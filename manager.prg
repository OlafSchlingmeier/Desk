*
FUNCTION Manager
 PRIVATE noLdarea
 PRIVATE oManagerYesterday
 PRIVATE cfIeldmac
 PRIVATE ALL LIKE nDay*
 PRIVATE ALL LIKE nMon*
 PRIVATE ALL LIKE nYea*
 PRIVATE ALL LIKE nDVAT*
 PRIVATE ALL LIKE nMVAT*
 PRIVATE ALL LIKE nYVAT*
 PRIVATE npAidoutm, npAidouty
 PRIVATE niNternm, niNterny
 PRIVATE ngIftcertm, ngIftcerty
 LOCAL l_oReser
 noLdarea = SELECT()
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_ADDTOMANAGER"),1)
 SELECT maNager
 GOTO BOTTOM IN "Manager"
 DO WHILE (maNager.mg_date==g_sysdate)
      = loGdata("Record in manager for "+DTOC(g_sysdate)+" exists.", ;
        "Audit.Log")
      = loGdata("Record in manager for "+DTOC(g_sysdate)+" deleted.", ;
        "Audit.Log")
      DELETE
      GOTO BOTTOM
 ENDDO
 SCATTER FIELDS mg_gstldg, mg_gcldg, mg_dldg, mg_cldg NAME oManagerYesterday
 FOR ni = 1 TO 9
      cmAcro = "nDayA"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nDVAT"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nMVAT"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nYVAT"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nDayP"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nMonA"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nMonP"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nYeaA"+STR(ni, 1)
      &cMacro = 0
      cmAcro = "nYeaP"+STR(ni, 1)
      &cMacro = 0
 ENDFOR
 IF neWperiod(g_sysdate)
      npAidoutm = 0.00
      niNternm = 0.00
      ngIftcertm = 0.00
      FOR ni = 1 TO 9
           cmAcro = "nMonA"+STR(ni, 1)
           &cMacro = 0
           cmAcro = "nMonP"+STR(ni, 1)
           &cMacro = 0
           cmAcro = "nMVAT"+STR(ni, 1)
           &cMacro = 0
      ENDFOR
      IF neWyear(g_sysdate)
           npAidouty = 0.00
           niNterny = 0.00
           ngIftcerty = 0.00
           FOR ni = 1 TO 9
                cmAcro = "nYeaA"+STR(ni, 1)
                &cMacro = 0
                cmAcro = "nYeaP"+STR(ni, 1)
                &cMacro = 0
                cmAcro = "nYVAT"+STR(ni, 1)
                &cMacro = 0
           ENDFOR
      ELSE
           npAidouty = maNager.mg_pdouty
           niNterny = maNager.mg_interny
           ngIftcerty = maNager.mg_gcerty
           FOR ni = 1 TO 9
                cmAcro = "nYeaA"+STR(ni, 1)
                cfIeld = "Manager.Mg_YeaG"+STR(ni, 1)
                &cMacro = Eval(cField)
                cmAcro = "nYeaP"+STR(ni, 1)
                cfIeld = "Manager.Mg_YeaP"+STR(ni, 1)
                &cMacro = Eval(cField)
                cmAcro = "nYVAT"+STR(ni, 1)
                cfIeld = "Manager.Mg_YVAT"+STR(ni, 1)
                &cMacro = Eval(cField)
           ENDFOR
      ENDIF
 ELSE
      npAidoutm = maNager.mg_pdoutm
      niNternm = maNager.mg_internm
      ngIftcertm = maNager.mg_gcertm
      npAidouty = maNager.mg_pdouty
      niNterny = maNager.mg_interny
      ngIftcerty = maNager.mg_gcerty
      FOR ni = 1 TO 9
           cmAcro = "nMonA"+STR(ni, 1)
           cfIeld = "Manager.Mg_MonG"+STR(ni, 1)
           &cMacro = Eval(cField)
           cmAcro = "nYeaA"+STR(ni, 1)
           cfIeld = "Manager.Mg_YeaG"+STR(ni, 1)
           &cMacro = Eval(cField)
           cmAcro = "nMonP"+STR(ni, 1)
           cfIeld = "Manager.Mg_MonP"+STR(ni, 1)
           &cMacro = Eval(cField)
           cmAcro = "nYeaP"+STR(ni, 1)
           cfIeld = "Manager.Mg_YeaP"+STR(ni, 1)
           &cMacro = Eval(cField)
           cmAcro = "nMVAT"+STR(ni, 1)
           cfIeld = "Manager.Mg_MVAT"+STR(ni, 1)
           &cMacro = Eval(cField)
           cmAcro = "nYVAT"+STR(ni, 1)
           cfIeld = "Manager.Mg_YVAT"+STR(ni, 1)
           &cMacro = Eval(cField)
      ENDFOR
 ENDIF
 SELECT maNager
 IF ( .NOT. EOF("Manager"))
      COPY TO TmpMngr NEXT 1
      USE TmpMngr IN 0
 ELSE
      COPY TO TmpMngr STRUCTURE
      USE TmpMngr IN 0
      APPEND BLANK
 ENDIF
 IF (maNager.mg_date<>g_sysdate)
      INSERT INTO Manager (mg_date) VALUES (g_sysdate)
 ENDIF
 SELECT maNager
 SCATTER BLANK MEMVAR
 M.mg_date = g_sysdate
 M.mg_pdoutm = npAidoutm
 M.mg_pdouty = npAidouty
 M.mg_internm = niNternm
 M.mg_interny = niNterny
 M.mg_gcertm = ngIftcertm
 M.mg_gcerty = ngIftcerty
 FOR ni = 1 TO 9
      cmAcro = "nDayA"+STR(ni, 1)
      cfIeld = "m.Mg_DayG"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nDVAT"+STR(ni, 1)
      cfIeld = "m.Mg_DVAT"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nMonA"+STR(ni, 1)
      cfIeld = "m.Mg_MonG"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nMVAT"+STR(ni, 1)
      cfIeld = "m.Mg_MVAT"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nYeaA"+STR(ni, 1)
      cfIeld = "m.Mg_YeaG"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nYVAT"+STR(ni, 1)
      cfIeld = "m.Mg_YVAT"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nDayP"+STR(ni, 1)
      cfIeld = "m.Mg_DayP"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nMonP"+STR(ni, 1)
      cfIeld = "m.Mg_MonP"+STR(ni, 1)
      &cField = Eval(cMacro)
      cmAcro = "nYeaP"+STR(ni, 1)
      cfIeld = "m.Mg_YeaP"+STR(ni, 1)
      &cField = Eval(cMacro)
 ENDFOR
 SELECT roOm
 *GOTO TOP IN "Room"
 SET ORDER TO TAG1 IN roomtype
 SET RELATION TO roOm.rm_roomtyp INTO roOmtype
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_CNTROOMSAVAILABLE"),1)
 p_oAudit.txtinfo(STR(M.mg_roomavl),2)
 IF NOT HotelClosed(M.mg_date)
      COUNT FOR roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum TO M.mg_roomavl
      SUM roOm.rm_beds TO M.mg_bedavl FOR roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum
 ELSE
      M.mg_roomavl = 0
      M.mg_bedavl = 0
 ENDIF
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_CNTBEDSAVAILABLE"),1)
 p_oAudit.txtinfo(STR(M.mg_bedavl),2)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_COOOROOMS"),1)
 COUNT FOR roOm.rm_status="OOO" .AND. roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum TO M.mg_roomooo
 p_oAudit.txtinfo(STR(M.mg_roomooo),2)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_COOSROOMS"),1)
 COUNT FOR roOm.rm_status="OOS" .AND. roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum TO M.mg_roomoos
 p_oAudit.txtinfo(STR(M.mg_roomoos),2)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_CNTOOOBEDS"),1)
 SUM roOm.rm_beds TO M.mg_bedooo FOR roOm.rm_status="OOO" .AND.  ;
     roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum
 p_oAudit.txtinfo(STR(M.mg_bedooo),2)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_CNTOOSBEDS"),1)
 SUM roOm.rm_beds TO M.mg_bedoos FOR roOm.rm_status="OOS" .AND.  ;
     roOmtype.rt_group==1 .AND. roOmtype.rt_vwsum
 p_oAudit.txtinfo(STR(M.mg_bedoos),2)
 SET RELATION TO
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_RESERVAT"),1)
 = ManagerReservationOccupancy()
 = ManagerSharingOccupancy()
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_OCCROOMS")+" "+LTRIM(STR(M.mg_roomocc)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_OCCBEDS")+" "+LTRIM(STR(M.mg_bedocc)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_ROOMARR")+" "+LTRIM(STR(M.mg_roomarr)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_PERSARR")+" "+LTRIM(STR(M.mg_persarr)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_ROOMDEP")+" "+LTRIM(STR(M.mg_roomdep)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_PERSDEP")+" "+LTRIM(STR(M.mg_persdep)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_CXLTODAY")+" "+LTRIM(STR(M.mg_rescxl)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_CXLLATE")+" "+LTRIM(STR(M.mg_cxllate)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_NSTODAY")+" "+LTRIM(STR(M.mg_resns)),1)
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_NEWRES")+" "+LTRIM(STR(M.mg_resnew)),1)
 = maNagerfinancial()
 = leDgerinpost()
 = maNagerdeposit()
 = maNagerar()
 = foRecast()
 = arRivalsanddepartures()
 = CalcCumulativeFields()
 SELECT maNager
 GATHER MEMVAR
 RELEASE ALL LIKE 'Mg_*'
 RELEASE ALL LIKE 'nDay*'
 RELEASE ALL LIKE 'nMon*'
 RELEASE ALL LIKE 'nYea*'
 IF (USED("TmpMngr"))
      SELECT tmPmngr
      USE
 ENDIF
 = fiLedelete("TmpMngr.Dbf")
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
PROCEDURE ManagerReservationOccupancy
 LOCAL l_nAlias, l_cOrder, l_oReser, l_nMultiplier, l_nRecnoYesterday
 LOCAL l_oReservationYesterday, l_oReservationToday, l_lYesterdaySharing, l_lTodaySharing, l_nYesterdayPersons, l_nTodayPersons
 l_nAlias = SELECT()
 SELECT reservat
 l_cOrder = ORDER()
 SET ORDER TO
 SCAN
      * p_oAudit.progress(RECNO())
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
                          M.mg_tencxl = M.mg_tencxl+reServat.rs_rooms
                     CASE INLIST(reServat.rs_cxlstat, "OPT", "LST")
                          M.mg_optcxl = M.mg_optcxl+reServat.rs_rooms
                     OTHERWISE
                          M.mg_rescxl = M.mg_rescxl+reServat.rs_rooms
                ENDCASE
           ENDIF
           IF (reServat.rs_cxldate==(g_sysdate+1) .AND. reServat.rs_status="CXL")
                M.mg_cxllate = M.mg_cxllate+reServat.rs_rooms
           ENDIF
           IF (reServat.rs_cxldate==g_sysdate .AND. reServat.rs_status="NS")
                DO CASE
                     CASE reServat.rs_cxlstat = "TEN"
                          M.mg_tencxl = M.mg_tencxl+reServat.rs_rooms
                     CASE INLIST(reServat.rs_cxlstat, "OPT", "LST")
                          M.mg_optcxl = M.mg_optcxl+reServat.rs_rooms
                     OTHERWISE
                          M.mg_resns = M.mg_resns+reServat.rs_rooms
                ENDCASE
           ENDIF
           IF (reServat.rs_created==g_sysdate)
                M.mg_resnew = M.mg_resnew+reServat.rs_rooms
           ENDIF
      ENDIF
      IF INLIST(roomtype.rt_group, 1, 2, 4) AND (reservat.rs_arrdate <= g_sysdate) AND EMPTY(reservat.rs_in) AND ;
                NOT INLIST(reservat.rs_status, "CXL", "NS")
           * If exist some definite (not IN or OUT status) reservations in past and change them status to NO SHOW.
           IF (reServat.rs_arrdate==g_sysdate)
                M.mg_resns = M.mg_resns+reServat.rs_rooms
           ENDIF
           SELECT reservat
           SCATTER NAME l_oReser MEMO
           l_oReser.rs_cxlstat = l_oReser.rs_status
           l_oReser.rs_status = "NS"
           l_oReser.rs_updated = g_sysdate
           l_oReser.rs_cxldate = g_sysdate
           DO CheckAndSave IN ProcReservat WITH l_oReser, .F., .F., "NOSHOW"
      ENDIF
      IF INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum AND NOT INLIST(reservat.rs_status, "CXL", "NS")
           l_nTodayPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
           IF NOT EMPTY(reservat.rs_in) AND NOT EMPTY(reservat.rs_out) AND ;
                     (reservat.rs_arrdate = reservat.rs_depdate) AND (rs_depdate==g_sysdate)
                IF NOT l_lTodaySharing
                     M.mg_roomarr = M.mg_roomarr+reServat.rs_rooms     && Always OUT
                     M.mg_rmduse = M.mg_rmduse+reServat.rs_rooms
                ENDIF
                M.mg_persarr = M.mg_persarr+l_nTodayPersons            && Always OUT
                M.mg_prduse = M.mg_prduse+l_nTodayPersons
           ENDIF
           IF (reServat.rs_depdate==g_sysdate)
                IF NOT l_lTodaySharing
                     M.mg_roomdep = M.mg_roomdep+reServat.rs_rooms
                ENDIF
                M.mg_persdep = M.mg_persdep+l_nTodayPersons
           ENDIF
           IF ( .NOT. EMPTY(reServat.rs_in) .AND. EMPTY(reServat.rs_out))
                IF (reServat.rs_arrdate==g_sysdate)
                     IF NOT l_lTodaySharing
                          M.mg_roomarr = M.mg_roomarr+reServat.rs_rooms
                     ENDIF
                     M.mg_persarr = M.mg_persarr+l_nTodayPersons
                ENDIF
                IF (reServat.rs_depdate==g_sysdate)
                     IF NOT l_lTodaySharing
                          M.mg_roomdep = M.mg_roomdep+reServat.rs_rooms
                     ENDIF
                     M.mg_persdep = M.mg_persdep+l_nTodayPersons
                ELSE
                     IF roomtype.rt_group = 4
                          l_nMultiplier = OCCURS(",", room.rm_link) + 1
                     ELSE
                          l_nMultiplier = 1
                     ENDIF
                     IF NOT l_lTodaySharing
                          M.mg_roomocc = M.mg_roomocc + reservat.rs_rooms * l_nMultiplier
                     ENDIF
                     M.mg_bedocc = M.mg_bedocc + l_nTodayPersons
                     IF (reServat.rs_complim)
                          IF NOT l_lTodaySharing
                               M.mg_comprmd = M.mg_comprmd + reservat.rs_rooms * l_nMultiplier
                          ENDIF
                          M.mg_compprd = M.mg_compprd + l_nTodayPersons
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
                               M.mg_roomarr = M.mg_roomarr+reservat.rs_rooms
                          ENDIF
                          M.mg_persarr = M.mg_persarr+l_nTodayPersons
                     ENDIF
                CASE NOT INLIST(roomtype.rt_group, 1, 4)
                * If reservation yesterday was in standard room and today is in non standard room this room is departure room.
                     GO l_nRecnoYesterday IN roomtype
                     IF INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
                          IF NOT l_lYesterdaySharing
                               M.mg_roomdep = M.mg_roomdep + reservat.rs_rooms
                          ENDIF
                          M.mg_persdep = M.mg_persdep + l_nYesterdayPersons
                     ENDIF
           ENDCASE
      ENDIF
 ENDSCAN
 SET ORDER TO l_cOrder
 SELECT (l_nAlias)
ENDPROC
*
PROCEDURE ManagerSharingOccupancy
 LOCAL l_nAlias, l_cOrder, l_nMultiplier, l_lIsArrival, l_lIsDeparture, l_lIsDayUse, l_lIsComplim
 l_nAlias = SELECT()
 SELECT sharing
 l_cOrder = ORDER()
 SET ORDER TO
 SET RELATION TO sd_roomtyp INTO roomtype
 SCAN FOR NOT sd_history AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
      DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "ROOMDEP", g_sysdate
      IF l_lIsDeparture
           M.mg_roomdep = M.mg_roomdep + 1
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDayUse, sd_shareid, sd_lowdat, sd_highdat, "DAYUSE", g_sysdate
      IF (sd_status = "OUT") AND l_lIsDayUse
           M.mg_roomarr = M.mg_roomarr + 1     && Always OUT
           M.mg_rmduse = M.mg_rmduse + 1
      ENDIF
      IF sd_status = "IN"
           DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ROOMARR", g_sysdate
           IF (sd_lowdat = g_sysdate) AND l_lIsArrival
                M.mg_roomarr = M.mg_roomarr + 1
           ENDIF
           IF BETWEEN(g_sysdate, sd_lowdat, sd_highdat)
                IF (roomtype.rt_group = 4) AND SEEK(sd_roomnum,"room","tag1")
                     l_nMultiplier = OCCURS(",", room.rm_link) + 1
                ELSE
                     l_nMultiplier = 1
                ENDIF
                M.mg_roomocc = M.mg_roomocc + l_nMultiplier
                DO RiShareInterval IN ProcResRooms WITH l_lIsComplim, sd_shareid, sd_lowdat, sd_highdat, "COMPLIM"
                IF l_lIsComplim
                     M.mg_comprmd = M.mg_comprmd + l_nMultiplier
                ENDIF
           ENDIF
      ENDIF
 ENDSCAN
 SET RELATION TO
 SET ORDER TO l_cOrder
 SELECT (l_nAlias)
ENDPROC
*
FUNCTION LedgerInPost
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_LEDGER"),1)
 ntOtdaygroup = 0
 ntOtdaypay = 0
 ntOtdayvat = 0
 FOR ni = 1 TO 9
      cmAcro = "m.Mg_DayG"+STR(ni, 1)
      ntOtdaygroup = ntOtdaygroup+EVALUATE(cmAcro)
      cmAcro = "m.Mg_DayP"+STR(ni, 1)
      ntOtdaypay = ntOtdaypay+EVALUATE(cmAcro)
      cmAcro = "m.Mg_DVAT"+STR(ni, 1)
      ntOtdayvat = ntOtdayvat+EVALUATE(cmAcro)
 ENDFOR
 M.mg_gstldg = oManagerYesterday.mg_gstldg + ntOtdaygroup + IIF(paRam.pa_exclvat, ntOtdayvat, 0) + M.mg_pdoutd + M.mg_internd + M.mg_gcertd - ntOtdaypay
 M.mg_gcldg = oManagerYesterday.mg_gcldg + M.mg_gcertd - M.mg_dayp7
 p_oAudit.txtinfo(STR(M.mg_gstldg),2)
 RETURN .T.
ENDFUNC
*
FUNCTION ManagerFinancial
 PRIVATE laVatcode
 DIMENSION laVatcode[10]
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_FINANCIAL"),1)
 laVatcode[1] = .F.
 FOR ni = 1 TO 9
      laVatcode[ni+1] = dbLookup("PickList","TAG3","VATGROUP  "+STR(ni,  ;
               3),"Found()")
 ENDFOR
 nsElect = SELECT()
 MNFinancialDataGet(g_sysdate) && Creates curposts cursor!
 SELECT arTicle
 SET ORDER TO 1
 SELECT paYmetho
 SET ORDER TO 1
 SELECT curPosts
 SET RELATION TO hp_artinum INTO arTicle
 SET RELATION ADDITIVE TO curPosts.hp_paynum INTO paYmetho
 SCAN
      IF ( .NOT. curPosts.hp_cancel .AND. (EMPTY(curPosts.hp_ratecod) .OR. (  ;
         .NOT. EMPTY(curPosts.hp_ratecod) .AND. curPosts.hp_split)))
           IF (curPosts.hp_paynum<>0)
                IF  .NOT. INLIST(curPosts.hp_reserid, -2, -1, 0.200, 0.300)
                     cmAcro = "m.Mg_DayP"+STR(MAX(paYmetho.pm_paytyp, 1), 1)
                     &cMacro = Eval(cMacro) - curPosts.hp_Amount
                     cmAcro = "m.Mg_MonP"+STR(MAX(paYmetho.pm_paytyp, 1), 1)
                     &cMacro = Eval(cMacro) - curPosts.hp_Amount
                     cmAcro = "m.Mg_YeaP"+STR(MAX(paYmetho.pm_paytyp, 1), 1)
                     &cMacro = Eval(cMacro) - curPosts.hp_Amount
                ENDIF
           ELSE
                DO CASE
                     CASE arTicle.ar_artityp=2
                          M.mg_pdoutd = M.mg_pdoutd+curPosts.hp_amount
                          M.mg_pdoutm = M.mg_pdoutm+curPosts.hp_amount
                          M.mg_pdouty = M.mg_pdouty+curPosts.hp_amount
                     CASE arTicle.ar_artityp=3
                          M.mg_internd = M.mg_internd+curPosts.hp_amount
                          M.mg_internm = M.mg_internm+curPosts.hp_amount
                          M.mg_interny = M.mg_interny+curPosts.hp_amount
                     CASE arTicle.ar_artityp=4
                          M.mg_gcertd = M.mg_gcertd+curPosts.hp_amount
                          M.mg_gcertm = M.mg_gcertm+curPosts.hp_amount
                          M.mg_gcerty = M.mg_gcerty+curPosts.hp_amount
                     OTHERWISE
                          cmAcro = "m.Mg_DayG"+STR(MAX(arTicle.ar_main, 1), 1)
                          &cMacro   = Eval(cMacro) + curPosts.hp_Amount
                          cmAcro = "m.Mg_MonG"+STR(MAX(arTicle.ar_main, 1), 1)
                          &cMacro = Eval(cMacro) + curPosts.hp_Amount
                          cmAcro = "m.Mg_YeaG"+STR(MAX(arTicle.ar_main, 1), 1)
                          &cMacro = Eval(cMacro) + curPosts.hp_Amount
                          FOR ni = 1 TO 9
                               IF (laVatcode(ni+1))
                                    cmAcro = "m.Mg_DVAT"+ ;
                                     STR(MAX(arTicle.ar_main, 1), 1)
                                    cvAtmacro = "curPosts.hp_Vat"+STR(ni, 1)
                                    &cMacro   = Eval(cMacro) + Eval(cVATMacro)
                                    cmAcro = "m.Mg_MVAT"+ ;
                                     STR(MAX(arTicle.ar_main, 1), 1)
                                    cvAtmacro = "curPosts.hp_Vat"+STR(ni, 1)
                                    &cMacro   = Eval(cMacro) + Eval(cVATMacro)
                                    cmAcro = "m.Mg_YVAT"+ ;
                                     STR(MAX(arTicle.ar_main, 1), 1)
                                    cvAtmacro = "curPosts.hp_Vat"+STR(ni, 1)
                                    &cMacro   = Eval(cMacro) + Eval(cVATMacro)
                               ENDIF
                          ENDFOR
                ENDCASE
           ENDIF
      ENDIF
 ENDSCAN
 SET RELATION TO
 USE IN curPosts
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION Forecast
 LOCAL nsElect, l_nMonth, l_nYear, l_cCur, l_dTomorrow
 nsElect = SELECT()
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_FORECAST"),1)
 l_nMonth = MONTH(g_sysdate)
 l_nYear=YEAR(g_sysdate)
 l_dTomorrow = g_sysdate+1
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
      SELECT av_date, av_avail, av_definit, av_option, av_tentat, av_allott, av_altall, av_pick, av_waiting, av_ooservc
           FROM availab 
           INNER JOIN roomtype ON av_roomtyp = rt_roomtyp 
           WHERE av_date BETWEEN <<sqlcnv(l_dTomorrow,.T.)>> AND <<sqlcnv(g_sysdate+365, .T.)>> AND 
           rt_group = <<sqlcnv(1,.T.)>> 
           AND rt_vwsum = <<sqlcnv(.T.,.T.)>>
 ENDTEXT

 l_cCur = sqlcursor(l_cSql)
 SELECT (l_cCur)
 SCAN ALL
      IF av_date = l_dTomorrow
           M.mg_maxtomo = M.mg_maxtomo+av_avail-av_ooservc
           M.mg_deftomo = M.mg_deftomo+av_definit
           M.mg_opttomo = M.mg_opttomo+av_option
           M.mg_tentomo = M.mg_tentomo+av_tentat
           M.mg_alltomo = M.mg_alltomo+av_allott+av_altall
           M.mg_pictomo = M.mg_pictomo+av_pick
           M.mg_waitomo = M.mg_waitomo+av_waiting
      ENDIF
      IF BETWEEN(av_date, l_dTomorrow, g_sysdate+7)
           M.mg_maxnext = M.mg_maxnext+av_avail-av_ooservc
           M.mg_defnext = M.mg_defnext+av_definit
           M.mg_optnext = M.mg_optnext+av_option
           M.mg_tennext = M.mg_tennext+av_tentat
           M.mg_allnext = M.mg_allnext+av_allott+av_altall
           M.mg_picnext = M.mg_picnext+av_pick
           M.mg_wainext = M.mg_wainext+av_waiting
      ENDIF
      IF av_date>=l_dTomorrow AND MONTH(av_date)=l_nMonth AND YEAR(av_date)=l_nYear
           M.mg_maxendm = M.mg_maxendm+av_avail-av_ooservc
           M.mg_defendm = M.mg_defendm+av_definit
           M.mg_optendm = M.mg_optendm+av_option
           M.mg_tenendm = M.mg_tenendm+av_tentat
           M.mg_allendm = M.mg_allendm+av_allott+av_altall
           M.mg_picendm = M.mg_picendm+av_pick
           M.mg_waiendm = M.mg_waiendm+av_waiting
      ENDIF
      IF BETWEEN(av_date, l_dTomorrow, g_sysdate+30) &&av_date<=(g_sysdate+30)
           M.mg_max30da = M.mg_max30da+av_avail-av_ooservc
           M.mg_def30da = M.mg_def30da+av_definit
           M.mg_opt30da = M.mg_opt30da+av_option
           M.mg_ten30da = M.mg_ten30da+av_tentat
           M.mg_all30da = M.mg_all30da+av_allott+av_altall
           M.mg_pic30da = M.mg_pic30da+av_pick
           M.mg_wai30da = M.mg_wai30da+av_waiting
      ENDIF
      IF BETWEEN(av_date, l_dTomorrow, g_sysdate+365)&&av_date<=(g_sysdate+365)
           M.mg_max365d = M.mg_max365d+av_avail-av_ooservc
           M.mg_def365d = M.mg_def365d+av_definit
           M.mg_opt365d = M.mg_opt365d+av_option
           M.mg_ten365d = M.mg_ten365d+av_tentat
           M.mg_all365d = M.mg_all365d+av_allott+av_altall
           M.mg_pic365d = M.mg_pic365d+av_pick
           M.mg_wai365d = M.mg_wai365d+av_waiting
      ENDIF
      IF av_date>=l_dTomorrow AND YEAR(av_date)=l_nYear
           M.mg_maxendy = M.mg_maxendy+av_avail-av_ooservc
           M.mg_defendy = M.mg_defendy+av_definit
           M.mg_optendy = M.mg_optendy+av_option
           M.mg_tenendy = M.mg_tenendy+av_tentat
           M.mg_allendy = M.mg_allendy+av_allott+av_altall
           M.mg_picendy = M.mg_picendy+av_pick
           M.mg_waiendy = M.mg_waiendy+av_waiting
      ENDIF
 ENDSCAN
 dclose(l_cCur)
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION ArrivalsAndDepartures
 PRIVATE nsElect
 LOCAL l_nMgrArr, l_nMgrDep, l_cRoomtype, l_oResrooms, l_lSharing, l_lIsArrival, l_lIsDeparture
 nsElect = SELECT()
 M.mg_arrival = 0
 M.mg_departu = 0
 l_nMgrArr = 0
 l_nMgrDep = 0
 SELECT reServat
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_ARRIVALS"),1)
 SCAN FOR (DTOS(rs_arrdate)+rs_lname = DTOS(g_sysdate+1)) AND NOT INLIST(rs_status, "CXL", "NS")
     IF SEEK(reservat.rs_roomtyp,"roomtype","tag1") AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
          RiGetRoom(reservat.rs_reserid, reservat.rs_arrdate, @l_oResrooms)
          IF ISNULL(l_oResrooms) OR EMPTY(l_oResrooms.ri_shareid)
              M.mg_arrival = M.mg_arrival + reservat.rs_rooms
          ENDIF
     ENDIF
 ENDSCAN
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_DEPARTURES"),1)
 SCAN FOR (DTOS(rs_depdate)+rs_lname = DTOS(g_sysdate+1)) AND NOT INLIST(rs_status, "CXL", "NS")
      RiGetRoom(reservat.rs_reserid, reservat.rs_depdate, @l_oResrooms)
      l_lSharing = NOT (ISNULL(l_oResrooms) OR EMPTY(l_oResrooms.ri_shareid))
      l_cRoomtype = IIF(ISNULL(l_oResrooms), reservat.rs_roomtyp, l_oResrooms.ri_roomtyp)
      IF SEEK(l_cRoomtype,"roomtype","tag1") AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum AND NOT l_lSharing
           M.mg_departu = M.mg_departu + reservat.rs_rooms
      ENDIF
 ENDSCAN
 SELECT sharing
 SET RELATION TO sd_roomtyp INTO roomtype
 SCAN FOR NOT sd_history AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
    DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ARRIVAL", g_sysdate+1
    IF (sd_lowdat = g_sysdate+1) AND l_lIsArrival
        l_nMgrArr = l_nMgrArr + 1
    ENDIF
    DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "DEPARTURE", g_sysdate+1
    IF l_lIsDeparture
        l_nMgrDep = l_nMgrDep + 1
    ENDIF
 ENDSCAN
 SET RELATION TO
 M.mg_arrival = M.mg_arrival + l_nMgrArr
 M.mg_departu = M.mg_departu + l_nMgrDep
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION CalcCumulativeFields
 IF neWperiod(g_sysdate)
      M.mg_roomavm = M.mg_roomavl
      M.mg_bedavlm = M.mg_bedavl
      M.mg_rmooom = M.mg_roomooo
      M.mg_rmoosm = M.mg_roomoos
      M.mg_bdooom = M.mg_bedooo
      M.mg_bdoosm = M.mg_bedoos
      M.mg_rmoccm = M.mg_roomocc
      M.mg_bdoccm = M.mg_bedocc
      M.mg_rmarrm = M.mg_roomarr
      M.mg_perarrm = M.mg_persarr
      M.mg_roodepm = M.mg_roomdep
      M.mg_perdepm = M.mg_persdep
      M.mg_rescxlm = M.mg_rescxl
      M.mg_optcxlm = M.mg_optcxl
      M.mg_tencxlm = M.mg_tencxl
      M.mg_cxllatm = M.mg_cxllate
      M.mg_resnsm = M.mg_resns
      M.mg_resnewm = M.mg_resnew
      M.mg_prdusem = M.mg_prduse
      M.mg_rmdusem = M.mg_rmduse
      M.mg_comprmm = M.mg_comprmd
      M.mg_compprm = M.mg_compprd
 ELSE
      M.mg_roomavm = tmPmngr.mg_roomavm+M.mg_roomavl
      M.mg_bedavlm = tmPmngr.mg_bedavlm+M.mg_bedavl
      M.mg_rmooom = tmPmngr.mg_rmooom+M.mg_roomooo
      M.mg_rmoosm = tmPmngr.mg_rmoosm+M.mg_roomoos
      M.mg_bdooom = tmPmngr.mg_bdooom+M.mg_bedooo
      M.mg_bdoosm = tmPmngr.mg_bdoosm+M.mg_bedoos
      M.mg_rmoccm = tmPmngr.mg_rmoccm+M.mg_roomocc
      M.mg_bdoccm = tmPmngr.mg_bdoccm+M.mg_bedocc
      M.mg_rmarrm = tmPmngr.mg_rmarrm+M.mg_roomarr
      M.mg_perarrm = tmPmngr.mg_perarrm+M.mg_persarr
      M.mg_roodepm = tmPmngr.mg_roodepm+M.mg_roomdep
      M.mg_perdepm = tmPmngr.mg_perdepm+M.mg_persdep
      M.mg_rescxlm = tmPmngr.mg_rescxlm+M.mg_rescxl
      M.mg_optcxlm = tmPmngr.mg_optcxlm+M.mg_optcxl
      M.mg_tencxlm = tmPmngr.mg_tencxlm+M.mg_tencxl
      M.mg_cxllatm = tmPmngr.mg_cxllatm+M.mg_cxllate
      M.mg_resnsm = tmPmngr.mg_resnsm+M.mg_resns
      M.mg_resnewm = tmPmngr.mg_resnewm+M.mg_resnew
      M.mg_prdusem = tmPmngr.mg_prdusem+M.mg_prduse
      M.mg_rmdusem = tmPmngr.mg_rmdusem+M.mg_rmduse
      M.mg_comprmm = tmPmngr.mg_comprmm+M.mg_comprmd
      M.mg_compprm = tmPmngr.mg_compprm+M.mg_compprd
 ENDIF
 IF neWyear(g_sysdate)
      M.mg_roomavy = M.mg_roomavl
      M.mg_bedavly = M.mg_bedavl
      M.mg_rmoooy = M.mg_roomooo
      M.mg_rmoosy = M.mg_roomoos
      M.mg_bdoooy = M.mg_bedooo
      M.mg_bdoosy = M.mg_bedoos
      M.mg_rmoccy = M.mg_roomocc
      M.mg_bdoccy = M.mg_bedocc
      M.mg_rmarry = M.mg_roomarr
      M.mg_perarry = M.mg_persarr
      M.mg_roodepy = M.mg_roomdep
      M.mg_perdepy = M.mg_persdep
      M.mg_rescxly = M.mg_rescxl
      M.mg_optcxly = M.mg_optcxl
      M.mg_tencxly = M.mg_tencxl
      M.mg_cxllaty = M.mg_cxllate
      M.mg_resnsy = M.mg_resns
      M.mg_resnewy = M.mg_resnew
      M.mg_prdusey = M.mg_prduse
      M.mg_rmdusey = M.mg_rmduse
      M.mg_comprmy = M.mg_comprmd
      M.mg_comppry = M.mg_compprd
 ELSE
      M.mg_roomavy = tmPmngr.mg_roomavy+M.mg_roomavl
      M.mg_bedavly = tmPmngr.mg_bedavly+M.mg_bedavl
      M.mg_rmoooy = tmPmngr.mg_rmoooy+M.mg_roomooo
      M.mg_rmoosy = tmPmngr.mg_rmoosy+M.mg_roomoos
      M.mg_bdoooy = tmPmngr.mg_bdoooy+M.mg_bedooo
      M.mg_bdoosy = tmPmngr.mg_bdoosy+M.mg_bedoos
      M.mg_rmoccy = tmPmngr.mg_rmoccy+M.mg_roomocc
      M.mg_bdoccy = tmPmngr.mg_bdoccy+M.mg_bedocc
      M.mg_rmarry = tmPmngr.mg_rmarry+M.mg_roomarr
      M.mg_perarry = tmPmngr.mg_perarry+M.mg_persarr
      M.mg_roodepy = tmPmngr.mg_roodepy+M.mg_roomdep
      M.mg_perdepy = tmPmngr.mg_perdepy+M.mg_persdep
      M.mg_rescxly = tmPmngr.mg_rescxly+M.mg_rescxl
      M.mg_optcxly = tmPmngr.mg_optcxly+M.mg_optcxl
      M.mg_tencxly = tmPmngr.mg_tencxly+M.mg_tencxl
      M.mg_cxllaty = tmPmngr.mg_cxllaty+M.mg_cxllate
      M.mg_resnsy = tmPmngr.mg_resnsy+M.mg_resns
      M.mg_resnewy = tmPmngr.mg_resnewy+M.mg_resnew
      M.mg_prdusey = tmPmngr.mg_prdusey+M.mg_prduse
      M.mg_rmdusey = tmPmngr.mg_rmdusey+M.mg_rmduse
      M.mg_comprmy = tmPmngr.mg_comprmy+M.mg_comprmd
      M.mg_comppry = tmPmngr.mg_comppry+M.mg_compprd
 ENDIF
ENDFUNC
*
FUNCTION ReCalcManager
 PRIVATE ddAte, p_lRecalcOccupancy
 PRIVATE ceXitmessage
 PRIVATE adLg
 LOCAL l_dStartDate, l_cArchScripts
 ceXitmessage = ""
 IF ( .NOT. opEnfile(.F.,"Manager"))
      ceXitmessage = GetLangText("MANAGER","TXT_CANNOT_OPEN_MANAGER")
 ELSE
      SELECT maNager
      SET ORDER TO 1
      GOTO TOP
      DO WHILE ( .NOT. EOF() .AND. EMPTY(maNager.mg_date))
           SKIP 1
      ENDDO
      ddAte = {}
      DIMENSION adLg[2, 8]
      adLg[1, 1] = "date"
      adLg[1, 2] = GetLangText("MANAGER","TXT_ENTER_DATE")
      adLg[1, 3] = 'Manager.Mg_Date'
      adLg[1, 4] = ""
      adLg[1, 5] = 11
      adLg[1, 6] = ""
      adLg[1, 7] = ""
      adLg[1, 8] = 0
      adLg[2, 1] = "recalcocc"
      adLg[2, 2] = GetLangText("MANAGER","TXT_RECALC_OCC")
      adLg[2, 3] = ".T."
      adLg[2, 4] = "@*C"
      adLg[2, 5] = 11
      adLg[2, 6] = ""
      adLg[2, 7] = ""
      adLg[2, 8] = .F.
      IF diAlog(GetLangText("MANAGER","TXT_RECALCULATE"),"",@adLg)
           ddAte = adLg(1,8)
           p_lRecalcOccupancy = adLg(2,8)
      ENDIF
      IF (EMPTY(ddAte))
           ceXitmessage = GetLangText("MANAGER","TXT_NO_CHANGES_MADE")
      ELSE
           IF ( .NOT. SEEK(DTOS(ddAte), "Manager"))
                IF ( .NOT. yeSno(GetLangText("MANAGER","TXT_DATE_NOT_ON_FILE")+ ;
                   ";"+GetLangText("MANAGER","TXT_CREATE_IT"),GetLangText("MANAGER", ;
                   "TXT_RECALCULATE")))
                     ceXitmessage = GetLangText("MANAGER","TXT_DATE_NOT_ON_FILE")
                ELSE
                     SELECT maNager
                     APPEND BLANK
                     REPLACE maNager.mg_date WITH ddAte
                ENDIF
           ENDIF
           IF (EMPTY(ceXitmessage))
                IF (maKechanges(ddAte))
                     SELECT maNager
                     = SEEK(DTOS(ddAte))
                     l_dStartDate = ddAte
                    ******************** Prepare SQLs for archive ******************************************************
                    *
                    TEXT TO l_cArchScripts TEXTMERGE NOSHOW PRETEXT 15
                    SELECT histres.* FROM histres WHERE hr_reserid > 1 AND hr_depdate > <<SqlCnvB(l_dStartDate)>>;
               
                    SELECT hresext.* FROM hresext WHERE rs_reserid = <<SqlCnvB(reservat.rs_reserid)>>;
               
                    SELECT histpost.* FROM histpost WHERE hp_date >= <<SqlCnvB(l_dStartDate)>>
                    ENDTEXT
                    ProcArchive("RestoreArchive", "histres,hresext,histpost", l_cArchScripts, l_dStartDate)
                    *
                    ****************************************************************************************************
                     DO WHILE (ddAte<g_sysdate)
                          IF ( .NOT. SEEK(DTOS(ddAte), "Manager"))
                               APPEND BLANK
                               REPLACE maNager.mg_date WITH ddAte
                          ENDIF
                          = hiStorymanagerfinancial(ddAte)
                          ddAte = ddAte+1
                     ENDDO
                     WAIT CLEAR
                     DO Recalculate IN managerbuildings WITH l_dStartDate, p_lRecalcOccupancy
                     IF p_lRecalcOccupancy
                          = HistoryManagerOccupancy(l_dStartDate)
                     ENDIF
                    ******************** Delete temp files *************************************************************
                    *
                    ProcArchive("DeleteTempArchive", "histres,hresext,histpost")
                    *
                    ****************************************************************************************************
                     ceXitmessage = GetLangText("MANAGER","TXT_CHANGES_ARE_MADE")
                ELSE
                     ceXitmessage = GetLangText("MANAGER","TXT_CHANGES_ARE_MADE")
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 = alErt(ceXitmessage,GetLangText("MANAGER","TXT_RECALCULATE"))
 = clOsefile("Manager")
 RETURN .T.
ENDFUNC
*
FUNCTION MakeChanges
 PARAMETER ddAte
 PRIVATE lcHangesmade
 PRIVATE ccOpyname
 PRIVATE ceXitmessage
 lcHangesmade = .F.
 ccOpyname = _screen.oGlobal.choteldir+"Tmp\"+DTOS(g_sysdate)+".Mgr"
 ceXitmessage = ""
 DO WHILE (.T.)
      IF ( .NOT. coPymanager(ccOpyname))
           ceXitmessage = GetLangText("MANAGER","TXT_COULD_NOT_COPY_MANAGER")
           EXIT
      ENDIF
      IF ( .NOT. reSetfields(ddAte))
           ceXitmessage = GetLangText("MANAGER","TXT_FIELDS_COULD_NOT_BE_RESET")
           EXIT
      ENDIF
      lcHangesmade = .T.
      EXIT
 ENDDO
 IF ( .NOT. EMPTY(ceXitmessage))
      = alErt(ceXitmessage,GetLangText("MANAGER","TXT_RECALCULATE"))
 ENDIF
 RETURN lcHangesmade
ENDFUNC
*
FUNCTION CopyManager
 PARAMETER ccOpyname
 PRIVATE lsUcces
 lsUcces = .F.
 WAIT WINDOW NOWAIT GetLangText("MANAGER","TXT_COPY_TO")+" "+ccOpyname
 SELECT maNager
 COPY TO (ccOpyname) ALL
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION ResetFields
 PARAMETER ddAte
 WAIT WINDOW NOWAIT GetLangText("MANAGER","TXT_RESET_FIELDS")
 SELECT maNager
 FOR i = 0 TO g_sysdate - ddAte - 1
      IF NOT SEEK(DTOS(ddAte+i),"manager","tag1")
           INSERT INTO manager (mg_date) VALUES (ddAte+i)
      ENDIF
      = reSet("Manager.Mg_DayG")
      = reSet("Manager.Mg_DayP")
      = reSet("Manager.Mg_DVAT")
      = reSet("Manager.Mg_MonG")
      = reSet("Manager.Mg_MonP")
      = reSet("Manager.Mg_MVAT")
      = reSet("Manager.Mg_YeaG")
      = reSet("Manager.Mg_YeaP")
      = reSet("Manager.Mg_YVAT")
      REPLACE maNager.mg_gstldg WITH 0, maNager.mg_pdoutd WITH 0,  ;
              maNager.mg_pdoutm WITH 0, maNager.mg_pdouty WITH 0,  ;
              maNager.mg_internd WITH 0, maNager.mg_internm WITH 0,  ;
              maNager.mg_interny WITH 0, maNager.mg_gcertd WITH 0,  ;
              maNager.mg_gcertm WITH 0, maNager.mg_gcerty WITH 0
      IF p_lRecalcOccupancy
           REPLACE maNager.mg_arrival WITH 0, maNager.mg_departu WITH 0 ;
                   maNager.mg_bedocc WITH 0, maNager.mg_resnew WITH 0 ;
                   maNager.mg_rescxl WITH 0, maNager.mg_roomdep WITH 0 ;
                   maNager.mg_persdep WITH 0, maNager.mg_roomarr WITH 0 ;
                   maNager.mg_persarr WITH 0, maNager.mg_rmduse WITH 0 ;
                   maNager.mg_prduse WITH 0, maNager.mg_roomocc WITH 0 ;
                   maNager.mg_comprmd WITH 0, maNager.mg_compprd WITH 0, ;
                   maNager.mg_resns WITH 0, maNager.mg_roomoos WITH 0, ;
                   maNager.mg_bedoos WITH 0, maNager.mg_optcxl WITH 0, ;
                   maNager.mg_tencxl WITH 0
      ENDIF
 ENDFOR
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION Reset
 PARAMETER cfIeld
 PRIVATE ni
 FOR ni = 1 TO 9
      REPLACE (cfIeld+STR(ni, 1)) WITH 0
 ENDFOR
 RETURN .T.
ENDFUNC
*
FUNCTION fSet
 PARAMETER cfIeld
 PRIVATE ni
 PRIVATE cm
 FOR ni = 1 TO 9
      cm = "m."+SUBSTR(cfIeld, AT(".", cfIeld)+1)+STR(ni, 1)
      Replace (cField + Str(nI, 1)) With &cM
 ENDFOR
 RETURN .T.
ENDFUNC
*
FUNCTION HistoryManagerFinancial
 PARAMETER ddAte
 PRIVATE laVatcode, oManagerYesterday
 DIMENSION laVatcode[10]
 WAIT WINDOW NOWAIT GetLangText("MANAGER","TXT_FINANCIAL")+DTOC(ddAte)
 SELECT maNager
 SCATTER FIELDS mg_gstldg, mg_gcldg, mg_dldg, mg_cldg BLANK NAME oManagerYesterday
 IF (SEEK(DTOS(ddAte)))
      SKIP -1
      IF ( .NOT. BOF())
           SCATTER MEMVAR
           SCATTER FIELDS mg_gstldg, mg_gcldg, mg_dldg, mg_cldg NAME oManagerYesterday
           IF ( .NOT. SEEK(DTOS(ddAte)))
                APPEND BLANK
                REPLACE maNager.mg_date WITH ddAte
           ENDIF
           IF  .NOT. neWperiod(ddAte)
                = fsEt("Manager.Mg_MonG")
                = fsEt("Manager.Mg_MonP")
                = fsEt("Manager.Mg_MVAT")
                REPLACE maNager.mg_pdoutm WITH M.mg_pdoutm,  ;
                        maNager.mg_internm WITH M.mg_internm,  ;
                        maNager.mg_gcertm WITH M.mg_gcertm
           ENDIF
           IF  .NOT. neWyear(ddAte)
                = fsEt("Manager.Mg_YeaG")
                = fsEt("Manager.Mg_YeaP")
                = fsEt("Manager.Mg_YVAT")
                REPLACE maNager.mg_pdouty WITH M.mg_pdouty,  ;
                        maNager.mg_interny WITH M.mg_interny,  ;
                        maNager.mg_gcerty WITH M.mg_gcerty
           ENDIF
      ENDIF
 ENDIF
 laVatcode[1] = .F.
 FOR ni = 1 TO 9
      laVatcode[ni+1] = dbLookup("PickList","TAG3","VATGROUP  "+STR(ni,  ;
               3),"Found()")
 ENDFOR
 nsElect = SELECT()
 MNFinancialDataGet(ddAte) && Creates curposts cursor!
 SELECT arTicle
 SET ORDER TO 1
 SELECT paYmetho
 SET ORDER TO 1
 SELECT curPosts
 SET RELATION TO hp_artinum INTO arTicle
 SET RELATION ADDITIVE TO hp_paynum INTO paYmetho
 SCAN ALL
      IF ( .NOT. curPosts.hp_cancel .AND. (EMPTY(curPosts.hp_ratecod)  ;
         .OR. ( .NOT. EMPTY(curPosts.hp_ratecod) .AND. curPosts.hp_split)))
           IF (curPosts.hp_reserid>0)
                IF (curPosts.hp_paynum<>0)
                     IF  .NOT. INLIST(curPosts.hp_reserid, -2, -1, 0.200,  ;
                         0.300)
                          SELECT maNager
                          cm = "Manager.Mg_DayP"+ ;
                               STR(MAX(paYmetho.pm_paytyp, 1), 1)
                          Replace &cM With Eval(cM) - curPosts.Hp_Amount
                          cm = "Manager.Mg_MonP"+ ;
                               STR(MAX(paYmetho.pm_paytyp, 1), 1)
                          Replace &cM With Eval(cM) - curPosts.Hp_Amount
                          cm = "Manager.Mg_YeaP"+ ;
                               STR(MAX(paYmetho.pm_paytyp, 1), 1)
                          Replace &cM With Eval(cM) - curPosts.Hp_Amount
                     ENDIF
                ELSE
                     DO CASE
                          CASE arTicle.ar_artityp=2
                               SELECT maNager
                               REPLACE maNager.mg_pdoutd WITH  ;
                                       maNager.mg_pdoutd+ ;
                                       curPosts.hp_amount,  ;
                                       maNager.mg_pdoutm WITH  ;
                                       maNager.mg_pdoutm+ ;
                                       curPosts.hp_amount,  ;
                                       maNager.mg_pdouty WITH  ;
                                       maNager.mg_pdouty+curPosts.hp_amount
                          CASE arTicle.ar_artityp=3
                               SELECT maNager
                               REPLACE maNager.mg_internd WITH  ;
                                       maNager.mg_internd+ ;
                                       curPosts.hp_amount,  ;
                                       maNager.mg_internm WITH  ;
                                       maNager.mg_internm+ ;
                                       curPosts.hp_amount,  ;
                                       maNager.mg_interny WITH  ;
                                       maNager.mg_interny+curPosts.hp_amount
                          CASE arTicle.ar_artityp=4
                               SELECT maNager
                               REPLACE maNager.mg_gcertd WITH  ;
                                       maNager.mg_gcertd+ ;
                                       curPosts.hp_amount,  ;
                                       maNager.mg_gcertm WITH  ;
                                       maNager.mg_gcertm+ ;
                                       curPosts.hp_amount,  ;
                                       maNager.mg_gcerty WITH  ;
                                       maNager.mg_gcerty+curPosts.hp_amount
                          OTHERWISE
                               SELECT maNager
                               cm = "Manager.Mg_DayG"+ ;
                                    STR(MAX(arTicle.ar_main, 1), 1)
                               Replace &cM With Eval(cM) + curPosts.Hp_Amount
                               cm = "Manager.Mg_MonG"+ ;
                                    STR(MAX(arTicle.ar_main, 1), 1)
                               Replace &cM With Eval(cM) + curPosts.Hp_Amount
                               cm = "Manager.Mg_YeaG"+ ;
                                    STR(MAX(arTicle.ar_main, 1), 1)
                               Replace &cM With Eval(cM) + curPosts.Hp_Amount
                               FOR ni = 1 TO 9
                                    IF (laVatcode(ni+1))
                                         cn = "curPosts.Hp_Vat"+STR(ni, 1)
                                         cm = "Manager.Mg_DVAT"+ ;
                                          STR(MAX(arTicle.ar_main, 1), 1)
                                         Replace &cM With Eval(cM) + Eval(cN)
                                         cm = "Manager.Mg_MVAT"+ ;
                                          STR(MAX(arTicle.ar_main, 1), 1)
                                         Replace &cM With Eval(cM) + Eval(cN)
                                         cm = "Manager.Mg_YVAT"+ ;
                                          STR(MAX(arTicle.ar_main, 1), 1)
                                         Replace &cM With Eval(cM) + Eval(cN)
                                    ENDIF
                               ENDFOR
                     ENDCASE
                ENDIF
           ENDIF
      ENDIF
 ENDSCAN
 ntOtdaygroup = 0
 ntOtdaypay = 0
 ntOtdayvat = 0
 FOR ni = 1 TO 9
      cmAcro = "Manager.Mg_DayG"+STR(ni, 1)
      nTotDayGroup = nTotDayGroup + &cMacro
      cmAcro = "Manager.Mg_DayP"+STR(ni, 1)
      nTotDayPay = nTotDayPay + &cMacro
      cmAcro = "Manager.Mg_DVAT"+STR(ni, 1)
      nTotDayVat = nTotDayVat + &cMacro
 ENDFOR
 SELECT maNager
 SCATTER FIELDS mg_gstldg, mg_gcldg, mg_dldg, mg_dldgdeb, mg_dldgcrd, mg_cldg, mg_cldgdeb, mg_cldgcrd BLANK MEMVAR
 M.mg_gstldg = oManagerYesterday.mg_gstldg + ntOtdaygroup + IIF(paRam.pa_exclvat, ntOtdayvat, 0) + maNager.mg_pdoutd + maNager.mg_internd + maNager.mg_gcertd - ntOtdaypay
 M.mg_gcldg = oManagerYesterday.mg_gcldg + maNager.mg_gcertd - maNager.mg_dayp7
 = maNagerdeposit(ddAte)
 = maNagerar(ddAte)
 GATHER MEMVAR FIELDS mg_gstldg, mg_gcldg, mg_dldg, mg_dldgdeb, mg_dldgcrd, mg_cldg, mg_cldgdeb, mg_cldgcrd
 SET RELATION TO
 SET ORDER IN hiStpost TO 1
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION ManagerDeposit
 PARAMETER ddAte
 LOCAL oEnvironment, ncRedit, ntRansfer

 IF _screen.DP
      ddAte = EVL(ddAte,sySdate())
      oEnvironment = SetEnvironment("deposit")
      IF USED("deposit")
           SELECT deposit
           SET ORDER TO
           SUM dp_credit TO ncRedit FOR dp_sysdate = ddAte
           SUM dp_credit TO ntRansfer FOR dp_posted = ddAte
           M.mg_dldg = oManagerYesterday.mg_dldg + ncRedit - ntRansfer
           M.mg_dldgdeb = ntRansfer
           M.mg_dldgcrd = ncRedit
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION ManagerAr
 PARAMETER ddAte
 LOCAL oEnvironment, ncRedit, ndEbit

 IF _screen.DV
      ddAte = EVL(ddAte,sySdate())
      oEnvironment = SetEnvironment("arpost")
      IF USED("arpost")
           SELECT arpost
           SET ORDER TO
           SUM ap_debit, ap_credit TO ndEbit, ncRedit FOR ap_sysdate = ddAte AND NOT ap_hiden
           M.mg_cldg = oManagerYesterday.mg_cldg + ndEbit - ncRedit
           M.mg_cldgdeb = ndEbit
           M.mg_cldgcrd = ncRedit
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION HistoryManagerOccupancy
 LPARAMETERS lp_dStartDate
 PRIVATE p_dStartDate, p_lAdd
 p_dStartDate = lp_dStartDate
 p_lAdd = .T.     && Add values in RecalcField()
 LOCAL l_nSelect, l_nRoomsAvailable, l_nBedsAvailable
 LOCAL l_lCloseOutOfOrd, l_lCloseHOutOfOr, l_lCloseOutOfSer, l_lCloseHOutOfSr
 l_nSelect = SELECT()
 l_nRoomsAvailable = 0
 l_nBedsAvailable = 0
 SELECT room
 SET RELATION TO rm_roomtyp INTO roomtype
 SCAN FOR roomtype.rt_group==1 AND roomtype.rt_vwsum
      l_nRoomsAvailable = l_nRoomsAvailable + 1
      l_nBedsAvailable = l_nBedsAvailable + rm_beds
 ENDSCAN
 SET RELATION TO
 SELECT manager
 SCAN FOR BETWEEN(DTOS(mg_date),DTOS(p_dStartDate),DTOS(g_sysdate-1))
      IF HotelClosed(manager.mg_date)
           REPLACE mg_roomavl WITH 0 IN manager
           REPLACE mg_bedavl WITH 0 IN manager
      ELSE
           IF EMPTY(manager.mg_roomavl)
                REPLACE mg_roomavl WITH l_nRoomsAvailable IN manager
           ENDIF
           IF EMPTY(manager.mg_bedavl)
                REPLACE mg_bedavl WITH l_nBedsAvailable IN manager
           ENDIF
      ENDIF
 ENDSCAN
 SELECT mg_date FROM manager ;
      WHERE BETWEEN(DTOS(mg_date), DTOS(p_dStartDate), DTOS(g_sysdate-1)) AND ;
      (NOT EMPTY(mg_roomooo) OR NOT EMPTY(mg_bedooo)) ;
      ORDER BY mg_date INTO CURSOR curManOOO
 INDEX ON mg_date TAG tag1
 IF NOT USED("outoford")
      l_lCloseOutOfOrd = .T.
 ENDIF
 IF NOT USED("houtofor")
      l_lCloseHOutOfOr = .T.
 ENDIF
 SELECT oo_roomnum, oo_fromdat, oo_todat, rm_beds FROM houtofor ;
           LEFT JOIN room ON oo_roomnum = rm_roomnum ;
           LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
           WHERE rt_group = 1 AND rt_vwsum INTO CURSOR curHOutofor
 SELECT oo_roomnum, oo_fromdat, oo_todat, rm_beds FROM outoford ;
           LEFT JOIN room ON oo_roomnum = rm_roomnum ;
           LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
           WHERE rt_group = 1 AND rt_vwsum INTO CURSOR curOutoford READWRITE
 APPEND FROM DBF("curHOutofor")
 USE IN curHOutofor
 IF l_lCloseHOutOfOr
      USE IN houtofor
 ENDIF
 IF l_lCloseOutOfOrd
      USE IN outoford
 ENDIF
 IF NOT USED("outofser")
      l_lCloseOutOfSer = .T.
 ENDIF
 IF NOT USED("houtofsr")
      l_lCloseHOutOfSr = .T.
 ENDIF
 SELECT os_roomnum, os_fromdat, os_todat, rm_beds FROM houtofsr ;
           LEFT JOIN room ON os_roomnum = rm_roomnum ;
           LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
           WHERE rt_group = 1 AND rt_vwsum INTO CURSOR curHOutofsr
 SELECT os_roomnum, os_fromdat, os_todat, rm_beds FROM outofser ;
           LEFT JOIN room ON os_roomnum = rm_roomnum ;
           LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
           WHERE rt_group = 1 AND rt_vwsum INTO CURSOR curOutofser READWRITE
 APPEND FROM DBF("curHOutofsr")
 USE IN curHOutofsr
 IF l_lCloseHOutOfSr
      USE IN houtofsr
 ENDIF
 IF l_lCloseOutOfSer
      USE IN outofser
 ENDIF
 LOCAL ARRAY l_aTasks(5,2)
 l_aTasks(1,1) = RECCOUNT("curOutOfOrd")
 l_aTasks(1,2) = GetLangText("MANAGER","TXT_OUTOFORDOCCRBLD")+"..."
 l_aTasks(2,1) = RECCOUNT("curOutOfSer")
 l_aTasks(2,2) = GetLangText("MANAGER","TXT_OUTOFSEROCCRBLD")+"..."
 l_aTasks(3,1) = RECCOUNT("reservat")
 l_aTasks(3,2) = GetLangText("MANAGER","TXT_RESERVATOCCRBLD")+"..."
 l_aTasks(4,1) = RECCOUNT("histres")
 l_aTasks(4,2) = GetLangText("MANAGER","TXT_HISTRESOCCRBLD")+"..."
 l_aTasks(5,1) = RECCOUNT("sharing")
 l_aTasks(5,2) = GetLangText("MANAGER","TXT_SHARINGOCCRBLD")+"..."
 DO FORM forms\ProgressBar NAME ProgressBar WITH GetLangText("MANAGER","TXT_OCCRBLD"), l_aTasks
 = RecalcManagerOutOfOrder()
 = RecalcManagerOutOfService()
 = RecalcManagerReservationOccupancy()
 = RecalcManagerHistReservationOccupancy()
 = RecalcManagerSharingOccupancy()
 ProgressBar.Complete()
 WAIT WINDOW "Processing cumulative data..." NOWAIT
 = RecalcCumulativeFields()
 WAIT CLEAR
 SELECT (l_nSelect)
ENDFUNC
*
PROCEDURE RecalcManagerOutOfOrder
 LOCAL l_nAlias, l_dDate
 l_nAlias = SELECT()
 SELECT curOutoford
 SCAN
      ProgressBar.Update(RECNO(),1)
      l_dDate = oo_fromdat
      DO WHILE l_dDate < oo_todat
           IF NOT SEEK(l_dDate,"curManOOO","tag1")
                = RecalcField("mg_roomooo",1,l_dDate)
                = RecalcField("mg_bedooo",rm_beds,l_dDate)
           ENDIF
           l_dDate = l_dDate + 1
      ENDDO
 ENDSCAN
 USE IN curOutoford
 USE IN curManOOO
 SELECT (l_nAlias)
ENDPROC
*
PROCEDURE RecalcManagerOutOfService
 LOCAL l_nAlias, l_dDate
 l_nAlias = SELECT()
 SELECT curOutofser
 SCAN
      ProgressBar.Update(RECNO(),2)
      l_dDate = os_fromdat
      DO WHILE l_dDate < os_todat
           = RecalcField("mg_roomoos",1,l_dDate)
           = RecalcField("mg_bedoos",rm_beds,l_dDate)
           l_dDate = l_dDate + 1
      ENDDO
 ENDSCAN
 USE IN curOutofser
 SELECT (l_nAlias)
ENDPROC
*
PROCEDURE RecalcManagerReservationOccupancy
 LOCAL l_nAlias, l_cOrder, l_lComplim, l_nMultiplier, l_dDate, l_lGetResState
 LOCAL l_oResCurrent, l_oResArrival, l_oResDeparture, l_oResNext
 LOCAL l_lCurrStandard, l_lStandardInArrival, l_lStandardInDeparture, l_lPreviousStandard
 LOCAL l_nCurrPersons, l_nArrPersons, l_nDepPersons, l_nPreviousPersons
 LOCAL l_lCurrSharing, l_lSharingArr, l_lSharingDep, l_lPreviousSharing
 l_nAlias = SELECT()
 SELECT reservat
 l_cOrder = ORDER()
 SET ORDER TO
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
      l_lStandardInArrival = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
      IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(reservat.rs_arrdate),"resrate","tag2")
           l_nArrPersons = resrate.rr_adults+resrate.rr_childs+resrate.rr_childs2+resrate.rr_childs3
      ELSE
           l_nArrPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
      ENDIF
      IF l_lStandardInArrival AND NOT EMPTY(rs_created)
           = RecalcField("mg_resnew",rs_rooms,rs_created)
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
           l_lStandardInDeparture = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
           IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(MAX(reservat.rs_arrdate,reservat.rs_depdate-1)),"resrate","tag2")
                l_nDepPersons = resrate.rr_adults+resrate.rr_childs+resrate.rr_childs2+resrate.rr_childs3
           ELSE
                l_nDepPersons = reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
           ENDIF
           IF l_lStandardInArrival AND NOT l_lSharingArr
                = RecalcField("mg_arrival",rs_rooms,rs_arrdate-1)
           ENDIF
           IF l_lStandardInDeparture AND NOT l_lSharingDep
                = RecalcField("mg_departu",rs_rooms,rs_depdate-1)
           ENDIF
      ENDIF

      DO CASE
           CASE l_lStandardInArrival AND INLIST(rs_status, "CXL", "NS") AND INLIST(reServat.rs_cxlstat, "OPT", "LST", "TEN")
                IF reServat.rs_cxlstat = "TEN"
                     = RecalcField("mg_tencxl",rs_rooms,rs_cxldate)
                ELSE
                     = RecalcField("mg_optcxl",rs_rooms,rs_cxldate)
                ENDIF
           CASE l_lStandardInArrival AND (rs_status = "CXL")
                = RecalcField("mg_rescxl",rs_rooms,rs_cxldate)
           CASE l_lStandardInArrival AND (rs_status = "NS")
                = RecalcField("mg_resns",rs_rooms,rs_cxldate)
           CASE (rs_arrdate < g_sysdate) AND INLIST(rs_status, "IN", "OUT")
                IF l_lStandardInArrival
                     IF NOT l_lSharingArr
                          = RecalcField("mg_roomarr",rs_rooms,rs_arrdate)
                     ENDIF
                     = RecalcField("mg_persarr",l_nArrPersons,rs_arrdate)
                ENDIF
                IF l_lStandardInDeparture
                     IF NOT l_lSharingDep
                          = RecalcField("mg_roomdep",rs_rooms,rs_depdate)
                     ENDIF
                     = RecalcField("mg_persdep",l_nDepPersons,rs_depdate)
                ENDIF
                IF rs_arrdate = rs_depdate
                     IF l_lStandardInDeparture
                          IF rs_status = "OUT"
                               IF NOT l_lSharingDep
                                    = RecalcField("mg_rmduse",rs_rooms,rs_depdate)
                               ENDIF
                               = RecalcField("mg_prduse",l_nDepPersons,rs_depdate)
                          ELSE
                               * Checked reservation would be proccessed in audit
                          ENDIF
                     ENDIF
                ELSE
                     l_lPreviousStandard = l_lStandardInArrival
                     l_nPreviousPersons = l_nArrPersons
                     l_lPreviousSharing = l_lSharingArr
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
                                    = RecalcField("mg_roomocc",rs_rooms*l_nMultiplier,l_dDate)
                               ENDIF
                               = RecalcField("mg_bedocc",l_nCurrPersons,l_dDate)
                               IF rs_complim
                                    IF NOT l_lCurrSharing
                                         = RecalcField("mg_comprmd",rs_rooms*l_nMultiplier,l_dDate)
                                    ENDIF
                                    = RecalcField("mg_compprd",l_nCurrPersons,l_dDate)
                               ENDIF
                          ENDIF
                          IF NOT l_lPreviousStandard AND l_lCurrStandard
                          * Rellocation from non standard room to standard (new arrival rooms)
                               IF NOT l_lCurrSharing
                                    = RecalcField("mg_roomarr",rs_rooms,l_dDate)
                               ENDIF
                               = RecalcField("mg_persarr",l_nCurrPersons,l_dDate)
                          ENDIF
                          IF l_lPreviousStandard AND NOT l_lCurrStandard
                          * Rellocation from standard room to non standard (new departure rooms)
                               IF NOT l_lPreviousSharing
                                    = RecalcField("mg_roomdep",rs_rooms,l_dDate)
                               ENDIF
                               = RecalcField("mg_persdep",l_nPreviousPersons,l_dDate)
                          ENDIF
                          l_lPreviousStandard = l_lCurrStandard
                          l_nPreviousPersons = l_nCurrPersons
                          l_lPreviousSharing = l_lCurrSharing
                          l_dDate = l_dDate + 1
                     ENDDO
                ENDIF
      ENDCASE
 ENDSCAN
 SET ORDER TO l_cOrder
 SELECT (l_nAlias)
