**
** strhotkey.fxp
**
*
FUNCTION StrHotKey
 LPARAMETERS pcPrompt
 LOCAL npOs, crEt
 npOs = AT('\<', pcPrompt)
 crEt = ''
 IF npOs>0
      crEt = SUBSTR(pcPrompt, npOs+2, 1)
 ENDIF
 RETURN crEt
ENDFUNC
*
