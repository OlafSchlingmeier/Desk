PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.42"
RETURN tcVersion
ENDPROC
*
PROCEDURE fc06099
PARAMETER tlWithoutVat, tcType, tcResFilter, tcAvailFilter
LOCAL lcLabel, loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

IF TYPE("tcType") # "C"
     tcType = "M"
ENDIF
IF TYPE("tcResFilter") # "C"
     tcResFilter = ".T."
ENDIF
DO CASE
     CASE tcType == "S"          && S = Sourcecode/Herkunfscode
          lcLabel = "SOURCE"
     CASE tcType == "P"          && P = Preiscode
          lcLabel = "RATECOD"
     OTHERWISE && tcType == "M"  && M = Marketcode
          lcLabel = "MARKET"
ENDCASE
loSession = CREATEOBJECT("_fc06000")
loSession.DoPreproc(tlWithoutVat, lcLabel, tcResFilter, tcAvailFilter, @laPreProc)
RELEASE loSession

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
*!*     SELECT * FROM preproc INTO TABLE d:\fc06099.dbf
*!*     USE IN fc06099
WAIT CLEAR
ENDPROC
*
PROCEDURE PpCursorCreate
CREATE CURSOR PreProc (pp_year N(4), pp_month N(2), pp_code C(10), pp_maxrms N(8), pp_rev B(2), ;
     pp_rms N(8), pp_rmsopt N(8), pp_ad N(8), pp_ch1 N(8), pp_ch2 N(8), pp_ch3 N(8), ;
     pp_arrrms N(8), pp_arrad N(8), pp_arrch1 N(8), pp_arrch2 N(8), pp_arrch3 N(8), ;
     pp_deprms N(8), pp_depad N(8), pp_depch1 N(8), pp_depch2 N(8), pp_depch3 N(8), ;
     pp_grms N(8), pp_gad N(8), pp_gch1 N(8), pp_gch2 N(8), pp_gch3 N(8), ;
     pp_garrrms N(8), pp_garrad N(8), pp_garrch1 N(8), pp_garrch2 N(8), pp_garrch3 N(8), ;
     pp_gdeprms N(8), pp_gdepad N(8), pp_gdepch1 N(8), pp_gdepch2 N(8), pp_gdepch3 N(8), ;
     pp_dhg1 B(2), pp_dhg2 B(2), pp_dhg3 B(2), pp_dhg4 B(2), pp_dhg5 B(2), ;
     pp_dhg6 B(2), pp_dhg7 B(2), pp_dhg8 B(2), pp_dhg9 B(2), pp_dhg0 B(2), ;
     pp_ohg1 B(2), pp_ohg2 B(2), pp_ohg3 B(2), pp_ohg4 B(2), pp_ohg5 B(2), ;
     pp_ohg6 B(2), pp_ohg7 B(2), pp_ohg8 B(2), pp_ohg9 B(2), pp_ohg0 B(2), pp_date d)
INDEX ON DTOS(pp_date)+pp_code TAG pp_code
ENDPROC
*
PROCEDURE PpCursorInit
LPARAMETERS tcLabel, tcAvailFilter
LOCAL lcQuery, lnMaxRooms, lnYear, lnMonth, ldStartDay, ldEndDay
LOCAL ARRAY laRooms(1)

IF tcLabel = "RATECOD"  && Preiscode
     lcQuery = "SELECT DISTINCT rc_ratecod FROM ratecode WHERE NOT rc_inactiv"
ELSE
     * Marketcode and Herkunfscode
     lcQuery = "SELECT DISTINCT pl_charcod FROM picklist WHERE pl_label = " + SqlCnv(tcLabel) + " AND NOT pl_inactiv"
ENDIF
SELECT [*****] AS pp_code FROM param UNION &lcQuery ORDER BY 1 INTO CURSOR Query


LOCAL lcurDates
lcurDates = MakeDatesCursor(Min1, Max1)

lnYear = YEAR(min1)
lnMonth = MONTH(min1)

SELECT (lcurDates)
SCAN ALL
     ldStartDay = c_date
     ldEndDay = c_date
     SELECT COUNT(*) ;
          FROM Room ;
          INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp ;
          WHERE INLIST(rt_group,1,4) AND rt_vwsum ;
          INTO ARRAY laRooms
     lnMaxRooms = laRooms(1) * (ldEndDay - ldStartDay + 1)

     SELECT SUM(MIN(oo_todat-1,ldEndDay)-MAX(oo_fromdat,ldStartDay)+1) FROM OutOfOrd ;
          INNER JOIN Room ON rm_roomnum = oo_roomnum ;
          INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp AND INLIST(rt_group,1,4) AND rt_vwsum ;
          WHERE oo_fromdat <= ldEndDay AND oo_todat > ldStartDay AND NOT oo_cancel ;
     INTO ARRAY laRooms
     lnMaxRooms = lnMaxRooms - laRooms(1)
     INSERT INTO PreProc (pp_code, pp_year, pp_month, pp_maxrms, pp_date) SELECT pp_code, lnYear, lnMonth, lnMaxRooms, &lcurDates..c_date FROM Query
ENDSCAN



DClose(lcurDates)

*!*     INSERT INTO PreProc (pp_date, pp_maxrms, pp_ydate, pp_ymaxrms) ;
*!*          SELECT c_date, laRooms(1), DATE(YEAR(c_date)-1,MONTH(c_date),DAY(c_date)), laRooms(1) FROM &lcurDates
*!*     DClose(lcurDates)






*!*     lnYear = YEAR(min1)
*!*     lnMonth = MONTH(min1)
*!*     DO WHILE DATE(lnYear, lnMonth, 1) <= max1
*!*          ldStartDay = MAX(Min1,DATE(lnYear, lnMonth, 1))
*!*          ldEndDay = MIN(Max1,DATE(lnYear, lnMonth, LastDay(DATE(lnYear,lnMonth,1))))
*!*          SELECT COUNT(*) ;
*!*               FROM Room ;
*!*               INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp ;
*!*               WHERE INLIST(rt_group,1,4) AND rt_vwsum ;
*!*               INTO ARRAY laRooms
*!*          lnMaxRooms = laRooms(1) * (ldEndDay - ldStartDay + 1)

*!*          SELECT SUM(MIN(oo_todat-1,ldEndDay)-MAX(oo_fromdat,ldStartDay)+1) FROM OutOfOrd ;
*!*               INNER JOIN Room ON rm_roomnum = oo_roomnum ;
*!*               INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp AND INLIST(rt_group,1,4) AND rt_vwsum ;
*!*               WHERE oo_fromdat <= ldEndDay AND oo_todat > ldStartDay AND NOT oo_cancel ;
*!*          INTO ARRAY laRooms
*!*          lnMaxRooms = lnMaxRooms - laRooms(1)

*!*          INSERT INTO PreProc (pp_code, pp_year, pp_month, pp_maxrms) SELECT pp_code, lnYear, lnMonth, lnMaxRooms FROM Query

*!*          IF lnMonth = 12
*!*               lnYear = lnYear + 1
*!*               lnMonth = 1
*!*          ELSE
*!*               lnMonth = lnMonth + 1
*!*          ENDIF
*!*     ENDDO

DClose("Query")
ENDPROC
*
PROCEDURE OccupancyRevenueGenerate
LPARAMETERS tcLabel

* Recalculating occupancy and revenue statistic in present.
SELECT curReservat
SCAN
     WAIT CLEAR
     WAIT WINDOW NOWAIT STR(rs_reserid, 12, 3)
     OrResUpd(tcLabel)
ENDSCAN
ENDPROC
*
PROCEDURE RevenueGenerate
LPARAMETERS tlWithoutVat
LOCAL lnAmount, lcPpField

SELECT curPost
SCAN FOR SEEK(DTOS(curPost.ps_date)+curPost.rescode, "PreProc", "pp_code") OR SEEK(DTOS(curPost.ps_date)+[*****], "PreProc", "pp_code")
     lcPpField = "pp_" + IIF(INLIST(resstatus, "OPT", "TEN"), "o", "d") + "hg" + STR(ar_main,1)
     lnAmount = ps_amount - IIF(tlWithoutVat, ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9, 0)
     REPLACE &lcPpField WITH &lcPpField + lnAmount * curPost.resrooms IN PreProc
ENDSCAN
ENDPROC
*
PROCEDURE OrResUpd
LPARAMETERS tcLabel
LOCAL lcCode, lnSelect, ldDate, llGetResState, llSharing, llStandard, loResrooms, lcResRooms, lcResRate
LOCAL lnRooms, lcRoomtype, lcRoomnum, lcRatecode, lnRsAdults, lnRsChilds1, lnRsChilds2, lnRsChilds3

DO CASE
     CASE tcLabel = "MARKET"
          lcCode = curReservat.rs_market
     CASE tcLabel = "SOURCE"
          lcCode = curReservat.rs_source
     CASE tcLabel = "RATECOD"
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
               lnRooms = curReservat.rs_rooms * ICASE(NOT EMPTY(lcRoomnum), Get_rm_rmname(lcRoomnum, "rm_roomocc"), llStandard, 1, 0)
          ELSE
               llStandard = .F.
               lnRooms = 0
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
     IF tcLabel = "RATECOD"
          lcCode = PADR(CHRTRAN(lcRatecode,"*!",""),10)
     ENDIF

     IF NOT (llSharing OR EMPTY(lnRooms) AND EMPTY(lnRsAdults) AND EMPTY(lnRsChilds1) AND EMPTY(lnRsChilds2) AND EMPTY(lnRsChilds3)) AND ;
               SEEK(DTOS(ldDate)+lcCode, "PreProc", "pp_code") OR SEEK(DTOS(ldDate)+[*****], "PreProc", "pp_code")
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
                    IF INLIST(curReservat.rs_status, "OPT", "TEN")
                         REPLACE pp_rmsopt WITH pp_rmsopt + lnRooms IN PreProc
                    ELSE
                         REPLACE pp_rms WITH pp_rms + lnRooms IN PreProc
                    ENDIF
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
DEFINE CLASS _fc06000 AS Session

PROCEDURE Init
Ini()
OpenFile()
PpCursorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER tlWithoutVat, tcLabel, tcResFilter, tcAvailFilter, taPreProc
LOCAL lcHResFilter, lcCodeField, lcCodeHField, lcCodeSField, lcVatnumMacro

PpCursorInit(tcLabel, tcAvailFilter)

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

lcCodeField = IIF(tcLabel = "RATECOD", "ps_ratecod", "NVL(rs1.rs_" + tcLabel + ",rs2.rs_" + tcLabel + ")")
lcCodeHField = IIF(tcLabel = "RATECOD", "hp_ratecod", "NVL(hr1.hr_" + tcLabel + ",hr2.hr_" + tcLabel + ")")
lcCodeSField = IIF(tcLabel = "RATECOD", "rl_ratecod", "rs_" + tcLabel)
lcVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")
SELECT NVL(ar_main,0) AS ar_main, ps_date, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ;
       IIF(ps_origid<1, 001, NVL(NVL(rs1.rs_rooms,rs2.rs_rooms),000)) AS resrooms, IIF(ps_origid<1, [OUT], NVL(NVL(rs1.rs_status,rs2.rs_status),[   ])) AS resstatus, ;
       PADR(NVL(IIF(ps_origid<1 OR EMPTY(&lcCodeField), .NULL., &lcCodeField),'*****'),10) AS rescode ;
     FROM post ;
     LEFT JOIN reservat rs1 ON rs1.rs_reserid = ps_origid ;
     LEFT JOIN reservat rs2 ON rs2.rs_reserid = ps_reserid ;
     LEFT JOIN article ON ps_artinum = ar_artinum ;
     WHERE ps_reserid > 0 AND BETWEEN(ps_date, min1, max1) AND ;
          NOT EMPTY(ps_artinum) AND ar_artityp = 1 AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), hp_date, hp_amount, hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, ;
       IIF(hp_origid<1, 001, NVL(NVL(hr1.hr_rooms,hr2.hr_rooms),000)), IIF(hp_origid<1, [OUT], NVL(NVL(hr1.hr_status,hr2.hr_status),[   ])), ;
       PADR(NVL(IIF(hp_origid<1 OR EMPTY(&lcCodeHField), .NULL., &lcCodeHField),'*****'),10) ;
     FROM histpost ;
     LEFT JOIN post ON ps_postid = hp_postid ;
     LEFT JOIN histres hr1 ON hr1.hr_reserid = hp_origid ;
     LEFT JOIN histres hr2 ON hr2.hr_reserid = hp_reserid ;
     LEFT JOIN article ON hp_artinum = ar_artinum ;
     WHERE hp_reserid > 0 AND BETWEEN(hp_date, min1, max1) AND ISNULL(ps_postid) AND ;
          NOT EMPTY(hp_artinum) AND ar_artityp = 1 AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), rl_date, rl_price*rl_units, IIF(NVL(ar_vat,0)=0,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=1,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=2,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=3,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=4,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=5,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=6,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=7,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=8,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=9,&lcVatnumMacro,0), ;
       NVL(rs_rooms,000), NVL(rs_status,[   ]), PADR(NVL(IIF(EMPTY(&lcCodeSField), .NULL., &lcCodeSField),'*****'),10) ;
     FROM ressplit ;
     LEFT JOIN reservat ON rs_rsid = rl_rsid ;
     LEFT JOIN article ON rl_artinum = ar_artinum ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rl_date > rs_ratedat AND BETWEEN(rl_date, min1, max1) AND ar_artityp = 1 AND NOT EMPTY(rl_price*rl_units) AND NOT INLIST(rs_status, "OUT", "CXL", "NS", "LST") AND ;
          (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter ;
     INTO CURSOR curPost

OccupancyRevenueGenerate(tcLabel)
RevenueGenerate(tlWithoutVat)

SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE