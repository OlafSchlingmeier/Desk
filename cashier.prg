*Programm: cashier.prg
*
PROCEDURE Cashiers
    do form "forms\MngForm" with "MngCashiCtrl"
    return

 PRIVATE cbUttons
 PRIVATE clEvel
 PRIVATE ALL LIKE l_*
 PRIVATE a_Field
 DIMENSION a_Field[2, 4]
 STORE "" TO a_Field
 a_Field[1, 1] = "Cashier.ca_name"
 a_Field[1, 2] = 40
 a_Field[1, 3] = GetLangText("CASHIER","TXT_CANAME")
 a_Field[2, 1] = "ca_number"
 a_Field[2, 2] = 20
 a_Field[2, 3] = GetLangText("CASHIER","TXT_CANUMBER")
 a_Field[2, 4] = "99 "
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_DELETE"),-4)
 SELECT caShier
 GOTO TOP
 ccAsbutton = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("CASHIER","TXT_CABROWSE"),15,@a_Field,".t.",".t.", ;
   cbUttons,"vCAControl","CASHIER")
 gcButtonfunction = ccAsbutton
 RETURN
ENDPROC
*
FUNCTION vCAControl
 PARAMETER p_Choice
 DO CASE
      CASE p_Choice==1
      CASE p_Choice==2
           DO scRcashier WITH "EDIT"
           g_Refreshall = UPDATED()
      CASE p_Choice==3
           DO scRcashier WITH "NEW"
           g_Refreshall = .T.
      CASE p_Choice==4
           IF yeSno(GetLangText("CASHIER","TXT_CADELETE")+";"+ALLTRIM(ca_name))
                DELETE
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE ScrCashier
 PARAMETER p_Option
 PRIVATE ALL LIKE l_*
 l_Choice = 1
 DO CASE
      CASE p_Option="NEW"
           SCATTER BLANK MEMVAR
      CASE p_Option="EDIT"
           SCATTER MEMVAR
 ENDCASE
 DEFINE WINDOW wcAshiers AT 0.000, 0.000 SIZE 9.250, 60.000 FONT "Arial",  ;
        10 NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("CASHIER", ;
        "TXT_CAWINDOW")) NOMDI DOUBLE
 MOVE WINDOW wcAshiers CENTER
 ACTIVATE WINDOW wcAshiers
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
 DO paNel WITH 1/4, 2/3, 6.25, WCOLS()-(0.666666666666667)
 DO paNel WITH 15/16, 8/3, 33/16, 70/3, 2
 DO paNel WITH 35/16, 8/3, 53/16, 70/3, 2
 DO paNel WITH 55/16, 8/3, 73/16, 70/3, 2
 @ 1.000, 4.000 SAY GetLangText("CASHIER","TXT_CANAME")
 @ 2.250, 4.000 SAY GetLangText("CASHIER","TXT_CANUMBER")
 @ 3.500, 4.000 SAY GetLangText("CASHIER","TXT_CAOPENMAX")
 @ 1.000, 25.000 GET M.ca_name SIZE 1, 30 PICTURE "@K "+REPLICATE("X",  ;
   LEN(M.ca_name))
 @ 2.250, 25.000 GET M.ca_number SIZE 1, 30 PICTURE "@KB 99"
 @ 3.500, 25.000 GET M.ca_opmax SIZE 1, 30 PICTURE "@KB 99"
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
   PICTURE "@*TH "+cbUttons VALID vcAchoice(p_Option)
 READ CYCLE MODAL
 RELEASE WINDOW wcAshiers
 = chIldtitle("")
 RETURN
ENDPROC
*
FUNCTION vCAChoice
 PARAMETER p_Option
 PRIVATE l_Retval
 l_Retval = .F.
 DO CASE
      CASE M.l_Choice==1
           l_Retval = .T.
           DO CASE
                CASE p_Option="NEW"
                     INSERT INTO cashier FROM MEMVAR
                CASE p_Option="EDIT"
                     GATHER MEMVAR
           ENDCASE
           CLEAR READ
      CASE M.l_Choice==2
           l_Retval = .T.
           CLEAR READ
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
PROCEDURE ToFromBank
	IF  NOT userpid()
		RETURN
	ENDIF
	doform("frmcashierlist","forms\cashierList", "WITH 'BANK'")
	RETURN 
*
 PRIVATE ALL LIKE l_*
 PRIVATE a_Fields
 DIMENSION a_Fields[2, 4]
 STORE "" TO a_Fields
 IF  .NOT. usErpid()
      RETURN
 ENDIF
 a_Fields[1, 1] = "pm_paynum"
 a_Fields[1, 2] = 15
 a_Fields[1, 3] = GetLangText("CASHIER","TH_PAYNUM")
 a_Fields[1, 4] = "99 "
 a_Fields[2, 1] = "pm_lang"+g_Langnum
 a_Fields[2, 2] = 25
 a_Fields[2, 3] = GetLangText("CASHIER","TH_DESCRIPT")
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("CASHIER","TXT_TOBANK"),2)+buTton(clEvel, ;
            GetLangText("CASHIER","TXT_FROMBANK"),-3)
 l_Oldarea = SELECT()
 SELECT paYmetho
 l_Oldrec = RECNO("paymetho")
 GOTO TOP IN "paymetho"
 ccShbutton = gcButtonfunction
 gcButtonfunction = ""
 DO myBrowse WITH GetLangText("CASHIER","TW_TOFROMBANK"), 10, a_Fields,  ;
    "InList(pm_paytyp, 1, 2) and !Inlist(pm_paynum, Param.pa_payonld, Param.pa_rndpay) and !pm_inactiv",  ;
    ".t.", cbUttons, "vTFControl", "CASHIER"
 gcButtonfunction = ccShbutton
 GOTO l_Oldrec IN "paymetho"
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
PROCEDURE vTFControl
 PARAMETER p_Option
 DO CASE
      CASE p_Option=1
      CASE p_Option=2
           DO tfGet WITH 1, GetLangText("CASHIER","TW_TOBANK")
      CASE p_Option=3
           DO tfGet WITH -1, GetLangText("CASHIER","TW_FROMBANK")
 ENDCASE
 if paymetho.pm_opendrw =.t.
 	=drwopen()
 ENDIF
 _curobj = 2
 RETURN
