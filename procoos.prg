FUNCTION SetRoomsStatus
LPARAMETERS tcNewRoomStatus, tcRoomnum
LOCAL l_nSelected, l_dSysDate, l_cSql, l_cCurRP

IF EMPTY(tcNewRoomStatus)
	tcNewRoomStatus = "DIR"
ENDIF

l_nSelected = SELECT()

l_dSysDate = sysdate()
l_cCurRP = SYS(2015)

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT DISTINCT rm_roomnum, rm_status, CAST(NVL(rp_status,0) AS Numeric(2)) AS rp_status 
	FROM room 
	LEFT JOIN roomplan ON rm_roomnum = rp_roomnum AND rp_date = <<sqlcnv(l_dSysDate,.T.)>> AND rp_status < 0 
	<<IIF(EMPTY(tcRoomnum), "", "WHERE rm_roomnum = " + sqlcnv(tcRoomnum,.T.))>>
	ORDER BY 1,2,3
ENDTEXT

sqlcursor(l_cSql, l_cCurRP)
SCAN ALL
	DO CASE
		CASE rp_status = 0
			IF INLIST(rm_status, "OOO", "OOS")
				sqlupdate("room","rm_roomnum = " + sqlcnv(rm_roomnum,.T.),"rm_status = " + sqlcnv(tcNewRoomStatus,.T.))
			ENDIF
		CASE rp_status = -1
			IF rm_status <> "OOO"
				sqlupdate("room","rm_roomnum = " + sqlcnv(rm_roomnum,.T.),"rm_status = " + sqlcnv("OOO",.T.))
			ENDIF
		CASE rp_status = -2
			IF rm_status <> "OOS"
				sqlupdate("room","rm_roomnum = " + sqlcnv(rm_roomnum,.T.),"rm_status = " + sqlcnv("OOS",.T.))
			ENDIF
	ENDCASE
ENDSCAN
dclose(l_cCurRP)
DoTableUpdate(.T.,.T.,"room")

SELECT (l_nSelected)
RETURN .T.
ENDFUNC
*
FUNCTION DeleteExpiredOOS
LOCAL l_nSelect, l_cChanges, l_lOOSClose, l_dSysDate, l_lCloseHOutOfSr
l_dSysDate = g_sysdate
l_nSelect = SELECT()
l_lOOSClose = NOT USED("outofser")
l_lCloseHOutOfSr = NOT USED("HOutOfSr")
IF OpenFile(.f.,'OutOfSer') AND OpenFile(.f.,'HOutOfSr')
	SELECT OutOfSer
	SCAN FOR l_dSysDate >= os_todat
		IF NOT OutOfSer.os_cancel
			l_cChanges = rsHistry(os_changes, "DELETED", "Automatic delete in Audit")
			REPLACE os_changes WITH l_cChanges IN OutOfSer
		ENDIF
		= FromOOSToHist(OutOfSer.os_id)
	ENDSCAN
ENDIF
IF l_lCloseHOutOfSr
	CloseFile('HOutOfSr')
ENDIF
IF l_lOOSClose
	CloseFile('OutOfSer')
ENDIF
SELECT (l_nSelect)
ENDFUNC
*
PROCEDURE FromOOSToHist
LPARAMETERS lp_nOOSId
LOCAL l_nSelect, l_lCloseHOutOfSr, l_oOOSObj
l_nSelect = SELECT()
IF NOT USED("HOutOfSr")
	openfiledirect(.F.,"houtofsr")
	l_lCloseHOutOfSr = .T.
ENDIF
IF (lp_nOOSId = OutOfSer.os_id) OR SEEK(lp_nOOSId,"OutOfSer","tag1")
	SELECT OutOfSer
	SCATTER NAME l_oOOSObj MEMO
	SELECT HOutOfSr
	IF NOT SEEK(lp_nOOSId,"HOutOfSr","tag1")
		APPEND BLANK
		GATHER NAME l_oOOSObj MEMO
	ELSE
		GATHER NAME l_oOOSObj
		IF NOT (HOutOfSr.os_changes == OutOfSer.os_changes)
	* Memo fields are replace only if there are changed.
			REPLACE os_changes WITH OutOfSer.os_changes IN HOutOfSr
		ENDIF
	ENDIF
	DELETE IN OutOfSer
ENDIF
IF l_lCloseHOutOfSr
	USE IN HOutOfSr
