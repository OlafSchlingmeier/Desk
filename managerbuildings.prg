*
FUNCTION ManagerBuildings
 PRIVATE noLdarea
 PRIVATE crSrelat1
 PRIVATE crStarg1
 PRIVATE crSrelat2
 PRIVATE crStarg2
 PRIVATE crSrelat3
 PRIVATE crStarg3
 PRIVATE crSrelat4
 PRIVATE crStarg4
 PRIVATE p_aBuildings
 PRIVATE p_lRemoveRoomTypeAlias
 LOCAL l_lCloseMngBuild
 DIMENSION p_aBuildings(1)
 noLdarea = SELECT()
 IF NOT USED("mngbuild")
      openfiledirect(.F.,"mngbuild")
      l_lCloseMngBuild = .T.
 ENDIF
 
 p_lRemoveRoomTypeAlias = .F. && Use it to remove "roomtype." string from building filter, when using cursor

 IF GetHotelBuildings()
      SELECT reservat
      crSrelat1 = RELATION(1, "Reservat")
      crStarg1 = TARGET(1, "Reservat")
      crSrelat2 = RELATION(2, "Reservat")
      crStarg2 = TARGET(2, "Reservat")
      crSrelat3 = RELATION(3, "Reservat")
      crStarg3 = TARGET(3, "Reservat")
      crSrelat4 = RELATION(4, "Reservat")
      crStarg4 = TARGET(4, "Reservat")
      
      p_oAudit.txTinfo(GetLangText("MANAGER","TXT_ADDBUILDINGSTOMANAGER"),1)
      DELETE ALL FOR DTOS(mg_date) = DTOS(g_sysdate) IN mngbuild
      = InitializeFields(g_sysdate)
      = CalculateOccupancy()
      p_oAudit.txTinfo(GetLangText("MANAGER","TXT_FINANCIAL"),1)
      = CalculateFinancial(g_sysdate)
      = CalculateLedger()
      = CalculateDeposit()
      = CalculateAr()
      = CalculateCumulativeData(g_sysdate)
      = CalculateCumulativeOccupany(g_sysdate)
      = WriteData(.F.,g_sysdate)
      
      SELECT reservat
      IF ( .NOT. EMPTY(crSrelat1) .AND.  .NOT. EMPTY(crStarg1))
           Set Relation To &cRsRelat1 Into &cRsTarg1
      ENDIF
      IF ( .NOT. EMPTY(crSrelat2) .AND.  .NOT. EMPTY(crStarg2))
           Set Relation To &cRsRelat2 Into &cRsTarg2 ADDITIVE
      ENDIF
      IF ( .NOT. EMPTY(crSrelat3) .AND.  .NOT. EMPTY(crStarg3))
           Set Relation To &cRsRelat3 Into &cRsTarg3 ADDITIVE
      ENDIF
      IF ( .NOT. EMPTY(crSrelat4) .AND.  .NOT. EMPTY(crStarg4))
           Set Relation To &cRsRelat4 Into &cRsTarg4 ADDITIVE
      ENDIF
      
 ENDIF
 IF l_lCloseMngBuild
      USE IN mngbuild
 ENDIF
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION Recalculate
 LPARAMETERS lp_dStartDate, lp_lRecalcOccupancy
 PRIVATE crSrelat1
 PRIVATE crStarg1
 PRIVATE crSrelat2
 PRIVATE crStarg2
 PRIVATE crSrelat3
 PRIVATE crStarg3
 PRIVATE crSrelat4
 PRIVATE crStarg4
 PRIVATE noLdarea
 PRIVATE p_aBuildings
 PRIVATE p_lRemoveRoomTypeAlias
 DIMENSION p_aBuildings(1)
 LOCAL i, l_dDate, l_lCloseMngBuild
 p_lRemoveRoomTypeAlias = .F.
 noLdarea = SELECT()
 IF NOT USED("mngbuild")
      openfiledirect(.F.,"mngbuild")
      l_lCloseMngBuild = .T.
 ENDIF
 IF GetHotelBuildings()
      SELECT reservat
      crSrelat1 = RELATION(1, "Reservat")
      crStarg1 = TARGET(1, "Reservat")
      crSrelat2 = RELATION(2, "Reservat")
      crStarg2 = TARGET(2, "Reservat")
      crSrelat3 = RELATION(3, "Reservat")
      crStarg3 = TARGET(3, "Reservat")
      crSrelat4 = RELATION(4, "Reservat")
      crStarg4 = TARGET(4, "Reservat")
      = PreapareForRecalc(lp_dStartDate)
      l_dDate = lp_dStartDate
      DO WHILE l_dDate < g_sysdate
           WAIT WINDOW NOWAIT GetLangText("MANAGER","TXT_FINANCIAL_FOR_BUILDING")+DTOC(l_dDate)
           = InitializeFields(l_dDate)
           = ReCalculateFinancial(l_dDate)
           = CalculateLedger()
           = ReCalculateDeposit(l_dDate)
           = ReCalculateAr(l_dDate)
           = CalculateCumulativeData(l_dDate)
           = WriteData(.T.,l_dDate)
           l_dDate = l_dDate + 1
      ENDDO
      IF lp_lRecalcOccupancy
           = RecalculateOccupancy(lp_dStartDate)
      ENDIF
      SELECT reservat
      IF ( .NOT. EMPTY(crSrelat1) .AND.  .NOT. EMPTY(crStarg1))
           Set Relation To &cRsRelat1 Into &cRsTarg1
      ENDIF
      IF ( .NOT. EMPTY(crSrelat2) .AND.  .NOT. EMPTY(crStarg2))
           Set Relation To &cRsRelat2 Into &cRsTarg2 ADDITIVE
      ENDIF
      IF ( .NOT. EMPTY(crSrelat3) .AND.  .NOT. EMPTY(crStarg3))
           Set Relation To &cRsRelat3 Into &cRsTarg3 ADDITIVE
      ENDIF
      IF ( .NOT. EMPTY(crSrelat4) .AND.  .NOT. EMPTY(crStarg4))
           Set Relation To &cRsRelat4 Into &cRsTarg4 ADDITIVE
      ENDIF

      WAIT CLEAR
 ENDIF
 IF l_lCloseMngBuild
      USE IN mngbuild
 ENDIF
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION GetHotelBuildings
 LOCAL i, l_cCur, l_lBuildingsFound
 l_cCur = sqlcursor("SELECT bu_buildng FROM building")
 l_lBuildingsFound = RECCOUNT(l_cCur)>0
 SELECT * FROM (l_cCur) INTO ARRAY l_aSQLResult
 dclose(l_cCur)
 IF NOT l_lBuildingsFound
      RETURN .F.
 ENDIF
 DIMENSION p_aBuildings(ALEN(l_aSQLResult,1),5)
 FOR i = 1 TO ALEN(l_aSQLResult,1)
      p_aBuildings(i,1) = l_aSQLResult(i) && Building code from picklist.dbf
      p_aBuildings(i,2) = GetFilterExp(l_aSQLResult(i))
      p_aBuildings(i,3) = NULL && New data for sysdate()
      p_aBuildings(i,4) = NULL && Data from first previous record
      p_aBuildings(i,5) = .F. && True when yesterday record is found
 ENDFOR
 RELEASE l_aSQLResult
 RETURN .T.
ENDFUNC
*
FUNCTION GetFilterExp
 LPARAMETERS lp_cFilterExp
 IF EMPTY(lp_cFilterExp)
      lp_cFilterExp = ".T."
 ELSE
      lp_cFilterExp = "roomtype.rt_buildng = " + sqlcnv(lp_cFilterExp)
 ENDIF
 RETURN lp_cFilterExp
ENDFUNC
*
FUNCTION InitializeFields
 LPARAMETERS lp_dSysDate
 LOCAL i
 SELECT mngbuild
 FOR i = 1 TO ALEN(p_aBuildings,1)
      SCATTER MEMO NAME p_aBuildings(i,3) BLANK
      p_aBuildings(i,3).mg_date = lp_dSysDate
      p_aBuildings(i,3).mg_buildng = p_aBuildings(i,1)
      p_aBuildings(i,3).mg_mngbid = DTOS(lp_dSysDate)+p_aBuildings(i,1)
      IF SEEK(DTOS(lp_dSysDate-1)+p_aBuildings(i,1),"mngbuild","tag1")
           p_aBuildings(i,5) = .T.
      ELSE
           p_aBuildings(i,5) = .F.
           GO BOTTOM
           DO WHILE mg_buildng <> p_aBuildings(i,1) AND NOT BOF()
                SKIP -1
           ENDDO  
      ENDIF
      IF NOT EMPTY(mg_date)
           SCATTER MEMO NAME p_aBuildings(i,4)
      ELSE
           SCATTER MEMO NAME p_aBuildings(i,4) BLANK
           p_aBuildings(i,4).mg_date = lp_dSysDate-1
           p_aBuildings(i,4).mg_buildng = p_aBuildings(i,1)
           p_aBuildings(i,4).mg_mngbid = DTOS(lp_dSysDate-1)+p_aBuildings(i,1)
      ENDIF
 ENDFOR
 RETURN .T.
ENDFUNC
*
FUNCTION CalculateOccupancy
 LOCAL i
 SELECT roOm
 SET ORDER TO TAG1 IN roomtype
 SET RELATION TO roOm.rm_roomtyp INTO roOmtype
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_CNTROOMSAVAILABLE"),1)
 FOR i = 1 TO ALEN(p_aBuildings,1)
      p_aBuildings(i,3).mg_roomavl = CalcRoomavl(p_aBuildings(i,2))
 ENDFOR
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_COOOROOMS"),1)
 FOR i = 1 TO ALEN(p_aBuildings,1)
      p_aBuildings(i,3).mg_roomooo = CalcRoomooo(p_aBuildings(i,2))
 ENDFOR
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_COOSROOMS"),1)
 FOR i = 1 TO ALEN(p_aBuildings,1)
      p_aBuildings(i,3).mg_roomoos = CalcRoomoos(p_aBuildings(i,2))
 ENDFOR
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_CNTBEDSAVAILABLE"),1)
 FOR i = 1 TO ALEN(p_aBuildings,1)
      p_aBuildings(i,3).mg_bedavl = CalcBedavl(p_aBuildings(i,2))
 ENDFOR
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_CNTOOOBEDS"),1)
 FOR i = 1 TO ALEN(p_aBuildings,1)
      p_aBuildings(i,3).mg_bedooo = CalcBedooo(p_aBuildings(i,2))
 ENDFOR
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_CNTOOSBEDS"),1)
 FOR i = 1 TO ALEN(p_aBuildings,1)
      p_aBuildings(i,3).mg_bedoos = CalcBedoos(p_aBuildings(i,2))
 ENDFOR
 SET RELATION TO
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_RESERVAT"),1)
 = ManagerBuildingsReservationOccupancy()
 = ManagerBuildingsSharingOccupancy()
 = foRecast()
 = arRivalsanddepartures()
 RETURN .T.
ENDFUNC
*
PROCEDURE ManagerBuildingsReservationOccupancy
 LOCAL l_nAlias, l_cOrder, l_oReser, l_nMultiplier, l_nRecnoYesterday
 LOCAL l_oReservationYesterday, l_oReservationToday, l_lYesterdaySharing, l_lTodaySharing, l_nYesterdayPersons, l_nTodayPersons
 l_nAlias = SELECT()
 SELECT reservat
 l_cOrder = ORDER()
 SET ORDER TO
 SCAN
      * Taking yesterday Roomtype for arrival and departure rooms and persons.
      IF BETWEEN(g_sysdate-1, reservat.rs_arrdate, reservat.rs_depdate-1)
           RiGetRoom(reservat.rs_reserid, g_sysdate-1, @l_oReservationYesterday)
           l_lYesterdaySharing = NOT (ISNULL(l_oReservationYesterday) OR EMPTY(l_oReservationYesterday.ri_shareid))
           IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(g_sysdate-1),"resrate","tag2")
                l_nYesterdayPersons = resrate.rr_adults+resrate.rr_childs+resrate.rr_childs2+resrate.rr_childs3
           ELSE
                l_nYesterdayPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
           ENDIF
           IF ISNULL(l_oReservationYesterday)
                = SEEK(reservat.rs_roomtyp,"roomtype","tag1")
           ELSE
                = SEEK(l_oReservationYesterday.ri_roomtyp,"roomtype","tag1")
           ENDIF
           l_nRecnoYesterday = RECNO("roomtype")
      ELSE
           l_lYesterdaySharing = .F.
           l_nYesterdayPersons = 0
           l_nRecnoYesterday = 0
      ENDIF
      * Taking today state of reservation for sharing value.
      RiGetRoom(reservat.rs_reserid, g_sysdate, @l_oReservationToday)
      l_lTodaySharing = NOT (ISNULL(l_oReservationToday) OR EMPTY(l_oReservationToday.ri_shareid))
      = SEEK(reservat.rs_roomtyp,"roomtype","tag1")
      = SEEK(reservat.rs_roomnum,"room","tag1")
      IF INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
           IF (reServat.rs_cxldate==g_sysdate .AND. reServat.rs_status="CXL")
                DO CASE
                     CASE reServat.rs_cxlstat = "TEN"
                          AddToMngBuild("mg_tencxl",reservat.rs_rooms)
                     CASE INLIST(reServat.rs_cxlstat, "OPT", "LST")
                          AddToMngBuild("mg_optcxl",reservat.rs_rooms)
                     OTHERWISE
                          AddToMngBuild("mg_rescxl",reservat.rs_rooms)
                ENDCASE
           ENDIF
           IF (reServat.rs_cxldate==(g_sysdate+1) .AND. reServat.rs_status="CXL")
                AddToMngBuild("mg_cxllate",reServat.rs_rooms)
           ENDIF
           IF (reServat.rs_cxldate==g_sysdate .AND. reServat.rs_status="NS")
                DO CASE
                     CASE reServat.rs_cxlstat = "TEN"
                          AddToMngBuild("mg_tencxl",reservat.rs_rooms)
                     CASE INLIST(reServat.rs_cxlstat, "OPT", "LST")
                          AddToMngBuild("mg_optcxl",reservat.rs_rooms)
                     OTHERWISE
                          AddToMngBuild("mg_resns",reServat.rs_rooms)
                ENDCASE
           ENDIF
           IF (reServat.rs_created==g_sysdate)
                AddToMngBuild("mg_resnew",reServat.rs_rooms)
           ENDIF
      ENDIF
      IF INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum AND NOT INLIST(reservat.rs_status, "CXL", "NS")
           l_nTodayPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
           IF NOT EMPTY(reservat.rs_in) AND NOT EMPTY(reservat.rs_out) AND ;
                     (reservat.rs_arrdate = reservat.rs_depdate) AND (rs_depdate==g_sysdate)
                IF NOT l_lTodaySharing
                     AddToMngBuild("mg_roomarr",reServat.rs_rooms)
                     AddToMngBuild("mg_rmduse",reServat.rs_rooms)
                ENDIF
                AddToMngBuild("mg_persarr",l_nTodayPersons)
                AddToMngBuild("mg_prduse",l_nTodayPersons)
           ENDIF
           IF (reServat.rs_depdate==g_sysdate)
                IF NOT l_lTodaySharing
                     AddToMngBuild("mg_roomdep",reServat.rs_rooms)
                ENDIF
                AddToMngBuild("mg_persdep",l_nTodayPersons)
           ENDIF
           IF ( .NOT. EMPTY(reServat.rs_in) .AND. EMPTY(reServat.rs_out))
                IF (reServat.rs_arrdate==g_sysdate)
                     IF NOT l_lTodaySharing
                          AddToMngBuild("mg_roomarr",reServat.rs_rooms)
                     ENDIF
                     AddToMngBuild("mg_persarr",l_nTodayPersons)
                ENDIF
                IF (reServat.rs_depdate==g_sysdate)
                     IF NOT l_lTodaySharing
                          AddToMngBuild("mg_roomdep",reServat.rs_rooms)
                     ENDIF
                     AddToMngBuild("mg_persdep",reServat.rs_rooms)
                ELSE
                     IF roomtype.rt_group = 4
                          l_nMultiplier = OCCURS(",", room.rm_link) + 1
                     ELSE
                          l_nMultiplier = 1
                     ENDIF
                     IF NOT l_lTodaySharing
                          AddToMngBuild("mg_roomocc",reServat.rs_rooms * l_nMultiplier)
                     ENDIF
                     AddToMngBuild("mg_bedocc",l_nTodayPersons)
                     IF (reServat.rs_complim)
                          IF NOT l_lTodaySharing
                               AddToMngBuild("mg_comprmd",reServat.rs_rooms * l_nMultiplier)
                          ENDIF
                          AddToMngBuild("mg_compprd",l_nTodayPersons)
                     ENDIF
                ENDIF
           ENDIF
      ENDIF
      IF NOT INLIST(reservat.rs_status, "CXL", "NS")
           DO CASE
                CASE INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
                * If reservation yesterday was in non standard room and today is in standard room this room is arrival room.
                     GO l_nRecnoYesterday IN roomtype
                     IF NOT INLIST(roomtype.rt_group, 1, 4)
                          IF NOT l_lTodaySharing
                               AddToMngBuild("mg_roomarr",reServat.rs_rooms)
                          ENDIF
                          AddToMngBuild("mg_persarr",l_nTodayPersons)
                     ENDIF
                CASE NOT INLIST(roomtype.rt_group, 1, 4)
                * If reservation yesterday was in standard room and today is in non standard room this room is departure room.
                     GO l_nRecnoYesterday IN roomtype
                     IF INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
                          IF NOT l_lYesterdaySharing
                               AddToMngBuild("mg_roomdep",reServat.rs_rooms)
                          ENDIF
                          AddToMngBuild("mg_persdep",l_nYesterdayPersons)
                     ENDIF
           ENDCASE
      ENDIF
 ENDSCAN
 SET ORDER TO l_cOrder
 SELECT (l_nAlias)
ENDPROC
*
PROCEDURE ManagerBuildingsSharingOccupancy
 LOCAL l_nAlias, l_cOrder, l_nMultiplier, l_lIsArrival, l_lIsDeparture, l_lIsDayUse, l_lIsComplim
 l_nAlias = SELECT()
 SELECT sharing
 l_cOrder = ORDER()
 SET ORDER TO
 SET RELATION TO sd_roomtyp INTO roOmtype
 SCAN FOR NOT sd_history AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
      DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "ROOMDEP", g_sysdate
      IF l_lIsDeparture
           AddToMngBuild("mg_roomdep",1)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDayUse, sd_shareid, sd_lowdat, sd_highdat, "DAYUSE", g_sysdate
      IF (sd_status = "OUT") AND l_lIsDayUse
           AddToMngBuild("mg_roomarr",1)    && Always OUT
           AddToMngBuild("mg_rmduse",1)
      ENDIF
      IF sd_status = "IN"
           DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ROOMARR", g_sysdate
           IF (sd_lowdat = g_sysdate) AND l_lIsArrival
                AddToMngBuild("mg_roomarr",1)
           ENDIF
           IF BETWEEN(g_sysdate, sd_lowdat, sd_highdat)
                IF (roomtype.rt_group = 4) AND SEEK(sd_roomnum,"room","tag1")
                     l_nMultiplier = OCCURS(",", room.rm_link) + 1
                ELSE
                     l_nMultiplier = 1
                ENDIF
                AddToMngBuild("mg_roomocc",l_nMultiplier)
                DO RiShareInterval IN ProcResRooms WITH l_lIsComplim, sd_shareid, sd_lowdat, sd_highdat, "COMPLIM"
                IF l_lIsComplim
                     AddToMngBuild("mg_comprmd",l_nMultiplier)
                ENDIF
           ENDIF
      ENDIF
 ENDSCAN
 SET RELATION TO
 SET ORDER TO l_cOrder
 SELECT (l_nAlias)
ENDPROC
*
FUNCTION CalcRoomavl
 LPARAMETERS lp_cFilterExp
 LOCAL l_nResult
 IF EMPTY(lp_cFilterExp)
      lp_cFilterExp = ".T."
 ENDIF
 l_nResult = 0
 IF NOT HotelClosed(g_sysdate)
      COUNT FOR roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum .AND. &lp_cFilterExp TO l_nResult
 ENDIF
 RETURN l_nResult
ENDFUNC
*
FUNCTION CalcRoomooo
 LPARAMETERS lp_cFilterExp
 LOCAL l_nResult
 IF EMPTY(lp_cFilterExp)
      lp_cFilterExp = ".T."
 ENDIF
 l_nResult = 0
 COUNT FOR roOm.rm_status="OOO" .AND. roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum .AND. ;
      &lp_cFilterExp TO l_nResult
 RETURN l_nResult
