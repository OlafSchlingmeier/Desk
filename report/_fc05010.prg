PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.10"
RETURN tcVersion
ENDPROC
*
* Sign '%' replaces string '<g><new>'. So sign '%' is following strings '',  'new',  'g',  'gnew'
*      <g> - is '' for all reservations and 'g' just for group reservations
*      <new> - is 'new' for new reservations and '' staying days
#DEFINE pcFieldsRm     "pp_%rms, pp_%ad, pp_%ch1, pp_%ch2, pp_%ch3"
*
* Sign '%' replaces string '<o>'. So sign '%' is following strings 'd', 'o'
*      <o> - is 'o' for OPT and TEN reservations 'd' for other
*      'X' - is 0 - 9
#DEFINE pcFieldsRv     "pp_%hgX"
*
PROCEDURE _fc05010
LPARAMETERS tlWithoutVat, tcType
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_fc05010")
loSession.DoPreproc(tlWithoutVat, tcType, @laPreProc)
RELEASE loSession

WAIT CLEAR

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
ENDPROC
**********
DEFINE CLASS _fc05010 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("ratecode,article,picklist,reservat,resrooms,resrate,histres,hresroom,hresrate,param,roomtype,rtypedef,building,room,resrmshr,post,histpost,ressplit", tcHotCode, tcPath)
     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpCursorCreate IN _fc05010
          ENDTEXT
     ELSE
          PpCursorCreate()
     ENDIF
ENDPROC
*
PROCEDURE DoPreproc
     LPARAMETERS tlWithoutVat, tcType, taPreProc

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _fc05010 WITH <<SqlCnv(tlWithoutVat)>>, <<SqlCnv(tcType)>>
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          puSessionOrHotcode = this
          PpDo(tlWithoutVat, tcType)
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
     FOR j = 1 TO 2
          lcFields = lcFields + STRTRAN(lcFieldsRm, "%", IIF(i=1,"","g")+IIF(j=1,"","new"))
     NEXT
NEXT
FOR i = 1 TO 2
     lcFields = lcFields + STRTRAN(lcFieldsRv, "%", IIF(i=1,"d","o"))
NEXT

CREATE CURSOR PreProc (pp_code C(14), pp_res N(8), pp_rev B(2) &lcFields)
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
     FOR j = 1 TO 2
          lcFields = lcFields + STRTRAN(", " + pcFieldsRm, "%", IIF(i=1,"","g")+IIF(j=1,"","new"))
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

SELECT pp_code, SUM(pp_res) AS pp_res, SUM(pp_rev) AS pp_rev &lcFieldsS ;
     FROM PreProc ;
     GROUP BY pp_code ;
     INTO CURSOR PreProc
ENDPROC
*
PROCEDURE PpCursorInit
LPARAMETERS tcLabel
LOCAL lcSql
LOCAL ARRAY laRooms(1)

DO CASE
     CASE tcLabel = "RATECOD"     && Preiscode
          lcSql = "SELECT DISTINCT rc_ratecod FROM ratecode WHERE NOT rc_inactiv"
     CASE tcLabel = "ROOMNUM"     && Zimmer
          lcSql = "SELECT rm_roomnum FROM room INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp WHERE INLIST(rt_group, 1, 4) AND rt_vwsum"
     CASE tcLabel = "ROOMTYP"     && Zimmertyp
          lcSql = "SELECT rt_roomtyp FROM roomtype WHERE INLIST(rt_group, 1, 4) AND rt_vwsum"
     OTHERWISE                    && Marketcode and Herkunfscode
          lcSql = "SELECT DISTINCT pl_charcod FROM picklist WHERE pl_label = " + SqlCnv(tcLabel) + " AND NOT pl_inactiv"
ENDCASE

SELECT [*****] AS pp_code FROM param UNION &lcSql ORDER BY 1 INTO CURSOR curPreProc

INSERT INTO PreProc (pp_code) SELECT pp_code FROM curPreProc

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
LOCAL lnAmount, lcPpField

SELECT curPost
SCAN FOR SEEK(curPost.rescode, "PreProc", "pp_code") OR SEEK([*****], "PreProc", "pp_code")
     lcPpField = "pp_" + IIF(INLIST(resstatus, "OPT", "TEN"), "o", "d") + "hg" + STR(ar_main,1)
     lnAmount = ps_amount - IIF(tlWithoutVat, ps_vat1+ps_vat2+ps_vat3+ps_vat4+ps_vat5+ps_vat6+ps_vat7+ps_vat8+ps_vat9, 0)
     REPLACE &lcPpField WITH &lcPpField + lnAmount * curPost.resrooms IN PreProc
