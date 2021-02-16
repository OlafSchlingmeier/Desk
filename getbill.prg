*
FUNCTION GetBill
 PARAMETER plAsktype, plLedger, plCreditnote, plCheckout, lp_nReserId, lp_nAddrId, ;
           lp_nAmount, lp_cCaller, lp_nWindow, lp_nApId, lp_lNewPredictedID
 PRIVATE adLg, crEtnum
 LOCAL l_lYearAdded, l_nNewID, l_nFiscBillNo, l_nFpNr, l_cBillIdCode
 IF EMPTY(lp_nWindow)
      lp_nWindow = 0
 ENDIF
 IF EMPTY(lp_nApId)
      lp_nApId = 0
 ENDIF
 crEtnum = ""
 l_lYearAdded = .F.
 STORE 0 TO l_nFiscBillNo, l_nFpNr
 l_cBillIdCode = _screen.oGlobal.GetBillIdCode()
 DO CASE
      CASE INLIST(paRam.pa_country, 'ITA', 'POL')
           DO CASE
                CASE plAsktype .AND.  .NOT. plCreditnote
                     DIMENSION adLg[1, 8]
                     adLg[1, 1] = "type"
                     adLg[1, 2] = GetLangText("GETBILL","T_RICEVUTA")+";"+ ;
                         GetLangText("GETBILL","T_FATTURA")
                     adLg[1, 3] = "1"
                     adLg[1, 4] = "@*R"
                     adLg[1, 5] = 5
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = 1
                     DO WHILE  .NOT. diAlog(GetLangText("GETBILL","TW_BILLTYPE"), ;
                        '',@adLg,.T.)
                     ENDDO
                     IF adLg(1,8)=1
                          crEtnum = 'R'+ ;
                                    PADL(LTRIM(STR(neXtid('RICEVUTA'))),  ;
                                    9, '0')
                     ELSE
                          crEtnum = 'F'+ ;
                                    PADL(LTRIM(STR(neXtid('FATTURA'))), 9, '0')
                     ENDIF
                CASE plCreditnote
                     crEtnum = 'C'+PADL(LTRIM(STR(neXtid('CREDIT'))), 9, '0')
                OTHERWISE
                     crEtnum = 'R'+PADL(LTRIM(STR(neXtid('RICEVUTA'))), 9, '0')
           ENDCASE
      CASE paRam.pa_country='GRC'
           IF plCheckout
                DIMENSION adLg[1, 8]
                adLg[1, 1] = "billnr"
                adLg[1, 2] = GetLangText("GETBILL","T_BILLNR")
                adLg[1, 3] = "Space(10)"
                adLg[1, 4] = REPLICATE('!', 10)
                adLg[1, 5] = 12
                adLg[1, 6] = '!Empty(billnr)'
                adLg[1, 7] = ''
                adLg[1, 8] = ''
                DO WHILE  .NOT. diAlog(GetLangText("GETBILL","TW_ENTERBILLNR"), ;
                   '',@adLg,.T.)
                ENDDO
                crEtnum = ALLTRIM(adLg(1,8))
           ELSE
                crEtnum = ''
           ENDIF
      CASE paRam.pa_country='RS '
           l_nNewID = neXtid(l_cBillIdCode)
           crEtnum = PADL(LTRIM(STR(getcheckno(param.pa_idyear,l_nNewID))),10,"0")
           l_lYearAdded = .T.
           l_nFiscBillNo = FPBillPrinted(,,,"FPBillPrintedCheckFiscalBillNumber()")
           l_nFpNr = FPBillPrinted(,,,"FPBillPrintedGetFpNr()")
      OTHERWISE
           IF lp_lNewPredictedID
                l_nNewID = DLookUp("id", "id_code = " + SqlCnv(l_cBillIdCode), "id_last") + 1
           ELSE
                l_nNewID = neXtid(l_cBillIdCode)
           ENDIF
           crEtnum = PADL(LTRIM(STR(getcheckno(param.pa_idyear,l_nNewID))),10,"0")
           l_lYearAdded = .T.
 ENDCASE
 IF EMPTY(crEtnum)
      RETURN crEtnum
 ENDIF
 IF NOT l_lYearAdded AND param.pa_idyear
      crEtnum = RIGHT(crEtnum,6)
      crEtnum = ALLTRIM(STR(YEAR(sysdate()))+cretnum)
 ENDIF
 IF lp_lNewPredictedID
      RETURN crEtnum
 ENDIF

 LOCAL l_cHistory, l_lUsed, l_nRecNo, l_nRsId
 l_nRsId = DLookUp("reservat", "rs_reserid = " + SqlCnv(lp_nReserId,.T.), "rs_rsid")
 l_cHistory = RsHistry("", lp_cCaller, "CREATED")
 l_lUsed = USED("billnum")
 IF l_lUsed
      l_nRecNo = RECNO("billnum")
 ELSE
      openfiledirect(.F., "billnum")
 ENDIF
 INSERT INTO billnum ;
           (bn_billnum, bn_reserid, bn_rsid, bn_addrid, bn_amount, ;
           bn_history, bn_status, bn_date, bn_window, bn_apid, bn_fpid, bn_fpnr, bn_userid, bn_qrcode) VALUES ;
           (cRetNum, lp_nReserId, l_nRsId, lp_nAddrId, lp_nAmount, ;
           l_cHistory, "OPN", SysDate(), lp_nWindow, lp_nApId, l_nFiscBillNo, l_nFpNr, g_userid, IIF(_screen.oGlobal.lfiskaltrustactive, _screen.oGlobal.cfiskaltrustqrcode, ""))
 IF l_lUsed
      GO l_nRecNo IN billnum
 ELSE
      dclose("billnum")
 ENDIF
 RETURN crEtnum
ENDFUNC
*