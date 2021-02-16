*
#INCLUDE "include\constdefines.h"
*
 PRIVATE nhEight
 PRIVATE ni
 PRIVATE cmAcro
 PRIVATE nsElection
 PRIVATE lrEplaceuser
 PRIVATE nwIdth
 PRIVATE ncOunt
 PRIVATE nfIeld
 PRIVATE acPaytype
 PRIVATE noRder
 PRIVATE acUser
 PRIVATE alGroup
 DIMENSION alGroup[10]
 DIMENSION acPaytype[6]
 DIMENSION acUser[6]
 LOCAL i, lExpire, l_omyshell, caPpversion

 ********** Just add new module here and in Setup in procdeskserver!!! **********
 _screen.AddProperty("liclist", "KT,DV,DP,GS,BG,TG,B2,US,OL,OR,AZE,TP,IP,IK,IT,IS,EI,SA,APS,BMS,GD,GO,BRO")
 FOR i = 1 TO GETWORDCOUNT(_screen.liclist,",")
     _screen.AddProperty(GETWORDNUM(_screen.liclist,i,","),.F.)
 NEXT
 ********************************************************************************
 *                                                                              *
 * DONT FORGET TO ADD NEW MODULE IN HIDDEN PROCEDURE Setup in procdeskserver!!! *
 *                                                                              *
 ********************************************************************************

 STORE .T. to omapi, ocalendar
 g_Rptlng = ''
 g_Rptlngnr = ''
 glInreport = .F.
 glErrorinreport = .F.
 glDepositflag = .F.
 glPrgerror = .F.
 glCheckout = .F.
 g_auditactive = .F.
 STORE "" TO acUser
 llOgin = .T.
 nbUttonheight = 1.5
 nwIdth = 0
 nhEight = 0
 = scReensize(nwIdth,nhEight)
 gnTworowoffset = 2.25
 gnOnerowoffset = 0.5
 gnReseroffset = 0
 gcCompany1 = "Citadel"
 gcCompany2 = "Hotelsoftware GmbH"
 g_Hotel = gcApplication+" "+"Demo"+" "+"Hotel"+" "+"Warendorf"
 g_lFakeResAndPost = .F.
 g_oMsgHandler = .NULL.
 g_oTmrLogOut = .NULL.
 g_oTmrRelease = .NULL.
 g_oNavigPane = .NULL.
 g_dBillDate = {}
 g_oPredefinedColors = CREATEOBJECT("CColorTunnel")
 lnEterror = .F.
 lsYserror = .F.
 cuSerid = ""
 gcButtonfunction = ""
 g_Usergroup = ""
 g_Cashier = 0
 gcCashier = ""
 g_Billnum = ""
 g_Billname = ""
 g_Billstyle = 1
 g_UseBDateInStyle = .F.
 g_Demo = .T.
 g_Lite = .F.
 g_Userid = "SETUP"
 crEaderror = ""
 roomplanactive = .F.
 caPpversion = " "+ALLTRIM(STRTRAN(STR(_screen.oGlobal.oParam.pa_version,7,2),",","."))+"."+TRANSFORM(g_build)
 gcCopyright = "Copyright "+CHR(169)+" 1995/"+STR(MAX(YEAR(DATE()),2004),4) +" Citadel " + IIF(_screen.oGlobal.lUgos,"Schlingmeier + Partner KG","Deutschland")

 _DBLCLICK = IIF(_screen.oGlobal.oParam.pa_dbclick<0.25, 0.25, _screen.oGlobal.oParam.pa_dbclick)
 SET SYSMENU TO
 SET SYSMENU AUTOMATIC
 SET HELP ON
 
 SetupPrepareData()
 
 SetupAppSettings()
 
 SetupAdjustTitle(caPpversion)

 SetupEnviroment()

 SetupSuperUser()
 
 = enIgma(@g_Demo,@g_Lite,@g_Hotel,@lExpire)
 IF (g_Demo)
      IF _screen.oGlobal.oParam.pa_expd2
           = msGbox("Error 0111",gcApplication,016)
          * Abort, Error 111
           RETURN .F.
      ELSE
           = msGbox("Limited demo version!"+(CHR(13)+CHR(10))+ ;
             "Maximum 50/150 transactions","Warning",48)
      ENDIF
 ELSE
      IF NOT _screen.oGlobal.oParam.pa_expd2 AND BETWEEN(_screen.oGlobal.oParam.pa_sysdate, _screen.oGlobal.oParam.pa_expires-20, _screen.oGlobal.oParam.pa_expires)
           = alert("Achtung! Lizenz läuft am "+DTOC(_screen.oGlobal.oParam.pa_expires)+" ab!"+CHR(10)+;
            "Warning! Licence would expire on "+DTOC(_screen.oGlobal.oParam.pa_expires)+"!")
      ENDIF
 ENDIF
 IF g_Lite
      MODIFY WINDOW scReen TITLE gcApplication+" Lite"+caPpversion
 ENDIF

 DO seTstatus IN Setup

 g_oTmrRelease = NEWOBJECT("TmrRelease","libs\cit_system.vcx")
 DO InitializeMsgHandler IN procmessages

 SetupPrepareDataClose()

 RETURN .T.
