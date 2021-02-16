#DEFINE SQLR_CSRV_SIGNATURE     "52764219-f684-4b95-b3df-c97c7171f0d7"
#DEFINE SQLR_CRLF               CHR(13)+CHR(10)
#DEFINE SQLR_EOT                CHR(4)
#DEFINE SQLR_CSRV_KEY           "6A3839626324236B6B6439214F6F6231"
#DEFINE SQLR_CCNULL             CHR(0)
#DEFINE SQLR_BUFFER_SIZE        256
#DEFINE SQLR_LF                 CHR(10)
#DEFINE SQLR_CR                 CHR(13)

* ? sqlremote("SQLCURSOR","SELECT * FROM article")
* ? sqlremote("SQLTABLE","article")
* ? sqlremote("SQLTABLESTRUCT","address")
* ? sqlremote("EXEC","sleep(3000)")
* ? sqlremote("AUDIT",,,"DESK")

LPARAMETERS lp_cCmd, lp_cParam, lp_cCurName, lp_cDatabase, lp_nSecToWait, lp_lSuccess, lp_cServer, lp_nPort, lp_lEncrypt, lp_cRemoteTable, lp_lDontSelectIntoNewCursor
LOCAL l_cAlias, l_lKeepRemoteTable, l_lSilent

lp_lSuccess = .F.
IF EMPTY(lp_cParam)
     lp_cParam = ""
ENDIF
IF VARTYPE(lp_cDatabase) = "O"
     lp_cServer = lp_cDatabase.cServerName
     lp_nPort = lp_cDatabase.nServerPort
     lp_lEncrypt = lp_cDatabase.lEncrypt
     l_lSilent = lp_cDatabase.lSilent
     lp_cDatabase = lp_cDatabase.cApplication
ENDIF

SQLRemoteInit(lp_cDatabase, lp_nSecToWait, lp_cServer, lp_nPort, lp_lEncrypt, l_lSilent)

IF PCOUNT() > 9 AND NOT EMPTY(lp_cRemoteTable)
     lp_cRemoteTable = ""
     l_lKeepRemoteTable = .T.
ENDIF
l_cResult = g_oSqlRemote.Send(lp_cCmd, lp_cParam, @lp_cRemoteTable, l_lKeepRemoteTable)
lp_lSuccess = g_oSqlRemote.lSuccess

IF lp_lSuccess AND NOT EMPTY(lp_cRemoteTable)
     DELETE FILE (FORCEEXT(lp_cRemoteTable,"zip"))
     IF lp_lDontSelectIntoNewCursor
          l_cResult = lp_cRemoteTable
     ELSE
          IF INLIST(lp_cCmd, "SQLTABLE", "SQLTABLESTRUCT")
               lp_cCurName = JUSTSTEM(lp_cRemoteTable)
               USE (lp_cRemoteTable) IN 0 AGAIN EXCLUSIVE
          ELSE
               lp_cCurName = EVL(lp_cCurName,SYS(2015))
               l_cAlias = JUSTSTEM(lp_cRemoteTable)
               SELECT * FROM (lp_cRemoteTable) INTO CURSOR (lp_cCurName) NOFILTER READWRITE
               USE IN (l_cAlias)
               IF NOT l_lKeepRemoteTable
                    DELETE FILE (FORCEEXT(lp_cRemoteTable,"*"))
               ENDIF
          ENDIF
          g_oSqlRemote.CursorDataAdd(lp_cCurName, lp_cDatabase)
          l_cResult = lp_cCurName
     ENDIF
ENDIF

RETURN l_cResult
*
PROCEDURE SQLRemoteInit
LPARAMETERS lp_cDatabase, lp_nSecToWait, lp_cServer, lp_nPort, lp_lEncrypt, lp_lSilent

IF NOT (TYPE("g_oSqlRemote")="O" AND NOT ISNULL(g_oSqlRemote))
     RELEASE g_oSqlRemote
     PUBLIC g_oSqlRemote
     g_oSqlRemote = CREATEOBJECT("csqlremoteparams")
ENDIF

IF NOT EMPTY(lp_cDatabase)
     g_oSqlRemote.cDatabase = lp_cDatabase
