#DEFINE ARCHIVED_DELETED	"histres ", "hresext ", "histpost", "hpostcng"

LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, ;
	lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13, lp_uParam14, lp_uParam15, lp_uParam16, lp_uParam17, lp_uParam18, lp_uParam19
LOCAL l_cCallProc, l_nParamNo, l_uRetVal

l_cCallProc = lp_cFuncName + "("
FOR l_nParamNo = 1 TO PCOUNT()-1
	l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
NEXT
l_cCallProc = l_cCallProc + ")"
l_uRetVal = &l_cCallProc

RETURN l_uRetVal
ENDFUNC
*
PROCEDURE Archive
DoForm("archive", "forms\archive", "NAME poArchiveFrm LINKED")
ENDPROC
*
PROCEDURE DoArchive
LOCAL l_oSession, l_tStartTime, l_lSuccess

DO CASE
	CASE NOT EMPTY(_screen.oGlobal.oParam2.pa_arhdate)
		LogArchive(GetLangText("ARCHIVE","TA_ALREADY_ARCHIVED"))
		Alert(GetLangText("ARCHIVE","TA_ALREADY_ARCHIVED"))	&&History tables already archived!
	CASE NOT FILE("pgdbf.exe")
		LogArchive(StrFmt(GetLangText("COMMON","TA_FILENOTFOUND"),"pgdbf.exe"))
		Alert(StrFmt(GetLangText("COMMON","TA_FILENOTFOUND"),"pgdbf.exe"))	&&History tables already archived!
	CASE YesNo(GetLangText("ADPURGE","TA_AREYOUSURE")+"@2")
		l_tStartTime = SECONDS()
		DO SetMessagesOff IN procmessages
		l_oSession = CREATEOBJECT("PrivateSession")
		l_lSuccess = l_oSession.CallProc("DoFullArchive()")
		DO SetMessagesOn IN procmessages
		IF l_lSuccess
			MsgBox(Str2Msg(GetLangText("ARCHIVE","TXT_ARCHIVED_TO_POSTGRESQL"), "%s", Sec2Time(SECONDS() - l_tStartTime)),"",64)
		ELSE
			LogArchive(GetLangText("ARCHIVE","TA_NO_CONNECTION"))
			Alert(GetLangText("ARCHIVE","TA_NO_CONNECTION"))		&&Check ODBC connection!
		ENDIF
	OTHERWISE
ENDCASE
ENDPROC
*
PROCEDURE DoRestore
LOCAL l_oSession, l_tStartTime, l_lSuccess

DO CASE
	CASE EMPTY(_screen.oGlobal.oParam2.pa_arhdate)
		LogArchive(GetLangText("ARCHIVE","TA_NOT_ARCHIVED_YET"))
		Alert(GetLangText("ARCHIVE","TA_NOT_ARCHIVED_YET"))	&&History tables already archived!
	CASE YesNo(GetLangText("ADPURGE","TA_AREYOUSURE")+"@2")
		l_tStartTime = SECONDS()
		DO SetMessagesOff IN procmessages
		l_oSession = CREATEOBJECT("PrivateSession")
		l_lSuccess = l_oSession.CallProc("RestoreFullArchive()")
		DO SetMessagesOn IN procmessages
		IF l_lSuccess
			MsgBox(Str2Msg(GetLangText("ARCHIVE","TXT_ARCHIVE_RESTORED"), "%s", Sec2Time(SECONDS() - l_tStartTime)),"",64)
		ELSE
			LogArchive(GetLangText("ARCHIVE","TXT_ARCHIVE_NOT_RESTORED"))
			Alert(GetLangText("ARCHIVE","TXT_ARCHIVE_NOT_RESTORED"))
		ENDIF
	OTHERWISE
ENDCASE
ENDPROC
*
PROCEDURE DoFullArchive
* No need for creating database, and ODBC DSN is not required.
*
* In citadel.ini in system section must be set:
* ODBCSERVER=192.168.1.4	or (localhost)
* ODBCPORT=5432				; for PostgreSQL default port is 5432
* ODBCDRIVERNAME=PostgreSQL Unicode
*
* If ODBCDATABASE is not specified than name of database would be 'citadel'.
*
* Errors are logged in archive_log.txt
*
LOCAL l_oArc AS cArchive, l_lEmptyTables, l_lNoRemoveDuplicates, l_lSuccess
PRIVATE plTemporalOdbcForArchiving

l_lSuccess = .F.

IF NOT PrepareArchive(.T.)
	RETURN l_lSuccess
ENDIF
_screen.oGlobal.oArchive.ServerConnect(.T.)
_screen.oGlobal.oArchive.CreateDatabase()
_screen.oGlobal.oArchive.ServerConnect()
_screen.oGlobal.oArchive.CreateSchema()
_screen.oGlobal.oArchive.SetSession(SET("Datasession"))
_screen.oGlobal.oArchive.CreateTables()
plTemporalOdbcForArchiving = .T.
DO DBCheckStructureOdbcTableIndexes IN DbUpdate
DO DBCheckStructureOdbcSource IN DbUpdate
plTemporalOdbcForArchiving = .F.
_screen.oGlobal.oArchive.Disconnect()

l_lEmptyTables = .F.
l_lNoRemoveDuplicates = .F.
l_lSuccess = _screen.oGlobal.oArchive.ImportTables(l_lEmptyTables, l_lNoRemoveDuplicates)
IF l_lSuccess
	DeleteHistory()
ENDIF
_screen.oGlobal.oArchive.SetSession()

RETURN l_lSuccess
ENDPROC
*
PROCEDURE RestoreFullArchive
LOCAL l_lSuccess

