PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE hr01006r
PARAMETER tcType, tlNoRev
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("hr01006r")
loSession.DoPreproc(tcType, tlNoRev, @laPreProc)
RELEASE loSession

WAIT CLEAR

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
PUBLIC p_hr01006r_lNoRev
p_hr01006r_lNoRev = tlNoRev
ENDPROC
**********
DEFINE CLASS hr01006r AS HotelSession OF ProcMultiProper.prg
PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost,reservat,resrooms,resrate,hresroom,hresrate,sharing,resrmshr,roomtype,room,article,ratecode,picklist,param", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN hr01006r
          ENDTEXT
     ELSE
          PpCursorCreate()
     ENDIF
ENDPROC
*
PROCEDURE DoPreproc
LPARAMETERS tcType, tlNoRev, taPreProc

IF this.lUseRemote
     TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
     <<this.cRemoteScript>>
     DO PpDo IN hr01006r WITH <<SqlCnv(tcType)>>, <<SqlCnv(tlNoRev)>>
     SELECT * FROM PreProc INTO TABLE (l_cFullPath)
     USE
     DClose("PreProc")
     ENDTEXT
     SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
     this.cRemoteScript = ""
ELSE
     PpDo(tcType, tlNoRev)
ENDIF

IF USED("PreProc") AND RECCOUNT("PreProc") > 0
     SELECT * FROM PreProc INTO ARRAY taPreProc
ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
CREATE CURSOR PreProc (pp_date D, pp_code C(10), pp_numcod N(3), pp_descr C(25), pp_code1 C(10), pp_numcod1 N(3), pp_descr1 C(25), ;
	pp_rms N(8), pp_pax N(8), pp_dayrms N(8), pp_daypax N(8), pp_arrrms N(8), pp_arrpax N(8), ;
     pp_deprms N(8), pp_deppax N(8), pp_snglrms N(8), pp_snglpax N(8), pp_dblrms N(8), pp_dblpax N(8), pp_rev N(16,2), pp_vat N(16,6))
INDEX ON pp_code+pp_code1+DTOS(pp_date) TAG pp_code
SET ORDER TO
ENDPROC
*
PROCEDURE PpCursorInit
LPARAMETERS tcType1, tcType2
LOCAL lcLabel, lcurDates, lcLang

lcurDates = MakeDatesCursor(min1, max1, "pp_date")

DO CASE
     CASE INLIST(tcType1, 'M', 'S', 'C')
          lcLabel = PADR(ICASE(tcType1='S', 'SOURCE', tcType1='C', 'COUNTRY', 'MARKET'), 10)
          lcLang = "pl_lang" + g_langnum
          SELECT pl_charcod AS pp_code, pl_numcod AS pp_numcod, &lcLang AS pp_descr, 1 AS c_ord1 FROM picklist ;
               WHERE pl_label = lcLabel ;
               UNION ALL SELECT "", 0, "<Unknown>", 0 FROM param ;
               ORDER BY 4 ;
               INTO CURSOR curPreProc1
     CASE tcType1 == 'RT'
          lcLang = "rt_lang" + g_langnum
          SELECT rt_roomtyp AS pp_code, &lcLang AS pp_descr, 1 AS c_ord1 FROM roomtype ;
               WHERE NOT min3 OR INLIST(rt_group, 1, 4) AND rt_vwsum ;
               UNION ALL SELECT "", "<Unknown>", 0 FROM param ;
               ORDER BY 3 ;
               INTO CURSOR curPreProc1
     CASE tcType1 == 'R'
          lcLang = "rm_lang" + g_langnum
          SELECT rm_roomnum AS pp_code, &lcLang AS pp_descr, 1 AS c_ord1 FROM room ;
               INNER JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
               WHERE NOT min3 OR INLIST(rt_group, 1, 4) AND rt_vwsum ;
               UNION ALL SELECT "", "<Unknown>", 0 FROM param ;
               ORDER BY 3 ;
               INTO CURSOR curPreProc1
     CASE tcType1 == 'RC'
          lcLang = "rc_lang" + g_langnum
          SELECT rc_ratecod AS pp_code, &lcLang AS pp_descr, 1 AS c_ord1 FROM ratecode ;
               GROUP BY 1 ;
               UNION ALL SELECT "", "<Unknown>", 0 FROM param ;
               ORDER BY 3 ;
               INTO CURSOR curPreProc1
