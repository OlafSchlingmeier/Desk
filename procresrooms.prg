*** ProcResRooms ***
*
#INCLUDE "common\progs\cryptor.h"
#INCLUDE "include\constdefines.h"
*
PROCEDURE RiRebuild
LPARAMETERS lp_lNoHistory
LOCAL l_cNear, l_cOrder, l_lShareRebuild, l_lResRoomsRebuild, l_lShareUpdate, l_lExist
LOCAL l_lCloseReservat, l_lCloseHistres, l_lCloseResrooms, l_lCloseHresroom, l_lCloseSharing, l_lCloseResrmshr

IF NOT USED("reservat")
	OpenFile(.F., "reservat")
	l_lCloseReservat = .T.
ENDIF
IF NOT USED("histres")
	OpenFile(.F., "histres")
	l_lCloseHistres = .T.
ENDIF
IF NOT USED("resrooms")
	OpenFile(.F., "resrooms")
	l_lCloseResrooms = .T.
ENDIF
IF NOT USED("hresroom")
	OpenFile(.F., "hresroom")
	l_lCloseHresroom = .T.
ENDIF
IF .F. &&FILE(gcDatadir+"resshare.dbf")  && Don't try to import old sharing. This caused errors, when resshare.dbf wasn't deleted.
	ProcCryptor(CR_REGISTER, gcDatadir, "resshare")
	openfiledirect(.F.,"resshare")
	GO TOP IN resshare
	IF EMPTY(resshare.sr_shareid)
		USE IN resshare
		ProcCryptor(CR_UNREGISTER, gcDatadir, "resshare")
	ELSE
		l_lShareRebuild = .T.
		l_lShareUpdate = .T.
		IF NOT USED("resrmshr")
			OpenFile(.F., "resrmshr")
			l_lCloseResrmshr = .T.
		ENDIF
	ENDIF
ENDIF
IF NOT lp_lNoHistory AND YesNo(GetLangText("RESERVAT","TXT_ERASERESROOMS"))
	IF NOT YesNo(Str2Msg(GetLangText("RESERVAT","TXT_DOERASERESROOMS")))
		RETURN
	ENDIF
	l_lResRoomsRebuild = .T.
ENDIF
LOCAL ARRAY l_aTasks(2,2)
l_aTasks(1,1) = RECCOUNT("histres")
l_aTasks(1,2) = GetLangText("MENU","MNT_HRESROOMRBLD")+"..."
l_aTasks(2,1) = RECCOUNT("reservat")
l_aTasks(2,2) = GetLangText("MENU","MNT_RESROOMSRBLD")+"..."
DO FORM forms\progressbar NAME ProgressBar WITH GetLangText("MENU","MNT_RESROOMSRBLD"), l_aTasks
l_cNear = SET("Near")
SET NEAR ON
IF NOT lp_lNoHistory
	******************** Prepare SQLs for archive ******************************************************
	*
	ProcArchive("RestoreArchive", "histres", "SELECT histres.* FROM histres WHERE hr_reserid >= 1")
	*
	****************************************************************************************************
	ON KEY LABEL ALT+Q GO BOTTOM IN histres
	SELECT histres
	l_cOrder = ORDER()
	SET ORDER TO
	SCAN FOR (hr_reserid >= 1) AND NOT EMPTY(hr_arrdate)
		ProgressBar.Update(RECNO(),1)
		l_lExist = SEEK(STR(histres.hr_reserid,12,3)+DTOS(histres.hr_arrdate),"hresroom","tag2")
		IF l_lShareUpdate AND l_lExist AND NOT EMPTY(hresroom.ri_shareid)
			l_lShareUpdate = .F.
		ENDIF
		IF NOT l_lExist OR l_lResRoomsRebuild
			SELECT hresroom
			SCATTER NAME l_oResrooms
			IF NOT l_lExist
				l_oResrooms.ri_rroomid = NextId("RESROOMS")
				APPEND BLANK
			ENDIF
			l_oResrooms.ri_date = histres.hr_arrdate
			IF l_lShareRebuild AND SEEK(histres.hr_reserid,"resshare","tag2")
				l_oResrooms.ri_shareid = resshare.sr_shareid
				IF NOT SEEK(histres.hr_reserid,"reservat","tag1")
					IF SEEK(l_oResrooms.ri_rroomid,"resrmshr","tag2")
						REPLACE sr_shareid WITH l_oResrooms.ri_shareid IN resrmshr
					ELSE
						INSERT INTO resrmshr (sr_shareid, sr_rroomid) VALUES (l_oResrooms.ri_shareid, l_oResrooms.ri_rroomid)
					ENDIF
				ENDIF
			ELSE
				l_oResrooms.ri_shareid = 0
			ENDIF
			IF l_oResrooms.ri_reserid <> histres.hr_reserid OR l_lResRoomsRebuild
				l_oResrooms.ri_reserid = histres.hr_reserid
				l_oResrooms.ri_roomtyp = histres.hr_roomtyp
				l_oResrooms.ri_roomnum = IIF(EMPTY(l_oResrooms.ri_roomtyp),"",histres.hr_roomnum)
				l_oResrooms.ri_todate = IIF(DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(histres.hr_roomtyp), "rt_group") = 2, ;
					histres.hr_depdate, MAX(histres.hr_arrdate,histres.hr_depdate-1))
			ENDIF
			GATHER NAME l_oResrooms
			SELECT histres
		ENDIF
	ENDSCAN
	IF l_lResRoomsRebuild
		DELETE FOR NOT SEEK(hresroom.ri_reserid,"histres","tag1") OR ri_date <> histres.hr_arrdate OR ri_roomtyp <> histres.hr_roomtyp OR ri_roomnum <> histres.hr_roomnum IN hresroom
	ENDIF
	SET ORDER TO l_cOrder
	******************** Delete temp files *************************************************************
	*
	ProcArchive("DeleteTempArchive", "histres")
	*
	****************************************************************************************************