ENDIF
IF NOT EMPTY(lp_nSecToWait) AND VARTYPE(lp_nSecToWait) = "N"
     g_oSqlRemote.nSecToWait = lp_nSecToWait
ENDIF
IF NOT EMPTY(lp_cServer)
     g_oSqlRemote.cServerName = lp_cServer
ENDIF
IF NOT EMPTY(lp_nPort)
     g_oSqlRemote.nServerPort = lp_nPort
ENDIF
IF PCOUNT()>4
     g_oSqlRemote.lEncrypt = lp_lEncrypt
ENDIF
g_oSqlRemote.lSilent = lp_lSilent

RETURN .T.
ENDPROC
*
DEFINE CLASS csqlremoteparams AS Custom
*
#IF .F. && Make sure this is false, otherwise error
   *-- Define This for IntelliSense use
   LOCAL This AS csqlremoteparams OF sqlremote.prg
#ENDIF
*
cServerName = ""
nServerPort = 0
ctempfolder = ""
nSecToWait = 30
lEncrypt = .F.
cDatabase = ""
ocntws = .NULL.
lDebug = .F.
lSilent = .F.
lSuccess = .F.
cClientPcName = ""
lConnectionActive = .F. && Prevents multiple simultenius connection attemps over this object
DIMENSION aCursors(1)
*
PROCEDURE Send
LPARAMETERS lp_cCmd, lp_cParam, lp_cResultFile, lp_lKeepRemoteTable
LOCAL l_cResult, l_lSuccess, l_cMsg, l_cResponse, l_cDir, l_cFileContents, l_cFileNew, l_cFileNameNew, l_lAutoYield, ;
          l_cCurTableName, l_nSecToComplete, l_nSec, l_cUnzipDir, l_cUnzipFile, l_cType, l_lAjax, l_cHttpSendError, l_oHttp, ;
          l_oErr, l_cHTTPResponse, l_cAJAXError, l_cAJAXResult, l_cErrormessage, l_cMsgBeforeEncrypted, l_nHTTPStatus, l_cNewParam
LOCAL ARRAY l_aFiles(1)
this.lSuccess = .F.
l_cResult = ""
IF NOT (NOT EMPTY(this.cServerName) AND NOT EMPTY(this.nServerPort) AND NOT EMPTY(this.cDatabase) AND ;
          NOT EMPTY(lp_cCmd) AND NOT ISNULL(this.ocntws) AND NOT this.lConnectionActive)
     RETURN l_cResult
ENDIF

l_lAjax = (this.nServerPort=-1)

lp_cParam = STRTRAN(lp_cParam,SQLR_CRLF,SQLR_EOT)
lp_cParam = STRTRAN(lp_cParam,CHR(10),"")
lp_cParam = STRTRAN(lp_cParam,CHR(13),"")
l_cMsg = "|" + SQLR_CSRV_SIGNATURE + "|" + this.cClientPcName + "|" + this.cDatabase + "|"
l_cMsg = l_cMsg + lp_cCmd + IIF(lp_lKeepRemoteTable, "/RT", "") + "|" + lp_cParam + "|"
IF "__SQLPARAM__" $ lp_cParam
     l_cMsg = l_cMsg + this.CreateParamsObj(lp_cParam, @l_cNewParam) + "|"
     l_cMsg = STRTRAN(l_cMsg, lp_cParam, l_cNewParam)
ENDIF
l_cMsgBeforeEncrypted = l_cMsg
IF this.lEncrypt
     l_cMsg = this.Encrypt(l_cMsg)
ENDIF
l_cMsg = CHR(2) + l_cMsg + CHR(3)
l_cResponse = ""