ENDIF
SELECT (l_nSelect)
ENDPROC
*
PROCEDURE OOSAllowed
LPARAMETERS tnRecordId, tcRoomnum, toData
LOCAL lcSql, lcRoomPlanCur, lcMessage

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT TOP 1 rp_roomnum, rp_date, rp_status, rp_reserid, rp_nights FROM roomplan 
          WHERE rp_roomnum = <<SqlCnv(tcRoomnum,.T.)>> AND 
          rp_date BETWEEN <<SqlCnv(toData.os_fromdat,.T.)>> AND <<SqlCnv(toData.os_todat-1,.T.)>>
          <<IIF(EMPTY(tnRecordId), "", " AND NOT rp_osid = " + SqlCnv(tnRecordId,.T.))>> 
          ORDER BY 1, 2, 3, 4, 5
ENDTEXT
lcRoomPlanCur = SqlCursor(lcSql, lcRoomPlanCur)
DO CASE
     CASE EMPTY(lcRoomPlanCur) OR NOT USED(lcRoomPlanCur) OR RECCOUNT(lcRoomPlanCur) = 0 OR EMPTY(rp_roomnum)          && OK
          lcMessage = ""
          IF NOT RIIsRmFreeExtReser(toData.os_fromdat,toData.os_todat-1,tcRoomnum,@lcMessage)
               llExclusiveNo = .T.
          ENDIF
     CASE rp_status = -1          && Found OOO
          llExclusiveNo = .T.
          lcMessage = Str2Msg(GetLangTexT("RESERV2","T_OOOROOM")+".", "%s", ;
               Get_rm_rmname(rp_roomnum), DTOC(rp_date), DTOC(rp_date+rp_nights))
     CASE rp_status = -2          && Found OOS
          llExclusiveNo = .T.
          lcMessage = Str2Msg(GetLangTexT("RESERV2","T_OOSROOM")+".", "%s", ;
               Get_rm_rmname(rp_roomnum), DTOC(rp_date), DTOC(rp_date+rp_nights))
     OTHERWISE                    && Found reservation
          lcMessage = GetLangText("OUTOFORD","TA_RESFOUND") + ";" + GetLangText("OUTOFORD","T_ROOMNUM") + ": %s1;" + ;
               GetLangText("MGRRESER","TXT_DATE") + ": %s2;" + GetLangText("RESERVAT","T_RESNUM") + ": %s3!"
          lcMessage = Str2Msg(lcMessage, "%s", Get_rm_rmname(rp_roomnum), DTOC(rp_date), TRANSFORM(rp_reserid))
ENDCASE
DClose(lcRoomPlanCur)

RETURN lcMessage
ENDPROC
*
DEFINE CLASS cOOS AS cbobj OF commonclasses.prg
*
HIDDEN ocaroom
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS cOOS OF procoos.prg
#ENDIF
*
WheredFromDate = {}
WheredToDate = {}
WherenFloor = -1
WherecBuilding = ""
ocaroom = .NULL.
*
PROCEDURE ListGet
LOCAL l_lSuccess, l_nSelect, l_cSql, l_cCur, l_cWhere
PRIVATE p_dFromDate, p_dToDate, p_nFloor, p_cBuilding

l_nSelect = SELECT()

IF NOT (openfile(,"outofser") AND openfile(,"room") AND openfile(,"roomtype"))
     SELECT (l_nSelect)
     RETURN l_lSuccess
ENDIF

l_cWhere = ""
IF this.WherenFloor <> -1
     p_nFloor = this.WherenFloor
     l_cWhere = SqlAnd(l_cWhere, 'rm_floor = __SQLPARAM__p_nFloor')
ENDIF
IF NOT EMPTY(this.WherecBuilding)
     p_cBuilding = this.WherecBuilding
     l_cWhere = SqlAnd(l_cWhere, 'rt_buildng = __SQLPARAM__p_cBuilding')
ENDIF
IF NOT EMPTY(this.WheredFromDate)
     p_dFromDate = this.WheredFromDate
     l_cWhere = SqlAnd(l_cWhere, "os_todat > __SQLPARAM__p_dFromDate")
