*
FUNCTION PhoneList
*
doform("frmPhone","forms\viewPhone")
RETURN
*
 PRIVATE cbUttons, naRea
 PRIVATE acFields
 naRea = SELECT()
 DIMENSION acFields[9, 3]
 acFields[1, 1] = "Phone"
 acFields[1, 2] = 8
 acFields[1, 3] = GetLangText("PHONE","TXT_PHONE")
 acFields[2, 1] = "Room"
 acFields[2, 2] = 12
 acFields[2, 3] = GetLangText("PHONE","TXT_ROOM")
 acFields[3, 1] = "Guest"
 acFields[3, 2] = 25
 acFields[3, 3] = GetLangText("PHONE","TXT_GUEST")
 acFields[4, 1] = "Hotel"
 acFields[4, 2] = 8
 acFields[4, 3] = GetLangText("PHONE","TXT_HOTEL")
 acFields[5, 1] = "Ifc"
 acFields[5, 2] = 8
 acFields[5, 3] = GetLangText("PHONE","TXT_IFC")
 acFields[6, 1] = "Action"
 acFields[6, 2] = 8
 acFields[6, 3] = GetLangText("PHONE","TXT_ACTION")
 acFields[7, 1] = "Message"
 acFields[7, 2] = 8
 acFields[7, 3] = GetLangText("PHONE","TXT_MESSAGE")
 acFields[8, 1] = "SomeData"
 acFields[8, 2] = 8
 acFields[8, 3] = GetLangText("PHONE","TXT_SOMEDATA")
 acFields[9, 1] = "ReserID"
 acFields[9, 2] = 15
 acFields[9, 3] = GetLangText("PHONE","TXT_RESERID")
 cbUttons = "\?"+GetLangText("COMMON","TXT_CLOSE")+";"+GetLangText("PHONE", ;
            "TXT_SEARCH")+";"+GetLangText("PHONE","TXT_LOCK")+";"+GetLangText("PHONE", ;
            "TXT_UNLOCK")+";"+GetLangText("PHONE","TXT_KEYMESSAGE")+";"+ ;
            GetLangText("PHONE","TXT_REFRESH")
 = reAdphonenumbers()
 IF USED('TmpPhone')
      SELECT tmPphone
      GOTO TOP
      cpH1button = gcButtonfunction
      gcButtonfunction = ""
      DO myBrowse WITH GetLangText("PHONE","TXT_CAPTION"), 20, acFields, ".t.",  ;
         ".t.", cbUttons, "vPhoneControl", "PHONE"
      gcButtonfunction = cpH1button
      USE IN tmPphone
 ENDIF
 SELECT (naRea)
 RETURN .T.
