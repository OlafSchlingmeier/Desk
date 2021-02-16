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
FUNCTION GetRatecode
LPARAMETERS lp_nReserid, lp_dDate, lp_cExpression
LOCAL l_uRetVal, l_cRatecode

l_cRatecode = DLookUp("resrate", StrToSql("rr_reserid = %n1 AND rr_date = %d2", lp_nReserid, lp_dDate), "rr_ratecod")       && resrate.rr_ratecod
IF EMPTY(l_cRatecode)
     l_cRatecode = DLookUp("hresrate", StrToSql("rr_reserid = %n1 AND rr_date = %d2", lp_nReserid, lp_dDate), "rr_ratecod") && hresrate.rr_ratecod
ENDIF

l_uRetVal = DLookUp("ratecode", "rc_key = [" + l_cRatecode + "]", lp_cExpression) && Using always VFP table or VFP cursor!!

RETURN l_uRetVal
ENDFUNC
*
FUNCTION RateBlocked
LPARAMETERS lp_dDate, lp_dArrdate, lp_dDepdate, lp_cRoomType
LOCAL l_cRateCode, l_vRcProp, l_oReservat, l_dPostDepDate

l_cRateCode = PADR(ratecode.rc_ratecod, 10) + PADR(ratecode.rc_roomtyp, 4) + DTOS(ratecode.rc_fromdat) + ratecode.rc_season
IF NOT USED("rateprop")
     OpenFileDirect(,"rateprop")
ENDIF
IF NOT EMPTY(lp_dDepdate)
     l_oReservat = MakeStructure("rs_arrdate,rs_depdate,rs_roomtyp")
     l_oReservat.rs_roomtyp = EVL(lp_cRoomType, "    ")
     l_oReservat.rs_arrdate = lp_dArrdate
     l_oReservat.rs_depdate = lp_dDepdate
     l_dPostDepDate = RrGetRsDepDate(l_oReservat)
ENDIF
IF NOT EMPTY(l_dPostDepDate)
     l_vRcProp = (ratecode.rc_minstay > lp_dDepdate+1 - lp_dArrdate)
ENDIF
IF NOT l_vRcProp
     l_vRcProp = RcPropGet(l_cRateCode, "BLOCK_DATE", lp_dDate)
     l_vRcProp = NVL(l_vRcProp,.F.)
ENDIF
IF NOT l_vRcProp AND NOT EMPTY(l_dPostDepDate)
     l_vRcProp = RcPropGet(l_cRateCode, "MIN_STAY_DATE", lp_dDate)
     l_vRcProp = IIF(ISNULL(l_vRcProp), .F., l_vRcProp > lp_dDepdate - lp_dArrdate)
ENDIF
IF NOT l_vRcProp
     l_vRcProp = RcPropGet(l_cRateCode, "BLOCK_DOW" + TRANSFORM(DOW(lp_dDate,2)))
     l_vRcProp = NVL(l_vRcProp,.F.)
ENDIF
IF NOT l_vRcProp
     l_vRcProp = RcPropGet(l_cRateCode, "BLOCK_ARR_DOW" + TRANSFORM(DOW(lp_dArrdate,2)))
     l_vRcProp = NVL(l_vRcProp,.F.)
ENDIF
IF NOT l_vRcProp AND VARTYPE(lp_dDepdate)="D"
     l_vRcProp = RcPropGet(l_cRateCode, "BLOCK_DEP_DOW" + TRANSFORM(DOW(lp_dDepdate,2)))
     l_vRcProp = NVL(l_vRcProp,.F.)
ENDIF

RETURN l_vRcProp
ENDFUNC
*
PROCEDURE RcPropGet
LPARAMETERS lp_cRateCode, lp_cPropName, lp_cDate, lp_vPropValue

lp_vPropValue = .NULL.
IF PCOUNT() < 3
     lp_cDate = {}
     IF PCOUNT() < 2
          RETURN lp_vPropValue
     ENDIF
ENDIF
IF USED("rateprop") AND NOT EMPTY(lp_cRateCode) AND ;
          SEEK(PADR(lp_cRateCode, 23) + PADR(lp_cPropName, 15) + ;
          DTOS(lp_cDate), "rateprop", "tag3")
     DO CASE
          CASE rateprop.rd_valtype == "N"
               lp_vPropValue = rateprop.rd_valuen
          CASE rateprop.rd_valtype == "L"
               lp_vPropValue = rateprop.rd_valuel
          CASE rateprop.rd_valtype == "D"
               lp_vPropValue = rateprop.rd_valdate
          OTHERWISE &&rd_valtype == "C"
               lp_vPropValue = rateprop.rd_valuec
     ENDCASE
