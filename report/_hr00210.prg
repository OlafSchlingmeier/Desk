PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hr00210
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hr00210")
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
DEFINE CLASS _hr00210 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,address,apartner,user", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hr00210
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
     WHERE BETWEEN(hr_created, <<SqlCnvB(Min1)>>, <<SqlCnvB(Max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres", lcArchScripts, Min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
select  hr_reserid, hr_ArrDate, hr_DepDate, hr_Rooms, hr_Adults, hr_Childs, hr_childs2, hr_childs3,
	hr_RoomNum, hr_Share, hr_RoomTyp, hr_RateCod, hr_Rate, hr_created, hr_creatus, hr_updated, hr_userid,
	b.ad_company as Company, hr_Status, hr_ArrTime, hr_Group, hr_paymeth, hr_agent, 
 	Iif(hr_compid = hr_addrid and !empty(hr_apid), ap_lname, a.ad_lname) as ad_lname, 
	Iif(hr_compid = hr_addrid and !empty(hr_apid), ap_fname, a.ad_fname) as ad_fname, 
	Iif(hr_compid = hr_addrid and !empty(hr_apid), ap_title, a.ad_title) as ad_title, 
	a.ad_city, a.ad_member, us_name, us_id
from 	histRes, Address a, apartner, address b, user
where 	between(hr_created, Min1, Max1)
and	(alltrim(hr_creatus) = alltrim(min2) or empty(alltrim(min2)))
And	iif(empty(hr_addrid), hr_compid, hr_addrid) = a.Ad_AddrID
And	Iif(!empty(hr_compid), hr_compid, hr_addrid) = b.ad_addrid
And	Iif(empty(hr_apid), -9999, hr_apid) = ap_apid
And	us_id = hr_creatus
order by hr_creatus, hr_created, hr_reserid
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
ENDPROC
*