ENDIF
ON KEY LABEL ALT+Q GO BOTTOM IN reservat
SELECT reservat
l_cOrder = ORDER()
SET ORDER TO
SCAN FOR (rs_reserid >= 1) AND NOT EMPTY(rs_arrdate)
	ProgressBar.Update(RECNO(),2)
	l_lExist = SEEK(STR(reservat.rs_reserid,12,3)+DTOS(reservat.rs_arrdate),"resrooms","tag2")
	IF l_lShareUpdate AND l_lExist AND NOT EMPTY(resrooms.ri_shareid)
		l_lShareUpdate = .F.
	ENDIF
	IF NOT l_lExist OR l_lResRoomsRebuild
		SELECT resrooms
		SCATTER NAME l_oResrooms
		IF NOT l_lExist
			l_oResrooms.ri_rroomid = NextId("RESROOMS")
			APPEND BLANK
		ENDIF
		l_oResrooms.ri_date = reservat.rs_arrdate
		IF l_lShareRebuild AND SEEK(reservat.rs_reserid,"resshare","tag2")
			l_oResrooms.ri_shareid = resshare.sr_shareid
			IF SEEK(l_oResrooms.ri_rroomid,"resrmshr","tag2")
				REPLACE sr_shareid WITH l_oResrooms.ri_shareid IN resrmshr
			ELSE
				INSERT INTO resrmshr (sr_shareid, sr_rroomid) VALUES (l_oResrooms.ri_shareid, l_oResrooms.ri_rroomid)
			ENDIF
		ELSE
			l_oResrooms.ri_shareid = 0
		ENDIF
		IF l_oResrooms.ri_reserid <> reservat.rs_reserid OR l_lResRoomsRebuild
			l_oResrooms.ri_reserid = reservat.rs_reserid
			l_oResrooms.ri_roomtyp = reservat.rs_roomtyp
			l_oResrooms.ri_roomnum = IIF(EMPTY(l_oResrooms.ri_roomtyp),"",reservat.rs_roomnum)
			l_oResrooms.ri_todate = IIF(DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(reservat.rs_roomtyp), "rt_group") = 2, ;
				reservat.rs_depdate, MAX(reservat.rs_arrdate,reservat.rs_depdate-1))
		ENDIF
		GATHER NAME l_oResrooms
		SELECT reservat
	ENDIF
ENDSCAN
IF l_lResRoomsRebuild
	DELETE FOR NOT SEEK(resrooms.ri_reserid,"reservat","tag1") OR ri_date <> reservat.rs_arrdate OR ri_roomtyp <> reservat.rs_roomtyp OR ri_roomnum <> reservat.rs_roomnum IN resrooms
ENDIF
IF l_lShareRebuild
	IF l_lShareUpdate
		IF NOT USED("sharing")
			OpenFile(.F., "sharing")
			l_lCloseSharing = .T.
		ENDIF
		REPLACE sd_highdat WITH MAX(sd_lowdat, sd_highdat - 1) ALL IN sharing
		IF CURSORGETPROP("Buffering","sharing") = 5
			= TABLEUPDATE(.T.,.T.,"sharing")
		ENDIF
		IF l_lCloseSharing
			CloseFile("sharing")
		ENDIF
	ENDIF
	IF CURSORGETPROP("Buffering","resrmshr") = 5
		= TABLEUPDATE(.T.,.T.,"resrmshr")
	ENDIF
	IF l_lCloseResrmshr
		CloseFile("resrmshr")
	ENDIF
	IF USED("resshare")
		USE IN resshare
		ProcCryptor(CR_UNREGISTER, gcDatadir, "resshare")
	ENDIF
ENDIF
SET ORDER TO l_cOrder
ON KEY LABEL ALT+Q ON KEY
SET NEAR &l_cNear
ProgressBar.Complete()
IF l_lCloseReservat
	CloseFile("reservat")
ENDIF
IF l_lCloseHistres
	CloseFile("histres")
ENDIF
IF l_lCloseResrooms
	CloseFile("resrooms")
ENDIF
IF l_lCloseHresroom
	CloseFile("hresroom")
ENDIF
ENDPROC
*
PROCEDURE RiRebuildToDate
LOCAL l_nReserid, l_dToDate, l_cOrder, l_cOrderRs, l_cRiRoomtyp, l_nRtGroup

l_cOrderRs = ORDER("histres")
SET ORDER TO "" IN histres
SELECT hresroom
l_cOrder = ORDER()
SET ORDER TO tag2
SCAN
	l_nReserid = ri_reserid
	l_cRiRoomtyp = ri_roomtyp
	SKIP
	IF ri_reserid = l_nReserid
		l_dToDate = ri_date-1
	ELSE
		l_nRtGroup = DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(l_cRiRoomtyp), "rt_group")
		l_dToDate = DLookUp("histres", "hr_reserid = " + SqlCnv(l_nReserid,.T.), IIF(l_nRtGroup = 2, "hr_depdate", "MAX(hr_arrdate,hr_depdate-1)"))
	ENDIF
	SKIP -1
	REPLACE ri_todate WITH l_dToDate
ENDSCAN
SET ORDER TO &l_cOrder
SET ORDER TO l_cOrderRs IN histres

l_cOrderRs = ORDER("reservat")
SET ORDER TO "" IN reservat
SELECT resrooms
l_cOrder = ORDER()
SET ORDER TO tag2
SCAN
	l_nReserid = ri_reserid
	l_cRiRoomtyp = ri_roomtyp
	SKIP
	IF ri_reserid = l_nReserid
		l_dToDate = ri_date-1
	ELSE
		l_nRtGroup = DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(l_cRiRoomtyp), "rt_group")
		l_dToDate = DLookUp("reservat", "rs_reserid = " + SqlCnv(l_nReserid,.T.), IIF(l_nRtGroup = 2, "rs_depdate", "MAX(rs_arrdate,rs_depdate-1)"))
	ENDIF
	SKIP -1
	REPLACE ri_todate WITH l_dToDate
ENDSCAN
SET ORDER TO &l_cOrder
SET ORDER TO l_cOrderRs IN reservat
ENDPROC
*
PROCEDURE RiCheck
LPARAMETERS lp_nReserId, lp_dArrdate, lp_dDepdate, lp_cRoomtyp, lp_cRoomnum, lp_cResrooms
LOCAL l_nArea, l_cOrder, l_oResrooms, l_dRiDate, l_dRiTodate, l_cRiRoomtyp, l_nRtGroup

IF PCOUNT() < 5 OR ISNULL(lp_nReserId) OR EMPTY(lp_nReserId) OR EMPTY(lp_dArrdate)
	RETURN
ENDIF

IF EMPTY(lp_cResRooms)
	lp_cResRooms = "resrooms"
ENDIF

l_cOrder = ORDER(lp_cResRooms)
SET ORDER TO "" IN &lp_cResrooms

CALCULATE MIN(ri_date) FOR ri_reserid = lp_nReserid TO l_dRiDate IN &lp_cResrooms
IF NOT EMPTY(l_dRiDate)
	REPLACE ri_date WITH lp_dArrdate FOR ri_reserid = lp_nReserid AND ri_date = l_dRiDate IN &lp_cResrooms
	DELETE FOR ri_reserid = lp_nReserid AND ri_date < lp_dArrdate IN &lp_cResrooms
ENDIF

* Check if last interval of reservation is type of CONFERENCE. If is, than is always ri_todate = rs_depdate.
CALCULATE MAX(ri_todate) FOR ri_reserid = lp_nReserid TO l_dRiTodate IN &lp_cResrooms
IF NOT EMPTY(l_dRiTodate)
	l_cRiRoomtyp = DLookUp(lp_cResrooms, "ri_reserid = " + SqlCnv(lp_nReserid) + " AND ri_todate = " + SqlCnv(l_dRiTodate), "ri_roomtyp")
	l_nRtGroup = DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(l_cRiRoomtyp), "rt_group")
ELSE
	l_nRtGroup = 0
ENDIF
IF l_nRtGroup <> 2
	lp_dDepdate = MAX(lp_dArrdate,lp_dDepdate-1)
ENDIF
IF NOT EMPTY(l_dRiDate)
	REPLACE ri_todate WITH lp_dDepdate FOR ri_reserid = lp_nReserid AND ri_date <= lp_dDepdate AND ri_todate = l_dRiTodate IN &lp_cResrooms
	DELETE FOR ri_reserid = lp_nReserid AND ri_todate > lp_dDepdate IN &lp_cResrooms
	IF SysDate() > lp_dDepdate AND _tally > 0
		RiGetRoom(lp_nReserid, lp_dDepdate, @l_oResrooms, lp_cResrooms)
		IF NOT ISNULL(l_oResrooms) AND NOT RiSameRoomnum(l_oResrooms, lp_cRoomnum, lp_cRoomtyp)
			RiGetRoomnum(l_oResrooms, @lp_cRoomnum, @lp_cRoomtyp)
		ENDIF
	ENDIF
ENDIF

RiGetRoom(lp_nReserid, lp_dArrdate, @l_oResrooms, lp_cResrooms)
DO CASE
	CASE ISNULL(l_oResrooms)
		INSERT INTO &lp_cResrooms (ri_date, ri_todate, ri_reserid, ri_rroomid, ri_roomtyp, ri_roomnum) ;
			VALUES (lp_dArrdate, lp_dDepdate, lp_nReserid, NextId("RESROOMS"), lp_cRoomtyp, lp_cRoomnum)
	CASE lp_dArrdate >= SysDate() AND NOT RiSameRoomnum(l_oResrooms, lp_cRoomnum, lp_cRoomtyp)
		RiPutRoom(lp_nReserId, lp_dArrdate, {}, lp_cRoomtyp, lp_cRoomnum)
	OTHERWISE
ENDCASE

SET ORDER TO l_cOrder IN &lp_cResrooms
ENDPROC
*
FUNCTION RiGetRoom
LPARAMETERS lp_nReserId, lp_dDate, lp_oResrooms, lp_cResrooms, lp_uDummy
LOCAL l_nArea, l_nRecno, lp_lRetval, l_dRiDate, l_dRiTodate, l_oResrooms2, l_lUseSecondRecord, l_cOrder

lp_lRetval = .F.
lp_oResrooms = .NULL.
l_oResrooms2 = .NULL.
IF PCOUNT() < 3 OR ISNULL(lp_nReserId) OR EMPTY(lp_nReserId)
	RETURN lp_lRetval
ENDIF

l_lUseSecondRecord = VARTYPE(lp_cResrooms) <> "C" AND PCOUNT() > 3
IF l_lUseSecondRecord
	lp_cResRooms = lp_uDummy
ENDIF
IF EMPTY(lp_cResRooms)
	lp_cResRooms = "resrooms"
ENDIF

l_nRecno = RECNO(lp_cResRooms)
l_cOrder = ORDER(lp_cResrooms)
SET ORDER TO "" IN &lp_cResrooms

CALCULATE MIN(ri_date), MAX(ri_todate) FOR ri_reserid = lp_nReserid TO l_dRiDate, l_dRiTodate IN &lp_cResrooms
IF NOT EMPTY(l_dRiDate) AND NOT EMPTY(l_dRiTodate)
	lp_dDate = MIN(MAX(lp_dDate, l_dRiDate), l_dRiTodate)
