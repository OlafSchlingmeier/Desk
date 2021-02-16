*
#INCLUDE "common\progs\cryptor.h"
*
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
PROCEDURE RrRebuild
LPARAMETERS lp_lInitialRebuild, lp_lHistory, lp_lFixInvalid
LOCAL l_oOldRes, l_oNewRes, l_oOldHRes, l_oNewHRes, l_cResAlias, l_cOrder
LOCAL l_lResfixClose, l_lResraterebuild, l_lFound, l_lConfirmed, l_cForClause
LOCAL ARRAY l_aTasks(1,2)

l_aTasks(1,2) = GetLangText("MENU","MNT_RESRATERBLD")+"..."
l_cResAlias = "reservat"
IF lp_lInitialRebuild
	IF NOT YesNo(Str2Msg(GetLangText("RESERVAT","TXT_ERASERESRATE")))
		RETURN
	ENDIF
	USE IN resrate
	IF lp_lHistory
		IF FILE(gcDatadir+"hrateper.dbf")
			ProcCryptor(CR_REGISTER, gcDatadir, "hrateper")
			openfiledirect(.F., "hrateper")
		ENDIF
		IF USED("resfix")
			USE IN resfix
		ELSE
			l_lResfixClose = .T.
		ENDIF
		openfiledirect(.F., "hresfix", "resfix")
		USE IN hresrate
		openfiledirect(.T., "hresrate")
		ZAP IN hresrate
		USE IN hresrate
		openfiledirect(.F., "hresrate")
		SET ORDER TO Tag2 IN hresrate
		openfiledirect(.F., "hresrate", "resrate")
		l_aTasks(1,2) = GetLangText("MENU","MNT_HRESRATERBLD")+"..."
		l_cResAlias = "histres"
		l_cForClause = "(histres.hr_reserid >= 1) AND NOT EMPTY(histres.hr_arrdate) AND " + ;
			"NOT EMPTY(histres.hr_depdate) AND NOT EMPTY(histres.hr_roomtyp) AND NOT EMPTY(histres.hr_ratecod)"
		******************** Prepare SQLs for archive ******************************************************
		*
		ProcArchive("RestoreArchive", "histres", "SELECT histres.* FROM histres WHERE hr_reserid >= 1")
		*
		****************************************************************************************************
	ELSE
		IF NOT USED("resfix")
			openfiledirect(.F., "resfix")
			l_lResfixClose = .T.
		ENDIF
		dclose("ResrateOld")
		openfiledirect(.T., "resrate")
		ZAP IN resrate
		USE IN resrate
		openfiledirect(.F., "resrate")
		l_cForClause = "(reservat.rs_reserid >= 1) AND NOT EMPTY(reservat.rs_arrdate) AND " + ;
			"NOT EMPTY(reservat.rs_depdate) AND NOT EMPTY(reservat.rs_roomtyp) AND NOT EMPTY(reservat.rs_ratecod)"
	ENDIF
	SET ORDER TO Tag2 IN resrate
	PRIVATE p_resraterebuild
	p_resraterebuild = .T.
	IF FILE(gcDatadir+"rateperi.dbf")
		ProcCryptor(CR_REGISTER, gcDatadir, "rateperi")
		openfiledirect(.F., "rateperi")
	ENDIF
ELSE
	IF NOT USED("resfix")
		openfiledirect(.F., "resfix")
		l_lResfixClose = .T.
	ENDIF
	l_cForClause = "(reservat.rs_reserid >= 1) AND NOT EMPTY(reservat.rs_arrdate) AND NOT EMPTY(reservat.rs_depdate) " + ;
		"AND NOT EMPTY(reservat.rs_roomtyp) AND NOT EMPTY(reservat.rs_ratecod) AND NOT INLIST(reservat.rs_status, 'NS', 'CXL')"
ENDIF
SELECT reservat
SCATTER NAME l_oOldRes MEMO BLANK
SCATTER NAME l_oNewRes MEMO BLANK
SELECT &l_cResAlias
l_aTasks(1,1) = RECCOUNT()
DO FORM forms\progressbar NAME ProgressBar WITH GetLangText("MENU","MNT_RESRATERBLD"), l_aTasks
l_cOrder = ORDER()
ON KEY LABEL ALT+Q GO BOTTOM IN &l_cResAlias
SET ORDER TO
SCAN FOR &l_cForClause
	ProgressBar.Update(RECNO())
	IF NOT lp_lInitialRebuild AND NOT lp_lFixInvalid
		l_lFound = RatecodeLocate(MIN(&l_cResAlias..rs_depdate, MAX(g_sysdate, &l_cResAlias..rs_arrdate)), ;
			&l_cResAlias..rs_ratecod, &l_cResAlias..rs_roomtyp, &l_cResAlias..rs_arrdate, {}, .F., .T.)
		l_lResraterebuild = NOT l_lFound OR (&l_cResAlias..rs_updated < ratecode.rc_updated)
		IF l_lResraterebuild AND NOT l_lConfirmed
			l_lConfirmed = .T.
			IF NOT YesNo(GetLangText("RESERVAT","TXT_UPDATERESRATE"))
				EXIT
			ENDIF
		ENDIF
	ELSE
		l_lResraterebuild = .T.
	ENDIF
	IF l_lResraterebuild
		IF lp_lHistory
			IF SEEK(&l_cResAlias..hr_reserid,"reservat","Tag1")
				LOOP
			ENDIF
			SCATTER NAME l_oOldHRes MEMO
			SCATTER NAME l_oNewHRes MEMO
			RrHistToRes(l_oOldHRes, l_oNewHRes, l_oOldRes, l_oNewRes)
			IF USED("rateperi") AND USED("hrateper")
				AppendFrom("hrateper","ri_reserid = " + SqlCnv(l_oNewRes.rs_reserid), "rateperi")
			ENDIF
		ELSE
			SCATTER NAME l_oOldRes MEMO
			SCATTER NAME l_oNewRes MEMO
		ENDIF
		RrUpdate(l_oOldRes, l_oNewRes, .T.)
		IF lp_lHistory
			IF USED("rateperi")
				DELETE FOR ri_reserid = l_oNewRes.rs_reserid IN rateperi
			ENDIF
		ELSE
			REPLACE rs_updated WITH g_sysdate IN &l_cResAlias
			REPLACE rs_changes WITH rsHistry(&l_cResAlias..rs_changes, "RES.RATE REBUILD",IIF(l_lConfirmed, "Check", "Automatic")) IN &l_cResAlias
		ENDIF
	ENDIF
ENDSCAN
SET ORDER TO l_cOrder
******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
ProgressBar.Complete()
IF lp_lHistory
	USE IN resrate
	openfiledirect(.F., "resrate")
	SET ORDER TO Tag2 IN resrate
ENDIF
IF l_lResfixClose
	USE IN resfix
ELSE
	IF lp_lHistory
		USE IN resfix
		openfiledirect(.F., "resfix")
		SET ORDER TO Tag1 IN resfix
	ENDIF
ENDIF
IF USED("rateperi")
	USE IN rateperi
	ProcCryptor(CR_UNREGISTER, gcDatadir, "rateperi")
ENDIF
IF USED("hrateper")
	USE IN hrateper
	ProcCryptor(CR_UNREGISTER, gcDatadir, "hrateper")
ENDIF
ENDPROC
*
PROCEDURE RrUpdate
* lp_lUseReservat - When .T., take data from reservat table, and update those records in resrate table,
* which have rr_status = "OK"
LPARAMETERS lp_oOldRes, lp_oNewRes, lp_lForceUpdate, lp_dFromDate, lp_dToDate, lp_lUseReservat
LOCAL i, l_nArea, l_lResrateRebuild, l_lNewResrate, l_dDate, l_cRatecode, l_cRoomtype, l_nRate, l_nAdults, l_nChilds, l_nChilds2, l_nChilds3
LOCAL l_oResrooms, l_dRcStartDate, l_dRcEndDate, l_dFromDate, l_dToDate
LOCAL l_CloseResfix, l_CloseBanquet, l_ClosePickList, l_ClosePaymetho, l_lCloseRatecode, l_lCloseArticle, l_lCloseRatearti
LOCAL l_CloseAlthead, l_CloseAltsplit, l_lCloseResrateOld, l_lCloseResroomsOld, l_lCloseResrooms, l_lCloseResSplit, l_lCloseResRart
LOCAL l_dBetweenToDate, l_nArrTime, l_nDepTime

l_nArea = SELECT()

l_cRoomtype = lp_oNewRes.rs_roomtyp
l_cRatecode = lp_oNewRes.rs_ratecod
l_nRate = lp_oNewRes.rs_rate
l_nAdults = lp_oNewRes.rs_adults
l_nChilds = lp_oNewRes.rs_childs
l_nChilds2 = lp_oNewRes.rs_childs2
l_nChilds3 = lp_oNewRes.rs_childs3
l_nArrTime = lp_oNewRes.rs_arrtime
l_nDepTime = lp_oNewRes.rs_deptime

l_lCloseResrateOld = RrOpenAlias("resrate", "ResrateOld")
l_lCloseResroomsOld = RrOpenAlias("resrooms", "ResroomsOld")
l_lCloseResrooms = RrOpenAlias("resrooms")
l_lCloseResSplit = RrOpenAlias("ressplit")
l_CloseAlthead = RrOpenAlias("althead")
l_CloseAltsplit = RrOpenAlias("altsplit")
l_CloseResfix = RrOpenAlias("resfix")
l_CloseBanquet = RrOpenAlias("banquet")
l_ClosePickList = RrOpenAlias("picklist")
l_ClosePaymetho = RrOpenAlias("paymetho")
l_lCloseRatecode = RrOpenAlias("ratecode")
l_lCloseArticle = RrOpenAlias("article")
l_lCloseRatearti = RrOpenAlias("ratearti")
l_lCloseResRart = RrOpenAlias("resrart")

IF RrRatecodeIncl(lp_oNewRes.rs_rsid, lp_oNewRes.rs_ratecod, lp_oNewRes.rs_rate, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_roomtyp)
	IF NOT SEEK(STR(lp_oNewRes.rs_reserid,12,3),"resrate","Tag2") OR ;
			(resrate.rr_date <> lp_oNewRes.rs_arrdate) OR ; && Rebuild rates for all days because arrival date has been changed.
			(ratecode.rc_period = 6 AND lp_oOldRes.rs_depdate <> lp_oNewRes.rs_depdate) ;
			OR NOT SEEK(lp_oNewRes.rs_rsid,"ressplit","Tag1")
		lp_lForceUpdate = .T.
	ENDIF
	l_dBetweenToDate = MAX(lp_oNewRes.rs_arrdate, RrGetRsDepDate(lp_oNewRes), lp_oNewRes.rs_ratedat)
	DELETE FOR (rr_reserid = lp_oNewRes.rs_reserid) AND NOT BETWEEN(rr_date,  lp_oNewRes.rs_arrdate, l_dBetweenToDate) IN resrate
	DELETE FOR (rl_rsid = lp_oNewRes.rs_rsid)       AND NOT BETWEEN(rl_rdate, lp_oNewRes.rs_arrdate, l_dBetweenToDate) IN ressplit
	SELECT 0=1 AS upd, rr_ratecod AS c_newrc, * FROM resrate WITH (Buffering = .T.) WHERE rr_reserid = lp_oNewRes.rs_reserid ORDER BY rr_date INTO CURSOR ResrateCurrent READWRITE
	INDEX ON rr_date TAG rr_date
	IF EMPTY(lp_dFromDate) AND EMPTY(lp_dToDate)
		lp_dFromDate = lp_oNewRes.rs_arrdate
		lp_dToDate = RrGetLastDate(lp_oNewRes)
		l_dFromDate = lp_dFromDate
		l_dToDate = lp_dToDate
	ELSE
		l_dFromDate = lp_dFromDate
		l_dToDate = lp_dToDate
		IF SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(lp_dFromDate), "resrate", "Tag2") AND SEEK(resrate.rr_ratecod,"ratecode","Tag1") AND ratecode.rc_period > 3
			RrRatecodeInterval(lp_oNewRes.rs_reserid, lp_dFromDate, @l_dRcStartDate, @l_dRcEndDate)
			RrRatecodeFirstLastDay(lp_dFromDate, l_dRcStartDate, l_dRcEndDate, @lp_dFromDate)
		ENDIF
		IF SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(lp_dToDate), "resrate", "Tag2") AND SEEK(resrate.rr_ratecod,"ratecode","Tag1") AND ratecode.rc_period > 3
			STORE {} TO l_dRcStartDate, l_dRcEndDate
			RrRatecodeInterval(lp_oNewRes.rs_reserid, lp_dToDate, @l_dRcStartDate, @l_dRcEndDate)
			RrRatecodeFirstLastDay(lp_dFromDate, l_dRcStartDate, l_dRcEndDate,,@lp_dToDate)
		ENDIF
	ENDIF
	IF lp_lForceUpdate
		DELETE FOR (rl_rsid = lp_oNewRes.rs_rsid) AND BETWEEN(rl_rdate, lp_dFromDate, lp_dToDate) IN ressplit
	ENDIF
	l_dDate = lp_dFromDate
	l_lResrateRebuild = TYPE("p_resraterebuild") <> "U" AND p_resraterebuild
	l_lNewResrate = TYPE("p_oRates") = "O"
	IF l_lResrateRebuild
		l_dDate = lp_oNewRes.rs_arrdate
	ENDIF
	RiGetRoom(lp_oOldRes.rs_reserid, l_dDate, @l_oResrooms, .NULL., "ResroomsOld")
	IF NOT ISNULL(l_oResrooms)
		lp_oOldRes.rs_roomtyp = l_oResrooms.ri_roomtyp
	ENDIF
	RiGetRoom(lp_oNewRes.rs_reserid, l_dDate, @l_oResrooms)
	IF NOT ISNULL(l_oResrooms)
		lp_oNewRes.rs_roomtyp = l_oResrooms.ri_roomtyp
	ENDIF
	STORE {} TO l_dRcStartDate, l_dRcEndDate
	DO WHILE l_dDate <= lp_dToDate
		RrDayReset(l_dDate, lp_oOldRes, lp_oNewRes, l_lResrateRebuild OR BETWEEN(l_dDate, l_dFromDate, l_dToDate) AND l_lNewResrate, ;
			lp_lForceUpdate, lp_lUseReservat, l_cRatecode, l_nRate, l_nAdults, l_nChilds, l_nChilds2, l_nChilds3, l_nArrTime, l_nDepTime)
		l_dDate = l_dDate + 1
	ENDDO
	SELECT ResrateCurrent
	SCAN FOR upd
		IF NOT SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(ResrateCurrent.rr_date), "resrate", "Tag2")
			INSERT INTO resrate (rr_rrid, rr_reserid, rr_date, rr_status) VALUES (NextId("RESRATE"), lp_oNewRes.rs_reserid, ResrateCurrent.rr_date, "X")
		ENDIF
		REPLACE rr_ratecod WITH ResrateCurrent.rr_ratecod IN resrate
	ENDSCAN
	RaUpdate(lp_oNewRes)
	SELECT ResrateCurrent
	SCAN FOR upd AND SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(rr_date), "resrate", "Tag2")
		lp_oNewRes.rs_rate = rr_raterc
		lp_oNewRes.rs_ratecod = ALLTRIM(LEFT(resrate.rr_ratecod,;
				ICASE("!" $ resrate.rr_ratecod AND "*" $ resrate.rr_ratecod,12,"!" $ resrate.rr_ratecod OR "*" $ resrate.rr_ratecod,11,10);
				))
		lp_oNewRes.rs_adults = rr_adults
		lp_oNewRes.rs_childs = rr_childs
		lp_oNewRes.rs_childs2 = rr_childs2
		lp_oNewRes.rs_childs3 = rr_childs3
		lp_oNewRes.rs_arrtime = rr_arrtime
		lp_oNewRes.rs_deptime = rr_deptime
		IF SEEK(STR(resrate.rr_reserid,12,3)+DTOS(resrate.rr_date),"ResroomsOld","Tag2")
			lp_oOldRes.rs_roomtyp = ResroomsOld.ri_roomtyp
		ENDIF
		IF SEEK(STR(resrate.rr_reserid,12,3)+DTOS(resrate.rr_date),"resrooms","Tag2")
			lp_oNewRes.rs_roomtyp = resrooms.ri_roomtyp
		ENDIF
		RlDeleteDummy(rr_date, lp_oNewRes)
		FOR i = 1 TO 3
			RrDayUpdate(rr_date, lp_oOldRes, lp_oNewRes, lp_lForceUpdate)
			IF resrate.rr_status <> "X"
				EXIT
			ENDIF
		NEXT
	ENDSCAN
	DClose("ResrateCurrent")
