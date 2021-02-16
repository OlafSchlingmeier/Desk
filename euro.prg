 PARAMETER pnAmt, pdPosted
 LOCAL nrAte
 IF paRam.pa_currloc<>0
      nrAte = dlOokup('Paymetho','pm_paynum = '+sqLcnv(paRam.pa_currloc), ;
              'pm_rate')
 ELSE
      nrAte = dlOokup('Paymetho','pm_paynum = 1','pm_rate')
 ENDIF
 IF nrAte=0
      nrAte = 1
 ENDIF
 RETURN ROUND(pnAmt/nrAte, 6)
ENDFUNC
*
