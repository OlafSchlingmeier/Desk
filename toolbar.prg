PROCEDURE ShowColumnMenu
LPARAMETERS lp_cObject, lp_cGrid, lp_nXPos

=PopupColumnMenu(lp_cObject, lp_cGrid, lp_nXPos)
ACTIVATE POPUP puCol
ENDPROC
*
PROCEDURE GridDefinition
LPARAMETERS lp_cObject, lp_cGrid
LOCAL l_oGridDefForm

l_oGridDefForm = NEWOBJECT("tGridDef", "", "", &lp_cObject, lp_cGrid, IIF(TYPE("_screen.ActiveForm") = "U", .NULL., _screen.ActiveForm))
l_oGridDefForm.Show()
ENDPROC
*
PROCEDURE PopupColumnMenu
LPARAMETERS lp_cObject, lp_cGrid, lp_nXPos
IF PCOUNT() = 2
	DEFINE POPUP pucol SHORTCUT RELATIVE
ELSE
	DEFINE POPUP pucol SHORTCUT RELATIVE FROM 0, ROUND((lp_nXPos * SCOLS() / _screen.Width) + 1, 0) IN SCREEN
ENDIF

IF EMPTY(lp_cObject) OR EMPTY(lp_cGrid)
	DEFINE BAR 1 OF pucol PROMPT GetLangText("COMMON", "TXT_NO_COLUMNS")
	RETURN
ENDIF

&lp_cObject..PopupColumnMenu(lp_cObject, lp_cGrid, lp_nXPos)

RETURN .T.
ENDPROC
*
PROCEDURE SwitchColumn
LPARAMETERS tnColumnNo, tcObject

IF TYPE(tcObject) = "O"
	&tcObject..Columns(tnColumnNo).Visible = NOT &tcObject..Columns(tnColumnNo).Visible
ENDIF
ENDPROC
*