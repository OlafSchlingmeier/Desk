PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.20"
RETURN tcVersion
ENDPROC
*
* Sign '%' replaces string '<p><d>'. So sign '%' is following strings 'd', 'w', 'm', 'y', 'pd', 'pw', 'pm', 'py'
*      <p> - is '' for current year and 'p' for previous year
*      <d> - is 'd'-daily, 'w'-week cumulative, 'm'-month cumulative, 'y'-year cumulative
*      'X' - is 0 - 9
#DEFINE pcFieldsRm     "pp_%newres, pp_%nights"
#DEFINE pcFieldsRv     "pp_%revX"
*
PROCEDURE _fc02000
LPARAMETERS tlWithoutVat, tcResFilter
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_fc02000")
loSession.DoPreproc(tlWithoutVat, tcResFilter, @laPreProc)
RELEASE loSession

WAIT CLEAR

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
ENDPROC
**********
DEFINE CLASS _fc02000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("article,picklist,reservat,histres,resrooms,param,roomtype,post,histpost,ressplit", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _fc02000
          ENDTEXT
     ELSE
          PpCursorCreate()
     ENDIF
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS tlWithoutVat, tcResFilter, taPreProc

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _fc02000 WITH <<SqlCnv(tlWithoutVat)>>, <<SqlCnv(tcResFilter)>>
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          PpDo(tlWithoutVat, tcResFilter)
     ENDIF

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
LOCAL i, j, lcFields, lcFieldsS, lcField

lcFieldsS = ""
FOR i = 1 TO GETWORDCOUNT(pcFieldsRm, ",")
     lcFieldsS = lcFieldsS + ", " + ALLTRIM(GETWORDNUM(pcFieldsRm, i, ",")) + " N(8)"
NEXT
FOR i = 0 TO 9
     lcFieldsS = lcFieldsS + ", " + STRTRAN(pcFieldsRv, "X", TRANSFORM(i)) + " B(2)"
NEXT
lcFields = ""
FOR i = 1 TO 2
     FOR j = 1 TO 4
          lcFields = lcFields + STRTRAN(lcFieldsS, "%", IIF(i=1,"","p")+ICASE(j=1,"d",j=2,"w",j=3,"m","y"))
     NEXT
NEXT

CREATE CURSOR PreProc (ho_descrip C(100), ho_hotcode C(10), pp_date D, pp_pdate D &lcFields)
INDEX ON pp_date TAG pp_date
INDEX ON pp_pdate TAG pp_pdate
SET ORDER TO
ENDPROC
*
PROCEDURE PpCursorGroup
LOCAL i, j, lcFields, lcFieldsS, lcField

lcFields = pcFieldsRm
FOR i = 0 TO 9
     lcFields = lcFields + ", " + STRTRAN(pcFieldsRv, "X", TRANSFORM(i))
NEXT
lcFieldsS = ""
FOR i = 1 TO GETWORDCOUNT(lcFields, ",")
     lcField = ALLTRIM(GETWORDNUM(lcFields, i, ","))
     lcFieldsS = lcFieldsS + ", SUM(" + lcField + ") AS " + lcField
NEXT
lcFields = ""
FOR i = 1 TO 2
     FOR j = 1 TO 4
          lcFields = lcFields + STRTRAN(lcFieldsS, "%", IIF(i=1,"","p")+ICASE(j=1,"d",j=2,"w",j=3,"m","y"))
     NEXT
NEXT

SELECT pp_date, pp_pdate &lcFields ;
     FROM PreProc ;
     GROUP BY pp_date, pp_pdate ;
     INTO CURSOR curPreProc READWRITE

SELECT PreProc
APPEND FROM DBF("curPreProc")

DClose("curPreProc")
ENDPROC
*
PROCEDURE PpCusorInit
LOCAL lcurDates

lcurDates = MakeDatesCursor(min1, max1)
INSERT INTO PreProc (pp_date, pp_pdate) SELECT c_date, DATE(YEAR(c_date)-1,MONTH(c_date),DAY(c_date)) FROM &lcurDates

DClose(lcurDates)
ENDPROC
*
* Recalculating occupancy and revnue statistic in present and past.
PROCEDURE OccupancyCalculate
SELECT rs_created, SUM(rs_rooms) AS pp_resnew, SUM(rs_rooms*rs_nights) AS pp_nights ;
     FROM curReservat ;
     GROUP BY rs_created ;
     INTO CURSOR curPreproc
INDEX ON rs_created TAG rs_created
REPLACE pp_dnewres  WITH curPreproc.pp_resnew, pp_dnights  WITH curPreproc.pp_nights FOR SEEK(pp_date,  "curPreproc", "rs_created") IN PreProc
REPLACE pp_pdnewres WITH curPreproc.pp_resnew, pp_pdnights WITH curPreproc.pp_nights FOR SEEK(pp_pdate, "curPreproc", "rs_created") IN PreProc

SELECT SUM(IIF(BETWEEN(rs_created, pdDateW1,  pdDateW2),  pp_resnew, 0)) AS pp_wnewres, ;
       SUM(IIF(BETWEEN(rs_created, pdDateW1,  pdDateW2),  pp_nights, 0)) AS pp_wnights, ;
       SUM(IIF(BETWEEN(rs_created, pdDateM1,  pdDateM2),  pp_resnew, 0)) AS pp_mnewres, ;
       SUM(IIF(BETWEEN(rs_created, pdDateM1,  pdDateM2),  pp_nights, 0)) AS pp_mnights, ;
       SUM(IIF(BETWEEN(rs_created, pdDateY1,  pdDateY2),  pp_resnew, 0)) AS pp_ynewres, ;
       SUM(IIF(BETWEEN(rs_created, pdDateY1,  pdDateY2),  pp_nights, 0)) AS pp_ynights, ;
       SUM(IIF(BETWEEN(rs_created, pdDateW1P, pdDateW2P), pp_resnew, 0)) AS pp_pwnewres, ;
       SUM(IIF(BETWEEN(rs_created, pdDateW1P, pdDateW2P), pp_nights, 0)) AS pp_pwnights, ;
       SUM(IIF(BETWEEN(rs_created, pdDateM1P, pdDateM2P), pp_resnew, 0)) AS pp_pmnewres, ;
       SUM(IIF(BETWEEN(rs_created, pdDateM1P, pdDateM2P), pp_nights, 0)) AS pp_pmnights, ;
       SUM(IIF(BETWEEN(rs_created, pdDateY1P, pdDateY2P), pp_resnew, 0)) AS pp_pynewres, ;
       SUM(IIF(BETWEEN(rs_created, pdDateY1P, pdDateY2P), pp_nights, 0)) AS pp_pynights ;
     FROM curPreproc ;
     INTO CURSOR curPreproc
REPLACE pp_wnewres  WITH curPreproc.pp_wnewres, ;
        pp_wnights  WITH curPreproc.pp_wnights, ;
        pp_mnewres  WITH curPreproc.pp_mnewres, ;
        pp_mnights  WITH curPreproc.pp_mnights, ;
        pp_ynewres  WITH curPreproc.pp_ynewres, ;
        pp_ynights  WITH curPreproc.pp_ynights, ;
        pp_pwnewres WITH curPreproc.pp_pwnewres, ;
        pp_pwnights WITH curPreproc.pp_pwnights, ;
        pp_pmnewres WITH curPreproc.pp_pmnewres, ;
        pp_pmnights WITH curPreproc.pp_pmnights, ;
        pp_pynewres WITH curPreproc.pp_pynewres, ;
        pp_pynights WITH curPreproc.pp_pynights ;
     ALL IN PreProc

DClose("curPreproc")
ENDPROC
*
PROCEDURE RevnueCalculate
LPARAMETERS tlWithoutVat

SELECT rs_created, ar_main, SUM(rs_rooms*ROUND(ps_price*ps_units - IIF(tlWithoutVat, ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9, 0),2)) AS pp_rev ;
     FROM curPost ;
     WHERE BETWEEN(ar_main, min2, max2) AND NOT EMPTY(rs_rooms*ps_price*ps_units) ;
     GROUP BY rs_created, ar_main ;
     INTO CURSOR curPreproc
INDEX ON rs_created TAG rs_created
SCAN FOR BETWEEN(rs_created, min1, max1) AND SEEK(curPreproc.rs_created, "PreProc", "pp_date")
     REPLACE ("pp_drev" + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_rev IN PreProc
ENDSCAN
SCAN FOR BETWEEN(rs_created, pdMin1, pdMax1) AND SEEK(curPreproc.rs_created, "PreProc", "pp_pdate")
     REPLACE ("pp_pdrev" + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_rev IN PreProc
ENDSCAN

SELECT ar_main, ;
       CAST(SUM(IIF(BETWEEN(rs_created, pdDateW1,  pdDateW2),  pp_rev, 0)) AS Double(2)) AS pp_wrev, ;
       CAST(SUM(IIF(BETWEEN(rs_created, pdDateM1,  pdDateM2),  pp_rev, 0)) AS Double(2)) AS pp_mrev, ;
       CAST(SUM(IIF(BETWEEN(rs_created, pdDateY1,  pdDateY2),  pp_rev, 0)) AS Double(2)) AS pp_yrev, ;
       CAST(SUM(IIF(BETWEEN(rs_created, pdDateW1P, pdDateW2P), pp_rev, 0)) AS Double(2)) AS pp_pwrev, ;
       CAST(SUM(IIF(BETWEEN(rs_created, pdDateM1P, pdDateM2P), pp_rev, 0)) AS Double(2)) AS pp_pmrev, ;
       CAST(SUM(IIF(BETWEEN(rs_created, pdDateY1P, pdDateY2P), pp_rev, 0)) AS Double(2)) AS pp_pyrev ;
     FROM curPreproc ;
     GROUP BY ar_main ;
     INTO CURSOR curPreproc
SCAN
     REPLACE ("pp_wrev"  + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_wrev, ;
             ("pp_mrev"  + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_mrev, ;
             ("pp_yrev"  + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_yrev, ;
             ("pp_pwrev" + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_pwrev, ;
             ("pp_pmrev" + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_pmrev, ;
             ("pp_pyrev" + TRANSFORM(curPreproc.ar_main)) WITH curPreproc.pp_pyrev ;
          ALL IN PreProc
ENDSCAN

DClose("curPreproc")
ENDPROC
*
PROCEDURE PpDo
LPARAMETERS tlWithoutVat, tcResFilter
LOCAL lcHResFilter, lcVatnumMacro
PRIVATE pdStartDate, pdEndDate, pdMin1, pdMax1, pdDateW1, pdDateW2, pdDateM1, pdDateM2, pdDateY1, pdDateY2, pdDateW1P, pdDateW2P, pdDateM1P, pdDateM2P, pdDateY1P, pdDateY2P, lcArchScripts

pdStartDate = DATE(YEAR(min1)-1,1,1)
pdEndDate = DATE(YEAR(max1),12,31)
pdMin1 = GetRelDate(min1, "-1Y")
pdMax1 = GetRelDate(max1, "-1Y")

pdDateW1  = min1
pdDateW2  = min1 + 6
pdDateM1  = GetRelDate(min1,"",1)
pdDateM2  = GetRelDate(min1,"",31)
pdDateY1  = DATE(YEAR(min1),1,1)
pdDateY2  = DATE(YEAR(min1),12,31)
pdDateW1P = pdMin1
pdDateW2P = pdMin1 + 6
pdDateM1P = GetRelDate(pdMin1,"",1)
pdDateM2P = GetRelDate(pdMin1,"",31)
pdDateY1P = DATE(YEAR(pdMin1),1,1)
pdDateY2P = DATE(YEAR(pdMin1),12,31)

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE hr_reserid >= 1 AND BETWEEN(hr_created, <<SqlCnvB(pdStartDate)>>, <<SqlCnvB(pdEndDate)>>);

SELECT histpost.* FROM histpost
     INNER JOIN histres ON hr_reserid = hp_origid
     WHERE hr_reserid >= 1 AND BETWEEN(hr_created, <<SqlCnvB(pdStartDate)>>, <<SqlCnvB(pdEndDate)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, pdStartDate)
*
****************************************************************************************************

PpCusorInit()
IF VARTYPE(tcResFilter) # "C" OR EMPTY(tcResFilter)
     tcResFilter = ".T."
ENDIF

lcHResFilter = STRTRAN(tcResFilter, "rs_", "hr_")
SELECT DISTINCT rs_rsid, rs_reserid, rs_depdate-rs_arrdate AS rs_nights, rs_created, rs_ratedat, rs_rooms, rs_status ;
     FROM reservat ;
     LEFT JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
     WHERE BETWEEN(rs_created, pdStartDate, pdEndDate) AND (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND (NOT min3 OR INLIST(rt_group,1,4)) AND ;
          NOT INLIST(rs_status, "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter ;
UNION ALL ;
SELECT DISTINCT hr_rsid, hr_reserid, hr_depdate-hr_arrdate, hr_created, hr_ratedat, hr_rooms, hr_status ;
     FROM histres ;
     LEFT JOIN reservat ON rs_reserid = hr_reserid ;
     LEFT JOIN roomtype ON rt_roomtyp = hr_roomtyp ;
     WHERE hr_reserid >= 1 AND BETWEEN(hr_created, pdStartDate, pdEndDate) AND (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND (NOT min3 OR INLIST(rt_group,1,4)) AND ISNULL(rs_reserid) AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND (hr_status <> "TEN" OR param.pa_tentdef) AND &lcHResFilter ;
     INTO CURSOR curReservat

lcVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")
SELECT rs_created, rs_rooms, ps_date, ps_price, ps_units, ar_main, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9 ;
     FROM post ;
     INNER JOIN curReservat ON rs_reserid = ps_origid ;
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND NOT EMPTY(ri_roomtyp) AND BETWEEN(ps_rdate, ri_date, ri_todate) ;
     LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
     LEFT JOIN article ON ps_artinum = ar_artinum ;
     WHERE (EVL(RptBulding,"*") = "*" OR NVL(rt_buildng,"") = RptBulding) AND NOT EMPTY(ps_artinum) AND NOT EMPTY(ps_price*ps_units) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) ;
UNION ALL ;
SELECT rs_created, rs_rooms, hp_date, hp_price, hp_units, ar_main, hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9 ;
     FROM histpost ;
     LEFT JOIN post ON ps_postid = hp_postid ;
     INNER JOIN curReservat ON rs_reserid = hp_origid ;
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND NOT EMPTY(ri_roomtyp) AND BETWEEN(hp_rdate, ri_date, ri_todate) ;
     LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
     LEFT JOIN article ON hp_artinum = ar_artinum ;
     WHERE ISNULL(ps_postid) AND (EVL(RptBulding,"*") = "*" OR NVL(rt_buildng,"") = RptBulding) AND NOT EMPTY(hp_artinum) AND NOT EMPTY(hp_price*hp_units) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
UNION ALL ;
SELECT rs_created, rs_rooms, rl_date, rl_price, rl_units, ar_main, IIF(ar_vat=0,&lcVatnumMacro,0), IIF(ar_vat=1,&lcVatnumMacro,0), ;
     IIF(ar_vat=2,&lcVatnumMacro,0), IIF(ar_vat=3,&lcVatnumMacro,0), IIF(ar_vat=4,&lcVatnumMacro,0), IIF(ar_vat=5,&lcVatnumMacro,0), ;
     IIF(ar_vat=6,&lcVatnumMacro,0), IIF(ar_vat=7,&lcVatnumMacro,0), IIF(ar_vat=8,&lcVatnumMacro,0), IIF(ar_vat=9,&lcVatnumMacro,0) ;
     FROM ressplit ;
     INNER JOIN curReservat ON rs_rsid = rl_rsid ;
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND NOT EMPTY(ri_roomtyp) AND BETWEEN(rl_rdate, ri_date, ri_todate) ;
     LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp ;
     LEFT JOIN article ON rl_artinum = ar_artinum ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rl_date > rs_ratedat AND (EVL(RptBulding,"*") = "*" OR NVL(rt_buildng,"") = RptBulding) AND rs_status <> "OUT" AND NOT EMPTY(rl_price*rl_units) ;
     INTO CURSOR curPost

OccupancyCalculate()
RevnueCalculate(tlWithoutVat)

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************

DClose("curReservat")
DClose("curPost")
ENDPROC
*