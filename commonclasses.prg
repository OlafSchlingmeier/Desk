*
#INCLUDE "include\constdefines.h"
#INCLUDE "common\ffc\foxpro_reporting.h"
#INCLUDE "include\excel.h"
#INCLUDE "include\registry.h"
*
PROCEDURE CheckExeVersion
LPARAMETERS tcVersion, tlVersionOK
LOCAL lcVersion, lcExeVersion

lcExeVersion = FormatVersion(GetFileVersion("citadel.exe"))
lcVersion = FormatVersion(tcVersion)

tlVersionOK = (lcExeVersion >= lcVersion)
IF NOT tlVersionOK
	MESSAGEBOX("You must update version of main program!",48,"citadel.exe",6000)
ENDIF

RETURN tlVersionOK
ENDPROC
*
PROCEDURE SetTransactObject
PUBLIC g_oTransaction

IF VARTYPE(g_oTransaction) # "O"
	g_oTransaction = CREATEOBJECT("TransactObject")
	g_oTransaction.cLogErrorProc = "ErrorMsg(tcMessage)"
ENDIF
ENDPROC
*
PROCEDURE BeginTransaction
LOCAL l_oTransaction

IF Odbc()
	IF TYPE("plInTransaction") = "L" AND NOT plInTransaction
		plInTransaction = .T.
		Sql("BEGIN;")	&&BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE
	ENDIF
	RETURN .T.
ENDIF

IF VARTYPE(g_oTransaction) == "O"
	IF USED("curChangeRes") AND CURSORGETPROP("Buffering", "curChangeRes") # 5
		l_oTransaction = g_oTransaction.GetTransaction(SET("Datasession"))
		IF ISNULL(l_oTransaction)
			CURSORSETPROP("Buffering", 5, "curChangeRes")
		ENDIF
	ENDIF
	g_oTransaction.BeginTransaction(SET("Datasession"))
ENDIF
ENDPROC
*
FUNCTION EndTransaction
LPARAMETERS lp_lSilent

IF Odbc()
	IF TYPE("plInTransaction") = "L"
		IF NOT Sql("COMMIT;")	&&END TRANSACTION
			Sql("ROLLBACK;")
		ENDIF
		plInTransaction = .F.
		RELEASE plInTransaction
	ENDIF
	RETURN .T.
ENDIF

LOCAL l_lSuccess

IF VARTYPE(g_oTransaction) == "O"
	l_lSuccess = g_oTransaction.EndTransaction(SET("Datasession"))
	IF l_lSuccess
		DBTableFlushForce()
	ENDIF
ELSE
	l_lSuccess = .T.
ENDIF

IF USED("curChangeRes") AND CURSORGETPROP("Buffering", "curChangeRes") # 1
	DoTableRevert(.T., "curChangeRes")
	IF l_lSuccess
		USE IN curChangeRes
	ELSE
		CURSORSETPROP("Buffering", 1, "curChangeRes")
	ENDIF
ENDIF

IF NOT l_lSuccess AND NOT lp_lSilent
	Alert(GetLangText("RESERVAT","TA_SAVE_FAILED"))
ENDIF

RETURN l_lSuccess
ENDFUNC
*
FUNCTION TransactionIsOK
IF odbc()
	RETURN .T.
ENDIF
LOCAL l_lTranActive, l_lStatus

IF VARTYPE(g_oTransaction) == "O"
	l_lTranActive = g_oTransaction.GetStatus(SET("Datasession"), "TranActive")
	l_lStatus = g_oTransaction.GetStatus(SET("Datasession"), "Status")
ENDIF

RETURN NOT l_lTranActive OR l_lStatus
ENDFUNC
*
PROCEDURE DoTableUpdate
LPARAMETERS lp_nRows, lp_lForce, lp_cTableAlias, lp_lNoTransaction, lp_lUseCA, lp_lExternalODBC
LOCAL l_oTransaction, l_lDoTableUpdate, l_cFldState, l_lSuccess, l_oCursorAdapter, l_oException AS Exception

* Check if there changes in buffered alias.
DO CASE
	CASE NOT USED(lp_cTableAlias) OR CURSORGETPROP("Buffering", lp_cTableAlias) < 2
	CASE NOT EMPTY(lp_nRows) AND CURSORGETPROP("Buffering", lp_cTableAlias) > 3
		l_lDoTableUpdate = NOT EMPTY(GETNEXTMODIFIED(0,lp_cTableAlias))
	CASE NOT EOF(lp_cTableAlias)
		l_cFldState = GETFLDSTATE(-1,lp_cTableAlias)
		l_lDoTableUpdate = NOT CHRTRAN(l_cFldState,"234","") == l_cFldState
	OTHERWISE
ENDCASE

* If alias is attached CA alias and explicitly wants to TABLEUPDATE throw CA (if updating more then ONE table with CA).
DO CASE
	CASE NOT l_lDoTableUpdate
		l_lSuccess = .T.
	CASE lp_lUseCA
		l_oCursorAdapter = .NULL.
		TRY
			l_oCursorAdapter = GETCURSORADAPTER(lp_cTableAlias)
		CATCH TO l_oException
		ENDTRY
		IF NOT ISNULL(l_oCursorAdapter)
			l_lDoTableUpdate = .F.
			l_lSuccess = l_oCursorAdapter.DoTableUpdate(lp_nRows, .T., lp_lNoTransaction)
		ENDIF
	OTHERWISE
ENDCASE

DO CASE
	CASE NOT l_lDoTableUpdate
	CASE Odbc() OR lp_lExternalODBC OR lp_lNoTransaction OR VARTYPE(g_oTransaction) <> "O"
		l_lSuccess = TABLEUPDATE(lp_nRows, lp_lForce, lp_cTableAlias)
	OTHERWISE
		BeginTransaction()	&& Open new transaction if not opened yet.
		l_oTransaction = g_oTransaction.GetTransaction(SET("Datasession"))
		IF l_oTransaction.lStatus
			l_oTransaction.lStatus = g_oTransaction.TableUpdate(SET("Datasession"), lp_nRows, lp_lForce, lp_cTableAlias)
		ENDIF
		l_lSuccess = l_oTransaction.lStatus
		IF LOWER(lp_cTableAlias) = "availab"
			l_oTransaction.cAfterGoodSaveProc = "CCOnCitwebSync()"
		ENDIF
ENDCASE

RETURN l_lSuccess
ENDPROC
*
PROCEDURE DoTableRevert
LPARAMETERS lp_lAllRows, lp_cTableAlias

IF VARTYPE(g_oTransaction) == "O"
	g_oTransaction.TableRevert(SET("Datasession"), lp_lAllRows, lp_cTableAlias)
ENDIF
ENDPROC
*
PROCEDURE DbTableUpdate
LPARAMETERS lp_cTableName, lp_cForClause
LOCAL l_cDelete

IF NOT EMPTY(lp_cTableName) AND USED(lp_cTableName) AND CURSORGETPROP("Buffering", lp_cTableName) = 5
	l_cDelete = SET("Deleted")
	SET DELETED OFF
	SELECT &lp_cTableName
	SCAN FOR &lp_cForClause AND TransactionIsOK()
		DoTableUpdate(.F., .T., lp_cTableName)
	ENDSCAN
	SET DELETED &l_cDelete
ENDIF
ENDPROC
*
PROCEDURE DbTableRevert
LPARAMETERS lp_cTableName, lp_cForClause
LOCAL l_cDelete

IF NOT EMPTY(lp_cTableName) AND USED(lp_cTableName) AND CURSORGETPROP("Buffering", lp_cTableName) = 5
	l_cDelete = SET("Deleted")
	SET DELETED OFF
	SELECT &lp_cTableName
	SCAN FOR &lp_cForClause
		DoTableRevert(.F., lp_cTableName)
	ENDSCAN
	SET DELETED &l_cDelete
ENDIF
ENDPROC
*
PROCEDURE DBTableFlushForce
IF _screen.oGlobal.lflushforce
	FLUSH FORCE
ENDIF
ENDPROC
*
PROCEDURE QueryHotData
LPARAMETERS tcSqlSelect, tcHotCode, tcCurName
* In tcSqlSelect source table put in format _#<tablename>#_. For example _#RESERVAT#_.
LOCAL llSuccess, lcTablePath, lcPath, loTables, lcSqlSelect, lcSql, lnTable, lnPos, lcTable, lcAlias, l_cCur, l_lRemoteConnection, l_oDatabaseProp

llSuccess = .T.
lnArea = SELECT()

IF EMPTY(tcHotCode)
	tcHotCode = _screen.oGlobal.oParam2.pa_hotcode
ENDIF
l_lRemoteConnection = .F.
IF _screen.oGlobal.lUseMainServer

	l_cCur = sqlcursor("SELECT ho_path, ho_mainsrv FROM __#SRV.HOTEL#__ WHERE ho_hotcode = " + SqlCnv(tcHotCode,.T.))
	IF USED(l_cCur)
		lcTablePath = &l_cCur..ho_path
		l_oDatabaseProp = IIF(&l_cCur..ho_mainsrv,goDatabases.Item("SRV"),goDatabases.Item(ALLTRIM(tcHotCode)))
		IF TYPE("l_oDatabaseProp.nserverport")="N" AND NOT EMPTY(l_oDatabaseProp.nserverport)
			l_lRemoteConnection = .T.
		ENDIF

		lcTablePath = ADDBS(LOWER(ALLTRIM(lcTablePath)))
	endif
ELSE
	tcHotCode = "HOT"
	lcTablePath = ""
ENDIF

lcSql = tcSqlSelect
lcSqlSelect = tcSqlSelect

IF l_lRemoteConnection
	lcTable = STREXTRACT(lcSql,"#","#_")
	lcAlias = "__#"+ALLTRIM(tcHotCode)+"."+lcTable+"#__"
	lcSqlSelect = STRTRAN(lcSqlSelect,"_#"+lcTable+"#_", lcAlias)
	tcCurName = SqlCursor(lcSqlSelect,tcCurName)
ELSE
	loTables = CREATEOBJECT("Collection")
	FOR lnTable = 1 TO OCCURS("_#",lcSql)
		lnPos = AT("_#",lcSql)
		lcSql = STUFF(lcSql,1,lnPos,"")
		lcTable = STREXTRACT(lcSql,"#","#_")
		IF Odbc()
			lcPath = IIF(EMPTY(lcTablePath), "", STUFF(lcTablePath, LEN(lcTablePath), 1, "."))
			lcAlias = LOWER(lcPath+lcTable)
		ELSE
			IF UPPER(ALLTRIM(tcHotCode)) == UPPER(ALLTRIM(_screen.oGlobal.oParam2.pa_hotcode))
				lcAlias = LOWER(ALLTRIM(tcHotCode)+lcTable)
				OpenFileDirect(, lcTable, lcAlias)
			ELSE
				lcAlias = LOWER(ALLTRIM(tcHotCode)+lcTable)
				lcPath = IIF(EMPTY(lcTablePath), "", FNGetMPDataPath(lcTablePath))
				IF NOT OpenFileDirect(, lcTable, lcAlias, lcPath)
					llSuccess = .F.
					EXIT
				ENDIF
			ENDIF
			loTables.Add(lcAlias,lcTable)
		ENDIF
		lcSqlSelect = STRTRAN(lcSqlSelect,"_#"+lcTable+"#_", lcAlias)
	NEXT
	IF llSuccess
		tcCurName = SqlCursor(lcSqlSelect,tcCurName)
	ENDIF
	FOR EACH lcAlias IN loTables
		DClose(lcAlias)
	NEXT
ENDIF

SELECT(lnArea)

RETURN tcCurName
ENDPROC
*
PROCEDURE SortPopup
LPARAMETERS tnCurrentDirection
LOCAL lcDirection, lnBar

lnBar = 0
DEFINE POPUP popSort FROM MROW(), MCOL() RELATIVE SHORTCUT
DEFINE BAR 1 OF popSort PROMPT GetLangText("COMMON","TXT_SORT_ASCENDING")
DEFINE BAR 2 OF popSort PROMPT GetLangText("COMMON","TXT_SORT_DECENDING")
IF INLIST(tnCurrentDirection, 1, 2)
	SET MARK OF BAR tnCurrentDirection OF popSort TO .T.
ENDIF
ON SELECTION POPUP popSort lnBar = BAR()
ACTIVATE POPUP popSort
RELEASE POPUPS popSort

DO CASE
	CASE INLIST(lnBar, 0, tnCurrentDirection)
		lcDirection = ""
	CASE lnBar = 1
		lcDirection = "ASCENDING"
	OTHERWISE
		lcDirection = "DESCENDING"
ENDCASE

RETURN lcDirection
ENDPROC
*
PROCEDURE CCOnCitwebSync

	* Send file to citweb data folder, to signal some changes in desk database.
	* Posible types:
	* avl - Availibility change (empty parameter works too)
	* all - Send all
	
	LPARAMETERS lp_cMode
	IF NOT _screen.oGlobal.oParam2.pa_cwsync
		RETURN .T.
	ENDIF
	LOCAL l_cDir
	l_cDir = ALLTRIM(_screen.oGlobal.oParam2.pa_ciwebdr)
	IF NOT EMPTY(l_cDir) AND DIRECTORY(l_cDir)
		IF EMPTY(lp_cMode)
			lp_cMode = IIF(_screen.APS AND _screen.oGlobal.oParam2.pa_cwrauto, "all", "avl")
		ENDIF
		l_cFile = ADDBS(l_cDir)+"desk_sync." + LOWER(ALLTRIM(lp_cMode))
		STRTOFILE(TRANSFORM(DATETIME())+"|"+winpc(),l_cFile,1)
	ENDIF
	RETURN .T.
ENDPROC
*
DEFINE CLASS privatesession AS Session
	DataSession = 2

	PROCEDURE init
		DO ini
	ENDPROC

	PROCEDURE CheckData
	ENDPROC

	PROCEDURE OpenData
	ENDPROC

	PROCEDURE CloseData
	ENDPROC

	PROCEDURE FakeParam
		CREATE CURSOR param FROM ARRAY _screen.oGlobal.aParamFields
		INSERT INTO param FROM NAME _screen.oGlobal.oParam
	ENDPROC

	PROCEDURE CallProc
		LPARAMETERS tcCallProc, tuParam1, tuParam2, tuParam3, tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10, tuParam11, tuParam12, tuParam13, tuParam14, tuParam15
		LOCAL luRetVal

		this.CheckData()
		luRetVal = &tcCallProc

		RETURN luRetVal
	ENDPROC

	PROCEDURE CallScript
		LPARAMETERS tcCallScript, tuParam1, tuParam2, tuParam3, tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10
		LOCAL i, luRetVal, lcParams

		this.CheckData()
		lcParams = "tcCallScript"
		FOR i = 1 TO PCOUNT()-1
			lcParams = lcParams + ", @tuParam" + TRANSFORM(i)
		NEXT

		luRetVal = EXECSCRIPT(&lcParams)

		RETURN luRetVal
	ENDPROC

	PROCEDURE get_room
		LPARAMETERS tcWhere, tcFormat, tcIndex

		RETURN get_room(tcWhere, tcFormat, tcIndex)
	ENDPROC

	PROCEDURE get_roomtype
		LPARAMETERS tcWhere, tcFormat, tcIndex

		RETURN get_roomtype(tcWhere, tcFormat, tcIndex)
	ENDPROC

	PROCEDURE get_room_count
		LPARAMETERS tcWhere

		RETURN get_room_count(tcWhere)
	ENDPROC
ENDDEFINE
*
FUNCTION SetEnvironment
LPARAMETERS tcAliases, tcOrders
RETURN CREATEOBJECT("SetEnvironmentForDesk", tcAliases, tcOrders)
ENDFUNC
*
DEFINE CLASS SetEnvironmentForDesk AS SetEnvironment
	nExtraPropertyCount = 2
	DIMENSION aWatchProperty(2)
	aWatchProperty(1) = "cFilterClause"
	aWatchProperty(2) = "cForClause"

	PROCEDURE OpenTable
		LPARAMETERS tcAlias
		DOpen(tcAlias)
	ENDPROC
	*
	PROCEDURE GetWatchProperty
		LPARAMETERS tcAlias, tcProperty
		LOCAL lcExpression, loCursorAdapter

		IF Odbc()
			loCursorAdapter = .NULL.
			TRY
				loCursorAdapter = GETCURSORADAPTER(tcAlias)
			CATCH
			ENDTRY
			IF NOT ISNULL(loCursorAdapter)
				DO CASE
					CASE tcProperty = "cFilterClause"
						lcExpression = loCursorAdapter.cFilterClause
					CASE tcProperty = "cForClause"
						lcExpression = loCursorAdapter.MakeForClause()
						SELECT &tcAlias
						lcExpression = lcExpression + StrToSql("=%u1", &lcExpression)
					OTHERWISE
				ENDCASE
			ENDIF
		ENDIF

		RETURN lcExpression
	ENDPROC
	*
	PROCEDURE SetWatchProperty
		LPARAMETERS tcAlias, tcProperty, luValue

		DO CASE
			CASE VARTYPE(luValue) <> "C"
			CASE tcProperty = "cFilterClause"
				IF luValue <> this.GetWatchProperty(tcAlias, tcProperty)
					CursorQuery(tcAlias, luValue)
				ENDIF
			CASE tcProperty = "cForClause"
				SET ORDER TO "" IN &tcAlias
				DLocate(tcAlias, luValue)
			OTHERWISE
		ENDCASE
	ENDPROC
ENDDEFINE
*
DEFINE CLASS WindowsEvents AS Custom
	#include "include\constdefines.h"
	DIMENSION aMyLists(7)
	* aMyLists(1) - document name
	* aMyLists(2) - address id
	* aMyLists(3) - unbind after finish
	* aMyLists(4) - .T. = bound, .F. = unbound
	* aMyLists(5) - description text for subject in guest language
	* aMyLists(6) - report ID (lists.li_liid)
	* aMyLists(7) - rs_reserid
	
	nOldProc = 0
	nMenuBarRef = 100
	oSendEmailFormTmr = .NULL.

	FUNCTION Init
		this.DeclareApi()
		this.nOldProc = GetWindowLong(_screen.hWnd, GWL_WNDPROC)
		RETURN .T.
	ENDFUNC
	
	FUNCTION DeclareApi
		* Declared in main.prg!
		
		*DECLARE integer GetWindowLong IN Win32API ;
		*	integer hWnd, integer nIndex
		*DECLARE integer CallWindowProc IN Win32API ;
		*	integer lpPrevWndFunc, integer hWnd, integer Msg, integer wParam, ;
		*	integer lParam
	ENDFUNC

	FUNCTION CallSendEmailForm
		LPARAMETERS lp_nAddressID, lp_nReserId, l_aDocumentsToSend
		EXTERNAL ARRAY l_aDocumentsToSend

		IF VARTYPE(this.oSendEmailFormTmr) <> "O"
			this.oSendEmailFormTmr = CREATEOBJECT("cSendEmailFormTmr", lp_nAddressID, lp_nReserId, @l_aDocumentsToSend)
		ENDIF
		IF this.oSendEmailFormTmr.nStep = 0 AND NOT this.oSendEmailFormTmr.Enabled
			this.oSendEmailFormTmr.Enabled = .T.
		ENDIF
		RETURN .T.
	ENDFUNC

	FUNCTION BindEvents
		LPARAMETERS lp_nWinHandl, lp_nMessage, lp_nMode, lp_lUnbindAfterFinish
		LOCAL l_nRetVal
		DO CASE
			CASE lp_nMode = LETTERS
				this.aMyLists(3) = lp_lUnbindAfterFinish
				this.aMyLists(4) = .T.
				BINDEVENT(lp_nWinHandl, lp_nMessage, this, "MyListHandler")
			CASE lp_nMode = WINDOW_LIST_MENU
				this.aMyLists(4) = .T.
				BINDEVENT(lp_nWinHandl, lp_nMessage, this, "WindowListMenuHandler")
			OTHERWISE
				RETURN .F.
		ENDCASE
		RETURN .T.
	ENDFUNC
	
	FUNCTION UnBindEvent
		LPARAMETERS lp_nWinHandl, lp_nMessage
