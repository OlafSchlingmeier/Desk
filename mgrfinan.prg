*
FUNCTION MgrArticle
	do form "Forms\MngForm" with "MngArticleCtrl"
	return
 PARAMETER lsElect
 PRIVATE clEvel
 PRIVATE cbUttons
 PRIVATE noLdarea
 PRIVATE noLdrec
 PRIVATE noLdord
 PRIVATE acFields
 DIMENSION acFields[8, 4]
 PRIVATE acPrtypes
 IF (PARAMETERS()==0)
      lsElect = .F.
 ENDIF
 acFields[1, 1] = "Article.Ar_ArtiNum"
 acFields[1, 2] = 10
 acFields[1, 3] = GetLangText("MGRFINAN","TXT_ARNUM")
 acFields[1, 4] = ""
 acFields[2, 1] = "Article.Ar_Lang"+g_Langnum
 acFields[2, 2] = 50
 acFields[2, 3] = GetLangText("MGRFINAN","TXT_ARLANG")
 acFields[2, 4] = ""
 acFields[3, 1] = "Transform(Article.Ar_Price, Right(gcCurrcyDisp, 11))"
 acFields[3, 2] = 13
 acFields[3, 3] = GetLangText("MGRFINAN","TXT_ARPRICE")
 acFields[3, 4] = "@J"
 acFields[4, 1] = "Article.Ar_PrType"
 acFields[4, 2] = 3
 acFields[4, 3] = GetLangText("MGRFINAN","TXT_PRINTTYPE")
 acFields[4, 4] = ""
 acFields[5, 1] = "Article.Ar_Main"
 acFields[5, 2] = 6
 acFields[5, 3] = GetLangText("MGRFINAN","TXT_MAIN_GROUP")
 acFields[5, 4] = ""
 acFields[6, 1] = "Article.Ar_Sub"
 acFields[6, 2] = 6
 acFields[6, 3] = GetLangText("MGRFINAN","TXT_SUB_GROUP")
 acFields[6, 4] = ""
 acFields[7, 1] = "Article.Ar_Vat"
 acFields[7, 2] = 6
 acFields[7, 3] = GetLangText("MGRFINAN","TXT_VAT_CODE")
 acFields[7, 4] = ""
 acFields[8, 1] = "Article.Ar_StckCur"
 acFields[8, 2] = 10
 acFields[8, 3] = GetLangText("MGRFINAN","T_STOCKCUR")
 acFields[8, 4] = ""
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,IIF(lsElect, GetLangText("COMMON","TXT_SELECT"),  ;
            GetLangText("COMMON","TXT_CLOSE")),1)+"\!"+buTton(clEvel, ;
            GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON","TXT_COPY"),4)+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_SEARCH"),5)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_DELETE"),6)+buTton(clEvel,GetLangText("MGRFINAN", ;
            "TB_UPDKEY"),-7)
 noLdarea = SELECT()
 SELECT arTicle
 noLdrec = RECNO("article")
 noLdord = ORDER("article")
 SET ORDER TO 1
 GOTO TOP
 cmX1button = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("MGRFINAN","TXT_ARBROWSE"),20,@acFields,".t.",".t.", ;
   cbUttons,"vARControl","MGRFINAN")
 gcButtonfunction = cmX1button
 SET ORDER IN "Article" TO nOldOrd
 IF ( .NOT. lsElect)
      GOTO noLdrec IN "Article"
 ENDIF
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION vARControl
 PARAMETER ncHoice, cwIndow
 PRIVATE clAnguagemacro
 clAnguagemacro = "article.ar_lang"+M.g_Langnum
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           = scRarticle("EDIT")
           g_Refreshall = UPDATED()
      CASE ncHoice==3
           = scRarticle("NEW")
           g_Refreshall = .T.
      CASE ncHoice==4
           = scRarticle("COPY")
           g_Refreshall = .T.
      CASE ncHoice==5
           = arSearch()
           g_Refreshall = .T.
      CASE ncHoice==6
           If ( YesNo(GetLangText("MGRFINAN",  "TXT_ARDELETE") + ";" + LTrim(Str(ar_artinum)) + " " + AllTrim(&cLanguageMacro)) )
                WAIT WINDOW NOWAIT GetLangText("MGRFINAN","TXT_CHKREF")+'...'
                IF  .NOT. INLIST(ar_artinum, paRam.pa_departi,  ;
                    paRam.pa_depxfer, paRam.pa_depcxl, paRam.pa_depspec,  ;
                    paRam.pa_keyarti, paRam.pa_posarti, paRam.pa_posdifa,  ;
                    paRam.pa_pttarti, paRam.pa_ptvarti) .AND.  .NOT.  ;
                    dlOokup('Post','ps_artinum = '+sqLcnv(ar_artinum), ;
                    'Found()') .AND.  .NOT. dlOokup('HistPost', ;
                    'hp_artinum = '+sqLcnv(ar_artinum),'Found()') .AND.   ;
                    .NOT. dlOokup('RateArti','ra_artinum = '+ ;
                    sqLcnv(ar_artinum),'Found()') .AND.  .NOT.  ;
                    dlOokup('ResFix','rf_artinum = '+sqLcnv(ar_artinum), ;
                    'Found()') .AND.  .NOT. dlOokup('Voucher', ;
                    'vo_artinum = '+sqLcnv(ar_artinum),'Found()') .AND.   ;
                    .NOT. dlOokup('Banquet','bq_artinum = '+ ;
                    sqLcnv(ar_artinum),'Found()') .AND.  .NOT.  ;
                    dlOokup('ArPost','ap_artinum = '+sqLcnv(ar_artinum), ;
                    'Found()') .AND.  .NOT. dlOokup('Deposit', ;
                    'dp_artinum = '+sqLcnv(ar_artinum),'Found()')
                     WAIT CLEAR
                     DELETE
                     FLUSH
                ELSE
                     WAIT CLEAR
                     alErt(GetLangText("MGRFINAN","TXT_DELNOTPOSSIBLE"))
                ENDIF
           ENDIF
      CASE ncHoice==7
           arNewkey(ar_artinum)
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE ARNewKey
 LPARAMETERS pnOldkey
 PRIVATE adLg, nnEwkey
 nnEwkey = 0
 DIMENSION adLg[1, 8]
 adLg[1, 1] = "newnum"
 adLg[1, 2] = GetLangText("MGRFINAN","TXT_ARNUM")
 adLg[1, 3] = "0"
 adLg[1, 4] = "9999"
 adLg[1, 5] = 5
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = 0
 IF diAlog(GetLangText("MGRFINAN","TW_NEWKEY"),'',@adLg)
      nnEwkey = adLg(1,8)
      IF dlOokup('Article','ar_artinum = '+sqLcnv(nnEwkey),'Found()')
           alErt(GetLangText("MGRFINAN","TXT_KEYEXISTS"))
      ELSE
           WAIT WINDOW NOWAIT GetLangText("MGRFINAN","TXT_CHKREF")+'...'
           duPdate('Article','ar_artinum = '+sqLcnv(pnOldkey), ;
                  'ar_artinum',nnEwkey)
           duPdate('Post','ps_artinum = '+sqLcnv(pnOldkey),'ps_artinum', ;
                  nnEwkey)
           duPdate('HistPost','hp_artinum = '+sqLcnv(pnOldkey), ;
                  'hp_artinum',nnEwkey)
           duPdate('RateArti','ra_artinum = '+sqLcnv(pnOldkey), ;
                  'ra_artinum',nnEwkey)
           duPdate('ResFix','rf_artinum = '+sqLcnv(pnOldkey),'rf_artinum', ;
                  nnEwkey)
           duPdate('Voucher','vo_artinum = '+sqLcnv(pnOldkey), ;
                  'vo_artinum',nnEwkey)
           duPdate('Banquet','bq_artinum = '+sqLcnv(pnOldkey), ;
                  'bq_artinum',nnEwkey)
           duPdate('ArPost','ap_artinum = '+sqLcnv(pnOldkey),'ap_artinum', ;
                  nnEwkey)
           duPdate('Deposit','dp_artinum = '+sqLcnv(pnOldkey), ;
                  'dp_artinum',nnEwkey)
           duPdate('Param', ,'pa_departi',nnEwkey)
           duPdate('Param', ,'pa_depxfer',nnEwkey)
           duPdate('Param', ,'pa_depcxl',nnEwkey)
           duPdate('Param', ,'pa_depspec',nnEwkey)
           duPdate('Param', ,'pa_keyarti',nnEwkey)
           duPdate('Param', ,'pa_posarti',nnEwkey)
           duPdate('Param', ,'pa_posdifa',nnEwkey)
           duPdate('Param', ,'pa_pttarti',nnEwkey)
           duPdate('Param', ,'pa_ptvarti',nnEwkey)
           WAIT CLEAR
      ENDIF
 ENDIF
ENDPROC
*
PROCEDURE ARSearch
 PRIVATE adLg, nnUm, cdEscr, clAnguagemacro, nrEc
 DIMENSION adLg[2, 8]
 adLg[1, 1] = "num"
 adLg[1, 2] = GetLangText("MGRFINAN","TXT_ARNUM")
 adLg[1, 3] = "0"
 adLg[1, 4] = "9999"
 adLg[1, 5] = 5
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = 0
 adLg[2, 1] = "descr"
 adLg[2, 2] = GetLangText("MGRFINAN","TXT_ARLANG")
 adLg[2, 3] = "Space(20)"
 adLg[2, 4] = ""
 adLg[2, 5] = 20
 adLg[2, 6] = ""
 adLg[2, 7] = ""
 adLg[2, 8] = ''
 IF diAlog(GetLangText("MGRFINAN","TXT_ARSEARCH"), ,@adLg)
      nnUm = adLg(1,8)
      cdEscr = ALLTRIM(adLg(2,8))
      nrEc = RECNO()
      SET NEAR ON
      IF  .NOT. EMPTY(nnUm)
           SEEK nnUm
      ELSE
           clAnguagemacro = "Article.Ar_Lang"+M.g_Langnum
           locate for Upper(&cLanguageMacro) = AllTrim(Upper(cDescr))
      ENDIF
      IF (EOF())
           GOTO nrEc
      ENDIF
      SET NEAR OFF
 ENDIF
