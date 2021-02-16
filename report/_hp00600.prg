PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00600
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp00600")
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
DEFINE CLASS _hp00600 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost,ratecode,article", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp00600
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
     INNER JOIN (
     SELECT hp_reserid FROM histpost
          WHERE hp_date = <<SqlCnvB(Min1)>>
          GROUP BY 1
     ) hp ON hr_reserid = hp_reserid;

SELECT histpost.* FROM histpost
     WHERE hp_date = <<SqlCnvB(Min1)>>
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT hr_roomnum,
		hr_roomtyp,
		hr_lname,
		hr_reserid,
		hp_setid,
		hp_reserid,
		hp_postid,
		hp_supplem,
		hp_ratecod,
		hp_artinum, 
		hp_amount,
		hp_price, 
		hp_units,
		hp_date, 
		hp_time, 
		hp_userid, 
		hp_cashier, 
		hp_cancel,
		hp_split,
		rc_lang1, rc_lang2, rc_lang3, rc_lang4, rc_lang5, rc_lang6, rc_lang7, rc_lang8, rc_lang9
	FROM histpost, histres, ratecode, article
	WHERE hp_date = Min1
		AND hr_reserid = hp_reserid
		AND hp_ratecod = rc_ratecod + rc_roomtyp + dtos(rc_fromdat) + rc_season
		AND !hp_cancel
		AND ar_artinum = hp_artinum
		AND (EMPTY(ar_buildng) OR EVL(RptBulding,"*") = "*" OR ar_buildng = RptBulding)
	ORDER BY hr_roomnum, hr_reserid, hp_split, hp_artinum
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*