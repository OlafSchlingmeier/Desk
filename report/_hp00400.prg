PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00400
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp00400")
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
DEFINE CLASS _hp00400 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histpost,histres,billnum,paymetho,hdeposit,deposit,param", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp00400
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
          WHERE BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
          GROUP BY 1
     ) hp ON hr_reserid = hp_reserid;

SELECT histpost.* FROM histpost
     WHERE BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT hp_paynum,
		hp_date,
		hp_postid,
		hp_amount,
		hp_price,
		hp_billnum,
		CAST(NVL(bn_billnum,"") AS C(10)) AS bn_billnum,
		CAST(NVL(hr_roomnum,"") AS C(4)) AS hr_roomnum,
		CAST(NVL(hr_rsid,0) AS I) AS hr_rsid,
		CAST(NVL(hr_lname,"") AS C(30)) AS hr_lname, 
		CAST(NVL(hr_company,"") AS C(30)) AS hr_company, 
		CAST(NVL(hr_invid,0) AS N(8)) AS hr_invid, 
		CAST(NVL(hr_compid,0) AS N(8)) AS hr_compid,
		pm_paytyp,
		pm_user3,
		hp_descrip,
		hp_supplem,
		hp_time,
		hp_userid,
		hp_cashier,
		hp_units,
		hp_window,
		hp_cancel,
		IIF(pa_noclose AND min1 = max1, 1, 0) AS Dayamnt,
		hp_reserid,
		hp_addrid,
		CAST(NVL(NVL(hdp2.dp_receipt,dp2.dp_receipt),0) AS I) AS dp_receipt
	FROM histpost
	LEFT JOIN histres ON hr_reserid = hp_reserid
	LEFT JOIN billnum ON bn_billnum = hp_billnum
	LEFT JOIN paymetho ON hp_paynum = pm_paynum
	LEFT JOIN hdeposit hdp1 ON hdp1.dp_postid = hp_postid
	LEFT JOIN hdeposit hdp2 ON hdp2.dp_lineid = hdp1.dp_headid
	LEFT JOIN deposit dp1 ON dp1.dp_postid = hp_postid
	LEFT JOIN deposit dp2 ON dp2.dp_lineid = dp1.dp_headid
	INNER JOIN param ON 0 = 0
	WHERE BETWEEN(hp_date, min1, max1) AND BETWEEN(hp_cashier, min2, max2) AND BETWEEN(pm_paynum, min3, max3)
		AND IIF(NOT min4 OR min1 <> max1, hp_reserid <> -2, hp_reserid >= -2)
		AND ICASE(NOT pa_noclose AND min1 = max1, hp_reserid <> -1, pm_paytyp = 1 AND min1 = max1, hp_reserid >= -2, hp_reserid <> -1)
		AND (EMPTY(pm_buildng) OR EVL(RptBulding,"*") = "*" OR pm_buildng = RptBulding)
	GROUP BY hp_postid
	ORDER BY hp_paynum, hp_date, hp_postid
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*