*
FUNCTION RSCheckIn
 PARAMETER nrSreserid, plGroup, pcMessage, plSilent
 PRIVATE nrEcord
 PRIVATE ncUrrentrecord
* PRIVATE ccUrrentarea
 PRIVATE liFccheckin
 PRIVATE nrMord
 LOCAL l_cRsChanges
 PRIVATE ncHeckinrec
 PRIVATE lcOntinue, daRrival, ddEparture, cmSg, lcAncel, cHeader
 LOCAL l_lShowInterfaceForm, l_lAddressIsVIP, l_lApartnerIsVIP
 LOCAL ARRAY LArray(2)
 l_lShowInterfaceForm = param.pa_keyifc AND param.pa_askcard
 ncHeckinrec = RECNO("Reservat")
 l_cRsChanges = ""
 pcMessage = ""
 cHeader = ""

 DO WHILE (.T.)
      IF (INLIST(reServat.rs_status, "CXL", "NS"))
           pcMessage = GetLangText("RESERV2","TA_ISCXL")+"!"
           EXIT
      ENDIF
      IF ( .NOT. EMPTY(reServat.rs_in))
           pcMessage = GetLangText("RESERV2","TA_ISIN")+"!"
           EXIT
      ENDIF
      IF (reServat.rs_arrdate<>sySdate())
           pcMessage = GetLangText("RESERV2","TA_ARRTODAY")+"!"
           EXIT
      ENDIF
      IF (reServat.rs_rooms>1)
           pcMessage = GetLangText("RESERV2","TA_SPLITFIRST")+"!"
           EXIT
      ENDIF
      IF EMPTY(reServat.rs_ratecod) 
           IF SEEK(reServat.rs_roomtyp,'roomtype','tag1')
                IF INLIST(roomtype.rt_group,1,2,4)
                     pcMessage = GetLangText("ROOMPLAN","T_NORATECODE")
                     EXIT
                ENDIF
           ENDIF
      ENDIF
      lcAncel = .F.
      DO dpChkin IN DP WITH reServat.rs_reserid, lcAncel
      IF lcAncel
           EXIT
      ENDIF
      =SEEK(reservat.rs_addrid,'address','tag1')
      l_lAddressIsVIP = adDress.ad_vip
      l_lApartnerIsVIP = (USED('apartner') AND reservat.rs_addrid = reservat.rs_compid AND ;
                NOT EMPTY(reservat.rs_apname) AND ;
                SEEK(reservat.rs_apid, 'apartner', 'tag3') AND ;
                apartner.ap_vip1)
      IF NOT plSilent AND (l_lAddressIsVIP OR l_lApartnerIsVIP)
           ?? CHR(7)
           = alErt(GetLangText("RESERV2","TXT_ISVIP"))
      ENDIF
      IF DLookup("resrooms", "(ri_reserid = reservat.rs_reserid) AND (ri_date > reservat.rs_arrdate) AND EMPTY(ri_roomnum)", "Found('resrooms')")
           pcMessage = GetLangText("RESERV2","TA_ASSIGN_RESROOMS")
           EXIT
      ENDIF
      IF EMPTY(reServat.rs_roomnum)
           pcMessage = GetLangText("RESERV2","TA_ASSIGN")+"!"
           IF NOT plSilent
                Alert(pcMessage)
                IF g_newversionactive
                    DO FORM forms\getroom
                ELSE
                    DO geTroom
                ENDIF
           ENDIF
           IF EMPTY(reServat.rs_roomnum)
                EXIT
           ENDIF
      ENDIF
      
      SELECT reServat
      nrEcord = RECNO()
      noRder = ORDER()
      crOomnumber = reServat.rs_roomnum
      ddEparture = reServat.rs_depdate
      daRrival = reServat.rs_arrdate
      SET ORDER TO 13
      IF SEEK(crOomnumber, "Reservat")
           LOCATE REST FOR reServat.rs_depdate>=daRrival .AND.  ;
                  reServat.rs_status = "IN" .AND. RECNO()<>nrEcord WHILE  ;
                  reServat.rs_roomnum==crOomnumber .AND.  ;
                  reServat.rs_arrdate<=ddEparture
           IF FOUND()
                lcOntinue = .F.
                IF NOT plSilent AND Param.pa_multioc
                     lcOntinue = (MESSAGEBOX(GetLangText("RESERVAT","TXT_ROOM_IS_ASSIGNED_TO") + " " + Reservat.rs_lname + chr(13) +;
                                      GetLangText("RESERVAT","TXT_FROM") + " " + DTOC(Reservat.rs_arrdate) + " " +;
                                      GetLangText("RESERVAT","TH_TO") + " " + DTOC(Reservat.rs_depdate) + chr(13) + chr(13) +;
                                      GetLangText("RESERVAT","TXT_CONT_AS_MULTIOC"), 52, GetLangText("RESERVAT","TXT_MULTIPLE_OCCUPATION")) = 6)
                ELSE
                     pcMessage = GetLangText("RESERVAT","TXT_NOTALLOWEDMULTIOC") + CHR(13) + CHR(13) + ;
                         GetLangText("RESERVAT","TXT_ROOM_IS_ASSIGNED_TO") + " " + Reservat.rs_lname + CHR(13) +;
                          GetLangText("RESERVAT","TXT_FROM") + " " + DTOC(Reservat.rs_arrdate) + " " +GetLangText("RESERVAT","TH_TO") + " " + DTOC(Reservat.rs_depdate)
                    cHeader = GetLangText("RESERVAT","TXT_MULTIPLE_OCCUPATION")
                ENDIF

*                IF  .NOT. EMPTY(reServat.rs_in) .AND. reServat.rs_depdate= ;
*                    daRrival
*                     IF paRam.pa_multioc
*                          = alErt(GetLangText("RESERV2","TXT_OLDNOTOUT")+"!")
*                          lcOntinue = .T.
*                     ELSE
*                          cmSg = GetLangText("RESERV2","TXT_OLDNOTOUT")+"!;;"+ ;
*                                 GetLangText("RESERV2","TXT_GOON")+"?"
*                          lcOntinue = yeSno(cmSg)
*                     ENDIF
*                ELSE
*                     cmSg = GetLangText("RESERV2","TA_NOTFREE")+"!;;"+ ;
*                            LTRIM(PROPER(TRIM(reServat.rs_company))+" "+ ;
*                            PROPER(TRIM(reServat.rs_lname)))+";"+ ;
*                            DTOC(reServat.rs_arrdate)+" "+ ;
*                            DTOC(reServat.rs_depdate)+"!"
*                     IF paRam.pa_dblbook
*                          cmSg = cmSg+";;"+GetLangText("RESERV2","TXT_GOON")+"?@2"
*                          lcOntinue = yeSno(cmSg)
*                     ELSE
*                          = alErt(cmSg)
*                          lcOntinue = .F.
*                     ENDIF
*                ENDIF
                IF lcOntinue
                     SELECT reServat
                     SET ORDER TO nOrder
                     GOTO nrEcord
                     ncUrrentrecord = RECNO("room")
                     l_cRsChanges = rsHistry(l_cRsChanges,"CHECKIN", "Room not free...")
                ELSE
                     SELECT reServat
                     SET ORDER TO nOrder
                     GOTO nrEcord
                     ncUrrentrecord = RECNO("Room")
                     EXIT
                ENDIF
           ENDIF
      ENDIF
      SELECT reServat
      SET ORDER TO nOrder
      GOTO nrEcord
      ncUrrentrecord = RECNO("Room")
      nrMord = ORDER("Room")
      SET ORDER IN "Room" TO 1
      IF (paRam.pa_rmstat)
           DO roOmstat IN Interfac
           ncUrrentrecord = RECNO("Room")
           IF (SEEK(reServat.rs_roomnum, "Room") .AND. roOm.rm_status<>"CLN")
                IF INLIST(roOm.rm_status, "OOO", "OOS")
                     IF NOT plSilent AND param.pa_oooover
                          IF NOT yeSno(GetLangText("RESERV2","TXT_CURRENTSTATUS")+" "+ ;
                                    roOm.rm_status+";;"+GetLangText("RESERV2","TXT_CHECKIN")+"?", ;
                                    IIF(roOm.rm_status="OOO", GetLangText("RESERVAT","TXT_ROOM_OUT_OF_ORDER"), ;
                                    GetLangText("OUTOFSER","TXT_TITLE")))
                               EXIT
                          ELSE
                               l_cRsChanges = rsHistry(l_cRsChanges,"CHECKIN", IIF(roOm.rm_status="OOO","Room is OUT OF ORDER", "Room is OUT OF SERVICE"))
                          ENDIF
                     ELSE
                         pcMessage = GetLangText("RESERV2","TXT_CURRENTSTATUS")+" "+ roOm.rm_status+CHR(10)+ ;
                              IIF(roOm.rm_status="OOO",GetLangText("RESERVAT","TXT_ROOM_OUT_OF_ORDER"), GetLangText("OUTOFSER","TXT_TITLE"))
                         EXIT
                     ENDIF
                ELSE
                     IF NOT plSilent AND INLIST(dblookup("roomtype","tag1",reservat.rs_roomtyp,"rt_group"),1,4)
                          IF NOT yeSno(GetLangText("RESERV2","TXT_CURRENTSTATUS")+" "+ ;
                                    roOm.rm_status+";;"+GetLangText("RESERV2","TXT_CHECKIN")+"?", ;
                                    GetLangText("RESERV2","TA_ISDIRTY"))
                               EXIT
                          ELSE
                               l_cRsChanges = rsHistry(l_cRsChanges,"CHECKIN", "Room not CLEAN")
                          ENDIF
                     ENDIF
                ENDIF
           ENDIF
      ENDIF
      LOCAL ARRAY l_aRooms(1)
      LOCAL l_nRoom
      LinkRoomtype(reservat.rs_roomnum, reservat.rs_roomtyp, @l_aRooms)
      FOR l_nRoom = 1 TO ALEN(l_aRooms,1)
           IF SEEK(l_aRooms(l_nRoom, 4), "Room")
                REPLACE room.rm_status WITH "DIR" IN room
           ENDIF
      ENDFOR
      SET ORDER IN "Room" TO nRmOrd
      GOTO ncUrrentrecord IN "Room"
      *ccUrrentarea = SELECT()
      SELECT reServat
      nrEsrec = RECNO("Reservat")
      nrEsord = ORDER("Reservat")
      IF (paRam.pa_postpos)
           crEsroom = reServat.rs_roomnum
           SET ORDER TO 6
           ctProom = " "
           ntProom = 0
           DIMENSION alTproom[10]
           STORE .F. TO alTproom
           IF (SEEK("1"+crEsroom))
                DO WHILE (reServat.rs_roomnum==crEsroom .AND.  ;
                   reServat.rs_in=="1" .AND.  .NOT. EOF("Reservat"))
                     IF (EMPTY(reServat.rs_out))
                          ntPposition = RAT("TOUCHPOSROOM:",  ;
                                        reServat.rs_changes)
                          IF (ntPposition>0)
                               ctProom = SUBSTR(reServat.rs_changes,  ;
                                ntPposition+13, 1)
                               ntProom = VAL(ctProom)+1
                               alTproom[ntProom] = .T.
                          ENDIF
                     ENDIF
                     SKIP 1 IN reServat
                ENDDO
                ntPcount = 1
                DO WHILE (ntPcount<=10)
                     IF ( .NOT. alTproom(ntPcount))
                          ctProom = STR(ntPcount-1, 1)
                          EXIT
                     ENDIF
                     ntPcount = ntPcount+1
                ENDDO
           ENDIF
      ENDIF
      SELECT reServat
      SET ORDER TO nResOrd
      GOTO nrEsrec
      IF nrEsrec<>ncHeckinrec
           GOTO ncHeckinrec
      ENDIF
      l_cRsChanges = rsHistry(l_cRsChanges,"CHECKIN", "")
      IF (paRam.pa_postpos)
           IF (ctProom=="0")
                ctProom = " "
           ENDIF
           l_cRsChanges = rsHistry(l_cRsChanges, "TOUCHPOSROOM:"+ctProom, "")
      ENDIF
      LOCAL l_oReser
      SELECT reservat
      SCATTER NAME l_oReser MEMO
      l_oReser.rs_cidate = sySdate()
      l_oReser.rs_citime = TIME()
      l_oReser.rs_in = "1"
      l_oReser.rs_status = "IN"
      l_oReser.rs_posstat = "1"
      l_oReser.rs_changes = l_oReser.rs_changes + l_cRsChanges
      DO CheckAndSave IN ProcReservat WITH l_oReser, .T., .F., "CHECKIN"
       * Store last room nummber in address.dbf
