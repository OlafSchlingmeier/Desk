 PARAMETER pcText
 PRIVATE i, nlEn, lrEt
 pcText = ALLTRIM(pcText)
 nlEn = LEN(pcText)
 IF nlEn>0
      lrEt = .T.
      FOR i = 1 TO nlEn
           IF  .NOT. ISDIGIT(SUBSTR(pcText, i, 1))
                lrEt = .F.
                EXIT
           ENDIF
      ENDFOR
 ELSE
      lrEt = .F.
 ENDIF
 RETURN lrEt
ENDFUNC
*