IF l_lAjax
     l_oHTTP = CREATEOBJECT("MSXML2.ServerXMLHTTP")
     *l_oHttp.setTimeouts(this.nRESLOVETIMEOUT*1000,this.nCONNECTTIMEOUT*1000,this.nSENDTIMEOUT*1000,this.nRECIVETIMEOUT*1000)
     l_oHttp.setTimeouts(60*1000,60*1000,60*1000,60*1000)
     l_oHttp.Open("POST", this.cServerName, .F.)
     l_oHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
     l_oHttp.setRequestHeader('Charset', 'UTF-8')
     l_cHttpSendError = ""
     l_cParameters = "action=api&cmd="+UrlEncode(STRCONV(l_cMsg,9))
     TRY
          l_oHttp.send(l_cParameters)
     CATCH TO l_oErr
          l_cHttpSendError = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                    "|Message:"+TRANSFORM(l_oErr.Message)
     ENDTRY
     IF EMPTY(l_cHttpSendError)
          l_cHTTPResponse = "Status:"+TRANSFORM(l_oHttp.status)+;
                    "|StatusText:"+TRANSFORM(l_oHttp.statusText)+;
                    "|ReadyState:"+TRANSFORM(l_oHttp.readyState)
          IF l_oHttp.status = 200
               l_cResponse = l_oHttp.responseText
          ENDIF
     ENDIF
     l_nHTTPStatus = 0
     TRY
          l_nHTTPStatus = l_oHttp.status
     CATCH
     ENDTRY

     l_cAJAXError = ""
     DO CASE
          CASE NOT EMPTY(l_cHttpSendError)
               l_cAJAXError = l_cHttpSendError
          CASE l_nHTTPStatus <> 200
               l_cAJAXError = l_cHTTPResponse
          OTHERWISE
               l_cAJAXResult = STRTRAN(l_cResponse, CHR(2), "")
               l_cAJAXResult = STRTRAN(l_cAJAXResult, CHR(3), "")
               l_cAJAXResult = GETWORDNUM(l_cAJAXResult,1,"|")
               IF l_cAJAXResult = "ER" OR "Caught .NET exception" $ l_cAJAXResult
                    l_cAJAXError = l_cResponse
               ENDIF
     ENDCASE
     IF NOT EMPTY(l_cAJAXError)
          this.LogError("AJAX Error:" + SQLR_LF + l_cAJAXError + SQLR_LF + "Code:" + SQLR_LF + l_cMsgBeforeEncrypted)
     ENDIF
ELSE

     this.lConnectionActive = .T.

     l_lAutoYield = _vfp.AutoYield
     _vfp.AutoYield = .F.
     l_nSec = SECONDS()
     l_lSuccess = .F.

     * |52764219-f684-4b95-b3df-c97c7171f0d7|TEST1|DESK|SQLCURSOR|SELECT pa_hotel, pa_lang FROM param|

     IF this.ocntws.Connect(this.cServerName, this.nServerPort)
          IF this.ocntws.Send(l_cMsg)
               l_cResponse = this.ocntws.GetResponse(this.nSecToWait, this.lSilent)
          ENDIF
          this.ocntws.Disconnect()
     ENDIF

     _vfp.AutoYield = l_lAutoYield

ENDIF

IF NOT EMPTY(l_cResponse) AND this.lEncrypt
     l_cResponse = this.Decrypt(l_cResponse)
ENDIF
*STRTOFILE(l_cResponse + CHR(13) + CHR(10) + REPLICATE("-",40) + CHR(13) + CHR(10),"sqlremote.log",1)
l_cResponse = STRTRAN(l_cResponse, CHR(2), "")
l_cResponse = STRTRAN(l_cResponse, CHR(3), "")
l_cResult = GETWORDNUM(l_cResponse,1,"|")
IF l_cResult = "OK"
     IF INLIST(lp_cCmd,"SQLCURSOR") OR "</data_block>" $ l_cResponse
          l_lSuccess = .F.
          l_cDir = this.ctempfolder
          l_cFileContents = STREXTRACT(l_cResponse,"<data_block>","</data_block>")
          l_cFileNew = GETWORDNUM(l_cResponse,2,"|")
          IF NOT EMPTY(l_cFileNew)
               l_cFileNameNew = FORCEEXT(ADDBS(l_cDir) + l_cFileNew, "zip")
               STRTOFILE(STRCONV(l_cFileContents,14),l_cFileNameNew)
               IF FILE(l_cFileNameNew)
                    IF ADIR(l_aFiles,l_cFileNameNew) > 0
                         l_lSuccess = (l_aFiles(2) > 0)
                    ENDIF
               ENDIF
          ENDIF
          IF l_lSuccess
               l_cUnzipDir = JUSTPATH(l_cFileNameNew)
               UnzipQuick(l_cFileNameNew, l_cUnzipDir)
               lp_cResultFile = FORCEEXT(l_cFileNameNew,"dbf")
          ENDIF
     ELSE
          l_lSuccess = .T.
          l_cType = GETWORDNUM(l_cResponse,2,"|")
          l_cResult = ALLTRIM(GETWORDNUM(l_cResponse,3,"|"))
          IF l_cType <> "C"
              TRY
                  l_cResult = &l_cResult
              CATCH
              ENDTRY
          ENDIF
     ENDIF