ENDFUNC
*
FUNCTION CalcRoomoos
 LPARAMETERS lp_cFilterExp
 LOCAL l_nResult
 IF EMPTY(lp_cFilterExp)
      lp_cFilterExp = ".T."
 ENDIF
 l_nResult= 0
 COUNT FOR roOm.rm_status="OOS" .AND. roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum .AND. ;
      &lp_cFilterExp TO l_nResult
 RETURN l_nResult
ENDFUNC
*
FUNCTION CalcBedavl
 LPARAMETERS lp_cFilterExp
 LOCAL l_nResult
 IF EMPTY(lp_cFilterExp)
      lp_cFilterExp = ".T."
 ENDIF
 l_nResult = 0
 IF NOT HotelClosed(g_sysdate)
      SUM roOm.rm_beds TO l_nResult FOR roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum .AND. &lp_cFilterExp
 ENDIF
 RETURN l_nResult
ENDFUNC
*
FUNCTION CalcBedooo
 LPARAMETERS lp_cFilterExp
 LOCAL l_nResult
 IF EMPTY(lp_cFilterExp)
      lp_cFilterExp = ".T."
 ENDIF
 l_nResult = 0
 SUM roOm.rm_beds TO l_nResult FOR roOm.rm_status="OOO" .AND.  ;
     roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum .AND. &lp_cFilterExp
 RETURN l_nResult
ENDFUNC
*
FUNCTION CalcBedoos
 LPARAMETERS lp_cFilterExp
 LOCAL l_nResult
 IF EMPTY(lp_cFilterExp)
      lp_cFilterExp = ".T."
 ENDIF
 l_nResult = 0
 SUM roOm.rm_beds TO l_nResult FOR roOm.rm_status="OOS" .AND.  ;
     roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum .AND. &lp_cFilterExp
 RETURN l_nResult
ENDFUNC
*
FUNCTION Forecast
 PRIVATE nsElect
 LOCAL l_cText, l_cTextTomorrow, l_cTextNextweek, l_cTextNext30days, l_cTextNext365days, l_cSql, l_cBuildingLast
 l_cTextTomorrow = GetLangText("MANAGER","TXT_TOMORROW")
 l_cTextNextweek = GetLangText("MANAGER","TXT_NEXTWEEK")
 l_cTextNext30days = GetLangText("MANAGER","TXT_NEXT30DAYS")
 l_cTextNext365days = GetLangText("MANAGER","TXT_NEXT365DAYS")
 l_cText = ""
 nsElect = SELECT()
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_FORECAST"),1)
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
      SELECT rt_buildng, av_date, av_avail, av_definit, av_option, av_tentat, av_allott, av_altall, av_pick, av_waiting, av_ooservc
           FROM availab 
           INNER JOIN roomtype ON av_roomtyp = rt_roomtyp 
           WHERE av_date BETWEEN <<sqlcnv(g_sysdate+1,.T.)>> AND <<sqlcnv(g_sysdate+365, .T.)>> AND 
           rt_group = <<sqlcnv(1,.T.)>> 
           AND rt_vwsum = <<sqlcnv(.T.,.T.)>> 
           ORDER BY rt_buildng, av_date
 ENDTEXT
 l_cCur = sqlcursor(l_cSql)

 p_lRemoveRoomTypeAlias = .T.
 l_cBuildingLast = ""
 SELECT (l_cCur)
 SCAN ALL
      IF l_cBuildingLast <> ALLTRIM(rt_buildng)
           l_cBuildingLast = ALLTRIM(rt_buildng)
           p_oAudit.txTinfo(l_cBuildingLast,1)
      ENDIF
      DO CASE
           CASE av_date==(g_sysdate+1) AND l_cText <> l_cTextTomorrow
                *p_oAudit.txTinfo(GetLangText("MANAGER","TXT_TOMORROW"),1)
                l_cText = l_cTextTomorrow
           CASE BETWEEN(av_date,g_sysdate+2,g_sysdate+7) AND l_cText <> l_cTextNextweek
                *p_oAudit.txTinfo(GetLangText("MANAGER","TXT_NEXTWEEK"),1)
                l_cText = l_cTextNextweek
           CASE BETWEEN(av_date,g_sysdate+8,g_sysdate+30) AND l_cText <> l_cTextNext30days
                *p_oAudit.txTinfo(GetLangText("MANAGER","TXT_ENDOFMONTH"),1)
                *p_oAudit.txTinfo(GetLangText("MANAGER","TXT_NEXT30DAYS"),1)
                l_cText = l_cTextNext30days
           CASE BETWEEN(av_date,g_sysdate+31,g_sysdate+365) AND l_cText <> l_cTextNext365days
                *p_oAudit.txTinfo(GetLangText("MANAGER","TXT_NEXT365DAYS"),1)
                *p_oAudit.txTinfo(GetLangText("MANAGER","TXT_ENDOFTHEYEAR"),1)
                l_cText = l_cTextNext365days
      ENDCASE
      IF av_date==(g_sysdate+1)
           = AddToMngBuild("mg_maxtomo",av_avail-av_ooservc)
           = AddToMngBuild("mg_deftomo",av_definit)
           = AddToMngBuild("mg_opttomo",av_option)
           = AddToMngBuild("mg_tentomo",av_tentat)
           = AddToMngBuild("mg_alltomo",av_allott+av_altall)
           = AddToMngBuild("mg_pictomo",av_pick)
           = AddToMngBuild("mg_waitomo",av_waiting)      
      ENDIF
      IF av_date<=(g_sysdate+7)
           = AddToMngBuild("mg_maxnext",av_avail-av_ooservc)
           = AddToMngBuild("mg_defnext",av_definit)
           = AddToMngBuild("mg_optnext",av_option)
           = AddToMngBuild("mg_tennext",av_tentat)
           = AddToMngBuild("mg_allnext",av_allott+av_altall)
           = AddToMngBuild("mg_picnext",av_pick)
           = AddToMngBuild("mg_wainext",av_waiting)
      ENDIF
      IF MONTH(av_date)= MONTH(g_sysdate) AND YEAR(av_date)=YEAR(g_sysdate)
           = AddToMngBuild("mg_maxendm",av_avail-av_ooservc)
           = AddToMngBuild("mg_defendm",av_definit)
           = AddToMngBuild("mg_optendm",av_option)
           = AddToMngBuild("mg_tenendm",av_tentat)
           = AddToMngBuild("mg_allendm",av_allott+av_altall)
           = AddToMngBuild("mg_picendm",av_pick)
           = AddToMngBuild("mg_waiendm",av_waiting)
      ENDIF
      IF av_date<=(g_sysdate+30)
           = AddToMngBuild("mg_max30da",av_avail-av_ooservc)
           = AddToMngBuild("mg_def30da",av_definit)
           = AddToMngBuild("mg_opt30da",av_option)
           = AddToMngBuild("mg_ten30da",av_tentat)
           = AddToMngBuild("mg_all30da",av_allott+av_altall)
           = AddToMngBuild("mg_pic30da",av_pick)
           = AddToMngBuild("mg_wai30da",av_waiting)
      ENDIF
      IF av_date<=(g_sysdate+365)
           = AddToMngBuild("mg_max365d",av_avail-av_ooservc)
           = AddToMngBuild("mg_def365d",av_definit)
           = AddToMngBuild("mg_opt365d",av_option)
           = AddToMngBuild("mg_ten365d",av_tentat)
           = AddToMngBuild("mg_all365d",av_allott+av_altall)
           = AddToMngBuild("mg_pic365d",av_pick)
           = AddToMngBuild("mg_wai365d",av_waiting)
      ENDIF
      IF MONTH(av_date)<=12 .AND. YEAR(av_date)==YEAR(g_sysdate)
           = AddToMngBuild("mg_maxendy",av_avail-av_ooservc)
           = AddToMngBuild("mg_defendy",av_definit)
           = AddToMngBuild("mg_optendy",av_option)
           = AddToMngBuild("mg_tenendy",av_tentat)
           = AddToMngBuild("mg_allendy",av_allott+av_altall)
           = AddToMngBuild("mg_picendy",av_pick)
           = AddToMngBuild("mg_waiendy",av_waiting)
      ENDIF
 ENDSCAN
 
 p_lRemoveRoomTypeAlias = .F.
 
 dclose(l_cCur)
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION ArrivalsAndDepartures
 PRIVATE nsElect
 LOCAL l_nMgrArr, l_nMgrDep, l_cOrder
 nsElect = SELECT()
 SELECT reServat
 l_cOrder = ORDER()
 SET ORDER TO
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_ARRIVALS"),1)
 = CalcArrival()
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_DEPARTURES"),1)
 = CalcDepartu()
 SET ORDER TO l_cOrder IN reservat
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION CalcArrival
 LOCAL l_nResult, l_oResrooms, l_lIsArrival
 l_nResult = 0
 SELECT reservat
 SET RELATION TO rs_roomtyp INTO roomtype IN reservat
 SCAN FOR DTOS(rs_arrdate)+rs_lname = DTOS(g_sysdate+1) AND NOT INLIST(rs_status, 'CXL', 'NS') AND ;
            INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
     RiGetRoom(reservat.rs_reserid, reservat.rs_arrdate, @l_oResrooms)
     IF ISNULL(l_oResrooms) OR EMPTY(l_oResrooms.ri_shareid)
         l_nResult = l_nResult + rs_rooms
         AddToMngBuild("mg_arrival",rs_rooms)
     ENDIF
 ENDSCAN
 SET RELATION OFF INTO roomtype IN reservat
 SELECT sharing
 SET RELATION TO sd_roomtyp INTO roomtype
 SCAN FOR NOT sd_history AND (sd_lowdat = g_sysdate+1) AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
     DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ARRIVAL", g_sysdate+1
     IF l_lIsArrival
          l_nResult = l_nResult + 1
          AddToMngBuild("mg_arrival",1)
     ENDIF
 ENDSCAN
 SET RELATION TO
 SELECT reservat
 RETURN l_nResult
ENDFUNC
*
FUNCTION CalcDepartu
 LOCAL l_nResult, l_oResrooms, l_lSharing, l_cRoomtype, l_lIsDeparture
 l_nResult = 0
 SELECT reservat
 SCAN FOR DTOS(rs_depdate)+rs_roomnum=DTOS(g_sysdate+1) AND NOT INLIST(rs_status, 'CXL', 'NS')
     RiGetRoom(reservat.rs_reserid, reservat.rs_depdate, @l_oResrooms)
     l_lSharing = NOT (ISNULL(l_oResrooms) OR EMPTY(l_oResrooms.ri_shareid))
     l_cRoomtype = IIF(ISNULL(l_oResrooms), reservat.rs_roomtyp, l_oResrooms.ri_roomtyp)
     IF SEEK(l_cRoomtype,"roomtype","tag1") AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum AND NOT l_lSharing
         l_nResult = l_nResult + rs_rooms
         AddToMngBuild("mg_departu",rs_rooms)
     ENDIF
 ENDSCAN
 SELECT sharing
 SET RELATION TO sd_roomtyp INTO roomtype
 SCAN FOR NOT sd_history AND (sd_highdat = g_sysdate+1) AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
     DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "DEPARTURE", g_sysdate+1
     IF l_lIsDeparture
         l_nResult = l_nResult + 1
         AddToMngBuild("mg_departu",1)
     ENDIF
 ENDSCAN
 SET RELATION TO
 SELECT reservat
 RETURN l_nResult
ENDFUNC
*
FUNCTION AddToMngBuild
 LPARAMETERS lp_cField, lp_nValue
 LOCAL i, l_cMacro, l_nNewValue, l_cFilterExp
 FOR i = 1 TO ALEN(p_aBuildings,1)
      IF p_lRemoveRoomTypeAlias
           l_cFilterExp = STRTRAN(p_aBuildings(i,2),"roomtype.","")
      ELSE
           l_cFilterExp = p_aBuildings(i,2)
      ENDIF
      IF &l_cFilterExp
           l_cMacro = "p_aBuildings(i,3)." + lp_cField
           l_nNewValue = &l_cMacro + lp_nValue
           &l_cMacro = l_nNewValue
      ENDIF
 ENDFOR
 RETURN .T.
ENDFUNC
*
FUNCTION WriteData
 LPARAMETERS lp_lRecalculating, lp_dDate
 LOCAL i
 SELECT mngbuild
 FOR i = 1 TO ALEN(p_aBuildings,1)
      IF lp_lRecalculating
           IF NOT SEEK(DTOS(lp_dDate)+p_aBuildings(i,1),"mngbuild","tag1")
                INSERT INTO mngbuild (mg_mngbid,mg_date,mg_buildng) VALUES ;
                     (DTOS(lp_dDate)+p_aBuildings(i,1),lp_dDate,p_aBuildings(i,1))
           ENDIF   
           GATHER NAME p_aBuildings(i,3) FIELDS ;
                mg_dayg1, ;
                mg_dayg2, ;
                mg_dayg3, ;
                mg_dayg4, ;
                mg_dayg5, ;
                mg_dayg6, ;
                mg_dayg7, ;
                mg_dayg8, ;
                mg_dayg9, ;
                mg_dayp1, ;
                mg_dayp2, ;
                mg_dayp3, ;
                mg_dayp4, ;
                mg_dayp5, ;
                mg_dayp6, ;
                mg_dayp7, ;
                mg_dayp8, ;
                mg_dayp9, ;
                mg_dvat1, ;
                mg_dvat2, ;
                mg_dvat3, ;
                mg_dvat4, ;
                mg_dvat5, ;
                mg_dvat6, ;
                mg_dvat7, ;
                mg_dvat8, ;
                mg_dvat9, ;
                mg_mong1, ;
                mg_mong2, ;
                mg_mong3, ;
                mg_mong4, ;
                mg_mong5, ;
                mg_mong6, ;
                mg_mong7, ;
                mg_mong8, ;
                mg_mong9, ;
                mg_monp1, ;
                mg_monp2, ;
                mg_monp3, ;
                mg_monp4, ;
                mg_monp5, ;
                mg_monp6, ;
                mg_monp7, ;
                mg_monp8, ;
                mg_monp9, ;
                mg_mvat1, ;
                mg_mvat2, ;
                mg_mvat3, ;
                mg_mvat4, ;
                mg_mvat5, ;
                mg_mvat6, ;
                mg_mvat7, ;
                mg_mvat8, ;
                mg_mvat9, ;
                mg_yeag1, ;
                mg_yeag2, ;
                mg_yeag3, ;
                mg_yeag4, ;
                mg_yeag5, ;
                mg_yeag6, ;
                mg_yeag7, ;
                mg_yeag8, ;
                mg_yeag9, ;
                mg_yeap1, ;
                mg_yeap2, ;
                mg_yeap3, ;
                mg_yeap4, ;
                mg_yeap5, ;
                mg_yeap6, ;
                mg_yeap7, ;
                mg_yeap8, ;
                mg_yeap9, ;
                mg_yvat1, ;
                mg_yvat2, ;
                mg_yvat3, ;
                mg_yvat4, ;
                mg_yvat5, ;
                mg_yvat6, ;
                mg_yvat7, ;
                mg_yvat8, ;
                mg_yvat9, ;
                mg_gcldg, ;
                mg_gstldg, ;
                mg_pdoutd, ;
                mg_pdoutm, ;
                mg_pdouty, ;
                mg_internd, ;
                mg_internm, ;
                mg_interny, ;
                mg_gcertd, ;
                mg_gcertm, ;
                mg_gcerty, ;
                mg_cldg, ;
                mg_cldgcrd, ;
                mg_cldgdeb, ;
                mg_dldg, ;
                mg_dldgcrd, ;
                mg_dldgdeb MEMO
      ELSE
           APPEND BLANK
           GATHER NAME p_aBuildings(i,3) MEMO
      ENDIF
 ENDFOR
 RETURN .T.