ENDCASE
DO CASE
     CASE INLIST(tcType2, 'M', 'S', 'C')
          lcLabel = PADR(ICASE(tcType2='S', 'SOURCE', tcType2='C', 'COUNTRY', 'MARKET'), 10)
          lcLang = "pl_lang" + g_langnum
          SELECT pl_charcod AS pp_code1, pl_numcod AS pp_numcod1, &lcLang AS pp_descr1, 1 AS c_ord2 FROM picklist ;
               WHERE pl_label = lcLabel ;
               UNION ALL SELECT "", 0, "<Unknown>", 0 FROM param ;
               ORDER BY 4 ;
               INTO CURSOR curPreProc2
     CASE tcType2 == 'RT'
          lcLang = "rt_lang" + g_langnum
          SELECT rt_roomtyp AS pp_code1, &lcLang AS pp_descr1, 1 AS c_ord2 FROM roomtype ;
               WHERE NOT min3 OR INLIST(rt_group, 1, 4) AND rt_vwsum ;
               UNION ALL SELECT "", "<Unknown>", 0 FROM param ;
               ORDER BY 3 ;
               INTO CURSOR curPreProc2
     CASE tcType2 == 'R'
          lcLang = "rm_lang" + g_langnum
          SELECT rm_roomnum AS pp_code1, &lcLang AS pp_descr1, 1 AS c_ord2 FROM room ;
               INNER JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
               WHERE NOT min3 OR INLIST(rt_group, 1, 4) AND rt_vwsum ;
               UNION ALL SELECT "", "<Unknown>", 0 FROM param ;
               ORDER BY 3 ;
               INTO CURSOR curPreProc2
     CASE tcType2 == 'RC'
          lcLang = "rc_lang" + g_langnum
          SELECT rc_ratecod AS pp_code1, &lcLang AS pp_descr1, 1 AS c_ord2 FROM ratecode ;
               GROUP BY 1 ;
               UNION ALL SELECT "", "<Unknown>", 0 FROM param ;
               ORDER BY 3 ;
               INTO CURSOR curPreProc2
ENDCASE
IF USED("curPreProc2")
	SELECT * FROM &lcurDates, curPreProc1, curPreProc2 ;
	     ORDER BY pp_code, pp_code1, pp_date ;
	     INTO CURSOR curPreProc1
	DClose("curPreProc2")
ELSE
	SELECT * FROM &lcurDates, curPreProc1 ;
	     ORDER BY pp_code, pp_date ;
	     INTO CURSOR curPreProc1
ENDIF
SELECT PreProc
APPEND FROM DBF("curPreProc1")
DClose("curPreProc1")
DClose(lcurDates)
ENDPROC
*
PROCEDURE PpCursorGroup
SELECT pp_date, pp_code, pp_descr, pp_numcod, pp_code1, pp_descr1, pp_numcod1, SUM(pp_rms) AS pp_rms, SUM(pp_pax) AS pp_pax, SUM(pp_dayrms) AS pp_dayrms, SUM(pp_daypax) AS pp_daypax, ;
     SUM(pp_arrrms) AS pp_arrrms, SUM(pp_arrpax) AS pp_arrpax, SUM(pp_deprms) AS pp_deprms, SUM(pp_deppax) AS pp_deppax, ;
     SUM(pp_snglrms) AS pp_snglrms, SUM(pp_snglpax) AS pp_snglpax, SUM(pp_dblrms) AS pp_dblrms, SUM(pp_dblpax) AS pp_dblpax, ;
     SUM(pp_rev) AS pp_rev, SUM(pp_vat) AS pp_vat FROM PreProc ;
     GROUP BY pp_date, pp_code, pp_descr, pp_numcod, pp_code1, pp_descr1, pp_numcod1 ;
     INTO CURSOR PreProc
