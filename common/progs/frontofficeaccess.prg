*
#INCLUDE "cryptor.h"
*
PROCEDURE IsRemoteServerUsed
	LPARAMETERS tcApplication
	LOCAL loDatabaseProp, llUseRemote

	IF TYPE("goDatabases") = "O"
		loDatabaseProp = IIF(goDatabases.GetKey(tcApplication) = 0, .NULL., goDatabases.Item(tcApplication))
		IF VARTYPE(loDatabaseProp) = "O"
			llUseRemote = (NOT EMPTY(loDatabaseProp.cServerName) AND NOT EMPTY(loDatabaseProp.nServerPort))
		ENDIF
	ENDIF

	RETURN llUseRemote
ENDPROC
*
PROCEDURE ExtractFilters
	LPARAMETERS tcTables
	LOCAL lcRemoteFilters, lnTableNo, lcTable, lcTables

	IF "@@" $ tcTables
		lcTables = tcTables
		DO WHILE NOT EMPTY(STREXTRACT(lcTables, "@@", "@@", 1))
			lcFilter = STREXTRACT(lcTables, "@@", "@@", 1)
			lcTables = STRTRAN(lcTables, "@@"+lcFilter+"@@", "", 1)
		ENDDO
		lcRemoteFilters = tcTables
		FOR lnTableNo = 1 TO GETWORDCOUNT(lcTables, ",")
			lcTable = ALLTRIM(GETWORDNUM(lcTables, lnTableNo, ","))
			lcTable = GETWORDNUM(lcTables, lnTableNo, ",")
			IF lcTable+"@@" $ lcRemoteFilters
				lcRemoteFilters = STRTRAN(lcRemoteFilters, lcTable, "", 1)
			ELSE
				lcRemoteFilters = STRTRAN(lcRemoteFilters, lcTable, "@@ @@", 1)
			ENDIF
		NEXT
		lcRemoteFilters = STRTRAN(lcRemoteFilters, ",@@")
		lcRemoteFilters = SUBSTR(lcRemoteFilters, 3, LEN(lcRemoteFilters)-4)
		tcTables = lcTables
	ELSE
		lcRemoteFilters = ""
	ENDIF

	RETURN lcRemoteFilters
ENDPROC
*
FUNCTION OpenBrilliantTable
	LPARAMETERS tcTable, tcAlias, tlExclusive, tnBufferMode, tcRemoteFilter
	LOCAL llOpened

	IF BrilliantFrontOfficeExists()
		llOpened = g_oBrilliantFrontOffice.OpenTable(tcTable, tcAlias, tlExclusive, tnBufferMode, tcRemoteFilter)
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION BatchOpenBrilliantTable
	LPARAMETERS tcTables, tcAliases, tlExclusive, tnBufferMode, tcTablesWithFilters
	LOCAL llOpened

	IF BrilliantFrontOfficeExists()
		llOpened = g_oBrilliantFrontOffice.BatchOpenTable(tcTables, tcAliases, tlExclusive, tnBufferMode, tcTablesWithFilters)
	ENDIF

	RETURN llOpened
ENDFUNC
*
PROCEDURE CloseBrilliantTable
	LPARAMETERS tcAlias

	IF BrilliantFrontOfficeExists()
		g_oBrilliantFrontOffice.CloseTable(tcAlias)
	ENDIF
ENDPROC
*
PROCEDURE BatchCloseBrilliantTable
	LPARAMETERS tcAliases

	IF BrilliantFrontOfficeExists()
		g_oBrilliantFrontOffice.BatchCloseTable(tcAliases)
	ENDIF
ENDPROC
*
FUNCTION QueryBrilliantTable
	LPARAMETERS tcTable, tcAlias, tcWhere
	LOCAL llOpened

	IF BrilliantFrontOfficeExists()
		llOpened = g_oBrilliantFrontOffice.QueryTable(tcTable, tcAlias, tcWhere)
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION BatchQueryBrilliantTable
	LPARAMETERS tcTables, tcAliases, tcTablesWithFilters
	LOCAL llOpened, lnTableNo, lcTable, lcAlias, lcRemoteFilter

	IF BrilliantFrontOfficeExists()
		tcTablesWithFilters = EVL(tcTablesWithFilters,"")
		FOR lnTableNo = 1 TO GETWORDCOUNT(tcTables, ",")
			lcTable = ALLTRIM(GETWORDNUM(tcTables, lnTableNo, ","))
			lcAlias = ALLTRIM(GETWORDNUM(tcAliases, lnTableNo, ","))
			lcRemoteFilter = ALLTRIM(GETWORDNUM(tcTablesWithFilters, lnTableNo, "@@"))
			llOpened = g_oBrilliantFrontOffice.QueryTable(lcTable, lcAlias, lcRemoteFilter)
			IF NOT llOpened
				EXIT
			ENDIF
		NEXT
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION BrilliantFrontOfficeExists
	RETURN TYPE("g_oBrilliantFrontOffice") = "O" AND NOT ISNULL(g_oBrilliantFrontOffice)
ENDFUNC
*
FUNCTION PrepareBrilliantFrontOffice
	LPARAMETERS tcPathToBrilliantFrontOffice, tlAliasSameAsTable, tcErrorHnd, tlLicenseOpened, tlKeepTryingToOpenTable, tlUseDatabase
	LOCAL l_lDBAvailable
	l_lDBAvailable = .T.
	PUBLIC g_oBrilliantFrontOffice

	IF NOT BrilliantFrontOfficeExists()
		g_oBrilliantFrontOffice = CREATEOBJECT("BrilliantFrontOffice", tcPathToBrilliantFrontOffice, SET("Datasession"), tcErrorHnd, tlUseDatabase)
	ENDIF
	IF BrilliantFrontOfficeExists()
		g_oBrilliantFrontOffice.SetDatasession(SET("Datasession"))
		g_oBrilliantFrontOffice.lAliasSameAsTable = tlAliasSameAsTable
		g_oBrilliantFrontOffice.lLicenseOpened = tlLicenseOpened
		g_oBrilliantFrontOffice.lKeepTryingToOpenTable = tlKeepTryingToOpenTable
		l_lDBAvailable = tlKeepTryingToOpenTable OR g_oBrilliantFrontOffice.DBIsAvailable()
	ENDIF
	RETURN BrilliantFrontOfficeExists() AND l_lDBAvailable
ENDFUNC
*
FUNCTION RemoveBrilliantFrontOffice
	IF TYPE("g_oBrilliantFrontOffice") = "O" AND NOT ISNULL(g_oBrilliantFrontOffice) AND g_oBrilliantFrontOffice.lLicenseOpened
		g_oBrilliantFrontOffice.CloseTable("FOLicense")
	ENDIF
	RELEASE g_oBrilliantFrontOffice
ENDFUNC
*
FUNCTION BrilliantNextId
	LPARAMETERS tcAliasCode
	LOCAL lnNewId

	IF BrilliantFrontOfficeExists()
		lnNewId = g_oBrilliantFrontOffice.NextId(tcAliasCode)
	ELSE
		lnNewId = 0
	ENDIF

	RETURN lnNewId
ENDFUNC
*
FUNCTION BrilliantSqlQuery
	LPARAMETERS tcTables, tcAliases, tcSqlStatement
	LOCAL llSuccess

	IF BrilliantFrontOfficeExists()
		llSuccess = g_oBrilliantFrontOffice.SqlQuery(tcTables, tcAliases, tcSqlStatement)
	ENDIF

	RETURN llSuccess
ENDFUNC
*
FUNCTION OpenArgusTable
	LPARAMETERS tcTable, tcAlias, tlExclusive, tnBufferMode, tcRemoteFilter
	LOCAL llOpened

	IF ArgusFrontOfficeExists()
		llOpened = g_oArgusFrontOffice.OpenTable(tcTable, tcAlias, tlExclusive, tnBufferMode, tcRemoteFilter)
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION BatchOpenArgusTable
	LPARAMETERS tcTables, tcAliases, tlExclusive, tnBufferMode, tcTablesWithFilters
	LOCAL llOpened

	IF ArgusFrontOfficeExists()
		llOpened = g_oArgusFrontOffice.BatchOpenTable(tcTables, tcAliases, tlExclusive, tnBufferMode, tcTablesWithFilters)
	ENDIF

	RETURN llOpened
ENDFUNC
*
PROCEDURE CloseArgusTable
	LPARAMETERS tcAlias

	IF ArgusFrontOfficeExists()
		g_oArgusFrontOffice.CloseTable(tcAlias)
	ENDIF
ENDPROC
*
PROCEDURE BatchCloseArgusTable
	LPARAMETERS tcAliases

	IF ArgusFrontOfficeExists()
		g_oArgusFrontOffice.BatchCloseTable(tcAliases)
	ENDIF
ENDPROC
*
FUNCTION QueryArgusTable
	LPARAMETERS tcTable, tcAlias, tcWhere
	LOCAL llOpened

	IF ArgusFrontOfficeExists()
		llOpened = g_oArgusFrontOffice.QueryTable(tcTable, tcAlias, tcWhere)
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION BatchQueryArgusTable
	LPARAMETERS tcTables, tcAliases, tcTablesWithFilters
	LOCAL llOpened, lnTableNo, lcTable, lcAlias, lcRemoteFilter

	IF ArgusFrontOfficeExists()
		tcTablesWithFilters = EVL(tcTablesWithFilters,"")
		FOR lnTableNo = 1 TO GETWORDCOUNT(tcTables, ",")
			lcTable = ALLTRIM(GETWORDNUM(tcTables, lnTableNo, ","))
			lcAlias = ALLTRIM(GETWORDNUM(tcAliases, lnTableNo, ","))
			lcRemoteFilter = ALLTRIM(GETWORDNUM(tcTablesWithFilters, lnTableNo, "@@"))
			llOpened = g_oArgusFrontOffice.QueryTable(lcTable, lcAlias, lcRemoteFilter)
			IF NOT llOpened
				EXIT
			ENDIF
		NEXT
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION ArgusFrontOfficeExists
	RETURN TYPE("g_oArgusFrontOffice") = "O" AND NOT ISNULL(g_oArgusFrontOffice)
ENDFUNC
*
FUNCTION PrepareArgusFrontOffice
	LPARAMETERS tcPathToArgusFrontOffice, tlAliasSameAsTable, tcErrorHnd
	PUBLIC g_oArgusFrontOffice

	IF NOT ArgusFrontOfficeExists()
		g_oArgusFrontOffice = CREATEOBJECT("ArgusFrontOffice", tcPathToArgusFrontOffice, SET("Datasession"), tcErrorHnd)
	ENDIF
	IF ArgusFrontOfficeExists()
		g_oArgusFrontOffice.SetDatasession(SET("Datasession"))
		g_oArgusFrontOffice.lAliasSameAsTable = tlAliasSameAsTable
	ENDIF
	RETURN ArgusFrontOfficeExists()
ENDFUNC
*
FUNCTION RemoveArgusFrontOffice
	RELEASE g_oArgusFrontOffice
ENDFUNC
*
FUNCTION ArgusNextId
	LPARAMETERS tcAliasCode
	LOCAL lnNewId

	IF ArgusFrontOfficeExists()
		lnNewId = g_oArgusFrontOffice.NextId(tcAliasCode)
	ELSE
		lnNewId = 0
	ENDIF

	RETURN lnNewId
ENDFUNC
*
FUNCTION ArgusSqlQuery
	LPARAMETERS tcTables, tcAliases, tcSqlStatement
	LOCAL llSuccess

	IF ArgusFrontOfficeExists()
		llSuccess = g_oArgusFrontOffice.SqlQuery(tcTables, tcAliases, tcSqlStatement)
	ENDIF

	RETURN llSuccess
ENDFUNC
*
FUNCTION OpenWellnessTable
	LPARAMETERS tcTable, tcAlias, tlExclusive, tnBufferMode, tcRemoteFilter
	LOCAL llOpened

	IF WellnessFrontOfficeExists()
		llOpened = g_oWellnessFrontOffice.OpenTable(tcTable, tcAlias, tlExclusive, tnBufferMode, tcRemoteFilter)
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION BatchOpenWellnessTable
	LPARAMETERS tcTables, tcAliases, tlExclusive, tnBufferMode, tcTablesWithFilters
	LOCAL llOpened

	IF WellnessFrontOfficeExists()
		llOpened = g_oWellnessFrontOffice.BatchOpenTable(tcTables, tcAliases, tlExclusive, tnBufferMode, tcTablesWithFilters)
	ENDIF

	RETURN llOpened
ENDFUNC
*
PROCEDURE CloseWellnessTable
	LPARAMETERS tcAlias

	IF WellnessFrontOfficeExists()
		g_oWellnessFrontOffice.CloseTable(tcAlias)
	ENDIF
ENDPROC
*
PROCEDURE BatchCloseWellnessTable
	LPARAMETERS tcAliases

	IF WellnessFrontOfficeExists()
		g_oWellnessFrontOffice.BatchCloseTable(tcAliases)
	ENDIF
ENDPROC
*
FUNCTION QueryWellnessTable
	LPARAMETERS tcTable, tcAlias, tcWhere
	LOCAL llOpened

	IF WellnessFrontOfficeExists()
		llOpened = g_oWellnessFrontOffice.QueryTable(tcTable, tcAlias, tcWhere)
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION BatchQueryWellnessTable
	LPARAMETERS tcTables, tcAliases, tcTablesWithFilters
	LOCAL llOpened, lnTableNo, lcTable, lcAlias, lcRemoteFilter

	IF WellnessFrontOfficeExists()
		tcTablesWithFilters = EVL(tcTablesWithFilters,"")
		FOR lnTableNo = 1 TO GETWORDCOUNT(tcTables, ",")
			lcTable = ALLTRIM(GETWORDNUM(tcTables, lnTableNo, ","))
			lcAlias = ALLTRIM(GETWORDNUM(tcAliases, lnTableNo, ","))
			lcRemoteFilter = ALLTRIM(GETWORDNUM(tcTablesWithFilters, lnTableNo, "@@"))
			llOpened = g_oWellnessFrontOffice.QueryTable(lcTable, lcAlias, lcRemoteFilter)
			IF NOT llOpened
				EXIT
			ENDIF
		NEXT
	ENDIF

	RETURN llOpened
ENDFUNC
*
FUNCTION WellnessFrontOfficeExists
	RETURN TYPE("g_oWellnessFrontOffice") = "O" AND NOT ISNULL(g_oWellnessFrontOffice)
ENDFUNC
*
FUNCTION PrepareWellnessFrontOffice
	LPARAMETERS tcPathToWellnessFrontOffice, tlAliasSameAsTable, tcErrorHnd
	PUBLIC g_oWellnessFrontOffice
	
	IF VARTYPE(tlAliasSameAsTable)<>"L"
		tlAliasSameAsTable = .F.
	ENDIF
	IF NOT WellnessFrontOfficeExists()
		g_oWellnessFrontOffice = CREATEOBJECT("WellnessFrontOffice", tcPathToWellnessFrontOffice, SET("Datasession"), tcErrorHnd)
	ENDIF
	IF WellnessFrontOfficeExists()
		g_oWellnessFrontOffice.SetDatasession(SET("Datasession"))
		g_oWellnessFrontOffice.lAliasSameAsTable = tlAliasSameAsTable
	ENDIF
	RETURN WellnessFrontOfficeExists()
ENDFUNC
*
FUNCTION RemoveWellnessFrontOffice
	RELEASE g_oWellnessFrontOffice
ENDFUNC
*
FUNCTION WellnessNextId
	LPARAMETERS tcAliasCode
	LOCAL lnNewId

	IF WellnessFrontOfficeExists()
		lnNewId = g_oWellnessFrontOffice.NextId(tcAliasCode)
	ELSE
		lnNewId = 0
	ENDIF

	RETURN lnNewId
ENDFUNC
*
FUNCTION WellnessSqlQuery
	LPARAMETERS tcTables, tcAliases, tcSqlStatement
	LOCAL llSuccess

	IF WellnessFrontOfficeExists()
		llSuccess = g_oWellnessFrontOffice.SqlQuery(tcTables, tcAliases, tcSqlStatement)
	ENDIF

	RETURN llSuccess
ENDFUNC
*
DEFINE CLASS BrilliantFrontOffice AS FrontOffice
	cCaClasses = "common\progs\cadefdesk.prg"
	cRemoteDatabase = "DESK"
	lLicenseOpened = .F. && Use to leave license table open, to signal desk that somebody is using database

	PROTECTED FUNCTION Init
		LPARAMETERS tcPathToFrontOffice, tnDataSessionId, tcErrorHnd, tlUseDatabase
		IF tlUseDatabase
			this.lUseDatabase = .T.
			this.cDatabaseName = "Brilliant.dbc"
			this.cNextIdSProc = "sp_newid('%1')"
		ENDIF
		this.lRemote = IsRemoteServerUsed("DESK")
		RETURN DODEFAULT(tcPathToFrontOffice, tnDataSessionId, tcErrorHnd)
	ENDFUNC

	FUNCTION DBIsAvailable
		LOCAL lDBAvailable
		IF this.lRemote OR this.OpenTable("license", "FOLicense")
			IF NOT this.lLicenseOpened
				this.CloseTable("FOLicense")
			ENDIF
			lDBAvailable = .T.
		ENDIF
		RETURN lDBAvailable
	ENDPROC

	FUNCTION NextId
		LPARAMETERS tcAliasCode
		LOCAL lnArea, lnReturnNewID, lnOldReprocess, lnOldReprocessType, lcIDAlias, loDatabaseProp, llSuccess, lcSqlFunc

		IF this.lRemote
			lnReturnNewID = 0
			loDatabaseProp = IIF(goDatabases.GetKey(this.cRemoteDatabase) = 0, .NULL., goDatabases.Item(this.cRemoteDatabase))
			IF VARTYPE(loDatabaseProp) = "O"
				lcSqlFunc = "SqlRemote"	&& External function
				lnReturnNewID = &lcSqlFunc("EVAL", "NextId('"+TRANSFORM(tcAliasCode)+"')",,loDatabaseProp,,@llSuccess)
				IF NOT llSuccess
					lnReturnNewID = 0
				ENDIF
			ENDIF
		ELSE
			lnReturnNewID = DODEFAULT(tcAliasCode)
		ENDIF

		IF EMPTY(lnReturnNewID)
			*** Check Param
			IF NOT EMPTY(tcAliasCode) AND TYPE('tcAliasCode') == 'C'
				*** and convert to upper case
				tcAliasCode = UPPER(PADR(tcAliasCode,8))

				*** Open id.dbf if not already open
				lcIDAlias = IIF(this.lAliasSameAsTable, "id", SYS(2015))
				IF this.OpenTable("id", lcIDAlias)
					*** Now find the required table
					lnArea = SELECT()
					SELECT &lcIDAlias
					LOCATE FOR id_code = tcAliasCode
					SELECT (lnArea)
					IF FOUND(lcIDAlias)
						*** Found the required table
						*** Get a Lock on id table
						lnOldReprocess = SET("Reprocess")
						lnOldReprocessType = SET("Reprocess", 2)
						SET REPROCESS TO AUTOMATIC
						IF RLOCK(lcIDAlias)
							*** Set next value and update id
							lnReturnNewID = &lcIDAlias..id_last + 1
							REPLACE id_last WITH lnReturnNewID IN (lcIDAlias)
							UNLOCK IN &lcIDAlias
						ENDIF
						IF lnOldReprocessType = 1
							SET REPROCESS TO (lnOldReprocess) SECONDS
						ELSE
							SET REPROCESS TO (lnOldReprocess)
						ENDIF
					ELSE
						*** Not found, needs a new entry in id
						lnReturnNewID = 1
						INSERT INTO &lcIDAlias (id_code, id_last) VALUES (tcAliasCode, lnReturnNewID)
					ENDIF

					*** Close id.dbf
					this.CloseTable(lcIDAlias)
				ENDIF
			ENDIF
		ENDIF

		RETURN lnReturnNewID
	ENDFUNC