ELSE
	DELETE FOR rr_reserid = lp_oNewRes.rs_reserid IN resrate
	DELETE FOR rl_rsid = lp_oNewRes.rs_rsid IN ressplit
ENDIF

RrCloseAlias("resfix", l_CloseResfix)
RrCloseAlias("banquet", l_CloseBanquet)
RrCloseAlias("paymetho", l_ClosePaymetho)
RrCloseAlias("picklist", l_ClosePickList)
RrCloseAlias("ratearti", l_lCloseRatearti)
RrCloseAlias("resrart", l_lCloseResRart)
RrCloseAlias("ratecode", l_lCloseRatecode)
RrCloseAlias("article", l_lCloseArticle)
RrCloseAlias("ressplit", l_lCloseResSplit)
RrCloseAlias("ResrateOld", l_lCloseResrateOld)
RrCloseAlias("resrooms", l_lCloseResrooms)
RrCloseAlias("ResroomsOld", l_lCloseResroomsOld)
RrCloseAlias("althead", l_CloseAlthead)
RrCloseAlias("altsplit", l_CloseAltsplit)

lp_oNewRes.rs_roomtyp = l_cRoomtype
lp_oNewRes.rs_ratecod = l_cRatecode
lp_oNewRes.rs_rate = l_nRate
lp_oNewRes.rs_adults = l_nAdults
lp_oNewRes.rs_childs = l_nChilds
lp_oNewRes.rs_childs2 = l_nChilds2
lp_oNewRes.rs_childs3 = l_nChilds3
lp_oNewRes.rs_arrtime = l_nArrTime
lp_oNewRes.rs_deptime = l_nDepTime

SELECT (l_nArea)
ENDPROC
*
PROCEDURE RaUpdate
LPARAMETERS lp_oNewRes
LOCAL l_curOldRA, l_curNewRA, l_curAddRa

IF SEEK(lp_oNewRes.rs_rsid,"resrart","tag3")
	l_curOldRA = SYS(2015)
	l_curNewRA = SYS(2015)
	l_curAddRa = SYS(2015)
	SELECT DISTINCT ra_ratecod, ra_rcsetid FROM resrart WITH (BUFFERING = .T.) ;
		WHERE ra_rsid = lp_oNewRes.rs_rsid ;
		INTO CURSOR &l_curOldRA READWRITE
	INDEX ON ra_rcsetid TAG ra_rcsetid
	INDEX ON ra_ratecod TAG ra_ratecod

	SELECT DISTINCT c_newrc, rc_rcsetid FROM ResrateCurrent ;
		INNER JOIN ratecode ON rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season = c_newrc ;
		INTO CURSOR &l_curNewRA READWRITE
	INDEX ON c_newrc TAG c_newrc

	SCAN FOR NOT SEEK(c_newrc, l_curOldRA, "ra_ratecod") AND SEEK(rc_rcsetid, l_curOldRA, "ra_rcsetid")
		SELECT * FROM resrart WHERE ra_rsid = lp_oNewRes.rs_rsid AND ra_ratecod = &l_curOldRA..ra_ratecod INTO CURSOR &l_curAddRa READWRITE
		REPLACE ra_ratecod WITH &l_curNewRA..c_newrc ALL
		SELECT resrart
		APPEND FROM DBF(l_curAddRa)
		SELECT &l_curNewRA
	ENDSCAN
	SELECT &l_curOldRA
	SCAN FOR NOT SEEK(ra_ratecod, l_curNewRA, "c_newrc")
		DELETE FOR ra_rsid = lp_oNewRes.rs_rsid AND ra_ratecod = &l_curOldRA..ra_ratecod IN resrart
	ENDSCAN
	DClose(l_curOldRA)
	DClose(l_curNewRA)
	DClose(l_curAddRa)
ENDIF
ENDPROC
*
PROCEDURE RrDayReset
LPARAMETERS lp_dDate, lp_oOldRes, lp_oNewRes, lp_lResrateRebuild, lp_lForceUpdate, lp_lUseReservat, lp_cRatecode, lp_nRate, lp_nAdults, lp_nChilds, lp_nChilds2, lp_nChilds3, lp_nArrTime, lp_nDepTime
LOCAL l_lRaUpdate, l_oResrooms, l_cRatecode

l_lRaUpdate = SEEK(lp_oNewRes.rs_rsid,"resrart","tag3")
DO CASE
	CASE lp_lResrateRebuild
		DO CASE
			CASE TYPE("p_oRates") = "O"	&& Changing data in rates form
				lp_oNewRes.rs_ratecod = p_oRates.rs_ratecod
				lp_oNewRes.rs_rate = p_oRates.rs_rate
				lp_oNewRes.rs_adults = p_oRates.rs_adults
				lp_oNewRes.rs_childs = p_oRates.rs_childs
				lp_oNewRes.rs_childs2 = p_oRates.rs_childs2
				lp_oNewRes.rs_childs3 = p_oRates.rs_childs3
				lp_oNewRes.rs_arrtime = p_oRates.rs_arrtime
				lp_oNewRes.rs_deptime = p_oRates.rs_deptime
			CASE USED("rateperi") AND SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(lp_dDate),"rateperi","tag3") AND rateperi.ri_state = 0
				lp_oNewRes.rs_ratecod = rateperi.ri_ratecod
				lp_oNewRes.rs_rate = rateperi.ri_rate
				lp_oNewRes.rs_adults = rateperi.ri_adults
				lp_oNewRes.rs_childs = rateperi.ri_childs
				lp_oNewRes.rs_childs2 = rateperi.ri_childs2
				lp_oNewRes.rs_childs3 = rateperi.ri_childs3
		ENDCASE
	CASE SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(lp_dDate),"resrate","tag2") AND ;
			IIF(lp_lUseReservat, LEFT(resrate.rr_status,2) = "OR" AND lp_dDate <> MAX(lp_oNewRes.rs_arrdate, SysDate()), resrate.rr_status # "X")
		IF l_lRaUpdate
			RiGetRoom(lp_oNewRes.rs_reserid, lp_dDate, @l_oResrooms)
			IF NOT ISNULL(l_oResrooms)
				lp_oNewRes.rs_roomtyp = l_oResrooms.ri_roomtyp
			ENDIF
		ENDIF
		lp_oNewRes.rs_ratecod = ICASE(INLIST(resrate.rr_status, "OAL", "ORA"), "!", INLIST(resrate.rr_status, "OUS", "ORU", "OFF"), "*", "") + ;
			ALLTRIM(LEFT(CHRTRAN(LEFT(resrate.rr_ratecod,11), "*!", ""),10))
		lp_oNewRes.rs_rate = RrDayPrice(lp_oNewRes, lp_dDate)
		lp_oNewRes.rs_adults = resrate.rr_adults
		lp_oNewRes.rs_childs = resrate.rr_childs
		lp_oNewRes.rs_childs2 = resrate.rr_childs2
		lp_oNewRes.rs_childs3 = resrate.rr_childs3
		lp_oNewRes.rs_arrtime = resrate.rr_arrtime
		lp_oNewRes.rs_deptime = resrate.rr_deptime
	OTHERWISE
		lp_oNewRes.rs_ratecod = lp_cRatecode
		lp_oNewRes.rs_rate = lp_nRate
		lp_oNewRes.rs_adults = lp_nAdults
		lp_oNewRes.rs_childs = lp_nChilds
		lp_oNewRes.rs_childs2 = lp_nChilds2
		lp_oNewRes.rs_childs3 = lp_nChilds3
		lp_oNewRes.rs_arrtime = lp_nArrtime
		lp_oNewRes.rs_deptime = lp_nDeptime
ENDCASE

DO WHILE .T.
	IF NOT SEEK(lp_dDate,"ResrateCurrent","rr_date")
		INSERT INTO ResrateCurrent (rr_date) VALUES (lp_dDate)
		EXIT
	ENDIF

	IF lp_lForceUpdate
		EXIT
	ENDIF
	IF ResrateCurrent.rr_status = "X"						&& Invalid rate
		EXIT
	ENDIF
	IF NOT SEEK(ResrateCurrent.rr_ratecod,"ratecode","Tag1")	&& Ratecode not found
		EXIT
	ENDIF
	IF NOT INLIST(SUBSTR(ResrateCurrent.rr_ratecod,11,4), "*", lp_oNewRes.rs_roomtyp)			&& Roomtype changed
		EXIT
	ENDIF
	IF NOT PADR(CHRTRAN(lp_oNewRes.rs_ratecod, "*!", ""),10) == PADR(ResrateCurrent.rr_ratecod,10)	&& Ratecode changed
		EXIT
	ENDIF
	IF NOT INLIST(LEFT(lp_oNewRes.rs_ratecod,1), "*", "!") AND NOT INLIST(ResrateCurrent.rr_status, "OK", "ORI")
		EXIT
	ENDIF
	IF LEFT(lp_oNewRes.rs_ratecod,1) = "*" AND NOT INLIST(ResrateCurrent.rr_status, "OUS", "ORU", "OFF")
		EXIT
	ENDIF
	IF LEFT(lp_oNewRes.rs_ratecod,1) = "!" AND NOT INLIST(ResrateCurrent.rr_status, "OAL", "ORA")
		EXIT
	ENDIF
	IF lp_oNewRes.rs_adults <> ResrateCurrent.rr_adults		&& Adults changed
		EXIT
	ENDIF
	IF lp_oNewRes.rs_childs <> ResrateCurrent.rr_childs		&& Children 1 changed
		EXIT
	ENDIF
	IF lp_oNewRes.rs_childs2 <> ResrateCurrent.rr_childs2		&& Children 2 changed
		EXIT
	ENDIF
	IF lp_oNewRes.rs_childs3 <> ResrateCurrent.rr_childs3		&& Children 3 changed
		EXIT
	ENDIF
	IF lp_oNewRes.rs_arrtime <> ResrateCurrent.rr_arrtime		&& Arrtime changed
		EXIT
	ENDIF
	IF lp_oNewRes.rs_deptime <> ResrateCurrent.rr_deptime		&& Deptime changed
		EXIT
	ENDIF
	IF lp_oNewRes.rs_rate <> RrDayPrice(lp_oNewRes, lp_dDate)	&& UD rate changed
		EXIT
	ENDIF
	IF NOT EMPTY(lp_oNewRes.rs_yoid) AND NOT (SEEK(lp_oNewRes.rs_yoid, "yioffer", "tag1") AND yioffer.yo_rooms = lp_oNewRes.rs_rooms)	&& Offered rooms changed
		EXIT
	ENDIF
	IF NOT lp_oNewRes.rs_discnt == lp_oOldRes.rs_discnt		&& Discount changed
		EXIT
	ENDIF

	RETURN
ENDDO

REPLACE upd WITH .T., ;
	rr_adults WITH lp_oNewRes.rs_adults, ;
	rr_childs WITH lp_oNewRes.rs_childs, ;
	rr_childs2 WITH lp_oNewRes.rs_childs2, ;
	rr_childs3 WITH lp_oNewRes.rs_childs3, ;
	rr_arrtime WITH lp_oNewRes.rs_arrtime, ;
	rr_deptime WITH lp_oNewRes.rs_deptime, ;
	rr_ratecod WITH lp_oNewRes.rs_ratecod, ;
	rr_raterc WITH lp_oNewRes.rs_rate IN ResrateCurrent
IF l_lRaUpdate AND RatecodeLocate(lp_dDate, lp_oNewRes.rs_ratecod, lp_oNewRes.rs_roomtyp, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_depdate)
	REPLACE c_newrc WITH ratecode.rc_key IN ResrateCurrent
ENDIF
ENDPROC
*
PROCEDURE RrDayUpdate
LPARAMETERS lp_dDate, lp_oOldRes, lp_oNewRes, lp_lForceUpdate
LOCAL l_nArea, l_oResRate, l_cRatecode, l_lLeaveValid, l_lLeaveOffered, l_dPostDate, l_dFromDate, l_dToDate, l_dFirstDate, l_dLastDate
PRIVATE p_dPostDate
p_dPostDate = lp_dDate

l_nArea = SELECT()
IF resrate.rr_status = "X" OR lp_dDate > lp_oNewRes.rs_ratedat OR lp_lForceUpdate
	l_lLeaveValid = BETWEEN(lp_dDate, lp_oOldRes.rs_arrdate, MAX(lp_oOldRes.rs_arrdate,lp_oOldRes.rs_depdate-1)) AND ;
		CHRTRAN(lp_oOldRes.rs_ratecod,"*!", "") = CHRTRAN(lp_oNewRes.rs_ratecod,"*!", "") AND lp_oOldRes.rs_roomtyp = lp_oNewRes.rs_roomtyp

	DO CASE
		CASE EMPTY(lp_oNewRes.rs_yoid) OR LEFT(resrate.rr_status, 2) = "OR"
		CASE DLocate("resyield", "ry_yoid = " + SqlCnv(lp_oNewRes.rs_yoid) + " AND ry_date = " + SqlCnv(lp_dDate))
			lp_oNewRes.rs_ratecod = "*" + CHRTRAN(lp_oNewRes.rs_ratecod,"*!", "")
		OTHERWISE
			lp_oNewRes.rs_ratecod = STRTRAN(lp_oNewRes.rs_ratecod,"*")
	ENDCASE

	l_lLeaveOffered = resrate.rr_status <> "X" AND lp_oOldRes.rs_roomtyp = lp_oNewRes.rs_roomtyp AND ;
		lp_oOldRes.rs_arrdate = lp_oNewRes.rs_arrdate AND lp_oOldRes.rs_depdate = lp_oNewRes.rs_depdate AND ;
		CHRTRAN(lp_oOldRes.rs_ratecod, "*!", "") = CHRTRAN(lp_oNewRes.rs_ratecod, "*!", "") AND ;
		lp_oOldRes.rs_adults = lp_oNewRes.rs_adults AND lp_oOldRes.rs_childs = lp_oNewRes.rs_childs AND ;
		lp_oOldRes.rs_childs2 = lp_oNewRes.rs_childs2 AND lp_oOldRes.rs_childs3 = lp_oNewRes.rs_childs3

	l_cRatecode = IIF(l_lLeaveOffered AND LEFT(lp_oNewRes.rs_ratecod,1) <> "!", "*" + CHRTRAN(lp_oNewRes.rs_ratecod,"*!", ""), lp_oNewRes.rs_ratecod)

	lp_oNewRes.rs_rate = RateCodeEval(lp_dDate, l_cRatecode, lp_oNewRes.rs_rate, lp_oNewRes.rs_roomtyp, lp_oNewRes.rs_altid, ;
		lp_oNewRes.rs_adults, lp_oNewRes.rs_childs, lp_oNewRes.rs_childs2, lp_oNewRes.rs_childs3, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_depdate, ;
		lp_oNewRes.rs_arrtime, lp_oNewRes.rs_deptime, l_lLeaveValid, .T., .T.)
	RrRatecodeInterval(lp_oNewRes, lp_dDate, @l_dFromDate, @l_dToDate)
	RrRatecodeFirstLastDay(lp_dDate, l_dFromDate, l_dToDate, @l_dFirstDate, @l_dLastDate)
	l_dPostDate = RRGetPostDate(lp_dDate, l_dFromDate, l_dToDate, l_dFirstDate, l_dLastDate)
	IF lp_dDate <> l_dPostDate
		lp_oNewRes.rs_rate = RateCodeEval(l_dPostDate, l_cRatecode, lp_oNewRes.rs_rate, lp_oNewRes.rs_roomtyp, lp_oNewRes.rs_altid, ;
			lp_oNewRes.rs_adults, lp_oNewRes.rs_childs, lp_oNewRes.rs_childs2, lp_oNewRes.rs_childs3, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_depdate, ;
			lp_oNewRes.rs_arrtime, lp_oNewRes.rs_deptime, l_lLeaveValid, .T., .T.)
	ENDIF
ENDIF

SELECT resrate
SCATTER NAME l_oResRate
IF LEFT(lp_oNewRes.rs_ratecod,1) = "*" AND lp_oNewRes.rs_rate >= 0 AND NOT EMPTY(lp_oNewRes.rs_yoid) AND ;
		DLocate("resyield", "ry_yoid = " + SqlCnv(lp_oNewRes.rs_yoid) + " AND ry_date = " + SqlCnv(l_oResRate.rr_date)) AND ;
		DLocate("yioffer", "yo_yoid = " + SqlCnv(lp_oNewRes.rs_yoid))
	l_oResRate.rr_adults = yioffer.yo_adults
	l_oResRate.rr_childs = yioffer.yo_childs
	l_oResRate.rr_childs2 = yioffer.yo_childs2
	l_oResRate.rr_childs3 = yioffer.yo_childs3
	lp_oNewRes.rs_rate = resyield.ry_rate
ELSE
	l_oResRate.rr_adults = lp_oNewRes.rs_adults
	l_oResRate.rr_childs = lp_oNewRes.rs_childs
	l_oResRate.rr_childs2 = lp_oNewRes.rs_childs2
	l_oResRate.rr_childs3 = lp_oNewRes.rs_childs3
	l_oResRate.rr_arrtime = lp_oNewRes.rs_arrtime
	l_oResRate.rr_deptime = lp_oNewRes.rs_deptime
ENDIF
DO CASE
	CASE l_oResRate.rr_status <> "X"
	CASE TYPE("p_resraterebuild") = "U" OR NOT p_resraterebuild
	CASE NOT (USED("rateperi") AND SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(lp_dDate),"rateperi","tag3") AND rateperi.ri_state = 0)
	CASE LEFT(rateperi.ri_ratecod,1) = "*"
		l_oResRate.rr_status = "ORU"
	CASE LEFT(rateperi.ri_ratecod,1) = "!"
		l_oResRate.rr_status = "ORA"
	OTHERWISE
		l_oResRate.rr_status = "ORI"
