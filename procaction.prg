 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
			lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
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
PROCEDURE ActInsert
LPARAMETERS lp_record, lp_cMode, lp_cUserGroup, lp_lSetFilter, lp_cFilterCursorName, lp_oCaAction AS cabase OF common\libs\cit_ca.vcx, ;
		lp_lNoTableUpdate
 LOCAL l_cCurUser, l_nSelect
 l_nSelect = SELECT()
 IF lp_lSetFilter
	IF EMPTY(lp_cFilterCursorName)
		lp_lSetFilter = .F.
	ENDIF
	IF NOT USED(lp_cFilterCursorName)
		lp_lSetFilter = .F.
	ENDIF
 ENDIF
 IF PCOUNT()<6 OR VARTYPE(lp_oCaAction)<>"O"
 	lp_oCaAction = CREATEOBJECT("caaction")
 	IF lp_cMode == 'NEW'
 		lp_oCaAction.cFilterclause = "0=1"
 	ELSE
 		lp_oCaAction.cFilterclause = "at_atid = " + sqlcnv(lp_record.at_atid,.T.)
 	ENDIF
 	lp_oCaAction.CursorFill()
 ENDIF
 SELECT (lp_oCaAction.Alias)
 IF EMPTY(lp_cUserGroup)
	lp_record.at_time = ActRemoveDoublePoint(lp_record.at_time)
	IF lp_cMode == 'NEW'
		lp_record.at_atid = nextid("ACTION")
		IF EMPTY(lp_record.at_insuser)
			lp_record.at_insuser = g_Userid
		ENDIF
		lp_record.at_insdate = sysdate()
		lp_record.at_instime = TIME()
		APPEND BLANK
		GATHER NAME lp_record MEMO
	ELSE
		lp_record.at_status = 0
		GATHER NAME lp_record MEMO
	ENDIF
	IF lp_lSetFilter
		IF NOT dlocate(lp_cFilterCursorName, "at_atid = " + sqlcnv(lp_record.at_atid))
			INSERT INTO (lp_cFilterCursorName) (at_atid) VALUES (lp_record.at_atid)
		ENDIF
		l_lChanged = .T.
	ENDIF
 ELSE
	IF lp_cMode == 'EDIT'
		DELETE IN (lp_oCaAction.Alias)
	ENDIF
	l_cCurUser = sqlcursor('SELECT us_id, us_group FROM "user" WHERE NOT us_inactiv AND us_group = ' + sqlcnv(lp_cUserGroup,.T.))
	SELECT (l_cCurUser)
	SCAN FOR us_group = lp_cUserGroup
		lp_record.at_userid = us_id
		lp_record.at_time = ActRemoveDoublePoint(lp_record.at_time)
		IF lp_cMode == 'NEW'
			lp_record.at_atid = nextid("ACTION")
			IF EMPTY(lp_record.at_insuser)
				lp_record.at_insuser = g_Userid
			ENDIF
			lp_record.at_insdate = sysdate()
			lp_record.at_instime = TIME()
		ENDIF
		SELECT (lp_oCaAction.Alias)
		APPEND BLANK
		GATHER NAME lp_record MEMO
		IF lp_lSetFilter
			IF NOT dlocate(lp_cFilterCursorName, "at_atid = " + sqlcnv(lp_record.at_atid))
				INSERT INTO (lp_cFilterCursorName) (at_atid) VALUES (lp_record.at_atid)
			ENDIF
		ENDIF
	ENDSCAN
	dclose(l_cCurUser)
 ENDIF
 IF NOT lp_lNoTableUpdate
 	lp_oCaAction.DoTableUpdate(.T.)
 ELSE
 	TABLEUPDATE(.T.,.T.,lp_oCaAction.Alias)
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE CheckForActions
 LPARAMETERS lp_lFoundAction
 LOCAL l_nSelect, l_cCursor, l_cSql

 l_nSelect = SELECT()

 lp_lFoundAction = .F.
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
  SELECT TOP 1 at_atid FROM action ;
       WHERE at_userid IN (<<sqlcnv("          ",.T.)>>, <<sqlcnv(g_userid,.T.)>>) ;
       AND at_date = <<sqlcnv(g_sysdate,.T.)>> AND ;
       at_compl = __EMPTY_DATE__ ORDER BY 1
 ENDTEXT
 l_cCursor = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
 IF RECCOUNT(l_cCursor) > 0
      lp_lFoundAction = .T.
 ENDIF
 dclose(l_cCursor)

 SELECT (l_nSelect)

 RETURN lp_lFoundAction
