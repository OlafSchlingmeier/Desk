PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.01"
RETURN tcVersion
ENDPROC
*
PROCEDURE rs0670
LOCAL l_cSql, l_nRev, l_nManagerGroup

* For revenue, get only article from article manager group defined in l_nManagerGroup variable !
l_nManagerGroup = 1

* Get reservations

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT DISTINCT rt_buildng, rs_reserid, rs_rsid, rs_arrdate, rs_depdate, rs_group, rs_roomtyp, rs_roomnum, rs_ratecod, rs_market, rs_source, rs_ratedat, rs_rooms, 
       rs_adults, rs_childs, rs_childs2, rs_childs3, rs_status, .F. AS reshistory, rs_rate, rs_share, 0000000000.00 AS c_rev 
     FROM reservat 
     INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp AND rt_group IN (1,4) 
     WHERE (rs_arrdate <= max3 AND rs_depdate >= min3) AND NOT INLIST(rs_status, "CXL", "NS", "LST") AND 
     (EMPTY(rt_buildng) OR EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND 
     (EMPTY(min1) OR rt_roomtyp = min1) AND 
     (EMPTY(min2) OR rs_roomnum = min2)
UNION ALL 
SELECT DISTINCT rt_buildng, hr_reserid, rs_rsid, hr_arrdate, hr_depdate, hr_group, hr_roomtyp, hr_roomnum, hr_ratecod, hr_market, hr_source, hr_ratedat, hr_rooms, 
       hr_adults, hr_childs, hr_childs2, hr_childs3, hr_status, .T. AS reshistory, rs_rate, hr_share, 0000000000.00 AS c_rev 
     FROM histres 
     INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp AND rt_group IN (1,4) 
     LEFT JOIN reservat ON rs_reserid = hr_reserid 
     WHERE hr_reserid >= 1 AND (hr_arrdate <= max3 AND hr_depdate >= min3) AND ISNULL(rs_reserid) AND NOT INLIST(hr_status, "CXL", "NS", "LST") 
     AND (EMPTY(rt_buildng) OR EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND 
     (EMPTY(min1) OR rt_roomtyp = min1) AND 
     (EMPTY(min2) OR rs_roomnum = min2)
     ORDER BY 1,3
ENDTEXT

l_cSql = l_cSql + " INTO CURSOR preproc READWRITE"

&l_cSql

IF NOT min4
     RETURN .T.
ENDIF

* Get revenue

SELECT histpost
l_cOrderHistPost = ORDER()
SET ORDER TO

SELECT post
l_cOrderPost = ORDER()
SET ORDER TO

SELECT ressplit
l_cOrderResSplit = ORDER()
SET ORDER TO


SELECT preproc

SCAN ALL
     l_nRev = 0.00
     IF reshistory
          SELECT histpost
          SUM hp_amount ;
               FOR ;
                    hp_origid = preproc.rs_reserid AND hp_artinum > 0 AND hp_amount <> 0.00 AND NOT hp_cancel AND hp_window > 0 AND (EMPTY(hp_ratecod) OR hp_split) AND ;
                    SEEK(hp_artinum, "article", "tag1") AND article.ar_mangrp = l_nManagerGroup ;
                    TO l_nRev
     ELSE
          SELECT ressplit
          SUM rl_price*rl_units ;
               FOR ;
                    rl_rsid = preproc.rs_rsid AND rl_date > preproc.rs_ratedat AND rl_price*rl_units <> 0.00 AND ;
                    SEEK(rl_artinum, "article", "tag1") AND article.ar_mangrp = l_nManagerGroup ;
                    TO l_nRevResSplit

          SELECT post
          SUM ps_amount ;
               FOR ;
                    ps_origid = preproc.rs_reserid AND ps_artinum > 0 AND ps_amount <> 0.00 AND NOT ps_cancel AND ps_window > 0 AND (EMPTY(ps_ratecod) OR ps_split) AND ;
                    SEEK(ps_artinum, "article", "tag1") AND article.ar_mangrp = l_nManagerGroup ;
                    TO l_nRevPost

          l_nRev = l_nRevResSplit + l_nRevPost
     ENDIF
     IF l_nRev <> 0.00
          REPLACE c_rev WITH l_nRev IN preproc
     ENDIF
ENDSCAN

SELECT histpost
SET ORDER TO l_cOrderHistPost

SELECT post
SET ORDER TO l_cOrderPost

SELECT ressplit
SET ORDER TO l_cOrderResSplit

SELECT preproc

RETURN .T.
ENDPROC
*