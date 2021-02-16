 PARAMETER pcAlias
 PRIVATE naRea, lrEt
 IF EMPTY(pcAlias)
      pcAlias = ALIAS()
 ENDIF
 naRea = SELECT()
 SELECT (pcAlias)
 APPEND BLANK
 FLUSH
 lrEt = .T.
 SELECT (naRea)
 RETURN lrEt
ENDFUNC
*
