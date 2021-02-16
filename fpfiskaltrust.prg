#INCLUDE "include\constdefines.h"
*
*PROCEDURE fpfiskaltrust
LPARAMETERS lp_cMode, lp_uParam1, lp_uParam2
LOCAL l_nSelect, l_lSuccess, l_oFiskalTrust AS cfiskaltrust OF fpfiskaltrust.prg

l_nSelect = SELECT()

l_oFiskalTrust = CREATEOBJECT("cfiskaltrust")
l_lSuccess = l_oFiskalTrust.Start(lp_cMode, lp_uParam1, lp_uParam2)
IF l_lSuccess AND lp_cMode == "DEP_EXPORT"
     Alert("RKSV-DEP Export: " + l_oFiskalTrust.cFilename)
ENDIF

SELECT(l_nSelect)

RETURN l_lSuccess
ENDPROC
*
DEFINE CLASS cfiskaltrust AS Custom
*
#IF .F. && Make sure this is false, otherwise error
     *-- Define This for IntelliSense use
     LOCAL this AS cfiskaltrust OF fpfiskaltrust.prg
#ENDIF
*
cCountry = "AT"    && STRCONV(cCountry,15) = "4154"
cReceiptCase = "4707387510509010944"     && 0x4154000000000000
*cCountry = "DE"   && STRCONV(cCountry,15) = "4445"
*cReceiptCase = "4919338167976329216"    && 0x4445000000000000
cLogFile = ""
lLog = .F.
cMode = ""
nReceiptCase = 0
nReserId = 0
nWindow = 0
nDEPStartTicks = 0
nDEPEndTicks = 0
cResCur = ""
cRequest = ""
cResponse = ""
cFilename = ""
luseexternalhttp = .F.
oHttp = .NULL.
nRESLOVETIMEOUT = 10
nCONNECTTIMEOUT = 10
nSENDTIMEOUT = 10
nRECIVETIMEOUT = 10
cproxy = ""
cserver = ""
cError = ""
cQRCodeData = ""
lQRCodeRequired = .T.

*
PROCEDURE Start
LPARAMETERS lp_cMode, lp_uParam1, lp_uParam2
LOCAL l_lSuccess, l_cFilename, l_nFlagDebit

IF NOT PEMSTATUS(_screen.oGlobal, "lDontSendDebitor", 5)
     _screen.oGlobal.AddProperty("lDontSendDebitor", (UPPER(ReadINI(FULLPATH(INI_FILE), [fiskaltrust], [dontsenddebitor])) == "YES"))
ENDIF
this.cserver = _screen.oGlobal.cfiskaltrusturl + "json/sign"
this.cproxy = _screen.oGlobal.cfiskaltrustproxy
this.cLogFile = _screen.oGlobal.cHotelDir + "fiskaltrust.log"
this.luseexternalhttp = _screen.oGlobal.lfiskaltrustuseexternalhttp
this.lLog = _screen.oGlobal.lfiskaltrustlog

this.cMode = lp_cMode

