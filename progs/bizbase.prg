#INCLUDE "include\constdefines.h"

**************************************************
*-- Class:        cbizbase (\progs\bizbase.prg)
*-- ParentClass:  _collection (\common\libs\_lbasec.vcx)
*-- BaseClass:    collection
*-- Time Stamp:   29.08.11 13:36:09
*
DEFINE CLASS cbizbase AS _collection


	PROTECTED nerrorcode
	PROTECTED cerror

	nerrorcode = NO_ERROR
	cerror = ""
	ctables = ""
	lbufferedsource = .F.


	PROCEDURE initialize
		LPARAMETERS tcTables
		LOCAL i, lcTables, lcTable

		lcTables = IIF(EMPTY(tcTables), this.cTables, tcTables)

		FOR i = 1 TO GETWORDCOUNT(lcTables,",")
			lcTable = GETWORDNUM(lcTables,i,",")
			this.AddTable(lcTable)
		ENDFOR
	ENDPROC


	PROCEDURE save
		LOCAL loData

		FOR EACH loData IN this
			loData.DoTableUpdate(.T.,.T.)
		ENDFOR

		IF NOT EndTransaction()
			this.nErrorCode = ERR_COMMIT
			this.cError = "Commit error"
		ENDIF
	ENDPROC


	PROCEDURE cursorfill
		LPARAMETERS tcTable, tcFilterClause, tcAlias
		LOCAL loData

		IF EMPTY(tcAlias)
			tcAlias = "cur"+tcTable
		ENDIF

		tcAlias = LOWER(tcAlias)

		IF this.GetKey(tcAlias) = 0
			loData = .NULL.
		ELSE
			loData = this.Item(tcAlias)
			loData.cFilterClause = SqlParse(tcFilterClause,.T.)
			loData.CursorFill()
		ENDIF

		RETURN loData
	ENDPROC


	PROCEDURE cursorrefresh
		LPARAMETERS tcTable, tcAlias
		LOCAL loData

		IF EMPTY(tcAlias)
			tcAlias = "cur"+tcTable
		ENDIF

		tcAlias = LOWER(tcAlias)

		IF this.GetKey(tcAlias) > 0
			loData = this.Item(tcAlias)
			loData.CursorRefresh()
		ENDIF
	ENDPROC


	PROCEDURE geterror
		LPARAMETERS tcError

		tcError = this.cError

		RETURN this.nErrorcode
	ENDPROC


	PROCEDURE reseterror
		this.nErrorCode = NO_ERROR
		this.cError = ""
	ENDPROC


	PROTECTED PROCEDURE opentable
		LPARAMETERS tcTable
		LOCAL lnRecno

		IF NOT USED(tcTable) OR CURSORGETPROP("Buffering",tcTable) <> 5
			IF USED(tcTable)
				lnRecno = RECNO(tcTable)
				DClose(tcTable)
			ENDIF
			OpenFile(,tcTable,,,5)
			IF NOT EMPTY(lnRecno) AND lnRecno < RECCOUNT(tcTable)
				GO lnRecno IN &tcTable
			ENDIF
		ENDIF
	ENDPROC


	PROCEDURE addtable
		LPARAMETERS tcTable, tcAlias
		LOCAL loData

		IF EMPTY(tcAlias)
			tcAlias = "cur"+tcTable
		ENDIF

		tcAlias = LOWER(tcAlias)

		IF this.GetKey(tcAlias) = 0
			this.OpenTable(tcTable)
			loData = CREATEOBJECT("ca"+tcTable)
			loData.Alias = tcAlias
			loData.lBufferedSource = this.lBufferedSource
			loData.lCreateIndexes  = .T.
			this.Add(loData, loData.Alias)
		ENDIF
	ENDPROC


	PROCEDURE gettable
		LPARAMETERS tcAlias
		LOCAL loData

		tcAlias = LOWER(tcAlias)

		IF this.GetKey(tcAlias) = 0
			loData = .NULL.
		ELSE
			loData = this.Item(tcAlias)
		ENDIF

		RETURN loData
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cbizbase
**************************************************

**************************************************
*-- Class:        colModules (\progs\bizbase.prg)
*-- ParentClass:  _collection (\common\libs\_lbasec.vcx)
*-- BaseClass:    collection
*-- Time Stamp:   29.08.11 13:36:09
*
DEFINE CLASS colModules AS _collection


	PROTECTED nerrorcode
	PROTECTED cerror

	nerrorcode = NO_ERROR
	cerror = ""
	cModules = ""	&& bizbase classes delimited with semicolon


	PROCEDURE initmodule
		LPARAMETERS tcModules
		LOCAL i, lcModule

		lcTables = IIF(EMPTY(tcModules), this.cModules, tcModules)

		FOR i = 1 TO GETWORDCOUNT(tcModules,";")
			lcModule = GETWORDNUM(tcModules,i,";")
			this.AddModule(lcModule)
		ENDFOR
	ENDPROC


	PROCEDURE initialize
		LOCAL loModule

		FOR EACH loModule IN this
			loModule.Initialize()
		ENDFOR
	ENDPROC


	PROCEDURE addmodule
		LPARAMETERS tcModule
		LOCAL loModule, lcClass, lcTables

		tcModule = LOWER(tcModule)
		lcClass = ALLTRIM(STREXTRACT(tcModule,"","=",1,2))
		lcTables = ALLTRIM(STREXTRACT(tcModule,"="))

		IF this.GetKey(lcClass) = 0
			loModule = CREATEOBJECT(lcClass)
			IF NOT EMPTY(lcTables)
				loModule.cTables = lcTables
			ENDIF
			this.Add(loModule, tcModule)
		ENDIF
	ENDPROC


	PROCEDURE getmodule
		LPARAMETERS tcClass
		LOCAL loModule

		tcClass = LOWER(tcClass)

		IF this.GetKey(tcClass) = 0
			loModule = .NULL.
		ELSE
			loModule = this.Item(tcClass)
		ENDIF

		RETURN loModule
	ENDPROC


	PROCEDURE geterror
		LPARAMETERS tcError
		LOCAL loModule

		FOR EACH loModule IN this
			this.nErrorcode = loModule.GetError(@tcError)
			this.cError = tcError
			IF this.nErrorcode < NO_ERROR
				EXIT
			ENDIF
		ENDFOR

		RETURN this.nErrorcode
	ENDPROC


	PROCEDURE reseterror
		LOCAL loModule

		FOR EACH loModule IN this
			loModule.ResetError()
		ENDFOR

		this.nErrorCode = NO_ERROR
		this.cError = ""
	ENDPROC


ENDDEFINE
*
*-- EndDefine: colModules
**************************************************