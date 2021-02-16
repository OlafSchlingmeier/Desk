*
FUNCTION Recurring
 PRIVATE nfRequency
 PRIVATE noNoccurence
 PRIVATE lsHeetcopy, nsHeetid
 naRearecurring = SELECT()
 SELECT reServat
 noRderreservat = ORDER()
 nrEcnoreservat = RECNO()
 ON READERROR
 nrEsid = reServat.rs_reserid
 nsElection = 1
 nfRequency = 0
 noNoccurence = 0
 ndAyoccurence = 0
 neVerydays = 0
 lsKipweekends = .F.
 dsTartdate = reServat.rs_arrdate
 deNddate = reServat.rs_depdate
 nnIghts = reServat.rs_depdate-reServat.rs_arrdate
 lsHeetcopy = .T.
 nsHeetid = reServat.rs_reserid
 = reCurwindow(0)
 = heLptext()
 = inFormation()
 @ 6, 4 SAY GetLangText("RECURRES","TXT_START_DATE")
 @ 6, 16 GET dsTartdate PICTURE "@K" VALID (dsTartdate>=sySdate()) ERROR  ;
   GetLangText("RECURRES","TXT_DATE_NOT_VALID")
 @ 7.250, 4 SAY GetLangText("RECURRES","TXT_END_DATE")
 @ 7.250, 16 GET deNddate PICTURE "@K" VALID (deNddate>=sySdate() .AND.  ;
   deNddate>=dsTartdate) ERROR GetLangText("RECURRES","TXT_DATE_NOT_VALID")
 @ 8.500, 4 GET lsHeetcopy PICTURE '@*C '+GetLangText("RECURRES","TXT_SHEETCOPY")
 cdAily = IIF( .NOT. EMPTY(SUBSTR(reServat.rs_arrtime, 1, 2)+ ;
          SUBSTR(reServat.rs_arrtime, 4, 2)+SUBSTR(reServat.rs_deptime, 1,  ;
          2)+SUBSTR(reServat.rs_deptime, 4, 2)), "", "\\")
 @ 6.500, 34 GET nfRequency FUNCTION "*R" PICTURE cdAily+GetLangText("RECURRES", ;
   "TXT_DAILY")+";"+GetLangText("RECURRES","TXT_WEEKLY")+";"+GetLangText("RECURRES", ;
   "TXT_BIWEEKLY")+";"+GetLangText("RECURRES","TXT_MONLY")+";"+GetLangText("RECURRES", ;
   "TXT_QUARTERLY")+";"+GetLangText("RECURRES","TXT_YEARLY")+";"+GetLangText("RECURRES", ;
   "TXT_EVERY") VALID diSableoccurence(nfRequency,neVerydays, ;
   @lsKipweekends,@noNoccurence,@ndAyoccurence)
 @ 12.500, 45 GET neVerydays SIZE 1, 4 VALID (diSableoccurence(nfRequency, ;
   neVerydays,@lsKipweekends,@noNoccurence,@ndAyoccurence) .AND.  ;
   neVerydays>nnIghts) WHEN nfRequency==7
 @ 12.500, 50 SAY GetLangText("RECURRES","TXT_DAYS")
 @ 14, 34 GET lsKipweekends FUNCTION "*C" PICTURE cdAily+GetLangText("RECURRES", ;
   "TXT_SKIP_WEEKENDS") VALID diSableoccurence(nfRequency,neVerydays, ;
   @lsKipweekends,@noNoccurence,@ndAyoccurence) WHEN nfRequency==1
 @ 6.500, 74 GET noNoccurence FUNCTION "*R" PICTURE GetLangText("RECURRES", ;
   "TXT_FIRST")+";"+GetLangText("RECURRES","TXT_SECOND")+";"+GetLangText("RECURRES", ;
   "TXT_THIRD")+";"+GetLangText("RECURRES","TXT_FOURTH")+";"+GetLangText("RECURRES", ;
   "TXT_LAST") VALID diSablefrequency(noNoccurence,@ndAyoccurence, ;
   @nfRequency,@neVerydays,@lsKipweekends,@dsTartdate)
 @ 6.500, 94 GET ndAyoccurence FUNCTION "*R" PICTURE myCdow(1)+";"+ ;
   myCdow(2)+";"+myCdow(3)+";"+myCdow(4)+";"+myCdow(5)+";"+myCdow(6)+";"+ ;
   myCdow(7)+";"+IIF(noNoccurence==5, "", "\\")+GetLangText("RECURRES", ;
   "TXT_DAY_FOR_LAST") VALID diSablefrequency(noNoccurence,@ndAyoccurence, ;
   @nfRequency,@neVerydays,@lsKipweekends,@dsTartdate)
 @ 18, 80 GET nsElection STYLE "B" SIZE nbUttonheight, 15 FUNCTION "*"+ ;
   "H" PICTURE GetLangText("RECURRES","TXT_CREATE")+";"+GetLangText("COMMON","TXT_CLOSE")
 READ MODAL
 = reCurwindow(1)
 IF (nsElection==1)
      = inFowindow("~"+GetLangText("RECURRES","TXT_CREAT_RESERVATIONS"))
      = inFowindow(GetLangText("RECURRES","TXT_PREPARE"))
      cfIlename = SYS(3)
      SELECT reServat
      COPY TO (cfIlename) STRUCTURE
      USE (cfIlename) ALIAS tmPrese IN 0
      IF (crEatereservations(dsTartdate,deNddate,nfRequency,neVerydays, ;
         lsKipweekends,noNoccurence,ndAyoccurence)=0)
           = inFowindow()
           = alErt(GetLangText("RECURRES","TXT_NO_RESERVATIONS_CREATED"))
      ELSE
           = inFowindow()
           = diSptmprese()
      ENDIF
      = clOsefile("TmpRese")
      = fiLedelete(cfIlename+'.DBF')
      = fiLedelete(cfIlename+'.FPT')
 ENDIF
 ON READERROR =WHATREAD()
 SELECT reServat
 SET ORDER TO nOrderReservat
 GOTO nrEcnoreservat
 SELECT (naRearecurring)
 RETURN .T.