ENDCASE

IF l_oResRate.rr_status = "X" OR lp_dDate > lp_oNewRes.rs_ratedat OR lp_lForceUpdate
	IF ratecode.rc_period = 7
		RrRatecodeFirstLastDay(l_dToDate - ratecode.rc_prcdur + 1, l_dFromDate, l_dToDate,,@l_dToDate)
		IF lp_dDate > l_dToDate AND lp_oNewRes.rs_rate >= 0
			lp_oNewRes.rs_rate = -1
		ENDIF
	ENDIF
	DO CASE
		CASE lp_oNewRes.rs_rate < 0
			l_oResRate.rr_status = "X"
		CASE LEFT(lp_oNewRes.rs_ratecod,1) = "*" && changed rate by user
			l_oResRate.rr_status = IIF(LEFT(l_oResRate.rr_status, 2) = "OR", "ORU", "OUS")
		CASE LEFT(lp_oNewRes.rs_ratecod,1) = "!" AND SEEK(lp_oNewRes.rs_altid,"althead","tag1") AND ;
				(SEEK(PADR(althead.al_altid,8)+DTOS(lp_dDate)+lp_oNewRes.rs_roomtyp+STRTRAN(lp_oNewRes.rs_ratecod, "!"),"altsplit","tag2") OR ;
				SEEK(PADR(althead.al_altid,8)+DTOS(lp_dDate)+"*   "+STRTRAN(lp_oNewRes.rs_ratecod, "!"),"altsplit","tag2"))
			l_oResRate.rr_status = IIF(LEFT(l_oResRate.rr_status, 2) = "OR", "ORA", "OAL")
		OTHERWISE
			l_oResRate.rr_status = IIF(LEFT(l_oResRate.rr_status, 2) = "OR", "ORI", "OK")
	ENDCASE
	l_oResRate.rr_raterc = 0
	l_oResRate.rr_rateex = 0
	l_oResRate.rr_ratepg = 0
	l_oResRate.rr_package = 0
	l_oResRate.rr_raterf = 0
	l_oResRate.rr_ratefrc = 0
	l_oResRate.rr_raterd = 0
	IF l_oResRate.rr_status = "X"
		l_oResRate.rr_ratecod = PADR(lp_oNewRes.rs_ratecod, 10)
	ELSE
		l_oResRate.rr_ratecod = ratecode.rc_key
		RrRateCoefficient(l_oResRate, lp_oNewRes)
		RrRatecodeRate(l_oResRate, lp_oNewRes, l_dFromDate, l_dToDate)
		RrResfixRate(l_oResRate, lp_oNewRes)
		RrBanquetRate(l_oResRate, lp_oNewRes)
	ENDIF
ENDIF
IF INLIST(l_oResRate.rr_status, "OUS", "ORU", "OFF") AND NOT EMPTY(lp_oNewRes.rs_yoid) AND ;
		DLocate("resyield", "ry_yoid = " + SqlCnv(lp_oNewRes.rs_yoid) + " AND ry_date = " + SqlCnv(lp_dDate)) AND ;
		l_oResRate.rr_ratecod = resyield.ry_ratecod AND lp_oNewRes.rs_rate = resyield.ry_rate AND ;
		DLocate("yioffer", "yo_yoid = " + SqlCnv(lp_oNewRes.rs_yoid)) AND lp_oNewRes.rs_rooms <= yioffer.yo_rooms
	l_oResRate.rr_status = "OFF"
ENDIF

SELECT resrate
GATHER NAME l_oResRate
GO RECNO("resrate") IN resrate

SELECT(l_nArea)
ENDPROC
*
FUNCTION RrPostIt
LPARAMETERS lp_dForDate, lp_dRcStartDate, lp_dRcEndDate, lp_dPostDate, lp_cRaAlias
LOCAL l_dFirstDate, l_dLastDate

lp_cRaAlias = EVL(lp_cRaAlias, "ratearti")
RrRatecodeFirstLastDay(lp_dForDate, lp_dRcStartDate, lp_dRcEndDate, @l_dFirstDate, @l_dLastDate)

DO CASE
	CASE &lp_cRaAlias..ra_onlyon = 999 OR ratecode.rc_period >= 6 AND (l_dFirstDate + &lp_cRaAlias..ra_onlyon - 1 > l_dLastDate)
		lp_dPostDate = IIF(ratecode.rc_period < 4, lp_dRcEndDate, l_dLastDate)
	CASE &lp_cRaAlias..ra_onlyon > 0
		lp_dPostDate = IIF(ratecode.rc_period < 4, lp_dRcStartDate, l_dFirstDate) + &lp_cRaAlias..ra_onlyon - 1
	CASE &lp_cRaAlias..ra_onlyon < 0
		lp_dPostDate = lp_dRcStartDate + FLOOR((lp_dForDate-lp_dRcStartDate+1) / (-&lp_cRaAlias..ra_onlyon)) * (-&lp_cRaAlias..ra_onlyon) - 1
	CASE INLIST(ratecode.rc_rhytm, 7, 8)
		lp_dPostDate = lp_dForDate
	OTHERWISE
		lp_dPostDate = RRGetPostDate(lp_dForDate, lp_dRcStartDate, lp_dRcEndDate, l_dFirstDate, l_dLastDate)
ENDCASE

RETURN (lp_dForDate = lp_dPostDate)
ENDFUNC
*
FUNCTION RRGetPostDate
* ratcode alias is expected to be open, and to be selected right record in table!
LPARAMETERS lp_dForDate, lp_dRcStartDate, lp_dRcEndDate, lp_dFirstDate, lp_dLastDate
LOCAL l_dPostDate

DO CASE
	CASE ratecode.rc_period = 4
		l_dPostDate = lp_dFirstDate
	CASE ratecode.rc_period = 5
		l_dPostDate = RRGetMonthPostDate(lp_dForDate, lp_dRcStartDate, lp_dRcEndDate)
	CASE INLIST(ratecode.rc_period, 6, 7) AND ratecode.rc_rhytm = 3
		l_dPostDate = lp_dFirstDate
	CASE INLIST(ratecode.rc_period, 6, 7)
		l_dPostDate = lp_dLastDate
	OTHERWISE
		l_dPostDate = lp_dForDate
ENDCASE

RETURN l_dPostDate
ENDFUNC
*
FUNCTION RrRatecodeRate
LPARAMETERS lp_oResRate, lp_oNewRes, lp_dRcStartDate, lp_dRcEndDate
LOCAL l_nArea, l_nOrdRa, l_nParts, l_nPrice, l_nRlPrice, l_nPeriods, l_nUnits, l_dFirstDate, l_dLastDate, l_lUdRate
LOCAL l_oRessplit, l_lOnlyMainDisc, l_lPostPackage, l_nRedirectReserId, l_cRaAlias, l_lCustomRA, l_cRaWhileClause, l_lPostIt, l_dCorrectionLastDate

