*PROCEDURE doindex
IF NOT TYPE("_screen.ActiveForm.name")="U"
	IF (WEXIST ('FAddressMask') OR WEXIST ('FWeekform'))
		MESSAGEBOX(GetLangText("COMMON","T_CLOSEALLWINDOWSFIRST"),16,GetLangText("RECURRES","TXT_INFORMATION"))
		RETURN
	ENDIF
ENDIF
DO FORM "forms\index"
RETURN
ENDPROC
*
PROCEDURE SupervisorReindex
LOCAL lpAck, lcOnsist, lnSelected, llForcePackAllTables
PRIVATE  alGroup
DIMENSION alGroup(11)

IF NOT yesno(GetLangText("ADPURGE","TA_AREYOUSURE"))
    RETURN .T.
ENDIF

lnSelected = SELECT()

DO SetMessagesOff IN procmessages
IF allowlogin(.F.)

    FOR i = 1 TO 11
        alGroup(i) = .T.
    ENDFOR

    lpAck = .T.
    lcOnsist = .F.
    llForcePackAllTables = .T.
    = crEatinx(lpAck,0,lcOnsist, .T., .T., llForcePackAllTables)
ENDIF

DO SetMessagesOn IN procmessages
allowlogin(.T.)

DO reFreshuser IN Login

SELECT (lnSelected)

RETURN .T.
ENDPROC