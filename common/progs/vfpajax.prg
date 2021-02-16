* Class cHTTPDataSend can be used to send XML and receive responese.

* When called directly, tests are run.
* You must set those enviroment variables, to make it work:
*
* VFPAJAX_DESKHRSIMWEB_SERVER - Full URL to deskhrsimweb.exe server. Example: http://localhost:29613
* VFPAJAX_PROXY - Full URL to proxy server, when used. Example: http://localhost:8888
* VFPAJAX_EXTERNAL - YES when citadelhttp.exe should be used to create HTTP requests.
* VFPAJAX_HRS_SERVER - Full URL to Hrs server. Example: https://zimmerdemo.im-web.de/Schnittstellen/ZiW.php
* VFPAJAX_HRS_COMPANY - Login Company. Example : jetbrain
* VFPAJAX_HRS_USER - Login user. Example: smith
* VFPAJAX_HRS_PASSWORD - Login password. Example: secret
* VFPAJAX_HRS_COMPANY_ID - Company ID. Example: xeac31f51a844f1

PRIVATE p_oVFPAJAXParams
p_oVFPAJAXParams = CREATEOBJECT("Empty")

VA_Init()

CLEAR

VA_HRS_Test()
VA_DESKHRSIMWEB_Test()

ENDPROC
*
PROCEDURE VA_Init()

ADDPROPERTY(p_oVFPAJAXParams, "cDESKHRSIMWEBServer", GETENV('VFPAJAX_DESKHRSIMWEB_SERVER'))
IF EMPTY(p_oVFPAJAXParams.cDESKHRSIMWEBServer)
     p_oVFPAJAXParams.cDESKHRSIMWEBServer = "http://localhost:29613"
ENDIF
p_oVFPAJAXParams.cDESKHRSIMWEBServer = VA_Strip_FS(p_oVFPAJAXParams.cDESKHRSIMWEBServer)

ADDPROPERTY(p_oVFPAJAXParams, "cProxy", GETENV('VFPAJAX_PROXY'))

ADDPROPERTY(p_oVFPAJAXParams, "lUseExternalHTTPClient", IIF(GETENV('VFPAJAX_EXTERNAL')=="YES",.T.,.F.))

ADDPROPERTY(p_oVFPAJAXParams, "cHRSServer", GETENV('VFPAJAX_HRS_SERVER'))
IF EMPTY(p_oVFPAJAXParams.cHRSServer)
     p_oVFPAJAXParams.cHRSServer = "https://zimmerdemo.im-web.de/Schnittstellen/ZiW.php"
ENDIF
p_oVFPAJAXParams.cHRSServer = VA_Strip_FS(p_oVFPAJAXParams.cHRSServer)

ADDPROPERTY(p_oVFPAJAXParams, "cHRSCompany", GETENV('VFPAJAX_HRS_COMPANY'))
ADDPROPERTY(p_oVFPAJAXParams, "cHRSUser", GETENV('VFPAJAX_HRS_USER'))
ADDPROPERTY(p_oVFPAJAXParams, "cHRSPassword", GETENV('VFPAJAX_HRS_PASSWORD'))
ADDPROPERTY(p_oVFPAJAXParams, "cHRSCompanyId", GETENV('VFPAJAX_HRS_COMPANY_ID'))

ENDPROC
*
PROCEDURE VA_Strip_FS()
LPARAMETERS lp_cServer
IF EMPTY(lp_cServer)
     RETURN ""
ENDIF
IF RIGHT(lp_cServer,1)="/"
     lp_cServer = LEFT(lp_cServer, LEN(lp_cServer)-1)
ENDIF
RETURN lp_cServer
ENDPROC
*
PROCEDURE VA_DESKHRSIMWEB_Test
LOCAL l_oHTTP, l_oXML, l_oNodes, l_oNode, l_oRoomRates, l_oSeasons, l_oSeason, l_nSeasonId, l_oAddonPrices, l_nPriceId, l_nPrice

VA_Log("START")

* http://localhost:29613/getprices?token=f97b4d11-3784-4057-902d-3da683693ce4&categoryid=5387

