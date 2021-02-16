 PARAMETER pcFile
 PRIVATE cfUll, crEt
 PRIVATE ncOuntbs, nbSfirst, nbSlast, ndOt
 cfUll = UPPER(FULLPATH(pcFile))
 ncOuntbs = OCCURS('\', cfUll)
 nbSfirst = AT('\', cfUll)
 nbSlast = AT('\', cfUll, ncOuntbs)
 ndOt = AT('.', cfUll)
 crEt = SUBSTR(cfUll, nbSlast+1, ndOt-nbSlast-1)
 RETURN crEt
ENDFUNC
*