ENDPROC
*
PROCEDURE RecalcManagerOneHistReservationOccupancy
 LOCAL l_nMultiplier, l_dDate, l_lGetResState
 LOCAL l_oResCurrent, l_oResArrival, l_oResDeparture, l_oResNext
 LOCAL l_lCurrStandard, l_lStandardInArrival, l_lStandardInDeparture, l_lPreviousStandard
 LOCAL l_nCurrPersons, l_nArrPersons, l_nDepPersons, l_nPreviousPersons
 LOCAL l_lCurrSharing, l_lSharingArr, l_lSharingDep, l_lPreviousSharing

 * Taking reservation state for arrival date.
 =SEEK(histres.hr_rsid,"hresext","tag3")
 RiGetRoom(histres.hr_reserid, histres.hr_arrdate, @l_oResArrival, .NULL., "hresroom")
 l_lSharingArr = NOT (ISNULL(l_oResArrival) OR EMPTY(l_oResArrival.ri_shareid))
 IF ISNULL(l_oResArrival)
      = SEEK(histres.hr_roomtyp,"roomtype","tag1")
 ELSE
      = SEEK(l_oResArrival.ri_roomtyp,"roomtype","tag1")
 ENDIF
 l_lStandardInArrival = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
 IF SEEK(STR(histres.hr_reserid,12,3)+DTOS(histres.hr_arrdate),"hresrate","tag2")
      l_nArrPersons = hresrate.rr_adults+hresrate.rr_childs+hresrate.rr_childs2+hresrate.rr_childs3
 ELSE
      l_nArrPersons = histres.hr_adults+histres.hr_childs+histres.hr_childs2+histres.hr_childs3
 ENDIF
 IF l_lStandardInArrival AND NOT EMPTY(hr_created)
      = RecalcField("mg_resnew",hr_rooms,hr_created)
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
      l_lStandardInDeparture = INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum
      IF SEEK(STR(histres.hr_reserid,12,3)+DTOS(MAX(histres.hr_arrdate,histres.hr_depdate-1)),"hresrate","tag2")
           l_nDepPersons = hresrate.rr_adults+hresrate.rr_childs+hresrate.rr_childs2+hresrate.rr_childs3
      ELSE
           l_nDepPersons = histres.hr_adults+histres.hr_childs+histres.hr_childs2+histres.hr_childs3
      ENDIF
 ENDIF

 DO CASE
      CASE l_lStandardInArrival AND INLIST(hr_status, "CXL", "NS") AND INLIST(hresext.rs_cxlstat, "OPT", "LST", "TEN")
           IF hresext.rs_cxlstat = "TEN"
                = RecalcField("mg_tencxl",hr_rooms,hr_cxldate)
           ELSE
                = RecalcField("mg_optcxl",hr_rooms,hr_cxldate)
           ENDIF
      CASE l_lStandardInArrival AND (hr_status = "CXL")
           = RecalcField("mg_rescxl",hr_rooms,hr_cxldate)
      CASE l_lStandardInArrival AND (hr_status = "NS")
           = RecalcField("mg_resns",hr_rooms,hr_cxldate)
      CASE INLIST(hr_status, "IN", "OUT")
           IF l_lStandardInArrival
                IF NOT l_lSharingArr
                     = RecalcField("mg_roomarr",hr_rooms,hr_arrdate)
                     = RecalcField("mg_arrival",hr_rooms,hr_arrdate-1)
                ENDIF
                = RecalcField("mg_persarr",l_nArrPersons,hr_arrdate)
           ENDIF
           IF l_lStandardInDeparture
                IF NOT l_lSharingDep
                     = RecalcField("mg_roomdep",hr_rooms,hr_depdate)
                     = RecalcField("mg_departu",hr_rooms,hr_depdate-1)
                ENDIF
                = RecalcField("mg_persdep",l_nDepPersons,hr_depdate)
           ENDIF
           IF hr_arrdate = hr_depdate
                IF l_lStandardInDeparture
                     IF hr_status = "OUT"
                          IF NOT l_lSharingDep
                               = RecalcField("mg_rmduse",hr_rooms,hr_depdate)
                          ENDIF
                          = RecalcField("mg_prduse",l_nDepPersons,hr_depdate)
                     ELSE
                          * Checked reservation would be proccessed in audit
                     ENDIF
                ENDIF
           ELSE
                l_lPreviousStandard = l_lStandardInArrival
                l_nPreviousPersons = l_nArrPersons
                l_lPreviousSharing = l_lSharingArr
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
                               = RecalcField("mg_roomocc",hr_rooms*l_nMultiplier,l_dDate)
                          ENDIF
                          = RecalcField("mg_bedocc",l_nCurrPersons,l_dDate)
                          IF hr_complim
                               IF NOT l_lCurrSharing
                                    = RecalcField("mg_comprmd",hr_rooms*l_nMultiplier,l_dDate)
                               ENDIF
                               = RecalcField("mg_compprd",l_nCurrPersons,l_dDate)
                          ENDIF
                     ENDIF
                     IF NOT l_lPreviousStandard AND l_lCurrStandard
                     * Rellocation from non standard room to standard (new arrival rooms)
                          IF NOT l_lCurrSharing
                               = RecalcField("mg_roomarr",hr_rooms,l_dDate)
                          ENDIF
                          = RecalcField("mg_persarr",l_nCurrPersons,l_dDate)
                     ENDIF
                     IF l_lPreviousStandard AND NOT l_lCurrStandard
                     * Rellocation from standard room to non standard (new departure rooms)
                          IF NOT l_lPreviousSharing
                               = RecalcField("mg_roomdep",hr_rooms,l_dDate)
                          ENDIF
                          = RecalcField("mg_persdep",l_nPreviousPersons,l_dDate)
                     ENDIF
                     l_lPreviousStandard = l_lCurrStandard
                     l_nPreviousPersons = l_nCurrPersons
                     l_lPreviousSharing = l_lCurrSharing
                     l_dDate = l_dDate + 1
                ENDDO
           ENDIF
 ENDCASE
