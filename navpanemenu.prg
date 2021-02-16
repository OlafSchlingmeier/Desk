
****************************************
* Don't forget to change mainmenu.prg. *
****************************************

 PRIVATE ALL LIKE l_*
 PRIVATE ldOnt
 PRIVATE ckEyfxp
 LOCAL cfUnction, cnAme, nsEquence, nBar, nButton, cMacro
 LOCAL caLtkey, l_lpuReportsCreated
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
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_EDITMENU"))
 define pad pEdit               of _MSYSMENU prompt GetLangText("MENU","MNU_EDITMENU")                key &cAltKey, "" skip FOR InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_GOMENU"))
 define pad pGoMenu               of _MSYSMENU prompt GetLangText("MENU", "MNU_GOMENU")                key &cAltKey, "" skip FOR InLogIn()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_WINDOW"))
 define pad pWindow OF _MSYSMENU prompt GetLangText("MENU","MNU_WINDOW")                     key &cAltKey, "" skip for InLogin()
 caLtkey = 'ALT+'+stRhotkey(GetLangText("MENU","MNU_HELP"))
 define pad pHelp			of _MSYSMENU Prompt GetLangText("MENU", "MNU_HELP")      	key &cAltKey, "" skip FOR InLogIn()
 ON PAD pfIle OF _MSYSMENU ACTIVATE POPUP puFile
 ON PAD pEdit OF _MSYSMENU ACTIVATE POPUP puEditMenu
 ON PAD pGoMenu OF _MSYSMENU ACTIVATE POPUP puGoMenu
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
           ON SELECTION BAR 9 OF puFile =LOGMENU("FILE|PRINTER SETUP",   "FISCALMENU IN PRINTER")
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
 IF (g_Usergroup=="SUPERVISOR" .AND. g_Userid=="SUPERVISOR" .AND. (UPPER(gcApplication)=="CITADEL DESK" OR  (gcApplication = "Application")))
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
*	  IF g_lNewConferenceActive
*	  	DEFINE BAR 40 OF puMgrreservat PROMPT GetLangText("MENU","MGR_ROOM_PICTURES")
 *    ENDIF
