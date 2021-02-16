PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.60"
RETURN tcVersion
ENDPROC
*
PROCEDURE _fc07000
PARAMETER tlWithoutVat, tcType, tcResFilter
LOCAL lcLabel, loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

IF TYPE("tcType") # "C"
     tcType = "M"
ENDIF
IF TYPE("tcResFilter") # "C"
     tcResFilter = ".T."
ENDIF
DO CASE
     CASE tcType == "S"          && S = Sourcecode/Herkunfscode
          lcLabel = "SOURCE"
     CASE tcType == "P"          && P = Preiscode
          lcLabel = "RATECOD"
     OTHERWISE && tcType == "M"  && M = Marketcode
          lcLabel = "MARKET"
ENDCASE
loSession = CREATEOBJECT("_fc07000")
loSession.DoPreproc(tlWithoutVat, lcLabel, tcResFilter, @laPreProc)
RELEASE loSession
SysDate()

PpCusorCreate()
IF NOT EMPTY(laPreProc(1))
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
*
PROCEDURE PpCusorCreate
CREATE CURSOR PreProc (pp_date D(8), pp_codeid N(3), pp_code C (10), pp_descr C (25), pp_rms N(8), pp_lyrms N(8), pp_prs N(8), pp_maxrms N(8), pp_rev B(2))
INDEX ON DTOC(pp_date,1)+pp_code TAG pp_code
ENDPROC
*
PROCEDURE PpCusorInit
LPARAMETERS tcLabel
LOCAL i, lcurDates, lcLang
LOCAL ARRAY laRooms(1)

SELECT COUNT(*) FROM Room ;
     INNER JOIN RoomType ON rm_roomtyp = rt_roomtyp ;
     WHERE INLIST(rt_group,1,4) AND rt_vwsum ;
     INTO ARRAY laRooms

lcurDates = MakeDatesCursor(pdStartDate, pdEndDate)
SELECT c_date, laRooms(1) AS pp_maxrms FROM &lcurDates INTO CURSOR &lcurDates READWRITE

DIMENSION laRooms(1)
SELECT ooo.* FROM ( ;
     SELECT oo_fromdat, oo_todat, oo_roomnum FROM OutOfOrd ;
          WHERE oo_fromdat <= pdEndDate AND oo_todat > pdStartDate AND NOT oo_cancel ;
     UNION ALL ;
     SELECT ho.oo_fromdat, ho.oo_todat, ho.oo_roomnum FROM HOutOfOr ho ;
     LEFT JOIN OutOfOrd ON OutOfOrd.oo_id = ho.oo_id ;
          WHERE ho.oo_fromdat <= pdEndDate AND ho.oo_todat > pdStartDate AND NOT ho.oo_cancel AND ISNULL(OutOfOrd.oo_id) ;
     ) ooo ;
     INNER JOIN Room ON rm_roomnum = ooo.oo_roomnum ;
     INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp AND INLIST(rt_group,1,4) AND rt_vwsum ;
     INTO ARRAY laRooms
IF ALEN(laRooms) > 1
     FOR i = 1 TO ALEN(laRooms,1)
          UPDATE &lcurDates SET pp_maxrms = pp_maxrms - 1 WHERE BETWEEN(c_date, laRooms(i,1), laRooms(i,2)-1)
     NEXT
ENDIF

IF tcLabel = "RATECOD"  && Preiscode
     lcLang = "rc_lang" + g_Langnum
     SELECT RECNO() AS pp_codeid, * FROM ( ;
          SELECT rc_ratecod AS pp_code, &lcLang AS pp_descr FROM ratecode ;
          UNION SELECT [*****], [Unknown] FROM ratecode GROUP BY 1 ORDER BY 1) rc ;
          INTO CURSOR curCodes
ELSE
     * Marketcode and Herkunfscode
     lcLang = "pl_lang" + g_Langnum
     SELECT RECNO() AS pp_codeid, * FROM ( ;
          SELECT pl_charcod AS pp_code, &lcLang AS pp_descr FROM picklist WHERE pl_label = tcLabel ;
          UNION SELECT [*****], [Unknown] FROM picklist GROUP BY 1 ORDER BY 1) pl ;
          INTO CURSOR curCodes
ENDIF

INSERT INTO PreProc (pp_date, pp_codeid, pp_code, pp_descr, pp_maxrms) ;
     SELECT DISTINCT c_date, pp_codeid, pp_code, pp_descr, pp_maxrms FROM curCodes, &lcurDates ORDER BY 1,2

DClose("curCodes")
DClose(lcurDates)
ENDPROC
*
PROCEDURE PpCusorGroup
LPARAMETERS tcLabel
LOCAL lcLang, ldDate, lnCodeCnt

IF min4 AND tcLabel = "RATECOD"
     lcLang = "pl_lang" + g_Langnum
     SELECT pp_date, pp_codeid, NVL(PADR(pl_charcod,10), pp_code) AS pp_code, NVL(&lcLang, pp_descr) AS pp_descr, ;
          SUM(pp_rms) AS pp_rms, SUM(pp_lyrms) AS pp_lyrms, SUM(pp_prs) AS pp_prs, pp_maxrms, SUM(pp_rev) AS pp_rev FROM PreProc ;
          LEFT JOIN (SELECT DISTINCT rc_ratecod, rc_group FROM ratecode) a ON pp_code = a.rc_ratecod  ;
          LEFT JOIN picklist ON pl_label+pl_charcod = "RCODEGROUP"+a.rc_group ;
          GROUP BY pp_date, pp_codeid, 3, 4 ;
          INTO CURSOR PreProc READWRITE
ENDIF

ldDate = PreProc.pp_date
CALCULATE CNT() FOR pp_date = ldDate TO lnCodeCnt IN PreProc
IF lnCodeCnt > 0
     REPLACE pp_codeid WITH MOD(RECNO("PreProc")-1,lnCodeCnt)+1 ALL IN PreProc
ENDIF

REPLACE pp_code WITH "Passerby" FOR pp_code = "*****" IN PreProc
ENDPROC
*
PROCEDURE OccupancyRevnueGenerate
LPARAMETERS tcLabel

* Recalculating occupancy and revnue statistic in present.
SELECT reservat
SCAN
     WAIT WINDOW NOWAIT STR(rs_reserid, 12, 3)
     OrResUpd(tcLabel, "reservat")
     REPLACE pa_sysdate WITH reservat.rs_arrdate IN param
     SysDate()
     DO BqPost IN Banquet
     DO RateCodePost IN RatePost WITH MIN(pdEndDate,reservat.rs_depdate), "",,, .T.
     REPLACE resrooms WITH reservat.rs_rooms ;
             resrtgroup WITH DLookUp("RoomType", "rt_roomtyp = reservat.rs_roomtyp", "rt_group") ;
             resstatus WITH reservat.rs_status ;
             rescode WITH IIF(tcLabel = "RATECOD", IIF(EMPTY(post.ps_ratecod), '*****', post.ps_ratecod), EVALUATE("reservat.rs_"+tcLabel)) ;
             FOR EMPTY(rescode) IN post
ENDSCAN
           
* Recalculating occupancy statistic in history.
SELECT histres
SCAN
     WAIT WINDOW NOWAIT STR(hr_reserid, 12, 3)
     OrResUpd(tcLabel, "histres")
ENDSCAN
ENDPROC
*
PROCEDURE LastYearOccupancyRevnueGenerate
LPARAMETERS tcLabel

* Recalculating occupancy and revnue statistic in present.
SELECT reservatLy
SCAN
     WAIT WINDOW NOWAIT STR(rs_reserid, 12, 3)
     OrResUpd(tcLabel, "reservatLy", .T.)
ENDSCAN
           
* Recalculating occupancy statistic in history.
SELECT histresLy
SCAN
     WAIT WINDOW NOWAIT STR(hr_reserid, 12, 3)
     OrResUpd(tcLabel, "histresLy", .T.)
ENDSCAN
ENDPROC
*
PROCEDURE RevnueGenerate
LPARAMETERS tlWithoutVat
LOCAL lnMainGroup, lnAmount

SELECT post
SCAN FOR (NOT min3 OR INLIST(resrtgroup, 1, 4)) AND NOT EMPTY(ps_artinum) AND NOT EMPTY(ps_amount) AND ;
          NOT ps_cancel AND (ps_split OR EMPTY(ps_ratecod))
     lnMainGroup = DLookUp("article", "ar_artinum = " + SqlCnv(ps_artinum), "ar_main")
     IF BETWEEN(lnMainGroup, min2, max2) AND SEEK(DTOC(ps_date,1)+rescode,'PreProc','pp_code')
          lnAmount = ps_amount - IIF(tlWithoutVat, ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9, 0)
          REPLACE pp_rev WITH pp_rev + lnAmount * post.resrooms IN PreProc
     ENDIF
ENDSCAN
ENDPROC
*
PROCEDURE OrResUpd
LPARAMETERS tcLabel, tcResAlias, tlLastYear
LOCAL lcCode, lnSelect, lcOrder, ldDate, llGetResState, loResCurrent, loResNext, lcResRooms, lcResRate
LOCAL lnReserid, lnRooms, lcRatecode, lcStatus, ldArrDate, ldDepDate, llSharing, llGroup, ldForDate
LOCAL lnRsRooms, lcRsRatecode, lnRsPax, lcRsRoomtype, lcRsRoomnum, lnPersons, lcRoomtype, lcRoomnum

lnSelect = SELECT()

IF EMPTY(tcResAlias)
    tcResAlias = "reservat"
ENDIF
IF INLIST(tcResAlias, "reservat", "reservatLy")
    lcResRooms = "resrooms"
    lcResRate = "resrate"
    lnReserid = &tcResAlias..rs_reserid
    lcStatus = &tcResAlias..rs_status
    ldArrDate = &tcResAlias..rs_arrdate
    ldDepDate = &tcResAlias..rs_depdate
    llGroup = NOT EMPTY(&tcResAlias..rs_group)
    lcRsRoomtype = &tcResAlias..rs_roomtyp
    lcRsRoomnum = &tcResAlias..rs_roomnum
    lnRsRooms = &tcResAlias..rs_rooms
    lcRsRatecode = CHRTRAN(&tcResAlias..rs_ratecod,"*!","")
    lnPersons = &tcResAlias..rs_adults + &tcResAlias..rs_childs + &tcResAlias..rs_childs2 + &tcResAlias..rs_childs3
    DO CASE
         CASE tcLabel = "MARKET"
              lcCode = &tcResAlias..rs_market
         CASE tcLabel = "SOURCE"
              lcCode = &tcResAlias..rs_source
         CASE tcLabel = "RATECOD"
         OTHERWISE
              RETURN
    ENDCASE
ELSE
    lcResRooms = "hresroom"
    lcResRate = "hresrate"
    lnReserid = &tcResAlias..hr_reserid
    lcStatus = &tcResAlias..hr_status
    ldArrDate = &tcResAlias..hr_arrdate
    ldDepDate = &tcResAlias..hr_depdate
    llGroup = NOT EMPTY(&tcResAlias..hr_group)
    lcRsRoomtype = &tcResAlias..hr_roomtyp
    lcRsRoomnum = &tcResAlias..hr_roomnum
    lnRsRooms = &tcResAlias..hr_rooms
    lcRsRatecode = CHRTRAN(&tcResAlias..hr_ratecod,"*!","")
    lnPersons = &tcResAlias..hr_adults + &tcResAlias..hr_childs + &tcResAlias..hr_childs2 + &tcResAlias..hr_childs3
    DO CASE
         CASE tcLabel = "MARKET"
              lcCode = &tcResAlias..hr_market
         CASE tcLabel = "SOURCE"
              lcCode = &tcResAlias..hr_source
         CASE tcLabel = "RATECOD"
         OTHERWISE
              RETURN
    ENDCASE
ENDIF

