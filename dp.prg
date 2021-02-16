#INCLUDE "include\constdefines.h"
*
PROCEDURE DPView
 PARAMETER pnReserid, plReadonly
 LOCAL cbUttons, clEvel, naRea, ciDx, cfOr, cbTnfunc
 LOCAL a_Fields
 IF  .NOT. usErpid()
      RETURN
 ENDIF
 DIMENSION a_Fields[8, 4]
 a_Fields[1, 1] = [Iif(dp_headid = dp_lineid, Deposit.dp_reserid, '')]
 a_Fields[1, 2] = 12
 a_Fields[1, 3] = GetLangText("DP","T_RESNO")
 a_Fields[1, 4] = 'C'
 a_Fields[2, 1] = 'dp_paynum + dp_artinum'
 a_Fields[2, 2] = 6
 a_Fields[2, 3] = GetLangText("DP","T_DEPT")
 a_Fields[2, 4] = 'C9999 '
 a_Fields[3, 1] = 'DispDept()'
 a_Fields[3, 2] = 20
 a_Fields[3, 3] = GetLangText("DP","T_DESCRIPTION")
 a_Fields[3, 4] = 'C'+REPLICATE('X', 20)
 a_Fields[4, 1] = 'dp_ref'
 a_Fields[4, 2] = 32
 a_Fields[4, 3] = GetLangText("DP","T_REFERENCE")
 a_Fields[4, 4] = 'C'+REPLICATE('X', 25)
 a_Fields[5, 1] = 'dp_debit'
 a_Fields[5, 2] = 12
 a_Fields[5, 3] = GetLangText("DP","T_DEBIT")
 a_Fields[5, 4] = 'C@Z '+RIGHT(gcCurrcydisp, 12)
 a_Fields[6, 1] = 'dp_credit'
 a_Fields[6, 2] = 12
 a_Fields[6, 3] = GetLangText("DP","T_CREDIT")
 a_Fields[6, 4] = 'C@Z '+RIGHT(gcCurrcydisp, 12)
 a_Fields[7, 1] = [Iif(dp_headid = dp_lineid, Deposit.dp_due, '')]
 a_Fields[7, 2] = siZedate()+piXh(4)
 a_Fields[7, 3] = GetLangText("DP","T_DUE")
 a_Fields[7, 4] = 'C'
 a_Fields[8, 1] = 'DispBal()'
 a_Fields[8, 2] = 12
 a_Fields[8, 3] = GetLangText("DP","T_BALANCE")
 a_Fields[8, 4] = 'C@J'
 clEvel = ''
 IF plReadonly
      cbUttons = "\?"+buTton(clEvel,GetLangText("DP","TB_CLOSE"),-1)
 ELSE
      cbUttons = "\?"+buTton(clEvel,GetLangText("DP","TB_CLOSE"),1)+ ;
                 buTton(clEvel,GetLangText("DP","TB_PAY"),2)+buTton(clEvel, ;
                 GetLangText("DP","TB_POST"),3)+buTton(clEvel,GetLangText("DP", ;
                 "TB_ADJUST"),-4)
 ENDIF
 naRea = SELECT()
 doPen('Deposit')
 SELECT dePosit
 ciDx = fiLetemp()
 cfOr = 'dp_reserid = '+sqLcnv(pnReserid)
 index on Str(dp_headid, 8) + Str(dp_lineid, 8) for &cFor to (cIdx)
 SET RELATION ADDITIVE TO dp_artinum INTO arTicle
 SET RELATION ADDITIVE TO dp_paynum INTO paYmetho
 = dlOcate('Deposit',cfOr)
 cbTnfunc = gcButtonfunction
 gcButtonfunction = ''
 = myBrowse(GetLangText("DP","TW_DEPOSITS"),10,@a_Fields,cfOr,'.t.',cbUttons, ;
   'DPControl','DP','','LocalColor',0,'Deposit')
 gcButtonfunction = cbTnfunc
 SELECT dePosit
 SET RELATION TO
 SET INDEX TO
 = fiLedelete(ciDx)
 dcLose('Deposit')
 SELECT (naRea)
 RETURN
ENDPROC
*
FUNCTION DispDept
 IF dp_paynum>0
      RETURN EVALUATE('Paymetho.pm_lang'+g_Langnum)
 ELSE
      RETURN EVALUATE('article.ar_lang'+g_Langnum)
 ENDIF
 RETURN
ENDFUNC
*
FUNCTION DispBal
 IF dp_headid=dp_lineid .OR. dp_headid=0
      RETURN TRANSFORM(dpBal(dp_headid,dp_lineid), RIGHT(gcCurrcydisp, 12))
 ELSE
      RETURN ''
 ENDIF
 RETURN
ENDFUNC
*
PROCEDURE LocalColor
 PARAMETER pcColor, pcStyle, plNotcurrent
 IF dp_headid=dp_lineid
      IF plNotcurrent
           pcColor = "rgb(0,0,0,0,255,255)"
      ELSE
           pcColor = "rgb(0,255,255,0,0,128)"
      ENDIF
 ELSE
      IF dp_headid=0
           IF plNotcurrent
                pcColor = "rgb(0,0,0,255,255,0)"
           ELSE
                pcColor = "rgb(255,255,0,0,0,128)"
           ENDIF
      ENDIF
 ENDIF
 RETURN