_screen.oGlobal.cfiskaltrustqrcode = ""
l_nFlagDebit = 0
DO CASE
     CASE this.cMode = "ZERO_SLIP"
          l_lSuccess = this.ConvertNullToJSON("2")
     CASE this.cMode = "START-UP_SLIP"
          l_lSuccess = this.ConvertNullToJSON("3")
     CASE this.cMode = "SHUT-DOWN_SLIP"
          l_lSuccess = this.ConvertNullToJSON("4")
     CASE this.cMode = "MONTH_SLIP"
          l_lSuccess = this.ConvertNullToJSON("5")
     CASE this.cMode = "YEAR_SLIP"
          l_lSuccess = this.ConvertNullToJSON("6")
     CASE this.cMode = "DEP_EXPORT"
          this.cFilename = PUTFILE("RKSV-DEP Export :", _screen.oGlobal.cfiskaltrustcashboxid+"_"+TRANSFORM(Time2Ticks()), "json")
          this.nDEPStartTicks = Time2Ticks(lp_uParam1)
          this.nDEPEndTicks = Time2Ticks(lp_uParam2)
          this.cserver = _screen.oGlobal.cfiskaltrusturl + "json/journal?type="+this.GetReceiptCase(1)+"&from="+TRANSFORM(this.nDEPStartTicks)+"&to="+TRANSFORM(this.nDEPEndTicks)
          this.cRequest = ""
          l_lSuccess = .T.
     OTHERWISE
          IF g_Demo OR glTraining
               this.nReceiptCase = BITOR(this.nReceiptCase,0x20000) && 0x4154000000020000
          ENDIF
          IF this.cMode = "CXL"
               this.cMode = "RESERVATION"
               this.nReceiptCase = BITOR(this.nReceiptCase,0x40000) && 0x4154000000040000
          ENDIF
          IF INLIST(this.cMode, "LEDGER", "DEPOSIT")
               this.nReceiptCase = BITOR(this.nReceiptCase,0xA)     && 0x415400000000000A
          ENDIF
          this.nReserId = EVL(lp_uParam1,0)
          this.nWindow = EVL(lp_uParam2,0)
          l_lSuccess = this.GetBillData()

          IF NOT l_lSuccess
               RETURN l_lSuccess
          ENDIF

          l_lSuccess = this.ConvertBillToJSON(@l_nFlagDebit)
ENDCASE

IF NOT l_lSuccess OR _screen.oGlobal.lDontSendDebitor AND l_nFlagDebit = 1
     RETURN l_lSuccess
ENDIF

l_lSuccess = this.SendJSON()

IF NOT l_lSuccess
     IF NOT EMPTY(this.cError)
          Alert(this.cError, "Fiskaltrust Fehler")
     ENDIF
     RETURN l_lSuccess
ENDIF

IF this.cMode = "DEP_EXPORT"
     l_lSuccess = this.ParseResponseDEP()
ELSE     
     l_lSuccess = this.ParseResponseJSON()
ENDIF

IF NOT EMPTY(this.cError)
     Alert(this.cError, "Fiskaltrust Fehler")
ENDIF
IF NOT l_lSuccess
     RETURN l_lSuccess
ENDIF

_screen.oGlobal.cfiskaltrustqrcode = this.cQRCodeData

RETURN l_lSuccess
ENDPROC
*
PROCEDURE GetBillData
LOCAL i, l_nRecno, l_lSuccess, l_cPostCur, l_cResCur, l_nWindow, l_cHotelLangNum, l_cSql, l_nReserId, l_oPost, l_cVatNr, l_nVatPct

l_lSuccess = .T.

l_nSelect = SELECT()

l_cPostCur = SYS(2015)
l_cResCur = SYS(2015)
this.cResCur = l_cResCur

l_nWindow = this.nWindow
l_nReserId = this.nReserId

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