l_oParams = CREATEOBJECT("Empty")
ADDPROPERTY(l_oParams, "cServer", p_oVFPAJAXParams.cDESKHRSIMWEBServer + "/getprices")
ADDPROPERTY(l_oParams, "cProxy", p_oVFPAJAXParams.cProxy)
ADDPROPERTY(l_oParams, "lUseExternalHTTPClient", p_oVFPAJAXParams.lUseExternalHTTPClient)
ADDPROPERTY(l_oParams, "cLogFile", "")
ADDPROPERTY(l_oParams, "cContentType", "text/html")
ADDPROPERTY(l_oParams, "lGET", .T.)

l_oHTTP = CREATEOBJECT("cHTTPDataSend", l_oParams)
l_oXML = l_oHTTP.Send("token=f97b4d11-3784-4057-902d-3da683693ce4&categoryid=5387")

IF ISNULL(l_oXML)
     RETURN .F.
ENDIF

l_oRoomRates = l_oXML.selectSingleNode("/root/category/roomrates_get_rs")
IF NOT ISNULL(l_oRoomRates)
     l_oSeasons = l_oRoomRates.selectNodes("season")
     FOR EACH l_oSeason IN l_oSeasons
          l_nSeasonId = l_oHTTP.GetAttribute("season_id","I",l_oSeason)
          VA_Log("season_id: " + TRANSFORM(l_nSeasonId))

          l_oAccommodationPrices = l_oSeason.selectNodes("accommodations/price")
          FOR EACH l_oAccommodationPrice IN l_oAccommodationPrices
               l_nPriceId = l_oHTTP.GetAttribute("price_id","I",l_oAccommodationPrice)
               l_nPrice = l_oHTTP.GetNodeText("value","B",l_oAccommodationPrice)
               VA_Log("accommodation|price_id: "+TRANSFORM(l_nPriceId)+"|addon_id: "+TRANSFORM(l_nAddonId)+"|value: "+TRANSFORM(l_nPrice))
          ENDFOR

          l_oAddonPrices = l_oSeason.selectNodes("addons/price")
          FOR EACH l_oAddonPrice IN l_oAddonPrices
               l_nPriceId = l_oHTTP.GetAttribute("price_id","I",l_oAddonPrice)
               l_nAddonId = l_oHTTP.GetNodeText("addon_id","B",l_oAddonPrice)
               l_nPrice = l_oHTTP.GetNodeText("value","B",l_oAddonPrice)
               VA_Log("addon|price_id: "+TRANSFORM(l_nPriceId)+"|addon_id: "+TRANSFORM(l_nAddonId)+"|value: "+TRANSFORM(l_nPrice))
          ENDFOR

     ENDFOR
ENDIF

l_oAllSeasons = l_oXML.selectSingleNode("/root/category/season_get_all_rs")
IF NOT ISNULL(l_oAllSeasons)
     l_oSeasons = l_oAllSeasons.selectNodes("season")
     FOR EACH l_oSeason IN l_oSeasons
          l_nSeasonId = l_oHTTP.GetAttribute("season_id","I",l_oSeason)
          l_cSeasonName = l_oHTTP.GetNodeText("name","C",l_oSeason)
          l_cSeasonStart = l_oHTTP.GetNodeText("start","C",l_oSeason)
          l_cSeasonEnd = l_oHTTP.GetNodeText("end","C",l_oSeason)
          VA_Log("season|season_id: "+TRANSFORM(l_nSeasonId)+"|name: "+TRANSFORM(l_cSeasonName)+"|start: "+TRANSFORM(l_cSeasonStart)+"|end: "+TRANSFORM(l_cSeasonEnd))
     ENDFOR
ENDIF

l_oAddonTypes = l_oXML.selectNodes("/root/category/roomrate_get_addon_types_rs/addon_type")
IF NOT ISNULL(l_oAddonTypes)
     FOR EACH l_oAddonType IN l_oAddonTypes
          l_nAddonId = l_oHTTP.GetAttribute("addon_id","I",l_oAddonType)
          l_cAddonName = l_oHTTP.GetNodeText("name","C",l_oAddonType)
          VA_Log("addontype|addon_id: "+TRANSFORM(l_nAddonId)+"|name: "+TRANSFORM(l_cAddonName))
     ENDFOR
