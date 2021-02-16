*
PROCEDURE DDelete
 PARAMETER pcAlias
 PRIVATE naRea
 IF EMPTY(pcAlias)
      pcAlias = ALIAS()
 ENDIF
 naRea = SELECT()
 SELECT (pcAlias)
 DELETE
 FLUSH
 SELECT (naRea)
 RETURN
ENDPROC
*
