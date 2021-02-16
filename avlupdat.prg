LPARAMETERS nrOw, daRrdate, ddEpdate, nrOoms, csTatus, nAltId, nrEserid, cStartLoc, cFinishLoc
Private npArameters
LOCAL l_lCloseResrooms, l_lCloseResroomsOld, l_lOrderResrooms, l_lOrderResroomsOld, l_lRoomnumPeri, l_lRoomnumOldPeri
LOCAL i, l_dArrdate, l_dDepdate, l_cRoomtyp, l_cRoomnum, l_nShareid, l_nSelect, l_lResroomschanged
PRIVATE p_nReserid
p_nReserid = nrEserid
External Array a_Data
l_nSelect = SELECT()
npArameters = PCOUNT()
If (npArameters==0)
	nrOw = 1
Endif
If (npArameters<9)
	daRrdate = reServat.rs_arrdate
	ddEpdate = reServat.rs_depdate
	nrOoms = reServat.rs_rooms
	nAltId = reServat.rs_altid
	nrEserid = reServat.rs_reserid
	cStartLoc = reServat.rs_lstart
	cFinishLoc = reServat.rs_lfinish
ENDIF
IF NOT USED("resrooms")
	openfiledirect(.F., "resrooms")
	l_lCloseResrooms = .T.
ENDIF
SELECT resrooms
l_lOrderResrooms = ORDER()
SET ORDER TO
IF NOT USED("ResroomsOld")
	openfiledirect(.F., "resrooms","ResroomsOld")
	l_lCloseResroomsOld = .T.
ENDIF
SELECT ResroomsOld
l_lOrderResroomsOld = ORDER()
SET ORDER TO
DO RiChanged IN ProcResrooms WITH l_lResroomschanged, "ri_reserid = p_nReserid"
PlanSet(nrEserid)
IF g_Data(nrOw,1) <> daRrdate OR g_Data(nrOw,2) <> ddEpdate OR g_Data(nrOw,3) <> nrOoms OR g_Data(nrOw,6) <> csTatus OR g_Data(nrOw,7) <> nAltId OR ;
		g_Data(nrOw,8) <> nrEserid OR g_Data(nrOw,9) <> cStartLoc OR g_Data(nrOw,10) <> cFinishLoc OR l_lResroomschanged
	IF NOT INLIST(g_Data(nrOw,6), "CXL", "NS")
		AvlReset(nrOw)
		SELECT ResroomsOld
		SCAN FOR (ri_reserid = g_Data(nrOw,8)) AND NOT EMPTY(ri_shareid) AND TransactionIsOK()
			IF SEEK(ResroomsOld.ri_shareid, "sharing", "tag1")
				ShareReset(ResroomsOld.ri_shareid, g_Data(nrOw,7))
				IF NOT INLIST(sharing.sd_status, "CXL", "NS")
					ShareSet(ResroomsOld.ri_shareid, g_Data(nrOw,7), .T.)
				ENDIF
				IF sharing.sd_nomembr = 0
					DELETE IN sharing
				ENDIF
				DoTableUpdate(.F., .T., "sharing")
				DbTableUpdate("resrmshr","sr_shareid = sharing.sd_shareid")
			ENDIF
		ENDSCAN
	ENDIF
	IF NOT INLIST(csTatus, "CXL", "NS")
		AvlSet(daRrdate, ddEpdate, nrOoms, csTatus, nAltId, nrEserid, , cStartLoc, cFinishLoc)
		SELECT resrooms
		SCAN FOR (ri_reserid = nrEserid) AND NOT EMPTY(ri_shareid) AND TransactionIsOK()
			IF SEEK(resrooms.ri_shareid, "sharing", "tag1")
				IF NOT ISNULL(CURVAL("sd_status","sharing")) AND NOT INLIST(CURVAL("sd_status","sharing"), "CXL", "NS")
					ShareReset(resrooms.ri_shareid, nAltId)
				ENDIF
				ShareSet(resrooms.ri_shareid, nAltId)
				DoTableUpdate(.F., .T., "sharing")
				DbTableUpdate("resrmshr","sr_shareid = sharing.sd_shareid")
			ENDIF
		ENDSCAN
	ENDIF
Endif
SET ORDER TO l_lOrderResroomsOld IN ResroomsOld
SET ORDER TO l_lOrderResrooms IN resrooms
IF l_lCloseResrooms
	USE IN resrooms
ENDIF
IF l_lCloseResroomsOld
	USE IN ResroomsOld 
ENDIF
Flush
IF USED("curChangeRes")
	LOCAL l_nRecno
	l_nRecno = RECNO("curChangeRes")
	DELETE FOR cr_reserid = nReserid IN curChangeRes
	GO l_nRecno IN curChangeRes