ENDSCAN
ENDPROC
*
PROCEDURE OrResUpd
LPARAMETERS tcLabel
LOCAL lcCode, lnSelect, ldDate, ldFromDate, ldToDate, llGetResState, llSharing, llStandard, loResrooms, lcResRooms, lcResRate
LOCAL lnRooms, lcRoomtype, lcRoomnum, lcRatecode, lnRsAdults, lnRsChilds1, lnRsChilds2, lnRsChilds3

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

ldDate = curReservat.rs_arrdate
DO WHILE ldDate <= curReservat.rs_depdate
     llGetResState = (ldDate = curReservat.rs_arrdate) OR ISNULL(loResrooms) OR NOT BETWEEN(ldDate, loResrooms.ri_date, loResrooms.ri_todate)
     IF llGetResState
          RiGetRoom(curReservat.rs_reserid, ldDate, @loResrooms, lcResRooms)
          llSharing = NOT EMPTY(IIF(ISNULL(loResrooms), 0, loResrooms.ri_shareid))
          lcRoomtype = IIF(ISNULL(loResrooms), curReservat.rs_roomtyp, loResrooms.ri_roomtyp)
          lcRoomnum = IIF(ISNULL(loResrooms), curReservat.rs_roomnum, loResrooms.ri_roomnum)
          IF DLocate("roomtype", "rt_roomtyp = " + SqlCnv(lcRoomtype,.T.))
               llStandard = (roomtype.rt_group = 1 AND roomtype.rt_vwsum OR roomtype.rt_group = 4)
               lnRooms = curReservat.rs_rooms * ICASE(NOT EMPTY(lcRoomnum), Get_rm_rmname(lcRoomnum, "rm_roomocc", puSessionOrHotcode), llStandard, 1, 0)
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

     DO CASE
          CASE tcLabel = "RATECOD"
               lcCode = PADR(CHRTRAN(lcRatecode,"*!",""),10)
          CASE tcLabel = "ROOMNUM"
               lcCode = lcRoomnum
          CASE tcLabel = "ROOMTYP"
               lcCode = lcRoomtype
          OTHERWISE
     ENDCASE

     IF SEEK(lcCode, "PreProc", "pp_code") OR SEEK([*****], "PreProc", "pp_code")
          IF ldDate = curReservat.rs_arrdate
               REPLACE pp_res WITH pp_res + 1 IN PreProc
          ENDIF
          IF NOT (llSharing OR EMPTY(lnRooms) AND EMPTY(lnRsAdults) AND EMPTY(lnRsChilds1) AND EMPTY(lnRsChilds2) AND EMPTY(lnRsChilds3))
               IF ldDate = curReservat.rs_arrdate
                    IF NOT llSharing
                         REPLACE pp_newrms WITH pp_newrms + lnRooms IN PreProc
                    ENDIF
                    REPLACE pp_newad WITH pp_newad + lnRsAdults, ;
                            pp_newch1 WITH pp_newch1 + lnRsChilds1, ;
                            pp_newch2 WITH pp_newch2 + lnRsChilds2, ;
                            pp_newch3 WITH pp_newch3 + lnRsChilds3 IN PreProc
                    IF NOT EMPTY(curReservat.rs_group)
                         IF NOT llSharing
                              REPLACE pp_gnewrms WITH pp_gnewrms + lnRooms IN PreProc
                         ENDIF
                         REPLACE pp_gnewad WITH pp_gnewad + lnRsAdults, ;
                                 pp_gnewch1 WITH pp_gnewch1 + lnRsChilds1, ;
                                 pp_gnewch2 WITH pp_gnewch2 + lnRsChilds2, ;
                                 pp_gnewch3 WITH pp_gnewch3 + lnRsChilds3 IN PreProc
                    ENDIF
               ENDIF
               IF ldDate < curReservat.rs_depdate
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
     ENDIF
     ldDate = ldDate + 1
ENDDO

SELECT (lnSelect)
ENDPROC
*
PROCEDURE PpDo
LPARAMETERS tlWithoutVat, tcType
LOCAL lcLabel, lcCodeField, lcCodeHField, lcCodeSField, lcVatnumMacro, lcHotcode, lcArchScripts
PRIVATE plUseUI

plUseUI = (_VFP.StartMode < 3)     && Don't show WAIT WINDOW if called from IIS's ActiveVFP.dll

