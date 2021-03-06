PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE banquetconfirm
LOCAL l_cSql, l_nReserId, l_cCompany, l_cDepartment, l_cStreet, l_cStreet2, l_cCity, l_cTitle, l_cName, l_cGuestName, l_cAllDays, l_cRDate, l_oData, l_nIntId, l_nRevResSplit

l_nReserId = Min1

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT DISTINCT 
     CAST('' AS Char(50)) AS firma,
     CAST('' AS Char(50)) AS abteilg,
     CAST('' AS Char(100)) AS strasse,
     CAST('' AS Char(100)) AS strasse2,
     CAST('' AS Char(50)) AS ort,
     CAST('' AS Char(20)) AS titel,
     CAST('' AS Char(60)) AS name,
     CAST('' AS Char(80)) AS gastname,
     g.ad_company AS g_company, g.ad_departm AS g_departm, g.ad_street AS g_street, g.ad_street2 AS g_street2, g.ad_country AS g_country, 
     g.ad_zip AS g_zip, g.ad_city AS g_city, g.ad_title AS g_title, g.ad_fname AS g_fname, g.ad_lname AS g_lname, g.ad_addrid AS g_addrid, 
     c.ad_company AS c_company, c.ad_departm AS c_departm, c.ad_street AS c_street, c.ad_street2 AS c_street2, c.ad_country AS c_country, 
     c.ad_zip AS c_zip, c.ad_city AS c_city, c.ad_title AS c_title, c.ad_fname AS c_fname, c.ad_lname AS c_lname, c.ad_addrid AS c_addrid, 
     rs_addrid, rs_adults, rs_agent, rs_agentid, rs_allott, rs_altid, rs_apid, rs_apname, rs_arrdate, rs_arrtime, rs_ccnum, rs_childs, rs_childs2, rs_childs3,
     rs_cnfstat, rs_company, rs_compid, rs_created, rs_creatus, rs_depamt1, rs_depamt2, rs_depdat1, rs_depdat2, rs_depdate, rs_deppaid, rs_deppdat, rs_deptime, 
     rs_discnt, rs_feat1, rs_feat2, rs_feat3, rs_fname, rs_group, rs_groupid, rs_invap, rs_invapid, rs_invid, rs_lname, rs_market, rs_note, rs_noteco, rs_optdate, 
     rs_rate, rs_ratecod, rs_ratedat, rs_reserid, rs_rmname, rs_roomlst, rs_roomnum, rs_rooms, rs_roomtyp, rs_rsid, rs_saddrid, rs_share, rs_sname, rs_source, 
     rs_status, rs_title, rs_updated, rs_userid, rs_usrres0, rs_usrres1, rs_usrres2, rs_usrres3, rs_usrres4, rs_usrres5, rs_usrres6, rs_usrres7, rs_usrres8, 
     rs_usrres9, us_cashier, us_dep, us_email, us_fax, us_group, us_id, us_name, us_phone, rt_buildng, rt_group, rt_lang1, rt_lang2, rt_lang3, rt_lang4, rt_lang5, 
     rt_lang6, rt_lang7, rt_lang8, rt_lang9, rt_maxpers, rt_note, rt_roomtyp, ra_amnt, ra_artinum, ra_artityp, ra_exinfo, ra_multipl, ra_note, ra_notef, ra_notep, 
     ra_onlyon, ra_raid, ra_ratecod, ra_ratepct, ra_user1, ra_user2, ra_user3, ra_user4, 
     CAST('' AS Char(40)) AS r_date, 
     ar_lang1, ar_lang2, ar_lang3, ar_lang4, ar_lang5, ar_lang6, ar_lang7, ar_lang8, ar_lang9, 
     2 AS c_resinfo, 
     000 AS c_pos, {} AS c_arrdate, {} AS c_depdate, SPACE(25) AS c_roomtyp, 000 AS c_rooms, 0000000000.00 AS c_revr, 0000000000.00 AS c_revrs, 
     0000000000.00 AS c_reva, 0000000000.00 AS c_revas, 0000000000.00 AS c_revs  
     FROM reservat 
     LEFT JOIN resrart ON rs_rsid = ra_rsid 
     LEFT JOIN article ON ra_artinum = ar_artinum 
     LEFT JOIN address g ON rs_addrid = g.ad_addrid 
     LEFT JOIN address c ON rs_compid = c.ad_addrid 
     LEFT JOIN roomtype ON rs_roomtyp = rt_roomtyp 
     LEFT JOIN user ON us_id = <<sqlcnv(g_userid, .T.)>> 
     WHERE rs_reserid = <<sqlcnv(l_nReserId,.T.)>> 
     ORDER BY ra_artinum 
ENDTEXT

l_cCur = sqlcursor(l_cSql,,,,,,,.T.)