ENDPROC
*
PROCEDURE RecalcManagerHistReservationOccupancy
 LOCAL l_nAlias, l_cOrder
 l_nAlias = SELECT()
 SELECT histres
 l_cOrder = ORDER()
 SET ORDER TO
 SCAN FOR (hr_depdate > p_dStartDate) AND (hr_reserid > 1) AND NOT SEEK(hr_reserid,"reservat","tag1")
      ProgressBar.Update(RECNO(),4)
      * Taking reservation state for arrival date.
      RecalcManagerOneHistReservationOccupancy()
 ENDSCAN
 SET ORDER TO l_cOrder
 SELECT (l_nAlias)
ENDPROC
*
PROCEDURE RecalcManagerSharingOccupancy
 LOCAL l_nAlias, l_cOrder, l_nMultiplier, l_dDate, l_lIsArrival, l_lIsDeparture, l_lIsDayUse, l_lIsComplim
 l_nAlias = SELECT()
 SELECT sharing
 l_cOrder = ORDER()
 SET ORDER TO
 SET RELATION TO sd_roomtyp INTO roomtype
 SCAN FOR INLIST(sd_status, "IN", "OUT") AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsum ;
	 		AND NOT EMPTY(sd_lowdat)
      ProgressBar.Update(RECNO(),5)
      DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ARRIVAL", sd_lowdat
      IF l_lIsArrival
           RecalcField("mg_arrival",1,sd_lowdat-1)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ROOMARR", sd_lowdat
      IF l_lIsArrival
           RecalcField("mg_roomarr",1,sd_lowdat)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "DEPARTURE", sd_highdat+1
      IF l_lIsDeparture
           RecalcField("mg_departu",1,sd_highdat)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "ROOMDEP", sd_highdat+1
      IF l_lIsDeparture
           RecalcField("mg_roomdep",1,sd_highdat+1)
      ENDIF
      DO RiShareInterval IN ProcResRooms WITH l_lIsDayUse, sd_shareid, sd_lowdat, sd_highdat, "DAYUSE", sd_lowdat
      IF l_lIsDayUse
           IF sd_status = "OUT"
                RecalcField("mg_rmduse",1,sd_lowdat)
                RecalcField("mg_departu",1,sd_highdat-1)
                RecalcField("mg_roomdep",1,sd_highdat)
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
                RecalcField("mg_roomocc",l_nMultiplier,l_dDate)
                IF l_lIsComplim
                     RecalcField("mg_comprmd",l_nMultiplier,l_dDate)
                ENDIF
                l_dDate = l_dDate + 1
           ENDDO
      ENDIF
 ENDSCAN
 SET RELATION TO
 SET ORDER TO l_cOrder
 SELECT (l_nAlias)