ENDFUNC
*
PROCEDURE SetStatus
 IF g_lAutomationMode
      RETURN .T.
 ENDIF
 LOCAL LDontMainMenu 

 IF !ROOMPLANACTIVE
      for i=1 to _screen.formcount
           IF UPPER(_screen.forms(i).name) = "FWEEKFORM"
                LDontMainMenu = .t.
                EXIT
           ENDIF
      NEXT
 ELSE
      LDontMainMenu = .t.
 ENDIF
 IF NOT LDontMainMenu AND NOT inlogin()
      = maInmenu()
 ENDIF

 SetStatusBarMessage()

 cfIlename = "Help\Help_"+g_Language+".hlp"
 IF (FILE(cfIlename))
      SET HELP TO (cfIlename)
      ON KEY LABEL F1 HELP()
 ENDIF
 cdEfault = SYS(2003)
* LTestDefault = SET("Default")
 LTestDefault = g_setdef
 IF !"\\"$LTestDefault
      SET DEFAULT TO (cdEfault)
*     MESSAGEBOX(SET("Default"))
 ENDIF

 RETURN
ENDPROC
*
FUNCTION SetupEnviroment
 PRIVATE csEp1000

 ***** Create OLE Components
 LOCAL LPath, ceRror, Ldef, Lole, l_lShowErrors
 ceRror = ON('error')
 LPath = SET("Path")
 Lole = SYS(5)+SYS(2003)+"\omapierr"
 Ldef = SYS(5)+SYS(2003)
 _screen.AddProperty("olerr",.F.)
 ON ERROR DO (Lole) WITH ERROR(), MESSAGE()
 form1 = CREATEOBJECT("form")
 form1.AddObject("olemapiseasson1","olemapiseasson")
 *omapi = GETOBJECT("olemapiseasson")
 l_lShowErrors = g_debug AND NOT g_lDevelopment
 IF _screen.olerr
      omapi = .F.
      IF l_lShowErrors
           MESSAGEBOX("Missing system file: MSMAPI32.OCX",64,GetLangText("RECURRES","TXT_INFORMATION"))
      ENDIF
      _screen.olerr = .F.
 ELSE
     *omess = GETOBJECT("olemapimessages")
      form1.AddObject("olemapimessages1","olemapimessages")
      IF _screen.olerr
           omapi = .F.
           IF l_lShowErrors
                MESSAGEBOX(GetLangText("COMMON","T_MISSINGFILE")+": MSMAPI32.OCX",64,GetLangText("RECURRES","TXT_INFORMATION"))
           ENDIF
      ENDIF
 ENDIF
 _screen.olerr = .F.
 form1.AddObject("olecal1","_olecalendar")
 IF _screen.olerr
      ocalendar = .F.
      IF l_lShowErrors
           MESSAGEBOX("Missing system file: MSCOMCT2.OCX",64,GetLangText("RECURRES","TXT_INFORMATION"))
      ENDIF
      _screen.olerr = .F.
 ENDIF
 l_omyshell = CreateObject("WScript.Shell")
 IF _screen.olerr
      IF l_lShowErrors
           MESSAGEBOX("Missing system file: WSHOM.OCX"+CHR(13)+"Please install Windows Scripting Host on your system.",64,GetLangText("RECURRES","TXT_INFORMATION"))
      ENDIF
      _screen.olerr = .F.
 ENDIF
 _screen.olerr = .F.
 RELEASE form1
 on error &cError  && restore system error handler
 SET path to (LPath)
 SET DEFAULT TO (Ldef)
 *****
 *DO "progs\defineclass"
 IF NOT g_debug
      SET BELL OFF
      SET RESOURCE OFF
 ENDIF
 SET COLOR TO
 IF glTraining
      SET COLOR OF SCHEME 1 TO RGB(0,0,0,255,255,128),,,,,,,, RGB(0,0,0,255,255,128), RGB(128,128,128,255,255,128)
 ELSE
      SET COLOR OF SCHEME 1 TO RGB(0,0,0,192,192,192),,,,,,,, RGB(0,0,0,192,192,192), RGB(128,128,128,192,192,192)
 ENDIF
 ON READERROR =WHATREAD()
 ON SHUTDOWN = checkwin("CLEANUP", .T., .T.)
 IF (opEnfile(.F.,"Param"))
      IF g_debug
           *SET ESCAPE ON
           ON KEY LABEL ALT+X DO CLEANUP
      ELSE
           SET ESCAPE OFF
      ENDIF
      DO setsystempoint IN ini
      IF SET('point')=','
           SET SEPARATOR TO '.'
           csEp1000 = '.'
      ELSE
           SET SEPARATOR TO ','
           csEp1000 = ','
      ENDIF
      IF (_screen.oGlobal.oParam.pa_currdec>0)
           gcCurrcy = RIGHT(REPLICATE("9", 16)+"."+REPLICATE("9",  ;
                      _screen.oGlobal.oParam.pa_currdec), 16)
           gcCurrcydisp = gcCurrcy
      ELSE
           gcCurrcy = REPLICATE("9", 16)
           gcCurrcydisp = REPLICATE("999"+csEp1000, 4)+"999"
      ENDIF
 ENDIF
* SET SYSFORMATS ON
* Get common settings from default datasession, and use it in private datasessions
_screen.oGlobal.cSetCurrencyPosition = SET("Currency")
_screen.oGlobal.cSetCurrencySign = SET("Currency",1)
_screen.oGlobal.nSetDecimals = SET("Decimals")
_screen.oGlobal.nSetHours = SET("Hours")
_screen.oGlobal.cSetSeparator = SET("Separator")
 RETURN .T.
ENDFUNC
*
FUNCTION ScreenSize
 PARAMETER nwIdth, nhEight
 PRIVATE nsIze
 PUBLIC g_Nscreenmode
 nsIze = SYSMETRIC(1)
 DO CASE
      CASE nsIze==640
           nwIdth = 105
           nhEight = 27
           g_Nscreenmode = 1
      CASE nsIze==800
           nwIdth = 132
           nhEight = 34.5
           g_Nscreenmode = 2
      CASE nsIze==1024
           nwIdth = 132
           nhEight = 34.5
           g_Nscreenmode = 3
      OTHERWISE
           nwIdth = 132
           nhEight = 34.5
           g_Nscreenmode = 0
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION SetupSuperUser
 LOCAL l_oCaUser AS cabase OF common\libs\cit_ca.vcx, l_oCaGroup AS cabase OF common\libs\cit_ca.vcx, l_nSelect, l_cAllOn

 l_cAllOn = REPLICATE("1",16)
 l_nSelect = SELECT()

 l_oCaGroup = NEWOBJECT("cagroup","progs\cadefdesk.prg")
 l_oCaGroup.cfilterclause = "gr_group="+sqlcnv("SUPERVISOR",.T.)
 l_oCaGroup.CursorFill()

 l_oCaUser = NEWOBJECT("causer","progs\cadefdesk.prg")
 l_oCaUser.cfilterclause = "us_id="+sqlcnv("SUPERVISOR",.T.)
 l_oCaUser.CursorFill()

 IF NOT (USED("cagroup") AND USED("causer"))
      SELECT (l_nSelect)
      RETURN .F.
 ENDIF
 SELECT cagroup

 SCATTER NAME _screen.oGlobal.oGroup MEMO BLANK

 IF RECCOUNT()=0
      APPEND BLANK
      REPLACE gr_group WITH "SUPERVISOR"
 ENDIF

 * Must update SUPERVISOR group?
 IF cagroup.gr_file <> l_cAllOn OR ;
    cagroup.gr_financ <> l_cAllOn OR ;
    cagroup.gr_maint <> l_cAllOn OR ;
    cagroup.gr_other <> l_cAllOn OR ;
    cagroup.gr_report <> l_cAllOn OR ;
    cagroup.gr_view <> l_cAllOn OR ;
    cagroup.gr_manager <> l_cAllOn OR ;
    cagroup.gr_reserva <> l_cAllOn OR ;
    cagroup.gr_address <> l_cAllOn OR ;
    cagroup.gr_interfa <> l_cAllOn OR ;
    cagroup.gr_extra <> l_cAllOn OR ;
    cagroup.gr_butrese <> l_cAllOn OR ;
    cagroup.gr_butplan <> l_cAllOn OR ;
    cagroup.gr_butrscr <> l_cAllOn OR ;
    cagroup.gr_butrled <> l_cAllOn OR ;
    cagroup.gr_butgrou <> l_cAllOn OR ;
    cagroup.gr_butaddr <> l_cAllOn OR ;
    cagroup.gr_butuser <> l_cAllOn OR ;
    cagroup.gr_butbill <> l_cAllOn OR ;
    cagroup.gr_butrate <> l_cAllOn OR ;
    cagroup.gr_butcout <> l_cAllOn OR ;
    cagroup.gr_butadd2 <> l_cAllOn OR ;
    cagroup.gr_allott <> l_cAllOn OR ;
    cagroup.gr_btcout2 <> l_cAllOn OR ;
    cagroup.gr_conplan <> l_cAllOn OR ;
    cagroup.gr_condayp <> l_cAllOn OR ;
    cagroup.gr_aze <> l_cAllOn OR ;
    cagroup.gr_multipr <> l_cAllOn OR ;
    cagroup.gr_buthous <> l_cAllOn

      REPLACE gr_file WITH l_cAllOn, ;
              gr_financ WITH l_cAllOn, ;
              gr_maint WITH l_cAllOn, ;
              gr_other WITH l_cAllOn, ;
              gr_report WITH l_cAllOn, ;
              gr_view WITH l_cAllOn, ;
              gr_manager WITH l_cAllOn, ;
              gr_reserva WITH l_cAllOn, ;
              gr_address WITH l_cAllOn, ;
              gr_interfa WITH l_cAllOn, ;
              gr_extra WITH l_cAllOn, ;
              gr_butrese WITH l_cAllOn, ;
              gr_butplan WITH l_cAllOn, ;
              gr_butrscr WITH l_cAllOn, ;
              gr_butrled WITH l_cAllOn, ;
              gr_butgrou WITH l_cAllOn, ;
              gr_butaddr WITH l_cAllOn, ;
              gr_butuser WITH l_cAllOn, ;
              gr_butbill WITH l_cAllOn, ;
              gr_butrate WITH l_cAllOn, ;
              gr_butcout WITH l_cAllOn, ;
              gr_butadd2 WITH l_cAllOn, ;
              gr_allott WITH l_cAllOn, ;
              gr_btcout2 WITH l_cAllOn, ;
              gr_conplan WITH l_cAllOn, ;
              gr_condayp WITH l_cAllOn, ;
              gr_aze WITH l_cAllOn, ;
              gr_multipr WITH l_cAllOn, ;
              gr_buthous WITH l_cAllOn
     l_oCaGroup.DoTableUpdate(.F.)
     EndTransaction()
 ENDIF

 SELECT causer

 SCATTER NAME _screen.oGlobal.oUser MEMO BLANK

 IF RECCOUNT()>1
      * Only one superuser allowed!
      DELETE ALL
      l_oCaUser.DoTableUpdate(.T.)
      EndTransaction()
      l_oCaUser.CursorFill()
 ENDIF

 SELECT causer
 IF RECCOUNT()=0
      APPEND BLANK
      REPLACE us_id WITH "SUPERVISOR"
 ENDIF

 IF us_cashier <> 1 OR us_group <> "SUPERVISOR" OR us_lang <> _screen.oGlobal.oParam.pa_lang OR ;
      ALLTRIM(us_name) <> "Support" OR us_pass <> SYS(2007, REPLICATE(CHR(255), 10)) OR ;
      us_inactiv

     REPLACE us_cashier WITH 1, ;
              us_group WITH "SUPERVISOR", ;
              us_lang WITH _screen.oGlobal.oParam.pa_lang, ;
              us_name WITH "Support", ;
              us_pass WITH SYS(2007, REPLICATE(CHR(255), 10)), ;
              us_inactiv WITH .F.
     l_oCaUser.DoTableUpdate(.F.)
     EndTransaction()

 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDFUNC
*
PROCEDURE SetupAdjustTitle
 LPARAMETERS lp_cVersion, _LCaption
 IF (g_debug)
      _screen.Icon = "bitmap\icons\tools.ico"
      _screen.Caption = "Dev. ("+SYS(5)+SYS(2003)+") "+gcApplication+lp_cVersion
      _screen.FontName = "Arial"
      _screen.FontSize = 10
 ELSE
      _screen.ForeColor = RGB(0,0,0)
      DO CASE
           CASE FILE("demo.go")
                _LCaption = gcApplication + " Version 10.X"
           CASE _screen.oGlobal.lUgos
                _LCaption = MACNETIX_CAPTION + lp_cVersion
           OTHERWISE
                _LCaption = ReadINI(FULLPATH(INI_FILE), [System], [AddInMainTitle])
                _LCaption = IIF(EMPTY(_LCaption), "", "*" + _LCaption + "* ") + gcApplication + lp_cVersion
      ENDCASE
      IF g_lSpecialVersion
           _LCaption = _LCaption+"*"
      ENDIF
      _Screen.FontName = "Arial"
      _Screen.FontSize = 10
      _Screen.ControlBox = .T.
      IF NOT _screen.oGlobal.lscreenminbuttonenabled
           _Screen.MaxButton = .F.
      ENDIF
      _Screen.MinButton = .T.
      _Screen.Closable = .T.
      _Screen.Icon = "bitmap\Erase02.ico"
      _Screen.Caption = _LCaption
 ENDIF

 IF glTraining
      _screen.Caption = ">>> TRAINING *** TRAINING *** TRAINING <<<  "+_screen.Caption
      _screen.AddObject("LTraining","label")
      _screen.ltraining.backstyle = 0
      _screen.ltraining.caption = "TRAINING VERSION"
      _screen.ltraining.fontsize = 48
      _screen.ltraining.top = 100
      _screen.ltraining.left = 30
      _screen.ltraining.forecolor =  RGB(255,0,0)
      _screen.ltraining.autosize = .t.
      _screen.ltraining.visible = .t.
 ENDIF
 g_initialscreenheight = _screen.Height
 RETURN .T.
ENDPROC
*
PROCEDURE SetupAppSettings
* Put here application settings, which can be made after update.
LOCAL l_nSelect

l_nSelect = SELECT()

* Get email client
IF USED("caemprop") AND NOT EMPTY(caemprop.ep_emtype)
     _screen.oGlobal.emtype = caemprop.ep_emtype
ENDIF

SetupBuildingsCheck()

* Setup terminal and fiscal printer
SELECT caterminal
IF dlocate("caterminal","tm_winname = " + sqlcnv(PADR(winpc(),15)))
     SCATTER NAME _screen.oGlobal.oTerminal MEMO
ELSE
     SCATTER NAME _screen.oGlobal.oTerminal MEMO BLANK
ENDIF
SELECT cafprinter
IF NOT EMPTY(_screen.oGlobal.oTerminal.tm_fpnr) AND ;
          dlocate("cafprinter","fp_fpnr = " + sqlcnv(_screen.oGlobal.oTerminal.tm_fpnr))
     SCATTER NAME _screen.oGlobal.ofprinter MEMO
ELSE
     SCATTER NAME _screen.oGlobal.ofprinter MEMO BLANK
ENDIF

* Get Room Data
_screen.oGlobal.oGData.RoomsRefresh()
_screen.oGlobal.oGData.RoomTypesRefresh()

SELECT(l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE SetupBuildingsCheck
* Are buildings used?
g_lBuildings = _screen.oGlobal.oparam2.pa_buildin
IF NOT g_lBuildings
     _screen.oGlobal.cStandardBuilding = ""
ENDIF
_screen.oGlobal.lVehicleRentMode = _screen.oGlobal.lVehicleRentMode AND g_lBuildings
_screen.oGlobal.lVehicleRentModeOffsetInAvailab = _screen.oGlobal.lVehicleRentModeOffsetInAvailab AND _screen.oGlobal.lVehicleRentMode
RETURN .T.
ENDPROC
*
PROCEDURE SetupPrepareData
LOCAL l_oCa, l_nSelect
l_nSelect = SELECT()
openfile(.F., "building")

l_oCa = NEWOBJECT("cafprinter","progs\cadefdesk.prg")
l_oCa.ldontfill = .F.
l_oCa.CursorFill()
l_oCa.CursorDetach()

l_oCa = NEWOBJECT("caemprop","progs\cadefdesk.prg")
l_oCa.ldontfill = .F.
l_oCa.CursorFill()
l_oCa.CursorDetach()

l_oCa = NEWOBJECT("caterminal","progs\cadefdesk.prg")
l_oCa.ldontfill = .F.
l_oCa.CursorFill()
l_oCa.CursorDetach()
SELECT(l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE SetupPrepareDataClose
dclose("cafprinter")
dclose("caemprop")
dclose("caterminal")
ENDPROC