PROCEDURE Invoice
LPARAMETERS lp_cPostCursor
 IF PCOUNT() == 0
	lp_cPostCursor = "InvPost"
 ENDIF
 LOCAL l_lCloseRateperi, l_oReservat, l_lResFixOpen, l_lCloseResFix
 l_lResFixOpen = USED("resfix")
 IF NOT l_lResFixOpen AND OpenFile(.F.,"resfix",.F.,.T.)
	l_lResFixOpen = .T.
	l_lCloseResFix = .T.
 ENDIF
 SELECT reservat
 SCATTER NAME l_oReservat
 LOCAL ARRAY l_aPost(1)
 = AFIELDS(l_aPost, "post")
 DO CursorAddField IN ProcBill WITH l_aPost, 'PS_INVTYPE', 'C', 1, 0
 DO CursorAddField IN ProcBill WITH l_aPost, 'PS_INVDATE', 'D', 8, 0
 CREATE CURSOR &lp_cPostCursor FROM ARRAY l_aPost

 BLANK FIELDS rs_ratedat, rs_rfixdat, rs_ratein, rs_rateout IN reservat
 = InvRateCodePost(reservat.rs_arrdate, "CHECKIN", lp_cPostCursor)
 LOCAL l_dFor, l_oReservat1
 l_dFor = reservat.rs_arrdate
 SCATTER NAME l_oReservat1
 DO WHILE l_dFor <= reservat.rs_depdate - 1
	IF l_lResFixOpen
		= InvPostResFix(l_dFor, lp_cPostCursor)
	ENDIF
    IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(l_dFor),"resrooms","tag2")
         IF (reservat.rs_roomtyp <> resrooms.ri_roomtyp) OR ;
            (reservat.rs_roomnum <> resrooms.ri_roomnum) OR ;
            (reservat.rs_adults <> resrooms.ri_adults) OR ;
            (reservat.rs_childs <> resrooms.ri_childs) OR ;
            (reservat.rs_childs2 <> resrooms.ri_childs2) OR ;
            (reservat.rs_childs3 <> resrooms.ri_childs3)
               l_oReservat1.rs_roomtyp = resrooms.ri_roomtyp
               l_oReservat1.rs_roomnum = resrooms.ri_roomnum
               l_oReservat1.rs_adults = resrooms.ri_adults
               l_oReservat1.rs_childs = resrooms.ri_childs
               l_oReservat1.rs_childs2 = resrooms.ri_childs2
               l_oReservat1.rs_childs3 = resrooms.ri_childs3
         ENDIF
    ENDIF
    IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(l_dFor),"resrate","tag2") AND NOT EMPTY(resrate.rr_ratecod)
         l_cRatecod = LEFT(resrate.rr_ratecod,10)
         IF INLIST(resrate.rr_status, "OUS", "ORU")
              l_cRatecod = "*" + l_cRatecod
         ELSE
              IF INLIST(resrate.rr_status, "OAL", "ORA")
                   l_cRatecod = "!" + l_cRatecod
              ENDIF
         ENDIF
         DO RrDayPrice IN ProcResrate WITH l_oReservat1, param.pa_sysdate+1, l_nPrice
         IF (reservat.rs_ratecod <> l_cRatecod) OR (reservat.rs_rate <> l_nPrice)
              l_oReservat1.rs_ratecod = l_cRatecod
              l_oReservat1.rs_rate = l_nPrice
         ENDIF
    ENDIF
    GATHER NAME l_oReservat1 FIELDS rs_roomtyp, rs_roomnum, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_ratecod, rs_rate
	InvRateCodePost(l_dFor, "", lp_cPostCursor)
	l_dFor = l_dFor+1
 ENDDO
 = InvRateCodePost(reservat.rs_depdate, "CHECKOUT", lp_cPostCursor)

 SELECT reservat
 GATHER NAME l_oReservat
 IF l_lResFixOpen AND l_lCloseResFix
	= CloseFile("resfix")
 ENDIF
 FLUSH
 RETURN lp_cPostCursor
ENDPROC
*
FUNCTION InvRateCodePost
 PARAMETER dfOrdate, ctYpe, lp_cPostAlias
 PRIVATE ncUrrentarea
 PRIVATE ndOwcurrent, ndOwarrival, caDfld, ccHfld
 PRIVATE ALL LIKE l_*
 ncUrrentarea = SELECT()
 l_Arrival = reServat.rs_arrdate
 l_Departure = reServat.rs_depdate
 l_Roomtype = reServat.rs_roomtyp
 l_Ratecode = STRTRAN(STRTRAN(reServat.rs_ratecod, "*"), "!")
 l_Adults = reServat.rs_adults
 l_Children = reServat.rs_childs
 l_Children2 = reServat.rs_childs2
 l_Children3 = reServat.rs_childs3
 l_Firsttime = .T.
 IF ( .NOT. EMPTY(reServat.rs_ratecod) .AND. (( .NOT. reServat.rs_ratein  ;
    .AND. ctYpe="CHECKIN" .AND. reServat.rs_arrdate=dForDate) .OR. (  ;
    .NOT. reServat.rs_rateout .AND. ctYpe="CHECKOUT" .AND.  ;
    reServat.rs_depdate=dForDate) .OR. (reServat.rs_ratedat<dfOrdate  ;
    .AND. EMPTY(ctYpe))))
      l_Date = MAX(reServat.rs_arrdate, reServat.rs_ratedat+1)
      l_End = dfOrdate
      DO WHILE (l_Date<=l_End)
           l_Rate = reservat.rs_rate
           l_fFound = .F.
           IF (LEFT(reservat.rs_ratecod,1) = "!") && changed ratecode in allotments
              IF SEEK(reservat.rs_altid,"althead","tag1")
           		IF SEEK(PADR(althead.al_altid,8)+DTOS(l_Arrival)+reservat.rs_roomtyp+l_Ratecode,"altsplit","tag2") OR ;
                        SEEK(PADR(althead.al_altid,8)+DTOS(l_Arrival)+"*   "+l_Ratecode,"altsplit","tag2")
           			l_fFound = .T.
           		ENDIF
              ENDIF
           ENDIF
           l_Season = dlOokup('Season','se_date = '+sqLcnv(l_Date),'se_season')
           = SEEK(PADR(l_Ratecode, 10)+l_Roomtype, "RateCode")
           IF NOT l_fFound
               SELECT raTecode
               LOCATE REST FOR raTecode.rc_fromdat<=l_Date .AND.  ;
                      raTecode.rc_todat>l_Date .AND. (EMPTY(rc_season) .OR.  ;
                      rc_season=l_Season) WHILE raTecode.rc_ratecod=l_Ratecode
               l_fFound = FOUND("RateCode")
           ENDIF
           IF ( .NOT. FOUND("RateCode"))
                = SEEK(PADR(l_Ratecode, 10)+"*", "RateCode")
               IF NOT l_fFound
                    LOCATE REST FOR raTecode.rc_fromdat<=l_Date .AND.  ;
                           raTecode.rc_todat>l_Date .AND. (EMPTY(rc_season)  ;
                           .OR. rc_season=l_Season) WHILE raTecode.rc_ratecod= ;
                           l_Ratecode
               ENDIF
               l_fFound = FOUND("RateCode")
           ENDIF
           IF NOT l_fFound
                ceRrortxt = GetLangText("RATEPOST","TA_RCNOTFOUND")+" "+ ;
                            ALLTRIM(l_Ratecode)+" "+TRIM(l_Roomtype)+" "+ ;
                            DTOC(l_Date)+" "+l_Season+"!"
                = erRormsg("RoomType:"+l_Roomtype+" Room:"+ ;
                  reServat.rs_roomnum+" "+ceRrortxt)
                EXIT
           ELSE
                DO CASE
                     CASE raTecode.rc_rhytm==3 .AND. ctYpe="CHECKIN"
                          l_End = reServat.rs_depdate-1
                          = InvPostResFix(l_Date, lp_cPostAlias)
                     CASE raTecode.rc_rhytm==4 .AND. ctYpe="CHECKOUT"  ;
                          .AND. l_Firsttime
                          l_Date = reServat.rs_arrdate
                          l_End = reServat.rs_depdate-1
                          l_Firsttime = .F.
                          LOOP
                ENDCASE
                IF NOT ("*" $ reservat.rs_ratecod) AND NOT ("!" $ reservat.rs_ratecod) AND NOT ;
                                ((raTecode.rc_rhytm=7) AND (l_Date>reServat.rs_arrdate))
                     l_Rate = raTecode.rc_base
                     ndOwcurrent = DOW(l_Date, 2)
                     ndOwarrival = DOW(reServat.rs_arrdate, 2)
                     IF SUBSTR(raTecode.rc_weekend, ndOwcurrent, 1)='1'  ;
                        .AND. SUBSTR(raTecode.rc_closarr, ndOwarrival, 1)=' '
                          caDfld = 'RateCode.rc_wamnt'
                          ccHfld = 'RateCode.rc_wcamnt'
                     ELSE
                          caDfld = 'RateCode.rc_amnt'
                          ccHfld = 'RateCode.rc_camnt'
                     ENDIF
                     IF ( .NOT. BETWEEN(l_Adults, 1, 5) .OR.  ;
                        EVALUATE(caDfld+STR(l_Adults, 1))==0)
                          l_Rate = l_Rate+EVALUATE(caDfld+'1')*MAX(l_Adults, 1)
                     ELSE
                          l_Rate = l_Rate+EVALUATE(caDfld+ ;
                                   STR(MAX(l_Adults, 1), 1))
                     ENDIF
                     IF l_Children>0
                          l_Rate = l_Rate+EVALUATE(ccHfld+'1')*l_Children
                     ENDIF
                     IF l_Children2>0
                          l_Rate = l_Rate+EVALUATE(ccHfld+'2')*l_Children2
                     ENDIF
                     IF l_Children3>0
                          l_Rate = l_Rate+EVALUATE(ccHfld+'3')*l_Children3
                     ENDIF
                     DO CASE
                          CASE raTecode.rc_period==1
                               l_Periods = hoUrs(reServat.rs_arrtime, ;
                                reServat.rs_deptime,reServat.rs_arrdate, ;
                                reServat.rs_depdate)
                               l_Rate = l_Rate*l_Periods
                          CASE raTecode.rc_period==2
                               l_Periods = daYparts(reServat.rs_arrtime, ;
                                reServat.rs_deptime,reServat.rs_arrdate, ;
                                reServat.rs_depdate)
                               l_Rate = l_Rate*l_Periods
                     ENDCASE
                     REPLACE reServat.rs_rate WITH l_Rate
                ENDIF
           ENDIF
           = InvPostRate(l_Date,ctYpe, lp_cPostAlias)
           l_Date = l_Date+1
      ENDDO
      WAIT CLEAR
 ENDIF
 SELECT (ncUrrentarea)
 RETURN .T.
