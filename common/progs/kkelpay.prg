#DEFINE C_KK_MIN_TIMEOUT                25

#DEFINE C_KK_SENDING                    "Daten werden bearbeitet..."
#DEFINE C_KK_RESPONSE                   "Antwort ist angekomen."
#DEFINE C_KK_TIMEOUT                    "Zeit ist abgelaufen, Transaktion ist abgebrochen!"
#DEFINE C_KK_OK                         "Erfolg"
#DEFINE C_KK_CANCEL                     "Fehlgeschlagen"
#DEFINE C_KK_PROCCESS_PREVIOUS          "System Bearbeitung. Bitte warten."
#DEFINE C_KK_ELPAY_OFFLINE              "elPay Treiber nicht gestartet / offline."
#DEFINE C_KK_NO_CLIENT_ID               "Klient ID ist nicht definiert für diese Arbeitstation."
#DEFINE C_KK_IN_FILE_FOUND              "In Datei gefunden."
#DEFINE C_KK_OUT_FILE_CANT_PROCCESS     "Kann nicht die Out Datei bearbeiten."
#DEFINE C_KK_IN_FILE_CANT_CREATE        "Kann nicht die In Date erstellen."
#DEFINE C_KK_INVALID_PARAMETERS         "Ungültige Parameter."
#DEFINE C_KK_PRINTING                   "Drucken elPay Quittung..."
#DEFINE C_KK_IN_FILE_IS_STIL_PROCCESSED "Das System verarbeitet noch die Letzte Anforderung, Transaktion ist abgebrochen!"
#DEFINE C_KK_WAIT_MORE                  "Zeit ist abgelaufen, wollen Sie noch ein bisschen warten?"
#DEFINE C_KK_YESNO_DIALOG               "elPay Abfrage"
#DEFINE C_KK_OLD_OUTFILE_FOUND_AND_PRNT "Ein Beleg von elPay auf eine frühere Kreditkartenzahlung ist gefunden! Bitte überprüfen ob diese soll storniert werden!"

*PROCEDURE kkelpay
LPARAMETERS lp_cFunction, lp_cStation, lp_cAmount, lp_cCreditCard, lp_cExpDate, lp_cMpos, lp_lFakeVisa, lp_lZReader
LOCAL l_lSuccess, l_cTrack1, l_cTrack2, l_cTrack3
* Test
*RELEASE g_oElPay
*PUBLIC g_oElPay

* VISA       422222222222222
* AMEX       378282246310005
* DINNERS    30569309025904
* MASTERCARD 5555555555554444
* JCB        3530111333300000

IF lp_lFakeVisa
     STORE "" TO lp_cCreditCard, lp_cExpDate, lp_cMpos
     kkGenFakeVisa(@l_cTrack1, @l_cTrack2)
ENDIF

g_oElPay = CREATEOBJECT("celpay")
g_oElPay.cProgressEvent = "kkshowprogress"
l_lSuccess = g_oElPay.Start(lp_cFunction,lp_cAmount,"Citadel Desk","9.09.112",lp_cStation,lp_cCreditCard,lp_cExpDate,;
          lp_cMpos,l_cTrack1,l_cTrack2,l_cTrack3,,,,lp_lZReader)
? "(" + g_oElPay.cerrorcode + ") " + g_oElPay.cerrortext

RETURN l_lSuccess
ENDPROC
*
PROCEDURE kkshowprogress
LPARAMETERS lp_cText
WAIT WINDOW lp_cText NOWAIT
RETURN .T.
ENDPROC
*
PROCEDURE kkGenFakeVisa
LPARAMETERS lp_cTrac1, lp_cTrac2
LOCAL l_cTrack1, l_cTrack2, l_cLRC

l_cTrack1 = "%B4053667506298698^PADILLA/L.                ^12041200000000000000**690******?"
l_cLRC = kklrcget(l_cTrack1)
l_cTrack1 = l_cTrack1 + l_cLRC
l_cTrack2 = ";4053667506298698=12041200123400000000?"
l_cLRC = kklrcget(l_cTrack2)
l_cTrack2 = l_cTrack2 + l_cLRC
lp_cTrac1 = l_cTrack1
lp_cTrac2 = l_cTrack2
ENDPROC
*
PROCEDURE kklrcget
LPARAMETERS tcMsg
LOCAL i, l_nResult
l_nResult = 0
FOR i =  1 TO LEN(tcMsg)
     l_nOneByte = ASC(SUBSTR(tcMsg, i, 1))
     l_nResult = BITXOR(l_nOneByte, l_nResult)
ENDFOR

l_cResult = CHR(l_nResult)

RETURN l_cResult
ENDPROC
*
DEFINE CLASS celpay AS Custom
*
#IF .F. && Make sure this is false, otherwise error
   *-- Define This for IntelliSense use
   LOCAL this AS celpay OF kkelpay.prg
#ENDIF
*
lSuccess = .F.
cSoftwareName = ""
cSoftwareversion = ""
cWinPc = ""
cFolder = ""
cLogFile = "kkelpay.log"
cinifile = "kkelpay.ini"
cClientId = ""
cClientlist = ""
ndebugdetaillevel = 1
cInFile = ""
cOutFile = ""
cBDDFile = ""
cActive = "Aktiv.$$$"
cStationProccessingFile = ""
noutfiledelay = 90
dOutFileWait = {}
cwinpcreal = ""
cprogressevent = ""
cprintevent = ""
lshowprogress = .T.
cerrortext = "OK"
cerrorcode = "0"
nelpaypaynum = 0
loldoutfilefound = .F.
lDontDisplayMessageBox = .F.
*
PROCEDURE Start(lp_cFunction AS String, lp_cAmount AS String, lp_cSoftwareName AS String, ;
          lp_cSoftwareVersion AS String, lp_cWinPc AS String, lp_cCreditCardNo As String, ;
          lp_cValidUntil AS String, lp_cMops AS String, lp_cSpur1 AS String, lp_cSpur2 AS String, lp_cSpur3 AS String, ;
          lp_nPrintWidth AS Number, lp_nClientId AS Number, lp_nTimeoutsec AS Number, lp_lZreader AS Boolean, ;
          lp_cClientlist AS String, lp_lUsepad AS Boolean, lp_lOnlyCheckAktive AS Boolean, ;
          lp_cBelegNr AS String, lp_cFolder AS String, lp_cpaywish AS String, lp_cZahlart AS String, lp_lDontDisplayMessageBox AS Logical) ;
          AS Boolean