DO CASE
     CASE this.cMode = "RESERVATION"
          SELECT *, 0 AS ps_vatnr, CAST(IIF(ps_vat0 <> 0,"0","")+IIF(ps_vat1 <> 0,"1","")+IIF(ps_vat2 <> 0,"2","")+IIF(ps_vat3 <> 0,"3","")+IIF(ps_vat4 <> 0,"4","")+IIF(ps_vat5 <> 0,"5","")+IIF(ps_vat6 <> 0,"6","")+IIF(ps_vat7 <> 0,"7","")+IIF(ps_vat8 <> 0,"8","")+IIF(ps_vat9 <> 0,"9","") AS char(10)) AS vatnr FROM post ;
               WHERE ps_reserid = l_nReserId AND ps_window = l_nWindow AND NOT ps_cancel AND (ps_split OR EMPTY(ps_ratecod)) AND (ps_paynum > 0 OR ps_units <> 0) ;
               INTO CURSOR &l_cPostCur READWRITE
          * Next code is used for posts with multiple VAT rates. For example room charge with different VAT rates.
          SCAN FOR LEN(ALLTRIM(vatnr)) > 1
               l_nRecno = RECNO()
               SCATTER FIELDS EXCEPT vatnr MEMO NAME l_oPost
               l_cVatNr = ALLTRIM(vatnr)
               FOR i = 1 TO LEN(l_cVatNr)
                    l_oPost.ps_vatnr = INT(VAL(SUBSTR(l_cVatNr,i,1)))
                    IF l_oPost.ps_vatnr = 0
                         l_oPost.ps_vatnr = DLookUp("picklist", "pl_label = 'VATGROUP  ' AND EMPTY(pl_numval)", "pl_numcod")
                         l_oPost.ps_amount = ROUND(l_oPost.ps_vat0, 2)
                    ELSE
                         l_nVatPct = DLookUp("picklist", "pl_label = 'VATGROUP  ' AND pl_numcod = " + SqlCnv(l_oPost.ps_vatnr), "pl_numval")
                         l_oPost.ps_amount = ROUND(EVALUATE("l_oPost.ps_vat" + TRANSFORM(l_oPost.ps_vatnr)) * (100+IIF(param.pa_exclvat,0,l_nVatPct)) / l_nVatPct, 2)
                    ENDIF
                    IF i = 1
                         GATHER NAME l_oPost FIELDS ps_amount, ps_vatnr
                    ELSE
                         INSERT INTO &l_cPostCur FROM NAME l_oPost
                    ENDIF
               ENDFOR
               GO l_nRecno
          ENDSCAN
     CASE this.cMode = "PASSERBY"
          SELECT *, 0 AS ps_vatnr FROM post WHERE .F. INTO CURSOR (l_cPostCur) READWRITE
          APPEND FROM DBF("query") && Articles
          APPEND FROM DBF("tblpostcursor") && Payments
     CASE this.cMode = "PHONECALLS"
          SELECT *, 0 AS ps_vatnr FROM post WHERE .F. INTO CURSOR (l_cPostCur) READWRITE
          APPEND FROM DBF("query") && Articles & Payments
     CASE this.cMode = "LEDGER"
          SELECT *, 0 AS ps_vatnr FROM post WHERE .F. INTO CURSOR (l_cPostCur) READWRITE
          APPEND FROM DBF("query") && Payments
ENDCASE

IF l_lSuccess
     l_cHotelLangNum = GetHotelLangNum()

     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT PLU, Descript, SUM(Units) AS Units, Amount, Billnum, VAT, pl_numval AS VATPct, ar_artityp AS Artype, ps_supplem AS Supplem, Cmd, printorder FROM ;
          ( ;
          SELECT CAST(IIF('@' $ ps_ifc,STREXTRACT(ps_ifc,'@','|'),ps_artinum) AS Char(5)) AS PLU, ;
               CAST(IIF('@' $ ps_ifc,STREXTRACT(ps_ifc,'|',''),<<"ar_lang"+l_cHotelLangNum>>) AS Char(40)) AS Descript, ;
               CAST(ps_units AS Numeric(10,2)) AS Units, ;
               CAST(ps_amount AS Numeric(10,2)) AS Amount, ;
               CAST(ps_billnum AS Char(10)) AS Billnum, ;
               pl_user1 AS VAT, ;
               pl_numval, ;
               ar_artityp, ;
               ps_supplem, ;
               CAST(<<sqlcnv("S",.T.)>> AS Char(2)) AS Cmd, ;
               CAST(1 AS Numeric(1)) AS printorder ;
               FROM <<l_cPostCur>> ;
               INNER JOIN article ON ps_artinum = ar_artinum ;
               INNER JOIN picklist ON pl_label = "VATGROUP" AND pl_numcod = EVL(ps_vatnr,ar_vat) ;
               WHERE ps_artinum > 0 AND NOT ps_cancel AND (ps_split OR EMPTY(ps_ratecod)) AND ps_units <> 0 ;
          ) AS c1 ;
     GROUP BY PLU, Descript, Amount, VAT, Cmd, printorder ORDER BY printorder, PLU ;
     HAVING Amount <> 0 AND SUM(Units) <> 0 ;
     UNION ALL ;
     SELECT CAST(ps_paynum AS Char(5)) AS PLU, ;
          CAST(pm_lang<<l_cHotelLangNum>> AS Char(40)) AS Descript, ;
          CAST(0 AS Numeric(10,2)) AS Units, ;
          SUM(CAST(-ps_amount AS Numeric(10,2))) AS Amount, ;
          ps_billnum AS Billnum, ;
          '' AS VAT, ;
          0, ;
          0, ;
          "", ;
          CAST(ALLTRIM(pm_user1) AS Char(2)) AS Cmd, ;
          CAST(3 AS Numeric(1)) AS printorder ;
          FROM <<l_cPostCur>> ;
          INNER JOIN paymetho ON ps_paynum = pm_paynum ;
          WHERE ps_paynum > 0 AND NOT ps_cancel ;
          GROUP BY PLU, Descript, Units, Cmd, printorder ;
          HAVING Amount <> 0 ;
          INTO CURSOR <<l_cResCur>>
     ENDTEXT
     l_cSql = STRTRAN(l_cSql, ";", "")
     &l_cSql
     IF NOT USED(l_cResCur) OR RECCOUNT(l_cResCur)=0
          l_lSuccess = .F.
     ENDIF
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE ConvertNullToJSON
LPARAMETERS lp_cCmd
LOCAL l_cJSON

