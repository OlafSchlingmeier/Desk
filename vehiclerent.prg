*
*PROCEDURE VehicleRent
LPARAMETERS tcFuncName, tuParam1, tuParam2, tuParam3, tuParam4, tuParam5, tuParam6, tuParam7, tuParam8, tuParam9, tuParam10
LOCAL lcCallProc, lnParamNo, luRetVal

lcCallProc = tcFuncName + "("
FOR lnParamNo = 1 TO PCOUNT()-1
     lcCallProc = lcCallProc + IIF(lnParamNo = 1, "", ", ") + "@tuParam" + TRANSFORM(lnParamNo)
NEXT
lcCallProc = lcCallProc + ")"

luRetVal = &lcCallProc

RETURN luRetVal
ENDFUNC
*
PROCEDURE VehicleRentRM_Test
LOCAL ldFromDate, ldToDate

ldFromDate = DATE(2015,8,1)
ldToDate = DATE(2015,9,10)

VehicleRentRM(ldFromDate, ldToDate)     && Returns curRoomplan with boat location intervals.
SELECT curRoomplan
BROWSE
ENDPROC
*
PROCEDURE VehicleRentRT_Test
LOCAL ldFromDate, ldToDate

ldFromDate = DATE(2015,8,1)
ldToDate = DATE(2015,10,10)

VehicleRentRT(ldFromDate, ldToDate)     && Returns curAvailab with availability offset according to boat relocation.
SELECT curAvailab
BROWSE
ENDPROC
*
PROCEDURE VehicleRentRM
LPARAMETERS tdFromDate, tdToDate, tcCurName, tcRoomnum
LOCAL lnArea, lcNear, lcSql, lnRsid, lcRoomtype, lcBuilding, lcRtStart, lcRtFinish, loTransfer, lcOrderHR, lcOrderRS, lnRecnoHR, lnRecnoRS, ;
     llCloseRS, llCloseHR, llCloseRT, llCloseRD, llCloseRM, lcCurReser, lcCurName
LOCAL ARRAY laRoomtype(1)

lnArea = SELECT()

lcNear = SET("Near")

IF EMPTY(tcCurName)
     tcCurName = "curRoomplan"
ENDIF

IF NOT USED("reservat")
     USE reservat IN 0
     llCloseRS = .T.
ENDIF
IF NOT USED("histres")
     USE histres IN 0
     llCloseHR = .T.
ENDIF
IF NOT USED("roomtype")
     USE roomtype IN 0
     llCloseRT = .T.
ENDIF
IF NOT USED("rtypedef")
     USE rtypedef IN 0
     llCloseRD = .T.
ENDIF
IF NOT USED("room")
     USE room IN 0
     llCloseRM = .T.
ENDIF
lnRecnoHR = RECNO("histres")
lnRecnoRS = RECNO("reservat")
lcOrderRS = ORDER("reservat")

lcCurReser = SYS(2015)

***************************************************************************************************************************************************
* Collect all boat reservations for rentable boats on period from "tdFromDate <-> tdToDate" in cursor curReser
* c_rtstart  - Boat room type ID on start  port (rt_buildng = rs_lstart  AND rt_rdid = rd_rdid)
* c_rtfinish - Boat room type ID on finish port (rt_buildng = rs_lfinish AND rt_rdid = rd_rdid)
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT rs_rsid, rs_roomnum, rs_arrdate, rs_depdate, rt_buildng, rs_roomtyp, rs_lstart, rt_roomtyp AS c_rtstart, rs_lfinish, rt_roomtyp AS c_rtfinish
     FROM reservat
     INNER JOIN roomtype ON rt_roomtyp = rs_roomtyp
     WHERE 0=1
ENDTEXT
&lcSql INTO CURSOR &lcCurReser READWRITE
INDEX ON rs_roomnum TAG rs_roomnum
SET ORDER TO

