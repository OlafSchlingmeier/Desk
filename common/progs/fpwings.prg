#DEFINE def_cFpWings_Version   "2.12"
#DEFINE def_cTab               CHR(9)
#DEFINE def_cLF                CHR(13) + CHR(10)
#DEFINE def_cQtyMeasure        "Kom"
#DEFINE def_fileext            "wng"
#DEFINE def_msg_paperopen      "Proveri da li si spustio ruèicu za papir za raèun!"
#DEFINE def_msg_ctrlpaperopen  "Proveri da li si spustio ruèicu za papir za kontrolnu traku!"
#DEFINE def_msg_printeroff     "Štampac je ugašen, ili nije povezan!"
#DEFINE def_msg_sending        "Šaljem na fiskalni štampaè..."
#DEFINE def_msg_duplicate_art  "Pronaðeni isti artikli sa razlièitom cenom!"
#DEFINE def_msg_no_response    "Nema odgovora od wingsfiskal.exe programa. Odustajem!"
*
PROCEDURE fpwings
LPARAMETER lp_cVersion, lp_cCommand, lp_lSuccess, lp_cErrorMsg, lp_cDataCur, lp_cDrvPath, ;
          lp_cDrvExe, lp_cWinPc, lp_cFileName, lp_uParam1, lp_uParam2, lp_nFpNr, lp_lCheckEXE, ;
          lp_cOperater, lp_cFooter
LOCAL l_cText, l_cResponseText
l_cResponseText = ""
lp_lSuccess = .T.

IF NOT EMPTY(lp_cVersion) AND lp_cVersion = "VERSION"
     lp_cVersion = def_cFpWings_Version
     RETURN lp_lSuccess
ENDIF

IF EMPTY(lp_cDrvPath)
     lp_lSuccess = .F.
     lp_cErrorMsg = "NO_DRIVER_PATH"
     RETURN lp_lSuccess
ENDIF

IF NOT DIRECTORY(lp_cDrvPath)
     lp_lSuccess = .F.
     lp_cErrorMsg = "NO_DRIVER_PATH_DIRECTORY"
     RETURN lp_lSuccess
ENDIF

IF NOT EMPTY(lp_cDrvExe) AND lp_lCheckEXE
     IF NOT FILE(lp_cDrvExe)
          lp_lSuccess = .F.
          lp_cErrorMsg = "NO_DRIVER_EXE"
          RETURN lp_lSuccess
     ENDIF
ENDIF

IF EMPTY(lp_cFileName)
     lp_cFileName = SYS(3)
ENDIF

* Create commands for fiscal driver
DO CASE
     CASE lp_cCommand = "BILL"
          lp_lSuccess = FPWingsBill(@l_cText, @lp_cErrorMsg, lp_cDataCur)
          IF NOT lp_lSuccess
               RETURN lp_lSuccess
          ENDIF
     CASE lp_cCommand = "OPERATER"
          IF NOT EMPTY(lp_cOperater)
               lp_cOperater = FPRemoveSpecChars(lp_cOperater)
               l_cText = "#OPERATER" + def_cLF
               l_cText = l_cText + "001" + def_cTab + "0000" + def_cTab + lp_cOperater + def_cLF
          ENDIF
     CASE lp_cCommand = "SETFOOTER"
          IF EMPTY(lp_cFooter)
               lp_cFooter = ""
          ENDIF
          lp_cFooter = FPRemoveSpecChars(lp_cFooter)
          l_cText = "#SET_FOOTER" + def_cLF
          l_cText = l_cText + lp_cFooter + def_cLF
     CASE lp_cCommand = "Z-READER"
          l_cText = "#Z_REPORT"
     CASE lp_cCommand = "X-READER"
          l_cText = "#X_REPORT"
     CASE lp_cCommand = "P-READER"
          l_cText = "#PERIODIC_REPORT" + def_cLF + ;
                    FPWingsConvDate(lp_uParam1) + def_cTab + FPWingsConvDate(lp_uParam2)
     CASE lp_cCommand = "DELETE_ALL_ARTICLES"
          l_cText = "#DELETE_ALL_ARTIKLI"
     CASE lp_cCommand = "SEND_ALL_ARTICLES"
          lp_lSuccess = FPWingsSendArticles(@l_cText, @lp_cErrorMsg, lp_cDataCur)
          IF NOT lp_lSuccess
               RETURN lp_lSuccess
          ENDIF
     CASE lp_cCommand = "READ_ALL_ARTICLES"
          l_cText = "#READ_ARTIKLI"
          l_cResponseText = "YES"
     CASE lp_cCommand = "SEND_VAT_GROUPS"
          lp_lSuccess = FPWingsSendVatGroups(@l_cText, @lp_cErrorMsg, lp_cDataCur)
          IF NOT lp_lSuccess
               RETURN lp_lSuccess
          ENDIF