ENDPROC
*
PROCEDURE TFGet
 PARAMETER p_Sign, p_Title
 PRIVATE ALL LIKE l_*
 PRIVATE ncArec
 l_Amount = 0
 l_Reason = SPACE(25)
 l_Oldarea = SELECT()
 DEFINE WINDOW wtOfrom AT 0.000, 0.000 SIZE 6.500, 60.000 FONT "Arial",  ;
        10 NOCLOSE NOZOOM TITLE p_Title NOMDI DOUBLE
 MOVE WINDOW wtOfrom CENTER
 ACTIVATE WINDOW wtOfrom
 DO paNel WITH 1/4, 2/3, WROWS()-(0.25), WCOLS()-(0.666666666666667)
 DO paNel WITH 15/16, 8/3, 33/16, 70/3, 2
 DO paNel WITH 35/16, 8/3, 53/16, 70/3, 2
 @ 1.000, 4.000 SAY GetLangText("CASHIER","T_AMOUNT")
 @ 2.250, 4.000 SAY GetLangText("CASHIER","T_REASON")
 @ 1.000, 25.000 GET l_Amount SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy,  ;
   12) VALID l_Amount>0 .OR. LASTKEY()=27
 @ 2.250, 25.000 GET l_Reason SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)  ;
   VALID  .NOT. EMPTY(l_Reason) .OR. LASTKEY()=27
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 l_Choice = 0
 l_Buttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
             buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
 @ l_Row, l_Col GET l_Choice SIZE nbUttonheight, 15 PICTURE "@*TH "+l_Buttons
 READ MODAL
 RELEASE WINDOW wtOfrom
 IF LASTKEY()<>27 .AND. l_Choice=1
      SELECT poSt
      SCATTER BLANK MEMVAR
      M.ps_paynum = paYmetho.pm_paynum
      M.ps_units = -p_Sign*l_Amount
      M.ps_price = IIF(EMPTY(paYmetho.pm_rate), 1.00, paYmetho.pm_rate)
      M.ps_supplem = l_Reason
      M.ps_reserid = 0.400
      M.ps_origid = 0.400
      M.ps_date = sySdate()
      M.ps_time = TIME()
      M.ps_amount = p_Sign*ROUND(l_Amount*paYmetho.pm_calcrat, 2)
      M.ps_userid = cuSerid
      M.ps_cashier = g_Cashier
      M.ps_currtxt = ''
      = cuRrcnv(M.ps_paynum,M.ps_units,0,0,@M.ps_currtxt)
      M.ps_postid = neXtid('Post')
      INSERT INTO Post FROM MEMVAR
      FLUSH
      M.ps_amount = -M.ps_amount
      M.ps_units = -M.ps_units
      M.ps_supplem = l_Reason
      M.ps_cashier = 99
      M.ps_postid = neXtid('Post')
      INSERT INTO Post FROM MEMVAR
      FLUSH
      SELECT caShier
      ncArec = RECNO()
      LOCATE ALL FOR ca_number=99
      IF  .NOT. FOUND()
           APPEND BLANK
           REPLACE ca_number WITH 99, ca_name WITH "Housebank", ca_opmax  ;
                   WITH 99
           FLUSH
      ENDIF
      IF  .NOT. ca_isopen
           REPLACE ca_isopen WITH .T., ca_opdate WITH sySdate(),  ;
                   ca_optime WITH TIME()
           FLUSH
      ENDIF
      GOTO ncArec
      alErt(GetLangText("CASHIER","TA_TOFROMBANKDONE"))
 ENDIF
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
PROCEDURE CashInOut
	IF  NOT userpid()
		RETURN
	ENDIF
	doform("frmcashierlist","forms\cashierList","WITH 'CASH'")
	RETURN 
*
 PRIVATE ALL LIKE l_*
 PRIVATE a_Fields
 DIMENSION a_Fields[2, 4]
 STORE "" TO a_Fields
 IF  .NOT. usErpid()
      RETURN
 ENDIF
 a_Fields[1, 1] = "pm_paynum"
 a_Fields[1, 2] = 15
 a_Fields[1, 3] = GetLangText("CASHIER","TH_PAYNUM")
 a_Fields[1, 4] = "99 "
 a_Fields[2, 1] = "pm_lang"+g_Langnum
 a_Fields[2, 2] = 25
 a_Fields[2, 3] = GetLangText("CASHIER","TH_DESCRIPT")
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("CASHIER","TXT_CASHIN"),2)+buTton(clEvel, ;
            GetLangText("CASHIER","TXT_CASHOUT"),-3)
 l_Oldarea = SELECT()
 SELECT paYmetho
 l_Oldrec = RECNO("paymetho")
 GOTO TOP IN "paymetho"
 ccShbutton = gcButtonfunction
 gcButtonfunction = ""
 DO myBrowse WITH GetLangText("CASHIER","TW_CASHINOUT"), 10, a_Fields,  ;
    "InList(pm_paytyp, 1, 2) and !Inlist(pm_paynum, Param.pa_payonld, Param.pa_rndpay) and !pm_inactiv",  ;
    ".t.", cbUttons, "vIOControl", "CASHIER"
 gcButtonfunction = ccShbutton
 GOTO l_Oldrec IN "paymetho"
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
PROCEDURE vIOControl
 PARAMETER p_Option
 DO CASE
      CASE p_Option=1
      CASE p_Option=2
           DO ioGet WITH -1, GetLangText("CASHIER","TW_CASHIN")
      CASE p_Option=3
           DO ioGet WITH 1, GetLangText("CASHIER","TW_CASHOUT")
 ENDCASE
 if paymetho.pm_opendrw=.t.
 	=drwopen()
 ENDIF
 _curobj = 2
 RETURN