ENDPROC
*
PROCEDURE ScrArticle
 PARAMETER coPtion
 PRIVATE cpRtypes
 PRIVATE nsElect
 PRIVATE neXtra
 PRIVATE caRbuttons
 cpRtypes = ""
 PRIVATE ALL LIKE l_*
 l_Choice = 1
 l_Lang = "m.ar_lang"+g_Langnum
 l_Addstock = 0
 caRrbuttons = GetLangText("MGRFINAN","TXT_STANDARD")+";"+GetLangText("MGRFINAN", ;
               "TXT_PAIDOUT")+";"+GetLangText("MGRFINAN","TXT_INTERNAL")+";"+ ;
               GetLangText("MGRFINAN","TXT_VOUCHER")
 SELECT pt_descrip FROM PrTypes ORDER BY pt_number INTO ARRAY acPrtypes
 IF _TALLY=0
      DIMENSION acPrtypes[1]
      acPrtypes = ''
 ENDIF
 DO CASE
      CASE coPtion="NEW"
           SCATTER BLANK MEMVAR
      CASE coPtion="COPY"
           SCATTER MEMVAR
           M.ar_artinum = 0
      CASE coPtion="EDIT"
           SCATTER MEMVAR
 ENDCASE
 nsElect = SELECT()
 IF (opEnfile(.F.,"PrTypes"))
      SELECT prTypes
      IF (SEEK(STR(M.ar_prtype, 2), "PrTypes"))
           cpRtypes = prTypes.pt_descrip
      ENDIF
      USE
 ENDIF
 IF ( .NOT. EMPTY(paRam.pa_aruser1+paRam.pa_aruser2+paRam.pa_aruser3))
      neXtra = 4.75
 ELSE
      neXtra = 0
 ENDIF
 SELECT (nsElect)
 DEFINE WINDOW waRticle AT 0, 0 SIZE 23.75+neXtra, 60 FONT "Arial", 10  ;
        NOGROW NOFLOAT NOCLOSE TITLE chIldtitle(GetLangText("MGRFINAN", ;
        "TXT_ARWINDOW")) NOMDI SYSTEM
 MOVE WINDOW waRticle CENTER
 ACTIVATE WINDOW waRticle
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 arTityp = M.ar_artityp
 = paNelborder()
 = txTpanel(1,4,23,GetLangText("MGRFINAN","TXT_ARNUM"),0)
 = txTpanel(2.25,4,23,GetLangText("MGRFINAN","TXT_ARLANG"),0)
 = txTpanel(3.50,4,23,GetLangText("MGRFINAN","TXT_ARPRICE"),0)
 = txTpanel(5,4,23,GetLangText("MGRFINAN","TXT_ARTYPE"),0)
 = txTpanel(6.75,4,23,GetLangText("MGRFINAN","TXT_PRTYPE"),0)
 = txTpanel(8.25,4,23,IIF(paRam.pa_twovats, GetLangText("MGRFINAN","TXT_ARVATS"),  ;
   GetLangText("MGRFINAN","TXT_ARVAT")),0)
 = txTpanel(9.5,4,23,GetLangText("MGRFINAN","TXT_ARMAIN"),0)
 = txTpanel(10.75,4,23,GetLangText("MGRFINAN","TXT_ARSUB"),0)
 = txTpanel(12,4,23,GetLangText("MGRFINAN","T_STOCK"),0)
 = txTpanel(13.25,4,23,GetLangText("MGRFINAN","T_STOCKCUR"),0)
 = txTpanel(14.5,4,23,GetLangText("MGRFINAN","T_STOCKADD"),0)
 = txTpanel(15.75,4,23,GetLangText("MGRFINAN","T_STOCKMIN"),0)
 = txTpanel(17,4,23,GetLangText("MGRFINAN","TXT_LAYOUT"),0)
 = txTpanel(18.25,4,23,GetLangText("MGRFINAN","TXT_EXPIRE"),0)
 @ 18.250, 32 SAY IIF(paRam.pa_vouexpm, GetLangText("MGRFINAN","TXT_MONTHS"),  ;
   GetLangText("MGRFINAN","TXT_DAYS"))
 IF (neXtra>0)
      FOR nuSerfields = 1 TO 3
           cuSermacro = "Param.Pa_ArUser"+STR(nuSerfields, 1)
           If ( !Empty(&cUserMacro) )
                =TxtPanel(19.50 + (1.25 * nUserFields), 4, 23, AllTrim(&cUserMacro), 0)
           ENDIF
      ENDFOR
 ENDIF
 IF coPtion='EDIT'
      @ 1, 25 GET M.ar_artinum SIZE 1, 6 PICTURE "@KB 9999" WHEN .F.  ;
        COLOR ,RGB(0,0,255,192,192,192)
 ELSE
      @ 1, 25 GET M.ar_artinum SIZE 1, 6 PICTURE "@KB 9999" VALID  .NOT.  ;
        dlOokup('Article','ar_artinum = '+sqLcnv(M.ar_artinum),'Found()')
 ENDIF
 @  2.25, 25 get &l_lang 					 picture "@K " + Replicate("X", 25) 	 valid LangEdit("AR_", GetLangText("MGRFINAN",  "TXT_ARWINDOW"))	 size 1, 30
 @ 3.500, 25 GET M.ar_price SIZE 1, 12 PICTURE "@KB "+RIGHT(gcCurrcy, 9)
 @ 4.750, 25 GET M.arTityp DEFAULT 1 FUNCTION "^" PICTURE caRrbuttons
 @ 6.500, 25 GET M.cpRtypes FROM acPrTypes FUNCTION "^"
 @ 8.250, 25 GET M.ar_vat SIZE 1, 2 PICTURE "@KB 9" VALID  ;
   piCklist("VATGROUP",@M.ar_vat,7.75,25.00,"N","wArticle")
 IF (paRam.pa_twovats)
      @ 8.250, 35 GET M.ar_vat2 SIZE 1, 2 PICTURE "@KB 9" VALID  ;
        piCklist("VATGROUP",@M.ar_vat2,7.75,35.00,"N","wArticle")
 ENDIF
 @ 9.500, 25 GET M.ar_main SIZE 1, 2 PICTURE "@KB 9" VALID  ;
   piCklist("MAINGROUP",@M.ar_main,9.00,25.00,"N","wArticle")
 @ 10.750, 25 GET M.ar_sub SIZE 1, 3 PICTURE "@KB 99" VALID  ;
   piCklist("SUBGROUP",@M.ar_sub,10.25,25.00,"N","wArticle")
 @ 12, 25 GET M.ar_stckctl PICTURE "@*C "+GetLangText("MGRFINAN","TC_STOCK")
 @ 13.250, 25 GET M.ar_stckcur SIZE 1, 10 PICTURE "@K 999999" WHEN M.ar_stckctl
 @ 14.500, 25 GET l_Addstock SIZE 1, 10 PICTURE "@K 999999" VALID  ;
   vaDdstock() WHEN M.ar_stckctl
 @ 15.750, 25 GET M.ar_stckmin SIZE 1, 10 PICTURE "@K 999999" WHEN M.ar_stckctl
 @ 17, 25 GET M.ar_layout SIZE 1, 30 PICTURE "@K" WHEN M.ar_artityp==4
 @ 18.250, 25 GET M.ar_expire SIZE 1, 5 PICTURE "@K 999" WHEN M.ar_artityp==4
 @ 19.500, 4 GET M.ar_return PICTURE '@*C '+GetLangText("MGRFINAN", ;
   "TXT_RETURN_ARTICLE")
 IF (neXtra>0)
      FOR nuSerfields = 1 TO 3
           cuSermacro = "Param.Pa_ArUser"+STR(nuSerfields, 1)
           If ( !Empty(&cUserMacro) )
                cfIeldtoget = "m.Ar_User"+STR(nuSerfields, 1)
                @ 19.50 + (1.25 * nUserFields), 25 Get &cFieldToGet Size 1, 15
           ENDIF
      ENDFOR
 ENDIF
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
   PICTURE "@*TH "+cbUttons VALID vaRchoice(coPtion)
 READ CYCLE MODAL
 RELEASE WINDOW waRticle
 = chIldtitle("")
 RETURN
ENDPROC
*
FUNCTION vAddStock
 M.ar_stckcur = M.ar_stckcur+l_Addstock
 SHOW GET M.ar_stckcur
 RETURN .T.
ENDFUNC
*
FUNCTION vARChoice
 PARAMETER coPtion
 PRIVATE nfIlselect
 PRIVATE lrEtval
 lrEtval = .F.
 DO CASE
      CASE M.l_Choice==1
           IF EMPTY(M.ar_artinum)
                = alErt(GetLangText("MGRFINAN","TXT_ARNO"))
           ELSE
                lrEtval = .T.
                nfIlselect = SELECT()
                IF (opEnfile(.F.,"PrTypes"))
                     SELECT prTypes
                     SET ORDER TO 2
                     IF (SEEK(UPPER(cpRtypes), "PrTypes"))
                          M.ar_prtype = prTypes.pt_number
                     ELSE
                          M.ar_prtype = 0
                     ENDIF
                     USE
                ENDIF
                M.ar_artityp = arTityp
                SELECT (nfIlselect)
                DO CASE
                     CASE coPtion="NEW"
                          INSERT INTO article FROM MEMVAR
                     CASE coPtion="COPY"
                          INSERT INTO article FROM MEMVAR
                     CASE coPtion="EDIT"
                          GATHER MEMVAR
                ENDCASE
                CLEAR READ
           ENDIF
      CASE M.l_Choice==2
           lrEtval = .T.
           CLEAR READ
 ENDCASE
 RETURN lrEtval
ENDFUNC
*
PROCEDURE MgrPaymethod
 PARAMETER lsElect
 
   do form "Forms\MngForm" with "MngPayMethodCtrl"
   return

 PRIVATE cbUttons
 PRIVATE clEvel
 PRIVATE noLdarea, npMrec
 PRIVATE ALL LIKE l_*
 PRIVATE a_Fields
 IF (PARAMETERS()==0)
      lsElect = .F.
 ENDIF
 DIMENSION a_Fields[4, 4]
 STORE '' TO a_Fields
 a_Fields[1, 1] = "PayMetho.Pm_PayMeth"
 a_Fields[1, 2] = 15
 a_Fields[1, 3] = GetLangText("MGRFINAN","TXT_PMETHOD")
 a_Fields[2, 1] = "paymetho.pm_paynum"
 a_Fields[2, 2] = 15
 a_Fields[2, 3] = GetLangText("MGRFINAN","TXT_PMNUM")
 a_Fields[2, 4] = '99 '
 a_Fields[3, 1] = "paymetho.pm_lang"+g_Langnum
 a_Fields[3, 2] = 30
 a_Fields[3, 3] = GetLangText("MGRFINAN","TXT_PMLANG")
 a_Fields[4, 1] = 'Iif(pm_paytyp = 2 and !pm_ineuro, pm_rate, space(12))'
 a_Fields[4, 2] = 17
 a_Fields[4, 3] = GetLangText("MGRFINAN","TXT_PMRATE")
 IF paRam.pa_ineuro
      DIMENSION a_Fields[5, 4]
      a_Fields[5, 1] =  ;
              'Iif(Inlist(pm_paytyp, 1, 2) and pm_ineuro, pm_rate, space(12))'
      a_Fields[5, 2] = 17
      a_Fields[5, 3] = '1 EUR ='
      a_Fields[5, 4] = ''
 ENDIF
 clEvel = ""
 IF lsElect
      cbUttons = buTton(clEvel,GetLangText("COMMON","TXT_SELECT"),-1)
 ELSE
      cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
                 buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
                 GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
                 "TXT_DELETE"),4)+buTton(clEvel,GetLangText("MGRFINAN", ;
                 "TXT_DEPOSIT"),5)+buTton(clEvel,GetLangText("MGRFINAN", ;
                 "TB_UPDKEY"),-6)
 ENDIF
 noLdarea = SELECT()
 SELECT paYmetho
 l_Oldrec = RECNO("paymetho")
 GOTO TOP
 cmX2button = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("MGRFINAN","TXT_PMBROWSE"),15,@a_Fields,".t.",".t.", ;
   cbUttons,"vPMControl","MGRFINAN")
 gcButtonfunction = cmX2button
 neUrorate = dlOokup('Paymetho','pm_paynum = 1','pm_rate')
 SELECT paYmetho
 npMrec = RECNO()
 SCAN ALL
      IF INLIST(pm_paytyp, 1, 2) .AND. paRam.pa_ineuro .AND. paYmetho.pm_ineuro
           IF EMPTY(pm_rate)
                REPLACE pm_calcrat WITH neUrorate
           ELSE
                REPLACE pm_calcrat WITH neUrorate/pm_rate
           ENDIF
      ELSE
           IF EMPTY(pm_rate)
                REPLACE pm_calcrat WITH 1
           ELSE
                REPLACE pm_calcrat WITH pm_rate
           ENDIF
      ENDIF
 ENDSCAN
 FLUSH
 GOTO npMrec
 IF ( .NOT. lsElect)
      GOTO l_Oldrec IN "paymetho"
 ENDIF
 SELECT (noLdarea)
 RETURN
