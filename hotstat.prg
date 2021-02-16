*
PROCEDURE HotStat
DoForm("frmHotstat", "forms\ViewHotStat")
RETURN .T.
ENDPROC
*
PROCEDURE ReadData
PARAMETERS pnLow, pnHigh, paHsData, paToDay, paVirtRt, paForecast
EXTERNAL ARRAY paHsData, paToDay, paVirtRt, paForecast
LOCAL j, l_nArea, l_nRooms
PRIVATE p_dResultFirstDate, p_dResultLastDate, pnDays, pcurAvailab, plBuildingFilter

WAIT WINDOW NOWAIT "Reading data..."
l_nArea = SELECT()

p_dResultFirstDate = dFirst + pnLow - 1
p_dResultLastDate = dFirst + pnHigh - 1
pnDays = p_dResultLastDate - p_dResultFirstDate + 1
plBuildingFilter = (cBuildingExp <> "1=1")

DIMENSION paToDay[4], paHsData[23,4+pnDays], paVirtRt[1,4+pnDays], paForecast[1,4+pnDays]
STORE 0 TO paToDay, paHsData, paVirtRt, paForecast

DIMENSION p_aRsDef(pnDays), p_aRsOpt(pnDays), p_aAllotted(pnDays)
DIMENSION p_aPicked(pnDays), p_aOoo(pnDays), p_aOos(pnDays)
DIMENSION p_aRmsArr(pnDays), p_aPrsArr(pnDays), p_aRmsIn(pnDays)
DIMENSION p_aPrsIn(pnDays), p_aRmsDep(pnDays), p_aPrsDep(pnDays)
DIMENSION p_aCnfRms1(pnDays), p_aCnfRms2(pnDays), p_aCnfRms3(pnDays)
DIMENSION p_aCnfPrs1(pnDays), p_aCnfPrs2(pnDays), p_aCnfPrs3(pnDays)
STORE 0 TO p_aRsDef, p_aRsOpt, p_aAllotted, p_aPicked, p_aOoo, p_aOos
STORE 0 TO p_aRmsArr, p_aPrsArr, p_aRmsIn, p_aPrsIn, p_aRmsDep, p_aPrsDep
STORE 0 TO p_aCnfPrs1, p_aCnfPrs2, p_aCnfPrs3, p_aCnfRms1, p_aCnfRms2, p_aCnfRms3

IF _screen.oGlobal.lVehicleRentMode AND plBuildingFilter
     pcurAvailab = SqlCursor("SELECT availab.*, rt_group, rt_vwshow, rt_vwsum, rt_vwsize FROM availab " + ;
                                   "INNER JOIN roomtype ON rt_roomtyp = av_roomtyp " + ;
                                   "WHERE av_date BETWEEN " + SqlCnv(p_dResultFirstDate,.T.) + " AND " + SqlCnv(p_dResultLastDate,.T.) + " AND " + cBuildingExp,,,,,,,.T.)
     INDEX ON av_roomtyp TAG av_roomtyp
     INDEX ON av_date TAG av_date
     SET ORDER TO
     IF NOT _screen.oGlobal.lVehicleRentModeOffsetInAvailab
          VehicleRent("VehicleRentFixAvailability", p_dResultFirstDate, p_dResultLastDate, pcurAvailab)
     ENDIF
ELSE
     pcurAvailab = ""
     l_nRooms = Get_rm_room_count("(rt_group = 1 OR rt_group = 4 AND rt_vwshow) AND rt_vwsum AND rt_vwsize > 0 AND " + cBuildingExp)
ENDIF

HotelStat_Captions()
HotelStat_OutOfOrder()
HotelStat_OutOfService()
HotelStat_Allotments()
IF dFirst = SysDate()
     HotelStat_ArrivalsDepartures_For_Sysdate()
ENDIF
HotelStat_Reservation_Occupancy()

FOR j = 1 TO pnDays
     IF _screen.oGlobal.lVehicleRentMode AND plBuildingFilter
          CALCULATE SUM(av_avail+av_ooorder) ;
               FOR av_date = p_dResultFirstDate+j-1 AND (rt_group = 1 OR rt_group = 4 AND rt_vwshow) AND rt_vwsum AND rt_vwsize > 0 ;
               TO paHsData(1,4+j) ;
               IN &pcurAvailab
     ELSE
          paHsData(1,4+j) = l_nRooms
     ENDIF
     paHsData(2,4+j) = p_aOoo(j) + p_aOos(j)
     paHsData(3,4+j) = paHsData(1,4+j) - paHsData(2,4+j) + IIF(_screen.oGlobal.oParam2.pa_oosdef, 0, p_aOos(j))
     paHsData(4,4+j) = p_aRsDef(j)
     paHsData(5,4+j) = paHsData(3,4+j) - paHsData(4,4+j)
     paHsData(6,4+j) = p_aRsOpt(j)
     paHsData(7,4+j) = MAX(ROUND(p_aAllotted(j) - p_aPicked(j), 0), 0)
     paHsData(8,4+j) = paHsData(5,4+j) - IIF(_screen.oGlobal.oParam.pa_optidef, paHsData(6,4+j), 0) - IIF(_screen.oGlobal.oParam.pa_allodef, paHsData(7,4+j), 0)
     paHsData(9,4+j) = paHsData(4,4+j) + paHsData(6,4+j)
     paHsData(10,4+j) = ROUND(IIF(paHsData(3,4+j) = 0, 0, 100 * paHsData(4,4+j) / paHsData(3,4+j)), 1)
     paHsData(11,4+j) = ROUND(IIF(paHsData(3,4+j) = 0, 0, 100 * (paHsData(3,4+j) - paHsData(8,4+j)) / paHsData(3,4+j)), 1)
     paHsData(12,4+j) = p_aRmsArr(j)
     paHsData(13,4+j) = p_aPrsArr(j)
     paHsData(14,4+j) = p_aRmsIn(j)
     paHsData(15,4+j) = p_aPrsIn(j)
     paHsData(16,4+j) = p_aRmsDep(j)
     paHsData(17,4+j) = p_aPrsDep(j)
     paHsData(18,4+j) = p_aCnfRms1(j)
     paHsData(19,4+j) = p_aCnfPrs1(j)
     paHsData(20,4+j) = p_aCnfRms2(j)
     paHsData(21,4+j) = p_aCnfPrs2(j)
     paHsData(22,4+j) = p_aCnfRms3(j)
     paHsData(23,4+j) = p_aCnfPrs3(j)