ENDPROC
*
FUNCTION DPControl
 PARAMETER pnBtn
 DO CASE
      CASE pnBtn=1
           RETURN .T.
      CASE pnBtn=2
           = dpPay()
           g_Refreshall = .T.
      CASE pnBtn=3
           = dpArti()
           g_Refreshall = .T.
      CASE pnBtn=4
           = dpAdjust()
           g_Refreshall = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE DPPay
 LOCAL cwIn, nrOw, ncOl, cbUttons, naRea
 LOCAL ntMpbal, nbAlance, ndEfamt
 PRIVATE nbTn, ndIsprate, ncAlcrate, naMt
 PRIVATE l_vatnum, l_vatpct, l_vatnum2, l_vatpct2
 nbAlance = dpBal(dp_headid,0)
 naRea = SELECT()
 SELECT dePosit
 SCATTER BLANK MEMVAR
 M.dp_date = sySdate()
 ndIsprate = 0
 ncAlcrate = 0
 naMt = 0
 cwIn = SYS(2015)
 DEFINE WINDOW (cwIn) AT 0.000, 0.000 SIZE 12.750, 59.750 FONT "Arial",  ;
        10 NOGROW NOFLOAT NOCLOSE TITLE GetLangText("DP","TW_PAY") NOMDI SYSTEM
 MOVE WINDOW (cwIn) CENTER
 ACTIVATE WINDOW (cwIn)
 = paNelborder()
 = txTpanel(1,2,23,GetLangText("DP","T_DATE"),0)
 = txTpanel(2.25,2,23,GetLangText("DP","T_PAYMETHOD"),0)
 = txTpanel(3.5,2,23,GetLangText("DP","T_RATE"),0)
 = txTpanel(4.75,2,23,GetLangText("DP","T_AMOUNT"),0)
 = txTpanel(6,2,23,GetLangText("DP","T_REFERENCE"),0)
 @ 1.000, 25.000 GET M.dp_date SIZE 1, siZedate() PICTURE "@K"
 @ 2.250, 25.000 GET M.dp_paynum SIZE 1, 4 PICTURE "@K 99" VALID  ;
   paYnumvalid(@M.dp_paynum,@ndIsprate,@ncAlcrate,@naMt,nbAlance) .AND.  ;
   saYpay(@M.dp_paynum,2.25,32)
 @ 3.500, 25.000 GET ndIsprate SIZE 1, 14 PICTURE "@K 99999.999999" WHEN  ;
   .F. COLOR ,RGB(0,0,255,192,192,192)
 ndEfamt = 0.00
 @ 4.750, 25.000 GET naMt SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy, 12)  ;
   WHEN xsEtvar(@ndEfamt,naMt)
 @ 6, 25.000 GET M.dp_ref SIZE 1, 30 PICTURE "@K "+REPLICATE('X', 25)
 cbUttons = "\!"+buTton('',GetLangText('COMMON',"TXT_OK"),1)+buTton('', ;
            GetLangText('COMMON',"TXT_CANCEL"),-2)
 nrOw = WROWS()-2.5
 ncOl = (WCOLS()-0032-1)/2
 nbTn = 0
 @ nrOw, ncOl GET nbTn SIZE nbUttonheight, 15 PICTURE "@*NH "+cbUttons  ;
   VALID dpPayvalid(nbTn)
 READ CYCLE MODAL
 RELEASE WINDOW (cwIn)
 IF nbTn=1 .AND. LASTKEY()<>27
      M.dp_sysdate = sySdate()
      M.dp_credit = ROUND(naMt*ncAlcrate, paRam.pa_currdec)
      IF ndEfamt=naMt
           nrOunddiff = nbAlance-M.dp_credit
           IF nrOunddiff<>0.00
                M.dp_credit = M.dp_credit+nrOunddiff
           ENDIF
      ELSE
           nrOunddiff = 0
      ENDIF
      M.dp_reserid = dePosit.dp_reserid
      M.dp_headid = dePosit.dp_headid
      M.dp_userid = g_Userid
      M.dp_cashier = g_Cashier
      M.dp_lineid = neXtid('DEPOSIT')
      INSERT INTO Deposit FROM MEMVAR
      FLUSH
      m.ps_reserid= deposit.dp_reserid
      m.ps_userid=g_userid
      m.ps_cashier=g_cashier
      m.ps_postid=nextid('POST')
      m.ps_date=sysdate()
      m.ps_units=1
      m.ps_paynum=0
      m.ps_supplem=DTOC(m.dp_date)+m.dp_ref
      m.ps_time=TIME()
      m.ps_window=0
      m.ps_touched=.f.
      m.ps_addrid=0
      m.ps_artinum= param.pa_departi
      m.ps_cancel=.f.
      m.ps_origid=m.ps_reserid
      m.ps_prtype=0
      m.ps_setid=0
      m.ps_split=.f.
      m.ps_price=m.dp_credit
      m.ps_amount=m.dp_credit
      l_vatnum=0
      l_vatpct=0
      l_vatnum2=0
      l_vatpct2=0
      DO sarticle in particle
      cvAtmacro1 = "m.ps_vat"+LTRIM(STR(l_Vatnum))
      &cVATMacro1 = m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
      cvAtmacro2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
      &cVATMacro2 = m.ps_amount *  (1 - (100 / (100 + l_VatPct2)))
      IF (param.pa_exclvat)
           m.ps_price = m.ps_price - ;
                        ROUND(&cvatmacro1,param.pa_currdec) - ;
                        ROUND(&cvatmacro2,param.pa_currdec)
           m.ps_amount = m.ps_amount - ;
                        ROUND(&cvatmacro1,param.pa_currdec) - ;
                        ROUND(&cvatmacro2,param.pa_currdec)
      ENDIF
      INSERT INTO post FROM memvar
      STORE 0 TO m.ps_vat0, m.ps_vat1, m.ps_vat2, m.ps_vat3, m.ps_vat4, m.ps_vat5, m.ps_vat6, m.ps_vat7, m.ps_vat8, m.ps_vat9
      m.ps_reserid= deposit.dp_reserid
      m.ps_userid=g_userid
      m.ps_cashier=g_cashier
      m.ps_postid=nextid('POST')
      m.ps_date=sysdate()
      m.ps_amount=-m.dp_credit
      m.ps_units=m.dp_credit
      m.ps_paynum=m.dp_paynum
      m.ps_price=1
      m.ps_supplem=DTOC(m.dp_date)+m.dp_ref
      m.ps_time=TIME()
      m.ps_window=0
      m.ps_touched=.f.
      m.ps_addrid=0
      m.ps_artinum=0
      m.ps_cancel=.f.
      m.ps_origid=m.ps_reserid
      m.ps_prtype=0
      m.ps_setid=0
      m.ps_split=.f.
      INSERT INTO post FROM memvar
      flush
      duPdate('Reservat','rs_reserid = '+sqLcnv(dp_reserid),'rs_deppdat', ;
             M.dp_date)
      duPdate('Reservat','rs_reserid = '+sqLcnv(dp_reserid),'rs_deppaid',;
             reservat.rs_deppaid+M.dp_credit)
 ENDIF
 DO WHILE dp_headid<>dp_lineid .AND.  .NOT. BOF()
      SKIP -1
 ENDDO
 SELECT (naRea)
 RETURN
ENDPROC
*
FUNCTION DPPayValid
 PARAMETER pnBtn
 IF pnBtn=2
      CLEAR READ
      RETURN .T.
 ENDIF
 IF EMPTY(M.dp_date)
      = alErt(GetLangText("DP","TA_DATEREQ"))
      RETURN .F.
 ENDIF
 IF EMPTY(M.dp_paynum)
      = alErt(GetLangText("DP","TA_PAYREQ"))
      RETURN .F.
 ENDIF
 IF EMPTY(M.naMt)
      = alErt(GetLangText("DP","TA_AMTREQ"))
      RETURN .F.
 ENDIF
 CLEAR READ
 RETURN .T.
ENDFUNC
*
FUNCTION PayNumValid
 PARAMETER pnPaynum, pnRate, pnCalcrate, pnAmt, pnBalance
 LOCAL acOls, naRea, loK
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 DIMENSION acOls[3, 2]
 acOls[1, 1] = "pm_paynum"
 acOls[1, 2] = 5
 acOls[2, 1] = "pm_lang"+g_Langnum
 acOls[2, 2] = 20
 acOls[3, 1] = "Iif(pm_paytyp = 2, pm_rate, Space(12))"
 acOls[3, 2] = 17
 naRea = SELECT()
 SELECT paYmetho
 loK = dlOcate('Paymetho','pm_paynum = '+sqLcnv(pnPaynum)+ ;
       ' and Inlist(pm_paytyp, 1, 2, 3) and !Inlist(pm_paynum, Param.pa_payonld, Param.pa_rndpay) and not pm_inactiv' ;
       )
 IF  .NOT. loK
      GOTO TOP IN paYmetho
      loK = (myPopup(WONTOP(),0,0,5,@acOls, ;
            "Inlist(pm_paytyp, 1, 2, 3) and !Inlist(pm_paynum, Param.pa_payonld, Param.pa_rndpay) and not pm_inactiv", ;
            ".t.")>0)
 ENDIF
 IF loK
      pnPaynum = paYmetho.pm_paynum
      pnRate = IIF(EMPTY(paYmetho.pm_rate) .OR. paYmetho.pm_paynum=1,  ;
               1.00, paYmetho.pm_rate)
      pnCalcrate = paYmetho.pm_calcrat
      pnAmt = ROUND(pnBalance/pnCalcrate, paRam.pa_currdec)
      SHOW GETS
 ENDIF
 SELECT (naRea)
 RETURN loK
ENDFUNC
*
FUNCTION SayPay
 PARAMETER pnPaynum, pnRow, pnCol
 @ pnRow, pnCol SAY dlOokup('Paymetho','pm_paynum = '+sqLcnv(pnPaynum), ;
   'pm_lang'+g_Langnum) SIZE 1, WCOLS()-pnCol-4 COLOR RGB(0,0,255)
 RETURN .T.
