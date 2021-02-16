#DEFINE CRLF				CHR(13)+CHR(10)

* Updating modes
#DEFINE EDIT_MODE			1
#DEFINE NEW_MODE			2
#DEFINE COPY_MODE			3
#DEFINE DELETE_MODE			4
#DEFINE READONLY_MODE		5

* Table reservation statuses
#DEFINE TR_DEF				0
#DEFINE TR_ASG				1
#DEFINE TR_IN				2
#DEFINE TR_OUT				3
#DEFINE TR_NS				4
#DEFINE TR_CXL				5
*
FUNCTION ProcTableReservation
LPARAMETERS tcFuncName, tuParam1, tuParam2, tuParam3, tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10
LOCAL lcCallProc, lnParamNo, luRetVal

lcCallProc = tcFuncName + "("
FOR lnParamNo = 1 TO PCOUNT()-1
	lcCallProc = lcCallProc + IIF(lnParamNo = 1, "", ", ") + "@tuParam" + ALLTRIM(STR(lnParamNo))
NEXT
lcCallProc = lcCallProc + ")"
luRetVal = &lcCallProc
RETURN luRetVal
ENDFUNC
*
FUNCTION SaveReservation
LPARAMETERS toTableRes, tdDateTo
LOCAL lnErrorCode, lcurTableres, lcTblTableres, llRlGroup

DO CASE
	CASE toTableRes.tr_trid = 0
		lnErrorCode = RecurrentReservation(toTableRes, tdDateTo, NOT EMPTY(toTableRes.tg_locnr))
	CASE NOT EMPTY(toTableRes.tr_rsid) AND (toTableRes.tr_trid < 0 OR NOT EMPTY(toTableRes.dr_rlid)) AND toTableRes.tr_tablenr <> toTableRes.oOldRes.tr_tablenr
		lcTblTableres = IIF(TYPE("toTableRes.curTableres") = "C" AND NOT EMPTY(toTableRes.curTableres), toTableRes.curTableres, "tblTableres")
		lcurTableres = SYS(2015)
		SELECT * FROM &lcTblTableres WHERE tr_rsid = toTableRes.tr_rsid AND (tr_trid = toTableRes.tr_trid OR tr_status = TR_DEF) INTO CURSOR &lcurTableres
		IF RECCOUNT(lcurTableres) > 1
			MakeStructure("oRecurRes", toTableRes)
			toTableRes.oRecurRes = CurToObj(lcurTableres)
			llRlGroup = .T.
		ENDIF
		DClose(lcurTableres)
		IF llRlGroup
			lnErrorCode = MoveReservation(toTableRes)
		ELSE
			lnErrorCode = SaveOneReservation(toTableRes)
		ENDIF
	CASE EMPTY(toTableRes.tr_tgid) OR toTableRes.tr_from = toTableRes.oOldRes.tr_from AND ALLTRIM(toTableRes.tg_tables) == ALLTRIM(toTableRes.oOldRes.tg_tables)
		lnErrorCode = SaveOneReservation(toTableRes)
	OTHERWISE
		lcTblTableres = IIF(TYPE("toTableRes.curTableres") = "C" AND NOT EMPTY(toTableRes.curTableres), toTableRes.curTableres, "tblTableres")
		lcurTableres = SYS(2015)
		SELECT * FROM &lcTblTableres WHERE tr_tgid = toTableRes.tr_tgid INTO CURSOR &lcurTableres
		MakeStructure("oGroupRes", toTableRes)
		toTableRes.oGroupRes = CurToObj(lcurTableres)
		DClose(lcurTableres)
		DO CASE
			CASE NOT ALLTRIM(toTableRes.tg_tables) == ALLTRIM(toTableRes.oOldRes.tg_tables)
				lnErrorCode = UpdateGroupReservation(toTableRes)
			CASE toTableRes.tr_from <> toTableRes.oOldRes.tr_from
				lnErrorCode = MoveReservation(toTableRes)
			OTHERWISE
		ENDCASE
ENDCASE
PtrSyncExternalDb(toTableRes.tr_rsid)

RETURN lnErrorCode
ENDFUNC
*
FUNCTION SaveOneReservation
LPARAMETERS toTableRes, tlEnvironmentAlreadyPrepared
LOCAL lnErrorCode, lnResSplitId, lnCopyFrom, llCreateGroup

IF NOT tlEnvironmentAlreadyPrepared
	g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres, TblRsGrp, TblProps, DeskTblr')
ENDIF

CFCleanRecordText(toTableRes)
lnErrorCode = CheckReservation(toTableRes)

IF lnErrorCode = 0
	IF toTableRes.tr_trid > 0
		toTableRes.tr_updated = DATETIME()
		toTableRes.tr_changes = PtrChanges(toTableRes, "CHANGED")
		SqlUpdate("Tableres", "tr_trid = " + SqlCnv(toTableRes.tr_trid), toTableRes, 6)
		IF toTableRes.tg_tgid > 0
			SqlUpdate("TblRsGrp", "tg_tgid = " + SqlCnv(toTableRes.tr_tgid), toTableRes, 6)
		ENDIF
	ELSE
		lnResSplitId = -toTableRes.tr_trid
		toTableRes.tr_trid = g_oBridgeFunc.NextID('TABLERES')
		IF toTableRes.tg_tgid = -1
			toTableRes.tr_tgid = g_oBridgeFunc.NextID('TBLRSGRP')
		ENDIF
		toTableRes.tr_created = DATETIME()
		IF TYPE("toTableRes.nCopyTrId") = "N"
			lnCopyFrom = toTableRes.nCopyTrId
		ENDIF
		toTableRes.tr_changes = ""
		toTableRes.tr_changes = PtrChanges(toTableRes, ICASE(lnResSplitId > 0, "IMPORT", EMPTY(lnCopyFrom), "CREATED", "COPY from TrID: " + TRANSFORM(lnCopyFrom)))
		SqlInsert("Tableres",,5, toTableRes)
		IF toTableRes.tg_tgid = -1
			toTableRes.tg_tgid = toTableRes.tr_tgid
			SqlInsert("TblRsGrp",,5, toTableRes)
		ENDIF
		IF lnResSplitId > 0
			SqlInsert("DeskTblr", "dr_drid,dr_trid,dr_rlid", 1, ;
				SqlCnv(g_oBridgeFunc.NextID('DESKTBLR')) + "," + SqlCnv(toTableRes.tr_trid) + "," + SqlCnv(lnResSplitId))
		ENDIF
	ENDIF
ENDIF
IF NOT tlEnvironmentAlreadyPrepared
	g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
ENDIF

RETURN lnErrorCode
ENDFUNC
*
FUNCTION ptrUser
LPARAMETERS tnWaiter, tcUser, tcUserId, tcUserName
LOCAL lcUser

