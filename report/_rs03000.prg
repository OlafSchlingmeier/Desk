PROCEDURE PpVersion
PARAMETER cversion
cversion = "2.45"
RETURN
ENDPROC
*
PROCEDURE _RS03000
LOCAL l_cSql, l_nSelect, l_cPostingsCur

l_nSelect = SELECT()

min2 = PADR(ALLTRIM(min2),3)

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT r.*, c1.ar_fcstofs, c1.ar_fcst, c1.units, c1.pp_date, c1.rl_date FROM ( 
     SELECT rs_reserid, rs_arrdate, rs_depdate, rs_roomnum, rs_rmname, rs_lname, rs_group, rs_roomtyp, rs_rooms, 
          rs_ratecod, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_status, 
          ar_fcstofs, ar_fcst, 
          CAST(SUM(rs_rooms*rl_units) AS Numeric(4)) AS units, 
          rl_rdate + ar_fcstofs AS pp_date, 
          rl_date 
          FROM reservat 
          INNER JOIN ressplit ON rs_rsid = rl_rsid 
          INNER JOIN article ON rl_artinum = ar_artinum AND ar_fcst <> '   ' 
          WHERE NOT rs_status IN ('NS ','CXL'<<IIF(_screen.oGlobal.oParam.pa_tentdef,[],[,'TEN'])>>) AND 
          <<IIF(EMPTY(max1),[rl_rdate + ar_fcstofs = ] + sqlcnv(min1,.T.),[rl_rdate + ar_fcstofs BETWEEN ] + sqlcnv(min1,.T.) + [ AND ] + sqlcnv(max1,.T.))>> 
          <<IIF(EMPTY(min2),[],[ AND ar_fcst = ] + sqlcnv(min2,.T.))>> 
          GROUP BY 1, 2, 3, 4 ,5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 20
          ORDER BY 17,5 
     ) c1 INNER JOIN reservat r ON c1.rs_reserid = r.rs_reserid 
ENDTEXT
l_cPostingsCur = sqlcursor(l_cSql)

SELECT * FROM (l_cPostingsCur) INTO CURSOR PreProc

dclose(l_cPostingsCur)

SELECT (l_nSelect)

RETURN .T.
ENDPROC
