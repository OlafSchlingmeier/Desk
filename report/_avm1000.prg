PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _avm1000
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
          loSession = CREATEOBJECT("_avm1000", curHotel.ho_hotcode, curHotel.ho_path)
          loSession.DoPreproc(@laPreProc)
          RELEASE loSession

          IF ALEN(laPreProc) > 1
               INSERT INTO PreProc FROM ARRAY laPreProc
          ENDIF
     ENDSCAN
     DClose("curHotel")
ENDIF

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS _avm1000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("availab,manager,param", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _avm1000
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
     DO PpDo IN _avm1000
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
SELECT av_date, av_roomtyp, av_definit, av_avail, av_option, av_allott, av_altall, av_pick FROM availab WHERE 0=1 INTO CURSOR PreProc READWRITE
ENDPROC
*
PROCEDURE PpDo
SELECT av_date, [    ] AS av_roomtyp, SUM(av_definit) AS av_definit, SUM(av_avail) AS av_avail, SUM(av_option) AS av_option, ;
     SUM(av_allott) AS av_allott, SUM(av_altall) AS av_altall, SUM(av_pick) AS av_pick FROM availab, param ;
     WHERE BETWEEN(av_date, min1, max1) AND av_date >= param.pa_sysdate ;
     GROUP BY 1 ;
     UNION ALL ;
     SELECT mg_date, [MANA], mg_roomocc, mg_roomavl - mg_roomooo, 0000.00, 0000, 0000, 0000 FROM manager ;
     WHERE BETWEEN(mg_date, min1, max1) ;
     INTO CURSOR curManager

SELECT PreProc
APPEND FROM DBF("curManager")
DClose("curManager")
ENDPROC
*