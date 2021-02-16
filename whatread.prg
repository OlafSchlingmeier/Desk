 PUBLIC crEaderror
 IF (EMPTY(crEaderror))
      crEaderror = "The value you entered is invalid!"
      WAIT WINDOW TIMEOUT 1 crEaderror
 ELSE
      WAIT WINDOW TIMEOUT 2 crEaderror
 ENDIF
 crEaderror = ""
 RETURN .T.
ENDFUNC
*
