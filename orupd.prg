PROCEDURE OrUpd
LOCAL laDialog, lcExitMessage, lnStartYear, lnEndYear, llRecalcOcc, llRecalcRev, ltStartTime, ltEndTime

OpenFileDirect(.F.,"Histors")
SELECT Histors
SET ORDER TO
LOCATE FOR or_date >= DATE(2000,1,1)
DIMENSION laDialog[3, 8]
laDialog[1, 1] = "txtStartDate"
laDialog[1, 2] = GetLangText("ASTAT","TXT_START_YEAR")
laDialog[1, 3] = "YEAR(IIF(EMPTY(or_date), SysDate(), or_date))"
laDialog[1, 4] = ""
laDialog[1, 5] = 11
laDialog[1, 6] = ""
laDialog[1, 7] = ""
laDialog[2, 1] = "txtEndDate"
laDialog[2, 2] = GetLangText("ASTAT","TXT_END_YEAR")
laDialog[2, 3] = "YEAR(SysDate())"
laDialog[2, 4] = ""
laDialog[2, 5] = 11
laDialog[2, 6] = ""
laDialog[2, 7] = ""
laDialog[3, 1] = "recalcopt"
laDialog[3, 2] = GetLangText("ASTAT","TXT_RECALC_OCC")+";"+GetLangText("ASTAT","TXT_RECALC_REV")+";"+GetLangText("ORSTAT","TXT_RECALC_BOTH")
laDialog[3, 3] = "3"
laDialog[3, 4] = "@*RH"
laDialog[3, 5] = 30
laDialog[3, 6] = ""
laDialog[3, 7] = ""
IF Dialog(GetLangText("ORSTAT","TXT_RECALCULATE"),GetLangText("STATISTIC", "TXT_PROCEED_FILL_REVENUE"),@laDialog)
	lnStartYear = laDialog(1,8)
	lnEndYear   = laDialog(2,8)
	llRecalcOcc = laDialog(3,8)#2
	llRecalcRev = laDialog(3,8)#1
ENDIF
IF EMPTY(lnStartYear) OR EMPTY(lnEndYear) OR NOT llRecalcOcc AND NOT llRecalcRev
	lcExitMessage = GetLangText("ORSTAT","TXT_NO_CHANGES_MADE")
ELSE
	ltStartTime = SECONDS()
	ReCalcOrStat(lnStartYear, lnEndYear, llRecalcOcc, llRecalcRev)
	ltEndTime = SECONDS()
	lcExitMessage = Str2Msg(GetLangText("ORSTAT","TXT_CHANGES_ARE_MADE"), "%s", Sec2Time(ltEndTime - ltStartTime))
	WAIT CLEAR
ENDIF

Alert(lcExitMessage, GetLangText("ORSTAT","TXT_RECALCULATE"))
RETURN .T.
ENDPROC
*
FUNCTION ReCalcOrStat
LPARAMETERS tnStartYear, tnEndYear, tlRecalcOcc, tlRecalcRev
	PRIVATE pdStartDate, pdEndDate
	LOCAL lcOrstat, loAudit
	LOCAL ARRAY l_aProcess(4)

	pdStartDate = DATE(tnStartYear,1,1)
	pdEndDate = DATE(tnEndYear,12,31)

	OpenFileDirect(.F.,"Orstat")

	STORE 0 TO l_aProcess
	IF tlRecalcRev
		SET ORDER TO "" IN histpost
		CALCULATE CNT() FOR BETWEEN(hp_date, pdStartDate, pdEndDate) AND NOT SEEK(hp_reserid,"reservat","tag1") TO l_aProcess(1) IN histpost
	ENDIF
	IF tlRecalcOcc
		SET ORDER TO "" IN histres
		CALCULATE CNT() FOR hr_reserid > 1 AND hr_arrdate <= pdEndDate AND hr_depdate > pdStartDate AND NOT SEEK(hr_reserid,"reservat","tag1") TO l_aProcess(2) IN histres
	ENDIF
	IF tlRecalcRev
		SET ORDER TO "" IN post
		CALCULATE CNT() FOR BETWEEN(ps_date, pdStartDate, pdEndDate) TO l_aProcess(3) IN post
	ENDIF
	IF tlRecalcOcc
		SET ORDER TO "" IN reservat
		CALCULATE CNT() FOR rs_reserid > 1 AND DTOS(rs_arrdate)+rs_lname < DTOS(pdEndDate+1) AND DTOS(rs_depdate)+rs_roomnum > DTOS(pdStartDate) TO l_aProcess(4) IN reservat
	ENDIF

	DO CASE
		CASE tlRecalcRev AND tlRecalcOcc
			DELETE FOR BETWEEN(or_date, pdStartDate, pdEndDate) IN orstat
			DELETE FOR BETWEEN(or_date, pdStartDate, pdEndDate) IN histors
		CASE tlRecalcOcc
			BLANK FIELDS LIKE or_*pax, or_*rms FOR BETWEEN(or_date, pdStartDate, pdEndDate) IN orstat
			BLANK FIELDS LIKE or_*pax, or_*rms FOR BETWEEN(or_date, pdStartDate, pdEndDate) IN histors
		CASE tlRecalcRev
			BLANK FIELDS LIKE or_0rev?, or_0vat?, or_crev?, or_cvat? FOR BETWEEN(or_date, pdStartDate, pdEndDate) IN orstat
			BLANK FIELDS LIKE or_0rev?, or_0vat?, or_crev?, or_cvat? FOR BETWEEN(or_date, pdStartDate, pdEndDate) IN histors
	ENDCASE

	DO FORM "forms\audit" NAME loAudit WITH ChildTitle(GetLangText("ORSTAT","TXT_RECALCULATE"))
	loAudit.lLog = .F.
	loAudit.ScrollProgressInit(@l_aProcess)

	lcOrstat = "histors"
	IF tlRecalcRev
		loAudit.TxtInfo("Scaning through HistPost table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN histpost
		SELECT histpost
		SCAN FOR BETWEEN(hp_date, pdStartDate, pdEndDate) AND NOT SEEK(hp_reserid,"reservat","tag1")
			loAudit.Progress(1)
			OrHistPs(lcOrstat)
		ENDSCAN
	ENDIF

	IF tlRecalcOcc
		loAudit.TxtInfo("Scaning through HistRes table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN histres
		SELECT histres
		SCAN FOR hr_reserid > 1 AND hr_arrdate <= pdEndDate AND hr_depdate > pdStartDate AND NOT SEEK(hr_reserid,"reservat","tag1")
			loAudit.Progress(2)
			OrHistRs(lcOrstat)
		ENDSCAN
	ENDIF

	lcOrstat = "orstat"
	IF tlRecalcRev
		loAudit.TxtInfo("Scaning through Post table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN post
		SELECT post
		SCAN FOR BETWEEN(ps_date, pdStartDate, pdEndDate)
			loAudit.Progress(3)
			OrPost(lcOrstat)
		ENDSCAN
	ENDIF

	IF tlRecalcOcc
		loAudit.TxtInfo("Scaning through Reservat table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN reservat
		SELECT reservat
		SCAN FOR rs_reserid > 1 AND DTOS(rs_arrdate)+rs_lname < DTOS(pdEndDate+1) AND DTOS(rs_depdate)+rs_roomnum > DTOS(pdStartDate)
			loAudit.Progress(4)
			OrReservat(lcOrstat)
		ENDSCAN
	ENDIF
	ON KEY LABEL ALT+Q
	loAudit.Release()
ENDFUNC

FUNCTION OrPost
LPARAMETERS lp_cAlias
 LOCAL l_oResroom, l_cRoomType, l_cRoomNum, l_cRatecode, l_nSelect, l_lCloseHresrooms, l_lCloseHresrate
 IF NOT post.ps_cancel AND post.ps_artinum > 0 AND (EMPTY(post.ps_ratecod) OR post.ps_split)
	l_nSelect = SELECT()
	IF NOT USED("hresrate")
		openfiledirect(.F., "hresrate")
		l_lCloseHresrate = .T.
	ENDIF
	IF NOT USED("hresroom")
		openfiledirect(.F., "hresroom")
		l_lCloseHresrooms = .T.
	ENDIF
	IF NOT SEEK(post.ps_origid, "histres", "tag1")
		= SEEK(post.ps_reserid, "histres", "tag1")
	ENDIF
	RiGetRoom(histres.hr_reserid, post.ps_date, @l_oResroom, "hresroom")
	l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, histres.hr_roomtyp)
	l_cRoomNum = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomnum, histres.hr_roomnum)
	= SEEK(STR(histres.hr_reserid,12,3)+DTOS(post.ps_date), "hresrate", "tag2")
	l_cRatecode = IIF(FOUND("hresrate"), LEFT(hresrate.rr_ratecod,10), STRTRAN(STRTRAN(histres.hr_ratecod,"*"),"!"))
	LOCAL l_nMainGr, l_nVat
	IF SEEK(post.ps_artinum,"article","tag1")
		*IF NOT INLIST(article.ar_artityp,1,3)
		*	RETURN .T.
		*ENDIF
		l_nMainGr = article.ar_main
	ELSE
		l_nMainGr = 10
	ENDIF
	l_nVat = post.ps_vat1 + post.ps_vat2 + post.ps_vat3 + post.ps_vat4 + post.ps_vat5 + ;
		post.ps_vat6 + post.ps_vat7 + post.ps_vat8 + post.ps_vat9
	OrPsUpd(lp_cAlias, "MARKET", histres.hr_market, post.ps_date, l_nMainGr, post.ps_amount, l_nVat)
	OrPsUpd(lp_cAlias, "SOURCE", histres.hr_source, post.ps_date, l_nMainGr, post.ps_amount, l_nVat)
	OrPsUpd(lp_cAlias, "COUNTRY", histres.hr_country, post.ps_date, l_nMainGr, post.ps_amount, l_nVat)
	OrPsUpd(lp_cAlias, "ROOMTYP", l_cRoomType, post.ps_date, l_nMainGr, post.ps_amount, l_nVat)
	OrPsUpd(lp_cAlias, "ROOMNUM", l_cRoomNum, post.ps_date, l_nMainGr, post.ps_amount, l_nVat)
	OrPsUpd(lp_cAlias, "RATECOD", l_cRatecode, post.ps_date, l_nMainGr, post.ps_amount, l_nVat)
	IF l_lCloseHresrooms
		USE IN hresroom
	ENDIF
	IF l_lCloseHresrate
		USE IN hresrate
	ENDIF
	SELECT (l_nSelect)
 ENDIF
ENDFUNC

FUNCTION OrHistPs
LPARAMETERS lp_cAlias
 LOCAL l_oResroom, l_cRoomType, l_cRoomNum, l_cRatecode, l_nSelect
 IF NOT histpost.hp_cancel AND histpost.hp_artinum > 0 AND (EMPTY(histpost.hp_ratecod) OR histpost.hp_split)
	l_nSelect = SELECT()
	IF NOT SEEK(histpost.hp_origid, "histres", "tag1")
		= SEEK(histpost.hp_reserid, "histres", "tag1")
	ENDIF
	RiGetRoom(histres.hr_reserid, histpost.hp_date, @l_oResroom, .NULL., "hresroom")
	l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, histres.hr_roomtyp)
	l_cRoomNum = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomnum, histres.hr_roomnum)
	= SEEK(STR(histres.hr_reserid,12,3)+DTOS(histpost.hp_date), "hresrate", "tag2")
	l_cRatecode = IIF(FOUND("hresrate"), LEFT(hresrate.rr_ratecod,10), STRTRAN(STRTRAN(histres.hr_ratecod,"*"),"!"))
	LOCAL l_nMainGr, l_nVat
	IF SEEK(histpost.hp_artinum,"article","tag1")
		*IF NOT INLIST(article.ar_artityp,1,3)
		*	RETURN .T.
		*ENDIF
		l_nMainGr = article.ar_main
	ELSE
		l_nMainGr = 10
	ENDIF
	l_nVat = histpost.hp_vat1+histpost.hp_vat2 + histpost.hp_vat3 + histpost.hp_vat4 + histpost.hp_vat5 + ;
		histpost.hp_vat6 + histpost.hp_vat7 + histpost.hp_vat8 + histpost.hp_vat9
	OrPsUpd(lp_cAlias, "MARKET", histres.hr_market, histpost.hp_date, l_nMainGr, histpost.hp_amount, l_nVat)
	OrPsUpd(lp_cAlias, "SOURCE", histres.hr_source, histpost.hp_date, l_nMainGr, histpost.hp_amount, l_nVat)
	OrPsUpd(lp_cAlias, "COUNTRY", histres.hr_country, histpost.hp_date, l_nMainGr, histpost.hp_amount, l_nVat)
	OrPsUpd(lp_cAlias, "ROOMTYP", l_cRoomType, histpost.hp_date, l_nMainGr, histpost.hp_amount, l_nVat)
	OrPsUpd(lp_cAlias, "ROOMNUM", l_cRoomNum, histpost.hp_date, l_nMainGr, histpost.hp_amount, l_nVat)
	OrPsUpd(lp_cAlias, "RATECOD", l_cRatecode, histpost.hp_date, l_nMainGr, histpost.hp_amount, l_nVat)
	SELECT (l_nSelect)
 ENDIF