ENDPROC
*
FUNCTION vPMControl
 PARAMETER ncHoice, cwIndow
 l_Lang = "paymetho.pm_lang"+M.g_Langnum
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           DO scRpaymethod WITH "EDIT"
           g_Refreshall = UPDATED()
      CASE ncHoice==3
           DO scRpaymethod WITH "NEW"
           g_Refreshall = .T.
      CASE ncHoice==4
           if YesNo(GetLangText("MGRFINAN",  "TXT_PMDELETE") + ";" + LTrim(Str(paymetho.pm_paynum)) + " " + AllTrim(&l_lang))
                WAIT WINDOW NOWAIT GetLangText("MGRFINAN","TXT_CHKREF")+'...'
                IF  .NOT. INLIST(pm_paynum, 1, paRam.pa_currloc,  ;
                    paRam.pa_payonld, paRam.pa_rndpay, paRam.pa_posnpay)  ;
                    .AND.  .NOT. dlOokup('Post','ps_paynum = '+ ;
                    sqLcnv(pm_paynum),'Found()') .AND.  .NOT.  ;
                    dlOokup('HistPost','hp_paynum = '+sqLcnv(pm_paynum), ;
                    'Found()') .AND.  .NOT. dlOokup('RateCode', ;
                    'rc_paynum = '+sqLcnv(pm_paynum),'Found()') .AND.   ;
                    .NOT. dlOokup('LedgPaym','lp_paynum = '+ ;
                    sqLcnv(pm_paynum),'Found()') .AND.  .NOT.  ;
                    dlOokup('LedgPost','ld_paynum = '+sqLcnv(pm_paynum), ;
                    'Found()') .AND.  .NOT. dlOokup('ArPost', ;
                    'ap_paynum = '+sqLcnv(pm_paynum),'Found()') .AND.   ;
                    .NOT. dlOokup('Deposit','dp_paynum = '+ ;
                    sqLcnv(pm_paynum),'Found()')
                     WAIT CLEAR
                     DELETE
                     FLUSH
                ELSE
                     WAIT CLEAR
                     alErt(GetLangText("MGRFINAN","TXT_DELNOTPOSSIBLE"))
                ENDIF
           ENDIF
      CASE ncHoice==5
           = dePosits()
      CASE ncHoice=6
           pmNewkey(paYmetho.pm_paynum)
           g_Refreshcurr = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE PMNewKey
 LPARAMETERS pnOldkey
 PRIVATE adLg, nnEwkey
 nnEwkey = 0
 DIMENSION adLg[1, 8]
 adLg[1, 1] = "newnum"
 adLg[1, 2] = GetLangText("MGRFINAN","TXT_PMNUM")
 adLg[1, 3] = "0"
 adLg[1, 4] = "99"
 adLg[1, 5] = 3
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = 0
 IF diAlog(GetLangText("MGRFINAN","TW_NEWKEY"),'',@adLg)
      nnEwkey = adLg(1,8)
      IF dlOokup('Paymetho','pm_paynum = '+sqLcnv(nnEwkey),'Found()')
           alErt(GetLangText("MGRFINAN","TXT_KEYEXISTS"))
      ELSE
           WAIT WINDOW NOWAIT GetLangText("MGRFINAN","TXT_CHKREF")+'...'
           duPdate('PayMetho','pm_paynum = '+sqLcnv(pnOldkey),'pm_paynum', ;
                  nnEwkey)
           duPdate('Post','ps_paynum = '+sqLcnv(pnOldkey),'ps_paynum',nnEwkey)
           duPdate('HistPost','hp_paynum = '+sqLcnv(pnOldkey),'hp_paynum', ;
                  nnEwkey)
           duPdate('RateCode','rc_paynum = '+sqLcnv(pnOldkey),'rc_paynum', ;
                  nnEwkey)
           duPdate('LedgPaym','lp_paynum = '+sqLcnv(pnOldkey),'lp_paynum', ;
                  nnEwkey)
           duPdate('LedgPost','ld_paynum = '+sqLcnv(pnOldkey),'ld_paynum', ;
                  nnEwkey)
           duPdate('ArPost','ap_paynum = '+sqLcnv(pnOldkey),'ap_paynum', ;
                  nnEwkey)
           duPdate('Deposit','dp_paynum = '+sqLcnv(pnOldkey),'dp_paynum', ;
                  nnEwkey)
           duPdate('Param', ,'pa_currloc',nnEwkey)
           duPdate('Param', ,'pa_payonld',nnEwkey)
           duPdate('Param', ,'pa_rndpay',nnEwkey)
           duPdate('Param', ,'pa_posnpay',nnEwkey)
           WAIT CLEAR
      ENDIF
 ENDIF
ENDPROC
*
PROCEDURE ScrPaymethod
 PARAMETER coPtion
 PRIVATE ccHecklist, npLord, ceNabled, ntRuerate
 PRIVATE ALL LIKE l_*
 IF  _SCREEN.DV
      = doPen('ArAcct')
      SELECT paYmetho
 ENDIF
 l_Lang = "m.pm_lang"+M.g_Langnum
 l_Choice = 1
 ccHecklist = ""
 DO CASE
      CASE coPtion="NEW"
           SCATTER BLANK MEMVAR
      CASE coPtion="EDIT"
           SCATTER MEMVAR
 ENDCASE
 ntRuerate = M.pm_rate
 naRea = SELECT()
 SELECT piCklist
 npLord = ORDER()
 SET ORDER TO 3
 = SEEK("PAYTYPE", "PickList")
 DO WHILE (piCklist.pl_label="PAYTYPE" .AND.  .NOT. EOF("PickList"))
      ccHecklist = ccHecklist+IIF(EMPTY(ccHecklist), "", ";")+piCklist.pl_lang1
      SKIP 1 IN piCklist
 ENDDO
 SET ORDER TO nPlOrd
 SELECT (naRea)
 IF ( .NOT. EMPTY(paRam.pa_pmuser1+paRam.pa_pmuser2+paRam.pa_pmuser3))
      neXtra = 4.75
 ELSE
      neXtra = 0
 ENDIF
 DEFINE WINDOW wpAymethod AT 0.000, 0.000 SIZE 16.50+neXtra, 59.750 FONT  ;
        "Arial", 10 NOGROW NOFLOAT NOCLOSE TITLE  ;
        chIldtitle(GetLangText("MGRFINAN","TXT_PMWINDOW")) NOMDI SYSTEM
 MOVE WINDOW wpAymethod CENTER
 ACTIVATE WINDOW wpAymethod
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 = paNelborder()
 = txTpanel(1,2,23,GetLangText("MGRFINAN","TXT_PMNUM"),0)
 = txTpanel(2.25,2,23,GetLangText("MGRFINAN","TXT_PMLANG"),0)
 = txTpanel(3.5,2,23,GetLangText("MGRFINAN","TXT_PMTYPE"),0)
 = txTpanel(5.25,2,23,GetLangText("MGRFINAN","TXT_PMRATE"),0)
 = txTpanel(6.5,2,23,GetLangText("MGRFINAN","TXT_PMMETH"),0)
 = txTpanel(7.75,2,23,GetLangText("MGRFINAN","TXT_PMCOMM")+IIF (_SCREEN.DV,  ;
   ' / '+GetLangText("MGRFINAN","T_PMARACCT"), ''),0)
 = txTpanel(9,2,23,GetLangText("MGRFINAN","TXT_PMCOPY"),0)
 = txTpanel(10.25,2,23,GetLangText("MGRFINAN","T_DEPAARTI"),0)
 = txTpanel(11.5,2,23,GetLangText("MGRFINAN","T_AMNTPCT"),0)
 IF (neXtra>0)
      FOR nuSerfields = 1 TO 3
           cuSermacro = "Param.Pa_PmUser"+STR(nuSerfields, 1)
           If ( !Empty(&cUserMacro) )
                =TxtPanel(12.75 + (1.25 * nUserFields), 2, 23, AllTrim(&cUserMacro), 0)
           ENDIF
      ENDFOR
 ENDIF
 IF coPtion='EDIT'
      @ 1.000, 25.000 GET M.pm_paynum SIZE 1, 6 PICTURE "@KB 99" WHEN .F.  ;
        COLOR ,RGB(0,0,255,192,192,192)
 ELSE
      @ 1.000, 25.000 GET M.pm_paynum SIZE 1, 6 PICTURE "@KB 99" VALID   ;
        .NOT. dlOokup('Paymetho','pm_paynum = '+sqLcnv(M.pm_paynum),'Found()')
 ENDIF
 @  2.25,	25.00 	get 	&l_lang 					 picture "@K " + Replicate("X", 25) 	 valid LangEdit("PM_", GetLangText("MGRFINAN",  "TXT_PMWINDOW"))	 size 1, 30
 @ 3.500, 25.000 GET M.pm_paytyp DEFAULT 1 FUNCTION "^" PICTURE  ;
   ccHecklist VALID xeNable('m.pm_rate',INLIST(M.pm_paytyp, 1, 2)) .AND.  ;
   ( .NOT. paRam.pa_ineuro .OR. xeNable('m.pm_ineuro',INLIST(M.pm_paytyp,  ;
   1, 2))) .AND. xeNable('m.pm_commpct',M.pm_paytyp=3) .AND. ( .NOT.  ;
   _SCREEN.DV .OR. xeNable('m.pm_aracct',M.pm_paytyp=3))
 ceNabled = IIF(INLIST(M.pm_paytyp, 1, 2), 'ENABLED', 'DISABLED')
 @  5.25, 25.00 	get 	m.pm_rate  picture "@KB 9999999.999999"  size 1, 17  &cEnabled	
 IF paRam.pa_ineuro
      @  5.25, 44.00 get m.pm_ineuro  picture "@*C 1 EUR ="  size 1, 12  &cEnabled
 ENDIF
 @ 6.500, 25.000 GET M.pm_paymeth SIZE 1, 6 PICTURE "@K !!!!"
 ceNabled = IIF(M.pm_paytyp=3, 'ENABLED', 'DISABLED')
 @  7.75, 25.00	get		m.pm_commpct  picture "@KB 99.99"  size 1, 6  &cEnabled
 IF  _SCREEN.DV
      @  7.75, 33.00 get m.pm_aracct  picture "@KB 999999"  size 1, 8  &cEnabled  valid Lastkey() = 27 or DLocate('ArAcct', 'ac_aracct = ' + sqlCnv(m.pm_aracct))
 ENDIF
 @ 9.000, 25.000 GET M.pm_copy SIZE 1, 6 PICTURE "@KB 9"
 @ 10.250, 25.000 GET M.pm_addarti SIZE 1, 6 PICTURE "@K 9999" VALID  ;
   EMPTY(M.pm_addarti) .OR. SEEK(M.pm_addarti, "article")
 @ 11.500, 25.000 GET M.pm_addamnt SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy, 10)
 @ 11.500, 41.000 GET M.pm_addpct SIZE 1, 14 PICTURE "@K 999.99"
 @ 12.750, 25 GET M.pm_opendrw PICTURE "@*C "+GetLangText("MGRFINAN","T_OPENDRAWER")
 IF (neXtra>0)
      FOR nuSerfields = 1 TO 3
           cuSermacro = "Param.Pa_PmUser"+STR(nuSerfields, 1)
           If ( !Empty(&cUserMacro) )
                cfIeldtoget = "m.Pm_User"+STR(nuSerfields, 1)
                @ 12.75 + (1.25 * nUserFields), 25 Get &cFieldToGet Size 1, 15
           ENDIF
      ENDFOR
 ENDIF
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
   PICTURE "@*TH "+cbUttons VALID vpMchoice(coPtion)
 READ CYCLE MODAL
 RELEASE WINDOW wpAymethod
 = chIldtitle("")
 IF  _SCREEN.DV
      = dcLose('ArAcct')
 ENDIF
 RETURN