ENDFUNC
*
FUNCTION CalculateCumulativeOccupany
 LPARAMETERS lp_dSysDate
 LOCAL i
 IF neWperiod(lp_dSysDate)
      FOR i = 1 TO ALEN(p_aBuildings,1)
           p_aBuildings(i,3).mg_roomavm = p_aBuildings(i,3).mg_roomavl
           p_aBuildings(i,3).mg_bedavlm = p_aBuildings(i,3).mg_bedavl
           p_aBuildings(i,3).mg_rmooom  = p_aBuildings(i,3).mg_roomooo
           p_aBuildings(i,3).mg_rmoosm  = p_aBuildings(i,3).mg_roomoos
           p_aBuildings(i,3).mg_bdooom  = p_aBuildings(i,3).mg_bedooo
           p_aBuildings(i,3).mg_bdoosm  = p_aBuildings(i,3).mg_bedoos
           p_aBuildings(i,3).mg_rmoccm  = p_aBuildings(i,3).mg_roomocc
           p_aBuildings(i,3).mg_bdoccm  = p_aBuildings(i,3).mg_bedocc
           p_aBuildings(i,3).mg_rmarrm  = p_aBuildings(i,3).mg_roomarr
           p_aBuildings(i,3).mg_perarrm = p_aBuildings(i,3).mg_persarr
           p_aBuildings(i,3).mg_roodepm = p_aBuildings(i,3).mg_roomdep
           p_aBuildings(i,3).mg_perdepm = p_aBuildings(i,3).mg_persdep
           p_aBuildings(i,3).mg_rescxlm = p_aBuildings(i,3).mg_rescxl
           p_aBuildings(i,3).mg_optcxlm = p_aBuildings(i,3).mg_optcxl
           p_aBuildings(i,3).mg_tencxlm = p_aBuildings(i,3).mg_tencxl
           p_aBuildings(i,3).mg_cxllatm = p_aBuildings(i,3).mg_cxllate
           p_aBuildings(i,3).mg_resnsm  = p_aBuildings(i,3).mg_resns
           p_aBuildings(i,3).mg_resnewm = p_aBuildings(i,3).mg_resnew
           p_aBuildings(i,3).mg_prdusem = p_aBuildings(i,3).mg_prduse
           p_aBuildings(i,3).mg_rmdusem = p_aBuildings(i,3).mg_rmduse
           p_aBuildings(i,3).mg_comprmm = p_aBuildings(i,3).mg_comprmd
           p_aBuildings(i,3).mg_compprm = p_aBuildings(i,3).mg_compprd
      ENDFOR
 ELSE
      FOR i = 1 TO ALEN(p_aBuildings,1)
           p_aBuildings(i,3).mg_roomavm = p_aBuildings(i,4).mg_roomavm + p_aBuildings(i,3).mg_roomavl
           p_aBuildings(i,3).mg_bedavlm = p_aBuildings(i,4).mg_bedavlm + p_aBuildings(i,3).mg_bedavl
           p_aBuildings(i,3).mg_rmooom  = p_aBuildings(i,4).mg_rmooom  + p_aBuildings(i,3).mg_roomooo
           p_aBuildings(i,3).mg_rmoosm  = p_aBuildings(i,4).mg_rmoosm  + p_aBuildings(i,3).mg_roomoos
           p_aBuildings(i,3).mg_bdooom  = p_aBuildings(i,4).mg_bdooom  + p_aBuildings(i,3).mg_bedooo
           p_aBuildings(i,3).mg_bdoosm  = p_aBuildings(i,4).mg_bdoosm  + p_aBuildings(i,3).mg_bedoos
           p_aBuildings(i,3).mg_rmoccm  = p_aBuildings(i,4).mg_rmoccm  + p_aBuildings(i,3).mg_roomocc
           p_aBuildings(i,3).mg_bdoccm  = p_aBuildings(i,4).mg_bdoccm  + p_aBuildings(i,3).mg_bedocc
           p_aBuildings(i,3).mg_rmarrm  = p_aBuildings(i,4).mg_rmarrm  + p_aBuildings(i,3).mg_roomarr
           p_aBuildings(i,3).mg_perarrm = p_aBuildings(i,4).mg_perarrm + p_aBuildings(i,3).mg_persarr
           p_aBuildings(i,3).mg_roodepm = p_aBuildings(i,4).mg_roodepm + p_aBuildings(i,3).mg_roomdep
           p_aBuildings(i,3).mg_perdepm = p_aBuildings(i,4).mg_perdepm + p_aBuildings(i,3).mg_persdep
           p_aBuildings(i,3).mg_rescxlm = p_aBuildings(i,4).mg_rescxlm + p_aBuildings(i,3).mg_rescxl
           p_aBuildings(i,3).mg_optcxlm = p_aBuildings(i,4).mg_optcxlm + p_aBuildings(i,3).mg_optcxl
           p_aBuildings(i,3).mg_tencxlm = p_aBuildings(i,4).mg_tencxlm + p_aBuildings(i,3).mg_tencxl
           p_aBuildings(i,3).mg_cxllatm = p_aBuildings(i,4).mg_cxllatm + p_aBuildings(i,3).mg_cxllate
           p_aBuildings(i,3).mg_resnsm  = p_aBuildings(i,4).mg_resnsm  + p_aBuildings(i,3).mg_resns
           p_aBuildings(i,3).mg_resnewm = p_aBuildings(i,4).mg_resnewm + p_aBuildings(i,3).mg_resnew
           p_aBuildings(i,3).mg_prdusem = p_aBuildings(i,4).mg_prdusem + p_aBuildings(i,3).mg_prduse
           p_aBuildings(i,3).mg_rmdusem = p_aBuildings(i,4).mg_rmdusem + p_aBuildings(i,3).mg_rmduse
           p_aBuildings(i,3).mg_comprmm = p_aBuildings(i,4).mg_comprmm + p_aBuildings(i,3).mg_comprmd
           p_aBuildings(i,3).mg_compprm = p_aBuildings(i,4).mg_compprm + p_aBuildings(i,3).mg_compprd
      ENDFOR
 ENDIF
 IF neWyear(lp_dSysDate)
      FOR i = 1 TO ALEN(p_aBuildings,1)
           p_aBuildings(i,3).mg_roomavy = p_aBuildings(i,3).mg_roomavl
           p_aBuildings(i,3).mg_bedavly = p_aBuildings(i,3).mg_bedavl
           p_aBuildings(i,3).mg_rmoooy  = p_aBuildings(i,3).mg_roomooo
           p_aBuildings(i,3).mg_rmoosy  = p_aBuildings(i,3).mg_roomoos
           p_aBuildings(i,3).mg_bdoooy  = p_aBuildings(i,3).mg_bedooo
           p_aBuildings(i,3).mg_bdoosy  = p_aBuildings(i,3).mg_bedoos
           p_aBuildings(i,3).mg_rmoccy  = p_aBuildings(i,3).mg_roomocc
           p_aBuildings(i,3).mg_bdoccy  = p_aBuildings(i,3).mg_bedocc
           p_aBuildings(i,3).mg_rmarry  = p_aBuildings(i,3).mg_roomarr
           p_aBuildings(i,3).mg_perarry = p_aBuildings(i,3).mg_persarr
           p_aBuildings(i,3).mg_roodepy = p_aBuildings(i,3).mg_roomdep
           p_aBuildings(i,3).mg_perdepy = p_aBuildings(i,3).mg_persdep
           p_aBuildings(i,3).mg_rescxly = p_aBuildings(i,3).mg_rescxl
           p_aBuildings(i,3).mg_optcxly = p_aBuildings(i,3).mg_optcxl
           p_aBuildings(i,3).mg_tencxly = p_aBuildings(i,3).mg_tencxl
           p_aBuildings(i,3).mg_cxllaty = p_aBuildings(i,3).mg_cxllate
           p_aBuildings(i,3).mg_resnsy  = p_aBuildings(i,3).mg_resns
           p_aBuildings(i,3).mg_resnewy = p_aBuildings(i,3).mg_resnew
           p_aBuildings(i,3).mg_prdusey = p_aBuildings(i,3).mg_prduse
           p_aBuildings(i,3).mg_rmdusey = p_aBuildings(i,3).mg_rmduse
           p_aBuildings(i,3).mg_comprmy = p_aBuildings(i,3).mg_comprmd
           p_aBuildings(i,3).mg_comppry = p_aBuildings(i,3).mg_compprd
      ENDFOR
 ELSE
      FOR i = 1 TO ALEN(p_aBuildings,1)
           p_aBuildings(i,3).mg_roomavy = p_aBuildings(i,4).mg_roomavy + p_aBuildings(i,3).mg_roomavl
           p_aBuildings(i,3).mg_bedavly = p_aBuildings(i,4).mg_bedavly + p_aBuildings(i,3).mg_bedavl
           p_aBuildings(i,3).mg_rmoooy  = p_aBuildings(i,4).mg_rmoooy  + p_aBuildings(i,3).mg_roomooo
           p_aBuildings(i,3).mg_rmoosy  = p_aBuildings(i,4).mg_rmoosy  + p_aBuildings(i,3).mg_roomoos
           p_aBuildings(i,3).mg_bdoooy  = p_aBuildings(i,4).mg_bdoooy  + p_aBuildings(i,3).mg_bedooo
           p_aBuildings(i,3).mg_bdoosy  = p_aBuildings(i,4).mg_bdoosy  + p_aBuildings(i,3).mg_bedoos
           p_aBuildings(i,3).mg_rmoccy  = p_aBuildings(i,4).mg_rmoccy  + p_aBuildings(i,3).mg_roomocc
           p_aBuildings(i,3).mg_bdoccy  = p_aBuildings(i,4).mg_bdoccy  + p_aBuildings(i,3).mg_bedocc
           p_aBuildings(i,3).mg_rmarry  = p_aBuildings(i,4).mg_rmarry  + p_aBuildings(i,3).mg_roomarr
           p_aBuildings(i,3).mg_perarry = p_aBuildings(i,4).mg_perarry + p_aBuildings(i,3).mg_persarr
           p_aBuildings(i,3).mg_roodepy = p_aBuildings(i,4).mg_roodepy + p_aBuildings(i,3).mg_roomdep
           p_aBuildings(i,3).mg_perdepy = p_aBuildings(i,4).mg_perdepy + p_aBuildings(i,3).mg_persdep
           p_aBuildings(i,3).mg_rescxly = p_aBuildings(i,4).mg_rescxly + p_aBuildings(i,3).mg_rescxl
           p_aBuildings(i,3).mg_optcxly = p_aBuildings(i,4).mg_optcxly + p_aBuildings(i,3).mg_optcxl
           p_aBuildings(i,3).mg_tencxly = p_aBuildings(i,4).mg_tencxly + p_aBuildings(i,3).mg_tencxl
           p_aBuildings(i,3).mg_cxllaty = p_aBuildings(i,4).mg_cxllaty + p_aBuildings(i,3).mg_cxllate
           p_aBuildings(i,3).mg_resnsy  = p_aBuildings(i,4).mg_resnsy  + p_aBuildings(i,3).mg_resns
           p_aBuildings(i,3).mg_resnewy = p_aBuildings(i,4).mg_resnewy + p_aBuildings(i,3).mg_resnew
           p_aBuildings(i,3).mg_prdusey = p_aBuildings(i,4).mg_prdusey + p_aBuildings(i,3).mg_prduse
           p_aBuildings(i,3).mg_rmdusey = p_aBuildings(i,4).mg_rmdusey + p_aBuildings(i,3).mg_rmduse
           p_aBuildings(i,3).mg_comprmy = p_aBuildings(i,4).mg_comprmy + p_aBuildings(i,3).mg_comprmd
           p_aBuildings(i,3).mg_comppry = p_aBuildings(i,4).mg_comppry + p_aBuildings(i,3).mg_compprd
      ENDFOR
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION CalculateCumulativeData
 LPARAMETERS lp_dSysDate
 LOCAL i
 IF neWperiod(lp_dSysDate)
      FOR i = 1 TO ALEN(p_aBuildings,1)
           ** Financial
           * mg_monp
           p_aBuildings(i,3).mg_monp1 = p_aBuildings(i,3).mg_dayp1
           p_aBuildings(i,3).mg_monp2 = p_aBuildings(i,3).mg_dayp2
           p_aBuildings(i,3).mg_monp3 = p_aBuildings(i,3).mg_dayp3
           p_aBuildings(i,3).mg_monp4 = p_aBuildings(i,3).mg_dayp4
           p_aBuildings(i,3).mg_monp5 = p_aBuildings(i,3).mg_dayp5
           p_aBuildings(i,3).mg_monp6 = p_aBuildings(i,3).mg_dayp6
           p_aBuildings(i,3).mg_monp7 = p_aBuildings(i,3).mg_dayp7
           p_aBuildings(i,3).mg_monp8 = p_aBuildings(i,3).mg_dayp8
           p_aBuildings(i,3).mg_monp9 = p_aBuildings(i,3).mg_dayp9
           * mg_mong
           p_aBuildings(i,3).mg_mong1 = p_aBuildings(i,3).mg_dayg1
           p_aBuildings(i,3).mg_mong2 = p_aBuildings(i,3).mg_dayg2
           p_aBuildings(i,3).mg_mong3 = p_aBuildings(i,3).mg_dayg3
           p_aBuildings(i,3).mg_mong4 = p_aBuildings(i,3).mg_dayg4
           p_aBuildings(i,3).mg_mong5 = p_aBuildings(i,3).mg_dayg5
           p_aBuildings(i,3).mg_mong6 = p_aBuildings(i,3).mg_dayg6
           p_aBuildings(i,3).mg_mong7 = p_aBuildings(i,3).mg_dayg7
           p_aBuildings(i,3).mg_mong8 = p_aBuildings(i,3).mg_dayg8
           p_aBuildings(i,3).mg_mong9 = p_aBuildings(i,3).mg_dayg9
           * mg_mvat
           p_aBuildings(i,3).mg_mvat1 = p_aBuildings(i,3).mg_dvat1
           p_aBuildings(i,3).mg_mvat2 = p_aBuildings(i,3).mg_dvat2
           p_aBuildings(i,3).mg_mvat3 = p_aBuildings(i,3).mg_dvat3
           p_aBuildings(i,3).mg_mvat4 = p_aBuildings(i,3).mg_dvat4
           p_aBuildings(i,3).mg_mvat5 = p_aBuildings(i,3).mg_dvat5
           p_aBuildings(i,3).mg_mvat6 = p_aBuildings(i,3).mg_dvat6
           p_aBuildings(i,3).mg_mvat7 = p_aBuildings(i,3).mg_dvat7
           p_aBuildings(i,3).mg_mvat8 = p_aBuildings(i,3).mg_dvat8
           p_aBuildings(i,3).mg_mvat9 = p_aBuildings(i,3).mg_dvat9
           *
           p_aBuildings(i,3).mg_pdoutm = p_aBuildings(i,3).mg_pdoutd
           p_aBuildings(i,3).mg_internm = p_aBuildings(i,3).mg_internd
           p_aBuildings(i,3).mg_gcertm = p_aBuildings(i,3).mg_gcertd
      ENDFOR
 ELSE
      FOR i = 1 TO ALEN(p_aBuildings,1)
           ** Financial
           * mg_monp
           p_aBuildings(i,3).mg_monp1 = p_aBuildings(i,4).mg_monp1+p_aBuildings(i,3).mg_dayp1
           p_aBuildings(i,3).mg_monp2 = p_aBuildings(i,4).mg_monp2+p_aBuildings(i,3).mg_dayp2
           p_aBuildings(i,3).mg_monp3 = p_aBuildings(i,4).mg_monp3+p_aBuildings(i,3).mg_dayp3
           p_aBuildings(i,3).mg_monp4 = p_aBuildings(i,4).mg_monp4+p_aBuildings(i,3).mg_dayp4
           p_aBuildings(i,3).mg_monp5 = p_aBuildings(i,4).mg_monp5+p_aBuildings(i,3).mg_dayp5
           p_aBuildings(i,3).mg_monp6 = p_aBuildings(i,4).mg_monp6+p_aBuildings(i,3).mg_dayp6
           p_aBuildings(i,3).mg_monp7 = p_aBuildings(i,4).mg_monp7+p_aBuildings(i,3).mg_dayp7
           p_aBuildings(i,3).mg_monp8 = p_aBuildings(i,4).mg_monp8+p_aBuildings(i,3).mg_dayp8
           p_aBuildings(i,3).mg_monp9 = p_aBuildings(i,4).mg_monp9+p_aBuildings(i,3).mg_dayp9
           * mg_mong
           p_aBuildings(i,3).mg_mong1 = p_aBuildings(i,4).mg_mong1+p_aBuildings(i,3).mg_dayg1
           p_aBuildings(i,3).mg_mong2 = p_aBuildings(i,4).mg_mong2+p_aBuildings(i,3).mg_dayg2
           p_aBuildings(i,3).mg_mong3 = p_aBuildings(i,4).mg_mong3+p_aBuildings(i,3).mg_dayg3
           p_aBuildings(i,3).mg_mong4 = p_aBuildings(i,4).mg_mong4+p_aBuildings(i,3).mg_dayg4
           p_aBuildings(i,3).mg_mong5 = p_aBuildings(i,4).mg_mong5+p_aBuildings(i,3).mg_dayg5
           p_aBuildings(i,3).mg_mong6 = p_aBuildings(i,4).mg_mong6+p_aBuildings(i,3).mg_dayg6
           p_aBuildings(i,3).mg_mong7 = p_aBuildings(i,4).mg_mong7+p_aBuildings(i,3).mg_dayg7
           p_aBuildings(i,3).mg_mong8 = p_aBuildings(i,4).mg_mong8+p_aBuildings(i,3).mg_dayg8
           p_aBuildings(i,3).mg_mong9 = p_aBuildings(i,4).mg_mong9+p_aBuildings(i,3).mg_dayg9
           * mg_mvat
           p_aBuildings(i,3).mg_mvat1 = p_aBuildings(i,4).mg_mvat1+p_aBuildings(i,3).mg_dvat1
           p_aBuildings(i,3).mg_mvat2 = p_aBuildings(i,4).mg_mvat2+p_aBuildings(i,3).mg_dvat2
           p_aBuildings(i,3).mg_mvat3 = p_aBuildings(i,4).mg_mvat3+p_aBuildings(i,3).mg_dvat3
           p_aBuildings(i,3).mg_mvat4 = p_aBuildings(i,4).mg_mvat4+p_aBuildings(i,3).mg_dvat4
           p_aBuildings(i,3).mg_mvat5 = p_aBuildings(i,4).mg_mvat5+p_aBuildings(i,3).mg_dvat5
           p_aBuildings(i,3).mg_mvat6 = p_aBuildings(i,4).mg_mvat6+p_aBuildings(i,3).mg_dvat6
           p_aBuildings(i,3).mg_mvat7 = p_aBuildings(i,4).mg_mvat7+p_aBuildings(i,3).mg_dvat7
           p_aBuildings(i,3).mg_mvat8 = p_aBuildings(i,4).mg_mvat8+p_aBuildings(i,3).mg_dvat8
           p_aBuildings(i,3).mg_mvat9 = p_aBuildings(i,4).mg_mvat9+p_aBuildings(i,3).mg_dvat9
           *
           p_aBuildings(i,3).mg_pdoutm = p_aBuildings(i,4).mg_pdoutm+p_aBuildings(i,3).mg_pdoutd
           p_aBuildings(i,3).mg_internm = p_aBuildings(i,4).mg_internm+p_aBuildings(i,3).mg_internd
           p_aBuildings(i,3).mg_gcertm = p_aBuildings(i,4).mg_gcertm+p_aBuildings(i,3).mg_gcertd
      ENDFOR
 ENDIF
 IF neWyear(lp_dSysDate)
      FOR i = 1 TO ALEN(p_aBuildings,1)
           ** Financial
           * mg_yeap
           p_aBuildings(i,3).mg_yeap1 = p_aBuildings(i,3).mg_dayp1
           p_aBuildings(i,3).mg_yeap2 = p_aBuildings(i,3).mg_dayp2
           p_aBuildings(i,3).mg_yeap3 = p_aBuildings(i,3).mg_dayp3
           p_aBuildings(i,3).mg_yeap4 = p_aBuildings(i,3).mg_dayp4
           p_aBuildings(i,3).mg_yeap5 = p_aBuildings(i,3).mg_dayp5
           p_aBuildings(i,3).mg_yeap6 = p_aBuildings(i,3).mg_dayp6
           p_aBuildings(i,3).mg_yeap7 = p_aBuildings(i,3).mg_dayp7
           p_aBuildings(i,3).mg_yeap8 = p_aBuildings(i,3).mg_dayp8
           p_aBuildings(i,3).mg_yeap9 = p_aBuildings(i,3).mg_dayp9
           * mg_yeag
           p_aBuildings(i,3).mg_yeag1 = p_aBuildings(i,3).mg_dayg1
           p_aBuildings(i,3).mg_yeag2 = p_aBuildings(i,3).mg_dayg2
           p_aBuildings(i,3).mg_yeag3 = p_aBuildings(i,3).mg_dayg3
           p_aBuildings(i,3).mg_yeag4 = p_aBuildings(i,3).mg_dayg4
           p_aBuildings(i,3).mg_yeag5 = p_aBuildings(i,3).mg_dayg5
           p_aBuildings(i,3).mg_yeag6 = p_aBuildings(i,3).mg_dayg6
           p_aBuildings(i,3).mg_yeag7 = p_aBuildings(i,3).mg_dayg7
           p_aBuildings(i,3).mg_yeag8 = p_aBuildings(i,3).mg_dayg8
           p_aBuildings(i,3).mg_yeag9 = p_aBuildings(i,3).mg_dayg9
           * mg_yvat
           p_aBuildings(i,3).mg_yvat1 = p_aBuildings(i,3).mg_dvat1
           p_aBuildings(i,3).mg_yvat2 = p_aBuildings(i,3).mg_dvat2
           p_aBuildings(i,3).mg_yvat3 = p_aBuildings(i,3).mg_dvat3
           p_aBuildings(i,3).mg_yvat4 = p_aBuildings(i,3).mg_dvat4
           p_aBuildings(i,3).mg_yvat5 = p_aBuildings(i,3).mg_dvat5
           p_aBuildings(i,3).mg_yvat6 = p_aBuildings(i,3).mg_dvat6
           p_aBuildings(i,3).mg_yvat7 = p_aBuildings(i,3).mg_dvat7
           p_aBuildings(i,3).mg_yvat8 = p_aBuildings(i,3).mg_dvat8
           p_aBuildings(i,3).mg_yvat9 = p_aBuildings(i,3).mg_dvat9
           *
           p_aBuildings(i,3).mg_pdouty = p_aBuildings(i,3).mg_pdoutd
           p_aBuildings(i,3).mg_interny = p_aBuildings(i,3).mg_internd
           p_aBuildings(i,3).mg_gcerty = p_aBuildings(i,3).mg_gcertd
      ENDFOR
 ELSE
      FOR i = 1 TO ALEN(p_aBuildings,1)
           ** Financial
           * mg_yeap
           p_aBuildings(i,3).mg_yeap1 = p_aBuildings(i,4).mg_yeap1+p_aBuildings(i,3).mg_dayp1
           p_aBuildings(i,3).mg_yeap2 = p_aBuildings(i,4).mg_yeap2+p_aBuildings(i,3).mg_dayp2
           p_aBuildings(i,3).mg_yeap3 = p_aBuildings(i,4).mg_yeap3+p_aBuildings(i,3).mg_dayp3
           p_aBuildings(i,3).mg_yeap4 = p_aBuildings(i,4).mg_yeap4+p_aBuildings(i,3).mg_dayp4
           p_aBuildings(i,3).mg_yeap5 = p_aBuildings(i,4).mg_yeap5+p_aBuildings(i,3).mg_dayp5
           p_aBuildings(i,3).mg_yeap6 = p_aBuildings(i,4).mg_yeap6+p_aBuildings(i,3).mg_dayp6
           p_aBuildings(i,3).mg_yeap7 = p_aBuildings(i,4).mg_yeap7+p_aBuildings(i,3).mg_dayp7
           p_aBuildings(i,3).mg_yeap8 = p_aBuildings(i,4).mg_yeap8+p_aBuildings(i,3).mg_dayp8
           p_aBuildings(i,3).mg_yeap9 = p_aBuildings(i,4).mg_yeap9+p_aBuildings(i,3).mg_dayp9
           * mg_yeag
           p_aBuildings(i,3).mg_yeag1 = p_aBuildings(i,4).mg_yeag1+p_aBuildings(i,3).mg_dayg1
           p_aBuildings(i,3).mg_yeag2 = p_aBuildings(i,4).mg_yeag2+p_aBuildings(i,3).mg_dayg2
           p_aBuildings(i,3).mg_yeag3 = p_aBuildings(i,4).mg_yeag3+p_aBuildings(i,3).mg_dayg3
           p_aBuildings(i,3).mg_yeag4 = p_aBuildings(i,4).mg_yeag4+p_aBuildings(i,3).mg_dayg4
           p_aBuildings(i,3).mg_yeag5 = p_aBuildings(i,4).mg_yeag5+p_aBuildings(i,3).mg_dayg5
           p_aBuildings(i,3).mg_yeag6 = p_aBuildings(i,4).mg_yeag6+p_aBuildings(i,3).mg_dayg6
           p_aBuildings(i,3).mg_yeag7 = p_aBuildings(i,4).mg_yeag7+p_aBuildings(i,3).mg_dayg7
           p_aBuildings(i,3).mg_yeag8 = p_aBuildings(i,4).mg_yeag8+p_aBuildings(i,3).mg_dayg8
           p_aBuildings(i,3).mg_yeag9 = p_aBuildings(i,4).mg_yeag9+p_aBuildings(i,3).mg_dayg9
           * mg_yvat
           p_aBuildings(i,3).mg_yvat1 = p_aBuildings(i,4).mg_yvat1+p_aBuildings(i,3).mg_dvat1
           p_aBuildings(i,3).mg_yvat2 = p_aBuildings(i,4).mg_yvat2+p_aBuildings(i,3).mg_dvat2
           p_aBuildings(i,3).mg_yvat3 = p_aBuildings(i,4).mg_yvat3+p_aBuildings(i,3).mg_dvat3
           p_aBuildings(i,3).mg_yvat4 = p_aBuildings(i,4).mg_yvat4+p_aBuildings(i,3).mg_dvat4
           p_aBuildings(i,3).mg_yvat5 = p_aBuildings(i,4).mg_yvat5+p_aBuildings(i,3).mg_dvat5
           p_aBuildings(i,3).mg_yvat6 = p_aBuildings(i,4).mg_yvat6+p_aBuildings(i,3).mg_dvat6
           p_aBuildings(i,3).mg_yvat7 = p_aBuildings(i,4).mg_yvat7+p_aBuildings(i,3).mg_dvat7
           p_aBuildings(i,3).mg_yvat8 = p_aBuildings(i,4).mg_yvat8+p_aBuildings(i,3).mg_dvat8
           p_aBuildings(i,3).mg_yvat9 = p_aBuildings(i,4).mg_yvat9+p_aBuildings(i,3).mg_dvat9
           *
           p_aBuildings(i,3).mg_pdouty = p_aBuildings(i,4).mg_pdouty+p_aBuildings(i,3).mg_pdoutd
           p_aBuildings(i,3).mg_interny = p_aBuildings(i,4).mg_interny+p_aBuildings(i,3).mg_internd
           p_aBuildings(i,3).mg_gcerty = p_aBuildings(i,4).mg_gcerty+p_aBuildings(i,3).mg_gcertd
      ENDFOR
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION NewPeriod
 PARAMETER pdDate
 PRIVATE lrEt, ncUrrent, npRevious, naRea, nrEcs
 lrEt = .F.
 IF  .NOT. FILE(gcDatadir+"PERIOD.DBF")
      lrEt = (DAY(pdDate)==1)
 ELSE
      ncUrrent = 0
      npRevious = 0
      naRea = SELECT()
      IF opEnfile(.F.,"Period")
           SELECT peRiod
           LOCATE ALL FOR BETWEEN(pdDate, pe_fromdat, pe_todat)
           IF FOUND()
                lrEt = (pdDate = pe_fromdat)
           ELSE
                lrEt = (DAY(pdDate)==1)
           ENDIF
           = clOsefile("Period")
      ENDIF
      SELECT (naRea)
 ENDIF
 RETURN lrEt
