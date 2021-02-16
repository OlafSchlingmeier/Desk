*
FUNCTION LogMenu
 LPARAMETER tcSelection, tcProcedure, tlNotDO

 IF TYPE("g_lLogUserActions")="L" AND g_lLogUserActions
	LogData(Str2Msg("%s1 %s2 %s3: %s4 %s5", "%s", TTOC(DATETIME()), PADR(WinPC(),10), PADR(g_userid,10), tcSelection, LogMenuGetScreenCaption()), "user.log")
 ENDIF
 IF NOT tlNotDO
	tcProcedure = "DO " + tcProcedure
 ENDIF
 _screen.oGlobal.ExecStatmentInDefDS(tcProcedure)
ENDFUNC
*     
FUNCTION LogNavPane
 LPARAMETER tcNode, tcProcedure

 LogMenu(GetLangText("MENU", "TXT_NAVIG_PANE")+"|"+tcNode+"|"+LogMenuGetScreenCaption(), tcProcedure, .T.)
ENDFUNC
*
FUNCTION LogButton
 LPARAMETER toProcess, tcCallingEvent
 LOCAL lcProcessName, lcFormName

 IF TYPE("g_lLogUserActions")="L" AND g_lLogUserActions
	DO CASE
		CASE TYPE("_screen.ActiveForm") <> "O"
			lcFormName = "(Not from form)"
		CASE TYPE("_screen.ActiveForm.Parent") = "O" AND LOWER(_screen.ActiveForm.Parent.BaseClass) = "formset"
			lcFormName = _screen.ActiveForm.Parent.Name+"."+_screen.ActiveForm.Name
		OTHERWISE
			lcFormName = _screen.ActiveForm.Name
	ENDCASE
	lcProcessName = ICASE(VARTYPE(toProcess) = "C", toProcess, toProcess.BaseClass = "Commandbutton", toProcess.Caption, ;
		toProcess.Class = "Pprocess", ALLTRIM(STRTRAN(STREXTRACT(EVALUATE(toProcess.cCaption),"","(",1,2), "\<"))+"/"+TRANSFORM(toProcess.ProcessNo), "")
	LogData(Str2Msg("%s1 %s2 %s3: %s4 (%s5.%s6) %s7", "%s", TTOC(DATETIME()), PADR(WinPC(),10), PADR(g_userid,10), lcProcessName, lcFormName, tcCallingEvent, LogMenuGetScreenCaption()), "user.log")
 ENDIF
ENDFUNC
*
FUNCTION LogMenuGetScreenCaption
RETURN "[" + STREXTRACT(_screen.Caption, "[")
ENDFUNC