ENDFUNC
*
PROCEDURE DPArti
 LOCAL cwIn, nrOw, ncOl, cbUttons, naRea, csUpplem, naRtinum
 PRIVATE nbTn, naMt, npRice, nqTy
 naRea = SELECT()
 SELECT dePosit
 SCATTER BLANK MEMVAR
 M.dp_date = sySdate()
 M.dp_artinum = param.pa_departi
 naMt = 0
 npRice = 0
 nqTy = 1
 cwIn = SYS(2015)
 DEFINE WINDOW (cwIn) AT 0.000, 0.000 SIZE 12.750, 59.750 FONT "Arial",  ;
        10 NOGROW NOFLOAT NOCLOSE TITLE GetLangText("DP","TW_ARTICLE") NOMDI SYSTEM
 MOVE WINDOW (cwIn) CENTER
 ACTIVATE WINDOW (cwIn)
 = paNelborder()
 = txTpanel(1,2,23,GetLangText("DP","T_DATE"),0)
 = txTpanel(2.25,2,23,GetLangText("DP","T_ARTICLE"),0)
 = txTpanel(3.5,2,23,GetLangText("DP","T_QUANTITY"),0)
 = txTpanel(4.75,2,23,GetLangText("DP","T_PRICE"),0)
 = txTpanel(6,2,23,GetLangText("DP","T_AMOUNT"),0)
 = txTpanel(7.25,2,23,GetLangText("DP","T_REFERENCE"),0)
 @ 1.000, 25.000 GET M.dp_date SIZE 1, siZedate() PICTURE "@K"
 @ 2.250, 25.000 GET M.dp_artinum SIZE 1, 6 PICTURE "@K 9999" VALID  ;
   arTivalid(@M.dp_artinum,@npRice) .AND. saYarti(@M.dp_artinum,2.25,34) DISABLE
 @ 3.500, 25.000 GET nqTy SIZE 1, 6 PICTURE "@K 9999" VALID caLcamt(nqTy, ;
   npRice,@naMt)
 @ 4.750, 25.000 GET npRice SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy, 12)  ;
   VALID npRice>0 .AND. caLcamt(nqTy,npRice,@naMt)
 @ 6.000, 25.000 GET naMt SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy, 12)
 @ 7.250, 25.000 GET M.dp_ref SIZE 1, 30 PICTURE "@K "+REPLICATE('X', 25)
 @ 8.500, 2 GET M.dp_addpost PICTURE '@*C '+GetLangText("DP","T_POSTATCI")
 cbUttons = "\!"+buTton('',GetLangText('COMMON',"TXT_OK"),1)+buTton('', ;
            GetLangText('COMMON',"TXT_CANCEL"),-2)
 nrOw = WROWS()-2.5
 ncOl = (WCOLS()-0032-1)/2
 nbTn = 0
 @ nrOw, ncOl GET nbTn SIZE nbUttonheight, 15 PICTURE "@*NH "+cbUttons  ;
   VALID dpArtivalid(nbTn)
 READ CYCLE MODAL
 RELEASE WINDOW (cwIn)
 IF nbTn=1 .AND. LASTKEY()<>27
      naRtinum = M.dp_artinum
      M.dp_sysdate = sySdate()
      M.dp_debit = naMt
      M.dp_reserid = dePosit.dp_reserid
      M.dp_headid = dePosit.dp_headid
      M.dp_lineid = neXtid('DEPOSIT')
      M.dp_userid = g_Userid
      M.dp_cashier = g_Cashier
      INSERT INTO Deposit FROM MEMVAR
      FLUSH
 ENDIF
 DO WHILE dp_headid<>dp_lineid .AND.  .NOT. BOF()
      SKIP -1
 ENDDO
 SELECT (naRea)
 RETURN
ENDPROC
*
FUNCTION DPArtiValid
 PARAMETER pnBtn
 IF pnBtn=2
      CLEAR READ
      RETURN .T.
 ENDIF
 IF EMPTY(M.dp_date)
      = alErt(GetLangText("DP","TA_DATEREQ"))
      RETURN .F.
 ENDIF
 IF EMPTY(M.dp_artinum)
      = alErt(GetLangText("DP","TA_ARTREQ"))
      RETURN .F.
 ENDIF
 IF EMPTY(M.naMt)
      = alErt(GetLangText("DP","TA_AMTREQ"))
      RETURN .F.
 ENDIF
 CLEAR READ
 RETURN .T.
ENDFUNC
*
FUNCTION ArtiValid
 PARAMETER pnArtinum, pnPrice
 LOCAL acOls, naRea, loK
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 DIMENSION acOls[3, 2]
 acOls[1, 1] = "ar_artinum"
 acOls[1, 2] = 5
 acOls[2, 1] = "ar_lang"+g_Langnum
 acOls[2, 2] = 20
 acOls[3, 1] = "ar_price"
 acOls[3, 2] = 15
 naRea = SELECT()
 SELECT arTicle
 loK = dlOcate('Article','ar_artinum = '+sqLcnv(pnArtinum)+ ;
       ' and Inlist(ar_artityp, 1,2,3)')
 IF  .NOT. loK
      GOTO TOP IN arTicle
      loK = (myPopup(WONTOP(),0,0,5,@acOls,"Inlist(ar_artityp, 1, 3)",".t.")>0)
 ENDIF
 IF loK
      pnArtinum = arTicle.ar_artinum
      pnPrice = arTicle.ar_price
      SHOW GETS
 ENDIF
 SELECT (naRea)
 RETURN loK
ENDFUNC
*
PROCEDURE DPAdjust
 PRIVATE adLg
 IF  .NOT. EMPTY(dp_posted)
      alErt('TA_CHECKEDIN')
      RETURN
 ENDIF
 DO CASE
      CASE dp_headid=dp_lineid
           DIMENSION adLg[2, 8]
           adLg[1, 1] = "amt"
           adLg[1, 2] = GetLangText("DP","T_AMOUNT")
           adLg[1, 3] = "dp_debit"
           adLg[1, 4] = '@K '+RIGHT(gcCurrcy, 12)
           adLg[1, 5] = 12
           adLg[1, 6] = ""
           adLg[1, 7] = ""
           adLg[1, 8] = 0
           adLg[2, 1] = "due"
           adLg[2, 2] = GetLangText("DP","T_DUE")
           adLg[2, 3] = "dp_due"
           adLg[2, 4] = '@K'
           adLg[2, 5] = 12
           adLg[2, 6] = ""
           adLg[2, 7] = ""
           adLg[2, 8] = {}
           IF diAlog(GetLangText("DP","TW_ADJ_REQUIRED"),'',@adLg)
                REPLACE dp_debit WITH adLg(1,8), dp_due WITH adLg(2,8)
                FLUSH
                IF dp_depcnt=2
                     M.rs_depamt2 = adLg(1,8)
                     M.rs_depdat2 = adLg(2,8)
                     SHOW GET M.rs_depamt2 LEVEL RDLEVEL()-1
                     SHOW GET M.rs_depdat2 LEVEL RDLEVEL()-1
                     duPdate('Reservat','rs_reserid = '+ ;
                            sqLcnv(dp_reserid),'rs_depamt2',adLg(1,8))
                     duPdate('Reservat','rs_reserid = '+ ;
                            sqLcnv(dp_reserid),'rs_depdat2',adLg(2,8))
                ELSE
                     M.rs_depamt1 = adLg(1,8)
                     M.rs_depdat1 = adLg(2,8)
                     SHOW GET M.rs_depamt1 LEVEL RDLEVEL()-1
                     SHOW GET M.rs_depdat1 LEVEL RDLEVEL()-1
                     duPdate('Reservat','rs_reserid = '+ ;
                            sqLcnv(dp_reserid),'rs_depamt1',adLg(1,8))
                     duPdate('Reservat','rs_reserid = '+ ;
                            sqLcnv(dp_reserid),'rs_depdat1',adLg(2,8))
                ENDIF
           ENDIF
      CASE dp_artinum>0
           IF dp_sysdate<sySdate()
                alErt(GetLangText("DP","TA_OLDPOSTING"))
                RETURN
           ENDIF
           DIMENSION adLg[1, 8]
           adLg[1, 1] = "amt"
           adLg[1, 2] = GetLangText("DP","T_AMOUNT")
           adLg[1, 3] = "dp_debit"
           adLg[1, 4] = '@K '+RIGHT(gcCurrcy, 12)
           adLg[1, 5] = 12
           adLg[1, 6] = ""
           adLg[1, 7] = ""
           adLg[1, 8] = 0
           IF diAlog(GetLangText("DP","TW_ADJ_POSTING"),'',@adLg)
                REPLACE dp_debit WITH adLg(1,8)
                FLUSH
           ENDIF
      CASE dp_paynum>0
           IF dp_sysdate<sySdate()
                alErt(GetLangText("DP","TA_OLDPOSTING"))
                RETURN
           ENDIF
           dp_creditold_=dp_credit
           DIMENSION adLg[1, 8]
           adLg[1, 1] = "amt"
           adLg[1, 2] = GetLangText("DP","T_AMOUNT")
           adLg[1, 3] = "dp_credit"
           adLg[1, 4] = '@K '+RIGHT(gcCurrcy, 12)
           adLg[1, 5] = 12
           adLg[1, 6] = ""
           adLg[1, 7] = ""
           adLg[1, 8] = 0
           IF diAlog(GetLangText("DP","TW_ADJ_PAYMENT"),'',@adLg)
                duPdate('Reservat','rs_reserid = '+sqLcnv(dp_reserid),'rs_deppaid',;
                     (reservat.rs_deppaid-dp_credit)+adLg(1,8))
                REPLACE dp_credit WITH adLg(1,8)
                FLUSH
                m.ps_window=0
                m.ps_touched=.f.
                m.ps_addrid=0
                m.ps_artinum=0
                m.ps_cancel=.f.
                m.ps_prtype=0
                m.ps_setid=0
                m.ps_split=.f.
                m.ps_reserid= dp_reserid
                m.ps_origid=m.ps_reserid
                m.ps_userid=g_userid
                m.ps_cashier=g_cashier
                m.ps_postid=nextid('POST')
                m.ps_date=sysdate()
                m.ps_amount=dp_creditold_
                m.ps_units=-dp_creditold_
                m.ps_paynum=dp_paynum
                m.ps_price=1
                m.ps_supplem=DTOC(dp_date)+dp_ref
                m.ps_time=TIME()
                INSERT INTO post FROM memvar
                m.ps_reserid= dp_reserid
                m.ps_userid=g_userid
                m.ps_cashier=g_cashier
                m.ps_postid=nextid('POST')
                m.ps_date=sysdate()
                m.ps_amount=-dp_credit
                m.ps_units=dp_credit
                m.ps_paynum=dp_paynum
                m.ps_price=1
                m.ps_supplem=DTOC(dp_date)+dp_ref
                m.ps_time=TIME()

                INSERT INTO post FROM memvar
                flush
            ENDIF
 ENDCASE
