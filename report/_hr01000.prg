PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "7.30"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hr01000
LPARAMETERS tcType, tlNoRev
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hr01000")
loSession.DoPreproc(tcType, tlNoRev, @laPreProc)
RELEASE loSession

WAIT CLEAR

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
ENDPROC
**********
DEFINE CLASS _hr01000 AS HotelSession OF ProcMultiProper.prg
PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost,reservat,resrooms,resrate,hresroom,hresrate,sharing,resrmshr,roomtype,rtypedef,building,room,article,ratecode,picklist", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _hr01000
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
          DO PpDo IN _hr01000 WITH <<SqlCnv(tcType)>>, <<SqlCnv(tlNoRev)>>
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          puSessionOrHotcode = this
          PpDo(tcType, tlNoRev)
     ENDIF

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
CREATE CURSOR PreProc (pp_date D, pp_code C(10), pp_numcod N(3), pp_descr C(25), pp_rms N(8), pp_pax N(8), pp_dayrms N(8), pp_daypax N(8), pp_arrrms N(8), pp_arrpax N(8), ;
     pp_deprms N(8), pp_deppax N(8), pp_snglrms N(8), pp_snglpax N(8), pp_dblrms N(8), pp_dblpax N(8), pp_rev N(16,2), pp_vat N(16,6))
INDEX ON pp_code+DTOS(pp_date) TAG pp_code
SET ORDER TO
ENDPROC
*
PROCEDURE PpCursorInit
LPARAMETERS tcType
LOCAL lcLabel, lcurDates, lcLang