ENDFUNC
*
FUNCTION RecurWindow
 PARAMETER naCtivate
 IF (naCtivate==0)
      DEFINE WINDOW wrEcurring AT 0, 0 SIZE 20, 120 FONT "Arial", 10  ;
             NOGROW NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("RECURRES", ;
             "TXT_RECURRING_RESERVATION")) SYSTEM
      MOVE WINDOW wrEcurring CENTER
      ACTIVATE WINDOW wrEcurring
      = paNelborder()
      = paNelborder(5,2,10.5,30,GetLangText("RECURRES","TXT_DATE_SPAN"))
      = paNelborder(11,2,16,30,GetLangText("RECURRES","TXT_INFORMATION"))
      = paNelborder(5,32,16,70,GetLangText("RECURRES","TXT_FIXED_FREQUENCY"))
      = paNelborder(5,72,16,115,GetLangText("RECURRES","TXT_MONTHLY_OCCURENCE"))
      = paNelborder(17,2,17.75,115)
 ELSE
      DEACTIVATE WINDOW wrEcurring
      RELEASE WINDOW wrEcurring
      = chIldtitle("")
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION helpText
 @ 1, 10 SAY GetLangText("RECURRES","TXT_HELP1")+" "+GetLangText("RECURRES","TXT_HELP2")
 @ 2.250, 10 SAY GetLangText("RECURRES","TXT_HELP3")+" "+GetLangText("RECURRES","TXT_HELP4")
 RETURN .T.
ENDFUNC
*
FUNCTION Information
 @ 12, 3 SAY GetLangText("RECURRES","TXT_NIGHTS")
 @ 12, 15 SAY STR(reServat.rs_depdate-reServat.rs_arrdate, 4, 0) STYLE "B"
 @ 13.250, 3 SAY GetLangText("RECURRES","TXT_ROOMTYPE")
 @ 13.250, 15 SAY reServat.rs_roomtyp STYLE "B"
 @ 14.500, 3 SAY GetLangText("RECURRES","TXT_ROOMNUMBER")
 @ 14.500, 15 SAY reServat.rs_roomnum STYLE "B"
 RETURN .T.
