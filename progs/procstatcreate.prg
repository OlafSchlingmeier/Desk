LPARAMETERS lp_dSysDate, lp_cStatCur1, lp_cStatCur2, lp_cAddrIdCur, lp_uFilters, lp_cEventsCur, lp_creservat, lp_chistres, lp_cpost, lp_chistpost, lp_croomtype, lp_calthead, lp_cevint, lp_carticle, lp_cressplit

* Also used in citadelapi!

LOCAL l_nSelect, l_curReservat, l_curHistres, l_curPost, l_curResr, l_curPsAstat, l_curRsAstat, l_curYear, l_cAddrIdCur, l_cChooseEventsCur
LOCAL i, l_nFirstYear, l_nLastYear, l_dEndLY, l_dStartLY, l_dStartCY, l_cSqlRl, l_lFilterAsGuest, l_lFilterAsCompany, l_lFilterAsAgent, l_lFilterAlsoForecast, l_cWhereAdr, l_cWhereAdrH
LOCAL ARRAY l_aYears(1)

l_nSelect = SELECT()

l_curReservat = SYS(2015)
l_curHistres = SYS(2015)
l_curPost = SYS(2015)
l_curResr = SYS(2015)
l_curPsAstat = SYS(2015)
l_curRsAstat = SYS(2015)
l_curYear = SYS(2015)
l_cAddrIdCur = lp_cAddrIdCur
l_cChooseEventsCur = lp_cEventsCur

IF VARTYPE(lp_uFilters) = "N"
     l_lFilterEvents = BITTEST(lp_uFilters,0)
     l_lFilterAsGuest = BITTEST(lp_uFilters,1)
     l_lFilterAsCompany = BITTEST(lp_uFilters,2)
     l_lFilterAsAgent = BITTEST(lp_uFilters,3)
     l_lFilterAlsoForecast = BITTEST(lp_uFilters,4)
ELSE
     l_lFilterEvents = lp_uFilters
     STORE .T. TO l_lFilterAsGuest, l_lFilterAsCompany, l_lFilterAsAgent
ENDIF

STORE "" TO l_cWhereAdr, l_cSqlRl
IF l_lFilterAsGuest
     l_cWhereAdr = l_cWhereAdr + IIF(EMPTY(l_cWhereAdr), "", " OR ") + "rs_addrid = " + l_cAddrIdCur + ".nAddrId"
ENDIF
IF l_lFilterAsCompany
     l_cWhereAdr = l_cWhereAdr + IIF(EMPTY(l_cWhereAdr), "", " OR ") + "rs_compid = " + l_cAddrIdCur + ".nAddrId"
ENDIF
IF l_lFilterAsAgent
     l_cWhereAdr = l_cWhereAdr + IIF(EMPTY(l_cWhereAdr), "", " OR ") + "rs_agentid = " + l_cAddrIdCur + ".nAddrId"
ENDIF
IF EMPTY(l_cWhereAdr)
     l_cWhereAdr = "0=1"
ENDIF
l_cWhereAdrH = STRTRAN(l_cWhereAdr, "rs_", "hr_")

l_dStartCY = DATE(YEAR(lp_dSysDate),1,1)
l_dEndCY = IIF(l_lFilterAlsoForecast, DATE(YEAR(lp_dSysDate),12,31), lp_dSysDate)     && If want to include forecast data from ressplit.dbf then retrueve data to end of current year
l_dStartLY = DATE(YEAR(lp_dSysDate)-1,1,1)
l_dEndLY = GetRelDate(l_dEndCY, "-1Y", 31)

creservat = EVL(lp_creservat, "reservat")
chistres = EVL(lp_chistres, "histres")
cpost = EVL(lp_cpost, "post")
chistpost = EVL(lp_chistpost, "histpost")
croomtype = EVL(lp_croomtype, "roomtype")
calthead = EVL(lp_calthead, "althead")
cevint = EVL(lp_cevint, "evint")
carticle = EVL(lp_carticle, "article")
cressplit = EVL(lp_cressplit, "ressplit")

