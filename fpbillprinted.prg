#DEFINE def_maxlines                          25
#DEFINE def_address_not_found                 "Nije pronaðena adresa za ovaj raèun!"
#DEFINE def_bill_cant_be_printed              "P A Ž NJ A !!!  Nije dozvoljeno izdavanje raèuna!"
#DEFINE def_not_valid_address_for_inv_payment "Za VIRMANSKO plaæanje nisu ispravni podaci o adresi:"
#DEFINE def_address_is_not_company            "Adresa NIJE firma (prazan naziv firme)"
#DEFINE def_no_vat_no_for_company             "PIB NIJE unet za firmu"
*
*PROCEDURE FPBillPrinted
LPARAMETERS lp_cMode, lp_nReserId, lp_nWindow, lp_cProcedure
LOCAL l_cSql, l_lSuccess, l_cPostCur, l_cResCur, l_nSelect, l_cHotelLangNum, l_cErrorMsg, ;
          l_cDrvPath, l_cDrvExe, l_cWinPc, l_cFileName, l_nFpNr, l_lCheckEXE, l_cOperater, l_cFooter
IF NOT EMPTY(lp_cProcedure)
     RETURN &lp_cProcedure
ENDIF

l_lSuccess = .T.
STORE "" TO l_cErrorMsg, l_cOperater, l_cFooter

IF _screen.oGlobal.lfiskaltrustactive
     l_lSuccess = fpfiskaltrust(lp_cMode, lp_nReserId, lp_nWindow)
     RETURN l_lSuccess
ENDIF

IF NOT FPBillPrintedDriverUsed()
     RETURN l_lSuccess
ENDIF

l_cDriver = FPBillPrintedGetDriverFileName()

IF NOT FILE(FULLPATH(l_cDriver))
     l_lSuccess = .F.
     = alert(l_cDriver,GetLangText("PRNTBILL","TXT_FILENOTFOUND"))
     RETURN l_lSuccess
ENDIF

IF NOT USED("fprinter")
     openfiledirect(.F.,"fprinter")
ENDIF

IF NOT USED("terminal")
     openfiledirect(.F.,"terminal")
ENDIF

l_nSelect = SELECT()

l_cPostCur = SYS(2015)
l_cResCur = SYS(2015)

IF NOT USED("post")
     openfiledirect(.F.,"post")
ENDIF
IF NOT USED("picklist")
     openfiledirect(.F.,"picklist")
ENDIF
IF NOT USED("article")
     openfiledirect(.F.,"article")
ENDIF
IF NOT USED("paymetho")
     openfiledirect(.F.,"paymetho")
ENDIF
IF NOT USED("address")
     openfiledirect(.F.,"address")
ENDIF

DO CASE
     CASE lp_cMode = "RESERVATION"
          SELECT * FROM post ;
               WHERE ps_reserid = lp_nReserId AND ps_window = lp_nWindow ;
               INTO CURSOR &l_cPostCur
     CASE lp_cMode = "PASSERBY"
          SELECT * FROM post WHERE .F. INTO CURSOR (l_cPostCur) READWRITE
          APPEND FROM DBF("query") && Articles
          APPEND FROM DBF("tblpostcursor") && Payments
     CASE lp_cMode = "PHONECALLS"
          SELECT * FROM post WHERE .F. INTO CURSOR (l_cPostCur) READWRITE
          APPEND FROM DBF("query") && Articles & Payments
ENDCASE

IF l_lSuccess
     l_lSuccess = FPBillPrintedCheckAddress(l_cPostCur)
ENDIF

IF l_lSuccess
     l_cHotelLangNum = GetHotelLangNum()

     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT PLU, Descript, SUM(Units) AS Units, Price, VAT, Cmd, printorder FROM ;
          ( ;
          SELECT CAST(IIF('@' $ ps_ifc,STREXTRACT(ps_ifc,'@','|'),ps_artinum) AS Char(5)) AS PLU, ;
               CAST(IIF('@' $ ps_ifc,STREXTRACT(ps_ifc,'|',''),<<"ar_lang"+l_cHotelLangNum>>) AS Char(40)) AS Descript, ;
               CAST(ps_units AS Numeric(10,2)) AS Units, ;
               CAST(ps_price AS Numeric(10,2)) AS Price, ;
               CAST(IIF(EMPTY(pl_user3),ar_vat,pl_user3) AS Numeric(1)) AS VAT, ;
               CAST(<<sqlcnv("S",.T.)>> AS Char(1)) AS Cmd, ;
               CAST(1 AS Numeric(1)) AS printorder ;
               FROM <<l_cPostCur>> ;
               INNER JOIN article ON ps_artinum = ar_artinum ;
               INNER JOIN picklist ON pl_label = "VATGROUP" AND pl_numcod = ar_vat ;
               WHERE ps_artinum > 0 AND NOT ps_cancel AND NOT ps_split AND ps_units>0 AND ar_artityp <> <<sqlcnv(3,.T.)>> ;
               AND ps_artinum <> <<sqlcnv(param.pa_posarti,.T.)>> ;
          UNION ALL ;
          SELECT CAST(IIF('@' $ ps_ifc,STREXTRACT(ps_ifc,'@','|'),ps_artinum) AS Char(5)) AS PLU, ;
               CAST(IIF('@' $ ps_ifc,STREXTRACT(ps_ifc,'|',''),<<"ar_lang"+l_cHotelLangNum>>) AS Char(40)) AS Descript, ;
               CAST(ps_units AS Numeric(10,2)) AS Units, ;
               CAST(ps_price AS Numeric(10,2)) AS Price, ;
               CAST(IIF(EMPTY(pl_user3),ar_vat,pl_user3) AS Numeric(1)) AS VAT, ;
               CAST(<<sqlcnv("S",.T.)>> AS Char(1)) AS Cmd, ;
               CAST(1 AS Numeric(1)) AS printorder ;
               FROM <<l_cPostCur>> ;
               INNER JOIN article ON ps_artinum = ar_artinum ;
               INNER JOIN picklist ON pl_label = "VATGROUP" AND pl_numcod = ar_vat ;
               WHERE ps_artinum > 0 AND NOT ps_cancel AND NOT ps_split AND ps_units<0 AND ar_artityp <> <<sqlcnv(3,.T.)>> ;
               AND ps_artinum <> <<sqlcnv(param.pa_posarti,.T.)>> ;
          UNION ALL ;
          SELECT CAST(ps_artinum AS Char(5)) AS PLU, ;
               CAST(<<"ar_lang"+l_cHotelLangNum>> AS Char(40)) AS Descript, ;
               CAST(1 AS Numeric(10,2)) AS Units, ;
               SUM(CAST(ps_price * ps_units AS Numeric(10,2))) AS Price, ;
               CAST(IIF(EMPTY(pl_user3),ar_vat,pl_user3) AS Numeric(1)) AS VAT, ;
               CAST(<<sqlcnv("S",.T.)>> AS Char(1)) AS Cmd, ;
               CAST(1 AS Numeric(1)) AS printorder ;
               FROM <<l_cPostCur>> ;
               INNER JOIN article ON ps_artinum = ar_artinum ;
               INNER JOIN picklist ON pl_label = "VATGROUP" AND pl_numcod = ar_vat ;
               WHERE ps_artinum = <<sqlcnv(param.pa_posarti,.T.)>> AND NOT ps_cancel AND NOT ps_split ;
               GROUP BY 1, 2, 3, 5, 6, 7 ;
          ) AS c1 ;
     GROUP BY PLU, Descript, Price, VAT, Cmd, printorder ORDER BY printorder, PLU ;
     HAVING Price <> 0 AND SUM(Units) <> 0 ;
     UNION ALL ;
     SELECT CAST(0 AS Char(5)) AS PLU, ;
          CAST("" AS Char(40)) AS Descript, ;
          CAST(0 AS Numeric(10,2)) AS Units, ;
          SUM(CAST(-ps_amount AS Numeric(10,2))) AS Price, ;
          0 AS VAT, ;
          CAST(ALLTRIM(pm_user3) AS Char(1)) AS Cmd, ;
          CAST(3 AS Numeric(1)) AS printorder ;
          FROM <<l_cPostCur>> ;
          INNER JOIN paymetho ON ps_paynum = pm_paynum ;
          WHERE ps_paynum > 0 AND NOT ps_cancel ;
          GROUP BY PLU, Descript, Units, Cmd, printorder ;
          HAVING Price > 0 ;
          INTO CURSOR <<l_cResCur>>
     ENDTEXT
     l_cSql = STRTRAN(l_cSql, ";", "")
     &l_cSql