l_nArea = SELECT()
l_lCustomRA = SEEK(STR(lp_oNewRes.rs_rsid,10)+lp_oResRate.rr_ratecod, "ResRart", "tag1")
l_lUdRate = LEFT(lp_oNewRes.rs_ratecod,1) = "*"
l_cRaAlias = IIF(l_lCustomRA, "resrart", "ratearti")
l_cRaWhileClause = IIF(l_lCustomRA, "ra_rsid = " + SqlCnv(lp_oNewRes.rs_rsid) + " AND ", "")
l_nOrdRa = ORDER(l_cRaAlias)
SET ORDER TO tag1 IN &l_cRaAlias
IF l_lCustomRA OR SEEK(lp_oResRate.rr_ratecod,"ratearti")
	RrRatecodeFirstLastDay(lp_oResRate.rr_date, lp_dRcStartDate, lp_dRcEndDate, @l_dFirstDate, @l_dLastDate)
	l_dCorrectionLastDate = l_dLastDate
	IF INLIST(ratecode.rc_rhytm, 7, 8)
		l_nParts = 1/(l_dLastDate-l_dFirstDate+1)
		STORE lp_oResRate.rr_date TO l_dFirstDate, l_dLastDate
	ELSE
		l_nParts = IIF(ratecode.rc_period = 4, (l_dLastDate-l_dFirstDate+1)/7, 1)
	ENDIF
	SELECT ressplit
	SCATTER BLANK NAME l_oRessplit
	l_oRessplit.rl_rsid = lp_oNewRes.rs_rsid
	l_oRessplit.rl_date = ICASE(ratecode.rc_rhytm = 3, lp_dRcStartDate, ratecode.rc_rhytm = 4, lp_dRcEndDate, lp_oResRate.rr_date)
	l_oRessplit.rl_rdate = lp_oResRate.rr_date
	l_oRessplit.rl_ratecod = lp_oResRate.rr_ratecod

	IF NOT EMPTY(lp_oNewRes.rs_discnt)
		l_lOnlyMainDisc = dlookup([picklist], [pl_label='DISCOUNT' AND pl_charcod = ] + sqlcnv(lp_oNewRes.rs_discnt,.T.),[pl_user1='1'])
	ENDIF

	SELECT &l_cRaAlias
	SCAN FOR SEEK(&l_cRaAlias..ra_artinum, "article", "tag1") WHILE &l_cRaWhileClause ra_ratecod = lp_oResRate.rr_ratecod
		IF RatePost("PostYesNo", lp_oResRate.rr_date,,@l_lPostIt, lp_oNewRes.rs_rate, lp_oNewRes.rs_arrdate, lp_dRcStartDate, lp_dRcEndDate,,l_cRaAlias)
			l_nUnits = 1
			DO CASE
				CASE &l_cRaAlias..ra_artityp = 1
					l_nPrice = lp_oNewRes.rs_rate * l_nParts	&& For week and stay/day-variable ratecodes price for main articles is proportional
				CASE EMPTY(&l_cRaAlias..ra_amnt) AND NOT EMPTY(&l_cRaAlias..ra_ratepct)
					l_nPrice = IIF(&l_cRaAlias..ra_pctexma, 0, lp_oNewRes.rs_rate * l_nParts * &l_cRaAlias..ra_ratepct / 100)		&& If ra_pctexma then calculate price at the end
				OTHERWISE
					l_nUnits = RrGetUnits(l_cRaAlias, lp_oResRate.rr_adults, lp_oResRate.rr_childs, lp_oResRate.rr_childs2, lp_oResRate.rr_childs3)
					DO CASE
						CASE ratecode.rc_period = 1
							l_nPeriods = Hours(lp_oNewRes.rs_arrtime, lp_oNewRes.rs_deptime, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_depdate, lp_oResRate.rr_date)
						CASE ratecode.rc_period = 2
							l_nPeriods = DayParts(lp_oNewRes.rs_arrtime, lp_oNewRes.rs_deptime, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_depdate, lp_oResRate.rr_date)
						OTHERWISE
							l_nPeriods = 1
					ENDCASE
					l_nUnits = l_nUnits * l_nPeriods
					IF lp_oNewRes.rs_rate = 0.00 AND &l_cRaAlias..ra_artityp <> 3
						* When rate for this ratecode is 0.00, then post all split articles with price 0.00
						l_nPrice = 0.00
					ELSE
						l_nPrice = &l_cRaAlias..ra_amnt
					ENDIF
			ENDCASE
			IF l_nUnits = 0
				* Don't post articles with units = 0
				LOOP
			ENDIF
			l_nRlPrice = ROUND(l_nPrice * IIF(&l_cRaAlias..ra_pmlocal, 1.00, lp_oResRate.rr_curcoef) * ;
				IIF(&l_cRaAlias..ra_artityp = 1 OR &l_cRaAlias..ra_artityp = 2 AND NOT l_lOnlyMainDisc, lp_oResRate.rr_ratcoef, 1), 2)
			IF &l_cRaAlias..ra_artityp = 1 AND l_nParts <> 1 AND lp_oResRate.rr_date = l_dCorrectionLastDate
				l_nRlPrice = ROUND(ROUND(lp_oNewRes.rs_rate * IIF(&l_cRaAlias..ra_pmlocal, 1.00, lp_oResRate.rr_curcoef) * ;
					IIF(&l_cRaAlias..ra_artityp = 1 OR &l_cRaAlias..ra_artityp = 2 AND NOT l_lOnlyMainDisc, lp_oResRate.rr_ratcoef, 1), 2) ;
					- (1/l_nParts-1)*l_nRlPrice, 2)		&& Rounding correction
			ENDIF
			l_oRessplit.rl_raid = &l_cRaAlias..ra_raid
			l_oRessplit.rl_artinum = IIF(l_lCustomRA, &l_cRaAlias..ra_artinum, rrgetmainartinum(lp_oResRate))	&& &l_cRaAlias..ra_artinum
			l_oRessplit.rl_artityp = &l_cRaAlias..ra_artityp
			l_oRessplit.rl_units = l_nUnits
			l_oRessplit.rl_price = l_nRlPrice
			IF l_lPostIt
				* For rc_period = 6 and split article which should be posted on some day, we must check if he is already posted also for another dates,
				* because all split articles with ra_onlyon > 0 would be posted, also when needed on last day of reservation.
				IF NOT DLocate("ressplit", StrToVfp("rl_rsid = %n1 AND rl_rdate " + IIF(ratecode.rc_period=6 AND &l_cRaAlias..ra_onlyon > 0, "<=","=") + " %d2 AND EMPTY(rl_rfid) AND rl_raid = %n3", lp_oNewRes.rs_rsid, lp_oResRate.rr_date, l_oRessplit.rl_raid))
					INSERT INTO ressplit (rl_rlid) VALUES (NextId("RESSPLIT"))
				ENDIF
				SELECT ressplit
				GATHER NAME l_oRessplit FIELDS EXCEPT rl_rlid
				IF INLIST(&l_cRaAlias..ra_artityp, 1, 3)
					l_nRedirectReserId = lp_oNewRes.rs_reserid
					BillInst("BillInstr", &l_cRaAlias..ra_artinum, lp_oNewRes.rs_billins, @l_nRedirectReserId, 1, .T., lp_oNewRes)
					IF &l_cRaAlias..ra_artityp = 1
						lp_oResRate.rr_raterc = l_nUnits * l_nPrice
						l_lPostPackage = .T.
					ELSE
						* When ratecode is in euro, but some extra article is in local currency, then
						* must recalculate price form local currency to foregin currency.
						lp_oResRate.rr_rateex = lp_oResRate.rr_rateex + l_nRlPrice * l_nUnits / EVL(lp_oResRate.rr_curcoef,1)
					ENDIF
					IF l_nRedirectReserId <> lp_oNewRes.rs_reserid
						lp_oResRate.rr_raterd = lp_oResRate.rr_raterd + l_nRlPrice * l_nUnits
					ENDIF
				ENDIF
				IF &l_cRaAlias..ra_artityp = 2 AND NOT l_lUdRate AND &l_cRaAlias..ra_package
					lp_oResRate.rr_package = lp_oResRate.rr_package + l_nUnits * l_nPrice
				ENDIF
				IF EMPTY(l_nRedirectReserId)	&& if RATECODE.RC_PERIOD > 3 and &l_cRaAlias..RA_ONLYON > 1 then redirected reservation is not defined yet.
					l_nRedirectReserId = lp_oNewRes.rs_reserid
					BillInst("BillInstr", &l_cRaAlias..ra_artinum, lp_oNewRes.rs_billins, @l_nRedirectReserId, 1, .T., lp_oNewRes)
				ENDIF
				IF l_nRedirectReserId <> lp_oNewRes.rs_reserid
					REPLACE rl_rdrsid WITH DLookUp("reservat", "rs_reserid = " + SqlCnv(l_nRedirectReserId), "rs_rsid") IN ressplit
				ENDIF
			ELSE
				IF DLocate("ressplit", StrToVfp("rl_rsid = %n1 AND BETWEEN(rl_rdate, %d2, %d3) AND EMPTY(rl_rfid) AND rl_raid = %n4 AND rl_artityp = 1", l_oRessplit.rl_rsid, l_dFirstDate, l_dLastDate, l_oRessplit.rl_raid))
					SELECT ressplit
					GATHER NAME l_oRessplit FIELDS rl_price
				ENDIF
			ENDIF
			SELECT &l_cRaAlias
		ENDIF
	ENDSCAN
	IF l_lPostPackage &&AND ratecode.rc_period <> 5 OR BETWEEN(RRGetMonthPostDate(lp_oResRate.rr_date, lp_dRcStartDate, lp_dRcEndDate), l_dFirstDate, l_dLastDate)
		RrResfixRate(lp_oResRate, lp_oNewRes, l_oRessplit)
	ENDIF
	IF lp_oResRate.rr_date = l_dLastDate
		l_cWhere = StrToVfp("BETWEEN(rl_rdate, %d1, %d2) AND rl_ratecod = %s3 AND (EMPTY(rl_rfid) OR EMPTY(rl_raid))", l_dFirstDate, l_dLastDate, lp_oResRate.rr_ratecod)
		lp_oResRate.rr_rateex = lp_oResRate.rr_rateex + RrSetMainSplit(lp_oResRate, lp_oNewRes, l_cWhere)
	ENDIF
ENDIF
SET ORDER TO l_nOrdRa IN &l_cRaAlias
SELECT (l_nArea)
ENDFUNC
*
PROCEDURE RrResfixRate
LPARAMETERS lp_oResRate, lp_oNewRes, lp_oRessplit
LOCAL l_nArea, l_nOrdRf, l_nRecnoRf, l_nOrdAr, l_nOrdRa, l_nOrdRc, l_nRecnoRC, l_cRatecode, l_nPrice, l_nUnits, l_lFound
LOCAL l_oRessplit, l_lPackage, l_nCurrencyrate, l_nResFixPrice, l_nReservatCurrencyRate, l_nRedirectReserId, l_cRaAlias, l_lCustomRA, l_cRaWhileClause

l_nArea = SELECT()
l_lPackage = (VARTYPE(lp_oRessplit) = "O")
l_nOrdRf = ORDER("resfix")
SET ORDER TO tag1 IN resfix
IF SEEK(lp_oResRate.rr_reserid, "resfix", "tag1")
	l_nRecnoRC = RECNO("ratecode")
	l_lCustomRA = SEEK(STR(lp_oNewRes.rs_rsid,10)+lp_oResRate.rr_ratecod, "ResRart", "tag1")
	l_cRaAlias = IIF(l_lCustomRA, "resrart", "ratearti")
	l_cRaWhileClause = IIF(l_lCustomRA, "ra_rsid = " + SqlCnv(lp_oNewRes.rs_rsid) + " AND ", "")
	l_nOrdRa = ORDER(l_cRaAlias)
	SET ORDER TO tag1 IN &l_cRaAlias
	l_nReservatCurrencyRate = RrGetCurrencyrate(lp_oResRate, lp_oNewRes, ratecode.rc_paynum)
	SELECT resfix
	SCAN FOR rf_alldays OR (lp_oNewRes.rs_arrdate + rf_day = lp_oResRate.rr_date) WHILE rf_reserid = lp_oResRate.rr_reserid
		IF NOT EMPTY(resfix.rf_ratecod) AND (resfix.rf_package = l_lPackage)
			l_lFound = RatecodeLocate(lp_oResRate.rr_date, resfix.rf_ratecod, lp_oNewRes.rs_roomtyp, lp_oNewRes.rs_arrdate, {}, .F., .T.)
			IF l_lFound AND IIF(l_lCustomRA, SEEK(STR(lp_oNewRes.rs_rsid,10)+ratecode.rc_key, "ResRart"), SEEK(ratecode.rc_key,"ratearti"))
				l_cRatecode = ratecode.rc_key
				l_nCurrencyrate = RrGetCurrencyrate(lp_oResRate, lp_oNewRes, ratecode.rc_paynum)
				SELECT ressplit
				SCATTER BLANK NAME l_oRessplit
				l_oRessplit.rl_rsid = lp_oNewRes.rs_rsid
				l_oRessplit.rl_date = lp_oResRate.rr_date
				l_oRessplit.rl_ratecod = l_cRatecode
				l_oRessplit.rl_rdate = lp_oResRate.rr_date
				l_oRessplit.rl_rfid = resfix.rf_rfid
				SELECT &l_cRaAlias
				SCAN FOR SEEK(&l_cRaAlias..ra_artinum, "article", "tag1") WHILE &l_cRaWhileClause ra_ratecod = l_cRatecode
					l_nUnits = 1
					DO CASE
						CASE &l_cRaAlias..ra_artityp = 1
							l_nPrice = resfix.rf_price
						CASE EMPTY(&l_cRaAlias..ra_amnt) AND NOT EMPTY(&l_cRaAlias..ra_ratepct)
							l_nPrice = IIF(&l_cRaAlias..ra_pctexma, 0, resfix.rf_price) * &l_cRaAlias..ra_ratepct / 100		&& If ra_pctexma then calculate price at the end
						OTHERWISE
							l_nUnits = RrGetUnits(l_cRaAlias, resfix.rf_adults, resfix.rf_childs, resfix.rf_childs2, resfix.rf_childs3)
							IF resfix.rf_price = 0.00 AND &l_cRaAlias..ra_artityp <> 3
								l_nPrice = 0.00
							ELSE
								l_nPrice = &l_cRaAlias..ra_amnt
							ENDIF
					ENDCASE
					IF l_nUnits = 0
						* Don't post articles with units = 0
						LOOP
					ENDIF
					l_oRessplit.rl_raid = &l_cRaAlias..ra_raid
					l_oRessplit.rl_artinum = IIF(l_lCustomRA, &l_cRaAlias..ra_artinum, rrgetmainartinum(lp_oResRate))	&&&l_cRaAlias..ra_artinum
					l_oRessplit.rl_artityp = &l_cRaAlias..ra_artityp
					l_oRessplit.rl_price = l_nPrice * IIF(&l_cRaAlias..ra_pmlocal,1.00,l_nCurrencyrate)
					l_oRessplit.rl_units = l_nUnits * resfix.rf_units
					IF DLocate("ressplit", StrToVfp("rl_rsid = %n1 AND rl_rdate = %d2 AND rl_rfid = %n3 AND rl_raid = %n4", ;
							lp_oNewRes.rs_rsid, lp_oResRate.rr_date, l_oRessplit.rl_rfid, l_oRessplit.rl_raid))
						SELECT ressplit
						GATHER NAME l_oRessplit FIELDS EXCEPT rl_rlid
					ELSE
						l_oRessplit.rl_rlid = NextId("RESSPLIT")
						INSERT INTO ressplit FROM NAME l_oRessplit
					ENDIF
					IF INLIST(&l_cRaAlias..ra_artityp, 1, 3)
						l_nRedirectReserId = lp_oNewRes.rs_reserid
						BillInst("BillInstr", &l_cRaAlias..ra_artinum, lp_oNewRes.rs_billins, @l_nRedirectReserId, 1, .T., lp_oNewRes)
						lp_oResRate.rr_ratefrc = lp_oResRate.rr_ratefrc + ressplit.rl_price * ressplit.rl_units
						IF l_nRedirectReserId <> lp_oNewRes.rs_reserid
							lp_oResRate.rr_raterd = lp_oResRate.rr_raterd + ressplit.rl_price * ressplit.rl_units
						ENDIF
					ENDIF
					IF EMPTY(l_nRedirectReserId)	&& if RATECODE.RC_PERIOD > 3 and &l_cRaAlias..RA_ONLYON > 1 then redirected reservation is not defined yet.
						l_nRedirectReserId = lp_oNewRes.rs_reserid
						BillInst("BillInstr", &l_cRaAlias..ra_artinum, lp_oNewRes.rs_billins, @l_nRedirectReserId, 1, .T., lp_oNewRes)
					ENDIF
					IF l_nRedirectReserId <> lp_oNewRes.rs_reserid
						REPLACE rl_rdrsid WITH DLookUp("reservat", "rs_reserid = " + SqlCnv(l_nRedirectReserId), "rs_rsid") IN ressplit
					ENDIF
					SELECT &l_cRaAlias
				ENDSCAN
				l_cWhere = StrToVfp("rl_rdate = %d1 AND rl_rfid = %n2", l_oRessplit.rl_rdate, l_oRessplit.rl_rfid)
				lp_oResRate.rr_ratefrc = lp_oResRate.rr_ratefrc + RrSetMainSplit(lp_oResRate, lp_oNewRes, l_cWhere)
			ENDIF
		ENDIF
		IF NOT EMPTY(resfix.rf_artinum) AND resfix.rf_package = l_lPackage AND SEEK(resfix.rf_artinum, "article", "tag1")
			l_nRedirectReserId = lp_oNewRes.rs_reserid
			BillInst("BillInstr", resfix.rf_artinum, lp_oNewRes.rs_billins, @l_nRedirectReserId, 1, .T., lp_oNewRes)
			IF resfix.rf_package
				l_nResFixPrice = resfix.rf_price
				lp_oRessplit.rl_raid = 0
				lp_oRessplit.rl_rfid = resfix.rf_rfid
				lp_oRessplit.rl_artinum = resfix.rf_artinum
				lp_oRessplit.rl_artityp = 2
				lp_oRessplit.rl_price = l_nResFixPrice
				lp_oRessplit.rl_units = resfix.rf_units
				IF DLocate("ressplit", StrToVfp("rl_rsid = %n1 AND rl_rdate = %d2 AND rl_rfid = %n3", lp_oNewRes.rs_rsid, lp_oResRate.rr_date, lp_oRessplit.rl_rfid))
					SELECT ressplit
					GATHER NAME lp_oRessplit FIELDS EXCEPT rl_rlid
				ELSE
					lp_oRessplit.rl_rlid = NextId("RESSPLIT")
					INSERT INTO ressplit FROM NAME lp_oRessplit
				ENDIF
				lp_oResRate.rr_ratepg = lp_oResRate.rr_ratepg + resfix.rf_units * l_nResFixPrice
			ELSE
				l_nResFixPrice = resfix.rf_price*IIF(NOT resfix.rf_forcurr,1,l_nReservatCurrencyRate)
				IF DLocate("ressplit", StrToVfp("rl_rsid = %n1 AND rl_rdate = %d2 AND rl_rfid = %n3", lp_oNewRes.rs_rsid, lp_oResRate.rr_date, resfix.rf_rfid))
					REPLACE rl_artinum WITH resfix.rf_artinum, rl_artityp WITH 3, rl_price WITH l_nResFixPrice, rl_units WITH resfix.rf_units IN ressplit
				ELSE
					INSERT INTO ressplit (rl_rlid, rl_rsid, rl_date, rl_rdate, rl_rfid, rl_artinum, rl_artityp, rl_price, rl_units) ;
						VALUES (NextId("RESSPLIT"), lp_oNewRes.rs_rsid, lp_oResRate.rr_date, lp_oResRate.rr_date, resfix.rf_rfid, resfix.rf_artinum, 3, l_nResFixPrice, resfix.rf_units)
				ENDIF
				lp_oResRate.rr_raterf = lp_oResRate.rr_raterf + resfix.rf_units * l_nResFixPrice
			ENDIF
			IF l_nRedirectReserId <> lp_oNewRes.rs_reserid
				REPLACE rl_rdrsid WITH DLookUp("reservat", "rs_reserid = " + SqlCnv(l_nRedirectReserId), "rs_rsid") IN ressplit
				lp_oResRate.rr_raterd = lp_oResRate.rr_raterd + resfix.rf_units * l_nResFixPrice
			ENDIF
		ENDIF
		SELECT resfix
	ENDSCAN
	SET ORDER TO l_nOrdRa IN &l_cRaAlias
	GO l_nRecnoRC IN ratecode
