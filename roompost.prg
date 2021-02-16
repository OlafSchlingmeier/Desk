PROCEDURE RoomPostProcess
 LOCAL l_nBalance, l_nWindow, l_oResult, l_nAddrID, l_nReserID, l_oResult, l_lNewResTran
 l_nBalance = 0
 l_nWindow = 1
 l_nAddrID = 0
 l_nReserID = 0
 l_oResult = .NULL.
 * create cursor
 DO CursorPostPayCreate IN ProcBill
 * Call form for post.
 DO FORM "forms/postpay" ;
          WITH "ROOM_POST", l_nWindow, l_nAddrId, l_nReserId, l_nBalance ;
          TO l_oResult
 IF VARTYPE(l_oResult)="L" AND l_oResult = .T.
      IF _screen.oglobal.oparam2.pa_restran
           l_lNewResTran = post.ps_postid < 0 AND post.ps_artinum > 0 AND post.ps_window > 0 AND (EMPTY(post.ps_ratecod) OR post.ps_split)
      ENDIF
      FNNextIdTempWriteRealId("post", "ps_postid", "POST")
      IF l_lNewResTran
           ProcReservatTransactions("reservat", "EDIT")
      ENDIF
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE Post
LOCAL l_oDummyForm
 IF NOT userpid()
     RETURN
 ENDIF
 DO FORM "forms\RoomPostDummy" NAME l_oDummyForm NOSHOW
 l_oDummyForm.Release()
 RETURN
*
 PRIVATE lvOucherused
 PRIVATE ALL LIKE l_*
 IF  .NOT. usErpid()
      RETURN
 ENDIF
 lvOucherused = .F.
 l_Row = 0.5
 l_Col = 2
 l_Vat = "m.ps_vat"
 l_Vat2 = "m.ps_vat2"
 DIMENSION l_aWin(1)
 l_Oldrec = RECNO("post")
 l_Oldarea = SELECT()
 SELECT poSt
 SCATTER BLANK MEMVAR
 DEFINE WINDOW wrOompost FROM 0.000, 0.000 TO 24, 129 FONT "Arial", 10  ;
        NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("ROOMPOST","TW_ROOMPOST"))  ;
        NOMDI DOUBLE
 MOVE WINDOW wrOompost CENTER
 ACTIVATE WINDOW NOSHOW wrOompost
 l_Txtsize = 12
 l_To = l_Col+l_Txtsize
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_ROOMNUM"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 15
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_LNAME"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 7
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_ARTINUM"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 11
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_UNITS"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 12
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_PRICE"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = IIF(g_Nscreenmode==1, 11, 20)
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_DEFAULT"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = IIF(g_Nscreenmode==1, 11, 20)
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_CUSTOM"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = IIF(g_Nscreenmode==1, 11, 20)
 l_To = l_To+l_Txtsize+1
 = txTpanel(l_Row,l_Col,l_To,GetLangText("ROOMPOST","T_SUPPLEM"),l_Txtsize)
 = txTpanel(21,2,12,GetLangText("ROOMPOST","T_BALANCE"),10)
 l_Row = 2
 l_cRM_RMNAME = SPACE(10)
 l_Lname = SPACE(15)
 l_Reserid = 0
 = vbAlance()
 SHOW WINDOW wrOompost
 DO WHILE .T.
      M.ps_artinum = 0
      M.ps_units = 1
      M.ps_price = 0
      M.ps_vat0 = 0
      M.ps_vat1 = 0
      M.ps_vat2 = 0
      M.ps_vat3 = 0
      M.ps_vat4 = 0
      M.ps_vat5 = 0
      M.ps_vat6 = 0
      M.ps_vat7 = 0
      M.ps_vat8 = 0
      M.ps_vat9 = 0
      M.ps_paynum = 0
      M.ps_descrip = SPACE(25)
      M.ps_supplem = SPACE(25)
      l_Lang = SPACE(25)
      l_Vatnum = 0
      l_Vatpct = 0
      l_Vatnum2 = 0
      l_Vatpct2 = 0
      l_Col = 2
      l_Row = l_Row+1
      IF l_Row>18
           SCROLL 3, 1.5, 18, IIF(g_Nscreenmode==1, 93, 120), 1
           l_Row = 18
      ENDIF
      @ l_Row, l_Col GET l_cRM_RMNAME SIZE 1, 12 PICTURE "@K !!!!!!!!!!" VALID  ;
        LASTKEY()=27 .OR. (vrOomnum(ROW(),COL()-6) .AND. vbAlance())
      l_Col = l_Col+13
      @ l_Row, l_Col GET l_Lname SIZE 1, 15 PICTURE "@K "+REPLICATE("X",  ;
        10) VALID LASTKEY()=27 .OR. (vlName(ROW(),COL()-15) .AND.  ;
        vbAlance()) WHEN EMPTY(l_cRM_RMNAME)
      l_Col = l_Col+16
      @ l_Row, l_Col GET M.ps_artinum SIZE 1, 7 PICTURE "@K 9999" VALID  ;
        LASTKEY()=27 .OR. vaRticle(ROW(),COL()-7)
      l_Col = l_Col+8
      @ l_Row, l_Col GET M.ps_units SIZE 1, 11 PICTURE "@K 9999" VALID  ;
        IIF(dblookup("article","tag1",M.ps_artinum,"ar_artityp")==4, M.ps_units=1, M.ps_units<>0)
      l_Col = l_Col+12
      @ l_Row, l_Col GET M.ps_price SIZE 1, 12 PICTURE "@K "+ ;
        RIGHT(gcCurrcy, 10) VALID M.ps_price>=0
      l_Col = l_Col+13
      l_Txtsize = IIF(g_Nscreenmode==1, 11, 20)
      @ l_Row, l_Col GET l_Lang SIZE 1, l_Txtsize WHEN .F.
      l_Col = l_Col+l_Txtsize+1
      @ l_Row, l_Col GET M.ps_descrip SIZE 1, l_Txtsize PICTURE "@K "+ ;
        REPLICATE("X", 25)
      l_Col = l_Col+l_Txtsize+1
      @ l_Row, l_Col GET M.ps_supplem SIZE 1, l_Txtsize PICTURE "@K "+ ;
        REPLICATE("X", 25) VALID IIF(M.ps_units<0,  .NOT.  ;
        EMPTY(M.ps_supplem), .T.)
      l_Col = (WCOLS()-15)/2
      @ WROWS()-2.5, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE  ;
        nbUttonheight, 15 PICTURE "@*TH \?"+GetLangText("COMMON","TXT_CLOSE")  ;
        WHEN LASTKEY()=27 .OR. MDOWN()
      PUSH KEY CLEAR
      READ MODAL
      POP KEY
      IF LASTKEY()=27 .OR. M.ps_artinum==0
           EXIT
      ELSE
           l_Id = l_Reserid
           l_Window = 1
           DO biLlinstr IN BillInst WITH M.ps_artinum,  ;
              reServat.rs_billins, l_Id, l_Window
           IF l_Id<>l_Reserid
                M.ps_supplem = get_rm_rmname(reServat.rs_roomnum)+" "+adDress.ad_lname
           ENDIF
           M.ps_reserid = l_Id
           M.ps_window = l_Window
           M.ps_origid = l_Reserid
           M.ps_date = sySdate()
           M.ps_time = TIME()
           M.ps_amount = M.ps_price*M.ps_units
           M.ps_userid = cuSerid
           M.ps_cashier = g_Cashier
           IF (paRam.pa_exclvat)
                l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                &l_Vat               = m.ps_amount * (l_VatPct / 100)
                IF paRam.pa_compvat
                     l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &l_Vat2 = (m.ps_amount + &l_Vat) * (l_VatPct2 / 100)
                ELSE
                     l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &l_Vat2 = m.ps_amount * (l_VatPct2 / 100)
                ENDIF
           ELSE
                l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                &l_Vat               = m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
                l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                &l_Vat2               = m.ps_amount * ( 1 - (100 / (100 + l_VatPct2)))
           ENDIF
           M.ps_postid = neXtid('Post')
           INSERT INTO Post FROM MEMVAR
           FLUSH
           IF arTicle.ar_stckctl
                REPLACE arTicle.ar_stckcur WITH arTicle.ar_stckcur-M.ps_units
           ENDIF
                 LOCAL naRtitype 
            naRtitype = arTicle.ar_artityp
            DO CASE
                 CASE naRtitype==2
                      l_Lastrec = RECNO()
                      M.ps_artinum = 0
                      IF paRam.pa_currloc<>0
                           M.ps_paynum = paRam.pa_currloc
                      ELSE
                           M.ps_paynum = 1
                      ENDIF
                      M.ps_reserid = 0.200
                      M.ps_origid = 0.200
                      M.ps_price = 1.00
                      M.ps_supplem = get_rm_rmname(reServat.rs_roomnum)+' '+ ;
                       reServat.rs_lname
                      M.ps_units = -M.ps_amount
                      M.ps_amount = M.ps_amount
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
                      GOTO l_Lastrec
                 CASE naRtitype==4
                      nVoucherNum = Voucher("Post", "Reservat")
                      lVoucherUsed = NOT EMPTY(nVoucherNum)
                      IF lVoucherUsed
                           REPLACE ps_voucnum WITH nVoucherNum, ;
                                   ps_vouccpy WITH 1 IN Post
                      ENDIF
            ENDCASE
*           IF (arTicle.ar_artityp==4)
*                lvOucherused = voUcher("Post")
*           ENDIF
       ENDIF
 ENDDO
 RELEASE WINDOW wrOompost
 IF (lvOucherused)
      DO prIntthevoucher IN Voucher
 ENDIF
 = chIldtitle("")
 GOTO l_Oldrec IN "post"
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
FUNCTION vArticle
 PARAMETER p_Row, p_Col
 PRIVATE l_Oldarea, l_Retval
 PRIVATE a_Field
 DIMENSION a_Field[3, 2]
 a_Field[1, 1] = "ar_artinum"
 a_Field[1, 2] = 5
 a_Field[2, 1] = "ar_lang"+g_Langnum
 a_Field[2, 2] = 25
 a_Field[3, 1] = "ar_price"
 a_Field[3, 2] = 10
 l_Oldarea = SELECT()
 l_Retval = .F.
 SELECT arTicle
 IF EMPTY(M.ps_artinum) .OR.  .NOT. SEEK(M.ps_artinum) .or. ar_inactiv&& .OR. ar_artityp=2
      GOTO TOP IN arTicle
*      IF myPopup("wRoomPost",p_Row+1,p_Col,5,@a_Field,"ar_artityp <> 2",".t.")>0
      IF myPopup("wRoomPost",p_Row+1,p_Col,5,@a_Field,"!ar_inactiv",".t.")>0
           M.ps_artinum = ar_artinum
           M.ps_price = ar_price
           M.l_Lang = EVALUATE("ar_lang"+g_Langnum)
           SHOW GET M.ps_price
           SHOW GET l_Lang
           l_Retval = .T.
      ENDIF
 ELSE
      M.ps_price = ar_price
      M.l_Lang = EVALUATE("ar_lang"+g_Langnum)
      SHOW GET M.ps_price
      SHOW GET l_Lang
      l_Retval = .T.
 ENDIF
 IF l_Retval
      SELECT piCklist
      SET ORDER TO 3
      = SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat, 3))
      l_Vatnum = arTicle.ar_vat
      l_Vatpct = piCklist.pl_numval
      = SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat2, 3))
      l_Vatnum2 = arTicle.ar_vat2
      l_Vatpct2 = piCklist.pl_numval
      SET ORDER TO 1
 ENDIF
 SELECT (l_Oldarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION vRoomNum
 PARAMETER p_Row, p_Col
 PRIVATE l_Oldarea, l_Retval, lfOund, nfOundrooms, nrSrec
 PRIVATE a_Field
 LOCAL l_cRM_ROOMNUM
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "get_rm_rmname(reservat.rs_roomnum)"
 a_Field[1, 2] = 10
 a_Field[2, 1] = "address.ad_lname"
 a_Field[2, 2] = 25
 l_Oldarea = SELECT()
 l_Retval = .F.
 IF  .NOT. EMPTY(l_cRM_RMNAME)
      l_cRM_ROOMNUM = get_rm_roomnum(l_cRM_RMNAME)
      SELECT reServat
      SET ORDER IN "reservat" TO 6
      lfOund = .F.
      nfOundrooms = 0
      DO CASE
           CASE SEEK("1"+PADR(ALLTRIM(l_cRM_ROOMNUM), 4))
                lfOund = .T.
                nrSrec = RECNO()
                COUNT REST WHILE reServat.rs_in="1" .AND.  ;
                      reServat.rs_roomnum==PADR(ALLTRIM(l_cRM_ROOMNUM), 4)  ;
                      .AND. EMPTY(reServat.rs_out) TO nfOundrooms
                GOTO nrSrec
           CASE SEEK("1")
                nfOundrooms = 0
                LOCATE REST FOR EMPTY(reServat.rs_out) WHILE reServat.rs_in="1"
                lfOund = FOUND()
           OTHERWISE
                lfOund = .F.
      ENDCASE
      DO CASE
           CASE lfOund .AND. nfOundrooms=1
             LOCAL l_lAllow
             l_aWin(1) = 1
             DO BillsReserCheck IN ProcBill WITH reservat.rs_reserid, l_aWin, ;
                       "POST_NEW", l_lAllow
             IF l_lAllow
                l_Reserid = reServat.rs_reserid
                l_Lname = adDress.ad_lname
                SHOW GET l_Lname
                SHOW GET l_cRM_RMNAME
                l_Retval = .T.
             ENDIF
           CASE lfOund .AND. nfOundrooms<>1
                IF myPopup("wRoomPost",p_Row+1,p_Col,5,@a_Field, ;
                   'Empty(rs_out)','rs_in = "1"')>0
                  LOCAL l_lAllow
                  l_aWin(1) = 1
                  DO BillsReserCheck IN ProcBill WITH reservat.rs_reserid, l_aWin, ;
                            "POST_NEW", l_lAllow
                  IF l_lAllow
                     l_Reserid = reServat.rs_reserid
                     l_Lname = adDress.ad_lname
                     l_cRM_ROOMNUM = reServat.rs_roomnum
                     l_cRM_RMNAME = get_rm_rmname(l_cRM_ROOMNUM)
                     SHOW GET l_Lname
                     SHOW GET l_cRM_RMNAME
                     l_Retval = .T.
                  ENDIF
                ENDIF
           OTHERWISE
                = alErt(GetLangText("ROOMPOST","TA_NOINHOUSE")+" !")
      ENDCASE
      SET ORDER IN "reservat" TO 1
      SELECT (l_Oldarea)
 ELSE
      l_Retval = .T.
 ENDIF
 RETURN l_Retval
ENDFUNC
*
FUNCTION vLName
 PARAMETER p_Row, p_Col
 PRIVATE l_Oldarea, l_Retval
 PRIVATE a_Field
 LOCAL l_cRM_ROOMNUM
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "get_rm_rmname(reservat.rs_roomnum)"
 a_Field[1, 2] = 10
 a_Field[2, 1] = "address.ad_lname"
 a_Field[2, 2] = 25
 l_Oldarea = SELECT()
 l_Retval = .F.
 SELECT reServat
 SET ORDER IN "reservat" TO 7
 DO CASE
      CASE SEEK("1"+UPPER(TRIM(l_Lname)), "reservat") .OR. SEEK("1",  ;
           "reservat")
           IF myPopup("wRoomPost",p_Row+1,p_Col,5,@a_Field, ;
              'Empty(rs_out)','rs_in = "1"')>0
             LOCAL l_lAllow
             l_aWin(1) = 1
             DO BillsReserCheck IN ProcBill WITH reservat.rs_reserid, l_aWin, ;
                       "POST_NEW", l_lAllow
             IF l_lAllow
                l_Reserid = reServat.rs_reserid
                l_cRM_ROOMNUM = reServat.rs_roomnum
                l_cRM_RMNAME = get_rm_rmname(l_cRM_ROOMNUM)
                l_Lname = adDress.ad_lname
                SHOW GET l_Lname
                SHOW GET l_cRM_RMNAME
                l_Retval = .T.
             ENDIF
           ENDIF
      OTHERWISE
           = alErt(GetLangText("ROOMPOST","TA_NOINHOUSE")+" !")
 ENDCASE
 SET ORDER IN "reservat" TO 1
 SELECT (l_Oldarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION vBalance
 @ 21, 13 SAY baLance(l_Reserid,1)+baLance(l_Reserid,2)+baLance(l_Reserid, ;
   3) SIZE 1, 12
 RETURN .T.
ENDFUNC
*
