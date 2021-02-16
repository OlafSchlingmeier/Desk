 PARAMETER pnCurrnr, pnCurramt, pnRate, pnCashamt, pcInfo, plExchange
 PRIVATE neUroamt, neUrorate
 PRIVATE naRea, npMrec
 naRea = SELECT()
 SELECT paYmetho
 npMrec = RECNO()
 IF  .NOT. dlOcate('Paymetho','pm_paynum = '+sqLcnv(pnCurrnr))
      = alErt(stRfmt( ;
        "Paymethod %s1 not found for possible Currency Conversion!",pnCurrnr))
 ELSE
      IF paYmetho.pm_paytyp=2
           IF paRam.pa_ineuro .AND. paYmetho.pm_ineuro
                IF paRam.pa_currloc<>0
                     neUrorate = dlOokup('Paymetho','pm_paynum = '+ ;
                                 sqLcnv(paRam.pa_currloc),'pm_rate')
                ELSE
                     neUrorate = dlOokup('Paymetho','pm_paynum = 1','pm_rate')
                ENDIF
                IF paRam.pa_currloc<>0 .AND.  .NOT. plExchange
                     neUroamt = ROUND(pnCurramt/paYmetho.pm_rate, 6)
                     pnCashamt = ROUND(neUroamt*neUrorate, paRam.pa_currdec)
                     pnRate = paYmetho.pm_rate
                     pcInfo = TRIM(paYmetho.pm_paymeth)+' '+ ;
                              LTRIM(STR(pnCurramt, 12, 2))+' / '+ ;
                              ntOc(paYmetho.pm_rate)+' = '+ ;
                              LTRIM(STR(neUroamt, 12, 2))
                ELSE
                     neUroamt = ROUND(pnCurramt/paYmetho.pm_rate, 6)
                     pnCashamt = ROUND(neUroamt*neUrorate, paRam.pa_currdec)
                     pnRate = paYmetho.pm_rate
                     pcInfo = TRIM(paYmetho.pm_paymeth)+' '+ ;
                              LTRIM(STR(pnCurramt, 12, 2))+' / '+ ;
                              ntOc(paYmetho.pm_rate)+' = EUR '+ ;
                              ntOc(neUroamt)+' x '+ntOc(neUrorate)+' = '+ ;
                              LTRIM(STR(pnCashamt, 12, paRam.pa_currdec))
                ENDIF
           ELSE
                pnCashamt = ROUND(pnCurramt*paYmetho.pm_rate, paRam.pa_currdec)
                pnRate = paYmetho.pm_rate
                pcInfo = TRIM(paYmetho.pm_paymeth)+' '+ ;
                         LTRIM(STR(pnCurramt, 12, 2))+' x '+ ;
                         ntOc(paYmetho.pm_rate)+' = '+LTRIM(STR(pnCashamt,  ;
                         12, paRam.pa_currdec))
           ENDIF
      ELSE
           pnCashamt = pnCurramt
           pnRate = 1.000000
           pcInfo = ''
      ENDIF
 ENDIF
 GOTO npMrec IN paYmetho
 SELECT (naRea)
 RETURN
ENDPROC
*