ELSE
     l_cResult = GETWORDNUM(l_cResponse,2,"|")
ENDIF

IF this.lDebug
     IF NOT EMPTY(l_cResult)
          ? "Response: " + TRANSFORM(l_cResult)
     ENDIF
     l_nSecToComplete = SECONDS() - l_nSec

     ? "Completed in " + TRANSFORM(l_nSecToComplete) + " sec."
     ? "Success = " + TRANSFORM(l_lSuccess)
     ?
ENDIF
this.lSuccess = l_lSuccess

this.lConnectionActive = .F.

RETURN l_cResult
ENDPROC
*
PROCEDURE CloseConnection
TRY
     this.ocntws.Object.Close()
CATCH
ENDTRY
ENDPROC
*
PROCEDURE CreateParamsObj
LPARAMETERS lp_cParam, lp_cNewParam
LOCAL l_nTimesFound, i, l_cOneSqlParam, l_oJSON, l_oParams, l_cSqlParamsJSON, l_cParamName

l_cSqlParamsJSON = ""
lp_cNewParam = lp_cParam

IF NOT EMPTY(lp_cParam)
     l_oParams = CREATEOBJECT("Empty")
     l_nTimesFound = OCCURS("__SQLPARAM__",lp_cParam)
     FOR i = 1 TO l_nTimesFound
          l_cOneSqlParam = this.GetOneSqlParam(lp_cParam, i, @l_cParamName)
          IF NOT EMPTY(l_cOneSqlParam)
               ADDPROPERTY(l_oParams, l_cParamName, EVALUATE(l_cOneSqlParam))
               lp_cNewParam = STRTRAN(lp_cNewParam, "__SQLPARAM__"+l_cOneSqlParam,"l_oParamObj."+l_cParamName)
          ENDIF
     ENDFOR
     l_oJSON = NEWOBJECT('json','common\progs\json.prg')
     l_cSqlParamsJSON = l_oJSON.stringify(l_oParams)
ENDIF

RETURN l_cSqlParamsJSON
ENDPROC
*
PROCEDURE GetOneSqlParam
LPARAMETERS lp_cString, lp_nOccurence, lp_cParamName
LOCAL l_cSqlParam, l_nTimesFound, i, l_nStart, l_nLength, l_cOneChar

l_cSqlParam = ""
IF NOT EMPTY(lp_cString) AND NOT EMPTY(lp_nOccurence)
     l_nTimesFound = OCCURS("__SQLPARAM__",lp_cString)
     IF l_nTimesFound >= lp_nOccurence
          l_nStart = AT("__SQLPARAM__",lp_cString,lp_nOccurence) + 12
          l_nLength = LEN(lp_cString)
          FOR i = l_nStart TO l_nLength
               l_cOneChar = SUBSTR(lp_cString,i,1)
               IF INLIST(l_cOneChar, " ", "=", "-", "*", "/", "\") OR NOT LEFT(l_cSqlParam,6) == "OLDVAL" AND INLIST(l_cOneChar, "(", ",", ")")
                    EXIT
               ENDIF
               l_cSqlParam = l_cSqlParam + l_cOneChar
          ENDFOR
     ENDIF
ENDIF
lp_cParamName = CHRTRAN(l_cSqlParam, ".(),'", "")

RETURN l_cSqlParam
ENDPROC
*
PROCEDURE Encrypt
LPARAMETERS lp_cString
LOCAL l_cEncripted, l_cEncriptedHex
l_cEncripted = ""
TRY
     l_cEncripted =Encrypt(lp_cString, SQLR_CSRV_KEY, 0, 0, 0, 16, 16)
     l_cEncriptedHex = STRCONV(l_cEncripted,13)
CATCH
ENDTRY
RETURN l_cEncriptedHex
ENDPROC
*
PROCEDURE Decrypt
LPARAMETERS lp_cString
LOCAL l_cClean
l_cClean = ""
TRY
     l_cClean = Decrypt(STRCONV(lp_cString,14),SQLR_CSRV_KEY, 0, 0, 0, 16, 16)
CATCH
ENDTRY
l_cClean = STRTRAN(l_cClean, CHR(0))
RETURN l_cClean
ENDPROC
*
PROCEDURE Init
LOCAL l_lFoundgetprivateprofilestring, l_lFoundsleep, i, l_cIniFile
LOCAL ARRAY l_aDlls(1)

IF NOT "common\dll" $ LOWER(SET("Path"))
     SET PATH TO "common\dll" ADDITIVE
ENDIF
IF NOT "vfpcompression" $ LOWER(SET("Library"))
     SET LIBRARY TO common\dll\vfpcompression.fll ADDITIVE
ENDIF
IF NOT "vfpencryption71" $ LOWER(SET("Library"))
     SET LIBRARY TO common\dll\vfpencryption71.fll ADDITIVE
ENDIF
IF FILE("common\dll\vfpconnection.fll") AND NOT "vfpconnection" $ LOWER(SET("Library"))
     SET LIBRARY TO common\dll\vfpconnection.fll ADDITIVE
ENDIF

* Declare DLLS, when needed

IF ADLLS(l_aDlls)>0
     FOR i = 1 TO ALEN(l_aDlls,1)
          IF LOWER(ALLTRIM(l_aDlls(i,1))) == "getprivateprofilestring"
               l_lFoundgetprivateprofilestring = .T.
          ENDIF
          IF LOWER(ALLTRIM(l_aDlls(i,1))) == "sleep"
               l_lFoundsleep = .T.
               EXIT
          ENDIF
     ENDFOR
ENDIF
IF NOT l_lFoundsleep
     DECLARE Sleep IN Win32API INTEGER nMilliseconds
ENDIF

this.ctempfolder = ADDBS(SYS(2023)) + "citsqlremote"
IF NOT DIRECTORY(this.ctempfolder)
     MKDIR (this.ctempfolder)
ENDIF

this.ocntws = .NULL.
TRY
     this.ocntws = NEWOBJECT("cscntwinsock","common\libs\cit_sqlremote.vcx")
CATCH
ENDTRY

this.SetClientPcName()

RETURN .T.
ENDPROC
*
PROCEDURE LogError
LPARAMETERS lp_cMessage
LOCAL l_cErrormessage, l_cErrorAddtext, l_cLogMacro

STORE "" TO l_cErrorAddtext, l_cLogMacro
DO CASE
     CASE TYPE("gcApplication") = "C" AND UPPER(gcApplication) = "CITADEL DESK"
          * Desk
          *_vfp.Name = "ARGUS"
          l_cErrorAddtext = "Hotel: " + IIF(TYPE("g_Hotel")="C",g_Hotel,"Unknown Hotel") + SQLR_LF
          l_cLogMacro = "erRormsg(l_cErrormessage,.F.)"
     CASE TYPE("glAutomationMode")="L" AND TYPE("gnManagerMode")="N"
          * Terminal
          l_cLogMacro = "filelog('TERMINAL.ERR',l_cErrormessage)"
     CASE TYPE("goGlobal.cappname")="C" AND goGlobal.cappname = "manager"
          * Manager
          l_cLogMacro = "filelog('MANAGER.ERR',l_cErrormessage)"
     CASE TYPE("g_cApplication")="C" AND LOWER(g_cApplication) = "thermaris wellness zentrum"
          * Wellness
          l_cLogMacro = "LogData(l_cErrormessage, g_oCommandParam.rootfolder+'Error.log')"
     OTHERWISE
ENDCASE
l_cErrormessage = ALLTRIM(_screen.Caption) + SQLR_LF + ;
     l_cErrorAddtext + ;
     "Workstation: " + this.cClientPcName + SQLR_LF + ;
     lp_cMessage + SQLR_LF + ;
     "AY = " + TRANSFORM(_vfp.AutoYield)
&l_cLogMacro
ENDPROC
*
PROCEDURE CursorDataAdd
LPARAMETERS lp_cCursor, lp_cApp
LOCAL l_nRow, l_nRows

this.CursorDataClean()
l_nRow = 0
DO WHILE .T.
	l_nRow = ASCAN(this.aCursors, lp_cCursor, l_nRow+1, 0, 1, 15)
	DO CASE
		CASE l_nRow = 0
			l_nRows = IIF(EMPTY(this.aCursors(1)), 0, ALEN(this.aCursors,1))+1
			DIMENSION this.aCursors(l_nRows,2)
			this.aCursors(l_nRows,1) = lp_cCursor
			this.aCursors(l_nRows,2) = lp_cApp
			RETURN
		CASE this.aCursors(l_nRow,2) == lp_cApp
			RETURN
		OTHERWISE
	ENDCASE
ENDDO
ENDPROC
*
PROCEDURE CursorDataGet
LPARAMETERS lp_cCursor
LOCAL l_cApp, l_nRow

l_nRow = ASCAN(this.aCursors, lp_cCursor, 1, 0, 1, 15)
IF l_nRow > 0
     l_cApp = this.aCursors(l_nRow,2)
ELSE
     l_cApp = ""
ENDIF

RETURN l_cApp
ENDPROC
*
PROCEDURE CursorDataClean
LOCAL i, l_cAlias

IF ALEN(this.aCursors,1) > 99
     FOR i = ALEN(this.aCursors,1) TO 1 STEP -1
          l_cAlias = this.aCursors(i,1)
          IF NOT USED(l_cAlias)
               ADEL(this.aCursors,i)
               IF ALEN(this.aCursors,1) > 1
                    DIMENSION this.aCursors(ALEN(this.aCursors,1)-1,2)
               ENDIF
          ENDIF
     NEXT
ENDIF
ENDPROC
*
PROCEDURE SetClientPcName
DO CASE
     CASE TYPE("gcApplication")="C" AND UPPER(gcApplication) = "CITADEL DESK"
          * Desk
          this.cClientPcName = EVALUATE("winpc()")
     CASE TYPE("glAutomationMode")="L" AND TYPE("gnManagerMode")="N"
          * Terminal
          this.cClientPcName = EVALUATE("winmachine()")
     CASE TYPE("goGlobal.cappname")="C" AND goGlobal.cappname = "manager"
          * Manager
          this.cClientPcName = EVALUATE("winmachine()")
     CASE TYPE("g_cApplication")="C" AND LOWER(g_cApplication) = "thermaris wellness zentrum"
          this.cClientPcName = ALLTRIM(STREXTRACT(ID(), "", "#", 0, 2))
     OTHERWISE
          this.cClientPcName = "UNKNOWN"
ENDCASE
RETURN .T.
ENDPROC
*
PROCEDURE ReadIni
lparameters tcINIFile, ;
     tcSection, ;
     tuEntry, ;
     tcDefault, ;
     taEntries
local lcBuffer, ;
     lcDefault, ;
     lnSize, ;
     luReturn
declare integer GetPrivateProfileString in Win32API string cSection, ;
     string cEntry, string cDefault, string @ cBuffer, integer nBufferSize, ;
     string cINIFile
lcBuffer  = replicate(SQLR_CCNULL, SQLR_BUFFER_SIZE)
lcDefault = iif(vartype(tcDefault) <> 'C', '', tcDefault)
lnSize    = GetPrivateProfileString(tcSection, tuEntry, lcDefault, @lcBuffer, ;
     SQLR_BUFFER_SIZE, tcINIFile)
lcBuffer  = left(lcBuffer, lnSize)
luReturn  = lcBuffer
do case
     case vartype(tuEntry) = 'C'
     case lnSize = 0
          luReturn = 0
     otherwise
          luReturn = alines(taEntries, lcBuffer, .T., SQLR_CCNULL, SQLR_CR)
endcase
return luReturn
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE