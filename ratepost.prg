 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, lp_uParam6, lp_uParam7, lp_uParam8, ;
            lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13, lp_uParam14, lp_uParam15, lp_uParam16
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal

 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO PCOUNT()-1
    l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"
 *l_cCallProc = MakeCallProc(lp_cFuncName, "lp_uParam", PCOUNT()-1)
 l_uRetVal = &l_cCallProc

 RETURN l_uRetVal
ENDFUNC
*
FUNCTION RateCodePost
 PARAMETER dfOrdate, ctYpe, lp_nWindow, lp_cSupplem, lp_lCheckResfixForAllPeriod
 PRIVATE ncUrrentarea
 PRIVATE ndOwcurrent, ndOwarrival, caDfld, ccHfld
 PRIVATE l_cRoomtype, l_cRoomnum
 LOCAL l_dDate, l_dEnd, l_dPostDate, l_dRcStartDate, l_dRcEndDate, l_dFirstDate, l_dLastDate, l_cRatecode, l_nRate, l_nRecno, l_cOrder, l_lFound, l_lStop, ;
          l_dArrDate, l_dDepDate, l_nAltId, l_dArrTime, l_dDepTime, l_oResrooms, l_lRiClose, l_lRrClose, l_lRaClose, ;
          l_oOldRes, l_oNewRes, l_nAdults, l_lChangeVAT, l_cPlTmp, l_cArTmp, l_lAdvanceBill, l_lRateDatChanged
 ncUrrentarea = SELECT()
 IF NOT USED('resrooms')
      openfiledirect(.F., "resrooms")
      l_lRiClose = .T.
 ENDIF
 IF NOT USED('resrate')
      openfiledirect(.F., "resrate")
      l_lRrClose = .T.
 ENDIF
 IF NOT USED('resrart')
      openfiledirect(.F., "resrart")
      l_lRaClose = .T.
 ENDIF

 IF reservat.rs_rcsync
      rrsyncreser(reservat.rs_rsid,,.T.)
 ENDIF

 IF EMPTY(ctYpe) AND NOT _screen.oGlobal.oParam2.pa_fixonda
      RPPostResFix(dfOrdate, lp_lCheckResfixForAllPeriod)
 ENDIF

 l_lAdvanceBill = (dfOrdate > SysDate())
 l_nAdults = 0
 l_dArrDate = reservat.rs_arrdate
 l_dDepDate = reservat.rs_depdate
 l_cRoomtype = reservat.rs_roomtyp
 l_cRoomnum = reservat.rs_roomnum
 l_nAltId = reservat.rs_altid
 l_dArrTime = reservat.rs_arrtime
 l_dDepTime = reservat.rs_deptime

 IF (ctYpe = "CHECKIN" AND dfOrdate = reservat.rs_arrdate AND NOT reservat.rs_ratein) OR ;
           (ctYpe = "CHECKOUT" AND dfOrdate = reservat.rs_depdate AND (NOT reservat.rs_rateout OR dfOrdate > reservat.rs_ratedat+1)) OR ;
           (EMPTY(ctYpe) AND dfOrdate > reservat.rs_ratedat)
      IF NOT g_lFakeResAndPost
           FNWaitWindow(ALLTRIM(reservat.rs_rmname)+" "+PROPER(ALLTRIM(reservat.rs_lname))+" "+ALLTRIM(reservat.rs_ratecod)+"...",.T.)
      ENDIF
      l_dDate = MAX(reservat.rs_arrdate, reservat.rs_ratedat+1)
      CursorQuery("resrate", StrToSql("rr_reserid = %n1", reservat.rs_reserid))
      CursorQuery("resrooms", StrToSql("ri_reserid = %n1", reservat.rs_reserid))
      CursorQuery("resrart", StrToSql("ra_rsid = %n1", reservat.rs_rsid))
      l_dEnd = dfOrdate
      DO WHILE l_dDate <= l_dEnd
           l_lChangeVAT = ProcBill("ChangeVAT", l_dDate, @l_cPlTmp, @l_cArTmp)
           IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(l_dDate-1),"resrate","tag2")
                l_cRatecode = resrate.rr_ratecod
           ELSE
                l_cRatecode = ""
           ENDIF
           IF NOT SEEK(STR(reservat.rs_reserid,12,3)+DTOS(l_dDate), "resrate", "tag2")
                EXIT
           ENDIF
           IF NOT (l_cRatecode == resrate.rr_ratecod) AND NOT EMPTY(l_cRatecode)
                l_nRecno = RECNO("reservat")
                BLANK FIELDS rs_ratexch IN reservat
                IF CURSORGETPROP("Buffering", "reservat") == 1
                    FLUSH
                ELSE
                    =TABLEUPDATE(.T., .T., "reservat")
                ENDIF
                GO l_nRecno IN reservat
           ENDIF
           RiGetRoom(reservat.rs_reserid, l_dDate, @l_oResrooms)
           IF NOT ISNULL(l_oResrooms)
                l_cRoomtype = l_oResrooms.ri_roomtyp
                l_cRoomnum = l_oResrooms.ri_roomnum
           ENDIF
           IF resrate.rr_status = "X"
                SELECT reservat
                SCATTER NAME l_oOldRes MEMO
                SCATTER NAME l_oNewRes MEMO
                ProcResRate("RrUpdate", l_oOldRes, l_oNewRes, .T., l_dDate, l_dDate)
                IF NOT SEEK(STR(reservat.rs_reserid,12,3)+DTOS(l_dDate), "resrate", "tag2") OR resrate.rr_status = "X"
                     EXIT
                ENDIF
           ENDIF
           l_cRatecode = IIF(resrate.rr_status = "X", resrate.rr_ratecod, LEFT(resrate.rr_ratecod,10))
           l_lFound = RatecodeLocate(l_dDate, ALLTRIM(l_cRatecode), l_cRoomtype, l_dArrDate)
           ProcResRate("RrRatecodeInterval", reservat.rs_reserid, l_dDate, @l_dRcStartDate, @l_dRcEndDate)
           ProcResRate("RrRatecodeFirstLastDay", l_dDate, l_dRcStartDate, l_dRcEndDate, @l_dFirstDate, @l_dLastDate)
           l_dPostDate = ProcResRate("RRGetPostDate", l_dDate, l_dRcStartDate, l_dRcEndDate, l_dFirstDate, l_dLastDate)
           IF l_dDate <> l_dPostDate AND BETWEEN(l_dPostDate, l_dRcStartDate, l_dRcEndDate)
                l_lFound = RatecodeLocate(l_dPostDate, ALLTRIM(l_cRatecode), l_cRoomtype, l_dArrDate)
           ENDIF
           IF NOT l_lFound
                SELECT reservat
                SCATTER NAME l_oOldRes MEMO
                SCATTER NAME l_oNewRes MEMO
                ProcResRate("RrUpdate", l_oOldRes, l_oNewRes, .T., l_dDate, l_dDate)
                EXIT
           ELSE
                IF cType = "CHECKIN" AND NOT INLIST(ratecode.rc_rhytm, 2, 3)
                     EXIT
                ENDIF
                IF cType = "CHECKOUT" AND NOT ratecode.rc_rhytm = 4 && Event is CHECKOUT, but ratecode is not ON CHECKOUT
                     EXIT
                ENDIF
                DO CASE
                     CASE ratecode.rc_rhytm < 3
                     CASE ratecode.rc_rhytm = 3
                          l_dEnd = MAX(l_dEnd, l_dRcEndDate)
                     CASE ratecode.rc_rhytm = 4 AND NOT l_lAdvanceBill AND (l_dRcEndDate > l_dEnd OR EMPTY(cType) AND l_dRcEndDate = reservat.rs_depdate-1)
                          EXIT
                     CASE INLIST(ratecode.rc_rhytm, 5, 6)
                          l_dEnd = MAX(l_dEnd, l_dLastDate)
                ENDCASE
                IF _screen.oGlobal.oParam2.pa_fixonda
                     DO PostResfix IN ResFix WITH l_dDate
                ENDIF
                l_cRatecode = ALLTRIM(ratecode.rc_ratecod)
                SELECT reservat
                SCATTER NAME l_oNewRes MEMO
                l_nRate = ProcResRate("RrDayPrice", l_oNewRes, l_dDate)
                DO CASE
                     CASE resrate.rr_status = "X"
                          * If there for some reason stay invalid record in resrate.dbf pick rate an ratecode from reservat.
                          l_cRatecode = reservat.rs_ratecod
                          l_nRate = reservat.rs_rate
                     CASE INLIST(resrate.rr_status, "OAL", "ORA")
                          l_cRatecode = "!" + l_cRatecode
                     OTHERWISE     &&INLIST(resrate.rr_status, "OUS", "ORU", "OFF")
                          l_cRatecode = "*" + l_cRatecode
                ENDCASE
                l_nAdults = resrate.rr_adults
                l_nChilds = resrate.rr_childs
                l_nChilds2 = resrate.rr_childs2
                l_nChilds3 = resrate.rr_childs3
                l_nRate = RateCalculate(l_dDate, l_cRatecode, l_cRoomtype, l_nAltId, l_nRate, ;
                     l_nAdults, l_nChilds, l_nChilds2, l_nChilds3, l_dArrDate, l_dDepDate, l_dArrTime, l_dDepTime)
                IF ThisPostRate(l_dDate, ctYpe, l_nRate, lp_nWindow, lp_cSupplem)
                     IF NOT l_lRateDatChanged
                          l_lRateDatChanged = .T.
                     ENDIF
                     REPLACE rs_ratedat WITH l_dDate IN reservat
                     DO CASE
                          CASE cType = "CHECKIN"
                               REPLACE rs_ratein WITH .T. IN reservat
                          CASE cType = "CHECKOUT"
                               REPLACE rs_rateout WITH .T. IN reservat
                     ENDCASE
                     IF CURSORGETPROP("Buffering", "reservat") = 1
                         FLUSH
                         DBTableFlushForce()
                     ELSE
                         = TABLEUPDATE(.T., .T., "reservat")
                     ENDIF
                ENDIF
                l_dDate = l_dDate + 1
           ENDIF
           IF l_lChangeVAT
               ProcBill("RestoreVAT", l_cPlTmp, l_cArTmp)
           ENDIF
      ENDDO
      IF NOT g_lFakeResAndPost
           FNWaitWindow(,,,.T.)
      ENDIF
 ENDIF
 IF l_lRateDatChanged
      PRT_rsifsync_insert("reservat", "EDIT")
 ENDIF
 IF l_lRiClose
      dclose("resrooms")
 ENDIF
 IF l_lRrClose
      dclose("resrate")
 ENDIF
 IF l_lRaClose
      dclose("resrart")
 ENDIF
 SELECT (ncUrrentarea)
 RETURN .T.