ENDIF

VA_Log("END")

ENDPROC
*
PROCEDURE VA_HRS_Test
LOCAL l_cXML, l_oXMLSend AS cHTTPDataSend OF vfpajax.prg, l_oXMLResponse, l_oNodes, l_nTID, l_oNode, l_oParams

VA_Log("START")

l_oParams = CREATEOBJECT("Empty")
ADDPROPERTY(l_oParams, "cXML", "")
ADDPROPERTY(l_oParams, "cServer", p_oVFPAJAXParams.cHRSServer)
ADDPROPERTY(l_oParams, "cProxy", p_oVFPAJAXParams.cProxy)
ADDPROPERTY(l_oParams, "lUseExternalHTTPClient", p_oVFPAJAXParams.lUseExternalHTTPClient)
ADDPROPERTY(l_oParams, "cLogFile", "")
ADDPROPERTY(l_oParams, "cContentType", "application/x-www-form-urlencoded")
ADDPROPERTY(l_oParams, "cFormatBeforeSend", ["xml=" + UrlEncode(STRCONV(this.cXmlRequest,9))])


l_oXMLSend = CREATEOBJECT("cHTTPDataSend", l_oParams)

TEXT TO l_cXML TEXTMERGE NOSHOW PRETEXT 15
<?xml version="1.0" encoding="UTF-8"?>
<branch_get_rq xmlns="https://zimmer.im-web.de/Schnittstellen/xmlschema">
  <authentication>
    <company><<p_oVFPAJAXParams.cHRSCompany>></company>
    <user><<p_oVFPAJAXParams.cHRSUser>></user>
    <password><<p_oVFPAJAXParams.cHRSPassword>></password>
  </authentication>
  <company_id><![CDATA[<<p_oVFPAJAXParams.cHRSCompanyId>>]]></company_id>
  <branches>
  </branches>
  <branch_data_get/>
</branch_get_rq>
ENDTEXT

l_oXMLResponse = l_oXMLSend.Send(l_cXML)

IF ISNULL(l_oXMLResponse)
     RETURN .F.
ENDIF

l_oNodes = l_oXMLResponse.selectNodes("/branch_get_rs/branches/branch")

FOR EACH l_oNode IN l_oNodes
     l_nTID = l_oXMLSend.GetAttribute("tid","I",l_oNode)
     IF NOT EMPTY(l_nTID)
          VA_Log(TRANSFORM(l_nTID) + " " + l_oXMLSend.GetNodeText("name",,,l_oNode))
     ENDIF
ENDFOR

VA_Log("END")

ENDPROC
*
PROCEDURE VA_Log
LPARAMETERS lp_cEntry
? TRANSFORM(DATETIME()) + " " + PROGRAM(2) + " " + lp_cEntry
ENDPROC
*
DEFINE CLASS cHTTPDataSend AS Custom
*
cURL = ""
cProxy = ""
oNode = .NULL.
oParams = .NULL.
oHTTPConnection = .NULL.
*
PROCEDURE Init
LPARAMETERS lp_oParams
IF VARTYPE(lp_oParams) = "O"
     this.oParams = lp_oParams
ENDIF
ENDPROC
*
PROCEDURE Send
LPARAMETERS lp_cXML
LOCAL l_oXMLResponse
l_oXMLResponse = NULL

IF VARTYPE(this.oParams)<>"O"
     RETURN l_oXMLResponse
ENDIF
IF TYPE("this.oParams.cXML")<>"C"
     ADDPROPERTY(this.oParams, "cXML", "")
ENDIF

this.oParams.cXML = lp_cXML

this.oHTTPConnection = CREATEOBJECT("cHTTP", this.oParams)
IF this.oHTTPConnection.HttpSend()
     l_oXMLResponse = this.oHTTPConnection.oXMLResponse
ENDIF

RETURN l_oXMLResponse
ENDPROC
*
PROCEDURE GetNodeText
LPARAMETERS lp_cNodePath, lp_cType, lp_oParent, lp_oNode
LOCAL l_cText, l_oNode, l_uRetVal
l_cText = ""
l_uRetVal = ""
IF VARTYPE(lp_cType)="L"
     lp_cType = "C"
