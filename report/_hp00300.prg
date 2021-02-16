PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00300
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp00300")
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
DEFINE CLASS _hp00300 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost,address,article", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp00300
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
          WHERE hp_reserid > -2 AND BETWEEN(hp_date, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
          GROUP BY 1
     ) hp ON hr_reserid = hp_reserid;

SELECT histpost.* FROM histpost
     WHERE hp_reserid > -2 AND BETWEEN(hp_date, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, Min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT hp_artinum,
		hp_date,
		hp_postid,
		hp_amount,
		CAST(NVL(hr_roomnum,"") AS C(4)) AS hr_roomnum,
		CAST(NVL(hr_lname,"") AS C(30)) AS hr_lname,
		hp_price,
		hp_units,
		hp_supplem,
		hp_time,
		hp_userid,
		hp_cashier,
		hp_cancel,
		hp_descrip,
		hp_addrid,
		hp_reserid,
		ad_lname, ad_fname
	FROM histpost
	INNER JOIN article ON ar_artinum = hp_artinum
	LEFT JOIN histres ON hr_reserid = hp_reserid
	LEFT JOIN address on ad_addrid = hr_addrid
	WHERE BETWEEN(hp_date, Min1, Max1)
		AND BETWEEN(hp_artinum, min2, max2)
		AND IIF(min3, (EMPTY(hp_ratecod) OR hp_split), !hp_split)
		AND hp_artinum > 0
		AND hp_reserid > -2
		AND (EMPTY(ar_buildng) OR EVL(RptBulding,"*") = "*" OR ar_buildng = RptBulding)
	ORDER BY hp_artinum, hp_date, hp_postid
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*