*      IF EMPTY(reservat.rs_addrid)
*           IF !EMPTY(reservat.rs_apid) AND !EMPTY(reservat.rs_compid)
*                 IF SEEK(reServat.rs_compid,'address','tag1')
*                      replace ad_lasroom WITH reServat.rs_roomnum IN address
*                 ENDIF
*           ENDIF
*      ELSE
*           IF SEEK(reServat.rs_addrid,'address','tag1')
*                replace ad_lasroom WITH reServat.rs_roomnum IN address
*           ENDIF
*      ENDIF

      IF NOT plSilent AND reServat.rs_msgshow AND NOT plGroup
           DO FORM forms\msgedit WITH 1, reservat.rs_reserid, GetReservatLongName(), CompanyName()
      ENDIF
      biRthday()
      DO raTecodepost IN RatePost WITH (sySdate()), "CHECKIN"
      DO bqPost IN Banquet
      liFccheckin = .T.
      IF NOT plSilent AND paRam.pa_pttask
           IF ( .NOT. yeSno(GetLangText("RESERV2","TXT_IFCCHECKIN")+"?", ;
              GetLangText("RESERV2","TXT_INTERFACE")))
                liFccheckin = .F.
           ENDIF
           REPLACE reServat.rs_changes WITH rsHistry(reServat.rs_changes, ;
                   "PHONECHECKIN",IIF(liFccheckin, "YES", "NO"))
           SELECT reservat
           IF CURSORGETPROP("Buffering") == 1
               FLUSH
           ELSE
               = TABLEUPDATE(.F.,.T.,"reservat")
           ENDIF
      ENDIF
      IF (liFccheckin)
           DO ifCcheck IN Interfac WITH reServat.rs_roomnum, "CHECKIN", .F., l_lShowInterfaceForm
      ENDIF
      IF NOT plSilent AND (l_lShowInterfaceForm OR _screen.oCardReaderHandler.lAvailable)
           IF _screen.oGlobal.lUgos
                DO FORM "forms\interfaceawaform" WITH reservat.rs_rsid
           ELSE
                DO FORM forms\keycardform WITH reservat.rs_reserid, 2, NOT _screen.oglobal.oparam2.pa_ifcnoci
           ENDIF
      ENDIF
      *SELECT (ccUrrentarea)
      SELECT reservat
      IF NOT plSilent AND paRam.pa_cibill AND NOT plGroup
           IF (yeSno(GetLangText("RESERV2","TXT_GOTOBILL")))
                IF userpid()
                     g_Billstyle = MAX(param.pa_billsty, 1)
                     LArray(1) = reservat.rs_reserid
                     IF TYPE("_screen.ActiveForm") = "O"
                          LArray(2) = _screen.ActiveForm
                     ENDIF
                     doform('frmbills','forms\bills','',.T.,@LArray)
                ENDIF
           ENDIF
      ENDIF
      EXIT
 ENDDO
 IF NOT plSilent AND NOT EMPTY(pcMessage)
      Alert(pcMessage,cHeader)
 ENDIF
 RETURN .T.
