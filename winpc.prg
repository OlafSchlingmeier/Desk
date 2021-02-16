 PRIVATE ctEmp, npOs
 IF NOT EMPTY(g_cWinPc)
      RETURN g_cWinPc
 ENDIF
 ctEmp = GETENV('BFW_STATION')
 IF  .NOT. EMPTY(ctEmp)
      RETURN UPPER(ctEmp)
 ENDIF
 ctEmp = ALLTRIM(SYS(0))
 npOs = AT('#', ctEmp)
 DO CASE
      CASE ctEmp='1' .OR. ctEmp='#'
           RETURN "STAND ALONE"
      CASE npOs>0
           RETURN ALLTRIM(SUBSTR(ctEmp, 1, npOs-1))
 ENDCASE
 RETURN
ENDFUNC
*
