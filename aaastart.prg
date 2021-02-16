* Used to call application from development. This file must not be a project main program.
* main.prg can be called with follwing parameters:
* STRU - Update Brilliant database und languagefile with fields.dbf, files.dbf and language.dbf in update directory
* UPD - Update Brilliant database and language file without fields.dbf and files.dbf in update directory
* @_!%ST1, @_!%ST2 ... @_!%ST6 - Fake windows machine name
* g_setremotepath - can be used when working with remote database (in some other folder, not data in project root)

CLEAR ALL
LOCAL l_cDefault
IF TYPE("application.ActiveProject.HomeDir") == "C"
	l_cDefault = application.ActiveProject.HomeDir
ELSE
	l_cDefault = "D:\Code\Main\brilliant907"
ENDIF
PUBLIC g_debug, g_lDevelopment, g_setremotepath
g_debug = .T.
g_lDevelopment = .T.
*g_setremotepath = "forms; bitmap; include; libs; progs; " + l_cDefault
SET PATH TO "data; forms; bitmap; include; libs; progs; " + l_cDefault
SET ESCAPE OFF
SET DEFAULT TO (l_cDefault)
SET SYSMENU TO DEFAULT
SET ASSERTS ON
*ASSERT .f.
*main("stru")
*main("upd")
*main("@_!%ST6 S+P OLI 1") && Auto log
main("@_!%ST6 FR") && Auto log
*main("@_!%ST6")