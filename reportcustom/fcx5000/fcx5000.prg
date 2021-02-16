PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "8.30"
RETURN tcVersion
ENDPROC
*
* Sign '%' replaces string '<g><arr>'. So sign '%' is following strings '',  'arr',  'dep',  'g',  'garr',  'gdep'
*      <g> - is '' for all reservations and 'g' just for group reservations
*      <arr> - is 'arr' for arrivals, 'dep' for departures and '' staying days
#DEFINE pcFieldsRm     "pp_%rms, pp_%ad, pp_%ch1, pp_%ch2, pp_%ch3"
*
* Sign '%' replaces string '<o>'. So sign '%' is following strings 'd', 'o'
*      <o> - is 'o' for OPT and TEN reservations 'd' for other
*      'X' - is 0 - 9
#DEFINE pcFieldsRv     "pp_%hgX"
*
PROCEDURE fcx5000
LPARAMETERS tlWithoutVat, tcType, tcResFilter, tcAvailFilter

PPMainFunc(tlWithoutVat, tcType, tcResFilter, tcAvailFilter)

SELECT * FROM preproc INTO CURSOR cy1

l_dFrom = min1
l_dTo = max1

min1 = GetRelDate(min1,"-1Y")
max1 = GetRelDate(max1,"-1Y")

PPMainFunc(tlWithoutVat, tcType, tcResFilter, tcAvailFilter)

min1 = l_dFrom
max1 = l_dTo

SELECT * FROM preproc INTO CURSOR cy2

PPAfterProcess()

SELECT * FROM preproc WHERE 1=1 INTO TABLE (TTOC(DATETIME(),1)+".dbf")
USE
SELECT preproc
RETURN .T.
ENDPROC
*
PROCEDURE PPMainFunc
LOCAL loSession
LOCAL ARRAY laPreProc(1)

IF CheckExeVersion("9.10.349")
     WAIT WINDOW NOWAIT "Preprocessing..."

     loSession = CREATEOBJECT("_fc05000")
     loSession.DoPreproc(tlWithoutVat, tcType, tcResFilter, tcAvailFilter, @laPreProc)
     RELEASE loSession

     WAIT CLEAR
ENDIF

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PPAfterProcess
LOCAL l_nsdtotal, l_nsototal, l_nbdtotal, l_nbototal
SELECT CAST('' AS Char(3)) AS p_buildng, CAST('' AS Char(10)) AS p_rtname, CAST('' AS Char(4)) AS p_roomtype, ;
       pp_code, ;
       CAST(pp_dhg0 + pp_dhg1 + pp_dhg2 + pp_dhg3 + pp_dhg4 + pp_dhg5 + pp_dhg6 + pp_dhg7 + pp_dhg8 + pp_dhg9 AS Numeric(12,2)) AS pp_dtotal, ;
       CAST(pp_ohg0 + pp_ohg1 + pp_ohg2 + pp_ohg3 + pp_ohg4 + pp_ohg5 + pp_ohg6 + pp_ohg7 + pp_ohg8 + pp_ohg9 AS Numeric(12,2)) AS pp_ototal, ;
       CAST(0 AS Numeric(12,2)) AS pp_bdtotal, ;
       CAST(0 AS Numeric(12,2)) AS pp_bototal, ;
       CAST(0 AS Numeric(12,2)) AS pp_sdtotal, ;
       CAST(0 AS Numeric(12,2)) AS pp_sototal, ;
       pp_dhg0, pp_dhg1, pp_dhg2, pp_dhg3, pp_dhg4, pp_dhg5, pp_dhg6, pp_dhg7, pp_dhg8, pp_dhg9, ;
       pp_ohg0, pp_ohg1, pp_ohg2, pp_ohg3, pp_ohg4, pp_ohg5, pp_ohg6, pp_ohg7, pp_ohg8, pp_ohg9 ;
       FROM preproc ;
       WHERE 1=1 ;
       INTO CURSOR c1 READWRITE
