 LPARAMETER lnOdeleteofuser
 action(999)
 SET REPROCESS TO 1 SECONDS

 IF (PCOUNT()==0)
      lnOdeleteofuser = .F.
 ENDIF

 IF ( .NOT. lnOdeleteofuser)
      IF (USED("License"))
           SELECT liCense
           IF ( .NOT. EOF())
                IF (RLOCK())
                     SCATTER BLANK MEMVAR
                     GATHER MEMVAR
                ENDIF
           ENDIF
      ENDIF
 ENDIF

IF TYPE("_screen.oGlobal.oGData") = "O"
     IF odbc()
          _screen.oGlobal.oGData.ReleaseHandles()
     ENDIF
ENDIF

ProcNavpane("ReleaseNavPane")
*** Now Close other tables and databases
CLOSE TABLES ALL
CLOSE DATA ALL
*** Release Memory Variables, Procedures 
*** and Class Libraries
RELEASE g_dobilltimer, g_oTmrLogOut, g_oMsgHandler, g_oNavigPane
IF NOT g_lDevelopment
	RELEASE g_CryptorObject
ENDIF
ReleaseTransactObject()
UNBINDEVENTS(0)
ON ERROR *
_screen.RemoveObject("ohtml")
_Screen.RemoveObject("oThemesManager")
_Screen.RemoveObject("oCardReaderHandler")
_screen.oGlobal.oStatusBar.RemoveIt()
_Screen.RemoveObject("oGlobal")
_Screen.oProcessHandler = .NULL.
IF !g_debug
	CLEAR EVENTS PROMPT MEMORY WINDOWS MENU POPUPS
*	CLEAR ALL
	SET PROCEDURE TO
	SET CLASSLIB TO
	SET LIBRARY TO
	*With all of this gone we can safely restore the command window and the default system menu and clear out any global settings defined using the ON commands:
	*** Get the command window and system menu back
	SET SYSMENU TO DEFAULT
	*** Clear global settings
	ON SHUTDOWN
	ON KEY
	ON ESCAPE
	WAIT CLEAR
	QUIT
ELSE
*	CLEAR MEMORY
	CLEAR EVENTS PROMPT MEMORY WINDOWS MENU POPUPS
*	CLEAR ALL
	SET PROCEDURE TO
	SET CLASSLIB TO
	SET LIBRARY TO
	SET SAFETY ON
	*With all of this gone we can safely restore the command window and the default system menu and clear out any global settings defined using the ON commands:
	*** Get the command window and system menu back
*	ACTIVATE WINDOW COMMAND
	SET MESSAGE TO
	SET SYSMENU TO DEFAULT
	*** Clear global settings
	ON SHUTDOWN
	ON KEY
	ON ESCAPE
	WAIT CLEAR
	RELEASE g_cittool, goTbrQuick, goTbrMain, g_oWinEvents
	IF FILE("start.fky")
		RESTORE MACROS FROM start.fky
	ENDIF
	ON ERROR
	CANCEL
ENDIF