ENDFUNC

FUNCTION OrRooms
LPARAMETERS lp_cRoomTyp, lp_nRooms, lp_cRoomNum
 IF NOT EMPTY(lp_cRoomNum) AND dblookup("roomtype","tag1",lp_cRoomTyp,"rt_group") == 4
	lp_nRooms = lp_nRooms * (OCCURS(",", ;
		dlookup("room","rm_roomnum="+sqlcnv(lp_cRoomNum),'rm_link')) + 1)
 ENDIF
 RETURN lp_nRooms
ENDFUNC

FUNCTION OrReservat
LPARAMETERS lp_cAlias
 LOCAL l_nSelect
 PRIVATE p_lAdd
 p_lAdd = .T.
 l_nSelect = SELECT()
 OrResUpd(lp_cAlias, "MARKET", "reservat")
 OrResUpd(lp_cAlias, "SOURCE", "reservat")
 OrResUpd(lp_cAlias, "COUNTRY", "reservat")
 OrResUpd(lp_cAlias, "ROOMTYP", "reservat")
 OrResUpd(lp_cAlias, "ROOMNUM", "reservat")
 OrResUpd(lp_cAlias, "RATECOD", "reservat")
 SELECT (l_nSelect)
ENDFUNC

FUNCTION OrHistRs
LPARAMETERS lp_cAlias, lp_lRemove
 LOCAL l_nSelect
 PRIVATE p_lAdd
 p_lAdd = NOT lp_lRemove	&& Remove values in OrResUpd()
 l_nSelect = SELECT()
 OrResUpd(lp_cAlias, "MARKET", "histres")
 OrResUpd(lp_cAlias, "SOURCE", "histres")
 OrResUpd(lp_cAlias, "COUNTRY", "histres")
 OrResUpd(lp_cAlias, "ROOMTYP", "histres")
 OrResUpd(lp_cAlias, "ROOMNUM", "histres")
 OrResUpd(lp_cAlias, "RATECOD", "histres")
 SELECT (l_nSelect)
ENDFUNC

FUNCTION OrInsert
LPARAMETERS lp_cAlias, lp_cLabel, lp_cCode, lp_dDate
 LOCAL l_oRec
 SELECT(lp_cAlias)
 SET ORDER TO tag1 DESCENDING
 SET NEAR ON
 = SEEK(PADR(lp_cLabel,10)+PADR(lp_cCode,10)+DTOS(lp_dDate))
 IF (or_label=lp_cLabel) AND (or_code=lp_cCode) AND ;
		YEAR(or_date)==YEAR(lp_dDate) AND (or_date<lp_dDate)
	SCATTER NAME l_oRec
 ELSE
	SCATTER NAME l_oRec BLANK
 ENDIF
 SET NEAR OFF
 SET ORDER TO tag1 ASCENDING
 INSERT INTO &lp_cAlias (or_date, or_label, or_code, ;
		or_crms, or_cpax, or_cdayrms, or_cdaypax, ;
		or_carrrms, or_carrpax, or_cdeprms, or_cdeppax, ;
		or_crev0, or_crev1, or_crev2, or_crev3, ;
		or_crev4, or_crev5, or_crev6, or_crev7, ;
		or_crev8, or_crev9, or_cvat0, or_cvat1, ;
		or_cvat2, or_cvat3, or_cvat4, or_cvat5, ;
		or_cvat6, or_cvat7, or_cvat8, or_cvat9) ;
	VALUES (lp_dDate, lp_cLabel, lp_cCode, ;
		l_oRec.or_crms, l_oRec.or_cpax, l_oRec.or_cdayrms, l_oRec.or_cdaypax, ;
		l_oRec.or_carrrms, l_oRec.or_carrpax, l_oRec.or_cdeprms, l_oRec.or_cdeppax, ;
		l_oRec.or_crev0, l_oRec.or_crev1, l_oRec.or_crev2, l_oRec.or_crev3, ;
		l_oRec.or_crev4, l_oRec.or_crev5, l_oRec.or_crev6, l_oRec.or_crev7, ;
		l_oRec.or_crev8, l_oRec.or_crev9, l_oRec.or_cvat0, l_oRec.or_cvat1, ;
		l_oRec.or_cvat2, l_oRec.or_cvat3, l_oRec.or_cvat4, l_oRec.or_cvat5, ;
		l_oRec.or_cvat6, l_oRec.or_cvat7, l_oRec.or_cvat8, l_oRec.or_cvat9)
ENDFUNC

FUNCTION OrPsUpd
LPARAMETERS lp_cAlias, lp_cLabel, lp_cCode, lp_dDate, lp_nMainGr, lp_nAmount, lp_nVat
 LOCAL l_nCount, l_nSelect, l_cOrder, l_lPeriodFilter
 LOCAL ARRAY l_anAmount(11), l_anVat(11)

 l_lPeriodFilter = (VARTYPE(pdStartDate)="D" AND VARTYPE(pdEndDate)="D")
 IF l_lPeriodFilter AND NOT BETWEEN(lp_dDate, pdStartDate, pdEndDate)
	RETURN
 ENDIF
 l_nSelect = SELECT()
 SELECT(lp_cAlias)
 l_cOrder = ORDER()
 IF LOWER(l_cOrder) <> "tag1"
 	SET ORDER TO tag1
 ENDIF
 FOR l_nCount = 1 TO 11
	l_anAmount(l_nCount) = 0
	l_anVat(l_nCount) = 0
 ENDFOR
 l_anAmount(lp_nMainGr+1) = lp_nAmount
 l_anVat(lp_nMainGr+1) = lp_nVat
 IF NOT SEEK(PADR(lp_cLabel,10)+PADR(lp_cCode,10)+DTOS(lp_dDate),lp_cAlias,"tag1")
	OrInsert(lp_cAlias, lp_cLabel, lp_cCode, lp_dDate)
 ENDIF
 REPLACE or_0rev0 WITH or_0rev0+l_anAmount(1), ;
		or_0rev1 WITH or_0rev1+l_anAmount(2), ;
		or_0rev2 WITH or_0rev2+l_anAmount(3), ;
		or_0rev3 WITH or_0rev3+l_anAmount(4), ;
		or_0rev4 WITH or_0rev4+l_anAmount(5), ;
		or_0rev5 WITH or_0rev5+l_anAmount(6), ;
		or_0rev6 WITH or_0rev6+l_anAmount(7), ;
		or_0rev7 WITH or_0rev7+l_anAmount(8), ;
		or_0rev8 WITH or_0rev8+l_anAmount(9), ;
		or_0rev9 WITH or_0rev9+l_anAmount(10), ;
		or_0revx WITH or_0revx+l_anAmount(11), ;
		or_0vat0 WITH or_0vat0+l_anVat(1), ;
		or_0vat1 WITH or_0vat1+l_anVat(2), ;
		or_0vat2 WITH or_0vat2+l_anVat(3), ;
		or_0vat3 WITH or_0vat3+l_anVat(4), ;
		or_0vat4 WITH or_0vat4+l_anVat(5), ;
		or_0vat5 WITH or_0vat5+l_anVat(6), ;
		or_0vat6 WITH or_0vat6+l_anVat(7), ;
		or_0vat7 WITH or_0vat7+l_anVat(8), ;
		or_0vat8 WITH or_0vat8+l_anVat(9), ;
		or_0vat9 WITH or_0vat9+l_anVat(10), ;
		or_0vatx WITH or_0vatx+l_anVat(11)
 SCAN REST WHILE (or_label=lp_cLabel) AND (or_code=lp_cCode) AND ;
		(YEAR(or_date)==YEAR(lp_dDate))
	REPLACE or_crev0 WITH or_crev0+l_anAmount(1), ;
			or_crev1 WITH or_crev1+l_anAmount(2), ;
			or_crev2 WITH or_crev2+l_anAmount(3), ;
			or_crev3 WITH or_crev3+l_anAmount(4), ;
			or_crev4 WITH or_crev4+l_anAmount(5), ;
			or_crev5 WITH or_crev5+l_anAmount(6), ;
			or_crev6 WITH or_crev6+l_anAmount(7), ;
			or_crev7 WITH or_crev7+l_anAmount(8), ;
			or_crev8 WITH or_crev8+l_anAmount(9), ;
			or_crev9 WITH or_crev9+l_anAmount(10), ;
			or_crevx WITH or_crevx+l_anAmount(11), ;
			or_cvat0 WITH or_cvat0+l_anVat(1), ;
			or_cvat1 WITH or_cvat1+l_anVat(2), ;
			or_cvat2 WITH or_cvat2+l_anVat(3), ;
			or_cvat3 WITH or_cvat3+l_anVat(4), ;
			or_cvat4 WITH or_cvat4+l_anVat(5), ;
			or_cvat5 WITH or_cvat5+l_anVat(6), ;
			or_cvat6 WITH or_cvat6+l_anVat(7), ;
			or_cvat7 WITH or_cvat7+l_anVat(8), ;
			or_cvat8 WITH or_cvat8+l_anVat(9), ;
			or_cvat9 WITH or_cvat9+l_anVat(10), ;
			or_cvatx WITH or_cvatx+l_anVat(11)
 ENDSCAN
 IF LOWER(l_cOrder) <> "tag1"
 	SET ORDER TO l_cOrder
 ENDIF
 SELECT (l_nSelect)
ENDFUNC

