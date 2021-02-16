PROCEDURE ProcCryptor
LPARAMETERS tnFunction, tcDefaultPath, tcTableName, tcCommand
#INCLUDE "cryptor.h"
#DEFINE CRLF				CHR(13) + CHR(10)

IF EMPTY(tnFunction)
	tnFunction = CR_REGISTER
ENDIF
IF EMPTY(tcDefaultPath)
	IF TYPE("gcApplication")="C" AND UPPER(gcApplication) = "CITADEL DESK"
		IF NOT EMPTY(gcDatadir)
			tcDefaultPath = gcDatadir
			IF LOWER(tcDefaultPath)=="data\"
				tcDefaultPath = FULLPATH(tcDefaultPath)
			ENDIF
		ENDIF
	ENDIF
	IF EMPTY(tcDefaultPath)
		tcDefaultPath = ADDBS(SYS(5)+SYS(2003))+"DATA"
	ENDIF
ENDIF
tcDefaultPath = ADDBS(tcDefaultPath)
IF EMPTY(tcTableName)
	tcTableName = ""
ENDIF

IF NOT FILE(tcDefaultPath + "notable.go")
	RETURN .T.
ENDIF
IF NOT INLIST(tnFunction, CR_REGISTER, CR_ENCODE, CR_DECODE, CR_UNREGISTER, CR_EXEC_FUNC) OR tnFunction = CR_EXEC_FUNC AND EMPTY(tcTableName)
	RETURN .F.
ENDIF

* Creating a Cryptor object
PUBLIC g_CryptorObject
IF VARTYPE(g_CryptorObject) <> "O"
	g_CryptorObject = CREATEOBJECT("Cryptor", tcDefaultPath, "Br1973Cit", ENCODER_WHITESPACE, "Hotel.crypt.log")
	IF VARTYPE(g_CryptorObject) <> "O"
		RELEASE g_CryptorObject
		RETURN .F.
	ENDIF
	g_CryptorObject.SetProperty("BackupMode", CRYPTOR_DELETEBACKUP)
ENDIF

LOCAL lnArea, lcCommand, lcComment, lcFilesAlias, lcTmpFiles, llSplashActive, llSuccess, l_lEncrypted

lnArea = SELECT()
llSuccess = .T.
l_lEncrypted = .T.

IF TYPE("frmSplash") = "O"
	llSplashActive = .T.
	frmSplash.Show()
ENDIF

DO CASE
	CASE tnFunction = CR_REGISTER
		lcCommand = "g_CryptorObject.RegisterTable"
		lcComment = "Registering"
	CASE tnFunction = CR_ENCODE
		lcCommand = "g_CryptorObject.EncodeTable"
		IF g_CryptorObject.CheckTable("files") AND NOT g_CryptorObject.IsCrypted(.F., "files")
			IF TYPE("_screen.oGlobal.choteldir")="C" AND NOT EMPTY(_screen.oGlobal.choteldir)
				g_CryptorObject.cBackupDir = ADDBS(_screen.oGlobal.choteldir+"Tmp\" + SYS(3))
			ELSE
				g_CryptorObject.cBackupDir = ADDBS(FULLPATH("Tmp\" + SYS(3)))
			ENDIF
			lcComment = "Backup & encod."
		ELSE
			lcComment = "Encoding"
		ENDIF
	CASE tnFunction = CR_DECODE
		lcCommand = "g_CryptorObject.DecodeTable"
		lcComment = "Decoding"
	CASE tnFunction = CR_UNREGISTER
		lcCommand = "g_CryptorObject.UnregisterTable"
		lcComment = "Unregistering"
	CASE tnFunction = CR_EXEC_FUNC
		lcCommand = "g_CryptorObject." + tcCommand
ENDCASE

IF EMPTY(tcTableName)
	* Apply function on all tables.
	g_CryptorObject.lLogMessage = .T.
	g_CryptorObject.lShowMessage = NOT llSplashActive
	IF g_CryptorObject.CheckTable("files")
		lcFilesAlias = SYS(2015)
		lcTmpFiles = SYS(2015)
		USE (tcDefaultPath + "files") IN 0 AGAIN ALIAS &lcTmpFiles SHARED
		SELECT DISTINCT fi_name, fi_path, fi_flag FROM &lcTmpFiles ORDER BY fi_path, fi_name INTO CURSOR &lcFilesAlias READWRITE
		USE IN &lcTmpFiles
		INSERT INTO &lcFilesAlias (fi_name, fi_path, fi_flag) VALUES ("FILES", "DATA\", "")
		INSERT INTO &lcFilesAlias (fi_name, fi_path, fi_flag) VALUES ("FIELDS", "DATA\", "")
		IF llSplashActive
			frmsplash.Progress.Caption = lcComment + " database ..."
			frmsplash.Reset(RECCOUNT())
		ENDIF
		SCAN FOR tnFunction = CR_DECODE OR NOT ("X" $ fi_flag)
			IF llSplashActive
				frmsplash.Update(RECNO())
			ENDIF
			IF tnFunction = CR_ENCODE
				g_CryptorObject.BackupTable(fi_name, tcDefaultPath + "..\" + ALLTRIM(fi_path))
			ENDIF
			llSuccess = &lcCommand(fi_name, tcDefaultPath + "..\" + ALLTRIM(fi_path)) AND llSuccess
		ENDSCAN
		USE IN &lcFilesAlias
		IF INLIST(tnFunction, CR_ENCODE, CR_DECODE)
			IF llSplashActive
				frmsplash.Progress.Caption = lcComment + IIF(llSuccess, " succeed.", " failed!")
			ENDIF
			IF g_CryptorObject.lMadeChanges
				g_CryptorObject.LogData(lcComment + " database ..." + IIF(llSuccess, " succeed.", " failed!"))
				g_CryptorObject.lMadeChanges = .F.
			ENDIF
		ENDIF
	ENDIF
	g_CryptorObject.lShowMessage = .F.
	g_CryptorObject.lLogMessage = .F.
	g_CryptorObject.cBackupDir = ""
ELSE
	* Check if table is marked in fi_flag with "X" as not encrypted
	IF g_CryptorObject.CheckTable("files")
		lcFilesAlias = SYS(2015)
		lcTmpFiles = SYS(2015)
		USE (tcDefaultPath + "files") IN 0 AGAIN ALIAS &lcTmpFiles SHARED
		SELECT DISTINCT fi_name, fi_path, fi_flag FROM &lcTmpFiles ;
			WHERE fi_name = PADR(UPPER(tcTableName),8) AND "X" $ fi_flag ;
			ORDER BY fi_path, fi_name ;
			INTO CURSOR &lcFilesAlias
		IF RECCOUNT()>0
			l_lEncrypted = .F.
		ENDIF
		USE
		USE IN &lcTmpFiles
		
		IF l_lEncrypted
			* OK, table is marked as encrypted
			llSuccess = &lcCommand(tcTableName, tcDefaultPath)
		ENDIF
	ENDIF
ENDIF

SELECT (lnArea)

RETURN llSuccess
ENDPROC

**************************************************
*-- Class Library:  proccryptor.prg
**************************************************


**************************************************
*-- Class:        cryptor (proccryptor.prg)
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Time Stamp:   06/02/08 03:53:13 PM
*
*
DEFINE CLASS Cryptor AS Custom
	PROTECTED ckey
	ckey = ""
	PROTECTED nmethod
	nmethod = 0
	PROTECTED oxitechcryptorobject
	oxitechcryptorobject = .NULL.
	PROTECTED cdefaultpath
	cdefaultpath = ""
	PROTECTED cerrorlogfilename
	cerrorlogfilename = "Crypt.log"
	cbackupdir = ""
	Name = "cryptor"
	lshowmessage = .F.
	llogmessage = .F.
	lrepaircorrupted = .F.
	lmadechanges = .F.


	PROCEDURE Init
		LPARAMETERS tcDefaultPath, tcKey, tnMethod, tcErrorLogFilename

		IF PCOUNT() < 3 OR EMPTY(tcKey)
			RETURN .F.
		ENDIF

		IF NOT EMPTY(tcErrorLogFilename)
			this.cErrorLogFilename = tcErrorLogFilename
		ENDIF

		this.oXitechCryptorObject = CREATEOBJECT("XitechCryptor.Cryptor")
		IF VARTYPE(this.oXitechCryptorObject) <> "O"
			RETURN .F.
		ENDIF

		this.WatchDLL()

		this.cDefaultPath = tcDefaultPath
		this.cKey = tcKey
		this.nMethod = tnMethod
	ENDPROC


	PROCEDURE Destroy
		this.oXitechCryptorObject = .NULL.
	ENDPROC


	PROCEDURE Error
		LPARAMETERS tnError, tcMethod, tnLine

		DO CASE
			CASE INLIST(tnError, 1426, 1733)
				this.MsgBox("Cryptor module was not properly instaled.")
		ENDCASE

		this.LogError(tnError)
	ENDPROC


	PROTECTED PROCEDURE watchdll
		this.oXitechCryptorObject.WatchDLL("VFP7.EXE")		&& Visual FoxPro 7.0 IDE
		this.oXitechCryptorObject.WatchDLL("VFP7R.DLL")		&& Visual FoxPro 7.0 Runtime
		this.oXitechCryptorObject.WatchDLL("VFP7T.DLL")		&& Visual FoxPro 7.0 Runtime MT
		this.oXitechCryptorObject.WatchDLL("VFP8.EXE")		&& Visual FoxPro 8.0 IDE
		this.oXitechCryptorObject.WatchDLL("VFP8R.DLL")		&& Visual FoxPro 8.0 Runtime
		this.oXitechCryptorObject.WatchDLL("VFP8T.DLL")		&& Visual FoxPro 8.0 Runtime MT
		this.oXitechCryptorObject.WatchDLL("VFP9.EXE")		&& Visual FoxPro 9.0 IDE
		this.oXitechCryptorObject.WatchDLL("VFP9R.DLL")		&& Visual FoxPro 9.0 Runtime
		this.oXitechCryptorObject.WatchDLL("VFP9T.DLL")		&& Visual FoxPro 9.0 Runtime MT
	ENDPROC


	PROCEDURE decode
		LPARAMETERS tcFileName, tcPath, tcKey, tnMethod
		LOCAL lcFullPath, lnErrorCode

		IF EMPTY(tcPath)
			tcPath = this.cDefaultPath
		ENDIF
		IF EMPTY(tcKey)
			tcKey = this.cKey
		ENDIF
		IF EMPTY(tnMethod)
			tnMethod = this.nMethod
		ENDIF

		lcFullPath = FULLPATH(ADDBS(tcPath) + tcFileName)
		IF FILE(lcFullPath)
			this.LogData("Decoding " + UPPER(lcFullPath) + ".")
			lnErrorCode = this.oXitechCryptorObject.DecodeFile(lcFullPath, tcKey, tnMethod)
			IF lnErrorCode = CRYPTOR_ERR_SUCCESS AND NOT this.lMadeChanges
				this.lMadeChanges = .T.
			ENDIF
			this.LogError(lnErrorCode)
		ELSE
			lnErrorCode = CRYPTOR_ERR_FAILED_OPEN_SRC
		ENDIF

		RETURN lnErrorCode
	ENDPROC


	PROCEDURE decodetable
		LPARAMETERS tcTableName, tcPath, tcKey, tnMethod, tlForce
		LOCAL llSuccess, lnErrorCode

		llSuccess = tlForce OR this.CheckTable(tcTableName, tcPath, tcKey, tnMethod)
		IF tlForce OR llSuccess AND this.IsCrypted(.T., tcTableName, tcPath, tcKey, tnMethod)
			IF this.lShowMessage
				WAIT "Decoding " + UPPER(tcTableName) + " table." WINDOW NOWAIT
			ENDIF
			lnErrorCode = this.Decode(FORCEEXT(tcTableName, "dbf"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
			lnErrorCode = this.Decode(FORCEEXT(tcTableName, "cdx"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
			lnErrorCode = this.Decode(FORCEEXT(tcTableName, "fpt"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
			* Unregister a table.
			llSuccess = llSuccess AND this.UnregisterTable(tcTableName, tcPath)
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE encode
		LPARAMETERS tcFileName, tcPath, tcKey, tnMethod
		LOCAL lcFullPath, lnErrorCode

		IF EMPTY(tcPath)
			tcPath = this.cDefaultPath
		ENDIF
		IF EMPTY(tcKey)
			tcKey = this.cKey
		ENDIF
		IF EMPTY(tnMethod)
			tnMethod = this.nMethod
		ENDIF

		lcFullPath = FULLPATH(ADDBS(tcPath) + tcFileName)
		IF FILE(lcFullPath)
			this.LogData("Encoding " + UPPER(lcFullPath) + ".")
			lnErrorCode = this.oXitechCryptorObject.EncodeFile(lcFullPath, tcKey, tnMethod)
			IF lnErrorCode = CRYPTOR_ERR_SUCCESS AND NOT this.lMadeChanges
				this.lMadeChanges = .T.
			ENDIF
			this.LogError(lnErrorCode)
		ELSE
			lnErrorCode = CRYPTOR_ERR_FAILED_OPEN_SRC
		ENDIF

		RETURN lnErrorCode
	ENDPROC


	PROCEDURE encodetable
		LPARAMETERS tcTableName, tcPath, tcKey, tnMethod
		LOCAL llSuccess, lnErrorCode

		llSuccess = this.CheckTable(tcTableName, tcPath, tcKey, tnMethod)
		IF llSuccess AND NOT this.IsCrypted(.F., tcTableName, tcPath, tcKey, tnMethod)
			IF this.lShowMessage
				WAIT "Encoding " + UPPER(tcTableName) + " table." WINDOW NOWAIT
			ENDIF
			lnErrorCode = this.Encode(FORCEEXT(tcTableName, "dbf"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
			lnErrorCode = this.Encode(FORCEEXT(tcTableName, "cdx"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
			lnErrorCode = this.Encode(FORCEEXT(tcTableName, "fpt"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
			* Register a table.
			llSuccess = llSuccess AND this.RegisterTable(tcTableName, tcPath, tcKey, tnMethod)
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE register
		LPARAMETERS tcFileName, tcPath, tcKey, tnMethod
		LOCAL lcFullPath, lnErrorCode

		IF EMPTY(tcPath)
			tcPath = this.cDefaultPath
		ENDIF
		IF EMPTY(tcKey)
			tcKey = this.cKey
		ENDIF
		IF EMPTY(tnMethod)
			tnMethod = this.nMethod
		ENDIF

		lcFullPath = FULLPATH(ADDBS(tcPath) + tcFileName)
		IF FILE(lcFullPath)
			lnErrorCode = this.oXitechCryptorObject.Register(lcFullPath, tcKey, tnMethod)
			this.LogError(lnErrorCode)
		ELSE
			lnErrorCode = CRYPTOR_ERR_FAILED_OPEN_SRC
		ENDIF

		RETURN lnErrorCode
	ENDPROC


	PROCEDURE registertable
		LPARAMETERS tcTableName, tcPath, tcKey, tnMethod
		LOCAL llSuccess, lnErrorCode

		llSuccess = .T.
		IF NOT this.IsRegistered(tcTableName, tcPath, tcKey, tnMethod)
			IF this.lShowMessage
				WAIT "Registering " + UPPER(tcTableName) + " table." WINDOW NOWAIT
			ENDIF
			lnErrorCode = this.Register(FORCEEXT(tcTableName, "dbf"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_ALREADY_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
			lnErrorCode = this.Register(FORCEEXT(tcTableName, "cdx"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_ALREADY_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
			lnErrorCode = this.Register(FORCEEXT(tcTableName, "fpt"), tcPath, tcKey, tnMethod)
			llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_ALREADY_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE unregister
		LPARAMETERS tcFileName, tcPath
		LOCAL lcFullPath, lnErrorCode

		IF EMPTY(tcPath)
			tcPath = this.cDefaultPath
		ENDIF

		lcFullPath = FULLPATH(ADDBS(tcPath) + tcFileName)
		IF FILE(lcFullPath)
			lnErrorCode = this.oXitechCryptorObject.Unregister(lcFullPath)
		ELSE
			lnErrorCode = CRYPTOR_ERR_FAILED_OPEN_SRC
		ENDIF

		RETURN lnErrorCode
	ENDPROC


	PROCEDURE unregistertable
		LPARAMETERS tcTableName, tcPath
		LOCAL llSuccess, lnErrorCode

		lnErrorCode = this.Unregister(FORCEEXT(tcTableName, "dbf"), tcPath)
		llSuccess = INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_NOT_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
		lnErrorCode = this.Unregister(FORCEEXT(tcTableName, "cdx"), tcPath)
		llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_NOT_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
		lnErrorCode = this.Unregister(FORCEEXT(tcTableName, "fpt"), tcPath)
		llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_NOT_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)

		RETURN llSuccess
	ENDPROC


	PROCEDURE setproperty
		LPARAMETERS tcPropertyName, tvValue

		this.oXitechCryptorObject.&tcPropertyName = tvValue
	ENDPROC


	PROCEDURE getproperty
		LPARAMETERS tcPropertyName

		RETURN this.oXitechCryptorObject.&tcPropertyName
	ENDPROC


	PROCEDURE logdata
		LPARAMETERS tcMessage
		#DEFINE TIMELOGACTION	"Time: " + TTOC(DATETIME()) + " Action: "

		IF this.lLogMessage AND NOT EMPTY(this.cErrorLogFilename)
			STRTOFILE(TIMELOGACTION + tcMessage + CRLF, this.cErrorLogFilename, 1)
		ENDIF
	ENDPROC


	PROTECTED PROCEDURE logerror
		LPARAMETERS tnError
		#DEFINE TIMELOGERRORACTION	"Time: " + TTOC(DATETIME()) + " Error: " + ALLTRIM(STR(tnError)) + " Message: "
		LOCAL lcMessage

		DO CASE
			CASE tnError = CRYPTOR_ERR_SUCCESS
				RETURN
			CASE tnError < CRYPTOR_ERR_SUCCESS AND VARTYPE(this.oXitechCryptorObject) == "O"
				lcMessage = this.oXitechCryptorObject.GetErrorMessage(tnError)
			CASE INLIST(tnError, 1426, 1733)
				lcMessage = "Cryptor module was not properly instaled."
			OTHERWISE
				lcMessage = MESSAGE()
		ENDCASE

		IF NOT EMPTY(lcMessage) AND this.lLogMessage AND NOT EMPTY(this.cErrorLogFilename)
			STRTOFILE(TIMELOGERRORACTION + lcMessage + CRLF, this.cErrorLogFilename, 1)
		ENDIF
	ENDPROC


	PROCEDURE cbackupdir_assign
		LPARAMETERS tcBackupPath
		IF NOT EMPTY(tcBackupPath)
			LOCAL llLogMessage
			llLogMessage = this.lLogMessage
			this.lLogMessage = .T.
			this.LogData("Back up folder is " + UPPER(tcBackupPath) + ".")
			this.lLogMessage = llLogMessage
		ENDIF
		this.cBackupDir = tcBackupPath
	ENDPROC


	PROCEDURE backuptable
		LPARAMETERS tcTableName, tcPath
		LOCAL lcFullFileName, lcBackupFileName

		IF EMPTY(this.cBackupDir)
			RETURN .T.
		ENDIF

		IF EMPTY(tcPath)
			tcPath = this.cDefaultPath
		ENDIF

		lcFullFileName = FULLPATH(ADDBS(tcPath) + FORCEEXT(tcTableName, "*"))
		lcBackupFileName = FULLPATH(ADDBS(this.cBackupDir) + FORCEEXT(tcTableName, "*"))

		IF NOT DIRECTORY(this.cBackupDir)
			MD (this.cBackupDir)
		ENDIF
		IF NOT FILE(FORCEEXT(lcBackupFileName, "dbf"))
			COPY FILE (lcFullFileName) TO (lcBackupFileName)
		ENDIF

		RETURN .T.
	ENDPROC


	PROCEDURE checktable
		LPARAMETERS tcTableName, tcPath, tcKey, tnMethod
		LOCAL llSuccess, lcFullPath, lcDBFFile

		IF EMPTY(tcPath)
			tcPath = this.cDefaultPath
		ENDIF

		lcFullPath = FULLPATH(ADDBS(tcPath) + tcTableName)
		lcDBFFile = FORCEEXT(lcFullPath, "dbf")

		llSuccess = .T.
		IF FILE(lcDBFFile)
			lnErrorCode = this.TryTable(lcDBFFile)
			IF lnErrorCode = CRYPTOR_ERR_NOT_TABLE
				* Table could be crypted. Register first and try again.
				this.RegisterTable(tcTableName, tcPath, tcKey, tnMethod)
				lnErrorCode = this.TryTable(lcDBFFile)
			ENDIF
			IF lnErrorCode # CRYPTOR_ERR_SUCCESS
				* There is an error.
				llSuccess = .F.
			ENDIF
		ENDIF

		IF llSuccess
			* Table is OK or not exists.
			RETURN .T.
		ENDIF

		llSuccess = this.RepairTable(lcFullPath, tcKey, tnMethod)

		RETURN llSuccess
	ENDPROC


	PROCEDURE repairtable
		LPARAMETERS tcFullPath, tcKey, tnMethod
		LOCAL lcTableName, lcPath, lcDBFFile, lcFPTFile, lcCDXFile
		LOCAL lnErrorCode, llSuccess, llCrypted, llShowMessage, llLogMessage

		lcTableName = JUSTSTEM(tcFullPath)
		lcPath = JUSTPATH(tcFullPath)
		lcDBFFile = FORCEEXT(tcFullPath, "dbf")
		lcCDXFile = FORCEEXT(tcFullPath, "cdx")
		lcFPTFile = FORCEEXT(tcFullPath, "fpt")

		llShowMessage = this.lShowMessage
		this.lShowMessage = .F.
		llLogMessage = this.lLogMessage
		this.lLogMessage = .F.

		llSuccess = this.UnregisterTable(lcTableName, lcPath)

		IF FILE(lcDBFFile)
			lnErrorCode = this.TryTable(lcDBFFile)
			IF lnErrorCode = CRYPTOR_ERR_SUCCESS
				* Table is not crypted and all is OK.
				this.lShowMessage = llShowMessage
				this.lLogMessage = llLogMessage
				RETURN .T.
			ENDIF

			llCrypted = NOT INLIST(lnErrorCode, CRYPTOR_ERR_FPT_INVALID, CRYPTOR_ERR_CDX_INVALID, CRYPTOR_ERR_CDX_MISSING)

			***** Check DBF file *****
			IF llCrypted
				* Table is crypted or corrupted. Register only DBF file.
				lnErrorCode = this.Register(JUSTFNAME(lcDBFFile), lcPath, tcKey, tnMethod)
				llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_ALREADY_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
			ENDIF

			lnErrorCode = this.TryTable(lcDBFFile)
			IF NOT INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FPT_INVALID, CRYPTOR_ERR_CDX_INVALID, CRYPTOR_ERR_CDX_MISSING)
				IF llCrypted
					* Table is corrupted. Unregister DBF file.
					lnErrorCode = this.Unregister(JUSTFNAME(lcDBFFile), lcPath)
					llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_NOT_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
				ENDIF
				this.lLogMessage = llLogMessage
				this.lShowMessage = llShowMessage
				llSuccess = this.TryToRepairCorruptedTable(lcDBFFile, tcKey, tnMethod)
				RETURN llSuccess
			ENDIF
		ELSE
			* Table is not exists.
			this.lLogMessage = llLogMessage
			this.lShowMessage = llShowMessage
			RETURN .T.
		ENDIF

		***** Check FPT file *****
		IF FILE(lcFPTFile)
			IF llCrypted
				IF lnErrorCode # CRYPTOR_ERR_FPT_INVALID
					* Table is crypted, but memo file is not crypted. Encode only FPT file.
					lnErrorCode = this.Encode(JUSTFNAME(lcFPTFile), lcPath, tcKey, tnMethod)
					llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
				ENDIF
				* Table is crypted. Register FPT file.
				lnErrorCode = this.Register(JUSTFNAME(lcFPTFile), lcPath, tcKey, tnMethod)
				llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_ALREADY_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
			ELSE
				IF lnErrorCode = CRYPTOR_ERR_FPT_INVALID
					* Table is not crypted, but memo file is crypted or corrupted. Decode only FPT file.
					lnErrorCode = this.Decode(JUSTFNAME(lcFPTFile), lcPath, tcKey, tnMethod)
					llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
				ENDIF
			ENDIF

			lnErrorCode = this.TryTable(lcDBFFile)
			IF lnErrorCode = CRYPTOR_ERR_FPT_INVALID
				IF llCrypted
					* Memo file is corrumted. Unregister DBF and FPT files.
					llSuccess = this.UnregisterTable(tcTableName, tcPath)
				ENDIF
				this.lLogMessage = llLogMessage
				this.lShowMessage = llShowMessage
				llSuccess = this.TryToRepairCorruptedTable(lcDBFFile, tcKey, tnMethod)
				RETURN llSuccess
			ENDIF
		ENDIF

		***** Check CDX file *****
		IF FILE(lcCDXFile)
			IF llCrypted
				IF NOT INLIST(lnErrorCode, CRYPTOR_ERR_CDX_INVALID, CRYPTOR_ERR_CDX_MISSING)
					* Table is crypted, but index file is not crypted. Encode only CDX file.
					lnErrorCode = this.Encode(JUSTFNAME(lcCDXFile), lcPath, tcKey, tnMethod)
					llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
				ENDIF
				* Table is crypted. Register a CDX file.
				lnErrorCode = this.Register(JUSTFNAME(lcCDXFile), lcPath, tcKey, tnMethod)
				llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_ALREADY_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
			ELSE
				IF INLIST(lnErrorCode, CRYPTOR_ERR_CDX_INVALID, CRYPTOR_ERR_CDX_MISSING)
					* Table is not crypted, but index file is crypted or corrupted. Decode only CDX file.
					lnErrorCode = this.Decode(JUSTFNAME(lcCDXFile), lcPath, tcKey, tnMethod)
					llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_FAILED_OPEN_SRC)
				ENDIF
			ENDIF

			lnErrorCode = this.TryTable(lcDBFFile)
			IF lnErrorCode # CRYPTOR_ERR_SUCCESS
				IF llCrypted
					* CDX file is corrupted. Unregister and delete a CDX file.
					lnErrorCode = this.Unregister(JUSTFNAME(lcCDXFile), lcPath)
					llSuccess = llSuccess AND INLIST(lnErrorCode, CRYPTOR_ERR_SUCCESS, CRYPTOR_ERR_NOT_REGISTERED, CRYPTOR_ERR_FAILED_OPEN_SRC)
				ENDIF
				DELETE FILE (lcCDXFile)
			ENDIF
		ENDIF

		IF lnErrorCode # CRYPTOR_ERR_SUCCESS
			lnErrorCode = this.TryTable(lcDBFFile)
		ENDIF

		this.lLogMessage = llLogMessage
		this.lShowMessage = llShowMessage

		IF lnErrorCode = CRYPTOR_ERR_SUCCESS
			* Table is OK.
			RETURN .T.
		ELSE
			* Table is corrupted.
			llSuccess = this.TryToRepairCorruptedTable(lcDBFFile, tcKey, tnMethod)
			RETURN llSuccess
		ENDIF
	ENDPROC


	PROCEDURE trytorepaircorruptedtable
		LPARAMETERS tcFullPath, tcKey, tnMethod
		LOCAL llSuccess, lcTableName, lcPath

		this.LogData("Corrupted table " + UPPER(tcFullPath) + ".")

		IF this.lRepairCorrupted
			lcTableName = JUSTSTEM(tcFullPath)
			lcPath = JUSTPATH(tcFullPath)
			llSuccess = this.ModifyFile(tcFullPath, 1, 2, "")
			IF llSuccess
				llSuccess = this.RegisterTable(lcTableName, lcPath, tcKey, tnMethod)
			ENDIF
			llSuccess = (CRYPTOR_ERR_SUCCESS = this.TryTable(tcFullPath))
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE modifyfile
		LPARAMETERS tcFullPath, tnStartReplacement, tnCharactersReplaced, tcReplacement
		LOCAL llSuccess, lnBytes, lcContent, lcBackupFile, lcSafety

		IF FILE(tcFullPath)
			lcBackupFile = FORCEEXT(tcFullPath, "bak")
			lcSafety = SET("Safety")
			SET SAFETY OFF
			COPY FILE (tcFullPath) TO (lcBackupFile)
			DELETE FILE (tcFullPath)
			lcContent = FILETOSTR(lcBackupFile)
			lcContent = STUFF(lcContent, tnStartReplacement, tnCharactersReplaced, tcReplacement)
			lnBytes = STRTOFILE(lcContent, tcFullPath)
			SET SAFETY &lcSafety
			IF lnBytes = LEN(lcContent)
				this.LogData("Table " + UPPER(tcFullPath) + " has been modified.")
				llSuccess = .T.
			ELSE
				this.LogData("Table " + UPPER(tcFullPath) + " couldn't be recovered.")
			ENDIF
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE iscrypted
		LPARAMETERS tlCheckForDecoding, tcTableName, tcPath, tcKey, tnMethod
		LOCAL llCrypted, lnErrorCode, llShowMessage, llLogMessage

		llShowMessage = this.lShowMessage
		this.lShowMessage = .F.
		llLogMessage = this.lLogMessage
		this.lLogMessage = .F.

		IF tlCheckForDecoding
			llCrypted = .F.
			lnErrorCode = this.Register(FORCEEXT(tcTableName, "dbf"), tcPath, tcKey, tnMethod)
			DO CASE
				CASE lnErrorCode = CRYPTOR_ERR_ALREADY_REGISTERED
					llCrypted = .T.
				CASE lnErrorCode = CRYPTOR_ERR_SUCCESS
					this.Unregister(FORCEEXT(tcTableName, "dbf"), tcPath)
				OTHERWISE
			ENDCASE
		ELSE
			llCrypted = .T.
			lnErrorCode = this.Unregister(FORCEEXT(tcTableName, "dbf"), tcPath)
			DO CASE
				CASE lnErrorCode = CRYPTOR_ERR_NOT_REGISTERED
					llCrypted = .F.
				CASE lnErrorCode = CRYPTOR_ERR_SUCCESS
					this.Register(FORCEEXT(tcTableName, "dbf"), tcPath, tcKey, tnMethod)
				OTHERWISE
			ENDCASE
		ENDIF

		this.lLogMessage = llLogMessage
		this.lShowMessage = llShowMessage

		RETURN llCrypted
	ENDPROC


	PROCEDURE isregistered
		LPARAMETERS tcTableName, tcPath, tcKey, tnMethod
		LOCAL llIsRegistered, lnErrorCode, llShowMessage, llLogMessage

		llShowMessage = this.lShowMessage
		this.lShowMessage = .F.
		llLogMessage = this.lLogMessage
		this.lLogMessage = .F.

		lnErrorCode = this.Register(FORCEEXT(tcTableName, "dbf"), tcPath, tcKey, tnMethod)
		DO CASE
			CASE lnErrorCode = CRYPTOR_ERR_ALREADY_REGISTERED
				llIsRegistered = .T.
			CASE lnErrorCode = CRYPTOR_ERR_SUCCESS
				this.Unregister(FORCEEXT(tcTableName, "dbf"), tcPath)
			OTHERWISE
		ENDCASE

		this.lLogMessage = llLogMessage
		this.lShowMessage = llShowMessage

		RETURN llIsRegistered
	ENDPROC


	PROTECTED PROCEDURE trytable
		LPARAMETERS tcDBFFile
		LOCAL lnErrorCode, lcAlias
		LOCAL loException AS Exception

		lcAlias = SYS(2015)
		TRY
			USE (tcDBFFile) IN 0 ALIAS &lcAlias SHARED AGAIN
			lnErrorCode = CRYPTOR_ERR_SUCCESS
			USE IN &lcAlias
		CATCH TO loException
			lnErrorCode = loException.ErrorNo
		ENDTRY

		RETURN lnErrorCode
	ENDPROC


	PROCEDURE msgbox
		LPARAMETERS tcMessageText
		IF TYPE("frmSplash") = "O"
			frmSplash.Visible = .F.
		ENDIF
		MESSAGEBOX(tcMessageText, 48, "Information", 20000)
		IF TYPE("frmSplash") = "O"
			frmSplash.Visible = .T.
		ENDIF
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cryptor
**************************************************