SCAN ALL
     l_cRTName = PADR(ALLTRIM(GETWORDNUM(pp_code, 1, " ")),10)
     l_cBuildng = PADR(ALLTRIM(GETWORDNUM(pp_code, 2, " ")),3)
     SELECT rtypedef
     LOCATE FOR rd_roomtyp = l_cRTName
     IF NOT FOUND()
          SELECT c1
          DELETE
          LOOP
     ENDIF
     SELECT roomtype
     LOCATE FOR rt_rdid = rtypedef.rd_rdid AND rt_buildng = l_cBuildng
     IF NOT FOUND()
          SELECT c1
          DELETE
          LOOP
     ENDIF
     
     SELECT c1

     REPLACE p_buildng WITH l_cBuildng, ;
             p_rtname  WITH l_cRTName, ;
             p_roomtype WITH roomtype.rt_roomtyp

ENDSCAN

l_nsdtotal = 0.00
l_nsototal = 0.00

SELECT DISTINCT p_buildng FROM c1 INTO CURSOR cbuildng
SCAN ALL
     l_nbdtotal = 0.00
     l_nbototal = 0.00
     SELECT c1
     SUM pp_dtotal, pp_ototal FOR p_buildng = cbuildng.p_buildng TO l_nbdtotal, l_nbototal

     SELECT c1
     REPLACE pp_bdtotal WITH l_nbdtotal, ;
             pp_bototal WITH l_nbototal FOR p_buildng = cbuildng.p_buildng

     l_nsdtotal = l_nsdtotal + l_nbdtotal
     l_nsototal = l_nsototal + l_nbototal

ENDSCAN

SELECT c1
REPLACE pp_sdtotal WITH l_nsdtotal, ;
        pp_sototal WITH l_nsototal ALL

SELECT * FROM c1 WHERE 1=1 ORDER BY p_buildng, p_rtname INTO CURSOR preproc

USE IN c1
USE IN cbuildng

SELECT preproc

