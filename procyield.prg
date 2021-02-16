*
#INCLUDE "common\progs\cryptor.h"
*
FUNCTION ProcYield
LPARAMETERS tcFuncName, tuParam1, tuParam2, tuParam3, tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10
LOCAL lcCallProc, lnParamNo, luRetVal

lcCallProc = tcFuncName + "("
FOR lnParamNo = 1 TO PCOUNT()-1
	lcCallProc = lcCallProc + IIF(lnParamNo = 1, "", ", ") + "@tuParam" + ALLTRIM(STR(lnParamNo))
NEXT
lcCallProc = lcCallProc + ")"
luRetVal = &lcCallProc
RETURN luRetVal
ENDFUNC
*
PROCEDURE RyInitialize
LPARAMETERS toReservat
LOCAL i, llMakeOffer, lnYieldCondId, ldDate, lcRatecode, lnRate, lnOccupancyPct, loYioffer, lcSql, lcCurYieldmng, loYicond

FOR i = 1 TO ALEN(toReservat.aResyield,1)
	IF NOT EMPTY(toReservat.aResyield[i,1])
		llMakeOffer = .T.
		EXIT
	ENDIF
NEXT
IF NOT llMakeOffer
	toReservat.rs_yoid = 0
	toReservat.rs_ratecod = STRTRAN(toReservat.rs_ratecod, "*")
	RETURN .F.
ENDIF

SELECT yioffer
SCATTER NAME loYioffer MEMO BLANK
loYioffer.yo_yoid = NextId('YIOFFER')
loYioffer.yo_rsid = toReservat.rs_rsid
loYioffer.yo_from = toReservat.rs_arrdate
loYioffer.yo_to = toReservat.rs_depdate
loYioffer.yo_roomtyp = IIF(EMPTY(toReservat.rs_roomtyp), "*", toReservat.rs_roomtyp)
loYioffer.yo_rooms = toReservat.rs_rooms
loYioffer.yo_adults = toReservat.rs_adults
loYioffer.yo_childs = toReservat.rs_childs
loYioffer.yo_childs2 = toReservat.rs_childs2
loYioffer.yo_childs3 = toReservat.rs_childs3
loYioffer.yo_created = DATETIME()
loYioffer.yo_sysdate = g_sysdate
loYioffer.yo_userid = g_userid
INSERT INTO yioffer FROM NAME loYioffer
toReservat.rs_yoid = loYioffer.yo_yoid

IF NOT EMPTY(toReservat.rs_ratecod)
	toReservat.rs_ratecod = "*" + CHRTRAN(toReservat.rs_ratecod,"!*", "")
ENDIF
FOR i = 1 TO ALEN(toReservat.aResyield,1)
	DO CASE
		CASE EMPTY(toReservat.aResyield[i,1])
			LOOP
		CASE DLocate("yicond", "yc_yoid = " + SqlCnv(loYioffer.yo_yoid,.T.) + " AND yc_yrid = " + SqlCnv(toReservat.aResyield[i,1],.T.))
			lnYieldCondId = yicond.yc_ycid
		OTHERWISE
			TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
				SELECT ym_avail, ym_avltype, ym_avlhot, ym_days, ym_daytype, ym_prcpct, ym_prcpct2, ym_prcpct3, ym_prcunit, ym_round FROM rcyield
					INNER JOIN yieldmng ON yr_ymid = ym_ymid
					WHERE yr_yrid = <<SqlCnv(toReservat.aResyield[i,1],.T.)>>
			ENDTEXT
			lcCurYieldmng = SqlCursor(lcSql)
			
			SELECT yicond
			SCATTER NAME loYicond MEMO BLANK
			lnYieldCondId = NextId('YICOND')
			loYicond.yc_ycid = lnYieldCondId
			loYicond.yc_yoid = loYioffer.yo_yoid
			loYicond.yc_yrid = toReservat.aResyield[i,1]
			loYicond.yc_avail = &lcCurYieldmng..ym_avail
			loYicond.yc_avltype = &lcCurYieldmng..ym_avltype
			loYicond.yc_avlhot = &lcCurYieldmng..ym_avlhot
			loYicond.yc_days = &lcCurYieldmng..ym_days
			loYicond.yc_daytype = &lcCurYieldmng..ym_daytype
			DO CASE
				CASE loYioffer.yo_adults > 2 AND NOT EMPTY(&lcCurYieldmng..ym_prcpct3)
					loYicond.yc_prcpct = &lcCurYieldmng..ym_prcpct3
				CASE loYioffer.yo_adults > 1 AND NOT EMPTY(&lcCurYieldmng..ym_prcpct2)
					loYicond.yc_prcpct = &lcCurYieldmng..ym_prcpct2
				OTHERWISE
					loYicond.yc_prcpct = &lcCurYieldmng..ym_prcpct
			ENDCASE
			loYicond.yc_prcunit = &lcCurYieldmng..ym_prcunit
			loYicond.yc_round = &lcCurYieldmng..ym_round
			loYicond.yc_prcset = toReservat.nPriceSetting

			INSERT INTO yicond FROM NAME loYicond
	ENDCASE
	ldDate = toReservat.aResyield[i,2]
	lcRatecode = toReservat.aResyield[i,3]
	lnRate = toReservat.aResyield[i,4]
	lnOccupancyPct = IIF(yicond.yc_avlhot, 100-toReservat.aResyield[i,7], toReservat.aResyield[i,5])

	RatecodeLocate(ldDate, lcRatecode, toReservat.rs_roomtyp, toReservat.rs_arrdate)
	lcRatecode = ratecode.rc_ratecod+ratecode.rc_roomtyp+DTOS(ratecode.rc_fromdat)+ratecode.rc_season
	INSERT INTO resyield (ry_ryid, ry_yoid, ry_ycid, ry_date, ry_ratecod, ry_rate, ry_occup) ;
		VALUES (NextId('RESYIELD'), toReservat.rs_yoid, lnYieldCondId, ldDate, lcRatecode, lnRate, lnOccupancyPct)
NEXT

RETURN .T.
ENDPROC
*
FUNCTION RyOfferValid
LPARAMETERS tcResAlias, tdFromDate, tdToDate, tnAdults, tnChilds, tnChilds2, tnChilds3, tcRoomType, tcRateCode, tnRate
LOCAL lnOfferState, lcRcRoomtypes, lnOccupiedRoomsCount, lnRoomsCount, llInterval

lnOfferState = -1
llInterval = (VARTYPE(tdFromDate)="D")
IF NOT llInterval
	tnAdults = &tcResAlias..rs_adults
	tnChilds = &tcResAlias..rs_childs
	tnChilds2 = &tcResAlias..rs_childs2
	tnChilds3 = &tcResAlias..rs_childs3
	tcRoomType = &tcResAlias..rs_roomtyp
	tcRateCode = &tcResAlias..rs_ratecod
	tnRate = &tcResAlias..rs_rate
ENDIF

DO CASE
	CASE EMPTY(&tcResAlias..rs_yoid) OR NOT DLocate("yioffer", "yo_yoid = " + SqlCnv(&tcResAlias..rs_yoid,.T.)) OR yioffer.yo_to <= SysDate()
		lnOfferState = 0
	CASE &tcResAlias..rs_arrdate >= yioffer.yo_to
	CASE &tcResAlias..rs_depdate <= yioffer.yo_from
	CASE NOT INLIST(yioffer.yo_roomtyp, "*", tcRoomType)
	CASE llInterval AND (tdFromDate > yioffer.yo_to OR tdToDate < yioffer.yo_from)
		lnOfferState = 0
	CASE &tcResAlias..rs_rooms > yioffer.yo_rooms
	CASE tnAdults > yioffer.yo_adults
	CASE tnChilds > yioffer.yo_childs
	CASE tnChilds2 > yioffer.yo_childs2
	CASE tnChilds3 > yioffer.yo_childs3
	CASE NOT llInterval AND &tcResAlias..rs_arrdate < yioffer.yo_from
		lnOfferState = 1
	CASE NOT DLocate("resyield", "ry_yoid = " + SqlCnv(&tcResAlias..rs_yoid,.T.) + " AND ry_date = " + SqlCnv(MAX(SysDate(),&tcResAlias..rs_arrdate),.T.))
	CASE PADR(tcRateCode,10) <> "*"+LEFT(resyield.ry_ratecod,9)
	CASE (NOT llInterval AND tnRate <> resyield.ry_rate) OR (llInterval AND ;
			DLocate("resyield", "ry_yoid = " + SqlCnv(&tcResAlias..rs_yoid,.T.) + " AND BETWEEN(ry_date, " + SqlCnv(tdFromDate,.T.) + ;
			", " + SqlCnv(tdToDate,.T.) + ") AND ry_rate <> " + SqlCnv(tnRate,.T.)))
	OTHERWISE
		lnOfferState = 0
		* Here can be added code to validate if occupancy changed meanwhile.

*!*			RatecodeLocate(resyield.ry_date, tcRateCode, tcRoomType)
*!*			lcRcRoomtypes = ProcRatecode("GetRcRoomtypes", ratecode.rc_rcsetid, .T.)
*!*			ProcRatecode("GetHotelRoomsCount", resyield.ry_date, lcRcRoomtypes, @lnRoomsCount, @lnOccupiedRoomsCount, ;
*!*				NVL(OLDVAL("rs_roomtyp","reservat"),""), NVL(OLDVAL("rs_rooms","reservat"),0))
*!*			IF yioffer.yo_avltype = 0 AND ROUND(MAX((lnOccupiedRoomsCount/lnRoomsCount)*100,0),2) <= yioffer.yo_avail OR ;
*!*					yioffer.yo_avltype = 1 AND ROUND(MAX((lnOccupiedRoomsCount/lnRoomsCount)*100,0),2) >= yioffer.yo_avail
*!*				lnOfferState = .T.
*!*			ENDIF
ENDCASE

RETURN lnOfferState
ENDFUNC
*