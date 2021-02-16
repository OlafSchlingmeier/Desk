*
FUNCTION vControl
 PARAMETER noPtion, nbIllreserid, nbIllwindow
 PRIVATE l_Reason
 PRIVATE l_I
 PRIVATE l_Reserid, naDdressid
 PUSH KEY CLEAR
 DO CASE
      CASE noPtion==1
      CASE noPtion==2
           = edItpost()
           g_Refreshcurr = .T.
      CASE noPtion==3
           *= neWpost(nbIllreserid,nbIllwindow)
           DO FORM "forms/postpay" WITH "OLD_POST", nbIllwindow
           l_Refreshwin = .T.
      CASE noPtion==4
           IF nbIllwindow>1
                naDdressid = VAL(SUBSTR(MLINE(reServat.rs_billins,  ;
                             nbIllwindow), 1, 12))
                IF naDdressid=0
                     naDdressid = reServat.rs_addrid
                ENDIF
           ELSE
                naDdressid = reServat.rs_addrid
           ENDIF
           *= neWpay(nbIllreserid,nbIllwindow,reServat.rs_paymeth,naDdressid)
           DO FORM "forms/postpay" WITH "OLD_PAY", nbIllwindow, naDdressid
           l_Refreshwin = .T.
      CASE noPtion==5
           IF (paRam.pa_delpost .AND. (EMPTY(poSt.ps_paynum) .OR.  ;
              paRam.pa_delpay) .AND. poSt.ps_date=sySdate() .AND.  ;
              EMPTY(poSt.ps_ratecod))
                IF (yeSno(GetLangText("CHKOUT2","TA_DELETE")+" "+ ;
                   ALLTRIM(STR(poSt.ps_artinum+poSt.ps_paynum))+" "+ ;
                   ALLTRIM(EVALUATE("Article.Ar_Lang"+g_Langnum)+ ;
                   EVALUATE("Paymetho.Pm_Lang"+g_Langnum))+"?"))
                     l_Reason = SPACE(25)
                     DEFINE WINDOW wrEason AT 0, 0 SIZE 5, 80 FONT  ;
                            "Arial", 10 NOCLOSE NOZOOM TITLE  ;
                            chIldtitle(GetLangText("CHKOUT2","TW_REASON")) NOMDI  ;
                            DOUBLE
                     MOVE WINDOW wrEason CENTER
                     ACTIVATE WINDOW wrEason
                     clEvel = ""
                     cdElbuttons = "\!"+buTton(clEvel,GetLangText("COMMON", ;
                                   "TXT_OK"),1)+"\?"+buTton(clEvel, ;
                                   GetLangText("COMMON","TXT_CANCEL"),-2)
                     nsElectedbutton = 1
                     = paNelborder()
                     = paNel((0.9375),(2.66666666666667),(2.0625), ;
                       (23.3333333333333),2)
                     @ 1, 4 SAY GetLangText("CHKOUT2","T_REASON")
                     @ 1, 25 GET l_Reason SIZE 1, 30 PICTURE "@K "+ ;
                       REPLICATE("X", 25)
                     @ 1, 60 GET nsElectedbutton STYLE "B" SIZE  ;
                       nbUttonheight, 15 FUNCTION "*"+"V" PICTURE cdElbuttons
                     READ VALID ((nsElectedbutton==1 .AND.  .NOT.  ;
                          EMPTY(l_Reason)) .OR. nsElectedbutton==2) MODAL
                     RELEASE WINDOW wrEason
                     = chIldtitle("")
                     IF (nsElectedbutton==1)
                          REPLACE poSt.ps_descrip WITH l_Reason
                          REPLACE poSt.ps_cancel WITH .T.
                          IF dlOokup('Article','ar_artinum = '+ ;
                             sqLcnv(poSt.ps_artinum),'ar_artityp')=2
                               SCATTER MEMVAR
                               l_Oldrec = RECNO()
                               M.ps_artinum = 0
                               M.ps_cancel = .F.
                               IF paRam.pa_currloc<>0
                                    M.ps_paynum = paRam.pa_currloc
                               ELSE
                                    M.ps_paynum = 1
                               ENDIF
                               M.ps_supplem = TRIM(reServat.rs_roomnum)+ ;
                                ' '+reServat.rs_lname
                               M.ps_reserid = 0.200
                               M.ps_origid = 0.200
                               M.ps_price = 1.00
                               M.ps_units = M.ps_amount
                               M.ps_amount = -M.ps_amount
                               M.ps_vat0 = 0.00
                               M.ps_vat1 = 0.00
                               M.ps_vat2 = 0.00
                               M.ps_vat3 = 0.00
                               M.ps_vat4 = 0.00
                               M.ps_vat5 = 0.00
                               M.ps_vat6 = 0.00
                               M.ps_vat7 = 0.00
                               M.ps_vat8 = 0.00
                               M.ps_vat9 = 0.00
                               M.ps_postid = neXtid('Post')
                               INSERT INTO Post FROM MEMVAR
                               FLUSH
                               GOTO l_Oldrec
                          ENDIF
                     ENDIF
                ENDIF
           ELSE
                = alErt(GetLangText("CHKOUT2","TA_IMPOSSIBLE")+"!")
           ENDIF
      CASE noPtion==6
           DO toGgle
           g_Refreshcurr = .T.
      CASE noPtion==7
           DO inSpost WITH nbIllwindow
           l_Refreshwin = .T.
      CASE noPtion==8
           = spLitpst()
           g_Refreshall = .T.
      CASE noPtion==9
           = prNtbill(nbIllreserid,nbIllwindow,.F.,1,.F.)
      CASE noPtion==10
           FOR l_I = 1 TO 3
                = prNtbill(nbIllreserid,l_I,.F.,1,.F.)
           ENDFOR
      CASE noPtion==11
           = prNtbill(nbIllreserid,nbIllwindow,.T.,1,.F.)
      CASE noPtion==12
           l_Reserid = reServat.rs_reserid
           l_Roomnum = poStroom()
           DO ifCpost IN Interfac WITH l_Reserid, l_Roomnum
           = chEckout(l_Reserid,nbIllwindow,.T.)
           l_Refreshwin = .T.
      CASE noPtion==13
           l_Reserid = reServat.rs_reserid
           = reDirect(l_Reserid)
           l_Refreshwin = .T.
      CASE noPtion==14
           DO ifCprint IN Interfac WITH nbIllreserid, nbIllwindow
      CASE noPtion==15
           = seTbillstyle(nbIllwindow)
      CASE noPtion==16
           = grOupbil()
 ENDCASE
 POP KEY
 RETURN .T.
