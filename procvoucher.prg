 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
			lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal
 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO PCOUNT()-1
	l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"
 l_uRetVal = &l_cCallProc
 RETURN l_uRetVal
ENDFUNC
*
PROCEDURE VoucherCreate
LPARAMETERS lp_cPostAlias, lp_lAddrCalc, lp_nVoucherNumber
 LOCAL l_lCloseVoucher, l_nArea, l_nAddrId, l_nFor
 IF PCOUNT() == 0
	lp_cPostAlias = "post"
 ENDIF
 IF NOT USED("voucher")
	OpenFileDirect(.F.,"voucher")
	IF NOT USED("voucher")
		lp_nVoucherNumber = 0
		RETURN 0
	ENDIF
	l_lCloseVoucher = .T.
 ELSE
	l_lCloseVoucher = .F.
 ENDIF
 l_nArea = SELECT()
 SELECT(lp_cPostAlias)
 IF lp_lAddrCalc
	DO BillAddrId WITH l_nWindow, l_nAddrId
 ELSE
	l_nAddrId = ps_addrid
 ENDIF
 FOR l_nFor = 1 TO ps_units
	= SEEK(ps_artinum,"article","tag1")
	APPEND BLANK IN voucher
	REPLACE vo_addrid  WITH l_nAddrId, ;
			vo_amount  WITH (ps_amount/ps_units), ;
			vo_artinum WITH ps_artinum, ;
			vo_copy    WITH 0, ;
			vo_created WITH sysdate(), ;
			vo_date    WITH sysdate(), ;
			vo_descrip WITH EVALUATE("article.ar_lang"+g_Langnum), ;
			vo_number  WITH uniquenumber(), ;
			vo_unused  WITH (ps_amount/ps_units), ;
			vo_userid  WITH ps_userid ;
		IN voucher
	IF NOT param.pa_vounoex
		REPLACE vo_expdate WITH expires(sysdate(),article.ar_expire) ;
				IN voucher
	ENDIF
	*vo_station WITH wiNpc(), vo_time WITH TIME(),
 ENDFOR
 lp_nVoucherNumber = voucher.vo_number
 IF l_lCloseVoucher
	USE IN voucher
 ENDIF
 SELECT(l_nArea)
 RETURN lp_nVoucherNumber
ENDPROC
*
PROCEDURE VoucherCancel
LPARAMETERS lp_nVoucherNumber
LOCAL l_nArea, l_cError, l_lCloseVoucher

 IF EMPTY(lp_nVoucherNumber)
	RETURN .F.
 ENDIF

 l_nArea = SELECT()

 IF NOT USED("voucher")
	OpenFileDirect(.F.,"voucher")
	IF NOT USED("voucher")
		RETURN .F.
	ENDIF
	l_lCloseVoucher = .T.
 ENDIF
 IF NOT SEEK(lp_nVoucherNumber,"voucher","tag11")
	l_cError = GetLangText("VOUCHER","TXT_UNKNOWN")
 ELSE
	IF voucher.vo_amount <> voucher.vo_unused
		l_cError = GetLangText("VOUCHER","TXT_VOUCHER_ALREADY_USED")
	ELSE
		REPLACE vo_amount WITH 0, vo_unused WITH 0 IN voucher
	ENDIF
 ENDIF
 IF NOT EMPTY(l_cError)
	= alert(l_cError,GetLangText("VOUCHER","TXT_VOUCHER"))
 ENDIF
 IF l_lCloseVoucher
	USE IN voucher
 ENDIF
 SELECT(l_nArea)

 RETURN .T.
