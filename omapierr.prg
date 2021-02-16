PROCEDURE omapiErr
PARAMETER mError, mMessage

DO CASE
	CASE mError = 1429
		MESSAGEBOX(GetLangText("ADDRESS","T_MAILNOTSENT"),64,GetLangText("RECURRES","TXT_INFORMATION"))
	CASE mError = 1426 OR mError = 1733
		*MESSAGEBOX(mMessage,64,GetLangText("RECURRES","TXT_INFORMATION"))
		*MESSAGEBOX("Bitte schreiben Sie diese Meldung:"+chr(13)+"MAPI Error no:"+STR(merror)+CHR(13)+"Error Message:"+mMessage,64,"MAPI Call Error")
		*MESSAGEBOX("Bitte schreiben Sie diese Meldung:"+chr(13)+"MAPI Error no:"+STR(merror)+CHR(13)+"Error Message:"+mMessage,64,"MAPI Call Error")
		_screen.olerr = .T.
	OTHERWISE
		MESSAGEBOX("Meldung:"+chr(13)+"Error no:"+STR(merror)+CHR(13)+"Error Message:"+mMessage,64,"MAPI Call Error")
ENDCASE
