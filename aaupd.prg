PROCEDURE AaUpd
LOCAL laDialog, lcExitMessage, lnStartYear, lnEndYear, llRecalcOcc, llRecalcRev, ltStartTime, ltEndTime

OpenFileDirect(.F.,"Histstat")
SELECT Histstat
SET ORDER TO
LOCATE FOR aa_date >= DATE(2000,1,1)
DIMENSION laDialog[3, 8]
laDialog[1, 1] = "txtStartDate"
laDialog[1, 2] = GetLangText("ASTAT","TXT_START_YEAR")
laDialog[1, 3] = "YEAR(IIF(EMPTY(aa_date), SysDate(), aa_date))"
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
laDialog[3, 2] = GetLangText("ASTAT","TXT_RECALC_OCC")+";"+GetLangText("ASTAT","TXT_RECALC_REV")+";"+GetLangText("ASTAT","TXT_RECALC_BOTH")
laDialog[3, 3] = "3"
laDialog[3, 4] = "@*RH"
laDialog[3, 5] = 30
laDialog[3, 6] = ""
laDialog[3, 7] = ""
IF Dialog(GetLangText("ASTAT","TXT_RECALCULATE"),GetLangText("COMMON", "TXT_PROCEED_FILL_ADDRSTAT"),@laDialog)
	lnStartYear = laDialog(1,8)
	lnEndYear   = laDialog(2,8)
	llRecalcOcc = laDialog(3,8)#2
	llRecalcRev = laDialog(3,8)#1
ENDIF
IF EMPTY(lnStartYear) OR EMPTY(lnEndYear) OR NOT llRecalcOcc AND NOT llRecalcRev
	lcExitMessage = GetLangText("ASTAT","TXT_NO_CHANGES_MADE")
ELSE
	ltStartTime = SECONDS()
	ReCalcAStat(lnStartYear, lnEndYear, llRecalcOcc, llRecalcRev)
	ltEndTime = SECONDS()
	lcExitMessage = Str2Msg(GetLangText("ASTAT","TXT_CHANGES_ARE_MADE"), "%s", Sec2Time(ltEndTime - ltStartTime))
	WAIT CLEAR
ENDIF