ENDFUNC
*
PROCEDURE RSQuickEdit
 PARAMETER nrSreserid
 PRIVATE ALL LIKE l_*
 PRIVATE p_Checkaddress, p_Splitted
 PRIVATE a_Fields
 DIMENSION a_Fields[12, 4]
 STORE '' TO a_Fields
 PRIVATE naRea, nrSrec, nrSord
 PRIVATE nrStemprec, naDdrooms, nsUbsetid, i, nlAstsubid, nsPlitrooms, nrOoms
 PRIVATE cpMroomnum, npMid, csEtbillins, lhAspm, ctMpbillins, ctMpgroup,  ;
         nrEsfixid
 a_Fields[1, 1] = "Reservat.Rs_Status"
 a_Fields[1, 2] = 5
 a_Fields[1, 3] = "Stat"
 a_Fields[2, 1] = "address.ad_lname"
 a_Fields[2, 2] = IIF(g_Nscreenmode==1, 20, 25)
 a_Fields[2, 3] = GetLangText("RESERV2","TH_LNAME")
 a_Fields[2, 4] = REPLICATE('X', 25)
 a_Fields[3, 1] = "address.ad_fname"
 a_Fields[3, 2] = IIF(g_Nscreenmode==1, 12, 15)
 a_Fields[3, 3] = GetLangText("RESERV2","TH_FNAME")
 a_Fields[4, 1] = "address.ad_lang"
 a_Fields[4, 2] = IIF(g_Nscreenmode==1, 5, 6)
 a_Fields[4, 3] = GetLangText("RESERV2","TH_LANG")
 a_Fields[5, 1] = "address.ad_titlcod"
 a_Fields[5, 2] = IIF(g_Nscreenmode==1, 5, 6)
 a_Fields[5, 3] = GetLangText("RESERV2","TH_TITLECODE")
 a_Fields[6, 1] = "address.ad_title"
 a_Fields[6, 2] = IIF(g_Nscreenmode==1, 8, 10)
 a_Fields[6, 3] = GetLangText("RESERV2","TH_TITLE")
 a_Fields[7, 1] = "address.ad_country"
 a_Fields[7, 2] = IIF(g_Nscreenmode==1, 5, 6)
 a_Fields[7, 3] = GetLangText("RESERV2","TH_COUNTRY")
 a_Fields[8, 1] = "reservat.rs_arrdate"
 a_Fields[8, 2] = siZedate()
 a_Fields[8, 3] = GetLangText("RESERV2","TH_ARRDATE")
 a_Fields[9, 1] = "reservat.rs_depdate"
 a_Fields[9, 2] = siZedate()
 a_Fields[9, 3] = GetLangText("RESERV2","TH_DEPDATE")
 a_Fields[10, 1] = "reservat.rs_roomtyp"
 a_Fields[10, 2] = IIF(g_Nscreenmode==1, 5, 6)
 a_Fields[10, 3] = GetLangText("RESERV2","TH_ROOMTYPE")
 a_Fields[11, 1] = "reservat.rs_roomnum + TRIM(reservat.rs_share)"
 a_Fields[11, 2] = IIF(g_Nscreenmode==1, 6, 6)
 a_Fields[11, 3] = GetLangText("RESERV2","TH_ROOMNUM")
 a_Fields[12, 1] = "reservat.rs_adults"
 a_Fields[12, 2] = IIF(g_Nscreenmode==1, 6, 6)
 a_Fields[12, 3] = GetLangText("RESERV2","TH_ADULTS")
 IF INLIST(reServat.rs_status, "CXL", "NS")
      = alErt(GetLangText("RESERV2","TA_ISCXL")+"!")
      RETURN
 ENDIF
 IF dbLookup("RoomType","Tag1",rs_roomtyp,"Rt_Group")=2
      = alErt(GetLangText("RESERV2","TA_ONLYSTANDARD"))
      RETURN
 ENDIF
 naRea = SELECT()
 SELECT reServat
 nrSord = ORDER()
 nrSrec = RECNO()
 SET ORDER TO 1
 IF  .NOT. reServat.rs_roomlst
      IF  .NOT. yeSno(GetLangText("RESERV2","TA_SPLIT")+"?")
           SELECT (naRea)
           RETURN
      ELSE
           ctMpgroup = reServat.rs_group
           ctMpbillins = ""
           lhAspm = qeHaspm(reServat.rs_reserid,reServat.rs_arrdate, ;
                    @ctMpgroup,@ctMpbillins)
           IF EMPTY(ctMpgroup)
                cgRoupname = qeGetgrp()
                IF EMPTY(cgRoupname)
                     SELECT (naRea)
                     RETURN
                ENDIF
           ELSE
                cgRoupname = ctMpgroup
           ENDIF
           IF  .NOT. lhAspm
                IF yeSno(GetLangText("RESERV2","TXT_CREATEDUMMY"),GetLangText("RESERV2", ;
                   "TXT_SPLITROOMS"))
                     cpMroomnum = geTfree(geTdummy(),reServat.rs_arrdate, ;
                                  reServat.rs_depdate)
                     IF EMPTY(cpMroomnum)
                          = alErt(GetLangText("RESERV2","TXT_NOFREEDUMMY"), ;
                            GetLangText("RESERV2","TXT_SPLITROOMS"))
                          SELECT (naRea)
                          RETURN
                     ENDIF
                     npMid = reServat.rs_reserid
                     csEtbillins = MLINE(reServat.rs_billins, 4)
                     IF  .NOT. EMPTY(csEtbillins)
                          csEtbillins = STRTRAN(STR(npMid, 12, 3),",",".",1,1)+ ;
                                        SUBSTR(csEtbillins, 13)
                     ELSE
                          csEtbillins = reServat.rs_billins
                     ENDIF
                ELSE
                     cpMroomnum = ""
                     npMid = 0
                     csEtbillins = reServat.rs_billins
                ENDIF
           ELSE
                cpMroomnum = ""
                npMid = 0
                csEtbillins = ctMpbillins
           ENDIF
           nrOoms = reServat.rs_rooms
           nsPlitrooms = qeGetrms(reServat.rs_rooms,reServat.rs_roomtyp)
           DO CASE
                CASE EMPTY(nsPlitrooms)
                     SELECT (naRea)
                     RETURN
                CASE nsPlitrooms==nrOoms
                     nsPlitrooms = nsPlitrooms-1
           ENDCASE
           nlAstsubid = qeGetsubid(reServat.rs_reserid)
           nrSrec = RECNO()
           nsUbsetid = INT(reServat.rs_reserid*10)/10
           IF  .NOT. EMPTY(cpMroomnum)
                naDdrooms = nsPlitrooms+1
           ELSE
                naDdrooms = nsPlitrooms
           ENDIF
           SCATTER MEMO MEMVAR
           nrEsfixid = M.rs_reserid
           FOR i = 1 TO naDdrooms
                M.rs_reserid = nsUbsetid+nlAstsubid+(0.001*i)
                M.rs_billins = csEtbillins
                M.rs_group = cgRoupname
                M.rs_changes = rsHistry("","QUICK EDIT","Copy")
                IF i=1
                     IF  .NOT. EMPTY(cpMroomnum)
                          IF nrOoms=nsPlitrooms+1
                               M.rs_rooms = 1
                               M.rs_roomlst = .T.
                          ELSE
                               M.rs_rooms = nrOoms-nsPlitrooms
                               M.rs_roomlst = .F.
                          ENDIF
                     ELSE
                          M.rs_rooms = 1
                          M.rs_roomlst = .T.
                     ENDIF
                ELSE
                     M.rs_rooms = 1
                     M.rs_roomlst = .T.
                ENDIF
                M.rs_in = ""
                M.rs_out = ""
                M.rs_status = IIF(INLIST(M.rs_status, "IN", "OUT", "CXL",  ;
                              "NS"), paRam.pa_defstat, M.rs_status)
                M.rs_ratedat = CTOD("")
                M.rs_ratein = .F.
                M.rs_rateout = .F.
                M.rs_created = sySdate()
                M.rs_updated = sySdate()
                M.rs_userid = cuSerid
                M.rs_cidate = {}
                M.rs_citime = ""
                M.rs_codate = {}
                M.rs_cotime = ""
                M.rs_cxldate = {}
                M.rs_depamt1 = 0
                M.rs_depamt2 = 0
                M.rs_depdat1 = {}
                M.rs_depdat2 = {}
                M.rs_deppdat = {}
                M.rs_deppaid = 0
                IF LOOKUP(paYmetho.pm_deposit, M.rs_paymeth,  ;
                   paYmetho.pm_paymeth, "Tag2")
                     M.rs_paymeth = ""
                ENDIF
                = avLsave(1,{},{},0,"","","","",0,"","")
                INSERT INTO Reservat FROM MEMVAR
                = avLupdat()
                DO reSfixsync IN ResFix WITH nrEsfixid, M.rs_reserid
                FLUSH
           ENDFOR
           GOTO nrSrec
           IF  .NOT. EMPTY(cpMroomnum)
                = avLsave()
                REPLACE reServat.rs_group WITH cgRoupname,  ;
                        reServat.rs_rooms WITH 1, reServat.rs_roomnum  ;
                        WITH cpMroomnum, reServat.rs_roomtyp WITH  ;
                        geTdummy(), reServat.rs_roomlst WITH .T.,  ;
                        reServat.rs_rate WITH 0.00, reServat.rs_ratecod WITH ""
                = avLupdat()
                DO reSfixdel IN ResFix WITH reServat.rs_reserid
                = qeUpdsingle(reServat.rs_reserid,reServat.rs_arrdate, ;
                  cgRoupname,csEtbillins)
           ELSE
                = avLsave()
                IF reServat.rs_rooms=nsPlitrooms+1
                     REPLACE reServat.rs_group WITH cgRoupname,  ;
                             reServat.rs_rooms WITH 1,  ;
                             reServat.rs_roomlst WITH .T.,  ;
                             reServat.rs_billins WITH csEtbillins
                ELSE
                     REPLACE reServat.rs_group WITH cgRoupname,  ;
                             reServat.rs_rooms WITH reServat.rs_rooms- ;
                             nsPlitrooms, reServat.rs_billins WITH csEtbillins
                ENDIF
                = avLupdat()
           ENDIF
      ENDIF
 ENDIF
 l_For = '!Inlist(Rs_Status, "CXL", "NS") And DbLookup("RoomType", "Tag1", Rs_RoomTyp, "Rt_Group") <> 2 And Rs_Rooms = 1 And Rs_RoomLst'
 l_While = [Str(Int(Reservat.Rs_ReserId), 8, 0) == ']+ ;
           STR(INT(reServat.rs_reserid), 8, 0)+[']
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
            GetLangText("RESERV2","TXT_AUTO"),3)+buTton(clEvel,GetLangText("RESERV2", ;
            "TB_INFO"),-4)
 crS1button = gcButtonfunction
 gcButtonfunction = ""
 DO myBrowse WITH GetLangText("RESERV2","TW_QUICKEDIT"), 20, a_Fields, l_For,  ;
    l_While, cbUttons, "vControl", "reserv2"
 gcButtonfunction = crS1button
 SELECT reServat
 SET ORDER TO nRsOrd
 GOTO nrSrec
 SELECT (naRea)
 RETURN
ENDPROC
*
FUNCTION QeHasPM
 PARAMETER pnId, pdArrival, pcGroup, pcBillins
 PRIVATE lrEt, naRea, nrSord, nrSrec
 lrEt = .F.
 naRea = SELECT()
 SELECT reServat
 nrSord = ORDER()
 nrSrec = RECNO()
 SET ORDER TO 1
 = dlOcate('Reservat','rs_reserid >= '+sqLcnv(INT(pnId))+ ;
   ' and rs_reserid < '+sqLcnv(INT(pnId)+1))
 LOCATE REST FOR isDummy(rs_roomtyp) .AND. rs_arrdate=pdArrival WHILE  ;
        INT(rs_reserid)==INT(pnId)
 IF FOUND()
      lrEt = .T.
      pcGroup = rs_group
      pcBillins = MLINE(rs_billins, 4)
      IF  .NOT. EMPTY(pcBillins)
           pcBillins = STR(rs_reserid, 12, 3)+SUBSTR(pcBillins, 13)
      ENDIF
 ENDIF
 SET ORDER TO nRsOrd
 GOTO nrSrec
 SELECT (naRea)
 RETURN lrEt
ENDFUNC
*
FUNCTION QeGetRms
 PARAMETER pnRooms, pcRoomtype
 PRIVATE adLg, nrEt
 nrEt = 0
 DIMENSION adLg[1, 8]
 adLg[1, 1] = "rooms"
 adLg[1, 2] = TRIM(pcRoomtype)+" "+GetLangText("RESERV2","TXT_COUNTSPLIT")
 adLg[1, 3] = LTRIM(STR(pnRooms))
 adLg[1, 4] = "99"
 adLg[1, 5] = 10
 adLg[1, 6] = "rooms >= 1 AND rooms <= "+LTRIM(STR(pnRooms))
 adLg[1, 7] = ""
 adLg[1, 8] = 0
 IF diAlog(GetLangText("RESERV2","TXT_SPLITROOMS"),GetLangText("RESERV2", ;
    "TXT_ENTERSPLIT"),@adLg)
      nrEt = adLg(1,8)
 ENDIF
 RETURN nrEt
ENDFUNC
*
FUNCTION QeGetGrp
 PRIVATE adLg, crEt
 crEt = ""
 DIMENSION adLg[1, 8]
 adLg[1, 1] = "group"
 adLg[1, 2] = GetLangText("RESERV2","TXT_GROUP")
 adLg[1, 3] = "Space(25)"
 adLg[1, 4] = REPLICATE("!", 25)
 adLg[1, 5] = 30
 adLg[1, 6] = "!Empty(group)"
 adLg[1, 7] = ""
 adLg[1, 8] = ""
 IF diAlog(GetLangText("RESERV2","TXT_SPLITROOMS"),"",@adLg)
      crEt = adLg(1,8)
 ENDIF
 RETURN crEt
ENDFUNC
*
FUNCTION QeGetSubId
 PARAMETER pnId
 PRIVATE nrEt, naRea, nrSord, nrSrec
 nrEt = 0
 naRea = SELECT()
 SELECT reServat
 nrSord = ORDER()
 nrSrec = RECNO()
 SET ORDER TO 1
 IF dlOcate('Reservat','rs_reserid >= '+sqLcnv(INT(pnId*10)/10)+ ;
    ' and rs_reserid < '+sqLcnv(INT(pnId*10)/10+(0.1)))
      nrEt = rs_reserid-INT(pnId*10)/10
      SCAN REST WHILE INT(rs_reserid*10)/10==INT(pnId*10)/10
           nrEt = rs_reserid-INT(pnId*10)/10
      ENDSCAN
 ELSE
      nrEt = rs_reserid-INT(pnId*10)/10
 ENDIF
 SET ORDER TO nRsOrd
 GOTO nrSrec
 SELECT (naRea)
 RETURN nrEt
ENDFUNC
*
PROCEDURE QeUpdSingle
 PARAMETER pnId, pdArrival, pcGroup, pcBillins, pnGroupid, pcResalias
 PRIVATE naRea, nrSrec, nrSord
 IF PCOUNT() < 5
      pnGroupid = 0
 ENDIF
 IF PCOUNT() < 6
      pcResalias = "reservat"
 ENDIF
 naRea = SELECT()
 SELECT &pcResalias
 nrSrec = RECNO()
 nrSord = ORDER()
 SET ORDER TO 1
 IF dlOcate(pcResalias,'rs_reserid >= '+sqLcnv(INT(pnId))+ ;
    ' and rs_reserid < '+sqLcnv(INT(pnId)+1))
      SCAN REST FOR rs_rooms=1 .AND.  .NOT. rs_roomlst .AND. rs_arrdate= ;
           pdArrival WHILE INT(rs_reserid)==INT(pnId)
           IF NOT EMPTY(pcBillins)
                REPLACE rs_billins WITH pcBillins
           ENDIF
           REPLACE rs_roomlst WITH .T., rs_group WITH pcGroup, rs_groupid WITH pnGroupid
      ENDSCAN
 ENDIF
 GOTO nrSrec
 SET ORDER TO nRsOrd
 SELECT (naRea)
 RETURN
ENDPROC
*
PROCEDURE vControl
 PARAMETER p_Choice
 DO CASE
      CASE p_Choice==1
      CASE p_Choice==2
           IF reServat.rs_rooms==1
                REPLACE reServat.rs_roomlst WITH .T.
           ENDIF
           DO scRquickedit
           g_Refreshall = .T.
      CASE p_Choice==3
           IF (yeSno(GetLangText("RESERV2","TXT_ARE_YOU_SURE")))
                = auToroom(CTOD(""),reServat.rs_reserid,"")
           ENDIF
           g_Refreshall = .T.
      CASE p_Choice==4
           DO qeInfo
 ENDCASE
 RETURN
ENDPROC
*
PROCEDURE ScrQuickEdit
 PRIVATE daRrdate
 PRIVATE ddEpdate
 PRIVATE l_Row
 l_Row = M.ncUrline+piXv(3)
 PRIVATE ALL LIKE l_*
 PRIVATE ndOwcurrent, ndOwarrival, caDfld, ccHfld
 l_Col = 5+piXh(2)
 l_Append = .F.
 l_Oldarea = SELECT()
 l_Rsrec = RECNO("reservat")
 SELECT adDress
 SCATTER MEMO MEMVAR
 SELECT reServat
 SCATTER MEMO MEMVAR
 SCATTER TO acReservat 
 daRrdate = reServat.rs_arrdate
 ddEpdate = reServat.rs_depdate
 SET READBORDER OFF
 @ l_Row, l_Col GET M.ad_lname SIZE 1, 25 PICTURE "@K "+REPLICATE("X",  ;
   30) VALID vlName(@l_Append)
 l_Col = l_Col+25+piXh(1)
 @ l_Row, l_Col GET M.ad_fname SIZE 1, 15 PICTURE "@K "+REPLICATE("X", 20)
 l_Col = l_Col+15+piXh(1)
 @ l_Row, l_Col GET M.ad_lang SIZE 1, 6 PICTURE "@K !!!" VALID  ;
   piCklist("LANGUAGE",@M.ad_lang,l_Row,44,"C",WONTOP())
 l_Col = l_Col+6+piXh(1)
 @ l_Row, l_Col GET M.ad_titlcod SIZE 1, 6 PICTURE "@KB 9" VALID  ;
   vtItle(l_Row,51)
 l_Col = l_Col+6+piXh(1)
 @ l_Row, l_Col GET M.ad_title SIZE 1, 10 PICTURE "@K "+REPLICATE("X",  ;
   10) WHEN .F.
 l_Col = l_Col+10+piXh(1)
 @ l_Row, l_Col GET M.ad_country SIZE 1, 6 PICTURE "@K !!!" VALID  ;
   piCklist("COUNTRY",@M.ad_country,l_Row,69,"C",WONTOP())
 l_Col = l_Col+6+piXh(1)
 @ l_Row, l_Col GET M.rs_arrdate SIZE 1, siZedate() PICTURE "@KD" VALID   ;
   .NOT. EMPTY(M.rs_arrdate) WHEN  .NOT. INLIST(reServat.rs_status, "IN",  ;
   "OUT")
 l_Col = l_Col+siZedate()+piXh(1)
 @ l_Row, l_Col GET M.rs_depdate SIZE 1, siZedate() PICTURE "@KD" VALID   ;
   .NOT. EMPTY(M.rs_depdate) .AND. M.rs_depdate>=M.rs_arrdate WHEN  .NOT.  ;
   INLIST(reServat.rs_status, "OUT")
 l_Col = l_Col+siZedate()+piXh(1)
 @ l_Row, l_Col GET M.rs_roomtyp SIZE 1, 6 PICTURE "@K !!!!" VALID  ;
   vrOomtype(l_Row,85) .AND. voVerbook() WHEN  .NOT.  ;
   INLIST(reServat.rs_status, "IN", "OUT")
 l_Col = l_Col+6+piXh(1)
 @ l_Row, l_Col GET M.rs_roomnum SIZE 1, 6 PICTURE "@K !!!!" VALID  ;
   vrOomnum(l_Row,85) WHEN (M.rs_rooms=1) .AND.  .NOT.  ;
   INLIST(reServat.rs_status, "IN", "OUT")
 l_Col = l_Col+6+piXh(1)
 @ l_Row, l_Col GET M.rs_adults SIZE 1, 6 PICTURE "@K 999" VALID  ;
   M.rs_adults>=0 .AND. M.rs_adults<999 WHEN  .NOT.  ;
   INLIST(reServat.rs_status, "OUT")
 READ MODAL
 SET READBORDER ON
 IF LASTKEY()<>27
      SELECT adDress
      IF l_Append
           INSERT INTO address FROM MEMVAR
      ELSE
           l_Adord = ORDER("address")
           SET ORDER IN "address" TO 1
           = SEEK(M.ad_addrid, "address")
           SET ORDER IN "address" TO l_AdOrd
           GATHER MEMO MEMVAR
      ENDIF
      = avLsave()
      SELECT reServat
      GOTO l_Rsrec IN "reservat"
      LOCAL l_oResOld, l_nMode
      SCATTER MEMO NAME l_oResOld
      IF (M.rs_arrdate<>daRrdate)
           M.rs_changes = rsHistry(M.rs_changes,"QUICKEDIT","ARRIVAL "+ ;
                          DTOC(daRrdate)+"..."+DTOC(M.rs_arrdate))
      ENDIF
      IF (M.rs_depdate<>ddEpdate)
           M.rs_changes = rsHistry(M.rs_changes,"QUICKEDIT","DEPARTURE "+ ;
                          DTOC(ddEpdate)+"..."+DTOC(M.rs_depdate))
      ENDIF
      IF (reServat.rs_roomtyp<>M.rs_roomtyp .OR. reServat.rs_adults<> ;
         M.rs_adults .OR. reServat.rs_arrdate<>M.rs_arrdate .OR.  ;
         reServat.rs_depdate<>M.rs_depdate) .AND.  ;
         LEFT(reServat.rs_ratecod, 1)<>"*"
           SELECT raTecode
           SET ORDER TO 1
           IF SEEK(reServat.rs_ratecod)
                LOCATE REST FOR raTecode.rc_fromdat<=M.rs_arrdate .AND.  ;
                       raTecode.rc_todat>M.rs_arrdate .AND.  ;
                       raTecode.rc_roomtyp==reServat.rs_roomtyp .AND.  ;
                       (raTecode.rc_minstay=0 .OR. raTecode.rc_minstay<= ;
                       M.rs_depdate-M.rs_arrdate) WHILE  ;
                       raTecode.rc_ratecod==reServat.rs_ratecod
                IF  .NOT. FOUND()
                     = SEEK(PADR(reServat.rs_ratecod, 10)+"*", "RateCode")
                     LOCATE REST FOR raTecode.rc_fromdat<=M.rs_arrdate  ;
                            .AND. raTecode.rc_todat>M.rs_arrdate .AND.  ;
                            raTecode.rc_roomtyp="*" .AND.  ;
                            (raTecode.rc_minstay=0 .OR.  ;
                            raTecode.rc_minstay<=M.rs_depdate- ;
                            M.rs_arrdate) WHILE raTecode.rc_ratecod= ;
                            reServat.rs_ratecod
                ENDIF
                IF FOUND()
                     nrAte = raTecode.rc_base
                     ndOwcurrent = DOW(reServat.rs_arrdate, 2)
                     ndOwarrival = DOW(reServat.rs_arrdate, 2)
                     IF SUBSTR(raTecode.rc_weekend, ndOwcurrent, 1)='1'  ;
                        .AND. SUBSTR(raTecode.rc_closarr, ndOwarrival, 1)=' '
                          caDfld = 'RateCode.rc_wamnt'
                          ccHfld = 'RateCode.rc_wcamnt'
                     ELSE
                          caDfld = 'RateCode.rc_amnt'
                          ccHfld = 'RateCode.rc_camnt'
                     ENDIF
                     IF ( .NOT. BETWEEN(M.rs_adults, 1, 5) .OR.  ;
                        EVALUATE(caDfld+STR(M.rs_adults, 1))==0)
                          nrAte = nrAte+EVALUATE(caDfld+'1')* ;
                                  IIF(paRam.pa_chkadts, MAX(M.rs_adults,  ;
                                  1), M.rs_adults)
                     ELSE
                          nrAte = nrAte+EVALUATE(caDfld+ ;
                                  STR(MAX(M.rs_adults, 1), 1))
                     ENDIF
                     IF reServat.rs_childs>0
                          nrAte = nrAte+EVALUATE(ccHfld+'1')*reServat.rs_childs
                     ENDIF
                     IF reServat.rs_childs2>0
                          nrAte = nrAte+EVALUATE(ccHfld+'2')* ;
                                  reServat.rs_childs2
                     ENDIF
                     IF reServat.rs_childs3>0
                          nrAte = nrAte+EVALUATE(ccHfld+'3')* ;
                                  reServat.rs_childs3
                     ENDIF
                     IF nrAte<>reServat.rs_rate
                          = alErt(GetLangText("RESERV2","TA_RCCHANGED")+"!")
                          M.rs_changes = rsHistry(M.rs_changes, ;
                           "QUICKEDIT","RATE "+LTRIM(STR(M.rs_rate, 10,  ;
                           2))+"..."+LTRIM(STR(nrAte, 10, 2)))
                          M.rs_rate = nrAte
                     ENDIF
                ELSE
                     = alErt(GetLangText("RESERV2","TA_RCINV1")+";;"+ ;
                       GetLangText("RESERV2","TA_RCINV2")+"!")
                     M.rs_arrdate = reServat.rs_arrdate
                     M.rs_depdate = reServat.rs_depdate
                     M.rs_roomtyp = reServat.rs_roomtyp
                     M.rs_roomnum = reServat.rs_roomnum
                     M.rs_adults = reServat.rs_adults
                ENDIF
           ELSE
                = alErt(GetLangText("RESERV2","TA_RCINV1")+";;"+GetLangText("RESERV2", ;
                  "TA_RCINV2")+"!")
                M.rs_arrdate = reServat.rs_arrdate
                M.rs_depdate = reServat.rs_depdate
                M.rs_roomtyp = reServat.rs_roomtyp
                M.rs_roomnum = reServat.rs_roomnum
                M.rs_adults = reServat.rs_adults
           ENDIF
           SELECT reServat
      ENDIF
      GATHER MEMO MEMVAR
      DO CheckShare IN ProcReservat WITH "reservat", l_nMode, .F., .T., l_oResOld
      IF l_nMode >= 0
          DO ChangeShare IN ProcReservat WITH l_nMode, "reservat"
          = avLupdat()
          DO UpdateShareRes IN ProcReservat WITH "reservat"
      ELSE
          GATHER NAME l_oResOld MEMO
      ENDIF
 ENDIF
 l_Top = IIF(l_Row==2, 0, (0.0625))
 l_Bottom = IIF(l_Row==21, 0, (0.0625))
 SCROLL l_Row-l_Top, 5/3, l_Row+l_Bottom, l_Col+6-(0.333333333333333), 0
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
FUNCTION vLName
 PARAMETER p_Append
 PRIVATE nsEppos
 PRIVATE ALL LIKE l_*
 PRIVATE a_Fields
 DIMENSION a_Fields[7, 3]
 a_Fields[1, 1] = "address.ad_company"
 a_Fields[1, 2] = 20
 a_Fields[1, 3] = GetLangText("RESERV2","TH_COMPANY")
 a_Fields[2, 1] = "address.ad_departm"
 a_Fields[2, 2] = 15
 a_Fields[2, 3] = GetLangText("RESERV2","TH_DEPARTM")
 a_Fields[3, 1] = "address.ad_lname"
 a_Fields[3, 2] = 20
 a_Fields[3, 3] = GetLangText("RESERV2","TH_LNAME")
 a_Fields[4, 1] = "address.ad_fname"
 a_Fields[4, 2] = 15
 a_Fields[4, 3] = GetLangText("RESERV2","TH_FNAME")
 a_Fields[5, 1] = "address.ad_title"
 a_Fields[5, 2] = 15
 a_Fields[5, 3] = GetLangText("RESERV2","TH_TITLE")
 a_Fields[6, 1] = "Trim(address.ad_street)"
 a_Fields[6, 2] = 15
 a_Fields[6, 3] = GetLangText("RESERV2","TH_STREET")
 a_Fields[7, 1] = "Trim(address.ad_city)"
 a_Fields[7, 2] = 15
 a_Fields[7, 3] = GetLangText("RESERV2","TH_CITY")
 l_Retval = .F.
 l_Oldarea = SELECT()
 l_Oldname = M.ad_lname
 l_Savename = adDress.ad_lname
 SELECT adDress
 SET ORDER IN "address" TO 2
 IF  .NOT. EMPTY(M.ad_lname)
      = SEEK(UPPER(ALLTRIM(M.ad_lname)), "address")
      IF  .NOT. FOUND() .AND. yeSno(GetLangText("RESERV2","TA_NAMENOTFOUND")+"?")
           IF param.pa_adrcall
           do form "forms\addressmask" with "EDITQ", M.ad_lname, TAGNO(), "QER"&&, RECNO()
*           do form "forms\ADDRESSMASK" WITH 'EDITL',PROPER(pcsearch),tagno(),PCCALL
*           WAIT "Please wait" WINDOW TIMEOUT 5
           p_Append = .F.
           l_Retval = .T.
          * SHOW GETS
        ELSE
           p_Append = .T.
           SELECT adDress
           SCATTER BLANK MEMO MEMVAR
           M.ad_lname = l_Oldname
           M.ad_addrid = neXtid('ADDRESS')
           M.ad_country = paRam.pa_country
           M.ad_titlcod = paRam.pa_titlcod
           M.ad_lang = paRam.pa_lang
           M.ad_created = sySdate()
           M.ad_updated = sySdate()
           M.ad_userid = cuSerid
           M.rs_addrid = M.ad_addrid
           M.rs_lname = UPPER(M.ad_lname)
           l_Retval = .T.
           SHOW GETS
    ENDIF 
      ELSE
           IF (UPPER(ALLTRIM(l_Savename))==UPPER(ALLTRIM(M.ad_lname)))
                LOCATE REST FOR adDress.ad_addrid==M.ad_addrid WHILE  ;
                       UPPER(ALLTRIM(adDress.ad_lname))= ;
                       UPPER(ALLTRIM(M.ad_lname))
           ENDIF
           clEvel = ""
           cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+ ;
                      buTton(clEvel,GetLangText("COMMON","TXT_NEW"),-2)
           crS2button = gcButtonfunction
           gcButtonfunction = ""
           DO myBrowse WITH GetLangText("RESERV2","TW_ADDRESS"), 10, a_Fields,  ;
              ".t.", ".t.", cbUttons, "vAdControl", "reserv2"
           gcButtonfunction = crS2button
           IF LASTKEY()<>27
                IF  .NOT. p_Append
                     SCATTER MEMO MEMVAR
                ENDIF
                M.rs_addrid = M.ad_addrid
                M.rs_lname = UPPER(M.ad_lname)
                l_Retval = .T.
                SHOW GETS
           ENDIF
      ENDIF
      nsEppos = AT('/', M.rs_lname)
      IF nsEppos>0 .AND. nsEppos<LEN(M.rs_lname)
           M.rs_sname = SUBSTR(M.rs_lname, nsEppos+1)
      ELSE
           M.rs_sname = ''
      ENDIF
 ELSE
      l_Retval = .F.
 ENDIF
 SET ORDER IN "address" TO 1
 SELECT (l_Oldarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION vAdControl
 PARAMETER p_Choice
 PRIVATE l_Oldname
 l_Oldname = M.ad_lname
 DO CASE
      CASE p_Choice==1
      CASE p_Choice==2
           M.p_Append = .T.
           SELECT adDress
           SCATTER BLANK MEMO MEMVAR
           M.ad_lname = l_Oldname
           M.ad_addrid = neXtid('ADDRESS')
           M.ad_country = paRam.pa_country
           M.ad_titlcod = paRam.pa_titlcod
           M.ad_lang = paRam.pa_lang
           M.ad_created = sySdate()
           M.ad_updated = sySdate()
           M.ad_userid = cuSerid
           M.rs_addrid = M.ad_addrid
           M.rs_lname = UPPER(M.ad_lname)
           M.l_Ready = .T.
           CLEAR READ
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION vTitle
 PARAMETER p_Row, p_Col
 PRIVATE ALL LIKE l_*
 PRIVATE a_Field
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "ti_titlcod"
 a_Field[1, 2] = 2
 a_Field[2, 1] = "ti_title"
 a_Field[2, 2] = 15
 l_Oldarea = SELECT()
 l_Retval = .F.
 SELECT tiTle
 LOCATE ALL FOR tiTle.ti_lang=M.ad_lang .AND. tiTle.ti_titlcod=M.ad_titlcod
 IF  .NOT. FOUND()
      GOTO TOP
      IF myPopup(WONTOP(),p_Row+1,p_Col,5,@a_Field,".t.", ;
         "ti_lang = m.ad_lang")>0
           M.ad_titlcod = tiTle.ti_titlcod
           M.ad_title = tiTle.ti_title
           M.ad_salute = TRIM(tiTle.ti_salute)+" "+TRIM(flIp(M.ad_lname))+","
           M.ad_attn = IIF( .NOT. EMPTY(M.ad_company), tiTle.ti_attn, "")
           SHOW GET M.ad_title
           SHOW GET M.ad_salute
           SHOW GET M.ad_attn
           l_Retval = .T.
      ENDIF
 ELSE
      M.ad_titlcod = tiTle.ti_titlcod
      M.ad_title = tiTle.ti_title
      M.ad_salute = TRIM(tiTle.ti_salute)+" "+TRIM(flIp(M.ad_lname))+","
      M.ad_attn = IIF( .NOT. EMPTY(M.ad_company), tiTle.ti_attn, "")
      SHOW GET M.ad_title
      SHOW GET M.ad_salute
      SHOW GET M.ad_attn
      l_Retval = .T.
 ENDIF
 SELECT (l_Oldarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION vRoomtype
 PARAMETER p_Line, p_Pos
 PRIVATE ALL LIKE l_*
 PRIVATE a_Field
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "rt_roomtyp"
 a_Field[1, 2] = 6
 a_Field[2, 1] = "Trim(rt_lang"+g_Langnum+")"
 a_Field[2, 2] = 20
 l_Retval = .F.
 l_Oldarea = SELECT()
 SELECT roOmtype
 IF (EMPTY(M.rs_roomtyp) .OR.  .NOT. SEEK(M.rs_roomtyp, "RoomType"))
      GOTO TOP IN "RoomType"
      IF (myPopup(WONTOP(),p_Line+1,p_Pos,5,@a_Field,".t.",".t.")>0)
           M.rs_roomtyp = roOmtype.rt_roomtyp
           l_Retval = .T.
      ENDIF
 ELSE
      l_Retval = .T.
 ENDIF
 SELECT (l_Oldarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION vRoomnum
 PARAMETER ncUrrentline, ncUrrentposition
 PRIVATE liSvalid
 PRIVATE nsElect
 PRIVATE ALL LIKE l_*
 PRIVATE a_Field
 DIMENSION a_Field[3, 2]
 a_Field[1, 1] = "rm_roomnum"
 a_Field[1, 2] = 6
 a_Field[2, 1] = "rm_roomtyp"
 a_Field[2, 2] = 6
 a_Field[3, 1] = "Trim(rm_lang"+g_Langnum+")"
 a_Field[3, 2] = 20
 liSvalid = .F.
 nsElect = SELECT()
 SELECT roOm
 IF (EMPTY(M.rs_roomnum))
      liSvalid = .T.
 ELSE
      IF ( .NOT. SEEK(M.rs_roomnum, "Room"))
           GOTO TOP IN "room"
           IF (myPopup(WONTOP(),ncUrrentline+1,ncUrrentposition,5, ;
              @a_Field,".t.",".t.")>0)
                M.rs_roomtyp = roOm.rm_roomtyp
                M.rs_roomnum = roOm.rm_roomnum
                liSvalid = .T.
                SHOW GET M.rs_roomtyp
           ENDIF
      ELSE
           M.rs_roomtyp = roOm.rm_roomtyp
           liSvalid = .T.
           SHOW GET M.rs_roomtyp
      ENDIF
 ENDIF
 SELECT (nsElect)
 RETURN liSvalid
ENDFUNC
*
FUNCTION vOverBook
 PRIVATE ALL LIKE l_*
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 l_Retval = .T.
 l_Oldarea = SELECT()
 l_Oldroomtype = reServat.rs_roomtyp
 l_Oldarrival = reServat.rs_arrdate
 l_Olddeparture = reServat.rs_depdate
 l_Rtrec = RECNO("roomtype")
 IF SEEK(M.rs_roomtyp, "roomtype") .AND. roOmtype.rt_group=1
      l_Free = 9999
      l_Date = M.rs_arrdate
      SELECT avAilab
      DO WHILE l_Date<M.rs_depdate
           IF SEEK(DTOS(l_Date)+M.rs_roomtyp, "availab")
                l_Calc = IIF(M.rs_roomtyp==l_Oldroomtype .AND.  ;
                         BETWEEN(l_Date, l_Oldarrival, l_Olddeparture), 0, 1)
                l_Free = MIN(l_Free, av_avail-l_Calc-av_definit- ;
                         IIF(paRam.pa_optidef, av_option, 0)- ;
                         IIF(paRam.pa_allodef, MAX(av_allott-av_pick, 0), 0))
                IF l_Free<0
                     l_Retval = paRam.pa_overbk
                     IF  .NOT. yeSno(GetLangText("RESERV2","TA_OVBK1")+" "+ ;
                         DTOC(l_Date)+" "+LTRIM(STR(-l_Free))+" "+ ;
                         TRIM(M.rs_roomtyp)+";"+GetLangText("RESERV2","TA_OVBK2")+"?")
                          EXIT
                     ELSE
                          l_Free = 9999
                     ENDIF
                ENDIF
           ENDIF
           l_Date = l_Date+1
      ENDDO
      l_Free = IIF(l_Free=9999, 0, l_Free)
 ENDIF
 GOTO l_Rtrec IN "roomtype"
 SELECT (l_Oldarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION Deact
 CLEAR READ
 RETURN .T.
ENDFUNC
*
FUNCTION GetRLEDButtons
 PARAMETER acChecks, alChecks
 EXTERNAL ARRAY acChecks
 EXTERNAL ARRAY alChecks
 DIMENSION acChecks[18]
 DIMENSION alChecks[18]
 STORE "" TO acChecks
 STORE .F. TO alChecks
 acChecks[1] = GetLangText("COMMON","TXT_CLOSE")
 acChecks[2] = GetLangText("COMMON","TXT_EDIT")
 acChecks[3] = GetLangText("RESERV2","TXT_AUTO")
 acChecks[9] = GetLangText("RESERV2","TXT_CXLRESERVATION")+" "+GetLangText("RESERV2", ;
         "TXT_INDELETE")
 acChecks[10] = GetLangText("RESERV2","TXT_DELRESERVATION")
 acChecks[13] = GetLangText("COMMON","TXT_OK")+" "+GetLangText("RESERV2","TXT_INSEARCH")
 acChecks[14] = GetLangText("COMMON","TXT_CANCEL")
 cmAcro = "Group.Gr_ButRled"
 cData  = &cMacro
 FOR ni = 1 TO 16
      alChecks[ni] = (SUBSTR(cdAta, ni, 1)=="1")
 ENDFOR
 RETURN .T.
ENDFUNC
*
PROCEDURE vClearRoom
 IF WEXIST('wShowRoom')
      RELEASE WINDOW wsHowroom
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE AutoRoom
 PARAMETER p_Arrdate, nrSreserid, pcFor
 PRIVATE ndAy, lfOund, cfOr, cwHile
 PRIVATE ALL LIKE l_*
 LOCAL l_oResOld, l_nMode
 l_Oldrsord = ORDER("reservat")
 l_Oldrsrec = RECNO("reservat")
 l_Oldarea = SELECT()
 l_Found = 0
 l_Notfound = 0
 l_Autofound = .F.
 SELECT reServat
 DO CASE
      CASE  .NOT. EMPTY(p_Arrdate)
           SET ORDER IN "reservat" TO 8
           lfOund = SEEK(DTOS(p_Arrdate), "reservat")
           cfOr = sqLand(pcFor,"Empty(rs_roomnum)")
           cwHile = "reservat.rs_arrdate = "+sqLcnv(p_Arrdate)
      CASE  .NOT. EMPTY(nrSreserid)
           SET ORDER IN "reservat" TO 1
           lfOund = dlOcate('Reservat','rs_reserid >= '+ ;
                    sqLcnv(INT(nrSreserid))+' and rs_reserid < '+ ;
                    sqLcnv(INT(nrSreserid)+1))
           cfOr = 'rs_rooms = 1 and Empty(rs_roomnum) and !InList(rs_status, "NS", "CXL")'
           cwHile = "Int(reservat.rs_reserid) = "+sqLcnv(INT(nrSreserid))
 ENDCASE
 IF lfOund
      scan rest for &cFor while &cWhile
           ngRoup = dbLookup("RoomType","Tag1",reServat.rs_roomtyp,"Rt_Group")
           l_Autofound = .F.
           IF (ngRoup<>2)
                LOCAL l_depdate
                l_depdate = reservat.rs_depdate
                IF (ngroup == 3) .AND. (reservat.rs_arrdate == reservat.rs_depdate)
                     l_depdate = reservat.rs_depdate + 1
                ENDIF
                SELECT roOm
                SET ORDER IN "Room" TO 2
                = SEEK(reServat.rs_roomtyp, "Room")
                SCAN WHILE roOm.rm_roomtyp==reServat.rs_roomtyp
                     FOR ndAy = 0 TO (l_depdate- ;
                         reServat.rs_arrdate-1)
                          IF (SEEK(roOm.rm_roomnum+ ;
                             DTOS(reServat.rs_arrdate+ndAy), "RoomPlan"))
                               EXIT
                          ENDIF
                     ENDFOR
                     IF (reServat.rs_arrdate+ndAy==l_depdate)
                          SELECT reServat
                          SCATTER NAME l_oResOld
                          = avLsave()
                          REPLACE reServat.rs_roomnum WITH roOm.rm_roomnum
                          DO CheckShare IN ProcReservat WITH "reservat", l_nMode, .F., .T., l_oResOld
                          IF l_nMode >= 0
                              DO ChangeShare IN ProcReservat WITH l_nMode, "reservat"
                              = avLupdat()
                              DO UpdateShareRes IN ProcReservat WITH "reservat"
                              l_Autofound = .T.
                          ELSE
                              REPLACE reServat.rs_roomnum WITH l_oResOld.rs_roomnum
                          ENDIF
                          EXIT
                     ENDIF
                     SELECT roOm
                ENDSCAN
                SET ORDER IN "room" TO 1
                SELECT reServat
           ENDIF
           IF l_Autofound
                l_Found = l_Found+1
           ELSE
                l_Notfound = l_Notfound+1
           ENDIF
           WAIT WINDOW NOWAIT LTRIM(STR(l_Found))+"/"+ ;
                LTRIM(STR(l_Notfound))+"..."
      ENDSCAN
      WAIT CLEAR
 ENDIF
 = alErt(GetLangText("RESERV2","TA_AUTOFOUND")+" "+LTRIM(STR(l_Found))+";"+ ;
   GetLangText("RESERV2","TA_AUTONOTFOUND")+" "+LTRIM(STR(l_Notfound))+"!")
 GOTO l_Oldrsrec IN "reservat"
 SET ORDER IN "reservat" TO l_OldRsOrd
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
FUNCTION RsRoomList
IF g_NewVersionActive
      doform("roomlist","forms\roomlist")
ELSE
      doform('roomlist','forms\roomlist with 1')
ENDIF

RETURN
 PRIVATE nrLoldarea
 PRIVATE nrLoldrecord
 PRIVATE nrLoldorder
 PRIVATE cfOr, cwHile
 PRIVATE daRrival, cgRoup, crOomtype, laSsigned
 PRIVATE acRlfields
 DIMENSION acRlfields[9, 3]
 acRlfields[1, 1] = "Reservat.Rs_RoomTyp"
 acRlfields[1, 2] = 6
 acRlfields[1, 3] = GetLangText("RESERV2","TH_ROOMTYPE")
 acRlfields[2, 1] = "Reservat.Rs_RoomNum"
 acRlfields[2, 2] = 6
 acRlfields[2, 3] = GetLangText("RESERV2","TH_ROOMNUM")
 acRlfields[3, 1] = "Reservat.Rs_ArrDate"
 acRlfields[3, 2] = siZedate()
 acRlfields[3, 3] = GetLangText("RESERV2","TH_ARRDATE")
 acRlfields[4, 1] = "Reservat.Rs_DepDate"
 acRlfields[4, 2] = siZedate()
 acRlfields[4, 3] = GetLangText("RESERV2","TH_DEPDATE")
 acRlfields[5, 1] = "Reservat.Rs_Status"
 acRlfields[5, 2] = 5
 acRlfields[5, 3] = "Stat"
 acRlfields[6, 1] =  ;
           "Trim(Address.Ad_lName) + ', ' + Trim(Address.Ad_Title) + ' ' + Trim(Address.Ad_fName)"
 acRlfields[6, 2] = 25
 acRlfields[6, 3] = GetLangText("RESERV2","TH_LNAME")
 acRlfields[7, 1] = "Reservat.Rs_Adults"
 acRlfields[7, 2] = 6
 acRlfields[7, 3] = GetLangText("RESERV2","TH_ADULTS")
 acRlfields[8, 1] = "Reservat.Rs_Childs"
 acRlfields[8, 2] = 6
 acRlfields[8, 3] = GetLangText("RESERV2","TH_CHILDS")
 acRlfields[9, 1] = "Trim(Reservat.Rs_Group)"
 acRlfields[9, 2] = 15
 acRlfields[9, 3] = GetLangText("RESERV2","TH_GROUP")
 daRrival = sySdate()
 cgRoup = ""
 crOomtype = ""
 laSsigned = .F.
 nrLoldarea = SELECT()
 nrLoldorder = ORDER("Reservat")
 nrLoldrecord = RECNO("Reservat")
 SELECT reServat
 IF rlIstdialog(@daRrival,@cgRoup,@crOomtype,@laSsigned)
      cwHile = 'rs_arrdate = '+sqLcnv(daRrival)
      cfOr = 'rs_rooms = 1 and DbLookup("RoomType", "Tag1", rs_roomtyp, "rt_group") <> 2 and Empty(Rs_In) and Empty(Rs_Out) and !Inlist(rs_status, "CXL", "NS")'
      IF  .NOT. EMPTY(cgRoup)
           cfOr = sqLand(cfOr,"rs_group = "+sqLcnv(cgRoup))
      ENDIF
      IF  .NOT. EMPTY(crOomtype)
           cfOr = sqLand(cfOr,"rs_roomtyp = "+sqLcnv(crOomtype))
      ENDIF
      IF  .NOT. laSsigned
           cfOr = sqLand(cfOr,"Empty(rs_roomnum)")
      ENDIF
      SELECT reServat
      SET ORDER IN "Reservat" TO 8
      = SEEK(DTOS(daRrival), "Reservat")
      locate rest for &cFor while &cWhile
      IF ( .NOT. FOUND("Reservat"))
           = alErt(GetLangText("RESERV2","TA_NOARRIVAL")+"!")
      ELSE
           clEvel = "RLED"
           cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+ ;
                      "\!"+buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+ ;
                      buTton(clEvel,GetLangText("RESERV2","TXT_AUTO"),-3)
           crS3button = gcButtonfunction
           gcButtonfunction = ""
           = myBrowse("0026>"+GetLangText("RESERV2","TW_ROOMLIST"),20, ;
             @acRlfields,cfOr,cwHile,cbUttons,"vRlControl","RESERV2")
           gcButtonfunction = crS3button
      ENDIF
 ENDIF
 SET ORDER IN "Reservat" TO nRlOldOrder
 GOTO nrLoldrecord IN "Reservat"
 SELECT (nrLoldarea)
 RETURN .T.
ENDFUNC
*
FUNCTION vRlControl
 PARAMETER nrLchoice
 DO CASE
      CASE nrLchoice==1
      CASE nrLchoice==2
           = scRroomlist()
           g_Refreshcurr = .T.
      CASE nrLchoice==3
           IF (yeSno(GetLangText("RESERV2","TXT_ASSIGN_ROOM_NUMBERS")))
                DO auToroom WITH M.daRrival, 0, M.cfOr
           ENDIF
           g_Refreshall = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE ScrRoomlist
 PRIVATE l_Row
 l_Row = ncUrline+piXv(3)
 PRIVATE nrLcolumn
 PRIVATE nsColdarea
 PRIVATE nsCrecord
 SET READBORDER OFF
 nrLcolumn = piXh(1)
 nsColdarea = SELECT()
 nsCrecord = RECNO("reservat")
 SELECT reServat
 SCATTER MEMO MEMVAR
 @ l_Row, nrLcolumn GET M.rs_roomtyp SIZE 1, 6 PICTURE "@K !!!!" VALID  ;
   vrOomtype(l_Row,9) .AND. voVerbook() .AND. vsHowroom()
 nrLcolumn = nrLcolumn+6+piXh(1)
 @ l_Row, nrLcolumn GET M.rs_roomnum SIZE 1, 6 PICTURE "@K !!!!" VALID  ;
   vrOomnum(l_Row,2)
 nrLcolumn = nrLcolumn+6+piXh(1)
 @ l_Row, nrLcolumn GET M.rs_arrdate SIZE 1, siZedate() PICTURE "@KD"  ;
   VALID  .NOT. EMPTY(M.rs_arrdate)
 nrLcolumn = nrLcolumn+siZedate()+piXh(1)
 @ l_Row, nrLcolumn GET M.rs_depdate SIZE 1, siZedate() PICTURE "@KD"  ;
   VALID  .NOT. EMPTY(M.rs_depdate) .AND. M.rs_depdate>=M.rs_arrdate
 READ VALID vcLearroom() MODAL
 SET READBORDER ON
 IF LASTKEY()<>27
      = avLsave()
      GOTO nsCrecord IN "reservat"
      GATHER MEMO MEMVAR
      = avLupdat()
 ENDIF
 SELECT (nsColdarea)
 RETURN
ENDPROC
*
FUNCTION vShowRoom
 PRIVATE ALL LIKE l_*
 l_Oldarea = SELECT()
 l_Line = 0
 l_Arrival = M.rs_arrdate
 l_Departure = M.rs_depdate
 l_Roomtype = M.rs_roomtyp
 l_Count = 0
 l_Prevwin = WONTOP()
 SELECT roOm
 SET ORDER IN "room" TO 2
 SEEK l_Roomtype
 l_Row = IIF(g_Nscreenmode==1, 1, 8)
 l_Col = IIF(g_Nscreenmode==1, 1, 4)
 l_To = IIF(g_Nscreenmode==1, 24, 28)
 IF  .NOT. WEXIST('wShowRoom')
      DEFINE WINDOW wsHowroom FROM l_Row, l_Col TO l_To, 25.000 FONT  ;
             "Arial", 10 NOFLOAT NOCLOSE NOZOOM TITLE GetLangText("RESERV2", ;
             "TW_AVAILROOMS") HALFHEIGHT NOMDI
 ENDIF
 ACTIVATE WINDOW wsHowroom
 CLEAR
 DO WHILE (roOm.rm_roomtyp=l_Roomtype .AND. l_Count<=18)
      SELECT roOmplan
      SET ORDER TO 1
      SET NEAR ON
      SEEK roOm.rm_roomnum+DTOS(l_Arrival)
      SET NEAR OFF
      LOCATE REST WHILE rp_roomnum=roOm.rm_roomnum .AND. rp_date<l_Departure
      IF ( .NOT. FOUND("RoomPlan"))
           @ l_Line, 1 SAY roOm.rm_roomnum SIZE 1, 6
           @ l_Line, 8 SAY roOm.rm_roomtyp SIZE 1, 6
           @ l_Line, 15 SAY roOm.rm_status SIZE 1, 6
           l_Line = l_Line+1
           l_Count = l_Count+1
      ENDIF
      SELECT roOm
      SKIP 1
 ENDDO
 SET ORDER IN "Room" TO 1
 SELECT (l_Oldarea)
 ACTIVATE WINDOW (l_Prevwin)
 RETURN .T.
ENDFUNC
*
FUNCTION RListDialog
 PARAMETER pdArrival, pcGroup, pcRoomtype, plAssigned
 PRIVATE adLg, lrEt
 DIMENSION adLg[4, 8]
 adLg[1, 1] = "arrival"
 adLg[1, 2] = GetLangText("RESERV2","T_ARRIVAL")
 adLg[1, 3] = "SysDate()"
 adLg[1, 4] = ""
 adLg[1, 5] = siZedate()
 adLg[1, 6] = "arrival >= SysDate()"
 adLg[1, 7] = ""
 adLg[1, 8] = {}
 adLg[2, 1] = "group"
 adLg[2, 2] = GetLangText("RESERV2","TH_GROUP")
 adLg[2, 3] = "[]"
 adLg[2, 4] = REPLICATE('!', 20)
 adLg[2, 5] = 20
 adLg[2, 6] = ""
 adLg[2, 7] = ""
 adLg[2, 8] = ""
 adLg[3, 1] = "roomtype"
 adLg[3, 2] = GetLangText("RESERV2","TH_ROOMTYPE")
 adLg[3, 3] = "[]"
 adLg[3, 4] = '!!!!'
 adLg[3, 5] = 6
 adLg[3, 6] = ""
 adLg[3, 7] = ""
 adLg[3, 8] = ""
 adLg[4, 1] = "assigned"
 adLg[4, 2] = GetLangText("RESERV2","TXT_INCL_ASSIGNED_ROOMS")
 adLg[4, 3] = ".f."
 adLg[4, 4] = "@*C"
 adLg[4, 5] = 20
 adLg[4, 6] = ""
 adLg[4, 7] = ""
 adLg[4, 8] = .F.
 IF diAlog(GetLangText("RESERV2","TW_RLIST"),"",@adLg)
      pdArrival = adLg(1,8)
      pcGroup = UPPER(ALLTRIM(adLg(2,8)))
      pcRoomtype = UPPER(ALLTRIM(adLg(3,8)))
      plAssigned = adLg(4,8)
      lrEt = .T.
 ELSE
      lrEt = .F.
 ENDIF
 RETURN lrEt
ENDFUNC
*
PROCEDURE QEInfo
 PRIVATE naRea, niD, cgRp, nrSord, nrSrec, arT, nrTsize, nrTpos, arOoms
 PRIVATE i, naSg, nuNasg, nrOw, ncOl, cmDclose
 nrTsize = 0
 naRea = SELECT()
 SELECT reServat
 niD = INT(rs_reserid)
 cgRp = rs_group
 nrSord = ORDER()
 nrSrec = RECNO()
 SET ORDER TO 1
 LOCATE ALL FOR rs_reserid>=niD .AND. rs_group=cgRp
 SCAN REST FOR rs_group=cgRp WHILE rs_reserid<niD+1
      IF nrTsize=0
           DIMENSION arT[1]
           nrTsize = 1
           arT[1] = rs_roomtyp
           nrTpos = 1
           DIMENSION arOoms[1, 2]
           arOoms[nrTsize, 1] = 0
           arOoms[nrTsize, 2] = 0
      ELSE
           nrTpos = ASCAN(arT, rs_roomtyp)
           IF nrTpos=0
                nrTsize = nrTsize+1
                nrTpos = nrTsize
                DIMENSION arT[nrTsize]
                arT[nrTsize] = rs_roomtyp
                DIMENSION arOoms[nrTsize, 2]
                arOoms[nrTsize, 1] = 0
                arOoms[nrTsize, 2] = 0
           ENDIF
      ENDIF
      IF EMPTY(rs_roomnum)
           arOoms[nrTpos, 2] = arOoms(nrTpos,2)+rs_rooms
      ELSE
           arOoms[nrTpos, 1] = arOoms(nrTpos,1)+rs_rooms
      ENDIF
 ENDSCAN
 SET ORDER TO nRsOrd
 GOTO nrSrec
 SELECT (naRea)
 IF nrTsize>0
      DEFINE WINDOW wqEinfo FROM 0, 0 TO 5+nrTsize*2, 30.000 FONT "Arial",  ;
             10 NOCLOSE NOZOOM TITLE GetLangText("RESERV2","TW_INFO") NOMDI
      ACTIVATE WINDOW NOSHOW wqEinfo
      MOVE WINDOW wqEinfo CENTER
      nrOw = 0.25
      @ nrOw, 5 SAY GetLangText("RESERV2","T_ASSIGNED")
      @ nrOw, 15 SAY GetLangText("RESERV2","T_UNASSIGNED")
      naSg = 0
      nuNasg = 0
      FOR i = 1 TO nrTsize
           nrOw = 0.25+i*1.25
           @ nrOw, 1 SAY arT(i) SIZE 1, 5
           @ nrOw, 5 SAY arOoms(i,1) SIZE 1, 5 COLOR RGB(0,0,255,192,192,192)
           @ nrOw, 15 SAY arOoms(i,2) SIZE 1, 5 COLOR RGB(0,0,255,192,192,192)
           naSg = naSg+arOoms(i,1)
           nuNasg = nuNasg+arOoms(i,2)
      ENDFOR
      nrOw = nrOw+1.25
      @ nrOw, 1 TO nrOw, WCOLS()-1 COLOR RGB(128,128,128)
      nrOw = nrOw+piXv(1)
      @ nrOw, 1 TO nrOw, WCOLS()-1 COLOR RGB(255,255,255)
      nrOw = nrOw+0.25
      @ nrOw, 5 SAY naSg SIZE 1, 5 COLOR RGB(0,0,255,192,192,192)
      @ nrOw, 15 SAY nuNasg SIZE 1, 5 COLOR RGB(0,0,255,192,192,192)
      nrOw = WROWS()-2
      ncOl = (WCOLS()-15)/2
      @ nrOw, ncOl GET cmDclose DEFAULT 0 SIZE 1.5, 15 PICTURE '@* '+ ;
        GetLangText("COMMON","TXT_CLOSE")
      PUSH KEY CLEAR
      READ MODAL
      POP KEY
      RELEASE WINDOW wqEinfo
 ENDIF
ENDPROC
*