ENDPROC
*
FUNCTION RecalcField
 LPARAMETERS lp_cField, lp_nValue, lp_dDate
 IF BETWEEN(lp_dDate,p_dStartDate, g_sysdate-1)
      IF SEEK(DTOS(lp_dDate),"manager","tag1")
           REPLACE &lp_cField WITH MAX(0, &lp_cField + lp_nValue*IIF(p_lAdd,1,-1)) IN manager
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION RecalcCumulativeFields
 LOCAL l_oYesterday, l_oToday, l_nOrder
 SELECT manager
 l_nOrder = ORDER()
 SET ORDER TO
 IF SEEK(DTOS(p_dStartDate-1),"manager","tag1")
      SCATTER MEMO NAME l_oYesterday
 ELSE
      SCATTER MEMO NAME l_oYesterday BLANK
 ENDIF
 SCAN FOR DTOS(mg_date) >= DTOS(p_dStartDate)
       SCATTER MEMO NAME l_oToday
       IF neWperiod(mg_date)
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
      IF neWyear(mg_date)
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
 SET ORDER TO l_nOrder
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
PROCEDURE ManagerRevUpdate
LPARAMETERS lp_dForDate
LOCAL l_oEnvironment, l_nRecno, l_oBefore, l_oAfter, l_lVatsDefined, l_nArtiNum, l_nVatValue, l_cField
LOCAL ARRAY l_aVats(1)
l_oEnvironment = SetEnvironment("manager, post, histpost, picklist, article, paymetho", "tag1")
IF NOT SEEK(DTOS(lp_dForDate), "manager", "Tag1")
     RETURN .F.
