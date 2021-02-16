*
#INCLUDE "common\progs\cryptor.h"
#INCLUDE "include\constdefines.h"
*
FUNCTION Main
LPARAMETER ccOmmand
PRIVATE cdUmmy
ON ERROR DO StartErrorHnd WITH ERROR(), MESSAGE(), PROGRAM(), LINENO(), MESSAGE(1) IN ErrorSys

MainInitPublics()

IF NOT g_lDevelopment
     _screen.LockScreen = .T.
     _screen.Icon = "bitmap\Erase02.ico"
     _screen.WindowState = 2
     _screen.LockScreen = .F.
ENDIF

** ReFox 6.0 - Branding Code
_refox_ =  (9876543210)

IF WEXIST('Standard')
      HIDE WINDOW stAndard
ENDIF

DO FORM forms\Splash NAME frmsplash

MainProcessCommand(PCOUNT(), @ccOmmand)
MainSetEnvSettings()

frmsplash.SetLabelCaption(getlangtext("MAIN","STARTING"))

IF MainStartNotAllowed(ccOmmand,,,.T.)
     MainCleanUp()
     RETURN .F.
ENDIF

MainInitLibs(.T.)

IF NOT CheckFilesAndFields()
     MainCleanUp()
     RETURN .F.
ENDIF

IF NOT _screen.oGlobal.lDoBatchOnStartup
     _screen.LockScreen = .T. && Prevent user to see, how statusbar is created
     _screen.oGlobal.oStatusBar.CreateIt() && Sets autoyield to .F.
     _vfp.AutoYield = .T.
     _screen.LockScreen = .F.
ENDIF

IF NOT ProcCryptor(CR_ENCODE) OR NOT ProcCryptor(CR_REGISTER)
     alert(getapplangtext("MAIN","DATA_ACCESS_IS_FAILED"))
     = ErrorMsg(getapplangtext("MAIN","DATA_ACCESS_IS_FAILED"),.T.)
     MainCleanUp()
     RETURN .F.
ENDIF

IF _screen.oGlobal.lDoBatchOnStartup
     * Only execute some FXP files, and exit. Files are defined in citadel.ini. FXP must have valid GUID.
     frmsplash.Visible = .F.
     MainBatchStart()
     RETURN .T.
ENDIF

MainPrepareData()

IF NOT SetBaseAppSettings()
     MainCleanUp()
     RETURN .F.
ENDIF

frmsplash.SetLabelCaption(getapplangtext("MAIN","STARTING"))
frmsplash.HideProgressBar()

MainPrepareDataClose()

IF NOT dbupdate()
     alert(getapplangtext("MAIN","APPLICATION_CANT_START"))
     MainCleanUp()
     RETURN .F.
ENDIF

MainInitSharedLibs()
MainCreateGlobalObjects()
InitMousePointer()
IF checknetid()
     action(1)
     lexit = .F.
     IF setup()
          
          CheckIndex()
          SetUserActionsLog()

          frmsplash.Release()
          RELEASE frmsplash
          login(.F.)
          cdummy = GetLangText("MAIN","TXT_LANGUAGE")

          IF _screen.oGlobal.lDoAuditOnStartup
               DO NightAudit IN audit
               = checkwin("cleanup",,.T.,.T.)
          ENDIF

          IF NOT g_lNoReadEvents
               _vfp.AutoYield = .F.
               READ EVENTS
               POP KEY
          ENDIF

     ELSE
          MainQuit()
     ENDIF
ENDIF

RETURN .T.
ENDFUNC
*
PROCEDURE MainBatchStart
g_lAutomationMode = .T.
MainInitLibs()
MainPrepareData()
IF SetBaseAppSettings()

     MainPrepareDataClose()
     MainCreateGlobalObjects()
     setup()

     MainBatchDo()

ENDIF

= checkwin("cleanup",,.T.,.T.)

RETURN .T.
ENDPROC
*
PROCEDURE MainBatchDo
LOCAL l_lCheck, l_cIniLoc, l_nCount, l_cFXP, l_cFXPFullPath, l_cParams, l_cFunction, l_lOnlyTables, l_cFunctionCheck, ;
          l_cGuid
#DEFINE CX_DESK_FXP_GUID "1B0821EE9A9F11E1A1CFB6E76088709B"
#DEFINE CX_FXP_GUID      "3E0FA46C9C7213D2BF5B15E86016715A"
l_cIniLoc = FULLPATH(INI_FILE)
l_lCheck = .T.
l_nCount = 0
l_lOnlyTables = .T.
CloseAllFiles(l_lOnlyTables)
DO WHILE l_lCheck
     l_lCheck = .F.
     l_nCount = l_nCount + 1
     l_cFXP = ReadINI(l_cIniLoc, "dobatch", "fxp"+TRANSFORM(l_nCount),"")
     IF NOT EMPTY(l_cFXP)
          l_lCheck = .T.
          l_cFXP = FORCEEXT(l_cFXP,"fxp")
          l_cFXPFullPath = _screen.oGlobal.choteldir + l_cFXP
          IF FILE(l_cFXPFullPath)
               l_cFunction = "DO " + l_cFXPFullPath
               
               * check us fxp allowed
               l_cGuid = TRANSFORM(SYS(2007,CX_DESK_FXP_GUID))
               l_cFunctionCheck = l_cFunction + " WITH l_cGuid"
               &l_cFunctionCheck
               IF NOT EMPTY(l_cGuid) AND TRANSFORM(l_cGuid) == SYS(2007,CX_FXP_GUID)
                    l_cFunction = l_cFunction + " WITH '" + CX_FXP_GUID + "'"
                    &l_cFunction
               ENDIF
          ENDIF
     ENDIF
ENDDO
RETURN .T.
ENDPROC
*
FUNCTION vFoundation
 RETURN leXit
ENDFUNC
*
FUNCTION vClear
 CLEAR READ
 RETURN .T.
ENDFUNC
*
FUNCTION CheckNetID
 LPARAMETERS lp_lRelogin, lp_lSuccess, lp_lDontQuit
 PRIVATE nlOcks
 LOCAL l_cMessage, l_nReprocessCount, l_nReprocessType, l_lProceed, l_nMaxAlowedUsers, l_nMaxAllowedLicensedUsers, l_nShowLocks
 lp_lSuccess = .F.
 l_lProceed = .T.
 nlOcks = 0
 l_nShowLocks = 0
 l_nMaxAlowedUsers = _screen.oGlobal.oParam.pa_maxuser+1 && Thru licence alowed plus SUPERVISOR user
 l_nMaxAllowedLicensedUsers = _screen.oGlobal.oParam.pa_maxuser
 l_cMessage = SET('message', 1)
 l_nReprocessCount = SET("Reprocess")
 l_nReprocessType = SET("Reprocess", 2)
 SET REPROCESS TO 1
 IF openfiledirect(.F.,"License") AND openfiledirect(.F.,"files") && Here was checked param instead of files before!
      IF  .NOT. (SUBSTR(DBF("files"), 1, 3)==SUBSTR(DBF("License"), 1, 3))
           = alErt("Missing license file!")
           l_lProceed = .F.
      ENDIF
      IF l_lProceed
           SELECT liCense
           GOTO TOP
           LOCATE FOR ALLTRIM(UPPER(lc_station))==wiNpc()
           IF ( .NOT. EOF())
                = acTion(3)
                IF ( .NOT. RLOCK())
                     WAIT CLEAR
                     WAIT WINDOW TIMEOUT 10  ;
                          gcApplication + " is already running on this station!"+ ;
                          (CHR(13)+CHR(10))+"Unable to start " + gcApplication + " again"+ ;
                          (CHR(13)+CHR(10))+(CHR(13)+CHR(10))+ ;
                          "Use ALT+TAB to switch to " + gcApplication
                     l_lProceed = .F.
                ELSE
                     SCATTER BLANK MEMVAR
                     GATHER MEMVAR
                ENDIF
           ENDIF
      ENDIF
      IF l_lProceed
           SELECT liCense
           UNLOCK ALL
           DO WHILE (RECCOUNT()<l_nMaxAlowedUsers)
                APPEND BLANK
                UNLOCK
           ENDDO
           GOTO TOP
           DO WHILE ( .NOT. EOF("License"))
                IF (RLOCK("license"))
                     UNLOCK
                ELSE
                     l_nShowLocks = l_nShowLocks + 1
                     IF NOT ALLTRIM(UPPER(license.lc_user)) == "SUPERVISOR" && Don't count SUPERVISOR as licensed user
                          nlOcks = nlOcks+1
                     ENDIF
                     IF g_debug
                          WAIT CLEAR
                          WAIT WINDOW NOWAIT "Locked:"+LTRIM(STR(l_nShowLocks))
                     ENDIF
                ENDIF
                SKIP 1 IN "License"
           ENDDO
           IF (nlOcks>=l_nMaxAllowedLicensedUsers)
                g_totalandsuperuser = .T.
           ELSE
                g_totalandsuperuser = .F.
           ENDIF
           GOTO TOP IN "license"
           DO WHILE ( .NOT. EOF("License"))
                IF RLOCK()
                     EXIT
                ENDIF
                SKIP 1 IN "license"
           ENDDO
           IF (EOF("License"))
                = alErt("No Available Network ID!")
                l_lProceed = .F.
           ENDIF
      ENDIF
      IF l_lProceed
           IF lp_lRelogin
                REPLACE lc_user WITH _screen.oGlobal.oUser.us_id, ;
                        lc_date WITH DATE(), ;
                        lc_time WITH TIME(), ;
                        lc_station WITH wiNpc() ;
                        IN license
           ELSE
                REPLACE lc_user WITH "STARTUP", ;
                        lc_date WITH DATE(), ;
                        lc_time WITH TIME(), ;
                        lc_station WITH wiNpc() ;
                        IN license
           ENDIF
           FLUSH
           lp_lSuccess = .T.
      ENDIF
 ENDIF
 IF l_nReprocessType = 1
     SET REPROCESS TO (l_nReprocessCount) SECONDS
 ELSE
     SET REPROCESS TO (l_nReprocessCount)
 ENDIF
 SET MESSAGE TO l_cMessage
 
 IF lp_lSuccess
      IF g_debug
           WAIT WINDOW NOWAIT "Total Locks is "+LTRIM(STR(nlOcks+1))
      ENDIF
 ELSE
      IF NOT lp_lDontQuit
           DO CHECKWIN IN CHECKWIN WITH 'MainQuit IN Main',.T.,.T.,.F.,.T.
           *DO CHECKWIN IN CHECKWIN WITH 'CLEANUP',.T.,.T.,.F.,.T.
           *RETURN TO MASTER
      ENDIF
 ENDIF
 RETURN lp_lSuccess
