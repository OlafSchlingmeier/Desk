PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.10"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hpm0150
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

PpCursorCreate()

SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
SELECT curHotel
SCAN
     WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
     DIMENSION laPreProc(1)
     loSession = CREATEOBJECT("_hpm0150", curHotel.ho_hotcode, curHotel.ho_path)
     loSession.DoPreproc(@laPreProc)
     RELEASE loSession

     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
     ENDIF
ENDSCAN
DClose("curHotel")

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS _hpm0150 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("article,histpost", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _hpm0150
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
          DO PpDo IN _hpm0150
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
SELECT hp_artinum, hp_units, hp_amount, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, ar_artityp, ar_main, ar_sub ;
     FROM histpost, article ;
     WHERE 0=1 ;
     INTO CURSOR PreProc READWRITE
ENDPROC
*
PROCEDURE PpDo
LOCAL lcArchScripts

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histpost.* FROM histpost
     WHERE hp_reserid >= -1 AND BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histpost", lcArchScripts, min1)
*
****************************************************************************************************

SELECT hp_artinum, hp_units, hp_amount, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, ;
     hp_vat7, hp_vat8, hp_vat9, ar_artityp, ar_main, ar_sub FROM histpost, article ;
     WHERE ar_artinum = hp_artinum AND BETWEEN(hp_date, min1, max1) AND hp_reserid >= -1 AND ;
          hp_amount <> 0 AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
     ORDER BY ar_main, ar_sub, ar_artinum ;
     INTO CURSOR curPost

SELECT PreProc
APPEND FROM DBF("curPost")
DClose("curPost")

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histpost")
*
****************************************************************************************************
ENDPROC
*