 PARAMETER pcText, puExpr1, puExpr2, puExpr3, puExpr4, puExpr5
 PRIVATE ntOdo, i
 ntOdo = PCOUNT()-1
 FOR i = 1 TO ntOdo
      pcText = STRTRAN(pcText, '%s'+ntOc(i), cnV(EVALUATE('puExpr'+ntOc(i))))
 ENDFOR
 RETURN pcText
ENDFUNC
*
