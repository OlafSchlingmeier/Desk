PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "11.30"
RETURN tcVersion
ENDPROC
*
* Sign '%' replaces string '<y><o><g><arr>'. So sign '%' is following strings '',  'arr',  'dep',  'g',  'garr',  'gdep',  'o',  'oarr',  'odep',  'og',  'ogarr',  'ogdep',
*                                                                            'y', 'yarr', 'ydep', 'yg', 'ygarr', 'ygdep', 'yo', 'yoarr', 'yodep', 'yog', 'yogarr', 'yogdep'
*      <y> - is '' for current year and 'y' for previous year
*      <o> - is 'o' for OPT and TEN reservations '' for other
*      <g> - is '' for all reservations and 'g' just for group reservations
*      <arr> - is 'arr' for arrivals, 'dep' for departures and '' staying days
#DEFINE pcFieldsRm     "pp_%rms, pp_%snglrms, pp_%dblrms, pp_%ad, pp_%ch1, pp_%ch2, pp_%ch3"
*
* Sign '%' replaces string '<y><o>'. So sign '%' is following strings 'd', 'o', 'yd', 'yo'
*      <y> - is '' for current year and 'y' for previous year
*      <o> - is 'o' for OPT and TEN reservations 'd' for other
*      'X' - is 0 - 9
#DEFINE pcFieldsRv     "pp_%sg1, pp_%hgX"
*
PROCEDURE fcx1001
LPARAMETERS tlWithoutVat, tcResFilter, tcAdrFilter
LOCAL loSession
LOCAL ARRAY laPreProc(1)

IF CheckExeVersion("9.10.349")
     WAIT WINDOW NOWAIT "Preprocessing..."

     loSession = CREATEOBJECT("_fc01000")
     loSession.DoPreproc(tlWithoutVat, tcResFilter, tcAdrFilter, @laPreProc)
     RELEASE loSession

     WAIT CLEAR
