*
PROCEDURE ResFix
 PARAMETER p_Reserid, p_Arrdate, p_Depdate
 PRIVATE ALL LIKE l_*
 PRIVATE a_Fields
 DIMENSION a_Fields[5, 3]
 l_Oldarea = SELECT()
 IF (opEnfile(.F.,"ResFix"))
      a_Fields[1, 1] = "ResFix.rf_artinum"
      a_Fields[1, 2] = 6
      a_Fields[1, 3] = GetLangText("RESFIX","TH_ARTINUM")
      a_Fields[2, 1] = "Article.ar_lang"+g_Langnum
      a_Fields[2, 2] = 30
      a_Fields[2, 3] = GetLangText("RESFIX","TH_LANG")
      a_Fields[3, 1] = "ResFix.rf_price"
      a_Fields[3, 2] = 10
      a_Fields[3, 3] = GetLangText("RESFIX","TH_PRICE")
      a_Fields[4, 1] = "ResFix.rf_units"
      a_Fields[4, 2] = 6
      a_Fields[4, 3] = GetLangText("RESFIX","TH_UNITS")
      a_Fields[5, 1] =  ;
              "Iif(!ResFix.rf_alldays and !Eof('ResFix'), ResFix.rf_day + m.p_ArrDate, '')"
      a_Fields[5, 2] = 12
      a_Fields[5, 3] = GetLangText("RESFIX","TH_DATE")
      clEvel = ""
      cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
                 buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
                 GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
                 "TXT_DELETE"),-4)
      SELECT reSfix
      = SEEK(p_Reserid)
      SET RELATION TO rf_artinum INTO arTicle
      cbAqbutton = gcButtonfunction
      gcButtonfunction = ""
      DO myBrowse WITH GetLangText("RESFIX","TW_RESFIX"), 10, a_Fields, ".t.",  ;
         "rf_reserid = p_ReserId", cbUttons, "vControl", "ResFix"
      gcButtonfunction = cbAqbutton
      SET RELATION TO
      = clOsefile("ResFix")
 ENDIF
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
FUNCTION vControl
 PARAMETER p_Choice
 DO CASE
      CASE p_Choice==1
      CASE p_Choice==2
           DO scRresfix WITH "EDIT", p_Reserid, p_Arrdate, p_Depdate
           g_Refreshall = UPDATED()
      CASE p_Choice==3
           DO scRresfix WITH "NEW", p_Reserid, p_Arrdate, p_Depdate
           g_Refreshall = UPDATED()
      CASE p_Choice==4
           IF yeSno(GetLangText("RESFIX","TA_DELETE")+";"+STR(rf_artinum)+" ?")
                DELETE
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE ScrResFix
 PARAMETER p_Option, p_Reserid, p_Arrdate, p_Depdate
 PRIVATE ALL LIKE l_*
 l_Choice = 1
 DO CASE
      CASE p_Option="NEW"
           SCATTER BLANK MEMO MEMVAR
           M.rf_reserid = p_Reserid
           l_Date = CTOD("")
           l_Lang = ""
      CASE p_Option="EDIT"
           SCATTER MEMO MEMVAR
           IF  .NOT. M.rf_alldays
                l_Date = p_Arrdate+M.rf_day
           ELSE
                l_Date = CTOD("")
           ENDIF
           l_Lang = EVALUATE("Article.ar_lang"+g_Langnum)
 ENDCASE
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
 DEFINE WINDOW wrEsfix AT 0.000, 0.000 SIZE 12.500, 60.000 FONT "Arial",  ;
        10 NOGROW NOFLOAT NOCLOSE TITLE chIldtitle(GetLangText("RESFIX", ;
        "TW_RESFIX")) NOMDI SYSTEM
 MOVE WINDOW wrEsfix CENTER
 ACTIVATE WINDOW wrEsfix
 DO paNel WITH 1/4, 2/3, 9.00, WCOLS()-(0.666666666666667)
 DO paNel WITH 15/16, 8/3, 33/16, 70/3, 2
 DO paNel WITH 35/16, 8/3, 53/16, 70/3, 2
 DO paNel WITH 55/16, 8/3, 73/16, 70/3, 2
 DO paNel WITH 75/16, 8/3, 93/16, 70/3, 2
 DO paNel WITH 95/16, 8/3, 113/16, 70/3, 2
 @ 1.000, 4.000 SAY GetLangText("RESFIX","T_DATE")
 @ 2.250, 4.000 SAY GetLangText("RESFIX","T_ARTINUM")
 @ 3.500, 4.000 SAY GetLangText("RESFIX","T_LANG")
 @ 4.750, 4.000 SAY GetLangText("RESFIX","T_UNITS")
 @ 6.000, 4.000 SAY GetLangText("RESFIX","T_PRICE")
 @ 1.000, 25.000 GET M.l_Date SIZE 1, siZedate() PICTURE "@K" VALID  ;
   EMPTY(l_Date) .OR. (l_Date>=p_Arrdate .AND. l_Date<p_Depdate)
 @ 2.250, 25.000 GET M.rf_artinum SIZE 1, 30 PICTURE "@K 9999" VALID  ;
   (LASTKEY()=27) .OR. vaRticle(2.25,25.00)
 @ 3.500, 25.000 GET M.l_Lang SIZE 1, 30 WHEN .F.
 @ 4.750, 25.000 GET M.rf_units SIZE 1, 30 PICTURE "@KB 9999"
 @ 6.000, 25.000 GET M.rf_price SIZE 1, 30 PICTURE "@KB "+RIGHT(gcCurrcy, 10)
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
   FUNCTION "*"+"H" PICTURE cbUttons VALID vrFchoice(p_Option,l_Date,p_Arrdate)
 READ CYCLE MODAL
 RELEASE WINDOW wrEsfix
 = chIldtitle("")
 RETURN
ENDPROC
*
FUNCTION vRFChoice
 PARAMETER p_Option, p_Date, p_Arrdate
 l_Retval = .F.
 DO CASE
      CASE M.l_Choice==1
           IF EMPTY(M.rf_artinum) .OR. EMPTY(M.rf_units)
                RETURN .F.
           ENDIF
           IF  .NOT. EMPTY(p_Date)
                M.rf_day = p_Date-p_Arrdate
                M.rf_alldays = .F.
           ELSE
                M.rf_day = 0
                M.rf_alldays = .T.
           ENDIF
           l_Retval = .T.
           DO CASE
                CASE p_Option="NEW"
                     INSERT INTO ResFix FROM MEMVAR
                CASE p_Option="EDIT"
                     GATHER MEMO MEMVAR
           ENDCASE
           CLEAR READ
      CASE M.l_Choice==2
           l_Retval = .T.
           CLEAR READ
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
FUNCTION vArticle
 PARAMETER p_Line, p_Col
 PRIVATE a_Field, l_Oldarea, l_Retval
 DIMENSION a_Field[2, 2]
 a_Field[1, 1] = "ar_artinum"
 a_Field[1, 2] = 6
 a_Field[2, 1] = "Trim(ar_lang"+g_Langnum+")"
 a_Field[2, 2] = 20
 l_Oldarea = SELECT()
 l_Oldrec = RECNO("article")
 l_Retval = .F.
 SELECT arTicle
 IF EMPTY(M.rf_artinum) .OR.  .NOT. SEEK(M.rf_artinum, "article") OR ar_inactiv
      GOTO TOP IN arTicle
      IF myPopup("wResFix",p_Line+1,p_Col,5,@a_Field, ;
         "article.ar_artityp = 1 and !ar_inactiv",'.t.')>0
           M.rf_artinum = arTicle.ar_artinum
           M.rf_price = IIF( .NOT. EMPTY(M.rf_price), M.rf_price,  ;
                        arTicle.ar_price)
           M.l_Lang = EVALUATE("Article.ar_lang"+g_Langnum)
           l_Retval = .T.
      ENDIF
 ELSE
      M.rf_price = IIF( .NOT. EMPTY(M.rf_price), M.rf_price, arTicle.ar_price)
      M.l_Lang = EVALUATE("Article.ar_lang"+g_Langnum)
      l_Retval = .T.
 ENDIF
 SHOW GET M.rf_price
 SHOW GET M.l_Lang
 GOTO l_Oldrec IN "article"
 SELECT (l_Oldarea)
 RETURN l_Retval
ENDFUNC
*
FUNCTION PostResFix
 PARAMETER p_Fordate, lp_cPostAlias, lp_cRateCode, lp_lSkipCheckRateDat
 IF PCOUNT() < 2
      lp_cPostAlias = "post"
 ENDIF
 LOCAL l_lPackage, l_lUsedResfix
 l_lPackage = NOT EMPTY(lp_cRateCode)
 PRIVATE ALL LIKE l_*
 PRIVATE ALL LIKE ps_*
 PRIVATE p_dPostDate
 IF ((NOT lp_lSkipCheckRateDat AND p_ForDate<=reservat.rs_ratedat) OR p_ForDate<=reservat.rs_rfixdat) AND NOT l_lPackage
      RETURN
 ENDIF
 p_dPostDate = p_Fordate
 LOCAL l_lAllow, l_Season, l_cError, l_RcOrd, l_nRecnoRC, l_lForeignCurrency, l_nExchangeRate
 LOCAL ARRAY l_aWin(1)
 l_Oldsel = SELECT()
 l_Arord = ORDER("Article")
 l_Arrec = RECNO("Article")
 l_Plord = ORDER("Picklist")
 l_Plrec = RECNO("Picklist")
 l_RcOrd = ORDER("Ratecode")
 l_lUsedResfix = USED("resfix")
 IF l_lUsedResfix
      l_Rford = ORDER("ResFix")
      l_Rfrec = RECNO("ResFix")
 ELSE
      OpenFileDirect(.F.,"resfix")
 ENDIF
 SELECT piCklist
 SET ORDER TO tag3
 SELECT arTicle
 SET ORDER TO tag1
 SELECT reSfix
 SET ORDER TO tag1
 IF SEEK(reServat.rs_reserid)
      l_lForeignCurrency = ResFixCheckForeginCurrency(,@l_nExchangeRate)
      SCAN FOR resfix.rf_alldays OR (reservat.rs_arrdate + resfix.rf_day = p_Fordate) ;
                WHILE resfix.rf_reserid = reservat.rs_reserid
           IF NOT EMPTY(resfix.rf_ratecod) AND (resfix.rf_package = l_lPackage)
                l_Season = dlOokup('Season','se_date = '+sqLcnv(p_Fordate),'se_season')
                l_nRecnoRC = RECNO("ratecode")
                SET ORDER TO Tag1 IN ratecode DESCENDING
                IF SEEK(resfix.rf_ratecod, "ratecode")
                     SELECT ratecode
                     LOCATE REST FOR BETWEEN(p_Fordate, rc_fromdat, rc_todat - 1) AND (l_Season = ALLTRIM(rc_season)) AND ;
                          INLIST(rc_roomtyp, "*", reservat.rs_roomtyp) WHILE rc_ratecod = resfix.rf_ratecod
                     IF FOUND()
                          DO PostRate IN RatePost WITH lp_cPostAlias, "POST_NEW", resfix.rf_units*reservat.rs_rooms, resfix.rf_price, resfix.rf_adults, ;
                               resfix.rf_childs, resfix.rf_childs2, resfix.rf_childs3, 1
                          IF NOT l_lPackage
                               REPLACE reservat.rs_rfixdat WITH p_Fordate IN reservat
                          ENDIF
                     ELSE
                          l_cError = GetLangText("RATEPOST","TA_RCNOTFOUND") + " " + ALLTRIM(resfix.rf_ratecod) + " " + ;
                               TRIM(reservat.rs_roomtyp) + " " + DTOC(p_Fordate) + " " + l_Season + "!"
                          ErrorMsg("RoomType:" + reservat.rs_roomtyp + " Room:" + reservat.rs_roomnum + " " + l_cError)
                          Alert(l_cError)
                     ENDIF
                ENDIF
                SET ORDER TO l_RcOrd IN "Ratecode" ASCENDING
                GO l_nRecnoRC IN ratecode
                SELECT resfix
           ENDIF
           IF NOT EMPTY(resfix.rf_artinum) AND (resfix.rf_package = l_lPackage) AND ;
                     SEEK(resfix.rf_artinum, "article", "tag1")
                IF g_lFakeResAndPost AND (TYPE("max1") = "D") AND (TYPE("min1") = "D") AND NOT BETWEEN(p_Fordate + article.ar_fcstofs, min1, max1)
                     LOOP
                ENDIF
                IF l_lPackage
                     GO TOP IN &lp_cPostAlias
                     m.ps_setid = &lp_cPostAlias..ps_setid
                ENDIF
                m.ps_vat0 = 0
                m.ps_vat1 = 0
                m.ps_vat2 = 0
                m.ps_vat3 = 0
                m.ps_vat4 = 0
                m.ps_vat5 = 0
                m.ps_vat6 = 0
                m.ps_vat7 = 0
                m.ps_vat8 = 0
                m.ps_vat9 = 0
                = SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat, 3), "Picklist")
                l_Vatnum = arTicle.ar_vat
                l_Vatpct = piCklist.pl_numval
                = SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat2, 3),  ;
                  "Picklist")
                l_Vatnum2 = arTicle.ar_vat2
                l_Vatpct2 = piCklist.pl_numval
                l_Id = reServat.rs_reserid
                l_Window = PBGetFreeWindow(l_Id)
                M.ps_artinum = reSfix.rf_artinum
                DO biLlinstr IN BillInst WITH M.ps_artinum,  ;
                   reServat.rs_billins, l_Id, l_Window
                IF l_Id<>reServat.rs_reserid
                     M.ps_supplem = get_rm_rmname(reServat.rs_roomnum)+" "+adDress.ad_lname
                ELSE
                     M.ps_supplem = ""
                     l_aWin(1) = l_Window
                     DO BillsReserCheck IN ProcBill WITH l_Id, l_aWin, ;
                               "POST_NEW", l_lAllow
                     IF NOT l_lAllow
                          EXIT
                     ENDIF
                ENDIF
                M.ps_units = reSfix.rf_units*reservat.rs_rooms
                M.ps_price = reSfix.rf_price*IIF(l_lForeignCurrency AND reSfix.rf_forcurr AND NOT EMPTY(l_nExchangeRate),l_nExchangeRate,1)
                M.ps_reserid = l_Id
                M.ps_window = l_Window
                M.ps_origid = reServat.rs_reserid
                M.ps_date = IIF(g_lFakeResAndPost, p_Fordate, SysDate())
                M.ps_time = TIME()
                M.ps_amount = M.ps_price*M.ps_units
                M.ps_userid = "AUTOMATIC"
                M.ps_cashier = 0
                IF (paRam.pa_exclvat)
                     l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                     &l_Vat = m.ps_amount * (l_VatPct / 100)
                     IF paRam.pa_compvat
                          l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                          &l_Vat2 = (m.ps_amount + &l_Vat) * (l_VatPct2 / 100)
                     ELSE
                          l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                          &l_Vat2 = m.ps_amount * (l_VatPct2 / 100)
                     ENDIF
                ELSE
                     l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                     &l_Vat = m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
                     l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &l_Vat2 = m.ps_amount * ( 1 - (100 / (100 + l_VatPct2)))
                ENDIF
                M.ps_split = resfix.rf_package
                M.ps_ratecod = IIF(l_lPackage, lp_cRateCode, "")
                m.ps_raid = 0
                M.ps_postid = neXtid('Post')
                M.ps_amount = ROUND(M.ps_amount,2) && ps_amount b(8,2)
                INSERT INTO &lp_cPostAlias FROM MEMVAR
                IF CURSORGETPROP("Buffering",lp_cPostAlias) == 1
                    FLUSH
                ELSE
                    = TABLEUPDATE(.F.,.T.,lp_cPostAlias)
                ENDIF
                IF arTicle.ar_stckctl
                     REPLACE arTicle.ar_stckcur WITH arTicle.ar_stckcur- ;
                             M.ps_units
                ENDIF
                IF l_lPackage
                     GO TOP IN &lp_cPostAlias
                     m.ps_amount = m.ps_amount + &lp_cPostAlias..ps_amount
                     m.ps_price = m.ps_amount / &lp_cPostAlias..ps_units
                     m.ps_vat0 = m.ps_vat0 + &lp_cPostAlias..ps_vat0
                     m.ps_vat1 = m.ps_vat1 + &lp_cPostAlias..ps_vat1
                     m.ps_vat2 = m.ps_vat2 + &lp_cPostAlias..ps_vat2
                     m.ps_vat3 = m.ps_vat3 + &lp_cPostAlias..ps_vat3
                     m.ps_vat4 = m.ps_vat4 + &lp_cPostAlias..ps_vat4
                     m.ps_vat5 = m.ps_vat5 + &lp_cPostAlias..ps_vat5
                     m.ps_vat6 = m.ps_vat6 + &lp_cPostAlias..ps_vat6
                     m.ps_vat7 = m.ps_vat7 + &lp_cPostAlias..ps_vat7
                     m.ps_vat8 = m.ps_vat8 + &lp_cPostAlias..ps_vat8
                     m.ps_vat9 = m.ps_vat9 + &lp_cPostAlias..ps_vat9
                     REPLACE ps_amount WITH m.ps_amount, ps_price WITH m.ps_price, ;
                               ps_vat0 WITH m.ps_vat0, ps_vat1 WITH m.ps_vat1, ;
                               ps_vat2 WITH m.ps_vat2, ps_vat3 WITH m.ps_vat3, ;
                               ps_vat4 WITH m.ps_vat4, ps_vat5 WITH m.ps_vat5, ;
                               ps_vat6 WITH m.ps_vat6, ps_vat7 WITH m.ps_vat7, ;
                               ps_vat8 WITH m.ps_vat8, ps_vat9 WITH m.ps_vat9 ;
                               IN &lp_cPostAlias
                ELSE
                     REPLACE reservat.rs_rfixdat WITH p_Fordate IN reservat
                ENDIF
           ENDIF
      ENDSCAN
 ENDIF
 SET ORDER IN "Article" TO l_ArOrd
 GOTO l_Arrec IN "Article"
 SET ORDER IN "Picklist" TO l_PlOrd
 GOTO l_Arrec IN "Picklist"
 IF l_lUsedResfix
     SET ORDER IN "ResFix" TO l_RfOrd
     GOTO l_Rfrec IN "ResFix"
 ELSE
     IF USED("resfix")
          USE IN resfix
     ENDIF
 ENDIF
 SELECT (l_Oldsel)
 RETURN .T.
ENDFUNC
*
FUNCTION ResFixDel
 PARAMETER p_Reserid
 PRIVATE ALL LIKE l_*
 l_Oldarea = SELECT()
 IF (opEnfile(.F.,"ResFix"))
      SELECT reSfix
      IF SEEK(p_Reserid)
           SCAN WHILE reSfix.rf_reserid=p_Reserid
                DELETE
           ENDSCAN
      ENDIF
      = clOsefile("ResFix")
 ENDIF
 SELECT (l_Oldarea)
 RETURN .T.
ENDFUNC
*
PROCEDURE ResFixSync
 PARAMETER pnFromid, pnToid
 PRIVATE arEsfix, naRea, i
 naRea = SELECT()
 IF opEnfile(.F.,"ResFix")
      SELECT reSfix
      IF SEEK(pnFromid)
           COPY TO ARRAY arEsfix FIELDS rf_reserid, rf_units, rf_price,  ;
                rf_artinum, rf_alldays, rf_day REST WHILE rf_reserid=pnFromid
           IF TYPE('aResFix[1]')='N'
                DO WHILE SEEK(pnToid)
                     DELETE
                ENDDO
                FOR i = 1 TO ALEN(arEsfix, 1)
                     arEsfix[i, 1] = pnToid
                ENDFOR
                APPEND FROM ARRAY arEsfix FIELDS rf_reserid, rf_units,  ;
                       rf_price, rf_artinum, rf_alldays, rf_day
                FLUSH
           ENDIF
      ENDIF
      = clOsefile("ResFix")
 ENDIF
 SELECT (naRea)
 RETURN
ENDPROC
*
PROCEDURE ResFixCheckForeginCurrency
LPARAMETERS lp_lForeignCurrency, lp_nExchangeRate
LOCAL l_nRCRecNo, l_nPmRate, l_lFound, l_lForeignCurrency, l_nSelect

l_lForeignCurrency = .F.

l_nSelect = SELECT()
l_nRCRecNo = RECNO("ratecode")

l_lFound = RatecodeLocate(MAX(g_sysdate, reservat.rs_arrdate), reservat.rs_ratecod, reservat.rs_roomtyp, reservat.rs_arrdate, {}, .F., .T.)

IF l_lFound AND NOT EMPTY(ratecode.rc_paynum)
     l_nPmRate = DLookUp("paymetho", "pm_paynum = "+SqlCnv(ratecode.rc_paynum,.T.), "pm_rate")
     IF NOT EMPTY(l_nPmRate)
          l_lForeignCurrency = .T.
          lp_nExchangeRate = l_nPmRate
     ENDIF
ENDIF

GO l_nRCRecNo IN ratecode
SELECT (l_nSelect)

lp_lForeignCurrency = l_lForeignCurrency

RETURN l_lForeignCurrency
ENDPROC
*