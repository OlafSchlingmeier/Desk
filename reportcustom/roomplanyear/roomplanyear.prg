*
PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE RoomplanYear
LOCAL l_nSelect, l_cSql

l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT ri.*, CAST("" AS C(40)) AS c_rscapt, CAST(NVL(adc.ad_company,"") AS C(50)) AS c_company, CAST(NVL(adl.ad_lname,"") AS C(30)) AS l_lname, CAST(NVL(adl.ad_fname,"") AS C(20)) AS l_fname, CAST(NVL(ads.ad_lname,"") AS C(30)) AS s_lname FROM (
		SELECT ri_roomnum, ri_date, ri_todate, rs_reserid, rs_arrdate, rs_depdate, rs_addrid, rs_compid, rs_saddrid, rs_lname, rs_fname, rs_sname, rs_status FROM resrooms
			INNER JOIN roomtype ON ri_roomtyp = rt_roomtyp
			INNER JOIN reservat ON ri_reserid = rs_reserid
			WHERE ri_date <= <<SqlCnv(DATE(min1,12,31),.T.)>> AND ri_todate >= <<SqlCnv(DATE(min1,1,1),.T.)>> AND NOT INLIST(rs_status, 'CXL', 'NS ') AND 
			<<IIF(EMPTY(min2), "rt_group = 1 AND NOT EMPTY(ri_roomnum)", "ri_roomnum = " + SqlCnv(min2,.T.))>>
		UNION ALL
		SELECT ri_roomnum, ri_date, ri_todate, hr_reserid, hr_arrdate, hr_depdate, hr_addrid, hr_compid, hresext.rs_saddrid, hr_lname, hr_fname, hresext.rs_sname, hr_status FROM hresroom
			INNER JOIN roomtype ON ri_roomtyp = rt_roomtyp
			INNER JOIN histres ON ri_reserid = hr_reserid
			INNER JOIN hresext ON ri_reserid = hresext.rs_reserid
			LEFT JOIN reservat ON ri_reserid = reservat.rs_reserid
			WHERE ISNULL(rs_addrid) AND ri_date <= <<SqlCnv(DATE(min1,12,31),.T.)>> AND ri_todate >= <<SqlCnv(DATE(min1,1,1),.T.)>> AND NOT INLIST(hr_status, 'CXL', 'NS ') AND 
			<<IIF(EMPTY(min2), "rt_group = 1 AND NOT EMPTY(ri_roomnum)", "ri_roomnum = " + SqlCnv(min2,.T.))>>) ri
		LEFT JOIN address adl ON adl.ad_addrid = ri.rs_addrid
		LEFT JOIN address adc ON adc.ad_addrid = ri.rs_compid
		LEFT JOIN address ads ON ads.ad_addrid = ri.rs_saddrid
		ORDER BY ri_roomnum, ri_date
ENDTEXT
SqlCursor(l_cSql,"PreProc",,,,,,.T.)
REPLACE c_rscapt WITH ALLTRIM(IIF(EMPTY(rs_lname),c_company,ALLTRIM(PROPER(NVL(l_fname,"")))+" "+ALLTRIM(PROPER(NVL(l_lname,"")))+IIF(EMPTY(rs_sname),"","/"+ALLTRIM(PROPER(NVL(s_lname,"")))))) ALL IN PreProc

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*