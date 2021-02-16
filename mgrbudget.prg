IF NOT _screen.B2
	do form "forms\BudgetForm"
ELSE
	DO FORM "forms\budgetbaselform"
ENDIF

RETURN .T.