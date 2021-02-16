 PARAMETER pcAlias
 IF EMPTY(pcAlias)
      pcAlias = ALIAS()
 ENDIF
 UNLOCK IN (pcAlias)
 FLUSH
 RETURN
ENDPROC
*
