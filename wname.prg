*
FUNCTION wName
 * Function is called from mylists.prg
 * Determines which Window is opened, and on top of all windows, and returns Window name
 * Prepares enviroment, seeks records
 LPARAMETERS lp_lManagerForm
 LOCAL lnRecNo, lnReserId, lcWonTop, cwInname, l_nAddrId, l_oRef, l_lProceed
 cwInname = ""
 lcWonTop = UPPER(WONTOP())

 DO CASE
	CASE lcWonTop = "FADDRESSMASK"
		IF TYPE("_screen.activeform") = "O"
			l_nAddrId = _screen.activeform.Parent.m_GetSelectedAddress()
			IF odbc()
				IF NOT EMPTY(l_nAddrId)
					cwInname = "WADBROWSE"
				ENDIF
			ELSE
				IF USED("saddress") AND SEEK(l_nAddrId,"saddress","tag1")
					cwInname = "WADBROWSE"
				ENDIF
			ENDIF
		ENDIF
	CASE INLIST(lcWonTop, "FWEEKFORM","CONFERENCEFORM","CONFERENCEDAYFORM") AND NOT IsNull(_screen.activeform.SelectedReser)
		_screen.oGlobal.oBill.nReserId = _screen.activeform.SelectedReser.ReserId
		= SEEK(_screen.activeform.SelectedReser.ReserId, "reservat", "tag1")
		cwInname = "WRSBROWSE"
	CASE lcWonTop = "RESBRW"
		lnReserId = _screen.ActiveForm.GetReserid()
		_screen.oGlobal.oBill.nReserId = lnReserId
		SEEK lnReserId order tag1 IN reservat
		cwInname = "WRSBROWSE"
	CASE lcWonTop = "WLDBROWSE"
		= SEEK(ledgpost.ld_addrid, "saddress", "tag1")
		cwInname = "WLDBROWSE"
	CASE lcWonTop = "TFORM12"
		cwInname = "TFORM12"
		IF TYPE("_screen.activeform.formname")="C"
			DO CASE
				CASE UPPER(_screen.activeform.formname) = "RESERVAT"
					l_oRef = _screen.activeform.Parent
					IF l_oRef.modestart == "NEW" AND l_oRef.mode == "NEW"
						l_lProceed = l_oRef.CheckIfSaved(2)
					ELSE
						l_lProceed = .T.
					ENDIF
					IF l_lProceed
						_screen.activeform.Activate()
						lnReserId = l_oRef.ReserId
						_screen.oGlobal.oBill.nReserId = lnReserId
						IF USED("reservat")
							= SEEK(_screen.oGlobal.oBill.nReserId, "reservat", "tag1")
						ENDIF
						cwInname = "WRESERVAT"
					ENDIF
				CASE UPPER(_screen.activeform.formname) = "QUICKEDIT"
					_screen.oGlobal.oBill.nReserId = _screen.activeform.Parent.getreserid()
			ENDCASE
		ENDIF
	CASE lp_lManagerForm
		IF lcWonTop = "MNGFORM"
			cwInname = UPPER(_screen.ActiveForm.cFormLabel)
		ENDIF
	OTHERWISE
		DEFINE WINDOW wdEmo FROM 10, 10 TO 12.000, 30 FONT "Arial", 10 NOCLOSE  ;
		       NOZOOM TITLE "Check name" IN scReen NOMDI DOUBLE
		ACTIVATE WINDOW wdEmo
		MOVE WINDOW wdEmo CENTER
		cwInname = WLAST()
		DEACTIVATE WINDOW wdEmo
 ENDCASE

 RETURN cwInname
ENDFUNC
*