ENDIF
SELECT manager
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
     IF ps_paynum <> 0
          IF NOT INLIST(ps_reserid, -2, -1, 0.200, 0.300)
               l_cField = "l_oAfter.mg_dayp" + STR(MAX(pm_paytyp, 1), 1)
               &l_cField = &l_cField - ps_amount
          ENDIF
     ELSE
          DO CASE
               CASE ar_artityp = 2
                    l_oAfter.mg_pdoutd = l_oAfter.mg_pdoutd + ps_amount
               CASE ar_artityp = 3
                    l_oAfter.mg_internd = l_oAfter.mg_internd + ps_amount
               CASE ar_artityp = 4
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
     IF hp_paynum <> 0
          IF NOT INLIST(hp_reserid, -2, -1, 0.200, 0.300)
               l_cField = "l_oAfter.mg_dayp" + STR(MAX(pm_paytyp, 1), 1)
               &l_cField = &l_cField - hp_amount
          ENDIF
     ELSE
          DO CASE
               CASE ar_artityp = 2
                    l_oAfter.mg_pdoutd = l_oAfter.mg_pdoutd + hp_amount
               CASE ar_artityp = 3
                    l_oAfter.mg_internd = l_oAfter.mg_internd + hp_amount
               CASE ar_artityp = 4
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
SELECT manager
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
     FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(param.pa_sysdate - 1)) ;
     WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) AND MONTH(mg_date) = MONTH(l_oBefore.mg_date) IN manager
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
     FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(param.pa_sysdate - 1)) ;
     WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) IN manager
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
     REST FOR DTOS(mg_date) < DTOS(param.pa_sysdate) IN manager
ENDPROC
*
PROCEDURE RemoveReservation
LPARAMETERS lp_nReserId
 LOCAL l_oEnvironment, l_oBefore, l_oAfter, l_dCreated, l_dCanceled
 PRIVATE p_dStartDate, p_lAdd
 l_oEnvironment = SetEnvironment("manager, histres, hresroom, hresrate, roomtype", "tag1")
 IF DLocate("histres", "hr_reserid = " + SqlCnv(lp_nReserId)) AND histres.hr_reserid > 1
      =SEEK(histres.hr_rsid,"hresext","tag3")
      p_lAdd = .F.     && Remove values in RecalcField()
      l_nAlias = SELECT()
      l_dCreated = IIF(EMPTY(histres.hr_created), histres.hr_arrdate, histres.hr_created)
      l_dCanceled = IIF(EMPTY(histres.hr_cxldate), histres.hr_arrdate, histres.hr_cxldate)
      p_dStartDate = MIN(histres.hr_arrdate-1, l_dCreated, l_dCanceled)
      SELECT * FROM manager WHERE INLIST(DTOS(mg_date),DTOS(l_dCreated),DTOS(l_dCanceled)) OR ;
           BETWEEN(DTOS(mg_date),DTOS(histres.hr_arrdate),DTOS(histres.hr_depdate)) ;
           ORDER BY mg_date INTO CURSOR curManager     && Backup previous state
      SELECT histres
      RecalcManagerOneHistReservationOccupancy()
      * Update cumulative values
      SELECT curManager
      SCAN
           SCATTER NAME l_oBefore
           = SEEK(DTOS(l_oBefore.mg_date),"manager","tag1")
           SELECT manager
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
                FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(param.pa_sysdate - 1)) ;
                WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) AND MONTH(mg_date) = MONTH(l_oBefore.mg_date) IN manager
           = SEEK(DTOS(l_oBefore.mg_date),"manager","tag1")
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
                FOR BETWEEN(DTOS(mg_date), DTOS(l_oBefore.mg_date), DTOS(param.pa_sysdate - 1)) ;
                WHILE YEAR(mg_date) = YEAR(l_oBefore.mg_date) IN manager
           SELECT curManager
      ENDSCAN
      USE IN curManager
 ENDIF
