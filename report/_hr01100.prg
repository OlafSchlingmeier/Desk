PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "9.20"

RETURN tcVersion
ENDPROC
*
PROCEDURE _hr01100
LPARAMETER tcType, tlRmsOrd, tcFilter, tlConferenceRoomsOnly
LOCAL loSession, ldOldMin1, ldOldMax1
LOCAL ARRAY laPreProc(1), laSelectedAddresses(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hr01100")
loSession.lConferenceRoomsOnly = tlConferenceRoomsOnly
loSession.DoPreproc(tcType, tlRmsOrd, tcFilter, @laPreProc)

PpCursorCreateCurrentTime()
IF NOT EMPTY(laPreProc(1))
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

PpCursorCreateAllTime()
APPEND FROM DBF("PreProc")
DClose("PreProc")

* calculate for previous year
ldOldMin1 = min1
ldOldMax1 = max1
min1 = DATE(YEAR(min1)-1, MONTH(min1), IIF(MONTH(min1)=2 AND DAY(min1)=29, 28, DAY(min1)))
max1 = DATE(YEAR(max1)-1, MONTH(max1), IIF(MONTH(max1)=2 AND DAY(max1)=29, 28, DAY(max1)))

SELECT DISTINCT pp_addrid FROM PreProcAll INTO ARRAY laSelectedAddresses

loSession.DoPreproc(tcType, tlRmsOrd, tcFilter, @laPreProc, @laSelectedAddresses)
RELEASE loSession

PpCursorCreateCurrentTime()
IF NOT EMPTY(laPreProc(1))
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

* Now mix results into PreProcAll cursor
SELECT PreProcAll
SCAN FOR SEEK(PADL(PreProcAll.pp_addrid,8)+PADL(PreProcAll.pp_month,6),"Preproc","pp_addrid")
     REPLACE pp_vrms WITH Preproc.pp_rms, ;
             pp_vpax WITH Preproc.pp_pax, ;
             pp_vdayrms WITH Preproc.pp_dayrms, ;
             pp_vdaypax WITH Preproc.pp_daypax, ;
             pp_vnsrms WITH Preproc.pp_nsrms, ;
             pp_vcxlrms WITH Preproc.pp_cxlrms, ;
             pp_vrev1 WITH Preproc.pp_rev1, ;
             pp_vrev2 WITH Preproc.pp_rev2, ;
             pp_vrev3 WITH Preproc.pp_rev3, ;
             pp_vrev4 WITH Preproc.pp_rev4, ;
             pp_vrev5 WITH Preproc.pp_rev5, ;
             pp_vrev6 WITH Preproc.pp_rev6, ;
             pp_vrev7 WITH Preproc.pp_rev7, ;
             pp_vrev8 WITH Preproc.pp_rev8, ;
             pp_vrev9 WITH Preproc.pp_rev9 ;
             IN PreProcAll
ENDSCAN

min1 = ldOldMin1
max1 = ldOldMax1

DClose("PreProc")

SELECT * FROM PreProcAll INTO CURSOR PreProc
DClose("PreProcAll")

SELECT PreProc

WAIT CLEAR
ENDPROC
*
DEFINE CLASS _hr01100 AS Session

lConferenceRoomsOnly = .F.

PROCEDURE Init
Ini()
OpenFile()
ENDPROC

PROCEDURE DoPreproc
LPARAMETER tcType, tlRmsOrd, tcFilter, taPreProc, taSelectedAddresses
LOCAL lcCriterium, lcAddrJoinClause, lcAddrIdField, lcAddressField, lcurReservat, lcurHistres, lcurPost, lcurPreproc, lcSelectedAddressesCur, ;
          lcRoomGroupFilter, lcReserDepDateFilter, lcHistReserDepDateFilter, lcReserPPDepDateFilter, lcHistPPReserDepDateFilter, lcAddrIdHField, lcArchScripts

IF EMPTY(tcFilter)
     tcFilter = ".T."
ENDIF
IF this.lConferenceRoomsOnly
     lcRoomGroupFilter = [rt_group = 2]
     lcReserDepDateFilter = [rs_depdate]
     lcHistReserDepDateFilter = [hr_depdate]
     lcReserPPDepDateFilter = [rs_depdate]
     lcHistPPReserDepDateFilter = [hr_depdate]
ELSE
     lcRoomGroupFilter = [INLIST(rt_group, 1, 4) AND rt_vwsum OR rt_group = 3]
     lcReserDepDateFilter = [MAX(rs_arrdate, rs_depdate-1)]
     lcHistReserDepDateFilter = [MAX(hr_arrdate, hr_depdate-1)]
     lcReserPPDepDateFilter = [rs_depdate-1]
     lcHistPPReserDepDateFilter = [hr_depdate-1]
ENDIF

PpCursorCreateCurrentTime()

lcurReservat = SYS(2015)
lcurHistres = SYS(2015)
lcurPost = SYS(2015)
lcurPreproc = SYS(2015)
lcSelectedAddressesCur = SYS(2015)

IF PCOUNT() > 4
     CREATE CURSOR (lcSelectedAddressesCur) (pp_addrid N(8))
     INDEX ON pp_addrid TAG TAG1
     INSERT INTO (lcSelectedAddressesCur) FROM ARRAY taSelectedAddresses
     lcAddrJoinClause = "INNER JOIN " + lcSelectedAddressesCur + " ON pp_addrid = ad_addrid"
ELSE
     lcAddrJoinClause = ""

******************** Prepare SQLs for archive ******************************************************
*
     TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
     SELECT histres.* FROM histres
          INNER JOIN (
          SELECT hr_reserid AS c_reserid FROM histres
               WHERE hr_reserid > 1 AND hr_arrdate <= <<SqlCnvB(max1)>> AND hr_depdate >= <<SqlCnvB(min1)>>
          UNION
          SELECT hr_reserid FROM histres
               INNER JOIN histpost ON hp_origid = hr_reserid
               WHERE BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
               GROUP BY hr_reserid
          ) hr ON hr_reserid = c_reserid;

     SELECT histpost.* FROM histpost
          WHERE BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
     ENDTEXT
     ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************
ENDIF

DO CASE
     CASE VARTYPE(tcType) # "C" OR tcType == "C"          && C = Company
          lcCriterium = 'NOT EMPTY(ad_company)'
          lcAddrIdField = 'rs_compid'
     CASE tcType == "G"                                   && G = Guest
          lcCriterium = 'NOT EMPTY(ad_lname)'
          lcAddrIdField = 'rs_addrid'
     CASE tcType == "A"                                   && A = Agent
          lcCriterium = 'NOT EMPTY(ad_company)'
          lcAddrIdField = 'rs_agentid'
ENDCASE

DO CASE
     CASE VARTYPE(min3) # "N" OR NOT INLIST(min3, 1, 2)
          lcAddressField = '0'
     CASE min3 = 1
          lcAddressField = 'ad_compnum'
     CASE min3 = 2
          lcAddressField = 'ad_member'
ENDCASE

SELECT DISTINCT &lcAddrIdField AS pp_addrid, &lcAddressField AS pp_compnum, rt_group, rs_reserid, rs_rsid, rs_arrdate, ;
     rs_depdate, rs_adults+rs_childs+rs_childs2+rs_childs3 AS pp_persons, rs_ratedat, rs_status, rs_rooms, ;
     CallFunc("MAX(min1, p1)",rs_arrdate) AS pp_fromdate, CallFunc("MIN(max1, MAX(p1, p2))",rs_arrdate, &lcReserPPDepDateFilter) AS pp_todate FROM reservat ;
     INNER JOIN address ON ad_addrid = &lcAddrIdField ;
     &lcAddrJoinClause INNER JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
     WHERE rs_reserid > 1 AND &lcAddrIdField > 0 AND rs_arrdate <= max1 AND &lcReserDepDateFilter >= min1 AND ;
     (&lcRoomGroupFilter) AND (&lcCriterium) AND (&tcFilter) ;
     INTO CURSOR (lcurReservat) READWRITE
INDEX ON rs_reserid TAG rs_reserid
INDEX ON rs_rsid TAG rs_rsid

lcAddrIdHField = STRTRAN(lcAddrIdField, "rs_", "hr_")
SELECT DISTINCT &lcAddrIdHField AS pp_addrid, &lcAddressField AS pp_compnum, rt_group, hr_reserid AS rs_reserid, hr_rsid AS rs_rsid, hr_arrdate AS rs_arrdate, ;
     hr_depdate AS rs_depdate, hr_adults+hr_childs+hr_childs2+hr_childs3 AS pp_persons, hr_ratedat AS rs_ratedat, hr_status AS rs_status, hr_rooms AS rs_rooms, ;
     CallFunc("MAX(min1, p1)",hr_arrdate) AS pp_fromdate, CallFunc("MIN(max1, MAX(p1, p2))",hr_arrdate, &lcHistPPReserDepDateFilter) AS pp_todate FROM histres ;
     INNER JOIN address ON ad_addrid = &lcAddrIdHField ;
     &lcAddrJoinClause INNER JOIN roomtype ON rt_roomtyp = hr_roomtyp ;
     WHERE hr_reserid > 1 AND &lcAddrIdHField > 0 AND hr_arrdate <= max1 AND &lcHistReserDepDateFilter >= min1 AND ;
     NOT SEEK(hr_reserid,"reservat","tag1") AND (&lcRoomGroupFilter) AND (&lcCriterium) AND (&tcFilter) ;
     INTO CURSOR (lcurHistres) READWRITE
INDEX ON rs_reserid TAG rs_reserid

SELECT &lcAddrIdField AS pp_addrid, &lcAddressField AS pp_compnum, ps_date AS pp_date, ps_amount AS pp_amount, NVL(ar_main,0) AS ar_main FROM post ;
     INNER JOIN reservat ON ps_origid = rs_reserid ;
     INNER JOIN address ON ad_addrid = &lcAddrIdField ;
     &lcAddrJoinClause INNER JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
     LEFT JOIN article ON ar_artinum = ps_artinum ;
     WHERE BETWEEN(ps_date, min1, max1) AND NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) AND rs_reserid > 1 AND &lcAddrIdField > 0 AND (&lcRoomGroupFilter) AND (&lcCriterium) AND (&tcFilter) ;
     UNION ALL ;
SELECT &lcAddrIdHField AS pp_addrid, &lcAddressField AS pp_compnum, hp_date, hp_amount, NVL(ar_main,0) FROM histpost ;
     INNER JOIN histres ON hp_origid = hr_reserid ;
     INNER JOIN address ON ad_addrid = &lcAddrIdHField ;
     &lcAddrJoinClause INNER JOIN roomtype ON rt_roomtyp = hr_roomtyp ;
     LEFT JOIN article ON ar_artinum = hp_artinum ;
     WHERE BETWEEN(hp_date, min1, max1) AND NOT SEEK(hp_postid,"post","tag3") AND NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) AND hr_reserid > 1 AND &lcAddrIdHField > 0 AND (&lcRoomGroupFilter) AND (&lcCriterium) AND (&tcFilter) ;
     UNION ALL ;
SELECT &lcAddrIdField AS pp_addrid, &lcAddressField AS pp_compnum, rl_date, rl_price*rl_units, NVL(ar_main,0) FROM ressplit ;
     INNER JOIN reservat ON rs_rsid = rl_rsid ;
     INNER JOIN address ON ad_addrid = &lcAddrIdField ;
     &lcAddrJoinClause INNER JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
     LEFT JOIN article ON ar_artinum = rl_artinum ;
     WHERE rl_date > rs_ratedat AND BETWEEN(rl_date, min1, max1) AND NOT EMPTY(rl_price*rl_units) AND NOT INLIST(rs_status, 'CXL', 'NS') AND rs_reserid > 1 AND &lcAddrIdField > 0 AND (&lcRoomGroupFilter) AND (&lcCriterium) AND (&tcFilter) ;
     INTO CURSOR (lcurPost)