ENDPROC
*
PROCEDURE VoucherUse
LPARAMETERS lp_nAmount, lp_cVoucherNumber, lp_lNoReplace
 LOCAL l_lCloseVoucher, l_nArea, l_cError, l_lVoucherDebitorPaied, l_nVNum
 IF lp_nAmount <= 0
	lp_cVoucherNumber = ""
	RETURN ""
 ENDIF
 IF NOT USED("voucher")
	OpenFileDirect(.F.,"voucher")
	IF NOT USED("voucher")
		lp_cVoucherNumber = ""
		RETURN ""
	ENDIF
	l_lCloseVoucher = .T.
 ELSE
	l_lCloseVoucher = .F.
 ENDIF
 OpenFileDirect(,"extvouch")
 l_nArea = SELECT()
 IF EMPTY(lp_cVoucherNumber)
	DO FORM "forms\certifnumform" TO lp_cVoucherNumber
 ENDIF
 lp_cVoucherNumber = PADL(ALLTRIM(lp_cVoucherNumber),12)
 l_cError = ""
 IF NOT SEEK(LEFT(lp_cVoucherNumber,10),"voucher","tag3")
	l_cError = GetLangText("VOUCHER","TXT_UNKNOWN")
 ELSE
	IF voucher.vo_copy <> VAL(RIGHT(lp_cVoucherNumber,2))
		l_cError = GetLangText("VOUCHER","TXT_SEQUENCE_ERROR")
	ELSE
		IF (voucher.vo_expdate <= sysdate()) AND NOT param.pa_vounoex
			l_cError = GetLangText("VOUCHER","TXT_EXPIRED")
		ELSE
			IF voucher.vo_amount = voucher.vo_unused && Check only for new vouchers.
				l_nVNum = INT(VAL(LEFT(lp_cVoucherNumber,10)))
				l_lVoucherDebitorPaied = VaucherCheckDebitForOne(l_nVNum)
			ELSE
				l_lVoucherDebitorPaied = .T.
			ENDIF
			
			IF NOT l_lVoucherDebitorPaied
				l_cError = GetLangText("VOUCHER","TXT_VOUCHER_NOT_PAIED_YET")
			ELSE
				DO CASE
				 CASE voucher.vo_unused >= lp_nAmount
					IF EMPTY(lp_lNoReplace)
						REPLACE vo_unused WITH voucher.vo_unused - lp_nAmount IN voucher
					ENDIF
				 CASE voucher.vo_unused > 0
					lp_nAmount = voucher.vo_unused
					IF EMPTY(lp_lNoReplace)
						REPLACE vo_unused WITH 0 IN voucher
					ENDIF
				 OTHERWISE && voucher.vo_unused = 0
					l_cError = GetLangText("VOUCHER","TXT_AMOUNT_IS_ZERO")
				ENDCASE
			ENDIF
		ENDIF
	ENDIF
 ENDIF
 IF NOT EMPTY(l_cError)
	= alert(l_cError,GetLangText("VOUCHER","TXT_VOUCHER"))
	lp_cVoucherNumber = ""
	lp_nAmount = 0
 ENDIF
 IF l_lCloseVoucher
	USE IN voucher
 ENDIF
 SELECT(l_nArea)
 RETURN lp_cVoucherNumber
ENDPROC
*
PROCEDURE VoucherRevenueUse
LPARAMETERS lp_aVatAmount, lp_cVoucherNumber
EXTERNAL ARRAY lp_aVatAmount
LOCAL l_lCloseVoucher, l_nArea

l_nArea = SELECT()

IF NOT USED("voucher")
	OpenFileDirect(.F.,"voucher")
	IF NOT USED("voucher")
		RETURN lp_cVoucherNumber
	ENDIF
	l_lCloseVoucher = .T.
ENDIF

IF EMPTY(lp_cVoucherNumber)
	DO FORM "Forms\CertifnumForm" TO l_cVoucherNumber
ELSE
	l_cVoucherNumber = lp_cVoucherNumber
ENDIF
l_cVoucherNumber = PADL(ALLTRIM(l_cVoucherNumber),12)
lp_cVoucherNumber = ""