ENDFUNC
*
PROCEDURE ThisPostRate
 PARAMETER dfOrdate, ctYpe, lp_nPrice, nwindow, lp_cSupplem
 PRIVATE leRror
 PRIVATE nrEsid, nfOliowin
 PRIVATE p_dPostDate
 LOCAL l_lAllow, l_lOnlyMainDisc, l_nSplitSetID, l_nMainPrice, l_nSplitPrice, l_nPackagePrice, l_nMainSplitPriceCorr, l_cRatecode, l_cVatMacro1, l_cVatMacro2, l_lspecialfiscalprintermode
 LOCAL l_Marti, l_nParts, l_nRatePct, l_lMainZeroPrice, l_dRcStartDate, l_dRcEndDate, l_dFirstDate, l_dLastDate, l_dPostDate, l_cRaAlias, l_lCustomRA, l_cRaWhileClause, l_nArtinum, l_lPostIt
 LOCAL l_curPost, l_nPositIdMain, l_Discpct, l_nRecCount, l_lUdRate
 LOCAL ARRAY l_aWin(1), l_aVat(1)
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
 l_lspecialfiscalprintermode = _screen.oGlobal.lspecialfiscalprintermode
 l_lUdRate = LEFT(reservat.rs_ratecod,1) = "*"
 IF EMPTY(nwindow)
      nwindow = PBGetFreeWindow(reservat.rs_reserid)
 ENDIF
 SELECT * FROM post WHERE 0=1 INTO CURSOR TempPost READWRITE
 l_cRatecode = ratecode.rc_ratecod + ratecode.rc_roomtyp + DTOS(ratecode.rc_fromdat) + ratecode.rc_season
 IF NOT SEEK(l_cRatecode+'1', "RateArti") AND NOT SEEK(STR(reservat.rs_rsid,10)+l_cRatecode+'1', "ResRart", "tag1")
      ceRrortxt = GetLangText("RATEPOST","TA_MAINNOTFOUND")+" "+TRIM(raTecode.rc_ratecod)+" "+TRIM(raTecode.rc_roomtyp)+" "+DTOC(raTecode.rc_fromdat)+"!"
      = erRormsg("RoomType:"+l_cRoomtype+" Room:"+l_cRoomnum+" "+ceRrortxt)
      = alErt(ceRrortxt)
      leRror = .T.
 ENDIF
 IF NOT leRror
      l_lCustomRA = SEEK(STR(reservat.rs_rsid,10)+l_cRatecode, "ResRart", "tag1")
      l_cRaAlias = IIF(l_lCustomRA, "resrart", "ratearti")
      l_cRaWhileClause = IIF(l_lCustomRA, "ra_rsid = " + SqlCnv(reservat.rs_rsid) + " AND ", "")
      ProcResRate("RrRatecodeInterval", reservat.rs_reserid, dfOrdate, @l_dRcStartDate, @l_dRcEndDate)
      ProcResRate("RrRatecodeFirstLastDay", dfOrdate, l_dRcStartDate, l_dRcEndDate, @l_dFirstDate, @l_dLastDate)
      l_curPost = SqlCursor("SELECT * FROM post WHERE ps_origid = " + SqlCnv(reservat.rs_reserid) + " AND BETWEEN(ps_rdate, " + SqlCnv(l_dFirstDate) + ", " + SqlCnv(l_dLastDate) + ") AND ps_ratecod = " + SqlCnv(l_cRatecode))
      SELECT &l_cRaAlias
      SCAN WHILE &l_cRaWhileClause ra_ratecod = l_cRatecode
           IF PostYesNo(dfOrdate, ctYpe, @l_lPostIt,,,l_dRcStartDate, l_dRcEndDate, @l_dPostDate, l_cRaAlias) AND (l_lPostIt OR DLocate(l_curPost, "NOT ps_split"))
                l_nArtinum = IIF(l_lCustomRA, &l_cRaAlias..ra_artinum, RPGetMainArtiNum(dfOrdate))
                SELECT arTicle
                IF NOT SEEK(l_nArtinum, "Article")
                     ceRrortxt = GetLangText("RATEPOST","TA_ARNOTFOUND")+" "+LTRIM(STR(l_nArtinum, 4))+"!"
                     = erRormsg("RoomType:"+l_cRoomtype+" Room:"+l_cRoomnum+" "+ceRrortxt)
                     = alErt(ceRrortxt)
                     leRror = .T.
                     EXIT
                ENDIF
                IF g_lFakeResAndPost AND (TYPE("max1") = "D") AND (TYPE("min1") = "D") AND NOT BETWEEN(dfOrdate + article.ar_fcstofs, min1, max1)
                     LOOP
                ENDIF
                SELECT paYmetho
                IF NOT EMPTY(raTecode.rc_paynum) AND SEEK(raTecode.rc_paynum, "PayMetho")
                     IF EMPTY(reServat.rs_ratexch)
                          l_Currencyrate = EVL(paYmetho.pm_rate, 1.00)
                          REPLACE rs_ratexch WITH l_Currencyrate IN reServat
                          IF CURSORGETPROP("Buffering","reservat") == 1
                              FLUSH
                          ELSE
                              = TABLEUPDATE(.F.,.T.,"reservat")
                          ENDIF
                     ELSE
                          l_Currencyrate = reServat.rs_ratexch
                     ENDIF
                ELSE
                     l_Currencyrate = 1.00
                ENDIF
                SELECT piCklist
                SET ORDER TO 3
                IF NOT SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat, 3), "PickList")
                     ceRrortxt = GetLangText("RATEPOST","TA_VATNOTFOUND")+" "+LTRIM(STR(arTicle.ar_vat))+"!"
                     = erRormsg("RoomType:"+l_cRoomtype+" Room:"+l_cRoomnum+" "+ceRrortxt)
                     = alErt(ceRrortxt)
                     leRror = .T.
                     EXIT
                ENDIF
                l_Vatnum = arTicle.ar_vat
                l_Vatpct = piCklist.pl_numval
                IF (arTicle.ar_vat2>0)
                     IF NOT SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat2, 3), "PickList")
                          ceRrortxt = GetLangText("RATEPOST","TA_VATNOTFOUND")+" "+LTRIM(STR(arTicle.ar_vat2))+"!"
                          = erRormsg("RoomType:"+l_cRoomtype+" Room:"+l_cRoomnum+" "+ceRrortxt)
                          = alErt(ceRrortxt)
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
                IF (&l_cRaAlias..ra_artityp==1)
                     l_Mvatnum = l_Vatnum
                     l_Mvatpct = l_Vatpct
                     l_M2vatnum = l_Vatnum2
                     l_M2vatpct = l_Vatpct2
                     l_M2VatTyp2 = picklist.pl_user2
                     l_Marti = l_nArtinum
                ENDIF
                SELECT teMppost
                SCATTER BLANK MEMVAR
                M.ps_artinum = l_nArtinum
                IF l_lspecialfiscalprintermode
                     M.ps_ifc = ""
                     IF &l_cRaAlias..ra_artityp==1
                          M.ps_ifc = RPGetFiscalPrinterArticleDescription()
                     ENDIF
                ENDIF
                l_nParts = ICASE(ratecode.rc_period = 4, (l_dLastDate-l_dFirstDate+1)/7, ratecode.rc_rhytm = 7, 1/(l_dLastDate-l_dFirstDate+1), 1)
                M.ps_units = 1
                DO CASE
                     CASE &l_cRaAlias..ra_artityp==1
                          M.ps_price = lp_nPrice * l_nParts
                     CASE EMPTY(&l_cRaAlias..ra_amnt) AND NOT EMPTY(&l_cRaAlias..ra_ratepct)
                          M.ps_price = IIF(&l_cRaAlias..ra_pctexma, 0, lp_nPrice * l_nParts * &l_cRaAlias..ra_ratepct / 100)     && If ra_pctexma then calculate price at the end
                     OTHERWISE
                          M.ps_units = poStmultiply(dfOrdate,l_cRaAlias)
                          M.ps_price = &l_cRaAlias..ra_amnt                                && For week ratecode price for all articles is proportional
                ENDCASE
                IF lp_nPrice = 0.00 AND &l_cRaAlias..ra_artityp <> 3
                     M.ps_price = 0.00
                ELSE
                     M.ps_price = M.ps_price*IIF(&l_cRaAlias..ra_pmlocal,1.00,l_Currencyrate)
                ENDIF
                l_Discpct = 0
                IF NOT EMPTY(reServat.rs_discnt) AND &l_cRaAlias..ra_artityp <> 3          && No discount for extra article
                     l_lOnlyMainDisc = dlOokup('PickList', 'pl_label=[DISCOUNT] and pl_charcod = '+ sqLcnv(reServat.rs_discnt),'pl_user1=[1]') && pl_user1=[1] Discount only for main article
                     IF NOT l_lOnlyMainDisc OR &l_cRaAlias..ra_artityp = 1
                          l_Discpct = dlOokup('PickList', 'pl_label=[DISCOUNT] and pl_charcod = '+ sqLcnv(reServat.rs_discnt),'pl_numval')
                          IF l_Discpct>0 .AND. l_Discpct<=100
                               M.ps_price = M.ps_price*(100-l_Discpct)/100
                          ENDIF
                     ENDIF
                ENDIF
                IF INLIST(&l_cRaAlias..ra_artityp, 1, 3) OR (nrEsid=0 AND nfOliowin=0)
                     nrEsid = reServat.rs_reserid
                     nfOliowin = nwindow
                     p_dPostDate = dfOrdate
                     DO biLlinstr IN BillInst WITH M.ps_artinum, reServat.rs_billins, nrEsid, nfOliowin
                     IF (nrEsid<>reServat.rs_reserid)
                          M.ps_supplem = get_rm_rmname(l_cRoomnum) + " " + MakeProperName(reServat.rs_lname)
                          nfOliowin = nwindow
                     ENDIF
                     nfOliowin = PBGetFreeWindow(nrEsid, nfOliowin)
                     IF NOT EMPTY(lp_cSupplem)
                          M.ps_supplem = ALLTRIM(M.ps_supplem) + " " + lp_cSupplem
                     ENDIF
                ENDIF
                IF (&l_cRaAlias..ra_artityp == 2) .AND. (&l_cRaAlias..ra_amnt < 0)
                    M.ps_units = -M.ps_units
                    M.ps_price = -M.ps_price
                ENDIF
                M.ps_reserid = nrEsid
                M.ps_window = nfOliowin
                l_aWin(1) = nfOliowin
                M.ps_origid = reServat.rs_reserid
                M.ps_date = IIF(g_lFakeResAndPost, dfOrdate, SysDate())
                IF (sySdate()<>dfOrdate)
                     M.ps_supplem = DTOC(dfOrdate)+" "+M.ps_supplem
                ENDIF
                M.ps_rdate = l_dPostDate
                M.ps_time = TIME()
                M.ps_price = ROUND(M.ps_price, paRam.pa_currdec)
                IF &l_cRaAlias..ra_artityp = 1 AND l_nParts <> 1 AND dForDate = l_dLastDate
                     M.ps_price = lp_nPrice*IIF(&l_cRaAlias..ra_pmlocal,1.00,l_Currencyrate)*(100-l_Discpct)/100 - (1/l_nParts-1)*M.ps_price     && Rounding correction
                ENDIF
                M.ps_amount = ROUND(M.ps_price*M.ps_units,2)  && ps_amount b(8,2)
                M.ps_userid = "AUTOMATIC"
                M.ps_cashier = 0
                IF EMPTY(l_nSplitSetID) AND &l_cRaAlias..ra_artityp = 1 AND ratecode.rc_period > 3
                     IF DLocate(l_curPost, "NOT ps_split")
                          l_nPositIdMain = &l_curPost..ps_postid
                          l_nSplitSetID = &l_curPost..ps_setid
                     ENDIF
                ENDIF
                IF EMPTY(l_nSplitSetID)
                     l_nSplitSetID = NextId('SPLITSET')
                ENDIF
                M.ps_ratecod = IIF(&l_cRaAlias..ra_artityp = 3, "", &l_cRaAlias..ra_ratecod)
                M.ps_split = (&l_cRaAlias..ra_artityp = 2)
                M.ps_setid = IIF(EMPTY(M.ps_ratecod), 0, l_nSplitSetID)
                M.ps_raid = &l_cRaAlias..ra_raid
                ProcBill("ArticeVatAmounts", M.ps_artinum, M.ps_amount, @l_aVat)
                l_cVatMacro1 = "M.ps_vat" + TRANSFORM(l_aVat(1,1))
                l_cVatMacro2 = "M.ps_vat" + TRANSFORM(l_aVat(2,1))
                &l_cVatMacro1 = l_aVat(1,2)
                &l_cVatMacro2 = l_aVat(2,2)
                IF M.ps_units <> 0
                     IF NOT M.ps_split && check if bill should be reopened
                          DO BillsReserCheck IN ProcBill WITH nResId, l_aWin, "POST_NEW", l_lAllow
                          IF NOT l_lAllow
                               lError = .T.
                               EXIT
                          ENDIF
                     ENDIF
                     IF l_lPostIt
                          M.ps_postid = neXtid('Post')
                     ENDIF
                     INSERT INTO TempPost FROM MEMVAR
                ENDIF
                IF NOT l_lUdRate AND &l_cRaAlias..ra_package
                     GO TOP IN TempPost
                     m.ps_price = (TempPost.ps_amount + m.ps_amount) / TempPost.ps_units
                     REPLACE ps_amount WITH TempPost.ps_amount + m.ps_amount, ps_price WITH m.ps_price, ;
                          ps_vat0 WITH TempPost.ps_vat0 + m.ps_vat0, ps_vat1 WITH TempPost.ps_vat1 + m.ps_vat1, ;
                          ps_vat2 WITH TempPost.ps_vat2 + m.ps_vat2, ps_vat3 WITH TempPost.ps_vat3 + m.ps_vat3, ;
                          ps_vat4 WITH TempPost.ps_vat4 + m.ps_vat4, ps_vat5 WITH TempPost.ps_vat5 + m.ps_vat5, ;
                          ps_vat6 WITH TempPost.ps_vat6 + m.ps_vat6, ps_vat7 WITH TempPost.ps_vat7 + m.ps_vat7, ;
                          ps_vat8 WITH TempPost.ps_vat8 + m.ps_vat8, ps_vat9 WITH TempPost.ps_vat9 + m.ps_vat9 ;
                          IN TempPost
                ENDIF
                SELECT &l_cRaAlias
           ENDIF
      ENDSCAN
      CALCULATE CNT() TO l_nRecCount IN temppost
      IF l_nRecCount > 0
           IF EMPTY(l_nPositIdMain)
                DO PostResFix IN ResFix WITH dForDate, "temppost", ratecode.rc_ratecod+ratecode.rc_roomtyp+DTOS(ratecode.rc_fromdat)+ratecode.rc_season
           ENDIF
           CALCULATE SUM(IIF(NOT ps_split AND NOT EMPTY(ps_ratecod), ps_amount, 0)), SUM(IIF(ps_split, ps_amount, 0)) TO l_nMainPrice, l_nSplitPrice IN temppost
           l_nRatePct = RPGetSplitFromMainPct("temppost", l_cRaAlias, l_lUdRate)
           l_nMainSplitPriceCorr = (l_nMainPrice - l_nSplitPrice) * 100/(100+l_nRatePct)
           SELECT temppost
           SCAN FOR NOT EMPTY(ps_raid) AND SEEK(IIF(l_lCustomRA, STR(reservat.rs_rsid,10), "")+l_cRatecode+STR(ps_raid,10), l_cRaAlias, "tag2") AND ;
                     INLIST(&l_cRaAlias..ra_artityp, 2, 3) AND NOT &l_cRaAlias..ra_package AND &l_cRaAlias..ra_ratepct <> 0 AND &l_cRaAlias..ra_pctexma
                M.ps_price = ROUND(l_nMainSplitPriceCorr * &l_cRaAlias..ra_ratepct/100, param.pa_currdec)
                M.ps_amount = ROUND(M.ps_price * ps_units, 2)
                ProcBill("ArticeVatAmounts", ps_artinum, m.ps_amount, @l_aVat)
                l_cVatMacro1 = "ps_vat" + TRANSFORM(l_aVat(1,1))
                l_cVatMacro2 = "ps_vat" + TRANSFORM(l_aVat(2,1))
                M.&l_cVatMacro1 = l_aVat(1,2)
                M.&l_cVatMacro2 = l_aVat(2,2)
                GATHER MEMVAR FIELDS ps_amount, ps_price, &l_cVatMacro1, &l_cVatMacro2
                IF &l_cRaAlias..ra_artityp = 2
                     l_nSplitPrice = l_nSplitPrice + M.ps_amount
                ENDIF
           ENDSCAN
           LOCATE
           SCATTER MEMVAR
           l_lMainZeroPrice = (M.ps_amount = 0)
           M.ps_units = 1
           IF ratecode.rc_period > 3 AND ratecode.rc_rhytm <> 7                  && Main article posted (&l_cRaAlias..ra_artityp = 1)
                DO CASE
                     CASE dForDate < l_dLastDate
                          * In this case correct main article and main split would be 0
                          l_nMainPrice = l_nSplitPrice
                     CASE NOT EMPTY(l_nPositIdMain)
                          * In this case correct main article and remove amount from already posted main article (only on last date of rate code interval)
                          CALCULATE SUM(ps_amount) FOR ps_setid = l_nSplitSetID AND ps_split AND EMPTY(ps_raid) TO l_nPackagePrice IN post
                          DLocate(l_curPost, "ps_postid = " + SqlCnv(l_nPositIdMain))
                          l_nMainPrice = l_nMainPrice + l_nPackagePrice - &l_curPost..ps_amount
                     OTHERWISE
                ENDCASE
                M.ps_price = ROUND(l_nMainPrice, param.pa_currdec)
                M.ps_amount = ROUND(M.ps_price * M.ps_units, 2)
                GATHER MEMVAR FIELDS ps_amount, ps_price, ps_units               && Main article (ps_split = .F.)
           ENDIF
           M.ps_price = ROUND(l_nMainPrice - l_nSplitPrice, param.pa_currdec)    && Calculate main split article
           M.ps_amount = ROUND(M.ps_price * M.ps_units, 2)  && ps_amount b(8,2)
           M.ps_split = .T.
           DO CASE
                CASE NOT l_lMainZeroPrice
                     IF M.ps_amount <> 0.00
                          * Insert main split article if need
                          STORE 0.00 TO m.ps_vat0, m.ps_vat1, m.ps_vat2, m.ps_vat3, m.ps_vat4, m.ps_vat5, m.ps_vat6, m.ps_vat7, m.ps_vat8, m.ps_vat9
                          ProcBill("ArticeVatAmounts", m.ps_artinum, m.ps_amount, @l_aVat)
                          l_cVatMacro1 = "m.ps_vat" + TRANSFORM(l_aVat(1,1))
                          l_cVatMacro2 = "m.ps_vat" + TRANSFORM(l_aVat(2,1))
                          &l_cVatMacro1 = l_aVat(1,2)
                          &l_cVatMacro2 = l_aVat(2,2)
                          M.ps_postid = NextId("post")
                          INSERT INTO temppost FROM MEMVAR
                          IF NOT EMPTY(l_nPositIdMain)
                               DLocate(l_curPost, "ps_postid = " + SqlCnv(l_nPositIdMain))
                               REPLACE ps_supplem WITH &l_curPost..ps_supplem, ps_ifc WITH &l_curPost..ps_ifc IN temppost
                          ENDIF
                     ENDIF
                     * Correct VATs for main article
                     SELECT temppost
                     SUM ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9 ;
                          TO M.ps_vat0, M.ps_vat1, M.ps_vat2, M.ps_vat3, M.ps_vat4, M.ps_vat5, M.ps_vat6, M.ps_vat7, M.ps_vat8, M.ps_vat9 FOR ps_split
                     LOCATE
                     GATHER MEMVAR FIELDS ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9
                CASE SUBSTR(ratecode.rc_weekend, DOW(dForDate, 2), 1) = '1' AND SUBSTR(ratecode.rc_closarr, DOW(reservat.rs_arrdate, 2), 1) = ' '
                     DELETE FOR ps_ratecod = M.ps_ratecod IN temppost
                OTHERWISE
                     ************************************************************************************************
                     * No Main Logis article with ps_split = .F. found.                                             *
                     * Store in Main Logis article with ps_split = .T. correct VAT amount.                          *
                     ************************************************************************************************
                     SELECT temppost
                     LOCATE
                     STORE 0 TO M.ps_vat0, M.ps_vat1, M.ps_vat2, M.ps_vat3, M.ps_vat4, M.ps_vat5, M.ps_vat6, M.ps_vat7, M.ps_vat8, M.ps_vat9
                     ProcBill("ArticeVatAmounts", m.ps_artinum, m.ps_amount, @l_aVat)
                     l_cVatMacro1 = "m.ps_vat" + TRANSFORM(l_aVat(1,1))
                     l_cVatMacro2 = "m.ps_vat" + TRANSFORM(l_aVat(2,1))
                     &l_cVatMacro1 = l_aVat(1,2)
                     &l_cVatMacro2 = l_aVat(2,2)
                     GATHER MEMVAR FIELDS ps_split, ps_amount, ps_price, ps_units, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9
           ENDCASE
      ENDIF
      DClose(l_curPost)
 ENDIF
 IF NOT leRror
      CALCULATE CNT() TO l_nRecCount IN temppost
      IF l_nRecCount > 0
           *****************************
           * Posting one ratecode set! *
           *****************************
           IF NOT EMPTY(l_nPositIdMain)
                SELECT post
                =SEEK(l_nPositIdMain,"post","tag3")
                * Add amount and VAT to main article in post.dbf and remove main article in temppost.dbf
                SCATTER MEMVAR
                SELECT temppost
                LOCATE
                IF NOT EMPTY(ps_price) OR NOT EMPTY(ps_amount) OR NOT EMPTY(ps_vat0) OR NOT EMPTY(ps_vat1) OR NOT EMPTY(ps_vat2) OR NOT EMPTY(ps_vat3) OR ;
                          NOT EMPTY(ps_vat4) OR NOT EMPTY(ps_vat5) OR NOT EMPTY(ps_vat6) OR NOT EMPTY(ps_vat7) OR NOT EMPTY(ps_vat8) OR NOT EMPTY(ps_vat9)
                     M.ps_date = SysDate()
                     M.ps_price = M.ps_price + ps_price
                     M.ps_amount = M.ps_amount + ps_amount
                     M.ps_vat0 = M.ps_vat0 + ps_vat0
                     M.ps_vat1 = M.ps_vat1 + ps_vat1
                     M.ps_vat2 = M.ps_vat2 + ps_vat2
                     M.ps_vat3 = M.ps_vat3 + ps_vat3
                     M.ps_vat4 = M.ps_vat4 + ps_vat4
                     M.ps_vat5 = M.ps_vat5 + ps_vat5
                     M.ps_vat6 = M.ps_vat6 + ps_vat6
                     M.ps_vat7 = M.ps_vat7 + ps_vat7
                     M.ps_vat8 = M.ps_vat8 + ps_vat8
                     M.ps_vat9 = M.ps_vat9 + ps_vat9
                     M.ps_touched = .T.
                     SELECT post
                     GATHER MEMVAR
                ENDIF
                DELETE IN temppost
                CALCULATE CNT() TO l_nRecCount IN TempPost
                IF l_nRecCount > 0
                     IF NOT EMPTY(M.ps_window)
                          REPLACE ps_window WITH M.ps_window FOR NOT EMPTY(ps_ratecod) IN TempPost
                     ENDIF
                     IF NOT EMPTY(M.ps_reserid)
                          REPLACE ps_reserid WITH M.ps_reserid FOR NOT EMPTY(ps_ratecod) IN TempPost
                     ENDIF
                ENDIF
           ENDIF
           CALCULATE CNT() TO l_nRecCount IN TempPost
           IF l_nRecCount > 0
                REPLACE ps_postid WITH NextId("post") FOR EMPTY(ps_postid) IN TempPost
                SELECT poSt
                APPEND FROM DBF("TempPost")
                IF CURSORGETPROP("Buffering","post") == 1
                    FLUSH
                ELSE
                    = TABLEUPDATE(.T.,.T.,"post")
                ENDIF
                IF CURSORGETPROP("Buffering","pswindow") == 1
                    FLUSH
                ELSE
                    = TABLEUPDATE(.T.,.T.,"pswindow")
                ENDIF
                IF _screen.oglobal.oparam2.pa_restran
                    ProcReservatTransactions("reservat", "EDIT")
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 DClose("TempPost")
 SELECT (coLdarea)
 RETURN NOT leRror