SELECT pp_addrid, pp_compnum, LEFT(DTOS(pp_date),6) AS pp_month, SUM(IIF(ar_main<2, pp_amount, 0.00)) AS pp_rev1, ;
     SUM(IIF(ar_main=2, pp_amount, 0.00)) AS pp_rev2, SUM(IIF(ar_main=3, pp_amount, 0.00)) AS pp_rev3, ;
     SUM(IIF(ar_main=4, pp_amount, 0.00)) AS pp_rev4, SUM(IIF(ar_main=5, pp_amount, 0.00)) AS pp_rev5, ;
     SUM(IIF(ar_main=6, pp_amount, 0.00)) AS pp_rev6, SUM(IIF(ar_main=7, pp_amount, 0.00)) AS pp_rev7, ;
     SUM(IIF(ar_main=8, pp_amount, 0.00)) AS pp_rev8, SUM(IIF(ar_main=9, pp_amount, 0.00)) AS pp_rev9 ;
     FROM &lcurPost ;
     GROUP BY pp_addrid, pp_compnum, 3 ;
     INTO CURSOR (lcurPreproc)

SELECT PreProc
APPEND FROM DBF(lcurPreproc)

OccupancyGenerate(lcurReservat, "resrate")
OccupancyGenerate(lcurHistres, "hresrate")