NEXT

HotelStat_VirtRt()
HotelStat_Forecast()
DClose(pcurAvailab)

SELECT (l_nArea)
WAIT CLEAR

RETURN
ENDPROC
*
PROCEDURE HotelStat_Captions
LOCAL i

paHsData[1,1] = GetLangText("HOTSTAT","T_ROOMS")+' '+GetLangText("HOTSTAT","T_TOTAL")
paHsData[2,1] = GetLangText("HOTSTAT","T_ROOMS")+' '+GetLangText("HOTSTAT","T_OOO")+' '+GetLangText("HOTSTAT","T_OR_OOS")
paHsData[3,1] = GetLangText("HOTSTAT","T_ROOMS")+' '+GetLangText("HOTSTAT","T_TORENT")
paHsData[4,1] = GetLangText("HOTSTAT","T_RES")+' '+GetLangText("HOTSTAT","T_DEFINIT")
paHsData[5,1] = GetLangText("HOTSTAT","T_ROOMS")+' '+GetLangText("HOTSTAT","T_AVMAX")
paHsData[6,1] = GetLangText("HOTSTAT","T_RES")+' '+GetLangText("HOTSTAT","T_OPTION")
paHsData[7,1] = GetLangText("HOTSTAT","T_RES")+' '+GetLangText("HOTSTAT","T_INALLT")
paHsData[8,1] = GetLangText("HOTSTAT","T_ROOMS")+' '+GetLangText("HOTSTAT","T_AVMIN")
paHsData[9,1] = GetLangText("HOTSTAT","T_RES")+' '+GetLangText("HOTSTAT","T_TOTAL")
paHsData[10,1] = GetLangText("HOTSTAT","T_OCCMIN")
paHsData[11,1] = GetLangText("HOTSTAT","T_OCCMAX")
paHsData[12,1] = GetLangText("HOTSTAT","T_ARRS")+' '+GetLangText("HOTSTAT","T_RMS")
paHsData[13,1] = GetLangText("HOTSTAT","T_ARRS")+' '+GetLangText("HOTSTAT","T_PERS")
paHsData[14,1] = GetLangText("HOTSTAT","T_INHOUSE")+' '+GetLangText("HOTSTAT","T_RMS")
paHsData[15,1] = GetLangText("HOTSTAT","T_INHOUSE")+' '+GetLangText("HOTSTAT","T_PERS")
paHsData[16,1] = GetLangText("HOTSTAT","T_DEPS")+' '+GetLangText("HOTSTAT","T_RMS")
paHsData[17,1] = GetLangText("HOTSTAT","T_DEPS")+' '+GetLangText("HOTSTAT","T_PERS")
paHsData[18,1] = GetLangText("HOTSTAT","T_CONFRMS")+' <'+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt1, 2)), 2, '0')+':00'
paHsData[19,1] = GetLangText("HOTSTAT","T_CONF")+' '+GetLangText("HOTSTAT","T_PERS")+' <'+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt1, 2)), 2, '0')+':00'
paHsData[20,1] = GetLangText("HOTSTAT","T_CONFRMS")+' '+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt1, 2)), 2, '0')+':00'+'-'+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt2, 2)), 2, '0')+':00'
paHsData[21,1] = GetLangText("HOTSTAT","T_CONF")+' '+GetLangText("HOTSTAT","T_PERS")+' '+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt1, 2)), 2, '0')+':00'+'-'+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt2, 2)), 2, '0')+':00'
paHsData[22,1] = GetLangText("HOTSTAT","T_CONFRMS")+' >'+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt2, 2)), 2, '0')+':00'
paHsData[23,1] = GetLangText("HOTSTAT","T_CONF")+' '+GetLangText("HOTSTAT","T_PERS")+' >'+ PADL(LTRIM(STR(_screen.oGlobal.oParam.pa_dayprt2, 2)), 2, '0')+':00'
FOR i = 1 TO 23
     paHsData[i,2] = ICASE(i=5, RGB(255,0,0), i=8, RGB(0,0,255), BETWEEN(i,12,17), RGB(255,255,0), BETWEEN(i,18,23), RGB(0,255,255), RGB(255,255,255))
     paHsData[i,3] = IIF(INLIST(i,5,8), RGB(255,255,255), RGB(0,0,0))
     paHsData[i,4] = IIF(INLIST(i,10,11), 1, 0)
NEXT
ENDPROC
*
PROCEDURE HotelStat_OutOfOrder
LOCAL lnArea, lcSql, lcurOutoford, lnRooms, ldDate

lnArea = SELECT()

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT oo_roomnum, oo_fromdat, oo_todat, roomtype.* FROM outoford
     LEFT JOIN room ON rm_roomnum = oo_roomnum
     LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp
     WHERE oo_fromdat <= <<SqlCnv(p_dResultLastDate,.T.)>> AND oo_todat > <<SqlCnv(p_dResultFirstDate,.T.)>> AND NOT oo_cancel AND <<cBuildingExp>>