ENDFUNC
*
FUNCTION NewYear
 PARAMETER pdDate
 PRIVATE lrEt, naRea, nrEcs
 lrEt = .F.
 IF  .NOT. FILE(gcDatadir+"PERIOD.DBF")
      lrEt = (DAY(pdDate)==1 .AND. MONTH(pdDate)==1)
 ELSE
      naRea = SELECT()
      IF opEnfile(.F.,"Period")
           SELECT peRiod
           LOCATE ALL FOR BETWEEN(pdDate, pe_fromdat, pe_todat)
           IF FOUND()
                lrEt = (pe_period = 1) AND (pe_fromdat = pdDate)
           ELSE
                lrEt = (DAY(pdDate)==1 .AND. MONTH(pdDate)==1)
           ENDIF
           = clOsefile("Period")
      ENDIF
      SELECT (naRea)
 ENDIF
 RETURN lrEt
ENDFUNC
*
FUNCTION CalculateFinancial
 LPARAMETERS lp_dSysDate, lp_cResAlias
 LOCAL i, l_lVatsDefined, l_nVatValue, l_nSelect, l_cOrder, l_nPayNum, l_nArtiNum
 LOCAL ARRAY l_aVats(1)
 IF EMPTY(lp_cResAlias)
      lp_cResAlias = "reservat"
 ENDIF
 l_nPayNum = 0
 l_nArtiNum = 0
 l_lVatsDefined = .F.
 l_nSelect = SELECT()
 l_cOrder = ORDER(lp_cResAlias)
 SET ORDER TO TAG1 IN &lp_cResAlias
 SELECT pl_numcod FROM picklist WHERE pl_label = "VATGROUP" AND pl_numcod > 0 ;
           DISTINCT ORDER BY pl_numcod INTO ARRAY l_aVats
 IF _TALLY>0
      l_lVatsDefined = .T.
 ENDIF
 MNBFinancialDataGet(lp_dSysDate, lp_cResAlias)
 SELECT curPosts
 SET RELATION TO hp_origid INTO &lp_cResAlias
 IF lp_cResAlias="reservat"
      SET RELATION TO rs_roomtyp INTO roomtype IN &lp_cResAlias
 ELSE
      SET RELATION TO hr_roomtyp INTO roomtype IN &lp_cResAlias ADDITIVE
 ENDIF
 SCAN
      IF hp_reserid < 1 AND NOT EMPTY(IIF(hp_paynum = 0, NVL(ar_buildng,''), NVL(pm_buildng,'')))
           DLocate("roomtype", "rt_buildng = " + sqlcnv(IIF(hp_paynum = 0, ar_buildng, pm_buildng)))
      ENDIF
      IF EMPTY(roomtype.rt_buildng) AND NOT EMPTY(_screen.oGlobal.cStandardBuilding)
           DLocate("roomtype", "rt_buildng = " + sqlcnv(_screen.oGlobal.cStandardBuilding))
      ENDIF
      IF hp_paynum<>0
           IF NOT INLIST(hp_reserid, -2, -1, 0.200, 0.300)
                l_nPayNum = IIF(ISNULL(pm_paytyp), 1, MAX(pm_paytyp, 1))
                = AddToMngBuild("mg_dayp"+STR(l_nPayNum, 1),-hp_amount)
           ENDIF
      ELSE
           DO CASE
                CASE ar_artityp=2
                     = AddToMngBuild("mg_pdoutd",hp_amount)
                CASE ar_artityp=3
                     = AddToMngBuild("mg_internd",hp_amount)
                CASE ar_artityp=4
                     = AddToMngBuild("mg_gcertd",hp_amount)
                OTHERWISE
                     l_nArtiNum = IIF(ISNULL(ar_main), 1, MAX(ar_main, 1))
                     = AddToMngBuild("mg_dayg"+STR(l_nArtiNum, 1),hp_amount)
                     IF l_lVatsDefined
                          l_nVatValue = 0
                          FOR i = 1 TO ALEN(l_aVats,1)
                               l_nVatValue = l_nVatValue + EVALUATE("hp_Vat"+STR(l_aVats(i),1))
                          ENDFOR
                          = AddToMngBuild("mg_dvat"+STR(l_nArtiNum,1), l_nVatValue)
                     ENDIF
           ENDCASE
      ENDIF
 ENDSCAN
 SET RELATION OFF INTO roomtype IN &lp_cResAlias
 USE IN curPosts
 SET ORDER TO l_cOrder IN &lp_cResAlias
 SELECT (l_nSelect)
 RETURN .T.
ENDFUNC
*
FUNCTION CalculateLedger
 LOCAL i, l_nTotdayGroup, l_nTotdayPay, l_nTotdayVat, l_cMacro, l_nMainGr
 i = 1
 DO WHILE i <= ALEN(p_aBuildings,1)
      l_nTotdayGroup = 0
      l_nTotdayPay = 0
      l_nTotdayVat = 0
      FOR l_nMainGr = 1 TO 9
           l_cMacro = "p_aBuildings(i,3).mg_dayg"+STR(l_nMainGr, 1)
           l_nTotdayGroup = l_nTotdayGroup+EVALUATE(l_cMacro)
           l_cMacro = "p_aBuildings(i,3).mg_dayp"+STR(l_nMainGr, 1)
           l_nTotdayPay = l_nTotdayPay+EVALUATE(l_cMacro)
           l_cMacro = "p_aBuildings(i,3).mg_dvat"+STR(l_nMainGr, 1)
           l_nTotdayVat = l_nTotdayVat+EVALUATE(l_cMacro)
      ENDFOR
      IF paRam.pa_exclvat
           p_aBuildings(i,3).mg_gstldg = p_aBuildings(i,4).mg_gstldg+l_nTotdayGroup+ ;
                l_nTotdayVat+p_aBuildings(i,3).mg_pdoutd+p_aBuildings(i,3).mg_internd+ ;
                p_aBuildings(i,3).mg_gcertd-l_nTotdayPay
      ELSE
           p_aBuildings(i,3).mg_gstldg = p_aBuildings(i,4).mg_gstldg+ ;
                l_nTotdayGroup+p_aBuildings(i,3).mg_pdoutd+p_aBuildings(i,3).mg_internd+ ;
                p_aBuildings(i,3).mg_gcertd-l_nTotdayPay
      ENDIF
      p_aBuildings(i,3).mg_gcldg = p_aBuildings(i,4).mg_gcldg+p_aBuildings(i,3).mg_gcertd-; 
           p_aBuildings(i,3).mg_dayp7
      i = i + 1
 ENDDO
 RETURN .T.
ENDFUNC
*
FUNCTION CalculateDeposit
 LOCAL l_nCredit, l_nTransfer, i, l_nSelect, l_lUsedDeposit, l_cOrderDeposit
 IF NOT _screen.dp
      RETURN .T.
 ENDIF
 l_nSelect = SELECT()
 l_lUsedDeposit = USED("deposit")
 IF NOT l_lUsedDeposit
      openfiledirect(.F.,"deposit")
 ELSE
      l_cOrderDeposit = ORDER("deposit")
      SET ORDER TO "" IN deposit
 ENDIF
 IF NOT USED("deposit")
      RETURN .F.
 ENDIF
 i = 1
 DO WHILE i <= ALEN(p_aBuildings,1)
      l_nCredit = 0
      l_nTransfer = 0
      SELECT deposit
      SET RELATION TO dp_reserid INTO reservat
      SET RELATION TO rs_roomtyp INTO roomtype IN reservat
      SCAN FOR dp_sysdate = g_sysdate AND &p_aBuildings(i,2)
           l_nCredit = l_nCredit + dp_credit
      ENDSCAN
      SCAN FOR dp_posted = g_sysdate AND &p_aBuildings(i,2)
           l_nTransfer = l_nTransfer + dp_credit
      ENDSCAN
      p_aBuildings(i,3).mg_dldgdeb = l_nTransfer
      p_aBuildings(i,3).mg_dldgcrd = l_nCredit
      IF p_aBuildings(i,5)
           p_aBuildings(i,3).mg_dldg = p_aBuildings(i,4).mg_dldg+l_nCredit-l_nTransfer
      ELSE
           p_aBuildings(i,3).mg_dldg = l_nCredit-l_nTransfer
      ENDIF
      i = i + 1
 ENDDO
 SET RELATION TO
 SET RELATION OFF INTO roomtype IN reservat
 IF NOT l_lUsedDeposit
      USE IN deposit
 ELSE
      SET ORDER TO l_cOrderDeposit IN deposit
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDFUNC
*
FUNCTION CalculateAr
 LOCAL i, l_nSelect, l_lUsedArpost, l_cOrderArpost, l_nDebit, l_nCredit
 IF NOT _screen.dv
      RETURN .T.
 ENDIF
 l_nSelect = SELECT()
 l_lUsedArpost = USED("arpost")
 IF NOT l_lUsedArpost
      openfiledirect(.F.,"arpost")
 ELSE
      l_cOrderArpost = ORDER("arpost")
      SET ORDER TO "" IN arpost
 ENDIF
 IF NOT USED("arpost")
      RETURN .F.
 ENDIF
 SET RELATION TO ap_reserid INTO reservat IN arpost
 SET RELATION TO rs_roomtyp INTO roomtype IN reservat
 i = 1
 DO WHILE i <= ALEN(p_aBuildings,1)
      l_nDebit = 0
      l_nCredit = 0
      SELECT arpost
      SCAN FOR ap_sysdate = g_sysdate AND NOT ap_hiden AND &p_aBuildings(i,2)
           l_nDebit = l_nDebit + ap_debit
           l_nCredit = l_nCredit + ap_credit
      ENDSCAN
      p_aBuildings(i,3).mg_cldgdeb = l_nDebit
      p_aBuildings(i,3).mg_cldgcrd = l_nCredit
      IF p_aBuildings(i,5)
           p_aBuildings(i,3).mg_cldg = p_aBuildings(i,4).mg_cldg+l_nDebit-l_nCredit
      ELSE
           p_aBuildings(i,3).mg_cldg = l_nDebit-l_nCredit
      ENDIF
      i = i + 1
 ENDDO
 SET RELATION TO
 SET RELATION OFF INTO roomtype IN reservat
 IF NOT l_lUsedArpost
      USE IN arpost
 ELSE
      SET ORDER TO l_cOrderArpost IN arpost
 ENDIF
 SELECT (l_nSelect)
ENDFUNC
*
FUNCTION PreapareForRecalc
 LPARAMETERS lp_dDate
 LOCAL l_cCopyName, i
 l_cCopyName = _screen.oGlobal.choteldir+"tmp\"+DTOS(g_sysdate)+".mnb"
 SELECT mngbuild
 COPY TO (l_cCopyName) ALL
 FOR i = 1 TO ALEN(p_aBuildings,1)
      IF NOT SEEK(DTOS(lp_dDate)+p_aBuildings(i,1),"mngbuild","tag1")
           INSERT INTO mngbuild (mg_mngbid,mg_date,mg_buildng) VALUES ;
                (DTOS(lp_dDate)+p_aBuildings(i,1),lp_dDate,p_aBuildings(i,1))
      ENDIF   
 ENDFOR
 SELECT mngbuild
 SET ORDER TO TAG2
 IF SEEK(DTOS(lp_dDate))
      REPLACE mg_dayg1 WITH 0, ;
           mg_dayg2 WITH 0, ;
           mg_dayg3 WITH 0, ;
           mg_dayg4 WITH 0, ;
           mg_dayg5 WITH 0, ;
           mg_dayg6 WITH 0, ;
           mg_dayg7 WITH 0, ;
           mg_dayg8 WITH 0, ;
           mg_dayg9 WITH 0, ;
           mg_dayp1 WITH 0, ;
           mg_dayp2 WITH 0, ;
           mg_dayp3 WITH 0, ;
           mg_dayp4 WITH 0, ;
           mg_dayp5 WITH 0, ;
           mg_dayp6 WITH 0, ;
           mg_dayp7 WITH 0, ;
           mg_dayp8 WITH 0, ;
           mg_dayp9 WITH 0, ;
           mg_dvat1 WITH 0, ;
           mg_dvat2 WITH 0, ;
           mg_dvat3 WITH 0, ;
           mg_dvat4 WITH 0, ;
           mg_dvat5 WITH 0, ;
           mg_dvat6 WITH 0, ;
           mg_dvat7 WITH 0, ;
           mg_dvat8 WITH 0, ;
           mg_dvat9 WITH 0, ;
           mg_mong1 WITH 0, ;
           mg_mong2 WITH 0, ;
           mg_mong3 WITH 0, ;
           mg_mong4 WITH 0, ;
           mg_mong5 WITH 0, ;
           mg_mong6 WITH 0, ;
           mg_mong7 WITH 0, ;
           mg_mong8 WITH 0, ;
           mg_mong9 WITH 0, ;
           mg_monp1 WITH 0, ;
           mg_monp2 WITH 0, ;
           mg_monp3 WITH 0, ;
           mg_monp4 WITH 0, ;
           mg_monp5 WITH 0, ;
           mg_monp6 WITH 0, ;
           mg_monp7 WITH 0, ;
           mg_monp8 WITH 0, ;
           mg_monp9 WITH 0, ;
           mg_mvat1 WITH 0, ;
           mg_mvat2 WITH 0, ;
           mg_mvat3 WITH 0, ;
           mg_mvat4 WITH 0, ;
           mg_mvat5 WITH 0, ;
           mg_mvat6 WITH 0, ;
           mg_mvat7 WITH 0, ;
           mg_mvat8 WITH 0, ;
           mg_mvat9 WITH 0, ;
           mg_yeag1 WITH 0, ;
           mg_yeag2 WITH 0, ;
           mg_yeag3 WITH 0, ;
           mg_yeag4 WITH 0, ;
           mg_yeag5 WITH 0, ;
           mg_yeag6 WITH 0, ;
           mg_yeag7 WITH 0, ;
           mg_yeag8 WITH 0, ;
           mg_yeag9 WITH 0, ;
           mg_yeap1 WITH 0, ;
           mg_yeap2 WITH 0, ;
           mg_yeap3 WITH 0, ;
           mg_yeap4 WITH 0, ;
           mg_yeap5 WITH 0, ;
           mg_yeap6 WITH 0, ;
           mg_yeap7 WITH 0, ;
           mg_yeap8 WITH 0, ;
           mg_yeap9 WITH 0, ;
           mg_yvat1 WITH 0, ;
           mg_yvat2 WITH 0, ;
           mg_yvat3 WITH 0, ;
           mg_yvat4 WITH 0, ;
           mg_yvat5 WITH 0, ;
           mg_yvat6 WITH 0, ;
           mg_yvat7 WITH 0, ;
           mg_yvat8 WITH 0, ;
           mg_yvat9 WITH 0, ;
           mg_gstldg WITH 0, ;
           mg_pdoutd WITH 0, ;
           mg_pdoutm WITH 0, ;
           mg_pdouty WITH 0, ;
           mg_internd WITH 0, ;
           mg_internm WITH 0, ;
           mg_interny WITH 0, ;
           mg_gcertd WITH 0, ;
           mg_gcertm WITH 0, ;
           mg_gcerty WITH 0, ;
           mg_arrival WITH 0, ;
           mg_departu WITH 0, ;
           mg_resnew WITH 0, ;
           mg_rescxl WITH 0, ;
           mg_optcxl WITH 0, ;
           mg_tencxl WITH 0, ;
           mg_resns WITH 0, ;
           mg_persarr WITH 0, ;
           mg_persdep WITH 0, ;
           mg_roomarr WITH 0, ;
           mg_roomdep WITH 0, ;
           mg_rmduse WITH 0, ;
           mg_prduse WITH 0, ;
           mg_roomocc WITH 0, ;
           mg_bedocc WITH 0, ;
           mg_comprmd WITH 0, ;
           mg_compprd WITH 0, ;
           mg_roomoos WITH 0, ;
           mg_bedoos WITH 0 REST
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION RecalculateOccupancy
 LPARAMETERS lp_dStartDate
 LOCAL l_oEnvironment, l_nRoomsAvailable, l_nBedsAvailable, l_nBuildingNo
 PRIVATE p_dStartDate, p_lAdd
 p_dStartDate = lp_dStartDate
 p_lAdd = .T.     && Add values in RecalcAddToMngBuild()

 l_oEnvironment = SetEnvironment("mngbuild, roomtype, room, outoford, houtofor, outofser, houtofsr", ", tag1")

 SET RELATION TO rm_roomtyp INTO roomtype IN room
 FOR l_nBuildingNo = 1 TO ALEN(p_aBuildings,1)
     SELECT room
     COUNT FOR roomtype.rt_group = 1 AND roomtype.rt_vwsum AND &p_aBuildings(l_nBuildingNo,2) TO l_nRoomsAvailable
     SUM rm_beds FOR roomtype.rt_group = 1 AND roomtype.rt_vwsum AND &p_aBuildings(l_nBuildingNo,2) TO l_nBedsAvailable
     SELECT mngbuild
     SCAN FOR BETWEEN(DTOS(mg_date),DTOS(p_dStartDate),DTOS(g_sysdate-1)) AND mg_buildng = p_aBuildings(l_nBuildingNo,1)
          IF HotelClosed(mngbuild.mg_date)
               REPLACE mg_roomavl WITH 0 IN mngbuild
               REPLACE mg_bedavl WITH 0 IN mngbuild
          ELSE
               IF EMPTY(mngbuild.mg_roomavl)
                    REPLACE mg_roomavl WITH l_nRoomsAvailable IN mngbuild
               ENDIF
               IF EMPTY(mngbuild.mg_bedavl)
                    REPLACE mg_bedavl WITH l_nBedsAvailable IN mngbuild
               ENDIF
          ENDIF
     ENDSCAN
 NEXT
 SELECT room
 SET RELATION TO

 SELECT mg_mngbid FROM mngbuild;
      WHERE BETWEEN(DTOS(mg_date),DTOS(p_dStartDate),DTOS(g_sysdate-1)) AND ;
      (NOT EMPTY(mg_roomooo) OR NOT EMPTY(mg_bedooo)) ;
      ORDER BY mg_date INTO CURSOR curMnbOOO
 INDEX ON mg_mngbid TAG tag1

 SELECT oo_roomnum, oo_fromdat, oo_todat, rm_beds, rm_roomtyp FROM outoford ;
      LEFT JOIN room ON oo_roomnum = rm_roomnum ;
      LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
      WHERE rt_group = 1 AND rt_vwsum ;
      UNION SELECT oo_roomnum, oo_fromdat, oo_todat, rm_beds, rm_roomtyp FROM houtofor ;
           LEFT JOIN room ON oo_roomnum = rm_roomnum ;
           LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
           WHERE rt_group = 1 AND rt_vwsum ;
      INTO CURSOR curOutoford

 SELECT os_roomnum, os_fromdat, os_todat, rm_beds, rm_roomtyp FROM outofser ;
      LEFT JOIN room ON os_roomnum = rm_roomnum ;
      LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
      WHERE rt_group = 1 AND rt_vwsum ;
      UNION SELECT os_roomnum, os_fromdat, os_todat, rm_beds, rm_roomtyp FROM houtofsr ;
           LEFT JOIN room ON os_roomnum = rm_roomnum ;
           LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
           WHERE rt_group = 1 AND rt_vwsum ;
      INTO CURSOR curOutofser

 LOCAL ARRAY l_aTasks(5,2)
 l_aTasks(1,1) = RECCOUNT("curOutOfOrd")
 l_aTasks(1,2) = GetLangText("MNGBUILD","TXT_OUTOFORDOCCRBLD")+"..."
 l_aTasks(2,1) = RECCOUNT("curOutOfSer")
 l_aTasks(2,2) = GetLangText("MNGBUILD","TXT_OUTOFSEROCCRBLD")+"..."
 l_aTasks(3,1) = RECCOUNT("reservat")
 l_aTasks(3,2) = GetLangText("MNGBUILD","TXT_RESERVATOCCRBLD")+"..."
 l_aTasks(4,1) = RECCOUNT("histres")
 l_aTasks(4,2) = GetLangText("MNGBUILD","TXT_HISTRESOCCRBLD")+"..."
 l_aTasks(5,1) = RECCOUNT("sharing")
 l_aTasks(5,2) = GetLangText("MNGBUILD","TXT_SHARINGOCCRBLD")+"..."
 DO FORM forms\ProgressBar NAME ProgressBar WITH GetLangText("MNGBUILD","TXT_OCCRBLD"), l_aTasks
 = RecalcManagerBuildingsOutOfOrder()
 = RecalcManagerBuildingsOutOfService()
 = RecalcManagerBuildingsReservationOccupancy()
 = RecalcManagerBuildingsHistReservationOccupancy()
 = RecalcManagerBuildingsSharingOccupancy()
 ProgressBar.Complete()
 FOR l_nBuildingNo = 1 TO ALEN(p_aBuildings,1)
      WAIT WINDOW "Processing cumulative data for "+p_aBuildings(l_nBuildingNo,1)+"..." NOWAIT
      = RecalcCumulativeFields(p_aBuildings(l_nBuildingNo,1))
 ENDFOR
 WAIT CLEAR
