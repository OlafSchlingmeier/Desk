 PARAMETER puExpr
 PRIVATE ctYpe
 ctYpe = TYPE('puExpr')
 DO CASE
      CASE ctYpe='C'
           RETURN ''
      CASE ctYpe='N'
           RETURN 0
      CASE ctYpe='D'
           RETURN CTOD('')
      CASE ctYpe='L'
           RETURN .F.
 ENDCASE
 RETURN
ENDFUNC
*