ENDIF

IF l_lSuccess AND USED(l_cResCur)
     l_cDrvPath = ALLTRIM(_screen.oGlobal.ofprinter.fp_drvpath)
     l_cDrvExe = ALLTRIM(_screen.oGlobal.ofprinter.fp_drvfile)
     l_cWinPc = ALLTRIM(_screen.oGlobal.oterminal.tm_winname)
     l_nFpNr = _screen.oGlobal.ofprinter.fp_fpnr
     l_lCheckEXE = (l_cWinPc == ALLTRIM(_screen.oGlobal.ofprinter.fp_winname))
     
     IF FPFXPIsOK()
          IF _screen.oGlobal.ofprinter.fp_setop
               l_cFileName = FPBillPrintedGetFileName()
               l_cOperater = ALLTRIM(g_username)
               DO &l_cDriver WITH "", "OPERATER", l_lSuccess, l_cErrorMsg, "", l_cDrvPath, l_cDrvExe, ;
                         l_cWinPc, l_cFileName,,,l_nFpNr, l_lCheckEXE, l_cOperater
          ENDIF
          IF _screen.oGlobal.ofprinter.fp_setfoot
               l_cFileName = FPBillPrintedGetFileName()
               TRY
                    l_cFooter = EVALUATE(ALLTRIM(_screen.oGlobal.ofprinter.fp_footer))
               CATCH
               ENDTRY
               DO &l_cDriver WITH "", "SETFOOTER", l_lSuccess, l_cErrorMsg, "", l_cDrvPath, l_cDrvExe, ;
                         l_cWinPc, l_cFileName,,,l_nFpNr, l_lCheckEXE,, l_cFooter
          ENDIF
          * Don't check l_lSuccess. Let next command "BILL" check is printer on line.
          * This commands are not so important, and could gives us back false failure reasons.
          l_lSuccess = .F.
          l_cFileName = FPBillPrintedGetFileName()
          DO &l_cDriver WITH "", "BILL", l_lSuccess, l_cErrorMsg, l_cResCur, l_cDrvPath, l_cDrvExe, ;
                    l_cWinPc, l_cFileName,,,l_nFpNr, l_lCheckEXE
     ELSE
          l_lSuccess = .F.
          l_cErrorMsg = "NO_VALID_FXP"
     ENDIF
     IF NOT l_lSuccess
          alert(l_cErrorMsg)
     ENDIF
ELSE
     l_lSuccess = .F.
ENDIF

dclose(l_cPostCur)
dclose(l_cResCur)
SELECT(l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPBillPrintedCheckAddress
LPARAMETERS lp_cPostCur
LOCAL l_lSuccess, l_nSelect, l_cCompInvMarker, l_lFound, l_nAddrId, l_cAdrCur, l_cErrorMsg
l_cCompInvMarker = "X"

IF EMPTY(lp_cPostCur) OR NOT USED(lp_cPostCur)
     RETURN l_lSuccess
ENDIF

l_nSelect = SELECT()
l_lSuccess = .T.

SELECT (lp_cPostCur)
SCAN FOR ps_paynum > 0 AND dlocate("paymetho", "pm_paynum = " + sqlcnv(ps_paynum))
     IF ALLTRIM(paymetho.pm_user2) == l_cCompInvMarker
          l_lFound = .T.
          EXIT
     ENDIF
ENDSCAN

IF l_lFound
     l_nAddrId = INT(_screen.oGlobal.oBill.nAddrId)
     IF l_nAddrId > 0
          l_cAdrCur = sqlcursor("SELECT ad_lname, ad_company, ad_usr9 FROM address WHERE ad_addrid = " + sqlcnv(l_nAddrId,.T.))
     ENDIF
     DO CASE
          CASE l_nAddrId = 0 OR RECCOUNT()=0
               l_cErrorMsg = def_address_not_found
               l_lSuccess = .F.
          CASE EMPTY(ad_company)
               l_cErrorMsg = def_address_is_not_company
               l_lSuccess = .F.
          CASE EMPTY(ad_usr9)
               l_cErrorMsg = def_no_vat_no_for_company
               l_lSuccess = .F.
     ENDCASE
     IF NOT l_lSuccess
          l_cErrorMsg = def_bill_cant_be_printed + CHR(10)+CHR(13) + ;
                    def_not_valid_address_for_inv_payment + CHR(10)+CHR(13) + ;
                    CHR(10)+CHR(13) + ;
                    l_cErrorMsg
          alert(l_cErrorMsg)
     ENDIF
     dclose(l_cAdrCur)
ENDIF

SELECT (l_nSelect)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPBillPrintedGetFileName
LOCAL l_cFileName
l_cFileName = TRANSFORM(nextid("FPFILE"+ALLTRIM(STR(_screen.oGlobal.ofprinter.fp_fpnr,2))))
l_cFileName = PADL(l_cFileName,8,"0")
RETURN l_cFileName
ENDPROC
*
PROCEDURE FPBillPrintedGetDriverFileName
LOCAL l_cFxp
l_cFxp = FORCEEXT("FP" + ALLTRIM(param.pa_fiscprt),"fxp")
IF NOT EMPTY(_screen.oGlobal.choteldir)
	l_cFxp = _screen.oGlobal.choteldir + l_cFxp
ENDIF
RETURN l_cFxp
ENDPROC
*
PROCEDURE FPBillPrintedDriverUsed
IF NOT USED("param")
     openfiledirect(.F.,"param")
ENDIF

IF EMPTY(param.pa_fiscprt) OR g_lAutomationMode ;&& Don't print fiscal bills when running in automation mode
          OR _screen.oGlobal.oterminal.tm_fpoff
     RETURN .F.
ELSE
     RETURN .T.
ENDIF
ENDPROC
*
PROCEDURE FPBillPrintedCheckFiscalBillNumber
LOCAL l_nFiscBillNo, l_cIdCode, l_nUserChecked
l_nFiscBillNo = 0
IF FPBillPrintedDriverUsed()
     l_nUserChecked = 0
     l_cIdCode = "FPBILL"+ALLTRIM(STR(_screen.oGlobal.ofprinter.fp_fpnr,2))
     l_nFiscBillNo = nextid(l_cIdCode)
     l_nUserChecked = INPUTBOX(GetLangText("FISCAL","TXT_FISCAL_BILL"), ;
                         GetLangText("FISCAL","TXT_CHECK_FISCAL_BILL_NUMBER"), ;
                         TRANSFORM(l_nFiscBillNo) ;
                         )
     l_nUserChecked = INT(VAL(l_nUserChecked))
     IF NOT EMPTY(l_nUserChecked) AND l_nUserChecked <> l_nFiscBillNo
          l_nFiscBillNo = l_nUserChecked
          UPDATE id SET id_last = l_nFiscBillNo WHERE id_code = l_cIdCode
          FLUSH
     ENDIF
ENDIF
g_nLastFiscalBillNr = l_nFiscBillNo
RETURN l_nFiscBillNo
ENDPROC
*
PROCEDURE FPBillPrintedGetFpNr
IF FPBillPrintedDriverUsed()
     RETURN _screen.oGlobal.ofprinter.fp_fpnr
ELSE
     RETURN 0
ENDIF
ENDPROC
*
PROCEDURE FPBillPrintedShowCommands
     DoForm("frmbillfiscalprinter", "forms\billfiscalprinter")
ENDPROC
*
PROCEDURE FPBillPrintedCommand
LPARAMETERS lp_cCommand, lp_uParam1, lp_uParam2
LOCAL l_cDrvPath, l_cDrvExe, l_cWinPc, l_cFileName, l_cErrorMsg, l_lSuccess, l_cDriver, ;
          l_cHotelLangNum, l_cArtCur, l_nFpNr, l_lCheckEXE
STORE "" TO l_cErrorMsg, l_cArtCur

l_cDriver = FPBillPrintedGetDriverFileName()

IF NOT FILE(FULLPATH(l_cDriver))
     l_lSuccess = .F.
     = alert(l_cDriver,GetLangText("PRNTBILL","TXT_FILENOTFOUND"))
     RETURN l_lSuccess
ENDIF

IF NOT FPFXPIsOK()
     l_lSuccess = .F.
     = alert(l_cDriver,"NO_VALID_FXP")
     RETURN l_lSuccess
ENDIF

IF NOT USED("param")
     openfiledirect(.F.,"param")
ENDIF
IF NOT USED("article")
     openfiledirect(.F.,"article")
ENDIF
IF NOT USED("id")
     openfiledirect(.F.,"id")
ENDIF
IF NOT USED("picklist")
     openfiledirect(.F.,"picklist")
ENDIF

IF INLIST(lp_cCommand, "X-READER", "Z-READER", "P-READER", "DELETE_ALL_ARTICLES", "SEND_ALL_ARTICLES", "READ_ALL_ARTICLES", "SEND_VAT_GROUPS")
     DO CASE
          CASE lp_cCommand = "P-READER"
               IF EMPTY(lp_uParam1)
                    lp_uParam1 = DATE()
               ENDIF
               IF EMPTY(lp_uParam2)
                    lp_uParam2 = DATE()
               ENDIF
          CASE lp_cCommand = "SEND_ALL_ARTICLES"
               l_cArtCur = SYS(2015)
               l_cHotelLangNum = GetHotelLangNum()
               TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
               SELECT CAST(ar_artinum AS Char(5)) AS PLU, ;
                      CAST(<<"ar_lang"+GetHotelLangNum())>> AS Char(40)) AS Descript, ;
                      CAST(ar_price AS Numeric(10,2)) AS Price, ar_vat AS VAT ;
                      FROM article ;
                      WHERE NOT ar_inactiv ;
                      ORDER BY ar_artinum ;
                      INTO CURSOR <<l_cArtCur>>
               ENDTEXT
               l_cSql = STRTRAN(l_cSql, ";", "")
               &l_cSql
          CASE lp_cCommand = "SEND_VAT_GROUPS"
               TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
                    SELECT CAST(pl_user3 AS Numeric(2)) AS c_vatgrp, CAST(pl_numval AS Numeric(5,2)) AS c_vatpct 
                         FROM picklist 
                         WHERE pl_label = 'VATGROUP  ' AND pl_user3 <> '  '
                         ORDER BY 1
               ENDTEXT
               l_cArtCur = sqlcursor(l_cSql)
     ENDCASE


     l_cDrvPath = ALLTRIM(_screen.oGlobal.ofprinter.fp_drvpath)
     l_cDrvExe = ALLTRIM(_screen.oGlobal.ofprinter.fp_drvfile)
     l_cWinPc = ALLTRIM(_screen.oGlobal.oterminal.tm_winname)
     l_cFileName = FPBillPrintedGetFileName()
     l_nFpNr = _screen.oGlobal.ofprinter.fp_fpnr
     l_lCheckEXE = (l_cWinPc == ALLTRIM(_screen.oGlobal.ofprinter.fp_winname))

     DO &l_cDriver WITH "", lp_cCommand, l_lSuccess, l_cErrorMsg, l_cArtCur, l_cDrvPath, l_cDrvExe, ;
               l_cWinPc, l_cFileName, lp_uParam1, lp_uParam2, l_nFpNr, l_lCheckEXE
     
     DO CASE
          CASE lp_cCommand = "SEND_ALL_ARTICLES"
               dclose(l_cArtCur)
          CASE lp_cCommand = "READ_ALL_ARTICLES"
               FPBillPrintedPrintArticles(lp_uParam1)
          CASE lp_cCommand = "SEND_VAT_GROUPS"
               dclose(l_cArtCur)
     ENDCASE
ELSE
     l_cErrorMsg = "INVALID_COMMAND"
ENDIF
IF NOT l_lSuccess
     l_cErrorMsg = FPLimitResponseMsg(l_cErrorMsg)
     alert(l_cErrorMsg)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPBillPrintedPrintArticles()
LPARAMETERS lp_cText
LOCAL l_cArtTmpCur, l_cPoint, l_cPilotTmpCur, l_cArticleListTempFile, l_nSelect

IF EMPTY(lp_cText)
     RETURN .F.
ENDIF

l_nSelect = SELECT()
l_cArtTmpCur = SYS(2015)
l_cPoint = SET("Point")
SET POINT TO "."
l_cArticleListTempFile = filetemp("txt")
STRTOFILE(lp_cText, l_cArticleListTempFile)
l_cPilotTmpCur = SYS(2015)
CREATE CURSOR (l_cPilotTmpCur) (dfield C(1))
SELECT CAST(0 AS Char(5)) AS PLU, ;
       CAST("" AS Char(40)) AS Descript, ;
       CAST("" AS Char(5)) AS Qty, ;
       CAST("" AS Char(2)) AS Units, ;
       CAST(0 AS Numeric(12,2)) AS Price, ;
       "  " AS VAT ;
       FROM (l_cPilotTmpCur) ;
       WHERE .F. ;
       INTO CURSOR (l_cArtTmpCur) READWRITE
APPEND FROM (l_cArticleListTempFile) DELIMITED WITH TAB
GO TOP
DELETE NEXT 2
SCAN ALL
     DO CASE 
          CASE VAT = "E"
               REPLACE VAT WITH "08"
          CASE VAT = "G"
               REPLACE VAT WITH "00"
          CASE VAT = "Ð"
               REPLACE VAT WITH "18"
          OTHERWISE
               REPLACE VAT WITH "??"
     ENDCASE
ENDSCAN
SELECT * FROM (l_cArtTmpCur) INTO CURSOR (l_cArtTmpCur)
GO TOP
DISPLAY FIELDS PLU, Descript, Qty, Price, VAT ALL TO PRINTER PROMPT NOCONSOLE

SET POINT TO l_cPoint
DELETE FILE (l_cArticleListTempFile)
dclose(l_cArtTmpCur)
dclose(l_cPilotTmpCur)

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE FPLimitResponseMsg
LPARAMETERS lp_cErrorMsg
LOCAL i
LOCAL ARRAY l_aErrMsgLines(1)
IF EMPTY(lp_cErrorMsg)
     RETURN lp_cErrorMsg
ENDIF

* limit lines in response to def_maxlines
= ALINES(l_aErrMsgLines,lp_cErrorMsg)
IF ALEN(l_aErrMsgLines,1)>def_maxlines
     lp_cErrorMsg = ""
     FOR i = 1 TO def_maxlines
          lp_cErrorMsg = lp_cErrorMsg + l_aErrMsgLines(i) + CHR(13) + CHR(10)
     ENDFOR
ENDIF

RETURN lp_cErrorMsg
ENDPROC
*
PROCEDURE FPFXPIsOK
* check is this valid fxp file, or some other dummy file.
LOCAL l_cFxpName, l_cVersion, l_lFailed
l_cFxpName = FPBillPrintedGetDriverFileName()
l_cVersion = "VERSION"
l_lFailed = .F.
TRY
     DO &l_cFxpName WITH l_cVersion
CATCH
     l_lFailed = .T.
ENDTRY
RETURN NOT l_lFailed
ENDPROC
*