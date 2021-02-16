*** 
*** ReFox  XI  #DE110683  Heiko Knabe  Schlingmeier + Partner KG [VFP90]
***
**
PROCEDURE PpVersion
 PARAMETER cversion
 cversion = "2.16"
 RETURN
ENDPROC
**
PROCEDURE _RS02000
 LOCAL narea, nrsrec, nrsord, npsrec, npsord, dfor, nday, nad, nch1, nch2, nch3, nrooms, nrev
 LOCAL crstmp, cpstmp, cidtmp
 LOCAL lcalcrev
 PRIVATE art, aar, armsmax
 SELECT rt_roomtyp FROM RoomType WHERE rt_group=1 AND rt_vwsum INTO ARRAY art
 IF _TALLY=0
    RETURN
 ENDIF
 lcalcrev = TYPE('Min2')='L' AND min2
 SELECT ar_artinum FROM article WHERE ar_artityp=1 AND BETWEEN(ar_main, min3, max3) INTO ARRAY aar
 min1 = MAX(sysdate(), min1)
 narea = SELECT()
 SELECT reservat
 nrsord = ORDER()
 nrsrec = RECNO()
 SELECT post
 npsord = ORDER()
 npsrec = RECNO()
 WAIT WINDOW NOWAIT "Preprocessing..."
 CREATE CURSOR PreProc (pp_date D, pp_rms N (4), pp_ad N (4), pp_ch1 N (4), pp_ch2 N (4), pp_ch3 N (4), pp_maxrms N (4), pp_grms N (4), pp_gad N (4), pp_gch1 N (4), pp_gch2 N (4), pp_gch3 N (4), pp_arrrms N (4), pp_arrad N (4), pp_arrch1 N (4), pp_arrch2 N (4), pp_arrch3 N (4), pp_garrrms N (4), pp_garrad N (4), pp_garrch1 N (4), pp_garrch2 N (4), pp_garrch3 N (4), pp_deprms N (4), pp_depad N (4), pp_depch1 N (4), pp_depch2 N (4), pp_depch3 N (4), pp_gdeprms N (4), pp_gdepad N (4), pp_gdepch1 N (4), pp_gdepch2 N (4), pp_gdepch3 N (4), pp_rev B (2))
 SELECT SUM(av_avail) FROM Availab WHERE BETWEEN(av_date, min1, max1) GROUP BY av_date ORDER BY av_date INTO ARRAY amaxrms
 SELECT preproc
 FOR nday = 0 TO (max1-min1)
    dfor = min1+nday
    SELECT preproc
    APPEND BLANK
    REPLACE pp_date WITH dfor, pp_maxrms WITH amaxrms(nday+1)
 ENDFOR
 RELEASE amaxrms
 IF lcalcrev
    crstmp = filetemp('DBF')
    SELECT reservat
    COPY TO (crstmp) WITH CDX ALL FOR (rs_arrdate<=max1 AND rs_depdate>=min1) AND NOT INLIST(rs_status, 'CXL', 'NS', 'LST') AND ASCAN(art, rs_roomtyp)>0
    USE IN reservat
    USE EXCLUSIVE (crstmp) ALIAS reservat IN 0
    cpstmp = filetemp('DBF')
    SELECT post
    COPY TO (cpstmp) STRUCTURE WITH CDX
    USE IN post
    USE EXCLUSIVE (cpstmp) ALIAS post IN 0
    cidtmp = filetemp('DBF')
    cpatmp = filetemp('DBF')
    SELECT param
    COPY TO (cpatmp) ALL
    USE IN param
    USE EXCLUSIVE (cpatmp) ALIAS param IN 0
    SELECT id
    COPY TO (cidtmp) STRUCTURE
    USE IN id
    USE EXCLUSIVE (cidtmp) ALIAS id IN 0
    USE SHARED (gcdatadir+'ResFix.DBF') ALIAS resfix IN 0
    PUBLIC mysysdate
    SELECT reservat
    SCAN ALL
       IF reservat.rs_status='OPT' AND NOT param.pa_optidef
          LOOP
       ENDIF
       IF reservat.rs_status='TEN' AND NOT param.pa_tentdef
          LOOP
       ENDIF
       mysysdate = reservat.rs_arrdate
       DO ratecodepost IN RatePost WITH reservat.rs_arrdate, 'CHECKIN'
       DO bqpost IN Banquet
       dfor = reservat.rs_arrdate
       DO WHILE dfor<reservat.rs_depdate AND dfor<=max1
          mysysdate = dfor
          REPLACE param.pa_sysdate WITH dfor
          IF NOT USED("Resfix")
             USE SHARED (gcdatadir+'ResFix.DBF') ALIAS resfix IN 0
          ENDIF
          DO postresfix IN ResFix WITH dfor
          DO ratecodepost IN RatePost WITH dfor, ''
          dfor = dfor+1
       ENDDO
       mysysdate = reservat.rs_depdate
       DO ratecodepost IN RatePost WITH reservat.rs_depdate, 'CHECKOUT'
       SELECT reservat
    ENDSCAN
    RELEASE mysysdate
    IF USED("resfix")
       USE IN resfix
    ENDIF
    SELECT post
    INDEX ON ps_origid TAG ps_origid
 ENDIF
 SELECT reservat
 SCAN ALL
    WAIT WINDOW NOWAIT STR(reservat.rs_reserid, 12, 3)
    IF NOT lcalcrev
       IF (rs_arrdate<=max1 AND rs_depdate>=min1) AND NOT INLIST(rs_status, 'CXL', 'NS', 'LST') AND ASCAN(art, rs_roomtyp)>0
       ELSE
          LOOP
       ENDIF
    ENDIF
    IF reservat.rs_status='OPT' AND NOT param.pa_optidef
       LOOP
    ENDIF
    IF reservat.rs_status='TEN' AND NOT param.pa_tentdef
       LOOP
    ENDIF
    nrooms = reservat.rs_rooms
    nad = nrooms*reservat.rs_adults
    nch1 = nrooms*reservat.rs_childs
    nch2 = nrooms*reservat.rs_childs2
    nch3 = nrooms*reservat.rs_childs3
    SELECT preproc
    dfor = reservat.rs_arrdate
    DO WHILE dfor<=reservat.rs_depdate AND dfor<=max1
       SELECT preproc
       LOCATE FOR pp_date=dfor
       IF lcalcrev
          SELECT post
          SUM ps_amount TO nrev ALL FOR ps_origid=reservat.rs_reserid AND ps_date=dfor AND (EMPTY(ps_ratecod) OR ps_split) AND ASCAN(aar, ps_artinum)>0
          SELECT preproc
          REPLACE pp_rev WITH pp_rev+(nrev*nrooms)
       ENDIF
       IF dfor=reservat.rs_arrdate
          IF EMPTY(reservat.rs_share)
             REPLACE pp_arrrms WITH pp_arrrms+nrooms
          ENDIF
          REPLACE pp_arrad WITH pp_arrad+nad, pp_arrch1 WITH pp_arrch1+nch1, pp_arrch2 WITH pp_arrch2+nch2, pp_arrch3 WITH pp_arrch3+nch3
          IF NOT EMPTY(reservat.rs_group)
             IF EMPTY(reservat.rs_share)
                REPLACE pp_garrrms WITH pp_garrrms+nrooms
             ENDIF
             REPLACE pp_garrad WITH pp_garrad+nad, pp_garrch1 WITH pp_garrch1+nch1, pp_garrch2 WITH pp_garrch2+nch2, pp_garrch3 WITH pp_garrch3+nch3
          ENDIF
       ENDIF
       IF dfor=reservat.rs_depdate
          IF EMPTY(reservat.rs_share)
             REPLACE pp_deprms WITH pp_deprms+nrooms
          ENDIF
          REPLACE pp_depad WITH pp_depad+nad, pp_depch1 WITH pp_depch1+nch1, pp_depch2 WITH pp_depch2+nch2, pp_depch3 WITH pp_depch3+nch3
          IF NOT EMPTY(reservat.rs_group)
             IF EMPTY(reservat.rs_share)
                REPLACE pp_gdeprms WITH pp_gdeprms+nrooms
             ENDIF
             REPLACE pp_gdepad WITH pp_gdepad+nad, pp_gdepch1 WITH pp_gdepch1+nch1, pp_gdepch2 WITH pp_gdepch2+nch2, pp_gdepch3 WITH pp_gdepch3+nch3
          ENDIF
       ENDIF
       IF dfor<reservat.rs_depdate
          IF EMPTY(reservat.rs_share)
             REPLACE pp_rms WITH pp_rms+nrooms
          ENDIF
          REPLACE pp_ad WITH pp_ad+nad, pp_ch1 WITH pp_ch1+nch1, pp_ch2 WITH pp_ch2+nch2, pp_ch3 WITH pp_ch3+nch3
          IF NOT EMPTY(reservat.rs_group)
             IF EMPTY(reservat.rs_share)
                REPLACE pp_grms WITH pp_grms+nrooms
             ENDIF
             REPLACE pp_gad WITH pp_gad+nad, pp_gch1 WITH pp_gch1+nch1, pp_gch2 WITH pp_gch2+nch2, pp_gch3 WITH pp_gch3+nch3
          ENDIF
       ENDIF
       dfor = dfor+1
    ENDDO
    SELECT reservat
 ENDSCAN
 IF lcalcrev
    USE IN reservat
    filedelete(crstmp)
    filedelete(STRTRAN(crstmp, '.DBF', '.FPT'))
    filedelete(STRTRAN(crstmp, '.DBF', '.CDX'))
    USE SHARED (gcdatadir+'Reservat.DBF') ALIAS reservat IN 0
    SELECT reservat
    relations()
    GOTO nrsrec
    SET ORDER TO nRsOrd
    USE IN post
    filedelete(cpstmp)
    filedelete(STRTRAN(cpstmp, '.DBF', '.FPT'))
    filedelete(STRTRAN(cpstmp, '.DBF', '.CDX'))
    USE SHARED (gcdatadir+'Post.DBF') ALIAS post IN 0
    SELECT post
    GOTO npsrec
    SET ORDER TO nPsOrd
    IF USED("id")
       USE IN id
    ENDIF
    filedelete(cidtmp)
    USE SHARED (gcdatadir+'Id.DBF') ALIAS id IN 0
    USE IN param
    filedelete(cpatmp)
    USE SHARED (gcdatadir+'Param.dbf') ALIAS param IN 0
 ENDIF
 SELECT preproc
 SELECT (narea)
 RETURN
ENDPROC
**
*** 
*** ReFox - alles ist nicht verloren 
***