ENDIF

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
ENDPROC
**********
DEFINE CLASS _fc01000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("article,picklist,outoford,reservat,resrooms,resrate,histres,hresroom,hresrate,param,roomtype,room,resrmshr,post,histpost,ressplit,address", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _fc01000
          ENDTEXT
     ELSE
          PpCursorCreate()
     ENDIF
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS tlWithoutVat, tcResFilter, tcAdrFilter, taPreProc

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _fc01000 WITH <<SqlCnv(tlWithoutVat)>>, <<SqlCnv(tcResFilter)>>, <<SqlCnv(tcAdrFilter)>>
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          puSessionOrHotcode = this
          PpDo(tlWithoutVat, tcResFilter, tcAdrFilter)
     ENDIF

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
LOCAL i, j, k, l, lcFields, lcFieldsRm, lcFieldsRv, lcField

lcFieldsRm = ""
FOR i = 1 TO GETWORDCOUNT(pcFieldsRm, ",")
     lcField = ALLTRIM(GETWORDNUM(pcFieldsRm, i, ","))
     lcFieldsRm = lcFieldsRm + ", " + lcField + " N(8)"
NEXT
lcFieldsRv = ", " + ALLTRIM(GETWORDNUM(pcFieldsRv, 1, ",")) + " B(2)"
lcField = ALLTRIM(GETWORDNUM(pcFieldsRv, 2, ","))
FOR i = 0 TO 9
     lcFieldsRv = lcFieldsRv + ", " + STRTRAN(lcField, "X", TRANSFORM(i)) + " B(2)"
NEXT
lcFields = ""
FOR i = 1 TO 2
     FOR j = 1 TO 2
          FOR k = 1 TO 2
               FOR l = 1 TO 3
                    lcFields = lcFields + STRTRAN(lcFieldsRm, "%", IIF(i=1,"","y")+IIF(j=1,"","o")+IIF(k=1,"","g")+ICASE(l=2,"arr",l=3,"dep",""))
               NEXT
          NEXT
          lcFields = lcFields + STRTRAN(lcFieldsRv, "%", IIF(i=1,"","y")+IIF(j=1,"d","o"))
     NEXT
NEXT

CREATE CURSOR PreProc (ho_descrip C(100), ho_hotcode C(10), pp_date D, pp_maxrms N(8), pp_ydate D, pp_ymaxrms N(8) &lcFields)
INDEX ON pp_date TAG pp_date
INDEX ON pp_ydate TAG pp_ydate
SET ORDER TO
ENDPROC
*
PROCEDURE PpCursorGroup
LOCAL i, j, k, l, lcFields, lcFieldsRm, lcFieldsRv, lcField

lcFieldsRm = ""
FOR i = 1 TO GETWORDCOUNT(pcFieldsRm, ",")
     lcField = ALLTRIM(GETWORDNUM(pcFieldsRm, i, ","))
     lcFieldsRm = lcFieldsRm + ", SUM(" + lcField + ") AS " + lcField
NEXT
lcField = ALLTRIM(GETWORDNUM(pcFieldsRv, 1, ","))
lcFieldsRv = ", SUM(" + lcField + ") AS " + lcField
FOR i = 0 TO 9
     lcField = STRTRAN(ALLTRIM(GETWORDNUM(pcFieldsRv, 2, ",")), "X", TRANSFORM(i))
     lcFieldsRv = lcFieldsRv + ", SUM(" + lcField + ") AS " + lcField
NEXT
lcFields = ""
FOR i = 1 TO 2
     FOR j = 1 TO 2
          FOR k = 1 TO 2
               FOR l = 1 TO 3
                    lcFields = lcFields + STRTRAN(lcFieldsRm, "%", IIF(i=1,"","y")+IIF(j=1,"","o")+IIF(k=1,"","g")+ICASE(l=2,"arr",l=3,"dep",""))
               NEXT
          NEXT
          lcFields = lcFields + STRTRAN(lcFieldsRv, "%", IIF(i=1,"","y")+IIF(j=1,"d","o"))
     NEXT
NEXT

SELECT pp_date, pp_ydate, SUM(pp_maxrms) AS pp_maxrms, SUM(pp_ymaxrms) AS pp_ymaxrms &lcFields ;
     FROM PreProc ;
     GROUP BY pp_date, pp_ydate ;
     INTO CURSOR curPreProc READWRITE

SELECT PreProc
APPEND FROM DBF("curPreProc")

DClose("curPreProc")
ENDPROC
*
PROCEDURE PpCursorInit
LOCAL i, lcurDates
LOCAL ARRAY laRooms(1)

SELECT COUNT(*) ;
     FROM Room ;
     INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp ;
     WHERE (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND ;
           (EMPTY(min1) OR rt_roomtyp = min1) AND ;
           (EMPTY(min2) OR rm_roomnum = min2) AND ;
           INLIST(rt_group,1,4) AND rt_vwsum ;
     INTO ARRAY laRooms

lcurDates = MakeDatesCursor(pdStartDate, pdEndDate)
INSERT INTO PreProc (pp_date, pp_maxrms, pp_ydate, pp_ymaxrms) ;
     SELECT c_date, laRooms(1), DATE(YEAR(c_date)-1,MONTH(c_date),DAY(c_date)), laRooms(1) FROM &lcurDates
DClose(lcurDates)

DIMENSION laRooms(1)
SELECT oo_fromdat, oo_todat, oo_roomnum FROM OutOfOrd ;
     INNER JOIN Room ON rm_roomnum = oo_roomnum ;
     INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp AND INLIST(rt_group,1,4) AND rt_vwsum ;
     WHERE (oo_fromdat <= pdLyEndDate AND oo_todat > pdLyStartDate OR oo_fromdat <= pdEndDate AND oo_todat > pdStartDate) AND ;
     NOT oo_cancel AND ;
     (EVL(RptBulding,"*") = "*" OR rt_buildng = RptBulding) AND ;
     (EMPTY(min1) OR rt_roomtyp = min1) AND ;
     (EMPTY(min2) OR rm_roomnum = min2) ;
     INTO ARRAY laRooms
IF ALEN(laRooms) > 1
     FOR i = 1 TO ALEN(laRooms,1)
          UPDATE PreProc SET pp_maxrms = pp_maxrms - 1 WHERE BETWEEN(pp_date, laRooms(i,1), laRooms(i,2)-1)
          UPDATE PreProc SET pp_ymaxrms = pp_ymaxrms - 1 WHERE BETWEEN(pp_ydate, laRooms(i,1), laRooms(i,2)-1)
     NEXT
ENDIF
ENDPROC
*
PROCEDURE OccupancyGenerate
SELECT curReservat
SCAN
     IF plUseUI
          WAIT CLEAR
          WAIT WINDOW NOWAIT STR(rs_reserid, 12, 3)
     ENDIF
     OrResUpd()
ENDSCAN
ENDPROC
*
PROCEDURE RevnueGenerate
LPARAMETERS tlWithoutVat
LOCAL i, lnAmount, lcPpField, lcBuilding, lnSubGroup

lnSubGroup = 0 && Filter on some subgroup

SELECT curPost
SCAN ALL

     * Filter ob building

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

     * Filter on roomtype

     IF NOT EMPTY(min1) AND c_roomtyp <> min1
          LOOP
     ENDIF

     * Filter on room

     IF NOT EMPTY(min2) AND c_roomnum <> min2
          LOOP
     ENDIF

     FOR i = 1 TO 2
          DO CASE
               CASE i = 1 AND BETWEEN(ps_date, pdStartDate, pdEndDate) AND SEEK(curPost.ps_date, "PreProc", "pp_date")
                    * Update preproc if ps_date in current year
               CASE i = 2 AND BETWEEN(ps_date, pdLyStartDate, pdLyEndDate) AND SEEK(curPost.ps_date, "PreProc", "pp_ydate")
                    * Update preproc if ps_date in last year
               OTHERWISE
                    LOOP
          ENDCASE
          lcPpField = "pp_" + IIF(i=1, "", "y") + IIF(INLIST(resstatus, "OPT", "TEN"), "o", "d") + "hg" + STR(ar_main,1)
          lnAmount = ps_amount - IIF(tlWithoutVat, ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9, 0)
          REPLACE &lcPpField WITH &lcPpField + lnAmount * curPost.resrooms IN PreProc
          IF NOT EMPTY(lnSubGroup) AND ar_sub = lnSubGroup
               lcPpField = "pp_" + IIF(i=1, "", "y") + IIF(INLIST(resstatus, "OPT", "TEN"), "o", "d") + "sg1"
               REPLACE &lcPpField WITH &lcPpField + lnAmount * curPost.resrooms IN PreProc
          ENDIF
     NEXT
ENDSCAN
ENDPROC
*
PROCEDURE OrResUpd
LOCAL lnSelect, ldDate, llGetResState, loResrooms, lcResRooms, lcResRate
LOCAL lnReserid, lnRooms, lcBuildng, lcRoomtype, lcRoomnum, lnAdults, lnChilds1, lnChilds2, lnChilds3, llSharing, llStandard, llSingle
LOCAL i, j, k, l, lcPrefix, lcFldrms, lcFldsdrms, lcFldad, lcFldch1, lcFldch2, lcFldch3

lnSelect = SELECT()

IF curReservat.reshistory
     lcResRooms = "hresroom"
     lcResRate = "hresrate"
ELSE
     lcResRooms = "resrooms"
     lcResRate = "resrate"
ENDIF

ldDate = MAX(pdLyStartDate, curReservat.rs_arrdate)
DO WHILE ldDate <= MIN(pdEndDate, curReservat.rs_depdate)
     llGetResState = INLIST(ldDate, MAX(pdLyStartDate, curReservat.rs_arrdate), pdStartDate) OR ISNULL(loResrooms) OR NOT BETWEEN(ldDate, loResrooms.ri_date, loResrooms.ri_todate)
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

     DO CASE
          CASE NOT llStandard
               STORE 0 TO lnAdults, lnChilds1, lnChilds2, lnChilds3
          CASE SEEK(STR(curReservat.rs_reserid,12,3)+DTOS(ldDate), lcResRate, "tag2")
               lnAdults = curReservat.rs_rooms * &lcResRate..rr_adults
               lnChilds1 = curReservat.rs_rooms * &lcResRate..rr_childs
               lnChilds2 = curReservat.rs_rooms * &lcResRate..rr_childs2
               lnChilds3 = curReservat.rs_rooms * &lcResRate..rr_childs3
          OTHERWISE
               lnAdults = curReservat.rs_rooms * curReservat.rs_adults
               lnChilds1 = curReservat.rs_rooms * curReservat.rs_childs
               lnChilds2 = curReservat.rs_rooms * curReservat.rs_childs2
               lnChilds3 = curReservat.rs_rooms * curReservat.rs_childs3
     ENDCASE
     llSingle = ((lnAdults + lnChilds1 + lnChilds2 + lnChilds3) / curReservat.rs_rooms < 2)

     IF (EVL(RptBulding,"*") = "*" OR lcBuildng = RptBulding) AND ;
               (EMPTY(min1) OR lcRoomtype = min1) AND ;
               (EMPTY(min2) OR lcRoomnum = min2) AND ;
               NOT ((llSharing OR EMPTY(lnRooms)) AND EMPTY(lnAdults) AND EMPTY(lnChilds1) AND EMPTY(lnChilds2) AND EMPTY(lnChilds3))
          j = IIF(INLIST(curReservat.rs_status,"OPT","TEN"), 2, 1)     && Update OPT or DEF fields in preproc
          FOR i = 1 TO 2
               DO CASE
                    CASE i = 1 AND curReservat.rs_arrdate <= pdEndDate AND curReservat.rs_depdate >= pdStartDate AND SEEK(ldDate, "PreProc", "pp_date")
                         * Update preproc if date in current year
                    CASE i = 2 AND curReservat.rs_arrdate <= pdLyEndDate AND curReservat.rs_depdate >= pdLyStartDate AND SEEK(ldDate, "PreProc", "pp_ydate")
                         * Update preproc if date in last year
                    OTHERWISE
                         LOOP
               ENDCASE
               FOR k = 1 TO 2
                    DO CASE
                         CASE k = 1
                              * Always update preproc
                         CASE k = 2 AND NOT EMPTY(curReservat.rs_group)
                              * Update preproc only if reservation belongs to group
                         OTHERWISE
                              LOOP
                    ENDCASE
                    FOR l = 1 TO 3
                         DO CASE
                              CASE l = 1 AND ldDate < MIN(IIF(i=1,pdEndDate,pdLyEndDate)+1, curReservat.rs_depdate)
                                   * Update preproc if date belongs to interval
                              CASE l = 2 AND ldDate = curReservat.rs_arrdate
                                   * Update preproc if date is on arrival
                              CASE l = 3 AND ldDate = curReservat.rs_depdate
                                   * Update preproc if date is on departure
                              OTHERWISE
                                   LOOP
                         ENDCASE
                         lcPrefix = IIF(i=1,"","y") + IIF(j=1,"","o") + IIF(k=1,"","g") + ICASE(l=2,"arr",l=3,"dep","")
                         lcFldrms = STRTRAN("pp_%rms", "%", lcPrefix)
                         lcFldsdrms = STRTRAN("pp_%rms", "%", lcPrefix+IIF(llSingle,"sngl","dbl"))
                         lcFldad = STRTRAN("pp_%ad", "%", lcPrefix)
                         lcFldch1 = STRTRAN("pp_%ch1", "%", lcPrefix)
                         lcFldch2 = STRTRAN("pp_%ch2", "%", lcPrefix)
                         lcFldch3 = STRTRAN("pp_%ch3", "%", lcPrefix)
                         IF NOT llSharing
                              REPLACE &lcFldrms WITH &lcFldrms + lnRooms, ;
                                      &lcFldsdrms WITH &lcFldsdrms + lnRooms IN PreProc
                         ENDIF
                         REPLACE &lcFldad WITH &lcFldad + lnAdults, ;
                                 &lcFldch1 WITH &lcFldch1 + lnChilds1, ;
                                 &lcFldch2 WITH &lcFldch2 + lnChilds2, ;
                                 &lcFldch3 WITH &lcFldch3 + lnChilds3 IN PreProc
                    NEXT
               NEXT
          NEXT
     ENDIF
     ldDate = IIF(ldDate = pdLyEndDate AND pdLyEndDate < pdStartDate, pdStartDate, ldDate + 1)
ENDDO

SELECT (lnSelect)
ENDPROC
*
PROCEDURE PpDo
LPARAMETERS tlWithoutVat, tcResFilter, tcAdrFilter
LOCAL lcHResFilter, lcResFilterC, lcHResFilterC, lcAdrFilterC, lcVatnumMacro
PRIVATE pdStartDate, pdEndDate, pdLyStartDate, pdLyEndDate, plUseUI

plUseUI = (_VFP.StartMode < 3)     && Don't show WAIT WINDOW if called from IIS's ActiveVFP.dll
pdStartDate = min3
pdEndDate = max3
pdLyStartDate = GetRelDate(min3,"-1Y")
pdLyEndDate = GetRelDate(max3,"-1Y")

PpCursorInit()

IF VARTYPE(tcResFilter) # "C" OR EMPTY(tcResFilter)
     STORE ".T." TO tcResFilter, lcHResFilter, lcResFilterC, lcHResFilterC
ELSE
     lcResFilterC = StrToMsg("(%s1 OR %s2)", STRTRAN(tcResFilter, "rs_", "rs1.rs_"), STRTRAN(tcResFilter, "rs_", "rs2.rs_"))
     lcHResFilterC = StrToMsg("(%s1 OR %s2)", STRTRAN(tcResFilter, "rs_", "hr1.hr_"), STRTRAN(tcResFilter, "rs_", "hr2.hr_"))
     lcHResFilter = STRTRAN(tcResFilter, "rs_", "histres.hr_")
     tcResFilter = STRTRAN(tcResFilter, "rs_", "reservat.rs_")
ENDIF
IF VARTYPE(tcAdrFilter) # "C" OR EMPTY(tcAdrFilter)
     STORE ".T." TO tcAdrFilter, lcAdrFilterC
ELSE
     lcAdrFilterC = StrToMsg("(%s1 OR %s2)", STRTRAN(tcAdrFilter, "ad_", "ad1.ad_"), STRTRAN(tcAdrFilter, "ad_", "ad2.ad_"))
ENDIF
SELECT DISTINCT rs_rsid, rs_reserid, rs_arrdate, rs_depdate, rs_group, rs_roomtyp, rs_roomnum, rs_ratecod, rs_market, rs_source, rs_ratedat, rs_rooms, ;
       rs_adults, rs_childs, rs_childs2, rs_childs3, rs_status, .F. AS reshistory ;
     FROM reservat ;
     LEFT JOIN address ON ad_addrid = rs_addrid ;
     WHERE (rs_arrdate <= pdLyEndDate AND rs_depdate >= pdLyStartDate OR rs_arrdate <= pdEndDate AND rs_depdate >= pdStartDate) AND ;
          NOT INLIST(rs_status, "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter AND &tcAdrFilter ;
UNION ALL ;
SELECT DISTINCT hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_group, hr_roomtyp, hr_roomnum, hr_ratecod, hr_market, hr_source, hr_ratedat, hr_rooms, ;
       hr_adults, hr_childs, hr_childs2, hr_childs3, hr_status, .T. AS reshistory ;
     FROM histres ;
     LEFT JOIN reservat ON rs_reserid = hr_reserid ;
     LEFT JOIN address ON ad_addrid = hr_addrid ;
     WHERE hr_reserid >= 1 AND (hr_arrdate <= pdLyEndDate AND hr_depdate >= pdLyStartDate OR hr_arrdate <= pdEndDate AND hr_depdate >= pdStartDate) AND ISNULL(rs_reserid) AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND (hr_status <> "TEN" OR param.pa_tentdef) AND &lcHResFilter AND &tcAdrFilter ;
     ORDER BY 2 ;
     INTO CURSOR curReservat

lcVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")
SELECT NVL(ar_main,0) AS ar_main, NVL(ar_sub,0) AS ar_sub, ps_date, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ;
       CAST(NVL(NVL(NVL(ri1.ri_roomtyp,rs1.rs_roomtyp),NVL(ri2.ri_roomtyp,rs2.rs_roomtyp)),"") AS C(4)) AS c_roomtyp, ;
       CAST(NVL(NVL(NVL(ri1.ri_roomnum,rs1.rs_roomnum),NVL(ri2.ri_roomnum,rs2.rs_roomnum)),"") AS C(4)) AS c_roomnum, ;
       ar_buildng AS c_buildng, ;
       IIF(ps_origid<1 OR ps_rdate <= NVL(rs1.rs_ratedat,rs2.rs_ratedat), 001, NVL(NVL(rs1.rs_rooms,rs2.rs_rooms),000)) AS resrooms, ;
       IIF(ps_origid<1, [OUT], NVL(NVL(rs1.rs_status,rs2.rs_status),[   ])) AS resstatus ;
     FROM post ;
     LEFT JOIN reservat rs1 ON rs1.rs_reserid = ps_origid ;
     LEFT JOIN address ad1 ON ad1.ad_addrid = rs1.rs_addrid ;
     LEFT JOIN resrooms ri1 ON ri1.ri_reserid = ps_origid AND NOT EMPTY(ri1.ri_roomtyp) AND BETWEEN(EVL(ps_rdate,ps_date), ri1.ri_date, ri1.ri_todate) ;
     LEFT JOIN reservat rs2 ON rs2.rs_reserid = ps_reserid ;
     LEFT JOIN address ad2 ON ad2.ad_addrid = rs2.rs_addrid ;
     LEFT JOIN resrooms ri2 ON ri2.ri_reserid = ps_reserid AND NOT EMPTY(ri2.ri_roomtyp) AND BETWEEN(EVL(ps_rdate,ps_date), ri2.ri_date, ri2.ri_todate) ;
     LEFT JOIN article ON ps_artinum = ar_artinum ;
     WHERE ps_reserid > 0 AND (BETWEEN(ps_date, pdLyStartDate, pdLyEndDate) OR BETWEEN(ps_date, pdStartDate, pdEndDate)) AND ;
          NOT EMPTY(ps_artinum) AND ar_artityp = 1 AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) AND &lcResFilterC AND &lcAdrFilterC ;
UNION ALL ;
SELECT NVL(ar_main,0), NVL(ar_sub,0), hp_date, hp_amount, hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, ;
       NVL(NVL(NVL(ri1.ri_roomtyp,hr1.hr_roomtyp),NVL(ri2.ri_roomtyp,hr2.hr_roomtyp)),""), ;
       NVL(NVL(NVL(ri1.ri_roomnum,hr1.hr_roomnum),NVL(ri2.ri_roomnum,hr2.hr_roomnum)),""), ;
       ar_buildng, ;
       IIF(hp_origid<1 OR hp_rdate <= NVL(hr1.hr_ratedat,hr2.hr_ratedat), 001, NVL(NVL(hr1.hr_rooms,hr2.hr_rooms),000)), ;
       IIF(hp_origid<1, [OUT], NVL(NVL(hr1.hr_status,hr2.hr_status),[   ])) ;
     FROM histpost ;
     LEFT JOIN post ON ps_postid = hp_postid ;
     LEFT JOIN histres hr1 ON hr1.hr_reserid = hp_origid ;
     LEFT JOIN address ad1 ON ad1.ad_addrid = hr1.hr_addrid ;
     LEFT JOIN hresroom ri1 ON ri1.ri_reserid = hp_origid AND NOT EMPTY(ri1.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), ri1.ri_date, ri1.ri_todate) ;
     LEFT JOIN histres hr2 ON hr2.hr_reserid = hp_reserid ;
     LEFT JOIN address ad2 ON ad2.ad_addrid = hr2.hr_addrid ;
     LEFT JOIN hresroom ri2 ON ri2.ri_reserid = hp_reserid AND NOT EMPTY(ri2.ri_roomtyp) AND BETWEEN(EVL(hp_rdate,hp_date), ri2.ri_date, ri2.ri_todate) ;
     LEFT JOIN article ON hp_artinum = ar_artinum ;
     WHERE hp_reserid > 0 AND (BETWEEN(hp_date, pdLyStartDate, pdLyEndDate) OR BETWEEN(hp_date, pdStartDate, pdEndDate)) AND ISNULL(ps_postid) AND ;
          NOT EMPTY(hp_artinum) AND ar_artityp = 1 AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND &lcHResFilterC AND &lcAdrFilterC ;
UNION ALL ;
SELECT NVL(ar_main,0), NVL(ar_sub,0), rl_date, rl_price*rl_units, IIF(NVL(ar_vat,0)=0,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=1,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=2,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=3,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=4,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=5,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=6,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=7,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=8,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=9,&lcVatnumMacro,0), ;
       NVL(NVL(ri_roomtyp,rs_roomtyp),""), ;
       NVL(NVL(ri_roomnum,rs_roomnum),""), ;
       ar_buildng, ;
       NVL(rs_rooms,000), NVL(rs_status,[   ]) ;
     FROM ressplit ;
     LEFT JOIN reservat ON rs_rsid = rl_rsid ;
     LEFT JOIN address ON ad_addrid = rs_addrid ;
     LEFT JOIN resrooms ON ri_reserid = rs_reserid AND NOT EMPTY(ri_roomtyp) AND BETWEEN(rl_rdate, ri_date, ri_todate) ;
     LEFT JOIN article ON rl_artinum = ar_artinum ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rl_date > rs_ratedat AND (BETWEEN(rl_date, pdLyStartDate, pdLyEndDate) OR BETWEEN(rl_date, pdStartDate, pdEndDate)) AND ar_artityp = 1 AND NOT EMPTY(rl_price*rl_units) AND ;
          NOT INLIST(rs_status, "OUT", "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) AND &tcResFilter AND &tcAdrFilter ;
     INTO CURSOR curPost

OccupancyGenerate()
RevnueGenerate(tlWithoutVat)

DClose("curReservat")
DClose("curPost")
ENDPROC
*