ENDFUNC
*
FUNCTION DisableOccurence
 PARAMETER nfRequency, neVerydays, lsKipweekends, noNoccurence, ndAyoccurence
 IF (nfRequency<>0 .OR. neVerydays<>0 .OR. lsKipweekends)
      noNoccurence = 0
      ndAyoccurence = 0
      SHOW GET noNoccurence
      SHOW GET ndAyoccurence
 ENDIF
 IF (nfRequency<>1)
      lsKipweekends = .F.
      SHOW GET lsKipweekends
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION DisableFrequency
 PARAMETER noNoccurence, ndAyoccurence, nfRequency, neVerydays,  ;
           lsKipweekends, dsTartdate
 IF (noNoccurence<>0 .OR. ndAyoccurence<>0)
      IF (ndAyoccurence==8 .AND. noNoccurence<>5)
           ndAyoccurence = 0
      ENDIF
      lsKipweekends = .F.
      nfRequency = 0
      neVerydays = 0
      SHOW GET nfRequency
      SHOW GET neVerydays
      SHOW GET lsKipweekends
      IF (ndAyoccurence==0)
           ndAyoccurence = DOW(dsTartdate)
      ELSE
           dsTartdate = daTeoccurence(dsTartdate,ndAyoccurence,noNoccurence)
      ENDIF
      IF (noNoccurence==5)
           SHOW OBJECT 25 ENABLE
      ELSE
           SHOW OBJECT 25 DISABLE
      ENDIF
      SHOW GET dsTartdate
      SHOW GET ndAyoccurence
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION CreateReservations
 PARAMETER dsTartdate, deNddate, nfRequency, neVerydays, lsKipweekends,  ;
           noNoccurence, ndAyoccurence
 PRIVATE niD
 PRIVATE nrEsorder
 PRIVATE nrEsrecord
 nnIghts = reServat.rs_depdate-reServat.rs_arrdate
 SELECT reServat
 nrEsorder = ORDER()
 nrEsrecord = RECNO()
 SET ORDER TO 1
 niD = reServat.rs_reserid
 ncOpies = 0
 DO CASE
      CASE nfRequency==0 .AND. noNoccurence<>0 .AND. ndAyoccurence<>0
           dtMpdate = daTeoccurence(dsTartdate,ndAyoccurence,noNoccurence)
           DO WHILE (dtMpdate<=deNddate)
                = apPendreservation(niD,dtMpdate)
                ncOpies = ncOpies+1
                dtMpdate = daTeoccurence(adDonemonth(dtMpdate), ;
                           ndAyoccurence,noNoccurence)
           ENDDO
      CASE nfRequency==1
           dtMpdate = dsTartdate
           DO WHILE (dtMpdate<=deNddate)
                IF ( .NOT. lsKipweekends .OR. (DOW(dtMpdate)<>1 .AND.  ;
                   DOW(dtMpdate)<>7))
                     = apPendreservation(niD,dtMpdate)
                     ncOpies = ncOpies+1
                ENDIF
                dtMpdate = dtMpdate+1
           ENDDO
      CASE nfRequency==2
           ncOpies = 0
           dtMpdate = dsTartdate
           DO WHILE (dtMpdate<=deNddate)
                = apPendreservation(niD,dtMpdate)
                dtMpdate = dtMpdate+7
                ncOpies = ncOpies+1
           ENDDO
      CASE nfRequency==3
           ncOpies = 0
           dtMpdate = dsTartdate
           DO WHILE (dtMpdate<=deNddate)
                = apPendreservation(niD,dtMpdate)
                dtMpdate = dtMpdate+14
                ncOpies = ncOpies+1
           ENDDO
      CASE nfRequency==4
           ncOpies = 0
           dtMpdate = dsTartdate
           DO WHILE (dtMpdate<=deNddate)
                = apPendreservation(niD,dtMpdate)
                dtMpdate = adDonemonth(dtMpdate)
                ncOpies = ncOpies+1
           ENDDO
      CASE nfRequency==5
           ncOpies = 0
           dtMpdate = dsTartdate
           DO WHILE (dtMpdate<=(deNddate-0091))
                = apPendreservation(niD,dtMpdate)
                dtMpdate = dtMpdate+0091
                ncOpies = ncOpies+1
           ENDDO
      CASE nfRequency==6
           ncOpies = 0
           dtMpdate = dsTartdate
           DO WHILE (dtMpdate<=deNddate)
                = apPendreservation(niD,dtMpdate)
                dtMpdate = adDoneyear(dtMpdate)
                ncOpies = ncOpies+1
           ENDDO
      CASE nfRequency==7
           ncOpies = 0
           dtMpdate = dsTartdate
           DO WHILE (dtMpdate<=deNddate)
                = apPendreservation(niD,dtMpdate)
                dtMpdate = dtMpdate+neVerydays
                ncOpies = ncOpies+1
           ENDDO
 ENDCASE
 = inFowindow(GetLangText("RECURRES","TXT_NUMBER_OF_COPIES")+STR(ncOpies))
 SELECT reServat
 SET ORDER TO nResOrder
 GOTO nrEsrecord
 RETURN ncOpies