ldDate = MAX(pdStartDate, ldArrDate)
DO WHILE ldDate <= MIN(pdEndDate, ldDepDate)
     llGetResState = (ldDate = MAX(pdStartDate, ldArrDate)) OR ISNULL(loResCurrent) OR ISNULL(loResNext) OR ;
          loResCurrent.ri_rroomid <> loResNext.ri_rroomid AND ;
          NOT BETWEEN(ldDate, loResCurrent.ri_date, loResNext.ri_date-1)
     IF llGetResState
          RiGetRoom(lnReserid, ldDate, @loResCurrent, @loResNext, lcResRooms)
          IF ISNULL(loResCurrent)
               llSharing = .F.
               lcRoomtype = lcRsRoomtype
               lcRoomnum = lcRsRoomnum
          ELSE
               llSharing = NOT EMPTY(loResCurrent.ri_shareid)
               lcRoomtype = loResCurrent.ri_roomtyp
               lcRoomnum = loResCurrent.ri_roomnum
          ENDIF
          lnRooms = lnRsRooms
          DO OrRooms IN Orupd WITH lcRoomtype, lnRooms, lcRoomnum
     ENDIF
     IF min3 AND NOT DbLookup("roomtype","tag1",lcRoomtype,"INLIST(rt_group,1,4)")
          ldDate = ldDate + 1
          LOOP
     ENDIF
     IF NOT ISNULL(loResCurrent) AND NOT EMPTY(loResCurrent.ri_shareid)
          llSharing = (lnReserId <> RiGetShareFirstReserId(loResCurrent.ri_shareid, ldDate))
     ENDIF

     IF SEEK(STR(lnReserid,12,3)+DTOS(ldDate), lcResRate, "tag2")
          lcRatecode = LEFT(IIF(&lcResRate..rr_status = "X", CHRTRAN(&lcResRate..rr_ratecod,"*!",""), &lcResRate..rr_ratecod),10)
          lnPersons = &lcResRate..rr_adults + &lcResRate..rr_childs + &lcResRate..rr_childs2 + &lcResRate..rr_childs3
     ELSE
          lcRatecode = lcRsRatecode
     ENDIF

     IF tcLabel = "RATECOD"
          lcCode = lcRatecode
     ENDIF

     ldForDate = IIF(tlLastYear, DATE(YEAR(ldDate)+1,MONTH(ldDate),DAY(ldDate)), ldDate)
     IF SEEK(DTOC(ldForDate,1)+lcCode,'PreProc','pp_code')
          IF ldDate < MIN(pdEndDate+1, ldDepDate)
               IF tlLastYear
                    IF NOT llSharing
                         REPLACE pp_lyrms WITH pp_lyrms + lnRooms IN PreProc
                    ENDIF
               ELSE
                    IF NOT llSharing
                         REPLACE pp_rms WITH pp_rms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_prs WITH pp_prs + lnPersons IN PreProc
               ENDIF
          ENDIF
     ENDIF
     ldDate = ldDate + 1
ENDDO

SELECT (lnSelect)
ENDPROC
*
DEFINE CLASS _fc07000 AS Session

PROCEDURE Init
Ini()
OpenFile()
PpCusorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER tlWithoutVat, tcLabel, tcResFilter, taPreProc
LOCAL lcReserTemp, lcLyReserTemp, lcPostTemp, lcPostchngTemp, lcHistresTemp, lcLyHistresTemp, lcIdTemp, lcParamTemp
LOCAL ldLyStartDate, ldLyEndDate
PRIVATE pdStartDate, pdEndDate

pdStartDate = MonthStart(min1)
pdEndDate = DATE(YEAR(min1),MONTH(min1),LastDay(min1))
ldLyStartDate = DATE(YEAR(min1)-1,MONTH(min1),1)
ldLyEndDate = DATE(YEAR(min1)-1,MONTH(min1),LastDay(min1))

PpCusorInit(tcLabel)

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     INNER JOIN (
     SELECT hr_reserid AS c_reserid FROM histres
          WHERE hr_reserid >= 1 AND (hr_arrdate <= <<SqlCnvB(pdEndDate)>> AND hr_depdate >= <<SqlCnvB(pdStartDate)>> OR hr_arrdate <= <<SqlCnvB(ldLyEndDate)>> AND hr_depdate >= <<SqlCnvB(ldLyStartDate)>>)
     UNION
     SELECT hr_reserid FROM histres
          INNER JOIN histpost ON hp_origid = hr_reserid
          WHERE hp_reserid > 0 AND BETWEEN(hp_date, <<SqlCnvB(pdStartDate)>>, <<SqlCnvB(pdEndDate)>>)
          GROUP BY hr_reserid
     ) hr ON hr_reserid = c_reserid;

SELECT histpost.* FROM histpost
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, <<SqlCnvB(pdStartDate)>>, <<SqlCnvB(pdEndDate)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, ldLyStartDate)
*
****************************************************************************************************

* fake Post
lcPostTemp = Filetemp('DBF')
SELECT post
COPY TO (lcPostTemp) WITH CDX FOR ps_reserid > 0 AND BETWEEN(ps_date, pdStartDate, pdEndDate) AND ;
     NOT EMPTY(ps_artinum) AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split)
USE IN post
USE EXCLUSIVE (lcPostTemp) ALIAS post IN 0
ALTER TABLE post ADD COLUMN resrooms N(3) ADD COLUMN resrtgroup N(1) ADD COLUMN resstatus C(3) ADD COLUMN rescode C(10)

lcCodeField = "reservat.rs_" + tcLabel
SELECT post
SCAN FOR ps_origid >= 1 AND SEEK(ps_origid, "reservat", "tag1")
     REPLACE resrooms WITH reservat.rs_rooms ;
             resrtgroup WITH DLookUp("RoomType", "rt_roomtyp = reservat.rs_roomtyp", "rt_group") ;
             resstatus WITH reservat.rs_status ;
             rescode WITH IIF(tcLabel = "RATECOD", IIF(EMPTY(post.ps_ratecod), '*****', post.ps_ratecod), IIF(EMPTY(&lcCodeField), '*****', &lcCodeField)) ;
             IN post
ENDSCAN
lcCodeField = "histres.hr_" + tcLabel
SELECT post
SCAN FOR EMPTY(rescode) AND ps_origid >= 1 AND SEEK(ps_origid, "histres", "tag1")
     REPLACE resrooms WITH histres.hr_rooms ;
             resrtgroup WITH DLookUp("RoomType", "rt_roomtyp = histres.hr_roomtyp", "rt_group") ;
             resstatus WITH histres.hr_status ;
             rescode WITH IIF(tcLabel = "RATECOD", IIF(EMPTY(post.ps_ratecod), '*****', post.ps_ratecod), IIF(EMPTY(&lcCodeField), '*****', &lcCodeField)) ;
             IN post
ENDSCAN

* Move from histpost --> post
lcCodeField = "hr_"+tcLabel
INSERT INTO post (ps_postid, ps_date, ps_reserid, ps_origid, ps_amount, ps_artinum, ps_ratecod, ps_split, ps_cancel, ;
     ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, resrooms, resrtgroup, resstatus, rescode) ;
     SELECT hp_postid, hp_date, hp_reserid, hp_origid, hp_amount, hp_artinum, hp_ratecod, hp_split, hp_cancel, ;
     hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, NVL(hr_rooms,0), NVL(rt_group,0), NVL(hr_status,""), ;
     PADR(IIF(tcLabel = "RATECOD", IIF(EMPTY(hp_ratecod), '*****', hp_ratecod), NVL(&lcCodeField,'*****')),10) FROM histpost ;
     LEFT JOIN histres ON hr_reserid = hp_origid ;
     LEFT JOIN roomtype ON rt_roomtyp = hr_roomtyp ;
     LEFT JOIN hresrate ON rr_reserid = hr_reserid AND rr_date = hp_date ;
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, pdStartDate, pdEndDate) AND NOT SEEK(hp_postid, "post", "tag3") AND ;
     NOT EMPTY(hp_artinum) AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split)

REPLACE resrooms WITH 1, resrtgroup WITH 0, resstatus WITH 'OUT', rescode WITH '*****' FOR EMPTY(rescode) AND ps_origid < 1 IN post