ENDFUNC
*
PROCEDURE Toggle
 IF RECNO("post")<>teMp.tp_recno
      INSERT INTO temp (tp_recno, tp_marker) VALUES (RECNO("post"), CHR(171))
 ELSE
      REPLACE teMp.tp_marker WITH IIF(EMPTY(teMp.tp_marker), CHR(171), "")
 ENDIF
 RETURN
ENDPROC
*
FUNCTION EditPost
 PRIVATE csTyle9text
 PRIVATE coRistyle9text, cfLd
 PRIVATE acPrtypes
 PRIVATE ALL LIKE l_*
 l_Default = EVALUATE("AllTrim(Article.Ar_Lang"+g_Langnum+ ;
             " + PayMetho.Pm_Lang"+g_Langnum+" + RateCode.Rc_Lang"+ ;
             g_Langnum+")")
 DO CASE
      CASE poSt.ps_prtype>0
           csTyle9text = dbLookup("PrTypes",1,STR(poSt.ps_prtype, 2), ;
                         "PrTypes.Pt_Descrip")
      CASE arTicle.ar_prtype>0
           csTyle9text = dbLookup("PrTypes",1,STR(arTicle.ar_prtype, 2), ;
                         "PrTypes.Pt_Descrip")
      OTHERWISE
           csTyle9text = ""
 ENDCASE
 coRistyle9text = csTyle9text
 nsElectedbutton = 1
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 cfLd = 'pt_lang'+g_Langnum
 Select &cFld From PrTypes Into Array acPrTypes Order By Pt_Number
 IF _TALLY=0
      DIMENSION acPrtypes[1]
      acPrtypes[1] = ""
 ENDIF
 SCATTER MEMVAR FIELDS ps_artinum, ps_date, ps_time, ps_units, ps_price,  ;
         ps_cashier, ps_userid, ps_descrip, ps_supplem
 DEFINE WINDOW weDitpost AT 0, 0 SIZE 12.500, 80 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("CHKOUT2","TW_EDIT")) NOMDI DOUBLE
 MOVE WINDOW weDitpost CENTER
 ACTIVATE WINDOW weDitpost
 = paNelborder()
 = paNel((0.9375),(2.66666666666667),(2.0625),(23.3333333333333),2)
 = paNel((2.1875),(2.66666666666667),(3.3125),(23.3333333333333),2)
 = paNel((3.4375),(2.66666666666667),(4.5625),(23.3333333333333),2)
 = paNel((4.6875),(2.66666666666667),(5.8125),(23.3333333333333),2)
 = paNel((5.9375),(2.66666666666667),(7.0625),(23.3333333333333),2)
 = paNel((7.1875),(2.66666666666667),(8.3125),(23.3333333333333),2)
 = paNel((8.9375),(2.66666666666667),(10.0625),(23.3333333333333),2)
 = paNel((10.1875),(2.66666666666667),(11.3125),(23.3333333333333),2)
 @ 1, 4 SAY GetLangText("CHKOUT2","T_DATETIME")
 @ 2.250, 4 SAY GetLangText("CHKOUT2","T_USERCASH")
 @ 3.500, 4 SAY GetLangText("CHKOUT2","T_UNITS")
 @ 4.750, 4 SAY GetLangText("CHKOUT2","T_PRICE")
 @ 6, 4 SAY GetLangText("CHKOUT2","T_DEFAULT")
 @ 7.250, 4 SAY GetLangText("CHKOUT2","TXT_STYLE9TEXT")
 @ 9, 4 SAY GetLangText("CHKOUT2","T_CUSTOM")
 @ 10.250, 4 SAY GetLangText("CHKOUT2","T_SUPPLEM")
 @ 1, 25 GET M.ps_date SIZE 1, 14 WHEN .F.
 @ 1, 41 GET M.ps_time SIZE 1, 14 WHEN .F.
 @ 2.250, 25 GET M.ps_userid SIZE 1, 14 WHEN .F.
 @ 2.250, 41 GET M.ps_cashier SIZE 1, 14 WHEN .F.
 @ 3.500, 25 GET M.ps_units SIZE 1, 30 WHEN .F.
 IF M.ps_artinum>0
      @ 4.750, 25 GET M.ps_price SIZE 1, 30 PICTURE RIGHT(gcCurrcy, 14)  ;
        WHEN .F.
 ELSE
      @ 4.750, 25 GET M.ps_price SIZE 1, 30 PICTURE '99999.999999' WHEN .F.
 ENDIF
 @ 6, 25 GET l_Default SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25) WHEN .F.
 @ 7.250, 25 GET csTyle9text FROM acPrTypes FUNCTION "^"
 @ 9, 25 GET M.ps_descrip SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)
 @ 10.250, 25 GET M.ps_supplem SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)
 @ 1, 60 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"V" PICTURE cbUttons
 READ CYCLE MODAL
 RELEASE WINDOW weDitpost
 = chIldtitle("")
 IF (nsElectedbutton==1)
      M.ps_touched = .T.
      GATHER MEMVAR FIELDS ps_descrip, ps_supplem, ps_touched
      IF (coRistyle9text<>csTyle9text)
           nsElect = SELECT()
           SELECT prTypes
           = dlOcate('PrTypes','pt_lang'+g_Langnum+' = '+sqLcnv(csTyle9text))
           SELECT poSt
           REPLACE poSt.ps_prtype WITH prTypes.pt_number
           IF prTypes.pt_copytxt
                REPLACE poSt.ps_descrip WITH EVALUATE('PrTypes.pt_lang'+ ;
                        g_Langnum)
           ENDIF
           SELECT prTypes
           SET ORDER TO 1
           SELECT (nsElect)
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
PROCEDURE InsPost
 PARAMETER p_Window
 PRIVATE l_Oldarea
 PRIVATE nrEsid, nwIndow, nsEtid, npSrec, npSord, naRea
 l_Oldarea = SELECT()
 WAIT WINDOW NOWAIT "Transfer..."
 SELECT teMp
 GOTO TOP
 DO WHILE  .NOT. EOF()
      IF  .NOT. EMPTY(teMp.tp_marker)
           GOTO teMp.tp_recno IN "post"
           nwIndow = poSt.ps_window
           nrEsid = poSt.ps_reserid
           nsEtid = poSt.ps_setid
           REPLACE poSt.ps_window WITH p_Window, poSt.ps_touched WITH .T.
           FLUSH
           IF nsEtid>0
                naRea = SELECT()
                SELECT poSt
                npSrec = RECNO()
                npSord = ORDER()
                SET ORDER TO 0
                REPLACE ps_window WITH p_Window, ps_touched WITH .T. ALL  ;
                        FOR ps_reserid=nrEsid .AND. ps_window=nwIndow  ;
                        .AND. ps_setid=nsEtid
                FLUSH
                SET ORDER TO nPsOrd
                GOTO npSrec
                SELECT (naRea)
           ENDIF
      ENDIF
      SKIP 1
 ENDDO
 ZAP
 SELECT (l_Oldarea)
 WAIT CLEAR
 RETURN