ENDFUNC
*
FUNCTION AppendReservation
 PARAMETER nrEsid, dtMpdate
 PRIVATE ciNternalstatus
 PRIVATE ntHisid
 PRIVATE ctHeroom
 IF (reServat.rs_arrdate==dtMpdate)
      ntHisid = reServat.rs_reserid
 ELSE
      ntHisid = neXtid('RESERVAT')+0.1
 ENDIF
 SELECT reServat
 = dlOcate('Reservat','rs_reserid >= '+sqLcnv(INT(nrEsid))+ ;
   ' and rs_reserid < '+sqLcnv(INT(nrEsid)+1))
 DO WHILE (INT(nrEsid)==INT(reServat.rs_reserid) .AND.  .NOT. EOF("Reservat"))
      ctHeroom = reServat.rs_roomnum
      DO CASE
           CASE reServat.rs_arrdate==dtMpdate .AND. reServat.rs_roomnum== ;
                ctHeroom
                ciNternalstatus = GetLangText("RECURRES","TXT_PRIMAIRY_RESERVATION")
           CASE  .NOT. isAvail(dtMpdate,dtMpdate+(reServat.rs_depdate- ;
                 reServat.rs_arrdate),reServat.rs_arrtime, ;
                 reServat.rs_deptime,reServat.rs_roomtyp, ;
                 reServat.rs_rooms,@ctHeroom)
                ciNternalstatus = GetLangText("RECURRES","TXT_NOT_AVAILABLE")
           OTHERWISE
                IF (ctHeroom<>reServat.rs_roomnum)
                     ciNternalstatus = GetLangText("RECURRES", ;
                                       "TXT_ROOM_NOT_AVAILABLE")
                ELSE
                     ciNternalstatus = GetLangText("RECURRES","TXT_AVAILABLE")
                ENDIF
      ENDCASE
      = inFowindow(DTOS(dtMpdate)+" "+PROPER(ciNternalstatus))
      SELECT tmPrese
      APPEND BLANK
      REPLACE tmPrese.rs_addrid WITH reServat.rs_addrid
      REPLACE tmPrese.rs_adults WITH reServat.rs_adults
      REPLACE tmPrese.rs_agent WITH reServat.rs_agent
      REPLACE tmPrese.rs_agentid WITH reServat.rs_agentid
      REPLACE tmPrese.rs_arrtime WITH reServat.rs_arrtime
      REPLACE tmPrese.rs_arrdate WITH dtMpdate
      REPLACE tmPrese.rs_ccexpy WITH reServat.rs_ccexpy
      REPLACE tmPrese.rs_ccnum WITH reServat.rs_ccnum
      REPLACE tmPrese.rs_childs WITH reServat.rs_childs
      REPLACE tmPrese.rs_childs2 WITH reServat.rs_childs2
      REPLACE tmPrese.rs_childs3 WITH reServat.rs_childs3
      REPLACE tmPrese.rs_company WITH reServat.rs_company
      REPLACE tmPrese.rs_compid WITH reServat.rs_compid
      REPLACE tmPrese.rs_conres WITH reServat.rs_conres
      REPLACE tmPrese.rs_invid WITH reServat.rs_invid
      REPLACE tmPrese.rs_created WITH sySdate()
      REPLACE tmPrese.rs_depdate WITH dtMpdate+(reServat.rs_depdate- ;
              reServat.rs_arrdate)
      REPLACE tmPrese.rs_deptime WITH reServat.rs_deptime
      IF  .NOT. EMPTY(reServat.rs_optdate)
           REPLACE tmPrese.rs_optdate WITH tmPrese.rs_arrdate- ;
                   (reServat.rs_arrdate-reServat.rs_optdate)
      ENDIF
      REPLACE tmPrese.rs_group WITH reServat.rs_group
      REPLACE tmPrese.rs_lname WITH reServat.rs_lname
      REPLACE tmPrese.rs_market WITH reServat.rs_market
      REPLACE tmPrese.rs_note WITH reServat.rs_note
      REPLACE tmPrese.rs_paymeth WITH reServat.rs_paymeth
      REPLACE tmPrese.rs_rate WITH reServat.rs_rate
      REPLACE tmPrese.rs_ratecod WITH reServat.rs_ratecod
      REPLACE tmPrese.rs_recur WITH ""
      REPLACE tmPrese.rs_reserid WITH ntHisid
      REPLACE tmPrese.rs_roomnum WITH ctHeroom
      REPLACE tmPrese.rs_rooms WITH reServat.rs_rooms
      REPLACE tmPrese.rs_roomtyp WITH reServat.rs_roomtyp
      REPLACE tmPrese.rs_source WITH reServat.rs_source
      REPLACE tmPrese.rs_status WITH geTstatus(reServat.rs_status)
      REPLACE tmPrese.rs_updated WITH sySdate()
      REPLACE tmPrese.rs_userid WITH g_Userid
      REPLACE tmPrese.rs_usrres1 WITH reServat.rs_usrres1
      REPLACE tmPrese.rs_usrres2 WITH reServat.rs_usrres2
      REPLACE tmPrese.rs_usrres3 WITH reServat.rs_usrres3
      REPLACE tmPrese.rs_changes WITH "CREATED BY RECURRING RESERVATION"+ ;
              (CHR(13)+CHR(10))+"OLD_ID"+STR(reServat.rs_reserid, 12, 3)
      REPLACE tmPrese.rs_interns WITH ciNternalstatus
      REPLACE tmPrese.rs_cnfstat WITH reServat.rs_cnfstat
      REPLACE tmPrese.rs_conbill WITH cnV(reServat.rs_reserid)
      ntHisid = ntHisid+0.1
      SELECT reServat
      SKIP 1
 ENDDO
 RETURN .T.
ENDFUNC
*
FUNCTION GetStatus
 PARAMETER csTatus
 PRIVATE crEturn
 IF (INLIST(csTatus, "IN ", "OUT", "DEF", "CXL"))
      crEturn = "DEF"
 ELSE
      crEturn = csTatus
 ENDIF
 RETURN crEturn
ENDFUNC
*
FUNCTION DispTmpRese
 DIMENSION acRecfields[9, 3]
 acRecfields[1, 1] = "TmpRese.Rs_ArrDate"
 acRecfields[1, 2] = siZedate()
 acRecfields[1, 3] = GetLangText("RECURRES","TXT_ARRDATE")
 acRecfields[2, 1] = "Rs_DepDate"
 acRecfields[2, 2] = siZedate()
 acRecfields[2, 3] = GetLangText("RECURRES","TXT_DEPDATE")
 acRecfields[3, 1] = "Rs_ArrTime"
 acRecfields[3, 2] = 6
 acRecfields[3, 3] = GetLangText("RECURRES","TXT_FROM")
 acRecfields[4, 1] = "Rs_DepTime"
 acRecfields[4, 2] = 6
 acRecfields[4, 3] = GetLangText("RECURRES","TXT_TO")
 acRecfields[5, 1] = "Rs_Rooms"
 acRecfields[5, 2] = 4
 acRecfields[5, 3] = GetLangText("RECURRES","TXT_ROOMS")
 acRecfields[6, 1] = "Rs_RoomTyp"
 acRecfields[6, 2] = 6
 acRecfields[6, 3] = GetLangText("RECURRES","TXT_RTYPE")
 acRecfields[7, 1] = "Rs_RoomNum"
 acRecfields[7, 2] = 6
 acRecfields[7, 3] = GetLangText("RECURRES","TXT_ROOMNO")
 acRecfields[8, 1] = "Rs_Adults + Rs_Childs+Rs_Childs2+Rs_Childs3"
 acRecfields[8, 2] = 4
 acRecfields[8, 3] = GetLangText("RECURRES","TXT_PERSONS")
 acRecfields[9, 1] = "Rs_InternS"
 acRecfields[9, 2] = 40
 acRecfields[9, 3] = GetLangText("RECURRES","TXT_INTERNAL_STATUS")
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_SAVE"),2)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_DELETE"),-3)
 crEcurbutton = gcButtonfunction
 gcButtonfunction = ""
 SELECT tmPrese
 nrEclines = 20
 GOTO TOP
 = myBrowse(GetLangText("RECURRES","TXT_RECUR_BROWSE"),nrEclines,@acRecfields, ;
   ".t.",".t.",cbUttons,"vRecControl","RECURRES")
 gcButtonfunction = crEcurbutton
 RETURN .T.
ENDFUNC
*
FUNCTION vRecControl
 PARAMETER ncHoice
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           SELECT tmPrese
           IF (RECCOUNT()==0)
                = alErt(txT_nothing_left_to_append)
           ELSE
                IF (yeSno(GetLangText("RECURRES","TXT_APPEND_RESERVATIONS")))
                     ncReated = apPendtoreservat(geTrecur())
                     = alErt(GetLangText("RECURRES","TXT_APPDED")+" "+STR(ncReated))
                ENDIF
           ENDIF
           CLEAR READ
      CASE ncHoice==3
           IF (yeSno(GetLangText("RECURRES","TXT_DEL_RESERVATION")+";"+ ;
              GetLangText("RECURRES","TXT_ARRIVAL")+" "+DTOC(tmPrese.rs_arrdate)+ ;
              ";"+GetLangText("RECURRES","TXT_DEPARTURE")+" "+ ;
              DTOC(tmPrese.rs_depdate)))
                SELECT tmPrese
                DELETE
                g_Refreshall = .T.
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION AppendToReservat
 PARAMETER cnAme
 PRIVATE naPpended, ctMpfile, noRigid
 = inFowindow("~"+GetLangText("RECURRES","TXT_APPD_RESERVATIONS"))
 = doPen('Sheet')
 = dopen('Banquet')
 = dopen('Resfix')
 naPpended = 0
 SELECT tmPrese
 GOTO TOP
 DO WHILE ( .NOT. EOF())
      IF (TRIM(tmPrese.rs_interns)==GetLangText("RECURRES", "TXT_PRIMAIRY_RESERVATION"))
           = inFowindow(GetLangText("RECURRES","TXT_PRIMAIRY_RESERVATION"))
           SELECT reServat
           nrEsorder = ORDER()
           SET ORDER TO 1
           IF ( .NOT. SEEK(tmPrese.rs_reserid, "Reservat"))
                = alErt(GetLangText("RECURRES","TXT_PRIMAIRY_RESERVATION")+"is missing....")
           ELSE
                REPLACE reServat.rs_recur WITH cnAme
                REPLACE reServat.rs_interns WITH GetLangText("RECURRES", "TXT_PRIMAIRY_RESERVATION")
           ENDIF
           SELECT reServat
           SET ORDER TO nResOrder
      ELSE
           = inFowindow(GetLangText("RECURRES","TXT_APPD_FOR_DATE")+" "+ DTOC(tmPrese.rs_arrdate))
           SELECT tmPrese
           REPLACE tmPrese.rs_recur WITH cnAme
           SCATTER MEMO MEMVAR
           SELECT reServat
           APPEND BLANK
           GATHER MEMO MEMVAR
           DO avLset IN AvlUpdat WITH reServat.rs_arrdate, reServat.rs_depdate, reServat.rs_rooms, ;
              reServat.rs_status, reServat.rs_altid, 0, "", reServat.rs_lstart, reServat.rs_lfinish
           DO plAnset IN AvlUpdat WITH reServat.rs_arrdate,  ;
              reServat.rs_depdate, reServat.rs_roomnum,  ;
              reServat.rs_status, reServat.rs_reserid, reServat.rs_roomtyp
           IF M.lsHeetcopy
                noRigid = myVal(reServat.rs_conbill)
                IF dlOokup('Sheet','sh_reserid = '+sqLcnv(noRigid),'Found()')
                     ctMpfile = fiLetemp()
                     SELECT shEet
                     COPY TO (ctMpfile) ALL FOR sh_reserid=M.noRigid  ;
                          .AND. sh_day=0
                     USE (ctMpfile) ALIAS tmPsheet IN 0
                     SELECT tmPsheet
                     REPLACE sh_reserid WITH tmPrese.rs_reserid ALL
                     USE IN tmPsheet
                     SELECT shEet
                     APPEND FROM (ctMpfile)
                     = fiLedelete(ctMpfile+'.DBF')
                     = fiLedelete(ctMpfile+'.FPT')
                ENDIF
           ENDIF
* banquet           
           	IF dlOcate('Banquet','bq_reserid = '+ sqLcnv(reServat.rs_reserid))
				IF (yeSno(GetLangText("RESERVAT","TA_COPYBANQUET")+"?"))
					SELECT BANQUET
					SCAN FOR bq_reserid=M.noRigid
						SCATTER MEMO MEMVAR
						r_=RECNO()
						m.bq_reserid = tmprese.rs_reserid
						INSERT INTO banquet FROM MEMVAR
						FLUSH
						GO r_
					endscan
					SELECT reServat
				ENDIF
			ENDIF
* charges
			IF dlOcate('Resfix','rf_reserid = '+ sqLcnv(reServat.rs_reserid))
				IF (yeSno(GetLangText("RESERVAT","TA_COPYFIX")+"?"))
					SELECT resfix
					SCAN FOR rf_reserid=M.noRigid
						SCATTER MEMO MEMVAR
						r_=RECNO()
						m.rf_reserid = tmprese.rs_reserid
						INSERT INTO resfix FROM MEMVAR
						FLUSH
						GO r_
					endscan
					SELECT reServat
				ENDIF
			ENDIF
		
           
           SELECT reServat
           BLANK FIELDS rs_conbill
           FLUSH
           naPpended = naPpended+1
      ENDIF
      SELECT tmPrese
      SKIP 1
 ENDDO
 = inFowindow()
 = dcLose('Sheet')
 = dclose('Banquet')
 = dclose('Resfix')
 RETURN naPpended
ENDFUNC
*
FUNCTION GetRecur
 PRIVATE adLg, crEt
 DIMENSION adLg[1, 8]
 adLg[1, 1] = "recur"
 adLg[1, 2] = GetLangText("RECURRES","TXT_RECURNAME")
 adLg[1, 3] = "TmpRese.rs_recur"
 adLg[1, 4] = REPLICATE('X', 20)
 adLg[1, 5] = 20
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = ''
 crEt = ''
 IF diAlog(GetLangText("RECURRES","TXT_ENTER_NAME"),'',@adLg,.T.)
      crEt = adLg(1,8)
 ENDIF
 RETURN crEt
ENDFUNC
*