* Collect all reservations for specific set of addresses.
DO CASE
     CASE RECCOUNT(l_cAddrIdCur) = 1     && if only 1 address is calculating
          SELECT DISTINCT rs_reserid, rs_rsid, rs_arrdate, rs_depdate, rs_roomtyp, rs_status, rs_altid, rs_ratedat ;
               FROM &creservat ;
               WHERE &l_cWhereAdr ;
               INTO CURSOR (l_curReservat)
          INDEX ON rs_reserid TAG rs_reserid

          SELECT DISTINCT hr_reserid, hr_rsid, hr_arrdate, hr_depdate, hr_roomtyp, hr_status, hr_altid ;
               FROM &chistres ;
               WHERE (&l_cWhereAdrH) AND NOT SEEK(&chistres..hr_reserid,l_curReservat,"rs_reserid") ;
               INTO CURSOR (l_curHistres)
          INDEX ON hr_reserid TAG hr_reserid

     CASE RECCOUNT(l_cAddrIdCur) < RECCOUNT(chistres)/3500     && if just some addresses are calculating
          SELECT DISTINCT rs_reserid, rs_rsid, rs_arrdate, rs_depdate, rs_roomtyp, rs_status, rs_altid, rs_ratedat ;
               FROM &creservat ;
               INNER JOIN &l_cAddrIdCur ON &l_cWhereAdr ;
               INTO CURSOR (l_curReservat)
          INDEX ON rs_reserid TAG rs_reserid

          SELECT DISTINCT hr_reserid, hr_rsid, hr_arrdate, hr_depdate, hr_roomtyp, hr_status, hr_altid ;
               FROM &chistres ;
               INNER JOIN &l_cAddrIdCur ON &l_cWhereAdrH ;
               WHERE NOT SEEK(&chistres..hr_reserid,l_curReservat,"rs_reserid") ;
               INTO CURSOR (l_curHistres)
          INDEX ON hr_reserid TAG hr_reserid

     OTHERWISE     && if a lot off addresses are calculating     (faster than SELECT with INNER JOIN)
          SELECT rs_reserid, rs_rsid, rs_arrdate, rs_depdate, rs_roomtyp, rs_status, rs_altid, rs_ratedat ;
               FROM &creservat ;
               WHERE 0 = 1 ;
               INTO CURSOR (l_curReservat) READWRITE
          INDEX ON rs_reserid TAG rs_reserid
          SELECT (creservat)
          SCAN FOR NOT SEEK(rs_reserid,l_curReservat,"rs_reserid") AND (SEEK(rs_addrid,l_cAddrIdCur,"tag1") OR SEEK(rs_compid,l_cAddrIdCur,"tag1") OR SEEK(rs_agentid,l_cAddrIdCur,"tag1"))
               SCATTER MEMO NAME l_oReservat
               INSERT INTO (l_curReservat) FROM NAME l_oReservat
          ENDSCAN

          SELECT hr_reserid, hr_rsid, hr_arrdate, hr_depdate, hr_roomtyp, hr_status, hr_altid ;
               FROM &chistres ;
               WHERE 0 = 1 ;
               INTO CURSOR (l_curHistres) READWRITE
          INDEX ON hr_reserid TAG hr_reserid
          SELECT (chistres)
          SCAN FOR NOT SEEK(hr_reserid,l_curReservat,"rs_reserid") AND NOT SEEK(hr_reserid,l_curHistres,"hr_reserid") AND (SEEK(hr_addrid,l_cAddrIdCur,"tag1") OR SEEK(hr_compid,l_cAddrIdCur,"tag1") OR SEEK(hr_agentid,l_cAddrIdCur,"tag1"))
               SCATTER MEMO NAME l_oReservat
               INSERT INTO (l_curHistres) FROM NAME l_oReservat
          ENDSCAN
ENDCASE

