****************************************************************************************************************************
*                                                                                                                          *
* procreservattransactions                                                                                                 *
*                                                                                                                          *
* Used to enter reservation data into rsifsync transaction table. Interface service can read this table, and detect        *
* modifications in reservation.                                                                                            *
* After the change is read and stored, the service should set field rq_done to DATETIME(), and delete processed record.    *
* Table rsifsync is set to be packed when the database is reindexed. When necessary, processed records can be found in     *
* rsifsync.dbf file in packed folder.                                                                                      *
*                                                                                                                          *
* Procedure PRT_Import_All should be called for complete transfer of all reservations (except CXL and NS) to interface     *
* When this procedure is called, it should be prevented, that users change reservat table.                                 *
*                                                                                                                          *
****************************************************************************************************************************
LPARAMETERS lp_cResAlias, lp_cMode, lp_cResSplitAlias
LOCAL l_nSelect, l_cRoomTypeOldVal, l_lStandardRoom, l_lWasStandardRoom, l_nRtGroup
PRIVATE p_oData, p_cResAlias, p_cResSplitAlias

p_oData = .NULL.
p_cResAlias = lp_cResAlias
p_cResSplitAlias = IIF(EMPTY(lp_cResSplitAlias), "ressplit" , lp_cResSplitAlias)

****************************************************************************************************************************
*                                                                                                                          *
* lp_cMode - Possible modes                                                                                                *
*                                                                                                                          *
* NEW                                                                                                                      *
* EDIT                                                                                                                     *
* COPY                                                                                                                     *
* CANCELED                                                                                                                 *
*                                                                                                                          *
****************************************************************************************************************************

l_cRoomTypeOldVal = IIF(RECNO(lp_cResAlias) < 0 OR CURSORGETPROP("Buffering", lp_cResAlias)=1, "", OLDVAL("rs_roomtyp",lp_cResAlias))

l_nRtGroup = dblookup("roomtype","tag1",&p_cResAlias..rs_roomtyp,"rt_group")

l_lStandardRoom = INLIST(l_nRtGroup,1,3,4)
l_lWasStandardRoom = NOT EMPTY(l_cRoomTypeOldVal) AND dblookup("roomtype","tag1",l_cRoomTypeOldVal,"INLIST(rt_group,1,3,4)")

IF NOT l_lStandardRoom AND NOT l_lWasStandardRoom
     RETURN .F.
ENDIF

l_nSelect = SELECT()

IF NOT USED("rsifsync")
     openfile(.F.,"rsifsync")
ENDIF

SELECT rsifsync
SCATTER NAME p_oData MEMO BLANK

SELECT &p_cResAlias

p_oData.rq_rsid = rs_rsid
p_oData.rq_start = rs_arrdate
p_oData.rq_end = rs_depdate
p_oData.rq_status = rs_status
p_oData.rq_market = rs_market

IF NOT l_lStandardRoom AND l_lWasStandardRoom
     p_oData.rq_action = "CANCELED"
ELSE
     p_oData.rq_action = lp_cMode
ENDIF

p_oData.rq_notroom = IIF(l_nRtGroup=3,.T.,.F.)
p_oData.rq_rooms = rs_rooms
p_oData.rq_ratedat = rs_ratedat
p_oData.rq_source = rs_source
p_oData.rq_adults = rs_adults
p_oData.rq_child1 = rs_childs
p_oData.rq_child2 = rs_childs2
p_oData.rq_child3 = rs_childs3
p_oData.rq_changes = rs_changes
p_oData.rq_created = rs_created
p_oData.rq_updated = rs_updated
p_oData.rq_timesta = DATETIME()
p_oData.rq_timisec = INT(VAL(RIGHT(TRANSFORM(SECONDS()),3)))

p_oData.rq_rqid = nextid('RSIFSYNC')
INSERT INTO rsifsync FROM NAME p_oData
PRT_GetResRooms()
PRT_GetResSplit()
PRT_GetGuests()
PRT_GetPosts()
REPLACE rq_resgues WITH p_oData.rq_resgues, ;
        rq_respost WITH p_oData.rq_respost, ;
        rq_resroom WITH p_oData.rq_resroom, ;
        rq_resspli WITH p_oData.rq_resspli ;
        IN rsifsync

IF CURSORGETPROP("Buffering", "rsifsync") = 1
     DBTableFlushForce()
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
*******************************************************************************************************
*
* PRT_rsifsync_insert
*
* Used to update changes over reservat record outside from commit transaction block.
* Use it when value in some reservat field is changed directly, and not over checkreservat.msavereser
* method.
*
*******************************************************************************************************
*
PROCEDURE PRT_rsifsync_insert
LPARAMETERS lp_cResAlias, lp_cMode, lp_cResSplitAlias

IF NOT _screen.oglobal.oparam2.pa_restran
     RETURN .T.
ENDIF

IF procreservattransactions(lp_cResAlias, lp_cMode, lp_cResSplitAlias)

     IF CURSORGETPROP("Buffering", "rsifsync") = 1
          FLUSH
     ELSE
          = TABLEUPDATE(.T., .T., "rsifsync")
     ENDIF

ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PRT_GetResRooms
LOCAL l_nSelect, l_nReserId

l_nSelect = SELECT()

l_nReserId = &p_cResAlias..rs_reserid

SELECT ri_date AS c_date, ri_todate+1 AS c_todate, ri_roomtyp AS c_roomtyp, ri_roomnum AS c_roomnum, c_ratecod FROM ( ;
          SELECT rs.rs_reserid, NVL(ri.ri_date, rs.rs_arrdate) AS ri_date, NVL(ri.ri_todate, rs.rs_depdate-1) AS ri_todate, ;
               NVL(ri.ri_roomtyp, rs.rs_roomtyp) AS ri_roomtyp, NVL(ri.ri_roomnum, rs.rs_roomnum) AS ri_roomnum, ;
               CAST(CHRTRAN(LEFT(NVL(rr.rr_ratecod, rs.rs_ratecod),11), "*!", "") AS char(10)) AS c_ratecod ;
               FROM reservat rs WITH (BUFFERING = .T.) ;
               LEFT JOIN resrooms ri WITH (BUFFERING = .T.) ON ri.ri_reserid = rs.rs_reserid ;
               LEFT JOIN resrate rr WITH (BUFFERING = .T.) ON STR(rr.rr_reserid,12,3)+DTOS(rr.rr_date) = STR(ri.ri_reserid,12,3)+DTOS(ri.ri_date) ;
               WHERE rs.rs_reserid = l_nReserId ;
          UNION ;
          SELECT hr.hr_reserid, NVL(hri.ri_date, hr.hr_arrdate), NVL(hri.ri_todate, hr.hr_depdate-1), ;
               NVL(hri.ri_roomtyp, hr.hr_roomtyp), NVL(hri.ri_roomnum, hr.hr_roomnum), ;
               CAST(CHRTRAN(LEFT(NVL(hrr.rr_ratecod, hr.hr_ratecod),11), "*!", "") AS char(10)) ;
               FROM histres hr ;
               LEFT JOIN hresroom hri ON hri.ri_reserid = hr.hr_reserid ;
               LEFT JOIN hresrate hrr ON STR(hrr.rr_reserid,12,3)+DTOS(hrr.rr_date) = STR(hri.ri_reserid,12,3)+DTOS(hri.ri_date) ;
               LEFT JOIN reservat rrs WITH (BUFFERING = .T.) ON rrs.rs_reserid = hr.hr_reserid ;
               WHERE hr.hr_reserid = l_nReserId AND ISNULL(rrs.rs_reserid)) c ;
     ORDER BY 1 ;
     INTO CURSOR resroom1 READWRITE

IF RECCOUNT()>0
     REPLACE c_todate WITH c_todate+1 FOR c_date = c_todate
     p_oData.rq_resroom = PRT_ConvertCursorToXML("resroom1")
ENDIF

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PRT_GetResSplit
LOCAL l_nSelect, l_nRsId

l_nSelect = SELECT()

l_nRsId = &p_cResAlias..rs_rsid

SELECT c_date, c_artinum, c_artityp, c_ratecod, c_amount, c_qty, CAST(pl_numval AS Numeric(5,2)) AS c_vatprc, ar_lang3 AS c_descript, ar_main AS c_main, ar_artityp AS c_atyp ;
     FROM ( ;
          SELECT EVL(rl_rdate,rl_date) AS c_date, rl_artinum AS c_artinum, rl_artityp AS c_artityp, CAST(rl_price AS Numeric(12,2)) AS c_amount, rl_units AS c_qty, LEFT(rl_ratecod,10) AS c_ratecod ;
               FROM &p_cResSplitAlias WITH (BUFFERING = .T.) ;
               WHERE rl_rsid = l_nRsId ;
     ) c1 ;
     INNER JOIN article ON c_artinum = ar_artinum  ;
     INNER JOIN picklist ON pl_label = 'VATGROUP  ' AND pl_numcod = ar_vat ;
     WHERE c_qty <> 0 ;
     ORDER BY c_date, c_artityp, c_artinum ;
     INTO CURSOR resspli1

IF RECCOUNT()>0
     p_oData.rq_resspli = PRT_ConvertCursorToXML("resspli1")
ENDIF

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PRT_GetGuests
LOCAL l_nSelect, l_nRsId
l_nSelect = SELECT()

l_nRsId = &p_cResAlias..rs_rsid

SELECT NVL(a1.ad_birth, {}) AS a1_birth, NVL(a1.ad_zip,'') AS a1_zip, NVL(a1.ad_city,'') AS a1_city, NVL(a1.ad_country,'') AS a1_country, ;
     NVL(a1.ad_lang,'') AS a1_lang, NVL(a1.ad_state,'') AS a1_state, NVL(p1.pl_lang3,'') AS a1_cdescript, ;
     NVL(a2.ad_birth,{}) AS a2_birth, NVL(a2.ad_zip,'') AS a2_zip, NVL(a2.ad_city,'') AS a2_city, NVL(a2.ad_country,'') AS a2_country, ;
     NVL(a2.ad_lang,'') AS a2_lang, NVL(a2.ad_state,'') AS a2_state, NVL(p2.pl_lang3,'') AS a2_cdescript ;
     FROM &p_cResAlias WITH (BUFFERING = .T.) ;
     LEFT JOIN address a1 ON rs_addrid = a1.ad_addrid ;
     LEFT JOIN picklist p1 ON a1.ad_country = p1.pl_charcod AND p1.pl_label = 'COUNTRY' ;
     LEFT JOIN address a2 ON rs_saddrid = a2.ad_addrid ;
     LEFT JOIN picklist p2 ON a2.ad_country = p2.pl_charcod AND p2.pl_label = 'COUNTRY' ;
     WHERE rs_rsid = l_nRsId ;
     INTO CURSOR resgues1

IF RECCOUNT()>0
     p_oData.rq_resgues = PRT_ConvertCursorToXML("resgues1")
ENDIF

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PRT_GetPosts
LOCAL l_nSelect, l_nReserId

l_nSelect = SELECT()

IF NOT USED("histpost")
     openfile(,"histpost")
ENDIF
l_nReserId = &p_cResAlias..rs_reserid

SELECT c_date, c_artinum, 0 AS c_artityp, c_ratecod, c_amount, c_qty, CAST(pl_numval AS Numeric(5,2)) AS c_vatprc, ar_lang3 AS c_descript, ar_main AS c_main, ar_artityp AS c_atyp ;
     FROM ( ;
          SELECT EVL(ps_rdate,ps_date) AS c_date, ps_artinum AS c_artinum, CAST(ps_price AS Numeric(12,2)) AS c_amount, ps_units AS c_qty, LEFT(ps_ratecod,10) AS c_ratecod ;
               FROM post ;
               WHERE ps_origid = l_nReserId AND NOT ps_cancel AND ps_artinum > 0 AND ps_window > 0 AND (ps_ratecod = '          ' OR ps_split) ;
          UNION ALL ;
          SELECT EVL(hp_rdate,hp_date), hp_artinum, hp_price, hp_units, LEFT(hp_ratecod,10) ;
               FROM histpost ;
               LEFT JOIN post ON hp_postid = ps_postid ;
               WHERE hp_origid = l_nReserId AND NOT hp_cancel AND hp_artinum > 0 AND hp_window > 0 AND (hp_ratecod = '          ' OR hp_split) AND ISNULL(ps_postid) ;
     ) c1 ;
     INNER JOIN article ON c_artinum = ar_artinum ;
     INNER JOIN picklist ON pl_label = 'VATGROUP  ' AND pl_numcod = ar_vat ;
     WHERE c_qty <> 0 ;
     ORDER BY c_date, c_artityp, c_artinum ;
     INTO CURSOR respost1

