PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.01"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hr00100
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hr00100")
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
DEFINE CLASS _hr00100 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,roomtype,address,apartner", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hr00100
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
LOCAL lcSQL, lcArchScripts

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE BETWEEN(hr_cxldate, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT hr_arrdate, hr_depdate, hr_rooms, hr_adults, hr_childs, hr_childs2, hr_childs3, 
       hr_roomnum, hr_roomtyp, hr_ratecod, hr_rate, hr_share, 
       b.ad_company as company, hr_agent, hr_note, hr_status, hr_arrtime, hr_group, hr_changes,
       IIF(hr_compid = hr_addrid and hr_apid > 0, ap_lname, a.ad_lname) AS ad_lname, 
       IIF(hr_compid = hr_addrid and hr_apid > 0, ap_fname, a.ad_fname) AS ad_fname, 
       IIF(hr_compid = hr_addrid and hr_apid > 0, ap_title, a.ad_title) AS ad_title, 
       a.ad_city, a.ad_member,
       rt_group, hr_cxldate, hr_cxlnr, hr_updated, CAST(NVL(rs_cxlstat, '') AS Char(3)) AS rs_cxlstat
     FROM histres
     INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp 
     INNER JOIN address a ON IIF(EMPTY(hr_addrid), hr_compid, hr_addrid) = a.ad_addrid 
     INNER JOIN address b ON IIF(NOT EMPTY(hr_compid), hr_compid, hr_addrid) = b.ad_addrid 
     LEFT JOIN apartner ON hr_apid = ap_apid 
     LEFT JOIN hresext ON hr_rsid = rs_rsid 
     WHERE INLIST(hr_status, 'CXL', 'NS') AND rt_group <> 2 
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
ENDPROC
*