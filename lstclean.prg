 PARAMETER pcList
 pcList = STRTRAN(pcList, ' ', '')
 pcList = STRTRAN(pcList, ';', ',')
 pcList = UPPER(ALLTRIM(pcList))
 IF  .NOT. EMPTY(pcList)
      IF LEFT(pcList, 1)<>','
           pcList = ','+pcList
      ENDIF
      IF RIGHT(pcList, 1)<>','
           pcList = pcList+','
      ENDIF
 ENDIF
 RETURN pcList
ENDFUNC
*
