PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "6.60"
RETURN tcVersion
ENDPROC
*
PROCEDURE _bg03000
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_bg03000")
loSession.DoPreproc("MARKET", @laPreProc)
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
CREATE CURSOR PreProc (pp_code C (3), pp_descr C (25), pp_date D(8), pp_brms N(8), pp_rms N(8), pp_brev B(2), pp_rev B(2))
INDEX ON pp_code+DTOC(pp_date,1) TAG pp_code
ENDPROC
*
PROCEDURE PpCusorInit
LPARAMETERS tcLabel
LOCAL ldDate, lcLang

CREATE CURSOR tmpPeriod (tp_date D(8))

ldDate = min1
DO WHILE ldDate <= max1
     INSERT INTO tmpPeriod VALUES (ldDate)
     ldDate = ldDate + 1
ENDDO

lcLang = "pl_lang" + g_Langnum
INSERT INTO PreProc (pp_code, pp_descr, pp_date) ;
     SELECT pl_charcod AS pp_code, &lcLang AS pp_descr, tp_date AS pp_date FROM picklist, tmpPeriod ;
          WHERE pl_label = tcLabel ;
          ORDER BY pl_charcod

USE IN tmpPeriod
ENDPROC

PROCEDURE BudgetOccupancyRevnueGenerate
LPARAMETERS tcLabel
LOCAL llBgddaysClose, lcLabelCode, lnYear, lnMonth, lcKey, ldForDate

IF NOT USED("bgddays")
     OpenFile(.F., "bgddays")
     llBgddaysClose = .T.
ENDIF

lnYear = YEAR(min1)
lnMonth = MONTH(min1)
DO WHILE DATE(lnYear, lnMonth, 1) <= max1
     lcKey = STR(lnYear,4) + STR(lnMonth,2) + STR(0,4)

     SELECT bgddays
     SCAN FOR bd_key+STR(bd_day,3) = lcKey + PADR(UPPER("RMNT_PER_MARKET"),20) AND NOT EMPTY(bd_roomnts)
          lcLabelCode = SUBSTR(bd_key,32,3)
          ldForDate = DATE(lnYear, lnMonth, bd_day)
          IF BETWEEN(ldForDate, Min1, Max1) AND SEEK(PADR(lcLabelCode,3)+DTOC(ldForDate,1),'PreProc','pp_code')
               REPLACE pp_brms WITH bgddays.bd_roomnts IN PreProc
          ENDIF
     ENDSCAN
     SCAN FOR bd_key+STR(bd_day,3) = lcKey + PADR(UPPER("REV_PER_MARKET"),20) AND NOT EMPTY(bd_revenue)
          lcLabelCode = SUBSTR(bd_key,32,3)
          ldForDate = DATE(lnYear, lnMonth, bd_day)
          IF BETWEEN(ldForDate, Min1, Max1) AND SEEK(PADR(lcLabelCode,3)+DTOC(ldForDate,1),'PreProc','pp_code')
               REPLACE pp_brev WITH bgddays.bd_revenue IN PreProc
          ENDIF
     ENDSCAN

     IF lnMonth = 12
          lnYear = lnYear + 1
          lnMonth = 1
     ELSE
          lnMonth = lnMonth + 1
     ENDIF
ENDDO

IF llBgddaysClose
     CloseFile("bgddays")
ENDIF
ENDPROC
*
PROCEDURE OccupancyRevnueGenerate
LPARAMETERS tcLabel
LOCAL lcCodeField

* Recalculating occupancy and revnue statistic in present.
lcCodeField = "reservat.rs_" + tcLabel
SELECT reservat
SCAN
     WAIT WINDOW NOWAIT STR(rs_reserid, 12, 3)
     OrResUpd(tcLabel, "reservat")
     REPLACE pa_sysdate WITH reservat.rs_arrdate IN param
     SysDate()
     DO BqPost IN Banquet
     DO RateCodePost IN RatePost WITH MIN(max1,reservat.rs_depdate), "",,, .T.
     REPLACE resrooms WITH reservat.rs_rooms ;
             resrtgroup WITH DLookUp("RoomType", "rt_roomtyp = reservat.rs_roomtyp", "rt_group") ;
             resstatus WITH reservat.rs_status ;
             rescode WITH &lcCodeField ;
             FOR EMPTY(rescode) IN post
     SELECT reservat
ENDSCAN

* Recalculating occupancy statistic in history.
SELECT histres
SCAN
     WAIT WINDOW NOWAIT STR(hr_reserid, 12, 3)
     OrResUpd(tcLabel, "histres")
ENDSCAN
ENDPROC
*
PROCEDURE RevnueGenerate
LOCAL lnMainGroup

SELECT post
SCAN FOR (NOT min3 OR INLIST(resrtgroup, 1, 4)) AND NOT EMPTY(ps_artinum) AND NOT EMPTY(ps_amount) AND ;
          NOT ps_cancel AND (ps_split OR EMPTY(ps_ratecod))
     lnMainGroup = DLookUp("article", "ar_artinum = " + SqlCnv(ps_artinum), "ar_main")
     IF BETWEEN(lnMainGroup, min2, max2) AND SEEK(PADR(rescode,3)+DTOC(ps_date,1),'PreProc','pp_code')
          REPLACE pp_rev WITH pp_rev + post.ps_amount * post.resrooms IN PreProc
     ENDIF
ENDSCAN
ENDPROC
*
PROCEDURE OrResUpd
LPARAMETERS tcLabel, tcResAlias
LOCAL lcCode, lnSelect, lcOrder, ldDate, llGetResState, loResCurrent, loResNext, lcResRooms, lcResRate
LOCAL lnReserid, lnRooms, lcRatecode, lcStatus, ldArrDate, ldDepDate, llSharing, llGroup
LOCAL lnRsRooms, lcRsRatecode, lnRsPax, lcRsRoomtype, lcRsRoomnum, lnPersons, lcRoomtype, lcRoomnum

lnSelect = SELECT()

IF EMPTY(tcResAlias)
    tcResAlias = "reservat"
ENDIF
IF tcResAlias = "reservat"
    lcResRooms = "resrooms"
    lcResRate = "resrate"
    lnReserid = reservat.rs_reserid
    lcStatus = reservat.rs_status
    ldArrDate = reservat.rs_arrdate
    ldDepDate = reservat.rs_depdate
    llGroup = NOT EMPTY(reservat.rs_group)
    lcRsRoomtype = reservat.rs_roomtyp
    lcRsRoomnum = reservat.rs_roomnum
    lnRsRooms = reservat.rs_rooms
    lcRsRatecode = CHRTRAN(reservat.rs_ratecod,"*!","")
    lnRsAdults = reservat.rs_adults
    lnRsChilds1 = reservat.rs_childs
    lnRsChilds2 = reservat.rs_childs2
    lnRsChilds3 = reservat.rs_childs3
    DO CASE
         CASE tcLabel = "MARKET"
              lcCode = reservat.rs_market
         CASE tcLabel = "SOURCE"
              lcCode = reservat.rs_source
         CASE tcLabel = "RATECOD"
         OTHERWISE
              RETURN
    ENDCASE
ELSE
    lcResRooms = "hresroom"
    lcResRate = "hresrate"
    lnReserid = histres.hr_reserid
    lcStatus = histres.hr_status
    ldArrDate = histres.hr_arrdate
    ldDepDate = histres.hr_depdate
    llGroup = NOT EMPTY(histres.hr_group)
    lcRsRoomtype = histres.hr_roomtyp
    lcRsRoomnum = histres.hr_roomnum
    lnRsRooms = histres.hr_rooms
    lcRsRatecode = CHRTRAN(histres.hr_ratecod,"*!","")
    lnRsAdults = histres.hr_adults
    lnRsChilds1 = histres.hr_childs
    lnRsChilds2 = histres.hr_childs2
    lnRsChilds3 = histres.hr_childs3
    DO CASE
         CASE tcLabel = "MARKET"
              lcCode = histres.hr_market
         CASE tcLabel = "SOURCE"
              lcCode = histres.hr_source
         CASE tcLabel = "RATECOD"
         OTHERWISE
              RETURN
    ENDCASE
ENDIF

ldDate = MAX(min1, ldArrDate)
DO WHILE ldDate <= MIN(max1, ldDepDate)
     llGetResState = (ldDate = MAX(min1, ldArrDate)) OR ISNULL(loResCurrent) OR ISNULL(loResNext) OR ;
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
     ELSE
          lcRatecode = lcRsRatecode
     ENDIF

     IF tcLabel = "RATECOD"
          lcCode = lcRatecode
     ENDIF

     IF SEEK(PADR(lcCode,3)+DTOC(ldDate,1),'PreProc','pp_code')
          IF ldDate < MIN(max1+1, ldDepDate)
               IF NOT llSharing
                    REPLACE pp_rms WITH pp_rms + lnRooms IN PreProc
               ENDIF
          ENDIF
     ENDIF
     ldDate = ldDate + 1
ENDDO

SELECT (lnSelect)
ENDPROC
*
DEFINE CLASS _bg03000 AS Session

