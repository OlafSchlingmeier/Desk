PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _bn00101
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_bn00101")
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
DEFINE CLASS _bn00101 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("billnum,address,apartner,histres,histpost", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _bn00101
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
     SELECT bn_reserid FROM billnum
          WHERE BETWEEN(bn_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
          GROUP BY bn_reserid
     ) bn ON bn_reserid = hr_reserid;

SELECT histpost.* FROM histpost
     INNER JOIN (
     SELECT bn_reserid FROM billnum
          WHERE BETWEEN(bn_date, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
          GROUP BY bn_reserid
     ) bn ON bn_reserid = hp_reserid
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************

TEXT TO lcSQL TEXTMERGE NOSHOW PRETEXT 15
Select bn_billnum, bn_reserid, bn_addrid, bn_amount, bn_history, bn_status, bn_date, bn_window, bn_apid, 
     bn_paynum, bn_newnum, bn_oldnum,
     ad_company, iif(!empty(bn_apid), ap_lname, ad_lname) as name,
     Iif(!empty(bn_apid), ap_fname, ad_fname) as vorname, ad_city,
     hr_roomnum, histpost.*
from billnum, address, apartner, histres, histpost
where between(bn_date, min1, max1)
and iif(!empty(bn_addrid), bn_addrid, -9999999) = ad_addrid
and Iif(!empty(bn_apid), bn_apid, -9999) = ap_apid
and bn_reserid = hr_reserid
and bn_reserid = hp_reserid
and bn_window = hp_window
and bn_billnum = hp_billnum
and !hp_cancel
and (empty(hp_ratecod) or hp_split)
Union all
Select bn_billnum, bn_reserid, bn_addrid, bn_amount, bn_history, bn_status, bn_date, bn_window, bn_apid,
     bn_paynum, bn_newnum, bn_oldnum,
     ad_company, iif(!empty(bn_apid), ap_lname, ad_lname) as name,
     Iif(!empty(bn_apid), ap_fname, ad_fname) as vorname, ad_city,
     space(4), histpost.*
from billnum, address, apartner, histpost
where between(bn_date, min1, max1)
and iif(!empty(bn_addrid), bn_addrid, -9999999) = ad_addrid
and Iif(!empty(bn_apid), bn_apid, -9999) = ap_apid
and bn_reserid = hp_reserid
and bn_window = hp_window
and bn_billnum = hp_billnum
and !hp_cancel
and (empty(hp_ratecod) or hp_split)
and bn_billnum NOT IN (Select bn_billnum from billnum, histres where bn_reserid = hr_reserid)
order by 1, hp_date, hp_paynum, hp_artinum
ENDTEXT
&lcSQL INTO CURSOR PreProc

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
ENDPROC
*