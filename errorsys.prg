 PARAMETER p_Error, p_Message, p_Procedure, p_Line, p_Code
 PUBLIC glPrgerror
 PRIVATE lgEnerror
 PRIVATE ccAllstack, nsTackcount
 PRIVATE ALL LIKE l_*
 PRIVATE cmAcro
 LOCAL l_lFF, lDoExitProcess, l_cMainErrorMessage
 glPrgerror = .F.
 lgEnerror = .F.
 lsYserror = .F.
 l_Handle = -1
 nsTackcount = 1
 ccAllstack = ""
 DO WHILE PROGRAM(nsTackcount) <> p_Procedure
      ccAllstack = ccAllstack + PROGRAM(nsTackcount) + " "
      nsTackcount = nsTackcount + 1
 ENDDO
 l_cMainErrorMessage = ALLTRIM(_screen.Caption) + CHR(10) + ;
                       IIF(TYPE("g_Hotel") = "C", "Hotel: " + g_Hotel + CHR(10), "") + ;
                       "Error: " + TRANSFORM(p_Error) + CHR(10) + ;
                       "Message: " + p_Message + CHR(10) + ;
                       "Procedure: " + p_Procedure + CHR(10) + ;
                       "Called from: " + ccAllstack + CHR(10) + ;
                       "Line: " + TRANSFORM(p_Line) + CHR(10) + ;
                       "Code: " + p_Code

 DO CASE
      CASE p_Error==1958
           = alert(p_Message)
      CASE p_Error==1579
           * Command cannot be issued on a table with cursors in table buffering mode 
           LOCAL lcMessage
           lcMessage = ""
           DO CASE
                CASE g_IndexOnBuffFailed = 1
                     g_IndexOnBuffFailed = 2
                     lcMessage = "Please first close Reservation List window, and try again."
                OTHERWISE
                     g_IndexOnBuffFailed = 0
                     lcMessage = "Some errors occoured. Please inform your vendor with this message: BUFF INDX "+ALIAS()
           ENDCASE
           = alert(lcMessage)
      CASE p_Error==17
           lsYserror = .F.
      CASE p_Error==1 .OR. p_Error==1162
           = alErt(p_Message,"ERROR")
           glPrgerror = .T.
      CASE p_Error==5
      CASE p_Error==38
      CASE p_Error==4
      CASE p_Error==1108
      CASE p_Error==2034
           DO whatread
      CASE p_Error==30
      CASE p_Error==56
           = alErt(p_Message,"ERROR")
      CASE p_Error==1644 .OR. p_Error==125
           = alErt(p_Message,"ERROR")
           lsYserror = .T.
      CASE p_Error==3 .OR. p_Error==1705
           lnEterror = .T.
      CASE p_Error==1405
           = alErt(GetLangText("ERRORSYS","TXT_RUN_FAILED"),GetLangText("ERRORSYS", ;
             "TXT_ERROR_MESSAGE"))
           lsYserror = .T.
      CASE p_Error==1249
           CLEAR READ
           WAIT WINDOW TIMEOUT 0.1 GetLangText("ERRORSYS","TA_CLOSEWINS")+"!"
           lsYserror = .T.
      CASE p_Procedure == "PRTREPORT" OR glInreport
*          IF g_newversionactive
*               LOCAL l_Errormessage,nsElected 
*               DO CASE
*                    CASE p_error=1426
*                         lsYserror = .F.
*                    CASE p_error=1429 &&AND errarray(7)=4605
*                         lsYserror = .F.
*                    OTHERWISE
*                         l_Errormessage = "Error "+Ltrim(Str(p_Error))+" in "+ p_Procedure+"("+Ltrim(Str(p_Line))+")"
*                         DO FORM forms\sqlerror TO nselected WITH "SQL definition Error",GetLangText("ERRORSYS","TXT_WRITE_DOWN_THIS_MESSAGE")+CHR(13)+ l_Errormessage,"bitmap\Stop.Ico"
*                         IF nsElected==2
*                              l_Errormessage = "Error:"+Ltrim(STR(p_Error))+CHR(13)+"Message:"+ p_Message+CHR(13)+"Procedure:"+p_Procedure+CHR(13)+ "Line:"+Ltrim(Str(p_Line))+CHR(13)+"Code:"+p_Code
*                              DO FORM forms\sqlerror TO nselected WITH "SQL definition Error Detail",l_Errormessage,"bitmap\Info.Ico"	
*                                   IF nselected=2
*                                        = alErt(csQlstatement,"Executing SQL statement")
*                                   ENDIF
*                         ENDIF
*                         lsYserror = .T.
*                    ENDCASE
*          ELSE
           DO CASE
                CASE p_error=1426
                     *OLE Error
                OTHERWISE
                     l_Errormessage = GetLangText("ERRORSYS","TXT_WRITE_DOWN_THIS_MESSAGE") + ";" + ;
                                      "Error " + TRANSFORM(p_Error) + " in " + p_Procedure + "(" + TRANSFORM(p_Line) + ")"
                     IF seLectmessage("SQL definition Error", GetLangText("COMMON", "TXT_OK")+";"+GetLangText("ERRORSYS","TXT_INFO"), l_Errormessage, "bitmap\Stop.Ico") = 2
                          IF seLectmessage("SQL definition Error Detail", GetLangText("COMMON","TXT_OK")+IIF(p_Procedure == "PRTREPORT",";"+GetLangText("ERRORSYS","TXT_INFO"),""), l_cMainErrorMessage, "bitmap\Info.Ico") = 2 AND p_Procedure == "PRTREPORT"
                               = alErt(csQlstatement,"Executing SQL statement")
                          ENDIF
                     ENDIF
                     IF glOutIfErrorInReport
                          lgEnerror = .T.
                          glInreport = .F.
                     ELSE
                          lsYserror = .T.
                     ENDIF
           ENDCASE
*          ENDIF
      CASE p_Error==1707
           RETRY
      CASE p_Error==12
           IF ("Variable 'TXT_"=SUBSTR(p_Message, 1, 14))
                cmAcro = SUBSTR(p_Message, 11, AT("'", p_Message, 2)-12)
                WAIT WINDOW NOWAIT "Missing Text:"+cmAcro
                &cMacro   = cMacro
                lsYserror = .T.
           ELSE
                lgEnerror = .T.
           ENDIF
      CASE p_error==1104 OR p_error==1103
           IF _screen.oGlobal.lexitwhennetworksharelost
                MESSAGEBOX("Lost connection to database. Application would exit now!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Time: " +TTOC(DATETIME()),48,"Citadel Desk",30000)
                lDoExitProcess = .T.
           ELSE
                MESSAGEBOX("Network resource is not available")
           ENDIF
          lgEnerror = .T.
      CASE p_error==108
           MESSAGEBOX(GetLangText("COMMON","T_FILE_IS LOCKED"),48,GetLangText("RECURRES","TXT_INFORMATION"))
      CASE p_error==109 OR p_error==109
           MESSAGEBOX(GetLangText("COMMON","T_RECORD_IS LOCKED"),48,GetLangText("RECURRES","TXT_INFORMATION"))
      OTHERWISE
           lgEnerror = .T.
 ENDCASE
 IF (lgEnerror)
      IF g_debug
           l_Errormessage = l_cMainErrorMessage
           l_Errormessage = "Error: " + TRANSFORM(p_Error) + CHR(10) + ;
                            "Message: " + p_Message + CHR(10) + ;
                            "Procedure: " + p_Procedure
           SET STEP ON
           IF .F.
                RETURN .T.	&& Step here in debuger, to continue program execution
                RETRY		&& Step here in debuger, to retry program execution
           ENDIF
      ENDIF
      IF glInreport
           glErrorinreport = .T.
      ELSE
           CLEAR READ
           p_cAutoYield = TRANSFORM(_vfp.AutoYield)
           l_lFF = .F.
           TRY
                l_lFF = _screen.oglobal.lFlushForce
           CATCH
           ENDTRY
           l_Errormessage =  l_cMainErrorMessage + CHR(10) + "AY = " + p_cAutoYield + "|FF = " + TRANSFORM(l_lFF)
           IF g_myerrorhandle
                RELEASE oerror
                PUBLIC oerror
                oerror=CREATEOBJECT('_error')
                oerror.cdatadir = gcdatadir
                oerror.handle(p_Error, p_Procedure, p_Line,p_Message)
           ENDIF
           ON ERROR *
           action(6)
           = erRormsg(l_Errormessage,.F.)
           IF lDoExitProcess
                ExitProcess()
           ENDIF
           DO SetMessagesOff IN procmessages
           = msGbox(l_Errormessage,getapplangtext("LOGIN","TXT_SYSTEM_ERROR"),016)
           = checkwin("cleanup",,.T.,.T.)
           RETURN TO MASTER
      ENDIF
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE StartErrorHnd
LPARAMETERS tnError, tcMessage, tcMethod, tnLine, tnCode
#DEFINE CRLF		CHR(13)+CHR(10)
LOCAL llShowErrorMessage, lcErrorMsg, lcErrorDescription, lcCallStack, lnStackCount, lcProgram
LOCAL ARRAY laError(1)

AERROR(laError)
llShowErrorMessage = .T.

IF BETWEEN(tnError, 1427, 1429) OR tnError = 1526
	lcErrorMsg = TRANSFORM(laError(3))
ELSE
	lcErrorMsg = MESSAGE()
ENDIF

lcErrorDescription = "Line: " + TRANSFORM(tnLine) + CRLF + ;
		"1:" + TRANSFORM(laError(1)) + CRLF + ;
		"2:" + TRANSFORM(laError(2)) + CRLF + ;
		"3:" + TRANSFORM(NVL(laError(3),"")) + CRLF + ;
		"4:" + TRANSFORM(NVL(laError(4),"")) + CRLF + ;
		"5:" + TRANSFORM(NVL(laError(5),"")) + CRLF + ;
		"6:" + TRANSFORM(NVL(laError(6),"")) + CRLF + ;
		"7:" + TRANSFORM(NVL(laError(7),"")) + CRLF

lnStackCount = 1
lcCallStack = ""
lcProgram = PROGRAM()
DO WHILE PROGRAM(lnStackCount) <> lcProgram
	lcCallStack = lcCallStack + PROGRAM(lnStackCount) + " "
	lnStackCount = lnStackCount + 1
ENDDO

lcErrorMsg = TTOC(DATETIME()) + " ::" + _VFP.FullName + ":: " + CRLF + ALLTRIM(_Screen.Caption) + " :: " + CRLF + lcErrorMsg + CRLF
lcErrorMsg = lcErrorMsg + lcErrorDescription + ALLTRIM(lcCallStack) + CRLF + CRLF

STRTOFILE(lcErrorMsg, "Hotel.Err", .T.)

IF Application.StartMode = 0
	SET STEP ON
	IF .F.
		RETRY		&& Step here in debuger, to retry program execution
	ENDIF
ENDIF

IF llShowErrorMessage
	MESSAGEBOX(lcErrorMsg, 16, "Error")
ENDIF
ENDPROC
*