ENDFUNC
*
PROCEDURE InvPostRate
 PARAMETER dfOrdate, ctYpe, lp_cPostAlias
 PRIVATE leRror
 PRIVATE ctMpfilename, nsPlitsetid
 PRIVATE nrEsid, nfOliowin, p_dPostDate
 PRIVATE a_Struct
 coLdarea = SELECT()
 leRror = .F.
 nrEsid = 0
 nfOliowin = 0
 l_Mvatnum = 0
 l_Mvatpct = 0
 l_M2vatnum = 0
 l_M2vatpct = 0
 l_M2VatTyp2 = ""
 l_Marti = 0
 SELECT(lp_cPostAlias)
 = AFIELDS(a_Struct)
 CREATE CURSOR TempPost FROM ARRAY a_Struct
 ctMpfilename = DBF()
 SELECT raTearti
 IF ( .NOT. SEEK(raTecode.rc_ratecod+raTecode.rc_roomtyp+ ;
    DTOS(raTecode.rc_fromdat)+raTecode.rc_season+STR(1, 1), "RateArti"))
      ceRrortxt = GetLangText("RATEPOST","TA_MAINNOTFOUND")+" "+ ;
                  TRIM(raTecode.rc_ratecod)+" "+TRIM(raTecode.rc_roomtyp)+ ;
                  " "+DTOC(raTecode.rc_fromdat)+"!"
      = erRormsg("RoomType:"+l_Roomtype+" Room:"+reServat.rs_roomnum+" "+ ;
        ceRrortxt)
      leRror = .T.
 ENDIF
 IF ( .NOT. leRror)
      SCAN WHILE (raTearti.ra_ratecod=raTecode.rc_ratecod+ ;
           raTecode.rc_roomtyp+DTOS(raTecode.rc_fromdat)+raTecode.rc_season)
           IF (poStyesno(dfOrdate,ctYpe))
                SELECT arTicle
                IF ( .NOT. SEEK(raTearti.ra_artinum, "Article"))
                     ceRrortxt = GetLangText("RATEPOST","TA_ARNOTFOUND")+" "+ ;
                                 LTRIM(STR(raTearti.ra_artinum, 4))+"!"
                     = erRormsg("RoomType:"+l_Roomtype+" Room:"+ ;
                       reServat.rs_roomnum+" "+ceRrortxt)
                     leRror = .T.
                     EXIT
                ENDIF
                IF g_lFakeResAndPost AND (TYPE("max1") = "D") AND (TYPE("min1") = "D") AND NOT BETWEEN(dfOrdate + article.ar_fcstofs, min1, max1)
                    LOOP
                ENDIF
                SELECT paYmetho
                IF ( .NOT. EMPTY(raTecode.rc_paynum) .AND.  ;
                   SEEK(raTecode.rc_paynum, "PayMetho"))
                     IF EMPTY(reServat.rs_ratexch)
                          l_Currencyrate = IIF(EMPTY(paYmetho.pm_rate),  ;
                           1.00, paYmetho.pm_rate)
                          REPLACE rs_ratexch WITH l_Currencyrate IN reServat
                     ELSE
                          l_Currencyrate = reServat.rs_ratexch
                     ENDIF
                ELSE
                     l_Currencyrate = 1.00
                ENDIF
                SELECT piCklist
                SET ORDER TO 3
                IF ( .NOT. SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat,  ;
                   3), "PickList"))
                     ceRrortxt = GetLangText("RATEPOST","TA_VATNOTFOUND")+" "+ ;
                                 LTRIM(STR(arTicle.ar_vat))+"!"
                     = erRormsg("RoomType:"+l_Roomtype+" Room:"+ ;
                       reServat.rs_roomnum+" "+ceRrortxt)
                     leRror = .T.
                     EXIT
                ENDIF
                l_Vatnum = arTicle.ar_vat
                l_Vatpct = piCklist.pl_numval
                IF (arTicle.ar_vat2>0)
                     IF ( .NOT. SEEK(PADR("VATGROUP", 10)+ ;
                        STR(arTicle.ar_vat2, 3), "PickList"))
                          ceRrortxt = GetLangText("RATEPOST","TA_VATNOTFOUND")+ ;
                                      " "+LTRIM(STR(arTicle.ar_vat2))+"!"
                          = erRormsg("RoomType:"+l_Roomtype+" Room:"+ ;
                            reServat.rs_roomnum+" "+ceRrortxt)
                          leRror = .T.
                          EXIT
                     ENDIF
                     l_Vatnum2 = arTicle.ar_vat2
                     l_Vatpct2 = piCklist.pl_numval
                     l_VatTyp2 = picklist.pl_user2
                ELSE
                     l_Vatnum2 = 0
                     l_Vatpct2 = 0
                     l_VatTyp2 = ""
                ENDIF
                SET ORDER IN "PickList" TO 1
                IF (raTearti.ra_artityp==1)
                     l_Mvatnum = l_Vatnum
                     l_Mvatpct = l_Vatpct
                     l_M2vatnum = l_Vatnum2
                     l_M2vatpct = l_Vatpct2
                     l_M2VatTyp2 = picklist.pl_user2
                     l_Marti = raTearti.ra_artinum
                ENDIF
                SELECT teMppost
                SCATTER BLANK MEMVAR
                M.ps_artinum = raTearti.ra_artinum
                IF raTearti.ra_artityp==1
                     M.ps_units = 1
                     IF raTecode.rc_rhytm==7
                          IF reServat.rs_depdate-reServat.rs_arrdate>=2  ;
                             .AND. dfOrdate=reServat.rs_depdate-1
                               M.ps_price = reServat.rs_rate-(dfOrdate- ;
                                reServat.rs_arrdate)* ;
                                ROUND(reServat.rs_rate/ ;
                                MAX(reServat.rs_depdate- ;
                                reServat.rs_arrdate, 1), 2)
                          ELSE
                               M.ps_price = ROUND(reServat.rs_rate/ ;
                                MAX(reServat.rs_depdate- ;
                                reServat.rs_arrdate, 1), 2)
                          ENDIF
                     ELSE
                          M.ps_price = reServat.rs_rate
                     ENDIF
                ELSE
                     M.ps_units = poStmultiply()
                     IF EMPTY(raTearti.ra_amnt) .AND.  .NOT.  ;
                        EMPTY(raTearti.ra_ratepct)
                          M.ps_price = ROUND(raTearti.ra_ratepct* ;
                                       reServat.rs_rate/100, paRam.pa_currdec)
                     ELSE
                          M.ps_price = raTearti.ra_amnt
                     ENDIF
                ENDIF
                IF raTecode.rc_period=4 .AND. raTecode.rc_rhytm=1
                     IF raTearti.ra_artityp=1
                          M.ps_price = ROUND(M.ps_price* ;
                                       weEks(reServat.rs_arrdate, ;
                                       reServat.rs_depdate)/ ;
                                       (reServat.rs_depdate- ;
                                       reServat.rs_arrdate), 2)
                     ENDIF
                ENDIF
                IF raTecode.rc_period=5 .AND. raTecode.rc_rhytm=1
                     M.ps_price = ROUND(M.ps_price/laStday(dfOrdate), 2)
                ENDIF
                M.ps_price = ROUND(M.ps_price*l_Currencyrate, paRam.pa_currdec)
                IF  .NOT. EMPTY(reServat.rs_discnt)
                     l_Discpct = dlOokup('PickList', ;
                                 'pl_label=[DISCOUNT] and pl_charcod = '+ ;
                                 sqLcnv(reServat.rs_discnt),'pl_numval')
                     IF l_Discpct>0 .AND. l_Discpct<=100
                          M.ps_price = M.ps_price-M.ps_price*l_Discpct/100
                     ENDIF
                ENDIF
                IF INLIST(raTearti.ra_artityp, 1, 3) .OR. (nrEsid=0 .AND.  ;
                   nfOliowin=0)
                     nrEsid = reServat.rs_reserid
                     nfOliowin = 1
                     p_dPostDate = dfOrdate
                     DO biLlinstr IN BillInst WITH M.ps_artinum,  ;
                        reServat.rs_billins, nrEsid, nfOliowin, .T.
                     p_dPostDate = {}
                     IF (nrEsid<>reServat.rs_reserid)
                          M.ps_supplem = get_rm_rmname(reServat.rs_roomnum)+" "+ ;
                           adDress.ad_lname
                     ENDIF
                ENDIF
                IF (ratearti.ra_artityp == 2) .AND. (ratearti.ra_amnt < 0)
                    M.ps_units = - M.ps_units
                    M.ps_price = - M.ps_price
                ENDIF
                M.ps_reserid = nrEsid
                M.ps_window = nfOliowin
                M.ps_origid = reServat.rs_reserid
                M.ps_date = sySdate()
                M.ps_invdate = dfOrdate
                IF (sySdate()<>dfOrdate)
                     M.ps_supplem = DTOC(dfOrdate)+" "+M.ps_supplem
                ENDIF
                M.ps_time = TIME()
                M.ps_amount = M.ps_price*M.ps_units
                M.ps_userid = "AUTOMATIC"
                M.ps_cashier = 0
				LOCAL l_cVatMacro1, l_cVatMacro2
				l_cVatMacro1 = "m.ps_vat"+LTRIM(STR(l_Vatnum))
				l_cVatMacro2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
				IF param.pa_exclvat
					IF UPPER(ALLTRIM(l_VatTyp2)) <> "PP"
						&l_cVatMacro1 = m.ps_amount * (l_VatPct / 100)
						IF UPPER(ALLTRIM(l_VatTyp2)) <> "BT"
							IF paRam.pa_compvat
								&l_cVatMacro2 = (m.ps_amount + &l_cVatMacro1) * (l_VatPct2 / 100)					
							ELSE
								&l_cVatMacro2 = m.ps_amount * (l_VatPct2 / 100)
							ENDIF
						ELSE
							&l_cVatMacro2 = l_VatPct2
						ENDIF
					ELSE
						LOCAL l_nPurchasePrice
						l_nPurchasePrice = DbLookup("article","tag1",m.ps_artinum,"ar_pprice")
						IF (m.ps_amount-l_nPurchasePrice) > 0
							&l_cVatMacro2 = (m.ps_amount-l_nPurchasePrice) * (l_VatPct2 / (100-l_VatPct2))
						ENDIF
						&l_cVatMacro1 = (m.ps_amount+&l_cVatMacro2) * (l_VatPct / 100)
					ENDIF
				ELSE
					&l_cVatMacro1 = m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
					DO CASE
					 CASE UPPER(ALLTRIM(l_VatTyp2)) == "PP"
						LOCAL l_nPurchasePrice
						l_nPurchasePrice = DbLookup("article","tag1",m.ps_artinum,"ar_pprice")
						IF (m.ps_amount-l_nPurchasePrice-&l_cVatMacro1) > 0
							&l_cVatMacro2 = (m.ps_amount-l_nPurchasePrice-&l_cVatMacro1) * (l_VatPct2 / 100)
						ENDIF
					 CASE UPPER(ALLTRIM(l_VatTyp2)) == "BT"
						&l_cVatMacro2 = l_VatPct2
					 OTHERWISE
						&l_cVatMacro2 = m.ps_amount * ( 1 - (100 / (100 + l_VatPct2)))
					ENDCASE
				ENDIF
                M.ps_split = (raTearti.ra_artityp==2)
                M.ps_ratecod = IIF(raTearti.ra_artityp==3, "",  ;
                               raTearti.ra_ratecod)
                M.ps_amount = ROUND(M.ps_amount,2) && ps_amount b(8,2)
                IF M.ps_amount<>0.00 .OR. ratearti.ra_artityp==1
                     M.ps_postid = neXtid('Post')
                     INSERT INTO TempPost FROM MEMVAR
                ENDIF
                SELECT raTearti
           ENDIF
      ENDSCAN
      SELECT teMppost
      IF RECCOUNT()>0
           = InvPostResFix(dForDate, "temppost", ratecode.rc_ratecod+ ;
                     ratecode.rc_roomtyp+DTOS(ratecode.rc_fromdat)+ratecode.rc_season)
           SUM ps_amount TO l_Amount ALL FOR teMppost.ps_split
           GOTO TOP IN "temppost"
           SCATTER MEMVAR
         IF NOT g_lFakeResAndPost OR (TYPE("max1") <> "D") OR (TYPE("min1") <> "D") OR ;
             BETWEEN(dfOrdate + LOOKUP(article.ar_fcstofs,m.ps_artinum,article.ar_artinum,"TAG1"), min1, max1)
           LOCAL l_flagZero
           l_flagZero = (M.ps_amount = 0)
           M.ps_price = M.ps_amount-l_Amount
           M.ps_units = 1
           M.ps_amount = M.ps_price*M.ps_units
           M.ps_split = .T.
			LOCAL l_cVatMacro1, l_cVatMacro2
			l_cVatMacro1 = "m.ps_vat"+LTRIM(STR(l_Mvatnum))
			l_cVatMacro2 = "m.ps_vat"+LTRIM(STR(l_M2vatnum))
			IF param.pa_exclvat
				IF UPPER(ALLTRIM(l_M2VatTyp2)) <> "PP"
					&l_cVatMacro1 = m.ps_amount * (l_MVatPct / 100)
					IF UPPER(ALLTRIM(l_M2VatTyp2)) <> "BT"
						IF paRam.pa_compvat
							&l_cVatMacro2 = (m.ps_amount + &l_cVatMacro1) * (l_M2vatpct / 100)					
						ELSE
							&l_cVatMacro2 = m.ps_amount * (l_M2vatpct / 100)
						ENDIF
					ELSE
						&l_cVatMacro2 = l_M2vatpct
					ENDIF
				ELSE
					LOCAL l_nPurchasePrice
					l_nPurchasePrice = DbLookup("article","tag1",m.ps_artinum,"ar_pprice")
					IF (m.ps_amount-l_nPurchasePrice) > 0
						&l_cVatMacro2 = (m.ps_amount-l_nPurchasePrice) * (l_M2vatpct / (100-l_M2vatpct))
					ENDIF
					&l_cVatMacro1 = (m.ps_amount+&l_cVatMacro2) * (l_MVatPct / 100)
				ENDIF
			ELSE
				&l_cVatMacro1 = m.ps_amount * ( 1 - (100 / (100 + l_MVatPct)))
				DO CASE
				 CASE UPPER(ALLTRIM(l_M2VatTyp2)) == "PP"
					LOCAL l_nPurchasePrice
					l_nPurchasePrice = DbLookup("article","tag1",m.ps_artinum,"ar_pprice")
					IF (m.ps_amount-l_nPurchasePrice-&l_cVatMacro1) > 0
						&l_cVatMacro2 = (m.ps_amount-l_nPurchasePrice-&l_cVatMacro1) * (l_M2vatpct / 100)
					ENDIF
				 CASE UPPER(ALLTRIM(l_M2VatTyp2)) == "BT"
					&l_cVatMacro2 = l_M2vatpct
				 OTHERWISE
					&l_cVatMacro2 = m.ps_amount * ( 1 - (100 / (100 + l_M2vatpct)))
				ENDCASE
			ENDIF
           IF .NOT. l_flagZero
                M.ps_amount = ROUND(M.ps_amount,2) && ps_amount b(8,2)
                IF M.ps_amount <> 0.00
                     M.ps_postid = NextId("post")
                     INSERT INTO temppost FROM MEMVAR
                ENDIF
                SELECT teMppost
                SUM ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5,  ;
                    ps_vat6, ps_vat7, ps_vat8, ps_vat9 TO l_Vat0, l_Vat1,  ;
                    l_Vat2, l_Vat3, l_Vat4, l_Vat5, l_Vat6, l_Vat7,  ;
                    l_Vat8, l_Vat9 ALL FOR teMppost.ps_split
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
           ELSE
                STORE 0.00 TO M.ps_vat0, M.ps_vat1,M.ps_vat2, M.ps_vat3, ps_vat4, ;
                          M.ps_vat5, M.ps_vat6, M.ps_vat7, M.ps_vat8, M.ps_vat9
                GATHER MEMVAR
                SELECT temppost
                SUM ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ;
                          ps_vat6, ps_vat7, ps_vat8, ps_vat9 ;
                          TO l_Vat0, l_Vat1, l_Vat2, l_Vat3, l_Vat4, l_Vat5, ;
                          l_Vat6, l_Vat7, l_Vat8, l_Vat9 ;
                          FOR ps_split
                M.ps_vat0 = - l_Vat0
                M.ps_vat1 = - l_Vat1
                M.ps_vat2 = - l_Vat2
                M.ps_vat3 = - l_Vat3
                M.ps_vat4 = - l_Vat4
                M.ps_vat5 = - l_Vat5
                M.ps_vat6 = - l_Vat6
                M.ps_vat7 = - l_Vat7
                M.ps_vat8 = - l_Vat8
                M.ps_vat9 = - l_Vat9
                GO TOP IN temppost
                GATHER MEMVAR FIELDS ps_vat0, ps_vat1, ps_vat2, ps_vat3, ;
                          ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9
           ENDIF
         ENDIF
      ENDIF
 ENDIF
 IF  .NOT. leRror
      IF RECCOUNT("temppost")>0
           nsPlitsetid = 0
           SELECT(lp_cPostAlias)
           IF raTecode.rc_rhytm==7
                LOCATE ALL FOR ps_reserid=teMppost.ps_reserid .AND.  ;
                       ps_artinum=l_Marti .AND. ps_ratecod= ;
                       raTecode.rc_ratecod+raTecode.rc_roomtyp+ ;
                       DTOS(raTecode.rc_fromdat)+raTecode.rc_season .AND.   ;
                       .NOT. ps_split
                IF FOUND()
                     SELECT teMppost
                     GOTO TOP IN "temppost"
                     SCATTER MEMVAR FIELDS ps_price, ps_amount, ps_vat0,  ;
                             ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5,  ;
                             ps_vat6, ps_vat7, ps_vat8, ps_vat9, ps_date,  ;
                             ps_touched
                     DELETE
                     SELECT(lp_cPostAlias)
                     M.ps_price = ps_price+M.ps_price
                     M.ps_amount = ps_amount+M.ps_amount
                     M.ps_vat0 = ps_vat0+M.ps_vat0
                     M.ps_vat1 = ps_vat1+M.ps_vat1
                     M.ps_vat2 = ps_vat2+M.ps_vat2
                     M.ps_vat3 = ps_vat3+M.ps_vat3
                     M.ps_vat4 = ps_vat4+M.ps_vat4
                     M.ps_vat5 = ps_vat5+M.ps_vat5
                     M.ps_vat6 = ps_vat6+M.ps_vat6
                     M.ps_vat7 = ps_vat7+M.ps_vat7
                     M.ps_vat8 = ps_vat8+M.ps_vat8
                     M.ps_vat9 = ps_vat9+M.ps_vat9
                     M.ps_date = sySdate()
                     M.ps_touched = .T.
                     GATHER MEMVAR FIELDS ps_price, ps_amount, ps_vat0,  ;
                            ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5,  ;
                            ps_vat6, ps_vat7, ps_vat8, ps_vat9, ps_date,  ;
                            ps_touched
                     nsPlitsetid = ps_setid
                ENDIF
           ENDIF
           IF nsPlitsetid=0
                nsPlitsetid = neXtid('SPLITSET')
           ENDIF
           SELECT teMppost
           REPLACE ps_setid WITH nsPlitsetid ALL FOR  .NOT. EMPTY(ps_ratecod)
           SELECT(lp_cPostAlias)
           APPEND FROM (ctMpfilename)
      ENDIF
      SELECT reServat
      DO CASE
           CASE ctYpe="CHECKIN"
                REPLACE reServat.rs_ratein WITH .T.
                IF (raTecode.rc_rhytm==2 .OR. raTecode.rc_rhytm==3)
                     REPLACE reServat.rs_ratedat WITH dfOrdate
                ENDIF
           CASE ctYpe="CHECKOUT"
                REPLACE reServat.rs_rateout WITH .T.
           OTHERWISE
                REPLACE reServat.rs_ratedat WITH dfOrdate
      ENDCASE
 ENDIF
 = clOsefile("TempPost")
 SELECT (coLdarea)
 RETURN
ENDPROC
*
FUNCTION PostYesNo
 PARAMETER dfOrdate, ctYpe
 LOCAL l_lWeekendRate, l_nSumRate
 PRIVATE lpOstit
 lpOstit = .F.
 l_lWeekendRate = SUBSTR(ratecode.rc_weekend, DOW(dfOrdate, 2), 1) = '1' AND ;
      SUBSTR(ratecode.rc_closarr, DOW(reservat.rs_arrdate, 2), 1) = ' '
 IF l_lWeekendRate
      l_nSumRate = raTecode.rc_wamnt1+ ;
           raTecode.rc_wamnt2+raTecode.rc_wamnt3+raTecode.rc_wamnt4+ ;
           raTecode.rc_wamnt5+raTecode.rc_wcamnt1+raTecode.rc_wcamnt2+ ;
           raTecode.rc_wcamnt3
 ELSE
      l_nSumRate = raTecode.rc_amnt1+ ;
           raTecode.rc_amnt2+raTecode.rc_amnt3+raTecode.rc_amnt4+ ;
           raTecode.rc_amnt5+raTecode.rc_camnt1+raTecode.rc_camnt2+ ;
           raTecode.rc_camnt3
 ENDIF
 DO CASE
      CASE ratecode.rc_noextr AND ratearti.ra_artityp = 3 AND l_lWeekendRate
      CASE reServat.rs_rate=0.00 .AND. l_nSumRate<>0.00 .AND. EMPTY(ctYpe)
           lpOstit = .T.
      CASE raTecode.rc_rhytm=1 .AND. EMPTY(ctYpe) .AND.  ;
           EMPTY(raTearti.ra_onlyon)
           lpOstit = .T.
      CASE raTecode.rc_rhytm=1 .AND. EMPTY(ctYpe) .AND.  ;
           raTearti.ra_onlyon>0 .AND. ((dfOrdate-reServat.rs_arrdate+1= ;
           raTearti.ra_onlyon) .OR. (raTearti.ra_onlyon=999 .AND.  ;
           dfOrdate=reServat.rs_depdate-1))
           lpOstit = .T.
      CASE raTecode.rc_rhytm=1 .AND. EMPTY(ctYpe) .AND.  ;
           raTearti.ra_onlyon<0 .AND. MOD(dfOrdate-reServat.rs_arrdate+1, - ;
           1*raTearti.ra_onlyon)=0
           lpOstit = .T.
      CASE raTecode.rc_rhytm=2 .AND. (ctYpe="CHECKIN" .OR. (EMPTY(ctYpe)  ;
           .AND. dfOrdate>reServat.rs_arrdate))
           lpOstit = .T.
      CASE raTecode.rc_rhytm=3 .AND. ctYpe="CHECKIN" .AND.  ;
           (INLIST(raTecode.rc_period, 1, 2, 3) .OR. (raTecode.rc_period== ;
           6 .AND. dfOrdate==reServat.rs_arrdate)) .AND.  ;
           (EMPTY(raTearti.ra_onlyon) .OR. (dfOrdate-reServat.rs_arrdate+ ;
           1=raTearti.ra_onlyon))
           lpOstit = .T.
      CASE raTecode.rc_rhytm=3 .AND. EMPTY(ctYpe) .AND.  ;
           raTecode.rc_period=3 .AND. dfOrdate>reServat.rs_ratedat .AND.  ;
           (EMPTY(raTearti.ra_onlyon) .OR. (dfOrdate-reServat.rs_arrdate+ ;
           1=raTearti.ra_onlyon))
           lpOstit = .T.
      CASE raTecode.rc_rhytm=4 .AND. ctYpe="CHECKOUT" .AND.  ;
           (INLIST(raTecode.rc_period, 1, 2, 3) .OR. (raTecode.rc_period== ;
           6 .AND. dfOrdate==reServat.rs_depdate-1))
           lpOstit = .T.
      *CASE raTecode.rc_rhytm=5 .AND. MOD(MAX(dfOrdate-reServat.rs_arrdate,  ;
      *     1), 7)==0 .AND. EMPTY(ctYpe)
      *     lpOstit = .T.
      CASE raTecode.rc_rhytm=5 .AND. (MOD(MAX(dfOrdate-reServat.rs_arrdate,  ;
           1), 7)==0 OR dfOrdate=reServat.rs_arrdate) .AND. EMPTY(ctYpe)
           lpOstit = .T.
      CASE raTecode.rc_rhytm=6 .AND. MONTH(dfOrdate)<>MONTH(dfOrdate-1)  ;
           .AND. EMPTY(ctYpe)
           lpOstit = .T.
      CASE raTecode.rc_rhytm=7 .AND. EMPTY(ctYpe) .AND. ((dfOrdate- ;
           reServat.rs_arrdate+1=raTearti.ra_onlyon) .OR.  ;
           (raTearti.ra_onlyon=999 .AND. dfOrdate=reServat.rs_depdate-1)  ;
           .OR. raTearti.ra_artityp==1)
           lpOstit = .T.
 ENDCASE
 RETURN lpOstit