* all events will be unbound if only lp_nWinHandl was parameter passed and with value of 0
		IF PCOUNT() = 2
			UNBINDEVENTS(lp_nWinHandl, lp_nMessage)
			IF VARTYPE(this.oSendEmailFormTmr)= "O"
				this.oSendEmailFormTmr.Release()
				this.oSendEmailFormTmr = .NULL.
			ENDIF
		ELSE
			UNBINDEVENTS(lp_nWinHandl)
		ENDIF
	ENDFUNC
	
	FUNCTION MyListHandler
		LPARAMETERS hWnd as Integer, Msg as Integer, wParam as Integer, lParam as Integer
		IF Msg = WM_ACTIVATE AND wParam = WA_ACTIVE
			DO SendLetterAutomatic IN procemail WITH this.aMyLists(1), this.aMyLists(2), this.aMyLists(7)
		ENDIF
		RETURN CallWindowProc(this.nOldProc, hWnd, Msg, wParam, lParam)
	ENDFUNC
	*
	FUNCTION WindowListMenuHandler
		LPARAMETERS hWnd as Integer, Msg as Integer, wParam as Integer, lParam as Integer
		LOCAL l_nBar, l_nForm, l_nMenubarRef, l_oItem, l_nIndex, l_oFormList, l_nShortcut
		IF this.SysmenuPadExist("PWINDOW")
			l_oFormList = CREATEOBJECT("collection")
			FOR EACH l_oForm AS Form IN _screen.Forms
				IF LOWER(l_oForm.BaseClass) <> "toolbar" AND NOT EMPTY(l_oForm.Caption) AND l_oForm.Visible AND l_oForm.TitleBar = 1
					IF NOT PEMSTATUS(l_oForm, "nmenubarrefx1950",5)
						l_oForm.AddProperty("nmenubarrefx1950",this.GetMenuBarRef())
					ENDIF
					l_oFormList.Add(l_oForm, RTRIM(STR(l_oForm.nmenubarrefx1950)))
				ENDIF
			ENDFOR
			l_nBar = 1
			l_nShortcut = 1
			DO WHILE l_nBar <= CNTBAR("puWindow")
				l_nMenubarRef = GETBAR("puWindow", l_nBar)
				IF l_nMenubarRef > 50
					l_nIndex = l_oFormList.GetKey(RTRIM(STR(l_nMenubarRef)))
					IF EMPTY(l_nIndex)
						*** remove form from window list menu
						RELEASE BAR l_nMenubarRef OF puWindow
						LOOP
					ELSE
						*** the form is on the list, update it
						l_oForm = l_oFormList.Item(l_nIndex)
						this.UpdateMenuBar(l_oForm, @l_nShortcut)
						l_oFormList.Remove(l_nIndex)
					ENDIF
				ENDIF
				l_nBar = l_nBar + 1
			ENDDO
			FOR EACH l_oForm IN l_oFormList
				*** add form to window list
				this.UpdateMenuBar(l_oForm, @l_nShortcut)
			ENDFOR
		ENDIF
		RETURN CallWindowProc(this.nOldProc, hWnd, Msg, wParam, lParam)
	ENDFUNC
	*
	PROTECTED PROCEDURE SysmenuPadExist
		LPARAMETERS lp_cPad
		LOCAL l_nPad
		FOR l_nPad = 1 TO CNTPAD('_msysmenu')
			IF GETPAD('_msysmenu', l_nPad) == UPPER(lp_cPad)
				RETURN .T.
			ENDIF
		ENDFOR
		RETURN .F.
	ENDPROC
	*
	PROCEDURE ShowSelectedForm
		LPARAMETERS lp_nMenubarRef
		FOR EACH l_oForm AS Form IN _screen.Forms
			IF PEMSTATUS(l_oForm, "nmenubarrefx1950",5) AND l_oForm.nmenubarrefx1950 = lp_nMenubarRef
				l_oForm.Show()
				RETURN
			ENDIF
		ENDFOR
	ENDPROC
	*
	PROTECTED PROCEDURE UpdateMenuBar
		LPARAMETERS lp_oForm, lp_nIndex
		LOCAL l_cSkip, l_nBar, l_cPrompt
		l_nBar = lp_oForm.nmenubarrefx1950
		l_cPrompt = lp_oForm.Caption
		l_cSkip = TRANSFORM((NOT lp_oForm.Enabled) OR (TYPE("_screen.activeform.name") == "C" ;
				AND _screen.activeform.WindowType = 1))
		DEFINE BAR l_nBar OF puWindow ;
				PROMPT IIF(lp_nIndex > 10, " ", "\<" + RIGHT(STR(lp_nIndex),1)) + " " + l_cPrompt ;
				SKIP FOR &l_cSkip
		SET MARK OF BAR l_nBar OF puWindow TO TYPE("_screen.ActiveForm.nmenubarrefx1950") = "N" AND _screen.ActiveForm.nmenubarrefx1950 = l_nBar
		ON SELECTION BAR l_nBar OF puWindow g_oWinEvents.ShowSelectedForm(BAR())
		lp_nIndex = lp_nIndex + 1
	ENDPROC
	*
	PROCEDURE GetMenuBarRef
		this.nMenuBarRef = this.nMenuBarRef + 1
		RETURN this.nMenuBarRef
	ENDPROC

	FUNCTION GetProperty
		LPARAMETERS lp_nMode, lp_nPropertyNumber
		LOCAL l_uRetVal
		DO CASE
			CASE lp_nMode = LETTERS
				l_uRetVal = this.aMyLists(lp_nPropertyNumber)
			OTHERWISE
				
		ENDCASE
		RETURN l_uRetVal
	ENDFUNC
	*
	FUNCTION EventBoundOrNot
	LPARAMETERS lp_nMode
	LOCAL l_lRetVal
	DO case
		CASE lp_nMode = LETTERS
			l_lRetVal = this.aMyLists(4)
		OTHERWISE
			
	ENDCASE
	RETURN l_lRetVal
	ENDFUNC
	*
	FUNCTION UnbindWhenFinished
	LPARAMETERS lp_nMode
	LOCAL l_lRetVal
	DO CASE
		CASE lp_nMode = LETTERS
			l_lRetVal = this.aMyLists(4)
		OTHERWISE
			
	ENDCASE
	RETURN l_lRetVal
	ENDFUNC
	*
	FUNCTION ReserAllProperty
	LPARAMETERS lp_nMode
	DO CASE
		CASE lp_nMode = LETTERS
			this.aMyLists(1) = ""
			this.aMyLists(2) = 0
			this.aMyLists(3) = .F.
			this.aMyLists(4) = .F.
			this.aMyLists(5) = ""
			this.aMyLists(7) = 0
	ENDCASE
	ENDFUNC
ENDDEFINE
*
DEFINE CLASS rpttoxls AS ReportListener
	*
	PROTECTED oExcel, oEval, oXml, nOldSessionID
	cCaption = ""
	oExcel = .NULL.
	oOOCalc = .NULL.
	oEval = .NULL.
	nOldSessionID = 0
	QuietMode = .T.
	*
	PROCEDURE BeforeReport
		LOCAL l_cAlias
		this.nOldSessionID = SET("Datasession")
		SET DATASESSION TO this.FRXDataSession
		CREATE CURSOR curRpt ( ;
				rp_recno i, ;
				rp_pageno i, ;
				rp_left n(8,2), ;
				rp_top n(8,2), ;
				rp_width n(8,2), ;
				rp_height n(8,2), ;
				rp_leftpos i, ;
				rp_toppos i, ;
				rp_rightpos i, ;
				rp_bottompos i, ;
				rp_content m)
		this.PrepareExcelObject()
		*this.PrepareOOCalcObject()
	ENDPROC
	*
	PROCEDURE BeforeBand(nBandObjCode, nFRXRecNo)
		this.oEval = CREATEOBJECT("Collection")
	ENDPROC
	*
	PROCEDURE EvaluateContents(nFRXRecno, oObjProperties)
		LOCAL l_oCollection as Collection
		l_oCollection = this.oEval
		l_oCollection.Add(oObjProperties,ALLTRIM(STR(nFRXRecno)))
	ENDPROC
	*
	PROCEDURE AfterBand(nBandObjCode, nFRXRecNo)
		this.oEval = .NULL.
	ENDPROC
	*
	PROCEDURE Render(nFRXRecNo,;
			nLeft,nTop,nWidth,nHeight,;
			nObjectContinuationType, ;
			cContentsToBeRendered, GDIPlusImage)

		GO nFRXRecNo IN frx
		IF INLIST(frx.ObjType, FRX_OBJTYP_LABEL, FRX_OBJTYP_RECTANGLE, FRX_OBJTYP_FIELD)
			LOCAL l_oColl AS Collection, l_oEvData
			l_oColl = this.oEval
			TRY
				l_oEvData = l_oColl.Item(ALLTRIM(STR(nFRXRecNo)))
				IF TYPE("l_oEvData.Value") <> "C"
					cContentsToBeRendered = TRANSFORM(l_oEvData.Value)
				ELSE
					cContentsToBeRendered = l_oEvData.Text
				ENDIF
			CATCH
				cContentsToBeRendered = STRCONV(cContentsToBeRendered,10)
			ENDTRY
			INSERT INTO curRpt ;
						(rp_recno, rp_pageno, rp_left, rp_top, rp_width, rp_height, rp_content) ;
					VALUES ( ;
						nFRXRecNo, this.PageNo, ;
						this.ReportPosToPixel(nLeft), ;
						this.ReportPosToPixel(nTop), ;
						this.ReportPosToPixel(nWidth), ;
						this.ReportPosToPixel(nHeight), ;
						cContentsToBeRendered)
		ENDIF
		DODEFAULT(nFRXRecNo,;
				nLeft,nTop,nWidth,nHeight,;
				nObjectContinuationType, ;
				cContentsToBeRendered, GDIPlusImage)
	ENDPROC
	*
	PROCEDURE AfterReport
		LOCAL l_nPageNo, l_oWBook
		l_oWBook = this.oExcel.ActiveWorkbook
		FOR l_nPageNo = 1 TO this.PageTotal
			IF l_oWBook.Sheets.Count < l_nPageNo
				l_oSheet = l_oWBook.Sheets.Add( , l_oWBook.Sheets(l_oWBook.Sheets.Count))
			ELSE
				l_oSheet = l_oWBook.Sheets(l_nPageNo)
			ENDIF
			l_oSheet.PageSetup.LeftMargin = l_oSheet.Application.CentimetersToPoints(0.5)
			l_oSheet.PageSetup.RightMargin = l_oSheet.Application.CentimetersToPoints(0.5)
			l_oSheet.PageSetup.TopMargin = l_oSheet.Application.CentimetersToPoints(1)
			l_oSheet.PageSetup.BottomMargin = l_oSheet.Application.CentimetersToPoints(1)
			l_oSheet.PageSetup.PaperSize = xlPaperA4
			l_oSheet.Name = "Page"+ALLTRIM(STR(l_nPageNo))
			l_oSheet.Select()
			this.CalculateExcelPositions(l_nPageNo)
			this.PlaceObject(l_oSheet, l_nPageNo)
		ENDFOR
		USE IN curRpt
		* select first page
		WITH this.oExcel.Sheets(1)
			.Select()
			.Range("A1:A1").Select()
		ENDWITH
		this.oExcel.ScreenUpdating = .T.
		this.oExcel.EnableEvents =.T.
		this.oExcel.Visible = .T.
	ENDPROC
	*
	PROTECTED PROCEDURE PrepareExcelObject()
		LOCAL l_oSheet
		this.oExcel = CREATEOBJECT("Excel.Application")
		IF NOT EMPTY(this.cCaption)
			this.oExcel.Caption = ALLTRIM(this.cCaption)
		ENDIF
		this.oExcel.ScreenUpdating = .F.
		this.oExcel.EnableEvents =.F.
		this.oExcel.Workbooks.Add()
	ENDPROC
	*
	PROTECTED PROCEDURE PrepareOOCalcObject()
		LOCAL l_cSpreadSheetName
		l_cSpreadSheetName = FULLPATH(gcDocumentdir+".odp")
		this.oOOCalc = NEWOBJECT("AutoOpenOffice", "cit_system")
		IF NOT this.oOOCalc.NewDocument(l_cSpreadSheetName)
			Alert(GetLangText("EMBROWS","TXT_OPERATION_UNSUCCESSFULL"))
		ENDIF
	ENDPROC
	*
	PROTECTED PROCEDURE ReportPosToPixel(lp_nRepPos)
		RETURN this.oExcel.InchesToPoints(lp_nRepPos/960)
	ENDPROC
	*
	* find all column widths and row heights
	* replace report positions with excel positions in curRpt
	*
	PROTECTED PROCEDURE CalculateExcelPositions(lp_nPageNo)
		LOCAL l_nPos, l_nRecNo, l_nNextPos, l_nWidthUnit, l_oTempForm AS form
		* calculate ColumnWidth unit in pixels
		l_oTempForm = CREATEOBJECT("form")
		l_oTempForm.FontSize = this.oExcel.StandardFontsize
		l_oTempForm.FontName = this.oExcel.StandardFont
		l_nWidthUnit = l_oTempForm.TextWidth("0")
		l_oTempForm.Release()

		SELECT rp_leftpos FROM ;
				(SELECT rp_left AS rp_leftpos ;
					FROM curRpt ;
					WHERE rp_pageno = lp_nPageNo ;
					UNION ;
						SELECT rp_left+rp_width AS rp_leftpos ;
							FROM curRpt ;
							WHERE rp_pageno = lp_nPageNo) AS curTemp;
			GROUP BY rp_leftpos ;
			INTO CURSOR curLeftPos
		l_nPos = 0
		SCAN
			l_nRecNo = RECNO("curLeftPos")
			SKIP 1 IN curLeftPos
			IF NOT EOF("curLeftPos")
				l_nNextPos = rp_leftpos
			ELSE
				l_nNextPos = 0
			ENDIF
			GO l_nRecno IN curLeftPos
			l_nPos = l_nPos + 1
			IF l_nNextPos > 0
				l_oSheet.Columns(l_nPos).ColumnWidth = ;
						(l_nNextPos - rp_leftpos) / l_nWidthUnit
			ENDIF
			UPDATE curRpt ;
				SET rp_leftpos = l_nPos ;
				WHERE rp_left = curLeftPos.rp_leftpos
			UPDATE curRpt ;
				SET rp_rightpos = l_nPos - 1 ;
				WHERE rp_left+rp_width = curLeftPos.rp_leftPos
		ENDSCAN
		USE IN curLeftPos
		
		SELECT rp_toppos FROM ;
				(SELECT rp_top AS rp_toppos ;
					FROM curRpt ;
					WHERE rp_pageno = lp_nPageNo ;
					UNION ;
						SELECT rp_top+rp_height AS rp_toppos ;
							FROM curRpt ;
							WHERE rp_pageno = lp_nPageNo) AS curTemp;
			GROUP BY rp_toppos ;
			INTO CURSOR curTopPos
		l_nPos = 0
		SELECT curTopPos
		SCAN
			l_nRecNo = RECNO("curTopPos")
			SKIP 1
			IF NOT EOF("curTopPos")
				l_nNextPos = rp_toppos
			ELSE
				l_nNextPos = 0
			ENDIF
			GO l_nRecno IN curTopPos
			l_nPos = l_nPos + 1
			IF l_nNextPos > 0
				l_oSheet.Rows(l_nPos).RowHeight = MIN(400,l_nNextPos - rp_toppos)
			ENDIF
			UPDATE curRpt ;
				SET rp_toppos = l_nPos ;
				WHERE rp_top = curTopPos.rp_toppos
			UPDATE curRpt ;
				SET rp_bottompos = l_nPos - 1 ;
				WHERE rp_top + rp_height = curTopPos.rp_toppos
		ENDSCAN
		USE IN curTopPos
	ENDPROC
	*
	* report objects from curRpt are placed to excel object
	*
	PROTECTED PROCEDURE placeObject(lp_oSheet, lp_nPageNo)
		LOCAL l_oRange
		this.doPage(lp_nPageNo, this.PageTotal)
		SELECT curRpt
		SCAN FOR rp_pageno = lp_nPageNo
			this.doProgress(RECNO("curRpt"), RECCOUNT("curRpt"))
			SELECT curRpt
			GO curRpt.rp_recno IN frx
			l_oRange = lp_oSheet.Range(lp_oSheet.Cells(curRpt.rp_toppos, curRpt.rp_leftpos), ;
					lp_oSheet.Cells(curRpt.rp_bottompos, curRpt.rp_rightpos))
			DO CASE
				CASE INLIST(frx.objtype, FRX_OBJTYP_LABEL, FRX_OBJTYP_FIELD)
*					l_oRange.select()
					l_oRange.MergeCells = .F.
					l_oRange.MergeCells = .T.
					this.SetFont(l_oRange)
					l_oRange.Value = curRpt.rp_content
				CASE frx.objtype = FRX_OBJTYP_RECTANGLE
					this.SetBorder(l_oRange)
			ENDCASE
		ENDSCAN
	ENDPROC
	*
	* get pen or fill rgb color
	*
	PROTECTED PROCEDURE GetColor(lp_cMode)
		LOCAL l_nColor
		lp_cMode = UPPER(ALLTRIM(lp_cMode))
		l_nColor = RGB(255,255,255)
		TRY
			DO CASE
				CASE lp_cMode == "PEN"
					l_nColor = RGB(frx.penred, frx.pengreen, frx.penblue)
				CASE lp_cMode == "FILL"
					l_nColor = RGB(frx.fillred, frx.fillgreen, frx.fillblue)
			ENDCASE
		CATCH
		ENDTRY
		RETURN l_nColor
	ENDPROC
	*
	PROTECTED PROCEDURE SetFont(lp_oRange)
		lp_oRange.Font.Name = frx.FontFace
		lp_oRange.Font.Size = frx.FontSize
*		lp_oRange.Font.Color = this.GetColor("pen")
		lp_oRange.Font.Bold = (BITAND(frx.FontStyle, FRX_FONTSTYLE_BOLD) > 0)
		lp_oRange.Font.Italic = (BITAND(frx.FontStyle, FRX_FONTSTYLE_ITALIC) > 0)
		lp_oRange.Font.Underline = (BITAND(frx.FontStyle, FRX_FONTSTYLE_UNDERLINED) > 0)
		lp_oRange.Font.StrikeThrough = (BITAND(frx.FontStyle, FRX_FONTSTYLE_STRIKETHROUGH) > 0)
		lp_oRange.VerticalAlignment = xlVAlignCenter
		lp_oRange.WrapText = .T.
		lp_oRange.ShrinkToFit = .T.
		DO CASE
			CASE frx.offset = FRX_JUSTIFICATION_LEFT
				lp_oRange.HorizontalAlignment = xlHAlignLeft
			CASE frx.offset = FRX_JUSTIFICATION_RIGHT
				lp_oRange.HorizontalAlignment = xlHAlignRight
			CASE frx.offset = FRX_JUSTIFICATION_CENTER
				lp_oRange.HorizontalAlignment = xlHAlignCenter
		ENDCASE
	ENDPROC
	*
	PROTECTED PROCEDURE SetBorder(lp_oRange)
		LOCAL l_nColor
		lp_oRange.Interior.Color = this.GetColor("fill")
		l_nColor = this.GetColor("pen")
		lp_oRange.Borders(xlEdgeLeft).Color = l_nColor
		lp_oRange.Borders(xlEdgeTop).Color = l_nColor
		lp_oRange.Borders(xlEdgeBottom).Color = l_nColor
		lp_oRange.Borders(xlEdgeRight).Color = l_nColor
		lp_oRange.Borders(xlEdgeLeft).LineStyle = xlContinuous
		lp_oRange.Borders(xlEdgeTop).LineStyle = xlContinuous
		lp_oRange.Borders(xlEdgeBottom).LineStyle = xlContinuous
		lp_oRange.Borders(xlEdgeRight).LineStyle = xlContinuous
	ENDPROC
	*
	PROTECTED PROCEDURE doProgress(lp_nCurrentProgress, lp_nTotalProgress)
		SET DATASESSION TO this.nOldSessionID
		this.onProgress(lp_nCurrentProgress, lp_nTotalProgress)
		SET DATASESSION TO this.FRXDataSession
	ENDPROC
	*
	PROTECTED PROCEDURE doPage(lp_nCurrentPage, lp_nTotalPage)
		SET DATASESSION TO this.nOldSessionID
		this.onPage(lp_nCurrentPage, lp_nTotalPage)
		SET DATASESSION TO this.FRXDataSession
	ENDPROC
	*
	PROCEDURE onProgress(lp_nCurrentProgress, lp_nTotalProgress)
	
	ENDPROC
	*
	PROCEDURE onPage(lp_nCurrentPage, lp_nTotalPage)
	
	ENDPROC
	*
ENDDEFINE
*
DEFINE CLASS THeader AS Header
	Caption = "THeader"
	*
	PROCEDURE DblClick
	IF NOT EMPTY(this.Parent.cSortOrder)
		this.Parent.Parent.setordering(this.Parent.cSortOrder)
	ENDIF
	ENDPROC
	*
	PROCEDURE RightClick
	IF NOT EMPTY(this.Parent.cSortOrder)
		this.Parent.Parent.setordering(this.Parent.cSortOrder, .T.)
	ENDIF
	ENDPROC
ENDDEFINE
*
DEFINE CLASS GRDRAVColumn AS Column
	FontName = "Courier"
	ReadOnly = .T.
	Width = 105
	Sparse = .F.
	Movable = .F.
	Resizable = .F.
	HeaderClass = "GRDRAVHeader"
	HeaderClassLibrary = "commonclasses.prg"
	ADD OBJECT GRDRAVcntgridcell1 AS GRDRAVcntgridcell

	PROCEDURE SetCaption
		LPARAMETERS lp_cText
		this.GRDRAVHeader1.Caption = lp_cText
	ENDPROC
ENDDEFINE
*
DEFINE CLASS GRDRAVHeader AS Header
	Alignment = 2
ENDDEFINE
*
DEFINE CLASS GRDRAVcntgridcell AS cntgridcell OF libs\cit_rentavail.vcx
	FontName = "Courier"
ENDDEFINE
*
DEFINE CLASS grdHotstatColumn AS Column
	ReadOnly = .T.
	ADD OBJECT tbgrid1 AS gbtbgrid
*
PROCEDURE MouseMove
	LPARAMETERS nButton, nShift, nXCoord, nYCoord
	this.Parent.MouseMove(nButton, nShift, nXCoord, nYCoord)
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS JAvlRtColumn AS grdBaseSortColumn
	Alignment = 2
	InputMask = "99999"
	Movable = .F.
	Resizable = .F.
	Width = 35
	nBackColorCoef = 0
	Header1.FontBold = .T.
ENDDEFINE
*
DEFINE CLASS JAvlAvColumn AS Column
	Alignment = 2
	InputMask = "99999"
	Movable = .F.
	Resizable = .F.
	Width = 71
	nBackColorCoef = 0
	ADD OBJECT Header1 AS Header
	Header1.Alignment = 2
	Header1.FontBold = .T.
ENDDEFINE
*
DEFINE CLASS JAvlEvColumn AS JAvlAvColumn
	Header1.WordWrap = .T.
	ADD OBJECT Text1 AS EditBox
	Text1.ScrollBars = 0
	Text1.FontName = "Arial Narrow"
	Text1.FontSize = 8
	Text1.Themes = .F.
	Text1.BorderStyle = 0
	ADD OBJECT Image1 AS Image
	Image1.Stretch = 2
	Sparse = .F.
ENDDEFINE
*
DEFINE CLASS grdbasesortcolumn AS Column
	ReadOnly = .T.
	lForceSortAllowed = .F.
	ccontrolsourcecopy = ""
	cSortOrder = ""
	lonlyonce = .F.
	ADD OBJECT Header1 AS JHeader
	ADD OBJECT tbgrid1 AS gbtbgrid
	*
	PROCEDURE ControlSource_ASSIGN
	LPARAMETERS vNewVal
	*IF NOT EMPTY(vNewVal)&& AND this.ccontrolsourcecopy <> vNewVal
	IF NOT this.lonlyonce AND NOT EMPTY(vNewVal)
		this.lonlyonce = .T.
		this.ccontrolsourcecopy = vNewVal
	ENDIF
	this.ControlSource = vNewVal
	*
	PROCEDURE Visible_ASSIGN
	LPARAMETERS tlNewVal

	IF this.Visible # tlNewVal
		this.Visible = tlNewVal
		this.Parent.ChangeProp("Visible", this)
	ENDIF
	ENDPROC
	*
ENDDEFINE
*
DEFINE CLASS JHeader AS Header
	Alignment = 2
	Visible = .T.
	HIDDEN jSort
	jsort = .F.
	*
	PROCEDURE MouseDown
		LPARAMETERS pnbutton, pnshift, pnxcoord, pnycoord
		IF (GetScreenCursor() = gnarrowpointer) OR this.Parent.lForceSortAllowed
			this.jsort = .T.
		ELSE
			this.jsort = .F.
		ENDIF
	ENDPROC
	*
	PROCEDURE RightClick
		LOCAL ckey, lcDirection, nRecno, cmsg, l_lSuccess, l_oErr
		IF !this.jsort
			RETURN
		ENDIF
		ckey = UPPER(EVL(this.parent.csortorder,this.parent.controlsource))
		IF EMPTY(ckey) OR "THIS" $ ckey OR [IIF(LI_HIDE] $ ckey
			* Dont sort when empty, or when controlsorce is method
			RETURN
		ENDIF
		l_oErr = .NULL.
		l_lSuccess = .T.
		nRecno = RECNO()
		lcDirection = SortPopup(0)
		WITH this.Parent.Parent
			DO CASE
				CASE lcDirection = "ASCENDING"
					ckey = .GetSortKey(this.Parent, ckey, lcDirection)
					cmsg = _VFP.StatusBar
					SET MESSAGE TO "Sorting" + '...'
					TRY
						INDEX ON &cKey &lcDirection TAG GridSort OF (.JIndexFile)
					CATCH TO l_oErr
					ENDTRY
					IF TYPE("l_oErr.ErrorNo") = "N" AND l_oErr.ErrorNo = 110
						* Existing compound CDX file was not opened. Create an other.
						l_lSuccess = .F.
					ENDIF
					IF NOT l_lSuccess
						SET INDEX TO
						FileDelete(.JIndexFile)
						INDEX ON &cKey &lcDirection TAG GridSort OF (.JIndexFile)
					ENDIF
					.Refreshsortcursor()
					.refresh()
					SET MESSAGE TO cmsg
				CASE lcDirection = "DESCENDING"
					ckey = .GetSortKey(this.Parent, ckey, lcDirection)
					cmsg = _VFP.StatusBar
					SET MESSAGE TO"Sorting" + '...'
					TRY
						INDEX ON &cKey &lcDirection TAG GridSort OF (.JIndexFile)
					CATCH TO l_oErr
					ENDTRY
					IF TYPE("l_oErr.ErrorNo") = "N" AND l_oErr.ErrorNo = 110
						* Existing compound CDX file was not opened. Create an other.
						l_lSuccess = .F.
					ENDIF
					IF NOT l_lSuccess
						SET INDEX TO
						FileDelete(.JIndexFile)
						INDEX ON &cKey &lcDirection TAG GridSort OF (.JIndexFile)
					ENDIF
					.Refreshsortcursor()
					.refresh()
					SET MESSAGE TO cmsg
			ENDCASE
		ENDWITH
		GO nRecno
	ENDPROC
	*
ENDDEFINE
*
DEFINE CLASS gbtbgrid AS tbgrid OF libs\main.vcx
ENDDEFINE
*
DEFINE CLASS oCmdGetFile AS Custom
	Caption = "..."

	PROCEDURE Click
	LPARAMETERS lp_oFormRef
	LOCAL l_cFilename

	l_cFilename = GETFILE()
	IF NOT EMPTY(l_cFilename)
		lp_oFormRef.txtPath.Value = PROPER(ALLTRIM(JUSTFNAME(l_cFilename)))
	ENDIF
	ENDPROC
ENDDEFINE
*
DEFINE CLASS oCmdGetColor AS Custom
	Caption = "..."

	PROCEDURE Click
	LPARAMETERS lp_oFormRef
	LOCAL l_nColor

	l_nColor = GETCOLOR(lp_oFormRef.txtColor.DisabledBackColor)
	IF l_nColor <> -1
		lp_oFormRef.txtColor.DisabledBackColor = l_nColor
	ENDIF
ENDDEFINE
*
DEFINE CLASS cmngreportmidifytimer AS Timer
*
Interval = 300
*
PROCEDURE Timer
this.Enabled = .F.
LOCAL l_oForm AS Form
FOR EACH l_oForm IN _screen.Forms
	IF TYPE("l_oForm.mngCTRL.Class")="C" AND LOWER(l_oForm.mngCTRL.Class)=="mngreportsctrl"
		l_oForm.Show()
		EXIT
	ENDIF
ENDFOR
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS cglobal AS Custom
cUpdateNewsURL = ""
lArchive = .F.
oArchive = .NULL.
nHoldHistResYears = 5
lsmtpactive = .F.
csmtphost = ""
csmtpfrom = ""
csmtpauthlogin = ""
csmtpauthpassword = ""
csmtpdefaultexportformat = ""
csmtpdefaulttoaddress = ""
lsmtpusemapi = .F.
oactiveaddress = .NULL.
oactiveapartner = .NULL.
lLEAVE_FULL_FIELD_CONTENT = .T.
nHORIZONTAL_ADJUSTMENT = 1500
nVERTICAL_ADJUSTMENT = 400
emtype = 1
lUseMainServer = .F.
lautorepairtables = .F.
oTerminal = .NULL.
oFPrinter = .NULL.
oParam2 = .NULL.
oParam = .NULL.
lautocenterforms = .T.
lblockusers = .F.
creportresultsdir = "reportresults"
lLoginFailed = .F.
cdatabasedir = ""
creportdir = ""
ctemplatedir = ""
choteldir = ""
chotelvatnr = ""
cdatabasetableprefix = ""
oCaCol = .NULL.
oUser = .NULL.
oGroup = .NULL.
lMultiProper = .F.
lODBC = .F.
lODBCSYNC = .F.
cODBCDSN = ""
cODBCDatabase = "citadel"
cODBCServer = ""
cODBCPort = ""
cODBCDriverName = ""
lODBCArgus = .F.
cArgusMetadataDir = ""
cODBCArgusDatabase = ""
cODBCArgusServer = ""
cODBCArgusPort = ""
cODBCArgusPswd = ""
cODBCArgusDriver = ""
nODBCDReconnectTimeout = 30
lFormReports = .F.
cIniLoc = ""
lIfcRoomStatIsChar = .F.
lAutoBackup = .F.
lshowtabs = .F.
cAutoBackupDestination = ""
nNumberOfAutobackups = 0
lSystemAppExists = .T.
lDoAuditOnStartup = .F.
lRptlngSettled = .F.
nBCOccupancyLevel1 = RGB(255,255,255)
nBCOccupancyLevel2 = RGB(255,255,255)
nBCOccupancyLevel3 = RGB(255,255,255)
lDontAllowArticleDescriptionChange = .F.
lflushforce = .F.
cmsglast = ""
ccomservertempfolder = ""
oDeskServer = .NULL.
lelpay = .F.
lscreenminbuttonenabled = .F.
lforcestartoverloader = .F.
cSetCurrencyPosition = ""
cSetCurrencySign = ""
nSetDecimals = 2
nSetHours = 24
cSetSeparator = ""
lUgos = .F.
lUgosPriceChangeNotAllowed = .F.
cUgosImportWorkStation = ""
cUgosPatientsImportMask = ""
nUgosImportPeriod = 10
lUgosLogging = .F.
cUgosLogFileName = ""
nUgosMaxLogFileLength = 0
nUgosMaxLogNum = 0
cUgosDefaultRatecode = ""
cUgosDefaultRoomtype = ""
cUgosDefaultLanguage = ""
cUgosDefaultMarket = ""
cUgosDefaultSource = ""
lBmsManagerForServer = .F.
lbmsratecodewithsplits = .F.
luselanguagetable = .F.
lNavPaneIconsExternal = .F.
lwebbrowserdesktop = .F.
nMyDeskRefreshPeriod = 0
lexitwhennetworksharelost = .F.
chtmldir = ""
lusesysdatefrompc = .F.
luseremoteserverforsql = .F.
lNewAvailability = .F.
oBuilding = .NULL.
cStandardBuilding = ""
lDoBatchOnStartup = .F.
cIfcBeforeReadDataFXP = ""
lManagerRevenueOnlyForClosedBills = .F.
lDontSaveCreditCard = .F.
cadrmaincopyfieldsignorelist = ""
lAllowConfGroupSplit = .F.
nGridMinHeight = 0
cDotNetFrameworkVersion = "0.0"
lTableReservationPlans = .F.
lAvailabilityShowPrintDialog = .F.
nAvailabilityShowPrintDialogDefaultDays = 0
oExtVouchersData = .NULL.
lexternalvouchers = .F.
lspecialfiscalprintermode = .F.
lmainserverremote = .F.
lMainServerDirectoryAvailable = .F.
lAllowBillExport = .F.
lVehicleRentMode = .F.
lVehicleRentModeOffsetInAvailab = .F.
lIfcCheckBlock = .F.
lResetBillNumberOnNewYear = .F.
lhidebanquetbutton = .F.
larticlenotewithformating = .F.
csortroomsonrevenuefromdate = ""
csortroomsonrevenuetodate = ""
csortroomsonrevenuemaingroups = ""
lbdarticleactive = .F.
oQRCodeGen = .NULL.
lfiskaltrustactive = .F.
lfiskaltrustlog = .F.
lfiskaltrustuseexternalhttp = .F.
cfiskaltrusturl = ""
cfiskaltrustproxy = ""
cfiskaltrustcashboxid = ""
cfiskaltrustqrcode = ""
cfiskaltrustaccesstoken = ""
lLimitInputMaskForRoomName = .F.
lAgency = .F.
lQrCodeDoorKeyActive = .F.
cQrCodeDoorKeyReservatUserField = ""
cQrCodeURLReservatUserField = ""
cQrCodeHost = ""
cQrCode_twilio_url = ""
cQrCode_twilio_from_phone = ""
cQrCode_twilio_sms_message = ""
cQrCode_twilio_auth = ""
cHouseKeepingRoomTypeFilter = ""
cHiInsuranceNoAdrUserField = ""
lHiLog = .F.
lGobdActive = .F.
cGobdDirectory = ""
dGobdFromsysdate = {}
cGobdAddress_globalid = ""
cGobdArticle_globalid = ""
lSqlCursorErrorIgnore = .F.
DIMENSION aSearchRes(1), aParamFields(1), aParam2Fields(1)
DIMENSION aExtserver(1)
*
PROCEDURE Init
LOCAL l_cData

this.NewObject("oIniReg","oldinireg","libs\registry.vcx")
IF NOT g_lAutomationMode
	this.NewObject("ostatusbar","cstatusbar","libs\cit_system.vcx")
	this.NewObject("oColPictures","tcntPictureCollection","libs\cit_ctrl.vcx")

	* check if local ini file is used
	IF FILE(INI_LOCAL_FILE)
		l_cData = ""
		IF this.oIniReg.GetINIEntry(@l_cData, "System", "hoteldir", FULLPATH(INI_LOCAL_FILE)) = ERROR_SUCCESS
			IF NOT EMPTY(l_cData)
				_screen.oGlobal.choteldir = ADDBS(ALLTRIM(LOWER(l_cData)))
			ENDIF
		ENDIF
	ENDIF
ENDIF
this.cIniLoc = FULLPATH(INI_FILE)

*Make fake param2, we don't have connection to database yet, but need some dafault settings
this.oParam2 = CREATEOBJECT("Empty")
ADDPROPERTY(this.oParam2,"pa_dbvers","")
this.oParam = CREATEOBJECT("Empty")
ADDPROPERTY(this.oParam,"pa_point",",")
ADDPROPERTY(this.oParam,"pa_sysdate",{})
this.AddObject("oBill","cBillData")
this.oCaCol = CREATEOBJECT("Collection")
this.AddObject("oGData","cGData")
IF NOT g_lAutomationMode
	this.NewObject("oMultiProper","cMultiProper","progs\procmultiproper.prg")
	this.AddObject("oFormsHandler","cFormsHandler")
ENDIF

* When cashier logs in with selected building, store here selected building properties
this.oBuilding = CREATEOBJECT("Empty")
ADDPROPERTY(this.oBuilding,"ccode","")
ADDPROPERTY(this.oBuilding,"cdescription","")
ADDPROPERTY(this.oBuilding,"cbillnumprefix","")
ADDPROPERTY(this.oBuilding,"lselectbuildingonlogin",.F.)

* Initialize ExtServer

DIMENSION this.aExtServer(20)
this.aExtServer(DIRS_SERVER_ID) = "DIRS"
this.aExtServer(CLTZ_SERVER_ID) = "CLTZ"
this.aExtServer(HOSC_SERVER_ID) = "HOSC"
this.aExtServer(CSTATION_SERVER_ID) = "CLST"
this.aExtServer(WEBSERVICE_SERVER_ID) = "WEBS"
this.aExtServer(WEBMEDIA_SERVER_ID) = "CHMN"
this.aExtServer(CITADEL_SERVER_ID) = "CITD"
this.aExtServer(RHNCHANNELPRO_SERVER_ID) = "RHNC"
this.aExtServer(CITADEL_BOOKING_SERVER_ID) = "CITB"
this.aExtServer(PARITYRATE_SERVER_ID) = "PART"
this.aExtServer(HOTELNETSOLUTIONS_SERVER_ID) = "HSOL"
this.aExtServer(HOTELSPIDER_SERVER_ID) = "HSPI"
this.aExtServer(SITEMINDER_SERVER_ID) = "SIMI"
this.aExtServer(PROFITROOM_SERVER_ID) = "PROF"
this.aExtServer(WEBRES_SERVER_ID) = "WRES"
this.aExtServer(AVAILPRO_SERVER_ID) = "APRO"
this.aExtServer(DIRSV3_SERVER_ID) = "DIR3"
this.aExtServer(SABRE_SERVER_ID) = "SABR"
this.aExtServer(HOTELPARTNERYM_SERVER_ID) = "HOPA"
this.aExtServer(HRS_IMWEB_SERVER_ID) = "IHRS"

RETURN .T.
ENDPROC
*
PROCEDURE Initialize
LOCAL l_cIniLoc, l_cIniLocMP, l_cFrameworkPath, l_cVersion
* Create other global objects, after database is accessable
IF ProcArchive("PrepareArchive")
	_screen.oGlobal.oArchive.Disconnect()
ENDIF
IF NOT g_lAutomationMode
	this.NewObject("oRG","ReportGenerator","mylists.prg") && Used in default datasession!
ENDIF
IF _screen.oGlobal.lfiskaltrustactive OR _screen.oGlobal.lQrCodeDoorKeyActive
	_screen.oGlobal.oQRCodeGen = CREATEOBJECT("FoxBarcodeQR")
ENDIF
IF this.lUseMainServer
	l_cIniLoc = FULLPATH(INI_FILE)
	l_cIniLocMP = IIF(this.lmultiproper OR EMPTY(this.oParam2.pa_srvpath),l_cIniLoc,ADDBS(ALLTRIM(this.oParam2.pa_srvpath))+"citadel.ini")
	IF NOT EMPTY(l_cIniLocMP)
		* Here add properties, which should be read from multiproper citadel.ini, in each hotel installation
		this.cadrmaincopyfieldsignorelist = ReadINI(l_cIniLocMP, [multiproper], [adrmaincopyfieldsignorelist], [])
	ENDIF
ENDIF
this.nGridMinHeight = IIF(GetDPI() = 120, 24, 20)

IF IsDotNet(@l_cFrameworkPath, @l_cVersion)
	this.cDotNetFrameworkVersion = l_cVersion
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE AfterLogin
IF this.lshowtabs
	procnavpane("TurnOnNavPane")
	MdMyDesk(.T.)
ELSE
	MdMyDesk(.T.)
	procnavpane("TurnOnNavPane")
ENDIF
IF this.lshowtabs OR ISNULL(g_oNavigPane)
	MdRefresh()
ENDIF
IF NOT ISNULL(_screen.oCardReaderHandler.oHicHandler) AND _screen.oCardReaderHandler.oHicHandler.lAvailable
	_screen.oCardReaderHandler.oHicHandler.AfterLogin()
ENDIF
ENDPROC
*
PROCEDURE GetActiveAddress
LPARAMETERS lp_lNoListsTable, lp_nReserId, lp_cHeader, lp_liid
LOCAL l_nAddrId, l_nApId, l_cCur, l_lFound
STORE 0 TO l_nAddrId, l_nApId, lp_nReserId
lp_cHeader = ""
this.oactiveaddress = .NULL.
this.oactiveapartner = .NULL.

IF NOT lp_lNoListsTable
	* Get list type
	IF lists.li_custom AND lists.li_lettype = 1 AND lists.li_menu = 8 AND ALLTRIM(LOWER(lists.li_mindef1)) == "reservat.rs_reserid" AND lists.li_reslet AND TYPE("min1")="N" AND NOT EMPTY(min1)
		IF SEEK(min1, "reservat", "tag1")
			lp_nReserId = reservat.rs_reserid
			IF EMPTY(reservat.rs_compid)
				l_nAddrId = reservat.rs_addrid
			ELSE
				l_nAddrId = reservat.rs_compid
				IF NOT EMPTY(reservat.rs_apid)
					l_nApId = reservat.rs_apid
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

DO CASE
	CASE NOT EMPTY(l_nAddrId)
	CASE this.oBill.nAddrId > 0
		l_nAddrId = this.oBill.nAddrId
		l_nApId = this.oBill.nApId
	OTHERWISE
		l_lFound = .F.
		FOR EACH l_oForm IN _screen.Forms
			IF LOWER(l_oForm.Name) = "faddressmask" AND l_oForm.Visible
				l_lFound = .T.
				EXIT
			ENDIF
		ENDFOR
		DO CASE
			CASE NOT l_lFound
			CASE TYPE("l_oForm.Name") = "U"
			
			CASE LOWER(l_oForm.Name)="faddressmask"
				l_nAddrId = l_oForm.Parent.m_GetSelectedAddress(@l_nApId, .T.)
		ENDCASE
ENDCASE

IF l_nAddrId>0
	l_cCur = sqlcursor("SELECT * FROM address WHERE ad_addrid = "+sqlcnv(l_nAddrId),"",.F.,"",.NULL.,.T.)
	IF USED(l_cCur) AND RECCOUNT(l_cCur)>0
		SELECT (l_cCur)
		SCATTER NAME this.oactiveaddress MEMO
		lp_cHeader = procemail("PEGetHeader", lp_liid, ad_title, ad_fname, ad_lname, ad_salute, ad_lang)
	ENDIF
	dclose(l_cCur)
ENDIF
IF l_nApId>0
	l_cCur = sqlcursor("SELECT * FROM apartner WHERE ap_apid = "+sqlcnv(l_nApId),"",.F.,"",.NULL.,.T.)
	IF USED(l_cCur) AND RECCOUNT(l_cCur)>0
		SELECT (l_cCur)
		SCATTER NAME this.oactiveapartner MEMO
		lp_cHeader = procemail("PEGetHeader", lp_liid, ap_title, ap_fname, ap_lname, ap_salute, ap_lang)
	ENDIF
	dclose(l_cCur)
ENDIF

RETURN l_nAddrId
ENDPROC
*
PROCEDURE GetIniProp
LPARAMETERS lp_cSection, lp_cProperty
#INCLUDE "include\registry.h"
LOCAL l_cData, l_cRetVal
l_cData = ""
l_cRetVal = ""
IF EMPTY(lp_cSection) OR EMPTY(lp_cProperty)
	RETURN l_cRetVal
ENDIF
IF this.oIniReg.GetINIEntry(@l_cData, lp_cSection, lp_cProperty, this.cIniLoc) = ERROR_SUCCESS
	IF NOT EMPTY(l_cData)
		l_cRetVal = l_cData
	ENDIF
ENDIF
RETURN l_cRetVal
ENDPROC
*
PROCEDURE RefreshTableParam2
LOCAL loRecord

this.oGData.GetMainTableRecord("param2", @loRecord)
this.oParam2 = loRecord
		* check if fields are missing, in case before update is finished
	*!*		IF TYPE("this.oParam2.pa_...")="U"
	*!*			ADDPROPERTY(this.oParam2,"pa_...",.F.)
	*!*		ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE RefreshTableParam
LOCAL loRecord

this.oGData.GetMainTableRecord("param", @loRecord)
this.oParam = loRecord

RETURN .T.
ENDPROC
*
PROCEDURE RefreshTableTerminal
LOCAL loRecord

this.oGData.GetMainTableRecord("terminal", @loRecord, "tm_winname = " + SqlCnv(PADR(WinPC(),15),.T.))
this.oTerminal = loRecord

RETURN .T.
ENDPROC
*
PROCEDURE SearchResCriteriums
LOCAL i, lnRow
LOCAL ARRAY laSearchRes(1,4)

lnRow = 1
laSearchRes[lnRow,1] = ""	&& Caption for combo in params
laSearchRes[lnRow,2] = ""	&& Caption for menu item in resbrw
laSearchRes[lnRow,3] = 0	&& nMode for SearchRes form
laSearchRes[lnRow,4] = 0	&& Section number. Between differnet sections would be placed menu separator.
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_LASTNAME")
laSearchRes[lnRow,3] = 1
laSearchRes[lnRow,4] = 1
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_COMPANY")
laSearchRes[lnRow,3] = 2
laSearchRes[lnRow,4] = 1
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_AGENT")
laSearchRes[lnRow,3] = 3
laSearchRes[lnRow,4] = 1
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_GROUP")
laSearchRes[lnRow,3] = 4
laSearchRes[lnRow,4] = 1
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_ALLOTT")
laSearchRes[lnRow,3] = 5
laSearchRes[lnRow,4] = 1
IF _screen.KT
	lnRow = AAdd(@laSearchRes)
	laSearchRes[lnRow,2] = GetLangText("RESBRW","TXT_EVENT")
	laSearchRes[lnRow,3] = 30
	laSearchRes[lnRow,4] = 1
ENDIF
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_ARRDATE")
laSearchRes[lnRow,3] = 7
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_DEPDATE")
laSearchRes[lnRow,3] = 8
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_ROOMNUM")
laSearchRes[lnRow,3] = 9
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_ROOMTYPE")
laSearchRes[lnRow,3] = 10
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_STATUS")
laSearchRes[lnRow,3] = 11
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_RESNUM")
laSearchRes[lnRow,3] = 12
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_CANCNUM")
laSearchRes[lnRow,3] = 13
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TM_CREATED_DATE")
laSearchRes[lnRow,3] = 31
laSearchRes[lnRow,4] = 2
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TXT_RECNAME")
laSearchRes[lnRow,3] = 20
laSearchRes[lnRow,4] = 5
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TXT_MEMBER")
laSearchRes[lnRow,3] = 22
laSearchRes[lnRow,4] = 6
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","TXT_USERDEF")
laSearchRes[lnRow,3] = 23
laSearchRes[lnRow,4] = 6
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","T_RATECODE")
laSearchRes[lnRow,3] = 24
laSearchRes[lnRow,4] = 6
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("RESERVAT","T_CARDAUTH")
laSearchRes[lnRow,3] = 25
laSearchRes[lnRow,4] = 6
lnRow = AAdd(@laSearchRes)
laSearchRes[lnRow,2] = GetLangText("BILL","TXT_BILL_NUM")
laSearchRes[lnRow,3] = 26
laSearchRes[lnRow,4] = 6
FOR i = 1 TO ALEN(laSearchRes,1)
	laSearchRes[i,1] = STRTRAN(laSearchRes[i,2],"\<")
NEXT
DIMENSION this.aSearchRes(1)
=ACOPY(laSearchRes, this.aSearchRes)
ENDPROC
*
PROCEDURE MainServerPathGet
LOCAL l_cPath
DO CASE
	CASE TYPE("this.oParam2.pa_srvpath")<>"C"
		l_cPath = ""
	CASE EMPTY(this.oParam2.pa_srvpath)
		l_cPath = ""
	OTHERWISE
		l_cPath = ALLTRIM(this.oParam2.pa_srvpath)
ENDCASE
IF NOT EMPTY(l_cPath)
	l_cPath = ADDBS(l_cPath)
ENDIF
RETURN l_cPath
ENDPROC
*
PROCEDURE MainServerTables
LPARAMETERS lp_cTable
LOCAL l_lUseFromMainServer
IF EMPTY(lp_cTable)
	lp_cTable = ""
ELSE
	lp_cTable = PADR(LOWER(ALLTRIM(lp_cTable)),8)
ENDIF
IF this.lMultiProper AND this.lMainServerDirectoryAvailable AND INLIST(lp_cTable,PADR("grid",8),PADR("screens",8),PADR("gridprop",8)) && Here add tables, which should always be opened from main server database.
	l_lUseFromMainServer = .T.
ENDIF
RETURN l_lUseFromMainServer
ENDPROC
*
PROCEDURE GetLangText
LPARAMETER tcProgram, tcLabel, tcLanguage, tlWithoutLine
LOCAL i, lnArea, lcText, lcXML, lcLanguage
LOCAL ARRAY laLanguage(9,3)

lnArea = SELECT()

lcText = STRTRAN(PROPER(STRTRAN(tcLabel, "TXT_", "")), "_", " ")

lcLanguage = IIF(PCOUNT() > 2 AND NOT EMPTY(tcLanguage), tcLanguage, "")

IF NOT USED("curlanguage")
	IF this.luselanguagetable
		openfiledirect(.F.,"language")
		sqlcursor("SELECT * FROM language","curlanguage",,,,,,.T.)
		dclose("language")
		SELECT curlanguage
	ELSE
		lcXML = STRCONV(FILETOSTR("Metadata\language.xml"),11)
		XMLTOCURSOR(lcXML, "curlanguage")
	ENDIF
	INDEX ON UPPER(la_lang+la_prg+la_label) TAG Tag1
ENDIF

IF USED("curlanguage")
	SELECT curlanguage
	IF TYPE("g_Language") <> "C"
		g_Language = "ENG"
	ENDIF
	lcLanguage = IIF(EMPTY(lcLanguage), g_Language, lcLanguage)
	DO CASE
		CASE SEEK(PADR(lcLanguage,3)+PADR(tcProgram,8)+PADR(tcLabel,30),"curlanguage","tag1")
			lcText = ALLTRIM(curlanguage.la_text)
		CASE SEEK("ENG"+PADR(tcProgram,8)+PADR(tcLabel,30),"curlanguage","tag1")
			lcText = ALLTRIM(curlanguage.la_text)
		CASE FILE("Hotel.lng")
			laLanguage[1,1] = "ENG"
			laLanguage[1,2] = "English"
			laLanguage[2,1] = "DUT"
			laLanguage[2,2] = "Dutch"
			laLanguage[3,1] = "GER"
			laLanguage[3,2] = "German"
			laLanguage[4,1] = "FRE"
			laLanguage[4,2] = "French"
			laLanguage[5,1] = "INT"
			laLanguage[5,2] = "Int. English"
			laLanguage[6,1] = "SER"
			laLanguage[6,2] = "Serbian"
			laLanguage[7,1] = "POR"
			laLanguage[7,2] = "Portuguese"
			laLanguage[8,1] = "ITA"
			laLanguage[8,2] = "Italian"
			laLanguage[9,1] = "POL"
			laLanguage[9,2] = "Polish"
			DEFINE WINDOW deFinetext FROM 1, 1 TO 20, 80 FONT "Arial", 10 NOCLOSE NOZOOM TITLE "Define TEXT" IN SCREEN NOMDI DOUBLE
			ACTIVATE WINDOW deFinetext
			laLanguage[1,3] = PADR(lcText,60)
			laLanguage[2,3] = laLanguage[1,3]
			laLanguage[3,3] = laLanguage[1,3]
			laLanguage[4,3] = laLanguage[1,3]
			laLanguage[5,3] = laLanguage[1,3]
			laLanguage[6,3] = laLanguage[1,3]
			laLanguage[7,3] = laLanguage[1,3]
			laLanguage[8,3] = laLanguage[1,3]
			laLanguage[9,3] = laLanguage[1,3]
			@ 1,       1 SAY "Base language :" + lcLanguage
			@ 2.250,   1 SAY "Source :" + tcProgram
			@ 3.500,   1 SAY "Label :" + tcLabel
			@ 4.750,   1 SAY laLanguage[1,2]
			@ 4.750,  20 GET laLanguage[1,3] SIZE 1, 50 PICTURE "@K"
			@ 6,       1 SAY laLanguage[2,2]
			@ 6,      20 GET laLanguage[2,3] SIZE 1, 50 PICTURE "@K"
			@ 7.250,   1 SAY laLanguage[3,2]
			@ 7.250,  20 GET laLanguage[3,3] SIZE 1, 50 PICTURE "@K"
			@ 8.500,   1 SAY laLanguage[4,2]
			@ 8.500,  20 GET laLanguage[4,3] SIZE 1, 50 PICTURE "@K"
			@ 9.750,   1 SAY laLanguage[5,2]
			@ 9.750,  20 GET laLanguage[5,3] SIZE 1, 50 PICTURE "@K"
			@ 11,      1 SAY laLanguage[6,2]
			@ 11,     20 GET laLanguage[6,3] SIZE 1, 50 PICTURE "@K"
			@ 12.250,  1 SAY laLanguage[7,2]
			@ 12.250, 20 GET laLanguage[7,3] SIZE 1, 50 PICTURE "@K"
			@ 13.500,  1 SAY laLanguage[8,2]
			@ 13.500, 20 GET laLanguage[8,3] SIZE 1, 50 PICTURE "@K"
			@ 14.750,  1 SAY laLanguage[9,2]
			@ 14.750, 20 GET laLanguage[9,3] SIZE 1, 50 PICTURE "@K"
			READ MODAL
			IF LASTKEY() <> 27
				FOR i = 1 TO 9
					IF NOT EMPTY(laLanguage[i,3])
						INSERT INTO curlanguage (la_label, la_lang, la_prg, la_text) ;
							VALUES (UPPER(tcLabel), laLanguage[i,1], tcProgram, laLanguage[i,3])
						LogData(curlanguage.la_lang+CHR(9)+curlanguage.la_prg+CHR(9)+curlanguage.la_label+CHR(9)+curlanguage.la_text,"Hotel.lng")
					ENDIF
				NEXT
				IF SEEK(PADR(lcLanguage,3)+PADR(tcProgram,8)+PADR(tcLabel,30),"curlanguage","tag1")
					lcText = ALLTRIM(curlanguage.la_text)
				ELSE
					lcText = tcLabel
				ENDIF
			ELSE
				lcText = "? " + lcLanguage + " " + tcProgram + " " + tcLabel
			ENDIF
			DEACTIVATE WINDOW deFinetext
			RELEASE WINDOW deFinetext
		OTHERWISE
	ENDCASE
ENDIF

IF TYPE("gcApplication") = "C"
	lcText = STRTRAN(lcText, "%APP", gcApplication)
ENDIF
IF TYPE("g_lCheckLang") = "L" AND g_lCheckLang AND USED("curlanguage")
	lcText = TRANSFORM(RECNO("curlanguage")) + "-" + lcText
ENDIF
IF tlWithoutLine
	lcText = STRTRAN(lcText, "\<")
ENDIF

SELECT (lnArea)

RETURN lcText
ENDPROC
*
PROCEDURE lSystemAppExists_Assign
LPARAMETERS tlNewVal

IF this.lSystemAppExists AND NOT tlNewVal
	this.lSystemAppExists = tlNewVal
	Alert(GetText("COMMON","TXT_SYSTEMAPP_NOT_EXISTS"))
ENDIF
ENDPROC
*
PROCEDURE Reconfirm
* Do it in default datasession.
LOCAL l_lCancel
DO reConfirm IN Login WITH l_lCancel
RETURN l_lCancel
ENDPROC
*
PROCEDURE CallScript
LPARAMETERS tcCallProc, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10
LOCAL i, luRetVal, lcParams

lcParams = "tcCallProc"
FOR i = 1 TO PCOUNT()-1
	lcParams = lcParams + ", @p" + TRANSFORM(i)
NEXT

luRetVal = EXECSCRIPT(&lcParams)

RETURN luRetVal
ENDPROC
*
FUNCTION CallFunc
LPARAMETERS tcMacro, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10

RETURN &tcMacro
ENDFUNC
*
FUNCTION CallCmd
LPARAMETERS tlRetval, tcMacro, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10
LOCAL luRetVal

IF tlRetval
	luRetVal = &tcMacro
ELSE
	luRetVal = .T.
	&tcMacro
ENDIF

RETURN luRetVal
ENDFUNC
*
PROCEDURE CallProcInDefDS
LPARAMETERS lp_cFuncName, lp_cPrg, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
		 lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
LOCAL l_cCallProc, l_nParamNo, l_uRetVal, l_nNoOfProcParams
l_nNoOfProcParams = PCOUNT()-2
IF EMPTY(lp_cPrg)
	l_cCallProc = lp_cFuncName + "("
	FOR l_nParamNo = 1 TO l_nNoOfProcParams
		l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
	NEXT
	l_cCallProc = l_cCallProc + ")"
	l_uRetVal = &l_cCallProc
ELSE
	l_cCallProc = "DO " + lp_cFuncName + " IN " + lp_cPrg + IIF(l_nNoOfProcParams>0," WITH ","")
	FOR l_nParamNo = 1 TO l_nNoOfProcParams
		l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
	NEXT
	&l_cCallProc
	l_uRetVal = .T.
ENDIF
RETURN l_uRetVal
ENDPROC
*
PROCEDURE ExecStatmentInDefDS
LPARAMETERS lp_cStatment
IF NOT EMPTY(lp_cStatment)
	&lp_cStatment
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE MsgAdd
* Used in automation mode
LPARAMETERS lp_cText
this.cmsglast = this.cmsglast + ALLTRIM(TRANSFORM(lp_cText)) + "|"
ENDPROC
*
PROCEDURE GetOrderExpression
LPARAMETERS tcOrder
LOCAL lnArea, i, lnOrderFldNum, lcOrderExpression, lcField, lcFldOrderExpression

lnArea = SELECT()

IF NOT USED("fields")
	OpenFileDirect(,"fields")
ENDIF

lcOrderExpression = ""
lnOrderFldNum = GETWORDCOUNT(tcOrder,",")
IF lnOrderFldNum < 2
	lcOrderExpression = this.GetFldOrderExpression(tcOrder)
ELSE
	FOR i = 1 TO lnOrderFldNum
		lcField = GETWORDNUM(tcOrder,i,",")
		lcFldOrderExpression = this.GetFldOrderExpression(lcField)
		IF NOT EMPTY(lcFldOrderExpression)
			lcOrderExpression = lcOrderExpression + IIF(EMPTY(lcOrderExpression), "", "__||__") + lcFldOrderExpression
		ENDIF
	NEXT
ENDIF

SELECT(lnArea)

RETURN lcOrderExpression
ENDPROC
*
PROCEDURE GetFldOrderExpression
LPARAMETERS tcField
LOCAL lnArea, lcOrderExpression, lcTblName, lcFldName

lnArea = SELECT()

IF "." $ tcField
	lcTblName = STREXTRACT(tcField,"",".")
	lcFldName = STREXTRACT(tcField,".")
ELSE
	lcTblName = ""
	lcFldName = tcField
ENDIF

lcOrderExpression = ""
IF NOT EMPTY(lcFldName)
	IF EMPTY(lcTblName) OR NOT SEEK(UPPER(PADR(lcTblName,8)+PADR(lcFldName,10)),"fields","tag1")
		DLocate("fields", "UPPER(fd_name) = " + SqlCnv(UPPER(lcFldName)))
	ENDIF
	DO CASE
		CASE fields.fd_type = "C"
			lcOrderExpression = Str2Msg("PADR(%s1,%s2)", "%s", lcFldName, TRANSFORM(fields.fd_len))
		CASE fields.fd_type = "D"
			lcOrderExpression = Str2Msg("DTOS(%s)", "%s", lcFldName)
		CASE fields.fd_type = "I"
			lcOrderExpression = Str2Msg("__STR__(%s,10)", "%s", lcFldName)
		CASE fields.fd_type = "N"
			lcOrderExpression = Str2Msg("__STR__(%s1,%s2)", "%s", lcFldName, TRANSFORM(fields.fd_len+fields.fd_dec+1))
		OTHERWISE
	ENDCASE
ENDIF

SELECT(lnArea)

RETURN lcOrderExpression
ENDPROC
*
PROCEDURE Close_def_table
LPARAMETERS tcAliases
LOCAL i, lcAlias

FOR i = 1 TO GETWORDCOUNT(tcAliases,",")
	lcAlias = ALLTRIM(GETWORDNUM(tcAliases,i,","))
	DClose(lcAlias)
NEXT
ENDPROC
*
PROCEDURE get_room
LPARAMETERS tcWhere, tcFormat, tcIndex

RETURN get_room(tcWhere, tcFormat, tcIndex)
ENDPROC
*
PROCEDURE get_roomtype
LPARAMETERS tcWhere, tcFormat, tcIndex

RETURN get_roomtype(tcWhere, tcFormat, tcIndex)
ENDPROC
*
PROCEDURE get_room_count
LPARAMETERS tcWhere

RETURN get_room_count(tcWhere)
ENDPROC
*
PROCEDURE GetNavPaneIconFileName
LPARAMETERS lp_cFileName
LOCAL l_cFileName
IF NOT EMPTY(lp_cFileName)
	IF this.lNavPaneIconsExternal
		l_cFileName = FULLPATH("external\bitmap\navpane\"+lp_cFileName)
	ELSE
		l_cFileName = "bitmap\navpane\"+lp_cFileName
	ENDIF
ENDIF
RETURN l_cFileName
ENDPROC
*
PROCEDURE SetSystemTime
IF _screen.oGlobal.lusesysdatefrompc
	IF NOT EMPTY(_screen.oglobal.oparam.pa_sysdate) AND _screen.oglobal.oparam.pa_sysdate <> DATE()
		_screen.oglobal.oparam.pa_sysdate = DATE()
		sysdate()
		TRY
			SetStatusBarMessage()
		CATCH
		ENDTRY
	ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE GetBillIdCode
LOCAL l_cIdCode
IF _screen.oGlobal.lResetBillNumberOnNewYear
	l_cIdCode = "BI" + RIGHT(TRANSFORM(YEAR(sysdate())),2)
ELSE
	l_cIdCode = "BILL"
ENDIF
IF this.SelectBuildingOnLoginAllowed() AND NOT EMPTY(this.oBuilding.cbillnumprefix)
	l_cIdCode = l_cIdCode + "@" + this.oBuilding.cbillnumprefix
ENDIF
RETURN l_cIdCode
ENDPROC
*
PROCEDURE GettBillFirst2Numbers
LOCAL l_cAppId
l_cAppId = "22" && Constant, identifies application. But can be used for bulding, to make diffrent bill number for each building!
IF this.SelectBuildingOnLoginAllowed() AND NOT EMPTY(this.oBuilding.cbillnumprefix)
	l_cAppId = this.oBuilding.cbillnumprefix
ENDIF
RETURN l_cAppId
ENDPROC
*
PROCEDURE SelectBuildingForFinance
LPARAMETERS lp_cCode, lp_nBillnumPrefix, lp_cdescription
IF EMPTY(lp_cCode)
	this.oBuilding.ccode = ""
ELSE
	this.oBuilding.ccode = lp_cCode
	this.oBuilding.cdescription = lp_cdescription
ENDIF
IF EMPTY(lp_nBillnumPrefix)
	this.oBuilding.cbillnumprefix = ""
ELSE
	this.oBuilding.cbillnumprefix = TRANSFORM(lp_nBillnumPrefix)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE SelectBuildingOnLoginAllowed
RETURN g_lBuildings AND this.oBuilding.lselectbuildingonlogin
ENDPROC
*
PROCEDURE Grid_Init
LPARAMETERS toForm, toGrid
LOCAL i, lnArea, llShow, llActiv, loGridRec, lnOrder, llChangeDetected, loColumn, loControl AS Control
LOCAL ARRAY laInitialColumnOrder(1)

this.Grid_SetProp(toForm, toGrid)

IF toGrid.SetColumns
	lnArea = SELECT()
	
	this.oGData.CreateCA("Grid",,"gr_user = " + SqlCnv(PADR(g_userid,10),.T.) + " AND gr_label = " + SqlCnv(UPPER(PADR(toGrid.cGridLabelName,30)),.T.))
	FOR EACH loColumn IN toGrid.Columns
		* Save current state from grid object to grid.dbf
		llActiv = (TYPE("loColumn.lActiv") <> "L" OR loColumn.lActiv)
		llShow = (TYPE("loColumn.lShow") <> "L" OR loColumn.lShow)
		DO CASE
			CASE NOT SEEK(UPPER(PADR(g_userid,10)+PADR(toGrid.cGridLabelName,30)+PADR(loColumn.Name,30)), "cagrid", "tag1")
				* If created new columns in development add them to grid.dbf
				SELECT cagrid
				SCATTER MEMO BLANK NAME loGridRec
				loGridRec.gr_grid = NextId("GRID")
				loGridRec.gr_user = g_userid
				loGridRec.gr_label = UPPER(toGrid.cGridLabelName)
				loGridRec.gr_column = loColumn.Name
				loGridRec.gr_order = loColumn.ColumnOrder
				loGridRec.gr_width = loColumn.Width
				loGridRec.gr_activ = llActiv
				loGridRec.gr_show = llShow
				INSERT INTO cagrid FROM NAME loGridRec
				llChangeDetected = .T.
			CASE cagrid.gr_show <> llShow
				REPLACE gr_show WITH llShow, gr_activ WITH llActiv IN cagrid
				llChangeDetected = .T.
			OTHERWISE
		ENDCASE
	NEXT
	SELECT RECNO() FROM cagrid WITH (Buffering = .T.) ORDER BY gr_order INTO ARRAY laInitialColumnOrder
	lnOrder = 0
	FOR i = 1 TO ALEN(laInitialColumnOrder)
		GO laInitialColumnOrder(i) IN cagrid
		DO CASE
			CASE TYPE("toGrid." + ALLTRIM(cagrid.gr_column)) = "O"
				loColumn = EVALUATE("toGrid." + ALLTRIM(cagrid.gr_column))
				loColumn.FontBold = cagrid.gr_usbd
				toGrid.SetColumnProperty(loColumn, "DynamicBackColor", ALLTRIM(TRANSFORM(EVL(cagrid.gr_usdbc,""))))
				toGrid.SetColumnProperty(loColumn, "DynamicForeColor", ALLTRIM(TRANSFORM(EVL(cagrid.gr_usdfc,""))))
			CASE toGrid.lAddUserDefinedColumns
				* Make new user defined columns in grid object
				IF NOT cagrid.gr_show
					REPLACE gr_show WITH .T., gr_activ WITH .T. IN cagrid
					llChangeDetected = .T.
				ENDIF
				this.Grid_AddColumn(toGrid)
				loColumn = EVALUATE("toGrid." + ALLTRIM(cagrid.gr_column))
			OTHERWISE
				* Delete data from grid.dbf for not used columns anymore
				DELETE IN cagrid
				llChangeDetected = .T.
				LOOP
		ENDCASE
		* Set new column order to grid object and grid.dbf
		lnOrder = lnOrder + 1
		IF cagrid.gr_order <> lnOrder
			REPLACE gr_order WITH lnOrder IN cagrid
			llChangeDetected = .T.
		ENDIF
		toGrid.ChangeColumnOrder(loColumn, cagrid.gr_order)
	NEXT

	IF llChangeDetected
		this.oGData.Grid.DoTableUpdate(.T.)
	ENDIF

	SELECT (lnArea)
ENDIF
ENDPROC
*
PROCEDURE Grid_AddColumn
LPARAMETERS toGrid
LOCAL loNewColumn, lcBaseColumnControl, lcBaseColumnControlName

IF TYPE(EVALUATE("cagrid.gr_source")) = "L"
	lcBaseColumnControl = toGrid.p_BaseColumnControl
	lcBaseColumnControlName = toGrid.p_BaseColumnControlName
	toGrid.p_BaseColumnControl = "CheckBox"
	toGrid.p_BaseColumnControlName = "CheckBox1"
	toGrid.ColumnCount = toGrid.ColumnCount + 1
	loNewColumn = toGrid.Columns(toGrid.ColumnCount)
	loNewColumn.CheckBox1.Caption = ""
	loNewColumn.Sparse = .F.
	toGrid.p_BaseColumnControl = lcBaseColumnControl
	toGrid.p_BaseColumnControlName = lcBaseColumnControlName
ELSE
	toGrid.ColumnCount = toGrid.ColumnCount + 1
	loNewColumn = toGrid.Columns(toGrid.ColumnCount)
ENDIF

IF NOT PEMSTATUS(loNewColumn, "cn", 5)
	loNewColumn.AddProperty("cn")
ENDIF
IF NOT PEMSTATUS(loNewColumn, "cw", 5)
	loNewColumn.AddProperty("cw")
ENDIF
IF NOT PEMSTATUS(loNewColumn, "lUDCol", 5)
	loNewColumn.AddProperty("lUDCol")
ENDIF

loNewColumn.Name = ALLTRIM(cagrid.gr_column)
loNewColumn.cn = loNewColumn.Name
loNewColumn.cw = cagrid.gr_width
loNewColumn.lUDCol = .T.
toGrid.SetColumnProperty(loNewColumn, "ControlSource", ALLTRIM(cagrid.gr_source))
loNewColumn.Visible = .T.
ENDPROC
*
PROCEDURE Grid_SetProp
LPARAMETERS toForm AS Form, toGrid AS Grid
LOCAL lnSelect, lnRowHeight, lnHeaderHeight, i
LOCAL ARRAY l_aColumns(1)

IF toGrid.lSetGridProp
	lnSelect = SELECT()

	IF NOT toGrid.AllowHeaderSizing
		toGrid.AllowHeaderSizing = .T.
	ENDIF
	IF NOT toGrid.AllowRowSizing
		toGrid.AllowRowSizing = .T.
	ENDIF
	IF toGrid.ResizeFontSize
		toGrid.ResizeFontSize = .F.
	ENDIF
	IF PEMSTATUS(toForm, "ResizeHeaderFont", 5) AND toForm.ResizeHeaderFont
		toForm.ResizeHeaderFont = .F.
	ENDIF

	lnRowHeight = toGrid.RowHeight
	lnHeaderHeight = toGrid.HeaderHeight
	IF toGrid.FontName <> g_cGridFontName
		toGrid.FontName = g_cGridFontName		&& changes Header.FontName too
	ENDIF
	IF toGrid.FontSize <> g_nGridFontSize
		* Warning! Changing FontSize for grid, resets width for all columns!!!
		IF toGrid.ColumnCount > 0
			DIMENSION l_aColumns(toGrid.ColumnCount)
			FOR i = 1 TO toGrid.ColumnCount
				l_aColumns(i) = toGrid.Columns(i).Width
			ENDFOR
		ENDIF
		toGrid.FontSize = g_nGridFontSize		&& changes Grid.RowHeight, Grid.HeaderHeight and Header.FontSize too
		IF toGrid.ColumnCount > 0
			FOR i = 1 TO toGrid.ColumnCount
				toGrid.Columns(i).Width = l_aColumns(i)
			ENDFOR
		ENDIF
	ENDIF

	this.oGData.CreateCA("Gridprop",,"gp_user = " + SqlCnv(PADR(UPPER(g_userid),10),.T.) + " AND gp_label = " + SqlCnv(PADR(UPPER(toGrid.cGridLabelName),30),.T.))
	IF RECCOUNT("cagridprop") = 0
		toGrid.RowHeight = lnRowHeight
		toGrid.HeaderHeight = lnHeaderHeight
	ELSE
		toGrid.RowHeight = cagridprop.gp_rheight
		toGrid.HeaderHeight = MAX(cagridprop.gp_hheight,19)
	ENDIF

	SELECT (lnSelect)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE Grid_SaveProp
LPARAMETERS toForm, toGrid
LOCAL lnSelect, lcGUser, lcGLabel

IF toGrid.lSetGridProp AND NOT toGrid.SaveGridPropDone
	lnSelect = SELECT()

	lcGLabel = PADR(UPPER(toGrid.cGridLabelName),30)
	lcGUser = PADR(UPPER(g_userid),10)
	this.oGData.CreateCA("Gridprop",,"gp_user = " + SqlCnv(lcGUser,.T.) + " AND gp_label = " + SqlCnv(lcGLabel,.T.))
	SELECT cagridprop
	IF RECCOUNT() = 0
		INSERT INTO cagridprop (gp_user, gp_label) VALUES (lcGUser, lcGLabel)
	ENDIF
	SCATTER NAME loGridprop
	loGridprop.gp_rheight = MIN(125,MAX(15,toGrid.RowHeight))
	loGridprop.gp_hheight = IIF(toGrid.HeaderHeight = 0, 0, MIN(125,MAX(15,toGrid.HeaderHeight)))
	IF RecordChanged(loGridprop, "cagridprop")
		GATHER NAME loGridprop
		this.oGData.Gridprop.DoTableUpdate()
	ENDIF

	toGrid.SaveGridPropDone = .T.

	SELECT (lnSelect)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE Grid_RestoreState
LPARAMETERS toForm, toGrid, toColumn, tlGridDontRefresh

IF toGrid.SaveGridSettings
	this.oGData.CreateCA("Grid",tlGridDontRefresh,"gr_user = " + SqlCnv(PADR(g_userid,10),.T.) + " AND gr_label = " + SqlCnv(UPPER(PADR(toGrid.cGridLabelName,30)),.T.))
	IF SEEK(UPPER(PADR(g_userid,10)+PADR(toGrid.cGridLabelName,30)+PADR(toColumn.Name,30)), "cagrid", "tag1")
		IF INLIST(UPPER(toGrid.cGridLabelName), "GRDBUILDINGS", "GRDROOMTYPES", "GRDHOTELS", "GRDROOMTYPESMP")
			DO CASE
				CASE NOT INLIST(UPPER(toColumn.Name), "GRCFREE", "GRCDEF")
					* hide records if exists in grid.dbf (new availability form, grids: grdBuildings, grdRoomtypes)
					toColumn.Visible = .F.
				CASE UPPER(toColumn.Name) = "GRCDEF" AND UPPER(toGrid.cGridLabelName) = "GRDROOMTYPES" AND _screen.oGlobal.lVehicleRentMode
					LOCAL lnUDColumn
					lnUDColumn = IIF(cagrid.gr_activ, 1002, 1003)
					IF NOT SEEK(UPPER(PADR(g_userid,10)+PADR(toGrid.cGridLabelName,30)+PADR("grcOpt",30)), "cagrid", "tag1") OR NOT cagrid.gr_activ
						toGrid.DoUDColumnPopupMenu(lnUDColumn)
					ENDIF
				CASE NOT cagrid.gr_activ
					toGrid.DoUDColumnPopupMenu(IIF(UPPER(toColumn.Name) = "GRCFREE", 1001, 1002))
				OTHERWISE
			ENDCASE
		ELSE
			toColumn.Width = cagrid.gr_width
			toColumn.Visible = cagrid.gr_activ
			IF toColumn.lUDCol
				toColumn.Header1.Caption = ALLTRIM(cagrid.gr_caption)
				toGrid.SetColumnProperty(toColumn, "ControlSource", ALLTRIM(cagrid.gr_source))
				toColumn.Movable = cagrid.gr_movable
				toColumn.Resizable = cagrid.gr_resize
				toColumn.InputMask = ALLTRIM(cagrid.gr_inpmask)
				toColumn.FontBold = cagrid.gr_bold
				toColumn.Alignment = cagrid.gr_align
				toGrid.SetColumnProperty(toColumn, "DynamicBackColor", ALLTRIM(cagrid.gr_dybaco))
				toGrid.SetColumnProperty(toColumn, "DynamicForeColor", ALLTRIM(cagrid.gr_dyfoco))
			ENDIF
		ENDIF
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE Grid_SaveState
LPARAMETERS toForm, toGrid, toColumn, tlGridDontRefresh
LOCAL lnWidth, llChangeDetected, llRows, lChanged

IF toGrid.SaveGridSettings
	this.oGData.CreateCA("Grid",tlGridDontRefresh,"gr_user = " + SqlCnv(PADR(g_userid,10),.T.) + " AND gr_label = " + SqlCnv(UPPER(PADR(toGrid.cGridLabelName,30)),.T.))
	IF INLIST(UPPER(toGrid.cGridLabelName), "GRDBUILDINGS", "GRDROOMTYPES", "GRDHOTELS", "GRDROOMTYPESMP")
		DO CASE
			CASE NOT INLIST(UPPER(toColumn.Name), "GRCFREE", "GRCDEF")
				* insert only hidden records (new availability form, grids: grdBuildings, grdRoomtypes)
				IF toColumn.Visible = SEEK(UPPER(PADR(g_userid,10)+PADR(toGrid.cGridLabelName,30)+PADR(toColumn.Name,30)), "cagrid", "Tag1")
					IF toColumn.Visible
						DELETE IN cagrid
					ELSE
						INSERT INTO cagrid (gr_grid, gr_user, gr_label, gr_column) VALUES (NextId("GRID"), g_userid, UPPER(toGrid.cGridLabelName), toColumn.Name)
					ENDIF
					llChangeDetected = .T.
				ENDIF
			CASE UPPER(toColumn.Name) = "GRCDEF" AND UPPER(toGrid.cGridLabelName) = "GRDROOMTYPES" AND _screen.oGlobal.lVehicleRentMode
				LOCAL i, lcColumnName, llActive
				llRows = .T.
				FOR i = 1 TO 2
					lcColumnName = IIF(i = 1, "grcDef", "grcOpt")
					llActive = toColumn.Visible AND (toForm.lShowOpt = (lcColumnName = "grcOpt"))
					DO CASE
						CASE NOT SEEK(UPPER(PADR(g_userid,10)+PADR(toGrid.cGridLabelName,30)+PADR(lcColumnName,30)), "cagrid", "tag1")
							INSERT INTO cagrid (gr_grid, gr_user, gr_label, gr_column, gr_activ) VALUES (NextId("GRID"), g_userid, UPPER(toGrid.cGridLabelName), lcColumnName, llActive)
							llChangeDetected = .T.
						CASE cagrid.gr_activ <> llActive
							REPLACE gr_activ WITH llActive IN cagrid
							llChangeDetected = .T.
						OTHERWISE
					ENDCASE
				NEXT
			CASE NOT SEEK(UPPER(PADR(g_userid,10)+PADR(toGrid.cGridLabelName,30)+PADR(toColumn.Name,30)), "cagrid", "tag1")
				INSERT INTO cagrid (gr_grid, gr_user, gr_label, gr_column, gr_activ) VALUES (NextId("GRID"), g_userid, UPPER(toGrid.cGridLabelName), toColumn.Name, toColumn.Visible)
				llChangeDetected = .T.
			CASE cagrid.gr_activ <> toColumn.Visible
				REPLACE gr_activ WITH toColumn.Visible IN cagrid
				llChangeDetected = .T.
			OTHERWISE
		ENDCASE
	ELSE
		IF SEEK(UPPER(PADR(g_userid,10)+PADR(toGrid.cGridLabelName,30)+PADR(toColumn.Name,30)), "cagrid", "tag1")
			* save width of columns with resize factor
			IF toGrid.lResizeColumns
				lnWidth = ROUND(toColumn.Width*(toGrid.w-17)/(toGrid.Width-17), 0)
			ELSE
				lnWidth = toColumn.Width
			ENDIF
			IF cagrid.gr_width <> lnWidth
				REPLACE gr_width WITH lnWidth IN cagrid
				llChangeDetected = .T.
			ENDIF
			IF cagrid.gr_order <> toColumn.ColumnOrder
				REPLACE gr_order WITH toColumn.ColumnOrder IN cagrid
				llChangeDetected = .T.
			ENDIF
			IF cagrid.gr_activ <> toColumn.Visible
				REPLACE gr_activ WITH toColumn.Visible IN cagrid
				llChangeDetected = .T.
			ENDIF
		ENDIF
	ENDIF
	IF llChangeDetected
		this.oGData.Grid.DoTableUpdate(llRows)
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE Grid_GetColumnProperty
LPARAMETERS toGrid, toColumn, tcProperty, tlGridDontRefresh
LOCAL lcGridLabelName, luRetval

lcGridLabelName = ICASE(VARTYPE(toGrid) = "C", toGrid, TYPE("toGrid.cGridLabelName") = "C", toGrid.cGridLabelName, "")
this.oGData.CreateCA("Grid", tlGridDontRefresh, "gr_user = " + SqlCnv(PADR(g_userid,10),.T.) + " AND gr_label = " + SqlCnv(UPPER(PADR(lcGridLabelName,30)),.T.))
luRetval = .NULL.
TRY
	luRetval = DLookUp("cagrid", "UPPER(gr_user+gr_label+gr_column) = " + SqlCnv(UPPER(PADR(g_userid,10)+PADR(lcGridLabelName,30)+PADR(toColumn.Name,30))), tcProperty)
CATCH
ENDTRY

RETURN luRetval
ENDPROC
*
PROCEDURE GridScreen_RestoreDefaults
LOCAL lcurUser, lcurSuperScreens, lcurSuperGrid, lcurSuperGridprop

this.oGData.CreateCA("Screens",,"")
this.oGData.CreateCA("Grid",,"")
this.oGData.CreateCA("Gridprop",,"")
lcurSuperScreens = SYS(2015)
SELECT * FROM cascreens WHERE sc_userid = "SUPERVISOR" INTO CURSOR &lcurSuperScreens
lcurSuperGrid = SYS(2015)
SELECT * FROM cagrid WHERE gr_user = "SUPERVISOR" INTO CURSOR &lcurSuperGrid
lcurSuperGridprop = SYS(2015)
SELECT * FROM cagridprop WHERE gp_user = "SUPERVISOR" INTO CURSOR &lcurSuperGridprop
DO CASE
	CASE RECCOUNT(lcurSuperScreens) = 0
		Alert(GetLangText("FUNC", "TXT_NOSUPERINSCREEN"))		&&"Not found SUPERVISOR USER in screen.dbf!"
	CASE RECCOUNT(lcurSuperGrid) = 0
		Alert(GetLangText("FUNC", "TXT_NOSUPERINGRID"))		&&"Not found SUPERVISOR USER in grid.dbf!"
	CASE RECCOUNT(lcurSuperGridprop) = 0
		Alert(GetLangText("FUNC", "TXT_NOSUPERINGRIDPROP"))	&&"Not found SUPERVISOR USER in gridprop.dbf!"
	OTHERWISE
		WAIT GetLangText("COMMON", "T_PLEASEWAIT") WINDOW NOWAIT
		lcurUser = SqlCursor([SELECT us_id FROM "user" WHERE NOT us_id IN ('SUPERVISOR', '          ')])
		SCAN
			SELECT &lcurSuperScreens
			SCAN
				SCATTER MEMO MEMVAR
				m.sc_userid = &lcurUser..us_id
				IF SEEK(m.sc_label+m.sc_userid,"cascreens","tag1")
					SELECT cascreens
					GATHER MEMVAR MEMO
					SELECT &lcurSuperScreens
				ELSE
					INSERT INTO cascreens FROM MEMVAR
				ENDIF
			ENDSCAN
			SELECT &lcurSuperGrid
			SCAN
				SCATTER MEMO MEMVAR
				m.gr_user = &lcurUser..us_id
				IF SEEK(UPPER(m.gr_user+m.gr_label+m.gr_column),"cagrid","tag1")
					SELECT cagrid
					m.gr_grid = gr_grid
					GATHER MEMVAR MEMO
					SELECT &lcurSuperGrid
				ELSE
					m.gr_grid = NextId("GRID")
					INSERT INTO cagrid FROM MEMVAR
				ENDIF
			ENDSCAN
			SELECT &lcurSuperGridprop
			SCAN
				SCATTER MEMO MEMVAR
				m.gp_user = &lcurUser..us_id
				IF DLocate("cagridprop", "gp_user = " + SqlCnv(m.gp_user) + " AND gp_label = " + SqlCnv(m.gp_label))
					SELECT cagridprop
					GATHER MEMVAR MEMO
					SELECT &lcurSuperGridprop
				ELSE
					INSERT INTO cagridprop FROM MEMVAR
				ENDIF
			ENDSCAN
			SELECT &lcurUser
		ENDSCAN
		this.oGData.Screens.DoTableUpdate(.T.,.T.)
		this.oGData.Grid.DoTableUpdate(.T.,.T.)
		this.oGData.Gridprop.DoTableUpdate(.T.)
		DClose(lcurUser)
		WAIT CLEAR
ENDCASE
DClose(lcurSuperScreens)
DClose(lcurSuperGrid)
DClose(lcurSuperGridprop)
ENDPROC
*
PROCEDURE Screen_RestoreState
LPARAMETERS toForm, tlDontResize, tlDontRefresh, tlNoWhRatio
LOCAL lnArea, lcFormLabel, lnScreenWidth, lnScreenHeight, lnTop, lnLeft, lnWidth, lnHeight

IF VARTYPE(toForm) = "O" AND toForm.SaveFormSize
	lnArea = SELECT()

	IF NOT PEMSTATUS(toForm,"oScreens",5)
		toForm.AddProperty("oScreens")
	ENDIF

	lcFormLabel = this.Screen_GetFormLabel(toForm)

	this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(PADR(g_userid,10),.T.) + " AND sc_label = " + SqlCnv(lcFormLabel,.T.))
	SELECT cascreens
	IF NOT SEEK(lcFormLabel,"cascreens","tag2")
		SCATTER BLANK NAME toForm.oScreens
		toForm.oScreens.sc_userid = PADR(g_userid,10)
		toForm.oScreens.sc_label = lcFormLabel
		IF NOT tlDontRefresh
			toForm.Refresh()
		ENDIF
	ELSE
		SCATTER NAME toForm.oScreens
		lnScreenWidth = _screen.Width - 8
		lnScreenHeight = _screen.Height - 27
		lnTop = toForm.oScreens.sc_top
		lnLeft = toForm.oScreens.sc_left
		IF tlNoWhRatio
			lnWidth = toForm.oScreens.sc_width
			lnHeight = toForm.oScreens.sc_height
		ELSE
			lnWidth = ROUND(toForm.w * IIF(EMPTY(toForm.oScreens.sc_fw), 1, toForm.oScreens.sc_fw), 0)
			lnHeight = ROUND(toForm.h * IIF(EMPTY(toForm.oScreens.sc_fh), 1, toForm.oScreens.sc_fh), 0)
		ENDIF
		IF toForm.AutoCenter
			lnTop = ROUND((lnScreenHeight - lnHeight) / 2, 0)
			lnLeft = ROUND((lnScreenWidth - lnWidth) / 2, 0)
		ENDIF
		IF lnWidth > lnScreenWidth
			lnLeft = 1
			lnWidth = lnScreenWidth
		ENDIF
		IF lnHeight > lnScreenHeight
			lnTop = 1
			lnHeight = lnScreenHeight
		ENDIF
		toForm.Top = lnTop
		toForm.Left = lnLeft
		toForm.Width = lnWidth
		toForm.Height = lnHeight
		IF toForm.oScreens.sc_maxi
			toForm.WindowState = 2
			IF NOT tlDontResize
				toForm.Resize(lnScreenWidth, lnScreenHeight)
			ENDIF
		ELSE
			IF NOT tlDontResize
				toForm.Resize()
			ENDIF
		ENDIF
	ENDIF

	SELECT (lnArea)
ENDIF
ENDPROC
*
PROCEDURE Screen_SaveState
LPARAMETERS toForm
LOCAL lnArea

* check if there are some changes
IF VARTYPE(toForm) = "O" AND toForm.SaveFormSize
	lnArea = SELECT()

	toForm.oScreens.sc_userid = PADR(g_userid,10)
	toForm.oScreens.sc_label = this.Screen_GetFormLabel(toForm)
	toForm.oScreens.sc_maxi = (toForm.WindowState = 2)
	IF toForm.oScreens.sc_maxi
		toForm.oScreens.sc_top = IIF(TYPE("toForm.t") = "N", toForm.t, 0)
		toForm.oScreens.sc_left = IIF(TYPE("toForm.l") = "N", toForm.l, 0)
		toForm.oScreens.sc_width = IIF(TYPE("toForm.w") = "N", toForm.w, 0)
		toForm.oScreens.sc_height = IIF(TYPE("toForm.h") = "N", toForm.h, 0)
		toForm.oScreens.sc_fw = 0
		toForm.oScreens.sc_fh = 0
	ELSE
		toForm.oScreens.sc_top = toForm.Top
		toForm.oScreens.sc_left = toForm.Left
		toForm.oScreens.sc_width = toForm.Width
		toForm.oScreens.sc_height = toForm.Height
		toForm.oScreens.sc_fw = IIF(TYPE("toForm.w") = "N" AND toForm.w > 0, ROUND(toForm.Width/toForm.w,4), 0)
		toForm.oScreens.sc_fh = IIF(TYPE("toForm.h") = "N" AND toForm.h > 0, ROUND(toForm.Height/toForm.h,4), 0)
	ENDIF
	this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(toForm.oScreens.sc_userid,.T.) + " AND sc_label = " + SqlCnv(toForm.oScreens.sc_label,.T.))
	IF NOT SEEK(toForm.oScreens.sc_label,"cascreens","tag2")
		INSERT INTO cascreens (sc_userid, sc_label) VALUES (toForm.oScreens.sc_userid, toForm.oScreens.sc_label)
	ENDIF
	IF RecordChanged(toForm.oScreens, "cascreens")
		SELECT cascreens
		GATHER NAME toForm.oScreens MEMO
		this.oGData.Screens.DoTableUpdate()
	ENDIF

	SELECT (lnArea)
ENDIF
ENDPROC
*
PROCEDURE Screen_GetFormLabel
LPARAMETERS toForm
LOCAL lcFormLabel

DO CASE
	CASE TYPE("toForm.cFormLabel") = "C" AND NOT EMPTY(toForm.cFormLabel)
		lcFormLabel = toForm.cFormLabel
	CASE TYPE("toForm.Parent") = "O"
		lcFormLabel = toForm.Parent.Name + toForm.Name
	OTHERWISE
		lcFormLabel = toForm.Name
ENDCASE
lcFormLabel = UPPER(PADR(lcFormLabel,20))

RETURN lcFormLabel
ENDPROC
*
PROCEDURE Toolbar_RestoreState
LPARAMETERS tlSmallButtons
LOCAL lnArea

lnArea = SELECT()

this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(PADR(g_userid,10),.T.) + " AND sc_label = " + SqlCnv(PADR(SCREENS_TOOLBAR,20),.T.))
IF SEEK(PADR(SCREENS_TOOLBAR,20),"cascreens","tag2")
	tlSmallButtons = cascreens.sc_usset1
ENDIF

SELECT (lnArea)
ENDPROC
*
PROCEDURE Toolbar_SaveState
LPARAMETERS tlSmallButtons
LOCAL lnArea, loScreens

lnArea = SELECT()

this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(PADR(g_userid,10),.T.) + " AND sc_label = " + SqlCnv(PADR(SCREENS_TOOLBAR,20),.T.))
IF NOT SEEK(PADR(SCREENS_TOOLBAR,20),"cascreens","tag2")
	INSERT INTO cascreens (sc_userid, sc_label) VALUES (g_userid, SCREENS_TOOLBAR)
ENDIF

SELECT cascreens
SCATTER FIELDS sc_userid, sc_label, sc_usset1 MEMO NAME loScreens
loScreens.sc_usset1 = tlSmallButtons

IF RecordChanged(loScreens, "cascreens")
	SELECT cascreens
	GATHER NAME loScreens MEMO
	this.oGData.Screens.DoTableUpdate()
ENDIF

SELECT (lnArea)
ENDPROC
*
PROCEDURE Navpane_RestoreState
LPARAMETERS tcFieldName, tuValue
LOCAL lnArea

lnArea = SELECT()

this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(PADR(g_userid,10),.T.) + " AND sc_label = " + SqlCnv(PADR("FRMNAVPANE",20),.T.))
IF SEEK(PADR("FRMNAVPANE",20),"cascreens","tag2")
	tuValue = cascreens.&tcFieldName
ENDIF

SELECT (lnArea)

RETURN tuValue
ENDPROC
*
PROCEDURE Navpane_SaveState
LPARAMETERS tcFieldName, tuValue
LOCAL lnArea, loScreens

lnArea = SELECT()

this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(PADR(g_userid,10),.T.) + " AND sc_label = " + SqlCnv(PADR("FRMNAVPANE",20),.T.))
IF NOT SEEK(PADR("FRMNAVPANE",20),"cascreens","tag2")
	INSERT INTO cascreens (sc_userid, sc_label) VALUES (g_userid, "FRMNAVPANE")
ENDIF

SELECT cascreens
SCATTER FIELDS sc_userid, sc_label, &tcFieldName MEMO NAME loScreens
loScreens.&tcFieldName = tuValue

IF RecordChanged(loScreens, "cascreens")
	SELECT cascreens
	GATHER NAME loScreens MEMO
	this.oGData.Screens.DoTableUpdate()
ENDIF

SELECT (lnArea)
ENDPROC
*
PROCEDURE Mydesk_RestoreState
LPARAMETERS toSettings
LOCAL lnArea, llExist

lnArea = SELECT()

toSettings = MakeStructure("nShowNotes, nShowActions, nShowWeather, nShowHotstat, nShowTwitter")

this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(PADR(g_userid,10),.T.) + " AND sc_label = " + SqlCnv(PADR("MYDESK",20),.T.))
IF SEEK(PADR("MYDESK",20),"cascreens","tag2") AND NOT EMPTY(cascreens.sc_ussets)
	llExist = .T.
	toSettings.nShowNotes = INT(VAL(SUBSTR(cascreens.sc_ussets,1,1)))
	toSettings.nShowActions = INT(VAL(SUBSTR(cascreens.sc_ussets,2,1)))
	toSettings.nShowWeather = INT(VAL(SUBSTR(cascreens.sc_ussets,3,1)))
	toSettings.nShowHotstat = INT(VAL(SUBSTR(cascreens.sc_ussets,4,1)))
	toSettings.nShowTwitter = INT(VAL(SUBSTR(cascreens.sc_ussets,5,1)))
ELSE
	STORE 1 TO toSettings.nShowNotes, toSettings.nShowActions, toSettings.nShowWeather, toSettings.nShowHotstat, toSettings.nShowTwitter
ENDIF

SELECT (lnArea)

RETURN llExist
ENDPROC
*
PROCEDURE Mydesk_SaveState
LOCAL lnArea, loScreens, loSettings, lcSetOld, lcSetNew, llOK, llExist, llRefresh

STORE REPLICATE("0",5) TO lcSetOld, lcSetNew

llExist = this.Mydesk_RestoreState(@loSettings)
lcSetOld = STUFF(lcSetOld,1,1,TRANSFORM(loSettings.nShowNotes))
lcSetOld = STUFF(lcSetOld,2,1,TRANSFORM(loSettings.nShowActions))
lcSetOld = STUFF(lcSetOld,3,1,TRANSFORM(loSettings.nShowWeather))
lcSetOld = STUFF(lcSetOld,4,1,TRANSFORM(loSettings.nShowHotstat))
lcSetOld = STUFF(lcSetOld,5,1,TRANSFORM(loSettings.nShowTwitter))

DO FORM Forms\MyDeskSettingsForm WITH loSettings TO llOK
IF llOK
	lcSetNew = STUFF(lcSetNew,1,1,TRANSFORM(loSettings.nShowNotes))
	lcSetNew = STUFF(lcSetNew,2,1,TRANSFORM(loSettings.nShowActions))
	lcSetNew = STUFF(lcSetNew,3,1,TRANSFORM(loSettings.nShowWeather))
	lcSetNew = STUFF(lcSetNew,4,1,TRANSFORM(loSettings.nShowHotstat))
	lcSetNew = STUFF(lcSetNew,5,1,TRANSFORM(loSettings.nShowTwitter))
	* First check if settings are changed
	llRefresh = NOT lcSetOld == lcSetNew
ENDIF

IF NOT llExist OR llRefresh
	lnArea = SELECT()

	this.oGData.CreateCA("Screens",,"sc_userid = " + SqlCnv(PADR(g_userid,10),.T.) + " AND sc_label = " + SqlCnv(PADR("MYDESK",20),.T.))
	IF NOT SEEK(PADR("MYDESK",20),"cascreens","tag2")
		INSERT INTO cascreens (sc_userid, sc_label) VALUES (g_userid, "MYDESK")
	ENDIF

	SELECT cascreens
	SCATTER FIELDS sc_userid, sc_label, sc_ussets MEMO NAME loScreens
	loScreens.sc_ussets = lcSetNew

	IF RecordChanged(loScreens, "cascreens")
		SELECT cascreens
		GATHER NAME loScreens MEMO
		this.oGData.Screens.DoTableUpdate()
	ENDIF

	SELECT (lnArea)
ENDIF

RETURN llRefresh
ENDPROC
*
PROCEDURE GetExtServerName
LPARAMETERS lp_nServerID
IF BETWEEN(lp_nServerID,1,ALEN(this.aExtserver))
	RETURN this.aExtserver(lp_nServerID)
ELSE
	RETURN ""