PROCEDURE Init
Ini()
OpenFile()
PpCusorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER tcLabel, taPreProc
LOCAL lcReserTemp, lcPostTemp, lcPostchngTemp, lcHistresTemp, lcIdTemp, lcParamTemp, lcArchScripts

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     INNER JOIN (
     SELECT hr_reserid AS c_reserid FROM histres
          WHERE hr_reserid >= 1 AND hr_arrdate <= <<SqlCnvB(Max1)>> AND hr_depdate >= <<SqlCnvB(Min1)>>
     UNION
     SELECT hr_reserid FROM histres
          INNER JOIN histpost ON hp_origid = hr_reserid
          WHERE hp_reserid > 0 AND BETWEEN(hp_date, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
          GROUP BY hr_reserid
     ) hr ON hr_reserid = c_reserid;

SELECT histpost.* FROM histpost
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, Min1)
*
****************************************************************************************************

PpCusorInit(tcLabel)

* fake Post
lcPostTemp = Filetemp('DBF')
SELECT post
COPY TO (lcPostTemp) WITH CDX FOR ps_reserid > 0 AND BETWEEN(ps_date, Min1, Max1) AND ;
     NOT EMPTY(ps_artinum) AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split)
USE IN post
USE EXCLUSIVE (lcPostTemp) ALIAS post IN 0
ALTER TABLE post ADD COLUMN resrooms N(3) ADD COLUMN resrtgroup N(1) ADD COLUMN resstatus C(3) ADD COLUMN rescode C(10)

lcCodeField = "reservat.rs_" + tcLabel
SELECT post
SCAN FOR ps_origid >= 1 AND SEEK(ps_origid, "reservat", "tag1")
     REPLACE resrooms WITH 1 ;
             resrtgroup WITH DLookUp("RoomType", "rt_roomtyp = reservat.rs_roomtyp", "rt_group") ;
             resstatus WITH reservat.rs_status ;
             rescode WITH IIF(tcLabel = "RATECOD", IIF(EMPTY(post.ps_ratecod), '*****', post.ps_ratecod), IIF(EMPTY(&lcCodeField), '*****', &lcCodeField)) ;
             IN post
ENDSCAN
lcCodeField = "histres.hr_" + tcLabel
SELECT post
SCAN FOR EMPTY(rescode) AND ps_origid >= 1 AND SEEK(ps_origid, "histres", "tag1")
     REPLACE resrooms WITH 1 ;
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
     hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, 1, NVL(rt_group,0), NVL(hr_status,""), ;
     IIF(tcLabel = "RATECOD", IIF(EMPTY(hp_ratecod), '*****', hp_ratecod), NVL(&lcCodeField,'*****')) FROM histpost ;
     LEFT JOIN histres ON hr_reserid = hp_origid ;
     LEFT JOIN roomtype ON rt_roomtyp = hr_roomtyp ;
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, Min1, Max1) AND NOT SEEK(hp_postid, "post", "tag3") AND ;
     NOT EMPTY(hp_artinum) AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split)

REPLACE resrooms WITH 1, resrtgroup WITH 0, resstatus WITH 'OUT', rescode WITH '*****' FOR EMPTY(rescode) AND ps_origid < 1 IN post

* fake Reservat
lcReserTemp = Filetemp('DBF')
SELECT reservat
COPY TO (lcReserTemp) WITH CDX ALL FOR rs_arrdate <= Max1 AND rs_depdate >= Min1 AND NOT INLIST(rs_status, "CXL", "NS", "LST") AND ;
          (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef)
USE IN reservat
USE EXCLUSIVE (lcReserTemp) ALIAS reservat IN 0

* fake Histres
lcHistresTemp = Filetemp('DBF')
SELECT histres
COPY TO (lcHistresTemp) WITH CDX ALL FOR hr_reserid >= 1 AND hr_arrdate <= Max1 AND hr_depdate >= Min1 AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND ;
          (hr_status <> "TEN" OR param.pa_tentdef) AND NOT SEEK(hr_reserid, "reservat", "tag1")
USE IN histres
******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
USE (lcHistresTemp) IN 0 ALIAS histres EXCLUSIVE

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

BudgetOccupancyRevnueGenerate(tcLabel)
g_lFakeResAndPost = .T.
OccupancyRevnueGenerate(tcLabel)
RevnueGenerate()
g_lFakeResAndPost = .F.

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histpost")
*
****************************************************************************************************

USE IN reservat
FileDelete(lcReserTemp)
FileDelete(STRTRAN(lcReserTemp, '.DBF', '.CDX'))
FileDelete(STRTRAN(lcReserTemp, '.DBF', '.FPT'))
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
USE IN id
FileDelete(lcIdTemp)
USE IN param
FileDelete(lcParamTemp)

SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE