#INCLUDE "include\constdefines.h"
*
FUNCTION ArgusOffice
LPARAMETERS pcFunction, pcTablesOrLicenceOrCloseAO, pcSqlStatement, plSilent, plAliasSameAsTable, pcFilterClause, pcInnerClause, pcOrderBy, pnTopClause, pcOrder
LOCAL lnArea, lcErrMsg, llSuccess, lnNewId, lcParamValue

pcFunction = IIF(EMPTY(pcFunction), "", pcFunction)
pcTablesOrLicenceOrCloseAO = IIF(EMPTY(pcTablesOrLicenceOrCloseAO), "", pcTablesOrLicenceOrCloseAO)
pcSqlStatement = IIF(EMPTY(pcSqlStatement), "", pcSqlStatement)
lnArea = SELECT()
OpenFile(.F., "param2")

DO CASE
     CASE UPPER(pcFunction) == "EXIT"
          AOExit(pcTablesOrLicenceOrCloseAO)                    && puTablesOrLicenceOrCloseAO - table list or '' for disconnecting
          llSuccess = .T.
     CASE NOT _screen.oGlobal.oParam.pa_argus OR EMPTY(_screen.oGlobal.oParam2.pa_argusdr)
     CASE NOT DIRECTORY(ALLTRIM(_screen.oGlobal.oParam2.pa_argusdr))
          lcErrMsg = GetLangText("ARGUS","TA_DIR_NOT_DEFINED")
     CASE UPPER(pcFunction) == "PARAM"
          DO CASE
               CASE NOT AOGetParam(pcTablesOrLicenceOrCloseAO, @lcParamValue)
               CASE pcTablesOrLicenceOrCloseAO = "pa_licopt"
                    llSuccess = (pcSqlStatement $ lcParamValue)
                    IF NOT llSuccess
                         lcErrMsg = "'" + pcSqlStatement + "' " + GetLangText("ARGUS","TA_MODULE_NOT_AVAILABLE")
                    ENDIF
               CASE pcTablesOrLicenceOrCloseAO = "pa_cashctr"
                    llSuccess = lcParamValue
                    IF NOT llSuccess
                         lcErrMsg = GetLangText("ARGUS","TA_CASH_CTRL_NOT_USED")
                    ENDIF
               CASE EMPTY(pcSqlStatement)
                    llSuccess = lcParamValue
               OTHERWISE
          ENDCASE
     CASE UPPER(pcFunction) == "LICENSE"
          llSuccess = ArgusOffice("PARAM", "pa_licopt", pcTablesOrLicenceOrCloseAO, plSilent)     && puTablesOrLicenceOrCloseAO - license code
     CASE EMPTY(pcFunction) AND NOT PrepareArgusFrontOffice(_screen.oGlobal.oParam2.pa_argusdr, plAliasSameAsTable)
          lcErrMsg = GetLangText("ARGUS","TA_DATA_NOT_AVAILABLE")
     CASE UPPER(pcFunction) == "USE"
          llSuccess = AOUse(pcTablesOrLicenceOrCloseAO)         && puTablesOrLicenceOrCloseAO - table list
          IF NOT llSuccess
               lcErrMsg = GetLangText("ARGUS","TA_DATA_NOT_AVAILABLE")
               AOExit()                                         && disconnecting
          ENDIF
     CASE UPPER(pcFunction) == "QUERY"
          llSuccess = AOQuery(pcTablesOrLicenceOrCloseAO)
          IF NOT llSuccess
               lcErrMsg = GetLangText("ARGUS","TA_DATA_NOT_AVAILABLE")
               AOExit(pcTablesOrLicenceOrCloseAO)               && puTablesOrLicenceOrCloseAO - table list
          ENDIF
     CASE UPPER(pcFunction) == "SQLQUERY"
          llSuccess = AOSqlQuery(pcTablesOrLicenceOrCloseAO, pcSqlStatement)
          IF NOT llSuccess
               lcErrMsg = GetLangText("ARGUS","TA_DATA_NOT_AVAILABLE")
               AOExit()                                         && disconnecting
          ENDIF
     CASE UPPER(pcFunction) == "CURSORQUERY"
          llSuccess = AOCursorQuery(pcTablesOrLicenceOrCloseAO, pcFilterClause, pcInnerClause, pcOrderBy, pnTopClause, pcOrder)
     CASE UPPER(pcFunction) == "DOTABLEUPDATE"
          llSuccess = AOTableUpdate(pcTablesOrLicenceOrCloseAO)
     CASE UPPER(pcFunction) == "NEXTID"
          lnNewId = ArgusNextId(pcTablesOrLicenceOrCloseAO) && puTablesOrLicenceOrCloseAO - Alias Code
          llSuccess = lnNewId
     OTHERWISE
          llSuccess = .T.
ENDCASE

IF NOT EMPTY(lcErrMsg) AND NOT plSilent
     Alert(lcErrMsg)
ENDIF

SELECT (lnArea)

RETURN llSuccess
ENDFUNC
*
PROCEDURE AOExit
LPARAMETERS pcTables
LOCAL lcAliases

RemoveArgusFrontOffice()
IF NOT EMPTY(pcTables)
     lcAliases = AOAliasList(pcTables)
     FOR lnTableNo = 1 TO GETWORDCOUNT(lcAliases, ",")
          lcAlias = ALLTRIM(GETWORDNUM(lcAliases, lnTableNo, ","))
          CloseFile(lcAlias)
     NEXT
ENDIF
ENDPROC
*
FUNCTION AOUse
LPARAMETERS pcTables
LOCAL lcAliases, llSuccess

lcAliases = AOAliasList(pcTables)
llSuccess = BatchOpenArgusTable(pcTables, lcAliases)

RETURN llSuccess
ENDFUNC
*
FUNCTION AOQuery
LPARAMETERS pcTables
LOCAL lcAliases, llSuccess

lcAliases = AOAliasList(pcTables)
llSuccess = BatchQueryArgusTable(pcTables, lcAliases)

RETURN llSuccess
ENDFUNC
*
FUNCTION AOSqlQuery
LPARAMETERS pcTables, pcSqlStatement
LOCAL lcAliases, llSuccess

lcAliases = AOAliasList(pcTables)
llSuccess = ArgusSqlQuery(pcTables, lcAliases, pcSqlStatement)

RETURN llSuccess
ENDFUNC
*
FUNCTION AOCursorQuery
LPARAMETERS pcTable, pcFilterClause, pcInnerClause, pcOrderBy, pnTopClause, pcOrder
LOCAL lcAlias

lcAlias = AOAliasList(pcTable)
CursorQuery(lcAlias, pcFilterClause, pcInnerClause, pcOrderBy, pnTopClause, pcOrder, .T.)

RETURN .T.
ENDFUNC
*
FUNCTION AOTableUpdate
LPARAMETERS pcAlias
LOCAL llSuccess

llSuccess = DoTableUpdate(.T.,.T.,pcAlias,.T.,.T.)

RETURN llSuccess
ENDFUNC
*
FUNCTION AOAliasList
LPARAMETERS pcTables
LOCAL lnTableNo, lcAlias, lcAliases

lcAliases = pcTables
FOR lnTableNo = 1 TO GETWORDCOUNT(lcAliases, ",")
     lcAlias = ALLTRIM(GETWORDNUM(lcAliases, lnTableNo, ","))
     lcAliases = STRTRAN(lcAliases, lcAlias, "AO"+lcAlias, 1, 1)
NEXT

RETURN lcAliases
ENDFUNC
*
FUNCTION AOGetParam
LPARAMETERS pcArgParamField, puRetval
LOCAL llParamPicked

IF ArgusOffice("", "", "", .T.) AND ArgusOffice("Use", "Param", "", .T.) AND TYPE("AOParam."+pcArgParamField) <> "U"
     ArgusOffice("CursorQuery", "Param", "",,,"0=0")
     puRetval = EVALUATE('AOParam.'+pcArgParamField)
     llParamPicked = .T.
ENDIF
ArgusOffice("Exit")

RETURN llParamPicked
ENDFUNC
*
PROCEDURE AOGetOdbc
LOCAL lcTerminalIni, lcData

IF _screen.oGlobal.oParam.pa_argus AND NOT EMPTY(_screen.oGlobal.oParam2.pa_argusdr)
     lcTerminalIni = FULLPATH(ADDBS(ALLTRIM(_screen.oGlobal.oParam2.pa_argusdr))+"..\terminal.ini")
     IF FILE(lcTerminalIni)
          lcData = ReadINI(lcTerminalIni, "Database", "DBMS", "Visual Foxpro")
          IF UPPER(lcData) = "ODBC"
               _screen.oGlobal.cArgusMetadataDir = LOWER(JUSTPATH(lcTerminalIni)) + "\shared\metadata"
               _screen.oGlobal.lODBCArgus = .T.
               lcData = ReadINI(lcTerminalIni, "Database", "ODBCDRIVERNAME", "")
               IF NOT EMPTY(lcData)
                    _screen.oGlobal.cODBCArgusDriver = lcData
               ENDIF
               lcData = ReadINI(lcTerminalIni, "Database", "ODBCDATABASE", "citadel")
               IF NOT EMPTY(lcData)
                    _screen.oGlobal.cODBCArgusDatabase = lcData
               ENDIF
               lcData = ReadINI(lcTerminalIni, "Database", "ODBCSERVER", "127.0.0.1")
               IF NOT EMPTY(lcData)
                    _screen.oGlobal.cODBCArgusServer = lcData
               ENDIF
               lcData = ReadINI(lcTerminalIni, "Database", "ODBCPORT", "5432")
               IF NOT EMPTY(lcData)
                    _screen.oGlobal.cODBCArgusPort = lcData
               ENDIF
               IF NOT (EMPTY(_screen.oGlobal.cODBCArgusDatabase) OR EMPTY(_screen.oGlobal.cODBCArgusServer) OR EMPTY(_screen.oGlobal.cODBCArgusPort))
                    lcData = ReadINI(lcTerminalIni, "Database", "ODBCPWD", "")
                    _screen.oGlobal.cODBCArgusPswd = EVL(lcData,"zimnicA$2001")
               ENDIF
          ENDIF
     ENDIF