Alert(lcExitMessage, GetLangText("ASTAT","TXT_RECALCULATE"))
RETURN .T.
ENDPROC
*
FUNCTION ReCalcAStat
LPARAMETERS tnStartYear, tnEndYear, tlRecalcOcc, tlRecalcRev
	PRIVATE pdStartDate, pdEndDate
	LOCAL lcAstat, loAudit
	LOCAL ARRAY l_aProcess(4)

	pdStartDate = DATE(tnStartYear,1,1)
	pdEndDate = DATE(tnEndYear,12,31)

	OpenFileDirect(.F.,"Astat")
	OpenFileDirect(.F.,"LastStay")
	SET ORDER TO tag1 IN article

	IF tlRecalcRev
		SET ORDER TO "" IN histpost
		CALCULATE CNT() FOR BETWEEN(hp_date, pdStartDate, pdEndDate) TO l_aProcess(1) IN histpost
	ENDIF
	IF tlRecalcOcc
		SET ORDER TO "" IN histres
		CALCULATE CNT() FOR hr_reserid > 1 AND hr_arrdate <= pdEndDate AND hr_depdate > pdStartDate TO l_aProcess(2) IN histres
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
			DELETE FOR BETWEEN(aa_date, pdStartDate, pdEndDate) IN astat
			DELETE FOR BETWEEN(aa_date, pdStartDate, pdEndDate) IN histstat
		CASE tlRecalcOcc
			BLANK FIELDS aa_0res, aa_0cxl, aa_0ns, aa_0nights, aa_cres, aa_ccxl, aa_cns, aa_cnights FOR BETWEEN(aa_date, pdStartDate, pdEndDate) IN astat
			BLANK FIELDS aa_0res, aa_0cxl, aa_0ns, aa_0nights, aa_cres, aa_ccxl, aa_cns, aa_cnights FOR BETWEEN(aa_date, pdStartDate, pdEndDate) IN histstat
		CASE tlRecalcRev
			BLANK FIELDS LIKE aa_0amount, aa_0amt?, aa_0vat?, aa_camount, aa_camt?, aa_cvat? FOR BETWEEN(aa_date, pdStartDate, pdEndDate) IN astat
			BLANK FIELDS LIKE aa_0amount, aa_0amt?, aa_0vat?, aa_camount, aa_camt?, aa_cvat? FOR BETWEEN(aa_date, pdStartDate, pdEndDate) IN histstat
	ENDCASE

	DO FORM "forms\audit" NAME loAudit WITH ChildTitle(GetLangText("ASTAT","TXT_RECALCULATE"))
	loAudit.lLog = .F.
	loAudit.ScrollProgressInit(@l_aProcess)

	lcAstat = "histstat"
	IF tlRecalcRev
		loAudit.TxtInfo("Scaning through HistPost table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN histpost
		SELECT histpost
		SET RELATION TO hp_artinum INTO article ADDITIVE
		SCAN FOR BETWEEN(hp_date, pdStartDate, pdEndDate)
 	  		loAudit.Progress(1)
			AaHistPs(lcAstat, hp_date)
		ENDSCAN
		SET RELATION OFF INTO article
	ENDIF

	IF tlRecalcOcc
		loAudit.TxtInfo("Scaning through HistRes table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN histres
		SELECT histres
		SCAN FOR hr_reserid > 1 AND hr_arrdate <= pdEndDate AND hr_depdate > pdStartDate
 	  		loAudit.Progress(2)
			AaHistRs(lcAstat, hr_arrdate)
			LsHistUpd()
		ENDSCAN
	ENDIF

	lcAstat = "astat"
	IF tlRecalcRev
		loAudit.TxtInfo("Scaning through Post table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN post
		SELECT post
		SET RELATION TO ps_artinum INTO article ADDITIVE
		SCAN FOR BETWEEN(ps_date, pdStartDate, pdEndDate)
 	  		loAudit.Progress(3)
			AaPost(lcAstat, ps_date)
		ENDSCAN
		SET RELATION OFF INTO article
	ENDIF

	IF tlRecalcOcc
		loAudit.TxtInfo("Scaning through Reservat table!", 3)
		ON KEY LABEL ALT+Q GO BOTTOM IN reservat
		SELECT reservat
		SCAN FOR rs_reserid > 1 AND DTOS(rs_arrdate)+rs_lname < DTOS(pdEndDate+1) AND DTOS(rs_depdate)+rs_roomnum > DTOS(pdStartDate)
 	  		loAudit.Progress(4)
			AaReservat(lcAstat, rs_arrdate)
		ENDSCAN
	ENDIF
	ON KEY LABEL ALT+Q
	loAudit.Release()
ENDFUNC

FUNCTION AaPost
	LPARAMETERS lp_alias, lp_date
	PRIVATE p_0amount
	PRIVATE p_0vat0,p_0vat1,p_0vat2,p_0vat3,p_0vat4,p_0vat5,p_0vat6,p_0vat7,p_0vat8,p_0vat9
	PRIVATE p_0amt0,p_0amt1,p_0amt2,p_0amt3,p_0amt4,p_0amt5,p_0amt6,p_0amt7,p_0amt8,p_0amt9
	LOCAL l_nArea, l_macro, lPrivateResrateMessageContent

	l_nArea = SELECT()
	SELECT post
	IF NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) AND SEEK(ps_reserid, "reservat", "Tag1")
		STORE 0 TO p_0amount
		STORE 0 TO p_0vat0,p_0vat1,p_0vat2,p_0vat3,p_0vat4,p_0vat5,p_0vat6,p_0vat7,p_0vat8,p_0vat9
		STORE 0 TO p_0amt0,p_0amt1,p_0amt2,p_0amt3,p_0amt4,p_0amt5,p_0amt6,p_0amt7,p_0amt8,p_0amt9
		p_0amount = p_0amount + ps_amount
		l_macro = 'p_0vat' + ALLTRIM(STR(article.ar_main)) + '=' + ;
			'ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9'
		&l_macro
		l_macro='p_0amt'+ALLTRIM(STR(article.ar_main))+'=ps_amount'
		IF EMPTY(article.ar_artinum)
			lPrivateResrateMessageContent = " ps_artinum %s1 not found in article table. ps_postid: %s2 ps_amount: %s3"
			ErrorMsg(PROGRAM()+" CallProc: "+PROGRAM(PROGRAM(-1)-1)+Str2Msg(lPrivateResrateMessageContent,"%s",;
					TRANSFORM(ps_artinum), TRANSFORM(ps_postid), TRANSFORM(ps_amount)))
		ENDIF
		&l_macro
		SELECT reservat
		IF rs_addrid > 0
			AaPsUpd(lp_alias, rs_addrid, lp_date)
		ENDIF
		IF rs_compid > 0 AND rs_compid <> rs_addrid
			AaPsUpd(lp_alias, rs_compid, lp_date)
		ENDIF
		IF rs_agentid > 0 AND rs_agentid <> rs_addrid AND rs_agentid <> rs_compid
			AaPsUpd(lp_alias, rs_agentid, lp_date)
		ENDIF
	ENDIF
	SELECT(l_nArea)
ENDFUNC

FUNCTION AaHistPs
	LPARAMETERS lp_alias, lp_date
	PRIVATE p_0amount
	PRIVATE p_0vat0,p_0vat1,p_0vat2,p_0vat3,p_0vat4,p_0vat5,p_0vat6,p_0vat7,p_0vat8,p_0vat9
	PRIVATE p_0amt0,p_0amt1,p_0amt2,p_0amt3,p_0amt4,p_0amt5,p_0amt6,p_0amt7,p_0amt8,p_0amt9
	LOCAL l_nArea, l_macro, lPrivateResrateMessageContent

	l_nArea = SELECT()
	SELECT histpost
	IF NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) AND ;
			SEEK(hp_reserid, "histres", "Tag1") AND NOT SEEK(hp_reserid, "reservat", "Tag1")
		STORE 0 TO p_0amount
		STORE 0 TO p_0vat0,p_0vat1,p_0vat2,p_0vat3,p_0vat4,p_0vat5,p_0vat6,p_0vat7,p_0vat8,p_0vat9
		STORE 0 TO p_0amt0,p_0amt1,p_0amt2,p_0amt3,p_0amt4,p_0amt5,p_0amt6,p_0amt7,p_0amt8,p_0amt9
		p_0amount = p_0amount + hp_amount
		l_macro = 'p_0vat' + ALLTRIM(STR(article.ar_main)) + '=' + ;
			'hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9'
		IF EMPTY(article.ar_artinum)
			lPrivateResrateMessageContent = " hp_artinum %s1 not found in article table. hp_postid: %s2 hp_amount: %s3"
			ErrorMsg(PROGRAM()+" CallProc: "+PROGRAM(PROGRAM(-1)-1)+Str2Msg(lPrivateResrateMessageContent,"%s",;
					TRANSFORM(hp_artinum), TRANSFORM(hp_postid), TRANSFORM(hp_amount)))
		ENDIF
		&l_macro
		l_macro='p_0amt'+ALLTRIM(STR(article.ar_main))+'=hp_amount'
		&l_macro
		SELECT histres
		IF hr_addrid > 0
			AaPsUpd(lp_alias, hr_addrid, lp_date)
		ENDIF
		IF hr_compid > 0 AND hr_compid <> hr_addrid
			AaPsUpd(lp_alias, hr_compid, lp_date)
		ENDIF
		IF hr_agentid > 0 AND hr_agentid <> hr_addrid AND hr_agentid <> hr_compid
			AaPsUpd(lp_alias, hr_agentid, lp_date)
		ENDIF
	ENDIF
	SELECT(l_nArea)
ENDFUNC

FUNCTION AaReservat
	LPARAMETERS lp_alias, lp_date
	LOCAL l_nArea
	PRIVATE p_lAdd
	p_lAdd = .T.	&& Remove values in AaResUpd()

	l_nArea = SELECT()
	SELECT reservat
	IF rs_arrdate <= lp_date AND DbLookup("roomtype","tag1",rs_roomtyp,"INLIST(rt_group,1,4) AND rt_vwsum")
		IF rs_addrid > 0
			AaResUpd(lp_alias, rs_addrid, rs_arrdate, rs_depdate, rs_status)
		ENDIF
		IF rs_compid > 0 AND rs_compid <> rs_addrid
			AaResUpd(lp_alias, rs_compid, rs_arrdate, rs_depdate, rs_status)
		ENDIF
		IF rs_agentid > 0 AND rs_agentid <> rs_addrid AND rs_agentid <> rs_compid
			AaResUpd(lp_alias, rs_agentid, rs_arrdate, rs_depdate, rs_status)
		ENDIF
	ENDIF
	SELECT(l_nArea)
ENDFUNC

FUNCTION AaHistRs
	LPARAMETERS lp_alias, lp_date, lp_lRemove
	LOCAL l_nArea
	PRIVATE p_lAdd
	p_lAdd = NOT lp_lRemove

	l_nArea = SELECT()
	SELECT histres
	IF hr_arrdate <= lp_date AND NOT SEEK(hr_reserid,'reservat','tag1') AND ;
			DbLookup("roomtype","tag1",hr_roomtyp,"INLIST(rt_group,1,4) AND rt_vwsum")
		IF hr_addrid > 0
			AaResUpd(lp_alias, hr_addrid, hr_arrdate, hr_depdate, hr_status)
		ENDIF
		IF hr_compid > 0 AND hr_compid <> hr_addrid
			AaResUpd(lp_alias, hr_compid, hr_arrdate, hr_depdate, hr_status)
		ENDIF
		IF hr_agentid > 0 AND hr_agentid <> hr_addrid AND hr_agentid <> hr_compid
			AaResUpd(lp_alias, hr_agentid, hr_arrdate, hr_depdate, hr_status)
		ENDIF
	ENDIF
	SELECT(l_nArea)
ENDFUNC

FUNCTION AaInsert
	LPARAMETERS lp_alias, lp_addrid, lp_date
	LOCAL l_nArea, l_rec, l_cNear

	l_nArea = SELECT()
	SELECT &lp_alias
	SET ORDER TO tag2 DESCENDING
	l_cNear = SET("Near")
	SET NEAR ON
	SEEK(PADL(lp_addrid,8,"0")+DTOS(lp_date))
	SET NEAR &l_cNear
	IF aa_addrid = lp_addrid AND YEAR(aa_date) = YEAR(lp_date) AND aa_date < lp_date
		SCATTER NAME l_rec
	ELSE
		SCATTER NAME l_rec BLANK
	ENDIF
	SET ORDER TO tag2 ASCENDING
	INSERT INTO &lp_alias (aa_addrid, aa_date, aa_camount, ;
			aa_camt0, aa_camt1, aa_camt2, aa_camt3, ;
			aa_camt4, aa_camt5, aa_camt6, aa_camt7, ;
			aa_camt8, aa_camt9, aa_cvat0, aa_cvat1, ;
			aa_cvat2, aa_cvat3, aa_cvat4, aa_cvat5, ;
			aa_cvat6, aa_cvat7, aa_cvat8, aa_cvat9, ;
			aa_cres, aa_cnights, aa_ccxl, aa_cns) ;
		VALUES (lp_addrid, lp_date, l_rec.aa_camount, ;
			l_rec.aa_camt0, l_rec.aa_camt1, l_rec.aa_camt2, l_rec.aa_camt3, ;
			l_rec.aa_camt4, l_rec.aa_camt5, l_rec.aa_camt6, l_rec.aa_camt7, ;
			l_rec.aa_camt8, l_rec.aa_camt9, l_rec.aa_cvat0, l_rec.aa_cvat1, ;
			l_rec.aa_cvat2, l_rec.aa_cvat3, l_rec.aa_cvat4, l_rec.aa_cvat5, ;
			l_rec.aa_cvat6, l_rec.aa_cvat7, l_rec.aa_cvat8, l_rec.aa_cvat9, ;
			l_rec.aa_cres, l_rec.aa_cnights, l_rec.aa_ccxl, l_rec.aa_cns)
	SELECT(l_nArea)
ENDFUNC

FUNCTION AaPsUpd
	LPARAMETERS lp_alias, lp_addrid, lp_date
	LOCAL l_nArea, l_macro1, l_macro2, l_year, l_lPeriodFilter

	l_lPeriodFilter = (VARTYPE(pdStartDate)="D" AND VARTYPE(pdEndDate)="D")
	IF l_lPeriodFilter AND NOT BETWEEN(lp_date, pdStartDate, pdEndDate)
		RETURN
	ENDIF
	l_nArea = SELECT()
	SELECT &lp_alias
	IF !SEEK(PADL(lp_addrid,8,"0")+DTOS(lp_date),lp_alias,'tag2')
		AaInsert(lp_alias, lp_addrid, lp_date)
	ENDIF
	REPLACE aa_0amount WITH aa_0amount+p_0amount, ;
			aa_0amt0 WITH aa_0amt0+p_0amt0, aa_0amt1 WITH aa_0amt1+p_0amt1, ;
			aa_0amt2 WITH aa_0amt2+p_0amt2, aa_0amt3 WITH aa_0amt3+p_0amt3, ;
			aa_0amt4 WITH aa_0amt4+p_0amt4, aa_0amt5 WITH aa_0amt5+p_0amt5, ;
			aa_0amt6 WITH aa_0amt6+p_0amt6, aa_0amt7 WITH aa_0amt7+p_0amt7, ;
			aa_0amt8 WITH aa_0amt8+p_0amt8, aa_0amt9 WITH aa_0amt9+p_0amt9, ;
			aa_0vat0 WITH aa_0vat0+p_0vat0, aa_0vat1 WITH aa_0vat1+p_0vat1, ;
			aa_0vat2 WITH aa_0vat2+p_0vat2, aa_0vat3 WITH aa_0vat3+p_0vat3, ;
			aa_0vat4 WITH aa_0vat4+p_0vat4, aa_0vat5 WITH aa_0vat5+p_0vat5, ;
			aa_0vat6 WITH aa_0vat6+p_0vat6, aa_0vat7 WITH aa_0vat7+p_0vat7, ;
			aa_0vat8 WITH aa_0vat8+p_0vat8, aa_0vat9 WITH aa_0vat9+p_0vat9
	l_year = YEAR(aa_date)
	SCAN REST WHILE (aa_addrid==lp_addrid) .AND. (YEAR(aa_date)==l_year)
		REPLACE aa_camount WITH aa_camount+p_0amount, ;
				aa_camt0 WITH aa_camt0+p_0amt0, aa_camt1 WITH aa_camt1+p_0amt1, ;
				aa_camt2 WITH aa_camt2+p_0amt2, aa_camt3 WITH aa_camt3+p_0amt3, ;
				aa_camt4 WITH aa_camt4+p_0amt4, aa_camt5 WITH aa_camt5+p_0amt5, ;
				aa_camt6 WITH aa_camt6+p_0amt6, aa_camt7 WITH aa_camt7+p_0amt7, ;
				aa_camt8 WITH aa_camt8+p_0amt8, aa_camt9 WITH aa_camt9+p_0amt9, ;
				aa_cvat0 WITH aa_cvat0+p_0vat0, aa_cvat1 WITH aa_cvat1+p_0vat1, ;
				aa_cvat2 WITH aa_cvat2+p_0vat2, aa_cvat3 WITH aa_cvat3+p_0vat3, ;
				aa_cvat4 WITH aa_cvat4+p_0vat4, aa_cvat5 WITH aa_cvat5+p_0vat5, ;
				aa_cvat6 WITH aa_cvat6+p_0vat6, aa_cvat7 WITH aa_cvat7+p_0vat7, ;
				aa_cvat8 WITH aa_cvat8+p_0vat8, aa_cvat9 WITH aa_cvat9+p_0vat9
	ENDSCAN
	SELECT(l_nArea)
ENDFUNC

FUNCTION AaResUpd
	LPARAMETERS lp_alias, lp_nAddrId, lp_dArrdate, lp_dDepdate, lp_cStatus
	LOCAL l_nArea, l_dDate, l_dEndDate, l_cFields, l_lPeriodFilter

	l_nArea = SELECT()
	l_lPeriodFilter = (VARTYPE(pdStartDate)="D" AND VARTYPE(pdEndDate)="D")
	l_cFields = "aa_0res WITH MAX(0, aa_0res + IIF(p_lAdd,1,-1))" + IIF(lp_cStatus = "CXL", + ;
			  ", aa_0cxl WITH MAX(0, aa_0cxl + IIF(p_lAdd,1,-1))", "") + IIF(lp_cStatus = "NS", + ;
			  ", aa_0ns  WITH MAX(0, aa_0ns  + IIF(p_lAdd,1,-1))", "")
	IF NOT l_lPeriodFilter OR BETWEEN(lp_dArrdate, pdStartDate, pdEndDate)
		IF NOT SEEK(PADL(lp_nAddrId,8,"0")+DTOS(lp_dArrdate),lp_alias,'tag2')
			AaInsert(lp_alias, lp_nAddrId, lp_dArrdate)
		ENDIF
		REPLACE &l_cFields IN &lp_alias
	ENDIF
	l_cFields = STRTRAN(l_cFields, "aa_0", "aa_c")
	REPLACE &l_cFields FOR NOT l_lPeriodFilter OR BETWEEN(aa_date, pdStartDate, pdEndDate) WHILE aa_addrid = lp_nAddrId AND YEAR(aa_date) = YEAR(lp_dArrdate) IN &lp_alias

	IF NOT INLIST(lp_cStatus,"NS","CXL")
		l_dDate = IIF(l_lPeriodFilter, MAX(lp_dArrdate,pdStartDate), lp_dArrdate)
		l_dEndDate = MAX(lp_dArrdate, lp_dDepdate-1)
		l_dEndDate = IIF(l_lPeriodFilter, MIN(l_dEndDate,pdEndDate), l_dEndDate)
		DO WHILE l_dDate <= l_dEndDate
			IF NOT SEEK(PADL(lp_nAddrId,8,"0")+DTOS(l_dDate),lp_alias,'tag2')
				AaInsert(lp_alias, lp_nAddrId, l_dDate)
			ENDIF
			REPLACE aa_0nights WITH MAX(0, aa_0nights + IIF(p_lAdd,1,-1)) IN &lp_alias
			REPLACE aa_cnights WITH MAX(0, aa_cnights + IIF(p_lAdd,1,-1)) ;
				FOR NOT l_lPeriodFilter OR BETWEEN(aa_date, pdStartDate, pdEndDate) ;
				WHILE aa_addrid = lp_nAddrId AND YEAR(aa_date) = YEAR(l_dDate) IN &lp_alias
			l_dDate = l_dDate + 1
		ENDDO
	ENDIF
	SELECT(l_nArea)
ENDFUNC

FUNCTION AaPlus
LPARAMETERS lp_cAlias, lp_nAddrId, lp_dDate, lp_oAa
 LOCAL l_nArea, l_nRecNo, l_nYear
 l_nArea = SELECT()
 SELECT(lp_cAlias)
 l_nRecNo = RECNO()
 l_cOrder = ORDER()
 SET ORDER TO tag2
 IF NOT SEEK(PADL(lp_nAddrId,8,"0")+DTOS(lp_dDate), lp_cAlias, "tag2")
	AaInsert(lp_cAlias, lp_nAddrId, lp_dDate)
 ENDIF
 REPLACE aa_0amount WITH aa_0amount + lp_oAa.aa_0amount, ;
		aa_0amt0 WITH aa_0amt0 + lp_oAa.aa_0amt0, ;
		aa_0amt1 WITH aa_0amt1 + lp_oAa.aa_0amt1, ;
		aa_0amt2 WITH aa_0amt2 + lp_oAa.aa_0amt2, ;
		aa_0amt3 WITH aa_0amt3 + lp_oAa.aa_0amt3, ;
		aa_0amt4 WITH aa_0amt4 + lp_oAa.aa_0amt4, ;
		aa_0amt5 WITH aa_0amt5 + lp_oAa.aa_0amt5, ;
		aa_0amt6 WITH aa_0amt6 + lp_oAa.aa_0amt6, ;
		aa_0amt7 WITH aa_0amt7 + lp_oAa.aa_0amt7, ;
		aa_0amt8 WITH aa_0amt8 + lp_oAa.aa_0amt8, ;
		aa_0amt9 WITH aa_0amt9 + lp_oAa.aa_0amt9, ;
		aa_0vat0 WITH aa_0vat0 + lp_oAa.aa_0vat0, ;
		aa_0vat1 WITH aa_0vat1 + lp_oAa.aa_0vat1, ;
		aa_0vat2 WITH aa_0vat2 + lp_oAa.aa_0vat2, ;
		aa_0vat3 WITH aa_0vat3 + lp_oAa.aa_0vat3, ;
		aa_0vat4 WITH aa_0vat4 + lp_oAa.aa_0vat4, ;
		aa_0vat5 WITH aa_0vat5 + lp_oAa.aa_0vat5, ;
		aa_0vat6 WITH aa_0vat6 + lp_oAa.aa_0vat6, ;
		aa_0vat7 WITH aa_0vat7 + lp_oAa.aa_0vat7, ;
		aa_0vat8 WITH aa_0vat8 + lp_oAa.aa_0vat8, ;
		aa_0vat9 WITH aa_0vat9 + lp_oAa.aa_0vat9, ;
		aa_0nights WITH aa_0nights + lp_oAa.aa_0nights, ;
		aa_0res WITH aa_0res + lp_oAa.aa_0res, ;
		aa_0cxl WITH aa_0cxl + lp_oAa.aa_0cxl, ;
		aa_0ns WITH aa_0ns + lp_oAa.aa_0ns
 l_nYear = YEAR(aa_date)
 SCAN REST WHILE (aa_addrid == lp_nAddrId) AND (YEAR(aa_date) == l_nYear)
	REPLACE aa_camount WITH aa_camount + lp_oAa.aa_0amount, ;
			aa_camt0 WITH aa_camt0 + lp_oAa.aa_0amt0, ;
			aa_camt1 WITH aa_camt1 + lp_oAa.aa_0amt1, ;
			aa_camt2 WITH aa_camt2 + lp_oAa.aa_0amt2, ;
			aa_camt3 WITH aa_camt3 + lp_oAa.aa_0amt3, ;
			aa_camt4 WITH aa_camt4 + lp_oAa.aa_0amt4, ;
			aa_camt5 WITH aa_camt5 + lp_oAa.aa_0amt5, ;
			aa_camt6 WITH aa_camt6 + lp_oAa.aa_0amt6, ;
			aa_camt7 WITH aa_camt7 + lp_oAa.aa_0amt7, ;
			aa_camt8 WITH aa_camt8 + lp_oAa.aa_0amt8, ;
			aa_camt9 WITH aa_camt9 + lp_oAa.aa_0amt9, ;
			aa_cvat0 WITH aa_cvat0 + lp_oAa.aa_0vat0, ;
			aa_cvat1 WITH aa_cvat1 + lp_oAa.aa_0vat1, ;
			aa_cvat2 WITH aa_cvat2 + lp_oAa.aa_0vat2, ;
			aa_cvat3 WITH aa_cvat3 + lp_oAa.aa_0vat3, ;
			aa_cvat4 WITH aa_cvat4 + lp_oAa.aa_0vat4, ;
			aa_cvat5 WITH aa_cvat5 + lp_oAa.aa_0vat5, ;
			aa_cvat6 WITH aa_cvat6 + lp_oAa.aa_0vat6, ;
			aa_cvat7 WITH aa_cvat7 + lp_oAa.aa_0vat7, ;
			aa_cvat8 WITH aa_cvat8 + lp_oAa.aa_0vat8, ;
			aa_cvat9 WITH aa_cvat9 + lp_oAa.aa_0vat9, ;
			aa_cnights WITH aa_cnights + lp_oAa.aa_0nights, ;
			aa_cres WITH aa_cres + lp_oAa.aa_0res, ;
			aa_ccxl WITH aa_ccxl + lp_oAa.aa_0cxl, ;
			aa_cns WITH aa_cns + lp_oAa.aa_0ns
 ENDSCAN
 SET ORDER TO l_cOrder
 GO l_nRecNo
 SELECT(l_nArea)
ENDFUNC

FUNCTION AaMerge
LPARAMETERS lp_cAlias, lp_nAddrIdFrom, lp_nAddrIdTo
 LOCAL l_nArea, l_cOrder, l_nRecNo, l_oAa, l_lFound
 l_nArea = SELECT()
 l_cOrder = ORDER(lp_cAlias)
 SELECT(lp_cAlias)
 SET ORDER TO
 SCAN FOR aa_addrid = lp_nAddrIdFrom
	SCATTER MEMO NAME l_oAa
	AaPlus(lp_cAlias, lp_nAddrIdTo, aa_date, l_oAa)
	DELETE IN (lp_cAlias)
 ENDSCAN
 SET ORDER TO l_cOrder
 SELECT(l_nArea)
ENDFUNC

FUNCTION AaRevenueForecast
LPARAMETERS lp_nAaddrId, lp_nRevSum, lp_nRmsSum, ;
		lp_nRevMEnd, lp_nRmsMEnd, lp_nRevD30, lp_nRmsD30, ;
		lp_nRevYEnd, lp_nRmsYEnd, lp_nRevD365, lp_nRmsD365
 LOCAL l_nArea, l_nRecNo, l_cOrderRs, l_cOrderRt, l_dSys, l_dSysMEnd, l_dSysYEnd, l_dSysD30, l_dSysD365

 l_dSys = SysDate()
 l_dSysMEnd = GetRelDate(l_dSys,"",31)
 l_dSysYEnd = DATE(YEAR(l_dSys), 12, 31)
 l_dSysD30 = GetRelDate(l_dSys,"+1M")
 l_dSysD365 = GetRelDate(l_dSys,"+1Y")
 l_cOrderRs = ORDER("reservat")
 l_cOrderRt = ORDER("roomtype")
 SET ORDER TO Tag33 IN reservat
 SET ORDER TO Tag1 IN roomtype
 SET RELATION TO rl_rsid INTO reservat IN ressplit ADDITIVE
 SET RELATION TO rs_roomtyp INTO roomtype IN reservat ADDITIVE

 SELECT reservat
 SUM rs_rooms * MAX(0,rs_depdate-MAX(rs_arrdate,l_dSys)), ;
 	rs_rooms * MAX(0,MIN(rs_depdate-1,l_dSysMEnd)-MAX(rs_arrdate,l_dSys)+1), ;
 	rs_rooms * MAX(0,MIN(rs_depdate-1,l_dSysD30)-MAX(rs_arrdate,l_dSys)+1), ;
 	rs_rooms * MAX(0,MIN(rs_depdate-1,l_dSysYEnd)-MAX(rs_arrdate,l_dSys)+1), ;
 	rs_rooms * MAX(0,MIN(rs_depdate-1,l_dSysD365)-MAX(rs_arrdate,l_dSys)+1) ;
 	FOR rs_arrdate >= l_dSys AND INLIST(lp_nAaddrId, rs_addrid, rs_compid, rs_agentid) AND ;
 	NOT INLIST(rs_status, "NS", "CXL") AND NOT EMPTY(rs_roomtyp) AND INLIST(roomtype.rt_group, 1, 4) ;
 	TO lp_nRmsSum, lp_nRmsMEnd, lp_nRmsD30, lp_nRmsYEnd, lp_nRmsD365
 SELECT ressplit
 SUM rl_price * rl_units * reservat.rs_rooms, ;
 	rl_price * rl_units * reservat.rs_rooms * IIF(BETWEEN(rl_date, l_dSys, l_dSysMEnd), 1, 0), ;
 	rl_price * rl_units * reservat.rs_rooms * IIF(BETWEEN(rl_date, l_dSys, l_dSysD30), 1, 0), ;
 	rl_price * rl_units * reservat.rs_rooms * IIF(BETWEEN(rl_date, l_dSys, l_dSysYEnd), 1, 0), ;
 	rl_price * rl_units * reservat.rs_rooms * IIF(BETWEEN(rl_date, l_dSys, l_dSysD365), 1, 0) ;
 	FOR rl_date >= l_dSys AND INLIST(lp_nAaddrId, reservat.rs_addrid, reservat.rs_compid, reservat.rs_agentid) AND ;
 	NOT INLIST(reservat.rs_status, "NS", "CXL") AND NOT EMPTY(reservat.rs_roomtyp) AND INLIST(roomtype.rt_group, 1, 4) ;
 	TO lp_nRevSum, lp_nRevMEnd, lp_nRevD30, lp_nRevYEnd, lp_nRevD365

 SET RELATION OFF INTO reservat IN ressplit
 SET RELATION OFF INTO roomtype IN reservat
 SET ORDER TO l_cOrderRs IN reservat
 SET ORDER TO l_cOrderRt IN roomtype
 lp_nRevSum = ROUND(lp_nRevSum, param.pa_currdec)
 lp_nRmsSum = INT(lp_nRmsSum)
 lp_nRevMEnd = ROUND(lp_nRevMEnd, param.pa_currdec)
 lp_nRmsMEnd = INT(lp_nRmsMEnd)
 lp_nRevD30 = ROUND(lp_nRevD30, param.pa_currdec)
 lp_nRmsD30 = INT(lp_nRmsD30)
 lp_nRevYEnd = ROUND(lp_nRevYEnd, param.pa_currdec)
 lp_nRmsYEnd = INT(lp_nRmsYEnd)
 lp_nRevD365 = ROUND(lp_nRevD365, param.pa_currdec)
 lp_nRmsD365 = INT(lp_nRmsD365)
 SELECT(l_nArea)
 * Return 10 parameters by reference
ENDFUNC

FUNCTION HlpSumRevenue
LPARAMETERS lp_dDate, lp_dSys, lp_nRevenue, lp_nRooms, lp_nRevSum, lp_nRmsSum, ;
		lp_nRevMEnd, lp_nRmsMEnd, lp_nRevD30, lp_nRmsD30, ;
		lp_nRevYEnd, lp_nRmsYEnd, lp_nRevD365, lp_nRmsD365
 lp_nRevSum = lp_nRevSum + lp_nRevenue
 lp_nRmsSum = lp_nRmsSum + lp_nRooms
 IF MONTH(lp_dDate) == MONTH(lp_dSys) AND YEAR(lp_dDate) == YEAR(lp_dSys)
	lp_nRevMEnd = lp_nRevMEnd + lp_nRevenue
	lp_nRmsMEnd = lp_nRmsMEnd + lp_nRooms
 ENDIF
 IF lp_dDate < lp_dSys + 30
	lp_nRevD30 = lp_nRevD30 + lp_nRevenue
	lp_nRmsD30 = lp_nRmsD30 + lp_nRooms
 ENDIF
 IF YEAR(lp_dDate) == YEAR(lp_dSys)
	lp_nRevYEnd = lp_nRevYEnd + lp_nRevenue
	lp_nRmsYEnd = lp_nRmsYEnd + lp_nRooms
 ENDIF
 IF lp_dDate < lp_dSys + 365
	lp_nRevD365 = lp_nRevD365 + lp_nRevenue
	lp_nRmsD365 = lp_nRmsD365 + lp_nRooms
 ENDIF
 * Return 10 parameters by reference
ENDFUNC

FUNCTION LsHistUpd
	LOCAL l_nArea

	l_nArea = SELECT()
	SELECT histres
	IF hr_addrid > 0
		LsUpd(hr_addrid, hr_arrdate, hr_depdate, hr_roomtyp, hr_roomnum, hr_rate, hr_ratecod, hr_status, hr_market, hr_source)
	ENDIF
	IF hr_compid > 0 AND hr_compid <> hr_addrid
		LsUpd(hr_compid, hr_arrdate, hr_depdate, hr_roomtyp, hr_roomnum, hr_rate, hr_ratecod, hr_status, hr_market, hr_source)
	ENDIF
	IF hr_agentid > 0 AND hr_agentid <> hr_addrid AND hr_agentid <> hr_compid
		LsUpd(hr_agentid, hr_arrdate, hr_depdate, hr_roomtyp, hr_roomnum, hr_rate, hr_ratecod, hr_status, hr_market, hr_source)
	ENDIF
	SELECT(l_nArea)
ENDFUNC

FUNCTION LsResUpd
	LPARAMETERS lp_reserid
	LOCAL l_nArea, l_recno

	l_nArea = SELECT()
	SELECT reservat
	l_recno = RECNO()
	IF SEEK(lp_reserid, "reservat", "tag1")
		IF rs_addrid > 0
			LsUpd(rs_addrid, rs_arrdate, rs_depdate, rs_roomtyp, rs_roomnum, rs_rate, rs_ratecod, rs_status, rs_market, rs_source)
		ENDIF
		IF rs_compid > 0 AND rs_compid <> rs_addrid
			LsUpd(rs_compid, rs_arrdate, rs_depdate, rs_roomtyp, rs_roomnum, rs_rate, rs_ratecod, rs_status, rs_market, rs_source)
		ENDIF
		IF rs_agentid > 0 AND rs_agentid <> rs_addrid AND rs_agentid <> rs_compid
			LsUpd(rs_agentid, rs_arrdate, rs_depdate, rs_roomtyp, rs_roomnum, rs_rate, rs_ratecod, rs_status, rs_market, rs_source)
		ENDIF
	ENDIF
	GOTO l_recno
	SELECT(l_nArea)
ENDFUNC

FUNCTION LsUpd
	LPARAMETERS lp_addrid, lp_arrdate, lp_depdate, lp_roomtyp, lp_roomnum, lp_rate, lp_ratecod, lp_status, lp_market, lp_source
	LOCAL l_nArea, l_rt_group, l_not_used

	l_nArea = SELECT()
	l_not_used = .F.
	IF NOT USED("rt")
		openfiledirect(.F., "roomtype", "rt")
		l_not_used = .T.
	ENDIF
	l_rt_group = IIF(SEEK(lp_roomtyp, "rt", "tag1"), rt.rt_group, 1)
	
	IF lp_status="OUT" .AND. l_rt_group=1 && old condition was INLIST(lp_status,"IN","OUT")
		IF SEEK(lp_addrid, "laststay", "tag1")
			IF lp_depdate >= laststay.ls_depdate && ??? AND lp_depdate<sysdate()
				REPLACE ls_arrdat  WITH lp_arrdate, ;
						ls_depdate WITH lp_depdate, ;
						ls_roomtyp WITH lp_roomtyp, ;
						ls_roomnum WITH lp_roomnum, ;
						ls_rate    WITH lp_rate, ;
						ls_ratecod WITH lp_ratecod, ;
						ls_market  WITH lp_market, ;
						ls_source  WITH lp_source IN laststay
			ENDIF
		ELSE
			INSERT INTO laststay (ls_addrid, ls_arrdat, ls_depdate, ls_roomtyp, ls_roomnum, ls_rate, ls_ratecod, ls_market, ls_source) ;
				VALUES (lp_addrid, lp_arrdate, lp_depdate, lp_roomtyp, lp_roomnum, lp_rate, lp_ratecod, lp_market, lp_source)
		ENDIF
	ENDIF
	IF l_not_used
		USE IN rt
	ENDIF
	SELECT(l_nArea)
ENDFUNC
*
PROCEDURE AddressStatRevUpdate
LPARAMETERS lp_dForDate
LOCAL i, l_oEnvironment, l_nCase, l_oBefore, l_oAfter, l_nVatValue, l_cIndex, l_cField
LOCAL ARRAY l_aAddress(3,2)
l_oEnvironment = SetEnvironment("astat, histstat, post, histpost, histres, reservat, article")
IF NOT param.pa_audnost
	l_aAddress(1,1) = "rs_addrid"
	l_aAddress(1,2) = ".T."
	l_aAddress(2,1) = "rs_compid"
	l_aAddress(2,2) = "rs_compid <> rs_addrid"
	l_aAddress(3,1) = "rs_agentid"
	l_aAddress(3,2) = "rs_agentid <> rs_addrid AND rs_agentid <> rs_compid"
	SELECT post.*, article.ar_main, reservat.rs_addrid, reservat.rs_compid, reservat.rs_agentid FROM post ;
		LEFT JOIN article ON post.ps_artinum = article.ar_artinum ;
		LEFT JOIN reservat ON post.ps_reserid = reservat.rs_reserid ;
		WHERE ps_date = lp_dForDate AND NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) ;
		INTO CURSOR curPost
	SELECT * FROM astat WHERE aa_date = lp_dForDate ORDER BY aa_addrid INTO CURSOR curAstat
	BLANK FIELDS LIKE aa_0amount, aa_0amt?, aa_0vat? FOR aa_date = lp_dForDate IN astat
	SELECT curPost
	SCAN
		FOR l_nCase = 1 TO ALEN(l_aAddress,1)
			IF NOT ISNULL(EVALUATE("curPost."+l_aAddress(l_nCase,1))) AND EVALUATE("curPost."+l_aAddress(l_nCase,1)) > 0 AND ;
					EVALUATE(l_aAddress(l_nCase,2))
				IF NOT SEEK(PADL(EVALUATE("curPost."+l_aAddress(l_nCase,1)),8,"0")+DTOS(lp_dForDate),"astat","Tag2")
					AaInsert("astat", EVALUATE("curPost."+l_aAddress(l_nCase,1)), lp_dForDate)
					SELECT curPost
				ENDIF
				l_cIndex = IIF(ISNULL(curPost.ar_main), "0", STR(MAX(curPost.ar_main,0),1))
				l_nVatValue = 0
				FOR i = 1 TO 9
					l_nVatValue = l_nVatValue + EVALUATE("curPost.ps_vat" + STR(i,1))
				NEXT
				REPLACE aa_0amount WITH astat.aa_0amount + curPost.ps_amount IN astat
				l_cField = "aa_0amt" + l_cIndex
				REPLACE &l_cField WITH astat.&l_cField + curPost.ps_amount IN astat
				l_cField = "aa_0vat" + l_cIndex
				REPLACE &l_cField WITH astat.&l_cField + l_nVatValue IN astat
			ENDIF
		NEXT
	ENDSCAN
	USE IN curPost
	SET ORDER TO Tag2 IN astat
	SELECT curAstat
	SCAN
		SCATTER NAME l_oBefore
		= SEEK(PADL(l_oBefore.aa_addrid,8,"0")+DTOS(l_oBefore.aa_date),"astat","Tag2")
		SELECT astat
		SCATTER NAME l_oAfter
		REPLACE aa_camount WITH aa_camount - l_oBefore.aa_0amount + l_oAfter.aa_0amount, ;
				aa_camt0 WITH aa_camt0 - l_oBefore.aa_0amt0 + l_oAfter.aa_0amt0, ;
				aa_camt1 WITH aa_camt1 - l_oBefore.aa_0amt1 + l_oAfter.aa_0amt1, ;
				aa_camt2 WITH aa_camt2 - l_oBefore.aa_0amt2 + l_oAfter.aa_0amt2, ;
				aa_camt3 WITH aa_camt3 - l_oBefore.aa_0amt3 + l_oAfter.aa_0amt3, ;
				aa_camt4 WITH aa_camt4 - l_oBefore.aa_0amt4 + l_oAfter.aa_0amt4, ;
				aa_camt5 WITH aa_camt5 - l_oBefore.aa_0amt5 + l_oAfter.aa_0amt5, ;
				aa_camt6 WITH aa_camt6 - l_oBefore.aa_0amt6 + l_oAfter.aa_0amt6, ;
				aa_camt7 WITH aa_camt7 - l_oBefore.aa_0amt7 + l_oAfter.aa_0amt7, ;
				aa_camt8 WITH aa_camt8 - l_oBefore.aa_0amt8 + l_oAfter.aa_0amt8, ;
				aa_camt9 WITH aa_camt9 - l_oBefore.aa_0amt9 + l_oAfter.aa_0amt9, ;
				aa_cvat0 WITH aa_cvat0 - l_oBefore.aa_0vat0 + l_oAfter.aa_0vat0, ;
				aa_cvat1 WITH aa_cvat1 - l_oBefore.aa_0vat1 + l_oAfter.aa_0vat1, ;
				aa_cvat2 WITH aa_cvat2 - l_oBefore.aa_0vat2 + l_oAfter.aa_0vat2, ;
				aa_cvat3 WITH aa_cvat3 - l_oBefore.aa_0vat3 + l_oAfter.aa_0vat3, ;
				aa_cvat4 WITH aa_cvat4 - l_oBefore.aa_0vat4 + l_oAfter.aa_0vat4, ;
				aa_cvat5 WITH aa_cvat5 - l_oBefore.aa_0vat5 + l_oAfter.aa_0vat5, ;
				aa_cvat6 WITH aa_cvat6 - l_oBefore.aa_0vat6 + l_oAfter.aa_0vat6, ;
				aa_cvat7 WITH aa_cvat7 - l_oBefore.aa_0vat7 + l_oAfter.aa_0vat7, ;
				aa_cvat8 WITH aa_cvat8 - l_oBefore.aa_0vat8 + l_oAfter.aa_0vat8, ;
				aa_cvat9 WITH aa_cvat9 - l_oBefore.aa_0vat9 + l_oAfter.aa_0vat9 ;
			FOR aa_date >= l_oBefore.aa_date ;
			WHILE aa_addrid = l_oBefore.aa_addrid AND YEAR(aa_date) = YEAR(l_oBefore.aa_date) IN astat
		SELECT curAstat
	ENDSCAN
	USE IN curAstat
ENDIF
l_aAddress(1,1) = "hr_addrid"
l_aAddress(1,2) = ".T."
l_aAddress(2,1) = "hr_compid"
l_aAddress(2,2) = "hr_compid <> hr_addrid"
l_aAddress(3,1) = "hr_agentid"
l_aAddress(3,2) = "hr_agentid <> hr_addrid AND hr_agentid <> hr_compid"
SELECT histpost.*, article.ar_main, histres.hr_addrid, histres.hr_compid, histres.hr_agentid FROM histpost ;
	LEFT JOIN article ON histpost.hp_artinum = article.ar_artinum ;
	LEFT JOIN histres ON histpost.hp_reserid = histres.hr_reserid ;
	WHERE hp_date = lp_dForDate AND NOT SEEK(histpost.hp_postid,"post","Tag3") AND ;
	NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) INTO CURSOR curPost
SELECT * FROM histstat WHERE aa_date = lp_dForDate ORDER BY aa_addrid INTO CURSOR curAstat
BLANK FIELDS LIKE aa_0amount, aa_0amt?, aa_0vat? FOR aa_date = lp_dForDate IN histstat
SELECT curPost
SCAN
	FOR l_nCase = 1 TO ALEN(l_aAddress,1)
		IF NOT ISNULL(EVALUATE("curPost."+l_aAddress(l_nCase,1))) AND EVALUATE("curPost."+l_aAddress(l_nCase,1)) > 0 AND ;
				EVALUATE(l_aAddress(l_nCase,2))
			IF NOT SEEK(PADL(EVALUATE("curPost."+l_aAddress(l_nCase,1)),8,"0")+DTOS(lp_dForDate),"histstat","Tag2")
				AaInsert("histstat", EVALUATE("curPost."+l_aAddress(l_nCase,1)), lp_dForDate)
				SELECT curPost
			ENDIF
			l_cIndex = IIF(ISNULL(curPost.ar_main), "0", STR(MAX(curPost.ar_main,0),1))
			l_nVatValue = 0
			FOR i = 1 TO 9
				l_nVatValue = l_nVatValue + EVALUATE("curPost.hp_vat" + STR(i,1))
			NEXT
			REPLACE aa_0amount WITH histstat.aa_0amount + curPost.hp_amount IN histstat
			l_cField = "aa_0amt" + l_cIndex
			REPLACE &l_cField WITH histstat.&l_cField + curPost.hp_amount IN histstat
			l_cField = "aa_0vat" + l_cIndex
			REPLACE &l_cField WITH histstat.&l_cField + l_nVatValue IN histstat
		ENDIF
	NEXT
ENDSCAN
USE IN curPost
SET ORDER TO Tag2 IN histstat
SELECT curAstat
SCAN
	SCATTER NAME l_oBefore
	= SEEK(PADL(l_oBefore.aa_addrid,8,"0")+DTOS(l_oBefore.aa_date),"histstat","Tag2")
	SELECT histstat
	SCATTER NAME l_oAfter
	REPLACE aa_camount WITH aa_camount - l_oBefore.aa_0amount + l_oAfter.aa_0amount, ;
			aa_camt0 WITH aa_camt0 - l_oBefore.aa_0amt0 + l_oAfter.aa_0amt0, ;
			aa_camt1 WITH aa_camt1 - l_oBefore.aa_0amt1 + l_oAfter.aa_0amt1, ;
			aa_camt2 WITH aa_camt2 - l_oBefore.aa_0amt2 + l_oAfter.aa_0amt2, ;
			aa_camt3 WITH aa_camt3 - l_oBefore.aa_0amt3 + l_oAfter.aa_0amt3, ;
			aa_camt4 WITH aa_camt4 - l_oBefore.aa_0amt4 + l_oAfter.aa_0amt4, ;
			aa_camt5 WITH aa_camt5 - l_oBefore.aa_0amt5 + l_oAfter.aa_0amt5, ;
			aa_camt6 WITH aa_camt6 - l_oBefore.aa_0amt6 + l_oAfter.aa_0amt6, ;
			aa_camt7 WITH aa_camt7 - l_oBefore.aa_0amt7 + l_oAfter.aa_0amt7, ;
			aa_camt8 WITH aa_camt8 - l_oBefore.aa_0amt8 + l_oAfter.aa_0amt8, ;
			aa_camt9 WITH aa_camt9 - l_oBefore.aa_0amt9 + l_oAfter.aa_0amt9, ;
			aa_cvat0 WITH aa_cvat0 - l_oBefore.aa_0vat0 + l_oAfter.aa_0vat0, ;
			aa_cvat1 WITH aa_cvat1 - l_oBefore.aa_0vat1 + l_oAfter.aa_0vat1, ;
			aa_cvat2 WITH aa_cvat2 - l_oBefore.aa_0vat2 + l_oAfter.aa_0vat2, ;
			aa_cvat3 WITH aa_cvat3 - l_oBefore.aa_0vat3 + l_oAfter.aa_0vat3, ;
			aa_cvat4 WITH aa_cvat4 - l_oBefore.aa_0vat4 + l_oAfter.aa_0vat4, ;
			aa_cvat5 WITH aa_cvat5 - l_oBefore.aa_0vat5 + l_oAfter.aa_0vat5, ;
			aa_cvat6 WITH aa_cvat6 - l_oBefore.aa_0vat6 + l_oAfter.aa_0vat6, ;
			aa_cvat7 WITH aa_cvat7 - l_oBefore.aa_0vat7 + l_oAfter.aa_0vat7, ;
			aa_cvat8 WITH aa_cvat8 - l_oBefore.aa_0vat8 + l_oAfter.aa_0vat8, ;
			aa_cvat9 WITH aa_cvat9 - l_oBefore.aa_0vat9 + l_oAfter.aa_0vat9 ;
		FOR aa_date >= l_oBefore.aa_date ;
		WHILE aa_addrid = l_oBefore.aa_addrid AND YEAR(aa_date) = YEAR(l_oBefore.aa_date) IN histstat
	SELECT curAstat
ENDSCAN
USE IN curAstat
ENDPROC
*
PROCEDURE RemoveReservation
LPARAMETERS lp_nReserId, lp_lInHistory
LOCAL l_oEnvironment, l_cAlias
l_cAlias = IIF(lp_lInHistory, "histstat", "astat")
l_oEnvironment = SetEnvironment(l_cAlias + ", histres, hresroom, hresrate, roomtype, room", "tag1")
IF DLocate("histres", "hr_reserid = " + SqlCnv(lp_nReserId))
	AaHistRs(l_cAlias, histres.hr_arrdate, .T.)
ENDIF
ENDPROC
*