PROCEDURE OrResUpd
LPARAMETERS lp_cAlias, lp_cLabel, lp_cResAlias
 LOCAL l_cCode, l_nSelect, l_cOrder, l_dDate, l_lGetResState, l_oResCurrent, l_oResNext, l_cResRooms, l_cResRate
 LOCAL l_nReserid, l_nRooms, l_cRatecode, l_cStatus, l_dArrDate, l_dDepDate, l_dStartDate, l_dEndDate, l_lSharing, l_lPeriodFilter
 LOCAL l_nRsRooms, l_cRsRatecode, l_nRsPax, l_cRsRoomtype, l_cRsRoomnum, l_nPersons, l_cRoomtype, l_cRoomnum

 l_lPeriodFilter = (VARTYPE(pdStartDate)="D" AND VARTYPE(pdEndDate)="D")
 l_nSelect = SELECT()
 SELECT (lp_cAlias)
 l_cOrder = ORDER()
 IF LOWER(l_cOrder) <> "tag1"
 	SET ORDER TO tag1
 ENDIF
 IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
 ENDIF
 IF lp_cResAlias = "reservat"
	l_cResRooms = "resrooms"
	l_cResRate = "resrate"
	l_nReserid = reservat.rs_reserid
	l_cStatus = reservat.rs_status
	l_dArrDate = reservat.rs_arrdate
	l_dDepDate = reservat.rs_depdate
	l_cRsRoomtype = reservat.rs_roomtyp
	l_cRsRoomnum = reservat.rs_roomnum
	l_nRsRooms = reservat.rs_rooms
	l_cRsRatecode = STRTRAN(STRTRAN(reservat.rs_ratecod,"*"),"!")
	l_nRsPax = reservat.rs_adults + reservat.rs_childs + reservat.rs_childs2 + reservat.rs_childs3
	DO CASE
		CASE lp_cLabel = "MARKET"
			l_cCode = reservat.rs_market
		CASE lp_cLabel = "SOURCE"
			l_cCode = reservat.rs_source
		CASE lp_cLabel = "COUNTRY"
			l_cCode = DbLookup("address", "tag1", reservat.rs_addrid, "ad_country", .T.)
		CASE lp_cLabel = "ROOMTYP"
		CASE lp_cLabel = "ROOMNUM"
		CASE lp_cLabel = "RATECOD"
		OTHERWISE
			RETURN
	ENDCASE
 ELSE
	l_cResRooms = "hresroom"
	l_cResRate = "hresrate"
	l_nReserid = histres.hr_reserid
	l_cStatus = histres.hr_status
	l_dArrDate = histres.hr_arrdate
	l_dDepDate = histres.hr_depdate
	l_cRsRoomtype = histres.hr_roomtyp
	l_cRsRoomnum = histres.hr_roomnum
	l_nRsRooms = histres.hr_rooms
	l_cRsRatecode = STRTRAN(STRTRAN(histres.hr_ratecod,"*"),"!")
	l_nRsPax = histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
	DO CASE
		CASE lp_cLabel = "MARKET"
			l_cCode = histres.hr_market
		CASE lp_cLabel = "SOURCE"
			l_cCode = histres.hr_source
		CASE lp_cLabel = "COUNTRY"
			l_cCode = histres.hr_country
		CASE lp_cLabel = "ROOMTYP"
		CASE lp_cLabel = "ROOMNUM"
		CASE lp_cLabel = "RATECOD"
		OTHERWISE
			RETURN
	ENDCASE
 ENDIF
 IF NOT INLIST(l_cStatus,"NS","CXL","LST","OPT","TEN")
	l_dStartDate = IIF(l_lPeriodFilter, MAX(l_dArrDate,pdStartDate), l_dArrDate)
	l_dEndDate = IIF(l_lPeriodFilter, MIN(l_dDepDate,pdEndDate), l_dDepDate)
	l_dDate = l_dStartDate
	DO WHILE l_dDate <= l_dEndDate
		l_lGetResState = (l_dDate = l_dStartDate) OR ISNULL(l_oResCurrent) OR ISNULL(l_oResNext) OR ;
			l_oResCurrent.ri_rroomid <> l_oResNext.ri_rroomid AND ;
			NOT BETWEEN(l_dDate, l_oResCurrent.ri_date, l_oResNext.ri_date-1)
		IF l_lGetResState
			RiGetRoom(l_nReserid, l_dDate, @l_oResCurrent, @l_oResNext, l_cResRooms)
			IF ISNULL(l_oResCurrent)
				l_lSharing = .F.
				l_cRoomtype = l_cRsRoomtype
				l_cRoomnum = l_cRsRoomnum
			ELSE
				l_lSharing = NOT EMPTY(l_oResCurrent.ri_shareid)
				l_cRoomtype = l_oResCurrent.ri_roomtyp
				l_cRoomnum = l_oResCurrent.ri_roomnum
			ENDIF
			l_nRooms = OrRooms(l_cRoomtype, l_nRsRooms, l_cRoomnum)
		ENDIF
		IF NOT DbLookup("roomtype","tag1",l_cRoomtype,"INLIST(rt_group,1,4) AND rt_vwsum")
			l_dDate = l_dDate + 1
			LOOP
		ENDIF
		IF NOT ISNULL(l_oResCurrent) AND NOT EMPTY(l_oResCurrent.ri_shareid)
			l_lSharing = (l_nReserId <> RiGetShareFirstReserId(l_oResCurrent.ri_shareid, l_dDate))
		ENDIF

		IF SEEK(STR(l_nReserid,12,3)+DTOS(l_dDate), l_cResRate, "tag2")
			l_cRatecode = LEFT(&l_cResRate..rr_ratecod,10)
			l_nPersons = &l_cResRate..rr_adults + &l_cResRate..rr_childs + &l_cResRate..rr_childs2 + &l_cResRate..rr_childs3
		ELSE
			l_cRatecode = l_cRsRatecode
			l_nPersons = l_nRsPax
		ENDIF

		DO CASE
			CASE lp_cLabel = "ROOMTYP"
				l_cCode = l_cRoomtype
			CASE lp_cLabel = "ROOMNUM"
				l_cCode = l_cRoomnum
			CASE lp_cLabel = "RATECOD"
				l_cCode = l_cRatecode
		ENDCASE

		IF NOT SEEK(PADR(lp_cLabel,10)+PADR(l_cCode,10)+DTOS(l_dDate), lp_cAlias, "tag1")
			OrInsert(lp_cAlias, lp_cLabel, l_cCode, l_dDate)
		ENDIF
		IF l_dDate = l_dArrDate
			IF NOT l_lSharing
				REPLACE or_0arrrms WITH MAX(0, or_0arrrms + l_nRooms*IIF(p_lAdd,1,-1))
			ENDIF
			REPLACE or_0arrpax WITH MAX(0, or_0arrpax + l_nPersons*IIF(p_lAdd,1,-1))
		ENDIF
		IF l_dDate = l_dDepDate
			IF NOT l_lSharing
				REPLACE or_0deprms WITH MAX(0, or_0deprms + l_nRooms*IIF(p_lAdd,1,-1))
			ENDIF
			REPLACE or_0deppax WITH MAX(0, or_0deppax + l_nPersons*IIF(p_lAdd,1,-1))
		ENDIF
		DO CASE
			CASE l_dArrDate = l_dDepDate
				IF NOT l_lSharing
					REPLACE or_0dayrms WITH MAX(0, or_0dayrms + l_nRooms*IIF(p_lAdd,1,-1))
				ENDIF
				REPLACE or_0daypax WITH MAX(0, or_0daypax + l_nPersons*IIF(p_lAdd,1,-1))
			CASE l_dDate < l_dDepDate
				IF NOT l_lSharing
					REPLACE or_0rms WITH MAX(0, or_0rms + l_nRooms*IIF(p_lAdd,1,-1))
				ENDIF
				REPLACE or_0pax WITH MAX(0, or_0pax + l_nPersons*IIF(p_lAdd,1,-1))
		ENDCASE
		SCAN REST FOR NOT l_lPeriodFilter OR BETWEEN(or_date, pdStartDate, pdEndDate) ;
				WHILE or_label = lp_cLabel AND or_code = l_cCode AND YEAR(or_date) = YEAR(l_dDate)
			IF l_dDate = l_dArrDate
				IF NOT l_lSharing
					REPLACE or_carrrms WITH MAX(0, or_carrrms + l_nRooms*IIF(p_lAdd,1,-1))
				ENDIF
				REPLACE or_carrpax WITH MAX(0, or_carrpax + l_nPersons*IIF(p_lAdd,1,-1))
			ENDIF
			IF l_dDate = l_dDepDate
				IF NOT l_lSharing
					REPLACE or_cdeprms WITH MAX(0, or_cdeprms + l_nRooms*IIF(p_lAdd,1,-1))
				ENDIF
				REPLACE or_cdeppax WITH MAX(0, or_cdeppax + l_nPersons*IIF(p_lAdd,1,-1))
			ENDIF
			DO CASE
				CASE l_dArrDate = l_dDepDate
					IF NOT l_lSharing
						REPLACE or_cdayrms WITH MAX(0, or_cdayrms + l_nRooms*IIF(p_lAdd,1,-1))
					ENDIF
					REPLACE or_cdaypax WITH MAX(0, or_cdaypax + l_nPersons*IIF(p_lAdd,1,-1))
				CASE l_dDate < l_dDepDate
					IF NOT l_lSharing
						REPLACE or_crms WITH MAX(0, or_crms + l_nRooms*IIF(p_lAdd,1,-1))
					ENDIF
					REPLACE or_cpax WITH MAX(0, or_cpax + l_nPersons*IIF(p_lAdd,1,-1))
			ENDCASE
		ENDSCAN
		l_dDate = l_dDate + 1
	ENDDO
 ENDIF
 IF LOWER(l_cOrder) <> "tag1"
 	SET ORDER TO l_cOrder
 ENDIF
 SELECT (l_nSelect)
ENDFUNC

FUNCTION OrPpCusorCreate
LPARAMETERS cthelabel, lp_lOnlyStandard, lp_cAlias
IF EMPTY(lp_cAlias)
	lp_cAlias = "PreProc"
ENDIF
CREATE CURSOR &lp_cAlias (pp_date D(8), pp_code C (10), pp_name C (10), pp_descr C (75), pp_rms N (6), pp_pax N (6),  ;
       pp_dayrms N (6), pp_daypax N (6), pp_arrrms N (6), pp_arrpax N (6), pp_deprms N (6),  ;
       pp_deppax N (6), pp_rev N (16, 2), pp_vat N (16, 6), pp_ycompare L(1), pp_rmspercent N (4,2), ;
       pp_avgrate B (8), pp_sumrate B (8))
IF INLIST(cthelabel,"ROOMTYP","ROOMNUM")
	IF lp_lOnlyStandard
		SELECT rt_roomtyp FROM RoomType WHERE INLIST(rt_group, 1, 4) INTO ARRAY art
	ELSE
		SELECT rt_roomtyp FROM RoomType WHERE INLIST(rt_group, 1, 2, 3, 4) INTO ARRAY art
	ENDIF
	IF _TALLY = 0
	     DIMENSION art[1]
	     art = ''
	ENDIF
	SELECT rt_roomtyp FROM RoomType WHERE rt_group = 4 INTO ARRAY artsuite
	IF _TALLY = 0
	     DIMENSION artsuite[1]
	     artsuite = ''
	ENDIF
ENDIF
DO CASE
     CASE INLIST(cthelabel,"MAINGROUP","SUBGROUP")
               SELECT picklist
               nplrec = RECNO()
               SCAN ALL FOR pl_label = cthelabel
                    INSERT INTO &lp_cAlias (pp_code, pp_descr) VALUES ;
                           (ALLTRIM(STR(picklist.pl_numcod)), ;
                           EVALUATE('PickList.pl_lang' + g_langnum))
               ENDSCAN
               GOTO nplrec
               INSERT INTO &lp_cAlias (pp_code, pp_descr) VALUES ('-1', '<Unknown>')
     CASE INLIST(cthelabel,"MARKET","SOURCE","COUNTRY")
               SELECT picklist
               nplrec = RECNO()
               SCAN ALL FOR pl_label = cthelabel
                    INSERT INTO &lp_cAlias (pp_code, pp_descr) VALUES ;
                           (picklist.pl_charcod, EVALUATE('PickList.pl_lang' + g_langnum))
               ENDSCAN
               GOTO nplrec
               INSERT INTO &lp_cAlias (pp_descr) VALUES ('<Unknown>')
     CASE cthelabel = "ROOMTYP"
               SELECT roomtype
               nrtrec = RECNO()
               SCAN ALL FOR ASCAN(art, rt_roomtyp) > 0
                    INSERT INTO &lp_cAlias (pp_code, pp_name, pp_descr) VALUES ;
                           (roomtype.rt_roomtyp, get_rt_roomtyp(roomtype.rt_roomtyp), EVALUATE('RoomType.rt_lang' + g_langnum))
               ENDSCAN
               GOTO nrtrec
               INSERT INTO &lp_cAlias (pp_descr) VALUES ('<Unknown>')
     CASE cthelabel = "ROOMNUM"
               SELECT room
               nrmrec = RECNO()
               SCAN ALL FOR ASCAN(art, rm_roomtyp) > 0
                    INSERT INTO &lp_cAlias (pp_code, pp_name, pp_descr) VALUES ;
                           (room.rm_roomnum, get_rm_rmname(room.rm_roomnum), EVALUATE('Room.rm_lang' + g_langnum))
               ENDSCAN
               GOTO nrmrec
               INSERT INTO &lp_cAlias (pp_descr) VALUES ('<Unknown>')
     CASE cthelabel = "RATECOD"
          cidx = filetemp()
          SELECT ratecode
          nrcord = ORDER()
          INDEX ON rc_ratecod TO (cidx) UNIQUE
               SELECT ratecode
               nrcrec = RECNO()
               SCAN ALL
                    INSERT INTO &lp_cAlias (pp_code, pp_descr) VALUES ;
                           (ratecode.rc_ratecod, EVALUATE('RateCode.rc_lang' + g_langnum))
               ENDSCAN
               GOTO nrcrec
               INSERT INTO &lp_cAlias (pp_descr) VALUES ('<Unknown>')
          SET ORDER TO nRCOrd
          = filedelete(cidx)
     CASE cthelabel = "AVGPRICEDAY"
          *
     CASE cthelabel = "AVGPRDAYYEAR"
		FOR l_nMonth = 1 TO 12
			INSERT INTO &lp_cAlias (pp_code, pp_name) VALUES (PADL(l_nMonth,2), MyCMonth(l_nMonth))
		ENDFOR
     CASE INLIST(cthelabel, "AVGPRICERANGE", "AVGPRRNGYEAR")
		SELECT LTRIM(STR(pv_low))+"-"+LTRIM(STR(pv_high)) AS pp_code ;
				FROM priceavg INTO CURSOR tblAvgPrRng
		SELECT(lp_cAlias)
		APPEND FROM DBF("tblAvgPrRng")
		INSERT INTO &lp_cAlias (pp_descr) VALUES (GetLangText("OR","TXT_OTHER_RANGE"))
		USE IN tblAvgPrRng
     CASE INLIST(cthelabel, "OCCUPANCY", "OCCYEAR")
          *
