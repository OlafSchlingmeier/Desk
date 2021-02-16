DEFINE CLASS csqldef AS Custom

PROCEDURE Release
RELEASE this
ENDPROC
*
PROCEDURE GetSqlStatment
LPARAMETERS pcname, poparam
LOCAL cmacro, lsuccess, csql

lsuccess = .T.
IF odbc()
     cmacro = "csql = this." + pcname + "_odbc(@poparam)"
ELSE
     cmacro = "csql = this." + pcname + "_vfp(@poparam)"
ENDIF
TRY
     &cmacro
CATCH
     lsuccess = .F.
ENDTRY
IF lsuccess
	csql = STRTRAN(csql, ";", "") && Remove ; line breaks, to allow macro execution
ELSE
     csql = ""
ENDIF

RETURN csql
ENDPROC
*
PROCEDURE GetParamsObj
LPARAMETERS puparam1, puparam2, puparam3, puparam4, puparam5, puparam6, puparam7, puparam8, puparam9
LOCAL oParams, i, cmacro

oParams = CREATEOBJECT("Collection")
FOR i = 1 TO PCOUNT()
     cmacro = "puparam" + TRANSFORM(i)
     oParams.Add(&cmacro)
ENDFOR

RETURN oParams
ENDPROC
*
PROCEDURE getrentobjectdata_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect, l_cWhere
* oParam.Item(1) - cBuilding
* oParam.Item(2) - dFromDate
* oParam.Item(3) - dToDate

IF EMPTY(oParam.Item(4))
     l_cWhere = sqlcnv(.T.)
ELSE
     l_cWhere = "as_roomtyp = " + sqlcnv(oParam.Item(4))
ENDIF
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT as_date, SUM(as_rooms) AS maxrooms, SUM(as_rooms - as_pick) AS freerooms ;
          FROM althead ;
          INNER JOIN altsplit ON as_altid = al_altid ;
          WHERE al_buildng = <<sqlcnv(oParam.Item(1),.T.)>> AND ;
          BETWEEN(STR(as_altid,8)+DTOS(as_date), ;
                 STR(al_altid,8)+DTOS(<<sqlcnv(oParam.Item(2),.T.)>>), ;
                 STR(al_altid,8)+DTOS(<<sqlcnv(oParam.Item(3),.T.)>>)) AND ;
                 <<l_cWhere>>
          GROUP BY as_date
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getrentobjectdata_sql_odbc
LPARAMETERS oParam
LOCAL cSqlSelect
* oParam.Item(1) - cBuilding
* oParam.Item(2) - dFromDate
* oParam.Item(3) - dToDate

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT as_date, SUM(as_rooms) AS maxrooms, SUM(as_rooms - as_pick) AS freerooms ;
          FROM althead ;
          INNER JOIN altsplit ON as_altid = al_altid ;
          WHERE al_buildng = <<sqlcnv(oParam.Item(1),.T.)>> AND ;
          CAST(as_altid AS Char(10)) || CAST(as_date AS Char(10)) 
          BETWEEN 
          al_altid || <<sqlcnv(oParam.Item(2),.T.)>> AND 
          al_altid || <<sqlcnv(oParam.Item(3),.T.)>> 
          GROUP BY as_date
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getallotmentdata_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect, cWhere
* oParam.Item(1) - nEventIntId
* oParam.Item(2) - nRoomTypeId
* oParam.Item(3) - cCompany
* oParam.Item(4) - cGuest

cWhere = "ei_eiid = " + SqlCnv(oParam.Item(1))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(2)), "", "rt_rdid = " + SqlCnv(oParam.Item(2),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(3)) AND EMPTY(oParam.Item(4)), "", ;
	"EXISTS(SELECT * FROM reservat WHERE rs_altid = althead.al_altid AND rs_company = " + SqlCnv(oParam.Item(3),.T.) + " AND rs_lname = " + SqlCnv(oParam.Item(4),.T.) + ")"))
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT al_altid, bu_lang<<g_langnum>> AS bu_lang, al_buildng, al_fromdat, al_todat, al_note, ev_name, ev_city, ei_from, ei_to, as_date, ;
		SUM(as_rooms) AS maxrooms, SUM(as_rooms - as_pick) AS freerooms, SUM(as_pick) AS pickrooms FROM altsplit ;
		INNER JOIN roomtype ON rt_roomtyp = as_roomtyp ;
		INNER JOIN althead ON al_altid = as_altid ;
		INNER JOIN evint ON ei_eiid = al_eiid ;
		INNER JOIN events ON ev_evid = ei_evid ;
		INNER JOIN building ON bu_buildng = al_buildng ;
		WHERE <<cWhere>> ;
		GROUP BY al_altid, bu_lang, al_buildng, al_fromdat, al_todat, ev_name, ev_city, ei_from, ei_to, as_date
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getallotmentdata_sql_odbc
LPARAMETERS oParam
LOCAL cSqlSelect, l_cWhere
* oParam.Item(1) - nEventIntId
* oParam.Item(2) - nRoomTypeId
* oParam.Item(3) - cCompany
* oParam.Item(4) - cGuest

cWhere = "ei_eiid = " + SqlCnv(oParam.Item(1))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(2)), "", "rt_rdid = " + SqlCnv(oParam.Item(2),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(3)) AND EMPTY(oParam.Item(4)), "", ;
	"EXISTS(SELECT * FROM reservat WHERE rs_altid = althead.al_altid AND rs_company = " + SqlCnv(oParam.Item(3),.T.) + " AND rs_lname = " + SqlCnv(oParam.Item(4),.T.) + ")"))

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT al_altid, bu_lang<<g_langnum>> AS bu_lang, al_buildng, al_fromdat, al_todat, al_note, ev_name, ev_city, ei_from, ei_to, as_date, ;
		SUM(as_rooms) AS maxrooms, SUM(as_rooms - as_pick) AS freerooms, SUM(as_pick) AS pickrooms FROM altsplit ;
		INNER JOIN roomtype ON rt_roomtyp = as_roomtyp ;
		INNER JOIN althead ON al_altid = as_altid ;
		INNER JOIN evint ON ei_eiid = al_eiid ;
		INNER JOIN events ON ev_evid = ei_evid ;
		INNER JOIN building ON bu_buildng = al_buildng ;
		WHERE <<cWhere>> ;
		GROUP BY al_altid, bu_lang, al_buildng, al_fromdat, al_todat, ev_name, ev_city, ei_from, ei_to, as_date
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE geteventintervaldata_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect, l_cWhere
* oParam.Item(1) - dForDate
* oParam.Item(2) - nEventIntId

IF EMPTY(oParam.Item(2))
	l_cWhere = ""
ELSE
	l_cWhere = "AND al_eiid = " + SqlCnv(oParam.Item(2),.T.)
ENDIF
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT as_roomtyp, as_altid, SUM(as_rooms) AS maxrooms, SUM(as_pick) AS pickrooms, SUM(as_rooms - as_pick) AS freerooms ;
		FROM altsplit ;
		INNER JOIN althead ON al_altid = as_altid ;
		WHERE as_date = <<SqlCnv(oParam.Item(1),.T.)>> <<l_cWhere>> ;
		GROUP BY as_roomtyp, as_altid
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE geteventintervaldata_sql_odbc
LPARAMETERS oParam
LOCAL cSqlSelect, l_cWhere
* oParam.Item(1) - dForDate
* oParam.Item(2) - nEventIntId

IF EMPTY(oParam.Item(2))
	l_cWhere = ""
ELSE
	l_cWhere = "AND al_eiid = " + SqlCnv(oParam.Item(2),.T.)
ENDIF
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT as_roomtyp, as_altid, SUM(as_rooms) AS maxrooms, SUM(as_pick) AS pickrooms, SUM(as_rooms - as_pick) AS freerooms ;
		FROM altsplit ;
		INNER JOIN althead ON al_altid = as_altid ;
		WHERE as_date = <<SqlCnv(oParam.Item(1),.T.)>> <<l_cWhere>> ;
		GROUP BY as_roomtyp, as_altid
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getallotavaildata_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect
* oParam.Item(1) - dForDate
* oParam.Item(2) - nAllotId

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT as_roomtyp, as_altid, SUM(as_rooms) AS maxrooms, SUM(as_pick) AS pickrooms, SUM(as_rooms - as_pick) AS freerooms FROM altsplit ;
		WHERE STR(as_altid,8)+DTOS(as_date) = <<SqlCnv(STR(oParam.Item(2),8)+DTOS(oParam.Item(1)),.T.)>> AND as_roomtyp <> <<SqlCnv("*",.T.)>> ;
		GROUP BY as_roomtyp, as_altid
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getallotavaildata_sql_odbc
LPARAMETERS oParam
LOCAL cSqlSelect
* oParam.Item(1) - dForDate
* oParam.Item(2) - nAllotId

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT as_roomtyp, as_altid, SUM(as_rooms) AS maxrooms, SUM(as_pick) AS pickrooms, SUM(as_rooms - as_pick) AS freerooms FROM altsplit ;
		WHERE as_date = <<SqlCnv(oParam.Item(1),.T.)>> AND as_altid = <<SqlCnv(oParam.Item(2),.T.)>> AND as_roomtyp <> <<SqlCnv("*",.T.)>> ;
		GROUP BY as_roomtyp, as_altid
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getrentobjavaildata_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect, l_cWhere
* oParam.Item(1) - dForDate
* oParam.Item(2) - nRentObjId

IF EMPTY(oParam.Item(2))
	l_cWhere = ""
ELSE
	l_cWhere = "AND al_buildng = " + SqlCnv(oParam.Item(2),.T.)
ENDIF
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT as_roomtyp, as_altid, SUM(as_rooms) AS maxrooms, SUM(as_pick) AS pickrooms, SUM(as_rooms - as_pick) AS freerooms FROM altsplit ;
		INNER JOIN althead ON al_altid = as_altid ;
		WHERE as_date = <<SqlCnv(oParam.Item(1),.T.)>> <<l_cWhere>> ;
		GROUP BY as_roomtyp, as_altid
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getrentobjavaildata_sql_odbc
LPARAMETERS oParam
LOCAL cSqlSelect, l_cWhere
* oParam.Item(1) - dForDate
* oParam.Item(2) - nRentObjId

IF EMPTY(oParam.Item(2))
	l_cWhere = ""
ELSE
	l_cWhere = "AND al_buildng = " + SqlCnv(oParam.Item(2),.T.)
ENDIF
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT as_roomtyp, as_altid, SUM(as_rooms) AS maxrooms, SUM(as_pick) AS pickrooms, SUM(as_rooms - as_pick) AS freerooms FROM altsplit ;
		INNER JOIN althead ON al_altid = as_altid ;
		WHERE as_date = <<SqlCnv(oParam.Item(1),.T.)>> <<l_cWhere>> ;
		GROUP BY as_roomtyp, as_altid
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getavailcursor_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect, l_cJoin, l_cFromDate, l_cToDate, l_cRoomtype
* oParam.Item(1) - dFromDate
* oParam.Item(2) - dToDate
* oParam.Item(3) - cRoomtype
* oParam.Item(4) - lAllDates

l_cFromDate = IIF(EMPTY(oParam.Item(1)), "", DTOS(oParam.Item(1)))
l_cToDate = IIF(EMPTY(oParam.Item(2)), "", DTOS(oParam.Item(2)))
l_cRoomtype = oParam.Item(3)

IF oParam.Item(4)
	l_cJoin = ""
ELSE
	* don't show dates without allotments with events
	l_cJoin = "INNER JOIN altsplit ON av_date = as_date INNER JOIN althead ON as_altid = al_altid AND al_eiid > 0"
ENDIF

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT DISTINCT av_date FROM availab ;
		<<l_cJoin>> ;
		WHERE av_roomtyp+DTOS(av_date) >= [<<l_cRoomtype>><<l_cFromDate>>] AND av_roomtyp+DTOS(av_date) <= [<<l_cRoomtype>><<l_cToDate>>] ;
		ORDER BY av_date
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getavailcursor_sql_odbc
LPARAMETERS oParam
LOCAL cSqlSelect, l_cWhere, l_cJoin
* oParam.Item(1) - dFromDate
* oParam.Item(2) - dToDate
* oParam.Item(3) - cRoomtype
* oParam.Item(4) - lAllDates

l_cWhere = "av_roomtyp = " + SqlCnv(oParam.Item(3),.T.)
l_cWhere = SqlAnd(l_cWhere, IIF(EMPTY(oParam.Item(1)), "", "av_date >= " + SqlCnv(oParam.Item(1),.T.)))
l_cWhere = SqlAnd(l_cWhere, IIF(EMPTY(oParam.Item(2)), "", "av_date <= " + SqlCnv(oParam.Item(2),.T.)))

IF oParam.Item(4)
	l_cJoin = ""
ELSE
	* don't show dates without allotments with events
	l_cJoin = "INNER JOIN altsplit ON av_date = as_date INNER JOIN althead ON as_altid = al_altid AND al_eiid > 0"