ENDIF
IF VARTYPE(lp_oNode)="O"
     l_oNode = lp_oNode
ELSE
     IF VARTYPE(lp_oParent)<>"O"
          lp_oParent = this.oNode
     ENDIF
     IF NOT ISNULL(lp_oParent) AND NOT EMPTY(lp_cNodePath)
          l_oNode = lp_oParent.selectSingleNode(lp_cNodePath)
     ENDIF
ENDIF
IF NOT ISNULL(l_oNode) AND TYPE("l_oNode.Text")="C"
     l_cText = ALLTRIM(STRCONV(l_oNode.Text,11))
ENDIF
DO CASE
     CASE lp_cType = "I"
          l_uRetVal = IIF(EMPTY(l_cText) OR NOT ISDIGIT(l_cText),0,INT(VAL(l_cText)))
     CASE lp_cType = "D"
          l_uRetVal = this.ConvertXMLDateToVFPDate(l_cText)
     CASE lp_cType = "B"
          l_uRetVal = IIF(EMPTY(l_cText) OR NOT ISDIGIT(l_cText),0.00,EVALUATE(STRTRAN(l_cText,",",".")))
     OTHERWISE
          l_uRetVal = l_cText
ENDCASE
RETURN l_uRetVal
ENDPROC
*
PROCEDURE GetAttribute
LPARAMETERS lp_cAttribute, lp_cType, lp_oNode
LOCAL l_cText, l_uRetVal
l_cText = ""
l_uRetVal = ""
IF VARTYPE(lp_cType)="L"
     lp_cType = "C"
ENDIF
IF VARTYPE(lp_oNode)<>"O"
     lp_oNode = this.oNode
ENDIF
l_cText = NVL(lp_oNode.getAttribute(lp_cAttribute),"")
DO CASE
     CASE lp_cType = "I"
          l_uRetVal = IIF(EMPTY(l_cText) OR NOT ISDIGIT(l_cText),0,INT(VAL(l_cText)))
     OTHERWISE
          l_uRetVal = l_cText
ENDCASE
RETURN l_uRetVal
ENDPROC
*
PROCEDURE ConvertXMLDateToVFPDate
LPARAMETERS lp_cDate
l_dDate = {}
IF EMPTY(lp_cDate)
     RETURN l_dDate
ENDIF
l_cYear = GETWORDNUM(lp_cDate,1,"-")
l_cMonth = GETWORDNUM(lp_cDate,2,"-")
l_cDay = GETWORDNUM(lp_cDate,3,"-")
l_dDate = DATE(INT(VAL(l_cYear)), INT(VAL(l_cMonth)), INT(VAL(l_cDay)))
RETURN l_dDate
ENDPROC
*
PROCEDURE GetError
RETURN this.oHTTPConnection.cErrorText
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS cHTTP AS Custom
*
cResponseReadable = ""
oHttp = NULL
oGZip = NULL
cLogFile = "vfpajax.log"
cXMLLogFile = ""
nConnectionError = 0
cErrorText = ""
nRESLOVETIMEOUT = 10
nCONNECTTIMEOUT = 10
nSENDTIMEOUT = 10
nRECIVETIMEOUT = 10
cserver = ""
cuserid = ""
cpassword = ""
cXmlRequest = ""
cproxy = ""
lcompression = .F.
oXMLResponse = NULL
cXMLRESPONSE = ""
lUseExternalHTTPClient = .F.
cEXEPath = ""
cContentType = "application/xml"
lLog = .T.
lGET = .F.
cFormatBeforeSend = ""
*
PROCEDURE Init
LPARAMETERS lp_oParams
LOCAL l_cFll
this.GetParams(lp_oParams)

this.cXMLLogFile = JUSTSTEM(this.cLogFile) + "-xml.log"
IF NOT "vfpconnection" $ LOWER(SET("Library"))
     * Needed for URLEncode
     IF FILE("vfpconnection.fll")
          l_cFll = FULLPATH("vfpconnection.fll")
     ELSE
          l_cFll = FULLPATH("common\dll\vfpconnection.fll")
     ENDIF
     SET LIBRARY TO (l_cFll)
ENDIF
IF TYPE("_screen.oGlobal.cHotelDir")="C"
     this.cEXEPath = _screen.oGlobal.cHotelDir
ELSE
     this.cEXEPath = ADDBS(SYS(5)+SYS(2003))
ENDIF
ENDPROC
*
PROCEDURE GetParams
LPARAMETERS lp_oParams
IF TYPE("lp_oParams.cXML")="C"
     this.cXmlRequest = lp_oParams.cXML
ENDIF
IF TYPE("lp_oParams.cServer")="C"
     this.cserver = lp_oParams.cServer
ENDIF
IF TYPE("lp_oParams.cProxy")="C" AND NOT EMPTY(lp_oParams.cProxy)
     this.cproxy = lp_oParams.cProxy
ENDIF
IF TYPE("lp_oParams.cLogFile")="C" AND NOT EMPTY(lp_oParams.cLogFile)
     this.cLogFile = lp_oParams.cLogFile
ENDIF
IF TYPE("lp_oParams.lUseExternalHTTPClient")="L"
     this.lUseExternalHTTPClient = lp_oParams.lUseExternalHTTPClient
ENDIF
IF TYPE("lp_oParams.cContentType")="C" AND NOT EMPTY(lp_oParams.cContentType)
     this.cContentType = lp_oParams.cContentType
ENDIF
IF TYPE("lp_oParams.lGET")="L" AND lp_oParams.lGET
     this.lGET = .T.
ENDIF
IF TYPE("lp_oParams.cFormatBeforeSend")="C" AND NOT EMPTY(lp_oParams.cFormatBeforeSend)
     this.cFormatBeforeSend = lp_oParams.cFormatBeforeSend
ENDIF
ENDPROC
*
PROCEDURE HttpSend
LOCAL l_lSuccess

this.cResponseReadable = ""
this.cXMLRESPONSE = "NO_RESPONSE_TEXT"

this.RemoveSpacesFromXML()
this.LogitXml("REQUEST")

IF this.lUseExternalHTTPClient
     l_lSuccess = this.HttpSendExternal()
ELSE
     l_lSuccess = this.HttpSendInternal()
ENDIF

IF l_lSuccess
     l_lSuccess = this.HttpSendXMLGet()
ENDIF

this.LogItXml("RESPONSE")

RETURN l_lSuccess
ENDPROC
*
PROCEDURE HTTPSendExternal
LOCAL l_lSuccess, l_cResult, l_cCmd, l_cServer, l_cTXTFileName, l_cStatus, l_nErrorCode, l_cError

lp_cResponse = ""
l_cStatus = ""
l_cServer = STRTRAN(this.cServer, "&", "^&")
l_cTXTFileName = this.GetGuid()+".txt"
l_cTXTFileName = FULLPATH(ADDBS(SYS(2023))+l_cTXTFileName)
STRTOFILE(this.GetSendData(),l_cTXTFileName,0)

TEXT TO l_cCmd TEXTMERGE NOSHOW PRETEXT 15
<<FULLPATH(this.cEXEPath+"citadelhttp.exe")>> <<l_cServer>> <<l_cTXTFileName>> <<IIF(this.lGET, "GET", "POST")>> <<IIF(EMPTY(this.cproxy),"NO_PROXY",this.cproxy)>> <<this.cContentType>> GET_RESPONSE_INFO <<IIF(this.lLog, "LOG_HTTP DEBUG", "")>>
ENDTEXT

l_cResult = this.ExecCommand(l_cCmd, @l_nErrorCode)
IF l_nErrorCode = 0 && Success
     l_lSuccess = .T.
     IF NOT EMPTY(l_cResult)
          l_cStatus = ALLTRIM(STREXTRACT(l_cResult, "___@@@___", "___###___"))
     ENDIF

     IF EMPTY(l_cResult) OR "getaddrinfow" $ l_cResult OR "no such host" $ l_cResult OR l_cStatus <> "200"
          l_cError = "HTTP connect error! (1)" + CHR(13) + l_cResult
          l_lSuccess = .F.
     ENDIF

     this.cResponseReadable = STREXTRACT(l_cResult,"","___@@@___")

     DELETE FILE (l_cTXTFileName)