ENDPROC
*
FUNCTION PostYesNo
 PARAMETER dfOrdate, ctYpe, lPostIt, nResRate, dResArrDate, dRcStartDate, dRcEndDate, dPostDate, cRaAlias
 LOCAL l_lWeekendRate, l_nSumRate

 nResRate = EVL(nResRate, reservat.rs_rate)
 dResArrDate = EVL(dResArrDate, reservat.rs_arrdate)
 dRcStartDate = EVL(dRcStartDate, dResArrDate)
 dRcEndDate = EVL(dRcEndDate, reservat.rs_depdate-1)
 cRaAlias = EVL(cRaAlias, "ratearti")

 l_lWeekendRate = SUBSTR(ratecode.rc_weekend, DOW(dfOrdate, 2), 1) = '1' AND SUBSTR(ratecode.rc_closarr, DOW(dResArrDate, 2), 1) = ' '
 IF l_lWeekendRate
      l_nSumRate = ratecode.rc_wamnt1 + ratecode.rc_wamnt2 + ratecode.rc_wamnt3 + ratecode.rc_wamnt4 + ratecode.rc_wamnt5 + ;
                   ratecode.rc_wcamnt1 + ratecode.rc_wcamnt2 + ratecode.rc_wcamnt3
 ELSE
      l_nSumRate = ratecode.rc_amnt1 + ratecode.rc_amnt2 + ratecode.rc_amnt3 + ratecode.rc_amnt4 + ratecode.rc_amnt5 + ;
                   ratecode.rc_camnt1 + ratecode.rc_camnt2 + ratecode.rc_camnt3
 ENDIF

 lPostIt = ProcResRate("RrPostIt", dfOrdate, dRcStartDate, dRcEndDate, @dPostDate, cRaAlias)
 DO CASE
      CASE NOT lPostIt
           *lPostIt = (&cRaAlias..ra_artityp = 1 AND nResRate = 0.00 AND l_nSumRate <> 0.00)
      CASE &cRaAlias..ra_artityp = 3 AND ratecode.rc_noextr AND l_lWeekendRate
           lPostIt = .F.
      OTHERWISE
 ENDCASE

 RETURN lPostIt OR &cRaAlias..ra_artityp = 1 AND BETWEEN(dPostDate, dRcStartDate, dRcEndDate)
