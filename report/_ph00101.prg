PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _ph00101
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_ph00101")
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
DEFINE CLASS _ph00101 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost,article,param", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _ph00101
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
     SELECT hr_reserid AS c_reserid FROM histres
          INNER JOIN histpost ON hp_reserid = hr_reserid
          WHERE hp_reserid > -2 AND BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
          GROUP BY hr_reserid
     ) hr ON hr_reserid = c_reserid;

SELECT histpost.* FROM histpost
     WHERE hp_reserid > -2 AND BETWEEN(hp_date, <<SqlCnvB(min1)>>, <<SqlCnvB(Max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
SELECT 	hp_amount AS Amount,
	hr_roomnum, 
	hr_lname, 
	hp_postid,
	hp_artinum, 
	hp_price, 
	hp_units,
	Ar_Lang1, 
	Ar_Lang2, 
	Ar_Lang3, 
	Ar_Lang4, 
	Ar_Lang5, 
	Ar_Lang6, 
	Ar_Lang7, 
	Ar_Lang8, 
	Ar_Lang9,
	Hp_Vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9,
	hp_supplem, 
	hp_date, 
	hp_time, 
	hp_userid, 
	hp_cashier,
	hp_artinum as artinum,
	hp_ifc,
	pa_pttarti
FROM histpost, histres, article, Param
WHERE 	hp_date >=min1
AND 	hp_date <= Max1
and	get_rm_rmname(hr_roomnum) >= min2
and	get_rm_rmname(hr_roomnum) <= max2
AND	(Empty(hp_ratecod) OR hp_split)
AND 	hr_reserid = hp_reserid
AND 	!hp_split
AND 	hP_UserID="INTERFACE"
AND 	!hp_cancel
AND 	ar_artinum = hp_artinum
And 	hp_artinum = pa_pttarti
AND 	hp_artinum > 0
AND 	hp_paynum =0
AND 	hp_reserid > -2
Union All
SELECT 	hp_amount AS Amount,
	"", 
	"", 
	hp_postid,
	hp_artinum, 
	hp_price, 
	hp_units,
	Ar_Lang1, 
	Ar_Lang2, 
	Ar_Lang3, 
	Ar_Lang4, 
	Ar_Lang5, 
	Ar_Lang6, 
	Ar_Lang7, 
	Ar_Lang8, 
	Ar_Lang9,
	Hp_Vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9,
	hp_supplem, 
	hp_date, 
	hp_time, 
	hp_userid, 
	hp_cashier,
	hp_artinum as artinum,
	hp_ifc,
	pa_pttArti
FROM histpost, article, Param
WHERE 	hp_date >=min1
AND 	hp_date <= Max1
AND 	hp_reserid NOT IN 
	( SELECT hr_reserid FROM histres WHERE hr_reserid = hp_reserid )
AND 	hp_reserid > -2
AND	ar_artinum = hp_artinum
And 	hp_artinum = pa_pttarti
AND 	!hp_split
AND 	hP_UserID="INTERFACE"
AND 	!hp_cancel
AND 	hp_artinum > 0
AND 	hp_paynum =0
ORDER BY artinum, 2,3,4
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*