PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00200
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp00200")
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
DEFINE CLASS _hp00200 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histpost,paymetho", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp00200
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
SELECT histpost.* FROM histpost
     WHERE BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histpost", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT hp_paynum, 
	sum(-hp_amount) AS amnt, 
	sum(hp_units) as curramnt,
	count(hp_amount) as Menge,
	pm_paytyp,
	Iif(hp_reserid=0.2, 2, Iif(hp_reserid=0.3, 3, Iif(hp_reserid=0.4, 4, 1))) as CASH
FROM histpost, paymetho
WHERE hp_date >= min1
	AND hp_date <= max1
	AND !hp_cancel
	AND pm_paynum = hp_paynum
	AND (EMPTY(pm_buildng) OR EVL(RptBulding,"*") = "*" OR pm_buildng = RptBulding)
	AND !Inlist(hp_reserid, -2, -1)
GROUP BY pm_paytyp, hp_paynum, 6
ORDER BY pm_paytyp, hp_paynum
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histpost")
*
****************************************************************************************************
ENDPROC
*