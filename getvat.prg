*
PROCEDURE GetVat
 PARAMETER naRticle, naMount, nvAtgroup1, nvAtgroup2, nvAt1amount, nvAt2amount
 PRIVATE nsElect
 nsElect = SELECT()
 SELECT arTicle
 IF (SEEK(naRticle, "Article"))
      SELECT piCklist
      SET ORDER TO 3
      IF (SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat, 3), "PickList"))
           nvAtgroup1 = arTicle.ar_vat
           IF (paRam.pa_exclvat)
                nvAt1amount = naMount*piCklist.pl_numval/100
           ELSE
                nvAt1amount = (naMount/(100+piCklist.pl_numval))* ;
                              piCklist.pl_numval
           ENDIF
      ENDIF
      nvAtgroup2 = arTicle.ar_vat2
      IF (nvAtgroup2>0)
           IF (SEEK(PADR("VATGROUP", 10)+STR(nvAtgroup2, 3), "PickList"))
                IF (paRam.pa_exclvat)
                     IF paRam.pa_compvat
                          nvAt2amount = (naMount+nvAtamount1)* ;
                                        piCklist.pl_numval/100
                     ELSE
                          nvAt2amount = naMount*piCklist.pl_numval/100
                     ENDIF
                ELSE
                     nvAt2amount = (naMount/(100+piCklist.pl_numval))* ;
                                   piCklist.pl_numval
                ENDIF
           ENDIF
      ENDIF
      SET ORDER IN piCklist TO 1
 ENDIF
 SELECT (nsElect)
 RETURN
ENDPROC
*
