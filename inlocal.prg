 LPARAMETERS pnAmteuro
 LOCAL ncUrrloc, nrAte
 ncUrrloc = paRam.pa_currloc
 IF ncUrrloc=0
      ncUrrloc = 1
 ENDIF
 nrAte = dlOokup('Paymetho','pm_paynum = '+sqLcnv(ncUrrloc),'pm_rate')
 IF nrAte=0
      nrAte = 1
 ENDIF
 RETURN ROUND(pnAmteuro*nrAte, 6)
ENDFUNC
*