ENDPROC
*
PROCEDURE PpDo
LPARAMETERS tcType, tlNoRev
LOCAL lcType1, lcType2, lcCode1, lcCode2, lcJoin, ldDate, lnRooms, lnPersons, lnReserId, lcRrAlias, loResRoom, llAddRooms

tcType = EVL(tcType,"M")
lcType1 = GETWORDNUM(tcType,1,"/")
lcType2 = GETWORDNUM(tcType,2,"/")
STORE "" TO lcCode1, lcCode2
PpCursorInit(lcType1, lcType2)

* Get occupancy
DO CASE
     CASE lcType1 == 'M'
          lcCode1 = 'histres.hr_market'
     CASE lcType1 == 'S'
          lcCode1 = 'histres.hr_source'
     CASE lcType1 == 'C'
          lcCode1 = 'histres.hr_country'
     CASE lcType1 == 'RT'
          lcCode1 = 'loResRoom.ri_roomtyp'
     CASE lcType1 == 'R'
          lcCode1 = 'loResRoom.ri_roomnum'
     CASE lcType1 == 'RC'
          lcCode1 = 'CHRTRAN(histres.hr_ratecod,[*!],[])'
	OTHERWISE
          lcCode1 = ''
ENDCASE
DO CASE
     CASE lcType2 == 'M'
          lcCode2 = 'histres.hr_market'
     CASE lcType2 == 'S'
          lcCode2 = 'histres.hr_source'
     CASE lcType2 == 'C'
          lcCode2 = 'histres.hr_country'
     CASE lcType2 == 'RT'
          lcCode2 = 'loResRoom.ri_roomtyp'
     CASE lcType2 == 'R'
          lcCode2 = 'loResRoom.ri_roomnum'
     CASE lcType2 == 'RC'
          lcCode2 = 'CHRTRAN(histres.hr_ratecod,[*!],[])'
	OTHERWISE
          lcCode2 = ''
ENDCASE

SELECT histres
SCAN FOR hr_reserid > 1 AND hr_arrdate <= max1 AND hr_depdate >= min1 AND NOT INLIST(histres.hr_status, 'CXL', 'NS', 'LST', 'OPT', 'TEN')
     WAIT WINDOW NOWAIT STR(hr_reserid,12,3)
     * Check if reservation is in history or not
     IF SEEK(histres.hr_reserid,"resrate","tag3")
          lcRrAlias = "resrate"
     ELSE
          lcRrAlias = "hresrate"
     ENDIF
     ldDate = MAX(hr_arrdate, min1) && Start date is min1 from date.
     DO WHILE ldDate <= MIN(hr_depdate, max1) && End date is min1 from date.
          * Find right record in resrooms. This gives us room number and roomtype.
          RiGetRoom(hr_reserid, ldDate, @loResRoom, "hresroom")
          * Check if we will this roomtype.
          IF NOT min3 OR DLocate("RoomType", "rt_roomtyp = " + SqlCnv(loResRoom.ri_roomtyp) + " AND INLIST(rt_group, 1, 4) AND rt_vwsum")
               IF NOT SEEK(PADR(&lcCode1,10)+PADR(&lcCode2,10)+DTOS(ldDate),"PreProc","pp_code")
                    INSERT INTO PreProc (pp_code, pp_descr, pp_code1, pp_descr1, pp_date) VALUES (&lcCode1, "#", &lcCode2, "#", ldDate)
               ENDIF

               * Get number of rooms for this reservation.
               IF DLocate("RoomType", "rt_roomtyp = " + SqlCnv(loResRoom.ri_roomtyp) + " AND rt_group = 4")
                    * Linked room.
                    lnRooms = hr_rooms * IIF(EMPTY(loResRoom.ri_roomnum), 1, Get_rm_rmname(loResRoom.ri_roomnum, "rm_roomocc"))
               ELSE
                    lnRooms = hr_rooms
               ENDIF

               * Get number of persons from resrate.
               IF SEEK(STR(histres.hr_reserid,12,3)+DTOS(IIF(ldDate=histres.hr_depdate, ldDate-1, ldDate)),lcRrAlias,"tag2")
                    lnPersons = &lcRrAlias..rr_adults+&lcRrAlias..rr_childs+&lcRrAlias..rr_childs2+&lcRrAlias..rr_childs3
               ELSE
                    lnPersons = hr_adults+hr_childs+hr_childs2+hr_childs3
               ENDIF

               IF ldDate = hr_arrdate
                    IF ISNULL(loResRoom) OR EMPTY(loResRoom.ri_shareid) && Sharing would be processed later.
                         * calcaulate arrival rooms
                         REPLACE pp_arrrms WITH pp_arrrms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_arrpax WITH pp_arrpax + lnPersons IN PreProc
               ENDIF
               IF ldDate = hr_depdate
                    IF ISNULL(loResRoom) OR EMPTY(loResRoom.ri_shareid)
                         * calculate departure rooms
                         REPLACE pp_deprms WITH pp_deprms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_deppax WITH pp_deppax + lnPersons IN PreProc
               ENDIF
               DO CASE
                    CASE hr_arrdate = hr_depdate
                         * no sharing possible for 0 days reservations
                         REPLACE pp_dayrms WITH pp_dayrms + lnRooms IN PreProc
                         REPLACE pp_daypax WITH pp_daypax + lnPersons IN PreProc
                    CASE ldDate < hr_depdate
                         * calculate occupied rooms
                         IF ISNULL(loResRoom) OR EMPTY(loResRoom.ri_shareid)
                              REPLACE pp_rms WITH pp_rms + lnRooms IN PreProc
                         ENDIF
                         REPLACE pp_pax WITH pp_pax + lnPersons IN PreProc
                         IF lnPersons = 1
                              IF ISNULL(loResRoom) OR EMPTY(loResRoom.ri_shareid)
                                   * calculate occupied single rooms
                                   REPLACE pp_snglrms WITH pp_snglrms + lnRooms IN PreProc
                              ENDIF
                              REPLACE pp_snglpax WITH pp_snglpax + lnPersons IN PreProc
                         ELSE
                              IF ISNULL(loResRoom) OR EMPTY(loResRoom.ri_shareid)
                                   * calculate occupied double rooms
                                   REPLACE pp_dblrms WITH pp_dblrms + lnRooms IN PreProc
                              ENDIF
                              REPLACE pp_dblpax WITH pp_dblpax + lnPersons IN PreProc
                         ENDIF
               ENDCASE
          ENDIF
          ldDate = ldDate + 1
     ENDDO
     SELECT histres
ENDSCAN

* Now calculate rooms for sharings
DO CASE
     CASE lcType1 == 'RT'
          lcCode1 = 'sharing.sd_roomtyp'
     CASE lcType1 == 'R'
          lcCode1 = 'sharing.sd_roomnum'
     OTHERWISE
ENDCASE
DO CASE
     CASE lcType2 == 'RT'
          lcCode2 = 'sharing.sd_roomtyp'
     CASE lcType2 == 'R'
          lcCode2 = 'sharing.sd_roomnum'
     OTHERWISE
ENDCASE
SELECT sharing
SCAN FOR sd_lowdat <= max1 AND sd_highdat + 1 >= min1 AND NOT INLIST(sharing.sd_status, 'CXL', 'NS', 'LST', 'OPT', 'TEN')
     WAIT WINDOW NOWAIT "Sharing: " + TRANSFORM(sd_shareid)
     ldDate = MAX(sd_lowdat, min1)
     DO WHILE ldDate <= MIN(sd_highdat+1, max1)
          lnReserId = RiGetShareFirstReserId(sd_shareid, ldDate) && Get main reservation for sharing. Reservation fields are used from this reservation for sharing.
          IF SEEK(lnReserId, "histres", "tag1")
               IF NOT min3 OR DLocate("RoomType", "rt_roomtyp = " + SqlCnv(sd_roomtyp) + " AND INLIST(rt_group, 1, 4) AND rt_vwsum")
                    IF NOT SEEK(PADR(&lcCode1,10)+PADR(&lcCode2,10)+DTOS(ldDate),"PreProc","pp_code")
                    	INSERT INTO PreProc (pp_code, pp_descr, pp_code1, pp_descr1, pp_date) VALUES (&lcCode1, "#", &lcCode2, "#", ldDate)
                    ENDIF
                    IF DLocate("RoomType", "rt_roomtyp = " + SqlCnv(sd_roomtyp) + " AND rt_group = 4")
                         lnRooms = IIF(EMPTY(sd_roomnum), 1, Get_rm_rmname(sd_roomnum, "rm_roomocc"))
                    ELSE
                         lnRooms = 1
                    ENDIF
                    IF ldDate = sd_lowdat
                         * This is start date for sharing. But is this arrival date for reservation?
                         DO RiShareInterval IN ProcResRooms WITH llAddRooms, sd_shareid, sd_lowdat, sd_highdat, "ARRIVAL", ldDate
                         IF llAddRooms
                              REPLACE pp_arrrms WITH pp_arrrms + lnRooms IN PreProc
                         ENDIF
                    ENDIF
                    IF ldDate = sd_highdat + 1
                         * This is end date for sharing. But is this departure date for reservation?
                         DO RiShareInterval IN ProcResRooms WITH llAddRooms, sd_shareid, sd_lowdat, sd_highdat, "DEPARTURE", ldDate
                         IF llAddRooms
                              REPLACE pp_deprms WITH pp_deprms + lnRooms IN PreProc
                         ENDIF
                    ENDIF
                    IF BETWEEN(ldDate, sd_lowdat, sd_highdat)
                         REPLACE pp_rms WITH pp_rms + lnRooms IN PreProc
                         * if sharing must be double room
                         REPLACE pp_dblrms WITH pp_dblrms + lnRooms IN PreProc
                    ENDIF
               ENDIF
          ENDIF
          ldDate = ldDate + 1
     ENDDO
ENDSCAN

IF NOT tlNoRev
     WAIT WINDOW NOWAIT 'Revenue...'
     DO CASE
          CASE lcType1 == 'M'
               lcCode1 = "NVL(hr_market,rs_market)"
          CASE lcType1 == 'S'
               lcCode1 = "NVL(hr_source,rs_source)"
          CASE lcType1 == 'C'
               lcCode1 = "NVL(hr_country,rs_country)"
          CASE lcType1 == 'RT'
               lcCode1 = "NVL(hri.ri_roomtyp,rri.ri_roomtyp)"
          CASE lcType1 == 'R'
               lcCode1 = "NVL(hri.ri_roomnum,rri.ri_roomnum)"
          CASE lcType1 == 'RC'
               lcCode1 = "CHRTRAN(NVL(hr_ratecod,rs_ratecod),[*!],[])"
     ENDCASE
     DO CASE
          CASE lcType2 == 'M'
               lcCode2 = "NVL(hr_market,rs_market)"
          CASE lcType2 == 'S'
               lcCode2 = "NVL(hr_source,rs_source)"
          CASE lcType2 == 'C'
               lcCode2 = "NVL(hr_country,rs_country)"
          CASE lcType2 == 'RT'
               lcCode2 = "NVL(hri.ri_roomtyp,rri.ri_roomtyp)"
          CASE lcType2 == 'R'
               lcCode2 = "NVL(hri.ri_roomnum,rri.ri_roomnum)"
          CASE lcType2 == 'RC'
               lcCode2 = "CHRTRAN(NVL(hr_ratecod,rs_ratecod),[*!],[])"
     ENDCASE

     SELECT CAST(NVL(&lcCode1,"") AS C(10)) AS pp_code, CAST(NVL(&lcCode2,"") AS C(10)) AS pp_code1, hp_date, SUM(hp_amount) AS pp_rev, SUM(hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9) AS pp_vat ;
          FROM HistPost ;
          INNER JOIN (SELECT ar_artinum, ar_artityp, ar_main FROM article GROUP BY 1) ar ON ar_artinum = hp_artinum ;
          LEFT JOIN histres  ON hr_reserid = hp_origid AND NOT EMPTY(hr_roomtyp) ;
          LEFT JOIN reservat ON rs_reserid = hp_origid AND NOT EMPTY(rs_roomtyp) ;
          LEFT JOIN hresroom hri ON hri.ri_reserid = hp_origid AND NOT EMPTY(hri.ri_roomtyp) AND BETWEEN(hp_date, hri.ri_date, hri.ri_todate) ;
          LEFT JOIN resrooms rri ON rri.ri_reserid = hp_origid AND NOT EMPTY(rri.ri_roomtyp) AND BETWEEN(hp_date, rri.ri_date, rri.ri_todate) ;
          WHERE BETWEEN(hp_date, min1, max1) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND ar.ar_artityp = 1 AND BETWEEN(ar.ar_main, min2, max2) ;
          GROUP BY pp_code, pp_code1, hp_date ;
          INTO CURSOR curPost
     SCAN
          IF NOT SEEK(PADR(curPost.pp_code,10)+PADR(curPost.pp_code1,10)+DTOS(curPost.hp_date),"PreProc","pp_code")
          	INSERT INTO PreProc (pp_code, pp_descr, pp_code1, pp_descr1, pp_date) VALUES (curPost.pp_code, "#", curPost.pp_code1, "#", curPost.hp_date)
          ENDIF
          REPLACE pp_rev WITH curPost.pp_rev, pp_vat WITH curPost.pp_vat IN PreProc
     ENDSCAN
     DClose("curPost")
ENDIF

DO CASE
     CASE lcType1 == 'RT'
          * Fix room type
          SELECT DISTINCT pp_code, pp_code AS c_desc FROM PreProc INTO CURSOR curRmNames READWRITE
          REPLACE c_desc WITH get_rt_roomtyp(pp_code) ALL IN curRmNames
          INDEX ON pp_code TAG pp_code
          REPLACE pp_code WITH curRmNames.c_desc FOR SEEK(pp_code,"curRmNames","pp_code") IN PreProc
     CASE lcType1 == 'R'
          * Fix room name
          SELECT DISTINCT pp_code, pp_code AS c_desc FROM PreProc INTO CURSOR curRmNames READWRITE
          REPLACE c_desc WITH get_rm_rmname(pp_code) ALL IN curRmNames
          INDEX ON pp_code TAG pp_code
          REPLACE pp_code WITH curRmNames.c_desc FOR SEEK(pp_code,"curRmNames","pp_code") IN PreProc
     OTHERWISE
ENDCASE
DO CASE
     CASE lcType2 == 'RT'
          * Fix room type
          SELECT DISTINCT pp_code1, pp_code1 AS c_desc FROM PreProc INTO CURSOR curRmNames READWRITE
          REPLACE c_desc WITH get_rt_roomtyp(pp_code1) ALL IN curRmNames
          INDEX ON pp_code1 TAG pp_code
          REPLACE pp_code1 WITH curRmNames.c_desc FOR SEEK(pp_code1,"curRmNames","pp_code") IN PreProc
     CASE lcType2 == 'R'
          * Fix room name
          SELECT DISTINCT pp_code1, pp_code1 AS c_desc FROM PreProc INTO CURSOR curRmNames READWRITE
          REPLACE c_desc WITH get_rm_rmname(pp_code1) ALL IN curRmNames
          INDEX ON pp_code1 TAG pp_code
          REPLACE pp_code1 WITH curRmNames.c_desc FOR SEEK(pp_code1,"curRmNames","pp_code") IN PreProc
     OTHERWISE
ENDCASE
DClose("curRmNames")
ENDPROC
*