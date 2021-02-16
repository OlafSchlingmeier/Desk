*
FUNCTION DOpen
 PARAMETER pcTable
 PRIVATE lrEt
 IF opEnfile(.F.,pcTable,.F.,.T.)
      lrEt = .T.
      SELECT (pcTable)
 ELSE
      lrEt = .F.
 ENDIF
 RETURN lrEt
ENDFUNC
*
