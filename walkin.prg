* PROCEDURE walkin
PARAMETERS p_dArrival, p_dDeparture, p_cRoomtype
IF PCOUNT() == 3
	doform("frmquickreser","forms\quickreser","WITH p_dArrival, p_dDeparture, p_cRoomtype")
ELSE
	doform("frmquickreser","forms\quickreser")
ENDIF
RETURN
*