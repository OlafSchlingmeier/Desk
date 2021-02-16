PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.50"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hrm0500
LPARAMETERS tcType
LOCAL loSession
LOCAL ARRAY laPreProc(1)
PRIVATE pcAddressFld

WAIT WINDOW NOWAIT "Preprocessing..."

IF VARTYPE(tcType) # "C"
     tcType = "A"
ENDIF
DO CASE
     CASE tcType == "C"               && C = Company
          pcAddressFld = "hr_compid"
     OTHERWISE && tcType == "A"       && A = Agent
          pcAddressFld = "hr_agentid"
ENDCASE

PpCursorCreate()

SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
SELECT curHotel
SCAN
     WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
     DIMENSION laPreProc(1)
     loSession = CREATEOBJECT("_hrm0500", curHotel.ho_hotcode, curHotel.ho_path)
     loSession.DoPreproc(@laPreProc)
     RELEASE loSession

     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
          REPLACE ho_hotcode WITH curHotel.ho_hotcode, ho_descrip WITH curHotel.ho_descrip FOR EMPTY(ho_hotcode) IN PreProc
     ENDIF
ENDSCAN
PpCursorGroup()
DClose("curHotel")

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS _hrm0500 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,address,roomtype,rtypedef,room", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _hrm0500
          ENDTEXT
     ELSE
          PpCursorCreate()
     ENDIF
ENDPROC
*
PROCEDURE DoPreproc
     LPARAMETERS taPreProc

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          pcAddressFld = <<SqlCnv(pcAddressFld)>>
          DO PpDo IN _hrm0500
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          PpDo()
     ENDIF

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
SELECT CAST("" AS C(100)) AS ho_descrip, CAST("" AS C(10)) AS ho_hotcode, ad_company, ad_departm, ad_zip, ad_city, ;
     hr_lname, hr_arrdate, hr_depdate, hr_rooms, hr_roomtyp, hr_roomnum, rd_roomtyp, rm_rmname, hr_ratecod, hr_rate, ;
     hr_status, hr_adults, hr_childs, hr_childs2, hr_childs3, hr_share, hr_group, hr_reserid, rt_group ;
     FROM histres, address, rtypedef, roomtype, room ;
     WHERE 0=1 ;
     INTO CURSOR PreProc READWRITE
ENDPROC
*
PROCEDURE PpCursorGroup
SELECT * FROM PreProc INTO CURSOR curPreProc READWRITE
BLANK FIELDS ho_descrip, ho_hotcode ALL IN curPreProc

SELECT PreProc
APPEND FROM DBF("curPreProc")

DClose("curPreProc")
ENDPROC
*
PROCEDURE PpDo
LOCAL lcArchScripts

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE BETWEEN(hr_depdate, <<SqlCnvB(Min2)>>, <<SqlCnvB(Max2)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres", lcArchScripts, Min2)
*
****************************************************************************************************

SELECT CAST("" AS C(100)) AS ho_descrip, CAST("" AS C(10)) AS ho_hotcode, ad_company, ad_departm, ad_zip, ad_city, ;
     hr_lname, hr_arrdate, hr_depdate, hr_rooms, hr_roomtyp, hr_roomnum, rd_roomtyp, ;
     CAST(NVL(rm_rmname, hr_roomnum) AS C(10)) AS rm_rmname, CAST(STRTRAN(hr_ratecod, "*") AS C(10)) AS hr_ratecod, hr_rate, ;
     hr_status, hr_adults, hr_childs, hr_childs2, hr_childs3, hr_share, hr_group, hr_reserid, rt_group ;
     FROM histres ;
     INNER JOIN address ON &pcAddressFld = ad_addrid ;
     INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp ;
     INNER JOIN rtypedef ON rd_rdid = rt_rdid ;
     LEFT JOIN room ON hr_roomnum = rm_roomnum ;
     WHERE ad_adid = Min1 AND BETWEEN(hr_depdate, Min2, Max2) AND rt_group <> 3 ;
     ORDER BY hr_ratecod, hr_arrdate, hr_lname ;
     INTO CURSOR curReservat

SELECT PreProc
APPEND FROM DBF("curReservat")
DClose("curReservat")

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
ENDPROC
*