IF VARTYPE(min4) # "L" OR NOT min4
     BLANK FIELDS pp_month ALL IN PreProc
ENDIF

GroupingByNumber()
GroupingByValues(tlRmsOrd)

IF PCOUNT() > 4
******************** Delete temp files *************************************************************
*
     ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDIF

DClose(lcurReservat)
DClose(lcurHistres)
DClose(lcurPost)
DClose(lcurPreproc)
DClose(lcSelectedAddressesCur)

SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE
*
PROCEDURE PpCursorCreateCurrentTime
CREATE CURSOR PreProc (pp_addrid N(8), pp_compnum N(10), pp_recno N(6), pp_month N(6), pp_rms N(6), pp_pax N(6), ;
     pp_dayrms N(6), pp_daypax N(6), pp_nsrms N(6), pp_cxlrms N(6), pp_rev1 B(2), pp_rev2 B(2), ;
     pp_rev3 B(2), pp_rev4 B(2), pp_rev5 B(2), pp_rev6 B(2), pp_rev7 B(2), pp_rev8 B(2), pp_rev9 B(2))
INDEX ON PADL(pp_addrid,8)+PADL(pp_month,6) TAG pp_addrid
ENDPROC
*
PROCEDURE PpCursorCreateAllTime
CREATE CURSOR PreProcAll ( ;
     pp_addrid N(8), pp_compnum N(10), pp_recno N(6), pp_month N(6), ;
     pp_rms N(6), pp_pax N(6), pp_dayrms N(6), ;
     pp_daypax N(6), pp_nsrms N(6), pp_cxlrms N(6), pp_rev1 B(2), pp_rev2 B(2), pp_rev3 B(2), ;
     pp_rev4 B(2), pp_rev5 B(2), pp_rev6 B(2), pp_rev7 B(2), pp_rev8 B(2), pp_rev9 B(2), ;
     pp_vrms N(6), pp_vpax N(6), pp_vdayrms N(6), ;
     pp_vdaypax N(6), pp_vnsrms N(6), pp_vcxlrms N(6), pp_vrev1 B(2), pp_vrev2 B(2), pp_vrev3 B(2), ;
     pp_vrev4 B(2), pp_vrev5 B(2), pp_vrev6 B(2), pp_vrev7 B(2), pp_vrev8 B(2), pp_vrev9 B(2) ;
     )
