PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00700
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp00700")
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
DEFINE CLASS _hp00700 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp00700
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
          WHERE hp_reserid > -2 AND hp_reserid <> hp_origid AND BETWEEN(hp_date, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
          GROUP BY 1
     UNION
     SELECT hp_origid FROM histpost
          WHERE hp_reserid > -2 AND hp_reserid <> hp_origid AND BETWEEN(hp_date, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
          GROUP BY 1
     ) hp ON hr_reserid = hp_reserid;

SELECT histpost.* FROM histpost
     WHERE hp_reserid > -2 AND hp_reserid <> hp_origid AND BETWEEN(hp_date, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, Min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT	org.hr_roomnum as orgroomnum,
	new.hr_roomnum as roomnum,
	proper(org.hr_lname) as orglname, 
	proper(new.hr_lname) as lname,
	hp_reserid,
	hp_postid,
	hp_artinum,
	hp_paynum, 
	hp_amount,
	hp_price, 
	hp_units,
	hp_supplem, 
	hp_date, 
	hp_time, 
	hp_userid, 
	hp_cashier, 
	hp_cancel
FROM histpost, histres org, histres new
WHERE  between(hp_date, Min1, Max1)
AND	between(hp_artinum, min2, max2)
AND 	org.hr_reserid = hp_origid
AND 	new.hr_reserid = hp_reserid
AND 	hp_reserid <> hp_origid
AND 	!hp_split
AND 	hp_reserid > -2
ORDER BY orgroomnum, hp_postid
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*