* Determine guest and company address
SELECT (l_cCur)
GO TOP
IF NOT ISNULL(c_addrid)
     * Company
     l_cCompany = c_company
     l_cDepartment = c_departm
     l_cStreet = c_street
     l_cStreet2 = c_street2
     l_cCountry = c_country
     l_cZip = c_zip
     l_cCity = ALLTRIM(IIF(c_country="D", "", ALLTRIM(c_country) + "- ") + TRIM(c_zip) + " " + TRIM(c_city))
     l_cTitle = c_title
     l_cName = ALLTRIM(c_fname) + " " + TRIM(flip(c_lname))
     * Get guest name
     IF ISNULL(g_addrid)
          l_cGuestName = ALLTRIM(TRIM(c_title) + " " + TRIM(c_fname) + " " + TRIM(flip(c_lname)))
     ELSE
          l_cGuestName = ALLTRIM(TRIM(g_title) + " " + TRIM(g_fname) + " " + TRIM(flip(g_lname)))
     ENDIF
ELSE
     * Guest
     l_cCompany = g_company
     l_cDepartment = g_departm
     l_cStreet = g_street
     l_cStreet2 = g_street2
     l_cCountry = g_country
     l_cZip = g_zip
     l_cCity = ALLTRIM(IIF(g_country="D", "", ALLTRIM(g_country) + "- ") + TRIM(g_zip) + " " + TRIM(g_city))
     l_cTitle = g_title
     l_cName = ALLTRIM(g_fname) + " " + TRIM(flip(g_lname))
     l_cGuestName = ALLTRIM(TRIM(g_title) + " " + TRIM(g_fname) + " " + TRIM(flip(g_lname)))
ENDIF



*!*     REPLACE firma    WITH l_cCompany, ;
*!*             abteilg  WITH l_cDepartment, ;
*!*             strasse  WITH l_cStreet, ;
*!*             strasse2 WITH l_cStreet2, ;
*!*             ort      WITH l_cCity, ;
*!*             titel    WITH l_cTitle, ;
*!*             name     WITH l_cName, ;
*!*             gastname WITH l_cGuestName ;
*!*             ALL

l_cAllDays = GetLangText("RESFIX", "TXT_ALL_DAYS")
SCAN ALL
     l_cRDate = ICASE(ISNULL(ra_onlyon),'', EMPTY(ra_onlyon), l_cAllDays, DTOC(rs_arrdate + ra_onlyon - 1))
     REPLACE firma    WITH l_cCompany, ;
             abteilg  WITH l_cDepartment, ;
             strasse  WITH l_cStreet, ;
             strasse2 WITH l_cStreet2, ;
             ort      WITH l_cCity, ;
             titel    WITH l_cTitle, ;
             name     WITH l_cName, ;
             gastname WITH l_cGuestName, ;
             r_date   WITH l_cRDate
ENDSCAN
GO TOP

SELECT (l_cCur)
GO TOP

SELECT ressplit
SUM rl_price*rl_units FOR rl_rsid = &l_cCur..rs_rsid AND rl_price*rl_units <> 0.00 TO l_nRevResSplit

SELECT (l_cCur)
REPLACE c_revas WITH l_nRevResSplit ALL
GO TOP

IF rs_groupid > 0
     l_nIntId = INT(rs_reserid)
     SELECT rs_rsid, rs_roomtyp, rs_arrdate, rs_depdate, SUM(rs_rooms) AS c_rooms ;
          FROM reservat ;
          INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp AND rt_group IN (1,4) ;
          WHERE rs_reserid >= l_nIntId AND rs_reserid < l_nIntId+1 ;
          GROUP BY 1, 2, 3, 4 ;
          ORDER BY 3, 4 ;
          INTO CURSOR c1
     SCAN ALL
          SELECT ressplit
          SUM rl_price*rl_units FOR rl_rsid = c1.rs_rsid AND rl_price*rl_units <> 0.00 TO l_nRevResSplit
          SELECT (l_cCur)
          SCATTER NAME l_oData FIELDS EXCEPT ra_amnt, ra_artinum, ra_artityp, ra_exinfo, ra_multipl, ra_note, ra_notef, ra_notep, ra_onlyon, ra_raid, ra_ratecod, ra_ratepct, ra_user1, ra_user2, ra_user3, ra_user4 MEMO
          l_oData.c_resinfo = 1
          l_oData.c_pos = RECNO("c1")
          l_oData.c_arrdate = c1.rs_arrdate
          l_oData.c_depdate = c1.rs_depdate
          l_oData.c_roomtyp = Get_rt_roomtyp(c1.rs_roomtyp)
          l_oData.c_rooms = c1.c_rooms
          l_oData.c_revr = l_nRevResSplit
          INSERT INTO (l_cCur) FROM NAME l_oData
     ENDSCAN
     SELECT (l_cCur)
     SUM c_revr TO l_nSum
     REPLACE c_revrs WITH l_nSum ALL
ENDIF

SELECT (l_cCur)
GO TOP
l_nSum = c_revas + c_revrs
REPLACE c_revs WITH l_nSum ALL

SELECT * FROM (l_cCur) WHERE 1=1 ORDER BY c_resinfo, ra_artinum INTO CURSOR preproc

dclose("c1")
dclose(l_cCur)

RETURN .T.
ENDPROC
*