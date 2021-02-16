#INCLUDE "include\constdefines.h"
*
PROCEDURE MdMyDesk
LPARAMETERS lp_lVisible

IF NOT _screen.oGlobal.lwebbrowserdesktop
	RETURN .T.
ENDIF
IF lp_lVisible
	IF NOT (TYPE("_screen.ohTML") = "O" AND NOT ISNULL(_screen.ohTML))
		_screen.NewObject("ohtml","cnthtml5","libs\aaa_html5.vcx")
	ENDIF
	_screen.oHtml.Visible = .T.
	_screen.Show()
ELSE
	IF TYPE("_screen.ohTML") = "O" AND NOT ISNULL(_screen.ohTML)
		_screen.oHtml.Visible = .F.
		_screen.RemoveObject("ohtml")
	ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE MdWait
DOEVENTS FORCE
sleep(100)
DOEVENTS FORCE
sleep(100)
DOEVENTS FORCE
sleep(100)
RETURN .T.
ENDPROC
*
PROCEDURE MdShow
LOCAL loForm

IF _screen.oGlobal.lwebbrowserdesktop AND TYPE("_screen.ohTML") = "O" AND NOT ISNULL(_screen.ohTML)
	_screen.oHtml.Go()
	FOR EACH loForm IN _Screen.Forms FOXOBJECT
		IF UPPER(loForm.BaseClass) <> "TOOLBAR" AND NOT INLIST(UPPER(loForm.ParentClass), "CRVISUAL") AND ;
				NOT INLIST(UPPER(loForm.Name), "MESSAGESFORM", "FRMNAVPANE", "TNBTHEMEDOUTLOOKNAVBARFRM", "CRHEALTHCARD")
			TRY
				loForm.WindowState = 1
			CATCH
			ENDTRY
		ENDIF
	NEXT
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE MdRefresh
IF _screen.oGlobal.lwebbrowserdesktop AND TYPE("_screen.ohTML") = "O" AND NOT ISNULL(_screen.ohTML)
	_screen.oHtml.Go()
ENDIF
RETURN .T.
ENDPROC
*