* Collect posts for retrieved reservations.
DO CASE
     CASE NOT l_lFilterEvents
          IF l_lFilterAlsoForecast
               TEXT TO l_cSqlRl TEXTMERGE NOSHOW PRETEXT 2 + 8
                    UNION ALL
                    SELECT rl_date, rl_price*rl_units, NVL(ar_main,0)
                         FROM <<cressplit>>
                         INNER JOIN <<l_curReservat>> ON rs_rsid = rl_rsid
                         LEFT JOIN <<carticle>> ON ar_artinum = rl_artinum
                         WHERE rl_date > rs_ratedat AND NOT EMPTY(rl_price*rl_units) AND NOT INLIST(rs_status, 'CXL', 'NS')
               ENDTEXT
          ENDIF
          SELECT ps_date, ps_amount, NVL(ar_main,0) AS ar_main ;
               FROM &cpost ;
               INNER JOIN (l_curReservat) ON rs_reserid = ps_origid ;
               LEFT JOIN &carticle ON ar_artinum = ps_artinum ;
               WHERE NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) ;
          UNION ALL ;
          SELECT hp_date, hp_amount, NVL(ar_main,0) ;
               FROM &chistpost ;
               INNER JOIN (l_curHistres) ON hr_reserid = hp_origid ;
               LEFT JOIN &carticle ON ar_artinum = hp_artinum ;
               WHERE NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) ;
               &l_cSqlRl ;
               INTO CURSOR (l_curPost)

          SELECT rs_rsid, rs_arrdate, rs_depdate, YEAR(rs_arrdate) AS rs_year, rs_status, 1 AS rs_res, ;
                 PSCGetNights(YEAR(rs_arrdate), rs_arrdate, rs_depdate) AS rs_nights, ;
                 PSCGetNights(YEAR(rs_arrdate), rs_arrdate, rs_depdate, l_dEndCY) AS rs_nights1 ;
               FROM (l_curReservat) ;
               LEFT JOIN &croomtype ON rt_roomtyp = rs_roomtyp ;
               WHERE INLIST(rt_group,1,4) AND rt_vwsum ;
          UNION ALL ;
          SELECT hr_rsid, hr_arrdate, hr_depdate, YEAR(hr_arrdate), hr_status, 1, ;
                 PSCGetNights(YEAR(hr_arrdate), hr_arrdate, hr_depdate), ;
                 PSCGetNights(YEAR(hr_arrdate), hr_arrdate, hr_depdate, l_dEndCY) ;
               FROM (l_curHistres) ;
               LEFT JOIN &croomtype ON rt_roomtyp = hr_roomtyp ;
               WHERE INLIST(rt_group,1,4) AND rt_vwsum ;
               INTO CURSOR (l_curResr) READWRITE
     CASE g_lShips
          IF l_lFilterAlsoForecast
               TEXT TO l_cSqlRl TEXTMERGE NOSHOW PRETEXT 2 + 8
                    UNION ALL
                    SELECT rl_date, rl_price*rl_units, NVL(ar_main,0)
                         FROM <<cressplit>>
                         INNER JOIN <<l_curReservat>> ON rs_rsid = rl_rsid
                         INNER JOIN <<calthead>> ON al_altid = rs_altid
                         INNER JOIN <<cevint>> ON ei_eiid = al_eiid
                         INNER JOIN <<l_cChooseEventsCur>> ON ev_evid = ei_evid
                         LEFT JOIN <<carticle>> ON ar_artinum = rl_artinum
                         WHERE ev_mark AND rl_date > rs_ratedat AND NOT EMPTY(rl_price*rl_units) AND NOT INLIST(rs_status, 'CXL', 'NS')
               ENDTEXT
          ENDIF
          SELECT ps_date, ps_amount, NVL(ar_main,0) AS ar_main ;
               FROM &cpost ;
               INNER JOIN (l_curReservat) ON rs_reserid = ps_origid ;
               INNER JOIN &calthead ON al_altid = rs_altid ;
               INNER JOIN &cevint ON ei_eiid = al_eiid ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &carticle ON ar_artinum = ps_artinum ;
               WHERE ev_mark AND NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) ;
          UNION ALL ;
          SELECT hp_date, hp_amount, NVL(ar_main,0) ;
               FROM &chistpost ;
               INNER JOIN (l_curHistres) ON hr_reserid = hp_origid ;
               INNER JOIN &calthead ON al_altid = hr_altid ;
               INNER JOIN &cevint ON ei_eiid = al_eiid ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &carticle ON ar_artinum = hp_artinum ;
               WHERE ev_mark AND NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) ;
               &l_cSqlRl ;
               INTO CURSOR (l_curPost)

          SELECT rs_rsid, rs_arrdate, rs_depdate, YEAR(rs_arrdate) AS rs_year, rs_status, 1 AS rs_res, ;
                 PSCGetNights(YEAR(rs_arrdate), rs_arrdate, rs_depdate) AS rs_nights, ;
                 PSCGetNights(YEAR(rs_arrdate), rs_arrdate, rs_depdate, l_dEndCY) AS rs_nights1 ;
               FROM (l_curReservat) ;
               INNER JOIN &calthead ON al_altid = rs_altid ;
               INNER JOIN &cevint ON ei_eiid = al_eiid ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &croomtype ON rt_roomtyp = rs_roomtyp ;
               WHERE ev_mark AND INLIST(rt_group,1,4) AND rt_vwsum ;
          UNION ALL ;
          SELECT hr_rsid, hr_arrdate, hr_depdate, YEAR(hr_arrdate), hr_status, 1, ;
                 PSCGetNights(YEAR(hr_arrdate), hr_arrdate, hr_depdate), ;
                 PSCGetNights(YEAR(hr_arrdate), hr_arrdate, hr_depdate, l_dEndCY) ;
               FROM (l_curHistres) ;
               INNER JOIN &calthead ON al_altid = hr_altid ;
               INNER JOIN &cevint ON ei_eiid = al_eiid ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &croomtype ON rt_roomtyp = hr_roomtyp ;
               WHERE ev_mark AND INLIST(rt_group,1,4) AND rt_vwsum ;
               INTO CURSOR (l_curResr) READWRITE
     OTHERWISE
          IF l_lFilterAlsoForecast
               TEXT TO l_cSqlRl TEXTMERGE NOSHOW PRETEXT 2 + 8
                    UNION ALL
                    SELECT rl_date, rl_price*rl_units, NVL(ar_main,0)
                         FROM <<cressplit>>
                         INNER JOIN <<l_curReservat>> ON rs_rsid = rl_rsid
                         INNER JOIN <<cevint>> ON BETWEEN(rl_date, ei_from, ei_to)
                         INNER JOIN <<l_cChooseEventsCur>> ON ev_evid = ei_evid
                         LEFT JOIN <<carticle>> ON ar_artinum = rl_artinum
                         WHERE ev_mark AND rl_date > rs_ratedat AND NOT EMPTY(rl_price*rl_units) AND NOT INLIST(rs_status, 'CXL', 'NS')
               ENDTEXT
          ENDIF
          SELECT ps_date, ps_amount, NVL(ar_main,0) AS ar_main ;
               FROM &cpost ;
               INNER JOIN (l_curReservat) ON rs_reserid = ps_origid ;
               INNER JOIN &cevint ON BETWEEN(ps_date, ei_from, ei_to) ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &carticle ON ar_artinum = ps_artinum ;
               WHERE ev_mark AND NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) ;
          UNION ALL ;
          SELECT hp_date, hp_amount, NVL(ar_main,0) ;
               FROM &chistpost ;
               INNER JOIN (l_curHistres) ON hr_reserid = hp_origid ;
               INNER JOIN &cevint ON BETWEEN(hp_date, ei_from, ei_to) ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &carticle ON ar_artinum = hp_artinum ;
               WHERE ev_mark AND NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) ;
               &l_cSqlRl ;
               INTO CURSOR (l_curPost)

          SELECT rs_rsid, rs_arrdate, rs_depdate, YEAR(rs_arrdate) AS rs_year, rs_status, 1 AS rs_res, ;
                 PSCGetNights(YEAR(rs_arrdate), rs_arrdate, rs_depdate) AS rs_nights, ;
                 PSCGetNights(YEAR(rs_arrdate), rs_arrdate, rs_depdate, l_dEndCY) AS rs_nights1 ;
               FROM (l_curReservat) ;
               INNER JOIN &cevint ON rs_arrdate <= ei_to AND rs_depdate > ei_from ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &croomtype ON rt_roomtyp = rs_roomtyp ;
               WHERE ev_mark AND INLIST(rt_group,1,4) AND rt_vwsum ;
          UNION ALL ;
          SELECT hr_rsid, hr_arrdate, hr_depdate, YEAR(hr_arrdate), hr_status, 1, ;
                 PSCGetNights(YEAR(hr_arrdate), hr_arrdate, hr_depdate), ;
                 PSCGetNights(YEAR(hr_arrdate), hr_arrdate, hr_depdate, l_dEndCY) ;
               FROM (l_curHistres) ;
               INNER JOIN &cevint ON hr_arrdate <= ei_to AND hr_depdate > ei_from ;
               INNER JOIN &l_cChooseEventsCur ON ev_evid = ei_evid ;
               LEFT JOIN &croomtype ON rt_roomtyp = hr_roomtyp ;
               WHERE ev_mark AND INLIST(rt_group,1,4) AND rt_vwsum ;
               INTO CURSOR (l_curResr) READWRITE
ENDCASE

SELECT (l_curResr)
SCAN FOR YEAR(rs_arrdate) < YEAR(rs_depdate-1)
     SCATTER FIELDS EXCEPT rs_res NAME l_oReservat
     FOR l_oReservat.rs_year = YEAR(rs_arrdate)+1 TO YEAR(rs_depdate-1)
          l_oReservat.rs_nights  = PSCGetNights(l_oReservat.rs_year, rs_arrdate, rs_depdate)
          l_oReservat.rs_nights1 = PSCGetNights(l_oReservat.rs_year, rs_arrdate, rs_depdate, l_dEndCY)
          INSERT INTO (l_curResr) FROM NAME l_oReservat
     ENDFOR
ENDSCAN
FOR i = 1 TO 2
     DO CASE
          CASE i = 1     && Fill Compare cursor
               l_cStatCur = lp_cStatCur1
               l_cNightsFld = "rs_nights1"
               l_cWherePS = "BETWEEN(ps_date, l_dStartLY, l_dEndLY) OR BETWEEN(ps_date, l_dStartCY, l_dEndCY)"
               l_cWhereRS = "rs_depdate > l_dStartLY AND rs_arrdate <= l_dEndLY OR rs_depdate > l_dStartCY AND rs_arrdate <= l_dEndCY"
          CASE i = 2     && Fill Year cursor
               l_cStatCur = lp_cStatCur2
               l_cNightsFld = "rs_nights"
               l_cWherePS = "0=0"
               l_cWhereRS = "0=0"
          OTHERWISE
     ENDCASE

     SELECT YEAR(ps_date) AS ps_year, ;
            SUM(ps_amount) AS aa_camount, ;
            SUM(IIF(ar_main = 0, ps_amount, 0.00)) AS aa_camt0, ;
            SUM(IIF(ar_main = 1, ps_amount, 0.00)) AS aa_camt1, ;
            SUM(IIF(ar_main = 2, ps_amount, 0.00)) AS aa_camt2, ;
            SUM(IIF(ar_main = 3, ps_amount, 0.00)) AS aa_camt3, ;
            SUM(IIF(ar_main = 4, ps_amount, 0.00)) AS aa_camt4, ;
            SUM(IIF(ar_main = 5, ps_amount, 0.00)) AS aa_camt5, ;
            SUM(IIF(ar_main = 6, ps_amount, 0.00)) AS aa_camt6, ;
            SUM(IIF(ar_main = 7, ps_amount, 0.00)) AS aa_camt7, ;
            SUM(IIF(ar_main = 8, ps_amount, 0.00)) AS aa_camt8, ;
            SUM(IIF(ar_main = 9, ps_amount, 0.00)) AS aa_camt9 ;
          FROM (l_curPost) ;
          WHERE &l_cWherePS ;
          GROUP BY 1 ;
          ORDER BY 1 ;
          INTO CURSOR (l_curPsAstat)

     SELECT rs_year, ;
            SUM(IIF(INLIST(rs_status, "NS", "CXL"), 0, &l_cNightsFld)) AS aa_cnights, ;
            COUNT(*) AS aa_cres, ;
            SUM(IIF(rs_status = "NS",  rs_res, 0)) AS aa_cns, ;
            SUM(IIF(rs_status = "CXL", rs_res, 0)) AS aa_ccxl ;
          FROM (l_curResr) ;
          WHERE &l_cWhereRS ;
          GROUP BY 1 ;
          ORDER BY 1 ;
          INTO CURSOR (l_curRsAstat)

     DO CASE
          CASE i = 1     && Fill Compare cursor
               l_nFirstYear = YEAR(lp_dSysDate)-1
          CASE i = 2     && Fill Year cursor
               l_nFirstYear = YEAR(lp_dSysDate)
               IF NOT EMPTY(&l_curPsAstat..ps_year)
                    l_nFirstYear = MIN(l_nFirstYear, &l_curPsAstat..ps_year)
               ENDIF
               IF NOT EMPTY(&l_curRsAstat..rs_year)
                    l_nFirstYear = MIN(l_nFirstYear, &l_curRsAstat..rs_year)
               ENDIF
          OTHERWISE
     ENDCASE

     MakeIntervalDataCursor(l_nFirstYear, YEAR(l_dEndCY), "aa_year", l_curYear)

     SELECT aa_year, ;
            CAST(NVL(aa_camount, 0.00) AS Numeric(14,2)) AS aa_camount, ;
            CAST(NVL(aa_camt0,   0.00) AS Numeric(14,2)) AS aa_camt0, ;
            CAST(NVL(aa_camt1,   0.00) AS Numeric(14,2)) AS aa_camt1, ;
            CAST(NVL(aa_camt2,   0.00) AS Numeric(14,2)) AS aa_camt2, ;
            CAST(NVL(aa_camt3,   0.00) AS Numeric(14,2)) AS aa_camt3, ;
            CAST(NVL(aa_camt4,   0.00) AS Numeric(14,2)) AS aa_camt4, ;
            CAST(NVL(aa_camt5,   0.00) AS Numeric(14,2)) AS aa_camt5, ;
            CAST(NVL(aa_camt6,   0.00) AS Numeric(14,2)) AS aa_camt6, ;
            CAST(NVL(aa_camt7,   0.00) AS Numeric(14,2)) AS aa_camt7, ;
            CAST(NVL(aa_camt8,   0.00) AS Numeric(14,2)) AS aa_camt8, ;
            CAST(NVL(aa_camt9,   0.00) AS Numeric(14,2)) AS aa_camt9, ;
            CAST(NVL(aa_cres,    0) AS Numeric(10)) AS aa_cres, ;
            CAST(NVL(aa_cnights, 0) AS Numeric(10)) AS aa_cnights, ;
            CAST(NVL(aa_cns,     0) AS Numeric(10)) AS aa_cns, ;
            CAST(NVL(aa_ccxl,    0) AS Numeric(10)) AS aa_ccxl ;
          FROM (l_curYear) ;
          LEFT JOIN (l_curPsAstat) ON aa_year = ps_year ;
          LEFT JOIN (l_curRsAstat) ON aa_year = rs_year ;
          ORDER BY 1 ;
          INTO CURSOR (l_cStatCur)
ENDFOR

DClose(l_curReservat)
DClose(l_curHistres)
DClose(l_curPost)
DClose(l_curResr)
DClose(l_curPsAstat)
DClose(l_curRsAstat)
DClose(l_curYear)

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE PSCGetNights
LPARAMETERS tnYear, tdArrdate, tdDepdate, tdToDate
LOCAL lnNights, ldStart, ldEnd

IF EMPTY(tdArrdate) OR EMPTY(tdDepdate) OR tdArrdate = tdDepdate
     lnNights = 0
ELSE
     ldStart = DATE(tnYear,1,1)
     DO CASE
          CASE EMPTY(tdToDate)
               ldEnd = DATE(tnYear,12,31)
          CASE tnYear = YEAR(tdToDate)
               ldEnd = tdToDate
          OTHERWISE
               ldEnd = GetRelDate(tdToDate, TRANSFORM(tnYear-YEAR(tdToDate))+"Y")
     ENDCASE
     lnNights = MAX(0, MIN(tdDepdate-1, ldEnd) - MAX(ldStart, tdArrdate) + 1)
ENDIF

RETURN lnNights
ENDPROC
*