ENDFUNC
*
FUNCTION PostMultiply
 PRIVATE ALL LIKE l_*
 l_Retval = 1
 DO CASE
      CASE raTearti.ra_multipl==1
           l_Retval = reServat.rs_adults
      CASE raTearti.ra_multipl==2
           l_Retval = reServat.rs_adults+reServat.rs_childs+reservat.rs_childs2+reservat.rs_childs3
      CASE raTearti.ra_multipl==3
           l_Retval = reServat.rs_childs
      CASE raTearti.ra_multipl==4
           l_Retval = 1
      CASE raTearti.ra_multipl==5
           l_Retval = reServat.rs_childs2
      CASE raTearti.ra_multipl==6
           l_Retval = reServat.rs_childs3
      CASE raTearti.ra_multipl==7
           l_Retval = 0
 ENDCASE
 DO CASE
      CASE raTecode.rc_period==1
           l_Periods = hoUrs(reServat.rs_arrtime,reServat.rs_deptime, ;
                       reServat.rs_arrdate,reServat.rs_depdate)
           l_Retval = l_Retval*l_Periods
      CASE raTecode.rc_period==2
           l_Periods = daYparts(reServat.rs_arrtime,reServat.rs_deptime, ;
                       reServat.rs_arrdate,reServat.rs_depdate)
           l_Retval = l_Retval*l_Periods
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
FUNCTION InvPostResFix
 PARAMETER p_Fordate, lp_cPostAlias, lp_cRateCode
 IF PCOUNT() < 2
      lp_cPostAlias = "post"
 ENDIF
 LOCAL l_lPackage, l_nRecno, l_Season, l_cError, l_RcOrd, l_nRecnoRC
 l_lPackage = NOT EMPTY(lp_cRateCode)
 PRIVATE ALL LIKE l_*
 PRIVATE ALL LIKE ps_*
 IF (p_ForDate<=reservat.rs_ratedat OR p_ForDate<=reservat.rs_rfixdat) AND NOT l_lPackage 
      RETURN
 ENDIF
 l_Oldsel = SELECT()
 l_Arord = ORDER("Article")
 l_Arrec = RECNO("Article")
 l_Plord = ORDER("Picklist")
 l_Plrec = RECNO("Picklist")
 l_Rford = ORDER("ResFix")
 l_Rfrec = RECNO("ResFix")
 l_RcOrd = ORDER("Ratecode")
 SELECT piCklist
 SET ORDER TO tag3
 SELECT arTicle
 SET ORDER TO tag1
 SELECT reSfix
 SET ORDER TO tag1
 IF SEEK(reServat.rs_reserid)
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
                          DO PostRate IN RatePost WITH lp_cPostAlias, "INVOICE", resfix.rf_price, resfix.rf_adults, ;
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
           IF NOT EMPTY(resfix.rf_artinum) AND (resfix.rf_package == l_lPackage) AND ;
                     SEEK(resfix.rf_artinum, "article", "tag1")
                IF g_lFakeResAndPost AND (TYPE("max1") = "D") AND (TYPE("min1") = "D") AND NOT BETWEEN(p_Fordate + article.ar_fcstofs, min1, max1)
                    LOOP
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
                l_Window = 1
                M.ps_artinum = reSfix.rf_artinum
                l_nRecno = RECNO("resfix")
                DO biLlinstr IN BillInst WITH M.ps_artinum,  ;
                   reServat.rs_billins, l_Id, l_Window
                GO l_nRecno IN resfix
                IF l_Id<>reServat.rs_reserid
                     M.ps_supplem = get_rm_rmname(reServat.rs_roomnum)+" "+adDress.ad_lname
                ELSE
                     M.ps_supplem = ""
                ENDIF
                M.ps_units = reSfix.rf_units
                M.ps_price = reSfix.rf_price
                M.ps_reserid = l_Id
                M.ps_window = l_Window
                M.ps_origid = reServat.rs_reserid
                M.ps_date = sySdate()
                M.ps_time = TIME()
                M.ps_amount = M.ps_price*M.ps_units
                M.ps_userid = "AUTOMATIC"
                M.ps_cashier = 0
                IF (paRam.pa_exclvat)
                     l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                     &l_Vat			= m.ps_amount * (l_VatPct / 100)
                     IF paRam.pa_compvat
                          l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                          &l_Vat2 = (m.ps_amount + &l_Vat) * (l_VatPct2 / 100)						
                     ELSE
                          l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                          &l_Vat2 = m.ps_amount * (l_VatPct2 / 100)
                     ENDIF
                ELSE
                     l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
                     &l_Vat			= m.ps_amount * ( 1 - (100 / (100 + l_VatPct)))
                     l_Vat2 = "m.ps_vat"+LTRIM(STR(l_Vatnum2))
                     &l_Vat2			= m.ps_amount * ( 1 - (100 / (100 + l_VatPct2)))
                ENDIF
                M.ps_split = resfix.rf_package
                M.ps_ratecod = IIF(l_lPackage, lp_cRateCode, "")
                M.ps_invtype = IIF(l_lPackage, "P", "R")
                M.ps_invdate = p_Fordate
                M.ps_postid = neXtid('Post')
                M.ps_amount = ROUND(M.ps_amount,2) && ps_amount b(8,2)
                INSERT INTO &lp_cPostAlias FROM MEMVAR
                *IF arTicle.ar_stckctl
                *     REPLACE arTicle.ar_stckcur WITH arTicle.ar_stckcur- ;
                *             M.ps_units
                *ENDIF
                IF l_lPackage
                     GO TOP IN &lp_cPostAlias
                     m.ps_amount = m.ps_amount + &lp_cPostAlias..ps_amount
                     m.ps_price = m.ps_amount / &lp_cPostAlias..ps_units
                     REPLACE ps_amount WITH m.ps_amount, ;
                     		ps_price WITH m.ps_price IN &lp_cPostAlias
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
 SET ORDER IN "ResFix" TO l_RfOrd
 GOTO l_Rfrec IN "ResFix"
 SELECT (l_Oldsel)
 RETURN .T.
ENDFUNC
*