lcUser = IIF(EMPTY(tnWaiter), "", "Waiter:" + TRANSFORM(tnWaiter))
lcUser = lcUser + IIF(EMPTY(lcUser) OR EMPTY(tcUser), "", "-") + ALLTRIM(tcUser)
lcUser = lcUser + IIF(EMPTY(lcUser) OR EMPTY(tcUserId), "", "-") + ALLTRIM(tcUserId)
IF NOT EMPTY(tcUserName)
	lcUser = ALLTRIM(tcUserName) + IIF(EMPTY(lcUser), "", " (" + lcUser + ")")
ENDIF

RETURN lcUser
ENDFUNC
*
FUNCTION ptrChanges
LPARAMETERS toTableRes, tcWhat
*not implemented tcWhat in "NOSHOW"
LOCAL lcWho, lcChanges, lcExcludeFields, loTableRes, lcurTableres

DO CASE
	CASE TYPE("g_userid") = "C"
		lcWho = g_userid
	CASE TYPE("gcuser") = "C"
		lcWho = gcuser
	CASE TYPE("gnWaiter") = "N"
		lcWho = "Waiter:" + TRANSFORM(gnWaiter)
	OTHERWISE
		lcWho = ""
ENDCASE

lcExcludeFields = "tr_trid,tr_tgid,tr_tableid,tr_status,tr_changes,tr_user,tr_userid,tr_waitnr,tr_created,tr_updated,tr_touched,tg_tgid"
IF TYPE("toTableRes.tg_tgid") = "U" OR toTableRes.tg_tgid = 0
	lcExcludeFields = lcExcludeFields + ",tg_locnr,tg_tables,tg_adults,tg_childs,tg_note"
ENDIF
IF tcWhat = "CHANGED"
	lcurTableres = SqlCursor("SELECT * FROM Tableres LEFT JOIN TblRsGrp ON tg_tgid = tr_tgid WHERE tr_trid = " + SqlCnv(toTableRes.tr_trid))
	SCATTER MEMO NAME loTableRes
	CFCleanRecordText(loTableRes)
	USE IN &lcurTableres
	IF INLIST(loTableRes.tr_status, TR_NS, TR_CXL) AND toTableRes.tr_status = TR_DEF
		tcWhat = "REACTIVATE"
	ENDIF
ENDIF
lcChanges = ALLTRIM(toTableRes.tr_changes) + IIF(EMPTY(toTableRes.tr_changes), "", CRLF) + LogChanges(SysDate(), lcWho, tcWhat, toTableRes, loTableRes, lcExcludeFields)

RETURN lcChanges
ENDFUNC
*
FUNCTION RecurrentReservation
LPARAMETERS toTableRes, tdDateTo, tlOnFailedRevert
LOCAL i, lnBuffTr, lnBuffTg, lnErrorCode, lcTables, lnTables, lnTable, lnFrom, lnTo, lnCounter, lnCreated
LOCAL ARRAY laTables(1)

MakeStructure("nFromTrId, nToTrId", toTableRes)
STORE 0 TO toTableRes.nFromTrId, toTableRes.nToTrId
IF EMPTY(tdDateTo)
	tdDateTo = toTableRes.tr_sysdate
ENDIF
STORE 0 TO lnErrorCode, lnTables, lnCounter, lnCreated

g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres, TblRsGrp, TblProps, DeskTblr')

FOR i = 1 TO GETWORDCOUNT(toTableRes.tg_tables,",")
	lcTables = GETWORDNUM(toTableRes.tg_tables,i,",")
	IF "-" $ lcTables
		lnFrom = INT(VAL(GETWORDNUM(lcTables,1,"-")))
		lnTo = INT(VAL(GETWORDNUM(lcTables,2,"-")))
		FOR lnTable = lnFrom TO lnTo
			IF lnTable > 0 AND 0 = ASCAN(laTables,lnTable) AND g_oBridgeFunc.DLocate('TblProps', 'tp_tablenr = ' + SqlCnv(lnTable))
				lnTables = lnTables + 1
				DIMENSION laTables(lnTables)
				laTables[lnTables] = lnTable
			ENDIF
		NEXT
	ELSE
		lnTable = INT(VAL(lcTables))
		IF lnTable >= 0 AND 0 = ASCAN(laTables,lnTable) AND (lnTable = 0 OR g_oBridgeFunc.DLocate('TblProps', 'tp_tablenr = ' + SqlCnv(lnTable)))
			lnTables = lnTables + 1
			DIMENSION laTables(lnTables)
			laTables[lnTables] = lnTable
		ENDIF
	ENDIF
NEXT
ASORT(laTables)

DO CASE
	CASE lnTables = 0
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1011|TBLRES","Invalid table number!"))
		lnErrorCode = 1
	CASE tdDateTo < toTableRes.tr_sysdate
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1333|TBLRES","Check date of reservation."))
		lnErrorCode = 3
	OTHERWISE
		* Generate reccurent and/or for other tables table reservations
		IF tlOnFailedRevert
			lnBuffTr = CURSORGETPROP("Buffering","Tableres")
			CURSORSETPROP("Buffering",5,"Tableres")
			lnBuffTg = CURSORGETPROP("Buffering","TblRsGrp")
			CURSORSETPROP("Buffering",5,"TblRsGrp")
		ENDIF
		IF ALEN(laTables) > 1
			toTableRes.tg_adults = toTableRes.tr_persons
			toTableRes.tr_persons = 0
			toTableRes.tg_childs = toTableRes.tr_childs
			toTableRes.tr_childs = 0
			toTableRes.tg_note = toTableRes.tr_note
			toTableRes.tr_note = ""
		ENDIF
		DO WHILE toTableRes.tr_sysdate <= tdDateTo
			IF ALEN(laTables) > 1
				toTableRes.tg_tgid = -1
			ENDIF
			FOR EACH lnTable IN laTables
				toTableRes.tr_trid = 0
				toTableRes.tr_tablenr = lnTable
				toTableRes.tr_from = CTOT(DTOC(toTableRes.tr_sysdate)+" "+TTOC(toTableRes.tr_from,2))
				toTableRes.tr_to = CTOT(DTOC(toTableRes.tr_sysdate)+" "+TTOC(toTableRes.tr_to,2))
				lnErrorCode = SaveOneReservation(toTableRes, .T.)
				IF lnErrorCode <> 0 AND (tlOnFailedRevert OR EMPTY(toTableRes.nFromTrId))
					IF tlOnFailedRevert
						TABLEREVERT(.T.,"Tableres")
						CURSORSETPROP("Buffering",lnBuffTr,"Tableres")
						TABLEREVERT(.T.,"TblRsGrp")
						CURSORSETPROP("Buffering",lnBuffTg,"TblRsGrp")
						g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1407|TBLRES","Table reservations haven't been created!"))
					ENDIF
					g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
					IF ALEN(laTables) > 1
						toTableRes.tg_tgid = 0
						toTableRes.tr_persons = toTableRes.tg_adults
						toTableRes.tg_adults = 0
						toTableRes.tr_childs = toTableRes.tg_childs
						toTableRes.tg_childs = 0
						toTableRes.tr_note = toTableRes.tg_note
						toTableRes.tg_note = ""
					ENDIF
					RETURN lnErrorCode	&& If 1st reservation failed or if selected entire location (revert all succeed reservations)
				ENDIF
				lnCounter = lnCounter + 1
				IF lnErrorCode = 0
					lnCreated = lnCreated + 1
					IF EMPTY(toTableRes.nFromTrId)
						toTableRes.nFromTrId = toTableRes.tr_trid
					ENDIF
					toTableRes.nToTrId = toTableRes.tr_trid
				ENDIF
			NEXT
			toTableRes.tr_sysdate = toTableRes.tr_sysdate + 1
		ENDDO
		IF tlOnFailedRevert
			TABLEUPDATE(.T.,.T.,"Tableres")
			CURSORSETPROP("Buffering",lnBuffTr,"Tableres")
			TABLEUPDATE(.T.,.T.,"TblRsGrp")
			CURSORSETPROP("Buffering",lnBuffTg,"TblRsGrp")
		ELSE
			lnErrorCode = 0	&& Behave like all is OK (close edit form). Just if 1st reservation failed than return error code.
		ENDIF
