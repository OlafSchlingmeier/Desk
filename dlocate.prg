*FUNCTION DLocate
 LPARAMETER pcAlias, pcExpr, plRemoveOrder
 LOCAL l_cOrder, naRea, lrEt
 naRea = SELECT()
 SELECT (pcAlias)
 IF plRemoveOrder
      l_cOrder = ORDER()
      SET ORDER TO
 ENDIF
 IF EMPTY(pcExpr)
      LOCATE
 ELSE
      LOCATE ALL FOR &pcExpr
 ENDIF
 lrEt = FOUND()
 IF plRemoveOrder
      SET ORDER TO l_cOrder
 ENDIF
 SELECT (naRea)
 RETURN lrEt
ENDFUNC
*