ENDPROC
*
FUNCTION CalcAmt
 PARAMETER pnQty, pnPrice, pnAmt
 pnAmt = pnQty*pnPrice
 =arTivalid(@M.dp_artinum,@npRice) 
 =saYarti(@M.dp_artinum,2.25,34)
 SHOW GETS
 RETURN .T.
ENDFUNC
*
FUNCTION SayArti
 PARAMETER pnArtinum, pnRow, pnCol
 @ pnRow, pnCol SAY dlOokup('Article','ar_artinum = '+sqLcnv(pnArtinum), ;
   'ar_lang'+g_Langnum) SIZE 1, WCOLS()-pnCol-4 COLOR RGB(0,0,255)
 RETURN .T.
ENDFUNC
*
PROCEDURE DPAudit
 LOCAL naRea
*naRea = SELECT()
*IF doPen('Deposit')
*     SELECT dePosit
*     dcLose('Deposit')
*ENDIF
*SELECT (naRea)
 RETURN
ENDPROC
*
PROCEDURE DPDel
 PARAMETER pnHeadid
 LOCAL naRea, nrEc
 IF pnHeadid<>0
      naRea = SELECT()
      SELECT dePosit
      nrEc = RECNO()
      DELETE ALL FOR dp_headid=pnHeadid
      FLUSH
      GOTO nrEc
      SELECT (naRea)
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE DPUpdate
 LOCAL naRea, coLdnear, nrSord, nrSrec, ndEpamt, ddEplim, i
 naRea = SELECT()
 IF doPen('Deposit')
      SELECT reServat
      nrSord = ORDER()
      nrSrec = RECNO()
      SET ORDER TO 8
      coLdnear = SET('near')
      SET NEAR ON
      SEEK DTOS(sySdate())
      set near &cOldNear
      SCAN REST FOR  .NOT. INLIST(rs_status, 'IN', 'OUT', 'CXL', 'NS')  ;
           .AND. (rs_depamt1<>0 .OR. rs_depamt2<>0)
           FOR i = 1 TO 2
                ndEpamt = EVALUATE('rs_depamt'+STR(i, 1))
                ddEplim = EVALUATE('rs_depdat'+STR(i, 1))
                IF ndEpamt<>0
                     SELECT dePosit
                     LOCATE ALL FOR dp_reserid=reServat.rs_reserid .AND.  ;
                            dp_depcnt=i
                     IF  .NOT. FOUND()
                          niD = neXtid('DEPOSIT')
                          INSERT INTO Deposit (dp_lineid, dp_headid,  ;
                                 dp_artinum, dp_date, dp_sysdate,  ;
                                 dp_reserid, dp_depcnt, dp_debit, dp_due)  ;
                                 VALUES (niD, niD, paRam.pa_departi,  ;
                                 sySdate(), sySdate(),  ;
                                 reServat.rs_reserid, i, ndEpamt, ddEplim)
                          FLUSH
                     ENDIF
                     SELECT reServat
                ENDIF
           ENDFOR
      ENDSCAN
      SET ORDER TO nRsOrd
      GOTO nrSrec
      dcLose('Deposit')
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE DPInsert
 LPARAMETERS pnReserid, pnDepamt1, pdDeplim1, pnDepamt2, pdDeplim2
 LOCAL naRea, niD
 naRea = SELECT()
 IF doPen('Deposit')
      IF pnDepamt1<>0
           niD = neXtid('DEPOSIT')
           INSERT INTO Deposit (dp_lineid, dp_headid, dp_artinum, dp_date,  ;
                  dp_sysdate, dp_reserid, dp_depcnt, dp_debit, dp_due)  ;
                  VALUES (niD, niD, paRam.pa_departi, sySdate(),  ;
                  sySdate(), pnReserid, 1, pnDepamt1, pdDeplim1)
           FLUSH
      ENDIF
      IF pnDepamt2<>0
           niD = neXtid('DEPOSIT')
           INSERT INTO Deposit (dp_lineid, dp_headid, dp_artinum, dp_date,  ;
                  dp_sysdate, dp_reserid, dp_depcnt, dp_debit, dp_due)  ;
                  VALUES (niD, niD, paRam.pa_departi, sySdate(),  ;
                  sySdate(), pnReserid, 2, pnDepamt2, pdDeplim2)
           FLUSH
      ENDIF
      dcLose('Deposit')
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE DPDelete
 LPARAMETERS pnReserid, plCancel
 LOCAL naRea, ncRedit
 naRea = SELECT()
 IF doPen('Deposit')
      SUM dp_credit TO ncRedit ALL FOR dp_reserid=pnReserid .AND. dp_posted={}
      IF ncRedit<>0
           alErt(GetLangText("DP","TA_DPHASCREDIT"))
           plCancel = .T.
      ELSE
           DELETE ALL FOR dp_reserid=pnReserid
           FLUSH
      ENDIF
      dcLose('Deposit')
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE DPChkIn
 LPARAMETERS pnReserid, plCancel
 LOCAL naRea, ndEbit, ncRedit, l_nVatNum, l_nVatPct, odata, l_cSql, l_curDpBalance, l_cSupplement, l_nDpReceipt
 IF EMPTY(paRam.pa_depxfer)
      alErt(GetLangText("DP","TXT_PA_DEPXFER"))
      RETURN
 ENDIF
 naRea = SELECT()
 IF doPen('Deposit')
      SUM ROUND(dp_debit,2), ROUND(dp_credit,2) TO ndEbit, ncRedit ALL FOR dp_reserid = pnReserid AND dp_posted = {}
      IF ndEbit > ncRedit
           alErt(GetLangText("DP","TA_DPNOTBALANCED"))
           plCancel = .T.
      ELSE
           IF _screen.DV
                TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
                     SELECT dp.dp_lineid, dp.c_headid, SUM(NVL(ap_debit-ap_credit, dp_credit)) AS c_balance FROM Arpost
                          RIGHT JOIN (
                               SELECT dp_lineid, dp_credit, CAST(NVL(ap_headid,-1) AS Numeric(8)) AS c_headid FROM Deposit
                                    INNER JOIN Paymetho ON pm_paynum = dp_paynum
                                    LEFT JOIN Arpost ON ap_postid = dp_postid
                                    WHERE dp_reserid = <<SqlCnv(pnReserid)>> AND dp_posted = __EMPTY_DATE__ AND dp_credit > 0 AND pm_paytyp = 4
                                    ) dp ON ap_headid = c_headid
                          GROUP BY 1,2
                ENDTEXT
           ELSE
                TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
                     SELECT dp_lineid, CAST(NVL(ld_ldid,-1) AS Integer) AS c_ldid, NVL(ld_billamt-ld_paidamt, dp_credit) AS c_balance FROM Deposit
                          INNER JOIN Paymetho ON pm_paynum = dp_paynum
                          LEFT JOIN ledgpost ON ld_postid = dp_postid
                          WHERE dp_reserid = <<SqlCnv(pnReserid)>> AND dp_posted = __EMPTY_DATE__ AND dp_credit > 0 AND pm_paytyp = 4
                ENDTEXT
           ENDIF
           l_curDpBalance = SqlCursor(l_cSql)
           IF DLocate(l_curDpBalance, "c_balance > 0")
                Alert(GetLangText("DP","TA_DPOPENPAYMENTS"))
           ENDIF
           DClose(l_curDpBalance)
           l_nDpReceipt = DLookUp("deposit", "dp_reserid = " + SqlCnv(pnReserid) + " AND NOT EMPTY(dp_receipt)", "dp_receipt")
           l_cSupplement = IIF(EMPTY(l_nDpReceipt), "", "Deposit Rechnung-Nr.: " + TRANSFORM(l_nDpReceipt))
           SELECT Deposit
           IF ncRedit<>0
                l_lNoVat = DpCheckAddressVat(pnReserid)
                IF NOT l_lNoVat
                    odata = .NULL.
                    dpcalcvat("dp_reserid = " + sqlcnv(pnReserid) + " AND dp_posted={}", @odata, ncRedit)
                    ncredit = odata.ps_amount
                ENDIF

                ncRedit = ncRedit * -1
                odata.ps_vat0 = odata.ps_vat0 * -1
                odata.ps_vat1 = odata.ps_vat1 * -1
                odata.ps_vat2 = odata.ps_vat2 * -1
                odata.ps_vat3 = odata.ps_vat3 * -1
                odata.ps_vat4 = odata.ps_vat4 * -1
                odata.ps_vat5 = odata.ps_vat5 * -1
                odata.ps_vat6 = odata.ps_vat6 * -1
                odata.ps_vat7 = odata.ps_vat7 * -1
                odata.ps_vat8 = odata.ps_vat8 * -1
                odata.ps_vat9 = odata.ps_vat9 * -1
                poStart(pnReserid,1,paRam.pa_depxfer,1,ncRedit,'',l_cSupplement,l_lNoVat,odata)
           ENDIF
           SCAN ALL FOR dp_reserid=pnReserid .AND. dp_addpost .AND.  ;
                dp_posted={}
                poStart(pnReserid,1,dp_artinum,1,dp_debit,'','')
           ENDSCAN
           REPLACE dp_posted WITH sySdate() ALL FOR dp_reserid=pnReserid
           IF CURSORGETPROP("Buffering") == 1
               FLUSH
           ELSE
               = TABLEUPDATE(.T.,.T.) && deposit table
           ENDIF
      ENDIF
      IF !g_newversionactive
          dcLose('Deposit')
      ENDIF
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE DPCancel
 LPARAMETERS pnReserid, plCancel
 LOCAL naRea, ndEbit, ncRedit, i, niD, nbAlance
 PRIVATE ahEaders
 IF EMPTY(paRam.pa_depcxl)
      alErt( ;
           "Article for automatic cancellation of deposits is not setup in the parameters!" ;
           )
      plCancel = .T.
      RETURN
 ENDIF
 naRea = SELECT()
 IF doPen('Deposit')
      CALCULATE SUM(dp_debit), SUM(dp_credit) TO ndEbit, ncRedit FOR  ;
                dp_reserid=pnReserid .AND. dp_posted={}
      IF ncRedit<>0
           alErt(GetLangText("DP","TA_DPHASCREDIT"))
           plCancel = .T.
      ELSE
           IF ndEbit<>0
                IF yeSno(GetLangText("DP","TA_DPAUTOCXL")+'@2')
                     COPY TO ARRAY ahEaders FIELDS dp_headid ALL FOR  ;
                          dp_reserid=pnReserid .AND. dp_headid=dp_lineid
                     IF _TALLY>0
                          FOR i = 1 TO ALEN(ahEaders, 1)
                               nbAlance = dpBal(ahEaders(i))
                               niD = neXtid('DEPOSIT')
                               INSERT INTO Deposit (dp_lineid, dp_headid,  ;
                                      dp_artinum, dp_date, dp_sysdate,  ;
                                      dp_reserid, dp_debit) VALUES (niD,  ;
                                      ahEaders(i), paRam.pa_depcxl,  ;
                                      sySdate(), sySdate(), pnReserid, - ;
                                      nbAlance)
                               FLUSH
                               
                          ENDFOR
                     ENDIF
                ELSE
                     plCancel = .T.
                ENDIF
           ENDIF
      ENDIF
      dcLose('Deposit')
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE dpnewarticle
LOCAL niD, l_lSuccess, l_lDepVat, ndepamt1, ndepamt2, nsum, ndepsum1, ndepsum2, ndepmax, nrsid, ncount, csql, dduedate, npercent
IF _screen.oGlobal.oParam2.pa_depvat
     * Here we should check how many vat groups are in deposit amount. We should calcualte it from ressplit.
     nrsid = reservat.rs_rsid
     ndepamt1 = reservat.rs_depamt1
     ndepamt2 = reservat.rs_depamt2
     cwhere = dpgetreservatfilterclause()
     TEXT TO csql TEXTMERGE NOSHOW PRETEXT 15
     SELECT pl_numval, pl_user4, CAST(SUM(rl_price*rl_units*rs_rooms) AS Numeric(13,2)) AS camt, ;
          CAST(0  AS Numeric(13,2)) AS cpropamt1, CAST(0  AS Numeric(13,2)) AS cpropamt2 ;
          FROM reservat ;
          INNER JOIN ressplit ON rs_rsid = rl_rsid ;
          INNER JOIN article ON rl_artinum = ar_artinum ;
          INNER JOIN picklist p1 ON p1.pl_label = 'VATGROUP' AND ar_vat = p1.pl_numcod ;
          WHERE <<cwhere>> AND rl_price*rl_units <> 0 ;
          GROUP BY 1,2 ;
          ORDER BY 2 DESC
     ENDTEXT
     = sqlcursor(csql,"cdepcal1095",,,,.T.,,.T.)
     l_lDepVat = (RECCOUNT("cdepcal1095") > 0)
