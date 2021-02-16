PROCEDURE BrwAvailab
LPARAMETERS lp_cAvailabFormName, lp_cField, lp_cCurRec, lp_cSource, lp_oParams, lp_oCallingObj, lp_lAutomationMode, lp_cBuliding
LOCAL l_eRet, l_lAutomationMode, l_cFor

IF PCOUNT() = 4
	l_eRet = DoField(lp_cAvailabFormName, lp_cSource, lp_cCurRec, lp_cField)
ELSE
	l_lAutomationMode = g_lAutomationMode OR lp_lAutomationMode
	IF EMPTY(lp_cAvailabFormName)
		lp_cAvailabFormName = "brwavail"
	ENDIF
	LOCAL i, l_nArea, l_cCurrRec, l_cSource, l_cField, l_nCol, l_cOrderRT
	LOCAL l_nMaxRoomtypes, l_nMaxDummy, l_nMaxVirtual, l_nVirtualNo, l_nRoomTypeNo, l_nDummyNo, l_nEventIntId, l_nAllotId
	LOCAL l_cHotelCur, l_cHotCode, l_cTablePath, l_cAlias, l_cvwfmt, l_lftbold, l_lNotSetRtOccLevels, l_lNotSetDefOccLevels, l_lNotSetOccLevelColors
	l_lNotSetDefOccLevels = _screen.oGlobal.oParam2.pa_avlpct1=0 AND _screen.oGlobal.oParam2.pa_avlpct2=0 AND _screen.oGlobal.oParam2.pa_avlpct3=0
	l_lNotSetOccLevelColors = INLIST(_screen.oGlobal.nBCOccupancyLevel1,0,RGB(255,255,255)) AND INLIST(_screen.oGlobal.nBCOccupancyLevel2,0,RGB(255,255,255)) AND INLIST(_screen.oGlobal.nBCOccupancyLevel3,0,RGB(255,255,255))
	l_nMaxRoomtypes = 30	&& Show up to 30 standard roomtypes
	l_nMaxDummy = 10		&& Show up to 10 dummy roomtypes
	l_nMaxVirtual = 10		&& Show up to 10 virtual roomtypes
	l_nRoomTypeNo = 0		&& Number of standard roomtypes in grid
	l_nDummyNo = 0			&& Number of dummy roomtypes in grid
	l_nVirtualNo = 0		&& Number of virtual roomtypes in grid
	DO CASE
		CASE lp_cAvailabFormName = "brweventavail"
			l_nEventIntId = lp_oParams.Item("EventIntId")
		CASE lp_cAvailabFormName = "brwallottavail"
			l_nAllotId = lp_oParams.Item("AllotId")
		OTHERWISE
	ENDCASE
	l_nCol = 12
	LOCAL ARRAY l_aColumns(1, l_nCol), l_aFields(1, 16), l_aAltRoomtypes(1)
	STORE .F. TO l_aFields
	DO CursorAddField IN ProcBill WITH l_aFields, "DDATE", "D", 8, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "LALTDEF", "L", 1, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "LOPTDEF", "L", 1, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "LTENDEF", "L", 1, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "LOOSDEF", "L", 1, 0
	l_nArea = SELECT()
	l_cSource = SYS(2015)
	l_cCurrRec = SYS(2015)
	l_cOrderRT = ORDER("roomtype")
	i = 1
	DO CursorAddField IN ProcBill WITH l_aFields, "CDAY", "C", 8, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "NDAYCOLOR", "N", 10, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "NDAYBCOLOR", "N", 10, 0, .T.
	l_aColumns(i, 1) = ""
	l_aColumns(i, 2) = 55
	l_aColumns(i, 3) = GetLangText("VIEW","TXT_AVDATE")
	l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [CDAY], [" + l_cCurrRec + "], [" + l_cSource + "])"
	l_aColumns(i, 5) = "BrwAvailab([" + lp_cAvailabFormName + "], [NDAYCOLOR], [" + l_cCurrRec + "], [" + l_cSource + "])"
	l_aColumns(i, 6) = IIF(l_lNotSetDefOccLevels OR l_lNotSetOccLevelColors, "", "BrwAvailab([" + lp_cAvailabFormName + "], [NDAYBCOLOR], [" + l_cCurrRec + "], [" + l_cSource + "])")
	i = 2
	DIMENSION l_aColumns(i, l_nCol)
	DO CursorAddField IN ProcBill WITH l_aFields, "CEVENT", "C", 254, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "NEVENTCOLOR", "N", 10, 0, .T.
	l_aColumns(i, 1) = ""
	l_aColumns(i, 2) = 60
	l_aColumns(i, 3) = GetLangText("VIEW","TXT_AVEVENT")
	l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [CEVENT], [" + l_cCurrRec + "], [" + l_cSource + "])"
	l_aColumns(i, 5) = ""
	l_aColumns(i, 6) = "BrwAvailab([" + lp_cAvailabFormName + "], [NEVENTCOLOR], [" + l_cCurrRec + "], [" + l_cSource + "])"
	IF lp_cAvailabFormName = "brwmultipropavail" AND OpenFile(.F., "hotel")
		l_cHotelCur = SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode")
		IF USED(l_cHotelCur) AND RECCOUNT() > 0
			SELECT &l_cHotelCur
			SCAN ALL WHILE l_nRoomTypeNo < l_nMaxRoomtypes
				l_cHotCode = UPPER(ALLTRIM(ho_hotcode))
				l_cTablePath = FNGetMPDataPath(ho_path)
				l_cAlias = "picklist_" + LOWER(l_cHotCode)
				IF OpenFileDirect(.F., "picklist", l_cAlias, l_cTablePath)
					SELECT &l_cAlias
					SCAN ALL FOR pl_label = "VIRROOM" AND BETWEEN(pl_numcod, 1, 10) WHILE l_nRoomTypeNo < l_nMaxRoomtypes
						i = i + 1
						DIMENSION l_aColumns(i, l_nCol)
						l_cField = "VR_" + l_cHotCode + "_" + ALLTRIM(pl_charcod)
						DO CursorAddField IN ProcBill WITH l_aFields, l_cField, "N", 8, 2
						l_aColumns(i, 1) = ""
						l_aColumns(i, 2) = 30
						l_aColumns(i, 3) = ALLTRIM(pl_charcod) + " " + l_cHotCode
						l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [" + l_cField + "], [" + l_cCurrRec + "], [" + l_cSource + "])"
						l_aColumns(i, 5) = ""
						l_aColumns(i, 6) = ""
						l_aColumns(i, 9) = &l_cHotelCur..ho_hotcode+pl_charcod
						l_nRoomTypeNo = l_nRoomTypeNo + 1
					ENDSCAN
					USE
				ENDIF
			ENDSCAN
		ENDIF
	ELSE
		IF lp_cAvailabFormName = "brweventavail"
			l_aAltRoomtypes(1) = ""
			SELECT DISTINCT as_roomtyp FROM altsplit ;
				INNER JOIN althead ON al_altid = as_altid ;
				WHERE al_eiid = l_nEventIntId INTO ARRAY l_aAltRoomtypes
		ENDIF
		SELECT roomtype
		SET ORDER TO Tag2
		l_cFor = "INLIST(rt_group, 1, 4) AND (rt_vwsize > 0) AND rt_vwshow" + IIF(EMPTY(lp_cBuliding),""," AND rt_buildng = '" + lp_cBuliding + "'")
		SCAN ALL FOR &l_cFor WHILE l_nRoomTypeNo < l_nMaxRoomtypes
			l_cvwfmt = ""
			l_lftbold = .F.
			l_lNotSetRtOccLevels = .T.
			DO CASE
				CASE lp_cAvailabFormName = "brweventavail" AND NOT EMPTY(l_aAltRoomtypes(1))
					IF 0 = ASCAN(l_aAltRoomtypes, rt_roomtyp) 
						LOOP
					ENDIF
					l_cField = "RT_" + ALLTRIM(STR(RECNO("roomtype")))
					l_cCaption = Get_rt_roomtyp(rt_roomtyp)
					l_nFtcolid = rt_ftcolid
					l_nCocolid = rt_cocolid
					l_lNotSetRtOccLevels = rt_avlpct1=0 AND rt_avlpct2=0 AND rt_avlpct3=0
				CASE lp_cAvailabFormName = "brwallottavail"
					IF NOT DLocate("altsplit", "STR(as_altid,8)+DTOS(as_date) = " + SqlCnv(STR(l_nAllotId,8)) + " AND as_roomtyp = roomtype.rt_roomtyp")
						LOOP
					ENDIF
					l_cField = "RT_" + ALLTRIM(STR(RECNO("roomtype")))
					l_cCaption = Get_rt_roomtyp(rt_roomtyp)
					l_nFtcolid = rt_ftcolid
					l_nCocolid = rt_cocolid
					l_lNotSetRtOccLevels = rt_avlpct1=0 AND rt_avlpct2=0 AND rt_avlpct3=0
				CASE g_lShips
					IF rtypedef.rd_rdid # roomtype.rt_rdid
						DLocate("rtypedef", "rd_rdid = roomtype.rt_rdid")
					ENDIF
					l_cField = "RD_" + ALLTRIM(STR(RECNO("rtypedef")))
					IF 0 < ASCAN(l_aFields,l_cField,1,0,1,8)
						LOOP
					ENDIF
					l_cCaption = ALLTRIM(rtypedef.rd_roomtyp)
					l_nFtcolid = rtypedef.rd_ftcolid
					l_nCocolid = rtypedef.rd_cocolid
				OTHERWISE
					l_cField = "RT_" + ALLTRIM(STR(RECNO("roomtype")))
					l_cCaption = Get_rt_roomtyp(rt_roomtyp)
					l_nFtcolid = rt_ftcolid
					l_nCocolid = rt_cocolid
					l_cvwfmt = ALLTRIM(rt_vwfmt)
					l_lftbold = rt_ftbold
					l_lNotSetRtOccLevels = rt_avlpct1=0 AND rt_avlpct2=0 AND rt_avlpct3=0
			ENDCASE
			i = i + 1
			DIMENSION l_aColumns(i, l_nCol)
			DO CursorAddField IN ProcBill WITH l_aFields, l_cField, "N", 8, 2
			l_aColumns(i, 1) = ""
			l_aColumns(i, 2) = 30
			l_aColumns(i, 3) = UPPER(l_cCaption)
			l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [" + l_cField + "], [" + l_cCurrRec + "], [" + l_cSource + "])"
			l_aColumns(i, 5) = IIF(NOT EMPTY(l_nFtcolid) AND DbLookUp("citcolor", "tag1", l_nFtcolid, "FOUND()"), ;
							ALLTRIM(STR(DbLookUp("citcolor", "tag1", l_nFtcolid, "ct_color"))), "")
			IF NOT _screen.oGlobal.oParam2.pa_avllvrt OR l_lNotSetOccLevelColors OR l_lNotSetRtOccLevels AND l_lNotSetDefOccLevels
				l_aColumns(i, 6) = IIF(NOT EMPTY(l_nCocolid) AND DbLookUp("citcolor", "tag1", l_nCocolid, "FOUND()"), ;
								ALLTRIM(STR(DbLookUp("citcolor", "tag1", l_nCocolid, "ct_color"))), "")
			ELSE
				DO CursorAddField IN ProcBill WITH l_aFields, l_cField+"BC", "N", 10, 0, .T.
				l_aColumns(i, 6) = "BrwAvailab([" + lp_cAvailabFormName + "], [" + l_cField + "BC], [" + l_cCurrRec + "], [" + l_cSource + "])"
			ENDIF
			l_aColumns(i, 9) = IIF(g_lShips, rt_rdid, rt_roomtyp)
			l_aColumns(i, 10) = l_cvwfmt
			l_aColumns(i, 11) = l_lftbold
			l_nRoomTypeNo = l_nRoomTypeNo + 1
		ENDSCAN
	ENDIF
	i = i + 1
	DIMENSION l_aColumns(i, l_nCol)
	DO CursorAddField IN ProcBill WITH l_aFields, "NFREE", "N", 8, 2
	l_aColumns(i, 1) = ""
	l_aColumns(i, 2) = 40
	l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVFREE')
	l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NFREE], [" + l_cCurrRec + "], [" + l_cSource + "])"
	l_aColumns(i, 5) = ""
	l_aColumns(i, 6) = ""
	IF lp_cAvailabFormName = "brwavail"
		SELECT roomtype
		l_cFor = "NOT EMPTY(rt_roomtyp) AND rt_group = 3 AND rt_vwsize > 0 AND (rt_vwshow OR rt_vwsum)" + IIF(EMPTY(lp_cBuliding),""," AND rt_buildng = '" + lp_cBuliding + "'")
		SCAN ALL FOR &l_cFor WHILE l_nDummyNo < l_nMaxDummy
			IF g_lShips
				IF rtypedef.rd_rdid # roomtype.rt_rdid
					DLocate("rtypedef", "rd_rdid = roomtype.rt_rdid")
				ENDIF
				l_cField = "DD_" + ALLTRIM(STR(RECNO("rtypedef")))
				IF 0 < ASCAN(l_aFields,l_cField,1,0,1,8)
					LOOP
				ENDIF
				l_cCaption = ALLTRIM(rtypedef.rd_roomtyp)
				l_nFtcolid = rtypedef.rd_ftcolid
				l_nCocolid = rtypedef.rd_cocolid
			ELSE
				l_cField = "D_" + ALLTRIM(STR(RECNO("roomtype")))
				l_cCaption = Get_rt_roomtyp(rt_roomtyp)
				l_nFtcolid = rt_ftcolid
				l_nCocolid = rt_cocolid
			ENDIF
			i = i + 1
			DIMENSION l_aColumns(i, l_nCol)
			DO CursorAddField IN ProcBill WITH l_aFields, l_cField, "N", 8, 2
			l_aColumns(i, 1) = ""
			l_aColumns(i, 2) = 30
			l_aColumns(i, 3) = UPPER(l_cCaption)
			l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [" + l_cField + "], [" + l_cCurrRec + "], [" + l_cSource + "])"
			l_aColumns(i, 5) = IIF(NOT EMPTY(l_nFtcolid) AND DbLookUp("citcolor", "tag1", l_nFtcolid, "FOUND()"), ;
							ALLTRIM(STR(DbLookUp("citcolor", "tag1", l_nFtcolid, "ct_color"))), "")
			l_aColumns(i, 6) = IIF(NOT EMPTY(l_nCocolid) AND DbLookUp("citcolor", "tag1", l_nCocolid, "FOUND()"), ;
							ALLTRIM(STR(DbLookUp("citcolor", "tag1", l_nCocolid, "ct_color"))), "")
			l_aColumns(i, 9) = IIF(g_lShips, rt_rdid, rt_roomtyp)
			l_nDummyNo = l_nDummyNo + 1
		ENDSCAN
	ENDIF
	i = i + 1
	DIMENSION l_aColumns(i, l_nCol)
	DO CursorAddField IN ProcBill WITH l_aFields, "NDEF", "N", 8, 2
	l_aColumns(i, 1) = ""
	l_aColumns(i, 2) = 30
	l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVDEFI')
	l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NDEF], [" + l_cCurrRec + "], [" + l_cSource + "])"
	l_aColumns(i, 5) = ""
	l_aColumns(i, 6) = ""
	IF _screen.oGlobal.oParam2.pa_avl6pm
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		DO CursorAddField IN ProcBill WITH l_aFields, "NSIXPM", "N", 8, 2
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_6PM')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NSIXPM], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
	ENDIF
	i = i + 1
	DIMENSION l_aColumns(i, l_nCol)
	DO CursorAddField IN ProcBill WITH l_aFields, "NOPT", "N", 8, 2
	l_aColumns(i, 1) = ""
	l_aColumns(i, 2) = 30
	l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVOPTI')
	l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NOPT], [" + l_cCurrRec + "], [" + l_cSource + "])"
	l_aColumns(i, 5) = ""
	l_aColumns(i, 6) = ""
	IF "LST" == DbLookup("picklist", "tag4", PADR("RESSTATUS", 10) + "LST", "pl_charcod")
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVWAIT')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NLST], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
	ENDIF
	DO CursorAddField IN ProcBill WITH l_aFields, "NLST", "N", 8, 2
	IF "TEN" == DbLookup("picklist", "tag4", PADR("RESSTATUS", 10) + "TEN", "pl_charcod")
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVTENT')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NTEN], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
	ENDIF
	DO CursorAddField IN ProcBill WITH l_aFields, "NTEN", "N", 8, 2
	IF lp_cAvailabFormName = "brwavail"
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVOOORDER')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NOOO], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVOOSERVC')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NOOS], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
	ENDIF
	DO CursorAddField IN ProcBill WITH l_aFields, "NOOO", "N", 5, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "NOOS", "N", 5, 0
	IF lp_cAvailabFormName = "brwavail" AND RECCOUNT("Altsplit") > 0
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVALLOTT')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NALT], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVPICK')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NPICK], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_AVFREEALLOTT')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NFREEALLOT], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
	ENDIF
	DO CursorAddField IN ProcBill WITH l_aFields, "NALT", "N", 5, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "NPICK", "N", 5, 0
	DO CursorAddField IN ProcBill WITH l_aFields, "NFREEALLOT", "N", 5, 0
	IF _screen.oGlobal.oParam2.pa_shexria AND _screen.OR
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 30
		l_aColumns(i, 3) = GetLangText('VIEW','TXT_EXT_RESER')
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NEXTRESER], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		DO CursorAddField IN ProcBill WITH l_aFields, "NEXTRESER", "N", 5, 0
	ENDIF
	IF lp_cAvailabFormName = "brwmultipropavail" OR _screen.oGlobal.oParam.pa_expavl
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		DO CursorAddField IN ProcBill WITH l_aFields, "NRMSARR", "N", 8, 2
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 35
		l_aColumns(i, 3) = GetLangText("VIEW","TXT_ARRROOM")
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NRMSARR], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		DO CursorAddField IN ProcBill WITH l_aFields, "NPRSARR", "N", 5, 0
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 35
		l_aColumns(i, 3) = GetLangText("VIEW","TXT_ARRPERS")
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NPRSARR], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		DO CursorAddField IN ProcBill WITH l_aFields, "NRMSINH", "N", 8, 2
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 35
		l_aColumns(i, 3) = GetLangText("VIEW","TXT_INROOM")
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NRMSINH], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		DO CursorAddField IN ProcBill WITH l_aFields, "NPRSINH", "N", 5, 0
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 35
		l_aColumns(i, 3) = GetLangText("VIEW","TXT_INPERS")
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NPRSINH], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		DO CursorAddField IN ProcBill WITH l_aFields, "NRMSDEP", "N", 8, 2
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 35
		l_aColumns(i, 3) = GetLangText("VIEW","TXT_DEPROOM")
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NRMSDEP], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		i = i + 1
		DIMENSION l_aColumns(i, l_nCol)
		DO CursorAddField IN ProcBill WITH l_aFields, "NPRSDEP", "N", 5, 0
		l_aColumns(i, 1) = ""
		l_aColumns(i, 2) = 35
		l_aColumns(i, 3) = GetLangText("VIEW","TXT_DEPPERS")
		l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [NPRSDEP], [" + l_cCurrRec + "], [" + l_cSource + "])"
		l_aColumns(i, 5) = ""
		l_aColumns(i, 6) = ""
		DO CursorAddField IN ProcBill WITH l_aFields, "NRMSIN", "N", 8, 2
		DO CursorAddField IN ProcBill WITH l_aFields, "NPRSIN", "N", 5, 0
		DO CursorAddField IN ProcBill WITH l_aFields, "NRMSOUT", "N", 8, 2
		DO CursorAddField IN ProcBill WITH l_aFields, "NPRSOUT", "N", 5, 0
		IF lp_cAvailabFormName = "brwavail"
			SELECT picklist
			SCAN ALL FOR pl_label = "VIRROOM" AND BETWEEN(pl_numcod, 1, 10) WHILE l_nVirtualNo < l_nMaxVirtual
				i = i + 1
				DIMENSION l_aColumns(i, l_nCol)
				l_cField = "VR_" + ALLTRIM(pl_charcod)
				DO CursorAddField IN ProcBill WITH l_aFields, l_cField, "N", 8, 2
				l_aColumns(i, 1) = ""
				l_aColumns(i, 2) = 30
				l_aColumns(i, 3) = ALLTRIM(pl_charcod)
				l_aColumns(i, 4) = "BrwAvailab([" + lp_cAvailabFormName + "], [" + l_cField + "], [" + l_cCurrRec + "], [" + l_cSource + "])"
				l_aColumns(i, 5) = ""
				l_aColumns(i, 6) = ""
				l_nVirtualNo = l_nVirtualNo + 1
			ENDSCAN
		ENDIF
	ENDIF
	SET ORDER TO l_cOrderRT IN roomtype
	SELECT(l_nArea)
	IF l_lAutomationMode
		LOCAL l_cFunc, l_cCurProps, i, l_oProps
		LOCAL ARRAY l_adate(lp_oParams(1).Days,1)
		CREATE CURSOR (l_cCurrRec) FROM ARRAY l_aFields
		INSERT INTO (l_cCurrRec) (lAltDef, lOptDef, lTenDef, lOosDef) ;
			VALUES (_screen.oGlobal.oParam.pa_allodef, _screen.oGlobal.oParam.pa_optidef, _screen.oGlobal.oParam.pa_tentdef, _screen.oGlobal.oParam2.pa_oosdef)
		CREATE CURSOR (l_cSource) (av_date d)
		INSERT INTO (l_cSource) FROM ARRAY l_adate
		REPLACE av_date WITH lp_oParams(1).FromDate+RECNO()-1 ALL
		SELECT * FROM &l_cSource, &l_cCurrRec INTO CURSOR (l_cSource) READWRITE
		SELECT (l_cSource)
		SCAN
			BrwAvailab(lp_cAvailabFormName, "DDATE", l_cCurrRec, l_cSource)
			SELECT (l_cCurrRec)
			SCATTER NAME loRecord
			SELECT (l_cSource)
			GATHER NAME loRecord
		ENDSCAN
		l_cFunc = "BrwAvailab([" + lp_cAvailabFormName + "], ["
		l_cCurProps = SYS(2015)
		CREATE CURSOR (l_cCurProps) (nWidth n(3), cCaption c(50), cSource c(20), cDynFColor c(50), cDynBColor c(50), cInputMask c(10), lFonBold l)
		SCATTER NAME l_oProps
		FOR i = 1 TO ALEN(l_aColumns,1)
			l_oProps.nWidth = l_aColumns(i,2)
			l_oProps.cCaption = l_aColumns(i,3)
			l_oProps.cSource = IIF(l_cFunc $ l_aColumns(i,4), STREXTRACT(l_aColumns(i,4),l_cFunc,"]"), l_aColumns(i,4))
			l_oProps.cDynFColor = IIF(l_cFunc $ l_aColumns(i,5), STREXTRACT(l_aColumns(i,5),l_cFunc,"]"), l_aColumns(i,5))
			l_oProps.cDynBColor = IIF(l_cFunc $ l_aColumns(i,6), STREXTRACT(l_aColumns(i,6),l_cFunc,"]"), l_aColumns(i,6))
			l_oProps.cInputMask = IIF(EMPTY(l_aColumns(i,10)), "", l_aColumns(i,10))
			l_oProps.lFonBold = l_aColumns(i,11)
			INSERT INTO (l_cCurProps) FROM NAME l_oProps
		NEXT
		lp_oParams(1).ResultCursor = l_cSource
		lp_oParams(1).PropsCursor = l_cCurProps
		lp_oParams(1).nRoomTypeNo = l_nRoomTypeNo
		lp_oParams(1).ndummyno = l_nDummyNo
		lp_oParams(1).nVirtualNo = l_nVirtualNo
		ACOPY(l_aColumns, lp_oParams(1).aColumns)
	ELSE
		l_oBrwAvl = NEWOBJECT("BrwAvail", "libs\cit_avail", "", ;
				l_cSource, @l_aColumns, l_cCurrRec, @l_aFields, lp_oParams, lp_cAvailabFormName, lp_oCallingObj)
		l_oBrwAvl.nroomtypeno = l_nRoomTypeNo
		l_oBrwAvl.ndummyno = l_nDummyNo
		l_oBrwAvl.nVirtualNo = l_nVirtualNo
		l_oBrwAvl.grdAvail.SetAll("Alignment",1,"Column")
		l_oBrwAvl.grdAvail.Column1.Alignment = 3
		l_oBrwAvl.grdAvail.Column2.Alignment = 3
		l_oBrwAvl.OnSearchEx()
	ENDIF
	l_eRet = .T.
ENDIF
RETURN l_eRet
ENDPROC
*
PROCEDURE DoField
LPARAMETERS lp_cAvailabFormName, lp_cSource, lp_cCurRec, lp_cField
LOCAL l_dDateSource, l_dDateCurrent, l_eRet
l_dDateSource = EVALUATE(lp_cSource + ".av_date")
l_dDateCurrent = EVALUATE(lp_cCurRec + ".dDate")
IF l_dDateSource <> l_dDateCurrent
	DoDate(lp_cAvailabFormName, lp_cCurRec, lp_cSource)
ENDIF
l_eRet = EVALUATE(lp_cCurRec + "." + lp_cField)
RETURN l_eRet
ENDPROC
*
PROCEDURE DoDate
LPARAMETERS lp_cAvailabFormName, lp_cCurRec, lp_cSource
LOCAL l_nArea, l_dDate, l_oCurRec
LOCAL l_oAvailParam, l_oParams, l_nAllotId, l_ofrmBrowse, l_cBuilding, l_cSqlSelect

l_nArea = SELECT()
l_dDate = EVALUATE(lp_cSource + ".av_date")

SELECT(lp_cCurRec)
SCATTER MEMO NAME l_oCurRec BLANK
l_oCurRec.lAltDef = EVALUATE(lp_cCurRec + ".lAltDef")
l_oCurRec.lOptDef = EVALUATE(lp_cCurRec + ".lOptDef")
l_oCurRec.lTenDef = EVALUATE(lp_cCurRec + ".lTenDef")
l_oCurRec.lOosDef = EVALUATE(lp_cCurRec + ".lOosDef")
l_oCurRec.dDate = l_dDate
l_oCurRec.cDay = SUBSTR(DTOC(l_dDate), 1, 5) + " " + SUBSTR(MyCDoW(l_dDate), 1, 2)
l_oCurRec.nDayColor = IIF(INLIST(DOW(l_dDate), 1, 7), RGB(255, 0, 0), RGB(0, 0, 0))
l_oCurRec.cEvent = ""
l_oCurRec.nEventColor = .NULL.

l_oAvailParam = GetProperty(lp_cAvailabFormName, "oParams", .NULL.)
DO CASE
	CASE lp_cAvailabFormName = "brwmultipropavail"
		l_ofrmBrowse = GetProperty("brwmultipropavail", "frmSearch.frmBrowse", .NULL.)
		IF NOT ISNULL(l_ofrmBrowse)
			FOR i = 1 TO ALEN(l_ofrmBrowse.aHotels,1)
				IF NOT l_ofrmBrowse.aHotels[i,4].GetAvlData(l_oCurRec, l_ofrmBrowse.aHotels[i,2])
					EXIT
				ENDIF
			NEXT
		ENDIF
		SELECT(lp_cCurRec)
		GATHER MEMO NAME l_oCurRec
	CASE VARTYPE(l_oAvailParam) # "O"
		l_cBuilding = GetProperty("brwavail", "cBuilding", "")
		GetDate(l_oCurRec, l_cBuilding)
		SELECT(lp_cCurRec)
		GATHER MEMO NAME l_oCurRec
	OTHERWISE
		DO CASE
			CASE lp_cAvailabFormName = "brwavail"
				l_oParams = gosqlwrapper.GetParamsObj(l_dDate, l_oAvailParam.Item("RentObjId"))
				l_cSqlSelect = goSqlWrapper.GetSqlStatment("getrentobjavaildata_sql", l_oParams)
			CASE lp_cAvailabFormName = "brweventavail"
				l_oParams = gosqlwrapper.GetParamsObj(l_dDate, l_oAvailParam.Item("EventIntId"))
				l_cSqlSelect = goSqlWrapper.GetSqlStatment("geteventintervaldata_sql", l_oParams)
			CASE lp_cAvailabFormName = "brwallottavail"
				l_oParams = gosqlwrapper.GetParamsObj(l_dDate, l_oAvailParam.Item("AllotId"))
				l_cSqlSelect = goSqlWrapper.GetSqlStatment("getallotavaildata_sql", l_oParams)
			OTHERWISE
		ENDCASE

		IF NOT EMPTY(l_cSqlSelect)
			SqlCursor(l_cSqlSelect, "curAllotAvlData")
			IF USED("curAllotAvlData")
				SELECT curAllotAvlData
				INDEX ON as_altid TAG Tag1
				SELECT(lp_cCurRec)
				GATHER MEMO NAME l_oCurRec
				LOCAL ARRAY l_aAllotId(1)
				l_aAllotId(1) = 0
				SELECT DISTINCT as_altid FROM curAllotAvlData INTO ARRAY l_aAllotId
				FOR EACH l_nAllotId IN l_aAllotId
					AllotDoDate(lp_cAvailabFormName, lp_cCurRec, lp_cSource, l_nAllotId)
				NEXT
			ENDIF
		ENDIF
ENDCASE

SELECT (l_nArea)
ENDPROC
*
PROCEDURE GetDate
LPARAMETERS l_oCurRec, l_cBuilding, lp_cHotCode
LOCAL l_nFree, l_cVariable, l_cVariableBC, l_nAvlPct1, l_nAvlPct2, l_nAvlPct3, l_nRoomTypeRecNo, l_nOccPct, l_nAllRooms, l_lShowExpAvl, l_lShow6PM
LOCAL ARRAY l_aExtReser(1)

IF EMPTY(lp_cHotCode)
	lp_cHotCode = ""
ENDIF

l_lShowExpAvl = (TYPE("l_oCurRec.nRmsArr") # "U")
l_lShow6PM = (TYPE("l_oCurRec.nSIXPM") # "U")
SET ORDER TO Tag1 IN availab
= SEEK(DTOS(l_oCurRec.dDate), "availab", "tag1")
IF NOT EMPTY(season.se_event)
	l_oCurRec.cEvent = l_oCurRec.cEvent + IIF(EMPTY(l_oCurRec.cEvent),"","/") + ALLTRIM(season.se_event)
ENDIF
IF NOT EMPTY(season.se_color)
	l_oCurRec.nEventColor = EVALUATE("RGB(" + season.se_color + ")")
ENDIF
l_nAllRooms = 0
SELECT availab
SCAN REST FOR roomtype.rt_vwsize > 0 AND (roomtype.rt_vwshow OR roomtype.rt_vwsum) AND ;
		(EMPTY(l_cBuilding) OR roomtype.rt_buildng = l_cBuilding) WHILE av_date = l_oCurRec.dDate
	l_nAllRooms = l_nAllRooms + av_avail
	l_nFree = av_avail - (av_definit + ;
			IIF(l_oCurRec.lAltDef, MAX(av_allott + av_altall - av_pick,0), 0) + ;
			IIF(l_oCurRec.lOptDef, av_option, 0) + ;
			IIF(l_oCurRec.lTenDef, av_tentat, 0) + ;
			IIF(l_oCurRec.lOosDef, av_ooservc, 0))
	l_nRoomTypeRecNo = RECNO("roomtype")
	DO CASE
		CASE INLIST(roomtype.rt_group, 1, 4)
			IF roomtype.rt_vwsum
				l_oCurRec.nFree = l_oCurRec.nFree + l_nFree
				l_oCurRec.nDef = l_oCurRec.nDef + av_definit
				l_oCurRec.nOpt = l_oCurRec.nOpt + av_option
				l_oCurRec.nLst = l_oCurRec.nLst + av_waiting
				l_oCurRec.nTen = l_oCurRec.nTen + av_tentat
			ENDIF
			IF EMPTY(lp_cHotCode)
				l_cVariable = "l_oCurRec.RT_" + ALLTRIM(STR(l_nRoomTypeRecNo))
				IF TYPE(l_cVariable) == "U"
					l_cVariable = "l_oCurRec.RD_" + ALLTRIM(STR(RECNO("rtypedef")))
					IF TYPE(l_cVariable) == "U"
						LOOP
					ENDIF
				ENDIF
				&l_cVariable = &l_cVariable + l_nFree
				l_cVariable = "l_oCurRec.RT_" + ALLTRIM(STR(l_nRoomTypeRecNo))
				IF TYPE(l_cVariable + "BC") <> "U"
					l_cVariableBC = l_cVariable + "BC"
					IF roomtype.rt_avlpct1 = 0 AND roomtype.rt_avlpct2 = 0 AND roomtype.rt_avlpct3 = 0
						l_nAvlPct1 = _screen.oGlobal.oParam2.pa_avlpct1
						l_nAvlPct2 = _screen.oGlobal.oParam2.pa_avlpct2
						l_nAvlPct3 = _screen.oGlobal.oParam2.pa_avlpct3
					ELSE
						l_nAvlPct1 = roomtype.rt_avlpct1
						l_nAvlPct2 = roomtype.rt_avlpct2
						l_nAvlPct3 = roomtype.rt_avlpct3
					ENDIF
					l_nOccPct = 100*(1-IIF(av_avail = 0, 0, &l_cVariable/av_avail))
					&l_cVariableBC = ICASE(l_nOccPct>l_nAvlPct1, _screen.oGlobal.nBCOccupancyLevel1, l_nOccPct>l_nAvlPct2, _screen.oGlobal.nBCOccupancyLevel2, l_nOccPct>=l_nAvlPct3, _screen.oGlobal.nBCOccupancyLevel3, .NULL.)
				ENDIF
			ENDIF
		CASE roomtype.rt_group = 3
			l_cVariable = "l_oCurRec.D_" + ALLTRIM(STR(l_nRoomTypeRecNo))
			IF TYPE(l_cVariable) == "U"
				l_cVariable = "l_oCurRec.DD_" + ALLTRIM(STR(RECNO("rtypedef")))
				IF TYPE(l_cVariable) == "U"
					LOOP
				ENDIF
			ENDIF
			&l_cVariable = &l_cVariable + l_nFree
	ENDCASE
*	l_oCurRec.nFree = l_oCurRec.nFree - IIF(l_oCurRec.lAltDef, av_altall, 0)
	l_oCurRec.nOoo = l_oCurRec.nOoo + av_ooorder
	l_oCurRec.nOos = l_oCurRec.nOos + av_ooservc
	l_oCurRec.nAlt = l_oCurRec.nAlt + av_allott + av_altall
	l_oCurRec.nPick = l_oCurRec.nPick + av_pick
	l_oCurRec.nFreeAllot = l_oCurRec.nFreeAllot + (av_allott + av_altall - av_pick)
	IF SEEK(PADR("VIRROOM",10)+PADR(roomtype.rt_virroom,3), "picklist", "tag4") AND picklist.pl_numcod > 0
		l_cVariable = "l_oCurRec.VR_" + IIF(EMPTY(lp_cHotCode), "", UPPER(ALLTRIM(lp_cHotCode))+"_") + ALLTRIM(picklist.pl_charcod)
		IF TYPE(l_cVariable) # "U"
			&l_cVariable = &l_cVariable + l_nFree
		ENDIF
	ENDIF
ENDSCAN
IF TYPE("l_oCurRec.nExtReser") # "U"
	SELECT SUM(er_rooms) FROM extreser WHERE er_arrdate <= l_oCurRec.dDate AND er_depdate > l_oCurRec.dDate ;
		AND NOT er_status IN ('CXL','LST') AND NOT er_done ;
		INTO ARRAY l_aExtReser
	IF VARTYPE(l_aExtReser(1))="N"
		l_oCurRec.nExtReser = l_aExtReser(1)
	ENDIF
ENDIF
l_nOccPct = 100*(1-IIF(l_nAllRooms=0,0,l_oCurRec.nFree/l_nAllRooms))
l_oCurRec.nDayBColor = ICASE(l_nOccPct>_screen.oGlobal.oParam2.pa_avlpct1, _screen.oGlobal.nBCOccupancyLevel1, ;
	l_nOccPct>_screen.oGlobal.oParam2.pa_avlpct2, _screen.oGlobal.nBCOccupancyLevel2, l_nOccPct>=_screen.oGlobal.oParam2.pa_avlpct3, ;
	_screen.oGlobal.nBCOccupancyLevel3, .NULL.)
IF l_lShowExpAvl OR l_lShow6PM
	LOCAL l_cNear, l_nRmsArr, l_nPrsArr, l_nRmsDep, l_nPrsDep, l_nRmsInH, l_nPrsInH, l_nRmsIn, l_nPrsIn, l_nRmsOut, l_nPrsOut, l_nRms6pm, ;
			l_lSharing, l_cReservat, l_lIsArrival, l_lIsDeparture, l_nLinks
	STORE 0 TO l_nRmsArr, l_nPrsArr, l_nRmsDep, l_nPrsDep, l_nRmsInH, l_nPrsInH, l_nRmsIn, l_nPrsIn, l_nRmsOut, l_nPrsOut, l_nRms6pm
	IF l_lShowExpAvl
		l_cReservat = SqlCursor("SELECT rs_arrdate, rs_depdate, rs_reserid, rs_status, rs_roomnum, rs_roomtyp, rs_rooms, rs_adults, rs_childs, rs_childs2, rs_childs3, ri_roomnum, ri_roomtyp, ri_shareid " + ;
			"FROM reservat LEFT JOIN resrooms ON ri_reserid = rs_reserid AND BETWEEN(" + SqlCnv(l_oCurRec.dDate,.T.) + ", ri_date, ri_todate) WHERE DTOS(rs_arrdate)+rs_lname LIKE " + ;
			SqlCnv(DTOS(l_oCurRec.dDate)+"%",.T.) + " AND NOT INLIST(rs_status, 'NS', 'CXL', 'LST')")
		SCAN
			IF ISNULL(ri_roomnum)
				l_lSharing = .F.
				l_nLinks = NumLinks(rs_roomnum, rs_roomtyp, l_cBuilding)
			ELSE
				l_lSharing = NOT EMPTY(ri_shareid)
				l_nLinks = NumLinks(ri_roomnum, ri_roomtyp, l_cBuilding)
			ENDIF
			IF NOT EMPTY(l_nLinks)
				IF NOT l_lSharing
					l_nRmsArr = l_nRmsArr + rs_rooms * l_nLinks
				ENDIF
				l_nPrsArr = l_nPrsArr + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
				IF rs_status = "IN"
					IF NOT l_lSharing
						l_nRmsIn = l_nRmsIn + rs_rooms * l_nLinks
					ENDIF
					l_nPrsIn = l_nPrsIn + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
				ENDIF
			ENDIF
		ENDSCAN
	ENDIF
	l_cReservat = SqlCursor("SELECT rs_arrdate, rs_depdate, rs_reserid, rs_status, rs_roomnum, rs_roomtyp, rs_rooms, rs_adults, rs_childs, rs_childs2, rs_childs3, ri_roomnum, ri_roomtyp, ri_shareid " + ;
		" FROM reservat LEFT JOIN resrooms ON ri_reserid = rs_reserid AND BETWEEN(" + SqlCnv(l_oCurRec.dDate,.T.) + ", ri_date, ri_todate) WHERE DTOS(rs_depdate)+rs_roomnum >= " + ;
		SqlCnv(DTOS(l_oCurRec.dDate),.T.) + " AND DTOS(rs_arrdate)+rs_lname < " + SqlCnv(DTOS(l_oCurRec.dDate+1),.T.) + " AND NOT INLIST(rs_status, 'NS', 'CXL', 'LST') ORDER BY rs_arrdate, rs_depdate",l_cReservat)
	SCAN
		IF ISNULL(ri_roomnum)
			l_lSharing = .F.
			l_nLinks = NumLinks(rs_roomnum, rs_roomtyp, l_cBuilding)
		ELSE
			l_lSharing = NOT EMPTY(ri_shareid)
			l_nLinks = NumLinks(ri_roomnum, ri_roomtyp, l_cBuilding)
		ENDIF
		IF NOT EMPTY(l_nLinks)
			IF BETWEEN(l_oCurRec.dDate, rs_arrdate, MAX(rs_arrdate,rs_depdate-1))
				IF NOT l_lSharing
					IF rs_status = "6PM"
						l_nRms6pm = l_nRms6pm + rs_rooms * l_nLinks
					ENDIF
					l_nRmsInH = l_nRmsInH + rs_rooms * l_nLinks
				ENDIF
				l_nPrsInH = l_nPrsInH + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
			ENDIF
			IF rs_depdate = l_oCurRec.dDate
				IF NOT l_lSharing
					l_nRmsDep = l_nRmsDep + rs_rooms * l_nLinks
				ENDIF
				l_nPrsDep = l_nPrsDep + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
				IF rs_status = "OUT"
					IF NOT l_lSharing
						l_nRmsOut = l_nRmsOut + rs_rooms * l_nLinks
					ENDIF
					l_nPrsOut = l_nPrsOut + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
				ENDIF
			ENDIF
		ENDIF
	ENDSCAN
	DClose(l_cReservat)
	SELECT sharing
	SCAN FOR NOT sd_history
		l_nLinks = NumLinks(sd_roomnum, sd_roomtyp, l_cBuilding)
		IF NOT EMPTY(l_nLinks)
			IF sd_lowdat = l_oCurRec.dDate
				DO RiShareInterval IN ProcResRooms WITH l_lIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ARRIVAL", l_oCurRec.dDate
				IF l_lIsArrival
					l_nRmsArr = l_nRmsArr + l_nLinks
					IF sd_status = "IN"
						l_nRmsIn = l_nRmsIn + l_nLinks
					ENDIF
				ENDIF
			ENDIF
			IF BETWEEN(l_oCurRec.dDate, sd_lowdat, sd_highdat)
				IF sd_status = "6PM"
					l_nRms6pm = l_nRms6pm + l_nLinks
				ENDIF
				l_nRmsInH = l_nRmsInH + l_nLinks
			ENDIF
			IF sd_highdat + 1 = l_oCurRec.dDate
				DO RiShareInterval IN ProcResRooms WITH l_lIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "DEPARTURE", l_oCurRec.dDate
				IF l_lIsDeparture
					l_nRmsDep = l_nRmsDep + l_nLinks
					IF sd_status = "OUT"
						l_nRmsOut = l_nRmsOut + l_nLinks
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDSCAN
	IF l_lShowExpAvl
		l_oCurRec.nRmsArr = l_nRmsArr
		l_oCurRec.nPrsArr = l_nPrsArr
		l_oCurRec.nRmsDep = l_nRmsDep
		l_oCurRec.nPrsDep = l_nPrsDep
		l_oCurRec.nRmsInH = l_nRmsInH
		l_oCurRec.nPrsInH = l_nPrsInH
		l_oCurRec.nRmsIn = l_nRmsIn
		l_oCurRec.nPrsIn = l_nPrsIn
		l_oCurRec.nRmsOut = l_nRmsOut
		l_oCurRec.nPrsOut = l_nPrsOut
	ENDIF
	IF l_lShow6PM
		l_oCurRec.nSIXPM = l_nRms6pm
		l_oCurRec.nDef = l_oCurRec.nDef - l_oCurRec.nSIXPM
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE AllotDoDate
LPARAMETERS lp_cAvailabFormName, lp_cCurRec, lp_cSource, lp_nAllotId
LOCAL l_oCurRec, l_cVariable, l_nRoomTypeRecNo, l_lIsAllotId, l_cEvent, l_oResrooms, l_lSharing, l_nOccPct
LOCAL ARRAY l_aEvents(1)

SELECT(lp_cCurRec)
SCATTER MEMO NAME l_oCurRec

= SEEK(l_oCurRec.dDate, "season", "tag1")

* Get only events linked to allotment
SELECT CAST(TRIM(ev_name) + " " + TRIM(ev_city) AS Char(61)) AS AlEvent FROM althead ;
	INNER JOIN evint ON al_eiid = ei_eiid ;
	INNER JOIN events ON ei_evid = ev_evid ;
	WHERE al_altid = lp_nAllotId INTO ARRAY l_aEvents
IF VARTYPE(l_aEvents(1))="C"
	l_oCurRec.cEvent = ""
	FOR EACH l_cEvent IN l_aEvents
		l_oCurRec.cEvent = l_oCurRec.cEvent + TRIM(l_cEvent) + "\"
	ENDFOR
	l_oCurRec.cEvent = LEFT(l_oCurRec.cEvent,LEN(l_oCurRec.cEvent)-1)
ENDIF
IF EMPTY(season.se_color)
	l_oCurRec.nEventColor = .NULL.
ELSE
	l_oCurRec.nEventColor = EVALUATE("RGB(" + season.se_color + ")")
ENDIF
SELECT curAllotAvlData
SCAN FOR as_altid = lp_nAllotId AND SEEK(as_roomtyp, "roomtype", "tag1") AND roomtype.rt_vwsize > 0 AND (roomtype.rt_vwshow OR roomtype.rt_vwsum)
	l_nRoomTypeRecNo = RECNO("roomtype")
	DO CASE
		CASE INLIST(roomtype.rt_group, 1, 4)
			l_cVariable = "l_oCurRec.RT_" + ALLTRIM(STR(l_nRoomTypeRecNo))
			IF TYPE(l_cVariable) == "U"
				l_cVariable = "l_oCurRec.RD_" + ALLTRIM(STR(RECNO("rtypedef")))
				IF TYPE(l_cVariable) == "U"
					LOOP
				ENDIF
			ENDIF
			IF roomtype.rt_vwsum
				l_oCurRec.nFree = l_oCurRec.nFree + freerooms
			ENDIF
			l_oCurRec.nAlt = l_oCurRec.nAlt + maxrooms
			l_oCurRec.nPick = l_oCurRec.nPick + pickrooms
			l_oCurRec.nFreeAllot = l_oCurRec.nFreeAllot + freerooms
			&l_cVariable = &l_cVariable + freerooms
		CASE roomtype.rt_group = 3
			l_cVariable = "l_oCurRec.D_" + ALLTRIM(STR(l_nRoomTypeRecNo))
			IF TYPE(l_cVariable) == "U"
				l_cVariable = "l_oCurRec.DD_" + ALLTRIM(STR(RECNO("rtypedef")))
				IF TYPE(l_cVariable) == "U"
					LOOP
				ENDIF
			ENDIF
			&l_cVariable = &l_cVariable + freerooms
	ENDCASE
ENDSCAN
l_nOccPct = 100*(1-IIF(l_oCurRec.nAlt=0,0,l_oCurRec.nFree/l_oCurRec.nAlt))
l_oCurRec.nDayBColor = ICASE(l_nOccPct>_screen.oGlobal.oParam2.pa_avlpct1, _screen.oGlobal.nBCOccupancyLevel1, ;
	l_nOccPct>_screen.oGlobal.oParam2.pa_avlpct2, _screen.oGlobal.nBCOccupancyLevel2, l_nOccPct>=_screen.oGlobal.oParam2.pa_avlpct3, ;
	_screen.oGlobal.nBCOccupancyLevel3, .NULL.)
SELECT reservat
SCAN FOR rs_altid = lp_nAllotId AND BETWEEN(l_oCurRec.dDate, rs_arrdate, rs_depdate-1) AND ;
		NOT INLIST(rs_status, "NS", "CXL") AND INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsize > 0 AND roomtype.rt_vwsum
	RiGetRoom(rs_reserid, l_oCurRec.dDate, @l_oResrooms)
	l_lSharing = NOT ISNULL(l_oResrooms) AND NOT EMPTY(l_oResrooms.ri_shareid)
	IF NOT l_lSharing
		l_oCurRec.nDef = l_oCurRec.nDef + rs_rooms * IIF(INLIST(rs_status, "OPT", "LST", "TEN"), 0, 1)
		l_oCurRec.nOpt = l_oCurRec.nOpt + rs_rooms * IIF(rs_status = "OPT", 1, 0)
		l_oCurRec.nLst = l_oCurRec.nLst + rs_rooms * IIF(rs_status = "LST", 1, 0)
		l_oCurRec.nTen = l_oCurRec.nTen + rs_rooms * IIF(rs_status = "TEN", 1, 0)
	ENDIF
ENDSCAN
SELECT sharing
SCAN FOR NOT sd_history AND BETWEEN(l_oCurRec.dDate, sd_lowdat, sd_highdat) AND sd_status # "CXL" AND ;
		INLIST(roomtype.rt_group, 1, 4) AND roomtype.rt_vwsize > 0 AND roomtype.rt_vwsum
	DO RiShareInterval IN ProcResRooms WITH l_lIsAllotId, sd_shareid, , , "ALLOTMENT", , lp_nAllotId
	IF l_lIsAllotId
		l_oCurRec.nDef = l_oCurRec.nDef + IIF(INLIST(sd_status, "OPT", "LST", "TEN"), 0, 1)
		l_oCurRec.nOpt = l_oCurRec.nOpt + IIF(sd_status = "OPT", 1, 0)
		l_oCurRec.nLst = l_oCurRec.nLst + IIF(sd_status = "LST", 1, 0)
		l_oCurRec.nTen = l_oCurRec.nTen + IIF(sd_status = "TEN", 1, 0)
	ENDIF
ENDSCAN
IF _screen.oGlobal.oParam.pa_expavl
	LOCAL l_nRmsArr, l_nPrsArr, l_nRmsDep, l_nPrsDep, l_nRmsInH, l_nPrsInH, l_nRmsIn, l_nPrsIn, l_nRmsOut, l_nPrsOut
	STORE 0 TO l_nRmsArr, l_nPrsArr, l_nRmsDep, l_nPrsDep, l_nRmsInH, l_nPrsInH, l_nRmsIn, l_nPrsIn, l_nRmsOut, l_nPrsOut
	SELECT reservat
	SCAN FOR rs_altid = lp_nAllotId AND NOT INLIST(rs_status, "NS", "CXL", "LST") AND roomtype.rt_group = 1 AND roomtype.rt_vwsum
		RiGetRoom(rs_reserid, l_oCurRec.dDate, @l_oResrooms)
		l_lSharing = NOT ISNULL(l_oResrooms) AND NOT EMPTY(l_oResrooms.ri_shareid)
		IF rs_arrdate = l_oCurRec.dDate
			IF NOT l_lSharing
				l_nRmsArr = l_nRmsArr + rs_rooms
			ENDIF
			l_nPrsArr = l_nPrsArr + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
			IF rs_status = "IN"
				IF NOT l_lSharing
					l_nRmsIn = l_nRmsIn + rs_rooms
				ENDIF
				l_nPrsIn = l_nPrsIn + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
			ENDIF
		ENDIF
		IF BETWEEN(l_oCurRec.dDate, rs_arrdate, MAX(rs_arrdate,rs_depdate-1))
			IF NOT l_lSharing
				l_nRmsInH = l_nRmsInH + rs_rooms
			ENDIF
			l_nPrsInH = l_nPrsInH + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
		ENDIF
		IF rs_depdate = l_oCurRec.dDate
			IF NOT l_lSharing
				l_nRmsDep = l_nRmsDep + rs_rooms
			ENDIF
			l_nPrsDep = l_nPrsDep + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
			IF rs_status = "OUT"
				IF NOT l_lSharing
					l_nRmsOut = l_nRmsOut + rs_rooms
				ENDIF
				l_nPrsOut = l_nPrsOut + rs_rooms * (rs_adults + rs_childs + rs_childs2 + rs_childs3)
			ENDIF
		ENDIF
	ENDSCAN
	SELECT sharing
	SCAN FOR NOT sd_history AND BETWEEN(l_oCurRec.dDate, sd_lowdat, sd_highdat+1) AND sd_status # "CXL" AND roomtype.rt_group = 1 AND roomtype.rt_vwsum
		DO RiShareInterval IN ProcResRooms WITH l_lIsAllotId, sd_shareid, , , "ALLOTMENT", , lp_nAllotId
		IF l_lIsAllotId
			IF sd_lowdat == l_oCurRec.dDate
				l_nRmsArr = l_nRmsArr + 1
				IF sd_status = "IN"
					l_nRmsIn = l_nRmsIn + 1
				ENDIF
			ENDIF
			IF BETWEEN(l_oCurRec.dDate, sd_lowdat, sd_highdat)
				l_nRmsInH = l_nRmsInH + 1
			ENDIF
			IF sd_highdat+1 == l_oCurRec.dDate
				l_nRmsDep = l_nRmsDep + 1
				IF sd_status = "OUT"
					l_nRmsOut = l_nRmsOut + 1
				ENDIF
			ENDIF
		ENDIF
	ENDSCAN
	l_oCurRec.nRmsArr = l_oCurRec.nRmsArr + l_nRmsArr
	l_oCurRec.nPrsArr = l_oCurRec.nPrsArr + l_nPrsArr
	l_oCurRec.nRmsDep = l_oCurRec.nRmsDep + l_nRmsDep
	l_oCurRec.nPrsDep = l_oCurRec.nPrsDep + l_nPrsDep
	l_oCurRec.nRmsInH = l_oCurRec.nRmsInH + l_nRmsInH
	l_oCurRec.nPrsInH = l_oCurRec.nPrsInH + l_nPrsInH
	l_oCurRec.nRmsIn = l_oCurRec.nRmsIn + l_nRmsIn
	l_oCurRec.nPrsIn = l_oCurRec.nPrsIn + l_nPrsIn
	l_oCurRec.nRmsOut = l_oCurRec.nRmsOut + l_nRmsOut
	l_oCurRec.nPrsOut = l_oCurRec.nPrsOut + l_nPrsOut
ENDIF

SELECT(lp_cCurRec)
GATHER MEMO NAME l_oCurRec
ENDPROC
*
FUNCTION GetProperty
LPARAMETERS lp_cAvailabFormName, lp_cProperty, lp_uDefValue
LOCAL l_oForm, l_uValue

l_uValue = lp_uDefValue
FOR EACH l_oForm IN _screen.Forms
	IF l_oForm.Name == lp_cAvailabFormName
		TRY
			l_uValue = l_oForm.&lp_cProperty
		CATCH
		ENDTRY
		EXIT
	ENDIF
NEXT

RETURN l_uValue
ENDFUNC
*
FUNCTION NumLinks
LPARAMETERS lp_cRoomnum, lp_cRoomtype, lp_cBuilding
LOCAL i, l_cLinkedRooms, l_nRetVal

l_nRetVal = IIF(SEEK(lp_cRoomtype,"roomtype","tag1") AND roomtype.rt_group = 1 AND roomtype.rt_vwsum AND (EMPTY(lp_cBuilding) OR roomtype.rt_buildng = lp_cBuilding), 1, 0)
IF NOT EMPTY(lp_cRoomnum) AND SEEK(lp_cRoomnum,"room","tag1") AND NOT EMPTY(STRTRAN(room.rm_link,","))
	l_cLinkedRooms = STRTRAN(room.rm_link," ")
	FOR i = 1 TO GETWORDCOUNT(l_cLinkedRooms,",")
		IF SEEK(PADR(GETWORDNUM(l_cLinkedRooms,i,","),4),"room","tag1") AND SEEK(room.rm_roomtyp,"roomtype","tag1") AND ;
				roomtype.rt_group = 1 AND roomtype.rt_vwsum AND (EMPTY(lp_cBuilding) OR roomtype.rt_buildng = lp_cBuilding)
			l_nRetVal = l_nRetVal + 1 / (GETWORDCOUNT(STRTRAN(room.rm_link," "),",")+1)
		ENDIF
	ENDFOR
ENDIF

RETURN l_nRetVal
ENDFUNC
*