LogArchive("Drop database on PostgreSQL...")
IF NOT PrepareArchive()
	RETURN .F.
ENDIF
_screen.oGlobal.oArchive.SetSession(SET("Datasession"))
l_lSuccess = _screen.oGlobal.oArchive.RecallHistory()
IF l_lSuccess
	l_lSuccess = _screen.oGlobal.oArchive.DropDatabase(LOWER(_screen.oGlobal.cODBCDatabase))
ENDIF
_screen.oGlobal.oArchive.Disconnect()
IF l_lSuccess
	SetArchiveDate()
ENDIF
_screen.oGlobal.oArchive.SetSession()
LogArchive(IIF(l_lSuccess, "Finished.", "NOT completed."))

RETURN l_lSuccess
ENDPROC
*
PROCEDURE CheckStructure
IF PrepareArchive()
	_screen.oGlobal.oArchive.ConnectToDatabase()
	IF _screen.oGlobal.oArchive.nHandle > 0
		PRIVATE plTemporalOdbcForArchiving

		plTemporalOdbcForArchiving = .T.
		DO DBCheckStructureOdbc IN DbUpdate
		DO DBCheckStructureOdbcTableIndexes IN DbUpdate
		plTemporalOdbcForArchiving = .F.
	ENDIF
	_screen.oGlobal.oArchive.Disconnect()
ENDIF
ENDPROC
*
PROCEDURE PrepareArchive
LPARAMETERS lp_lDontConnectToDatabase
LOCAL l_lPrepared

IF _screen.oGlobal.lArchive
	IF VARTYPE(_screen.oGlobal.oArchive) <> "O"
		_screen.oGlobal.oArchive = .NULL.
		_screen.oGlobal.oArchive = CREATEOBJECT("cArchive")
	ENDIF
	l_lPrepared = (VARTYPE(_screen.oGlobal.oArchive) = "O")
	IF l_lPrepared AND NOT lp_lDontConnectToDatabase AND _screen.oGlobal.oArchive.nHandle < 1
		_screen.oGlobal.oArchive.ConnectToDatabase()
	ENDIF
ENDIF

RETURN l_lPrepared
ENDPROC
*
PROCEDURE SetArchiveDate
LPARAMETERS tdDate
LOCAL l_oLogger

l_oLogger = CREATEOBJECT("ProcLogger")
l_oLogger.cKeyExp = "pa_paid"
l_oLogger.SetOldVal("param2")
REPLACE pa_arhdate WITH EVL(tdDate,{}) IN param2
l_oLogger.SetNewVal()
l_oLogger.Save()
_screen.oGlobal.RefreshTableParam2()
ENDPROC
*
PROCEDURE ArchivePost
LPARAMETERS lp_lArchived, lp_nPostId

IF PrepareArchive()
	lp_lArchived = _screen.oGlobal.oArchive.ArchivePost(lp_nPostId)
	RETURN .T.
ENDIF
RETURN .F.
ENDPROC
*
PROCEDURE ArchiveReservation
LPARAMETERS lp_lArchived, lp_nReserId, lp_nRsId

IF PrepareArchive()
	lp_lArchived = _screen.oGlobal.oArchive.ArchiveReservation(lp_nReserId, lp_nRsId)
	RETURN .T.
ENDIF
RETURN .F.
ENDPROC
*
PROCEDURE ArchiveBillnum
LPARAMETERS lp_lArchived

IF PrepareArchive()
	lp_lArchived = _screen.oGlobal.oArchive.ArchiveBillnum()
	RETURN .T.
ENDIF
RETURN .F.
ENDPROC
*
PROCEDURE DeleteHistory
LOCAL l_cTable, l_dArchiveDate, l_tStartTime, l_nRecords

LogArchive("Delete history...")
l_dArchiveDate = DATE(YEAR(SysDate())-_screen.oGlobal.nHoldHistResYears, 1, 1)
SetArchiveDate(l_dArchiveDate)

SELECT *, CAST(ICASE(fi_alias = "histres ", -3, fi_alias = "histpost", -2, fi_alias = "hyioffer", -1, RECNO()) AS I) AS ord ;
	FROM files ;
	WHERE UPPER(fi_name) = UPPER(fi_alias) AND ("A" $ fi_flag) AND NOT fi_vfp AND fi_path = "DATA\" AND INLIST(LOWER(fi_name), ARCHIVED_DELETED) ;
	ORDER BY ord ;
	INTO CURSOR curFiles	&& Delete records fro histres and histpost first because of relation.
SCAN
	l_tStartTime = SECONDS()
	l_cTable = ALLTRIM(LOWER(fi_name))
	OpenFileDirect(,l_cTable)
	LogArchive("Table: " + l_cTable + ";  Records: ...", .T.)
	l_nRecords = 0
	DO CASE
		CASE l_cTable = "histres"
			DELETE FOR hr_depdate < l_dArchiveDate AND hr_reserid > 1 IN histres
			l_nRecords = _tally
		CASE l_cTable = "hresext"
			DELETE FROM hresext WHERE !EXISTS(SELECT 'x' FROM histres WHERE hr_rsid = rs_rsid)
			l_nRecords = _tally
		CASE l_cTable = "histpost"
			DELETE FROM histpost WHERE hp_date < l_dArchiveDate AND (hp_reserid < 1 OR !EXISTS(SELECT 'x' FROM histres WHERE hr_reserid = hp_reserid))
			l_nRecords = _tally
		CASE l_cTable = "hpostcng"
			DELETE FROM hpostcng WHERE !EXISTS(SELECT 'x' FROM histpost WHERE hp_postid = ph_postid)
			l_nRecords = _tally
		OTHERWISE
	ENDCASE
	LogArchive(TRANSFORM(l_nRecords) + ";  Duration: " + TRANSFORM(SECONDS()-l_tStartTime) + " seconds.")
ENDSCAN
USE IN curFiles
ENDPROC
*
PROCEDURE PackArchived
LOCAL i, l_cAlias, l_lSuccess, l_oExepction, l_cErrorText, l_tStartTime

SELECT files
SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND ("A" $ fi_flag) AND NOT fi_vfp AND fi_path = "DATA\" AND INLIST(LOWER(fi_name), ARCHIVED_DELETED)
	l_tStartTime = SECONDS()
	l_cAlias = UPPER(ALLTRIM(fi_alias))
	LogArchive("Packing a table: " + l_cAlias + "...", .T.)
	FOR i = 1 TO 3
		IF OpenFile(.T.,l_cAlias)
			EXIT
		ENDIF
	NEXT
	IF USED(l_cAlias) AND ISEXCLUSIVE(l_cAlias)
		l_lSuccess = .T.
		SELECT (l_cAlias)
		TRY
			PACK
		CATCH TO l_oExepction
			l_lSuccess = .F.
			ASSERT .F. MESSAGE PROGRAM()
		ENDTRY
		IF NOT l_lSuccess
			TEXT TO l_cErrorText TEXTMERGE NOSHOW PRETEXT 3
				<<TRANSFORM(DATETIME())>> Archive - PACK command error
				-------------------------------------
				<<l_cAlias>>
				-------------------------------------
				ErrorNo:<<TRANSFORM(l_oExepction.ErrorNo)>>
				Message:<<TRANSFORM(l_oExepction.Message)>>
				Procedure:<<TRANSFORM(l_oExepction.Procedure)>>
				LineNo:<<TRANSFORM(l_oExepction.LineNo)>>
				LineContents:<<TRANSFORM(l_oExepction.LineContents)>>
				Details:<<TRANSFORM(l_oExepction.Details)>>
			ENDTEXT
			LogData(l_cErrorText, "hotel.err")
			SELECT (l_cAlias)
			USE
			Alert(l_cErrorText)
		ENDIF
	ENDIF
	OpenFile(,l_cAlias)
	IF l_lSuccess
		LogArchive(";  Duration: " + TRANSFORM(SECONDS()-l_tStartTime) + " seconds.")
	ENDIF
ENDSCAN
WAIT CLEAR
ENDPROC
*
PROCEDURE RestoreArchive
LPARAMETERS lp_cTables, lp_cWheres, lp_dFrom, lp_lSilent, lp_lStayConnected, lp_lTempPgTable
LOCAL i, l_cTable, l_cWhere, l_cFiles, l_cFile

IF PrepareArchive()
	IF EMPTY(lp_dFrom) OR lp_dFrom < _screen.oGlobal.oParam2.pa_arhdate &&AND (lp_lSilent OR YesNo(GetLangText("ARCHIVE","TXT_ALREADY_ARCHIVED")))
		IF NOT lp_lSilent
			WAIT WINDOW NOWAIT GetLangText("ARCHIVE","TXT_RESTORE_ARCHIVE")
		ENDIF
		l_cFiles = ""
		FOR i = 1 TO GETWORDCOUNT(lp_cTables,',')
			l_cTable = GETWORDNUM(lp_cTables,i,',')
			IF USED(l_cTable)
				l_cFile = DBF(l_cTable)
				IF NOT (l_cTable == LOWER(JUSTSTEM(l_cFile)))
					DClose(l_cTable)
					FileDelete(FORCEEXT(l_cFile,'DBF'))
					FileDelete(FORCEEXT(l_cFile,'CDX'))
					FileDelete(FORCEEXT(l_cFile,'FPT'))
				ENDIF
			ENDIF
			l_cWhere = SqlParseB(GETWORDNUM(lp_cWheres,i,';'))
			l_cFiles = l_cFiles + IIF(EMPTY(l_cFiles), "", ",") + _screen.oGlobal.oArchive.RestoreFromArchive(l_cTable, l_cWhere, lp_lTempPgTable)
		NEXT
		FOR i = 1 TO GETWORDCOUNT(lp_cTables,',')
			l_cTable = GETWORDNUM(lp_cTables,i,',')
			l_cFile = GETWORDNUM(l_cFiles,i,',')
			IF NOT EMPTY(l_cFile)
				DClose(l_cTable)
				USE (l_cFile) IN 0 ALIAS (l_cTable) SHARED
			ENDIF
		NEXT
		IF NOT lp_lSilent
			WAIT CLEAR
		ENDIF
	ENDIF
	IF NOT lp_lStayConnected
		_screen.oGlobal.oArchive.Disconnect()
	ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE DeleteTempArchive
LPARAMETERS lp_cTables
LOCAL i, l_cTable, l_cFile

FOR i = 1 TO GETWORDCOUNT(lp_cTables,',')
	l_cTable = GETWORDNUM(lp_cTables,i,',')
	IF USED(l_cTable)
		l_cFile = DBF(l_cTable)
		IF NOT (l_cTable == LOWER(JUSTSTEM(l_cFile)))
			DClose(l_cTable)
			FileDelete(FORCEEXT(l_cFile,'DBF'))
			FileDelete(FORCEEXT(l_cFile,'CDX'))
			FileDelete(FORCEEXT(l_cFile,'FPT'))
			OpenFileDirect(,l_cTable)
		ENDIF
	ENDIF
NEXT
IF _screen.oGlobal.lArchive AND VARTYPE(_screen.oGlobal.oArchive) = "O"
	_screen.oGlobal.oArchive.Disconnect()