ENDPROC
*
PROCEDURE MNFinancialDataGet
 LPARAMETERS lp_dDate
 LOCAL l_lOnlyForClosedBills
 l_lOnlyForClosedBills = _screen.oGlobal.lManagerRevenueOnlyForClosedBills
 IF l_lOnlyForClosedBills
      SELECT * FROM histpost WHERE 0=1 INTO CURSOR curPosts READWRITE
      SELECT * FROM histpost ;
                WHERE hp_date = lp_dDate AND ;
                ((NOT (hp_window>0 AND hp_reserid > 1) AND ; && Reservation bills
                NOT (hp_reserid = 0.100 AND NOT EMPTY(hp_billnum)) AND ;&& PasserBy
                hp_artinum <> 250) OR ; 
                (hp_artinum = 250 AND hp_reserid = 0.100 AND hp_userid = 'POS' AND hp_supplem = 'ARGUS T-POS')) ;
                INTO CURSOR curmg1 READWRITE
      SCAN FOR hp_artinum = 250 AND hp_reserid = 0.100 AND hp_userid = 'POS' AND hp_supplem = 'ARGUS T-POS'
           REPLACE hp_artinum WITH 270
      ENDSCAN
      SELECT * FROM billnum ;
                INNER JOIN histpost ON bn_billnum = hp_billnum ;
                WHERE bn_date = lp_dDate AND bn_status = "PCO" ;
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
                CAST(0 AS Numeric(12,3)) AS hp_reserid ;
                FROM billnum ;
                INNER JOIN postcxl ON bn_billnum = ps_billnum ;
                WHERE bn_cxldate = lp_dDate AND bn_date <> bn_cxldate AND bn_status = "CXL" ;
                INTO CURSOR curmg3 READWRITE
      IF _TALLY>0
           SCAN ALL
                REPLACE hp_reserid WITH dlookup("histres","hr_rsid = " + sqlcnv(hp_rsid),"hr_reserid")
           ENDSCAN
      ENDIF
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
                CAST(0 AS Numeric(12,3)) AS hp_reserid ;
                FROM billnum ;
                INNER JOIN postcxl ON bn_billnum = ps_billnum ;
                WHERE bn_date = lp_dDate AND bn_cxldate <> {} AND bn_date <> bn_cxldate AND bn_status = "CXL" ;
                INTO CURSOR curmg4 READWRITE
      IF _TALLY>0
           SCAN ALL
                REPLACE hp_reserid WITH dlookup("histres","hr_rsid = " + sqlcnv(hp_rsid),"hr_reserid")
           ENDSCAN
      ENDIF
      SELECT curPosts
      APPEND FROM DBF("curmg1")
      APPEND FROM DBF("curmg2")
      APPEND FROM DBF("curmg3")
      APPEND FROM DBF("curmg4")
      dclose("curmg1")
      dclose("curmg2")
      dclose("curmg3")
      dclose("curmg4")
 ELSE
      SELECT * FROM histpost WHERE hp_date = lp_dDate INTO CURSOR curPosts
 ENDIF
 
 RETURN .T.
 ENDPROC
