PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "2.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _fc01006
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_fc01006")
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
DEFINE CLASS _fc01006 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("param,picklist,reservat,post,ressplit,article,histres,histpost", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _fc01006
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
LOCAL pdStartDate, pdEndDate, tcResFilter, lcHResFilter, lcHRes1Filter, lcHRes2Filter, lcRes1Filter, lcRes2Filter, lcVatnumMacro, lcArchScripts

pdStartDate = min1
pdEndDate = max1
tcResFilter = ".T."

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     INNER JOIN (
     SELECT hr_reserid AS c_reserid FROM histres
          INNER JOIN histpost ON hp_reserid = hr_reserid OR hp_origid = hr_reserid
          WHERE hp_reserid > 0 AND BETWEEN(hp_date, <<SqlCnvB(pdStartDate)>>, <<SqlCnvB(pdEndDate)>>)
          GROUP BY hr_reserid
     ) hr ON hr_reserid = c_reserid;

SELECT histpost.* FROM histpost
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, <<SqlCnvB(pdStartDate)>>, <<SqlCnvB(pdEndDate)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, pdStartDate)
*
****************************************************************************************************

lcHResFilter = STRTRAN(tcResFilter, "rs_", "histres.hr_")
lcHRes1Filter = STRTRAN(tcResFilter, "rs_", "hr1.hr_")
lcHRes2Filter = STRTRAN(tcResFilter, "rs_", "hr2.hr_")
lcRes1Filter = STRTRAN(tcResFilter, "rs_", "rs1.rs_")
lcRes2Filter = STRTRAN(tcResFilter, "rs_", "rs2.rs_")
tcResFilter = STRTRAN(tcResFilter, "rs_", "reservat.rs_")

lcVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")

SELECT NVL(ar_artinum,0) AS ar_artinum, NVL(ar_artityp,0) AS ar_artityp,NVL(ar_main,0) AS ar_main, NVL(ar_sub,0) AS ar_sub, ps_date, ps_amount, ps_price, ps_units, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ;
       IIF(ps_origid<1 OR ps_rdate <= NVL(rs1.rs_ratedat,rs2.rs_ratedat), 001, NVL(NVL(rs1.rs_rooms,rs2.rs_rooms),000)) AS resrooms, ;
       IIF(ps_origid<1, [OUT], NVL(NVL(rs1.rs_status,rs2.rs_status),[   ])) AS resstatus ;
     FROM post ;
     LEFT JOIN reservat rs1 ON rs1.rs_reserid = ps_origid ;
     LEFT JOIN reservat rs2 ON rs2.rs_reserid = ps_reserid ;
     LEFT JOIN article ON ps_artinum = ar_artinum ;
     WHERE ps_reserid > 0 AND BETWEEN(ps_date, pdStartDate, pdEndDate) AND NOT SEEK(ps_postid, "histpost", "tag3") AND ;
          NOT EMPTY(ps_artinum) AND ar_artityp = 1 AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) AND (&lcRes1Filter OR &lcRes2Filter) ;
UNION ALL ;
SELECT NVL(ar_artinum,0), NVL(ar_artityp,0), NVL(ar_main,0), NVL(ar_sub,0), hp_date, hp_amount, hp_price, hp_units, hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, ;
       IIF(hp_origid<1 OR hp_rdate <= NVL(hr1.hr_ratedat,hr2.hr_ratedat), 001, NVL(NVL(hr1.hr_rooms,hr2.hr_rooms),000)), ;
       IIF(hp_origid<1, [OUT], NVL(NVL(hr1.hr_status,hr2.hr_status),[   ])) ;
     FROM histpost ;
     LEFT JOIN post ON ps_postid = hp_postid ;
     LEFT JOIN histres hr1 ON hr1.hr_reserid = hp_origid ;
     LEFT JOIN histres hr2 ON hr2.hr_reserid = hp_reserid ;
     LEFT JOIN article ON hp_artinum = ar_artinum ;
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, pdStartDate, pdEndDate) AND ISNULL(ps_postid) AND ;
          NOT EMPTY(hp_artinum) AND ar_artityp = 1 AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND (&lcHRes1Filter OR &lcHRes2Filter) ;
UNION ALL ;
SELECT NVL(ar_artinum,0), NVL(ar_artityp,0), NVL(ar_main,0), NVL(ar_sub,0), rl_date, rl_price*rl_units, rl_price, rl_units, IIF(NVL(ar_vat,0)=0,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=1,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=2,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=3,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=4,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=5,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=6,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=7,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=8,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=9,&lcVatnumMacro,0), ;
       NVL(rs_rooms,000), NVL(rs_status,[   ]) ;
     FROM ressplit ;
     LEFT JOIN reservat ON rs_rsid = rl_rsid ;
     LEFT JOIN article ON rl_artinum = ar_artinum ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rl_date > rs_ratedat AND BETWEEN(rl_date, pdStartDate, pdEndDate) AND ar_artityp = 1 AND NOT EMPTY(rl_price*rl_units) AND ;
          NOT INLIST(rs_status, "OUT", "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter ;
     INTO CURSOR curPost

SELECT ar_artinum AS hp_artinum, ;
       SUM(ps_units) AS Units, ;
       SUM(ps_amount) AS Amount, ;
       SUM(ps_vat1) AS Vat1, ;
       SUM(ps_vat2) AS Vat2, ;
       SUM(ps_vat3) AS Vat3, ;
       SUM(ps_vat4) AS Vat4, ;
       SUM(ps_vat5) AS Vat5, ;
       SUM(ps_vat6) AS Vat6, ;
       SUM(ps_vat7) AS Vat7, ;
       SUM(ps_vat8) AS Vat8, ;
       SUM(ps_vat9) AS Vat9, ;
       ar_artityp, ;
       ar_main, ;
       ar_sub ;
     FROM curPost ;
     GROUP BY ar_main, ar_sub, ar_artinum ;
     ORDER BY ar_main, ar_sub, ar_artinum ;
     INTO CURSOR Preproc NOFILTER

DClose("curPost")

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************

RETURN .T.
ENDPROC
*