ENDCASE
ENDFUNC

FUNCTION OrGetStat
LPARAMETERS lp_cAlias, lp_cLabel, lp_cCode, lp_dDate, l_oOrstat
 SELECT(lp_cAlias)
 = SEEK(PADR(lp_cLabel,10)+PADR(lp_cCode,10)+DTOS(lp_dDate))
 IF (or_label=lp_cLabel) AND (or_code=lp_cCode) AND (YEAR(or_date)==YEAR(lp_dDate))
	SCATTER NAME l_oOrstat
 ELSE
	SCATTER NAME l_oOrstat BLANK
 ENDIF
 RETURN l_oOrstat && l_oOrstat is parameter and it is returned by reference too
ENDFUNC

FUNCTION OrGetMainGrStat
LPARAMETERS lp_nGroup, lp_dDate, lp_cAlias, lp_oStat
 LOCAL l_nArea, l_nRecNo, l_cRevGroupMacro, l_cVatGroupMacro, l_oOrStat
 l_nArea = SELECT()
 IF EMPTY(lp_cAlias)
	 OrPpCusorCreate("TEMPORARY", .F., "tblMainGroupStat")
	 SELECT tblMainGroupStat
	 APPEND BLANK
	 lp_cAlias = "tblMainGroupStat"
 ENDIF
 lp_nGroup = IIF(BETWEEN(lp_nGroup, 0, 9), lp_nGroup, 10)
 l_cRevGroupMacro = OrPpArMainGroups(lp_nGroup,lp_nGroup,"l_oHistors.or_crev")
 l_cVatGroupMacro = OrPpArMainGroups(lp_nGroup,lp_nGroup,"l_oHistors.or_cvat")
 SELECT curpicklist
 l_nRecNo = RECNO()
 SCAN ALL FOR pl_label = "MARKET"
	l_oOrStat = OrGetStat("curhistors","MARKET",curpicklist.pl_charcod,lp_dDate)
	OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	l_oOrStat = OrGetStat("curorstat","MARKET",curpicklist.pl_charcod,lp_dDate)
	OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	SELECT curpicklist
 ENDSCAN
 GO l_nRecNo
 l_oOrStat = OrGetStat("curhistors","MARKET","",lp_dDate)
 OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
 l_oOrStat = OrGetStat("curorstat","MARKET","",lp_dDate)
 OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
 SELECT curorstat
 SCATTER NAME lp_oStat BLANK
 IF BETWEEN(lp_nGroup, 0, 9)
	l_cRevGroupMacro = "lp_oStat.or_crev" + STR(lp_nGroup,1)
	l_cVatGroupMacro = "lp_oStat.or_cvat" + STR(lp_nGroup,1)
 ELSE
	l_cRevGroupMacro = "lp_oStat.or_crevx"
	l_cVatGroupMacro = "lp_oStat.or_cvatx"
 ENDIF
 SELECT(lp_cAlias)
 &l_cRevGroupMacro = pp_rev
 &l_cVatGroupMacro = pp_vat
 IF lp_cAlias = "tblMainGroupStat"
	USE IN tblMainGroupStat
 ENDIF
 SELECT(l_nArea)
 RETURN lp_oStat
ENDFUNC

FUNCTION OrPpAdd
LPARAMETERS l_oHistors, lp_cRevGroupMacro, lp_cVatGroupMacro, lp_cAlias
 IF EMPTY(lp_cAlias)
	lp_cAlias = "PreProc"
 ENDIF
 SELECT(lp_cAlias)
 REPLACE pp_rms WITH pp_rms+l_oHistors.or_crms, ;
		pp_pax WITH pp_pax+l_oHistors.or_cpax, ;
		pp_dayrms WITH pp_dayrms+l_oHistors.or_cdayrms, ;
		pp_daypax WITH pp_daypax+l_oHistors.or_cdaypax, ;
		pp_arrrms WITH pp_arrrms+l_oHistors.or_carrrms, ;
		pp_arrpax WITH pp_arrpax+l_oHistors.or_carrpax, ;
		pp_deprms WITH pp_deprms+l_oHistors.or_cdeprms, ;
		pp_deppax WITH pp_deppax+l_oHistors.or_cdeppax, ;
		pp_rev WITH pp_rev+(&lp_cRevGroupMacro), ;
		pp_vat WITH pp_vat+(&lp_cVatGroupMacro)
ENDFUNC

FUNCTION OrPpSub
LPARAMETERS l_oHistors, lp_cRevGroupMacro, lp_cVatGroupMacro, lp_cAlias
 IF EMPTY(lp_cAlias)
	lp_cAlias = "PreProc"
 ENDIF
 SELECT(lp_cAlias)
 REPLACE pp_rms WITH pp_rms-l_oHistors.or_crms, ;
		pp_pax WITH pp_pax-l_oHistors.or_cpax, ;
		pp_dayrms WITH pp_dayrms-l_oHistors.or_cdayrms, ;
		pp_daypax WITH pp_daypax-l_oHistors.or_cdaypax, ;
		pp_arrrms WITH pp_arrrms-l_oHistors.or_carrrms, ;
		pp_arrpax WITH pp_arrpax-l_oHistors.or_carrpax, ;
		pp_deprms WITH pp_deprms-l_oHistors.or_cdeprms, ;
		pp_deppax WITH pp_deppax-l_oHistors.or_cdeppax, ;
		pp_rev WITH pp_rev-(&lp_cRevGroupMacro), ;
		pp_vat WITH pp_vat-(&lp_cVatGroupMacro)
ENDFUNC

FUNCTION OrPpArMainGroups
LPARAMETERS lp_nArMainGrMin, lp_nArMainGrMax, lp_cField
 LOCAL l_cArMainGrMacro, l_nCount
 l_cArMainGrMacro = lp_cField + ;
		IIF(lp_nArMainGrMin==10,"x",STR(lp_nArMainGrMin,1))
 FOR l_nCount = lp_nArMainGrMin+1 TO lp_nArMainGrMax
	l_cArMainGrMacro = l_cArMainGrMacro + "+" + lp_cField + ;
			IIF(l_nCount==10,"x",STR(l_nCount,1))
 ENDFOR
 RETURN l_cArMainGrMacro
ENDFUNC

FUNCTION OrPpRequery
LPARAMETERS cthelabel, lp_dMin, lp_dMax, lp_nArMainGrMin, lp_nArMainGrMax, lp_cAlias
IF EMPTY(lp_cAlias)
	lp_cAlias = "PreProc"
ENDIF
*!*     IF INLIST(cthelabel, "AVGPRICEDAY", "AVGPRDAYYEAR", "AVGPRICERANGE", "AVGPRRNGYEAR")
*!*     	DO RrRebuild IN ProcResrate
*!*     ENDIF
DO CASE
CASE cthelabel = "MAINGROUP"
	OrPpArMainRequery(cthelabel, lp_dMin, lp_dMax, lp_cAlias)
CASE cthelabel = "SUBGROUP"
	OrPpArSubRequery(cthelabel, lp_dMin, lp_dMax, lp_cAlias)
CASE cthelabel = "AVGPRICEDAY"
	OrPpAvgPriceRequery(lp_dMin, lp_dMax, lp_cAlias)
CASE cthelabel = "AVGPRDAYYEAR"
	OrPpAvgPriceYearRequery(lp_dMin, lp_dMax, lp_cAlias)
CASE INLIST(cthelabel, "AVGPRICERANGE", "AVGPRRNGYEAR")
	OrPpAvgPrRangeRequery(lp_dMin, lp_dMax, lp_cAlias)
CASE cthelabel = "OCCUPANCY"
	OrPpOccRequery(lp_dMin, lp_dMax, lp_cAlias)
CASE cthelabel = "OCCYEAR"
	OrPpOccYearRequery(YEAR(lp_dMin), lp_cAlias)
OTHERWISE
 LOCAL l_oOrStat, l_cRevGroupMacro, l_cVatGroupMacro
 l_cRevGroupMacro = OrPpArMainGroups(lp_nArMainGrMin,lp_nArMainGrMax,"l_oHistors.or_crev")
 l_cVatGroupMacro = OrPpArMainGroups(lp_nArMainGrMin,lp_nArMainGrMax,"l_oHistors.or_cvat")