ENDCASE
g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
IF lnCounter > 1
	g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1404|TBLRES","Created %n1 of %n2 reservations for tables.", lnCreated, lnCounter))
ENDIF

RETURN lnErrorCode
ENDFUNC
*
FUNCTION MoveReservation
LPARAMETERS toTableRes
LOCAL lnBuffTr, lnBuffDr, lnErrorCode, lcurName, lnAnswer, lnCounter, lnChanged, loTableres, lnFirstTrId

MakeStructure("nFromTrId, nToTrId, cFilter", toTableRes)
STORE IIF(toTableRes.tr_trid > 0, toTableRes.tr_trid, 0) TO toTableRes.nFromTrId, toTableRes.nToTrId
lcurName = SYS(2015)
lnErrorCode = -1
DO CASE
	CASE NOT EMPTY(toTableRes.tr_tgid) AND toTableRes.tr_from <> toTableRes.oOldRes.tr_from
		lnAnswer = g_oBridgeFunc.YesNoCancel(g_oBridgeFunc.GetLanguageText("A|1408|TBLRES","Do you want to move entire group of reservations or you want to move;" + ;
			"selected reservation to table %n1 and time %d2 (%s3-%s4)?", ;
			toTableRes.tr_tablenr, toTableRes.tr_sysdate, LEFT(TTOC(toTableRes.tr_from,2),5), LEFT(TTOC(toTableRes.tr_to,2),5)) + ";;" + ;
			g_oBridgeFunc.GetLanguageText("A|1409|TBLRES","Yes - entire group;No - selected reservation"))
		DO CASE
			CASE lnAnswer = 6
				g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres, TblRsGrp, TblProps, DeskTblr')
				ObjToCur(toTableRes.oGroupRes, @lcurName)
				SELECT &lcurName
				lnChanged = 0
				lnCounter = RECCOUNT()
				SCAN FOR tr_status = TR_DEF
					IF tr_trid = toTableRes.tr_trid
						loTableres = toTableRes
					ELSE
						SCATTER MEMO NAME loTableres
						loTableres.tr_from = toTableRes.tr_from
						loTableres.tr_to = toTableRes.tr_to
						loTableres.tr_sysdate = toTableRes.tr_sysdate
					ENDIF
					lnErrorCode = SaveOneReservation(loTableres, .T.)

					IF lnErrorCode = 0
						lnChanged = lnChanged + 1
						IF EMPTY(lnFirstTrId)
							lnFirstTrId = loTableres.tr_trid
						ENDIF
						toTableRes.nToTrId = loTableres.tr_trid
					ENDIF
				ENDSCAN
				DClose(lcurName)
				IF NOT EMPTY(lnFirstTrId)
					toTableRes.nFromTrId = lnFirstTrId
				ENDIF
				IF lnCounter > 1
					toTableRes.cFilter = "tr_tgid = " + SqlCnv(toTableRes.tr_tgid)
					g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1410|TBLRES","Changed %n1 of %n2 reservations for tables.", lnChanged, lnCounter))
				ENDIF
				g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
			CASE lnAnswer = 7
				lnErrorCode = SaveOneReservation(toTableRes)
			OTHERWISE
		ENDCASE
	CASE g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1401|TBLRES","Do you want to move reservation to table %n1 and time %d2 (%s3-%s4)?", ;
			toTableRes.tr_tablenr, toTableRes.tr_sysdate, LEFT(TTOC(toTableRes.tr_from,2),5), LEFT(TTOC(toTableRes.tr_to,2),5)))
		IF PEMSTATUS(toTableRes, "oRecurRes", 5) AND g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1423|TBLRES","Do you want to move table reservations for the entire stay?"))
			g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres, TblRsGrp, TblProps, Location, DeskTblr')
			MakeStructure("lOK", toTableRes)
			lnBuffTr = CURSORGETPROP("Buffering","Tableres")
			CURSORSETPROP("Buffering",5,"Tableres")
			lnBuffDr = CURSORGETPROP("Buffering","DeskTblr")
			CURSORSETPROP("Buffering",5,"DeskTblr")
			ObjToCur(toTableRes.oRecurRes, @lcurName)
			SELECT &lcurName
			lnCounter = RECCOUNT()
			DO WHILE lnErrorCode <> 0
				STORE 0 TO lnChanged, lnFirstTrId
				SCAN
					IF tr_trid = toTableRes.tr_trid
						loTableres = toTableRes
					ELSE
						SCATTER MEMO NAME loTableres
						loTableres.tr_tablenr = toTableRes.tr_tablenr
						IF loTableres.tr_trid < 0
							loTableres.tr_from = CTOT(DTOC(loTableres.tr_sysdate)+" "+TTOC(toTableRes.tr_from,2))
							loTableres.tr_to = CTOT(DTOC(loTableres.tr_sysdate)+" "+TTOC(toTableRes.tr_to,2))
							IF NOT EMPTY(loTableres.ar_article)
								loTableres.tr_note = ALLTRIM(loTableres.ar_article)
							ENDIF
							IF EMPTY(loTableres.tr_usrname)
								loTableres.tr_usrname = toTableRes.tr_usrname
							ENDIF
						ENDIF
					ENDIF
					lnErrorCode = SaveOneReservation(loTableres, .T.)
					DO CASE
						CASE lnErrorCode = 0
							lnChanged = lnChanged + 1
							IF EMPTY(lnFirstTrId)
								lnFirstTrId = loTableres.tr_trid
							ENDIF
							toTableRes.nToTrId = loTableres.tr_trid
						CASE g_oBridgeFunc.PickAvailTable(toTableRes)
							TABLEREVERT(.T.,"Tableres")
							TABLEREVERT(.T.,"DeskTblr")
							EXIT
						OTHERWISE
							lnErrorCode = 0
					ENDCASE
				ENDSCAN
			ENDDO
			DClose(lcurName)
			TABLEUPDATE(.T.,.T.,"Tableres")
			CURSORSETPROP("Buffering",lnBuffTr,"Tableres")
			TABLEUPDATE(.T.,.T.,"DeskTblr")
			CURSORSETPROP("Buffering",lnBuffDr,"DeskTblr")
			IF NOT EMPTY(lnFirstTrId)
				toTableRes.nFromTrId = lnFirstTrId
			ENDIF
			IF lnCounter > 1
				toTableRes.cFilter = "tr_rsid = " + SqlCnv(toTableRes.tr_rsid)
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1410|TBLRES","Changed %n1 of %n2 reservations for tables.", lnChanged, lnCounter))
			ENDIF
			g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
		ELSE
			lnErrorCode = SaveOneReservation(toTableRes)
		ENDIF
	OTHERWISE
