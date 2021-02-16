PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "7.21"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp10000
LPARAMETERS tcLiart, tlWithoutVat
LOCAL lcLabel, loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_hp10000")
loSession.DoPreproc(tcLiart, tlWithoutVat, @laPreProc)
RELEASE loSession

WAIT CLEAR

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
ENDPROC
**********
DEFINE CLASS _hp10000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("param,paymetho,article,histpost", tcHotCode, tcPath)
ENDPROC
*
PROCEDURE DoPreproc
     LPARAMETERS tcLiart, tlWithoutVat, taPreProc

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _hp10000 WITH <<SqlCnv(tcLiart)>>, <<SqlCnv(tlWithoutVat)>>
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          PpDo(tcLiart, tlWithoutVat)
     ENDIF

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
CREATE CURSOR PreProc (pp_artinum N(4), pp_paynum N(3), pp_lang3 C(25), pp_sub N(2), pp_main N(1), pp_artityp N(1), ;
     pp_tag B(6), pp_monat B(6), pp_jahr B(6), pp_vtag B(6), pp_vmonat B(6), pp_vjahr B(6))
ENDPROC
*
PROCEDURE PpCursorGroup
SELECT pp_artinum, pp_paynum, pp_lang3, pp_sub, pp_main, pp_artityp, ;
     SUM(pp_tag) AS pp_tag, SUM(pp_monat) AS pp_monat, SUM(pp_jahr) AS pp_jahr, ;
     SUM(pp_vtag) AS pp_vtag, SUM(pp_vmonat) AS pp_vmonat, SUM(pp_vjahr) AS pp_vjahr ;
     FROM PreProc ;
     GROUP BY pp_artinum, pp_paynum, pp_lang3, pp_sub, pp_main, pp_artityp ;
     INTO CURSOR PreProc
ENDPROC
*
PROCEDURE PpDo
LPARAMETERS tcLiart, tlWithoutVat
LOCAL llExclvat, ldMonth1, ldYear1, ldLyMin1, ldLyMonth1, ldLyYear1, lcAmountField, lcArchScripts

ldMonth1 = GetRelDate(min1,"",1)
ldYear1 = DATE(YEAR(min1),1,1)
ldLyMin1 = GetRelDate(min1,"-1Y")
ldLyMonth1 = GetRelDate(min1,"-1Y",1)
ldLyYear1 = DATE(YEAR(min1)-1,1,1)
lcAmountField = "hp_amount"

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histpost.* FROM histpost
     WHERE hp_reserid > 0 AND (BETWEEN(hp_date, <<SqlCnvB(ldLyYear1)>>, <<SqlCnvB(ldLyMin1)>>) OR BETWEEN(hp_date, <<SqlCnvB(ldYear1)>>, <<SqlCnvB(min1)>>))
ENDTEXT
ProcArchive("RestoreArchive", "histpost", lcArchScripts, ldLyYear1)
*
****************************************************************************************************

DO CASE
     CASE tcLiart = "U"
          *llExclvat = param.pa_exclvat
          DO CASE
               CASE NOT llExclvat AND tlWithoutVat
                    lcAmountField = lcAmountField + "-(hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9)"
               CASE llExclvat AND NOT tlWithoutVat
                    lcAmountField = lcAmountField + "+(hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9)"
               OTHERWISE
          ENDCASE
          SELECT hp_artinum AS pp_artinum, 0 AS pp_paynum, CAST(NVL(ar_lang3,"") AS C(25)) AS pp_lang3, ;
                 CAST(NVL(ar_sub,0) AS N(2)) AS pp_sub, CAST(NVL(ar_main,0) AS N(1)) AS pp_main, CAST(NVL(ar_artityp,0) AS N(1)) AS pp_artityp, ;
                 SUM(IIF(hp_date = min1,                         1, 0) * ROUND(&lcAmountField,6)) AS pp_tag, ;
                 SUM(IIF(BETWEEN(hp_date, ldMonth1, min1),       1, 0) * ROUND(&lcAmountField,6)) AS pp_monat, ;
                 SUM(IIF(BETWEEN(hp_date, ldYear1,  min1),       1, 0) * ROUND(&lcAmountField,6)) AS pp_jahr, ;
                 SUM(IIF(hp_date = ldLyMin1,                     1, 0) * ROUND(&lcAmountField,6)) AS pp_vtag, ;
                 SUM(IIF(BETWEEN(hp_date, ldLyMonth1, ldLyMin1), 1, 0) * ROUND(&lcAmountField,6)) AS pp_vmonat, ;
                 SUM(IIF(BETWEEN(hp_date, ldLyYear1,  ldLyMin1), 1, 0) * ROUND(&lcAmountField,6)) AS pp_vjahr ;
               FROM histpost ;
               LEFT JOIN (SELECT ar_buildng, ar_artinum, ar_lang3, ar_sub, ar_main, ar_artityp FROM article GROUP BY 2) ar ON ar_artinum = hp_artinum ;
               WHERE (BETWEEN(hp_date, ldLyYear1, ldLyMin1) OR BETWEEN(hp_date, ldYear1, min1)) AND ;
                    NOT hp_cancel AND hp_artinum > 0 AND hp_reserid > 0 AND (EMPTY(hp_ratecod) OR hp_split) AND ;
                    (EMPTY(ar_buildng) OR EVL(RptBulding,"*") = "*" OR ar_buildng = RptBulding) ;
               GROUP BY 1 ;
               INTO CURSOR PreProc
     CASE tcLiart = "F"
          SELECT 0 AS pp_artinum, hp_paynum AS pp_paynum, CAST(NVL(pm_lang3,"") AS C(25)) AS pp_lang3, 0 AS pp_sub, 0 AS pp_main, 0 AS pp_artityp, ;
                 SUM(IIF(hp_date = min1,                         1, 0) * ROUND(&lcAmountField,6)) AS pp_tag, ;
                 SUM(IIF(BETWEEN(hp_date, ldMonth1, min1),       1, 0) * ROUND(&lcAmountField,6)) AS pp_monat, ;
                 SUM(IIF(BETWEEN(hp_date, ldYear1,  min1),       1, 0) * ROUND(&lcAmountField,6)) AS pp_jahr, ;
                 SUM(IIF(hp_date = ldLyMin1,                     1, 0) * ROUND(&lcAmountField,6)) AS pp_vtag, ;
                 SUM(IIF(BETWEEN(hp_date, ldLyMonth1, ldLyMin1), 1, 0) * ROUND(&lcAmountField,6)) AS pp_vmonat, ;
                 SUM(IIF(BETWEEN(hp_date, ldLyYear1,  ldLyMin1), 1, 0) * ROUND(&lcAmountField,6)) AS pp_vjahr ;
               FROM histpost ;
               LEFT JOIN paymetho ON pm_paynum = hp_paynum ;
               WHERE (BETWEEN(hp_date, ldLyYear1, ldLyMin1) OR BETWEEN(hp_date, ldYear1, min1)) AND ;
                    NOT hp_cancel AND hp_paynum > 0 AND NOT INLIST(hp_reserid, -2, -1, 0.200, 0.300) AND ;
                    (EMPTY(pm_buildng) OR EVL(RptBulding,"*") = "*" OR pm_buildng = RptBulding) ;
               GROUP BY 2 ;
               INTO CURSOR PreProc
     OTHERWISE
          PpCursorCreate()
ENDCASE

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histpost")
*
****************************************************************************************************
ENDPROC
*