PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.10"
RETURN tcVersion
ENDPROC
*
PROCEDURE _tr00100
WAIT WINDOW NOWAIT "Preprocessing..."

PpDo()

WAIT CLEAR
ENDPROC
*
PROCEDURE PpDo
LOCAL lcSql

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
SELECT *, tg_tables AS c_tables, tg_adults AS c_adults, tg_childs AS c_childs,
	CAST(CHRTRAN(EVL(tr_note,tg_note),CHR(13)+CHR(10),"  ") AS C(100)) AS c_note, EMPTY(tg_tables) AS c_ord
	FROM __#ARG.tableres#__
	LEFT JOIN __#ARG.tblrsgrp#__ ON tg_tgid = tr_tgid
	LEFT JOIN __#ARG.location#__ ON BETWEEN(tr_tablenr, lc_begin, lc_end)
	LEFT JOIN __#ARG.desktblr#__ ON dr_trid = tr_trid
	LEFT JOIN tblDayParts ON c_dpid = min3
	WHERE tr_tgid > 0 AND BETWEEN(tr_sysdate, min1, max1) AND tr_tablenr >= 0 AND (min2 = 0 OR lc_locnr = min2) AND NOT INLIST(tr_status, 4, 5) AND
		(min3 = 0 OR (LEFT(TTOC(tr_from,2),5) < c_end OR LEFT(TTOC(tr_from,2),5) < c_nstart AND LEFT(TTOC(tr_to,2),5) <= c_nstart) AND LEFT(TTOC(tr_to,2),5) > c_start)
	GROUP BY tr_tgid
UNION ALL
SELECT *, IIF(tr_tablenr = 0, "", TRANSFORM(tr_tablenr)), tr_persons, tr_childs,
	CHRTRAN(tr_note,CHR(13)+CHR(10),"  "), EMPTY(tr_tablenr) AS c_ord
	FROM __#ARG.tableres#__
	LEFT JOIN __#ARG.tblrsgrp#__ ON tg_tgid = tr_tgid
	LEFT JOIN __#ARG.location#__ ON BETWEEN(tr_tablenr, lc_begin, lc_end)
	LEFT JOIN __#ARG.desktblr#__ ON dr_trid = tr_trid
	LEFT JOIN tblDayParts ON c_dpid = min3
	WHERE tr_tgid = 0 AND BETWEEN(tr_sysdate, min1, max1) AND tr_tablenr >= 0 AND (min2 = 0 OR lc_locnr = min2) AND NOT INLIST(tr_status, 4, 5) AND
		(min3 = 0 OR (LEFT(TTOC(tr_from,2),5) < c_end OR LEFT(TTOC(tr_from,2),5) < c_nstart AND LEFT(TTOC(tr_to,2),5) <= c_nstart) AND LEFT(TTOC(tr_to,2),5) > c_start)
	ORDER BY tr_sysdate, c_ord, lc_begin, tr_tablenr
ENDTEXT
SqlCursor(lcSql ,"PreProc",,,,,,.T.)
BLANK FIELDS dr_rlid FOR ISNULL(dr_rlid) 
BLANK FIELDS lc_locnr FOR ISNULL(lc_locnr) 
INDEX ON dr_rlid TAG dr_rlid
SET ORDER TO

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT -rl_rlid AS tr_trid, rl_rsid AS tr_rsid, rl_rdate AS tr_sysdate,
	DTOT(rl_rdate) AS tr_from, DTOT(rl_rdate) AS tr_to, ad_phone AS tr_phone,
	CAST(NVL(NVL(a1.ar_lang<<g_Langnum>>, a2.ar_lang<<g_Langnum>>),'') AS Character(100)) AS c_note,
	CAST(rs_adults AS Integer) AS c_adults,
	CAST(rs_childs+rs_childs2+rs_childs3 AS Integer) AS c_childs,
	CAST(EVL(rs_addrid,ad_addrid) AS Numeric(8)) AS tr_addrid,
	CAST(EVL(rs_title,ad_title) AS Character(25)) AS tr_title,
	CAST(EVL(rs_lname,ad_lname) AS Character(30)) AS tr_lname,
	CAST(EVL(rs_fname,ad_fname) AS Character(20)) AS tr_fname,
	CAST('<<g_userid>>' AS Character(10)) AS tr_userid,
	CAST('<<g_userid>>' AS Character(10)) AS tr_usrname
	FROM Ressplit
	LEFT JOIN Resrart rra ON rra.ra_rsid = rl_rsid AND rra.ra_raid = rl_raid AND rra.ra_ratecod = rl_ratecod
	LEFT JOIN Ratearti ra ON ra.ra_raid = rl_raid AND ra.ra_ratecod = rl_ratecod
	LEFT JOIN Article a1 ON a1.ar_artinum = rra.ra_artinum
	LEFT JOIN Article a2 ON a2.ar_artinum = ra.ra_artinum
	INNER JOIN Reservat ON rs_rsid = rl_rsid
	LEFT JOIN Address ON ad_addrid = EVL(rs_addrid, rs_compid)
	WHERE NVL(NVL(rra.ra_atblres, ra.ra_atblres), 0=1) AND INLIST(rs_status, 'DEF', '6PM', 'ASG', 'IN') AND BETWEEN(rl_rdate, min1, max1) AND min2 = 0 AND min3 = 0
ENDTEXT
lcurTrUnassigned = SqlCursor(lcSql,,,,,,,.T.)
DELETE FOR SEEK(-tr_trid, "PreProc", "dr_rlid") IN &lcurTrUnassigned
SELECT PreProc
APPEND FROM DBF(lcurTrUnassigned)
DClose(lcurTrUnassigned)
ENDPROC
*