#INCLUDE "include\constdefines.h"
#DEFINE MAX_BILLSTYLE       18
#DEFINE SAGROUP_ARTINUM     9999
*
 LPARAMETERS nrEserid, nbIllwindow, lpReview, ncOpies, plCheckout, lp_nAyID, lp_nBillType, ;
           lp_lDontAskForBillClose, lp_cbillfrxname, lp_lFromPostCxl, lp_lDontPrint
 PRIVATE naRea
 LOCAL l_cLang, l_nCopy, l_nPostings
 LOCAL ARRAY l_aReportHeader(7)
 LOCAL naDdressid, l_nAddrId, lChangeVAT, cPickListTmp, l_lDontPrint, l_lLogis7PctVAT, l_nRecNoLists, l_cPostAlias
 PRIVATE l_cTitle, l_cDepartment, l_cName, l_cStreet1, l_cStreet2, l_cCity, l_cCountry, l_cArPayDescriptionText, l_cArPayDiscountText, l_cBnOrder
 PRIVATE naDdrrecord
 PRIVATE ncOunter
 PRIVATE cfRxname
 PRIVATE nBillstyle, lBillHistory, lUseBookingDate, lFromPostCxl
 PRIVATE npOstrecord
 PRIVATE ntHisposting
 PRIVATE ntHisaddress
 PRIVATE ntHisreservat
 PRIVATE ctExtline
 PRIVATE cfXp
 PRIVATE laSktype, lcReditnote, llEdger, lArtForClause
 PRIVATE clAngdbf
 PRIVATE amYprinters, cdEfaultprinter, npRintercount, i
 PRIVATE ctMpfrx, ctMpfrt, l_Report
 
 STORE "" TO l_cArPayDescriptionText, l_cArPayDiscountText, l_Report
 STORE 0 TO nBillstyle
 lBillHistory = .F.
 lUseBookingDate = .F.
 lFromPostCxl = lp_lFromPostCxl
 l_cPostAlias = IIF(lp_lFromPostCxl, "postcxl", "post")
 
 naRea = SELECT()
 IF NOT USED("ratearti")
      = openfile(.F.,"ratearti")
 ENDIF
 IF NOT USED("resrart")
      = openfile(.F.,"resrart")
 ENDIF
 IF NOT USED("histres")
      = openfile(.F.,"histres")
 ENDIF
 SELECT reServat
 noRder = ORDER()
 IF (EOF())
      ctExtline = "Reservat EOF before printing bill"
      IF (FILE("Hotel.Dbg"))
           WAIT WINDOW NOWAIT ctExtline
      ENDIF
 ENDIF
 = reLations()
 SELECT reServat
 SET ORDER TO 1
 SEEK nrEserid
 SET ORDER TO nOrder
 SELECT (naRea)
 g_Billdupl = 0
 naRea = SELECT()
 g_Billname = ""
 IF (nbIllwindow<>1)
      IF NOT EMPTY(adDress.ad_fname) OR NOT EMPTY(adDress.ad_lname)
           g_Billname = TRIM(adDress.ad_title)+" "+TRIM(adDress.ad_fname)+" "+ ;
                        TRIM(flIp(adDress.ad_lname))
      ENDIF
      IF _screen.oglobal.oparam.pa_accomp == "11" AND NOT EMPTY(reservat.rs_sname)
           g_Billname = g_Billname + " / " + ALLTRIM(PROPER(reservat.rs_sname))
      ENDIF
      naDdressid = FNGetWindowData(reservat.rs_rsid, nbIllwindow, "pw_addrid")
      IF ( .NOT. EMPTY(naDdressid))
           naDdrrecord = RECNO("Address")
           IF ( .NOT. SEEK(naDdressid, "Address", "tag1"))
                GOTO naDdrrecord IN "Address"
           ENDIF
      ENDIF
 ENDIF
 IF lFromPostCxl
      l_cBnOrder = ORDER("billnum")
      SET ORDER TO tag1 IN billnum DESCENDING 
      g_BillNum = DLookUp("billnum", "bn_reserid = " + sqlcnv(nReserId) + " AND bn_window = " + sqlcnv(nbIllwindow) + " AND bn_status = 'CXL'", "bn_billnum")
      g_dBillDate = DLookUp("billnum", "bn_reserid = " + sqlcnv(nReserId) + " AND bn_window = " + sqlcnv(nbIllwindow) + " AND bn_status = 'CXL'", "bn_date")
      IF _screen.oGlobal.lfiskaltrustactive
           _screen.oGlobal.cfiskaltrustqrcode = ALLTRIM(DLookUp("billnum", "bn_reserid = " + sqlcnv(nReserId) + " AND bn_window = " + sqlcnv(nbIllwindow) + " AND bn_status = 'CXL'", "bn_qrcodec"))
      ENDIF
      SET ORDER TO (l_cBnOrder) IN billnum
 ELSE
      g_dBillDate = FNGetBillData(reservat.rs_reserid, nBillWindow, "bn_date")
 ENDIF
 l_lLogis7PctVAT = ProcBill("ChangeVATGetProp", "EXVCLOGIS7PCT", IIF(EMPTY(g_dBillDate),sysdate(),g_dBillDate))
 IF l_lLogis7PctVAT AND NOT EMPTY(g_dBillDate)
      * Only for bills older then 1.1.2010. dont show splitted articles
      l_lLogis7PctVAT = (g_dBillDate >= _screen.oGlobal.oBill.dVatCutDate)
 ENDIF
 IF l_lLogis7PctVAT
      IF _screen.oGlobal.oParam2.pa_zearbil
           * Show postings with zero amount on bill. Don't show postings from DUM ratecode.
           lArtForClause = "(EMPTY(ps_ratecod) OR (ps_split AND NOT LEFT(ps_ratecod,10)==[DUM       ]))"
      ELSE
           lArtForClause = "((EMPTY(ps_ratecod) OR ps_split) AND ps_amount <> 0)"
      ENDIF
 ELSE
      lArtForClause = "NOT ps_split"
 ENDIF
 = biLlstyle(nrEserid,nbIllwindow)
 l_cLang = IIF(_screen.oGlobal.oParam.pa_billlng AND NOT EMPTY(address.ad_lang), ALLTRIM(address.ad_lang), g_Language)
 l_Report = ADDBS(gcReportdir)+TRANSFORM(lp_cbillfrxname)
 cfRxname = geTbillfrx(l_cLang, lp_cbillfrxname)
 ctMpfrx = ''
 ctMpfrt = ''
 DO CASE
      CASE  .NOT. FILE(cfRxname)
           = alErt(cfRxname,GetLangText("PRNTBILL","TXT_FILENOTFOUND"))
      CASE  .NOT. chEcklayout(cfRxname,@ctMpfrx,@ctMpfrt)
      OTHERWISE
           lChangeVAT = ProcBill("ChangeVAT", reservat.rs_depdate, @cPickListTmp, "", .T.)
           PBSetReportLanguage(l_cLang)
           clAngdbf = STRTRAN(UPPER(cfRxname), '.FRX', '.DBF')
           IF FILE(clAngdbf)
                USE SHARED NOUPDATE (clAngdbf) ALIAS rePtext IN 0
           ENDIF
           ntHisone = SELECT()
           SELECT teMppost
           l_nPostings = 0
           COUNT ALL TO l_nPostings
           SELECT &l_cPostAlias
           npOstrecord = RECNO(l_cPostAlias)
           IF l_nPostings > 0 AND IIF(lFromPostCxl, DLocate("postcxl", "ps_rsid = " + SqlCnv(reservat.rs_rsid) + " AND ps_window = " + SqlCnv(nBillWindow) + " AND " + lArtForClause), ;
                     DLocate("post", "ps_reserid = " + SqlCnv(nReserid) + " AND ps_window = " + SqlCnv(nBillWindow) + " AND NOT ps_cancel AND " + lArtForClause))
                IF (USED("TempPost"))
                     SELECT teMppost
                     GOTO TOP IN "TempPost"
                ENDIF
                IF NOT lFromPostCxl
                     g_BillNum = ALLTRIM(FNGetBillData(nReserId, nbIllwindow, "bn_billnum"))
                     IF _screen.oGlobal.lfiskaltrustactive
                          _screen.oGlobal.cfiskaltrustqrcode = ALLTRIM(FNGetBillData(nReserId, nbIllwindow, "bn_qrcode"))
                     ENDIF
                ENDIF
                IF EMPTY(g_BillNum)
                     * Check it in billnum table too! Fix ugly bug, that billnum was not written in rs_billnrX field.
                     g_BillNum = dlookup("billnum", ;
                               "bn_reserid = " + sqlcnv(nReserId) + " AND bn_window = " + sqlcnv(nbIllwindow) + ;
                               " AND bn_status = 'PCO'", ;
                               "bn_billnum")
                ENDIF
                DO BillReportHeader IN ProcBill WITH .F., nbIllwindow, l_aReportHeader
                l_cTitle = l_aReportHeader(1)
                l_cDepartment = l_aReportHeader(2)
                l_cName = l_aReportHeader(3)
                l_cStreet1 = l_aReportHeader(4)
                l_cStreet2 = l_aReportHeader(5)
                l_cCity = l_aReportHeader(6)
                l_cCountry = l_aReportHeader(7)
                DO BillAddrId IN procbill WITH nbIllwindow,reservat.rs_rsid, ;
                          reservat.rs_addrid, l_nAddrId
                _screen.oGlobal.oBill.nAddrId = l_nAddrId
                _screen.oGlobal.oBill.nApId = IIF(INLIST(nbIllwindow, 1, 2), reservat.rs_apid, 0)
                _screen.oGlobal.oBill.nReserId = nrEserid
                _screen.oGlobal.oBill.nWindow = nbIllwindow
                _screen.oGlobal.oBill.cArtForClause = lArtForClause
                _screen.oGlobal.oBill.cProformaInvoiceNo = STRTRAN(STRTRAN(TRANSFORM(_screen.oGlobal.oBill.nReserId),",","-"),".","-")+;
                          "-"+TRANSFORM(dlookup("id","id_code = 'DOCUMENT'","id_last")+1)
                _screen.oGlobal.oBill.SetUser(g_BillNum)
                _screen.oGlobal.oBill.SetElPaySlip()
                DO BillArPaymentDetails IN ProcBill WITH l_cArPayDescriptionText, l_cArPayDiscountText, l_nAddrId ;
                     ,.F., lp_nAyID
                _screen.oGlobal.oBill.lActive = .T.
                IF (lpReview)
                     g_Billdupl = 1
                     g_nLastFiscalBillNr = 0
                     PBSetBillType(lp_nBillType)
                     IF (g_Demo .OR. glTraining)
                          glInreport = .T.
                          REPORT FORM (ctMpfrx) PREVIEW HEADING  ;
                                 REPLICATE(UPPER(gcApplication)+ ;
                                 IIF(g_Demo, " DEMO VERSION... ",  ;
                                 " TRAININGS VERSION... "), 3) NOCONSOLE  ;
                                 FOR ( .NOT. ps_cancel .AND. &lArtForClause) ;
                                 WHILE (ps_reserid=nrEserid  ;
                                 .AND. ps_window=nbIllwindow)
                          glErrorinreport = .F.
                          glInreport = .F.
                          DO seTstatus IN Setup
                     ELSE
                          PrintReport(ctMpfrx,,,,,,"TempPost")
                     ENDIF
                ELSE
                     LOCAL l_cAlias, l_cAction, l_nBalance, l_nAmount, l_nApId, l_nAddrId, ;
                               l_nPayNum, l_cOldTmpFrx, l_nSelected
                     l_cAlias = ALIAS()
                     l_cAction = IIF(plCheckout, "CHKOUT", "PRINT")
                     DO BillAmount IN ProcBill WITH l_nAmount, l_cAlias, ;
                             nReserId, nBillWindow, lArtForClause
                     l_nBalance = Balance(nrEserid, nbIllwindow)
                     IF EMPTY(g_BillNum)
                        IF plCheckout OR (l_nBalance==0 AND ;
                                  (lp_lDontAskForBillClose OR YesNo(GetLangText("PRNTBILL","TXT_BILL_CHKOUT"))))
                          IF FPBillPrinted("RESERVATION", nrEserid, nbIllwindow)
                               laSktype = .T.
                               llEdger = (dlOokup('Paymetho','pm_paynum = '+ ;
                                         sqLcnv(FNGetBillData(reservat.rs_reserid, nbIllwindow, "bn_paynum")),'pm_paytyp')=4)
                               lcReditnote = .F.
                               DO BillApId IN procbill WITH nbIllwindow,reservat.rs_addrid, ;
                                         reservat.rs_compid,reservat.rs_invid, ;
                                         reservat.rs_apid,reservat.rs_invapid,l_nApId
                               g_BillNum = GetBill(lAskType, lLedger, lCreditNote, ;
                                         plCheckOut, ps_reserid, l_nAddrId, ;
                                         l_nAmount, l_cAction, nbIllwindow , ;
                                         l_nApId)
                               DBTableFlushForce()
                          ENDIF
                        ENDIF
                     ELSE
                        l_lDontPrint = .F.
                     ENDIF
                     IF lp_lDontPrint
                     	l_lDontPrint = .T.
                     ENDIF
                     l_nPayNum = 0
                     DO BillPayNum IN procbill WITH reservat.rs_reserid, nbIllwindow, l_nPayNum
                     IF NOT EMPTY(g_BillNum)
                          IF l_cAction <> "CHKOUT"
                               l_cAction = IIF(l_nBalance==0, "CHKOUT", l_cAction)
                          ENDIF
                          DO BillNumChange IN ProcBill WITH g_BillNum, ;
                                    l_cAction, "", l_nPayNum, l_nAmount, lp_nAyID, lp_nBillType
                          DO BillUpdate IN ProcBill WITH nReserId, nBillWindow, g_BillNum
                          g_dBillDate = DbLookup("billnum", "tag1", g_BillNum, "bn_date")
                     ENDIF
                     PBSetBillType(lp_nBillType)
                     IF NOT l_lDontPrint
                          IF NOT EMPTY(g_BillNum)
                               g_Billcopy = MIN(99, FNGetWindowData(reservat.rs_rsid, nBillWindow, "pw_copy")+1)
                               FNSetWindowData(reservat.rs_rsid, nBillWindow, "pw_copy", g_Billcopy)
                          ENDIF
                          FLUSH
                          IF ( .NOT. EMPTY(naDdressid))
                               naDdrrecord = RECNO("Address")
                               IF ( .NOT. SEEK(naDdressid, "Address", "tag1"))
                                    GOTO naDdrrecord IN "Address"
                               ENDIF
                          ENDIF
                          ntHisposting = RECNO(l_cPostAlias)
                          ntHisaddress = RECNO("Address")
                          ntHisreservat = RECNO("Reservat")
                          FOR nbIllcounter = 1 TO ncOpies
                               l_cOldTmpFrx = ""
                               l_nRecNoLists = 0
                               WAIT WINDOW NOWAIT GetLangText("PRNTBILL", ;
                                    "TXT_PRINTINGCOPY")+" "+LTRIM(STR(nbIllcounter))
                               g_Billdupl = nbIllcounter
                               IF (g_Demo .OR. glTraining)
                                    glInreport = .T.
                                    REPORT FORM (ctMpfrx) HEADING  ;
                                           REPLICATE(UPPER(gcApplication)+ ;
                                           IIF(g_Demo, " DEMO VERSION... ",  ;
                                           " TRAININGS VERSION... "), 3) TO  ;
                                           PRINTER NOCONSOLE FOR ( .NOT.  ;
                                           ps_cancel .AND.  &lArtForClause)  ;
                                           WHILE (ps_reserid=nrEserid .AND.  ;
                                           ps_window=nbIllwindow)
                                    glErrorinreport = .F.
                                    glInreport = .F.
                                    DO seTstatus IN Setup
                               ELSE
                                    cdEfaultprinter = SET('printer', 2)
                                    IF nbIllcounter = 2 AND NOT EMPTY(_screen.oGlobal.oParam.pa_copydev)
                                         npRintercount = APRINTERS(amYprinters)
                                         FOR i = 1 TO npRintercount
                                              IF UPPER(amYprinters(i,1))= UPPER(TRIM(_screen.oGlobal.oParam.pa_copydev))
                                                   SET PRINTER TO NAME (amYprinters(i,1))
                                                   EXIT
                                              ENDIF
                                         ENDFOR
                                    ENDIF
                                    IF nbIllcounter = 2 AND NOT EMPTY(_screen.oGlobal.oParam.pa_bilcopy)
                                         l_nSelected = SELECT()
                                         SELECT lists
                                         l_nRecNoLists = RECNO()
                                         LOCATE FOR li_frx = ALLTRIM(_screen.oGlobal.oParam.pa_bilcopy)+".FRX"
                                         IF FOUND() AND FILE(ADDBS(gcReportdir)+ALLTRIM(_screen.oGlobal.oParam.pa_bilcopy)+".FRX")
                                              l_cOldTmpFrx = ctMpfrx
                                              ctMpfrx = ADDBS(gcReportdir)+ALLTRIM(_screen.oGlobal.oParam.pa_bilcopy)+".FRX"
                                         ELSE
                                              GO l_nRecNoLists IN lists
                                         ENDIF
                                         SELECT(l_nSelected)
                                    ENDIF
                                    IF nbIllcounter > 1 AND NOT EMPTY(_screen.oGlobal.oParam2.pa_copylng)
                                         PBSetReportLanguage(_screen.oGlobal.oParam2.pa_copylng)
                                    ENDIF
                                    PrintReport(ctMpfrx,,,,"ZUGFERD",,"TempPost")
                                    PrintReport(ctMpfrx, .T., NOT _screen.oGlobal.oParam2.pa_askbprn)
                                    IF nbIllcounter = 2 AND NOT EMPTY(_screen.oGlobal.oParam.pa_copydev)
                                         SET PRINTER TO NAME (cdEfaultprinter)
                                    ENDIF
                                    IF nbIllcounter = 2 AND NOT EMPTY(_screen.oGlobal.oParam.pa_bilcopy) AND NOT EMPTY(l_cOldTmpFrx)
                                         ctMpfrx = l_cOldTmpFrx
                                         l_cOldTmpFrx = ""
                                         GO l_nRecNoLists IN lists
                                    ENDIF
                               ENDIF
                               WAIT CLEAR
                               GOTO ntHisposting IN &l_cPostAlias
                               GOTO ntHisreservat IN "Reservat"
                               GOTO ntHisaddress IN "Address"
                               IF USED("TempPost")
                                    SELECT teMppost
                                    GOTO TOP
                               ENDIF
                          ENDFOR
                     ENDIF
                     l_nCopy = FNGetWindowData(reservat.rs_rsid, nbIllwindow, "pw_copy")
                ENDIF
           ENDIF
           _screen.oGlobal.oBill.lActive = .F.
           _screen.oGlobal.oBill.nAddrId = 0
           _screen.oGlobal.oBill.nApId = 0
           _screen.oGlobal.oBill.ResetElPaySlip()
           GOTO npOstrecord IN &l_cPostAlias
           = dcLose('RepText')
           SELECT (ntHisone)
           IF nbIllwindow <> 1
                IF NOT EMPTY(naDdressid)
                     GOTO naDdrrecord IN "Address"
                ENDIF
           ENDIF
           IF lChangeVAT
               ProcBill("RestoreVAT", cPickListTmp)
           ENDIF
 ENDCASE
 = clOsefile("TempPost")
 SELECT (naRea)
 fiLedelete(ctMpfrx)
 fiLedelete(ctMpfrt)
 RETURN .T.
ENDFUNC
*
FUNCTION BillStyle
 PARAMETER tnReserId, tnBillWindow, tlHistory, tnHistBillStyle, tlHistUseBookingDate, tlHpFields
 LOCAL lnArea, llInsert, lcLangNum, lcKeyExpression, lcPostFields, lcHistPostFields, lcSalang, lnRecno, lnPsRecno, lnRsRecno, lnHrRecno, lnAdRecno, lnVat0Grp, l_dNewDate
 LOCAL lcRaAlias, lnRsID, lnVat0, llFromPostCxl
 PRIVATE pcPostAlias

 lnArea = SELECT()
 llFromPostCxl = TYPE("lFromPostCxl") = "L" AND lFromPostCxl
 pcPostAlias = IIF(llFromPostCxl, "postcxl", "post")
 lnPsRecno = RECNO(pcPostAlias)
 lnRsRecno = RECNO("reservat")
 lnAdRecno = RECNO("address")
 lnHrRecno = RECNO("histres")
 
 nBillstyle = IIF(EMPTY(tnHistBillStyle), g_Billstyle, tnHistBillStyle)
 lUseBookingDate = IIF(PCOUNT() < 5, g_UseBDateInStyle, tlHistUseBookingDate)
 IF NOT BETWEEN(nBillstyle, 1, MAX_BILLSTYLE)
      nBillstyle = MAX(_screen.oGlobal.oParam.pa_billsty, 1)
 ENDIF
 lnVat0Grp = DLookUp("picklist", "pl_label = [VATGROUP] AND pl_numval = 0", "pl_numcod")
 WAIT WINDOW NOWAIT GetLangText("PRNTBILL","TXT_PREPAREBILLSTYLE") + " " + TRANSFORM(nBillstyle) + IIF(lUseBookingDate, "-B", "") + "..."

 IF NOT USED("histpost")
      openfile(.F.,"histpost")
 ENDIF

 DO CursorPrintBillCreate IN ProcBill WITH "TempPost"
 SCATTER FIELDS ps_euro, ps_local, cur_vat, cur_rmname, cur_arrdat, cur_depdat BLANK MEMVAR
 lcLangNum = STR(DLookUp('PickList', 'pl_label = [LANGUAGE] AND pl_charcod = ' + ;
      SqlCnv(IIF(_screen.oGlobal.oParam.pa_billlng AND NOT EMPTY(address.ad_lang), address.ad_lang, g_Language)), 'pl_numval'), 1)
 DO CASE
      CASE tlHistory
           lcRaAlias = "hresrart"
           lnRsID = histres.hr_rsid
           SELECT DISTINCT histpost.*, lnRsID AS cur_rsid, NVL(rc_sagroup,0=1) AS rc_sagroup, NVL(NVL(rra.ra_sagroup,ra.ra_sagroup),0=1) AS ra_sagroup, NVL(ar_vat,0) AS ar_vat, ;
                IIF(EMPTY(hp_ratecod),4,NVL(NVL(rra.ra_artityp,ra.ra_artityp),0)) AS cur_artitp, NVL(ar_prtype,00) AS ar_prtype, CAST(NVL(rc_rcsetid,0) AS Num(8)) AS cur_rcsetid ;
                FROM histpost ;
                LEFT JOIN ratecode ON rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season = hp_ratecod ;
                LEFT JOIN hresrart rra ON STR(rra.ra_rsid,10)+rra.ra_ratecod+STR(rra.ra_raid,10) = STR(lnRsID,10)+hp_ratecod+STR(hp_raid,10) ;
                LEFT JOIN ratearti ra ON ra.ra_ratecod+STR(ra.ra_raid,10) = hp_ratecod+STR(hp_raid,10) AND ra.ra_raid > 0 ;
                LEFT JOIN article ON ar_artinum = hp_artinum AND ar_artinum > 0 ;
                WHERE hp_reserid = tnReserId AND hp_window = tnBillWindow AND NOT hp_cancel AND &lArtForClause ;
                ORDER BY hp_postid ;
                INTO CURSOR curHistPost
           SELECT post.*, CAST(0 AS Int) AS cur_rsid, CAST("" AS Char(35)) AS rc_salang, 0=1 AS rc_sagroup, 0=1 AS ra_sagroup, 0 AS cur_artitp, 0 AS ar_vat, 00 AS ar_prtype, ;
                0=1 AS pt_alwgrp, CAST("" AS Char(20)) AS pt_lang, CAST("" AS Char(25)) AS pl_vatlang, CAST(0 AS Num(8)) AS cur_rcsetid, ;
                CAST(0 AS Double(2)) AS cur_amount, CAST(0 AS Double(6)) AS cur_price ;
                FROM post ;
                WHERE 0=1 ;
                INTO CURSOR curPost READWRITE
           DO GetPostFields IN ProcBill WITH "curPost", "curHistPost", lcPostFields, lcHistPostFields
           INSERT INTO curPost (&lcPostFields) SELECT &lcHistPostFields FROM curHistPost
      CASE llFromPostCxl
           lcRaAlias = "resrart"
           lnRsID = reservat.rs_rsid
           lnReserID = reservat.rs_reserid
           SELECT DISTINCT postcxl.*, .F. AS ps_cancel, ps_date AS ps_bdate, ps_date AS ps_rdate, lnReserID AS ps_reserid, lnReserID AS ps_origid, 0 AS ps_prtype, ps_rsid AS cur_rsid, CAST("" AS Char(35)) AS rc_salang, NVL(rc_sagroup,0=1) AS rc_sagroup, NVL(NVL(rra.ra_sagroup,ra.ra_sagroup),0=1) AS ra_sagroup, ;
                IIF(EMPTY(ps_ratecod),4,NVL(NVL(rra.ra_sagroup,ra.ra_artityp),0)) AS cur_artitp, NVL(ar_vat,0) AS ar_vat, NVL(ar_prtype,0) AS ar_prtype, ;
                0=1 AS pt_alwgrp, CAST("" AS Char(20)) AS pt_lang, CAST("" AS Char(25)) AS pl_vatlang, CAST(NVL(rc_rcsetid,0) AS Num(8)) AS cur_rcsetid, ;
                CAST(0 AS Double(2)) AS cur_amount, CAST(0 AS Double(6)) AS cur_price ;
                FROM postcxl ;
                LEFT JOIN ratecode ON rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season = ps_ratecod ;
                LEFT JOIN resrart rra ON STR(rra.ra_rsid,10)+rra.ra_ratecod+STR(rra.ra_raid,10)+STR(rra.ra_artinum,4) = ps_ratecod+STR(ps_raid,10) ;
                LEFT JOIN ratearti ra ON ra.ra_ratecod+STR(ra.ra_raid,10) = ps_ratecod+STR(ps_raid,10) AND ra.ra_raid > 0 ;
                LEFT JOIN article ON ar_artinum = ps_artinum AND ar_artinum > 0 ;
                WHERE ps_rsid = lnRsID AND ps_window = tnBillWindow AND ps_billnum = g_BillNum AND &lArtForClause ;
                ORDER BY ps_postid ;
                INTO CURSOR curPost READWRITE
      OTHERWISE
           lcRaAlias = "resrart"
           lnRsID = reservat.rs_rsid
           SELECT DISTINCT post.*, lnRsID AS cur_rsid, CAST("" AS Char(35)) AS rc_salang, NVL(rc_sagroup,0=1) AS rc_sagroup, NVL(NVL(rra.ra_sagroup,ra.ra_sagroup),0=1) AS ra_sagroup, ;
                IIF(EMPTY(ps_ratecod),4,NVL(NVL(rra.ra_sagroup,ra.ra_artityp),0)) AS cur_artitp, NVL(ar_vat,0) AS ar_vat, NVL(ar_prtype,0) AS ar_prtype, ;
                0=1 AS pt_alwgrp, CAST("" AS Char(20)) AS pt_lang, CAST("" AS Char(25)) AS pl_vatlang, CAST(NVL(rc_rcsetid,0) AS Num(8)) AS cur_rcsetid, ;
                CAST(0 AS Double(2)) AS cur_amount, CAST(0 AS Double(6)) AS cur_price ;
                FROM post ;
                LEFT JOIN ratecode ON rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season = ps_ratecod ;
                LEFT JOIN resrart rra ON STR(rra.ra_rsid,10)+rra.ra_ratecod+STR(rra.ra_raid,10)+STR(rra.ra_artinum,4) = ps_ratecod+STR(ps_raid,10) ;
                LEFT JOIN ratearti ra ON ra.ra_ratecod+STR(ra.ra_raid,10) = ps_ratecod+STR(ps_raid,10) AND ra.ra_raid > 0 ;
                LEFT JOIN article ON ar_artinum = ps_artinum AND ar_artinum > 0 ;
                WHERE ps_reserid = tnReserId AND ps_window = tnBillWindow AND NOT ps_cancel AND &lArtForClause ;
                ORDER BY ps_postid ;
                INTO CURSOR curPost READWRITE
 ENDCASE

 REPLACE ra_sagroup WITH DLookUp(lcRaAlias, "STR(ra_rsid,10)+ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4) = " + SqlCnv(STR(lnRsID,10)+ps_ratecod) + " AND ra_sagroup AND ra_artinum = " + SqlCnv(ps_artinum), "ra_sagroup"), ;
         cur_artitp WITH DLookUp(lcRaAlias, "STR(ra_rsid,10)+ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4) = " + SqlCnv(STR(lnRsID,10)+ps_ratecod+'1'+STR(ps_artinum,4)), "IIF(FOUND(),ra_artityp,2)") ;
         FOR cur_artitp = 0 AND ps_raid < 0
 REPLACE ra_sagroup WITH DLookUp("ratearti", "ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4) = " + SqlCnv(ps_ratecod) + " AND ra_sagroup AND ra_artinum = " + SqlCnv(ps_artinum), "ra_sagroup"), ;
         cur_artitp WITH DLookUp("ratearti", "ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4) = " + SqlCnv(ps_ratecod+'1'+STR(ps_artinum,4)), "IIF(FOUND(),ra_artityp,2)") ;
         FOR cur_artitp = 0
 REPLACE pl_vatlang WITH DLangLookUp("picklist", "pl_label = [VATGROUP] AND pl_numcod = " + SqlCnv(ar_vat), "pl_lang", lcLangNum) FOR ar_vat > 0
 REPLACE ps_prtype WITH ar_prtype FOR ps_prtype = 0 AND ar_prtype > 0
 REPLACE pt_lang WITH DLangLookUp("prtypes", "pt_number = " + SqlCnv(ps_prtype), "pt_lang", lcLangNum), ;
         pt_alwgrp WITH DLookUp("prtypes", "pt_number = " + SqlCnv(ps_prtype), "pt_alwgrp") FOR ps_prtype > 0
 SELECT curPost
 SCAN
      l_dNewDate = ps_date
      IF _screen.oGlobal.oParam2.pa_billrda
           * Set ratecode posted for date as ps_date
           l_dNewDate = EVL(ps_rdate,l_dNewDate)
      ENDIF
      IF lUseBookingDate
           * Set ratecode posted for date as ps_date
           l_dNewDate = EVL(ps_bdate,l_dNewDate)
      ENDIF
      IF ps_date <> l_dNewDate
           REPLACE ps_date WITH l_dNewDate
      ENDIF
      IF NOT ps_cancel AND ps_artinum > 0 AND NOT EMPTY(ps_ratecod) AND NOT ps_split
           * For main split article, we must get all split articles, to calculate sum amount of articles with VAT 0%
           * and store it in ps_vat0
           IF EMPTY(ps_vat0)
                lnVat0 = PBGetVat0(tnReserId, tnBillWindow, ps_setid, lnVat0Grp, tlHistory, llFromPostCxl)
                IF lnVat0 <> 0.00
                     REPLACE ps_vat0 WITH lnVat0
                ENDIF
           ENDIF
      ELSE
           * When posting is article from VAT group 0%, then copy Amount into ps_vat0 field, to show it on bill.
           * But it can happen (Argus POS posting), that this article has another VAT groups amount. So, when there another VAT is
           * found, don't copy ps_amount into ps_vat0. In that case is expected, that in ps_vat0 is already copied
           * amount for VAT group 0%.
           IF ar_vat = lnVat0Grp AND (ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9)=0 AND ps_vat0=0
                REPLACE ps_vat0 WITH ps_amount
           ENDIF
      ENDIF
      IF _screen.SA AND rc_sagroup AND INLIST(cur_artitp, 1, 2) AND ra_sagroup
           * Ratecode article groupping
           lcSalang = DLangLookup("ratecode", "rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season = " + SqlCnv(ps_ratecod), "rc_salang", lcLangNum)
           IF NOT EMPTY(lcSalang)
                lnRecno = RECNO()
                SCATTER MEMO MEMVAR
                IF DLocate("curPost", "ps_setid = " + SqlCnv(m.ps_setid) + " AND rc_salang = " + SqlCnv(PADR(lcSalang,35)))
                     DO CASE
                          CASE EMPTY(m.ps_ratecod) OR NOT m.ps_split
                               m.ps_units = 1
                          CASE DLocate(pcPostAlias,"ps_setid = " + SqlCnv(m.ps_setid) + " AND NOT ps_split")
                               * Get units from main article
                               m.ps_units = &pcPostAlias..ps_units
                          CASE DLocate("histpost","hp_setid = " + SqlCnv(m.ps_setid) + " AND NOT hp_split")
                               * Get units from main article
                               m.ps_units = histpost.hp_units
                          OTHERWISE
                               m.ps_units = 1
                     ENDCASE
                     REPLACE ps_units WITH m.ps_units, ps_amount WITH ps_amount + m.ps_amount, ps_price WITH ps_amount/ps_units, ;
                             ps_vat0 WITH ps_vat0 + m.ps_vat0, ps_vat1 WITH ps_vat1 + m.ps_vat1, ps_vat2 WITH ps_vat2 + m.ps_vat2, ;
                             ps_vat3 WITH ps_vat3 + m.ps_vat3, ps_vat4 WITH ps_vat4 + m.ps_vat4, ps_vat5 WITH ps_vat5 + m.ps_vat5, ;
                             ps_vat6 WITH ps_vat6 + m.ps_vat6, ps_vat7 WITH ps_vat7 + m.ps_vat7, ps_vat8 WITH ps_vat8 + m.ps_vat8, ;
                             ps_vat9 WITH ps_vat9 + m.ps_vat9
                     GO lnRecno
                     DELETE
                     LOOP
                ELSE
                     GO lnRecno
                     IF ar_prtype > 0
                          BLANK FIELDS ps_prtype, pt_alwgrp, pt_lang
                     ENDIF
                     REPLACE cur_artitp WITH 3, rc_salang WITH lcSalang
                ENDIF
           ENDIF
      ENDIF
      DO CASE
           CASE EMPTY(ps_ratecod) OR NOT ps_split
           CASE DLocate(pcPostAlias,"ps_setid = " + SqlCnv(ps_setid) + " AND NOT ps_split")
                * Get data from main article
                REPLACE ps_descrip WITH &pcPostAlias..ps_descrip, ;
                        ps_supplem WITH &pcPostAlias..ps_supplem, ;
                        ps_note WITH &pcPostAlias..ps_note
                IF cur_artitp = 1 AND NOT pt_alwgrp AND INLIST(nBillstyle, 15, 16)
                     REPLACE cur_amount WITH &pcPostAlias..ps_amount, ;
                             cur_price WITH &pcPostAlias..ps_price
                ENDIF
           CASE DLocate("histpost","hp_setid = " + SqlCnv(ps_setid) + " AND NOT hp_split")
                * Get data from main article
                REPLACE ps_descrip WITH histpost.hp_descrip, ;
                        ps_supplem WITH histpost.hp_supplem, ;
                        ps_note WITH histpost.hp_note
                IF cur_artitp = 1 AND NOT pt_alwgrp AND INLIST(nBillstyle, 15, 16)
                     REPLACE cur_amount WITH histpost.hp_amount, ;
                             cur_price WITH histpost.hp_price
                ENDIF
           OTHERWISE
      ENDCASE
 ENDSCAN
 * cur_artitp = 1     - Ratecode's main articles
 * cur_artitp = 2     - Ratecode's simple split articles
 * cur_artitp = 3     - Ratecode's groupped split articles
 * cur_artitp = 4     - Ratecode's extra or common articles
 * cur_artitp = 5     - Always groupped articles
 REPLACE cur_artitp WITH 5 FOR pt_alwgrp
 DO CASE
      CASE nBillstyle = 1
           * Detalliert
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+DTOS(ps_date)+IIF(cur_artitp>3,'1','0')+STR(ps_setid,8)+STR(cur_artitp,1) TAG tag1
           INDEX ON STR(ps_prtype,2)+STR(cur_vat,1) TAG tag2
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                llInsert = .T.
                DO CASE
                     CASE m.ps_paynum > 0
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag2")
                     OTHERWISE
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 2
           * Pro Tag, pro Artikel
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+DTOS(ps_date)+STR(cur_artitp,1)+STR(ps_artinum,4) TAG tag1
           INDEX ON DTOS(ps_date)+STR(ps_artinum,4) TAG tag2
           INDEX ON DTOS(ps_date)+ps_descrip TAG tag3
           INDEX ON DTOS(ps_date)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(DTOS(m.ps_date)+PADR(m.ps_descrip,25), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(DTOS(m.ps_date)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(DTOS(m.ps_date)+STR(m.ps_artinum,4), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 3
           * Pro Artikel
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+STR(cur_artitp,1)+STR(ps_artinum,4) TAG tag1
           INDEX ON STR(ps_artinum,4) TAG tag2
           INDEX ON ps_descrip TAG tag3
           INDEX ON STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(PADR(m.ps_descrip,25), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(STR(m.ps_artinum,4), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 4
           * Pro Artikel, pro Preis
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+STR(cur_artitp,1)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag1
           INDEX ON STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag2
           INDEX ON ps_descrip+STR(ps_price,12,2) TAG tag3
           INDEX ON STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(PADR(m.ps_descrip,25)+STR(m.ps_price,12,2), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(STR(m.ps_artinum,4)+STR(m.ps_price,12,2), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 5
           * Pro Tag
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+DTOS(ps_date)+STR(cur_artitp,1)+STR(cur_vat,1) TAG tag1
           INDEX ON DTOS(ps_date)+IIF(cur_artitp=5,'1','0')+STR(cur_vat,1) TAG tag2
           INDEX ON DTOS(ps_date)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag3
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(DTOS(m.ps_date)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag3")
                     OTHERWISE
                          m.ps_descrip = MakeShorDateString(M.ps_date) + PBGetVatLang()
                          llInsert = NOT SEEK(DTOS(m.ps_date)+'0'+STR(m.cur_vat,1), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 6
           * Pro Tag, pro Artikel, pro Preis
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+DTOS(ps_date)+STR(cur_artitp,1)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag1
           INDEX ON DTOS(ps_date)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag2
           INDEX ON DTOS(ps_date)+ps_descrip+STR(ps_price,12,2) TAG tag3
           INDEX ON DTOS(ps_date)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(DTOS(m.ps_date)+PADR(m.ps_descrip,25)+STR(m.ps_price,12,2), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(DTOS(m.ps_date)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(DTOS(m.ps_date)+STR(m.ps_artinum,4)+STR(m.ps_price,12,2), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 7
           * Pro Zimmer, pro Artikel, pro Preis
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+DTOS(ps_date)+UPPER(cur_rmname)+STR(cur_artitp,1)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag1
           INDEX ON STR(ps_origid,12,3)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag2
           INDEX ON STR(ps_origid,12,3)+ps_descrip+STR(ps_price,12,2) TAG tag3
           INDEX ON STR(ps_origid,12,3)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetRoomName()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+PADR(m.ps_descrip,25)+STR(m.ps_price,12,2), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_artinum,4)+STR(m.ps_price,12,2), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 8
           * Pro Zimmer, detalliert
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+UPPER(cur_rmname)+DTOS(ps_date)+IIF(cur_artitp>3,'1','0')+STR(ps_setid,8)+STR(cur_artitp,1) TAG tag1
           INDEX ON STR(ps_origid,12,3)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag2
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetRoomName()
                llInsert = .T.
                DO CASE
                     CASE m.ps_paynum > 0
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag2")
                     OTHERWISE
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 9
           * Aufenthalt ingesamt
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+STR(cur_artitp,1)+STR(cur_vat,1) TAG tag1
           INDEX ON IIF(cur_artitp=5,'1','0')+STR(cur_vat,1) TAG tag2
           INDEX ON STR(ps_prtype,2)+STR(cur_vat,1) TAG tag3
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag3")
                     OTHERWISE
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = DLangLookup("picklist", "pl_label+pl_charcod = [BILLTEXT  ART]", "pl_lang", lcLangNum)
                          IF EMPTY(m.ps_descrip)
                               m.ps_descrip = "Not found BILLTEXT+ART"
                          ENDIF
                          m.ps_descrip = ALLTRIM(RTRIM(m.ps_descrip) + PBGetVatLang())
                          llInsert = NOT SEEK('0'+STR(m.cur_vat,1), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 10
           * Druckgruppierungskode
           SELECT TempPost
           INDEX ON IIF(ps_paynum=0,'0','1')+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag1
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                llInsert = .T.
                DO CASE
                     CASE m.ps_paynum > 0
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                     CASE m.ps_prtype > 0
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK('0'+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag1")
                     OTHERWISE
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 11
           * Pro Zimmer
           SELECT TempPost
           INDEX ON IIF(ps_paynum=0,'0','1')+UPPER(cur_rmname)+DTOS(ps_date)+STR(cur_artitp,1)+STR(cur_vat,1)+STR(ps_paynum,3) TAG tag1
           INDEX ON STR(ps_origid,12,3)+IIF(cur_artitp=5,'1','0')+STR(cur_vat,1) TAG tag2
           INDEX ON STR(ps_origid,12,3)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag3
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetRoomName()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag3")
                     OTHERWISE
                          IF NOT EMPTY(m.cur_rmname) AND PADR(UPPER(m.ps_supplem),25) = PADR(UPPER(m.cur_rmname),25)
                               m.ps_supplem = ""
                          ENDIF
                          m.ps_descrip = ALLTRIM(RTRIM(m.cur_rmname) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+'0'+STR(m.cur_vat,1), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 12
           * Pro Zimmer, pro Druckgruppierungskode
           SELECT TempPost
           INDEX ON IIF(ps_paynum=0,'0','1')+UPPER(cur_rmname)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag1
           INDEX ON STR(ps_origid,12,3)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag2
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetRoomName()
                llInsert = .T.
                DO CASE
                     CASE m.ps_paynum > 0
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                     CASE m.ps_prtype > 0
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag2")
                     OTHERWISE
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 13
           * Pro Anreise/Abreise, pro Artikel, pro Preis
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+IIF(EMPTY(cur_arrdat),'1','0')+DTOS(cur_arrdat)+DTOS(cur_depdat)+UPPER(ps_supplem)+DTOS(ps_date)+STR(cur_artitp,1)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag1
           INDEX ON DTOS(cur_arrdat)+DTOS(cur_depdat)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag2
           INDEX ON DTOS(cur_arrdat)+DTOS(cur_depdat)+ps_descrip+STR(ps_price,12,2) TAG tag3
           INDEX ON DTOS(cur_arrdat)+DTOS(cur_depdat)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetArrDep()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(DTOS(m.cur_arrdat)+DTOS(m.cur_depdat)+PADR(m.ps_descrip,25)+STR(m.ps_price,12,2), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(DTOS(m.cur_arrdat)+DTOS(m.cur_depdat)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(DTOS(m.cur_arrdat)+DTOS(m.cur_depdat)+STR(m.ps_artinum,4)+STR(m.ps_price,12,2), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 14
           * Pro Zimmer, pro Artikel
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+DTOS(ps_date)+UPPER(cur_rmname)+STR(cur_artitp,1)+STR(ps_artinum,4) TAG tag1
           INDEX ON STR(ps_origid,12,3)+STR(ps_artinum,4) TAG tag2
           INDEX ON STR(ps_origid,12,3)+ps_descrip TAG tag3
           INDEX ON STR(ps_origid,12,3)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetRoomName()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+PADR(m.ps_descrip,25), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_artinum,4), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert, .T.)
           ENDSCAN
      CASE nBillstyle = 15
           * Pro Preiscode, pro Artikel, pro Preis
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+IIF(cur_artitp>3,'1','0')+STR(ps_setid,8)+STR(cur_artitp,1)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag1
           INDEX ON STR(cur_rcsetid,8)+STR(ps_setid,8)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag2
           INDEX ON STR(cur_rcsetid,8)+STR(ps_setid,8)+ps_descrip+STR(ps_price,12,2) TAG tag3
           INDEX ON STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           INDEX ON STR(cur_rcsetid,8)+STR(ps_artinum,4)+STR(cur_price,12,2) TAG tag5
           SELECT curPost
           INDEX ON STR(ps_paynum,3)+STR(cur_artitp,1)+STR(ps_artinum,4) TAG tag1
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(STR(m.cur_rcsetid,8)+STR(m.ps_setid,8)+PADR(m.ps_descrip,25)+STR(m.ps_price,12,2), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     CASE m.cur_artitp = 1
                          llInsert = NOT SEEK(STR(m.cur_rcsetid,8)+STR(m.ps_artinum,4)+STR(m.cur_price,12,2), "TempPost", "tag5")
                          IF NOT llInsert&& FOUND("TempPost")
                               lnRecno = RECNO()
                               * Split articles sort and group with its main article. Main article change setid because its grouped with other existed main article.
                               REPLACE ps_setid WITH TempPost.ps_setid FOR ps_setid = m.ps_setid AND ps_setid <> TempPost.ps_setid
                               GO lnRecno
                          ENDIF
                     OTHERWISE
                          llInsert = NOT SEEK(STR(m.cur_rcsetid,8)+STR(m.ps_setid,8)+STR(m.ps_artinum,4)+STR(m.ps_price,12,2), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert, .T.)
           ENDSCAN
      CASE nBillstyle = 16
           * Pro Preiscode, pro Zimmer, pro Artikel, pro Preis
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+IIF(cur_artitp>3,'1','0')+STR(ps_setid,8)+STR(cur_artitp,1)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag1
           INDEX ON STR(cur_rcsetid,8)+STR(ps_setid,8)+STR(ps_origid,12,3)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag2
           INDEX ON STR(cur_rcsetid,8)+STR(ps_setid,8)+STR(ps_origid,12,3)+ps_descrip+STR(ps_price,12,2) TAG tag3
           INDEX ON STR(ps_origid,12,3)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           INDEX ON STR(cur_rcsetid,8)+STR(ps_origid,12,3)+STR(ps_artinum,4)+STR(cur_price,12,2) TAG tag5
           SELECT curPost
           INDEX ON STR(ps_paynum,3)+STR(cur_artitp,1)+STR(ps_artinum,4) TAG tag1
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetRoomName()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(STR(m.cur_rcsetid,8)+STR(m.ps_setid,8)+STR(m.ps_origid,12,3)+PADR(m.ps_descrip,25)+STR(m.ps_price,12,2), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     CASE m.cur_artitp = 1
                          llInsert = NOT SEEK(STR(m.cur_rcsetid,8)+STR(m.ps_origid,12,3)+STR(m.ps_artinum,4)+STR(m.cur_price,12,2), "TempPost", "tag5")
                          IF NOT llInsert&& FOUND("TempPost")
                               lnRecno = RECNO()
                               * Split articles sort and group with its main article. Main article change setid because its grouped with other existed main article.
                               REPLACE ps_setid WITH TempPost.ps_setid FOR ps_setid = m.ps_setid AND ps_setid <> TempPost.ps_setid
                               GO lnRecno
                          ENDIF
                     OTHERWISE
                          llInsert = NOT SEEK(STR(m.cur_rcsetid,8)+STR(m.ps_setid,8)+STR(m.ps_origid,12,3)+STR(m.ps_artinum,4)+STR(m.ps_price,12,2), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert, .T.)
           ENDSCAN
      CASE nBillstyle = 17
           * Pro Zimmer, pro Anreise/Abreise, pro Artikel, pro Preis
           SELECT TempPost
           INDEX ON STR(ps_paynum,3)+UPPER(cur_rmname)+IIF(EMPTY(cur_arrdat),'1','0')+DTOS(cur_arrdat)+DTOS(cur_depdat)+UPPER(ps_supplem)+DTOS(ps_date)+STR(cur_artitp,1)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag1
           INDEX ON STR(ps_origid,12,3)+DTOS(cur_arrdat)+DTOS(cur_depdat)+STR(ps_artinum,4)+STR(ps_price,12,2) TAG tag2
           INDEX ON STR(ps_origid,12,3)+DTOS(cur_arrdat)+DTOS(cur_depdat)+ps_descrip+STR(ps_price,12,2) TAG tag3
           INDEX ON STR(ps_origid,12,3)+DTOS(cur_arrdat)+DTOS(cur_depdat)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag4
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                PBGetArrDep()
                PBGetRoomName()
                DO CASE
                     CASE m.ps_paynum > 0
                          llInsert = .T.
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+DTOS(m.cur_arrdat)+DTOS(m.cur_depdat)+PADR(m.ps_descrip,25)+STR(m.ps_price,12,2), "TempPost", "tag3")
                     CASE m.pt_alwgrp
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+DTOS(m.cur_arrdat)+DTOS(m.cur_depdat)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag4")
                     OTHERWISE
                          llInsert = NOT SEEK(STR(m.ps_origid,12,3)+DTOS(m.cur_arrdat)+DTOS(m.cur_depdat)+STR(m.ps_artinum,4)+STR(m.ps_price,12,2), "TempPost", "tag2")
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
      CASE nBillstyle = 18
           * Pro Tag, pro Druckgruppierungskode
           SELECT TempPost
           INDEX ON IIF(ps_paynum=0,'0','1')+DTOS(ps_date)+STR(ps_prtype,2)+STR(cur_vat,1) TAG tag1
           SELECT curPost
           SCAN
                SCATTER MEMO MEMVAR
                PBSetPostCommonFields()
                llInsert = .T.
                DO CASE
                     CASE m.ps_paynum > 0
                     CASE NOT EMPTY(rc_salang)
                          m.ps_artinum = SAGROUP_ARTINUM
                          m.ps_descrip = EVL(m.ps_descrip,rc_salang)
                     CASE m.ps_prtype > 0
                          m.ps_descrip = ALLTRIM(RTRIM(pt_lang) + PBGetVatLang())
                          llInsert = NOT SEEK('0'+DTOS(m.ps_date)+STR(m.ps_prtype,2)+STR(m.cur_vat,1), "TempPost", "tag1")
                     OTHERWISE
                ENDCASE
                Post2Temp(llInsert)
           ENDSCAN
 ENDCASE
 SELECT TempPost
 IF tlHpFields
      lcKeyExpression = STRTRAN(UPPER(KEY(1)), "PS_", "HP_")
      ConvertFieldNames("TempPost",,"PS_", "HP_")
      IF TYPE(lcKeyExpression) # "U"
           INDEX ON &lcKeyExpression TAG tag1
      ENDIF
      SET RELATION TO hp_ratecod INTO ratecode
      SET RELATION TO hp_artinum INTO article ADDITIVE
      SET RELATION TO hp_paynum INTO paymetho ADDITIVE
 ELSE
      SET ORDER TO tag1
      GO TOP
      SET RELATION TO ps_ratecod INTO ratecode
      SET RELATION TO ps_artinum INTO article ADDITIVE
      SET RELATION TO ps_paynum INTO paymetho ADDITIVE
 ENDIF
 GO lnPsRecno IN &pcPostAlias
 GO lnRsRecno IN reservat
 GO lnAdRecno IN address
 GO lnHrRecno IN histres
 SELECT (lnArea)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION Post2Temp
LPARAMETERS tlInsert, tlForceUnits
LOCAL lnArea

 IF tlInsert
      INSERT INTO TempPost FROM MEMVAR
 ELSE
      lnArea = SELECT()
      SELECT TempPost
      REPLACE ps_date WITH MIN(ps_date, m.ps_date), ;
              ps_units WITH IIF(ps_price = m.ps_price OR tlForceUnits, ps_units + m.ps_units, 0), ;
              ps_price WITH IIF(ps_price = m.ps_price, m.ps_price, 0.00), ;
              ps_amount WITH ps_amount + m.ps_amount,  ;
              cur_price WITH IIF(cur_price = m.cur_price, m.cur_price, 0.00), ;
              cur_amount WITH cur_amount + m.cur_amount,  ;
              ps_vat0 WITH ps_vat0 + m.ps_vat0, ;
              ps_vat1 WITH ps_vat1 + m.ps_vat1, ;
              ps_vat2 WITH ps_vat2 + m.ps_vat2, ;
              ps_vat3 WITH ps_vat3 + m.ps_vat3, ;
              ps_vat4 WITH ps_vat4 + m.ps_vat4, ;
              ps_vat5 WITH ps_vat5 + m.ps_vat5, ;
              ps_vat6 WITH ps_vat6 + m.ps_vat6, ;
              ps_vat7 WITH ps_vat7 + m.ps_vat7, ;
              ps_vat8 WITH ps_vat8 + m.ps_vat8, ;
              ps_vat9 WITH ps_vat9 + m.ps_vat9, ;
              ps_euro WITH ps_euro + m.ps_euro
      IF _screen.oGlobal.oParam.pa_currloc # 0
           REPLACE ps_local WITH ps_local + m.ps_local
      ENDIF
      SELECT (lnArea)
 ENDIF

 RETURN .T.
ENDFUNC
*
PROCEDURE PBGetVatLang
*RETURN " - " + m.pl_vatlang
RETURN ""
ENDPROC
*
FUNCTION GetBillFrx
 * lp_cBillLanguage parameter was previously used to get another report name, when
 * for specific languages. This is no more used, but parameter is leaved here
 * for compatibility issues.
 LPARAMETER lp_cBillLanguage, lp_cbillfrxname
 LOCAL l_cFrxName, l_cCompletePath
 IF EMPTY(lp_cbillfrxname)
      l_cFrxName = "bill1.frx"
 ELSE
      l_cFrxName = lp_cbillfrxname
 ENDIF
 l_cCompletePath = ADDBS(gcReportdir)+l_cFrxName
 RETURN l_cCompletePath
ENDFUNC
*
PROCEDURE PBSetReportLanguage
LPARAMETERS lp_cLang
IF EMPTY(lp_cLang)
     g_Rptlngnr='0'
ELSE
     g_Rptlng = lp_cLang
     g_Rptlngnr = STR(dlOokup('PickList', ;
                  'pl_label=[LANGUAGE] and pl_charcod = '+ ;
                  sqLcnv(lp_cLang),'pl_numval'), 1)
ENDIF
IF g_Rptlngnr='0'
     g_Rptlngnr = g_Langnum
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE PBSetBillType
LPARAMETERS lp_nBillType
LOCAL l_nBillNumBillType, l_nDefaultBillType

_screen.oGlobal.oBill.nBillType = -1

IF NOT EMPTY(g_BillNum)
     l_nBillNumBillType = BillNumType(g_BillNum)
     IF l_nBillNumBillType <> -1
          _screen.oGlobal.oBill.nBillType = l_nBillNumBillType
     ENDIF
ENDIF

IF _screen.oGlobal.oBill.nBillType = -1
     l_nDefaultBillType = BillNumTypeDefault(_screen.oGlobal.oBill.nAddrId)
     IF BillNumTypeManualSelectedValid(lp_nBillType, l_nDefaultBillType)
          _screen.oGlobal.oBill.nBillType = lp_nBillType
     ELSE
          _screen.oGlobal.oBill.nBillType = l_nDefaultBillType
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE PBSetPostCommonFields
 IF NOT EMPTY(m.ps_ratecod) AND m.ps_split AND NOT IIF(m.ps_raid > 0, DLocate("ratearti", "ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4) = " + SqlCnv(m.ps_ratecod+"1"+STR(m.ps_artinum,4))), ;
           DLocate("resrart", "STR(ra_rsid,10)+ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4) = " + SqlCnv(STR(m.cur_rsid,10)+m.ps_ratecod+"1"+STR(m.ps_artinum,4))))
      m.ps_ratecod = ""     && Release connection if split article is not main-split article
 ENDIF
 m.cur_vat = m.ar_vat
 m.ps_euro = Euro(m.ps_amount)
 IF _screen.oGlobal.oParam.pa_currloc # 0
      m.ps_local = InLocal(m.ps_amount)
 ENDIF
ENDPROC
*
PROCEDURE PBGetRoomName
 m.cur_rmname = ""
 DO CASE
      CASE m.ps_origid = m.ps_reserid
      CASE SEEK(m.ps_origid, "reservat", "tag1")
           m.cur_rmname = get_rm_rmname(reservat.rs_roomnum) + ' ' + PROPER(reservat.rs_lname)
      CASE SEEK(m.ps_origid, "histres", "tag1")
           m.cur_rmname = get_rm_rmname(histres.hr_roomnum) + ' ' + PROPER(histres.hr_lname)
      OTHERWISE
 ENDCASE
 IF NOT EMPTY(m.cur_rmname) AND EMPTY(m.ps_supplem)
      m.ps_supplem = m.cur_rmname
 ENDIF
ENDPROC
*
PROCEDURE PBGetArrDep
 STORE {} TO m.cur_arrdat, m.cur_depdat
 DO CASE
      CASE m.ps_paynum > 0
      CASE SEEK(m.ps_origid, "reservat", "tag1")
           m.cur_arrdat = reservat.rs_arrdate
           m.cur_depdat = reservat.rs_depdate
      CASE SEEK(m.ps_origid, "histres", "tag1")
           m.cur_arrdat = histres.hr_arrdate
           m.cur_depdat = histres.hr_depdate
      OTHERWISE
 ENDCASE
 IF NOT EMPTY(m.cur_arrdat) AND NOT EMPTY(m.cur_depdat)
      m.ps_supplem = PADR(TRANSFORM(m.cur_arrdat) + '-' + TRANSFORM(m.cur_depdat),25)
 ENDIF
ENDPROC
*
PROCEDURE PBGetVat0
LPARAMETERS lp_nReserId, lp_nBillWindow, lp_nSetId, lp_nVat0Grp, lp_lHistory, lp_lFromPostCxl
LOCAL l_nSelect, l_nVat0, l_cCur, l_cSql, l_nRsId

l_nSelect = SELECT()
l_nVat0 = 0.00
l_cSplits = SYS(2015)

DO CASE
     CASE lp_lHistory
          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
               SELECT SUM(hp_amount) AS result 
                    FROM histpost 
                    INNER JOIN article ON hp_artinum = ar_artinum AND ar_vat = <<lp_nVat0Grp>> 
                    WHERE hp_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND hp_window = <<lp_nBillWindow>> AND hp_setid = <<lp_nSetId>> AND NOT hp_cancel AND hp_split 
          ENDTEXT
     CASE lp_lFromPostCxl
          l_nRsId = reservat.rs_rsid
          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
               SELECT SUM(ps_amount) AS result 
                    FROM postcxl 
                    INNER JOIN article ON ps_artinum = ar_artinum AND ar_vat = <<lp_nVat0Grp>> 
                    WHERE ps_rsid = <<sqlcnv(l_nRsId,.T.)>> AND ps_window = <<lp_nBillWindow>> AND ps_setid = <<lp_nSetId>> AND ps_split 
          ENDTEXT
     OTHERWISE
          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
               SELECT SUM(ps_amount) AS result 
                    FROM post 
                    INNER JOIN article ON ps_artinum = ar_artinum AND ar_vat = <<lp_nVat0Grp>> 
                    WHERE ps_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND ps_window = <<lp_nBillWindow>> AND ps_setid = <<lp_nSetId>> AND NOT ps_cancel AND ps_split 
          ENDTEXT
ENDCASE

l_cCur = sqlcursor(l_cSql)
IF RECCOUNT()>0
     l_nVat0 = result
ENDIF

dclose(l_cCur)

SELECT (l_nSelect)

RETURN l_nVat0
ENDPROC