*
LPARAMETERS lp_nNumber
LOCAL l_lRunaudit
LOCAL l_nOldArea
LOCAL l_nCashierNumber, l_nSign
LOCAL l_cOrder, l_dSysdate
LOCAL l_nCalc
l_dSysdate = sySdate()
l_cOrder = ""
IF (PCOUNT()==1)
	l_nCashierNumber = lp_nNumber
	l_lRunaudit = .T.
ELSE
	l_nCashierNumber = g_Cashier
	l_lRunaudit = .F.
ENDIF
IF ( NOT EMPTY(WTITLE()) AND  NOT l_lRunaudit)
	= alErt(GetLangText("CASHIER","TA_CLOSEWINS")+"!")
	RETURN
ENDIF
l_nOldArea = SELECT()
WAIT WINDOW NOWAIT GetLangText("CASHIER","TA_PROCESSING")
SELECT SUM(ps_units) AS tp_calc, SUM(ps_amount) AS tp_amount, ps_paynum AS tp_paynum, ;
				00000000.00 AS tp_count, REPLICATE(" ",25) AS tp_lang ;
		FROM Post ;
		WHERE ps_date = l_dSysdate AND ps_cashier=l_nCashierNumber ;
				AND NOT EMPTY(ps_paynum) AND NOT ps_cancel ;
		GROUP BY ps_cashier, ps_paynum, tp_count, tp_lang ;
		HAVING ROUND(tp_calc,2) <> 0.00 ;
		INTO CURSOR temp READWRITE
WAIT CLEAR
IF RECCOUNT("temp") > 0
	GOTO TOP IN "Temp"
	IF ( NOT l_lRunaudit)
		doform("frmcashierclose","forms\cashierclose")
	ELSE
		REPLACE ALL tp_count WITH tp_calc IN temp
		= clOseclose(l_nCashierNumber, .T.)
	ENDIF
ELSE
	SELECT caShier
	LOCATE ALL FOR caShier.ca_number==l_nCashierNumber
	IF NOT l_lRunaudit OR (cashier.ca_isopen AND NOT param.pa_noclose)
		REPLACE caShier.ca_isopen WITH .F.
		REPLACE caShier.ca_clodate WITH SysDate()
		REPLACE caShier.ca_clotime WITH TIME()
		REPLACE caShier.ca_opcount WITH MAX(caShier.ca_opcount-1,0)
	ENDIF
	IF ( NOT l_lRunaudit)
		= alErt(GetLangText("CASHIER","TA_ISCLOSED")+" "+ ;
			LTRIM(STR(l_nCashierNumber))+"!")
		g_Cashier = 0
	ENDIF
ENDIF
= dClose("temp")
SELECT (l_nOldArea)
DO seTstatus IN Setup
IF (g_Cashier==0)
	= CheckWin("LOGIN WITH .T.", .T.)
ENDIF
RETURN l_nCashierNumber
ENDFUNC
*
FUNCTION vCLControl
 PARAMETER p_Choice
 PRIVATE lrEturn
 lrEturn = .T.
 DO CASE
      CASE p_Choice=1
      CASE p_Choice=2
           DO clOseedit
           g_Refreshcurr = .T.
           lrEturn = .F.
      CASE p_Choice=3
           LOCAL lcCashier
           lcCashier = g_Cashier
           DO clOseclose WITH lcCashier
 ENDCASE
 RETURN lrEturn
ENDFUNC
*
PROCEDURE CloseEdit
 PRIVATE l_Col, l_Row, l_Top, l_Bottom
 l_Row = ncUrline+piXv(3)
 l_Col = piXh(1)+IIF(paRam.pa_hidcash, 40+piXh(2), 55+piXh(3))
 laCtivebar = .F.
 DO diSpline IN MyBrowse WITH (ncUrline)
 laCtivebar = .T.
 SCATTER MEMVAR
 SET READBORDER OFF
 @ l_Row, l_Col GET M.tp_count SIZE 1, 15 PICTURE "@KB "+RIGHT(gcCurrcy, 12)
 READ MODAL
 SET READBORDER ON
 GATHER MEMVAR
 RETURN
ENDPROC
*
FUNCTION CloseClose
 LPARAMETERS pnCashier, plRunAudit
 PRIVATE noLdarea, nPostid
 LOCAL lcUserid, lcFilter, lnPrice, lnCalcrate, lnAmount
 noLdarea = SELECT()
 IF plRunAudit
 	lcUserid = "AUTOMATIC"
 	lcFilter = ".T."
 ELSE
 	lcUserid = cUserid
 	lcFilter = "ROUND(temp.tp_count,2) <> 0.00"
 ENDIF
 SELECT temp
 SCAN FOR &lcFilter
      IF SEEK(temp.tp_paynum, "paymetho", "TAG1")
          lnPrice = IIF(EMPTY(paymetho.pm_rate) OR paymetho.pm_paynum = 1, 1.00, paymetho.pm_rate)
          lnCalcrate = paymetho.pm_calcrat
      ELSE
          lnPrice = 1
          lnCalcrate = 1
      ENDIF
      IF temp.tp_calc = temp.tp_count
          lnAmount = ROUND(-temp.tp_amount, 2)
      ELSE
          lnAmount = ROUND(temp.tp_count*lnCalcrate, 2)
      ENDIF
      nPostid = nextid('Post')
      INSERT INTO Post (ps_postid, ps_paynum, ps_units, ps_price,  ;
             ps_supplem, ps_reserid, ps_origid, ;
             ps_date, ps_time, ;
             ps_amount, ps_userid, ps_cashier) ;
             VALUES (nPostid, temp.tp_paynum, -temp.tp_count, lnPrice, ;
             "CLOSE "+LTRIM(STR(pnCashier)), -2, -2, ;
             sysdate(), TIME(), ;
             lnAmount, lcUserid, pnCashier)
      IF (plRunAudit .AND. paRam.pa_noclose ;
                   AND NOT INLIST(temp.tp_paynum, param.pa_payonld, param.pa_rndpay))
           npOstid = neXtid('Post')
           INSERT INTO Post (ps_postid, ps_paynum, ps_units, ps_price, ;
                  ps_supplem, ps_reserid, ps_origid, ;
                  ps_date, ps_time, ;
                  ps_amount, ps_userid, ps_cashier) ;
                  VALUES (npOstid, temp.tp_paynum, temp.tp_count, lnPrice, ;
                  "TRANSFER AUDIT #"+LTRIM(STR(pnCashier)), -1, -1, ;
                  sysdate()+1, TIME(), ;
                  -lnAmount, lcUserid, pnCashier)
      ENDIF
 ENDSCAN
 IF ( .NOT. plRunAudit)
      SELECT caShier
      LOCATE ALL FOR caShier.ca_number==pnCashier
      REPLACE caShier.ca_isopen WITH .F.
      REPLACE caShier.ca_clodate WITH sySdate()
      REPLACE caShier.ca_clotime WITH TIME()
      REPLACE caShier.ca_opcount WITH MAX(caShier.ca_opcount-1,0)
      = alErt(GetLangText("CASHIER","TA_ISCLOSED")+" "+LTRIM(STR(pnCashier))+"!")
      g_Cashier = 0
 ENDIF
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
PROCEDURE UpdateVersion
 LOCAL l_dSysdate
 OpenFile(.F., "post")
 l_dSysdate = SysDate()
 REPLACE ps_units WITH -ps_units ;
         FOR ps_reserid = -1 AND ps_date = l_dSysdate AND SIGN(ps_amount) = SIGN(ps_units) ;
         IN post
 CloseFile("post")
ENDPROC
*