DO CASE
	CASE EMPTY(l_cVoucherNumber)
	CASE NOT SEEK(LEFT(l_cVoucherNumber,10),"voucher","tag3")
		Alert(GetLangText("VOUCHER","TXT_UNKNOWN"),GetLangText("VOUCHER","TXT_VOUCHER"))
	CASE voucher.vo_copy <> VAL(RIGHT(l_cVoucherNumber,2))
		Alert(GetLangText("VOUCHER","TXT_SEQUENCE_ERROR"),GetLangText("VOUCHER","TXT_VOUCHER"))
	CASE voucher.vo_expdate <= SysDate() AND NOT _screen.oglobal.oparam.pa_vounoex
		Alert(GetLangText("VOUCHER","TXT_EXPIRED"),GetLangText("VOUCHER","TXT_VOUCHER"))
	CASE voucher.vo_amount = voucher.vo_unused AND NOT VaucherCheckDebitForOne(INT(VAL(LEFT(l_cVoucherNumber,10)))) && Check only for new vouchers.
		Alert(GetLangText("VOUCHER","TXT_VOUCHER_NOT_PAIED_YET"),GetLangText("VOUCHER","TXT_VOUCHER"))
	CASE voucher.vo_unused <= 0
		Alert(GetLangText("VOUCHER","TXT_AMOUNT_IS_ZERO"),GetLangText("VOUCHER","TXT_VOUCHER"))
	OTHERWISE
		l_nRow = ASCAN(lp_aVatAmount,voucher.vo_vatval,1,0,1,8)
		IF l_nRow > 0
			lp_cVoucherNumber = l_cVoucherNumber
		ELSE
			Alert(Str2Msg(GetLangText("VOUCHER","TXT_NOVATARTICLE"),"%s",TRANSFORM(voucher.vo_vatval, "99.99%")),GetLangText("VOUCHER","TXT_VOUCHER"))
		ENDIF
ENDCASE

IF l_lCloseVoucher
	DClose("voucher")
ENDIF

SELECT(l_nArea)

RETURN lp_cVoucherNumber
ENDPROC
*
PROCEDURE VoucherPrint
LPARAMETERS lp_cVoucherNumber, lp_lIncrement
 LOCAL l_lCloseVoucher, l_lFound
 IF NOT USED("voucher")
	OpenFileDirect(.F.,"voucher")
	IF NOT USED("voucher")
		RETURN .F.
	ENDIF
	l_lCloseVoucher = .T.
 ELSE
	l_lCloseVoucher = .F.
 ENDIF
 lp_cVoucherNumber = PADL(ALLTRIM(lp_cVoucherNumber),12)
 IF NOT EMPTY(lp_cVoucherNumber)
	IF SEEK(LEFT(lp_cVoucherNumber,10),"voucher","tag3") ;
			AND (voucher.vo_copy = VAL(RIGHT(lp_cVoucherNumber,2)))
		l_lFound = .T.
	ELSE
		l_lFound = .F.
	ENDIF
 ELSE
	l_lFound = .T.
 ENDIF
 IF l_lFound AND (voucher.vo_unused > 0)
	= SEEK(voucher.vo_artinum,"article","tag1")
	DO PrintVoucher IN voucher WITH ALLTRIM(UPPER(article.ar_layout))
	IF lp_lIncrement
		REPLACE vo_copy WITH voucher.vo_copy + 1 IN voucher
	ENDIF
 ENDIF
 IF l_lCloseVoucher
	USE IN voucher
 ENDIF
ENDPROC
*
FUNCTION Expires
 PARAMETER ddAte, nvAlue
 * SAME FUNCTION EXISTS IN VOUCHER.PRG
 PRIVATE deXpdate
 PRIVATE ni
 deXpdate = ddAte
 IF (paRam.pa_vouexpm)
	FOR ni = 1 TO nvAlue
		deXpdate = adDonemonth(deXpdate)
	ENDFOR
 ELSE
	deXpdate = ddAte+nvAlue
 ENDIF
 RETURN deXpdate
