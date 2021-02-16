PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _rsm1000
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
          pcAddressFld = "rs_compid"
     OTHERWISE && tcType == "A"       && A = Agent
          pcAddressFld = "rs_agentid"
ENDCASE

PpCursorCreate()

IF CheckExeVersion("9.10.349")
     SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
     SELECT curHotel
     SCAN
          WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
          DIMENSION laPreProc(1)
          loSession = CREATEOBJECT("_rsm1000", curHotel.ho_hotcode, curHotel.ho_path)
          loSession.DoPreproc(@laPreProc)
          RELEASE loSession

          IF ALEN(laPreProc) > 1
               INSERT INTO PreProc FROM ARRAY laPreProc
               REPLACE ho_hotcode WITH curHotel.ho_hotcode, ho_descrip WITH curHotel.ho_descrip FOR EMPTY(ho_hotcode) IN PreProc
          ENDIF
     ENDSCAN
     PpCursorGroup()
     DClose("curHotel")
ENDIF

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS _rsm1000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("param,reservat,address,roomtype,rtypedef,room", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _rsm1000
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
          DO PpDo IN _rsm1000
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
     rs_lname, rs_arrdate, rs_depdate, rs_rooms, rs_roomtyp, rs_roomnum, rd_roomtyp, rm_rmname, ;
     rs_ratecod, rs_rate, rs_status, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_share, rs_group ;
     FROM reservat, address, rtypedef, room ;
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
SELECT "" AS ho_descrip, "" AS ho_hotcode, ad_company, ad_departm, ad_zip, ad_city, ;
     rs_lname, rs_arrdate, rs_depdate, rs_rooms, rs_roomtyp, rs_roomnum, rd_roomtyp, CAST(NVL(rm_rmname, rs_roomnum) AS C(10)) AS rm_rmname, ;
     rs_ratecod, rs_rate, rs_status, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_share, rs_group ;
     FROM reservat ;
     INNER JOIN address ON &pcAddressFld = ad_addrid ;
     INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp ;
     INNER JOIN rtypedef ON rd_rdid = rt_rdid ;
     LEFT JOIN room ON rs_roomnum = rm_roomnum ;
     WHERE ad_adid = Min1 AND rs_arrdate >= g_SysDate AND NOT INLIST(rs_status, "NS", "CXL") AND rt_group <> 3 ;
     ORDER BY rs_arrdate, rs_lname ;
     INTO CURSOR curReservat

SELECT PreProc
APPEND FROM DBF("curReservat")
DClose("curReservat")
ENDPROC
*