ENDPROC
*
FUNCTION vPMChoice
 PARAMETER coPtion
 PRIVATE ALL LIKE l_
 l_Retval = .F.
 DO CASE
      CASE M.l_Choice==1
           IF EMPTY(M.pm_paynum)
                = alErt(GetLangText("MGRFINAN","TXT_PMNO"))
           ELSE
                l_Retval = .T.
                DO CASE
                     CASE coPtion="NEW"
                          INSERT INTO paymetho FROM MEMVAR
                     CASE coPtion="COPY"
                          INSERT INTO paymetho FROM MEMVAR
                     CASE coPtion="EDIT"
                          SELECT paYmetho
                          GATHER MEMVAR
                ENDCASE
                CLEAR READ
           ENDIF
      CASE M.l_Choice==2
           l_Retval = .T.
           CLEAR READ
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
FUNCTION Deposits
 PRIVATE chEading
 PRIVATE nsElection
 SELECT paYmetho
 SCATTER MEMO MEMVAR
 DO WHILE (.T.)
      nsElection = 2
      = dePwindow(0,GetLangText("MGRFINAN","TXT_DEFINE_DEPOSITS")+" / "+ ;
        ALLTRIM(EVALUATE("PayMetho.Pm_Lang"+g_Langnum)))
      = txTpanel(0.5,2,38,"",26)
      M.pm_dep1whe = IIF(M.pm_dep1whe==0, 1, M.pm_dep1whe)
      M.pm_dep2whe = IIF(M.pm_dep2whe==0, 1, M.pm_dep2whe)
      @ 0.500, 3 GET M.pm_deposit FUNCTION "*C" PICTURE GetLangText("MGRFINAN", ;
        "TXT_USE_AS_DEPOSIT")
      = txTpanel(3,2,38,GetLangText("MGRFINAN","TXT_FIRSTDEPOSIT"),26)
      = txTpanel(4.25,2,27,GetLangText("MGRFINAN","TXT_DEP1PER"),24)
      @ 4.250, 28 GET M.pm_dep1per SIZE 1, 8 PICTURE "@K 999.99" VALID  ;
        M.pm_dep1per>0 WHEN M.pm_deposit ERROR GetLangText("MGRFINAN", ;
        "TXT_P1_GREATER_THAN_0")
      = txTpanel(5.5,2,27,GetLangText("MGRFINAN","TXT_DEP1DAYS"),24)
      @ 5.500, 28 GET M.pm_dep1day SIZE 1, 5 PICTURE "@K 999" VALID  ;
        M.pm_dep1day>0 ERROR GetLangText("MGRFINAN","TXT_D1_GREATER_THAN_0")
      @ 6.750, 2 GET M.pm_dep1whe FUNCTION "*R" PICTURE GetLangText("MGRFINAN", ;
        "TXT_BEFORE_ARRIVAL")+";"+GetLangText("MGRFINAN","TXT_AFTER_RESERVATION")
      = txTpanel(10,2,38,GetLangText("MGRFINAN","TXT_SECONDDEPOSIT"),26)
      = txTpanel(11.25,2,27,GetLangText("MGRFINAN","TXT_DEP1PER"),24)
      @ 11.250, 28 GET M.pm_dep2per SIZE 1, 8 PICTURE "@K 999.99" VALID  ;
        M.pm_dep2per>=0 .AND. (M.pm_dep1per+M.pm_dep2per<=100) WHEN  ;
        M.pm_deposit ERROR GetLangText("MGRFINAN","TXT_P2_GEQ_THAN_0")
      = txTpanel(12.5,2,27,GetLangText("MGRFINAN","TXT_DEP1DAYS"),24)
      @ 12.500, 28 GET M.pm_dep2day SIZE 1, 5 PICTURE "@K 999" VALID  ;
        M.pm_dep2day>0 WHEN M.pm_dep2per>0 ERROR GetLangText("MGRFINAN", ;
        "TXT_D1_GREATER_THAN_0")
      @ 13.750, 2 GET M.pm_dep2whe FUNCTION "*R" PICTURE GetLangText("MGRFINAN", ;
        "TXT_BEFORE_ARRIVAL")+";"+GetLangText("MGRFINAN", ;
        "TXT_AFTER_RESERVATION") WHEN M.pm_dep2per>0
      @ 18, 5 GET nsElection STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
        "*"+"H" PICTURE GetLangText("COMMON","TXT_OK")+";"+GetLangText("COMMON","TXT_CANCEL")
      READ MODAL
      DO CASE
           CASE nsElection==1
                SELECT paYmetho
                IF ( .NOT. M.pm_deposit)
                     M.pm_dep1whe = 0
                     M.pm_dep2whe = 0
                     M.pm_dep1per = 0
                     M.pm_dep2per = 0
                     M.pm_dep1day = 0
                     M.pm_dep2day = 0
                     GATHER MEMO MEMVAR
                     EXIT
                ELSE
                     DO CASE
                          CASE M.pm_dep1per+M.pm_dep2per>100
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_PERCENTAGES_ARE_GT_100")
                          CASE M.pm_dep1per<=0
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_P1_SHOULD_BE_GT_0")
                          CASE M.pm_dep1whe==0
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_P1_WHEN_NOT_DEF")
                          CASE M.pm_dep1day<=0
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_D1_SHOULD_BE_GT_0")
                          CASE M.pm_dep2per>0 .AND. M.pm_dep2day<=0
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_D2_SHOULD_BE_GT_0")
                          CASE M.pm_dep2per>0 .AND. M.pm_dep2whe==0
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_P2_WHEN_NOT_DEF")
                          CASE M.pm_dep1per>0 .AND. M.pm_dep2per>0 .AND.  ;
                               M.pm_dep1whe==1 .AND. M.pm_dep2whe==1  ;
                               .AND. M.pm_dep1day<=M.pm_dep2day
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_DAT2_BEFORE_DAT1")
                          CASE M.pm_dep1per>0 .AND. M.pm_dep2per>0 .AND.  ;
                               M.pm_dep1whe==2 .AND. M.pm_dep2whe==2  ;
                               .AND. M.pm_dep1day>=M.pm_dep2day
                               WAIT WINDOW NOWAIT GetLangText("MGRFINAN", ;
                                    "TXT_DAT2_BEFORE_DAT1")
                          OTHERWISE
                               IF (M.pm_dep2per==0)
                                    M.pm_dep2day = 0
                                    M.pm_dep2whe = 0
                               ENDIF
                               GATHER MEMO MEMVAR
                               EXIT
                     ENDCASE
                ENDIF
           CASE nsElection==2
                EXIT
      ENDCASE
 ENDDO
 = dePwindow(1)
 g_Refreshall = .T.
 RETURN .T.
ENDFUNC
*
FUNCTION DepWindow
 PARAMETER naCtivate, chEading
 IF (naCtivate==0)
      ON READERROR
      DEFINE WINDOW wdEposits AT 0, 0 SIZE 20, 40 FONT "Arial", 10 NOGROW  ;
             NOCLOSE NOZOOM TITLE chIldtitle(chEading) SYSTEM
      MOVE WINDOW wdEposits CENTER
      ACTIVATE WINDOW wdEposits
      = paNelborder()
 ELSE
      DEACTIVATE WINDOW wdEposits
      RELEASE WINDOW wdEposits
      = chIldtitle("")
      ON READERROR =WHATREAD()
 ENDIF
 RETURN .T.
ENDFUNC
*
PROCEDURE MgrRatecodeGroups
	do form "forms\MngForm" with "MngRateCGrCtrl"
ENDPROC
*
PROCEDURE MgrYieldMng
	do form "forms\MngForm" with "MngYieldMngGrCtrl"
ENDPROC
*
PROCEDURE MgrRatecode
    do form "forms\MngForm" with "MngRateCCtrl"
    return

 PRIVATE noLdarea
 PRIVATE cbUttons
 PRIVATE clEvel
 PRIVATE ALL LIKE l_*
 PRIVATE a_Fields
 DIMENSION a_Fields[7, 4]
 a_Fields[1, 1] = "ratecode.rc_ratecod"
 a_Fields[1, 2] = 12
 a_Fields[1, 3] = GetLangText("MGRFINAN","TXT_RCCODE")
 a_Fields[1, 4] = ""
 a_Fields[2, 1] = "ratecode.rc_lang"+g_Langnum
 a_Fields[2, 2] = 35
 a_Fields[2, 3] = GetLangText("MGRFINAN","TXT_RCLANG")
 a_Fields[2, 4] = ""
 a_Fields[3, 1] = "ratecode.rc_roomtyp"
 a_Fields[3, 2] = 10
 a_Fields[3, 3] = GetLangText("MGRFINAN","TXT_RCROOMTYP")
 a_Fields[3, 4] = ""
 a_Fields[4, 1] = "ratecode.rc_fromdat"
 a_Fields[4, 2] = siZedate()
 a_Fields[4, 3] = GetLangText("MGRFINAN","TXT_RCFROMDATE")
 a_Fields[4, 4] = ""
 a_Fields[5, 1] = "ratecode.rc_todat"
 a_Fields[5, 2] = siZedate()
 a_Fields[5, 3] = GetLangText("MGRFINAN","TXT_RCTODATE")
 a_Fields[5, 4] = ""
 a_Fields[6, 1] =  ;
         "Transform(Round(ratecode.rc_amnt1, param.pa_currdec), Right(gcCurrcyDisp, 12))"
 a_Fields[6, 2] = 12
 a_Fields[6, 3] = GetLangText("MGRFINAN","TXT_RCAMOUNT")+" 1"
 a_Fields[6, 4] = "@J"
 a_Fields[7, 1] =  ;
         "Transform(Round(ratecode.rc_amnt2, param.pa_currdec), Right(gcCurrcyDisp, 12))"
 a_Fields[7, 2] = 12
 a_Fields[7, 3] = GetLangText("MGRFINAN","TXT_RCAMOUNT")+" 2"
 a_Fields[7, 4] = "@J"
 noLdarea = SELECT()
 l_Oldrec = RECNO("ratecode")
 clEvel = "RATE"
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_COPY"),4)+buTton(clEvel,GetLangText("MGRFINAN","TXT_SPLIT"),5)+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_DELETE"),-6)
 SELECT raTecode
 GOTO TOP IN "ratecode"
 SET RELATION TO UPPER(raTecode.rc_ratecod+raTecode.rc_roomtyp)+DTOS(raTecode.rc_fromdat)+raTecode.rc_season INTO raTearti
 cmX3button = gcButtonfunction
 gcButtonfunction = ""
 DO myBrowse WITH GetLangText("MGRFINAN","TXT_RCBROWSE"), 20, a_Fields, ".t.",  ;
    ".t.", cbUttons, "vRCControl", "MGRFINAN"
 gcButtonfunction = cmX3button
 GOTO l_Oldrec IN "ratecode"
 SELECT (noLdarea)
 RETURN
ENDPROC
*
FUNCTION vRCControl
 PARAMETER ncHoice, cwIndow
 l_Lang = "ratecode.rc_lang"+M.g_Langnum
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           DO scRratecode WITH "EDIT"
           g_Refreshall = UPDATED()
      CASE ncHoice==3
           DO scRratecode WITH "NEW"
           g_Refreshall = .T.
      CASE ncHoice==4
           DO scRratecode WITH "COPY"
           g_Refreshall = .T.
      CASE ncHoice==5
           DO mgRratearticle
      CASE ncHoice==6
           if YesNo(GetLangText("MGRFINAN",  "TXT_RCDELETE") + ";" + AllTrim(&l_lang) + " " + DtoC(rc_fromdat) + "/" + DtoC(rc_todat))
                SELECT raTearti
                DELETE FOR (raTearti.ra_ratecod== ;
                       UPPER(raTecode.rc_ratecod+raTecode.rc_roomtyp)+ ;
                       DTOS(raTecode.rc_fromdat)+raTecode.rc_season)
                SELECT raTecode
                DELETE
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION ScrRatecode
 PARAMETER coPtion
 PRIVATE ALL LIKE l_*
 PRIVATE a_Split
 PRIVATE lwKndmon, lwKndtue, lwKndwed, lwKndthu, lwKndfri, lwKndsat, lwKndsun
 PRIVATE lnOtmon, lnOttue, lnOtwed, lnOtthu, lnOtfri, lnOtsat, lnOtsun
 l_Lang = "m.rc_lang"+M.g_Langnum
 l_Choice = 1
 l_Nosplit = .T.
 SELECT raTecode
 DO CASE
      CASE coPtion="NEW"
           SCATTER BLANK MEMVAR
      CASE coPtion="COPY"
           SCATTER MEMVAR
           SELECT raTearti
           IF SEEK(UPPER(raTecode.rc_ratecod+raTecode.rc_roomtyp)+ ;
              DTOS(raTecode.rc_fromdat)+raTecode.rc_season, "RateArti")
                COPY TO ARRAY a_Split FIELDS ra_ratecod, ra_artinum,  ;
                     ra_amnt, ra_multipl, ra_onlyon, ra_artityp,  ;
                     ra_ratepct WHILE raTearti.ra_ratecod= ;
                     UPPER(raTecode.rc_ratecod+raTecode.rc_roomtyp)+ ;
                     DTOS(raTecode.rc_fromdat)+raTecode.rc_season
                l_Nosplit = .F.
           ENDIF
           SELECT raTecode
      CASE coPtion="EDIT"
           SCATTER MEMVAR
 ENDCASE
 l_Childcats = lsTcount(paRam.pa_childs)
 DEFINE WINDOW wrAtecode AT 0, 0 SIZE 23.000, 124 FONT "Arial", 10 NOGROW  ;
        NOFLOAT NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("MGRFINAN", ;
        "TXT_RCWINDOW")) DOUBLE
 MOVE WINDOW wrAtecode CENTER
 ACTIVATE WINDOW wrAtecode
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 cpEriod = geTperiod()
 crHythm = geTrhythm()
 = paNelborder()
 = txTpanel(1.00,2,20,GetLangText("MGRFINAN","TXT_RCCODE"),0)
 = txTpanel(3.50,2,20,GetLangText("MGRFINAN","TXT_RCLANG"),0)
 = txTpanel(4.75,2,20,GetLangText("MGRFINAN","TXT_RCROOMTYP"),0)
 = txTpanel(6.00,2,20,GetLangText("MGRFINAN","T_FROMTO"),0)
 = txTpanel(7.25,2,20,GetLangText("MGRFINAN","T_SEASON"),0)
 = txTpanel(8.50,2,20,GetLangText("MGRFINAN","T_PERIOD"),0)
 = txTpanel(15.25,2,20,GetLangText("MGRFINAN","T_MARKET"),0)
 = txTpanel(16.50,2,20,GetLangText("MGRFINAN","T_BASE"),0)
 = txTpanel(17.75,2,20,GetLangText("MGRFINAN","T_SPECIALRATEON"),0)
 = txTpanel(19.00,2,20,GetLangText("MGRFINAN","T_CLOSEDONARRIVAL"),0)
 IF l_Childcats>0
      = txTpanel(1.50,50,72,'1 '+GetLangText("MGRFINAN","TXT_ADULT")+' / '+ ;
        GetLangText("MGRFINAN","TXT_CHILD")+' '+lsTitem(paRam.pa_childs,1),0)
 ELSE
      = txTpanel(1.50,50,72,'1 '+GetLangText("MGRFINAN","TXT_ADULT"),0)
 ENDIF
 IF l_Childcats>1
      = txTpanel(2.75,50,72,'2 '+GetLangText("MGRFINAN","TXT_ADULT")+' / '+ ;
        GetLangText("MGRFINAN","TXT_CHILD")+' '+lsTitem(paRam.pa_childs,2),0)
 ELSE
      = txTpanel(2.75,50,72,'2 '+GetLangText("MGRFINAN","TXT_ADULT"),0)
 ENDIF
 IF l_Childcats>2
      = txTpanel(4.00,50,72,'3 '+GetLangText("MGRFINAN","TXT_ADULT")+' / '+ ;
        GetLangText("MGRFINAN","TXT_CHILD")+' '+lsTitem(paRam.pa_childs,3),0)
 ELSE
      = txTpanel(4.00,50,72,'3 '+GetLangText("MGRFINAN","TXT_ADULT"),0)
 ENDIF
 = txTpanel(5.25,50,72,'4 '+GetLangText("MGRFINAN","TXT_ADULT"),0)
 = txTpanel(6.50,50,72,'5 '+GetLangText("MGRFINAN","TXT_ADULT"),0)
 = txTpanel(7.75,50,72,GetLangText("MGRFINAN","T_RHYTM"),0)
 = txTpanel(15.25,50,72,GetLangText("MGRFINAN","T_PAYNUM"),0)
 = txTpanel(15.25,80,98,GetLangText("MGRFINAN","T_MINSTAY"),0)
 @ 1, 22 GET M.rc_ratecod SIZE 1, 15 PICTURE "@K "+REPLICATE("!", 9)  ;
   VALID LASTKEY()=27 .OR.  .NOT. EMPTY(M.rc_ratecod)
 @ 2.250, 2 GET M.rc_complim FUNCTION "*C" PICTURE GetLangText("MGRFINAN", ;
   "TXT_COMPLIMENTORY")
 @ 3.5,	22 Get &l_lang 							 Picture "@K " + Replicate("X", 35) 	 Valid LangEdit("RC_", GetLangText("MGRFINAN",  "TXT_RCWINDOW"))  Size 1, 25
 @ 4.750, 22 GET M.rc_roomtyp SIZE 1, 8 PICTURE "@K !!!!" VALID  ;
   vrOomtype(@M.rc_roomtyp)
 @ 6, 22 GET M.rc_fromdat SIZE 1, siZedate() PICTURE "@KD" VALID  ;
   LASTKEY()=27 .OR.  .NOT. EMPTY(M.rc_fromdat)
 @ 6, 35 GET M.rc_todat SIZE 1, siZedate() PICTURE "@KD" VALID LASTKEY()= ;
   27 .OR. M.rc_todat>=M.rc_fromdat
 @ 7.250, 22 GET M.rc_season SIZE 1, 4 PICTURE '@K !' VALID  ;
   chKseason(M.rc_season,M.rc_fromdat,M.rc_todat)
 @ 8.500, 22 GET M.rc_period DEFAULT 3 PICTURE "@*RNV "+cpEriod
 @ 15.250, 22 GET M.rc_market SIZE 1, 6 PICTURE "@K !!!" VALID LASTKEY()= ;
   27 .OR. EMPTY(M.rc_market) .OR. piCklist("MARKET",@M.rc_market,ROW()-1, ;
   30,"C",WONTOP())
 @ 16.500, 22 GET M.rc_base SIZE 1, 14 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 lwKndmon = (SUBSTR(M.rc_weekend, 1, 1)='1')
 lwKndtue = (SUBSTR(M.rc_weekend, 2, 1)='1')
 lwKndwed = (SUBSTR(M.rc_weekend, 3, 1)='1')
 lwKndthu = (SUBSTR(M.rc_weekend, 4, 1)='1')
 lwKndfri = (SUBSTR(M.rc_weekend, 5, 1)='1')
 lwKndsat = (SUBSTR(M.rc_weekend, 6, 1)='1')
 lwKndsun = (SUBSTR(M.rc_weekend, 7, 1)='1')
 lnOtmon = (SUBSTR(M.rc_closarr, 1, 1)='1')
 lnOttue = (SUBSTR(M.rc_closarr, 2, 1)='1')
 lnOtwed = (SUBSTR(M.rc_closarr, 3, 1)='1')
 lnOtthu = (SUBSTR(M.rc_closarr, 4, 1)='1')
 lnOtfri = (SUBSTR(M.rc_closarr, 5, 1)='1')
 lnOtsat = (SUBSTR(M.rc_closarr, 6, 1)='1')
 lnOtsun = (SUBSTR(M.rc_closarr, 7, 1)='1')
 @ 17.750, 22 GET lwKndmon SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(2), 3)
 @ 17.750, 30 GET lwKndtue SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(3), 3)
 @ 17.750, 38 GET lwKndwed SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(4), 3)
 @ 17.750, 46 GET lwKndthu SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(5), 3)
 @ 17.750, 54 GET lwKndfri SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(6), 3)
 @ 17.750, 62 GET lwKndsat SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(7), 3)
 @ 17.750, 70 GET lwKndsun SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(1), 3)
 @ 19.000, 22 GET lnOtmon SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(2), 3)
 @ 19.000, 30 GET lnOttue SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(3), 3)
 @ 19.000, 38 GET lnOtwed SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(4), 3)
 @ 19.000, 46 GET lnOtthu SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(5), 3)
 @ 19.000, 54 GET lnOtfri SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(6), 3)
 @ 19.000, 62 GET lnOtsat SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(7), 3)
 @ 19.000, 70 GET lnOtsun SIZE 1, 4 PICTURE '@*C '+LEFT(myCdow(1), 3)
 @ 0.350, 74 SAY GetLangText("MGRFINAN","T_STANDARD") SIZE 1, 23 PICTURE '@I'  ;
   COLOR W+/B 
 @ 0.350, 98 SAY GetLangText("MGRFINAN","T_SPECIAL") SIZE 1, 23 PICTURE '@I'  ;
   COLOR W+/B 
 @ 1.500, 74 GET M.rc_amnt1 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 2.750, 74 GET M.rc_amnt2 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 4.000, 74 GET M.rc_amnt3 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 5.250, 74 GET M.rc_amnt4 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 6.500, 74 GET M.rc_amnt5 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 IF l_Childcats>0
      @ 1.500, 86 GET M.rc_camnt1 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 ENDIF
 IF l_Childcats>1
      @ 2.750, 86 GET M.rc_camnt2 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 ENDIF
 IF l_Childcats>2
      @ 4.000, 86 GET M.rc_camnt3 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 ENDIF
 @ 1.500, 98 GET M.rc_wamnt1 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 2.750, 98 GET M.rc_wamnt2 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 4.000, 98 GET M.rc_wamnt3 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 5.250, 98 GET M.rc_wamnt4 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 @ 6.500, 98 GET M.rc_wamnt5 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 IF l_Childcats>0
      @ 1.500, 110 GET M.rc_wcamnt1 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 ENDIF
 IF l_Childcats>1
      @ 2.750, 110 GET M.rc_wcamnt2 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 ENDIF
 IF l_Childcats>2
      @ 4.000, 110 GET M.rc_wcamnt3 SIZE 1, 11 PICTURE "@K "+RIGHT(gcCurrcy, 9)
 ENDIF
 @ 7.750, 74 GET M.rc_rhytm PICTURE "@*RNV "+crHythm
 @ 15.250, 74 GET M.rc_paynum SIZE 1, 4 PICTURE "@K 99" VALID  ;
   EMPTY(M.rc_paynum) .OR. (SEEK(M.rc_paynum, "paymetho") .AND.  ;
   paYmetho.pm_paytyp==2)
 @ 15.250, 100 GET M.rc_minstay SIZE 1, 4 PICTURE '@K 99'
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
   FUNCTION "*"+"H" PICTURE cbUttons VALID vrCchoice(coPtion)
 READ CYCLE MODAL
 RELEASE WINDOW wrAtecode
 = chIldtitle("")
 RETURN .T.