IF RECCOUNT()>0
     p_oData.rq_respost = PRT_ConvertCursorToXML("respost1")
ENDIF

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PRT_ConvertCursorToXML
LPARAMETERS lp_cCursor
LOCAL l_cXML
l_cXML = ""
CURSORTOXML(lp_cCursor,"l_cXML",3,32+2+4,0,"1")
RETURN l_cXML
ENDPROC
*
PROCEDURE PRT_Import_All
LOCAL l_nSelect, l_cOrder, l_nTotal, l_lAbort, l_dImportFrom, l_tStartTime, l_nSec

IF NOT yesno("Achtung! Alle Datensätze von rsifsync löschen und importieren von reservat und histres?" + CHR(13) + CHR(13) + ;
             "(Es sollen keine Änderungen in reservat Tabelle passieren, wenn dieses Import läuft!)")
     RETURN .T.
ENDIF

l_tStartTime = DATETIME()
= loGdata(TRANSFORM(DATETIME())+"|"+"Start|UserId: "+g_userid+"|SysDate:"+TRANSFORM(sysdate())+"|Action:IMPORT","rsifsync.log")

*********************************************************
* Needed for LASTKEY(), to prevent reading last ESC     *
KEYBOARD CHR(13)
INKEY()
*********************************************************

l_nSelect = SELECT()

PRT_Import_All_OpenTables()

WAIT WINDOW "Deleting all records from rsifsync" NOWAIT

SELECT rsifsync
DELETE ALL

****************************************************************************************************************************
*                                                                                                                          *
* First import all reservations from histres table, but only those which doesn't exists in reservat                        *
*                                                                                                                          *
****************************************************************************************************************************

SELECT rs_rsid, rs_arrdate, rs_depdate, rs_status, rs_market, rs_roomtyp, rs_rooms, rs_roomnum, rs_ratecod, rs_rate, rs_ratedat, ;
     rs_source, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_created, rs_updated, rs_changes, rs_addrid, rs_saddrid, rs_reserid ;
     FROM reservat ;
     WHERE 1=0 ;
     INTO CURSOR restemp1 READWRITE

SELECT histres

l_cOrder = ORDER()

SET ORDER TO

l_dImportFrom = sysdate() - 365 * 2 && Get all reservations from 2 years in the past until now

l_nTotal = RECCOUNT()

SCAN FOR hr_reserid > 0 AND NOT INLIST(hr_status, "CXL", "NS ") AND NOT SEEK(hr_rsid, "reservat", "tag33") AND ;
           hr_depdate > l_dImportFrom AND dblookup("roomtype","tag1",hr_roomtyp,"INLIST(rt_group,1,3,4)")

     WAIT WINDOW "Importing from histres ("+TRANSFORM(ROUND(RECNO()/l_nTotal*100,2))+")%. hr_reserid: " + TRANSFORM(hr_reserid) NOWAIT
     FNDoEvents()
     IF LASTKEY()=27
          l_lAbort = .T.
          EXIT
     ENDIF
 
     SELECT restemp1
     ZAP
     SCATTER NAME l_oData MEMO BLANK
     SELECT histres
     l_oData.rs_rsid = hr_rsid
     l_oData.rs_arrdate = hr_arrdate
     l_oData.rs_depdate = hr_depdate
     l_oData.rs_status = hr_status
     l_oData.rs_market = hr_market
     l_oData.rs_roomtyp = hr_roomtyp
     l_oData.rs_rooms = hr_rooms
     l_oData.rs_roomnum = hr_roomnum
     l_oData.rs_ratecod = hr_ratecod
     l_oData.rs_rate = hr_rate
     l_oData.rs_source = hr_source
     l_oData.rs_adults = hr_adults
     l_oData.rs_childs = hr_childs
     l_oData.rs_childs2 = hr_childs2
     l_oData.rs_childs3 = hr_childs3
     l_oData.rs_created = hr_created
     l_oData.rs_updated = hr_updated
     l_oData.rs_changes = hr_changes
     l_oData.rs_ratedat = hr_ratedat
     l_oData.rs_addrid = hr_addrid
     l_oData.rs_reserid = hr_reserid
     IF SEEK(histres.hr_rsid,"hresext","tag3")
          l_oData.rs_saddrid = hresext.rs_saddrid
     ENDIF
     INSERT INTO restemp1 FROM NAME l_oData

     procreservattransactions("restemp1", "NEW", "hresplit")