TEXT TO l_cJSON TEXTMERGE NOSHOW
{
     "ftCashBoxID": "<<_screen.oGlobal.cfiskaltrustcashboxid>>",
     "cbTerminalID": "<<LEFT(winpc(),8)>>",
     "cbReceiptReference": "",
     "cbReceiptMoment": "<<TTOC(DATETIME(),3)>>",
     "ftReceiptCase": <<this.GetReceiptCase(lp_cCmd)>>,
     "cbChargeItems": [],
     "cbPayItems": []
}
ENDTEXT

this.cRequest = l_cJSON

RETURN .T.
ENDPROC
*
PROCEDURE ConvertBillToJSON
LPARAMETERS l_nFlagDebit
LOCAL l_cJSON, l_nFlagVouch, l_cJSONChargeItems, l_cJSONPayments

STORE "" TO l_cJSON, l_cJSONChargeItems, l_cJSONPayItems
l_nFlagDebit = 0     && l_nFlagDebit = -1: There is regular payments; l_nFlagDebit = 1: There is only debtor payment
l_nFlagVouch = 0     && l_nFlagVouch = -1: There is regular payments; l_nFlagVouch = 1: There is used only vouchers for certain goods (with tax rate)

SELECT (this.cRESCUR)
SCAN
     IF Cmd = "S" AND Artype <> 4
          IF l_nFlagVouch = 0 AND Amount < 0 AND "V#:" $ Supplem     && Using vouchers for certain goods (with tax rate). No any other payments just this vouchers.
               l_nFlagVouch = 1
          ENDIF
          TEXT TO l_cJSONChargeItems ADDITIVE TEXTMERGE NOSHOW
          {
               "Quantity": <<this.ConvDecToString(Units)>>,
               "Description": "<<ALLTRIM(Descript)>>",
               "Amount": <<this.ConvDecToString(Amount)>>,
               "VATRate": <<this.ConvDecToString(VATPct)>>,
               "ftChargeItemCase": <<this.GetReceiptCase(VAT)>>,
               "ProductNumber": "<<ALLTRIM(PLU)>>"
          },
          ENDTEXT
     ELSE
          IF l_nFlagDebit <> -1 AND PADL(ALLTRIM(Cmd),2,"0") >= "0B"     && Using debtor payment.
               l_nFlagDebit = 1
          ELSE
               l_nFlagDebit = -1
          ENDIF
          l_nFlagVouch = -1
          TEXT TO l_cJSONPayItems ADDITIVE TEXTMERGE NOSHOW
          {
               "Quantity": 1.0,
               "Description": "<<ALLTRIM(Descript)>>",
               "Amount": <<this.ConvDecToString(IIF(Artype = 4, -1, 1) * Amount)>>,
               "ftPayItemCase": <<this.GetReceiptCase(IIF(Artype = 4, "06", Cmd))>>,
               "MoneyNumber": "<<ALLTRIM(PLU)>>"
          },
          ENDTEXT
          IF Artype = 4     && Purchasing value vouchers with 0%
               this.nReceiptCase = BITOR(this.nReceiptCase,0xA)
               this.lQRCodeRequired = .F.
          ENDIF
     ENDIF
ENDSCAN
IF LEN(l_cJSONChargeItems) > 0
     l_cJSONChargeItems = LEFT(l_cJSONChargeItems , LEN(l_cJSONChargeItems)-1)
ENDIF
IF LEN(l_cJSONPayItems) > 0
     l_cJSONPayItems = LEFT(l_cJSONPayItems, LEN(l_cJSONPayItems)-1)
ENDIF
IF l_nFlagDebit = 1     && There is only debtor payment.
     this.lQRCodeRequired = .F.
ENDIF
IF l_nFlagVouch = 1     && Using vouchers for certain goods (with tax rate). No any other payments just this vouchers.
     this.nReceiptCase = BITOR(this.nReceiptCase,0xE)
     this.lQRCodeRequired = .F.
ENDIF

TEXT TO l_cJSON TEXTMERGE NOSHOW
{
     "ftCashBoxID": "<<_screen.oGlobal.cfiskaltrustcashboxid>>",
     "cbTerminalID": "<<LEFT(winpc(),8)>>",
     "cbReceiptReference": "<<this.GetBillNum()>>",
     "cbReceiptMoment": "<<this.GetBillDate()>>",
     "ftReceiptCase": <<this.GetReceiptCase(EVL(this.nReceiptCase,1))>>,
     "cbChargeItems": [<<l_cJSONChargeItems>>],
     "cbPayItems": [<<l_cJSONPayItems>>]
}
ENDTEXT

this.cRequest = l_cJSON

RETURN .T.
ENDPROC
*
PROCEDURE ConvDecToString
LPARAMETERS lp_nValue
LOCAL l_cString
l_cString = STRTRAN(TRANSFORM(lp_nValue),",",".")
RETURN l_cString
ENDPROC
*
PROCEDURE GetReceiptCase
LPARAMETERS lp_uCmd
LOCAL l_cHexVal

IF VARTYPE(lp_uCmd) = "N"
     l_cHexVal = RIGHT(TRANSFORM(lp_uCmd,"@0"),6)
ELSE     && VARTYPE(lp_uCmd) = "C"
     l_cHexVal = PADL(ALLTRIM(lp_uCmd),6,"0")
ENDIF

RETURN STUFF(this.cReceiptCase, 12, 8, PADL(INT(VAL(RIGHT(this.cReceiptCase,8))) + EVALUATE("0x"+l_cHexVal),8,"0"))
ENDPROC
*
PROCEDURE GetErrorFromStatus
LOCAL l_cState, l_cError

l_cState = ALLTRIM(STREXTRACT(this.cResponse, '"ftState":', ','))
DO CASE
     CASE l_cState = this.GetReceiptCase("00")
          l_cError = ""
     CASE l_cState = this.GetReceiptCase("01")
          l_cError = "Auﬂer Betrieb! (01)"
     CASE l_cState = this.GetReceiptCase("02")
          l_cError = "SSCD tempor‰r ausgefallen! (02)"
     CASE l_cState = this.GetReceiptCase("04")
          l_cError = "SSCD permanent ausgefallen! (04)"
     CASE l_cState = this.GetReceiptCase("08")
          l_cError = "Nacherfassung aktiv! (08)"
     CASE l_cState = this.GetReceiptCase("10")
          l_cError = "Monatsbericht f‰llig! (10)"
     CASE l_cState = this.GetReceiptCase("20")
          l_cError = "Jahresbericht f‰llig! (20)"
     CASE l_cState = this.GetReceiptCase("40")
          l_cError = "Nachricht / Meldung anstehend! (40)"
     OTHERWISE
ENDCASE

RETURN l_cError
ENDPROC
*
PROCEDURE GetBillNum
LOCAL l_nBillNum, l_cBillNum
LOCAL ARRAY l_aResult(1)
SELECT DISTINCT Billnum FROM (this.cResCur) WHERE NOT EMPTY(Billnum) INTO ARRAY l_aResult
IF TYPE("l_aResult(1)")="C"
     l_cBillNum = l_aResult(1)
