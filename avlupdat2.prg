LPARAMETERS nReserID, cResAlias
	LOCAL l_nRecNo, l_dArrDate, l_dDepDate, l_nRooms, l_cStatus, l_nAltId, l_nReserID, l_cStartLoc, l_cFinishLoc

	IF PCOUNT() < 2
		cResAlias = 'Reservat'
	ENDIF
	IF PCOUNT() < 1
		nReserID = &cResAlias..rs_reserid
	ENDIF
	l_nRecNo = RECNO(cResAlias)
	IF NOT SEEK(nReserID, cResAlias, 'Tag1')
		GO l_nRecNo IN &cResAlias
		RETURN
	ENDIF

	IF l_nRecNo < 0
		l_dArrDate = {}
		l_dDepDate = {}
		l_nRooms = 0
		l_cStatus = ""
		l_nAltId = 0
		l_nReserID = 0
		l_cStartLoc = ""
		l_cFinishLoc = ""
	ELSE
		l_dArrDate = CURVAL("rs_arrdate", cResAlias)
		l_dDepDate = CURVAL("rs_depdate", cResAlias)
		l_nRooms = CURVAL("rs_rooms", cResAlias)
		l_nAltId = CURVAL("rs_altid", cResAlias)
		l_nReserID = CURVAL("rs_reserid", cResAlias)
		l_cStatus = CURVAL("rs_status", cResAlias)
		l_cStartLoc = CURVAL("rs_lstart", cResAlias)
		l_cFinishLoc = CURVAL("rs_lfinish", cResAlias)
	ENDIF
	= avlSave(1, l_dArrDate, l_dDepDate, l_nRooms, "", "", l_cStatus, l_nAltId, l_nReserID, l_cStartLoc, l_cFinishLoc)

	l_dArrDate = &cResAlias..rs_arrdate
	l_dDepDate = &cResAlias..rs_depdate
	l_nRooms = &cResAlias..rs_rooms
	l_nAltId = &cResAlias..rs_altid
	l_cStatus = &cResAlias..rs_status
	l_cStartLoc = &cResAlias..rs_lstart
	l_cFinishLoc = &cResAlias..rs_lfinish
	
	LOCAL cAvOrder
	cAvOrder = ORDER("availab")
	SET ORDER TO "Tag1" IN "availab"
	= avlupdat(1, l_dArrDate, l_dDepDate, l_nRooms, l_cStatus, l_nAltId, nReserID, l_cStartLoc, l_cFinishLoc)
	SET ORDER TO cAvOrder IN "availab"

*	DoTableUpdate(.T.,.T.,'roomplan')
	DoTableUpdate(.T.,.T.,'availab')
	DoTableUpdate(.T.,.T.,'altsplit')
	GO l_nRecNo IN &cResAlias
	RETURN .T.
ENDFUNC
*