ENDSCAN

SET ORDER TO l_cOrder
IF l_lAbort
     SELECT (l_nSelect)
     WAIT WINDOW "Aborted!" NOWAIT
     RETURN .T.
ENDIF


****************************************************************************************************************************
*                                                                                                                          *
* Now import all reservations from reservat table                                                                          *
*                                                                                                                          *
****************************************************************************************************************************

SELECT reservat

l_cOrder = ORDER()

SET ORDER TO

l_nTotal = RECCOUNT()

SCAN FOR NOT INLIST(rs_status, "CXL", "NS ") AND dblookup("roomtype","tag1",rs_roomtyp,"INLIST(rt_group,1,3,4)")

     WAIT WINDOW "Importing from reservat ("+TRANSFORM(ROUND(RECNO()/l_nTotal*100,2))+")%. rs_reserid: " + TRANSFORM(rs_reserid) NOWAIT
     FNDoEvents()
     IF LASTKEY()=27
          l_lAbort = .T.
          EXIT
     ENDIF

     procreservattransactions("reservat", "NEW")

ENDSCAN

SET ORDER TO l_cOrder



SELECT (l_nSelect)

IF l_lAbort
     WAIT WINDOW "Aborted!" NOWAIT
     = loGdata(TRANSFORM(DATETIME())+"|"+"End  |Action:IMPORT ABORTED","rsifsync.log")
ELSE
     WAIT WINDOW "Finished!" NOWAIT
     l_nSec = DATETIME()-l_tStartTime
     = loGdata(TRANSFORM(DATETIME())+"|"+"End  |Action:IMPORT FINISHED OK|Time:" + TRANSFORM(l_nSec) + " sec.","rsifsync.log")
     alert(GetLangText("COMMON","TXT_DONE") + " (" + TRANSFORM(l_nSec) + " " + GetLangText("SHOWTV","TXT_SECONDS") + ")")
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PRT_Import_All_OpenTables

IF NOT USED("rsifsync")
     openfile(.F.,"rsifsync")
ENDIF

IF NOT USED("reservat")
     openfile(.F.,"reservat")
ENDIF

IF NOT USED("histres")
     openfile(.F.,"histres")
ENDIF

IF NOT USED("resrooms")
     openfile(.F.,"resrooms")
ENDIF

IF NOT USED("hresroom")
     openfile(.F.,"hresroom")
ENDIF

IF NOT USED("resrate")
     openfile(.F.,"resrate")
ENDIF

IF NOT USED("hresrate")
     openfile(.F.,"hresrate")
ENDIF

IF NOT USED("post")
     openfile(.F.,"post")
ENDIF

IF NOT USED("histpost")
     openfile(.F.,"histpost")
ENDIF

IF NOT USED("hresext")
     openfile(.F.,"hresext")
ENDIF

IF NOT USED("ressplit")
     openfile(.F.,"ressplit")
ENDIF

IF NOT USED("hresplit")
     openfile(.F.,"hresplit")
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PRT_NAreservattransactions
IF NOT USED("rsifsync")
     openfile(.F.,"rsifsync")
ENDIF

DELETE FOR rq_done > {..:} AND rq_timesta < g_Sysdate IN rsifsync

RETURN .T.
ENDPROC
*