SELECT reservat
SCAN FOR DTOS(rs_depdate)+rs_roomnum > DTOS(tdFromDate) AND DTOS(rs_arrdate)+rs_lname <= DTOS(tdToDate) AND ;
          IIF(EMPTY(tcRoomnum), rs_roomnum <> '    ', rs_roomnum = PADR(tcRoomnum,4)) AND NOT INLIST(rs_status, 'CXL', 'NS ') AND ;
          SEEK(rs_roomtyp, "roomtype", "tag1") AND SEEK(roomtype.rt_rdid, "rtypedef", "tag1") AND rtypedef.rd_verent
     SELECT roomtype
     lcBuilding = rt_buildng
     LOCATE FOR rt_buildng = reservat.rs_lstart AND rt_rdid = rtypedef.rd_rdid
     IF FOUND()
          lcRtStart = rt_roomtyp
          LOCATE FOR rt_buildng = EVL(reservat.rs_lfinish, reservat.rs_lstart) AND rt_rdid = rtypedef.rd_rdid
          IF FOUND()
               lcRtFinish = rt_roomtyp
               INSERT INTO &lcCurReser (rs_rsid, rs_roomnum, rs_arrdate, rs_depdate, rs_roomtyp, rs_lstart, rs_lfinish, rt_buildng, c_rtstart, c_rtfinish) ;
                    VALUES (reservat.rs_rsid, reservat.rs_roomnum, reservat.rs_arrdate, reservat.rs_depdate, reservat.rs_roomtyp, reservat.rs_lstart, ;
                         EVL(reservat.rs_lfinish, reservat.rs_lstart), lcBuilding, lcRtStart, lcRtFinish)
          ENDIF
     ENDIF
     SELECT reservat
ENDSCAN

SELECT histres
SCAN FOR hr_depdate > tdFromDate AND hr_arrdate <= tdToDate AND NOT SEEK(hr_rsid, "reservat", "tag33") AND ;
          IIF(EMPTY(tcRoomnum), hr_roomnum <> '    ', hr_roomnum = PADR(tcRoomnum,4)) AND NOT INLIST(hr_status, 'CXL', 'NS ') AND ;
          SEEK(hr_roomtyp, "roomtype", "tag1") AND SEEK(roomtype.rt_rdid, "rtypedef", "tag1") AND rtypedef.rd_verent
     SELECT roomtype
     lcBuilding = rt_buildng
     LOCATE FOR rt_buildng = histres.hr_lstart AND rt_rdid = rtypedef.rd_rdid
     IF FOUND()
          lcRtStart = rt_roomtyp
          LOCATE FOR rt_buildng = EVL(histres.hr_lfinish, histres.hr_lstart) AND rt_rdid = rtypedef.rd_rdid
          IF FOUND()
               lcRtFinish = rt_roomtyp
               INSERT INTO &lcCurReser (rs_rsid, rs_roomnum, rs_arrdate, rs_depdate, rs_roomtyp, rs_lstart, rs_lfinish, rt_buildng, c_rtstart, c_rtfinish) ;
                    VALUES (histres.hr_rsid, histres.hr_roomnum, histres.hr_arrdate, histres.hr_depdate, histres.hr_roomtyp, histres.hr_lstart, ;
                         EVL(histres.hr_lfinish, histres.hr_lstart), lcBuilding, lcRtStart, lcRtFinish)
          ENDIF
     ENDIF
     SELECT histres
ENDSCAN

***************************************************************************************************************************************************
* Make structure for location of rentable boats on period from "tdFromDate <-> tdToDate" in cursor curRoomplan
* tf_boatnum  - Boat room ID
* tf_hometyp  - Home (mother) boat room type ID
* tf_homeport - Home (mother) port
* tf_porttyp  - Current boat room type ID
* tf_port     - Current port
* tf_transfer - Need to be transfered to required port to prepare for next reservation
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT room.*, rd_rdid, rd_roomtyp, rm_roomnum AS tf_boatnum, rm_roomtyp AS tf_hometyp, rt_buildng AS tf_homeport, rm_roomtyp AS tf_porttyp, rt_buildng AS tf_port, tdFromDate AS tf_fromdat, tdToDate AS tf_todat, 0=1 AS tf_transfer
     FROM room
     INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp
     INNER JOIN rtypedef ON rd_rdid = rt_rdid AND rd_verent
     <<IIF(EMPTY(tcRoomnum), "", "WHERE rm_roomnum = '"+PADR(tcRoomnum,4)+"' ")>>
ENDTEXT
&lcSql INTO CURSOR &tcCurName READWRITE
INDEX ON tf_fromdat TAG tf_fromdat
INDEX ON tf_todat TAG tf_todat
INDEX ON tf_boatnum TAG tf_boatnum
INDEX ON tf_boatnum+DTOS(tf_todat) TAG tf_boatto

***************************************************************************************************************************************************
* If using period from "tdFromDate <-> tdToDate" need to be changed initial boat location on "tdFromDate" depend on previous boat reservations
* Search for boat reservation (on histres/reservat) that finishes its trip before "tdFromDate"
IF NOT EMPTY(tdFromDate)
     lcOrderHR = ORDER("histres")
     SET ORDER TO tag17 IN histres DESCENDING      && hr_roomnum+DTOS(hr_depdate)
     SET ORDER TO tag23 IN reservat DESCENDING     && rs_roomnum+DTOS(rs_depdate)+DTOS(rs_arrdate)
     SET NEAR ON
     SELECT &tcCurName
     SCAN
          lnRsid = 0
          SELECT &lcCurReser
          LOCATE FOR rs_roomnum = &tcCurName..tf_boatnum AND BETWEEN(tdFromDate, rs_arrdate, rs_depdate-1)
          IF FOUND()
               lnRsid = &lcCurReser..rs_rsid
               lcRoomtype = &lcCurReser..rs_roomtyp
               lcBuilding = &lcCurReser..rs_lstart
          ELSE
               SELECT histres
               =SEEK(&tcCurName..tf_boatnum+DTOS(tdFromDate))
               IF histres.hr_roomnum = &tcCurName..tf_boatnum AND INLIST(hr_status, 'CXL', 'NS ')
                    LOCATE FOR NOT INLIST(hr_status, 'CXL', 'NS ') WHILE hr_roomnum = &tcCurName..tf_boatnum
               ENDIF
               IF hr_roomnum = &tcCurName..tf_boatnum
                    lnRsid = histres.hr_rsid
                    lcRoomtype = histres.hr_roomtyp
                    lcBuilding = histres.hr_lfinish
               ENDIF
               SELECT reservat
               =SEEK(&tcCurName..tf_boatnum+DTOS(tdFromDate))
               IF rs_roomnum = &tcCurName..tf_boatnum AND INLIST(rs_status, 'CXL', 'NS ')
                    LOCATE FOR NOT INLIST(rs_status, 'CXL', 'NS ') WHILE rs_roomnum = &tcCurName..tf_boatnum
               ENDIF
               IF reservat.rs_roomnum = &tcCurName..tf_boatnum AND (EMPTY(lnRsid) OR histres.hr_depdate < reservat.rs_depdate)
                    lnRsid = reservat.rs_rsid
                    lcRoomtype = reservat.rs_roomtyp
                    lcBuilding = reservat.rs_lfinish
               ENDIF
          ENDIF
          IF NOT EMPTY(lnRsid)
               * Boat room type ID must be on finish port (rt_buildng = rs_lfinish AND rt_rdid = rd_rdid)
               laRoomtype(1) = ""
               SELECT rt2.rt_roomtyp FROM roomtype rt1, roomtype rt2 ;
                    WHERE rt2.rt_rdid = rt1.rt_rdid AND rt1.rt_roomtyp = lcRoomtype AND rt2.rt_buildng = lcBuilding ;
                    INTO ARRAY laRoomtype
               IF NOT EMPTY(laRoomtype(1))
                    lcRoomtype = laRoomtype(1)
               ENDIF
               REPLACE tf_porttyp WITH lcRoomtype, tf_port WITH lcBuilding IN &tcCurName
          ENDIF
          SELECT &tcCurName
     ENDSCAN
     SET NEAR &lcNear
     SET ORDER TO (lcOrderHR) IN histres
ENDIF