lcurDates = MakeDatesCursor(min1, max1, "pp_date")
DO CASE
     CASE INLIST(tcType, 'M', 'S', 'C')
          lcLabel = PADR(ICASE(tcType='S', 'SOURCE', tcType='C', 'COUNTRY', 'MARKET'), 10)
          lcLang = "pl_lang" + g_langnum
          SELECT pp_date, pl_charcod AS pp_code, pl_numcod AS pp_numcod, &lcLang AS pp_descr FROM &lcurDates, picklist ;
               WHERE pl_label = lcLabel ;
               INTO CURSOR curPreProc
          SELECT PreProc
          APPEND FROM DBF("curPreProc")
     CASE tcType == 'RT'
          lcLang = "rt_lang" + g_langnum
          SELECT pp_date, rt_roomtyp AS pp_code, &lcLang AS pp_descr FROM &lcurDates, roomtype ;
               WHERE (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND (NOT min3 OR INLIST(rt_group, 1, 4) AND rt_vwsum) ;
               INTO CURSOR curPreProc
          SELECT PreProc
          APPEND FROM DBF("curPreProc")
     CASE tcType == 'R'
          lcLang = "rm_lang" + g_langnum
          SELECT pp_date, rm_roomnum AS pp_code, &lcLang AS pp_descr FROM &lcurDates, room ;
               INNER JOIN roomtype ON rt_roomtyp = rm_roomtyp ;
               WHERE (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND (NOT min3 OR INLIST(rt_group, 1, 4) AND rt_vwsum) ;
               INTO CURSOR curPreProc
          SELECT PreProc
          APPEND FROM DBF("curPreProc")
     CASE tcType == 'RC'
          lcLang = "rc_lang" + g_langnum
          SELECT pp_date, rc_ratecod AS pp_code, &lcLang AS pp_descr FROM &lcurDates, ratecode ;
               GROUP BY 1,2 ;
               INTO CURSOR curPreProc
          SELECT PreProc
          APPEND FROM DBF("curPreProc")
     OTHERWISE
ENDCASE
DClose("curPreProc")
INSERT INTO PreProc (pp_date, pp_descr) SELECT pp_date, "<Unknown>" FROM &lcurDates
ENDPROC
*
PROCEDURE PpCursorGroup
SELECT pp_date, pp_code, pp_descr, SUM(pp_rms) AS pp_rms, SUM(pp_pax) AS pp_pax, SUM(pp_dayrms) AS pp_dayrms, SUM(pp_daypax) AS pp_daypax, ;
     SUM(pp_arrrms) AS pp_arrrms, SUM(pp_arrpax) AS pp_arrpax, SUM(pp_deprms) AS pp_deprms, SUM(pp_deppax) AS pp_deppax, ;
     SUM(pp_snglrms) AS pp_snglrms, SUM(pp_snglpax) AS pp_snglpax, SUM(pp_dblrms) AS pp_dblrms, SUM(pp_dblpax) AS pp_dblpax, ;
     SUM(pp_rev) AS pp_rev, SUM(pp_vat) AS pp_vat FROM PreProc ;
     GROUP BY pp_date, pp_code, pp_descr ;
     INTO CURSOR PreProc
ENDPROC
*
PROCEDURE PpDo
LPARAMETERS tcType, tlNoRev
LOCAL lcCode, ldDate, lnRooms, lnPersons, lnReserId, lcRiAlias, lcRrAlias, loResRoom, lcRoomtype, lcRoomnum, lcBuilding, lnShareId, llAddRooms, llUseUI, lcArchScripts

llUseUI = (_VFP.StartMode < 3)     && Don't show WAIT WINDOW if called from IIS's ActiveVFP.dll
tcType = EVL(tcType,"M")

PpCursorInit(tcType)

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     INNER JOIN (
     SELECT hr_reserid AS c_reserid FROM histres
          WHERE hr_reserid > 1 AND hr_arrdate <= <<SqlCnvB(max1)>> AND hr_depdate >= <<SqlCnvB(min1)>>
     UNION
     SELECT hr_reserid FROM histres
          INNER JOIN histpost ON hp_reserid = hr_reserid OR hp_origid = hr_reserid
          WHERE BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
          GROUP BY hr_reserid
     ) hr ON hr_reserid = c_reserid;

SELECT histpost.* FROM histpost
     WHERE BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************

* Get occupancy
DO CASE
     CASE tcType == 'M'
          lcCode = 'histres.hr_market'
     CASE tcType == 'S'
          lcCode = 'histres.hr_source'
     CASE tcType == 'C'
          lcCode = 'histres.hr_country'
     CASE tcType == 'RT'
          lcCode = 'lcRoomtype'
     CASE tcType == 'R'
          lcCode = 'lcRoomnum'
     CASE tcType == 'RC'
          lcCode = 'CHRTRAN(histres.hr_ratecod,[*!],[])'
     OTHERWISE
ENDCASE

SELECT histres
SCAN FOR hr_reserid > 1 AND hr_arrdate <= max1 AND hr_depdate >= min1 AND NOT INLIST(histres.hr_status, 'CXL', 'NS', 'LST', 'OPT', 'TEN')
     IF llUseUI
          WAIT WINDOW NOWAIT STR(hr_reserid,12,3)
     ENDIF
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
          IF ISNULL(loResRoom)
               lcRoomtype = histres.hr_roomtyp
               lcRoomnum = histres.hr_roomnum
               lnShareId = 0
          ELSE
               lcRoomtype = loResRoom.ri_roomtyp
               lcRoomnum = loResRoom.ri_roomnum
               lnShareId = loResRoom.ri_shareid
          ENDIF
          * Check if we will this roomtype.
          IF DLocate("RoomType", "rt_roomtyp = " + SqlCnv(lcRoomtype)) AND ;
                    (EVL(RptBulding,"*") = "*" OR RoomType.rt_buildng = RptBulding) AND(NOT min3 OR INLIST(RoomType.rt_group, 1, 4) AND RoomType.rt_vwsum)
               IF NOT SEEK(PADR(&lcCode,10)+DTOS(ldDate),"PreProc","pp_code")
                    INSERT INTO PreProc (pp_code, pp_date, pp_descr) VALUES (&lcCode, ldDate, "#")
               ENDIF

               * Get number of rooms for this reservation.
               IF RoomType.rt_group = 4
                    * Linked room.
                    lnRooms = hr_rooms * IIF(EMPTY(lcRoomnum), 1, Get_rm_rmname(lcRoomnum, "rm_roomocc", puSessionOrHotcode))
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
                    IF EMPTY(lnShareId) && Sharing would be processed later.
                         * calcaulate arrival rooms
                         REPLACE pp_arrrms WITH pp_arrrms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_arrpax WITH pp_arrpax + lnPersons IN PreProc
               ENDIF
               IF ldDate = hr_depdate
                    IF EMPTY(lnShareId)
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
                         IF EMPTY(lnShareId)
                              REPLACE pp_rms WITH pp_rms + lnRooms IN PreProc
                         ENDIF
                         REPLACE pp_pax WITH pp_pax + lnPersons IN PreProc
                         IF lnPersons = 1
                              IF EMPTY(lnShareId)
                                   * calculate occupied single rooms
                                   REPLACE pp_snglrms WITH pp_snglrms + lnRooms IN PreProc
                              ENDIF
                              REPLACE pp_snglpax WITH pp_snglpax + lnPersons IN PreProc
                         ELSE
                              IF EMPTY(lnShareId)
                                   * calculate occupied double rooms
                                   REPLACE pp_dblrms WITH pp_dblrms + lnRooms IN PreProc
                              ENDIF
                              REPLACE pp_dblpax WITH pp_dblpax + lnPersons IN PreProc
                         ENDIF
                    OTHERWISE
               ENDCASE
          ENDIF
          ldDate = ldDate + 1
     ENDDO
     SELECT histres
ENDSCAN

* Now calculate rooms for sharings
DO CASE
     CASE tcType == 'RT'
          lcCode = 'sharing.sd_roomtyp'
     CASE tcType == 'R'
          lcCode = 'sharing.sd_roomnum'
     OTHERWISE
ENDCASE
SELECT sharing
SCAN FOR sd_lowdat <= max1 AND sd_highdat + 1 >= min1 AND NOT INLIST(sharing.sd_status, 'CXL', 'NS', 'LST', 'OPT', 'TEN')
     IF llUseUI
          WAIT WINDOW NOWAIT "Sharing: " + TRANSFORM(sd_shareid)
     ENDIF
     ldDate = MAX(sd_lowdat, min1)
     DO WHILE ldDate <= MIN(sd_highdat+1, max1)
          lnReserId = RiGetShareFirstReserId(sd_shareid, ldDate) && Get main reservation for sharing. Reservation fields are used from this reservation for sharing.
          IF SEEK(lnReserId, "histres", "tag1")
               IF DLocate("RoomType", "rt_roomtyp = " + SqlCnv(sd_roomtyp)) AND ;
                         (EVL(RptBulding,"*") = "*" OR RoomType.rt_buildng = RptBulding) AND(NOT min3 OR INLIST(RoomType.rt_group, 1, 4) AND RoomType.rt_vwsum)
                    IF NOT SEEK(PADR(&lcCode,10)+DTOS(ldDate),"PreProc","pp_code")
                         INSERT INTO PreProc (pp_code, pp_date, pp_descr) VALUES (&lcCode, ldDate, "#")
                    ENDIF
                    IF RoomType.rt_group = 4
                         lnRooms = IIF(EMPTY(sd_roomnum), 1, Get_rm_rmname(sd_roomnum, "rm_roomocc", puSessionOrHotcode))
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
     IF llUseUI
          WAIT WINDOW NOWAIT 'Revenue...'
     ENDIF
     DO CASE
          CASE tcType == 'M'
               lcCode = "NVL(NVL(hr1.hr_market,rs1.rs_market),NVL(hr2.hr_market,rs2.rs_market))"
          CASE tcType == 'S'
               lcCode = "NVL(NVL(hr1.hr_source,rs1.rs_source),NVL(hr2.hr_source,rs2.rs_source))"
          CASE tcType == 'C'
               lcCode = "NVL(NVL(hr1.hr_country,rs1.rs_country),NVL(hr2.hr_country,rs2.rs_country))"
          CASE tcType == 'RT'
               lcCode = "NVL(NVL(NVL(hri1.ri_roomtyp,rri1.ri_roomtyp),NVL(hr1.hr_roomtyp,rs1.rs_roomtyp)),NVL(NVL(hri2.ri_roomtyp,rri2.ri_roomtyp),NVL(hr2.hr_roomtyp,rs2.rs_roomtyp)))"
          CASE tcType == 'R'
               lcCode = "NVL(NVL(NVL(hri1.ri_roomnum,rri1.ri_roomnum),NVL(hr1.hr_roomnum,rs1.rs_roomnum)),NVL(NVL(hri2.ri_roomnum,rri2.ri_roomnum),NVL(hr2.hr_roomnum,rs2.rs_roomnum)))"
          CASE tcType == 'RC'
               lcCode = "CHRTRAN(NVL(NVL(hr1.hr_ratecod,rs1.rs_ratecod),NVL(hr2.hr_ratecod,rs2.rs_ratecod)),[*!],[])"
          OTHERWISE
     ENDCASE
     SELECT CAST(NVL(&lcCode,"") AS C(10)) AS pp_code, CAST(NVL(NVL(NVL(NVL(hri1.ri_roomtyp,rri1.ri_roomtyp),NVL(hr1.hr_roomtyp,rs1.rs_roomtyp)),NVL(NVL(hri2.ri_roomtyp,rri2.ri_roomtyp),NVL(hr2.hr_roomtyp,rs2.rs_roomtyp))),"") AS C(4)) AS c_roomtyp, ;
               ar_buildng AS c_buildng, hp_date, hp_amount AS pp_rev, hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9 AS pp_vat ;
          FROM HistPost ;
          INNER JOIN (SELECT ar_artinum, ar_artityp, ar_main, ar_buildng FROM article GROUP BY 1) ar ON ar_artinum = hp_artinum ;
          LEFT JOIN histres hr1 ON hr1.hr_reserid = hp_origid AND NOT EMPTY(hr1.hr_roomtyp) ;
          LEFT JOIN reservat rs1 ON rs1.rs_reserid = hp_origid AND NOT EMPTY(rs1.rs_roomtyp) ;
          LEFT JOIN hresroom hri1 ON hri1.ri_reserid = hp_origid AND NOT EMPTY(hri1.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), hri1.ri_date, hri1.ri_todate) ;
          LEFT JOIN resrooms rri1 ON rri1.ri_reserid = hp_origid AND NOT EMPTY(rri1.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), rri1.ri_date, rri1.ri_todate) ;
          LEFT JOIN histres hr2 ON hr2.hr_reserid = hp_reserid AND NOT EMPTY(hr2.hr_roomtyp) ;
          LEFT JOIN reservat rs2 ON rs2.rs_reserid = hp_reserid AND NOT EMPTY(rs2.rs_roomtyp) ;
          LEFT JOIN hresroom hri2 ON hri2.ri_reserid = hp_reserid AND NOT EMPTY(hri2.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), hri2.ri_date, hri2.ri_todate) ;
          LEFT JOIN resrooms rri2 ON rri2.ri_reserid = hp_reserid AND NOT EMPTY(rri2.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), rri2.ri_date, rri2.ri_todate) ;
          WHERE BETWEEN(hp_date, min1, max1) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND ar.ar_artityp = 1 AND BETWEEN(ar.ar_main, min2, max2) ;
          INTO CURSOR curPost
     SCAN
          IF EVL(RptBulding,"*") <> "*"
               IF EMPTY(c_roomtyp)
                    lcBuilding = c_buildng
               ELSE
                    lcBuilding = PADR(get_rt_roomtyp(c_roomtyp,"rt_buildng",,puSessionOrHotcode), 3)
                    IF EMPTY(lcBuilding)
                         lcBuilding = c_buildng
                    ENDIF
               ENDIF
               IF lcBuilding <> RptBulding
                    LOOP
               ENDIF
          ENDIF
          IF NOT SEEK(PADR(curPost.pp_code,10)+DTOS(curPost.hp_date),"PreProc","pp_code")
               INSERT INTO PreProc (pp_code, pp_date, pp_descr) VALUES (curPost.pp_code, curPost.hp_date, "#")
          ENDIF
          REPLACE pp_rev WITH pp_rev + curPost.pp_rev, pp_vat WITH pp_vat + curPost.pp_vat IN PreProc
     ENDSCAN
     DClose("curPost")
ENDIF

DO CASE
     CASE tcType == 'RT'
          * Fix room type
          REPLACE pp_code WITH get_rt_roomtyp(pp_code,,,puSessionOrHotcode) ALL IN PreProc
     CASE tcType == 'R'
          * Fix room name
          REPLACE pp_code WITH get_rm_rmname(pp_code, IIF(EVL(RptBulding,"*") = "*", "RTRIM(rm_rmname)+IIF(EMPTY(rt_buildng), '', ' ('+RTRIM(rt_buildng)+')')", ""), puSessionOrHotcode) ALL IN PreProc
     OTHERWISE
ENDCASE

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*