ENDTEXT
lcurOutoford = SqlCursor(lcSql)
SCAN
     lnRooms = NumLinks(oo_roomnum)
     IF NOT EMPTY(lnRooms)
          ldDate = oo_fromdat
          DO WHILE ldDate < oo_todat
               AddToField(@p_aOoo, lnRooms, ldDate)
               ldDate = ldDate + 1
          ENDDO
     ENDIF
ENDSCAN
DClose(lcurOutoford)

SELECT (lnArea)
ENDPROC
*
PROCEDURE HotelStat_OutOfService
LOCAL lnArea, lcSql, lcurOutofser, lnRooms, ldDate

lnArea = SELECT()

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT os_roomnum, os_fromdat, os_todat, roomtype.* FROM outofser
     LEFT JOIN room ON rm_roomnum = os_roomnum
     LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp
     WHERE os_fromdat <= <<SqlCnv(p_dResultLastDate,.T.)>> AND os_todat > <<SqlCnv(p_dResultFirstDate,.T.)>> AND NOT os_cancel AND <<cBuildingExp>>
ENDTEXT
lcurOutofser = SqlCursor(lcSql)
SCAN
     lnRooms = NumLinks(os_roomnum)
     IF NOT EMPTY(lnRooms)
          ldDate = os_fromdat
          DO WHILE ldDate < os_todat
               AddToField(@p_aOos, lnRooms, ldDate)
               ldDate = ldDate + 1
          ENDDO
     ENDIF
ENDSCAN
DClose(lcurOutofser)

SELECT (lnArea)
ENDPROC
*
PROCEDURE HotelStat_Allotments
LOCAL lnArea, lcSql, lcurAltsplit

lnArea = SELECT()

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT as_rooms, as_date, as_roomtyp FROM altsplit
     LEFT JOIN roomtype ON rt_roomtyp = as_roomtyp
     WHERE as_date BETWEEN <<SqlCnv(p_dResultFirstDate,.T.)>> AND <<SqlCnv(p_dResultLastDate,.T.)>> AND
          as_rooms > 0 AND (as_roomtyp = '*' OR <<cBuildingExp>>)
ENDTEXT
lcurAltsplit = SqlCursor(lcSql)
SCAN
     AddToField(@p_aAllotted, as_rooms, as_date)
ENDSCAN
DClose(lcurAltsplit)

SELECT (lnArea)
ENDPROC
*
PROCEDURE HotelStat_ArrivalsDepartures_For_Sysdate
LOCAL lnArea, lcSql, lcurReservat, lcurResrmshr
LOCAL ldSysdate, lnRooms, lcBuildingExp
LOCAL lnArrRooms, lnArrPers, lnDepRooms, lnDepPers

lnArea = SELECT()

STORE 0 TO lnArrRooms, lnArrPers, lnDepRooms, lnDepPers
ldSysdate = SysDate()

lcBuildingExp = cBuildingExp
IF _screen.oGlobal.lVehicleRentMode AND plBuildingFilter
     cBuildingExp = STRTRAN(lcBuildingExp, "rt_buildng = ", "rs_lstart = ")
ENDIF
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT rs_rsid, rs_roomnum, rs_rooms, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_lstart, roomtype.*, NVL(ri_shareid,0) AS ri_shareid FROM reservat
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND ri_date = rs_arrdate
     LEFT JOIN roomtype ON rt_roomtyp = rs_roomtyp
     WHERE <<IIF(Odbc(), "rs_arrdate = " + SqlCnv(ldSysdate,.T.), "DTOS(rs_arrdate)+rs_lname = " + SqlCnv(DTOS(ldSysdate),.T.))>> AND
          INLIST(rs_status,'DEF','6PM','ASG') AND <<cBuildingExp>>
ENDTEXT
lcurReservat = SqlCursor(lcSql)
SCAN
     lnRooms = NumLinks(rs_roomnum)
     IF NOT EMPTY(lnRooms)
          IF EMPTY(ri_shareid)
               lnArrRooms = lnArrRooms + rs_rooms * lnRooms
          ENDIF
          IF rt_group <> 2
               lnArrPers = lnArrPers + rs_rooms * (rs_adults+rs_childs+rs_childs2+rs_childs3)
          ENDIF
     ENDIF
ENDSCAN

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT rs_rsid, rs_roomnum, rs_rooms, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_lstart, roomtype.*, NVL(ri_shareid,0) AS ri_shareid, NVL(ri_roomnum,rs_roomnum) AS ri_roomnum FROM reservat
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND ri_todate = rs_depdate-IIF(rs_arrdate<rs_depdate,1,0)
     LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp
     WHERE <<IIF(Odbc(), "rs_depdate = " + SqlCnv(ldSysdate,.T.), "DTOS(rs_depdate)+rs_roomnum = " + SqlCnv(DTOS(ldSysdate),.T.))>> AND
          rs_status = 'IN' AND <<cBuildingExp>>
ENDTEXT
SqlCursor(lcSql, lcurReservat)
SCAN
     lnRooms = NumLinks(ri_roomnum)
     IF NOT EMPTY(lnRooms)
          IF EMPTY(ri_shareid)
               lnDepRooms = lnDepRooms + rs_rooms * lnRooms
          ENDIF
          IF rt_group <> 2
               lnDepPers = lnDepPers + rs_rooms * (rs_adults+rs_childs+rs_childs2+rs_childs3)
          ENDIF
     ENDIF
