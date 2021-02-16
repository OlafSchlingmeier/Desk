*
FUNCTION ArLic
 PRIVATE ncC, ncOunt, ctMp, nlIc, lrEt
 IF g_Demo
      RETURN .T.
 ENDIF
 ncC = 0
 ctMp = PADR(paRam.pa_hotel, 30)+"CiTaDeL"+PADR(paRam.pa_city, 30)+ ;
        PADR("EXAR", 8)
 FOR ncOunt = 1 TO LEN(ctMp)
      ncC = ncC+(ncOunt*ASC(SUBSTR(ctMp, ncOunt, 1)))
 ENDFOR
 nlIc = paRam.pa_arlic
 IF nlIc<>ncC .OR. nlIc=0
      lrEt = .F.
 ELSE
      lrEt = .T.
 ENDIF
 RETURN lrEt
ENDFUNC
*