ENDFUNC
*
PROCEDURE VouchersNew
 LOCAL l_nAddrId, l_frmPasserby
 IF VARTYPE(_screen.oglobal.oExtVouchersData)="O"
	l_nAddrId = _screen.oglobal.oExtVouchersData.naddrid
 ELSE
	l_nAddrId = 0
 ENDIF
* DO FORM forms\addressbrowse WITH 0, "ADDRESS" TO l_nAddrId
* IF NOT EMPTY(l_nAddrId)
*	GO l_nAddrId IN address
*	l_nAddrId = address.ad_addrid
* ENDIF
 DO FORM "forms\passerby" NAME l_frmPasserby LINKED ;
		WITH "VOUCH", l_nAddrId, 0
 RETURN .T.
ENDPROC
*
PROCEDURE VauchersDelete
LPARAMETERS lp_lResult
 IF voucher.vo_unused <= 0
	* Return result through parameter by reference
	lp_lResult = .F.
	RETURN .F.
 ENDIF
 LOCAL l_nWindow, l_cVouchId, l_lResult, l_nPaynum
 l_nWindow = 1
 l_cVouchId = STR(voucher.vo_number,10)+STR(voucher.vo_copy,2)
 * Create tblPostCursor
 DO CursorPostPayCreate IN ProcBill WITH .T.
 * Call form for pay.
 DO FORM "forms/postpay" ;
		WITH "VOUCH_DELETE", l_nWindow, voucher.vo_addrid, 0, l_cVouchId ;
		TO l_lResult
 IF l_lResult AND SEEK(l_cVouchId,"voucher","tag3")
	REPLACE vo_amount WITH voucher.vo_amount-voucher.vo_unused IN voucher
	REPLACE vo_unused WITH 0 IN voucher
 ENDIF

 IF l_lResult AND Yesno(GetLangText("PASSERBY","TA_PRINTBILL")+"?")
	* Create cursor Query
	DO CursorPrintBillCreate WITH "query"
	SELECT query
	SET RELATION TO query.ps_artinum INTO article
	SET RELATION TO query.ps_paynum INTO paymetho ADDITIVE
	APPEND FROM DBF("tblPostCursor") FOR ps_paynum > 0
	DELETE FOR ps_paynum > 0 IN tblPostCursor
	GO TOP IN tblPostCursor
	* Prepare for print.
	_screen.oGlobal.oBill.nAddrId = voucher.vo_addrid
	IF FPBillPrinted("PASSERBY")
		g_Billnum = getbill(.T.,,.T.,,0.1, voucher.vo_addrid, -tblPostCursor.ps_amount, "PASSERBY", 1)
	ELSE
		g_Billnum = ""
	ENDIF
	IF NOT EMPTY(g_Billnum)
		DO PBSetBillType IN prntbill
		g_Billname = ''
		g_dBillDate = SysDate()
		SELECT query
		SCAN
			* Update ps_addrid in Post and Query!
			REPLACE ps_addrid WITH voucher.vo_addrid
			IF SEEK(query.ps_postid,"post","tag3")
				REPLACE ps_addrid WITH voucher.vo_addrid, ps_billnum WITH g_Billnum IN post
				IF ps_paynum > 0
					REPLACE ps_ifc WITH g_Billnum IN post
				ENDIF
			ENDIF
			* Udate Query for printing.
			IF ps_paynum > 0
				REPLACE ps_ifc WITH g_Billnum, ps_billnum WITH g_Billnum
				l_nPaynum = ps_paynum
			ENDIF
			IF ps_artinum>0
				IF param.pa_currloc<>0
					REPLACE ps_local WITH inlocal(ps_amount)
				ELSE
					REPLACE ps_euro WITH euro(ps_amount)
				ENDIF
			ENDIF
		ENDSCAN
		GOTO TOP
		= BillNumChange(g_Billnum, "CHKOUT", "Print",l_nPaynum)
		l_lResult = PasserbyProcessCommit()
		IF l_lResult
			* Print.
			= SetPassBillStyle(0)
			DO printpassbill IN passerby WITH 1
		ENDIF
	ENDIF
 ENDIF
 * Close Query
 dclose("query")
 * Close tblPostCursor
 dclose("tblPostCursor")
 * Return result through parameter by reference
 lp_lResult = l_lResult
 RETURN l_lResult