ENDIF
SELECT (l_nSelect)
Return .T.
Endfunc
*
Function avLreset
Parameter nrOw
Private daRrdate
Private ddEpdate
Private nrOoms
Private csTatus
Private nAltId
Private nsElect
Private ddAte
LOCAL l_nReserid, l_nShareid, l_cRoomnum, l_cRoomtype, l_oResrooms, l_cStartLoc, l_cFinishLoc, l_cRtStart, l_cRtFinish
Private arOomtypes, i, ngRoup
DIMENSION arOomtypes[1, 5]
daRrdate = g_Data(nrOw,1)
ddEpdate = g_Data(nrOw,2)
nrOoms = g_Data(nrOw,3)
l_cRoomnum = ""
l_cRoomtype = ""
csTatus = stAtus2field(g_Data(nrOw,6))
nAltId = g_Data(nrOw,7)
l_nReserid = g_Data(nrOw,8)
l_cStartLoc = g_Data(nrOw,9)
l_cFinishLoc = g_Data(nrOw,10)
nsElect = Select()
SELECT avAilab
IF NOT EMPTY(daRrdate) AND NOT EMPTY(ddEpdate) AND (l_nReserid >= 1)
	STORE "    " TO l_cRtStart, l_cRtFinish
	ddAte = daRrdate
	DO WHILE ddAte < ddEpdate
		IF ddAte = daRrdate OR ISNULL(l_oResrooms) OR NOT BETWEEN(ddAte, l_oResrooms.ri_date, l_oResrooms.ri_todate)
			RiGetRoom(l_nReserid, ddAte, @l_oResrooms, "ResroomsOld")
			l_cRoomnum = IIF(ISNULL(l_oResrooms), "", l_oResrooms.ri_roomnum)
			l_cRoomtype = IIF(ISNULL(l_oResrooms), "", l_oResrooms.ri_roomtyp)
			l_nShareid = IIF(ISNULL(l_oResrooms), 0, l_oResrooms.ri_shareid)
			IF _screen.oGlobal.lVehicleRentModeOffsetInAvailab AND NOT EMPTY(l_cStartLoc)
				l_cRtStart = Get_rt_roomtyp(PADL(Get_rt_roomtyp(l_cRoomtype,"rt_rdid"),10)+l_cStartLoc, "PADL(rt_rdid,10)+rt_buildng", .T.)
				l_cRtFinish = Get_rt_roomtyp(PADL(Get_rt_roomtyp(l_cRoomtype,"rt_rdid"),10)+l_cFinishLoc, "PADL(rt_rdid,10)+rt_buildng", .T.)
			ENDIF
			IF _screen.oGlobal.lVehicleRentModeOffsetInAvailab AND NOT EMPTY(l_cRtStart) AND l_cRtStart <> l_cRoomtype
				LinkRoomtype("",l_cRtStart,@arOomtypes)
			ELSE
				LinkRoomtype(l_cRoomnum,l_cRoomtype,@arOomtypes)
			ENDIF
		ENDIF
		IF EMPTY(l_nShareid)
			FOR i = 1 TO ALEN(arOomtypes, 1)
				IF SEEK(DTOS(ddAte)+arOomtypes(i,1),"availab","tag1")
					REPLACE (csTatus) WITH EVALUATE(csTatus) - nrOoms*arOomtypes(i,2) IN availab
					IF NOT EMPTY(nAltId) AND i = 1
						REPLACE av_pick WITH availab.av_pick-nrOoms IN availab
						AllotReset(nAltId, arOomtypes(i,1), nrOoms, ddAte)
					ENDIF
				ENDIF
			ENDFOR
		ENDIF
		ddAte = ddAte+1
	Enddo
	IF _screen.oGlobal.lVehicleRentModeOffsetInAvailab AND NOT EMPTY(l_cRtStart) AND NOT EMPTY(l_cRtFinish) AND l_cRtStart <> l_cRtFinish
		REPLACE av_avail WITH av_avail+nrOoms FOR av_date >= ddEpdate AND av_roomtyp = l_cRtStart
		REPLACE av_avail WITH av_avail-nrOoms FOR av_date >= ddEpdate AND av_roomtyp = l_cRtFinish
	ENDIF
Endif
Select (nsElect)
Flush
Return .T.
Endfunc
*
Function avLset
Parameter daRrdate, ddEpdate, nrOoms, csTatus, nAltId, p_nReserid, cRateCod, cStartLoc, cFinishLoc, lAvlrebuild
Private csTatusfield
Private nsElect
Private ddAte
Private arOomtypes, i
DIMENSION arOomtypes[1, 5]
LOCAL l_oResrooms, l_nShareid, l_cRoomnum, l_cRoomtype, l_cRtStart, l_cRtFinish
IF EMPTY(cRateCod)
	IF TYPE("a_Data[nrow, 11]") == "C"
		cRateCod = a_Data[nrow, 11]
	ELSE
		cRateCod = reservat.rs_ratecod
	ENDIF
ENDIF
csTatusfield = stAtus2field(csTatus)
nsElect = Select()
Select avAilab
IF NOT EMPTY(daRrdate) AND NOT EMPTY(ddEpdate) AND (p_nReserid >= 1)
	STORE "    " TO l_cRtStart, l_cRtFinish
	ddAte = daRrdate
	DO WHILE ddAte < ddEpdate
		IF ddAte = daRrdate OR ISNULL(l_oResrooms) OR NOT BETWEEN(ddAte, l_oResrooms.ri_date, l_oResrooms.ri_todate)
			RiGetRoom(p_nReserid, ddAte, @l_oResrooms)
			l_cRoomnum = IIF(ISNULL(l_oResrooms), "", l_oResrooms.ri_roomnum)
			l_cRoomtype = IIF(ISNULL(l_oResrooms), "", l_oResrooms.ri_roomtyp)
			l_nShareid = IIF(ISNULL(l_oResrooms), 0, l_oResrooms.ri_shareid)
			IF _screen.oGlobal.lVehicleRentModeOffsetInAvailab AND NOT EMPTY(cStartLoc)
				l_cRtStart = Get_rt_roomtyp(PADL(Get_rt_roomtyp(l_cRoomtype,"rt_rdid"),10)+cStartLoc, "PADL(rt_rdid,10)+rt_buildng", .T.)
				l_cRtFinish = Get_rt_roomtyp(PADL(Get_rt_roomtyp(l_cRoomtype,"rt_rdid"),10)+cFinishLoc, "PADL(rt_rdid,10)+rt_buildng", .T.)
			ENDIF
			IF _screen.oGlobal.lVehicleRentModeOffsetInAvailab AND NOT EMPTY(l_cRtStart) AND l_cRtStart <> l_cRoomtype
				LinkRoomtype("",l_cRtStart,@arOomtypes)
			ELSE
				LinkRoomtype(l_cRoomnum,l_cRoomtype,@arOomtypes)
			ENDIF
		ENDIF
		IF EMPTY(l_nShareid)
			FOR i = 1 TO ALEN(arOomtypes, 1)
				IF SEEK(DTOS(ddAte)+arOomtypes(i,1),"availab","tag1")
					REPLACE (csTatusfield) WITH EVALUATE(csTatusfield) + nrOoms*arOomtypes(i,2) IN availab
					IF NOT EMPTY(nAltId) AND i = 1
						REPLACE av_pick WITH availab.av_pick+nrOoms IN availab
						AllotSet(nAltId, arOomtypes(i,1), nrOoms, ddAte, cRateCod, .T.)
					ENDIF
				ENDIF
			ENDFOR
		ENDIF
		ddAte = ddAte+1
	ENDDO
	IF _screen.oGlobal.lVehicleRentModeOffsetInAvailab AND NOT EMPTY(l_cRtStart) AND NOT EMPTY(l_cRtFinish) AND l_cRtStart <> l_cRtFinish
		REPLACE av_avail WITH av_avail-nrOoms FOR av_date >= ddEpdate AND av_roomtyp = l_cRtStart IN availab
		REPLACE av_avail WITH av_avail+nrOoms FOR av_date >= ddEpdate AND av_roomtyp = l_cRtFinish IN availab
	ENDIF
