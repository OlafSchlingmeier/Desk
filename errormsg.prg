 LPARAMETER ctExt, lcLeanup, cfIlename
 LOCAL nhAndle
 IF (PCOUNT()<3)
      IF EMPTY(_screen.oGlobal.choteldir)
           cfIlename = g_setdef+"\Hotel.Err"
      ELSE
           cfIlename = _screen.oGlobal.choteldir+"Hotel.Err"
      ENDIF
 ELSE
      cfIlename = _screen.oGlobal.choteldir+cfIlename
 ENDIF
 IF ( .NOT. FILE(cfIlename))
      nhAndle = FCREATE(cfIlename, 0)
 ELSE
      nhAndle = FOPEN(cfIlename, 2)
 ENDIF
 IF (nhAndle<>-1)
      = FSEEK(nhAndle, 0, 2)
      = FPUTS(nhAndle, DTOC(DATE())+" "+TIME()+" "+wiNpc()+" "+IIF(TYPE("g_userid")="C",g_userid,"@"))
      = FPUTS(nhAndle, STRTRAN(ctExt, ";", (CHR(13)+CHR(10))))
      = FPUTS(nhAndle, "")
      = FPUTS(nhAndle, "")
      = FCLOSE(nhAndle)
 ENDIF
 IF (lcLeanup)
      = clEanup()
 ENDIF
 RETURN .T.
ENDFUNC
*
