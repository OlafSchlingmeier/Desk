PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
#DEFINE pcDepENG		GetText("RESERVAT","T_DEPDATE","ENG")
#DEFINE pcDepGER		GetText("RESERVAT","T_DEPDATE","GER")
*
PROCEDURE _mg00800
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_mg00800")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

PpCusorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
*
PROCEDURE PpCusorCreate
CREATE CURSOR Preproc (date D, mg_adlinh N(10), mg_adlinhm N(10), mg_adlinhy N(10), mg_cldinh N(10), mg_cldinhm N(10), mg_cldinhy N(10), ;
	mg_housrmd N(10), mg_housrmm N(10), mg_housrmy N(10), mg_vipinh N(10), mg_vipinhm N(10), mg_vipinhy N(10), mg_agninh N(10), mg_agninhm N(10), mg_agninhy N(10), ;
	mg_brtinh N(10), mg_brtinhm N(10), mg_brtinhy N(10), mg_roomwlk N(10), mg_rmwlkm N(10), mg_rmwlky N(10), mg_perswlk N(10), mg_perwlkm N(10), mg_perwlky N(10), ;
	mg_roomext N(10), mg_rmextm N(10), mg_rmexty N(10), mg_persns N(10), mg_pernsm N(10), mg_pernsy N(10), mg_rmarrt N(10), mg_rmarrtm N(10), mg_rmarrty N(10), ;
	mg_perarrt N(10), mg_prarrtm N(10), mg_prarrty N(10), mg_rmdept N(10), mg_rmdeptm N(10), mg_rmdepty N(10), mg_perdept N(10), mg_prdeptm N(10), mg_prdepty N(10), ;
	mg_shrocc N(10), mg_shroccm N(10), mg_shroccy N(10), mg_hcdayg1 B(2), mg_hcmong1 B(2), mg_hcyeag1 B(2), mg_hcdvat1 B(6), mg_hcmvat1 B(6), mg_hcyvat1 B(6))
ENDPROC
**********
DEFINE CLASS _mg00800 AS Session

PROCEDURE Init
Ini()
OpenFile(,"manager")
OpenFile(,"sharing")
OpenFile(,"resrmshr")
OpenFile(,"reservat")
OpenFile(,"resrate")
OpenFile(,"resrooms")
OpenFile(,"address")
OpenFile(,"histres")
OpenFile(,"hresrate")
OpenFile(,"hresroom")
OpenFile(,"histpost")
OpenFile(,"article")
PpCusorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER taPreProc
LOCAL lcHouseRc, ldMin1, ldMin10, ldMax10, ldDate, ldDateM, ldDateY, ldDateB, loManager
LOCAL ARRAY aDates(1)

lcHouseRc = PADR(min4,10)
ldMin1 = IIF(min1 = max1, GetRelDate(max1,"-1Y"), min1)
ldMin10 = DATE(YEAR(ldMin1),1,1)
ldMax10 = DATE(YEAR(max1),1,1)

CREATE CURSOR curDate (c_date D)
SELECT mg_date AS date FROM Manager WHERE INLIST(DTOS(mg_date), DTOS(ldMin1), DTOS(max1)) ORDER BY mg_date INTO CURSOR curPreproc
SELECT Preproc
APPEND FROM DBF("curPreproc")
SCAN
	ldDate = date
	ldDateM = GetRelDate(ldDate,"",1)
	ldDateY = DATE(YEAR(ldDate),1,1)
	ldDateB = MIN(ldDateM,ldDateY)
	ZAP IN curDate
	DIMENSION aDates(ldDate-ldDateB+1,1)
	INSERT INTO curDate FROM ARRAY aDates
	REPLACE c_date WITH ldDateB+RECNO()-1 ALL IN curDate

	SELECT rs_reserid, ;
		  rs_rsid, ;
		  c_date AS rr_date, ;
		  rs_arrdate, ;
		  rs_depdate, ;
		  rs_rooms, ;
		  rs_addrid, ;
		  rs_compid, ;
		  rs_agentid, ;
		  rs_created, ;
		  rs_status, ;
		  rs_cxldate, ;
		  NVL(ri_rroomid, 0) AS ri_rroomid, ;
		  NVL(ri_date, rs_arrdate) AS ri_date, ;
		  NVL(ri_todate, rs_depdate-1) AS ri_todate, ;
		  NVL(ri_roomtyp, rs_roomtyp) AS ri_roomtyp, ;
		  NVL(ri_roomnum, rs_roomnum) AS ri_roomnum, ;
		  CAST(NVL(ri_shareid, 0) AS Numeric(8)) AS ri_shareid, ;
		  NVL(rr_adults, rs_adults) AS rr_adults, ;
		  CAST(NVL(rr_childs + rr_childs2 + rr_childs3, rs_childs + rs_childs2 + rs_childs3) AS Numeric(4)) AS rr_childs, ;
		  CAST(LEFT(CHRTRAN(NVL(rr_ratecod, rs_ratecod), "*!", ""), 10) AS Character(10)) AS rs_ratecod, ;
		  EVL(GetOldDeparture(rs_changes, rs_status), rs_depdate) AS orgdepdate, ;
		  NVL(NVL(adl.ad_birth, adc.ad_birth), {}) AS ad_birth, ;
		  NVL(NVL(adl.ad_vip, adc.ad_vip), 0=1) AS ad_vip, ;
		  CAST(NVL(NVL(adl.ad_vipstat, adc.ad_vipstat), 0) AS Numeric(2)) AS ad_vipstat, ;
		  NVL(INLIST(rti.rt_group, 1, 4) AND rti.rt_vwsum, INLIST(rts.rt_group, 1, 4) AND rts.rt_vwsum) AS standard, ;
		  OCCURS(",", NVL(NVL(ICASE(ISNULL(rti.rt_group), .NULL., rti.rt_group = 4, rmi.rm_link, ""), ICASE(ISNULL(rts.rt_group), .NULL., rts.rt_group = 4, rms.rm_link, "")), "")) + 1 AS multiply ;
		FROM reservat ;
		INNER JOIN curDate ON BETWEEN(c_date, rs_arrdate, MAX(rs_arrdate,rs_depdate-1)) ;
		LEFT JOIN resrate ON rr_reserid = rs_reserid AND rr_date = c_date ;
		LEFT JOIN resrooms ON ri_reserid = rr_reserid AND BETWEEN(c_date, ri_date, ri_todate) ;
		LEFT JOIN roomtype rti ON rti.rt_roomtyp = ri_roomtyp ;
		LEFT JOIN roomtype rts ON rts.rt_roomtyp = rs_roomtyp ;
		LEFT JOIN room rmi ON rmi.rm_roomnum = ri_roomnum ;
		LEFT JOIN room rms ON rms.rm_roomnum = rs_roomnum ;
		LEFT JOIN address adl ON adl.ad_addrid = rs_addrid ;
		LEFT JOIN address adc ON adc.ad_addrid = rs_compid ;
		WHERE DTOS(rs_arrdate)+rs_lname < DTOS(ldDate+2) AND DTOS(rs_depdate)+rs_roomnum >= DTOS(ldDateB) AND BETWEEN(c_date, ldDateB, ldDate+1) AND rs_status <> "CXL" ;
	UNION ALL ;
	SELECT hr_reserid, ;
		  hr_rsid, ;
		  c_date, ;
		  hr_arrdate, ;
		  hr_depdate, ;
		  hr_rooms, ;
		  hr_addrid, ;
		  hr_compid, ;
		  hr_agentid, ;
		  hr_created, ;
		  hr_status, ;
		  hr_cxldate, ;
		  NVL(ri_rroomid, 0) AS ri_rroomid, ;
		  NVL(ri_date, hr_arrdate), ;
		  NVL(ri_todate, hr_depdate-1), ;
		  NVL(ri_roomtyp, hr_roomtyp), ;
		  NVL(ri_roomnum, hr_roomnum), ;
		  CAST(NVL(ri_shareid, 0) AS Numeric(8)), ;
		  NVL(rr_adults, hr_adults), ;
		  CAST(NVL(rr_childs + rr_childs2 + rr_childs3, hr_childs + hr_childs2 + hr_childs3) AS Numeric(4)), ;
		  CAST(LEFT(CHRTRAN(NVL(rr_ratecod, hr_ratecod), "*!", ""), 10) AS Character(10)), ;
		  EVL(GetOldDeparture(hr_changes, hr_status), hr_depdate), ;
		  NVL(NVL(adl.ad_birth, adc.ad_birth), {}), ;
		  NVL(NVL(adl.ad_vip, adc.ad_vip), 0=1), ;
		  CAST(NVL(NVL(adl.ad_vipstat, adc.ad_vipstat), 0) AS Numeric(2)), ;
		  NVL(INLIST(rti.rt_group, 1, 4) AND rti.rt_vwsum, INLIST(rts.rt_group, 1, 4) AND rts.rt_vwsum) AS standard, ;
		  OCCURS(",", NVL(NVL(ICASE(ISNULL(rti.rt_group), .NULL., rti.rt_group = 4, rmi.rm_link, ""), ICASE(ISNULL(rts.rt_group), .NULL., rts.rt_group = 4, rms.rm_link, "")), "")) + 1 AS multiply ;
		FROM histres ;
		LEFT JOIN reservat ON rs_reserid = hr_reserid ;
		INNER JOIN curDate ON BETWEEN(c_date, hr_arrdate, MAX(hr_arrdate,hr_depdate-1)) ;
		LEFT JOIN hresrate ON rr_reserid = hr_reserid AND rr_date = c_date ;
		LEFT JOIN hresroom ON ri_reserid = rr_reserid AND BETWEEN(c_date, ri_date, ri_todate) ;
		LEFT JOIN roomtype rti ON rti.rt_roomtyp = ri_roomtyp ;
		LEFT JOIN roomtype rts ON rts.rt_roomtyp = hr_roomtyp ;
		LEFT JOIN room rmi ON rmi.rm_roomnum = ri_roomnum ;
		LEFT JOIN room rms ON rms.rm_roomnum = hr_roomnum ;
		LEFT JOIN address adl ON adl.ad_addrid = hr_addrid ;
		LEFT JOIN address adc ON adc.ad_addrid = hr_compid ;
		WHERE hr_reserid > 1 AND hr_arrdate < ldDate+2 AND hr_depdate >= ldDateB AND BETWEEN(c_date, ldDateB, ldDate+1) AND ISNULL(rs_reserid) AND hr_status <> "CXL" ;
		ORDER BY 1, 3 ;
		INTO CURSOR curReservat READWRITE
	INDEX ON ri_shareid TAG ri_shareid
	INDEX ON rr_date TAG rr_date
	INDEX ON rs_ratecod TAG rs_ratecod
	SET ORDER TO
	SCAN FOR ri_shareid <> 0 AND rs_ratecod = lcHouseRc AND standard AND rs_status <> "NS"
		ldDate = rr_date
		lnShareId = ri_shareid
		lnRecno = RECNO()
		LOCATE FOR ri_shareid = lnShareId AND rr_date = ldDate AND standard AND rs_status <> "NS" AND rs_ratecod <> lcHouseRc
		IF FOUND()
			BLANK FIELDS rs_ratecod FOR ri_shareid = lnShareId AND rr_date = ldDate AND standard AND rs_status <> "NS" AND rs_ratecod = lcHouseRc
		ENDIF
		GO lnRecno
	ENDSCAN

	SELECT SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate,															rr_adults,		0)) AS mg_adlinh, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM,															rr_adults,		0)) AS mg_adlinhm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY,															rr_adults,		0)) AS mg_adlinhy, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate,															rr_childs,		0)) AS mg_cldinh, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM,															rr_childs,		0)) AS mg_cldinhm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY,															rr_childs,		0)) AS mg_cldinhy, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate					AND (ad_vip OR NOT EMPTY(ad_vipstat)),				rr_adults+rr_childs,0)) AS mg_vipinh, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM				AND (ad_vip OR NOT EMPTY(ad_vipstat)),				rr_adults+rr_childs,0)) AS mg_vipinhm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY				AND (ad_vip OR NOT EMPTY(ad_vipstat)),				rr_adults+rr_childs,0)) AS mg_vipinhy, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate					AND rs_ratecod = lcHouseRc,						rs_rooms*multiply,	0)) AS mg_housrmd, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM				AND rs_ratecod = lcHouseRc,						rs_rooms*multiply,	0)) AS mg_housrmm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY				AND rs_ratecod = lcHouseRc,						rs_rooms*multiply,	0)) AS mg_housrmy, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate  AND ri_shareid = 0 AND rs_addrid = rs_agentid,						rs_rooms*multiply,	0)) AS mg_agninh, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM AND ri_shareid = 0 AND rs_addrid = rs_agentid,						rs_rooms*multiply,	0)) AS mg_agninhm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY AND ri_shareid = 0 AND rs_addrid = rs_agentid,						rs_rooms*multiply,	0)) AS mg_agninhy, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate  AND ri_shareid = 0 AND BETWEEN(rr_date, orgdepdate, rs_depdate-1),		rs_rooms*multiply,	0)) AS mg_roomext, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM AND ri_shareid = 0 AND BETWEEN(rr_date, orgdepdate, rs_depdate-1),		rs_rooms*multiply,	0)) AS mg_rmextm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY AND ri_shareid = 0 AND BETWEEN(rr_date, orgdepdate, rs_depdate-1),		rs_rooms*multiply,	0)) AS mg_rmexty, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate					AND IsBirthday(rr_date, ad_birth),					rr_adults+rr_childs,0)) AS mg_brtinh, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM				AND IsBirthday(rr_date, ad_birth),					rr_adults+rr_childs,0)) AS mg_brtinhm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY				AND IsBirthday(rr_date, ad_birth),					rr_adults+rr_childs,0)) AS mg_brtinhy, ;
		  SUM(IIF(rs_status  = "NS" AND rr_date  = ldDate					AND rr_date = rs_cxldate,						rr_adults+rr_childs,0)) AS mg_persns, ;
		  SUM(IIF(rs_status  = "NS" AND rr_date >= ldDateM				AND rr_date = rs_cxldate,						rr_adults+rr_childs,0)) AS mg_pernsm, ;
		  SUM(IIF(rs_status  = "NS" AND rr_date >= ldDateY				AND rr_date = rs_cxldate,						rr_adults+rr_childs,0)) AS mg_pernsy, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate  AND ri_shareid = 0 AND rr_date = rs_arrdate AND rs_arrdate = rs_created,	rs_rooms,			0)) AS mg_roomwlk, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM AND ri_shareid = 0 AND rr_date = rs_arrdate AND rs_arrdate = rs_created,	rs_rooms,			0)) AS mg_rmwlkm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY AND ri_shareid = 0 AND rr_date = rs_arrdate AND rs_arrdate = rs_created,	rs_rooms,			0)) AS mg_rmwlky, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate					AND rr_date = rs_arrdate AND rs_arrdate = rs_created,	rr_adults+rr_childs,0)) AS mg_perswlk, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM				AND rr_date = rs_arrdate AND rs_arrdate = rs_created,	rr_adults+rr_childs,0)) AS mg_perwlkm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY				AND rr_date = rs_arrdate AND rs_arrdate = rs_created,	rr_adults+rr_childs,0)) AS mg_perwlky, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate  AND ri_shareid = 0 AND rr_date = rs_arrdate-1,						rs_rooms,			0)) AS mg_rmarrt, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM AND ri_shareid = 0 AND rr_date = rs_arrdate-1,						rs_rooms,			0)) AS mg_rmarrtm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY AND ri_shareid = 0 AND rr_date = rs_arrdate-1,						rs_rooms,			0)) AS mg_rmarrty, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate					AND rr_date = rs_arrdate-1,						rr_adults+rr_childs,0)) AS mg_perarrt, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM				AND rr_date = rs_arrdate-1,						rr_adults+rr_childs,0)) AS mg_prarrtm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY				AND rr_date = rs_arrdate-1,						rr_adults+rr_childs,0)) AS mg_prarrty, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate  AND ri_shareid = 0 AND rr_date = rs_depdate-1,						rs_rooms,			0)) AS mg_rmdept, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM AND ri_shareid = 0 AND rr_date = rs_depdate-1,						rs_rooms,			0)) AS mg_rmdeptm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY AND ri_shareid = 0 AND rr_date = rs_depdate-1,						rs_rooms,			0)) AS mg_rmdepty, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date  = ldDate					AND rr_date = rs_depdate-1,						rr_adults+rr_childs,0)) AS mg_perdept, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateM				AND rr_date = rs_depdate-1,						rr_adults+rr_childs,0)) AS mg_prdeptm, ;
		  SUM(IIF(rs_status <> "NS" AND rr_date >= ldDateY				AND rr_date = rs_depdate-1,						rr_adults+rr_childs,0)) AS mg_prdepty, ;
		  0 AS mg_shrocc, 0 AS mg_shroccm, 0 AS mg_shroccy ;
		  FROM curReservat ;
		  WHERE standard ;
		  INTO CURSOR curManager
	SCATTER NAME loManager

	SELECT sharing
	SCAN FOR SEEK(sd_shareid, "curReservat", "ri_shareid")
		ldArrdate		= ShInterval("ARRDATE", sd_shareid, sd_lowdat)
		ldDepdate		= ShInterval("DEPDATE", sd_shareid, sd_highdat)
		lnAgentId		= ShInterval("AGENTID", sd_shareid)
		ldCreated		= ShInterval("WALKIN", sd_shareid, sd_lowdat)
		ldOrigDepdate	= ShInterval("ORGDEPDATE", sd_shareid, sd_highdat)

		loManager.mg_agninh  = loManager.mg_agninh  + IIF(NOT EMPTY(lnAgentId) AND BETWEEN(ldDate,sd_lowdat,sd_highdat), curReservat.multiply, 0)
		loManager.mg_agninhm = loManager.mg_agninhm + IIF(NOT EMPTY(lnAgentId), MAX(MIN(sd_highdat,ldDate)-MAX(sd_lowdat,ldDateM)+1,0) * curReservat.multiply, 0)
		loManager.mg_agninhy = loManager.mg_agninhy + IIF(NOT EMPTY(lnAgentId), MAX(MIN(sd_highdat,ldDate)-MAX(sd_lowdat,ldDateY)+1,0) * curReservat.multiply, 0)
		loManager.mg_roomext = loManager.mg_roomext + IIF(NOT EMPTY(ldOrigDepdate) AND BETWEEN(ldDate,MAX(sd_lowdat,ldOrigDepdate),sd_highdat), curReservat.multiply, 0)
		loManager.mg_rmextm  = loManager.mg_rmextm  + IIF(NOT EMPTY(ldOrigDepdate), MAX(MIN(sd_highdat,ldDate)-MAX(MAX(sd_lowdat,ldOrigDepdate),ldDateM)+1,0) * curReservat.multiply, 0)
		loManager.mg_rmexty  = loManager.mg_rmexty  + IIF(NOT EMPTY(ldOrigDepdate), MAX(MIN(sd_highdat,ldDate)-MAX(MAX(sd_lowdat,ldOrigDepdate),ldDateY)+1,0) * curReservat.multiply, 0)
		loManager.mg_roomwlk = loManager.mg_roomwlk + IIF(NOT EMPTY(ldCreated) AND BETWEEN(ldDate,sd_lowdat,sd_highdat), curReservat.multiply, 0)
		loManager.mg_rmwlkm  = loManager.mg_rmwlkm  + IIF(NOT EMPTY(ldCreated), MAX(MIN(sd_highdat,ldDate)-MAX(sd_lowdat,ldDateM)+1,0) * curReservat.multiply, 0)
		loManager.mg_rmwlky  = loManager.mg_rmwlky  + IIF(NOT EMPTY(ldCreated), MAX(MIN(sd_highdat,ldDate)-MAX(sd_lowdat,ldDateY)+1,0) * curReservat.multiply, 0)
		loManager.mg_rmarrt  = loManager.mg_rmarrt  + IIF(NOT EMPTY(ldArrdate) AND sd_lowdat-1  = ldDate, 0, 1)
		loManager.mg_rmarrtm = loManager.mg_rmarrtm + IIF(NOT EMPTY(ldArrdate) AND sd_lowdat-1 >= ldDateM, 0, 1)
		loManager.mg_rmarrty = loManager.mg_rmarrty + IIF(NOT EMPTY(ldArrdate) AND sd_lowdat-1 >= ldDateY, 0, 1)
		loManager.mg_rmdept  = loManager.mg_rmdept  + IIF(NOT EMPTY(ldDepdate) AND sd_highdat-1  = ldDate, 0, 1)
		loManager.mg_rmdeptm = loManager.mg_rmdeptm + IIF(NOT EMPTY(ldDepdate) AND sd_highdat-1 >= ldDateM, 0, 1)
		loManager.mg_rmdepty = loManager.mg_rmdepty + IIF(NOT EMPTY(ldDepdate) AND sd_highdat-1 >= ldDateY, 0, 1)
		loManager.mg_shrocc  = loManager.mg_shrocc  + IIF(BETWEEN(ldDate,sd_lowdat,sd_highdat), curReservat.multiply, 0)
		loManager.mg_shroccm = loManager.mg_shroccm + MAX(MIN(sd_highdat,ldDate)-MAX(sd_lowdat,ldDateM)+1,0) * curReservat.multiply
		loManager.mg_shroccy = loManager.mg_shroccy + MAX(MIN(sd_highdat,ldDate)-MAX(sd_lowdat,ldDateY)+1,0) * curReservat.multiply
	ENDSCAN

	SELECT Preproc
	GATHER NAME loManager

	SELECT hp_date, hp_amount, hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9 AS hp_vat, ;
		CallFunc("MAX(NVL(p1,0),1)",ar_artityp) AS ar_artityp, CallFunc("MAX(NVL(p1,0),1)",ar_main) AS ar_main ;
		FROM histpost ;
		LEFT JOIN histres ON hr_reserid = hp_origid ;
		LEFT JOIN article ON ar_artinum = hp_artinum ;
		WHERE hp_reserid > 1 AND BETWEEN(hp_date, ldDateB, ldDate) AND hp_artinum <> 0 AND hp_amount <> 0 AND NOT hp_cancel AND hp_split AND ;
			(hr_complim OR PADR(CHRTRAN(hp_ratecod,"*!",""),10) = lcHouseRc) ;
		INTO CURSOR curPost

	SELECT SUM(IIF(hp_date  = ldDate  AND ar_artityp = 1 AND ar_main = 1, 1, 0) * hp_amount) AS mg_hcdayg1, ;
		  SUM(IIF(hp_date >= ldDateM AND ar_artityp = 1 AND ar_main = 1, 1, 0) * hp_amount) AS mg_hcmong1, ;
		  SUM(IIF(hp_date >= ldDateY AND ar_artityp = 1 AND ar_main = 1, 1, 0) * hp_amount) AS mg_hcyeag1, ;
		  SUM(IIF(hp_date  = ldDate  AND ar_artityp = 1 AND ar_main = 1, 1, 0) * hp_vat)    AS mg_hcdvat1, ;
		  SUM(IIF(hp_date >= ldDateM AND ar_artityp = 1 AND ar_main = 1, 1, 0) * hp_vat)    AS mg_hcmvat1, ;
		  SUM(IIF(hp_date >= ldDateY AND ar_artityp = 1 AND ar_main = 1, 1, 0) * hp_vat)    AS mg_hcyvat1 ;
		  FROM curPost ;
		  INTO CURSOR curManager
	SCATTER NAME loManager
	SELECT Preproc
	GATHER NAME loManager
ENDSCAN

SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE
**********
FUNCTION GetOldDeparture
LPARAMETERS tcChanges, tcStatus
LOCAL ldDepdate, lcChanges, lnPosCI, lnPosEng, lnPosGer, lcDepStr, lcDepChn

ldDepdate = {}
IF INLIST(tcStatus, "IN", "OUT")
	lnPosCI = RAT("CHECKIN", tcChanges, 1)
	lcChanges = IIF(lnPosCI = 0, tcChanges, SUBSTR(tcChanges,lnPosCI))
	lnPosEng = AT(pcDepENG, lcChanges, 1)
	lnPosGer = AT(pcDepGER, lcChanges, 1)
	lcDepStr = ICASE(lnPosEng = 0 AND lnPosGer = 0, "", lnPosGer = 0 OR lnPosEng < lnPosGer, pcDepENG, pcDepGER)
	IF NOT EMPTY(lcDepStr)
		lcDepChn = STREXTRACT(lcChanges, lcDepStr, ",", 1)
		ldDepdate = CTOD(RIGHT(lcDepChn,10))
	ENDIF
ENDIF

RETURN ldDepdate
ENDFUNC
*
FUNCTION IsBirthday
LPARAMETERS tdDate, tdBirth

RETURN NOT EMPTY(tdBirth) AND tdDate = DATE(YEAR(tdDate), MONTH(tdBirth), DAY(tdBirth))
ENDFUNC
*
FUNCTION ShInterval
LPARAMETERS tcLabel, tnShareId, tdDate
LOCAL lRetVal, lnArea, lorgdepdate

lnArea = SELECT()

lorgdepdate = {}
lRetVal = IIF(tcLabel = "AGENTID", 0, {})
SELECT resrmshr
SCAN FOR sr_shareid = tnShareId
	DO CASE
		CASE SEEK(resrmshr.sr_rroomid,"resrooms","tag3") AND SEEK(resrooms.ri_reserid,"reservat","tag1")
			DO CASE
				CASE tcLabel = "AGENTID"
					IF NOT EMPTY(reservat.rs_agentid) AND reservat.rs_addrid = reservat.rs_agentid
						lRetVal = reservat.rs_agentid
						EXIT
					ENDIF
				CASE tcLabel = "ARRDATE"
					IF tdDate = reservat.rs_arrdate
						lRetVal = reservat.rs_arrdate
						EXIT
					ENDIF
				CASE tcLabel = "DEPDATE"
					IF tdDate = MAX(reservat.rs_arrdate,reservat.rs_depdate-1)
						lRetVal = reservat.rs_depdate
						EXIT
					ENDIF
				CASE tcLabel = "WALKIN"
					IF tdDate = reservat.rs_arrdate AND reservat.rs_arrdate = reservat.rs_created
						lRetVal = tdDate
					ELSE
						lRetVal = {}
						EXIT
					ENDIF
				CASE tcLabel = "ORGDEPDATE"
					lorgdepdate = MAX(lorgdepdate, EVL(GetOldDeparture(reservat.rs_changes, reservat.rs_status), reservat.rs_depdate))
					IF tdDate >= lorgdepdate
						lRetVal = lorgdepdate
					ELSE
						lRetVal = {}
						EXIT
					ENDIF
				OTHERWISE
					EXIT
			ENDCASE
		CASE SEEK(resrmshr.sr_rroomid,"hresroom","tag3") AND SEEK(hresroom.ri_reserid,"histres","tag1")
			DO CASE
				CASE tcLabel = "AGENTID"
					IF NOT EMPTY(histres.hr_agentid) AND histres.hr_addrid = histres.hr_agentid
						lRetVal = histres.hr_agentid
						EXIT
					ENDIF
				CASE tcLabel = "ARRDATE"
					IF tdDate = histres.hr_arrdate
						lRetVal = histres.hr_arrdate
						EXIT
					ENDIF
				CASE tcLabel = "DEPDATE"
					IF tdDate = MAX(histres.hr_arrdate,histres.hr_depdate-1)
						lRetVal = histres.hr_depdate
						EXIT
					ENDIF
				CASE tcLabel = "WALKIN"
					IF tdDate = histres.hr_arrdate AND histres.hr_arrdate = histres.hr_created
						lRetVal = tdDate
					ELSE
						lRetVal = {}
						EXIT
					ENDIF
				CASE tcLabel = "ORGDEPDATE"
					lorgdepdate = MAX(lorgdepdate, EVL(GetOldDeparture(histres.hr_changes, histres.hr_status), histres.hr_depdate))
					IF tdDate >= lorgdepdate
						lRetVal = lorgdepdate
					ELSE
						lRetVal = {}
						EXIT
					ENDIF
				OTHERWISE
					EXIT
			ENDCASE
		OTHERWISE
			EXIT
	ENDCASE
ENDSCAN

SELECT (lnArea)

RETURN lRetVal
ENDFUNC
*