ENDPROC
*
PROCEDURE CheckOut
 LPARAMETERS pnReserid, nbIllwindow, plPrint
* PRIVATE ALL LIKE l_*
* PRIVATE dfOr
* PRIVATE npMrecnum
* PRIVATE loPendrawer, lqUickout, cnAme, cbIllnum, cfXp
* PRIVATE laSktype, llEdger, lcReditnote, lcHeckout, naDdressid, lpOstpayment
* LOCAL LHistStr, LOldDepDate
* LHistStr = ""
* LOldDepDate = {}
* l_Row = 0.5
* l_Col = 2
* l_Settled = .T.
* l_Advtype = 0
* l_Window = nbIllwindow
* loPendrawer = .F.
* lqUickout = (nbIllwindow=0)
* lpOstpayment = .F.
* IF EMPTY(reServat.rs_in)
*      = alErt(GetLangText("CHKOUT2","TXT_NOTCHECKEDIN")+"!")
*      RETURN
* ENDIF
* naRea = SELECT()
* SELECT paYmetho
* npMrecnum = RECNO()
* IF (reServat.rs_depdate>sySdate())
*      clEvel = ""
*      cbUttons = "\!"+buTton(clEvel,GetLangText("CHKOUT2","TXT_EARLYLEAVING"),1, ;
*                 .T.)+buTton(clEvel,GetLangText("CHKOUT2","TXT_ADVANCEBILL"),2, ;
*                 .T.)+"\?"+buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-3,.T.)
*      DO FORM forms\nodepartureform TO l_Advtype 
*      DO CASE
*           CASE l_Advtype==1
*                = avLsave()
*                SELECT reServat
*                LOldDepDate = reServat.rs_depdate 
*                LOCAL l_nReserid, l_nMode, l_nOldShareid, l_nCount, l_nRecno, l_oReser
*                SCATTER NAME l_oReser
*                l_nOldShareid = reservat.rs_shareid
*                REPLACE reServat.rs_depdate WITH sySdate()
*                l_nRecno = RECNO("reservat")
*                l_nCount = 0
*                SELECT resshare
*                SCAN FOR sr_shareid = l_nOldShareid
*                    IF SEEK(resshare.sr_reserid, "reservat", "tag1")
*                        l_nCount = l_nCount + 1
*                    ENDIF
*                ENDSCAN
*                GO l_nRecno IN reservat
*                IF l_nCount < 2
*                    l_nMode = 2
*                ELSE
*                    DO CheckRoomNum IN ProcReservat WITH l_nMode, "reServat", .F., l_oReser, .T.
*                ENDIF
*                IF l_nMode >= 0
*                    DO ChangeShare IN ProcReservat WITH l_nMode, "reservat"
*                    = avlupdat()
*                    LHistStr = GetLangText("RESERVAT","T_CHANGED")+" "+GetLangText("RESERVAT","T_DEPDATE")+" "+ ;
*                    DTOC(LOldDepDate)+"..."+DTOC(sySdate())+","
*                    REPLACE reServat.rs_changes WITH  rsHistry(reServat.rs_changes, ;
*                        "EARLY LEAVING",LHistStr)
*                    DO UpdateShareRes IN ProcReservat WITH "reservat"
*                    GO l_nRecno IN reservat
*                ELSE
*                    GO l_nRecno IN reservat
*                    REPLACE reservat.rs_depdate WITH l_oReser.rs_depdate IN reservat
*                    SELECT (naRea)
*                    RETURN
*                ENDIF
*            CASE l_Advtype=2
*                IF EMPTY(reServat.rs_ratedat)
*                     dfOr = sySdate()
*                ELSE
*                     dfOr = reServat.rs_ratedat+1
*                ENDIF
*                IF opEnfile(.F.,"ResFix",.f.,.t.)
*                     DO WHILE dfOr<=reServat.rs_depdate-1
*                          DO poStresfix IN ResFix WITH dfOr
*                          dfOr = dfOr+1
*                     ENDDO
*                     = clOsefile("ResFix")
*                     FLUSH
*                ENDIF
*                DO raTecodepost IN RatePost WITH reServat.rs_depdate-1, ""
*                DO raTecodepost IN RatePost WITH reServat.rs_depdate,  ;
*                   "CHECKOUT"
*           OTHERWISE
*                SELECT (naRea)
*                RETURN
*      ENDCASE
* ENDIF
* IF  .NOT. dePspec()
*      SELECT (naRea)
*      RETURN
* ENDIF
* IF lqUickout
*      IF (baLance(pnReserid,2)+baLance(pnReserid,3)<>0.00)
*           = alErt(GetLangText("CHKOUT2","TA_HAS2BILL")+"!")
*           SELECT (naRea)
*           RETURN
&&      ELSE
*           l_Window = 1
*           l_Balance = baLance(pnReserid,l_Window)
*      ENDIF
* ELSE
*      l_Balance = baLance(pnReserid,l_Window)
* ENDIF
* IF l_Balance<>0
*      lpOstpayment = .T.
*      l_Settled = .F.
*      SELECT poSt
*
*      IF l_Window>1
*           naDdressid = VAL(SUBSTR(MLINE(reServat.rs_billins, l_Window),  ;
*                        1, 12))
*           IF naDdressid=0
*                naDdressid = reServat.rs_addrid
*           ENDIF
&&      ELSE
*           naDdressid = reServat.rs_addrid
*      ENDIF
*
*      DO FORM "forms/postpay" ;
*               WITH "OLD_CHKOUT", l_Window, naDdressid, .T. ;
*               TO l_result
*      IF l_result <> 0
*          l_Settled = .T.
*          npMrecnum = l_result
*      ENDIF
* ENDIF
* SELECT paYmetho
* GOTO npMrecnum
* SELECT (naRea)
* IF l_Settled
*      SELECT reServat
*      REPLACE reServat.rs_paymeth WITH paYmetho.pm_paymeth
*      cfLd = 'Reservat.rs_paynum'+STR(l_Window, 1)
*      replace &cFld with Paymetho.pm_paynum
*      FLUSH
*      IF (reServat.rs_depdate<=sySdate() .AND. (baLance(pnReserid,1)+ ;
*               baLance(pnReserid,2)+baLance(pnReserid,3)+ ;
*               balance(pnReserid,4)+balance(pnReserid,5)+ ;
*               balance(pnReserid,6)==0.00))
*           REPLACE reServat.rs_codate WITH sySdate()
*           REPLACE reServat.rs_cotime WITH TIME()
*           REPLACE reServat.rs_out WITH "1"
*           REPLACE reServat.rs_status WITH "OUT"
*           replace reservat.rs_posstat WITH "0"
*           REPLACE reServat.rs_changes WITH rsHistry(reServat.rs_changes, ;
*                   "CHECKOUT","")
*           REPLACE reServat.rs_xchkout WITH .F.
*           IF !EMPTY(reservat.rs_shareid)
*                DO ChangeShare IN ProcReservat WITH 2, "reservat"
*                IF SEEK(reservat.rs_shareid,"sharing","tag1") AND (OLDVAL("sd_reserid","sharing") <> sharing.sd_reserid)
*                    DO plAnreset IN AvlUpdat WITH OLDVAL("sd_reserid","sharing")
*                    DO plAnset IN AvlUpdat WITH sharing.sd_lowdat, sharing.sd_highdat, sharing.sd_roomnum, ;
*                        sharing.sd_status, sharing.sd_reserid, sharing.sd_roomtyp, sharing.sd_shareid
*                    FLUSH
*                ENDIF
*                = TABLEUPDATE(.F., .T., "sharing")
*            ENDIF
*           IF param.pa_rmstat
*           		IF SEEK(reServat.rs_roomnum, 'room', 'tag1')
*           			replace rm_status WITH "DIR" IN room
*           		ENDIF 
*           ENDIF
*           DO ifCcheck IN Interfac WITH reServat.rs_roomnum, "CHECKOUT"
*           WAIT WINDOW TIMEOUT 0.5 TRIM(reServat.rs_roomnum)+" "+ ;
*                TRIM(PROPER(reServat.rs_lname))+" OUT"
*           FLUSH
*           IF openfile(.f.,"laststay",.f.,.t.)
*           		DO LsResUpd IN AaUpd WITH pnReserid
*  *       		USE IN laststay
*           		SELECT reservat
*           	ENDIF
*      ENDIF
*      IF (paRam.pa_autoprn .AND. plPrint)
*           ncUrar = SELECT()
*           SELECT paYmetho
*           GOTO npMrecnum
*           SELECT (ncUrar)
*           glCheckout = .T.
*           = prNtbill(pnReserid,l_Window,.F.,MAX(paYmetho.pm_copy, 1),.T.)
*           glCheckout = .F.
*      ENDIF
*      IF (SEEK(reServat.rs_roomnum, "Room"))
*           REPLACE roOm.rs_message WITH ""
*           REPLACE roOm.rs_msgshow WITH .F.
*      ENDIF
*      * Store last room nummber in address.dbf
**      IF EMPTY(reservat.rs_addrid)
**      	IF !EMPTY(reservat.rs_apid) AND !EMPTY(reservat.rs_compid)
**		      IF SEEK(reServat.rs_compid,'address','tag1')
**		      	replace ad_lasroom WITH reServat.rs_roomnum IN address
**		      ENDIF
**      	ENDIF
**      ELSE
**	      IF SEEK(reServat.rs_addrid,'address','tag1')
**	      	replace ad_lasroom WITH reServat.rs_roomnum IN address
**	      ENDIF
**	ENDIF
*      IF lqUickout .AND. lpOstpayment
*           IF EMPTY(reServat.rs_billnr1)
*                laSktype = .F.
*                llEdger = .F.
*                lcReditnote = .F.
*                lcHeckout = plPrint
*                LOCAL l_nAmount, l_cBillNum
*                DO BillAmount IN ProcBill WITH l_nAmount,"post",nReserId,nBillWindow
*                l_cBillNum = GetBill(lasktype,lledger,lcreditnote,lcheckout, ;
*                        reservat.rs_reserid,reservat.rs_addrid,l_nAmount,"CHECK OUT")
*                REPLACE rs_billnr1 WITH l_cBillNum IN reservat
*           ENDIF
*           REPLACE reServat.rs_copyw1 WITH MIN(99, reServat.rs_copyw1+1)
*           cnAme = TRIM(adDress.ad_title)+" "+TRIM(adDress.ad_fname)+" "+ ;
*                   TRIM(flIp(adDress.ad_lname))
*           cbIllnum = reServat.rs_billnr1
*           IF  .NOT. EMPTY(paRam.pa_fiscprt)
*                IF reServat.rs_copyw1=1
*                     cfXp = 'FP'+TRIM(paRam.pa_fiscprt)+'.FXP'
*                     IF FILE(cfXp)
*                          cfXp = 'FP'+TRIM(paRam.pa_fiscprt)
*                          do &cFxp with 'PRINT', pnReserId, 1, cName, cBillNum, 'Post'
*                     ENDIF
*                ENDIF
*           ENDIF
*      ENDIF
* ENDIF
* SELECT (naRea)
* RETURN
ENDPROC
*
FUNCTION vRoomNum
 PARAMETER p_Row, p_Col
 PRIVATE l_Retval, naRea, l_Oldord
 PRIVATE a_Field
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "reservat.rs_roomnum"
 a_Field[1, 2] = 5
 a_Field[2, 1] = "address.ad_lname"
 a_Field[2, 2] = 25
 l_Retval = .F.
 naRea = SELECT()
 l_Oldord = ORDER("reservat")
 l_Oldrec = RECNO("reservat")
 IF  .NOT. EMPTY(l_Roomnum)
      SELECT reServat
      SET ORDER IN "reservat" TO 6
      DO CASE
           CASE SEEK("1"+l_Roomnum, "reservat") .AND. EMPTY(reServat.rs_out)
                l_Newid = reServat.rs_reserid
                l_Lname = reServat.rs_lname
                l_Retval = .T.
                SHOW GETS
           CASE SEEK("1"+TRIM(l_Roomnum), "reservat") .OR. SEEK("1",  ;
                "reservat")
                IF myPopup("wRedirect",p_Row,p_Col,5,@a_Field, ;
                   'Empty(rs_out)','rs_in = "1"')>0
                     l_Newid = reServat.rs_reserid
                     l_Roomnum = reServat.rs_roomnum
                     l_Lname = reServat.rs_lname
                     l_Retval = .T.
                     SHOW GETS
                ENDIF
           OTHERWISE
                = alErt(GetLangText("CHKOUT2","TA_NOINHOUSE")+"!")
      ENDCASE
      SET ORDER IN "reservat" TO l_OldOrd
      GOTO l_Oldrec IN "reservat"
      SELECT (naRea)
 ELSE
      l_Retval = .T.
 ENDIF
 RETURN l_Retval