ENDCASE

IF EMPTY(l_cText)
     lp_lSuccess = .F.
     lp_cErrorMsg = "NO_COMMANDS"
     RETURN lp_lSuccess
ENDIF

* Now send to printer
IF lp_lSuccess
     lp_lSuccess = FPWingsPrint(l_cText, lp_cDrvPath, lp_cDrvExe, @lp_cErrorMsg, lp_cWinPc, lp_cFileName, ;
               @l_cResponseText, lp_nFpNr, lp_lCheckEXE)
ENDIF

IF lp_cCommand = "READ_ALL_ARTICLES"
     lp_uParam1 = l_cResponseText
ENDIF
RETURN lp_lSuccess
ENDPROC
*
PROCEDURE FPWingsConvDate
LPARAMETERS lp_dDate
RETURN PADL(DAY(lp_dDate), 2, "0") + "." + ;
          PADL(MONTH(lp_dDate), 2, "0") + "." + ;
          RIGHT(PADL(YEAR(lp_dDate), 4, "0"), 2)
ENDPROC
*
PROCEDURE FPWingsPrint
LPARAMETERS lp_cText, lp_cDrvPath, lp_cDrvExe, lp_cErrorMsg, lp_cWinPc, lp_cFileName, lp_cResponseText, ;
          lp_nFpNr, lp_lCheckEXE
LOCAL l_cFile, l_lFinished, l_nHandle, l_nSize, l_nStatus, l_lSuccess, l_cResponse, l_nRetry, ;
          l_nWaitMS, l_nSec, l_nHandle
l_nSec = 30
l_nWaitMS = 200
l_cResponse = ""

WAIT WINDOW def_msg_sending NOWAIT

IF EMPTY(lp_cWinPc)
     TRY
          lp_cWinPc = ALLTRIM(GETWORDNUM(SYS(0),1," "))
     CATCH
     ENDTRY
     IF EMPTY(lp_cWinPc)
          lp_cWinPc = "STAND_ALONE"
     ENDIF
ENDIF
lp_cWinPc = LOWER(lp_cWinPc)

l_cFile = FORCEEXT(lp_cFileName,def_fileext)
l_cFileResult = ADDBS(lp_cDrvPath) + "res\" + l_cFile
l_cFile = ADDBS(lp_cDrvPath) + l_cFile

* Start driver, when not started
IF lp_lCheckEXE AND NOT FPWingsCheckIsDriverRunning(lp_cDrvExe)
     l_lSuccess = .F.
     lp_cErrorMsg = "NO_DRV_STARTED"
     RETURN l_lSuccess
ENDIF

FPWingsLogCom(lp_cText, lp_nFpNr)

* Write file with commands to folder for fiscal driver
l_nHandle = FCREATE(l_cFile)
IF l_nHandle <> -1
     FWRITE(l_nHandle, lp_cText)
     FFLUSH(l_nHandle, .T.)
     FCLOSE(l_nHandle)
ELSE
     l_lSuccess = .F.
     lp_cErrorMsg = "NO_FILE_WRITTEN"
     RETURN l_lSuccess
ENDIF

* Send file to driver
* We write commands for driver in l_cFile. Driver reads the file, and creates file l_cFileResult with responses.
* Files are not opened exclusive. We can read responses from driver.
* Driver has finished processing when he deletes l_cFile file.
* l_nStatus = 1 - We have send l_cFile with commands.
* l_nStatus = 2 - Driver has created file l_cFileResult with reponse
* l_nStatus = 3 - Driver has deleted l_cFile file, and finished processing of commands.

l_nRetry = 0
DO WHILE NOT l_lFinished
     l_nRetry = l_nRetry + 1
     * command file created
     l_nStatus = 1
     IF FILE(l_cFileResult)
          * result file created
          l_nStatus = 2
          * When finished, command file is deleted
          IF NOT FILE(l_cFile) AND FILE(l_cFileResult)
               * Open it exclusive. When success, driver has finished to write.
               l_nHandle = FOPEN(l_cFileResult,2)
               IF l_nHandle > 0
                    l_nStatus = 3
                    l_nSize =  FSEEK(l_nHandle, 0, 2)
                    l_nSize = MIN(l_nSize, 65535)
                    = FSEEK(l_nHandle, 0, 0)
                    l_cResponse = FREAD(l_nHandle, l_nSize)
                    l_lFinished = .T.
                    FCLOSE(l_nHandle)
               ENDIF
          ENDIF
     ENDIF
     IF NOT l_lFinished
          sleep(l_nWaitMS)
          IF INLIST(l_nStatus, 2)
               WAIT WINDOW FPWingsGetStatus(lp_cDrvPath) NOWAIT
          ENDIF
          IF l_nRetry > (5 * l_nSec) && Wait l_nSec seconds
               IF l_nStatus < 2
                    IF l_nStatus = 1
                         * delete file with commands, driver hasn't taken this file
                         DELETE FILE (l_cFile)
                         l_cResponse = def_msg_no_response
                    ENDIF
                    l_lFinished = .T.
               ELSE
                    * Check if driver is running. If not, start it again.
                    IF lp_lCheckEXE
                         FPWingsCheckIsDriverRunning(lp_cDrvExe)
                    ENDIF
               ENDIF
          ENDIF
     ENDIF
ENDDO

IF LEFT(l_cResponse,1)="0"
     l_lSuccess = .T.
     IF lp_cResponseText = "YES"
          lp_cResponseText = l_cResponse
     ENDIF
ELSE
     l_lSuccess = .F.
     lp_cErrorMsg = "MSG_" + TRANSFORM(l_nStatus)+"_" + l_cResponse
     l_cStatus = FPWingsGetStatus(lp_cDrvPath)
     IF NOT EMPTY(l_cStatus)
          lp_cErrorMsg = l_cStatus + CHR(13) + CHR(13) + lp_cErrorMsg
     ENDIF
     FPWingsLogRes(lp_cErrorMsg, FPWingsGetStatus(lp_cDrvPath))
ENDIF

WAIT CLEAR

RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPWingsCheckIsDriverRunning
LPARAMETERS lp_cDrvExe
LOCAL l_lSuccess, l_cFile
IF EMPTY(lp_cDrvExe)
     l_lSuccess = .T.
ELSE
     l_cFile = ALLTRIM(lp_cDrvExe)
     IF FILE(lp_cDrvExe)
          IF NOT FPWingsIsExeRunning(JUSTFNAME(lp_cDrvExe))
                    FPWingsRunExe(l_cFile)
                    l_lSuccess = FPWingsIsExeRunning(JUSTFNAME(l_cFile))
                    IF l_lSuccess
                         * wait for driver to initialize
                         sleep(1000)
                    ENDIF
          ELSE
              l_lSuccess = .T.
          ENDIF
     ELSE
          l_lSuccess = .T.
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPWingsIsExeRunning(tcName, tlTerminate)
LOCAL loLocator, loWMI, loProcesses, loProcess, llIsRunning

RETURN .T.

loLocator      = CREATEOBJECT('WBEMScripting.SWBEMLocator')
loWMI          = loLocator.ConnectServer() 
loWMI.Security_.ImpersonationLevel = 3            && Impersonate
 
loProcesses     = loWMI.ExecQuery([SELECT * FROM Win32_Process WHERE Name = '] + tcName + ['])
llIsRunning = .F.
IF loProcesses.Count > 0
     FOR EACH loProcess in loProcesses
          llIsRunning = .T.
          IF tlTerminate
               loProcess.Terminate(0)
          ENDIF
     ENDFOR
ENDIF
RETURN llIsRunning
ENDPROC
*
PROCEDURE FPWingsRunExe
LPARAMETERS lp_cFile
IF EMPTY(lp_cFile)
     RETURN .F.
ENDIF 
IF NOT FILE(lp_cFile)
     RETURN .F.
ENDIF
DECLARE INTEGER WinExec IN kernel32 ;
         STRING lpCmdLine ,;
         INTEGER uCmdShow