ENDIF
IF SEEK(STR(lp_nReserId,12,3),lp_cResRooms,"tag2")
	*DLocate(lp_cResRooms, "ri_reserid = " + SqlCnv(lp_nReserId) + " AND BETWEEN(" + SqlCnv(lp_dDate) + ", ri_date, ri_todate)")
	l_nArea = SELECT()
	SELECT &lp_cResRooms
	SET ORDER TO tag2
	LOCATE FOR BETWEEN(lp_dDate, ri_date, ri_todate) REST WHILE ri_reserid = lp_nReserId
	IF FOUND()
		SCATTER NAME lp_oResrooms
		IF l_lUseSecondRecord
			SCATTER NAME l_oResrooms2
			LOCATE FOR BETWEEN(lp_oResrooms.ri_todate+1, ri_date, ri_todate) REST WHILE ri_reserid = lp_nReserId
			IF FOUND()
			* DLocate(lp_cResRooms, "ri_reserid = " + SqlCnv(lp_nReserId) + " AND BETWEEN(" + SqlCnv(lp_oResrooms.ri_todate+1) + ", ri_date, ri_todate)")
				SCATTER NAME l_oResrooms2
			ENDIF
		ENDIF
		lp_lRetval = (lp_dDate >= lp_oResrooms.ri_date)
	ENDIF
	SELECT (l_nArea)
ENDIF

SET ORDER TO l_cOrder IN &lp_cResrooms
GO l_nRecno IN &lp_cResRooms

IF l_lUseSecondRecord
	lp_cResrooms = l_oResrooms2	&& Temporaly while used 2nd resrooms record in code. (Backward compatibility)
ENDIF

RETURN lp_lRetval
ENDFUNC
*
PROCEDURE RiPutError
LPARAMETERS lp_nReserId, lp_cResRooms
LOCAL l_lCloseReservat, l_lError
LOCAL ARRAY l_aOldReser(1)
IF JUSTSTEM(DBF(lp_cResRooms)) = "RESROOMS"
	l_lCloseReservat = NOT USED("reservat")
	SELECT rs_reserid FROM reservat WHERE rs_reserid = lp_nReserId INTO ARRAY l_aOldReser
	IF l_lCloseReservat
		USE IN reservat
	ENDIF
	l_lError = NOT EMPTY(l_aOldReser(1))
ELSE
	l_lError = .T.
ENDIF
IF l_lError
	ErrorMsg("CallProc: "+PROGRAM(PROGRAM(-1)-1)+" No ResRooms record for ReserId: "+STR(lp_nReserId,12,3))
ENDIF
ENDPROC
*
PROCEDURE RiPutRoom
* Left border:
* 1. 0 = NULL (FD = Arrival)		=>	Rn1 = RN
* 2. 0 = 1, Rn0 = RN			=>	Rn1 = RN
* 3. 0 = 1, Rn0 # RN			=>	split 0 (new is 1), td0 = FD-1, fd1 = FD.
* 4. 0 # 1, Rn0 = RN			=>	merge 0+1=>0 (delete 1), td0 = td1.
* 5. 0 # 1, Rn0 # RN			=>	Rn1 = RN
*
* Right border:
* 1. 4 = NULL (TD = Departure)	=>	Rn3 = RN
* 2. 4 = 3, Rn4 = RN			=>	Rn3 = RN
* 3. 4 = 3, Rn4 # RN			=>	split 4 (new is 3), fd4 = TD+1, td3 = TD.
* 4. 4 # 3, Rn4 = RN			=>	merge 3+4=>4 (delete 3), fd4 = fd3.
* 5. 4 # 3, Rn4 # RN			=>	Rn3 = RN
*
LPARAMETERS lp_nReserId, lp_dFromDate, lp_dToDate, lp_cRoomtyp, lp_cRoomnum, lp_nShareId
LOCAL l_nArea, l_oResrooms0, l_oResrooms1, l_oResrooms3, l_oResrooms4, l_cResRooms

IF (PCOUNT() < 5) OR ISNULL(lp_nReserId) OR EMPTY(lp_nReserId)
	RETURN
ENDIF
l_cResRooms = "resrooms"
lp_cRoomtyp = PADR(lp_cRoomtyp,4)
lp_cRoomnum = PADR(lp_cRoomnum,4)
RiGetRoom(lp_nReserId, lp_dFromDate-1, @l_oResrooms0, l_cResRooms)			&& If l_oResrooms0 ON lp_dFromDate-1 (BEFORE lp_dFromDate).
RiGetRoom(lp_nReserId, lp_dFromDate, @l_oResrooms1, l_cResRooms)				&& If l_oResrooms1 ON lp_dFromDate.
IF ISNULL(l_oResrooms0) OR ISNULL(l_oResrooms1)
	RETURN
ENDIF
IF l_oResrooms0.ri_rroomid = l_oResrooms1.ri_rroomid
	* Relate by ref. 0=1 if the same record
	l_oResrooms0 = IIF(l_oResrooms0.ri_date > lp_dFromDate-1, .NULL., l_oResrooms1)
ENDIF
lp_dToDate = EVL(lp_dToDate,l_oResrooms1.ri_todate)
RiGetRoom(lp_nReserId, lp_dToDate, @l_oResrooms3, l_cResRooms)				&& If l_oResrooms3 ON lp_dToDate.
RiGetRoom(lp_nReserId, lp_dToDate+1, @l_oResrooms4, l_cResRooms)				&& If l_oResrooms4 ON lp_dToDate+1 (AFTER lp_dToDate).
IF ISNULL(l_oResrooms3) OR ISNULL(l_oResrooms4)
	RETURN
ENDIF
IF l_oResrooms3.ri_rroomid = l_oResrooms4.ri_rroomid
	* Relate by ref. 3=4 if the same record
	l_oResrooms4 = IIF(l_oResrooms4.ri_todate < lp_dToDate+1, .NULL., l_oResrooms3)
