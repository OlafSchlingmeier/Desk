PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE fc07001
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("fc07001")
loSession.DoPreproc(@laPreProc, @laPPStruct)
RELEASE loSession

IF ALEN(laPPStruct) > 1
     CREATE CURSOR PreProc FROM ARRAY laPPStruct
     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
     ENDIF
ENDIF

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS fc07001 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("reservat,resrooms,resrate,histres,hresroom,hresrate,roomtype,param", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN fc07001
          ENDTEXT
     ELSE
          PpCursorCreate()
     ENDIF
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN fc07001
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          PpDo()
     ENDIF

     IF USED("PreProc")
          AFIELDS(taPPStruct, "PreProc")
          IF RECCOUNT("PreProc") > 0
               SELECT * FROM PreProc INTO ARRAY taPreProc
          ENDIF
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
CREATE CURSOR PreProc (pp_date D(8), pp_codeid N(3), pp_groupid N(8), pp_group C(25), pp_prs N(8))
INDEX ON PADL(pp_groupid,8)+DTOC(pp_date,1) TAG pp_group
ENDPROC
*
PROCEDURE PpDo
LOCAL lcArchScripts, lcurDates, lnPersons
PRIVATE pdStartDate, pdEndDate

pdStartDate = MonthStart(min1)
pdEndDate = DATE(YEAR(min1),MONTH(min1),LastDay(min1))

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM hresrate
     INNER JOIN histres ON hr_reserid = rr_reserid
     WHERE BETWEEN(rr_date, <<SqlCnvB(pdStartDate)>>, <<SqlCnvB(pdEndDate)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres", lcArchScripts, pdStartDate)
*
****************************************************************************************************

lcurDates = MakeDatesCursor(pdStartDate, pdEndDate)

SELECT rs_groupid, rs_group, rs_arrdate, rs_depdate, rr_rrid, rr_date, rr_adults, rr_childs, rr_childs2, rr_childs3 FROM resrate ;
     INNER JOIN reservat ON rs_reserid = rr_reserid ;
     LEFT JOIN resrooms ON ri_reserid = rr_reserid AND BETWEEN(rr_date, ri_date, ri_todate) ;
     LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
     WHERE BETWEEN(rr_date, pdStartDate, pdEndDate) AND (NOT min3 OR INLIST(rt_group,1,4)) AND rs_groupid > 0 AND ;
          NOT INLIST(rs_status, "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) ;
UNION ;
SELECT hr_groupid, hr_group, hr_arrdate, hr_depdate, rr_rrid, rr_date, rr_adults, rr_childs, rr_childs2, rr_childs3 FROM hresrate ;
     INNER JOIN histres ON hr_reserid = rr_reserid ;
     LEFT JOIN hresroom ON ri_reserid = rr_reserid AND BETWEEN(rr_date, ri_date, ri_todate) ;
     LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
     WHERE BETWEEN(rr_date, pdStartDate, pdEndDate) AND (NOT min3 OR INLIST(rt_group,1,4)) AND hr_groupid > 0 AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND (hr_status <> "TEN" OR param.pa_tentdef) ;
     INTO CURSOR curReservat

SELECT 000 AS pp_codeid, rs_groupid, rs_group FROM curReservat GROUP BY 2,3 INTO CURSOR curGroups READWRITE
REPLACE pp_codeid WITH RECNO() ALL
INSERT INTO PreProc (pp_codeid, pp_groupid, pp_group, pp_date) SELECT pp_codeid, rs_groupid, rs_group, c_date FROM &lcurDates, curGroups

SELECT curReservat
SCAN
     IF SEEK(PADL(rs_groupid,8)+DTOC(rr_date,1),'PreProc','pp_group')
          lnPersons = rr_adults + rr_childs + rr_childs2 + rr_childs3
          REPLACE pp_prs WITH pp_prs + lnPersons IN PreProc
     ENDIF
ENDSCAN

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************

DClose(lcurDates)
DClose("curGroups")
DClose("curReservat")
ENDPROC
*