ENDPROC
*
PROCEDURE IOGet
 PARAMETER p_Sign, p_Title
 PRIVATE ALL LIKE l_*
 PRIVATE ncArec
 l_Amount = 0
 l_Reason = SPACE(25)
 l_Oldarea = SELECT()
 DEFINE WINDOW wtOfrom AT 0.000, 0.000 SIZE 6.500, 60.000 FONT "Arial",  ;
        10 NOCLOSE NOZOOM TITLE p_Title NOMDI DOUBLE
 MOVE WINDOW wtOfrom CENTER
 ACTIVATE WINDOW wtOfrom
 DO paNel WITH 1/4, 2/3, WROWS()-(0.25), WCOLS()-(0.666666666666667)
 DO paNel WITH 15/16, 8/3, 33/16, 70/3, 2
 DO paNel WITH 35/16, 8/3, 53/16, 70/3, 2
 @ 1.000, 4.000 SAY GetLangText("CASHIER","T_AMOUNT")
 @ 2.250, 4.000 SAY GetLangText("CASHIER","T_REASON")
 @ 1.000, 25.000 GET l_Amount SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy,  ;
   12) VALID l_Amount>0 .OR. LASTKEY()=27
 @ 2.250, 25.000 GET l_Reason SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)  ;
   VALID  .NOT. EMPTY(l_Reason) .OR. LASTKEY()=27
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 l_Choice = 0
 l_Buttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
             buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
 @ l_Row, l_Col GET l_Choice SIZE nbUttonheight, 15 PICTURE "@*TH "+l_Buttons
 READ MODAL
 RELEASE WINDOW wtOfrom
 IF LASTKEY()<>27 .AND. l_Choice=1
      SELECT poSt
      SCATTER BLANK MEMVAR
      M.ps_paynum = paYmetho.pm_paynum
      M.ps_units = -p_Sign*l_Amount
      M.ps_price = IIF(EMPTY(paYmetho.pm_rate), 1.00, paYmetho.pm_rate)
      M.ps_supplem = l_Reason
      M.ps_reserid = 0.300
      M.ps_origid = 0.300
      M.ps_date = sySdate()
      M.ps_time = TIME()
      M.ps_amount = p_Sign*ROUND(l_Amount*paYmetho.pm_calcrat, 2)
      M.ps_userid = cuSerid
      M.ps_cashier = g_Cashier
      M.ps_currtxt = ''
      = cuRrcnv(M.ps_paynum,M.ps_units,0,0,@M.ps_currtxt)
      M.ps_postid = neXtid('Post')
      INSERT INTO Post FROM MEMVAR
      FLUSH
      alErt(GetLangText("CASHIER","TA_CASHINOUTDONE"))
 ENDIF
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
PROCEDURE ChangeCash
	IF  NOT userpid()
		RETURN
	ENDIF
	doform("frmcashierchange","forms\cashierchange")
	RETURN 