ENDPROC
*
FUNCTION VaucherTblCreate
LPARAMETERS lp_cVouchAlias, lp_cWhereClause, lp_cOrderClause, lp_lIndex, lp_lSkipVaucherMarkDebit
 IF NOT EMPTY(lp_cOrderClause)
	lp_cOrderClause = "ORDER BY " + lp_cOrderClause
 ENDIF
*!*	 SELECT *, 0 AS c_notpaid FROM voucher ;
*!*			LEFT JOIN address ON voucher.vo_addrid=address.ad_addrid ;
*!*			LEFT JOIN post ON post.ps_postid = voucher.vo_postid ;
*!*			LEFT JOIN histpost ON histpost.hp_postid = voucher.vo_postid ;
*!*			WHERE &lp_cWhereClause &lp_cOrderClause ;
*!*			INTO CURSOR &lp_cVouchAlias READWRITE
 SELECT vo_expdate, vo_created, vo_descrip, vo_amount, vo_unused, vo_number, vo_copy, vo_note, vo_vat, vo_vatdesc, vo_vatval, vo_addrid, vo_postid, vo_veid, ;
	ad_addrid , ad_lname, CAST('' AS Char(25)) AS ps_supplem, CAST('' AS Char(25)) AS hp_supplem, CAST(NVL(ve_vouchno,"") AS Char(10)) AS ve_vouchno, ;
	0 AS c_notpaid, .F. AS c_npcalc FROM voucher ;
	LEFT JOIN address ON vo_addrid > 0 AND voucher.vo_addrid = address.ad_addrid ;
	LEFT JOIN extvouch ON voucher.vo_veid = extvouch.ve_veid ;
	WHERE &lp_cWhereClause AND vo_amount > 0 &lp_cOrderClause ;
	INTO CURSOR &lp_cVouchAlias READWRITE
 SCAN FOR vo_postid > 0
	IF SEEK(vo_postid,"post","tag3") AND NOT EMPTY(post.ps_supplem)
		REPLACE ps_supplem WITH post.ps_supplem IN &lp_cVouchAlias
	ELSE
		IF SEEK(vo_postid,"histpost","tag3") AND NOT EMPTY(histpost.hp_supplem)
			REPLACE hp_supplem WITH histpost.hp_supplem IN &lp_cVouchAlias
		ENDIF
	ENDIF
 ENDSCAN
 IF NOT lp_lSkipVaucherMarkDebit
	 VaucherMarkDebit(lp_cVouchAlias)
 ENDIF
 IF lp_lIndex
	INDEX ON STR(vo_number,10)+STR(vo_copy,2) TAG tag3
	INDEX ON DTOS(vo_expdate) TAG tag5
	INDEX ON UPPER(vo_descrip) TAG tag8
	INDEX ON DTOS(vo_created) TAG tag9
	*INDEX ON STR(vo_unused,12,2) TAG tag10
	*INDEX ON STR(vo_amount,12,2) TAG tag_a
	*INDEX ON ad_lname TAG tag_b
	SET ORDER TO
 ENDIF
ENDFUNC
*
FUNCTION VaucherFilter
LPARAMETERS lp_cVouchNumber, lp_dPurchDate, lp_dExpDate, lp_cDescript, ;
			lp_nMinUnused, lp_nAmount, lp_lUnPrinted, ;
			lp_cLName, lp_lExact, lp_cVouchAlias
 LOCAL l_cWhereClause, l_cSearchNum, l_cZero
 l_cWhereClause = ".T."
 IF NOT EMPTY(lp_cVouchNumber)
	l_cWhereClause = "STR(vo_number,10)+STR(vo_copy,2) = " + ;
			"'" + SUBSTR(PADL(ALLTRIM(lp_cVouchNumber),12),1,10) + ;
			STR(VAL(RIGHT(ALLTRIM(lp_cVouchNumber),2)),2) + "'"
 ENDIF
 IF NOT EMPTY(lp_dPurchDate)
	l_cWhereClause = IIF(EMPTY(l_cWhereClause),"",l_cWhereClause+" AND ") + ;
			"DTOS(vo_created)=" + "'" + DTOS(lp_dPurchDate) + "'"
 ENDIF
 IF NOT EMPTY(lp_dExpDate)
	l_cWhereClause = IIF(EMPTY(l_cWhereClause),"",l_cWhereClause+" AND ") + ;
			"DTOS(vo_expdate)=" + "'" + DTOS(lp_dExpDate) + "'"
 ENDIF
 IF NOT EMPTY(lp_cDescript)
	l_cWhereClause = IIF(EMPTY(l_cWhereClause),"",l_cWhereClause+" AND ") + ;
			"UPPER(vo_descrip)=" + "'" + UPPER(lp_cDescript) + "'"
 ENDIF
 IF NOT EMPTY(lp_lUnPrinted)
	l_cWhereClause = IIF(EMPTY(l_cWhereClause),"",l_cWhereClause+" AND ") + ;
			"STR(voucher.vo_copy,2)=' 0'"
 ENDIF
 IF NOT EMPTY(lp_nMinUnused)
	l_cWhereClause = IIF(EMPTY(l_cWhereClause),"",l_cWhereClause+" AND ") + ;
			"STR(voucher.vo_unused,12,2)>=" + "'" + STR(lp_nMinUnused,12,2) + "'"
 ENDIF
 IF NOT EMPTY(lp_nAmount)
	l_cWhereClause = IIF(EMPTY(l_cWhereClause),"",l_cWhereClause+" AND ") + ;
			"voucher.vo_amount = " + sqlcnv(lp_nAmount)
 ENDIF
 IF NOT EMPTY(lp_cLName)
	l_cWhereClause = IIF(EMPTY(l_cWhereClause),"",l_cWhereClause+" AND ") + ;
			"voucher.vo_addrid IN (" + ;
			"SELECT ad_addrid AS vo_addrid FROM address " + ;
			"WHERE UPPER(ad_lname)+UPPER(ad_fname)+UPPER(ad_city) = " + ;
			"'" + UPPER(ALLTRIM(lp_cLName)) + "')"
	IF lp_lExact
		l_cWhereClause = l_cWhereClause + ;
				" AND UPPER(ad_lname)==" + "'" + ;
				UPPER(lp_cLName) + "'"
	ENDIF
 ENDIF
 IF EMPTY(lp_cVouchAlias)
	lp_cVouchAlias = "tblFilterVoucher"
 ENDIF
 VaucherTblCreate(lp_cVouchAlias, l_cWhereClause, "", .F., .T.)
 RETURN lp_cVouchAlias
ENDFUNC
*
FUNCTION VaucherSearch
LPARAMETERS lp_cVouchAlias, lp_cVouchNumber, ;
			lp_dPurchDate, lp_dExpDate, lp_cDescript
 LOCAL l_cForClause, l_cOrder, l_nRecNo, l_nArea
 l_cForClause = ".T."
 l_cOrder = ORDER(lp_cVouchAlias)
 IF NOT EMPTY(lp_cVouchNumber)
	l_cForClause = "STR(vo_number,10)+STR(vo_copy,2) = " + ;
			"'" + SUBSTR(PADL(ALLTRIM(lp_cVouchNumber),12),1,10) + ;
			STR(VAL(RIGHT(ALLTRIM(lp_cVouchNumber),2)),2) + "'"
	l_cOrder = "tag3"
 ENDIF
 IF NOT EMPTY(lp_dPurchDate)
	l_cForClause = IIF(EMPTY(l_cForClause),"",l_cForClause+" AND ") + ;
			"DTOS(vo_created) = DTOS(lp_dPurchDate)"
	l_cOrder = "tag9"
 ENDIF
 IF NOT EMPTY(lp_dExpDate)
	l_cForClause = IIF(EMPTY(l_cForClause),"",l_cForClause+" AND ") + ;
			"DTOS(vo_expdate) = DTOS(lp_dExpDate)"
	l_cOrder = "tag5"
 ENDIF
 IF NOT EMPTY(lp_cDescript)
	l_cForClause = IIF(EMPTY(l_cForClause),"",l_cForClause+" AND ") + ;
			"UPPER(vo_descrip) = UPPER(ALLTRIM(lp_cDescript))"
	l_cOrder = "tag8"
 ENDIF
 l_nRecNo = RECNO(lp_cVouchAlias)
 l_nArea = SELECT()
 SELECT(lp_cVouchAlias)
 SET ORDER TO
 LOCATE FOR &l_cForClause
 SET ORDER TO l_cOrder
 SELECT(l_nArea)
 IF NOT FOUND(lp_cVouchAlias)
	= alert(GetLangText("VOUCHER","TXT_NOTFOUND"),GetLangText("VOUCHER","TXT_VOSEARCH"))
	GOTO l_nRecNo IN &lp_cVouchAlias
	RETURN .F.
 ELSE
	RETURN .T.
 ENDIF
