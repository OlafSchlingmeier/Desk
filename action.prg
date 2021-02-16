*
FUNCTION Action
 * Possible actions:
 * 001 - Started, locked record in license.dbf
 * 002 - Unknown
 * 003 - User logging in, found record in license.dbf for station, trying to LOCK
 * 004 - User logged in
 * 006 - Error message
 * 101 - Aborted loging out other workstations
 * 102 - Retry loging out other workstations
 * 999 - Shuting down
 PARAMETER nnUmber
 PRIVATE nhAndle
 LOCAL l_cFile
 PUBLIC g_Userid
 IF (EMPTY(GETENV("BFW_ACTION")))
      l_cFile = _screen.oGlobal.choteldir + "Hotel.Act"
      IF ( .NOT. FILE(l_cFile))
           nhAndle = FCREATE(l_cFile, 0)
      ELSE
           nhAndle = FOPEN(l_cFile, 2)
      ENDIF
      IF (nhAndle<>-1)
           IF (TYPE("g_UserID")<>"C")
                g_Userid = "STARTUP"
           ENDIF
           = FSEEK(nhAndle, 0, 2)
           = FPUTS(nhAndle, TTOC(DATETIME())+' '+PADR(WinPC(),10)+' '+PADR(g_Userid, 10)+' '+PADL(LTRIM(STR(nnUmber)), 3, "0"))
           = FCLOSE(nhAndle)
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*