ENDFUNC
*
PROCEDURE RecalcManagerBuildingsOutOfOrder
 LOCAL l_oEnvironment, l_dDate
 l_oEnvironment = SetEnvironment("mngbuild, roomtype", ", tag1")
 SELECT curOutoford
 SET RELATION TO rm_roomtyp INTO roOmtype
 SCAN
      ProgressBar.Update(RECNO(),1)
      l_dDate = oo_fromdat
      DO WHILE l_dDate < oo_todat
           = RecalcAddToMngBuild("mg_roomooo",1,l_dDate)
           = RecalcAddToMngBuild("mg_bedooo",rm_beds,l_dDate)
           l_dDate = l_dDate + 1
      ENDDO
 ENDSCAN
 SET RELATION TO
 USE IN curOutoford
 USE IN curMnbOOO
ENDPROC
*
PROCEDURE RecalcManagerBuildingsOutOfService
 LOCAL l_oEnvironment, l_dDate
 l_oEnvironment = SetEnvironment("mngbuild, roomtype", ", tag1")
 SELECT curOutofser
 SET RELATION TO rm_roomtyp INTO roOmtype
 SCAN
      ProgressBar.Update(RECNO(),2)
      l_dDate = os_fromdat
      DO WHILE l_dDate < os_todat
           = RecalcAddToMngBuild("mg_roomoos",1,l_dDate)
           = RecalcAddToMngBuild("mg_bedoos",rm_beds,l_dDate)
           l_dDate = l_dDate + 1
      ENDDO
 ENDSCAN
 SET RELATION TO
 USE IN curOutofser
ENDPROC
*
PROCEDURE RecalcManagerBuildingsReservationOccupancy
 LOCAL l_oEnvironment, l_lComplim, l_nMultiplier, l_dDate, l_lGetResState
 LOCAL l_oResCurrent, l_oResArrival, l_oResDeparture, l_oResNext, l_nRecnoArr, l_nRecnoDep
 LOCAL l_lCurrStandard, l_lStandardInArrival, l_lStandardInDeparture, l_lPreviousStandard
 LOCAL l_nCurrPersons, l_nArrPersons, l_nDepPersons, l_nPreviousPersons, l_nPreviousRecno
 LOCAL l_lCurrSharing, l_lSharingArr, l_lSharingDep, l_lPreviousSharing, l_nCurrRecno
 l_oEnvironment = SetEnvironment("mngbuild, reservat, roomtype, room, resrooms, resrate")
 SELECT reservat
 SCAN
      ProgressBar.Update(RECNO(),3)
      * Taking reservation state for arrival date.
      RiGetRoom(reservat.rs_reserid, reservat.rs_arrdate, @l_oResArrival)
      l_lSharingArr = NOT (ISNULL(l_oResArrival) OR EMPTY(l_oResArrival.ri_shareid))
      IF ISNULL(l_oResArrival)
           = SEEK(reservat.rs_roomtyp,"roomtype","tag1")
      ELSE
           = SEEK(l_oResArrival.ri_roomtyp,"roomtype","tag1")
      ENDIF
      l_nRecnoArr = RECNO("roomtype")
      l_lStandardInArrival = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
      IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(reservat.rs_arrdate),"resrate","tag2")
           l_nArrPersons = resrate.rr_adults+resrate.rr_childs+resrate.rr_childs2+resrate.rr_childs3
      ELSE
           l_nArrPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
      ENDIF
      IF l_lStandardInArrival AND NOT EMPTY(rs_created)
           GO l_nRecnoArr IN roomtype
           RecalcAddToMngBuild("mg_resnew",rs_rooms,rs_created)
      ENDIF

      IF (rs_arrdate <= g_sysdate) AND NOT INLIST(rs_status,"CXL","NS")
           * Taking reservation state for departure date.
           RiGetRoom(reservat.rs_reserid, reservat.rs_depdate, @l_oResDeparture)
           l_lSharingDep = NOT (ISNULL(l_oResDeparture) OR EMPTY(l_oResDeparture.ri_shareid))
           IF ISNULL(l_oResDeparture)
                = SEEK(reservat.rs_roomtyp,"roomtype","tag1")
           ELSE
                = SEEK(l_oResDeparture.ri_roomtyp,"roomtype","tag1")
           ENDIF
           l_nRecnoDep = RECNO("roomtype")
           l_lStandardInDeparture = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
           IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(MAX(reservat.rs_arrdate,reservat.rs_depdate-1)),"resrate","tag2")
                l_nDepPersons = resrate.rr_adults+resrate.rr_childs+resrate.rr_childs2+resrate.rr_childs3
           ELSE
                l_nDepPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
           ENDIF
           IF l_lStandardInArrival AND NOT l_lSharingArr
                GO l_nRecnoArr IN roomtype
                RecalcAddToMngBuild("mg_arrival",rs_rooms,rs_arrdate-1)
           ENDIF
           IF l_lStandardInDeparture AND NOT l_lSharingDep
                GO l_nRecnoDep IN roomtype
                RecalcAddToMngBuild("mg_departu",rs_rooms,rs_depdate-1)
           ENDIF
      ENDIF

      DO CASE
           CASE l_lStandardInArrival AND INLIST(rs_status, "CXL", "NS") AND INLIST(rs_cxlstat, "OPT", "LST", "TEN")
                GO l_nRecnoArr IN roomtype
                IF rs_cxlstat = "TEN"
                     RecalcAddToMngBuild("mg_tencxl",rs_rooms,rs_cxldate)
                ELSE
                     RecalcAddToMngBuild("mg_optcxl",rs_rooms,rs_cxldate)
                ENDIF
           CASE l_lStandardInArrival AND (rs_status = "CXL")
                GO l_nRecnoArr IN roomtype
                RecalcAddToMngBuild("mg_rescxl",rs_rooms,rs_cxldate)
           CASE l_lStandardInArrival AND (rs_status = "NS")
                GO l_nRecnoArr IN roomtype
                RecalcAddToMngBuild("mg_resns",rs_rooms,rs_cxldate)
           CASE (rs_arrdate < g_sysdate) AND INLIST(rs_status, "IN", "OUT")
                IF l_lStandardInArrival
                     GO l_nRecnoArr IN roomtype
                     IF NOT l_lSharingArr
                          RecalcAddToMngBuild("mg_roomarr",rs_rooms,rs_arrdate)
                     ENDIF
                     RecalcAddToMngBuild("mg_persarr",l_nArrPersons,rs_arrdate)
                ENDIF
                IF l_lStandardInDeparture
                     GO l_nRecnoDep IN roomtype
                     IF NOT l_lSharingDep
                          RecalcAddToMngBuild("mg_roomdep",rs_rooms,rs_depdate)
                     ENDIF
                     RecalcAddToMngBuild("mg_persdep",l_nDepPersons,rs_depdate)
                ENDIF
                IF rs_arrdate = rs_depdate
                     IF l_lStandardInDeparture
                          IF rs_status = "OUT"
                               GO l_nRecnoDep IN roomtype
                               IF NOT l_lSharingDep
                                    RecalcAddToMngBuild("mg_rmduse",rs_rooms,rs_depdate)
                               ENDIF
                               RecalcAddToMngBuild("mg_prduse",l_nDepPersons,rs_depdate)
                          ELSE
                               * Checked reservation would be proccessed in audit
                          ENDIF
                     ENDIF
                ELSE
                     l_lPreviousStandard = l_lStandardInArrival
                     l_nPreviousPersons = l_nArrPersons
                     l_lPreviousSharing = l_lSharingArr
                     l_nPreviousRecno = l_nRecnoArr
                     l_oResCurrent = .NULL.
                     l_oResNext = .NULL.
                     l_dDate = rs_arrdate
                     DO WHILE l_dDate < rs_depdate
                          l_lGetResState = (l_dDate = rs_arrdate) OR ISNULL(l_oResCurrent) OR ISNULL(l_oResNext) OR NOT BETWEEN(l_dDate, l_oResCurrent.ri_date, l_oResNext.ri_date-1)
                          IF l_lGetResState
                               RiGetRoom(reservat.rs_reserid, l_dDate, @l_oResCurrent, @l_oResNext)
                               l_lCurrSharing = NOT (ISNULL(l_oResCurrent) OR EMPTY(l_oResCurrent.ri_shareid))
                               IF ISNULL(l_oResCurrent)
                                    = SEEK(reservat.rs_roomtyp,"roomtype","tag1")
                                    = SEEK(reservat.rs_roomnum,"room","tag1")
                               ELSE
                                    = SEEK(l_oResCurrent.ri_roomtyp,"roomtype","tag1")
                                    = SEEK(l_oResCurrent.ri_roomnum,"room","tag1")
                               ENDIF
                               l_lCurrStandard = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
                               l_nCurrRecno = RECNO("roomtype")
                          ENDIF
                          IF l_lCurrStandard
                               IF roomtype.rt_group = 4
                                    l_nMultiplier = OCCURS(",", room.rm_link) + 1
                               ELSE
                                    l_nMultiplier = 1
                               ENDIF
                               IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(l_dDate),"resrate","tag2")
                                    l_nCurrPersons = resrate.rr_adults+resrate.rr_childs+resrate.rr_childs2+resrate.rr_childs3
                               ELSE
                                    l_nCurrPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
                               ENDIF
                               IF NOT l_lCurrSharing
                                    RecalcAddToMngBuild("mg_roomocc",rs_rooms*l_nMultiplier,l_dDate)
                               ENDIF
                               RecalcAddToMngBuild("mg_bedocc",l_nCurrPersons,l_dDate)
                               IF rs_complim
                                    IF NOT l_lCurrSharing
                                         RecalcAddToMngBuild("mg_comprmd",rs_rooms*l_nMultiplier,l_dDate)
                                    ENDIF
                                    RecalcAddToMngBuild("mg_compprd",l_nCurrPersons,l_dDate)
                               ENDIF
                          ENDIF
                          IF NOT l_lPreviousStandard AND l_lCurrStandard
                          * Rellocation from non standard room to standard (new arrival rooms)
                               IF NOT l_lCurrSharing
                                    RecalcAddToMngBuild("mg_roomarr",rs_rooms,l_dDate)
                               ENDIF
                               RecalcAddToMngBuild("mg_persarr",l_nCurrPersons,l_dDate)
                          ENDIF
                          IF l_lPreviousStandard AND NOT l_lCurrStandard
                          * Rellocation from standard room to non standard (new departure rooms)
                               GO l_nPreviousRecno IN roomtype
                               IF NOT l_lPreviousSharing
                                    RecalcAddToMngBuild("mg_roomdep",rs_rooms,l_dDate)
                               ENDIF
                               RecalcAddToMngBuild("mg_persdep",l_nPreviousPersons,l_dDate)
                               GO l_nCurrRecno IN roomtype
                          ENDIF
                          l_lPreviousStandard = l_lCurrStandard
                          l_nPreviousPersons = l_nCurrPersons
                          l_lPreviousSharing = l_lCurrSharing
                          l_nPreviousRecno = l_nCurrRecno
                          l_dDate = l_dDate + 1
                     ENDDO
                ENDIF
      ENDCASE
 ENDSCAN
ENDPROC
*
PROCEDURE RecalcManagerOneHistReservationOccupancy
 LOCAL l_nMultiplier, l_dDate, l_lGetResState
 LOCAL l_oResCurrent, l_oResArrival, l_oResDeparture, l_oResNext, l_nRecnoArr, l_nRecnoDep
 LOCAL l_lCurrStandard, l_lStandardInArrival, l_lStandardInDeparture, l_lPreviousStandard
 LOCAL l_nCurrPersons, l_nArrPersons, l_nDepPersons, l_nPreviousPersons, l_nPreviousRecno
 LOCAL l_lCurrSharing, l_lSharingArr, l_lSharingDep, l_lPreviousSharing, l_nCurrRecno

 * Taking reservation state for arrival date.
 =SEEK(histres.hr_rsid,"hresext","tag3")
 RiGetRoom(histres.hr_reserid, histres.hr_arrdate, @l_oResArrival, .NULL., "hresroom")
 l_lSharingArr = NOT (ISNULL(l_oResArrival) OR EMPTY(l_oResArrival.ri_shareid))
 IF ISNULL(l_oResArrival)
      = SEEK(histres.hr_roomtyp,"roomtype","tag1")
 ELSE
      = SEEK(l_oResArrival.ri_roomtyp,"roomtype","tag1")
 ENDIF
 l_nRecnoArr = RECNO("roomtype")
 l_lStandardInArrival = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
 IF SEEK(STR(histres.hr_reserid,12,3)+DTOS(histres.hr_arrdate),"hresrate","tag2")
      l_nArrPersons = hresrate.rr_adults+hresrate.rr_childs+hresrate.rr_childs2+hresrate.rr_childs3
 ELSE
      l_nArrPersons = histres.hr_adults+histres.hr_childs+histres.hr_childs2+histres.hr_childs3
 ENDIF
 IF l_lStandardInArrival AND NOT EMPTY(hr_created)
      GO l_nRecnoArr IN roomtype
      RecalcAddToMngBuild("mg_resnew",hr_rooms,hr_created)
 ENDIF

 IF NOT INLIST(hr_status,"CXL","NS")
      * Taking reservation state for departure date.
      RiGetRoom(histres.hr_reserid, histres.hr_depdate, @l_oResDeparture, .NULL., "hresroom")
      l_lSharingDep = NOT (ISNULL(l_oResDeparture) OR EMPTY(l_oResDeparture.ri_shareid))
      IF ISNULL(l_oResDeparture)
           = SEEK(histres.hr_roomtyp,"roomtype","tag1")
      ELSE
           = SEEK(l_oResDeparture.ri_roomtyp,"roomtype","tag1")
      ENDIF
      l_nRecnoDep = RECNO("roomtype")
      l_lStandardInDeparture = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
      IF SEEK(STR(histres.hr_reserid,12,3)+DTOS(MAX(histres.hr_arrdate,histres.hr_depdate-1)),"hresrate","tag2")
           l_nDepPersons = hresrate.rr_adults+hresrate.rr_childs+hresrate.rr_childs2+hresrate.rr_childs3
      ELSE
           l_nDepPersons = histres.hr_adults+histres.hr_childs+histres.hr_childs2+histres.hr_childs3
      ENDIF
 ENDIF

 DO CASE
      CASE l_lStandardInArrival AND INLIST(hr_status, "CXL", "NS") AND INLIST(hresext.rs_cxlstat, "OPT", "LST", "TEN")
           GO l_nRecnoArr IN roomtype
           IF hresext.rs_cxlstat = "TEN"
                RecalcAddToMngBuild("mg_tencxl",hr_rooms,hr_cxldate)
           ELSE
                RecalcAddToMngBuild("mg_optcxl",hr_rooms,hr_cxldate)
           ENDIF
      CASE l_lStandardInArrival AND (hr_status = "CXL")
           GO l_nRecnoArr IN roomtype
           RecalcAddToMngBuild("mg_rescxl",hr_rooms,hr_cxldate)
      CASE l_lStandardInArrival AND (hr_status = "NS")
           GO l_nRecnoArr IN roomtype
           RecalcAddToMngBuild("mg_resns",hr_rooms,hr_cxldate)
      CASE INLIST(hr_status, "IN", "OUT")
           IF l_lStandardInArrival
                GO l_nRecnoArr IN roomtype
                IF NOT l_lSharingArr
                     RecalcAddToMngBuild("mg_roomarr",hr_rooms,hr_arrdate)
                     RecalcAddToMngBuild("mg_arrival",hr_rooms,hr_arrdate-1)
                ENDIF
                RecalcAddToMngBuild("mg_persarr",l_nArrPersons,hr_arrdate)
           ENDIF
           IF l_lStandardInDeparture
                GO l_nRecnoDep IN roomtype
                IF NOT l_lSharingDep
                     RecalcAddToMngBuild("mg_roomdep",hr_rooms,hr_depdate)
                     RecalcAddToMngBuild("mg_departu",hr_rooms,hr_depdate-1)
                ENDIF
                RecalcAddToMngBuild("mg_persdep",l_nDepPersons,hr_depdate)
           ENDIF
           IF hr_arrdate = hr_depdate
                IF l_lStandardInDeparture
                     IF hr_status = "OUT"
                          GO l_nRecnoDep IN roomtype
                          IF NOT l_lSharingDep
                               RecalcAddToMngBuild("mg_rmduse",hr_rooms,hr_depdate)
                          ENDIF
                          RecalcAddToMngBuild("mg_prduse",l_nDepPersons,hr_depdate)
                     ELSE
                          * Checked reservation would be proccessed in audit
                     ENDIF
                ENDIF
           ELSE
                l_lPreviousStandard = l_lStandardInArrival
                l_nPreviousPersons = l_nArrPersons
                l_lPreviousSharing = l_lSharingArr
                l_nPreviousRecno = l_nRecnoArr
                l_oResCurrent = .NULL.
                l_oResNext = .NULL.
                l_dDate = hr_arrdate
                DO WHILE l_dDate < hr_depdate
                     l_lGetResState = (l_dDate = hr_arrdate) OR ISNULL(l_oResCurrent) OR ISNULL(l_oResNext) OR NOT BETWEEN(l_dDate, l_oResCurrent.ri_date, l_oResNext.ri_date-1)
                     IF l_lGetResState
                          RiGetRoom(histres.hr_reserid, l_dDate, @l_oResCurrent, @l_oResNext, "hresroom")
                          l_lCurrSharing = NOT (ISNULL(l_oResCurrent) OR EMPTY(l_oResCurrent.ri_shareid))
                          IF ISNULL(l_oResCurrent)
                               = SEEK(histres.hr_roomtyp,"roomtype","tag1")
                               = SEEK(histres.hr_roomnum,"room","tag1")
                          ELSE
                               = SEEK(l_oResCurrent.ri_roomtyp,"roomtype","tag1")
                               = SEEK(l_oResCurrent.ri_roomnum,"room","tag1")
                          ENDIF
                          l_lCurrStandard = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
                          l_nCurrRecno = RECNO("roomtype")
                     ENDIF
                     IF l_lCurrStandard
                          IF roomtype.rt_group = 4
                               l_nMultiplier = OCCURS(",", room.rm_link) + 1
                          ELSE
                               l_nMultiplier = 1
                          ENDIF
                          IF SEEK(STR(histres.hr_reserid,12,3)+DTOS(l_dDate),"hresrate","tag2")
                               l_nCurrPersons = hresrate.rr_adults+hresrate.rr_childs+hresrate.rr_childs2+hresrate.rr_childs3
                          ELSE
                               l_nCurrPersons = histres.hr_adults+histres.hr_childs+histres.hr_childs2+histres.hr_childs3
                          ENDIF
                          IF NOT l_lCurrSharing
                               RecalcAddToMngBuild("mg_roomocc",hr_rooms*l_nMultiplier,l_dDate)
                          ENDIF
                          RecalcAddToMngBuild("mg_bedocc",l_nCurrPersons,l_dDate)
                          IF hr_complim
                               IF NOT l_lCurrSharing
                                    RecalcAddToMngBuild("mg_comprmd",hr_rooms*l_nMultiplier,l_dDate)
                               ENDIF
                               RecalcAddToMngBuild("mg_compprd",l_nCurrPersons,l_dDate)
                          ENDIF
                     ENDIF
                     IF NOT l_lPreviousStandard AND l_lCurrStandard
                     * Rellocation from non standard room to standard (new arrival rooms)
                          IF NOT l_lCurrSharing
                               RecalcAddToMngBuild("mg_roomarr",hr_rooms,l_dDate)
                          ENDIF
                          RecalcAddToMngBuild("mg_persarr",l_nCurrPersons,l_dDate)
                     ENDIF
                     IF l_lPreviousStandard AND NOT l_lCurrStandard
                     * Rellocation from standard room to non standard (new departure rooms)
                          GO l_nPreviousRecno IN roomtype
                          IF NOT l_lPreviousSharing
                               RecalcAddToMngBuild("mg_roomdep",hr_rooms,l_dDate)
                          ENDIF
                          RecalcAddToMngBuild("mg_persdep",l_nPreviousPersons,l_dDate)
                          GO l_nCurrRecno IN roomtype
                     ENDIF
                     l_lPreviousStandard = l_lCurrStandard
                     l_nPreviousPersons = l_nCurrPersons
                     l_lPreviousSharing = l_lCurrSharing
                     l_nPreviousRecno = l_nCurrRecno
                     l_dDate = l_dDate + 1
                ENDDO
           ENDIF
 ENDCASE
ENDPROC
*
PROCEDURE RecalcManagerBuildingsHistReservationOccupancy
 LOCAL l_oEnvironment
 l_oEnvironment = SetEnvironment("mngbuild, histres, reservat, room, roomtype, hresroom, hresrate")
 SELECT histres
 SCAN FOR (hr_depdate > p_dStartDate) AND (hr_reserid > 1) AND NOT SEEK(hr_reserid,"reservat","tag1")
      ProgressBar.Update(RECNO(),4)
      RecalcManagerOneHistReservationOccupancy()
 ENDSCAN
ENDPROC
*
PROCEDURE RecalcManagerBuildingsSharingOccupancy
 LOCAL l_oEnvironment, l_nMultiplier, l_dDate, l_lIsArrival, l_lIsDeparture, l_lIsDayUse, l_lIsComplim
 l_oEnvironment = SetEnvironment("mngbuild, roomtype, room, sharing", ", tag1")
 SELECT sharing
 SET RELATION TO sd_roomtyp INTO roomtype
 SCAN FOR INLIST(sd_status, "IN", "OUT") AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum ;
 			AND NOT EMPTY(sd_lowdat)
      ProgressBar.Update(RECNO(),5)
      DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ARRIVAL", sd_lowdat
      IF l_lIsArrival
           RecalcAddToMngBuild("mg_arrival",1,sd_lowdat-1)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ROOMARR", sd_lowdat
      IF l_lIsArrival
           RecalcAddToMngBuild("mg_roomarr",1,sd_lowdat)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "DEPARTURE", sd_highdat+1
      IF l_lIsDeparture
           RecalcAddToMngBuild("mg_departu",1,sd_highdat)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "ROOMDEP", sd_highdat+1
      IF l_lIsDeparture
           RecalcAddToMngBuild("mg_roomdep",1,sd_highdat+1)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDayUse, sd_shareid, sd_lowdat, sd_highdat, "DAYUSE", sd_lowdat
      IF l_lIsDayUse
           IF sd_status = "OUT"
                RecalcAddToMngBuild("mg_rmduse",1,sd_lowdat)
                RecalcAddToMngBuild("mg_departu",1,sd_highdat-1)
                RecalcAddToMngBuild("mg_roomdep",1,sd_highdat)
           ENDIF
      ELSE
           DO RiShareInterval IN ProcResRooms WITH l_lIsComplim, sd_shareid, sd_lowdat, sd_highdat, "COMPLIM"
           IF (roomtype.rt_group = 4) AND SEEK(sd_roomnum,"room","tag1")
                l_nMultiplier = OCCURS(",", room.rm_link) + 1
           ELSE
                l_nMultiplier = 1
           ENDIF
           l_dDate = sd_lowdat
           DO WHILE l_dDate <= sd_highdat
                RecalcAddToMngBuild("mg_roomocc",l_nMultiplier,l_dDate)
                IF l_lIsComplim
                     RecalcAddToMngBuild("mg_comprmd",l_nMultiplier,l_dDate)
                ENDIF
                l_dDate = l_dDate + 1
           ENDDO
      ENDIF
 ENDSCAN
 SET RELATION TO
ENDPROC
*
FUNCTION RecalcAddToMngBuild
 LPARAMETERS lp_cField, lp_nValue, lp_dDate
 IF BETWEEN(lp_dDate, p_dStartDate, g_sysdate-1)
     LOCAL i
     FOR i = 1 TO ALEN(p_aBuildings,1)
          IF &p_aBuildings(i,2) AND (NOT INLIST(lp_cField,"mg_roomooo","mg_bedooo") OR ;
                    NOT SEEK(DTOS(lp_dDate)+p_aBuildings(i,1),"curMnbOOO","tag1"))
               IF SEEK(DTOS(lp_dDate)+p_aBuildings(i,1),"mngbuild","tag1")
                    REPLACE &lp_cField WITH MAX(0, &lp_cField + lp_nValue*IIF(p_lAdd,1,-1)) IN mngbuild
               ENDIF
          ENDIF
     ENDFOR
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION RecalcCumulativeFields
 LPARAMETERS l_cBuilding
 LOCAL l_oYesterday, l_oToday, l_oEnvironment
 l_oEnvironment = SetEnvironment("mngbuild")
 SELECT mngbuild
 IF SEEK(DTOS(p_dStartDate-1)+l_cBuilding,"mngbuild","tag1")
      SCATTER MEMO NAME l_oYesterday
 ELSE
      SCATTER MEMO NAME l_oYesterday BLANK
 ENDIF
 SCAN FOR (DTOS(mg_date) >= DTOS(p_dStartDate)) AND (mg_buildng == l_cBuilding)
       SCATTER MEMO NAME l_oToday
       IF NewPeriod(mg_date)
           l_oToday.mg_roomavm = l_oToday.mg_roomavl
           l_oToday.mg_bedavlm = l_oToday.mg_bedavl
           l_oToday.mg_rmooom  = l_oToday.mg_roomooo
           l_oToday.mg_rmoosm  = l_oToday.mg_roomoos
           l_oToday.mg_bdooom  = l_oToday.mg_bedooo
           l_oToday.mg_bdoosm  = l_oToday.mg_bedoos
           l_oToday.mg_rmoccm  = l_oToday.mg_roomocc
           l_oToday.mg_bdoccm  = l_oToday.mg_bedocc
           l_oToday.mg_rmarrm  = l_oToday.mg_roomarr
           l_oToday.mg_perarrm = l_oToday.mg_persarr
           l_oToday.mg_roodepm = l_oToday.mg_roomdep
           l_oToday.mg_perdepm = l_oToday.mg_persdep
           l_oToday.mg_rescxlm = l_oToday.mg_rescxl
           l_oToday.mg_optcxlm = l_oToday.mg_optcxl
           l_oToday.mg_tencxlm = l_oToday.mg_tencxl
           l_oToday.mg_cxllatm = l_oToday.mg_cxllate
           l_oToday.mg_resnsm  = l_oToday.mg_resns
           l_oToday.mg_resnewm = l_oToday.mg_resnew
           l_oToday.mg_prdusem = l_oToday.mg_prduse
           l_oToday.mg_rmdusem = l_oToday.mg_rmduse
           l_oToday.mg_comprmm = l_oToday.mg_comprmd
           l_oToday.mg_compprm = l_oToday.mg_compprd
      ELSE
           l_oToday.mg_roomavm = l_oYesterday.mg_roomavm + l_oToday.mg_roomavl
           l_oToday.mg_bedavlm = l_oYesterday.mg_bedavlm + l_oToday.mg_bedavl
           l_oToday.mg_rmooom  = l_oYesterday.mg_rmooom  + l_oToday.mg_roomooo
           l_oToday.mg_rmoosm  = l_oYesterday.mg_rmoosm  + l_oToday.mg_roomoos
           l_oToday.mg_bdooom  = l_oYesterday.mg_bdooom  + l_oToday.mg_bedooo
           l_oToday.mg_bdoosm  = l_oYesterday.mg_bdoosm  + l_oToday.mg_bedoos
           l_oToday.mg_rmoccm  = l_oYesterday.mg_rmoccm  + l_oToday.mg_roomocc
           l_oToday.mg_bdoccm  = l_oYesterday.mg_bdoccm  + l_oToday.mg_bedocc
           l_oToday.mg_rmarrm  = l_oYesterday.mg_rmarrm  + l_oToday.mg_roomarr
           l_oToday.mg_perarrm = l_oYesterday.mg_perarrm + l_oToday.mg_persarr
           l_oToday.mg_roodepm = l_oYesterday.mg_roodepm + l_oToday.mg_roomdep
           l_oToday.mg_perdepm = l_oYesterday.mg_perdepm + l_oToday.mg_persdep
           l_oToday.mg_rescxlm = l_oYesterday.mg_rescxlm + l_oToday.mg_rescxl
           l_oToday.mg_optcxlm = l_oYesterday.mg_optcxlm + l_oToday.mg_optcxl
           l_oToday.mg_tencxlm = l_oYesterday.mg_tencxlm + l_oToday.mg_tencxl
           l_oToday.mg_cxllatm = l_oYesterday.mg_cxllatm + l_oToday.mg_cxllate
           l_oToday.mg_resnsm  = l_oYesterday.mg_resnsm  + l_oToday.mg_resns
           l_oToday.mg_resnewm = l_oYesterday.mg_resnewm + l_oToday.mg_resnew
           l_oToday.mg_prdusem = l_oYesterday.mg_prdusem + l_oToday.mg_prduse
           l_oToday.mg_rmdusem = l_oYesterday.mg_rmdusem + l_oToday.mg_rmduse
           l_oToday.mg_comprmm = l_oYesterday.mg_comprmm + l_oToday.mg_comprmd
           l_oToday.mg_compprm = l_oYesterday.mg_compprm + l_oToday.mg_compprd
      ENDIF
      IF NewYear(mg_date)
           l_oToday.mg_roomavy = l_oToday.mg_roomavl
           l_oToday.mg_bedavly = l_oToday.mg_bedavl
           l_oToday.mg_rmoooy  = l_oToday.mg_roomooo
           l_oToday.mg_rmoosy  = l_oToday.mg_roomoos
           l_oToday.mg_bdoooy  = l_oToday.mg_bedooo
           l_oToday.mg_bdoosy  = l_oToday.mg_bedoos
           l_oToday.mg_rmoccy  = l_oToday.mg_roomocc
           l_oToday.mg_bdoccy  = l_oToday.mg_bedocc
           l_oToday.mg_rmarry  = l_oToday.mg_roomarr
           l_oToday.mg_perarry = l_oToday.mg_persarr
           l_oToday.mg_roodepy = l_oToday.mg_roomdep
           l_oToday.mg_perdepy = l_oToday.mg_persdep
           l_oToday.mg_rescxly = l_oToday.mg_rescxl
           l_oToday.mg_optcxly = l_oToday.mg_optcxl
           l_oToday.mg_tencxly = l_oToday.mg_tencxl
           l_oToday.mg_cxllaty = l_oToday.mg_cxllate
           l_oToday.mg_resnsy  = l_oToday.mg_resns
           l_oToday.mg_resnewy = l_oToday.mg_resnew
           l_oToday.mg_prdusey = l_oToday.mg_prduse
           l_oToday.mg_rmdusey = l_oToday.mg_rmduse
           l_oToday.mg_comprmy = l_oToday.mg_comprmd
           l_oToday.mg_comppry = l_oToday.mg_compprd
      ELSE
           l_oToday.mg_roomavy = l_oYesterday.mg_roomavy + l_oToday.mg_roomavl
           l_oToday.mg_bedavly = l_oYesterday.mg_bedavly + l_oToday.mg_bedavl
           l_oToday.mg_rmoooy  = l_oYesterday.mg_rmoooy  + l_oToday.mg_roomooo
           l_oToday.mg_rmoosy  = l_oYesterday.mg_rmoosy  + l_oToday.mg_roomoos
           l_oToday.mg_bdoooy  = l_oYesterday.mg_bdoooy  + l_oToday.mg_bedooo
           l_oToday.mg_bdoosy  = l_oYesterday.mg_bdoosy  + l_oToday.mg_bedoos
           l_oToday.mg_rmoccy  = l_oYesterday.mg_rmoccy  + l_oToday.mg_roomocc
           l_oToday.mg_bdoccy  = l_oYesterday.mg_bdoccy  + l_oToday.mg_bedocc
           l_oToday.mg_rmarry  = l_oYesterday.mg_rmarry  + l_oToday.mg_roomarr
           l_oToday.mg_perarry = l_oYesterday.mg_perarry + l_oToday.mg_persarr
           l_oToday.mg_roodepy = l_oYesterday.mg_roodepy + l_oToday.mg_roomdep
           l_oToday.mg_perdepy = l_oYesterday.mg_perdepy + l_oToday.mg_persdep
           l_oToday.mg_rescxly = l_oYesterday.mg_rescxly + l_oToday.mg_rescxl
           l_oToday.mg_optcxly = l_oYesterday.mg_optcxly + l_oToday.mg_optcxl
           l_oToday.mg_tencxly = l_oYesterday.mg_tencxly + l_oToday.mg_tencxl
           l_oToday.mg_cxllaty = l_oYesterday.mg_cxllaty + l_oToday.mg_cxllate
           l_oToday.mg_resnsy  = l_oYesterday.mg_resnsy  + l_oToday.mg_resns
           l_oToday.mg_resnewy = l_oYesterday.mg_resnewy + l_oToday.mg_resnew
           l_oToday.mg_prdusey = l_oYesterday.mg_prdusey + l_oToday.mg_prduse
           l_oToday.mg_rmdusey = l_oYesterday.mg_rmdusey + l_oToday.mg_rmduse
           l_oToday.mg_comprmy = l_oYesterday.mg_comprmy + l_oToday.mg_comprmd
           l_oToday.mg_comppry = l_oYesterday.mg_comppry + l_oToday.mg_compprd
      ENDIF
      GATHER NAME l_oToday MEMO
      l_oYesterday = l_oToday
 ENDSCAN
 RETURN .T.
ENDFUNC
*
PROCEDURE ManagerBuildRevUpdate
LPARAMETERS lp_dForDate, lp_nReserId
LOCAL l_oEnvironment, l_nRecno, l_oBefore, l_oAfter, l_cBuilding, l_lVatsDefined, l_cField, l_nArtiNum, l_nVatValue, l_oResroom, l_cRoomType
LOCAL ARRAY l_aVats(1)
l_oEnvironment = SetEnvironment("mngbuild, post, histpost, hresroom, histres, picklist, article, paymetho, roomtype", "tag2")

RiGetRoom(lp_nReserId, lp_dForDate, @l_oResroom, .NULL., "hresroom")
l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, ;
     DLookUp("histres", "hr_reserid = " + SqlCnv(lp_nReserId), "hr_roomtyp"))
l_cBuilding = DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(l_cRoomType), "rt_buildng")
IF EMPTY(l_cBuilding) OR NOT SEEK(DTOS(lp_dForDate)+l_cBuilding, "mngbuild", "Tag1")
     RETURN .F.
ENDIF
SELECT mngbuild
l_nRecno = RECNO()
SCATTER NAME l_oBefore
SCATTER FIELDS LIKE mg_dayp?, mg_dayg?, mg_dvat?, mg_pdoutd, mg_internd, mg_gcertd NAME l_oAfter BLANK
SELECT DISTINCT pl_numcod FROM picklist ;
     WHERE pl_label = "VATGROUP" AND pl_numcod > 0 ;
     ORDER BY pl_numcod INTO ARRAY l_aVats
IF _tally > 0
     l_lVatsDefined = .T.
ENDIF
SELECT post.*, article.ar_artityp, article.ar_main, paymetho.pm_paytyp FROM post ;
     LEFT JOIN article ON post.ps_artinum = article.ar_artinum ;
     LEFT JOIN paymetho ON post.ps_paynum = paymetho.pm_paynum ;
     WHERE ps_date = lp_dForDate AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split);
     INTO CURSOR curPost
SELECT curPost
SCAN
     RiGetRoom(ps_origid, lp_dForDate, @l_oResroom, .NULL., "hresroom")
     l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, ;
          DLookUp("histres", "hr_reserid = " + SqlCnv(ps_origid), "hr_roomtyp"))
     IF l_cBuilding <> DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(l_cRoomType), "rt_buildng")
          LOOP
     ENDIF
     IF ps_paynum <> 0
          IF NOT INLIST(ps_reserid, -2, -1, 0.200, 0.300)
               l_cField = "l_oAfter.mg_dayp" + STR(MAX(pm_paytyp, 1), 1)
               &l_cField = &l_cField - ps_amount
          ENDIF
     ELSE
          DO CASE
               CASE curPost.ar_artityp = 2
                    l_oAfter.mg_pdoutd = l_oAfter.mg_pdoutd + ps_amount
               CASE curPost.ar_artityp = 3
                    l_oAfter.mg_internd = l_oAfter.mg_internd + ps_amount
               CASE curPost.ar_artityp = 4
                    l_oAfter.mg_gcertd = l_oAfter.mg_gcertd + ps_amount
               OTHERWISE
                    l_nArtiNum = IIF(ISNULL(ar_main), 1, MAX(ar_main, 1))
                    l_cField = "l_oAfter.mg_dayg"+STR(l_nArtiNum,1)
                    &l_cField = &l_cField + ps_amount
                    IF l_lVatsDefined
                         l_nVatValue = 0
                         FOR i = 1 TO ALEN(l_aVats,1)
                              l_nVatValue = l_nVatValue + EVALUATE("ps_vat"+STR(l_aVats(i),1))
                         ENDFOR
                         l_cField = "l_oAfter.mg_dvat"+STR(l_nArtiNum,1)
                         &l_cField = &l_cField + l_nVatValue
                    ENDIF
          ENDCASE
     ENDIF
ENDSCAN
SELECT histpost.*, article.ar_artityp, article.ar_main, paymetho.pm_paytyp FROM histpost ;
     LEFT JOIN article ON histpost.hp_artinum = article.ar_artinum ;
     LEFT JOIN paymetho ON histpost.hp_paynum = paymetho.pm_paynum ;
     WHERE hp_date = lp_dForDate AND NOT SEEK(histpost.hp_postid,"post","Tag3") AND ;
     NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split);
     INTO CURSOR curPost
SELECT curPost
SCAN
     RiGetRoom(hp_origid, lp_dForDate, @l_oResroom, .NULL., "hresroom")
     l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, ;
          DLookUp("histres", "hr_reserid = " + SqlCnv(hp_origid), "hr_roomtyp"))
     IF l_cBuilding <> DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(l_cRoomType), "rt_buildng")
          LOOP
     ENDIF
     IF hp_paynum <> 0
          IF NOT INLIST(hp_reserid, -2, -1, 0.200, 0.300)
               l_cField = "l_oAfter.mg_dayp" + STR(MAX(pm_paytyp, 1), 1)
               &l_cField = &l_cField - hp_amount
          ENDIF
     ELSE
          DO CASE
               CASE curPost.ar_artityp = 2
                    l_oAfter.mg_pdoutd = l_oAfter.mg_pdoutd + hp_amount
               CASE curPost.ar_artityp = 3
                    l_oAfter.mg_internd = l_oAfter.mg_internd + hp_amount
               CASE curPost.ar_artityp = 4
                    l_oAfter.mg_gcertd = l_oAfter.mg_gcertd + hp_amount
               OTHERWISE
                    l_nArtiNum = IIF(ISNULL(ar_main), 1, MAX(ar_main, 1))
                    l_cField = "l_oAfter.mg_dayg"+STR(l_nArtiNum,1)
                    &l_cField = &l_cField + hp_amount
                    IF l_lVatsDefined
                         l_nVatValue = 0
                         FOR i = 1 TO ALEN(l_aVats,1)
                              l_nVatValue = l_nVatValue + EVALUATE("hp_vat"+STR(l_aVats(i),1))
                         ENDFOR
                         l_cField = "l_oAfter.mg_dvat"+STR(l_nArtiNum,1)
                         &l_cField = &l_cField + l_nVatValue
                    ENDIF
          ENDCASE
     ENDIF
ENDSCAN
USE IN curPost
SELECT mngbuild
GO l_nRecno
GATHER NAME l_oAfter
REPLACE mg_monp1 WITH mg_monp1 - l_oBefore.mg_dayp1 + l_oAfter.mg_dayp1, ;
        mg_monp2 WITH mg_monp2 - l_oBefore.mg_dayp2 + l_oAfter.mg_dayp2, ;
        mg_monp3 WITH mg_monp3 - l_oBefore.mg_dayp3 + l_oAfter.mg_dayp3, ;
        mg_monp4 WITH mg_monp4 - l_oBefore.mg_dayp4 + l_oAfter.mg_dayp4, ;
        mg_monp5 WITH mg_monp5 - l_oBefore.mg_dayp5 + l_oAfter.mg_dayp5, ;
        mg_monp6 WITH mg_monp6 - l_oBefore.mg_dayp6 + l_oAfter.mg_dayp6, ;
        mg_monp7 WITH mg_monp7 - l_oBefore.mg_dayp7 + l_oAfter.mg_dayp7, ;
        mg_monp8 WITH mg_monp8 - l_oBefore.mg_dayp8 + l_oAfter.mg_dayp8, ;
        mg_monp9 WITH mg_monp9 - l_oBefore.mg_dayp9 + l_oAfter.mg_dayp9, ;
        mg_mong1 WITH mg_mong1 - l_oBefore.mg_dayg1 + l_oAfter.mg_dayg1, ;
        mg_mong2 WITH mg_mong2 - l_oBefore.mg_dayg2 + l_oAfter.mg_dayg2, ;
        mg_mong3 WITH mg_mong3 - l_oBefore.mg_dayg3 + l_oAfter.mg_dayg3, ;
        mg_mong4 WITH mg_mong4 - l_oBefore.mg_dayg4 + l_oAfter.mg_dayg4, ;
        mg_mong5 WITH mg_mong5 - l_oBefore.mg_dayg5 + l_oAfter.mg_dayg5, ;
        mg_mong6 WITH mg_mong6 - l_oBefore.mg_dayg6 + l_oAfter.mg_dayg6, ;
        mg_mong7 WITH mg_mong7 - l_oBefore.mg_dayg7 + l_oAfter.mg_dayg7, ;
        mg_mong8 WITH mg_mong8 - l_oBefore.mg_dayg8 + l_oAfter.mg_dayg8, ;
        mg_mong9 WITH mg_mong9 - l_oBefore.mg_dayg9 + l_oAfter.mg_dayg9, ;
        mg_mvat1 WITH mg_mvat1 - l_oBefore.mg_dvat1 + l_oAfter.mg_dvat1, ;
        mg_mvat2 WITH mg_mvat2 - l_oBefore.mg_dvat2 + l_oAfter.mg_dvat2, ;
        mg_mvat3 WITH mg_mvat3 - l_oBefore.mg_dvat3 + l_oAfter.mg_dvat3, ;
        mg_mvat4 WITH mg_mvat4 - l_oBefore.mg_dvat4 + l_oAfter.mg_dvat4, ;
        mg_mvat5 WITH mg_mvat5 - l_oBefore.mg_dvat5 + l_oAfter.mg_dvat5, ;
        mg_mvat6 WITH mg_mvat6 - l_oBefore.mg_dvat6 + l_oAfter.mg_dvat6, ;
        mg_mvat7 WITH mg_mvat7 - l_oBefore.mg_dvat7 + l_oAfter.mg_dvat7, ;
        mg_mvat8 WITH mg_mvat8 - l_oBefore.mg_dvat8 + l_oAfter.mg_dvat8, ;
        mg_mvat9 WITH mg_mvat9 - l_oBefore.mg_dvat9 + l_oAfter.mg_dvat9, ;
        mg_pdoutm WITH mg_pdoutm - l_oBefore.mg_pdoutd + l_oAfter.mg_pdoutd, ;
        mg_internm WITH mg_internm - l_oBefore.mg_internd + l_oAfter.mg_internd, ;
        mg_gcertm WITH mg_gcertm - l_oBefore.mg_gcertd + l_oAfter.mg_gcertd ;
     FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(SysDate() - 1)) AND (mg_buildng = l_cBuilding) ;
     WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) AND MONTH(mg_date) = MONTH(l_oBefore.mg_date) IN mngbuild
GO l_nRecno
REPLACE mg_yeap1 WITH mg_yeap1 - l_oBefore.mg_dayp1 + l_oAfter.mg_dayp1, ;
        mg_yeap2 WITH mg_yeap2 - l_oBefore.mg_dayp2 + l_oAfter.mg_dayp2, ;
        mg_yeap3 WITH mg_yeap3 - l_oBefore.mg_dayp3 + l_oAfter.mg_dayp3, ;
        mg_yeap4 WITH mg_yeap4 - l_oBefore.mg_dayp4 + l_oAfter.mg_dayp4, ;
        mg_yeap5 WITH mg_yeap5 - l_oBefore.mg_dayp5 + l_oAfter.mg_dayp5, ;
        mg_yeap6 WITH mg_yeap6 - l_oBefore.mg_dayp6 + l_oAfter.mg_dayp6, ;
        mg_yeap7 WITH mg_yeap7 - l_oBefore.mg_dayp7 + l_oAfter.mg_dayp7, ;
        mg_yeap8 WITH mg_yeap8 - l_oBefore.mg_dayp8 + l_oAfter.mg_dayp8, ;
        mg_yeap9 WITH mg_yeap9 - l_oBefore.mg_dayp9 + l_oAfter.mg_dayp9, ;
        mg_yeag1 WITH mg_yeag1 - l_oBefore.mg_dayg1 + l_oAfter.mg_dayg1, ;
        mg_yeag2 WITH mg_yeag2 - l_oBefore.mg_dayg2 + l_oAfter.mg_dayg2, ;
        mg_yeag3 WITH mg_yeag3 - l_oBefore.mg_dayg3 + l_oAfter.mg_dayg3, ;
        mg_yeag4 WITH mg_yeag4 - l_oBefore.mg_dayg4 + l_oAfter.mg_dayg4, ;
        mg_yeag5 WITH mg_yeag5 - l_oBefore.mg_dayg5 + l_oAfter.mg_dayg5, ;
        mg_yeag6 WITH mg_yeag6 - l_oBefore.mg_dayg6 + l_oAfter.mg_dayg6, ;
        mg_yeag7 WITH mg_yeag7 - l_oBefore.mg_dayg7 + l_oAfter.mg_dayg7, ;
        mg_yeag8 WITH mg_yeag8 - l_oBefore.mg_dayg8 + l_oAfter.mg_dayg8, ;
        mg_yeag9 WITH mg_yeag9 - l_oBefore.mg_dayg9 + l_oAfter.mg_dayg9, ;
        mg_yvat1 WITH mg_yvat1 - l_oBefore.mg_dvat1 + l_oAfter.mg_dvat1, ;
        mg_yvat2 WITH mg_yvat2 - l_oBefore.mg_dvat2 + l_oAfter.mg_dvat2, ;
        mg_yvat3 WITH mg_yvat3 - l_oBefore.mg_dvat3 + l_oAfter.mg_dvat3, ;
        mg_yvat4 WITH mg_yvat4 - l_oBefore.mg_dvat4 + l_oAfter.mg_dvat4, ;
        mg_yvat5 WITH mg_yvat5 - l_oBefore.mg_dvat5 + l_oAfter.mg_dvat5, ;
        mg_yvat6 WITH mg_yvat6 - l_oBefore.mg_dvat6 + l_oAfter.mg_dvat6, ;
        mg_yvat7 WITH mg_yvat7 - l_oBefore.mg_dvat7 + l_oAfter.mg_dvat7, ;
        mg_yvat8 WITH mg_yvat8 - l_oBefore.mg_dvat8 + l_oAfter.mg_dvat8, ;
        mg_yvat9 WITH mg_yvat9 - l_oBefore.mg_dvat9 + l_oAfter.mg_dvat9, ;
        mg_pdouty WITH mg_pdouty - l_oBefore.mg_pdoutd + l_oAfter.mg_pdoutd, ;
        mg_interny WITH mg_interny - l_oBefore.mg_internd + l_oAfter.mg_internd, ;
        mg_gcerty WITH mg_gcerty - l_oBefore.mg_gcertd + l_oAfter.mg_gcertd ;
     FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(SysDate() - 1)) AND (mg_buildng = l_cBuilding) ;
     WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) IN mngbuild
l_nTotalDiffDayp = 0
l_nTotalDiffDayg = 0
l_nTotalDiffDvat = 0
FOR l_nGroupNo = 1 TO 9
     l_nTotalDiffDayp = l_nTotalDiffDayp - EVALUATE("l_oBefore.mg_dayp" + STR(l_nGroupNo,1)) + EVALUATE("l_oAfter.mg_dayp" + STR(l_nGroupNo,1))
     l_nTotalDiffDayg = l_nTotalDiffDayg - EVALUATE("l_oBefore.mg_dayg" + STR(l_nGroupNo,1)) + EVALUATE("l_oAfter.mg_dayg" + STR(l_nGroupNo,1))
     l_nTotalDiffDvat = l_nTotalDiffDvat - EVALUATE("l_oBefore.mg_dvat" + STR(l_nGroupNo,1)) + EVALUATE("l_oAfter.mg_dvat" + STR(l_nGroupNo,1))
NEXT
l_nTotalDiff = l_nTotalDiffDayg + IIF(param.pa_exclvat, l_nTotalDiffDvat, 0) - l_nTotalDiffDayp
GO l_nRecno
REPLACE mg_gcldg WITH mg_gcldg - (l_oBefore.mg_gcertd - l_oBefore.mg_dayp7) + (l_oAfter.mg_gcertd - l_oAfter.mg_dayp7), ;
        mg_gstldg WITH mg_gstldg - (l_oBefore.mg_pdoutd + l_oBefore.mg_internd + l_oBefore.mg_gcertd) + ;
        (l_oAfter.mg_pdoutd + l_oAfter.mg_internd + l_oAfter.mg_gcertd) + l_nTotalDiff ;
     REST FOR DTOS(mg_date) < DTOS(param.pa_sysdate) AND mg_buildng = l_cBuilding IN mngbuild
ENDPROC
*
FUNCTION ReCalculateFinancial
 LPARAMETERS lp_dSysDate
 LOCAL i, l_lVatsDefined, l_nVatValue, l_oEnvironment, l_nPayNum, l_nArtiNum, l_oResroom
 LOCAL ARRAY l_aVats(1)
 l_oEnvironment = SetEnvironment("mngbuild, histpost, hresroom, histres, picklist, article, paymetho, roomtype", "tag2")
 l_nPayNum = 0
 l_nArtiNum = 0
 l_lVatsDefined = .F.
 SELECT DISTINCT pl_numcod FROM picklist ;
      WHERE pl_label = "VATGROUP" AND pl_numcod > 0 ;
      ORDER BY pl_numcod ;
      INTO ARRAY l_aVats
 IF _tally > 0
      l_lVatsDefined = .T.
 ENDIF
 MNBFinancialDataGet(lp_dSysDate, "histres")
 SELECT curPosts
 SCAN
      IF hp_reserid < 1 AND NOT EMPTY(IIF(hp_paynum = 0, NVL(ar_buildng,''), NVL(pm_buildng, '')))
           DLocate("roomtype", "rt_buildng = " + sqlcnv(IIF(hp_paynum = 0, ar_buildng, pm_buildng)))
      ELSE
           RiGetRoom(hp_origid, hp_date, @l_oResroom, .NULL., "hresroom")
           l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, ;
                DLookUp("histres", "hr_reserid = " + SqlCnv(hp_origid), "hr_roomtyp"))
           = SEEK(l_cRoomType, "roomtype", "tag1")
      ENDIF
      IF EMPTY(roomtype.rt_buildng) AND NOT EMPTY(_screen.oGlobal.cStandardBuilding)
           DLocate("roomtype", "rt_buildng = " + sqlcnv(_screen.oGlobal.cStandardBuilding))
      ENDIF
      IF hp_paynum<>0
           IF NOT INLIST(hp_reserid, -2, -1, 0.200, 0.300)
                l_nPayNum = IIF(ISNULL(pm_paytyp), 1, MAX(pm_paytyp, 1))
                AddToMngBuild("mg_dayp"+STR(l_nPayNum, 1),-hp_amount)
           ENDIF
      ELSE
           DO CASE
                CASE ar_artityp=2
                     AddToMngBuild("mg_pdoutd",hp_amount)
                CASE ar_artityp=3
                     AddToMngBuild("mg_internd",hp_amount)
                CASE ar_artityp=4
                     AddToMngBuild("mg_gcertd",hp_amount)
                OTHERWISE
                     l_nArtiNum = IIF(ISNULL(ar_main), 1, MAX(ar_main, 1))
                     AddToMngBuild("mg_dayg"+STR(l_nArtiNum, 1),hp_amount)
                     IF l_lVatsDefined
                          l_nVatValue = 0
                          FOR i = 1 TO ALEN(l_aVats,1)
                               l_nVatValue = l_nVatValue + EVALUATE("hp_Vat"+STR(l_aVats(i),1))
                          ENDFOR
                          AddToMngBuild("mg_dvat"+STR(l_nArtiNum,1), l_nVatValue)
                     ENDIF
           ENDCASE
      ENDIF
 ENDSCAN
 USE IN curPosts
 RETURN .T.
ENDFUNC
*
PROCEDURE ReCalculateDeposit
LPARAMETERS lp_dForDate
 LOCAL i, l_oEnvironment, l_oResroom
 IF NOT _screen.dp
      RETURN
 ENDIF
 l_oEnvironment = SetEnvironment("deposit, histres, hresroom, roomtype")
 FOR i = 1 TO ALEN(p_aBuildings,1)
      IF p_aBuildings(i,5)
           p_aBuildings(i,3).mg_dldg = p_aBuildings(i,4).mg_dldg
      ELSE
           p_aBuildings(i,3).mg_dldg = 0
      ENDIF
 NEXT
 SELECT deposit
 SCAN FOR dp_sysdate = lp_dForDate OR dp_posted = lp_dForDate
      RiGetRoom(dp_reserid, lp_dForDate, @l_oResroom, .NULL., "hresroom")
      l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, ;
           DLookUp("histres", "hr_reserid = " + SqlCnv(dp_reserid), "hr_roomtyp"))
      = SEEK(l_cRoomType, "roomtype", "tag1")
      IF dp_sysdate = lp_dForDate
           AddToMngBuild("mg_dldgcrd", dp_credit)
           AddToMngBuild("mg_dldg", dp_credit)
      ENDIF
      IF dp_posted = lp_dForDate
           AddToMngBuild("mg_dldgdeb", dp_credit)
           AddToMngBuild("mg_dldg", -dp_credit)
      ENDIF
 ENDSCAN
ENDPROC
*
PROCEDURE ReCalculateAr
LPARAMETERS lp_dForDate
 LOCAL i, l_nSelect, l_lUsedArpost, l_cOrderArpost, l_oResroom
 IF NOT _screen.dv
      RETURN
 ENDIF
 l_oEnvironment = SetEnvironment("arpost, histres, hresroom, roomtype")
 FOR i = 1 TO ALEN(p_aBuildings,1)
      IF p_aBuildings(i,5)
           p_aBuildings(i,3).mg_cldg = p_aBuildings(i,4).mg_cldg
      ELSE
           p_aBuildings(i,3).mg_cldg = 0
      ENDIF
 NEXT
 SELECT arpost
 SCAN FOR ap_sysdate = lp_dForDate AND NOT ap_hiden
      RiGetRoom(ap_reserid, lp_dForDate, @l_oResroom, .NULL., "hresroom")
      l_cRoomType = IIF(NOT ISNULL(l_oResroom), l_oResroom.ri_roomtyp, ;
           DLookUp("histres", "hr_reserid = " + SqlCnv(ap_reserid), "hr_roomtyp"))
      = SEEK(l_cRoomType, "roomtype", "tag1")
      AddToMngBuild("mg_cldgdeb", ap_debit)
      AddToMngBuild("mg_cldgcrd", ap_credit)
      AddToMngBuild("mg_cldg", ap_debit - ap_credit)
 ENDSCAN
ENDPROC
*
PROCEDURE RemoveReservation
LPARAMETERS lp_nReserId
 LOCAL l_oEnvironment, l_oBefore, l_oAfter, l_dCreated, l_dCanceled
 PRIVATE p_dStartDate, p_lAdd
 PRIVATE p_aBuildings
 DIMENSION p_aBuildings(1)
 l_oEnvironment = SetEnvironment("mngbuild, histres, hresroom, hresrate, roomtype, picklist", "tag1")
 IF GetHotelBuildings() AND DLocate("histres", "hr_reserid = " + SqlCnv(lp_nReserId)) AND histres.hr_reserid > 1
      =SEEK(histres.hr_rsid,"hresext","tag3")
      p_lAdd = .F.     && Remove values in RecalcField()
      l_nAlias = SELECT()
      l_dCreated = IIF(EMPTY(histres.hr_created), histres.hr_arrdate, histres.hr_created)
      l_dCanceled = IIF(EMPTY(histres.hr_cxldate), histres.hr_arrdate, histres.hr_cxldate)
      p_dStartDate = MIN(histres.hr_arrdate-1, l_dCreated, l_dCanceled)
      SELECT * FROM mngbuild WHERE INLIST(DTOS(mg_date),DTOS(l_dCreated),DTOS(l_dCanceled)) OR ;
           BETWEEN(DTOS(mg_date),DTOS(histres.hr_arrdate),DTOS(histres.hr_depdate)) ;
           ORDER BY mg_mngbid INTO CURSOR curMngbuild     && Backup previous state
      SELECT histres
      RecalcManagerOneHistReservationOccupancy()
      * Update cumulative values
      SELECT curMngbuild
      SCAN
           SCATTER NAME l_oBefore
           = SEEK(DTOS(l_oBefore.mg_date),"mngbuild","tag2")
           SELECT mngbuild
           SCATTER NAME l_oAfter
           REPLACE mg_rmoccm  WITH mg_rmoccm  - l_oBefore.mg_roomocc + l_oAfter.mg_roomocc, ;
                   mg_bdoccm  WITH mg_bdoccm  - l_oBefore.mg_bedocc  + l_oAfter.mg_bedocc, ;
                   mg_rmarrm  WITH mg_rmarrm  - l_oBefore.mg_roomarr + l_oAfter.mg_roomarr, ;
                   mg_perarrm WITH mg_perarrm - l_oBefore.mg_persarr + l_oAfter.mg_persarr, ;
                   mg_roodepm WITH mg_roodepm - l_oBefore.mg_roomdep + l_oAfter.mg_roomdep, ;
                   mg_perdepm WITH mg_perdepm - l_oBefore.mg_persdep + l_oAfter.mg_persdep, ;
                   mg_rescxlm WITH mg_rescxlm - l_oBefore.mg_rescxl  + l_oAfter.mg_rescxl, ;
                   mg_optcxlm WITH mg_optcxlm - l_oBefore.mg_optcxl  + l_oAfter.mg_optcxl, ;
                   mg_tencxlm WITH mg_tencxlm - l_oBefore.mg_tencxl  + l_oAfter.mg_tencxl, ;
                   mg_resnsm  WITH mg_resnsm  - l_oBefore.mg_resns   + l_oAfter.mg_resns, ;
                   mg_resnewm WITH mg_resnewm - l_oBefore.mg_resnew  + l_oAfter.mg_resnew, ;
                   mg_prdusem WITH mg_prdusem - l_oBefore.mg_prduse  + l_oAfter.mg_prduse, ;
                   mg_rmdusem WITH mg_rmdusem - l_oBefore.mg_rmduse  + l_oAfter.mg_rmduse, ;
                   mg_comprmm WITH mg_comprmm - l_oBefore.mg_comprmd + l_oAfter.mg_comprmd, ;
                   mg_compprm WITH mg_compprm - l_oBefore.mg_compprd + l_oAfter.mg_compprd ;
                FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(SysDate() - 1)) AND (mg_buildng = l_oBefore.mg_buildng) ;
                WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) AND MONTH(mg_date) = MONTH(l_oBefore.mg_date) IN mngbuild
           = SEEK(DTOS(l_oBefore.mg_date),"mngbuild","tag2")
           REPLACE mg_rmoccy  WITH mg_rmoccy  - l_oBefore.mg_roomocc + l_oAfter.mg_roomocc, ;
                   mg_bdoccy  WITH mg_bdoccy  - l_oBefore.mg_bedocc  + l_oAfter.mg_bedocc, ;
                   mg_rmarry  WITH mg_rmarry  - l_oBefore.mg_roomarr + l_oAfter.mg_roomarr, ;
                   mg_perarry WITH mg_perarry - l_oBefore.mg_persarr + l_oAfter.mg_persarr, ;
                   mg_roodepy WITH mg_roodepy - l_oBefore.mg_roomdep + l_oAfter.mg_roomdep, ;
                   mg_perdepy WITH mg_perdepy - l_oBefore.mg_persdep + l_oAfter.mg_persdep, ;
                   mg_rescxly WITH mg_rescxly - l_oBefore.mg_rescxl  + l_oAfter.mg_rescxl, ;
                   mg_optcxly WITH mg_optcxly - l_oBefore.mg_optcxl  + l_oAfter.mg_optcxl, ;
                   mg_tencxly WITH mg_tencxly - l_oBefore.mg_tencxl  + l_oAfter.mg_tencxl, ;
                   mg_resnsy  WITH mg_resnsy  - l_oBefore.mg_resns   + l_oAfter.mg_resns, ;
                   mg_resnewy WITH mg_resnewy - l_oBefore.mg_resnew  + l_oAfter.mg_resnew, ;
                   mg_prdusey WITH mg_prdusey - l_oBefore.mg_prduse  + l_oAfter.mg_prduse, ;
                   mg_rmdusey WITH mg_rmdusey - l_oBefore.mg_rmduse  + l_oAfter.mg_rmduse, ;
                   mg_comprmy WITH mg_comprmy - l_oBefore.mg_comprmd + l_oAfter.mg_comprmd, ;
                   mg_comppry WITH mg_comppry - l_oBefore.mg_compprd + l_oAfter.mg_compprd ;
                FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(SysDate() - 1)) AND (mg_buildng = l_oBefore.mg_buildng) ;
                WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) IN mngbuild
           SELECT curMngbuild
      ENDSCAN
      USE IN curMngbuild
 ENDIF
ENDPROC
*
PROCEDURE  MNBFinancialDataGet
 LPARAMETERS lp_dDate, lp_cResAlias
 LOCAL l_lOnlyForClosedBills
 l_lOnlyForClosedBills = .F.&&ALLTRIM(_screen.oGlobal.oParam.pa_country) == "RS"
 IF l_lOnlyForClosedBills
      LOCAL i, l_cReserIdField, l_cRsIdField
      LOCAL ARRAY l_acurmg(1)
      IF LOWER(lp_cResAlias)="reservat"
           l_cReserIdField = "rs_reserid"
           l_cRsIdField = "rs_rsid"
      ELSE
           l_cReserIdField = "hr_reserid"
           l_cRsIdField = "hr_rsid"
      ENDIF
      SELECT * FROM histpost ;
                INNER JOIN article ON hp_artinum = ar_artinum ;
                INNER JOIN paymetho ON hp_paynum = pm_paynum ;
                WHERE 0=1 INTO CURSOR curmg0
      AFIELDS(l_acurmg)
      FOR i = 1 TO ALEN(l_acurmg,1)
           l_acurmg(i,5) = .T. && Allow nulls
      ENDFOR
      CREATE CURSOR curposts FROM ARRAY l_acurmg
      SELECT * FROM histpost ;
                LEFT JOIN article ON hp_artinum = ar_artinum ;
                LEFT JOIN paymetho ON hp_paynum = pm_paynum ;
                WHERE hp_date = lp_dDate AND NOT hp_cancel AND ;
                ((EMPTY(hp_ratecod) OR (NOT EMPTY(hp_ratecod) AND hp_split)) AND ;
                NOT (hp_window>0 AND hp_reserid > 1) AND ;
                NOT (hp_reserid = 0.100 AND NOT EMPTY(hp_billnum)) ;
                OR hp_artinum = 250) ;
                INTO CURSOR curmg1

      SELECT * FROM billnum ;
                INNER JOIN histpost ON bn_billnum = hp_billnum ;
                LEFT JOIN article ON hp_artinum = ar_artinum ;
                LEFT JOIN paymetho ON hp_paynum = pm_paynum ;
                WHERE bn_date = lp_dDate AND bn_status = "PCO" AND ;
                NOT hp_cancel AND ;
                (EMPTY(hp_ratecod) OR (NOT EMPTY(hp_ratecod) AND hp_split)) ;
                AND hp_artinum <> 250 ;
                INTO CURSOR curmg2

      SELECT ps_addrid AS hp_addrid, ;
                -ps_amount AS hp_amount, ;
                ps_artinum AS hp_artinum, ;
                ps_billnum AS hp_billnum, ;
                ps_cashier AS hp_cashier, ;
                ps_date AS hp_date, ;
                ps_descrip AS hp_descrip, ;
                ps_fibdat AS hp_fibdat, ;
                ps_finacct AS hp_finacct, ;
                ps_ifc AS hp_ifc, ;
                ps_note AS hp_note, ;
                ps_paynum AS hp_paynum, ;
                ps_postid AS hp_postid, ;
                ps_price AS hp_price, ;
                ps_ratecod AS hp_ratecod, ;
                ps_rsid AS hp_rsid, ;
                ps_setid AS hp_setid, ;
                ps_split AS hp_split, ;
                ps_supplem AS hp_supplem, ;
                ps_time AS hp_time, ;
                -ps_units AS hp_units, ;
                ps_userid AS hp_userid, ;
                -ps_vat0 AS hp_vat0, ;
                -ps_vat1 AS hp_vat1, ;
                -ps_vat2 AS hp_vat2, ;
                -ps_vat3 AS hp_vat3, ;
                -ps_vat4 AS hp_vat4, ;
                -ps_vat5 AS hp_vat5, ;
                -ps_vat6 AS hp_vat6, ;
                -ps_vat7 AS hp_vat7, ;
                -ps_vat8 AS hp_vat8, ;
                -ps_vat9 AS hp_vat9, ;
                ps_vouccpy AS hp_vouccpy, ;
                ps_voucnum AS hp_voucnum, ;
                ps_window AS hp_window, ;
                &l_cReserIdField AS hp_reserid, ;
                article.*, paymetho.* ;
                FROM billnum ;
                INNER JOIN postcxl ON bn_billnum = ps_billnum ;
                LEFT JOIN &lp_cResAlias ON ps_rsid = &l_cRsIdField ;
                LEFT JOIN article ON ps_artinum = ar_artinum ;
                LEFT JOIN paymetho ON ps_paynum = pm_paynum ;
                WHERE bn_cxldate = lp_dDate AND bn_date <> bn_cxldate AND bn_status = "CXL" AND ;
                (EMPTY(ps_ratecod) OR (NOT EMPTY(ps_ratecod) AND ps_split)) ;
                AND ps_artinum <> 250 ;
                INTO CURSOR curmg3

      SELECT ps_addrid AS hp_addrid, ;
                ps_amount AS hp_amount, ;
                ps_artinum AS hp_artinum, ;
                ps_billnum AS hp_billnum, ;
                ps_cashier AS hp_cashier, ;
                ps_date AS hp_date, ;
                ps_descrip AS hp_descrip, ;
                ps_fibdat AS hp_fibdat, ;
                ps_finacct AS hp_finacct, ;
                ps_ifc AS hp_ifc, ;
                ps_note AS hp_note, ;
                ps_paynum AS hp_paynum, ;
                ps_postid AS hp_postid, ;
                ps_price AS hp_price, ;
                ps_ratecod AS hp_ratecod, ;
                ps_rsid AS hp_rsid, ;
                ps_setid AS hp_setid, ;
                ps_split AS hp_split, ;
                ps_supplem AS hp_supplem, ;
                ps_time AS hp_time, ;
                ps_units AS hp_units, ;
                ps_userid AS hp_userid, ;
                ps_vat0 AS hp_vat0, ;
                ps_vat1 AS hp_vat1, ;
                ps_vat2 AS hp_vat2, ;
                ps_vat3 AS hp_vat3, ;
                ps_vat4 AS hp_vat4, ;
                ps_vat5 AS hp_vat5, ;
                ps_vat6 AS hp_vat6, ;
                ps_vat7 AS hp_vat7, ;
                ps_vat8 AS hp_vat8, ;
                ps_vat9 AS hp_vat9, ;
                ps_vouccpy AS hp_vouccpy, ;
                ps_voucnum AS hp_voucnum, ;
                ps_window AS hp_window, ;
                &l_cReserIdField AS hp_reserid, ;
                article.*, paymetho.* ;
                FROM billnum ;
                INNER JOIN postcxl ON bn_billnum = ps_billnum ;
                LEFT JOIN &lp_cResAlias ON ps_rsid = &l_cRsIdField ;
                LEFT JOIN article ON ps_artinum = ar_artinum ;
                LEFT JOIN paymetho ON ps_paynum = pm_paynum ;
                WHERE bn_date = lp_dDate AND bn_cxldate <> {} AND bn_date <> bn_cxldate AND bn_status = "CXL" AND ;
                (EMPTY(ps_ratecod) OR (NOT EMPTY(ps_ratecod) AND ps_split)) ;
                AND ps_artinum <> 250 ;
                INTO CURSOR curmg4
      SELECT curPosts
      APPEND FROM DBF("curmg1")
      APPEND FROM DBF("curmg2")
      APPEND FROM DBF("curmg3")
      APPEND FROM DBF("curmg4")
      dclose("curmg0")
      dclose("curmg1")
      dclose("curmg2")
      dclose("curmg3")
      dclose("curmg4")
 ELSE
      SELECT * FROM histpost ;
                LEFT JOIN article ON hp_artinum = ar_artinum ;
                LEFT JOIN paymetho ON hp_paynum = pm_paynum ;
                WHERE hp_date = lp_dDate AND NOT hp_cancel AND ;
                (EMPTY(hp_ratecod) OR (NOT EMPTY(hp_ratecod) AND hp_split)) ;
                INTO CURSOR curPosts
 ENDIF
 
 RETURN .T.
ENDPROC
*
**
***********
** TESTS **
***********
*
PROCEDURE MNTestForecast
PRIVATE p_oAudit, p_aBuildings, p_lRemoveRoomTypeAlias
LOCAL l_cCur, l_cCurMan, i
p_lRemoveRoomTypeAlias = .F.
p_oAudit = NEWOBJECT("cMNDummyAudit", "manager.prg")

l_cCurMan = "curmngbuild"
l_cCur = sqlcursor("SELECT * FROM mngbuild WHERE 0=1")
SELECT * FROM (l_cCur) INTO CURSOR (l_cCurMan) READWRITE
dclose(l_cCur)

DIMENSION p_aBuildings(1)
GetHotelBuildings()
SELECT (l_cCurMan)
FOR i = 1 TO ALEN(p_aBuildings,1)
     SCATTER NAME p_aBuildings(i,3) BLANK
ENDFOR

Forecast()

FOR i = 1 TO ALEN(p_aBuildings,1)
     SELECT (l_cCurMan)
     APPEND BLANK
     GATHER NAME p_aBuildings(i,3)
ENDFOR

DIMENSION p_aBuildings(1)
GetHotelBuildings()
SELECT (l_cCurMan)
FOR i = 1 TO ALEN(p_aBuildings,1)
     SCATTER NAME p_aBuildings(i,3) BLANK
ENDFOR

MNForecastOld()

FOR i = 1 TO ALEN(p_aBuildings,1)
     SELECT (l_cCurMan)
     APPEND BLANK
     GATHER NAME p_aBuildings(i,3)
ENDFOR
ENDPROC
*
FUNCTION MNForecastOld
 PRIVATE nsElect
 LOCAL l_cText, l_cTextTomorrow, l_cTextNextweek, l_cTextNext30days, l_cTextNext365days
 l_cTextTomorrow = GetLangText("MANAGER","TXT_TOMORROW")
 l_cTextNextweek = GetLangText("MANAGER","TXT_NEXTWEEK")
 l_cTextNext30days = GetLangText("MANAGER","TXT_NEXT30DAYS")
 l_cTextNext365days = GetLangText("MANAGER","TXT_NEXT365DAYS")
 l_cText = ""
 nsElect = SELECT()
 p_oAudit.txTinfo(GetLangText("MANAGER","TXT_FORECAST"),1)
 SELECT avAilab
 SET RELATION TO av_roomtyp INTO roOmtype
 SCAN FOR DTOS(av_date) >= DTOS(g_sysdate+1) AND ;
           roomtype.rt_group = 1 AND roomtype.rt_vwsum
      DO CASE
           CASE av_date==(g_sysdate+1) AND l_cText <> l_cTextTomorrow
                p_oAudit.txTinfo(GetLangText("MANAGER","TXT_TOMORROW"),1)
                l_cText = l_cTextTomorrow
           CASE BETWEEN(av_date,g_sysdate+2,g_sysdate+7) AND l_cText <> l_cTextNextweek
                p_oAudit.txTinfo(GetLangText("MANAGER","TXT_NEXTWEEK"),1)
                l_cText = l_cTextNextweek
           CASE BETWEEN(av_date,g_sysdate+8,g_sysdate+30) AND l_cText <> l_cTextNext30days
                p_oAudit.txTinfo(GetLangText("MANAGER","TXT_ENDOFMONTH"),1)
                p_oAudit.txTinfo(GetLangText("MANAGER","TXT_NEXT30DAYS"),1)
                l_cText = l_cTextNext30days
           CASE BETWEEN(av_date,g_sysdate+31,g_sysdate+365) AND l_cText <> l_cTextNext365days
                p_oAudit.txTinfo(GetLangText("MANAGER","TXT_NEXT365DAYS"),1)
                p_oAudit.txTinfo(GetLangText("MANAGER","TXT_ENDOFTHEYEAR"),1)
                l_cText = l_cTextNext365days
      ENDCASE
      IF av_date==(g_sysdate+1)
           = AddToMngBuild("mg_maxtomo",avAilab.av_avail-avAilab.av_ooservc)
           = AddToMngBuild("mg_deftomo",avAilab.av_definit)
           = AddToMngBuild("mg_opttomo",avAilab.av_option)
           = AddToMngBuild("mg_tentomo",avAilab.av_tentat)
           = AddToMngBuild("mg_alltomo",avAilab.av_allott+avAilab.av_altall)
           = AddToMngBuild("mg_pictomo",avAilab.av_pick)
           = AddToMngBuild("mg_waitomo",avAilab.av_waiting)
      ENDIF
      IF av_date<=(g_sysdate+7)
           = AddToMngBuild("mg_maxnext",avAilab.av_avail-avAilab.av_ooservc)
           = AddToMngBuild("mg_defnext",avAilab.av_definit)
           = AddToMngBuild("mg_optnext",avAilab.av_option)
           = AddToMngBuild("mg_tennext",avAilab.av_tentat)
           = AddToMngBuild("mg_allnext",avAilab.av_allott+avAilab.av_altall)
           = AddToMngBuild("mg_picnext",avAilab.av_pick)
           = AddToMngBuild("mg_wainext",avAilab.av_waiting)
      ENDIF
      IF MONTH(av_date)= MONTH(g_sysdate) AND YEAR(av_date)=YEAR(g_sysdate)
           = AddToMngBuild("mg_maxendm",avAilab.av_avail-avAilab.av_ooservc)
           = AddToMngBuild("mg_defendm",avAilab.av_definit)
           = AddToMngBuild("mg_optendm",avAilab.av_option)
           = AddToMngBuild("mg_tenendm",avAilab.av_tentat)
           = AddToMngBuild("mg_allendm",avAilab.av_allott+avAilab.av_altall)
           = AddToMngBuild("mg_picendm",avAilab.av_pick)
           = AddToMngBuild("mg_waiendm",avAilab.av_waiting)
      ENDIF
      IF av_date<=(g_sysdate+30)
           = AddToMngBuild("mg_max30da",avAilab.av_avail-avAilab.av_ooservc)
           = AddToMngBuild("mg_def30da",avAilab.av_definit)
           = AddToMngBuild("mg_opt30da",avAilab.av_option)
           = AddToMngBuild("mg_ten30da",avAilab.av_tentat)
           = AddToMngBuild("mg_all30da",avAilab.av_allott+avAilab.av_altall)
           = AddToMngBuild("mg_pic30da",avAilab.av_pick)
           = AddToMngBuild("mg_wai30da",avAilab.av_waiting)
      ENDIF
      IF av_date<=(g_sysdate+365)
           = AddToMngBuild("mg_max365d",avAilab.av_avail-avAilab.av_ooservc)
           = AddToMngBuild("mg_def365d",avAilab.av_definit)
           = AddToMngBuild("mg_opt365d",avAilab.av_option)
           = AddToMngBuild("mg_ten365d",avAilab.av_tentat)
           = AddToMngBuild("mg_all365d",avAilab.av_allott+avAilab.av_altall)
           = AddToMngBuild("mg_pic365d",avAilab.av_pick)
           = AddToMngBuild("mg_wai365d",avAilab.av_waiting)
      ENDIF
      IF MONTH(av_date)<=12 .AND. YEAR(av_date)==YEAR(g_sysdate)
           = AddToMngBuild("mg_maxendy",avAilab.av_avail-avAilab.av_ooservc)
           = AddToMngBuild("mg_defendy",avAilab.av_definit)
           = AddToMngBuild("mg_optendy",avAilab.av_option)
           = AddToMngBuild("mg_tenendy",avAilab.av_tentat)
           = AddToMngBuild("mg_allendy",avAilab.av_allott+avAilab.av_altall)
           = AddToMngBuild("mg_picendy",avAilab.av_pick)
           = AddToMngBuild("mg_waiendy",avAilab.av_waiting)
      ENDIF
 ENDSCAN
 SET RELATION TO
 SELECT (nsElect)
 RETURN .T.
ENDFUNC