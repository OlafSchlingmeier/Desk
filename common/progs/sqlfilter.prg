*
FUNCTION SqlFilter
LPARAMETERS tcFilter, tcExpression
LOCAL lcRetVal

DO CASE
	CASE EMPTY(tcExpression)
		lcRetVal = tcFilter
	CASE EMPTY(tcFilter) AND NOT EMPTY(tcExpression)
		lcRetVal = "(" + tcExpression + ")"
	CASE NOT EMPTY(tcFilter) AND NOT EMPTY(tcExpression)
		lcRetVal = tcFilter + " AND (" + tcExpression + ")"
ENDCASE

RETURN lcRetVal
ENDFUNC
*