*
 PRIVATE ALL LIKE l_*
 PRIVATE a_Fields
 DIMENSION a_Fields[2, 4]
 STORE "" TO a_Fields
 IF  .NOT. usErpid()
      RETURN
 ENDIF
 a_Fields[1, 1] = "pm_paynum"
 a_Fields[1, 2] = 15
 a_Fields[1, 3] = GetLangText("CASHIER","TH_PAYNUM")
 a_Fields[1, 4] = "99 "
 a_Fields[2, 1] = "pm_lang"+g_Langnum
 a_Fields[2, 2] = 25
 a_Fields[2, 3] = GetLangText("CASHIER","TH_DESCRIPT")
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("CASHIER","TXT_CHANGE"),-2)
 l_Oldarea = SELECT()
 SELECT paYmetho
 l_Oldrec = RECNO("paymetho")
 GOTO TOP IN "paymetho"
 ccCcbutton = gcButtonfunction
 gcButtonfunction = ""
 DO myBrowse WITH GetLangText("CASHIER","TW_CHANGE"), 10, a_Fields,  ;
    "InList(pm_paytyp, 1, 2, 3) and pm_paynum <> Param.pa_currloc and !pm_inactiv", ".t.",  ;
    cbUttons, "vCHControl", "CASHIER"
 gcButtonfunction = ccCcbutton
 GOTO l_Oldrec IN "paymetho"
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
PROCEDURE vCHControl
 PARAMETER p_Choice
 DO CASE
      CASE p_Choice=1
      CASE p_Choice=2
           DO chAngeamount
 ENDCASE
 if paymetho.pm_opendrw =.t.
 	=drwopen()
 endif
 RETURN
ENDPROC
*
PROCEDURE ChangeAmount
 PRIVATE ALL LIKE l_*
 l_Oldarea = SELECT()
 DEFINE WINDOW wcHange AT 0.000, 0.000 SIZE 10.000, 60.000 FONT "Arial",  ;
        10 NOCLOSE NOZOOM TITLE GetLangText("CASHIER","TW_CHANGE") NOMDI DOUBLE
 MOVE WINDOW wcHange CENTER
 ACTIVATE WINDOW wcHange
 DO paNel WITH 1/4, 2/3, WROWS()-(0.25), WCOLS()-(0.666666666666667)
 DO paNel WITH 15/16, 8/3, 33/16, 70/3, 2
 DO paNel WITH 35/16, 8/3, 53/16, 70/3, 2
 DO paNel WITH 55/16, 8/3, 73/16, 70/3, 2
 DO paNel WITH 75/16, 8/3, 93/16, 70/3, 2
 DO paNel WITH 95/16, 8/3, 113/16, 70/3, 2
 @ 1.000, 4.000 SAY GetLangText("CASHIER","TXT_CURRENCY")
 @ 2.250, 4.000 SAY GetLangText("CASHIER","T_RATE")
 @ 3.500, 4.000 SAY GetLangText("CASHIER","T_AMOUNT")
 @ 4.750, 4.000 SAY GetLangText("CASHIER","T_RETAMOUNT")
 @ 6.000, 4.000 SAY GetLangText("CASHIER","T_SUPPLEM")
 @ 1.000, 25 SAY EVALUATE("paymetho.pm_lang"+g_Langnum) COLOR RGB(0,0,255, ;
   192,192,192)
 IF paRam.pa_ineuro .AND. paYmetho.pm_ineuro
      @ 2.250, 25 SAY '1 EUR = '+ntOc(paYmetho.pm_rate)+' '+ ;
        TRIM(paYmetho.pm_paymeth) SIZE 1, 25 COLOR RGB(0,0,255,192,192,192)
 ELSE
      @ 2.250, 25 SAY '1 '+TRIM(paYmetho.pm_paymeth)+' = '+ ;
        ntOc(paYmetho.pm_rate) SIZE 1, 25 COLOR RGB(0,0,255,192,192,192)
 ENDIF
 l_Curramt = 0
 l_Retrate = 0
 l_Retamt = 0
 l_Supplement = SPACE(25)
 l_Info = ''
 @ 3.500, 25.000 GET l_Curramt SIZE 1, 14 PICTURE "@KB "+RIGHT(gcCurrcy,  ;
   12) VALID LASTKEY()=27 .OR. (l_Curramt>0 .AND.  ;
   caLculate(paYmetho.pm_paynum,l_Curramt,@l_Retrate,@l_Retamt,@l_Info))
 @ 4.750, 25.000 GET l_Retamt SIZE 1, 14 PICTURE "@KB "+RIGHT(gcCurrcy,  ;
   12) WHEN .F. COLOR ,RGB(0,0,255,192,192,192)
 @ 6.000, 25.000 GET l_Supplement SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)
 l_Buttons = "\!"+buTton('',GetLangText("COMMON","TXT_OK"),1)+"\?"+buTton('', ;
             GetLangText("COMMON","TXT_CANCEL"),-2)
 l_Row = WROWS()-2
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice DEFAULT 0 STYLE "B" SIZE nbUttonheight, 15  ;
   FUNCTION "*"+"H" PICTURE l_Buttons
 READ MODAL
 RELEASE WINDOW wcHange
 IF l_Choice=1
      SELECT poSt
      SCATTER BLANK MEMO MEMVAR
      M.ps_paynum = paYmetho.pm_paynum
      M.ps_units = l_Curramt
      M.ps_price = l_Retrate
      M.ps_supplem = l_Supplement
      M.ps_reserid = 0.500
      M.ps_origid = 0.500
      M.ps_date = sySdate()
      M.ps_time = TIME()
      IF paRam.pa_currloc<>0
           M.ps_amount = ROUND(euRo(-l_Retamt), 2)
      ELSE
           M.ps_amount = -l_Retamt
      ENDIF
      M.ps_userid = cuSerid
      M.ps_cashier = g_Cashier
      M.ps_currtxt = l_Info
      M.ps_postid = neXtid('Post')
      INSERT INTO Post FROM MEMVAR
      FLUSH
      l_Rec1 = RECNO("Post")
      IF paRam.pa_currloc<>0
           M.ps_paynum = paRam.pa_currloc
      ELSE
           M.ps_paynum = 1
      ENDIF
      M.ps_units = -l_Retamt
      M.ps_price = 1.00000
      M.ps_supplem = l_Supplement
      M.ps_reserid = 0.500
      M.ps_origid = 0.500
      M.ps_date = sySdate()
      M.ps_time = TIME()
      IF paRam.pa_currloc<>0
           M.ps_amount = ROUND(euRo(l_Retamt), 2)
      ELSE
           M.ps_amount = l_Retamt
      ENDIF
      M.ps_userid = cuSerid
      M.ps_cashier = g_Cashier
      M.ps_currtxt = l_Info
      M.ps_postid = neXtid('Post')
      INSERT INTO Post FROM MEMVAR
      FLUSH
      l_Rec2 = RECNO("Post")
      IF FILE(gcReportdir+"_cashchn.frx") .AND. yeSno(GetLangText("COMMON", ;
         "TXT_RECPRINT"))
           l_Area = SELECT()
           SELECT * FROM Post WHERE INLIST(RECNO(), l_Rec1, l_Rec2) INTO  ;
                    CURSOR Query
           IF _TALLY>0
                g_Rptlngnr = g_Langnum
                g_Rptlng = g_Language
                l_Frx = gcReportdir+"_cashchn.FRX"
                l_Langdbf = STRTRAN(UPPER(l_Frx), '.FRX', '.DBF')
                IF FILE(l_Langdbf)
                     USE SHARED NOUPDATE (l_Langdbf) ALIAS rePtext IN 0
                ENDIF
                REPORT FORM (l_Frx) TO PRINTER PROMPT NOCONSOLE
                = dcLose('RepText')
                DO seTstatus IN Setup
           ENDIF
           = clOsefile("Query")
           SELECT (l_Area)
      ENDIF
 ENDIF
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
FUNCTION Calculate
 PARAMETER pnPaynum, pnCurramt, pnRetrate, pnRetamt, pcInfo
 = cuRrcnv(pnPaynum,pnCurramt,@pnRetrate,@pnRetamt,@pcInfo,.T.)
 SHOW GETS
 RETURN .T.
ENDFUNC
*