***************************************************************************************************************************************************
* Calculating boat locations depends on collected boat reservations on period from "tdFromDate <-> tdToDate"
* If boat starts its trip on "rs_lstart <> current port" then from "rs_arrdate" this boat is on "rs_lstart" port and must be transferd to this port.
* If boat finishes its trip on "rs_lfinish <> current port" then from "rs_depdate" this boat is on "rs_lfinish" port.
SELECT &lcCurReser
SCAN
     SELECT &tcCurName
     LOCATE FOR tf_boatnum = &lcCurReser..rs_roomnum AND (EMPTY(tf_fromdat) OR tf_fromdat < &lcCurReser..rs_arrdate) AND (EMPTY(tf_todat) OR tf_todat > &lcCurReser..rs_arrdate-1)
     IF FOUND() AND tf_port <> &lcCurReser..rs_lstart
          SCATTER MEMO NAME loTransfer
          loTransfer.tf_port = &lcCurReser..rs_lstart
          loTransfer.tf_porttyp = &lcCurReser..c_rtstart
          loTransfer.tf_fromdat = &lcCurReser..rs_arrdate
          loTransfer.tf_transfer = .T.
          REPLACE tf_todat WITH &lcCurReser..rs_arrdate-1 IN &tcCurName
          INSERT INTO &tcCurName FROM NAME loTransfer
     ENDIF
     LOCATE FOR tf_boatnum = &lcCurReser..rs_roomnum AND (EMPTY(tf_fromdat) OR tf_fromdat < &lcCurReser..rs_depdate) AND (EMPTY(tf_todat) OR tf_todat > &lcCurReser..rs_depdate-1)
     IF FOUND() AND tf_port <> &lcCurReser..rs_lfinish
          SELECT &tcCurName
          SCATTER MEMO NAME loTransfer
          loTransfer.tf_port = &lcCurReser..rs_lfinish
          loTransfer.tf_porttyp = &lcCurReser..c_rtfinish
          loTransfer.tf_fromdat = &lcCurReser..rs_depdate
          loTransfer.tf_transfer = .F.
          REPLACE tf_todat WITH &lcCurReser..rs_depdate-1 IN &tcCurName
          INSERT INTO &tcCurName FROM NAME loTransfer
     ENDIF
     SELECT &lcCurReser
ENDSCAN
* Search for possible transfers on end of period for each boat (if reservation is not in cursor <lcCurReser>)
SET ORDER TO tag13 IN reservat     && rs_roomnum+DTOS(rs_arrdate)+DTOS(rs_depdate)
SET NEAR ON
lcCurName = SYS(2015)
SELECT * FROM &tcCurName WHERE 0=1 INTO CURSOR &lcCurName READWRITE
SELECT &tcCurName
SET ORDER TO tf_boatto
SCAN
     SELECT &lcCurReser
     LOCATE FOR rs_roomnum = &tcCurName..tf_boatnum AND BETWEEN(tdToDate, rs_arrdate, rs_depdate)
     IF FOUND()
          LOOP
     ENDIF
     SELECT reservat
     =SEEK(&tcCurName..tf_boatnum+DTOS(tdToDate))
     IF rs_roomnum = &tcCurName..tf_boatnum AND INLIST(rs_status, 'CXL', 'NS ')
          LOCATE FOR NOT INLIST(rs_status, 'CXL', 'NS ') WHILE rs_roomnum = &tcCurName..tf_boatnum
     ENDIF
     SELECT &tcCurName
     IF reservat.rs_roomnum = &tcCurName..tf_boatnum AND SEEK(reservat.rs_roomnum+DTOS(tdToDate),tcCurName,"tf_boatto") AND &tcCurName..tf_port <> reservat.rs_lstart
          SCATTER MEMO NAME loTransfer
          loTransfer.tf_port = reservat.rs_lstart
          loTransfer.tf_fromdat = reservat.rs_arrdate
          loTransfer.tf_todat = reservat.rs_depdate
          loTransfer.tf_transfer = .T.
          INSERT INTO &lcCurName FROM NAME loTransfer
     ENDIF