ENDFUNC
*
FUNCTION CheckIndex
&&Check if indexes exist for tables, needed on startup
 IF opEnfile(.F.,"messages")
      IF USED("messages")
           USE IN messages
      ENDIF
 ENDIF
 SELECT 0&& Set unused work area
 RETURN .T.
ENDFUNC
*
FUNCTION SetUserActionsLog
LOCAL l_oIniReg, l_cLogUserActions

#INCLUDE "include\registry.h"

l_oIniReg = CREATEOBJECT("OldIniReg")
l_cIniLoc = FULLPATH(INI_FILE)
g_lLogUserActions = .T.
IF l_oIniReg.GetINIEntry(@l_cLogUserActions, "User", "Log", l_cIniLoc) = ERROR_SUCCESS
     IF LOWER(l_cLogUserActions) = "no" OR LOWER(l_cLogUserActions) = "n"
          g_lLogUserActions = .F.
     ENDIF
ENDIF
RETURN .T.
ENDFUNC
*
PROCEDURE CheckFilesAndFields
LOCAL l_lSuccess, l_oErr, i, l_lRetry
l_lSuccess = .T.
= ProcCryptor(CR_REGISTER, gcDatadir, "Files")
IF NOT openfiledirect(.F.,"files")
     l_lSuccess = .F.
     alert(Str2Msg(getapplangtext("MAIN","CANT_OPEN_TABLE"), "%s", "files"))
ELSE
     * Check Index
     SELECT files
     IF ATAGINFO(l_aTag,"files.cdx")=0
          IF openfiledirect(.T.,"files")
               SELECT files
               INDEX ON UPPER(fi_name) TAG taG1
               INDEX ON UPPER(fi_alias) TAG taG2
               INDEX ON STR(fi_group, 2) TAG taG3
          ENDIF
     ENDIF
     closefile("files")
ENDIF
ProcCryptor(CR_UNREGISTER, gcDatadir, "Files")
IF l_lSuccess
     = ProcCryptor(CR_REGISTER, gcDatadir, "fields")
     IF NOT openfiledirect(.F.,"fields")
          l_lSuccess = .F.
          alert(Str2Msg(getapplangtext("MAIN","CANT_OPEN_TABLE"), "%s", "fields"))
     ELSE
          * Check Index
          SELECT fields
          IF ATAGINFO(l_aTag,"fields.cdx")=0
               IF openfiledirect(.T.,"fields")
                    SELECT fields
                    INDEX ON UPPER(fd_table+fd_name) TAG fiElds
               ENDIF
          ENDIF
          closefile("fields")
     ENDIF
     ProcCryptor(CR_UNREGISTER, gcDatadir, "fields")
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE SetBaseAppSettings
* Put here only minimal needed settings!
* This is done before update, so new fields and tables are not yet available.
* Go to function SetupAppSettings in setup.prg, and add new settings there.

LOCAL l_nSelect
IF USED("caparam")
     l_nSelect = SELECT()
     SetAppVersion()
     _screen.oGlobal.RefreshTableParam()
     _screen.oGlobal.RefreshTableParam2()
     gcHotCode = ALLTRIM(UPPER(_screen.oGlobal.oParam2.pa_hotcode))
     AFIELDS(_screen.oGlobal.aParamFields, "caparam")
     AFIELDS(_screen.oGlobal.aParam2Fields, "caparam2")
     DO setsystempoint IN ini 
     IF NOT g_debug
          g_debug = _screen.oGlobal.oParam.pa_debug
     ENDIF
     g_myerrorhandle = _screen.oGlobal.oParam.pa_error
     IF EMPTY(_screen.oGlobal.oParam.pa_lang)
          g_Language = "GER"
     ELSE
          g_Language = _screen.oGlobal.oParam.pa_lang
     ENDIF

     _screen.oGlobal.SetSystemTime()
     sysdate()

     MainSetRemoteDatabases()

     g_Langnum = "3" && Default is german
     SqlCursor("SELECT pl_numcod FROM picklist WHERE pl_label = " + SqlCnv("LANGUAGE  ",.T.) + " AND pl_charcod = " + SqlCnv(g_Language, .T.), "capicklist")
     IF RECCOUNT("capicklist") > 0
          g_Langnum = ALLTRIM(TRANSFORM(capicklist.pl_numcod))
     ENDIF
     SELECT(l_nSelect)
ELSE
     IF NOT g_lDevelopment
          RELEASE g_CryptorObject
     ENDIF
     MESSAGEBOX("Can't open PARAM.DBF!"+CHR(13)+"Data is crypted or system maintenance is in progress.",16 ,"Information")
     RETURN .F.
ENDIF
ENDPROC
*
PROCEDURE MainSetRemoteDatabases
LOCAL i, l_cDataPathMPServer, l_cDataPathArgus, l_cDataPathWellness, l_cHotCode, l_cHotPath, l_oDatabaseProp, l_lMainServerPathValid
LOCAL ARRAY l_aDataPathsMultiproper(1)

DO AOGetOdbc IN ArgusOffice
goDatabases.Remove(-1)
goDatabases.Add(DataAccessInit("DESK","","",INI_FILE,.T.), "DESK")
IF _screen.oGlobal.oParam.pa_argus
     l_cDataPathArgus = ADDBS(_screen.oGlobal.oParam2.pa_argusdr)
     goDatabases.Add(DataAccessInit("ARGUS","AO",l_cDataPathArgus,INI_FILE), "ARG")
ENDIF
IF _screen.oGlobal.oParam2.pa_wellifc
     l_cDataPathWellness = ADDBS(_screen.oGlobal.oParam2.pa_welldir)
     goDatabases.Add(DataAccessInit("WELLNESS","WO",l_cDataPathWellness,INI_FILE), "WEL")
ENDIF
l_cDataPathMPServer = _screen.oGlobal.MainServerPathGet()
IF NOT EMPTY(l_cDataPathMPServer)
     TRY
          l_lMainServerPathValid = DIRECTORY(l_cDataPathMPServer)
     CATCH
     ENDTRY
     _screen.oGlobal.lMainServerDirectoryAvailable = l_lMainServerPathValid
     l_cDataPathMPServer = ADDBS(l_cDataPathMPServer) + "data\"
     goDatabases.Add(DataAccessInit("MPSERVER","FO",l_cDataPathMPServer,INI_FILE), "SRV")
     IF _screen.oGlobal.lUseMainServer
          l_oDatabaseProp = goDatabases.Item("SRV")
          IF TYPE("l_oDatabaseProp.nserverport")="N"
               _screen.oGlobal.lmainserverremote = (l_oDatabaseProp.nserverport<>0)
          ENDIF
     ENDIF
     l_aDataPathsMultiproper(1) = .T.
     SqlCursor("SELECT ho_hotcode, ho_path FROM __#SRV.HOTEL#__ WHERE ho_mainsrv = (1=0)",,,,,,@l_aDataPathsMultiproper)
     IF NOT EMPTY(l_aDataPathsMultiproper(1))
          FOR i = 1 TO ALEN(l_aDataPathsMultiproper,1)
               l_cHotCode = ALLTRIM(l_aDataPathsMultiproper(i,1))
               l_cHotPath = ADDBS(ALLTRIM(l_aDataPathsMultiproper(i,2))) + "data\"
               goDatabases.Add(DataAccessInit(UPPER("Desk"+l_cHotCode),l_cHotCode+"_",l_cHotPath,INI_FILE), l_cHotCode)     && here add server's name and port from Hotel.dbf
          NEXT
     ENDIF
     IF "vfpcompression" $ LOWER(SET("Library"))
          RELEASE LIBRARY vfpcompression.fll
     ENDIF
     IF "vfpencryption71" $ LOWER(SET("Library"))
          RELEASE LIBRARY vfpencryption71.fll
     ENDIF
     IF "vfpconnection" $ LOWER(SET("Library"))
          RELEASE LIBRARY vfpconnection.fll
     ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE MainInitPublics
PUBLIC leXit
PUBLIC gcApplication
PUBLIC glTraining
PUBLIC g_Lite
PUBLIC gl_valid
PUBLIC g_totalandsuperuser
PUBLIC _reser_mode
PUBLIC ARRAY parights(260), padow(7), pamonths(12)
PUBLIC g_debug
PUBLIC g_myerrorhandle
PUBLIC g_pushkeyactive
PUBLIC g_initpath
PUBLIC g_setdef
PUBLIC g_hh
PUBLIC g_newversionactive
PUBLIC g_dobilltimer
PUBLIC g_oWinEvents
PUBLIC g_IndexOnBuffFailed
PUBLIC g_lNewConferenceActive
PUBLIC g_lBillMode, gcReportdir, gcDatadir, g_BriliantToolBar, g_buildversion, g_cittool, goTbrQuick, goTbrMain, ;
          gcTemplatedir, gcDocumentdir, g_lCheckLang
PUBLIC g_lDevelopment, g_CryptorObject, g_cWinPc, g_lLogUserActions, g_cPoint
PUBLIC g_lShips, g_lBuildings
PUBLIC g_oUserData
PUBLIC gosqlwrapper
PUBLIC g_oBridgeFunc
PUBLIC g_Version
PUBLIC g_Build
PUBLIC g_Revision
PUBLIC lnEterror
PUBLIC g_Sysdate
PUBLIC llOgin
PUBLIC g_Nscreenmode
PUBLIC glDepositflag
PUBLIC glInreport
PUBLIC glErrorinreport
PUBLIC glOutIfErrorInReport
PUBLIC g_Rptlng
PUBLIC g_Rptlngnr
PUBLIC omapi
PUBLIC ocalendar
PUBLIC roomplanactive
PUBLIC g_auditactive
PUBLIC g_lFakeResAndPost
PUBLIC g_oMsgHandler
PUBLIC g_oTmrLogOut
PUBLIC g_oTmrRelease
PUBLIC g_dBillDate
PUBLIC g_oNavigPane
PUBLIC lsYserror
PUBLIC cuSerid
PUBLIC crEaderror
PUBLIC gcCurrcy
PUBLIC gcCurrcydisp
PUBLIC glCheckout
PUBLIC g_Usergroup
PUBLIC g_Cashier
PUBLIC gcCashier
PUBLIC g_Language
g_Language = "ENG"
PUBLIC g_Langnum
PUBLIC g_Tempdir
PUBLIC g_Refreshall
PUBLIC g_Refreshcurr
PUBLIC g_Data[10,10]
PUBLIC g_Billnum
PUBLIC g_Billname
PUBLIC g_Billcopy
PUBLIC g_Billdupl
PUBLIC g_Billstyle, g_UseBDateInStyle
PUBLIC gcButtonfunction
PUBLIC g_Demo
PUBLIC g_Lite
PUBLIC g_Hotel
PUBLIC g_Nscreenmode
PUBLIC g_Userid
PUBLIC nbUttonheight
PUBLIC gcCompany1
PUBLIC gcCompany2
PUBLIC gcCopyright
PUBLIC glPrgerror
PUBLIC gnTworowoffset
PUBLIC gnOnerowoffset
PUBLIC gnReseroffset
PUBLIC ps_departm
PUBLIC hp_departm
PUBLIC ar_departm
PUBLIC rf_departm
PUBLIC bq_departm
PUBLIC g_username
PUBLIC g_nLastFiscalBillNr
PUBLIC g_cGridFontName
PUBLIC g_nGridFontSize
PUBLIC g_oPredefinedColors
PUBLIC g_lUseCreditor
PUBLIC g_lToolBarNoCaption
PUBLIC g_lNoReadEvents
PUBLIC g_lUseNewRepExp
PUBLIC g_lUseNewRepPreview
PUBLIC g_cexeversion
PUBLIC g_cexenameandpath
PUBLIC g_myshell
PUBLIC g_initialscreenheight
PUBLIC g_oTabsToolBar
PUBLIC g_lAutomationMode
PUBLIC goDatabases, gcUseDatabase, gcHotCode
PUBLIC glAutoGeneratePoints, glAutoDiscount, g_lSpecialVersion, g_oBillFormSet

***********************************************************
* Don't forget to add new variables in procdeskserver.prg *
***********************************************************

_screen.NewObject("oGlobal","cglobal","commonclasses.prg")
g_myshell = CreateObject("WScript.Shell")
gcApplication = ""
goDatabases = CREATEOBJECT("Collection")
gcUseDatabase = ""
gcHotCode = ""

STORE SPACE(3) TO ps_departm, hp_departm, ar_departm, rf_departm, bq_departm
g_Revision = " " && Not used, but here for compatibility reasons
g_oFP = .NULL.
g_oUserData = CREATEOBJECT("Empty")
ADDPROPERTY(g_oUserData,"cuser","")
ADDPROPERTY(g_oUserData,"cpass","")
ADDPROPERTY(g_oUserData,"lPassc",.F.)
ADDPROPERTY(g_oUserData,"ccashier","")
gosqlwrapper = NEWOBJECT("csqldef","sqlclasses.prg")
g_Sysdate = {}
glTraining = .F.
g_IndexOnBuffFailed = 0
g_hh = .t.
g_setdef = ""
g_cWinPc = ""
g_cPoint = "," && Default set point, is changed by procedure SetSystemPoint, and used when param table is not accessable
g_pushkeyactive = .f.
g_myerrorhandle = .f. 
_reser_mode = ""
gl_valid=.f.
g_BriliantToolBar = .NULL.
gcReportdir = "Report\"
gcDatadir = "Data\"
gcTemplatedir = "Dot\"
gcDocumentdir = "Document\"
g_cittool=.null.
goTbrQuick = .NULL.
goTbrMain = .NULL.
g_oNavigPane=.null.
IF FILE("hotel.lang")
     g_lCheckLang = .T.
ENDIF
g_lUseNewRepPreview = .T.
g_newversionactive = .T.
g_lNewConferenceActive = .T.
g_lBillMode = .T.
g_username = ""
g_nLastFiscalBillNr = 0
g_cGridFontName = "Arial"
g_nGridFontSize = 10
g_cexenameandpath = MainGetExeNameAndPath()
g_lAutomationMode = .F.
g_oBillFormSet = .NULL.

MainUseCreditors()
MainUseNewReportExport()
MainMiscSettings()
gcApplication = IIF(_screen.oGlobal.lUgos,"Macnetix@on-balance","Citadel Desk")

RETURN .T.
ENDPROC
*
PROCEDURE MainSetEnvSettings
LOCAL LMyAppResult
* Here was SET DATE Short

* Get windows settings for:
*SET CURRENCY
SET SYSFORMATS ON
SET SYSFORMATS OFF
* Hard coded set decimals to 2 and set hours to 24
SET DECIMALS TO 2
SET HOURS TO 24
*

SET DATE german
*SET DATE Short
*************************!
SET MARK TO .
SET CENTURY ON
SET TALK OFF
SET EXCLUSIVE OFF
SET DELETED ON
SET READBORDER ON
SET SAFETY OFF
SET POINT TO "."
SET REFRESH TO 0, 5
SET REPROCESS TO AUTOMATIC
SET AUTOSAVE ON
SET STATUS BAR ON
SET MESSAGE TO ""
SET CLOCK STATUS
SET NEAR OFF
SET EXACT OFF
SET ANSI OFF
SET TYPEAHEAD TO 5
SET SYSMENU TO
SET DEBUG OFF
SET MULTILOCKS ON
SET ENGINEBEHAVIOR 70
SET NOTIFY CURSOR OFF
SET NOTIFY OFF
SET CPDIALOG OFF
SET UDFPARMS TO VALUE
SET NULLDISPLAY TO ''
IF NOT g_lDevelopment
     SYS(2450,1)
ENDIF
SET PROCEDURE TO "progs\func.prg" && Set it here to allow calling alert funtion. We set it later again in MainSetEnvSetting function.
= seTerror()

MainGetHotelIniLanguage()

IF TYPE("_Screen.oThemesManager")="O"
     _Screen.RemoveObject("oThemesManager")
ENDIF
_Screen.Newobject("oThemesManager","ThemesManager","libs\ThemedControls.vcx")

IF NOT g_lDevelopment
     _screen.WindowState = 2
     _screen.caption = "Starting " + gcApplication + "..."
     IF NOT PEMSTATUS(_screen, "imgBackground", 5)
          _screen.AddObject("imgBackground","image")
     ENDIF
     _Screen.imgBackground.Stretch = 2
     _Screen.imgBackground.Width = _Screen.Width
     _Screen.imgBackground.Height = _Screen.Height
     _Screen.imgBackground.Anchor = 15
     _Screen.oThemesManager.ChangeTheme()
     _Screen.imgBackground.Visible = .T.
     _screen.ForeColor = RGB(0,0,0)
     SET TALK OFF
ENDIF

MainSetPath()

IF FILE('myapp.ini')
     LMyAppResult = checkupdate()
ENDIF

IF LMyAppResult AND FILE('myapp.ini')
     CREATE CURSOR ctmpcur (c1 c(100))
     APPEND FROM myapp.ini DELIMITED WITH tab
     GO BOTTOM
     g_setdef= ALLTRIM(ctmpcur.c1)
     IF DIRECTORY(g_setdef)
          SET DEFAULT TO &g_setdef
     ELSE
          MESSAGEBOX("Your local hotel directory, specified in myapp.ini is not valid!"+CHR(13)+;
                            "Please check setting in myapp.ini!",16,"Message")
     ENDIF
ELSE
     g_setdef = SYS(5)+SYS(2003)
ENDIF

PUSH KEY CLEAR
CLOSE DATABASES
CLEAR MACROS

IF NOT DIRECTORY(_screen.oGlobal.choteldir+"Tmp")
     MD (_screen.oGlobal.choteldir+"Tmp")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"Tmp\pack")
     MD (_screen.oGlobal.choteldir+"Tmp\pack")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"Packed")
     MD (_screen.oGlobal.choteldir+"Packed")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"Pictures")
     MD (_screen.oGlobal.choteldir+"Pictures")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"Update")
     MD (_screen.oGlobal.choteldir+"Update")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"common\dll")
     MD (_screen.oGlobal.choteldir+"common\dll")
     IF FILE(_screen.oGlobal.choteldir+"hndlib.dll")
          COPY FILE (_screen.oGlobal.choteldir+"hndlib.dll") TO (_screen.oGlobal.choteldir+"common\dll\hndlib.dll")
          DELETE FILE (_screen.oGlobal.choteldir+"hndlib.dll")
     ENDIF
     IF FILE(_screen.oGlobal.choteldir+"zlib.dll")
          COPY FILE (_screen.oGlobal.choteldir+"zlib.dll") TO (_screen.oGlobal.choteldir+"common\dll\zlib.dll")
          DELETE FILE (_screen.oGlobal.choteldir+"zlib.dll")
     ENDIF
     IF FILE(_screen.oGlobal.choteldir+"xfrxlib.fll")
          COPY FILE (_screen.oGlobal.choteldir+"xfrxlib.fll") TO (_screen.oGlobal.choteldir+"common\dll\xfrxlib.fll")
          DELETE FILE (_screen.oGlobal.choteldir+"xfrxlib.fll")
     ENDIF
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"ifc")
     MD (_screen.oGlobal.choteldir+"ifc")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"ifc\int")
     MD (_screen.oGlobal.choteldir+"ifc\int")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"ifc\key")
     MD (_screen.oGlobal.choteldir+"ifc\key")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"ifc\pos")
     MD (_screen.oGlobal.choteldir+"ifc\pos")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"ifc\ptt")
     MD (_screen.oGlobal.choteldir+"ifc\ptt")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.choteldir+"ifc\ptv")
     MD (_screen.oGlobal.choteldir+"ifc\ptv")
ENDIF
IF NOT DIRECTORY(_screen.oGlobal.cReportResultsDir)
     MD (_screen.oGlobal.cReportResultsDir)
ENDIF
IF NOT EMPTY(gcDocumentdir) AND NOT DIRECTORY(gcDocumentdir)
     MD (gcDocumentdir)
ENDIF

IF _screen.oGlobal.lwebbrowserdesktop
     IF NOT DIRECTORY(_screen.oGlobal.chtmldir)
          MD (_screen.oGlobal.chtmldir)
     ENDIF
ENDIF

IF _screen.oGlobal.lGobdActive
     IF NOT DIRECTORY(_screen.oGlobal.cGobdDirectory)
          MD (_screen.oGlobal.cGobdDirectory)
     ENDIF
ENDIF

SET SYSMENU TO
***
*sys(3050,1,10000000)
*sys(3050,2,6000000)
***

MainVersion()
ENDPROC
*
PROCEDURE MainStartNotAllowed
LPARAMETERS ccOmmand, lp_lDontChangeScreen, lp_lNoCryptor, lp_lCheckLoader
* lp_lNoCryptor - Dont register with cryptor, when calling from login form.
* Table is allready registered with cryptor.
LOCAL l_lBlocked
l_lBlocked = FILE(_screen.oGlobal.choteldir+"hotel.stop")
IF NOT l_lBlocked
     IF NOT lp_lNoCryptor
          = ProcCryptor(CR_REGISTER, gcDatadir, "license")
     ENDIF
     IF NOT openfiledirect(.F.,"license")
          l_lBlocked = .T.
     ELSE
          dclose("license")
     ENDIF
     IF NOT lp_lNoCryptor
          ProcCryptor(CR_UNREGISTER, gcDatadir, "license")
     ENDIF
ENDIF
IF l_lBlocked
     IF NOT (NOT EMPTY(ccOmmand) AND UPPER(ccOmmand) == "LOGIN")
          IF NOT lp_lDontChangeScreen
               _screen.Caption = gcApplication
               _screen.ForeColor = RGB(0,0,0)
               _screen.Icon = "bitmap\Erase02.ico"
               _screen.WindowState = 2
          ENDIF
          = MESSAGEBOX(getapplangtext("MAIN","SYSTEM_MAINTANCE"),16,getapplangtext("MAIN","SYSTEM_MESSAGE"),10000)
          RETURN .T.
     ENDIF
ENDIF
IF lp_lCheckLoader AND _screen.oGlobal.lforcestartoverloader
     IF EMPTY(ccOmmand) OR (NOT EMPTY(ccOmmand) AND UPPER(ccOmmand) <> "LOADER")
          IF NOT g_lDevelopment
               = MESSAGEBOX(getapplangtext("MAIN","TXT_DIRECT_START_NOT_ALLOWED"),16,getapplangtext("MAIN","SYSTEM_MESSAGE"),10000)
               RETURN .T.
          ENDIF
     ENDIF
ENDIF
RETURN .F.
ENDPROC
*
PROCEDURE MainInitLibs
LPARAMETERS lp_lExcludeFLLs
DECLARE INTEGER GetPrivateProfileString IN Win32API STRING, STRING,  ;
        STRING, STRING @, INTEGER, STRING
DECLARE INTEGER WritePrivateProfileString IN Win32API STRING, STRING,  ;
        STRING, STRING
DECLARE INTEGER GetProfileString IN Win32API STRING, STRING, STRING,  ;
        STRING @, INTEGER
DECLARE INTEGER WriteProfileString IN Win32API STRING, STRING, STRING
DECLARE INTEGER GetCursor IN WIN32API AS GetScreenCursor
DECLARE Sleep IN Win32API INTEGER nMilliseconds
* FindWindowA returns the window handle from the window's caption
DECLARE LONG FindWindowA IN WIN32API STRING class, STRING title
* SetWindowPos moves the window to the top, using the window handle
* Example: SetWindowPos(hwnd, -1, 0, 0, 0, 0, 3)
DECLARE SetWindowPos IN WIN32API LONG hwnd, LONG hwndafter, LONG x, LONG y, LONG cx, LONG cy, LONG flags
DECLARE INTEGER CopyFile IN kernel32;
        STRING  lpExistingFileName,;
        STRING  lpNewFileName,;
        INTEGER bFailIfExists
DECLARE integer GetWindowLong IN Win32API ;
     integer hWnd, integer nIndex
DECLARE integer CallWindowProc IN Win32API ;
     integer lpPrevWndFunc, integer hWnd, integer Msg, integer wParam, ;
     integer lParam
DECLARE Integer ExitProcess IN WIN32API

IF FILE("common\dll\blat.dll")
     DECLARE INTEGER Send IN common\dll\blat.dll STRING blatstring
ENDIF
SET PROCEDURE TO "func.prg"
SET PROCEDURE TO "common\progs\commonfunc.prg" ADDITIVE
SET PROCEDURE TO "listsdata.prg" ADDITIVE
SET PROCEDURE TO "procresrooms.prg" ADDITIVE
SET PROCEDURE TO "procresrate.prg" ADDITIVE
IF g_newversionactive
     SET PROCEDURE TO "resrateperi.prg" ADDITIVE
ENDIF
SET PROCEDURE TO "commonclasses.prg" ADDITIVE
SET PROCEDURE TO "commonprocs.prg" ADDITIVE
SET PROCEDURE TO "toolbar.prg" ADDITIVE
SET PROCEDURE TO "frontofficeaccess.prg" ADDITIVE
SET PROCEDURE TO "sqlclasses.prg" ADDITIVE
SET PROCEDURE TO "common\progs\sqlparse.prg" ADDITIVE
SET PROCEDURE TO "procbill.prg" ADDITIVE
SET PROCEDURE TO "procaddress.prg" ADDITIVE
SET PROCEDURE TO "getlangtext.prg" ADDITIVE
SET PROCEDURE TO "common\progs\cadefdesk.prg" ADDITIVE
SET PROCEDURE TO "progs\bizbase.prg" ADDITIVE
SET PROCEDURE TO "progs\bizaddress.prg" ADDITIVE
SET PROCEDURE TO "progs\bizallotment.prg" ADDITIVE
SET PROCEDURE TO "progs\bizreservat.prg" ADDITIVE
SET PROCEDURE TO "progs\procmydesk.prg" ADDITIVE
SET PROCEDURE TO "common\progs\rentgroupbrowseclasses.prg" ADDITIVE
SET PROCEDURE TO "mailing.prg" ADDITIVE
SET PROCEDURE TO "progs\procreservattransactions.prg" ADDITIVE
SET PROCEDURE TO "procconf.prg" ADDITIVE
SET PROCEDURE TO "qdfoxjson.prg" ADDITIVE
IF _screen.oGlobal.lfiskaltrustactive OR _screen.oGlobal.lQrCodeDoorKeyActive
     SET PROCEDURE TO common\progs\foxbarcodeqr.prg ADDITIVE
ENDIF
SET CLASSLIB TO "Libs\mnglibs" 
SET CLASSLIB TO "Libs\mngargus" additive
SET CLASSLIB TO "Libs\restextline" additive
SET CLASSLIB TO "Libs\DBClasses" additive
SET CLASSLIB TO "Libs\BaseCtlr" additive
SET CLASSLIB TO "Libs\BaseCtrL2" additive
SET CLASSLIB TO "Libs\_datetime" additive
SET CLASSLIB TO "Libs\registry" additive
SET CLASSLIB TO 'libs\main' additive 
SET CLASSLIB TO 'libs\checkreservat' additive 
SET CLASSLIB TO 'libs\cit_budget' additive 
SET CLASSLIB TO 'libs\cit_reservat' ADDITIVE
SET CLASSLIB TO 'libs\cit_bridge' ADDITIVE
SET CLASSLIB TO 'libs\cit_data' ADDITIVE
SET CLASSLIB TO 'libs\cit_email' ADDITIVE
IF FILE('libs\_pg_cit_data.vcx')
     SET CLASSLIB TO 'libs\_pg_cit_data' ADDITIVE
ENDIF
SET CLASSLIB TO 'libs\cit_avail' ADDITIVE
SET CLASSLIB TO 'libs\cit_toolbarparts' ADDITIVE
SET CLASSLIB TO 'libs\cit_intervals' ADDITIVE
SET CLASSLIB TO 'libs\cit_address' ADDITIVE
SET CLASSLIB TO 'libs\cit_ctrl' ADDITIVE
SET CLASSLIB TO 'libs\cit_hicardreader.vcx' ADDITIVE
SET CLASSLIB TO 'libs\cit_tbrform' ADDITIVE
SET CLASSLIB TO 'libs\jbase' ADDITIVE
SET CLASSLIB TO 'libs\toolbar' ADDITIVE
SET CLASSLIB TO 'common\libs\cit_ca' ADDITIVE
SET CLASSLIB TO 'common\ffc\_reportlistener' ADDITIVE
SET CLASSLIB TO 'common\ffc\automate' ADDITIVE
SET CLASSLIB TO 'common\ffc\mailmrge' ADDITIVE
SET CLASSLIB TO 'common\misc\xfrxlib\xfrxlib.vcx' ADDITIVE
SET CLASSLIB TO 'common\libs\cit_cardreader.vcx' ADDITIVE
SET CLASSLIB TO 'common\libs\_lvisual.vcx' ADDITIVE
SET CLASSLIB TO 'common\libs\_util.vcx' ADDITIVE
SET CLASSLIB TO 'common\libs\_search.vcx' ADDITIVE
SET CLASSLIB TO 'common\libs\processhandler.vcx' ADDITIVE
SET CLASSLIB TO 'libs\cit_report.vcx' ADDITIVE
SET CLASSLIB TO 'libs\proc_system.vcx' ADDITIVE
SET CLASSLIB TO 'libs\progressbarex.vcx' ADDITIVE
IF NOT lp_lExcludeFLLs
     MainInitSharedLibs()
ENDIF
ENDPROC
*
PROCEDURE MainInitSharedLibs
****************************************************************************************************
* SET LIBRARY TO will exclusively capture the file so this file can't be overwrited.
* Use this declarations after update procedure because some flls are copied from apupdate folder.
****************************************************************************************************
SET LIBRARY TO "fll\anFoxGUI.fll" ADDITIVE
IF FILE("common\dll\vfpcompression.fll")
     SET LIBRARY TO "common\dll\vfpcompression.fll" ADDITIVE
ENDIF
IF FILE("common\dll\vfpencryption71.fll")
     SET LIBRARY TO common\dll\vfpencryption71.fll ADDITIVE
ENDIF
IF FILE("common\dll\vfpconnection.fll") AND NOT "vfpconnection" $ LOWER(SET("Library"))
     SET LIBRARY TO common\dll\vfpconnection.fll ADDITIVE
ENDIF
ENDPROC
*
PROCEDURE MainProcessCommand
LPARAMETERS lp_nPCount, lp_cCommand
LOCAL i, l_cCmdAfter
IF lp_nPCount>0
     IF lp_cCommand = "LOADER|TRAINING"
          l_cCmdAfter = "LOADER"
          lp_cCommand = "TRAINING"
     ENDIF
     DO CASE
          CASE AT("TRAINING", UPPER(ALLTRIM(lp_cCommand)))>0
               glTraining = .T.
          CASE INLIST(UPPER(LEFT(lp_cCommand,7)), "@_!%ST1", "@_!%ST2", "@_!%ST3", "@_!%ST4", "@_!%ST5", "@_!%ST6", "@_!%ORG")
               IF NOT ALLTRIM(LEFT(UPPER(lp_cCommand),7)) == "@_!%ORG"
                    g_cWinPc = ALLTRIM(LEFT(UPPER(lp_cCommand),7))
               ENDIF
               FOR i = 1 TO GETWORDCOUNT(lp_cCommand)
                    DO CASE
                         CASE i = 2
                              g_oUserData.cuser = ALLTRIM(UPPER(GETWORDNUM(lp_cCommand,i," ")))
                         CASE i = 3
                              g_oUserData.cpass = ALLTRIM(UPPER(GETWORDNUM(lp_cCommand,i," ")))
                         CASE i = 4
                              g_oUserData.ccashier = ALLTRIM(GETWORDNUM(lp_cCommand,i," "))
                    ENDCASE
               ENDFOR
          CASE lp_cCommand == "DESK_AUDIT"
               _screen.oGlobal.lDoAuditOnStartup = .T.
          CASE lp_cCommand == "DO_BATCH"
               _screen.oGlobal.lDoBatchOnStartup = .T.
     ENDCASE
     IF NOT EMPTY(l_cCmdAfter)
          lp_cCommand = l_cCmdAfter
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE MainCreateGlobalObjects
LOCAL l_nSelect
_screen.oGlobal.Initialize()
g_oBridgeFunc = CREATEOBJECT("BrilliantFunc")
g_oWinEvents = CREATEOBJECT('WindowsEvents')
g_dobilltimer = CREATEOBJECT('billtimer')
_screen.AddObject("oCardReaderHandler","CrHandler")
IF NOT (g_lAutomationMode OR _screen.oGlobal.lDoAuditOnStartup)
	_screen.oCardReaderHandler.lOpenPort = g_lNoReadEvents
	_screen.oCardReaderHandler.Initialize()
ENDIF

_screen.AddProperty("oTmrCall",.NULL.)
_screen.oTmrCall = NEWOBJECT("TmrCall","libs\cit_system.vcx")
_screen.AddProperty("oProcessHandler",CREATEOBJECT("cProcessHnd"))
SetTransactObject()
l_nSelect = SELECT()
_screen.oGlobal.RefreshTableParam2()
SELECT (l_nSelect)
ENDPROC
*
PROCEDURE SetAppVersion
LPARAMETERS lp_cVersion
LOCAL l_cPoint, l_cVersion, l_lSpecial
l_cVersion = GetFileVersion(APP_EXE_NAME, @l_lSpecial)
g_cexeversion = l_cVersion
l_cPoint = SET("Point")
SET POINT TO "."
g_Version = VAL(ALLTRIM(GETWORDNUM(l_cVersion,1,"."))+"."+PADL(ALLTRIM(GETWORDNUM(l_cVersion,2,".")),2,"0"))
SET POINT TO l_cPoint
g_Build = VAL(ALLTRIM(GETWORDNUM(l_cVersion,3,".")))
lp_cVersion = l_cVersion
g_lSpecialVersion = l_lSpecial
RETURN .T.
ENDPROC
*
PROCEDURE MainGetHotelIniLanguage
LOCAL l_cLanguage, l_oIniReg
l_cLanguage = ""
g_Language = "GER"
l_cIniLoc = FULLPATH(INI_FILE)
l_oIniReg = NEWOBJECT("oldinireg","libs\registry.vcx")
IF l_oIniReg.GetINIEntry(@l_cLanguage, "System", "Language", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cLanguage)
          g_Language = l_cLanguage
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE MainUseCreditors
LOCAL l_cUse, l_oIniReg
l_cUse = ""
g_lUseCreditor = .F.
l_cIniLoc = FULLPATH(INI_FILE)
l_oIniReg = NEWOBJECT("oldinireg","libs\registry.vcx")
IF l_oIniReg.GetINIEntry(@l_cUse, "System", "Creditors", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cUse) AND (LOWER(l_cUse) = "yes" OR LOWER(l_cUse) = "ja")
          g_lUseCreditor = .T.
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE MainUseNewReportExport
LOCAL l_cUse, l_oIniReg, l_cData
l_cUse = ""
g_lUseNewRepExp = .F.
l_cIniLoc = FULLPATH(INI_FILE)
l_oIniReg = NEWOBJECT("oldinireg","libs\registry.vcx")
IF l_oIniReg.GetINIEntry(@l_cUse, "System", "newreportexport", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cUse) AND (LOWER(l_cUse) = "yes" OR LOWER(l_cUse) = "ja")
          g_lUseNewRepExp = .T.
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cUse, "System", "newreportpreview", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cUse) AND (LOWER(l_cUse) = "no" OR LOWER(l_cUse) = "nein")
          g_lUseNewRepPreview = .F.
     ENDIF
ENDIF

IF l_oIniReg.GetINIEntry(@l_cUse, "System", "FormReports", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cUse) AND (LOWER(l_cUse) = "yes" OR LOWER(l_cUse) = "ja")
           _screen.oGlobal.lFormReports = .T.
     ENDIF
ENDIF

IF l_oIniReg.GetINIEntry(@l_cUse, "E-Mail", "active", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cUse) AND (LOWER(l_cUse) = "yes" OR LOWER(l_cUse) = "ja")
          _screen.oGlobal.lsmtpactive = .T.
          
          IF l_oIniReg.GetINIEntry(@l_cData, "E-Mail", "smtphost", l_cIniLoc) = ERROR_SUCCESS
               IF NOT EMPTY(l_cData)
                     _screen.oGlobal.csmtphost = l_cData
               ENDIF
          ENDIF
          
          IF l_oIniReg.GetINIEntry(@l_cData, "E-Mail", "smtpauthlogin", l_cIniLoc) = ERROR_SUCCESS
               IF NOT EMPTY(l_cData)
                     _screen.oGlobal.csmtpauthlogin = l_cData
               ENDIF
          ENDIF

          IF l_oIniReg.GetINIEntry(@l_cData, "E-Mail", "smtpauthpassword", l_cIniLoc) = ERROR_SUCCESS
               IF NOT EMPTY(l_cData)
                     _screen.oGlobal.csmtpauthpassword = l_cData
               ENDIF
          ENDIF
          
          IF l_oIniReg.GetINIEntry(@l_cData, "E-Mail", "smtpfrom", l_cIniLoc) = ERROR_SUCCESS
               IF NOT EMPTY(l_cData)
                     _screen.oGlobal.csmtpfrom = l_cData
               ENDIF
          ENDIF

          IF l_oIniReg.GetINIEntry(@l_cData, "E-Mail", "smtpdefaultexportformat", l_cIniLoc) = ERROR_SUCCESS
               IF NOT EMPTY(l_cData)
                     _screen.oGlobal.csmtpdefaultexportformat = l_cData
               ENDIF
          ENDIF

          IF l_oIniReg.GetINIEntry(@l_cData, "E-Mail", "smtpdefaulttoaddress", l_cIniLoc) = ERROR_SUCCESS
               IF NOT EMPTY(l_cData)
                     _screen.oGlobal.csmtpdefaulttoaddress = l_cData
               ENDIF
          ENDIF

          IF l_oIniReg.GetINIEntry(@l_cData, "E-Mail", "smtpusemapi", l_cIniLoc) = ERROR_SUCCESS
               IF NOT EMPTY(l_cData) AND (LOWER(l_cData) = "yes" OR LOWER(l_cData) = "ja")
                     _screen.oGlobal.lsmtpusemapi = .T.
               ENDIF
          ENDIF

     ENDIF
ENDIF

IF l_oIniReg.GetINIEntry(@l_cData, "ExcelExport", "LEAVE_FULL_FIELD_CONTENT", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lLEAVE_FULL_FIELD_CONTENT = IIF(LOWER(l_cData)="no",.F.,.T.)
     ENDIF
ENDIF

IF l_oIniReg.GetINIEntry(@l_cData, "ExcelExport", "HORIZONTAL_ADJUSTMENT", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nHORIZONTAL_ADJUSTMENT = INT(VAL(l_cData))
     ENDIF
ENDIF

IF l_oIniReg.GetINIEntry(@l_cData, "ExcelExport", "VERTICAL_ADJUSTMENT", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nVERTICAL_ADJUSTMENT = INT(VAL(l_cData))
     ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE MainMiscSettings
LPARAMETERS lp_oDeskServer
LOCAL l_oIniReg, l_cData

IF NOT "common\misc\sfwtreeview" $ LOWER(SET("Path"))
     * Needed for readini
     SET PATH TO SET("Path")+";"+"common\misc\sfwtreeview"
ENDIF

l_cIniLoc = FULLPATH(INI_FILE)
l_oIniReg = NEWOBJECT("oldinireg","libs\registry.vcx")
IF l_oIniReg.GetINIEntry(@l_cData, "System", "usemainserver", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lUseMainServer = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "autorepairtables", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lAutoRepairTables = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "autocenterforms", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData) AND LOWER(l_cData)="no"
           * Turn it off only when explicitly set this property to no.
           * This works only for form, which have autocenter set to .T.
           _screen.oGlobal.lautocenterforms = .F.
     ELSE
           _screen.oGlobal.lautocenterforms = .T.
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "databasedir", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cdatabasedir = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "reportdir", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.creportdir = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "templatedir", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.ctemplatedir = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF EMPTY(_screen.oGlobal.choteldir)
     IF l_oIniReg.GetINIEntry(@l_cData, "System", "hoteldir", l_cIniLoc) = ERROR_SUCCESS
          IF NOT EMPTY(l_cData)
               _screen.oGlobal.choteldir = ADDBS(ALLTRIM(LOWER(l_cData)))
          ENDIF
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "hotel", "vatnr", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.chotelvatnr = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "databasetableprefix", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cdatabasetableprefix = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "multiproper", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lmultiproper = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "ODBC", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lODBC = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "MpStartHotelCode", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           gcHotCode = ALLTRIM(UPPER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "ODBCDSN", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cODBCDSN = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "ODBCDATABASE", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cODBCDatabase = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "ODBCSERVER", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cODBCServer = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "ODBCPORT", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cODBCPort = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "ODBCDRIVERNAME", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cODBCDriverName = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF NOT (_screen.oGlobal.lODBC OR EMPTY(_screen.oGlobal.cODBCDSN) AND (EMPTY(_screen.oGlobal.cODBCDriverName) OR EMPTY(_screen.oGlobal.cODBCServer) OR EMPTY(_screen.oGlobal.cODBCPort))) AND ;
          l_oIniReg.GetINIEntry(@l_cData, "System", "ODBCSYNC", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lODBCSYNC = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "IfcRoomStatIsChar", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lIfcRoomStatIsChar = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "showtabs", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lshowtabs = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "BmsManagerForServer", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lBmsManagerForServer = (LOWER(l_cData)="yes")
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "bmsratecodewithsplits", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lbmsratecodewithsplits = (LOWER(l_cData)="yes")
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "Audit", "AutoBackup", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lAutoBackup = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF _screen.oGlobal.lAutoBackup
     IF l_oIniReg.GetINIEntry(@l_cData, "Audit", "AutoBackupDestination", l_cIniLoc) = ERROR_SUCCESS
          IF NOT EMPTY(l_cData)
                _screen.oGlobal.cAutoBackupDestination = ADDBS(LOWER(l_cData))
          ENDIF
     ENDIF
     IF EMPTY(_screen.oGlobal.cAutoBackupDestination)
          _screen.oGlobal.cAutoBackupDestination = _screen.oGlobal.choteldir + "db_backup"
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "Availability", "BCOccupancyLevel1", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nBCOccupancyLevel1 = &l_cData
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "Availability", "BCOccupancyLevel2", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nBCOccupancyLevel2 = &l_cData
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "Availability", "BCOccupancyLevel3", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nBCOccupancyLevel3 = &l_cData
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "DontAllowArticleDescriptionChange", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lDontAllowArticleDescriptionChange = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "flushforce", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lflushforce = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "comservertempfolder", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.ccomservertempfolder = l_cData
     ENDIF
ENDIF
IF EMPTY(_screen.oGlobal.ccomservertempfolder)
     _screen.oGlobal.ccomservertempfolder = _screen.oGlobal.choteldir + "comtemp"
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "comserveridletime", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           IF VARTYPE(lp_oDeskServer)="O"
                lp_oDeskServer.nSessionIdleTime = VAL(l_cData)
           ENDIF
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "elpay", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lelpay = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "screenminbuttonenabled", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lscreenminbuttonenabled = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "forcestartoverloader", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lforcestartoverloader = IIF(LOWER(l_cData)="yes",.T.,.F.)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "Status", l_cIniLoc) = ERROR_SUCCESS
     _screen.oGlobal.lUgos = (UPPER(l_cData) == "ON")
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "PriceChangeNotAllowed", l_cIniLoc) = ERROR_SUCCESS
     _screen.oGlobal.lUgosPriceChangeNotAllowed = (UPPER(l_cData) == "YES")
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "ImportWorkStation", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosImportWorkStation = ALLTRIM(UPPER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "PatientsImportMask", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosPatientsImportMask = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "ImportPeriod", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nUgosImportPeriod = INT(VAL(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "Logging", l_cIniLoc) = ERROR_SUCCESS
     _screen.oGlobal.lUgosLogging = (UPPER(l_cData) == "YES")
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "LogFileName", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosLogFileName = ALLTRIM(LOWER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "MaxLogFileLength", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nUgosMaxLogFileLength = INT(VAL(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "MaxLogNum", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nUgosMaxLogNum = INT(VAL(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "DefaultRatecode", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosDefaultRatecode = ALLTRIM(l_cData)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "DefaultRoomtype", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosDefaultRoomtype = ALLTRIM(l_cData)
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "DefaultLanguage", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosDefaultLanguage = ALLTRIM(UPPER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "DefaultMarket", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosDefaultMarket = ALLTRIM(UPPER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "ugos", "DefaultSource", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.cUgosDefaultSource = ALLTRIM(UPPER(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "uselanguagetable", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.luselanguagetable = (UPPER(l_cData) == "YES")
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "MyDesk", "webbrowserdesktop", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lwebbrowserdesktop = (UPPER(l_cData) == "YES")
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "MyDesk", "RefreshPeriod", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.nMyDeskRefreshPeriod = INT(VAL(l_cData))
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "exitwhennetworksharelost", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lexitwhennetworksharelost = (UPPER(l_cData) == "YES")
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "usesysdatefrompc", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.lusesysdatefrompc = (UPPER(l_cData) == "YES")
     ENDIF
ENDIF
IF l_oIniReg.GetINIEntry(@l_cData, "System", "useremoteserverforsql", l_cIniLoc) = ERROR_SUCCESS
     IF NOT EMPTY(l_cData)
           _screen.oGlobal.luseremoteserverforsql = (UPPER(l_cData) == "YES")
     ENDIF
ENDIF

_screen.oGlobal.lNewAvailability = (UPPER(ReadINI(l_cIniLoc, [System], [NewAvailability])) == "YES")
_screen.oGlobal.oBuilding.lselectbuildingonlogin = (UPPER(ReadINI(l_cIniLoc, [System], [selectbuildingonlogin])) == "YES")
_screen.oGlobal.cStandardBuilding = ReadINI(l_cIniLoc, [System], [StandardBuilding], [])
_screen.oGlobal.cIfcBeforeReadDataFXP = ReadINI(l_cIniLoc, [interface], [IfcBeforeReadDataFXP], [])
_screen.oGlobal.lManagerRevenueOnlyForClosedBills = (UPPER(ReadINI(l_cIniLoc, [System], [ManagerRevenueOnlyForClosedBills])) == "YES")
_screen.oGlobal.lDontSaveCreditCard = (UPPER(ReadINI(l_cIniLoc, [System], [dontsavecreditcard])) == "YES")
_screen.oGlobal.lAllowConfGroupSplit = (UPPER(ReadINI(l_cIniLoc, [System], [AllowConfGroupSplit])) == "YES")
glAutoGeneratePoints = (UPPER(ReadINI(l_cIniLoc, [System], [autogeneratepoints], [yes])) == "YES")
glAutoDiscount = (UPPER(ReadINI(l_cIniLoc, [System], [autodiscount], [yes])) == "YES")
glOutIfErrorInReport = (UPPER(ReadINI(l_cIniLoc, [System], [OutIfErrorInReport])) == "YES")
_screen.oGlobal.nNumberOfAutobackups = INT(VAL(ReadINI(l_cIniLoc, [Audit], [NumberOfAutobackups], [0])))
_screen.oGlobal.lTableReservationPlans = (UPPER(ReadINI(l_cIniLoc, [System], [TableReservationPlans])) == "YES")
_screen.oGlobal.lAvailabilityShowPrintDialog = (UPPER(ReadINI(l_cIniLoc, [availability], [showprintdialog])) == "YES")
_screen.oGlobal.nAvailabilityShowPrintDialogDefaultDays = INT(VAL(ReadINI(l_cIniLoc, [availability], [showprintdialogdefaultdays], [60])))
_screen.oGlobal.lexternalvouchers = (UPPER(ReadINI(l_cIniLoc, [System], [externalvouchers])) == "YES")
_screen.oGlobal.lspecialfiscalprintermode = (UPPER(ReadINI(l_cIniLoc, [system], [specialfiscalprintermode])) == "YES")
_screen.oGlobal.lAllowBillExport = (UPPER(ReadINI(l_cIniLoc, [bill], [allowbillexport])) == "YES")
_screen.oGlobal.lVehicleRentMode = (UPPER(ReadINI(l_cIniLoc, [System], [VehicleRentMode])) == "YES")
_screen.oGlobal.lVehicleRentModeOffsetInAvailab = (UPPER(ReadINI(l_cIniLoc, [System], [VehicleRentModeOffsetInAvailab])) == "YES")
_screen.oGlobal.lResetBillNumberOnNewYear = (UPPER(ReadINI(l_cIniLoc, [bill], [ResetBillNumberOnNewYear])) == "YES")
_screen.oGlobal.cUpdateNewsURL = ReadINI(l_cIniLoc, [System], [UpdateNewsURL], [])
_screen.oGlobal.lhidebanquetbutton = (UPPER(ReadINI(l_cIniLoc, [System], [hidebanquetbutton])) == "YES")
_screen.oGlobal.larticlenotewithformating = (UPPER(ReadINI(l_cIniLoc, [System], [articlenotewithformating])) == "YES")
_screen.oGlobal.csortroomsonrevenuefromdate = ReadINI(l_cIniLoc, [RoomPlan], [sortroomsonrevenuefromdate], [sysdate()])
_screen.oGlobal.csortroomsonrevenuetodate = ReadINI(l_cIniLoc, [RoomPlan], [csortroomsonrevenuetodate], [sysdate()+7])
_screen.oGlobal.csortroomsonrevenuemaingroups = ReadINI(l_cIniLoc, [RoomPlan], [sortroomsonrevenuemaingroups], [1,2,3,4,5,6,7,8,9])
_screen.oGlobal.lbdarticleactive = (UPPER(ReadINI(l_cIniLoc, [System], [bdarticleactive])) == "YES")
_screen.oGlobal.lfiskaltrustactive = (UPPER(ReadINI(l_cIniLoc, [fiskaltrust], [active])) == "YES")
_screen.oGlobal.lfiskaltrustlog = (UPPER(ReadINI(l_cIniLoc, [fiskaltrust], [log])) == "YES")
_screen.oGlobal.lfiskaltrustuseexternalhttp = (UPPER(ReadINI(l_cIniLoc, [fiskaltrust], [useexternalhttp])) == "YES")
_screen.oGlobal.cfiskaltrusturl = ReadINI(l_cIniLoc, [fiskaltrust], [url], [])
_screen.oGlobal.cfiskaltrustcashboxid = ReadINI(l_cIniLoc, [fiskaltrust], [cashboxid], [])
_screen.oGlobal.cfiskaltrustaccesstoken = ReadINI(l_cIniLoc, [fiskaltrust], [accesstoken], [])
_screen.oGlobal.cfiskaltrustproxy = ReadINI(l_cIniLoc, [fiskaltrust], [proxy], [])
_screen.oGlobal.lLimitInputMaskForRoomName = (UPPER(ReadINI(l_cIniLoc, [system], [limitinputmaskforroomname])) == "YES")
_screen.oGlobal.lAgency = (UPPER(ReadINI(l_cIniLoc, [agency], [active])) == "YES")
_screen.oGlobal.lQrCodeDoorKeyActive = (UPPER(ReadINI(l_cIniLoc, [qrcodedoorkey], [active])) == "YES")
_screen.oGlobal.cQrCodeDoorKeyReservatUserField = LOWER(ReadINI(l_cIniLoc, [qrcodedoorkey], [keyuserfield], []))
_screen.oGlobal.cQrCodeURLReservatUserField = LOWER(ReadINI(l_cIniLoc, [qrcodedoorkey], [urluserfield], []))
_screen.oGlobal.cQrCodeHost = LOWER(ReadINI(l_cIniLoc, [qrcodedoorkey], [host], []))
_screen.oGlobal.cQrCode_twilio_url = ReadINI(l_cIniLoc, [qrcodedoorkey], [twilio_url], [])
_screen.oGlobal.cQrCode_twilio_from_phone = ReadINI(l_cIniLoc, [qrcodedoorkey], [twilio_from_phone], [])
_screen.oGlobal.cQrCode_twilio_sms_message = ReadINI(l_cIniLoc, [qrcodedoorkey], [twilio_sms_message], [])
_screen.oGlobal.cQrCode_twilio_auth = ReadINI(l_cIniLoc, [qrcodedoorkey], [twilio_auth], [])
_screen.oGlobal.cHouseKeepingRoomTypeFilter = ReadINI(l_cIniLoc, [System], [housekeepingroomtypefilter], [])
_screen.oGlobal.cHiInsuranceNoAdrUserField = LOWER(ReadINI(l_cIniLoc, [healthsmartcard], [insurancenoadruserfield], []))
_screen.oGlobal.lHiLog = (UPPER(ReadINI(l_cIniLoc, [healthsmartcard], [log])) == "YES")
_screen.oGlobal.lArchive = (UPPER(ReadINI(l_cIniLoc, [archive], [active])) == "YES")
_screen.oGlobal.nHoldHistResYears = INT(VAL(ReadINI(l_cIniLoc, [archive], [holdhistresyears], [5])))
_screen.oGlobal.lGobdActive = (UPPER(ReadINI(l_cIniLoc, [gobd], [active])) == "YES")
_screen.oGlobal.cGobdDirectory = _screen.oGlobal.cHotelDir+LOWER(ReadINI(l_cIniLoc, [gobd], [directory], [gobd]))
_screen.oGlobal.dGobdFromsysdate = CTOD(ReadINI(l_cIniLoc, [gobd], [fromsysdate], "{}"))
_screen.oGlobal.cGobdAddress_globalid = ReadINI(l_cIniLoc, [gobd], [address_globalid], [])
_screen.oGlobal.cGobdArticle_globalid = ReadINI(l_cIniLoc, [gobd], [article_globalid], [])
_screen.oGlobal.lSqlCursorErrorIgnore = (UPPER(ReadINI(l_cIniLoc, [system], [sqlcursorerrorignore])) == "YES")
RETURN .T.
ENDPROC
*
PROCEDURE MainSetPath
LPARAMETERS lp_cDatabaseDir
LOCAL l_cPath, l_cDataPath, l_cReportPath, l_cDotPath

* Add path to database
DO CASE
     CASE PCOUNT()>0 AND NOT EMPTY(lp_cDatabaseDir)
          gcDatadir = lp_cDatabaseDir
     CASE glTraining
          gcDatadir = APP_TRAINING_FOLDER
     CASE TYPE("g_setremotepath")=="C" AND NOT EMPTY(g_setremotepath)
          gcDatadir = LOWER(g_setremotepath)
     CASE NOT EMPTY(_screen.oGlobal.cdatabasedir)
          gcDatadir = _screen.oGlobal.cdatabasedir
     CASE NOT EMPTY(_screen.oGlobal.choteldir)
          gcDatadir = _screen.oGlobal.choteldir + "data"
     OTHERWISE
          gcDatadir = "data"
ENDCASE

gcDatadir = ADDBS(gcDatadir)

* Add path for reports, dots and documents
IF EMPTY(_screen.oGlobal.choteldir)
     IF NOT EMPTY(_screen.oGlobal.creportdir)
          gcReportdir = _screen.oGlobal.creportdir
     ENDIF
     IF NOT EMPTY(_screen.oGlobal.ctemplatedir)
          gcTemplatedir = _screen.oGlobal.ctemplatedir
     ENDIF
ELSE
     gcReportdir = _screen.oGlobal.choteldir + "report"
     gcTemplatedir = _screen.oGlobal.choteldir + "dot"
     gcDocumentdir = _screen.oGlobal.choteldir + "document"
     _screen.oGlobal.creportresultsdir = _screen.oGlobal.choteldir + "reportresults"
ENDIF
gcReportdir = ADDBS(gcReportdir)
gcTemplatedir = ADDBS(gcTemplatedir)
gcDocumentdir = ADDBS(gcDocumentdir)
_screen.oGlobal.chtmldir = ADDBS(FULLPATH(_screen.oGlobal.choteldir + "html"))

l_cDataPath = LEFT(gcDatadir,LEN(gcDatadir)-1)
l_cReportPath = LEFT(gcReportdir,LEN(gcReportdir)-1)
l_cDotPath = LEFT(gcTemplatedir,LEN(gcTemplatedir)-1)

SET PATH TO l_cDataPath + "; " + l_cReportPath + "; " + l_cDotPath + "; tpos; forms; bitmap; include; libs; progs; " + ;
    "common\progs; common\libs; common\forms; common\dll; common\ffc; common\misc\xfrxlib; common\misc\ctl32; " + ;
    "common\misc\sfwtreeview"
    
g_initpath = SET("Path")
RETURN .T.
ENDPROC
*
PROCEDURE MainCleanUp
IF TYPE("frmsplash") = "O"
     frmsplash.Release()
     RELEASE frmsplash
ENDIF
IF TYPE("_screen.oGlobal.oStatusBar") = "O" AND TYPE("_screen.statusBar") = "O"
     _screen.oGlobal.oStatusBar.RemoveIt()
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE MainQuit
TRY
     MainCleanUp()
     CleanUp()
CATCH
ENDTRY
ON SHUTDOWN
QUIT
ENDPROC
*
PROCEDURE MainPrepareData
LOCAL l_oCa AS cabase OF common\libs\cit_ca.vcx

IF openfiledirect(.F.,"param","",gcDatadir)
     sqlcursor("SELECT * FROM param", "caparam")
     CFCursorNullsRemove(.T.,"caparam")
ENDIF
IF openfiledirect(.F.,"param2","",gcDatadir)
     * In old Versions, param2 perhaps don't exist!
     sqlcursor("SELECT * FROM param2", "caparam2")
     CFCursorNullsRemove(.T.,"caparam2")
ENDIF

openfile(.F.,"picklist")

*!*     l_oCa = CREATEOBJECT("caparam")
*!*     l_oCa.ldontfill = .F.
*!*     l_oCa.lgetallfields = .T.
*!*     l_oCa.CursorFill()
*!*     l_oCa.CursorDetach()

*!*     l_oCa = CREATEOBJECT("caparam2")
*!*     l_oCa.ldontfill = .F.
*!*     l_oCa.lgetallfields = .T.
*!*     l_oCa.CursorFill()
*!*     l_oCa.CursorDetach()

ENDPROC
*
PROCEDURE MainPrepareDataClose
dclose("capicklist")
dclose("caparam")
dclose("caparam2")
dclose("param")
dclose("param2")
dclose("picklist")
dclose("files")
dclose("fields")
ENDPROC
*
PROCEDURE MainGetExeNameAndPath
LOCAL l_nModuleHandle, l_cFileName, l_nSize

IF _VFP.StartMode = 0
     l_cFileName = FULLPATH(_screen.oGlobal.cHotelDir+"citadel.exe")
ELSE
     DECLARE INTEGER GetModuleFileName IN Win32API AS waGetModuleFileName INTEGER hModule, STRING @lpFilename, INTEGER nSize

     l_nModuleHandle = 0
     l_cFileName = SPACE(256)
     l_nSize = waGetModuleFileName(l_nModuleHandle, @l_cFileName, LEN(l_cFileName))
ENDIF

RETURN ALLTRIM(l_cFileName)
ENDPROC
*
DEFINE CLASS cFormsHandler AS Custom
*
nhWnd = 0
cLastFormName = " "
cLastFormCustomName = " "
loToolbarHnd = .NULL.
*
PROCEDURE FormAdd
LPARAMETERS lp_oFormRef
IF _screen.oGlobal.lshowtabs
     BINDEVENT(lp_oFormRef.HWnd, WM_SHOWWINDOW, this, "FormEvent")
     BINDEVENT(lp_oFormRef.HWnd, WM_SETTEXT, this, "FormEvent")
     BINDEVENT(lp_oFormRef.HWnd, WM_SETFOCUS, this, "FormEvent")
     BINDEVENT(lp_oFormRef.HWnd, WM_KILLFOCUS, this, "FormEvent")
     BINDEVENT(lp_oFormRef.HWnd, WM_DESTROY, this, "FormEvent")
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE FormEvent
LPARAMETERS hWnd as Integer, Msg as Integer, wParam as Integer, lParam as Integer
LOCAL lnOldProc, l_lResVisible, l_lExists, l_oForm AS Form
this.nhWnd = hWnd

*!*     STRTOFILE(TRANSFORM(DATETIME())+" hWnd:" + TRANSFORM(hWnd) + " Msg:" + ;
*!*               TRANSFORM(Msg) + " wParam:" + TRANSFORM(wParam) + ;
*!*               " lParam:" + TRANSFORM(lParam)+CHR(13),"windows.log",1)

l_lResVisible = .NULL.
DO CASE
     CASE Msg = WM_SHOWWINDOW
          IF wParam=0
               l_lResVisible = .F.
          ELSE
               l_lResVisible = .T.
          ENDIF
     CASE Msg = WM_SETTEXT
          l_lResVisible = this.FormRefreshCaption()
     CASE Msg = WM_KILLFOCUS
          l_lResVisible = .T.
     CASE Msg = WM_SETFOCUS
          l_lResVisible = .T.
     CASE Msg = WM_DESTROY
          l_lResVisible = .F.
          UNBINDEVENTS(hWnd)

ENDCASE
IF VARTYPE(l_lResVisible)="L"
     IF l_lResVisible
          this.AddToTab()
     ELSE
          this.RemoveFromTab()
     ENDIF
ENDIF
lnOldProc = GetWindowLong(_screen.hWnd, GWL_WNDPROC)
RETURN CallWindowProc(lnOldProc, hWnd, Msg, wParam, lParam)
ENDPROC
*
PROCEDURE AddToTab
LPARAMETERS lp_nhWnd
LOCAL l_cbtn, l_cMacro, l_oForm, l_oFormRef AS Form, l_lFormIsModal
IF NOT _screen.oGlobal.lshowtabs OR g_lUseNewRepPreview AND glInreport    && If error in report than shows wrong error message.
     RETURN .T.
ENDIF
IF EMPTY(lp_nhWnd)
     lp_nhWnd = this.nhWnd
ENDIF
IF VARTYPE(g_oTabsToolBar)="O" AND VARTYPE(lp_nhWnd)="N"
     l_oFormRef = .NULL.
     FOR EACH l_oForm IN _screen.Forms
          DO CASE
               CASE VARTYPE(l_oForm) <> "O"
               CASE TYPE("l_oForm.hWnd") <> "N"
                    LOCAL l_oErr
                    STRTOFILE(DTOC(DATE())+" "+TIME()+" "+WinPC()+" "+IIF(TYPE("g_userid")="C",g_userid,"@")+CRLF, "Hotel.Err", .T.)
                    TRY
                         STRTOFILE("l_oForm: "+PADR(TRANSFORM(l_oForm),15), "Hotel.Err", .T.)
                    CATCH TO l_oErr
                         STRTOFILE("l_oForm: "+l_oErr.Details+" ("+TRANSFORM(l_oErr.ErrorNo)+"-"+l_oErr.Message+")", "Hotel.Err", .T.)
                    ENDTRY
                    TRY
                         STRTOFILE("; HWND: "+PADR(TRANSFORM(l_oForm.hWnd),15), "Hotel.Err", .T.)
                    CATCH TO l_oErr
                         STRTOFILE("; HWND: "+l_oErr.Details+" ("+TRANSFORM(l_oErr.ErrorNo)+"-"+l_oErr.Message+")", "Hotel.Err", .T.)
                    ENDTRY
                    TRY
                         STRTOFILE("; BASECLASS: "+PADR(TRANSFORM(l_oForm.BaseClass),15), "Hotel.Err", .T.)
                    CATCH TO l_oErr
                         STRTOFILE("; BASECLASS: "+l_oErr.Details+" ("+TRANSFORM(l_oErr.ErrorNo)+"-"+l_oErr.Message+")", "Hotel.Err", .T.)
                    ENDTRY
                    TRY
                         STRTOFILE("; CLASS: "+PADR(TRANSFORM(l_oForm.Class),15), "Hotel.Err", .T.)
                    CATCH TO l_oErr
                         STRTOFILE("; CLASS: "+l_oErr.Details+" ("+TRANSFORM(l_oErr.ErrorNo)+"-"+l_oErr.Message+")", "Hotel.Err", .T.)
                    ENDTRY
                    TRY
                         STRTOFILE("; NAME: "+PADR(TRANSFORM(l_oForm.Name),15), "Hotel.Err", .T.)
                    CATCH TO l_oErr
                         STRTOFILE("; NAME: "+l_oErr.Details+" ("+TRANSFORM(l_oErr.ErrorNo)+"-"+l_oErr.Message+")", "Hotel.Err", .T.)
                    ENDTRY
                    STRTOFILE(CRLF+CRLF+CRLF, "Hotel.Err", .T.)
               CASE l_oForm.hWnd = lp_nhWnd
                    l_oFormRef = l_oForm
               OTHERWISE
          ENDCASE
     ENDFOR
     l_oForm = .NULL.

     IF VARTYPE(l_oFormRef)="O"
          IF NOT EMPTY(l_oFormRef.Name) AND l_oFormRef.Name <> this.cLastFormName
               this.cLastFormName = l_oFormRef.Name
               this.cLastFormCustomName = IIF(TYPE("l_oFormRef.formname")="C",l_oFormRef.formname,"")
          ENDIF
          l_cbtn = "cmd" + TRANSFORM(lp_nhWnd,"@0")
          IF NOT PEMSTATUS(g_oTabsToolBar,l_cbtn,5)
               g_oTabsToolBar.NewObject(l_cbtn,"foxtabcontrol","cit_formtabs.vcx")
               l_cMacro = "g_oTabsToolBar."+l_cbtn
               IF VARTYPE(this.loToolbarHnd)="O"
                    * Ups, we have already disabled toolars. It can be, from modal form is called anorher form.
                    * In that case, enable only toolbar for form buttons.
                    this.loToolbarHnd.EnableToolbars(.T.)
               ELSE
                    l_lFormIsModal = (l_oFormRef.WindowType = 1)
                    IF l_lFormIsModal
                         this.loToolbarHnd = NEWOBJECT("ctoolbarhnd","proctoolbar.prg")
                         this.loToolbarHnd.DisableToolbars()
                         IF TYPE("l_oFormRef.ldontdisableformtoolbar")="L" AND l_oFormRef.ldontdisableformtoolbar
                              this.loToolbarHnd.EnableToolbars(.T.)
                         ENDIF
                    ENDIF
               ENDIF
               &l_cMacro..SetWindowName(l_oFormRef.Caption,l_oFormRef.Icon,, l_lFormIsModal)
               &l_cMacro..Visible=.T.
          ENDIF
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE RemoveFromTab
LOCAL l_cbtn, l_cTmrName, l_cMacro
IF VARTYPE(g_oTabsToolBar)="O" AND VARTYPE(this.nhWnd)="N"
     l_cbtn = "cmd" + TRANSFORM(this.nhWnd,"@0")
     IF PEMSTATUS(g_oTabsToolBar,l_cbtn,5)
          l_cMacro = "g_oTabsToolBar."+l_cbtn
          IF &l_cMacro..lFormIsModal
               TRY
                    this.loToolbarHnd.EnableToolbars()
                    this.loToolbarHnd = .NULL.
               CATCH
               ENDTRY
          ENDIF
          g_oTabsToolBar.RemoveObject(l_cbtn)
     ENDIF
     l_cTmrName = "otmr" + TRANSFORM(this.nhWnd,"@0")
     IF TYPE("this."+l_cTmrName)="O"
          this.RemoveObject(l_cTmrName)
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE FormRefreshCaption
LPARAMETERS lp_oFormRef
LOCAL l_cMacro, l_oFormRef, l_oForm, l_lSuccess
IF _screen.oGlobal.lshowtabs
     IF VARTYPE(lp_oFormRef)="O"
          l_oFormRef = lp_oFormRef
     ELSE
          l_oFormRef = .NULL.
          FOR EACH l_oForm IN _screen.Forms
               IF VARTYPE(l_oForm)="O" AND l_oForm.HWnd = this.nhWnd
                    l_oFormRef = l_oForm
                    EXIT
               ENDIF
          ENDFOR
          l_oForm = .NULL.
     ENDIF
     IF VARTYPE(l_oFormRef)="O" AND VARTYPE(g_oTabsToolBar)="O"
          l_cbtn = "cmd" + TRANSFORM(l_oFormRef.HWnd,"@0")
          IF PEMSTATUS(g_oTabsToolBar,l_cbtn,5)
               l_cMacro = "g_oTabsToolBar."+l_cbtn
               &l_cMacro..SetWindowName(l_oFormRef.Caption,l_oFormRef.Icon)
               &l_cMacro..Refresh()
               l_lSuccess = .T.
          ENDIF
     ENDIF
ENDIF
l_oFormRef = .NULL.
lp_oFormRef = .NULL.
RETURN l_lSuccess
ENDPROC
*
PROCEDURE GetCaption
LPARAMETERS lp_cCaption
RETURN ALLTRIM(LEFT(lp_cCaption,15)) + IIF(LEN(lp_cCaption)>15,"..","")
ENDPROC
*
ENDDEFINE
*