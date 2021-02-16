 PARAMETER pcList
 RETURN MAX(OCCURS(',', lsTclean(pcList))-1, 0)
ENDFUNC
*