ENDIF

* Calculate FromDate (FD) boundary!!!
DO CASE
	CASE ISNULL(l_oResrooms0)
		* FD = Arrival.
	CASE l_oResrooms0 = l_oResrooms1 AND RiSameRoomnum(l_oResrooms0, lp_cRoomnum, lp_cRoomtyp)
		* 0 = 1 and rn0 = RN.
	CASE l_oResrooms0 = l_oResrooms1 AND NOT RiSameRoomnum(l_oResrooms0, lp_cRoomnum, lp_cRoomtyp)
		* 0 = 1 and rn0 # RN	=>	split 0 (new is 1), td0 = FD-1, fd1 = FD.
		l_oResrooms1 = RecordCopyObj(l_oResrooms0)
		l_oResrooms1.ri_rroomid = 0		&& 1st make new
		l_oResrooms0.ri_todate = lp_dFromDate-1
		l_oResrooms1.ri_date = lp_dFromDate
	CASE l_oResrooms0 # l_oResrooms1 AND RiSameRoomnum(l_oResrooms0, lp_cRoomnum, lp_cRoomtyp)
		* 0 # 1 and rn0 = RN	=>	merge 0+1 (delete 1).
		IF l_oResrooms1.ri_rroomid # l_oResrooms3.ri_rroomid
			DELETE FOR ri_rroomid = l_oResrooms1.ri_rroomid IN &l_cResRooms
		ENDIF
		l_oResrooms0.ri_todate = l_oResrooms1.ri_todate
		l_oResrooms1 = l_oResrooms0
	CASE l_oResrooms0 # l_oResrooms1 AND NOT RiSameRoomnum(l_oResrooms0, lp_cRoomnum, lp_cRoomtyp)
		* 0 # 1 and rn0 # RN.
	OTHERWISE
ENDCASE
* Calculate ToDate (TD) boundary!!!
DO CASE
	CASE ISNULL(l_oResrooms4)
		* TD = Departure.
	CASE l_oResrooms3 = l_oResrooms4 AND RiSameRoomnum(l_oResrooms4, lp_cRoomnum, lp_cRoomtyp)
		* 3 = 4 and rn4 = RN.
	CASE l_oResrooms3 = l_oResrooms4 AND NOT RiSameRoomnum(l_oResrooms4, lp_cRoomnum, lp_cRoomtyp)
		* 3 = 4 and rn4 # RN	=>	split 4 (new is 3), fd4 = TD+1, td3 = TD.
		IF l_oResrooms3.ri_rroomid # l_oResrooms1.ri_rroomid AND (ISNULL(l_oResrooms0) OR l_oResrooms3.ri_rroomid # l_oResrooms0.ri_rroomid)
			l_oResrooms3 = RecordCopyObj(l_oResrooms4)
			l_oResrooms3.ri_rroomid = 0		&& 3rd make new
		ELSE
			l_oResrooms4 = RecordCopyObj(l_oResrooms3)
			l_oResrooms4.ri_rroomid = 0		&& 4th make new because 3rd would be 1st and not updated.
		ENDIF
		l_oResrooms4.ri_date = lp_dToDate+1
		l_oResrooms3.ri_todate = lp_dToDate
		IF l_oResrooms4.ri_roomnum = VIRTUAL_ROOMNUM
			l_oResrooms4.ri_roomnum = ""
			l_oResrooms4.ri_shareid = 0
		ENDIF
	CASE l_oResrooms3 # l_oResrooms4 AND RiSameRoomnum(l_oResrooms4, lp_cRoomnum, lp_cRoomtyp)
		* 3 # 4 and rn4 = RN	=>	merge 3+4 (delete 3).
		IF l_oResrooms3.ri_rroomid # l_oResrooms1.ri_rroomid AND (ISNULL(l_oResrooms0) OR l_oResrooms3.ri_rroomid # l_oResrooms0.ri_rroomid)
			DELETE FOR ri_rroomid = l_oResrooms3.ri_rroomid IN &l_cResRooms
		ENDIF
		l_oResrooms4.ri_date = l_oResrooms3.ri_date
		l_oResrooms3 = l_oResrooms4
	CASE l_oResrooms3 # l_oResrooms4 AND NOT RiSameRoomnum(l_oResrooms4, lp_cRoomnum, lp_cRoomtyp)
		* 3 # 4 and rn4 # RN	=>	rn3 = RN.
	OTHERWISE
ENDCASE
* Merge 1+3 in 1st and 3rd wouldn't be updated.
l_oResrooms1.ri_todate = l_oResrooms3.ri_todate
IF l_oResrooms4 = l_oResrooms3
	l_oResrooms4 = l_oResrooms1
ENDIF
l_oResrooms3 = l_oResrooms1

IF NOT RiSameRoomnum(l_oResrooms1, lp_cRoomnum, lp_cRoomtyp)
	RiSetRoomnum(l_oResrooms1, lp_cRoomnum, lp_cRoomtyp)
	l_oResrooms1.ri_shareid = EVL(lp_nShareId,0)
ENDIF

IF l_oResrooms1.ri_rroomid = 0
	l_oResrooms1.ri_rroomid = NextId("RESROOMS")
	INSERT INTO &l_cResRooms (ri_rroomid) VALUES (l_oResrooms1.ri_rroomid)
ENDIF
IF NOT ISNULL(l_oResrooms4) AND l_oResrooms4.ri_rroomid = 0
	l_oResrooms4.ri_rroomid = NextId("RESROOMS")
	INSERT INTO &l_cResRooms (ri_rroomid) VALUES (l_oResrooms4.ri_rroomid)
ENDIF

l_nArea = SELECT()