*
***********
** TESTS **
***********
*
PROCEDURE MNTestForecast
PRIVATE p_oAudit
p_oAudit = CREATEOBJECT("cMNDummyAudit")
LOCAL l_cCur, l_cCurMan
l_cCurMan = "curmanager"
l_cCur = sqlcursor("SELECT * FROM manager WHERE 0=1")
SELECT * FROM (l_cCur) INTO CURSOR (l_cCurMan) READWRITE
dclose(l_cCur)
SELECT (l_cCurMan)
SCATTER BLANK MEMVAR
Forecast()
INSERT INTO (l_cCurMan) FROM MEMVAR
SELECT (l_cCurMan)
SCATTER BLANK MEMVAR
MNForecastOld()
INSERT INTO (l_cCurMan) FROM MEMVAR
ENDPROC
*
FUNCTION MNForecastOld
 PRIVATE nsElect
 nsElect = SELECT()
 p_oAudit.txtinfo(GetLangText("MANAGER","TXT_FORECAST"),1)
 SELECT avAilab
 IF (SEEK(DTOS(g_sysdate+1), "Availab"))
      p_oAudit.txtinfo(GetLangText("MANAGER","TXT_TOMORROW"),1)
      DO WHILE ( .NOT. EOF("Availab") .AND. avAilab.av_date==(g_sysdate+1))
           IF dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_Group")=1 AND ;
                   dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_vwsum")
                M.mg_maxtomo = M.mg_maxtomo+avAilab.av_avail-avAilab.av_ooservc
                M.mg_deftomo = M.mg_deftomo+avAilab.av_definit
                M.mg_opttomo = M.mg_opttomo+avAilab.av_option
                M.mg_tentomo = M.mg_tentomo+avAilab.av_tentat
                M.mg_alltomo = M.mg_alltomo+avAilab.av_allott+avAilab.av_altall
                M.mg_pictomo = M.mg_pictomo+avAilab.av_pick
                M.mg_waitomo = M.mg_waitomo+avAilab.av_waiting
           ENDIF
           SKIP 1 IN avAilab
      ENDDO
      p_oAudit.txtinfo(GetLangText("MANAGER","TXT_NEXTWEEK"),1)
      SEEK DTOS(g_sysdate+1)
      DO WHILE ( .NOT. EOF("Availab") .AND. avAilab.av_date<=(g_sysdate+7))
           IF dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_Group")=1 AND ;
                   dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_vwsum")
                M.mg_maxnext = M.mg_maxnext+avAilab.av_avail-avAilab.av_ooservc
                M.mg_defnext = M.mg_defnext+avAilab.av_definit
                M.mg_optnext = M.mg_optnext+avAilab.av_option
                M.mg_tennext = M.mg_tennext+avAilab.av_tentat
                M.mg_allnext = M.mg_allnext+avAilab.av_allott+avAilab.av_altall
                M.mg_picnext = M.mg_picnext+avAilab.av_pick
                M.mg_wainext = M.mg_wainext+avAilab.av_waiting
           ENDIF
           SKIP 1 IN avAilab
      ENDDO
      p_oAudit.txtinfo(GetLangText("MANAGER","TXT_ENDOFMONTH"),1)
      SEEK DTOS(g_sysdate+1)
      DO WHILE ( .NOT. EOF("Availab") .AND. MONTH(avAilab.av_date)= ;
         MONTH(g_sysdate))
           IF dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_Group")=1 AND ;
                   dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_vwsum")
                M.mg_maxendm = M.mg_maxendm+avAilab.av_avail-avAilab.av_ooservc
                M.mg_defendm = M.mg_defendm+avAilab.av_definit
                M.mg_optendm = M.mg_optendm+avAilab.av_option
                M.mg_tenendm = M.mg_tenendm+avAilab.av_tentat
                M.mg_allendm = M.mg_allendm+avAilab.av_allott+avAilab.av_altall
                M.mg_picendm = M.mg_picendm+avAilab.av_pick
                M.mg_waiendm = M.mg_waiendm+avAilab.av_waiting
           ENDIF
           SKIP 1 IN avAilab
      ENDDO
      p_oAudit.txtinfo(GetLangText("MANAGER","TXT_NEXT30DAYS"),1)
      SEEK DTOS(g_sysdate+1)
      DO WHILE ( .NOT. EOF("Availab") .AND. avAilab.av_date<=(g_sysdate+30))
           IF dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_Group")=1 AND ;
                   dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_vwsum")
                M.mg_max30da = M.mg_max30da+avAilab.av_avail-avAilab.av_ooservc
                M.mg_def30da = M.mg_def30da+avAilab.av_definit
                M.mg_opt30da = M.mg_opt30da+avAilab.av_option
                M.mg_ten30da = M.mg_ten30da+avAilab.av_tentat
                M.mg_all30da = M.mg_all30da+avAilab.av_allott+avAilab.av_altall
                M.mg_pic30da = M.mg_pic30da+avAilab.av_pick
                M.mg_wai30da = M.mg_wai30da+avAilab.av_waiting
           ENDIF
           SKIP 1 IN avAilab
      ENDDO
      p_oAudit.txtinfo(GetLangText("MANAGER","TXT_NEXT365DAYS"),1)
      SEEK DTOS(g_sysdate+1)
      DO WHILE ( .NOT. EOF("Availab") .AND. avAilab.av_date<=(g_sysdate+365))
           IF dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_Group")=1 AND ;
                   dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_vwsum")
                M.mg_max365d = M.mg_max365d+avAilab.av_avail-avAilab.av_ooservc
                M.mg_def365d = M.mg_def365d+avAilab.av_definit
                M.mg_opt365d = M.mg_opt365d+avAilab.av_option
                M.mg_ten365d = M.mg_ten365d+avAilab.av_tentat
                M.mg_all365d = M.mg_all365d+avAilab.av_allott+avAilab.av_altall
                M.mg_pic365d = M.mg_pic365d+avAilab.av_pick
                M.mg_wai365d = M.mg_wai365d+avAilab.av_waiting
           ENDIF
           SKIP 1 IN avAilab
      ENDDO
      p_oAudit.txtinfo(GetLangText("MANAGER","TXT_ENDOFTHEYEAR"),1)
      SEEK DTOS(g_sysdate+1)
      DO WHILE ( .NOT. EOF("Availab") .AND. MONTH(avAilab.av_date)<=12  ;
         .AND. YEAR(avAilab.av_date)==YEAR(g_sysdate))
           IF dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_Group")=1 AND ;
                   dbLookup("RoomType","Tag1",avAilab.av_roomtyp,"Rt_vwsum")
                M.mg_maxendy = M.mg_maxendy+avAilab.av_avail-avAilab.av_ooservc
                M.mg_defendy = M.mg_defendy+avAilab.av_definit
                M.mg_optendy = M.mg_optendy+avAilab.av_option
                M.mg_tenendy = M.mg_tenendy+avAilab.av_tentat
                M.mg_allendy = M.mg_allendy+avAilab.av_allott+avAilab.av_altall
                M.mg_picendy = M.mg_picendy+avAilab.av_pick
                M.mg_waiendy = M.mg_waiendy+avAilab.av_waiting
           ENDIF
           SKIP 1 IN avAilab
      ENDDO
 ENDIF
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
DEFINE CLASS cMNDummyAudit AS Custom
*
PROCEDURE txtinfo
LPARAMETERS lp_cText, lp_nNo
ENDPROC
*
ENDDEFINE