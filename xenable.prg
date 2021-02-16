*
FUNCTION XEnable
 PARAMETER pcVar, plEnabled
 IF plEnabled
      SHOW GET (pcVar) ENABLE
 ELSE
      &pcVar = Blank(&pcVar)
      SHOW GET (pcVar) DISABLE
 ENDIF
 RETURN .T.
ENDFUNC
*
