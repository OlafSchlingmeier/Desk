PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00150
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp00150")
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
DEFINE CLASS _hp00150 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histpost,article", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp00150
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
SELECT hp_artinum, 
	sum(hp_units) as Units,
	Sum(hp_amount) AS amount, 
	Sum(hp_vat1) AS Vat1, 
	Sum(hp_vat2) AS Vat2, 
	Sum(hp_vat3) AS Vat3, 
	Sum(hp_vat4) AS Vat4, 
	Sum(hp_vat5) AS Vat5, 
	Sum(hp_vat6) AS Vat6, 
	Sum(hp_vat7) AS Vat7, 
	Sum(hp_vat8) AS Vat8, 
	Sum(hp_vat9) AS Vat9, 
	ar_artityp,
	ar_main,
	ar_sub
FROM histpost, article
WHERE 	hp_date >= min1
AND	hp_date <= max1
AND	(Empty(hp_ratecod) .or. hp_split)
AND	!hp_cancel
AND	ar_artinum = hp_artinum
AND (EMPTY(ar_buildng) OR EVL(RptBulding,"*") = "*" OR ar_buildng = RptBulding)
AND	hp_reserid >= -1
AND	hp_amount <>0
GROUP BY ar_main, ar_sub, ar_artinum
ORDER BY ar_main, ar_sub, ar_artinum
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histpost")
*
****************************************************************************************************
ENDPROC
*