SELECT &l_cResRooms
IF ri_rroomid = l_oResrooms1.ri_rroomid OR SEEK(l_oResrooms1.ri_rroomid,l_cResRooms,"tag3")
	IF RecordChanged(l_oResrooms1, l_cResRooms)
		GATHER NAME l_oResrooms1
	ENDIF
ENDIF
IF NOT ISNULL(l_oResrooms0) AND l_oResrooms0 # l_oResrooms1
	IF ri_rroomid = l_oResrooms0.ri_rroomid OR SEEK(l_oResrooms0.ri_rroomid,l_cResRooms,"tag3")
		IF RecordChanged(l_oResrooms0, l_cResRooms)
			GATHER NAME l_oResrooms0
		ENDIF
	ENDIF
ENDIF
IF NOT ISNULL(l_oResrooms4) AND l_oResrooms4 # l_oResrooms1
	IF ri_rroomid = l_oResrooms4.ri_rroomid OR SEEK(l_oResrooms4.ri_rroomid,l_cResRooms,"tag3")
		IF RecordChanged(l_oResrooms4, l_cResRooms)
			GATHER NAME l_oResrooms4
		ENDIF
	ENDIF
ENDIF
* Clean/delete all dummy records inside interval 1. (ri_date+1 <-> ri_todate)
DELETE FOR BETWEEN(STR(ri_reserid,12,3)+DTOS(ri_date), STR(lp_nReserId,12,3)+DTOS(l_oResrooms1.ri_date+1), STR(lp_nReserId,12,3)+DTOS(l_oResrooms3.ri_todate)) IN &l_cResRooms

SELECT (l_nArea)
ENDPROC
*
PROCEDURE RiSetRoomnum
LPARAMETERS lp_oResrooms, lp_cRoomnum, lp_cRoomtyp

lp_oResrooms.ri_roomnum = lp_cRoomnum
lp_oResrooms.ri_roomtyp = lp_cRoomtyp
ENDPROC
*
PROCEDURE RiGetRoomnum
LPARAMETERS lp_oResrooms, lp_cRoomnum, lp_cRoomtyp

lp_cRoomnum = lp_oResrooms.ri_roomnum
lp_cRoomtyp = lp_oResrooms.ri_roomtyp
ENDPROC
*
FUNCTION RiSameRoomnum
LPARAMETERS lp_oResrooms, lp_cRoomnum, lp_cRoomtyp
LOCAL llSame

llSame = (lp_oResrooms.ri_roomnum == lp_cRoomnum AND lp_oResrooms.ri_roomtyp == lp_cRoomtyp)

RETURN llSame
ENDFUNC
*
FUNCTION RiChanged
LPARAMETERS lp_lResroomschanged, lp_cForClause, lp_cOldTable, lp_cNewTable
LOCAL l_lChanged, i
lp_lResroomschanged = .F.
IF EMPTY(lp_cNewTable)
	lp_cNewTable = "resrooms"
ENDIF
IF EMPTY(lp_cOldTable)
	lp_cOldTable = IIF(USED("ResroomsOld"), "ResroomsOld", "resrooms")
ENDIF
AFIELDS(l_aFields, lp_cNewTable)
SELECT &lp_cNewTable
SCAN FOR &lp_cForClause
	IF SEEK(&lp_cNewTable..ri_rroomid, lp_cOldTable, "tag3")
		FOR i = 1 TO ALEN(l_aFields,1)
			IF NOT (EVALUATE(lp_cNewTable+"."+l_aFields(i,1)) == EVALUATE(lp_cOldTable+"."+l_aFields(i,1)))
				lp_lResroomschanged = .T.
				EXIT
			ENDIF
		ENDFOR
	ELSE
		lp_lResroomschanged = .T.
	ENDIF
	IF lp_lResroomschanged
		EXIT
	ENDIF
ENDSCAN
IF NOT lp_lResroomschanged
	SELECT &lp_cOldTable
	SCAN FOR &lp_cForClause
		IF NOT SEEK(&lp_cOldTable..ri_rroomid, lp_cNewTable, "tag3")
			lp_lResroomschanged = .T.
			EXIT
		ENDIF
	ENDSCAN
ENDIF
RETURN lp_lResroomschanged
ENDFUNC
*
FUNCTION RiShareInterval
LPARAMETERS lp_lRetVal, lp_nShareid, lp_dLowdate, lp_dHighdate, lp_cLabel, lp_dSysdate, lp_nAltId
LOCAL l_lRetVal, l_nRecno, l_nHRecno, l_nRecnoRT, l_nArea, l_lIsInReservat, l_lIsInHistres, l_dRiStartDate, l_oReservationNextState

