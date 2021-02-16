PROCEDURE DoForm
LPARAMETERS tcFormName, tcScxName, tcParams, tlDisableForm, taParams, tlForceOpen, tcCustomMethod
LOCAL i, loForm, llRestart, llFound, lcFormName, lcParams

IF NOT tlForceOpen AND NOT EMPTY(tcFormName)
	* Activate already loaded form.
	llFound = ShowVisibleForm(tcFormName,,tcCustomMethod,@taParams)
ENDIF
IF NOT llFound
	IF tlDisableForm AND TYPE("_screen.ActiveForm") = "O"
		_screen.ActiveForm.Enabled = .F.
	ENDIF
	DO CASE
		CASE INLIST(LOWER(tcScxName), "forms\addressmask", "forms\reservat", "forms\bills")
			* Check reusable forms.
			FOR EACH loForm IN _screen.Forms
				IF NOT loForm.Visible AND TYPE("loForm.FormName") = "C" AND UPPER(ALLTRIM(loForm.FormName)) == UPPER(ALLTRIM(tcFormName)) AND ;
						TYPE("loForm.lCloseOnFinish") = "L" AND NOT loForm.lCloseOnFinish
					llRestart = .T.
					EXIT
				ENDIF
			NEXT
		CASE Odbc()
			* Check '_pg_...' forms.
			lcFormName = GETWORDNUM(tcScxName,1)
			IF FILE(FORCEEXT(STRTRAN(lcFormName, JUSTSTEM(lcFormName), "_pg_" + JUSTSTEM(lcFormName)),"scx"))
				tcScxName = STRTRAN(tcScxName, JUSTSTEM(lcFormName), "_pg_" + JUSTSTEM(lcFormName))
			ENDIF
		OTHERWISE
	ENDCASE
	* Prepare parameters.
	IF PCOUNT() > 4
		lcParams = ""
		FOR i = 1 TO ALEN(taParams)
			lcParams = lcParams + IIF(EMPTY(lcParams), "", ", ") + "taParams(" + TRANSFORM(i) + ")"
		NEXT
		IF NOT llRestart AND NOT EMPTY(lcParams)
			lcParams = "WITH " + lcParams
		ENDIF
	ELSE
		lcParams = EVL(tcParams,"")
	ENDIF
	IF llRestart
		* Show reusable form.
		loForm.Parent.MainEntryPoint(&lcParams)
	ELSE
		* Load a form.
		DO FORM &tcScxName &lcParams
	ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE ShowVisibleForm
LPARAMETERS tcFormName, tlFound, tcCustomMethod,taParams
LOCAL loForm, lcParams, i
lcParams = ""

* Activate already loaded form.
FOR EACH loForm IN _screen.Forms
	IF UPPER(loForm.BaseClass) = "FORM" AND loForm.Visible AND loForm.Enabled AND ;
			TYPE("loForm.FormName") = "C" AND UPPER(ALLTRIM(loForm.FormName)) == UPPER(ALLTRIM(tcFormName))
		IF loForm.WindowState = 1
			loForm.WindowState = 0
		ENDIF
		IF NOT EMPTY(tcCustomMethod)
			IF PCOUNT() > 3
				lcParams = ""
				FOR i = 1 TO ALEN(taParams)
					lcParams = lcParams + IIF(EMPTY(lcParams), "", ", ") + "taParams(" + TRANSFORM(i) + ")"
				NEXT
			ENDIF
			l_cMacro = "loForm." + tcCustomMethod + "(" + lcParams + ")"
			&l_cMacro
		ELSE
			loForm.Show()
		ENDIF 
		ControlSetFocus(loForm, .T.)
		tlFound = .T.
		EXIT
	ENDIF
NEXT

RETURN tlFound
ENDPROC
*