ENDSCAN
SELECT &tcCurName
APPEND FROM DBF(lcCurName)
USE IN &lcCurName
SET NEAR &lcNear
***************************************************************************************************************************************************

SET ORDER TO (lcOrderRS) IN reservat
VehicleRent_GoRecNo(lnRecnoHR, "histres")
VehicleRent_GoRecNo(lnRecnoRS, "reservat")
IF llCloseRS
     USE IN reservat
ENDIF
IF llCloseHR
     USE IN histres
ENDIF
IF llCloseRT
     USE IN roomtype
ENDIF
IF llCloseRD
     USE IN rtypedef
ENDIF
IF llCloseRM
     USE IN room
ENDIF
USE IN &lcCurReser
GO TOP IN &tcCurName

SELECT (lnArea)

RETURN .T.
ENDPROC
*
PROCEDURE VehicleRentRT
LPARAMETERS tdFromDate, tdToDate, tcCurName
LOCAL lnArea, lcSql, lcFldName, llClosePA, llCloseAV, llCloseRS, llCloseHR, llCloseRT, llCloseRD, lcCurReser, lcCurRoomplan, lcCurRoomtype, lcAnyRoomType, ldStartDate

lnArea = SELECT()

IF EMPTY(tcCurName)
     tcCurName = "curAvailab"
ENDIF

IF NOT USED("param")
     USE param IN 0
     llClosePA = .T.
ENDIF
IF NOT USED("availab")
     USE availab IN 0
     llCloseAV = .T.
ENDIF
IF NOT USED("reservat")
     USE reservat IN 0
     llCloseRS = .T.
ENDIF
IF NOT USED("histres")
     USE histres IN 0
     llCloseHR = .T.
ENDIF
IF NOT USED("roomtype")
     USE roomtype IN 0
     llCloseRT = .T.
ENDIF
IF NOT USED("rtypedef")
     USE rtypedef IN 0
     llCloseRD = .T.
ENDIF

lcCurRoomplan = SYS(2015)
lcCurReser = SYS(2015)
ldStartDate = MIN(VehicleRent_SysDate(),tdFromDate)

***************************************************************************************************************************************************
* Get rentable boats location before "tdFromDate" in cursor "lcCurRoomplan"
VehicleRentRM(ldStartDate-1, ldStartDate-1, lcCurRoomplan)
* Point of interest is on boats that are not on mother port
SELECT * FROM &lcCurRoomplan WHERE tf_homeport <> tf_port INTO CURSOR &lcCurRoomplan

***************************************************************************************************************************************************
* Collect all boat reservations for rentable boats on period from "tdFromDate <-> tdToDate" in cursor curReser
*   that not starts on mother port or that change port until finish of trip
* c_rtstart  - Boat room type ID on start  port (rt_buildng = rs_lstart  AND rt_rdid = rd_rdid)
* c_rtfinish - Boat room type ID on finish port (rt_buildng = rs_lfinish AND rt_rdid = rd_rdid)
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT rs_arrdate, rs_depdate, rs_rooms, rs_status, rt1.rt_buildng, rs_roomtyp, rs_lstart, rt2.rt_roomtyp AS c_rtstart, rs_lfinish, rt3.rt_roomtyp AS c_rtfinish
     FROM reservat WITH (Buffering = .T.)
     INNER JOIN roomtype rt1 ON rt1.rt_roomtyp = rs_roomtyp
     INNER JOIN rtypedef ON rd_rdid = rt1.rt_rdid AND rd_verent
     INNER JOIN roomtype rt2 ON rt2.rt_buildng = rs_lstart AND rt2.rt_rdid = rd_rdid
     INNER JOIN roomtype rt3 ON rt3.rt_buildng = rs_lfinish AND rt3.rt_rdid = rd_rdid
     WHERE DTOS(rs_depdate)+rs_roomnum >= <<VehicleRent_SqlCnv(DTOS(ldStartDate),.T.)>> AND
          DTOS(rs_arrdate)+rs_lname <= <<VehicleRent_SqlCnv(DTOS(tdToDate),.T.)>> AND
          rs_lstart <> '   ' AND (rs_lstart <> rt1.rt_buildng OR rs_lfinish <> '   ' AND rs_lfinish <> rs_lstart) AND
          NOT INLIST(rs_status, 'CXL', 'NS ') AND (rt1.rt_group = 1 OR INLIST(rt1.rt_group, 3, 4) AND rt1.rt_vwshow)
