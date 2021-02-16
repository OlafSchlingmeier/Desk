*
FUNCTION AvlSave
LPARAMETERS nrOw, daRrdate, ddEpdate, nrOoms, crOomtyp, crOomnum, csTatus, nAltId, nrEserid, cStartLoc, cFinishLoc
LOCAL l_nParameters

l_nParameters = PCOUNT()
IF l_nParameters = 0
	nrOw = 1
ENDIF
IF l_nParameters < 11
	g_Data[nrOw, 1] = reServat.rs_arrdate
	g_Data[nrOw, 2] = reServat.rs_depdate
	g_Data[nrOw, 3] = reServat.rs_rooms
	g_Data[nrOw, 4] = reServat.rs_roomtyp
	g_Data[nrOw, 5] = reServat.rs_roomnum
	g_Data[nrOw, 6] = reServat.rs_status
	g_Data[nrOw, 7] = reServat.rs_altid
	g_Data[nrOw, 8] = reServat.rs_reserid
	g_Data[nrOw, 9] = reServat.rs_lstart
	g_Data[nrOw, 10] = reServat.rs_lfinish
ELSE
	g_Data[nrOw, 1] = daRrdate
	g_Data[nrOw, 2] = ddEpdate
	g_Data[nrOw, 3] = nrOoms
	g_Data[nrOw, 4] = crOomtyp
	g_Data[nrOw, 5] = crOomnum
	g_Data[nrOw, 6] = csTatus
	g_Data[nrOw, 7] = nAltId
	g_Data[nrOw, 8] = nrEserid
	g_Data[nrOw, 9] = cStartLoc
	g_Data[nrOw, 10] = cFinishLoc
ENDIF

RETURN .T.
ENDFUNC
*