ENDCASE
PtrSyncExternalDb(toTableRes.tr_rsid)

RETURN lnErrorCode
ENDFUNC
*
FUNCTION UpdateGroupReservation
LPARAMETERS toTableRes
LOCAL i, lnErrorCode, lcurName, lcTables, lnTables, lnTable, lnFrom, lnTo, lnCounter, lnCreated, lnDeleted
LOCAL ARRAY laTables(1)

MakeStructure("nFromTrId, nToTrId, cFilter", toTableRes)
STORE 0 TO toTableRes.nFromTrId, toTableRes.nToTrId
STORE 0 TO lnErrorCode, lnTables, lnCounter, lnCreated, lnDeleted

g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres, TblRsGrp, TblProps, DeskTblr')

FOR i = 1 TO GETWORDCOUNT(toTableRes.tg_tables,",")
	lcTables = GETWORDNUM(toTableRes.tg_tables,i,",")
	IF "-" $ lcTables
		lnFrom = INT(VAL(GETWORDNUM(lcTables,1,"-")))
		lnTo = INT(VAL(GETWORDNUM(lcTables,2,"-")))
		FOR lnTable = lnFrom TO lnTo
			IF lnTable > 0 AND 0 = ASCAN(laTables,lnTable) AND g_oBridgeFunc.DLocate('TblProps', 'tp_tablenr = ' + SqlCnv(lnTable))
				lnTables = lnTables + 1
				DIMENSION laTables(lnTables)
				laTables[lnTables] = lnTable
			ENDIF
		NEXT
	ELSE
		lnTable = INT(VAL(lcTables))
		IF lnTable > 0 AND 0 = ASCAN(laTables,lnTable) AND g_oBridgeFunc.DLocate('TblProps', 'tp_tablenr = ' + SqlCnv(lnTable))
			lnTables = lnTables + 1
			DIMENSION laTables(lnTables)
			laTables[lnTables] = lnTable
		ENDIF
	ENDIF
NEXT
ASORT(laTables)

DO CASE
	CASE lnTables = 0 OR 0 = ASCAN(laTables, toTableRes.tr_tablenr)
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1011|TBLRES","Invalid table number!"))
		lnErrorCode = 1
	OTHERWISE
		lnErrorCode = SaveOneReservation(toTableRes, .T.)
		IF lnErrorCode = 0
			lcurName = SYS(2015)
			ObjToCur(toTableRes.oGroupRes, @lcurName)
			REPLACE tg_tgid WITH toTableRes.tg_tgid, ;
				tg_tables WITH toTableRes.tg_tables, ;
				tg_locnr WITH toTableRes.tg_locnr, ;
				tg_adults WITH toTableRes.tg_adults, ;
				tg_childs WITH toTableRes.tg_childs, ;
				tg_note WITH toTableRes.tg_note ALL IN &lcurName
			STORE 0 TO lnCreated, lnDeleted, lnCounter
			IF g_oBridgeFunc.DLocate(lcurName, "tr_tablenr = " + SqlCnv(toTableRes.oOldRes.tr_tablenr))
				lnRow = ASCAN(laTables, toTableRes.tr_tablenr)
				IF lnRow > 0
					lnCounter = lnCounter + 1
					DELETE IN &lcurName
					ADEL(laTables, lnRow)
					DIMENSION laTables(MAX(1,ALEN(laTables)-1))
				ENDIF
			ENDIF
			SELECT &lcurName
			SCAN
				lnRow = ASCAN(laTables, tr_tablenr)
				IF lnRow > 0
					lnCounter = lnCounter + 1
					DELETE
					ADEL(laTables, lnRow)
					DIMENSION laTables(MAX(1,ALEN(laTables)-1))
				ENDIF
			ENDSCAN
			SCAN FOR INLIST(tr_status, TR_IN, TR_OUT)
				lnCounter = lnCounter + 1
				DELETE
				ADEL(laTables, ALEN(laTables))
				DIMENSION laTables(MAX(1,ALEN(laTables)-1))
			ENDSCAN
			SCAN
				IF EMPTY(laTables(1))
					lnDeleted = lnDeleted + 1
					SqlDelete('Tableres','tr_trid = ' + SqlCnv(tr_trid))
				ELSE
					lnCounter = lnCounter + 1
					SCATTER MEMO NAME loTableres
					loTableres.tr_tablenr = laTables(1)
					lnErrorCode = SaveOneReservation(loTableres, .T.)
					IF lnErrorCode = 0
						lnDeleted = lnDeleted + 1
						lnCreated = lnCreated + 1
					ENDIF
					ADEL(laTables, 1)
					DIMENSION laTables(MAX(1,ALEN(laTables)-1))
				ENDIF
			ENDSCAN
			DClose(lcurName)
			IF NOT EMPTY(laTables(1))
				toTableRes.tr_persons = 0
				toTableRes.tr_childs = 0
				toTableRes.tr_note = ""
				FOR EACH lnTable IN laTables
					lnCounter = lnCounter + 1
					toTableRes.tr_trid = 0
					toTableRes.tr_tablenr = lnTable
					lnErrorCode = SaveOneReservation(toTableRes, .T.)
					IF lnErrorCode = 0
						lnCreated = lnCreated + 1
					ENDIF
				NEXT
			ENDIF
			IF lnCreated > 0 OR lnDeleted > 0
				toTableRes.cFilter = "tr_tgid = " + SqlCnv(toTableRes.tr_tgid)
			ENDIF
			lnErrorCode = 0	&& Behave like all is OK (close edit form). Just if 1st reservation failed than return error code.
		ENDIF
ENDCASE
g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
IF lnCounter > 1
	g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1422|TBLRES","Created %n1 and deleted %n2 of %n3 reservations for tables.", lnCreated, lnDeleted, lnCounter))
ENDIF

RETURN lnErrorCode
ENDFUNC
*
FUNCTION CheckReservation
LPARAMETERS toTableRes
LOCAL lnErrorCode, lcFromTime, lcToTime

lcFromTime = LEFT(TTOC(toTableRes.tr_from,2),5)
lcToTime = LEFT(TTOC(toTableRes.tr_to,2),5)
DO CASE
	CASE INLIST(toTableRes.tr_status, TR_NS, TR_CXL)
		lnErrorCode = 0
	CASE NOT BETWEEN(toTableRes.tr_tablenr, 0, 9999)
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1011|TBLRES","Invalid table number!"))
		lnErrorCode = 1
	CASE NOT EMPTY(toTableRes.tr_tablenr) AND NOT g_oBridgeFunc.DLocate('TblProps', 'tp_tablenr = ' + SqlCnv(toTableRes.tr_tablenr))
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1031|TBLRES","Table %s1 has no location!",SqlCnv(toTableRes.tr_tablenr)))
		lnErrorCode = 2
	CASE EMPTY(toTableRes.tr_sysdate)
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1333|TBLRES","Check date of reservation."))
		lnErrorCode = 3
	CASE EMPTY(CHRTRAN(lcFromTime,"0:",""))
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1334|TBLRES","Check reservation start time."))
		lnErrorCode = 4
	CASE EMPTY(CHRTRAN(lcToTime,"0:","")) OR lcFromTime > lcToTime
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1335|TBLRES","Check reservation end time."))
		lnErrorCode = 5
	CASE EMPTY(toTableRes.tr_persons) AND EMPTY(toTableRes.tg_adults)
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1336|TBLRES","Check No. of persons for reservation."))
		lnErrorCode = 6
	CASE NOT EMPTY(toTableRes.tr_tablenr) AND NOT EMPTY(TblProps.tp_seats) AND toTableRes.tr_persons+toTableRes.tr_childs > TblProps.tp_seats
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1425|TBLRES","No. of persons can't be greater than %s1.",SqlCnv(TblProps.tp_seats)))
		lnErrorCode = 6
	CASE EMPTY(toTableRes.tr_lname)
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1337|TBLRES","Check reservation name."))
		lnErrorCode = 7
	CASE NOT EMPTY(toTableRes.tr_tablenr) AND g_oBridgeFunc.DLocate('TableRes','tr_trid <> '+SqlCnv(toTableRes.tr_trid)+' AND tr_tablenr = '+SqlCnv(toTableRes.tr_tablenr)+;
			' AND tr_from < '+SqlCnv(toTableRes.tr_to)+' AND tr_to > '+SqlCnv(toTableRes.tr_from)+' AND NOT INLIST(tr_status,'+SqlCnv(TR_NS)+','+SqlCnv(TR_CXL)+','+SqlCnv(TR_OUT)+')')
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1338|TBLRES","Table %s1 already reserved to another guest.",SqlCnv(toTableRes.tr_tablenr)))
		lnErrorCode = 8
	CASE EMPTY(toTableRes.tr_usrname)
		g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1342|TBLRES","Check user."))
		lnErrorCode = 9
	OTHERWISE
		lnErrorCode = 0
ENDCASE

RETURN lnErrorCode
ENDFUNC
*
PROCEDURE ptrSearch
LPARAMETERS lp_oTableRes, lp_oTables
LOCAL l_cFilter, l_cFilterUn, l_cTblFilter, l_cFilterCaption

STORE "" TO l_cFilter, l_cFilterUn, l_cTblFilter, l_cFilterCaption

IF NOT EMPTY(lp_oTableRes.tr_tablenr)
	l_cFilter = SqlFilter(l_cFilter, 'tr_tablenr = ' + SqlCnv(lp_oTableRes.tr_tablenr,.T.,lp_oTableRes.lODBCArgus))
	l_cFilterCaption = g_oBridgeFunc.GetLanguageText("ARGUS","TH_TABLE")+":"+TRANSFORM(lp_oTableRes.tr_tablenr)
ENDIF
IF NOT EMPTY(lp_oTables.lc_deptnr)
	l_cTblFilter = SqlFilter(l_cTblFilter, 'lc_deptnr = ' + SqlCnv(lp_oTables.lc_deptnr,.T.,lp_oTableRes.lODBCArgus))
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TH_DEPARTMENT")+":"+ALLTRIM(lp_oTables.dp_descr)
ENDIF
IF NOT EMPTY(lp_oTables.lc_locnr)
	l_cTblFilter = SqlFilter(l_cTblFilter, 'lc_locnr = ' + SqlCnv(lp_oTables.lc_locnr,.T.,lp_oTableRes.lODBCArgus))
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TH_LOCATION")+":"+ALLTRIM(lp_oTables.lc_descr)
ENDIF
IF NOT EMPTY(lp_oTables.tp_feat1)
	l_cTblFilter = SqlFilter(l_cTblFilter, 'INLIST(' + SqlCnv(lp_oTables.tp_feat1,.T.,lp_oTableRes.lODBCArgus) + ', tp_feat1, tp_feat2, tp_feat3, tp_feat4, tp_feat5, lc_feat1, lc_feat2, lc_feat3, lc_feat4, lc_feat5)')
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TH_FEATURE")+":"+ALLTRIM(lp_oTables.tp_feat1)
ENDIF
IF NOT EMPTY(lp_oTableRes.tr_sysdate)
	l_cFilter = SqlFilter(l_cFilter, 'tr_sysdate = ' + SqlCnv(lp_oTableRes.tr_sysdate,.T.,lp_oTableRes.lODBCArgus))
	l_cFilterUn = SqlFilter(l_cFilterUn, 'rl_rdate = ' + SqlCnv(lp_oTableRes.tr_sysdate,.T.,lp_oTableRes.lODBCArgus))
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TH_DATE")+":"+TRANSFORM(lp_oTableRes.tr_sysdate)
ENDIF
IF NOT EMPTY(lp_oTableRes.tr_from)
	l_cFilter = SqlFilter(l_cFilter, 'tr_from >= ' + SqlCnv(lp_oTableRes.tr_from,.T.,lp_oTableRes.lODBCArgus))
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TH_FROM")+":"+TRANSFORM(lp_oTableRes.tr_from)
ENDIF
IF NOT EMPTY(lp_oTableRes.tr_lname)
	l_cFilter = SqlFilter(l_cFilter, 'LIKE(' + SqlCnv(ALLTRIM(lp_oTableRes.tr_lname) + '*',.T.,lp_oTableRes.lODBCArgus) + ', UPPER(tr_lname))')
	l_cFilterUn = SqlFilter(l_cFilterUn, 'LIKE(' + SqlCnv(ALLTRIM(lp_oTableRes.tr_lname) + '*',.T.,lp_oTableRes.lODBCArgus) + ', UPPER(EVL(rs_lname,ad_lname)))')
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TXT_LAST_NAME")+":"+ALLTRIM(lp_oTableRes.tr_lname)
ENDIF
IF NOT EMPTY(lp_oTableRes.tr_fname)
	l_cFilter = SqlFilter(l_cFilter, 'LIKE(' + SqlCnv(ALLTRIM(lp_oTableRes.tr_fname) + '*',.T.,lp_oTableRes.lODBCArgus) + ', UPPER(tr_fname))')
	l_cFilterUn = SqlFilter(l_cFilterUn, 'LIKE(' + SqlCnv(ALLTRIM(lp_oTableRes.tr_fname) + '*',.T.,lp_oTableRes.lODBCArgus) + ', UPPER(EVL(rs_fname,ad_fname)))')
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TXT_FIRST_NAME")+":"+ALLTRIM(lp_oTableRes.tr_fname)
ENDIF
IF NOT EMPTY(lp_oTableRes.tr_persons)
	l_cFilter = SqlFilter(l_cFilter, 'tr_persons = ' + SqlCnv(lp_oTableRes.tr_persons,.T.,lp_oTableRes.lODBCArgus))
	l_cFilterCaption = l_cFilterCaption + " " + g_oBridgeFunc.GetLanguageText("ARGUS","TXT_PERSONS")+":"+TRANSFORM(lp_oTableRes.tr_persons)
