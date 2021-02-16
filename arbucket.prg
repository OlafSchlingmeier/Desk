*
FUNCTION ArBucket
 PARAMETER pdInvoice, plDispute
 PRIVATE nbUcket
 nbUcket = 1
 DO CASE
      CASE plDispute
           nbUcket = 7
      CASE pdInvoice>sySdate()-paRam.pa_arage1
           nbUcket = 1
      CASE pdInvoice<=sySdate()-paRam.pa_arage1 .AND. pdInvoice>sySdate()- ;
           paRam.pa_arage2
           nbUcket = 2
      CASE pdInvoice<=sySdate()-paRam.pa_arage2 .AND. pdInvoice>sySdate()- ;
           paRam.pa_arage3
           nbUcket = 3
      CASE pdInvoice<=sySdate()-paRam.pa_arage3 .AND. pdInvoice>sySdate()- ;
           paRam.pa_arage4
           nbUcket = 4
      CASE pdInvoice<=sySdate()-paRam.pa_arage4 .AND. pdInvoice>sySdate()- ;
           paRam.pa_arage5
           nbUcket = 5
      CASE pdInvoice<=sySdate()-paRam.pa_arage5
           nbUcket = 6
 ENDCASE
 RETURN nbUcket
ENDFUNC
*
