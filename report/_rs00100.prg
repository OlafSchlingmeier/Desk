PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.03"
RETURN tcVersion
ENDPROC
*
PROCEDURE _rs00100
LOCAL lcPreproc1, lcPreproc2, lcPreproc3

lcPreproc1 = SYS(2015)
lcPreproc2 = SYS(2015)
lcPreproc3 = SYS(2015)

SELECT rs_arrdate, rs_depdate, rs_rooms, rs_adults, rs_childs, rs_childs2, rs_childs3, ;
	rs_roomnum, rs_share, rs_roomtyp, rs_ratecod, rs_rate, rs_agent, rs_saddrid, rs_sname, ;
	b.ad_company AS company, rs_note, rs_status, rs_arrtime, rs_group, rs_paymeth, ;
 	ICASE(!EMPTY(rs_rgid), rs_lname, rs_compid = rs_addrid AND rs_apid > 0, ap_lname, a.ad_lname) AS ad_lname, ;
 	ICASE(!EMPTY(rs_rgid), rs_fname, rs_compid = rs_addrid AND rs_apid > 0, ap_fname, a.ad_fname) AS ad_fname, ;
 	ICASE(!EMPTY(rs_rgid), rs_title, rs_compid = rs_addrid AND rs_apid > 0, ap_title, a.ad_title) AS ad_title, ;
	PADR(IIF(!EMPTY(rs_saddrid), TRIM(c.ad_lname) + " " + TRIM(c.ad_fname) + ", " + TRIM(c.ad_title), TRIM(rs_sname)),50) AS sharename, ;
	a.ad_addrid, a.ad_city, a.ad_member, rt_group, NVL(rm_rpseq,0) AS rm_rpseq ;
	FROM reservat ;
	LEFT JOIN room ON rs_roomnum = rm_roomnum ;
	INNER JOIN roomtype on rs_roomtyp = rt_roomtyp ;
	INNER JOIN apartner ON IIF(!EMPTY(rs_apid), rs_apid, -9999) = ap_apid ;
	INNER JOIN address a ON IIF(!EMPTY(rs_addrid), rs_addrid, rs_compid) = a.ad_addrid ;
	INNER JOIN address b ON IIF(!EMPTY(rs_compid), rs_compid, rs_addrid) = b.ad_addrid ;
	INNER JOIN address c ON ICASE(!EMPTY(rs_saddrid), rs_saddrid, !EMPTY(rs_addrid), rs_addrid, rs_compid) = c.ad_addrid ;
	WHERE BETWEEN(rs_arrdate, Min1, Max1) AND !INLIST(rt_group, 2, 3) AND !INLIST(rs_status, 'NS', 'CXL') ;
	ORDER BY 1 ;
	INTO CURSOR (lcPreproc1)

SELECT ad_addrid, SUM(IIF(INLIST(rs_status,"NS","CXL"),0,rs_nights)) AS rs_cnights, SUM(IIF(INLIST(rs_status,"NS","CXL"),0,1)) AS rs_cres, ;
	SUM(IIF(rs_status="NS",1,0)) AS rs_cns, SUM(IIF(rs_status="CXL",1,0)) AS rs_ccxl ;
	FROM (SELECT pp1.ad_addrid, IIF(rs1.rs_depdate=rs1.rs_arrdate, 1, rs1.rs_depdate-rs1.rs_arrdate) AS rs_nights, rs1.rs_status FROM reservat rs1 ;
	LEFT JOIN roomtype rt1 ON rs1.rs_roomtyp = rt1.rt_roomtyp ;
	INNER JOIN (lcPreproc1) pp1 ON rs1.rs_addrid = pp1.ad_addrid OR rs1.rs_compid = pp1.ad_addrid OR rs1.rs_agentid = pp1.ad_addrid ;
	WHERE rs1.rs_arrdate < min1 AND INLIST(rt1.rt_group,1,4) AND rt1.rt_vwsum ;
	UNION ALL ;
	SELECT pp1.ad_addrid, IIF(hr_depdate=hr_arrdate, 1, hr_depdate-hr_arrdate), hr_status FROM histres ;
	LEFT JOIN roomtype rt1 ON hr_roomtyp = rt1.rt_roomtyp ;
	INNER JOIN (lcPreproc1) pp1 ON hr_addrid = pp1.ad_addrid OR hr_compid = pp1.ad_addrid OR hr_agentid = pp1.ad_addrid ;
	WHERE hr_arrdate < min1 AND INLIST(rt1.rt_group,1,4) AND rt1.rt_vwsum AND NOT hr_rsid IN (SELECT rs_rsid FROM reservat)) pp2 ;
	GROUP BY 1 ;
	INTO CURSOR (lcPreproc2)

SELECT ad_addrid, SUM(ps_amount) AS rs_camount ;
	FROM (SELECT pp1.ad_addrid, ps_amount FROM post ;
	INNER JOIN reservat rs1 ON ps_reserid = rs_reserid ;
	INNER JOIN (lcPreproc1) pp1 ON rs1.rs_addrid = pp1.ad_addrid OR rs1.rs_compid = pp1.ad_addrid OR rs1.rs_agentid = pp1.ad_addrid ;
	WHERE NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) ;
	UNION ALL ;
	SELECT pp1.ad_addrid, hp_amount FROM histpost ;
	INNER JOIN histres ON hp_reserid = hr_reserid ;
	INNER JOIN (lcPreproc1) pp1 ON hr_addrid = pp1.ad_addrid OR hr_compid = pp1.ad_addrid OR hr_agentid = pp1.ad_addrid ;
	WHERE NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split) AND NOT hp_reserid IN (SELECT rs_reserid FROM reservat)) pp2 ;
	GROUP BY 1 ;
	INTO CURSOR (lcPreproc3)
	
SELECT &lcPreproc1..*, NVL(rs_cnights,00000000) AS rs_cnights, NVL(rs_cres,0000) AS rs_cres, NVL(rs_cns,0000) AS rs_cns, NVL(rs_ccxl,0000) AS rs_ccxl, NVL(rs_camount,0.00) AS rs_camount ;
	FROM (lcPreproc1) ;
	LEFT JOIN (lcPreproc2) ON &lcPreproc1..ad_addrid = &lcPreproc2..ad_addrid ;
	LEFT JOIN (lcPreproc3) ON &lcPreproc1..ad_addrid = &lcPreproc3..ad_addrid ;
	INTO CURSOR Preproc

USE IN (lcPreproc1)
USE IN (lcPreproc2)
USE IN (lcPreproc3)
ENDPROC
*