ENDFUNC
*
FUNCTION PostMultiply
LPARAMETERS lp_dForDate, lp_cRaAlias, lp_Retval
 LOCAL l_Periods
 lp_cRaAlias = EVL(lp_cRaAlias, "ratearti")
 lp_Retval = 1
 IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(lp_dForDate), "resrate", "tag2")
      lp_Retval = RrGetUnits(lp_cRaAlias, resrate.rr_adults, resrate.rr_childs, resrate.rr_childs2, resrate.rr_childs3)
 ELSE
      lp_Retval = RrGetUnits(lp_cRaAlias, reservat.rs_adults, reservat.rs_childs, reservat.rs_childs2, reservat.rs_childs3)
 ENDIF
 DO CASE
      CASE ratecode.rc_period = 1
           l_Periods = Hours(reservat.rs_arrtime, reservat.rs_deptime, reservat.rs_arrdate, reservat.rs_depdate, lp_dForDate)
           lp_Retval = lp_Retval * l_Periods
      CASE ratecode.rc_period = 2
           l_Periods = DayParts(reservat.rs_arrtime, reservat.rs_deptime, reservat.rs_arrdate, reservat.rs_depdate, lp_dForDate)
           lp_Retval = lp_Retval * l_Periods
 ENDCASE
 RETURN lp_Retval
ENDFUNC
*
FUNCTION PostRate
LPARAMETER lp_cPostAlias, lp_cMode, lp_nUnits, lp_nAmount, lp_nAdults, lp_nChilds, lp_nChilds2, lp_nChilds3, lp_nFolioWin, ;
          lp_lChangedRes, lp_lIsOK, lp_lSpecLogin, lp_lUgos, lp_dIfcFrom, lp_dIfcTo, lp_nIfcSetId, lp_cSupplemText, lp_dBDate
LOCAL l_oPost, l_lError, l_lAllow, l_nReserid, l_nFolioWin, l_nSplitSetID, l_cPicklistOrder, l_nPicklistRecNo, l_dForDate, l_cRaAlias, l_lCustomRA, l_cRaWhileClause
LOCAL l_Currencyrate, ceRrortxt, l_Vat, l_Vat2, l_Vatnum, l_Vatpct, l_Vatnum2, l_Vatpct2, l_Mvatnum, l_Mvatpct, l_M2vatnum, l_M2vatpct, l_Marti
LOCAL l_nQty, l_nMainPrice, l_nMainSplitPriceCorr, l_cRatecode, l_cVatMacro1, l_cVatMacro2, l_oData, l_oCARpostifc, l_nRatePct, l_nAmount, l_lUdRate
LOCAL ARRAY l_aWin(1), l_aVat(1), l_aFields(1)
PRIVATE p_cUgosPtt, p_cUgosPtv, p_cUgosInt

l_nPicklistRecNo = RECNO("picklist")
l_cPicklistOrder = ORDER("picklist")
l_cRatecode = ratecode.rc_ratecod + ratecode.rc_roomtyp + DTOS(ratecode.rc_fromdat) + ratecode.rc_season
IF NOT SEEK(l_cRatecode+'1',"ratearti") AND NOT SEEK(STR(reservat.rs_rsid,10)+l_cRatecode+'1', "ResRart", "tag1")
    ceRrortxt = GetLangText("RATES","TA_MAINNOTFOUND") + " " + TRIM(ratecode.rc_ratecod) + ;
        " " + TRIM(ratecode.rc_roomtyp) + " " + DTOC(ratecode.rc_fromdat) + "!"
    = erRormsg("RoomType:" + reservat.rs_roomtyp + " Room:" + reservat.rs_roomnum + " " + ceRrortxt)
    = alErt(ceRrortxt)
    lp_lIsOK = .F.
    RETURN .F.
ENDIF

IF lp_nAdults = 0
    lp_nAdults = 1
ENDIF
l_nReserid = 0
l_nFolioWin = 0
l_Mvatnum = 0
l_Mvatpct = 0
l_M2vatnum = 0
l_M2vatpct = 0
l_Marti = 0

l_nAmount = ratecode.rc_base
IF BETWEEN(lp_nAdults, 1, 5) AND EVALUATE("ratecode.rc_amnt"+STR(lp_nAdults,1)) # 0
    l_nAmount = l_nAmount + EVALUATE("ratecode.rc_amnt"+STR(lp_nAdults,1))
ELSE
    l_nAmount = l_nAmount + ratecode.rc_amnt1 * lp_nAdults
ENDIF
IF lp_nChilds > 0
    l_nAmount = l_nAmount + ratecode.rc_camnt1 * lp_nChilds
ENDIF
IF lp_nChilds2 > 0
    l_nAmount = l_nAmount + ratecode.rc_camnt2 * lp_nChilds2
ENDIF
IF lp_nChilds3 > 0
    l_nAmount = l_nAmount + ratecode.rc_camnt3 * lp_nChilds3
ENDIF
l_lUdRate = (l_nAmount <> lp_nAmount)

STORE REPLICATE("0",10) TO p_cUgosPtt, p_cUgosPtv, p_cUgosInt

l_Currencyrate = 1.00
IF NOT EMPTY(ratecode.rc_paynum) AND SEEK(ratecode.rc_paynum, "paymetho","tag1")
    IF EMPTY(reServat.rs_ratexch)
         l_Currencyrate = IIF(EMPTY(paYmetho.pm_rate), 1.00, paYmetho.pm_rate)
         REPLACE rs_ratexch WITH l_Currencyrate IN reServat
         IF CURSORGETPROP("Buffering","reservat") == 1
             FLUSH
         ELSE
             = TABLEUPDATE(.F.,.T.,"reservat")
         ENDIF
    ELSE
         l_Currencyrate = reServat.rs_ratexch
    ENDIF
ENDIF
SELECT &lp_cPostAlias
= AFIELDS(l_aFields)
CREATE CURSOR tmpRFPost FROM ARRAY l_aFields
l_lCustomRA = SEEK(STR(reservat.rs_rsid,10)+l_cRatecode, "ResRart", "tag1")
l_cRaAlias = IIF(l_lCustomRA, "resrart", "ratearti")
l_cRaWhileClause = IIF(l_lCustomRA, "ra_rsid = " + SqlCnv(reservat.rs_rsid) + " AND ", "")
SELECT &l_cRaAlias
SCAN WHILE &l_cRaWhileClause ra_ratecod = l_cRatecode
    SELECT article
    IF NOT SEEK(&l_cRaAlias..ra_artinum, "article")
        ceRrortxt = GetLangText("RATES","TA_ARNOTFOUND") + " " + ALLTRIM(STR(&l_cRaAlias..ra_artinum,4)) + "!"
        = erRormsg("RoomType:" + reservat.rs_roomtyp + " Room:" + reservat.rs_roomnum + " " + ceRrortxt)
        = alErt(ceRrortxt)
        l_lError = .T.
        EXIT
    ENDIF
    IF g_lFakeResAndPost AND (TYPE("max1") = "D") AND (TYPE("min1") = "D") AND NOT BETWEEN(p_Fordate + article.ar_fcstofs, min1, max1)
        LOOP
    ENDIF
    SELECT picklist
    SET ORDER TO 3
    IF NOT SEEK(PADR("VATGROUP", 10) + STR(article.ar_vat, 3), "picklist")
        ceRrortxt = GetLangText("RATES","TA_VATNOTFOUND") + " " + ALLTRIM(STR(article.ar_vat)) + "!"
        = erRormsg("RoomType:" + reservat.rs_roomtyp + " Room:" + reservat.rs_roomnum + " " + ceRrortxt)
        = alErt(ceRrortxt)
        l_lError = .T.
        EXIT
    ENDIF
    l_Vatnum = article.ar_vat
    l_Vatpct = picklist.pl_numval
    IF article.ar_vat2 > 0
        IF NOT SEEK(PADR("VATGROUP", 10) + STR(article.ar_vat2, 3), "picklist")
             ceRrortxt = GetLangText("RATES","TA_VATNOTFOUND") + " " + LTRIM(STR(article.ar_vat2)) + "!"
             = erRormsg("RoomType:" + reservat.rs_roomtyp + " Room:" + reservat.rs_roomnum + " " + ceRrortxt)
             = alErt(ceRrortxt)
             l_lError = .T.
             EXIT
        ENDIF
        l_Vatnum2 = article.ar_vat2
        l_Vatpct2 = picklist.pl_numval
    ELSE
        l_Vatnum2 = 0
        l_Vatpct2 = 0
    ENDIF
    SET ORDER TO 1 IN "picklist"
    IF &l_cRaAlias..ra_artityp = 1
        l_Mvatnum = l_Vatnum
        l_Mvatpct = l_Vatpct
        l_M2vatnum = l_Vatnum2
        l_M2vatpct = l_Vatpct2
        l_Marti = &l_cRaAlias..ra_artinum
    ENDIF
    SELECT tmpRFPost
    SCATTER NAME l_oPost BLANK
    l_oPost.ps_raid = &l_cRaAlias..ra_raid
    l_oPost.ps_artinum = &l_cRaAlias..ra_artinum
    l_oPost.ps_units = IIF(NOT l_lUdRate AND &l_cRaAlias..ra_package, lp_nUnits, RPGetUnits(lp_nUnits, &l_cRaAlias..ra_onlyon))
    DO CASE
        CASE &l_cRaAlias..ra_artityp = 1
            l_oPost.ps_price = lp_nAmount
            IF lp_lUgos
                 * Set as posting description name of ratecode, and from-to date, for which are interfaces on
                 l_oPost.ps_descrip = ALLTRIM(ratecode.rc_ratecod) + " " + ;
                           TRANSFORM(DAY(lp_dIfcFrom)) + "." + TRANSFORM(MONTH(lp_dIfcFrom)) + "-" + ;
                           TRANSFORM(DAY(lp_dIfcTo)) + "." + TRANSFORM(MONTH(lp_dIfcTo))
            ENDIF
        CASE EMPTY(&l_cRaAlias..ra_amnt) AND NOT EMPTY(&l_cRaAlias..ra_ratepct)
            l_oPost.ps_price = IIF(&l_cRaAlias..ra_pctexma, 0, lp_nAmount) * &l_cRaAlias..ra_ratepct / 100          && If ra_pctexma then calculate price at the end
        OTHERWISE
            l_oPost.ps_price = &l_cRaAlias..ra_amnt
            l_nQty = RrGetUnits(l_cRaAlias, lp_nAdults, lp_nChilds, lp_nChilds2, lp_nChilds3)
            l_oPost.ps_units = l_oPost.ps_units * l_nQty
    ENDCASE
    IF lp_lUgos
        RPCheckInterfac()
    ENDIF
    l_oPost.ps_price = ROUND(l_oPost.ps_price * IIF(&l_cRaAlias..ra_pmlocal,1.00,l_Currencyrate), param.pa_currdec)
    l_oPost.ps_amount = ROUND(l_oPost.ps_units * l_oPost.ps_price,2)  && ps_amount b(8,2)
    IF lp_lSpecLogin
        l_lAllow = .T.
        l_nReserid = reservat.rs_reserid
        l_nFolioWin = lp_nFolioWin
        DO BillNumDate IN ProcBill WITH l_nReserid, l_nFolioWin, l_dForDate
    ELSE
        IF INLIST(&l_cRaAlias..ra_artityp, 1, 3) OR ((l_nReserid = 0) AND (l_nFolioWin = 0))
            l_nReserid = reservat.rs_reserid
            l_nFolioWin = PBGetFreeWindow(reservat.rs_reserid, lp_nFolioWin)
            DO biLlinstr IN BillInst WITH l_oPost.ps_artinum, reservat.rs_billins, l_nReserid, l_nFolioWin
            IF l_nReserid <> reservat.rs_reserid
                 l_oPost.ps_supplem = get_rm_rmname(reservat.rs_roomnum)+" "+MakeProperName(reServat.rs_lname)
                 lp_lChangedRes = .T.
            ENDIF
            l_oPost.ps_supplem = EVL(lp_cSupplemText,l_oPost.ps_supplem)
        ENDIF
        l_aWin(1) = l_nFolioWin
        DO BillsReserCheck IN ProcBill WITH l_nReserid, l_aWin, lp_cMode, l_lAllow
        l_dForDate = SysDate()
    ENDIF
    IF NOT l_lAllow
        l_lError = .T.
        EXIT
    ENDIF
    l_oPost.ps_reserid = l_nReserid
    l_oPost.ps_window = l_nFolioWin
    l_oPost.ps_origid = reservat.rs_reserid
    l_oPost.ps_bdate = EVL(lp_dBDate,{})
    l_oPost.ps_date = IIF(g_lFakeResAndPost, p_Fordate, l_dForDate)
    l_oPost.ps_time = TIME()
    l_oPost.ps_userid = g_Userid
    l_oPost.ps_cashier = 0
    ProcBill("ArticeVatAmounts", l_oPost.ps_artinum, l_oPost.ps_amount, @l_aVat)
    l_cVatMacro1 = "l_oPost.ps_vat" + TRANSFORM(l_aVat(1,1))
    l_cVatMacro2 = "l_oPost.ps_vat" + TRANSFORM(l_aVat(2,1))
    &l_cVatMacro1 = l_aVat(1,2)
    &l_cVatMacro2 = l_aVat(2,2)
    IF lp_cMode = "INVOICE"
        l_oPost.ps_invtype = "R"
        l_oPost.ps_invdate = p_Fordate          && Specialy for invoice, p_Fordate is private variable
    ENDIF
    l_oPost.ps_split = (&l_cRaAlias..ra_artityp = 2)
    l_oPost.ps_ratecod = IIF(&l_cRaAlias..ra_artityp = 3, "", &l_cRaAlias..ra_ratecod)
    IF l_oPost.ps_amount <> 0.00 OR &l_cRaAlias..ra_pctexma AND lp_nAmount * &l_cRaAlias..ra_ratepct / 100 <> 0.00 OR _screen.oGlobal.lUgos
        l_oPost.ps_postid = neXtid('Post')
        SELECT tmpRFPost
        APPEND BLANK
        GATHER NAME l_oPost
    ENDIF
    IF NOT l_lUdRate AND &l_cRaAlias..ra_package
        GO TOP IN tmpRFPost
        l_oPost.ps_price = (tmpRFPost.ps_amount + l_oPost.ps_amount) / tmpRFPost.ps_units
        REPLACE ps_amount WITH tmpRFPost.ps_amount + l_oPost.ps_amount, ps_price WITH l_oPost.ps_price, ;
            ps_vat0 WITH tmpRFPost.ps_vat0 + l_oPost.ps_vat0, ps_vat1 WITH tmpRFPost.ps_vat1 + l_oPost.ps_vat1, ;
            ps_vat2 WITH tmpRFPost.ps_vat2 + l_oPost.ps_vat2, ps_vat3 WITH tmpRFPost.ps_vat3 + l_oPost.ps_vat3, ;
            ps_vat4 WITH tmpRFPost.ps_vat4 + l_oPost.ps_vat4, ps_vat5 WITH tmpRFPost.ps_vat5 + l_oPost.ps_vat5, ;
            ps_vat6 WITH tmpRFPost.ps_vat6 + l_oPost.ps_vat6, ps_vat7 WITH tmpRFPost.ps_vat7 + l_oPost.ps_vat7, ;
            ps_vat8 WITH tmpRFPost.ps_vat8 + l_oPost.ps_vat8, ps_vat9 WITH tmpRFPost.ps_vat9 + l_oPost.ps_vat9 ;
            IN tmpRFPost
    ENDIF
    SELECT &l_cRaAlias