ENDIF
SET ORDER TO l_nOrdRf IN resfix
SELECT (l_nArea)
ENDPROC
*
PROCEDURE RrBanquetRate
LPARAMETERS lp_oResRate, lp_oNewRes
LOCAL l_nArea, l_nOrdBq, l_nRedirectReserId

l_nArea = SELECT()
l_nOrdBq = ORDER("banquet")
SET ORDER TO tag1 IN banquet
IF lp_oResRate.rr_date = lp_oNewRes.rs_arrdate AND SEEK(lp_oNewRes.rs_reserid, "banquet", "tag1")
	SELECT banquet
	SCAN FOR NOT EMPTY(bq_artinum) AND NOT EMPTY(bq_price) AND NOT EMPTY(bq_units) AND bq_calc WHILE bq_reserid = lp_oNewRes.rs_reserid
		IF SEEK(banquet.bq_artinum, "article", "tag1")
			l_nRedirectReserId = lp_oNewRes.rs_reserid
			BillInst("BillInstr", banquet.bq_artinum, lp_oNewRes.rs_billins, @l_nRedirectReserId, 1, .T., lp_oNewRes)
			IF DLocate("ressplit", "PADL(rl_rsid,10)+DTOS(rl_date) = " + SqlCnv(PADL(lp_oNewRes.rs_rsid,10)+DTOS(lp_oResRate.rr_date)) + ;
					" AND rl_bqid = " + SqlCnv(banquet.bq_bqid))
				REPLACE rl_artinum WITH banquet.bq_artinum, rl_artityp WITH 3, rl_price WITH banquet.bq_price, rl_units WITH banquet.bq_units IN ressplit
			ELSE
				INSERT INTO ressplit (rl_rlid, rl_rsid, rl_date, rl_rdate, rl_bqid, rl_artinum, rl_artityp, rl_price, rl_units) ;
					VALUES (NextId("RESSPLIT"), lp_oNewRes.rs_rsid, lp_oResRate.rr_date, lp_oResRate.rr_date, banquet.bq_bqid, banquet.bq_artinum, 3, banquet.bq_price, banquet.bq_units)
			ENDIF
			lp_oResRate.rr_raterf = lp_oResRate.rr_raterf + banquet.bq_units * banquet.bq_price
			IF l_nRedirectReserId <> lp_oNewRes.rs_reserid
				REPLACE rl_rdrsid WITH DLookUp("reservat", "rs_reserid = " + SqlCnv(l_nRedirectReserId), "rs_rsid") IN ressplit
				lp_oResRate.rr_raterd = lp_oResRate.rr_raterd + banquet.bq_units * banquet.bq_price
			ENDIF
		ENDIF
	ENDSCAN
ENDIF
SET ORDER TO l_nOrdBq IN banquet
SELECT (l_nArea)
ENDPROC
*
FUNCTION RrRatecodeSplitAmount
LPARAMETERS lp_oResRate, lp_oReservat, lp_dFoundDate, lp_aLinks, lp_cRaAlias, lp_lNoPctSplits, lp_nSumPrice
EXTERNAL ARRAY lp_aLinks
LOCAL l_nArea, l_nOrdRa, l_nPrice, l_nPeriods, l_nSumPrice, l_nOrderRC, l_nRecnoRC, l_dRcStartDate, l_dRcEndDate, l_dFirstDate, l_dLastDate, l_cRaWhileClause, l_lCustomRA, l_nRatePct

lp_nSumPrice = 0
lp_dFoundDate = {}
IF NOT USED("ratecode")
	RETURN lp_nSumPrice
ENDIF
l_nArea = SELECT()
IF EMPTY(lp_cRaAlias)
	l_lCustomRA = SEEK(STR(lp_oReservat.rs_rsid,10)+lp_oResRate.rr_ratecod, "ResRart", "tag1")
	lp_cRaAlias = IIF(l_lCustomRA, "resrart", "ratearti")
ELSE
	l_lCustomRA = .T.
ENDIF
l_cRaWhileClause = IIF(l_lCustomRA, "ra_rsid = " + SqlCnv(lp_oReservat.rs_rsid) + " AND ", "")
l_nOrdRa = ORDER(lp_cRaAlias)
SET ORDER TO tag1 IN &lp_cRaAlias		&& STR(ra_rsid,10)+ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4)
l_nRecnoRC = RECNO("ratecode")
IF LOWER(ORDER("ratecode"))<>"tag1"
	l_nOrderRC = ORDER("ratecode")
	SET ORDER TO tag1 IN ratecode
ENDIF
IF VARTYPE(lp_aLinks)="L"
	RrRatecodeInterval(lp_oResRate.rr_reserid, lp_oResRate.rr_date, @l_dRcStartDate, @l_dRcEndDate)
	RrRatecodeFirstLastDay(lp_oResRate.rr_date, l_dRcStartDate, l_dRcEndDate, @l_dFirstDate, @l_dLastDate)
	DIMENSION lp_aLinks(1,6)
	lp_aLinks(1,1) = lp_oResRate.rr_date
	lp_aLinks(1,2) = l_dFirstDate
	lp_aLinks(1,3) = l_dLastDate
	lp_aLinks(1,4) = lp_oReservat.rs_rate
	lp_aLinks(1,5) = 0
	lp_aLinks(1,6) = 0
ENDIF
IF NOT EMPTY(lp_aLinks(1,2))
	FOR i = 1 TO ALEN(lp_aLinks,1)
		l_nSumPrice = 0
		l_nRatePct = 0
		SELECT resrate
		SCAN FOR rr_reserid = lp_oReservat.rs_reserid AND BETWEEN(rr_date, lp_aLinks(i,2), lp_aLinks(i,3))
			SCATTER NAME l_oResRate MEMO
			IF SEEK(IIF(l_lCustomRA,STR(lp_oReservat.rs_rsid,10),"")+l_oResRate.rr_ratecod,lp_cRaAlias) AND SEEK(l_oResRate.rr_ratecod,"ratecode","tag1")
				RrRatecodeInterval(l_oResRate.rr_reserid, l_oResRate.rr_date, @l_dRcStartDate, @l_dRcEndDate)
				SELECT &lp_cRaAlias
				SCAN FOR ra_artityp = 2 WHILE &l_cRaWhileClause ra_ratecod = l_oResRate.rr_ratecod
					IF NOT SEEK(&lp_cRaAlias..ra_artinum, "article", "tag1")
						EXIT
					ENDIF
					IF RatePost("PostYesNo", l_oResRate.rr_date,,,lp_oReservat.rs_rate, lp_oReservat.rs_arrdate, l_dRcStartDate, l_dRcEndDate,,lp_cRaAlias)
						l_nUnits = 1
						IF EMPTY(ra_amnt) AND NOT EMPTY(ra_ratepct)
							l_nPrice = 0&&lp_oReservat.rs_rate * ra_ratepct / 100
							IF NOT ra_pctexma
								IF lp_lNoPctSplits
									l_nRatePct = l_nRatePct + ra_ratepct
								ELSE
									l_nPrice = lp_oReservat.rs_rate * ra_ratepct / 100
								ENDIF
							ENDIF
						ELSE
							l_nUnits = RrGetUnits(lp_cRaAlias, l_oResRate.rr_adults, l_oResRate.rr_childs, l_oResRate.rr_childs2, l_oResRate.rr_childs3)
*							DO CASE
*								CASE ratecode.rc_period = 1
*									l_nPeriods = Hours(lp_oReservat.rs_arrtime, lp_oReservat.rs_deptime, lp_oReservat.rs_arrdate, ;
*											lp_oReservat.rs_depdate, l_oResRate.rr_date)
*								CASE ratecode.rc_period = 2
*									l_nPeriods = DayParts(lp_oReservat.rs_arrtime, lp_oReservat.rs_deptime, lp_oReservat.rs_arrdate, ;
*											lp_oReservat.rs_depdate, l_oResRate.rr_date)
*								OTHERWISE
									l_nPeriods = 1
*							ENDCASE
							l_nUnits = l_nUnits * l_nPeriods
							l_nPrice = ra_amnt * l_nUnits
						ENDIF
						l_nSumPrice = l_nSumPrice + l_nPrice
						SELECT &lp_cRaAlias
					ENDIF
				ENDSCAN
			ENDIF
		ENDSCAN
		IF NOT EMPTY(l_nRatePct)
			l_nSumPrice = l_nSumPrice * 100/(100-l_nRatePct)
		ENDIF
		lp_aLinks(i,6) = l_nSumPrice
		IF NOT EMPTY(lp_aLinks(1,4)) AND l_nSumPrice > MAX(lp_aLinks(i,4), lp_nSumPrice)
			lp_nSumPrice = l_nSumPrice
			lp_dFoundDate = lp_aLinks(i,1)
		ENDIF
	ENDFOR
ENDIF
SET ORDER TO l_nOrdRa IN &lp_cRaAlias
IF NOT EMPTY(l_nOrderRC)
	SET ORDER TO l_nOrderRC IN ratecode
ENDIF
GO l_nRecnoRC IN ratecode
SELECT (l_nArea)

RETURN lp_nSumPrice
ENDFUNC
*
FUNCTION RrDayPrice
LPARAMETERS lp_oNewRes, lp_dDate, lp_nPrice, lp_cAlias
LOCAL l_nRecno, l_nReserId, l_BackComp, l_nPrice, l_nPeriods, l_dRcStartDate, l_dRcEndDate, l_nRecnoRC, l_oResrooms, l_lFound, l_dFirstDate, l_dLastDate, l_cRoomtype

IF VARTYPE(lp_oNewRes) = "N"
	l_nReserId = lp_oNewRes
	l_BackComp = .T.	&& Backward compatibility
ELSE
	l_nReserId = lp_oNewRes.rs_reserid
ENDIF