ENDIF
ENDPROC
*
PROCEDURE LogArchive
LPARAMETERS tcNewText, tlNoCrlf

WAIT tcNewText WINDOW NOWAIT
IF TYPE("poArchiveFrm") = "O"
	poArchiveFrm.Log(tcNewText, tlNoCrlf)
ENDIF
ENDPROC
*
DEFINE CLASS cArchive AS Custom

#IF .F. && Make sure this is false, otherwise error
   *-- Define This for IntelliSense use
   LOCAL This AS cArchive OF ProcArchive.prg
#ENDIF

DIMENSION aCrcTempDbfs(1)
cPass = ""
cSchema = ""
oTables = .NULL.
cScript = ""
nHandle = 0
nDataSession = 0
cDataDir = ""
cConnectString = ""
*
PROCEDURE Init
SYS(987,.T.)
this.cPass = EVL(ReadINI(FULLPATH(_screen.oGlobal.cHotelDir+"citadel.ini"),[System],[ODBCPWD]), 'zimnicA$2001')
this.cSchema = "desk" + IIF(TYPE("gcHotCode") <> "C" OR EMPTY(gcHotCode), "", "_" + LOWER(gcHotCode))
this.cDataDir = ADDBS(FULLPATH(gcDatadir))
this.nDataSession = SET("Datasession")

this.ServerConnect(.T.)		&& Just connect to the server for creating a database.

IF this.nHandle < 1
	RETURN .F.
ENDIF
ENDPROC
*
PROCEDURE Destroy
SQLDISCONNECT(0)
ENDPROC
*
PROCEDURE Disconnect
IF this.nHandle > 0
	SQLDISCONNECT(this.nHandle)
	this.nHandle = 0
ENDIF
ENDPROC
*
PROCEDURE SetSession
LPARAMETERS tnDataSession

IF PCOUNT() = 0
	SET DATASESSION TO this.nDataSession
ELSE
	IF SET("Datasession") <> tnDataSession
		SET DATASESSION TO tnDataSession
	ENDIF
	IF NOT USED("files")
		USE (this.cDataDir+"files") SHARED IN 0
	ENDIF
	IF NOT USED("fields")
		USE (this.cDataDir+"fields") SHARED IN 0
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE ConnectToDatabase
this.ServerConnect()		&& Connect to the specified database after its creation.

IF this.nHandle > 0
	this.cScript = "SET search_path TO " + this.cSchema + ", pg_catalog;"
	this.ExecSql()
ENDIF
ENDPROC
*
PROCEDURE ServerConnect
LPARAMETERS lp_lNoDatabase
LOCAL l_cConnString

SQLDISCONNECT(0)

TEXT TO l_cConnString TEXTMERGE NOSHOW PRETEXT 15
Driver={<<_screen.oGlobal.cODBCDriverName>>};
Uid=postgres;Pwd=<<this.cPass>>;DATABASE=<<IIF(lp_lNoDatabase,'postgres',_screen.oGlobal.cODBCDatabase)>>;
SERVER=<<_screen.oGlobal.cODBCServer>>;PORT=<<_screen.oGlobal.cODBCPort>>;
CA=d;A6=;A7=100;A8=4096;B0=255;B1=8190;BI=2;C2=dd_;;CX=1b102bb;A1=7.4-1
ENDTEXT

this.nHandle = SQLSTRINGCONNECT(l_cConnString)

RETURN .T.
ENDPROC
*
PROCEDURE CreateDatabase
this.cScript = "SELECT datname FROM pg_catalog.pg_database WHERE datname = '"+LOWER(_screen.oGlobal.cODBCDatabase)+"';"
this.ExecSql("curdatabase")
IF RECCOUNT() = 0
	WAIT CLEAR
	LogArchive("Creating curdatabase: " + _screen.oGlobal.cODBCDatabase)
	TEXT TO this.cScript TEXTMERGE NOSHOW PRETEXT 15
	CREATE DATABASE "<<_screen.oGlobal.cODBCDatabase>>"
		WITH 
		OWNER = postgres
		TEMPLATE = template0
		ENCODING = 'UTF8'
		LC_COLLATE = 'C'
		LC_CTYPE = 'C'
		TABLESPACE = pg_default
		CONNECTION LIMIT = -1;
	ENDTEXT
	this.ExecSql()
ENDIF
USE IN curdatabase

RETURN .T.
ENDPROC
*
PROCEDURE RecallHistory
LOCAL l_cTable, l_cArcTable, l_tStartTime

LogArchive("Move from archive to history tables...")
SELECT files
SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND ("A" $ fi_flag) AND NOT fi_vfp AND fi_path = "DATA\" AND INLIST(LOWER(fi_name), ARCHIVED_DELETED)
	l_tStartTime = SECONDS()
	l_cTable = ALLTRIM(LOWER(fi_name))
	l_cArcTable = "arc" + ALLTRIM(LOWER(fi_name))
	* Select all data from archive
	LogArchive("Select data from table: " + l_cTable + ";  Records: ...", .T.)
	this.cScript = [SELECT * FROM "] + l_cTable + [";]
	this.ExecSql(l_cArcTable)
	LogArchive(TRANSFORM(RECCOUNT(l_cArcTable)) + ";  Duration: " + TRANSFORM(SECONDS()-l_tStartTime) + " seconds.")
	SELECT files
ENDSCAN

