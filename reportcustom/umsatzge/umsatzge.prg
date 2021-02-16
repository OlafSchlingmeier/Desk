
PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.02"
RETURN tcVersion
ENDPROC
*
PROCEDURE umsatzge
LOCAL l_cSql, l_nRev, l_nManagerGroup, l_dPrevYearMin, l_dPrevYearMax, l_oData

* For revenue, get only article from article manager group defined in l_nManagerGroup variable !
l_nManagerGroup = 1

umsatzge_getrevenue(min2, max2, l_nManagerGroup)

SELECT rt_buildng, rt_lang3, rescode AS rs_roomtyp, rd_roomtyp, CAST(SUM(ps_amount) AS Numeric(12,2)) AS c_rev, CAST(0 AS Numeric(12,2)) AS c_revp ;
     FROM curpost ;
     INNER JOIN roomtype ON rescode = rt_roomtyp AND INLIST(rt_group, 1, 4) AND rt_vwsum ;
     INNER JOIN rtypedef ON rt_rdid = rd_rdid ;
     WHERE (EMPTY(rt_buildng) OR EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND ;
     (EMPTY(min1) OR c_roomtyp = min1) ;
     GROUP BY 1, 2, 3, 4 ;
     ORDER BY 1,3 ;
     INTO CURSOR preproc READWRITE

l_dPrevYearMin = GetRelDate(min2, "-1Y")
l_dPrevYearMax = GetRelDate(max2, "-1Y")

umsatzge_getrevenue(l_dPrevYearMin, l_dPrevYearMax, l_nManagerGroup)

SELECT rt_buildng, rt_lang3, rescode AS rs_roomtyp, rd_roomtyp, CAST(SUM(ps_amount) AS Numeric(12,2)) AS c_revp ;
     FROM curpost ;
     INNER JOIN roomtype ON rescode = rt_roomtyp AND INLIST(rt_group, 1, 4) AND rt_vwsum ;
     INNER JOIN rtypedef ON rt_rdid = rd_rdid ;
     WHERE (EMPTY(rt_buildng) OR EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND ;
     (EMPTY(min1) OR c_roomtyp = min1) ;
     GROUP BY 1, 2, 3, 4 ;
     ORDER BY 1,3 ;
     INTO CURSOR cpast1

SCAN ALL
     SELECT preproc
     LOCATE FOR rt_buildng = cpast1.rt_buildng AND rs_roomtyp = cpast1.rs_roomtyp
     IF FOUND()
          REPLACE c_revp WITH cpast1.c_revp IN preproc
     ELSE
          SELECT cpast1
          SCATTER MEMO NAME l_oData
          INSERT INTO preproc FROM NAME l_oData
     ENDIF
ENDSCAN

dclose("cpast1")
dclose("curpost")

SELECT rt_buildng, rt_lang3, rs_roomtyp, rd_roomtyp, c_rev, c_revp FROM preproc WHERE 1=1 ORDER BY 1,4 INTO CURSOR preproc

RETURN .T.
ENDPROC
*
PROCEDURE umsatzge_getrevenue
LPARAMETERS lp_dFrom, lp_dTo, lp_nManagerGroup
LOCAL min1, max1, min2, max2, tcResFilter, lcLabel, cmaingroup

IF NOT USED("param")
     USE data\param IN 0 SHARED
ENDIF

IF EMPTY(lp_dFrom)
     RETURN .T.
ENDIF

min1 = lp_dFrom

IF EMPTY(lp_dTo)
     RETURN .T.
ENDIF

max1 = lp_dTo

tcResFilter = ".T."
lcLabel = "ROOMTYP"

*******************************************************************************************
*
* SQL copied from preproc _fc05000 version 8.30
*
* BEGIN
*
*******************************************************************************************

lcCodeField = IIF(lcLabel = "RATECOD", "ps_ratecod", "NVL(rs1.rs_" + lcLabel + ",rs2.rs_" + lcLabel + ")")
lcCodeHField = IIF(lcLabel = "RATECOD", "hp_ratecod", "NVL(hr1.hr_" + lcLabel + ",hr2.hr_" + lcLabel + ")")
lcCodeSField = IIF(lcLabel = "RATECOD", "rl_ratecod", "rs_" + lcLabel)
lcVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")
SELECT NVL(ar_main,0) AS ar_main, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ;
       CAST(NVL(NVL(NVL(ri1.ri_roomtyp,rs1.rs_roomtyp),NVL(ri2.ri_roomtyp,rs2.rs_roomtyp)),"") AS C(4)) AS c_roomtyp, ar_buildng AS c_buildng, ;
       IIF(ps_origid<1, 001, NVL(NVL(rs1.rs_rooms,rs2.rs_rooms),000)) AS resrooms, IIF(ps_origid<1, [OUT], NVL(NVL(rs1.rs_status,rs2.rs_status),[   ])) AS resstatus, ;
       PADR(NVL(IIF(ps_origid<1 OR EMPTY(&lcCodeField), .NULL., &lcCodeField),'*****'),10) AS rescode ;
     FROM post ;
     LEFT JOIN reservat rs1 ON rs1.rs_reserid = ps_origid ;
     LEFT JOIN resrooms ri1 ON ri1.ri_reserid = ps_origid AND NOT EMPTY(ri1.ri_roomtyp) AND BETWEEN(EVL(ps_rdate,ps_date), ri1.ri_date, ri1.ri_todate) ;
     LEFT JOIN reservat rs2 ON rs2.rs_reserid = ps_reserid ;
     LEFT JOIN resrooms ri2 ON ri2.ri_reserid = ps_reserid AND NOT EMPTY(ri2.ri_roomtyp) AND BETWEEN(EVL(ps_rdate,ps_date), ri2.ri_date, ri2.ri_todate) ;
     LEFT JOIN article ON ps_artinum = ar_artinum AND ar_mangrp = lp_nManagerGroup ;
     WHERE ps_reserid > 0 AND BETWEEN(ps_date, min1, max1) AND NOT EMPTY(ps_artinum) AND ar_artityp = 1 AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), hp_amount, hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, ;
       NVL(NVL(NVL(ri1.ri_roomtyp,hr1.hr_roomtyp),NVL(ri2.ri_roomtyp,hr2.hr_roomtyp)),""), ar_buildng, ;
       IIF(hp_origid<1, 001, NVL(NVL(hr1.hr_rooms,hr2.hr_rooms),000)), IIF(hp_origid<1, [OUT], NVL(NVL(hr1.hr_status,hr2.hr_status),[   ])), ;
       PADR(NVL(IIF(hp_origid<1 OR EMPTY(&lcCodeHField), .NULL., &lcCodeHField),'*****'),10) ;
     FROM histpost ;
     LEFT JOIN post ON ps_postid = hp_postid ;
     LEFT JOIN histres hr1 ON hr1.hr_reserid = hp_origid ;
     LEFT JOIN histres hr2 ON hr2.hr_reserid = hp_reserid ;
     LEFT JOIN hresroom ri1 ON ri1.ri_reserid = hp_origid AND NOT EMPTY(ri1.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), ri1.ri_date, ri1.ri_todate) ;
     LEFT JOIN hresroom ri2 ON ri2.ri_reserid = hp_reserid AND NOT EMPTY(ri2.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), ri2.ri_date, ri2.ri_todate) ;
     LEFT JOIN article ON hp_artinum = ar_artinum AND ar_mangrp = lp_nManagerGroup ;
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, min1, max1) AND ISNULL(ps_postid) AND NOT EMPTY(hp_artinum) AND ar_artityp = 1 AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), rl_price*rl_units, IIF(NVL(ar_vat,0)=0,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=1,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=2,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=3,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=4,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=5,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=6,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=7,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=8,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=9,&lcVatnumMacro,0), ;
       NVL(NVL(ri_roomtyp,rs_roomtyp),""), ar_buildng, ;
       NVL(rs_rooms,000), NVL(rs_status,[   ]), PADR(NVL(IIF(EMPTY(&lcCodeSField), .NULL., &lcCodeSField),'*****'),10) ;
     FROM ressplit ;
     LEFT JOIN reservat ON rs_rsid = rl_rsid ;
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND NOT EMPTY(ri_roomtyp) AND BETWEEN(EVL(rl_rdate,rl_date), ri_date, ri_todate) ;
     LEFT JOIN article ON rl_artinum = ar_artinum  AND ar_mangrp = lp_nManagerGroup ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rl_date > rs_ratedat AND BETWEEN(rl_date, min1, max1) AND ar_artityp = 1 AND NOT EMPTY(rl_price*rl_units) AND ;
          NOT INLIST(rs_status, "OUT", "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter ;
     INTO CURSOR curPost

*******************************************************************************************
*
* SQL copied from preproc _fc05000 version 8.30
*
* END
*
*******************************************************************************************


RETURN .T.
ENDPROC