ENDIF
IF l_lDepVat
     SUM camt TO nsum

     SCAN ALL
          IF ndepamt1<>0
               REPLACE cpropamt1 WITH ROUND(ndepamt1*camt/nsum,2)
          ENDIF
          IF ndepamt2<>0
               REPLACE cpropamt2 WITH ROUND(ndepamt2*camt/nsum,2)
          ENDIF
     ENDSCAN
     SUM cpropamt1, cpropamt2 TO ndepsum1, ndepsum2
     IF ndepsum1 <> ndepamt1
          * Remove rounding error for reservat.rs_depamt1
          CALCULATE MAX(cpropamt1) TO ndepmax
          LOCATE FOR cpropamt1 = ndepmax
          REPLACE cpropamt1 WITH cpropamt1 - ndepsum1 + ndepamt1
     ENDIF
     IF ndepsum2 <> ndepamt2
          * Remove rounding error for reservat.rs_depamt2
          CALCULATE MAX(cpropamt2) TO ndepmax
          LOCATE FOR cpropamt2 = ndepmax
          REPLACE cpropamt2 WITH cpropamt2 - ndepsum2 + ndepamt2
     ENDIF

     IF ndepamt1 <> 0
          niD = neXtid('DEPOSIT')
          niDline = niD
          ncount = 0
          ndepcnt = 1
          dduedate = reservat.rs_Depdat1
          npercent = 100 * ndepamt1/nsum
          SCAN FOR ISDIGIT(ALLTRIM(pl_user4)) AND cpropamt1<>0
               ncount = ncount + 1
               IF ncount > 1
                    niDline = neXtid('DEPOSIT')
                    ndepcnt = 0
                    dduedate = {}
                    npercent = 0
               ENDIF
               nartinum = INT(VAL(pl_user4))
               Insert Into Deposit (dp_lineid, dp_headid, dp_artinum, dp_date, dp_sysdate, dp_reserid, dp_depcnt, dp_debit, dp_due, dp_userid, dp_percent)  ;
                    VALUES (niDline, niD, nartinum, sysdate(), sysdate(), reservat.rs_Reserid, ndepcnt, cdepcal1095.cpropamt1, dduedate, g_userid, npercent)
          ENDSCAN
     ENDIF

     IF ndepamt2 <> 0
          niD = neXtid('DEPOSIT')
          niDline = niD
          ncount = 0
          ndepcnt = 2
          dduedate = reservat.rs_Depdat2
          npercent = 100 * ndepamt2/nsum
          SCAN FOR ISDIGIT(ALLTRIM(pl_user4)) AND cpropamt2<>0
               ncount = ncount + 1
               IF ncount > 1
                    niDline = neXtid('DEPOSIT')
                    ndepcnt = 0
                    dduedate = {}
                    npercent = 0
               ENDIF
               nartinum = INT(VAL(pl_user4))
               Insert Into Deposit (dp_lineid, dp_headid, dp_artinum, dp_date,dp_sysdate, dp_reserid, dp_depcnt, dp_debit, dp_due, dp_userid, dp_percent)  ;
                    VALUES (niDline, niD, nartinum, sysdate(),sysdate(), reservat.rs_Reserid, ndepcnt, cdepcal1095.cpropamt2, dduedate, g_userid, npercent)
          ENDSCAN
     ENDIF
