doform('fweekform','forms\weekform')
RETURN
*
PROCEDURE PlanMultiProp
 Doform('mpweekform','forms\weekform','WITH .T.')
ENDPROC
*
PROCEDURE CanDrop
 LPARAMETERS plCancel
 PRIVATE cnEwroomtype, nnEwrate, naDults, ncHilds, daRrival, crAtecode, csEason
 PRIVATE ndOwcurrent, ndOwarrival, caDfld, ccHfld
 cnEwroomtype = roOm.rm_roomtyp
 IF cnEwroomtype=reServat.rs_roomtyp
      RETURN
 ENDIF
 naDults = reServat.rs_adults
 ncHilds = reServat.rs_childs
 crAtecode = STRTRAN(reServat.rs_ratecod, '*', '')
 daRrival = MAX(reServat.rs_arrdate, sySdate())
 csEason = dlOokup('Season','se_date = '+sqLcnv(daRrival),'se_season')
 IF dlOcate('RateCode','rc_ratecod = '+sqLcnv(crAtecode)+ ;
    ' AND (rc_roomtyp = [*] OR rc_roomtyp = '+sqLcnv(cnEwroomtype)+')'+ ;
    ' AND rc_fromdat <= '+sqLcnv(daRrival)+' AND rc_todat > '+ ;
    sqLcnv(daRrival)+' AND (Empty(rc_season) OR rc_season = '+ ;
    sqLcnv(csEason)+')')
      nnEwrate = raTecode.rc_base
      ndOwcurrent = DOW(daRrival, 2)
      ndOwarrival = DOW(daRrival, 2)
      IF SUBSTR(raTecode.rc_weekend, ndOwcurrent, 1)='1' .AND.  ;
         SUBSTR(raTecode.rc_closarr, ndOwarrival, 1)=' '
           caDfld = 'RateCode.rc_wamnt'
           ccHfld = 'RateCode.rc_wcamnt'
      ELSE
           caDfld = 'RateCode.rc_amnt'
           ccHfld = 'RateCode.rc_camnt'
      ENDIF
      IF  .NOT. BETWEEN(naDults, 1, 5) .OR. EVALUATE(caDfld+STR(naDults, 1))==0
           nnEwrate = nnEwrate+EVALUATE(caDfld+'1')*IIF(paRam.pa_chkadts,  ;
                      MAX(naDults, 1), naDults)
      ELSE
           nnEwrate = nnEwrate+EVALUATE(caDfld+STR(MAX(naDults, 1), 1))
      ENDIF
      IF ( .NOT. BETWEEN(ncHilds, 1, 5) .OR. EVALUATE(ccHfld+STR(ncHilds,  ;
         1))==0)
           nnEwrate = nnEwrate+EVALUATE(ccHfld+'1')*ncHilds
      ELSE
           nnEwrate = nnEwrate+EVALUATE(ccHfld+STR(MAX(ncHilds, 1), 1))
      ENDIF
      IF LEFT(reServat.rs_ratecod, 1)<>'*' .AND. nnEwrate<>reServat.rs_rate
           IF yeSno(stRfmt(GetLangText("PLAN","TA_DROPCHANGERATE"), ;
              LTRIM(STR(reServat.rs_rate, 10, paRam.pa_currdec)), ;
              LTRIM(STR(nnEwrate, 10, paRam.pa_currdec))))
                REPLACE reServat.rs_rate WITH nnEwrate
           ELSE
                IF yeSno(stRfmt(GetLangText("PLAN","TA_DROPOVERRIDE"), ;
                   LTRIM(STR(reServat.rs_rate, 10, paRam.pa_currdec))))
                     REPLACE reServat.rs_ratecod WITH '*'+reServat.rs_ratecod
                ELSE
                     plCancel = .T.
                ENDIF
           ENDIF
      ENDIF
 ELSE
      alErt(stRfmt(GetLangText("PLAN","TA_DROPNORATECODE"),TRIM(crAtecode), ;
           TRIM(cnEwroomtype)))
      plCancel = .T.
 ENDIF
ENDPROC
*