ENDPROC
*
PROCEDURE OccupancyGenerate
LPARAMETERS tcurReservat, tcResrate
LOCAL lnMonth, lnNextMonth, ldMinDate, ldMaxDate, lnPersons

SELECT &tcurReservat
SCAN FOR rt_group <> 3
     FOR lnMonth = VAL(LEFT(DTOS(pp_fromdate),6)) TO VAL(LEFT(DTOS(pp_todate),6))
          lnNextMonth = lnMonth + IIF(MOD(lnMonth,100)=12, 89, 1)  && if december, next month have to be january next year, Example: 201012 -> 201101; 201012 + 89 = 201101
          IF NOT SEEK(PADL(&tcurReservat..pp_addrid,8)+PADL(lnMonth,6), "PreProc", "pp_addrid")
               INSERT INTO PreProc (pp_addrid, pp_compnum, pp_month) VALUES (&tcurReservat..pp_addrid, &tcurReservat..pp_compnum, lnMonth)
          ENDIF
          DO CASE
               CASE rs_status = "NS"
                    IF lnMonth = VAL(LEFT(DTOS(pp_fromdate),6))
                         REPLACE pp_nsrms WITH PreProc.pp_nsrms + &tcurReservat..rs_rooms IN PreProc
                    ENDIF
               CASE rs_status = "CXL"
                    IF lnMonth = VAL(LEFT(DTOS(pp_fromdate),6))
                         REPLACE pp_cxlrms WITH PreProc.pp_cxlrms + &tcurReservat..rs_rooms IN PreProc
                    ENDIF
               CASE NOT INLIST(rs_status, 'LST', 'OPT', 'TEN') AND rs_arrdate = rs_depdate
                    REPLACE pp_dayrms WITH PreProc.pp_dayrms + &tcurReservat..rs_rooms, ;
                            pp_daypax WITH PreProc.pp_daypax + &tcurReservat..pp_persons IN PreProc
               CASE NOT INLIST(rs_status, 'LST', 'OPT', 'TEN')
                    ldMinDate = MAX(pp_fromdate, DATE(INT(lnMonth/100),MOD(lnMonth,100),1))
                    ldMaxDate = MIN(pp_todate+1, DATE(INT(lnNextMonth/100),MOD(lnNextMonth,100),1))
                    CALCULATE SUM(rr_adults+rr_childs+rr_childs2+rr_childs3) ;
                         FOR rr_reserid = &tcurReservat..rs_reserid AND BETWEEN(rr_date, ldMinDate, ldMaxDate-1) ;
                         TO lnPersons IN &tcResrate
                    lnPersons = lnPersons + (ldMaxDate-ldMinDate-_tally)*pp_persons
                    REPLACE pp_rms WITH PreProc.pp_rms + &tcurReservat..rs_rooms * MAX(1, ldMaxDate-ldMinDate), ;
                            pp_pax WITH PreProc.pp_pax + lnPersons IN PreProc
               OTHERWISE
          ENDCASE
          lnMonth = lnNextMonth - 1
     NEXT
ENDSCAN
ENDPROC
*
PROCEDURE GroupingByNumber
LOCAL lcurPreproc

IF VARTYPE(min3) = "N" AND INLIST(min3, 1, 2)
     lcurPreproc = SYS(2015)
     SELECT pp_addrid, pp_compnum, pp_month, SUM(pp_rms) AS pp_rms, SUM(pp_pax) AS pp_pax, SUM(pp_dayrms) AS pp_dayrms, ;
          SUM(pp_daypax) AS pp_daypax, SUM(pp_nsrms) AS pp_nsrms, SUM(pp_cxlrms) AS pp_cxlrms, ;
          SUM(pp_rev1) AS pp_rev1, SUM(pp_rev2) AS pp_rev2, SUM(pp_rev3) AS pp_rev3, ;
          SUM(pp_rev4) AS pp_rev4, SUM(pp_rev5) AS pp_rev5, SUM(pp_rev6) AS pp_rev6, ;
          SUM(pp_rev7) AS pp_rev7, SUM(pp_rev8) AS pp_rev8, SUM(pp_rev9) AS pp_rev9 FROM PreProc ;
          WHERE pp_compnum = 0 ;
          GROUP BY pp_month, pp_addrid ;
     UNION SELECT pp_addrid, pp_compnum, pp_month, SUM(pp_rms) AS pp_rms, SUM(pp_pax) AS pp_pax, SUM(pp_dayrms) AS pp_dayrms, ;
          SUM(pp_daypax) AS pp_daypax, SUM(pp_nsrms) AS pp_nsrms, SUM(pp_cxlrms) AS pp_cxlrms, ;
          SUM(pp_rev1) AS pp_rev1, SUM(pp_rev2) AS pp_rev2, SUM(pp_rev3) AS pp_rev3, ;
          SUM(pp_rev4) AS pp_rev4, SUM(pp_rev5) AS pp_rev5, SUM(pp_rev6) AS pp_rev6, ;
          SUM(pp_rev7) AS pp_rev7, SUM(pp_rev8) AS pp_rev8, SUM(pp_rev9) AS pp_rev9 FROM PreProc ;
          WHERE pp_compnum > 0 ;
          GROUP BY pp_month, pp_compnum ;
          INTO CURSOR &lcurPreproc
     PpCursorCreateCurrentTime()
     APPEND FROM DBF(lcurPreproc)
     DClose(lcurPreproc)
ENDIF
ENDPROC
*
PROCEDURE GroupingByValues
LPARAMETERS tlRmsOrd
LOCAL lcurPreproc, lcOrdFld

lcurPreproc = SYS(2015)
lcOrdFld = IIF(tlRmsOrd, "5", "11")     && pp_rms - 5th field; pp_rev - 11th field
SELECT 00000000 AS pp_recno, pp_addrid, pp_month, pp_compnum, SUM(pp_rms) AS pp_rms, SUM(pp_pax) AS pp_pax, ;
     SUM(pp_dayrms) AS pp_dayrms, SUM(pp_daypax) AS pp_daypax, SUM(pp_cxlrms) AS pp_cxlrms, SUM(pp_nsrms) AS pp_nsrms, ;
     SUM(pp_rev1 + pp_rev2 + pp_rev3 + pp_rev4 + pp_rev5 + pp_rev6 + pp_rev7 + pp_rev8 + pp_rev9) AS pp_rev, ;
     SUM(pp_rev1) AS pp_rev1, SUM(pp_rev2) AS pp_rev2, SUM(pp_rev3) AS pp_rev3, SUM(pp_rev4) AS pp_rev4, SUM(pp_rev5) AS pp_rev5, ;
     SUM(pp_rev6) AS pp_rev6, SUM(pp_rev7) AS pp_rev7, SUM(pp_rev8) AS pp_rev8, SUM(pp_rev9) AS pp_rev9 FROM PreProc ;
     GROUP BY pp_month, pp_addrid HAVING pp_rev <> 0 OR pp_rms <> 0 OR pp_dayrms <> 0 OR pp_nsrms <> 0 OR pp_cxlrms <> 0 ;
     ORDER BY pp_month, &lcOrdFld DESCEND ;
     INTO CURSOR &lcurPreproc READWRITE
SCAN
     lnOffset = RECNO() - 1
     lnMonth = pp_month
     REPLACE pp_recno WITH RECNO() - lnOffset WHILE pp_month = lnMonth
     SKIP -1
ENDSCAN
PpCursorCreateCurrentTime()
APPEND FROM DBF(lcurPreproc)
DClose(lcurPreproc)
ENDPROC
*