ENDIF
ENDPROC
*
ENDDEFINE
*
***********************************************************
*
DEFINE CLASS cBillData AS Custom
*
nAddrId = 0
nApId = 0
nBillType = 0
dVatCutDate = {^2010-1-1} && Constant, date from when bills are shown with split articles when pa_country = "D"
nReserId = 0
nWindow = 0
cArtForClause = ""
cProformaInvoiceNo = ""
cUserId = ""
cUserName = ""
lActive = .F.
cElPaySlip = ""
cElPayCashierSlip = ""
*
PROCEDURE SetUser
LPARAMETERS lp_cBillNum
STORE "" TO this.cUserId, this.cUserName
IF NOT EMPTY(lp_cBillNum)
	this.cUserId = dlookup("billnum","bn_billnum = " + sqlcnv(lp_cBillNum,.T.),"bn_userid")
ENDIF
IF EMPTY(this.cUserId)
	this.cUserId = g_userid
ENDIF
this.cUserName = dlookup("user","us_id = " + sqlcnv(PADR(this.cUserId,10),.T.),"us_name")
IF EMPTY(this.cUserName)
	this.cUserName = PROPER(this.cUserId)
ENDIF
RETURN .T.
ENDPROC
*
&& SetElPaySlip gets Elpay payment slip for first ElPay payment in bill, and stores it in cElPaySlip property.
&& _screen.oGlobal.oBill.cElPaySlip can be used from bill1.frx report.
PROCEDURE SetElPaySlip
LPARAMETERS lp_cBillBillNum, lp_lHistory
LOCAL l_nSelect, l_cCur, l_cWhere

this.ResetElPaySlip()

IF NOT _screen.oGlobal.lelPay
	RETURN .T.
ENDIF

l_nSelect = SELECT()

l_cWhere = this.SetElPaySlip_GetWhere(lp_cBillBillNum, lp_lHistory)

IF lp_lHistory
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT el_print ;
		FROM histpost ;
		INNER JOIN elpay ON hp_postid = el_postid ;
		WHERE <<l_cWhere>> ;
		ORDER BY hp_postid ASC
	ENDTEXT
ELSE
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT el_print ;
		FROM post ;
		INNER JOIN elpay ON ps_postid = el_postid ;
		WHERE <<l_cWhere>> ;
		ORDER BY ps_postid ASC
	ENDTEXT
ENDIF

l_cCur = sqlcursor(l_cSql,,,,,.T.)

SCAN FOR NOT EMPTY(el_print)
	this.SetElPaySlip_Parse()
	EXIT
ENDSCAN

dclose(l_cCur)

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
&& ResetElPaySlip sets value to empty string
PROCEDURE ResetElPaySlip
this.cElPaySlip = ""
this.cElPayCashierSlip = ""
RETURN .T.
ENDPROC
*
&& SetElPaySlip_GetWhere returns where clause to select records from post and elpay tables
PROCEDURE SetElPaySlip_GetWhere
LPARAMETERS lp_cBillBillNum, lp_lHistory
LOCAL l_cWhere, l_cPasserByPaymentsCur

IF EMPTY(lp_cBillBillNum)
	* Filter on reserid and window
	IF lp_lHistory
		TEXT TO l_cWhere TEXTMERGE NOSHOW PRETEXT 15
		hp_reserid = <<sqlcnv(this.nReserId,.T.)>> AND hp_window = <<sqlcnv(this.nWindow,.T.)>> AND hp_paynum > 0 AND NOT hp_cancel
		ENDTEXT
	ELSE
		TEXT TO l_cWhere TEXTMERGE NOSHOW PRETEXT 15
		ps_reserid = <<sqlcnv(this.nReserId,.T.)>> AND ps_window = <<sqlcnv(this.nWindow,.T.)>> AND ps_paynum > 0 AND NOT ps_cancel
		ENDTEXT
	ENDIF
	RETURN l_cWhere
ENDIF

* Filter on billnum
IF lp_lHistory
	TEXT TO l_cWhere TEXTMERGE NOSHOW PRETEXT 15
	hp_billnum = '<<lp_cBillBillNum>>' AND hp_paynum > 0 AND NOT hp_cancel
	ENDTEXT
ELSE
	TEXT TO l_cWhere TEXTMERGE NOSHOW PRETEXT 15
	ps_billnum = '<<lp_cBillBillNum>>' AND ps_paynum > 0 AND NOT ps_cancel
	ENDTEXT
ENDIF

RETURN l_cWhere
ENDPROC
*
&& SetElPaySlip_Parse reads slip from el_print cursor field, removes blank lines,
&& and copies only slip part between two S markers into cElPaySlip property
PROCEDURE SetElPaySlip_Parse
	LOCAL l_nLines, l_lSlipBegin, i, l_cLine, l_cPrintMark
	LOCAL ARRAY l_aLines(1)

	l_nLines = ALINES(l_aLines, el_print)

	FOR i = 1 TO l_nLines
		l_cLine = ALLTRIM(l_aLines(i))
		IF EMPTY(l_cLine)
			LOOP
		ENDIF
		l_cPrintMark = STREXTRACT(l_cLine,"",";")
		IF l_cPrintMark = "S"
			IF NOT l_lSlipBegin
				l_lSlipBegin = .T.
			ENDIF
			LOOP
		ENDIF
		IF NOT l_lSlipBegin
			this.cElPayCashierSlip = this.cElPayCashierSlip + l_cLine + CHR(13) + CHR(10)
			LOOP
		ENDIF
		this.cElPaySlip = this.cElPaySlip + l_cLine + CHR(13) + CHR(10)
	ENDFOR

	RETURN .T.
ENDPROC
*
ENDDEFINE
*
***********************************************************
*
DEFINE CLASS cGData AS Custom
DIMENSION aCurHandles(1)
*
PROCEDURE CreateCA
LPARAMETERS tcTable, tlDontCursorFill, tcWhere, tcAlias

IF NOT PEMSTATUS(this, tcTable, 5)
	tlDontCursorFill = .F.
	this.AddProperty(tcTable, CREATEOBJECT("ca"+tcTable))
	this.&tcTable..lCreateIndexes = .T.
ENDIF
IF NOT EMPTY(tcAlias)
	this.&tcTable..Alias = tcAlias
ENDIF
IF PCOUNT() > 2
	this.&tcTable..cFilterClause = tcWhere
ENDIF
this.&tcTable..CursorQuery(NOT tlDontCursorFill)
ENDPROC
*
PROCEDURE dlookupb
LPARAMETERS pcalias, pcwhere, pcexpr
LOCAL uret, narea, nrec, curname
uret = .NULL.
narea = SELECT()
IF openfile(.F., pcalias)
	IF INLIST(UPPER(PADR(pcalias,8)), "ROOM    ", "ROOMTYPE")
		uret = DLookUp(pcalias, pcwhere, pcexpr)
	ELSE
		curname = sqlcursor([SELECT ] + pcexpr + [ AS vResult FROM ] + this.CheckTableName(pcalias) + [ WHERE ] + pcwhere)
		IF USED(curname)
			SELECT (curname)
			uret = vResult
			dclose(curname)
		ENDIF
	ENDIF
ENDIF
SELECT(narea)
RETURN uret
ENDPROC
*
PROCEDURE DbLookup
LPARAMETERS caLias, ctAg, csEekexpression, crEturnexpression, lkEeprec
LOCAL uret

IF USED(caLias)
	uret = DbLookup(caLias, ctAg, csEekexpression, crEturnexpression, lkEeprec, .T.)
ELSE
	uret = .NULL.
ENDIF

RETURN uret
ENDPROC
*
PROCEDURE CheckTableName
LPARAMETERS pctbname
pctbname = LOWER(pctbname)
IF INLIST(PADR(pctbname,8),"user    ","order    ","check   ","table   ","group   ")
	pctbname = '"'+pctbname+'"'
ENDIF
RETURN pctbname
ENDPROC
*
PROCEDURE GetHandle
LPARAMETERS lp_lExternalODBC
LOCAL nConn, i, nActive, cHotCode, nHandle, nRow

nConn = 0
nActive = ASQLHANDLES(aCurHandles)
IF nActive > 0
	cHotCode = ICASE(lp_lExternalODBC, "ARG_EXT", TYPE("pcHotCode")="C" AND NOT EMPTY(pcHotCode), pcHotCode, TYPE("gcHotCode")="C" AND NOT EMPTY(gcHotCode), gcHotCode, "")
	FOR i = 1 TO nActive
		nHandle = aCurHandles(i)
		nRow = ASCAN(this.aCurHandles,nHandle,1,0,1,8)
		IF (EMPTY(cHotCode) OR nRow > 0 AND UPPER(this.aCurHandles(nRow,2)) == UPPER(cHotCode)) AND NOT SQLGETPROP(nHandle,"ConnectBusy")
			nConn = nHandle
		ENDIF
	ENDFOR
ENDIF
IF EMPTY(nConn)
	nConn = this.NewConnection(,lp_lExternalODBC)
ENDIF
RETURN nConn
ENDPROC
*
PROCEDURE Reconnected
LPARAMETERS lp_lExternalODBC
LOCAL nRetVal, nHandle, cCursor, lReconnected

cCursor = SYS(2015)
nRetVal = -1
nSeconds = SECONDS()
DO WHILE SECONDS() <= nSeconds + this.Parent.nODBCDReconnectTimeout
	nHandle = this.GetHandle(lp_lExternalODBC)
	IF nHandle > 0
		nRetVal = SQLEXEC(nHandle, "SELECT 1", cCursor)
		IF nRetVal < 0
			lReconnected = .T.
			SQLDISCONNECT(nHandle)
			FNDoEvents()
		ELSE
			EXIT
		ENDIF
	ENDIF
ENDDO
IF nRetVal < 0
	ERROR(1104)	&& Error reading file "file". (Error 1104)
ENDIF

DClose(cCursor)

RETURN lReconnected
ENDPROC
*
PROCEDURE DisconnectIdleHandle
LPARAMETERS lp_nHandle
IF NOT EMPTY(lp_nHandle)
	TRY
		SQLIDLEDISCONNECT(lp_nHandle)
	CATCH
	ENDTRY
ENDIF
ENDPROC
*
PROCEDURE ReleaseHandles
LPARAMETERS lp_lNotAll
LOCAL i

IF lp_lNotAll
	FOR i = 1 TO ASQLHANDLES(aCurHandles)
		IF 0 < ASCAN(this.aCurHandles,aCurHandles(i),1,0,1,8)
			SQLDISCONNECT(aCurHandles(i))
		ENDIF
	NEXT
ELSE
	SQLDISCONNECT(0)
ENDIF
DIMENSION this.aCurHandles(1)
STORE 0 TO this.aCurHandles

RETURN .T.
ENDPROC
*
PROCEDURE ReleaseHandle
LPARAMETERS pnHandle
* Leave always one handle
LOCAL nActive, i, j
nActive = ASQLHANDLES(aCurHandles)
IF nActive > 1
	FOR i = 2 TO nActive
		IF aCurHandles(i) = pnHandle
			SQLDISCONNECT(aCurHandles(i))
			FOR j = 1 TO ALEN(this.aCurHandles,1)
				IF this.aCurHandles(j,1) = pnHandle
					ADEL(this.aCurHandles,j)
					DIMENSION this.aCurHandles(ALEN(this.aCurHandles,1)-1,ALEN(this.aCurHandles,2))
					EXIT
				ENDIF
			ENDFOR
			EXIT
		ENDIF
	ENDFOR
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE NewConnection
LPARAMETERS lp_lExclusive, lp_lExternalODBC
LOCAL nConn, nResult, lShared, cHotCode, cDatabase, nRows, cConString

lShared = NOT lp_lExclusive
DO CASE
	CASE lp_lExternalODBC AND NOT EMPTY(this.Parent.cODBCArgusDriver) AND NOT EMPTY(this.Parent.cODBCArgusServer) AND NOT EMPTY(this.Parent.cODBCArgusPort)
		TEXT TO cConString TEXTMERGE NOSHOW PRETEXT 15
		Driver={<<this.Parent.cODBCArgusDriver>>};
		Uid=postgres;Pwd=<<_screen.oGlobal.cODBCArgusPswd>>;DATABASE=<<IIF(EMPTY(this.Parent.cODBCArgusDatabase),'postgres',this.Parent.cODBCArgusDatabase)>>;
		SERVER=<<this.Parent.cODBCArgusServer>>;PORT=<<this.Parent.cODBCArgusPort>>;
		CA=d;A6=;A7=100;A8=4096;B0=255;B1=8190;BI=2;C2=dd_;;CX=1b102bb;A1=7.4-1
		ENDTEXT
		nConn = SQLSTRINGCONNECT(cConString,lShared)
	CASE NOT EMPTY(this.Parent.cODBCDriverName) AND NOT EMPTY(this.Parent.cODBCServer) AND NOT EMPTY(this.Parent.cODBCPort)
		TEXT TO cConString TEXTMERGE NOSHOW PRETEXT 15
		Driver={<<this.Parent.cODBCDriverName>>};
		Uid=postgres;Pwd=zimnicA$2001;DATABASE=<<IIF(EMPTY(this.Parent.cODBCDatabase),'postgres',this.Parent.cODBCDatabase)>>;
		SERVER=<<this.Parent.cODBCServer>>;PORT=<<this.Parent.cODBCPort>>;
		CA=d;A6=;A7=100;A8=4096;B0=255;B1=8190;BI=2;C2=dd_;;CX=1b102bb;A1=7.4-1
		ENDTEXT
		nConn = SQLSTRINGCONNECT(cConString,lShared)
	OTHERWISE
		nConn = SQLCONNECT(this.Parent.cODBCDSN,"","",lShared)
ENDCASE

IF nConn > 0
	*cConString = SQLGETPROP(nConn,"ConnectString")
	cHotCode = ICASE(lp_lExternalODBC, "ARG_EXT", TYPE("pcHotCode")="C" AND NOT EMPTY(pcHotCode), pcHotCode, TYPE("gcHotCode")="C" AND NOT EMPTY(gcHotCode), gcHotCode, "")
	cDatabase = IIF(lp_lExternalODBC, "argus", "desk"+IIF(EMPTY(cHotCode), "", "_")+cHotCode)
	nResult = SQLEXEC(nConn,"SET search_path = "+cDatabase+", pg_catalog;")
	nRows = IIF(ALEN(this.aCurHandles)=1, 0, ALEN(this.aCurHandles,1)) + 1
	DIMENSION this.aCurHandles(nRows,2)
	this.aCurHandles(nRows,1) = nConn
	this.aCurHandles(nRows,2) = cHotCode
ELSE
	nResult = -1
ENDIF
IF nResult<0
	ASSERT .F. MESSAGE PROGRAM()
	* unsuccess
ENDIF
RETURN nConn
ENDPROC
*
PROCEDURE TbNextId
LPARAMETERS pcidname, pulast
* Here we should have stored procedure on back end

LOCAL narea, nret, linitialize, cCurPl, cPrefix, nIDLength

narea = SELECT()

DO CASE
	CASE INLIST(pcidname, "ROOM    ", "ROOMTYPE")
		cPrefix = "@"
		nIDLength = 3		&& ID length without prefix
		linitialize = (PCOUNT() > 1) AND VARTYPE(pulast) == "C"
		nret = IIF(linitialize, ALLTRIM(IIF(LEFT(pulast,LEN(cPrefix)) == cPrefix, SUBSTR(pulast,LEN(cPrefix)+1), pulast)), "")
		cCurPl = SqlCursor("SELECT id_clast FROM id WHERE id_code = " + SqlCnv(pcidname,.T.))
		IF RECCOUNT() > 0
			IF NOT linitialize
				nret = GetNewCharId(PADL(SUBSTR(ALLTRIM(id_clast), LEN(cPrefix)+1), nIDLength))
			ENDIF
			IF NOT EMPTY(nret)
				nret = cPrefix + PADL(nret, nIDLength, "A")
			ENDIF
			SqlUpdate("id", "id_code = " + SqlCnv(pcidname,.T.), "id_clast = " + SqlCnv(nret,.T.))
		ELSE
			IF NOT linitialize
				nret = GetNewCharId(PADL(SUBSTR(ALLTRIM(id_clast), LEN(cPrefix)+1), nIDLength))
			ENDIF
			IF NOT EMPTY(nret)
				nret = cPrefix + PADL(nret, nIDLength, "A")
			ENDIF
			SqlInsert("id", "id_code, id_clast", 1, SqlCnv(pcidname,.T.)+","+SqlCnv(nret,.T.))
		ENDIF
	CASE pcidname = "LISTS   "
		cCurPl = SqlCursor("SELECT id_last FROM id WHERE id_code = " + SqlCnv(pcidname,.T.))
		IF RECCOUNT() > 0
			nret = id_last + 1
			SqlUpdate("id", "id_code = " + SqlCnv(pcidname,.T.), "id_last = " + SqlCnv(nret,.T.))
		ELSE
			nret = 1000
			SqlInsert("id", "id_code, id_last", 1, SqlCnv(pcidname,.T.)+","+SqlCnv(nret,.T.))
		ENDIF
	OTHERWISE
		linitialize = (PCOUNT() > 1) AND VARTYPE(pulast) == "N"
		nret = IIF(linitialize, pulast, 0)
		cCurPl = SqlCursor("SELECT id_last FROM id WHERE id_code = " + SqlCnv(pcidname,.T.))
		IF RECCOUNT() > 0
			IF NOT linitialize
				nret = id_last + 1
			ENDIF
			SqlUpdate("id", "id_code = " + SqlCnv(pcidname,.T.), "id_last = " + SqlCnv(nret,.T.))
		ELSE
			IF NOT linitialize
				nret = 1
			ENDIF
			SqlInsert("id", "id_code, id_last", 1, SqlCnv(pcidname,.T.)+","+SqlCnv(nret,.T.))
		ENDIF
ENDCASE

DClose(cCurPl)

SELECT (narea)

RETURN nret
ENDPROC
*
PROCEDURE UseTablesVfp
LPARAMETERS lp_cTable
LOCAL lcTables

IF NOT EMPTY(lp_cTable)
	lcTables = C_USETABLESVFP
	IF INLIST(UPPER(PADR(ALLTRIM(lp_cTable),8)), &lcTables)
		RETURN .T.
	ENDIF
ENDIF
RETURN .F.
ENDPROC
*
PROCEDURE IsVfpDataTable
LPARAMETERS tcTable
LOCAL lcTables

lcTables = C_VFPDATATABLE
RETURN INLIST(UPPER(PADR(ALLTRIM(tcTable),8)), &lcTables)
ENDPROC
*
PROCEDURE IsStaticDataTable
LPARAMETERS tcTable
LOCAL lcTables

lcTables = C_STATICDATATABLE
IF Odbc()
	lcTables = lcTables + ',' + C_STATICDATATABLE_ODBC
ENDIF

RETURN INLIST(UPPER(PADR(ALLTRIM(tcTable),8)), &lcTables)
ENDPROC
*
PROCEDURE IsStaticTableUsed
LPARAMETERS tcTable

RETURN USED(tcTable)
ENDPROC
*
PROCEDURE StaticDataRefresh
LOCAL lnArea, lcCur, lcTable, lnTagNo, lcKeyMacro, lcKey, lcTag, lcDesc, lcCand

IF Odbc()
	lnArea = SELECT()

	SELECT files
	SCAN FOR this.IsStaticDataTable(fi_name)
		lcTable = ALLTRIM(fi_name)
		this.StaticTableRefresh(lcTable)
	ENDSCAN

	SELECT (lnArea)
ENDIF
ENDPROC
*
PROCEDURE GetMainTableRecord
LPARAMETERS tcTable, toRecord, tcWhere
LOCAL lnArea, lcCursor, llUsed

lnArea = SELECT()

IF Odbc()
	lcCursor = SqlCursor("SELECT * FROM " + tcTable + SqlWhere("",tcWhere))
	CFCursorNullsRemove(.T.,lcCursor)
	SCATTER MEMO NAME toRecord
	DClose(lcCursor)
ELSE
	llUsed = USED(tcTable)
	IF OpenFile(,tcTable)
		IF NOT EMPTY(tcWhere)
			DLocate(tcTable, tcWhere)
		ENDIF
		SELECT (tcTable)
		SCATTER MEMO NAME toRecord
	ENDIF
	IF NOT llUsed
		DClose(tcTable)
	ENDIF
ENDIF

SELECT (lnArea)
ENDPROC
*
PROCEDURE StaticTableRefresh
LPARAMETERS tcTable
LOCAL lnArea, lcCursor, llUsed, lcArrayName
LOCAL ARRAY laIndexes(1)

IF this.IsStaticDataTable(tcTable)
	lnArea = SELECT()

	lcArrayName = "a" + tcTable + "Cur"
	IF NOT PEMSTATUS(this, lcArrayName, 5)
		this.AddProperty(lcArrayName + "(1)")
	ENDIF

	DO CASE
		CASE NOT Odbc()
			llUsed = USED(tcTable)
			IF OpenFile(,tcTable)
				SELECT * FROM (tcTable) INTO ARRAY this.&lcArrayName
			ENDIF
			IF NOT llUsed
				DClose(tcTable)
			ENDIF
		CASE USED(tcTable)
			lcCursor = SqlCursor("SELECT * FROM " + tcTable)
			CFCursorNullsRemove(.T.,lcCursor)
			SELECT * FROM (lcCursor) INTO ARRAY this.&lcArrayName
			DClose(lcCursor)
			ZAP IN &tcTable
			INSERT INTO &tcTable FROM ARRAY this.&lcArrayName
		OTHERWISE
			SqlCursor("SELECT * FROM " + tcTable, tcTable,,,,,,.T.)
			CFCursorNullsRemove(.T.,tcTable)
			SetIndexes(tcTable,,"Tag1",,@laIndexes)
			SELECT * FROM (tcTable) INTO ARRAY this.&lcArrayName
	ENDCASE
ENDIF

SELECT (lnArea)
ENDPROC
*
PROCEDURE RoomsRefresh
this.StaticTableRefresh("room")
_screen.oGlobal.Close_def_table("rmrtbld")
ENDPROC
*
PROCEDURE RoomTypesRefresh
this.StaticTableRefresh("roomtype")
_screen.oGlobal.Close_def_table("rmrtbld, rtrdbld")
ENDPROC
*
PROCEDURE GetTableStructure
LPARAMETERS tcTable, taFields
EXTERNAL ARRAY taFields

* Table structure from Fields.dbf
IF USED(tcTable)
	AFIELDS(taFields, tcTable)
ENDIF
*SELECT fd_name, fd_type, fd_len, fd_dec, .F., .F., "", "", "", "", "", "", "", "", "", "", 0, 0 FROM fields ;
	WHERE UPPER(fd_table+fd_name) = UPPER(PADR(tcTable,8)) ;
	INTO ARRAY taFields
ENDPROC
*
PROCEDURE GetTableIndexes
LPARAMETERS tcTable, taIndexes, tlExternalODBC
EXTERNAL ARRAY taIndexes
LOCAL i, lcFiAlias, lnRecno, lnMaxIndexes

IF tlExternalODBC
	lcFiAlias = "AOFiles"
	IF NOT USED("AOFiles")
		openfiledirect(.F., "files", "AOFiles", this.Parent.cArgusMetadataDir, .T.)
	ENDIF
ELSE
	lcFiAlias = "Files"
	IF NOT USED("Files")
		openfiledirect(.F., "files")
	ENDIF
ENDIF

lnRecno = RECNO(lcFiAlias)
IF SEEK(UPPER(PADR(tcTable,8)), lcFiAlias, "tag1")
	lnMaxIndexes = 45	&& Check if exists this key field in files table in sole old version
	DIMENSION taIndexes(lnMaxIndexes,4)
	FOR i = 1 TO lnMaxIndexes
		taIndexes(i,1) = ALLTRIM(EVALUATE(lcFiAlias+".fi_key" + TRANSFORM(i)))
		IF EMPTY(taIndexes(i,1))
			DIMENSION taIndexes(MAX(1,i-1),4)
			EXIT
		ENDIF
		taIndexes(i,2) = EVALUATE(lcFiAlias+".fi_des" + TRANSFORM(i))
		taIndexes(i,3) = EVALUATE(lcFiAlias+".fi_uni" + TRANSFORM(i))
		IF tlExternalODBC
			taIndexes(i,4) = EVALUATE(lcFiAlias+".fi_tag" + TRANSFORM(i))
		ELSE
			taIndexes(i,4) = "Tag" + TRANSFORM(i)
		ENDIF
	NEXT
ENDIF
GO lnRecno IN &lcFiAlias
ENDPROC
*
ENDDEFINE
*
PROCEDURE OpenCommonTable
LPARAMETERS tcTable, tcAlias, toDE, toCursorAdapter
LOCAL loCursorAdapter, llReturnCaObject

IF EMPTY(tcAlias)
	tcAlias = tcTable
ENDIF

llReturnCaObject = NOT EMPTY(toCursorAdapter)	&& Need to be returned cursoradapter object by reference.
DO CASE
	CASE USED(tcAlias)
	CASE _screen.oGlobal.oGData.IsStaticDataTable(tcTable) AND _screen.oGlobal.oGData.IsStaticTableUsed(tcTable)
		StaticTableCopy(tcTable, tcAlias, "Tag1")
	CASE VARTYPE(toDE) = "O"
		IF NOT PEMSTATUS(toDE, tcAlias, 5)
			toDE.AddObject(tcAlias, "ca"+tcTable)
		ENDIF
		toDE.&tcAlias..cFilterClause = "0=1"
		toDE.&tcAlias..Alias = tcAlias
		toDE.&tcAlias..cOrder = "Tag1"
		toDE.&tcAlias..lCreateIndexes = .T.
		toDE.&tcAlias..CursorQuery(.T.)
	CASE llReturnCaObject
		loCursorAdapter = .NULL.
		loCursorAdapter = CREATEOBJECT("ca"+tcTable)
		loCursorAdapter.cFilterClause = "0=1"
		loCursorAdapter.Alias = tcAlias
		loCursorAdapter.cOrder = "Tag1"
		loCursorAdapter.lCreateIndexes = .T.
		loCursorAdapter.CursorQuery(.T.)
		toCursorAdapter = loCursorAdapter
	OTHERWISE
*		Don't open table on ODBC() if table is not static or if don't pass references for toDE and toCursorAdapter.
*		Leave program to fail if table is not prepared in DataEnvironment.
*		loCursorAdapter = CREATEOBJECT("ca"+tcTable)
*		loCursorAdapter.Alias = tcAlias
*		loCursorAdapter.cOrder = "Tag1"
*		loCursorAdapter.lCreateIndexes = .T.
*		loCursorAdapter.lDetach = .T.
*		loCursorAdapter.CursorQuery(.T.)
**		SqlCursor("SELECT * FROM " + tcTable, tcAlias,,,,,,.T.)
**		CFCursorNullsRemove(.T.,tcAlias)
**		SetIndexes(tcTable, tcAlias, "Tag1",,@laIndexes)
ENDCASE
ENDPROC
*
PROCEDURE StaticTableCopy
LPARAMETERS tcTable, tcAlias, tcOrder
LOCAL lcArrayName
LOCAL ARRAY laFields(1), laIndexes(1)

IF EMPTY(tcAlias)
	tcAlias = tcTable
ENDIF

_screen.oGlobal.oGData.GetTableStructure(tcTable, @laFields)
CREATE CURSOR (tcAlias) FROM ARRAY laFields
SetIndexes(tcTable, tcAlias, tcOrder,,@laIndexes)

lcArrayName = "a" + tcTable + "Cur"
IF PEMSTATUS(_screen.oGlobal.oGData, lcArrayName, 5) AND (ALEN(_screen.oGlobal.oGData.&lcArrayName) > 1 OR NOT EMPTY(_screen.oGlobal.oGData.&lcArrayName(1)))
	INSERT INTO (tcAlias) FROM ARRAY _screen.oGlobal.oGData.&lcArrayName
ENDIF
ENDPROC
*
PROCEDURE SetIndexes
LPARAMETERS tcTable, tcAlias, tcOrder, tcIndexList, taIndexes, tlExternalODBC, tcRemoteDatabase
LOCAL lnArea, lnTagNo, lcKey, lcTag, lcDesc, lcCand, lnBuffering
EXTERNAL ARRAY taIndexes

lnArea = SELECT()

IF EMPTY(tcAlias)
	tcAlias = tcTable
ENDIF

IF VARTYPE(taIndexes(1))="L"
	* Create array with indexes only once
	IF EMPTY(tcRemoteDatabase)
		_screen.oGlobal.oGData.GetTableIndexes(tcTable, @taIndexes, tlExternalODBC)
	ELSE
		SELECT (tcTable)
		IF TAGCOUNT() > 0
			DIMENSION taIndexes(TAGCOUNT(),4)
			FOR i = 1 TO TAGCOUNT()
				taIndexes(i,1) = KEY(i)
				taIndexes(i,2) = DESCENDING(i)
				taIndexes(i,3) = CANDIDATE(i)
				taIndexes(i,4) = TAG(i)
			NEXT
		ENDIF
	ENDIF
ENDIF

SELECT &tcAlias
lnBuffering = CURSORGETPROP("Buffering")
FOR lnTagNo = 1 TO ALEN(taIndexes,1)
	lcKey = taIndexes(lnTagNo,1)
	lcTag = taIndexes(lnTagNo,4)
	IF NOT EMPTY(lcKey) AND (EMPTY(tcIndexList) OR ("|"+UPPER(lcTag)+"|" $ STRTRAN("|"+UPPER(tcIndexList)+"|", " ")))
		lcDesc = IIF(taIndexes(lnTagNo,2), "DESCENDING", "")
		lcCand = IIF(taIndexes(lnTagNo,3), "CANDIDATE", "")
		IF CURSORGETPROP("Buffering") > 3
			CURSORSETPROP("Buffering",3)
		ENDIF
		INDEX ON &lcKey TAG &lcTag &lcDesc &lcCand
	ENDIF
NEXT
IF CURSORGETPROP("Buffering") <> lnBuffering
	CURSORSETPROP("Buffering",lnBuffering)
ENDIF
IF NOT EMPTY(tcOrder) AND TAGNO(tcOrder) > 0
	SET ORDER TO (tcOrder)
ELSE
	SET ORDER TO
ENDIF

SELECT (lnArea)
ENDPROC
*
PROCEDURE CursorQuery
LPARAMETERS tcAlias, tcFilterClause, tcInnerClause, tcOrderBy, tnTopClause, tcOrder, tlExternalODBC
LOCAL loCursorAdapter

IF Odbc() OR tlExternalODBC
	loCursorAdapter = .NULL.
	TRY
		loCursorAdapter = GETCURSORADAPTER(tcAlias)
	CATCH
	ENDTRY
	IF NOT ISNULL(loCursorAdapter)
		loCursorAdapter.CursorQuery(.T., tcFilterClause, tcInnerClause, tcOrderBy, tnTopClause, tcOrder)
	ENDIF
ENDIF
ENDPROC
*
DEFINE CLASS cbobj AS Session
*
HIDDEN ccreatedtables
*
DataSession = 1
cListCur = ""
lvaliderr = .F.
cvaliderr = ""
lexportastable = .F.
lexportasxml = .F.
ctmpdir = ""
cresulttable = ""
ccreatedtables = ""
cxml = ""
cxmltable = ""
lxmltablestruct = .F.
*
PROCEDURE Init
this.SetExport()
ENDPROC
*
HIDDEN PROCEDURE SetExport
IF g_lAutomationMode
	IF VARTYPE(_screen.oGlobal.oDeskServer) = "O"
		IF _screen.oGlobal.oDeskServer.cExportType = "XML"
			this.lexportasxml = .T.
			this.lxmltablestruct = _screen.oGlobal.oDeskServer.lPrepareCursorStructure
		ELSE
			this.lexportastable = .T.
		ENDIF
	ENDIF
	this.ctmpdir = IIF(EMPTY(_screen.oGlobal.ccomservertempfolder),"",ADDBS(FULLPATH(_screen.oGlobal.ccomservertempfolder)))
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE ListGet
ENDPROC
*
PROCEDURE RecGet
ENDPROC
*
PROCEDURE RecReload
ENDPROC
*
PROCEDURE RecSave
ENDPROC
*
PROCEDURE CheckCa
ENDPROC
*
PROCEDURE GetCaAlias
RETURN ""
ENDPROC
*
PROCEDURE Export
LPARAMETERS lp_cCur
IF NOT EMPTY(lp_cCur)
	this.ExpAsDbf(lp_cCur)
	this.ExportAsXml(lp_cCur)
ENDIF
ENDPROC
*
PROCEDURE Import
LPARAMETERS lp_cCur
IF NOT EMPTY(lp_cCur)
	this.ImportFromDbf(lp_cCur)
	this.ImportFromXml(lp_cCur)
ENDIF
ENDPROC
*
PROCEDURE ExpAsDbf
LPARAMETERS lp_cCur
IF this.lexportastable
	SELECT (lp_cCur)
	IF FILE(this.ctmpdir+lp_cCur+".dbf")
		DELETE FILE (this.ctmpdir+lp_cCur+".*")
	ENDIF
	COPY TO (this.ctmpdir+lp_cCur) CDX
	this.cresulttable = this.ctmpdir+lp_cCur
ENDIF
ENDPROC
*
PROCEDURE ExportAsXml
LPARAMETERS lp_cCur
IF this.lexportasxml
	LOCAL lcXML
	this.cXMLTable = LOWER(lp_cCur)
	CURSORTOXML(this.cXMLTable,"lcXML",1,32,0,"1")
	this.cxml = lcXML
	this.cresulttable = lp_cCur
	this.SetXml()
	this.ccreatedtables = this.ccreatedtables + lp_cCur + "|"
ENDIF
ENDPROC
*
PROCEDURE ImportFromDbf
LPARAMETERS lp_cCur
LOCAL l_oData, l_cCur
IF this.lexportastable
	IF EMPTY(lp_cCur) OR NOT FILE(this.ctmpdir+lp_cCur+".dbf")
		RETURN .F.
	ENDIF
	SELECT 0
	USE (this.ctmpdir+lp_cCur) ALIAS (lp_cCur+"1") SHARED
	LOCATE
	SCATTER NAME l_oData MEMO
	IF NOT USED(lp_cCur)
		l_cCur = SYS(2015)
		COPY STRUCTURE TO (ADDBS(this.ctmpdir)+l_cCur+".dbf")
		USE (ADDBS(this.ctmpdir)+l_cCur+".dbf") IN 0
		SELECT * FROM (l_cCur) WHERE 0=1 INTO CURSOR (lp_cCur) READWRITE
		USE IN (l_cCur)
		DELETE FILE (ADDBS(this.ctmpdir)+l_cCur+".*")
	ENDIF
	SELECT (lp_cCur)
	LOCATE
	IF RECCOUNT()=0
		APPEND BLANK
	ENDIF
	GATHER NAME l_oData MEMO
	USE IN (lp_cCur+"1")
	SELECT (lp_cCur)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE ImportFromXml
LPARAMETERS lp_cCur
LOCAL l_oData, l_owwXml AS wwxml OF wwxml.vcx, l_lSuccess
IF this.lexportasxml
	this.GetXML()
	IF EMPTY(lp_cCur) OR EMPTY(this.cxml)
		RETURN .F.
	ENDIF
	l_owwXml = NEWOBJECT("wwXML","wwxml.vcx")
	SELECT * FROM (lp_cCur) WHERE 0=1 INTO CURSOR (lp_cCur+"1") READWRITE
	IF EMPTY(this.cxmltable)
		l_lSuccess = l_owwXml.DataSetXMLToCursor(this.cxml,lp_cCur+"1")
	ELSE
		l_lSuccess = l_owwXml.DataSetXMLToCursor(this.cxml,lp_cCur+"1", this.cxmltable)
	ENDIF
	IF l_lSuccess
		SELECT (lp_cCur+"1")
		LOCATE
		SCATTER NAME l_oData MEMO
		SELECT (lp_cCur)
		LOCATE
		IF RECCOUNT()=0
			APPEND BLANK
		ENDIF
		GATHER NAME l_oData MEMO
	ENDIF
	dclose(lp_cCur+"1")
	l_owwXml = .NULL.
	SELECT (lp_cCur)
ENDIF
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE GetXML
IF g_lAutomationMode AND VARTYPE(_screen.oGlobal.oDeskServer) = "O"
	this.cXML = _screen.oGlobal.oDeskServer.cXML
	this.cXMLTable = _screen.oGlobal.oDeskServer.cXMLTable
ENDIF
ENDPROC
*
HIDDEN PROCEDURE SetXML
IF g_lAutomationMode AND VARTYPE(_screen.oGlobal.oDeskServer) = "O"
	_screen.oGlobal.oDeskServer.cXML = this.cXML
	_screen.oGlobal.oDeskServer.cXMLTable = this.cXMLTable
	IF this.lxmltablestruct
		AFIELDS(_screen.oGlobal.oDeskServer.axmltablestruct,this.cXMLTable)
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE CloseAliases
LOCAL i, l_ctable
dclose(this.cListCur)
IF NOT EMPTY(this.ccreatedtables)
	FOR i = 1 TO GETWORDCOUNT(this.ccreatedtables,"|")
		l_ctable = GETWORDNUM(this.ccreatedtables,i,"|")
		IF NOT EMPTY(l_ctable)
			dclose(l_ctable)
			TRY
				DELETE FILE (this.ctmpdir+l_ctable++".*")
			CATCH
			ENDTRY
		ENDIF
	ENDFOR
ENDIF
this.CloseAliasesHook()
ENDPROC
*
PROCEDURE CloseAliasesHook
ENDPROC
*
PROCEDURE Destroy
this.CloseAliases()
ENDPROC
*
ENDDEFINE
*
*********************************************************************************************************
*
* Used to call emailsend.scx from bind event. Form is modal, and when called without delay, citadel.exe
* can freeze, when bin event occurs more then once.
*
*********************************************************************************************************
*
DEFINE CLASS cSendEmailFormTmr AS Timer
*
Interval = 300
Enabled = .F.
nStep = 0
nAddressID = 0
nReserId = 0
DIMENSION aDocumentsToSend[1]
*
PROCEDURE Init
LPARAMETERS lp_nAddressID, lp_nReserId, lp_aDocumentsToSend
EXTERNAL ARRAY lp_aDocumentsToSend
DIMENSION this.aDocumentsToSend(ALEN(lp_aDocumentsToSend,1))
LOCAL i

FOR i = 1 TO ALEN(lp_aDocumentsToSend,1)
	this.aDocumentsToSend(i) = lp_aDocumentsToSend(i)
ENDFOR

this.nAddressID = lp_nAddressID
this.nReserId = lp_nReserId

RETURN .T.
ENDPROC
*
PROCEDURE Timer
LOCAL i
LOCAL ARRAY l_aDocumentsToSend(1)

this.Enabled = .F.

DO CASE
	CASE this.nStep = 0
		this.nStep = 1
		this.Enabled = .T.
	CASE this.nStep = 1
		this.nStep = 2
		DIMENSION l_aDocumentsToSend(ALEN(this.aDocumentsToSend,1))
		FOR i = 1 TO ALEN(this.aDocumentsToSend,1)
			l_aDocumentsToSend(i) = this.aDocumentsToSend(i)
		ENDFOR
		DO FORM forms\emailsend.scx WITH "NEW", this.nAddressID, .NULL., 0, this.nReserId, l_aDocumentsToSend
ENDCASE

RETURN .T.
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE
**************************************************************************************