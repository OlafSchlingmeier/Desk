*Programm newpost.prg
*
FUNCTION NewPost
 PARAMETER npOstreserid, npOstwindow
 PRIVATE l_Lang
 PRIVATE l_Row
 PRIVATE l_Col
 PRIVATE l_Txtsize
 PRIVATE nsElectedbutton
 PRIVATE naRtitype
 PRIVATE npOstrecord
 PRIVATE ntO
 PRIVATE cvAtmacro1
 PRIVATE cvAtmacro2
 PRIVATE lvOucherused
 lvOucherused = .F.
 nsElectedbutton = 2
 l_Row = 0.5
 l_Col = 2
 cvAtmacro1 = "m.ps_vat"
 cvAtmacro2 = "m.ps_vat"
 npOstrecord = RECNO("post")
 SELECT poSt
 SCATTER BLANK MEMVAR
 DEFINE WINDOW wpOst FROM 0, 0 TO 16, IIF(g_Nscreenmode==1, 100, 127)  ;
        FONT "Arial", 10 NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("CHKOUT2", ;
        "TW_POST")) NOMDI DOUBLE
 MOVE WINDOW wpOst CENTER
 ACTIVATE WINDOW wpOst
 l_Txtsize = 10
 ntO = l_Col+l_Txtsize
 = txTpanel(l_Row,l_Col,ntO,GetLangText("CHKOUT2","T_ARTINUM"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 10
 ntO = ntO+l_Txtsize+1
 = txTpanel(l_Row,l_Col,ntO,GetLangText("CHKOUT2","T_UNITS"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 12
 ntO = ntO+l_Txtsize+1
 = txTpanel(l_Row,l_Col,ntO,GetLangText("CHKOUT2","T_PRICE"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = IIF(g_Nscreenmode==1, 17, 25)
 ntO = ntO+l_Txtsize+1
 = txTpanel(l_Row,l_Col,ntO,GetLangText("CHKOUT2","T_DEFAULT"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = IIF(g_Nscreenmode==1, 17, 25)
 ntO = ntO+l_Txtsize+1
 = txTpanel(l_Row,l_Col,ntO,GetLangText("CHKOUT2","T_CUSTOM"),l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = IIF(g_Nscreenmode==1, 17, 25)
 ntO = ntO+l_Txtsize+1
 = txTpanel(l_Row,l_Col,ntO,GetLangText("CHKOUT2","T_SUPPLEM"),l_Txtsize)
 = txTpanel(12,2,12,GetLangText("CHKOUT2","T_BALANCE"),10)
 l_Row = 2
 lpOsting = .T.
 DO WHILE (lpOsting)
      l_Lang = SPACE(25)
      l_Vatnum = 0
      l_Vatpct = 0
      l_Vatnum2 = 0
      l_Vatpct2 = 0
      naRtitype = 0
      l_Col = 2
      l_Row = l_Row+1
      = coMposting(baLance(npOstreserid,npOstwindow),"wPost")
      IF (LASTKEY()=27 .OR. M.ps_artinum==0 .OR. nsElectedbutton==2)
           lpOsting = .F.
      ELSE
           l_Id = npOstreserid
           l_Window = npOstwindow
           DO biLlinstr IN BillInst WITH M.ps_artinum,  ;
              reServat.rs_billins, l_Id, l_Window
           IF (l_Id<>npOstreserid)
                M.ps_supplem = reServat.rs_roomnum+" "+adDress.ad_lname
           ENDIF
           M.ps_reserid = l_Id
           M.ps_window = l_Window
           M.ps_origid = npOstreserid
           M.ps_date = sySdate()
           M.ps_time = TIME()
           M.ps_amount = M.ps_price*M.ps_units
           M.ps_userid = cuSerid
           M.ps_cashier = g_Cashier
           IF (paRam.pa_exclvat)
                cvAtmacro1 = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                &cVATMacro1	= m.ps_amount * (l_VatPct / 100)
                IF paRam.pa_compvat
                     cvAtmacro2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &cVATMacro2	= (m.ps_amount + &cVATMacro1) * (l_VatPct2 / 100)					
                ELSE
                     cvAtmacro2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &cVATMacro2	= m.ps_amount * (l_VatPct2 / 100)
                ENDIF
           ELSE
                cvAtmacro1 = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                &cVATMacro1	= m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
                cvAtmacro2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                &cVATMacro2	= m.ps_amount * ( 1 - (100 / (100 + l_VatPct2)))
           ENDIF
           IF ( .NOT. deMomax("Post"))
                M.ps_postid = neXtid('Post')
                INSERT INTO Post FROM MEMVAR
                FLUSH
                IF (arTicle.ar_stckctl)
                     REPLACE arTicle.ar_stckcur WITH arTicle.ar_stckcur- ;
                             M.ps_units
                ENDIF
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
                          M.ps_supplem = TRIM(reServat.rs_roomnum)+' '+ ;
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
           ENDIF
      ENDIF
 ENDDO
 RELEASE WINDOW wpOst
 IF (lvOucherused)
      DO prIntthevoucher IN Voucher
 ENDIF
 = chIldtitle("")
 GOTO npOstrecord IN "Post"
 RETURN .T.
ENDFUNC
*
FUNCTION ComPosting
 PARAMETER p_Nbalance, nbIllwindowname
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),-1)
 M.ps_artinum = 0
 M.ps_paynum = 0
 M.ps_units = 0
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
 M.ps_descrip = SPACE(25)
 M.ps_supplem = SPACE(25)
 IF l_Row>10
      SCROLL 3, 1.5, 10, IIF(g_Nscreenmode==1, 93, 120), 1
      l_Row = 10
 ENDIF
 @ 12, 13 SAY TRANSFORM(p_Nbalance, RIGHT(gcCurrcydisp, 15)) STYLE 'B'  ;
   SIZE 1, 16
 @ l_Row, l_Col GET M.ps_artinum SIZE 1, 10 PICTURE "@K 9999" VALID  ;
   paRticle(ROW(),COL()-10,nbIllwindowname) && geändert  27.04.2001
 l_Col = l_Col+11
 IF param.pa_untdec
 @ l_Row, l_Col GET M.ps_units SIZE 1, 10 PICTURE "@K 9999.99" VALID  ;
   vUnits(m.ps_units,m.ps_artinum) .OR. LASTKEY()==27
 ELSE
 @ l_Row, l_Col GET M.ps_units SIZE 1, 10 PICTURE "@K 9999" VALID  ;
   vUnits(m.ps_units,m.ps_artinum) .OR. LASTKEY()==27
 ENDIF
 l_Col = l_Col+11
 @ l_Row, l_Col GET M.ps_price SIZE 1, 12 PICTURE "@K "+RIGHT(gcCurrcy,  ;
   10) VALID M.ps_price>=0 .OR. LASTKEY()==27
 l_Col = l_Col+13
 l_Txtsize = IIF(g_Nscreenmode==1, 17, 25)
 @ l_Row, l_Col GET l_Lang SIZE 1, l_Txtsize WHEN .F.
 l_Col = l_Col+l_Txtsize+1
 @ l_Row, l_Col GET M.ps_descrip SIZE 1, l_Txtsize PICTURE "@K "+ ;
   REPLICATE("X", l_Txtsize)
 l_Col = l_Col+l_Txtsize+1
 @ l_Row, l_Col GET M.ps_supplem SIZE 1, l_Txtsize PICTURE "@K "+ ;
   REPLICATE("X", l_Txtsize) VALID IIF(M.ps_units<0,  .NOT.  ;
   EMPTY(M.ps_supplem), .T.) .AND. skIpok()
 @ 12, 50 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"H" PICTURE cbUttons
 PUSH KEY CLEAR
 READ CYCLE MODAL
 POP KEY
 RETURN .T.
ENDFUNC
*
FUNCTION vUnits
LPARAMETERS lp_units, lp_artinum
LOCAL l_lRetVal, l_nRecNo
l_lRetVal = .T.
l_nRecNo = RECNO("article")
IF SEEK(lp_artinum, "article", "tag1")
	IF article.ar_stckctl
		DO CASE
		 CASE article.ar_stckcur < lp_units
			= alert(GetLangText("BILL","TXT_ARTI_STOCK_NO")+ ;
				CHR(13)+ALLTRIM(STR(article.ar_stckcur)), ;
				GetLangText("CHKOUT2","TW_POST"))
			l_lRetVal = .F.
		 CASE article.ar_stckmin >= article.ar_stckcur-lp_units
			= alert(GetLangText("BILL","TXT_ARTI_STOCK_MIN"), ;
				GetLangText("CHKOUT2","TW_POST"))
		ENDCASE
	ENDIF
ENDIF
GO l_nRecNo IN article
l_lRetVal = l_lRetVal AND (lp_units <>0)
RETURN l_lRetVal
ENDFUNC
*