*PROCEDURE exjmavs

* Export guest to exjmavs

#DEFINE c_cExAVSFXPVersion          "1.19"
#DEFINE c_cExAVSFXPName             "exjmavs"
#DEFINE c_cExAVSLogFile             _screen.oGlobal.cHotelDir + "exjmavs.log"
#DEFINE c_cExAVSXMLLogFile          _screen.oGlobal.cHotelDir + "exjmavsxml.log"
#DEFINE c_cExAVSServerLink          "https://meldeschein.avs.de/meldeschein-ws-test/JMeldescheinWebservices"
#DEFINE c_cExAVSLTResNotFound       "Keine Reservierung gefunden!" + CHR(10) + CHR(13) + ; 
                                    "Diese Funktion soll �ber Reservierung Maske, Reservierungsliste oder Zimmerplan geruffen werden!"

* Paramaters:
* lp_cVersion - When filled with "VERSION" string, version of fxp module is returned
* lp_lFromReservat - Called for direct print over reservat mask, weekform or res browse
* lp_lForcePrint - Always print meldeschien
* lp_lForceSingle - Force possibility to send one group reservation as single reservation

LPARAMETERS lp_cVersion, lp_lFromReservat, lp_lForcePrint, lp_lForWholeGroup, lp_lForceSingle
LOCAL l_oSession, l_nReserId, l_cWinName
l_cWinName = ""
l_nReserId = 0

IF NOT EMPTY(lp_cVersion) AND VARTYPE(lp_cVersion) = "C" AND lp_cVersion = "VERSION"
     lp_cVersion = c_cExAVSFXPVersion
     RETURN .T.
ENDIF

IF lp_lFromReservat
     _screen.oGlobal.oBill.nReserId = 0
     l_cWinName = wname()
     IF INLIST(l_cWinName, "WRESERVAT","WRSBROWSE") AND _screen.oGlobal.oBill.nReserId > 1
          l_nReserId = _screen.oGlobal.oBill.nReserId
     ENDIF
     _screen.oGlobal.oBill.nReserId = 0
     IF l_nReserId = 0
          alert(c_cExAVSLTResNotFound)
          RETURN .T.
     ENDIF
ENDIF

l_oSession = CREATEOBJECT("exexjmavssession")
l_oSession.cVersion = c_cExAVSFXPVersion
l_oSession.cFXPName = c_cExAVSFXPName
l_oSession.cLogFile = c_cExAVSLogFile
l_oSession.cXMLLogFile = c_cExAVSXMLLogFile
l_oSession.cServerLink = c_cExAVSServerLink
l_oSession.lForcePrint = lp_lForcePrint
l_oSession.Runit(l_nReserId, lp_lForWholeGroup, lp_lForceSingle)
l_oSession.Release()
l_oSession = .NULL.

RETURN .T.
ENDPROC
*
PROCEDURE EXJMAVSOpenWindowsExplorer
LPARAMETERS lp_cDir
LOCAL loshell as Shell32.application
IF EMPTY(lp_cDir)
     lp_cDir = FULLPATH(CURDIR())
ENDIF
loshell = CREATEOBJECT('shell.application')
loShell.Explore(lp_cDir)
loShell = null
RETURN .T.
ENDPROC
*
**
***
**
*
DEFINE CLASS exexjmavssession AS Session
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS exexjmavssession OF exjmavs.prg
   LOCAL this.oHttp AS MSXML2.ServerXMLHTTP
#ENDIF
*
* Properties
*
cVersion = ""
cFXPName = ""
cLogFile = ""
cXMLLogFile = ""
cIniFile = ""
cPDFSaveFolder = ""
cFirmaId = ""
cObjektId = ""
lObjektIdFromRoomTable = .F.
userfield_room_objektid = ""
cObjektIdDefault = ""
cFirmaIdDefault = ""
cKurVerwaltungIdDefault = ""
cKurVerwaltungId = ""
nDaysInPast = 0
lShowPDFAfterDownload = .F.
lHistTable = .F.
cuserfield_meldescheinnr  = ""
cuserfield_kategorie_person = ""
cuserfield_meldescheinnr_hist = ""
cuserfield_kategorie_person_hist = ""
cuserfield_kfz = ""
cuserfield_kfz_hist = ""
cuserfield_group = ""
cuserfield_group_hist = ""
cstandardkategorie = ""
lForcePrint = .T.
lUseBuildings = .F.
lSendTotalResAmount = .F.

dFromDate = {}
dHSysDate = {}
cCurCountry = ""
cCurBuildings = ""
cCurRes = ""
cCurHistRes = ""
cCurAnrede = ""
cCurGuests = ""

cXmlRequest = ""
cXmlResponse = ""
cXMLBegleitPerson = ""
cXMLBegleitGruppe = ""
oXMLbucheMeldeschein = .NULL.
oXMLdruckeMeldescheine = .NULL.
oXMLgetKonfigurationsListe = .NULL.
oXMLholeMeldeschein = .NULL.

dBirth = {}
nTitleCode = 0
cLName = ""
cFName = ""
cstreet = ""
czip = ""
ccity = ""
cArrDate = ""
cDepDate = ""
cAnredeId = ""
cKategorieId = ""
cLandId = ""
cKFZ = ""
cMeldeSchein = ""
cAcmdFee = ""

dSBirth = {}
nSTitleCode = 0
cSLName = ""
cSFName = ""
cSstreet = ""
cSzip = ""
cScity = ""
cSAnredeId = ""
cSKategorieId = ""

cfehler = ""
lForWholeGroup = .F.
lForceSingle = .F.

nMeldescheneSent = 0
nReservationsFound = 0
nMeldeschenePrinted = 0

oHttp = .NULL.
chttpcmd = ""
nSys3101 = 0
cServerLink = ""
cusername = ""
cpassword = ""
nreslovetimeout=10
nconnecttimeout=10
nsendtimeout=10
nrecivetimeout=10
nConnectionError = 0
cproxy = ""

*
* Methodes
*
PROCEDURE Init
ini()
openfiledirect(.F.,"reservat")
openfiledirect(.F.,"histres")
openfiledirect(.F.,"hresext")
openfiledirect(.F.,"address")
openfiledirect(.F.,"apartner")
openfiledirect(.F.,"picklist")
openfiledirect(.F.,"roomtype")
openfiledirect(.F.,"post")
openfiledirect(.F.,"histpost")
openfiledirect(.F.,"ressplit")
openfiledirect(.F.,"article")
this.dHSysDate = sysdate()
this.cCurAnrede = SYS(2015)
this.nSys3101 = SYS(3101,65001)
ENDPROC
*
PROCEDURE RunIt
LPARAMETERS lp_nReserId, lp_lForWholeGroup, lp_lForceSingle

this.lForWholeGroup = lp_lForWholeGroup
this.lForceSingle = lp_lForceSingle

this.lUseBuildings = ICASE(this.lObjektIdFromRoomTable,.F.,TYPE("_screen.oGlobal.oParam2.pa_buildin")="L",_screen.oGlobal.oParam2.pa_buildin,.F.)
this.Prepare()
this.ReservationsSend(lp_nReserId)
this.ShowResult()
this.CleanUp()

RETURN .T.
ENDPROC
*
PROCEDURE ShowResult
LOCAL l_cMessage
l_cMessage = this.GetReportMessage()
alert(l_cMessage)
IF this.nMeldeschenePrinted>0
     EXJMAVSOpenWindowsExplorer(this.cPDFSAVEFOLDER)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE GetReportMessage
LOCAL l_cMessage
l_cMessage = this.GetLangText("FINISHED")
DO CASE
     CASE this.nConnectionError = 1
          l_cMessage = l_cMessage + CHR(10)+CHR(13) + this.GetLangText("CONNECTIONERROR")
     CASE this.nConnectionError = 2
          l_cMessage = l_cMessage + CHR(10)+CHR(13) + this.GetLangText("CONNECTIONERROR_PRINTING")
     CASE this.nConnectionError = 3
          l_cMessage = l_cMessage + CHR(10)+CHR(13) + this.GetLangText("CONNECTIONERROR_INSTALL_HTTPXML")
ENDCASE

l_cMessage = l_cMessage + ;
          CHR(10)+CHR(13) + CHR(10)+CHR(13) + ;
          this.GetLangText("RESERVATIONSFOUND") + TRANSFORM(this.nReservationsFound) + ;
          CHR(10)+CHR(13) + ;
          this.GetLangText("MELDESCHEINSENT") + TRANSFORM(this.nMeldescheneSent) + ;
          CHR(10)+CHR(13) + ;
          this.GetLangText("MELDESCHEINPRINTED") + TRANSFORM(this.nMeldeschenePrinted)

IF NOT EMPTY(this.cfehler)
     l_cMessage = l_cMessage + ;
          CHR(10)+CHR(13) + CHR(10)+CHR(13) + ;
          this.cfehler
ENDIF
RETURN l_cMessage
ENDPROC
*
PROCEDURE GetLangText

* Lang texts here.

LPARAMETERS lp_cLabel AS String
LOCAL l_cText AS String
DO CASE
     CASE lp_cLabel == "GETRESERVAT"
          l_cText = "Reservierungen selektieren..."
     CASE lp_cLabel == "MELDPREPARE"
          l_cText = "�berpr�fe Reservierung ..."
     CASE lp_cLabel == "MELDSEND"
          l_cText = "Sende neues Meldeschein f�r Reservierung ..."
     CASE lp_cLabel == "MELDUPDATE"
          l_cText = "Update Meldeschein f�r Reservierung ..."
     CASE lp_cLabel == "NOTHINGTOEXPORT"
          l_cText = "Keine Reservierungen gefunden!"
     CASE lp_cLabel == "FINISHED"
          l_cText = "Fertig."
     CASE lp_cLabel == "YES"
          l_cText = "Ja"
     CASE lp_cLabel == "NO"
          l_cText = "Nein"
     CASE lp_cLabel == "CONNECTIONERROR"
          l_cText = "Verbindung mit AVS Server war nicht erfolgreich. Nicht alle Meldescheine sind gesendet."
     CASE lp_cLabel == "SAVEMELDESCHEINE"
          l_cText = "Meldescheine als PDF unterladen..."
     CASE lp_cLabel == "RESERVATIONSFOUND"
          l_cText = "Reservierungen �berpr�ft:"
     CASE lp_cLabel == "MELDESCHEINSENT"
          l_cText = "Meldescheine gesendet an AVS server:"
     CASE lp_cLabel == "MELDESCHEINPRINTED"
          l_cText = "Meldescheine als PDF von AVS server untergeladen bzw. gedruckt:"
     CASE lp_cLabel == "CONNECTIONERROR_PRINTING"
          l_cText = "Verbindung mit AVS Server war nicht erfolgreich. Nicht alle Meldescheine sind als PDF untergeladen."
     CASE lp_cLabel == "CONNECTIONERROR_INSTALL_HTTPXML"
          l_cText = "Verbindung mit AVS Server war nicht erfolgreich. msxml3.dll Datei soll an System installiert werden."
     CASE lp_cLabel == "SEND_FOR_WHOLE_GROUP"
          l_cText = "Wollen Sie �ber diesen Meldeschein alle Gruppenmitglieder senden?"
     CASE lp_cLabel == "SEND_FOR_WHOLE_GROUP_FOR_ONE_BUILDING"
          l_cText = "Wollen Sie �ber diesen Meldeschein alle Gruppenmitglieder f�r Geb�ude %s1 senden?"
     CASE lp_cLabel == "NOT_ALLOWED_FOR_WHOLE_GROUP"
          l_cText = "@2V O R S I C H T !!!"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"Es ist nicht erlaubt �ber diese Reservierung Meldeschein f�r alle Gruppenmitglieder zu senden, weil eine andere Reservierung ist schon als Hauptreservierung f�r diese Gruppe benutzt. Weitermachen?"
OTHERWISE
     l_cText = PROPER(lp_cLabel)
