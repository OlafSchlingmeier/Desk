 LPARAMETER puExpr, plodbc, plForceOdbc
 IF plodbc AND (odbc() OR plForceOdbc)
      RETURN SqlCnvB(puexpr)
 ENDIF
 PRIVATE ctYpe, crEt, cpOint, cdAte
 crEt = ''
 ctYpe = TYPE('puExpr')
 DO CASE
      CASE INLIST(ctYpe,'D','T') AND EMPTY(puExpr)
           crEt = '{}'
      CASE ctYpe='C' .OR. ctYpe='M'
           crEt = '['+puExpr+']'
      CASE ctYpe='D'
           cdAte = DTOS(puExpr)
           crEt = '{^'+SUBSTR(cdAte, 1, 4)+'-'+SUBSTR(cdAte, 5, 2)+'-'+ ;
                  SUBSTR(cdAte, 7, 2)+'}'
      CASE ctYpe='L'
           crEt = IIF(puExpr, '.t.', '.f.')
      CASE ctYpe='N' OR ctYpe='Y'
           IF INT(puExpr)=puExpr
                crEt = LTRIM(STR(puExpr))
           ELSE
                cpOint = SET('point')
                crEt = LTRIM(STR(puExpr, 20, 8))
                crEt = STRTRAN(crEt, cpOint, '.')
                DO WHILE RIGHT(crEt, 1)='0'
                     crEt = SUBSTR(crEt, 1, LEN(crEt)-1)
                ENDDO
                * When converted string is longer as 16 character, that means, we have numeric
                * which has precision greater as 16.
                * In this case, use transform function, becouse numeric value can wrongly have more decimals numbers
                * on end.
                *
                * Example:
                * puExpr = 88094650.201 && ReserId
                * ? STR(puExpr, 20, 8) && Gives back 88094650.20100001
                IF LEN(crEt)>16
                     crEt = TRANSFORM(puExpr)
                     crEt = STRTRAN(crEt, cpOint, '.')
                ENDIF
           ENDIF
      CASE ctype = 'T'
           cret = "{^" + ALLTRIM(STR(YEAR(puexpr))) + "-" + ;
                   ALLTRIM(STR(MONTH(puexpr))) + "-" + ;
                   ALLTRIM(STR(DAY(puexpr))) + " " + ;
                   ALLTRIM(STR(HOUR(puexpr))) + ":" + ;
                   ALLTRIM(STR(MINUTE(puexpr))) + ":" + ;
                   ALLTRIM(STR(SEC(puexpr))) + "}"
 ENDCASE
 RETURN crEt
ENDFUNC
*