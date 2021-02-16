 PARAMETER pcList, pnIndex
 PRIVATE npOsstart, npOsend, crEt
 crEt = ''
 IF pnIndex>0
      pcList = lsTclean(pcList)
      npOsstart = AT(',', pcList, pnIndex)
      npOsend = AT(',', pcList, pnIndex+1)
      IF LEN(pcList)>npOsstart
           crEt = SUBSTR(pcList, npOsstart+1, npOsend-npOsstart-1)
      ENDIF
 ENDIF
 RETURN crEt
ENDFUNC
*
