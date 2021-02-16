 LPARAMETER pcAlias
 IF EMPTY(pcAlias)
      RETURN .F.
 ENDIF
 IF USED(pcAlias)
      USE IN (pcAlias)
 ENDIF
 RETURN .T.
ENDPROC
*