ENDIF

RETURN lp_vPropValue
ENDPROC
*
PROCEDURE CalculateOccupancy
LPARAMETERS lp_dDate, lp_cRoomType, lp_aRoomCount, lp_oOldReservat
EXTERNAL ARRAY lp_aRoomCount
LOCAL l_nRoomsCount, l_nOccupiedRoomsCount

GetHotelRoomsCount(lp_dDate, "*", @l_nRoomsCount, @l_nOccupiedRoomsCount, lp_oOldReservat)
lp_aRoomCount(1) = l_nRoomsCount
lp_aRoomCount(3) = l_nOccupiedRoomsCount
GetHotelRoomsCount(lp_dDate, lp_cRoomType, @l_nRoomsCount, @l_nOccupiedRoomsCount, lp_oOldReservat)
lp_aRoomCount(2) = l_nRoomsCount
lp_aRoomCount(4) = l_nOccupiedRoomsCount
ENDPROC
*
PROCEDURE GetHotelRoomsCount
LPARAMETERS lp_dDate, lp_cRoomType, lp_nRoomsCount, lp_nOccupiedRoomsCount, lp_oOldReservat
LOCAL i, l_nArea, l_cSql, l_cWhere, l_cCurAvlOcc

l_nArea = SELECT()

IF EMPTY(lp_cRoomType) OR lp_cRoomType = "*"
     l_cWhere = ""
ELSE
     l_cWhere = " AND av_roomtyp IN ("
     FOR i = 1 TO GETWORDCOUNT(lp_cRoomType,",")
          l_cWhere = l_cWhere + IIF(i = 1, "", ",") + SqlCnv(PADR(GETWORDNUM(lp_cRoomType,i,","),4),.T.)
     NEXT
     l_cWhere = l_cWhere + ")"
ENDIF

IF DLookUp("availab", "av_date = " + SqlCnv(lp_dDate,.T.), "av_date") = lp_dDate
     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
          SELECT SUM(av_avail) AS av_avail, SUM(av_definit<<IIF(_screen.oGlobal.oParam.pa_allodef, "+__MAX__(av_allott+av_altall-av_pick,0)","")>>
               <<IIF(_screen.oGlobal.oParam.pa_optidef,"+av_option","")>><<IIF(_screen.oGlobal.oParam.pa_tentdef,"+av_tentat","")>>
               <<IIF(_screen.oGlobal.oParam2.pa_oosdef,"+av_ooservc","")>>) AS av_definit FROM availab
               INNER JOIN roomtype ON rt_roomtyp = av_roomtyp
               WHERE av_date = <<SqlCnv(lp_dDate,.T.)>><<l_cWhere>> AND rt_group <> 3
     ENDTEXT
     l_cCurAvlOcc = SqlCursor(l_cSql)
     lp_nRoomsCount = NVL(&l_cCurAvlOcc..av_avail,0)
     lp_nOccupiedRoomsCount = NVL(&l_cCurAvlOcc..av_definit,0)
     IF NOT ISNULL(EVL(lp_oOldReservat,.NULL.)) AND BETWEEN(lp_dDate, lp_oOldReservat.rs_arrdate, lp_oOldReservat.rs_depdate-1) AND (lp_cRoomType = "*" OR lp_oOldReservat.rs_roomtyp $ lp_cRoomType)
          lp_nOccupiedRoomsCount = lp_nOccupiedRoomsCount - lp_oOldReservat.rs_rooms     && don't include rooms for current reservation
     ENDIF
ELSE
     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
          SELECT SUM(av_avail+av_ooorder) AS av_avail FROM availab
               INNER JOIN roomtype ON rt_roomtyp = av_roomtyp
               WHERE av_date = <<SqlCnv(g_sysdate,.T.)>><<l_cWhere>> AND rt_group <> 3
     ENDTEXT
     l_cCurAvlOcc = SqlCursor(l_cSql)
     lp_nRoomsCount = NVL(&l_cCurAvlOcc..av_avail,0)
     lp_nOccupiedRoomsCount = 0
ENDIF
DClose(l_cCurAvlOcc)