ENDIF
IF NOT EMPTY(this.WheredToDate)
     p_dToDate = this.WheredToDate
     l_cWhere = SqlAnd(l_cWhere, "os_fromdat <= __SQLPARAM__p_dToDate")
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT os_id, os_roomnum, rm_rmname AS c_rmname, rd_roomtyp AS c_roomtyp, os_fromdat, os_todat, os_reason, CAST(NVL(rm_floor,0) AS Num(2)) AS rm_floor,
     CAST(NVL(rm_roomtyp,"") AS Char(4)) AS rm_roomtyp, CAST(NVL(rt_buildng,"") AS Char(3)) rt_buildng, 0=1 AS c_selected 
     FROM outofser 
     LEFT JOIN room ON rm_roomnum = os_roomnum
     LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp 
     LEFT JOIN rtypedef ON rt_rdid = rd_rdid 
     WHERE <<SqlAnd(l_cWhere, "NOT os_cancel")>>
     ORDER BY 2, 3
ENDTEXT

l_cCur = sqlcursor(l_cSql,this.cListCur,.F.,"",.NULL.,.T.,,.T.)
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)
IF l_lSuccess
     this.cListCur = l_cCur
     this.Export(this.cListCur)
ENDIF
SELECT (l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE FloorsGet
LOCAL l_nArea, l_lSuccess

l_nArea = SELECT()

IF NOT (openfile(,"room"))
     SELECT (l_nSelect)
     RETURN l_lSuccess
ENDIF

l_cCur = sqlcursor("SELECT DISTINCT TRANSFORM(rm_floor)+'. "+GetLangText("HOUSE","T_FLOOR")+"' AS descript, rm_floor FROM room UNION SELECT '', -1 FROM room ORDER BY 2")
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)

IF l_lSuccess
     this.Export(l_cCur)
     DClose(l_cCur)
ENDIF

SELECT (l_nArea)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE RoomsGet
LOCAL l_nArea, l_lSuccess, l_cSql

l_nArea = SELECT()

IF NOT (openfile(,"room") AND openfile(,"roomtype"))
     SELECT (l_nSelect)
     RETURN l_lSuccess
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT rm_roomnum, rm_rmname, rm_lang<<g_langnum>> AS rm_lang, rm_floor, NVL(rt_buildng,"   ") AS rt_buildng 
     FROM room
     LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp
     <<IIF(_screen.oGlobal.oParam2.pa_ooostd, "WHERE rt_group IN (1,4)", "")>>
     ORDER BY rm_rpseq, rm_rmname
ENDTEXT

l_cCur = sqlcursor(l_cSql)
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)

IF l_lSuccess
     SELECT rm_roomnum, rm_rmname + " " + rt_buildng + " " + rm_lang AS c_rmname, rm_rmname, rm_lang, rm_floor, rt_buildng FROM (l_cCur) WHERE 1=1 INTO CURSOR (l_cCur)
     this.Export(l_cCur)
     DClose(l_cCur)
ENDIF

SELECT (l_nArea)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE OOSDelete
LPARAMETERS lp_nId
LOCAL l_lSuccess, locaOutOfSer, lcRoomStatus
lcRoomStatus = ""
l_lSuccess = .T.

OpenFile(,"availab",,,5)
OpenFile(,"roomplan",,,5)
OpenFile(,"room",,,5)
locaOutOfSer = CREATEOBJECT("caOutOfSer")
locaOutOfSer.cFilterClause = "os_id = " + SqlCnv(lp_nId,.T.)
locaOutOfSer.CursorFill()
SELECT caOutOfSer
SCATTER MEMO NAME loDataOld
SCATTER MEMO BLANK NAME loDataNew
REPLACE os_cancel WITH .T., os_changes WITH RsHistry(os_changes, "DELETED", "")
DO OosUpdate IN AvlUpdat WITH loDataOld, loDataNew
DO CASE
     CASE NOT EMPTY(lcRoomStatus) OR NOT _screen.oGlobal.oParam.pa_rmstat OR NOT BETWEEN(SysDate(), os_fromdat, os_todat-1)
     OTHERWISE
          lcRoomStatus = "DIR"
ENDCASE
DO SetRoomsStatus IN ProcOos WITH lcRoomStatus, os_roomnum
locaOutOfSer.DoTableUpdate()

DClose("availab")
DClose("roomplan")
DClose("room")

RETURN l_lSuccess
ENDPROC
*
PROCEDURE OOSUpdate
LPARAMETERS lp_cJSON, lp_lForce
LOCAL l_oJSON, l_oData, l_cResult, lcAllowedMessage, loDataOld, loDataNew, lcChanges

l_cResult = "OK"

IF NOT EMPTY(lp_cJSON)
     l_oJSON = NEWOBJECT("json","common\progs\json.prg")
     l_oData = l_oJSON.parse(lp_cJSON)
ENDIF

IF VARTYPE(l_oData) <> "O"
     l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 001"
     RETURN l_cResult
ENDIF

IF NOT (openfile(,"outofser") AND openfile(,"room"))
     l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 002"
     RETURN l_cResult
ENDIF

SELECT room
LOCATE FOR rm_roomnum = l_oData.os_roomnum
IF NOT FOUND()
     l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 003"
     RETURN l_cResult
ENDIF

l_oData.os_fromdat = CTOD(LEFT(l_oData.os_fromdat,10))
l_oData.os_todat = CTOD(LEFT(l_oData.os_todat,10))

IF EMPTY(l_oData.os_roomnum)
     l_cResult = GetLangText("MGRRESER","TXT_ROOMREQ")
     RETURN l_cResult
ENDIF

IF EMPTY(l_oData.os_fromdat)
     l_cResult = GetLangText("OUTOFORD","TH_FROM") + " " + GetLangText("COMMON","TXT_FIELD_IS_REQUIRED")
     RETURN l_cResult
ENDIF

IF EMPTY(l_oData.os_todat)
     l_cResult = GetLangText("OUTOFORD","TH_TO") + " " + GetLangText("COMMON","TXT_FIELD_IS_REQUIRED")
     RETURN l_cResult
ENDIF

IF l_oData.os_fromdat < sysdate()
     l_cResult = GetLangText("BILL","T_NOTVALIDFIELDS") + " " + GetLangText("OUTOFORD","TH_FROM")
     RETURN l_cResult
ENDIF

IF l_oData.os_fromdat >= l_oData.os_todat
     l_cResult = GetLangText("BILL","T_NOTVALIDFIELDS") + " " + GetLangText("OUTOFORD","TH_TO")
     RETURN l_cResult
ENDIF

IF NOT lp_lForce
     lcAllowedMessage = OOSAllowed(l_oData.os_id, l_oData.os_roomnum, l_oData)
     IF NOT EMPTY(lcAllowedMessage)
          l_cResult = lcAllowedMessage + "|ALLOW"
          RETURN l_cResult
     ENDIF
ENDIF

SELECT outofser
IF EMPTY(l_oData.os_id)
     SCATTER MEMO BLANK NAME loDataOld
     l_oData.os_id = NextId("OUTOFSER")
     INSERT INTO outofser FROM NAME l_oData
     DO OosUpdate IN AvlUpdat WITH loDataOld, l_oData
ELSE
     LOCATE FOR os_id = l_oData.os_id
     IF FOUND()
          SCATTER MEMO NAME loDataOld
          ADDPROPERTY(l_oData, "os_changes", os_changes)
          lcChanges = ""
          IF l_oData.os_fromdat <> loDataOld.os_fromdat
               lcChanges = lcChanges+IIF(EMPTY(lcChanges), "", ",")+GetLangText("ADDRESS","TXT_FROM")+" "+DTOC(l_oData.os_fromdat)+"..."+DTOC(loDataOld.os_fromdat)
          ENDIF
          IF l_oData.os_todat <> loDataOld.os_todat
               lcChanges = lcChanges+IIF(EMPTY(lcChanges), "", ",")+GetLangText("ADDRESS","TXT_TO")+" "+DTOC(l_oData.os_todat)+"..."+DTOC(loDataOld.os_todat)
          ENDIF
          IF l_oData.os_roomnum <> loDataOld.os_roomnum
               lcChanges = lcChanges+IIF(EMPTY(lcChanges), "", ",")+GetLangText("OUTOFORD","T_ROOMNUM")+" "+Get_rm_rmname(l_oData.os_roomnum)+"..."+Get_rm_rmname(loDataOld.os_roomnum)
          ENDIF
          IF NOT EMPTY(lcChanges)
               l_oData.os_changes = RsHistry(l_oData.os_changes, "CHANGED", lcChanges)
          ENDIF
          GATHER MEMO NAME l_oData FIELDS os_roomnum, os_fromdat, os_todat, os_reason, os_changes
          SCATTER MEMO NAME loDataNew
          DO OosUpdate IN AvlUpdat WITH loDataOld, loDataNew
     ELSE
          l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 004"
          RETURN l_cResult
     ENDIF
ENDIF

DO SetRoomsStatus IN ProcOos WITH "DIR", l_oData.os_roomnum

RETURN l_cResult
ENDPROC
*
ENDDEFINE
*