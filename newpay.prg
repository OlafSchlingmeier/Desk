*Program newpay.prg
*
FUNCTION NewPay
 PARAMETER p_Reserid, p_Window, cpAymethod, pnAddressid
 PRIVATE nsElectedbutton, loPendrawer, ntOpayamt, cfLd
 PRIVATE ALL LIKE l_*
 nsElectedbutton = 1
 loPendrawer = .F.
 l_Row = 0.5
 l_Col = 2
 l_Oldrec = RECNO("post")
 l_Oldarea = SELECT()
 SELECT poSt
 SCATTER BLANK MEMVAR
 DEFINE WINDOW wpAy FROM 0, 0 TO 16, IIF(g_Nscreenmode==1, 104, 126) FONT  ;
        "Arial", 10 NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("CHKOUT2", ;
        "TW_PAY")) NOMDI DOUBLE
 MOVE WINDOW wpAy CENTER
 ACTIVATE WINDOW wpAy
 DO coMpayscreen IN ChkOut2
 l_Row = 2
 DO WHILE .T.
      ntOpayamt = baLance(p_Reserid,p_Window)
      l_Defunits = 0.00
      = coMpayget(ntOpayamt,"wPay",cpAymethod,pnAddressid)
      IF LASTKEY()=27 .OR. M.ps_paynum==0
           EXIT
      ELSE
           l_Saveunits = M.ps_units
           IF M.ps_units>0 .AND.  .NOT. EMPTY(paYmetho.pm_addamnt)
                M.ps_units = (M.ps_units+paYmetho.pm_addamnt)
           ENDIF
           IF (M.ps_units>0 .AND. paYmetho.pm_paytyp==5)
                IF ( .NOT. EMPTY(paYmetho.pm_addpct))
                     M.ps_units = (paYmetho.pm_addpct*M.ps_units/100)*-1
                ENDIF
           ELSE
                IF M.ps_units>0 .AND.  .NOT. EMPTY(paYmetho.pm_addpct)
                     M.ps_units = M.ps_units+(paYmetho.pm_addpct* ;
                                  M.ps_units/100)
                ENDIF
           ENDIF
           M.ps_reserid = p_Reserid
           M.ps_origid = p_Reserid
           M.ps_window = p_Window
           M.ps_date = sySdate()
           M.ps_time = TIME()
           M.ps_amount = -ROUND(M.ps_units*paYmetho.pm_calcrat, 2)
           M.ps_userid = cuSerid
           M.ps_cashier = g_Cashier
           M.ps_currtxt = ''
           = cuRrcnv(M.ps_paynum,M.ps_units,0,0,@M.ps_currtxt)
           M.ps_postid = neXtid('Post')
           INSERT INTO Post FROM MEMVAR
           FLUSH
           IF l_Defunits=M.ps_units
                = roUndit(M.ps_reserid,M.ps_window,ntOpayamt,M.ps_units, ;
                  paYmetho.pm_calcrat,'','Post')
           ENDIF
           IF (M.ps_units>0 .AND.  .NOT. (l_Saveunits==M.ps_units) .AND.  ;
              paYmetho.pm_paytyp<>5)
                l_Diffamount = -M.ps_amount - l_Saveunits*paymetho.pm_calcrat
                M.ps_paynum = 0
                M.ps_supplem = ""
                M.ps_units = 1.00
                M.ps_price = ROUND(l_Diffamount,param.pa_currdec)
                M.ps_amount = M.ps_units*M.ps_price
                M.ps_artinum = paYmetho.pm_addarti
                l_vatnum=0
                l_vatpct=0
                l_vatnum2=0
                l_vatpct2=0
                DO sarticle in particle
                cvAtmacro1 = "m.ps_vat"+LTRIM(STR(l_Vatnum))
    	        &cVATMacro1	= m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
        	    cvAtmacro2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
            	&cVATMacro2	= m.ps_amount *  (1 - (100 / (100 + l_VatPct2)))
            	IF (param.pa_exclvat)
	            	m.ps_price	= m.ps_price - ;
	            					ROUND(&cvatmacro1,param.pa_currdec) - ;
	            					ROUND(&cvatmacro2,param.pa_currdec)
	            	m.ps_amount	= m.ps_amount - ;
	            					ROUND(&cvatmacro1,param.pa_currdec) - ;
	            					ROUND(&cvatmacro2,param.pa_currdec)
		        ENDIF
		        M.ps_postid = neXtid('Post')
                INSERT INTO Post FROM MEMVAR
                FLUSH
           ENDIF
           IF  .NOT. loPendrawer
                loPendrawer = paYmetho.pm_opendrw
           ENDIF
      ENDIF
 ENDDO
 RELEASE WINDOW wpAy
 IF loPendrawer
      = drWopen()
 ENDIF
 DO prIntthevoucher IN Voucher
 = chIldtitle("")
 GOTO l_Oldrec IN "post"
 SELECT (l_Oldarea)
 RETURN .T.
ENDFUNC
*
PROCEDURE ComPayGet
 PARAMETER p_Nbalance, nbIllwindowname, cpAymethod, pnAddressid
 lnOpayallowed = (UPPER(nbIllwindowname)=="WPAY")
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),-1)
 IF ( .NOT. EMPTY(cpAymethod))
      M.ps_paynum = dbLookup("PayMetho",2,UPPER(cpAymethod), ;
                    "PayMetho.Pm_PayNum",.T.)
 ELSE
      M.ps_paynum = 0
 ENDIF
 M.ps_units = 0
 M.ps_price = 0
 M.ps_descrip = SPACE(25)
 M.ps_supplem = SPACE(25)
 l_Lang = SPACE(25)
 l_Col = 2
 l_Row = l_Row+1
 IF (l_Row>10)
      SCROLL 3, 1.5, 10, IIF(g_Nscreenmode==1, 97, 119), 1
      l_Row = 10
 ENDIF
 l_Balance = p_Nbalance
 @ 12, 13 SAY TRANSFORM(l_Balance, RIGHT(gcCurrcydisp, 15)) STYLE "B"  ;
   SIZE 1, 17
 @ l_Row, l_Col GET M.ps_paynum SIZE 1, 12 PICTURE "@K 99" VALID  ;
   vpAymeth(ROW(),COL()-14,nbIllwindowname,pnAddressid)
 l_Col = l_Col+13
 @ l_Row, l_Col GET M.ps_units SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy,  ;
   12) VALID M.ps_units<>0 .OR. LASTKEY()==27 WHEN ( .NOT.  ;
   EMPTY(M.ps_paynum) .AND. paYmetho.pm_paytyp<>5) .AND. ( .NOT.  ;
   EMPTY(M.ps_paynum) .AND. paYmetho.pm_paytyp<>7) .AND.  ;
   xsEtvar(@l_Defunits,M.ps_units)
 l_Col = l_Col+15
 @ l_Row, l_Col GET M.ps_price SIZE 1, 17 PICTURE "@K 9999999.999999"  ;
   WHEN .F. COLOR ,RGB(0,0,255,192,192,192)
 l_Col = l_Col+18
 l_Txtsize = 22
 @ l_Row, l_Col GET l_Lang SIZE 1, l_Txtsize WHEN .F.
 l_Col = l_Col+l_Txtsize+1
 l_Txtsize = 25
 @ l_Row, l_Col GET M.ps_descrip SIZE 1, l_Txtsize PICTURE "@K "+ ;
   REPLICATE("X", l_Txtsize) WHEN  .NOT. EMPTY(M.ps_paynum)
 l_Col = l_Col+l_Txtsize+1
 @ l_Row, l_Col GET M.ps_supplem SIZE 1, l_Txtsize PICTURE "@K "+ ;
   REPLICATE("X", l_Txtsize) VALID IIF(M.ps_units*M.ps_price<0,  .NOT.  ;
   EMPTY(M.ps_supplem), .T.) .AND. skIpok() WHEN  .NOT. EMPTY(M.ps_paynum)
 @ 12, 50 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"H" PICTURE cbUttons
 PUSH KEY CLEAR
 READ CYCLE MODAL
 POP KEY
 RETURN
ENDPROC
*