IF VARTYPE(tcType) # "C"
     tcType = "M"
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

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE hr_reserid >= 1 AND BETWEEN(hr_created, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>);

SELECT histpost.* FROM histpost
     INNER JOIN histres ON hr_reserid = hp_origid
     WHERE hp_reserid > 0 AND hr_reserid >= 1 AND BETWEEN(hr_created, <<SqlCnvB(min1)>>, <<SqlCnvB(max1)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, min1)
*
****************************************************************************************************

SELECT DISTINCT rs_rsid, rs_reserid, rs_arrdate, rs_depdate, rs_group, rs_roomtyp, rs_roomnum, rs_ratecod, rs_market, rs_source, rs_ratedat, rs_rooms, ;
       rs_adults, rs_childs, rs_childs2, rs_childs3, rs_status, .F. AS reshistory ;
     FROM reservat ;
     WHERE BETWEEN(rs_created, min1, max1) AND NOT INLIST(rs_status, "CXL", "NS", "LST") AND (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) ;
UNION ALL ;
SELECT DISTINCT hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_group, hr_roomtyp, hr_roomnum, hr_ratecod, hr_market, hr_source, hr_ratedat, hr_rooms, ;
       hr_adults, hr_childs, hr_childs2, hr_childs3, hr_status, .T. AS reshistory ;
     FROM histres ;
     LEFT JOIN reservat ON rs_reserid = hr_reserid ;
     WHERE hr_reserid >= 1 AND BETWEEN(hr_created, min1, max1) AND ISNULL(rs_reserid) AND ;
          NOT INLIST(hr_status, "CXL", "NS", "LST") AND (hr_status <> "OPT" OR param.pa_optidef) AND (hr_status <> "TEN" OR param.pa_tentdef) ;
     ORDER BY 2 ;
     INTO CURSOR curReservat

lcCodeField = IIF(lcLabel = "RATECOD", "ps_ratecod", "rs_" + lcLabel)
lcCodeHField = IIF(lcLabel = "RATECOD", "hp_ratecod", "hr_" + lcLabel)
lcCodeSField = IIF(lcLabel = "RATECOD", "rl_ratecod", "rs_" + lcLabel)
lcVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")
SELECT NVL(ar_main,0) AS ar_main, ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ;
       rs_rooms AS resrooms, rs_status AS resstatus, PADR(EVL(&lcCodeField,'*****'),10) AS rescode ;
     FROM post ;
     INNER JOIN reservat ON rs_reserid = ps_origid AND BETWEEN(rs_created, min1, max1) ;
     LEFT JOIN article ON ps_artinum = ar_artinum ;
     WHERE ps_reserid > 0 AND NOT EMPTY(ps_artinum) AND ar_artityp = 1 AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), hp_amount, hp_vat0, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9, ;
       hr_rooms, hr_status, PADR(EVL(&lcCodeHField,'*****'),10) ;
     FROM histpost ;
     LEFT JOIN post ON ps_postid = hp_postid ;
     INNER JOIN histres ON hr_reserid = hp_origid AND BETWEEN(hr_created, min1, max1) ;
     LEFT JOIN article ON hp_artinum = ar_artinum ;
     WHERE hp_reserid > 0 AND ISNULL(ps_postid) AND NOT EMPTY(hp_artinum) AND ar_artityp = 1 AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
UNION ALL ;
SELECT NVL(ar_main,0), rl_price*rl_units, IIF(NVL(ar_vat,0)=0,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=1,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=2,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=3,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=4,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=5,&lcVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=6,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=7,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=8,&lcVatnumMacro,0), IIF(NVL(ar_vat,0)=9,&lcVatnumMacro,0), ;
       rs_rooms, rs_status, PADR(EVL(&lcCodeSField,'*****'),10) ;
     FROM ressplit ;
     INNER JOIN reservat ON rs_rsid = rl_rsid AND BETWEEN(rs_created, min1, max1) ;
     LEFT JOIN article ON rl_artinum = ar_artinum ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rl_date > rs_ratedat AND ar_artityp = 1 AND NOT EMPTY(rl_price*rl_units) AND NOT INLIST(rs_status, "OUT", "CXL", "NS", "LST") AND ;
          (rs_status <> "OPT" OR param.pa_optidef) AND (rs_status <> "TEN" OR param.pa_tentdef) ;
     INTO CURSOR curPost

OccupancyRevenueGenerate(lcLabel)
RevenueGenerate(tlWithoutVat)

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************

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