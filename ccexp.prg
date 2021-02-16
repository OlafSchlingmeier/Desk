 PARAMETER pcCcexp, pdDeparture, pcCardnumber
 PRIVATE nmOnth, nyEar
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 IF EMPTY(pcCcexp) .OR. pcCcexp="  -  "
      IF  .NOT. EMPTY(pcCardnumber)
           crEaderror = GetLangText("CCEXP","TA_EXPINVALID")
           RETURN .F.
      ELSE
           RETURN .T.
      ENDIF
 ENDIF
 nmOnth = VAL(SUBSTR(pcCcexp, 1, 2))
 nyEar = VAL(SUBSTR(pcCcexp, 4, 2))
 IF BETWEEN(nyEar, 60, 99)
      nyEar = 1900+nyEar
 ELSE
      nyEar = 2000+nyEar
 ENDIF
 IF  .NOT. BETWEEN(nmOnth, 1, 12)
      crEaderror = GetLangText("CCEXP","TA_EXPINVALID")
      RETURN .F.
 ENDIF
 IF (nyEar*100)+nmOnth<(YEAR(pdDeparture)*100)+MONTH(pdDeparture)
      crEaderror = GetLangText("CCEXP","TA_EXPINVALID")
      RETURN .F.
 ENDIF
 RETURN .T.
ENDFUNC
*
