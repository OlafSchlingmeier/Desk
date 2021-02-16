*
FUNCTION SqlWhere
LPARAMETERS pcwhere, pcexpr
LOCAL cret
DO CASE
     CASE EMPTY(pcexpr)
          cret = pcwhere
     CASE EMPTY(pcwhere) AND !EMPTY(pcexpr)
          cret = " WHERE (" + pcexpr + ")"
     CASE !EMPTY(pcwhere) AND !EMPTY(pcexpr)
          cret = pcwhere + " AND (" + pcexpr + ")"
ENDCASE
RETURN cret
ENDFUNC
*
