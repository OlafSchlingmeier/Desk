 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
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
PROCEDURE searchallott
LPARAMETERS lp_oAvailForm

LOCAL l_dFromDate, l_dToDate, l_nEventIntId, l_nRoomtypeId, l_cGuest, l_cCompany, l_lAllDates, l_oAvailParam
LOCAL ARRAY l_aDialogData(8,11)

IF PCOUNT()=0 && Calling brweventavail form
	IF WEXIST("brweventavail")
		WAIT WINDOW  GetLangText("COMMON","TXT_YOUHAVEOPENEDWINDOW") timeout 3
		RETURN .F.
	ENDIF
ENDIF

l_aDialogData(1,1) = "cboallot"
l_aDialogData(1,2) = GetLangText("EVENT","TXT_EVENT")
l_aDialogData(1,3) = "0"
l_aDialogData(1,4) = "@G"
l_aDialogData(1,5) = 20
l_aDialogData(1,6) = ""
l_aDialogData(1,7) = ""
l_aDialogData(1,9) = goSqlWrapper.GetSqlStatment("getevents_sql")
l_aDialogData(1,11) = CREATEOBJECT("collection")
l_aDialogData(1,11).Add(4,"ColumnCount")
l_aDialogData(1,11).Add(5,"BoundColumn")
l_aDialogData(1,11).Add(.T.,"BoundTo")
l_aDialogData(1,11).Add(.F.,"ColumnLines")
l_aDialogData(1,11).Add("100,100,70,70","ColumnWidths")
l_aDialogData(1,11).Add(3,"RowSourceType")
l_aDialogData(1,11).Add(CREATEOBJECT("oProcAllottCboHandler"),"ohandler")

l_aDialogData(2,1) = "cmbbrwsel"
l_aDialogData(2,2) = ""
l_aDialogData(2,3) = ".T."
l_aDialogData(2,4) = "@B"
l_aDialogData(2,11) = CREATEOBJECT("oCmdHandler")

l_aDialogData(3,1) = "dtxtdate"
l_aDialogData(3,2) = GetLangText("EVENT","TXT_FROM")
l_aDialogData(3,3) = "{}"
l_aDialogData(3,8) = {}

l_aDialogData(4,1) = "dtxttodate"
l_aDialogData(4,2) = ""
l_aDialogData(4,3) = "{}"
l_aDialogData(4,8) = {}

l_aDialogData(5,1) = "cbort"
l_aDialogData(5,2) = GetLangText("GETROOM","T_ROOMTYPE")
l_aDialogData(5,3) = "0"
l_aDialogData(5,4) = "@G"
l_aDialogData(5,5) = 10
l_aDialogData(5,6) = ""
l_aDialogData(5,7) = ""
l_aDialogData(5,9) = goSqlWrapper.GetSqlStatment("getroomtypes_sql")
l_aDialogData(5,11) = CREATEOBJECT("collection")
l_aDialogData(5,11).Add(2,"ColumnCount")
l_aDialogData(5,11).Add(4,"BoundColumn")
l_aDialogData(5,11).Add(.T.,"BoundTo")
l_aDialogData(5,11).Add(.F.,"ColumnLines")
l_aDialogData(5,11).Add("60,120","ColumnWidths")
l_aDialogData(5,11).Add(3,"RowSourceType")

l_aDialogData(6,1) = "txtcompany"
l_aDialogData(6,2) = GetLangText("RESERVAT","T_COMPANY")
l_aDialogData(6,3) = "[]"
l_aDialogData(6,4) = REPLICATE("!",30)
l_aDialogData(6,5) = 40

l_aDialogData(7,1) = "txtguest"
l_aDialogData(7,2) = GetLangText("RESERVAT","T_LNAME")
l_aDialogData(7,3) = "[]"
l_aDialogData(7,4) = REPLICATE("!",30)
l_aDialogData(7,5) = 40

l_aDialogData(8,1) = "chknull"
l_aDialogData(8,2) = GetLangText("ALLOTT","TXT_NULL_VALUES")
l_aDialogData(8,3) = ".T."
l_aDialogData(8,4) = "@C"
IF dialog(GetLangText("ALLOTT","TXT_ALLOT_AVAIL"), "", @l_aDialogData)
	l_nEventIntId = INT(l_aDialogData(1,8))
	l_dFromDate = l_aDialogData(3,8)
	l_dToDate = l_aDialogData(4,8)
	l_nRoomtypeId = INT(l_aDialogData(5,8))
	l_cCompany = ALLTRIM(l_aDialogData(6,8))
	l_cGuest = ALLTRIM(l_aDialogData(7,8))
	l_lAllDates = l_aDialogData(8,8)
	DO CASE
		CASE NOT EMPTY(l_nEventIntId)
			IF EMPTY(l_dFromDate)
				l_dFromDate = DLookUp("evint", "ei_eiid = " + SqlCnv(l_nEventIntId,.T.), "ei_from")
			ENDIF
			IF EMPTY(l_dToDate)
				l_dToDate = DLookUp("evint", "ei_eiid = " + SqlCnv(l_nEventIntId,.T.), "ei_to")
			ENDIF
		CASE NOT l_lAllDates AND EMPTY(l_nRoomtypeId)
			IF EMPTY(l_dFromDate)
				CALCULATE MIN(ei_from) TO l_dFromDate IN evint
			ENDIF
			IF EMPTY(l_dToDate)
				CALCULATE MAX(ei_to) TO l_dToDate IN evint
			ENDIF
		OTHERWISE
	ENDCASE
	IF NOT EMPTY(l_dFromDate) AND NOT EMPTY(l_dToDate)
		l_dToDate = MAX(l_dFromDate, l_dToDate)
	ENDIF
	l_oAvailParam = CREATEOBJECT("Collection")
	l_oAvailParam.Add(l_nEventIntId, "EventIntId")
	l_oAvailParam.Add(l_dFromDate, "FromDate")
	l_oAvailParam.Add(l_dToDate, "ToDate")
	l_oAvailParam.Add(l_nRoomtypeId, "RoomType")
	l_oAvailParam.Add(l_cCompany, "Company")
	l_oAvailParam.Add(l_cGuest, "Guest")
	l_oAvailParam.Add(l_lAllDates, "AllDates")
	DO CASE
		CASE VARTYPE(lp_oAvailForm) # "O" AND EMPTY(l_nRoomtypeId) AND EMPTY(l_nEventIntId) AND EMPTY(l_cCompany) AND EMPTY(l_cGuest)
			* Call availab form for first time
			BrwAvailab("brweventavail",.F.,.F.,.F.,l_oAvailParam)
		CASE VARTYPE(lp_oAvailForm) = "O" AND LOWER(lp_oAvailForm.Class) = "brwavail" AND EMPTY(l_nRoomtypeId) AND EMPTY(l_cCompany) AND EMPTY(l_cGuest) AND l_nEventIntId # lp_oAvailForm.oParams.Item("EventIntId")
			* Called from search dialog. Availab form exists.
			lp_oAvailForm.oParams = l_oAvailParam
			lp_oAvailForm.OnSearchEx()
		OTHERWISE
			DO AllotShowEvent IN procallott WITH l_oAvailParam, lp_oAvailForm
	ENDCASE
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE AllotShowEvent
LPARAMETERS lp_oParams, lp_oCallFrom
LOCAL l_nEiid, l_oParams, l_nRoomtypeId, l_cGuest, l_cCompany, l_dFromDate, l_dToDate, l_dToDateOld, l_lThruReser

IF EMPTY(lp_oParams.Item("EventIntId"))
	* Find possible events
	l_nRoomtypeId = lp_oParams.Item("RoomType")
	l_cCompany = lp_oParams.Item("Company")
	l_cGuest = lp_oParams.Item("Guest")
	l_dFromDate = lp_oParams.Item("FromDate")
	l_dToDate = lp_oParams.Item("ToDate")
	l_dToDateOld = l_dToDate
	IF NOT EMPTY(l_cCompany) OR NOT EMPTY(l_cGuest)
		l_lThruReser = .T.
		l_oParams = goSqlWrapper.GetParamsObj(l_dFromDate, l_dToDate, l_nRoomtypeId, l_cCompany, l_cGuest)
	ELSE
		l_oParams = goSqlWrapper.GetParamsObj(l_dFromDate, l_dToDate, l_nRoomtypeId)
	ENDIF

	l_nEiid = GetEvent(l_oParams, l_lThruReser)

	IF l_nEiid = 0
		RETURN .T.
	ELSE
		lp_oParams.Remove("EventIntId")
		lp_oParams.Add(l_nEiid, "EventIntId")
		IF EMPTY(l_dFromDate)
			l_dFromDate = DLookUp("evint", "ei_eiid = " + SqlCnv(l_nEiid,.T.), "ei_from")
			lp_oParams.Remove("FromDate")
			lp_oParams.Add(l_dFromDate, "FromDate")
		ENDIF
		IF EMPTY(l_dToDate)
			l_dToDate = DLookUp("evint", "ei_eiid = " + SqlCnv(l_nEiid,.T.), "ei_to")
		ENDIF
		l_dToDate = MAX(l_dFromDate, l_dToDate)
		IF l_dToDateOld # l_dToDate
			lp_oParams.Remove("ToDate")
			lp_oParams.Add(l_dToDate, "ToDate")
		ENDIF
	ENDIF
ENDIF

IF NOT AllottmentFound(lp_oParams)
	Alert(GetLangText("EXACT","TXT_NO_DATA_FOUND"))
	RETURN .T.
ENDIF

IF VARTYPE(lp_oCallFrom) = "O" AND LOWER(lp_oCallFrom.Name) = "frmrentavailab"
	lp_oCallFrom.oParams = lp_oParams
	lp_oCallFrom.OnRefresh()
ELSE
	* Show mask
	LOCAL ARRAY la_params(2)
	la_params(1) = lp_oCallFrom
	la_params(2) = lp_oParams
	DoForm('rentavailability','Forms\rentavailability', '', .F., @la_params)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE AllottmentFound
LPARAMETERS lp_oParams
LOCAL l_lSuccess, l_cCur

l_lSuccess = .T.
l_oParams = goSqlWrapper.GetParamsObj(lp_oParams.Item("EventIntId"), lp_oParams.Item("RoomType"), lp_oParams.Item("Company"), lp_oParams.Item("Guest"))
l_cCur = SqlCursor(,,,"getallotmentdata_sql", l_oParams)
IF NOT USED(l_cCur) OR RECCOUNT(l_cCur) = 0
	l_lSuccess = .F.
ENDIF
dclose(l_cCur)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE PrepareAvailCursor
LPARAMETERS lp_oAvailForm, lp_oParams, lp_cSource
LOCAL l_cTempCur, l_nSelect, l_oParams

l_nSelect = SELECT()

lp_oAvailForm.lNullDates = lp_oParams.Item("AllDates")

GO TOP IN availab
l_oParams = goSqlWrapper.GetParamsObj(lp_oParams.Item("FromDate"), lp_oParams.Item("ToDate"), availab.av_roomtyp, lp_oParams.Item("AllDates"))
l_cTempCur = SqlCursor(,,,"getavailcursor_sql", l_oParams)

SELECT (lp_cSource)
ZAP
APPEND FROM DBF(l_cTempCur)
dclose(l_cTempCur)
SELECT(l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE SetAllottMode
g_lShips = _screen.KT AND _screen.oGlobal.oParam2.pa_rentmod
RETURN .T.
ENDPROC
*
PROCEDURE GetEvent
LPARAMETERS lp_oParams, lp_lThruReser
LOCAL ARRAY l_aDialogData(1,11)
LOCAL l_cCurName
lp_nEventId = 0
l_cCurName = SqlCursor(,,, IIF(lp_lThruReser, "geteventsforname_sql", "geteventsforperiod_sql"), lp_oParams)

DO CASE
	CASE EMPTY(l_cCurName) OR NOT USED(l_cCurName) OR RECCOUNT(l_cCurName) = 0
		* no event found
		Alert(GetLangText("ALLOTT","TXT_NO_EVENTS_FOUND"))
	CASE RECCOUNT(l_cCurName) = 1
		* if only one event
		lp_nEventId = &l_cCurName..ei_eiid
	OTHERWISE
		* If more then one event found
		GO TOP IN &l_cCurName
		l_aDialogData(1,1) = "cboallot"
		l_aDialogData(1,2) = GetLangText("EVENT","TXT_EVENT")
		l_aDialogData(1,3) = "[" + SqlCnv(&l_cCurName..ei_eiid) + "]"
		l_aDialogData(1,4) = "@G"
		l_aDialogData(1,5) = 20
		l_aDialogData(1,6) = ""
		l_aDialogData(1,7) = ""
		l_aDialogData(1,9) = ""
		l_aDialogData(1,11) = CREATEOBJECT("Collection")

		l_aDialogData(1,11).Add(4, "ColumnCount")
		l_aDialogData(1,11).Add(5, "BoundColumn")
		l_aDialogData(1,11).Add(.T., "BoundTo")
		l_aDialogData(1,11).Add(.F., "ColumnLines")
		l_aDialogData(1,11).Add("100,100,80,80", "ColumnWidths")
		l_aDialogData(1,11).Add(6, "RowSourceType")
		l_aDialogData(1,11).Add(l_cCurName + ".EventName, EventCity, ei_from, ei_to, ei_eiid", "RowSource")

		IF Dialog(GetLangText("COMMON","TXT_CHOOSE"), "", @l_aDialogData)
			lp_nEventId = INT(VAL(l_aDialogData(1,8)))
		ENDIF
ENDCASE

DClose(l_cCurName)

RETURN lp_nEventId
ENDPROC
*
PROCEDURE ResArrivalDateAllowed

* Check if rs_arrdate is between allowed from to dates in allotment.

LPARAMETERS lp_lAllowed, lp_dAllotFrom, lp_dAllotTo, lp_nAltId, lp_dArrival, lp_cRoomTyp
LOCAL l_cCur, l_nSelect
lp_dAllotFrom = {}
lp_lAllowed = .F.

IF NOT EMPTY(lp_cRoomTyp)
     l_nRTGroup =_screen.oGlobal.oGData.dlookupb( ;
          "roomtype", ;
          "rt_roomtyp="+sqlcnv(lp_cRoomTyp,.T.), ;
          "rt_group")
     IF l_nRTGroup = 3 && Dummy
          lp_lAllowed = .T.
          RETURN lp_lAllowed
     ENDIF
ENDIF

l_nSelect = SELECT()

l_cCur = sqlcursor( ;
     "SELECT al_fromdat, al_todat, al_cutday, al_cutdate " + ;
     "FROM althead " + ;
     "WHERE al_altid = " + sqlcnv(lp_nAltId, .T.))

IF RECCOUNT()>0
     SELECT (l_cCur)
     l_dToDate = al_todat

     IF al_cutday = 0 AND NOT EMPTY(al_cutdate)
          l_dFromDate = al_cutdate
     ELSE
          l_dCompareDate = MAX(al_fromdat, sysdate())
          l_dFromDate = l_dCompareDate - al_cutday
     ENDIF

     lp_dAllotFrom = l_dFromDate
     lp_dAllotTo = l_dToDate

     IF BETWEEN(lp_dArrival, l_dFromDate, l_dToDate)
          lp_lAllowed = .T.
     ENDIF
ENDIF
dclose(l_cCur)

SELECT(l_nSelect)

RETURN lp_lAllowed
ENDPROC
*
DEFINE CLASS oCmdHandler AS Custom
jcursor = ""
Caption = "..."
PROCEDURE Click
LPARAMETERS lp_oFormRef
LOCAL l_nRet, l_nSelect, l_cSql
LOCAL ARRAY l_aDefs(4,5)

l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT ev_name AS EventName, ev_city AS EventCity, ei_from, ei_to, ei_eiid ;
		FROM evint ;
		INNER JOIN events ON ev_evid = ei_evid ;
		WHERE ei_to >= <<SqlCnv(SysDate(),.T.)>>
ENDTEXT
l_cSql = STRTRAN(l_cSql,";","")

this.jcursor = sqlcursor(l_cSql,,,,,,,.T.)

INDEX ON UPPER(EventName)+DTOS(ei_from) TAG EventName
INDEX ON UPPER(EventCity)+DTOS(ei_from) TAG EventCity
INDEX ON ei_from TAG ei_from
INDEX ON ei_to TAG ei_to
SET ORDER TO EventName
GO TOP

l_aDefs(1,1) = "EventName"
l_aDefs(1,2) = 100
l_aDefs(1,3) = GetLangText("EVENT", "TXT_EVENT")
l_aDefs(1,4) = "TXT"
l_aDefs(1,5) = "EventName"
l_aDefs(2,1) = "EventCity"
l_aDefs(2,2) = 100
l_aDefs(2,3) = GetLangText("EVENT", "TXT_CITY")
l_aDefs(2,4) = "TXT"
l_aDefs(2,5) = "EventCity"
l_aDefs(3,1) = "ei_from"
l_aDefs(3,2) = 120
l_aDefs(3,3) = GetLangText("EVENT", "TXT_FROM")
l_aDefs(3,4) = "TXT"
l_aDefs(3,5) = "ei_from"
l_aDefs(4,1) = "ei_to"
l_aDefs(4,2) = 120
l_aDefs(4,3) = GetLangText("EVENT", "TXT_TO")
l_aDefs(4,4) = "TXT"
l_aDefs(4,5) = "ei_to"

SELECT 0
DO FORM forms\brwmulsel WITH this.jcursor, l_aDefs, GetLangText("ALLOTT", "TXT_SELECT_EVENTS"), ;
		.F., .T. TO l_nRet
IF l_nRet = 1
	cjcursor = this.jcursor
	lp_oFormRef.cboallot.Value = &cjcursor..ei_eiid
	lp_oFormRef.cboallot.Refresh()
	lp_oFormRef.cboallot.LostFocus()
ENDIF
ENDPROC
*
PROCEDURE Release
dclose(this.jcursor)
RELEASE this
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS oProcAllottCboHandler AS Custom
*
PROCEDURE LostFocus
LPARAMETERS lp_oFormRef
LOCAL l_cCur
l_cCur = lp_oFormRef.cboallot.lcursor
IF EMPTY(l_cCur)
	RETURN .T.
ENDIF
IF NOT EMPTY(&l_cCur..ei_from)
	lp_oFormRef.dtxtdate.Value = &l_cCur..ei_from
	lp_oFormRef.dtxtdate.Refresh()
ENDIF
IF NOT EMPTY(&l_cCur..ei_to)
	lp_oFormRef.dtxttodate.Value = &l_cCur..ei_to
	lp_oFormRef.dtxttodate.Refresh()
ENDIF
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE
*
PROCEDURE PaValidateAllotment
LPARAMETERS tlMessages, tcResSetFilter, tcResAlias
LOCAL llRetVal, loProcAllottment AS procallott.prg

loProcAllottment = NEWOBJECT("oProcAllottment", "procallott.prg", "", tcResSetFilter, tcResAlias)
IF VARTYPE(loProcAllottment) = "O"
	loProcAllottment.lMessages = tlMessages
	llRetVal = loProcAllottment.Validate()
ENDIF

RETURN llRetVal
ENDPROC
*
PROCEDURE PaUpdateAllotment
LPARAMETERS tcResSetFilter, tcResAlias
LOCAL loProcAllottment AS procallott.prg

loProcAllottment = NEWOBJECT("oProcAllottment", "procallott.prg", "", tcResSetFilter, tcResAlias)
IF VARTYPE(loProcAllottment) = "O"
	loProcAllottment.UpdateAvAsRooms()
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PaSharersInDifferentAllottment
LPARAMETERS tcResAlias, tlSilent
LOCAL llValid, loEnvironment, lcurSharers, lnReserId, lnAltId

loEnvironment = SetEnvironment()

tcResAlias = EVL(tcResAlias, "reservat")

lnReserId = &tcResAlias..rs_reserid
lnAltId = &tcResAlias..rs_altid

lcurSharers = SYS(2015)
SELECT rs_altid FROM &tcResAlias WITH (Buffering = .T.) ;
	INNER JOIN resrooms ri2 WITH (Buffering = .T.) ON ri2.ri_reserid = rs_reserid ;
	INNER JOIN resrooms ri1 WITH (Buffering = .T.) ON ri1.ri_shareid = ri2.ri_shareid ;
	WHERE ri1.ri_reserid = lnReserId AND NOT EMPTY(ri1.ri_shareid) AND rs_altid <> lnAltId ;
	INTO CURSOR &lcurSharers
llValid = (RECCOUNT(lcurSharers) = 0)
DClose(lcurSharers)

IF NOT llValid AND NOT tlSilent
	Alert(GetLangText("RESERVAT","TXT_NOSHARE_OTHER_ALLOTT"))
ENDIF

RETURN llValid
ENDPROC
*
DEFINE CLASS oProcAllottment AS Custom
DIMENSION aResLines(1)
nCurResLine = 0
lMessages = .T.
cResAlias = ""
cResSetFilter = ""
oNewRes = .NUll.
oOldRes = .NUll.
#IF .F. && Make sure this is false, otherwise error
   *-- Define This for IntelliSense use
   LOCAL this AS oProcAllottment OF ProcAllott.prg
#ENDIF
*
PROCEDURE Init
LPARAMETERS tcResSetFilter, tcResAlias
LOCAL ARRAY laBuffer(1)

tcResAlias = EVL(tcResAlias, "reservat")

IF EMPTY(&tcResAlias..rs_altid) OR NOT SEEK(&tcResAlias..rs_altid, "althead", "tag1")
	RETURN .F.
ENDIF

this.cResAlias = tcResAlias
this.cResSetFilter = IIF(EMPTY(tcResSetFilter), "", tcResSetFilter + " AND ") + "NOT EMPTY(rs_arrdate) AND NOT INLIST(rs_status, 'NS ', 'CXL') AND rt_group <> 3"

SELECT (this.cResAlias)
SCATTER NAME this.oNewRes
SCATTER BLANK NAME this.oOldRes

STORE 0 TO laBuffer
SELECT DISTINCT rs_altid FROM reservat WHERE (&tcResSetFilter) AND NOT EMPTY(rs_altid) INTO ARRAY laBuffer
this.oOldRes.rs_altid = laBuffer(1)		&& If edited old reservation set in allotment and if there is new reservation, rs_altid have to be retrieved from other reservation in set.

SELECT rs_reserid FROM (this.cResAlias) WITH (Buffering = .T.) WHERE &tcResSetFilter INTO ARRAY this.aResLines

RETURN .T.
ENDPROC
*
PROCEDURE Validate
LOCAL loEnvironment, llValid, lcurShareIdOld, lcurShareId, ldFirstDate, lnAvailRsRoomTyp, lnAvailPaLsAllot, lnDifRsRoom, lnDifPaLsAllot, llReserChanged, lcMessage
LOCAL lnOverrule	&& lnOverrule = 0(not decided); -1(refused overruling rooms); 1(accepted overruling rooms)

loEnvironment = SetEnvironment()

llValid = .T.

this.nCurResLine = ASCAN(this.aResLines, this.oNewRes.rs_reserid)		&& Current/edited reservation line in set

IF RECNO(this.cResAlias) > 0
	this.oOldRes.rs_arrdate = OLDVAL("rs_arrdate", this.cResAlias)
	this.oOldRes.rs_rooms = OLDVAL("rs_rooms", this.cResAlias)
	this.oOldRes.rs_roomtyp = OLDVAL("rs_roomtyp", this.cResAlias)
ENDIF

IF NOT EMPTY(this.oOldRes.rs_altid) AND SEEK(this.oOldRes.rs_altid, "althead", "Tag1")
	ldFirstDate = g_Sysdate
	IF althead.al_cutday = 0 AND NOT EMPTY(althead.al_cutdate)
		IF g_Sysdate > althead.al_cutdate
			ldFirstDate = althead.al_todat
		ENDIF
	ELSE
		IF g_Sysdate > althead.al_fromdat - althead.al_cutday
			ldFirstDate = MAX(g_Sysdate + althead.al_cutday, althead.al_fromdat)
		ENDIF
	ENDIF
	IF ldFirstDate > althead.al_fromdat	&& There is blocked allotment
		DO CASE
			CASE NOT EMPTY(this.oOldRes.rs_roomtyp) AND this.oOldRes.rs_rooms <> this.oNewRes.rs_rooms AND this.oNewRes.rs_arrdate < ldFirstDate
				IF this.lMessages
					Alert(GetLangText("RESERVAT","TXT_NOCHANGE_ROOMS"))
				ENDIF
				RETURN .F.
			CASE NOT EMPTY(this.oOldRes.rs_roomtyp) AND this.oOldRes.rs_arrdate <> this.oNewRes.rs_arrdate AND this.oOldRes.rs_arrdate < ldFirstDate
				IF this.lMessages
					Alert(Str2Msg(GetLangText("RESERVAT","TXT_NOCHANGE_ARRDATE")))
				ENDIF
				RETURN .F.
			CASE this.oNewRes.rs_arrdate < ldFirstDate AND (EMPTY(this.oOldRes.rs_roomtyp) OR this.oOldRes.rs_arrdate <> this.oNewRes.rs_arrdate)
				IF this.lMessages
					Alert(Str2Msg(GetLangText("RESERVAT","TXT_MAJOR_ARRDATE"), "%s", DTOC(ldFirstDate-1)))
				ENDIF
				RETURN .F.
		ENDCASE
	ENDIF
ENDIF

* Collect in 'curRessetOld' all old reservations related to current set and get sharings from that set.
this.GetOldReserSet(@lcurShareIdOld)
* Collect in 'curResset' all new reservations related to current set and get sharings from that set.
this.GetNewReserSet(@lcurShareId)
* Add related sharers from old and new set of reservations to 'curRessetOld' and 'curResset'.
this.AddSharedReser(lcurShareIdOld)
this.AddSharedReser(lcurShareId)
this.CalculateDeltaCursor(lcurShareIdOld, lcurShareId)

lnOverrule = 0
SELECT curAltSplit
SCAN FOR c_rooms > 0
	=SEEK(curAltSplit.c_date, "curAltSplitS", "c_date")
	lnAvailRsRoomTyp = IIF(SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+c_roomtyp, "altsplit", "tag2"), altsplit.as_rooms-altsplit.as_pick, 0)
	lnAvailPaLsAllot = IIF(SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+"*", "altsplit", "tag2"), altsplit.as_rooms-altsplit.as_pick, 0) - curAltSplitS.c_roomsu
	* Released rooms by the room moving process goes to * roomtype.
	IF c_rooms > lnAvailRsRoomTyp + lnAvailPaLsAllot AND curAltSplitS.c_rooms > 0
		lnDifRsRoom = MIN(curAltSplitS.c_rooms, c_rooms - lnAvailRsRoomTyp - lnAvailPaLsAllot)
		lnAvailPaLsAllot = lnAvailPaLsAllot + lnDifRsRoom
		REPLACE c_rooms WITH curAltSplitS.c_rooms - lnDifRsRoom IN curAltSplitS
	ENDIF
	DO CASE
		CASE c_rooms <= lnAvailRsRoomTyp + lnAvailPaLsAllot
		CASE lnAvailRsRoomTyp <= 0 AND lnAvailPaLsAllot = 0
			llValid = .F.
			IF this.lMessages
				WAIT WINDOW Str2Msg(althead.al_allott+";"+GetLangText("RESERVAT","TXT_ISNOALLOTMENT")+";"+ ALLTRIM(this.oNewRes.rs_lname)+", "+DTOC(c_date),"%s")
			ENDIF
		OTHERWISE
			llValid = .F.
			llReserChanged = (this.oNewRes.rs_altid <> this.oOldRes.rs_altid) OR (c_line = this.nCurResLine)
			IF this.lMessages
				IF lnOverrule = 0 AND llReserChanged
					lcMessage = GetLangText("RESERVAT","TXT_MORE_THAN_IN_ALLOT")+" "+STR(c_line,1)+";"+GetLangText("RESERVAT","TXT_FOR")+" "+DTOC(c_date)
					IF g_lShips
						Alert(lcMessage)
						llContinue = .F.
					ELSE
						llContinue = YesNo(lcMessage + ";" + GetLangText("RESERVAT","TXT_OVERRULE_ROOMS"))
					ENDIF
					IF llContinue
						lnOverrule = 1
					ELSE
						lnOverrule = -1
						WAIT WINDOW GetLangText("RESERVAT","TXT_CHANGE_THE_RESERVATION")
					ENDIF
				ENDIF
			ELSE
				lnOverrule = -1
			ENDIF
			IF lnOverrule = 1 OR NOT llReserChanged
				llValid = .T.
			ENDIF
	ENDCASE

	IF llValid
		IF c_rooms > lnAvailRsRoomTyp + lnAvailPaLsAllot
			lnDifPaLsAllot = lnAvailPaLsAllot
		ELSE
			lnDifPaLsAllot = MAX(c_rooms - lnAvailRsRoomTyp, 0)
		ENDIF
		REPLACE c_roomsu WITH curAltSplitS.c_roomsu + lnDifPaLsAllot IN curAltSplitS
	ELSE
		IF this.lMessages
			Alert(GetLangText("RESERVAT","TXT_NOCHANGE_ROOMS"))
		ENDIF
		EXIT
	ENDIF
ENDSCAN
DClose("curResset")
DClose("curRessetOld")
DClose("curAltSplit")
DClose("curAltSplitS")

RETURN llValid
ENDPROC
*
PROCEDURE UpdateAvAsRooms
LOCAL loEnvironment, lcurShareIdOld, lcurShareId, lnAvailRsRoomTyp, lnAvailPaLsAllot, lnDifRsRoom, lnDifRsRoomTyp, lnDifPaLsAllot, loAltsplit, ldCutDate

loEnvironment = SetEnvironment()

* Collect in 'curRessetOld' all old reservations related to current set and get sharings from that set.
this.GetOldReserSet(@lcurShareIdOld)
* Collect in 'curResset' all new reservations related to current set and get sharings from that set.
this.GetNewReserSet(@lcurShareId)
* Add related sharers from old and new set of reservations to 'curRessetOld' and 'curResset'.
this.AddSharedReser(lcurShareIdOld)
this.AddSharedReser(lcurShareId)
this.CalculateDeltaCursor(lcurShareIdOld, lcurShareId)

SELECT curAltSplit
SCAN FOR c_rooms > 0
	=SEEK(curAltSplit.c_date, "curAltSplitS", "c_date")
	lnAvailRsRoomTyp = IIF(SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+c_roomtyp, "altsplit", "tag2"), altsplit.as_rooms-altsplit.as_pick, 0)
	lnAvailPaLsAllot = IIF(SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+"*", "altsplit", "tag2"), altsplit.as_rooms-altsplit.as_pick, 0)
	IF c_rooms > lnAvailRsRoomTyp + lnAvailPaLsAllot AND curAltSplitS.c_rooms > 0
		lnDifRsRoom = MIN(curAltSplitS.c_rooms, c_rooms - lnAvailRsRoomTyp - lnAvailPaLsAllot)
		lnAvailPaLsAllot = lnAvailPaLsAllot + lnDifRsRoom
		REPLACE c_rooms WITH curAltSplitS.c_rooms - lnDifRsRoom IN curAltSplitS
	ENDIF
	IF c_rooms > lnAvailRsRoomTyp + lnAvailPaLsAllot
		* There is not enough rooms but overrule.
		lnDifRsRoomTyp = c_rooms - lnAvailRsRoomTyp	&& Make enough rooms for allotment.
		lnDifPaLsAllot = lnAvailPaLsAllot	&& Use all '*' rooms.
	ELSE
		* There is enough rooms.
		lnDifRsRoomTyp = MAX(c_rooms - lnAvailRsRoomTyp, 0)
		lnDifPaLsAllot = lnDifRsRoomTyp
	ENDIF

	* Update AltSplit table on roomtype not '*'.
	DO CASE
		CASE lnDifRsRoomTyp <= 0
		CASE SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+c_roomtyp, "altsplit", "tag2")
			REPLACE as_rooms WITH altsplit.as_rooms + lnDifRsRoomTyp IN altsplit
		CASE SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+"*", "altsplit", "tag2")
			SELECT altsplit
			SCATTER NAME loAltsplit
			loAltsplit.as_pick = 0
			loAltsplit.as_orgroom = 0
			loAltsplit.as_accept = .F.
			SELECT curAltSplit
			IF c_line > 0 AND SEEK(STR(this.aResLines(c_line),12,3)+DTOS(c_date),"resrate","tag2")
				loAltsplit.as_ratecod = CHRTRAN(LEFT(resrate.rr_ratecod,10),"!*","")
			ENDIF
			loAltsplit.as_roomtyp = c_roomtyp
			loAltsplit.as_rooms = lnDifRsRoomTyp
			INSERT INTO altsplit FROM NAME loAltsplit
		OTHERWISE
	ENDCASE
	* Update AltSplit table on roomtype '*'.
	IF lnDifPaLsAllot <> 0 AND SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+"*", "altsplit", "tag2")
		REPLACE as_rooms WITH altsplit.as_rooms - lnDifPaLsAllot IN altsplit
	ENDIF

	* Update Availab table on roomtype not '*'.
	IF lnDifRsRoomTyp > 0 AND SEEK(DTOS(c_date)+c_roomtyp, "availab", "tag1")
		REPLACE av_allott WITH availab.av_allott + lnDifRsRoomTyp IN availab
	ENDIF
	* Update Availab table on roomtype '*'.
	IF lnDifPaLsAllot <> 0 AND SEEK(DTOS(c_date)+ALLTRIM(_screen.oGlobal.oParam.pa_lsallot), "availab", "tag1")
		REPLACE av_altall WITH availab.av_altall - lnDifPaLsAllot IN availab
	ENDIF
ENDSCAN
SELECT curAltSplit
SCAN FOR c_rooms < 0 AND c_roomss > 0
	* Update AltSplit table on roomtype not '*'.
	IF SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(c_date)+c_roomtyp, "altsplit", "tag2")
		REPLACE as_rooms WITH altsplit.as_rooms - curAltSplit.c_roomss IN altsplit
	ENDIF
	* Update Availab table on roomtype not '*'.
	IF SEEK(DTOS(c_date)+c_roomtyp, "availab", "tag1")
		REPLACE av_allott WITH availab.av_allott - curAltSplit.c_roomss IN availab
	ENDIF
ENDSCAN
DELETE FOR as_altid = this.oNewRes.rs_altid AND as_rooms <= 0 IN altsplit
SELECT curAltSplitS
SCAN FOR c_rooms > 0 
	IF SEEK(PADR(this.oNewRes.rs_altid,8)+DTOS(curAltSplitS.c_date)+"*", "altsplit", "tag2")
		REPLACE as_rooms WITH altsplit.as_rooms + curAltSplitS.c_rooms IN altsplit
	ELSE
		ldCutDate = IIF(EMPTY(althead.al_cutday) AND NOT EMPTY(althead.al_cutdate), althead.al_cutdate, c_date - althead.al_cutday)
		INSERT INTO altsplit (as_altid, as_cutdate, as_date, as_rooms, as_roomtyp) ;
			VALUES (this.oNewRes.rs_altid, ldCutDate, curAltSplitS.c_date, curAltSplitS.c_rooms, "*")
	ENDIF
	IF SEEK(DTOS(curAltSplitS.c_date)+ALLTRIM(_screen.oGlobal.oParam.pa_lsallot), "availab", "tag1")
		REPLACE av_altall WITH availab.av_altall + curAltSplitS.c_rooms IN availab
	ENDIF
ENDSCAN
DClose("curAltSplit")
DClose("curAltSplitS")

RETURN .T.
ENDPROC
*
PROCEDURE GetOldReserSet
* Collect in 'curRessetOld' all old reservations related to current set and get sharings from that set.
LPARAMETERS tcurShareId
LOCAL lnArea, lcResSetFilter

lnArea = SELECT()

lcResSetFilter = this.cResSetFilter

tcurShareId = SYS(2015)

SELECT resrooms.*, reservat.* FROM resrooms ;
	INNER JOIN reservat ON rs_reserid = ri_reserid ;
	INNER JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
	WHERE this.oNewRes.rs_altid = this.oOldRes.rs_altid AND (&lcResSetFilter) ;
	INTO CURSOR curRessetOld READWRITE
INDEX ON rs_reserid TAG rs_reserid
SET ORDER TO
SELECT DISTINCT sharing.* FROM curRessetOld ;
	INNER JOIN sharing ON sd_shareid = ri_shareid ;
	WHERE NOT EMPTY(ri_shareid) ;
	INTO CURSOR &tcurShareId

SELECT (lnArea)

RETURN .T.
ENDPROC
*
PROCEDURE GetNewReserSet
* Collect in 'curResset' all new reservations related to current set and get sharings from that set.
LPARAMETERS tcurShareId
LOCAL lnArea, lcResAlias, lcResSetFilter

lnArea = SELECT()

lcResAlias = this.cResAlias
lcResSetFilter = this.cResSetFilter

tcurShareId = SYS(2015)

SELECT resrooms.*, &lcResAlias..*, ASCAN(this.aResLines,rs_reserid) AS c_line FROM resrooms WITH (Buffering = .T.) ;
	INNER JOIN &lcResAlias WITH (Buffering = .T.) ON rs_reserid = ri_reserid ;
	INNER JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
	WHERE &lcResSetFilter ;
	INTO CURSOR curResset READWRITE
INDEX ON rs_reserid TAG rs_reserid
SET ORDER TO
SELECT DISTINCT sharing.* FROM curResset ;
	INNER JOIN sharing WITH (Buffering = .T.) ON sd_shareid = ri_shareid ;
	WHERE NOT EMPTY(ri_shareid) ;
	INTO CURSOR &tcurShareId

SELECT (lnArea)

RETURN .T.
ENDPROC
*
PROCEDURE AddSharedReser
* Add related sharers from old and new set of reservations to 'curRessetOld' and 'curResset'.
LPARAMETERS tcurShareId
LOCAL lnArea, lcResAlias, lcurSharers

lnArea = SELECT()

lcResAlias = this.cResAlias
lcurSharers = SYS(2015)

* Add related new sharers from set of reservations to 'curRessetOld' and 'curResset'.
SELECT &tcurShareId
SCAN
	SELECT DISTINCT ri_reserid FROM resrooms WITH (Buffering = .T.) ;
		WHERE ri_shareid = &tcurShareId..sd_shareid ;
		INTO CURSOR &lcurSharers
	SCAN
		IF NOT SEEK(&lcurSharers..ri_reserid, "curResset", "rs_reserid")
			INSERT INTO curResset ;
				SELECT resrooms.*, &lcResAlias..*, 0 FROM resrooms WITH (Buffering = .T.) ;
					INNER JOIN &lcResAlias WITH (Buffering = .T.) ON rs_reserid = ri_reserid ;
					INNER JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
					WHERE ri_reserid = &lcurSharers..ri_reserid AND rt_group <> 3
		ENDIF
		IF NOT SEEK(&lcurSharers..ri_reserid, "curRessetOld", "rs_reserid")
			INSERT INTO curRessetOld ;
				SELECT resrooms.*, reservat.* FROM resrooms ;
					INNER JOIN reservat ON rs_reserid = ri_reserid ;
					INNER JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
					WHERE ri_reserid = &lcurSharers..ri_reserid AND rt_group <> 3
		ENDIF
	ENDSCAN
	SELECT &tcurShareId
ENDSCAN
* Add related old sharers from set of reservations to 'curRessetOld' and 'curResset'.
SCAN
	SELECT DISTINCT ri_reserid FROM resrooms ;
		WHERE ri_shareid = &tcurShareId..sd_shareid ;
		INTO CURSOR &lcurSharers
	SCAN FOR NOT SEEK(ri_reserid, "curRessetOld", "rs_reserid")
		IF NOT SEEK(&lcurSharers..ri_reserid, "curResset", "rs_reserid")
			INSERT INTO curResset ;
				SELECT resrooms.*, &lcResAlias..*, 0 FROM resrooms WITH (Buffering = .T.) ;
					INNER JOIN &lcResAlias WITH (Buffering = .T.) ON rs_reserid = ri_reserid ;
					INNER JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
					WHERE ri_reserid = &lcurSharers..ri_reserid AND rt_group <> 3
		ENDIF
		IF NOT SEEK(&lcurSharers..ri_reserid, "curRessetOld", "rs_reserid")
			INSERT INTO curRessetOld ;
				SELECT resrooms.*, reservat.* FROM resrooms ;
					INNER JOIN reservat ON rs_reserid = ri_reserid ;
					INNER JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
					WHERE ri_reserid = &lcurSharers..ri_reserid AND rt_group <> 3
		ENDIF
	ENDSCAN
	SELECT &tcurShareId
ENDSCAN
DClose(lcurSharers)

SELECT (lnArea)

RETURN .T.
ENDPROC
*
PROCEDURE CalculateDeltaCursor
LPARAMETERS tcurShareIdOld, tcurShareId

this.CreateEmptyDeltaCursor()
this.AddNewReserSetToDeltaCursor(tcurShareId)
this.RemoveOldReserSetFromDeltaCursor(tcurShareIdOld)
DClose(tcurShareId)
DClose(tcurShareIdOld)

* Use released rooms first from other reservations.
REPLACE c_roomss WITH c_roomss - c_rooms, c_rooms WITH 0 FOR c_roomss >= c_rooms AND c_rooms > 0 IN curAltSplit
REPLACE c_rooms WITH c_rooms - c_roomss, c_roomss WITH 0 FOR c_rooms > c_roomss AND c_roomss > 0 IN curAltSplit

* All other released rooms collect as * rooms which could be used for other room types.
SELECT c_date, SUM(c_roomss) AS c_rooms, 0000 AS c_roomsu FROM curAltSplit GROUP BY c_date INTO CURSOR curAltSplitS READWRITE
INDEX on c_date TAG c_date
SET ORDER TO

RETURN .T.
ENDPROC
*
PROCEDURE CreateEmptyDeltaCursor
LOCAL lcurDates
LOCAL ARRAY laMinMax(1)

* Make period cursor day by day.
STORE {} TO laMinMax
SELECT MIN(ri_date) AS c_fromdate, MAX(ri_todate) AS c_todate FROM ( ;
	SELECT ri_date, ri_todate FROM curRessetOld WHERE this.oNewRes.rs_altid <> this.oOldRes.rs_altid OR ri_reserid = this.oNewRes.rs_reserid ;
	UNION ;
	SELECT ri_date, ri_todate FROM curResset WHERE this.oNewRes.rs_altid <> this.oOldRes.rs_altid OR ri_reserid = this.oNewRes.rs_reserid) c ;
	INTO ARRAY laMinMax
lcurDates = MakeDatesCursor(laMinMax(1), laMinMax(2))	&&c_date

* Get all roomtypes from all collected reservations.
SELECT ri_roomtyp AS c_roomtyp FROM curRessetOld ;
UNION SELECT ri_roomtyp FROM curResset ;
	INTO CURSOR curAltSplit

* Create empty Delta (difference between new and old state of allotment occupancy) cursor.
SELECT c_date, c_roomtyp, 0000 AS c_rooms, 0000 AS c_roomss, 00 AS c_line FROM &lcurDates, curAltSplit INTO CURSOR curAltSplit READWRITE
DClose(lcurDates)
ENDPROC
*
PROCEDURE AddNewReserSetToDeltaCursor
LPARAMETERS tcurShareId

* Add not shared rooms for new reservation set to Delta cursor.
SELECT curResset
SCAN FOR EMPTY(ri_shareid)
	REPLACE c_rooms WITH c_rooms + curResset.rs_rooms, c_line WITH IIF(c_line = 0 OR this.nCurResLine > 0 AND curResset.c_line = this.nCurResLine, curResset.c_line, c_line) ;
		FOR c_roomtyp = curResset.ri_roomtyp AND BETWEEN(c_date, curResset.ri_date, curResset.ri_todate) IN curAltSplit
ENDSCAN
* Also add shared rooms for new reservation set to Delta cursor.
SELECT &tcurShareId
SCAN
	REPLACE c_rooms WITH c_rooms + 1 ;
		FOR c_roomtyp = &tcurShareId..sd_roomtyp AND BETWEEN(c_date, &tcurShareId..sd_lowdat, &tcurShareId..sd_highdat) IN curAltSplit
ENDSCAN
ENDPROC
*
PROCEDURE RemoveOldReserSetFromDeltaCursor
LPARAMETERS tcurShareIdOld
LOCAL ldDate, loResrooms, lcRoomtype

* Remove not shared rooms for old reservation set from Delta cursor.
SELECT curRessetOld
SCAN FOR EMPTY(ri_shareid)
	REPLACE c_rooms WITH c_rooms - curRessetOld.rs_rooms ;
		FOR c_roomtyp = curRessetOld.ri_roomtyp AND BETWEEN(c_date, curRessetOld.ri_date, curRessetOld.ri_todate) IN curAltSplit
	IF SEEK(curRessetOld.ri_reserid, "curResset", "rs_reserid")
		* If changed room type on reservation than add this rooms to * room type pool for further use in this set.
		ldDate = curRessetOld.ri_date
		DO WHILE ldDate <= curRessetOld.ri_todate
			RiGetRoom(curRessetOld.ri_reserid, ldDate, @loResrooms)
			lcRoomtype = IIF(ISNULL(loResrooms), "", loResrooms.ri_roomtyp)
			REPLACE c_roomss WITH c_roomss + IIF(lcRoomtype <> curRessetOld.ri_roomtyp, curRessetOld.rs_rooms, 0) ;
				FOR c_roomtyp = curRessetOld.ri_roomtyp AND c_date = ldDate IN curAltSplit
			ldDate = ldDate + 1
		ENDDO
	ENDIF
ENDSCAN
* Also remove shared rooms for old reservation set from Delta cursor.
SELECT &tcurShareIdOld
SCAN
	REPLACE c_rooms WITH c_rooms - 1 ;
		FOR c_roomtyp = &tcurShareIdOld..sd_roomtyp AND BETWEEN(c_date, &tcurShareIdOld..sd_lowdat, &tcurShareIdOld..sd_highdat) IN curAltSplit
ENDSCAN
ENDPROC
*
ENDDEFINE
*