ENDCASE
RETURN l_cText
ENDPROC
*
PROCEDURE Prepare
LOCAL l_nExtCountryCode, l_cTitleHerrCodes, l_cTitleFrauCodes, i, l_nId, l_cSet, l_nKategoriesFound, ;
          l_okonfigliste, l_okonfigdatensatz, l_oXML AS MSXML2.DomDocument, l_oOneNode, l_cId, l_cDescript, ;
          l_cCode, l_cServer, l_cExtObjektId, l_cData, l_cfirmid, l_ckurid

LOCAL ARRAY l_aKategories(1)
this.cfehler = ""
this.nConnectionError = 0

STRTOFILE(CHR(10)+CHR(13)+REPLICATE("-",50)+CHR(10)+CHR(13),this.cLogFile,1)

this.LogIt("Started|" + this.cFXPName + " Version:" + TRANSFORM(this.cVersion) + "|Hotel date:" + TRANSFORM(this.dHSysDate) + "|PC:" + winpc() + "|Buildings:" + TRANSFORM(this.lUseBuildings))

this.cIniFile = _screen.oGlobal.cHotelDir + FORCEEXT(this.cFXPName,"ini")
this.cIniFile = FULLPATH(this.cIniFile)

IF NOT FILE(this.cIniFile)
     this.LogIt("ini file not found.")
     STRTOFILE("", this.cIniFile, 0)
ENDIF

* Get settings from ini file

l_cSet = "SETTINGS|"

this.cFirmaIdDefault = readini(this.cIniFile, "System","firmaid", "0")
l_cSet = l_cSet + "FirmaId:" + TRANSFORM(this.cFirmaId) + "|"
this.cObjektIdDefault = readini(this.cIniFile, "System","objektid", "0")
l_cSet = l_cSet + "ObjektId:" + TRANSFORM(this.cObjektIdDefault) + "|"

this.lObjektIdFromRoomTable = IIF(LOWER(readini(this.cIniFile, "System","objektidfromroomtable", "no"))=="yes",.T.,.F.)
l_cSet = l_cSet + "ObjektIdFromRoomTable:" + TRANSFORM(this.lObjektIdFromRoomTable) + "|"

this.userfield_room_objektid = readini(this.cIniFile, "System","userfield_room_objektid", "")
l_cSet = l_cSet + "userfield_room_objektid:" + TRANSFORM(this.userfield_room_objektid) + "|"

this.cKurVerwaltungIdDefault = readini(this.cIniFile, "System","kurverwaltungid", "0")
l_cSet = l_cSet + "KurVerwaltungId:" + TRANSFORM(this.cKurVerwaltungId) + "|"

this.nDaysInPast = INT(VAL(readini(this.cIniFile, "System","checkreservationfrom", "30")))
l_cSet = l_cSet + "checkreservationfrom:" + TRANSFORM(this.nDaysInPast) + "|"
this.lSendTotalResAmount = INLIST(PROPER(readini(this.cIniFile, "System","SendTotalResAmount", "NO")), "Yes", "Ja")
l_cSet = l_cSet + "sendtotalresamount:" + this.GetLangText(IIF(this.lSendTotalResAmount,"YES","NO")) + "|"

this.cPDFSaveFolder = FULLPATH(_screen.oGlobal.cHotelDir + readini(this.cIniFile, "System","pdfsavefolder", "meldescheinepdf"))
l_cSet = l_cSet + "pdfsavefolder:" + TRANSFORM(this.cPDFSaveFolder) + "|"

IF NOT DIRECTORY(this.cPDFSaveFolder)
     MKDIR (this.cPDFSaveFolder)
ENDIF

this.cPDFSaveFolder = ADDBS(this.cPDFSaveFolder)

this.LogIt(l_cSet)
l_cSet = "SETTINGS|"

this.cuserfield_meldescheinnr = readini(this.cIniFile, "System","userfield_meldescheinnr", "rs_usrres0")
l_cSet = l_cSet + "userfield_meldescheinnr:" + TRANSFORM(this.cuserfield_meldescheinnr) + "|"

this.cuserfield_kategorie_person = readini(this.cIniFile, "System","userfield_kategorie_person", "rs_usrres1")
l_cSet = l_cSet + "userfield_kategorie_person:" + TRANSFORM(this.cuserfield_kategorie_person) + "|"

this.cuserfield_kfz = readini(this.cIniFile, "System","userfield_kfz", "")
l_cSet = l_cSet + "userfield_kfz:" + TRANSFORM(this.cuserfield_kfz) + "|"

this.cuserfield_group = readini(this.cIniFile, "System","userfield_group", "")
l_cSet = l_cSet + "userfield_group:" + TRANSFORM(this.cuserfield_group ) + "|"

this.cstandardkategorie = readini(this.cIniFile, "System","standardkategorie", "")
l_cSet = l_cSet + "standardkategorie:" + TRANSFORM(this.cuserfield_group ) + "|"


this.LogIt(l_cSet)
l_cSet = "SETTINGS|"

this.nreslovetimeout = INT(VAL(readini(this.cIniFile, "Http","reslovetimeout", "30")))
l_cSet = l_cSet + "reslovetimeout:" + TRANSFORM(this.nreslovetimeout) + "|"
this.nconnecttimeout = INT(VAL(readini(this.cIniFile, "Http","connecttimeout", "60")))
l_cSet = l_cSet + "connecttimeout:" + TRANSFORM(this.nconnecttimeout) + "|"
this.nsendtimeout = INT(VAL(readini(this.cIniFile, "Http","sendtimeout", "120")))
l_cSet = l_cSet + "sendtimeout:" + TRANSFORM(this.nsendtimeout) + "|"
this.nrecivetimeout = INT(VAL(readini(this.cIniFile, "Http","recivetimeout", "120")))
l_cSet = l_cSet + "recivetimeout:" + TRANSFORM(this.nrecivetimeout) + "|"

l_cServer = readini(this.cIniFile, "Http","server", "")
IF NOT EMPTY(l_cServer)
     this.cServerLink = l_cServer
ENDIF
this.cusername = readini(this.cIniFile, "Http","username", "")
this.cpassword = readini(this.cIniFile, "Http","password", "")
this.cproxy = readini(this.cIniFile, "Http","proxy", "")

this.LogIt(l_cSet)

this.cuserfield_meldescheinnr_hist = STRTRAN(this.cuserfield_meldescheinnr,"rs_", "hr_")
this.cuserfield_kategorie_person_hist = STRTRAN(this.cuserfield_kategorie_person,"rs_", "hr_")
this.cuserfield_kfz_hist = STRTRAN(this.cuserfield_kfz,"rs_", "hr_")
this.cuserfield_group_hist = STRTRAN(this.cuserfield_group,"rs_", "hr_")

this.dFromDate = this.dHSysDate - this.nDaysInPast

* get countries
this.cCurCountry = sqlcursor("SELECT pl_charcod, CAST(0 AS Numeric(3)) AS ext FROM picklist WHERE pl_label = " + sqlcnv("COUNTRY",.T.),,,,,,,.T.)
SCAN ALL
     l_nExtCountryCode = INT(VAL(readini(this.cIniFile, "Laenderliste", ALLTRIM(pl_charcod), "1"))) && Default is 1 - Deutschland
     REPLACE ext WITH l_nExtCountryCode
ENDSCAN

* get buildings
IF this.lUseBuildings
     this.cCurBuildings = sqlcursor("SELECT bu_buildng, CAST('' AS Char(8)) AS objektid, SPACE(10) AS firmaid, SPACE(10) AS kurid FROM building WHERE 1=1",,,,,,,.T.)
     SCAN ALL
          l_cData = ALLTRIM(readini(this.cIniFile, "Objektliste", ALLTRIM(bu_buildng), this.cObjektIdDefault))
          IF ";" $ l_cData
               l_cExtObjektId = GETWORDNUM(l_cData,1,";")
               l_cfirmid = GETWORDNUM(l_cData,2,";")
               l_ckurid = GETWORDNUM(l_cData,3,";")
          ELSE
               l_cExtObjektId = l_cData
               l_cfirmid = ""
               l_ckurid = ""
          ENDIF
          
          REPLACE objektid WITH l_cExtObjektId, ;
                  firmaid WITH l_cfirmid, ;
                  kurid WITH l_ckurid
     ENDSCAN
ENDIF

* Get anrede
CREATE CURSOR (this.cCurAnrede) (c_title c(5), c_id i)

l_cTitleHerrCodes = readini(this.cIniFile, "Anrede","Herr", "0")
FOR i = 1 TO GETWORDCOUNT(l_cTitleHerrCodes,",")
     l_nId = 0
     TRY
          l_nId = INT(VAL(ALLTRIM(GETWORDNUM(l_cTitleHerrCodes,i,","))))
     CATCH
     ENDTRY
     IF NOT EMPTY(l_nId)
          INSERT INTO (this.cCurAnrede) VALUES ("HERR",l_nId)
     ENDIF
ENDFOR

l_cTitleFrauCodes = readini(this.cIniFile, "Anrede","Frau", "0")
FOR i = 1 TO GETWORDCOUNT(l_cTitleFrauCodes,",")
     l_nId = 0
     TRY
          l_nId = INT(VAL(ALLTRIM(GETWORDNUM(l_cTitleFrauCodes,i,","))))
     CATCH
     ENDTRY
     IF NOT EMPTY(l_nId)
          INSERT INTO (this.cCurAnrede) VALUES ("FRAU",l_nId)
     ENDIF
ENDFOR

* Get kategorie

CREATE CURSOR curkat (c_code c(5), c_id i)

l_nKategoriesFound = 0
l_nKategoriesFound = readini(this.cIniFile, "Kategorien",0,,@l_aKategories)
IF l_nKategoriesFound > 0
     * Get categories
     FOR i = 1 TO l_nKategoriesFound
          l_nId = INT(VAL(readini(this.cIniFile, "Kategorien",l_aKategories(i),"0")))
          IF l_nId > 0
               INSERT INTO curkat VALUES (l_aKategories(i),l_nId)
          ENDIF
     ENDFOR
ELSE
     this.LogIt("In Kategorien section no kategories found. Try to receive kategories from AVS server.")
     IF this.getKonfigurationsListe()
          l_oXML = this.oXMLgetKonfigurationsListe
          l_okonfigliste = l_oXML.selectNodes("/S:Envelope/S:Body/ns0:configuration-lists/konfigliste/konfigdatensatz")
          l_okonfigdatensatz = .NULL.
          FOR EACH l_okonfigdatensatz IN l_okonfigliste
               l_oOneNode = l_okonfigdatensatz.selectSingleNode("id")
               l_cId = ALLTRIM(l_oOneNode.Text)
               l_oOneNode = l_okonfigdatensatz.selectSingleNode("text1")
               l_cDescript = ALLTRIM(l_oOneNode.Text)
               l_oOneNode = l_okonfigdatensatz.selectSingleNode("text2")
               l_cCode = UPPER(ALLTRIM(l_oOneNode.Text))

               writeini(this.cIniFile, "Kategorien", l_cCode, l_cId)
               INSERT INTO curkat VALUES (l_cCode,INT(VAL(l_cId)))
               this.LogIt("Added Kategorie: "+l_cDescript+"|"+l_cCode+"|"+l_cId)
          ENDFOR
     ELSE
          this.LogIt("Failed to receive kategories from AVS server.")
     ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE ReservationsSend

* Get all reservations, which should be sent to server, then receive and save meldeschein as PDF, and mark it as complete,
* with storing meldeblatnr in reservat table.
* When connection error occoured, abort all.

LPARAMETERS lp_nReserId
LOCAL l_cCurRes, l_cResWhere, l_lPrint, l_Continue, l_lCancel, l_lForWholeGroup
l_Continue = .T.

this.Progress(this.GetLangText("GETRESERVAT"))

* Get all needed reservations from reservat table. From histres table get only reservations, not found in reservat table.

IF EMPTY(lp_nReserId)
     this.LogIt("Start SQL SELECT for reservations.")
     TEXT TO l_cResWhere TEXTMERGE NOSHOW PRETEXT 1+2+4+8
          ((rs_arrdate >= <<sqlcnv(this.dFromDate,.T.)>> AND rs_status = 'IN' AND rs_in = '1') OR 
          (rs_depdate >= <<sqlcnv(this.dFromDate,.T.)>> AND rs_status = 'OUT' AND rs_out = '1')) AND 
          (rt_group = 1 OR rt_group = 4) AND 
          (rs_depdate - rs_arrdate) > 0 
     ENDTEXT
ELSE
     * Print only 1 reservation
     this.LogIt("Start SQL SELECT for reservation with ReserId "+TRANSFORM(lp_nReserId)+".")
     TEXT TO l_cResWhere TEXTMERGE NOSHOW PRETEXT 1+2+4+8
          (rs_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND 
          (rt_group = 1 OR rt_group = 4) AND 
          (rs_depdate - rs_arrdate) > 0) 
     ENDTEXT
     
     * When only one reservation, then show PDF after download.
     this.lSHOWPDFAFTERDOWNLOAD = .T.
ENDIF

l_cSql = this.GetReservationSql(l_cResWhere)
this.cCurRes = sqlcursor(l_cSql,,,,,,,.T.)

this.Progress(this.GetLangText("GETRESERVAT") + " 50%")

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 1+2+4+8
SELECT DISTINCT hr_reserid AS c_reserid, hr_rsid AS c_rsid, hr_arrdate AS c_arrdate, hr_depdate AS c_depdate, hr_adults AS c_adults, 
     hr_childs AS c_childs, hr_childs2 AS c_childs2, hr_childs3 AS c_childs3, hr_addrid AS c_addrid, h2.rs_custom1 AS c_custom1, 
     hr_compid AS c_compid, hr_apname AS c_apname, <<this.cuserfield_kategorie_person_HIST>> AS c_kper, 
     hr_roomnum AS c_roomnum, hr_lname AS c_lname, <<this.cuserfield_meldescheinnr_hist>> AS c_meldenr, 
     <<IIF(EMPTY(this.cuserfield_kfz_hist),[''],this.cuserfield_kfz_hist)>> AS c_kfz, 
     <<IIF(EMPTY(this.cuserfield_group_hist),[''],this.cuserfield_group_hist)>> AS c_ufgroup, 
     hr_status AS c_status, hr_in AS c_in, hr_codate AS c_codate, 
     hr_groupid AS c_groupid, hr_roomlst AS c_roomlst, 
     rt_buildng, 
     a1.ad_lname, a1.ad_fname, a1.ad_titlcod, a1.ad_birth, a1.ad_street, a1.ad_zip, a1.ad_city, a1.ad_country, 
     ap_lname, ap_fname, ap_titlcod, ap_gebdate, 
     a2.ad_lname AS c_slname, a2.ad_fname AS c_sfname, a2.ad_titlcod AS c_stitlcod, a2.ad_birth AS c_sbirth, a2.ad_street AS c_sstreet, 
     a2.ad_zip AS c_szip, a2.ad_city AS c_scity, a2.ad_country AS c_scountry, 
     r1.rs_reserid 
     FROM histres 
     INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp 
     INNER JOIN address a1 ON hr_addrid = a1.ad_addrid 
     LEFT JOIN apartner ON hr_apid = ap_apid 
     LEFT JOIN reservat r1 ON hr_reserid = r1.rs_reserid 
     LEFT JOIN hresext h1 ON hr_rsid = h1.rs_rsid 
     LEFT JOIN address a2 ON h1.rs_saddrid = a2.ad_addrid 
     WHERE ((hr_arrdate >= <<sqlcnv(this.dFromDate)>> AND hr_status = 'IN' AND hr_in = '1') OR 
     (hr_depdate >= <<sqlcnv(this.dFromDate)>> AND hr_status = 'OUT' AND hr_out = '1')) AND 
     (rt_group = 1 OR rt_group = 4) AND 
     (hr_depdate - hr_arrdate) > 0 AND 
     <<this.cuserfield_meldescheinnr_hist>> = '<<SPACE(35)>>' 
     AND ISNULL(r1.rs_reserid) 
     ORDER BY c_depdate, c_reserid
ENDTEXT
*_cliptext=l_cSql
IF EMPTY(lp_nReserId)
     this.cCurHistRes = sqlcursor(l_cSql,,,,,,,.T.)
ELSE
     * We don't need history reservations cursor, because we are printing only 1 reservation. This is fake cursor.
     this.cCurHistRes = SYS(2015)
     SELECT * FROM (this.cCurRes) WHERE 0=1 INTO CURSOR (this.cCurHistRes)
ENDIF

this.LogIt("Finished SQL SELECT for reservations.")

this.nMeldescheneSent = 0
this.nMeldeschenePrinted = 0
this.nReservationsFound = RECCOUNT(this.cCurRes) + RECCOUNT(this.cCurHistRes)

IF RECCOUNT(this.cCurRes)>0 OR RECCOUNT(this.cCurHistRes)>0
     this.LogIt("Found in reservat " + TRANSFORM(RECCOUNT(this.cCurRes)) + " and in histres " + ;
               TRANSFORM(RECCOUNT(this.cCurHistRes)) + " reservations.")
     this.Progress(this.GetLangText("MELDPREPARE"))

     * From reservat
     IF NOT EMPTY(lp_nReserId)
          l_Continue = this.CheckGroup(@l_lForWholeGroup)
     ENDIF
     IF NOT l_Continue
          this.LogIt("Aborting because group reservierung couldn't be used for all group members. Finished.")
          RETURN .T.
     ENDIF

     IF NOT EMPTY(lp_nReserId) AND NOT l_lForWholeGroup
          l_lCancel = this.ShowGuests()
          IF l_lCancel
               this.LogIt("Aborting because user manualy cancelled from guests form. Finished.")
               RETURN .T.
          ENDIF
     ENDIF

     l_cCurRes = this.cCURRES

     SELECT &l_cCurRes
     this.lHistTable = .F.
     SCAN FOR this.nConnectionError = 0
          l_lPrint = .F.
          this.Progress(this.GetLangText("MELDPREPARE")+" ReserId:"+TRANSFORM(c_reserid)+;
                    " Name:"+ALLTRIM(TRANSFORM(c_lname))+" Zimmer:"+ALLTRIM(get_rm_rmname(c_roomnum)))
          IF EMPTY(c_meldenr)
               IF this.SendMeldeschein()
                    this.ReservationUpdate()
                    this.nMeldescheneSent = this.nMeldescheneSent + 1
                    l_lPrint = .T.
               ENDIF
          ELSE
               * When meldeschein already sent for one reservation, check if changes are found, and when yes, send it again.
               DO CASE
                    CASE (c_status = 'IN' AND c_in = '1') OR (c_status = 'OUT' AND c_codate = this.dhSYSDATE) OR c_status = 'DEF'
                         IF this.UpdateMeldeschein()
                              this.nMeldescheneSent = this.nMeldescheneSent + 1
                              l_lPrint = .T.
                         ENDIF
                    CASE INLIST(c_status,'NS ','CXL')
                         * STORNO
                         IF this.UpdateMeldeschein(.T.)
                              this.nMeldescheneSent = this.nMeldescheneSent + 1
                         ENDIF
               ENDCASE
          ENDIF
          IF l_lPrint OR this.lForcePrint
               this.MeldescheinPrint()
               this.nMeldeschenePrinted = this.nMeldeschenePrinted + 1
          ENDIF
     ENDSCAN

     * From histres
     l_cCurRes = this.cCURHISTRES
     SELECT &l_cCurRes
     this.lHistTable = .T.
     SCAN FOR this.nConnectionError = 0
          l_lPrint = .F.
          this.Progress(this.GetLangText("MELDPREPARE")+" ReserId:"+TRANSFORM(c_reserid)+" Name:"+ALLTRIM(TRANSFORM(c_lname)))
          IF this.SendMeldeschein()
               this.ReservationUpdate()
               this.nMeldescheneSent = this.nMeldescheneSent + 1
               l_lPrint = .T.
          ENDIF
          IF l_lPrint OR this.lForcePrint
               this.MeldescheinPrint()
               this.nMeldeschenePrinted = this.nMeldeschenePrinted + 1
          ENDIF
     ENDSCAN

     IF this.nConnectionError > 0
          this.LogIt("HTTP connection error occured. Aborting sending.")
     ENDIF

     this.LogIt("Finished sending.")
ELSE
     this.LogIt("Nothing to send.")
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE ShowGuests
LOCAL l_oGuests, l_lCancel
l_oGuests = CREATEOBJECT("exexjmavsguests", this)
this.cCurGuests = l_oGuests.ShowGuests()
IF EMPTY(this.cCurGuests)
     l_lCancel = .T.
ENDIF
l_oGuests.Release()

RETURN l_lCancel
ENDPROC
*
PROCEDURE GetReservationSql
LPARAMETERS lp_cResWhere
LOCAL l_cSql

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 1+2+4+8
SELECT DISTINCT rs_reserid AS c_reserid, rs_rsid AS c_rsid, rs_arrdate AS c_arrdate, rs_depdate AS c_depdate, rs_adults AS c_adults, 
     rs_childs AS c_childs, rs_childs2 AS c_childs2, rs_childs3 AS c_childs3, rs_addrid AS c_addrid, rs_custom1 AS c_custom1, 
     rs_compid AS c_compid, rs_apname AS c_apname, <<this.cuserfield_kategorie_person>> AS c_kper, 
     <<this.cuserfield_meldescheinnr>> AS c_meldenr, <<IIF(EMPTY(this.cuserfield_kfz),[''],this.cuserfield_kfz)>> AS c_kfz, 
     <<IIF(EMPTY(this.cuserfield_group),[''],this.cuserfield_group)>> AS c_ufgroup, 
     rs_status AS c_status, rs_in AS c_in, 
     rs_roomnum AS c_roomnum, rs_lname AS c_lname, rs_codate AS c_codate, 
     rs_groupid AS c_groupid, rs_roomlst AS c_roomlst, 
     rt_buildng, 
     a1.ad_lname, a1.ad_fname, a1.ad_titlcod, a1.ad_birth, a1.ad_street, a1.ad_zip, a1.ad_city, a1.ad_country, 
     ap_lname, ap_fname, ap_titlcod, ap_gebdate, 
     a2.ad_lname AS c_slname, a2.ad_fname AS c_sfname, a2.ad_titlcod AS c_stitlcod, a2.ad_birth AS c_sbirth, a2.ad_street AS c_sstreet, 
     a2.ad_zip AS c_szip, a2.ad_city AS c_scity, a2.ad_country AS c_scountry 
     FROM reservat 
     INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp 
     INNER JOIN address a1 ON rs_addrid = ad_addrid 
     LEFT JOIN apartner ON rs_apid = ap_apid 
     LEFT JOIN address a2 ON rs_saddrid = a2.ad_addrid 
     WHERE <<lp_cResWhere>> 
     ORDER BY c_depdate, c_reserid
ENDTEXT
*_cliptext=l_cSql

RETURN l_cSql
ENDPROC
*
PROCEDURE ReservationUpdate
LOCAL l_cAlias, l_cMeldeSchein, l_oXML AS MSXML2.DomDocument, l_oNode, l_lUpdated

l_cMeldeSchein = ""

TRY
     l_oXML = this.oXMLBUCHEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:meldescheine/ns0:meldeschein/meldescheinnummer")
     l_cMeldeSchein = ALLTRIM(l_oNode.text)
CATCH TO l_oErr
     l_cErr = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                    "|Message:"+TRANSFORM(l_oErr.Message)
ENDTRY

IF EMPTY(l_cMeldeSchein)
     this.LogIt("Error when retrieving Meldeschein Nr. for ReserId " + TRANSFORM(c_reserid)+"|"+l_cErr)
