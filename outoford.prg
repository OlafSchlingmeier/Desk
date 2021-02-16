*
*PROCEDURE OutOfOrd
 do form "forms\MngForm" with "MngOOOCtrl"
 RETURN
ENDPROC
*
FUNCTION ooodelete
LPARAMETERS PSysDate
LOCAL LSelectedTable, LCxlData, LOOOUsed, l_lCloseHOutOfOr
LOOOUsed = .F.
LCxlData = ""
IF PCOUNT()=0
	PSysDate = g_sysdate
ENDIF
LSelectedTable = ALIAS()
LOOOUsed = USED('outoford')
l_lCloseHOutOfOr = not USED('outoford')
IF OpenFile(.f.,'OutOfOrd') AND OpenFile(.f.,'HOutOfOr')
	SELECT outoford
	SCAN FOR PSysDate >= OuTOfOrd.oo_todat
		LCxlData = ALLTRIM(PADR(DATETIME(),19)) + "/" + "AUTOMATIC" 
		IF NOT OuTOfOrd.oo_cancel
			REPLACE oo_cxlwh WITH LCxlData IN OuTOfOrd
		ENDIF
		= FromOOOToHist(OutOfOrd.oo_id)
	ENDSCAN
ENDIF
IF l_lCloseHOutOfOr
	CloseFile('HOutOfOr')
ENDIF
IF !LOOOUsed
	CloseFile('OutOfOrd')
ENDIF
IF !EMPTY(LSelectedTable)
	SELECT &LSelectedTable
ENDIF
ENDFUNC
*
PROCEDURE FromOOOToHist
LPARAMETERS lp_nOOOId
LOCAL l_nSelect, l_lCloseHOutOfOr, l_oOOOObj
l_nSelect = SELECT()
IF NOT USED("HOutOfOr")
	openfiledirect(.F.,"houtofor")
	l_lCloseHOutOfOr = .T.
ENDIF
IF (lp_nOOOId = OutOfOrd.oo_id) OR SEEK(lp_nOOOId,"OutOfOrd","tag1")
	SELECT OutOfOrd
	SCATTER NAME l_oOOOObj MEMO
	SELECT HOutOfOr
	IF NOT SEEK(lp_nOOOId,"HOutOfOr","tag1")
		APPEND BLANK
		GATHER NAME l_oOOOObj MEMO
	ELSE
		GATHER NAME l_oOOOObj
		IF NOT (HOutOfOr.rs_message == OutOfOrd.rs_message)
	* Memo fields are replace only if there are changed.
			REPLACE rs_message WITH OutOfOrd.rs_message IN HOutOfOr
		ENDIF
	ENDIF
	DELETE IN OutOfOrd
ENDIF
IF l_lCloseHOutOfOr
	USE IN HOutOfOr
ENDIF
SELECT (l_nSelect)
ENDPROC
*
PROCEDURE OOOAllowed
LPARAMETERS tnRecordId, tcRoomnum, toData
LOCAL lcSql, lcRoomPlanCur, lcMessage

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT TOP 1 rp_roomnum, rp_date, rp_status, rp_reserid, rp_nights FROM roomplan 
          WHERE rp_roomnum = <<SqlCnv(tcRoomnum,.T.)>> AND 
          rp_date BETWEEN <<SqlCnv(toData.oo_fromdat,.T.)>> AND <<SqlCnv(toData.oo_todat-1,.T.)>>
          <<IIF(EMPTY(tnRecordId), "", " AND NOT rp_ooid = " + SqlCnv(tnRecordId,.T.))>> 
          ORDER BY 1, 2, 3, 4, 5
ENDTEXT
lcRoomPlanCur = SqlCursor(lcSql, lcRoomPlanCur)
DO CASE
     CASE EMPTY(lcRoomPlanCur) OR NOT USED(lcRoomPlanCur) OR RECCOUNT(lcRoomPlanCur) = 0 OR EMPTY(rp_roomnum)          && OK
          lcMessage = ""
          IF NOT RIIsRmFreeExtReser(toData.oo_fromdat,toData.oo_todat-1,tcRoomnum,@lcMessage)
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
DEFINE CLASS cOOO AS cbobj OF commonclasses.prg
*
HIDDEN ocaroom
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS cOOO OF oufoford.prg
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

IF NOT (openfile(,"outoford") AND openfile(,"room") AND openfile(,"roomtype"))
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
     l_cWhere = SqlAnd(l_cWhere, "oo_todat > __SQLPARAM__p_dFromDate")
ENDIF
IF NOT EMPTY(this.WheredToDate)
     p_dToDate = this.WheredToDate
     l_cWhere = SqlAnd(l_cWhere, "oo_fromdat <= __SQLPARAM__p_dToDate")
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT oo_id, oo_roomnum, rm_rmname AS c_rmname, rd_roomtyp AS c_roomtyp, oo_fromdat, oo_todat, oo_reason, oo_status, CAST(NVL(rm_floor,0) AS Num(2)) AS rm_floor,
     CAST(NVL(rm_roomtyp,"") AS Char(4)) AS rm_roomtyp, CAST(NVL(rt_buildng,"") AS Char(3)) rt_buildng, 0=1 AS c_selected, outoford.rs_message, outoford.rs_msgshow 
     FROM outoford
     LEFT JOIN room ON rm_roomnum = oo_roomnum
     LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp 
     LEFT JOIN rtypedef ON rt_rdid = rd_rdid 
     WHERE <<SqlAnd(l_cWhere, "NOT oo_cancel")>>
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
PROCEDURE OOODelete
LPARAMETERS lp_nId
LOCAL l_lSuccess, locaOutOfOrd, lcRoomStatus
lcRoomStatus = ""
l_lSuccess = .T.

OpenFile(,"availab",,,5)
OpenFile(,"roomplan",,,5)
OpenFile(,"room",,,5)
locaOutOfOrd = CREATEOBJECT("caOutOfOrd")
locaOutOfOrd.cFilterClause = "oo_id = " + SqlCnv(lp_nId,.T.)
locaOutOfOrd.CursorFill()
SELECT caOutOfOrd
SCATTER MEMO NAME loDataOld
SCATTER MEMO BLANK NAME loDataNew
REPLACE oo_cancel WITH .T., oo_cxlwh WITH ALLTRIM(PADR(DATETIME(),19)) + "/" + PADR(g_userid,10)
DO OooUpdate IN AvlUpdat WITH loDataOld, loDataNew
DO CASE
     CASE NOT EMPTY(lcRoomStatus) OR NOT _screen.oGlobal.oParam.pa_rmstat OR NOT BETWEEN(SysDate(), oo_fromdat, oo_todat-1)
     OTHERWISE
          lcRoomStatus = "DIR"
ENDCASE
DO SetRoomsStatus IN ProcOos WITH lcRoomStatus, oo_roomnum
locaOutOfOrd.DoTableUpdate()

DClose("availab")
DClose("roomplan")
DClose("room")

RETURN l_lSuccess
ENDPROC
*
PROCEDURE OOONote
LPARAMETERS lp_nId, lp_cNote, lp_MsgShow
LOCAL l_lSuccess

IF NOT openfile(,"outoford")
     RETURN l_lSuccess
ENDIF

REPLACE rs_message WITH lp_cNote, rs_msgshow WITH lp_MsgShow FOR oo_id = lp_nId IN outoford
FLUSH

l_lSuccess = .T.

RETURN l_lSuccess
ENDPROC
*
PROCEDURE OOOUpdate
LPARAMETERS lp_cJSON, lp_lForce
LOCAL l_oJSON, l_oData, l_cResult, lcAllowedMessage, loDataOld, loDataNew

l_cResult = "OK"

IF NOT EMPTY(lp_cJSON)
     l_oJSON = NEWOBJECT("json","common\progs\json.prg")
     l_oData = l_oJSON.parse(lp_cJSON)
ENDIF

IF VARTYPE(l_oData) <> "O"
     l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 001"
     RETURN l_cResult
ENDIF

IF NOT (openfile(,"outoford") AND openfile(,"room"))
     l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 002"
     RETURN l_cResult
ENDIF

SELECT room
LOCATE FOR rm_roomnum = l_oData.oo_roomnum
IF NOT FOUND()
     l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 003"
     RETURN l_cResult
ENDIF

l_oData.oo_fromdat = CTOD(LEFT(l_oData.oo_fromdat,10))
l_oData.oo_todat = CTOD(LEFT(l_oData.oo_todat,10))

IF EMPTY(l_oData.oo_roomnum)
     l_cResult = GetLangText("MGRRESER","TXT_ROOMREQ")
     RETURN l_cResult
ENDIF

IF EMPTY(l_oData.oo_fromdat)
     l_cResult = GetLangText("OUTOFORD","TH_FROM") + " " + GetLangText("COMMON","TXT_FIELD_IS_REQUIRED")
     RETURN l_cResult
ENDIF

IF EMPTY(l_oData.oo_todat)
     l_cResult = GetLangText("OUTOFORD","TH_TO") + " " + GetLangText("COMMON","TXT_FIELD_IS_REQUIRED")
     RETURN l_cResult
ENDIF

IF l_oData.oo_fromdat < sysdate()
     l_cResult = GetLangText("BILL","T_NOTVALIDFIELDS") + " " + GetLangText("OUTOFORD","TH_FROM")
     RETURN l_cResult
ENDIF

IF l_oData.oo_fromdat >= l_oData.oo_todat
     l_cResult = GetLangText("BILL","T_NOTVALIDFIELDS") + " " + GetLangText("OUTOFORD","TH_TO")
     RETURN l_cResult
ENDIF

IF NOT lp_lForce
     lcAllowedMessage = OOOAllowed(l_oData.oo_id, l_oData.oo_roomnum, l_oData)
     IF NOT EMPTY(lcAllowedMessage)
          l_cResult = lcAllowedMessage + "|ALLOW"
          RETURN l_cResult
     ENDIF
ENDIF

SELECT outoford
IF EMPTY(l_oData.oo_id)
     SCATTER MEMO BLANK NAME loDataOld
     l_oData.oo_id = NextId("OUTOFORD")
     l_oData.rs_msgshow = _screen.oGlobal.oParam.pa_msgshow
     INSERT INTO outoford FROM NAME l_oData
     DO OooUpdate IN AvlUpdat WITH loDataOld, l_oData
ELSE
     LOCATE FOR oo_id = l_oData.oo_id
     IF FOUND()
          SCATTER MEMO NAME loDataOld
          GATHER NAME l_oData FIELDS oo_roomnum, oo_fromdat, oo_todat, oo_reason, rs_msgshow
          SCATTER MEMO NAME loDataNew
          DO OooUpdate IN AvlUpdat WITH loDataOld, loDataNew
     ELSE
          l_cResult = GetLangText("ERRORSYS","TXT_ACTION_FAILED") + " Code: 004"
          RETURN l_cResult
     ENDIF
ENDIF

DO SetRoomsStatus IN ProcOos WITH "DIR", l_oData.oo_roomnum

RETURN l_cResult
ENDPROC
*
ENDDEFINE
*