ENDSCAN
cBuildingExp = lcBuildingExp

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT sd_shareid, NVL(rs_arrdate,hr_arrdate) AS rs_arrdate, NVL(rs_depdate,hr_depdate) AS rs_depdate, sd_lowdat, sd_highdat, resrmshr.* FROM sharing
     LEFT JOIN resrmshr ON sr_shareid = sd_shareid
     LEFT JOIN roomtype ON rt_roomtyp = sd_roomtyp
     LEFT JOIN resrooms ON resrooms.ri_rroomid = sr_rroomid
     LEFT JOIN reservat ON rs_reserid = resrooms.ri_reserid
     LEFT JOIN hresroom ON hresroom.ri_rroomid = sr_rroomid
     LEFT JOIN histres ON hr_reserid = hresroom.ri_reserid
     WHERE NOT sd_history AND INLIST(sd_status,'IN','DEF','6PM','ASG') AND <<cBuildingExp>> AND
          (sd_lowdat = <<SqlCnv(ldSysdate,.T.)>> OR sd_highdat = <<SqlCnv(ldSysdate-1,.T.)>>)
     ORDER BY 1,2
ENDTEXT
lcurResrmshr = SqlCursor(lcSql)
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT sd_shareid, sd_roomnum, sd_lowdat, sd_highdat, sd_status, roomtype.* FROM sharing
     LEFT JOIN roomtype ON rt_roomtyp = sd_roomtyp
     WHERE NOT sd_history AND INLIST(sd_status,'IN','DEF','6PM','ASG') AND <<cBuildingExp>> AND
          (sd_lowdat = <<SqlCnv(ldSysdate,.T.)>> OR sd_highdat = <<SqlCnv(ldSysdate-1,.T.)>>)
ENDTEXT
SqlCursor(lcSql, lcurReservat)
SCAN
     lnRooms = NumLinks(sd_roomnum)
     IF NOT EMPTY(lnRooms)
          IF INLIST(sd_status,"DEF","6PM","ASG") AND sd_lowdat = ldSysdate AND ;
                    DLocate(lcurResrmshr, "sr_shareid = " + SqlCnv(sd_shareid,.T.) + " AND sd_lowdat = rs_arrdate AND rs_arrdate = " + SqlCnv(ldSysdate,.T.))
               lnArrRooms = lnArrRooms + lnRooms
          ENDIF
          IF sd_status = "IN" AND sd_highdat+1 = ldSysdate AND ;
                    DLocate(lcurResrmshr, "sr_shareid = " + SqlCnv(sd_shareid,.T.) + " AND sd_highdat = rs_depdate-1 AND rs_depdate = " + SqlCnv(ldSysdate,.T.))
               lnDepRooms = lnDepRooms + lnRooms
          ENDIF
     ENDIF
ENDSCAN

paToDay[1] = lnArrRooms
paToDay[2] = lnArrPers
paToDay[3] = lnDepRooms
paToDay[4] = lnDepPers

DClose(lcurReservat)
DClose(lcurResrmshr)

SELECT (lnArea)
ENDPROC
*
PROCEDURE HotelStat_Reservation_Occupancy
LOCAL lnArea, lcSql, lcurReservat, lcurResrate, lcurResrate, lcurSharing, lcurResrmshr
LOCAL lnReserId, llAddtArrInDep, ldLastTodate, ldDate, ltStarthr, ltDayprt1, ltDayprt2, ltArrival, ltDeparture
LOCAL lnRooms, lnLastRooms, lnPersons, lnLastPersons, llAddPersons, llLastAddPersons, lnShareId, lnLastShareId, lcBuildingExp
PRIVATE p_oDetermineDayPart
p_oDetermineDayPart = NULL

lnArea = SELECT()

lcBuildingExp = cBuildingExp
IF _screen.oGlobal.lVehicleRentMode AND plBuildingFilter
     cBuildingExp = STRTRAN(lcBuildingExp, "rt_buildng = ", "rs_lstart = ")
ENDIF

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT rs_reserid, rs_arrdate, rs_depdate, rs_lstart, rs_arrtime, rs_deptime, rs_roomnum, rs_rooms, rs_altid, rs_status, rs_adults, rs_childs, rs_childs2, rs_childs3,
     NVL(ri_date,rs_arrdate) AS ri_date, NVL(ri_todate,rs_depdate-IIF(rs_arrdate<rs_depdate,1,0)) AS ri_todate, NVL(ri_shareid,0) AS ri_shareid,
     NVL(ri_roomnum,rs_roomnum) AS ri_roomnum, NVL(ri_roomtyp,rs_roomtyp) AS ri_roomtyp, roomtype.* 
     FROM reservat
     LEFT JOIN resrooms ON ri_reserid = rs_reserid
     LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp
     WHERE <<IIF(Odbc(), "rs_depdate >= " + SqlCnv(p_dResultFirstDate,.T.), "DTOS(rs_depdate)+rs_roomnum >= " + SqlCnv(DTOS(p_dResultFirstDate),.T.))>> AND
          <<IIF(Odbc(), "rs_arrdate < " + SqlCnv(p_dResultLastDate+1,.T.), "DTOS(rs_arrdate)+rs_lname < " + SqlCnv(DTOS(p_dResultLastDate+1),.T.))>> AND
          NOT INLIST(rs_status, 'NS', 'CXL', 'LST') AND (rt_group = 2 OR rs_arrdate < rs_depdate)
     ORDER BY rs_arrdate, rs_reserid, ri_date
ENDTEXT
lcurReservat = SqlCursor(lcSql)

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT rr_reserid, rr_date, rr_adults, rr_childs, rr_childs2, rr_childs3
     FROM reservat
     LEFT JOIN resrate ON rr_reserid = rs_reserid
     WHERE <<IIF(Odbc(), "rs_depdate >= " + SqlCnv(p_dResultFirstDate,.T.), "DTOS(rs_depdate)+rs_roomnum >= " + SqlCnv(DTOS(p_dResultFirstDate),.T.))>> AND
          <<IIF(Odbc(), "rs_arrdate < " + SqlCnv(p_dResultLastDate+1,.T.), "DTOS(rs_arrdate)+rs_lname < " + SqlCnv(DTOS(p_dResultLastDate+1),.T.))>> AND
          NOT INLIST(rs_status, 'NS', 'CXL', 'LST')
     ORDER BY rr_reserid, rr_date
ENDTEXT
lcurResrate = SqlCursor(lcSql)
INDEX ON STR(rr_reserid,12,3)+DTOS(rr_date) TAG rr_date

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT sd_shareid, sd_lowdat, sd_highdat, sd_roomnum, sd_roomtyp, sd_status, roomtype.*
     FROM sharing
     LEFT JOIN roomtype ON rt_roomtyp = sd_roomtyp
     WHERE NOT sd_history AND sd_lowdat <> __EMPTY_DATE__ AND sd_status <> 'LST' AND
          sd_lowdat <= <<SqlCnv(p_dResultLastDate,.T.)>> AND sd_highdat+1 >= <<SqlCnv(p_dResultFirstDate,.T.)>>
     ORDER BY sd_shareid, sd_lowdat
ENDTEXT
lcurSharing = SqlCursor(lcSql)
INDEX ON sd_shareid TAG sd_shareid

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT NVL(rs_arrdate,hr_arrdate) AS rs_arrdate, NVL(rs_depdate,hr_depdate) AS rs_depdate, sd_lowdat, sd_highdat, resrmshr.*
     FROM sharing
     LEFT JOIN resrmshr ON sr_shareid = sd_shareid
     LEFT JOIN roomtype ON rt_roomtyp = sd_roomtyp
     LEFT JOIN resrooms ON resrooms.ri_rroomid = sr_rroomid
     LEFT JOIN reservat ON rs_reserid = resrooms.ri_reserid
     LEFT JOIN hresroom ON hresroom.ri_rroomid = sr_rroomid
     LEFT JOIN histres ON hr_reserid = hresroom.ri_reserid
     WHERE NOT sd_history AND sd_lowdat <> __EMPTY_DATE__ AND sd_status <> 'LST' AND
          sd_lowdat <= <<SqlCnv(p_dResultLastDate,.T.)>> AND sd_highdat+1 >= <<SqlCnv(p_dResultFirstDate,.T.)>>
     ORDER BY 1,2
ENDTEXT
lcurResrmshr = SqlCursor(lcSql)

IF _screen.oGlobal.oParam2.pa_connew
     p_oDetermineDayPart = NEWOBJECT("CODetermineDayPart", "procconf.prg")
ENDIF

SELECT (lcurReservat)
lnReserId = 0
lnLastRooms = 0
lnLastPersons = 0
SCAN ALL
     IF lnReserId <> rs_reserid
          IF lnLastPersons > 0
               AddToField(@p_aPrsDep, lnLastPersons, ldLastPrsTodate, llLastAddPersons AND NOT EMPTY(lnLastRooms))
               lnLastPersons = 0
          ENDIF
          IF lnLastRooms > 0
               AddToField(@p_aRmsDep, lnLastRooms, ldLastTodate, EMPTY(lnLastShareId))
               lnLastRooms = 0
          ENDIF
          lnReserId = rs_reserid
          lnLastShareId = 0
     ENDIF
     llAddtArrInDep = CountTentative(rs_status)
     lnRooms = rs_rooms * NumLinks(ri_roomnum)
     lnShareId = ri_shareid
     llAddPersons = (rt_group = 2) OR &cBuildingExp
     DO CASE
          CASE NOT llAddtArrInDep
          CASE NOT EMPTY(lnShareId) AND NOT EMPTY(lnLastShareId) 
          CASE NOT EMPTY(lnShareId)
               * Dearture rooms if Guest goes from non shared to shared room.
               IF SEEK(lnShareId, lcurSharing, "sd_shareid") AND &lcurSharing..sd_lowdat < ri_date AND lnLastRooms > 0
                    AddToField(@p_aRmsDep, lnLastRooms, ldLastTodate)
               ENDIF
          CASE NOT EMPTY(lnLastShareId)
               * Arrival rooms if Guest goes from shared to non shared room.
               IF SEEK(lnLastShareId, lcurSharing, "sd_shareid") AND &lcurSharing..sd_highdat > ri_todate AND lnRooms > 0
                    AddToField(@p_aRmsArr, lnRooms, ri_date)
               ENDIF
          CASE lnRooms > lnLastRooms
               AddToField(@p_aRmsArr, lnRooms-lnLastRooms, ri_date, EMPTY(lnShareId))
          CASE lnRooms < lnLastRooms
               AddToField(@p_aRmsDep, lnLastRooms-lnRooms, ldLastTodate, EMPTY(lnLastShareId))
          OTHERWISE
     ENDCASE
     ldDate = ri_date
     DO WHILE ldDate <= ri_todate
          IF NOT EMPTY(lnRooms)
               AddToField(@p_aPicked, lnRooms, ldDate, NOT EMPTY(rs_altid))
               IF INLIST(rs_status, "DEF", "ASG", "6PM", "IN", "OUT")
                    AddToField(@p_aRsDef, lnRooms, ldDate, EMPTY(lnShareId) AND (rt_group <> 2 OR ldDate < rs_depdate))
               ELSE
                    AddToField(@p_aRsOpt, lnRooms, ldDate, EMPTY(lnShareId) AND (rt_group <> 2 OR ldDate < rs_depdate))
               ENDIF
               IF llAddtArrInDep
                    AddToField(@p_aRmsIn, lnRooms, ldDate, EMPTY(lnShareId) AND (rt_group <> 2 OR ldDate < rs_depdate))
               ENDIF
          ENDIF
          DO CASE
               CASE SEEK(STR(rs_reserid,12,3)+DTOS(ldDate),lcurResrate,"rr_date")
                    lnPersons = rs_rooms * (&lcurResrate..rr_adults+&lcurResrate..rr_childs+&lcurResrate..rr_childs2+&lcurResrate..rr_childs3)
               OTHERWISE
                    lnPersons = rs_rooms * (rs_adults+rs_childs+rs_childs2+rs_childs3)
          ENDCASE
          IF llAddtArrInDep
               DO CASE
                    CASE lnPersons > lnLastPersons
                         AddToField(@p_aPrsArr, lnPersons-lnLastPersons, ldDate, llAddPersons AND NOT EMPTY(lnRooms))
                    CASE lnPersons < lnLastPersons
                         AddToField(@p_aPrsDep, lnLastPersons-lnPersons, ldLastPrsTodate, llLastAddPersons AND NOT EMPTY(lnLastRooms))
                    OTHERWISE
               ENDCASE
               AddToField(@p_aPrsIn, lnPersons, ldDate, llAddPersons AND NOT EMPTY(lnRooms))
          ENDIF

          IF rt_group = 2 AND INLIST(rs_status, "DEF", "ASG", "6PM", "IN", "OUT")
               IF _screen.oGlobal.oParam2.pa_connew
                    HotelStat_Conference_Occupancy(ldDate, lnPersons)
               ELSE
                    ltStarthr = DTOT(ldDate)+3600*_screen.oGlobal.oParam.pa_starthr
                    ltDayprt1 = DTOT(ldDate)+3600*_screen.oGlobal.oParam.pa_dayprt1
                    ltDayprt2 = DTOT(ldDate)+3600*_screen.oGlobal.oParam.pa_dayprt2
                    ltArrival = CTOT(DTOC(rs_arrdate)+" "+rs_arrtime)
                    ltArrival = IIF(rs_arrdate = ldDate AND ltArrival < ltStarthr, ltStarthr, ltArrival)
                    ltDeparture = IIF(EMPTY(CHRTRAN(rs_deptime,"0:","")), DTOT(rs_depdate+1), CTOT(DTOC(rs_depdate)+" "+rs_deptime))
                    IF ltArrival < ltDayprt1 AND ltDeparture > ltStarthr
                         AddToField(@p_aCnfPrs1, lnPersons, ldDate)
                         AddToField(@p_aCnfRms1, rs_rooms, ldDate)
                    ENDIF
                    IF ltArrival < ltDayprt2 AND ltDeparture > ltDayprt1
                         AddToField(@p_aCnfPrs2, lnPersons, ldDate)
                         AddToField(@p_aCnfRms2, rs_rooms, ldDate)
                    ENDIF
                    IF ltArrival < ltStarthr+86400 AND ltDeparture > ltDayprt2
                         AddToField(@p_aCnfPrs3, lnPersons, ldDate)
                         AddToField(@p_aCnfRms3, rs_rooms, ldDate)
                    ENDIF
               ENDIF
          ENDIF

          lnLastPersons = lnPersons
          ldLastPrsTodate = IIF(ldDate = MAX(rs_arrdate,rs_depdate-1), rs_depdate, ldDate)
          llLastAddPersons = llAddPersons
          ldDate = ldDate + 1
     ENDDO
     lnLastRooms = lnRooms
     ldLastTodate = IIF(ri_todate = MAX(rs_arrdate,rs_depdate-1), rs_depdate, ri_todate)
     lnLastShareId = lnShareId
ENDSCAN
IF lnLastRooms > 0
     AddToField(@p_aRmsDep, lnLastRooms, ldLastTodate, EMPTY(lnLastShareId))
ENDIF
IF lnLastPersons > 0
     AddToField(@p_aPrsDep, lnLastPersons, ldLastPrsTodate, llLastAddPersons AND NOT EMPTY(lnLastRooms))
ENDIF
cBuildingExp = lcBuildingExp

HotelStat_Sharing_Occupancy(lcurSharing, lcurResrmshr)

DClose(lcurReservat)
DClose(lcurResrate)
DClose(lcurSharing)
DClose(lcurResrmshr)

SELECT (lnArea)
ENDPROC
*
PROCEDURE HotelStat_Conference_Occupancy
LPARAMETERS tdDate, tnPersons
LOCAL lnSelect, lcCur

lnSelect = SELECT()

lcCur = sqlcursor("SELECT rr_arrtime, rr_deptime FROM resrate WHERE rr_reserid = " + sqlcnv(rs_reserid,.T.) + " AND rr_date = " + sqlcnv(tdDate, .T.))
SCAN ALL
     p_oDetermineDayPart.Do()

     SELECT (lnSelect)

     IF p_oDetermineDayPart.lPeriod1
          AddToField(@p_aCnfPrs1, tnPersons, tdDate)
          AddToField(@p_aCnfRms1, rs_rooms, tdDate)
     ENDIF
     IF p_oDetermineDayPart.lPeriod2
          AddToField(@p_aCnfPrs2, tnPersons, tdDate)
          AddToField(@p_aCnfRms2, rs_rooms, tdDate)
     ENDIF
     IF p_oDetermineDayPart.lPeriod3
          AddToField(@p_aCnfPrs3, tnPersons, tdDate)
          AddToField(@p_aCnfRms3, rs_rooms, tdDate)
     ENDIF
ENDSCAN

dclose(lcCur)

SELECT (lnSelect)

RETURN .T.
ENDPROC
*
PROCEDURE HotelStat_Sharing_Occupancy
LPARAMETERS tcurSharing, tcurResrmshr
LOCAL lnArea, ldDate, lnRooms, llAddtArrInDep

lnArea = SELECT()

SELECT (tcurSharing)
SCAN
     lnRooms = NumLinks(sd_roomnum)
     IF NOT EMPTY(lnRooms)
          llAddtArrInDep = CountTentative(sd_status)
          IF llAddtArrInDep AND DLocate(tcurResrmshr, "sr_shareid = " + SqlCnv(sd_shareid,.T.) + " AND sd_lowdat = rs_arrdate")
               AddToField(@p_aRmsArr, lnRooms, sd_lowdat)
          ENDIF
          IF llAddtArrInDep AND DLocate(tcurResrmshr, "sr_shareid = " + SqlCnv(sd_shareid,.T.) + " AND sd_highdat = rs_depdate-1")
               AddToField(@p_aRmsDep, lnRooms, sd_highdat+1)
          ENDIF
          ldDate = sd_lowdat
          DO WHILE ldDate <= sd_highdat
               IF llAddtArrInDep
                    AddToField(@p_aRmsIn, lnRooms, ldDate)
               ENDIF
               IF INLIST(sd_status, "DEF", "ASG", "6PM", "IN", "OUT")
                    AddToField(@p_aRsDef, lnRooms, ldDate)
               ELSE
                    AddToField(@p_aRsOpt, lnRooms, ldDate)
               ENDIF
               ldDate = ldDate + 1
          ENDDO
     ENDIF
ENDSCAN

SELECT (lnArea)
ENDPROC
*
PROCEDURE HotelStat_VirtRt
LOCAL i, j, lcFreeMacro, lcSql, lcurVirtRt, ltmpVirtRt, lcVirRtCaption

lcurVirtRt = SqlCursor("SELECT pl_charcod FROM picklist WHERE pl_label = 'VIRROOM   ' ORDER BY pl_charcod")
IF RECCOUNT(lcurVirtRt) > 0
     DIMENSION paVirtRt[RECCOUNT(lcurVirtRt),ALEN(paVirtRt,2)]
     lcVirRtCaption = GetLangText("HOTSTAT","TXT_VIRT_RT_AVAILABLE")
     lcFreeMacro = "av_avail - (av_definit" + ;
          IIF(_screen.oglobal.oparam.pa_allodef, "+__MAX__(av_allott - av_pick,0)", "") + ;
          IIF(_screen.oglobal.oparam.pa_optidef, "+av_option", "") + ;
          IIF(_screen.oglobal.oparam.pa_tentdef, "+av_tentat", "") + ;
          IIF(_screen.oglobal.oparam2.pa_oosdef, "+av_ooservc", "") + ")"
     TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT av_date, rt_virroom, CAST(SUM(<<lcFreeMacro>>) AS Integer) AS rfree FROM picklist
          INNER JOIN roomtype ON pl_charcod = rt_virroom
          INNER JOIN <<IIF(_screen.oGlobal.lVehicleRentMode AND plBuildingFilter, pcurAvailab, "availab")>> ON rt_roomtyp = av_roomtyp
          WHERE pl_label = 'VIRROOM   ' AND av_date BETWEEN <<SqlCnv(p_dResultFirstDate,.T.)>> AND <<SqlCnv(p_dResultLastDate,.T.)>> AND <<cBuildingExp>>
          GROUP BY 1,2
     ENDTEXT
     ltmpVirtRt = SqlCursor(lcSql,,,,,,,.T.)
     INDEX ON av_date TAG tag1

     SELECT (lcurVirtRt)
     SCAN
          i = RECNO()
          paVirtRt[i,1] = lcVirRtCaption + " " + ALLTRIM(pl_charcod)
          paVirtRt[i,2] = RGB(255,255,255)
          paVirtRt[i,3] = RGB(0,0,0)
          paVirtRt[i,4] = 0
          FOR j = 1 TO pnDays
               paVirtRt[i,4+j] = DLookUp(ltmpVirtRt, "av_date = " + SqlCnv(p_dResultFirstDate+j-1) + " AND rt_virroom = " + SqlCnv(pl_charcod), "rfree")
          NEXT
     ENDSCAN
     DClose(ltmpVirtRt)
ENDIF
DClose(lcurVirtRt)
ENDPROC
*
PROCEDURE HotelStat_Forecast
LOCAL i, j, lcRs, lcSql, lcurForecast, ltmpForecast, lcFcArtCaption

lcurForecast = SqlCursor("SELECT pl_charcod, pl_lang"+g_langnum+" AS pl_lang FROM picklist WHERE pl_label = 'FORECAST  ' AND pl_numcod <> 0 ORDER BY pl_charcod")
IF RECCOUNT(lcurForecast) > 0
     DIMENSION paForecast[RECCOUNT(lcurForecast),ALEN(paForecast,2)]
     lcFcArtCaption = GetLangText("HOTSTAT","TXT_FORECAST_ARTICLES")
     TEXT TO lcRs TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT DISTINCT rs_rsid, rs_reserid, rs_ratedat, rs_rooms FROM reservat
          INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp
          WHERE rs_arrdate <= <<SqlCnv(p_dResultLastDate, .T.)>> AND rs_depdate >= <<SqlCnv(p_dResultFirstDate, .T.)>> AND NOT INLIST(rs_status, "CXL", "NS", "LST")
               <<IIF(_screen.oGlobal.oParam.pa_optidef, "", " AND rs_status <> 'OPT'")>><<IIF(_screen.oGlobal.oParam.pa_tentdef, "", " AND rs_status <> 'TEN'")>> AND
               <<IIF(_screen.oGlobal.lVehicleRentMode AND plBuildingFilter, STRTRAN(cBuildingExp, "rt_roomtyp = ", "rs_lstart = "), cBuildingExp)>>
     ENDTEXT
     TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT ar_fcst, IIF(ps_rdate = __EMPTY_DATE__, ps_date, ps_rdate) + ar_fcstofs AS date, ps_units, CAST(IIF(ps_origid < 1, 1, NVL(rs.rs_rooms,0)) AS Numeric(3)) AS resrooms FROM post
          LEFT JOIN (<<lcRs>>) rs ON rs.rs_reserid = ps_origid
          INNER JOIN article ON ps_artinum = ar_artinum
          WHERE ps_reserid > 0 AND IIF(ps_rdate = __EMPTY_DATE__, ps_date, ps_rdate) + ar_fcstofs BETWEEN <<SqlCnv(p_dResultFirstDate,.T.)>> AND <<SqlCnv(p_dResultLastDate,.T.)>> AND
          ps_artinum > 0 AND ps_amount > 0 AND NOT ps_cancel AND (ps_ratecod = '<<SPACE(23)>>' OR ps_split) AND ar_fcst <> '   '
          UNION ALL
     SELECT ar_fcst, rl_rdate + ar_fcstofs, rl_units, CAST(NVL(rs.rs_rooms,0) AS Numeric(3)) FROM ressplit
          LEFT JOIN (<<lcRs>>) rs ON rs.rs_rsid = rl_rsid
          INNER JOIN article ON rl_artinum = ar_artinum
          WHERE rl_date > rs.rs_ratedat AND rl_rdate + ar_fcstofs BETWEEN <<SqlCnv(p_dResultFirstDate,.T.)>> AND <<SqlCnv(p_dResultLastDate,.T.)>> AND rl_units > 0 AND ar_fcst <> '   '
     ENDTEXT
     ltmpForecast = SqlCursor(lcSql)
     SELECT ar_fcst, date, SUM(ps_units*resrooms) AS units FROM (ltmpForecast) GROUP BY 1, 2 ORDER BY 1 INTO CURSOR (ltmpForecast) READWRITE
     INDEX ON date TAG Tag1

     SELECT (lcurForecast)
     SCAN
          i = RECNO()
          paForecast[i,1] = lcFcArtCaption + " " + ALLTRIM(pl_charcod) + " - " + pl_lang
          paForecast[i,2] = RGB(181,230,29)
          paForecast[i,3] = RGB(0,0,0)
          paForecast[i,4] = 0
          FOR j = 1 TO pnDays
               paForecast[i,4+j] = DLookUp(ltmpForecast, "date = " + SqlCnv(p_dResultFirstDate+j-1) + " AND ar_fcst = " + SqlCnv(pl_charcod), "units")
          NEXT
     ENDSCAN
     DClose(ltmpForecast)
ENDIF
DClose(lcurForecast)
ENDPROC
*
FUNCTION GetStart
PARAMETER pdStart,pcBuildingExp,pcTitleText
PRIVATE adLg
DIMENSION adLg[2, 8]
adLg[1, 1] = "start"
adLg[1, 2] = GetLangText("HOTSTAT","T_STARTDATE")
adLg[1, 3] = "SysDate()"
adLg[1, 4] = "!999999999"
adLg[1, 5] = siZedate()
adLg[1, 6] = "!Empty(start)"
adLg[1, 7] = ""
adLg[1, 8] = {}
adLg[2, 1] = "building"
adLg[2, 2] = GetLangText("HOTSTAT","T_BUILDING")
adLg[2, 3] = "SPACE(3)"
adLg[2, 4] = "!!!"
adLg[2, 5] = 3
adLg[2, 6] = "IIF(EMPTY(building),.T.,SEEK('BUILDING  '+building,'picklist','tag4'))"
adLg[2, 7] = ""
adLg[2, 8] = ""
IF diAlog(GetLangText("HOTSTAT","TW_STARTDATE"),'',@adLg)
     pdStart = adLg(1,8)
     IF NOT EMPTY(adLg(2,8))
          pcBuildingExp = "RoomType.rt_buildng = "+sqlcnv(TRIM(adLg(2,8)))
          pcTitleText = GetLangText("HOTSTAT", "TXT_HOTSTAT") + " " + ;
               GetLangText("HOTSTAT","TXT_FOR_BUILDING") + " " + TRIM(adLg(2,8))
     ELSE
          pcBuildingExp = "1=1"
          pcTitleText = GetLangText("HOTSTAT", "TXT_HOTSTAT")
     ENDIF
     RETURN .T.
ELSE
     RETURN .F.
ENDIF
ENDFUNC
*
FUNCTION NumLinks
LPARAMETERS tcRoomnum
LOCAL lnRetVal

DO CASE
     CASE ISNULL(rt_group) OR NOT (&cBuildingExp)
          lnRetVal = 0
     CASE EMPTY(tcRoomnum)
          lnRetVal = IIF(rt_group = 1 AND rt_vwsum OR rt_group = 4, 1, 0)
     OTHERWISE
          lnRetVal = Get_rm_rmname(tcRoomnum, "rm_roomocc")
ENDCASE

RETURN lnRetVal
ENDFUNC
*
PROCEDURE AddToField
LPARAMETERS taField, tnValue, tdDate, tExCondition
EXTERNAL ARRAY taField

IF BETWEEN(tdDate, p_dResultFirstDate, p_dResultLastDate) AND (PCOUNT() < 4 OR tExCondition)
     taField[tdDate-p_dResultFirstDate+1] = taField[tdDate-p_dResultFirstDate+1] + tnValue
ENDIF
ENDPROC
*
FUNCTION CountTentative
LPARAMETERS tcStatus

RETURN _screen.oGlobal.oParam.pa_tentdef OR tcStatus <> 'TEN'
ENDFUNC
*