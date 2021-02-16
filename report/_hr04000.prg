PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "7.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hr04000
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hr04000")
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
DEFINE CLASS _hr04000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,hresext,hresrate,hresroom,roomtype,resrate", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hr04000
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
PROCEDURE PpDo
LOCAL oldselect, lcArchScripts

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE BETWEEN(hr_arrdate, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>);

SELECT hresext.* FROM hresext
     INNER JOIN histres ON hr_reserid = rs_reserid
     WHERE BETWEEN(hr_arrdate, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,hresext", lcArchScripts, min1)
*
****************************************************************************************************

oldselect = SELECT()
create CURSOR preproc (pp_arrdate D (8), ppdate D (8), pp_ratecod C (10), pp_rrrcod C (10), pp_reserid N (12, 3), pp_depdate D (8), pp_rooms N (3), ;
     pp_adults N (3), pp_childs N (3), pp_childs2 N (1), pp_childs3 N (1), pp_roomnum C (4), pp_share C (2), pp_roomtyp C (4), pp_rate N (8, 3), ;
     pp_agent C (30), pp_saddrid N (8), pp_sname C (30), pp_note M (4), pp_status C (3), pp_arrtime C (5), pp_group C (25), pp_paymeth C (4), ;
     pp_addrid N (8), pp_compid N (8), pp_invid N (8), pp_apid N (8), pp_ratestat C (3), pp_created D(8), pp_creatus C(10), pp_rtgroup N(1))

SELECT histres.*, hresext.*, roomtype.rt_group, ;
     NVL(NVL(r.rr_date, h.rr_date),{}) AS rr_date, CAST(NVL(NVL(r.rr_ratecod, h.rr_ratecod),'') AS c(23)) AS rr_ratecod, NVL(NVL(r.rr_adults, h.rr_adults),000) AS rr_adults, ;
     NVL(NVL(r.rr_childs, h.rr_childs),000) AS rr_childs, NVL(NVL(r.rr_childs2, h.rr_childs2),0) AS rr_childs2, NVL(NVL(r.rr_childs3, h.rr_childs3),0) AS rr_childs3, ;
     NVL(NVL(r.rr_raterc, h.rr_raterc),0.00) AS rr_raterc, NVL(NVL(r.rr_status, h.rr_status),'   ') AS rr_status ;
     FROM histres ;
     INNER JOIN hresext ON hr_reserid = rs_reserid ;
     INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp ;
     LEFT JOIN resrate r ON hr_reserid = r.rr_reserid ;
     LEFT JOIN hresrate h ON hr_reserid = h.rr_reserid ;
     WHERE BETWEEN(hr_arrdate, min1, max1) AND !INLIST(hr_status, 'CXL', 'NS') INTO CURSOR restmp

select restmp
scan
     insert INTO preproc (pp_arrdate, ppdate, pp_ratecod, pp_rrrcod, pp_reserid, pp_depdate, pp_rooms, pp_roomnum, pp_share, ;
     pp_roomtyp, pp_agent, pp_saddrid, pp_sname, pp_note, pp_status, pp_arrtime, pp_group, pp_paymeth, pp_addrid, pp_compid, ;
     pp_invid, pp_apid, pp_adults, pp_childs, pp_childs2, pp_childs3, pp_rate, pp_ratestat, pp_created, pp_creatus, pp_rtgroup) VALUES ;
     (restmp.hr_arrdate, restmp.rr_date, STRTRAN(restmp.hr_ratecod, "*", ""), SUBSTR(restmp.rr_ratecod, 1, 10), restmp.hr_reserid, ;
     restmp.hr_depdate, restmp.hr_rooms, restmp.hr_roomnum, restmp.hr_share, restmp.hr_roomtyp, restmp.hr_agent, restmp.rs_saddrid, ;
     restmp.rs_sname, restmp.hr_note, restmp.hr_status, restmp.hr_arrtime, restmp.hr_group, restmp.hr_paymeth, restmp.hr_addrid, ;
     restmp.hr_compid, restmp.hr_invid, restmp.hr_apid, restmp.rr_adults, restmp.rr_childs, restmp.rr_childs2, restmp.rr_childs3, ;
     restmp.rr_raterc, restmp.rr_status, restmp.hr_created, restmp.hr_creatus, restmp.rt_group)
endscan
select preproc
goto TOP
do WHILE EOF() = .F.
     select hresroom
     set ORDER TO 2
     seek STR(preproc.pp_reserid, 12, 3) + DTOS(preproc.ppdate) 
     if FOUND()
          replace preproc.pp_roomnum WITH ri_roomnum
          replace preproc.pp_roomtyp WITH ri_roomtyp
     endif
     select preproc
     skip
enddo
select = oldselect

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,hresext")
*
****************************************************************************************************
ENDPROC
*