ELSE
     IF reservat.rs_Depamt1<>0
          niD = neXtid('DEPOSIT')
          Insert Into Deposit (dp_lineid, dp_headid, dp_artinum, dp_date,dp_sysdate, dp_reserid, dp_depcnt, dp_debit, dp_due, dp_userid)  ;
               VALUES (niD, niD, Param.pa_departi, sysdate(),sysdate(), reservat.rs_Reserid, 1, reservat.rs_Depamt1, reservat.rs_Depdat1, g_userid)
     Endif
     If reservat.rs_Depamt2<>0
          niD = neXtid('DEPOSIT')
          Insert Into Deposit (dp_lineid, dp_headid, dp_artinum, dp_date,dp_sysdate, dp_reserid, dp_depcnt, dp_debit, dp_due, dp_userid)  ;
               VALUES (niD, niD, Param.pa_departi, sysdate(),sysdate(), reservat.rs_Reserid, 2, reservat.rs_Depamt2, reservat.rs_Depdat2, g_userid)
     ENDIF
ENDIF
DoTableUpdate(.T.,.T.,"deposit")
l_lSuccess = EndTransaction()

RETURN l_lSuccess
ENDPROC
*
PROCEDURE dpgetreservatfilterclause
LPARAMETERS lp_cWhere
LOCAL cwhere, nreserid
nreserid = reservat.rs_reserid
DO CASE
     CASE NOT EMPTY(reservat.rs_groupid) AND dlookup("groupres","gr_groupid = " + sqlcnv(reservat.rs_groupid,.T.),"gr_pmresid") = nreserid
          * Paymaster
          cwhere = [rs_reserid >= ]+sqLcnv(INT(nreserid))+ [ AND rs_reserid < ]+sqLcnv(INT(nreserid)+1) + [ AND NOT rs_status IN ('NS','CXL')]
     CASE reservat.rs_roomlst
          * Group member
          cwhere = "rs_reserid = " + sqLcnv(nreserid)
     OTHERWISE
          * Reservation set
          cwhere = [rs_reserid >= ]+sqLcnv(INT(nreserid))+ [ AND rs_reserid < ]+sqLcnv(INT(nreserid)+1) + [ AND NOT rs_status IN ('NS','CXL')]
ENDCASE
lp_cWhere = cwhere
RETURN cwhere
ENDPROC
*
PROCEDURE dpnewpay
LPARAMETERS lp_lInsert, lp_nHeadId, lp_nAmount, lp_nPayNum, lp_lCommit, lp_lAutoDep, lp_nWindow, lp_lSuccess
LOCAL l_nSelect, l_cPayCur, l_cBalCur, nrOunddiff, cvAtmacro1, cvAtmacro2, l_lAllowed, l_nReserId, l_cRef, l_lNoVat, ;
          odata, l_nPostId1, l_nPostId2, l_lPaymentWithElPay, l_nPayNum, l_nAddrIdForDebitor, l_nWindowForDebitor, ;
          l_oCheckRes, l_nAddrId, l_nAddressRecNo
lp_lSuccess = .F.
IF EMPTY(lp_nPayNum)
     RETURN lp_lSuccess
ENDIF
IF EMPTY(lp_nWindow)
     lp_nWindow = 0
ENDIF
l_nSelect = SELECT()
l_cPayCur = sqlcursor("SELECT * from paymetho WHERE pm_paynum = " + sqlcnv(lp_nPayNum),"",.F.,"",.NULL.,.T.)
IF RECCOUNT(l_cPayCur)=0
     dclose(l_cPayCur)
     RETURN lp_lSuccess
ENDIF

l_nReserId = reservat.rs_reserid
IF lp_lAutoDep
     l_cRef = "Deposit AUTO"
     lp_nWindow = DEPOSIT_AUTO_WINDOW
     * check when debitor payment, is this address for lp_nWindow defined as debitor?
     DO biLlinstr IN BillInst WITH param.pa_departi, reservat.rs_billins, l_nReserId, lp_nWindow
ENDIF

* check when debitor payment, is this address for lp_nWindow defined as debitor?
IF INLIST(&l_cPayCur..pm_paytyp, 3, 4)

     * Find bill window where is set debitor address
     lp_nWindow = DEPOSIT_AUTO_WINDOW
     l_nAddrIdForDebitor = 0
     l_nWindowForDebitor = 2
     DO BillAddrId IN ProcBill WITH l_nWindowForDebitor, reservat.rs_rsid, reservat.rs_addrid, l_nAddrIdForDebitor
     IF EMPTY(l_nAddrIdForDebitor)
          l_nWindowForDebitor = 3
          DO BillAddrId IN ProcBill WITH l_nWindowForDebitor, reservat.rs_rsid, reservat.rs_addrid, l_nAddrIdForDebitor
          IF EMPTY(l_nAddrIdForDebitor)
               l_nWindowForDebitor = 1
               l_nAddrIdForDebitor = reservat.rs_addrid
          ENDIF
     ENDIF
     l_nAddrId = 0
     DO BillAddrId IN procbill WITH lp_nWindow,reservat.rs_rsid,reservat.rs_addrid, l_nAddrId
     IF l_nAddrId <> l_nAddrIdForDebitor
          * Address for bill window 5 is not same as address for debitor, so change it
          l_nAddressRecNo = RECNO("address")
          IF SEEK(l_nAddrIdForDebitor, "address", "tag1")
               l_oCheckRes = CREATEOBJECT("checkreservat")
               l_oCheckRes.rs_billins_line_replace(lp_nWindow+IIF(lp_nWindow>3,1,0), "reservat")
          ENDIF
          GO l_nAddressRecNo IN address
     ENDIF

     l_lAllowed = procbill("BillPayValid", l_nReserId, l_nWindowForDebitor, lp_nPayNum, lp_nAmount)
     * Only for pm_paytyp =  4 (Debitor account) don't allow payment.
     * For pm_paytyp = 3 (Visa, American Express) only show warning, but allow payment.
     IF NOT l_lAllowed AND &l_cPayCur..pm_paytyp = 4
          RETURN lp_lSuccess
     ENDIF
ENDIF

IF &l_cPayCur..pm_paytyp = 4
     * Force postings on DEPOSIT_AUTO_WINDOW windows, for debitor payment
     lp_nWindow = DEPOSIT_AUTO_WINDOW
ENDIF

IF lp_nWindow > 0
     * First check is free wished window
     LOCAL ARRAY l_aWin(1)
     LOCAL l_lSilent, l_lForce, l_lDontReopen, l_lValid
     l_lValid = .T.
     l_aWin(1) = lp_nWindow
     l_lSilent = .T. && Dont show messages
     l_lForce = .F.
     l_lDontReopen = .T.
     l_lAllowed = BillsReserCheck(l_nReserId, @l_aWin, "POST_NEW", l_lValid, l_lSilent, l_lForce, l_lDontReopen)
     IF NOT l_lAllowed
          = alert(GetLangText("BILL","TXT_BILL_ISSUED")+CHR(13)+CHR(13)+;
                    GetLangText("BILL","TXT_BILL_WINDOWS")+" "+TRANSFORM(lp_nWindow))
          
          RETURN lp_lSuccess
     ENDIF
ENDIF

IF lp_lInsert
     m.dp_headid=lp_nHeadId
     m.dp_lineid=nextid('deposit')
     m.dp_date=sysdate()
     m.dp_reserid=reservat.rs_reserid
     m.dp_userid=g_Userid
     m.dp_cashier=g_Cashier
     INSERT INTO deposit FROM MEMVAR
ENDIF

IF EMPTY(deposit.dp_date)
     = alert(GetLangText("DP","TA_DATEREQ"))
     RETURN lp_lSuccess
ENDIF

IF NOT EMPTY(lp_nPayNum)
     REPLACE deposit.dp_paynum WITH &l_cPayCur..pm_paynum IN deposit
ENDIF

IF EMPTY(deposit.dp_paynum)
     = alert(GetLangText("DP","TA_PAYREQ"))
     RETURN lp_lSuccess
ENDIF
IF EMPTY(lp_nAmount)
     = alert(GetLangText("DP","TA_AMTREQ"))
     RETURN lp_lSuccess
ENDIF

dpcalcbal(@l_cBalCur)

REPLACE dp_sysdate WITH sysdate(), ;
          dp_credit WITH ROUND(lp_nAmount*&l_cPayCur..pm_calcrat, param.pa_currdec) ;
          IN deposit

IF ROUND(IIF(SEEK(deposit.dp_headid,l_cBalCur,'tag1'),&l_cBalCur..balance,0)/&l_cPayCur..pm_calcrat, Param.pa_currdec)=lp_nAmount
     nrOunddiff = IIF(SEEK(deposit.dp_headid,l_cBalCur,'tag1'),&l_cBalCur..balance,0)-deposit.dp_credit
     IF nrOunddiff<>0.00
          REPLACE dp_credit WITH dp_credit+nrOunddiff IN deposit
     ENDIF
ENDIF
IF NOT EMPTY(l_cRef)
     REPLACE deposit.dp_ref WITH l_cRef IN deposit
ENDIF

l_lNoVat = DpCheckAddressVat(l_nReserId, "reservat")

SELECT deposit
SCATTER MEMVAR

* ELPAY **********************************************************************************
l_nPostId1 = nextid('POST')
l_nPostId2 = nextid('POST')

l_lPaymentWithElPay = .F.
l_nPayNum = deposit.dp_paynum
IF NOT pbpayelpay(m.dp_credit, @l_nPayNum, @l_lPaymentWithElPay,,,,l_nPostId2, l_cPayCur)
     dclose(l_cPayCur)
     SELECT (l_nSelect)
     lp_lSuccess = .F.
     RETURN lp_lSuccess
ENDIF
IF deposit.dp_paynum <> l_nPayNum
     REPLACE dp_paynum WITH l_nPayNum IN deposit
ENDIF
******************************************************************************************

m.ps_reserid= l_nReserId
m.ps_userid=g_Userid
m.ps_cashier=g_Cashier
m.ps_postid=l_nPostId1
m.ps_date=sysdate()
m.ps_units=1
m.ps_paynum=0
m.ps_descrip=m.dp_descrip
m.ps_supplem=EVL(m.dp_supplem,DTOC(m.dp_date)+m.dp_ref)
m.ps_time=TIME()
m.ps_window=lp_nWindow
m.ps_touched=.f.
m.ps_addrid=0
m.ps_artinum= param.pa_departi
m.ps_cancel=.f.
m.ps_origid=reservat.rs_reserid
m.ps_prtype=0
m.ps_setid=0
m.ps_split=.f.
m.ps_price=m.dp_credit
m.ps_amount=m.dp_credit
l_vatnum=0
l_vatpct=0
l_vatnum2=0
l_vatpct2=0
DO sarticle in particle

IF NOT l_lNoVat
     odata = .NULL.

     dpcalcvat("dp_headid = " + TRANSFORM(lp_nHeadId), @odata, m.ps_price)

     m.ps_price = odata.ps_price
     m.ps_amount = odata.ps_amount
     m.ps_vat0 = odata.ps_vat0
     m.ps_vat1 = odata.ps_vat1
     m.ps_vat2 = odata.ps_vat2
     m.ps_vat3 = odata.ps_vat3
     m.ps_vat4 = odata.ps_vat4
     m.ps_vat5 = odata.ps_vat5
     m.ps_vat6 = odata.ps_vat6
     m.ps_vat7 = odata.ps_vat7
     m.ps_vat8 = odata.ps_vat8
     m.ps_vat9 = odata.ps_vat9
ELSE
     * This address pays no vat
     STORE 0 TO m.ps_vat0, m.ps_vat1, m.ps_vat2, m.ps_vat3, m.ps_vat4, m.ps_vat5, m.ps_vat6, m.ps_vat7, m.ps_vat8, m.ps_vat9
ENDIF

INSERT INTO post FROM memvar
STORE 0 TO m.ps_vat0, m.ps_vat1, m.ps_vat2, m.ps_vat3, m.ps_vat4, m.ps_vat5, m.ps_vat6, m.ps_vat7, m.ps_vat8, m.ps_vat9
m.ps_reserid= l_nReserId
m.ps_userid=g_userid
m.ps_cashier=g_cashier
m.ps_postid=l_nPostId2
m.ps_date=sysdate()
m.ps_amount=-deposit.dp_credit
m.ps_units=deposit.dp_credit
m.ps_paynum=l_nPayNum
m.ps_price=1
m.ps_descrip=deposit.dp_descrip
m.ps_supplem=EVL(deposit.dp_supplem,DTOC(deposit.dp_date)+deposit.dp_ref)
m.ps_time=TIME()
m.ps_window=lp_nWindow
STORE 0 TO m.ps_addrid,m.ps_artinum,m.ps_prtype,m.ps_setid
STORE .F. TO m.ps_touched,m.ps_cancel,m.ps_split
m.ps_origid=reservat.rs_reserid
INSERT INTO post FROM MEMVAR

REPLACE deposit.dp_postid WITH m.ps_postid IN deposit
REPLACE rs_deppdat WITH deposit.dp_date, ;
          rs_deppaid WITH reservat.rs_deppaid+deposit.dp_credit IN reservat

IF lp_lAutoDep AND l_nReserId = reservat.rs_reserid
     IF CURSORGETPROP("Buffering","post")<>1
          TABLEUPDATE(.T.,.T.,"post")
     ENDIF
     PrntBill(reservat.rs_reserid,lp_nWindow,,MAX(&l_cPayCur..pm_copy,1),,,,.T.)
ENDIF

dclose(l_cPayCur)

IF lp_lCommit OR l_lPaymentWithElPay
     DoTableUpdate(.T.,.T.,"deposit")
     DoTableUpdate(.T.,.T.,"post")
     DoTableUpdate(.T.,.T.,"reservat")
     DoTableUpdate(.T.,.T.,"billnum")
     lp_lSuccess = EndTransaction()
ELSE
     FLUSH
     lp_lSuccess = .T.
ENDIF

SELECT (l_nSelect)

RETURN lp_lSuccess
ENDPROC
*
PROCEDURE dpcalcvat
LPARAMETERS lp_cWhere, lp_odata, lp_nPrice
LOCAL nprop, l_nSelect

l_nSelect = SELECT()

SELECT post
SCATTER NAME lp_odata BLANK
lp_odata.ps_price = lp_nPrice

* Get vats for all articles
SELECT CAST(SUM(dp_debit) AS Numeric(12,2)) AS ps_amount, ;
     CAST(SUM(IIF(pl_numval=0.00,dp_debit,0)) AS Numeric(18,6)) AS ps_vat0, ;
     CAST(SUM(IIF(ar_vat=1,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat1, ;
     CAST(SUM(IIF(ar_vat=2,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat2, ;
     CAST(SUM(IIF(ar_vat=3,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat3, ;
     CAST(SUM(IIF(ar_vat=4,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat4, ;
     CAST(SUM(IIF(ar_vat=5,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat5, ;
     CAST(SUM(IIF(ar_vat=6,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat6, ;
     CAST(SUM(IIF(ar_vat=7,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat7, ;
     CAST(SUM(IIF(ar_vat=8,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat8, ;
     CAST(SUM(IIF(ar_vat=9,dp_debit*pl_numval/(100+pl_numval),0)) AS Numeric(18,6)) AS ps_vat9 ;
     FROM deposit WITH (BUFFERING = .T.) ;
     INNER JOIN article ON dp_artinum = ar_artinum ;
     INNER JOIN picklist ON pl_label = 'VATGROUP' AND pl_numcod = ar_vat ;
     WHERE &lp_cWhere AND dp_debit > 0.00 ;
     INTO CURSOR csvat1 READWRITE

IF csvat1.ps_amount = 0.00
     nprop = 1
ELSE
     nprop = lp_odata.ps_price/csvat1.ps_amount && Ratio
ENDIF

REPLACE ps_vat0 WITH ROUND(ps_vat0*nprop,6), ;
        ps_vat1 WITH ROUND(ps_vat1*nprop,6), ;
        ps_vat2 WITH ROUND(ps_vat2*nprop,6), ;
        ps_vat3 WITH ROUND(ps_vat3*nprop,6), ;
        ps_vat4 WITH ROUND(ps_vat4*nprop,6), ;
        ps_vat5 WITH ROUND(ps_vat5*nprop,6), ;
        ps_vat6 WITH ROUND(ps_vat6*nprop,6), ;
        ps_vat7 WITH ROUND(ps_vat7*nprop,6), ;
        ps_vat8 WITH ROUND(ps_vat8*nprop,6), ;
        ps_vat9 WITH ROUND(ps_vat9*nprop,6)

IF (param.pa_exclvat)
     lp_odata.ps_price = lp_odata.ps_price - (ROUND(ps_vat0+ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9,param.pa_currdec))
ENDIF

lp_odata.ps_amount = lp_odata.ps_price

lp_odata.ps_vat0 = ps_vat0
lp_odata.ps_vat1 = ps_vat1
lp_odata.ps_vat2 = ps_vat2
lp_odata.ps_vat3 = ps_vat3
lp_odata.ps_vat4 = ps_vat4
lp_odata.ps_vat5 = ps_vat5
lp_odata.ps_vat6 = ps_vat6
lp_odata.ps_vat7 = ps_vat7
lp_odata.ps_vat8 = ps_vat8
lp_odata.ps_vat9 = ps_vat9

dclose("csvat1")

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE dpautopost
LPARAMETERS lp_nTotalPrice, lp_lDepositPosted
LOCAL l_nRs_depamt1, l_dRs_depdat1, l_nRecno, l_nOrder, l_nSelect, l_nRecnoF

lp_lDepositPosted = .F.

IF EMPTY(lp_nTotalPrice)
     lp_nTotalPrice = 0
ENDIF
*!*     IF EMPTY(reservat.rs_depamt1) AND ;
*!*               EMPTY(reservat.rs_in) AND INLIST(reservat.rs_status, "DEF", "ASG","6PM","OPT","TEN") AND ;
*!*               NOT EMPTY(param2.pa_depperc) AND NOT EMPTY(param2.pa_depbefa) AND NOT EMPTY(lp_nTotalPrice)

l_nRs_depamt1 = lp_nTotalPrice * (param2.pa_depperc / 100)
l_nRs_depamt1 = ROUND(l_nRs_depamt1, param.pa_currdec)

IF reservat.rs_depamt1<>l_nRs_depamt1 AND ;
          EMPTY(reservat.rs_in) AND INLIST(reservat.rs_status, "DEF", "ASG","6PM","OPT","TEN") AND ;
          NOT EMPTY(param2.pa_depperc) AND NOT EMPTY(param2.pa_depbefa) AND NOT EMPTY(lp_nTotalPrice)
     l_dRs_depdat1 = reservat.rs_created + param2.pa_depbefa
     IF l_nRs_depamt1 > 0.00 AND l_dRs_depdat1 <= reservat.rs_arrdate
          l_nSelect = SELECT()
          REPLACE rs_depamt1 WITH l_nRs_depamt1, ;
                    rs_depdat1 WITH l_dRs_depdat1 IN reservat
          lp_lDepositPosted = .T.
          SELECT deposit
          l_nRecno = RECNO()
          l_nOrder = ORDER()
          SET ORDER TO
          LOCATE FOR dp_reserid = reservat.rs_reserid AND dp_depcnt=1 AND dp_headid=dp_lineid
          IF FOUND()
               SCATTER MEMVAR BLANK
               m.dp_headid=deposit.dp_headid
               l_nRecnoF = RECNO()
               SUM dp_debit FOR dp_reserid = reservat.rs_reserid AND dp_headid=m.dp_headid AND dp_artinum=param.pa_departi TO l_nDebit
               GO l_nRecnoF
               IF l_nRs_depamt1-l_nDebit<>0
                    m.dp_lineid=nextid('deposit')
                    m.dp_date=sysdate()
                    m.dp_reserid=reservat.rs_reserid
                    m.dp_userid=g_Userid
                    m.dp_cashier=g_Cashier
                    m.dp_artinum=param.pa_departi
                    m.dp_debit=l_nRs_depamt1-l_nDebit
                    INSERT INTO deposit FROM memvar
                    DoTableUpdate(.T.,.T.,"deposit")
                    EndTransaction()
               ENDIF
          ENDIF
          SET ORDER TO l_nOrder
          GO l_nRecno
          SELECT (l_nSelect)
     ENDIF
     
ENDIF
RETURN lp_lDepositPosted
ENDPROC
*
PROCEDURE dpautopostallowed
LPARAMETERS lp_lAllowed
lp_lAllowed = _screen.dp AND ;
          ((NOT EMPTY(_screen.oGlobal.oParam2.pa_depbefa) AND NOT EMPTY(_screen.oGlobal.oParam2.pa_depperc)) OR ;
            _screen.oGlobal.oParam2.pa_depvat)
RETURN lp_lAllowed
ENDPROC
*
PROCEDURE dpcalcbal
LPARAMETERS lp_cCur
LOCAL l_nSelect, lnreserid, lnDepRN, lnRn, lnHeadid
l_nSelect = SELECT()
IF EMPTY(lp_cCur)
     lp_cCur = SYS(2015)
ENDIF

lndepRn=RECNO("deposit")
lnReserid=reservat.rs_reserid


dclose(lp_cCur)

CREATE CURSOR (lp_cCur) (dp_headid N(8), balance b(8)) 
INDEX ON dp_headid TAG tag1

SELECT deposit
SCAN FOR lnReserid=dp_reserid
     lnRn=RECNO()
     lnHeadid=dp_headid
     m.dp_headid=dp_headid
     SUM dp_debit-dp_credit FOR dp_headid=lnHeadid TO m.balance
     GO lnRn
     IF SEEK(dp_headid,lp_cCur,'tag1')
          SELECT &lp_cCur
          GATHER MEMVAR
          SELECT deposit
     ELSE
          INSERT INTO &lp_cCur FROM memvar
     ENDIF
ENDSCAN

GO lndepRn IN deposit

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE DpCheckAddressVat
LPARAMETERS lp_nReserId, lp_cResAlias, lp_lNoVat
LOCAL l_lNoVat, l_nUstidnr, l_cResCur, l_cAdrCur, l_nSelect, l_nAddrId, l_lContinue, l_lCloseCur
l_lNoVat = .F.
lp_lNoVat = .F.
IF EMPTY(lp_nReserId)
     RETURN l_lNoVat
ENDIF

l_nSelect = SELECT()

IF EMPTY(lp_cResAlias)
     l_cResCur = sqlcursor("SELECT rs_invid, rs_compid, rs_addrid FROM reservat WHERE rs_reserid = " + sqlcnv(lp_nReserId,.T.))
     l_lContinue = NOT EMPTY(l_cResCur) AND RECCOUNT()>0
     l_lCloseCur = .T.
ELSE
     l_cResCur = lp_cResAlias
     l_lContinue = .T.
ENDIF
IF l_lContinue
     l_nUstidnr = 0
     DO CASE
          CASE NOT EMPTY(&l_cResCur..rs_invid)
               l_nAddrId = &l_cResCur..rs_invid
          CASE NOT EMPTY(&l_cResCur..rs_compid)
               l_nAddrId = &l_cResCur..rs_compid
          CASE NOT EMPTY(&l_cResCur..rs_addrid)
               l_nAddrId = &l_cResCur..rs_addrid
          OTHERWISE
               l_nAddrId = 0
     ENDCASE
     IF NOT EMPTY(l_nAddrId)
          l_cAdrCur = sqlcursor("SELECT ad_novat FROM address WHERE ad_addrid = " + sqlcnv(l_nAddrId,.T.))
          IF RECCOUNT()>0
               l_lNoVat = &l_cAdrCur..ad_novat
          ENDIF
          dclose(l_cAdrCur)
     ENDIF
ENDIF
IF l_lCloseCur
     dclose(l_cResCur)
ENDIF

SELECT (l_nSelect)
lp_lNoVat = l_lNoVat
RETURN l_lNoVat
ENDPROC