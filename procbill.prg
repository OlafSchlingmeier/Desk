#INCLUDE "include\constdefines.h"
#INCLUDE "include\registry.h"

 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
			lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13, ;
			lp_uParam14, lp_uParam15, lp_uParam16, lp_uParam17, lp_uParam18, lp_uParam19
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
FUNCTION BillSetBalance
 LPARAMETERS lp_nBalance, lp_cRetBalace

 IF param.pa_exclvat
	lp_cRetBalace = TRANSFORM(lp_nBalance,RIGHT(gcCurrcydisp,14))
 ELSE
	IF param.pa_ineuro
		IF param.pa_currloc <> 0
			lp_cRetBalace = ;
				ALLTRIM(TRANSFORM(lp_nBalance,RIGHT(gcCurrcydisp, 15)))+"/ "+ ;
				ALLTRIM(TRANSFORM(inlocal(lp_nBalance),RIGHT(gcCurrcydisp,15)))+ ;
				dblookup("paymetho","tag1",param.pa_currloc,"pm_paymeth")
		ELSE
			lp_cRetBalace = ;
				ALLTRIM(TRANSFORM(lp_nBalance,RIGHT(gcCurrcydisp, 15)))+"/ "+ ;
				ALLTRIM(TRANSFORM(lp_nBalance/1.95583,RIGHT(gcCurrcydisp,15)))+"�"
		ENDIF
	ELSE
		IF g_sysdate> {^2002-02-28} OR param.pa_country<>"D"
			lp_cRetBalace = ;
				ALLTRIM(TRANSFORM(lp_nBalance,RIGHT(gcCurrcydisp, 15)))
		ELSE
			lp_cRetBalace = ;
				ALLTRIM(TRANSFORM(lp_nBalance/0.51129,RIGHT(gcCurrcydisp, 15)))+"/"+ ;
				ALLTRIM(TRANSFORM(lp_nBalance,RIGHT(gcCurrcydisp,15)))+"�"
		ENDIF
	ENDIF
 ENDIF
ENDFUNC

PROCEDURE BillMovePosts
 LPARAMETERS lp_cCutCursor, lp_cPasteCursor, lp_nWin, lp_lMarked
 LOCAL l_oOldPost, l_oNewPost, l_cForClause, l_oRecord, l_nWindow, l_nWinpos, l_nResId, l_nSetId, l_nRsId

 IF NOT USED(lp_cCutCursor) OR NOT USED(lp_cPasteCursor)
	RETURN .F.
 ENDIF
 IF lp_cCutCursor == lp_cPasteCursor
	RETURN .T.
 ENDIF

 IF PCOUNT()==4 AND lp_lMarked
	l_cForClause = "tw_mark"
 ELSE
	SELECT(lp_cCutCursor)
	l_cForClause = "ps_postid = " + TRANSFORM(ps_postid)
 ENDIF
 IF NOT BillSelectedPostsApproved(lp_cCutCursor,l_cForClause,lp_nWin)
	RETURN .F.
 ENDIF
 SELECT(lp_cCutCursor)
 SCAN FOR &l_cForClause
	SCATTER NAME l_oRecord
	l_oRecord.tw_mark = .F.
	IF SEEK(l_oRecord.ps_postid, "post", "tag3")
		l_nWindow = post.ps_window
		l_nResId = post.ps_reserid
		l_nRsId = DLookUp("reservat", "rs_reserid = " + SqlCnv(l_nResId,.T.), "rs_rsid")
		l_nSetId = post.ps_setid
		l_nWinpos = FNGetWindowData(l_nRsId, lp_nWin, "pw_winpos")
		IF l_nWinpos = 0
			* Bill is not created yet
			l_nWinpos = lp_nWin
			FNSetWindowData(l_nRsId, lp_nWin, "pw_winpos", l_nWinpos)
		ENDIF
		SELECT(lp_cPasteCursor)
		APPEND BLANK
		GATHER NAME l_oRecord
		SELECT post
		SCATTER NAME l_oOldPost
		REPLACE ps_window WITH lp_nWin, ;
				ps_touched WITH .T. ;
				IN post
		SCATTER NAME l_oNewPost
		PostHistory(l_oOldPost, l_oNewPost, "CHANGED")
		FLUSH
		IF l_nSetId>0
			SELECT post
			SCAN FOR (ps_reserid = l_nResId) AND (ps_window = l_nWindow) AND (ps_setid = l_nSetId)
				SCATTER NAME l_oOldPost
				REPLACE ps_window WITH lp_nWin, ;
						ps_touched WITH .T. IN post
				SCATTER NAME l_oNewPost
				PostHistory(l_oOldPost, l_oNewPost, "CHANGED")
			ENDSCAN
		ENDIF
		SELECT(lp_cCutCursor)
		DELETE
	ENDIF
 ENDSCAN

 RETURN .T.
ENDPROC

PROCEDURE BillRedirectPosts
 LPARAMETERS lp_nNewReserId, lp_cRoomNum, lp_cLName, lp_nWindow
 LOCAL l_nWindow, l_nRsId, l_nResId, l_nSetId, l_oOldPost, l_oNewPost, l_nArea, l_nRedirectWindow, l_lSupplemUpd, l_dForDate, l_nRedirectWinpos
 LOCAL ARRAY l_aWin(1)

 l_nArea = SELECT()

 l_nRsId = DLookUp("reservat", "rs_reserid = " + SqlCnv(post.ps_reserid), "rs_rsid")
 l_nRedirectWinpos = FNGetWindowData(l_nRsId, post.ps_window, "pw_winpos")
 l_nRedirectWindow = PBGetFreeWindow(lp_nNewReserId, l_nRedirectWinpos,,,l_nRedirectWinpos)
 l_aWin(1) = l_nRedirectWindow
 IF BillsReserCheck(lp_nNewReserId, @l_aWin, "POST_REDIRECT")
	l_nRedirectWindow = PBGetFreeWindow(lp_nNewReserId, l_nRedirectWindow)
 ELSE
	l_nRedirectWindow = PBGetFreeWindow(lp_nNewReserId, lp_nWindow)
 ENDIF
 l_nWindow = post.ps_window
 l_nResId = post.ps_reserid
 l_nSetId = post.ps_setid
 SELECT post
 SCATTER NAME l_oOldPost
 REPLACE ps_reserid WITH lp_nNewReserId, ;
		ps_window WITH l_nRedirectWindow, ;
		ps_touched WITH .T. IN post
 l_dForDate = CTOD(LEFT(ps_supplem,10))
 IF EMPTY(ps_supplem) OR NOT EMPTY(l_dForDate) AND EMPTY(SUBSTR(ps_supplem,11))
	 REPLACE ps_supplem WITH IIF(EMPTY(l_dForDate), "", DTOC(l_dForDate)+" ") + get_rm_rmname(lp_cRoomNum)+" "+MakeProperName(lp_cLName) IN post
	 l_lSupplemUpd = .T.
 ENDIF
 SCATTER NAME l_oNewPost
 PostHistory(l_oOldPost, l_oNewPost, "CHANGED")
 FLUSH
 IF l_nSetId>0
	LOCAL l_nRecNo, l_cOrder
	l_nRecNo = RECNO("post")
	l_cOrder = ORDER("post")
	SET ORDER TO 0 IN post
	SELECT post
	SCAN FOR (ps_reserid = l_nResId) AND (ps_window = l_nWindow) AND (ps_setid = l_nSetId)
		SCATTER NAME l_oOldPost
		REPLACE ps_reserid WITH lp_nNewReserId, ;
				ps_window WITH l_nRedirectWindow, ;
				ps_touched WITH .T. IN post
		l_dForDate = CTOD(LEFT(ps_supplem,10))
		IF l_lSupplemUpd AND (EMPTY(ps_supplem) OR NOT EMPTY(l_dForDate) AND EMPTY(SUBSTR(ps_supplem,11)))
			REPLACE ps_supplem WITH IIF(EMPTY(l_dForDate), "", DTOC(l_dForDate)+" ") + get_rm_rmname(lp_cRoomNum)+" "+MakeProperName(lp_cLName) IN post
		ENDIF
		SCATTER NAME l_oNewPost
		PostHistory(l_oOldPost, l_oNewPost, "CHANGED")
	ENDSCAN
	SET ORDER TO l_cOrder IN post
	GO l_nRecNo IN post
 ENDIF 
 SELECT (l_nArea)

 RETURN .T.
ENDPROC

PROCEDURE BillRedirectOK
 LPARAMETERS lp_nOldReserId, lp_nNewReserId, lp_frsBills
 LOCAL l_oOldPost, l_oNewPost, l_nArea
 DO CASE
  CASE lp_nOldReserId <= -10
	l_nArea = SELECT()
	SELECT post
	SCAN FOR NOT EMPTY(ps_marker)
		SCATTER NAME l_oOldPost
		REPLACE ps_reserid WITH lp_nNewReserId, ;
				ps_touched WITH .T., ;
				ps_marker WITH "", ;
				ps_supplem WITH GetLangText("CHKOUT2","TXT_PHONE_BOOTH")+" "+LTRIM(STR(ABS(lp_nOldReserId))) ;
				IN post
		SCATTER NAME l_oNewPost
		PostHistory(l_oOldPost, l_oNewPost, "CHANGED")
	ENDSCAN
	GOTO TOP IN post
	SELECT (l_nArea)
  CASE lp_nNewReserId > 0
	WAIT WINDOW NOWAIT "Transfer..."
	IF NOT BillRedirectCheck(lp_nNewReserId, lp_frsBills)
		RETURN .F.
	ENDIF
	LOCAL l_nCurWin, l_oBillWin, l_lChanged
	FOR l_nCurWin = 1 TO 6
		l_lChanged = .F.
		l_oBillWin = lp_frsBills.getbillobject("BillGrid", l_nCurWin)
		IF USED(l_oBillWin.RecordSource) AND BillSelectedPostsApproved(l_oBillWin.RecordSource,"tw_mark",l_oBillWin.n_ps_win,lp_nNewReserId)
			SELECT(l_oBillWin.RecordSource)
			SCAN FOR tw_mark
				SCATTER NAME l_oRecord
				IF SEEK(l_oRecord.ps_postid, "post", "tag3")
					= BillRedirectPosts(lp_nNewReserId, reservat.rs_roomnum, reservat.rs_lname)
					SELECT(l_oBillWin.RecordSource)
					DELETE
					IF NOT l_lChanged
						l_lChanged = .T.
					ENDIF
				ENDIF
			ENDSCAN
		ENDIF
		IF l_lChanged
			lp_frsBills.refreshbalance(l_nCurWin, .T.)
		ENDIF
	ENDFOR
	lp_frsBills.refreshbills()
 ENDCASE
 RETURN .T.
ENDPROC

PROCEDURE BillRedirectCheck
LPARAMETERS lp_nNewReserId, lp_frsBills, lp_lValid
 LOCAL l_nRecNo, l_nCurWin, l_oBillWin
 LOCAL ARRAY l_aWindows(1)
 lp_lValid = .F.
 l_nRecNo = RECNO("reservat")
 IF NOT SEEK(lp_nNewReserId,"reservat","tag1")
	GO l_nRecNo IN reservat
	RETURN lp_lValid
 ENDIF
 l_aWindows(1) = 0
 FOR l_nCurWin = 1 TO 6
	l_oBillWin = lp_frsBills.getbillobject("BillGrid", l_nCurWin)
	IF USED(l_oBillWin.RecordSource)
		SELECT(l_oBillWin.RecordSource)
		LOCATE FOR tw_mark
		IF FOUND()
			IF NOT EMPTY(l_aWindows(ALEN(l_aWindows)))
				DIMENSION l_aWindows(ALEN(l_aWindows)+1)
			ENDIF
			l_aWindows(ALEN(l_aWindows)) = PBGetFreeWindow(lp_nNewReserId, l_nCurWin,,,l_nCurWin)
		ENDIF
	ENDIF
 ENDFOR
 IF NOT EMPTY(l_aWindows(1))
	lp_lValid = BillsReserCheck(lp_nNewReserId, @l_aWindows, "POST_INSERT")
 ELSE
	lp_lValid = .T.
 ENDIF
 GO l_nRecNo IN reservat
 RETURN lp_lValid
ENDPROC

PROCEDURE BillActionCheck
LPARAMETERS lp_cAction

 DO CASE
	CASE lp_cAction = "PRINT"
		lp_lValid = (billnum.bn_status <> "CXL")
	CASE lp_cAction = "REOPEN"
		lp_lValid = EMPTY(billnum.bn_negnum) AND (billnum.bn_status=="PCO")
	CASE INLIST(lp_cAction, "CANCEL", "BILL_ADDR", "PAY_NEW", "POST_NEW", "POST_EDT", "POST_DEL", "POST_MARK", "POST_SPLIT", "POST_INSERT", "POST_REDIRECT", "POST_RATECOD")
		lp_lValid = EMPTY(billnum.bn_status) OR (billnum.bn_status=="OPN")
	CASE lp_cAction = "CHKOUT"
		lp_lValid = EMPTY(billnum.bn_status) OR INLIST(billnum.bn_status, "OPN", "PCO")
*	CASE lp_cAction = "UPD_CHKOUT"
*		lp_lValid = (billnum.bn_status == "PCO")
	CASE lp_cAction = "INVOICE"
		lp_lValid = .T.
	OTHERWISE
		lp_lValid = .F.
 ENDCASE
 RETURN lp_lValid
ENDPROC

PROCEDURE BillOpenReason
LPARAMETERS lp_cBillStatus, lp_cWindows, lp_lSilent, lp_lForceReason, lp_cChangeReason
 IF g_AuditActive
	lp_lSilent = .T.
	lp_lForceReason = .T.
 ENDIF
 LOCAL l_cQuestion
 l_cQuestion = IIF(lp_cBillStatus = "CXL", GetLangText("BILL","TXT_BILL_CXL"), ;
		GetLangText("BILL","TXT_BILL_ISSUED"))
 l_cQuestion = l_cQuestion + IIF(EMPTY(lp_cWindows),"", ".;" + ;
		GetLangText("BILL","TXT_BILL_WINDOWS") + ": " + lp_cWindows)
 l_cQuestion = l_cQuestion + ";" + GetLangText("BILL","TXT_BILL_REACTIVATE")
 DO CASE
  CASE lp_lForceReason
	lp_cChangeReason = "AUTOMATIC " + GetLangText("BILL","TXT_OPEN_BILL")
	IF NOT lp_lSilent
		= Alert(GetLangText("BILL","TXT_OPEN_BILL") + ;
				IIF(EMPTY(lp_cWindows),"", ".;" + ;
				GetLangText("BILL","TXT_BILL_WINDOWS") + ;
				": " + lp_cWindows))
	ENDIF
  CASE NOT lp_lSilent AND YesNo(l_cQuestion)
	DO FORM "forms\reasonform" WITH ;
			GetLangText("CHKOUT2","T_REASON")+":", ;
			GetLangText("BILL","TXT_OPEN_BILL") ;
			TO lp_cChangeReason
  OTHERWISE
	lp_cChangeReason = ""
 ENDCASE
 RETURN lp_cChangeReason
ENDPROC

*PROCEDURE BillOpenProc
*LPARAMETERS lp_nReserId, lp_nWindow, lp_cAction, lp_cReason, lp_nAmount
* LOCAL l_nRecNo, l_cBillNum
* l_nRecNo = RECNO("reservat")
* l_cBillNum = ""
* IF (lp_nReserId==reservat.rs_reserid) OR SEEK(lp_nReserId,"reservat","tag1")
*	LOCAL l_cField
*	l_cField = "reservat.rs_billnr"+ALLTRIM(STR(lp_nWindow,1))
*	l_cBillNum = BillNumChange(EVALUATE(l_cField), "OPEN", lp_cReason)
*	IF l_cBillNum <> EVALUATE(l_cField)
*		REPLACE &l_cField WITH l_cBillNum IN reservat
*	ENDIF
* ENDIF
* GO l_nRecNo IN reservat
* RETURN l_cBillNum
*ENDPROC

PROCEDURE BillsReserCheck
LPARAMETERS lp_nReserId, lp_aWindows, lp_cAction, lp_lValid, lp_lSilent, lp_lForceReason, lp_lDontReopen
EXTERNAL ARRAY lp_aWindows
 LOCAL l_nRecNoRes, l_lUsed, l_nRecNoBill, l_oEnvironment

 IF g_lFakeResAndPost
	lp_lValid = .T.
	RETURN .T.
 ENDIF

 l_oEnvironment = SetEnvironment("reservat,billnum")

 lp_lValid = .F.
 IF lp_nReserId <> reservat.rs_reserid
	CursorQuery("reservat", StrToSql("rs_reserid = %n1", lp_nReserId))
	IF NOT DLocate("reservat", StrToSql("rs_reserid = %n1", lp_nReserId))
		RETURN lp_lValid
	ENDIF
 ENDIF
 LOCAL l_cBillStatus, l_cWindows, l_nWins, l_nCount, l_cBillNum
 l_cBillStatus = "CXL"
 l_cWindows = ""
 l_nWins = ALEN(lp_aWindows)
 FOR l_nCount = 1 TO l_nWins
	IF NOT EMPTY(lp_aWindows(l_nCount))
		l_cBillNum = FNGetBillData(reservat.rs_reserid, lp_aWindows(l_nCount), "bn_billnum")
		IF NOT EMPTY(l_cBillNum) AND SEEK(l_cBillNum,"billnum","tag1") AND NOT BillActionCheck(lp_cAction)
			IF billnum.bn_status <> "CXL"
				l_cBillStatus = ""
			ENDIF
			l_cWindows = l_cWindows + IIF(EMPTY(l_cWindows),"",", ") + TRANSFORM(lp_aWindows(l_nCount))
		ELSE
			lp_aWindows(l_nCount) = 0
		ENDIF
	ENDIF
 ENDFOR
 IF NOT EMPTY(l_cWindows)
	IF NOT lp_lDontReopen
		LOCAL l_cChangeReason, l_cNewAction, l_cField
		*IF lp_cAction = "UPD_CHKOUT"
			*l_cNewAction = "CANCEL"
			*l_cChangeReason = "AUTOMATIC - CHECK OUT"
		*ELSE
			l_cNewAction = "OPEN"
			l_cChangeReason = BillOpenReason(l_cBillStatus, l_cWindows, lp_lSilent, lp_lForceReason)
		*ENDIF
		IF NOT EMPTY(l_cChangeReason)
			lp_lValid = .T.
			FOR l_nCount = 1 TO ALEN(lp_aWindows)
				IF NOT EMPTY(lp_aWindows(l_nCount))
					l_cBillNum = FNGetBillData(reservat.rs_reserid, lp_aWindows(l_nCount), "bn_billnum")
					IF NOT EMPTY(l_cBillNum)
						= BillNumChange(l_cBillNum, l_cNewAction, l_cChangeReason)
					ENDIF
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
 ELSE
	lp_lValid = .T.
 ENDIF

 RETURN lp_lValid
ENDPROC

PROCEDURE PBPrepareFirstFreeWindow
 LPARAMETERS lp_nReserid, lp_nWindowPosition, lp_cAction
 LOCAL l_nLastWin, l_nRsId

 l_nRsId = DLookUp("reservat", "rs_reserid = " + SqlCnv(lp_nReserid), "rs_rsid")
 l_nLastWin = 0
 CALCULATE MAX(pw_window) FOR pw_rsid = l_nRsId TO l_nLastWin IN pswindow
 l_nLastWin = MAX(6,l_nLastWin)+1

 PBGetFreeWindow(lp_nReserid, l_nLastWin, .T.,,lp_nWindowPosition, lp_cAction)

 RETURN l_nLastWin
ENDPROC

PROCEDURE PBGetFreeWindow
 LPARAMETERS lp_nReserid, lp_nWindow, lp_lSearchForHigherWindow, lp_lReturnZeroWhenNoFreeWindow, lp_nWindowPosition, lp_cAction
 LOCAL l_nWindow, l_nWinpos, l_lFoundBill, i, l_nSelect, l_lValid, l_lSilent, l_lDontReopen, l_nRsId, l_cSql
 LOCAL ARRAY l_aWin(1), l_aWinPos(1)

 l_nWindow = EVL(lp_nWindow,1)		&& 1 is default
 lp_nWindowPosition = EVL(lp_nWindowPosition,0)
 lp_cAction = EVL(lp_cAction, "POST_NEW")
 IF NOT EMPTY(lp_nReserid)
	l_nSelect = SELECT()
	l_nRsId = DLookUp("reservat", "rs_reserid = " + SqlCnv(lp_nReserid), "rs_rsid")
	* First check is free wished window
	l_aWin(1) = l_nWindow
	l_lSilent = .T. && Dont show messages
	l_lForce = .F.
	l_lDontReopen = .T.
	IF BillsReserCheck(lp_nReserid, @l_aWin, lp_cAction, l_lValid, l_lSilent, l_lForce, l_lDontReopen)
		l_lFoundBill = .T.
	ELSE
		IF NOT EMPTY(lp_nWindowPosition)
			* Wished bill is closed. Try to find free bill in specific position, to post record.
			TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
			SELECT pw_window 
				FROM (SELECT pw_rsid, pw_window FROM pswindow WHERE pw_rsid = <<SqlCnv(l_nRsId)>> AND pw_winpos = <<SqlCnv(lp_nWindowPosition)>>) pw 
				LEFT JOIN (SELECT bn_rsid, bn_window FROM billnum WHERE bn_reserid = <<SqlCnv(lp_nReserid)>> AND bn_status <> 'OPN') bn ON bn.bn_rsid = pw.pw_rsid AND bn.bn_window = pw.pw_window
				WHERE ISNULL(bn_window)
			ENDTEXT
			l_aWinPos(1) = .T.
			SqlCursor(l_cSql,,,,,,@l_aWinPos)
			IF NOT EMPTY(l_aWinPos(1))
				l_aWin(1) = l_aWinPos(1)
				IF BillsReserCheck(lp_nReserid, @l_aWin, lp_cAction, l_lValid, l_lSilent, l_lForce, l_lDontReopen)
					* We found window which is not closed.
					l_nWindow = l_aWinPos(1)
					l_lFoundBill = .T.
				ENDIF
			ENDIF
		ENDIF
		IF NOT l_lFoundBill
			* Wished bill is closed. Try to find first free bill, to post record.
			FOR i = IIF(lp_lSearchForHigherWindow, l_nWindow, 1) TO MAX_BILL_WINDOW		&& MAX_BILL_WINDOW = 9999
				IF NOT INLIST(i, l_aWin(1), l_nWindow) && We checked these bills already, and they closed.
					l_aWin(1) = i
					IF BillsReserCheck(lp_nReserid, @l_aWin, lp_cAction, l_lValid, l_lSilent, l_lForce, l_lDontReopen)
						* We found window which is not closed.
						l_nWindow = i
						l_lFoundBill = .T.
						EXIT
					ENDIF
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
	DO CASE
		CASE NOT l_lFoundBill
			l_nWinpos = 0
		CASE NOT EMPTY(lp_nWindowPosition)
			l_nWinpos = lp_nWindowPosition
		CASE BETWEEN(l_nWindow, 1, 6)
			l_nWinpos = l_nWindow
		OTHERWISE
			l_nWinpos = FNGetWindowData(l_nRsId, l_nWindow, "pw_winpos")
			IF EMPTY(l_nWinpos)
				l_nWinpos = PBGetFreeWindowPos(l_nRsId)
			ENDIF
	ENDCASE
	IF l_nWinpos = 0
		* All bills are closed.
		* Reactivate bill 6.
		IF lp_lReturnZeroWhenNoFreeWindow
			l_nWindow = 0
		ELSE
			l_nWindow = 6
		ENDIF
	ELSE
		FNSetWindowData(l_nRsId, l_nWindow, "pw_winpos", l_nWinpos)
		IF lp_nWindowPosition = 0
			lp_nWindowPosition = l_nWinpos
		ENDIF
	ENDIF
	SELECT(l_nSelect)
 ENDIF

 RETURN l_nWindow
ENDPROC

PROCEDURE PBGetFreeWindowPos
 LPARAMETERS lp_nRsId, lp_nWinpos, lp_nWindow
 LOCAL ARRAY l_aWin(1)
 LOCAL i, l_nWinpos

 FOR i = 4 TO 6
	l_aWin(1) = 0
	IF NOT g_auditactive
		SELECT bn_window FROM billnum ;
			INNER JOIN pswindow ON PADL(pw_rsid,10)+PADL(pw_window,10) = PADL(bn_rsid,10)+PADL(bn_window,10) ;
			WHERE pw_rsid = lp_nRsId AND pw_winpos = i AND bn_status = 'PCO' AND bn_date = SysDate() ;
			INTO ARRAY l_aWin
	ENDIF
	IF EMPTY(l_aWin(1))
		* We didn't find any closed bill on sysdate on selected window position.
		* So use this window position for bill.
		l_nWinpos = i
		EXIT
	ENDIF
 ENDFOR

 RETURN l_nWinpos
ENDPROC

PROCEDURE BillsReserRefresh
LPARAMETERS lp_lSpecLogin, lp_nReserId
 LOCAL l_nBillWin, l_cBillNum, l_nAmount, l_cStatus, l_cAction
 IF EMPTY(lp_nReserId)
	lp_nReserId = reservat.rs_reserid
 ENDIF
 IF reservat.rs_reserid <> lp_nReserId AND ;
		NOT SEEK(lp_nReserId,"reservat","tag1")
	RETURN .F.
 ENDIF
 FOR l_nBillWin = 1 TO 6
	l_cBillNum = ALLTRIM(FNGetBillData(reservat.rs_reserid, l_nBillWin, "bn_billnum"))
	IF NOT EMPTY(l_cBillNum)
		l_nAmount = BillAmount(l_nAmount, "post", lp_nReserId, l_nBillWin)
		l_cStatus = BillNumStatus(l_cBillNum)
		IF reservat.rs_status = "OUT" AND l_nAmount = 0 AND ;
				Balance(lp_nReserId, l_nBillWin) = 0 AND ;
				(lp_lSpecLogin AND l_cStatus <> "CXL" OR ;
				NOT lp_lSpecLogin AND NOT INLIST(l_cStatus, "PCO", "CXL"))
			l_cAction = IIF(lp_lSpecLogin, "SPEC_CXL", "CANCEL")
		ELSE
			l_cAction = "REFRESH"
		ENDIF
		= BillNumChange(l_cBillNum, l_cAction, "", 0, l_nAmount)
	ENDIF
 ENDFOR
 RETURN .T.
ENDPROC

PROCEDURE BillsReserOut
LPARAMETERS lp_nReserId, lp_aBalance, lp_lSilent
 LOCAL l_cChanges
 IF EMPTY(lp_nReserId)
	lp_nReserId = reservat.rs_reserid
 ENDIF
 IF reservat.rs_reserid <> lp_nReserId AND ;
		NOT SEEK(lp_nReserId,"reservat","tag1")
	RETURN .F.
 ENDIF
 EXTERNAL ARRAY lp_aBalance
 IF PCOUNT() < 2 OR VARTYPE(lp_aBalance) <> "N"
	DIMENSION lp_aBalance(6)
	lp_aBalance(1) = Balance(reservat.rs_reserid, 1)
	lp_aBalance(2) = Balance(reservat.rs_reserid, 2)
	lp_aBalance(3) = Balance(reservat.rs_reserid, 3)
	lp_aBalance(4) = Balance(reservat.rs_reserid, 4)
	lp_aBalance(5) = Balance(reservat.rs_reserid, 5)
	lp_aBalance(6) = Balance(reservat.rs_reserid, 6)
 ENDIF
 IF NOT ((lp_aBalance(1) == 0) AND (lp_aBalance(2) == 0) AND (lp_aBalance(3) == 0) AND ;
		(lp_aBalance(4) == 0) AND (lp_aBalance(5) == 0) AND (lp_aBalance(6) == 0)) ;
		AND (NOT EMPTY(reservat.rs_out) OR (reservat.rs_status <> "IN"))
	IF NOT reservat.rs_cowibal
		IF NOT lp_lSilent
			= Alert(GetLangText("BILL","TXT_SEPARATELY_HAS_BALANCE"))
		ENDIF
		l_cChanges = RsHistry(reservat.rs_changes, "UNDOCHECKOUT", ;
				GetLangText("RESERV2","TA_HASBALANCE"))
		REPLACE rs_out WITH "", ;
				rs_status WITH "IN", ;
				rs_changes WITH l_cChanges, ;
				rs_posstat WITH "1", ;
				rs_codate WITH {}, ;
				rs_cotime WITH "" ;
				IN reservat
		IF reservat.rs_depdate < SysDate()
			REPLACE rs_depdate WITH SysDate() IN reservat
		ENDIF
	ENDIF
 ELSE
	IF reservat.rs_cowibal
		REPLACE rs_cowibal WITH .F. IN reservat
	ENDIF
 ENDIF
ENDPROC

*PROCEDURE BillNumCheck
*LPARAMETERS lp_cBillNum, lp_cAction, lp_lValid, lp_lSilent, lp_lForceReason
* LOCAL l_lUsed, l_nRecNo
* l_lUsed = USED("billnum")
* IF l_lUsed
*	l_nRecNo = RECNO("billnum")
* ELSE
*	USE data\billnum IN 0 SHARED
* ENDIF
* IF NOT EMPTY(lp_cBillNum) AND SEEK(lp_cBillNum,"billnum","tag1") AND ;
*		NOT BillActionCheck(lp_cAction)
*	LOCAL l_cStatement, l_cChangeReason
*	lp_lValid = .F.
*	l_cChangeReason = BillOpenReason(billnum.bn_status, "", ;
*			lp_lSilent, lp_lForceReason)
*	IF NOT EMPTY(l_cChangeReason)
*		lp_lValid = .T.
*		= BillNumChange(lp_cBillNum,"OPEN",l_cChangeReason)
*	ENDIF
* ELSE
*	lp_lValid = .T.
* ENDIF
* IF l_lUsed
*	GO l_nRecNo IN billnum
* ELSE
*	USE IN billnum
* ENDIF
* RETURN lp_lValid
*ENDPROC

FUNCTION BillNumStatus
LPARAMETERS lp_cBillNum, lp_cStatus
 LOCAL l_lUsed, l_nRecNo
 l_lUsed = USED("billnum")
 IF l_lUsed
	l_nRecNo = RECNO("billnum")
 ELSE
	openfiledirect(.F., "billnum")
 ENDIF
 IF SEEK(lp_cBillNum,"billnum","tag1")
	lp_cStatus = billnum.bn_status
 ELSE
	lp_cStatus = ""
 ENDIF
 IF l_lUsed
	GO l_nRecNo IN billnum
 ELSE
	dclose("billnum")
 ENDIF
 RETURN lp_cStatus
ENDFUNC

FUNCTION BillNumType
LPARAMETERS lp_cBillNum, lp_nBillType
 LOCAL l_cCur, l_nSelect
 l_nSelect = SELECT()
 lp_nBillType = -1 && When no bill found
 openfiledirect(.F., "billnum")
 l_cCur = sqlcursor("SELECT bn_addrid, bn_type FROM billnum WHERE bn_billnum = " + SqlCnv(lp_cBillNum,.T.))
 IF RECCOUNT(l_cCur)>0
	lp_nBillType = &l_cCur..bn_type
	IF lp_nBillType = C_BILL_TYPE_UNDEFINED
		lp_nBillType = BillNumTypeDefault(&l_cCur..bn_addrid)
	ENDIF
 ENDIF
 dclose(l_cCur)
 SELECT (l_nSelect)
 RETURN lp_nBillType
ENDFUNC

FUNCTION BillNumTypeDefault
 LPARAMETERS lp_nAddrId
 LOCAL l_nBillType
 IF NOT EMPTY(lp_nAddrId) AND PAIsCompany(lp_nAddrId)
	l_nBillType = C_BILL_TYPE_COMPANY
 ELSE
	l_nBillType = C_BILL_TYPE_GUEST
 ENDIF
 RETURN l_nBillType
ENDFUNC

FUNCTION BillNumTypeManualSelectedValid
 LPARAMETERS lp_nBillType, lp_nDefBillType
 LOCAL l_lValid
 IF VARTYPE(lp_nBillType)="N" AND _screen.oGlobal.oParam2.pa_biltsel
	* Billtype sent thru parameter.
	* Alowed is only to change from company bill to guest bill.
	IF INLIST(lp_nBillType, C_BILL_TYPE_GUEST, C_BILL_TYPE_COMPANY) AND ;
			lp_nDefBillType = C_BILL_TYPE_COMPANY
		l_lValid = .T.
	ENDIF
 ENDIF
 RETURN l_lValid
ENDFUNC

FUNCTION BillNumChange
LPARAMETERS lp_cBillNum, lp_cAction, lp_cReason, lp_nPayNum, lp_nAmount, lp_nAyID, lp_nBillType
 LOCAL l_lReturn, l_cHistory, l_cStatus, l_nReserId, l_nWindow, l_nAddrId, l_nApId, l_nPayNum, l_oEnvironment

 STORE 0 TO l_nApId, l_nAddrId, l_nPayNum

 l_oEnvironment = SetEnvironment("reservat,billnum")

 CursorQuery("billnum", StrToSql("bn_billnum = %s1", lp_cBillNum))
 IF NOT SEEK(lp_cBillNum,"billnum","tag1")
	l_nReserId = 0
	l_nWindow = 0
	l_cStatus = "OPN"
	INSERT INTO billnum (bn_billnum, bn_status, bn_reserid, bn_window, bn_history, bn_addrid, bn_apid, bn_paynum, bn_userid) ;
		VALUES (lp_cBillNum, l_cStatus, l_nReserId, l_nWindow, "OLD BILL - "+l_cStatus, l_nAddrId, l_nApId, l_nPayNum, g_userid)
 ELSE
	l_nPayNum = EVL(lp_nPayNum, billnum.bn_paynum)
	CursorQuery("reservat", StrToSql("rs_reserid = %n1", billnum.bn_reserid))
	IF SEEK(billnum.bn_reserid,"reservat","tag1")
		REPLACE bn_rsid WITH reservat.rs_rsid IN billnum
		l_nAddrId = BillAddrId(billnum.bn_window, reservat.rs_rsid, reservat.rs_addrid)
		l_nApId = BillApId(billnum.bn_window, reservat.rs_addrid, reservat.rs_compid, reservat.rs_invid, reservat.rs_apid, reservat.rs_invapid)
	ELSE
		IF billnum.bn_reserid = 0.100 && PasserBy
			l_nAddrId = billnum.bn_addrid
			l_nApId = billnum.bn_apid
		ENDIF
	ENDIF
 ENDIF
 IF PCOUNT() > 4
	REPLACE bn_amount WITH lp_nAmount IN billnum
 ENDIF

 l_lReturn = .T.
 DO CASE
	CASE INLIST(lp_cAction, "CANCEL", "SPEC_CXL")
		REPLACE bn_status WITH "CXL" IN billnum
		BillDeleteBillNumFromPosts(billnum.bn_reserid, billnum.bn_window, billnum.bn_billnum)
	CASE lp_cAction = "CHKOUT"
		IF billnum.bn_status = "PCO"
			lp_cAction = "PRINT"
		ELSE
			REPLACE bn_status WITH "PCO", bn_date WITH SysDate(), bn_userid WITH g_userid IN billnum
			l_cOldNum = BillNewOldNum(billnum.bn_reserid, billnum.bn_window, billnum.bn_billnum)
			IF NOT EMPTY(l_cOldNum)
				REPLACE bn_oldnum WITH l_cOldNum IN billnum
			ENDIF
			IF _screen.BMS
				* In BMS mode generate now points. This is a place, which is called, when user closes bill.
				* It covers also the case, when billnum wasn't changed, but open bill was closes (PCO status).
				IF NOT (TYPE("p_lDontCallBonusFromBillNumChange")="L" AND p_lDontCallBonusFromBillNumChange) && Don't call it from passerby!
					ProcBill("PBBonusUpdate", billnum.bn_billnum, billnum.bn_reserid, billnum.bn_window, billnum.bn_addrid)
				ENDIF
			ENDIF
			PRT_rsifsync_insert("reservat", "EDIT")
		ENDIF
		REPLACE bn_addrid WITH l_nAddrId, bn_apid WITH l_nApId, bn_paynum WITH l_nPayNum IN billnum
		IF NOT EMPTY(lp_nAyID)
			REPLACE bn_ayid WITH lp_nAyID IN billnum
		ENDIF
		l_nBillType = BillNumTypeDefault(l_nAddrId)
		IF BillNumTypeManualSelectedValid(lp_nBillType, l_nBillType)
			l_nBillType = lp_nBillType
		ENDIF
		REPLACE bn_type WITH l_nBillType IN billnum
	CASE lp_cAction = "OPEN"
		IF INLIST(billnum.bn_status, "PCO", "CXL") AND (billnum.bn_date < SysDate() OR g_AuditActive OR NOT EMPTY(param.pa_fiscprt) OR _screen.oGlobal.lfiskaltrustactive)
			* When fiscal printer is used, bill must be always canceled!
			l_lReturn = .F.
			REPLACE bn_status WITH "CXL", bn_cxldate WITH sysdate() IN billnum
			lp_cAction = lp_cAction + " -> CANCEL"
			* copy to postcxl.dbf
			BillNumCxl()
		ELSE
			REPLACE bn_status WITH "OPN" IN billnum
		ENDIF
		BillDeleteBillNumFromPosts(billnum.bn_reserid, billnum.bn_window, billnum.bn_billnum, billnum.bn_addrid)
 ENDCASE
 IF NOT INLIST(lp_cAction, "REFRESH", "SPEC_CXL")
	l_cHistory = RsHistry(billnum.bn_history, lp_cAction, lp_cReason)
	REPLACE bn_history WITH l_cHistory IN billnum
 ENDIF

 RETURN l_lReturn
ENDFUNC

PROCEDURE BillNumCxl
 * billnum table is opened, and right record is selected
 LOCAL l_nSelect, l_oData, l_cSql, l_cCur, l_tCxlDateTime, l_lSuccess
 IF NOT param2.pa_cpybcxl AND NOT _screen.oGlobal.lfiskaltrustactive
	RETURN .T.
 ENDIF
 l_nSelect = SELECT()

 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT post.*, rs_rsid AS ps_rsid FROM post ;
		LEFT JOIN reservat ON rs_reserid = ps_reserid ;
		WHERE ps_reserid = <<sqlcnv(billnum.bn_reserid)>> AND ps_window = <<sqlcnv(billnum.bn_window)>> ;
		AND NOT ps_cancel ;
		ORDER BY ps_postid
 ENDTEXT
 l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
 IF RECCOUNT(l_cCur)>0
	IF openfile(.F., "postcxl")
		l_tCxlDateTime = DATETIME() && Needed, when is possible to cancel same billnum more times
		l_lSuccess = .T.
		IF _screen.oGlobal.lfiskaltrustactive
			l_lSuccess = fpfiskaltrust("CXL", billnum.bn_reserid, billnum.bn_window)
			IF l_lSuccess
				REPLACE bn_qrcodec WITH _screen.oGlobal.cfiskaltrustqrcode IN billnum
			ENDIF
		ENDIF
		IF l_lSuccess
			SELECT (l_cCur)
			SCAN ALL
				SCATTER NAME l_oData MEMO
				ADDPROPERTY(l_oData,"ps_cxldatt",l_tCxlDateTime)
				sqlinsert("postcxl","",5,l_oData)
			ENDSCAN
			IF _screen.oGlobal.lfiskaltrustactive
				= prntbill(billnum.bn_reserid,billnum.bn_window,.T.,1,,,,,,.T.)
			ENDIF
		ENDIF
	ENDIF
 ENDIF

 dclose(l_cCur)
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC

FUNCTION BillReserReopen
LPARAMETERS lp_nReserid, lp_nWindow
 LOCAL l_oEnvironment, l_cChangeReason, l_cBillNum, l_nWindow

 l_oEnvironment = SetEnvironment("billnum")

 l_nWindow = lp_nWindow

 l_cBillNum = FNGetBillData(lp_nReserid, lp_nWindow, "bn_billnum")
 IF NOT EMPTY(l_cBillNum) AND SEEK(l_cBillNum,"billnum","tag1") AND BillActionCheck("REOPEN")
	l_cChangeReason = BillOpenReason("REOPEN", TRANSFORM(lp_nWindow))
	IF NOT EMPTY(l_cChangeReason)
		* copy to post.dbf with negative/reverse items
		BillNumChange(l_cBillNum, "REOPEN", l_cChangeReason)
		BillNumReverse(@l_nWindow)
	ENDIF
 ENDIF

 RETURN l_nWindow
ENDFUNC

PROCEDURE BillNumReverse
LPARAMETERS lp_nWindow
 * billnum table is opened, and right record is selected
 LOCAL l_oEnvironment, l_cBillnum, l_cReverseBillNum, l_nReserid, l_nWinpos, l_nWindow, l_oData, l_cSql, l_cCur

 l_oEnvironment = SetEnvironment("billnum,post,ratecode,article,paymetho,pswindow")

 l_cReverseBillNum = ""
 l_nBnRecno = RECNO("billnum")
 l_cBillnum = billnum.bn_billnum

 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT post.*, ;
		CAST(<<IIF(_screen.oGlobal.oParam2.pa_radetai AND NOT _screen.oGlobal.lspecialfiscalprintermode, "''", "NVL(rc_lang"+g_Langnum+",'')")>> AS C(35)) AS tw_rclang, ;
		CAST(NVL(EVL(ar_lang<<g_Langnum>>,'<<GetLangText("MGRFINAN","TXT_NOTDEFINED")>>'),'') AS C(25)) AS tw_arlang, ;
		CAST(NVL(pm_lang<<g_Langnum>>,'') AS C(25)) AS tw_paylang, ;
		ps_units AS tw_units, ;
		0=0 AS tw_mark ;
		FROM post ;
		LEFT JOIN ratecode ON rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season = ps_ratecod ;
		LEFT JOIN article ON ar_artinum = ps_artinum ;
		LEFT JOIN paymetho ON pm_paynum = ps_paynum ;
		WHERE ps_reserid = <<sqlcnv(billnum.bn_reserid)>> AND ps_window = <<sqlcnv(billnum.bn_window)>> AND NOT ps_cancel ;
		ORDER BY ps_postid
 ENDTEXT
 l_cCur = sqlcursor(l_cSql,,,,,.T.,,.T.)
 IF RECCOUNT(l_cCur) > 0
	l_nReserid = billnum.bn_reserid
	l_nWinpos = FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_winpos")
	l_nWindow = PBPrepareFirstFreeWindow(l_nReserid, l_nWinpos, "REOPEN")
	FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_addrid",  IIF(billnum.bn_window = 1, billnum.bn_addrid, FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_addrid")))
	FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_billsty", FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_billsty"))
	FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_udbdate", FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_udbdate"))
	FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_bmsto1w", FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_bmsto1w"))
	FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_blamid",  FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_blamid"))
	SELECT (l_cCur)
	REPLACE ps_billnum WITH "", ps_window WITH l_nWindow, ps_date WITH SysDate(), ps_time WITH TIME() ALL
	SCAN
		SCATTER NAME l_oData MEMO
		l_oData.ps_postid =  NextId("POST")
		l_oData.ps_units  = -l_oData.ps_units
		l_oData.ps_amount = -l_oData.ps_amount
		l_oData.ps_vat0   = -l_oData.ps_vat0
		l_oData.ps_vat1   = -l_oData.ps_vat1
		l_oData.ps_vat2   = -l_oData.ps_vat2
		l_oData.ps_vat3   = -l_oData.ps_vat3
		l_oData.ps_vat4   = -l_oData.ps_vat4
		l_oData.ps_vat5   = -l_oData.ps_vat5
		l_oData.ps_vat6   = -l_oData.ps_vat6
		l_oData.ps_vat7   = -l_oData.ps_vat7
		l_oData.ps_vat8   = -l_oData.ps_vat8
		l_oData.ps_vat9   = -l_oData.ps_vat9
		sqlinsert("post","",5,l_oData)
	ENDSCAN
	IF FPBillPrinted("RESERVATION", l_nReserid, l_nWindow)
		l_cReverseBillNum = GetBill(,,,,l_nReserid, billnum.bn_addrid, -billnum.bn_amount, "REVERSE", l_nWindow, billnum.bn_apid)
		IF NOT EMPTY(l_cReverseBillNum)
			=SEEK(l_cReverseBillNum,"billnum","tag1")
			PBBonusUpdate(l_cReverseBillNum, l_nReserid, l_nWindow, billnum.bn_addrid)
			BillNumChange(l_cReverseBillNum, "CHKOUT", "No Print - Reverse bill")
			REPLACE bn_negnum WITH l_cBillnum IN billnum								&& Original bill number for Reverse bill.
			BillUpdate(l_nReserid, l_nWindow, l_cReverseBillNum)
			PDFArchiveBills("bn_billnum = " + SqlCnv(l_cReverseBillNum))
			GO l_nBnRecno IN billnum
			REPLACE bn_negnum WITH l_cReverseBillNum, bn_cxldate WITH sysdate() IN billnum	&& Reverse bill number for Original bill.
			lp_nWindow = BillReopen(l_cCur)
		ENDIF
	ENDIF
 ENDIF

 dclose(l_cCur)

 RETURN .T.
ENDPROC

PROCEDURE BillReopen
 LPARAMETERS lp_cCur
 LOCAL i, l_nWinpos, l_nWindow, l_oData, l_nRow, l_nResult, l_nRatio, l_nPostId
 LOCAL ARRAY l_aDefs(1,9), l_aSetId(1)

 SET FILTER TO NOT EMPTY(ps_artinum) AND NOT ps_split AND NOT INLIST(ps_userid, "POS       ", "WELLNESS  ") IN (lp_cCur)
 GO TOP IN (lp_cCur)

 l_nResult = 0
 IF NOT EOF(lp_cCur)
	* Choose which articles and payments would be moved to new bill.
	l_nRow = 1
	l_aDefs(l_nRow,1) = "EVL(ps_artinum,ps_paynum)"
	l_aDefs(l_nRow,2) = 30
	l_aDefs(l_nRow,3) = GetLangText("MGRPLIST","TXT_BASEL_SUPPL_NO")
	l_aDefs(l_nRow,4) = "TXT"
	l_aDefs(l_nRow,6) = .T.
	l_nRow = Aadd(@l_aDefs)
	l_aDefs(l_nRow,1) = "EVL(ps_descrip,EVL(tw_rclang,EVL(tw_arlang,tw_paylang)))"
	l_aDefs(l_nRow,2) = 100
	l_aDefs(l_nRow,3) = GetLangText("MGRFINAN","TXT_DESCRIPTION")
	l_aDefs(l_nRow,4) = "TXT"
	l_nRow = Aadd(@l_aDefs)
	l_aDefs(l_nRow,1) = "SUBSTR(DTOC(ps_date),1,5)"
	l_aDefs(l_nRow,2) = 50
	l_aDefs(l_nRow,3) = GetLangText("MGRRESER","TXT_DATE")
	l_aDefs(l_nRow,4) = "TXT"
	l_nRow = Aadd(@l_aDefs)
	l_aDefs(l_nRow,1) = "IIF(EMPTY(ps_artinum),'',ALLTRIM(TRANSFORM(ps_units,'9999'))+'x')"
	l_aDefs(l_nRow,1) = "tw_units"
	l_aDefs(l_nRow,2) = 40
	l_aDefs(l_nRow,3) = GetLangText("CHKOUT2","T_UNITS")
	l_aDefs(l_nRow,4) = "TXT"
	l_aDefs(l_nRow,9) = '9999x'
	l_nRow = Aadd(@l_aDefs)
	l_aDefs(l_nRow,1) = "IIF(EMPTY(ps_artinum),'',TRANSFORM(ROUND(ps_price,param.pa_currdec),RIGHT(gcCurrcyDisp,14)))"
	l_aDefs(l_nRow,2) = 60
	l_aDefs(l_nRow,3) = GetLangText("CHKOUT2","T_PRICE")
	l_aDefs(l_nRow,4) = "TXT"
	l_aDefs(l_nRow,8) = 1
	l_nRow = Aadd(@l_aDefs)
	l_aDefs(l_nRow,1) = "TRANSFORM(ROUND(IIF(EMPTY(ps_artinum),-1,1)*tw_units*ps_price,param.pa_currdec),RIGHT(gcCurrcyDisp,14))"
	l_aDefs(l_nRow,2) = 60
	l_aDefs(l_nRow,3) = GetLangText("CHKOUT2","T_AMOUNT")
	l_aDefs(l_nRow,4) = "TXT"
	l_nRow = Aadd(@l_aDefs)
	l_aDefs(l_nRow,1) = "tw_mark"
	l_aDefs(l_nRow,2) = 20
	l_aDefs(l_nRow,3) = ""
	l_aDefs(l_nRow,4) = "CHK"

	l_nResult = FNDoBrwMulSel(lp_cCur, @l_aDefs, GetLangText("BILL","TXT_KEEP_ARTICLES"))
 ENDIF
 SET FILTER TO IN (lp_cCur)

 IF l_nResult = 1
	l_aSetId(1) = 0
	SELECT DISTINCT ps_setid FROM (lp_cCur) WHERE ps_setid <> 0 AND NOT tw_mark AND NOT EMPTY(ps_artinum) AND NOT ps_split AND NOT INLIST(ps_userid, "POS       ", "WELLNESS  ") INTO ARRAY l_aSetId
	BLANK FIELDS tw_mark FOR tw_mark AND ps_setid <> 0 AND ASCAN(l_aSetId, ps_setid) > 0
	l_aSetId(1) = 0
	SELECT DISTINCT ps_setid, tw_units / ps_units FROM (lp_cCur) WHERE tw_units <> ps_units AND ps_setid <> 0 AND tw_mark AND NOT EMPTY(ps_artinum) AND NOT ps_split AND NOT INLIST(ps_userid, "POS       ", "WELLNESS  ") INTO ARRAY l_aSetId
	IF NOT EMPTY(l_aSetId(1))
		FOR i = 1 TO ALEN(l_aSetId,1)
			REPLACE tw_units WITH ps_units * l_aSetId(i,2) FOR ps_setid = l_aSetId(i,1) AND tw_mark AND ps_split AND NOT INLIST(ps_userid, "POS       ", "WELLNESS  ")
		ENDFOR
	ENDIF
 ELSE
	BLANK FIELDS tw_mark FOR tw_mark AND NOT EMPTY(ps_artinum) AND NOT INLIST(ps_userid, "POS       ", "WELLNESS  ")
 ENDIF

 l_nWinpos = FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_winpos")
 l_nWindow = PBPrepareFirstFreeWindow(billnum.bn_reserid, l_nWinpos, "REOPEN")
 FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_addrid",  IIF(billnum.bn_window = 1, billnum.bn_addrid, FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_addrid")))
 FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_billsty", FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_billsty"))
 FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_udbdate", FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_udbdate"))
 FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_bmsto1w", FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_bmsto1w"))
 FNSetWindowData(billnum.bn_rsid, l_nWindow, "pw_blamid",  FNGetWindowData(billnum.bn_rsid, billnum.bn_window, "pw_blamid"))

 REPLACE ps_window WITH l_nWindow ALL IN (lp_cCur)

 SELECT (lp_cCur)
 SCAN FOR tw_mark
	SCATTER NAME l_oData MEMO
	l_nPostId = NextId("POST")
	IF INLIST(ps_userid, "POS       ", "WELLNESS  ")		&& POS and WELLNESS records have old IDs because of relations and set new ID to original records.
		SqlUpdate("post", "ps_postid = " + SqlCnv(l_oData.ps_postid), "ps_postid = " + SqlCnv(l_nPostId) + ", ps_touched = .T.")
	ELSE
		l_oData.ps_postid = l_nPostId
	ENDIF
	IF tw_units <> ps_units
		l_nRatio = l_oData.tw_units / l_oData.ps_units
		l_oData.ps_units  = l_nRatio * l_oData.ps_units
		l_oData.ps_amount = l_nRatio * l_oData.ps_amount
		l_oData.ps_vat0   = l_nRatio * l_oData.ps_vat0
		l_oData.ps_vat1   = l_nRatio * l_oData.ps_vat1
		l_oData.ps_vat2   = l_nRatio * l_oData.ps_vat2
		l_oData.ps_vat3   = l_nRatio * l_oData.ps_vat3
		l_oData.ps_vat4   = l_nRatio * l_oData.ps_vat4
		l_oData.ps_vat5   = l_nRatio * l_oData.ps_vat5
		l_oData.ps_vat6   = l_nRatio * l_oData.ps_vat6
		l_oData.ps_vat7   = l_nRatio * l_oData.ps_vat7
		l_oData.ps_vat8   = l_nRatio * l_oData.ps_vat8
		l_oData.ps_vat9   = l_nRatio * l_oData.ps_vat9
	ENDIF
	sqlinsert("post","",5,l_oData)
 ENDSCAN
 FLUSH FORCE

RETURN l_nWindow
ENDPROC

PROCEDURE BillDeleteBillNumFromPosts
LPARAMETERS lp_nReserId, lp_nWindow, lp_cBillNum, lp_nAddrId
 LOCAL l_oBMSHandler

 REPLACE ps_billnum WITH "", ps_touched WITH .T. FOR ps_reserid = lp_nReserId AND ps_window = lp_nWindow IN post
 IF _screen.BMS
	IF NOT EMPTY(lp_cBillNum)
		* In BMS mode, this place is called when user cancels closed bill.
		* We mark all postings for this bill als canceled, points are deleted.
		l_oBMSHandler = NEWOBJECT("cBMSHandler", "common\progs\bmshandler.prg", "", SysDate(), g_userid, 1, ;
			_screen.oGlobal.oParam2.pa_bmstype, _screen.oGlobal.oParam2.pa_bsdays, _screen.oGlobal.oParam2.pa_hotcode)
		l_oBMSHandler.CancelPoints(lp_cBillNum)
	ENDIF
 ENDIF
 RETURN .T.
ENDPROC

PROCEDURE BillAmount
LPARAMETERS lp_nAmount, lp_cAlias, lp_nReserId, lp_nWindow, lp_cFilter
 LOCAL l_nArea, l_nRecNo, l_cForClause
 IF NOT EMPTY(lp_cAlias)
    l_nArea = SELECT()
    SELECT(lp_cAlias)
 ENDIF
 l_nRecNo = RECNO()
 IF EMPTY(lp_cFilter)
      lp_cFilter = "NOT ps_split"
 ENDIF
 l_cForClause = "ps_artinum<>0 AND NOT ps_cancel AND " + lp_cFilter + " "
 IF PCOUNT() > 2
    l_cForClause = "ps_reserid=lp_nReserId AND " + l_cForClause
    IF PCOUNT() > 3
        l_cForClause = l_cForClause + " AND ps_window=lp_nWindow"
    ENDIF
 ENDIF
 SUM ps_amount FOR &l_cForClause TO lp_nAmount
 GO l_nRecNo
 IF NOT EMPTY(lp_cAlias)
    SELECT(l_nArea)
 ENDIF
 RETURN lp_nAmount
ENDPROC

PROCEDURE BillIfcPrint
* This procedure evolved from IfcPrint in Interfac.prg.
 LPARAMETERS lp_nReserId, lp_nWindow, lp_lTel, lp_lPos, lp_lPTV, lp_lKey, lp_nPrint, lp_lInt
 LOCAL l_nAddrId, l_nRecNoAddr, l_cCurrLang, l_cFrx, l_cLangDbf, l_cForClause, l_cOutPut, ;
 		l_cAnotherPLUs, i, l_cOnePLU, l_cPostFor

 SELECT post
 LOCATE FOR ps_reserid = lp_nReserId AND ps_window = lp_nWindow
 IF NOT FOUND()
	RETURN .F.
 ENDIF
 IF lp_nWindow <> 1
	l_nAddrId = FNGetWindowData(reservat.rs_rsid, lp_nWindow, "pw_addrid")
	IF NOT EMPTY(l_nAddrId)
		l_nRecNoAddr = RECNO("address")
		IF NOT SEEK(l_nAddrId, "address")
			GO l_nRecNoAddr IN address
		ENDIF
	ENDIF
 ENDIF
 IF NOT param.pa_billlng OR (EMPTY(address.ad_lang) AND param.pa_billlng)
	l_cCurrLang = g_Language
 ELSE
	l_cCurrLang = ALLTRIM(address.ad_lang)
 ENDIF
 l_cFrx = gcReportdir + "bill2.frx"
 IF NOT FILE(l_cFrx)
	= alert(l_cFrx, "File not found")
	RETURN .F.
 ENDIF
 g_Rptlng = l_cCurrLang
 g_Rptlngnr = STR(dlookup('picklist', ;
			'pl_label=[LANGUAGE] AND pl_charcod = '+sqlcnv(l_cCurrLang), ;
			'pl_numval'), 1)
 IF g_Rptlngnr = '0'
	g_Rptlngnr = g_Langnum
 ENDIF
 l_cLangDbf = STRTRAN(UPPER(l_cFrx), '.FRX', '.DBF')
 IF FILE(l_cLangDbf)
	USE SHARED NOUPDATE (l_cLangDbf) ALIAS reptext IN 0
 ENDIF

 l_cForClause = ''
 IF lp_lTel
	l_cForClause = sqlor(l_cForClause,'PS_ARTINUM = PARAM.PA_PTTARTI')
 	IF param.pa_pttatbl AND FILE(gcDatadir+"ifcptt.dbf")
		LOCAL l_lCloseIfcptt, l_nSelect
		l_nSelect = SELECT()
		l_lCloseIfcptt = .F.
		IF NOT USED("ifcptt")
			openfiledirect(.F., "ifcptt")
			l_lCloseIfcptt = .T.
		ENDIF
		IF USED("ifcptt")
			SELECT ifcptt
			SCAN FOR NOT EMPTY(ifcptt.it_artinum)
				l_cForClause = sqlor(l_cForClause,'PS_ARTINUM = ' + sqlcnv(ifcptt.it_artinum))
			ENDSCAN
		ENDIF
		IF l_lCloseIfcptt AND USED("ifcptt")
			dclose("ifcptt")
		ENDIF
  		SELECT (l_nSelect)
 	ENDIF
 ENDIF
 IF lp_lPos
	l_cForClause = sqlor(l_cForClause,'PS_ARTINUM = ' + sqlcnv(PARAM.PA_POSARTI))
	IF NOT EMPTY(_screen.oGlobal.oParam2.pa_posarde)
		l_cAnotherPLUs = ALLTRIM(_screen.oGlobal.oParam2.pa_posarde)
		FOR i = 1 TO GETWORDCOUNT(l_cAnotherPLUs, ",")
			l_cOnePLU = ALLTRIM(GETWORDNUM(l_cAnotherPLUs, i, ","))
			IF ISDIGIT(l_cOnePLU)
				l_cForClause = sqlor(l_cForClause,'PS_ARTINUM = ' + sqlcnv(INT(VAL(l_cOnePLU))))
			ENDIF
		ENDFOR
	ENDIF
 ENDIF
 IF lp_lPTV
	l_cForClause = sqlor(l_cForClause,'PS_ARTINUM = PARAM.PA_PTVARTI')&& Changed von PTT on PTV!! 24.3.2002.
 ENDIF
 IF lp_lKey
	l_cForClause = sqlor(l_cForClause,'PS_ARTINUM = PARAM.PA_KEYARTI')
 ENDIF
 IF lp_lInt
	l_cForClause = sqlor(l_cForClause,"PS_ARTINUM = " + sqlcnv(_screen.oGlobal.oParam2.pa_intarti))
 ENDIF
 IF EMPTY(l_cForClause)
	l_cForClause = '.T.'
 ENDIF
 l_cPostFor = "ps_reserid = " + sqlcnv(lp_nReserId) + " AND ps_window = " + TRANSFORM(lp_nWindow) + " AND NOT ps_cancel AND NOT ps_split AND NOT EMPTY(ps_ifc)"
 IF _screen.oGlobal.lspecialfiscalprintermode
 	l_cPostFor = l_cPostFor + " AND NOT '@' $ ps_ifc"
 ENDIF
 SELECT * FROM post WHERE &l_cPostFor ;
 			ORDER BY ps_date, ps_paynum, ps_artinum INTO CURSOR tblIfcPost
 IF lp_nPrint = 1
	l_cOutPut = 'TO PRINTER'
	REPORT FORM (l_cFrx) FOR &l_cForClause NOCONSOLE &l_cOutPut
 ELSE
	LOCAL l_cFor, l_cReport, l_lNoListsTable, loSession, lnRetVal, l_lAutoYield, loXFF, loExtensionHandler, loPreview
	l_cFor = l_cForClause
	l_cReport = l_cFrx
	l_lNoListsTable = .T.
	IF g_lUseNewRepPreview
		loSession=EVALUATE([xfrx("XFRX#LISTENER")])
		lnRetVal = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
		IF lnRetVal = 0
			l_lAutoYield = _vfp.AutoYield
			_vfp.AutoYield = .T.
			REPORT FORM (l_cReport) FOR &l_cFor OBJECT loSession
			loXFF = loSession.oxfDocument 
			_vfp.AutoYield = l_lAutoYield
			loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
			loExtensionHandler.lNoListsTable = l_lNoListsTable
			loPreview = CREATEOBJECT("frmMpPreviewerDesk")
			loPreview.setExtensionHandler(loExtensionHandler)
			loPreview.PreviewXFF(loXFF)
			loPreview.show(1)
			loExtensionHandler = .NULL.
		ENDIF
	ELSE
		DO FORM forms\preview.scx NAME l_frmPreviw LINKED
		REPORT FORM (l_cReport) FOR &l_cFor PREVIEW NOCONSOLE
		RELEASE l_frmPreviw
	ENDIF
 ENDIF
 IF lp_nWindow <> 1
	IF NOT EMPTY(l_nAddrId)
		GO l_nRecNoAddr IN address
	ENDIF
 ENDIF
 = dclose('RepText')
 RETURN .T.
ENDPROC

PROCEDURE BillAddrId
 LPARAMETERS lp_nWindow, lp_nRsId, lp_nAddrId, lp_nRetAddrId
 LOCAL l_nWindow
 l_nWindow = lp_nWindow
 lp_nRetAddrId = 0
 IF l_nWindow > 1
	lp_nRetAddrId = FNGetWindowData(lp_nRsId, l_nWindow, "pw_addrid")
 ENDIF
 IF lp_nRetAddrId == 0
	lp_nRetAddrId = lp_nAddrId
 ENDIF
 RETURN lp_nRetAddrId && It is returned by reference too.
ENDPROC

PROCEDURE BillApId
 LPARAMETERS lp_nWindow, lp_nAddrId, lp_nCompId, lp_nInvId, lp_nApId, lp_nInvApId, lp_nRetApId
 DO CASE
 CASE lp_nWindow = 1 AND lp_nAddrId = lp_nCompId
	lp_nRetApId = lp_nApId
 CASE lp_nWindow = 2
	IF EMPTY(lp_nInvId)
		lp_nRetApId = lp_nApId
	ELSE
		lp_nRetApId = lp_nInvApId
	ENDIF
 OTHERWISE
	lp_nRetApId = 0
 ENDCASE
 RETURN lp_nRetApId
ENDPROC

PROCEDURE BillPayNum
 LPARAMETERS lp_nReserId, lp_nWindow, lp_nPayNum
 LOCAL l_nSelect, l_nRecNo, l_cOrder, l_lPostUsed
 l_nSelect = SELECT()
 l_lPostUsed = USED("post")
 IF NOT l_lPostUsed
	openfiledirect(.F., "post")
 ELSE
	l_nRecNo = RECNO("post")
	l_cOrder = ORDER("post")
	SET ORDER TO "" IN post
 ENDIF
 
 SELECT post
 lp_nPayNum = 0
 SCAN FOR ps_reserid = lp_nReserId AND ps_window = lp_nWindow AND ps_paynum <> 0 AND NOT ps_cancel
	lp_nPayNum = ps_paynum
 ENDSCAN

 IF NOT l_lPostUsed
	dclose("post")
 ELSE
	SET ORDER TO l_cOrder
	GO l_nRecNo
 ENDIF
 SELECT(l_nSelect)
 RETURN lp_nPayNum
ENDPROC

PROCEDURE BillUpdate
 LPARAMETERS lp_nReserId, lp_nWindow, lp_nBillNum, lp_lSpecLogin
 LOCAL l_oEnvironment

 l_oEnvironment = SetEnvironment("post, ledgpost, arpost")

 SELECT post
 SCAN FOR ps_reserid = lp_nReserId AND ps_window = lp_nWindow
	REPLACE ps_billnum WITH lp_nBillNum
	IF DLocate("ledgpost", "ld_postid = " + SqlCnv(ps_postid))
		REPLACE ld_billnum WITH lp_nBillNum IN ledgpost
		IF DLocate("arpost", "ap_postid = " + SqlCnv(ledgpost.ld_postid))
			REPLACE ap_billnr WITH ledgpost.ld_billnum IN arpost
		ENDIF
	ENDIF
	IF NOT lp_lSpecLogin AND ps_date <> SysDate()
		REPLACE ps_touched WITH .T.
	ENDIF
 ENDSCAN

 RETURN .T.
ENDPROC

FUNCTION BillNumDate
LPARAMETERS lp_nReserId, lp_nWindow, lp_dBillDate
 LOCAL l_nRecNoRes, l_lUsed, l_nRecNoBill, l_cBillNum
 lp_dBillDate = SysDate()
 l_nRecNoRes = RECNO("reservat")
 IF (lp_nReserId <> reservat.rs_reserid) AND NOT DLocate("reservat", "rs_reserid = "+SqlCnv(lp_nReserId))
	GO l_nRecNoRes IN reservat
	RETURN lp_dBillDate
 ENDIF
 l_lUsed = USED("billnum")
 IF l_lUsed
	l_nRecNoBill = RECNO("billnum")
 ELSE
	DOpen("billnum")
 ENDIF
 l_dBillDate = FNGetBillData(reservat.rs_reserid, lp_nWindow, "bn_date")
 IF NOT EMPTY(l_dBillDate)
	lp_dBillDate = l_dBillDate
 ENDIF
 IF l_lUsed
	GO l_nRecNoBill IN billnum
 ELSE
	DClose("billnum")
 ENDIF
 GO l_nRecNoRes IN reservat
 RETURN lp_dBillDate
ENDFUNC

PROCEDURE BillReportHeader
 LPARAMETERS lp_lHistory, lp_nBillWindow, lp_aReportHeader
 EXTERNAL ARRAY lp_aReportHeader
 DIMENSION lp_aReportHeader(8)
 LOCAL l_oAddress, l_nSelect, l_cJSON, l_oJSON
 l_nSelect = SELECT()
 
 l_oAddress = .NULL.
 IF NOT EMPTY(g_BillNum)
      * When address for this bill was deleted, then real address was saved in bn_address field as JSON.
      l_cJSON = dlookup("billnum","bn_billnum = " + sqlcnv(g_BillNum,.T.),"bn_address")
      IF NOT EMPTY(l_cJSON)
           l_oJSON = NEWOBJECT("json","common\progs\json.prg")
           TRY
                l_oAddress = l_oJSON.parse(l_cJSON)
           CATCH
           ENDTRY
      ENDIF
 ENDIF
 IF ISNULL(l_oAddress)
      SELECT address
      SCATTER FIELDS ad_company, ad_title, ad_departm, ad_addrid, ad_lname, ad_fname, ad_street, ad_street2, ad_zip, ad_city, ad_country NAME l_oAddress
 ENDIF

 lp_aReportHeader(1) = IIF(EMPTY(l_oAddress.ad_company), ALLTRIM(l_oAddress.ad_title), l_oAddress.ad_company)
 lp_aReportHeader(2) = ALLTRIM(l_oAddress.ad_departm)
 IF lp_lHistory
	 DO CASE
	 	CASE lp_nBillWindow = 2 AND histres.hr_invapid <> 0
	 		lp_aReportHeader(3) = ALLTRIM(histres.hr_invap)
	 	CASE lp_nBillWindow = 2 AND histres.hr_invid = 0 AND histres.hr_apid <> 0 OR ;
				lp_nBillWindow <> 2 AND histres.hr_compid = l_oAddress.ad_addrid AND histres.hr_lname <> UPPER(l_oAddress.ad_lname)
			lp_aReportHeader(3) = ALLTRIM(histres.hr_apname)
		OTHERWISE
			lp_aReportHeader(3) = IIF(EMPTY(l_oAddress.ad_company), "", LTRIM(RTRIM(l_oAddress.ad_title) + " ")) + ;
				LTRIM(RTRIM(l_oAddress.ad_fname) + " ") + Flip(l_oAddress.ad_lname)
	 ENDCASE
 ELSE
	 DO CASE
	 	CASE lp_nBillWindow = 2 AND reservat.rs_invapid <> 0
	 		lp_aReportHeader(3) = ALLTRIM(reservat.rs_invap)
	 	CASE lp_nBillWindow = 2 AND reservat.rs_invid = 0 AND reservat.rs_apid <> 0 OR ;
				lp_nBillWindow <> 2 AND reservat.rs_compid = l_oAddress.ad_addrid AND reservat.rs_apid <> 0
			lp_aReportHeader(3) = ALLTRIM(reservat.rs_apname)
		OTHERWISE
			lp_aReportHeader(3) = IIF(EMPTY(l_oAddress.ad_company), "", LTRIM(RTRIM(l_oAddress.ad_title) + " ")) + ;
				LTRIM(RTRIM(l_oAddress.ad_fname) + " ") + Flip(l_oAddress.ad_lname)
	 ENDCASE
 ENDIF
 lp_aReportHeader(4) = l_oAddress.ad_street
 lp_aReportHeader(5) = l_oAddress.ad_street2
 lp_aReportHeader(6) = LTRIM(RTRIM(l_oAddress.ad_zip) + "  ") + l_oAddress.ad_city
 lp_aReportHeader(7) = IIF(l_oAddress.ad_country = param.pa_country, "", ;
	DLookUp('PickList', 'pl_label = [COUNTRY] AND pl_charcod = ' + SqlCnv(l_oAddress.ad_country), ;
	'pl_lang' + g_RptLngNr))
 lp_aReportHeader(8) = DLookUp('PickList', 'pl_label = [COUNTRY] AND pl_charcod = ' + SqlCnv(EVL(l_oAddress.ad_country,param.pa_country)), 'pl_user2')
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC

PROCEDURE BillNewOldNum
LPARAMETERS lp_nReserId, lp_nWindow, lp_cNewNum, lp_cOldNum
 LOCAL l_oEnvironment, l_cNew

 lp_cOldNum = ""
 IF lp_nReserId > 1
	l_oEnvironment = SetEnvironment("billnum")
	CursorQuery("billnum", StrToSql("bn_reserid = %n1", lp_nReserId))
	l_cNew = lp_cNewNum
	SELECT billnum
	SET ORDER TO tag1 DESCENDING
	SCAN FOR bn_billnum <> lp_cNewNum AND bn_reserid = lp_nReserId AND bn_window = lp_nWindow AND EMPTY(bn_newnum)
		IF EMPTY(lp_cOldNum)
			lp_cOldNum = bn_billnum
		ENDIF
		REPLACE bn_newnum WITH l_cNew
		l_cNew = bn_billnum
	ENDSCAN
	SET ORDER TO
 ENDIF

 RETURN lp_cOldNum
ENDPROC

PROCEDURE BillCancelPost
LPARAMETERS lp_cReason, lp_dCancelFrom
* Cancel posting in post table
LOCAL l_nSelect, l_nRecno, l_oOldPost, l_oNewPost, l_nResId, l_nSetId, l_nMainRecno, l_cOrder, l_nPrice, l_oBMSHandler
IF EMPTY(lp_cReason)
	lp_cReason = ""
ENDIF
l_nSelect = SELECT()
SELECT post

l_nMainRecno = RECNO()

CursorQuery("rpostifc", StrToSql("rk_setid = %n1", post.ps_setid))
DO CASE
	CASE _screen.oGlobal.lUgos AND NOT EMPTY(post.ps_setid) AND DLocate("rpostifc", "rk_setid = " + SqlCnv(post.ps_setid))
		IF EMPTY(lp_dCancelFrom)
			lp_dCancelFrom = rpostifc.rk_from
		ENDIF
		IF lp_dCancelFrom <= rpostifc.rk_to
			l_nPrice = post.ps_price * (rpostifc.rk_to-lp_dCancelFrom+1)/(rpostifc.rk_to-rpostifc.rk_from+1)
			DO PostRate IN RatePost WITH "Post", "POST_DEL", -post.ps_units, l_nPrice, ;
				1, 0, 0, 0, post.ps_window,,,, .T., lp_dCancelFrom, rpostifc.rk_to, post.ps_setid
		ENDIF
	CASE NOT EMPTY(post.ps_ratecod) AND post.ps_setid > 0
		l_nResId = post.ps_reserid
		l_nSetId = post.ps_setid
		l_nRecNo = RECNO("post")
		l_cOrder = ORDER("post")
		SET ORDER TO 0 IN post
		SELECT post
		SCAN FOR (ps_reserid = l_nResId) AND (ps_setid = l_nSetId)
			SCATTER NAME l_oOldPost
			REPLACE ps_descrip WITH lp_cReason, ;
					ps_cancel WITH .T. IN post
			SCATTER NAME l_oNewPost
			IF NOT EMPTY(ps_voucnum) AND NOT EMPTY(ps_artinum)
				DO VoucherCancel IN ProcVoucher WITH ps_voucnum, ps_amount/ps_units
			ENDIF
			PostHistory(l_oOldPost, l_oNewPost,"DELETED")
		ENDSCAN
		SET ORDER TO l_cOrder IN post
		GO l_nRecNo IN post
	CASE article.ar_artityp == 2
		SCATTER NAME l_oOldPost
		REPLACE post.ps_descrip WITH lp_cReason, post.ps_cancel WITH .T.
		SCATTER NAME l_oNewPost
		PostHistory(l_oOldPost, l_oNewPost,"DELETED")
		SCATTER MEMVAR
		m.ps_artinum = 0
		m.ps_cancel = .F.
		IF param.pa_currloc <> 0
			m.ps_paynum = param.pa_currloc
		ELSE
			m.ps_paynum = IIF(EMPTY(_screen.oGlobal.oParam2.pa_paidopm),1,_screen.oGlobal.oParam2.pa_paidopm)
		ENDIF
		m.ps_supplem = get_rm_rmname(reservat.rs_roomnum)+' '+MakeProperName(reservat.rs_lname)
		m.ps_reserid = 0.200
		m.ps_origid = 0.200
		m.ps_price = 1.00
		m.ps_units = m.ps_amount
		m.ps_amount = -m.ps_amount
		m.ps_vat0 = 0.00
		m.ps_vat1 = 0.00
		m.ps_vat2 = 0.00
		m.ps_vat3 = 0.00
		m.ps_vat4 = 0.00
		m.ps_vat5 = 0.00
		m.ps_vat6 = 0.00
		m.ps_vat7 = 0.00
		m.ps_vat8 = 0.00
		m.ps_vat9 = 0.00
		m.ps_postid = nextid('post')
		INSERT INTO post FROM MEMVAR
		SELECT post
		SCATTER NAME l_oOldPost BLANK
		SCATTER NAME l_oNewPost
		PostHistory(l_oOldPost, l_oNewPost,"CREATED")
	OTHERWISE
		IF _screen.BMS
			IF NOT EMPTY(_screen.oGlobal.oParam2.pa_bmspay)
				IF post.ps_paynum>0 AND post.ps_paynum = _screen.oGlobal.oParam2.pa_bmspay
					l_oBMSHandler = NEWOBJECT("cBMSHandler", "common\progs\bmshandler.prg", "", SysDate(), g_userid, 1, ;
							_screen.oGlobal.oParam2.pa_bmstype, _screen.oGlobal.oParam2.pa_bsdays)
					l_oBMSHandler.CancelBonusPayment(post.ps_postid)
				ENDIF
			ENDIF
		ENDIF
		SCATTER NAME l_oOldPost
		REPLACE post.ps_descrip WITH lp_cReason, post.ps_cancel WITH .T.
		SCATTER NAME l_oNewPost
		IF NOT EMPTY(ps_voucnum) AND NOT EMPTY(ps_artinum)
			DO VoucherCancel IN ProcVoucher WITH ps_voucnum
		ENDIF
		PostHistory(l_oOldPost, l_oNewPost,"DELETED")
ENDCASE
GO l_nMainRecno IN post
SELECT (l_nSelect)
RETURN .T.
ENDPROC

*PROCEDURE BillsCheckOutUpdate
*LPARAMETERS lp_nReserId
* LOCAL l_nArea, l_nRecNoRes, l_lUsed, l_nRecNoBill
* l_nArea = SELECT()
* l_nRecNoRes = RECNO("reservat")
* IF (lp_nReserId <> reservat.rs_reserid) AND ;
*		NOT SEEK(lp_nReserId,"reservat","tag1")
*	GO l_nRecNoRes IN reservat
*	RETURN lp_lValid
* ENDIF
* l_lUsed = USED("billnum")
* IF l_lUsed
*	l_nRecNoBill = RECNO("billnum")
* ELSE
*	USE data\billnum IN 0 SHARED
* ENDIF
* LOCAL l_nBillWin, l_cField
* FOR l_nBillWin = 1 TO 6
*	l_cField = "reservat.rs_billnr" + ALLTRIM(STR(l_nBillWin))
*	IF NOT EMPTY(EVALUATE(l_cField))
*		LOCAL l_nRecNoPost
*		l_nRecNoPost = RECNO("post")
*		SELECT post
*		LOCATE FOR ps_reserid = reservat.rs_reserid AND ;
*				ps_window = l_nBillWin AND NOT ps_cancel AND NOT ps_split
*		IF NOT FOUND("post")
*			= BillNumChange(EVALUATE(l_cField), "CANCEL", ;
*					"AUTOMATIC - CHECK OUT")
*		ENDIF
*		GO l_nRecNoPost IN post
*	ENDIF
* ENDFOR
* IF l_lUsed
*	GO l_nRecNoBill IN billnum
* ELSE
*	USE IN billnum
* ENDIF
* GO l_nRecNoRes IN reservat
* SELECT(l_nArea)
* RETURN .T.
*ENDPROC

PROCEDURE CheckOutPrepare
 LPARAMETERS l_nReserId
 LOCAL l_nRoom
 l_nRoom = postroom()
 DO ifcpost IN interfac WITH l_nReserId, l_nRoom
ENDPROC

PROCEDURE CheckOutYesNo
LPARAMETERS lp_lRetYesNo, lp_lSilent
 DO CASE
  CASE EMPTY(reservat.rs_in) AND INLIST(reservat.rs_status, "DEF", "6PM", "ASG")
	IF NOT lp_lSilent
		lp_lRetYesNo = yesno(GetLangText("BILL","TXT_PRELIMINARY_INVOICE"))
	ELSE
		lp_lRetYesNo = .T.
	ENDIF
  CASE EMPTY(reservat.rs_in)
	IF NOT lp_lSilent
		= alert(GetLangText("CHKOUT2","TXT_NOTCHECKEDIN")+"!")
	ENDIF
	lp_lRetYesNo = .F.
  CASE NOT EMPTY(reservat.rs_out)
	lp_lRetYesNo = .F.
  OTHERWISE
	lp_lRetYesNo = .T.
 ENDCASE
 RETURN lp_lRetYesNo
ENDPROC

PROCEDURE CheckOutType
LPARAMETERS lp_nRetType, lp_nWindow, lp_dBillToDate, lp_cBillToDateCaption, lp_dSelectedToBillDate
LOCAL l_dBillToDate, i, l_cSupplem, l_oReser, l_lNoMessage, l_dRateDat, l_dForDate
 IF EMPTY(lp_nWindow)
 	lp_nWindow = 1
 ENDIF
 IF (reservat.rs_depdate>sysdate()) OR (reservat.rs_arrdate=reservat.rs_depdate AND reservat.rs_depdate>=sysdate())
	IF EMPTY(lp_nRetType)
		IF reservat.rs_arrdate=reservat.rs_depdate
			* For 0-day reservations, the is no early departure. So, don't show form with this question. Assume its checkout.
			lp_nRetType = 1
		ELSE
			IF g_lAutomationMode
				* In automation mode always allow check out. Caller must check if check out was planed for today.
				lp_nRetType = 1
			ELSE
				DO FORM forms\nodepartureform TO lp_nRetType
			ENDIF
		ENDIF
	ENDIF
	IF lp_nRetType = 2
		IF EMPTY(lp_dBillToDate)
			IF EMPTY(reservat.rs_rfixdat)
				l_dRateDat = reservat.rs_ratedat
			ELSE
				l_dRateDat = MIN(reservat.rs_ratedat, reservat.rs_rfixdat)
			ENDIF
			DO FORM forms\GetDateFromRange WITH "BILL_TO_DATE", reservat.rs_depdate, l_dRateDat+1, reservat.rs_depdate, lp_cBillToDateCaption TO l_dBillToDate
			lp_dSelectedToBillDate = l_dBillToDate
		ELSE
			l_dBillToDate = lp_dBillToDate
		ENDIF
		IF EMPTY(l_dBillToDate)
			lp_nRetType = 0
		ENDIF
	ENDIF
	DO CASE
		CASE lp_nRetType == 1
			SELECT reservat
			SCATTER NAME l_oReser MEMO
			l_oReser.rs_odepdat = l_oReser.rs_depdate
			l_oReser.rs_depdate = SysDate()
			DO CheckAndSave IN ProcReservat WITH l_oReser, .T., .F., "CHECKOUT"
			DO RatecodePost IN RatePost WITH reServat.rs_depdate, "CHECKOUT"
		CASE lp_nRetType == 2
			IF reservat.rs_rooms > 1
				* Post for all rooms in unsplitted reservation.
				* Lock reservat record, to prevent another user to change it, while
				* replacing rs_ratedat for every room.
				SELECT reservat
				SCATTER NAME l_oReser MEMO
				l_lNoMessage = .T.
				IF dlock("reservat",5,l_lNoMessage) 
					l_dRateDat = reservat.rs_ratedat
					l_cSupplem = GetLangText("CHKOUT1","TH_GROUP")+":"+TRANSFORM(INT(reservat.rs_reserid))
					FOR i = 1 TO reservat.rs_rooms
						l_dForDate = MIN(l_dBillToDate,IIF(reServat.rs_arrdate=reServat.rs_depdate,reServat.rs_depdate,reServat.rs_depdate - 1))
						DO RatecodePost IN RatePost WITH l_dForDate, "", lp_nWindow, l_cSupplem
						IF i < reservat.rs_rooms
							* set back previous reservat settings, for next reservation
							REPLACE reservat.rs_ratedat WITH l_oReser.rs_ratedat, ;
									reservat.rs_ratein WITH l_oReser.rs_ratein, ;
									reservat.rs_rateout WITH l_oReser.rs_rateout ;
									IN reservat
						ENDIF
					ENDFOR
					dunlock("reservat")
				ENDIF
			ELSE
				l_dForDate = MIN(l_dBillToDate,IIF(reServat.rs_arrdate=reServat.rs_depdate,reServat.rs_depdate,reServat.rs_depdate - 1))
				DO RatecodePost IN RatePost WITH l_dForDate, "", lp_nWindow
			ENDIF
			IF l_dBillToDate = reservat.rs_depdate
				DO ratecodepost IN RatePost WITH reservat.rs_depdate, "CHECKOUT", lp_nWindow
			ENDIF
		OTHERWISE
			lp_nRetType = 0
	ENDCASE
 ELSE
	lp_nRetType = 1
 ENDIF
 RETURN lp_nRetType
ENDPROC

PROCEDURE CheckOutWithBalance
LPARAMETERS lp_lCheckOutWithBalance, lp_lAllowed
lp_lAllowed = lp_lCheckOutWithBalance AND ;
		(;
		g_lAutomationMode ;
		)
RETURN lp_lAllowed
ENDPROC

PROCEDURE CheckOutProcess
LPARAMETERS lp_nbIllwindow, lp_plPrint, lp_lSettled, lp_lAllowCheckOutWithBalance, lp_oBillForm, lp_lNoCheckOut

LOCAL l_nWindow, l_nBalance, l_lPostPayment, l_nAddrId, l_nPayMethRecNo, ;
		l_oPaymetho, l_oCheckRes, l_nLastUsedPayMethRecNo
lp_lSettled = .T.
l_nWindow = lp_nbIllwindow
l_nPayMethRecNo = RECNO("paymetho")
IF  .NOT. dePspec()
	RETURN .F.
ENDIF
IF lp_nbIllwindow == 0
	IF (balance(reservat.rs_reserid,2)+balance(reservat.rs_reserid,3)+ ;
		balance(reservat.rs_reserid,4)+balance(reservat.rs_reserid,5)+ ;
		balance(reservat.rs_reserid,6) <> 0.00)
		= alert(GetLangText("CHKOUT2","TA_HAS2BILL")+"!")
		RETURN .F.
	ELSE
		l_nWindow = 1
		l_nBalance = balance(reservat.rs_reserid, l_nWindow)
	ENDIF
ELSE
	l_nBalance = balance(reservat.rs_reserid, l_nWindow)
ENDIF
l_lPostPayment = .F.
PBBonusDiscount(l_nWindow)
PBAdjustPrices(reservat.rs_reserid, l_nWindow)
IF l_nBalance <> 0
	IF (reservat.rs_depdate = SysDate()) AND CheckOutWithBalance(lp_lAllowCheckOutWithBalance)
		IF NOT reservat.rs_cowibal
			REPLACE rs_changes WITH RsHistry(reservat.rs_changes,"CHECKOUT",GetLangText("BILL","TXT_CHECKOUT_WITH_BALANCE")) IN reservat
			REPLACE rs_cowibal WITH .T. IN reservat
		ENDIF
		lp_lSettled = .T.
	ELSE
		lp_lSettled = .F.
		l_lPostPayment = .T.

		l_nAddrId = BillAddrId(l_nWindow,reservat.rs_rsid,reservat.rs_addrid)

		DO FORM "forms/postpay" ;
				WITH "BILL_CHKOUT", l_nWindow, l_nAddrId ;
				TO l_nLastUsedPayMethRecNo
		IF VARTYPE(l_nLastUsedPayMethRecNo)<>"N" && Because of elPay partial payment, form is closed before balance is set to 0.00
			lp_lSettled = .F.
			FNNextIdTempWriteRealId("post", "ps_postid", "POST")
		ELSE
			IF l_nLastUsedPayMethRecNo <> 0
				l_nPayMethRecNo = l_nLastUsedPayMethRecNo
				lp_lSettled = .T.
				FNNextIdTempWriteRealId("post", "ps_postid", "POST")
			ENDIF
		ENDIF
	ENDIF
ELSE
	IF reservat.rs_cowibal
		REPLACE rs_cowibal WITH .F. IN reservat
	ENDIF
ENDIF
GO l_nPayMethRecNo IN paymetho
IF lp_lSettled
	***********************************************
	* post alias has relation to paymetho alias !
	IF NOT l_lPostPayment
		LOCAL l_nPaynum
		l_nPaynum = BillPayNum(reservat.rs_reserid,l_nWindow)
		SELECT paymetho
		IF SEEK(l_nPaynum,"paymetho","tag1")
			SCATTER MEMO NAME l_oPaymetho
		ELSE
			SCATTER MEMO NAME l_oPaymetho BLANK
		ENDIF
	ELSE
		SELECT paymetho
		SCATTER MEMO NAME l_oPaymetho
	ENDIF
	***********************************************
	l_oCheckRes = CREATEOBJECT("checkreservat")
	IF NOT EMPTY(l_oPaymetho.pm_paymeth)
		l_oCheckRes.resset_one_field_change("rs_paymeth", l_oPaymetho.pm_paymeth)
	ENDIF
	RELEASE l_oCheckRes
	SELECT reservat
	IF NOT lp_lNoCheckOut AND ;
			(reservat.rs_depdate <= SysDate()) AND (reservat.rs_cowibal OR (balance(reservat.rs_reserid,1)+ ;
			balance(reservat.rs_reserid,2)+balance(reservat.rs_reserid,3)+ ;
			balance(reservat.rs_reserid,4)+balance(reservat.rs_reserid,5)+ ;
			balance(reservat.rs_reserid,6)==0.00))
		LOCAL l_oReser
		SELECT reservat
		SCATTER NAME l_oReser MEMO
		l_oReser.rs_codate = sysdate()
		l_oReser.rs_cotime = TIME()
		l_oReser.rs_out = "1"
		l_oReser.rs_status = "OUT"
		l_oReser.rs_posstat = "0"
		l_oReser.rs_xchkout = .F.
		DO CheckAndSave IN ProcReservat WITH l_oReser, .T., .F., "CHECKOUT"
		DO ifccheck IN Interfac WITH reservat.rs_roomnum, "CHECKOUT"
		PAAddressConsent(reservat.rs_reserid)
		IF NOT g_lAutomationMode
			WAIT WINDOW NOWAIT get_rm_rmname(reservat.rs_roomnum)+" "+ ;
					TRIM(PROPER(reservat.rs_lname))+" OUT"
		ENDIF
		FLUSH
		*= BillsCheckOutUpdate(reservat.rs_reserid)
		IF openfile(.F.,"laststay",.F.,.T.)
			DO LsResUpd IN AaUpd WITH reservat.rs_reserid
			SELECT reservat
		ENDIF
		IF NOT EMPTY(_screen.oGlobal.oParam2.pa_comsg)
			IF INLIST(DLookup('RoomType', 'rt_roomtyp = ' + SqlCnv(reservat.rs_roomtyp),'rt_group'), 1, 4)
				alert(_screen.oGlobal.oParam2.pa_comsg)
			ENDIF
		ENDIF
	ENDIF
	IF param.pa_autoprn AND lp_plPrint AND NOT reservat.rs_cowibal AND NOT g_lAutomationMode
		glcheckout = .T.
		LOCAL l_frmBillPrint
		DO FORM "forms\billprint" NAME l_frmBillPrint LINKED ;
				WITH reservat.rs_reserid, l_nWindow, MAX(l_oPaymetho.pm_copy,1), .T., lp_oBillForm ;
				NOSHOW
		RELEASE l_frmBillPrint
		glcheckout = .F.
	ENDIF
	IF (SEEK(reservat.rs_roomnum, "Room",'tag1'))
		IF NOT lp_lNoCheckOut
			REPLACE room.rs_message WITH ""
			REPLACE room.rs_msgshow WITH .F.
		ENDIF
	ENDIF
	IF (lp_nbIllwindow == 0) AND NOT g_lAutomationMode
		LOCAL l_nAmount, l_nBillcopy, l_cBillNum
		l_nAmount = BillAmount(l_nAmount, "post", reservat.rs_reserid, 1)
		IF l_nAmount <> 0
			l_cBillNum = FNGetBillData(reservat.rs_reserid, 1, "bn_billnum")
			IF EMPTY(l_cBillNum)
				IF FPBillPrinted("RESERVATION", reservat.rs_reserid, 1)
					LOCAL laSktype, llEdger, lcReditnote, lcHeckout
					laSktype = .F.
					llEdger = .F.
					lcReditnote = .F.
					lcHeckout = lp_plPrint
					l_nAmount = BillAmount(l_nAmount, "post", reservat.rs_reserid, 1)
					l_nAddrId = BillAddrId(l_nWindow,reservat.rs_rsid,reservat.rs_addrid)
					l_nApId = BillApId(l_nWindow,reservat.rs_addrid,reservat.rs_compid,reservat.rs_invid, ;
							reservat.rs_apid,reservat.rs_invapid)
					l_cBillNum = GetBill(lasktype,lledger,lcreditnote,lcheckout, ;
							reservat.rs_reserid,l_nAddrId,l_nAmount,"CHECK OUT", ;
							l_nWindow,l_nApId)
					PBBonusUpdate(l_cBillNum, reservat.rs_reserid, 1, l_nAddrId)
				ENDIF
			ENDIF
			IF NOT EMPTY(l_cBillNum)
				= BillNumChange(l_cBillNum, "CHKOUT", "No Print - Quick Out", 0, l_nAmount)
				= BillUpdate(reservat.rs_reserid, 1, l_cBillNum)
				l_nBillcopy = FNGetWindowData(reservat.rs_rsid, 1, "pw_copy")
				FNSetWindowData(reservat.rs_rsid, 1, "pw_copy", MIN(99, l_nBillcopy+1))
				LOCAL cnAme, cbIllnum, cfXp
				cnAme = TRIM(address.ad_title)+" "+TRIM(address.ad_fname)+" "+ ;
							TRIM(flIp(address.ad_lname))
				cbIllnum = l_cBillNum
			ENDIF
		ENDIF
		= BillsReserRefresh()
	ENDIF
ENDIF
RETURN lp_lSettled && It's returned by reference too.
ENDPROC

PROCEDURE PbPDFArchiveBills
LOCAL loSession, llSuccess

IF NOT _screen.oGlobal.lGobdActive
	RETURN .T.
ENDIF

DO SetMessagesOff IN ProcMessages
loSession = CREATEOBJECT("PrivateSession")
llSuccess = loSession.CallProc("ProcBill('PDFArchiveBills')")
DO SetMessagesOn IN ProcMessages

RETURN llSuccess
ENDPROC

PROCEDURE PDFArchiveBills
LPARAMETERS tcWhere
LOCAL loEnvironment, lnBillCnt, llUseBDateInStyle, lnStyle, lnCurrent, lnBillCnt

loEnvironment = SetEnvironment("address,param,picklist,billnum,histres,reservat,histpost,post,ratecode,article,paymetho,aracct,hpwindow,pswindow,ratearti,resrart,hresrart,postcxl,prtypes","tag1")

_screen.oGlobal.dGobdFromsysdate = EVL(_screen.oGlobal.dGobdFromsysdate, SysDate())

tcWhere = EVL(tcWhere, 'bn_date >= _screen.oGlobal.dGobdFromsysdate AND NOT bn_pdf AND bn_status = "PCO"')
SELECT billnum
COUNT FOR &tcWhere TO lnBillCnt
IF lnBillCnt > 0
	ON KEY LABEL ALT+Q GO BOTTOM IN billnum
	lnCurrent = 0
ENDIF
SCAN FOR &tcWhere
	lnCurrent = lnCurrent + 1
	IF ROUND(100*lnCurrent/lnBillCnt,0) > ROUND(100*(lnCurrent-1)/lnBillCnt,0)&&ROUND(100*RECNO()/RECCOUNT(),0) > lnCurrent; lnCurrent = ROUND(100*RECNO()/RECCOUNT(),0)
		WAIT "PDF/A-3 e-invoice: " + TRANSFORM(ROUND(100*lnCurrent/lnBillCnt,0))+" %" WINDOW NOWAIT
	ENDIF
	IF billnum.bn_reserid = 0.100
		BillHist("PrintPassCopy", billnum.bn_billnum,,.T.)
	ELSE
		lnStyle = ProcBillStyle(billnum.bn_rsid, billnum.bn_window, @llUseBDateInStyle, NOT SEEK(billnum.bn_reserid, "reservat", "tag1"))
		BillHist("PrintCopy", billnum.bn_reserid, billnum.bn_window,,lnStyle, llUseBDateInStyle, billnum.bn_addrid,,,,,.T.)
	ENDIF
	SELECT billnum
ENDSCAN
IF lnBillCnt > 0
	WAIT CLEAR
	ON KEY LABEL ALT+Q
ENDIF

RETURN .T.
ENDPROC

PROCEDURE PbCreateZUGFeRDXml
LPARAMETERS tcXmlFile, tcurData
LOCAL lcXml, lcXmlArticle, lcXmlBillNote, lcXmlSummaryTax, lcXmlDiscountAdditions, lcXmlSegment, lcArticles, lcNotes, lcTaxes, lcDiscounts, lcurPsData, lcPostFields, lcHistPostFields
LOCAL i, llHistory, lnWindow, lnReserid, ldArrdate, ldDepdate, lcTitle, lcDepartment, lcName, lcStreet1, lcStreet2, lcCity, lcCountry, lnVat, lnRsid, lcNote, lnPayment, lnVatSum, lnNetSum
LOCAL lnChargeSum, lnAllowanceSum, lnAddrId, lcDiscount, lnRecno, lcNegBillnum, llDebitor
LOCAL ARRAY laDisc(1), laVat(1), laPaytyp(1), laReportHeader(8)

lnRecno = RECNO("reservat")
STORE 0 TO lnWindow, lnAddrId
llHistory = NOT EMPTY(g_BillNum) AND SEEK(g_BillNum, "billnum", "tag1") AND billnum.bn_reserid <> 0.100 AND NOT SEEK(billnum.bn_reserid, "reservat", "tag1")
lnWindow = billnum.bn_window
lnAddrId = billnum.bn_addrid
lcNegBillnum = billnum.bn_negnum
BillReportHeader(llHistory, lnWindow, @laReportHeader)
lcTitle = laReportHeader(1)
lcDepartment = laReportHeader(2)
lcName = laReportHeader(3)
lcStreet1 = laReportHeader(4)
lcStreet2 = laReportHeader(5)
lcCity = laReportHeader(6)
lcCountry = laReportHeader(8)
OpenFileDirect(,"picklist", "dsc")
OpenFileDirect(,"picklist", "vat")

llHistory = (TYPE(tcurData+".hp_billnum") = "C")
IF llHistory
	lcurPsData = SYS(2015)
	CursorPrintBillCreate(lcurPsData)
	GetPostFields(lcurPsData, tcurData, @lcPostFields, @lcHistPostFields)
	INSERT INTO &lcurPsData (&lcPostFields) SELECT &lcHistPostFields FROM &tcurData
	llHistory = .T.
	GO TOP IN &lcurPsData
	=SEEK(&lcurPsData..ps_origid,"histres","tag1")
	lnReserid = histres.hr_reserid
	lnRsid = histres.hr_rsid
	ldArrdate = histres.hr_arrdate
	ldDepdate = histres.hr_depdate
	ldCreated = histres.hr_created
	lcDiscount = histres.hr_discnt
	SELECT pl_charcod, pl_numval, SUM(ps_amount) FROM &lcurPsData ;
		INNER JOIN histres ON hr_reserid = ps_origid ;
		INNER JOIN picklist ON pl_label+pl_charcod= "DISCOUNT  "+hr_discnt ;
		WHERE ps_artinum > 0 ;
		GROUP BY 1,2 ;
		ORDER BY 2 ;
		INTO ARRAY laDisc
ELSE
	lcurPsData = tcurData
	GO TOP IN &lcurPsData
	=SEEK(&lcurPsData..ps_origid,"reservat","tag1")
	lnReserid = reservat.rs_reserid
	lnRsid = reservat.rs_rsid
	lnArrdate = reservat.rs_arrdate
	lnDepdate = reservat.rs_depdate
	ldCreated = reservat.rs_created
	lcDiscount = reservat.rs_discnt
	SELECT pl_charcod, pl_numval, SUM(ps_amount) FROM &lcurPsData ;
		INNER JOIN reservat ON rs_reserid = ps_origid ;
		INNER JOIN picklist ON pl_label+pl_charcod= "DISCOUNT  "+rs_discnt ;
		WHERE ps_artinum > 0 ;
		GROUP BY 1,2 ;
		ORDER BY 2 ;
		INTO ARRAY laDisc
ENDIF
SELECT ps_postid FROM &lcurPsData ;
	INNER JOIN paymetho ON ps_paynum = pm_paynum ;
	WHERE ps_paynum > 0 AND pm_paytyp = 4;
	INTO ARRAY laPaytyp
llDebitor = NOT EMPTY(laPaytyp(1))

tcXmlFile = SYS(2023)+"\zugferd-invoice.xml"
lcXml = FILETOSTR("metadata\zugferd-invoice.xml")
lcXmlArticle = STREXTRACT(lcXml,"<!--  ARTICLE  -->","<!--  /ARTICLE  -->")
lcXmlBillNote = STREXTRACT(lcXml,"<!--  BILL NOTE  -->","<!--  /BILL NOTE  -->")
lcXmlSummaryTax = STREXTRACT(lcXml,"<!--  SUMMARY TAX  -->","<!--  /SUMMARY TAX  -->")
lcXmlDiscountAdditions = STREXTRACT(lcXml,"<!--  DISCOUNT-ADDITION  -->","<!--  /DISCOUNT-ADDITION  -->")

STORE "" TO lcArticles, lcNotes, lcTaxes, lcDiscounts
STORE 0 TO lnPayment, lnVatSum, lnNetSum, lnNetArtSum

lcNote = FNGetWindowData(lnRsid, lnWindow, "pw_note")
IF NOT EMPTY(lcNote)
	lcXmlSegment = STRTRAN(lcXmlBillNote, "__ExchangedDocument.IncludedNote.Content__", STRCONV(lcNote,9))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__ExchangedDocument.IncludedNote.SubjectCode__", "")
	lcNotes = lcNotes + lcXmlSegment
ENDIF

IF NOT EMPTY(laDisc(1))
	FOR i = 1 TO ALEN(laDisc,1)
		lcXmlSegment = STRTRAN(lcXmlBillNote, "__ExchangedDocument.IncludedNote.Content__", STRCONV("Es�bestehen�Rabatt "+laDisc(i,1)+" mit "+TRANSFORM(laDisc(i,2))+"%",9))
		lcXmlSegment = STRTRAN(lcXmlSegment, "__ExchangedDocument.IncludedNote.SubjectCode__", "<ram:SubjectCode>AAI</ram:SubjectCode>")
		lcNotes = lcNotes + lcXmlSegment
	ENDFOR
ENDIF
lcXmlSegment = STRTRAN(lcXmlBillNote, "__ExchangedDocument.IncludedNote.Content__", STRCONV(ALLTRIM(param.pa_hotel) + CRLF + ALLTRIM(param2.pa_street) + CRLF + ALLTRIM(param.pa_zip) + " " + ALLTRIM(param.pa_city) + CRLF + ALLTRIM(param.pa_country) + CRLF + "Gesch�ftsf�hrer: " + ALLTRIM(param2.pa_manager),9))
lcXmlSegment = STRTRAN(lcXmlSegment, "__ExchangedDocument.IncludedNote.SubjectCode__", "<ram:SubjectCode>REG</ram:SubjectCode>")
lcNotes = lcNotes + lcXmlSegment

i = 0
SELECT &lcurPsData
SCAN FOR ps_artinum > 0
	=SEEK(&lcurPsData..ps_origid,IIF(llHistory,"histres","reservat"),"tag1")
	=SEEK(&lcurPsData..ps_artinum,"article","tag1")
	=SEEK("DISCOUNT  "+IIF(llHistory,histres.hr_discnt,reservat.rs_discnt),"dsc","tag4")
	=SEEK("VATGROUP  "+STR(article.ar_vat,3),"vat","tag3")
	i = i + 1
	lnNetArt = ROUND(ps_price*ps_units*100/(100+IIF(param.pa_exclvat,0,vat.pl_numval))*(100-dsc.pl_numval)/100,4)
	lnNetArtSum = lnNetArtSum + lnNetArt
	lcXmlSegment = STRTRAN(lcXmlArticle, "__AssociatedDocumentLineDocument.LineID__", TRANSFORM(i))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__IncludedNote.Content__", STRCONV(ALLTRIM(ps_note),9))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeProduct.GlobalID__", IIF(EMPTY(_screen.oGlobal.cGobdArticle_globalid), "", ALLTRIM(TRANSFORM(EVALUATE("article."+_screen.oGlobal.cGobdArticle_globalid)))))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeProduct.SellerAssignedID__", ALLTRIM(TRANSFORM(ps_artinum)))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeProduct.Name__", STRCONV(ALLTRIM(EVALUATE("article.ar_lang"+g_langnum)),9))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeProduct.Description__", STRCONV(ALLTRIM(ps_descrip),9))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__GrossPriceProductTradePrice.ChargeAmount__", STRTRAN(ALLTRIM(STR(ROUND(ps_price*100/(100+IIF(param.pa_exclvat,0,vat.pl_numval)),4),20,4)),",","."))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__AppliedTradeAllowanceCharge.ActualAmount__", STRTRAN(ALLTRIM(STR(ROUND(ps_price*100/(100+IIF(param.pa_exclvat,0,vat.pl_numval))*dsc.pl_numval/100,4),20,4)),",","."))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__AppliedTradeAllowanceCharge.Reason__", STRCONV(ALLTRIM(EVALUATE("dsc.pl_lang"+g_langnum)),9))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__NetPriceProductTradePrice.ChargeAmount__", STRTRAN(ALLTRIM(STR(ROUND(ps_price*100/(100+IIF(param.pa_exclvat,0,vat.pl_numval))*(100-dsc.pl_numval)/100,4),20,4)),",","."))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedLineTradeDelivery.BilledQuantity__", STRTRAN(ALLTRIM(STR(ROUND(ps_units,4),20,4)),",","."))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__ApplicableTradeTax.RateApplicablePercent__", STRTRAN(ALLTRIM(STR(ROUND(vat.pl_numval,2),20,2)),",","."))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__ApplicableTradeTax.CategoryCode__", IIF(vat.pl_numval=0,"Z","S"))
	lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeSettlementLineMonetarySummation.LineTotalAmount__", STRTRAN(ALLTRIM(STR(lnNetArt,20,4)),",","."))
	lcArticles = lcArticles + lcXmlSegment
ENDSCAN

=SEEK(lnAddrId,"address","tag1")
lcXml = STRTRAN(lcXml, "__ExchangedDocument.ID__", EVL(g_BillNum,"0"))
lcXml = STRTRAN(lcXml, "__ExchangedDocument.TypeCode__", ICASE(NOT EMPTY(lcNegBillnum), "389", llDebitor, "383", EMPTY(g_BillNum), "386", "380"))
lcXml = STRTRAN(lcXml, "__ExchangedDocument.IssueDateTime__", DTOS(EVL(g_dbilldate,SysDate())))
lcXml = STRTRAN(lcXml, lcXmlBillNote, lcNotes)
lcXml = STRTRAN(lcXml, lcXmlArticle, lcArticles)
lcXml = STRTRAN(lcXml, "__SellerTradeParty.GlobalID__", ALLTRIM(param2.pa_globlid))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.Name__", STRCONV(ALLTRIM(param.pa_hotel),9))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.DefinedTradeContact.PersonName__", STRCONV(ALLTRIM(param2.pa_manager),9))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.DefinedTradeContact.TelephoneUniversalCommunication.CompleteNumber__", ALLTRIM(param2.pa_phone))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.DefinedTradeContact.EmailURIUniversalCommunication.URIID__", ALLTRIM(param2.pa_email))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.PostalTradeAddress.PostcodeCode__", ALLTRIM(param.pa_zip))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.PostalTradeAddress.LineOne__", STRCONV(ALLTRIM(param2.pa_street),9))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.PostalTradeAddress.CityName__", STRCONV(ALLTRIM(param.pa_city),9))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.PostalTradeAddress.CountryID__", ALLTRIM(DLookUp("picklist", "pl_label+pl_charcod = 'COUNTRY   " + param.pa_country + "'", "pl_user2")))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.SpecifiedTaxRegistration.FCID__", ALLTRIM(param2.pa_vatnr))
lcXml = STRTRAN(lcXml, "__SellerTradeParty.SpecifiedTaxRegistration.VAID__", ALLTRIM(param2.pa_ustidnr))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.ID__", ALLTRIM(TRANSFORM(address.ad_addrid)))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.GlobalID__", IIF(EMPTY(_screen.oGlobal.cGobdAddress_globalid), "", ALLTRIM(TRANSFORM(EVALUATE("address."+_screen.oGlobal.cGobdAddress_globalid)))))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.Name__", STRCONV(ALLTRIM(EVL(lcName,address.ad_company)),9))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.PostalTradeAddress.PostcodeCode__", ALLTRIM(address.ad_zip))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.PostalTradeAddress.LineOne__", STRCONV(ALLTRIM(lcStreet1),9))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.PostalTradeAddress.LineTwo__", STRCONV(ALLTRIM(lcStreet2),9))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.PostalTradeAddress.CityName__", STRCONV(ALLTRIM(lcCity),9))
lcXml = STRTRAN(lcXml, "__BuyerTradeParty.PostalTradeAddress.CountryID__", ALLTRIM(lcCountry))
lcXml = STRTRAN(lcXml, "__BuyerOrderReferencedDocument.IssuerAssignedID__", STRTRAN(ALLTRIM(STR(lnReserid,12,3)),",","."))
lcXml = STRTRAN(lcXml, "__ActualDeliverySupplyChainEvent.OccurrenceDateTime__", DTOS(ldCreated))

SELECT ar_vat, pl_numval, SUM(ps_amount), SUM(ps_vat0), SUM(ps_vat1), SUM(ps_vat2), SUM(ps_vat3), SUM(ps_vat4), SUM(ps_vat5), SUM(ps_vat6), SUM(ps_vat7), SUM(ps_vat8), SUM(ps_vat9) FROM &lcurPsData ;
	INNER JOIN article ON ar_artinum = ps_artinum ;
	INNER JOIN picklist ON pl_label+STR(pl_numcod,3) = "VATGROUP  "+STR(ar_vat,3) ;
	WHERE ps_artinum > 0 ;
	GROUP BY 1,2 ;
	INTO ARRAY laVat
CALCULATE SUM(-ps_amount) FOR ps_artinum = 0 TO lnPayment
IF NOT EMPTY(laVat(1))
	FOR i = 1 TO ALEN(laVat,1)
		lnNet = ROUND(IIF(laVat(i,2)=0,laVat(i,4),laVat(i,4+laVat(i,1))*100/laVat(i,2)),2)
		lnVat = ROUND(lnNet*laVat(i,2)/100,2)
		lnVatSum = lnVatSum + lnVat
		lnNetSum = lnNetSum + lnNet
		lcXmlSegment = STRTRAN(lcXmlSummaryTax, "__ApplicableTradeTax.CalculatedAmount__", STRTRAN(ALLTRIM(STR(lnVat,20,2)),",","."))
		lcXmlSegment = STRTRAN(lcXmlSegment, "__ApplicableTradeTax.BasisAmount__", STRTRAN(ALLTRIM(STR(lnNet,20,2)),",","."))
		lcXmlSegment = STRTRAN(lcXmlSegment, "__ApplicableTradeTax.CategoryCode__", IIF(laVat(i,2)=0,"Z","S"))
		lcXmlSegment = STRTRAN(lcXmlSegment, "__ApplicableTradeTax.RateApplicablePercent__", STRTRAN(ALLTRIM(STR(laVat(i,2),20,2)),",","."))
		lcTaxes = lcTaxes + lcXmlSegment
	ENDFOR
ENDIF
lcXml = STRTRAN(lcXml, lcXmlSummaryTax, lcTaxes)

*lcXmlSegment = STRTRAN(lcXmlDiscountAdditions, "__SpecifiedTradeAllowanceCharge.ChargeIndicator.Indicator__", "false")
*lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeAllowanceCharge.BasisAmount__", "10.00")
*lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeAllowanceCharge.ActualAmount__", "1.00")
*lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeAllowanceCharge.Reason__", "Sondernachlass")
*lcXmlSegment = STRTRAN(lcXmlSegment, "__SpecifiedTradeAllowanceCharge.CategoryTradeTax.RateApplicablePercent__", "19.00")
*lcDiscounts = lcDiscounts + lcXmlSegment
lcXml = STRTRAN(lcXml, lcXmlDiscountAdditions, lcDiscounts)

STORE 0 TO lnChargeSum, lnAllowanceSum
lcXml = STRTRAN(lcXml, "__SpecifiedTradePaymentTerms.Description__", "")
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.LineTotalAmount__", STRTRAN(ALLTRIM(STR(lnNetArtSum,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.ChargeTotalAmount__", STRTRAN(ALLTRIM(STR(lnChargeSum,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.AllowanceTotalAmount__", STRTRAN(ALLTRIM(STR(lnAllowanceSum,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.TaxBasisTotalAmount__", STRTRAN(ALLTRIM(STR(lnNetArtSum+lnChargeSum-lnAllowanceSum,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.TaxTotalAmount__", STRTRAN(ALLTRIM(STR(lnVatSum,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.RoundingAmount__", STRTRAN(ALLTRIM(STR(lnNetSum-lnNetArtSum,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.GrandTotalAmount__", STRTRAN(ALLTRIM(STR(lnNetArtSum+lnVatSum,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.TotalPrepaidAmount__", STRTRAN(ALLTRIM(STR(lnPayment,20,2)),",","."))
lcXml = STRTRAN(lcXml, "__SpecifiedTradeSettlementHeaderMonetarySummation.DuePayableAmount__", STRTRAN(ALLTRIM(STR(lnNetSum+lnVatSum-lnPayment,20,2)),",","."))

STRTOFILE(lcXml, tcXmlFile)

GO lnRecno IN reservat

DClose("dsc")
DClose("vat")
IF llHistory
	DClose(lcurPsData)
	SELECT &tcurData
ENDIF

RETURN .T.
ENDPROC

PROCEDURE PBCheckMessageOnCheckOut

IF SUBSTR(reservat.rs_mshwcco,2,1)<>"1"
	RETURN .T.
ENDIF

LOCAL lcGuestName, lcCompanyName

lcGuestName = GetReservatLongName("reservat","address","apartner")
lcCompanyName = CompanyName("company")

DO FORM forms\msgedit WITH 1, reservat.rs_reserid, lcGuestName, lcCompanyName

RETURN .T.
ENDPROC

PROCEDURE CheckOutBatch
 LOCAL ARRAY l_aMode(1)
 l_aMode(1) = IIF(param.pa_gchkout, "EXTENDED", "SIMPLE")
 = DoForm("frmBatchCheckOut", "forms\checkoutbatch", "", .F., @l_aMode)
 RETURN .T.
ENDPROC

PROCEDURE CheckOutBProc
LPARAMETERS lp_cMode, lp_cGroup, lp_nReserId, lp_lExpressCheckoOut
LOCAL l_nSelected, l_lUsedResFix, l_nRecNo, l_cOrder, l_nDone, l_dSysDate
LOCAL l_cScope, l_cForClause, l_lResult, l_lSuccess
DO CASE
 CASE lp_cMode = "SIMPLE"
	l_cScope = "REST"
	l_cForClause = "NOT EMPTY(rs_in) AND EMPTY(rs_out) " + ;
			"AND rs_depdate = l_dSysDate " + ;
			"AND INLIST(DLookup('RoomType', 'rt_roomtyp = ' + SqlCnv(rs_roomtyp)," + ;
			" 'rt_group'), 1, 4) "
	IF NOT EMPTY(lp_cGroup)
		l_cForClause = l_cForClause + " AND rs_group = " + SqlCnv(lp_cGroup)
	ENDIF
 CASE lp_cMode = "EXTENDED"
	l_cScope = "ALL"
	l_cForClause = "rs_in+DTOS(rs_depdate)+rs_roomnum+rs_out = " + ;
			"[1" + DTOS(SysDate()) + "] " + ;
			"AND rs_group+DTOS(rs_arrdate)+rs_lname = " + ;
			"[" + lp_cGroup + "] AND EMPTY(rs_out)"
 CASE lp_cMode = "SINGLE"
	l_cScope = "ALL"
	l_cForClause = "rs_in+DTOS(rs_depdate)+rs_roomnum+rs_out = " + ;
			"[1" + DTOS(SysDate()) + "] " + ;
			"AND rs_reserid = " + sqlcnv(lp_nReserId) + ;
			" AND EMPTY(rs_out)"

ENDCASE
l_nSelected = SELECT()
l_lUsedResFix = USED("resfix")
IF NOT l_lUsedResFix
	openfiledirect(.F., "resfix")
	SET ORDER TO Tag1 IN resfix
ENDIF
SELECT reservat
l_nRecNo = RECNO()
l_cOrder = ORDER()
IF lp_cMode = "SIMPLE"
	SET ORDER TO Tag6
ELSE
	SET ORDER TO
ENDIF
l_nDone = 0
l_dSysDate = SysDate()
IF (lp_cMode = "SIMPLE" AND SEEK("1", "Reservat")) OR (lp_cMode = "EXTENDED") OR (lp_cMode = "SINGLE")
	SCAN &l_cScope FOR &l_cForClause
		DO CheckOutPrepare IN ProcBill WITH reservat.rs_reserid
		DO raTecodepost IN RatePost WITH (l_dSysDate), "CHECKOUT"
		IF lp_lExpressCheckoOut OR ;
				(;
				Balance(rs_reserid, 1) + Balance(rs_reserid, 2) + ;
				Balance(rs_reserid, 3) + Balance(rs_reserid, 4) + ;
				Balance(rs_reserid, 5) + Balance(rs_reserid, 6) = 0.00 ;
				)
			IF NOT g_lAutomationMode
				WAIT WINDOW NOWAIT get_rm_rmname(reServat.rs_roomnum)+" "+TRIM(reServat.rs_lname)
			ENDIF
			IF lp_lExpressCheckoOut
				IF NOT PBPayAndPrintBills()
					l_lSuccess = .F.
					EXIT
				ENDIF
			ENDIF
			DO CursorPostPayCreate IN ProcBill WITH .T.
			DO CheckOutProcess IN ProcBill WITH 0, .F., l_lResult, lp_lExpressCheckoOut
			IF NOT g_lAutomationMode
				WAIT CLEAR
			ENDIF
			IF l_lResult
				l_nDone = l_nDone + 1
				IF NOT l_lSuccess
					l_lSuccess = .T.
				ENDIF
			ENDIF
		ENDIF
	ENDSCAN
ENDIF
GO l_nRecNo
SET ORDER TO l_cOrder
IF NOT l_lUsedResFix AND USED("resfix")
	dclose("resfix")
ENDIF
SELECT(l_nSelected)
= alErt(stRfmt(GetLangText("CHKOUT1","T_BATCHDONE"),l_nDone),GetLangText("CHKOUT1", ;
   "TW_BATCHCHECKOUT"))
RETURN l_lSuccess
ENDPROC
*
PROCEDURE PBPayAndPrintBills
LOCAL i, l_lSuccess, l_frmBillPrint, l_nReserId, l_nWindow, l_cBillNum, l_nAmount, l_lBillChkOut, l_cPMCur, l_nSelect, l_lAllowedAutomaticPrint
*g_lAutomationMode = .T.
l_nSelect = SELECT()
l_lSuccess = .F.
l_nReserId = reservat.rs_reserid
l_cPMCur = sqlcursor("SELECT pm_paynum, pm_copy, pm_calcrat FROM paymetho WHERE pm_paymeth = " + ;
		sqlcnv(reservat.rs_paymeth,.T.))

FOR i = 1 TO 6
	l_nWindow = i
	l_lAllowedAutomaticPrint = IIF(LOWER(readini(FULLPATH(INI_FILE), "expresscheckout", "allowedbillwindow"+TRANSFORM(l_nWindow), "yes"))="yes",.T.,.F.)
	IF l_lAllowedAutomaticPrint
		l_cBillNum = dlookup("billnum","bn_reserid = " + sqlcnv(l_nReserId,.T.) + " AND bn_window = " + sqlcnv(l_nWindow,.T.) + ;
				" AND bn_status = 'PCO'", "bn_billnum")
		IF EMPTY(l_cBillNum)
			l_nAmount = Balance(l_nReserId,l_nWindow)
			IF l_nAmount <> 0.00
				l_lSuccess = ProcBill("BillPayProcess", "post", l_nReserId, l_nWindow, 0, "", "BILLGROUP", &l_cPMCur..pm_paynum, ;
						l_nAmount, ROUND(l_nAmount / &l_cPMCur..pm_calcrat, param.pa_currdec),,,,"Guest Express Checkout")
			ELSE
				l_lSuccess = .T.
			ENDIF
			IF l_lSuccess
				g_Billstyle = ProcBillStyle(reservat.rs_rsid, l_nWindow, @g_UseBDateInStyle)
				l_lBillChkOut = (Balance(l_nReserId, l_nWindow) == 0.00)
				l_frmBillPrint = .F.
				DO FORM "forms\billprint" NAME l_frmBillPrint LINKED ;
						WITH l_nReserId, l_nWindow, ;
						MAX(&l_cPMCur..pm_copy,1), l_lBillChkOut, .F., .F., .T. ;
						NOSHOW
				l_frmBillPrint = .NULL.
			ENDIF
		ELSE
			l_lSuccess = .T.
		ENDIF
	ELSE
		l_lSuccess = .T.
	ENDIF
	IF NOT l_lSuccess
		EXIT
	ENDIF
ENDFOR
IF l_lSuccess
	* Mark in reservat record, that this reservation has automaticly issued bills
	sqlupdate("reservat", ;
		"rs_reserid = " + sqlcnv(l_nReserId,.T.), ;
		"rs_usrres3 = " + sqlcnv("T",.T.))

ENDIF

dclose(l_cPMCur)
SELECT (l_nSelect)
*g_lAutomationMode = .F.
RETURN l_lSuccess
ENDPROC
*
PROCEDURE PreliminaryInvoice
LPARAMETERS lp_nWindow, lp_oBillFormsetRef, lp_lPrint
LOCAL l_lSuccess, l_lPrint, l_lAllowCheckOutWithBalance, l_nSelect, l_dBillToDate, l_lCancel, l_lNoCheckOut
l_nSelect = SELECT()
l_lSuccess = .F.
l_lSuccess = CheckOutYesNo()
IF l_lSuccess
	l_nType = 2 && Advanced bill, until entered date
	l_cBillToDateCaption = GetLangText("BILL","TXT_PREBILL")
	CheckOutType(@l_nType, lp_nWindow, {}, l_cBillToDateCaption, @l_dBillToDate)
	l_lSuccess = NOT EMPTY(l_nType)
ENDIF
IF l_lSuccess
	IF param2.pa_dppostp
		l_lCancel = .F.
		DO dpchkin IN DP WITH reservat.rs_reserid, l_lCancel
	ENDIF
	AdvanceBillForWholeGroup(reservat.rs_reserid, lp_nWindow, l_dBillToDate)
	CursorPostPayCreate(.T.)
	l_lAllowCheckOutWithBalance = .F.
	l_lNoCheckOut = .T.
	l_lSuccess = CheckOutProcess(lp_nWindow, lp_lPrint, .F., l_lAllowCheckOutWithBalance, lp_oBillFormsetRef, l_lNoCheckOut)
ENDIF
SELECT(l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE AdvanceBillForWholeGroup
LPARAMETERS lp_nReserId, lp_nWindow, lp_dBillToDate
LOCAL l_nRecNo, l_nSelect, l_nType, l_nPMReserid, l_nAdvBillWholeGroup, l_lYesNo, l_lCancel
* Check if this is paymaster
l_nRecNo = RECNO("reservat")
l_nSelect = SELECT()
IF SEEK(lp_nReserId,"reservat","tag1")
	IF NOT EMPTY(reservat.rs_groupid)
		l_nPMReserid = DLookUp("groupres", "gr_groupid = " + sqlcnv(reservat.rs_groupid,.T.), "gr_pmresid")
		IF reservat.rs_reserid = l_nPMReserid
			l_nAdvBillWholeGroup = yesno(GetLangText("BILL","TXT_ADVANCE_BILL_GROUP"))
		ENDIF
	ENDIF
ENDIF
IF l_nAdvBillWholeGroup
	* Advance bill for whole group
	SELECT reservat
	l_nGroupId = reservat.rs_groupid
	SCAN FOR rs_groupid = l_nGroupId AND rs_reserid <> l_nPMReserid
		l_nType = 2 && Set it inside loop, because it can be changed in CheckOutType function!
		IF param2.pa_dppostp
			l_lCancel = .F.
			DO dpchkin IN DP WITH reservat.rs_reserid, l_lCancel
		ENDIF
		DO CheckOutPrepare IN ProcBill WITH reservat.rs_reserid
		DO CheckOutYesNo IN ProcBill WITH l_lYesNo, .T.
		IF l_lYesNo
			DO CheckOutType IN ProcBill WITH l_nType, lp_nWindow, lp_dBillToDate
		ENDIF
	ENDSCAN
ENDIF
GO l_nRecNo IN reservat
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PostAllUntilDate
LPARAMETERS lp_nReserId, lp_nWindow, lp_dDate
LOCAL l_nType, l_nSelect, l_nResRecNo
l_nSelect = SELECT()
l_nResRecNo = RECNO("reservat")
IF SEEK(lp_nReserId, "reservat", "tag1")
	l_nType = 2 && Advanced bill, until entered date
	CheckOutType(@l_nType, lp_nWindow, lp_dDate)
ENDIF
GO l_nResRecNo IN reservat
SELECT(l_nSelect)
RETURN NOT EMPTY(l_nType)
ENDPROC
*
*PROCEDURE BillPrint
*LPARAMETERS lp_cType
* LOCAL l
* DO CASE
*  CASE INLIST(lp_cType,"BILL_CHKOUT","OLD_CHKOUT")
*	IF (param.pa_autoprn .AND. lp_plPrint)
*		glcheckout = .T.
*		= prntbill(reservat.rs_reserid, l_nWindow, .F., MAX(paymetho.pm_copy,1), .T.)
*		glcheckout = .F.
*	ENDIF
*  CASE INLIST(lp_cType,"PASS_PAY","VOUCH_PAY")&& "BOOTH_PAY"
*	lprint = yesno(GetLangText("PASSERBY","TA_PRINTBILL")+"?")
*	lledger = (paymetho.pm_paytyp=4)
*	lasktype = (lprint .AND. luseaddress)
*	g_Billnum = getbill(lasktype,lledger,lcreditnote)
*	g_Billname = ''
*	REPLACE ps_ifc WITH g_Billnum ALL FOR ps_paynum>0 IN query
*	IF lprint
*		DO printpassbill IN passerby WITH MAX(paymetho.pm_copy,1)
*	ENDIF
*		IF luSeaddress
*			cnAme = TRIM(adDress.ad_title)+" "+ ;
*					TRIM(adDress.ad_fname)+" "+ ;
*					TRIM(flIp(adDress.ad_lname))
*		ELSE
*			cnAme = GetLangText("PASSERBY","TXT_PASSERBY")
*		ENDIF
* ENDCASE
*	IF (lp_nbIllwindow == 0) .AND. l_lPostPayment
*		IF EMPTY(reservat.rs_billnr1)
*			LOCAL laSktype, llEdger, lcReditnote, lcHeckout
*			laSktype = .F.
*			llEdger = .F.
*			lcReditnote = .F.
*			lcHeckout = lp_plPrint
*			REPLACE reservat.rs_billnr1 WITH geTbill(laSktype,llEdger,lcReditnote,lcHeckout)
*		ENDIF
*		REPLACE reservat.rs_copyw1 WITH MIN(99, reservat.rs_copyw1+1)
*		LOCAL cnAme, cbIllnum, cfXp
*		cnAme = TRIM(address.ad_title)+" "+TRIM(address.ad_fname)+" "+ ;
*					TRIM(flIp(address.ad_lname))
*		cbIllnum = reservat.rs_billnr1
*	ENDIF
* RETURN .T.
*ENDPROC
*
PROCEDURE CursorAddField
LPARAMETERS lp_aFields, lp_cNewName, lp_cNewType, lp_nNewWidth, lp_nDecPlaces, lp_lNullValues
* CursorAddField adds new field into cursor array (adds row that describes table column).
 LOCAL l_nNewRow, l_nColumn
 IF EMPTY(lp_aFields(1))
	l_nNewRow = 1
 ELSE
	l_nNewRow = ALEN(lp_aFields, 1)+1
 ENDIF
 DIMENSION lp_aFields[l_nNewRow, ALEN(lp_aFields, 2)]
 lp_aFields[l_nNewRow, 1] = lp_cNewName
 lp_aFields[l_nNewRow, 2] = lp_cNewType
 lp_aFields[l_nNewRow, 3] = lp_nNewWidth
 lp_aFields[l_nNewRow, 4] = lp_nDecPlaces
 lp_aFields[l_nNewRow, 5] = lp_lNullValues
 lp_aFields[l_nNewRow, 6] = .F.
 lp_aFields[l_nNewRow, 7] = ""
 lp_aFields[l_nNewRow, 8] = ""
 lp_aFields[l_nNewRow, 9] = ""
 lp_aFields[l_nNewRow, 10] = ""
 lp_aFields[l_nNewRow, 11] = ""
 lp_aFields[l_nNewRow, 12] = ""
 lp_aFields[l_nNewRow, 13] = ""
 lp_aFields[l_nNewRow, 14] = ""
 lp_aFields[l_nNewRow, 15] = ""
 lp_aFields[l_nNewRow, 16] = ""
ENDPROC

* CursorPostPayCreate creates appropriate cursor for PostPay form.
PROCEDURE CursorPostPayCreate
LPARAMETERS lp_lPayId
 = AFIELDS(l_aFields,"post")
 IF lp_lPayId
	DO CursorAddField WITH l_aFields, 'PS_PAYID', 'N', 8, 0
	DO CursorAddField WITH l_aFields, 'PS_VOUCHID', 'C', 12, 0
	DO CursorAddField WITH l_aFields, 'PS_CHKRFND', 'L', 1, 0
	DO CursorAddField WITH l_aFields, 'PS_LDAMNT', 'B', 8, 2
	DO CursorAddField WITH l_aFields, 'PS_LDID', 'I', 4, 0
 ENDIF
 CREATE CURSOR tblPostCursor FROM ARRAY l_aFields
ENDPROC

* CursorPrintBillCreate creates appropriate cursor for bill print process.
PROCEDURE CursorPrintBillCreate
LPARAMETERS tcAlias, tlHistory
LOCAL ARRAY laFields(1)

 = AFIELDS(laFields,IIF(tlHistory,"histpost","post"))
 DO CursorAddField WITH laFields, IIF(tlHistory,'HP_','PS_')+'EURO', 'B', 8, 6
 DO CursorAddField WITH laFields, IIF(tlHistory,'HP_','PS_')+'LOCAL', 'B', 8, 6
 DO CursorAddField WITH laFields, 'CUR_ARTITP', 'N', 1, 0
 DO CursorAddField WITH laFields, 'CUR_VAT', 'N', 1, 0
 DO CursorAddField WITH laFields, 'CUR_RMNAME', 'C', 25, 0
 DO CursorAddField WITH laFields, 'CUR_ARRDAT', 'D', 8, 0
 DO CursorAddField WITH laFields, 'CUR_DEPDAT', 'D', 8, 0
 DO CursorAddField WITH laFields, 'CUR_RCSETID', 'N', 8, 0
 DO CursorAddField WITH laFields, 'CUR_AMOUNT', 'B', 8, 2
 DO CursorAddField WITH laFields, 'CUR_PRICE', 'B', 8, 6
 CREATE CURSOR &tcAlias FROM ARRAY laFields
ENDPROC

* Check similar fields in post and histpost cursors and get comma delimited fields clause.
PROCEDURE GetPostFields
LPARAMETERS tcPostAlias, tcHistPostAlias, tcPostFields, tcHistPostFields
LOCAL i, lcHpField
LOCAL ARRAY laPostFields(1), laHistPostFields(1)

 =AFIELDS(laHistPostFields, tcHistPostAlias)
 tcPostFields = ""
 tcHistPostFields = ""
 FOR i = 1 TO AFIELDS(laPostFields, tcPostAlias)
      lcHpField = STRTRAN(laPostFields(i,1), "PS_", "HP_")
      IF 0 < ASCAN(laHistPostFields, lcHpField, 1, 0, 1, 7)
           tcPostFields = tcPostFields + IIF(EMPTY(tcPostFields), "", ",") + laPostFields(i,1)
           tcHistPostFields = tcHistPostFields + IIF(EMPTY(tcHistPostFields), "", ",") + lcHpField
      ENDIF
 NEXT
ENDPROC
* PasserbyPost is main procedure for new Passerby option. It should be called from mainmenu.
PROCEDURE PasserbyPost
LPARAMETERS lp_cType
 IF NOT userpid()
	RETURN
 ENDIF
 LOCAL l_nAddrId, l_nReserId, l_frmPasserby
 l_nAddrId = 0
 l_nReserId = 0
 DO CASE
	CASE EMPTY(lp_cType)
		DO CASE
			CASE TYPE("_screen.ActiveForm.Name")="C" AND _screen.ActiveForm.Name = "FAddressMask"
				l_nAddrId = _screen.ActiveForm.Parent.m_GetSelectedAddress()
			OTHERWISE
		ENDCASE
	CASE lp_cType = "RES"
		l_nAddrId = reservat.rs_addrid
		l_nReserId = reservat.rs_reserid
	CASE lp_cType = "ADDR"
		l_nAddrId = address.ad_addrid
	OTHERWISE
 ENDCASE
 DO FORM "forms\passerby" NAME l_frmPasserby LINKED WITH "PASS", l_nAddrId, l_nReserId
 RETURN
ENDPROC

* PasserbyProcess is procedure called from Passeby form Init event.
PROCEDURE PasserbyProcess
 LPARAMETERS lp_cMode, lp_nAddrId, lp_nReserId
 IF NOT INLIST(lp_cMode, "PASS", "VOUCH", "GROUP")
	RETURN .F.
 ENDIF
 LOCAL l_nBalance, l_nWindow, l_oResult, l_oPaymetho, l_lCancel, l_lSuccess, l_lExtVoucher, l_lPaymentOK
 l_nBalance = 0
 l_nWindow = 1
 l_oResult = .NULL.
 l_lExtVoucher = IIF(VARTYPE(_screen.oglobal.oExtVouchersData)="O",.T.,.F.)
 * Create tblPostCursor
 DO CursorPostPayCreate WITH .T.
 * Call form for post.
 DO FORM "forms/postpay" ;
		WITH lp_cMode+"_POST", l_nWindow, lp_nAddrId, lp_nReserId, l_nBalance, l_lExtVoucher ;
		TO l_oResult
 IF lp_cMode == "GROUP"
 	l_lSuccess = PasserbyProcessCommit()
 	RETURN l_lSuccess
 ENDIF
 IF ISNULL(l_oResult)
	* Cancel
	l_lCancel = .T.
 ELSE
	l_nBalance = l_oResult.nBalance
	lp_nAddrId = l_oResult.nAddrId
 ENDIF
 * Create cursor Query
 DO CursorPrintBillCreate WITH "query"
 SELECT query
 SET RELATION TO query.ps_ratecod INTO ratecode
 SET RELATION TO query.ps_artinum INTO article ADDITIVE
 SET RELATION TO query.ps_paynum INTO paymetho ADDITIVE
 APPEND FROM DBF("tblPostCursor")
 IF l_nBalance <> 0
	LOCAL l_lCreditNote, l_lPrint, l_lLedger, l_lAskType, l_cName
	LOCAL l_nPassBillStyle, l_oRetVal
	IF lp_cMode="PASS"
		l_oRetVal = .NULL.
	ELSE
		l_oRetVal = 0
	ENDIF
	l_nPassBillStyle = 0
	l_lCreditNote = (l_nBalance<0)
	* Clear tblPostCursor
	ZAP IN tblPostCursor
	* Call form for pay.
	DO FORM "forms/postpay" ;
			WITH lp_cMode+"_PAY", l_nWindow, lp_nAddrId, lp_nReserId, l_nBalance, l_lExtVoucher ;
			TO l_oRetVal
	IF (VARTYPE(l_oRetVal)="L" OR lp_cMode = "VOUCH" AND VARTYPE(l_oRetVal)="N") AND EMPTY(l_oRetVal)
		* Cancel
		l_lCancel = .T.
	ENDIF
	IF NOT l_lCancel
		IF lp_cMode="PASS"
			IF NOT ISNULL(l_oRetVal)
				lp_nAddrId=l_oRetVal.nAddrId
				l_nPassBillStyle=l_oRetVal.nPassBillStyle
			ENDIF
		ELSE
			lp_nAddrId=l_oRetVal
		ENDIF
		* post alias has relation to paymetho alias !
		SELECT paymetho
		SCATTER MEMO NAME l_oPaymetho
		* Prepare for print.
		l_lPrint = .T. && Not allowed in Germany after 1.1.2020, bill must always be printed. && yesno(GetLangText("PASSERBY","TA_PRINTBILL")+"?")
		l_lLedger = (l_oPaymetho.pm_paytyp=4)
		l_lAskType = (l_lPrint AND NOT EMPTY(lp_nAddrId))
		_screen.oGlobal.oBill.nAddrId = lp_nAddrId
		IF FPBillPrinted("PASSERBY")
			g_Billnum = getbill(l_lAskType, l_lLedger, l_lCreditNote, .F., ;
					0.1, lp_nAddrId, l_nBalance, "PASSERBY", 1)
		ELSE
			g_Billnum = ""
			l_lCancel = .T.
		ENDIF
		IF NOT EMPTY(g_Billnum)
			PBBonusUpdate(g_Billnum,,,lp_nAddrId, "Query")
			DO PBSetBillType IN prntbill
			g_Billname = ''
			g_dBillDate = SysDate()
			SELECT query
			APPEND FROM DBF("tblPostCursor")
			SCAN
				* Update ps_addrid in Post and Query!
				REPLACE ps_addrid WITH lp_nAddrId
				IF SEEK(query.ps_postid,"post","tag3")
					REPLACE ps_addrid WITH lp_nAddrId, ;
							ps_billnum WITH g_Billnum IN post
					IF ps_paynum > 0
						REPLACE ps_ifc WITH g_Billnum IN post
					ENDIF
				ENDIF
				* Udate Query for printing.
				IF ps_paynum > 0
					REPLACE ps_ifc WITH g_Billnum, ps_billnum WITH g_Billnum
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
			IF _screen.BMS
				* Ugly workaround, to send parameter to BillNumChange function, because when sending more
				* empty parameters, some other stuff is done!
				PRIVATE p_lDontCallBonusFromBillNumChange
				p_lDontCallBonusFromBillNumChange = .T.
			ENDIF
			IF l_lPrint
				= BillNumChange(g_Billnum, "CHKOUT", "Print",l_oPaymetho.pm_paynum)
			ELSE
				= BillNumChange(g_Billnum, "CHKOUT", "No Print",l_oPaymetho.pm_paynum)
			ENDIF
			IF _screen.BMS
				p_lDontCallBonusFromBillNumChange = .F.
			ENDIF
			l_lSuccess = PasserbyProcessCommit()

			IF l_lSuccess

				IF l_lPrint
					* Print.
					= SetPassBillStyle(l_nPassBillStyle)
					DO printpassbill IN passerby WITH MAX(l_oPaymetho.pm_copy,1)
				ENDIF

				* Prepare for Fisc Prt.
				IF NOT EMPTY(lp_nAddrId)
					l_cName = TRIM(address.ad_title)+" "+ ;
							TRIM(address.ad_fname)+" "+ ;
							TRIM(flip(address.ad_lname))
				ELSE
					l_cName = GetLangText("PASSERBY","TXT_PASSERBY")
				ENDIF
				IF EMPTY(lp_nReserId)
					lp_nReserId = 0.100
				ENDIF
				l_lPaymentOK = .T.
			ELSE
				l_lCancel = .T.
			ENDIF
		ENDIF
	ENDIF
 ELSE
	IF lp_cMode = "PASS"
		* Check if something is posted.
		IF NOT ISNULL(l_oResult) AND USED("tblpostcursor") AND dlocate("tblpostcursor","ps_artinum>0 AND ps_amount>0")
			l_lSuccess = PasserbyProcessCommit()
			IF l_lSuccess
				alert(GetLangText("COMMON","TXT_SAVED"))
			ENDIF
		ENDIF
	ENDIF
	IF lp_cMode = "VOUCH"
		* Cancel
		l_lCancel = .T.
	ENDIF
 ENDIF
 IF NOT l_lCancel
	* Print the vouchres created in PostPay form in mode "PASS_POST" or "VOUCH_POST"
	DO VoucherAddress IN voucher WITH lp_nAddrId
	DO PrintTheVoucher IN voucher
	PasserbyProcessCommit()
 ENDIF
 dclose("tblPostCursor")
 dclose("query")
 IF VARTYPE(_screen.oglobal.oExtVouchersData)="O"
	_screen.oglobal.oExtVouchersData.lSuccess = l_lPaymentOK
 ENDIF
 RETURN .T.
ENDPROC

PROCEDURE PasserbyProcessCommit
LOCAL l_lSuccess
IF USED("post")
	FNNextIdTempWriteRealId("post", "ps_postid", "POST")
	DoTableUpdate(.T.,.T.,"post")
ENDIF
IF USED("billnum")
	DoTableUpdate(.T.,.T.,"billnum")
ENDIF
IF USED("voucher")
	DoTableUpdate(.T.,.T.,"voucher")
ENDIF
IF USED("article")
	DoTableUpdate(.T.,.T.,"article")
ENDIF
l_lSuccess = EndTransaction()
RETURN l_lSuccess
ENDPROC

PROCEDURE BillSum
LPARAMETERS lp_nReserId, lp_nWindow, lp_nArtiNum, lp_dEndDate, lp_cMode, lp_nAmount
LOCAL l_cForClause, l_cExpression
l_cForClause = "ps_reserid = " + SqlCnv(lp_nReserId)
IF NOT EMPTY(lp_dEndDate)
	l_cExpression = "ps_date <= " + SqlCnv(lp_dEndDate)
	IF lp_cMode <> "PAY"
		l_cExpression = SqlOr(l_cExpression, "ps_paynum > 0")
	ENDIF
	l_cForClause = SqlAnd(l_cForClause, l_cExpression)
ENDIF
l_cForClause = SqlAnd(l_cForClause, "ps_window = " + SqlCnv(lp_nWindow))
IF EMPTY(lp_nArtiNum)
	DO CASE
	 CASE lp_cMode = "ARTI"
		l_cForClause = SqlAnd(l_cForClause, "ps_artinum > 0")
	 CASE lp_cMode = "PAY"
		l_cForClause = SqlAnd(l_cForClause, "ps_paynum > 0")
	ENDCASE
ELSE
	l_cForClause = SqlAnd(l_cForClause, "ps_artinum = " + SqlCnv(lp_nArtiNum))
ENDIF
l_cForClause = SqlAnd(l_cForClause, "NOT ps_split AND NOT ps_cancel")
IF param.pa_exclvat
	l_cExpression = "ps_amount + ps_vat1 + ps_vat2 + ps_vat3 + ps_vat4 + " + ;
		"ps_vat5 + ps_vat6 + ps_vat7 + ps_vat8 + ps_vat9"
ELSE
	l_cExpression = "ps_amount"
ENDIF
lp_nAmount = DSum("post", l_cForClause, l_cExpression)
RETURN lp_nAmount
ENDPROC

PROCEDURE UnlimitedRefund
LPARAMETERS lp_nReserId, lp_nWindow, lp_nArtiNum, lp_nAmount, lp_lAllow
LOCAL l_nArtiAmount
l_nArtiAmount = BillSum(lp_nReserId, lp_nWindow, lp_nArtiNum)
lp_lAllow = lp_nAmount <= l_nArtiAmount
RETURN lp_lAllow
ENDPROC

PROCEDURE BillPayValid
LPARAMETERS lp_nReserId, lp_nWindow, lp_nPayNum, lp_nAmount, lp_lAllow
 LOCAL l_nRecNoRes, l_nRecNoPay, l_nArea, l_nAddrId
 l_nArea = SELECT()
 l_nRecNoRes = RECNO("reservat")
 l_nRecNoPay = RECNO("paymetho")
 DO WHILE .T.
	IF reservat.rs_reserid <> lp_nReserId AND NOT SEEK(lp_nReserId, "reservat", "tag1")
		lp_lAllow = .F.
		EXIT
	ENDIF
	IF paymetho.pm_paynum <> lp_nPayNum AND NOT SEEK(lp_nPayNum, "paymetho", "tag1")
		lp_lAllow = .F.
		EXIT
	ENDIF
	DO CASE
		CASE paymetho.pm_paytyp == 4
			l_nAddrId = BillAddrId(lp_nWindow, reservat.rs_rsid, reservat.rs_addrid)
			lp_lAllow = EMPTY(AlwCLedg(l_nAddrId, .T.))
		CASE paymetho.pm_paytyp == 3
			IF _Screen.DV AND EMPTY(paymetho.pm_aracct)
				= Alert(GetLangText("VPAYMETH","TA_NOARACCT"))
			ENDIF
		CASE (paymetho.pm_paytyp==7)
			LOCAL l_cNumber
			l_ValidFlag = .F.
			l_cNumber = 0
			IF lp_nAmount > 0
				DO VoucherUse IN ProcVoucher WITH lp_nAmount, l_cNumber &&, .T.
			ENDIF
			IF NOT EMPTY(l_cNumber)
				*SELECT * FROM tblPostCursor WHERE ps_vouchid = l_cNumber INTO CURSOR tblTempVouchCount
				*IF RECCOUNT("tblTempVouchCount") > 0
					*l_ValidFlag = .F.
				*ELSE
					l_ValidFlag = .T.
					*thisform.a_newdata.ps_vouchid = l_cNumber
					*thisform.a_newdata.ps_price = 1
					*thisform.a_newdata.ps_units = lp_nAmount
					*thisform.a_newdata.ps_supplem = "V#:" + ALLTRIM(l_cNumber)
				*ENDIF
				*USE IN tblTempVouchCount
			ENDIF
	ENDCASE
	EXIT
 ENDDO
 GO l_nRecNoRes IN reservat
 GO l_nRecNoPay IN paymetho
 SELECT (l_nArea)
RETURN lp_lAllow
ENDPROC

PROCEDURE BillPayProcess
LPARAMETERS lp_cPostAlias, lp_nReserId, lp_nWindow, lp_nAddrId, lp_cBillNum, ;
	lp_cType, lp_nPayNum, lp_nAmount, lp_nUnits, lp_cDescrip, lp_cSupplem, lp_dDate, ;
	lp_cNote, lp_lCloseOnSuccess, lp_dBDate, lp_lcustompayment, lp_npostid, lp_lTempPostId, lp_lElPay
 LOCAL l_oEnvironment, l_oPost, l_nTotal
 LOCAL l_nDefUnits, l_cCurrTxt, l_nDiffAmount, l_lPayIdUsed, l_lLdAmntUsed
 LOCAL l_cVatMacro1, l_cVatMacro2
 LOCAL ARRAY l_aVat(2,2)

 l_oEnvironment = SetEnvironment("reservat, paymetho, param, id, picklist, article")

 IF lp_cType == "BILLGROUP" AND reservat.rs_reserid <> lp_nReserId AND NOT SEEK(lp_nReserId, "reservat", "tag1")
	RETURN .F.
 ENDIF
 IF paymetho.pm_paynum <> lp_nPayNum AND NOT SEEK(lp_nPayNum, "paymetho", "tag1")
	RETURN .F.
 ENDIF
 l_lPayIdUsed = (TYPE(lp_cPostAlias + ".ps_payid") <> "U")
 IF EMPTY(lp_dDate)
	lp_dDate = SysDate()
 ENDIF
 IF EMPTY(lp_cNote)
 	lp_cNote = ""
 ENDIF
 l_nDefUnits = ROUND(lp_nAmount / paymetho.pm_calcrat, param.pa_currdec)
 SELECT(lp_cPostAlias)
 SCATTER MEMO NAME l_oPost BLANK
 l_oPost.ps_reserid = lp_nReserId
 l_oPost.ps_origid = lp_nReserId
 l_oPost.ps_window = lp_nWindow
 l_oPost.ps_addrid = EVL(lp_nAddrId,0)
 l_oPost.ps_billnum = EVL(lp_cBillNum,"")
 l_oPost.ps_descrip = EVL(lp_cDescrip,"")
 l_oPost.ps_supplem = EVL(lp_cSupplem,"")
 l_oPost.ps_bdate = EVL(lp_dBDate,{})
 l_oPost.ps_date = lp_dDate
 l_oPost.ps_time = TIME()
 l_oPost.ps_userid = cuSerid
 l_oPost.ps_cashier = g_Cashier
 l_oPost.ps_note = lp_cNote
 l_cCurrTxt = ""
 l_oPost.ps_price = IIF(EMPTY(paymetho.pm_rate) OR paymetho.pm_paynum = 1, 1.00, paymetho.pm_rate)
 IF lp_cType == "LEDGER"
	* Payment on ledger.
	l_oPost.ps_units = -lp_nUnits
	l_oPost.ps_amount = IIF(l_nDefUnits = lp_nUnits, lp_nAmount, -ROUND(l_oPost.ps_price * l_oPost.ps_units, param.pa_currdec)) && ps_amount b(8,2)
	l_oPost.ps_paynum = param.pa_payonld
	CurrCnv(l_oPost.ps_paynum, l_oPost.ps_units, 0, 0, @l_cCurrTxt)
	l_oPost.ps_currtxt = l_cCurrTxt
	l_oPost.ps_postid = IIF(lp_lTempPostId,FNNextIdTemp("post"),NextId("post"))
	IF l_oPost.ps_postid = 0
		RETURN .F.
	ENDIF
	SELECT &lp_cPostAlias
	APPEND BLANK
	GATHER MEMO NAME l_oPost
	PostHistory(l_oPost, l_oPost, "CREATED", lp_cPostAlias)
 ENDIF
 l_oPost.ps_units = lp_nUnits
 IF l_oPost.ps_units > 0 AND NOT EMPTY(paymetho.pm_addamnt)
	l_oPost.ps_units = l_oPost.ps_units + paymetho.pm_addamnt
 ENDIF
 IF l_oPost.ps_units > 0 AND NOT EMPTY(paymetho.pm_addpct)
	IF paymetho.pm_paytyp = 5
		l_oPost.ps_units = - paymetho.pm_addpct * l_oPost.ps_units / 100
	ELSE
		l_oPost.ps_units = l_oPost.ps_units + paymetho.pm_addpct * l_oPost.ps_units / 100
	ENDIF
 ENDIF
 l_oPost.ps_units = ROUND(l_oPost.ps_units,2)	&& ps_units b(8,2)
 l_oPost.ps_amount = -ROUND(l_oPost.ps_units * paymetho.pm_calcrat, param.pa_currdec) && ps_amount b(8,2)
 l_oPost.ps_postid = IIF(lp_lTempPostId,FNNextIdTemp("post"),NextId("post"))
 IF l_oPost.ps_postid = 0
	RETURN .F.
 ENDIF
 lp_npostid = l_oPost.ps_postid

 *********
 * ELPAY *
 *********
 lp_lCloseOnSuccess = .F.
 IF NOT lp_lcustompayment
	IF pbpayelpay(l_oPost.ps_amount*-1, @lp_nPayNum, @lp_lCloseOnSuccess,,,,l_oPost.ps_postid)
		lp_lElPay = lp_lCloseOnSuccess
	ELSE
		RETURN .F.
	ENDIF
 ENDIF
 l_oPost.ps_paynum = lp_nPayNum
 CurrCnv(l_oPost.ps_paynum, l_oPost.ps_units, 0, 0, @l_cCurrTxt)
 l_oPost.ps_currtxt = l_cCurrTxt

 IF l_lPayIdUsed
 	l_oPost.ps_payid = l_oPost.ps_postid
 ENDIF
 l_nTotal = l_oPost.ps_amount
 SELECT &lp_cPostAlias
 APPEND BLANK
 GATHER MEMO NAME l_oPost
 PostHistory(l_oPost, l_oPost, "CREATED", lp_cPostAlias)
 IF l_oPost.ps_units > 0 AND lp_nUnits <> l_oPost.ps_units AND paymetho.pm_paytyp <> 5
	*  Add amount and percent for pay method.
	l_nDiffAmount = (l_oPost.ps_units - lp_nUnits) * paymetho.pm_calcrat
	l_oPost.ps_paynum = 0
	l_oPost.ps_supplem = ""
	l_oPost.ps_units = 1.00
	l_oPost.ps_price = l_nDiffAmount
	l_oPost.ps_artinum = paymetho.pm_addarti
	ArticeVatAmounts(l_oPost.ps_artinum, l_nDiffAmount, @l_aVat, .T.)
	l_cVatMacro1 = "l_oPost.ps_vat" + LTRIM(STR(l_aVat(1,1)))
	l_cVatMacro2 = "l_oPost.ps_vat" + LTRIM(STR(l_aVat(2,1)))
	&l_cVatMacro1 = l_aVat(1,2)
	&l_cVatMacro2 = l_aVat(2,2)
	IF param.pa_exclvat
		* Amount correction.
		l_oPost.ps_price = l_oPost.ps_price - &l_cVatMacro1 - &l_cVatMacro2
		lp_nAmount = ROUND(lp_nAmount + &l_cVatMacro1 + &l_cVatMacro2, param.pa_currdec)
	ENDIF
	l_oPost.ps_amount = ROUND(l_oPost.ps_units * l_oPost.ps_price, param.pa_currdec)
	l_oPost.ps_postid = IIF(lp_lTempPostId,FNNextIdTemp("post"),NextId("post"))
	l_nTotal = l_nTotal + l_oPost.ps_amount
	SELECT(lp_cPostAlias)
	APPEND BLANK
	GATHER NAME l_oPost MEMO
	PostHistory(l_oPost, l_oPost, "CREATED", lp_cPostAlias)
 ENDIF
 IF l_nDefUnits = lp_nUnits
	* Rounding error.
	IF 0 <> RoundIt(l_oPost.ps_reserid, l_oPost.ps_window, lp_nAmount, -l_nTotal, 1, "", lp_cPostAlias)
		REPLACE ps_addrid WITH IIF(EMPTY(lp_nAddrId), 0, lp_nAddrId), ;
				ps_billnum WITH IIF(EMPTY(lp_cBillNum), "", lp_cBillNum) IN &lp_cPostAlias
		IF l_lPayIdUsed
			REPLACE ps_payid WITH l_oPost.ps_payid IN &lp_cPostAlias
		ENDIF
	ENDIF
	lp_nAmount = 0.00
 ELSE
	lp_nAmount = lp_nAmount + l_nTotal
 ENDIF

 RETURN .T.
ENDPROC

PROCEDURE pbpayelpay
LPARAMETERS pnamount, npaynum, plcloseonsuccess, plcustompayment, plusepad, plmanual, pnpostid, pcpaymethoalias
LOCAL lsuccess, ctrack1, ctrack2, ctrack3, cpaperwidth, oelpay, cversionnumber, camt, ;
          oelpay AS celpay OF common\progs\kkelpay.prg, nclientid, lusepad, cstation, ntimeoutsec, nselect, ;
          ccurpy, creaderresult, cstorno, cbelegnr, cfunc, lmanual, cpan, cmmjj, cmops, cstornotype, celpaydir, ;
          ccustomamt, cpaywish, npayamount, npaynumorig, czahlart, ccustomzahlart, lcustomzahlartallowed
* When plcustompayment = .T., payment goes directly to elpay, is not bount to post table.
* This allows user to storno invalid payments.

plcloseonsuccess = .F.
IF NOT _screen.oGlobal.lelPay
     RETURN .T.
ENDIF
IF EMPTY(pcpaymethoalias)
     pcpaymethoalias = "paymetho"
ENDIF
IF NOT plcustompayment
     IF NOT &pcpaymethoalias..pm_elpay
          RETURN .T.
     ENDIF
     IF NOT pnamount <> 0.00
          RETURN .T.
     ENDIF
ENDIF

nselect = SELECT()

PRIVATE poelpayform
poelpayform = .NULL.

IF plcustompayment
     lusepad = plusepad
     lmanual = plmanual
     czahlart = ""
     pnamount = 0.00
     npaynum = 0
     npaynumorig = 0
     * Check if elpay payment is defined. If not, don't allow custom payment!
     nselect = SELECT()
     ccurpy = sqlcursor("SELECT TOP 1 pm_paynum FROM paymetho WHERE NOT pm_inactiv AND pm_elpay"+ICASE(plmanual," AND pm_elpyman",plusepad," AND pm_elpypad"," AND NOT pm_elpyman AND NOT pm_elpypad") + " ORDER BY 1")
     IF RECCOUNT(ccurpy)>0
          npaynumorig = &ccurpy..pm_paynum
     ENDIF
     dclose(ccurpy)
     SELECT (nselect)
     IF EMPTY(npaynumorig)
          alert(GetLangText("READGRP","TXT_INVALID_PAYMETH")+" (elPay)")
          RETURN .T.
     ENDIF
     * Check if zahlart is used
     nselect = SELECT()
     ccurpy = sqlcursor("SELECT TOP 1 pm_paynum FROM paymetho WHERE pm_elpyza <> '  ' ORDER BY 1")
     IF RECCOUNT(ccurpy)>0 AND NOT EMPTY(&ccurpy..pm_paynum)
          lcustomzahlartallowed = .T.
     ENDIF
     dclose(ccurpy)
     SELECT (nselect)
ELSE
     lusepad = &pcpaymethoalias..pm_elpypad
     lmanual = &pcpaymethoalias..pm_elpyman
     czahlart = &pcpaymethoalias..pm_elpyza
ENDIF

STORE "" TO cbelegnr, cstorno, cpan, cmmjj, cmops, cstornotype, celpaydir, ccustomamt, cpaywish, ccustomzahlart

IF lusepad
     * Do nothing, eplay will use i3380 do read card.
     *IF pnamount < 0 OR plcustompayment
          creaderresult = ""
          DO FORM common\forms\elpaycardreader.scx WITH pnamount,,.T.,,plcustompayment,lcustomzahlartallowed TO creaderresult
          IF EMPTY(creaderresult)
               alert("Kreditkarte NICHT gelesen!")
               RETURN .F.
          ENDIF
          cstorno = GETWORDNUM(creaderresult,4,"|")
          cbelegnr = ALLTRIM(GETWORDNUM(creaderresult,5,"|"))
          ccustomamt = ALLTRIM(GETWORDNUM(creaderresult,10,"|"))
          cstornotype = ALLTRIM(GETWORDNUM(creaderresult,9,"|"))
          cpaywish = ALLTRIM(GETWORDNUM(creaderresult,11,"|"))
          ccustomzahlart = ALLTRIM(GETWORDNUM(creaderresult,12,"|"))
     *ENDIF
ELSE
     
     ******************************************
     * TO DO
     * Here read card data from card reader!
     ******************************************
     creaderresult = ""
     DO FORM common\forms\elpaycardreader.scx WITH pnamount,,,lmanual,plcustompayment,lcustomzahlartallowed TO creaderresult
     IF EMPTY(creaderresult)
          alert("Kreditkarte NICHT gelesen!")
          RETURN .F.
     ENDIF
     IF lmanual
          cpan = ALLTRIM(GETWORDNUM(creaderresult,6,"|"))
          cmmjj = ALLTRIM(GETWORDNUM(creaderresult,7,"|"))
          cmops = ALLTRIM(GETWORDNUM(creaderresult,8,"|"))
     ELSE
          ctrack1 = ALLTRIM(GETWORDNUM(creaderresult,1,"|"))
          ctrack2 = ALLTRIM(GETWORDNUM(creaderresult,2,"|"))
          ctrack3 = ALLTRIM(GETWORDNUM(creaderresult,3,"|"))
     ENDIF
     cstornotype = ALLTRIM(GETWORDNUM(creaderresult,9,"|"))
     cstorno = GETWORDNUM(creaderresult,4,"|")
     cbelegnr = ALLTRIM(GETWORDNUM(creaderresult,5,"|"))
     ccustomamt = ALLTRIM(GETWORDNUM(creaderresult,10,"|"))
     ccustomzahlart = ALLTRIM(GETWORDNUM(creaderresult,12,"|"))
*!*          IF .T.
*!*               ctrack1 = "%B4053667506298698^PADILLA/L.                ^12041200000000000000**690******?q"
*!*               ctrack2 = ";4053667506298698=12041200123400000000?;"
*!*               ctrack3 = ""
*!*          ENDIF
ENDIF

IF plcustompayment
     pnamount = VAL(SUBSTR(ccustomamt,1,LEN(ccustomamt)-2) + SET("Point") + RIGHT(ccustomamt,2))
     czahlart = ccustomzahlart
ENDIF
DO FORM common\forms\elpaycardreader.scx NAME poelpayform WITH pnamount, .T. TO creaderresult NOSHOW
poelpayform.Show(2)


cstation = WinPc()
nclientid = _screen.oGlobal.oterminal.tm_elcltid
cversionnumber = g_cexeversion
ntimeoutsec = _screen.oGlobal.oterminal.tm_eltimeo
npaperwidth = _screen.oGlobal.oterminal.tm_elwidth
celpaydir = ALLTRIM(_screen.oGlobal.oterminal.tm_elpdir)

oelpay = NEWOBJECT("celpay","common\progs\kkelpay.prg")
oelpay.cProgressEvent = "pbshowprogress"
oelpay.cPrintEvent = "pbprintelpay"

IF cstorno = ".T."
     IF EMPTY(cbelegnr) AND cstornotype <> "2"
          * We don't need BelegNr for Gutschrift. This is like transfering founds to some bank account.
          alert("Beleg Nr. muss eingegeben werden!")
          RETURN .F.
     ENDIF
     DO CASE
          CASE cstornotype ="2" AND lmanual
               cfunc = "13" && Funktion 13; Gutschrift Kreditkarte manuell
          CASE cstornotype ="2"
               cfunc = "12" && Funktion 12; Gutschrift Kreditkarte
          CASE lmanual
               cfunc = "11" && Funktion 11; Stornieren Kreditkarte manuell
          OTHERWISE
               cfunc = "01" && Funktion 01; Stornieren ec- und Kreditkarten
     ENDCASE
     IF pnamount < 0
          pnamount = pnamount * -1
     ENDIF
ELSE
     IF lmanual
          cfunc = "10" && Funktion 10; Kreditkarte manuell
     ELSE
          cfunc = "00" && Funktion 00; Autorisieren ec- und Kreditkarten
     ENDIF
ENDIF

IF plcustompayment
     camt = ccustomamt
ELSE
     camt = ALLTRIM(STRTRAN(STRTRAN(STR(pnamount,12,2),".",""),",",""))
ENDIF

lsuccess = oelpay.Start(cfunc,camt,"Citadel Desk",cversionnumber,cstation,cpan,cmmjj,cmops,ctrack1,ctrack2,ctrack3,;
          npaperwidth,nclientid,ntimeoutsec,,,lusepad,,cbelegnr,celpaydir, cpaywish, czahlart)

IF VARTYPE(poelpayform)="O"
	poelpayform.Release()
ENDIF

IF lsuccess
     * Try to change to another paymethod
     IF NOT EMPTY(oelpay.nelpaypaynum)
          ccurpy = sqlcursor("SELECT pm_paynum FROM paymetho WHERE pm_elpynum = " + sqlcnv(oelpay.nelpaypaynum,.T.) + ;
               IIF(_screen.oglobal.SelectBuildingOnLoginAllowed() AND NOT EMPTY(_screen.oglobal.oBuilding.ccode), ;
               StrToSql(" AND pm_buildng = %s1", PADR(_screen.oglobal.oBuilding.ccode,3)), ""))
          IF USED(ccurpy) AND RECCOUNT()>0
               GO TOP
               npaynum = pm_paynum
          ENDIF
          dclose(ccurpy)
     ENDIF
     IF plcustompayment
          IF EMPTY(npaynum)
               npaynum = npaynumorig
          ENDIF
          IF npaynum > 0
               * Call BillPayProcess function. BillPayProcess will call pbpayelpay and do elpay payment. So we have payment posted in post.dbf
               IF cstorno = ".T."
                    npayamount = pnamount * -1
               ELSE
                    npayamount = pnamount
               ENDIF
               pnpostid = 0
               lsuccess = ProcBill("BillPayProcess", "post", 0.300, 0, 0, "", "ELPAY", npaynum, ;
                         npayamount, npayamount,,"ElPay",,,,,plcustompayment,@pnpostid)
          ENDIF
     ENDIF
     IF NOT EMPTY(pnpostid) AND openfile(.F.,"elpay")
          
          * Insert payment info in elpay table
          
          PRIVATE p_cPBEPInText
          PRIVATE p_cPBEPOutText
          PRIVATE p_cPBEPPrintText
          p_cPBEPInText = oelpay.RemoveSensitiveData(oelpay.oinfile.cInText)
          p_cPBEPOutText = oelpay.RemoveSensitiveData(oelpay.ooutfile.cOutText)
          p_cPBEPPrintText = oelpay.ooutfile.cPrintText

          sqlinsert("elpay", ;
                    "el_elid, el_postid, el_sent, el_reciv, el_print", ;
                    1, ;
                    sqlcnv(nextid("ELPAY"),.T.)+","+sqlcnv(pnpostid,.T.)+;
                    ",__SQLPARAM__p_cPBEPInText,__SQLPARAM__p_cPBEPOutText,__SQLPARAM__p_cPBEPPrintText";
                    )
     ENDIF

     IF plcustompayment AND lsuccess AND NOT EMPTY(pnpostid) AND NOT EMPTY(npayamount)
          * When manual elpay, print quittug
          PBCashierListPrintBill(IIF(npayamount>0,"TOBANK","FROMBANK"), sqlcursor("SELECT * FROM post WHERE ps_postid = " + TRANSFORM(pnpostid)))
     ENDIF
     plcloseonsuccess = .T.
ELSE
     alert("(" + oelpay.cerrorcode + ") " + oelpay.cerrortext)
ENDIF

oelpay.Release()
oelpay = .NULL.

WAIT CLEAR

SELECT (nselect)

RETURN lsuccess
ENDPROC
*
PROCEDURE pbelpaykassenschnitt
LOCAL nselect, lsuccess

* Kassenschnitt

IF NOT (_screen.oGlobal.lelPay AND _screen.oGlobal.oTerminal.tm_elksz2)
     RETURN .T.
ENDIF

nselect = SELECT()

lsuccess = pbelpaycallfunc("99",,ALLTRIM(_screen.oGlobal.oterminal.tm_elpdir),.T.)

SELECT (nselect)

RETURN lsuccess
ENDPROC
*
PROCEDURE pbelpaycallfunc
LPARAMETERS lp_cFunc, lp_lOnlyCheckAktive, lp_cElPayDir, lp_lQuiet
LOCAL cstation, nclientid, ntimeoutsec, oelpay

IF NOT _screen.oGlobal.lelPay
     RETURN .T.
ENDIF

cstation = WinPc()
nclientid = _screen.oGlobal.oterminal.tm_elcltid
cversionnumber = g_cexeversion
ntimeoutsec =  _screen.oGlobal.oterminal.tm_eltimeo
npaperwidth = _screen.oGlobal.oterminal.tm_elwidth
oelpay = NEWOBJECT("celpay","common\progs\kkelpay.prg")
oelpay.cProgressEvent = "pbshowprogress"
oelpay.cPrintEvent = "pbprintelpay"

IF lp_lOnlyCheckAktive
     lsuccess = oelpay.Start(,,"Citadel Desk",cversionnumber,cstation,"","","",,,,;
               npaperwidth,nclientid,ntimeoutsec,.F.,"",,.T.,,lp_cElPayDir)
     IF NOT lsuccess AND oelpay.cerrorcode <> "-1"
          alert("(" + oelpay.cerrorcode + ") " + oelpay.cerrortext)
     ENDIF
ELSE
     lsuccess = oelpay.Start(lp_cFunc,,"Citadel Desk",cversionnumber,cstation,"","","",,,,;
               npaperwidth,nclientid,ntimeoutsec,.F.,"",,.F.,,lp_cElPayDir)
     IF NOT lsuccess
          IF lp_lQuiet
               WAIT WINDOW "(" + oelpay.cerrorcode + ") " + oelpay.cerrortext TIMEOUT 30
          ELSE
               alert("(" + oelpay.cerrorcode + ") " + oelpay.cerrortext)
          ENDIF
     ENDIF

ENDIF


RETURN lsuccess
ENDPROC
*
PROCEDURE pbshowprogress
LPARAMETERS lp_cText
IF TYPE("poelpayform")="O" AND NOT ISNULL(poelpayform)
     poelpayform.OnShowProgress(lp_cText)
ELSE
     WAIT WINDOW lp_cText NOWAIT
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE pbprintelpay
LPARAMETERS pctext
LOCAL nlines, i, cprintmark, cline, cpcinit, cpcfullcut, cprinter, oprintdev, csetting, cvalue, cfrx, ;
          ccurname, cfrxfullpath
LOCAL ARRAY atext(1)

cprinter = ALLTRIM(_screen.oGlobal.oterminal.tm_elpport)
cfrx = ALLTRIM(_screen.oGlobal.oterminal.tm_elpfrx)
IF EMPTY(pctext)
     RETURN .F.
ENDIF
IF EMPTY(cprinter) AND EMPTY(cfrx)
     RETURN .F.
ENDIF

STORE "" TO cpcinit, cpcfullcut

IF NOT EMPTY(_screen.oGlobal.oterminal.tm_elpprn)
     nlines = ALINES(l_aText,_screen.oGlobal.oterminal.tm_elpprn)
     FOR i = 1 TO nlines
          cline = l_aText(i)
          csetting = LOWER(GETWORDNUM(cline,1,"="))
          cvalue = ALLTRIM(GETWORDNUM(cline,2,"="))
          DO CASE
               CASE csetting = "init"
                    cpcinit = cvalue
               CASE csetting = "fullcut"
                    cpcfullcut = cvalue
          ENDCASE
     ENDFOR
ENDIF

IF NOT EMPTY(cprinter)
     * Print to POS printer
     oprintdev = NEWOBJECT([PrintDev],[common\libs\rawprint.vcx])
     SET PRINTER TO DEFAULT
     oprintdev.cPrinterName = ALLTRIM(cprinter)
     oprintdev.cDocName     = "elPay slip print"
     IF .NOT. oprintdev.oOpen()
        msg = "Printer is not ready!"
        DO CASE
           CASE oprintdev.nopenerror == 0
                msg = msg +" Take a look in SPOOLER settings"
        OTHERWISE
                msg = msg + " Error 1 " +STR(oprintdev.nopenerror)
        ENDCASE
        MessageBox(msg, 16, "Printer Error")
        RETURN .F.
     ENDIF

     IF NOT EMPTY(cpcinit)
          oprintdev.oPrintMem(EVALUATE(cpcinit))
     ENDIF

     nlines = ALINES(atext,pctext)
     FOR i = 1 TO nlines
          cline = atext(i)
          cprintmark = STREXTRACT(cline,"",";")
          cline = ansitooem(STRTRAN(cline,cprintmark+";",""))
          oprintdev.oPrintMem(cline)
          oprintdev.oPrintMem(CRLF)
          IF cprintmark == "S"
               IF NOT EMPTY(cpcfullcut)
                    oprintdev.oPrintMem(EVALUATE(cpcfullcut))
               ENDIF
          ENDIF
     ENDFOR
     oprintdev.oClose()
ENDIF

IF NOT EMPTY(cfrx)
     ccurname = SYS(2015)
     CREATE CURSOR (ccurname) (pline m)
     INSERT INTO (ccurname) (pline) VALUES ("")
     nlines = ALINES(atext,pctext)
     FOR i = 1 TO nlines
          cline = atext(i)
          cprintmark = STREXTRACT(cline,"",";")
          cline = STRTRAN(cline,cprintmark+";","")
          REPLACE pline WITH pline + cline + CRLF IN (ccurname)
          IF cprintmark == "S"
               INSERT INTO (ccurname) (pline) VALUES ("")
          ENDIF
     ENDFOR
     DELETE FOR EMPTY(pline) IN (ccurname)
     g_Rptlngnr = g_Langnum
     g_Rptlng = g_Language
     cfrxfullpath = gcReportdir+FORCEEXT(ALLTRIM(cfrx),"FRX")
     IF FILE(cfrxfullpath)
          SELECT (ccurname)
          REPORT FORM (cfrxfullpath) TO PRINTER PROMPT NOCONSOLE
     ELSE
          = alErt(stRfmt("Report %s1 not found!",UPPER(cfrxfullpath)))
     ENDIF
     dclose(ccurname)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PBBonusUpdate
LPARAMETERS lp_cBillnum, lp_nReserId, lp_nWindow, lp_nAddrId, lp_cPostAlias
LOCAL l_nArea, l_oBMSHandler, l_cPremiumArticleList, l_cBonusPoints, l_curBonusArt, l_nBbId, l_lNoSplits, l_cWhere, ;
		l_lSuccess, l_lUseBsPendinTable, l_cSql, l_lHasPostings, l_lHasBonusPayments, l_lDontCopyInBsPending, ;
		nbonuscardid, l_lClosePostAlias, l_nAddrId, l_lDontUseCardReader

IF NOT (_screen.BMS AND (_screen.oGlobal.oParam2.pa_bmstype = 0 OR _screen.oGlobal.oParam2.pa_bsslfac > 0))
	RETURN .T.
ENDIF

l_lNoSplits = NOT _screen.oGlobal.lbmsratecodewithsplits
l_lUseBsPendinTable = IIF(_screen.oglobal.lusemainserver,.T.,.F.) && Only when desk used in multiproper installation, use bspendin table
l_nArea = SELECT()

IF EMPTY(lp_cPostAlias)
	lp_cPostAlias = SqlCursor("SELECT * FROM post WHERE ps_reserid = " + SqlCnv(lp_nReserId,.T.) + ;
		" AND ps_window = " + SqlCnv(lp_nWindow,.T.) + ;
		" AND NOT ps_cancel AND " + ;
		IIF(l_lNoSplits,"NOT ps_split","(EMPTY(ps_ratecod) OR ps_split)") + ;
		" AND NOT EMPTY(ps_amount)")
	l_lClosePostAlias = .T.
ENDIF

l_cPremiumArticleList = SqlCursor("SELECT ar_artinum, ar_bscramt, ar_lang"+g_langnum+" AS ar_lang, ar_bsdays FROM article WHERE ar_bscruse = (1=1)" + ;
	IIF(_screen.oGlobal.oParam2.pa_bmstype = 0, " AND ar_bscramt > 0", ""))

l_curBonusArt = SYS(2015)
l_cWhere = "NOT ps_cancel AND " + ;
		IIF(l_lNoSplits,"NOT ps_split","(EMPTY(ps_ratecod) OR ps_split)") + " AND " + ;
		"NOT EMPTY(ps_amount)"
SELECT * FROM &lp_cPostAlias ;
	INNER JOIN &l_cPremiumArticleList ON ps_artinum = ar_artinum ;
	WHERE &l_cWhere ;
	INTO CURSOR &l_curBonusArt READWRITE

IF RECCOUNT() > 0
	REPLACE ps_billnum WITH lp_cBillnum ALL
	IF _screen.oGlobal.oParam2.pa_bmstype = 1
		REPLACE ar_bscramt WITH _screen.oGlobal.oParam2.pa_bsslfac, ar_bsdays WITH _screen.oGlobal.oParam2.pa_bsdays ALL
	ENDIF
	SELECT * FROM &l_curBonusArt WHERE ps_units * ROUND(ar_bscramt * ps_price, 0) <> 0 INTO CURSOR &l_curBonusArt READWRITE
ENDIF

IF NOT EMPTY(_screen.oGlobal.oParam2.pa_bmspay)
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
		SELECT ps_postid FROM <<lp_cPostAlias>> WHERE ps_paynum = <<TRANSFORM(_screen.oGlobal.oParam2.pa_bmspay)>>
			INTO CURSOR curpayments23
	ENDTEXT
	&l_cSql
ENDIF

l_lHasPostings = (RECCOUNT(l_curBonusArt) > 0)
l_lHasBonusPayments = (USED("curpayments23") AND RECCOUNT("curpayments23")>0)

IF l_lHasPostings OR l_lHasBonusPayments
	l_oBMSHandler = NEWOBJECT("cBMSHandler", "common\progs\bmshandler.prg", "", SysDate(), g_userid, 1, ;
		_screen.oGlobal.oParam2.pa_bmstype, _screen.oGlobal.oParam2.pa_bsdays, _screen.oGlobal.oParam2.pa_hotcode)
	IF l_lUseBsPendinTable
		l_oBMSHandler.ProceedPendingBonus()
	ENDIF

	l_nAddrId = lp_nAddrId
	IF NOT EMPTY(lp_nReserId) AND NOT EMPTY(lp_nWindow) AND lp_nWindow > 1
		LOCAL ARRAY laReservat(1)
		laReservat(1) = .T.
		SqlCursor("SELECT rs_rsid, rs_addrid FROM reservat WHERE rs_reserid = " + SqlCnv(lp_nReserId,.T.),,,,,, @laReservat)
		IF TYPE("laReservat(1,1)") = "N" AND FNGetWindowData(laReservat(1,1), lp_nWindow, "pw_bmsto1w")
			l_nAddrId = laReservat(1,2)
			l_lDontUseCardReader = .T.
		ENDIF
	ENDIF
	l_lSuccess = l_oBMSHandler.CheckBonusAccount(l_nAddrId, @l_nBbId, 1, @l_lDontCopyInBsPending, @nbonuscardid, l_lDontUseCardReader)

	IF l_lHasPostings
		* We have some points to add
		IF l_lSuccess
			l_oBMSHandler.GenerateBonusPoints(l_curBonusArt, l_nBbId,,,nbonuscardid)
		ELSE
			#IF .F.
				* Don't use pending table, for now!
				IF l_lUseBsPendinTable
					* No connection to bms tables.
					* We have no information if this address has BMS account.
					* So we copy possible points to bspendin. We will later check, if this are real points or not.
					IF NOT l_lDontCopyInBsPending
						l_oBMSHandler.GenerateBonusPoints(l_curBonusArt, ,.T.,l_nAddrId,nbonuscardid)
					ENDIF
				ELSE
					* we are using desk in normal install (no multiproper), so when we can't acces our database, the is something seriosly wrong!
					* must reindex?
				ENDIF
			#ENDIF
		ENDIF
	ENDIF

	IF l_lHasBonusPayments
		IF EMPTY(l_nBbId)
			* Can happen when using card reader. But we must update billnum.
			l_oBMSHandler.UpdateBillNum(0, lp_cBillnum, "curpayments23", l_nAddrId, 0)
		ELSE
			l_oBMSHandler.UpdateBillNum(l_nBbId, lp_cBillnum, "curpayments23")
		ENDIF
	ENDIF
	DClose("bspost")
ENDIF
DClose(l_curBonusArt)
DClose(l_cPremiumArticleList)
DClose("curpayments23")
IF l_lClosePostAlias
	DClose(lp_cPostAlias)
ENDIF

SELECT (l_nArea)

RETURN .T.
ENDPROC
*
PROCEDURE PBBonusDiscount
LPARAMETERS lp_nWindow, lp_oBMSHandler
LOCAL i, l_nSelect, l_lChanged, l_nBbId, l_dSysDate, l_cSql, l_cPost, l_nAddrId, l_ncAddrId, l_lCheckBill, l_cDiscCod, l_nDiscPct, l_nAmount, l_nPrice, l_nUnits

l_nSelect = SELECT()

IF USED("postdisc") OR OpenFile(,"postdisc")
	l_dSysDate = SysDate()
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
		SELECT ps_postid FROM post INNER JOIN article ON ps_artinum = ar_artinum
			WHERE ps_reserid = <<SqlCnv(reservat.rs_reserid,.T.)>> AND <<IIF(EMPTY(lp_nWindow), "BETWEEN(ps_window,1,6)", "ps_window = " + SqlCnv(lp_nWindow,.T.))>> AND EMPTY(ps_billnum) AND 
			NOT ps_cancel AND (ar_discnt AND (EMPTY(ps_ratecod) OR NOT ps_split)) AND ps_date = <<SqlCnv(l_dSysDate,.T.)>>
	ENDTEXT
	l_cPost = SqlCursor(l_cSql)
	IF RECCOUNT(l_cPost) > 0
		IF VARTYPE(lp_oBMSHandler) <> "O"
			lp_oBMSHandler = NEWOBJECT("cBMSHandler", "common\progs\bmshandler.prg", "", SysDate(), g_userid, 1, _screen.oGlobal.oParam2.pa_bmstype, _screen.oGlobal.oParam2.pa_bsdays)
		ENDIF
		l_ncAddrId = 0
		FOR i = IIF(EMPTY(lp_nWindow), 1, lp_nWindow) TO IIF(EMPTY(lp_nWindow), 6, lp_nWindow)
			l_nAddrId = ProcBill("BillAddrId", i, reservat.rs_rsid, reservat.rs_addrid)
			IF EMPTY(l_nAddrId) OR l_ncAddrId = l_nAddrId
				l_lCheckBill = NOT EMPTY(l_nAddrId)
			ELSE
				l_ncAddrId = l_nAddrId
				l_lCheckBill = lp_oBMSHandler.CheckBonusAccount(l_nAddrId, @l_nBbId, 2)
				lp_oBMSHandler.GetVipStatusDiscount(l_nBbId, @l_cDiscCod, @l_nDiscPct)
			ENDIF
			IF l_lCheckBill
				SELECT post
				SCAN FOR ps_reserid = reservat.rs_reserid AND ps_window = i AND NOT ps_cancel AND ps_date = l_dSysDate
					DLocate("postdisc", "pd_postid = " + SqlCnv(ps_postid,.T.))
					IF postdisc.pd_discpct <> l_nDiscPct AND (Dlocate("article", "ar_artinum = " + SqlCnv(ps_artinum,.T.)) AND article.ar_discnt AND (EMPTY(ps_ratecod) OR NOT ps_split))
						SCATTER MEMVAR
						DO CASE
							CASE NOT FOUND("postdisc")
								INSERT INTO postdisc (pd_postid, pd_origamt, pd_discnt, pd_discpct, pd_tmstamp, pd_userid) ;
									VALUES (m.ps_postid, m.ps_price, l_cDiscCod, l_nDiscPct, DATETIME(), g_Userid)
								m.ps_price = ROUND(postdisc.pd_origamt * (100-postdisc.pd_discpct)/100, _screen.oGlobal.oParam.pa_currdec)
							CASE l_nDiscPct = 0
								m.ps_price = postdisc.pd_origamt
								DELETE IN postdisc
							OTHERWISE
								REPLACE pd_discnt WITH l_cDiscCod, ;
										pd_discpct WITH l_nDiscPct, ;
										pd_tmstamp WITH DATETIME(), ;
										pd_userid WITH g_Userid IN postdisc
								m.ps_price = ROUND(postdisc.pd_origamt * (100-postdisc.pd_discpct)/100, _screen.oGlobal.oParam.pa_currdec)
						ENDCASE

						SELECT post
						IF EMPTY(ps_ratecod)
							m.ps_amount = m.ps_price * m.ps_units
							PBCalculateVAT()
						ELSE
							l_nPrice = m.ps_price
							l_nUnits = m.ps_units
							SUM ps_amount TO l_nAmount FOR ps_setid = m.ps_setid AND ps_split AND ps_raid <> m.ps_raid
							m.ps_price = l_nPrice * l_nUnits - l_nAmount
							m.ps_units = 1
							m.ps_amount = m.ps_price * m.ps_units
							PBCalculateVAT()
                				IF DLocate("post", "ps_setid = " + SqlCnv(m.ps_setid ,.T.) + " AND ps_split AND ps_raid = " + SqlCnv(m.ps_raid,.T.))	&& change split main article.
								GATHER MEMVAR FIELDS ps_amount, ps_price, ps_units, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9
                				ENDIF
                				SUM ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9 ;
                					TO m.ps_vat0, m.ps_vat1, m.ps_vat2, m.ps_vat3, m.ps_vat4, m.ps_vat5, m.ps_vat6, m.ps_vat7, m.ps_vat8, m.ps_vat9 ;
                					FOR ps_setid = m.ps_setid AND ps_split
							m.ps_price = l_nPrice
							m.ps_units = l_nUnits
							m.ps_amount = m.ps_price * m.ps_units
                				DLocate("post", "ps_postid = " + SqlCnv(m.ps_postid,.T.))	&& change main article.
						ENDIF
						GATHER MEMVAR
						l_lChanged = .T.
					ENDIF
				ENDSCAN
			ENDIF
		NEXT
	ENDIF
	DClose(l_cPost)
ENDIF

SELECT (l_nSelect)

RETURN l_lChanged
ENDPROC
*
PROCEDURE PBCalculateVAT
LOCAL l_cVatMacro, l_nVat1, l_nVat2, l_Vatpct, l_Vatpct2, l_VatTyp2

STORE 0.00 TO l_nVat1, l_nVat2, m.ps_vat0, m.ps_vat1, m.ps_vat2, m.ps_vat3, m.ps_vat4, m.ps_vat5, m.ps_vat6, m.ps_vat7, m.ps_vat8, m.ps_vat9
l_Vatpct = DLookUp("picklist", "pl_label = [VATGROUP  ] AND pl_numcod = " + SqlCnv(article.ar_vat,.T.), "pl_numval")
l_Vatpct2 = IIF(article.ar_vat2 = 0, 0, DLookUp("picklist", "pl_label = [VATGROUP  ] AND pl_numcod = " + SqlCnv(article.ar_vat2,.T.), "pl_numval"))
l_VatTyp2 = IIF(article.ar_vat2 = 0, "", UPPER(ALLTRIM(DLookUp("picklist", "pl_label = [VATGROUP  ] AND pl_numcod = " + SqlCnv(article.ar_vat2,.T.), "pl_user2"))))
IF _screen.oGlobal.oParam.pa_exclvat
	IF l_VatTyp2 == "PP"
		IF m.ps_amount > article.ar_pprice
			l_nVat2 = (m.ps_amount-article.ar_pprice) * l_VatPct2/(100-l_VatPct2)
		ENDIF
		l_nVat1 = (m.ps_amount+l_nVat2) * l_VatPct/100
	ELSE
		l_nVat1 = m.ps_amount * l_VatPct/100
		IF l_VatTyp2 == "BT"
			l_nVat2 = l_VatPct2
		ELSE
			l_nVat2 = (m.ps_amount+IIF(_screen.oGlobal.oParam.pa_compvat,l_nVat1,0)) * l_VatPct2/100
		ENDIF
	ENDIF
ELSE
	l_nVat1 = m.ps_amount * l_VatPct/(100+l_VatPct)
	DO CASE
		CASE l_VatTyp2 == "PP"
			IF m.ps_amount > article.ar_pprice + l_nVat1
				l_nVat2 = (m.ps_amount-article.ar_pprice-l_nVat1) * l_VatPct2/100
			ENDIF
		CASE l_VatTyp2 == "BT"
			l_nVat2 = l_VatPct2
		OTHERWISE
			l_nVat2 = m.ps_amount * l_VatPct2/(100+l_VatPct2)
	ENDCASE
ENDIF
IF article.ar_vat > 0
	l_cVatMacro = "m.ps_vat"+TRANSFORM(article.ar_vat)
	&l_cVatMacro = l_nVat1
ENDIF 
IF article.ar_vat2 > 0
	l_cVatMacro = "m.ps_vat"+TRANSFORM(article.ar_vat2)
	&l_cVatMacro = l_nVat2
ENDIF 
ENDPROC
*
PROCEDURE PBBonusGetColor
LPARAMETERS lp_oObj,lp_cAddressAlias
LOCAL l_nColor, l_cSeekMacro, l_lFound, l_oBMSHandler, l_cVIPStatus, l_cDiscCod, l_nDiscPct, l_cCur, l_nBbid

l_nColor = RGB(0,0,0)

IF _screen.BMS
	l_nBbid = 0
	DO CASE
		CASE _screen.oGlobal.lUseMainServer AND _screen.oGlobal.lmainserverremote
			l_cCur = sqlcursor("SELECT bb_bbid FROM __#SRV.BSACCT#__ WHERE bb_adid = " + SqlCnv(&lp_cAddressAlias..ad_adid,.T.))
			IF USED(l_cCur)
				IF &l_cCur..bb_bbid > 0
					l_nBbid = &l_cCur..bb_bbid
					l_lFound = .T.
				ENDIF
				dclose(l_cCur)
			ENDIF
		CASE _screen.oGlobal.lUseMainServer
			CursorQuery("bsacct", "bb_adid = " + SqlCnv(&lp_cAddressAlias..ad_adid,.T.))
			l_cSeekMacro = [SEEK(]+lp_cAddressAlias+[.ad_adid,'bsacct','tag3')]
			l_lFound = &l_cSeekMacro
			l_nBbid = bsacct.bb_bbid
		OTHERWISE
			CursorQuery("bsacct", "bb_addrid = " + SqlCnv(&lp_cAddressAlias..ad_addrid,.T.))
			l_cSeekMacro = [SEEK(]+lp_cAddressAlias+[.ad_addrid,'bsacct','tag2')]
			l_lFound = &l_cSeekMacro
			l_nBbid = bsacct.bb_bbid
	ENDCASE
	IF l_lFound
		l_nColor = RGB(255,130,130)
	ENDIF
	IF VARTYPE(lp_oObj) = "O"
		lp_oObj.ForeColor = l_nColor
		IF l_lFound
			lp_oObj.Caption = TRIM(lp_oObj.Caption) + " (" + TRANSFORM(l_nBbid) + ")"
			l_oBMSHandler = NEWOBJECT("cBMSHandler", "common\progs\bmshandler.prg", "", SysDate(), g_userid, 1, _screen.oGlobal.oParam2.pa_bmstype, _screen.oGlobal.oParam2.pa_bsdays)
			l_cVIPStatus = l_oBMSHandler.GetVipStatusDiscount(l_nBbid, @l_cDiscCod, @l_nDiscPct)
			lp_oObj.cToolTipText = IIF(EMPTY(lp_oObj.cToolTipText), "", lp_oObj.cToolTipText + CHR(10)) + GetLangText("ADDRESS","TXT_VIP_STATUS") + ": " + ALLTRIM(l_cVIPStatus) + ;
					IIF(EMPTY(l_cVIPStatus), "", " (" + IIF(EMPTY(l_cDiscCod), GetLangText("CARDREADER","TA_1384"), ALLTRIM(l_cDiscCod)+" ["+TRANSFORM(-l_nDiscPct)+"%]")+")")
		ENDIF
	ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE ArticeVatAmounts
LPARAMETERS lp_nArtinum, lp_nAmount, lp_aVat, lp_lForPayment
LOCAL l_nVatPct1, l_nVatPct2, l_cVatTyp2, l_nPurchasePrice
EXTERNAL ARRAY lp_aVat
DIMENSION lp_aVat(2,2)

STORE 0 TO lp_aVat
IF SEEK(lp_nArtinum, "article", "tag1")
	= SEEK(PADR("VATGROUP",10)+STR(article.ar_vat,3), "picklist", "tag3")
	lp_aVat(1,1) = article.ar_vat
	l_nVatPct1 = picklist.pl_numval
	= SEEK(PADR("VATGROUP",10)+STR(article.ar_vat2,3), "picklist", "tag3")
	lp_aVat(2,1) = article.ar_vat2
	l_nVatPct2 = picklist.pl_numval
	l_cVatTyp2 = picklist.pl_user2
ELSE
	l_nVatPct1 = 0
	l_nVatPct2 = 0
	l_cVatTyp2 = ""
ENDIF
IF param.pa_exclvat
	IF UPPER(ALLTRIM(l_cVatTyp2)) <> "PP"
		IF lp_lForPayment
			IF UPPER(ALLTRIM(l_cVatTyp2)) <> "BT"
				IF param.pa_compvat
					lp_nAmount = lp_nAmount * (100 / (100 + l_nVatPct1 + l_nVatPct2 + l_nVatPct1 * l_nVatPct2 / 100))
				ELSE
					lp_nAmount = lp_nAmount * (100 / (100 + l_nVatPct1 + l_nVatPct2))
				ENDIF
			ELSE
				lp_nAmount = (lp_nAmount - l_nVatPct2) * (100 / (100 + l_nVatPct1))
			ENDIF
		ENDIF
		lp_aVat(1,2) = lp_nAmount * (l_nVatPct1 / 100)
		IF UPPER(ALLTRIM(l_cVatTyp2)) <> "BT"
			IF param.pa_compvat
				lp_aVat(2,2) = (lp_nAmount + lp_aVat(1,2)) * (l_nVatPct2 / 100)					
			ELSE
				lp_aVat(2,2) = lp_nAmount * (l_nVatPct2 / 100)
			ENDIF
		ELSE
			lp_aVat(2,2) = l_nVatPct2
		ENDIF
	ELSE
		l_nPurchasePrice = DbLookup("article", "tag1", lp_nArtinum, "ar_pprice")
		IF lp_nAmount - l_nPurchasePrice > 0
			IF lp_lForPayment
				lp_nAmount = (lp_nAmount + l_nPurchasePrice * l_nVatPct2 / (100 - l_nVatPct2) * (1 + l_nVatPct1 / 100)) / ;
					(1 + l_nVatPct2 / (100 - l_nVatPct2) + l_nVatPct1 / 100 + l_nVatPct2 / (100 - l_nVatPct2) * l_nVatPct1 / 100)
			ENDIF
			lp_aVat(2,2) = (lp_nAmount - l_nPurchasePrice) * l_nVatPct2 / (100 - l_nVatPct2)
		ELSE
			lp_nAmount = lp_nAmount * 100 / (100 + l_nVatPct1)
		ENDIF
		lp_aVat(1,2) = (lp_nAmount + lp_aVat(2,2)) * (l_nVatPct1 / 100)
	ENDIF
ELSE
	lp_aVat(1,2) = lp_nAmount * ( 1 - (100 / (100 + l_nVatPct1)))
	DO CASE
		CASE UPPER(ALLTRIM(l_cVatTyp2)) == "PP"
			l_nPurchasePrice = DbLookup("article", "tag1", lp_nArtinum, "ar_pprice")
			IF lp_nAmount - l_nPurchasePrice - lp_aVat(1,2) > 0
				lp_aVat(2,2) = (lp_nAmount - l_nPurchasePrice - lp_aVat(1,2)) * (l_nVatPct2 / 100)
			ENDIF
		CASE UPPER(ALLTRIM(l_cVatTyp2)) == "BT"
			lp_aVat(2,2) = l_nVatPct2
		OTHERWISE
			lp_aVat(2,2) = lp_nAmount * ( 1 - (100 / (100 + l_nVatPct2)))
	ENDCASE
ENDIF
ENDPROC

PROCEDURE BillPaymentCheck
 LPARAMETERS lp_nReserId, lp_nWin, lp_nPayNum
 LOCAL l_lResult, l_nAddressID, l_nSelect
 l_lResult = .T.
 IF _screen.dv
 	IF lp_nPayNum > 0 AND dlookup("paymetho","pm_paynum="+sqlcnv(lp_nPayNum),"pm_paytyp")=4
		l_nSelect = SELECT()
		l_cCurTemp = SYS(2015)
		SELECT rs_rsid, rs_addrid FROM reservat WHERE rs_reserid = lp_nReserId INTO CURSOR &l_cCurTemp
		IF RECCOUNT()>0
			DO BillAddrId IN ProcBill WITH lp_nWin,&l_cCurTemp..rs_rsid,&l_cCurTemp..rs_addrid,l_nAddressID
			l_lResult = EMPTY(alwcledg(l_nAddressID,.T.))
		ENDIF
		dclose(l_cCurTemp)
		SELECT (l_nSelect)
	ENDIF
 ENDIF
 RETURN l_lResult
ENDPROC

PROCEDURE payaskforaccount
 LPARAMETERS lp_nAccountNo
 LOCAL l_nSelect
 l_nSelect = SELECT()
 DO FORM forms\accountselectform TO lp_nAccountNo
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC

PROCEDURE BillSelectedPostsApproved
LPARAMETERS lp_cAlias, lp_cForClause, lp_nWin, lp_nReserId
LOCAL l_nSelect, l_lApproved, l_nRecNo, l_cMacroReserId
IF EMPTY(lp_nReserId)
	l_cMacroReserId = "ps_reserid"
ELSE
	l_cMacroReserId = "lp_nReserId"
ENDIF
l_lApproved = .T.
l_nSelect = SELECT()
SELECT (lp_cAlias)
l_nRecNo = RECNO()
SCAN FOR &lp_cForClause
	IF NOT BillPaymentCheck(&l_cMacroReserId, lp_nWin, ps_paynum)
		l_lApproved = .F.
		EXIT
	ENDIF
ENDSCAN
GOTO l_nRecNo
SELECT (l_nSelect)
RETURN l_lApproved
ENDPROC
*
FUNCTION SetPassBillStyle
LPARAMETERS lp_nPassBillStyle
IF lp_nPassBillStyle==1
	SELECT query
	SET ORDER TO
ELSE
	SELECT query
	INDEX ON STR(ps_paynum, 3)+STR(ps_artinum) TAG tag1
ENDIF
RETURN
ENDFUNC
*
PROCEDURE BillArPaymentDetails
LPARAMETERS lp_cArPayDescriptionText, lp_cArPayDiscountText, lp_nAddrID, lp_cCursorName, lp_nayid
LOCAL l_nSelect, l_nRecNo, l_cOrder, l_lArPaymentFound
STORE "" TO lp_cArPayDescriptionText, lp_cArPayDiscountText
l_lArPaymentFound = .T.
l_nSelect = SELECT()
*SELECT (lp_cCursorName)
*l_nRecNo = RECNO()
*l_cOrder = ORDER()
*SCAN ALL FOR ps_paynum > 0 AND ps_amount <> 0
*	IF dlookup("paymetho","pm_paynum = "+ sqlcnv(ps_paynum),"pm_paytyp") = 4
*		l_lArPaymentFound = .T.
*		EXIT
*	ENDIF
*ENDSCAN
IF l_lArPaymentFound
	lp_nArAcct = dlookup("aracct","ac_addrid = " + sqlcnv(lp_nAddrID) + " AND NOT ac_credito","ac_aracct")
	IF lp_nArAcct > 0
		DO ArPaymentDetails IN araccount WITH lp_nArAcct, lp_cArPayDescriptionText ;
			, lp_cArPayDiscountText, lp_nayid
	ENDIF
ENDIF
*SET ORDER TO l_cOrder
*GO l_nRecNo
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE BillsPaymentCondition 
LPARAMETERS lp_nReserId, lp_nBillNo, lp_nBillAyid
LOCAL l_nRecNo, l_nBillAyid
l_nRecNo = RECNO("reservat")
IF SEEK(lp_nReserId, "reservat", "tag1")
	l_nBillAyid = FNGetWindowData(reservat.rs_rsid, lp_nBillNo, "pw_blamid")
	IF lp_nBillAyid <> l_nBillAyid
		FNSetWindowData(reservat.rs_rsid, lp_nBillNo, "pw_blamid", lp_nBillAyid)
		FLUSH
	ENDIF
ENDIF
GO l_nRecNo IN reservat
RETURN .T.
ENDPROC
*
FUNCTION SpcNeedToUpdateStatistics
 LPARAMETERS lp_nReserId, lp_aChangedDates
 EXTERNAL ARRAY lp_aChangedDates
 LOCAL l_lUpdateStatistics, l_lGoesToPasserby
 l_lGoesToPasserby = DLocate("histpost", "hp_reserid = " + SqlCnv(lp_nReserId) + ;
		" AND SEEK(hp_postid, 'post', 'tag3') AND post.ps_reserid = 0.100")
 l_lUpdateStatistics = l_lGoesToPasserby OR DLocate("histpost", "hp_reserid = " + SqlCnv(lp_nReserId) + ;
		" AND NOT SEEK(hp_postid, 'post', 'tag3')")
 IF NOT l_lUpdateStatistics
	l_lUpdateStatistics = DLocate("post", "ps_reserid = " + SqlCnv(lp_nReserId) + ;
		" AND NOT SEEK(ps_postid, 'histpost', 'tag3') AND ps_date < " + SqlCnv(Sysdate()))
 ENDIF
 STORE .F. TO lp_aChangedDates
 IF l_lUpdateStatistics
	IF l_lGoesToPasserby
		SELECT DISTINCT hp_date FROM histpost INNER JOIN post ON hp_postid = ps_postid ;
			WHERE hp_reserid = lp_nReserId AND ps_reserid = 0.100 ;
			INTO ARRAY lp_aChangedDates
	ELSE
		SELECT DISTINCT ps_date FROM post ;
			WHERE ps_reserid = lp_nReserId AND ps_date < SysDate() AND NOT SEEK(post.ps_postid, "histpost", "tag3") ;
			UNION SELECT hp_date FROM histpost ;
			WHERE hp_reserid = lp_nReserId AND NOT SEEK(histpost.hp_postid, "post", "tag3") ;
			INTO ARRAY lp_aChangedDates
	ENDIF
 ENDIF
 RETURN l_lUpdateStatistics 
ENDFUNC
*
PROCEDURE SpcDeleteFromHistpost
 LPARAMETERS lp_nReserId
 IF NOT USED("hpostifc")
 	openfiledirect(.F.,"hpostifc")
 ENDIF
 SELECT histpost
 SCAN FOR hp_reserid = lp_nReserId AND NOT SEEK(histpost.hp_postid, "post", "tag3")
	* Delete from history if records are not in post.dbf
	IF NOT EMPTY(histpost.hp_setid)
		DELETE FOR rk_setid = histpost.hp_setid IN hpostifc
	ENDIF
	ProcReservat("FromPostchangesToHist", histpost.hp_postid)
	DELETE IN histpost
 ENDSCAN
ENDPROC
*
PROCEDURE SpcFromPostToHist
LPARAMETERS lp_nReserId
 SELECT post
 * Insert into history records that are in post.dbf and not in histpost.dbf
 SCAN FOR ps_reserid = lp_nReserId AND NOT SEEK(post.ps_postid, "histpost", "tag3")
	APPEND BLANK IN histpost
	REPLACE hp_addrid WITH post.ps_addrid, ;
			hp_amount WITH post.ps_amount, ;
			hp_artinum WITH post.ps_artinum, ;
			hp_billnum WITH post.ps_billnum, ;
			hp_cancel WITH post.ps_cancel, ;
			hp_cashier WITH post.ps_cashier, ;
			hp_currtxt WITH post.ps_currtxt, ;
			hp_date WITH post.ps_date, ;
			hp_descrip WITH post.ps_descrip, ;
			hp_fibdat WITH post.ps_fibdat, ;
			hp_ifc WITH post.ps_ifc, ;
			hp_note WITH post.ps_note, ;
			hp_origid WITH post.ps_origid, ;
			hp_paynum WITH post.ps_paynum, ;
			hp_postid WITH post.ps_postid, ;
			hp_price WITH post.ps_price, ;
			hp_prtype WITH post.ps_prtype, ;
			hp_ratecod WITH post.ps_ratecod, ;
			hp_reserid WITH post.ps_reserid, ;
			hp_setid WITH post.ps_setid, ;
			hp_split WITH post.ps_split, ;
			hp_supplem WITH post.ps_supplem, ;
			hp_time WITH post.ps_time, ;
			hp_units WITH post.ps_units,  ;
			hp_userid WITH post.ps_userid, ;
			hp_vat0 WITH post.ps_vat0, ;
			hp_vat1 WITH post.ps_vat1, ;
			hp_vat2 WITH post.ps_vat2, ;
			hp_vat3 WITH post.ps_vat3, ;
			hp_vat4 WITH post.ps_vat4, ;
			hp_vat5 WITH post.ps_vat5, ;
			hp_vat6 WITH post.ps_vat6, ;
			hp_vat7 WITH post.ps_vat7, ;
			hp_vat8 WITH post.ps_vat8, ;
			hp_vat9 WITH post.ps_vat9, ;
			hp_window WITH post.ps_window ;
			IN histpost
	ProcReservat("FromRpostifcToHist", post.ps_setid)
	ProcReservat("FromPostchangesToHist", post.ps_postid)
 ENDSCAN
ENDPROC
*
PROCEDURE SpcUpdateStatistics
 LPARAMETERS lp_nReserId, lp_aChangedDates
 EXTERNAL ARRAY lp_aChangedDates
 LOCAL l_nDateNo, l_cProgressTitle, l_oProgressBar
 l_cProgressTitle = GetLangText("CASHIER","TA_PROCESSING")
 l_oProgressBar = NEWOBJECT("_thermometer","_therm.vcx","",l_cProgressTitle,0)
 l_oProgressBar.Show()
 l_oProgressBar.iBasis = ALEN(lp_aChangedDates)*4

 FOR l_nDateNo = 1 TO ALEN(lp_aChangedDates)
	DO ManagerRevUpdate IN Manager WITH lp_aChangedDates(l_nDateNo)
	l_oProgressBar.Update(l_nDateNo*4 - 3)
	DO ManagerBuildRevUpdate IN ManagerBuildings WITH lp_aChangedDates(l_nDateNo), lp_nReserId
	l_oProgressBar.Update(l_nDateNo*4 - 2)
	DO OccupancyStatRevUpdate IN Orupd WITH lp_aChangedDates(l_nDateNo)
	l_oProgressBar.Update(l_nDateNo*4 - 1)
	DO AddressStatRevUpdate IN Aaupd WITH lp_aChangedDates(l_nDateNo)
	l_oProgressBar.Update(l_nDateNo*4)
 NEXT

 l_oProgressBar.Complete(GetLangText("COMMON","TXT_DONE"))
 l_oProgressBar.Release()
ENDPROC
*
PROCEDURE SpcBillNumUpdate
 LPARAMETERS lp_nReserID
 LOCAL l_nBillWin, l_cBillNum
 IF EMPTY(lp_nReserId)
	lp_nReserId = reservat.rs_reserid
 ENDIF
 IF reservat.rs_reserid <> lp_nReserId AND NOT SEEK(lp_nReserId,"reservat","tag1")
	RETURN .F.
 ENDIF
 FOR l_nBillWin = 1 TO 6
	l_cBillNum = ALLTRIM(FNGetBillData(reservat.rs_reserid, l_nBillWin, "bn_billnum"))
	BillUpdate(lp_nReserID, l_nBillWin, l_cBillNum, .T.)
 ENDFOR
ENDPROC
*
PROCEDURE SpcDeleteFromHistory
 LPARAMETERS lp_nReserId
 LOCAL l_oEnvironment

 l_oEnvironment = SetEnvironment("hsheet, hdeposit, hbanquet, hresroom, hresrate, hresfix, hbillins, histres, hresext")
 DELETE FOR sh_reserid = lp_nReserId IN hsheet
 DELETE FOR dp_reserid = lp_nReserId IN hdeposit
 DELETE FOR bq_reserid = lp_nReserId IN hbanquet
 DELETE FOR ri_reserid = lp_nReserId IN hresroom
 DELETE FOR rr_reserid = lp_nReserId IN hresrate
 DELETE FOR rf_reserid = lp_nReserId IN hresfix
 DELETE FOR bi_reserid = lp_nReserId IN hbillins
 DELETE FOR hr_reserid = lp_nReserId IN histres
 DELETE FOR rs_reserid = lp_nReserId IN hresext
 SpcPostFromHistresToPasserby(lp_nReserId)
ENDPROC
*
PROCEDURE SpcPostFromReserToPasserby
 LPARAMETERS lp_nReserId
 SELECT post
 SCAN FOR ps_reserid = lp_nReserId
	IF NOT EMPTY(post.ps_billnum) AND SEEK(post.ps_billnum, "billnum", "tag1") AND ;
			billnum.bn_reserid <> 0.100
		REPLACE bn_addrid WITH 0, ;
				bn_apid WITH 0, ;
				bn_reserid WITH 0.100, ;
				bn_window WITH 1 IN billnum
	ENDIF
	REPLACE ps_addrid WITH 0, ;
			ps_origid WITH 0.100, ;
			ps_reserid WITH 0.100, ;
			ps_window WITH 1 IN post
 ENDSCAN
ENDPROC
*
PROCEDURE SpcPostFromHistresToPasserby
 LPARAMETERS lp_nReserId
 SELECT histpost
 SCAN FOR hp_reserid = lp_nReserId AND SEEK(histpost.hp_postid, "post", "tag3")
	DELETE IN post
	DELETE FOR ph_postid = histpost.hp_postid IN postchng
	REPLACE hp_addrid WITH 0, ;
			hp_origid WITH 0.100, ;
			hp_reserid WITH 0.100, ;
			hp_window WITH 1 ;
		IN histpost
 ENDSCAN
ENDPROC
*
PROCEDURE SpcAfterDeleteReser
 LPARAMETERS lp_nReserId, lp_lInHistory
 LOCAL l_lUpdateStatistics, l_nDateNo, l_cProgressTitle, l_oProgressBar
 LOCAL ARRAY l_aChangedDates(1)
 SpcPostFromReserToPasserby(lp_nReserId)
 l_lUpdateStatistics = SpcNeedToUpdateStatistics(lp_nReserId, @l_aChangedDates)
 IF l_lUpdateStatistics
	l_cProgressTitle = GetLangText("CASHIER","TA_PROCESSING")
	l_oProgressBar = NEWOBJECT("_thermometer","_therm.vcx","",l_cProgressTitle,0)
	l_oProgressBar.Show()
	l_oProgressBar.iBasis = ALEN(l_aChangedDates) * 2 + 4
	SpcUpdateCash(@l_aChangedDates)
	DO RemoveReservation IN Manager WITH lp_nReserId
	l_oProgressBar.Update(1)
	DO RemoveReservation IN ManagerBuildings WITH lp_nReserId
	l_oProgressBar.Update(2)
	DO RemoveReservation IN Orupd WITH lp_nReserId, lp_lInHistory
	l_oProgressBar.Update(3)
	DO RemoveReservation IN Aaupd WITH lp_nReserId, lp_lInHistory
	l_oProgressBar.Update(4)
	SpcDeleteFromHistory(lp_nReserId)
	FOR l_nDateNo = 1 TO ALEN(l_aChangedDates)
		DO OccupancyStatRevUpdate IN Orupd WITH l_aChangedDates(l_nDateNo)
		l_oProgressBar.Update(l_nDateNo*2 + 3)
		DO AddressStatRevUpdate IN Aaupd WITH l_aChangedDates(l_nDateNo)
		l_oProgressBar.Update(l_nDateNo*2 + 4)
	NEXT

	l_oProgressBar.Complete(GetLangText("COMMON","TXT_DONE"))
	l_oProgressBar.Release()
 ENDIF
ENDPROC
*
FUNCTION ChangeVAT
LPARAMETERS lp_dForDate, lp_cPlTmp, lp_cArTmp, lp_lJustNewVAT
LOCAL l_lChanged, l_lChangeToNew, l_lChangeArticle, l_lChangePicklist, l_oIniReg, l_cIniLoc
LOCAL l_cOldVATGroup, l_cNewVATGroup, l_cNewVATName, l_cNewVATPercent, l_cChangeDate
LOCAL l_nOldVATGroup, l_nNewVATGroup, l_nNewVATPercent, l_dChangeDate, l_oRecord, l_nLangNo, l_cField
LOCAL l_nSelect, l_cOrder, l_cExVcArticles

l_nSelect = SELECT()
l_oIniReg = CREATEOBJECT("OldIniReg")
l_cOldVATGroup = ""
l_nOldVATGroup = 0
l_cNewVATGroup = ""
l_nNewVATGroup = 0
l_cNewVATName = ""
l_cNewVATPercent = ""
l_nNewVATPercent = 0
l_cChangeDate = ""
l_dChangeDate = {}
l_cIniLoc = FULLPATH(ChangeVatGetIni())

IF l_oIniReg.GetINIEntry(@l_cChangeDate, "ChangeVAT", "ChangeDate", l_cIniLoc) = ERROR_SUCCESS
    * Check first if need to be changed.
    l_dChangeDate = CTOD(l_cChangeDate)
    l_lChangeToNew = (Sysdate() < l_dChangeDate)
    l_lChanged = (l_lChangeToNew # (lp_dForDate < l_dChangeDate))    && XOR comparison 
    IF Sysdate() >= l_dChangeDate
         ChangeVATGetProp("EXVCCHANGEARTICLES")
         l_oIniReg = .NULL.
         l_oIniReg = CREATEOBJECT("OldIniReg")
    ENDIF
ENDIF

IF l_lChanged
    IF l_lChangeToNew
        * Cange to new VAT group mode.
        IF l_oIniReg.GetINIEntry(@l_cNewVATGroup, "ChangeVAT", "NewVATGroup", l_cIniLoc) = ERROR_SUCCESS AND ;
                l_oIniReg.GetINIEntry(@l_cNewVATName, "ChangeVAT", "NewVATName", l_cIniLoc) = ERROR_SUCCESS AND ;
                l_oIniReg.GetINIEntry(@l_cNewVATPercent, "ChangeVAT", "NewVATPercent", l_cIniLoc) = ERROR_SUCCESS
            l_nNewVATGroup = INT(VAL(l_cNewVATGroup))
            l_nNewVATPercent = INT(VAL(l_cNewVATPercent))
            l_lChangePicklist = .T.
             IF NOT lp_lJustNewVAT
                 IF l_oIniReg.GetINIEntry(@l_cOldVATGroup, "ChangeVAT", "OldVATGroup", l_cIniLoc) = ERROR_SUCCESS
                      l_nOldVATGroup = INT(VAL(l_cOldVATGroup))
                      l_lChangeArticle = .T.
                  ELSE
                      l_lChanged = .F.
                  ENDIF
             ENDIF
        ELSE
            l_lChanged = .F.
        ENDIF
    ELSE
        * Cange to old VAT group mode.
        IF NOT lp_lJustNewVAT AND ;
                l_oIniReg.GetINIEntry(@l_cOldVATGroup, "ChangeVAT", "OldVATGroup", l_cIniLoc) = ERROR_SUCCESS AND ;
                l_oIniReg.GetINIEntry(@l_cNewVATGroup, "ChangeVAT", "NewVATGroup", l_cIniLoc) = ERROR_SUCCESS
            l_nOldVATGroup = INT(VAL(l_cOldVATGroup))
            l_nNewVATGroup = INT(VAL(l_cNewVATGroup))
            l_lChangeArticle = .T.
        ELSE
            l_lChanged = .F.
        ENDIF
    ENDIF
ENDIF

IF l_lChanged AND l_lChangeArticle
    l_cExVcArticles = ChangeVATGetProp("EXVCARTICLELIST")
    lp_cArTmp = FileTemp('DBF')
    SELECT article
    l_cOrder = ORDER()
    COPY TO (lp_cArTmp) WITH CDX ALL
    dclose("article")
    USE (lp_cArTmp) ALIAS article IN 0
    IF l_lChangeToNew
         l_cExVcArticles = IIF(EMPTY(l_cExVcArticles), "ar_vat = " + SqlCnv(l_nOldVATGroup), "ar_artinum IN ("+l_cExVcArticles+")")
         UPDATE article SET ar_vat = l_nNewVATGroup WHERE &l_cExVcArticles AND ar_vat = l_nOldVATGroup
    ELSE
         l_cExVcArticles = IIF(EMPTY(l_cExVcArticles), "ar_vat = " + SqlCnv(l_nNewVATGroup), "ar_artinum IN ("+l_cExVcArticles+")")
         UPDATE article SET ar_vat = l_nOldVATGroup WHERE &l_cExVcArticles AND ar_vat = l_nNewVATGroup
    ENDIF
    SET ORDER TO l_cOrder IN article
ELSE
    lp_cArTmp = ""
ENDIF

IF l_lChanged AND l_lChangePicklist
    lp_cPlTmp = FileTemp('DBF')
    SELECT picklist
    l_cOrder = ORDER()
    COPY TO (lp_cPlTmp) WITH CDX ALL
    dclose("picklist")
    USE (lp_cPlTmp) ALIAS picklist IN 0
    DLocate("picklist", "pl_label+STR(pl_numcod,3) = '" + PADR("VATGROUP",10) + IIF(l_nOldVATGroup = 0, "", STR(l_nOldVATGroup,3)) + "'")
    SELECT picklist
    SCATTER NAME l_oRecord MEMO
    l_oRecord.pl_numcod = l_nNewVATGroup
    l_oRecord.pl_numval = l_nNewVATPercent
    FOR l_nLangNo = 1 TO 11
        l_cField = "pl_lang" + ALLTRIM(STR(l_nLangNo,2))
        l_oRecord.&l_cField = l_cNewVATName
    NEXT
    IF NOT DLocate("picklist", "pl_label+STR(pl_numcod,3) = '" + PADR("VATGROUP",10) + STR(l_nNewVATGroup,3) + "'")
        APPEND BLANK
    ENDIF
    GATHER NAME l_oRecord MEMO
    SET ORDER TO l_cOrder
ELSE
    lp_cPlTmp = ""
ENDIF

SELECT (l_nSelect)

RETURN l_lChanged
ENDFUNC
*
PROCEDURE RestoreVAT
LPARAMETERS lp_cPlTmp, lp_cArTmp
LOCAL l_nSelect

l_nSelect = SELECT()

IF NOT EMPTY(lp_cPlTmp)
    * Restoring Picklist.dbf
    dclose("picklist")
    FileDelete(lp_cPlTmp)
    FileDelete(STRTRAN(lp_cPlTmp, '.DBF', '.FPT'))
    FileDelete(STRTRAN(lp_cPlTmp, '.DBF', '.CDX'))
    OpenFile(.F., "picklist")
ENDIF

IF NOT EMPTY(lp_cArTmp)
    * Restoring Article.dbf
    dclose("article")
    FileDelete(lp_cArTmp)
    FileDelete(STRTRAN(lp_cArTmp, '.DBF', '.FPT'))
    FileDelete(STRTRAN(lp_cArTmp, '.DBF', '.CDX'))
    OpenFile(.F., "article")
ENDIF
SELECT (l_nSelect)
ENDPROC
*
PROCEDURE ChangeVATGetProp
LPARAMETERS tcProp, tuParam1
LOCAL luRetVal, lcExtFileName, llDevelopment, l_cHotDir, loIniReg, lcChangeDate, ldChangeDate
luRetVal = ""

l_cHotDir = IIF(TYPE("_screen.oGlobal.choteldir")="C",_screen.oGlobal.choteldir, "")
lcExtFileName = l_cHotDir + "exvatchange"
llDevelopment = (TYPE("g_lDevelopment") <> "U") AND g_lDevelopment

IF llDevelopment AND FILE(lcExtFileName + ".prg") OR FILE(lcExtFileName + ".fxp")
     DO CASE
          CASE EMPTY(tcProp)
          CASE tcProp = "EXVCARTICLELIST"
               luRetVal = tcProp
               DO &lcExtFileName WITH luRetVal
          CASE tcProp = "EXVCCHANGEARTICLES"
               DO &lcExtFileName WITH tcProp
          CASE tcProp = "EXVCLOGIS7PCT"
               loIniReg = CREATEOBJECT("OldIniReg")
               lcChangeDate = ""
               ldChangeDate = {}
               IF loIniReg.GetINIEntry(@lcChangeDate, "ChangeVAT", "ChangeDate", FULLPATH(ChangeVatGetIni())) = ERROR_SUCCESS
                   ldChangeDate = CTOD(lcChangeDate)
               ENDIF
               luRetVal = (tuParam1 >= ldChangeDate)
          OTHERWISE
     ENDCASE
ELSE
     IF PCOUNT()>1 && EXVCLOGIS7PCT
          luRetVal = .F.
          IF tcProp = "EXVCLOGIS7PCT" AND NOT _screen.oGlobal.oParam2.pa_spabill
               luRetVal = .T.
          ENDIF
     ENDIF
ENDIF

RETURN luRetVal
ENDPROC
*
PROCEDURE ChangeVatGetIni
LOCAL l_cHotDir, l_cIniFile
l_cIniFile = ""
* check ini file
l_cHotDir = IIF(TYPE("_screen.oGlobal.choteldir")="C",_screen.oGlobal.choteldir, "")

#IFDEF INI_FILE
     l_cIniFile = INI_FILE
#ENDIF

DO CASE
     CASE NOT EMPTY(l_cIniFile)
     CASE FILE(l_cHotDir+"citadel.ini")
          l_cIniFile = l_cHotDir+"citadel.ini"
     CASE FILE(l_cHotDir+"brilliant.ini")
          l_cIniFile = l_cHotDir+"brilliant.ini"
     OTHERWISE
          l_cIniFile = ""
ENDCASE
RETURN l_cIniFile
ENDPROC
*
PROCEDURE SpcUpdateCash
LPARAMETERS lp_aPayDates
EXTERNAL ARRAY lp_aPayDates
LOCAL l_cSumAlias
LOCAL l_dDate, l_dCurrDate, l_nDate, l_nCashier, l_nPaynum, l_nUnitDiff, l_nAmountDiff
IF TYPE("lp_aPayDates(1)") <> "D"
	RETURN .F.
ENDIF
l_cSumAlias = SYS(2015)
FOR l_nDate = 1 TO ALEN(lp_aPayDates,1)
	l_dDate = lp_aPayDates(l_nDate)
	SELECT SUM(hp_units) AS sum_units, SUM(hp_amount) AS sum_amount, hp_cashier, hp_paynum ;
			FROM histpost ;
			WHERE hp_date = l_dDate AND NOT EMPTY(hp_paynum) AND NOT hp_cancel ;
			GROUP BY hp_cashier, hp_paynum ;
			HAVING ROUND(sum_units, 2) <> 0.00 ;
			INTO CURSOR (l_cSumAlias)
	SCAN
		l_nCashier = &l_cSumAlias..hp_cashier
		l_nPaynum = &l_cSumAlias..hp_paynum
		l_nUnitDiff = ROUND(-&l_cSumAlias..sum_units, 2)
		*** amount is not calculated as amount = -units*price - rounding problem
		*** amount difference is used
		l_nAmountDiff = ROUND(-&l_cSumAlias..sum_amount, 2)
		IF Param.pa_noclose
			l_dCurrDate = l_dDate
			DO WHILE l_dCurrDate < Param.pa_sysdate
				= SpcUpdateCashDetails(l_nUnitDiff, l_nAmountDiff, l_dCurrDate, l_nPaynum, l_nCashier)
				l_dCurrDate = l_dCurrDate + 1
			ENDDO
		ELSE
			= SpcUpdateCashDetails(l_nUnitDiff, l_nAmountDiff, l_dDate, l_nPaynum, l_nCashier)
		ENDIF
		SELECT (l_cSumAlias)
	ENDSCAN
	dclose(l_cSumAlias)
ENDFOR
ENDPROC
*
PROCEDURE SpcUpdateCashDetails
LPARAMETERS lp_nUnitDiff, lp_nAmountDiff, lp_dDate, lp_nPaynum, lp_nCashier
LOCAL l_nPrice, l_cUserid, l_nUnits, l_nAmount, l_nPostid
IF SEEK(lp_nPaynum, "paymetho", "TAG1")
	l_nPrice = IIF(EMPTY(paymetho.pm_rate) OR paymetho.pm_paynum=1, 1, paymetho.pm_rate)
ELSE
	l_nPrice = 1
ENDIF
l_cUserid = "AUTOMATIC"
IF lp_dDate < Param.pa_sysdate
	SELECT HistPost
	LOCATE ALL FOR hp_date = lp_dDate AND hp_reserid = -2 AND hp_cashier = lp_nCashier AND hp_paynum = lp_nPaynum
	IF FOUND("HistPost")
		l_nUnits = HistPost.hp_units + lp_nUnitDiff
		IF ROUND(l_nUnits,2) = 0.00
			DELETE IN HistPost
		ELSE
			l_nAmount = HistPost.hp_amount + lp_nAmountDiff
			REPLACE hp_units WITH l_nUnits , ;
					hp_amount WITH l_nAmount IN HistPost
		ENDIF
	ELSE
		l_nPostid = Nextid('POST')
		INSERT INTO HistPost (hp_postid, hp_paynum, hp_units, hp_price,  ;
				hp_supplem, hp_reserid, hp_origid, hp_date, hp_time,  ;
				hp_amount, hp_userid, hp_cashier) ;
				VALUES (l_nPostid, lp_nPaynum, lp_nUnitDiff, l_nPrice, ;
				"CLOSE " + LTRIM(STR(lp_nCashier)), -2, -2, lp_dDate, TIME(), ;
				lp_nAmountDiff, l_cUserid, lp_nCashier)
	ENDIF
	IF Param.pa_noclose AND lp_dDate + 1 < Param.pa_sysdate ;
				AND NOT INLIST(lp_nPaynum, param.pa_payonld, param.pa_rndpay)
		LOCATE ALL FOR hp_date = lp_dDate + 1 AND hp_reserid = -1 AND hp_cashier = lp_nCashier AND hp_paynum = lp_nPaynum
		IF FOUND("HistPost")
			l_nUnits = HistPost.hp_units - lp_nUnitDiff
			IF ROUND(l_nUnits,2) = 0.00
				DELETE IN HistPost
			ELSE
				l_nAmount = HistPost.hp_amount - lp_nAmountDiff
				REPLACE hp_units WITH l_nUnits, ;
						hp_amount WITH l_nAmount IN HistPost
			ENDIF
		ELSE
			l_nPostid = Nextid('POST')
			INSERT INTO HistPost (hp_postid, hp_paynum, hp_units, hp_price,  ;
					hp_supplem, hp_reserid, hp_origid, hp_date, hp_time,  ;
					hp_amount, hp_userid, hp_cashier) ;
					VALUES (l_nPostid, lp_nPaynum, -lp_nUnitDiff, l_nPrice, ;
					"TRANSFER AUDIT #"+ LTRIM(STR(lp_nCashier)), -1, -1, lp_dDate + 1, TIME(), ;
					-lp_nAmountDiff, l_cUserid, lp_nCashier)
		ENDIF
	ENDIF
ENDIF
IF lp_dDate + 1 = Param.pa_sysdate
	SELECT Post
	LOCATE ALL FOR ps_date = lp_dDate AND ps_reserid = -2 AND ps_cashier = lp_nCashier AND ps_paynum = lp_nPaynum
	IF FOUND("Post")
		l_nUnits = Post.ps_units + lp_nUnitDiff
		IF ROUND(l_nUnits,2) = 0.00
			DELETE IN Post
		ELSE
			l_nAmount = Post.ps_amount + lp_nAmountDiff
			REPLACE ps_units WITH l_nUnits, ;
					ps_amount WITH l_nAmount IN Post
		ENDIF
	ELSE
		l_nPostid = Nextid('POST')
		INSERT INTO Post (ps_postid, ps_paynum, ps_units, ps_price,  ;
				ps_supplem, ps_reserid, ps_origid, ps_date, ps_time,  ;
				ps_amount, ps_userid, ps_cashier) ;
				VALUES (l_nPostid, lp_nPaynum, lp_nUnitDiff, l_nPrice, ;
				"CLOSE " + LTRIM(STR(lp_nCashier)), -2, -2, lp_dDate, TIME(), ;
				lp_nAmountDiff, l_cUserid, lp_nCashier)
	ENDIF
ENDIF
IF Param.pa_noclose AND lp_dDate >= Param.pa_sysdate - 2 ;
			AND NOT INLIST(lp_nPaynum, param.pa_payonld, param.pa_rndpay)
	SELECT Post
	LOCATE ALL FOR ps_date = lp_dDate + 1 AND ps_reserid = -1 AND ps_cashier = lp_nCashier AND ps_paynum = lp_nPaynum
	IF FOUND("Post")
		l_nUnits = Post.ps_units - lp_nUnitDiff
		IF ROUND(l_nUnits,2) = 0.00
			DELETE IN Post
		ELSE
			l_nAmount = Post.ps_amount - lp_nAmountDiff
			REPLACE ps_units WITH l_nUnits, ;
					ps_amount WITH l_nAmount IN Post
		ENDIF
	ELSE
		l_nPostid = Nextid('POST')
		INSERT INTO Post (ps_postid, ps_paynum, ps_units, ps_price,  ;
				ps_supplem, ps_reserid, ps_origid, ps_date, ps_time,  ;
				ps_amount, ps_userid, ps_cashier) ;
				VALUES (l_nPostid, lp_nPaynum, -lp_nUnitDiff, l_nPrice, ;
				"TRANSFER AUDIT #" + LTRIM(STR(lp_nCashier)), -1, -1, lp_dDate + 1, TIME(), ;
				-lp_nAmountDiff, l_cUserid, lp_nCashier)
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE IsPreBillAllowed
* Check if reservation can use prebill option
LPARAMETERS lp_cStatus
IF EMPTY(lp_cStatus)
	RETURN .F.
ENDIF 
RETURN INLIST(lp_cStatus, "DEF", "6PM", "ASG")
ENDPROC
*
PROCEDURE CalcOutDebts
LPARAMETERS lp_dDatum
LOCAL l_nSelect, l_nRecNo, l_oData, l_tCreated, l_cReserWhere, l_cIniFile, l_lAnotherWay, l_cAnotherWayFilter, l_cSql
LOCAL l_aSQLResult(1)
IF EMPTY(lp_dDatum)
	lp_dDatum = sysdate()
ENDIF

l_nSelect = SELECT()
l_nRecNo = RECNO()

IF NOT openfile(.F.,"outdebts",.F.,.T.)
	RETURN .F.
ENDIF

* check if records were added on this date

SELECT TOP 1 ou_ouid FROM outdebts WHERE ou_date = lp_dDatum ORDER BY 1 INTO ARRAY l_aSQLResult
IF TYPE("l_aSQLResult(1)") = "N"
	closefile("outdebts")
	RETURN .F.
ENDIF

l_tCreated = DATETIME()
l_cIniFile = FULLPATH(INI_FILE)
IF FILE(l_cIniFile)
	l_cAnotherWayFilter = readini(l_cIniFile, "audit","outdebtsfilter", "")
	l_lAnotherWay = IIF(EMPTY(l_cAnotherWayFilter),.F.,.T.)
ENDIF
IF l_lAnotherWay
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
		SELECT SUM(balance) AS c_sum ;
		FROM ;
			( ;
			SELECT Balance(rs_reserid,1,lp_dDatum) + ;
				Balance(rs_reserid,2,lp_dDatum) + ;
				Balance(rs_reserid,3,lp_dDatum) + ;
				Balance(rs_reserid,4,lp_dDatum) + ;
				Balance(rs_reserid,5,lp_dDatum) + ;
				Balance(rs_reserid,6,lp_dDatum) ;
				AS Balance ;
				FROM reservat ;
				WHERE <<l_cAnotherWayFilter>> AND EXISTS(SELECT 'x' FROM Post WHERE ps_reserid = rs_reserid) AND ;
				balance(rs_reserid, 1, lp_dDatum) + ;
				balance(rs_reserid, 2, lp_dDatum) + ;
				balance(rs_reserid, 3, lp_dDatum) + ;
				Balance(rs_reserid,4,lp_dDatum) + ;
				Balance(rs_reserid,5,lp_dDatum) + ;
				Balance(rs_reserid,6,lp_dDatum) <> 0 ;
			) c1 ;
			INTO CURSOR curx5109
	ENDTEXT
	l_cSql = STRTRAN(l_cSql, ";" ,"")
	&l_cSql
	SELECT outdebts
	SCATTER NAME l_oData BLANK
	l_oData.ou_ouid = nextid("outdebts")
	l_oData.ou_date = lp_dDatum
	l_oData.ou_artinum = 0
	l_oData.ou_amount = curx5109.c_sum
	l_oData.ou_created = l_tCreated
	INSERT INTO outdebts FROM NAME l_oData
	dclose("curx5109")
ELSE
	l_cReserWhere = "DTOS(rs_depdate)+rs_rmname >= " + sqlcnv(DTOS(lp_dDatum))
	SELECT rs_reserid, (Balance(rs_reserid,1,lp_dDatum) + ;
			Balance(rs_reserid,2,lp_dDatum) + ;
			Balance(rs_reserid,3,lp_dDatum) + ;
			Balance(rs_reserid,4,lp_dDatum) + Balance(rs_reserid,5,lp_dDatum) + ;
			Balance(rs_reserid,6,lp_dDatum)) AS ReserBalance ;
			FROM reservat ;
			WHERE &l_cReserWhere ;
			HAVING ReserBalance > 0 ;
			INTO CURSOR curOpenReservatBills
	SELECT lp_dDatum AS Date, CAST(ps_artinum AS Numeric (5)) AS artinum, SUM(ps_amount) AS amount, ;
			SUM(ps_vat1) AS vat1, SUM(ps_vat2) AS vat2, SUM(ps_vat3) AS vat3, ;
			SUM(ps_vat4) AS vat4, SUM(ps_vat5) AS vat5, SUM(ps_vat6) AS vat6, ;
			SUM(ps_vat7) AS vat7, SUM(ps_vat8) AS vat8, SUM(ps_vat9) AS vat9 ;
			FROM post ;
			INNER JOIN curOpenReservatBills ON rs_reserid = ps_reserid ;
			WHERE ps_date <= lp_dDatum AND ps_artinum > 0 AND INLIST(ps_window, 1, 2, 3, 4, 5, 6) AND ;
			(EMPTY(ps_ratecod) OR ps_split) AND NOT ps_cancel ;
			GROUP BY artinum ;
			UNION ;
			SELECT lp_dDatum AS Date, CAST(99999 AS Numeric (5)) AS artinum, SUM(ps_amount) AS amount, ;
			CAST(0 AS Double (6)) AS vat1, CAST(0 AS Double (6)) AS vat2, CAST(0 AS Double (6)) AS vat3,  ;
			CAST(0 AS Double (6)) AS vat4, CAST(0 AS Double (6)) AS vat5, CAST(0 AS Double (6)) AS vat6,  ;
			CAST(0 AS Double (6)) AS vat7, CAST(0 AS Double (6)) AS vat8, CAST(0 AS Double (6)) AS vat9  ;
			FROM post ;
			INNER JOIN curOpenReservatBills ON rs_reserid = ps_reserid ;
			WHERE ps_date <= lp_dDatum AND ps_paynum > 0 AND INLIST(ps_window, 1, 2, 3, 4, 5, 6) AND NOT ps_cancel ;
			GROUP BY artinum ;
			ORDER BY artinum ;
			INTO CURSOR curOutDebts
	SCAN ALL
		SELECT outdebts
		SCATTER NAME l_oData BLANK
		l_oData.ou_ouid = nextid("outdebts")
		l_oData.ou_date = lp_dDatum
		l_oData.ou_artinum = IIF(curOutDebts.artinum=99999,0,curOutDebts.artinum)
		l_oData.ou_amount = curOutDebts.amount
		l_oData.ou_vat1 = curOutDebts.vat1
		l_oData.ou_vat2 = curOutDebts.vat2
		l_oData.ou_vat3 = curOutDebts.vat3
		l_oData.ou_vat4 = curOutDebts.vat4
		l_oData.ou_vat5 = curOutDebts.vat5
		l_oData.ou_vat6 = curOutDebts.vat6
		l_oData.ou_vat7 = curOutDebts.vat7
		l_oData.ou_vat8 = curOutDebts.vat8
		l_oData.ou_vat9 = curOutDebts.vat9
		l_oData.ou_created = l_tCreated
		INSERT INTO outdebts FROM NAME l_oData
		SELECT curOutDebts
	ENDSCAN
	closefile("curOpenReservatBills")
	closefile("curOutDebts")
ENDIF
closefile("outdebts")
SELECT(l_nSelect)
IF NOT EMPTY(ALIAS())
	GO l_nRecNo
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE PBAdjustPrices
* When we are working with fiscal printer, we must adjust here
* prices posted in post.
LPARAMETERS lp_nReserId, lp_nWindow
LOCAL l_lAdjusted, l_cResCur

IF NOT param2.pa_corprbc
	RETURN l_lAdjusted
ENDIF
IF EMPTY(lp_nReserId) OR EMPTY(lp_nWindow)
	RETURN l_lAdjusted
ENDIF

LOCAL l_cPostCur, l_cSql, l_oOldPost, l_oNewPost, l_nSelect, ;
     l_nSetId, l_nMainArtiNum, l_nSumSplit, l_nMainAmount, l_cVatMacro, l_nVatAmount, ;
     l_cBillCur, l_lBillClosed

l_nSelect = SELECT()

* First check if bill is closed. Don't adjust prices on closed bills!
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT bn_status FROM billnum ;
     WHERE bn_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND bn_window = <<sqlcnv(lp_nWindow, .T.)>> ;
          AND bn_status = <<sqlcnv("PCO",.T.)>>
ENDTEXT
l_cBillCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
l_lBillClosed = (RECCOUNT(l_cBillCur)>0)
dclose(l_cBillCur)
IF l_lBillClosed
     SELECT (l_nSelect)
     RETURN l_lAdjusted
ENDIF

* Don't allow price adjust when rs_ratexch hast exchange rate.
l_cResCur = sqlcursor("SELECT rs_ratexch, rs_discnt FROM reservat WHERE rs_reserid = " + sqlcnv(lp_nReserId,.T.))
IF USED(l_cResCur) AND RECCOUNT(l_cResCur)>0 AND NOT EMPTY(&l_cResCur..rs_ratexch)
     dclose(l_cResCur)
     SELECT (l_nSelect)
     RETURN l_lAdjusted
ENDIF

* Check if for some posting price or vat is changed
IF _screen.oGlobal.lspecialfiscalprintermode

     * In this mode is not allowed to change prices for ratecode postings
     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT post.*, ar_price, ar_vat, pl_numval AS vatpct ;
          FROM post ;
          INNER JOIN article ON ps_artinum = ar_artinum ;
          INNER JOIN picklist ON pl_label = 'VATGROUP  ' AND pl_numcod = ar_vat ;
          WHERE ps_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND ;
               ps_window = <<sqlcnv(lp_nWindow,.T.)>> AND ;
               ps_artinum > 0 AND NOT ps_cancel AND ;
               EMPTY(ps_ratecod) AND ;
               ps_units>0 AND ;
               (ps_price <> ar_price OR ROUND(ps_amount * ( 1 - (100 / (100 + pl_numval))),4) <> ROUND(ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9,4)) ;
                AND ar_artityp = 1 AND ar_user2 <> "X" ;
          ORDER BY ps_postid, ps_postid
     ENDTEXT

ELSE

     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT DISTINCT ps_postid, ps_ratecod, post.ps_setid, ps_artinum, ps_split, ps_price, ps_units, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ar_price, ar_vat, pl_numval AS vatpct ;
          FROM post ;
          INNER JOIN article ON ps_artinum = ar_artinum ;
          INNER JOIN picklist ON pl_label = 'VATGROUP  ' AND pl_numcod = ar_vat ;
          WHERE ps_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND ;
               ps_window = <<sqlcnv(lp_nWindow,.T.)>> AND ;
               ps_artinum > 0 AND NOT ps_cancel AND ;
               EMPTY(ps_ratecod) AND ;
               ps_units>0 AND ;
               (ps_price <> ar_price OR ROUND(ps_amount * ( 1 - (100 / (100 + pl_numval))),4) <> ROUND(ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9,4)) ;
                AND ar_artityp = 1 AND ar_user2 <> "X" ;
     UNION ALL ;
     SELECT DISTINCT ps_postid, ps_ratecod, post.ps_setid, ps_artinum, ps_split, ps_price, ps_units, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ar_price, ar_vat, pl_numval AS vatpct ;
          FROM post ;
          INNER JOIN ( ;
                         SELECT ps_setid FROM post ;
                              INNER JOIN article ON ps_artinum = ar_artinum ;
                              INNER JOIN picklist p1 ON p1.pl_label = 'VATGROUP  ' AND p1.pl_numcod = ar_vat ;
                              INNER JOIN ratecode ON ps_ratecod = rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season AND rc_paynum = 0 ;
                              WHERE ps_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND ;
                                   ps_window = <<sqlcnv(lp_nWindow,.T.)>> AND ;
                                   ps_artinum > 0 AND NOT ps_cancel AND ;
                                   NOT EMPTY(ps_ratecod) AND ;
                                   ps_units>0 AND ;
                                   (ps_price <> ar_price OR ROUND(ps_amount * ( 1 - (100 / (100 + p1.pl_numval))),4) <> ROUND(ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9,4)) ;
                                   AND ar_artityp = 1 AND ar_user2 <> "X" ;
                              GROUP BY 1 ;
                     ) AS c1 ON post.ps_setid = c1.ps_setid ;
          INNER JOIN article ON ps_artinum = ar_artinum ;
          INNER JOIN picklist ON pl_label = 'VATGROUP  ' AND pl_numcod = ar_vat ;
     UNION ALL ;
     SELECT DISTINCT ps_postid, ps_ratecod, post.ps_setid, ps_artinum, ps_split, ps_price, ps_units, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ROUND(rs_rate * pm_rate,2) AS ar_price, ar_vat, pl_numval AS vatpct  ;
          FROM post  ;
          INNER JOIN ;
          (  SELECT ps_setid FROM post  ;
               INNER JOIN article ON ps_artinum = ar_artinum AND ar_artityp = 1 ;
               INNER JOIN picklist p1 ON p1.pl_label = 'VATGROUP  ' AND p1.pl_numcod = ar_vat  ;
               INNER JOIN ratecode ON ps_ratecod = rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season AND rc_paynum > 0  ;
               INNER JOIN reservat ON ps_origid = rs_reserid AND rs_rate > 0.00  ;
               INNER JOIN paymetho ON rc_paynum = pm_paynum AND pm_paynum > 0 AND pm_rate > 0.00  ;
               WHERE ps_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND ;
                    ps_window = <<sqlcnv(lp_nWindow,.T.)>> AND ;
                    ps_artinum > 0 AND NOT ps_cancel AND ;
                    NOT EMPTY(ps_ratecod) AND ps_units>0 AND  ps_price <> ROUND(rs_rate * pm_rate,2) ;
               GROUP BY 1  ;
           ) AS c1 ON post.ps_setid = c1.ps_setid  ;
           INNER JOIN article ON ps_artinum = ar_artinum AND ar_artityp = 1  ;
           INNER JOIN picklist ON pl_label = 'VATGROUP  ' AND pl_numcod = ar_vat  ;
           INNER JOIN reservat ON ps_origid = rs_reserid AND rs_rate > 0.00  ;
           INNER JOIN ratecode ON ps_ratecod = rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season AND rc_paynum > 0  ;
           INNER JOIN paymetho ON rc_paynum = pm_paynum AND pm_paynum > 0 AND pm_rate > 0.00  ;
     ORDER BY ps_postid
     ENDTEXT

ENDIF
l_cPostCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)

SELECT (l_cPostCur)
SCAN FOR EMPTY(ps_ratecod)
     SCATTER NAME l_oOldPost
     SCATTER NAME l_oNewPost
     l_oNewPost.ps_price = l_oNewPost.ar_price
     l_oNewPost.ps_amount = l_oNewPost.ps_price * l_oNewPost.ps_units
     l_cVatMacro = "ps_vat"+LTRIM(STR(ar_vat))
     l_nVatAmount = l_oNewPost.ps_amount * ( 1 - (100 / (100 + vatpct)))
     * Reset all vats for this record to 0
     sqlupdate("post", ;
               "ps_postid = " + sqlcnv(&l_cPostCur..ps_postid,.T.), ;
               "ps_vat1 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat2 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat3 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat4 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat5 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat6 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat7 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat8 = " + sqlcnv(0,.T.) + "," + ;
               "ps_vat9 = " + sqlcnv(0,.T.) ;
               )
     sqlupdate("post", ;
               "ps_postid = " + sqlcnv(&l_cPostCur..ps_postid,.T.), ;
               "ps_price = " + sqlcnv(&l_cPostCur..ar_price,.T.) + "," + ;
               "ps_amount = " + sqlcnv(&l_cPostCur..ar_price * &l_cPostCur..ps_units,.T.) + "," + ;
               l_cVatMacro + " = " + sqlcnv(l_nVatAmount,.T.) + "," + ;
               "ps_touched = " + sqlcnv(.T.,.T.) ;
               )
     PostHistory(l_oOldPost, l_oNewPost, "ADJUSTED")
     SELECT (l_cPostCur)
ENDSCAN
IF EMPTY(&l_cResCur..rs_discnt)
     STORE 0 TO ;
          l_nSetId, ;
          l_nMainArtiNum, ;
          l_nSumSplit, ;
          l_nMainAmount
     SELECT (l_cPostCur)
     SCAN FOR NOT EMPTY(ps_ratecod)
          IF l_nSetId <> ps_setid
               l_nSetId = ps_setid
               l_nMainArtiNum = ps_artinum
               l_nSumSplit = 0
               l_nMainAmount = ps_units * ar_price
          ENDIF
          IF ps_split AND ps_artinum <> l_nMainArtiNum
               l_nSumSplit = l_nSumSplit + (ps_units * ar_price)
          ENDIF
          SCATTER NAME l_oOldPost
          SCATTER NAME l_oNewPost
          
          IF ps_split AND ps_artinum = l_nMainArtiNum
               * adjust amount for main split article
               l_oNewPost.ps_amount = l_nMainAmount - l_nSumSplit
               l_oNewPost.ps_price = l_oNewPost.ps_amount / l_oNewPost.ps_units
          ELSE
               l_oNewPost.ps_price = ar_price
               l_oNewPost.ps_amount = ar_price * ps_units
          ENDIF
          l_cVatMacro = "ps_vat"+LTRIM(STR(ar_vat))
          l_nVatAmount = l_oNewPost.ps_amount * ( 1 - (100 / (100 + vatpct)))
          * Reset all vats for this record to 0
          sqlupdate("post", ;
                    "ps_postid = " + sqlcnv(&l_cPostCur..ps_postid,.T.), ;
                    "ps_vat1 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat2 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat3 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat4 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat5 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat6 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat7 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat8 = " + sqlcnv(0,.T.) + "," + ;
                    "ps_vat9 = " + sqlcnv(0,.T.) ;
                    )
          sqlupdate("post", ;
                    "ps_postid = " + sqlcnv(l_oNewPost.ps_postid,.T.), ;
                    "ps_price = " + sqlcnv(l_oNewPost.ps_price,.T.) + "," + ;
                    "ps_amount = " + sqlcnv(l_oNewPost.ps_amount,.T.) + "," + ;
                    l_cVatMacro + " = " + sqlcnv(l_nVatAmount,.T.) + "," + ;
                    "ps_touched = " + sqlcnv(.T.,.T.) ;
                    )
          PostHistory(l_oOldPost, l_oNewPost, "ADJUSTED")
          SELECT (l_cPostCur)
     ENDSCAN
ENDIF

FLUSH FORCE

dclose(l_cResCur)
dclose(l_cPostCur)

SELECT(l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ShowVatAmt
 LPARAMETER l_Exclamt, l_Buff, l_AmtAndVat, l_DontAddTotal, l_DontShowVat
 PRIVATE l_Vatnum, l_Vatpct, l_Vatnum2, l_Vatpct2, l_Vatamt
 PRIVATE l_Vattxt, l_Vattxt2, l_Size
 STORE 0 TO l_Vatnum, l_Vatpct, l_Vatnum2, l_Vatpct2
 STORE '' TO l_Vattxt, l_Vattxt2
 l_Size = 8
 l_Mainarti = dbLookup('RateArti','Tag1',raTecode.rc_ratecod+ ;
              raTecode.rc_roomtyp,'ra_artinum')
 l_Vatnum = dbLookup('Article','Tag1',l_Mainarti,'ar_vat',.T.)
 l_Vatpct = dbLookup('PickList','Tag3',PADR("VATGROUP", 10)+STR(l_Vatnum,  ;
            3),'PickList.pl_numval',.T.)
 l_Vatamt = l_Exclamt*(l_Vatpct/100)
 l_Vattxt = TRIM(EVALUATE('PickList.pl_lang'+g_Langnum))
 l_Vatnum2 = arTicle.ar_vat2
 l_Vatpct2 = dbLookup('PickList','Tag3',PADR("VATGROUP", 10)+ ;
             STR(l_Vatnum2, 3),'PickList.pl_numval',.T.)
 l_Vattxt2 = TRIM(EVALUATE('PickList.pl_lang'+g_Langnum))
 IF NOT l_DontShowVat
      l_Buff = l_Buff+TRANSFORM(l_Vatamt, RIGHT(gcCurrcy, 8))+' '+ ;
             PADR(l_Vattxt, 7)+CHR(13)+CHR(10)
 ENDIF
 l_Vat2amt = 0
 IF  .NOT. EMPTY(l_Vatnum2)
      l_Vat2amt = ROUND((l_Exclamt+IIF(paRam.pa_compvat, l_Vatamt, 0))* ;
                  (l_Vatpct2/100), 2)
      IF l_DontShowVat
           l_Buff = l_Buff+TRANSFORM(l_Vat2amt, RIGHT(gcCurrcy, 8))+' '+ ;
                    PADR(l_Vattxt2, 7)+CHR(13)+CHR(10)
      ENDIF
 ENDIF
 IF NOT l_DontAddTotal
      l_Buff = l_Buff+TRANSFORM(ROUND(l_Exclamt+l_Vatamt+l_Vat2amt, 2),  ;
                RIGHT(gcCurrcy, 8))+' '+PADR(GetLangText("WALKIN","T_TOTAL"), 7)
 ENDIF
 l_AmtAndVat = ROUND(l_Exclamt+l_Vatamt+l_Vat2amt, 2)
 RETURN
ENDPROC
*
PROCEDURE PBBillForecast
* Use it to get postings for one or more reservations in future, depending on ratecode and resrate
LPARAMETERS lp_nReserId, lp_cWhere, lp_cCurName
LOCAL l_oReservationBillForecast, l_cCurName, l_cWhere
LOCAL ARRAY laPreProc(1)

l_cCurName = ""

DO CASE
     CASE NOT EMPTY(lp_nReserId)
          l_cWhere = "rs_reserid = " + sqlcnv(lp_nReserId,.T.)
     CASE NOT EMPTY(lp_cWhere)
          l_cWhere = lp_cWhere
ENDCASE

IF NOT EMPTY(l_cWhere)
     l_oReservationBillForecast = CREATEOBJECT("cReservationBillForecast")
     l_oReservationBillForecast.cWhere = l_cWhere
     l_oReservationBillForecast.GetPostings(@laPreProc)
     IF NOT USED("post")
          openfiledirect(.F., "post")
     ENDIF
     l_cCurName = SYS(2015)
     SELECT * FROM post WHERE .F. INTO CURSOR (l_cCurName) READWRITE
     INSERT INTO (l_cCurName) FROM ARRAY laPreProc
ENDIF
lp_cCurName = l_cCurName
RETURN l_cCurName
ENDPROC
*
PROCEDURE PBGetVatGroup
LPARAMETERS lp_cAlias, lp_cFieldNamePrefix, lp_lReturnVatPercent
LOCAL l_nSelect, i, l_nVatNr, l_nRecNo, l_lRateCodeMain, l_cCur, l_cAlias, l_nRetVal, l_cSql
lp_cVatGroupDescipt = ""
IF EMPTY(lp_cAlias)
     lp_cAlias = ALIAS()
ENDIF
IF EMPTY(lp_cFieldNamePrefix)
     lp_cFieldNamePrefix = "ps_"
ENDIF
l_cAlias = lp_cAlias
IF lp_lReturnVatPercent
     l_nRetVal = 0.00
ELSE
     l_nRetVal = 0
ENDIF
IF EVALUATE(l_cAlias+"."+lp_cFieldNamePrefix+"artinum")>0
     l_nVatNr = 0
     l_nRecNo = RECNO(lp_cAlias)
     l_nSelect = SELECT()
     l_lRateCodeMain = IIF(NOT EMPTY(EVALUATE(l_cAlias+"."+lp_cFieldNamePrefix+"ratecod")) AND NOT EVALUATE(l_cAlias+"."+lp_cFieldNamePrefix+"split"),.T.,.F.)
     IF l_lRateCodeMain
          l_nSetId = EVALUATE(l_cAlias+"."+lp_cFieldNamePrefix+"setid")
          l_nMainArtinum = EVALUATE(l_cAlias+"."+lp_cFieldNamePrefix+"artinum")
          l_cSql = "SELECT "+;
               lp_cFieldNamePrefix+"vat1"+", "+;
               lp_cFieldNamePrefix+"vat2"+", "+;
               lp_cFieldNamePrefix+"vat3"+", "+;
               lp_cFieldNamePrefix+"vat4"+", "+;
               lp_cFieldNamePrefix+"vat5"+", "+;
               lp_cFieldNamePrefix+"vat6"+", "+;
               lp_cFieldNamePrefix+"vat7"+", "+;
               lp_cFieldNamePrefix+"vat8"+", "+;
               lp_cFieldNamePrefix+"vat9"+;
               " FROM " + l_cAlias + ;
               " WHERE " + lp_cFieldNamePrefix + "setid = " + TRANSFORM(l_nSetId) + " AND " + lp_cFieldNamePrefix + "split"
          l_cCur = sqlcursor(l_cSql)
          IF RECCOUNT()>0
               l_cAlias = l_cCur
          ELSE
               SELECT &l_cAlias
          ENDIF
     ENDIF
     FOR i = 1 TO 9
          l_nVatAmt = EVALUATE(l_cAlias+"."+lp_cFieldNamePrefix+"vat"+TRANSFORM(i))
          IF NOT EMPTY(l_nVatAmt)
               l_nVatNr = i
               EXIT
          ENDIF
     ENDFOR
     IF RECNO(lp_cAlias)<>l_nRecNo
          GO l_nRecNo IN (lp_cAlias)
     ENDIF
     IF NOT EMPTY(l_cCur)
          dclose(l_cCur)
     ENDIF
     IF lp_lReturnVatPercent
          l_nRetVal = PBGetVATPercent(lp_cAlias, lp_cFieldNamePrefix, l_nVatNr)
     ELSE
          l_nRetVal = l_nVatNr
     ENDIF
     SELECT (l_nSelect)
ENDIF
RETURN l_nRetVal
ENDPROC
*
PROCEDURE PBGetVATPercent
LPARAMETERS lp_cAlias, lp_cFieldNamePrefix, lp_nVatNr
LOCAL l_nAmount, l_nVat, l_nVatPercent

IF lp_nVatNr = 0
     l_nVatPercent = 0.00
ELSE
     l_nAmount = EVALUATE(lp_cAlias+"."+lp_cFieldNamePrefix+"amount")
     l_nVat = EVALUATE(lp_cAlias+"."+lp_cFieldNamePrefix+"vat"+TRANSFORM(lp_nVatNr))

     l_nVatPercent = ROUND((100*l_nVat)/(l_nAmount-IIF(_screen.oglobal.oparam.pa_exclvat,0,l_nVat)),2)
ENDIF
RETURN l_nVatPercent
ENDPROC
*
PROCEDURE PBCashierListPrintBill
LPARAMETERS lp_cTitle, lp_cCurPrintPost
* Used from cashierlist.scx and from pbpayelpay procedure, to print cashi in/out bill (quittung)
LOCAL l_nArea, l_cFrx
PRIVATE g_Rptlngnr, g_Rptlng, g_cTitle
IF USED(lp_cCurPrintPost)
     IF (RECCOUNT(lp_cCurPrintPost) > 0) AND FILE(gcReportdir+"_cashchn.frx") ;
                    AND yeSno(GetLangText("COMMON", "TXT_RECPRINT"))
          l_nArea = SELECT()
          g_Rptlngnr = g_Langnum
          g_Rptlng = g_Language
          g_cTitle = lp_cTitle
          l_cFrx = gcReportdir+"_cashchn.FRX"
          l_Langdbf = STRTRAN(UPPER(l_cFrx), '.FRX', '.DBF')
          IF FILE(l_Langdbf)
               USE SHARED NOUPDATE (l_Langdbf) ALIAS rePtext IN 0
          ENDIF
          SELECT (lp_cCurPrintPost)
          REPORT FORM (l_cFrx) TO PRINTER PROMPT NOCONSOLE
          = dclose('RepText')
          DO seTstatus IN Setup
          SELECT (l_nArea)
     ENDIF
     = closefile(lp_cCurPrintPost)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE PBOnAPIAction

* Should be used to get bill data as JSON for deskapi.
* Add here additional functions.
* Example:
*{"action":"procbill_get_bills","param1":2155}

LPARAMETERS lp_cJSON
LOCAL l_cCmd, l_oJSON

JSONStart()

l_oJSON = JSON.Parse(lp_cJSON)
IF TYPE("l_oJSON.debug") = "L" AND l_oJSON.debug
	l_cCmd = "PBOnAPIExecScript(l_oJSON)"
ELSE
	l_cCmd = l_oJSON.action + "(l_oJSON)"
ENDIF
RETURN &l_cCmd
ENDPROC
*
PROCEDURE PBOnAPIExecScript

* Use it from deskapi, when developing, to call prg file with EXECSCRIPT.
* So it is possible to change code in prg file, without need to compile exe.

LPARAMETERS lp_oJSON
LOCAL l_cPrgFile
l_cPrgFile = lp_oJSON.action + ".prg"
RETURN EXECSCRIPT(FILETOSTR(l_cPrgFile),lp_oJSON)
ENDPROC
*
PROCEDURE PBInsertPayment
LPARAMETERS lp_nReserId, lp_nWindow, lp_nPayNum, lp_nNextId, lp_nAmount, lp_cSupplem
LOCAL l_nSelect, l_oData

IF EMPTY(lp_nReserId)
	RETURN .F.
ENDIF

IF VARTYPE(lp_nWindow)<>"N"
	RETURN .F.
ENDIF

IF EMPTY(lp_nPayNum)
	RETURN .F.
ENDIF

IF VARTYPE(lp_nAmount)<>"N"
	RETURN .F.
ENDIF

IF EMPTY(lp_nNextId)
	lp_nNextId = nextid("POST")
ENDIF

IF VARTYPE(lp_cSupplem)<>"C"
	lp_cSupplem = ""
ENDIF

l_nSelect = SELECT()

SELECT post
SCATTER NAME l_oData BLANK

l_oData.ps_origid = lp_nReserId
l_oData.ps_reserid = l_oData.ps_origid
l_oData.ps_window = lp_nWindow
l_oData.ps_userid = g_userid
l_oData.ps_cashier = g_cashier
l_oData.ps_postid = lp_nNextId
l_oData.ps_date = sysdate()
l_oData.ps_amount = lp_nAmount
l_oData.ps_units = -1 * l_oData.ps_amount
l_oData.ps_price = 1
l_oData.ps_paynum = lp_nPayNum
l_oData.ps_supplem = lp_cSupplem
l_oData.ps_time = TIME()

INSERT INTO post FROM NAME l_oData

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
DEFINE CLASS cReservationBillForecast AS Session
*
cWhere = ""
*
PROCEDURE Init
ini(.T.)

openfiledirect(.F., "reservat")
openfiledirect(.F., "post")
openfiledirect(.F., "roomtype")
openfiledirect(.F., "rtypedef")
openfiledirect(.F., "althead")
openfiledirect(.F., "altsplit")
openfiledirect(.F., "evint")
openfiledirect(.F., "events")
openfiledirect(.F., "address")
openfiledirect(.F., "apartner")
openfiledirect(.F., "picklist")
openfiledirect(.F., "ratearti")
SET ORDER TO TAG1 IN ratearti
openfiledirect(.F., "resrart")
SET ORDER TO TAG1 IN resrart
openfiledirect(.F., "article")
SET ORDER TO TAG1 IN article
openfiledirect(.F., "building")
openfiledirect(.F., "postchng")
openfiledirect(.F., "resfix")
openfiledirect(.F., "resrate")
openfiledirect(.F., "resrooms")
openfiledirect(.F., "ratecode")
SELECT ratecode
SET ORDER TO TAG1
openfiledirect(.F., "paymetho")
SELECT paymetho
SET ORDER TO TAG1
RETURN .T.
ENDPROC

PROCEDURE GetPostings
LPARAMETERS taPreProc
LOCAL l_cWhere, i
l_cWhere = this.cWhere

sqlcursor("SELECT * FROM reservat WHERE " + l_cWhere + " ORDER BY rs_reserid", "curreservat")

* fake Reservat
lcReserTemp = Filetemp('DBF')
SELECT reservat
COPY TO (lcReserTemp) STRUCTURE WITH CDX
USE IN reservat
USE EXCLUSIVE (lcReserTemp) ALIAS reservat IN 0

* fake Post
lcPostTemp = Filetemp('DBF')
SELECT post
COPY TO (lcPostTemp) STRUCTURE WITH CDX
USE IN post
USE EXCLUSIVE (lcPostTemp) ALIAS post IN 0
ALTER TABLE post ADD COLUMN resaddr N(8) ADD COLUMN resrooms N(3)

* fake Postchng
lcPostchngTemp = Filetemp('DBF')
SELECT postchng
COPY TO (lcPostchngTemp) STRUCTURE WITH CDX
USE IN postchng
USE EXCLUSIVE (lcPostchngTemp) ALIAS postchng IN 0

* fake Id
lcIdTemp = Filetemp('DBF')
SELECT id
COPY TO (lcIdTemp) STRUCTURE WITH CDX
USE IN id
USE EXCLUSIVE (lcIdTemp) ALIAS id IN 0

* fake Param
lcParamTemp = Filetemp('DBF')
SELECT param
COPY TO (lcParamTemp)
USE IN param
USE EXCLUSIVE (lcParamTemp) ALIAS param IN 0

g_lFakeResAndPost = .T.

SELECT reservat
APPEND FROM DBF("curreservat")

* Fill postings from resrate and resfix
SELECT curreservat
SCAN FOR SEEK(curreservat.rs_reserid, "reservat", "tag1")
     FOR i = 1 TO reservat.rs_rooms
          SELECT reservat
          REPLACE rs_ratedat WITH {}
          DO RateCodePost IN RatePost WITH reservat.rs_depdate, "",,, .T.
     ENDFOR
ENDSCAN

g_lFakeResAndPost = .F.

SELECT * FROM post WHERE .F. INTO CURSOR curpost READWRITE
APPEND FROM DBF("post")

USE IN reservat
FileDelete(lcReserTemp)
FileDelete(STRTRAN(lcReserTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcReserTemp, '.DBF', '.FPT'))
USE IN post
FileDelete(lcPostTemp)
FileDelete(STRTRAN(lcPostTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcPostTemp, '.DBF', '.FPT'))
USE IN postchng
FileDelete(lcPostchngTemp)
FileDelete(STRTRAN(lcPostchngTemp, '.DBF', '.CDX'))
USE IN id
FileDelete(lcIdTemp)
USE IN param
FileDelete(lcParamTemp)

openfiledirect(.F., "param")
SysDate()

SELECT * FROM curpost INTO ARRAY taPreProc
RETURN .T.
ENDPROC

ENDDEFINE