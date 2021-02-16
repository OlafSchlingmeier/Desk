* Used to call application from development. This file must not be a project main program.
* main.prg can be called with follwing parameters:
* STRU - Update Brilliant database und languagefile with fields.dbf, files.dbf and language.dbf in update directory
* UPD - Update Brilliant database and language file without fields.dbf and files.dbf in update directory
* @_!%ST1, @_!%ST2 ... @_!%ST6 - Fake windows machine name
* @_!%ORG - use pc real windows name
* g_setremotepath - can be used when working with remote database (in some other folder, not data in project root)

PUBLIC  g_newversionactive, g_testdo, g_debug, g_lNewConferenceActive, ;
	g_lBillMode, g_setremotepath, g_lDevelopment, g_lNoReadEvents
LOCAL l_cProjectDir
IF TYPE("application.ActiveProject.HomeDir")=="C"
	l_cProjectDir = application.ActiveProject.HomeDir
ELSE
	l_cProjectDir = "D:\Code\Main\CitadelDesk"
ENDIF
*PUBLIC g_lTest
*g_lTest = .T.
*g_setremotepath = "forms; bitmap; include; libs; progs; " + l_cProjectDir
g_debug = .t.
g_lDevelopment = .t.
g_lNoReadEvents = .t. && When .T., new status bar is not showed!
*SET PATH TO "data;libs;forms"
SET ESCAPE OFF
SET DEFAULT TO (l_cProjectDir)
IF SET("Asserts")<>"ON"
	SET ASSERTS ON
ENDIF


*********************************
* Show XFRX Version

*LOCAL o
*SET PATH TO "common\progs"
*o = .NULL.
*TRY
*     o = EVALUATE([XFRX("XFRX#INIT")])
*CATCH
*ENDTRY
*IF VARTYPE(o)="O"
*     WAIT WINDOW o.getversion() NOWAIT
*ENDIF

*
*********************************


*********************************
* Auto log as supervisor

*l_cCitadelIniPath = FULLPATH("citadel.ini")
*l_cDatabaseDir = StartReadIni(l_cCitadelIniPath, "System","databasedir", "data")
*l_cParamPath = ADDBS(l_cDatabaseDir) + "param"
*SELECT pa_sysdate FROM (l_cParamPath) INTO ARRAY l_aResult
*dclose("param")
*main("@_!%ST6 SUPERVISOR "+TRANSFORM(YEAR(l_aResult(1))*2+MONTH(l_aResult(1))+DAY(l_aResult(1)))+" 1") && Auto log
*
*********************************

*main("STRU")
*main("UPD")
*main("@_!%ST6 S+P OLI 1") && Auto log
main("@_!%ST6")

*main("DO_BATCH")

RETURN .T.
ENDPROC
*
FUNCTION StartReadIni
LPARAMETERS tcINIFile, tcSection, tuEntry, tcDefault, taEntries
LOCAL lcBuffer, lcDefault, lnSize, luReturn

DECLARE integer GetPrivateProfileString IN Win32API string cSection, string cEntry, string cDefault, string @cBuffer, integer nBufferSize, string cINIFile

lcBuffer = REPLICATE(CHR(0), 256)
lcDefault = IIF(VARTYPE(tcDefault) <> 'C', '', tcDefault)
lnSize = GetPrivateProfileString(tcSection, tuEntry, lcDefault, @lcBuffer, 256, tcINIFile)
lcBuffer = LEFT(lcBuffer, lnSize)
lcBuffer = ALLTRIM(STREXTRACT(lcBuffer,"",";",1,2))
DO CASE
     CASE VARTYPE(tuEntry) = 'C'
          luReturn = lcBuffer
     CASE lnSize = 0
          luReturn = 0
     OTHERWISE
          luReturn = ALINES(taEntries, lcBuffer, .T., CHR(0), CHR(13))
ENDCASE

RETURN luReturn
ENDFUNC