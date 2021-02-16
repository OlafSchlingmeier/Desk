 PARAMETER pcFor, pcExpr
 PRIVATE crEt
 DO CASE
      CASE EMPTY(pcExpr)
           crEt = pcFor
      CASE EMPTY(pcFor) .AND.  .NOT. EMPTY(pcExpr)
           crEt = '('+pcExpr+')'
      CASE  .NOT. EMPTY(pcFor) .AND.  .NOT. EMPTY(pcExpr)
           crEt = pcFor+' AND ('+pcExpr+')'
 ENDCASE
 RETURN crEt
ENDFUNC
*
