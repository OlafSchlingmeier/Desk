PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00502
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp00502")
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
DEFINE CLASS _hp00502 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost,roomtype", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp00502
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
          WHERE hp_reserid >= 1 AND hp_date <= <<SqlCnvB(min1)>>
          GROUP BY 1
     ) hp ON hr_reserid = hp_reserid
     WHERE hr_depdate >= <<SqlCnvB(min1)>>;

SELECT histpost.* FROM histpost
     INNER JOIN histres ON hr_reserid = hp_reserid AND hr_depdate >= <<SqlCnvB(min1)>>
     WHERE hp_reserid >= 1 AND hp_date <= <<SqlCnvB(min1)>>
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT  hr_status as rs_status,
	0 as rm_rpseq,
	hr_roomnum as rs_roomnum,
	hr_arrdate as rs_arrdate, 
	hr_depdate as rs_depdate, 
	hr_rooms as rs_rooms, 
	hr_adults as rs_adults,
	hr_childs as rs_childs, hr_childs2 as rs_childs2, hr_childs3 as rs_childs3,
	hr_share as Rs_Share, 
	hr_roomtyp as rs_roomtyp, 
	hr_ratecod as rs_ratecod, 
	hr_rate as rs_rate, 
	hr_company as rs_company, 
	hr_reserid as rs_reserid,
	hr_note as rs_note, 
	hr_group as rs_group,
	hr_lname as rs_lname,
	IIF(EMPTY(RptBulding), "", rt_buildng) AS rt_buildng,
	sum(hp_amount) as Balance
FROM histres, histpost, roomtype
WHERE 	hr_depdate >= min1 
AND	hr_reserid = hp_reserid
AND	hp_reserid>=1
AND	hp_date<=min1
AND	!hp_cancel
AND	!hp_split
AND hr_roomtyp = rt_roomtyp
AND (EMPTY(rt_buildng) OR EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding)
Group by 16
ORDER BY 20,1,2,3
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*