ENDIF

lp_oTableRes.cFilter = l_cFilter
lp_oTableRes.cFilterUn = l_cFilterUn
lp_oTables.cFilter = l_cTblFilter
lp_oTableRes.cCaption = ALLTRIM(l_cFilterCaption)

RETURN .T.
ENDPROC
*
PROCEDURE ptrDelete
LPARAMETERS toTableRes, tnMode
LOCAL lnStatus, lcGuest, lnAnswer, lnChanged, lnCounter, lcAction, lcFilter, lcFunction, lcurTableres, lcTblTableres, lcurName
PRIVATE pcChangesPTR

IF toTableRes.tr_trid > 0
	tnMode = 0
	MakeStructure("nFromTrId, nToTrId, cFilter", toTableRes)
	STORE 0 TO toTableRes.nFromTrId, toTableRes.nToTrId
	IF NOT EMPTY(toTableRes.tr_tgid)
		lcTblTableres = IIF(TYPE("toTableRes.curTableres") = "C" AND NOT EMPTY(toTableRes.curTableres), toTableRes.curTableres, "tblTableres")
		lcurTableres = SYS(2015)
		SELECT * FROM &lcTblTableres WHERE tr_tgid = toTableRes.tr_tgid INTO CURSOR &lcurTableres
		MakeStructure("oGroupRes", toTableRes)
		toTableRes.oGroupRes = CurToObj(lcurTableres)
		DClose(lcurTableres)
	ENDIF
	g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres, TblRsGrp')
	lcGuest = ALLTRIM(toTableRes.tr_lname)+", "+ALLTRIM(toTableRes.tr_fname)
	DO CASE
		CASE toTableRes.tr_status = TR_IN
			DO CASE
				CASE NOT EMPTY(toTableRes.tr_tgid)
					lnAnswer = g_oBridgeFunc.YesNoCancel(g_oBridgeFunc.GetLanguageText("A|1411|TBLRES","Do you want to undo check in entire group of reservations or;undo check in guest %s1 for table %n2?", ;
						lcGuest, toTableRes.tr_tablenr) + ";;" + g_oBridgeFunc.GetLanguageText("A|1409|TBLRES","Yes - entire group;No - selected reservation"))
					IF INLIST(lnAnswer, 6, 7)
						tnMode = EDIT_MODE
						lcFilter = "tr_status = " + TRANSFORM(TR_IN)
						lnStatus = TR_DEF
						lcAction = "UNDOCHECKIN"
						lcFunction = g_oBridgeFunc.GetLanguageText("A|1412|TBLRES","Undo checked in")
					ENDIF
				CASE g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1393|TBLRES","Do you want to undo check in guest %s1 for table %n2?", lcGuest, toTableRes.tr_tablenr))
					tnMode = EDIT_MODE
					lnStatus = TR_DEF
					lcAction = "UNDOCHECKIN"
				OTHERWISE
			ENDCASE
		CASE toTableRes.tr_status = TR_OUT
			DO CASE
				CASE NOT EMPTY(toTableRes.tr_tgid)
					lnAnswer = g_oBridgeFunc.YesNoCancel(g_oBridgeFunc.GetLanguageText("A|1413|TBLRES","Do you want to undo check out entire group of reservations or;undo check out guest %s1 from table %n2?", ;
						lcGuest, toTableRes.tr_tablenr) + ";;" + g_oBridgeFunc.GetLanguageText("A|1409|TBLRES","Yes - entire group;No - selected reservation"))
					IF INLIST(lnAnswer, 6, 7)
						tnMode = EDIT_MODE
						lcFilter = "tr_status = " + TRANSFORM(TR_OUT)
						lnStatus = TR_IN
						lcAction = "UNDOCHECKOUT"
						lcFunction = g_oBridgeFunc.GetLanguageText("A|1414|TBLRES","Undo checked out")
					ENDIF
				CASE g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1394|TBLRES","Do you want to undo check out guest %s1 from table %n2?", lcGuest, toTableRes.tr_tablenr))
					tnMode = EDIT_MODE
					lnStatus = TR_IN
					lcAction = "UNDOCHECKOUT"
				OTHERWISE
			ENDCASE
		CASE INLIST(toTableRes.tr_status, TR_NS, TR_CXL)
			DO CASE
				CASE NOT EMPTY(toTableRes.tr_tgid)
					lnAnswer = g_oBridgeFunc.YesNoCancel(g_oBridgeFunc.GetLanguageText("A|1415|TBLRES","Do you want to delete entire group of reservations or;delete reservation for table %n1 and guest %s2?", ;
						toTableRes.tr_tablenr, lcGuest) + ";;" + g_oBridgeFunc.GetLanguageText("A|1409|TBLRES","Yes - entire group;No - selected reservation"))
					IF INLIST(lnAnswer, 6, 7)
						lcFilter = "NOT INLIST(tr_status, " + TRANSFORM(TR_IN) + ", " + TRANSFORM(TR_OUT) + ")"
						tnMode = DELETE_MODE
						lcFunction = g_oBridgeFunc.GetLanguageText("A|1416|TBLRES","Deleted")
					ENDIF
				CASE g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1390|TBLRES","Do you want to delete reservation for table %n1 and guest %s2?", toTableRes.tr_tablenr, lcGuest))
					tnMode = DELETE_MODE
				OTHERWISE
			ENDCASE
		OTHERWISE
			lnAnswer = g_oBridgeFunc.YesNoCancel(g_oBridgeFunc.GetLanguageText("A|1405|TBLRES","Do you want to cancel or delete forever reservation for table %n1 and guest %s2?;;Yes - cancellation;No - deleting", toTableRes.tr_tablenr, lcGuest))
			DO CASE
				CASE lnAnswer = 6
					tnMode = EDIT_MODE
					lnStatus = TR_CXL
					lcAction = "CANCELED"
					IF NOT EMPTY(toTableRes.tr_tgid)
						IF g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1417|TBLRES","Do you want to cancel entire group of reservations?"))
							lcFilter = "NOT INLIST(tr_status, " + TRANSFORM(TR_IN) + ", " + TRANSFORM(TR_OUT) + ", " + TRANSFORM(TR_NS) + ", " + TRANSFORM(TR_CXL) + ")"
							lcFunction = g_oBridgeFunc.GetLanguageText("A|1418|TBLRES","Canceled")
						ELSE
							lnAnswer = 7
						ENDIF
					ENDIF
				CASE lnAnswer = 7
					tnMode = DELETE_MODE
					IF NOT EMPTY(toTableRes.tr_tgid)
						IF g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1419|TBLRES","Do you want to delete entire group of reservations?"))
							lnAnswer = 6
							lcFilter = "NOT INLIST(tr_status, " + TRANSFORM(TR_IN) + ", " + TRANSFORM(TR_OUT) + ")"
							lcFunction = g_oBridgeFunc.GetLanguageText("A|1416|TBLRES","Deleted")
						ENDIF
					ENDIF
				OTHERWISE
			ENDCASE
	ENDCASE
	DO CASE
		CASE NOT INLIST(tnMode, EDIT_MODE, DELETE_MODE)
		CASE NOT EMPTY(toTableRes.tr_tgid) AND lnAnswer = 6
			lcurName = SYS(2015)
			ObjToCur(toTableRes.oGroupRes, @lcurName)
			SELECT &lcurName
			lnChanged = 0
			lnCounter = RECCOUNT()
			SCAN FOR &lcFilter
				SCATTER MEMO NAME loTableRes
				IF tnMode = DELETE_MODE
					SqlDelete('Tableres','tr_trid = ' + SqlCnv(loTableRes.tr_trid))
				ELSE
					pcChangesPTR = PtrChanges(loTableRes, lcAction)
					SqlUpdate('Tableres','tr_trid = ' + SqlCnv(loTableRes.tr_trid),'tr_status = ' + SqlCnv(lnStatus) + ',tr_changes = __SQLPARAM__pcChangesPTR')
				ENDIF

				lnChanged = lnChanged + 1
				IF EMPTY(toTableRes.nFromTrId)
					toTableRes.nFromTrId = loTableRes.tr_trid
				ENDIF
				toTableRes.nToTrId = loTableRes.tr_trid
			ENDSCAN
			DClose(lcurName)
			IF lnCounter > 1
				toTableRes.cFilter = "tr_tgid = " + SqlCnv(toTableRes.tr_tgid)
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1420|TBLRES","%s1 %n2 of %n3 reservations for tables.", lcFunction, lnChanged, lnCounter))
			ENDIF
		CASE tnMode = DELETE_MODE
			SqlDelete('Tableres','tr_trid = ' + SqlCnv(toTableRes.tr_trid))
		OTHERWISE
			pcChangesPTR = PtrChanges(toTableRes, lcAction)
			SqlUpdate('Tableres','tr_trid = ' + SqlCnv(toTableRes.tr_trid),'tr_status = ' + SqlCnv(lnStatus) + ',tr_changes = __SQLPARAM__pcChangesPTR')
	ENDCASE
	IF tnMode = DELETE_MODE AND NOT EMPTY(toTableRes.tr_tgid)
		lcurName = SqlCursor("SELECT COUNT(*) AS c_cnt FROM Tableres WHERE tr_tgid = " + SqlCnv(toTableRes.tr_tgid), lcurName)
		IF &lcurName..c_cnt = 0
			SqlDelete('TblRsGrp','tg_tgid = ' + SqlCnv(toTableRes.tr_tgid))
		ENDIF
		DClose(lcurName)
	ENDIF
	g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
	PtrSyncExternalDb(toTableRes.tr_rsid)
ENDIF
ENDPROC
*
PROCEDURE ptrCheckIn
LPARAMETERS lp_oTableres, lp_nMode, lp_lSilent
LOCAL l_nStatus, l_cGuest

lp_nMode = 0
IF lp_oTableres.tr_trid > 0 AND NOT INLIST(lp_oTableres.tr_status, TR_NS, TR_CXL)
	g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres')
	l_cGuest = ALLTRIM(lp_oTableres.tr_lname)+", "+ALLTRIM(lp_oTableres.tr_fname)
	DO CASE
		CASE lp_oTableres.tr_sysdate <> SysDate()
			IF NOT lp_lSilent
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1403|TBLRES","Reservation must be on system date!"))
			ENDIF
		CASE lp_oTableres.tr_status = TR_IN
			IF NOT lp_lSilent
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1396|TBLRES","Guest %s1 is already checked in for table %n2!", l_cGuest, lp_oTableres.tr_tablenr))
			ENDIF
		CASE lp_oTableres.tr_status = TR_OUT
			IF NOT lp_lSilent
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1397|TBLRES","Guest %s1 is already checked out from table %n2!", l_cGuest, lp_oTableres.tr_tablenr))
			ENDIF
		CASE g_oBridgeFunc.DLocate("Tableres", "tr_trid <> " + SqlCnv(lp_oTableres.tr_trid) + " AND tr_tablenr = " + SqlCnv(lp_oTableres.tr_tablenr) + ;
				" AND tr_sysdate = " + SqlCnv(lp_oTableres.tr_sysdate) + " AND tr_status = " + SqlCnv(TR_IN))
			IF NOT lp_lSilent
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1395|TBLRES","There is checked in guests for table %n1.;All checked in guests have to be checked out first!", lp_oTableres.tr_tablenr))
			ENDIF
		CASE lp_lSilent OR g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1391|TBLRES","Do you want to check IN guest %s1 for table %n2?", l_cGuest, lp_oTableres.tr_tablenr))
			lp_nMode = EDIT_MODE
		OTHERWISE
	ENDCASE
	IF lp_nMode = EDIT_MODE
		PRIVATE pcChangesPTR
		pcChangesPTR = PtrChanges(lp_oTableres, "CHECKIN")
		SqlUpdate('Tableres','tr_trid = ' + SqlCnv(lp_oTableres.tr_trid),'tr_status = ' + SqlCnv(TR_IN) + ',tr_changes = __SQLPARAM__pcChangesPTR')
	ENDIF
	g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