ELSE

     l_cAlias = this.cCURHISTRES
     sqlcursor("SELECT " + this.cUSERFIELD_MELDESCHEINNR_HIST + " AS c_melds FROM histres WHERE hr_reserid = " + sqlcnv(&l_cAlias..c_reserid,.T.),"curresm")
     IF RECCOUNT()>0 AND PADR(ALLTRIM(curresm.c_melds),100) <> PADR(l_cMeldeSchein,100)
          sqlupdate("histres","hr_reserid = " + sqlcnv(&l_cAlias..c_reserid),this.cUSERFIELD_MELDESCHEINNR_HIST+" = "+sqlcnv(l_cMeldeSchein,.T.))
          this.LogIt("Meldeschein Nr. " + l_cMeldeSchein + " written to histres ReserId " + TRANSFORM(&l_cAlias..c_reserid))
          REPLACE &l_cAlias..c_meldenr WITH l_cMeldeSchein IN &l_cAlias
          l_lUpdated = .T.
     ENDIF

     l_cAlias = this.cCURRES
     sqlcursor("SELECT " + this.cUSERFIELD_MELDESCHEINNR + " AS c_melds FROM reservat WHERE rs_reserid = " + sqlcnv(&l_cAlias..c_reserid,.T.),"curresm")
     IF RECCOUNT()>0 AND PADR(ALLTRIM(curresm.c_melds),100) <> PADR(l_cMeldeSchein,100)
          sqlupdate("reservat","rs_reserid = " + sqlcnv(&l_cAlias..c_reserid),this.cUSERFIELD_MELDESCHEINNR+" = "+sqlcnv(l_cMeldeSchein,.T.))
          this.LogIt("Meldeschein Nr. " + l_cMeldeSchein + " written to reservat ReserId " + TRANSFORM(&l_cAlias..c_reserid))
          REPLACE &l_cAlias..c_meldenr WITH l_cMeldeSchein IN &l_cAlias
          l_lUpdated = .T.
     ENDIF

     IF NOT l_lUpdated
          this.LogIt("Meldeschein Nr. " + l_cMeldeSchein + " not written to ReserId " + TRANSFORM(&l_cAlias..c_reserid) + " because already written there.")
     ENDIF
ENDIF
ENDPROC
*
PROCEDURE CheckGroup
LPARAMETERS lp_lForWholeGroup
LOCAL l_cCurRes, l_cForClause, l_cCur, l_nSelect, l_lContinue
lp_lForWholeGroup = .F.
l_lContinue = .T.
l_cCurRes = this.cCURRES
IF RECCOUNT(l_cCurRes)<>1
     * Allowed only in 1 reservation mode
     RETURN l_lContinue
ENDIF
IF EMPTY(&l_cCurRes..c_groupid) OR NOT &l_cCurRes..c_roomlst OR ; && This is not a group reservation
          this.lForceSingle OR ; && Treat this a single reservation, also when it is actually a group member
          NOT EMPTY(&l_cCurRes..c_meldenr) && When meldeschein nummer is already issued, don't check if it is a group member
     * This is not group reservation.
     RETURN l_lContinue
ENDIF

IF NOT ALLTRIM(&l_cCurRes..c_ufgroup) == "T"
     l_nSelect = SELECT()
     l_cForClause = "rs_reserid >= " + SqlCnv(INT(&l_cCurRes..c_reserid),.T.) + " AND rs_reserid < " + SqlCnv(INT(&l_cCurRes..c_reserid)+1,.T.) + " AND rs_groupid > 0 AND " + ;
               this.cuserfield_group+" = 'T'" + " AND rt_group IN (1,4)" + IIF(this.lUseBuildings," AND rt_buildng = " + SqlCnv(&l_cCurRes..rt_buildng,.T.),"")
     l_cCur = sqlcursor("SELECT COUNT(*) AS c_num FROM reservat INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp WHERE " + l_cForClause)
     IF &l_cCur..c_num=0
          IF this.lForWholeGroup AND yesno(IIF(this.lUseBuildings AND NOT EMPTY(&l_cCurRes..rt_buildng),strfmt(this.GetLangText("SEND_FOR_WHOLE_GROUP_FOR_ONE_BUILDING"),&l_cCurRes..rt_buildng),this.GetLangText("SEND_FOR_WHOLE_GROUP")))
               REPLACE c_ufgroup WITH "T" IN (l_cCurRes)
               sqlupdate("reservat","rs_reserid = " + sqlcnv(&l_cCurRes..c_reserid,.T.),this.cuserfield_group+" = 'T'")
               lp_lForWholeGroup = .T.
          ELSE
               l_lContinue = .F.
          ENDIF
     ELSE
          IF NOT yesno(this.GetLangText("NOT_ALLOWED_FOR_WHOLE_GROUP"))
               l_lContinue = .F.
          ENDIF
     ENDIF
     dclose(l_cCur)
     SELECT (l_nSelect)
ELSE
     lp_lForWholeGroup = .T.
ENDIF

RETURN l_lContinue
ENDPROC
*
PROCEDURE getKonfigurationsListe
LOCAL l_lSuccess
this.CreateXMLKonfigurationsListe("CONFIG-L-KAT")
IF this.HttpSend("getKonfigurationsListe")
     IF this.KonfigurationsListeAccepted()
          l_lSuccess = .T.
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE CreateXMLKonfigurationsListe
LPARAMETERS lp_cVerarbeitung
LOCAL l_cSysDate
l_cSysDate = this.Convertdate(this.dHSysDate)
this.cXmlRequest = ""

IF EMPTY(lp_cVerarbeitung)
     lp_cVerarbeitung = ""
ENDIF

TEXT TO this.cXmlRequest NOSHOW TEXTMERGE
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.avs.meldeschein.de/ns/">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:configuration-lists>
         <identifikation>
            <erzeugung><<l_cSysDate>></erzeugung>
            <schnittstelle>CITADEL</schnittstelle>
            <kurverwaltung><<this.cKURVERWALTUNGID>></kurverwaltung>
            <verarbeitung><<lp_cVerarbeitung>></verarbeitung>
         </identifikation>
      </ns:configuration-lists>
   </soapenv:Body>
</soapenv:Envelope>
ENDTEXT

ENDPROC
*
PROCEDURE KonfigurationsListeAccepted
LOCAL l_oNodeFehler, l_oXML AS MSXML2.DomDocument, l_nErrCode, l_cErrDescript, l_lSuccess
l_nErrCode = 0
l_cErrDescript = ""
l_oXML = this.oXMLgetKonfigurationsListe

*l_oNodeFehler = l_oXML.selectSingleNode("/SOAP-ENV:Envelope/SOAP-ENV:Body/configuration-lists/fehlermeldungen/fehler/code")
*l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns2:configuration-lists/fehlermeldungen/fehler/code")
l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:configuration-lists/fehlermeldungen/fehler/code")

IF ISNULL(l_oNodeFehler)
     l_cErrDescript = "Wrong response XML format."
ELSE
     l_nErrCode = INT(VAL(l_oNodeFehler.Text))
     l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:configuration-lists/fehlermeldungen/fehler/beschreibung")
     l_cErrDescript = ALLTRIM(l_oNodeFehler.Text)
ENDIF

DO CASE
     CASE l_nErrCode = 10001
          l_lSuccess = .T.
     OTHERWISE
          l_lSuccess = .F.
          this.cfehler = "fehler code:"+TRANSFORM(l_nErrCode)+CHR(13)+CHR(10)+"fehler beschreibung:"+l_cErrDescript
ENDCASE

this.LogIt("Send:"+IIF(l_lSuccess,"OK","ERROR")+"|fehler code:"+TRANSFORM(l_nErrCode)+"|fehler beschreibung:"+l_cErrDescript)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE MeldescheinPrint
LOCAL l_lSuccess
l_lSuccess = .F.
IF this.MeldescheinPrintPrepare()
     IF this.MeldescheinPDFReceive()
          l_lSuccess = this.MeldescheinPDFSave()
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE MeldescheinPrintPrepare
LOCAL l_cAlias, l_lSuccess
IF this.lhISTTABLE
     l_cAlias = this.cCURHISTRES
ELSE
     l_cAlias = this.ccuRRES
ENDIF

this.cMeldeSchein = ALLTRIM(&l_cAlias..c_meldenr)
IF EMPTY(this.cMeldeSchein)
     this.LogIt("MeldescheinPrint: No Meldeschein Nr. for ReserId " + TRANSFORM(&l_cAlias..c_reserid))
ELSE
     this.LogIt("MeldescheinPrint: Found Meldeschein Nr. " + this.cMeldeSchein + " PDF for ReserId " + TRANSFORM(&l_cAlias..c_reserid))
     l_lSuccess = .T.
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE MeldescheinPDFReceive
LOCAL l_lSuccess
this.CreateXMLPrint()
IF this.HttpSend("druckeMeldescheine")
     IF this.MeldescheinPDFAccepted()
          l_lSuccess = .T.
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE CreateXMLPrint
LOCAL l_cSysDate
l_cSysDate = this.Convertdate(this.dHSysDate)
this.cXmlRequest = ""

TEXT TO this.cXmlRequest NOSHOW TEXTMERGE
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.avs.meldeschein.de/ns/">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:druckeMeldescheineRequest>
         <identifikation>
            <erzeugung><<l_cSysDate>></erzeugung>
            <schnittstelle>CITADEL</schnittstelle>
            <kurverwaltung><<this.cKURVERWALTUNGID>></kurverwaltung>
            <verarbeitung>MS-DRUCKEN</verarbeitung>
         </identifikation>
         <meldeschein>
            <meldescheinnummer><<this.cMeldeSchein>></meldescheinnummer>
         </meldeschein>
      </ns:druckeMeldescheineRequest>
   </soapenv:Body>
</soapenv:Envelope>
ENDTEXT

ENDPROC
*
PROCEDURE MeldescheinPDFAccepted
LOCAL l_oNodeFehler, l_oXML AS MSXML2.DomDocument, l_nErrCode, l_cErrDescript, l_lSuccess
l_nErrCode = 0
l_cErrDescript = ""
l_oXML = this.oXMLdruckeMeldescheine


l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:druckeMeldescheineResponse/fehlermeldungen/fehler/code")
l_nErrCode = INT(VAL(l_oNodeFehler.Text))
l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:druckeMeldescheineResponse/fehlermeldungen/fehler/beschreibung")
l_cErrDescript = ALLTRIM(l_oNodeFehler.Text)

DO CASE
     CASE l_nErrCode = 10001
          l_lSuccess = .T.
     OTHERWISE
          l_lSuccess = .F.
          this.cfehler = "fehler code:"+TRANSFORM(l_nErrCode)+CHR(13)+CHR(10)+"fehler beschreibung:"+l_cErrDescript
ENDCASE

this.LogIt("PDF:"+IIF(l_lSuccess,"OK","ERROR")+"|fehler code:"+TRANSFORM(l_nErrCode)+"|fehler beschreibung:"+l_cErrDescript)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE MeldescheinPDFSave
LOCAL l_oNode, l_oXML AS MSXML2.DomDocument,l_lSuccess, l_oErr AS Exception, l_cFileName, l_cFullPathName
l_cErr = ""
l_cFullPathName = ""
l_oXML = this.oXMLDRUCKEMELDESCHEINE

IF this.lHISTTABLE
     l_cAlias = this.cCURHISTRES
ELSE
     l_cAlias = this.cCURRES
ENDIF
TRY
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:druckeMeldescheineResponse/ms-pdf")
     l_cFileName = STRTRAN(STRTRAN(TRANSFORM(&l_cAlias..c_reserid),",",".")+;
               "-"+ALLTRIM(get_rm_rmname(&l_cAlias..c_roomnum))+;
               "-"+ALLTRIM(&l_cAlias..c_lname)," ","_")+;
               ".pdf"

     STRTOFILE(STRCONV(l_oNode.Text, 14),this.cPDFSAVEFOLDER+l_cFileName,0)
     l_cFullPathName = FULLPATH(this.cPDFSAVEFOLDER+l_cFileName)
CATCH TO l_oErr
     l_cErr = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                    "|Message:"+TRANSFORM(l_oErr.Message)
ENDTRY

IF EMPTY(l_cErr)
     this.LogIt("Saved Meldeschein Nr. " + this.cMeldeSchein + " for ReserId " + TRANSFORM(&l_cAlias..c_reserid)+" to:"+l_cFullPathName)
     l_lSuccess = .T.
     IF this.lSHOWPDFAFTERDOWNLOAD AND NOT EMPTY(l_cFullPathName)
          g_myshell.Run([%COMSPEC% /C start ] + l_cFullPathName,0)
     ENDIF
ELSE
     this.LogIt("Error when saving Meldeschein Nr. " + this.cMeldeSchein + " for ReserId " + TRANSFORM(&l_cAlias..c_reserid)+"|"+l_cErr)
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE SendMeldeschein
LPARAMETERS lp_lUpdate, lp_lStorno
LOCAL l_lSuccess
this.Progress(IIF(lp_lUpdate,this.GetLangText("MELDUPDATE")+IIF(lp_lStorno," STORNO",""),this.GetLangText("MELDSEND"))+" ReserId:"+TRANSFORM(c_reserid)+;
          " Name:"+ALLTRIM(TRANSFORM(c_lname))+" Zimmer:"+ALLTRIM(get_rm_rmname(c_roomnum)))
this.cXmlRequest = ""
this.SetGuestData()
this.SetAccompanistData()
this.SetBuildingData()
IF this.IsGroupMeldeschein()
     this.CreateXMLBuchungBegleitGruppe(.T.)
ELSE
     this.CreateXMLBuchungBegleitPerson()
ENDIF
this.CreateXMLBuchung(lp_lUpdate, lp_lStorno)
IF this.HttpSend()
     IF this.MeldescheinAccepted()
          l_lSuccess = .T.
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE SendMeldescheinUpdate
LPARAMETERS lp_lStorno
RETURN this.SendMeldeschein(.T., lp_lStorno)
ENDPROC
*
PROCEDURE IsGroupMeldeschein
LOCAL l_cAlias, l_lIsGroup
l_cAlias = this.cCURRES
IF ALLTRIM(&l_cAlias..c_ufgroup) == "T"
     l_lIsGroup = .T.
ENDIF
RETURN l_lIsGroup
ENDPROC
*
PROCEDURE CreateXMLBuchung
LPARAMETERS lp_lUpdate, lp_lStorno
LOCAL l_cSysDate, l_cArrDate, l_cDepDate, l_cKategorieId, l_cAnredeId, l_cLandId, l_cBuchungsNummer, l_cmeldescheinnummer
l_cSysDate = this.Convertdate(this.dHSysDate)
l_cArrDate = this.cArrDate
l_cDepDate = this.cDepDate
l_cKategorieId = this.cKategorieId
l_cAnredeId = this.cAnredeId
l_cLandId = this.cLandId
l_cmeldescheinnummer = ""
l_ckfz = this.cKFZ

* Add CI- prefix to rs_rsid, to prevent collision with existing IDs in AVS database
l_cBuchungsNummer = this.GetBuchungsNummer()

IF lp_lUpdate
     l_cmeldescheinnummer = [<meldescheinnummer>]+ALLTRIM(c_meldenr)+[</meldescheinnummer>]
ENDIF

TEXT TO this.cXmlRequest NOSHOW TEXTMERGE
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.avs.meldeschein.de/ns/">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:meldescheine>
         <identifikation>
              <erzeugung><<l_cSysDate>></erzeugung>
              <schnittstelle>CITADEL</schnittstelle>
              <kurverwaltung><<this.cKURVERWALTUNGID>></kurverwaltung>
              <verarbeitung>BUCHEN</verarbeitung>
         </identifikation>
         <ns:meldeschein>
              <buchungsnummer><<l_cBuchungsNummer>></buchungsnummer>
              <<l_cmeldescheinnummer>>
              <firmaid><<this.cFIRMAID>></firmaid>
              <objektid><<this.cOBJEKTID>></objektid>
              <anreise><<l_cArrDate>></anreise>
              <abreise><<l_cDepDate>></abreise>
              <kategorieid><<l_cKategorieId>></kategorieid>
              <anredeid><<l_cAnredeId>></anredeid>
              <name><<this.cLNAME>></name>
              <vorname><<this.cFNAME>></vorname>
              <strasse><<this.cSTREET>></strasse>
              <plz><<this.cZIP>></plz>
              <ort><<this.cCITY>></ort>
              <landid><<l_cLandId>></landid>
              <<IIF(EMPTY(c_kfz),[],[<kfzkennzeichen>] + ALLTRIM(c_kfz) + [</kfzkennzeichen>])>>
              <<IIF(lp_lStorno,[<abrechnungstatusid>4</abrechnungstatusid>],[])>>
<<this.cXMLBegleitPerson>>
<<this.cXMLBegleitGruppe>>
              <<IIF(EMPTY(this.cAcmdFee), [], [<ue-e-gelt>]+this.cAcmdFee+[</ue-e-gelt>])>>
         </ns:meldeschein>
      </ns:meldescheine>
   </soapenv:Body>
</soapenv:Envelope>
ENDTEXT

RETURN .T.
ENDPROC
*
PROCEDURE CreateXMLBuchungBegleitPerson
LOCAL l_cXml AS String, l_nPersonNo AS Number, l_nChildCount AS Number, l_nChildNo AS Number, ;
          l_cArrDate, l_cDepDate, l_cKategorieId, l_cAnredeId, l_nPersons, l_cAnredeIdAcc

l_cArrDate = this.Convertdate(c_arrdate)
l_cDepDate = this.Convertdate(c_depdate)

this.cXMLBegleitPerson = ""

IF this.CreateXMLBuchungBegleitPersonFromGuests(l_cArrDate, l_cDepDate)
     RETURN .T.
ENDIF

l_cAnredeId = this.GetAnredeId()

* Add other adult persons and child, as begleitperson
l_nPersons = c_adults + c_childs + c_childs2 + c_childs3
IF l_nPersons > 1
     FOR l_nPersonNo = 2 TO l_nPersons
          l_cXml = ""
          IF l_nPersonNo = 2 AND NOT EMPTY(c_slname)
               * When accompanist is defined, use it only as 2. person
               l_cAnredeIdAcc = this.cSAnredeId
               l_cKategorieId = this.cSKategorieId
TEXT TO l_cXml NOSHOW TEXTMERGE
              <begleitperson>
                   <anredeid><<l_cAnredeIdAcc>></anredeid>
                   <name><<this.cSLName>></name>
                   <vorname><<this.cSFName>></vorname>
                   <kategorieid><<l_cKategorieId>></kategorieid>
                   <anreise><<l_cArrDate>></anreise>
                   <abreise><<l_cDepDate>></abreise>
              </begleitperson>
ENDTEXT

          ELSE
               l_cKategorieId = this.GetKategorieId(l_nPersonNo)
TEXT TO l_cXml NOSHOW TEXTMERGE
              <begleitperson>
                   <anredeid><<l_cAnredeId>></anredeid>
                   <name><<this.cLNAME>></name>
                   <vorname><<this.cFNAME>></vorname>
                   <kategorieid><<l_cKategorieId>></kategorieid>
                   <anreise><<l_cArrDate>></anreise>
                   <abreise><<l_cDepDate>></abreise>
              </begleitperson>
ENDTEXT

          ENDIF
          this.cXMLBegleitPerson = this.cXMLBegleitPerson + l_cXml + CHR(10) + CHR(13)
     ENDFOR
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE CreateXMLBuchungBegleitPersonFromGuests
LPARAMETERS lp_cArrDate, lp_cDepDate
LOCAL l_lGuestSet, l_nSelect, l_nBegleitPerson, l_cXml
l_nSelect = SELECT()
IF NOT EMPTY(this.cCurGuests) AND USED(this.cCurGuests) AND RECCOUNT(this.cCurGuests)>0
     l_nBegleitPerson = 0
     SELECT (this.cCurGuests)
     SCAN ALL
          l_nBegleitPerson = l_nBegleitPerson + 1
          IF l_nBegleitPerson = 1
               l_lGuestSet = .T.
               LOOP
          ENDIF
          TEXT TO l_cXml NOSHOW TEXTMERGE
              <begleitperson>
                   <anredeid><<TRANSFORM(IIF(c_title="FRAU",2,1))>></anredeid>
                   <name><<this.StringForXML(ALLTRIM(c_lname))>></name>
                   <vorname><<this.StringForXML(ALLTRIM(c_fname))>></vorname>
                   <kategorieid><<this.StringForXML(this.GetKategorieId(,c_cat))>></kategorieid>
                   <anreise><<lp_cArrDate>></anreise>
                   <abreise><<lp_cDepDate>></abreise>
              </begleitperson>
          ENDTEXT
          this.cXMLBegleitPerson = this.cXMLBegleitPerson + l_cXml + CHR(10) + CHR(13)
     ENDSCAN
ENDIF

SELECT (l_nSelect)

RETURN l_lGuestSet
ENDPROC
*
PROCEDURE CreateXMLBuchungBegleitGruppe
LPARAMETERS lp_lFillXml
LOCAL l_cXml, l_cSql, l_cResWhere, l_cCurGroup, l_cAlias, l_nSelect, l_nPersons, l_cKategorieId
l_cAlias = this.cCURRES

l_nSelect = SELECT()

CREATE CURSOR curgrcats82 (c_catid c(5), c_numofpe i)

* First send accompanist for main reservation as group members
SELECT &l_cAlias
l_nPersons = c_adults + c_childs + c_childs2 + c_childs3
IF l_nPersons > 1
     FOR l_nPersonNo = 2 TO l_nPersons
          SELECT (l_cCurGroup)
          l_cKategorieId = this.GetKategorieId(l_nPersonNo)
          SELECT curgrcats82
          LOCATE FOR c_catid = PADR(l_cKategorieId,5)
          IF FOUND()
               REPLACE c_numofpe WITH c_numofpe + 1
          ELSE
               INSERT INTO curgrcats82 (c_catid, c_numofpe) VALUES (l_cKategorieId, 1)
          ENDIF
     ENDFOR
ENDIF

* Get all reservations for this group, except main meldeschein reservation, reservations with medelschen number and dummies.
* We must count how many persons from every category we have.
SELECT &l_cAlias
TEXT TO l_cResWhere TEXTMERGE NOSHOW PRETEXT 1+2+4+8
     (rs_reserid >= <<SqlCnv(INT(c_reserid),.T.)>> AND rs_reserid < <<SqlCnv(INT(c_reserid)+1,.T.)>> AND rs_groupid > 0) AND 
     (rs_reserid <> <<sqlcnv(c_reserid,.T.)>>) AND 
     (NOT rs_status IN ('CXL', 'NS ')) AND 
     (rt_group = 1 OR rt_group = 4) AND <<IIF(this.lUseBuildings, "rt_buildng = " + sqlcnv(rt_buildng,.T.) + " AND","")>> 
     (rs_depdate - rs_arrdate) > 0  AND 
     <<this.cuserfield_meldescheinnr>> = '     ' 
ENDTEXT

l_cSql = this.GetReservationSql(l_cResWhere)
l_cCurGroup = sqlcursor(l_cSql,,,,,,,.T.)

SELECT (l_cCurGroup)
SCAN ALL
     l_nPersons = c_adults + c_childs + c_childs2 + c_childs3
     IF l_nPersons > 0
          FOR l_nPersonNo = 1 TO l_nPersons
               SELECT (l_cCurGroup)
               l_cKategorieId = this.GetKategorieId(l_nPersonNo)
               SELECT curgrcats82
               LOCATE FOR c_catid = PADR(l_cKategorieId,5)
               IF FOUND()
                    REPLACE c_numofpe WITH c_numofpe + 1
               ELSE
                    INSERT INTO curgrcats82 (c_catid, c_numofpe) VALUES (l_cKategorieId, 1)
               ENDIF
          ENDFOR
     ENDIF
ENDSCAN

IF lp_lFillXml
     this.cXMLBegleitGruppe = ""

     SELECT curgrcats82
     SCAN ALL

TEXT TO l_cXml NOSHOW TEXTMERGE
              <begleitgruppe>
                   <anzahl><<TRANSFORM(c_numofpe)>></anzahl>
                   <kategorieid><<ALLTRIM(c_catid)>></kategorieid>
              </begleitgruppe>
ENDTEXT

     this.cXMLBegleitGruppe = this.cXMLBegleitGruppe + l_cXml + CHR(10) + CHR(13)
     ENDSCAN
     dclose("curgrcats82")
ENDIF

dclose(l_cCurGroup)
SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE UpdateMeldeschein
LPARAMETERS lp_lStorno
LOCAL l_lSuccess
this.CreateXMLholeMeldeschein()
IF this.HttpSend("holeMeldeschein")
     IF this.MeldescheinFound()
          IF lp_lStorno
               IF this.SendMeldescheinUpdate(.T.)
                    l_lSuccess = .T.
               ENDIF
          ELSE
               this.SetGuestData()
               this.SetAccompanistData()
               IF this.MeldescheinChanged()
                    IF this.SendMeldescheinUpdate()
                         l_lSuccess = .T.
                    ENDIF
               ENDIF
          ENDIF
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE MeldescheinFound
LOCAL l_oNodeFehler, l_oXML AS MSXML2.DomDocument, l_nErrCode, l_cErrDescript, l_lSuccess
l_nErrCode = 0
l_cErrDescript = ""
l_oXML = this.oxmlHOLEMELDESCHEIN

l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/fehlermeldungen/fehler/code")
l_nErrCode = INT(VAL(l_oNodeFehler.Text))
l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/fehlermeldungen/fehler/beschreibung")
l_cErrDescript = ALLTRIM(l_oNodeFehler.Text)

DO CASE
     CASE l_nErrCode = 10001
          l_lSuccess = .T.
     OTHERWISE
          l_lSuccess = .F.
          this.cfehler = "fehler code:"+TRANSFORM(l_nErrCode)+CHR(13)+CHR(10)+"fehler beschreibung:"+l_cErrDescript
ENDCASE

this.LogIt("holeMeldeschein:"+IIF(l_lSuccess,"OK","ERROR")+"|fehler code:"+TRANSFORM(l_nErrCode)+"|fehler beschreibung:"+l_cErrDescript)

RETURN l_lSuccess

ENDPROC
*
PROCEDURE MeldescheinChanged
LOCAL l_oNode, l_oXML AS MSXML2.DomDocument, l_lDiffFound, l_cNodeText
* Check departure date
l_oXML = this.oxmlHOLEMELDESCHEIN
l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/abreise")
IF NOT ISNULL(l_oNode)
     l_cNodeText = ALLTRIM(l_oNode.Text)
     IF NOT l_cNodeText == this.cDepDate
          l_lDiffFound = .T.
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check arrival date
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/anreise")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cArrDate
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check title
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/anredeid")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cAnredeId
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cAnredeId)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check last name
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/name")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cLName
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cLName)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check first name
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/vorname")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cFName
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cFName)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check street
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/strasse")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cstreet
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cstreet)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check zip
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/plz")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.czip
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.czip)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check city
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/ort")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.ccity
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.ccity)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check country
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/landid")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cLandId
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cLandId)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check category
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/kategorieid")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cKategorieId
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cKategorieId)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check car plates
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/kfzkennzeichen")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cKFZ
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cKFZ)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF

* Check accompanist

IF NOT l_lDiffFound
     * Check title
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/begleitperson/anredeid")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cSAnredeId
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cSAnredeId)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check last name
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/begleitperson/name")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cSLName
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cSLName)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check first name
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/begleitperson/vorname")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cSFName
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cSFName)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound
     * Check category
     l_oXML = this.oxmlHOLEMELDESCHEIN
     l_oNode = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:holeMeldeschein/ns0:meldeschein/begleitperson/kategorieid")
     IF NOT ISNULL(l_oNode)
          l_cNodeText = ALLTRIM(l_oNode.Text)
          IF NOT l_cNodeText == this.cSKategorieId
               l_lDiffFound = .T.
          ENDIF
     ELSE
          IF NOT EMPTY(this.cSKategorieId)
               l_lDiffFound = .T.
          ENDIF
     ENDIF
ENDIF
IF NOT l_lDiffFound AND this.IsGroupMeldeschein()
     * Check group
     l_lDiffFound = this.MeldescheinChangedGroup()
ENDIF
RETURN l_lDiffFound
ENDPROC
*
PROCEDURE MeldescheinChangedGroup
LOCAL l_nSelect, l_lDiffFound, l_oXML, l_oNode, l_oNodes, l_cNodeText, l_oBG, l_nNumOf, l_cKatId
l_nSelect = SELECT()
l_oXML = this.oxmlHOLEMELDESCHEIN
* Check which categories are alrady sent
CREATE CURSOR curgrcatsxml1 (c_catid c(5), c_numofpe i)

l_oNodes = l_oXML.selectNodes("//begleitgruppe")
IF NOT ISNULL(l_oNodes)
     FOR EACH l_oBG IN l_oNodes
          l_oNode = l_oBG.selectSingleNode("kategorieid")
          IF NOT ISNULL(l_oNode)
               l_cNodeText = ALLTRIM(l_oNode.Text)
               l_cKatId = l_cNodeText
               l_oNode = l_oBG.selectSingleNode("anzahl")
               IF NOT ISNULL(l_oNode)
                    l_cNodeText = ALLTRIM(l_oNode.Text)
                    l_nNumOf = INT(VAL(l_cNodeText))
                    SELECT curgrcatsxml1
                    LOCATE FOR c_catid = PADR(l_cKatId,5)
                    IF FOUND()
                         REPLACE c_numofpe WITH c_numofpe + l_nNumOf
                    ELSE
                         INSERT INTO curgrcatsxml1 (c_catid, c_numofpe) VALUES (l_cKatId, l_nNumOf)
                    ENDIF
               ENDIF
          ENDIF
     ENDFOR
ENDIF

this.CreateXMLBuchungBegleitGruppe(.F.) && Result is in curgrcats82 cursor

SELECT c_catid, c_numofpe FROM curgrcatsxml1 WHERE 1=1 ORDER BY 1 INTO CURSOR curgrcatsxml2
SELECT c_catid, c_numofpe FROM curgrcats82 WHERE 1=1 ORDER BY 1 INTO CURSOR curgrcats83

IF RECCOUNT("curgrcatsxml2") <> RECCOUNT("curgrcats83")
     l_lDiffFound = .T.
ENDIF

IF NOT l_lDiffFound
     SELECT curgrcatsxml2
     SCAN ALL
          SELECT curgrcats83
          GO RECNO("curgrcatsxml2")
          IF curgrcatsxml2.c_catid <> curgrcats83.c_catid OR curgrcatsxml2.c_numofpe <> curgrcats83.c_numofpe
               l_lDiffFound = .T.
               EXIT
          ENDIF
     ENDSCAN
ENDIF

dclose("curgrcatsxml1")
dclose("curgrcatsxml2")
dclose("curgrcats82")
dclose("curgrcats83")
SELECT (l_nSelect)
RETURN l_lDiffFound
ENDPROC
*
PROCEDURE CreateXMLholeMeldeschein
LOCAL l_cSysDate, l_cBuchungsNummer
l_cSysDate = this.Convertdate(this.dHSysDate)
l_cBuchungsNummer = this.GetBuchungsNummer()

TEXT TO this.cXmlRequest NOSHOW TEXTMERGE
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.avs.meldeschein.de/ns/">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:holeMeldeschein>
         <identifikation>
            <erzeugung><<l_cSysDate>></erzeugung>
            <schnittstelle>CITADEL</schnittstelle>
            <kurverwaltung><<this.cKURVERWALTUNGID>></kurverwaltung>
            <verarbeitung>MS-HOLEN</verarbeitung>
         </identifikation>
         <anfragedaten>
            <buchungsnummer><<l_cBuchungsNummer>></buchungsnummer>
         </anfragedaten>
      </ns:holeMeldeschein>
   </soapenv:Body>
</soapenv:Envelope>

ENDTEXT

RETURN .T.
ENDPROC
*
PROCEDURE GetBuchungsNummer
* Add CI- prefix to rs_rsid, to prevent collision with existing IDs in AVS database
RETURN "CI-"+TRANSFORM(c_rsid)
ENDPROC
*
PROCEDURE GetKategorieId
LPARAMETERS lp_nPersonNo, lp_cCode
LOCAL l_cCode, l_nKategorieId
IF EMPTY(lp_nPersonNo)
     lp_nPersonNo = 1
ENDIF

IF EMPTY(lp_cCode)

     l_cCode = ""
     TRY
          l_cCode = GETWORDNUM(c_kper,lp_nPersonNo,",")
     CATCH
     ENDTRY

ELSE

     l_cCode = lp_cCode

ENDIF

l_cCode = UPPER(ALLTRIM(l_cCode))
IF EMPTY(l_cCode)
     l_cCode = this.cstandardkategorie
ENDIF
IF dlocate("curkat","c_code = " + sqlcnv(PADR(l_cCode,5)))
     l_nKategorieId = curkat.c_id
ELSE
     l_nKategorieId = 0
ENDIF

RETURN TRANSFORM(l_nKategorieId)
ENDPROC
*
PROCEDURE SetGuestData

* Prepare data with sohuld be used in XML

LOCAL l_lGuestIsAp

IF NOT this.SetGuestDataFromGuestsCursor()

     l_lGuestIsAp = (c_addrid = c_compid AND NOT ISNULL(ap_lname) AND NOT EMPTY(c_apname))
     IF l_lGuestIsAp
          this.dBirth = ap_gebdate
          this.nTitleCode = ap_titlcod
          this.cLName = this.StringForXML(ALLTRIM(ap_lname))
          this.cFName = this.StringForXML(ALLTRIM(ap_fname))
     ELSE
          this.dBirth = ad_birth
          this.nTitleCode = ad_titlcod
          this.cLName = this.StringForXML(ALLTRIM(ad_lname))
          this.cFName = this.StringForXML(ALLTRIM(ad_fname))
     ENDIF

     this.cKategorieId = this.GetKategorieId()

ENDIF

this.cstreet = this.StringForXML(ALLTRIM(ad_street))
this.czip = this.StringForXML(ALLTRIM(ad_zip))
this.ccity = this.StringForXML(ALLTRIM(ad_city))

this.cArrDate = this.Convertdate(c_arrdate)
this.cDepDate = this.Convertdate(c_depdate)
this.cAnredeId = this.GetAnredeId()
this.cLandId = this.GetLandId()
this.cKFZ = ""
IF NOT EMPTY(this.cuserfield_kfz) AND NOT EMPTY(c_kfz)
     this.cKFZ = ALLTRIM(c_kfz)
ENDIF
IF this.lSendTotalResAmount
     this.cAcmdFee = this.GetReservationPrice()
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE SetGuestDataFromGuestsCursor
LOCAL l_lGuestSet, l_nSelect
l_nSelect = SELECT()
IF NOT EMPTY(this.cCurGuests) AND USED(this.cCurGuests) AND RECCOUNT(this.cCurGuests)>0
     SELECT (this.cCurGuests)
     GO TOP
     this.cLName = this.StringForXML(ALLTRIM(c_lname))
     this.cFName = this.StringForXML(ALLTRIM(c_fname))
     this.dBirth = {}
     this.nTitleCode = IIF(c_title="HERR",1,2)
     this.cKategorieId = this.GetKategorieId(,c_cat)
     l_lGuestSet = .T.
ENDIF

SELECT (l_nSelect)

RETURN l_lGuestSet
ENDPROC
*
PROCEDURE SetAccompanistData

* Prepare data with sohuld be used in XML

this.dSBirth = NVL(ad_birth, {})
this.nSTitleCode = NVL(c_stitlcod,0)
this.cSLName = this.StringForXML(ALLTRIM(NVL(c_slname,"")))
this.cSFName = this.StringForXML(ALLTRIM(NVL(c_sfname,"")))
this.cSstreet = this.StringForXML(ALLTRIM(NVL(c_sstreet,"")))
this.cSzip = this.StringForXML(ALLTRIM(NVL(c_szip,"")))
this.cScity = this.StringForXML(ALLTRIM(NVL(c_scity,"")))
IF EMPTY(c_slname)
     this.cSAnredeId = ""
     this.cSKategorieId = ""
ELSE
     this.cSAnredeId = this.GetAnredeId(this.nSTitleCode)
     this.cSKategorieId = this.GetKategorieId(2)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE SetBuildingData
LOCAL l_cObjektId, l_cRoomObjektId, l_cFirmaId, l_cKurVerwaltungId
l_cObjektId = this.cObjektIdDefault
l_cFirmaId = this.cFirmaIdDefault
l_cKurVerwaltungId = this.cKurVerwaltungIdDefault
DO CASE
     CASE this.lObjektIdFromRoomTable
          IF NOT EMPTY(c_roomnum) AND NOT EMPTY(this.userfield_room_objektid)
               l_cRoomObjektId = dlookup("room","rm_roomnum = '" + c_roomnum + "'",this.userfield_room_objektid)
               IF NOT EMPTY(l_cRoomObjektId)
                    l_cObjektId = l_cRoomObjektId
               ENDIF
          ENDIF
     CASE this.lUseBuildings AND NOT EMPTY(rt_buildng)
          IF dlocate(this.cCurBuildings,"bu_buildng = " + sqlcnv(rt_buildng))
               IF NOT EMPTY(EVALUATE(this.cCurBuildings + ".objektid"))
                    l_cObjektId = ALLTRIM(EVALUATE(this.cCurBuildings + ".objektid"))
               ENDIF
               IF NOT EMPTY(EVALUATE(this.cCurBuildings + ".firmaid"))
                    l_cFirmaId = ALLTRIM(EVALUATE(this.cCurBuildings + ".firmaid"))
               ENDIF
               IF NOT EMPTY(EVALUATE(this.cCurBuildings + ".kurid"))
                    l_cKurVerwaltungId = ALLTRIM(EVALUATE(this.cCurBuildings + ".kurid"))
               ENDIF
          ENDIF
ENDCASE

this.cObjektId = l_cObjektId
this.cFirmaId = l_cFirmaId
this.cKurVerwaltungId = l_cKurVerwaltungId

RETURN .T.
ENDPROC
*
PROCEDURE StringForXML
LPARAMETERS lp_cString
LOCAL l_cStrXML
l_cStrXML = lp_cString
l_cStrXML = STRTRAN(l_cStrXML, "&", "&amp;")
l_cStrXML = STRTRAN(l_cStrXML, ">", "&gt;")
l_cStrXML = STRTRAN(l_cStrXML, "<", "&lt;")
l_cStrXML = STRTRAN(l_cStrXML, "'", "&apos;")
l_cStrXML = STRTRAN(l_cStrXML, ["], "&quot;")
l_cStrXML = STRCONV(l_cStrXML,9)
RETURN l_cStrXML
ENDPROC
*
PROCEDURE GetAnredeId
LPARAMETERS lp_nTitleCode
LOCAL l_nSelect, l_nAnredeId, l_cCode, l_nTitleCode
IF EMPTY(lp_nTitleCode)
     l_nTitleCode = this.nTITLECODE
ELSE
     l_nTitleCode = lp_nTitleCode
ENDIF
l_nSelect = SELECT()
SELECT (this.cCurAnrede)
LOCATE FOR c_id = l_nTitleCode
IF FOUND()
     l_cCode = ALLTRIM(c_title)
ELSE
     l_cCode = "HERR"
ENDIF

IF l_cCode = "FRAU"
     l_nAnredeId = 2
ELSE && HERR
     l_nAnredeId = 1
ENDIF


SELECT(l_nSelect)
RETURN TRANSFORM(l_nAnredeId)
ENDPROC
*
PROCEDURE GetLandId
LOCAL l_nLandId, l_cCountry
l_nLandId = 0
IF EMPTY(ad_country)
     * When no country is defined for address, get hotel country.
     l_cCountry = "D"
ELSE
     l_cCountry = PADR(ad_country,3)
ENDIF
IF dlocate(this.cCURCOUNTRY, "pl_charcod = " + sqlcnv(l_cCountry))
     l_nLandId = TRANSFORM(EVALUATE(this.cCURCOUNTRY + ".ext"))
ENDIF
IF EMPTY(l_nLandId)
     l_nLandId = 1 && Deutschland is default
ENDIF
RETURN TRANSFORM(l_nLandId)
ENDPROC
*
PROCEDURE GetReservationPrice
LOCAL l_cSql, l_nGeltPart, l_cAcmdFee
LOCAL ARRAY l_aTotalResAmount(1)

l_cAcmdFee = ""
l_nGeltPart = 0
IF USED(this.cCurGuests) AND RECCOUNT(this.cCurGuests) > 0
     CALCULATE CNT() FOR c_gelt TO l_nGeltPart IN (this.cCurGuests)
     l_nGeltPart = l_nGeltPart/RECCOUNT(this.cCurGuests)
ENDIF
IF NOT EMPTY(l_nGeltPart)
     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 1+2+4+8
     SELECT SUM(ps_amount) FROM ( 
          SELECT ps_amount FROM post 
               LEFT JOIN article ON ar_artinum = ps_artinum 
               WHERE ps_origid = <<SqlCnv(c_reserid,.T.)>> AND NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) AND ar_main = 1 
               UNION ALL 
          SELECT hp_amount FROM histpost 
               LEFT JOIN article ON ar_artinum = hp_artinum 
               WHERE hp_origid = <<SqlCnv(c_reserid,.T.)>> AND NOT SEEK(hp_postid,"post","tag3") AND NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) AND ar_main = 1 
               UNION ALL 
          SELECT rl_price*rl_units FROM ressplit 
               INNER JOIN reservat ON rs_rsid = rl_rsid 
               LEFT JOIN article ON ar_artinum = rl_artinum 
               WHERE rl_date > rs_ratedat AND rs_reserid = <<SqlCnv(c_reserid,.T.)>> AND NOT EMPTY(rl_price*rl_units) AND NOT INLIST(rs_status, 'CXL', 'NS') AND ar_main = 1) a
     ENDTEXT
     *_cliptext=l_cSql

     l_aTotalResAmount(1) = .T.
     sqlcursor(l_cSql,,,,,,@l_aTotalResAmount)
     IF l_aTotalResAmount(1) <> 0
          l_cAcmdFee = STRTRAN(ALLTRIM(STR(l_nGeltPart*l_aTotalResAmount(1),8,2)),",",".")
     ENDIF
ENDIF

RETURN l_cAcmdFee
ENDPROC
*
PROCEDURE ConvertDate
LPARAMETERS lp_dDate AS Date
RETURN TRANSFORM(YEAR(lp_dDate))+"-"+;
          PADL(TRANSFORM(MONTH(lp_dDate)),2,"0")+"-"+;
          PADL(TRANSFORM(DAY(lp_dDate)),2,"0")
ENDPROC
*
PROCEDURE convertavsdate
LPARAMETERS lp_cDate
LOCAL l_nYear, l_nMonth, l_nDay
l_nYear = INT(VAL(GETWORDNUM(lp_cDate,1,"-")))
l_nMonth = INT(VAL(GETWORDNUM(lp_cDate,2,"-")))
l_nDay = INT(VAL(SUBSTR(lp_cDate,9,2)))
RETURN DATE(l_nYear, l_nMonth, l_nDay)
ENDPROC
*
PROCEDURE HttpSend
LPARAMETERS lp_cCmd
LOCAL l_lSuccess, l_cAuth, l_oErr AS Exception, l_oHttp AS MSXML2.ServerXMLHTTP, l_cResponse, l_cHttpSendError, l_cSOAPAction
l_lSuccess = .F.
l_cResponse = ""
l_oErr = .NULL.

IF EMPTY(lp_cCmd)
     lp_cCmd = "bucheMeldeschein"
ENDIF
this.chttpcmd = lp_cCmd
IF ISNULL(this.oHttp)
     TRY
          this.oHttp = CREATEOBJECT("MSXML2.ServerXMLHTTP")
     CATCH TO l_oErr
          l_cResponse = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                         "|Message:"+TRANSFORM(l_oErr.Message)
     ENDTRY
ENDIF

IF ISNULL(this.oHttp)
     this.nConnectionError = 3
ELSE
     l_oHttp = this.oHttp
     l_oHttp.setTimeouts(this.nRESLOVETIMEOUT*1000,this.nCONNECTTIMEOUT*1000,this.nSENDTIMEOUT*1000,this.nRECIVETIMEOUT*1000)
     l_oHttp.Open("POST", this.cSERVERLINK, .F.)&&,this.cUSERNAME,this.cPASSWORD)

     *l_oHttp.setRequestHeader('Accept-Encoding', 'gzip,deflate')
     l_oHttp.setRequestHeader('Content-Type', 'text/xml;charset=UTF-8')
     l_cAuth = STRCONV(this.cUSERNAME + ":" + this.cPASSWORD, 13)
     l_oHttp.setRequestHeader('Authorization', 'Basic ' + l_cAuth)

     DO CASE
          CASE lp_cCmd == "druckeMeldescheine"
               l_cSOAPAction = '"urn:oracle:druckeMeldescheine"'
               this.oXMLdruckeMeldescheine = .NULL.
          CASE lp_cCmd == "holeMeldeschein"
               l_cSOAPAction = '"urn:oracle:holeMeldeschein"'
               this.oXMLholeMeldeschein = .NULL.
          CASE lp_cCmd == "getKonfigurationsListe"
               l_cSOAPAction = '"urn:oracle:getKonfigurationsListe"'
               this.oXMLgetKonfigurationsListe = .NULL.
          OTHERWISE
               l_cSOAPAction = '"urn:oracle:bucheMeldeschein"'
               this.oXMLbucheMeldeschein = .NULL.
     ENDCASE
     
     *l_oHttp.setRequestHeader('SOAPAction', '"urn:oracle:druckeMeldescheine"')
     *l_oHttp.setRequestHeader('SOAPAction', '"urn:oracle:bucheMeldeschein"')
     l_oHttp.setRequestHeader('SOAPAction', l_cSOAPAction)

     l_oHttp.setOption(2, 13056)
     IF NOT EMPTY(this.cproxy)
          l_oHttp.setProxy(2, this.cproxy, "")
     ENDIF

     this.LogitXml("REQUEST")
     
     l_cHttpSendError = ""
     TRY
          l_oHttp.send(this.cXmlRequest)
     CATCH TO l_oErr
          l_cHttpSendError = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
                    "|Message:"+TRANSFORM(l_oErr.Message)
     ENDTRY
     IF EMPTY(l_cHttpSendError)
          l_cResponse = "Status:"+TRANSFORM(l_oHttp.status)+;
                    "|StatusText:"+TRANSFORM(l_oHttp.statusText)+;
                    "|ReadyState:"+TRANSFORM(l_oHttp.readyState)
          IF l_oHttp.status = 200
               IF this.HttpSendXMLGet()
                    l_lSuccess = .T.
               ENDIF
          ENDIF
     ELSE
          DO CASE
               CASE lp_cCmd == "druckeMeldescheine"
                    this.nConnectionError = 2
               OTHERWISE
                    this.nConnectionError = 1
          ENDCASE
          l_cResponse = l_cHttpSendError
     ENDIF
     
ENDIF
l_cResponse = "HTTP Connect|"+l_cResponse

this.LogIt(l_cResponse)

IF l_lSuccess
     this.cXMLRESPONSE = l_oHttp.responsetext
     this.LogItXml("RESPONSE")
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE HttpSendXMLGet

* Hold refrence on received XML object in property

LOCAL l_oXML AS MSXML2.DomDocument, l_lSuccess
l_lSuccess = .T.
l_oXML = .NULL.
TRY
     l_oXML = this.oHTTP.responseXML
CATCH
ENDTRY
DO CASE
     CASE ISNULL(l_oXML)
          this.LogIt("Error: No XML received from server.")
          l_lSuccess = .F.
     CASE this.chttpcmd == "druckeMeldescheine"
          this.oXMLdruckeMeldescheine = l_oXML
     CASE this.chttpcmd == "holeMeldeschein"
          this.oXMLholeMeldeschein = l_oXML
     CASE this.chttpcmd == "getKonfigurationsListe"
          this.oXMLgetKonfigurationsListe = l_oXML
     OTHERWISE
          this.oXMLbucheMeldeschein = l_oXML
ENDCASE
RETURN l_lSuccess
ENDPROC
*
PROCEDURE MeldescheinAccepted
LOCAL l_oNodeFehler, l_oXML AS MSXML2.DomDocument, l_nErrCode, l_cErrDescript, l_lSuccess
l_nErrCode = 0
l_cErrDescript = ""
l_oXML = this.oXMLbucheMeldeschein

l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:meldescheine/fehlermeldungen/fehler/code")
IF ISNULL(l_oNodeFehler)
     l_cErrDescript = "Wrong response XML format."
ELSE
     l_nErrCode = INT(VAL(l_oNodeFehler.Text))
     l_oNodeFehler = l_oXML.selectSingleNode("/S:Envelope/S:Body/ns0:meldescheine/fehlermeldungen/fehler/beschreibung")
     l_cErrDescript = ALLTRIM(l_oNodeFehler.Text)
ENDIF

DO CASE
     CASE l_nErrCode = 10001
          l_lSuccess = .T.
     CASE l_nErrCode = 10104
          * Meldeschein is found on server. We mark it as succes, and store meldeschein nr in reservat table.
          l_lSuccess = .T.
     OTHERWISE
          l_lSuccess = .F.
          this.cfehler = "fehler code:"+TRANSFORM(l_nErrCode)+CHR(13)+CHR(10)+"fehler beschreibung:"+l_cErrDescript
ENDCASE

this.LogIt("Send:"+IIF(l_lSuccess,"OK","ERROR")+"|fehler code:"+TRANSFORM(l_nErrCode)+"|fehler beschreibung:"+l_cErrDescript)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE Progress
LPARAMETERS lp_cText
* WAIT CLEAR to refresh WAIT WINDOW in Desk, while autoyield=.F.
WAIT CLEAR
WAIT lp_cText WINDOW NOWAIT
RETURN .T.
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
PROCEDURE LogItXml
LPARAMETERS lp_cCmd
LOCAL l_cFile2, l_nLimit

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
          STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cCmd+CHR(10)+CHR(13)+REPLICATE("-",50)+CHR(10)+CHR(13)+;
                    this.cXmlRequest+CHR(10)+CHR(13)+;
                    REPLICATE("-",50)+CHR(10)+CHR(13),this.cXMLLogFile,1)
     ENDIF
CATCH
ENDTRY

ENDPROC
*
PROCEDURE CleanUp
WAIT CLEAR
this.LogIt("Exit.")
STRTOFILE(REPLICATE("-",50)+CHR(10)+CHR(13),this.cLogFile,1)
SYS(3101,this.nSys3101) && Restore code page translation to COM objects to default
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS exexjmavsguests AS Custom
*
cCURRES = ""
nSelect = 0
cCursor = ""
nPersons = 0
lCancel = .F.
oAVS = .NULL.
*
PROCEDURE Init
LPARAMETERS lp_oAVS
this.oAVS = lp_oAVS
this.cCURRES = this.oAVS.cCURRES
this.cCursor = "avsguests"
this.nSelect = SELECT()

this.CreateGuestsCursor()
this.SetNumberOfPersons()
this.StoredGuestsGet()
this.FillGuestsCursor()

RETURN .T.
ENDPROC
*
PROCEDURE ShowGuests

this.ShowInputMask()
this.CleanUp()

RETURN IIF(this.lCancel, "", this.cCursor)
ENDPROC
*
PROCEDURE CreateGuestsCursor

SELECT 000 AS c_no, '    ' AS c_title, CAST('' AS Char(30)) AS c_lname, CAST('' AS Char(20)) AS c_fname, CAST('' AS Char(5)) AS c_cat, 0=0 AS c_gelt FROM reservat WHERE 1=0 INTO CURSOR (this.cCursor) READWRITE

RETURN .T.
ENDPROC
*
PROCEDURE SetNumberOfPersons

SELECT (this.cCURRES)
this.nPersons = c_adults + c_childs + c_childs2 + c_childs3

RETURN .T.
ENDPROC
*
PROCEDURE FillGuestsCursor
LOCAL l_cCursor, l_cCurRes, l_nPerson, l_lPersonFound, l_nCurrentPerson

l_cCursor = this.cCursor
l_cCurRes = this.cCURRES

FOR l_nPerson = 1 TO this.nPersons
     SELECT (l_cCursor)

     l_lPersonFound = .F.
     l_nCurrentPerson = 0

     SCAN ALL
          l_nCurrentPerson = l_nCurrentPerson + 1
          IF l_nCurrentPerson = l_nPerson
               l_lPersonFound = .T.
               EXIT
          ENDIF
     ENDSCAN

     IF l_lPersonFound
          LOOP
     ELSE
          this.AddPersonToCursor(l_nPerson)
     ENDIF
ENDFOR

RETURN .T.
ENDPROC
*
PROCEDURE AddPersonToCursor
LPARAMETERS lp_nPerson
LOCAL l_cCursor, l_cCurRes, l_oData, l_nRecno, l_nMaxNo

l_cCursor = this.cCursor
l_cCurRes = this.cCURRES

SELECT (l_cCursor)
l_nRecno = RECNO()
IF EMPTY(lp_nPerson)
	l_nMaxNo = 0
	CALCULATE MAX(c_no) TO l_nMaxNo IN (l_cCursor)
	lp_nPerson = l_nMaxNo+1
ENDIF

APPEND BLANK
SCATTER NAME l_oData BLANK
l_oData.c_no = lp_nPerson
l_oData.c_gelt = .T.
DO CASE
     CASE lp_nPerson = 1
          l_lGuestIsAp = (&l_cCurRes..c_addrid = &l_cCurRes..c_compid AND NOT ISNULL(&l_cCurRes..ap_lname) AND NOT EMPTY(&l_cCurRes..c_apname))
          IF l_lGuestIsAp
               l_oData.c_lname = &l_cCurRes..ap_lname
               l_oData.c_fname = &l_cCurRes..ap_fname
          ELSE
               l_oData.c_lname = &l_cCurRes..ad_lname
               l_oData.c_fname = &l_cCurRes..ad_fname
          ENDIF
     CASE lp_nPerson = 2
          l_oData.c_lname = NVL(&l_cCurRes..c_slname, "")
          l_oData.c_fname = NVL(&l_cCurRes..c_sfname, "")
ENDCASE

GATHER NAME l_oData
GO l_nRecno

RETURN .T.
ENDPROC
*
PROCEDURE DelPersonFromCursor
IF RECNO(this.cCursor) > this.nPersons
	DELETE IN (this.cCursor)
	GO RECNO(this.cCursor) IN (this.cCursor)
ENDIF
ENDPROC
*
PROCEDURE StoredGuestsGet
LOCAL l_cJSON, l_cCurRes, l_lSuccess
l_cCurRes = this.cCURRES

l_cJSON = &l_cCurRes..c_custom1

IF NOT EMPTY(l_cJSON)

     IF FNJsonToCursor(l_cJSON, "curguest1")

          SELECT (this.cCursor)
          APPEND FROM DBF("curguest1")
          dclose("curguest1")

     ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE StoredGuestsSet
LOCAL l_cJSON, l_cCurRes
l_cCurRes = this.cCURRES

l_cJSON = FNCursorToJson(this.cCursor)

REPLACE rs_custom1 WITH l_cJSON FOR rs_reserid = &l_cCurRes..c_reserid IN reservat

RETURN .T.
ENDPROC
*
PROCEDURE ShowInputMask
LOCAL ARRAY l_aDefs(1,7), l_aUniButtonProp(7)

l_nRow = 1
l_aDefs(l_nRow,1) = "c_no"
l_aDefs(l_nRow,2) = 30
l_aDefs(l_nRow,3) = "Nr."
l_aDefs(l_nRow,4) = "TXT"
*l_aDefs(l_nRow,6) = .T.	&& could be edited guest No. because if deleted there would be holes in sequence.
l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_title"
l_aDefs(l_nRow,2) = 60
l_aDefs(l_nRow,3) = "Anrede"
l_aDefs(l_nRow,4) = "CBO"
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource")
l_aDefs(l_nRow,7).RowSourceType = 1
l_aDefs(l_nRow,7).RowSource = ",HERR,FRAU"
l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_lname"
l_aDefs(l_nRow,2) = 220
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_LASTNAME")
l_aDefs(l_nRow,4) = "TXT"
l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_fname"
l_aDefs(l_nRow,2) = 160
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_FIRSTNAME")
l_aDefs(l_nRow,4) = "TXT"
l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_cat"
l_aDefs(l_nRow,2) = 60
l_aDefs(l_nRow,3) = "Kat."
l_aDefs(l_nRow,4) = "CBO"
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource")
l_aDefs(l_nRow,7).RowSourceType = 1
l_aDefs(l_nRow,7).RowSource = ""
SELECT curkat
SCAN ALL
     l_aDefs(l_nRow,7).RowSource = l_aDefs(l_nRow,7).RowSource + "," + c_code
ENDSCAN
IF this.oAVS.lSendTotalResAmount
     l_nRow = Aadd(@l_aDefs)
     l_aDefs(l_nRow,1) = "c_gelt"
     l_aDefs(l_nRow,2) = 40
     l_aDefs(l_nRow,3) = GetLangText("EXJMAVS","TXT_UGELT")
     l_aDefs(l_nRow,4) = "CHK"
ENDIF
l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = ""
l_aDefs(l_nRow,2) = 20
l_aDefs(l_nRow,3) = ""
l_aDefs(l_nRow,4) = "CMD"
l_aDefs(l_nRow,7) = MakeStructure("Caption, Tag, ToolTipText")
l_aDefs(l_nRow,7).Caption = "-"
l_aDefs(l_nRow,7).Tag = "DelPersonFromCursor()"
l_aDefs(l_nRow,7).ToolTipText = GetLangText("ADDRESS","TXT_REMOVEGUEST")

l_aUniButtonProp[1] = this
l_aUniButtonProp[2] = "AddPersonToCursor()"
l_aUniButtonProp[4] = GetLangText("ADDRESS","TXT_ADDGUEST")
l_aUniButtonProp[7] = "+"

SELECT (this.cCursor)
GO TOP

l_nResult = FNDoBrwMulSel(this.cCursor, @l_aDefs, GetLangText("MAILING","T_GUESTS"), @l_aUniButtonProp,,GetLangText("MAILING","T_GUESTS"), .T.)

IF EMPTY(l_nResult)
     dclose(this.cCursor)
     this.lCancel = .T.
ELSE
     this.StoredGuestsSet()
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE CleanUp

SELECT (this.nSelect)
dclose("curguests")

RETURN .T.
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE