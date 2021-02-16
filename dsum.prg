*
FUNCTION DSum
 LPARAMETERS pcAlias, pcForexpr, pcSumexpr
 LOCAL urEt, naRea, nrEc, lcLose
 naRea = SELECT()
 IF  .NOT. USED(pcAlias)
      doPen(pcAlias)
      lcLose = .T.
 ELSE
      lcLose = .F.
 ENDIF
 IF EMPTY(pcForexpr)
      pcForexpr = '.T.'
 ENDIF
 SELECT (pcAlias)
 nrEc = RECNO()
 sum all &pcSumExpr for &pcForExpr to uRet
 GOTO nrEc
 IF lcLose
      dcLose(pcAlias)
 ENDIF
 SELECT (naRea)
 RETURN urEt
ENDFUNC
*