ENDPROC
*
PROCEDURE CheckNewTimeActions
 LPARAMETERS lp_nActions
 LOCAL l_nSelect, l_cTime, l_cCur, l_cSql
 lp_nActions = 0
 l_cTime = TIME()
 l_nSelect = SELECT()

 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
 SELECT at_atid ;
      FROM action ;
      WHERE (at_userid = <<sqlcnv(SPACE(10),.T.)>> OR at_userid = <<sqlcnv(g_userid,.T.)>>) AND ;
      at_compl = {} AND ;
      at_status = 0 AND ;
      NOT at_time = <<sqlcnv(SPACE(5),.T.)>> AND at_time <= <<sqlcnv(l_cTime, .T.)>> AND ;
      (at_date = {} OR at_date <= <<sqlcnv(g_sysdate,.T.)>>)
 ENDTEXT
 l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
 IF USED(l_cCur)
      SELECT (l_cCur)
      SCAN ALL
          lp_nActions = lp_nActions + 1
          sqlupdate("action", ;
                    "at_atid = " + sqlcnv(&l_cCur..at_atid,.T.), ;
                    "at_status = " + sqlcnv(2,.T.))
          *REPLACE at_status WITH 2
      ENDSCAN
      dclose(l_cCur)
 ENDIF
 SELECT (l_nSelect)
 RETURN lp_nActions
ENDPROC
*
PROCEDURE ActAudit
 LOCAL naRea, l_cCur, l_lUsed
 naRea = SELECT()
 l_lUsed = USED("action")
 IF openfile(.F.,"action")
	 l_dDate = sysdate() - 30
 	l_cCur = sqlcursor("SELECT at_atid FROM action WHERE NOT at_compl = {} AND at_compl<" + sqlcnv(l_dDate,.T.))
 	SCAN ALL
 		DO ActDelete IN procaction WITH &l_cCur..at_atid
 	ENDSCAN
 	dclose(l_cCur)
 ENDIF
 IF NOT l_lUsed
 	dclose("action")
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE ActInsertForDeletedReservations
LPARAMETERS lp_oRCMsg, lp_nAtId
LOCAL l_oMsg, l_lSetFilter, l_cActType
lp_nAtId = 0
l_lSetFilter = .F.
l_cActType = ""
l_cActType = _screen.oGlobal.oParam2.pa_rccxlat
FOR EACH l_oMsg IN lp_oRCMsg
	IF TYPE("l_oMsg.rs_lname") <> "U"
		* this is reser info
		SELECT action
		SCATTER MEMO NAME l_oActData BLANK
		l_oActData.at_acttyp = l_cActType
		l_oActData.at_reserid = l_oMsg.rs_reserid
		l_oActData.at_note = ALLTRIM(l_oMsg.rs_lname) + ;
				" # " + get_rm_rmname(l_oMsg.rs_roomnum) + ;
				" , " + STR(l_oMsg.rs_reserid,12,3)
		ActInsert(l_oActData, "NEW","",l_lSetFilter)
		lp_nAtId = l_oActData.at_atid
	ENDIF
ENDFOR

RETURN .T.
ENDPROC
*
PROCEDURE ActInsertForOptionalReservations
LPARAMETERS lp_dOptDate, lp_nReserId, lp_cResNameComp, lp_cStatus, lp_lSuccess, lp_lNoTableUpdate
LOCAL l_lSuccess, l_oActData, l_lSetFilter, l_nSelect, l_cSql, l_cCur

l_nSelect = SELECT()

l_lSuccess = .T.
IF NOT USED("action")
	l_lSuccess = openfile(.F.,"action")
ENDIF

