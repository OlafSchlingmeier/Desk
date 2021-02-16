 PARAMETER puExpr
 PRIVATE ctYpe, crEt, cpOint
 crEt = ''
 ctYpe = TYPE('puExpr')
 DO CASE
      CASE ctYpe='C' .OR. ctYpe='M'
           crEt = puExpr
      CASE ctYpe='D'
           crEt = DTOC(puExpr)
      CASE ctYpe='L'
           crEt = IIF(puExpr, '.t.', '.f.')
      CASE ctYpe='N'
           IF INT(puExpr)=puExpr
                crEt = LTRIM(STR(puExpr))
           ELSE
                cpOint = SET('point')
                SET POINT TO '.'
                crEt = LTRIM(STR(puExpr, 20, 8))
                DO WHILE RIGHT(crEt, 1)='0'
                     crEt = SUBSTR(crEt, 1, LEN(crEt)-1)
                ENDDO
                SET POINT TO cpOint
           ENDIF
 ENDCASE
 RETURN crEt
ENDFUNC
*