ENDIF
IF EMPTY(l_cBillNum)
     l_nBillNum = GetBill(,,,,,,,,,,.T.)
     l_cBillNum = this.ConvDecToString(l_nBillNum)
ENDIF
RETURN l_cBillNum
ENDPROC
*
PROCEDURE GetBillDate
RETURN TTOC(DATETIME(),3)
ENDPROC
*
PROCEDURE SendJSON

LPARAMETERS lp_cRequest, lp_cResponse
LOCAL l_lHttpSuccess, l_cResponse

IF this.luseexternalhttp
     l_lHttpSuccess = this.httpsend_external(this.cRequest, @l_cResponse)
ELSE
     l_lHttpSuccess = this.httpsend_serverxmlhttp(this.cRequest, @l_cResponse)
ENDIF

this.cResponse = l_cResponse

RETURN l_lHttpSuccess
ENDPROC
*
PROCEDURE HTTPSend_External
LPARAMETERS l_cRequest, lp_cResponse

LOCAL l_lSuccess, l_cResult, l_cCmd, l_cServer, l_cXMLFileName, l_cStatus

lp_cResponse = ""
l_cStatus = ""
l_cServer = STRTRAN(this.cServer, "&", "^&")
l_cXMLFileName = CFGetGuid()+".json"
l_cXMLFileName = FULLPATH(ADDBS(SYS(2023))+l_cXMLFileName)
STRTOFILE(l_cRequest,l_cXMLFileName,0)

TEXT TO l_cCmd TEXTMERGE NOSHOW PRETEXT 15
<<FULLPATH(_screen.oGlobal.cHotelDir+"citadelhttp.exe")>> <<l_cServer>> <<l_cXMLFileName>> POST <<IIF(EMPTY(this.cproxy),"NO_PROXY",this.cproxy)>> application/json GET_RESPONSE_INFO <<IIF(this.lLog, "LOG_HTTP DEBUG", "")>>
ENDTEXT

l_lSuccess = .T.

l_cResult = CFExecCommand(l_cCmd)
IF NOT EMPTY(l_cResult)
     l_cStatus = ALLTRIM(STREXTRACT(l_cResult, "___@@@___", "___###___"))
ENDIF

IF EMPTY(l_cResult) OR "getaddrinfow" $ l_cResult OR "no such host" $ l_cResult OR l_cStatus <> "200"
     this.cError = "HTTP connect error! (1)" + CHR(13) + l_cResult
     l_lSuccess = .F.
ENDIF

IF l_lSuccess
     lp_cResponse = l_cResult
ENDIF

DELETE FILE (l_cXMLFileName)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE HTTPSend_ServerXMLHTTP
LPARAMETERS lp_cRequest, lp_cResponse
LOCAL l_lHttpSuccess, l_cHttpResponse, l_oErr, l_cHttpSendError, l_oErr AS Exception, l_oHttp AS MSXML2.ServerXMLHTTP

l_lHttpSuccess = .F.
l_cHttpResponse = ""
l_oErr = .NULL.
lp_cResponse = ""

IF ISNULL(this.oHttp)
     TRY
          this.oHttp = CREATEOBJECT("MSXML2.ServerXMLHTTP")
     CATCH TO l_oErr
          l_cHttpResponse = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                         "|Message:"+TRANSFORM(l_oErr.Message)
     ENDTRY
ENDIF

IF ISNULL(this.oHttp)
     this.cError = l_cHttpResponse + " (2)"
ELSE
     l_oHttp = this.oHttp
     l_oHttp.setTimeouts(this.nRESLOVETIMEOUT*1000,this.nCONNECTTIMEOUT*1000,this.nSENDTIMEOUT*1000,this.nRECIVETIMEOUT*1000)
     l_oHttp.Open("POST", this.cServer, .F.)
     l_oHttp.setRequestHeader('Charset', 'UTF-8')
     l_oHttp.setRequestHeader('Content-Type', 'application/json')
     l_oHttp.setRequestHeader('CashboxID', _screen.oGlobal.cfiskaltrustcashboxid)
     l_oHttp.setRequestHeader('AccessToken', _screen.oGlobal.cfiskaltrustaccesstoken)
     l_oHttp.setOption(2, 13056)
     IF NOT EMPTY(this.cproxy)
          l_oHttp.setProxy(2, this.cproxy, "")
     ENDIF

     l_cHttpSendError = ""
     this.logit("REQUEST: "+lp_cRequest)
     TRY
          l_oHttp.send(lp_cRequest)
     CATCH TO l_oErr
          l_cHttpSendError = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                    "|Message:"+TRANSFORM(l_oErr.Message)
     ENDTRY
     IF EMPTY(l_cHttpSendError)
          l_cHttpResponse = "Status:"+TRANSFORM(l_oHttp.status)+;
                    "|StatusText:"+TRANSFORM(l_oHttp.statusText)+;
                    "|ReadyState:"+TRANSFORM(l_oHttp.readyState)
          IF l_oHttp.status = 200
               l_lHttpSuccess = .T.
               lp_cResponse = l_oHttp.responsetext
               this.logit("RESPONSE: "+lp_cResponse)
          ENDIF
     ELSE
          l_cHttpResponse = l_cHttpSendError
     ENDIF
ENDIF
l_cHttpResponse = "HTTP Connect|TS:"+TRANSFORM(this.nRESLOVETIMEOUT)+","+TRANSFORM(this.nCONNECTTIMEOUT)+","+;
          TRANSFORM(this.nSENDTIMEOUT)+","+TRANSFORM(this.nRECIVETIMEOUT)+"|"+;
          STRTRAN(STRTRAN(l_cHttpResponse,CHR(13),""),CHR(10),"")

IF NOT l_lHttpSuccess
     this.cError = l_cHttpResponse + " (3)"
ENDIF

this.logit(l_cHttpResponse)

RETURN l_lHttpSuccess
ENDPROC
*
PROCEDURE ParseResponseJSON
LOCAL l_oJSON, l_oData, l_oSignature, l_lSuccess

IF NOT '"ftSignatures":[]' $ this.cResponse
     l_oJSON = NEWOBJECT("json","common\progs\json.prg")
     l_oData = l_oJSON.parse(this.cResponse)
     FOR EACH l_oSignature IN l_oData.ftSignatures
          IF l_oSignature.ftSignatureFormat = 3
               IF NOT EMPTY(l_oSignature.Data) AND LEFT(l_oSignature.Data,4) = "_R1-"
                    this.cQRCodeData = l_oSignature.Data
                    l_lSuccess = .T.
                    EXIT
               ENDIF
          ENDIF
     ENDFOR
ENDIF

this.cError = this.GetErrorFromStatus()

RETURN l_lSuccess OR NOT this.lQRCodeRequired
ENDPROC
*
PROCEDURE ParseResponseDEP
LOCAL l_lSuccess

IF NOT EMPTY(this.cFilename)
     STRTOFILE(this.cResponse,this.cFilename)
     IF FILE(this.cFilename)
          l_lSuccess = .T.
     ENDIF
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE LogIt
LPARAMETERS lp_cText
LOCAL l_cFile2, l_nLimit

IF this.lLog AND NOT EMPTY(lp_cText)
     l_cFile2 = this.cLogFile + ".2"
     l_nLimit = 50000000 && 50 MB
     IF FILE(this.cLogFile)
          IF ADIR(l_aFile,LOCFILE(this.cLogFile))>0
               IF l_aFile(2)>l_nLimit
                    IF FILE(l_cFile2)
                         DELETE FILE (l_cFile2)
                    ENDIF
                    RENAME (this.cLogFile) TO (l_cFile2)
               ENDIF
          ENDIF
     ENDIF

     TRY
          STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cText + CHR(13) + CHR(10), this.cLogFile, 1)
     CATCH
     ENDTRY
ENDIF

RETURN .T.
ENDPROC
*
ENDDEFINE
*