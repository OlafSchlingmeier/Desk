*
FUNCTION Rates
 PRIVATE acRcfields
 PRIVATE noLdarea
 IF  .NOT. usErpid()
      RETURN
 ENDIF
DOFORM("RATECODEPOST","forms\RateCodePost")
*DO FORM "forms\RateCodePost"
RETURN
 DIMENSION acRcfields[5, 4]
 acRcfields[1, 1] = "TmpRates.Room"
 acRcfields[1, 2] = 6
 acRcfields[1, 3] = GetLangText("RATES","TXT_ROOM")
 acRcfields[1, 4] = "!!!!"
 acRcfields[2, 1] = "TmpRates.LName"
 acRcfields[2, 2] = 40
 acRcfields[2, 3] = GetLangText("RATES","TXT_NAME")
 acRcfields[2, 4] = "@X"
 acRcfields[3, 1] = "TmpRates.RateDesc"
 acRcfields[3, 2] = 40
 acRcfields[3, 3] = GetLangText("RATES","TXT_RATECODE")
 acRcfields[3, 4] = "@X"
 acRcfields[4, 1] = "TmpRates.Adults"
 acRcfields[4, 2] = 8
 acRcfields[4, 3] = GetLangText("RATES","TXT_ADULTS")
 acRcfields[4, 4] = "999"
 acRcfields[5, 1] = "TmpRates.Amount"
 acRcfields[5, 2] = 15
 acRcfields[5, 3] = GetLangText("RATES","TXT_AMOUNT")
 acRcfields[5, 4] = "999999999.99"
 cbUttons = "\?"+buTton("",GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+buTton("", ;
            GetLangText("RATES","TXT_POST"),-2)
 noLdarea = SELECT()
 CREATE CURSOR TmpRates (roOm C (4), lnAme C (35), raTedesc C (35),  ;
        adUlts N (4, 0), amOunt N (12, 2))
 SELECT tmPrates
 GOTO TOP
 crCbutton = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("RATES","TXT_RC_POST"),10,@acRcfields,".t.",".t.", ;
   cbUttons,"vRcControl","RATES")
 gcButtonfunction = crCbutton
 = clOsefile("TmpRates")
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION vRcControl
 PARAMETER ncHoice
 PRIVATE naDults
 PRIVATE crOom, clName
 PRIVATE crAtecode, crAtedesc, naMount
 PRIVATE nsElectedbutton
 PRIVATE nrSord, nrSrec, nrCord, nrCrec
 naMount = 0
 naDults = 0
 crOom = SPACE(4)
 crAtecode = SPACE(10)
 clName = ""
 crAtedesc = ""
 nsElectedbutton = 1
 nrSord = ORDER("Reservat")
 nrSrec = RECNO("Reservat")
 nrCord = ORDER("RateCode")
 nrCrec = RECNO("RateCode")
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           DEFINE WINDOW wrAtepost FROM 0, 0 TO 10, 80 FONT "Arial", 10  ;
                  NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("RATES", ;
                  "TXT_RATEPOST")) NOMDI DOUBLE
           MOVE WINDOW wrAtepost CENTER
           ACTIVATE WINDOW NOSHOW wrAtepost
           clEvel = ""
           cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
                      buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
           = paNelborder()
           = txTpanel(1,3,20,GetLangText("RATES","TXT_ROOM"),17)
           = txTpanel(2.25,3,20,GetLangText("RATES","TXT_RATECODE"),17)
           = txTpanel(3.5,3,20,GetLangText("RATES","TXT_ADULTS"),17)
           = txTpanel(4.75,3,20,GetLangText("RATES","TXT_AMOUNT"),17)
           @ 1, 25 GET crOom SIZE 1, 6 PICTURE "@K !!!!" VALID  ;
             viSin(@crOom,@clName,@naDults)
           @ 1, 32 GET clName SIZE 1, 20 WHEN .F.
           @ 2.250, 25 GET crAtecode SIZE 1, 12 PICTURE "@K !!!!!!!!!"  ;
             VALID viSratecode(@crAtecode,@crAtedesc,@naMount) .AND.  ;
             caLcrate(naDults,@naMount)
           @ 2.250, 38 GET crAtedesc SIZE 1, 20 WHEN .F.
           @ 3.500, 25 GET naDults SIZE 1, 4 PICTURE "@K 999" VALID  ;
             caLcrate(naDults,@naMount)
           @ 4.750, 25 GET naMount SIZE 1, 12 PICTURE "@K 99999999999999999.99" VALID  ;
             (naMount*naDults>=0) .OR. LASTKEY()=27
           @ 1, 60 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15  ;
             FUNCTION "*"+"V" PICTURE cbUttons
           READ MODAL
           RELEASE WINDOW wrAtepost
           IF (nsElectedbutton==1)
                IF  .NOT. poStrate(naMount,naDults)
                     = alErt(GetLangText("RATES","TXT_NOT+POSTED"))
                ELSE
                     SELECT tmPrates
                     APPEND BLANK
                     REPLACE tmPrates.roOm WITH crOom
                     REPLACE tmPrates.lnAme WITH clName
                     REPLACE tmPrates.raTedesc WITH crAtedesc
                     REPLACE tmPrates.adUlts WITH naDults
                     REPLACE tmPrates.amOunt WITH naMount
                     GOTO TOP
                ENDIF
           ELSE
                = alErt(GetLangText("RATES","TXT_NOT+POSTED"))
           ENDIF
           g_Refreshall = .T.
 ENDCASE
 SET ORDER IN "Reservat" TO nRsOrd
 GOTO nrSrec IN "Reservat"
 SET ORDER IN "RateCode" TO nRcOrd
 GOTO nrCrec IN "RateCode"
 RETURN .T.