*      IF _SCREEN.TG
*	      DEFINE BAR 50 OF puMgrreservat PROMPT GetLangText("MENU","MGR_RESOURCE")
*	      DEFINE BAR 60 OF puMgrreservat PROMPT GetLangText("MENU","MGR_CONFSTAT")
*	      DEFINE BAR 70 OF puMgrreservat PROMPT GetLangText("MENU","MGR_MENU")
*	ENDIF
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
*    IF g_lNewConferenceActive
*	    ON SELECTION BAR 40 OF puMgrreservat DO FORM 'forms\roompicturesviewerform' WITH 2
*	ENDIF
*	IF _SCREEN.TG
*	      ON SELECTION BAR 50 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|RESOURCES", "MGRRESOURCE IN MGRPLIST")
*	      ON SELECTION BAR 60 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|RESOURCES", "MGRCONFSTATUS IN MGRPLIST")
*	      ON SELECTION BAR 70 OF puMgrreservat =LOGMENU("FILE|MANAGER|RESERVATIONS|RESOURCES", "MGRMENU IN MGRPLIST")
*	ENDIF
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
 
 DEFINE POPUP puEditMenu SHADOW MARGIN RELATIVE
 DEFINE BAR _MED_CUT OF puEditMenu PROMPT GetLangText("MENU","MNU_CUT") KEY Ctrl+X
 DEFINE BAR _MED_COPY OF puEditMenu PROMPT GetLangText("MENU","MNU_COPY") KEY Ctrl+C
 DEFINE BAR _MED_PASTE OF puEditMenu PROMPT GetLangText("MENU","MNU_PASTE") KEY Ctrl+V
 
 DEFINE POPUP puGoMenu SHADOW MARGIN RELATIVE
 nButton = 1
 IF definebar(10,"puGoMenu",GetLangText("MENU","MNU_FAVOURITES"),"",0,"","bitmap\toolbar\favourites24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 10 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF .F. &&definebar(20,"puGoMenu",GetLangText("MENU","MNU_FILE"),"",0,"","bitmap\toolbar\admin24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 20 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF definebar(30,"puGoMenu",GetLangText("MENU","MNU_RESERVAT"),"",0,"","bitmap\toolbar\scaner24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 30 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF definebar(40,"puGoMenu",GetLangText("MENU","MNU_ADDRESS"),"",0,"","bitmap\toolbar\contacts24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 40 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF definebar(50,"puGoMenu",GetLangText("MENU","MNU_FINANCIAL"),"",0,"","bitmap\toolbar\notebook24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 50 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF definebar(60,"puGoMenu",GetLangText("MENU","MNU_VIEW"),"",0,"","bitmap\toolbar\monitor24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 60 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF definebar(70,"puGoMenu",GetLangText("MENU","MNU_OTHER"),"",0,"","bitmap\toolbar\tasks24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 70 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF definebar(80,"puGoMenu",GetLangText("MENU","MNU_REPORT"),"",0,"","bitmap\toolbar\views24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 80 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF _screen.oGlobal.oParam.pa_mnuextr AND definebar(90,"puGoMenu",GetLangText("MENU","MNU_EXTRA"),"",0,"","bitmap\toolbar\home24.png","ALT+"+STR(nButton,1))
      cMacro = "g_oNavigPane.Selectedbutton = " + STR(nButton,1)
      ON SELECTION BAR 90 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 IF definebar(100,"puGoMenu",GetLangText("MENU","MNU_HELP"),"",0,"","bitmap\toolbar\worldhand24.png","ALT+"+STR(MOD(nButton,10),1))
      cMacro = "g_oNavigPane.Selectedbutton = " + ALLTRIM(STR(nButton))
      ON SELECTION BAR 100 OF puGoMenu &cMacro
      nButton = nButton + 1
 ENDIF
 DEFINE BAR 105 OF puGoMenu PROMPT "\-"
 IF definebar(110,"puGoMenu",GetLangText("MENU","MNU_THEMES"),"",0,"","","")
      ON BAR 110 OF puGoMenu ACTIVATE POPUP puThemes
      ON SELECTION BAR 100 OF puGoMenu &cMacro
 ENDIF
 DEFINE POPUP puThemes SHADOW MARGIN RELATIVE
 IF _Screen.oThemesManager.OSName=="XP"
      definebar(111,"puThemes",GetLangText("MENU","MNU_THEMES_XPONLY"),"",0," OR .T.",,, "B")
      IF definebar(120,"puThemes",GetLangText("MENU","MNU_THEMES_AUTOMATIC"),"",0,"")
           ON SELECTION BAR 120 OF puThemes _Screen.oThemesManager.ThemeNumber = 0
      ENDIF
      DEFINE BAR 112 OF puThemes PROMPT "\-"
 ENDIF
 definebar(113,"puThemes",GetLangText("MENU","MNU_THEMES_OFFICE2003"),"",0," OR .T.",,, "B")
 IF definebar(121,"puThemes",GetLangText("MENU","MNU_THEMES_BLUE"),"",0,"")
      ON SELECTION BAR 121 OF puThemes _Screen.oThemesManager.ThemeNumber = 1
 ENDIF
 IF definebar(122,"puThemes",GetLangText("MENU","MNU_THEMES_OLIVE"),"",0,"")
      ON SELECTION BAR 122 OF puThemes _Screen.oThemesManager.ThemeNumber = 2
 ENDIF
 IF definebar(123,"puThemes",GetLangText("MENU","MNU_THEMES_SILVER"),"",0,"")
      ON SELECTION BAR 123 OF puThemes _Screen.oThemesManager.ThemeNumber = 3
 ENDIF
 DEFINE BAR 114 OF puThemes PROMPT "\-"
 definebar(115,"puThemes",GetLangText("MENU","MNU_THEMES_OFFICE2007"),"",0," OR .T.",,, "B")
 IF definebar(124,"puThemes",GetLangText("MENU","MNU_THEMES_BLACK"),"",0,"")
      ON SELECTION BAR 124 OF puThemes _Screen.oThemesManager.ThemeNumber = 4
 ENDIF
 IF definebar(125,"puThemes",GetLangText("MENU","MNU_THEMES_BLUE"),"",0,"")
      ON SELECTION BAR 125 OF puThemes _Screen.oThemesManager.ThemeNumber = 5
 ENDIF
 IF definebar(126,"puThemes",GetLangText("MENU","MNU_THEMES_SILVER"),"",0,"")
      ON SELECTION BAR 126 OF puThemes _Screen.oThemesManager.ThemeNumber = 6
 ENDIF
 SET MARK OF BAR 120+_Screen.oThemesManager.ThemeNumber OF puThemes TO .T.

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
 ON SELECTION BAR 20 OF puWindow procnavpane("NavigationPane")
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