LOCAL l_lSuccess
this.lSuccess = .F.
l_lSuccess = .F.
IF EMPTY(lp_cZahlart) OR VARTYPE(lp_cZahlart)<>"C"
     lp_cZahlart = ""
ELSE
     lp_cZahlart = LOWER(lp_cZahlart)
ENDIF
this.Logit("STR|"+;
          "STATION:"+TRANSFORM(lp_cWinPc)+"|"+;
          "CLIENTID:"+TRANSFORM(lp_nClientId)+"|"+;
          "ZREADER:"+TRANSFORM(lp_lZreader)+"|"+;
          "CLIENTLIST:"+TRANSFORM(lp_cClientlist)+"|"+;
          "FUNCTION:"+TRANSFORM(lp_cFunction)+"|"+;
          "AMOUNT:"+TRANSFORM(lp_cAmount)+"|"+;
          "SOFTNAME:"+TRANSFORM(lp_cSoftwareName)+"|"+;
          "SOFTVER:"+TRANSFORM(lp_cSoftwareVersion)+"|"+;
          "USEPINPAD:"+TRANSFORM(lp_lUsepad)+"|"+;
          "ONLYCHECKAKTIVE:"+TRANSFORM(lp_lOnlyCheckAktive)+"|"+;
          "BELEGNR:"+TRANSFORM(lp_cBelegNr)+"|"+;
          "ELPAYDIR:"+TRANSFORM(lp_cFolder)+"|"+;
          "ZAHLUNGSWUNSCH:"+TRANSFORM(lp_cpaywish)+"|"+;
          "ZAHLART:"+TRANSFORM(lp_cZahlart)+"|"+;
          "PRINTWIDTH:"+TRANSFORM(lp_nPrintWidth))

IF ((EMPTY(lp_cFunction) OR EMPTY(lp_cWinPc)) AND NOT (lp_lZreader OR lp_lOnlyCheckAktive)) ;
          OR EMPTY(lp_cSoftwareName) OR EMPTY(lp_cSoftwareVersion) OR EMPTY(lp_cFolder)
     this.Logit("EXT|Invalid parameters.")
     this.cerrorcode = "-7"
     this.cerrortext = C_KK_INVALID_PARAMETERS
     RETURN l_lSuccess
ENDIF

this.cWinPc = UPPER(ALLTRIM(lp_cWinPc))
this.cSoftwareName = lp_cSoftwareName
this.cSoftwareVersion = lp_cSoftwareVersion
this.lDontDisplayMessageBox = lp_lDontDisplayMessageBox

this.oinfile.cFunktion = lp_cFunction
this.oinfile.cBetrag = lp_cAmount
this.oinfile.cZahlart = lp_cZahlart
this.oinfile.cBeleg = IIF(EMPTY(lp_cBelegNr),"",ALLTRIM(TRANSFORM(lp_cBelegNr)))
this.oinfile.cSoftwareName = this.cSoftwareName
this.oinfile.cSoftwareVersion = this.cSoftwareVersion
this.oinfile.cPAN = IIF(EMPTY(lp_cCreditCardNo),"",ALLTRIM(TRANSFORM(lp_cCreditCardNo)))
this.oinfile.cVerfalldatum = IIF(EMPTY(lp_cValidUntil),"",ALLTRIM(TRANSFORM(lp_cValidUntil)))
this.oinfile.cMOPS = IIF(EMPTY(lp_cMops),"",ALLTRIM(TRANSFORM(lp_cMops)))
this.oinfile.cSpur1 = IIF(EMPTY(lp_cSpur1),"",lp_cSpur1)
this.oinfile.cSpur2 = IIF(EMPTY(lp_cSpur2),"",lp_cSpur2)
this.oinfile.cSpur3 = IIF(EMPTY(lp_cSpur3),"",lp_cSpur3)
this.oinfile.cDruckbreite = IIF(EMPTY(lp_nPrintWidth) OR (VARTYPE(lp_nPrintWidth)="N" AND NOT BETWEEN(lp_nPrintWidth,30,150)),"",TRANSFORM(lp_nPrintWidth))
this.oinfile.cZahlungswunsch = IIF(EMPTY(lp_cpaywish),"",lp_cpaywish)

this.cFolder = ALLTRIM(lp_cFolder)
IF NOT EMPTY(this.cFolder)
     this.cFolder = ADDBS(this.cFolder)
ENDIF
IF VARTYPE(lp_nClientId)="N"
     this.cClientId = PADL(TRANSFORM(lp_nClientId),3,"0")
ELSE
     this.cClientId = this.readini("clients", this.cWinPc, "")
ENDIF
TRY
     this.ndebugdetaillevel = INT(VAL(this.readini("settings", "debugdetaillevel", "1")))
CATCH
ENDTRY
IF VARTYPE(lp_nTimeoutsec)="N" AND NOT EMPTY(lp_nTimeoutsec)
     this.noutfiledelay = lp_nTimeoutsec
ELSE
     TRY
          this.noutfiledelay = INT(VAL(this.readini("settings", "timeoutsec", "90")))
     CATCH
     ENDTRY
ENDIF
IF this.noutfiledelay < C_KK_MIN_TIMEOUT
     this.noutfiledelay = C_KK_MIN_TIMEOUT
ENDIF
IF lp_lUsepad
     * When using pinpad, double the timeout value. User must give card and enter pin code, which can take some time.
     this.noutfiledelay = this.noutfiledelay * 2
ENDIF
IF lp_lZreader
     this.cclientlist = IIF(EMPTY(lp_cClientlist),"",lp_cClientlist)
ENDIF
IF lp_lOnlyCheckAktive
     l_lSuccess = this.Prepare(lp_lOnlyCheckAktive)
ELSE
     IF this.Prepare()
          IF lp_lZreader
               * We wished only to proccess timed out request.
               l_lSuccess = .T.
          ELSE
               IF this.CreateInFile()
                    IF this.GetOutFile()
                         l_lSuccess = this.ProcessOutFile()
                    ENDIF
               ENDIF
          ENDIF
     ENDIF
ENDIF
this.lSuccess = l_lSuccess
this.Logit("FIN|"+"SUCCESS:"+TRANSFORM(this.lSuccess)+"|"+"ERRORCODE:"+TRANSFORM(this.ceRRORCODE)+"|"+"ERRORTEXT:"+TRANSFORM(this.ceRRORTEXT)+"|")
RETURN l_lSuccess
ENDPROC
*
PROCEDURE Prepare
LPARAMETERS lp_lOnlyCheckAktive
LOCAL l_lSuccess, l_lAktiveFileFound, i, l_nOutFilesFound
LOCAL ARRAY l_aOutFiles(1)

IF NOT EMPTY(this.cFolder) AND DIRECTORY(this.cFolder)
     IF NOT EMPTY(this.cClientId) AND this.cClientId <> "000"
          this.cInFile = this.cFolder + "infile."+this.cClientId
          this.cOutFile = this.cFolder + "outfile."+this.cClientId
          this.cBDDFile = this.cFolder + "bdd."+this.cClientId
          this.cStationProccessingFile = this.cFolder + this.cClientId + ".$$$"
          FOR i = 1 TO 20
               IF FILE(this.cFolder + this.cActive)
                    l_lAktiveFileFound = .T.
                    EXIT
               ELSE
                    sleep(50)
               ENDIF
          ENDFOR
          IF l_lAktiveFileFound
               l_lSuccess = .T.
          ELSE
               this.Logit("EXT|No aktive file found. (elpay offline?)")
               this.cerrorcode = "-1"
               this.cerrortext = C_KK_ELPAY_OFFLINE
          ENDIF
     ELSE
          this.Logit("EXT|No ClientId defined for workstation " + this.cWinPc + " (check kkelpay.ini).")
          this.cerrorcode = "-2"
          this.cerrortext = C_KK_NO_CLIENT_ID
     ENDIF
ELSE
     this.Logit("EXT|Invalid folder.")
ENDIF
IF lp_lOnlyCheckAktive
     RETURN l_lSuccess
ENDIF
IF l_lSuccess
     IF FILE(this.cInFile)
          l_lSuccess = .F.
          this.Logit("EXT|In  file "+this.ciNFILE+"  for this station already found.")
          this.cerrorcode = "-3"
          this.cerrortext = C_KK_IN_FILE_FOUND
     ENDIF
ENDIF

* We don't check for 001.$$$ file, becouse it can happen, that this file is left behind from elpay server,
* and is'nt indicating, that some infile is processed!
*!*     IF l_lSuccess
*!*          IF FILE(this.cStationProccessingFile)
*!*               l_lSuccess = .F.
*!*               this.Logit("EXT|The previous in file is still processed. Aborting.")
*!*               this.cerrorcode = "-9"
*!*               this.cerrortext = C_KK_IN_FILE_IS_STIL_PROCCESSED
*!*          ENDIF
*!*     ENDIF

this.loldoutfilefound = .F.
IF l_lSuccess
     IF this.oinfile.cFunktion=  "99" && Funktion 99; Kassenschnitt (Kassenabschluss)
          * Check all pending outfiles for this elpay server folder
          l_nOutFilesFound = ADIR(l_aOutFiles, this.cFolder+"outfile.*")
          IF l_nOutFilesFound > 0
               FOR i = 1 TO l_nOutFilesFound
                    l_cClientId = PADL(JUSTEXT(l_aOutFiles(i,1)),3,"0")
                    IF NOT EMPTY(l_cClientId)
                         l_lSuccess = this.CheckPendingOutfile(l_cClientId)
                         IF NOT l_lSuccess
                              EXIT
                         ENDIF
                    ENDIF
               ENDFOR
          ENDIF
     ELSE
          * Only check pending outfile for this station.
          l_lSuccess = this.CheckPendingOutfile()
     ENDIF
*!*          IF NOT EMPTY(this.cclientlist)
*!*               l_nClients = GETWORDCOUNT(this.cclientlist,"|")
*!*               FOR i = 1 TO l_nClients
*!*                    l_cClientId = GETWORDNUM(this.cclientlist,i,"|")
*!*                    IF NOT EMPTY(l_cClientId)
*!*                         l_cClientId = PADL(l_cClientId,3,"0")
*!*                         l_lSuccess = this.CheckPendingOutfile(l_cClientId)
*!*                         IF NOT l_lSuccess
*!*                              EXIT
*!*                         ENDIF
*!*                    ENDIF
*!*               ENDFOR
*!*          ELSE
*!*               l_lSuccess = this.CheckPendingOutfile()
*!*          ENDIF
     IF this.loldoutfilefound AND l_lSuccess
          * We have found old unproccessed answer from elpay. We have printed it. User must decide what to do with it.
          this.cerrorcode = "-10"
          this.cerrortext = C_KK_OLD_OUTFILE_FOUND_AND_PRNT
          l_lSuccess = .F.
     ENDIF
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE CheckPendingOutfile
LPARAMETERS lp_cClientId
LOCAL l_lSuccess, l_cOldClient
l_lSuccess = .T.
IF NOT EMPTY(lp_cClientId)
     l_cOldClient = JUSTEXT(this.couTFILE)
     this.cinFILE = FORCEEXT(this.cinFILE, lp_cClientId)
     this.couTFILE = FORCEEXT(this.couTFILE, lp_cClientId)
ENDIF
IF FILE(this.couTFILE)
     ****************************************************
     * ATTENTION:                                       *
     * Must check this answer. User should manualy make *
     * storno, if needed.                               *
     ****************************************************
     IF NOT this.loldoutfilefound
          this.loldoutfilefound = .T.
     ENDIF
     this.Logit("EXT|Out file "+this.couTFILE+" for this station already found.")
     this.lShowProgress = .F.
     IF this.GetOutFile()
          this.Logit("EXT|Out file "+this.couTFILE+" is processed.")
          *l_lSuccess = this.CancelOutFile()
          l_lSuccess = this.ProcessPreviousOutFile()
     ELSE
          l_lSuccess = .F.
          this.Logit("EXT|Out file "+this.couTFILE+" can't be proccessed. Aborting.")
          this.cerrorcode = "-4"
          this.cerrortext = C_KK_OUT_FILE_CANT_PROCCESS
     ENDIF
     this.lShowProgress = .T.
ENDIF
IF NOT EMPTY(lp_cClientId)
     this.cinFILE = FORCEEXT(this.cinFILE, l_cOldClient)
     this.couTFILE = FORCEEXT(this.couTFILE, l_cOldClient)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE RemoveSensitiveData
LPARAMETERS lp_cText
* Remove sensitive data before writing into log!
LOCAL l_cText
l_cText = lp_cText
IF NOT EMPTY(lp_cText)
     l_cText = STRTRAN(l_cText, STREXTRACT(l_cText, "Spur1:", CHR(13)), "******")
     l_cText = STRTRAN(l_cText, STREXTRACT(l_cText, "Spur2:", CHR(13)), "******")
     l_cText = STRTRAN(l_cText, STREXTRACT(l_cText, "Spur3:", CHR(13)), "******")
     l_cText = STRTRAN(l_cText, STREXTRACT(l_cText, "MOPS:", CHR(13)), "******")
ENDIF
RETURN l_cText
ENDPROC
*
PROCEDURE CreateInFile
LOCAL l_lSuccess

this.oinfile.CreateText()

l_lSuccess = this.WriteFile(this.cInFile, this.oinfile.cInText)
IF l_lSuccess
     this.Logit("<--|In  file " + this.cinFILE + "  sent.")
     IF this.ndebugdetaillevel = 2
          this.Logit(this.oinfile.cInText,.T.,"<--|",.T.)
     ENDIF
ELSE
     this.Logit("EXT|In  file " + this.cinFILE + "  can't be created!")
     this.cerrorcode = "-5"
     this.cerrortext = C_KK_IN_FILE_CANT_CREATE
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE GetOutFile
LOCAL l_lSuccess, l_nHandle, l_nSize
this.ShowProgress(C_KK_SENDING)
this.dOutFileWait = DATETIME()

DO WHILE .T.
     IF DATETIME()-this.dOUTFILEWAIT>this.nOUTFILEDELAY
          IF this.yesno(C_KK_WAIT_MORE)
               this.dOutFileWait = DATETIME()
          ELSE
               l_lSuccess = .F.
               EXIT
          ENDIF
     ELSE
          sleep(10)
          wait window "" timeout .001
          DOEVENTS
          * Process file with messages to cashier
          IF FILE(this.cBDDFile)
               this.GetBDDFile()
          ENDIF
          IF FILE(this.cOutFile)
               l_nHandle = FOPEN(this.cOutFile,2) && Open it exclusive. When success, driver has finished to write.
               IF l_nHandle > 0
                    l_lSuccess = .T.
                    EXIT
               ENDIF
          ENDIF
     ENDIF
ENDDO
IF l_lSuccess
     this.ShowProgress(C_KK_RESPONSE)
     l_nSize =  FSEEK(l_nHandle, 0, 2)
     l_nSize = MIN(l_nSize, 65535)
     = FSEEK(l_nHandle, 0, 0)
     this.ooutfile.cOutText = FREAD(l_nHandle, l_nSize)
     FCLOSE(l_nHandle)
     this.Logit("-->|Out file " + this.cOutFile + " received.")
     IF this.ndebugdetaillevel = 2
          this.Logit(this.ooutfile.cOutText,.T.,"-->|")
     ENDIF
     this.DeleteFile(this.cOutFile)
ELSE
     this.ShowProgress(C_KK_TIMEOUT)
     this.Logit("EXT|Out file " + this.cOutFile+ " not found. Timeout. Aborting.")
     this.cerrorcode = "-6"
     this.cerrortext = C_KK_TIMEOUT
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE GetBDDFile
LOCAL l_lError, i, l_cBDDMsg
this.Logit("-->|BDD file " + this.cBDDFile + " received.")
FOR i = 1 TO 3
     sleep(100)
     l_lError = .F.
     TRY
          l_cBDDMsg = FILETOSTR(this.cBDDFile)
     CATCH
          l_lError = .T.
     ENDTRY
     IF NOT l_lError
          EXIT
     ENDIF
ENDFOR
IF NOT EMPTY(l_cBDDMsg)
     IF this.ndebugdetaillevel = 2
          this.Logit(l_cBDDMsg,.T.,"-->|")
     ENDIF
     this.ShowProgress(l_cBDDMsg)
ENDIF
this.DeleteFile(this.cBDDFile)
RETURN .T.
ENDPROC
*
PROCEDURE ProcessOutFile
LOCAL l_lSuccess

l_lSuccess = this.ooutfile.ProcessFile()

this.cerrorcode = this.ooutfile.cFehlercode
this.cerrortext = this.ooutfile.cFehlertext

this.SendToPrinter(this.ooutfile.cPrintText)
this.nelpaypaynum = INT(VAL(this.ooutfile.cKartenart))

IF l_lSuccess
     this.Logit("EXT|Out file " + this.cOutFile+ " SUCCESS.")
     this.ShowProgress(C_KK_OK)
ELSE
     this.Logit("EXT|Out file " + this.cOutFile+ " FAILED.")
     this.ShowProgress(C_KK_CANCEL)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE ProcessPreviousOutFile
LOCAL l_lSuccess, l_oInFile AS celpayinfile OF kkelpay.prg
this.lShowProgress = .T.
this.ShowProgress(C_KK_PROCCESS_PREVIOUS)
this.lShowProgress = .F.
l_lSuccess = this.ProcessOutFile()
RETURN l_lSuccess
ENDPROC
*
PROCEDURE CancelOutFile
LOCAL l_lSuccess, l_oInFile AS celpayinfile OF kkelpay.prg
this.lShowProgress = .T.
this.ShowProgress(C_KK_PROCCESS_PREVIOUS)
this.lShowProgress = .F.
l_lSuccess = this.ProcessOutFile()

IF l_lSuccess
     IF INLIST(this.ooutfile.cFunktion, "01", "11")
          * This is storno success report. Ignore it.
          l_lSuccess = .T.
     ELSE
          * Last attempt was succes, we must storno this payment now.
          l_lSuccess = .F.
          l_oInFile = CREATEOBJECT("celpayinfile")

          l_oInFile.cFunktion = ICASE(this.ooutfile.cFunktion = "10", "11", "01") && We must set appropiate storno function.
          l_oInFile.cBeleg = this.ooutfile.cBelegNr
          l_oInFile.cBetrag = this.ooutfile.cBetrag
          l_oInFile.cValuta = this.ooutfile.cValuta
          l_oInFile.cPAN = IIF(EMPTY(this.ooutfile.cPAN),"",this.ooutfile.cPAN)
          l_oInFile.cVerfallDatum = IIF(EMPTY(this.ooutfile.cVerfallDatum),"",this.ooutfile.cVerfallDatum)

          l_oInFile.cSoftwareName = this.cSoftwareName
          l_oInFile.cSoftwareVersion = this.cSoftwareVersion

          l_oInFile.CreateText()

          l_lSuccess = this.WriteFile(this.cInFile, l_oInFile.cInText)
          IF l_lSuccess
               l_lSuccess = .F.
               this.dOutFileWait = DATETIME()
               this.Logit("<--|In  file " + this.cinFILE + "  sent.")
               IF this.ndebugdetaillevel = 2
                    this.Logit(l_oInFile.cInText,.T.,"<--|")
               ENDIF
               IF this.GetOutFile()
                    l_lSuccess = this.ProcessOutFile()
               ENDIF
          ELSE
               this.Logit("EXT|In  file " + this.cinFILE + "  can't be created!")
               this.cerrorcode = "-5"
               this.cerrortext = C_KK_IN_FILE_CANT_CREATE
          ENDIF
          l_oInFile.Release()
          l_oInFile = .NULL.
     ENDIF
ELSE
     * Last attempt failed, so ignore it.
     l_lSuccess = .T.
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE Init
LOCAL l_lFoundgetprivateprofilestring, l_lFoundsleep, i
LOCAL ARRAY l_aDlls(1)

* Declare DLLS, when needed

IF ADLLS(l_aDlls)>0
     FOR i = 1 TO ALEN(l_aDlls,1)
          IF LOWER(ALLTRIM(l_aDlls(i,1))) == "getprivateprofilestring"
               l_lFoundgetprivateprofilestring = .T.
          ENDIF
          IF LOWER(ALLTRIM(l_aDlls(i,1))) == "sleep"
               l_lFoundsleep = .T.
          ENDIF
          IF l_lFoundgetprivateprofilestring AND l_lFoundsleep
               EXIT
          ENDIF
     ENDFOR
ENDIF
IF NOT l_lFoundgetprivateprofilestring
     declare integer GetPrivateProfileString in Win32API string cSection, ;
          string cEntry, string cDefault, string @ cBuffer, integer nBufferSize, ;
          string cINIFile
ENDIF
IF NOT l_lFoundsleep
     DECLARE Sleep IN Win32API INTEGER nMilliseconds
ENDIF

this.GetRealPcName()

this.AddObject("oinfile","celpayinfile")
this.AddObject("ooutfile","celpayoutfile")

RETURN .T.
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
PROCEDURE WriteFile
LPARAMETERS lp_cFile, lp_cText
LOCAL l_lSuccess, l_nHandle
l_nHandle = FCREATE(lp_cFile)
IF l_nHandle <> -1
     FWRITE(l_nHandle, lp_cText)
     FFLUSH(l_nHandle, .T.)
     FCLOSE(l_nHandle)
     l_lSuccess = .T.
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE DeleteFile
LPARAMETERS lp_cFileName
LOCAL i, l_lError
IF NOT EMPTY(lp_cFileName)
     FOR i = 1 TO 3
          l_lError = .F.
          TRY
               DELETE FILE (lp_cFileName)
          CATCH
               l_lError = .T.
          ENDTRY
          IF NOT l_lError
               EXIT
          ELSE
               sleep(100)
          ENDIF
     ENDFOR
     IF NOT FILE(lp_cFileName)
          this.Logit("EXT|    file " + lp_cFileName + " deleted.")
     ELSE
          this.Logit("EXT|    file " + lp_cFileName + " NOT deleted!")
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE GetSlipText
RETURN this.ooutfile.cPrintText
ENDPROC
*
PROCEDURE GetRealPcName
LOCAL ctEmp, npOs
ctEmp = ALLTRIM(SYS(0))
npOs = AT('#', ctEmp)
DO CASE
     CASE ctEmp='1' .OR. ctEmp='#'
           this.cwinpcreal = "STAND_ALONE"
     CASE npOs>0
           this.cwinpcreal = ALLTRIM(SUBSTR(ctEmp, 1, npOs-1))
     OTHERWISE
          this.cwinpcreal =  "UNKNOWN"
ENDCASE
ENDPROC
*
PROCEDURE ShowProgress
LPARAMETERS lp_cText, lp_lForce
LOCAL l_cMacro
IF NOT lp_lForce
     IF EMPTY(this.cprogressevent) OR NOT this.lShowProgress
          RETURN .T.
     ENDIF
ENDIF
l_cMacro = this.cprogressevent + "([" + lp_cText + "])"
TRY
     &l_cMacro
CATCH
ENDTRY

RETURN .T.
ENDPROC
*
PROCEDURE SendToPrinter
LPARAMETERS lp_cText
LOCAL l_cMacro
IF EMPTY(this.cprintevent)
     RETURN .T.
ENDIF
this.ShowProgress(C_KK_PRINTING, .T.)
l_cMacro = this.cprintevent + "(this.GetSlipText())"
TRY
     &l_cMacro
CATCH
ENDTRY
RETURN .T.
ENDPROC
*
PROCEDURE YesNo
LPARAMETERS lp_cText
IF this.lDontDisplayMessageBox
     RETURN .F.
ENDIF
IF MESSAGEBOX(lp_cText,4+32,C_KK_YESNO_DIALOG,30000)=6
     RETURN .T.
ELSE
     RETURN .F.
ENDIF
ENDPROC
*
PROCEDURE readini
#DEFINE c_cmnnBUFFER_SIZE            256
#DEFINE c_cmncNULL                   CHR(0)
#DEFINE c_cmncCR                     CHR(13)

lparameters ;
     tcSection, ;
     tuEntry, ;
     tcDefault, ;
     taEntries, ;
     tcINIFile
local lcBuffer, ;
     lcDefault, ;
     lnSize, ;
     luReturn, ;
     l_lFoundDll, ;
     i
LOCAL ARRAY l_aDlls(1)

IF EMPTY(tcINIFile)
     tcINIFile = this.cinifile
ENDIF
tcINIFile = FULLPATH(tcINIFile)

IF ADLLS(l_aDlls)>0
     FOR i = 1 TO ALEN(l_aDlls,1)
          IF LOWER(ALLTRIM(l_aDlls(i,1))) == "getprivateprofilestring"
               l_lFoundDll = .T.
          ENDIF
          EXIT
     ENDFOR
ENDIF
IF NOT l_lFoundDll
     declare integer GetPrivateProfileString in Win32API string cSection, ;
          string cEntry, string cDefault, string @ cBuffer, integer nBufferSize, ;
          string cINIFile
ENDIF

lcBuffer  = replicate(c_cmncNULL, c_cmnnBUFFER_SIZE)
lcDefault = iif(vartype(tcDefault) <> 'C', '', tcDefault)
lnSize    = GetPrivateProfileString(tcSection, tuEntry, lcDefault, @lcBuffer, ;
     c_cmnnBUFFER_SIZE, tcINIFile)
lcBuffer  = left(lcBuffer, lnSize)
luReturn  = lcBuffer
do case
     case vartype(tuEntry) = 'C'
     case lnSize = 0
          luReturn = 0
     otherwise
          luReturn = alines(taEntries, lcBuffer, .T., c_cmncNULL, c_cmncCR)
endcase
return luReturn
ENDPROC
*
PROCEDURE LogIt
LPARAMETERS lp_cText, lp_lAddEmptyLines, lp_cPrefix, lp_cRemoveSensitiveInfo
LOCAL l_cFile2, l_nLimit
IF NOT EMPTY(lp_cText)
     IF lp_cRemoveSensitiveInfo
          lp_cText = STRTRAN(lp_cText, STREXTRACT(lp_cText, "Spur1:", CHR(13)), "******")
          lp_cText = STRTRAN(lp_cText, STREXTRACT(lp_cText, "Spur2:", CHR(13)), "******")
          lp_cText = STRTRAN(lp_cText, STREXTRACT(lp_cText, "Spur3:", CHR(13)), "******")
          lp_cText = STRTRAN(lp_cText, STREXTRACT(lp_cText, "PAN:", CHR(13)), "******")
          lp_cText = STRTRAN(lp_cText, STREXTRACT(lp_cText, "Verfalldatum:", CHR(13)), "******")
          lp_cText = STRTRAN(lp_cText, STREXTRACT(lp_cText, "MOPS:", CHR(13)), "******")
     ENDIF
     IF lp_lAddEmptyLines
          lp_cText = lp_cPrefix + CHR(13)+CHR(10) + ;
                    REPLICATE("-",52) + CHR(13)+CHR(10) + ;
                    lp_cText + CHR(13)+CHR(10) + ;
                    REPLICATE("-",52) + CHR(13)+CHR(10)
     ENDIF
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
          STRTOFILE(TRANSFORM(DATETIME())+"|"+this.cwinpcreal+"|"+lp_cText+CHR(13)+CHR(10), this.cLogFile, 1)
     CATCH
     ENDTRY

ENDIF
RETURN .T.
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS celpayinfile AS Custom

cInText = ""

cFunktion = ""           && Funktion: (Funktionsnummer der Funktion, die ausgeführt werden soll)
cZahlart = ""            && Zahlart: sm, gc, kk
cBetrag = ""             && Betrag:  (Betrag in kleinster Einheit)
cValuta = "2"            && Valuta:  (Kennzeichen für die Währung, 1 oder 2)
cBeleg = ""              && Beleg:  (Belegnummer 4 Stellen, nur bei Stornos)
cSpur1 = ""              && Spur1:  (Spurdaten der Spur 1 einer Magnetkarte; entfällt, wenn Kartendaten über ein PINPad gelesen werden)
cSpur2 = ""              && Spur2:  (Spurdaten der Spur 2 einer Magnetkarte; entfällt, wenn Kartendaten über ein PINPad gelesen werden)
cSpur3 = ""              && Spur3:  (Spurdaten der Spur 3 einer Magnetkarte; entfällt, wenn Kartendaten über ein PINPad gelesen werden)
cPAN = ""                && PAN:  (PAN einer Karte, nur bei Kreditkarte manuell)
cVerfalldatum = ""       && Verfalldatum: (Das Verfalldatum in der Form YYMM, nur bei Kreditkarte manuell)
cMOPS = ""               && MOPS:  (Mailorder Prüfsumme, bei Mailorder)
cAID = ""                && AID:  (AID wird bei Reservierungserweiterungen benötigt)
cTraceNr = ""            && Trace-Nr: (Die Tracenummer wird bei Reservierungserweiterungen benötigt)
cZGBuchen = ""           && ZGBuchen: (Betrag wird trotz Erreichen des Limits der Zahlungsgarantie gebucht)
cVNr = ""                && VNr:  (Dieser Parameter ist optional und wird von elPAY payment lediglich im Outfile wieder mit ausgegeben.)
cFREI1 = ""              && FREI1:  (Dieser Parameter ist optional und für einen Text gedacht, der sowohl auf den Belegen erscheint, als auch in die Journaldatei geschrieben wird.)
cFREI2 = ""              && FREI2:  (Dieser Parameter ist optional und für einen Text gedacht, der sowohl auf den Belegen erscheint, als auch in die Journaldatei geschrieben wird.)
cFREI3 = ""              && FREI3:  (Dieser Parameter ist optional und für einen Text gedacht, der sowohl auf den Belegen erscheint, als auch in die Journaldatei geschrieben wird.)
cDruckbreite = ""        && Druckbreite: (maximale Anzahl der Zeichen pro Druckzeile (Minimum sind 30 Zeichen, Maximum 150 Zeichen))
cSoftwarename = ""       && Softwarename: (der Name Ihrer Software die das Infile erzeugt)
cSoftwareversion = ""    && Softwareversion: (die Versionsnummer Ihrer Software die das Infile erzeugt)
cKostenstelle = ""       && Kostenstelle (Maximum 10 Zeichen, Buchstaben und Zahlen, keine Sonderzeichen oder Umlaute)
cRechnungsNr = ""        && RechnungsNr (Maximum 15 Zeichen, Buchstaben und Zahlen, keine Sonderzeichen oder Umlaute)
cVerwendungszweck = ""   && Verwendungszweck (Maximum 27 Zeichen, Buchstaben und Zahlen, keine Sonderzeichen oder Umlaute)
cZahlungswunsch = ""     && Zahlungswunsch: ELV (Es wird eine ELV Zahlung gewünscht), ECC (Es wird eine ec-cash Zahlung gewünscht)
*
PROCEDURE CreateText
this.cInText = ""
this.cInText = this.cInText + IIF(EMPTY(this.cFunktion),"","Funktion:"+this.cFunktion+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cZahlart),"","Zahlart:"+this.cZahlart+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cBetrag),"","Betrag:"+this.cBetrag+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cBetrag),"","Valuta:"+this.cValuta+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cBeleg),"","Beleg:"+this.cBeleg+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cPAN),"","PAN:"+this.cPAN+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cVerfalldatum),"","Verfalldatum:"+this.cVerfalldatum+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cMOPS),"","MOPS:"+this.cMOPS+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cSpur1),"","Spur1:"+this.cSpur1+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cSpur2),"","Spur2:"+this.cSpur2+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cSpur3),"","Spur3:"+this.cSpur3+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cDruckbreite),"","Druckbreite:"+this.cDruckbreite+CHR(13)+CHR(10))
this.cInText = this.cInText + IIF(EMPTY(this.cZahlungswunsch),"","Zahlungswunsch:"+this.cZahlungswunsch+CHR(13)+CHR(10))

TEXT TO this.cInText ADDITIVE TEXTMERGE NOSHOW
Softwarename:<<this.cSoftwareName>>
Softwareversion:<<this.cSoftwareVersion>>
ENDTEXT

RETURN .T.
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS celpayoutfile AS Custom

oDruckzeile = .NULL.      && DruckzeileX :  (Inhalt der Druckzeile X für den Beleg, X ist eine Zahl)
cOutText = ""
cPrintText = ""

cFehlercode = ""         && Fehlercode:  (Ergebnis des Vorganges 0000 = Erfolgreich)
cFehlertext = ""         && Fehlertext:  (Im Fehlerfall steht hier der entsprechende Fehlertext, bei Fehlercode 3085 steht hier der Antworttext der KKO)
cTerminalID = ""         && Terminal-ID:  (muss zwingend, so wie sie hier zurückgegeben wird, gedruckt werden)
cAID = ""                && AID:   (Autorisierungs-Nr, bei POZ muss diese als Referenznummer ausgedruckt werden)
cAutorMerkmal = ""       && Autor-Merkmal:  (Autorisierungsmerkmal – muss bei POZ als Referenzparameter ausgedruckt werden)
cPAN = ""                && PAN:   (Die Karten-Nr. der Kreditkarte. Auf den Belegen das Feld Kartennummer.)
cOnline = ""             && Online:NEIN  (Kennzeichen, ob der Vorgang online oder offline war)
cTraceNr = ""            && Trace-Nr:  (Die Tracenummer des Vorganges. Auf den Belegen das Feld POS-Nr.)
cBelegNr = ""            && Beleg-Nr:  (Die Belegnummer der Buchung)
cVerfalldatum = ""       && Verfalldatum:  (Verfalldatum der Magnetkarte YYMM)
cUhrzeit = ""            && Uhrzeit:   (Uhrzeit des Vorganges HHMMSS)
cDatum = ""              && Datum:   (Datum des Vorganges TTMMYYYY)
cKontoNr = ""            && Konto-Nr:  (Kontonummer, nur bei ec -Vorgängen)
cBLZ = ""                && BLZ:   (Bankleitzahl, nur bei ec-Vorgängen)
cBetrag = ""             && Betrag:   (Der Betrag in kleinster Einheit)
cValuta = ""             && Valuta:   (Die Währung)
cKartenart = ""          && Kartenart:  (Kennzeichen der Kartenart)
cFunktion = ""           && Funktion:  (Ausgeführte Funktion)
cKartenfolgeNr = ""      && Kartenfolge-Nr:  (Die Kartenfolge-Nr. der ec-Karte. Auf den Belegen das Feld Karte.)
cVUNr = ""               && VU-Nr:   (Vertragsunternehmens-Nr der einzelnen KKO´s)
cTraceNrStorno = ""      && Trace-NrStorno:  (Transaktions-Nr. bei Stornos. Auf den Belegen das Feld Storno POS-Nr.)
cKKOText = ""            && KKOText:  (Text der KKO, wenn vorhanden muss er auf den Beleg gedruckt werden)
cSumme0 = ""             && Summe 0:  (Gesamtsumme währungslos in kleinster Einheit)
cSumme1 = ""             && Summe 1:  (Gesamtsumme DM in kleinster Einheit)
cSumme2 = ""             && Summe 2:  (Gesamtsumme Euro in kleinster Einheit)
cBon0 = ""               && Bon   0:   (Anzahl Bons währungslos)
cBon1 = ""               && Bon   1:   (Anzahl Bons DM)
cBon2 = ""               && Bon   2:   (Anzahl Bons Euro)
cLEKS = ""               && LEKS:   (Datum und Uhrzeit des letzten erfolgreichen Kassenschnittes - nur bei Diagnose)
cRestbetrag = ""         && Restbetrag:  (Betrag in kleinster Einheit bis zum Erreichen des Limits der Zahlungsgarantie)
cVNr = ""                && VNr: (Parameter den Ihre Software im Infile mit übergeben kann. Z.B. für softwareinterne Identifizierung der Transaktion. -> wird nicht in den Druckzeilen ausgegeben!)
cDefec = ""              && Def-ec: hier steht die vom Netzbetreiber als Standard eingestellte Zahlungstechnologie (mögliche Werte: ELV; ECC)
cELVvon = ""             && ELV-von: Enthält den Mindestbetrag in Cent, ab wann eine ELV Zahlung gemacht werden darf
cELVbis = ""             && ELV-bis: Enthält den Maximalbetrag in Cent bis zu dem eine ELV Zahlung gemacht werden darf 
cHost = ""               && Host: Beim Netzbetreiber AFC steht hier das verwendete Hostsystem drin. Mögliche Werte: „EVA“ oder „OPN“. 
cTastatureingabe = ""    && Tastatureingabe: (Hier steht die Eingabe vom PINPad (Funktion:79) , max. 15 Zahlen) 
cZahlart = ""            && Zahlart: sm, gc, kk
*
PROCEDURE ProcessFile
LOCAL l_nLines, i, l_cLine, l_cParam, l_oCol AS Collection, l_cPrintLine, l_cCmd, l_lSuccess
LOCAL ARRAY l_aText(1)
l_oCol = CREATEOBJECT("Collection")
this.oDruckzeile = .NULL.
this.oDruckzeile = l_oCol

l_nLines = ALINES(l_aText,this.cOutText)

FOR i = 1 TO l_nLines
     l_cLine = l_aText(i)
     l_cCmd = LOWER(GETWORDNUM(l_cLine,1,":"))
     l_cParam = ALLTRIM(GETWORDNUM(l_cLine,2,":"))
     DO CASE
          CASE l_cCmd = "fehlercode"
               this.cFehlercode = l_cParam
               l_lSuccess = IIF(l_cParam="0000",.T.,.F.)
          CASE l_cCmd = "fehlertext"
               this.cFehlertext = l_cParam
          CASE l_cCmd = "terminal-id"
               this.cTerminalID = l_cParam
          CASE l_cCmd = "aid"
               this.cAID = l_cParam
          CASE l_cCmd = "autor-merkmal"
               this.cAutorMerkmal = l_cParam
          CASE l_cCmd = "pan"
               this.cPAN = l_cParam
          CASE l_cCmd = "online"
               this.cOnline = l_cParam
          CASE l_cCmd = "trace-nr"
               this.cTraceNr = l_cParam
          CASE l_cCmd = "beleg-nr"
               this.cBelegNr = l_cParam
          CASE l_cCmd = "verfalldatum"
               this.cVerfalldatum = l_cParam
          CASE l_cCmd = "uhrzeit"
               this.cUhrzeit = l_cParam
          CASE l_cCmd = "datum"
               this.cDatum = l_cParam
          CASE l_cCmd = "konto-nr"
               this.cKontoNr = l_cParam
          CASE l_cCmd = "blz"
               this.cBLZ= l_cParam
          CASE l_cCmd = "betrag"
               this.cBetrag = l_cParam
          CASE l_cCmd = "valuta"
               this.cValuta = l_cParam
          CASE l_cCmd = "kartenart"
               this.cKartenart = l_cParam
          CASE l_cCmd = "funktion"
               this.cFunktion = l_cParam
          CASE l_cCmd = "kartenfolge-nr"
               this.cKartenfolgeNr = l_cParam
          CASE l_cCmd = "vu-nr"
               this.cVUNr = l_cParam
          CASE l_cCmd = "trace-nrstorno"
               this.cTraceNrStorno = l_cParam
          CASE l_cCmd = "kkotext"
               this.cKKOText = l_cParam
          CASE l_cCmd = "summe 0"
               this.cSumme0 = l_cParam
          CASE l_cCmd = "summe 1"
               this.cSumme1 = l_cParam
          CASE l_cCmd = "summe 2"
               this.cSumme2 = l_cParam
          CASE l_cCmd = "Bon   0"
               this.cBon0 = l_cParam
          CASE l_cCmd = "Bon   1"
               this.cBon1 = l_cParam
          CASE l_cCmd = "Bon   2"
               this.cBon2 = l_cParam
          CASE l_cCmd = "leks"
               this.cLEKS = l_cParam
          CASE l_cCmd = "restbetrag"
               this.cRestbetrag = l_cParam
          CASE l_cCmd = "vnr"
               this.cVNr = l_cParam
          CASE l_cCmd = "def-ec"
               this.cDefec = l_cParam
          CASE l_cCmd = "elv-von"
               this.cELVvon = l_cParam
          CASE l_cCmd = "elv-bis"
               this.cELVbis = l_cParam
          CASE l_cCmd = "host"
               this.cHost = l_cParam
          CASE l_cCmd = "tastatureingabe"
               this.cTastatureingabe= l_cParam
          CASE l_cCmd = "zahlart"
               this.cZahlart = l_cParam
          CASE LEFT(l_cCmd,10) = "druckzeile"
               l_cPrintLineNo = ALLTRIM(SUBSTR(l_cCmd,11))
               l_oCol.Add(l_cParam,l_cPrintLineNo)
     ENDCASE
ENDFOR

this.cPrintText = ""
FOR EACH l_cPrintLine IN l_oCol
     l_cPrintMark = STREXTRACT(l_cPrintLine,"",";")
     IF NOT l_cPrintMark == "S"
          l_cPrintLine = STRTRAN(l_cPrintLine,l_cPrintMark+";","")
     ENDIF
     this.cPrintText = this.cPrintText + l_cPrintLine + CHR(10)
ENDFOR
l_oCol = .NULL.
RETURN l_lSuccess
ENDPROC
*
ENDDEFINE