* fake Reservat
lcReserTemp = Filetemp('DBF')
SELECT reservat
COPY TO (lcReserTemp) WITH CDX ALL FOR rs_arrdate <= pdEndDate AND rs_depdate >= pdStartDate AND NOT INLIST(rs_status, "CXL", "NS", "LST") AND ;
          (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter
lcLyReserTemp = Filetemp('DBF')
COPY TO (lcLyReserTemp) WITH CDX ALL FOR rs_arrdate <= ldLyEndDate AND rs_depdate >= ldLyStartDate AND NOT INLIST(rs_status, "CXL", "NS", "LST") AND ;
          (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter
USE IN reservat
USE EXCLUSIVE (lcReserTemp) ALIAS reservat IN 0
USE EXCLUSIVE (lcLyReserTemp) ALIAS reservatLy IN 0

* fake Histres
tcResFilter = STRTRAN(tcResFilter, "rs_", "hr_")
lcHistresTemp = Filetemp('DBF')
SELECT histres
COPY TO (lcHistresTemp) WITH CDX ALL FOR hr_reserid >= 1 AND hr_arrdate <= pdEndDate AND hr_depdate >= pdStartDate AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND ;
          (hr_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter AND NOT SEEK(hr_reserid, "reservat", "tag1")
lcLyHistresTemp = Filetemp('DBF')
COPY TO (lcLyHistresTemp) WITH CDX ALL FOR hr_reserid >= 1 AND hr_arrdate <= ldLyEndDate AND hr_depdate >= ldLyStartDate AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND ;
          (hr_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter AND NOT SEEK(hr_reserid, "reservatLy", "tag1")
******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
USE IN histres
USE (lcHistresTemp) IN 0 ALIAS histres EXCLUSIVE
USE (lcLyHistresTemp) IN 0 ALIAS histresLy EXCLUSIVE

* fake Postchng
lcPostchngTemp = Filetemp('DBF')
SELECT postchng
COPY TO (lcPostchngTemp) STRUCTURE WITH CDX
USE IN postchng
USE EXCLUSIVE (lcPostchngTemp) ALIAS postchng IN 0

* fake Id
lcIdTemp = Filetemp('DBF')
SELECT id
COPY TO (lcIdTemp) STRUCTURE WITH CDX
USE IN id
USE EXCLUSIVE (lcIdTemp) ALIAS id IN 0

* fake Param
lcParamTemp = Filetemp('DBF')
SELECT param
COPY TO (lcParamTemp)
USE IN param
USE EXCLUSIVE (lcParamTemp) ALIAS param IN 0

g_lFakeResAndPost = .T.
OccupancyRevnueGenerate(tcLabel)
RevnueGenerate(tlWithoutVat)
pdStartDate = ldLyStartDate
pdEndDate = ldLyEndDate
LastYearOccupancyRevnueGenerate(tcLabel)
g_lFakeResAndPost = .F.

USE IN reservat
FileDelete(lcReserTemp)
FileDelete(STRTRAN(lcReserTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcReserTemp, '.DBF', '.FPT'))
USE IN reservatLy
FileDelete(lcLyReserTemp)
FileDelete(STRTRAN(lcLyReserTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcLyReserTemp, '.DBF', '.FPT'))
USE IN post
FileDelete(lcPostTemp)
FileDelete(STRTRAN(lcPostTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcPostTemp, '.DBF', '.FPT'))
USE IN postchng
FileDelete(lcPostchngTemp)
FileDelete(STRTRAN(lcPostchngTemp, '.DBF', '.CDX'))
USE IN histres
FileDelete(lcHistresTemp)
FileDelete(STRTRAN(lcHistresTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcHistresTemp, '.DBF', '.FPT'))
USE IN histresLy
FileDelete(lcLyHistresTemp)
FileDelete(STRTRAN(lcLyHistresTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcLyHistresTemp, '.DBF', '.FPT'))
USE IN id
FileDelete(lcIdTemp)
USE IN param
FileDelete(lcParamTemp)

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histpost")
*
****************************************************************************************************

PpCusorGroup(tcLabel)
SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE