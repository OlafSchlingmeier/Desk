*
FUNCTION ODBC
LOCAL llODBC

DO CASE
	CASE TYPE("plTemporalOdbcForArchiving") = "L" AND plTemporalOdbcForArchiving	&& Archiving sequence
		llODBC = .T.
	OTHERWISE
		llODBC = _screen.oGlobal.lODBC
ENDCASE

RETURN llODBC
ENDFUNC
*
PROCEDURE InstallDriver
LOCAL loShell, lcDriverPath

IF YesNo(GetLangText("ARCHIVE","TA_INSTALL_PGODBC_DRIVER"))	&& Do you want to install ODBC driver
	lcDriverPath = GETFILE("exe","","",0,"Find PostgreSQL driver (psqlodbc-setup.exe)")
	IF NOT EMPTY(lcDriverPath)
		loShell = CREATEOBJECT("Wscript.Shell")
		loShell.Run(lcDriverPath,0,.T.)
	ENDIF
ENDIF

RETURN .T.
ENDPROC
*
FUNCTION SetODBC
LPARAMETERS lp_lODBC
_screen.oGlobal.lODBC = lp_lODBC
ENDFUNC
*