IF l_lSuccess
	* check if we already have action for OPT or TEN status for this reservation
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
		SELECT at_atid FROM action ;
			WHERE at_reserid = <<sqlcnv(lp_nReserId)>> AND at_acttyp IN (<<sqlcnv("OPT")>>, <<sqlcnv("TEN")>>)
	ENDTEXT
	l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
	l_lSuccess = (RECCOUNT(l_cCur)=0)
ENDIF

IF l_lSuccess
	SELECT action
	SCATTER MEMO NAME l_oActData BLANK
	l_oActData.at_acttyp = lp_cStatus
	l_oActData.at_date = lp_dOptDate
	l_oActData.at_reserid = lp_nReserId
	l_oActData.at_insuser = "*"
	l_oActData.at_note = lp_cResNameComp
	l_lSetFilter = .F.
	ActInsert(l_oActData, "NEW","",l_lSetFilter,,,lp_lNoTableUpdate)
ENDIF

dclose(l_cCur)
SELECT (l_nSelect)
lp_lSuccess = l_lSuccess
RETURN l_lSuccess
ENDPROC
*
PROCEDURE ActInsertForAllotment
LPARAMETERS lp_oAltHead
LOCAL l_lSuccess, l_oActData, l_lSetFilter, l_nSelect, l_cMode, l_cCursor, l_cSql, l_cEvent

l_nSelect = SELECT()

l_lSuccess = .T.
IF NOT USED("action")
	l_lSuccess = openfile(.F.,"action")
ENDIF
IF l_lSuccess
	SELECT action
	IF NOT dlocate("action","at_altid = " + sqlcnv(lp_oAltHead.al_altid))
		l_cMode = "NEW"
		SCATTER MEMO NAME l_oActData BLANK
	ELSE
		SCATTER MEMO NAME l_oActData
		l_cMode = "EDIT"
		IF l_oActData.at_date = lp_oAltHead.al_cutdate
			* don't update action, cutdate not changed
			l_lSuccess = .F.
		ENDIF
	ENDIF
	IF l_lSuccess
		TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
			SELECT CAST(TRIM(ev_name) + ", " + TRIM(ev_city) AS Char(62)) AS AlEvent ;
				FROM evint ;
				INNER JOIN events ON ei_evid = ev_evid ;
				WHERE ei_eiid = <<sqlcnv(lp_oAltHead.al_eiid,.T.)>>
		ENDTEXT
		l_cCursor = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
		IF RECCOUNT(l_cCursor)>0
			GO TOP IN &l_cCursor
			l_cEvent = ALLTRIM(&l_cCursor..AlEvent)
		ELSE
			l_cEvent = ""
		ENDIF
		dclose(l_cCursor)

		l_oActData.at_acttyp = "KON"
		l_oActData.at_date = lp_oAltHead.al_cutdate
		l_oActData.at_altid = lp_oAltHead.al_altid
		l_oActData.at_insuser = "*"
		l_oActData.at_note = TRIM(PROPER(lp_oAltHead.al_allott)) + ", " + ;
				l_cEvent + ", " + ;
				IIF(NOT EMPTY(lp_oAltHead.al_locat),TRIM(PROPER(lp_oAltHead.al_locat)) + ", " ,"") + ;
				TRANSFORM(lp_oAltHead.al_fromdat) + "-" + TRANSFORM(lp_oAltHead.al_todat)
		l_lSetFilter = .F.
		ActInsert(l_oActData, l_cMode,"",l_lSetFilter)
	ENDIF
ENDIF

SELECT (l_nSelect)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE ActCheckAndUpdateForRelocation
LPARAMETERS tcResAlias
LOCAL llSuccess, loActData, llSetFilter, lnSelect, lcMode, lcCurResrooms, lcCurAction, lcSql, lcOldRoom, lnReserId

lnSelect = SELECT()

llSuccess = USED("resrooms") AND (USED("action") OR OpenFile(.F.,"action"))