SELECT(l_nArea)
ENDPROC
*
PROCEDURE GetOccupancyForPeriod
LPARAMETERS tdFromDate, tdToDate, taAvailab, toOldReservat
EXTERNAL ARRAY taAvailab
LOCAL lnArea, lcSql, lnRoomsCount, lcurDates, lcurRoomtype, lcurAvailab, ldArrdate, ldDepdate, lcRoomtype, lnRooms

lnArea = SELECT()

lcurDates = MakeDatesCursor(tdFromDate, tdToDate)     &&c_date
lcurRoomtype = SqlCursor("SELECT rt_roomtyp FROM roomtype WHERE INLIST(rt_group, 1, 4)")

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT av_date, av_roomtyp, av_avail, av_ooorder, av_definit
          <<IIF(_screen.oGlobal.oParam.pa_allodef, "+CallFunc('MAX(p1,0)',av_allott+av_altall-av_pick)", "")>>
          <<IIF(_screen.oGlobal.oParam.pa_optidef, "+av_option", "")>>
          <<IIF(_screen.oGlobal.oParam.pa_tentdef, "+av_tentat", "")>>
          <<IIF(_screen.oGlobal.oParam2.pa_oosdef, "+av_ooservc", "")>> AS av_definit
          FROM availab
          INNER JOIN roomtype ON rt_roomtyp = av_roomtyp
          WHERE av_date BETWEEN <<SqlCnv(tdFromDate,.T.)>> AND <<SqlCnv(tdToDate,.T.)>> AND rt_group <> 3
ENDTEXT
lcurAvailab = SqlCursor(lcSql)
LOCATE FOR av_date = g_sysdate
lnRoomsCount = av_avail+av_ooorder
IF ISNULL(toOldReservat)
     ldArrdate = {}
     ldDepdate = {}
     lcRoomtype = ""
     lnRooms = 0
ELSE
     ldArrdate = toOldReservat.rs_arrdate
     ldDepdate = toOldReservat.rs_depdate
     lcRoomtype = toOldReservat.rs_roomtyp
     lnRooms = toOldReservat.rs_rooms
ENDIF

SELECT rt_roomtyp, c_date, NVL(av_avail,lnRoomsCount), NVL(av_definit,0) - IIF(lnRooms > 0 AND BETWEEN(c_date, ldArrdate, ldDepdate-1) AND rt_roomtyp = lcRoomtype, lnRooms, 0) ;
     FROM (SELECT rt_roomtyp, c_date FROM &lcurRoomtype, &lcurDates ORDER BY 1,2) c ;
     LEFT JOIN &lcurAvailab ON av_date = c_date AND av_roomtyp = rt_roomtyp ;
     INTO ARRAY taAvailab

DClose(lcurDates)
DClose(lcurRoomtype)
DClose(lcurAvailab)

SELECT(lnArea)
ENDPROC
*
FUNCTION GetRatecodeColor
LPARAMETERS lp_cResAlias, lp_nColor

IF INLIST(&lp_cResAlias..rs_status, "DEF", "IN", "OUT", "OPT", "LST", "TEN", "6PM", "ASG")
     * Seek record in ratecode.dbf for rs_ratecod
     RatecodeLocate(MAX(SysDate(),&lp_cResAlias..rs_arrdate), &lp_cResAlias..rs_ratecod, &lp_cResAlias..rs_roomtyp, &lp_cResAlias..rs_arrdate,,,.T.)
     IF NOT EMPTY(ratecode.rc_colorid) AND SEEK(ratecode.rc_colorid,"citcolor","tag1")
          lp_nColor =  citcolor.ct_color
     ENDIF
ENDIF

RETURN lp_nColor
ENDFUNC
*
FUNCTION GetRcRoomtypes
LPARAMETERS lp_nRcSetId, lp_lRTypeId
LOCAL l_nArea, l_cRoomTypes, l_cCurRatecode

l_nArea = SELECT()
l_cRoomTypes = ""
l_cCurRatecode = SqlCursor("SELECT rc_roomtyp FROM ratecode WHERE rc_rcsetid = " + SqlCnv(lp_nRcSetId,.T.) + " ORDER BY rc_roomtyp")
SELECT &l_cCurRatecode
SCAN
     l_cRoomTypes = l_cRoomTypes + IIF(EMPTY(l_cRoomTypes), "", ",") + ;
          ALLTRIM(IIF(lp_lRTypeId OR rc_roomtyp = "*", rc_roomtyp, Get_rt_roomtyp(rc_roomtyp)))
ENDSCAN
DClose(l_cCurRatecode)

SELECT (l_nArea)

RETURN l_cRoomTypes
ENDFUNC
*