PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _mgm0100
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
          loSession = CREATEOBJECT("_mgm0100", curHotel.ho_hotcode, curHotel.ho_path)
          loSession.DoPreproc(@laPreProc)
          RELEASE loSession

          IF ALEN(laPreProc) > 1
               INSERT INTO PreProc FROM ARRAY laPreProc
          ENDIF
     ENDSCAN
	PpCursorGroup()
	DClose("curHotel")
ENDIF

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS _mgm0100 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("manager", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _mgm0100
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
          DO PpDo IN _mgm0100
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
SELECT * FROM Manager WHERE 0=1 INTO CURSOR PreProc READWRITE
ENDPROC
*
PROCEDURE PpCursorGroup
LOCAL i, lcSelectStatement
LOCAL ARRAY laPpFields(1)

lcSelectStatement = ""
FOR i = 1 TO AFIELDS(laPpFields,"PreProc")
     lcSelectStatement = lcSelectStatement + IIF(EMPTY(lcSelectStatement), "", ",") + ;
          IIF(INLIST(laPpFields(i,2),"B","F","I","N"), "SUM(" + LOWER(laPpFields(i,1)) + ") AS " + LOWER(laPpFields(i,1)), LOWER(laPpFields(i,1)))
NEXT

SELECT &lcSelectStatement FROM PreProc ;
     GROUP BY mg_date ;
     INTO CURSOR PreProc
ENDPROC
*
PROCEDURE PpDo
LOCAL lcWhere

DO CASE
     CASE EMPTY(max1)
          lcWhere = StrToSql("DTOS(mg_date) = %s1", DTOS(min1))
     CASE min1 = max1
          lcWhere = StrToSql("DTOS(mg_date) = %s1 OR DTOS(mg_date) = %s2", DTOS(GetRelDate(min1,"-1Y")), DTOS(max1))
     OTHERWISE
          lcWhere = StrToSql("DTOS(mg_date) = %s1 OR DTOS(mg_date) = %s2", DTOS(min1), DTOS(max1))
ENDCASE

SELECT * FROM Manager WHERE &lcWhere INTO CURSOR curManager

SELECT PreProc
APPEND FROM DBF("curManager")
DClose("curManager")
ENDPROC
*