ENDIF

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT DISTINCT av_date FROM availab ;
		<<l_cJoin>> ;
		WHERE <<l_cWhere>> ;
		ORDER BY av_date
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getreservationforallot_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect
* oParam.Item(1) - nAllotId

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT NVL(rs_reserid,0) AS rs_reserid, al_fromdat, al_todat, al_buildng FROM althead ;
		LEFT JOIN reservat ON al_altid = rs_altid ;
		LEFT JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
		WHERE al_altid = <<SqlCnv(INT(oParam.Item(1)),.T.)>>
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getreservationforallot_sql_odbc
LPARAMETERS oParam
LOCAL cSqlSelect
* oParam.Item(1) - nAllotId

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT rs_reserid, al_fromdat, al_todat, al_buildng FROM reservat ;
		LEFT JOIN althead ON al_altid = rs_altid ;
		LEFT JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
		WHERE rs_altid = <<SqlCnv(INT(oParam.Item(1)),.T.)>> AND rs_status NOT IN ('CXL', 'NS') AND rt_group <> 2
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getallotforreser_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect
* oParam.Item(1) - dArrival
* oParam.Item(2) - dDeparture

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT al_altid, al_fromdat, al_todat, bu_lang<<g_langnum>> AS bu_lang, bu_buildng, ;
		rt_roomtyp, rd_lang<<g_langnum>> AS rd_lang, rd_roomtyp, rm_roomnum, rm_lang<<g_langnum>> AS rm_lang, rm_rmname FROM althead ;
		INNER JOIN building ON bu_buildng = al_buildng ;
		LEFT JOIN altsplit ON as_altid = al_altid ;
		INNER JOIN roomtype ON rt_roomtyp = as_roomtyp ;
		INNER JOIN rtypedef ON rd_rdid = rt_rdid ;
		LEFT JOIN room ON rm_roomtyp = rt_roomtyp ;
		WHERE as_roomtyp <> [*] AND al_fromdat <= <<SqlCnv(oParam.Item(1),.T.)>> AND al_todat >= <<SqlCnv(oParam.Item(2)-1,.T.)>> ;
		GROUP BY al_fromdat, al_todat, al_altid, bu_lang, bu_buildng, rd_roomtyp, rt_roomtyp, rd_lang, rm_rmname, rm_lang, rm_roomnum
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getevents_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT ev_name AS EventName, ev_city AS EventCity, ei_from, ei_to, ei_eiid, UPPER(ev_name) ;
		FROM evint ;
		INNER JOIN events ON ev_evid = ei_evid ;
		WHERE ei_to >= <<SqlCnv(SysDate(),.T.)>> ;
		UNION SELECT "" AS EventName, "" AS EventCity, {} AS ei_from, {} AS ei_to, 0 AS ei_eiid, "" FROM param ;
		ORDER BY 6, ei_from
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE getroomtypes_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect

TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT rd_roomtyp, rd_lang<<g_langnum>> AS lang, IIF(rt_sequenc=0,99,rt_sequenc) AS sequenc, rd_rdid FROM roomtype ;
		LEFT JOIN rtypedef ON rd_rdid = rt_rdid ;
		GROUP BY rd_roomtyp, lang, sequenc ;
		UNION SELECT "" AS rd_roomtyp, "" AS lang, 0 AS sequenc, 0 AS rd_rdid FROM roomtype ;
		ORDER BY sequenc
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE geteventsforname_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect, cWhere
* oParam.Item(1) - dFromDate
* oParam.Item(2) - dToDate
* oParam.Item(3) - nRoomtype ID
* oParam.Item(4) - cCompany
* oParam.Item(5) - cGuest

cWhere = SqlAnd("rs_altid > 0", IIF(EMPTY(oParam.Item(2)), "", "ei_from <= " + SqlCnv(oParam.Item(2),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(1)), "", "ei_to >= " + SqlCnv(oParam.Item(1),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(3)), "", "rt_rdid = " + SqlCnv(oParam.Item(3),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(4)), "", "rs_company = " + SqlCnv(oParam.Item(4),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(5)), "", "rs_lname = " + SqlCnv(oParam.Item(5),.T.)))
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT DISTINCT ev_name AS EventName, ei_from, ei_to, ;
		ev_city AS EventCity, ei_eiid, UPPER(ev_name) ;
		FROM reservat ;
		INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp ;
		INNER JOIN althead ON rs_altid = al_altid ;
		INNER JOIN evint ON al_eiid = ei_eiid ;
		INNER JOIN events ON ei_evid = ev_evid ;
		WHERE <<cWhere>> ORDER BY 4
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
PROCEDURE geteventsforperiod_sql_vfp
LPARAMETERS oParam
LOCAL cSqlSelect
* oParam.Item(1) - dFromDate
* oParam.Item(2) - dToDate
* oParam.Item(3) - nRoomtypeID

cWhere = SqlAnd(".T.", IIF(EMPTY(oParam.Item(2)), "", "ei_from <= " + SqlCnv(oParam.Item(2),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(1)), "", "ei_to >= " + SqlCnv(oParam.Item(1),.T.)))
cWhere = SqlAnd(cWhere, IIF(EMPTY(oParam.Item(3)), "", "rt_rdid = " + SqlCnv(oParam.Item(3),.T.)))
TEXT TO cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT DISTINCT ev_name AS EventName, ei_from, ei_to, ;
		ev_city AS EventCity, ei_eiid, UPPER(ev_name) ;
		FROM evint ;
		INNER JOIN events ON ei_evid = ev_evid ;
		INNER JOIN althead ON ei_eiid = al_eiid ;
		INNER JOIN altsplit ON al_altid = as_altid ;
		INNER JOIN roomtype ON as_roomtyp = rt_roomtyp ;
		WHERE <<cWhere>> ORDER BY 4
ENDTEXT

RETURN cSqlSelect
ENDPROC
*
ENDDEFINE