ENDFUNC
*
FUNCTION vIsIn
 PARAMETER crOom, clName, naDults
 PRIVATE noLdarea
 PRIVATE lrEturn
 PRIVATE acOls
 PRIVATE lfOund, nfOundrooms, nrSrec
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 lrEturn = .F.
 noLdarea = SELECT()
 SELECT reServat
 SET ORDER TO 6
 lfOund = .F.
 nfOundrooms = 0
 DO CASE
      CASE SEEK("1"+PADR(ALLTRIM(crOom), 4))
           lfOund = .T.
           nrSrec = RECNO()
           COUNT REST WHILE reServat.rs_in="1" .AND. reServat.rs_roomnum== ;
                 PADR(ALLTRIM(crOom), 4) .AND. EMPTY(reServat.rs_out) TO  ;
                 nfOundrooms
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
           clName = adDress.ad_lname
           naDults = reServat.rs_adults
           SHOW GETS
           lrEturn = .T.
      CASE lfOund .AND. nfOundrooms<>1
           DIMENSION acOls[2, 2]
           acOls[1, 1] = "Reservat.Rs_roomnum"
           acOls[1, 2] = 5
           acOls[2, 1] = "Address.Ad_lname"
           acOls[2, 2] = 25
           IF myPopup(WONTOP(),ROW()+1,25,5,@acOls,'Empty(rs_out)', ;
              'rs_in = "1"')>0
                clName = adDress.ad_lname
                crOom = reServat.rs_roomnum
                naDults = reServat.rs_adults
                SHOW GETS
                lrEturn = .T.
           ENDIF
      OTHERWISE
           = alErt(GetLangText("RATES","TA_NODATA")+"!")
 ENDCASE
 SELECT (noLdarea)
 RETURN lrEturn