ENDFUNC
*
FUNCTION vLName
 PARAMETER p_Row, p_Col
 PRIVATE l_Retval, naRea, l_Oldord, l_Oldrec
 PRIVATE a_Field
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "reservat.rs_roomnum"
 a_Field[1, 2] = 5
 a_Field[2, 1] = "address.ad_lname"
 a_Field[2, 2] = 25
 naRea = SELECT()
 l_Oldord = ORDER("reservat")
 l_Oldrec = RECNO("reservat")
 l_Retval = .F.
 IF  .NOT. EMPTY(l_Lname)
      SELECT reServat
      SET ORDER IN "reservat" TO 7
      DO CASE
           CASE SEEK("1"+UPPER(TRIM(l_Lname)), "reservat") .OR. SEEK("1",  ;
                "reservat")
                IF myPopup("wRedirect",p_Row,p_Col,5,@a_Field, ;
                   'Empty(rs_out)','rs_in = "1"')>0
                     l_Newid = reServat.rs_reserid
                     l_Lname = reServat.rs_lname
                     l_Roomnum = reServat.rs_roomnum
                     l_Retval = .T.
                     SHOW GETS
                ENDIF
           OTHERWISE
                = alErt(GetLangText("CHKOUT2","TA_NOINHOUSE")+" !")
      ENDCASE
      SET ORDER IN "reservat" TO l_OldOrd
      GOTO l_Oldrec IN "reservat"
      SELECT (naRea)
 ELSE
      l_Retval = .T.
 ENDIF
 RETURN l_Retval
