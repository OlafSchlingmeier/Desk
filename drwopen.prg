*
PROCEDURE DrwOpen
 PRIVATE ceRror
 ceRror = ON('error')
 ON ERROR DO DRWERROR
 WAIT WINDOW NOWAIT "Öffnen Kassenlade ..."
* !wlade
 LOCAL LStart
 IF EMPTY(_screen.oGlobal.oterminal.tm_drwexe)
      LStart = "run /N4 wlade.exe"
 ELSE
      LStart = "run /N4 " + ALLTRIM(_screen.oGlobal.oterminal.tm_drwexe)
 ENDIF
 &LStart
 * SET CONSOLE OFF
 * SET PRINTER ON
 * SET PRINTER TO COM2 , 110, N, 8, 1, N, RL 
 * set printer to Name LADE
 * set printer on
 * ? REPLICATE(CHR(85), 20)
 * SET PRINTER TO default
 * SET PRINTER OFF
 * SET CONSOLE ON
 WAIT CLEAR
 on error &cError
 RETURN
ENDPROC
*
PROCEDURE DrwError
 RETURN
ENDPROC
*