ENDFUNC
*
PROCEDURE VaucherMarkDebit
* Check is voucher paied with debitor paytype
 LPARAMETERS lp_cCurAlias
 LOCAL l_nVNum, l_lVoucherDebitorPaied, l_nSelect
 IF _screen.oglobal.oparam2.pa_vodebch AND NOT EMPTY(lp_cCurAlias)
	l_nSelect = SELECT()
	SELECT (lp_cCurAlias)
	SCAN FOR vo_amount = vo_unused
		* Check only for new vouchers.
		l_lVoucherDebitorPaied = VaucherCheckDebitForOne(vo_number)
		IF NOT l_lVoucherDebitorPaied
			REPLACE c_notpaid WITH 1
		ENDIF
	ENDSCAN
	SELECT (l_nSelect)
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE VaucherCheckDebitForOne
* Check is voucher paied with debitor paytype
 LPARAMETERS lp_nVouchNum
 LOCAL l_nVNum, l_lVoucherDebitorPaied, l_nSelect
 l_lVoucherDebitorPaied = .T.
 IF _screen.oglobal.oparam2.pa_vodebch
	l_nSelect = SELECT()
	IF NOT EMPTY(lp_nVouchNum)
		l_nVNum = lp_nVouchNum
		= openfiledirect(.F.,"histpost")
		= openfiledirect(.F.,"paymetho")
		SELECT c1.vo_number, h2.hp_billnum FROM ( ;
				SELECT vo_number, h1.hp_billnum ;
				FROM voucher ;
				INNER JOIN histpost h1 ON vo_number = h1.hp_voucnum AND h1.hp_artinum>0 AND h1.hp_billnum <> ' ' ;
			) c1 ;
			INNER JOIN histpost h2 ON c1.hp_billnum = h2.hp_billnum AND h2.hp_paynum > 0 ;
			INNER JOIN paymetho ON h2.hp_paynum = pm_paynum AND pm_paytyp = 4 ;
			WHERE vo_number = l_nVNum ;
			INTO CURSOR curledgdeppaycheck
		IF RECCOUNT()=0
			= openfiledirect(.F.,"post")
			SELECT vo_number, p2.ps_billnum AS hp_billnum FROM (;
				SELECT vo_number, p1.ps_billnum  ;
				FROM voucher ;
				INNER JOIN post p1 ON vo_number = p1.ps_voucnum AND p1.ps_artinum>0 AND p1.ps_billnum <> ' ' ;
				) c1 ;
				INNER JOIN post p2 ON c1.ps_billnum = p2.ps_billnum AND p2.ps_paynum > 0 ;
				INNER JOIN paymetho ON p2.ps_paynum = pm_paynum AND pm_paytyp = 4 ;
				WHERE vo_number = l_nVNum ;
				INTO CURSOR curledgdeppaycheckpost
				IF RECCOUNT()>0
					* Postings not yet transfered in audit into ledger tables. But mark voucher 
					* as not paied.
					l_lVoucherDebitorPaied = .F.
				ENDIF
				dclose("curledgdeppaycheckpost")
				SELECT curledgdeppaycheck
		ENDIF
		IF RECCOUNT()>0
			IF _screen.DV
				= openfiledirect(.F.,"arpost")
				SELECT SUM(ap2.ap_debit- ap2.ap_credit) AS c_bal FROM arpost ap2 ;
					INNER JOIN ( ;
						SELECT ap_headid FROM arpost ap1 ;
							WHERE ap1.ap_billnr = curledgdeppaycheck.hp_billnum AND NOT ap1.ap_hiden ;
								) c1 ON ap2.ap_headid = c1.ap_headid ;
					WHERE NOT ap2.ap_hiden ;
				INTO CURSOR curledgpaybalancecheck
			ELSE
				= openfiledirect(.F.,"ledgpost")
				SELECT ld_billamt - ld_paidamt AS c_bal;
						FROM ledgpost ;
						WHERE ld_billnum = curledgdeppaycheck.hp_billnum ;
						INTO CURSOR curledgpaybalancecheck
			ENDIF
			IF RECCOUNT()>0 AND c_bal > 0
				l_lVoucherDebitorPaied = .F.
			ENDIF
		ENDIF
		dclose("curledgdeppaycheck")
		dclose("curledgpaybalancecheck")
	ENDIF
	SELECT (l_nSelect)
 ENDIF
 RETURN l_lVoucherDebitorPaied
ENDPROC
*
PROCEDURE DebitorForVoucherDeleteAllowed
LPARAMETERS lp_cBillNum
LOCAL l_lAllowed, l_nSelect, l_nVoucherNumber
l_lAllowed = .T.
IF _screen.oglobal.oparam2.pa_vodebch AND NOT EMPTY(lp_cBillNum)
	LOCAL ARRAY l_aSqlRes(1)
	l_nSelect = SELECT()
	IF NOT USED("histpost")
		openfile(.F., "histpost")
	ENDIF
	IF NOT USED("voucher")
		openfile(.F., "voucher")
	ENDIF
	SELECT hp_voucnum ;
		FROM histpost ;
		INNER JOIN article ON hp_artinum = ar_artinum AND ar_artityp = 4 ;
		WHERE hp_billnum = lp_cBillNum ;
		INTO ARRAY l_aSqlRes
	IF VARTYPE(l_aSqlRes(1))="N" AND NOT EMPTY(l_aSqlRes(1))
		l_nVoucherNumber = l_aSqlRes(1)
		l_aSqlRes(1) = .F.
		SELECT vo_amount-vo_unused AS c_balance ;
			FROM voucher ;
			WHERE vo_number = l_nVoucherNumber ;
			INTO ARRAY l_aSqlRes
		IF VARTYPE(l_aSqlRes(1))="N" AND l_aSqlRes(1)=0 && Check only for new vouchers.
			l_lAllowed = .F.
		ENDIF
	ENDIF
	SELECT (l_nSelect)
ENDIF
RETURN l_lAllowed
ENDPROC
*