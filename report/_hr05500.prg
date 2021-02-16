PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hr05500
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hr05500")
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
DEFINE CLASS _hr05500 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,roomtype,address,room,apartner", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hr05500
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
     WHERE BETWEEN(hr_arrdate, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
Select  hr_ArrDate, hr_DepDate, hr_Rooms, hr_Adults, hr_Childs, hr_childs2, hr_childs3, hr_cnfstat,
	hr_RoomNum, hr_Share, hr_RoomTyp, hr_RateCod, hr_Rate, hr_agent, hr_changes, hr_cxlnr,
	b.ad_company as Company, hr_Note, hr_Status, hr_ArrTime, hr_deptime, hr_Group, hr_paymeth,
 	Iif(hr_compid = hr_addrid and !empty(hr_apid), ap_lname, a.ad_lname) as ad_lname, 
	Iif(hr_compid = hr_addrid and !empty(hr_apid), ap_fname, a.ad_fname) as ad_fname, 
	Iif(hr_compid = hr_addrid and !empty(hr_apid), ap_title, a.ad_title) as ad_title, 
	a.ad_city, a.ad_member,
	rt_group, rm_rpseq
From 	histRes, RoomType, Address a, Room, apartner, address b
Where 	Between(hr_ArrDate, Min1, Max1)
And 	hr_RoomTyp = Rt_RoomTyp
And	Rt_Group = 2
And	Iif(!empty(hr_addrid), hr_addrid, hr_compid) = a.Ad_AddrID
And	Iif(!empty(hr_compid), hr_compid, hr_addrid) = b.ad_addrid
And	hr_RoomNum = Rm_RoomNum
And	Iif(empty(hr_apid), -9999, hr_apid) = ap_apid
And	iif(empty(min2), inlist(hr_status, "DEF","OPT","ASG","6PM","IN","OUT"), hr_status = min2)
order by 1
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
ENDPROC
*