ENDIF
ENDPROC
************************************************************************
PROCEDURE MgrReaders
     LPARAMETERS pcFilter

     DO FORM "Forms\MngForm" WITH "MngReadersCtrl",, pcFilter
ENDPROC
*
PROCEDURE CheckReader
     LPARAMETERS poCallingObj, poReader
     LOCAL ARRAY laParam(2)

     laParam(1) = poCallingObj
     laParam(2) = poReader
     DoForm("CashIn", "Forms\ArgusCashIn", "", .F., @laParam)
ENDPROC
*
PROCEDURE XReaderDetails
     LPARAMETERS poCallingObj, poReader
     LOCAL ARRAY laParam(2)

     laParam(1) = poCallingObj
     laParam(2) = poReader
     DoForm("CashInDetails", "Forms\ArgusCashInDetails", "", .F., @laParam)
ENDPROC
*
PROCEDURE SearchReader
     DO FORM "Forms\ArgusReaderSearch"
ENDPROC
************************************************************************
PROCEDURE MgrTableReser
     LOCAL lnMode, lcFilter, lnResourceID
     LOCAL ARRAY laParam(4)

     lnMode = GetTableResMode(@lnResourceID)
     DO CASE
          CASE lnMode = 1
               lcFilter = 'tr_rsid = ' + SqlCnv(lnResourceID)
          CASE lnMode = 2
               lcFilter = 'tr_addrid = ' + SqlCnv(lnResourceID)
          OTHERWISE
               lcFilter = 'tr_sysdate = ' + SqlCnv(SysDate())
     ENDCASE

     laParam(1) = "MngTableReserCtrl"
     laParam(3) = lcFilter
     laParam(4) = lnMode
     DoForm("", "Forms\MngForm",,,@laParam)
ENDPROC
*
PROCEDURE TableResDayPlan
     IF TableResIsInstalled()
          LOCAL lnMode, lnResourceID
          LOCAL ARRAY laParam(2)

          lnMode = GetTableResMode(@lnResourceID)

          laParam(1) = lnMode
          laParam(2) = lnResourceID
          DoForm("TableResDayPlan", "Forms\TableResDayPlan",,,@laParam)
     ENDIF
ENDPROC
*
PROCEDURE TableResWeekPlan
     IF TableResIsInstalled()
          LOCAL lnMode, lnResourceID
          LOCAL ARRAY laParam(2)

          lnMode = GetTableResMode(@lnResourceID)

          laParam(1) = lnMode
          laParam(2) = lnResourceID
          DoForm("TableResWeekPlan", "Forms\TableResWeekPlan",,,@laParam)
     ENDIF
ENDPROC
*
PROCEDURE CheckTableres
     LPARAMETERS toCallingObj, toTableres

     DO FORM "Forms\ArgusEditTableres" WITH toCallingObj, toTableres
ENDPROC
*
PROCEDURE DisplayOrder
     LPARAMETERS toCallingObj, toTableres

     DO FORM "Forms\ArgusOrderDetails" WITH toCallingObj, toTableres
ENDPROC
*
PROCEDURE SearchTableres
     LPARAMETERS toCallingObj, toTableres, toTables

     SELECT tblTableres
     SCATTER BLANK NAME toTableres
     toTables = MakeStructure("lc_locnr,lc_deptnr,lc_descr,dp_descr,tp_feat1,cFilter")
     toTables.lc_locnr = 0
     toTables.lc_deptnr = 0
     toTables.lc_descr = ""
     toTables.dp_descr = ""
     toTables.tp_feat1 = ""
     MakeStructure("lODBCArgus,cFilter,cFilterUn,cCaption,lOK", toTableres)
     toTableres.lODBCArgus = _screen.oGlobal.lODBCArgus

     DO FORM "Forms\ArgusTableresSearch" WITH toCallingObj, toTableres, toTables
