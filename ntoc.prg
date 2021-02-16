 PARAMETER pnNum
 PRIVATE crEt
 IF INT(pnNum)=pnNum
      crEt = LTRIM(STR(pnNum))
 ELSE
      crEt = LTRIM(STR(ROUND(pnNum, 6), 20, 6))
      DO WHILE RIGHT(crEt, 1)='0'
           crEt = SUBSTR(crEt, 1, LEN(crEt)-1)
      ENDDO
 ENDIF
 RETURN crEt
ENDFUNC
*