SELECT files
SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND ("A" $ fi_flag) AND NOT fi_vfp AND fi_path = "DATA\" AND INLIST(LOWER(fi_name), ARCHIVED_DELETED)
	l_tStartTime = SECONDS()
	l_cTable = ALLTRIM(LOWER(fi_name))
	l_cArcTable = "arc" + ALLTRIM(LOWER(fi_name))
	OpenFileDirect(,l_cTable)
	* Move from archive cursor to history tables...
	SELECT &l_cTable
	LogArchive("Move data to table: " + l_cTable + ";  Records: ...", .T.)
	APPEND FROM DBF(l_cArcTable)
	LogArchive(TRANSFORM(_tally) + ";  Duration: " + TRANSFORM(SECONDS()-l_tStartTime) + " seconds.")
	USE IN &l_cArcTable
	SELECT files
ENDSCAN

RETURN .T.
ENDPROC
*
PROCEDURE RestoreFromArchive
LPARAMETERS lp_cTable, lp_cSql, lp_lTempPgTable
LOCAL ARRAY l_aIndexes(1)
LOCAL i, l_nCount, l_cAlias, l_cFile, l_lDo, l_cScript, l_cIdJoin, l_cOrderBy

STORE "" TO l_cScript, l_cIdJoin, l_cOrderBy
IF lp_lTempPgTable
	DO CASE
		CASE lp_cTable = "histres"
			l_cScript = [DROP TABLE IF EXISTS curHr2019; SELECT hr_rsid AS c_id, ROW_NUMBER() OVER (ORDER BY hr_rsid) AS c_rn INTO TEMP curHr2019 FROM histres; ALTER TABLE curHr2019 ADD PRIMARY KEY (c_rn) DEFERRABLE;]
			l_cIdJoin = [ INNER JOIN curHr2019 ON hr_rsid = c_id]
		CASE lp_cTable = "hresext"
			l_cScript = [DROP TABLE IF EXISTS curRs2019; SELECT rs_rsid AS c_id, ROW_NUMBER() OVER (ORDER BY rs_rsid) AS c_rn INTO TEMP curRs2019 FROM hresext; ALTER TABLE curRs2019 ADD PRIMARY KEY (c_rn) DEFERRABLE;]
			l_cIdJoin = [ INNER JOIN curRs2019 ON rs_rsid = c_id]
		CASE lp_cTable = "histpost"
			l_cScript = [DROP TABLE IF EXISTS curHp2019; SELECT hp_postid AS c_id, ROW_NUMBER() OVER (ORDER BY hp_postid) AS c_rn INTO TEMP curHp2019 FROM histpost; ALTER TABLE curHp2019 ADD PRIMARY KEY (c_rn) DEFERRABLE;]
			l_cIdJoin = [ INNER JOIN curHp2019 ON hp_postid = c_id]
		CASE lp_cTable = "hpostcng"
			l_cScript = [DROP TABLE IF EXISTS curPh2019; SELECT ph_postid AS c_postid, ph_time AS c_time, ph_user AS c_user, ph_field AS c_field, ph_action AS c_action, ] + ;
				[ROW_NUMBER() OVER (ORDER BY ph_postid, ph_time, ph_user, ph_field, ph_action) AS c_rn INTO TEMP curPh2019 FROM hpostcng; ALTER TABLE curPh2019 ADD PRIMARY KEY (c_rn) DEFERRABLE;]
			l_cIdJoin = [ INNER JOIN curPh2019 ON ph_postid = c_postid AND ph_time = c_time AND ph_user = c_user AND ph_field = c_field AND ph_action = c_action]
		OTHERWISE
	ENDCASE
	IF NOT EMPTY(l_cScript)
		this.cScript = l_cScript
		this.ExecSql()
	ENDIF
ELSE
	DO CASE
		CASE lp_cTable = "histres"
			l_cOrderBy = [hr_rsid]
		CASE lp_cTable = "hresext"
			l_cOrderBy = [rs_rsid]
		CASE lp_cTable = "histpost"
			l_cOrderBy = [hp_postid]
		CASE lp_cTable = "hpostcng"
			l_cOrderBy = [ph_postid, ph_time, ph_user, ph_field, ph_action]
		OTHERWISE
	ENDCASE
ENDIF

* Select all data from archive
i = 0
l_nCount = 100000		&& For paged result order by PK have to be set.
l_cAlias = SYS(2015)
l_lDo = .T.
DO WHILE l_lDo
	l_lDo = .F.
	this.cScript = EVL(lp_cSql,"") + IIF(EMPTY(l_cIdJoin), [ ORDER BY ] + l_cOrderBy + [ LIMIT ] + TRANSFORM(l_nCount) + [ OFFSET ] + TRANSFORM(i*l_nCount), ;
												l_cIdJoin + [ WHERE c_rn BETWEEN ] + TRANSFORM(i*l_nCount+1) + [ AND ] + TRANSFORM((i+1)*l_nCount)) + [;]
	this.ExecSql("curData",IIF(lp_cTable="histpost",6,.F.))
	IF USED("curData")
		l_lDo = (RECCOUNT("curData") = l_nCount)
		IF i = 0
			l_cFile = FileTemp("dbf",.T.)
			SELECT curData
			COPY TO (l_cFile)
			USE (l_cFile) IN 0 ALIAS (l_cAlias) EXCLUSIVE
			SetIndexes(lp_cTable, l_cAlias,,,@l_aIndexes)
		ELSE
			SELECT (l_cAlias)
			APPEND FROM DBF("curData")
		ENDIF
		DClose("curData")
	ENDIF
	i = i + 1
ENDDO

DClose(l_cAlias)

RETURN l_cFile
ENDPROC
*
PROCEDURE DropDatabase
LPARAMETERS tcDatabase
LOCAL l_lSuccess

this.ServerConnect(.T.)
this.cScript = 'DROP DATABASE IF EXISTS "' + tcDatabase + '";'
this.ExecSql()
this.cScript = "SELECT datname FROM pg_catalog.pg_database WHERE datname = '" + tcDatabase + "';"
this.ExecSql("curdatabase")
l_lSuccess = (RECCOUNT() = 0)
USE IN curdatabase

RETURN l_lSuccess
ENDPROC
*
PROCEDURE CreateSchema
this.cScript = "SELECT schema_name FROM Information_Schema.Schemata WHERE schema_name = '"+LOWER(this.cSchema)+"';"
this.ExecSql("curschema")
IF RECCOUNT() = 0
	LogArchive("Creating schema: " + this.cSchema)
	this.cScript = "CREATE SCHEMA " + this.cSchema + ";"
	this.ExecSql()
ENDIF
this.cScript = "SET search_path TO " + this.cSchema + ", pg_catalog;"
this.ExecSql()
USE IN curschema

RETURN .T.
ENDPROC
*
PROCEDURE CreateTables
this.cScript = [SELECT * FROM pg_tables WHERE schemaname = '] + LOWER(this.cSchema) + [';]
this.ExecSql("curTables")

SELECT files
SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND ("A" $ fi_flag) AND NOT fi_vfp AND fi_path = "DATA\"
	LogArchive("Creating a table: " + ALLTRIM(fi_name))
	this.CreateTable()
ENDSCAN
USE IN curTables
ENDPROC
*
PROCEDURE CreateTable
LOCAL l_nSelect, l_cFields, l_cPrimaryKey, l_cType, l_cDefault

l_nSelect = SELECT()

SELECT curTables
LOCATE FOR tablename = LOWER(files.fi_name)
IF NOT FOUND()
	STORE "" TO l_cFields, l_cPrimaryKey
	SELECT fields
	SCAN FOR UPPER(fd_table+fd_name) = UPPER(files.fi_name)
		DO DBCheckStructureOdbcConvertVfpToOdbc IN DbUpdate WITH l_cType, l_cDefault,,"fields"
		l_cFields = l_cFields + IIF(EMPTY(l_cFields), [], [, ]) + ALLTRIM(LOWER(fd_name)) + [ ] + l_cType + [ DEFAULT ] + l_cDefault + [ NOT NULL]
	ENDSCAN
	l_cFields = l_cFields + this.ChecksumField(files.fi_name,.T.)
	IF NOT EMPTY(files.fi_unikey)
		l_cPrimaryKey = [, PRIMARY KEY (] + ALLTRIM(LOWER(files.fi_unikey)) + [) DEFERRABLE]
	ENDIF
	TEXT TO this.cScript TEXTMERGE NOSHOW PRETEXT 15
	CREATE TABLE IF NOT EXISTS "<<ALLTRIM(LOWER(files.fi_name))>>" (<<l_cFields>><<l_cPrimaryKey>>);
	ENDTEXT
	this.ExecSql()
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE ImportTables
LPARAMETERS lp_lEmptyTable, lp_lNoRemoveDuplicates
LOCAL i, l_oShell, l_cCommand, l_cFields, l_lShow, l_cPsqlScript, l_tStartTime, l_cTable, l_cDbf, l_cPSQLLog, l_cPSQLLogPath, l_nCodePage, l_lSuccess

LogArchive(GetLangText("ARCHIVE","TA_DATA_INTO_SERVER"))
l_cPsqlScript = SYS(2015)+".sql"
l_nCodePage = 1250	&&CPCURRENT()
SET TEXTMERGE ON
SET TEXTMERGE TO (l_cPsqlScript) NOSHOW
\SET standard_conforming_strings = off;
\SET client_min_messages = warning;
\SET escape_string_warning = off;
\SET search_path TO <<this.cSchema>>, pg_catalog;
\BEGIN TRANSACTION;
*Disable all constraints for PK validation
\SET CONSTRAINTS ALL DEFERRED;
SELECT files
SET FILTER TO
SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND ("A" $ fi_flag) AND NOT fi_vfp AND fi_path = "DATA\"
	* Code page check
	l_cTable = LOWER(ALLTRIM(fi_name))
	LogArchive("Table: " + l_cTable)
	l_cDbf = LOWER(FORCEEXT(this.cDataDir+l_cTable,"dbf"))
	this.ChecksumTable(l_cTable, @l_cDbf)
	CheckCodePage(l_cDbf, l_nCodePage)
	USE (l_cDbf) IN 0 AGAIN ALIAS (l_cTable) SHARED
	l_cFields = ""
	FOR i = 1 TO FCOUNT(l_cTable)
		l_cFields = l_cFields + IIF(EMPTY(l_cFields), "", ",") + FIELD(i,l_cTable)
	NEXT
	*WAIT "Importing data into table: " + ALLTRIM(fi_name) + "..." WINDOW NOWAIT
	\ALTER TABLE "<<l_cTable>>" DISABLE TRIGGER ALL;
	\ \COPY "<<l_cTable>>" (<<LOWER(l_cFields)>>) FROM PROGRAM '<<LOWER(FULLPATH("pgdbf.exe"))>> <<l_cDbf>>' ENCODING 'WIN<<TRANSFORM(l_nCodePage)>>';
	IF NOT lp_lNoRemoveDuplicates AND NOT EMPTY(fi_unikey)
		\SELECT pl_remove_duplicates('<<l_cTable>>','{<<ALLTRIM(LOWER(fi_unikey))>>}');
	ENDIF
	\ALTER TABLE "<<l_cTable>>" ENABLE TRIGGER ALL;
	IF RECCOUNT(l_cTable) = 0
		APPEND BLANK IN (l_cTable)
	ENDIF
	USE IN (l_cTable)
ENDSCAN
*Enable all constraints for PK validation
\SET CONSTRAINTS ALL IMMEDIATE;
\COMMIT;
SET TEXTMERGE TO
SET TEXTMERGE OFF

l_lShow = .T.
l_cCommand = TEXTMERGE([psql -h <<_screen.oGlobal.cODBCServer>> -p <<_screen.oGlobal.cODBCPort>> -d <<_screen.oGlobal.cODBCDatabase>> -U postgres -w -f <<l_cPsqlScript>>])
l_cCommand = l_cCommand + [ 1>>psql.log 2>>&1]
STRTOFILE("@SET PGPASSWORD=" + this.cPass + CHR(13)+CHR(10) + l_cCommand + CHR(13)+CHR(10),"upsizetmp.bat",0)
l_oShell = CREATEOBJECT("Wscript.Shell")
l_tStartTime = SECONDS()
LogArchive(GetLangText("ARCHIVE","TA_DATA_INTO_SERVER")+"...", .T.)

l_cPSQLLogPath = FULLPATH("psql.log")

DELETE FILE (l_cPSQLLogPath)

l_oShell.Run("upsizetmp.bat",IIF(l_lShow,1,0),.T.)

LogArchive(";  Duration: " + TRANSFORM(SECONDS()-l_tStartTime) + "seconds.")

l_lSuccess = .T.

IF FILE(l_cPSQLLogPath)
	l_cPSQLLog = FILETOSTR(l_cPSQLLogPath)
	IF "ROLLBACK" $ l_cPSQLLog OR "konnte nicht gefunden werden" $ l_cPSQLLog OR "operable program or batch file" $ l_cPSQLLog
		l_lSuccess = .F.
		LogArchive("Error when importing. Aborting. Please check " + l_cPSQLLogPath + " file for errors in database tables!")
		! /n notepad &l_cPSQLLogPath
	ENDIF
ENDIF

DELETE FILE upsizetmp.bat
IF l_lSuccess
	DELETE FILE (l_cPsqlScript)
ENDIF
this.DeleteChecksumTables()
WAIT CLEAR

RETURN l_lSuccess
ENDPROC
*
PROCEDURE ArchiveReservation
LPARAMETERS lp_nReserId, lp_nRsId
LOCAL l_lArchived

l_lArchived = this.ImportRecords("histres", "hr_reserid = " + SqlCnvB(lp_nReserId))
l_lArchived = this.ImportRecords("hresext", "rs_reserid = " + SqlCnvB(lp_nReserId)) AND l_lArchived
l_lArchived = this.ImportRecords("hresplit", "rl_rsid = " + SqlCnvB(lp_nRsId)) AND l_lArchived
l_lArchived = this.ImportRecords("hresrate", "rr_reserid = " + SqlCnvB(lp_nReserId)) AND l_lArchived
l_lArchived = this.ImportRecords("hresroom", "ri_reserid = " + SqlCnvB(lp_nReserId)) AND l_lArchived

RETURN l_lArchived
ENDPROC
*
PROCEDURE ArchivePost
LPARAMETERS lp_nPostId
LOCAL l_lArchived

l_lArchived = this.ImportRecords("histpost", "hp_postid = " + SqlCnvB(lp_nPostId))
l_lArchived = this.ImportRecords("hpostcng", "ph_postid = " + SqlCnvB(lp_nPostId)) AND l_lArchived

RETURN l_lArchived
ENDPROC
*
PROCEDURE ArchiveBillnum
LOCAL l_nSelect, l_lSuccess

l_nSelect = SELECT()

* Delete old data first
this.cScript = [SELECT bn_billnum, crc FROM "billnum";]
l_lSuccess = this.ExecSql("curBillnum")
IF NOT l_lSuccess
	RETURN .F.
ENDIF

INDEX ON bn_billnum TAG bn_billnum

SELECT billnum
SCAN FOR NOT SEEK(billnum.bn_billnum, "curBillnum", "bn_billnum") OR NOT curBillnum.crc == PADR(SYS(2017,"",0,3),10)
	l_lSuccess = this.ImportRecords("billnum", "bn_billnum = " + SqlCnvB(bn_billnum)) AND l_lSuccess
ENDSCAN
DClose("curBillnum")

SELECT (l_nSelect)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE ImportRecords
LPARAMETERS lp_cTable, lp_cFilter
LOCAL l_nSelect, l_lSuccess, l_cTable, l_cFields, l_cValues, l_cField, l_cMacro, l_nCurrent, l_cSelect, l_cTempFile, l_nrecno
PRIVATE poData

l_nSelect = SELECT()

* Delete old data first
this.cScript = [DELETE FROM "] + lp_cTable + [" WHERE ] + lp_cFilter + [;]
l_lSuccess = this.ExecSql()
IF NOT l_lSuccess
	RETURN .F.
ENDIF

* create insert command - fields structure
IF NOT USED("fields")
	USE (this.cDataDir+"fields") SHARED IN 0
ENDIF
l_cFields = ""
SELECT fields
SCAN FOR UPPER(fd_table+fd_name) = UPPER(PADR(lp_cTable,8))
	l_cFields = l_cFields + IIF(EMPTY(l_cFields), "", ",") + ALLTRIM(LOWER(fd_name))
ENDSCAN
l_cFields = l_cFields + this.ChecksumField(lp_cTable)
l_cValues = SUBSTR(STRTRAN(","+l_cFields, ",", ",?poData."),2)
this.cScript = [INSERT INTO "] + lp_cTable + [" (] + l_cFields + [) VALUES (] + l_cValues + [);]

* now take actual values from table
SELECT &lp_cTable
l_nrecno = RECNO()
SCAN FOR &lp_cFilter
	SCATTER MEMO NAME poData
	this.ChecksumValue(poData)
	SELECT fields
	SCAN FOR UPPER(fd_table+fd_name) = UPPER(PADR(lp_cTable,8))
		l_cField = ALLTRIM(LOWER(fd_name))
		poData.&l_cField = this.ConvField(poData.&l_cField)
	ENDSCAN
	l_lSuccess = this.ExecSql()
	SELECT &lp_cTable
	IF NOT l_lSuccess
		EXIT
	ENDIF
ENDSCAN
GO l_nrecno
SELECT (l_nSelect)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE DeleteChecksumTables
LOCAL i, lcFile

FOR i = 1 TO ALEN(this.aCrcTempDbfs)
	lcFile = this.aCrcTempDbfs(i)
	IF NOT EMPTY(lcFile)
		FileDelete(FORCEEXT(lcFile,'DBF'))
		FileDelete(FORCEEXT(lcFile,'CDX'))
		FileDelete(FORCEEXT(lcFile,'FPT'))
	ENDIF
NEXT

RETURN .T.
ENDPROC
*
PROCEDURE ChecksumTable
LPARAMETERS tcTable, tcDbf
LOCAL lnLast

DO CASE
	CASE INLIST(tcTable, "billnum")
		lnArea = SELECT()
		USE (tcDbf) IN 0 AGAIN ALIAS (tcTable) SHARED
		tcDbf = FileTemp("dbf",.T.)
		SELECT *, CAST(SYS(2017,"",0,3) AS Char(10)) AS crc FROM (tcTable) INTO TABLE (tcDbf)
		USE
		DClose(tcTable)
		lnLast = ALEN(this.aCrcTempDbfs)
		IF NOT EMPTY(this.aCrcTempDbfs(lnLast))
			lnLast = lnLast + 1
			DIMENSION this.aCrcTempDbfs(lnLast)
		ENDIF
		this.aCrcTempDbfs(lnLast) = tcDbf
		SELECT (lnArea)
	OTHERWISE
ENDCASE

RETURN .T.
ENDPROC
*
PROCEDURE ChecksumField
LPARAMETERS tcTable, tlCreateTable
LOCAL lcField

tcTable = ALLTRIM(LOWER(tcTable))
DO CASE
	CASE INLIST(tcTable, "billnum")
		lcField = [,crc] + IIF(tlCreateTable, [ CHARACTER(10) DEFAULT '' NOT NULL], [])
	OTHERWISE
		lcField = ""
ENDCASE

RETURN lcField
ENDPROC
*
PROCEDURE ChecksumValue
LPARAMETERS toData

DO CASE
	CASE INLIST(LOWER(ALIAS()), "billnum")
		ADDPROPERTY(toData,"crc",SYS(2017,"",0,3))
	OTHERWISE
ENDCASE

RETURN .T.
ENDPROC
*
PROCEDURE ConvField
LPARAMETERS tcValue
LOCAL lvExp, lcReplacement

lvExp = EVALUATE("tcValue")
DO CASE
	CASE INLIST(VARTYPE(lvExp), "N", "I", "B")
		lcReplacement = STRTRAN(TRANSFORM(lvExp),",",".")
	CASE VARTYPE(lvExp) = "Y"
		lcReplacement = ALLTRIM(STR(lvExp,15,4))
	CASE VARTYPE(lvExp) = "D"
		lcReplacement = IIF(EMPTY(lvExp), "'16111111'", DTOS(lvExp))
	CASE VARTYPE(lvExp) = "T"
		lcReplacement = IIF(EMPTY(lvExp), "'1611-11-11 11:11:11'", STRTRAN(TTOC(lvExp,3),"T"," "))
	CASE INLIST(VARTYPE(lvExp), "C", "M")
		lcReplacement = ALLTRIM(lvExp)
	CASE VARTYPE(lvExp) = "L"
		lcReplacement = IIF(lvExp, "true", "false")
	OTHERWISE
		ASSERT .F. MESSAGE PROGRAM()
ENDCASE

RETURN lcReplacement
ENDPROC
*
PROCEDURE ExecSql
LPARAMETERS lp_cCursorName, lp_nDecimals
LOCAL l_nRetVal, l_lSuccess, i, l_cText, l_nDecimals

IF VARTYPE(lp_nDecimals) = "N"
	l_nDecimals = SET("Decimals")
	SET DECIMALS TO lp_nDecimals
ENDIF

l_nRetVal = 0
TRY
	IF NOT EMPTY(lp_cCursorName)
		l_nRetVal = SQLEXEC(this.nHandle,this.cScript,lp_cCursorName)
	ELSE
		l_nRetVal = SQLEXEC(this.nHandle,this.cScript)
	ENDIF
CATCH TO l_oError
	MESSAGEBOX(TRANSFORM(l_oError.ErrorNo))
ENDTRY

IF VARTYPE(lp_nDecimals) = "N"
	SET DECIMALS TO l_nDecimals
ENDIF

IF l_nRetVal <> 1
	AERROR(l_aError)
	DISPLAY MEMORY LIKE l_aError TO odbc_error.txt NOCONSOLE
	l_cText = ""
	FOR i = 1 TO ALEN(l_aError)
		l_cText = l_cText + TRANSFORM(l_aError(i)) + CHR(13)
	ENDFOR
	ASSERT .F. MESSAGE l_cText
	IF .F.
		_CLIPTEXT = this.cScript
	ENDIF
	STRTOFILE(TRANSFORM(DATETIME())+" "+this.cScript+CHR(10)+CHR(13)+l_cText+CHR(10)+CHR(13),"archive_log.txt",1)
ELSE
	l_lSuccess = .T.
ENDIF

RETURN l_lSuccess
ENDPROC
*
ENDDEFINE
*