ENDFUNC
*
FUNCTION vRCChoice
 PARAMETER coPtion
 PRIVATE l_Retval, l_Recs, l_Len, l_Col, l_I
 l_Retval = .F.
 M.rc_weekend = IIF(M.lwKndmon, '1', ' ')+IIF(M.lwKndtue, '1', ' ')+ ;
                IIF(M.lwKndwed, '1', ' ')+IIF(M.lwKndthu, '1', ' ')+ ;
                IIF(M.lwKndfri, '1', ' ')+IIF(M.lwKndsat, '1', ' ')+ ;
                IIF(M.lwKndsun, '1', ' ')
 M.rc_closarr = IIF(M.lnOtmon, '1', ' ')+IIF(M.lnOttue, '1', ' ')+ ;
                IIF(M.lnOtwed, '1', ' ')+IIF(M.lnOtthu, '1', ' ')+ ;
                IIF(M.lnOtfri, '1', ' ')+IIF(M.lnOtsat, '1', ' ')+ ;
                IIF(M.lnOtsun, '1', ' ')
 DO CASE
      CASE M.l_Choice==1
           IF EMPTY(M.rc_ratecod) .OR. EMPTY(M.rc_fromdat) .OR.  ;
              EMPTY(M.rc_todat) .OR. EMPTY(M.rc_roomtyp) .OR.  .NOT.  ;
              chKseason(M.rc_season,M.rc_fromdat,M.rc_todat)
                = alErt(GetLangText("MGRFINAN","TXT_RCNO"))
           ELSE
                l_Retval = .T.
                DO CASE
                     CASE coPtion="NEW"
                          INSERT INTO ratecode FROM MEMVAR
                     CASE coPtion="COPY"
                          INSERT INTO ratecode FROM MEMVAR
                          IF  .NOT. l_Nosplit
                               l_Len = ALEN(a_Split, 1)
                               FOR l_I = 1 TO l_Len
                                    a_Split[l_I, 1] =  ;
                                     UPPER(PADR(M.rc_ratecod, 10)+ ;
                                     PADR(M.rc_roomtyp, 4))+ ;
                                     DTOS(M.rc_fromdat)+M.rc_season
                               ENDFOR
                               SELECT raTearti
                               APPEND FROM ARRAY a_Split FIELDS  ;
                                      ra_ratecod, ra_artinum, ra_amnt,  ;
                                      ra_multipl, ra_onlyon, ra_artityp,  ;
                                      ra_ratepct
                               SELECT raTecode
                          ENDIF
                     CASE coPtion="EDIT"
                          SELECT raTearti
                          REPLACE raTearti.ra_ratecod WITH M.rc_ratecod+ ;
                                  M.rc_roomtyp+DTOS(M.rc_fromdat)+ ;
                                  M.rc_season FOR raTearti.ra_ratecod= ;
                                  raTecode.rc_ratecod+raTecode.rc_roomtyp+ ;
                                  DTOS(raTecode.rc_fromdat)+raTecode.rc_season
                          SELECT raTecode
                          GATHER MEMVAR
                ENDCASE
                CLEAR READ
           ENDIF
      CASE M.l_Choice==2
           l_Retval = .T.
           CLEAR READ
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
FUNCTION MgrRateArticle
 PRIVATE noLdarea
 PRIVATE arAfields
 PRIVATE cwHileclause
 DIMENSION acMulti[7]
 acMulti[1] = GetLangText("MGRFINAN","TXT_NOTDEFINED")
 acMulti[2] = GetLangText("MGRFINAN","TXT_ADULT")
 acMulti[3] = GetLangText("MGRFINAN","TXT_PERSON")
 acMulti[4] = GetLangText("MGRFINAN","TXT_CHILD")+' '+lsTitem(paRam.pa_childs,1)
 acMulti[5] = '1x'
 acMulti[6] = GetLangText("MGRFINAN","TXT_CHILD")+' '+lsTitem(paRam.pa_childs,2)
 acMulti[7] = GetLangText("MGRFINAN","TXT_CHILD")+' '+lsTitem(paRam.pa_childs,3)
 DIMENSION acType[4]
 acType[1] = GetLangText("MGRFINAN","TXT_NOTDEFINED")
 acType[2] = GetLangText("MGRFINAN","TXT_T_MAIN")
 acType[3] = GetLangText("MGRFINAN","TXT_T_SPLIT")
 acType[4] = GetLangText("MGRFINAN","TXT_T_EXTRA")
 DIMENSION arAfields[6, 4]
 arAfields[1, 1] = "RateArti.Ra_ArtiNum"
 arAfields[1, 2] = 10
 arAfields[1, 3] = GetLangText("MGRFINAN","TH_ARTICLE")
 arAfields[1, 4] = ""
 arAfields[2, 1] = "Article.Ar_Lang"+g_Langnum
 arAfields[2, 2] = 25
 arAfields[2, 3] = GetLangText("MGRFINAN","TH_DESCRIPT")
 arAfields[2, 4] = ""
 arAfields[3, 1] =  ;
          "Iif(RateArti.ra_ratepct > 0, Transform(RateArti.ra_ratepct, '99%'), Transform(Round(RateArti.Ra_Amnt, Param.Pa_CurrDec), Right(gcCurrcyDisp, 12)))"
 arAfields[3, 2] = 12
 arAfields[3, 3] = GetLangText("MGRFINAN","TH_AMOUNT")
 arAfields[3, 4] = "@J"
 arAfields[4, 1] = "acMulti[RateArti.Ra_Multipl + 1]"
 arAfields[4, 2] = 18
 arAfields[4, 3] = GetLangText("MGRFINAN","TXT_MULTIPLICATOR")
 arAfields[4, 4] = ""
 arAfields[5, 1] = "acType[RateArti.Ra_ArtiTyp + 1]"
 arAfields[5, 2] = 12
 arAfields[5, 3] = GetLangText("MGRFINAN","TXT_TYPE")
 arAfields[5, 4] = ""
 arAfields[6, 1] = "RateArti.ra_onlyon"
 arAfields[6, 2] = 10
 arAfields[6, 3] = GetLangText("MGRFINAN","T_ONLYON")
 arAfields[6, 4] = ""
 noLdarea = SELECT()
 cwHileclause = "RateCode.rc_ratecod + RateCode.rc_roomtyp + DtoS(RateCode.rc_fromdat) + RateCode.rc_season == RateArti.ra_ratecod"
 SELECT raTearti
 SET RELATION TO raTearti.ra_artinum INTO arTicle
 clEvel = "RATE"
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),9)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),10)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_NEW"),11)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_DELETE"),-12)
 cmX4button = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("MGRFINAN","TW_RATEARTI"),10,@arAfields,".t.", ;
   cwHileclause,cbUttons,"vRAControl","MGRFINAN")
 gcButtonfunction = cmX4button
 SET RELATION TO
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION vRaControl
 PARAMETER nrAchoice
 PRIVATE clAnguagemacro
 clAnguagemacro = "Article.Ar_Lang"+g_Langnum
 DO CASE
      CASE nrAchoice==1
      CASE nrAchoice==2
           = scRratearti("EDIT")
           g_Refreshcurr = UPDATED()
      CASE nrAchoice==3
           = scRratearti("NEW")
           g_Refreshall = .T.
      CASE nrAchoice==4
           If ( YesNo(GetLangText("MGRFINAN",  "TA_DELETE") + ";" + lTrim(Str(Ra_ArtiNum)) + " " + AllTrim(&cLanguageMacro)) )
                DELETE
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION ScrRateArti
 PARAMETER coPtion
 PRIVATE ALL LIKE l_*
 PRIVATE lmAinexists, ceNable
 l_Lang = EVALUATE("article.ar_lang"+M.g_Langnum)
 l_Choice = 1
 DO CASE
      CASE coPtion="NEW"
           SCATTER BLANK MEMVAR
           M.ra_ratecod = raTecode.rc_ratecod+raTecode.rc_roomtyp+ ;
                          DTOS(raTecode.rc_fromdat)+raTecode.rc_season
           lmAinexists = dlOokup("RateArti",'ra_ratecod = '+ ;
                         sqLcnv(M.ra_ratecod),'ra_artityp = 1')
           M.ra_multipl = 1
           M.ra_rhytm = 2
           M.ra_artityp = IIF(lmAinexists, 2, 1)
           l_Lang = SPACE(25)
      CASE coPtion="EDIT"
           SCATTER MEMVAR
           lmAinexists = dlOokup("RateArti",'ra_ratecod = '+ ;
                         sqLcnv(M.ra_ratecod),'ra_artityp = 1')
 ENDCASE
 DEFINE WINDOW wrAtearti AT 0, 0 SIZE 23.750, 65 FONT "Arial", 10 NOGROW  ;
        NOFLOAT NOCLOSE TITLE chIldtitle(GetLangText("MGRFINAN","TW_RATEARTI"))  ;
        NOMDI SYSTEM
 MOVE WINDOW wrAtearti CENTER
 ACTIVATE WINDOW wrAtearti
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 = paNelborder()
 cmUltiply = geTmultiply()
 crAtype = geTratype(lmAinexists)
 = txTpanel(1,3,28,GetLangText("MGRFINAN","T_RATYPE"),23)
 = txTpanel(5.5,3,28,GetLangText("MGRFINAN","T_ARTICLE"),23)
 = txTpanel(6.75,3,28,GetLangText("MGRFINAN","T_DESCRIPT"),23)
 = txTpanel(8,3,28,GetLangText("MGRFINAN","T_AMOUNT"),23)
 = txTpanel(9.25,3,28,GetLangText("MGRFINAN","T_RATEPCT"),23)
 = txTpanel(10.50,3,28,GetLangText("MGRFINAN","T_MULTIPLY"),23)
 = txTpanel(17.25,3,28,GetLangText("MGRFINAN","T_ONLYON"),23)
 = txTpanel(18.50,3,28,GetLangText("MGRFINAN","TXT_EXTRAINFO"),23)
 ceNable = IIF(M.ra_artityp<>1, 'ENABLE', 'DISABLE')
 @  1,    30 Get m.Ra_ArtiTyp  Function "*R" + "N" + "V"  picture cRaType  &cEnable  valid XEnable('m.ra_amnt', m.ra_artityp <> 1) and  XEnable('m.ra_ratepct', m.ra_artityp <> 1) and  XEnable('m.ra_multipl', m.ra_artityp <> 1) and  XEnable('m.ra_onlyon', m.ra_artityp <> 1) and  XEnable('m.ra_exinfo', m.ra_artityp <> 1)
 @ 5.500, 30 GET M.ra_artinum SIZE 1, 6 PICTURE "@K 9999" VALID  ;
   vaRticle(5.5,25)
 @ 6.750, 30 GET l_Lang SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25) WHEN  ;
   .F. COLOR ,RGB(0,0,255,192,192,192)
 ceNable = IIF(M.ra_artityp<>1 .AND. M.ra_ratepct=0, 'ENABLE', 'DISABLE')
 @  8,    30 get m.Ra_Amnt  picture "@KB " + Right(gcCurrcy, 9) size 1, 11  &cEnable  valid XEnable('m.ra_ratepct', m.ra_amnt = 0)
 ceNable = IIF(M.ra_artityp<>1 .AND. M.ra_amnt=0, 'ENABLE', 'DISABLE')
 @  9.25, 30 get m.ra_ratepct  picture "@KB 99"  size 1, 4  &cEnable  valid XEnable('m.ra_amnt', m.ra_ratepct = 0)
 ceNable = IIF(M.ra_artityp<>1, 'ENABLE', 'DISABLE')
 @ 10.50, 30 Get m.Ra_Multipl picture "@*RNV " + cMultiply &cEnable
 @ 17.25, 30 Get m.Ra_OnlyOn  picture "@KB 999" size 1, 10 &cEnable
 @ 18.50, 30	Get m.Ra_ExInfo  picture "@K" size 1, 30 &cEnable
 l_Col = (WCOLS()-0032-1)/2
 l_Row = WROWS()-2.5
 @ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
   PICTURE "@*NH "+cbUttons VALID vrAchoice(coPtion)
 READ CYCLE MODAL
 RELEASE WINDOW wrAtearti
 = chIldtitle("")
 RETURN .T.
ENDFUNC
*
FUNCTION GetMultiply
 PRIVATE cmUltiply, ncHildcats
 ncHildcats = lsTcount(paRam.pa_childs)
 cmUltiply = buTton("",GetLangText("MGRFINAN","TXT_ADULT"),1,.T.)+buTton("", ;
             GetLangText("MGRFINAN","TXT_PERSON"),2,.T.)+buTton("", ;
             IIF(ncHildcats=0, '\\', '')+GetLangText("MGRFINAN","TXT_CHILD")+' '+ ;
             lsTitem(paRam.pa_childs,1),3,.T.)+buTton("",'1x',-4,.T.)
 IF ncHildcats>1
      cmUltiply = cmUltiply+';'+GetLangText("MGRFINAN","TXT_CHILD")+' '+ ;
                  lsTitem(paRam.pa_childs,2)
 ENDIF
 IF ncHildcats>2
      cmUltiply = cmUltiply+';'+GetLangText("MGRFINAN","TXT_CHILD")+' '+ ;
                  lsTitem(paRam.pa_childs,3)
 ENDIF
 RETURN cmUltiply
ENDFUNC
*
FUNCTION GetRaType
 LPARAMETERS plDisablemain
 PRIVATE crAtype
 crAtype = buTton("",IIF(plDisablemain, '\\', '')+GetLangText("MGRFINAN", ;
           "TXT_MAIN"),1,.T.)+buTton("",GetLangText("MGRFINAN","TXT_RASPLIT"),2, ;
           .T.)+buTton("",GetLangText("MGRFINAN","TXT_EXTRA"),-3,.T.)
 RETURN crAtype
ENDFUNC
*
FUNCTION GetPeriod
 PRIVATE cpEriod
 cpEriod = buTton("",GetLangText("MGRFINAN","TXT_HOUR"),1,.T.)+buTton("", ;
           GetLangText("MGRFINAN","TXT_DAYPART"),2,.T.)+buTton("", ;
           GetLangText("MGRFINAN","TXT_DAY"),3,.T.)+buTton("",GetLangText("MGRFINAN", ;
           "TXT_WEEK"),4,.T.)+buTton("",GetLangText("MGRFINAN","TXT_MONTH"),5, ;
           .T.)+buTton("",GetLangText("MGRFINAN","TXT_STAY"),-6,.T.)
 RETURN cpEriod
ENDFUNC
*
FUNCTION GetRhythm
 PRIVATE crHythm
 crHythm = buTton("",GetLangText("MGRFINAN","TXT_RHDAY"),1,.T.)+buTton("", ;
           GetLangText("MGRFINAN","TXT_FIRSTNIGHTATCHECKIN"),2,.T.)+buTton("", ;
           GetLangText("MGRFINAN","TXT_ATCHINSTAY"),3,.T.)+buTton("", ;
           GetLangText("MGRFINAN","TXT_ATCHOUTSTAY"),4,.T.)+buTton("", ;
           GetLangText("MGRFINAN","TXT_RHWEEK"),5,.T.)+buTton("",GetLangText("MGRFINAN", ;
           "TXT_RHMONTH"),6,.T.)+buTton("",GetLangText("MGRFINAN", ;
           "TXT_DAYVARIABLE"),-7,.T.)
 RETURN crHythm
ENDFUNC
*
FUNCTION vRAChoice
 PARAMETER coPtion
 PRIVATE l_Retval
 l_Retval = .F.
 DO CASE
      CASE M.l_Choice==1
           IF EMPTY(M.ra_artinum) .OR. (M.ra_artityp<>1 .AND.  ;
              EMPTY(M.ra_amnt) .AND. EMPTY(M.ra_ratepct))
                = alErt(GetLangText("MGRFINAN","TA_RAINVALID")+" !")
                RETURN .F.
           ELSE
                l_Retval = .T.
                DO CASE
                     CASE coPtion="NEW"
                          INSERT INTO ratearti FROM MEMVAR
                     CASE coPtion="EDIT"
                          GATHER MEMVAR
                ENDCASE
                CLEAR READ
           ENDIF
      CASE M.l_Choice==2
           l_Retval = .T.
           CLEAR READ
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
FUNCTION vArticle
 PARAMETER p_Line, p_Col
 PRIVATE noLdarea
 PRIVATE a_Field, l_Retval
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "ar_artinum"
 a_Field[1, 2] = 6
 a_Field[2, 1] = "Trim(ar_lang"+g_Langnum+")"
 a_Field[2, 2] = 20
 noLdarea = SELECT()
 l_Oldrec = RECNO("article")
 l_Retval = .F.
 SELECT arTicle
 IF EMPTY(M.ra_artinum) .OR.  .NOT. SEEK(M.ra_artinum, "article")
      GOTO TOP IN arTicle
      IF myPopup("wRateArti",p_Line+1,p_Col,5,@a_Field, ;
         "article.ar_artityp = 1",".t.")>0
           M.ra_artinum = arTicle.ar_artinum
           l_Lang = EVALUATE("article.ar_lang"+g_Langnum)
           SHOW GET l_Lang
           l_Retval = .T.
      ENDIF
 ELSE
      l_Lang = EVALUATE("article.ar_lang"+g_Langnum)
      SHOW GET l_Lang
      l_Retval = .T.
 ENDIF
 GOTO l_Oldrec IN "article"
 SELECT (noLdarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION GetRATEButtons
 PARAMETER acChecks, alChecks
 EXTERNAL ARRAY acChecks
 EXTERNAL ARRAY acChecks
 DIMENSION acChecks[18]
 DIMENSION alChecks[18]
 STORE "" TO acChecks
 STORE .F. TO alChecks
 acChecks[1] = GetLangText("COMMON","TXT_CLOSE")
 acChecks[2] = GetLangText("COMMON","TXT_EDIT")
 acChecks[3] = GetLangText("COMMON","TXT_NEW")
 acChecks[4] = GetLangText("COMMON","TXT_COPY")
 acChecks[5] = GetLangText("MGRFINAN","TXT_SPLIT")
 acChecks[6] = GetLangText("COMMON","TXT_DELETE")
 acChecks[9] = GetLangText("COMMON","TXT_CLOSE")
 acChecks[10] = GetLangText("COMMON","TXT_EDIT")
 acChecks[11] = GetLangText("COMMON","TXT_NEW")
 acChecks[12] = GetLangText("COMMON","TXT_DELETE")
 cmAcro = "Group.Gr_ButRate"
 cData  = &cMacro
 FOR ni = 1 TO 16
      alChecks[ni] = (SUBSTR(cdAta, ni, 1)=="1")
 ENDFOR
 RETURN .T.
ENDFUNC
*
FUNCTION MgrPOSArticle
 PRIVATE clEvel
 PRIVATE cbUttons
 PRIVATE noLdarea
 PRIVATE noLdrec
 PRIVATE noLdord
 PRIVATE acFields
 DIMENSION acFields[4, 4]
 PRIVATE cpOsfilter
 IF (opEnfile(.F.,"PosArti"))
      = reAdpos()
      acFields[1, 1] = "PosArti.Po_ArtiNum"
      acFields[1, 2] = 10
      acFields[1, 3] = GetLangText("MGRFINAN","TXT_ARNUM")
      acFields[1, 4] = ""
      acFields[2, 1] = "PosArti.Po_PosDesc"
      acFields[2, 2] = 30
      acFields[2, 3] = GetLangText("MGRFINAN","TXT_ARLANG")
      acFields[2, 4] = ""
      acFields[3, 1] = "PosArti.Po_BrilArt"
      acFields[3, 2] = 10
      acFields[3, 3] = GetLangText("MGRFINAN","TXT_BRILARTI")
      acFields[3, 4] = ""
      acFields[4, 1] = "Article.Ar_Lang"+g_Langnum
      acFields[4, 2] = 30
      acFields[4, 3] = GetLangText("MGRFINAN","TXT_ARLANG")
      acFields[4, 4] = ""
      clEvel = ""
      cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
                 buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
                 GetLangText("MGRFINAN","TXT_NEWONLY"),-3)
      noLdarea = SELECT()
      SELECT arTicle
      noLdrec = RECNO("Article")
      noLdord = ORDER("Article")
      SET ORDER TO 1
      SELECT poSarti
      SET RELATION TO poSarti.po_brilart INTO arTicle
      GOTO TOP
      cpOsfilter = ".t."
      cmX1button = gcButtonfunction
      gcButtonfunction = ""
      = myBrowse(GetLangText("MGRFINAN","TXT_POSARBROWSE"),20,@acFields, ;
        cpOsfilter,".t.",cbUttons,"vPosArControl","MGRFINAN")
      gcButtonfunction = cmX1button
      SET ORDER IN "Article" TO nOldOrd
      GOTO noLdrec IN "Article"
      SELECT (noLdarea)
 ENDIF
 = clOsefile("PosArti")
 RETURN .T.
ENDFUNC
*
FUNCTION vPosArControl
 PARAMETER ncHoice, cwIndow
 PRIVATE clAnguagemacro
 clAnguagemacro = "article.ar_lang"+M.g_Langnum
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           = poSarticle()
           SKIP 1
           IF (EOF())
                SKIP -1
           ENDIF
           g_Refreshall = .T.
      CASE ncHoice==3
           IF (EMPTY(FILTER()))
                SET FILTER TO EMPTY(poSarti.po_brilart)
                SHOW OBJECT 3 PROMPT GetLangText("MGRFINAN","TXT_SHOWALL")
           ELSE
                SET FILTER TO
                SHOW OBJECT 3 PROMPT GetLangText("MGRFINAN","TXT_NEWONLY")
           ENDIF
           GOTO TOP
           g_Refreshall = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION ReadPoS
 PRIVATE cfIlename
 WAIT WINDOW NOWAIT GetLangText("MGRFINAN","TXT_READING_POS_DATA")
 DO CASE
      CASE paRam.pa_postpos
           cFileName = StrTran(AllTrim(Param.Pa_PosArtD) + "\F&B\Fs_Arti_.Dbf", "\\", "\")
           IF (FILE(cfIlename))
                SELECT VAL(sa_numb) AS nuMber, sa_desc AS deSc FROM  ;
                       (cfIlename) ORDER BY nuMber INTO CURSOR Arti
                SELECT arTi
                INDEX ON STR(nuMber, 4) TAG taG1
                SET ORDER TO 1
           ENDIF
      CASE paRam.pa_argus
           cfIlename = STRTRAN(ALLTRIM(paRam.pa_posartd)+"\Artikel.Dat",  ;
                       "\\", "\")
           IF (FILE(cfIlename))
                CREATE CURSOR Arti (nuMber N (4, 0), deSc C (20))
                nhAndle = FOPEN(cfIlename)
                IF (nhAndle<>-1)
                     nrEcno = 1
                     DO WHILE ( .NOT. FEOF(nhAndle))
                          cdAta = FREAD(nhAndle, 283)
                          IF ( .NOT. EMPTY(SUBSTR(cdAta, 6, 20)))
                               SELECT arTi
                               APPEND BLANK
                               REPLACE arTi.nuMber WITH nrEcno
                               REPLACE arTi.deSc WITH SUBSTR(cdAta, 6, 20)
                          ENDIF
                          nrEcno = nrEcno+1
                     ENDDO
                     = FCLOSE(nhAndle)
                ENDIF
                SELECT arTi
                INDEX ON STR(nuMber, 4) TAG taG1
                SET ORDER TO 1
           ENDIF
 ENDCASE
 IF (SELECT("Arti")<>0)
      SELECT poSarti
      REPLACE poSarti.po_posdesc WITH GetLangText("MGRFINAN","TXT_NO_POS_ARTICLE") ALL
      SELECT arTi
      GOTO TOP
      DO WHILE ( .NOT. EOF())
           IF (arTi.nuMber>9999)
                = alErt(GetLangText("MGRFINAN","TXT_ARTICLE_NUMBER_TOO_LONG")+ ;
                  CHR(13)+CHR(10)+STR(arTi.nuMber)+" "+ALLTRIM(arTi.deSc))
           ELSE
                SELECT poSarti
                IF ( .NOT. SEEK(STR(arTi.nuMber, 4), "PosArti"))
                     APPEND BLANK
                     REPLACE poSarti.po_artinum WITH arTi.nuMber
                ENDIF
                REPLACE poSarti.po_posdesc WITH OEMTOANSI(arTi.deSc)
           ENDIF
           SELECT arTi
           SKIP 1
      ENDDO
 ENDIF
 = clOsefile("Arti")
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION PoSArticle
 = mgRarticle(.T.)
 REPLACE poSarti.po_brilart WITH arTicle.ar_artinum
 RETURN .T.
ENDFUNC
*
FUNCTION MgrPOSPayMethod
 PRIVATE clEvel
 PRIVATE cbUttons
 PRIVATE noLdarea
 PRIVATE noLdrec
 PRIVATE noLdord
 PRIVATE acFields
 DIMENSION acFields[5, 4]
 IF (opEnfile(.F.,"PosPaym"))
      = reAdpospaym()
      acFields[1, 1] = "PosPaym.Py_PayNum"
      acFields[1, 2] = 10
      acFields[1, 3] = GetLangText("MGRFINAN","TXT_PAYMETHOD")
      acFields[1, 4] = ""
      acFields[2, 1] = "PosPaym.Py_PosDesc"
      acFields[2, 2] = 30
      acFields[2, 3] = GetLangText("MGRFINAN","TXT_ARLANG")
      acFields[2, 4] = ""
      acFields[3, 1] = "PosPaym.Py_PayMeth"
      acFields[3, 2] = 10
      acFields[3, 3] = GetLangText("MGRFINAN","TXT_BRILPAY")
      acFields[3, 4] = ""
      acFields[4, 1] = "PayMetho.Pm_Lang"+g_Langnum
      acFields[4, 2] = 30
      acFields[4, 3] = GetLangText("MGRFINAN","TXT_PMLANG")
      acFields[4, 4] = ""
      acFields[5, 1] = "iIf(PosPaym.Py_Post,'"+GetLangText("MGRFINAN", ;
              "TXT_ISPOSTED")+"','"+GetLangText("MGRFINAN","TXT_ISNOTPOSTED")+"')"
      acFields[5, 2] = 30
      acFields[5, 3] = GetLangText("MGRFINAN","TXT_PMLANG")
      acFields[5, 4] = ""
      noLdarea = SELECT()
      SELECT paYmetho
      noLdrec = RECNO("PayMetho")
      noLdord = ORDER("PayMetho")
      SET ORDER TO 1
      SELECT poSpaym
      SET RELATION TO poSpaym.py_paymeth INTO paYmetho
      GOTO TOP
      clEvel = ""
      cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
                 buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
                 IIF(poSpaym.py_post, GetLangText("MGRFINAN","TXT_DONOTPOST"),  ;
                 GetLangText("MGRFINAN","TXT_DOPOST")),3)+buTton(clEvel, ;
                 GetLangText("MGRFINAN","TXT_NEWONLY"),-4)
      cmX1button = gcButtonfunction
      gcButtonfunction = "PostNoPost"
      = myBrowse(GetLangText("MGRFINAN","TXT_POSPMBROWSE"),20,@acFields,".t.", ;
        ".t.",cbUttons,"vPosPmControl","MGRFINAN")
      gcButtonfunction = cmX1button
      SET ORDER IN "PayMetho" TO nOldOrd
      GOTO noLdrec IN "PayMetho"
      SELECT (noLdarea)
 ENDIF
 = clOsefile("PosPaym")
 RETURN .T.
ENDFUNC
*
FUNCTION PostNoPost
 IF (poSpaym.py_post)
      SHOW OBJECT 3 PROMPT GetLangText("MGRFINAN","TXT_DONOTPOST")
 ELSE
      SHOW OBJECT 3 PROMPT GetLangText("MGRFINAN","TXT_DOPOST")
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION vPosPmControl
 PARAMETER ncHoice, cwIndow
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           = poSpaymethod()
           SKIP 1
           IF (EOF())
                SKIP -1
           ENDIF
           g_Refreshall = .T.
      CASE ncHoice==3
           REPLACE poSpaym.py_post WITH  .NOT. poSpaym.py_post
           g_Refreshall = UPDATED()
      CASE ncHoice==4
           IF (EMPTY(FILTER()))
                SET FILTER TO EMPTY(poSpaym.py_paymeth)
                SHOW OBJECT 4 PROMPT GetLangText("MGRFINAN","TXT_SHOWALL")
           ELSE
                SET FILTER TO
                SHOW OBJECT 4 PROMPT GetLangText("MGRFINAN","TXT_NEWONLY")
           ENDIF
           GOTO TOP
           g_Refreshall = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION ReadPoSPaym
 PRIVATE cfIlename
 WAIT WINDOW NOWAIT GetLangText("MGRFINAN","TXT_READING_POS_DATA")
 DO CASE
      CASE paRam.pa_postpos
           cfIlename = STRTRAN(ALLTRIM(paRam.pa_posartd)+ ;
                       "\BskKas\Bs_Payw_.Dbf", "\\", "\")
           IF (FILE(cfIlename))
                SELECT beT_nr AS nuMber, beT_om AS deSc FROM (cfIlename)  ;
                       ORDER BY nuMber INTO CURSOR Payw
                SELECT paYw
                INDEX ON STR(nuMber, 4) TAG taG1
                SET ORDER TO 1
           ENDIF
      CASE paRam.pa_argus
           cfIlename = STRTRAN(ALLTRIM(paRam.pa_posartd)+"\Betaling.Dat",  ;
                       "\\", "\")
           IF (FILE(cfIlename))
                CREATE CURSOR Payw (nuMber N (2, 0), deSc C (20))
                nhAndle = FOPEN(cfIlename)
                IF (nhAndle<>-1)
                     nrEcno = 1
                     DO WHILE ( .NOT. FEOF(nhAndle))
                          cdAta = FREAD(nhAndle, 115)
                          IF ( .NOT. EMPTY(SUBSTR(cdAta, 2, 20)))
                               SELECT paYw
                               APPEND BLANK
                               REPLACE paYw.nuMber WITH nrEcno
                               REPLACE paYw.deSc WITH SUBSTR(cdAta, 2, 20)
                          ENDIF
                          nrEcno = nrEcno+1
                     ENDDO
                     = FCLOSE(nhAndle)
                ENDIF
                SELECT paYw
                INDEX ON STR(nuMber, 4) TAG taG1
                SET ORDER TO 1
           ENDIF
 ENDCASE
 IF (SELECT("Payw")<>0)
      SELECT poSpaym
      REPLACE poSpaym.py_posdesc WITH GetLangText("MGRFINAN","TXT_NO_PAYM") ALL
      SELECT paYw
      GOTO TOP
      DO WHILE ( .NOT. EOF())
           IF (paYw.nuMber>99)
                = alErt(txT_paynumber_number_too_long+CHR(13)+CHR(10)+ ;
                  STR(paYw.nuMber)+" "+ALLTRIM(paYw.deSc))
           ELSE
                SELECT poSpaym
                IF ( .NOT. SEEK(STR(paYw.nuMber, 4), "PosPaym"))
                     APPEND BLANK
                     REPLACE poSpaym.py_paynum WITH paYw.nuMber
                     REPLACE poSpaym.py_post WITH .T.
                ENDIF
                REPLACE poSpaym.py_posdesc WITH paYw.deSc
           ENDIF
           SELECT paYw
           SKIP 1
      ENDDO
 ENDIF
 = clOsefile("Payw")
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION PoSPaymethod
 = mgRpaymethod(.T.)
 REPLACE poSpaym.py_paymeth WITH paYmetho.pm_paynum
 RETURN .T.
ENDFUNC
*
FUNCTION vRoomType
 PARAMETER crOomtype
 PRIVATE noLdarea
 PRIVATE a_Field, l_Retval
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 noLdarea = SELECT()
 l_Oldrec = RECNO("RoomType")
 l_Retval = .F.
 SELECT roOmtype
 DO CASE
      CASE crOomtype="*"
           l_Retval = .T.
      CASE SEEK(PADR(crOomtype, 4))
           l_Retval = .T.
      CASE  .NOT. SEEK(PADR(crOomtype, 4))
           DIMENSION a_Field[2, 2]
           a_Field[1, 1] = "rt_roomtyp"
           a_Field[1, 2] = 6
           a_Field[2, 1] = "Trim(rt_lang"+g_Langnum+")"
           a_Field[2, 2] = 20
           GOTO TOP
           IF myPopup(WONTOP(),ROW()+1,25,5,@a_Field,".t.",".t.")>0
                crOomtype = rt_roomtyp
                SHOW GETS
                l_Retval = .T.
           ENDIF
 ENDCASE
 GOTO l_Oldrec IN "RoomType"
 SELECT (noLdarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION ChkSeason
 LPARAMETERS pcSeason, pdBegin, pdEnd
 IF EMPTY(pcSeason)
      RETURN .T.
 ELSE
      RETURN  .NOT. EMPTY(dlOokup('Season','se_date >= '+sqLcnv(pdBegin)+ ;
              'and se_date < '+sqLcnv(pdEnd)+' and se_season = '+ ;
              sqLcnv(pcSeason),'se_season'))
 ENDIF
ENDFUNC
*
