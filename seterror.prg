*
FUNCTION SetError
 PUBLIC lnEterror
 lnEterror = .F.
* IF g_myerrorhandle
 *	RELEASE oerror
 *	PUBLIC oerror
 *	oerror=CREATEOBJECT('_error')
 *	ON ERROR oerror.handle(ERROR(), PROGRAM(), LINENO(),MESSAGE())
* else
	 ON ERROR DO ERRORSYS WITH 	ERROR(),MESSAGE(),PROGRAM(),LINENO(),MESSAGE(1) IN ERRORSYS
* endif
 RETURN .T.
ENDFUNC
*