ENDFUNC
*
FUNCTION vIsRateCode
 PARAMETER crAtecode, crAtedesc, naMount
 PRIVATE lrEturn
 PRIVATE noLdarea
 PRIVATE acOls, cfIlter
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 lrEturn = .F.
 noLdarea = SELECT()
 SELECT raTecode
 SET ORDER TO 1
 IF  .NOT. SEEK(PADR(crAtecode, 10)+PADR(UPPER(reServat.rs_roomtyp), 4),  ;
     "RateCode")
      = SEEK(PADR(crAtecode, 10)+"*", "RateCode")
 ENDIF
 cfIlter = '((Rc_Rhytm = 1 And Rc_Period = 3) Or (Inlist(Rc_Rhytm, 3, 4) And Rc_Period = 6)) And '+ ;
           'Rc_FromDat <= SysDate() And Rc_ToDat > SysDate() And '+ ;
           '(Rc_RoomTyp == Reservat.Rs_RoomTyp Or Rc_RoomTyp = "*")'
 Locate Rest  For &cFilter  While !Eof("RateCode") And RateCode.Rc_RateCod == PadR(cRateCode, 10)
 IF FOUND("RateCode")
      crAtedesc = EVALUATE("RateCode.Rc_Lang"+g_Langnum)
      lrEturn = .T.
      SHOW GETS
 ELSE
      DIMENSION acOls[3, 2]
      acOls[1, 1] = "RateCode.Rc_RateCod"
      acOls[1, 2] = 10
      acOls[2, 1] = "RateCode.Rc_Lang"+g_Langnum
      acOls[2, 2] = 25
      acOls[3, 1] = "RateCode.Rc_RoomTyp"
      acOls[3, 2] = 5
      GOTO TOP IN raTecode
      IF myPopup(WONTOP(),ROW()+1,25,5,@acOls,cfIlter,'.t.')>0
           crAtecode = raTecode.rc_ratecod
           crAtedesc = EVALUATE("RateCode.Rc_Lang"+g_Langnum)
           lrEturn = .T.
           SHOW GETS
      ENDIF
 ENDIF
 SELECT (noLdarea)
 RETURN lrEturn
ENDFUNC
*
FUNCTION CalcRate
 PARAMETER pnAdults, pnAmount
 PRIVATE naDults, nsIgn
 IF pnAdults<0
      nsIgn = -1
 ELSE
      nsIgn = 1
 ENDIF
 naDults = ABS(pnAdults)
 pnAmount = raTecode.rc_base
 IF naDults>0
      IF  .NOT. BETWEEN(naDults, 1, 5) .OR. EVALUATE("ratecode.rc_amnt"+ ;
          STR(naDults, 1))==0
           pnAmount = nsIgn*(pnAmount+raTecode.rc_amnt1* ;
                      IIF(paRam.pa_chkadts, MAX(naDults, 1), naDults))
      ELSE
           pnAmount = nsIgn*(pnAmount+EVALUATE("ratecode.rc_amnt"+ ;
                      STR(MAX(naDults, 1), 1)))
      ENDIF
 ENDIF
 SHOW GET M.naMount
 RETURN .T.
ENDFUNC
*
FUNCTION PostRate
 PARAMETER naMount, naDults
 PRIVATE leRror
 PRIVATE ctMpfilename, nsPlitsetid
 PRIVATE nrEsid, nfOliowin
 PRIVATE a_Struct
 coLdarea = SELECT()
 leRror = .F.
 nrEsid = 0
 nfOliowin = 0
 SELECT poSt
 = AFIELDS(a_Struct)
 CREATE CURSOR TempPost FROM ARRAY a_Struct
 ctMpfilename = DBF()
 SELECT raTearti
 IF ( .NOT. SEEK(raTecode.rc_ratecod+raTecode.rc_roomtyp+ ;
    DTOS(raTecode.rc_fromdat)+raTecode.rc_season+STR(1, 1), "RateArti"))
      ceRrortxt = GetLangText("RATES","TA_MAINNOTFOUND")+" "+ ;
                  TRIM(raTecode.rc_ratecod)+" "+TRIM(raTecode.rc_roomtyp)+ ;
                  " "+DTOC(raTecode.rc_fromdat)+"!"
      = erRormsg("RoomType:"+reServat.rs_roomtyp+" Room:"+ ;
        reServat.rs_roomnum+" "+ceRrortxt)
      = alErt(ceRrortxt)
      leRror = .T.
 ENDIF
 IF ( .NOT. leRror)
      SCAN WHILE (raTearti.ra_ratecod=raTecode.rc_ratecod+ ;
           raTecode.rc_roomtyp+DTOS(raTecode.rc_fromdat)+raTecode.rc_season)
           SELECT arTicle
           IF ( .NOT. SEEK(raTearti.ra_artinum, "Article"))
                ceRrortxt = GetLangText("RATES","TA_ARNOTFOUND")+" "+ ;
                            LTRIM(STR(raTearti.ra_artinum, 4))+"!"
                = erRormsg("RoomType:"+reServat.rs_roomtyp+" Room:"+ ;
                  reServat.rs_roomnum+" "+ceRrortxt)
                = alErt(ceRrortxt)
                leRror = .T.
                EXIT
           ENDIF
           SELECT paYmetho
           IF ( .NOT. EMPTY(raTecode.rc_paynum) .AND.  ;
              SEEK(raTecode.rc_paynum, "PayMetho"))
                l_Currencyrate = IIF(EMPTY(paYmetho.pm_rate), 1.00,  ;
                                 paYmetho.pm_rate)
           ELSE
                l_Currencyrate = 1.00
           ENDIF
           SELECT piCklist
           SET ORDER TO 3
           IF ( .NOT. SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat, 3),  ;
              "PickList"))
                ceRrortxt = GetLangText("RATES","TA_VATNOTFOUND")+" "+ ;
                            LTRIM(STR(arTicle.ar_vat))+"!"
                = erRormsg("RoomType:"+reServat.rs_roomtyp+" Room:"+ ;
                  reServat.rs_roomnum+" "+ceRrortxt)
                = alErt(ceRrortxt)
                leRror = .T.
                EXIT
           ENDIF
           l_Vatnum = arTicle.ar_vat
           l_Vatpct = piCklist.pl_numval
           IF (arTicle.ar_vat2>0)
                IF ( .NOT. SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat2,  ;
                   3), "PickList"))
                     ceRrortxt = GetLangText("RATES","TA_VATNOTFOUND")+" "+ ;
                                 LTRIM(STR(arTicle.ar_vat2))+"!"
                     = erRormsg("RoomType:"+reServat.rs_roomtyp+" Room:"+ ;
                       reServat.rs_roomnum+" "+ceRrortxt)
                     = alErt(ceRrortxt)
                     leRror = .T.
                     EXIT
                ENDIF
                l_Vatnum2 = arTicle.ar_vat2
                l_Vatpct2 = piCklist.pl_numval
           ELSE
                l_Vatnum2 = 0
                l_Vatpct2 = 0
           ENDIF
           SET ORDER IN "PickList" TO 1
           IF (raTearti.ra_artityp==1)
                l_Mvatnum = l_Vatnum
                l_Mvatpct = l_Vatpct
                l_M2vatnum = l_Vatnum2
                l_M2vatpct = l_Vatpct2
                l_Marti = raTearti.ra_artinum
           ENDIF
           SELECT teMppost
           SCATTER BLANK MEMVAR
           M.ps_artinum = raTearti.ra_artinum
           M.ps_units = naDults
           M.ps_price = IIF(raTearti.ra_artityp==1, ROUND(naMount/naDults,  ;
                        2), raTearti.ra_amnt)
           M.ps_amount = M.ps_units*M.ps_price
           M.ps_price = ROUND(M.ps_price*l_Currencyrate, paRam.pa_currdec)
           IF INLIST(raTearti.ra_artityp, 1, 3) .OR. (nrEsid=0 .AND.  ;
              nfOliowin=0)
                nrEsid = reServat.rs_reserid
                nfOliowin = 1
                DO biLlinstr IN BillInst WITH M.ps_artinum,  ;
                   reServat.rs_billins, nrEsid, nfOliowin
                IF (nrEsid<>reServat.rs_reserid)
                     M.ps_supplem = reServat.rs_roomnum+" "+adDress.ad_lname
                ENDIF
           ENDIF
           M.ps_reserid = nrEsid
           M.ps_window = nfOliowin
           M.ps_origid = reServat.rs_reserid
           M.ps_date = sySdate()
           M.ps_time = TIME()
           M.ps_userid = g_Userid
           M.ps_cashier = 0
           IF (paRam.pa_exclvat)
                l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                &l_Vat   = m.ps_amount * (l_VatPct / 100)
                IF paRam.pa_compvat
                     l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &l_Vat2 = (m.ps_amount + &l_Vat) * (l_VatPct2 / 100)						
                ELSE
                     l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &l_Vat2 = m.ps_amount * (l_VatPct2 / 100)
                ENDIF
           ELSE
                l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                &l_Vat   = m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
                l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                &l_Vat2  = m.ps_amount * ( 1 - (100 / (100 + l_VatPct2)))
           ENDIF
           M.ps_split = (raTearti.ra_artityp==2)
           M.ps_ratecod = IIF(raTearti.ra_artityp==3, "", raTearti.ra_ratecod)
           IF M.ps_amount<>0.00
                M.ps_postid = neXtid('Post')
                INSERT INTO TempPost FROM MEMVAR
           ENDIF
           SELECT raTearti
      ENDSCAN
      SELECT teMppost
      IF RECCOUNT()>0
           SUM ps_amount TO l_Amount ALL FOR teMppost.ps_split
           GOTO TOP IN "temppost"
           SCATTER MEMVAR
           M.ps_price = ROUND((M.ps_amount-l_Amount)/naDults, 2)
           M.ps_units = naDults
           M.ps_amount = M.ps_amount-l_Amount
           M.ps_split = .T.
           IF (paRam.pa_exclvat)
                l_Vat = "m.ps_vat"+LTRIM(STR(l_Mvatnum))
                &l_Vat  = m.ps_amount * (l_MVatPct / 100)
                l_Vat2 = "m.ps_vat"+LTRIM(STR(l_M2vatnum))
                &l_Vat2 = m.ps_amount * (l_M2VatPct / 100)
           ELSE
                l_Vat = "m.ps_vat"+LTRIM(STR(l_Mvatnum))
                &l_Vat  = m.ps_amount * ( 1 - (100 / (100 + l_MVatPct)))
                l_Vat2 = "m.ps_vat"+LTRIM(STR(l_M2vatnum))
                &l_Vat2 = m.ps_amount * ( 1 - (100 / (100 + l_M2VatPct)))
           ENDIF
           M.ps_postid = neXtid('Post')
           INSERT INTO TempPost FROM MEMVAR
           SELECT teMppost
           SUM ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5,  ;
               ps_vat6, ps_vat7, ps_vat8, ps_vat9 TO l_Vat0, l_Vat1,  ;
               l_Vat2, l_Vat3, l_Vat4, l_Vat5, l_Vat6, l_Vat7, l_Vat8,  ;
               l_Vat9 ALL FOR teMppost.ps_split
           GOTO TOP IN "temppost"
           SCATTER MEMVAR FIELDS ps_vat0, ps_vat1, ps_vat2, ps_vat3,  ;
                   ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9
           M.ps_vat0 = l_Vat0
           M.ps_vat1 = l_Vat1
           M.ps_vat2 = l_Vat2
           M.ps_vat3 = l_Vat3
           M.ps_vat4 = l_Vat4
           M.ps_vat5 = l_Vat5
           M.ps_vat6 = l_Vat6
           M.ps_vat7 = l_Vat7
           M.ps_vat8 = l_Vat8
           M.ps_vat9 = l_Vat9
           GATHER MEMVAR FIELDS ps_vat0, ps_vat1, ps_vat2, ps_vat3,  ;
                  ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9
           GOTO TOP IN "temppost"
      ENDIF
 ENDIF
 IF  .NOT. leRror .AND. RECCOUNT("temppost")>0
      nsPlitsetid = neXtid('SPLITSET')
      SELECT teMppost
      REPLACE ps_setid WITH nsPlitsetid ALL FOR  .NOT. EMPTY(ps_ratecod)
      SELECT poSt
      APPEND FROM (ctMpfilename)
      FLUSH
 ENDIF
 = clOsefile("TempPost")
 SELECT (coLdarea)
 RETURN  .NOT. leRror
ENDFUNC
*
FUNCTION PostMultiply
 PARAMETER naDults
 PRIVATE ALL LIKE l_*
 IF naDults<0
      l_Sign = -1
 ELSE
      l_Sign = 1
 ENDIF
 l_Retval = l_Sign*1
 DO CASE
      CASE raTearti.ra_multipl==1
           l_Retval = naDults
      CASE raTearti.ra_multipl==2
           l_Retval = naDults
      CASE raTearti.ra_multipl==3
      CASE raTearti.ra_multipl==4
      CASE raTearti.ra_multipl==5
      CASE raTearti.ra_multipl==6
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