ENDFUNC
*
PROCEDURE ReadPhoneNumbers
 PRIVATE neNd
 PRIVATE cfIlename
 PRIVATE naRea, nrMrec, nrSord, nrSrec
 PRIVATE cpHones
 LOCAL l_cSql, l_cCurName
 WAIT WINDOW NOWAIT GetLangText("PHONE","TXT_READSTATUSPLEASEWAIT")
 nrSord = ORDER("Reservat")
 nrSrec = RECNO("Reservat")
 naRea = SELECT()
 nrMrec = RECNO("Room")
 = crEatetmpphonefile()
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
      SELECT rs_reserid, rs_lname, rs_roomnum, rs_arrdate, rs_depdate ;
           FROM reservat ;
           WHERE rs_in+rs_roomnum+rs_out = <<sqlcnv("1",.T.)>> AND EMPTY(rs_out)
 ENDTEXT
 l_cCurName = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
 SELECT roOm
 GOTO TOP IN roOm
 DO WHILE ( .NOT. EOF("Room"))
      IF ( .NOT. EMPTY(roOm.rm_phone))
           SELECT tmPphone
           SCATTER BLANK MEMVAR
           M.roOm = ALLTRIM(roOm.rm_roomnum)
           M.meSsage = IIF(EMPTY(roOm.rs_message), "", "MSG")
           IF dlocate(l_cCurName,"rs_roomnum = " + sqlcnv(PADR(M.roOm,4)))
                M.guEst = &l_cCurName..rs_lname
                M.reSerid = &l_cCurName..rs_reserid
                M.hoTel = "IN"
                M.guestname = &l_cCurName..rs_lname
                M.arrival = &l_cCurName..rs_arrdate
                M.departure = &l_cCurName..rs_depdate
           ELSE
                M.guEst = ""
                M.reSerid = 0
                M.hoTel = "OUT"
                M.guestname = ""
                M.arrival = ""
                M.departure = ""
           ENDIF
           M.roomnum = room.rm_roomnum
           IF NOT EMPTY(roOm.rm_rmname)
                M.roOm = ALLTRIM(roOm.rm_rmname)
           ENDIF
           cpHones = ALLTRIM(roOm.rm_phone)+","
           neNd = AT(",", cpHones)
           DO WHILE (neNd>0)
                M.phOne = ALLTRIM(SUBSTR(cpHones, 1, neNd-1))
                M.ifC = ""
                M.acTion = ""
                M.soMedata = ""
                IF ( .NOT. EMPTY(M.phOne))
                     IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+M.phOne+".IN"))
                          M.ifC = "IN"
                     ENDIF
                     IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+M.phOne+".OUT"))
                          M.ifC = "OUT"
                     ENDIF
                     IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+M.phOne+".ACT"))
                          M.acTion = "ACT"
                     ENDIF
                     IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+M.phOne+".DAT"))
                          M.soMedata = "DAT"
                     ENDIF
                ENDIF
                SELECT tmPphone
                APPEND BLANK
                GATHER MEMVAR
                cpHones = SUBSTR(cpHones, neNd+1)
                neNd = AT(",", cpHones)
           ENDDO
      ENDIF
      SKIP 1 IN roOm
 ENDDO
 WAIT CLEAR
 SET ORDER IN reServat TO nRsOrd
 GOTO nrSrec IN reServat
 GOTO nrMrec IN roOm
 dclose(l_cCurName)
 SELECT (naRea)
 RETURN
ENDPROC
*
FUNCTION UpdatePhone
 PRIVATE nrEcord, cOrder
 WAIT WINDOW NOWAIT GetLangText("PHONE","TXT_READSTATUSPLEASEWAIT")
 SELECT tmPphone
 nrEcord = RECNO()
 cOrder = ORDER("room")
 SET ORDER TO Tag5 IN room
 SET RELATION TO roOm INTO roOm
 GOTO TOP
 DO WHILE ( .NOT. EOF())
      SCATTER MEMVAR
      M.ifC = ""
      M.soMedata = ""
      M.acTion = ""
      M.meSsage = IIF(EMPTY(roOm.rs_message), "", "MSG")
      IF ( .NOT. EMPTY(M.phOne))
           IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+ALLTRIM(M.phOne)+".IN"))
                M.ifC = "IN"
           ENDIF
           IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+ALLTRIM(M.phOne)+".OUT"))
                M.ifC = "OUT"
           ENDIF
           IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+ALLTRIM(M.phOne)+".ACT"))
                M.acTion = "ACT"
           ENDIF
           IF (FILE(_screen.oGlobal.choteldir+"ifc\PTT\"+ALLTRIM(M.phOne)+".DAT"))
                M.soMedata = "DAT"
           ENDIF
      ENDIF
      GATHER MEMVAR
      SKIP 1
 ENDDO
 SET RELATION TO
 SET ORDER TO cOrder IN room
 GOTO nrEcord
 g_Refreshall = .T.
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION CreateTmpPhoneFile
 PARAMETER cfIlename
 CREATE CURSOR TmpPhone (phOne C (4), roOm C (10), guEst C (25), hoTel C  ;
        (3), ifC C (6), acTion C (3), meSsage C (3), soMedata C (3),  ;
        reSerid N (12, 3), guestname c(30), arrival D, departure D, roomnum C(4))
 INDEX ON phOne TAG phOne
 INDEX ON roOm TAG roOm
 SET ORDER TO 1
 RETURN .T.
ENDFUNC
*
FUNCTION vPhoneControl
 PARAMETER ncHoice
 PRIVATE cgUest
 PRIVATE noRderaddress
 PRIVATE noRderreservat
 PRIVATE lrEfresh
 PRIVATE nrEserid
 PRIVATE crOom
 PRIVATE nsElect
 lrEfresh = .T.
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           IF ( .NOT. phOnesearch())
                lrEfresh = .F.
           ENDIF
      CASE ncHoice==3
           nrEserid = reSerid
           crOom = roOm
           SELECT reServat
           noRderreservat = ORDER()
           SET ORDER TO 1
           SEEK nrEserid
           DO ifCcheck IN Interfac WITH Get_rm_roomnum(crOom), "CHECKOUT"
           SET ORDER TO nOrderReservat
      CASE ncHoice==4
           IF ( .NOT. paRam.pa_pttchk .OR. hoTel=="IN" .OR. usEr.us_group== ;
              "SUPERVISOR")
                nrEserid = reSerid
                crOom = roOm
                SELECT reServat
                noRderreservat = ORDER()
                SET ORDER TO 1
                SEEK nrEserid
                DO ifCcheck IN Interfac WITH Get_rm_roomnum(crOom), "CHECKIN"
                SELECT reServat
                SET ORDER TO nOrderReservat
           ELSE
                = alErt(GetLangText("PHONE","TXT_NOTALLOWED"))
           ENDIF
      CASE ncHoice==5
           cgUest = guEst
           crOom = roOm
           IF ( .NOT. EMPTY(cgUest))
				LOCAL llFound
				llFound = .F.
                IF (SEEK(cgUest, "Address","tag2"))
		        	llFound = .T.
		        ELSE
		        	IF NOT EMPTY(TmpPhone.reSerid)
		        		IF SEEK(TmpPhone.reSerid,"reservat","tag1")
		        			IF reservat.rs_addrid = reservat.rs_compid AND ;
		        				NOT EMPTY(reservat.rs_apname)
				                IF (SEEK(cgUest, "apartner","tag2"))
						        	llFound = .T.
						        ENDIF
		        			ENDIF
		        		ENDIF
		        	ENDIF
		        ENDIF
				IF llFound
		             LOCAL loForm
		             loForm = NULL
		             DO FORM forms\msgedit NAME loForm LINKED WITH 2, TmpPhone.reSerid
		             RELEASE loForm
                ENDIF
           ELSE
                = alErt(GetLangText("PHONE","TXT_NOTCHECKEDIN"))
           ENDIF
      CASE ncHoice==6
 ENDCASE
 IF (lrEfresh)
      = upDatephone()
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION LockUnLock
*
	doform("frmLockUnlock","forms\viewphone with 2")
	RETURN
*
 PRIVATE daRr
 PRIVATE ncHoice
 PRIVATE ddEp
 PRIVATE cgUest
 PRIVATE cpHonenumber
 PRIVATE crOomnumber
 PRIVATE croomname
 PRIVATE csTatus
 = phOnewindow(0)
 DO WHILE (.T.)
      daRr = DATE()
      ncHoice = 1
      ddEp = DATE()
      cgUest = SPACE(10)
      ciFcstatus = SPACE(3)
      cpHonenumber = SPACE(4)
      crOomnumber = SPACE(4)
      croomname = SPACE(10)
      csTatus = SPACE(3)
      = txTpanel(0.50,2,20,GetLangText("PHONE","TXT_ROOMNUMBER"),18)
      = txTpanel(1.75,2,20,GetLangText("PHONE","TXT_PHONENUMBER"),18)
      = txTpanel(3.00,2,20,GetLangText("PHONE","TXT_GUESTNAME"),18)
      = txTpanel(4.25,2,20,GetLangText("PHONE","TXT_STATUS"),18)
      = txTpanel(5.50,2,20,GetLangText("PHONE","TXT_IFCSTATUS"),18)
      = txTpanel(6.75,2,20,GetLangText("PHONE","TXT_ARRIVAL"),18)
      = txTpanel(8.00,2,20,GetLangText("PHONE","TXT_DEPARTURE"),18)
      @ 0.500, 24 GET croomname SIZE 1, 10 PICTURE "@K !!!!!!!!!!" VALID  ;
        vsetroomnum(croomname) .AND. vrOomdata(.F.,@crOomnumber,@cpHonenumber,@cgUest,@daRr,@ddEp, ;
        @csTatus,@ciFcstatus)
      @ 1.750, 24 GET cpHonenumber SIZE 1, 10 PICTURE "@K !!!!" VALID  ;
        vrOomdata(.T.,@crOomnumber,@cpHonenumber,@cgUest,@daRr,@ddEp, ;
        @csTatus,@ciFcstatus) WHEN EMPTY(crOomnumber)
      @ 3.000, 24 GET cgUest STYLE "B" SIZE 1, 30 WHEN .F.
      @ 4.250, 24 GET csTatus STYLE "B" SIZE 1, 5 WHEN .F.
      @ 5.500, 24 GET ciFcstatus STYLE "B" SIZE 1, 5 WHEN .F.
      @ 6.750, 24 GET daRr STYLE "B" SIZE 1, siZedate() WHEN .F.
      @ 8.000, 24 GET ddEp STYLE "B" SIZE 1, siZedate() WHEN .F.
      @ 0.500, 65 GET ncHoice STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
        "*"+"V" PICTURE "\?"+GetLangText("COMMON","TXT_CLOSE")+";\!"+ ;
        GetLangText("PHONE","TXT_LOCK")+";"+GetLangText("PHONE","TXT_UNLOCK")
      READ CYCLE MODAL
      DO CASE
           CASE ncHoice==1
                EXIT
           CASE ncHoice==2
                DO ifCcheck IN Interfac WITH crOomnumber, "CHECKOUT"
           CASE ncHoice==3
                IF ( .NOT. paRam.pa_pttchk .OR. csTatus=="IN")
                     DO ifCcheck IN Interfac WITH crOomnumber, "CHECKIN"
                ELSE
                     = alErt(GetLangText("PHONE","TXT_NOTALLOWED"))
                ENDIF
      ENDCASE
 ENDDO
 = phOnewindow(1)
 RETURN .T.
ENDFUNC
*
FUNCTION PhoneWindow
 PARAMETER naCtivate
 IF (naCtivate==0)
      DEFINE WINDOW wpHone AT 0, 0 SIZE 10, 82 FONT "Arial", 10 NOGROW  ;
             NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("PHONE", ;
             "TXT_LOCKCAPTION")) SYSTEM
      MOVE WINDOW wpHone CENTER
      ACTIVATE WINDOW wpHone
 ELSE
      DEACTIVATE WINDOW wpHone
      RELEASE WINDOW wpHone
      = chIldtitle("")
      lwEredone = .T.
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION vRoomData
 PARAMETER lfRomphone, cnUmber, cpHone, cgUest, daRrival, ddEparture,  ;
           csTat, ciFc
 PRIVATE lfOund
 PRIVATE loK
 PRIVATE noRderroom
 PRIVATE noRderreservat
 PRIVATE npOs
 IF ( .NOT. lfRomphone)
      cpHone = ""
 ENDIF
 lfOund = .F.
 noRderroom = ORDER("Room")
 loK = .F.
 DO CASE
      CASE LASTKEY()==27 .OR. EMPTY(cnUmber+cpHone)
           loK = .T.
      CASE  .NOT. lfRomphone .AND. EMPTY(cnUmber)
           loK = .T.
      OTHERWISE
           SELECT roOm
           IF ( .NOT. EMPTY(cnUmber))
                SET ORDER TO 1
                IF ( .NOT. SEEK(cnUmber, "Room"))
                     crEaderror = GetLangText("PHONE","TXT_NOTAROOM")
                ELSE
                     lfOund = .T.
                ENDIF
           ELSE
                IF (EMPTY(cpHone))
                     loK = .T.
                ELSE
                     LOCATE FOR roOm.rm_phone=cpHone
                     IF (FOUND())
                          lfOund = .T.
                     ELSE
                          LOCATE FOR TRIM(cpHone)+","$roOm.rm_phone
                          IF (FOUND())
                               lfOund = .T.
                          ELSE
                               LOCATE FOR ","+TRIM(cpHone)$roOm.rm_phone
                               IF (FOUND())
                                    lfOund = .T.
                               ENDIF
                          ENDIF
                     ENDIF
                ENDIF
           ENDIF
           IF (lfOund)
                IF (EMPTY(cpHone))
                     npOs = AT(',', roOm.rm_phone)
                     IF npOs>0
                          cpHone = TRIM(SUBSTR(roOm.rm_phone, 1, npOs-1))
                     ELSE
                          cpHone = TRIM(roOm.rm_phone)
                     ENDIF
                ELSE
                     cpHone = TRIM(cpHone)
                     cnUmber = roOm.rm_roomnum
                ENDIF
                SELECT reServat
                noRderreservat = ORDER("Reservat")
                SET ORDER TO 6
                IF (SEEK("1"+cnUmber) .AND. EMPTY(reServat.rs_out))
                     cgUest = reServat.rs_lname
                     daRrival = reServat.rs_arrdate
                     ddEparture = reServat.rs_depdate
                     csTat = "IN"
                ELSE
                     cgUest = ""
                     daRrival = {}
                     ddEparture = {}
                     csTat = "OUT"
                ENDIF
                loK = .T.
                DO CASE
                     CASE FILE(_screen.oGlobal.choteldir+"ifc\Ptt\"+cpHone+".IN")
                          ciFc = "IN"
                     CASE FILE(_screen.oGlobal.choteldir+"ifc\Ptt\"+cpHone+".OUT")
                          ciFc = "OUT"
                     OTHERWISE
                          ciFc = "???"
                ENDCASE
                SET ORDER TO nOrderReservat
           ENDIF
 ENDCASE
 SELECT roOm
 SET ORDER TO nOrderRoom
 SHOW GETS
 RETURN loK
ENDFUNC
*
FUNCTION PhoneSearch
 PRIVATE lfOund
 PRIVATE crOom
 PRIVATE nrEcord
 PRIVATE nsElect
 lfOund = .F.
 nsElect = SELECT()
 SELECT tmPphone
 crOom = SPACE(4)
 nrEcord = RECNO()
 DEFINE WINDOW wsEarchphone AT 0, 0 SIZE 3, 40 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("PHONE","TXT_PHONESEARCH")) NOMDI DOUBLE
 MOVE WINDOW wsEarchphone CENTER
 ACTIVATE WINDOW wsEarchphone
 DO paNel WITH 1/4, 2/3, WROWS()-(0.25), WCOLS()-(0.666666666666667)
 = txTpanel(1,4,20,GetLangText("PHONE","TXT_PHONENUMBER"),17)
 DO WHILE ( .NOT. lfOund)
      @ 1, 25 GET crOom SIZE 1, 10 PICTURE "@K !!!!"
      READ MODAL
      IF (LASTKEY()==27)
           EXIT
      ENDIF
      SET NEAR ON
      SEEK ALLTRIM(crOom)
      lfOund =  .NOT. EOF()
 ENDDO
 IF ( .NOT. lfOund)
      GOTO nrEcord
 ENDIF
 SET NEAR OFF
 SELECT (nsElect)
 RELEASE WINDOW wsEarchphone
 = chIldtitle("")
 RETURN lfOund
ENDFUNC
*
FUNCTION vsetroomnum
 LPARAMETERS pcroomname
 * crOomnumber is private variable
 crOomnumber = get_rm_roomnum(pcroomname)
 RETURN .T.
ENDFUNC
*