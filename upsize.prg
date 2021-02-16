* No need for creating database, and ODBC DSN is not required.
*
* In citadel.ini in system section must be set:
* ODBCSERVER=192.168.1.4	or (localhost)
* ODBCPORT=5432				; for PostgreSQL default port is 5432
* ODBCDRIVERNAME=PostgreSQL ODBC Driver(UNICODE)
*
* If ODBCDATABASE is not specified than name of database would be 'citadel'.
*
* Errors are logged in upsize_log.txt
*
LOCAL l_oUp AS cUpsize, l_cDataDir, l_lEmptyTables, l_lNoRemoveDuplicates
PRIVATE pcDriverName, pcServer, pcPort, pcDatabase, pcSchema, pcPgDbf, pcPSQLPass

pcPSQLPass = IIF(TYPE('pcOdbcPassword')<>'C' OR EMPTY(pcOdbcPassword),'zimnicA$2001',pcOdbcPassword)
pcDriverName = _screen.oGlobal.cODBCDriverName
pcServer = _screen.oGlobal.cODBCServer
pcPort = _screen.oGlobal.cODBCPort
pcDatabase = _screen.oGlobal.cODBCDatabase
pcSchema = "desk" + IIF(TYPE("gcHotCode") <> "C" OR EMPTY(gcHotCode), "", "_" + LOWER(gcHotCode))
pcPgDbf = FULLPATH("pgdbf.exe")

l_cDataDir = FULLPATH(gcDatadir)

l_oUp = CREATEOBJECT("cUpsize", l_cDataDir)
*l_oUp.CreatePython()
l_oUp.CreateSchema()
l_oUp.CreateTables()
SetODBC(.T.)
DO DBCheckStructureOdbcTableIndexes IN DbUpdate
DO DBCheckStructureOdbcSource IN DbUpdate
_screen.oGlobal.oGData.ReleaseHandles(.T.)
SetODBC()

l_lEmptyTables = .F.
l_lNoRemoveDuplicates = .F.
l_oUp.ImportTables(l_lEmptyTables, l_lNoRemoveDuplicates)
IF USED("curTables")
	USE IN curTables
ENDIF
WAIT CLEAR
*
PROCEDURE DoUpsize
LOCAL l_oSession, l_tStartTime, l_tEndTime

IF 6 = MESSAGEBOX(GetLangText("ADPURGE","TA_AREYOUSURE"),292)
	PRIVATE pcOdbcPassword
	pcOdbcPassword = ReadINI(FULLPATH(_screen.oGlobal.cHotelDir+"citadel.ini"),[System],[ODBCPWD])
	l_tStartTime = SECONDS()
	DO SetMessagesOff IN procmessages
	l_oSession = CREATEOBJECT("PrivateSession")
	l_oSession.CallProc("Upsize()")
	DO SetMessagesOn IN procmessages
	l_tEndTime = SECONDS()
	MESSAGEBOX(Str2Msg(GetLangText("UPSIZE","TXT_DB_UPSIZED_TO_POSTGRESQL"), "%s", Sec2Time(l_tEndTime - l_tStartTime)),64)
ENDIF
ENDPROC
*
DEFINE CLASS cUpsize AS Custom

#IF .F. && Make sure this is false, otherwise error
   *-- Define This for IntelliSense use
   LOCAL This AS cUpsize OF upsize.prg
#ENDIF

oTables = .NULL.
cScript = ""
nHandle = 0
cDataDir = ""
cConnectString = ""
*
PROCEDURE Init
LPARAMETERS lp_cDataDir

SET POINT TO "."
*SET ASSERTS ON
SET DELETED ON
SET SAFETY OFF
SYS(987,.T.)

this.ServerConnect(.T.)		&& Just connect to the server for creating a database.
this.CreateDatabase()
this.ServerConnect()		&& Connect to the specified database after its creation.

this.cDataDir = ADDBS(EVL(lp_cDataDir, ADDBS(SYS(5)+SYS(2003))+"data"))

IF NOT USED("files")
	USE (this.cDataDir+"files") SHARED IN 0
	SET ORDER TO 1 IN files
ENDIF
IF NOT USED("fields")
	USE (this.cDataDir+"fields") SHARED IN 0
	SET ORDER TO 1 IN fields
ENDIF
ENDPROC
*
PROCEDURE Destroy
SQLDISCONNECT(0)
ENDPROC
*
PROCEDURE ServerConnect
LPARAMETERS lp_lNoDatabase
LOCAL l_cConnString

SQLDISCONNECT(0)

TEXT TO l_cConnString TEXTMERGE NOSHOW PRETEXT 15
Driver={<<pcDriverName>>};
Uid=postgres;Pwd=<<IIF(TYPE('pcOdbcPassword')<>'C' OR EMPTY(pcOdbcPassword),'zimnicA$2001',pcOdbcPassword)>>;DATABASE=<<IIF(lp_lNoDatabase,'postgres',pcDatabase)>>;
SERVER=<<pcServer>>;PORT=<<pcPort>>;
CA=d;A6=;A7=100;A8=4096;B0=255;B1=8190;BI=2;C2=dd_;;CX=1b102bb;A1=7.4-1
ENDTEXT

this.nHandle = SQLSTRINGCONNECT(l_cConnString)

RETURN .T.
ENDPROC
*
PROCEDURE CreateDatabase
this.cScript = "SELECT datname FROM pg_catalog.pg_database WHERE datname = '"+LOWER(pcDatabase)+"';"
this.ExecSql("curdatabase")
IF RECCOUNT() = 0
	WAIT CLEAR
	WAIT "Creating curdatabase: " + pcDatabase WINDOW NOWAIT
	TEXT TO this.cScript TEXTMERGE NOSHOW PRETEXT 15
	CREATE DATABASE "<<pcDatabase>>"
		WITH OWNER = postgres
		ENCODING = 'UTF8'
		TABLESPACE = pg_default
		LC_COLLATE = 'C'
		LC_CTYPE = 'C'
		CONNECTION LIMIT = -1;
	ENDTEXT
	this.ExecSql()
ENDIF
USE IN curdatabase

RETURN .T.
ENDPROC
*
PROCEDURE CreatePython
this.cScript = "SELECT lanname FROM pg_catalog.pg_language WHERE lanname = 'plpython3u';"
this.ExecSql("curlanguage")
IF RECCOUNT() = 0
	WAIT CLEAR
	WAIT "Creating curlanguage: plpython3u" WINDOW NOWAIT
	this.cScript = "CREATE EXTENSION plpython3u;"
	this.ExecSql()
ENDIF
USE IN curlanguage

RETURN .T.
ENDPROC
*
PROCEDURE CreateSchema
this.cScript = "SELECT schema_name FROM Information_Schema.Schemata WHERE schema_name = '"+LOWER(pcSchema)+"';"
this.ExecSql("curschema")
IF RECCOUNT() = 0
	WAIT CLEAR
	WAIT "Creating schema: " + pcSchema WINDOW NOWAIT
	this.cScript = "CREATE SCHEMA "+pcSchema+";"
	this.ExecSql()
ENDIF
this.cScript = "SET search_path TO "+pcSchema+";"
this.ExecSql()
USE IN curschema

RETURN .T.
ENDPROC
*
PROCEDURE GetTables
l_nFound = ADIR(l_aDir,this.cDataDir+"*.dbf")
FOR i = 1 TO l_nFound
	l_cTable = LOWER(FORCEEXT(l_aDir(i,1),""))
	IF INLIST(l_cTable, "files", "fields")
		LOOP
	ENDIF
	IF USED(l_cTable)
		USE IN (l_cTable)
	ENDIF
	IF NOT SEEK(UPPER(PADR(l_cTable,20)),"files","tag1")
		INSERT INTO files (;
				fi_name) VALUES ;
					(UPPER(l_cTable))
	
	ENDIF
	USE (this.cDataDir+l_cTable) SHARED IN 0
	IF ATAGINFO(l_aTag,"",l_cTable)>0
		FOR t = 1 TO ALEN(l_aTag,1)
			l_cKeyName = "fi_kname" + TRANSFORM(t)
			l_cKey = "fi_key" + TRANSFORM(t)
			REPLACE &l_cKeyName WITH l_aTag(t,1), ;
					&l_cKey WITH l_aTag(t,3) IN files
		ENDFOR
	ELSE
		FOR t = 1 TO 8
			l_cKeyName = "fi_kname" + TRANSFORM(t)
			l_cKey = "fi_key" + TRANSFORM(t)
			REPLACE &l_cKeyName WITH "", ;
					&l_cKey WITH "" IN files
		ENDFOR
	ENDIF
	AFIELDS(l_aFields,l_cTable)
	FOR j = 1 TO ALEN(l_aFields,1)
		SELECT fields
		IF NOT SEEK(UPPER(PADR(l_cTable,20)+PADR(l_aFields(j,1),10)),"fields","fields")
			INSERT INTO fields (;
					fd_table, ;
					fd_name, ;
					fd_type, ;
					fd_len, ;
					fd_dec) VALUES ;
					( ;
					UPPER(l_cTable), ;
					UPPER(l_aFields(j,1)), ;
					l_aFields(j,2), ;
					l_aFields(j,3), ;
					l_aFields(j,4))
		ENDIF
	ENDFOR
ENDFOR

ENDPROC
*
PROCEDURE CreateTables
this.cScript = [SELECT * FROM pg_tables WHERE schemaname = ']+LOWER(pcSchema)+[';]
this.ExecSql("curTables")

SELECT files
SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND NOT fi_vfp AND fi_path = "DATA\"
	WAIT CLEAR
	WAIT "Creating a table: " + ALLTRIM(fi_name) WINDOW NOWAIT
	this.CreateTable()
ENDSCAN

this.cScript = [SELECT * FROM pg_tables WHERE schemaname = ']+LOWER(pcSchema)+[';]
this.ExecSql("curTables")
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
	IF NOT EMPTY(files.fi_unikey)
	     l_cPrimaryKey = [, PRIMARY KEY (] + ALLTRIM(LOWER(files.fi_unikey)) + [) DEFERRABLE]
	ENDIF
	TEXT TO this.cScript TEXTMERGE NOSHOW PRETEXT 15
	CREATE TABLE "<<ALLTRIM(LOWER(files.fi_name))>>" (<<l_cFields>><<l_cPrimaryKey>>);
	ENDTEXT
	this.ExecSql()
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE ConvertDateField
LOCAL l_nSelect

l_nSelect = SELECT()

SELECT fields
SCAN FOR UPPER(fd_table+fd_name) = UPPER(files.fi_name) AND fd_type = "D"
	WAIT WINDOW fd_name NOWAIT
	TEXT TO this.cScript TEXTMERGE NOSHOW PRETEXT 15
	UPDATE <<pcSchema>>."<<ALLTRIM(LOWER(fd_table))>>" SET <<ALLTRIM(LOWER(fd_name))>> = '16111111' WHERE <<ALLTRIM(LOWER(fd_name))>> = '11111111';
	ENDTEXT
	this.ExecSql()
ENDSCAN

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE TableIndexes
LOCAL i, l_cIndexExp

SELECT files
SCAN
	FOR i = 1 TO 20
		l_cIndexExp = "fi_pidx" + TRANSFORM(i)
		IF NOT EMPTY(&l_cIndexExp)
			* Index for primary key was created automaticly!
			TEXT TO this.cScript TEXTMERGE NOSHOW PRETEXT 15
			CREATE INDEX <<ALLTRIM(LOWER(fi_name))>>_tag<<i>> ON <<pcSchema>>.<<ALLTRIM(LOWER(fi_name))>> USING btree (<<ALLTRIM(LOWER(&l_cIndexExp))>>);
			ENDTEXT
			this.ExecSql()
		ENDIF
	NEXT
ENDSCAN
ENDPROC
*
PROCEDURE ConvFieldDefinition
LPARAMETERS lp_cType, lp_nLen, lp_nDec, lp_lAutoInc
LOCAL l_cDefault

l_cDefault = ""
l_cFScript = ""
DO CASE
	CASE lp_lAutoInc
		l_cFScript = "serial"
	CASE lp_cType = "N"
		l_cFScript = "numeric"
		IF NOT EMPTY(lp_nLen)
			l_cFScript = l_cFScript + "("+TRANSFORM(lp_nLen)
			IF NOT EMPTY(lp_nDec)
				l_cFScript = l_cFScript + "," + TRANSFORM(lp_nDec)
			ENDIF
			l_cFScript = l_cFScript + +")"
		ENDIF
		l_cDefault = "0"
	CASE lp_cType = "I"
		l_cFScript = "integer"
		l_cDefault = "0"
	CASE lp_cType = "D"
		l_cFScript = "date"
		l_cDefault = "'1611-11-11'::date"
	CASE lp_cType = "T"
		l_cFScript = "timestamp without time zone"
		l_cDefault = "'1611-11-11 11:11:11'::timestamp without time zone"
	CASE lp_cType = "Y"
		l_cFScript = "numeric(15,4)"
		l_cDefault = "0"
	CASE lp_cType = "V"
		l_cFScript = "varchar"
		IF NOT EMPTY(lp_nLen)
			l_cFScript = l_cFScript + "("+TRANSFORM(lp_nLen) + ")"
		ENDIF
		l_cDefault = "''"
     CASE lp_cType = "C"
          l_cFScript = "char"
          l_cFScript = l_cFScript + "("+TRANSFORM(lp_nLen) + ")"
          l_cDefault = "''"
	CASE lp_cType = "M"
		l_cFScript = "text"
		l_cDefault = "''"
	CASE lp_cType = "L"
		l_cFScript = "boolean"
		l_cDefault = "false"
	CASE lp_cType = "B"
		l_cFScript = "float8"
		l_cDefault = "0"
ENDCASE
IF NOT EMPTY(l_cFScript)
	*ASSERT .F.
	l_cFScript = " " + l_cFScript + IIF(EMPTY(l_cDefault)," "," DEFAULT " + l_cDefault + " NOT NULL ")
	*l_cFScript = " " + l_cFScript + IIF(EMPTY(l_cDefault)," "," DEFAULT " + l_cDefault + " ")
ENDIF

RETURN l_cFScript
ENDPROC
*
PROCEDURE ImportTables
LPARAMETERS lp_lEmptyTable, lp_lNoRemoveDuplicates
LOCAL i, l_oShell, l_cCommand, l_cFields, l_lShow, l_cPsqlScript

WAIT "Importing data into server. Please wait..." WINDOW NOWAIT
l_cPsqlScript = SYS(2015)+".sql"
SET TEXTMERGE ON
SET TEXTMERGE TO (l_cPsqlScript) NOSHOW
\SET standard_conforming_strings = off;
\SET client_min_messages = warning;
\SET escape_string_warning = off;
\SET search_path TO <<pcSchema>>, pg_catalog;
*Disable all constraints for PK validation
\SET CONSTRAINTS ALL DEFERRED;
SELECT files
SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND NOT fi_vfp AND fi_path = "DATA\"&& AND UPPER(fi_name) = "POST    "
	USE (this.cDataDir+ALLTRIM(fi_name)) SHARED IN 0 AGAIN
	l_cFields = ""
	FOR i = 1 TO FCOUNT((ALLTRIM(fi_name)))
		l_cFields = l_cFields + IIF(EMPTY(l_cFields), "", ",") + FIELD(i,(ALLTRIM(fi_name)))
	NEXT
	*WAIT "Importing data into table: " + ALLTRIM(fi_name) + "..." WINDOW NOWAIT
	\ALTER TABLE "<<ALLTRIM(LOWER(fi_name))>>" DISABLE TRIGGER ALL;
	\ \COPY "<<ALLTRIM(LOWER(fi_name))>>" (<<LOWER(l_cFields)>>) FROM PROGRAM '<<LOWER(pcPgDbf)>> <<LOWER(this.cDataDir+ALLTRIM(fi_name)+".dbf")>>';
	IF NOT lp_lNoRemoveDuplicates AND NOT EMPTY(fi_unikey)
		\SELECT pl_remove_duplicates('<<ALLTRIM(LOWER(fi_name))>>','{<<ALLTRIM(LOWER(fi_unikey))>>}');
	ENDIF
	\ALTER TABLE "<<ALLTRIM(LOWER(fi_name))>>" ENABLE TRIGGER ALL;
	IF RECCOUNT(ALLTRIM(fi_name)) = 0
		APPEND BLANK IN (ALLTRIM(fi_name))
	ENDIF
	USE IN (ALLTRIM(fi_name))
ENDSCAN
*Enable all constraints for PK validation
\SET CONSTRAINTS ALL IMMEDIATE
SET TEXTMERGE TO
SET TEXTMERGE OFF

l_lShow = .F.
l_cCommand = TEXTMERGE([psql -h <<pcServer>> -p <<pcPort>> -d <<pcDatabase>> -U postgres -w -f <<l_cPsqlScript>>])
STRTOFILE("SET PGPASSWORD=" + pcPSQLPass + CHR(13)+CHR(10) + l_cCommand + CHR(13)+CHR(10),"upsizetmp.bat",0)
l_oShell = CREATEOBJECT("Wscript.Shell")
l_oShell.Run("upsizetmp.bat",IIF(l_lShow,1,0),.T.)
DELETE FILE upsizetmp.bat
DELETE FILE (l_cPsqlScript)
WAIT CLEAR