l_nArea = SELECT()
l_nRecnoRT = RECNO("roomtype")
l_nRecno = RECNO("reservat")
l_nHRecno = RECNO("histres")
SELECT resrmshr
SCAN FOR sr_shareid = lp_nShareid
	l_lIsInReservat = SEEK(resrmshr.sr_rroomid,"resrooms","tag3") AND SEEK(resrooms.ri_reserid,"reservat","tag1")
	IF NOT l_lIsInReservat
		l_lIsInHistres = SEEK(resrmshr.sr_rroomid,"hresroom","tag3") AND SEEK(hresroom.ri_reserid,"histres","tag1")
	ENDIF
	DO CASE
		CASE lp_cLabel = "ALLOTMENT"
			DO CASE
				CASE EMPTY(lp_nAltId)
					l_lRetVal = .T.
				CASE l_lIsInReservat
					IF reservat.rs_altid = lp_nAltId
						l_lRetVal = .T.
					ENDIF
				CASE l_lIsInHistres
					 IF histres.hr_altid = lp_nAltId
						 l_lRetVal = .T.
					 ENDIF
				OTHERWISE
			ENDCASE
		CASE INLIST(lp_cLabel, "ARRIVAL", "ROOMARR")
			IF l_lIsInReservat
				IF lp_dLowdate = reservat.rs_arrdate
					l_lRetVal = .T.
				ENDIF
			ELSE
				 IF l_lIsInHistres
					 IF lp_dLowdate = histres.hr_arrdate
						 l_lRetVal = .T.
					 ENDIF
				 ENDIF
			ENDIF
		CASE INLIST(lp_cLabel, "DEPARTURE", "ROOMDEP")
			IF l_lIsInReservat
				IF (reservat.rs_depdate = lp_dSysdate) AND (lp_dHighdate = MAX(reservat.rs_arrdate,reservat.rs_depdate-1))
					l_lRetVal = .T.
				ENDIF
			ELSE
				 IF l_lIsInHistres
					 IF (histres.hr_depdate = lp_dSysdate) AND (lp_dHighdate = MAX(histres.hr_arrdate,histres.hr_depdate-1))
						 l_lRetVal = .T.
					 ENDIF
				 ENDIF
			ENDIF
		CASE lp_cLabel = "DAYUSE"
			IF l_lIsInReservat
				IF (reservat.rs_arrdate <> lp_dSysdate) OR (reservat.rs_arrdate < reservat.rs_depdate)
					l_lRetVal = .T.
				ENDIF
			ELSE
				 IF l_lIsInHistres
					 IF (histres.hr_arrdate <> lp_dLowdate) OR (histres.hr_arrdate < histres.hr_depdate)
						 l_lRetVal = .T.
					 ENDIF
				 ENDIF
			ENDIF
		CASE lp_cLabel = "COMPLIM"
			IF l_lIsInReservat
				IF NOT reservat.rs_complim
					l_lRetVal = .T.
				ENDIF
			ELSE
				 IF l_lIsInHistres
					 IF NOT histres.hr_complim
						 l_lRetVal = .T.
					 ENDIF
				 ENDIF
			ENDIF
		OTHERWISE
			EXIT
	ENDCASE
	IF l_lRetVal
		EXIT
	ENDIF
ENDSCAN
IF NOT l_lRetVal AND INLIST(lp_cLabel, "ROOMARR", "ROOMDEP") AND SEEK(lp_nShareid,"resrmshr","tag1")
	l_lRetVal = .T.
	SELECT resrmshr
	SCAN FOR sr_shareid = lp_nShareid
		l_lIsInReservat = SEEK(resrmshr.sr_rroomid,"resrooms","tag3") AND SEEK(resrooms.ri_reserid,"reservat","tag1")
		IF NOT l_lIsInReservat
			l_lIsInHistres = SEEK(resrmshr.sr_rroomid,"hresroom","tag3") AND SEEK(hresroom.ri_reserid,"histres","tag1")
		ENDIF
		DO CASE
			CASE NOT l_lIsInReservat AND NOT l_lIsInHistres
				l_lRetVal = .F.
				EXIT
			CASE (lp_cLabel = "ROOMARR") AND (lp_dLowdate = lp_dSysdate)
				IF l_lIsInReservat
					IF (reservat.rs_arrdate < resrooms.ri_date) AND ;
							NOT IsNonStandardRtGrShareInterval(reservat.rs_reserid, lp_dLowdate-1, "resrooms")
						l_lRetVal = .F.
						EXIT
					ENDIF
				ELSE
					IF (histres.hr_arrdate < hresroom.ri_date) AND ;
							NOT IsNonStandardRtGrShareInterval(histres.hr_reserid, lp_dLowdate-1, "hresroom")
						l_lRetVal = .F.
						EXIT
					ENDIF
				ENDIF
			CASE (lp_cLabel = "ROOMDEP") AND (lp_dHighdate+1 = lp_dSysdate)
				IF l_lIsInReservat
					l_dRiStartDate = resrooms.ri_date
					IF NOT IsNonStandardRtGrShareInterval(reservat.rs_reserid, lp_dHighdate+1, "resrooms")
						RiGetRoom(reservat.rs_reserid, resrooms.ri_todate+1, @l_oReservationNextState)
						IF ISNULL(l_oReservationNextState) OR (l_dRiStartDate < l_oReservationNextState.ri_date)
							l_lRetVal = .F.
							EXIT
						ENDIF
					ENDIF
				ELSE
					l_dRiStartDate = hresroom.ri_date
					IF NOT IsNonStandardRtGrShareInterval(histres.hr_reserid, lp_dHighdate+1, "hresroom")
						RiGetRoom(histres.hr_reserid, hresroom.ri_todate+1, @l_oReservationNextState, "hresroom")
						IF ISNULL(l_oReservationNextState) OR (l_dRiStartDate < l_oReservationNextState.ri_date)
							l_lRetVal = .F.
							EXIT
						ENDIF
					ENDIF
				ENDIF
			OTHERWISE
				l_lRetVal = .F.
				EXIT
		ENDCASE
	ENDSCAN
ELSE
	IF INLIST(lp_cLabel, "DAYUSE", "COMPLIM")
		l_lRetVal = NOT l_lRetVal
	ENDIF
ENDIF
GO l_nHRecno IN histres
GO l_nRecno IN reservat
GO l_nRecnoRT IN roomtype
SELECT (l_nArea)
lp_lRetVal = l_lRetVal
RETURN lp_lRetVal
ENDFUNC
*
FUNCTION RiGetShareFirstReserId
LPARAMETERS lp_nShareid, lp_dDate
* Returns first reservation ID for specific room sharing and date.
LOCAL l_nReserId, l_nFirstReserId, l_oResCurrent, l_nSelect
l_nSelect = SELECT()
l_nReserId = 0
SELECT resrmshr
SCAN FOR sr_shareid = lp_nShareid
	IF SEEK(resrmshr.sr_rroomid,"resrooms","tag3")
		l_nReserId = resrooms.ri_reserid
		RiGetRoom(l_nReserId, lp_dDate, @l_oResCurrent)
	ELSE
		= SEEK(resrmshr.sr_rroomid,"hresroom","tag3")
		l_nReserId = hresroom.ri_reserid
		RiGetRoom(l_nReserId, lp_dDate, @l_oResCurrent, "hresroom")
	ENDIF
	IF EMPTY(l_nFirstReserId)
		l_nFirstReserId = l_nReserId
	ENDIF
	IF ISNULL(l_oResCurrent) OR l_oResCurrent.ri_rroomid <> resrmshr.sr_rroomid
		l_nReserId = l_nFirstReserId
	ELSE
		EXIT
	ENDIF