UNION ALL
SELECT hr_arrdate, hr_depdate, hr_rooms, hr_status, rt1.rt_buildng, hr_roomtyp, hr_lstart, rt2.rt_roomtyp, hr_lfinish, rt3.rt_roomtyp
     FROM histres
     INNER JOIN roomtype rt1 ON rt1.rt_roomtyp = hr_roomtyp
     INNER JOIN rtypedef ON rd_rdid = rt1.rt_rdid AND rd_verent
     INNER JOIN roomtype rt2 ON rt2.rt_buildng = hr_lstart AND rt2.rt_rdid = rd_rdid
     INNER JOIN roomtype rt3 ON rt3.rt_buildng = hr_lfinish AND rt3.rt_rdid = rd_rdid
     LEFT JOIN reservat ON rs_rsid = hr_rsid
     WHERE hr_depdate >= <<VehicleRent_SqlCnv(ldStartDate,.T.)>> AND
          hr_arrdate <= <<VehicleRent_SqlCnv(tdToDate,.T.)>> AND
          hr_lstart <> '   ' AND (hr_lstart <> rt1.rt_buildng OR hr_lfinish <> '   ' AND hr_lfinish <> hr_lstart) AND
          NOT INLIST(hr_status, 'CXL', 'NS ') AND ISNULL(rs_rsid) AND (rt1.rt_group = 1 OR INLIST(rt1.rt_group, 3, 4) AND rt1.rt_vwshow)
     ORDER BY 1, 2
ENDTEXT
&lcSql INTO CURSOR &lcCurReser

IF RECCOUNT(lcCurRoomplan) > 0 OR RECCOUNT(lcCurReser) > 0
     **********************************************************************************************************************************************
     * Collect all 'affected' boat room type IDs from "lcCurRoomplan and lcCurReser" cursors in cursor "lcCurRoomtype"
     lcCurRoomtype = SYS(2015)
     SELECT rs_roomtyp FROM &lcCurReser ;
     UNION SELECT c_rtstart FROM &lcCurReser ;
     UNION SELECT c_rtfinish FROM &lcCurReser ;
     UNION SELECT tf_hometyp FROM &lcCurRoomplan ;
     UNION SELECT tf_porttyp FROM &lcCurRoomplan ;
          ORDER BY 1 ;
          INTO CURSOR &lcCurRoomtype

     **********************************************************************************************************************************************
     * Make availability correction (differnces, not absolute values) for 'affected' room types on period from "tdFromDate <-> tdToDate" in cursor "curAvailab"
     lcAnyRoomType = &lcCurReser..rs_roomtyp
     TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT av_date, av_avail, av_definit, av_option, av_tentat, av_waiting
          FROM availab
          WHERE BETWEEN(av_date, <<VehicleRent_SqlCnv(tdFromDate,.T.)>>, <<VehicleRent_SqlCnv(tdToDate,.T.)>>) AND av_roomtyp = <<VehicleRent_SqlCnv(lcAnyRoomType,.T.)>>
     ENDTEXT
     &lcSql INTO CURSOR &tcCurName READWRITE
     BLANK FIELDS av_avail, av_definit, av_option, av_tentat, av_waiting ALL IN &tcCurName
     SELECT rs_roomtyp AS av_roomtyp, &tcCurName..* FROM &tcCurName, &lcCurRoomtype ORDER BY av_date, 1 INTO CURSOR &tcCurName READWRITE
     INDEX ON av_date TAG av_date
     INDEX ON av_roomtyp TAG av_roomtyp
     SET ORDER TO
     USE IN &lcCurRoomtype

     * Make correction for initial state of availability from cursor "lcCurRoomplan"
     * If some boats are not on mother port before "tdFromDate" then move them from mother port availability to current port availability
     SELECT &lcCurRoomplan
     SCAN
          REPLACE av_avail WITH av_avail - 1 ;
               FOR av_roomtyp = &lcCurRoomplan..tf_hometyp ;
               IN &tcCurName
          REPLACE av_avail WITH av_avail + 1 ;
               FOR av_roomtyp = &lcCurRoomplan..tf_porttyp ;
               IN &tcCurName
     ENDSCAN

     **********************************************************************************************************************************************
     * Calculating availability correction depends on collected boat reservations on period from "tdFromDate <-> tdToDate"
     SELECT &lcCurReser
     SCAN
          * If boat not starts its trip on mother port (rs_lstart <> mother port) then from "rs_arrdate-rs_depdate" move its occupancy from mother port occupancy to start port occupancy
          IF rs_lstart <> rt_buildng
               lcFldName = ICASE(rs_status = "OPT", "av_option", rs_status = "LST", "av_waiting", rs_status = "TEN", "av_tentat", "av_definit")
               REPLACE &lcFldName WITH &lcFldName - &lcCurReser..rs_rooms ;
                    FOR av_date >= &lcCurReser..rs_arrdate AND av_date < &lcCurReser..rs_depdate AND av_roomtyp = &lcCurReser..rs_roomtyp ;
                    IN &tcCurName
               REPLACE &lcFldName WITH &lcFldName + &lcCurReser..rs_rooms ;
                    FOR av_date >= &lcCurReser..rs_arrdate AND av_date < &lcCurReser..rs_depdate AND av_roomtyp = &lcCurReser..c_rtstart ;
                    IN &tcCurName
          ENDIF
          * If boat change port until finish of trip (rs_lfinish <> rs_lstart) then after finish of trip move its availability from start port to finish port
          IF rs_lfinish <> rs_lstart
               REPLACE av_avail WITH av_avail - &lcCurReser..rs_rooms ;
                    FOR av_date >= &lcCurReser..rs_depdate AND av_roomtyp = &lcCurReser..c_rtstart ;
                    IN &tcCurName
               REPLACE av_avail WITH av_avail + &lcCurReser..rs_rooms ;
                    FOR av_date >= &lcCurReser..rs_depdate AND av_roomtyp = &lcCurReser..c_rtfinish ;
                    IN &tcCurName
          ENDIF
     ENDSCAN
     GO TOP IN &tcCurName
ENDIF
***************************************************************************************************************************************************

IF llClosePA
     USE IN param
ENDIF
IF llCloseAV
     USE IN availab
ENDIF
IF llCloseRS
     USE IN reservat
ENDIF
IF llCloseHR
     USE IN histres
ENDIF
IF llCloseRT
     USE IN roomtype
ENDIF
IF llCloseRD
     USE IN rtypedef
ENDIF
USE IN &lcCurRoomplan
USE IN &lcCurReser

SELECT (lnArea)

RETURN .T.
ENDPROC
*
PROCEDURE VehicleRentCheckTransfer
LPARAMETERS tcRoomnum, tdArrDate, tdDepDate, taDatesPorts
EXTERNAL ARRAY taDatesPorts
LOCAL lnArea, lcCurRoomplan

lnArea = SELECT()

STORE .F. TO taDatesPorts
lcCurRoomplan = SYS(2015)
VehicleRentRM(tdArrDate-1, tdDepDate+1, lcCurRoomplan, tcRoomnum)
IF USED(lcCurRoomplan)
     SELECT tf_fromdat, tf_port FROM &lcCurRoomplan WHERE tf_transfer INTO ARRAY taDatesPorts
     USE IN &lcCurRoomplan
ENDIF

SELECT (lnArea)

RETURN NOT EMPTY(taDatesPorts(1))
ENDPROC
*
PROCEDURE VehicleRentFixAvailability
LPARAMETERS tdStartDate, tdEndDate, tCurAvailab
LOCAL lcCur, lnSelect, lnOrder

lnSelect = SELECT()

lcCur = SYS(2015)
VehicleRentRT(tdStartDate, tdEndDate, lcCur)
IF NOT USED(lcCur)
     SELECT (lnSelect)
     RETURN .T.
ENDIF

lnOrder = ORDER(tCurAvailab)
SET ORDER TO 0 IN &tCurAvailab

SELECT (lcCur)
SCAN FOR av_avail <> 0 OR av_definit <> 0 OR av_option <> 0 OR av_tentat <> 0 OR av_waiting <> 0
     REPLACE av_avail WITH av_avail + &lcCur..av_avail, ;
             av_definit WITH av_definit + &lcCur..av_definit, ;
             av_option WITH av_option + &lcCur..av_option, ;
             av_tentat WITH av_tentat + &lcCur..av_tentat, ;
             av_waiting WITH av_waiting + &lcCur..av_waiting ;
          FOR av_date = &lcCur..av_date AND av_roomtyp = &lcCur..av_roomtyp ;
          IN &tCurAvailab
ENDSCAN

USE IN (lcCur)

SET ORDER TO lnOrder IN &tCurAvailab
SELECT (lnSelect)

RETURN .T.
ENDPROC
*
PROCEDURE VehicleRent_SysDate
LOCAL ldSysDate

TRY
     ldSysDate = SysDate()
CATCH
     ldSysDate = param.pa_sysdate
ENDTRY

RETURN ldSysDate
ENDPROC
*
PROCEDURE VehicleRent_SqlCnv
LPARAMETER puExpr, plodbc
LOCAL ctYpe, crEt, cpOint, cdAte
crEt = ''
ctYpe = TYPE('puExpr')
DO CASE
     CASE INLIST(ctYpe,'D','T') AND EMPTY(puExpr)
          crEt = '{}'
     CASE ctYpe='C' .OR. ctYpe='M'
          crEt = '['+puExpr+']'
     CASE ctYpe='D'
          cdAte = DTOS(puExpr)
          crEt = '{^'+SUBSTR(cdAte, 1, 4)+'-'+SUBSTR(cdAte, 5, 2)+'-'+ ;
                 SUBSTR(cdAte, 7, 2)+'}'
     CASE ctYpe='L'
          crEt = IIF(puExpr, '.t.', '.f.')
     CASE ctYpe='N' OR ctYpe='Y'
          IF INT(puExpr)=puExpr
               crEt = LTRIM(STR(puExpr))
          ELSE
               cpOint = SET('point')
               crEt = LTRIM(STR(puExpr, 20, 8))
               crEt = STRTRAN(crEt, cpOint, '.')
               DO WHILE RIGHT(crEt, 1)='0'
                    crEt = SUBSTR(crEt, 1, LEN(crEt)-1)
               ENDDO
               * When converted string is longer as 16 character, that means, we have numeric
               * which has precision greater as 16.
               * In this case, use transform function, becouse numeric value can wrongly have more decimals numbers
               * on end.
               *
               * Example:
               * puExpr = 88094650.201 && ReserId
               * ? STR(puExpr, 20, 8) && Gives back 88094650.20100001
               IF LEN(crEt)>16
                    crEt = TRANSFORM(puExpr)
                    crEt = STRTRAN(crEt, cpOint, '.')
               ENDIF
          ENDIF
     CASE ctype = 'T'
          cret = "{^" + ALLTRIM(STR(YEAR(puexpr))) + "-" + ;
                  ALLTRIM(STR(MONTH(puexpr))) + "-" + ;
                  ALLTRIM(STR(DAY(puexpr))) + " " + ;
                  ALLTRIM(STR(HOUR(puexpr))) + ":" + ;
                  ALLTRIM(STR(MINUTE(puexpr))) + ":" + ;
                  ALLTRIM(STR(SEC(puexpr))) + "}"
ENDCASE
RETURN crEt
ENDFUNC
*
PROCEDURE VehicleRent_GoRecNo
LPARAMETERS lp_nRecNo, lp_cAlias
TRY
     GO lp_nRecNo IN (lp_cAlias)
CATCH
ENDTRY
RETURN .T.
ENDPROC