IF llSuccess AND (DLocate("action", "at_acttyp = [MOV] AND at_reserid = " + SqlCnv(&tcResAlias..rs_reserid)) OR ;
		DLocate("resrooms", "ri_reserid = " + SqlCnv(&tcResAlias..rs_reserid) + " AND ri_date <> " + SqlCnv(&tcResAlias..rs_arrdate)))
	lnReserId = &tcResAlias..rs_reserid
	TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
		SELECT * FROM action
			WHERE at_reserid = <<SqlCnv(lnReserId,.T.)>> AND at_acttyp = <<SqlCnv('MOV',.T.)>>
	ENDTEXT
	lcCurAction = SqlCursor(lcSql,,,,,,,.T.)
	lcCurResrooms = SYS(2015)
	SELECT * FROM resrooms WITH (BUFFERING = .T.) ;
		WHERE ri_reserid = &tcResAlias..rs_reserid AND ri_date >= &tcResAlias..rs_arrdate ;
		ORDER BY ri_date ;
		INTO CURSOR &lcCurResrooms
	lcOldRoom = &lcCurResrooms..ri_roomnum
	SELECT &lcCurResrooms
	SCAN
		IF &lcCurResrooms..ri_date <> &tcResAlias..rs_arrdate
			SELECT &lcCurAction
			IF RECCOUNT(lcCurAction)=0 OR EOF(lcCurAction)
				SCATTER MEMO BLANK NAME loActData
				lcMode = "NEW"
				loActData.at_acttyp = "MOV"
				loActData.at_reserid = &lcCurResrooms..ri_reserid
				loActData.at_insuser = "*"
			ELSE
				SCATTER MEMO NAME loActData
				lcMode = "EDIT"
			ENDIF
			loActData.at_date = &lcCurResrooms..ri_date
			loActData.at_note = Str2Msg(GetText("ACT","TXT_RELOCATE"), "%s", Get_rm_rmname(lcOldRoom), Get_rm_rmname(&lcCurResrooms..ri_roomnum))
			loActData.at_insdate = SysDate()
			loActData.at_instime = TIME()
			ActInsert(loActData, lcMode,,,,,.T.)
			IF lcMode = "EDIT"
				DELETE IN &lcCurAction
				SKIP IN &lcCurAction
			ENDIF
		ENDIF
		lcOldRoom = &lcCurResrooms..ri_roomnum
	ENDSCAN
	SELECT &lcCurAction
	SCAN
		ActDelete(at_atid)
	ENDSCAN
	USE IN &lcCurResrooms
	USE IN &lcCurAction
ENDIF

SELECT (lnSelect)

RETURN llSuccess
ENDPROC
*
PROCEDURE ActDelete
LPARAMETERS lp_nAtid
IF EMPTY(lp_nAtid)
	RETURN .F.
ENDIF
sqldelete("action", "at_atid = " + sqlcnv(lp_nAtid,.T.))
FLUSH
RETURN .T.
ENDPROC
*
PROCEDURE ActCompleted
	LPARAMETERS lp_nAtId
	IF EMPTY(lp_nAtId)
		RETURN .F.
	ENDIF
	sqlupdate("action", "at_atid = " + sqlcnv(lp_nAtId,.T.), "at_compl = " + sqlcnv(sysdate(),.T.))
	RETURN .T.
ENDPROC
*
PROCEDURE ActDeleteForOptionalReservation
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_cSql
IF EMPTY(lp_nReserId)
	RETURN .F.
ENDIF

l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT at_atid FROM action ;
		WHERE at_reserid = <<sqlcnv(lp_nReserId)>> AND at_acttyp IN (<<sqlcnv("OPT")>>, <<sqlcnv("TEN")>>)
ENDTEXT
l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
IF RECCOUNT(l_cCur)>0
	SCAN FOR NOT EMPTY(&l_cCur..at_atid)
		ActDelete(&l_cCur..at_atid)
	ENDSCAN
ENDIF

dclose(l_cCur)

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ActUpdateForOptionalReservation
LPARAMETERS lp_nReserId, lp_dOptDate, lp_cStatus
IF EMPTY(lp_nReserId) OR EMPTY(lp_dOptDate) OR EMPTY(lp_cStatus)
	RETURN .T.
ENDIF
sqlupdate("action", ;
		"at_reserid = " + sqlcnv(lp_nReserId,.T.) + " AND at_acttyp IN (" + sqlcnv("OPT") + ", " + sqlcnv("TEN") + ")", ;
		"at_date = " + sqlcnv(lp_dOptDate,.T.) + ", at_acttyp = " + sqlcnv(lp_cStatus) ;
		)
FLUSH
RETURN .T.
ENDPROC
*
PROCEDURE ActRemoveDoublePoint
LPARAMETERS lp_cTime
IF NOT EMPTY(lp_cTime) AND EMPTY(STRTRAN(lp_cTime,":",""))
	lp_cTime = ""
ENDIF
RETURN lp_cTime
ENDPROC
*
DEFINE CLASS cAction AS cbobj OF commonclasses.prg
*
HIDDEN ocaroom
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS cAction OF procaction.prg
#ENDIF
*
WheredFromDate = {}
WheredToDate = {}
WherecUser = ""
WherecUsergroup = ""
WherecType = ""
WherelIncCompleted = .F.
ocaroom = .NULL.
*
PROCEDURE ListGet
LOCAL l_lSuccess, l_nSelect, l_cSql, l_cCur, l_cWhere

l_nSelect = SELECT()

IF NOT (openfile(,"action") AND openfile(,"picklist") AND openfile(,"user") AND openfile(,"reservat") AND openfile(,"address"))
     SELECT (l_nSelect)
     RETURN l_lSuccess
ENDIF

l_cWhere = ""
DO CASE
     CASE EMPTY(this.WheredFromDate)
     CASE EMPTY(this.WheredToDate)
          PRIVATE p_dFromDate
          p_dFromDate = this.WheredFromDate
          l_cWhere = 'at_date = __SQLPARAM__p_dFromDate'
          *l_cWhere = 'at_date = ' + SqlCnv(this.WheredFromDate,.T.)
     OTHERWISE
          PRIVATE p_dFromDate, p_dToDate
          p_dFromDate = this.WheredFromDate
          p_dToDate = this.WheredToDate
          l_cWhere = 'BETWEEN(at_date, __SQLPARAM__p_dFromDate, __SQLPARAM__p_dToDate)'
          *l_cWhere = 'BETWEEN(at_date, ' + SqlCnv(this.WheredFromDate,.T.) + ', ' + SqlCnv(this.WheredToDate,.T.) + ')'
ENDCASE
DO CASE
     CASE ALLTRIM(this.WherecUser) = "*"
     CASE NOT EMPTY(this.WherecUser)
          PRIVATE p_cUser
          p_cUser = this.WherecUser
          l_cWhere = SqlAnd(l_cWhere, 'EMPTY(at_userid) OR at_userid = __SQLPARAM__p_cUser')
          *l_cWhere = SqlAnd(l_cWhere, 'EMPTY(at_userid) OR at_userid = ' + SqlCnv(ALLTRIM(this.WherecUser),.T.))
     CASE NOT EMPTY(this.WherecUsergroup)
          PRIVATE p_cUsergroup
          p_cUsergroup = this.WherecUsergroup
          l_cWhere = SqlAnd(l_cWhere, 'us_group = __SQLPARAM__p_cUsergroup')
          *l_cWhere = SqlAnd(l_cWhere, 'us_group = ' + SqlCnv(this.WherecUsergroup,.T.))
     OTHERWISE
          l_cWhere = SqlAnd(l_cWhere, 'EMPTY(at_userid)')
ENDCASE
IF NOT EMPTY(this.WherecType)
     PRIVATE p_cType
     p_cType = this.WherecType
     l_cWhere = SqlAnd(l_cWhere, 'at_acttyp = __SQLPARAM__p_cType')
     *l_cWhere = SqlAnd(l_cWhere, 'at_acttyp = ' + SqlCnv(ALLTRIM(this.WherecType),.T.))