RETURN .T.
ENDPROC
*
**********
DEFINE CLASS _fc05000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("ratecode,article,picklist,outoford,reservat,resrooms,resrate,histres,hresroom,hresrate,param,roomtype,rtypedef,building,room,resrmshr,post,histpost,ressplit", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _fc05000
          ENDTEXT
     ELSE
          PpCursorCreate()
     ENDIF
ENDPROC
*
PROCEDURE DoPreproc
     LPARAMETERS tlWithoutVat, tcType, tcResFilter, tcAvailFilter, taPreProc

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _fc05000 WITH <<SqlCnv(tlWithoutVat)>>, <<SqlCnv(tcType)>>, <<SqlCnv(tcResFilter)>>, <<SqlCnv(tcAvailFilter)>>
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          puSessionOrHotcode = this
          PpDo(tlWithoutVat, tcType, tcResFilter, tcAvailFilter)
     ENDIF

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
LOCAL i, j, lcFields, lcFieldsRm, lcFieldsRv

lcFieldsRm = ""
FOR i = 1 TO GETWORDCOUNT(pcFieldsRm, ",")
     lcFieldsRm = lcFieldsRm + ", " + ALLTRIM(GETWORDNUM(pcFieldsRm, i, ",")) + " N(8)"
NEXT
lcFieldsRv = ""
FOR i = 0 TO 9
     lcFieldsRv = lcFieldsRv + ", " + STRTRAN(pcFieldsRv, "X", TRANSFORM(i)) + " B(2)"
NEXT
lcFields = ""
FOR i = 1 TO 2
     FOR j = 1 TO 3
          lcFields = lcFields + STRTRAN(lcFieldsRm, "%", IIF(i=1,"","g")+ICASE(j=2,"arr",j=3,"dep",""))
     NEXT
NEXT
FOR i = 1 TO 2
     lcFields = lcFields + STRTRAN(lcFieldsRv, "%", IIF(i=1,"d","o"))
NEXT

CREATE CURSOR PreProc (pp_code C(14), pp_maxrms N(8), pp_rev B(2) &lcFields)
INDEX ON pp_code TAG pp_code
SET ORDER TO
ENDPROC
*
PROCEDURE PpCursorGroup
LOCAL i, j, lcFieldsRv, lcFields, lcFieldsS, lcField

lcFieldsRv = ""
FOR i = 0 TO 9
     lcFieldsRv = lcFieldsRv + ", " + STRTRAN(pcFieldsRv, "X", TRANSFORM(i))
NEXT
lcFields = ""
FOR i = 1 TO 2
     FOR j = 1 TO 3
          lcFields = lcFields + STRTRAN(", " + pcFieldsRm, "%", IIF(i=1,"","g")+ICASE(j=2,"arr",j=3,"dep",""))
     NEXT
NEXT
FOR i = 1 TO 2
     lcFields = lcFields + STRTRAN(lcFieldsRv, "%", IIF(i=1,"d","o"))
NEXT
lcFields = STUFF(lcFields,1,2,"")
lcFieldsS = ""
FOR i = 1 TO GETWORDCOUNT(lcFields, ",")
     lcField = ALLTRIM(GETWORDNUM(lcFields, i, ","))
     lcFieldsS = lcFieldsS + ", SUM(" + lcField + ") AS " + lcField
NEXT

SELECT pp_code, SUM(pp_maxrms) AS pp_maxrms, SUM(pp_rev) AS pp_rev &lcFieldsS ;
     FROM PreProc ;
     GROUP BY pp_code ;
     INTO CURSOR PreProc
ENDPROC
*
PROCEDURE PpCursorInit
LPARAMETERS tcLabel
LOCAL lcSql, lnMaxRooms
LOCAL ARRAY laRooms(1)

DO CASE
     CASE tcLabel = "RATECOD"     && Preiscode
          lcSql = "SELECT DISTINCT rc_ratecod FROM ratecode WHERE NOT rc_inactiv"
     CASE tcLabel = "ROOMNUM"     && Zimmer
          lcSql = "SELECT rm_roomnum FROM room INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp WHERE (EVL(RptBulding,'*') = '*' OR rt_buildng = RptBulding) AND INLIST(rt_group, 1, 4) AND rt_vwsum"
     CASE tcLabel = "ROOMTYP"     && Zimmertyp
          lcSql = "SELECT rt_roomtyp FROM roomtype WHERE (EVL(RptBulding,'*') = '*' OR rt_buildng = RptBulding) AND INLIST(rt_group, 1, 4) AND rt_vwsum"
     OTHERWISE                    && Marketcode and Herkunfscode
          lcSql = "SELECT DISTINCT pl_charcod FROM picklist WHERE pl_label = " + SqlCnv(tcLabel) + " AND NOT pl_inactiv"
ENDCASE

SELECT [*****] AS pp_code FROM param UNION &lcSql ORDER BY 1 INTO CURSOR curPreProc

SELECT COUNT(*) ;
     FROM Room ;
     INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp ;
     WHERE (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND INLIST(rt_group,1,4) AND rt_vwsum ;
     INTO ARRAY laRooms
lnMaxRooms = laRooms(1) * (max1 - min1 + 1)

SELECT SUM(MIN(oo_todat-1,max1)-MAX(oo_fromdat,min1)+1) FROM OutOfOrd ;
     INNER JOIN Room ON rm_roomnum = oo_roomnum ;
     INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp AND INLIST(rt_group,1,4) AND rt_vwsum ;
     WHERE oo_fromdat <= max1 AND oo_todat > min1 AND NOT oo_cancel AND (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) ;
     INTO ARRAY laRooms
lnMaxRooms = lnMaxRooms - laRooms(1)

INSERT INTO PreProc (pp_code, pp_maxrms) SELECT pp_code, lnMaxRooms FROM curPreProc

DClose("curPreProc")
ENDPROC
*
PROCEDURE OccupancyRevenueGenerate
LPARAMETERS tcLabel

* Recalculating occupancy and revenue statistic in present.
SELECT curReservat
SCAN
     IF plUseUI
          WAIT CLEAR
          WAIT WINDOW NOWAIT STR(rs_reserid, 12, 3)
     ENDIF
     OrResUpd(tcLabel)
ENDSCAN
ENDPROC
*
PROCEDURE RevenueGenerate
LPARAMETERS tlWithoutVat
LOCAL lnAmount, lcPpField, lcBuilding

SELECT curPost
SCAN FOR SEEK(curPost.rescode, "PreProc", "pp_code") OR SEEK([*****], "PreProc", "pp_code")
     IF EVL(RptBulding,"*") <> "*"
          IF EMPTY(c_roomtyp)
               lcBuilding = c_buildng
          ELSE
               lcBuilding = PADR(Get_rt_roomtyp(c_roomtyp, "rt_buildng",,puSessionOrHotcode), 3)
               IF EMPTY(lcBuilding)
                    lcBuilding = c_buildng
               ENDIF
          ENDIF
          IF lcBuilding <> RptBulding
               LOOP
          ENDIF
     ENDIF
     lcPpField = "pp_" + IIF(INLIST(resstatus, "OPT", "TEN"), "o", "d") + "hg" + STR(ar_main,1)
     lnAmount = ps_amount - IIF(tlWithoutVat, ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9, 0)
     REPLACE &lcPpField WITH &lcPpField + lnAmount * curPost.resrooms IN PreProc
ENDSCAN
ENDPROC
*
PROCEDURE OrResUpd
LPARAMETERS tcLabel
LOCAL lcCode, lnSelect, ldDate, llGetResState, llSharing, llStandard, loResrooms, lcResRooms, lcResRate
LOCAL lnRooms, lcRoomtype, lcRoomnum, lcBuildng, lcRatecode, lnRsAdults, lnRsChilds1, lnRsChilds2, lnRsChilds3

DO CASE
     CASE tcLabel = "MARKET"
          lcCode = curReservat.rs_market
     CASE tcLabel = "SOURCE"
          lcCode = curReservat.rs_source
     CASE INLIST(tcLabel, "RATECOD", "ROOMNUM", "ROOMTYP")
     OTHERWISE
          RETURN
ENDCASE

lnSelect = SELECT()

IF curReservat.reshistory
     lcResRooms = "hresroom"
     lcResRate = "hresrate"
ELSE
     lcResRooms = "resrooms"
     lcResRate = "resrate"
ENDIF

ldDate = MAX(min1, curReservat.rs_arrdate)
DO WHILE ldDate <= MIN(max1, curReservat.rs_depdate)
     llGetResState = (ldDate = MAX(min1, curReservat.rs_arrdate)) OR ISNULL(loResrooms) OR NOT BETWEEN(ldDate, loResrooms.ri_date, loResrooms.ri_todate)
     IF llGetResState
          RiGetRoom(curReservat.rs_reserid, ldDate, @loResrooms, lcResRooms)
          llSharing = NOT EMPTY(IIF(ISNULL(loResrooms), 0, loResrooms.ri_shareid))
          lcRoomtype = IIF(ISNULL(loResrooms), curReservat.rs_roomtyp, loResrooms.ri_roomtyp)
          lcRoomnum = IIF(ISNULL(loResrooms), curReservat.rs_roomnum, loResrooms.ri_roomnum)
          IF DLocate("roomtype", "rt_roomtyp = " + SqlCnv(lcRoomtype,.T.))
               llStandard = (roomtype.rt_group = 1 AND roomtype.rt_vwsum OR roomtype.rt_group = 4)
               lnRooms = curReservat.rs_rooms * ICASE(NOT EMPTY(lcRoomnum), Get_rm_rmname(lcRoomnum, "rm_roomocc", puSessionOrHotcode), llStandard, 1, 0)
               lcBuildng = roomtype.rt_buildng
          ELSE
               llStandard = .F.
               lnRooms = 0
               lcBuildng = ""
          ENDIF
     ENDIF
     IF NOT EMPTY(IIF(ISNULL(loResrooms), 0, loResrooms.ri_shareid))
          llSharing = (curReservat.rs_reserid <> RiGetShareFirstReserId(loResrooms.ri_shareid, ldDate))
     ENDIF

     IF SEEK(STR(curReservat.rs_reserid,12,3)+DTOS(ldDate), lcResRate, "tag2")
          lcRatecode = &lcResRate..rr_ratecod
          lnRsAdults = curReservat.rs_rooms * &lcResRate..rr_adults
          lnRsChilds1 = curReservat.rs_rooms * &lcResRate..rr_childs
          lnRsChilds2 = curReservat.rs_rooms * &lcResRate..rr_childs2
          lnRsChilds3 = curReservat.rs_rooms * &lcResRate..rr_childs3
     ELSE
          lcRatecode = curReservat.rs_ratecod
          lnRsAdults = curReservat.rs_rooms * curReservat.rs_adults
          lnRsChilds1 = curReservat.rs_rooms * curReservat.rs_childs
          lnRsChilds2 = curReservat.rs_rooms * curReservat.rs_childs2
          lnRsChilds3 = curReservat.rs_rooms * curReservat.rs_childs3
     ENDIF
     IF NOT llStandard
          STORE 0 TO lnRsAdults, lnRsChilds1, lnRsChilds2, lnRsChilds3
     ENDIF

     DO CASE
          CASE tcLabel = "RATECOD"
               lcCode = PADR(CHRTRAN(lcRatecode,"*!",""),10)
          CASE tcLabel = "ROOMNUM"
               lcCode = lcRoomnum
          CASE tcLabel = "ROOMTYP"
               lcCode = lcRoomtype
          OTHERWISE
     ENDCASE

     IF (EVL(RptBulding,"*") = "*" OR lcBuildng = RptBulding) AND ;
               NOT (llSharing OR EMPTY(lnRooms) AND EMPTY(lnRsAdults) AND EMPTY(lnRsChilds1) AND EMPTY(lnRsChilds2) AND EMPTY(lnRsChilds3)) AND ;
               (SEEK(lcCode, "PreProc", "pp_code") OR SEEK([*****], "PreProc", "pp_code"))
          IF ldDate = curReservat.rs_arrdate
               IF NOT llSharing
                    REPLACE pp_arrrms WITH pp_arrrms + lnRooms IN PreProc
               ENDIF
               REPLACE pp_arrad WITH pp_arrad + lnRsAdults, ;
                       pp_arrch1 WITH pp_arrch1 + lnRsChilds1, ;
                       pp_arrch2 WITH pp_arrch2 + lnRsChilds2, ;
                       pp_arrch3 WITH pp_arrch3 + lnRsChilds3 IN PreProc
               IF NOT EMPTY(curReservat.rs_group)
                    IF NOT llSharing
                         REPLACE pp_garrrms WITH pp_garrrms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_garrad WITH pp_garrad + lnRsAdults, ;
                            pp_garrch1 WITH pp_garrch1 + lnRsChilds1, ;
                            pp_garrch2 WITH pp_garrch2 + lnRsChilds2, ;
                            pp_garrch3 WITH pp_garrch3 + lnRsChilds3 IN PreProc
               ENDIF
          ENDIF
          IF ldDate = curReservat.rs_depdate
               IF NOT llSharing
                    REPLACE pp_deprms WITH pp_deprms + lnRooms IN PreProc
               ENDIF
               REPLACE pp_depad WITH pp_depad + lnRsAdults, ;
                       pp_depch1 WITH pp_depch1 + lnRsChilds1, ;
                       pp_depch2 WITH pp_depch2 + lnRsChilds2, ;
                       pp_depch3 WITH pp_depch3 + lnRsChilds3 IN PreProc
               IF NOT EMPTY(curReservat.rs_group)
                    IF NOT llSharing
                         REPLACE pp_gdeprms WITH pp_gdeprms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_gdepad WITH pp_gdepad + lnRsAdults, ;
                            pp_gdepch1 WITH pp_gdepch1 + lnRsChilds1, ;
                            pp_gdepch2 WITH pp_gdepch2 + lnRsChilds2, ;
                            pp_gdepch3 WITH pp_gdepch3 + lnRsChilds3 IN PreProc
               ENDIF
          ENDIF
          IF ldDate < MIN(max1+1, curReservat.rs_depdate)
               IF NOT llSharing
                    REPLACE pp_rms WITH pp_rms + lnRooms IN PreProc
               ENDIF
               REPLACE pp_ad WITH pp_ad + lnRsAdults, ;
                       pp_ch1 WITH pp_ch1 + lnRsChilds1, ;
                       pp_ch2 WITH pp_ch2 + lnRsChilds2, ;
                       pp_ch3 WITH pp_ch3 + lnRsChilds3 IN PreProc
               IF NOT EMPTY(curReservat.rs_group)
                    IF NOT llSharing
                         REPLACE pp_grms WITH pp_grms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_gad WITH pp_gad + lnRsAdults, ;
                            pp_gch1 WITH pp_gch1 + lnRsChilds1, ;
                            pp_gch2 WITH pp_gch2 + lnRsChilds2, ;
                            pp_gch3 WITH pp_gch3 + lnRsChilds3 IN PreProc
               ENDIF
          ENDIF
     ENDIF
     ldDate = ldDate + 1
ENDDO

SELECT (lnSelect)
ENDPROC
*
PROCEDURE PpDo
LPARAMETERS tlWithoutVat, tcType, tcResFilter, tcAvailFilter
LOCAL lcLabel, lcHResFilter, lcCodeField, lcCodeHField, lcCodeSField, lcVatnumMacro, lcHotcode
PRIVATE plUseUI

plUseUI = (_VFP.StartMode < 3)     && Don't show WAIT WINDOW if called from IIS's ActiveVFP.dll

IF VARTYPE(tcType) # "C"
     tcType = "M"
ENDIF
IF VARTYPE(tcResFilter) # "C"
     tcResFilter = ".T."
ENDIF
DO CASE
     CASE tcType == "S"          && S = Sourcecode/Herkunfscode
          lcLabel = "SOURCE"
     CASE tcType == "P"          && P = Ratecode/Preiscode
          lcLabel = "RATECOD"
     CASE tcType == "R"          && R = Room/Zimmer
          lcLabel = "ROOMNUM"
     CASE tcType == "RT"         && RT= Roomtype/Zimmertyp
          lcLabel = "ROOMTYP"
     OTHERWISE &&tcType == "M"   && M = Marketcode/Marketcode
          lcLabel = "MARKET"
ENDCASE

PpCursorInit(lcLabel)

lcHResFilter = STRTRAN(tcResFilter, "rs_", "hr_")
SELECT DISTINCT rs_rsid, rs_reserid, rs_arrdate, rs_depdate, rs_group, rs_roomtyp, rs_roomnum, rs_ratecod, rs_market, rs_source, rs_ratedat, rs_rooms, ;
       rs_adults, rs_childs, rs_childs2, rs_childs3, rs_status, .F. AS reshistory ;
     FROM reservat ;
     WHERE rs_arrdate <= max1 AND rs_depdate >= min1 AND NOT INLIST(rs_status, "CXL", "NS", "LST") AND ;
          (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter ;
UNION ALL ;
SELECT DISTINCT hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_group, hr_roomtyp, hr_roomnum, hr_ratecod, hr_market, hr_source, hr_ratedat, hr_rooms, ;
       hr_adults, hr_childs, hr_childs2, hr_childs3, hr_status, .T. AS reshistory ;
     FROM histres ;
     LEFT JOIN reservat ON rs_reserid = hr_reserid ;
     WHERE hr_reserid >= 1 AND hr_arrdate <= max1 AND hr_depdate >= min1 AND ISNULL(rs_reserid) AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND (hr_status <> "TEN" OR param.pa_tentdef) AND &lcHResFilter ;
     ORDER BY 2 ;
     INTO CURSOR curReservat

*******************************************************************************************
*
* SQL also copied and used in citadel.exe in commonprocs.prg, procedure RpGetRoomsRevenue
*
* BEGIN
*
* When changing code bellow, don't forget to also check SQL in RpGetRoomsRevenue!!!
*
*******************************************************************************************

lcCodeField = IIF(lcLabel = "RATECOD", "ps_ratecod", "NVL(rs1.rs_" + lcLabel + ",rs2.rs_" + lcLabel + ")")
lcCodeHField = IIF(lcLabel = "RATECOD", "hp_ratecod", "NVL(hr1.hr_" + lcLabel + ",hr2.hr_" + lcLabel + ")")
lcCodeSField = IIF(lcLabel = "RATECOD", "rl_ratecod", "rs_" + lcLabel)
lcVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")
SELECT NVL(ar_main,0) AS ar_main, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ;
       CAST(NVL(NVL(NVL(ri1.ri_roomtyp,rs1.rs_roomtyp),NVL(ri2.ri_roomtyp,rs2.rs_roomtyp)),"") AS C(4)) AS c_roomtyp, ar_buildng AS c_buildng, ;
       IIF(ps_origid<1, 001, NVL(NVL(rs1.rs_rooms,rs2.rs_rooms),000)) AS resrooms, IIF(ps_origid<1, [OUT], NVL(NVL(rs1.rs_status,rs2.rs_status),[   ])) AS resstatus, ;
       PADR(NVL(IIF(ps_origid<1 OR EMPTY(&lcCodeField), .NULL., &lcCodeField),'*****'),10) AS rescode ;
     FROM post ;
     LEFT JOIN reservat rs1 ON rs1.rs_reserid = ps_origid ;
     LEFT JOIN resrooms ri1 ON ri1.ri_reserid = ps_origid AND NOT EMPTY(ri1.ri_roomtyp) AND BETWEEN(EVL(ps_rdate,ps_date), ri1.ri_date, ri1.ri_todate) ;
     LEFT JOIN reservat rs2 ON rs2.rs_reserid = ps_reserid ;
     LEFT JOIN resrooms ri2 ON ri2.ri_reserid = ps_reserid AND NOT EMPTY(ri2.ri_roomtyp) AND BETWEEN(EVL(ps_rdate,ps_date), ri2.ri_date, ri2.ri_todate) ;
     LEFT JOIN article ON ps_artinum = ar_artinum ;
     WHERE ps_reserid > 0 AND BETWEEN(ps_date, min1, max1) AND NOT EMPTY(ps_artinum) AND ar_artityp = 1 AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), hp_amount, hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, ;
       NVL(NVL(NVL(ri1.ri_roomtyp,hr1.hr_roomtyp),NVL(ri2.ri_roomtyp,hr2.hr_roomtyp)),""), ar_buildng, ;
       IIF(hp_origid<1, 001, NVL(NVL(hr1.hr_rooms,hr2.hr_rooms),000)), IIF(hp_origid<1, [OUT], NVL(NVL(hr1.hr_status,hr2.hr_status),[   ])), ;
       PADR(NVL(IIF(hp_origid<1 OR EMPTY(&lcCodeHField), .NULL., &lcCodeHField),'*****'),10) ;
     FROM histpost ;
     LEFT JOIN post ON ps_postid = hp_postid ;
     LEFT JOIN histres hr1 ON hr1.hr_reserid = hp_origid ;
     LEFT JOIN histres hr2 ON hr2.hr_reserid = hp_reserid ;
     LEFT JOIN hresroom ri1 ON ri1.ri_reserid = hp_origid AND NOT EMPTY(ri1.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), ri1.ri_date, ri1.ri_todate) ;
     LEFT JOIN hresroom ri2 ON ri2.ri_reserid = hp_reserid AND NOT EMPTY(ri2.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), ri2.ri_date, ri2.ri_todate) ;
     LEFT JOIN article ON hp_artinum = ar_artinum ;
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, min1, max1) AND ISNULL(ps_postid) AND NOT EMPTY(hp_artinum) AND ar_artityp = 1 AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), rl_price*rl_units, IIF(NVL(ar_vat,0)=0,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=1,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=2,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=3,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=4,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=5,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=6,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=7,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=8,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=9,&lcVatnumMacro,0), ;
       NVL(NVL(ri_roomtyp,rs_roomtyp),""), ar_buildng, ;
       NVL(rs_rooms,000), NVL(rs_status,[   ]), PADR(NVL(IIF(EMPTY(&lcCodeSField), .NULL., &lcCodeSField),'*****'),10) ;
     FROM ressplit ;
     LEFT JOIN reservat ON rs_rsid = rl_rsid ;
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND NOT EMPTY(ri_roomtyp) AND BETWEEN(EVL(rl_rdate,rl_date), ri_date, ri_todate) ;
     LEFT JOIN article ON rl_artinum = ar_artinum ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rl_date > rs_ratedat AND BETWEEN(rl_date, min1, max1) AND ar_artityp = 1 AND NOT EMPTY(rl_price*rl_units) AND ;
          NOT INLIST(rs_status, "OUT", "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter ;
     INTO CURSOR curPost

*******************************************************************************************
*
* SQL also copied and used in citadel.exe in commonprocs.prg, procedure RpGetRoomsRevenue
*
* END
*
* When changing code above, don't forget to also check SQL in RpGetRoomsRevenue!!!
*
*******************************************************************************************

OccupancyRevenueGenerate(lcLabel)
RevenueGenerate(tlWithoutVat)

DClose("curReservat")
DClose("curPost")

DO CASE
     CASE lcLabel = "ROOMNUM"
          DO CASE
               CASE TYPE("puSessionOrHotcode") = "O"
                    lcHotcode = puSessionOrHotcode.cHotCode
               CASE TYPE("puSessionOrHotcode") = "C"
                    lcHotcode = puSessionOrHotcode
               OTHERWISE
          ENDCASE
          REPLACE pp_code WITH IIF(EMPTY(lcHotcode),"",ALLTRIM(lcHotcode)+"-")+get_rm_rmname(pp_code,,puSessionOrHotcode) FOR pp_code <> [*****] IN PreProc
     CASE lcLabel = "ROOMTYP"
          REPLACE pp_code WITH get_rt_roomtyp(pp_code,,,puSessionOrHotcode) FOR pp_code <> [*****] IN PreProc
     OTHERWISE
ENDCASE
ENDPROC
*