RETURN .T.
ENDPROC
*
PROCEDURE ImportTable
LPARAMETERS lp_lEmptyTable
LOCAL l_nSelect, l_cTable, l_cFields, l_cValues, l_cField, l_cMacro, l_nCurrent, l_cSelect, l_cTempFile
PRIVATE ALL LIKE m.

l_nSelect = SELECT()

l_cTable = ALLTRIM(LOWER(files.fi_name))

* check if table not exists
this.Createtable()

IF lp_lEmptyTable
	RETURN .T.
ENDIF

IF USED("curres")
	USE IN curres
ENDIF
* Check if we already have imported data for this table
this.cScript = [SELECT COUNT(*) AS res FROM "] + l_cTable + [";]
this.ExecSql("curres")
IF USED("curres") AND RECCOUNT() > 0 AND curres.res > 0
     RETURN .T.
ENDIF

IF USED(l_cTable)
	USE IN (l_cTable)
ENDIF
USE (this.cDataDir+l_cTable) SHARED IN 0 AGAIN

SELECT (l_cTable)
SCATTER MEMO BLANK MEMVAR

* create insert command - fields structure
l_nCurrent = -1
l_cFields = ""
l_cSelect = ""
SELECT fields
SCAN FOR UPPER(fd_table+fd_name) = UPPER(files.fi_name)
	l_cFields = l_cFields + IIF(EMPTY(l_cFields), "", ",") + ALLTRIM(LOWER(fd_name))
	l_cSelect = l_cSelect + IIF(EMPTY(l_cSelect), "", "+") + "_C("+ALLTRIM(LOWER(fd_name))+",'"+fd_type+"',"+TRANSFORM(fd_len) + IIF(EMPTY(l_cSelect), ",.T.)", ")")
ENDSCAN

IF .F.
l_cTempFile = FULLPATH(SYS(2015)+'.txt')
SELECT (l_cTable)
SCAN
	IF MOD(RECNO(),10000) = 0
		WAIT CLEAR
	ENDIF
	IF ROUND(100*RECNO()/RECCOUNT(),1) <> l_nCurrent
		l_nCurrent = ROUND(100*RECNO()/RECCOUNT(),1)
		WAIT "Importing data into table: " + ALLTRIM(files.fi_name) + "... " + STR(l_nCurrent,5,1) + "%" WINDOW NOWAIT
	ENDIF
	STRTOFILE(&l_cSelect+CHR(10),l_cTempFile,.T.)
ENDSCAN

IF FILE(l_cTempFile)
	TEXT TO this.cScript TEXTMERGE NOSHOW PRETEXT 7
	ALTER TABLE "<<l_cTable>>" DISABLE TRIGGER ALL;
	COPY "<<l_cTable>>" (<<l_cFields>>) FROM '<<l_cTempFile>>';
	ALTER TABLE "<<l_cTable>>" ENABLE TRIGGER ALL;
	ENDTEXT
	this.ExecSql()
	DELETE FILE (l_cTempFile)
ENDIF
ELSE
* now take actual values from table
SELECT (l_cTable)
SCAN
	IF MOD(RECNO(),10000) = 0
		WAIT CLEAR
	ENDIF
	IF ROUND(100*RECNO()/RECCOUNT(),1) <> l_nCurrent
		l_nCurrent = ROUND(100*RECNO()/RECCOUNT(),1)
		WAIT "Importing data into table: " + ALLTRIM(files.fi_name) + "... " + STR(l_nCurrent,5,1) + "%" WINDOW NOWAIT
	ENDIF
	l_cValues = ""
	SELECT fields
	SCAN FOR UPPER(fd_table+fd_name) = UPPER(files.fi_name)
		l_cField = ALLTRIM(LOWER(fd_name))
		SELECT (l_cTable)
		IF TYPE(l_cField) = "U"
			* New incremental field. Get RECNO value.
			l_cValues = l_cValues + IIF(EMPTY(l_cValues), [], [, ]) + this.ConvField(RECNO())
		ELSE
			l_cMacro = "m." + l_cField
			&l_cMacro = this.ConvField(&l_cField)
			l_cValues = l_cValues + IIF(EMPTY(l_cValues), [], [, ]) + "?" + l_cMacro
		ENDIF
		SELECT fields
	ENDSCAN
	this.cScript = [INSERT INTO "] + l_cTable + [" (] + l_cFields + [) VALUES (] + l_cValues + [);]
	this.ExecSql()
	SELECT (l_cTable)
ENDSCAN
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE TableSquences
RETURN .T.
SELECT files
SCAN FOR files.fi_autoinc AND NOT files.fi_vfp
     this.cScript = "SELECT setval( '"+LOWER(TRIM(files.fi_name))+"_"+ALLTRIM(LOWER(files.fi_key))+"_seq'," +;
               " ( SELECT MAX( "+ALLTRIM(LOWER(files.fi_key))+" ) FROM "+LOWER(TRIM(files.fi_name))+" ) );"
     this.ExecSql()
ENDSCAN

ENDPROC
*
PROCEDURE DeleteRecordsInTables
SELECT files
SCAN ALL
	this.cScript = [DELETE FROM "] + ALLTRIM(LOWER(fi_name)) + [";]
	this.ExecSql()
ENDSCAN
ENDPROC
*
PROCEDURE DeleteTables
SELECT files
SCAN ALL
	this.cScript = [DROP TABLE "] + ALLTRIM(LOWER(fi_name)) + [";]
	this.ExecSql()
ENDSCAN
ENDPROC
*
PROCEDURE SetField
LPARAMETERS tvExp, tcFieldType, tnFieldWidth
LOCAL lcReplacement

DO CASE
	CASE INLIST(tcFieldType, "N", "I", "B")
		lcReplacement = "TRANSFORM("+tvExp+")"
	CASE INLIST(tcFieldType, "C")
		lcReplacement = "STRCONV(STRTRAN(STRTRAN(STRTRAN(PADL("+tvExp+","+TRANSFORM(tnFieldWidth)+"),CHR(9),'\t'),CHR(10),'\n'),CHR(13),'\r'),9)"
	CASE tcFieldType = "D"
		lcReplacement = "LEFT(TTOC(EVL("+tvExp+",{^1611-11-11}),3),10)"
	CASE tcFieldType = "T"
		lcReplacement = "STRTRAN(TTOC(EVL("+tvExp+",{^1611-11-11,11:11:11}),3),'T',' ')"
	CASE tcFieldType = "L"
		lcReplacement = "IIF("+tvExp+",'f','t')"
	CASE INLIST(tcFieldType, "M")
		lcReplacement = "STRCONV(STRTRAN(STRTRAN(STRTRAN("+tvExp+",CHR(9),'\t'),CHR(10),'\n'),CHR(13),'\r'),9)"
	CASE tcFieldType = "Y"
		lcReplacement = "STR("+tvExp+",20,4)"
	OTHERWISE
		lcReplacement = ""
ENDCASE

RETURN lcReplacement
ENDPROC
*
PROCEDURE ConvField
LPARAMETERS lp_cValue
LOCAL lvExp
lvExp = EVALUATE("lp_cValue")
DO CASE
     CASE INLIST(VARTYPE(lvExp), "N", "I", "B")
          lcReplacement = this.NToC(lvExp)
     CASE VARTYPE(lvExp) = "Y"
          lcReplacement = ALLTRIM(STR(lvExp,15,4))
     CASE VARTYPE(lvExp) = "D"
          IF EMPTY(lvExp)
               lcReplacement = "'16111111'"
          ELSE
               lcReplacement = DTOS(lvExp)
          ENDIF
     CASE VARTYPE(lvExp) = "T"
          IF EMPTY(lvExp)
               lcReplacement = "'1611-11-11 11:11:11'"
          ELSE
               lcReplacement = STRTRAN(TTOC(lvExp,3),"T"," ")
          ENDIF
     CASE INLIST(VARTYPE(lvExp), "C", "M")
          vExp = TRIM(lvExp)
          lcReplacement = vExp
*!*               IF AT(['], lvExp)>0 OR AT([\], lvExp)>0
*!*                    lcReplacement = "$$" + TRIM(lvExp) + "$$"
*!*               ELSE
*!*                    lcReplacement = "'" + TRIM(lvExp) + "'"
*!*               ENDIF
          
     CASE VARTYPE(lvExp) = "L"
          lcReplacement = IIF(lvExp, "true", "false")
     OTHERWISE
          ASSERT .F. MESSAGE PROGRAM()
ENDCASE

RETURN lcReplacement
ENDPROC
*
PROCEDURE ConvFieldOld
LPARAMETERS lp_cValue
LOCAL lvExp
lvExp = EVALUATE("lp_cValue")
DO CASE
	CASE INLIST(VARTYPE(lvExp), "N", "I", "B")
		lcReplacement = this.NToC(lvExp)
	CASE VARTYPE(lvExp) = "Y"
		lcReplacement = "'"+ALLTRIM(STR(lvExp,15,4))+"'"
	CASE VARTYPE(lvExp) = "D"
		IF EMPTY(lvExp)
			lcReplacement = "NULL"
		ELSE
			lcReplacement = "'" + DTOS(lvExp) + "'"
		ENDIF
	CASE VARTYPE(lvExp) = "T"
		IF EMPTY(lvExp)
			lcReplacement = "NULL"
		ELSE
			lcReplacement = "'" + STRTRAN(TTOC(lvExp,3),"T"," ") + "'"
		ENDIF
	CASE INLIST(VARTYPE(lvExp), "C", "M")
		vExp = TRIM(lvExp)
		IF AT(['], lvExp)>0 OR AT([\], lvExp)>0
			lcReplacement = "$$" + TRIM(lvExp) + "$$"
		ELSE
			lcReplacement = "'" + TRIM(lvExp) + "'"
		ENDIF
		
	CASE VARTYPE(lvExp) = "L"
		lcReplacement = IIF(lvExp, "true", "false")
	OTHERWISE
		ASSERT .F. MESSAGE PROGRAM()
ENDCASE

RETURN lcReplacement
ENDPROC
*
PROCEDURE ntoc
LPARAMETERS tnNumber
LOCAL lcRet, lcPoint

IF INT(tnNumber) = tnNumber
	lcRet = LTRIM(STR(tnNumber))
ELSE
	lcPoint = SET("Point")
	SET POINT TO "."
	lcRet = LTRIM(STR(tnNumber, 20, 8))
	DO WHILE RIGHT(lcRet, 1) = "0"
		lcRet = SUBSTR(lcRet, 1, LEN(lcRet) - 1)
	ENDDO
	SET POINT TO lcPoint
ENDIF

RETURN lcRet
*
PROCEDURE ConvIndexExp
LPARAMETERS lp_cExp
lp_cExp = STRTRAN(lp_cExp,"+",",")
RETURN lp_cExp
ENDPROC
*
PROCEDURE ExecSql
LPARAMETERS lp_cCursorName
LOCAL l_nRetVal, l_lSuccess, i, l_cText
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
     STRTOFILE(TRANSFORM(DATETIME())+" "+this.cScript+CHR(10)+CHR(13)+l_cText+CHR(10)+CHR(13),"upsize_log.txt",1)
ELSE
	l_lSuccess = .T.
ENDIF
RETURN l_lSuccess
ENDPROC
*
ENDDEFINE
*
PROCEDURE _C
LPARAMETERS tvExp, tcFieldType, tnFieldWidth, tlNoTab
LOCAL lcReplacement

DO CASE
	CASE INLIST(tcFieldType, "N", "I", "B")
		lcReplacement = TRANSFORM(tvExp)
	CASE INLIST(tcFieldType, "C")
		lcReplacement = STRCONV(STRTRAN(STRTRAN(STRTRAN(PADL(tvExp,tnFieldWidth),CHR(9),'\t'),CHR(10),'\n'),CHR(13),'\r'),9)
	CASE tcFieldType = "D"
		lcReplacement = LEFT(TTOC(EVL(tvExp,{^1611-11-11}),3),10)
	CASE tcFieldType = "T"
		lcReplacement = STRTRAN(TTOC(EVL(tvExp,{^1611-11-11,11:11:11}),3),'T',' ')
	CASE tcFieldType = "L"
		lcReplacement = IIF(tvExp,'f','t')
	CASE INLIST(tcFieldType, "M")
		lcReplacement = STRCONV(STRTRAN(STRTRAN(STRTRAN(tvExp,CHR(9),'\t'),CHR(10),'\n'),CHR(13),'\r'),9)
	CASE tcFieldType = "Y"
		lcReplacement = STR(tvExp,20,4)
	OTHERWISE
		lcReplacement = ""
ENDCASE

RETURN IIF(tlNoTab, "", CHR(9))+lcReplacement
ENDPROC
*