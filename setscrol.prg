 PARAMETER nmOde, chEader
 PUBLIC ccUrrenttext
 IF (PARAMETERS()==1)
      chEader = GetLangText("MANAGER","TXT_AUDITINFO")
 ENDIF
 ccUrrenttext = ""
 IF (nmOde==0)
      DEFINE WINDOW wsCroll FROM 5, 0 TO WROWS()-5, 60 FONT "Arial", 10  ;
             NOCLOSE NOZOOM TITLE chIldtitle(chEader) IN scReen NOMDI DOUBLE
      ACTIVATE WINDOW NOSHOW wsCroll
      MOVE WINDOW wsCroll CENTER
      SHOW WINDOW wsCroll
      DO paNel WITH 0.5, 0.5, WROWS()-0.5, WCOLS()-0.5, 1
 ELSE
      DEACTIVATE WINDOW wsCroll
      RELEASE WINDOW wsCroll
      = chIldtitle("")
 ENDIF
 RETURN .T.
ENDFUNC
*