WinExec(lp_cFile, 1)
CLEAR DLLS "WinExec"
ENDPROC
*
PROCEDURE FPWingsGetStatus
LPARAMETERS lp_cDrvPath
LOCAL l_cStatusFile, l_cStatus, l_cMessage
l_cStatus = ""
l_cMessage = ""
l_cStatusFile = ADDBS(lp_cDrvPath) + "res\status.wng"
IF FILE(l_cStatusFile)
     l_cStatus = FILETOSTR(l_cStatusFile)
     l_cMessage = FPWingsGetHumanReadableErrorMsg(l_cStatus)
ENDIF
RETURN l_cMessage
ENDPROC
*
PROCEDURE FPWingsGetHumanReadableErrorMsg
LPARAMETERS lp_cStatus
*!* Posible statuses:
*!*               A  Opšta greška, poslednja komanda nije uspela
*!*               B  Mehanicka greška u uredaju
*!*               C  Displej nije povezan
*!*               D  Sintaksna greška
*!*               E  Operacija nije dozvoljena
*!*               F  Fiskalni isecak je otvoren
*!*               G  Nefiskalni isecak je otvoren
*!*               H  Ostalo je malo kontrolnog papira (žurnal papir)
*!*               I  Nema više kontrolnog papira
*!*               J  Ostalo je malo papira
*!*               K  Nema više papira
*!*               L  Ostalo je manje od 50 mesta u fiskalnoj memoriji
*!*               M  Fiskalna memorija je puna (više se ne može upisivati u nju)
*!*               N  Uredaj je fiskalizovan

LOCAL l_cErrorMsg, i, l_lNextIsStatus, l_nErrorNo, l_cMessageForUser, l_cUserMsg

l_cErrorMsg = ""
l_cUserMsg = ""

IF EMPTY(lp_cStatus)
     l_cErrorMsg = def_msg_printeroff
ELSE
     ALINES(l_aErr,lp_cStatus)
     * We skip first line, there was info how many error we have
     FOR i = 1 TO ALEN(l_aErr,1)
          l_nErrorNo = 0
          l_cCode = ALLTRIM(LEFT(l_aErr(i),2))
          l_cCode = STRTRAN(l_cCode,def_cTab,"") && Remove Tabs
          *l_cMessageForUser = ALLTRIM(SUBSTR(l_aErr(i),3))
          l_cMessageForUser = ALLTRIM(l_aErr(i))
          DO CASE
               CASE l_cCode == "C"
                     l_cErrorMsg = l_cErrorMsg + l_cMessageForUser + CHR(13)
               CASE l_cCode == "K"
                     l_cUserMsg = l_cUserMsg + def_msg_paperopen + CHR(13)
                     l_cErrorMsg = l_cErrorMsg + l_cMessageForUser + CHR(13)
               CASE l_cCode == "I"
                     l_cUserMsg = l_cUserMsg + def_msg_ctrlpaperopen + CHR(13)
                     l_cErrorMsg = l_cErrorMsg + l_cMessageForUser + CHR(13)
               CASE l_cCode == "M"
                     l_cErrorMsg = l_cErrorMsg + l_cMessageForUser + CHR(13)
          ENDCASE
     ENDFOR
     IF NOT EMPTY(l_cErrorMsg)
          IF NOT EMPTY(l_cUserMsg)
               l_cErrorMsg = l_cErrorMsg + CHR(13) + CHR(13) + l_cUserMsg
          ENDIF
     ENDIF
ENDIF
RETURN l_cErrorMsg
ENDPROC
*
PROCEDURE FPWingsLogCom
LPARAMETERS lp_cText, lp_nFpNr
LOCAL l_nSelect, l_oData, l_cTablePath
IF EMPTY(lp_nFpNr)
     lp_nFpNr = 0
ENDIF
l_nSelect = SELECT()

DO CASE
	CASE TYPE("_screen.oGlobal.choteldir")="C" AND NOT EMPTY(_screen.oGlobal.choteldir)
		l_cTablePath = _screen.oGlobal.choteldir
	CASE TYPE("gcargusdir")="C" AND NOT EMPTY(gcargusdir)
		l_cTablePath = gcargusdir
	OTHERWISE
		l_cTablePath = ""
ENDCASE

l_cTablePath = ""

TRY
     IF NOT FILE(l_cTablePath+"fpwingslog.dbf")
          CREATE TABLE (l_cTablePath+"fpwingslog") (fp_id i AUTOINC, fp_fpnr n(2), fp_date t, fp_com m, fp_res m, fp_status m)
          USE IN fpwingslog
     ENDIF
     IF NOT USED("fpwingslog")
          USE (l_cTablePath+"fpwingslog") SHARED IN 0 AGAIN
     ENDIF
     SELECT fpwingslog
     SCATTER NAME l_oData MEMO BLANK FIELDS EXCEPT fp_id
     l_oData.fp_date = DATETIME()
     l_oData.fp_com = lp_cText
     l_oData.fp_fpnr = lp_nFpNr
     INSERT INTO fpwingslog FROM NAME l_oData
     FLUSH
CATCH
ENDTRY
SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FPWingsLogRes
LPARAMETERS lp_cResponse, lp_cStatus
TRY
     IF NOT EMPTY(lp_cResponse) AND USED("fpwingslog")
          IF EMPTY(lp_cStatus)
               lp_cStatus = ""
          ENDIF
          REPLACE fp_res WITH lp_cResponse, ;
                    fp_status WITH lp_cStatus IN fpwingslog
          FLUSH
     ENDIF
CATCH
ENDTRY
ENDPROC
*
PROCEDURE FPWingsBill
LPARAMETERS lp_cText, lp_cErrorMsg, lp_cBillCur
LOCAL l_cPoint, l_nSelect, l_cLine, l_lSuccess, l_lHasArticle, l_cDuplArtCur, l_cArticleFialList
l_lSuccess = .T.
IF EMPTY(lp_cBillCur)
     l_lSuccess = .F.
     lp_cErrorMsg = "NO_POSTINGS_ON_BILL"
     RETURN l_lSuccess
ENDIF

* check for same articles with diffrent price
l_cDuplArtCur = SYS(2015)
SELECT plu, COUNT(*) AS pfound ;
     FROM ( ;
     SELECT plu, price ;
          FROM (lp_cBillCur) ;
          WHERE cmd = "S" ;
          GROUP BY plu, price ;
          ) AS c1 ;
     GROUP BY plu ;
     HAVING pfound > 1 ;
     INTO CURSOR (l_cDuplArtCur)
IF RECCOUNT()>0

     l_cArticleFialList = ""
     SCAN ALL
          l_cArticleFialList = l_cArticleFialList + ALLTRIM(TRANSFORM(plu)) + ", "
     ENDSCAN
     l_cArticleFialList = LEFT(l_cArticleFialList, LEN(l_cArticleFialList)-2)

     l_lSuccess = .F.
     lp_cErrorMsg = def_msg_duplicate_art+ " " + l_cArticleFialList
     RETURN l_lSuccess
ENDIF
USE IN &l_cDuplArtCur

l_cPoint = SET("Point")
SET POINT TO "."
l_nSelect = SELECT()

lp_cText = ""

lp_cText = lp_cText + "#FISKAL" + def_cLF
SELECT (lp_cBillCur)
* First add all orders, then stornos, and then payments
SCAN FOR PrintOrder = 1 && Orders
     l_cLine = ALLTRIM(PLU) + def_cTab + ALLTRIM(Descript) + def_cTab + ;
               IIF(TYPE("qtymes")="C" AND NOT EMPTY(qtymes),ALLTRIM(qtymes),def_cQtyMeasure) + def_cTab + ;
               IIF(RIGHT(STR(Units,14,3),3)="000",ALLTRIM(TRANSFORM(Units,"9999999999")),ALLTRIM(STR(Units,14,3))) + def_cTab + ;
               ALLTRIM(TRANSFORM(Price,"9999999999.99")) + ;
               def_cTab + TRANSFORM(VAT) + ;
               def_cLF
     lp_cText = lp_cText + l_cLine
ENDSCAN
l_lHasArticle = RECCOUNT()>0
IF NOT l_lHasArticle
     l_lSuccess = .F.
     lp_cErrorMsg = "NO_ARTICLE_DEFINED"
ENDIF
IF l_lSuccess
     SCAN FOR PrintOrder = 2 && Stornos
          l_cLine = ALLTRIM(PLU) + def_cTab + ALLTRIM(Descript) + def_cTab + ;
                    IIF(TYPE("qtymes")="C" AND NOT EMPTY(qtymes),ALLTRIM(qtymes),def_cQtyMeasure) + def_cTab + ;
                    ALLTRIM(TRANSFORM(Units,"9999999999.999")) + def_cTab + ALLTRIM(TRANSFORM(Price,"9999999999.99")) + ;
                    def_cTab + TRANSFORM(VAT) + ;
                    def_cLF
          lp_cText = lp_cText + l_cLine
     ENDSCAN

     l_cLine = "#PLACANJE" + def_cLF
     lp_cText = lp_cText + l_cLine
     SCAN FOR PrintOrder = 3 && Payments
          DO CASE
               CASE Cmd = "C"
                    l_cLine = "CEKOVI"
               CASE Cmd = "K"
                    l_cLine = "KARTICA"
               CASE Cmd = "G"
                    l_cLine = "GOTOVINA"
               OTHERWISE
                    l_lSuccess = .F.
                    lp_cErrorMsg = "NO_PAYMENT_DEFINED"
                    EXIT
          ENDCASE
          l_cLine = l_cLine + def_cTab + ALLTRIM(TRANSFORM(Price,"9999999999.99")) + def_cLF
          lp_cText = lp_cText + l_cLine
     ENDSCAN
ENDIF
SET POINT TO l_cPoint
SELECT(l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPWingsSendArticles
LPARAMETERS lp_cText, lp_cErrorMsg, lp_cArtCur
LOCAL l_cPoint, l_nSelect, l_cLine, l_lSuccess, l_lHasArticle, l_cDuplArtCur, l_cArticleFialList
l_lSuccess = .T.
IF EMPTY(lp_cArtCur)
     l_lSuccess = .F.
     lp_cErrorMsg = "NO_ARTICLES_TO_SEND"
     RETURN l_lSuccess
ENDIF

l_cPoint = SET("Point")
SET POINT TO "."
l_nSelect = SELECT()
lp_cText = "#ARTIKLI" + def_cLF


SELECT (lp_cArtCur)
SCAN FOR Price > 0
     l_cLine = ALLTRIM(PLU) + def_cTab + ;
               ALLTRIM(Descript) + def_cTab + ;
               def_cQtyMeasure + def_cTab + ;
                "1" + def_cTab + ;
                ALLTRIM(TRANSFORM(Price,"9999999999.99")) + def_cTab + ;
               TRANSFORM(VAT) + ;
               def_cLF
     lp_cText = lp_cText + l_cLine
ENDSCAN

SET POINT TO l_cPoint
SELECT(l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPWingsSendVatGroups
LPARAMETERS lp_cText, lp_cErrorMsg, lp_cCur
LOCAL l_cPoint, l_nSelect, l_cLine, l_lSuccess, l_lHasArticle, l_cDuplArtCur, l_cArticleFialList
l_lSuccess = .T.
IF EMPTY(lp_cCur)
     l_lSuccess = .F.
     lp_cErrorMsg = "NO_ARTICLES_TO_SEND"
     RETURN l_lSuccess
ENDIF

l_cPoint = SET("Point")
SET POINT TO "."
l_nSelect = SELECT()
lp_cText = "#SET_TAX_AMOUNT" + def_cLF

SELECT (lp_cCur)
SCAN ALL
     l_cLine = TRANSFORM(c_vatgrp) + def_cTab + ;
               STR(c_vatpct,5,1) + ;
               def_cLF
     lp_cText = lp_cText + l_cLine
ENDSCAN

SET POINT TO l_cPoint
SELECT(l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE FPRemoveSpecChars
LPARAMETERS lp_cString
LOCAL l_cNewString
l_cNewString = ""
IF NOT EMPTY(lp_cString)
     l_cNewString = lp_cString
     l_cNewString = STRTRAN(l_cNewString,"È","C")
     l_cNewString = STRTRAN(l_cNewString,"Æ","C")
     l_cNewString = STRTRAN(l_cNewString,"Š","C")
     l_cNewString = STRTRAN(l_cNewString,"Ð","DJ")
     l_cNewString = STRTRAN(l_cNewString,"Ž","Z")
     l_cNewString = STRTRAN(l_cNewString,"è","c")
     l_cNewString = STRTRAN(l_cNewString,"æ","c")
     l_cNewString = STRTRAN(l_cNewString,"š","s")
     l_cNewString = STRTRAN(l_cNewString,"ð","dj")
     l_cNewString = STRTRAN(l_cNewString,"ž","z")
ENDIF
RETURN l_cNewString
ENDPROC