ENDIF
SELECT (nsElect)
FLUSH
RETURN .T.
ENDFUNC
*
PROCEDURE PlanSet
LPARAMETERS lp_nReserid, lp_cResAlias, lp_cRoomplan
LOCAL i, l_cRpOrder, l_nSelect, l_nRecno, l_dDate, l_oRoomplan, l_nRoomStatus, l_oResrooms
LOCAL ARRAY l_aRoomtypes(1,5)

IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF
IF EMPTY(lp_cRoomplan)
	lp_cRoomplan = "roomplan"
ENDIF
IF EMPTY(lp_nReserid)
	lp_nReserid = &lp_cResAlias..rs_reserid
ENDIF

l_nSelect = SELECT()
l_cRpOrder = ORDER(lp_cRoomplan)
SET ORDER TO "" IN &lp_cRoomplan
l_nRecno = RECNO(lp_cResAlias)

IF SEEK(lp_nReserid, lp_cResAlias, "tag1") AND NOT INLIST(&lp_cResAlias..rs_status, "CXL", "NS") AND ;
		(&lp_cResAlias..rs_rooms = 1) AND (&lp_cResAlias..rs_reserid >= 1) AND NOT EMPTY(&lp_cResAlias..rs_arrdate)
	IF (CURSORGETPROP("Buffering",lp_cResAlias) <> 1) AND NOT ISNULL(CURVAL("rs_reserid",lp_cResAlias)) AND ;
			(lp_nReserid <> CURVAL("rs_reserid",lp_cResAlias))
		REPLACE rp_reserid WITH lp_nReserid FOR rp_reserid = CURVAL("rs_reserid",lp_cResAlias) IN &lp_cRoomplan
	ENDIF
	l_nRoomStatus = StAtus2Num(&lp_cResAlias..rs_status)
	SELECT &lp_cRoomplan
	SET ORDER TO tag2
	IF NOT SEEK(lp_nReserid)
		LOCATE
	ENDIF
	SCATTER NAME l_oRoomplan BLANK
	l_oRoomplan.rp_reserid = lp_nReserid
	l_dDate = &lp_cResAlias..rs_arrdate
	DO WHILE l_dDate <= &lp_cResAlias..rs_depdate+1
		IF l_dDate > &lp_cResAlias..rs_arrdate AND l_dDate > &lp_cResAlias..rs_depdate-IIF(l_aRoomtypes[1,3]=2,0,1)
			IF rp_reserid = lp_nReserid
				SELECT &lp_cRoomplan
				SCAN REST WHILE rp_reserid = lp_nReserid
					DELETE
				ENDSCAN
*				DELETE REST WHILE rp_reserid = lp_nReserid IN &lp_cRoomplan		&& After this command within transaction, couldn't be updated any record any more before ROLLBACK.
			ENDIF
			EXIT
		ENDIF
		IF l_dDate = &lp_cResAlias..rs_arrdate OR l_dDate > l_oResrooms.ri_todate
			RiGetRoom(lp_nReserid, l_dDate, @l_oResrooms)
			l_oRoomplan.rp_shareid = l_oResrooms.ri_shareid
			l_oRoomplan.rp_rroomid = l_oResrooms.ri_rroomid
			LinkRoomtype(l_oResrooms.ri_roomnum, l_oResrooms.ri_roomtyp, @l_aRoomtypes)
		ENDIF
		IF NOT EMPTY(l_oResrooms.ri_roomnum)
			l_oRoomplan.rp_date = l_dDate
			l_oRoomplan.rp_exinfo = ICASE(l_dDate = &lp_cResAlias..rs_arrdate, "<", l_dDate = &lp_cResAlias..rs_depdate-IIF(l_aRoomtypes[1,3]=2,0,1), ">", "")
			l_oRoomplan.rp_nights = &lp_cResAlias..rs_depdate - l_dDate
			FOR i = 1 TO ALEN(l_aRoomtypes,1)
				IF NOT EMPTY(l_aRoomtypes[i,4])
					l_oRoomplan.rp_roomnum = l_aRoomtypes[i,4]
					l_oRoomplan.rp_status = IIF((i = 1) OR (l_aRoomtypes[i,3] = 4), l_nRoomStatus, 99)
					l_oRoomplan.rp_link = l_aRoomtypes[i,5]
					IF rp_reserid = lp_nReserid
						UpdateRecord(lp_cRoomplan, l_oRoomplan)
					ELSE
						INSERT INTO &lp_cRoomplan FROM NAME l_oRoomplan
					ENDIF
					SKIP
				ENDIF
			NEXT
		ENDIF
		l_dDate = l_dDate + 1
	ENDDO
ELSE
	*DELETE FOR rp_reserid = lp_nReserid IN &lp_cRoomplan	&& After this command within transaction, couldn't be updated any record any more before ROLLBACK.
	SELECT &lp_cRoomplan
	SCAN FOR rp_reserid = lp_nReserid
		DELETE
	ENDSCAN
ENDIF

GO l_nRecno IN &lp_cResAlias
SET ORDER TO l_cRpOrder IN &lp_cRoomplan

SELECT (l_nSelect)
ENDPROC
*
FUNCTION AllotReset
LPARAMETERS lp_nAltId, lp_cRoomType, lp_nRooms, lp_dDate
LOCAL l_lRet
IF SEEK(lp_nAltId, 'althead', 'tag1')
	IF SEEK(PADR(althead.al_altid,8)+DTOS(lp_dDate)+lp_cRoomType, 'altsplit','tag2')
		REPLACE as_pick WITH altsplit.as_pick-lp_nRooms IN altsplit
		l_lRet = .T.
	ENDIF