lp_cAlias = EVL(lp_cAlias, "resrate")
l_nRecno = RECNO(lp_cAlias)
DO CASE
	CASE NOT SEEK(STR(l_nReserId,12,3)+DTOS(lp_dDate),lp_cAlias,"tag2")
		lp_nPrice = 0
	CASE EMPTY(&lp_cAlias..rr_ratecod)
		lp_nPrice = &lp_cAlias..rr_raterc
	OTHERWISE
		l_nRecnoRC = RECNO("ratecode")
		RrRatecodeInterval(l_nReserId, lp_dDate, @l_dRcStartDate, @l_dRcEndDate, lp_cAlias)
		l_lFound = SEEK(&lp_cAlias..rr_ratecod,"ratecode","tag1")
		IF NOT l_lFound
			* This can happen when ratecode key rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season is changed
			* then try to locate on right record in ratecode
			RiGetRoom(l_nReserId, lp_dDate, @l_oResrooms)
			IF ISNULL(l_oResrooms)
				l_cRoomtype = ""
			ELSE
				l_cRoomtype = l_oResrooms.ri_roomtyp
			ENDIF
			l_lFound = RatecodeLocate(lp_dDate, ALLTRIM(LEFT(&lp_cAlias..rr_ratecod,10)), l_cRoomtype, l_dRcStartDate,,,.T.)
		ENDIF
		DO CASE
			CASE NOT l_lFound OR ratecode.rc_period = 3
				lp_nPrice = &lp_cAlias..rr_raterc
			CASE ratecode.rc_period = 1
				lp_nPrice = &lp_cAlias..rr_raterc / IIF(l_BackComp, 24, Hours(lp_oNewRes.rs_arrtime, lp_oNewRes.rs_deptime, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_depdate, lp_dDate))
			CASE ratecode.rc_period = 2
				lp_nPrice = &lp_cAlias..rr_raterc / IIF(l_BackComp, 3, DayParts(lp_oNewRes.rs_arrtime, lp_oNewRes.rs_deptime, lp_oNewRes.rs_arrdate, lp_oNewRes.rs_depdate, lp_dDate))
			OTHERWISE
				RrRatecodeFirstLastDay(lp_dDate, l_dRcStartDate, l_dRcEndDate, @l_dFirstDate, @l_dLastDate)
				CALCULATE SUM(rr_raterc) FOR rr_reserid = l_nReserId AND BETWEEN(rr_date, l_dFirstDate, l_dLastDate) TO l_nPrice IN &lp_cAlias
				DO CASE
					CASE ratecode.rc_rhytm <> 6
					CASE l_dFirstDate = l_dRcStartDate AND l_dLastDate < l_dRcEndDate AND ratecode.rc_moposon < DAY(l_dFirstDate) AND EMPTY(l_nPrice)
						RrRatecodeFirstLastDay(l_dLastDate+1, l_dRcStartDate, l_dRcEndDate, @l_dFirstDate, @l_dLastDate)
						CALCULATE SUM(rr_raterc) FOR rr_reserid = l_nReserId AND BETWEEN(rr_date, l_dFirstDate, l_dLastDate) TO l_nPrice IN &lp_cAlias
					CASE NOT EMPTY(lp_nPrice)
						l_nPrice = lp_nPrice
					OTHERWISE
				ENDCASE
				lp_nPrice = l_nPrice
		ENDCASE
		GO l_nRecnoRC IN ratecode
ENDCASE
GO l_nRecno IN &lp_cAlias

RETURN lp_nPrice
ENDFUNC
*
PROCEDURE RrSetLinks
LPARAMETERS lp_nReserid, lp_dArrDate
LOCAL l_nArea, l_cOrderRR, l_nRecnoRR, l_nRecnoRC, l_cRatecode, l_cRcWhere, l_dDate, l_dRcStartDate, l_dRcEndDate, l_dFirstDate, l_dLastDate

l_nArea = SELECT()

l_nRecnoRC = RECNO("ratecode")

SELECT curResrate
l_cOrderRR = ORDER()
SET ORDER TO tag2
IF SEEK(STR(lp_nReserid,12,3) + DTOS(lp_dArrDate),"curResrate","Tag2")
	SCAN REST WHILE rr_reserid = lp_nReserid
		l_cRatecode = rr_ratecod
		l_cRcWhere = "rr_ratecod = " + SqlCnv(rr_ratecod)
		LOCATE REST FOR rr_status <> "X" AND SEEK(l_cRatecode,"ratecode","tag1") AND INLIST(ratecode.rc_period, 4, 5, 6, 7) WHILE rr_reserid = lp_nReserid AND &l_cRcWhere
		IF FOUND()
			l_nRecnoRR = RECNO()
			l_dDate = rr_date
			RrRatecodeInterval(lp_nReserid, l_dDate, @l_dRcStartDate, @l_dRcEndDate, "curResrate")
			RrRatecodeFirstLastDay(l_dDate, l_dRcStartDate, l_dRcEndDate, @l_dFirstDate, @l_dLastDate)
			CALCULATE AVG(rr_raterc) REST WHILE rr_reserid = lp_nReserid AND BETWEEN(rr_date, l_dFirstDate, l_dLastDate) TO l_nAvgRate
			IF _tally > 1
				GO l_nRecnoRR
				REPLACE rr_rateavg WITH ROUND(l_nAvgRate, 6), rr_link WITH RRGetPostDate(rr_date, l_dRcStartDate, l_dRcEndDate, l_dFirstDate, l_dLastDate) ;
					REST WHILE rr_reserid = lp_nReserid AND BETWEEN(rr_date, l_dFirstDate, l_dLastDate)
			ENDIF
		ENDIF
		SKIP -1
	ENDSCAN
ENDIF
SET ORDER TO l_cOrderRR

GO l_nRecnoRC IN ratecode

SELECT (l_nArea)
ENDPROC
*
PROCEDURE RrHistToRes
LPARAMETERS lp_oOldHRes, lp_oNewHRes, lp_oOldRes, lp_oNewRes
LOCAL i, l_oRes, l_oHRes
FOR i = 1 TO 2
	IF i = 1
		l_oRes = lp_oOldRes
		l_oHRes = lp_oOldHRes
	ELSE
		l_oRes = lp_oNewRes
		l_oHRes = lp_oNewHRes
	ENDIF
	l_oRes.rs_reserid = l_oHRes.hr_reserid
	l_oRes.rs_arrdate = l_oHRes.hr_arrdate
	l_oRes.rs_depdate = l_oHRes.hr_depdate
	l_oRes.rs_arrtime = l_oHRes.hr_arrtime
	l_oRes.rs_deptime = l_oHRes.hr_deptime
	l_oRes.rs_roomtyp = l_oHRes.hr_roomtyp
	l_oRes.rs_ratecod = l_oHRes.hr_ratecod
	l_oRes.rs_rate = l_oHRes.hr_rate
	l_oRes.rs_adults = l_oHRes.hr_adults
	l_oRes.rs_childs = l_oHRes.hr_childs
	l_oRes.rs_childs2 = l_oHRes.hr_childs2
	l_oRes.rs_childs3 = l_oHRes.hr_childs3
	l_oRes.rs_allott = l_oHRes.hr_allott
	l_oRes.rs_ratedat = l_oHRes.hr_ratedat
	l_oRes.rs_billins = l_oHRes.hr_billins
ENDFOR
ENDPROC
*
PROCEDURE RrRatecodeInterval
LPARAMETERS lp_uReser, lp_dDate, lp_dFromDate, lp_dToDate, lp_cAlias
LOCAL l_nArea, l_nRecno, l_nRecnoRR, l_cOrder, l_nReserid, l_cRatecode, l_lFilterByRcName, l_cWhere

IF EMPTY(lp_dFromDate) OR EMPTY(lp_dToDate) OR NOT BETWEEN(lp_dDate, lp_dFromDate, lp_dToDate)
	lp_cAlias = EVL(lp_cAlias, "resrate")
	l_nRecno = RECNO(lp_cAlias)
	l_nReserid = IIF(VARTYPE(lp_uReser) = "O", lp_uReser.rs_reserid, lp_uReser)
	STORE {} TO lp_dFromDate, lp_dToDate
	IF VARTYPE(lp_uReser) = "O"
		lp_dToDate = RrGetLastDate(lp_uReser)
		IF SEEK(STR(l_nReserid,12,3)+DTOS(lp_dToDate), lp_cAlias, "tag2")
			lp_dToDate = {}
		ENDIF
	ENDIF
	IF SEEK(STR(l_nReserid,12,3)+DTOS(lp_dDate), lp_cAlias, "tag2")
		l_nArea = SELECT()
		SELECT &lp_cAlias
		l_nRecnoRR = RECNO()
		l_cWhere = "PADR(CHRTRAN(LEFT(rr_ratecod,11), '!*', ''),10) = " + SqlCnv(PADR(CHRTRAN(LEFT(rr_ratecod,11), "!*", ""),10))
		l_cOrder = ORDER()
		SET ORDER TO tag2 DESCENDING
		LOCATE FOR NOT &l_cWhere WHILE rr_reserid = l_nReserid
		SKIP -1
		lp_dFromDate = rr_date
		IF EMPTY(lp_dToDate)
			GO l_nRecnoRR
			SET ORDER TO tag2 ASCENDING
			LOCATE FOR NOT &l_cWhere WHILE rr_reserid = l_nReserid
			SKIP -1
			lp_dToDate = rr_date
		ENDIF
		SET ORDER TO l_cOrder ASCENDING
		SELECT (l_nArea)
	ENDIF
	GO l_nRecno IN &lp_cAlias
ENDIF
ENDPROC
*
PROCEDURE RrRatecodeFirstLastDay
LPARAMETERS lp_dForDate, lp_dRcStartDate, lp_dRcEndDate, lp_dFirstDate, lp_dLastDate

DO CASE
	CASE ratecode.rc_period = 4
		lp_dFirstDate = lp_dRcStartDate + FLOOR((lp_dForDate - lp_dRcStartDate) / 7) * 7
		lp_dLastDate = MIN(lp_dRcEndDate, lp_dFirstDate + 6)
	CASE ratecode.rc_period = 5
		RRGetMonthPostDate(lp_dForDate, lp_dRcStartDate, lp_dRcEndDate, @lp_dFirstDate, @lp_dLastDate)
		lp_dFirstDate = MAX(lp_dRcStartDate, lp_dFirstDate)
		lp_dLastDate = MIN(lp_dRcEndDate, lp_dLastDate)
	CASE ratecode.rc_period = 6
		lp_dFirstDate = lp_dRcStartDate
		lp_dLastDate = lp_dRcEndDate
	CASE ratecode.rc_period = 7
		lp_dFirstDate = lp_dRcStartDate + FLOOR((lp_dForDate - lp_dRcStartDate) / ratecode.rc_prcdur) * ratecode.rc_prcdur
		lp_dLastDate = MIN(lp_dRcEndDate, lp_dFirstDate + ratecode.rc_prcdur - 1)
	OTHERWISE
		lp_dFirstDate = lp_dForDate
		lp_dLastDate = lp_dForDate
ENDCASE
ENDPROC
*
FUNCTION RrRateCoefficient
LPARAMETERS lp_oResRate, lp_oNewRes
LOCAL l_nRateCoefficient, l_nCurrencyRate, l_nDiscnt

l_nRateCoefficient = 1
l_nCurrencyRate = 1

IF NOT EMPTY(lp_oNewRes.rs_discnt)
	l_nDiscnt = DLookUp("picklist", "pl_label = [DISCOUNT] AND pl_charcod = "+SqlCnv(lp_oNewRes.rs_discnt), "pl_numval")
ELSE
	l_nDiscnt = 0
ENDIF
IF BETWEEN(l_nDiscnt, 0, 100)
	l_nRateCoefficient = (100 - l_nDiscnt) / 100
	IF ROUND(l_nRateCoefficient,4) = 1
		l_nRateCoefficient = 1
	ENDIF
ENDIF
IF l_nRateCoefficient > 0
	l_nCurrencyrate = RrGetCurrencyrate(lp_oResRate, lp_oNewRes, ratecode.rc_paynum)
	IF ROUND(l_nCurrencyrate,4) = 1
		l_nCurrencyrate = 1
	ENDIF
ENDIF

lp_oResRate.rr_ratcoef = l_nRateCoefficient
lp_oResRate.rr_curcoef = l_nCurrencyRate

RETURN .T.
ENDFUNC
*
FUNCTION RrOpenAlias
 LPARAMETERS lp_cTable, lp_cAlias
 LOCAL l_lCloseAlias

 IF EMPTY(lp_cAlias)
 	lp_cAlias = lp_cTable
 ENDIF
 IF NOT USED(lp_cAlias)
	openfiledirect(.F., lp_cTable, lp_cAlias)
	l_lCloseAlias = .T.
 ENDIF

 RETURN l_lCloseAlias
ENDFUNC
*
PROCEDURE RrCloseAlias
 LPARAMETERS lp_cAlias, lp_lCloseAlias

 IF lp_lCloseAlias AND USED(lp_cAlias)
*	USE IN &lp_cAlias	&& Leave table open. Never close a table.
 ENDIF
ENDPROC
*
PROCEDURE RrAdjustCustomPrices
LPARAMETERS lp_nReserId, lp_dNewArrDate, lp_dOldArrDate
LOCAL l_curResrate, l_nDaysOffSet
IF NOT EMPTY(lp_nReserId) AND NOT EMPTY(lp_dNewArrDate) AND NOT EMPTY(lp_dOldArrDate) AND ;
		lp_dNewArrDate <> lp_dOldArrDate
	l_nDaysOffSet = lp_dNewArrDate - lp_dOldArrDate
	l_curResrate = SYS(2015)
	SELECT * FROM resrate WITH (Buffering = .T.) WHERE STR(rr_reserid,12,3)+LEFT(rr_status,2)+DTOS(rr_date) = STR(lp_nReserId,12,3)+"OR" INTO CURSOR &l_curResrate READWRITE
	INDEX ON rr_date TAG rr_date
	DELETE FOR rr_reserid = lp_nReserId AND LEFT(rr_status,2) <> "OR" AND SEEK(rr_date-l_nDaysOffSet,l_curResrate,"rr_date") IN resrate
	DClose(l_curResrate)
	REPLACE rr_date WITH resrate.rr_date + l_nDaysOffSet ;
			FOR STR(rr_reserid,12,3)+LEFT(rr_status,2)+DTOS(rr_date) = STR(lp_nReserId,12,3) + "OR" ;
			IN resrate
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE RrRatecodeIncl
LPARAMETERS lp_nRsId, lp_cRatecode, lp_nRate, lp_dArrdate, lp_cRoomtype
LOCAL l_lIncluded, l_lFound, l_cRatecode, l_curRoomtype, l_nSelect

l_lIncluded = .T.
lp_cRatecode = PADR(CHRTRAN(lp_cRatecode,"*!",""),10)

IF lp_cRatecode = "DUM       "
	l_nSelect = SELECT()
	l_curRoomtype = SqlCursor("SELECT * FROM roomtype WHERE rt_roomtyp = " + SqlCnv(lp_cRoomtype,.T.))
	IF &l_curRoomtype..rt_group = 3
		l_lFound = RatecodeLocate(lp_dArrdate, lp_cRatecode, lp_cRoomtype, lp_dArrdate,,,.T.)
		IF l_lFound
			l_cRatecode = ratecode.rc_ratecod+ratecode.rc_roomtyp+DTOS(ratecode.rc_fromdat)+ratecode.rc_season
			IF NOT DLocate("resrart", "ra_rsid = " + SqlCnv(lp_nRsId) + " AND ra_ratecod = " + SqlCnv(l_cRatecode) + " AND ra_artityp <> 1") AND ;
					NOT DLocate("ratearti", "ra_ratecod = " + SqlCnv(l_cRatecode) + " AND ra_artityp <> 1")
				l_lIncluded = (lp_nRate <> 0.00)
			ENDIF
		ENDIF
	ENDIF
	DClose(l_curRoomtype)
	SELECT (l_nSelect)
ENDIF

RETURN l_lIncluded
ENDPROC
*
PROCEDURE RrGetLastDate
LPARAMETERS lp_oNewRes
LOCAL l_nSelect, l_oResrooms, l_cRoomtype, l_curRoomtype, l_dToDate, l_nRtGroup

l_dToDate = MAX(lp_oNewRes.rs_arrdate, RrGetRsDepDate(lp_oNewRes))

IF NOT _screen.oGlobal.oParam2.pa_connold

	IF lp_oNewRes.rs_depdate > lp_oNewRes.rs_arrdate
		l_nSelect = SELECT()

		RiGetRoom(lp_oNewRes.rs_reserid, lp_oNewRes.rs_depdate, @l_oResrooms)
		IF ISNULL(l_oResrooms)
			l_cRoomtype = lp_oNewRes.rs_roomtyp
		ELSE
			l_cRoomtype = l_oResrooms.ri_roomtyp
		ENDIF

		l_nRtGroup = get_rt_roomtyp(l_cRoomtype, "rt_group")
		IF NOT EMPTY(l_nRtGroup) AND l_nRtGroup = 2
			l_dToDate = lp_oNewRes.rs_depdate
		ENDIF

		SELECT (l_nSelect)
	ENDIF

ENDIF

RETURN l_dToDate
ENDPROC
*
PROCEDURE RrGetRsDepDate
LPARAMETERS lp_oRes
LOCAL l_lConfRoom, l_dToDate

IF NOT _screen.oGlobal.oParam2.pa_connold
	l_lConfRoom = DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(lp_oRes.rs_roomtyp,.T.), "rt_group = 2")
ENDIF

l_dToDate = IIF(l_lConfRoom,lp_oRes.rs_depdate,MAX(lp_oRes.rs_arrdate, lp_oRes.rs_depdate - 1))

RETURN l_dToDate
ENDPROC
*
PROCEDURE RlRebuild
LPARAMETERS lp_lInitialRebuild
LOCAL l_oNewRes, l_cOrder, l_cOrderRR, l_dFromDate, l_dToDate, l_cNear
LOCAL l_lCloseRessplit, l_lCloseReservat, l_lCloseResrate, l_lCloseRatecode, l_lCloseRatearti, l_lCloseArticle, l_lCloseResfix, l_lCloseResRart, l_lCloseBanquet
LOCAL ARRAY l_aTasks(1,2)

IF lp_lInitialRebuild AND NOT YesNo(Str2Msg(GetLangText("RESERVAT","TXT_ERASERESSPLIT")))
	RETURN
ENDIF
l_lCloseRessplit = RrOpenAlias("ressplit")
l_lCloseReservat = RrOpenAlias("reservat")
l_lCloseResrate = RrOpenAlias("resrate")
l_lCloseRatecode = RrOpenAlias("ratecode")
l_lCloseRatearti = RrOpenAlias("ratearti")
l_lCloseArticle = RrOpenAlias("article")
l_lCloseResfix = RrOpenAlias("resfix")
l_lCloseResRart = RrOpenAlias("resrart")
l_lCloseBanquet = RrOpenAlias("banquet")

IF lp_lInitialRebuild
	DELETE ALL IN ressplit
ENDIF

l_cOrderRR = ORDER("resrate")
CURSORSETPROP("Buffering",5,"resrate")
SET ORDER TO Tag2 IN resrate
ON KEY LABEL ALT+Q GO BOTTOM IN reservat
l_cNear = SET("Near")
SET NEAR ON
SELECT reservat
l_cOrder = ORDER()
SET ORDER TO
l_aTasks(1,1) = RECCOUNT()
l_aTasks(1,2) = GetLangText("MENU","MNT_RESSPLITRBLD")+"..."
DO FORM forms\progressbar NAME ProgressBar WITH GetLangText("MENU","MNT_RESSPLITRBLD"), l_aTasks
SCAN FOR rs_reserid >= 1 AND NOT EMPTY(rs_arrdate) AND NOT EMPTY(rs_depdate) AND NOT EMPTY(rs_roomtyp) AND NOT EMPTY(rs_ratecod) AND ;
		RrRatecodeIncl(rs_rsid, rs_ratecod, rs_rate, rs_arrdate, rs_roomtyp) AND (lp_lInitialRebuild OR NOT SEEK(reservat.rs_rsid,"ressplit","Tag1"))
	STORE {} TO l_dFromDate, l_dToDate
	ProgressBar.Update(RECNO())
	SCATTER NAME l_oNewRes MEMO
	SELECT resrate
	=SEEK(STR(l_oNewRes.rs_reserid,12,3)+DTOS(l_oNewRes.rs_arrdate),"resrate","Tag2")
	SCAN FOR rr_status <> "X" AND SEEK(resrate.rr_ratecod,"ratecode","tag1") WHILE rr_reserid = l_oNewRes.rs_reserid
		SCATTER NAME l_oResRate
		RrRatecodeInterval(l_oResRate.rr_reserid, l_oResRate.rr_date, @l_dFromDate, @l_dToDate)
		l_oNewRes.rs_rate = RrDayPrice(l_oNewRes, l_oResRate.rr_date)
		RrRatecodeRate(l_oResRate, l_oNewRes, l_dFromDate, l_dToDate)
		RrResfixRate(l_oResRate, l_oNewRes)
		RrBanquetRate(l_oResRate, l_oNewRes)
	ENDSCAN
	TABLEREVERT(.T.,"resrate")
	REPLACE rs_updated WITH g_sysdate, ;
			rs_changes WITH rsHistry(reservat.rs_changes, "RES.SPLITS REBUILD","Automatic") IN reservat
ENDSCAN
SET ORDER TO l_cOrder IN reservat
CURSORSETPROP("Buffering",1,"resrate")
SET ORDER TO l_cOrderRR IN resrate
SET NEAR &l_cNear
ON KEY LABEL ALT+Q
ProgressBar.Complete()

RrCloseAlias("ressplit", l_lCloseRessplit)
RrCloseAlias("reservat", l_lCloseReservat)
RrCloseAlias("resrate", l_lCloseResrate)
RrCloseAlias("ratecode", l_lCloseRatecode)
RrCloseAlias("ratearti", l_lCloseRatearti)
RrCloseAlias("resrart", l_lCloseResRart)
RrCloseAlias("article", l_lCloseArticle)
RrCloseAlias("resfix", l_lCloseResfix)
RrCloseAlias("banquet", l_lCloseBanquet)
ENDPROC
*
PROCEDURE RlDeleteDummy
LPARAMETERS lp_dDate, lp_oNewRes
LOCAL l_nArea, l_nOrder, l_nRecno, l_cWhere, l_cOldRatecode, l_dRcStartDate, l_dRcEndDate, l_dFirstDate, l_dLastDate

IF lp_oNewRes.rs_rcsync
	RETURN .T.	&& Already deleted in RrUpdate()
ENDIF

l_nArea = SELECT()
SELECT ressplit
l_nOrder = ORDER()
SET ORDER TO tag1

IF SEEK(lp_oNewRes.rs_rsid) AND SEEK(STR(lp_oNewRes.rs_reserid,12,3)+DTOS(lp_dDate), "resrate", "Tag2") AND RatecodeLocate(lp_dDate, lp_oNewRes.rs_ratecod, lp_oNewRes.rs_roomtyp, lp_oNewRes.rs_arrdate,,,.T.)
	RrRatecodeInterval(lp_oNewRes.rs_reserid, lp_dDate, @l_dRcStartDate, @l_dRcEndDate)
	RrRatecodeFirstLastDay(lp_dDate, l_dRcStartDate, l_dRcEndDate, @l_dFirstDate, @l_dLastDate)

	l_nRecno = RECNO()
	LOCATE FOR BETWEEN(rl_rdate, l_dFirstDate, l_dLastDate) AND NOT EMPTY(rl_rfid) WHILE rl_rsid = lp_oNewRes.rs_rsid
	IF FOUND()
		* Delete records for resfix
		DELETE FOR BETWEEN(rl_rdate, l_dFirstDate, l_dLastDate) AND NOT EMPTY(rl_rfid) AND ;
			NOT (SEEK(rl_rfid,'resfix','tag2') AND (resfix.rf_alldays OR rl_rdate = lp_oNewRes.rs_arrdate + resfix.rf_day) AND ;
			(EMPTY(rl_raid) OR SEEK(STR(rl_rsid,10)+rl_ratecod+STR(rl_raid,10),'resrart','tag2') OR SEEK(rl_ratecod+STR(rl_raid,10),'ratearti','tag2'))) ;
			WHILE rl_rsid = lp_oNewRes.rs_rsid
	ENDIF
	GO l_nRecno
	LOCATE FOR BETWEEN(rl_rdate, l_dFirstDate, l_dLastDate) AND NOT EMPTY(rl_bqid) WHILE rl_rsid = lp_oNewRes.rs_rsid
	IF FOUND()
		* Delete records for banquet
		DELETE FOR BETWEEN(rl_rdate, l_dFirstDate, l_dLastDate) AND NOT EMPTY(rl_bqid) AND NOT SEEK(rl_bqid,'banquet','tag4') WHILE rl_rsid = lp_oNewRes.rs_rsid
	ENDIF
	GO l_nRecno
	LOCATE FOR BETWEEN(rl_rdate, l_dFirstDate, l_dLastDate) AND NOT EMPTY(rl_ratecod) AND EMPTY(rl_bqid) AND EMPTY(rl_raid) <> EMPTY(rl_rfid) WHILE rl_rsid = lp_oNewRes.rs_rsid
	IF FOUND()
		* Delete records for main ratecode
		l_cOldRatecode = rl_ratecod
		IF l_cOldRatecode == ratecode.rc_key
			* Delete all not included splits in main ratecode
			IF SEEK(STR(lp_oNewRes.rs_rsid,10)+l_cOldRatecode, "ResRart", "tag1")
				l_cWhere = "NOT (SEEK(STR(rl_rsid,10)+rl_ratecod+STR(rl_raid,10),'resrart','tag2') AND RrPostIt(rl_rdate, l_dRcStartDate, l_dRcEndDate,,'resrart') AND " + ;
						   "RrGetUnits('resrart', lp_oNewRes.rs_adults, lp_oNewRes.rs_childs, lp_oNewRes.rs_childs2, lp_oNewRes.rs_childs3)<>0) "
			ELSE
				l_cWhere = "NOT (SEEK(rl_ratecod+STR(rl_raid,10),'ratearti','tag2') AND RrPostIt(rl_rdate, l_dRcStartDate, l_dRcEndDate) AND " + ;
						   "RrGetUnits('ratearti', lp_oNewRes.rs_adults, lp_oNewRes.rs_childs, lp_oNewRes.rs_childs2, lp_oNewRes.rs_childs3)<>0) "
			ENDIF
			l_cWhere = "NOT EMPTY(rl_raid) AND EMPTY(rl_rfid) AND " + l_cWhere + ;
				"OR EMPTY(rl_raid) AND NOT EMPTY(rl_rfid) AND NOT (SEEK(ressplit.rl_rfid,'resfix','tag2') AND (resfix.rf_alldays OR rl_rdate = " + SqlCnv(lp_oNewRes.rs_arrdate) + " + resfix.rf_day))"
		ELSE
			* Delete all packages and splits in main ratecode
			l_cWhere = "EMPTY(rl_raid) <> EMPTY(rl_rfid)"
		ENDIF
		DELETE FOR BETWEEN(rl_rdate, l_dFirstDate, l_dLastDate) AND rl_ratecod = l_cOldRatecode AND (&l_cWhere) WHILE rl_rsid = lp_oNewRes.rs_rsid
	ENDIF
ENDIF

SET ORDER TO l_nOrder
SELECT (l_nArea)
ENDPROC
*
PROCEDURE RrGetUnits
LPARAMETERS lp_cRaAlias, lp_nAdults, lp_nChilds, lp_nChilds2, lp_nChilds3
LOCAL l_nUnits

DO CASE
	CASE &lp_cRaAlias..ra_multipl = 1
		l_nUnits = lp_nAdults
	CASE &lp_cRaAlias..ra_multipl = 2
		l_nUnits = lp_nAdults + lp_nChilds + lp_nChilds2 + lp_nChilds3
	CASE &lp_cRaAlias..ra_multipl = 3
		l_nUnits = lp_nChilds
	CASE &lp_cRaAlias..ra_multipl = 4
		l_nUnits = 1
	CASE &lp_cRaAlias..ra_multipl = 5
		l_nUnits = lp_nChilds2
	CASE &lp_cRaAlias..ra_multipl = 6
		l_nUnits = lp_nChilds3
	CASE &lp_cRaAlias..ra_multipl = 7
		l_nUnits = 0
	OTHERWISE
		l_nUnits = 1
ENDCASE

RETURN l_nUnits
ENDPROC
*
PROCEDURE rrsyncreser
LPARAMETERS lp_nRsId, lp_cResAlias, lp_lCheckTables
LOCAL l_oOldRes, l_oNewRes, l_nSelect

IF EMPTY(lp_nRsId)
	RETURN .F.
ENDIF
IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF

l_nSelect = SELECT()