ELSE
     l_cError = "Error code " + TRANSFORM(l_nErrorCode) + ": " + STREXTRACT(l_cResult,"","___@@@___")
     this.LogIt(l_cError)
ENDIF
IF NOT EMPTY(l_cError)
     this.AddError(l_cError)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE HttpSendInternal
LOCAL l_lSuccess, l_oErr AS Exception, l_oHttp AS MSXML2.ServerXMLHTTP, l_cResponse, l_cHttpSendError, l_cSOAPAction, l_cURL
l_lSuccess = .F.
l_cResponse = ""
l_oErr = .NULL.

IF ISNULL(this.oHttp)
     TRY
          this.oHttp = CREATEOBJECT("MSXML2.ServerXMLHTTP")
     CATCH TO l_oErr
          l_cResponse = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                         "|Message:"+TRANSFORM(l_oErr.Message)
     ENDTRY
ENDIF

IF EMPTY(l_cResponse) AND ISNULL(l_oErr) AND this.lcompression
     l_oErr = .NULL.
     IF ISNULL(this.oGZip)
          TRY
               this.oGZip = NEWOBJECT("gzipper","gzipwrapper.prg")
          CATCH TO l_oErr
               l_cResponse = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                              "|Message:"+TRANSFORM(l_oErr.Message)
          ENDTRY
     ENDIF
     IF NOT EMPTY(l_cResponse)
          this.LogIt(l_cResponse)
     ENDIF
     l_oErr = .NULL.
     l_cResponse = ""
ENDIF

IF ISNULL(this.oHttp)
     this.nConnectionError = 3
     this.AddError("Can't create MSXML2.ServerXMLHTTP object.")
ELSE
     l_cURL = this.cserver
     IF this.lGET
          IF NOT EMPTY(this.GetSendData())
               l_cURL = l_cURL + "?" + this.GetSendData()
          ENDIF
     ENDIF
     l_oHttp = this.oHttp
     l_oHttp.setTimeouts(this.nRESLOVETIMEOUT*1000,this.nCONNECTTIMEOUT*1000,this.nSENDTIMEOUT*1000,this.nRECIVETIMEOUT*1000)
     l_oHttp.Open(IIF(this.lGET, "GET", "POST"), l_cURL, .F.,this.cuserid, this.cpassword)
     *l_oHttp.Open("POST", "http://dev.cmm2.de:81/ix/ota.x", .F.,this.cuserid, this.cpassword)     && Test account??

     IF this.lcompression
          l_oHttp.setRequestHeader('Accept-Encoding', 'gzip,deflate')
     ENDIF
     l_oHttp.setRequestHeader('Content-Type', this.cContentType)
     l_oHttp.setRequestHeader('Charset', 'UTF-8')
     l_oHttp.setOption(2, 13056)
     IF NOT EMPTY(this.cproxy)
          l_oHttp.setProxy(2, this.cproxy, "")
     ENDIF

     l_cHttpSendError = ""
     TRY
          l_oHttp.send(this.GetSendData())
     CATCH TO l_oErr
          l_cHttpSendError = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                    "|Message:"+TRANSFORM(l_oErr.Message)
     ENDTRY
     IF EMPTY(l_cHttpSendError)
          l_cResponse = "Status:"+TRANSFORM(l_oHttp.status)+;
                    "|StatusText:"+TRANSFORM(l_oHttp.statusText)+;
                    "|ReadyState:"+TRANSFORM(l_oHttp.readyState)
          IF l_oHttp.status = 200
               IF this.DecompressResponseInternal()
                    l_lSuccess = .T.
               ENDIF
          ENDIF
     ELSE
          this.nConnectionError = 1
          l_cResponse = l_cHttpSendError
     ENDIF
ENDIF
l_cResponse = "HTTP Connect|"+l_cResponse

this.LogIt(l_cResponse)

IF NOT l_lSuccess
     this.AddError(l_cResponse)
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE GetSendData
LOCAL l_cData, l_cFormatBeforeSend
l_cFormatBeforeSend = this.cFormatBeforeSend

IF EMPTY(l_cFormatBeforeSend)
     l_cData = this.cXmlRequest
ELSE
     l_cData = &l_cFormatBeforeSend
ENDIF

RETURN l_cData
ENDPROC
*
PROCEDURE GetGuid
LOCAL l_oTypeLib
l_oTypeLib = CREATEOBJECT("Scriptlet.TypeLib")
RETURN STREXTRACT(l_oTypeLib.Guid,"{","}")
ENDPROC
*
PROCEDURE LogIt
LPARAMETERS lp_cText
LOCAL l_cFile2, l_nLimit
IF NOT EMPTY(lp_cText)

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
PROCEDURE ExecCommand
LPARAMETERS lp_cCommand, lp_nErrorCode
LOCAL l_cOutPut, l_cTempShellRunFile, l_oShell
l_cOutPut = ""

IF EMPTY(lp_cCommand)
     RETURN l_cOutPut
ENDIF

* Initialize
l_oShell = CREATEOBJECT("Wscript.Shell")

* Create unique file name as guid
l_cTempShellRunFile = this.GetGuid()

* When guid wasn't created, create vfp unique name
IF EMPTY(l_cTempShellRunFile)
     l_cTempShellRunFile = SYS(2015)
ENDIF

* Set txt extension
l_cTempShellRunFile = FORCEEXT(l_cTempShellRunFile,"txt")
l_cTempShellRunFile = FULLPATH(ADDBS(SYS(2023))+l_cTempShellRunFile)

* Run command
*lp_nErrorCode = l_oShell.Run([%COMSPEC% /C ] + lp_cCommand + [  > ] + l_cTempShellRunFile, 0, .T.)

lp_nErrorCode = l_oShell.Run([%COMSPEC% /C ] + lp_cCommand + [ 1>>] + l_cTempShellRunFile  + [ 2>>&1 3>>&1], 0, .T.)

*l_nRunScript =         o.Run([%COMSPEC% /C ] + l_cCommand +  [ 1>>] + [sftpb.log]          + [ 2>>&1 3>>&1], 0, .T.)

* Check for output
IF FILE(l_cTempShellRunFile)
     l_cOutPut = FILETOSTR(l_cTempShellRunFile)
ENDIF

* Delete output file
DELETE FILE (l_cTempShellRunFile)

* Clean up
l_oShell = .NULL.
l_oTypeLib = .NULL.

RETURN l_cOutPut
ENDPROC
*
PROCEDURE LogItXml
LPARAMETERS lp_cCmd, lp_cURL
LOCAL l_cFile2, l_nLimit, l_cFakedXMLReq
IF EMPTY(lp_cURL)
     lp_cURL = ""
ENDIF
l_cFile2 = this.cXMLLogFile + ".2"
l_nLimit = 50000000 && 50 MB

IF FILE(this.cXMLLogFile)
     IF ADIR(l_aFile,LOCFILE(this.cXMLLogFile))>0
          IF l_aFile(2)>l_nLimit
               IF FILE(l_cFile2)
                    DELETE FILE (l_cFile2)
               ENDIF
               RENAME (this.cXMLLogFile) TO (l_cFile2)
          ENDIF
     ENDIF
ENDIF

TRY
     IF lp_cCmd = "RESPONSE"
          STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cCmd+CHR(10)+CHR(13)+REPLICATE("-",50)+CHR(10)+CHR(13)+;
                    this.cXMLRESPONSE+CHR(10)+CHR(13)+;
                    REPLICATE("-",50)+CHR(10)+CHR(13),this.cXMLLogFile,1)
     ELSE && REQUEST
          l_cFakedXMLReq = this.FakeRequestXML()
          STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cCmd+" "+lp_cURL+CHR(10)+CHR(13)+REPLICATE("-",50)+CHR(10)+CHR(13)+;
                    l_cFakedXMLReq+CHR(10)+CHR(13)+;
                    REPLICATE("-",50)+CHR(10)+CHR(13),this.cXMLLogFile,1)
     ENDIF
CATCH
ENDTRY
RETURN .T.
ENDPROC
*
PROCEDURE FakeRequestXML
LOCAL l_cXMLFaked

* Leave sent XML as file, for debugging, but remove secure infos
*!*     l_cXMLFaked = STRTRAN(this.cXmlRequest, [<wsse:Username>]+this.cUserId+[</wsse:Username>], [<wsse:Username>****</wsse:Username>])
*!*     l_cXMLFaked = STRTRAN(l_cXMLFaked, [<wsse:Password>]+this.cPassword+[</wsse:Password>], [<wsse:Password>****</wsse:Password>])

RETURN this.cXmlRequest
ENDPROC
*
PROCEDURE AddError
LPARAMETERS lp_cText
this.cErrorText = this.cErrorText + IIF(EMPTY(this.cErrorText),"",CHR(13)) + lp_cText
RETURN .T.
ENDPROC
*
PROCEDURE RemoveSpacesFromXML
this.cXmlRequest = STRTRAN(this.cXmlRequest,"> </","></")
this.cXmlRequest = STRTRAN(this.cXmlRequest,"> <","><")
RETURN .T.
ENDPROC
*
*
PROCEDURE DecompressResponseInternal
LOCAL l_cText, l_cLeft, l_nSys3101, l_cResponseText
STORE "" TO l_cText, l_cResponseText
l_cLeft = LEFT(TRANSFORM(this.oHTTP.responseBody),6) && From responseBody property data is returned as VARBINARY!
IF l_cLeft = "1F8B08"
     * "Compressed"
     l_cText = this.oGZip.DeCompress(this.oHttp.responseBody)
ELSE
     * "Plain"
     l_nSys3101 = SYS(3101,65001)
     l_cResponseText = this.oHTTP.responseText
     SYS(3101,l_nSys3101)
     l_cText = l_cResponseText
ENDIF
this.cResponseReadable = l_cResponseText
RETURN .T.
ENDPROC
*
PROCEDURE HttpSendXMLGet
* Must first remove CHR(10), CHR(13) from received string. MSXML2.ServerXMLHTTP parser
* not working when those characters are in string!

LOCAL l_oTempXML AS MSXML2.DOMDocument, l_cText, l_lSuccess, l_cError
this.oXMLResponse = .NULL.
*TRY
     l_oTempXML = CREATEOBJECT("MSXML2.DOMDocument")
     
     l_cText = this.cResponseReadable

     l_cText = STRTRAN(l_cText,CHR(0)," ")
     l_cText = STRTRAN(l_cText,CHR(10),"")
     l_cText = STRTRAN(l_cText,CHR(13),"")
     l_cText = ALLTRIM(l_cText)

     STRTOFILE(l_cText,"vfpajax.tmp",0)
     l_oTempXML.LoadXML(FILETOSTR("vfpajax.tmp"))
     this.oXMLResponse = l_oTempXML
     l_oTempXML = .NULL.
*CATCH
*ENDTRY

DO CASE
     CASE ISNULL(this.oXMLResponse)
          l_cError = "Error: No XML received from server."
          this.LogIt(l_cError)
          this.AddError(l_cError)
          l_lSuccess = .F.
     CASE EMPTY(this.oXMLResponse.xml)
          l_cError = "Error: Parsing error in XML received from server."
          this.LogIt(l_cError)
          this.AddError(l_cError)
          l_lSuccess = .F.
     OTHERWISE
          l_lSuccess = .T.
          this.cXMLRESPONSE = this.cResponseReadable
ENDCASE

RETURN l_lSuccess

*!*     * Hold refrence on received XML object in property

*!*     LOCAL l_oXML AS MSXML2.DomDocument, l_lSuccess, l_cError
*!*     l_lSuccess = .T.
*!*     l_oXML = .NULL.
*!*     TRY
*!*          l_oXML = this.oHTTP.responseXML
*!*     CATCH
*!*     ENDTRY
*!*     IF ISNULL(l_oXML)
*!*          l_cError = "Error: No XML received from server."
*!*          this.LogIt(l_cError)
*!*          this.AddError(l_cError)
*!*          l_lSuccess = .F.
*!*     ELSE
*!*          this.oXMLResponse = l_oXML
*!*     ENDIF
*!*     RETURN l_lSuccess
ENDPROC
*
ENDDEFINE
*