ENDIF
RETURN l_lRet
ENDFUNC
*
FUNCTION AllotmentIsExpired
LPARAMETERS lp_lExpired
lp_lExpired = (altsplit.as_cutdate < SysDate() + IIF(g_auditactive, 1, 0))
RETURN lp_lExpired
ENDFUNC
*
FUNCTION AdjustAllotmentRooms
LPARAMETERS lp_lReset
IF altsplit.as_rooms <> altsplit.as_pick
	IF lp_lReset
		REPLACE as_orgroom WITH altsplit.as_rooms IN altsplit
	ENDIF
	REPLACE as_rooms WITH altsplit.as_pick IN altsplit
ENDIF
RETURN .T.
ENDFUNC
*
FUNCTION AllotSet
LPARAMETERS lp_nAltId, lp_cRoomType, lp_nRooms, lp_dDate, lp_cRateCod, lp_lAdjustAllotment
LOCAL l_lRet
IF SEEK(lp_nAltId, 'althead', 'tag1')
	IF SEEK(PADR(althead.al_altid,8)+DTOS(lp_dDate), 'altsplit', 'tag2')
		IF SEEK(PADR(althead.al_altid,8)+DTOS(lp_dDate)+lp_cRoomType, 'altsplit', 'tag2')
			REPLACE as_pick WITH altsplit.as_pick+lp_nRooms IN altsplit
		ELSE
			LOCAL l_nRate1, l_nRate2, l_nRate3, l_nRate4, l_nRate5, l_dCutdate
			RateCodeGetRates(lp_dDate, lp_cRateCod, lp_cRoomType, @l_nRate1, @l_nRate2, @l_nRate3, @l_nRate4, @l_nRate5)
			l_dCutdate = IIF(EMPTY(althead.al_cutday) AND NOT EMPTY(althead.al_cutdate), althead.al_cutdate, lp_dDate - althead.al_cutday)
			INSERT INTO altsplit (as_altid, as_cutdate, as_date, as_pick, as_ratecod, as_rooms, as_roomtyp, as_rate1, as_rate2, as_rate3, as_rate4, as_rate5) ;
				VALUES (althead.al_altid, l_dCutdate, lp_dDate, lp_nRooms, ratecode.rc_ratecod, lp_nRooms, lp_cRoomType, l_nRate1, l_nRate2, l_nRate3, l_nRate4, l_nRate5)
		ENDIF
		IF lp_lAdjustAllotment AND AllotmentIsExpired()
			AdjustAllotmentRooms()
		ENDIF
		l_lRet = .T.
	ENDIF
ENDIF
RETURN l_lRet
ENDFUNC
*
FUNCTION ShareReset
LPARAMETERS lp_nShareid, lp_nAltId
LOCAL l_dLowdate, l_dHighdate, l_cRoomtype, l_cStatus
LOCAL l_nSelect, l_dDate
l_nSelect = SELECT()
IF SEEK(lp_nShareid, "sharing", "tag1") AND (RECNO("sharing") > 0) AND NOT EMPTY(CURVAL("sd_lowdat","sharing"))
	l_dLowdate = CURVAL("sd_lowdat","sharing")
	l_dHighdate = CURVAL("sd_highdat","sharing")
	l_cRoomtype = CURVAL("sd_roomtyp","sharing")
	l_cStatus = stAtus2field(CURVAL("sd_status","sharing"))
	SELECT availab
	l_dDate = l_dLowdate
	DO WHILE l_dDate <= l_dHighdate
		IF SEEK(DTOS(l_dDate) + l_cRoomtype)
			REPLACE (l_cStatus) WITH EVALUATE(l_cStatus) - 1
			IF NOT EMPTY(lp_nAltId)
				REPLACE av_pick WITH av_pick - 1
				AllotReset(lp_nAltId, l_cRoomtype, 1, l_dDate)
			ENDIF
		ENDIF
		l_dDate = l_dDate + 1
	ENDDO
ENDIF
SELECT (l_nSelect)
RETURN .T.
ENDFUNC
*
FUNCTION ShareSet
LPARAMETERS lp_nShareid, lp_nAltId, lp_lOldRes
LOCAL l_dLowdate, l_dHighdate, l_cRoomtype, l_cStatus
LOCAL l_nSelect, l_dDate, l_cBuff
LOCAL ARRAY l_aRatecodes(1)
l_nSelect = SELECT()
IF SEEK(lp_nShareid, "sharing", "tag1") AND NOT EMPTY(sharing.sd_lowdat)
	l_cBuff = IIF(lp_lOldRes, "", "WITH (Buffering = .T.)")
	l_dLowdate = sharing.sd_lowdat
	l_dHighdate = sharing.sd_highdat
	l_cRoomtype = sharing.sd_roomtyp
	l_cStatus = stAtus2field(sharing.sd_status)
	SELECT availab
	l_dDate = l_dLowdate
	DO WHILE l_dDate <= l_dHighdate
		IF SEEK(DTOS(l_dDate) + l_cRoomtype)
			REPLACE (l_cStatus) WITH EVALUATE(l_cStatus) + 1
			IF NOT EMPTY(lp_nAltId)
				REPLACE av_pick WITH av_pick + 1
				STORE "" TO l_aRatecodes
				SELECT DISTINCT rr_ratecod FROM resrooms &l_cBuff ;
					INNER JOIN resrate &l_cBuff ON rr_reserid = ri_reserid ;
					WHERE ri_shareid = lp_nShareid AND rr_date = l_dDate ;
					INTO ARRAY l_aRatecodes
				AllotSet(lp_nAltId, l_cRoomtype, 1, l_dDate, LEFT(l_aRatecodes(1),10), .T.)
			ENDIF
		ENDIF
		l_dDate = l_dDate + 1
	ENDDO
ENDIF
SELECT (l_nSelect)
RETURN .T.
ENDFUNC
*
FUNCTION Status2Field
LPARAMETERS lp_cStatus
LOCAL  l_cFieldName

DO CASE
	CASE lp_cStatus = "OPT"
		l_cFieldName = "av_option"
	CASE lp_cStatus = "LST"
		l_cFieldName = "av_waiting"
	CASE lp_cStatus = "TEN"
		l_cFieldName = "av_tentat"
	OTHERWISE
		l_cFieldName = "av_definit"
ENDCASE

RETURN l_cFieldName
ENDFUNC
*
FUNCTION Status2Num
LPARAMETERS lp_cStatus
LOCAL l_nStatus

DO CASE
	CASE lp_cStatus = "DEF"
		l_nStatus = 1
	CASE lp_cStatus = "OPT"
		l_nStatus = 2
	CASE lp_cStatus = "LST"
		l_nStatus = 3
	CASE lp_cStatus = "TEN"
		l_nStatus = 4
	CASE lp_cStatus = "ASG"
		l_nStatus = 5
	CASE lp_cStatus = "6PM"
		l_nStatus = 6
	CASE lp_cStatus = "OOO"
		l_nStatus = -1
	CASE lp_cStatus = "OOS"
		l_nStatus = -2
	CASE lp_cStatus = "BLK"
		l_nStatus = 99
	OTHERWISE
		l_nStatus = 1
ENDCASE
RETURN l_nStatus
ENDFUNC
*
Function AvlRebuild
Private acRoomtype
Private noLdarea
Private nlEngth
Private ncOunter
Private nrOoms
Private ndAycounter, p_oProgress
LOCAL l_lCloseResrooms,l_nRecNo, l_nRecCount, l_dStartDate, l_dEndDate, l_curDates
LOCAL ARRAY l_aAltId(1)
 IF !TYPE("_screen.ActiveForm.name")="U"
 		IF (WEXIST ('FAddressMask') OR WEXIST ('FWeekform'))
		 	MESSAGEBOX(GetLangText("COMMON","T_CLOSEALLWINDOWSFIRST"),16,GetLangText("RECURRES","TXT_INFORMATION"))
		 	RETURN
	 	ENDIF
 ENDIF
*_screen.addproperty("laviability",.T.)
noLdarea = Select()

DO FORM "forms\progress" WITH ;
	GetLangText("AVAILAB","TW_REBUILD")+" "+ ;
	GetLangText("AVAILAB","TXT_UNTIL")+" "+ ;
	Dtoc(sySdate()-7+Param.pa_avail), ;
	.F., .T. NAME p_oProgress
p_oProgress.SetCaption(GetLangText("AVAILAB","TW_REBUILD")+" "+ ;
	GetLangText("AVAILAB","TXT_UNTIL")+" "+Dtoc(sySdate()-7+Param.pa_avail))
p_oProgress.SetLabel(1, GetLangText("AVAILAB","T_REBUILDING"))
= chEckstatus()
If (opEnfile(.T.,"Availab"))
	Select avAilab
	Zap
	If (opEnfile(.T.,"RoomPlan"))
		Select roOmplan
		Zap
		IF _screen.oGlobal.lVehicleRentMode
			SELECT rt_roomtyp, COUNT(rm_roomtyp) FROM roomtype ;
				LEFT JOIN rtypedef ON rd_rdid = rt_rdid ;
				LEFT JOIN building ON bu_buildng = rt_buildng ;
				LEFT JOIN room ON rm_roomtyp = rt_roomtyp ;
				WHERE (rt_group = 1 OR INLIST(rt_group, 3, 4) AND rt_vwshow) AND (NOT ISNULL(rm_roomnum) OR rd_verent) ;
				GROUP BY 1 ;
				INTO ARRAY acRoomtype
			nlEngth = _tally
		ELSE
			SELECT rm_roomtyp, COUNT(IIF(EMPTY(rt_buildng), "", bu_buildng)) FROM room ;
				INNER JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
				LEFT JOIN building ON bu_buildng = rt_buildng AND NOT(g_lShips AND bu_hired) ;
				WHERE rt_group = 1 OR INLIST(rt_group, 3, 4) AND rt_vwshow ;
				GROUP BY rm_roomtyp ;
				INTO ARRAY acRoomtype
			nlEngth = _tally
		ENDIF
		If nlEngth > 0
			SELECT av_date, av_roomtyp, av_avail FROM availab WHERE 0=1 INTO CURSOR curTempAvail READWRITE
			l_dStartDate = SysDate() - param.pa_holdavl
			l_dEndDate = SysDate() + param.pa_avail
			l_curDates = MakeDatesCursor(l_dStartDate, l_dEndDate)
			INSERT INTO curTempAvail (av_date) SELECT c_date FROM &l_curDates
			USE IN &l_curDates
			FOR ncOunter = 1 TO nlEngth
				p_oProgress.SetLAbel(2, Get_rt_roomtyp(acRoomtype(ncOunter,1)))
				p_oProgress.Progress(nCounter*100/nLength)
				UPDATE curTempAvail SET av_roomtyp = acRoomtype(ncOunter,1), av_avail = acRoomtype(ncOunter,2)
				SELECT availab
				APPEND FROM DBF("curTempAvail")
			NEXT
			USE IN curTempAvail
			IF _screen.oGlobal.lVehicleRentMode AND _screen.oGlobal.lVehicleRentModeOffsetInAvailab
				VehicleRent("VehicleRentFixAvailability", SysDate(), l_dEndDate, "availab")
			ENDIF
		Endif
		IF NOT USED("resrooms")
			openfiledirect(.F., "resrooms")
			l_lCloseResrooms = .T.
		ENDIF
		p_oProgress.SetLabel(1, GetLangText("AVAILAB","T_ALLOTT"))
		= alLotrebuild()
		p_oProgress.SetLabel(1, GetLangText("AVAILAB","T_OUTOFORD"))
		= ooOrebuild()
		p_oProgress.SetLabel(1, GetLangText("AVAILAB","T_PROCESSING"))
		Set Order In "Reservat" To 8
		Goto Top In "Reservat"
		l_nRecNo = 0
		l_nRecCount = RECCOUNT("reservat")
		l_dStartDate = sysdate() - Param.pa_holdavl
		DO WHILE ( .Not. EOF("Reservat"))
			l_nRecNo = l_nRecNo + 1
			p_oProgress.SetLabel(2, Dtoc(reServat.rs_arrdate))
			p_oProgress.Progress(l_nRecNo*100/l_nRecCount)
			IF (reservat.rs_depdate >= l_dStartDate) AND !INLIST(reServat.rs_status, "CXL", "NS ")
					PlanSet(reservat.rs_reserid)
					AvlSet(reServat.rs_arrdate,reServat.rs_depdate, ;
						reServat.rs_rooms,reServat.rs_status, ;
						reServat.rs_altid,reservat.rs_reserid,reservat.rs_ratecod)
			ENDIF
			Skip 1 In "Reservat"
		ENDDO
		SELECT sharing
		SCAN FOR !sd_history
			IF !INLIST(sharing.sd_status, "CXL", "NS ")
				STORE 0 TO l_aAltId
				IF _screen.KT
					SELECT DISTINCT rs_altid FROM resrooms WITH (Buffering = .T.) ;
						INNER JOIN reservat WITH (Buffering = .T.) ON rs_reserid = ri_reserid ;
						WHERE ri_shareid = sharing.sd_shareid AND NOT EMPTY(rs_altid) ;
						INTO ARRAY l_aAltId
				ENDIF
				= ShareSet(sharing.sd_shareid, l_aAltId(1))
			ENDIF
		ENDSCAN
		IF l_lCloseResrooms
			USE IN resrooms
		ENDIF
		Set Order In "Reservat" To 1
		p_oProgress.SetLabel(1, GetLangText("AVAILAB","T_ALLOTT"))
		LOCAL l_dSysdate, l_nSelected, l_cOrderAltsplit
		l_dSysdate = IIF(g_auditactive, SysDate() + 1, SysDate())
		l_nSelected = SELECT()
		SELECT ALTSPLIT
		l_cOrderAltsplit = ORDER()
		SET ORDER TO
		l_nRecCount = RECCOUNT()
		SCAN ALL
			p_oProgress.Progress(RECNO()*100/l_nRecCount)
			IF AllotmentIsExpired()
				= AdjustAllotmentRooms()
			ENDIF
		ENDSCAN
		SET ORDER TO l_cOrderAltsplit
		SELECT (l_nSelected)
	Else
		= alErt(GetLangText("AVAILAB","TA_LEAVEPROG")+"!")
	Endif
	= dcLose("roomplan")
	= dcLose("availab")
Else
	= alErt(GetLangText("AVAILAB","TA_LEAVEPROG")+"!")
Endif
= opEnfile(.F.,"RoomPlan")
= opEnfile(.F.,"Availab")
= opEnfile(.F.,"MontPln")
p_oProgress.Release()
*RELEASE _screen.laviability
= chIldtitle("")
Select (noLdarea)
Return .T.
Endfunc
*
Function ooOrebuild
	Private noLdarea
	Private ddAte
	LOCAL LSysDate, LNights, l_nRecNo, l_nRecCount, l_lOOOOpen, l_lOOSOpen
	LNights = 0
	IF g_auditactive
		LSysDate = sysdate() + 1
	ELSE
		LSysDate = sysdate()
	ENDIF
	noLdarea = Select()
	l_lOOOOpen = USED("outoford")
	If (opEnfile(.F.,"OutOfOrd"))
		Select ouToford
		Set Relation To oo_roomnum Into roOm
		Goto Top
		Do While ( .Not. Eof())
			p_oProgress.SetLabel(2, get_rm_rmname(ouToford.oo_roomnum))
			IF EMPTY(ouToford.oo_id)
				REPLACE oo_id WITH nextid("OUTOFORD") IN ouToford
			ENDIF
			If ( NOT outoford.oo_cancel AND .Not. Empty(ouToford.oo_fromdat) .And.  .Not.  ;
					EMPTY(ouToford.oo_todat))
				ddAte = ouToford.oo_fromdat
*				IF NOT BETWEEN(LSysDate, ouToford.oo_fromdat, ouToford.oo_todat-1)
*					IF ALLTRIM(roOm.rm_status) = "OOO"
*						Replace roOm.rm_status With "DIR"
*					ENDIF
*				ENDIF
				l_nRecCount = ouToford.oo_todat - dDate
				l_nRecNo = 0
				Do While (ddAte<ouToford.oo_todat)
					l_nRecNo = l_nRecNo + 1
					p_oProgress.Progress(l_nRecNo*100/l_nRecCount)
*					If (ddAte==LSysDate)
*						IF !(ALLTRIM(roOm.rm_status) = "OOO")
*							Replace roOm.rm_status With "OOO"
*						ENDIF
*					Endif
					If (Seek(Dtos(ddAte)+roOm.rm_roomtyp, "Availab"))
						Replace avAilab.av_avail With avAilab.av_avail-1
						Replace avAilab.av_ooorder With avAilab.av_ooorder+1
					ENDIF
					LNights = ouToford.oo_todat - ddAte
					Insert Into roOmplan (rp_roomnum, rp_date, rp_status,  ;
						rp_reason, rp_exinfo, rp_nights, rp_ooid) Values  ;
						(ouToford.oo_roomnum, ddAte, -1,  ;
						ouToford.oo_reason, "", LNights, ouToford.oo_id)
					ddAte = ddAte+1
				Enddo
			Endif
			Skip 1 In "OutOfOrd"
		Enddo
		Set Relation To
	Endif
	IF NOT l_lOOOOpen
		= clOsefile("OutOfOrd")
	ENDIF
	l_lOOSOpen = USED("outofser")
	If (opEnfile(.F.,"OutOfSer"))
		Select OutOfSer
		SET FILTER TO os_cancel = .F.
		Set Relation To os_roomnum Into roOm
		Goto Top
		p_oProgress.SetLabel(1, GetLangText("PLAN","T_OOS"))
		Do While ( .Not. Eof())
			p_oProgress.SetLabel(2, get_rm_rmname(OutOfSer.os_roomnum))
			If ( .Not. Empty(OutOfSer.os_fromdat) .And.  .Not.  ;
					EMPTY(OutOfSer.os_todat))
				ddAte = OutOfSer.os_fromdat
				l_nRecCount = OutOfSer.os_toDat - dDate
				l_nRecNo = 0
				Do While (ddAte<OutOfSer.os_todat)
					l_nRecNo = l_nRecNo + 1
					p_oProgress.Progress(l_nRecNo*100/l_nRecCount)
					If (Seek(Dtos(ddAte)+roOm.rm_roomtyp, "Availab"))
						Replace avAilab.av_ooservc With avAilab.av_ooservc+1
					ENDIF
					LNights = OutOfSer.os_todat - ddAte
					Insert Into roOmplan (rp_roomnum, rp_date, rp_status,  ;
						rp_reason, rp_exinfo, rp_nights, rp_osid) Values  ;
						(OutOfSer.os_roomnum, ddAte, -2,  ;
						OutOfSer.os_reason, "", LNights, OutOfSer.os_id	)
					ddAte = ddAte+1
				Enddo
			Endif
			Skip 1 In "OutOfSer"
		Enddo
		Set Relation To
	Endif
	SET FILTER TO
	IF NOT l_lOOSOpen
		= clOsefile("OutOfSer")
	ENDIF

	Select (noLdarea)
	Return .T.
Endfunc
*
FUNCTION OosUpdate
LPARAMETERS toDataOld, toDataNew
LOCAL lnSelected, lcRoomtype, ldDate

lnSelected = SELECT()

IF toDataOld.os_id # toDataNew.os_id OR toDataOld.os_fromdat # toDataNew.os_fromdat OR toDataOld.os_todat # toDataNew.os_todat OR ;
		toDataOld.os_roomnum # toDataNew.os_roomnum OR toDataOld.os_reason # toDataNew.os_reason
	IF toDataOld.os_id # 0
		* Reset for old room
		lcRoomtype = DLookUp("room", "rm_roomnum = " + sqlcnv(toDataOld.os_roomnum,.T.), "rm_roomtyp")
		ldDate = toDataOld.os_fromdat
		DO WHILE ldDate < toDataOld.os_todat
			SqlUpdate("availab", "av_date = " + SqlCnv(ldDate,.T.) + " AND av_roomtyp = " + SqlCnv(lcRoomtype,.T.), "av_ooservc = av_ooservc - 1")
			SqlDelete("roomplan", "rp_roomnum = " + SqlCnv(toDataOld.os_roomnum,.T.) + ;
				" AND rp_date =  " + SqlCnv(ldDate,.T.) + " AND rp_status = -2 AND rp_osid = " + SqlCnv(toDataOld.os_id,.T.))
			ldDate = ldDate + 1
		ENDDO
	ENDIF
	IF toDataNew.os_id # 0
		* Set for new room
		lcRoomtype = DLookUp("room", "rm_roomnum = " + SqlCnv(toDataNew.os_roomnum,.T.), "rm_roomtyp")
		ldDate = toDataNew.os_fromdat
		DO WHILE ldDate < toDataNew.os_todat
			SqlUpdate("availab", "av_date = " + SqlCnv(ldDate,.T.) + " AND av_roomtyp = " + SqlCnv(lcRoomtype,.T.), "av_ooservc = av_ooservc + 1")
			SqlInsert("roomplan", "rp_roomnum, rp_date, rp_status, rp_osid, rp_nights, rp_reason", 1, ;
				SqlCnv(toDataNew.os_roomnum,.T.) + ", " + SqlCnv(ldDate,.T.) + ", -2, " + SqlCnv(toDataNew.os_id,.T.) + ", " + ;
				SqlCnv(toDataNew.os_todat - ldDate,.T.) + ", " + SqlCnv(toDataNew.os_reason,.T.))
			ldDate = ldDate + 1
		ENDDO
	ENDIF
	DoTableUpdate(.T.,.T.,"availab")
	DoTableUpdate(.T.,.T.,"roomplan")
ENDIF

SELECT (lnSelected)
RETURN .T.
ENDFUNC
*
FUNCTION OooUpdate
LPARAMETERS toDataOld, toDataNew
LOCAL lnSelected, lcRoomtype, ldDate

lnSelected = SELECT()

IF toDataOld.oo_id # toDataNew.oo_id OR toDataOld.oo_fromdat # toDataNew.oo_fromdat OR toDataOld.oo_todat # toDataNew.oo_todat OR ;
		toDataOld.oo_roomnum # toDataNew.oo_roomnum OR toDataOld.oo_reason # toDataNew.oo_reason
	IF toDataOld.oo_id # 0
		* Reset for old room
		lcRoomtype = DLookUp("room", "rm_roomnum = " + sqlcnv(toDataOld.oo_roomnum,.T.), "rm_roomtyp")
		ldDate = toDataOld.oo_fromdat
		DO WHILE ldDate < toDataOld.oo_todat
			SqlUpdate("availab", "av_date = " + SqlCnv(ldDate,.T.) + " AND av_roomtyp = " + SqlCnv(lcRoomtype,.T.), ;
				"av_avail = av_avail + 1, av_ooorder = av_ooorder - 1")
			SqlDelete("roomplan", "rp_roomnum = " + SqlCnv(toDataOld.oo_roomnum,.T.) + ;
				" AND rp_date =  " + SqlCnv(ldDate,.T.) + " AND rp_status = -1 AND rp_ooid = " + SqlCnv(toDataOld.oo_id,.T.))
			ldDate = ldDate + 1
		ENDDO
	ENDIF
	IF toDataNew.oo_id # 0
		* Set for new room
		lcRoomtype = DLookUp("room", "rm_roomnum = " + SqlCnv(toDataNew.oo_roomnum,.T.), "rm_roomtyp")
		ldDate = toDataNew.oo_fromdat
		DO WHILE ldDate < toDataNew.oo_todat
			SqlUpdate("availab", "av_date = " + SqlCnv(ldDate,.T.) + " AND av_roomtyp = " + SqlCnv(lcRoomtype,.T.), ;
				"av_avail = av_avail - 1, av_ooorder = av_ooorder + 1")
			SqlInsert("roomplan", "rp_roomnum, rp_date, rp_status, rp_ooid, rp_nights, rp_reason", 1, ;
				SqlCnv(toDataNew.oo_roomnum,.T.) + ", " + SqlCnv(ldDate,.T.) + ", -1, " + SqlCnv(toDataNew.oo_id,.T.) + ", " + ;
				SqlCnv(toDataNew.oo_todat - ldDate,.T.) + ", " + SqlCnv(toDataNew.oo_reason,.T.))
			ldDate = ldDate + 1
		ENDDO
	ENDIF
	DoTableUpdate(.T.,.T.,"availab")
	DoTableUpdate(.T.,.T.,"roomplan")
