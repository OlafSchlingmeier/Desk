PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _mg00100
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_mg00100")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS _mg00100 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT(IIF(EMPTY(RptBulding), "Manager", "MngBuild"), tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _mg00100
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
          DO PpDo IN _mg00100
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
IF EMPTY(RptBulding)
     SELECT *, "   "      AS Building, mg_date AS Date FROM Manager  WHERE 0=1 INTO CURSOR PreProc READWRITE
ELSE
     SELECT *, mg_buildng AS Building, mg_date AS Date FROM MngBuild WHERE 0=1 INTO CURSOR PreProc READWRITE
ENDIF
ENDPROC
*
PROCEDURE PpDo
DO CASE
     CASE EMPTY(RptBulding)
          SELECT *, "   " AS Building, mg_date AS Date FROM Manager ;
               WHERE INLIST(DTOS(mg_date), DTOS(IIF(Min1=EVL(Max1,{}),GetRelDate(Min1,"-1Y"),Min1)), DTOS(EVL(Max1,Min1))) ;
               INTO CURSOR curManager
     CASE RptBulding = "*"
          SELECT *, mg_buildng AS Building, mg_date AS Date FROM MngBuild ;
               WHERE INLIST(DTOS(mg_date), DTOS(IIF(Min1=EVL(Max1,{}),GetRelDate(Min1,"-1Y"),Min1)), DTOS(EVL(Max1,Min1))) ;
               INTO CURSOR curManager
     OTHERWISE
          SELECT *, mg_buildng AS Building, mg_date AS Date FROM MngBuild ;
               WHERE INLIST(mg_mngbid, DTOS(IIF(Min1=EVL(Max1,{}),GetRelDate(Min1,"-1Y"),Min1))+RptBulding, DTOS(EVL(Max1,Min1))+RptBulding) ;
               INTO CURSOR curManager
ENDCASE

SELECT PreProc
APPEND FROM DBF("curManager")
DClose("curManager")
ENDPROC
*