ENDDEFINE
*
DEFINE CLASS ArgusFrontOffice AS FrontOffice
	cCaClasses = "common\progs\cadefargus.prg"

	PROTECTED FUNCTION Init
		LPARAMETERS tcPathToFrontOffice, tnDataSessionId, tcErrorHnd
		LOCAL llCreated

		IF this.cApp = "DESK"
			this.lOdbc = EVALUATE(this.cGlobal+".lODBCArgus")
			*this.lRemote = IsRemoteServerUsed("ARGUS")
		ENDIF

		llCreated = DODEFAULT(tcPathToFrontOffice, tnDataSessionId, tcErrorHnd)

		RETURN llCreated
	ENDFUNC

	FUNCTION NextId
		LPARAMETERS tcAliasCode
		LOCAL lnArea, lnReturnNewID, lnOldReprocess, lnOldReprocessType, lcIDAlias

		lnReturnNewID = DODEFAULT(tcAliasCode)

		IF EMPTY(lnReturnNewID)
			*** Check Param
			IF NOT EMPTY(tcAliasCode) AND TYPE('tcAliasCode') == 'C'
				*** and convert to upper case
				tcAliasCode = UPPER(PADR(tcAliasCode,10))

				*** Open id.dbf if not already open
				lcIDAlias = IIF(this.lAliasSameAsTable, "id", SYS(2015))
				IF this.OpenTable("id", lcIDAlias)
					*** Now find the required table
					lnArea = SELECT()
					SELECT &lcIDAlias
					LOCATE FOR id_name = tcAliasCode
					SELECT (lnArea)
					*** Get a Lock on id table
					lnOldReprocess = SET("Reprocess")
					lnOldReprocessType = SET("Reprocess", 2)
					SET REPROCESS TO AUTOMATIC
					IF FOUND(lcIDAlias)
						*** Found the required table
						IF RLOCK(lcIDAlias)
							*** Set next value and update id
							IF tcAliasCode = "BILLNUM"
								lnReturnNewID = this.GetCheckNo(&lcIDAlias..id_last)
							ELSE
								lnReturnNewID = &lcIDAlias..id_last + 1
							ENDIF
							REPLACE id_last WITH lnReturnNewID IN (lcIDAlias)
							UNLOCK IN &lcIDAlias
						ENDIF
					ELSE
						*** Not found, needs a new entry in id
						IF RLOCK("0", lcIDAlias)
							lnReturnNewID = 1
							IF tcAliasCode = "BILLNUM"
								SELECT &lcIDAlias
								LOCATE FOR id_name = "CHECK"
								SELECT (lnArea)
								IF FOUND(lcIDAlias)
									lnReturnNewID = &lcIDAlias..id_last + 1
								ENDIF
							ENDIF
							INSERT INTO &lcIDAlias (id_name, id_last) VALUES (tcAliasCode, lnReturnNewID)
							UNLOCK IN &lcIDAlias RECORD 0
						ENDIF
					ENDIF
					IF lnOldReprocessType = 1
						SET REPROCESS TO (lnOldReprocess) SECONDS
					ELSE
						SET REPROCESS TO (lnOldReprocess)
					ENDIF

					*** Close id.dbf
					this.CloseTable(lcIDAlias)
				ENDIF
			ENDIF
		ENDIF

		RETURN lnReturnNewID
	ENDFUNC

	FUNCTION GetCheckNo
		LPARAMETERS tnLastId
		LOCAL lcParamAlias, lnSysYear, lcCurrentId, lnCurrentYear, lcApplicationId, lnReturnNewID

		*** Constant, identifies application
		lcApplicationId = "20"

		lcCurrentId = PADL(tnLastId, 10, "0")
		lnCurrentYear = INT(VAL(SUBSTR(lcCurrentId, 3, 2)))

		lcParamAlias = SYS(2015)
		IF this.OpenTable("param", lcParamAlias) AND &lcParamAlias..pa_yearchk
			lnSysYear = MOD(YEAR(&lcParamAlias..pa_sysdate),100)
			*** Close param.dbf
			this.CloseTable(lcParamAlias)
		ELSE
			lnSysYear = lnCurrentYear
		ENDIF

		*** Is year changed?
		IF lnCurrentYear = lnSysYear
			*** No
			lnReturnNewID = INT(VAL(STUFF(lcCurrentId, 1, 2, lcApplicationId))) + 1
		ELSE
			*** Yes
			lnReturnNewID = INT(VAL(lcApplicationId + PADL(lnSysYear,2,"0") + PADL(1,6,"0")))
		ENDIF

		RETURN lnReturnNewID
	ENDFUNC

ENDDEFINE
*
DEFINE CLASS WellnessFrontOffice AS FrontOffice
	FUNCTION NextId
		LPARAMETERS tcAliasCode
		LOCAL lnArea, lnReturnNewID, lnOldReprocess, lnOldReprocessType, lcIDAlias

		lnReturnNewID = DODEFAULT(tcAliasCode)

		IF EMPTY(lnReturnNewID)
			*** Check Param
			IF NOT EMPTY(tcAliasCode) AND TYPE('tcAliasCode') == 'C'
				*** and convert to upper case
				tcAliasCode = UPPER(PADR(tcAliasCode,10))

				*** Open id.dbf if not already open
				lcIDAlias = IIF(this.lAliasSameAsTable, "id", SYS(2015))
				IF this.OpenTable("id", lcIDAlias)
					*** Now find the required table
					lnArea = SELECT()
					SELECT &lcIDAlias
					LOCATE FOR id_code = tcAliasCode
					SELECT (lnArea)
					*** Get a Lock on id table
					lnOldReprocess = SET("Reprocess")
					lnOldReprocessType = SET("Reprocess", 2)
					SET REPROCESS TO AUTOMATIC
					IF FOUND(lcIDAlias)
						*** Found the required table
						IF RLOCK(lcIDAlias)
							*** Set next value and update id
							lnReturnNewID = &lcIDAlias..id_last + 1
							REPLACE id_last WITH lnReturnNewID IN (lcIDAlias)
							UNLOCK IN &lcIDAlias
						ENDIF
					ELSE
						*** Not found, needs a new entry in id
						IF RLOCK("0", lcIDAlias)
							lnReturnNewID = 1
							INSERT INTO &lcIDAlias (id_code, id_last) VALUES (tcAliasCode, lnReturnNewID)
							UNLOCK IN &lcIDAlias RECORD 0
						ENDIF
					ENDIF
					IF lnOldReprocessType = 1
						SET REPROCESS TO (lnOldReprocess) SECONDS
					ELSE
						SET REPROCESS TO (lnOldReprocess)
					ENDIF

					*** Close id.dbf
					this.CloseTable(lcIDAlias)
				ENDIF
			ENDIF
		ENDIF

		RETURN lnReturnNewID
	ENDFUNC

ENDDEFINE
*
DEFINE CLASS FrontOffice AS Custom
	PROTECTED cGlobal
	PROTECTED lUseDatabase
	PROTECTED lOdbc
	PROTECTED lRemote
	PROTECTED cRemoteDatabase
	PROTECTED cCaClasses
	PROTECTED lErrorOccured
	PROTECTED cErrorMsg
	PROTECTED cApp
	PROTECTED cPathToDatabase
	PROTECTED nDataSessionId
	PROTECTED cDatabaseName
	PROTECTED cNextIdSProc
	PROTECTED cErrorHnd
	PROTECTED nTableCount
	PROTECTED aTablePool[1,2]
			* aTablePool[i,1] - Alias
			* aTablePool[i,2] - Table

	nDataSessionId = 1
	cErrorMsg = ""
	lAliasSameAsTable = .F.
	cGlobal = ""
	cApp = ""
	cRemoteDatabase = ""
	cCaClasses = ""
	cPathToDatabase = ""
	cDatabaseName = ""
	cNextIdSProc = ""
	cErrorHnd = ""
	nTableCount = 0
	lKeepTryingToOpenTable = .F.

	PROTECTED FUNCTION Init
		LPARAMETERS tcPathToFrontOffice, tnDataSessionId, tcErrorHnd
		LOCAL llCreated

		IF TYPE("gcApplication") = "C" AND UPPER(gcApplication) = "CITADEL DESK"
			this.cApp = "DESK"
			this.cGlobal = "_screen.oGlobal"
		ELSE
			this.cApp = "ARGUS"
			this.cGlobal = "goGlobal"
		ENDIF
		this.cErrorHnd = tcErrorHnd
		IF NOT this.lRemote
			this.cPathToDatabase = ADDBS(ALLTRIM(tcPathToFrontOffice))
		ENDIF
		IF this.lUseDatabase AND NOT EMPTY(this.cDatabaseName) AND FILE(this.cPathToDatabase + this.cDatabaseName)
			this.SetDatasession(tnDataSessionId)
			OPEN DATABASE (this.cPathToDatabase + this.cDatabaseName) SHARED
			llCreated = DBUSED(JUSTSTEM(this.cDatabaseName))
		ELSE
			this.lUseDatabase = .F.
			llCreated = this.lRemote OR DIRECTORY(this.cPathToDatabase)
		ENDIF

		RETURN llCreated
	ENDFUNC

	PROTECTED PROCEDURE Destroy
		LOCAL lnTableNo

		this.SetDatasession()
		FOR lnTableNo = this.nTableCount TO 1 STEP -1
			this.CloseTable(this.aTablePool[lnTableNo,1])
		NEXT
		IF this.lUseDatabase
			CLOSE DATABASES
		ENDIF
		this.cPathToDatabase = ""
	ENDPROC

	PROTECTED PROCEDURE Error
		LPARAMETERS tnError, tcMethod, tnLine
		LOCAL lcErrorHnd

		this.lErrorOccured = .T.
		this.cErrorMsg = MESSAGE()
		IF EMPTY(this.cErrorHnd)
			*MESSAGEBOX(this.cErrorMsg, 16, "FrontOffice Error...")
			DODEFAULT(tnError, tcMethod, tnLine)
		ELSE
			lcErrorHnd = this.cErrorHnd
			&lcErrorHnd
		ENDIF
	ENDPROC

	PROTECTED PROCEDURE ResetError
		this.lErrorOccured = .F.
		this.cErrorMsg = ""
	ENDPROC

	PROTECTED FUNCTION IsCursor
		LPARAMETERS tcAlias

		this.ResetError()

		RETURN NOT JUSTEXT(DBF(tcAlias)) == "DBF"
	ENDPROC

	PROCEDURE SetDatasession
		LPARAMETERS tnDataSessionId

		IF NOT EMPTY(tnDataSessionId)
			this.nDataSessionId = tnDataSessionId
			*SET DATASESSION TO this.nDataSessionId
		ENDIF
	ENDPROC

	FUNCTION NextId
		LPARAMETERS tcAliasCode
		LOCAL lnReturnNewID, lcNextIdSProc
		
		this.ResetError()
		this.SetDatasession()

		IF this.lUseDatabase AND NOT EMPTY(this.cNextIdSProc)
			lcNextIdSProc = STRTRAN(this.cNextIdSProc, "%1", tcAliasCode)
			lnReturnNewID = &lcNextIdSProc
		ELSE
			lnReturnNewID = 0
		ENDIF

		RETURN lnReturnNewID
	ENDFUNC

	FUNCTION OpenTable
		LPARAMETERS tcTable, tcAlias, tlExclusive, tnBufferMode, tcRemoteFilter
		#DEFINE FO_OPENTABLE_TIMEOUT	10
		LOCAL llOpened, lcMacro, lnTableNo, lnRecNo, ltTime, lcTables, lcTablesCount, llNew

		this.ResetError()
		this.SetDatasession()

		tcAlias = IIF(this.lAliasSameAsTable OR EMPTY(tcAlias), JUSTSTEM(tcTable), tcAlias)
		tnBufferMode = IIF(TYPE("tnBufferMode") = "N" AND BETWEEN(tnBufferMode, 1, 5), tnBufferMode, 1)

		IF USED(tcAlias) AND this.IsCursor(tcAlias)
			IF TYPE(tcAlias+"._n_recno")="N"
				lnRecNo = &tcAlias.._n_recno
			ENDIF
			USE IN &tcAlias
		ENDIF

		llNew = .T.
		DO CASE
			CASE USED(tcAlias)
				llNew = .F.
			CASE NOT ProcCryptor(CR_REGISTER, this.cPathToDatabase, JUSTSTEM(tcTable))
			CASE this.lOdbc
				this.OpenOdbcTable(tcTable, tcAlias)
				tnBufferMode = IIF(tnBufferMode > 3, 5, 3)
			CASE this.lRemote
				this.OpenRemoteTable(tcTable, tcAlias, tcRemoteFilter)
				tnBufferMode = IIF(tnBufferMode > 3, 5, 3)
			OTHERWISE
				IF this.lUseDatabase
					lcMacro = JUSTSTEM(this.cDatabaseName) + "!" + JUSTSTEM(tcTable)
				ELSE
					lcMacro = '"' + ADDBS(this.cPathToDatabase) + FORCEEXT(JUSTFNAME(tcTable), "dbf") + '"'
				ENDIF
				lcMacro = "USE " + lcMacro + " IN 0 AGAIN" + IIF(tcAlias == JUSTSTEM(tcTable), "", " ALIAS " + tcAlias) + IIF(tlExclusive, " EXCLUSIVE", " SHARED")
				IF this.lKeepTryingToOpenTable
					ltTime = DATETIME()
					DO WHILE NOT USED(tcAlias) AND DATETIME() < ltTime + FO_OPENTABLE_TIMEOUT
						&lcMacro
						IF NOT USED(tcAlias)
							INKEY(1,"HM")
						ENDIF
					ENDDO
				ELSE
					&lcMacro
				ENDIF
		ENDCASE

		IF USED(tcAlias)
			llOpened = .T.
			IF CURSORGETPROP("Buffering", tcAlias) <> tnBufferMode
				CURSORSETPROP("Buffering", tnBufferMode, tcAlias)
			ENDIF
			IF NOT EMPTY(lnRecNo)
				GO lnRecNo IN &tcAlias
			ENDIF
			IF llNew
				lcTables = IIF(TYPE("paTables",1) = "A", "paTables", "this.aTablePool")
				lcTablesCount = IIF(TYPE("paTables",1) = "A", "pnTablesCount", "this.nTableCount")
				lnTableNo = ASCAN(&lcTables, ALLTRIM(LOWER(tcAlias)), 1, 0, 1, 14)
				IF lnTableNo = 0
					&lcTablesCount = &lcTablesCount + 1
					lnTableNo = &lcTablesCount
					DIMENSION &lcTables(lnTableNo, 2)
				ENDIF
				&lcTables[lnTableNo,1] = ALLTRIM(LOWER(tcAlias))
				&lcTables[lnTableNo,2] = ALLTRIM(LOWER(FORCEEXT(JUSTFNAME(tcTable), "dbf")))
			ENDIF
		ENDIF

		RETURN llOpened
	ENDFUNC

	FUNCTION BatchOpenTable
		LPARAMETERS tcTables, tcAliases, tlExclusive, tnBufferMode, tcTablesWithFilters
		LOCAL llOpened, lnTableNo, lcTable, lcAlias, lcRemoteFilter

		tcTablesWithFilters = EVL(tcTablesWithFilters,"")
		FOR lnTableNo = 1 TO GETWORDCOUNT(tcTables, ",")
			lcTable = ALLTRIM(GETWORDNUM(tcTables, lnTableNo, ","))
			lcAlias = ALLTRIM(GETWORDNUM(tcAliases, lnTableNo, ","))
			lcRemoteFilter = ALLTRIM(GETWORDNUM(tcTablesWithFilters, lnTableNo, "@@"))
			llOpened = this.OpenTable(lcTable, lcAlias, tlExclusive, tnBufferMode, lcRemoteFilter)
			IF NOT llOpened
				EXIT
			ENDIF
		NEXT

		RETURN llOpened
	ENDFUNC

	FUNCTION BatchCloseTable
		LPARAMETERS tcAliases
		LOCAL lnTableNo, lcAlias

		FOR lnTableNo = 1 TO GETWORDCOUNT(tcAliases, ",")
			lcAlias = ALLTRIM(GETWORDNUM(tcAliases, lnTableNo, ","))
			this.CloseTable(lcAlias)
		NEXT
	ENDFUNC

	FUNCTION RemovePrefix
		LPARAMETERS tcTables, tcAliases, tcSql
		LOCAL lcSql, lnTableNo, lcTable, lcAlias

		lcSql = tcSql
		FOR lnTableNo = 1 TO GETWORDCOUNT(tcTables, ",")
			lcTable = ALLTRIM(GETWORDNUM(tcTables, lnTableNo, ","))
			lcAlias = ALLTRIM(GETWORDNUM(tcAliases, lnTableNo, ","))
			lcSql = STRTRAN(lcSql, lcAlias, lcTable, -1, -1, 1)
		NEXT

		RETURN lcSql
	ENDFUNC

	FUNCTION QueryTable
		LPARAMETERS tcTable, tcAlias, tcWhere
		LOCAL lnRecNo, lcTable, lcDbSource, lcDbSrcAlias, lnTableNo

		this.ResetError()
		this.SetDatasession()

		lcTable = JUSTSTEM(tcTable)
		lcDbSrcAlias = SYS(2015)
		tcAlias = IIF(EMPTY(tcAlias), SYS(2015), tcAlias)
		tcWhere = IIF(EMPTY(tcWhere), "0=0", tcWhere)

		IF USED(tcAlias) AND NOT this.IsCursor(tcAlias)
			lnRecNo = RECNO(tcAlias)
			this.CloseTable(tcAlias)
		ENDIF

		DO CASE
			CASE USED(tcAlias) OR NOT ProcCryptor(CR_REGISTER, this.cPathToDatabase, lcTable)
			CASE this.lOdbc
				this.SqlQueryOdbc(tcTable, tcAlias, "SELECT *, CAST(0 AS Int) AS _n_recno FROM "+tcTable+" WHERE "+tcWhere, tcAlias)
				IF USED(tcAlias)
					REPLACE _n_recno WITH RECNO() ALL IN &tcAlias
					SELECT &tcAlias
					LOCATE
				ENDIF
			CASE this.lRemote
				this.SqlQueryRemote(tcTable, tcAlias, "SELECT *, CAST(0 AS Int) AS _n_recno FROM "+tcTable+" WHERE "+tcWhere, tcAlias)
				IF USED(tcAlias)
					REPLACE _n_recno WITH RECNO() ALL IN &tcAlias
					SELECT &tcAlias
					LOCATE
				ENDIF
			OTHERWISE
				IF this.lUseDatabase
					lcDbSource = JUSTSTEM(this.cDatabaseName) + "!" + lcTable
				ELSE
					lcDbSource = '"' + ADDBS(this.cPathToDatabase) + FORCEEXT(lcTable, "dbf") + '"'
				ENDIF
				USE &lcDbSource IN 0 AGAIN ALIAS &lcDbSrcAlias
				IF USED(lcDbSrcAlias)
					SELECT *, RECNO() AS _n_recno FROM &lcDbSrcAlias WHERE &tcWhere INTO CURSOR &tcAlias
					USE IN &lcDbSrcAlias
				ENDIF
		ENDCASE

		IF USED(tcAlias) AND NOT EMPTY(lnRecNo)
			SELECT &tcAlias
			LOCATE FOR _n_recno = lnRecNo
		ENDIF

		RETURN USED(tcAlias)
	ENDFUNC

	FUNCTION OpenOdbcTable
		LPARAMETERS tcTable, tcAlias

		IF NOT PEMSTATUS(this, tcTable, 5)
			this.AddProperty(tcTable, NEWOBJECT("ca"+tcTable, this.cCaClasses, "", .T.))
			this.&tcTable..lCreateIndexes = .T.
		ENDIF
		IF NOT EMPTY(tcAlias)
			this.&tcTable..Alias = tcAlias
		ENDIF
		this.&tcTable..CursorQuery(.T., "0=1")
	ENDFUNC

	FUNCTION SqlQueryOdbc
		LPARAMETERS tcTables, tcAliases, tcSql, tcCursor
		LOCAL lcSql, lcScript, llSuccess, lcSqlFunc

		IF "INTO CURSOR" $ tcSql
			lcSql = STREXTRACT(tcSql,"","INTO CURSOR",1,2)
			tcCursor = GETWORDNUM(STREXTRACT(tcSql,"INTO CURSOR",""),1)
		ELSE
			lcSql = tcSql
		ENDIF
		lcSql = this.RemovePrefix(tcTables, tcAliases, lcSql)

		TEXT TO lcScript TEXTMERGE NOSHOW PRETEXT 2+1
		LPARAMETERS tcSql, tcCursor
		LOCAL i, lnRetVal, llSuccess, lcErrorText, llReconnected

		lcSqlFunc = "SqlParse"	&& External function
		tcSql = &lcSqlFunc(tcSql,.T.,,.T.)
		FOR i = 1 TO 2
			lnRetVal = SQLEXEC(<<this.cGlobal>>.oGData.GetHandle(.T.), tcSql, tcCursor)
			llSuccess = (lnRetVal > 0)
			IF lnRetVal < 0
				lcErrorText = GetAErrorText()
				IF NOT llReconnected AND <<this.cGlobal>>.oGData.Reconnected(.T.)
					llReconnected = .T.
					LOOP
				ENDIF
				ASSERT .F. MESSAGE lcErrorText
				LogData(TRANSFORM(DATETIME()) + " " + lcErrorText, "odbc.err")
			ENDIF
			EXIT
		NEXT
		CFCursorNullsRemove(.T.,tcCursor,.T.)

		RETURN llSuccess
		ENDTEXT

		llSuccess = EXECSCRIPT(lcScript, lcSql, tcCursor)

		RETURN llSuccess
	ENDFUNC

	FUNCTION SqlQuery
		LPARAMETERS tcTables, tcAliases, tcSqlStatement
		LOCAL llSuccess

		this.ResetError()
		this.SetDatasession()

		DO CASE
			CASE this.lOdbc
				this.SqlQueryOdbc(tcTables, tcAliases, tcSqlStatement)
				llSuccess = NOT this.lErrorOccured
			CASE this.lRemote
				this.SqlQueryRemote(tcTables, tcAliases, tcSqlStatement)
				llSuccess = NOT this.lErrorOccured
			OTHERWISE
				PRIVATE paTables, pnTablesCount
				DIMENSION paTables(1)
				pnTablesCount = 0
				IF this.BatchOpenTable(tcTables, tcAliases)
					&tcSqlStatement
					llSuccess = NOT this.lErrorOccured
				ENDIF
				this.BatchCloseTable(tcAliases)
				RELEASE paTables, pnTablesCount
		ENDCASE

		RETURN llSuccess
	ENDFUNC

	FUNCTION OpenRemoteTable
		LPARAMETERS tcTable, tcAlias, tcRemoteFilter
		LOCAL i, lcCa

		lcCa = tcTable
		FOR i = 1 TO 2		&& If already opened same FO table remotely then open it again with different Alias.
			IF NOT PEMSTATUS(this, lcCa, 5)
				this.AddProperty(lcCa)
			ENDIF
			IF VARTYPE(this.&lcCa) = "O"
				IF NOT EMPTY(tcAlias) AND this.&lcCa..Alias <> tcAlias
					lcCa = tcTable+"_"+tcAlias
				ENDIF
			ELSE
				this.&lcCa = NEWOBJECT("ca"+tcTable, this.cCaClasses, "",,this.cRemoteDatabase)
				this.&lcCa..lCreateIndexes = .T.
				IF NOT EMPTY(tcAlias)
					this.&lcCa..Alias = tcAlias
				ENDIF
				EXIT
			ENDIF
		ENDFOR
		this.&lcCa..cRemoteFilter = tcRemoteFilter
		this.&lcCa..CursorQuery(.T.)
	ENDFUNC

	FUNCTION CloseRemoteTable
		LPARAMETERS tcAlias
		LOCAL loCursorAdapter, loException AS Exception

		loCursorAdapter = .NULL.
		TRY
			loCursorAdapter = GETCURSORADAPTER(tcAlias)
		CATCH TO loException
		ENDTRY
		IF NOT ISNULL(loCursorAdapter)
			loCursorAdapter.DClose()
		ENDIF
	ENDFUNC

	FUNCTION SqlQueryRemote
		LPARAMETERS tcTables, tcAliases, tcSql, tcCursor
		LOCAL lcSql, loDatabaseProp, llSuccess, lcSqlFunc

		IF "INTO CURSOR" $ tcSql
			lcSql = STREXTRACT(tcSql,"","INTO CURSOR",1,2)
			tcCursor = GETWORDNUM(STREXTRACT(tcSql,"INTO CURSOR",""),1)
		ELSE
			lcSql = tcSql
		ENDIF
		lcSql = this.RemovePrefix(tcTables, tcAliases, lcSql)

		lcSqlFunc = "SqlParse"	&& External function
		lcSql = &lcSqlFunc(lcSql)

		loDatabaseProp = goDatabases.Item(this.cRemoteDatabase)
		lcSqlFunc = "SqlRemote"	&& External function
		&lcSqlFunc("SQLCURSOR", lcSql, tcCursor, loDatabaseProp,,@llSuccess)
		CFCursorNullsRemove(.T.,tcCursor,.T.)

		RETURN llSuccess
	ENDFUNC

	PROCEDURE CloseTable
		LPARAMETERS tcAlias
		LOCAL lnTableNo, lcTables, lcTablesCount

		this.ResetError()
		this.SetDatasession()

		lcTables = IIF(TYPE("paTables",1) = "A", "paTables", "this.aTablePool")
		lcTablesCount = IIF(TYPE("paTables",1) = "A", "pnTablesCount", "this.nTableCount")
		lnTableNo = ASCAN(&lcTables, ALLTRIM(LOWER(tcAlias)), 1, 0, 1, 14)

		IF lnTableNo > 0
			IF USED(tcAlias)
				CommitChanges(tcAlias)
				DO CASE
					CASE this.lRemote
						this.CloseRemoteTable(tcAlias)
					OTHERWISE
						USE IN &tcAlias
				ENDCASE
			ENDIF
			ADEL(&lcTables, lnTableNo)
			&lcTablesCount = MAX(0, &lcTablesCount - 1)
			IF &lcTablesCount > 0
				DIMENSION &lcTables(&lcTablesCount, 2)
			ENDIF
		ENDIF
	ENDPROC
ENDDEFINE
*
*	FUNCTION WellnessFrontOfficeExists
*		LPARAMETERS toWellnessFrontOffice

*		IF TYPE("g_oWellnessFrontOffice") = "O" AND NOT ISNULL(g_oWellnessFrontOffice)
*			toWellnessFrontOffice = g_oWellnessFrontOffice.Get(SET("Datasession"))
*		ELSE
*			toWellnessFrontOffice = .NULL.
*		ENDIF

*		RETURN NOT ISNULL(toWellnessFrontOffice)
*	ENDFUNC
*	*
*	FUNCTION PrepareWellnessFrontOffice
*		LPARAMETERS tcPathToWellnessFrontOffice, tlAliasSameAsTable, tcErrorHnd
*		LOCAL loWellnessFrontOffice
*		PUBLIC g_oWellnessFrontOffice

*		IF TYPE("g_oWellnessFrontOffice") <> "O" OR ISNULL(g_oWellnessFrontOffice)
*			g_oWellnessFrontOffice = CREATEOBJECT("FrontOfficeCollection", "WellnessFrontOffice", tcPathToWellnessFrontOffice)
*		ENDIF
*		IF NOT WellnessFrontOfficeExists()
*			g_oWellnessFrontOffice.Set(SET("Datasession"), tcErrorHnd)
*		ENDIF
*		IF WellnessFrontOfficeExists(@loWellnessFrontOffice)
*			loWellnessFrontOffice.lAliasSameAsTable = tlAliasSameAsTable
*		ENDIF
*		RETURN WellnessFrontOfficeExists()
*	ENDFUNC
*	*
*	FUNCTION RemoveWellnessFrontOffice
*		IF WellnessFrontOfficeExists()
*			g_oWellnessFrontOffice.Close(SET("Datasession"))
*		ENDIF
*	ENDFUNC
*	*
*	DEFINE CLASS FrontOfficeCollection AS Collection
*		PROTECTED cClass
*		PROTECTED cPath

*		cClass = ""
*		cPath = ""

*		PROCEDURE Init
*			LPARAMETERS tcClass, tcPath

*			this.cClass = tcClass
*			this.cPath = ADDBS(ALLTRIM(tcPath))
*		ENDPROC

*		PROTECTED PROCEDURE Destroy
*			LOCAL loFrontOffice

*			FOR EACH loFrontOffice IN this
*				loFrontOffice.Release()
*			NEXT
*			this.Remove(-1)
*		ENDPROC

*		PROCEDURE Close
*			LPARAMETERS tnDataSessionId
*			LOCAL loFrontOffice, lcKey

*			lcKey = TRANSFORM(tnDataSessionId)
*			IF this.GetKey(lcKey) > 0
*				loFrontOffice = this.Item(lcKey)
*				this.Remove(lcKey)
*				loFrontOffice.Release()
*			ENDIF
*		ENDPROC

*		FUNCTION Get
*			LPARAMETERS tnDataSessionId
*			LOCAL loFrontOffice, lcKey

*			lcKey = TRANSFORM(tnDataSessionId)
*			IF this.GetKey(lcKey) = 0
*				loFrontOffice = .NULL.
*			ELSE
*				loFrontOffice = this.Item(lcKey)
*			ENDIF

*			RETURN loFrontOffice
*		ENDFUNC

*		FUNCTION Set
*			LPARAMETERS tnDataSessionId, tcErrorHnd
*			LOCAL loFrontOffice, lcKey

*			lcKey = TRANSFORM(tnDataSessionId)
*			IF this.GetKey(lcKey) = 0
*				loFrontOffice = CREATEOBJECT(this.cClass, this.cPath, tcErrorHnd)
*				this.Add(loFrontOffice, lcKey)
*			ELSE
*				loFrontOffice = this.Item(lcKey)
*			ENDIF

*			RETURN loFrontOffice
*		ENDFUNC
*	ENDDEFINE
*	*