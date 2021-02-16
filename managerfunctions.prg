PROCEDURE GetNextId
LPARAMETERS plcReturnValue, plcField, plcAlias, plcOrder
LOCAL lcOldAlias, lcOldOrder, lcOldRecno
DO CASE
	CASE PCOUNT() = 2
		plcAlias = ALIAS()
	CASE PCOUNT() = 3
	CASE PCOUNT() = 4
		SET ORDER TO plcOrder IN &plcAlias
ENDCASE

lcOldOrder = ORDER(plcAlias)
lcOldRecno = RECNO(plcAlias)
lcOldAlias = ALIAS()

SELECT &plcAlias

GO BOTTOM
plcReturnValue = &plcField + 1

IF NOT EMPTY(lcOldOrder)
	SET ORDER TO lcOldOrder
ENDIF
GO lcOldRecno IN &plcAlias
IF NOT EMPTY(lcOldAlias)
	SELECT &lcOldAlias
ENDIF
RETURN plcReturnValue
ENDPROC
*
PROCEDURE CheckNextId
LPARAMETERS plcReturnValue, pnId, plcAlias, plcOrder
LOCAL lnRecno
lnRecno = RECNO(plcAlias)
plcReturnValue = NOT SEEK(pnId, plcAlias, plcOrder)
GO lnRecno IN &plcAlias
RETURN plcReturnValue
ENDPROC