*
FUNCTION DLookup
 LPARAMETER pcAlias, pcWhere, pcExpr, plCache, plSql

 IF (Odbc() OR plSql) AND NOT _screen.oGlobal.oGData.UseTablesVfp(pcAlias) AND NOT (USED(pcAlias) AND IsCursor(pcAlias))
      RETURN dlookupb(pcAlias, pcWhere, pcExpr)
 ELSE
      pcWhere = SqlParse(pcWhere)
      pcExpr = SqlParse(pcExpr)
 ENDIF
 
 PRIVATE naRea, nrEc, lcLose, urEt
 naRea = SELECT()
 lcLose = .F.
 IF  .NOT. USED(pcAlias)
      lcLose = .T.
      = doPen(pcAlias)
 ENDIF
 SELECT (pcAlias)
 nrEc = RECNO()
 = dlOcate(pcAlias,pcWhere)
 urEt = EVALUATE(pcExpr)
 IF NREC>RECCOUNT()
 	GO BOTT
 ELSE
 GOTO nrEc
 ENDIF
 IF lcLose .AND.  .NOT. plCache
      = dcLose(pcAlias)
 ENDIF
 SELECT (naRea)
 RETURN urEt
ENDFUNC
*
PROCEDURE dlookupb
LPARAMETERS pcalias, pcwhere, pcexpr
RETURN _screen.oGlobal.oGData.dlookupb(pcalias, pcwhere, pcexpr)
ENDPROC