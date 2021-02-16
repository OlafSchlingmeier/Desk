PROCEDURE PpVersion
 PARAMETER cversion
 cversion = "1.00"
 RETURN
ENDPROC
*
PROCEDURE BillInfo
 LOCAL l_cForClause, l_nSelect, l_nRecNo, l_cResultCur, l_nGroupTotal
 PRIVATE p_nId
 p_nId = 0
 IF EMPTY(min2)
 	l_cForClause = "rs_reserid = min1"
 ELSE
 	l_cForClause = min2
 ENDIF
 l_cResultCur = "curBillInfo"
 l_nSelect = SELECT()
 CREATE CURSOR &l_cResultCur (w_codepage c(1), w_id n(8), w_reserid N(12,3), w_type c(4), w_artinum n(8), w_from d(8), w_to d(8), ;
 		w_units n(3), w_price b(2), w_descrip c(90), w_ratetot b(2), w_artitot b(2), w_total b(2))
 l_nGroupTotal = 0
 SELECT * FROM reservat WHERE &l_cForClause INTO CURSOR curResResult
 IF RECCOUNT() = 0
 	SELECT (l_nSelect)
 	RETURN .T.
 ENDIF
 SELECT curResResult
 SCAN FOR &l_cForClause
 	= CalcBillInfo(l_cResultCur)
 	l_nGroupTotal = l_nGroupTotal + &l_cResultCur..w_total
 ENDSCAN
 DELETE IN &l_cResultCur
 p_nId = p_nId + 1
 INSERT INTO &l_cResultCur (w_id, w_reserid, w_type, w_total) ;
 		VALUES (p_nId, min1, "LAST", l_nGroupTotal)
 
 SELECT w_reserid AS ReserId, ;
		rs_arrdate AS Anreise, ;
		rs_depdate AS Abreise, ;
		rs_roomtyp AS Zimmertyp, ;
		rs_rooms AS Anzahl_Zimmer, ;
		rs_roomnum AS Zimmernummer, ;
		(rs_adults + rs_childs + rs_childs2 + rs_childs3) AS Pax_Pro_Zimmer, ;
		rs_status AS Res_Status, ;
		rs_ratecod AS Preiscode, ;
		STR(w_price,8,2) AS Preis, ;
		rs_lname AS Gastname, ;
		rs_company AS Firma, ;
		rs_group AS Gruppenname, ;
		w_from AS Von_Datum, ;
		w_to AS Bis_Datum, ;
		w_artinum AS Artikelnr, ;
		w_descrip AS Beschreibung, ;
		w_units AS Menge, ;
		STR((w_units * w_price),8,2) AS Gesamtpreis, ;
		w_id ;
		FROM &l_cResultCur LEFT JOIN reservat ON w_reserid = rs_reserid WHERE w_type = "RATE" ORDER BY w_id INTO CURSOR curNew

 ccSvfile = Sys(2023)+"\BFWRES.TXT"
 lcsvfileok = filecsv("curnew",ccsvfile,.t.)

 SELECT w_reserid AS ReserId, ;
		w_from AS Von_Datum, ;
		w_to AS Bis_Datum, ;
		w_artinum AS Artikelnr, ;
		w_descrip AS Beschreibung, ;
		w_units AS Menge, ;
		STR(w_price,8,2) AS Preis, ;
		STR((w_units * w_price),8,2) AS Gesamtpreis, ;
		w_id ;
		FROM &l_cResultCur LEFT JOIN reservat ON w_reserid = rs_reserid WHERE INLIST(w_type,"EXTR","FIX") ORDER BY w_id INTO CURSOR curNew

 ccSvfile = Sys(2023)+"\BFWFIX.TXT"
 lcsvfileok = filecsv("curnew",ccsvfile,.t.)

 USE IN curNew
 USE IN curResResult
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE CalcBillInfo
 LPARAMETERS lp_cResultCur
 LOCAL l_nSelect, l_cResultCur, l_cTempCur, l_dFromDate, l_oPrevRecord, l_cDescrip, l_nTotal, l_nId, l_nQuantity
 LOCAL l_nRateTotal, l_nArtiTotal, l_nIntervalTotal
 l_cResultCur = lp_cResultCur
 l_nId = p_nId
 l_cTempCur = SYS(2015)
 l_oPrevRecord = .NULL.
 l_nSelect = SELECT()
 l_nReserId = reservat.rs_reserid
 = invoice(l_cTempCur)
 SELECT &l_cTempCur
 SUM ps_price * ps_units FOR NOT ps_split TO l_nTotal
 l_nTotal = l_nTotal * reservat.rs_rooms
 SUM ps_price * ps_units FOR NOT ps_split AND NOT EMPTY(ps_ratecod) TO l_nRateTotal
 l_nRateTotal = l_nRateTotal * reservat.rs_rooms
 SUM ps_price * ps_units FOR NOT ps_split AND EMPTY(ps_ratecod) TO l_nArtiTotal
 l_nArtiTotal = l_nArtiTotal * reservat.rs_rooms
 INDEX ON ps_invdate FOR NOT ps_split AND NOT EMPTY(ps_ratecod) TAG MAINART
 INDEX ON PADR(ps_invtype,1) + STR(ps_artinum,4) + STR(ps_price,12,2) + STR(ps_amount,12,2) + ;
 	DTOS(ps_invdate) FOR EMPTY(ps_ratecod) TAG ARTIC
 SET ORDER TO MAINART
 GO TOP
 SCATTER NAME l_oPrevRecord MEMO
 l_dFromDate = reservat.rs_arrdate
 l_nIntervalTotal = 0
 DO WHILE NOT EOF()
 	l_nIntervalTotal = l_nIntervalTotal + l_oPrevRecord.ps_price
 	SKIP 1
 	IF ps_amount <> l_oPrevRecord.ps_amount OR EOF()
 		l_cDescrip = l_oPrevRecord.ps_descrip
 		IF EMPTY(l_cDescrip)
 			l_cDescrip = DLookup("ratecode", "rc_ratecod = " + SqlCnv(LEFT(l_oPrevRecord.ps_ratecod,10)), "rc_lang" + g_Langnum)
 		ENDIF
 		IF EMPTY(l_cDescrip)
 			l_cDescrip = DLookup("article", "ar_artinum = " + SqlCnv(l_oPrevRecord.ps_artinum), "ar_lang" + g_Langnum)
 		ENDIF
 		l_nId = l_nId + 1
 		IF EOF()
 			l_oPrevRecord.ps_invdate = MAX(reservat.rs_arrdate, reservat.rs_depdate-1)
 		ENDIF
 		l_oPrevRecord.ps_price = l_nIntervalTotal / (l_oPrevRecord.ps_invdate-l_dFromDate+1)
 		INSERT INTO &l_cResultCur (w_codepage, w_id, w_reserid, w_type, w_from, w_to, w_units, w_price, w_descrip, w_ratetot, w_artitot, w_total, w_artinum) ;
 				VALUES ("æ", l_nId, l_nReserId, "RATE", l_dFromDate, l_oPrevRecord.ps_invdate, reservat.rs_rooms, ;
 					l_oPrevRecord.ps_price, l_cDescrip, l_nRateTotal, l_nArtiTotal, l_nTotal, l_oPrevRecord.ps_artinum)
 		l_dFromDate = l_oPrevRecord.ps_invdate + 1
 		l_nIntervalTotal = 0
 	ENDIF
 	SCATTER NAME l_oPrevRecord MEMO
 ENDDO
 SET ORDER TO ARTIC
 GO TOP
 IF NOT EOF()
 	l_nId = l_nId + 1
 	INSERT INTO &l_cResultCur (w_id, w_reserid, w_descrip, w_ratetot, w_artitot, w_total) ;
 			VALUES (l_nId, l_nReserId, GetLangText("WORDAPP","TXT_ADD_CHARGES"), l_nRateTotal, l_nArtiTotal, l_nTotal)
 ENDIF
 GO TOP
 l_dFromDate = ps_invdate
 SCATTER NAME l_oPrevRecord MEMO
 l_nQuantity = 0
 DO WHILE NOT EOF()
 	l_nQuantity = l_nQuantity + l_oPrevRecord.ps_units
 	SKIP 1
 	IF (ps_invtype <> l_oPrevRecord.ps_invtype) OR (ps_artinum <> l_oPrevRecord.ps_artinum) OR ;
 			(ps_price <> l_oPrevRecord.ps_price) OR (ps_amount <> l_oPrevRecord.ps_amount) OR EOF()
 		l_cDescrip = l_oPrevRecord.ps_descrip
 		IF EMPTY(l_cDescrip)
 			l_cDescrip = DLookup("article", "ar_artinum = " + SqlCnv(l_oPrevRecord.ps_artinum), "ar_lang" + g_Langnum)
 		ENDIF
 		l_nId = l_nId + 1
  		INSERT INTO &l_cResultCur (w_id, w_reserid, w_type, w_artinum, w_from, w_to, w_units, w_price, w_descrip, w_ratetot, w_artitot, w_total) ;
 				VALUES (l_nId, l_nReserId, IIF(EMPTY(l_oPrevRecord.ps_invtype), "EXTR", "FIX"), l_oPrevRecord.ps_artinum, ;
 					l_dFromDate, l_oPrevRecord.ps_invdate, l_nQuantity * reservat.rs_rooms, ;
 					l_oPrevRecord.ps_price, l_cDescrip, l_nRateTotal, l_nArtiTotal, l_nTotal)
 		l_dFromDate = ps_invdate
 		l_nQuantity = 0
 	ENDIF
 	SCATTER NAME l_oPrevRecord MEMO
 ENDDO
 l_nId = l_nId + 1
 INSERT INTO &l_cResultCur (w_id, w_reserid, w_type, w_descrip, w_ratetot, w_artitot, w_total) ;
 		VALUES (l_nId, l_nReserId, "RESL", GetLangText("WORDAPP","TXT_NEXT_RESERVATION"), l_nRateTotal, l_nArtiTotal, l_nTotal)
 USE IN &l_cTempCur
 SELECT (l_nSelect)
 p_nId = l_nId
 RETURN l_cResultCur
ENDPROC