ENDIF
IF NOT this.WherelIncCompleted
     l_cWhere = SqlAnd(l_cWhere, 'EMPTY(at_compl)')
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT action.*, pl_lang<<g_langnum>> AS pl_lang, CAST(MLINE(at_note,1) AS C(254)) AS c_note, NOT EMPTY(at_compl) AS c_compl,
     CAST("" AS C(13)) AS c_date, 0=1 AS c_selected,
     CAST(ICASE(at_reserid > 0, ALLTRIM(rs_rmname)+" "+rs_lname, at_addrid = 0, "", ALLTRIM(ad_company)+" "+ad_lname) AS C(81)) AS c_name
     FROM action
     INNER JOIN picklist ON pl_label = 'ACTION' AND at_acttyp = pl_charcod
     LEFT JOIN "user" ON at_userid = us_id
     LEFT JOIN reservat ON at_reserid = rs_reserid
     LEFT JOIN address ON at_addrid = ad_addrid
     <<IIF(EMPTY(l_cWhere), "", "WHERE " + l_cWhere)>>
     ORDER BY at_date, at_time
ENDTEXT

l_cCur = sqlcursor(l_cSql,this.cListCur,.F.,"",.NULL.,.T.,,.T.)
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)
IF l_lSuccess
     this.cListCur = l_cCur
     REPLACE c_date WITH DTOC(at_date)+" "+LEFT(MyCDoW(at_date),2) ALL IN (this.cListCur)
     this.Export(this.cListCur)
ENDIF
SELECT (l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE ActionTypesGet
LOCAL l_nArea, l_lSuccess

l_nArea = SELECT()

IF NOT (openfile(,"param") AND openfile(,"picklist"))
     SELECT (l_nSelect)
     RETURN l_lSuccess
ENDIF

l_cCur = sqlcursor("SELECT pl_charcod, pl_lang" + g_langnum + " AS pl_lang FROM picklist WHERE pl_label = 'ACTION    ' UNION ALL SELECT '', '' FROM param ORDER BY 1")
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)

IF l_lSuccess
     this.Export(l_cCur)
     DClose(l_cCur)
ENDIF

SELECT (l_nArea)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE UsersGet
LOCAL l_nArea, l_lSuccess

l_nArea = SELECT()

IF NOT (openfile(,"param") AND openfile(,"user"))
     SELECT (l_nSelect)
     RETURN l_lSuccess
ENDIF

l_cCur = sqlcursor('SELECT us_id, UPPER(us_name) AS us_name FROM "user" WHERE NOT us_inactiv UNION ALL SELECT "", "" FROM param ORDER BY 2')
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)

IF l_lSuccess
     this.Export(l_cCur)
     DClose(l_cCur)
ENDIF

SELECT (l_nArea)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE UsergroupsGet
LOCAL l_nArea, l_lSuccess

l_nArea = SELECT()

IF NOT (openfile(,"param") AND openfile(,"group"))
     SELECT (l_nSelect)
     RETURN l_lSuccess
ENDIF

l_cCur = sqlcursor('SELECT gr_group FROM "group" UNION ALL SELECT "" FROM param ORDER BY 1')
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)

IF l_lSuccess
     this.Export(l_cCur)
     DClose(l_cCur)
ENDIF

SELECT (l_nArea)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE ActionDelete
LPARAMETERS lp_nActId

RETURN ActDelete(lp_nActId)
ENDPROC
*
PROCEDURE ActionComplete
LPARAMETERS lp_nActId

RETURN ActCompleted(lp_nActId)
ENDPROC
*
PROCEDURE ActionUpdate
LPARAMETERS lp_cJSON
LOCAL l_oJSON, l_oAction

IF NOT EMPTY(lp_cJSON)
     l_oJSON = NEWOBJECT("json","common\progs\json.prg")
     l_oAction = l_oJSON.parse(lp_cJSON)
ENDIF

IF VARTYPE(l_oAction) <> "O"
     RETURN .F.
ENDIF
l_oAction.at_date = CTOD(LEFT(l_oAction.at_date,10))
ActInsert(l_oAction, IIF(EMPTY(l_oAction.at_atid), "NEW", "EDIT"), l_oAction.c_group)

RETURN .T.
ENDPROC
*
ENDDEFINE
*