ENDPROC
*
FUNCTION TableResIsInstalled
     LOCAL llSuccess

     DO CASE
          CASE NOT _screen.oGlobal.lTableReservationPlans
          CASE _screen.oGlobal.cDotNetFrameworkVersion < "4.0"
               Alert(Str2Msg(GetText("COMMON","TXT_TABLERES_PLATFORM_REQUIRED"), "%s", "Microsoft .NET Framework 4.0"))
          CASE NOT FILE("common\dll\wpftableres.dll")
               Alert(Str2Msg(GetText("COMMON","TXT_NOT_INSTALLED"), "%s", "WpfTableRes.dll"))
          CASE GetBinaryFileVersion("common\dll\wpftableres.dll", 2) < DLL_WPFTABLERES_REQUIRED_VERSION
               Alert(Str2Msg(GetText("COMMON","TXT_TABLERES_PLATFORM_REQUIRED"), "%s", "'wpftableres.dll' Version " + DLL_WPFTABLERES_REQUIRED_VERSION))
          OTHERWISE
               llSuccess = .T.
     ENDCASE

     RETURN llSuccess
ENDFUNC
*
FUNCTION GetTableResMode
     LPARAMETERS tnResourceID
     LOCAL lnMode, lcWOnTop

     lcWOnTop = UPPER(WONTOP())
     STORE 0 TO lnMode, tnResourceID
     DO CASE
          CASE TYPE("_screen.ActiveForm") # "O"
          CASE INLIST(lcWonTop, [TFORM12], [FORMEDITRES]) AND UPPER(_screen.ActiveForm.FormName) = [RESERVAT]
               tnResourceID = _screen.ActiveForm.DoEval("reservat.rs_rsid")
               lnMode = 1
          CASE lcWOnTop = [FWEEKFORM]
               IF NOT ISNULL(_screen.ActiveForm.SelectedReser)
                    tnResourceID = _screen.ActiveForm.DoEval("DLookUp('reservat', 'rs_reserid = ' + SqlCnv(this.SelectedReser.ReserId), 'rs_rsid')")
                    lnMode = 1
               ENDIF
          CASE lcWOnTop = [RESBRW]
               tnResourceID = _screen.ActiveForm.DoEval("DLookUp('reservat', 'rs_reserid = ' + SqlCnv(this.GetReserid()), 'rs_rsid')")
               lnMode = 1
          CASE lcWonTop = [TFORM12] AND UPPER(_screen.ActiveForm.FormName) = [QUICKEDIT]
               tnResourceID = _screen.ActiveForm.DoEval("tblQGrid.rs_rsid")
               lnMode = 1
          CASE lcWonTop = [FORMDETAIL] AND UPPER(_screen.ActiveForm.FormName) = [QUICKEDIT]
               tnResourceID = _screen.ActiveForm.DoEval("reservat.rs_rsid")
               lnMode = 1
          CASE lcWonTop = [FORMROOMLIST] AND UPPER(_screen.ActiveForm.FormName) = [ROOMLIST]
               tnResourceID = _screen.ActiveForm.DoEval("tblRLGrid.rs_rsid")
               lnMode = 1
          CASE lcWonTop = [FORMEDIT] AND UPPER(_screen.ActiveForm.FormName) = [ROOMLIST]
               tnResourceID = _screen.ActiveForm.DoEval("reservat.rs_rsid")
               lnMode = 1
          CASE lcWOnTop = [FADDRESSMASK]
               tnResourceID = _screen.activeform.Parent.m_GetSelectedAddress()
               lnMode = 2
          OTHERWISE
     ENDCASE

     RETURN lnMode
ENDFUNC
************************************************************************
FUNCTION PaymentCount
LPARAMETERS pnReaderId, pnXReaderId, pnPayNr, pnWaitNr, pnFlag
LOCAL lnCount

CALCULATE CNT(py_paynr) FOR py_readid = pnReaderId AND py_paynr = pnPayNr AND ;
     IIF(pnXReaderId = 0, py_waitnr = pnWaitNr, py_xreadid = pnXReaderId) AND ;
     pnFlag = IIF(INLIST(py_flag,3,4), py_flag, 1) TO lnCount IN AOPayment

RETURN lnCount
ENDFUNC
*
FUNCTION PaymentComment
LPARAMETERS pnFlag
LOCAL lcPayType

DO CASE
     CASE pnFlag = 3
          lcPayType = GetLangText("ARGUS", "TXT_CASHINOUT")
     CASE pnFlag = 4
          lcPayType = GetLangText("ARGUS", "TXT_CASHEXCHANGE")
     OTHERWISE
          lcPayType = ""
ENDCASE

RETURN PADR(lcPayType,30)
ENDFUNC
*