ENDSCAN
IF RECCOUNT("tmpRFPost") > 0
    SELECT tmpRFPost
    SCATTER BLANK NAME l_oPost
    * Prepare main split article
    SUM ps_amount FOR ps_split TO l_nSplitPrice
    SUM ps_amount FOR NOT ps_split AND NOT EMPTY(ps_ratecod) TO l_nMainPrice
    l_nRatePct = RPGetSplitFromMainPct("tmpRFPost", l_cRaAlias, l_lUdRate)
    l_nMainSplitPriceCorr = (l_nMainPrice - l_nSplitPrice) * 100/(100+l_nRatePct)
    SCAN FOR NOT EMPTY(ps_raid) AND IIF(l_lCustomRA, SEEK(STR(reservat.rs_rsid,10)+l_cRatecode+STR(ps_raid,10), "resrart", "tag2"), SEEK(l_cRatecode+STR(ps_raid,10), "ratearti", "tag2")) AND ;
            INLIST(&l_cRaAlias..ra_artityp, 2, 3) AND &l_cRaAlias..ra_ratepct <> 0 AND &l_cRaAlias..ra_pctexma
        l_oPost.ps_price = ROUND(l_nMainSplitPriceCorr/ps_units * &l_cRaAlias..ra_ratepct/100, param.pa_currdec)
        l_oPost.ps_amount = ROUND(l_oPost.ps_price * ps_units, 2)
        ProcBill("ArticeVatAmounts", ps_artinum, l_oPost.ps_amount, @l_aVat)
        l_cVatMacro1 = "ps_vat" + TRANSFORM(l_aVat(1,1))
        l_cVatMacro2 = "ps_vat" + TRANSFORM(l_aVat(2,1))
        l_oPost.&l_cVatMacro1 = l_aVat(1,2)
        l_oPost.&l_cVatMacro2 = l_aVat(2,2)
        GATHER NAME l_oPost FIELDS ps_amount, ps_price, &l_cVatMacro1, &l_cVatMacro2
        IF &l_cRaAlias..ra_artityp = 2
            l_nSplitPrice = l_nSplitPrice + l_oPost.ps_amount
        ENDIF
    ENDSCAN
    GO TOP
    SCATTER NAME l_oPost
    l_oPost.ps_price = ROUND((l_nMainPrice - l_nSplitPrice)/l_oPost.ps_units, param.pa_currdec)
    l_oPost.ps_amount = ROUND(l_oPost.ps_price * l_oPost.ps_units, 2)
    l_oPost.ps_split = .T.
    ProcBill("ArticeVatAmounts", l_oPost.ps_artinum, l_oPost.ps_amount, @l_aVat)
    l_cVatMacro1 = "l_oPost.ps_vat" + TRANSFORM(l_aVat(1,1))
    l_cVatMacro2 = "l_oPost.ps_vat" + TRANSFORM(l_aVat(2,1))
    &l_cVatMacro1 = l_aVat(1,2)
    &l_cVatMacro2 = l_aVat(2,2)
    IF l_oPost.ps_amount <> 0.00 OR _screen.oGlobal.lUgos
        l_oPost.ps_postid = NextId("post")
        SELECT tmpRFPost
        APPEND BLANK
        GATHER NAME l_oPost
    ENDIF
    SELECT tmpRFPost
    SCATTER NAME l_oPost
    SUM ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9 ;
        TO l_oPost.ps_vat0, l_oPost.ps_vat1, l_oPost.ps_vat2, l_oPost.ps_vat3, l_oPost.ps_vat4, l_oPost.ps_vat5, l_oPost.ps_vat6, l_oPost.ps_vat7, l_oPost.ps_vat8, l_oPost.ps_vat9 ;
        FOR ps_split
    LOCATE
    GATHER NAME l_oPost FIELDS ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9
    l_nSplitSetID = NextId('SPLITSET')
    SELECT tmpRFPost
    REPLACE ps_setid WITH l_nSplitSetID FOR NOT EMPTY(ps_ratecod)
    SELECT &lp_cPostAlias
    APPEND FROM DBF("tmpRFPost")
    IF CURSORGETPROP("Buffering",lp_cPostAlias) == 1
        FLUSH
    ELSE
        = TABLEUPDATE(.T.,.T.,lp_cPostAlias)
    ENDIF
    IF CURSORGETPROP("Buffering","pswindow") == 1
        FLUSH
    ELSE
        = TABLEUPDATE(.T.,.T.,"pswindow")
    ENDIF
    IF _screen.oglobal.oparam2.pa_restran
        ProcReservatTransactions("reservat", "EDIT")
    ENDIF
ENDIF

IF lp_lUgos AND (("1" $ p_cUgosPtt) OR ("1" $ p_cUgosPtv) OR ("1" $ p_cUgosInt))
     l_oCARpostifc = CREATEOBJECT("carpostifc")
     IF lp_cMode = "POST_DEL" AND NOT EMPTY(lp_nIfcSetId)
         l_oCARpostifc.cFilterClause = "rk_setid = " + SqlCnv(lp_nIfcSetId, .T.)
         l_oCARpostifc.CursorFill()
         REPLACE rk_dsetid WITH l_nSplitSetID, rk_deleted WITH .T. IN (l_oCARpostifc.Alias)
     ELSE
         l_oCARpostifc.SetProp(.T.,.T.)
         l_oCARpostifc.CursorFill()
         SELECT (l_oCARpostifc.Alias)
         SCATTER NAME l_oData BLANK
         l_oData.rk_rkid = nextid("RPOSTIFC")
         l_oData.rk_rsid = reservat.rs_rsid
         l_oData.rk_setid = l_nSplitSetID
         l_oData.rk_pttcls = p_cUgosPtt
         l_oData.rk_ptvcls = p_cUgosPtv
         l_oData.rk_intcls = p_cUgosInt
         l_oData.rk_from = lp_dIfcFrom
         l_oData.rk_to = lp_dIfcTo
         INSERT INTO (l_oCARpostifc.Alias) FROM NAME l_oData

         l_oCAResifcin = CREATEOBJECT("caresifcin")
         l_oCAResifcin.cFilterClause = "rn_rsid = " + SqlCnv(reservat.rs_rsid, .T.)
         l_oCAResifcin.CursorFill()
         IF RECCOUNT(l_oCAResifcin.Alias) = 0
             INSERT INTO (l_oCAResifcin.Alias) (rn_rsid, rn_pin, rn_pttcls, rn_ptvcls, rn_intcls) ;
                 VALUES (reservat.rs_rsid, GeneratePin(), REPLICATE("1",10), REPLICATE("1",10), REPLICATE("1",10))
         ENDIF
         l_oCAResifcin.DoTableUpdate(,.T.)
     ENDIF
     l_oCARpostifc.DoTableUpdate()
     l_oCARpostifc.DClose()
ENDIF

CloseFile("tmpRFPost")
GO l_nPicklistRecNo IN picklist
SET ORDER TO (l_cPicklistOrder) IN picklist
lp_lIsOK = NOT l_lError
RETURN lp_lIsOK
*
PROCEDURE RPGetMainArtiNum
LPARAMETERS lp_dfOrdate, lp_nArtiNum
* In PRIVATE p_oResRate is reference to resrate SCATTER object
LOCAL l_nArtiNum, l_nAdults, l_cMacroExp, l_lRRUpdateCall
l_nArtiNum = 0
IF NOT param2.pa_radetai OR ratearti.ra_artityp<>1
     l_nArtiNum = ratearti.ra_artinum
ELSE
     l_lRRUpdateCall = PCOUNT()>1
     IF l_lRRUpdateCall
          lp_dfOrdate = p_oResRate.rr_date
     ENDIF
     l_nAdults = RPGetNoOfAdults(lp_dfOrdate,,l_lRRUpdateCall)
     IF RPManualPriceChange(lp_dfOrdate,,l_lRRUpdateCall)
          l_cMacroExp = "ratearti.ra_artchng"
     ELSE
          l_lWeekend = RPIsWeekendRate(lp_dfOrdate)
          l_cMacroExp = "ratearti.ra_artin" + IIF(l_lWeekend,"c","u") + ALLTRIM(STR(l_nAdults))
     ENDIF
     TRY
          l_nArtiNum = EVALUATE(l_cMacroExp)
     CATCH
     ENDTRY
     IF EMPTY(l_nArtiNum)
          l_nArtiNum = ratearti.ra_artinum
     ENDIF
ENDIF
lp_nArtiNum = l_nArtiNum
RETURN l_nArtiNum
ENDPROC
*
PROCEDURE RPGetSplitFromMainPct
LPARAMETERS lp_curPost, lp_cRaAlias, lp_lUdRate
LOCAL l_nRatePct, l_lUdRate

lp_cRaAlias = EVL(lp_cRaAlias, "ratearti")
l_nRatePct = 0
SELECT &lp_curPost
SCAN FOR ps_split AND NOT EMPTY(ps_raid) AND SEEK(IIF(LOWER(lp_cRaAlias) = "ratearti","",STR(reservat.rs_rsid,10))+ps_ratecod+STR(ps_raid,10), lp_cRaAlias, "tag2") AND ;
          (lp_lUdRate OR NOT &lp_cRaAlias..ra_package) AND &lp_cRaAlias..ra_ratepct <> 0 AND &lp_cRaAlias..ra_pctexma
     l_nRatePct = l_nRatePct + &lp_cRaAlias..ra_ratepct
ENDSCAN

RETURN l_nRatePct
ENDPROC
*
PROCEDURE RPPostResFix
 * Post resfixs for defined day in resfix table, indepented of rythm of ratecode.
 LPARAMETERS lp_dForDate, lp_lCheckResfixForAllPeriod
 LOCAL l_lRFChangeDetected, l_dRFDate, l_dRFEnd, l_nSelect
 IF lp_dForDate >= reservat.rs_rfixdat
      IF lp_dForDate < reservat.rs_depdate OR lp_dForDate = reservat.rs_depdate AND ;
                (reservat.rs_arrdate = reservat.rs_depdate OR lp_lCheckResfixForAllPeriod AND reservat.rs_rfixdat < reservat.rs_depdate-1)
           l_nSelect = SELECT()
           l_dRFDate = MAX(reservat.rs_arrdate, SysDate(), reservat.rs_rfixdat+1)
           l_dRFEnd = MIN(MAX(reservat.rs_arrdate, reservat.rs_depdate-1), lp_dForDate)
           DO WHILE l_dRFDate <= l_dRFEnd
               DO PostResfix IN ResFix WITH l_dRFDate,"post",,.T.
               IF NOT l_lRFChangeDetected
                    l_lRFChangeDetected = .T.
               ENDIF
               l_dRFDate = l_dRFDate + 1
           ENDDO
           IF l_lRFChangeDetected
                IF CURSORGETPROP("Buffering","reservat") == 1
                    FLUSH
                ELSE
                    = TABLEUPDATE(.T.,.T.,"reservat")
                ENDIF
           ENDIF
           SELECT (l_nSelect)
      ENDIF
 ENDIF
ENDPROC
*
PROCEDURE RPGetNoOfAdults
LPARAMETERS lp_dForDate, lp_Retval, lp_lRRUpdateCall
 LOCAL l_Periods, l_nRecNo
 lp_Retval = 1
 
 IF lp_lRRUpdateCall
      lp_Retval = p_oResRate.rr_adults
 ELSE
      l_nRecNo = RECNO("resrate")
      IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(lp_dForDate), "resrate", "tag2")
           lp_Retval = resrate.rr_adults
      ELSE
           lp_Retval = reservat.rs_adults
      ENDIF
      GO l_nRecNo IN resrate
 ENDIF
 
 DO CASE
      CASE lp_Retval < 1
           lp_Retval = 1
      CASE lp_Retval > 5
           lp_Retval = 5
 ENDCASE
RETURN lp_Retval
ENDFUNC
*
PROCEDURE RPIsWeekendRate
LPARAMETERS dfOrdate
 LOCAL l_lWeekendRate, dResArrDate
 dResArrDate = reservat.rs_arrdate
 l_lWeekendRate = SUBSTR(ratecode.rc_weekend, DOW(dfOrdate, 2), 1) = '1' AND ;
      SUBSTR(ratecode.rc_closarr, DOW(dResArrDate, 2), 1) = ' '
RETURN l_lWeekendRate
ENDPROC
*
PROCEDURE RPManualPriceChange
LPARAMETERS lp_dForDate, lp_Retval, lp_lRRUpdateCall
 LOCAL l_Periods, l_nRecNo
 lp_Retval = .F.
 IF lp_lRRUpdateCall
      lp_Retval = INLIST(p_oResRate.rr_status, "OUS", "ORU", "OFF")
 ELSE
      l_nRecNo = RECNO("resrate")
      IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(lp_dForDate), "resrate", "tag2")
           lp_Retval = INLIST(resrate.rr_status, "OUS", "ORU", "OFF")
      ELSE
           lp_Retval = ("*" $ reservat.rs_ratecod)
      ENDIF
      GO l_nRecNo IN resrate
 ENDIF
RETURN lp_Retval
ENDPROC
*
PROCEDURE RPCheckInterfac
IF ALLTRIM(article.ar_user3)="PTT"
     p_cUgosPtt = STUFF(p_cUgosPtt,1,1,"1") && Phone
ENDIF
IF ALLTRIM(article.ar_user3)="PTVC"
     p_cUgosPtv = STUFF(p_cUgosPtv,1,1,"1") && PayTV Cable
     p_cUgosPtv = STUFF(p_cUgosPtv,5,1,"1") && PayTV Movies
ENDIF
IF ALLTRIM(article.ar_user3)="PTVA"
     p_cUgosPtv = STUFF(p_cUgosPtv,2,1,"1") && PayTV XXX
     p_cUgosPtv = STUFF(p_cUgosPtv,5,1,"1") && PayTV Movies
ENDIF
IF ALLTRIM(article.ar_user3)="PTVV"
     p_cUgosPtv = STUFF(p_cUgosPtv,3,1,"1") && PayTV Video on demand
ENDIF
IF ALLTRIM(article.ar_user3)="PTVI"
     p_cUgosPtv = STUFF(p_cUgosPtv,4,1,"1") && PayTV Internet
ENDIF
IF ALLTRIM(article.ar_user3)="INT"
     p_cUgosInt = STUFF(p_cUgosInt,1,1,"1") && WiFi Internet
ENDIF
ENDPROC
*
PROCEDURE RPGetUnits
LPARAMETERS lp_nUnits, lp_nOnlyOn
LOCAL l_nUnits
IF lp_nOnlyOn > 0 AND ratecode.rc_period = 3
     * Post only once
     l_nUnits = SIGN(lp_nUnits)
ELSE
     l_nUnits = lp_nUnits
ENDIF
RETURN l_nUnits
ENDPROC
*
PROCEDURE RPGetFiscalPrinterArticleDescription
LOCAL l_cText
l_cText = "@"+PADL(ratecode.rc_rcid,3,"0")+PADL(article.ar_artinum,2,"0")+"|"+PADL(ratecode.rc_ratecod,10) + PADL(ratecode.rc_rcid,3,"0") + PADL(get_rt_roomtyp(ratecode.rc_roomtyp),7) + ;
          PADR(EVALUATE("article.ar_lang" + GetHotelLangNum()),12)
RETURN l_cText
ENDPROC