ENDFUNC
*
FUNCTION vArrival
 PRIVATE l_Retval, naRea, l_Addrid
 LOCAL l_reserid
 l_reserid = reservat.rs_reserid
 l_Retval = .F.
 l_Addrid = reServat.rs_addrid
 IF  .NOT. EMPTY(l_Arrival)
      naRea = SELECT()
      SELECT reServat
      l_Oldrec = RECNO()
      SCAN FOR rs_addrid = l_Addrid
           IF NOT INLIST(reservat.rs_status, "CXL", "NS") AND (l_reserid <> reservat.rs_reserid) AND (l_Arrival == rs_arrdate)
                 l_Newid = reServat.rs_reserid
                 l_Retval = .T.
                 EXIT	        	
            ENDIF
      ENDSCAN
      GOTO l_Oldrec
      SELECT (naRea)
 ELSE
      l_Retval = .T.
 ENDIF
 RETURN l_Retval
ENDFUNC
*
PROCEDURE SetBillStyle
 PARAMETER pnWindow
 LOCAL LDefStyle, LNumDefStyle
 DEFINE POPUP puStyle MARGIN SHORTCUT
 DEFINE BAR 1 OF puStyle PROMPT "\<1 "+GetLangText("CHKOUT2","TM_DETAIL")
 DEFINE BAR 2 OF puStyle PROMPT "\<2 "+GetLangText("CHKOUT2","TM_DAYART")
 DEFINE BAR 3 OF puStyle PROMPT "\<3 "+GetLangText("CHKOUT2","TM_ART")
 DEFINE BAR 4 OF puStyle PROMPT "\<4 "+GetLangText("CHKOUT2","TM_ARTPRICE")
 DEFINE BAR 5 OF puStyle PROMPT "\<5 "+GetLangText("CHKOUT2","TM_DAY")
 DEFINE BAR 6 OF puStyle PROMPT "\<6 "+GetLangText("CHKOUT2","TM_DAYARTPRICE")
 DEFINE BAR 7 OF puStyle PROMPT "\<7 "+GetLangText("CHKOUT2","TM_ROOM")
 DEFINE BAR 8 OF puStyle PROMPT "\<8 "+GetLangText("CHKOUT2","TM_ROOMDAYART")
 DEFINE BAR 9 OF puStyle PROMPT "\<9 "+GetLangText("CHKOUT2","TM_TOTALSTAY")
 DEFINE BAR 10 OF puStyle PROMPT "1\<0 "+GetLangText("CHKOUT2","TM_PRINTCODE")
 DEFINE BAR 11 OF puStyle PROMPT "11 "+GetLangText("CHKOUT2","TM_ONLYROOM")
 DEFINE BAR 12 OF puStyle PROMPT "12 "+GetLangText("CHKOUT2","TM_ROOMPRINTCODE")
 DEFINE BAR 13 OF puStyle PROMPT "\-"
 DEFINE BAR 14 OF puStyle PROMPT "\<"+GetLangText("CHKOUT2","TXT_NOTE")
 
 g_Billstyle = ProcBillStyle(reservat.rs_rsid, pnWindow, @g_UseBDateInStyle)
 SET MARK OF BAR g_Billstyle OF puStyle TO .T.
 
 ON SELECTION POPUP puStyle DO SETSTYLE WITH BAR(), PNWINDOW
 l_Bars = CNTBAR("puStyle")
 l_Max = 1
 FOR l_I = 1 TO l_Bars
      l_Max = MAX(l_Max, LEN(PRMBAR("puStyle", l_I)))
 ENDFOR
 l_Row = (WROWS()-l_Bars)/2
 l_Col = (WCOLS()-l_Max-4)/2
 MOVE POPUP puStyle TO l_Row, l_Col
 ACTIVATE POPUP puStyle
 RELEASE POPUPS puStyle
 RETURN
ENDPROC
*
PROCEDURE SetStyle
 PARAMETER p_Style, pnWindow
 IF p_Style == 14
      DO geTnote WITH pnWindow
 ELSE
      g_Billstyle = p_Style
      DO WriteBillStyle IN ProcBillStyle WITH reservat.rs_rsid, pnWindow, g_Billstyle
 ENDIF
 DEACTIVATE POPUP puStyle
 RELEASE POPUPS puStyle
 RETURN
ENDPROC
*
PROCEDURE ComPayScreen
 l_Txtsize = 12
 l_To = l_Col+l_Txtsize
 = txTpanel(l_Row,l_Col,l_To,GetLangText("CHKOUT2","T_PAYNUM"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 14
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("CHKOUT2","T_AMOUNT"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 17
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("CHKOUT2","T_RATE"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 22
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("CHKOUT2","T_DEFAULT"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 25
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("CHKOUT2","T_CUSTOM"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 25
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("CHKOUT2","T_SUPPLEM"),l_Txtsize)
 = txTpanel(12,2,12,GetLangText("CHKOUT2","T_BALANCE"),10)
 RETURN
ENDPROC
*
FUNCTION Redirect
 PARAMETER nrEserid
 PRIVATE clEvel
 PRIVATE nsElectedbutton
 PRIVATE cbUttons
 PRIVATE nrEsid, nwIndow, nsEtid, npSrec, npSord, naRea
 PRIVATE ALL LIKE l_*
 nsElectedbutton = 1
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
 l_Roomnum = SPACE(4)
 l_Lname = SPACE(25)
 l_Arrival = CTOD("")
 l_Newid = 0
 l_Oldid = nrEserid
 naRea = SELECT()
 DEFINE WINDOW wrEdirect AT 0, 0 SIZE 5.500, 80 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("CHKOUT2","TW_REDIRECT")) NOMDI DOUBLE
 MOVE WINDOW wrEdirect CENTER
 ACTIVATE WINDOW wrEdirect
 = paNelborder()
 = paNel((0.9375),(2.66666666666667),(2.0625),(23.3333333333333),2)
 = paNel((2.1875),(2.66666666666667),(3.3125),(23.3333333333333),2)
 = paNel((3.4375),(2.66666666666667),(4.5625),(23.3333333333333),2)
 @ 1.000, 4.000 SAY GetLangText("CHKOUT2","T_ROOMNUM")
 @ 2.250, 4.000 SAY GetLangText("CHKOUT2","T_LNAME")
 @ 3.500, 4.000 SAY GetLangText("CHKOUT2","T_NEXTARR")
 @ 1.000, 25.000 GET l_Roomnum SIZE 1, 30 PICTURE "@K !!!!" VALID  ;
   vrOomnum(0.25,25.00) WHEN l_Newid=0
 @ 2.250, 25.000 GET l_Lname SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)  ;
   VALID vlName(0.25,25.00) WHEN l_Newid=0
 @ 3.500, 25.000 GET l_Arrival SIZE 1, siZedate() PICTURE "@K" VALID  ;
   vaRrival() WHEN l_Newid=0
 @ 1, 60 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"V" PICTURE cbUttons
 READ CYCLE MODAL
 RELEASE WINDOW wrEdirect
 = chIldtitle("")
 DO CASE
      CASE nsElectedbutton==1 .AND. nrEserid<=-10 .AND. l_Newid>0
           LOCAL l_nExtens
           SELECT poSt
           SCAN FOR &cForClause AND NOT EMPTY(ps_marker)
                DO BoothNum IN Booth WITH post.ps_reserid, l_nExtens
                REPLACE ps_supplem WITH GetLangText("CHKOUT2","TXT_PHONE_BOOTH")+;
                        " "+LTRIM(STR(l_nExtens))
           ENDSCAN
           REPLACE ps_reserid WITH l_Newid, ;
                   ps_touched WITH .T., ;
                   ps_marker WITH "" ;
                   ALL FOR &cForClause AND NOT EMPTY(ps_marker) IN post
           GOTO TOP
      CASE nsElectedbutton==1 .AND. l_Newid>0
           WAIT WINDOW NOWAIT "Transfer..."
           SELECT teMp
           GOTO TOP
           DO WHILE  .NOT. EOF()
                GOTO teMp.tp_recno IN "post"
                IF .NOT. EMPTY(teMp.tp_marker)
                     nrEsid = poSt.ps_reserid
                     nwIndow = poSt.ps_window
                     nsEtid = poSt.ps_setid
                     REPLACE poSt.ps_reserid WITH l_Newid, poSt.ps_touched  ;
                             WITH .T., poSt.ps_supplem WITH  ;
                             TRIM(reServat.rs_roomnum)+" "+ ;
      						 MakeProperName(reServat.rs_lname)
      *                       TRIM(PROPER(reServat.rs_lname))
                     FLUSH
                     IF nsEtid>0
                          naRea = SELECT()
                          SELECT poSt
                          npSrec = RECNO()
                          npSord = ORDER()
                          REPLACE ps_reserid WITH l_Newid, ps_touched WITH .T.,  ;
	                             ps_supplem WITH TRIM(reServat.rs_roomnum)+ ;
	                             " "+MakeProperName(reServat.rs_lname) ALL FOR  ;
	                             ps_reserid=nrEsid .AND. ps_window=nwIndow  ;
	                             .AND. ps_setid=nsEtid
                          FLUSH
                          SET ORDER TO nPsOrd
                          GOTO npSrec
                          SELECT (naRea)
                     ENDIF
                ENDIF
                SKIP 1
           ENDDO
           ZAP
           WAIT CLEAR
 ENDCASE
 SELECT (naRea)
 RETURN .T.
ENDFUNC
*
PROCEDURE GetNote
 PARAMETER pnWindow
 PRIVATE cnOte, nbUtton, cbUttons, cfLd, naRea
 DEFINE WINDOW wfOlionote AT 0, 0 SIZE 5, 80.000 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE GetLangText("CHKOUT2","TXT_NOTE")+" "+STR(pnWindow, 1)  ;
        NOMDI DOUBLE
 MOVE WINDOW wfOlionote CENTER
 ACTIVATE WINDOW wfOlionote
 nbUtton = 1
 cbUttons = "\!"+buTton("",GetLangText("COMMON","TXT_OK"),1)+buTton("", ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 cnOte = FNGetWindowData(Reservat.Rs_rsid, pnWindow, "pw_note")
 @ 1, 1 EDIT cnOte SIZE 3.25, 60 SCROLL
 @ 1, 64 GET nbUtton STYLE "B" SIZE nbUttonheight, 15 FUNCTION "*"+"V"  ;
   PICTURE cbUttons
 READ CYCLE MODAL
 RELEASE WINDOW wfOlionote
 IF LASTKEY()<>27
      naRea = SELECT()
      FNSetWindowData(Reservat.Rs_rsid, pnWindow, "pw_note", AllTrim(cNote))
      FLUSH
      SELECT (naRea)
 ENDIF
 RETURN
ENDPROC
*