ENDIF
ENDPROC
*
PROCEDURE ptrCheckOut
LPARAMETERS lp_oTableres, lp_nMode, lp_lSilent
LOCAL l_nStatus, l_cGuest

lp_nMode = 0
IF lp_oTableres.tr_trid > 0 AND NOT INLIST(lp_oTableres.tr_status, TR_NS, TR_CXL)
	g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres')
	l_cGuest = ALLTRIM(lp_oTableres.tr_lname)+", "+ALLTRIM(lp_oTableres.tr_fname)
	DO CASE
		CASE lp_oTableres.tr_status < TR_IN
			IF NOT lp_lSilent
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1400|TBLRES","Guest %s1 isn't checked in for table %n2, yet.", l_cGuest, lp_oTableres.tr_tablenr))
			ENDIF
		CASE lp_oTableres.tr_status = TR_OUT
			IF NOT lp_lSilent
				g_oBridgeFunc.Alert(g_oBridgeFunc.GetLanguageText("A|1397|TBLRES","Guest %s1 is already checked out from table %n2!", l_cGuest, lp_oTableres.tr_tablenr))
			ENDIF
		CASE lp_lSilent OR g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1392|TBLRES","Do you want to check OUT guest %s1 from table %n2?", l_cGuest, lp_oTableres.tr_tablenr))
			lp_nMode = EDIT_MODE
		OTHERWISE
	ENDCASE
	IF lp_nMode = EDIT_MODE
		PRIVATE pcChangesPTR
		pcChangesPTR = PtrChanges(lp_oTableres, "CHECKOUT")
		SqlUpdate('Tableres','tr_trid = ' + SqlCnv(lp_oTableres.tr_trid),'tr_status = ' + SqlCnv(TR_OUT) + ',tr_changes = __SQLPARAM__pcChangesPTR')
	ENDIF
	g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')
ENDIF
ENDPROC
*
PROCEDURE ptrReactivate
LPARAMETERS toTableRes
LOCAL lnErrorCode

lnErrorCode = -1
IF INLIST(toTableRes.tr_status, TR_NS, TR_CXL) AND g_oBridgeFunc.YesNo(g_oBridgeFunc.GetLanguageText("A|1406|TBLRES","Do you want to reactivate reservation to table %n1 and time %d2 (%s3-%s4)?", ;
		toTableRes.tr_tablenr, toTableRes.tr_sysdate, LEFT(TTOC(toTableRes.tr_from,2),5), LEFT(TTOC(toTableRes.tr_to,2),5)))
	toTableRes.tr_status = TR_DEF
	lnErrorCode = SaveOneReservation(toTableRes)
ENDIF

RETURN lnErrorCode
ENDPROC
*
PROCEDURE ptrCopyReset
LPARAMETERS toTableRes

IF TYPE("toTableRes.nCopyTrId") = "N" AND toTableRes.nCopyTrId > 0
	toTableRes.tr_trid = 0
	toTableRes.tr_tableid = 0
	IF toTableRes.tr_status <> TR_ASG
		toTableRes.tr_status = TR_DEF
	ENDIF
	toTableRes.tr_changes = ""
	toTableRes.tr_user = ""
	toTableRes.tr_userid = ""
	toTableRes.tr_waitnr = 0
	toTableRes.tr_created = {}
	toTableRes.tr_updated = {}
	toTableRes.tr_touched = .F.
	IF toTableRes.tr_tgid > 0
		toTableRes.tr_persons = toTableRes.tg_adults
		toTableRes.tr_childs = toTableRes.tg_childs
		toTableRes.tr_note = toTableRes.tg_note
		toTableRes.tr_tgid = 0
		toTableRes.tg_tgid = 0
		toTableRes.tg_adults = 0
		toTableRes.tg_childs = 0
		toTableRes.tg_note = ""
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE ptrSyncExternalDb
LPARAMETERS tnRsID
LOCAL lnArea, lcurIndicators, lnRsId, lcRsg

lnArea = SELECT()
lcurIndicators = SYS(2015)

g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'ARGUS', 'Tableres, DeskTblr')
g_oBridgeFunc.PrepareEnvironment(SET("Datasession"), 'BRILLIANT', 'Reservat, Ressplit, Ratearti, Resrart')

SELECT DISTINCT rl_rsid, IIF(NVL(tr_tablenr,0) = 0,'t','T') AS rsg FROM FORessplit ;
	LEFT JOIN FOResrart rra ON rra.ra_rsid = rl_rsid AND rra.ra_raid = rl_raid AND rra.ra_ratecod = rl_ratecod ;
	LEFT JOIN FORatearti ra ON ra.ra_raid = rl_raid AND ra.ra_ratecod = rl_ratecod ;
	LEFT JOIN DeskTblr ON dr_rlid = rl_rlid ;
	LEFT JOIN Tableres ON tr_trid = dr_trid ;
	WHERE (EMPTY(tnRsID) OR rl_rsid = tnRsID) AND NVL(NVL(rra.ra_atblres, ra.ra_atblres), 0=1) ;
	ORDER BY 1, 2 DESC ;
	INTO CURSOR &lcurIndicators
IF USED(lcurIndicators) AND RECCOUNT(lcurIndicators) > 0
	REPLACE rs_extflag WITH CHRTRAN(FOReservat.rs_extflag, "tT", "") FOR rs_extflag <> CHRTRAN(rs_extflag, "tT", "") IN FOReservat
	lnRsId = 0
	lcRsg = ""
	SELECT &lcurIndicators
	SCAN
		IF lnRsId <> rl_rsid
			IF NOT EMPTY(lcRsg) AND g_oBridgeFunc.DLocate("FOReservat", "rs_rsid = " + SqlCnv(lnRsId))
				REPLACE rs_extflag WITH lcRsg + CHRTRAN(ALLTRIM(FOReservat.rs_extflag), "tT", "") IN FOReservat
			ENDIF
			lnRsId = rl_rsid
			lcRsg = ""
		ENDIF
		lcRsg = lcRsg + rsg
	ENDSCAN
	IF NOT EMPTY(lcRsg) AND g_oBridgeFunc.DLocate("FOReservat", "rs_rsid = " + SqlCnv(lnRsId))
		REPLACE rs_extflag WITH lcRsg + CHRTRAN(ALLTRIM(FOReservat.rs_extflag), "tT", "") IN FOReservat
	ENDIF
ENDIF
DClose(lcurIndicators)

g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'BRILLIANT')
g_oBridgeFunc.RestoreEnvironment(SET("Datasession"), 'ARGUS')

SELECT (lnArea)
ENDPROC
*