 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13, lp_uParam14, lp_uParam15
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal

 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO PCOUNT()-1
	l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"

 l_uRetVal = &l_cCallProc

 RETURN l_uRetVal
ENDFUNC
*
FUNCTION BillHistory
	doform('billhist', 'forms\billhistory')
	RETURN .T.
ENDFUNC
*
FUNCTION PrintCopy
 PARAMETER p_Reserid, p_Window, p_Preview, pnStyle, plUseBDateInStyle, pnAddrid, pcBillIns, lp_cbillfrxname, lp_lNoPrintPrompt, lp_lNoSetStatus, lp_leInvoice
 LOCAL ARRAY l_aReportHeader(7)
 PRIVATE ALL LIKE l_*
 PRIVATE lArtForClause, lBillHistory, lFromPostCxl
 PRIVATE g_Billnum
 LOCAL l_nArea, l_Frx, l_nAddrId, l_nApId, l_lLogis7PctVAT, l_cLang, l_cPrintPrompt
 LOCAL l_cRcOrder, l_cArOrder, l_cPmOrder, l_cAccomp, l_Psrec, l_Rsrec, l_Hprec, l_Hrrec, l_lSuccess, l_lHistory

 l_nArea = SELECT()
 lFromPostCxl = .f.
 lp_cbillfrxname = EVL(lp_cbillfrxname, "Bill1.Frx")
 STORE "" TO l_cArPayDescriptionText, l_cArPayDiscountText

 l_Psrec = RECNO("post")
 l_Rsrec = RECNO("reservat")
 l_Hprec = RECNO("histpost")
 l_Hrrec = RECNO("histres")
 DO WHILE .T.
      IF NOT USED("hresext")
           OpenFile(,"hresext")
      ENDIF
      IF (p_Reserid = histres.hr_reserid OR SEEK(p_Reserid, "histres", "tag1")) AND p_Reserid <> hresext.rs_reserid
           = SEEK(p_Reserid, "hresext", "tag1")
      ENDIF
      IF p_Reserid <> reservat.rs_reserid
           = SEEK(p_Reserid, "reservat", "tag1")
      ENDIF
      DO CASE
           CASE p_Reserid = reservat.rs_reserid AND DLocate("post", "ps_reserid = " + SqlCnv(p_Reserid,.T.) + " AND NOT ps_cancel AND ps_window = "+ SqlCnv(p_Window,.T.))
           CASE p_Reserid = histres.hr_reserid AND DLocate("histpost", "hp_reserid = " + SqlCnv(p_Reserid,.T.) + " AND NOT hp_cancel AND hp_window = "+ SqlCnv(p_Window,.T.))
                l_lHistory = .T.
           OTHERWISE
                EXIT
      ENDCASE
      IF NOT USED("picklist")
           OpenFile(,"picklist")
      ENDIF
      IF NOT USED("lists")
           OpenFile(,"lists")
      ENDIF
      IF NOT USED("ratearti")
           OpenFile(,"ratearti")
      ENDIF
      IF NOT USED("resrart")
           OpenFile(,"resrart")
      ENDIF
      IF l_lHistory AND NOT USED("hresrart")
           OpenFile(,"hresrart")
      ENDIF
      IF NOT USED("article")
           OpenFile(,"article")
      ENDIF
      l_cRcOrder = ORDER("ratecode")
      l_cArOrder = ORDER("article")
      l_cPmOrder = ORDER("paymetho")
      SET ORDER TO tag1 IN ratecode
      SET ORDER TO tag1 IN article
      SET ORDER TO tag1 IN paymetho

      l_Adrec = RECNO("address")
      = SEEK(IIF(l_lHistory, histres.hr_addrid, reservat.rs_addrid), "Address", "tag1")
      g_Billname = ""
      IF p_Window<>1
           IF NOT EMPTY(adDress.ad_fname) OR NOT EMPTY(adDress.ad_lname)
                g_Billname = ALLTRIM(adDress.ad_title) + " " + ALLTRIM(adDress.ad_fname) + " " + ALLTRIM(FlIp(adDress.ad_lname))
           ENDIF
           *pnAddrid = VAL(SUBSTR(MLINE(pcBillIns, IIF(p_Window>3, p_Window+1, p_Window)), 1, 12))     && pnAddrid = bn_addrid, not need retrieve from billins
           IF NOT EMPTY(pnAddrid)
                =SEEK(pnAddrid, "address", "tag1")
           ENDIF
      ENDIF
      l_Frx = gcReportdir+lp_cbillfrxname

      IF p_Window<>1 AND _screen.oglobal.oparam.pa_accomp == "11"
           l_cAccomp = ALLTRIM(IIF(l_lHistory, hresext.rs_sname, reservat.rs_sname))
           IF NOT EMPTY(l_cAccomp)
                g_Billname = g_Billname + " / " + PROPER(l_cAccomp)
           ENDIF
      ENDIF
      g_Billnum = FNGetBillData(IIF(l_lHistory, histres.hr_reserid, reservat.rs_reserid), p_Window, "bn_billnum")
      lBillHistory = NOT EMPTY(g_Billnum)
      STORE 1 TO nBillstyle, g_Billdupl
      g_dBillDate = DbLookup("billnum", "tag1", g_BillNum, "bn_date")
      IF _screen.oGlobal.lfiskaltrustactive
           _screen.oGlobal.cfiskaltrustqrcode = ALLTRIM(DbLookup("billnum", "tag1", g_BillNum, "bn_qrcode"))
      ENDIF
      l_lLogis7PctVAT = ProcBill("ChangeVATGetProp", "EXVCLOGIS7PCT", g_dBillDate)
      IF l_lLogis7PctVAT
           * Only for bills older then 1.1.2010. dont show splitted articles
           l_lLogis7PctVAT = (g_dBillDate >= _screen.oGlobal.oBill.dVatCutDate)
      ENDIF

      IF l_lLogis7PctVAT
           IF _screen.oGlobal.oParam2.pa_zearbil
                * Show postings with zero amount on bill. Don't show postings from DUM ratecode.
                lArtForClause = "(EMPTY(hp_ratecod) OR (hp_split AND NOT LEFT(hp_ratecod,10)==[DUM       ]))"
           ELSE
                lArtForClause = "((EMPTY(hp_ratecod) OR hp_split) AND hp_amount <> 0)"
           ENDIF
      ELSE
           lArtForClause = "NOT hp_split"
      ENDIF
      lArtForClause = IIF(l_lHistory, lArtForClause, STRTRAN(lArtForClause,"hp_","ps_"))

      DO BillStyle IN PrntBill WITH p_Reserid, p_Window, l_lHistory, pnStyle, plUseBDateInStyle, UPPER(LEFT(lp_cbillfrxname,8)) = 'BILLCPY1'
      l_cLang = IIF(_screen.oGlobal.oParam.pa_billlng AND NOT EMPTY(address.ad_lang), ALLTRIM(address.ad_lang), g_Language)
      DO PBSetReportLanguage IN PrntBill WITH l_cLang     &&PBSetReportLanguage(l_cLang)
      l_Langdbf = STRTRAN(UPPER(l_Frx), '.FRX', '.DBF')
      IF FILE(l_Langdbf)
           USE SHARED NOUPDATE (l_Langdbf) ALIAS rePtext IN 0
      ENDIF
      DO BillReportHeader IN ProcBill WITH l_lHistory, p_Window, l_aReportHeader
      l_cTitle = l_aReportHeader(1)
      l_cDepartment = l_aReportHeader(2)
      l_cName = l_aReportHeader(3)
      l_cStreet1 = l_aReportHeader(4)
      l_cStreet2 = l_aReportHeader(5)
      l_cCity = l_aReportHeader(6)
      l_cCountry = l_aReportHeader(7)

      IF l_lHistory
           DO BillAddrId IN procbill WITH p_Window, histres.hr_rsid, histres.hr_addrid, l_nAddrId
           l_nApId = IIF(INLIST(p_Window, 1, 2), histres.hr_apid, 0)
      ELSE
           DO BillAddrId IN procbill WITH p_Window, reservat.rs_rsid, reservat.rs_addrid, l_nAddrId
           l_nApId = IIF(INLIST(p_Window, 1, 2), reservat.rs_apid, 0)
      ENDIF
      _screen.oGlobal.oBill.nAddrId = l_nAddrId
      _screen.oGlobal.oBill.nApId = l_nApId
      _screen.oGlobal.oBill.nReserId = p_Reserid
      _screen.oGlobal.oBill.nWindow = p_Window
      _screen.oGlobal.oBill.cArtForClause = lArtForClause
      _screen.oGlobal.oBill.SetUser(g_Billnum)
      _screen.oGlobal.oBill.SetElPaySlip(g_Billnum, l_lHistory)
      DO PBSetBillType IN PrntBill     &&PBSetBillType()
      SELECT TempPost
      _screen.oGlobal.oBill.lActive = .T.
      PrintReport(l_Frx,,,,"ZUGFERD",,"TempPost")
      IF NOT lp_leInvoice
           PrintReport(l_Frx, NOT p_Preview, lp_lNoPrintPrompt, lp_lNoSetStatus,,,"TempPost")
      ENDIF
      _screen.oGlobal.oBill.lActive = .F.
      IF p_Preview AND g_lUseNewRepPreview
           _screen.oGlobal.oBill.nAddrId = 0
           _screen.oGlobal.oBill.nApId = 0
      ENDIF
      _screen.oGlobal.oBill.ResetElPaySlip()
      DCLose('TempPost')
      DCLose('RepText')
      SELECT hiStpost
      SET RELATION TO
      SET ORDER TO l_cRcOrder IN ratecode
      SET ORDER TO l_cArOrder IN article
      SET ORDER TO l_cPmOrder IN paymetho
      GOTO l_Adrec IN "address"
      l_lSuccess = .T.
      EXIT
 ENDDO
 GOTO l_Psrec IN "post"
 GOTO l_Rsrec IN "reservat"
 GOTO l_Hprec IN "histpost"
 GOTO l_Hrrec IN "histres"

 SELECT (l_nArea)

 RETURN l_lSuccess
ENDFUNC
*
FUNCTION PrintPassCopy
LPARAMETERS lp_nBillNum, lp_lPreview, lp_leInvoice
 LOCAL l_nArea, l_lHistory
 l_nArea = SELECT()
 SELECT hp_addrid AS ps_addrid, ;
           hp_amount AS ps_amount, ;
           hp_artinum AS ps_artinum, ;
           hp_billnum AS ps_billnum, ;
           hp_cancel AS ps_cancel, ;
           hp_cashier AS ps_cashier, ;
           hp_currtxt AS ps_currtxt, ;
           hp_date AS ps_date, ;
           hp_descrip AS ps_descrip, ;
           hp_fibdat AS ps_fibdat, ;
           hp_ifc AS ps_ifc, ;
           hp_note AS ps_note, ;
           hp_origid AS ps_origid, ;
           hp_paynum AS ps_paynum, ;
           hp_postid AS ps_postid, ;
           hp_price AS ps_price, ;
           hp_prtype AS ps_prtype, ;
           hp_ratecod AS ps_ratecod, ;
           hp_reserid AS ps_reserid, ;
           hp_setid AS ps_setid, ;
           hp_split AS ps_split, ;
           hp_supplem AS ps_supplem, ;
           hp_time AS ps_time, ;
           hp_units AS ps_units, ;
           hp_userid AS ps_userid, ;
           hp_vat0 AS ps_vat0, ;
           hp_vat1 AS ps_vat1, ;
           hp_vat2 AS ps_vat2, ;
           hp_vat3 AS ps_vat3, ;
           hp_vat4 AS ps_vat4, ;
           hp_vat5 AS ps_vat5, ;
           hp_vat6 AS ps_vat6, ;
           hp_vat7 AS ps_vat7, ;
           hp_vat8 AS ps_vat8, ;
           hp_vat9 AS ps_vat9, ;
           hp_window AS ps_window ;
           FROM histpost ;
           WHERE hp_reserid == 0.1 AND ;
           hp_billnum == lp_nBillNum ;
           INTO CURSOR query1
 IF RECCOUNT()==0
      l_lHistory = .F.
      USE
      SELECT * FROM post ;
                WHERE ps_reserid == 0.1 AND ;
                ps_billnum == lp_nBillNum ;
                INTO CURSOR query1
 ELSE
       l_lHistory = .T.
 ENDIF
 DO CursorPrintBillCreate IN ProcBill WITH "query"
 APPEND FROM DBF("query1")
 DClose("query1")
 SET RELATION TO query.ps_ratecod INTO ratecode
 SET RELATION TO query.ps_artinum INTO article ADDITIVE
 SET RELATION TO query.ps_paynum INTO paymetho ADDITIVE
 g_BillNum = lp_nBillNum
 g_BillName = ""
 g_dBillDate = DbLookup("billnum", "tag1", g_BillNum, "bn_date")
 IF _screen.oGlobal.lfiskaltrustactive
      _screen.oGlobal.cfiskaltrustqrcode = ALLTRIM(DbLookup("billnum", "tag1", g_BillNum, "bn_qrcode"))
 ENDIF
 DO PrintPassBill IN Passerby WITH 1, lp_lPreview, lp_leInvoice, l_lHistory
 SELECT query
 SET RELATION TO
 USE
 SELECT(l_nArea)
ENDFUNC
*
FUNCTION IsBill
 PARAMETER pnReserid, pnWindow, lRet, pnBillNum
 LOCAL nArea, nHpOrd, nHpRec, cFor
 lrEt = .F.
 cFor = ""
 IF pnReserId == 0.1
      IF EMPTY(pnBillNum) OR pnWindow <> 1
           RETURN lRet
      ELSE
           cFor = " AND hp_billnum = " + SqlCnv(pnBillNum)
      ENDIF
 ENDIF
 naRea = SELECT()
 SELECT hiStpost
 nhPord = ORDER()
 nhPrec = RECNO()
 SET ORDER TO tag1
 IF SEEK(pnReserid)
      LOCATE REST FOR NOT hp_cancel AND hp_window = pnWindow &cFor ;
                WHILE hp_reserid = pnReserid
      lrEt = FOUND()
 ENDIF
 GOTO nhPrec
 SET ORDER TO nHpOrd
 IF NOT lrEt
       cFor = " AND ps_billnum = " + SqlCnv(pnBillNum)
       SELECT post
       nhPord = ORDER()
       nhPrec = RECNO()
       SET ORDER TO tag1
       IF SEEK(pnReserid)
            LOCATE REST FOR NOT ps_cancel AND ps_window = pnWindow &cFor ;
                      WHILE ps_reserid = pnReserid
            lrEt = FOUND()
       ENDIF
       GOTO nhPrec
       SET ORDER TO nHpOrd
 ENDIF
 SELECT (naRea)
 RETURN lrEt
ENDFUNC
*