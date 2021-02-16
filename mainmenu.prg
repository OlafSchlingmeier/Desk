
*******************************************
* Don't forget to change navpanemenu.prg. *
*******************************************

 PRIVATE ALL LIKE l_*
 PRIVATE ldOnt
 PRIVATE ckEyfxp
 LOCAL cfUnction, cnAme, nsEquence, nBar, nButton, cMacro, ltMpargus
 LOCAL caLtkey, l_lpuReportsCreated, l_cCurMenu, l_cExtraCmd
 LOCAL ARRAY acChecks[1]
 IF NOT g_lNoReadEvents
      SET SYSMENU TO
 ELSE
      SET SYSMENU TO _MSM_FILE, _MSM_EDIT, _MSM_VIEW, _MSM_TEXT, _MSM_TOOLS, _MSM_PROG, _MSM_WINDO
 ENDIF
 IF procnavpane("GetProperty","visible")
      navpanemenu()
      RETURN .T.
 ENDIF
 PUBLIC leXtravalid
 #include "include\constdefines.h"
 leXtravalid = .F.
 l_lpuReportsCreated = .F.
 IF (_screen.oGlobal.oParam.pa_mnuextr)
      IF (opEnfile(.F.,"Menu",.f.,.t.))
           l_cCurMenu = sqlcursor("SELECT COUNT(*) AS sres FROM menu")
           IF RECCOUNT(l_cCurMenu)>0 AND &l_cCurMenu..sres > 0
                leXtravalid = .T.
           ELSE
                leXtravalid = .F.
           ENDIF
           dclose(l_cCurMenu)
      ENDIF
      = clOsefile("Menu")
 ENDIF

publicEror = ON("error")
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_FILE"))
 define pad pFile 			of _MSYSMENU prompt GetLangText("MENU", "MNU_FILE") 		key &cAltKey, "" skip FOR InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_RESERVAT"))
 define pad pReservat		of _MSYSMENU prompt GetLangText("MENU", "MNU_RESERVAT")		 	key &cAltKey, "" skip FOR InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_ADDRESS"))
 define pad pAddress			of _MSYSMENU prompt GetLangText("MENU", "MNU_ADDRESS")		   	key &cAltKey, "" skip for InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_FINANCIAL"))
 define pad pFinancial 		of _MSYSMENU prompt GetLangText("MENU", "MNU_FINANCIAL")	key &cAltKey, "" skip for InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_VIEW"))
 define pad pViews			of _MSYSMENU prompt GetLangText("MENU", "MNU_VIEW")      	key &cAltKey, "" skip for InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_OTHER"))
 define pad pOther			of _MSYSMENU prompt GetLangText("MENU", "MNU_OTHER")     	key &cAltKey, "" skip for InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_REPORT"))
 define pad pReports			of _MSYSMENU prompt GetLangText("MENU", "MNU_REPORT")    	key &cAltKey, "" skip for InLogIn()
 IF (_screen.oGlobal.oParam.pa_mnuextr)
      caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_EXTRA"))
      define pad pExtra		of _MSYSMENU Prompt GetLangText("MENU", "MNU_EXTRA")		key &cAltKey, "" skip FOR vExtraValid()
 ENDIF
 IF _screen.oGlobal.lmultiproper
      caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_MULTIPROPER"))
      define pad pMultiproper          of _MSYSMENU prompt GetLangText("MENU", "MNU_MULTIPROPER")                key &cAltKey, "" skip FOR InLogIn()
 ENDIF
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_WINDOW"))
 define pad pWindow OF _MSYSMENU prompt GetLangText("MENU","MNU_WINDOW") 				key &cAltKey, "" skip for InLogin()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_HELP"))
 define pad pHelp			of _MSYSMENU Prompt GetLangText("MENU", "MNU_HELP")      	key &cAltKey, "" skip FOR InLogIn()
 ON PAD pfIle OF _MSYSMENU ACTIVATE POPUP puFile
 ON PAD prEservat OF _MSYSMENU ACTIVATE POPUP puReservat
 ON PAD paDdress OF _MSYSMENU ACTIVATE POPUP puAddress
 ON PAD pfInancial OF _MSYSMENU ACTIVATE POPUP puFinancial
 ON PAD pvIews OF _MSYSMENU ACTIVATE POPUP puViews
 ON PAD poTher OF _MSYSMENU ACTIVATE POPUP puOther
 ON PAD prEports OF _MSYSMENU ACTIVATE POPUP puReports
 IF (_screen.oGlobal.oParam.pa_mnuextr)
      ON PAD peXtra OF _MSYSMENU ACTIVATE POPUP puExtra
 ENDIF
 IF _screen.oGlobal.lmultiproper
      ON PAD pMultiproper OF _MSYSMENU ACTIVATE POPUP puMultiproper
 ENDIF
 ON PAD pWindow OF _MSYSMENU ACTIVATE POPUP puWindow
 ON PAD phElp OF _MSYSMENU ACTIVATE POPUP puHelp
 DEFINE POPUP puFile SHADOW MARGIN RELATIVE
 IF definebar(1,"puFile",GetLangText("MENU","FIL_MAINTENANCE"),"File",1,"","bitmap\icons\tools.ico")
      ON BAR 1 OF puFile ACTIVATE POPUP puMaintenance
 ENDIF
 IF definebar(2,"puFile",GetLangText("MENU","FIL_MANAGER"),"File",2,"","bitmap\toolbar\save.png")
      ON BAR 2 OF puFile ACTIVATE POPUP puManager
 ENDIF
 DEFINE BAR 3 OF puFile PROMPT "\-"
 IF definebar(4,"puFile",GetLangText("MENU","FIL_LOGIN"),"File",3,"","bitmap\toolbar\login.png","F9")
      ON SELECTION BAR 4 OF puFile =LOGMENU("FILE|LOGIN","LOGOUT")
 ENDIF
 IF definebar(5,"puFile",GetLangText("MENU","FIL_PASSWORD"),"File",4,"","bitmap\toolbar\keyboard.png")
      ON SELECTION BAR 5 OF puFile =LOGMENU("FILE|CHANGE PASSWORD", "SETPASSWORD IN PASSWORD")
 ENDIF
 DEFINE BAR 6 OF puFile PROMPT "\-"
 IF definebar(7,"puFile",GetLangText("MENU","FIL_PRTSETUP"),"File",5,"","bitmap\toolbar\print.png")
      ON SELECTION BAR 7 OF puFile =LOGMENU("FILE|PRINTER SETUP",   "PRINTERSETUP IN PRINTER WITH PROMPT()")
 ENDIF
 IF _screen.oGlobal.lfiskaltrustactive
      DEFINE BAR 8 OF puFile PROMPT "\-"
      IF definebar(9,"puFile",GetLangText("MENU","FIL_FISCALMENU"),"File",16,"","bitmap\toolbar\fiskaltrust.png")
           ON SELECTION BAR 9 OF puFile =LOGMENU("FILE|FISKALTRUST",   "FISCALMENU IN PRINTER")
      ENDIF
 ENDIF
 DEFINE BAR 10 OF puFile PROMPT "\-"
 IF definebar(11,"puFile",GetLangText("MENU","FIL_EXIT"),"File",6,"","bitmap\toolbar\exit.png","ALT+F4")
      ON SELECTION BAR 11 OF puFile =LOGMENU("FILE|EXIT","CHECKWIN IN CHECKWIN WITH 'CLEANUP',.T.,.T.")
 ENDIF
 DEFINE POPUP puMaintenance SHADOW MARGIN RELATIVE
 IF definebar(10,"puMaintenance",GetLangText("MENU","MNT_INDEX"),"Maint",1,"","")
      ON SELECTION BAR 10 OF puMaintenance =LOGMENU("FILE|MAINTENANCE|INDEX", "CHECKWIN IN CHECKWIN WITH 'DOINDEX',.F.")
 ENDIF
 IF definebar(20,"puMaintenance",GetLangText("MENU","MNT_AVAILAB"),"Maint",2,"","")
      ON SELECTION BAR 20 OF puMaintenance =LOGMENU("FILE|MAINTENANCE|AVAILABILITY", "CHECKWIN IN CHECKWIN WITH 'REBUILD',.T.")
 ENDIF
 IF _screen.oGlobal.lArchive AND definebar(22,"puMaintenance",GetLangText("MENU","MNT_ARCHIVE"),"Maint",9,"","")
      ON SELECTION BAR 22 OF puMaintenance =LOGMENU("FILE|MAINTENANCE|ARCHIVE", "Archive IN ProcArchive")
 ENDIF
 IF definebar(25,"puMaintenance",GetLangText("MENU","MNT_STATISTIC"),"Maint",7,"","")
      ON SELECTION BAR 25 OF puMaintenance =LOGMENU("FILE|MAINTENANCE|STATISTICS", "STATREFRESH IN AUDIT")
 ENDIF
 IF (_screen.oGlobal.oParam.pa_keyifc .OR. _screen.oGlobal.oParam.pa_posifc .OR. _screen.oGlobal.oParam.pa_pttifc .OR.  ;
    _screen.oGlobal.oParam.pa_ptvifc)
      IF definebar(30,"puMaintenance",GetLangText("MENU","IFC_SYNCHRONISE"),"Maint",3,"","")
           ON SELECTION BAR 30 OF puMaintenance =LOGMENU("FILE|MAINTENANCE|SYNCHRONISE", "SYNCHRONISE IN INTERFAC")
      ENDIF
 ENDIF
 DEFINE BAR 35 OF puMaintenance PROMPT "\-"
 IF definebar(37,"puMaintenance",GetLangText("MENU","MNT_USERLIST"),"Maint",4,"","")
      ON SELECTION BAR 37 OF puMaintenance =LOGMENU("FILE|MAINTENANCE|USER LIST", "USERLIST")
 ENDIF
 DEFINE BAR 39 OF puMaintenance PROMPT "\-"
 IF definebar(40,"puMaintenance",GetLangText("MENU","MNT_ADPURGE"),"Maint",10,"","")
       ON SELECTION BAR 40 OF puMaintenance =LOGMENU("FILE|MAINTENANCE|ADPURGE", "ADPURGE")
 ENDIF
 DEFINE BAR 44 OF puMaintenance PROMPT "\-"
 IF definebar(45,"puMaintenance",GetLangText("MENU","MNT_TRAINING"),"Maint",11, ;
           "OR glTraining OR (AT([TRAINING], UPPER(ALLTRIM(SYS(16))))>0)","")
       ON SELECTION BAR 45 OF puMaintenance DO TrainingVersion
 ENDIF
 IF (g_Usergroup=="SUPERVISOR" .AND. g_Userid=="SUPERVISOR" .AND. ;
          (UPPER(gcApplication)=="CITADEL DESK" OR UPPER(gcApplication)=="MACNETIX@ON-BALANCE" ;
          OR (gcApplication = "Application")))
      DEFINE BAR 50 OF puMaintenance PROMPT GetLangText("MENU","MNT_SUPERVISOR")
      ON BAR 50 OF puMaintenance ACTIVATE POPUP puSupervisor
      DEFINE POPUP puSupervisor SHADOW MARGIN RELATIVE
      DEFINE BAR 35 OF puSupervisor PROMPT GetLangText("MENU","MNT_FORMATREPORT") SKIP FOR g_Userid <> "SUPERVISOR"
      DEFINE BAR 40 OF puSupervisor PROMPT GetLangText("MENU","MNT_RECALCULATE")
      DEFINE BAR 50 OF puSupervisor PROMPT "Debug Mode ON/OFF"
      DEFINE BAR 60 OF puSupervisor PROMPT GetLangText("MENU","MNT_CHECKREPORTS")
      DEFINE BAR 70 OF puSupervisor PROMPT "Activate expanded Error Handler"
*     DEFINE BAR 80 OF puSupervisor PROMPT GetLangText("MENU","MNT_UPDATE_RECORDS_IN_ADDRESS")
      DEFINE BAR 90 OF puSupervisor PROMPT GetLangText("MENU","MNT_SET_GRID")
      DEFINE BAR 100 OF puSupervisor PROMPT GetLangText("MENU","MNT_CALCULATE_STATS")
      DEFINE BAR 110 OF puSupervisor PROMPT GetLangText("MENU","MNT_UPDTBL")
      DEFINE BAR 120 OF puSupervisor PROMPT GetLangText("MENU","MNT_UPDLANG")
      DEFINE BAR 130 OF puSupervisor PROMPT GetLangText("MENU","MNT_UPDLISTS")
      DEFINE BAR 140 OF puSupervisor PROMPT GetLangText("MENU","MNT_UPDREVSTAT")&&"Calculate initial Revnue Statistics"
      DEFINE BAR 150 OF puSupervisor PROMPT GetLangText("MENU","MNT_RESROOMSRBLD")&&"Rebuild Reservation period rooms"
      DEFINE BAR 160 OF puSupervisor PROMPT GetLangText("MENU","MNT_RESRATERBLD")&&"Rebuild Reservation period rates"
      DEFINE BAR 170 OF puSupervisor PROMPT GetLangText("MENU","MNT_HRESRATERBLD")&&"Rebuild History Reservation period rates"
      DEFINE BAR 180 OF puSupervisor PROMPT GetLangText("MENU","MNT_RESRATEFIX")&&"Fix Reservation period rates"
      DEFINE BAR 185 OF puSupervisor PROMPT GetLangText("MENU","MNT_RESSPLITRBLD")&&"Rebuild Reservation post splits"
      DEFINE BAR 190 OF puSupervisor PROMPT GetLangText("MENU","MNT_SET_TABLES_CODE_PAGE")
      DEFINE BAR 200 OF puSupervisor PROMPT GetLangText("MENU","MNT_BLOCK_ALL_USERS")
      DEFINE BAR 210 OF puSupervisor PROMPT "Test Server (citadelsrv.exe)"
      DEFINE BAR 220 OF puSupervisor PROMPT GetLangText("MENU","MNT_UPSIZE_TO_POSTGRESQL") SKIP FOR Odbc() OR ;
           EMPTY(_screen.oGlobal.cODBCDriverName) OR EMPTY(_screen.oGlobal.cODBCServer) OR EMPTY(_screen.oGlobal.cODBCPort)
      DEFINE BAR 230 OF puSupervisor PROMPT "Import from reservat and histres into rsifsync table"
      DEFINE BAR 240 OF puSupervisor PROMPT "Reindex and pack ALL tables (do it on server!)"
      ON SELECTION BAR 35 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|FORMATREPORTS", "FMTFRX IN FMTFRX")
      ON SELECTION BAR 40 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|RECALCULATE", "RECALCMANAGER IN MANAGER")
      ON SELECTION BAR 50 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|DEBUG", "DEBUG IN DEBUG")
      ON SELECTION BAR 60 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|CHECKREPORTS", "CLEANREPORTS")
      ON SELECTION BAR 70 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|ERROR", "ERROR IN DEBUG")
*     ON SELECTION BAR 80 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|UPDATEADDRESS", "UPDATEADDRESS IN DEBUG")
      ON SELECTION BAR 90 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|SETGRID", "SETGRID IN DEBUG")
      ON SELECTION BAR 100 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|CALCSTAT", "CHECKWIN WITH [AaUpd], .T.")
      ON SELECTION BAR 110 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|UPDATETABLES", "UPDATETABLES IN DEBUG")
      ON SELECTION BAR 120 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|UPDATELANG", "UPDATELANG IN DEBUG")
      ON SELECTION BAR 130 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|UPDATELISTS", "UPDATELISTS IN DEBUG")
      ON SELECTION BAR 140 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|CALCSTAT2", "CHECKWIN WITH [OrUpd], .T.")
      ON SELECTION BAR 150 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|RESROOMSREBUILD", "RIREBUILD IN PROCRESROOMS")
      ON SELECTION BAR 160 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|RESRATEREBUILD", "RRREBUILD IN PROCRESRATE WITH .T.")
      ON SELECTION BAR 170 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|HRESRATEREBUILD", "RRREBUILD IN PROCRESRATE WITH .T., .T.")
      ON SELECTION BAR 180 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|RESRATEFIX", "RRREBUILD IN PROCRESRATE WITH .F., .F., .T.")
      ON SELECTION BAR 185 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|RESSPLITREBUILD", "RLREBUILD IN PROCRESRATE WITH .T.")
      ON SELECTION BAR 190 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|SETCODEPAGETOTABLES", "setcodepagetotables IN cpzero")
      ON SELECTION BAR 200 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|DEBUGBLOCKALLUSERS", "DebugBlockAllUsers IN DEBUG")
      ON SELECTION BAR 210 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|TEST_SERVER", "testserver IN DEBUG")
      ON SELECTION BAR 220 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|UPSIZE_PGSQL", "DOUPSIZE IN UPSIZE")
      ON SELECTION BAR 230 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|IMPORT RSIFSYNC", "PRT_Import_All IN procreservattransactions")
      ON SELECTION BAR 240 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|REINDEX WITH PACK ALL", "SupervisorReindex IN doindex")
 ELSE
      IF NOT noUserrights("Maint",12)
           DEFINE BAR 50 OF puMaintenance PROMPT GetLangText("MENU","MNT_SUPERVISOR")
           ON BAR 50 OF puMaintenance ACTIVATE POPUP puSupervisor
           DEFINE POPUP puSupervisor SHADOW MARGIN RELATIVE
           DEFINE BAR 40 OF puSupervisor PROMPT GetLangText("MENU","MNT_RECALCULATE") SKIP FOR noUserrights("Maint",12)
           ON SELECTION BAR 40 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|RECALCULATE", "RECALCMANAGER IN MANAGER")
           DEFINE BAR 210 OF puSupervisor PROMPT "Test Server (citadelsrv.exe)"
           ON SELECTION BAR 210 OF puSupervisor =LOGMENU("FILE|MAINTENANCE|SUPERVISOR|TEST_SERVER", "testserver IN DEBUG")
      ENDIF
 ENDIF
 DEFINE POPUP puManager SHADOW MARGIN RELATIVE
 IF definebar(1,"puManager",GetLangText("MENU","MGR_RESERVAT"),"Manager",1,"","")
      ON BAR 1 OF puManager ACTIVATE POPUP puMgrreservat
 ENDIF
 IF _SCREEN.TG AND definebar(2,"puManager",GetLangText("MENU","MGR_BANQUET"),"Manager",7,"","")
      ON BAR 2 OF puManager ACTIVATE POPUP puMgrbanquet
 ENDIF
 IF definebar(3,"puManager",GetLangText("MENU","MGR_ADDRESS"),"Manager",2,"","")
      ON BAR 3 OF puManager ACTIVATE POPUP puMgraddress
 ENDIF

 IF definebar(4,"puManager",GetLangText("MENU","MGR_FINANCIAL"),"Manager",3,"","")
      ON BAR 4 OF puManager ACTIVATE POPUP puMgrfinancial
 ENDIF
 IF definebar(5,"puManager",GetLangText("MENU","MGR_SYSTEM"),"Manager",4,"","")
      ON BAR 5 OF puManager ACTIVATE POPUP puMgrsystem
 ENDIF
 IF _SCREEN.AZE AND definebar(9,"puManager",GetLangText("MENU","MGR_AZE"),"Manager",8,"","")
      ON BAR 9 OF puManager ACTIVATE POPUP puMgraze
 ENDIF
 IF NOT EMPTY(_screen.oGlobal.oParam2.pa_ciwebdr) AND definebar(10,"puManager",GetLangText("MENU","MGR_CITWEB_SETTINGS"),"Manager",10,"","")
      ON BAR 10 OF puManager ACTIVATE POPUP puMgrcitweb
 ENDIF
 DEFINE BAR 6 OF puManager PROMPT "\-"
 IF definebar(7,"puManager",GetLangText("MENU","MGR_LISTS"),"Manager",5,"","")
      ON SELECTION BAR 7 OF puManager =LOGMENU("FILE|MANAGER|DEFINE REPORTS", "LISTS  WITH 0, PROMPT() IN MYLISTS")
 ENDIF
 IF definebar(8,"puManager",GetLangText("MENU","MGR_BATCHES"),"Manager",6,"","")
      ON SELECTION BAR 8 OF puManager =LOGMENU("FILE|MANAGER|DEFINE BATCHES", "MGRBATCH IN MGRPLIST")
 ENDIF
 DEFINE POPUP puMgrreservat SHADOW MARGIN RELATIVE
 DEFINE BAR 10 OF puMgrreservat PROMPT GetLangText("MENU","MGR_ROOMTYPEDEF")
 DEFINE BAR 15 OF puMgrreservat PROMPT GetLangText("MENU","MGR_ROOMTYPE")
 DEFINE BAR 20 OF puMgrreservat PROMPT GetLangText("MENU","MGR_ROOMNUM")
 IF  .NOT. g_Lite
      DEFINE BAR 30 OF puMgrreservat PROMPT GetLangText("MENU","MGR_FEATURE")
*      IF g_lNewConferenceActive
*           DEFINE BAR 40 OF puMgrreservat PROMPT GetLangText("MENU","MGR_ROOM_PICTURES")
*      ENDIF
*      IF _SCREEN.TG
*           DEFINE BAR 50 OF puMgrreservat PROMPT GetLangText("MENU","MGR_RESOURCE")
*           DEFINE BAR 60 OF puMgrreservat PROMPT GetLangText("MENU","MGR_CONFSTAT")
*           DEFINE BAR 70 OF puMgrreservat PROMPT GetLangText("MENU","MGR_MENU")
*      ENDIF
      DEFINE BAR 80 OF puMgrreservat PROMPT GetLangText("MENU","MGR_DENIAL")
 ENDIF
 DEFINE BAR 90 OF puMgrreservat PROMPT "\-"
 DEFINE BAR 100 OF puMgrreservat PROMPT GetLangText("MENU","MGR_SOURCE")
 DEFINE BAR 110 OF puMgrreservat PROMPT GetLangText("MENU","MGR_MARKET")
 DEFINE BAR 120 OF puMgrreservat PROMPT GetLangText("MENU","MGR_VIRROOM")
 DEFINE BAR 130 OF puMgrreservat PROMPT GetLangText("MENU","MGR_BUILDING")
 IF _screen.EI
      DEFINE BAR 135 OF puMgrreservat PROMPT GetLangText("MENU","MGR_ENERGIE")
 ENDIF
 DEFINE BAR 140 OF puMgrreservat PROMPT "\-"
 DEFINE BAR 150 OF puMgrreservat PROMPT GetLangText("MENU","MGR_SEASON")
 ON SELECTION BAR 10 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|ROOM TYPE DEFS", "ROOMTYPEDEF IN ROOMTYPE")
 ON SELECTION BAR 15 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|ROOM TYPES", "ROOMTYPE")
 ON SELECTION BAR 20 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|ROOM NUMBERS", "MGRROOM 	IN MGRRESER")
 IF  .NOT. g_Lite
      ON SELECTION BAR 30 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|FEATURES", "MGRFEATURE IN MGRPLIST")
*      IF g_lNewConferenceActive
*           ON SELECTION BAR 40 OF puMgrreservat DO FORM 'forms\roompicturesviewerform' WITH 2
*      ENDIF
*      IF _SCREEN.TG
*           ON SELECTION BAR 50 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|RESOURCES", "MGRRESOURCE IN MGRPLIST")
*           ON SELECTION BAR 60 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|RESOURCES", "MGRCONFSTATUS IN MGRPLIST")
*           ON SELECTION BAR 70 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|RESOURCES", "MGRMENU IN MGRPLIST")
*      ENDIF
      ON SELECTION BAR 80 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|RESOURCES", "MGRDENIAL IN MGRPLIST")
 ENDIF
 ON SELECTION BAR 100 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|SOURCE CODES", "MGRSOURCE 	IN MGRPLIST")
 ON SELECTION BAR 110 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|MARKET CODES", "MGRMARKET 	IN MGRPLIST")
 ON SELECTION BAR 120 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|VIRROOM CODES", "MGRVIRROOM IN MGRPLIST")
 ON SELECTION BAR 130 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|BUILDING CODES", "MGRBUILDING IN MGRPLIST")
 IF _screen.EI
      ON SELECTION BAR 135 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|ENERGIE", "MGRENERGIE IN MGRPLIST")
 ENDIF
 ON SELECTION BAR 150 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|SEASONS", "MGRSEASON IN MGRRESER")
********************************
IF _SCREEN.TG AND g_lNewConferenceActive
      DEFINE POPUP puMgrbanquet SHADOW MARGIN RELATIVE
      DEFINE BAR 1 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_CONF_ROOM")
      DEFINE BAR 2 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_CONF_FEATURES")
      DEFINE BAR 3 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_CONF_RANGES")
      DEFINE BAR 5 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_ROOM_PICTURES")
      DEFINE BAR 6 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_RESOURCE")
      DEFINE BAR 7 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_CONFSTAT")
      DEFINE BAR 8 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_MENU")
      DEFINE BAR 9 OF puMgrbanquet PROMPT GetLangText("MENU","MGR_BESTUHLUNG")

      ON SELECTION BAR 1 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|CONFERENCE ROOM NUMBER", "FORM 'forms\MngForm' WITH 'MngConfRnCtrl'")
      ON SELECTION BAR 2 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|CONFERENCE FEATURES", "FORM 'forms\MngForm' WITH 'MngConfFeatCtrl'")
      ON SELECTION BAR 3 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|CONFERENCE RANGE", "FORM 'forms\MngForm' WITH 'MngConfRangeCtrl'")
      ON SELECTION BAR 5 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|CONFERENCE PICTURES", "Doform WITH '','forms\RoomPicturesViewerForm','WITH ,2'")
      ON SELECTION BAR 6 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|RESOURCES", "MGRRESOURCE IN MGRPLIST")
      ON SELECTION BAR 7 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|CONFSTATUS", "MGRCONFSTATUS IN MGRPLIST")
      ON SELECTION BAR 8 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|MENU", "MGRMENU IN MGRPLIST")
      ON SELECTION BAR 9 OF puMgrbanquet =LOGMENU("FILE|MANAGER|BANQUET|BESTUHLUNG", "MGRBESTUHLUNG IN MGRPLIST")
ENDIF
******************************** 
 DEFINE POPUP puMgraddress SHADOW MARGIN RELATIVE
 DEFINE BAR 1 OF puMgraddress PROMPT GetLangText("MENU","MGR_COUNTRY")
 DEFINE BAR 2 OF puMgraddress PROMPT GetLangText("MENU","MGR_LANGUAGE")
 DEFINE BAR 3 OF puMgraddress PROMPT GetLangText("MENU","MGR_TITLE")
 DEFINE BAR 4 OF puMgraddress PROMPT GetLangText("MENU","MGR_MAILING")
 DEFINE BAR 5 OF puMgraddress PROMPT GetLangText("MENU","MGR_REFERRAL")
 DEFINE BAR 6 OF puMgraddress PROMPT GetLangText("MENU","MGR_ADDRESS_TYPE")
 DEFINE BAR 7 OF puMgraddress PROMPT GetLangText("MENU","MGR_VIP_STATUS")
 ON SELECTION BAR 1 OF puMgraddress =LOGMENU("FILE|MANAGER|ADDRESSES|COUNTRIES",    "MGRCOUNTRY  IN MGRPLIST")
 ON SELECTION BAR 2 OF puMgraddress =LOGMENU("FILE|MANAGER|ADDRESSES|LANGUAGES",    "MGRLANGUAGE IN MGRPLIST")
 ON SELECTION BAR 3 OF puMgraddress =LOGMENU("FILE|MANAGER|ADDRESSES|TITLECODES",   "MGRTITLE	IN MGRGUEST")
 ON SELECTION BAR 4 OF puMgraddress =LOGMENU("FILE|MANAGER|ADDRESSES|MAILINGCODES", "MGRMAILING 	IN MGRPLIST")
 ON SELECTION BAR 5 OF puMgraddress =LOGMENU("FILE|MANAGER|ADDRESSES|REFERRALCODES", "MGRREFERRAL IN MGRPLIST")
 ON SELECTION BAR 6 OF puMgraddress =LOGMENU("FILE|MANAGER|ADDRESSES|ADDRESSTYPE", "MGRADRTYPE IN MGRPLIST")
 ON SELECTION BAR 7 OF puMgraddress =LOGMENU("FILE|MANAGER|ADDRESSES|VIPSTATUS", "MGRVIPSTATUS IN MGRPLIST")
 DEFINE POPUP puMgrfinancial SHADOW MARGIN RELATIVE
 IF _SCREEN.B2
     DEFINE BAR 1 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_BASEL")
     DEFINE POPUP puMBasel SHADOW MARGIN RELATIVE
     DEFINE BAR 1 OF puMBasel PROMPT GetLangText("MENU","MGR_MAIN_BASEL")
     DEFINE BAR 2 OF puMBasel PROMPT GetLangText("MENU","MGR_OBER_BASEL")
     DEFINE BAR 3 OF puMBasel PROMPT GetLangText("MENU","MGR_SUB_BASEL")
     DEFINE BAR 4 OF puMBasel PROMPT GetLangText("MENU","MGR_PERSONAL_BASEL")
     DEFINE BAR 5 OF puMBasel PROMPT GetLangText("MENU","MGR_DEPARTMENT_BASEL")
     DEFINE BAR 6 OF puMBasel PROMPT GetLangText("MENU","MGR_SUPPLEMENT_BASEL")
     ON SELECTION BAR 1 OF puMBasel =LOGMENU("FILE|MANAGER|FINANCIAL|BASEL II|MAIN GROUPS", "MGRMAINGROUPBASEL IN MGRPLIST")
     ON SELECTION BAR 2 OF puMBasel =LOGMENU("FILE|MANAGER|FINANCIAL|BASEL II|OBER GROUPS", "MGROBERGROUPBASEL IN MGRPLIST")
     ON SELECTION BAR 3 OF puMBasel =LOGMENU("FILE|MANAGER|FINANCIAL|BASEL II|SUB GROUPS", "MGRSUBGROUPBASEL IN MGRPLIST")
     ON SELECTION BAR 4 OF puMBasel =LOGMENU("FILE|MANAGER|FINANCIAL|BASEL II|PERSONAL", "MGRPERSONALBASEL IN MGRPLIST")
     ON SELECTION BAR 5 OF puMBasel =LOGMENU("FILE|MANAGER|FINANCIAL|BASEL II|DEPARTMENT", "MGRDEPARTMENTBASEL IN MGRPLIST")
     ON SELECTION BAR 6 OF puMBasel =LOGMENU("FILE|MANAGER|FINANCIAL|BASEL II|SUPPLEMENT", "MGRSUPLBASEL IN MGRPLIST")
     ON BAR 1 OF puMgrfinancial ACTIVATE POPUP puMBasel 
 ENDIF
 DEFINE BAR 10 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_MAIN")
 DEFINE BAR 20 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_SUB")
 DEFINE BAR 25 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_MANGRP")
 DEFINE BAR 30 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_VAT")
 DEFINE BAR 35 OF puMgrfinancial PROMPT "\-"
 DEFINE BAR 37 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_FORECAST")
 DEFINE BAR 40 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_ARTICLE")
*!*      IF (_screen.oGlobal.oParam.pa_topost)
*!*           DEFINE BAR 45 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_POSARTI")
*!*      ENDIF
DEFINE BAR 50 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_PAYMETHOD")
*!*      IF (_screen.oGlobal.oParam.pa_topost)
*!*           DEFINE BAR 53 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_POSPAYM")
*!*      ENDIF
 DEFINE BAR 55 OF puMgrfinancial PROMPT "\-"
 DEFINE BAR 60 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_CASHIER")
 DEFINE BAR 65 OF puMgrfinancial PROMPT "\-"
 DEFINE BAR 70 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_DEPARTM")
 DEFINE BAR 74 OF puMgrfinancial PROMPT "\-"
 IF _screen.APS
      DEFINE BAR 75 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_YIELD_MANAGMENT")
      DEFINE BAR 79 OF puMgrfinancial PROMPT "\-"
 ENDIF
 DEFINE BAR 80 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_RATECODE")
 DEFINE BAR 85 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_RATECODEGROUPS")
 DEFINE BAR 90 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_PRINTTYPECODES")
 DEFINE BAR 95 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_BILLINSTR")
 DEFINE BAR 96 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_DISCOUNT")
 DEFINE BAR 97 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_BILLDISCOUNT")
 DEFINE BAR 98 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_CASHINOUT")
 IF  .NOT. g_Lite
      IF _SCREEN.BG OR  _SCREEN.DV
           DEFINE BAR 99 OF puMgrfinancial PROMPT "\-"
      ENDIF
      IF _SCREEN.BG
           DEFINE BAR 100 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_BUDGET")
      ENDIF
      IF  _SCREEN.DV
           DEFINE BAR 101 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_ARACCOUNT")
           DEFINE POPUP puMArAccount SHADOW MARGIN RELATIVE
           DEFINE BAR 1 OF puMArAccount PROMPT GetLangText("MENU","MGR_ACCTTYPE")
           DEFINE BAR 2 OF puMArAccount PROMPT GetLangText("MENU","MGR_PAY_CONDITION")
           DEFINE BAR 3 OF puMArAccount PROMPT GetLangText("MENU","MGR_REMAINDER_KEY")
           DEFINE BAR 4 OF puMArAccount PROMPT GetLangText("MENU","MGR_AR_BILL_STATUS")
           ON SELECTION BAR 1 OF puMArAccount =LOGMENU("FILE|MANAGER|FINANCIAL|ARACCOUNT|ACCOUNTS", "MGRACCTTYPE IN MGRPLIST")
           ON SELECTION BAR 2 OF puMArAccount =LOGMENU("FILE|MANAGER|FINANCIAL|ARACCOUNT|PAY_CONDITION", "MGRACCTPAYCOND IN MGRPLIST")
           ON SELECTION BAR 3 OF puMArAccount =LOGMENU("FILE|MANAGER|FINANCIAL|ARACCOUNT|REMAINDER_KEY", "MGRACCTREMKEY IN MGRPLIST")
           ON SELECTION BAR 4 OF puMArAccount =LOGMENU("FILE|MANAGER|FINANCIAL|ARACCOUNT|BILL_STATUS", "MGRACCTBILLSTATUS IN MGRPLIST")
           ON BAR 101 OF puMgrfinancial ACTIVATE POPUP puMArAccount

          IF g_lUseCreditor
               DEFINE BAR 102 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_CREDITORS_ACCOUNT")
               DEFINE POPUP puMCrAccount SHADOW MARGIN RELATIVE

               DEFINE BAR 2 OF puMCrAccount PROMPT GetLangText("MENU","MGR_PAY_CONDITION")
               ON SELECTION BAR 2 OF puMCrAccount =LOGMENU("FILE|MANAGER|FINANCIAL|CRACCOUNT|PAY_CONDITION", "MGRACCTPAYCOND IN MGRPLIST WITH .T.")

               DEFINE BAR 3 OF puMCrAccount PROMPT GetLangText("MENU","MGR_REMAINDER_KEY")
               ON SELECTION BAR 3 OF puMCrAccount =LOGMENU("FILE|MANAGER|FINANCIAL|CRACCOUNT|REMAINDER_KEY", "MGRACCTREMKEY IN MGRPLIST WITH .T.")

               ON BAR 102 OF puMgrfinancial ACTIVATE POPUP puMCrAccount
          ENDIF

      ENDIF
 ENDIF
 IF _screen.oGlobal.oParam.pa_askfa
      DEFINE BAR 110 OF puMgrfinancial PROMPT GetLangText("MENU","MGR_ACCOUNTS")
 ENDIF
 
 ON SELECTION BAR 10 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|MAIN GROUPS",            "MGRMAINGROUP  IN MGRPLIST")
 ON SELECTION BAR 20 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|SUB GROUPS",             "MGRSUBGROUP   IN MGRPLIST")
 ON SELECTION BAR 25 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|MAIN GROUPS MNG",        "MNGMANGRPCTRL IN MGRPLIST")
 ON SELECTION BAR 30 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|VAT GROUPS",             "MGRVATGROUP   IN MGRPLIST")
 ON SELECTION BAR 37 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|FORECAST",               "MGRFORECAST")
 ON SELECTION BAR 40 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|ARTICLES",               "MGRARTICLE    IN MGRFINAN")
*!*      IF (_screen.oGlobal.oParam.pa_topost)
*!*           ON SELECTION BAR 45 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|POS ARTICLES",       "MGRPOSARTICLE IN MGRFINAN")
*!*      ENDIF
ON SELECTION BAR 50 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|PAYMETHODS",             "MGRPAYMETHOD  IN MGRFINAN")
*!*      IF (_screen.oGlobal.oParam.pa_topost)
*!*           ON SELECTION BAR 53 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|POS PAYMETHODS",     "MGRPOSPAYMETHOD IN MGRFINAN")
*!*      ENDIF
 ON SELECTION BAR 60 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|CASHIERS",               "CASHIERS	    IN CASHIER")
 ON SELECTION BAR 70 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|DEPARTMENTS",            "MGRDEPARTMENT IN MGRPLIST")
 IF _screen.APS
      ON SELECTION BAR 75 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|YIELDMNG",              "MGRYIELDMNG      IN MGRFINAN")
 ENDIF
 ON SELECTION BAR 80 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|RATECODES",              "MGRRATECODE 	IN MGRFINAN")
 ON SELECTION BAR 85 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|RATECODEGROUPS",         "MGRRATECODEGROUPS IN MGRFINAN")
 ON SELECTION BAR 90 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|PRINTER GROUPING CODES", "PRINTYPE")
 ON SELECTION BAR 95 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|BILL INSTRUCTIONS", "MGRBILLINSTR IN MGRPLIST")
 ON SELECTION BAR 96 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|DISCOUNTS", "MGRDISCOUNT IN MGRPLIST")
 ON SELECTION BAR 97 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|DISCOUNTS", "MGRBILLDISCOUNT IN MGRPLIST")
 ON SELECTION BAR 98 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|MGRCASHINOUT", "MGRCASHINOUT IN MGRPLIST")
 IF  .NOT. g_Lite
 	IF _SCREEN.BG
      	ON SELECTION BAR 100 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|BUDGET DEFINITION",      "MGRBUDGET")
      ENDIF
 ENDIF
 IF _screen.oGlobal.oParam.pa_askfa
      ON SELECTION BAR 110 OF puMgrfinancial =LOGMENU("FILE|MANAGER|FINANCIAL|ACCOUNTS", "MGRACCOUNTS IN MGRPLIST")
 ENDIF
 DEFINE POPUP puMgrsystem SHADOW MARGIN RELATIVE
 DEFINE BAR 10 OF puMgrsystem PROMPT GetLangText("MENU","MGR_PARAM")
 DEFINE BAR 15 OF puMgrsystem PROMPT "\-"
 DEFINE BAR 16 OF puMgrsystem PROMPT GetLangText("MENU","MGR_TERMINAL")
 DEFINE BAR 20 OF puMgrsystem PROMPT GetLangText("MENU","MGR_GROUP")
 DEFINE BAR 30 OF puMgrsystem PROMPT GetLangText("MENU","MGR_USER")
 DEFINE BAR 31 OF puMgrsystem PROMPT "\-"
 DEFINE BAR 32 OF puMgrsystem PROMPT GetLangText("MENU","MGR_ACTIVITIES")
 ON SELECTION BAR 10 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|PARAMETERS",  "PARAMS")
 ON SELECTION BAR 16 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|TERMINALS", "TERMINALS IN MGRSYS")
 ON SELECTION BAR 20 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|USER GROUPS", "GROUPS")
 ON SELECTION BAR 30 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|USERS",       "USERS IN MGRSYS")
 ON SELECTION BAR 32 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|ACTIVITIES", "MGRACTIVITY IN MGRPLIST")
 IF (_screen.oGlobal.oParam.pa_wakeup)
      DEFINE BAR 35 OF puMgrsystem PROMPT "\-"
      DEFINE BAR 40 OF puMgrsystem PROMPT GetLangText("MENU","MGR_WAKELANG")
      ON SELECTION BAR 40 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|WAKEUP LANGUAGES", "MGRWULANG IN MGRPLIST")
 ENDIF
 DEFINE BAR 45 OF puMgrsystem PROMPT "\-"
 DEFINE BAR 50 OF puMgrsystem PROMPT GetLangText("MENU","MGR_PERIOD")
 DEFINE BAR 60 OF puMgrsystem PROMPT GetLangText("MENU","MGR_SETTINGS")
* DEFINE BAR 70 OF puMgrsystem PROMPT "\-"
* DEFINE BAR 80 OF puMgrsystem PROMPT GetLangText("MENU","MGR_RESTART_MAIL_CLIENT") ;
*      SKIP FOR noUserrights("Maint",13)
 ON SELECTION BAR 50 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|PERIODS", "MGRPERIOD IN MGRPRIOD")
 ON SELECTION BAR 60 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|SETTINGS", "MGRSETTINGS IN MGRPLIST")
* ON SELECTION BAR 80 OF puMgrsystem =LOGMENU("FILE|MANAGER|SYSTEM|EMAIL", "RESETEMAILCLIENT IN PROCEMAIL")
 IF _SCREEN.AZE
      DEFINE POPUP puMgraze SHADOW MARGIN RELATIVE
      DEFINE BAR 10 OF puMgraze PROMPT GetLangText("MENU","MGR_JOBS")
      DEFINE BAR 20 OF puMgraze PROMPT GetLangText("MENU","MGR_TIMETYPE")
      DEFINE BAR 30 OF puMgraze PROMPT GetLangText("MENU","MGR_EVENTS")
      ON SELECTION BAR 10 OF puMgraze =LOGMENU("FILE|MANAGER|AZE|JOBS", "MGRJOBS IN MGRAZE")
      ON SELECTION BAR 20 OF puMgraze =LOGMENU("FILE|MANAGER|AZE|TIMETYPES", "TIMETYPES IN MGRAZE")
      ON SELECTION BAR 30 OF puMgraze =LOGMENU("FILE|MANAGER|AZE|TIMETYPES", "EVENTS IN MGRAZE")
 ENDIF
 IF NOT EMPTY(_screen.oGlobal.oParam2.pa_ciwebdr)
      DEFINE POPUP puMgrcitweb SHADOW MARGIN RELATIVE
      DEFINE BAR 10 OF puMgrcitweb PROMPT GetLangText("MENU","MGR_CITWEB_AVAILABILITY")
      ON SELECTION BAR 10 OF puMgrcitweb =LOGMENU("FILE|MANAGER|CITWEB SETTINGS|CITWEB AVAILABILITY", "MGRCITWEBAVILAB IN MGRCITWEB")
      IF _screen.OR
           DEFINE BAR 20 OF puMgrcitweb PROMPT GetLangText("MENU","MGR_CITWEB_RATES")
           ON SELECTION BAR 20 OF puMgrcitweb =LOGMENU("FILE|MANAGER|CITWEB SETTINGS|CITWEB RATES", "MGRCITWEBRATES IN MGRCITWEB")
      ENDIF
 ENDIF
 
 ************************************************************************************************************************************
 *
 *
 *
 *         A  T  T  E  N  T  I  O  N       ! ! ! !
 *         _______________________________________
 *
 *
 * When you are changing calls to functions from main menu items, don't forget to change it in 
 * cit_ctrl.vcx class library, in tnbthemedoutlooknavbar and tnbthemedoutlooknavbarfrm classes !!!!!!!!!!!!!
 *
 * Example:
 * =LOGMENU("RESERVATIONS|LIST ALL", "Doform WITH 'resbrw','forms\resbrw with 1'")
 * When changing "Doform WITH 'resbrw','forms\resbrw with 1'", you must change it in tnbthemedoutlooknavbar and tnbthemedoutlooknavbarfrm classes too !!!
 *
 *
 *         A  T  T  E  N  T  I  O  N       ! ! ! !
 *         _______________________________________
 *
 *
 *
 *
 *                             ud$$$**$$$$$$$bc.                          
 *                         u@**"        4$$$$$$$Nu                       
 *                       J                ""#$$$$$$r                     
 *                      @                       $$$$b                    
 *                    .F                        ^*3$$$                   
 *                   :% 4                         J$$$N                  
 *                   $  :F                       :$$$$$                  
 *                  4F  9                       J$$$$$$$                 
 *                  4$   k             4$$$$bed$$$$$$$$$                 
 *                 $$r  'F            $$$$$$$$$$$$$$$$$r                
 *                  $$$   b.           $$$$$$$$$$$$$$$$$N                
 *                  $$$$$k 3eeed$$b    $$$Euec."$$$$$$$$$                
 *   .@$**N.        $$$$$" $$$$$$F'L $$$$$$$$$$$  $$$$$$$                
 *   :$$L  'L       $$$$$ 4$$$$$$  * $$$$$$$$$$F  $$$$$$F         edNc   
 *  @$$$$N  ^k      $$$$$  3$$$$*%   $F4$$$$$$$   $$$$$"        d"  z$N  
 *  $$$$$$   ^k     '$$$"   #$$$F   .$  $$$$$c.u@$$$          J"  @$$$$r 
 *  $$$$$$$b   *u    ^$L            $$  $$$$$$$$$$$$u@       $$  d$$$$$$ 
 *   ^$$$$$$.    "NL   "N. z@*     $$$  $$$$$$$$$$$$$P      $P  d$$$$$$$ 
 *      ^"*$$$$b   '*L   9$E      4$$$  d$$$$$$$$$$$"     d*   J$$$$$r   
 *           ^$$$$u  '$.  $$$L     "#" d$$$$$$".@$$    .@$"  z$$$$*"     
 *             ^$$$$. ^$N.3$$$       4u$$$$$$$ 4$$$  u$*" z$$$"          
 *               '*$$$$$$$$ *$b      J$$$$$$$b u$$P $"  d$$P             
 *                  #$$$$$$ 4$ 3*$"$*$ $"$'c@@$$$$ .u@$$$P               
 *                    "$$$$  ""F~$ $uNr$$$^&J$$$$F $$$$#                 
 *                      "$$    "$$$bd$.$W$$$$$$$$F $$"                   
 *                        ?k         ?$$$$$$$$$$$F'*                     
 *                         9$$bL     z$$$$$$$$$$$F                       
 *                          $$$$    $$$$$$$$$$$$$                        
 *                           '#$$c  '$$$$$$$$$"                          
 *                            .@"#$$$$$$$$$$$$b                          
 *                          z*      $$$$$$$$$$$$N.                       
 *                        e"      z$$"  #$$$k  '*$$.                     
 *                    .u*      u@$P"      '#$$c   "$$c                   
 *             u@$*"""       d$$"            "$$$u  ^*$$b.               
 *           :$F           J$P"                ^$$$c   '"$$$$$$bL        
 *          d$$  ..      @$#                      #$$b         '#$       
 *          9$$$$$$b   4$$                          ^$$k         '$      
 *           "$$6""$b u$$                             '$    d$$$$$P      
 *             '$F $$$$$"                              ^b  ^$$$$b$       
 *              '$W$$$$"                                'b@$$$$"         
 *                                                       ^$$$*
 *
 *
 *         A  T  T  E  N  T  I  O  N       ! ! ! !
 *         _______________________________________
 *
 **************************************************************************************************************************************

 DEFINE POPUP puReservat SHADOW MARGIN RELATIVE
 IF definebar(10,"puReservat",GetLangText("MENU","RES_ALL"),"Reserva",1,"","bitmap\toolbar\reservat.png","SHIFT+F7")
      ON SELECTION BAR 10 OF puReservat =LOGMENU("RESERVATIONS|LIST ALL", "Doform WITH 'resbrw','forms\resbrw with 1'")
 ENDIF
 IF definebar(15,"puReservat",GetLangText("MENU","RES_INHOUSE"),"Reserva",5,"","bitmap\toolbar\inhouse.png")
      ON SELECTION BAR 15 OF puReservat =LOGMENU("FINANCIAL|BILLS", "Doform WITH 'resbrw54','forms\resbrw with 54'")
 ENDIF
 IF  .NOT. g_Lite
      IF definebar(20,"puReservat",GetLangText("MENU","RES_ROOMLIST"),"Reserva",2,"","bitmap\toolbar\roomlist.png")
           ON SELECTION BAR 20 OF puReservat =LOGMENU("RESERVATIONS|ROOMING LIST", "RSROOMLIST IN RESERV2")
      ENDIF
 ENDIF
 IF _SCREEN.OR
      DEFINE BAR 21 OF puReservat PROMPT getlangtext("EXTRESER","TXT_EXTRESER")
      ON SELECTION BAR 21 OF puReservat =LOGMENU("RESERVATIONS|EXTERNAL RESERVATION", "EXTRESER")
 ENDIF
 IF _screen.oGlobal.oParam.pa_quickrs AND NOT g_lShips
      DEFINE BAR 25 OF puReservat PROMPT "\-"
      IF definebar(30,"puReservat",GetLangText("MENU","RES_WALKIN"),"Reserva",3,"","bitmap\toolbar\walkin.png","SHIFT+F8")
           ON SELECTION BAR 30 OF puReservat =LOGMENU("RESERVATIONS|WALK IN", "WALKIN")
      ENDIF
 ENDIF
 IF  .NOT. g_Lite
      DEFINE BAR 35 OF puReservat PROMPT "\-"
      IF definebar(40,"puReservat",PADR(GetLangText("MENU","RES_DENIAL"), 20),"Reserva",6,"","bitmap\toolbar\denial.png")
           ON SELECTION BAR 40 OF puReservat =LOGMENU("RESERVATIONS|DENIAL", "DENIAL WITH SYSDATE(), {}, ''")
      ENDIF
      IF _SCREEN.kt
           IF definebar(50,"puReservat",GetLangText("MENU","MGR_ALLOTT"),"Reserva",4,"","bitmap\toolbar\allott.png","SHIFT+F5")
                ON SELECTION BAR 50 OF puReservat =LOGMENU("RESERVATIONS|ALLOTMENTS", "MGRALLOTT      IN MGRRESER")
           ENDIF
           IF g_lShips
                IF definebar(60,"puReservat",GetLangText("MENU","MGR_ALLOTT_AVAIL"),"Reserva",6,"","bitmap\toolbar\graph05.png","ALT+F5")
                     ON SELECTION BAR 60 OF puReservat =LOGMENU("RESERVATIONS|ALLOTMENTS AVAIL", "searchallott IN procallott")
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 DEFINE POPUP puAddress SHADOW MARGIN RELATIVE
 IF definebar(1,"puAddress",GetLangText("MENU","ADD_ALL"),"Address",1,"","bitmap\toolbar\card03.png","ALT+F2")
      ON SELECTION BAR 1 OF puAddress =LOGMENU("ADDRESSES|LIST ALL", "BRWADDRESS WITH 3, 20, .F., 'SADDRESS' IN ADDRESS")
 ENDIF
 IF definebar(2,"puAddress","\<" + GetLangText("WALKIN","T_MAILING"),"Address",2,"","bitmap\toolbar\note01.png")
      ON SELECTION BAR 2 OF puAddress =LOGMENU("ADDRESSES|MAILING", "DOFORM WITH 'mailingformsi','forms\mailingform'")
 ENDIF
 IF definebar(3,"puAddress","\<" + GetLangText("DOC","TXT_PHONE_NOTE"),"Address",3,"OR NOT INLIST(WONTOP(), [FADDRESSMASK])","bitmap\toolbar\phone01.png","ALT+F7")
      ON SELECTION BAR 3 OF puAddress =LOGMENU("ADDRESSES|PHONENOTE", "PHONENOTE IN ADDRESS")
 ENDIF
 IF _SCREEN.OL AND definebar(4,"puAddress",GetLangText("MENU","ADD_EMAILS"),"Address",4,"","bitmap\toolbar\mail1.bmp")
      ON SELECTION BAR 4 OF puAddress =LOGMENU("ADDRESSES|EMAIL", "DOFORM IN DOFORM WITH 'frmMailBrowse','forms/emailbrowse.scx'")
 ENDIF

 DEFINE POPUP puFinancial SHADOW MARGIN RELATIVE
 IF definebar(10,"puFinancial",GetLangText("MENU","FIN_POST"),"Financ",1,"OR g_Cashier==0","bitmap\toolbar\postings.png","SHIFT+F12")
      ON SELECTION BAR 10 OF puFinancial =LOGMENU("FINANCIAL|POSTINGS",             "POST IN ROOMPOST")
 ENDIF

 IF NOT g_Lite AND ;
           definebar(15,"puFinancial",GetLangText("MENU","TXT_RATE_CODE_POST"),"Financ",9,"OR g_Cashier==0","bitmap\toolbar\ratecodepost.png","CTRL+F12")
      ON SELECTION BAR 15 OF puFinancial =LOGMENU("FINANCIAL|RATE CODE POST",       "RATES IN RATES")
 ENDIF
 IF definebar(20,"puFinancial",GetLangText("MENU","FIN_CHECKOUT"),"Financ",2,"OR g_Cashier==0","bitmap\toolbar\bill.png","F12")
      ON SELECTION BAR 20 OF puFinancial =LOGMENU("FINANCIAL|BILLS",                "Doform WITH 'resbrw54','forms\resbrw with 54'")
 ENDIF
 IF definebar(25,"puFinancial",GetLangText("MENU","FIN_BATCHCHECKOUT"),"Financ",11,"OR g_Cashier==0","bitmap\toolbar\batchcheckout.png","")
      IF g_lBillMode
           ON SELECTION BAR 25 OF puFinancial =LOGMENU("FINANCIAL|BATCHCHKOUT","CHECKOUTBATCH IN PROCBILL")
      ELSE
           ON SELECTION BAR 25 OF puFinancial =LOGMENU("FINANCIAL|BATCHCHKOUT","BATCHCHKOUT IN CHKOUT1")
      ENDIF      
 ENDIF
 IF definebar(30,"puFinancial",GetLangText("MENU","FIN_PASSERBY"),"Financ",3,"OR g_Cashier==0","bitmap\toolbar\walkin.png","F8")
      ON SELECTION BAR 30 OF puFinancial =LOGMENU("FINANCIAL|PASSERBY",             "POSTPASSERBY IN PASSERBY")
 ENDIF
 IF definebar(35,"puFinancial",GetLangText("MENU","FIN_GROUPPOST"),"Financ",13,"OR g_Cashier==0","bitmap\toolbar\grouppost.png","")
      ON SELECTION BAR 35 OF puFinancial LOGMENU("FINANCIAL|GROUP POST",     " FORM [forms\resgroups] WITH [GROUP_POST]")
 ENDIF
 DEFINE BAR 40 OF puFinancial PROMPT "\-"
 IF definebar(50,"puFinancial",GetLangText("MENU","FIN_CLOSE"),"Financ",4,"OR g_Cashier==0","bitmap\toolbar\wrongway.png","")
      ON SELECTION BAR 50 OF puFinancial =LOGMENU("FINANCIAL|CLOSE CASHIER",        "CLOSCASH")
 ENDIF
 IF definebar(60,"puFinancial",GetLangText("MENU","FIN_EXCHANGE"),"Financ",5,"OR g_Cashier==0","bitmap\toolbar\dollarexchange.png","")
      ON SELECTION BAR 60 OF puFinancial =LOGMENU("FINANCIAL|CURRENCY EXCHANGE",    "CHANGECASH IN CASHIER")
 ENDIF
 IF definebar(70,"puFinancial",GetLangText("MENU","FIN_TOFROMBANK"),"Financ",6,"OR g_Cashier==0","bitmap\toolbar\to-from.png","")
      ON SELECTION BAR 70 OF puFinancial =LOGMENU("FINANCIAL|TO FROM BANK",         "TOFROMBANK IN CASHIER")
 ENDIF
 IF definebar(71,"puFinancial",GetLangText("MENU","FIN_CASHINOUT"),"Financ",12,"OR g_Cashier==0","bitmap\toolbar\greenballwitharrays.png","")
      ON SELECTION BAR 71 OF puFinancial =LOGMENU("FINANCIAL|CASH IN OUT ",         "CASHINOUT IN CASHIER")
 ENDIF
 IF NOT EMPTY(_screen.oGlobal.oParam.pa_fiscprt)
      IF definebar(72,"puFinancial",GetLangText("MENU","FIN_FISCAL_PRINTER"),"Financ",14,"OR g_Cashier==0","bitmap\toolbar\print.png","")
           ON SELECTION BAR 72 OF puFinancial =LOGMENU("FINANCIAL|FISCAL PRINTER ",         "FPBillPrintedShowCommands IN FPBillPrinted")
      ENDIF
 ENDIF
 IF _screen.oGlobal.lelpay
      IF definebar(73,"puFinancial","elPay Einstellungen","Financ",15,"OR g_Cashier==0","common\picts\elpay.png","")
           ON SELECTION BAR 73 OF puFinancial =LOGMENU("FINANCIAL|ELPAY SETTINGS", " FORM [common\forms\elpaysettings.scx]")
      ENDIF
 ENDIF
 IF _SCREEN.GD
      IF definebar(74,"puFinancial",GetLangText("MENU","FIN_GDPDU"),"Manager",9,"OR g_Cashier==0","common\picts\audicon.png","")
           ON SELECTION BAR 74 OF puFinancial =LOGMENU("FINANCIAL|GDPDU EXPORT", "GDPDUEXPORT IN GDPDUEXPORT WITH ,,,.T.")
      ENDIF
 ENDIF
 IF ArgusOffice("PARAM", "pa_cashctr",, .T.)
      DEFINE BAR 74 OF puFinancial PROMPT "\-"
      IF definebar(75,"puFinancial",GetLangText("MENU","FIN_ARGUS_CASHIN"),"Financ",14,"OR g_Cashier==0","bitmap\toolbar\euro.png","")
           ON SELECTION BAR 75 OF puFinancial =LOGMENU("FINANCIAL|ARGUS TPOS CASH IN", "MGRREADERS IN ARGUSOFFICE")
      ENDIF
 ENDIF
 IF  .NOT. g_Lite
      DEFINE BAR 80 OF puFinancial PROMPT "\-"
      IF _SCREEN.DV
           IF definebar(90,"puFinancial",GetLangText("MENU","FIN_AR"),"Financ",7,"OR g_Cashier==0","bitmap\toolbar\maninred.png","")
                ON BAR 90 OF puFinancial ACTIVATE POPUP poPar
                DEFINE POPUP poPar SHADOW MARGIN RELATIVE
                DEFINE BAR 1 OF poPar PROMPT GetLangText("MENU","AR_ACCOUNTS") KEY CTRL+F8
                DEFINE BAR 2 OF poPar PROMPT GetLangText("MENU","AR_REARS_BILLING") KEY CTRL+F9
                *DEFINE BAR 3 OF poPar PROMPT GetLangText("MENU","AR_BATRMND")
                ON SELECTION BAR 1 OF poPar =LOGMENU("FINANCIAL|AR ACCOUNTS","ARBROWSE IN AR")
                ON SELECTION BAR 2 OF poPar =LOGMENU("FINANCIAL|AR RECEIVABLES","ARRECEIVABLES IN AR")
                *ON SELECTION BAR 3 OF poPar =LOGMENU("FINANCIAL|AR BATRMND","ARBRMND IN AR")

                IF g_lUseCreditor
                     DEFINE BAR 91 OF puFinancial PROMPT GetLangText("MENU","CREDITORS_ACCOUNTS")
                     ON BAR 91 OF puFinancial ACTIVATE POPUP poPCreditors
                     DEFINE POPUP poPCreditors SHADOW MARGIN RELATIVE
                     DEFINE BAR 1 OF poPCreditors PROMPT GetLangText("MENU","CREDITORS_ACCOUNTS")
                     DEFINE BAR 2 OF poPCreditors PROMPT GetLangText("MENU","CREDITORS_REARS_BILLING")
                     ON SELECTION BAR 1 OF poPCreditors =LOGMENU("FINANCIAL|CREDITORS","ARBROWSE IN AR WITH .T.")
                     ON SELECTION BAR 2 OF poPCreditors =LOGMENU("FINANCIAL|CREDITORS RECEIVABLES","ARRECEIVABLES IN AR WITH .T.")
               ENDIF
           ENDIF
      ELSE
           IF definebar(90,"puFinancial",GetLangText("MENU","FIN_LEDGER"),"Financ",7,"OR g_Cashier==0","","")
                ON SELECTION BAR 90 OF puFinancial =LOGMENU("FINANCIAL|CREDIT CARD & LEDGER", "LEDGER IN LEDGER")
           ENDIF
      ENDIF
      IF _SCREEN.GS
           IF definebar(95,"puFinancial",GetLangText("MENU","FIN_VOUCHER"),"Financ",10,"OR g_Cashier==0","bitmap\toolbar\list_lines_menu.png","")
                ON SELECTION BAR 95 OF puFinancial =LOGMENU("FINANCIAL|VOUCHERS",             "BRWVOUCHER IN VOUCHER")
           ENDIF
      ENDIF
      IF _SCREEN.BMS AND (NOT _screen.oGlobal.lUseMainServer OR _screen.oGlobal.lBmsManagerForServer)
           IF definebar(97,"puFinancial",GetLangText("MENU","FIN_BONUS"),"Financ",16,"OR g_Cashier==0","bitmap\toolbar\billext.png","")
                ON SELECTION BAR 97 OF puFinancial =LOGMENU("FINANCIAL|BONUS",             "FORM 'forms\MngForm' WITH 'MngBmsCtrl'")
           ENDIF
      ENDIF
 ENDIF
 DEFINE BAR 100 OF puFinancial PROMPT "\-"
 IF definebar(110,"puFinancial",GetLangText("MENU","FIN_HISTORY"),"Financ",8,"OR g_Cashier==0","bitmap\toolbar\bill-hist.png","")
      ON SELECTION BAR 110 OF puFinancial =LOGMENU("FINANCIAL|BILL HISTORY",         "BILLHISTORY IN BILLHIST")
 ENDIF
 DEFINE POPUP puReports SHADOW MARGIN RELATIVE
 l_lpuReportsCreated = definebar(1,"puReports",GetLangText("MENU","RPT_RESERVAT"),"Report",1,"","","") OR l_lpuReportsCreated
 l_lpuReportsCreated = definebar(2,"puReports",GetLangText("MENU","RPT_INHOUSE"),"Report",2,"","","") OR l_lpuReportsCreated
 l_lpuReportsCreated = definebar(3,"puReports",GetLangText("MENU","RPT_FINANCIAL"),"Report",3,"","","") OR l_lpuReportsCreated
 IF NOT g_Lite
      l_lpuReportsCreated = definebar(4,"puReports",GetLangText("MENU","RPT_CONFERENCE"),"Report",4,"","","") OR l_lpuReportsCreated
 ENDIF
 l_lpuReportsCreated = definebar(5,"puReports",GetLangText("MENU","RPT_STATISTIC"),"Report",5,"","","") OR l_lpuReportsCreated
 l_lpuReportsCreated = definebar(6,"puReports",GetLangText("MENU","RPT_ADDRESS"),"Report",6,"","","") OR l_lpuReportsCreated
 l_lpuReportsCreated = definebar(7,"puReports",GetLangText("MENU","RPT_SYSTEM"),"Report",7,"","","") OR l_lpuReportsCreated
 l_lpuReportsCreated = definebar(8,"puReports",GetLangText("MENU","RPT_LETTERS"),"Report",8,"","bitmap\toolbar\letters.png","F7") OR l_lpuReportsCreated
 DEFINE BAR 100 OF puReports PROMPT "\-"
 IF definebar(9,"puReports",GetLangText("MENU","RPT_BATCH"),"Report",9,"","","")
      ON SELECTION BAR 9 OF puReports =LOGMENU("REPORTS|BATCHES", "BATCHES IN MYLISTS")
 ENDIF
 ltMpargus = TYPE("_screen.oGlobal.oParam.Pa_Argus") = "L" AND _screen.oGlobal.oParam.pa_argus
 IF (ltMpargus .OR. _screen.oGlobal.oParam.pa_postpos .OR.  .NOT. EMPTY(_screen.oGlobal.oParam.pa_rep13)  ;
    .OR.  .NOT. EMPTY(_screen.oGlobal.oParam.pa_rep14) .OR.  .NOT. EMPTY(_screen.oGlobal.oParam.pa_rep15))
      DEFINE BAR 101 OF puReports PROMPT "\-"
 ENDIF
 IF (_screen.oGlobal.oParam.pa_postpos .OR. ltMpargus)
      l_lpuReportsCreated = definebar(10,"puReports",GetLangText("MENU","RPT_TPOS"),"Report",10,"","","") OR l_lpuReportsCreated
 ENDIF
 IF ( .NOT. EMPTY(_screen.oGlobal.oParam.pa_rep13))
      l_lpuReportsCreated = definebar(11,"puReports",ALLTRIM(_screen.oGlobal.oParam.pa_rep13),"Report",11,"","","") OR l_lpuReportsCreated
 ENDIF
 IF ( .NOT. EMPTY(_screen.oGlobal.oParam.pa_rep14))
      l_lpuReportsCreated = definebar(12,"puReports",ALLTRIM(_screen.oGlobal.oParam.pa_rep14),"Report",12,"","","") OR l_lpuReportsCreated
 ENDIF
 IF ( .NOT. EMPTY(_screen.oGlobal.oParam.pa_rep15))
      l_lpuReportsCreated = definebar(13,"puReports",ALLTRIM(_screen.oGlobal.oParam.pa_rep15),"Report",13,"","","") OR l_lpuReportsCreated
 ENDIF
 IF _SCREEN.B2
      l_lpuReportsCreated = definebar(17,"puReports",GetLangText("MENU","RPT_BASELII"),"Report",15,"","","") OR l_lpuReportsCreated
 ENDIF
 IF l_lpuReportsCreated
      ON SELECTION POPUP puReports =LOGMENU("REPORTS...", "LISTS WITH BAR(), PROMPT() IN MYLISTS")
 ENDIF
 DEFINE POPUP puViews SHADOW MARGIN RELATIVE
 IF definebar(10,"puViews",GetLangText("MENU","VEW_ARRIVAL"),"View",1,"","bitmap\toolbar\arrivals.png","F3")
      ON SELECTION BAR 10 OF puViews =LOGMENU("VIEWS|ARRIVALS",            "Doform WITH 'resbrw50','forms\resbrw with 50'")
 ENDIF
 IF definebar(20,"puViews",GetLangText("MENU","VEW_DEPARTURE"),"View",2,"","bitmap\toolbar\departures.png","SHIFT+F3")
      ON SELECTION BAR 20 OF puViews =LOGMENU("VIEWS|DEPARTURES",          "Doform WITH 'resbrw51','forms\resbrw with 51'")
 ENDIF
 IF definebar(30,"puViews",GetLangText("MENU","VEW_INHOUSE"),"View",3,"","bitmap\toolbar\inhouse.png","CTRL+F3")
      ON SELECTION BAR 30 OF puViews =LOGMENU("VIEWS|IN HOUSE",            "Doform WITH 'resbrw52','forms\resbrw with 52'")
 ENDIF


 DEFINE BAR 40 OF puViews PROMPT "\-"
 IF definebar(50,"puViews",GetLangText("MENU","VEW_CASHIER"),"View",4,"","bitmap\toolbar\kassen.png","")
      ON SELECTION BAR 50 OF puViews =LOGMENU("VIEWS|CASHIERS",            "VEWCASHIER      IN VIEW")
 ENDIF
 IF definebar(60,"puViews",GetLangText("MENU","VEW_RATECODE"),"View",5,"","bitmap\toolbar\calculator.png","CTRL+F5")
      ON SELECTION BAR 60 OF puViews =LOGMENU("VIEWS|RATECODES",           "VEWRATECODE      IN VIEW")
 ENDIF
 IF _screen.APS AND definebar(70,"puViews",GetLangText("MENU","MGR_YIELD_MANAGMENT"),"View",5,"","bitmap\toolbar\ratecodepost.png","ALT+F5")
      ON SELECTION BAR 70 OF puViews =LOGMENU("VIEWS|RATEFIND",           "VEWRATECODE      IN VIEW     WITH 'RATEFIND'")
 ENDIF
 DEFINE BAR 80 OF puViews PROMPT "\-"
 IF definebar(90,"puViews",GetLangText("MENU","VEW_AVAIL"),"View",6,"","bitmap\toolbar\graph05.png","F4")
      ON SELECTION BAR 90 OF puViews =LOGMENU("VIEWS|AVAILABILITY",        "VEWAVAIL           IN VIEW")
 ENDIF
 IF definebar(100,"puViews",GetLangText("MENU","VEW_MAXAVAIL"),"View",7,"","bitmap\toolbar\grid.png","SHIFT+F4")
      ON SELECTION BAR 100 OF puViews =LOGMENU("VIEWS|MAX. AVAILABILITY",   "VEWMAXAVAIL     IN VIEW")
 ENDIF
 *DEFINE BAR 10 OF puViews PROMPT GetLangText("MENU","VEW_ALLOTMENTS") SKIP FOR  ;
 *       noUserrights("View",8) KEY SHIFT+F5
 DEFINE BAR 110 OF puViews PROMPT "\-"
 IF definebar(120,"puViews",GetLangText("MENU","VEW_ROOMPLAN"),"View",9,"","bitmap\toolbar\mac01.png","F2")
      ON SELECTION BAR 120 OF puViews =LOGMENU("VIEWS|ROOMS WEEKPLAN",      "PLAN               IN PLAN")
 ENDIF
 *DEFINE BAR 15 OF puViews PROMPT GetLangText("MENU","VEW_MONTHPLAN") SKIP FOR  ;
 *       noUserrights("View",13) KEY ALT+F2 
 IF  .NOT. g_Lite
      IF _SCREEN.TG
           IF definebar(130,"puViews",GetLangText("MENU","VEW_CONFWEEK"),"View",10,"","bitmap\toolbar\confplan.png","SHIFT+F2")
                ON SELECTION BAR 130 OF puViews =LOGMENU("VIEWS|CONFERENCE WEEKPLAN", "CONFWEEK          IN CONFWEEK")
           ENDIF
           IF definebar(140,"puViews",GetLangText("MENU","VEW_CONFER"),"View",11,"","bitmap\toolbar\confdayplan.png","CTRL+F2")
                ON SELECTION BAR 140 OF puViews =LOGMENU("VIEWS|CONFERENCE DAYPLAN",  "CONFPLAN          IN CONFPLAN")
           ENDIF
      ENDIF
      IF definebar(150,"puViews",GetLangText("MENU","VEW_HOTSTAT"),"View",14,"","bitmap\toolbar\percent.png","ALT+F12")
           ON SELECTION BAR 150 OF puViews LOGMENU("VIEWS|HOTSTAT",  "HOTSTAT IN HOTSTAT")&&DO HOTSTAT
      ENDIF
 ENDIF
 DEFINE BAR 160 OF puViews PROMPT "\-"
 IF _SCREEN.IT AND definebar(170,"puViews",GetLangText("MENU","VEW_PHONE"),"View",12,"","bitmap\toolbar\phone01.png","")
      ON SELECTION BAR 170 OF puViews =LOGMENU("VIEWS|PHONE",               "PHONELIST          IN PHONE")
 ENDIF
 IF definebar(180,"puViews",GetLangText("MENU","VEW_GETROOM"),"View",15,"","bitmap\toolbar\getroom.png","CTRL+F1")
      ON SELECTION BAR 180 OF puViews =LOGMENU("VIEWS|GET ROOM","GETROOM IN GETROOM")
 ENDIF
 IF g_lNewConferenceActive AND _SCREEN.US AND ;
           definebar(190,"puViews",GetLangText("MENU","VEW_REV_STAT"),"View",16,"","bitmap\toolbar\graph07.png","")
      ON SELECTION BAR 190 OF puViews =LOGMENU("VIEWS|REVENUE STATISTICS","FORM 'FORMS\OR'")
 ENDIF
 IF _screen.TP
      DEFINE BAR 200 OF puViews PROMPT "\-"
      IF definebar(210,"puViews",GetLangText("MENU","VEW_ARGUS_TABLERES"),"",0,"","bitmap\toolbar\coffee24.png","ALT+F11")
           ON SELECTION BAR 210 OF puViews =LOGMENU("VIEWS|ARGUS TABLE RESERVATIONS", "MGRTABLERESER IN ARGUSOFFICE")
      ENDIF
      IF _screen.oGlobal.lTableReservationPlans
           IF definebar(220,"puViews",GetLangText("MENU","VEW_ARGUS_TR_WEEKPLAN"),"",0,"","bitmap\toolbar\confplan.png")
                ON SELECTION BAR 220 OF puViews =LOGMENU("VIEWS|ARGUS TABLE RES. WEEKPLAN", "TABLERESWEEKPLAN IN ARGUSOFFICE")
           ENDIF
           IF definebar(230,"puViews",GetLangText("MENU","VEW_ARGUS_TR_DAYPLAN"),"",0,"","bitmap\toolbar\confdayplan.png")
                ON SELECTION BAR 230 OF puViews =LOGMENU("VIEWS|ARGUS TABLE RES. DAYPLAN", "TABLERESDAYPLAN IN ARGUSOFFICE")
           ENDIF
      ENDIF
 ENDIF
 DEFINE POPUP puOther SHADOW MARGIN RELATIVE
 IF definebar(1,"puOther",GetLangText("MENU","OTH_ACTIVITY"),"Other",11,"","bitmap\toolbar\action.png","SHIFT+F11")
      ON SELECTION BAR 1 OF puOther =LOGMENU("VIEWS|ACTIVITY","DOFORM IN DOFORM WITH 'activities','forms\activities'")
 ENDIF
* DEFINE BAR 2 OF puOther PROMPT GetLangText("MENU","OTH_ACTLIST") SKIP FOR  ;
 *       noUserrights("Other",12)
 IF definebar(3,"puOther",GetLangText("MENU","OTH_DOCLIST"),"Other",13, ;
           "OR NOT (INLIST(WONTOP(), 'WADBROWSE', 'WRSBROWSE','FWEEKFORM','RESBRW','CONFERENCEFORM','CONFERENCEDAYFORM') OR "+;
           "(WONTOP() = 'MNGFORM' AND TYPE('_screen.ActiveForm.cFormLabel') = 'C' AND UPPER(_screen.ActiveForm.cFormLabel) = 'BMSMANAGER'))","bitmap\toolbar\documents.png","CTRL+F7")
      ON SELECTION BAR 3 OF puOther LOGMENU("OTHER|DOCBROWSE", "DOCBROWSE IN DOC")
 ENDIF
 DEFINE BAR 5 OF puOther PROMPT "\-"
 IF definebar(10,"puOther",GetLangText("MENU","OTH_HOUSEKEEP"),"Other",1,"","bitmap\toolbar\housecleaning.png","")
      ON SELECTION BAR 10 OF puOther =LOGMENU("OTHER|HOUSE KEEPING", "HOUSEKEEP IN HOUSE")
 ENDIF
 IF definebar(15,"puOther",GetLangText("MENU","MGR_OOORDER"),"Other",10,"","bitmap\toolbar\outoforder.png","")
      ON SELECTION BAR 15 OF puOther =LOGMENU("OTHER|OUT OF ORDER", "OUTOFORD")
 ENDIF
 IF definebar(16,"puOther",GetLangText("MENU","MGR_OOSERVICE"),"Other",16,"","bitmap\toolbar\outofservice.png","")
      ON SELECTION BAR 16 OF puOther =LOGMENU("OTHER|OUT OF SERVICE", "FORM 'forms\MngForm' WITH 'MngOOSCtrl'")
 ENDIF
 IF definebar(20,"puOther",GetLangText("MENU","OTH_ROOMHIST"),"Other",2,"","bitmap\toolbar\window-with-graph.png","")
      ON SELECTION BAR 20 OF puOther =LOGMENU("OTHER|ROOMHISTORY", "ROOMHISTORY IN HOUSE")
 ENDIF
 DEFINE BAR 30 OF puOther PROMPT "\-"
 IF _screen.oGlobal.oParam.pa_pttwake AND definebar(40,"puOther",GetLangText("MENU","IFC_WAKEUP"),"Other",3,"","bitmap\toolbar\clock06.png","SHIFT+F6")
      ON SELECTION BAR 40 OF puOther =LOGMENU("OTHER|WAKEUPS", "WAKEUP")
 ENDIF
 IF (_screen.oGlobal.oParam.pa_wakeup) AND _SCREEN.IT AND ;
           definebar(40,"puOther",GetLangText("MENU","IFC_WAKEUP"),"Other",3,"","bitmap\toolbar\clock06.png","SHIFT+F6")
      ON SELECTION BAR 40 OF puOther =LOGMENU("OTHER|WAKE UP LIST", "WUBROWSE IN WUMANAGR")
 ENDIF
 IF (_SCREEN.IS OR _SCREEN.IK OR _SCREEN.IT OR _SCREEN.IP) AND ;
           definebar(50,"puOther",GetLangText("MENU","IFC_MESSAGE"),"Other",5,"","bitmap\toolbar\note01.png","ALT+F6")
      ON SELECTION BAR 50 OF puOther =LOGMENU("OTHER|MESSAGES", "Doform WITH 'resbrw53','forms\resbrw with 53'")
 ENDIF
 IF (_screen.oCardReaderHandler.lAvailable OR _screen.oGlobal.oParam.pa_keyifc OR _screen.oGlobal.oParam.pa_ptvifc OR _screen.oGlobal.oParam.pa_pttifc) AND (_SCREEN.IS OR _SCREEN.IK OR _SCREEN.IT OR _SCREEN.IP) AND ;
           definebar(60,"puOther",GetLangText("MENU","IFC_COPY"),"Other",6, ;
           "OR NOT INLIST(WONTOP(), 'WADBROWSE', 'FADDRESSMASK','WRSBROWSE','FWEEKFORM','RESBRW')","bitmap\toolbar\screwdriver.png","F6")
      ON SELECTION BAR 60 OF puOther =LOGMENU("OTHER|KEY CARDS", "NEWKEYCARD")
       *IF  .NOT. EMPTY(_screen.oGlobal.oParam.pa_keyname)
           *ckEyfxp = "KEY"+ALLTRIM(_screen.oGlobal.oParam.pa_keyname)
           *IF FILE(ckEyfxp+".FXP")
           *     On Selection Bar 60 Of puOther Do &cKeyFxp With "EXTRA"
           *ELSE
           *     = msGbox("Keycard interface driver "+ckEyfxp+ ;
           *       ".FXP not found!","Brilliant Interface",16)
           *ENDIF
      *ELSE
      *     ON SELECTION BAR 60 OF puOther =LOGMENU("OTHER|KEY CARDS", "EXTRACARDS IN KEYCARD")
      *ENDIF
 ENDIF
 IF (_screen.oGlobal.oParam.pa_pttcico)
      DEFINE BAR 70 OF puOther PROMPT "\-"
      IF definebar(71,"puOther",GetLangText("MENU","IFC_LOCKUNLOCK"),"Other",7,"","","")
           ON SELECTION BAR 71 OF puOther =LOGMENU("OTHER|PHONE MANGER", "LOCKUNLOCK IN PHONE")
      ENDIF
 ENDIF
 IF (TYPE("_screen.oGlobal.oParam.Pa_PttCel")=="C") AND _SCREEN.IT
      IF ( .NOT. EMPTY(_screen.oGlobal.oParam.pa_pttcel)) AND ;
           definebar(72,"puOther",GetLangText("MENU","IFC_BOOTH"),"Other",8,"","","F11")
           ON SELECTION BAR 72 OF puOther =LOGMENU("OTHER|PHONE BOOTH", "BOOTH IN BOOTH")
      ENDIF
 ENDIF
 IF _SCREEN.AZE AND definebar(75,"puOther",GetLangText("MENU","OTH_AZE"),"Aze",1,"","bitmap\toolbar\many-people.png","") && to do: Change user right for this!!!
      DEFINE BAR 76 OF puOther PROMPT "\-" BEFORE 75
      ON BAR 75 OF puOther ACTIVATE POPUP popaze
      DEFINE POPUP popaze SHADOW MARGIN RELATIVE
      IF definebar(1,"popaze",GetLangText("MENU","AZE_EMPLOYEE"),"Aze",2,"","","")
           ON SELECTION BAR 1 OF popaze =LOGMENU("OTHER|AZE|AZE_EMPLOYEE","employees IN mgraze")
      ENDIF
      IF definebar(2,"popaze",GetLangText("MENU","AZE_ASSIGNED_TIME_OVERVIEW"),"AZE",3,"","","")
           ON SELECTION BAR 2 OF popaze =LOGMENU("OTHER|AZE|AZE_ASSIGNED_TIME_OVERVIEW","monthtimeplan IN procaze")
      ENDIF
      IF definebar(3,"popaze",GetLangText("MENU","AZE_WORKING_TIME_OVERVIEW"),"Aze",4,"","","")
           ON SELECTION BAR 3 OF popaze =LOGMENU("OTHER|AZE|AZE_WORKING_TIME_OVERVIEW","workplanbrowse IN procaze")
      ENDIF
      IF definebar(4,"popaze",GetLangText("MENU","AZE_WORK_BEGIN_END"),"Aze",5,"","","")
           ON SELECTION BAR 4 OF popaze =LOGMENU("OTHER|AZE|AZE_WORK_BEGIN_END","workhourshandle IN procaze")
      ENDIF
      IF definebar(5,"popaze",GetLangText("MENU","AZE_PAUSE_BEGIN_END"),"Aze",6,"","","")
           ON SELECTION BAR 5 OF popaze =LOGMENU("OTHER|AZE|AZE_PAUSE_BEGIN_END","workpausehandle IN procaze")
      ENDIF
 ENDIF

 DEFINE BAR 99 OF puOther PROMPT "\-"
 IF definebar(100,"puOther",GetLangText("MENU","OTH_AUDIT"),"Other",4,"","bitmap\toolbar\globe.png","")
      ON SELECTION BAR 100 OF puOther =LOGMENU("OTHER|NIGHT AUDIT", "CHECKWIN IN CHECKWIN WITH 'NIGHTAUDIT IN AUDIT',.T.")
 ENDIF
 IF (_screen.oGlobal.oParam.pa_mnuextr)
      IF (opEnfile(.F.,"Menu",.f.,.t.))
           DEFINE POPUP puExtra SHADOW MARGIN RELATIVE
           l_cCurMenu = sqlcursor("SELECT * FROM menu ORDER BY mn_sequ")
           SELECT (l_cCurMenu)
           DO WHILE ( .NOT. EOF(l_cCurMenu))
                cnAme = ALLTRIM(EVALUATE(l_cCurMenu+".Mn_Lang"+g_Langnum))
                cfUnction = ALLTRIM(&l_cCurMenu..mn_func)
                nsEquence = &l_cCurMenu..mn_sequ
                nBar = nsEquence
                IF LEFT(cfUnction,1) = "_" AND TYPE(cfUnction) = "N"
                     nBar = &cfUnction
                ENDIF
                IF NOT EMPTY(cnAme) AND NOT EMPTY(cfUnction) AND NOT EMPTY(nsEquence) AND (nBar = nsEquence) AND ;
                          definebar(nBar,"puExtra",cnAme,IIF(BETWEEN(nsEquence,1,16),"Extra",""),nsEquence,"","","")
                     IF ".EXE" $ UPPER(cFunction) AND NOT "REGISTERCOMCOMPONENT" $ UPPER(cFunction) AND NOT "REGISTERDOTNETCOMPONENT" $ UPPER(cFunction)
                          ON SELECTION BAR (nSequence) OF puExtra Run /N4 &cFunction
                     ELSE
                          IF EMPTY(&l_cCurMenu..mn_files) AND NOT EMPTY(_screen.oGlobal.choteldir)
                               DO CASE
                                    CASE "()" $ cFunction
                                         cFunction = ALLTRIM(STRTRAN(cFunction, "()", ""))
                                    CASE "(" $ cFunction
                                         cFunction = STRTRAN(cFunction, "(", " WITH ")
                                         cFunction = STRTRAN(cFunction, ")", "")
                               ENDCASE
                               cFunction = "DO " + _screen.oGlobal.choteldir + cFunction
                          ENDIF
                          l_cExtraCmd = 'On Selection Bar ('+TRANSFORM(nSequence)+') Of puExtra =LOGMENU([EXTRA|'+TRANSFORM(cfUnction)+'], ['+cFunction+'],.T.)'
                          &l_cExtraCmd
                          *On Selection Bar (nSequence) Of puExtra &l_cExtraCmd
                     ENDIF
                ENDIF
                SKIP 1 IN &l_cCurMenu
           ENDDO
           dclose(l_cCurMenu)
      ENDIF
      = clOsefile("Menu")
 ENDIF

 IF _screen.oGlobal.lmultiproper
      DEFINE POPUP puMultiproper SHADOW MARGIN RELATIVE
      IF definebar(10,"puMultiproper",GetLangText("MENU","MP_CHOOSE_HOTEL"),"Multipr",1,"","bitmap\toolbar\multiproper.png","")
           ON SELECTION BAR 10 OF puMultiproper =LOGMENU("MULTIPROPER|CHOOSE HOTEL", "PROCMULTIPROPER")
      ENDIF
      DEFINE BAR 19 OF puMultiproper PROMPT "\-"
      IF definebar(20,"puMultiproper","\<" + GetLangText("ADDRESS","TXT_MAIN_SERVER_ADDRESSES"),"Multipr",2,"","bitmap\toolbar\customer.png")
           ON SELECTION BAR 20 OF puMultiproper =LOGMENU("ADDRESSES|SERVER ADDRESSES", "DOFORM WITH 'addressmainbook','forms\srvadrmain'")
      ENDIF
      IF definebar(25,"puMultiproper","\<" + GetLangText("ADDRESS","TXT_MAIN_SERVER_MAILING"),"Multipr",3,"","bitmap\toolbar\note01.png")
           ON SELECTION BAR 25 OF puMultiproper =LOGMENU("MULTIPROPER|MAILING SERVER", "DOFORM WITH 'mailingformmp','forms\mailingform WITH .T.'")
      ENDIF
      DEFINE BAR 29 OF puMultiproper PROMPT "\-"
      IF definebar(30,"puMultiproper",GetLangText("MENU","TXT_MP_ALL_RESERVATIONS"),"Multipr",4,"","bitmap\toolbar\rsbmainbook.png")
           ON SELECTION BAR 30 OF puMultiproper =LOGMENU("MULTIPROPER|RESERVATIONS", "DOFORM WITH 'rsbmainbook','forms\srvreservat'")
      ENDIF
      DEFINE BAR 39 OF puMultiproper PROMPT "\-"
      IF definebar(40,"puMultiproper",GetLangText("MENU","VEW_AVAIL"),"Multipr",5,"","bitmap\toolbar\graph05.png")
           ON SELECTION BAR 40 OF puMultiproper =LOGMENU("MULTIPROPER|AVAILABILITY", "VEWMULTIPROPAVAIL IN VIEW")
      ENDIF
      DEFINE BAR 49 OF puMultiproper PROMPT "\-"
      IF definebar(50,"puMultiproper",GetLangText("MENU","VEW_ROOMPLAN"),"Multipr",6,"","bitmap\toolbar\mac01.png")
           ON SELECTION BAR 50 OF puMultiproper =LOGMENU("MULTIPROPER|ROOMS WEEKPLAN", "PLANMULTIPROP IN PLAN")
      ENDIF
      DEFINE BAR 80 OF puMultiproper PROMPT "\-"
      l_cCurMenu = SqlCursor("SELECT li_menu FROM lists WHERE li_menu > 0 AND li_menu <> 9 AND NOT li_hide AND li_mainsrv = (1=1) GROUP BY li_menu")
      IF USED(l_cCurMenu) AND RECCOUNT(l_cCurMenu) > 0
           GetChecks(@acChecks,,"REPORT")
           nBar = 80
           SELECT &l_cCurMenu
           SCAN FOR NOT EMPTY(acChecks[li_menu])
                nBar = nBar + 1 
                IF definebar(nBar,"puMultiproper",acChecks[li_menu],"Report",li_menu,"","bitmap\toolbar\note01.png","")
                     cMacro = 'LOGMENU("MULTIPROPER|REPORTS-'+UPPER(acChecks[li_menu])+'", "LISTS WITH '+TRANSFORM(li_menu)+', PROMPT(), .T. IN MYLISTS")'
                     ON SELECTION BAR nBar OF puMultiproper &cMacro
                ENDIF
           ENDSCAN
      ENDIF
      CloseFile(l_cCurMenu)
      DEFINE BAR 100 OF puMultiproper PROMPT "\-"
      IF definebar(110,"puMultiproper",GetLangText("MENU","MGR_MAIN_SERVER_SETTINGS"),"Multipr",16,"","","")
           ON SELECTION BAR 110 OF puMultiproper =LOGMENU("MULTIPROPER|MAIN SERVER SETTINGS",  "DOFORM IN DOFORM WITH 'frmsrvsettings','forms/srvsettings.scx'")
      ENDIF
 ENDIF

 *** Window
 DEFINE POPUP puWindow SHADOW MARGIN RELATIVE
 DEFINE BAR _MWI_CASCADE OF puWindow PROMPT GetLangText("MENU","WND_CASCADE") PICTRES _MWI_CASCADE
 DEFINE BAR _MWI_ARRAN OF puWindow PROMPT GetLangText("MENU","WND_ARRANGE") PICTRES _MWI_ARRAN
 DEFINE BAR 10 OF puWindow PROMPT "\-"
 DEFINE BAR 20 OF puWindow PROMPT GetLangText("MENU","TXT_NAVIG_PANE")
 IF _screen.oGlobal.lwebbrowserdesktop
      DEFINE BAR 30 OF puWindow PROMPT GetLangText("MENU","FAV_MYDESK")
 ENDIF
 DEFINE BAR 35 OF puWindow PROMPT "\-"
 DEFINE BAR 40 OF puWindow PROMPT GetLangText("MENU","WND_REFRESH") KEY "F5", "F5"
 DEFINE BAR 50 OF puWindow PROMPT "\-"
 ON SELECTION BAR 20 OF puWindow =LOGMENU("WINDOWS|NAVIGATION PANE", "NavigationPane IN procnavpane")
 IF _screen.oGlobal.lwebbrowserdesktop
      ON SELECTION BAR 30 OF puWindow MdShow()
 ENDIF
 ON SELECTION BAR 40 OF puWindow DO DoRefresh IN MainMenu
 g_oWinEvents.BindEvents(application.hWnd, WM_ENTERMENULOOP, WINDOW_LIST_MENU)

 *l_Filename = "Help\Help_"+g_Language+".hlp"
 l_Filename = "Help\Help_"+g_Language+".chm"
 DEFINE POPUP puHelp SHADOW MARGIN RELATIVE
 IF (FILE(l_Filename))
      definebar(1,"puHelp",GetLangText("MENU","HLP_CONTENT"),"",,"","bitmap\toolbar\help3.png")
      DEFINE BAR 3 OF puHelp PROMPT "\-"
      definebar(4,"puHelp",GetLangText("MENU","HLP_ABOUT"),"",,"","bitmap\toolbar\info.png")
      definebar(5,"puHelp",GetLangText("MENU","HLP_SYSINFO"),"",,"","bitmap\toolbar\sysinfo.png")
 ELSE
      definebar(1,"puHelp",GetLangText("MENU","HLP_ABOUT"),"",,"","bitmap\toolbar\help3.png")
      definebar(2,"puHelp",GetLangText("MENU","HLP_SYSINFO"),"",,"","bitmap\toolbar\sysinfo.png")
 ENDIF
 DEFINE BAR 90 OF puHelp PROMPT '\-'
 definebar(10,"puHelp",GetLangText("MENU","HLP_WWW"),"",,"","bitmap\toolbar\web24.png")
 IF NOT EMPTY(_screen.oGlobal.cUpdateNewsURL)
      definebar(15,"puHelp",GetLangText("MENU","HLP_LATEST_NEWS"),"",,"","bitmap\toolbar\release-notes.png")
 ENDIF
 IF g_Demo
      definebar(20,"puHelp",GetLangText("MENU","HLP_MAIL_INFO"),"",,"","bitmap\toolbar\mail.png")
 ELSE
      definebar(20,"puHelp",GetLangText("MENU","HLP_MAIL_SUPPORT"),"",,"","bitmap\toolbar\mail.png")
 ENDIF
 IF (FILE(l_Filename))
      ON SELECTION BAR 1 OF puHelp =LOGMENU("HELP|CONTENTS", "HELPME IN HELP")
      *ON SELECTION BAR 2 OF puHelp =LOGMENU("HELP|SEARCH", "HELPME WITH .T. IN HELP")
      ON SELECTION BAR 4 OF puHelp =LOGMENU("HELP|ABOUT CITADEL DESK...", "ABOUT IN HELP")
      ON SELECTION BAR 5 OF puHelp =LOGMENU("HELP|SYSTEM", "SYSTEM IN HELP")
 ELSE
      ON SELECTION BAR 1 OF puHelp =LOGMENU("HELP|ABOUT CITADEL DESK...", "ABOUT IN HELP")
      ON SELECTION BAR 2 OF puHelp =LOGMENU("HELP|SYSTEM", "SYSTEM IN HELP")
 ENDIF
 ON SELECTION BAR 10 OF puHelp WINEXECUTE('HTTP://WWW.CITADEL.DE')
 IF NOT EMPTY(_screen.oGlobal.cUpdateNewsURL)
      ON SELECTION BAR 15 OF puHelp WINEXECUTE(_screen.oGlobal.cUpdateNewsURL)
 ENDIF
 IF g_Demo
      ON SELECTION BAR 20 OF puHelp WINEXECUTE('MAILTO:INFO@CITADEL.DE')
 ELSE
      ON SELECTION BAR 20 OF puHelp WINEXECUTE('MAILTO:SUPPORT@CITADEL.DE')
 ENDIF
 IF TYPE("g_lDevelopment")=="L" AND g_lDevelopment
      DEFINE BAR _MTL_DEBUGGER OF puHelp PROMPT "Debuger"
 ENDIF
 IF g_lCheckLang
      DEFINE BAR 30 OF puHelp PROMPT "Language" KEY ALT+F10
      ON SELECTION BAR 30 OF puHelp DO FORM "forms/language"
 ENDIF
 RETURN
ENDPROC
*
FUNCTION GetChecks
 LPARAMETER acChecks, alChecks, tcMenu
 EXTERNAL ARRAY acChecks
 EXTERNAL ARRAY alChecks
 LOCAL i, lcCurMenu

 DIMENSION acChecks[18], alChecks[18]
 STORE " " TO acChecks
 STORE .F. TO alChecks
 DO CASE
      CASE tcMenu = "FILE"
           acChecks[1] = STRTRAN(GetLangText("MENU","FIL_MAINTENANCE"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","FIL_MANAGER"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","FIL_LOGIN"), "\<", "")
           acChecks[4] = STRTRAN(GetLangText("MENU","FIL_PASSWORD"), "\<", "")
           acChecks[5] = STRTRAN(GetLangText("MENU","FIL_PRTSETUP"), "\<", "")
           acChecks[6] = STRTRAN(GetLangText("MENU","FIL_EXIT"), "\<", "")
           acChecks[7] = STRTRAN(GetLangText("MENU","FIL_ACTION"), "\<", "")
      CASE tcMenu = "RESERVA"
           acChecks[1] = STRTRAN(GetLangText("MENU","RES_ALL"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","RES_ROOMLIST"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","RES_WALKIN"), "\<", "")
           acChecks[16] = STRTRAN(GetLangText("MENU","RES_SHEET"), "\<", "")
      CASE tcMenu = "ADDRESS"
           acChecks[1] = STRTRAN(GetLangText("MENU","ADD_ALL"), "\<", "")
      CASE tcMenu = "FINANC"
           acChecks[1] = STRTRAN(GetLangText("MENU","FIN_POST"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","FIN_CHECKOUT"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","FIN_PASSERBY"), "\<", "")
           acChecks[4] = STRTRAN(GetLangText("MENU","FIN_CLOSE"), "\<", "")
           acChecks[5] = STRTRAN(GetLangText("MENU","FIN_EXCHANGE"), "\<", "")
           acChecks[6] = STRTRAN(GetLangText("MENU","FIN_TOFROMBANK"), "\<", "")
           acChecks[7] = STRTRAN(GetLangText("MENU","FIN_LEDGER"), "\<", "")
           acChecks[8] = STRTRAN(GetLangText("MENU","FIN_HISTORY"), "\<", "")
           acChecks[9] = STRTRAN(GetLangText("MENU","TXT_RATE_CODE_POST"), "\<", "")
           acChecks[10] = STRTRAN(GetLangText("MENU","FIN_VOUCHER"), "\<", "")
           acChecks[12] = STRTRAN(GetLangText("MENU","FIN_CASHINOUT"), "\<", "")
      CASE tcMenu = "VIEW"
           acChecks[1] = STRTRAN(GetLangText("MENU","VEW_ARRIVAL"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","VEW_DEPARTURE"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","VEW_INHOUSE"), "\<", "")
           acChecks[4] = STRTRAN(GetLangText("MENU","VEW_CASHIER"), "\<", "")
           acChecks[5] = STRTRAN(GetLangText("MENU","VEW_RATECODE"), "\<", "")
           acChecks[6] = STRTRAN(GetLangText("MENU","VEW_AVAIL"), "\<", "")
           acChecks[7] = STRTRAN(GetLangText("MENU","VEW_MAXAVAIL"), "\<", "")
           acChecks[8] = STRTRAN(GetLangText("MENU","VEW_ALLOTMENTS"), "\<", "")
           acChecks[9] = STRTRAN(GetLangText("MENU","VEW_WEEK"), "\<", "")
           acChecks[10] = STRTRAN(GetLangText("MENU","VEW_CONFWEEK"), "\<", "")
           acChecks[11] = STRTRAN(GetLangText("MENU","VEW_CONFER"), "\<", "")
           acChecks[12] = STRTRAN(GetLangText("MENU","VEW_PHONE"), "\<", "")
      CASE tcMenu = "OTHER"
           acChecks[1] = STRTRAN(GetLangText("MENU","OTH_HOUSEKEEP"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","OTH_ROOMHIST"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","IFC_WAKEUP"), "\<", "")
           acChecks[4] = STRTRAN(GetLangText("MENU","OTH_AUDIT"), "\<", "")
           acChecks[5] = STRTRAN(GetLangText("MENU","IFC_MESSAGE"), "\<", "")
           acChecks[6] = STRTRAN(GetLangText("MENU","IFC_COPY"), "\<", "")
           acChecks[7] = STRTRAN(GetLangText("MENU","IFC_LOCKUNLOCK"), "\<", "")
           acChecks[8] = STRTRAN(GetLangText("MENU","IFC_BOOTH"), "\<", "")
           acChecks[9] = STRTRAN(GetLangText("MENU","OTH_TPOSOPEN"), "\<", "")
      CASE tcMenu = "REPORT"
           acChecks[1] = STRTRAN(GetLangText("MENU","RPT_RESERVAT"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","RPT_INHOUSE"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","RPT_FINANCIAL"), "\<", "")
           acChecks[4] = STRTRAN(GetLangText("MENU","RPT_CONFERENCE"), "\<", "")
           acChecks[5] = STRTRAN(GetLangText("MENU","RPT_STATISTIC"), "\<", "")
           acChecks[6] = STRTRAN(GetLangText("MENU","RPT_ADDRESS"), "\<", "")
           acChecks[7] = STRTRAN(GetLangText("MENU","RPT_SYSTEM"), "\<", "")
           acChecks[8] = STRTRAN(GetLangText("MENU","RPT_LETTERS"), "\<", "")
           acChecks[9] = STRTRAN(GetLangText("MENU","RPT_BATCH"), "\<", "")
           acChecks[10] = STRTRAN(GetLangText("MENU","RPT_TPOS"), "\<", "")
           acChecks[11] = STRTRAN(ALLTRIM(_screen.oGlobal.oParam.pa_rep13), "\<", "")
           acChecks[12] = STRTRAN(ALLTRIM(_screen.oGlobal.oParam.pa_rep14), "\<", "")
           acChecks[13] = STRTRAN(ALLTRIM(_screen.oGlobal.oParam.pa_rep15), "\<", "")
           acChecks[14] = STRTRAN(GetLangText("MENU","RPT_VOUCHER"), "\<", "")
           acChecks[17] = STRTRAN(GetLangText("MENU","RPT_BASELII"), "\<", "")
      CASE tcMenu = "MAINT"
           acChecks[1] = STRTRAN(GetLangText("MENU","MNT_INDEX"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","MNT_AVAILAB"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","IFC_SYNCHRONISE"), "\<", "")
           acChecks[4] = STRTRAN(GetLangText("MENU","MNT_USERLIST"), "\<", "")
           acChecks[10] = STRTRAN(GetLangText("MENU","MNT_ADPURGE"), "\<", "")
      CASE tcMenu = "MANAGER"
           acChecks[1] = STRTRAN(GetLangText("MENU","MGR_RESERVAT"), "\<", "")
           acChecks[2] = STRTRAN(GetLangText("MENU","MGR_ADDRESS"), "\<", "")
           acChecks[3] = STRTRAN(GetLangText("MENU","MGR_FINANCIAL"), "\<", "")
           acChecks[4] = STRTRAN(GetLangText("MENU","MGR_SYSTEM"), "\<", "")
           acChecks[5] = STRTRAN(GetLangText("MENU","MGR_LISTS"), "\<", "")
           acChecks[6] = STRTRAN(GetLangText("MENU","MGR_BATCHES"), "\<", "")
      CASE tcMenu = "EXTRA"
           IF _screen.oGlobal.oParam.pa_mnuextr
                lcCurMenu = SqlCursor("SELECT mn_sequ, mn_lang" + g_langnum + " AS mn_lang FROM menu WHERE mn_sequ <> 0")
                IF USED(lcCurMenu) AND RECCOUNT(lcCurMenu) > 0
                     SELECT &lcCurMenu
                     SCAN
                          acChecks[mn_sequ] = STRTRAN(ALLTRIM(mn_lang), "\<")
                     ENDSCAN
                ENDIF
                CloseFile(lcCurMenu)
           ENDIF
 ENDCASE
 FOR i = 1 TO 16
      alChecks[i] = NOT NoUserRights(tcMenu,i)
 ENDFOR
 RETURN .T.
ENDFUNC
*
FUNCTION GetRights
 PARAMETER arIghts
 EXTERNAL ARRAY arIghts
 arIghts[1] = STRTRAN(GetLangText("MENU","MNU_FILE"), "\<", "")
 arIghts[2] = STRTRAN(GetLangText("MENU","MNU_RESERVAT"), "\<", "")
 arIghts[3] = STRTRAN(GetLangText("MENU","MNU_ADDRESS"), "\<", "")
 arIghts[4] = STRTRAN(GetLangText("MENU","MNU_FINANCIAL"), "\<", "")
 arIghts[5] = STRTRAN(GetLangText("MENU","MNU_VIEW"), "\<", "")
 arIghts[6] = STRTRAN(GetLangText("MENU","MNU_OTHER"), "\<", "")
 arIghts[7] = STRTRAN(GetLangText("MENU","MNU_REPORT"), "\<", "")
 arIghts[8] = STRTRAN(GetLangText("MENU","FIL_MAINTENANCE"), "\<", "")
 arIghts[9] = STRTRAN(GetLangText("MENU","FIL_MANAGER"), "\<", "")
 arIghts[10] = STRTRAN(GetLangText("MENU","MNU_EXTRA"), "\<", "")
 RETURN .T.
ENDFUNC
*
FUNCTION TestIt
 RUN /n3 \Hotel\Brillist.Exe 1, "TEST"
 ZOOM WINDOW scReen MIN
 RETURN .T.
ENDFUNC
*
PROCEDURE doRefresh
 IF TYPE("_screen.ActiveForm.Name") = "C" AND PEMSTATUS(_screen.ActiveForm, "onRefresh", 5)
      _screen.ActiveForm.OnRefresh()
 ELSE
      MdRefresh()
 ENDIF
ENDPROC
*