*PROCEDURE ProcRoom
ENDPROC
*
DEFINE CLASS chousekeeping AS cbobj OF commonclasses.prg
*
HIDDEN ocaroom
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS chousekeeping OF procroom.prg
#ENDIF
*
dSysDate = {}
cArrText = ""
cDepText = ""
cOcc = ""

WherecStatus = ""
WherecMaid = ""
WherecRoomtype = ""
WherecBuilding = ""
WherecRoom = ""
WherenFloor = .NULL.
croomcur = ""
cOneRoomCur = ""
cCurResList = ""
cCurResActions = ""
ocaroom = .NULL.
oLogger = .NULL.
*
PROCEDURE Init
DODEFAULT()
this.oLogger = CREATEOBJECT("proclogger")
this.oLogger.cTable = "room"
this.oLogger.cKeyExp = "rm_roomnum"
this.cArrText = GetLangText("HOUSE","TXT_ARRIVAL")
this.cDepText = GetLangText("HOUSE","TXT_DEPARTURE")
this.cOcc = GetLangText("HOUSE","TXT_OCCUPIED")
this.cOneRoomCur = SYS(2015)
this.cCurResList = SYS(2015)
this.cCurResActions = SYS(2015)
ENDPROC
*
PROCEDURE ListGet
LPARAMETERS lp_cWhere, lp_lGetMinibarPostings
LOCAL l_cSql, l_cArrText, l_cDepText, l_cOcc, l_nSelect, l_cCur, l_lSuccess, l_cWhere, l_cDescript, l_dArrDate, l_dDepDate, l_cGuest, l_cMiniBar, l_cAction, l_cResFix, l_nRsId
l_nSelect = SELECT()
this.dSysDate = sysdate()

IF NOT (openfile(,"room") AND openfile(,"param") AND openfile(,"roomtype") AND openfile(,"rtypedef") AND openfile(,"action") ;
          AND openfile(,"reservat") AND openfile(,"post") AND openfile(,"article") AND openfile(,"address") AND openfile(,"apartner"))
     RETURN l_lSuccess
ENDIF

IF EMPTY(lp_cWhere)
     l_cWhere = this.GetRoomTypeFilter()
     IF NOT EMPTY(this.WherecRoomtype)
          PRIVATE p_cRoomtype
          p_cRoomtype = this.WherecRoomtype
          l_cWhere = l_cWhere + " AND rt_roomtyp = __SQLPARAM__p_cRoomtype"
     ELSE
          IF NOT EMPTY(this.WherecBuilding)
               PRIVATE p_cBuilding
               p_cBuilding = this.WherecBuilding
               l_cWhere = l_cWhere + " AND rt_buildng = __SQLPARAM__p_cBuilding"
          ENDIF
     ENDIF
     IF NOT EMPTY(this.WherecStatus)
          PRIVATE p_cStatus
          p_cStatus = this.WherecStatus
          l_cWhere = l_cWhere + " AND rm_status = __SQLPARAM__p_cStatus"
     ENDIF
     IF NOT EMPTY(this.WherecMaid)
          PRIVATE p_cMaid
          p_cMaid = ALLTRIM(this.WherecMaid) + "%"
          l_cWhere = l_cWhere + " AND rm_maid LIKE __SQLPARAM__p_cMaid"
     ENDIF
     IF NOT ISNULL(this.WherenFloor)
          PRIVATE p_nFloor
          p_nFloor = this.WherenFloor
          l_cWhere = l_cWhere + " AND rm_floor = __SQLPARAM__p_nFloor"
     ENDIF
     IF NOT EMPTY(this.WherecRoom)
          PRIVATE p_cRoom
          p_cRoom = PADR(ALLTRIM(this.WherecRoom),10)
          l_cWhere = l_cWhere + " AND rm_rmname = __SQLPARAM__p_cRoom"
     ENDIF
ELSE
     l_cWhere = lp_cWhere
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT *, CAST ('' AS Char(27)) AS c_descript, ;
          CAST ('' AS Char(14)) AS c_rtbld, ;
          CAST ({} AS Date) AS c_arrdate, ;
          CAST ({} AS Date) AS c_depdate, ;
          CAST ('' AS Char(50)) AS c_guest, ;
          CAST ('' AS Memo) AS c_minibar, ;
          CAST ('' AS Char(250)) AS c_action, ;
          CAST ('' AS Char(250)) AS c_resfix, ;
          CAST ('' AS Char(1)) AS c_repair, ;
          CAST ('' AS Integer) AS c_rsid ;
     FROM ( ;
     SELECT DISTINCT CAST(IIF(rm_rmname='          ',rm_roomnum,rm_rmname) AS Char(10)) AS rm_rmname, rd_roomtyp, <<"rm_lang" + g_langnum>> AS c_lang, rm_floor, rm_status, rm_maid, rm_comment, rm_roomnum, rm_rpseq, ;
          rm_roomtyp ;
          FROM room ;
          INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp ;
          INNER JOIN rtypedef ON rt_rdid = rd_rdid ;
          WHERE <<l_cWhere>> ;
          ORDER BY 9,1,2,3,4,5,6,7,8,10 
) AS c1
ENDTEXT
l_cCur = sqlcursor(l_cSql,this.cListCur,.F.,"",.NULL.,.T.,,.T.)
l_lSuccess = NOT EMPTY(l_cCur) AND USED(l_cCur)
IF l_lSuccess
     this.cListCur = l_cCur
     this.GetReservationsForRooms()

     SELECT (l_cCur)
     SCAN ALL
          STORE "" TO l_dArrDate, l_dDepDate, l_cGuest, l_cMiniBar, l_cAction
          l_nRsId = 0
          l_cDescript = this.ms_occupied(rm_roomnum, @l_dArrDate, @l_dDepDate, @l_cGuest, lp_lGetMinibarPostings, @l_cMiniBar, @l_cAction, @l_cResFix, @l_nRsId)
          IF NOT EMPTY(l_cDescript)
               REPLACE c_descript WITH l_cDescript
          ENDIF
          IF NOT EMPTY(l_dArrDate)
               REPLACE c_arrdate WITH l_dArrDate
          ENDIF
          IF NOT EMPTY(l_dDepDate)
               REPLACE c_depdate WITH l_dDepDate
          ENDIF
          IF NOT EMPTY(l_cGuest)
               REPLACE c_guest WITH l_cGuest
          ENDIF
          IF NOT EMPTY(l_cMiniBar)
               REPLACE c_minibar WITH l_cMiniBar
          ENDIF
          IF NOT EMPTY(l_cAction)
               REPLACE c_action WITH l_cAction
          ENDIF
          IF NOT EMPTY(l_cResFix)
               REPLACE c_resfix WITH l_cResFix
          ENDIF
          IF NOT EMPTY(dlookup("action","at_compl = {} AND at_roomnum = '" + rm_roomnum + "'","at_roomnum"))
               REPLACE c_repair WITH "1"
          ENDIF
          REPLACE c_rtbld WITH Get_rt_roomtyp(rm_roomtyp)
          REPLACE c_rsid WITH l_nRsId
     ENDSCAN
     this.Export(this.cListCur)
     DClose(this.cCurResList)
     DClose(this.cCurResActions)
ENDIF
SELECT (l_nSelect)
RETURN l_lSuccess
ENDPROC
*
&& GetRoomTypeFilter returns filter for rooms.
&& He checks in citadel.ini [system] housekeepingroomtypefilter setting, and when not empty
&& he checks if valid rtypedef.rt_roomtyp values are entered, separated with commas.
PROCEDURE GetRoomTypeFilter
LOCAL l_cFilter, l_nNumberOfRoomTypes, i, l_cOneRoomType, l_nRdId, l_cRdIdsList

* Main filter, can be expanded with housekeepingroomtypefilter setting
l_cFilter = "rt_group IN (1,4)"

IF EMPTY(_screen.oGlobal.cHouseKeepingRoomTypeFilter)
     RETURN l_cFilter
ENDIF

l_cRdIdsList = ""

l_nNumberOfRoomTypes = GETWORDCOUNT(_screen.oGlobal.cHouseKeepingRoomTypeFilter,",")

FOR i = 1 TO l_nNumberOfRoomTypes
     l_cOneRoomType = GETWORDNUM(_screen.oGlobal.cHouseKeepingRoomTypeFilter,i,",")
     IF NOT EMPTY(l_cOneRoomType)
          l_cOneRoomType = ALLTRIM(l_cOneRoomType)
          IF LEN(l_cOneRoomType)<=10
               l_cOneRoomType = PADR(l_cOneRoomType,10)
               l_nRdId = dlookup("rtypedef","rd_roomtyp = [" + l_cOneRoomType + "]","rd_rdid")
               IF NOT EMPTY(l_nRdId)
                    l_cRdIdsList = l_cRdIdsList + TRANSFORM(l_nRdId) + ","
               ENDIF
          ENDIF
     ENDIF
ENDFOR

IF NOT EMPTY(l_cRdIdsList)
     l_cRdIdsList = SUBSTR(l_cRdIdsList, 1, LEN(l_cRdIdsList)-1)
     l_cFilter = "(" + l_cFilter + " OR rd_rdid IN (" + l_cRdIdsList + "))"
ENDIF

RETURN l_cFilter
ENDPROC
*
PROCEDURE ListGetOneRoom
LPARAMETERS lp_cRoomNum
LOCAL l_cSql, l_nSelect, l_cCur, l_lSuccess, l_cDescript
l_nSelect = SELECT()
this.dSysDate = sysdate()
IF EMPTY(this.cOneRoomCur)
     this.cOneRoomCur = SYS(2015)
ENDIF
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT rm_roomnum, rm_status, rm_maid, rm_comment, CAST ('' AS Char(27)) AS c_descript 
     FROM room 
     WHERE rm_roomnum = <<sqlcnv(lp_cRoomNum,.T.)>> 
ENDTEXT
sqlcursor(l_cSql,this.cOneRoomCur,.F.,"",.NULL.,.T.,,.T.)
IF RECCOUNT()>0
     this.GetReservationsForRooms(rm_roomnum)
     l_cDescript = this.ms_occupied(rm_roomnum)
     IF NOT EMPTY(l_cDescript)
          REPLACE c_descript WITH l_cDescript IN (this.cOneRoomCur)
     ENDIF
     DClose(this.cCurResList)
     DClose(this.cCurResActions)
     l_lSuccess = .T.
ENDIF
SELECT (l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE GetReservationsForRooms
* Get reservations for rooms on sysdate()
LPARAMETERS lp_cRoomNum
LOCAL l_cSql, l_nSelect
l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT DISTINCT ri_roomnum AS rs_roomnum, rs_reserid, rs_status, rs_arrdate, rs_depdate, rs_in, rs_out, ;
          rs_addrid, rs_compid, rs_apname, rs_rsid, ;
          ad_lname, ad_fname, ad_title, ;
          ap_lname, ap_fname, ap_title ;
          FROM resrooms ;
          INNER JOIN reservat ON ri_reserid = rs_reserid ;
          INNER JOIN roomtype ON ri_roomtyp = rt_roomtyp ;
          INNER JOIN address ON rs_addrid = ad_addrid ;
          LEFT JOIN apartner ON rs_apid = ap_apid ;
          WHERE ri_date <= <<SqlCnv(this.dSysDate,.T.)>> AND ri_todate >= <<SqlCnv(this.dSysDate-1,.T.)>> ;
          <<IIF(EMPTY(lp_cRoomNum),""," AND ri_roomnum = "+sqlcnv(lp_cRoomNum,.T.))>> ; 
          AND rt_group IN (1,4) ;
          AND NOT rs_status IN ('NS','CXL')
ENDTEXT
sqlcursor(l_cSql,this.cCurResList,.F.,"",.NULL.,.T.,,.T.)
SELECT (this.cCurResList)
INDEX ON RS_IN + RS_ROOMNUM + RS_OUT TAG TAG6
INDEX ON DTOS(RS_DEPDATE)+RS_ROOMNUM TAG TAG9
INDEX ON RS_ROOMNUM+DTOS(RS_ARRDATE)+DTOS(RS_DEPDATE) TAG TAG13

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT DISTINCT NVL(rm1.rm_roomnum,NVL(rm2.rm_roomnum,"    ")) AS rs_roomnum, CAST(NVL(rs_reserid,0) AS Num(12,3)) AS rs_reserid, at_acttyp, at_date, at_note, CAST(NVL(pl_lang<<g_langnum>>,"") AS Char(25)) AS c_atlang
          FROM action
          LEFT JOIN picklist ON pl_label = 'ACTION' AND pl_charcod = at_acttyp
          LEFT JOIN room rm1 ON rm1.rm_roomnum = at_roomnum
          LEFT JOIN resrooms ON ri_reserid = at_reserid
          LEFT JOIN room rm2 ON rm2.rm_roomnum = ri_roomnum
          LEFT JOIN reservat ON ri_reserid = rs_reserid
          LEFT JOIN roomtype rt1 ON rt1.rt_roomtyp = rm1.rm_roomtyp
          LEFT JOIN roomtype rt2 ON rt2.rt_roomtyp = rm2.rm_roomtyp
          WHERE (NOT EMPTY(at_roomnum) OR at_date BETWEEN ri_date AND ri_todate AND NOT rs_status IN ('NS','CXL'))
          <<IIF(EMPTY(lp_cRoomNum),""," AND at_roomnum = "+sqlcnv(lp_cRoomNum,.T.))>>
          AND NVL(rt1.rt_group,NVL(rt2.rt_group,0)) IN (1,4)
          ORDER BY 1
ENDTEXT
sqlcursor(l_cSql,this.cCurResActions,,,,,,.T.)
INDEX ON rs_roomnum+STR(rs_reserid,12,3)+DTOS(at_date) TAG Tag1

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ms_occupied
LPARAMETERS lp_cRoomNum, lp_dArrDate, lp_dDepDate, lp_cGuest, lp_lGetMinibarPostings, lp_cMiniBar, lp_cAction, lp_cResFix, lp_nRsId
LOCAL l_cDescipt, l_cResCur, l_cCurResActions
l_cResCur = this.cCurResList
l_cCurResActions = this.cCurResActions

l_cDescipt = ""
lp_cGuest = ""
lp_cMiniBar = ""
lp_cAction = ""
lp_cResFix = ""
lp_dArrDate = {}
lp_dDepDate = {}
lp_nRsId = 0

DO CASE
     CASE EMPTY(lp_cRoomNum)
     CASE SEEK(lp_cRoomNum+DTOS(this.dSysDate),l_cResCur,"tag13")
          l_cDescipt = this.cArrText + " ("+TRIM(&l_cResCur..rs_status)+")"
          lp_dArrDate = &l_cResCur..rs_arrdate
          lp_dDepDate = &l_cResCur..rs_depdate
          lp_cGuest = IIF(&l_cResCur..rs_addrid = &l_cResCur..rs_compid AND NOT ISNULL(&l_cResCur..ap_lname) AND NOT EMPTY(&l_cResCur..rs_apname), ;
                          ALLTRIM(&l_cResCur..ap_title) + " " + ALLTRIM(&l_cResCur..ap_lname), ;
                          ALLTRIM(&l_cResCur..ad_title) + " " + ALLTRIM(&l_cResCur..ad_lname))
          IF lp_lGetMinibarPostings
               lp_cMiniBar = this.GetMiniBarPostings(&l_cResCur..rs_reserid)
          ENDIF
          IF SEEK(lp_cRoomNum+STR(&l_cResCur..rs_reserid,12,3)+DTOS(this.dSysDate),l_cCurResActions,"tag1")
               lp_cAction = &l_cCurResActions..at_note
          ENDIF
          lp_cResFix = this.GetResFixRecords(&l_cResCur..rs_reserid)
          lp_nRsId = &l_cResCur..rs_rsid
     CASE SEEK(DTOS(this.dSysDate)+lp_cRoomNum,l_cResCur,"tag9")
          l_cDescipt = this.cDepText + " ("+TRIM(&l_cResCur..rs_status)+")"
          lp_dArrDate = &l_cResCur..rs_arrdate
          lp_dDepDate = &l_cResCur..rs_depdate
          lp_cGuest = IIF(&l_cResCur..rs_addrid = &l_cResCur..rs_compid AND NOT ISNULL(&l_cResCur..ap_lname) AND NOT EMPTY(&l_cResCur..rs_apname), ;
                          ALLTRIM(&l_cResCur..ap_title) + " " + ALLTRIM(&l_cResCur..ap_lname), ;
                          ALLTRIM(&l_cResCur..ad_title) + " " + ALLTRIM(&l_cResCur..ad_lname))
          IF lp_lGetMinibarPostings
               lp_cMiniBar = this.GetMiniBarPostings(&l_cResCur..rs_reserid)
          ENDIF
          IF SEEK(lp_cRoomNum+STR(&l_cResCur..rs_reserid,12,3)+DTOS(this.dSysDate),l_cCurResActions,"tag1")
               lp_cAction = &l_cCurResActions..at_note
          ENDIF
          lp_cResFix = this.GetResFixRecords(&l_cResCur..rs_reserid)
          lp_nRsId = &l_cResCur..rs_rsid
     CASE SEEK("1"+lp_cRoomNum,l_cResCur,"tag6") AND EMPTY(&l_cResCur..rs_out)
          l_cDescipt = this.cOcc + " ("+LTRIM(STR(this.dSysDate-&l_cResCur..rs_arrdate))+")"
          lp_dArrDate = &l_cResCur..rs_arrdate
          lp_dDepDate = &l_cResCur..rs_depdate
          lp_cGuest = IIF(&l_cResCur..rs_addrid = &l_cResCur..rs_compid AND NOT ISNULL(&l_cResCur..ap_lname) AND NOT EMPTY(&l_cResCur..rs_apname), ;
                          ALLTRIM(&l_cResCur..ap_title) + " " + ALLTRIM(&l_cResCur..ap_lname), ;
                          ALLTRIM(&l_cResCur..ad_title) + " " + ALLTRIM(&l_cResCur..ad_lname))
          IF lp_lGetMinibarPostings
               lp_cMiniBar = this.GetMiniBarPostings(&l_cResCur..rs_reserid)
          ENDIF
          IF SEEK(lp_cRoomNum+STR(&l_cResCur..rs_reserid,12,3)+DTOS(this.dSysDate),l_cCurResActions,"tag1")
               lp_cAction = &l_cCurResActions..at_note
          ENDIF
          lp_cResFix = this.GetResFixRecords(&l_cResCur..rs_reserid)
          lp_nRsId = &l_cResCur..rs_rsid
ENDCASE
IF EMPTY(lp_cAction) AND SEEK(lp_cRoomNum+STR(0,12,3)+DTOS(this.dSysDate),l_cCurResActions,"tag1")
     lp_cAction = EVL(&l_cCurResActions..at_note,ALLTRIM(&l_cCurResActions..c_atlang)+" ("+&l_cCurResActions..at_acttyp+")")
ENDIF

RETURN l_cDescipt
ENDPROC
*
PROCEDURE GetMiniBarPostings
LPARAMETERS lp_nReserId
LOCAL l_cCur, l_nSelect, l_cMiniBar
l_nSelect = SELECT()
l_cMiniBar = ""
l_cCur = sqlcursor("SELECT ar_lang" + g_langnum + " AS c_article, ps_units AS c_qty, ps_time AS c_time " + ;
     "FROM post INNER JOIN article ON ps_artinum = ar_artinum AND ar_cmhkord <> 0 WHERE ps_reserid = " + ;
     sqlcnv(lp_nReserId,.T.) + ;
     " AND ps_date = " + sqlcnv(sysdate(),.T.) + " AND NOT ps_cancel AND ps_userid = " + sqlcnv(cuSerid,.T.) + " ORDER BY ps_time DESC")
IF NOT EMPTY(l_cCur)
     IF USED(l_cCur)
          SELECT (l_cCur)
          SCAN ALL
               l_cMiniBar = l_cMiniBar + PADL(INT(c_qty),2) + " x " + ALLTRIM(c_article) + " (" + c_time + ")" + CHR(13) + CHR(10)
          ENDSCAN
          dclose(l_cCur)
     ENDIF
ENDIF
SELECT (l_nSelect)
RETURN l_cMiniBar
ENDPROC
*
PROCEDURE GetResFixRecords
LPARAMETERS lp_nReserId
LOCAL l_cResFix, l_nSelect, l_cSql, l_cCur
l_cResFix = ""
l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT DISTINCT ar_lang<<g_langnum>> AS c_article, rf_units AS c_qty 
          FROM reservat 
          INNER JOIN resfix ON rs_reserid = rf_reserid 
          INNER JOIN article ON rf_artinum = ar_artinum 
          WHERE rs_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND (rs_arrdate + rf_day = <<sqlcnv(sysdate(),.T.)>> OR rf_alldays) AND rf_showhk 
          ORDER BY 1 ASC 
ENDTEXT
l_cCur = sqlcursor(l_cSql)
IF NOT EMPTY(l_cCur)
     IF USED(l_cCur)
          SELECT (l_cCur)
          SCAN ALL
               l_cResFix = l_cResFix + PADL(INT(c_qty),2) + " x " + ALLTRIM(c_article) + ", "
          ENDSCAN
          IF NOT EMPTY(l_cResFix)
               l_cResFix = SUBSTR(l_cResFix, 1, LEN(l_cResFix)-2)
          ENDIF
          dclose(l_cCur)
     ENDIF
ENDIF
SELECT (l_nSelect)
RETURN l_cResFix
ENDPROC
*
PROCEDURE PostMinibar
LPARAMETERS lp_cRoomId, lp_cArtiNum, lp_cQty, lp_cRsId
LOCAL l_lSuccess, l_nArea, l_nArtiNum, l_nQty, l_cSql, l_cRoom, l_cCur, l_cResponse, l_nNextFreeWindow, l_oData, l_oCA, l_nOrigId, l_nReserId, l_cVatMacro1, l_cVatMacro2
LOCAL ARRAY l_aVat(2,2)
STORE 0 TO l_nQty, l_nArtiNum
l_cResponse = ""
IF EMPTY(lp_cRoomId) OR EMPTY(lp_cArtiNum) OR EMPTY(lp_cQty)
     l_cResponse = GetLangText("HOUSE","TXT_ARTICLE_NOT_POSTED") + "! " +  GetLangText("MYLISTS","TA_NOTVALIDDEFINITION")
     RETURN this.PostMinibarResponse(l_lSuccess, l_cResponse)
ENDIF
IF VARTYPE(lp_cRoomId)<>"C" OR LEN(lp_cRoomId)>4
     l_cResponse = GetLangText("HOUSE","TXT_ARTICLE_NOT_POSTED") + "! " +  GetLangText("HOUSE","TXT_ROOM_IS_NOT_VALID")
     RETURN this.PostMinibarResponse(l_lSuccess, l_cResponse)
ENDIF
l_cRoom = lp_cRoomId
l_nArtiNum = INT(VAL(lp_cArtiNum))
IF EMPTY(l_nArtiNum) OR NOT BETWEEN(l_nArtiNum,1,9999)
     l_cResponse = GetLangText("HOUSE","TXT_ARTICLE_NOT_POSTED") + "! " +  GetLangText("HOUSE","TXT_PLU_IS_NOT_VALID")
     RETURN this.PostMinibarResponse(l_lSuccess, l_cResponse)
ENDIF
l_nQty = INT(VAL(lp_cQty))
IF EMPTY(l_nQty) OR NOT BETWEEN(l_nQty,1,999)
     l_cResponse = GetLangText("HOUSE","TXT_ARTICLE_NOT_POSTED") + "! " +  GetLangText("HOUSE","TXT_QTY_IS_NOT_VALID")
     RETURN this.PostMinibarResponse(l_lSuccess, l_cResponse)
ENDIF

l_nArea = SELECT()

l_cWhere = "rs_out = ' ' AND rs_in = '1' AND rs_roomnum = " + sqlcnv(l_cRoom,.T.)

IF NOT EMPTY(lp_cRsId)
     l_cWhere = "rs_rsid = " + ALLTRIM(lp_cRsId) + " AND " + l_cWhere
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT rm_rmname, rs_reserid, rs_roomnum, rs_lname, rs_billins 
     FROM reservat 
     LEFT JOIN room ON rs_roomnum = rm_roomnum 
     WHERE <<l_cWhere>>
ENDTEXT
l_cCur = SqlCursor(l_cSql)
IF RECCOUNT()>0
     l_nNextFreeWindow = PBGetFreeWindow(&l_cCur..rs_reserid,1,,.T.)
     IF l_nNextFreeWindow = 0
          l_cResponse = GetLangText("HOUSE","TXT_ARTICLE_NOT_POSTED") + "! " + Str2Msg(GetText("POSTPAY","TXT_ALL_BILS_ARE_CLOSED"), "%s", ALLTRIM(&l_cCur..rs_rmname))
     ELSE
          IF NOT USED("article")
               = openfile(,"article")
          ENDIF
          IF dlocate("article","ar_artinum = " + SqlCnv(l_nArtiNum))
               l_nOrigId = &l_cCur..rs_reserid
               l_nReserId = l_nOrigId
               l_oCA = CREATEOBJECT("capost")
               l_oCA.SetProp(.T.,.T.)
               l_oCA.CursorFill()
               SELECT (l_oCA.Alias)
               SCATTER NAME l_oData MEMO BLANK
               l_oData.ps_postid = nextid("POST")
               l_oData.ps_artinum = l_nArtiNum
               l_oData.ps_date = sysdate()
               l_oData.ps_window = l_nNextFreeWindow
               DO BillInstr IN BillInst WITH l_oData.ps_artinum, &l_cCur..rs_billins, l_nReserId, l_nNextFreeWindow
               IF l_nReserId <> l_nOrigId
                    l_oData.ps_supplem = Get_rm_rmname(&l_cCur..rs_roomnum) + " " + MakeProperName(&l_cCur..rs_lname)
               ENDIF
               l_oData.ps_reserid = l_nReserId
               l_oData.ps_origid = l_nOrigId
               l_oData.ps_time = TIME()
               l_oData.ps_price = article.ar_price
               l_oData.ps_units = l_nQty
               l_oData.ps_amount = l_oData.ps_price * l_nQty
               l_oData.ps_userid = cuSerid
               l_oData.ps_cashier = g_Cashier
               ProcBill("ArticeVatAmounts", l_oData.ps_artinum, l_oData.ps_amount, @l_aVat)
               l_cVatMacro1 = "l_oData.ps_vat" + LTRIM(STR(l_aVat(1,1)))
               l_cVatMacro2 = "l_oData.ps_vat" + LTRIM(STR(l_aVat(2,1)))
               &l_cVatMacro1 = l_aVat(1,2)
               &l_cVatMacro2 = l_aVat(2,2)
               INSERT INTO (l_oCA.Alias) FROM NAME l_oData
               l_oCA.DoTableUpdate(.T.,.T.,.T.)
               l_oCA.DClose()
               l_oCA = .NULL.
               IF article.ar_stckctl
                    REPLACE article.ar_stckcur WITH article.ar_stckcur-l_oData.ps_units IN article
                    FLUSH IN article
               ENDIF
               l_cResponse = TRANSFORM(l_nQty) + "x "+ALLTRIM(DLookup("article", "ar_artinum = " + SqlCnv(l_nArtiNum), "ar_lang" + g_Langnum))+" gebucht an Zimmer " +get_rm_rmname(lp_cRoomId)
               l_lSuccess = .T.
          ELSE
               l_cResponse = GetLangText("HOUSE","TXT_ARTICLE_NOT_POSTED") + "! " +  GetLangText("HOUSE","TXT_PLU_IS_NOT_VALID")
          ENDIF
     ENDIF
ELSE
     l_cResponse = GetLangText("HOUSE","TXT_ARTICLE_NOT_POSTED") + "! " +  GetLangText("PHONE","TXT_NOTCHECKEDIN")
     RETURN this.PostMinibarResponse(l_lSuccess, l_cResponse)
ENDIF

dclose(l_cCur)
SELECT (l_nArea)
RETURN this.PostMinibarResponse(l_lSuccess, l_cResponse)
ENDPROC
*
PROCEDURE PostMinibarResponse
LPARAMETERS lp_lSuccess, lp_cText
RETURN IIF(lp_lSuccess,"1","0")+lp_cText
ENDPROC
*
PROCEDURE PostRepair
LPARAMETERS lp_cRoomId, lp_cacttyp, lp_cuserid, lp_cDate, lp_cnote
LOCAL l_cResponse, l_lSuccess, l_dDate
l_cResponse = ""

lp_cRoomId = PADR(ALLTRIM(TRANSFORM(lp_cRoomId)),4)

IF EMPTY(lp_cRoomId) OR EMPTY(dlookup("room", "rm_roomnum = " + sqlcnv(lp_cRoomId,.T.),"rm_roomnum"))
     l_cResponse = GetLangText("HOUSE","TXT_NO_ROOM_WAS_SELECTED")
     RETURN this.PostRepairResponse(l_lSuccess, l_cResponse)
ENDIF

lp_cacttyp = PADR(ALLTRIM(TRANSFORM(lp_cacttyp)),3)

IF EMPTY(lp_cacttyp) OR EMPTY(dlookup("picklist", "pl_label = 'ACTION' AND pl_charcod = " + sqlcnv(lp_cacttyp,.T.),"pl_charcod"))
     l_cResponse = GetLangText("ACT","TA_TYPEREQ")
     RETURN this.PostRepairResponse(l_lSuccess, l_cResponse)
ENDIF

lp_cuserid = PADR(ALLTRIM(TRANSFORM(lp_cuserid)),10)

IF EMPTY(lp_cuserid) OR EMPTY(dlookup("user", "us_id = " + sqlcnv(lp_cuserid,.T.),"us_id"))
     l_cResponse = GetLangText("ACT","T_USER") + " " + GetLangText("RECURRES","TXT_NOT_VALID")
     RETURN this.PostRepairResponse(l_lSuccess, l_cResponse)
ENDIF

IF EMPTY(lp_cnote) OR VARTYPE(lp_cnote)<>"C"
     l_cResponse = GetLangText("ACT","T_NOTE") + " " + GetLangText("RECURRES","TXT_NOT_VALID")
     RETURN this.PostRepairResponse(l_lSuccess, l_cResponse)
ENDIF

l_dDate = this.PostRepairDate(ALLTRIM(TRANSFORM(lp_cDate)))

lp_cnote = STRTRAN(lp_cnote,CHR(4),CHR(13)+CHR(10))

l_nSelect = SELECT()

l_lSuccess = .T.
IF NOT USED("action")
     l_lSuccess = openfile(.F.,"action")
ENDIF

IF l_lSuccess
     SELECT action
     SCATTER MEMO NAME l_oActData BLANK
     l_oActData.at_roomnum = lp_cRoomId
     l_oActData.at_acttyp = lp_cacttyp
     l_oActData.at_userid = lp_cuserid
     l_oActData.at_date = l_dDate
     l_oActData.at_note = lp_cnote
     DO ActInsert IN procaction WITH l_oActData, "NEW","",.F.,,,.F.
     l_cResponse = GetLangText("COMMON","TXT_SAVED")
ENDIF

RETURN this.PostRepairResponse(l_lSuccess, l_cResponse)
ENDPROC
*
PROCEDURE PostRepairDate
LPARAMETERS lp_cDate
LOCAL l_dDate
l_dDate = sysdate()

IF NOT EMPTY(lp_cDate)
     * 31.12.2016
     TRY
          l_dDate = DATE(INT(VAL(SUBSTR(lp_cDate,7,4))), INT(VAL(SUBSTR(lp_cDate,4,2))), INT(VAL(SUBSTR(lp_cDate,1,2))))
     CATCH
     ENDTRY
ENDIF

RETURN l_dDate
ENDPROC
*
PROCEDURE PostRepairResponse
LPARAMETERS lp_lSuccess, lp_cText
RETURN IIF(lp_lSuccess,"1","0")+lp_cText
ENDPROC
*
PROCEDURE ActionTypesGet
LOCAL l_nArea
l_nArea = SELECT()

l_cCur = sqlcursor("SELECT pl_charcod, pl_lang" + g_langnum + " AS pl_lang FROM picklist WHERE pl_label = 'ACTION' ORDER BY 1")

this.Export(l_cCur)

dclose(l_cCur)

SELECT (l_nArea)
RETURN .T.
ENDPROC
*
PROCEDURE UsersGet
LOCAL l_nArea
l_nArea = SELECT()

l_cCur = sqlcursor("SELECT us_id, UPPER(us_name) AS us_name FROM user WHERE NOT us_inactiv ORDER BY 2")

this.Export(l_cCur)

dclose(l_cCur)

SELECT (l_nArea)
RETURN .T.
ENDPROC
*
PROCEDURE UpdateAll
LPARAMETERS lp_cNewStatus
LOCAL l_nArea, l_cWhere, l_cCaAlias, l_curRoom

IF EMPTY(lp_cNewStatus) OR NOT INLIST(lp_cNewStatus,"CLN","DIR")
     RETURN .F.
ENDIF

l_nArea = SELECT()

l_cWhere = ""
IF NOT EMPTY(this.WherecStatus)
     PRIVATE p_cStatus
     p_cStatus = this.WherecStatus
     l_cWhere = l_cWhere + " AND rm_status = __SQLPARAM__p_cStatus"
ENDIF
IF NOT EMPTY(this.WherecMaid)
     PRIVATE p_cMaid
     p_cMaid = this.WherecMaid
     l_cWhere = l_cWhere + " AND rm_maid = __SQLPARAM__p_cMaid"
ENDIF
IF NOT ISNULL(this.WherenFloor)
     PRIVATE p_nFloor
     p_nFloor = this.WherenFloor
     l_cWhere = l_cWhere + " AND rm_floor = __SQLPARAM__p_nFloor"
ENDIF

this.CheckCa()
this.cRoomCur = ""
l_cCaAlias = this.GetCaAlias()
l_curRoom = SqlCursor("SELECT rm_roomnum, rm_status FROM room WHERE NOT rm_status IN ('OOO','OOS')" + ;
	l_cWhere + " AND rm_roomtyp IN (SELECT rt_roomtyp FROM roomtype WHERE rt_group IN (1,4))")
SCAN
	IF this.RecGet(rm_roomnum)
		IF NOT (&l_cCaAlias..rm_status == lp_cNewStatus)
			REPLACE rm_status WITH lp_cNewStatus IN (l_cCaAlias)
			this.RecSave()
		ENDIF
	ENDIF
ENDSCAN

SELECT (l_nArea)

RETURN .T.
ENDPROC
*
PROCEDURE RecGet
LPARAMETERS lp_cId
LOCAL l_lSuccess, l_nArea
this.CheckCa()
IF EMPTY(lp_cId)
     RETURN l_lSuccess
ENDIF
l_nArea = SELECT()
this.ocaroom.cFilterClause = "rm_roomnum = " + sqlcnv(lp_cId, .T.)
l_lSuccess = this.ocaroom.CursorFill()
this.oLogger.SetOldval(this.ocaroom.Alias)
this.Export(this.cROOMCUR)
SELECT (l_nArea)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE RecSave
LOCAL l_lSuccess, l_cCur
this.CheckCa()
l_cCur = this.ocaroom.Alias
this.lvaliderr = .F.
this.cvaliderr = ""
l_lSuccess = .T.
this.Import(this.croomcur)
IF OLDVAL("rm_status",l_cCur) <> &l_cCur..rm_status AND (EMPTY(&l_cCur..rm_status) OR NOT INLIST(&l_cCur..rm_status,"DIR","CLN"))
     this.cvaliderr = GetLangText("BILL","T_NOTVALIDFIELDS ") + " " + &l_cCur..rm_status
     this.lvaliderr = .T.
     l_lSuccess = .F.
ENDIF

IF l_lSuccess AND OLDVAL("rm_status",l_cCur) <> &l_cCur..rm_status AND NOT INLIST(OLDVAL("rm_status",l_cCur),"DIR","CLN","   ")
     this.cvaliderr = strfmt(GetLangText("HOUSE","TXT_STATUS_NOT_ALLOWED"),OLDVAL("rm_status",l_cCur))
     this.lvaliderr = .T.
     l_lSuccess = .F.
ENDIF

IF l_lSuccess
     l_lSuccess = this.ocaroom.DoTableUpdate()
     this.oLogger.SetNewVal()
     this.oLogger.Save()
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE CheckCa
IF ISNULL(this.ocaroom)
     this.ocaroom = CREATEOBJECT("caroom")
     this.ocaroom.Alias = SYS(2015)
     this.croomcur = this.ocaroom.Alias
ENDIF
ENDPROC
*
PROCEDURE GetCaAlias
RETURN IIF(ISNULL(this.ocaroom), "", this.ocaroom.Alias)
ENDPROC
*
PROCEDURE Destroy
TRY
     this.oLogger.Release()
CATCH
ENDTRY
this.oLogger = .NULL.
DODEFAULT()
ENDPROC
*
ENDDEFINE
*