ENDSCAN
SELECT (l_nSelect)
RETURN l_nReserId
ENDFUNC
*
FUNCTION IsNonStandardRtGrShareInterval
LPARAMETERS lp_nReserid, lp_dDate, lp_cResRoomsAlias
LOCAL l_oReservationState, l_nRecnoRT, l_lRetVal

RiGetRoom(lp_nReserid, lp_dDate, @l_oReservationState, lp_cResRoomsAlias)
IF NOT ISNULL(l_oReservationState)
	l_nRecnoRT = RECNO("roomtype")
	= SEEK(l_oReservationState.ri_roomtyp,"roomtype","tag1")
	IF NOT INLIST(roomtype.rt_group, 1, 4)
		l_lRetVal = .T.
	ENDIF
	GO l_nRecnoRT IN roomtype
ENDIF

RETURN l_lRetVal
ENDFUNC
*
PROCEDURE RiLastOccupiedDate
LPARAMETERS lp_cRoomName, lp_dLastUsed
LOCAL l_cRoomNum, l_dSysDate, l_cRoomName
LOCAL ARRAY l_aResult(1)

lp_dLastUsed = {}
IF EMPTY(lp_cRoomName)
	RETURN lp_dLastUsed
ENDIF
l_dSysDate = sysdate()
l_cRoomName = PADR(ALLTRIM(lp_cRoomName),10)
l_cRoomNum = get_rm_roomnum(l_cRoomName)

* first try to find if room was occupied in roomplan
* room is considered als occupied also when this was only blocked (rp_status = 99)
* reservation departure date (rs_depdate) is not considered als last day when room was occupied
* rs_depdate - 1 is date when room was last time occupied by reservation

SELECT rp_roomnum, MAX(rp_date) AS rp_maxdate ;
		FROM roomplan ;
		LEFT JOIN reservat ON rp_reserid = rs_reserid ;
		WHERE rp_roomnum+DTOS(rp_date) = l_cRoomNum AND rp_date <= l_dSysDate AND rp_reserid > 0 AND rs_in <> " " ;
		GROUP BY rp_roomnum ;
		INTO ARRAY l_aResult
IF _TALLY > 0
	lp_dLastUsed = l_aResult(1,2)
ELSE
	* if not occupied in roomplan
	* check in hresroom
	SELECT ri_roomnum, MAX(ri_todate) FROM hresroom ;
			LEFT JOIN histres ON ri_reserid = hr_reserid ;
			WHERE ri_roomnum = l_cRoomNum AND hr_in <> " " ;
			GROUP BY ri_roomnum ;
			INTO ARRAY l_aResult
	IF _TALLY > 0
		lp_dLastUsed = l_aResult(1,2)
	ENDIF
ENDIF

RETURN lp_dLastUsed
ENDPROC
*
PROCEDURE RIIsRmFreeExtReser
LPARAMETERS lp_dFrom, lp_dTo, lp_cRoomNum, lp_cMessage, lp_nReserId
LOCAL l_nSelect, l_cSql, l_cCur, l_lIsFree, l_lBuffering
lp_cMessage = ""
l_lIsFree = .T.
IF NOT _screen.oglobal.oparam2.pa_wsrooms
     RETURN l_lIsFree
ENDIF

l_nSelect = SELECT()
l_lBuffering = (NOT EMPTY(lp_nReserId))
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT er_arrdate, er_depdate, er_company, er_lname, er_adults, er_childs, er_childs2, er_childs3, er_uniquid 
          FROM extreser <<IIF(l_lBuffering," WITH (BUFFERING = .T.) ","")>>
          WHERE er_arrdate <= <<SqlCnv(lp_dTo,.T.)>> AND er_depdate > <<SqlCnv(lp_dFrom,.T.)>> AND 
          er_roomnum = <<SqlCnv(lp_cRoomNum,.T.)>> AND er_status <> 'CXL' AND er_status <> 'LST' AND NOT er_done 
          <<IIF(NOT EMPTY(lp_nReserId)," AND er_reserid <> " + sqlcnv(lp_nReserId,.T.),"")>>
          ORDER BY 1
ENDTEXT
IF l_lBuffering
     l_cCur = SYS(2015)
     l_cSql = l_cSql + " INTO CURSOR " + l_cCur
     &l_cSql
ELSE
     l_cCur = SqlCursor(l_cSql)
ENDIF 
l_lIsFree = (RECCOUNT(l_cCur) = 0)
IF NOT l_lIsFree
     lp_cMessage = GetLangText("RESERVAT","TXT_EXTRESER_NOTFREE")+";"+ ;
                   GetLangText("RESERVAT","TXT_BOOKING_ID")+": "+ALLTRIM(er_uniquid)+";"+;
                   IIF(EMPTY(er_company),"",PROPER(TRIM(er_company))+"/")+PROPER(TRIM(er_lname))+";"+ ;
                   DTOC(er_arrdate)+" "+DTOC(er_depdate)+" ("+LTRIM(STR(er_adults+er_childs+er_childs2+er_childs3))+")!"
ENDIF
dclose(l_cCur)
SELECT (l_nSelect)
RETURN l_lIsFree
ENDPROC
*