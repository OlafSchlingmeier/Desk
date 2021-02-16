#INCLUDE "include\constdefines.h"
*
FUNCTION WellnessOffice
LPARAMETERS pcFunction, pcTablesOrLicenceOrCloseWO, pcSqlStatement, plSilent
LOCAL lnArea, lcErrMsg, llSuccess, lnNewId, lcParamValue

pcFunction = IIF(EMPTY(pcFunction), "", pcFunction)
pcTablesOrLicenceOrCloseWO = IIF(EMPTY(pcTablesOrLicenceOrCloseWO), "", pcTablesOrLicenceOrCloseWO)
pcSqlStatement = IIF(EMPTY(pcSqlStatement), "", pcSqlStatement)
lnArea = SELECT()
OpenFile(.F., "param2")

DO CASE
     CASE UPPER(pcFunction) == "EXIT"
          WOExit(pcTablesOrLicenceOrCloseWO)                    && puTablesOrLicenceOrCloseWO - table list or '' for disconnecting
          llSuccess = .T.
     CASE NOT param2.pa_wellifc OR EMPTY(param2.pa_welldir)
     CASE NOT DIRECTORY(ALLTRIM(param2.pa_welldir))
          lcErrMsg = GetLangText("WELLNESS","TA_DIR_NOT_DEFINED")
     CASE UPPER(pcFunction) == "PARAM"
          DO CASE
               CASE NOT WOGetParam(pcTablesOrLicenceOrCloseWO, @lcParamValue)
               CASE EMPTY(pcSqlStatement)
                    llSuccess = lcParamValue
               OTHERWISE
          ENDCASE
     CASE EMPTY(pcFunction) AND NOT PrepareWellnessFrontOffice(param2.pa_welldir, pcTablesOrLicenceOrCloseWO)     && puTablesOrLicenceOrCloseWO - Alias is same as table
          lcErrMsg = GetLangText("WELLNESS","TA_DATA_NOT_AVAILABLE")
     CASE UPPER(pcFunction) == "USE"
          llSuccess = WOUse(pcTablesOrLicenceOrCloseWO)         && puTablesOrLicenceOrCloseWO - table list
          IF NOT llSuccess
               lcErrMsg = GetLangText("WELLNESS","TA_DATA_NOT_AVAILABLE")
               WOExit()                                         && disconnecting
          ENDIF
     CASE UPPER(pcFunction) == "QUERY"
          llSuccess = WOQuery(pcTablesOrLicenceOrCloseWO)
          IF NOT llSuccess
               lcErrMsg = GetLangText("WELLNESS","TA_DATA_NOT_AVAILABLE")
               WOExit(pcTablesOrLicenceOrCloseWO)               && puTablesOrLicenceOrCloseWO - table list
          ENDIF
     CASE UPPER(pcFunction) == "SQLQUERY"
          llSuccess = WOSqlQuery(pcTablesOrLicenceOrCloseWO, pcSqlStatement)
          IF NOT llSuccess
               lcErrMsg = GetLangText("WELLNESS","TA_DATA_NOT_AVAILABLE")
               WOExit()                                         && disconnecting
          ENDIF
     CASE UPPER(pcFunction) == "NEXTID"
          lnNewId = WellnessNextId(pcTablesOrLicenceOrCloseWO) && puTablesOrLicenceOrCloseWO - Alias Code
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
PROCEDURE WOExit
LPARAMETERS pcTables
LOCAL lcAliases

RemoveWellnessFrontOffice()
IF NOT EMPTY(pcTables)
     lcAliases = WOAliasList(pcTables)
     FOR lnTableNo = 1 TO GETWORDCOUNT(lcAliases, ",")
          lcAlias = ALLTRIM(GETWORDNUM(lcAliases, lnTableNo, ","))
          CloseFile(lcAlias)
     NEXT
ENDIF
ENDPROC
*
FUNCTION WOUse
LPARAMETERS pcTables
LOCAL lcAliases, llSuccess

lcAliases = WOAliasList(pcTables)
llSuccess = BatchOpenWellnessTable(pcTables, lcAliases)

RETURN llSuccess
ENDFUNC
*
FUNCTION WOQuery
LPARAMETERS pcTables
LOCAL lcAliases, llSuccess

lcAliases = WOAliasList(pcTables)
llSuccess = BatchQueryWellnessTable(pcTables, lcAliases)

RETURN llSuccess
ENDFUNC
*
FUNCTION WOSqlQuery
LPARAMETERS pcTables, pcSqlStatement
LOCAL lcAliases, llSuccess

lcAliases = WOAliasList(pcTables)
llSuccess = WellnessSqlQuery(pcTables, lcAliases, pcSqlStatement)

RETURN llSuccess
ENDFUNC
*
FUNCTION WOAliasList
LPARAMETERS pcTables
LOCAL lnTableNo, lcAlias, lcAliases

lcAliases = pcTables
FOR lnTableNo = 1 TO GETWORDCOUNT(lcAliases, ",")
     lcAlias = ALLTRIM(GETWORDNUM(lcAliases, lnTableNo, ","))
     lcAliases = STRTRAN(lcAliases, lcAlias, "WO"+lcAlias, 1, 1)
NEXT

RETURN lcAliases
ENDFUNC
*
FUNCTION WOGetParam
LPARAMETERS pcArgParamField, puRetval
LOCAL llParamPicked

IF WellnessOffice("", "", "", .T.) AND WellnessOffice("Use", "Param", "", .T.) AND DLocate("WOParam", "UPPER(pa_name) = " + SqlCnv(UPPER(pcArgParamField)))
     DO CASE
          CASE INLIST(WOParam.pa_type, "C", "M")
               puRetval = ALLTRIM(WOParam.pa_value)
          CASE INLIST(WOParam.pa_type, "N", "I")
               puRetval = INT(VAL(WOParam.pa_value))
          CASE WOParam.pa_type = "B"
               puRetval = VAL(WOParam.pa_value)
          CASE WOParam.pa_type = "L"
               puRetval = (ALLTRIM(UPPER(WOParam.pa_value)) == ".T.")
          CASE WOParam.pa_type = "D"
               puRetval = CTOD(WOParam.pa_value)
          CASE WOParam.pa_type = "T"
               puRetval = CTOT(WOParam.pa_value)
          OTHERWISE
     ENDCASE
     llParamPicked = .T.
ENDIF
WellnessOffice("Exit")

RETURN llParamPicked
ENDFUNC
***********************************************************************************************************
FUNCTION DeleteAppointments
LPARAMETERS pnReserId, plDeleteAllowed
LOCAL lnArea
LOCAL ARRAY laApps(3)

lnArea = SELECT()

plDeleteAllowed = .T.
IF NOT EMPTY(pnReserId) AND WellnessOffice(,,,.T.) AND WellnessOffice("Use", "Appset, Appoint, Pckapset, Groupart",,.T.)
     laApps = 0
     IF DLocate("WOAppset", "as_rsid = " + SqlCnv(pnReserId)) OR DLocate("WOGroupart", "gp_rsid = " + SqlCnv(pnReserId))
          SELECT COUNT(ap_appid), MIN(ap_start), MAX(ap_end) FROM WOAppoint ;
               INNER JOIN WOAppset ON as_setid = ap_setid ;
               LEFT JOIN WOGroupart ON gp_groupid = as_groupid ;
               WHERE as_rsid = pnReserId OR gp_rsid = pnReserId ;
               ORDER BY ap_start ;
               INTO ARRAY laApps
     ENDIF
     IF laApps(1) > 0
          IF YesNo(Str2Msg(GetLangText("WELLNESS","TA_DELETE_APPOINTMENTS_1"), "%s", ;
                    ALLTRIM(STR(laApps(1))), LEFT(TTOC(laApps(2)),10), LEFT(TTOC(laApps(3)),10)) + GetLangText("WELLNESS","TA_DELETE_APPOINTMENTS_2"))
               IF DLocate("WOAppset", "as_rsid = " + SqlCnv(pnReserId))
                    SELECT WOAppset
                    SCAN FOR as_rsid = pnReserId
                         SqlDelete("WOPckapset", "ag_setid = " + SqlCnv(WOAppset.as_setid))
                         SqlDelete("WOAppoint", "ap_setid = " + SqlCnv(WOAppset.as_setid))
                    ENDSCAN
                    SqlDelete("WOAppset", "as_rsid = " + SqlCnv(pnReserId))
               ENDIF
               IF DLocate("WOGroupart", "gp_rsid = " + SqlCnv(pnReserId))
                    SqlDelete("WOGroupart", "gp_rsid = " + SqlCnv(pnReserId))
               ENDIF
          ELSE
               plDeleteAllowed = .F.
          ENDIF
     ENDIF
     WellnessOffice("Exit")
ENDIF

SELECT (lnArea)

RETURN plDeleteAllowed
ENDFUNC
*