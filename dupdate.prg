*
PROCEDURE DUpdate
 LPARAMETERS pcAlias, pcForexpr, pcFld, puNewval
 LOCAL naRea, nrEc, lcLose
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
 replace all (pcFld) with puNewVal for &pcForExpr
 FLUSH
 GOTO nrEc
 IF lcLose
      dcLose(pcAlias)
 ENDIF
 SELECT (naRea)
ENDPROC
*
