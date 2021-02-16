PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.02"
RETURN tcVersion
ENDPROC
*
PROCEDURE _rsm0200
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

PpCursorCreate()

IF CheckExeVersion("9.10.349")
     SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
     SELECT curHotel
     SCAN
          WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
          DIMENSION laPreProc(1)
          loSession = CREATEOBJECT("_rsm0200", curHotel.ho_hotcode, curHotel.ho_path)
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
DEFINE CLASS _rsm0200 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("reservat,roomtype,address,apartner", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _rsm0200
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
          DO PpDo IN _rsm0200
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
SELECT CAST("" AS C(100)) AS ho_descrip, CAST("" AS C(10)) AS ho_hotcode, rt_group, ;
     ad_company AS company, ad_city, ad_member, ad_lname, ad_fname, ad_title, CAST("" AS C(50)) AS sharename, ;
     rs_reserid, rs_arrdate, rs_arrtime, rs_depdate, rs_rooms, rs_roomtyp, rs_roomnum, rs_share, rs_rmname,;
     rs_ratecod, rs_rate, rs_paymeth, rs_status, rs_adults, rs_childs, rs_childs2, rs_childs3, ;
     rs_group, rs_agent, rs_saddrid, rs_sname, rs_created, rs_updated, rs_userid, rs_cxldate ;
     FROM reservat, roomtype, address ;
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
SELECT "" AS ho_descrip, "" AS ho_hotcode, rt_group, ;
     b.ad_company AS company, a.ad_city, a.ad_member, ;
     ICASE(NOT EMPTY(rs_rgid), rs_lname, rs_compid = rs_addrid AND rs_apid > 0, ap_lname, a.ad_lname) AS ad_lname, ;
     ICASE(NOT EMPTY(rs_rgid), rs_fname, rs_compid = rs_addrid AND rs_apid > 0, ap_fname, a.ad_fname) AS ad_fname, ;
     ICASE(NOT EMPTY(rs_rgid), rs_title, rs_compid = rs_addrid AND rs_apid > 0, ap_title, a.ad_title) AS ad_title, ;
     CAST(IIF(NOT EMPTY(rs_saddrid), ALLTRIM(TRIM(c.ad_lname) + " " + TRIM(c.ad_fname) + ", " + TRIM(c.ad_title)), ALLTRIM(rs_sname)) AS C(50)) AS sharename, ;
     rs_reserid, rs_arrdate, rs_arrtime, rs_depdate, rs_rooms, rs_roomtyp, rs_roomnum, rs_share, rs_rmname,;
     rs_ratecod, rs_rate, rs_paymeth, rs_status, rs_adults, rs_childs, rs_childs2, rs_childs3, ;
     rs_group, rs_agent, rs_saddrid, rs_sname, rs_created, rs_updated, rs_userid, rs_cxldate ;
     FROM reservat ;
     INNER JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
     INNER JOIN address a ON a.ad_addrid = IIF(EMPTY(rs_addrid), rs_compid, rs_addrid) ;
     INNER JOIN address b ON b.ad_addrid = IIF(EMPTY(rs_compid), rs_addrid, rs_compid) ;
     INNER JOIN address c ON c.ad_addrid = ICASE(NOT EMPTY(rs_saddrid), rs_saddrid, EMPTY(rs_addrid), rs_compid, rs_addrid) ;
     INNER JOIN apartner ON ap_apid = IIF(EMPTY(rs_apid), -9999, rs_apid) ;
     WHERE BETWEEN(rs_created, min1, max1) AND NOT INLIST(rs_status, 'CXL', 'NS') AND rt_group <> 2 ;
     INTO CURSOR curReservat

SELECT PreProc
APPEND FROM DBF("curReservat")
DClose("curReservat")
ENDPROC
*