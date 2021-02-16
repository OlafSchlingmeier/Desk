 PRIVATE ncBreserid
 PRIVATE ncB1balance
 PRIVATE ncB2balance
 PRIVATE ncB3balance
 PRIVATE ngBreserid
 PRIVATE ngBcurrentselect
 PRIVATE acGbfields
 PRIVATE cgBchkbutton
 PRIVATE cbUttons
 ncB1balance = 0
 ncB2balance = 0
 ncB3balance = 0
 IF  .NOT. isDummy(reServat.rs_roomtyp)
      = alErt(GetLangText("GROUPBIL","TXT_NOT_A_PAYMASTER"))
 ELSE
      DIMENSION acGbfields[7, 4]
      acGbfields[1, 1] = "TmpGroup.Mark"
      acGbfields[1, 2] = 5
      acGbfields[1, 3] = GetLangText("GROUPBIL","TXT_MARKED")
      acGbfields[1, 4] = ""
      acGbfields[2, 1] = "Rs_RoomNum"
      acGbfields[2, 2] = 6
      acGbfields[2, 3] = GetLangText("GROUPBIL","TXT_ROOMNUM")
      acGbfields[2, 4] = ""
      acGbfields[3, 1] = "Rs_lName"
      acGbfields[3, 2] = 30
      acGbfields[3, 3] = GetLangText("GROUPBIL","TXT_NAME")
      acGbfields[3, 4] = ""
      acGbfields[4, 1] = "Rs_ReserID"
      acGbfields[4, 2] = 15
      acGbfields[4, 3] = GetLangText("GROUPBIL","TXT_RESERID")
      acGbfields[4, 4] = ""
      acGbfields[5, 1] =  ;
                'Transform(Round(nCb1Balance, Param.Pa_CurrDec), Right(gcCurrcyDisp, 14))'
      acGbfields[5, 2] = 14
      acGbfields[5, 3] = GetLangText("GROUPBIL","TXT_BALANCE")+" 1"
      acGbfields[5, 4] = "@J"
      acGbfields[6, 1] =  ;
                'Transform(Round(nCb2Balance, Param.Pa_CurrDec), Right(gcCurrcyDisp, 14))'
      acGbfields[6, 2] = 14
      acGbfields[6, 3] = GetLangText("GROUPBIL","TXT_BALANCE")+" 2"
      acGbfields[6, 4] = "@J"
      acGbfields[7, 1] =  ;
                'Transform(Round(nCb3Balance, Param.Pa_CurrDec), Right(gcCurrcyDisp, 14))'
      acGbfields[7, 2] = 14
      acGbfields[7, 3] = GetLangText("GROUPBIL","TXT_BALANCE")+" 3"
      acGbfields[7, 4] = "@J"
      ngBcurrentselect = SELECT()
      ngBreserid = reServat.rs_reserid
      ncBreserid = reServat.rs_reserid
      SELECT rs_roomnum, rs_lname, "    " AS maRk, rs_reserid FROM  ;
             Reservat WHERE rs_reserid>=INT(ngBreserid) AND rs_reserid< ;
             INT(ngBreserid)+1 AND  NOT EMPTY(reServat.rs_in) AND  ;
             EMPTY(reServat.rs_out) AND reServat.rs_status<>"CXL" AND   ;
             NOT isDummy(reServat.rs_roomtyp) INTO TABLE SYS(2023)+"\"+ ;
             "TmpGroup"
      cbUttons = GetLangText("COMMON","TXT_OK")+";"+GetLangText("GROUPBIL","TXT_MARK")+ ;
                 ";"+GetLangText("GROUPBIL","TXT_ALL")+";"+GetLangText("GROUPBIL","TXT_NONE")
      SELECT tmPgroup
      IF (RECCOUNT()>0)
           GOTO TOP
           cgBchkbutton = gcButtonfunction
           gcButtonfunction = ""
           = myBrowse(GetLangText("GROUPBIL","TXT_GROUPMEMBERS"),20,@acGbfields, ;
             ".t.",".t.",cbUttons,"vGbControl","GROUPBIL","CalcBalance")
           gcButtonfunction = cgBchkbutton
           SELECT tmPgroup
           COUNT ALL FOR  .NOT. EMPTY(tmPgroup.maRk) TO nmArked
           IF (nmArked>0)
                = poStings(ngBreserid)
           ENDIF
      ENDIF
      SELECT (ngBcurrentselect)
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION vGbControl
 PARAMETER ncHoice
 DIMENSION alChecks[3]
 DIMENSION acChecks[3]
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           IF (EMPTY(tmPgroup.maRk))
                STORE .F. TO alChecks
                acChecks[1] = GetLangText("GROUPBIL","TXT_FIRST_BILL")
                acChecks[2] = GetLangText("GROUPBIL","TXT_SECOND_BILL")
                acChecks[3] = GetLangText("GROUPBIL","TXT_THIRD_BILL")
                IF (chEckboxmessage(GetLangText("GROUPBIL","TXT_SELECT_BILLS"), ;
                   @alChecks,@acChecks))
                     cbIll = ""
                     cbIll = cbIll+IIF(alChecks(1), "1", "")
                     cbIll = cbIll+IIF(alChecks(2), "2", "")
                     cbIll = cbIll+IIF(alChecks(3), "3", "")
                     REPLACE tmPgroup.maRk WITH cbIll+CHR(187)
                ENDIF
           ELSE
                REPLACE tmPgroup.maRk WITH ""
           ENDIF
           g_Refreshcurr = .T.
      CASE ncHoice==3
           DIMENSION alChecks[3]
           STORE .F. TO alChecks
           DIMENSION acChecks[3]
           acChecks[1] = GetLangText("GROUPBIL","TXT_FIRST_BILL")
           acChecks[2] = GetLangText("GROUPBIL","TXT_SECOND_BILL")
           acChecks[3] = GetLangText("GROUPBIL","TXT_THIRD_BILL")
           IF (chEckboxmessage(GetLangText("GROUPBIL","TXT_SELECT_BILLS"), ;
              @alChecks,@acChecks))
                cbIll = ""
                cbIll = cbIll+IIF(alChecks(1), "1", "")
                cbIll = cbIll+IIF(alChecks(2), "2", "")
                cbIll = cbIll+IIF(alChecks(3), "3", "")
                REPLACE tmPgroup.maRk WITH cbIll+CHR(187) ALL
           ENDIF
           g_Refreshall = .T.
           GOTO TOP
      CASE ncHoice==4
           REPLACE tmPgroup.maRk WITH "" ALL
           g_Refreshall = .T.
           GOTO TOP
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION Postings
 PARAMETER npSreserid
 PRIVATE ctMppostname
 PRIVATE acPsfields
 PRIVATE cpSchkbutton
 PRIVATE cpSbuttons
 CREATE CURSOR TmpArti (maRk C (3), arTi N (4, 0), deScrip C (30), quAnt  ;
        N (12, 0), amOunt N (12, 2))
 SELECT tmPgroup
 GOTO TOP
 DO WHILE ( .NOT. EOF())
      IF ( .NOT. EMPTY(tmPgroup.maRk))
           DO ifCpost IN Interfac WITH tmPgroup.rs_reserid, tmPgroup.rs_roomnum
      ENDIF
      SELECT tmPgroup
      SKIP 1
 ENDDO
 SELECT * FROM Post WHERE ps_reserid>=INT(npSreserid) AND ps_reserid< ;
          INT(npSreserid)+1 AND  NOT poSt.ps_split AND  ;
          EMPTY(poSt.ps_paynum) INTO TABLE SYS(2023)+"\TmpPost"
 SELECT tmParti
 INDEX ON arTi TAG taG1
 SET ORDER TO 1
 SELECT tmPgroup
 GOTO TOP
 DO WHILE ( .NOT. EOF())
      IF ( .NOT. EMPTY(tmPgroup.maRk))
           SELECT tmPpost
           GOTO TOP
           DO WHILE ( .NOT. EOF())
                IF (tmPpost.ps_reserid==tmPgroup.rs_reserid .AND.  ;
                   AT(STR(tmPpost.ps_window, 1), tmPgroup.maRk)<>0)
                     SELECT tmParti
                     IF ( .NOT. SEEK(tmPpost.ps_artinum, "TmpArti"))
                          SELECT arTicle
                          = SEEK(tmPpost.ps_artinum, "Article")
                          SELECT tmParti
                          APPEND BLANK
                          REPLACE tmParti.arTi WITH tmPpost.ps_artinum
                          REPLACE tmParti.deScrip WITH  ;
                                  EVALUATE("Article.Ar_Lang"+g_Langnum)
                     ENDIF
                     REPLACE tmParti.quAnt WITH tmParti.quAnt+tmPpost.ps_units
                     REPLACE tmParti.amOunt WITH tmParti.amOunt+ ;
                             tmPpost.ps_amount
                ENDIF
                SELECT tmPpost
                SKIP 1
           ENDDO
      ENDIF
      SELECT tmPgroup
      SKIP 1
 ENDDO
 SELECT tmParti
 IF (RECCOUNT()>0)
      DIMENSION acPsfields[5, 3]
      acPsfields[1, 1] = "TmpArti.Mark"
      acPsfields[1, 2] = 5
      acPsfields[1, 3] = GetLangText("GROUPBIL","TXT_MARKED")
      acPsfields[2, 1] = "Arti"
      acPsfields[2, 2] = 10
      acPsfields[2, 3] = GetLangText("GROUPBIL","TXT_ARTICLE")
      acPsfields[3, 1] = "Descrip"
      acPsfields[3, 2] = 40
      acPsfields[3, 3] = GetLangText("GROUPBIL","TXT_DESCRIPTION")
      acPsfields[4, 1] = "Quant"
      acPsfields[4, 2] = 15
      acPsfields[4, 3] = GetLangText("GROUPBIL","TXT_QUANTITY")
      acPsfields[5, 1] = "Amount"
      acPsfields[5, 2] = 15
      acPsfields[5, 3] = GetLangText("GROUPBIL","TXT_AMOUNT")
      cpSbuttons = GetLangText("COMMON","TXT_OK")+";"+GetLangText("GROUPBIL", ;
                   "TXT_MARK")+";"+GetLangText("GROUPBIL","TXT_ALL")+";"+ ;
                   GetLangText("GROUPBIL","TXT_NONE")
      SELECT tmParti
      GOTO TOP
      cpSchkbutton = gcButtonfunction
      gcButtonfunction = ""
      = myBrowse(GetLangText("GROUPBIL","TXT_LIST_OF_ARTICLES"),20,@acPsfields, ;
        ".t.",".t.",cpSbuttons,"vPsControl","GROUPBIL")
      gcButtonfunction = cpSchkbutton
      COUNT ALL FOR  .NOT. EMPTY(tmParti.maRk) TO nrEcords
      IF (nrEcords>0)
           = rePost(npSreserid)
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION vPsControl
 PARAMETER ncHoice
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           IF (EMPTY(tmParti.maRk))
                REPLACE tmParti.maRk WITH CHR(187)
           ELSE
                REPLACE tmParti.maRk WITH ""
           ENDIF
           g_Refreshcurr = .T.
      CASE ncHoice==3
           REPLACE tmParti.maRk WITH CHR(187) ALL
           g_Refreshall = .T.
           GOTO TOP
      CASE ncHoice==4
           REPLACE tmParti.maRk WITH "" ALL
           g_Refreshall = .T.
           GOTO TOP
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION RePost
 PARAMETER nrPreserid
 PRIVATE nrSorder, nrSrec
 PRIVATE npSorder
 PRIVATE nrPnewrsid
 PRIVATE nrEsid, nwIndow, nsEtid, npSrec, npSord, naRea
 nrPnewrsid = 0
 naRea = SELECT()
 SELECT reServat
 nrSorder = ORDER()
 nrSrec = RECNO()
 SET ORDER TO 1
 = dlOcate('Reservat','rs_reserid >= '+sqLcnv(INT(nrPreserid))+ ;
   ' and rs_reserid < '+sqLcnv(INT(nrPreserid)+1))
 DO WHILE ( .NOT. EOF() .AND. INT(reServat.rs_reserid)==INT(nrPreserid))
      IF isDummy(reServat.rs_roomtyp) .AND.  .NOT.  ;
         INLIST(reServat.rs_status, 'CXL', 'NS')
           nrPnewrsid = reServat.rs_reserid
           EXIT
      ENDIF
      SELECT reServat
      SKIP 1
 ENDDO
 SELECT reServat
 SET ORDER TO nRsOrder
 GOTO nrSrec
 SELECT (naRea)
 IF nrPnewrsid=0
      RETURN
 ENDIF
 WAIT WINDOW NOWAIT "Transfer..."
 SELECT poSt
 npSorder = ORDER()
 SET ORDER TO 0
 SELECT tmPgroup
 GOTO TOP
 DO WHILE ( .NOT. EOF())
      IF ( .NOT. EMPTY(tmPgroup.maRk))
           SELECT tmParti
           GOTO TOP
           DO WHILE ( .NOT. EOF())
                IF ( .NOT. EMPTY(tmParti.maRk))
                     SELECT poSt
                     SCAN ALL FOR poSt.ps_reserid==tmPgroup.rs_reserid  ;
                          .AND. STR(poSt.ps_window, 1)$tmPgroup.maRk  ;
                          .AND. tmParti.arTi==poSt.ps_artinum
                          nrEsid = poSt.ps_reserid
                          nwIndow = poSt.ps_window
                          nsEtid = poSt.ps_setid
                          REPLACE poSt.ps_origid WITH poSt.ps_reserid,  ;
                                  poSt.ps_reserid WITH nrPnewrsid,  ;
                                  poSt.ps_touched WITH .T.,  ;
                                  poSt.ps_supplem WITH  ;
                                  TRIM(tmPgroup.rs_roomnum)+" "+ ;
                                  TRIM(PROPER(tmPgroup.rs_lname))
                          FLUSH
                          IF nsEtid>0
                               naRea = SELECT()
                               SELECT poSt
                               npSrec = RECNO()
                               npSord = ORDER()
                               REPLACE ps_reserid WITH nrPnewrsid,  ;
                                       ps_touched WITH .T., ps_supplem  ;
                                       WITH TRIM(tmPgroup.rs_roomnum)+" "+ ;
                                       TRIM(PROPER(tmPgroup.rs_lname))  ;
                                       ALL FOR ps_reserid=nrEsid .AND.  ;
                                       ps_window=nwIndow .AND. ps_setid=nsEtid
                               FLUSH
                               SET ORDER TO nPsOrd
                               GOTO npSrec
                               SELECT (naRea)
                          ENDIF
                     ENDSCAN
                ENDIF
                SELECT tmParti
                SKIP 1
           ENDDO
      ENDIF
      SELECT tmPgroup
      SKIP 1
 ENDDO
 WAIT CLEAR
 SELECT poSt
 SET ORDER TO nPsOrder
 l_Refreshwin = .T.
 RETURN .T.
ENDFUNC
*
FUNCTION CalcBalance
 ncB1balance = baLance(tmPgroup.rs_reserid,1)
 ncB2balance = baLance(tmPgroup.rs_reserid,2)
 ncB3balance = baLance(tmPgroup.rs_reserid,3)
 RETURN .T.
ENDFUNC
*
