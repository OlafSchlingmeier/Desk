LOCAL lnArea, lcWonTop, lcurReservat, lnReserId, lnRsId, llFound, llProceed

lnArea = SELECT()
lcWonTop = WONTOP()
DO CASE
	CASE lcWonTop = 'FWEEKFORM' AND NOT ISNULL(_screen.ActiveForm.SelectedReser)
		lnReserId = _screen.ActiveForm.SelectedReser.ReserId
	CASE lcWonTop = 'RESBRW'
		lnReserId = _screen.ActiveForm.GetReserid()
	OTHERWISE
		RETURN .F.
ENDCASE

lcurReservat = SqlCursor("SELECT rs_rsid, rs_status FROM reservat WHERE rs_reserid = " + SqlCnv(lnReserId))
llFound = RECCOUNT() > 0
llProceed = INLIST(rs_status, "IN", "DEF", "ASG", "6PM", "OPT") OR rs_status = "TEN" AND param.pa_tentdef
lnRsId = rs_rsid
DClose(lcurReservat)

SELECT(lnArea)

DO CASE
	CASE NOT llFound
	CASE NOT llProceed
		MsgBox(GetLangText("PLAN","TA_NOTINYET"),GetLangText("RECURRES","TXT_INFORMATION"),64)
	CASE _screen.oGlobal.lUgos
		DO FORM "forms\interfaceawaform" WITH lnRsId
	OTHERWISE
		DO FORM "forms\keycardform" WITH lnReserId
ENDCASE