IF (&lp_cResAlias..rs_rsid = lp_nRsId OR SEEK(lp_nRsId,lp_cResAlias,"tag33")) AND &lp_cResAlias..rs_rcsync
	IF lp_lCheckTables
		IF NOT USED("resrate")
			openfile(,"resrate")
		ENDIF
		IF NOT USED("ressplit")
			openfile(,"ressplit")
		ENDIF
	ENDIF
	CursorQuery("resrate", StrToSql("rr_reserid = %n1", &lp_cResAlias..rs_reserid))
	CursorQuery("ressplit", StrToSql("rl_rsid = %n1", &lp_cResAlias..rs_rsid))
	SELECT &lp_cResAlias
	SCATTER NAME l_oOldRes MEMO
	SCATTER NAME l_oNewRes MEMO
	RrUpdate(l_oOldRes, l_oNewRes, .T.)
	BLANK FIELDS rs_rcsync IN &lp_cResAlias
	DoTableUpdate(.F., .T., "reservat")
	DoTableUpdate(.T., .T., "resrate")
	DoTableUpdate(.T., .T., "ressplit")
	EndTransaction()
ENDIF

SELECT(l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE RlCheckRessplit
LPARAMETERS tcWhere
LOCAL loSession

loSession = CREATEOBJECT("FakePostSession")
loSession.FPCheckRessplit(tcWhere)
*loSession.FPCheckRessplit("rs_rsid = 91105")
*loSession.FPCheckRessplit("rs_arrdate <= DATE(2017,10,31) AND rs_depdate > DATE(2017,10,1) AND NOT INLIST(rs_status, 'CXL', 'NS')")
RELEASE loSession
ENDPROC
*
*
DEFINE CLASS FakePostSession AS PrivateSession OF CommonClasses.prg

PROCEDURE Init
	DODEFAULT()
	OpenFile()
	this.FakeParam()
	this.Fake("id")
	this.Fake("reservat")
	this.Fake("resrate")
	this.Fake("ressplit")
	this.Fake("post", "0=1")
	this.Fake("postchng", "0=1")
ENDPROC

PROCEDURE Destroy
	LOCAL i, lcTempDir, lcFName
	LOCAL ARRAY laSelect(1)

	lcTempDir = JUSTPATH(Filetemp())
	FOR i = 1 TO AUSED(laSelect)
		lcFName = DBF(laSelect(i,1))
		IF JUSTPATH(lcFName) == lcTempDir
			USE IN (laSelect(i,1))
			ERASE (FORCEEXT(lcFName,"*"))
		Endif
	ENDFOR
ENDPROC

PROCEDURE Fake
	LPARAMETERS tcTable, tcWhere
	LOCAL lcTemp

	tcWhere = IIF(EMPTY(tcWhere), "", "FOR " + tcWhere)
	lcTemp = Filetemp('DBF')
	SELECT &tcTable
	COPY TO (lcTemp) &tcWhere WITH CDX
	USE IN &tcTable
	USE EXCLUSIVE (lcTemp) ALIAS &tcTable IN 0
ENDPROC

PROCEDURE FPCheckRessplit
	LPARAMETERS tcWhere
	LOCAL i, lcReserId, lcRsId, lnTotalPost, lnTotalSplt, lcTmpDbf

	g_lFakeResAndPost = .T.

	SELECT reservat
	ALTER TABLE reservat ADD c_totsplt b(2) ADD c_totpost b(2)
	* Fill postings from resrate and resfix
	SCAN FOR &tcWhere
		WAIT TRANSFORM(rs_reserid)+"   "+TRANSFORM(ROUND(100 * RECNO()/RECCOUNT(),2))+"%" WINDOW NOWAIT
		CALCULATE SUM(rl_price*rl_units*IIF(EMPTY(rl_rfid),1,reservat.rs_rooms)) FOR rl_rsid = reservat.rs_rsid TO lnTotalSplt IN ressplit
		_screen.oglobal.oparam.pa_sysdate = reservat.rs_arrdate
		BLANK FIELDS rs_ratedat, rs_rfixdat
		DO RateCodePost IN RatePost WITH reservat.rs_depdate,"",,,.T.
		CALCULATE SUM(ps_amount) TO lnTotalPost FOR NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) IN post
		REPLACE c_totsplt WITH lnTotalSplt, c_totpost WITH lnTotalPost IN reservat
		DELETE ALL IN post		&& In fake post table.
		WAIT CLEAR
	ENDSCAN

	_screen.oglobal.oparam.pa_sysdate = param.pa_sysdate
	
	g_lFakeResAndPost = .F.
	lcTmpDbf = "rs"+TTOC(DATETIME(),1)
	SELECT * FROM reservat WHERE c_totsplt <> c_totpost INTO TABLE (lcTmpDbf)
ENDPROC

ENDDEFINE
*
PROCEDURE rrupdateextraandsplitprices
LPARAMETERS lp_crcsetid, lp_nPayNum
LOCAL l_dDate, l_cSql, l_nSelect, l_cRateCodeWhere, l_cCursor, l_cDateWhere

l_nSelect = SELECT()

IF PCOUNT()=2
	l_cRateCodeWhere = "rc_paynum = "+sqlcnv(lp_nPayNum,.T.)
ELSE
	l_cRateCodeWhere = "rc_rcsetid = "+sqlcnv(lp_crcsetid,.T.)
ENDIF

l_dDate = sysdate()

IF odbc()
	l_cDateWhere = "rs_depdate >= " + sqlcnv(l_dDate,.T.)
ELSE
	l_cDateWhere = "DTOS(rs_depdate)+rs_roomnum >= " + sqlcnv(DTOS(l_dDate),.T.)
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT DISTINCT rs_rsid 
	FROM reservat 
	INNER JOIN resrate ON rs_reserid = rr_reserid 
	INNER JOIN ratecode ON CAST(SUBSTR(rr_ratecod,1,10) AS Character(10)) = rc_ratecod AND <<l_cRateCodeWhere>> 
	WHERE <<l_cDateWhere>> AND NOT rs_rcsync AND rs_status NOT IN ('OUT','CXL','NS ','LST') AND 
	(rs_ratedat = __EMPTY_DATE__ OR rs_ratedat < rs_depdate-1) 
	AND NOT rs_ratecod IN ('DUM       ','COMP      ')
ENDTEXT

l_cCursor = sqlcursor(l_cSql)
FNDoEvents()
IF USED(l_cCursor) AND RECCOUNT(l_cCursor)>0
	SELECT &l_cCursor
	IF odbc()
		SCAN ALL
			sqlupdate("reservat","rs_rsid = " + sqlcnv(rs_rsid,.T.),"rs_rcsync = (1=1)")
		ENDSCAN
	ELSE
		SCAN ALL
			IF SEEK(&l_cCursor..rs_rsid,"reservat","tag33") AND NOT reservat.rs_rcsync
				REPLACE rs_rcsync WITH .T. IN reservat && Mark to update prices in ressplit and resrate later
			ENDIF
		ENDSCAN
		DoTableUpdate(.T., .T., "reservat")
		EndTransaction()
	ENDIF
ENDIF

dclose(l_cCursor)
FNDoEvents()

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE rrgetmainartinum
LPARAMETERS lp_oResRate
IF param2.pa_radetai
	LOCAL l_nArtiNum
	PRIVATE p_oResRate
	p_oResRate = .NULL.
	p_oResRate = lp_oResRate
    DO RPGetMainArtiNum IN ratepost WITH ,l_nArtiNum
    p_oResRate = .NULL.
    RETURN l_nArtiNum
ELSE
    RETURN ratearti.ra_artinum
ENDIF
ENDPROC
*
PROCEDURE RrGetSplitFromMainPct
LPARAMETERS lp_oResRate, lp_nRsId, lp_cWhere
LOCAL l_nRatePct, l_nRecno, l_lCustomRA, l_cRaAlias, l_lUdRate

l_lUdRate = INLIST(lp_oResRate.rr_status, "OUS", "ORU")
l_lCustomRA = SEEK(STR(lp_nRsId,10)+lp_oResRate.rr_ratecod, "ResRart", "tag1")
l_cRaAlias = IIF(l_lCustomRA, "resrart", "ratearti")
l_nRatePct = 0
SELECT ressplit
l_nRecno = RECNO()
SCAN FOR rl_rsid = lp_nRsId AND &lp_cWhere AND rl_artityp = 2 AND NOT EMPTY(rl_raid) AND ;
		SEEK(IIF(l_lCustomRA,STR(lp_nRsId,10),"")+rl_ratecod+STR(rl_raid,10), l_cRaAlias, "tag2") AND ;
		(l_lUdRate OR NOT &l_cRaAlias..ra_package) AND &l_cRaAlias..ra_ratepct <> 0 AND &l_cRaAlias..ra_pctexma
	l_nRatePct = l_nRatePct + &l_cRaAlias..ra_ratepct
ENDSCAN
GO l_nRecno

RETURN l_nRatePct
ENDPROC
*
PROCEDURE RrSetMainSplit
LPARAMETERS lp_oResRate, lp_oNewRes, lp_cWhere
LOCAL l_nArea, l_nRecnoRR, l_nRecnoRL, l_nExtra, l_nMainPrice, l_nSplitPrice, l_nRatePct, l_lUdRate

l_nArea = SELECT()
l_nRecnoRR = RECNO("resrate")
l_nRecnoRL = RECNO("ressplit")

l_lUdRate = INLIST(lp_oResRate.rr_status, "OUS", "ORU")
l_lCustomRA = SEEK(STR(lp_oNewRes.rs_rsid,10)+lp_oResRate.rr_ratecod, "ResRart", "tag1")
l_cRaAlias = IIF(l_lCustomRA, "resrart", "ratearti")
l_nExtra = 0
CALCULATE SUM(IIF(rl_artityp = 1 OR rl_artityp = 2 AND (IIF(EMPTY(rl_raid), NOT EMPTY(rl_rfid), ;
		NOT l_lUdRate AND SEEK(IIF(l_lCustomRA,STR(lp_oNewRes.rs_rsid,10),"")+rl_ratecod+STR(rl_raid,10), l_cRaAlias, "tag2") AND &l_cRaAlias..ra_package)), rl_price * rl_units, 0)), ;
		SUM(IIF(rl_artityp = 2, rl_price * rl_units, 0)) ;
	FOR rl_rsid = lp_oNewRes.rs_rsid AND &lp_cWhere ;
	TO l_nMainPrice, l_nSplitPrice ;
	IN ressplit
l_nRatePct = RrGetSplitFromMainPct(lp_oResRate, lp_oNewRes.rs_rsid, lp_cWhere)
SELECT ressplit
SCAN FOR rl_rsid = lp_oNewRes.rs_rsid AND &lp_cWhere AND INLIST(rl_artityp, 2, 3) AND NOT EMPTY(rl_raid) AND ;
		SEEK(IIF(l_lCustomRA,STR(lp_oNewRes.rs_rsid,10),"")+rl_ratecod+STR(rl_raid,10), l_cRaAlias, "tag2") AND ;
		NOT &l_cRaAlias..ra_package AND &l_cRaAlias..ra_ratepct <> 0 AND &l_cRaAlias..ra_pctexma
	REPLACE rl_price WITH ROUND((l_nMainPrice-l_nSplitPrice) * &l_cRaAlias..ra_ratepct/(100+l_nRatePct), 6)
	DO CASE
		CASE &l_cRaAlias..ra_artityp = 2
			l_nSplitPrice = l_nSplitPrice + rl_price * rl_units
		CASE &l_cRaAlias..ra_artityp <> 3
		CASE lp_oResRate.rr_date = ressplit.rl_rdate
			l_nExtra = l_nExtra + rl_price * rl_units / EVL(lp_oResRate.rr_curcoef,1)
		OTHERWISE
			REPLACE rr_rateex WITH resrate.rr_rateex + ressplit.rl_price * ressplit.rl_units / EVL(resrate.rr_curcoef,1) ;
				FOR rr_reserid = lp_oNewRes.rs_reserid AND rr_date = ressplit.rl_rdate IN resrate
	ENDCASE
ENDSCAN
REPLACE rl_price WITH l_nMainPrice-l_nSplitPrice FOR rl_rsid = lp_oNewRes.rs_rsid AND &lp_cWhere AND rl_artityp = 1

GO l_nRecnoRR IN resrate
GO l_nRecnoRL IN ressplit
SELECT (l_nArea)

RETURN l_nExtra
ENDPROC
*
PROCEDURE RrGetCurrencyrate
LPARAMETERS lp_oResRate, lp_oNewRes, lp_cRcPayNum
LOCAL l_nCurrencyrate, l_nPmRate

DO CASE
	CASE EMPTY(lp_cRcPayNum)
		l_nCurrencyrate = 1.00
	CASE NOT EMPTY(lp_oNewRes.rs_ratexch)
		l_nCurrencyrate = lp_oNewRes.rs_ratexch
	OTHERWISE
		l_nPmRate = DLookUp("paymetho", "pm_paynum = "+SqlCnv(lp_cRcPayNum), "pm_rate")
		l_nCurrencyrate = EVL(l_nPmRate, 1.00)
ENDCASE

RETURN l_nCurrencyrate
ENDPROC
*
FUNCTION RRGetMonthPostDate
* ratcode alias is expected to be open, and to be selected right record in table!
LPARAMETERS lp_dForDate, lp_dRcStartDate, lp_dRcEndDate, lp_dFirstDate, lp_dLastDate
LOCAL l_nOnDay, l_dPostDate

l_nOnDay = IIF(ratecode.rc_rhytm = 6, MAX(0,ratecode.rc_moposon), 0)
l_nOnDay = EVL(l_nOnDay,DAY(lp_dRcStartDate))
l_nOnDay = MIN(l_nOnDay, LastDay(lp_dForDate))
l_dPostDate = GetRelDate(lp_dForDate,,l_nOnDay)
IF lp_dForDate < l_dPostDate
	lp_dFirstDate = GetRelDate(l_dPostDate,"-1M")
	lp_dLastDate = l_dPostDate - 1
ELSE
	lp_dFirstDate = l_dPostDate
	lp_dLastDate = GetRelDate(l_dPostDate,"+1M") - 1
ENDIF
IF PCOUNT() < 4
	l_dPostDate = lp_dFirstDate
ENDIF

RETURN l_dPostDate
ENDFUNC
*
PROCEDURE RRForceResSplitUpdate
LOCAL l_oOldRes, l_oNewRes
SELECT reservat
SCATTER NAME l_oNewRes MEMO
SCATTER NAME l_oOldRes MEMO
l_oOldRes.rs_arrdate = IIF(RECNO() < 0, {}, OLDVAL("rs_arrdate","reservat"))
l_oOldRes.rs_depdate = IIF(RECNO() < 0, {}, OLDVAL("rs_depdate","reservat"))
DO RrUpdate IN ProcResRate WITH l_oOldRes, l_oNewRes, .T.
RETURN .T.
ENDPROC
