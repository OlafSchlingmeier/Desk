*
FUNCTION SqlOrder
LPARAMETERS tcOrder, tcExpression
LOCAL lcRetVal

DO CASE
	CASE EMPTY(tcExpression)
		lcRetVal = tcOrder
	CASE EMPTY(tcOrder) AND NOT EMPTY(tcExpression)
		lcRetVal = tcExpression
	CASE NOT EMPTY(tcOrder) AND NOT EMPTY(tcExpression)
		lcRetVal = tcOrder + "," + tcExpression
ENDCASE

RETURN lcRetVal
ENDFUNC
*