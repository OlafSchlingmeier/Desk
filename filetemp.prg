 LPARAMETER pcExt, plSys
 PRIVATE cdIr, cfIle
 IF EMPTY(pcExt)
      pcExt = 'TMP'
 ENDIF
 cdIr = SYS(2023)+"\"
 cfIle = cdIr+IIF(plSys,SYS(2015),SYS(3))+"."+pcExt
 DO WHILE FILE(cfIle)
      cfIle = cdIr+SYS(3)+"."+pcExt
 ENDDO
 RETURN cfIle
ENDFUNC
*
