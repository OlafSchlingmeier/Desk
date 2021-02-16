PROCEDURE ProcBillStyle
LPARAMETERS lp_nRsId, lp_nBillWin, lp_lUseBDateInStyle, lp_cHistory
LOCAL l_cResBillStyle, l_nBillStyle

l_nBillStyle = 0
lp_lUseBDateInStyle = .F.
IF PCOUNT() < 3
	RETURN l_nBillStyle
ENDIF
l_cResBillStyle = FNGetWindowData(lp_nRsId, lp_nBillWin, "pw_billsty", lp_cHistory)
DO CASE
	CASE EMPTY(l_cResBillStyle)
		l_nBillStyle = MAX(paRam.pa_billsty, 1)
	CASE BETWEEN(l_cResBillStyle, "0", "9")
		l_nBillStyle = ASC(l_cResBillStyle) - 48
	CASE BETWEEN(l_cResBillStyle, "A", "Z")
		l_nBillStyle = ASC(l_cResBillStyle) - 55
	CASE BETWEEN(l_cResBillStyle, "a", "z")
		l_nBillStyle = ASC(l_cResBillStyle) - 61
	OTHERWISE
		l_nBillStyle = MAX(paRam.pa_billsty, 1)
ENDCASE
lp_lUseBDateInStyle = FNGetWindowData(lp_nRsId, lp_nBillWin, "pw_udbdate", lp_cHistory)

RETURN l_nBillStyle
ENDPROC
*
PROCEDURE WriteBillStyle
LPARAMETERS lp_nRsId, lp_nBillWin, lp_nBillStyle, lp_lUseBDateInStyle
LOCAL l_cStyle

IF PCOUNT() < 3
	RETURN .F.
ENDIF
DO CASE
	CASE BETWEEN(lp_nBillStyle, 0, 9)
		l_cStyle = CHR(lp_nBillStyle+48)
	CASE BETWEEN(lp_nBillStyle, 10, 35)
		l_cStyle = CHR(lp_nBillStyle+55)
	CASE BETWEEN(lp_nBillStyle, 36, 61)
		l_cStyle = CHR(lp_nBillStyle+61)
	OTHERWISE
		l_cStyle = "-"
ENDCASE

CursorQuery("pswindow", StrToSql("pw_rsid = %n1 AND pw_window = %n2", lp_nRsId, lp_nBillWin))
FNSetWindowData(lp_nRsId, lp_nBillWin, "pw_billsty", l_cStyle)
FNSetWindowData(lp_nRsId, lp_nBillWin, "pw_udbdate", lp_lUseBDateInStyle)

RETURN .T.
ENDPROC
*