SELECT orstat
SET ORDER TO tag1 DESCENDING
SELECT histors
SET ORDER TO tag1 DESCENDING
SELECT(lp_cAlias)
SET NEAR ON
SCAN
	l_oOrStat = OrGetStat("histors",cthelabel,pp_code,lp_dMax)
	OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	l_oOrStat = OrGetStat("orstat",cthelabel,pp_code,lp_dMax)
	OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	IF YEAR(lp_dMax) > YEAR(lp_dMin)
		LOCAL l_dEndDay, l_cYear
		FOR l_nCount = YEAR(lp_dMin) TO YEAR(lp_dMax)-1
			l_cYear = ALLTRIM(STR(l_nCount))
			l_dEndDay = {^&l_cYear-12-31}
			l_oOrStat = OrGetStat("histors",cthelabel,pp_code,l_dEndDay)
			OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
			l_oOrStat = OrGetStat("orstat",cthelabel,pp_code,l_dEndDay)
			OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
		ENDFOR
	ENDIF
	IF YEAR(lp_dMin) > YEAR(lp_dMin-1)
		LOOP
	ENDIF
	l_oOrStat = OrGetStat("histors",cthelabel,pp_code,lp_dMin-1)
	OrPpSub(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	l_oOrStat = OrGetStat("orstat",cthelabel,pp_code,lp_dMin-1)
	OrPpSub(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
ENDSCAN
SET NEAR OFF
ENDCASE
ENDFUNC
*
FUNCTION OrPpArMainRequery
LPARAMETERS cthelabel, lp_dMin, lp_dMax, lp_cAlias
LOCAL l_nRecNoPickList, l_nGroup, l_oOrStat, l_cRevGroupMacro, l_cVatGroupMacro
IF EMPTY(lp_cAlias)
	lp_cAlias = "PreProc"
ENDIF
l_nRecNoPickList = RECNO("picklist")
SELECT orstat
SET ORDER TO tag1 DESCENDING
SELECT histors
SET ORDER TO tag1 DESCENDING
SELECT(lp_cAlias)
SET NEAR ON
SCAN
	l_nGroup = VAL(pp_code)
	l_nGroup = IIF(l_nGroup == -1, 10, l_nGroup)
	l_cRevGroupMacro = OrPpArMainGroups(l_nGroup,l_nGroup,"l_oHistors.or_crev")
	l_cVatGroupMacro = OrPpArMainGroups(l_nGroup,l_nGroup,"l_oHistors.or_cvat")
	SELECT picklist
	SCAN ALL FOR pl_label = "MARKET"
		l_oOrStat = OrGetStat("histors","MARKET",picklist.pl_charcod,lp_dMax)
		OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
		l_oOrStat = OrGetStat("orstat","MARKET",picklist.pl_charcod,lp_dMax)
		OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
		SELECT picklist
	ENDSCAN
	l_oOrStat = OrGetStat("histors","MARKET","",lp_dMax)
	OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	l_oOrStat = OrGetStat("orstat","MARKET","",lp_dMax)
	OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	IF YEAR(lp_dMax) > YEAR(lp_dMin)
		LOCAL l_dEndDay, l_cYear
		FOR l_nCount = YEAR(lp_dMin) TO YEAR(lp_dMax)-1
			l_cYear = ALLTRIM(STR(l_nCount))
			l_dEndDay = {^&l_cYear-12-31}
			SELECT picklist
			SCAN ALL FOR pl_label = "MARKET"
				l_oOrStat = OrGetStat("histors","MARKET",picklist.pl_charcod,l_dEndDay)
				OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
				l_oOrStat = OrGetStat("orstat","MARKET",picklist.pl_charcod,l_dEndDay)
				OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
				SELECT picklist
			ENDSCAN
			l_oOrStat = OrGetStat("histors","MARKET","",l_dEndDay)
			OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
			l_oOrStat = OrGetStat("orstat","MARKET","",l_dEndDay)
			OrPpAdd(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
		ENDFOR
	ENDIF
	IF YEAR(lp_dMin) > YEAR(lp_dMin-1)
		LOOP
	ENDIF
	SELECT picklist
	SCAN ALL FOR pl_label = "MARKET"
		l_oOrStat = OrGetStat("histors","MARKET",picklist.pl_charcod,lp_dMin-1)
		OrPpSub(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
		l_oOrStat = OrGetStat("orstat","MARKET",picklist.pl_charcod,lp_dMin-1)
		OrPpSub(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
		SELECT picklist
	ENDSCAN
	l_oOrStat = OrGetStat("histors","MARKET","",lp_dMin-1)
	OrPpSub(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
	l_oOrStat = OrGetStat("orstat","MARKET","",lp_dMin-1)
	OrPpSub(l_oOrStat,l_cRevGroupMacro,l_cVatGroupMacro, lp_cAlias)
ENDSCAN
SET NEAR OFF
GO l_nRecNoPickList IN picklist
ENDFUNC
*
FUNCTION OrPpArSubRequery
LPARAMETERS cthelabel, lp_dMin, lp_dMax, lp_cAlias
 SELECT SUM(hp_amount), ;
		SUM(hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9) AS sum_hp_vat, ;
		ar_sub ;
		FROM histpost ;
		LEFT JOIN article ON hp_artinum = ar_artinum ;
		WHERE BETWEEN(hp_date,lp_dMin,lp_dMax) AND ;
			NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
		GROUP BY ar_sub ;
		INTO CURSOR tblPreProc
			*AND (INLIST(ar_artityp,1,3) OR ISNULL(ar_artityp))
 INDEX ON ar_sub TAG ar_sub
 SELECT(lp_cAlias)
 SCAN
	IF SEEK(pp_code,"tblPreProc","ar_sub")
		REPLACE pp_rev WITH tblPreProc.sum_hp_amount, ;
				pp_vat WITH tblPreProc.sum_hp_vat
	ENDIF
 ENDSCAN
ENDFUNC
*
FUNCTION OrPpAvgPriceRequery
LPARAMETERS lp_dMin, lp_dMax, lp_cAlias
 LOCAL l_nArea, l_nDay
 FOR l_nDay = 0 TO (lp_dMax - lp_dMin)
	INSERT INTO (lp_cAlias) (pp_code, pp_date) VALUES (STR(l_nDay + 1), lp_dMin + l_nDay)
 ENDFOR
 l_nArea = SELECT()
 SELECT rr_date AS pp_date, SUM((rr_raterc*rr_ratcoef*rr_curcoef + rr_ratepg + rr_rateex*rr_curcoef + rr_raterd)*hr_rooms) AS pp_sumrate, SUM(hr_rooms) AS pp_rms FROM hresrate, histres ;
	LEFT JOIN roomtype ON rt_roomtyp = hr_roomtyp ;
	WHERE BETWEEN(rr_date, lp_dMin, lp_dMax) AND (hr_reserid = rr_reserid) AND NOT EMPTY(hr_roomtyp) AND INLIST(rt_group, 1, 4) ;
	GROUP BY rr_date ORDER BY pp_date INTO CURSOR curResRate
 SELECT curResRate
 SCAN
	SELECT(lp_cAlias)
	LOCATE FOR pp_date = curResRate.pp_date
	REPLACE pp_rms WITH curResRate.pp_rms, ;
			pp_sumrate WITH curResRate.pp_sumrate, ;
			pp_avgrate WITH curResRate.pp_sumrate / curResRate.pp_rms IN (lp_cAlias)
	SELECT curResRate
 ENDSCAN
 SELECT rr_date AS pp_date, SUM((rr_raterc*rr_ratcoef*rr_curcoef + rr_ratepg + rr_rateex*rr_curcoef + rr_raterd)*rs_rooms) AS pp_sumrate, SUM(rs_rooms) AS pp_rms FROM resrate, reservat ;
	LEFT JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
	WHERE BETWEEN(rr_date, lp_dMin, lp_dMax) AND (rs_reserid = rr_reserid) AND NOT EMPTY(rs_roomtyp) AND INLIST(rt_group, 1, 4) ;
	GROUP BY rr_date ORDER BY pp_date INTO CURSOR curResRate
 SELECT curResRate
 SCAN
	SELECT(lp_cAlias)
	LOCATE FOR pp_date = curResRate.pp_date
	REPLACE pp_rms WITH pp_rms + curResRate.pp_rms, ;
			pp_sumrate WITH pp_sumrate + curResRate.pp_sumrate, ;
			pp_avgrate WITH pp_avgrate + curResRate.pp_sumrate / curResRate.pp_rms IN (lp_cAlias)
	SELECT curResRate
 ENDSCAN
 USE IN curResRate
 SELECT(l_nArea)
ENDFUNC
*
FUNCTION OrPpAvgPriceYearRequery
LPARAMETERS lp_dMin, lp_dMax, lp_cAlias
 LOCAL l_nArea, l_nRate, l_nSumRate, l_nRooms, l_nAvgRate
 l_nArea = SELECT()
 OrPpCusorCreate("AVGPRICEDAY", .F., "ppAvgPriceYear")
 OrPpAvgPriceRequery(lp_dMin, lp_dMax, "ppAvgPriceYear")
 SELECT ppAvgPriceYear
 SCAN
	SELECT(lp_cAlias)
	LOCATE FOR pp_code = PADL(MONTH(ppAvgPriceYear.pp_date),2)
	IF FOUND()
		l_nRooms = &lp_cAlias..pp_rms + ppAvgPriceYear.pp_rms
		l_nSumRate = &lp_cAlias..pp_sumrate + ppAvgPriceYear.pp_sumrate
		l_nAvgRate = IIF(EMPTY(l_nRooms), 0, l_nSumRate / l_nRooms)
		REPLACE pp_rms WITH l_nRooms, pp_sumrate WITH l_nSumRate, ;
				pp_avgrate WITH l_nAvgRate IN (lp_cAlias)
	ENDIF
	SELECT ppAvgPriceYear
 ENDSCAN
 SELECT(l_nArea)
ENDFUNC
*
FUNCTION OrPpAvgPrRangeRequery
LPARAMETERS lp_dMin, lp_dMax, lp_cAlias
 LOCAL l_nArea, l_nRate, l_nSumRooms
 l_nArea = SELECT()
 SET RELATION TO rr_reserid INTO histres IN hresrate ADDITIVE
 SET RELATION TO hr_roomtyp INTO roomtype IN histres ADDITIVE
 SELECT hresrate
 SCAN FOR BETWEEN(rr_date, lp_dMin, lp_dMax) AND NOT EMPTY(histres.hr_roomtyp) AND INLIST(roomtype.rt_group, 1, 4)
	l_nRate = hresrate.rr_raterc*hresrate.rr_ratcoef*hresrate.rr_curcoef + hresrate.rr_ratepg + hresrate.rr_rateex*hresrate.rr_curcoef + hresrate.rr_raterd
	SELECT priceavg
	LOCATE FOR (pv_low <= l_nRate) AND (pv_high > l_nRate)
	IF FOUND("priceavg")
		SELECT &lp_cAlias
		LOCATE FOR pp_code = LTRIM(STR(priceavg.pv_low))+"-"+LTRIM(STR(priceavg.pv_high))
	ELSE
		GO BOTTOM IN &lp_cAlias
	ENDIF
	REPLACE pp_rms WITH &lp_cAlias..pp_rms + histres.hr_rooms ;
			pp_sumrate WITH &lp_cAlias..pp_sumrate + l_nRate * histres.hr_rooms IN &lp_cAlias
	SELECT hresrate
 ENDSCAN
 SET RELATION OFF INTO histres IN hresrate
 SET RELATION OFF INTO roomtype IN histres
 SET RELATION TO rr_reserid INTO reservat IN resrate ADDITIVE
 SET RELATION TO rs_roomtyp INTO roomtype IN reservat ADDITIVE
 SELECT resrate
 SCAN FOR BETWEEN(rr_date, lp_dMin, lp_dMax) AND NOT EMPTY(reservat.rs_roomtyp) AND INLIST(roomtype.rt_group, 1, 4)
	l_nRate = resrate.rr_raterc*resrate.rr_ratcoef*resrate.rr_curcoef + resrate.rr_ratepg + resrate.rr_rateex*resrate.rr_curcoef + resrate.rr_raterd
	SELECT priceavg
	LOCATE FOR (pv_low <= l_nRate) AND (pv_high > l_nRate)
	IF FOUND("priceavg")
		SELECT &lp_cAlias
		LOCATE FOR pp_code = LTRIM(STR(priceavg.pv_low))+"-"+LTRIM(STR(priceavg.pv_high))
	ELSE
		GO BOTTOM IN &lp_cAlias
	ENDIF
	REPLACE pp_rms WITH &lp_cAlias..pp_rms + reservat.rs_rooms ;
			pp_sumrate WITH &lp_cAlias..pp_sumrate + l_nRate * reservat.rs_rooms IN &lp_cAlias
	SELECT resrate
 ENDSCAN
 SET RELATION OFF INTO reservat IN resrate
 SET RELATION OFF INTO roomtype IN reservat
 SELECT &lp_cAlias
 SUM pp_rms TO l_nSumRooms
 REPLACE pp_avgrate WITH IIF(EMPTY(&lp_cAlias..pp_rms), 0, &lp_cAlias..pp_sumrate / &lp_cAlias..pp_rms) ;
		 pp_rmspercent WITH IIF(EMPTY(l_nSumRooms), 0, &lp_cAlias..pp_rms / l_nSumRooms * 100) ALL IN &lp_cAlias
 SELECT(l_nArea)
ENDFUNC
*
FUNCTION OrPpOccRequery
LPARAMETERS lp_dMin, lp_dMax, lp_cAlias
 LOCAL l_nDay, l_nRoomsOcc, l_nOccPercent
 FOR l_nDay = 0 TO (lp_dMax - lp_dMin)
	IF SEEK(DTOS(lp_dMin + l_nDay), "manager", "tag1")
		l_nRoomsOcc = manager.mg_roomocc
		l_nOccPercent = manager.mg_roomocc / (manager.mg_roomavl - manager.mg_roomooo - manager.mg_roomoos) * 100
	ELSE
		SELECT SUM(av_avail) AS av_avail, SUM(av_definit) AS av_definit, ;
				SUM(av_allott) AS av_allott, SUM(av_pick) AS av_pick ;
				FROM availab ;
				WHERE av_date = lp_dMin + l_nDay ;
				INTO CURSOR tblPpOccReq
		l_nRoomsOcc = tblPpOccReq.av_definit + IIF(param.pa_allodef, tblPpOccReq.av_allott - tblPpOccReq.av_pick, 0)
		l_nOccPercent = IIF(EMPTY(tblPpOccReq.av_avail), 0, l_nRoomsOcc / tblPpOccReq.av_avail * 100)
	ENDIF
	INSERT INTO (lp_cAlias) (pp_code, pp_date, pp_rms, pp_rmspercent) ;
			VALUES (STR(l_nDay + 1), lp_dMin + l_nDay, l_nRoomsOcc, l_nOccPercent)
 ENDFOR
ENDFUNC
*
FUNCTION OrPpOccYearRequery
LPARAMETERS lp_nYear, lp_cAlias
 LOCAL l_nMonth, l_dMin, l_dMax, l_dMiddle, l_nPercent, l_nAvl, l_nOcc
 FOR l_nMonth = 1 TO 12
	l_dMin = DATE(lp_nYear, l_nMonth, 1)
	l_dMax = DATE(lp_nYear, l_nMonth, LastDay(DATE(lp_nYear, l_nMonth, 27)))
	DO CASE
	 CASE BETWEEN(SysDate(), l_dMin, l_dMax)
		l_dMiddle = SysDate()
	 CASE SysDate() < l_dMin
		l_dMiddle = l_dMin
	 CASE SysDate() > l_dMax
		l_dMiddle = l_dMax
	ENDCASE
	IF l_dMin <> l_dMiddle
		SELECT SUM(mg_roomocc) AS mg_roomocc, SUM(mg_roomavl) AS mg_roomavl, ;
				SUM(mg_roomooo) AS mg_roomooo, SUM(mg_roomoos) AS mg_roomoos ;
				FROM manager ;
				WHERE (DTOS(mg_date) >= DTOS(l_dMin)) AND (DTOS(mg_date) < DTOS(l_dMiddle)) ;
				INTO CURSOR tblPpOccYearReq
		l_nAvl = tblPpOccYearReq.mg_roomavl - tblPpOccYearReq.mg_roomooo - tblPpOccYearReq.mg_roomoos
		l_nOcc = tblPpOccYearReq.mg_roomocc
	ELSE
		l_nAvl = 0
		l_nOcc = 0
	ENDIF
	IF l_dMiddle <> l_dMax
		SELECT SUM(av_avail) AS av_avail, SUM(av_definit) AS av_definit, ;
				SUM(av_allott) AS av_allott, SUM(av_pick) AS av_pick ;
				FROM availab ;
				WHERE av_date >= l_dMiddle AND av_date < l_dMax ;
				INTO CURSOR tblPpOccYearReq
		l_nAvl = l_nAvl + tblPpOccYearReq.av_avail
		l_nOcc = l_nOcc + tblPpOccYearReq.av_definit + IIF(param.pa_allodef, tblPpOccYearReq.av_allott - tblPpOccYearReq.av_pick, 0)
	ENDIF
	l_nPercent = IIF(EMPTY(l_nAvl), 0, l_nOcc / l_nAvl * 100)
	INSERT INTO (lp_cAlias) (pp_code, pp_name, pp_rmspercent) ;
			VALUES (PADL(l_nMonth,2), MyCMonth(l_nMonth), l_nPercent)
 ENDFOR
ENDFUNC
*
* Function OrPpNewRequery is created for test purposes.
* It tests speed of getting same results as in previous OrPpRequery function 
* but without cumulative fields (or_crms, or_cpax, or_crevx, or_cvatx, ...)
FUNCTION OrPpNewRequery
LPARAMETERS lp_cLabel, lp_dMin, lp_dMax, lp_nArMainGrMin, lp_nArMainGrMax
 l_time1=DATETIME()
 LOCAL l_cRevMacro, l_cVatMacro, l_nCount, l_cIndex
 SELECT or_code, ;
		SUM(or_0rms), SUM(or_0pax), SUM(or_0dayrms), SUM(or_0daypax), ;
		SUM(or_0arrrms), SUM(or_0arrpax), SUM(or_0deprms), SUM(or_0deppax), ;
		SUM(or_0rev0), SUM(or_0rev1), SUM(or_0rev2), SUM(or_0rev3), ;
		SUM(or_0rev4), SUM(or_0rev5), SUM(or_0rev6), SUM(or_0rev7), ;
		SUM(or_0rev8), SUM(or_0rev9), SUM(or_0revx), ;
		SUM(or_0vat0), SUM(or_0vat1), SUM(or_0vat2), SUM(or_0vat3), ;
		SUM(or_0vat4), SUM(or_0vat5), SUM(or_0vat6), SUM(or_0vat7), ;
		SUM(or_0vat8), SUM(or_0vat9), SUM(or_0vatx) ;
	FROM orstat ;
	WHERE or_label=lp_cLabel AND BETWEEN(or_date, lp_dMin, lp_dMax) ;
	GROUP BY or_code ;
  UNION ;
  SELECT or_code, ;
		SUM(or_0rms), SUM(or_0pax), SUM(or_0dayrms), SUM(or_0daypax), ;
		SUM(or_0arrrms), SUM(or_0arrpax), SUM(or_0deprms), SUM(or_0deppax), ;
		SUM(or_0rev0), SUM(or_0rev1), SUM(or_0rev2), SUM(or_0rev3), ;
		SUM(or_0rev4), SUM(or_0rev5), SUM(or_0rev6), SUM(or_0rev7), ;
		SUM(or_0rev8), SUM(or_0rev9), SUM(or_0revx), ;
		SUM(or_0vat0), SUM(or_0vat1), SUM(or_0vat2), SUM(or_0vat3), ;
		SUM(or_0vat4), SUM(or_0vat5), SUM(or_0vat6), SUM(or_0vat7), ;
		SUM(or_0vat8), SUM(or_0vat9), SUM(or_0vatx) ;
	FROM histors ;
	WHERE or_label=lp_cLabel AND BETWEEN(or_date, lp_dMin, lp_dMax) ;
	GROUP BY or_code ;
  INTO CURSOR tblORStat
 l_cIndex = IIF(lp_nArMainGrMin==10, "x", ALLTRIM(STR(lp_nArMainGrMin)))
 l_cRevMacro = "SUM(sum_or_0rev" + l_cIndex + ")"
 l_cVatMacro = "SUM(sum_or_0vat" + l_cIndex + ")"
 FOR l_nCount = lp_nArMainGrMin+1 TO lp_nArMainGrMax
	l_cIndex = IIF(l_nCount==10, "x", ALLTRIM(STR(l_nCount)))
	l_cRevMacro = l_cRevMacro + "+SUM(sum_or_0rev" + l_cIndex + ")"
	l_cVatMacro = l_cVatMacro + "+SUM(sum_or_0vat" + l_cIndex + ")"
 ENDFOR
 l_cRevMacro = l_cRevMacro + " AS pp_rev"
 l_cVatMacro = l_cVatMacro + " AS pp_vat"
 SELECT or_code, ;
		SUM(sum_or_0rms) AS pp_rms, SUM(sum_or_0pax) AS pp_pax, ;
		SUM(sum_or_0dayrms) AS pp_dayrms, SUM(sum_or_0daypax) AS pp_daypax, ;
		SUM(sum_or_0arrrms) AS pp_arrrms, SUM(sum_or_0arrpax) AS pp_arrpax, ;
		SUM(sum_or_0deprms) AS pp_deprms, SUM(sum_or_0deppax) AS pp_deppax, ;
		&l_cRevMacro, &l_cVatMacro ;
	FROM tblORStat ;
	GROUP BY or_code ;
	ORDER BY or_code ;
	INTO CURSOR npreproc
 USE IN tblORStat
 l_time2=DATETIME()
 = MESSAGEBOX("Finished in "+ALLTRIM(STR(l_time2-l_time1))+" seconds!", 64, "Information")
ENDFUNC
* Procedure OrInitiate is created for test purposes.
* It is trying of getting result direct from HistPost and HistRes 
* instead of use of HistOrS and OrStat.
PROCEDURE OrInitiate
 LPARAMETERS lp_dMinDate, lp_dMaxDate, lp_nMinArMain, lp_nMaxArMain, lp_lAllRoomTypes
 LOCAL l_cLang, l_cArLang
 l_cLang = "pl_lang" + g_langnum
 SELECT pl_charcod, &l_cLang FROM picklist WHERE pl_label = "MARKET    " INTO CURSOR tblMarket READWRITE
 SELECT tblMarket
 INDEX ON pl_charcod TAG tag1
 SELECT pl_charcod, &l_cLang FROM picklist WHERE pl_label = "SOURCE    " INTO CURSOR tblSource READWRITE
 SELECT tblSource
 INDEX ON pl_charcod TAG tag1
 SELECT pl_charcod, &l_cLang FROM picklist WHERE pl_label = "COUNTRY   " INTO CURSOR tblCountry READWRITE
 SELECT tblCountry
 INDEX ON pl_charcod TAG tag1
 l_cArLang = "ar_lang" + g_langnum
 SELECT SUM(hp_amount), SUM(hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9), ;
		ar_main, IIF(ISNULL(&l_cArLang),"<Unknown>",&l_cArLang) AS ar_lang, ;
		hr_reserid, ;
		rt_roomtyp, ;
		pl_charcod, IIF(ISNULL(&l_cLang),"<Unknown>",&l_cLang) AS pl_lang ;
		FROM histpost ;
		LEFT JOIN article ON hp_artinum = ar_artinum ;
		LEFT JOIN histres ON hp_origid = hr_reserid ;
		LEFT JOIN roomtype ON hr_roomtyp = rt_roomtyp ;
		LEFT JOIN tblMarket ON hr_market = pl_charcod ;
		WHERE BETWEEN(hp_date,lp_dMinDate,lp_dMaxDate) AND ;
			NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND ;
			(INLIST(ar_artityp,1,3) OR ISNULL(ar_artityp)) AND ;
			(BETWEEN(ar_main,lp_nMinArMain,lp_nMaxArMain) OR ISNULL(ar_main)) AND ;
			IIF(lp_lAllRoomTypes,.T.,INLIST(rt_group, 1, 4)) ;
		GROUP BY pl_charcod, ar_main ;
		INTO CURSOR tblORStat
ENDPROC

FUNCTION OrTabDelLineCreate
LPARAMETERS lp_nLegendCode, lp_cAlias, lp_nYear, lp_lZero, ;
	lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7, lp_cLabel
 LOCAL l_cTabDelLine, l_cData, l_cYear
 IF EMPTY(lp_cLabel)
 	lp_cLabel = ""
 ENDIF
 l_cYear = IIF(EMPTY(lp_nYear), "", " "+ALLTRIM(STR(lp_nYear)))
 DO CASE
  CASE lp_nLegendCode = 1
	l_cData = GetLangText("ORUPD","TXT_RMS") + l_cYear
  CASE lp_nLegendCode = 2
	l_cData = GetLangText("ORUPD","TXT_PAX") + l_cYear
  CASE lp_nLegendCode = 3
	l_cData = GetLangText("ORUPD","TXT_DAY_RMS") + l_cYear
  CASE lp_nLegendCode = 4
	l_cData = GetLangText("ORUPD","TXT_DAY_PAX") + l_cYear
  CASE lp_nLegendCode = 5
	l_cData = GetLangText("ORUPD","TXT_ARR_RMS") + l_cYear
  CASE lp_nLegendCode = 6
	l_cData = GetLangText("ORUPD","TXT_ARR_PAX") + l_cYear
  CASE lp_nLegendCode = 7
	l_cData = GetLangText("ORUPD","TXT_DEP_RMS") + l_cYear
  CASE lp_nLegendCode = 8
	l_cData = GetLangText("ORUPD","TXT_DEP_PAX") + l_cYear
  CASE lp_nLegendCode = 9
	l_cData = GetLangText("ORUPD","TXT_REV_BRUTO") + l_cYear
  CASE lp_nLegendCode = 10
	l_cData = GetLangText("ORUPD","TXT_VAT") + l_cYear
  CASE lp_nLegendCode = 11
	l_cData = GetLangText("ORUPD","TXT_REV_NETO") + l_cYear
  CASE INLIST(lp_nLegendCode, 100, 200)
	l_cData = l_cYear
  CASE BETWEEN(lp_nLegendCode, 101, 112) OR ;
		BETWEEN(lp_nLegendCode, 201, 212)
	l_cData = MyCMonth(lp_nLegendCode - IIF(lp_nLegendCode > 200, 200, 100)) + l_cYear
  OTHERWISE
	l_cData = " "
 ENDCASE
 l_cTabDelLine = l_cData
 SELECT(lp_cAlias)
 SCAN FOR lp_lZero OR pp_ycompare OR ;
		((pp_rms<>0 OR pp_pax<>0) AND lp_lChk1) OR ;
		((pp_dayrms<>0 OR pp_daypax<>0) AND lp_lChk2) OR ;
		((pp_arrrms<>0 OR pp_arrpax<>0) AND lp_lChk3) OR ;
		((pp_deprms<>0 OR pp_deppax<>0) AND lp_lChk4) OR ;
		(pp_rev<>0 AND (lp_lChk5 OR lp_lChk7)) OR ;
		(pp_vat<>0 AND lp_lChk6)
	DO CASE
	 CASE lp_nLegendCode = 1
		l_cData = ALLTRIM(STR(pp_rms))
	 CASE lp_nLegendCode = 2
		l_cData = ALLTRIM(STR(pp_pax))
	 CASE lp_nLegendCode = 3
		l_cData = ALLTRIM(STR(pp_dayrms))
	 CASE lp_nLegendCode = 4
		l_cData = ALLTRIM(STR(pp_daypax))
	 CASE lp_nLegendCode = 5
		l_cData = ALLTRIM(STR(pp_arrrms))
	 CASE lp_nLegendCode = 6
		l_cData = ALLTRIM(STR(pp_arrpax))
	 CASE lp_nLegendCode = 7
		l_cData = ALLTRIM(STR(pp_deprms))
	 CASE lp_nLegendCode = 8
		l_cData = ALLTRIM(STR(pp_deppax))
	 CASE lp_nLegendCode = 9
		l_cData = ALLTRIM(STR(pp_rev))
	 CASE lp_nLegendCode = 10
		l_cData = ALLTRIM(STR(pp_vat))
	 CASE lp_nLegendCode = 11
		l_cData = ALLTRIM(STR(pp_rev-pp_vat))
	 CASE BETWEEN(lp_nLegendCode, 100, 112)
		l_cData = ALLTRIM(STR(pp_avgrate))
	 CASE BETWEEN(lp_nLegendCode, 200, 212)
		l_cData = ALLTRIM(STR(pp_rmspercent, 5, 2))
	 OTHERWISE
		IF INLIST(lp_cLabel, "ROOMTYP", "ROOMNUM")
			l_cData = pp_name
		ELSE
			l_cData = ALLTRIM(pp_code)
		ENDIF
	ENDCASE
	l_cTabDelLine = l_cTabDelLine + CHR(9) + l_cData
 ENDSCAN
 RETURN l_cTabDelLine
ENDFUNC

FUNCTION OrTabDelStrCreate
LPARAMETERS l_cTabDelStr, lp_cLabel, lp_dBegin, lp_dEnd, lp_lZeros, ;
	lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7, ;
	lp_nYearCompare, lp_nYearLast
 LOCAL l_nYear, l_dCompareBegin, l_dCompareEnd
 IF NOT EMPTY(lp_nYearCompare)
	l_nYear = YEAR(lp_dEnd)
 ELSE
	l_nYear = 0
 ENDIF
 IF EMPTY(lp_nYearCompare) OR EMPTY(lp_nYearLast)
	OrPpCusorCreate(lp_cLabel, .F.)
	OrPpRequery(lp_cLabel, lp_dBegin, lp_dEnd, 0, 10)
	SELECT preproc
	INDEX ON pp_code TAG pp_code
 ENDIF
 IF NOT EMPTY(lp_nYearCompare)
	IF NOT EMPTY(lp_nYearLast)
		FOR l_nYear = lp_nYearCompare TO IIF(lp_nYearCompare > lp_nYearLast, lp_nYearCompare, lp_nYearLast)
			IF EMPTY(lp_dBegin)
				l_dCompareBegin = DATE(l_nYear, 1, 1)
				l_dCompareEnd = DATE(l_nYear, 12, 31)
			ELSE
				l_dCompareBegin = DATE(l_nYear, MONTH(lp_dBegin), 1)
				l_dCompareEnd = DATE(l_nYear, MONTH(lp_dBegin), LastDay(l_dCompareBegin))
			ENDIF
			OrPpCusorCreate(lp_cLabel, .F., "pp" + ALLTRIM(STR(l_nYear)))
			OrPpRequery(lp_cLabel, l_dCompareBegin, l_dCompareEnd, 0, 10, "pp" + ALLTRIM(STR(l_nYear)))
			*SELECT("pp" + ALLTRIM(STR(l_nYear)))
			*INDEX ON pp_code TAG pp_code
		ENDFOR
		l_cTabDelStr = OrTabDelLineCreate(0, "pp" + ALLTRIM(STR(lp_nYearCompare)), lp_nYearCompare, .T.)
		l_nLegend = IIF(INLIST(lp_cLabel, "AVGPRICEDAY", "AVGPRDAYYEAR"), 100, 200)
		FOR l_nYear = lp_nYearCompare TO IIF(lp_nYearCompare > lp_nYearLast, lp_nYearCompare, lp_nYearLast)
			l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(l_nLegend + MONTH(lp_dBegin), "pp" + ALLTRIM(STR(l_nYear)), l_nYear, .T.)
		ENDFOR
		RETURN l_cTabDelStr
	ELSE
	l_dCompareBegin = EVALUATE("{^"+ALLTRIM(STR(lp_nYearCompare))+"-"+ALLTRIM(STR(MONTH(lp_dBegin)))+"-"+ALLTRIM(STR(DAY(lp_dBegin)))+"}")
	l_dCompareEnd = EVALUATE("{^"+ALLTRIM(STR(lp_nYearCompare))+"-"+ALLTRIM(STR(MONTH(lp_dEnd)))+"-"+ALLTRIM(STR(DAY(lp_dEnd)))+"}")
	OrPpCusorCreate(lp_cLabel, .F., "ypp")
	OrPpRequery(lp_cLabel, l_dCompareBegin, l_dCompareEnd, 0, 10, "ypp")
	SELECT ypp
	INDEX ON pp_code TAG pp_code
	OrCompareSync("preproc", "ypp", lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	OrCompareSync("ypp", "preproc", lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 l_cTabDelStr = OrTabDelLineCreate(0, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7, lp_cLabel)
 IF lp_lChk1
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(1, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(1, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(2, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(2, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 IF lp_lChk2
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(3, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(3, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(4, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(4, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 IF lp_lChk3
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(5, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(5, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(6, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(6, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 IF lp_lChk4
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(7, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(7, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(8, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(8, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 IF lp_lChk5
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(9, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(9, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 IF lp_lChk6
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(10, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(10, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 IF lp_lChk7
	l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(11, "preproc", l_nYear, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	IF NOT EMPTY(lp_nYearCompare)
		l_cTabDelStr = l_cTabDelStr + CHR(13)+CHR(10) + OrTabDelLineCreate(11, "ypp", lp_nYearCompare, lp_lZeros, lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7)
	ENDIF
 ENDIF
 RETURN l_cTabDelStr
ENDFUNC

FUNCTION OrCompareSync
LPARAMETERS lp_cAlias1, lp_cAlias2, lp_lZero, ;
	lp_lChk1, lp_lChk2, lp_lChk3, lp_lChk4, lp_lChk5, lp_lChk6, lp_lChk7
 LOCAL l_cOrder
 l_cOrder = ORDER(lp_cAlias1)
 SELECT(lp_cAlias1)
 SET ORDER TO
 SCAN
	IF NOT SEEK(&lp_cAlias1..pp_code,lp_cAlias2,"pp_code")
		INSERT INTO &lp_cAlias2 (pp_code, pp_name, pp_descr, pp_ycompare) VALUES ;
				(&lp_cAlias1..pp_code, &lp_cAlias1..pp_name, &lp_cAlias1..pp_descr, .T.)
	ENDIF
	IF (lp_lZero OR ;
			((&lp_cAlias1..pp_rms<>0 OR &lp_cAlias1..pp_pax<>0) AND lp_lChk1) OR ;
			((&lp_cAlias1..pp_dayrms<>0 OR &lp_cAlias1..pp_daypax<>0) AND lp_lChk2) OR ;
			((&lp_cAlias1..pp_arrrms<>0 OR &lp_cAlias1..pp_arrpax<>0) AND lp_lChk3) OR ;
			((&lp_cAlias1..pp_deprms<>0 OR &lp_cAlias1..pp_deppax<>0) AND lp_lChk4) OR ;
			(&lp_cAlias1..pp_rev<>0 AND (lp_lChk5 OR lp_lChk7)) OR ;
			(&lp_cAlias1..pp_vat<>0 AND lp_lChk6)) ;
			AND NOT ;
			(lp_lZero OR ;
			((&lp_cAlias2..pp_rms<>0 OR &lp_cAlias2..pp_pax<>0) AND lp_lChk1) OR ;
			((&lp_cAlias2..pp_dayrms<>0 OR &lp_cAlias2..pp_daypax<>0) AND lp_lChk2) OR ;
			((&lp_cAlias2..pp_arrrms<>0 OR &lp_cAlias2..pp_arrpax<>0) AND lp_lChk3) OR ;
			((&lp_cAlias2..pp_deprms<>0 OR &lp_cAlias2..pp_deppax<>0) AND lp_lChk4) OR ;
			(&lp_cAlias2..pp_rev<>0 AND (lp_lChk5 OR lp_lChk7)) OR ;
			(&lp_cAlias2..pp_vat<>0 AND lp_lChk6))
		REPLACE pp_ycompare WITH .T. IN &lp_cAlias2
	ENDIF
 ENDSCAN
 SET ORDER TO l_cOrder
ENDFUNC
*
PROCEDURE OccupancyStatRevUpdate
LPARAMETERS lp_dForDate
LOCAL i, l_oEnvironment, l_nLabel, l_oBefore, l_oAfter, l_nVatValue, l_cIndex, l_cField, l_oResroom
LOCAL ARRAY l_aLabels(6,2)
l_oEnvironment = SetEnvironment("orstat, histors, post, histpost, histres, hresroom, article")
l_aLabels(1,1) = "COUNTRY"
l_aLabels(1,2) = "hr_country"
l_aLabels(2,1) = "MARKET"
l_aLabels(2,2) = "hr_market"
l_aLabels(3,1) = "RATECOD"
l_aLabels(3,2) = "hr_ratecod"
l_aLabels(4,1) = "ROOMNUM"
l_aLabels(4,2) = "hr_roomnum"
l_aLabels(5,1) = "ROOMTYP"
l_aLabels(5,2) = "hr_roomtyp"
l_aLabels(6,1) = "SOURCE"
l_aLabels(6,2) = "hr_source"
IF NOT param.pa_audnost
	SELECT post.*, article.ar_main, histres.hr_market, histres.hr_source, histres.hr_country, ;
		histres.hr_roomtyp, histres.hr_roomnum, STRTRAN(STRTRAN(histres.hr_ratecod,"*"),"!") AS hr_ratecod FROM post ;
		LEFT JOIN article ON post.ps_artinum = article.ar_artinum ;
		LEFT JOIN histres ON INLIST(histres.hr_reserid, post.ps_reserid, post.ps_origid) ;
		WHERE ps_date = lp_dForDate AND NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) ;
		INTO CURSOR curPost READWRITE
	SELECT * FROM orstat WHERE or_date = lp_dForDate ORDER BY or_label, or_code INTO CURSOR curOrstat
	BLANK FIELDS LIKE or_0rev?, or_0vat? FOR or_date = lp_dForDate IN orstat
	SELECT curPost
	SCAN
		RiGetRoom(ps_reserid, lp_dForDate, @l_oResroom, .NULL., "hresroom")
		IF NOT ISNULL(l_oResroom)
			REPLACE hr_roomtyp WITH l_oResroom.ri_roomtyp, ;
					hr_roomnum WITH l_oResroom.ri_roomnum IN curPost
		ENDIF
		FOR l_nLabel = 1 TO ALEN(l_aLabels,1)
			IF SEEK(PADR(l_aLabels(l_nLabel,1),10)+PADR(IIF(ISNULL(EVALUATE("curPost."+l_aLabels(l_nLabel,2))), "", ;
					EVALUATE("curPost."+l_aLabels(l_nLabel,2))),10)+DTOS(lp_dForDate),"orstat","Tag1")
				l_cIndex = IIF(ISNULL(curPost.ar_main), "x", STR(MAX(curPost.ar_main,0),1))
				l_nVatValue = 0
				FOR i = 1 TO 9
					l_nVatValue = l_nVatValue + EVALUATE("curPost.ps_vat" + STR(i,1))
				NEXT
				l_cField = "or_0rev" + l_cIndex
				REPLACE &l_cField WITH orstat.&l_cField + curPost.ps_amount IN orstat
				l_cField = "or_0vat" + l_cIndex
				REPLACE &l_cField WITH orstat.&l_cField + l_nVatValue IN orstat
			ENDIF
		NEXT
	ENDSCAN
	USE IN curPost
	SET ORDER TO Tag1 IN orstat
	SELECT curOrstat
	SCAN
		SCATTER NAME l_oBefore
		= SEEK(PADR(l_oBefore.or_label,10)+PADR(l_oBefore.or_code,10)+DTOS(l_oBefore.or_date),"orstat","Tag1")
		SELECT orstat
		SCATTER NAME l_oAfter
		REPLACE or_crev0 WITH or_crev0 - l_oBefore.or_0rev0 + l_oAfter.or_0rev0, ;
				or_crev1 WITH or_crev1 - l_oBefore.or_0rev1 + l_oAfter.or_0rev1, ;
				or_crev2 WITH or_crev2 - l_oBefore.or_0rev2 + l_oAfter.or_0rev2, ;
				or_crev3 WITH or_crev3 - l_oBefore.or_0rev3 + l_oAfter.or_0rev3, ;
				or_crev4 WITH or_crev4 - l_oBefore.or_0rev4 + l_oAfter.or_0rev4, ;
				or_crev5 WITH or_crev5 - l_oBefore.or_0rev5 + l_oAfter.or_0rev5, ;
				or_crev6 WITH or_crev6 - l_oBefore.or_0rev6 + l_oAfter.or_0rev6, ;
				or_crev7 WITH or_crev7 - l_oBefore.or_0rev7 + l_oAfter.or_0rev7, ;
				or_crev8 WITH or_crev8 - l_oBefore.or_0rev8 + l_oAfter.or_0rev8, ;
				or_crev9 WITH or_crev9 - l_oBefore.or_0rev9 + l_oAfter.or_0rev9, ;
				or_crevx WITH or_crevx - l_oBefore.or_0revx + l_oAfter.or_0revx, ;
				or_cvat0 WITH or_cvat0 - l_oBefore.or_0vat0 + l_oAfter.or_0vat0, ;
				or_cvat1 WITH or_cvat1 - l_oBefore.or_0vat1 + l_oAfter.or_0vat1, ;
				or_cvat2 WITH or_cvat2 - l_oBefore.or_0vat2 + l_oAfter.or_0vat2, ;
				or_cvat3 WITH or_cvat3 - l_oBefore.or_0vat3 + l_oAfter.or_0vat3, ;
				or_cvat4 WITH or_cvat4 - l_oBefore.or_0vat4 + l_oAfter.or_0vat4, ;
				or_cvat5 WITH or_cvat5 - l_oBefore.or_0vat5 + l_oAfter.or_0vat5, ;
				or_cvat6 WITH or_cvat6 - l_oBefore.or_0vat6 + l_oAfter.or_0vat6, ;
				or_cvat7 WITH or_cvat7 - l_oBefore.or_0vat7 + l_oAfter.or_0vat7, ;
				or_cvat8 WITH or_cvat8 - l_oBefore.or_0vat8 + l_oAfter.or_0vat8, ;
				or_cvat9 WITH or_cvat9 - l_oBefore.or_0vat9 + l_oAfter.or_0vat9, ;
				or_cvatx WITH or_cvatx - l_oBefore.or_0vatx + l_oAfter.or_0vatx ;
			FOR or_date >= l_oBefore.or_date ;
			WHILE or_label == l_oBefore.or_label AND or_code == l_oBefore.or_code AND ;
			YEAR(or_date) = YEAR(l_oBefore.or_date) IN orstat
		SELECT curOrstat
	ENDSCAN
	USE IN curOrstat
ENDIF
SELECT histpost.*, article.ar_main, histres.hr_market, histres.hr_source, histres.hr_country, ;
	histres.hr_roomtyp, histres.hr_roomnum, STRTRAN(STRTRAN(histres.hr_ratecod,"*"),"!") AS hr_ratecod FROM histpost ;
	LEFT JOIN article ON histpost.hp_artinum = article.ar_artinum ;
	LEFT JOIN histres ON INLIST(histres.hr_reserid, histpost.hp_reserid, histpost.hp_origid) ;
	WHERE hp_date = lp_dForDate AND NOT SEEK(histpost.hp_postid,"post","Tag3") AND NOT hp_cancel AND ;
	hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) ;
	INTO CURSOR curPost READWRITE
SELECT * FROM histors WHERE or_date = lp_dForDate ORDER BY or_label, or_code INTO CURSOR curOrstat
BLANK FIELDS LIKE or_0rev?, or_0vat? FOR or_date = lp_dForDate IN histors
SELECT curPost
SCAN
	RiGetRoom(hp_reserid, lp_dForDate, @l_oResroom, .NULL., "hresroom")
	IF NOT ISNULL(l_oResroom)
		REPLACE hr_roomtyp WITH l_oResroom.ri_roomtyp, ;
				hr_roomnum WITH l_oResroom.ri_roomnum IN curPost
	ENDIF
	FOR l_nLabel = 1 TO ALEN(l_aLabels,1)
		IF SEEK(PADR(l_aLabels(l_nLabel,1),10)+PADR(IIF(ISNULL(EVALUATE("curPost."+l_aLabels(l_nLabel,2))), "", ;
				EVALUATE("curPost."+l_aLabels(l_nLabel,2))),10)+DTOS(lp_dForDate),"histors","Tag1")
			l_cIndex = IIF(ISNULL(curPost.ar_main), "x", STR(MAX(curPost.ar_main,0),1))
			l_nVatValue = 0
			FOR i = 1 TO 9
				l_nVatValue = l_nVatValue + EVALUATE("curPost.hp_vat" + STR(i,1))
			NEXT
			l_cField = "or_0rev" + l_cIndex
			REPLACE &l_cField WITH histors.&l_cField + curPost.hp_amount IN histors
			l_cField = "or_0vat" + l_cIndex
			REPLACE &l_cField WITH histors.&l_cField + l_nVatValue IN histors
		ENDIF
	NEXT
ENDSCAN
USE IN curPost
SET ORDER TO Tag1 IN histors
SELECT curOrstat
SCAN
	SCATTER NAME l_oBefore
	= SEEK(PADR(l_oBefore.or_label,10)+PADR(l_oBefore.or_code,10)+DTOS(l_oBefore.or_date),"histors","Tag1")
	SELECT histors
	SCATTER NAME l_oAfter
	REPLACE or_crev0 WITH or_crev0 - l_oBefore.or_0rev0 + l_oAfter.or_0rev0, ;
			or_crev1 WITH or_crev1 - l_oBefore.or_0rev1 + l_oAfter.or_0rev1, ;
			or_crev2 WITH or_crev2 - l_oBefore.or_0rev2 + l_oAfter.or_0rev2, ;
			or_crev3 WITH or_crev3 - l_oBefore.or_0rev3 + l_oAfter.or_0rev3, ;
			or_crev4 WITH or_crev4 - l_oBefore.or_0rev4 + l_oAfter.or_0rev4, ;
			or_crev5 WITH or_crev5 - l_oBefore.or_0rev5 + l_oAfter.or_0rev5, ;
			or_crev6 WITH or_crev6 - l_oBefore.or_0rev6 + l_oAfter.or_0rev6, ;
			or_crev7 WITH or_crev7 - l_oBefore.or_0rev7 + l_oAfter.or_0rev7, ;
			or_crev8 WITH or_crev8 - l_oBefore.or_0rev8 + l_oAfter.or_0rev8, ;
			or_crev9 WITH or_crev9 - l_oBefore.or_0rev9 + l_oAfter.or_0rev9, ;
			or_crevx WITH or_crevx - l_oBefore.or_0revx + l_oAfter.or_0revx, ;
			or_cvat0 WITH or_cvat0 - l_oBefore.or_0vat0 + l_oAfter.or_0vat0, ;
			or_cvat1 WITH or_cvat1 - l_oBefore.or_0vat1 + l_oAfter.or_0vat1, ;
			or_cvat2 WITH or_cvat2 - l_oBefore.or_0vat2 + l_oAfter.or_0vat2, ;
			or_cvat3 WITH or_cvat3 - l_oBefore.or_0vat3 + l_oAfter.or_0vat3, ;
			or_cvat4 WITH or_cvat4 - l_oBefore.or_0vat4 + l_oAfter.or_0vat4, ;
			or_cvat5 WITH or_cvat5 - l_oBefore.or_0vat5 + l_oAfter.or_0vat5, ;
			or_cvat6 WITH or_cvat6 - l_oBefore.or_0vat6 + l_oAfter.or_0vat6, ;
			or_cvat7 WITH or_cvat7 - l_oBefore.or_0vat7 + l_oAfter.or_0vat7, ;
			or_cvat8 WITH or_cvat8 - l_oBefore.or_0vat8 + l_oAfter.or_0vat8, ;
			or_cvat9 WITH or_cvat9 - l_oBefore.or_0vat9 + l_oAfter.or_0vat9, ;
			or_cvatx WITH or_cvatx - l_oBefore.or_0vatx + l_oAfter.or_0vatx ;
		FOR or_date >= l_oBefore.or_date ;
		WHILE or_label == l_oBefore.or_label AND or_code == l_oBefore.or_code AND ;
		YEAR(or_date) = YEAR(l_oBefore.or_date) IN histors
	SELECT curOrstat
ENDSCAN
USE IN curOrstat
ENDPROC
*
PROCEDURE RemoveReservation
LPARAMETERS lp_nReserId, lp_lInHistory
LOCAL l_oEnvironment, l_cAlias
l_cAlias = IIF(lp_lInHistory, "histors", "orstat")
l_oEnvironment = SetEnvironment(l_cAlias + ", histres, hresroom, hresrate, roomtype, room", "tag1")
IF DLocate("histres", "hr_reserid = " + SqlCnv(lp_nReserId))
	OrHistRs(l_cAlias, .T.)
ENDIF
ENDPROC
*
FUNCTION OrGraphDataCreate
LPARAMETERS tcLabel, tdBegin, tdEnd, tnYearCompare, tnYearLast
LOCAL lnYear, ldCompareBegin, ldCompareEnd

IF EMPTY(tnYearCompare) OR EMPTY(tnYearLast)
	OrPpCusorCreate(tcLabel,,"PreProc")
	OrPpRequery(tcLabel, tdBegin, tdEnd, 0, 10, "PreProc")
	SELECT PreProc
	INDEX ON pp_code TAG pp_code
	IF NOT EMPTY(tnYearCompare)
		ldCompareBegin = EVALUATE("{^"+ALLTRIM(STR(tnYearCompare))+"-"+ALLTRIM(STR(MONTH(tdBegin)))+"-"+ALLTRIM(STR(DAY(tdBegin)))+"}")
		ldCompareEnd = EVALUATE("{^"+ALLTRIM(STR(tnYearCompare))+"-"+ALLTRIM(STR(MONTH(tdEnd)))+"-"+ALLTRIM(STR(DAY(tdEnd)))+"}")
		OrPpCusorCreate(tcLabel, .F., "ypp")
		OrPpRequery(tcLabel, ldCompareBegin, ldCompareEnd, 0, 10, "ypp")
		SELECT ypp
		INDEX ON pp_code TAG pp_code
		OrCompareSync("preproc", "ypp", .T., .T., .T., .T., .T., .T., .T., .T.)
		OrCompareSync("ypp", "preproc", .T., .T., .T., .T., .T., .T., .T., .T.)
	ENDIF
ELSE
	FOR lnYear = tnYearCompare TO MAX(tnYearCompare, tnYearLast)
		IF EMPTY(tdBegin)
			ldCompareBegin = DATE(lnYear, 1, 1)
			ldCompareEnd = DATE(lnYear, 12, 31)
		ELSE
			ldCompareBegin = DATE(lnYear, MONTH(tdBegin), 1)
			ldCompareEnd = DATE(lnYear, MONTH(tdBegin), LastDay(ldCompareBegin))
		ENDIF
		OrPpCusorCreate(tcLabel, .F., "pp" + ALLTRIM(STR(lnYear)))
		OrPpRequery(tcLabel, ldCompareBegin, ldCompareEnd, 0, 10, "pp" + ALLTRIM(STR(lnYear)))
		SELECT("pp" + ALLTRIM(STR(lnYear)))
		INDEX ON pp_code TAG pp_code
	NEXT
ENDIF
ENDFUNC
*