ENDIF

SELECT (lnSelected)
RETURN .T.
ENDFUNC
*
Function alLotrebuild
	Private noLdarea
	LOCAL _ddate, _croomtype, _lrec, _lsum, ;
		l_nRecCount, l_nRecNo
	noLdarea = Select()
	SELECT altsplit
	l_nRecCount = RECCOUNT()
	l_nRecNo = 0
	SCAN
		l_nRecNo = l_nRecNo + 1
		p_oProgress.SetLabel(2, ALLTRIM(STR(altsplit.as_altid)))
		p_oProgress.Progress(l_nRecNo*100/l_nRecCount)
		IF AllotmentIsExpired()
			= AdjustAllotmentRooms()
		ENDIF
		replace as_pick WITH 0
	ENDSCAN
	SCAN
*		IF Seek(Dtos(altsplit.as_date)+altsplit.as_roomtyp,'Availab','tag1')&& OR altsplit.as_accept .And. Seek(Dtos(altsplit.as_date), 'Availab', 'tag1'))
			_ddate = as_date
			_croomtype = as_roomtyp
			_lrec = RECNO('altsplit')
			SUM as_rooms FOR (as_date = _ddate) AND (as_roomtyp = _croomtype) TO _lsum&& )+altsplit.as_roomtyp,'Availab') .Or. (altsplit.as_roomtyp='*' .And. Seek(Dtos(altsplit.as_date), 'Availab'))
			GO _lrec
			IF _croomtype = "*"
				IF SEEK(DTOS(altsplit.as_date)+ALLTRIM(param.pa_lsallot),'Availab','tag1')
					REPLACE availab.av_altall WITH _lsum
				ENDIF
			ELSE
				IF SEEK(DTOS(altsplit.as_date)+altsplit.as_roomtyp,'Availab','tag1')
					REPLACE availab.av_allott WITH _lsum
				ENDIF
			ENDIF
*		ENDIF
	ENDSCAN
	IF g_lShips
		LOCAL l_cSqlSelect, l_cTempCur
		TEXT TO l_cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
			SELECT as_date, as_roomtyp, SUM(as_rooms) AS maxrooms FROM altsplit ;
				INNER JOIN althead ON althead.al_altid = altsplit.as_altid ;
				INNER JOIN building ON building.bu_buildng = althead.al_buildng ;
				WHERE building.bu_hired = <<SqlCnv(.T.,.T.)>> ;
				GROUP BY as_date, as_roomtyp
		ENDTEXT
		l_cSqlSelect = STRTRAN(l_cSqlSelect, ";", "")
		l_cTempCur = SqlCursor(l_cSqlSelect)
		IF USED(l_cTempCur)
			SELECT &l_cTempCur
			SCAN
				IF SEEK(DTOS(&l_cTempCur..as_date)+&l_cTempCur..as_roomtyp,'Availab','tag1')
					REPLACE av_avail WITH availab.av_avail + &l_cTempCur..maxrooms IN availab
				ENDIF
			ENDSCAN
			USE IN &l_cTempCur
		ENDIF
	ENDIF
	Select (noLdarea)
	Return .T.
Endfunc
*
	Function chEckstatus
	LOCAL l_cOrder
	Select reServat
	l_cOrder = ORDER()
	SET ORDER TO
	SCAN ALL
		Do Case
		Case reServat.rs_status=="OUT"
			IF NOT reServat.rs_in == "1"
				Replace reServat.rs_in With "1"
			ENDIF
			IF NOT reServat.rs_out == "1"
				Replace reServat.rs_out With "1"
			ENDIF
		Case reServat.rs_status=="IN "
			IF NOT reServat.rs_in == "1"
				Replace reServat.rs_in With "1"
			ENDIF
			IF NOT EMPTY(reServat.rs_out)
				Replace reServat.rs_out With ""
			ENDIF
		Otherwise
			IF NOT EMPTY(reServat.rs_in)
				Replace reServat.rs_in With ""
			ENDIF
			IF NOT EMPTY(reServat.rs_out)
				Replace reServat.rs_out With ""
			ENDIF
		Endcase
	ENDSCAN
	SET ORDER TO l_cOrder
	Return .T.
Endfunc
*
PROCEDURE AvlOpenTables
 PUBLIC ARRAY g_aAvlTables(10)
 IF NOT USED("availab")
	openfiledirect(.F., "availab")
	g_aAvlTables(1) = .T.
 ENDIF
 IF NOT USED("althead")
	openfiledirect(.F., "althead")
	g_aAvlTables(2) = .T.
 ENDIF
 IF NOT USED("altsplit")
	openfiledirect(.F., "altsplit")
	g_aAvlTables(3) = .T.
 ENDIF
 IF NOT USED("roomplan")
	openfiledirect(.F., "roomplan")
	g_aAvlTables(4) = .T.
 ENDIF
 IF NOT USED("roomtype")
	openfiledirect(.F., "roomtype")
	g_aAvlTables(5) = .T.
 ENDIF
 IF NOT USED("room")
	openfiledirect(.F., "room")
	g_aAvlTables(6) = .T.
 ENDIF
ENDPROC
*
PROCEDURE AvlCloseTables
 IF g_aAvlTables(1)
	USE IN availab
 ENDIF
 IF g_aAvlTables(2)
	USE IN althead
 ENDIF
 IF g_aAvlTables(3)
	USE IN altsplit
 ENDIF
 IF g_aAvlTables(4)
	USE IN roomplan
 ENDIF
 IF g_aAvlTables(5)
	USE IN roomtype
 ENDIF
 IF g_aAvlTables(6)
	USE IN room
 ENDIF
 RELEASE g_aAvlTables
ENDPROC
*
