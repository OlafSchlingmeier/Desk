*
#INCLUDE "include\constdefines.h"
*
FUNCTION RateCalculate
LPARAMETERS tdDate, tcRateCode, tcRoomType, tnAltId, tnRate, tnAdults, tnChilds, tnChilds2, tnChilds3, tdArrdate, tdDepdate, tcArrtime, tcDeptime, tcRcAlias

********************************************************************************************************************
*
* Don't forget to also change method ratecalculate in procyield class in common\libs\proc_yield.vcx file, in Desk !
*
********************************************************************************************************************

LOCAL lnRate, llFound, lnDOWcurrent, lnDOWarrival, ldDate, lnPeriods, lcAdFld, lcChFld, lnPersons, lnAddonPersons, lnAddonPrice, l_nSelect, l_cRoomCur

lnRate = tnRate
llFound = .F.
ldDate = IIF(EMPTY(tdDate), MIN(tdDepdate, MAX(tdArrdate, g_sysdate)), tdDate)
IF EMPTY(tcRcAlias)
	tcRcAlias = "RateCode"
ENDIF

IF LEFT(tcRateCode,1) = "!"	&& changed ratecode in allotments
	IF SEEK(tnAltId,"althead","tag1")
		IF SEEK(PADR(althead.al_altid,8)+DTOS(ldDate)+tcRoomType+STRTRAN(tcRateCode,"!"),"altsplit","tag2") OR ;
				SEEK(PADR(althead.al_altid,8)+DTOS(ldDate)+"*   "+STRTRAN(tcRateCode,"!"),"altsplit","tag2")
			IF tnAdults > 0
				IF tnAdults < 6
					lnRate = EVALUATE("AltSplit.as_rate" + TRANSFORM(tnAdults))
					IF lnRate = 0
						lnRate = tnAdults * AltSplit.as_rate1
					ENDIF
				ELSE
					lnRate = tnAdults * AltSplit.as_rate1
				ENDIF
			ELSE
				lnRate = 0
			ENDIF
			lnRate = lnRate + altsplit.as_crate1*tnChilds + altsplit.as_crate2*tnChilds2 + altsplit.as_crate3*tnChilds3
			llFound = .T.
		ENDIF
	ENDIF
ENDIF

IF NOT "*" $ tcRateCode AND NOT llFound
	lnRate = &tcRcAlias..rc_base
	lnDOWcurrent = DOW(ldDate, 2)
	lnDOWarrival = DOW(tdArrdate, 2)
	IF SUBSTR(&tcRcAlias..rc_weekend, lnDOWcurrent, 1) = '1' AND SUBSTR(&tcRcAlias..rc_closarr, lnDOWarrival, 1) = ' '
		IF NOT EMPTY(&tcRcAlias..rc_wbase)
			lnRate = &tcRcAlias..rc_wbase
		ENDIF
		lcAdFld = tcRcAlias+'.rc_wamnt'
		lcChFld = tcRcAlias+'.rc_wcamnt'
	ELSE
		lcAdFld = tcRcAlias+'.rc_amnt'
		lcChFld = tcRcAlias+'.rc_camnt'
	ENDIF
	IF NOT BETWEEN(tnAdults, 1, 5) OR EVALUATE(lcAdFld+TRANSFORM(tnAdults)) = 0
		lnRate = lnRate + EVALUATE(lcAdFld+'1')*IIF(_screen.oGlobal.oParam.pa_chkadts, MAX(tnAdults,1), tnAdults)
	ELSE
		lnRate = lnRate + EVALUATE(lcAdFld+TRANSFORM(MAX(tnAdults,1)))
	ENDIF
	IF tnChilds > 0
		lnRate = lnRate + EVALUATE(lcChFld+'1') * tnChilds
	ENDIF
	IF tnChilds2 > 0
		lnRate = lnRate + EVALUATE(lcChFld+'2') * tnChilds2
	ENDIF
	IF tnChilds3 > 0
		lnRate = lnRate + EVALUATE(lcChFld+'3') * tnChilds3
	ENDIF

	* When after some number of persons, additional charges per every next person are needed, as, for example, for additional bed charges, use ratecode table fields:
	* rm_beds - Number of persons after which additional charges apply
	* rc_adperra - Amount to add for every next person

	IF _screen.oGlobal.lAgency

		* Here lookup room table over rc_ratecod = rm_roomnum, and get min and max persons. Only price should be in ratecode.
		* rm_beds - Room standad occupancy
		* rm_bedchfr - Kleinkinder frei bis (one value from param.pa_childs: 0,1,2,3)

		IF &tcRcAlias..rc_adperra <> 0
			l_nSelect = SELECT()
			l_cRoomCur = sqlcursor("SELECT rm_beds, rm_bedchfr FROM room WHERE rm_rmname = '" + &tcRcAlias..rc_ratecod + "'")

			lnPersons = tnAdults + IIF(rm_bedchfr <> 1, tnChilds, 0) + IIF(rm_bedchfr <> 2, tnChilds2, 0) + IIF(rm_bedchfr <> 3, tnChilds3, 0)
			IF rm_beds > 0 AND lnPersons > rm_beds
				lnAddonPersons = lnPersons - rm_beds
				lnAddonPrice = &tcRcAlias..rc_adperra
				lnRate = lnRate + (lnAddonPersons * lnAddonPrice)
			ENDIF
			dclose(l_cRoomCur)
			SELECT (l_nSelect)
		ENDIF

	ENDIF
ENDIF

lnPeriods = 1
IF NOT EMPTY(tdDate)
	DO CASE
		CASE &tcRcAlias..rc_period = 1
			lnPeriods = Hours(tcArrtime, tcDeptime, tdArrdate, tdDepdate, tdDate)
		CASE &tcRcAlias..rc_period = 2
			lnPeriods = DayParts(tcArrtime, tcDeptime, tdArrdate, tdDepdate, tdDate)
	ENDCASE
ENDIF
lnRate = lnRate * lnPeriods
tnRate = lnRate

RETURN lnRate
ENDFUNC
*
FUNCTION RatecodeLocate
LPARAMETERS tdDate, tcRateCode, tcRoomType, tdArrdate, tdDepdate, tlCheckBlocked, tlSilent, tlFound, tlLogError, tlFindValidForRT
LOCAL lnArea, lnOrder, lnPeriod, lnRhytm, lcSeason, lcRateCode, lnRecnoRC, llPrivateResrateMessageContent, llFound, ldFirstRcDate

tlSilent = tlSilent OR g_lFakeResAndPost
tlFound = .F.
lcRateCode = PADR(CHRTRAN(tcRateCode,"!*",""),10)

IF NOT EMPTY(lcRateCode)
	lcSeason = ""
	lnArea = SELECT()
	SELECT ratecode
	lnOrder = ORDER()
	SET ORDER TO tag7 IN ratecode DESCENDING
	IF SEEK(lcRateCode, "ratecode")
		lnPeriod = ratecode.rc_period
		lnRhytm = ratecode.rc_rhytm
		SET ORDER TO tag7 IN ratecode ASCENDING
		lcSeason = DLookUp("season", "se_date = " + SqlCnv(tdDate), "se_season")
		llPrivateResrateMessageContent = " Ratecode %s1 hasn't been located in .DBF for key " + lcRateCode+PADR(tcRoomType,4)+TRANSFORM(tdArrdate)+ALLTRIM(lcSeason) + " for ReserId %s2 of date %s3!"
		DO WHILE NOT BOF("ratecode") AND ratecode.rc_ratecod = lcRateCode
			IF BETWEEN(tdDate, ratecode.rc_fromdat, ratecode.rc_todat - 1) AND INLIST(ratecode.rc_season, " ", lcSeason) AND ;
					INLIST(ratecode.rc_roomtyp, "*   ", PADR(tcRoomType,4))
				IF NOT ProcRatecode("RateBlocked", tdDate, tdArrdate, tdDepdate, tcRoomType)
					tlFound = .T.
					llPrivateResrateMessageContent = " Ratecode has been found."
					EXIT
				ELSE
					llFound = NOT tlCheckBlocked
					llPrivateResrateMessageContent = " Ratecode %s1 blocking conditions hasn't been applied for ReserId %s2 of date %s3!"
					IF EMPTY(lnRecnoRC)
						lnRecnoRC = RECNO("ratecode")
					ENDIF
				ENDIF
			ENDIF
			SKIP -1 IN ratecode
		ENDDO
		IF NOT tlFound AND llFound
			tlFound = .T.
			GO lnRecnoRC IN ratecode
		ENDIF
		IF tlFound AND INLIST(ratecode.rc_period, 6, 7) AND tdDate > tdArrdate
			* If reservation has one ratecode on stay and that ratecode expire during reservation but second ratecode with same name continues than always pick first ratecode.
			lnRecnoRC = RECNO("ratecode")
			llFound = .F.
			ldFirstRcDate = tdArrdate
			lcSeason = DLookUp("season", "se_date = " + SqlCnv(ldFirstRcDate), "se_season")
			DO WHILE NOT BOF("ratecode") AND ratecode.rc_ratecod = lcRateCode
				IF BETWEEN(ldFirstRcDate, ratecode.rc_fromdat, ratecode.rc_todat - 1) AND INLIST(ratecode.rc_season, " ", lcSeason) AND ;
						INLIST(PADR(ratecode.rc_roomtyp,4), "*   ", PADR(tcRoomType,4))
					IF NOT ProcRatecode("RateBlocked", ldFirstRcDate, tdArrdate, tdDepdate, tcRoomType)
						llFound = .T.
						EXIT
					ENDIF
				ENDIF
				SKIP -1 IN ratecode
			ENDDO
			IF NOT llFound
				GO lnRecnoRC IN ratecode
			ENDIF
		ENDIF
		IF NOT tlFound AND tlFindValidForRT
			IF (tlSilent OR YesNo(GetLangText("RESERVAT","TXT_MUST_CHANGE_RATECODE"))) AND SEEK(PADR(tcRoomType,4),"roomtype","tag1")
				SELECT ratecode
				IF EMPTY(roomtype.rt_ratecod)
					SET ORDER TO
					LOCATE FOR rc_roomtyp = roomtype.rt_roomtyp AND BETWEEN(tdDate, rc_fromdat, rc_todat-1) AND rc_period = lnPeriod AND rc_rhytm = lnRhytm
					IF NOT FOUND()
						LOCATE FOR rc_roomtyp = '*   ' AND BETWEEN(tdDate, rc_fromdat, rc_todat-1) AND rc_period = lnPeriod AND rc_rhytm = lnRhytm
					ENDIF
				ELSE
					SET ORDER TO tag7 DESCENDING
					IF SEEK(roomtype.rt_ratecod)
						LOCATE FOR BETWEEN(tdDate, rc_fromdat, rc_todat-1) AND INLIST(rc_roomtyp, "*   ", roomtype.rt_roomtyp) AND ;
							INLIST(ratecode.rc_season, " ", lcSeason) AND rc_period = lnPeriod AND rc_rhytm = lnRhytm ;
							WHILE rc_ratecod = roomtype.rt_ratecod
					ENDIF
					IF NOT FOUND() AND SEEK(roomtype.rt_ratecod)
						LOCATE FOR BETWEEN(tdDate, rc_fromdat, rc_todat-1) AND INLIST(rc_roomtyp, "*   ", roomtype.rt_roomtyp) AND ;
							rc_period = lnPeriod AND rc_rhytm = lnRhytm ;
							WHILE rc_ratecod = roomtype.rt_ratecod
					ENDIF
				ENDIF
				IF FOUND()
					tlFound = .T.
					tcRateCode = PADR(IIF(INLIST(LEFT(tcRateCode,1), "!", "*"), LEFT(tcRateCode,1), "") + rc_ratecod,10)
				ENDIF
			ENDIF
		ENDIF
	ELSE
		llPrivateResrateMessageContent = " Ratecode %s1 hasn't been located in .DBF for ReserId %s2 of date %s3!"
	ENDIF
	SET ORDER TO lnOrder IN ratecode ASCENDING
	IF NOT tlFound
		IF EMPTY(lnRecnoRC)
			IF NOT tlSilent
				Alert(GetLangText("RATEPOST","TA_RCNOTFOUND")+" "+ALLTRIM(tcRateCode)+" "+Get_rt_roomtyp(tcRoomType)+" "+DTOC(tdDate)+ALLTRIM(" "+lcSeason)+"!")
			ENDIF
		ELSE
			GO lnRecnoRC IN ratecode
		ENDIF
		IF tlLogError
			ErrorMsg("CallProc: "+PROGRAM(PROGRAM(-1)-1)+Str2Msg(llPrivateResrateMessageContent,"%s",tcRateCode, TRANSFORM(IIF(USED("reservat"), reservat.rs_reserid, 0)), TRANSFORM(tdDate)))
		ENDIF
	ENDIF
	SELECT (lnArea)
ENDIF

RETURN tlFound
ENDFUNC
*
PROCEDURE PrintReport
LPARAMETERS tcFrxFileName, tlPrint, tlNoPrintPrompt, tlNoSetStatus, tcExportType, tcOutputFile, tcurData
LOCAL llNoListsTable, lnRecno, loSession, loXFF, loPreview, loExtensionHandler, llAutoYield, loFile, lcXmlFile
LOCAL loPreviewForm, loToolbarHnd, lcPrintPrompt
LOCAL loObj, lnRetVal

DO CASE
	CASE tlPrint
		glInreport = .T.
		lcPrintPrompt = IIF(tlNoPrintPrompt OR g_lAutomationMode, "", "PROMPT")
		REPORT FORM (tcFrxFileName) TO PRINTER &lcPrintPrompt NOCONSOLE
		glErrorinreport = .F.
		glInreport = .F.
		IF NOT tlNoSetStatus
			DO SetStatus IN Setup
		ENDIF
	CASE EVL(tcExportType,"") = "ZUGFERD"
		IF _screen.oGlobal.lGobdActive AND NOT EMPTY(g_BillNum)
			tcOutputFile = ADDBS(_screen.oGlobal.cGobdDirectory)+FORCEEXT(g_BillNum, "pdf")
			IF NOT FILE(tcOutputFile)
				loObj = EVALUATE([XFRX("XFRX#LISTENER")])
				loObj.setpdfa(.T., "3B")
				lnRetVal = loObj.SetParams(tcOutputFile,,.T.,,.T.,,"PDF")
				IF lnRetVal = 0
					ProcBill("PbCreateZUGFeRDXml", @lcXmlFile, tcurData)
					loFile = loObj.addAttachment(lcXmlFile, .T., "Rechnungsdaten im ZUGFeRD-XML-Format", "text/xml", "Alternative")
					loFile.CreateZUGFeRDMetadata("BASIC", "INVOICE", "2.0")
					REPORT FORM (tcFrxFileName) OBJECT loObj
					FileDelete(lcXmlFile)
					IF billnum.bn_billnum = g_BillNum OR SEEK(g_BillNum, "billnum", "tag1")
						REPLACE bn_pdf WITH .T. IN billnum
					ENDIF
				ENDIF
				loObj = .NULL.
			ENDIF
		ENDIF
	CASE NOT EMPTY(tcExportType)
		loObj = EVALUATE([XFRX("XFRX#LISTENER")])
		*   XFRXSession::Setparams(tcOutputName, tcDirectory, tlNotOpenWiewer, tcCodePage, tlSilent, tlNewSession, tcTarget, tcArchive, tlAdditive, tlDeleteFileAfter)
		lnRetVal = loObj.SetParams(tcOutputFile,,.T.,,.T.,,tcExportType)
		IF lnRetVal = 0
			REPORT FORM (tcFrxFileName) OBJECT loObj
		ENDIF
		loObj = .NULL.
	CASE g_lUseNewRepPreview
		loSession = EVALUATE([xfrx("XFRX#LISTENER")])
		IF 0 = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
			IF USED("lists")
				lnRecno = RECNO("lists")
				llNoListsTable = NOT DLocate("lists", "UPPER(li_frx) = " + SqlCnv(UPPER(JUSTFNAME(tcFrxFileName)),.T.))
			ELSE
				llNoListsTable = .T.
			ENDIF
			llAutoYield = _vfp.AutoYield
			_vfp.AutoYield = .T.
			glInreport = .T.
			REPORT FORM (tcFrxFileName) OBJECT loSession
			glErrorinreport = .F.
			glInreport = .F.
			loXFF = loSession.oxfDocument
			_vfp.AutoYield = llAutoYield
			loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
			loExtensionHandler.lNoListsTable = llNoListsTable
			loExtensionHandler.curData = tcurData
			loPreview = CREATEOBJECT("frmMpPreviewerDesk")
			loPreview.setExtensionHandler(loExtensionHandler)
			loPreview.PreviewXFF(loXFF)
			loPreview.Show(1)
			loExtensionHandler.curData = ""
			loExtensionHandler = .NULL.
			IF USED("lists")
				GO lnRecno IN lists
			ENDIF
		ENDIF
	OTHERWISE
		loToolbarHnd = NEWOBJECT("cToolbarHnd","ProcToolbar.prg")
		loToolbarHnd.DisableToolbars()
		loPreviewForm = .NULL.
		DO FORM Forms\Preview.scx NAME loPreviewForm LINKED
		glInreport = .T.
		REPORT FORM (tcFrxFileName) NOCONSOLE PREVIEW WINDOW Preview
		glErrorinreport = .F.
		glInreport = .F.
		loPreviewForm.Release()
		DO SetStatus IN Setup
		loToolbarHnd.EnableToolbars()
ENDCASE
ENDFUNC
*
PROCEDURE AvlGetRoomtypes
LPARAMETERS taRoomtypes, tcurBuildings, tcHotCode
EXTERNAL ARRAY taRoomtypes
LOCAL lcSql, lcurRoomtypes, ltmpCursor

PRIVATE pcHotCode
pcHotCode = tcHotCode

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT CAST(rt_buildng AS Char(10)) AS rt_buildng, rt_roomtyp, CAST(NVL(rd_roomtyp,'') AS Char(10)) AS rd_roomtyp, rt_lang<<g_langnum>> AS rt_lang,
	rt_group, rt_vwshow, rt_vwsum, rt_ftbold, rt_vwfmt, rt_avlpct1, rt_avlpct2, rt_avlpct3,
	rt_virroom, CAST(NVL(c1.ct_color,0) AS Numeric(8)) AS fcolor, CAST(NVL(c2.ct_color,0) AS Numeric(8)) AS bcolor,
	CAST(IIF(rt_sequenc=0,99,rt_sequenc) AS Numeric(2)) AS rt_sequenc, rt_rdid
	FROM roomtype
	LEFT JOIN rtypedef ON rt_rdid = rd_rdid
	LEFT JOIN citcolor AS c1 ON rt_ftcolid = c1.ct_colorid
	LEFT JOIN citcolor AS c2 ON rt_cocolid = c2.ct_colorid
	WHERE rt_vwsize > 0 AND (INLIST(rt_group, 1, 4) AND rt_vwshow OR rt_group = 3 AND (rt_vwshow OR rt_vwsum))
	ORDER BY rt_buildng, rd_roomtyp
ENDTEXT
lcurRoomtypes = SqlCursor(lcSql,,,,,,,.T.)

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT pl_numcod, pl_charcod, pl_lang<<g_langnum>> AS pl_lang FROM picklist
	WHERE pl_label = 'VIRROOM   ' AND pl_numcod > 0
	ORDER BY pl_numcod
ENDTEXT
ltmpCursor = SqlCursor(lcSql)
IF EMPTY(tcurBuildings)
	INSERT INTO (lcurRoomtypes) (rt_roomtyp, rd_roomtyp, rt_lang, fcolor) SELECT "v"+pl_charcod, pl_charcod, pl_lang, RGB(64,64,64) FROM &ltmpCursor
	IF NOT EMPTY(tcHotCode)
		REPLACE rt_buildng WITH tcHotCode ALL IN (lcurRoomtypes)
	ENDIF
ELSE
	SELECT bu_buildng, &ltmpCursor..* FROM (tcurBuildings), (ltmpCursor) INTO CURSOR (ltmpCursor)
	INSERT INTO (lcurRoomtypes) (rt_buildng, rt_roomtyp, rd_roomtyp, rt_lang, fcolor) SELECT bu_buildng, "v"+pl_charcod, pl_charcod, pl_lang, RGB(64,64,64) FROM &ltmpCursor
ENDIF

SELECT * FROM (lcurRoomtypes) INTO ARRAY taRoomtypes

DClose(ltmpCursor)
DClose(lcurRoomtypes)
ENDPROC
*
PROCEDURE AvlGetEvents
LPARAMETERS taEvents, tdStartDate, tdEndDate, tcHotCode
EXTERNAL ARRAY taEvents
LOCAL lcSql, lcWhere, lcurEvents

lcWhere = IIF(EMPTY(tdStartDate), "1=1", "ei_from <= " + SqlCnv(tdEndDate,.T.) + " AND ei_to >= " + SqlCnv(tdStartDate,.T.))
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT CAST('<<EVL(tcHotCode,"")>>' AS Char(10)) AS c_hotcode, CAST(0 AS Int) AS c_row,
	  ei_eiid, ei_evid, ei_from, ei_to, ev_evid, ev_name, ev_city, ev_color, ev_picture
	FROM evint
	INNER JOIN events ON ev_evid = ei_evid
	WHERE <<lcWhere>>
	ORDER BY ei_from
ENDTEXT
lcurEvents = SqlCursor(lcSql,,,,,,,.T.)

SELECT * FROM (lcurEvents) INTO ARRAY taEvents

DClose(lcurEvents)
ENDPROC
*
PROCEDURE AvlEvData
LPARAMETERS toAvailData, tdStartDate, tdEndDate, tcHotCode
LOCAL loEvent, lcSql, lcurSeason, lcColumn, lcPictFile

PRIVATE pcHotCode
pcHotCode = tcHotCode

* Set Events
IF toAvailData.Parent.DoEval("DLocate(lp_uParam1, lp_uParam2)",,toAvailData.ccurEvents, "ckey = 'CEVENT'")  
	toAvailData.Parent.DoEval("SELECT &lp_uParam1",.T.,toAvailData.ccurEvents)
	toAvailData.Parent.DoEval("SCATTER MEMO NAME lp_uParam1",.T.,@loEvent)
	TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT se_date, se_event, se_color, NVL(ev_picture,'') AS ev_picture FROM season
		LEFT JOIN evint ON se_date BETWEEN ei_from AND ei_to
		LEFT JOIN events ON ev_evid = ei_evid
		WHERE se_date BETWEEN <<SqlCnv(tdStartDate,.T.)>> AND <<SqlCnv(tdEndDate,.T.)>>
		ORDER BY se_date
	ENDTEXT
	lcurSeason = SqlCursor(lcSql)
	SCAN FOR NOT EMPTY(ev_picture) OR NOT EMPTY(se_event) OR NOT EMPTY(se_color)
		lcColumn = TRANSFORM(se_date-toAvailData.dDate+1)
		lcPictFile = ""
		IF NOT EMPTY(ev_picture) AND EMPTY(EVALUATE("loEvent.cPict"+lcColumn))
			lcPictFile = FULLPATH("Pictures\"+ALLTRIM(ev_picture))
			IF NOT FILE(lcPictFile)
				lcPictFile = ""
			ENDIF
		ENDIF
		IF NOT EMPTY(lcPictFile)
			toAvailData.AddToField(,ev_picture, "cPict"+lcColumn, toAvailData.ccurEvents, .T.)
		ENDIF
		toAvailData.AddToField(,se_event, "cData"+lcColumn, toAvailData.ccurEvents)
		IF NOT EMPTY(se_color) AND EMPTY(EVALUATE("loEvent.bcolor"+lcColumn))
			toAvailData.AddToField(,EVALUATE("RGB(" + se_color + ")"), "bcolor"+lcColumn, toAvailData.ccurEvents, .T.)
		ENDIF
	ENDSCAN
	DClose(lcurSeason)
ENDIF
ENDPROC
*
PROCEDURE AvlRtData
LPARAMETERS toAvailData, tdStartDate, tdEndDate, tcHotCode
LOCAL loRoomtype, lcSql, lcurAvailab, lcColumn, lnValue, lnAvlPct1, lnAvlPct2, lnAvlPct3, lnOccPct, lnBColor

PRIVATE pcHotCode
pcHotCode = tcHotCode

* Set availability of roomtypes
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT availab.*, CAST(rt_buildng AS Char(10)) AS rt_buildng FROM availab
	INNER JOIN roomtype ON av_roomtyp = rt_roomtyp
	WHERE av_date BETWEEN <<SqlCnv(tdStartDate,.T.)>> AND <<SqlCnv(tdEndDate,.T.)>> AND
	rt_vwsize > 0 AND (INLIST(rt_group, 1, 4) AND rt_vwshow OR rt_group = 3 AND (rt_vwshow OR rt_vwsum))
ENDTEXT
lcurAvailab = SqlCursor(lcSql,,,,,,,.T.)
IF NOT EMPTY(tcHotCode)
	REPLACE rt_buildng WITH tcHotCode ALL IN (lcurAvailab)
ENDIF
IF _screen.oGlobal.lVehicleRentMode AND NOT _screen.oGlobal.lVehicleRentModeOffsetInAvailab
	VehicleRent("VehicleRentFixAvailability",tdStartDate,tdEndDate,lcurAvailab)
ENDIF
SCAN FOR toAvailData.Parent.DoEval("SEEK(lp_uParam1,lp_uParam2,'ckey')",,&lcurAvailab..rt_buildng+av_roomtyp,toAvailData.ccurRoomtypes)
	toAvailData.Parent.DoEval("SELECT &lp_uParam1",.T.,toAvailData.ccurRoomtypes)
	toAvailData.Parent.DoEval("SCATTER MEMO NAME lp_uParam1",.T.,@loRoomtype)
	SELECT &lcurAvailab
	lcColumn = TRANSFORM(av_date-toAvailData.dDate+1)
	lnValue = av_definit + ;
		IIF(toAvailData.lAlloDef, MAX(av_allott+av_altall-av_pick,0), 0) + ;
		IIF(toAvailData.lOptiDef, av_option, 0) + ;
		IIF(toAvailData.lTentDef, av_tentat, 0) + ;
		IIF(toAvailData.lOosDef, av_ooservc, 0)
	DO CASE
		CASE INLIST(loRoomtype.rt_group, 1, 4)
			toAvailData.AddToField(,av_avail-lnValue, "nFree"+lcColumn, toAvailData.ccurRoomtypes)
			toAvailData.AddToField(,lnValue, "nDef"+lcColumn, toAvailData.ccurRoomtypes)
			IF _screen.oGlobal.lVehicleRentMode
				toAvailData.AddToField(,av_option, "nOpt"+lcColumn, toAvailData.ccurRoomtypes)
			ENDIF
			IF _screen.oGlobal.oParam2.pa_avllvrt AND NOT (INLIST(_screen.oGlobal.nBCOccupancyLevel1,0,RGB(255,255,255)) AND INLIST(_screen.oGlobal.nBCOccupancyLevel2,0,RGB(255,255,255)) AND INLIST(_screen.oGlobal.nBCOccupancyLevel3,0,RGB(255,255,255)))
				IF loRoomtype.rt_avlpct1 = 0 AND loRoomtype.rt_avlpct2 = 0 AND loRoomtype.rt_avlpct3 = 0
					lnAvlPct1 = _screen.oGlobal.oParam2.pa_avlpct1
					lnAvlPct2 = _screen.oGlobal.oParam2.pa_avlpct2
					lnAvlPct3 = _screen.oGlobal.oParam2.pa_avlpct3
				ELSE
					lnAvlPct1 = loRoomtype.rt_avlpct1
					lnAvlPct2 = loRoomtype.rt_avlpct2
					lnAvlPct3 = loRoomtype.rt_avlpct3
				ENDIF
				lnOccPct = 100*(IIF(av_avail = 0, 1, lnValue/av_avail))
				lnBColor = ICASE(lnAvlPct1=0 AND lnAvlPct2=0 AND lnAvlPct3=0, 0, lnOccPct>lnAvlPct1, _screen.oGlobal.nBCOccupancyLevel1, lnOccPct>lnAvlPct2, _screen.oGlobal.nBCOccupancyLevel2, lnOccPct>=lnAvlPct3, _screen.oGlobal.nBCOccupancyLevel3, 0)
				toAvailData.AddToField(,lnBColor, "bcolor"+lcColumn, toAvailData.ccurRoomtypes)
			ENDIF
			IF loRoomtype.rt_vwsum
				toAvailData.AddToField(loRoomtype.rt_buildng+"NDEF      ", av_definit, "nData"+lcColumn, toAvailData.ccurAvailability)
				toAvailData.AddToField(loRoomtype.rt_buildng+"NOPT      ", av_option, "nData"+lcColumn, toAvailData.ccurAvailability)
				toAvailData.AddToField(loRoomtype.rt_buildng+"NLST      ", av_waiting, "nData"+lcColumn, toAvailData.ccurAvailability)
				toAvailData.AddToField(loRoomtype.rt_buildng+"NTEN      ", av_tentat, "nData"+lcColumn, toAvailData.ccurAvailability)
			ENDIF
		CASE loRoomtype.rt_group = 3
			toAvailData.AddToField(,av_avail-lnValue, "nFree"+lcColumn, toAvailData.ccurRoomtypes)
			toAvailData.AddToField(,lnValue, "nDef"+lcColumn, toAvailData.ccurRoomtypes)
			IF _screen.oGlobal.oParam2.pa_avllvrt AND NOT (INLIST(_screen.oGlobal.nBCOccupancyLevel1,0,RGB(255,255,255)) AND INLIST(_screen.oGlobal.nBCOccupancyLevel2,0,RGB(255,255,255)) AND INLIST(_screen.oGlobal.nBCOccupancyLevel3,0,RGB(255,255,255)))
				toAvailData.AddToField(,loRoomtype.bcolor, "bcolor"+lcColumn, toAvailData.ccurRoomtypes)
			ENDIF
	ENDCASE
	toAvailData.AddToField(loRoomtype.rt_buildng+"NOOO      ", av_ooorder, "nData"+lcColumn, toAvailData.ccurAvailability)
	toAvailData.AddToField(loRoomtype.rt_buildng+"NOOS      ", av_ooservc, "nData"+lcColumn, toAvailData.ccurAvailability)
	toAvailData.AddToField(loRoomtype.rt_buildng+"NALT      ", av_allott+av_altall, "nData"+lcColumn, toAvailData.ccurAvailability)
	toAvailData.AddToField(loRoomtype.rt_buildng+"NPICK     ", av_pick, "nData"+lcColumn, toAvailData.ccurAvailability)
	IF NOT EMPTY(loRoomtype.rt_virroom)
		toAvailData.AddToField(loRoomtype.rt_buildng+PADR("v"+loRoomtype.rt_virroom,4), av_avail-lnValue, "nFree"+lcColumn, toAvailData.ccurRoomtypes)
		toAvailData.AddToField(loRoomtype.rt_buildng+PADR("v"+loRoomtype.rt_virroom,4), lnValue, "nDef"+lcColumn, toAvailData.ccurRoomtypes)
	ENDIF
ENDSCAN
DClose(lcurAvailab)
ENDPROC
*
PROCEDURE AvlRsData
LPARAMETERS toAvailData, tdStartDate, tdEndDate, tlShowExpAvl, toAvlSession
LOCAL i, lcSql, lcHotCode, lnReservat, lcurReservat, llShowExpAvl, llShow6PM, llSharing, lcBuilding, lcBuildingDep, lnLinks, ln6PMRooms, ldFromDate, ldToDate, llIsArrival, llIsDeparture

llShowExpAvl = tlShowExpAvl OR _screen.oGlobal.oParam.pa_expavl
llShow6PM = _screen.oGlobal.oParam2.pa_avl6pm
lcHotCode = IIF(VARTYPE(toAvlSession) = "O", toAvlSession.cHotCode, "")

PRIVATE pcHotCode
pcHotCode = lcHotCode

IF llShowExpAvl OR llShow6PM
	* Set arrivals, departures and stays. 6PM
	IF odbc()

		TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
		SELECT rs_arrdate, rs_depdate, rs_reserid, rs_status, rs_roomnum, rs_roomtyp, rs_lstart, rs_lfinish, rs_rooms, rs_adults,
			rs_childs, rs_childs2, rs_childs3, ri_date, ri_todate, ri_roomnum, ri_roomtyp, NVL(ri_shareid,0) AS ri_shareid, rs_groupid 
			FROM reservat 
			LEFT JOIN resrooms ON ri_reserid = rs_reserid AND ri_date <= <<SqlCnv(tdEndDate,.T.)>> AND ri_todate >= <<SqlCnv(tdStartDate,.T.)>>
			WHERE rs_arrdate < <<sqlcnv(tdEndDate+1,.T.)>> AND rs_depdate >= <<sqlcnv(tdStartDate,.T.)>> AND
				NOT rs_status IN ('NS', 'CXL', 'LST')
			ORDER BY rs_reserid, ri_date
		ENDTEXT
	
	ELSE

		TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
		SELECT rs_arrdate, rs_depdate, rs_reserid, rs_status, rs_roomnum, rs_roomtyp, rs_lstart, rs_lfinish, rs_rooms, rs_adults,
			rs_childs, rs_childs2, rs_childs3, ri_date, ri_todate, ri_roomnum, ri_roomtyp, NVL(ri_shareid,0) AS ri_shareid, rs_groupid 
			FROM reservat 
			LEFT JOIN resrooms ON ri_reserid = rs_reserid AND ri_date <= <<SqlCnv(tdEndDate,.T.)>> AND ri_todate >= <<SqlCnv(tdStartDate,.T.)>>
			WHERE DTOS(rs_arrdate)+rs_lname < '<<DTOS(tdEndDate+1)>>' AND DTOS(rs_depdate)+rs_roomnum >= '<<DTOS(tdStartDate)>>' AND
				NOT INLIST(rs_status, 'NS', 'CXL', 'LST')
			ORDER BY rs_reserid, ri_date
		ENDTEXT

	ENDIF
	lcurReservat = SqlCursor(lcSql)
	lnReservat = 0
 	SCAN
		ldFromDate = MAX(NVL(ri_date,rs_arrdate),tdStartDate)
		ldToDate = MIN(NVL(ri_todate,MAX(rs_arrdate,rs_depdate-1)),tdEndDate)
		IF llShowExpAvl OR llShow6PM
			llSharing = NOT EMPTY(NVL(ri_shareid,0))
			lcBuilding = PADR(IIF(EMPTY(lcHotCode), Get_rt_roomtyp(NVL(ri_roomtyp,rs_roomtyp), "rt_buildng",,toAvlSession), lcHotCode),10)
			lcBuildingDep = PADR(EVL(rs_lfinish, lcBuilding),10)
			lcBuilding = PADR(EVL(rs_lstart, lcBuilding),10)
			IF EMPTY(NVL(ri_roomnum,rs_roomnum))
				lnLinks = Get_rt_roomtyp(NVL(ri_roomtyp,rs_roomtyp), "IIF(rt_group = 1 AND rt_vwsum, 1, 0)",,toAvlSession)
			ELSE
				lnLinks = Get_rm_rmname(NVL(ri_roomnum,rs_roomnum), "rm_roomocc", toAvlSession)
			ENDIF
		ENDIF
		IF llShow6PM AND rs_status = "6PM" AND ldFromDate <= ldToDate
			ln6PMRooms = Get_rt_roomtyp(NVL(ri_roomtyp,rs_roomtyp), "IIF(rt_vwsize > 0 AND INLIST(rt_group, 1, 4) AND rt_vwshow AND rt_vwsum, 1, 0)",,toAvlSession)
		ENDIF
		IF llShow6PM AND rs_status = "6PM" AND ldFromDate <= ldToDate AND NOT EMPTY(ln6PMRooms) AND NOT llSharing
			FOR i = ldFromDate-toAvailData.dDate+1 TO ldToDate-toAvailData.dDate+1
				toAvailData.AddToField(lcBuilding+"NSIXPM    ", rs_rooms*ln6PMRooms, "nData"+TRANSFORM(i), toAvailData.ccurAvailability)
				toAvailData.AddToField(lcBuilding+"NDEF      ", -rs_rooms*ln6PMRooms, "nData"+TRANSFORM(i), toAvailData.ccurAvailability)
			NEXT
		ENDIF
		IF llShowExpAvl AND NOT EMPTY(lnLinks)
			IF lnReservat <> rs_reserid
				IF NOT llSharing
					toAvailData.AddToField(lcBuilding+"NRMSARR   ", rs_rooms*lnLinks, "nData"+TRANSFORM(rs_arrdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
				ENDIF
				toAvailData.AddToField(lcBuilding+"NPRSARR   ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nData"+TRANSFORM(rs_arrdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
				IF rs_groupid<>0
					toAvailData.AddToField(lcBuilding+"NPRSARR   ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nGData"+TRANSFORM(rs_arrdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
				ENDIF
				IF rs_status = "IN"
					IF NOT llSharing
						toAvailData.AddToField(lcBuilding+"NRMSIN    ", rs_rooms*lnLinks, "nData"+TRANSFORM(rs_arrdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
					ENDIF
					toAvailData.AddToField(lcBuilding+"NPRSIN    ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nData"+TRANSFORM(rs_arrdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
					IF rs_groupid<>0
						toAvailData.AddToField(lcBuilding+"NPRSIN    ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nGData"+TRANSFORM(rs_arrdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
					ENDIF
				ENDIF
				IF NOT llSharing
					toAvailData.AddToField(lcBuildingDep+"NRMSDEP   ", rs_rooms*lnLinks, "nData"+TRANSFORM(rs_depdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
				ENDIF
				toAvailData.AddToField(lcBuilding+"NPRSDEP   ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nData"+TRANSFORM(rs_depdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
				IF rs_groupid<>0
					toAvailData.AddToField(lcBuildingDep+"NPRSDEP   ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nGData"+TRANSFORM(rs_depdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
				ENDIF
				IF rs_status = "OUT"
					IF NOT llSharing
						toAvailData.AddToField(lcBuilding+"NRMSOUT   ", rs_rooms*lnLinks, "nData"+TRANSFORM(rs_depdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
					ENDIF
					toAvailData.AddToField(lcBuilding+"NPRSOUT   ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nData"+TRANSFORM(rs_depdate-toAvailData.dDate+1), toAvailData.ccurAvailability)
				ENDIF
			ENDIF
			IF ldFromDate <= ldToDate
				FOR i = ldFromDate-toAvailData.dDate+1 TO ldToDate-toAvailData.dDate+1
					IF NOT llSharing
						toAvailData.AddToField(lcBuilding+"NRMSINH   ", rs_rooms*lnLinks, "nData"+TRANSFORM(i), toAvailData.ccurAvailability)
					ENDIF
					toAvailData.AddToField(lcBuilding+"NPRSINH   ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nData"+TRANSFORM(i), toAvailData.ccurAvailability)
					IF rs_groupid<>0
						toAvailData.AddToField(lcBuilding+"NPRSINH   ", rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3), "nGData"+TRANSFORM(i), toAvailData.ccurAvailability)
					ENDIF
				NEXT
			ENDIF
		ENDIF
		lnReservat = rs_reserid
	ENDSCAN
	TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT sd_roomnum, sd_roomtyp, sd_lowdat, sd_highdat, sd_status, sd_shareid FROM sharing
		WHERE sd_lowdat < <<SqlCnv(tdEndDate+1,.T.)>> AND sd_highdat >= <<SqlCnv(tdStartDate,.T.)>> AND NOT sd_history
	ENDTEXT
	SqlCursor(lcSql, lcurReservat)
	IF llShowExpAvl AND EMPTY(lcHotCode) AND RECCOUNT(lcurReservat) > 0
		toAvailData.OpenTables(,.T.)	&& Open history tables for sharing check (RiShareInterval IN ProcResRooms)
	ENDIF
	SELECT (lcurReservat)
	SCAN
		lcBuilding = PADR(IIF(EMPTY(lcHotCode), Get_rt_roomtyp(sd_roomtyp, "rt_buildng",,toAvlSession), lcHotCode),10)
		lcBuildingDep = lcBuilding
		ldFromDate = MAX(sd_lowdat,tdStartDate)
		ldToDate = MIN(sd_highdat,tdEndDate)
		IF llShowExpAvl
			IF EMPTY(sd_roomnum)
				lnLinks = Get_rt_roomtyp(sd_roomtyp, "IIF(rt_group = 1 AND rt_vwsum, 1, 0)",,toAvlSession)
			ELSE
				lnLinks = Get_rm_rmname(sd_roomnum, "rm_roomocc", toAvlSession)
			ENDIF
		ENDIF
		IF llShow6PM AND sd_status = "6PM" AND ldFromDate <= ldToDate
			ln6PMRooms = Get_rt_roomtyp(sd_roomtyp, "IIF(rt_vwsize > 0 AND INLIST(rt_group, 1, 4) AND rt_vwshow AND rt_vwsum, 1, 0)",,toAvlSession)
		ENDIF
		IF llShow6PM AND sd_status = "6PM" AND ldFromDate <= ldToDate AND NOT EMPTY(ln6PMRooms)
			FOR i = ldFromDate-toAvailData.dDate+1 TO ldToDate-toAvailData.dDate+1
				toAvailData.AddToField(lcBuilding+"NSIXPM    ", ln6PMRooms, "nData"+TRANSFORM(i), toAvailData.ccurAvailability)
				toAvailData.AddToField(lcBuilding+"NDEF      ", -ln6PMRooms, "nData"+TRANSFORM(i), toAvailData.ccurAvailability)
			NEXT
		ENDIF
		IF llShowExpAvl AND NOT EMPTY(lnLinks)
			DO RiShareInterval IN ProcResRooms WITH llIsArrival, sd_shareid, sd_lowdat, sd_highdat, "ARRIVAL", sd_lowdat
			IF llIsArrival
				toAvailData.AddToField(lcBuilding+"NRMSARR   ", lnLinks, "nData"+TRANSFORM(sd_lowdat-toAvailData.dDate+1), toAvailData.ccurAvailability)
				IF sd_status = "IN"
					toAvailData.AddToField(lcBuilding+"NRMSIN    ", lnLinks, "nData"+TRANSFORM(sd_lowdat-toAvailData.dDate+1), toAvailData.ccurAvailability)
				ENDIF
			ENDIF
			DO RiShareInterval IN ProcResRooms WITH llIsDeparture, sd_shareid, sd_lowdat, sd_highdat, "DEPARTURE", sd_highdat+1
			IF llIsDeparture
				toAvailData.AddToField(lcBuildingDep+"NRMSDEP   ", lnLinks, "nData"+TRANSFORM(sd_highdat-toAvailData.dDate+2), toAvailData.ccurAvailability)
				IF sd_status = "OUT"
					toAvailData.AddToField(lcBuildingDep+"NRMSOUT   ", lnLinks, "nData"+TRANSFORM(sd_highdat-toAvailData.dDate+2), toAvailData.ccurAvailability)
				ENDIF
			ENDIF
			IF ldFromDate <= ldToDate
				FOR i = ldFromDate-toAvailData.dDate+1 TO ldToDate-toAvailData.dDate+1
					toAvailData.AddToField(lcBuilding+"NRMSINH   ", lnLinks, "nData"+TRANSFORM(i), toAvailData.ccurAvailability)
				NEXT
			ENDIF
		ENDIF
	ENDSCAN
	DClose(lcurReservat)
ENDIF
ENDPROC
*
PROCEDURE AvlErData
LPARAMETERS toAvailData, tdStartDate, tdEndDate, tcHotCode
LOCAL i, lcSql, ldDate, lcurExtreser, lcColumn
LOCAL ARRAY laValues[1]

PRIVATE pcHotCode
pcHotCode = tcHotCode

IF _screen.oGlobal.oParam2.pa_shexria AND _screen.OR
	* Set pending external reservations
	TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT CAST(NVL(rt_buildng, '') AS Char(10)) AS rt_buildng, er_arrdate, er_depdate, er_rooms 
		FROM extreser
		LEFT JOIN roomtype ON er_roomtyp = rt_roomtyp
		WHERE er_arrdate <= <<SqlCnv(tdEndDate,.T.)>> AND er_depdate > <<SqlCnv(tdStartDate,.T.)>> AND NOT er_status IN ('CXL','LST') AND NOT er_done
	ENDTEXT
	lcurExtreser = SqlCursor(lcSql)

	ldDate = tdStartDate
	DO WHILE ldDate <= tdEndDate
		DIMENSION laValues[1]
		laValues[1] = .F.
		SELECT rt_buildng, SUM(er_rooms) FROM &lcurExtreser ;
			WHERE BETWEEN(ldDate, er_arrdate, MAX(er_arrdate,er_depdate-1)) ;
			GROUP BY rt_buildng ;
			INTO ARRAY laValues
		IF VARTYPE(laValues[1]) = "C"
			lcColumn = TRANSFORM(ldDate-toAvailData.dDate+1)
			FOR i = 1 TO ALEN(laValues,1)
				toAvailData.AddToField(laValues[i,1]+"NEXTRESER ", laValues[i,2], "nData"+lcColumn, toAvailData.ccurAvailability)
			NEXT
		ENDIF
		ldDate = ldDate + 1
	ENDDO
	DClose(lcurExtreser)
ENDIF
ENDPROC
*
PROCEDURE RpSetFeature
LPARAMETERS tcurResrooms
LOCAL lnSelect, lcFeature, lcurRoomfeat

lnSelect = SELECT()

lcurRoomfeat = SqlCursor("SELECT * FROM resfeat")
SELECT &tcurResrooms
SCAN
	lcFeature = ""
	SELECT &lcurRoomfeat
	SCAN FOR fr_rsid = &tcurResrooms..rs_rsid
		lcFeature = lcFeature + IIF(EMPTY(lcFeature), "", ", ") + ALLTRIM(fr_feature)
	ENDSCAN
	SELECT &tcurResrooms
	REPLACE c_feature WITH lcFeature
ENDSCAN
DClose(lcurRoomfeat)

SELECT (lnSelect)
ENDPROC
*
PROCEDURE RpGetFeatures
LPARAMETERS taFeatures, tcHotCode
EXTERNAL ARRAY taFeatures
LOCAL lcSqlSelect, lcurRoomfeat

PRIVATE pcHotCode
pcHotCode = tcHotCode

TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT roomfeat.*, rt_roomtyp, rt_buildng, rt_group, CAST(NVL(pl_lang<<g_Langnum>>,'') AS Char(25)) AS pl_lang, CAST('<<EVL(tcHotCode,'')>>' AS Char(10)) AS c_hotcode FROM roomfeat
	INNER JOIN room ON rf_roomnum = rm_roomnum
	INNER JOIN roomtype ON rt_roomtyp = rm_roomtyp
	LEFT JOIN picklist ON pl_label = 'FEATURE   ' AND pl_charcod = rf_feature
	ORDER BY rf_feature
	WHERE rf_feature <> ' '
ENDTEXT
lcurRoomfeat = SqlCursor(lcSqlSelect,,,,,,,.T.)
IF RECCOUNT(lcurRoomfeat) > 0
	SELECT * FROM (lcurRoomfeat) INTO ARRAY taFeatures
ENDIF

DClose(lcurRoomfeat)
ENDPROC
*
PROCEDURE RpGetRooms
LPARAMETERS toForm, toSearchTunnel, tcFilter, tcRoomKey, tnFirstRoom, toRpSession
LOCAL i, lnArea, lcHotCode, lnStart, lnCount, lnRoomsNo, lcStatusFilter, lcSearchResName, lcPeriod, lcSqlSelect, lcRoom, lcurReservat, lcRfSel, lnUnsortedValue

lnArea = SELECT()

IF VARTYPE(toRpSession) = "O"
	toRpSession.nStartLine = 1
	toRpSession.nEndLine = 1
	lcHotCode = toRpSession.cHotCode
ELSE
	lcHotCode = ""
ENDIF

PRIVATE pcHotCode
pcHotCode = lcHotCode

IF NOT EMPTY(toForm.cRpForPeriodSql)
	SqlCursor(toForm.cRpForPeriodSql, toForm.cCurRoomplanForPeriod,,,,,,.T.)
	INDEX ON ri_roomnum TAG ri_roomnum
ENDIF
lcRoom = SqlCursor(toForm.cRmSqlSelect,,,,,,,.T.)

* Check if order of rooms in roomplan on revenue is active
IF NOT EMPTY(toSearchTunnel.SelRevSorting)
	RpGetRoomsRevenue(IIF(toSearchTunnel.SelRevSorting = 1,.T.,.F.))
	IF toSearchTunnel.SelRevSorting = 1
		lnUnsortedValue = 99999 && descending
	ELSE
		lnUnsortedValue = 0     && ascending
	ENDIF
	SELECT (lcRoom)
	SCAN ALL
		IF dlocate("crevroom1", "rm_roomnum = '" + rm_roomnum + "'")
			REPLACE c_order WITH RECNO("crevroom1") IN (lcRoom)
		ELSE
			REPLACE c_order WITH lnUnsortedValue IN (lcRoom)
		ENDIF
	ENDSCAN

	SELECT crevroom1
	SCAN FOR dlocate(lcRoom, "rm_roomnum = '" + rm_roomnum + "'")
		REPLACE c_order WITH RECNO("crevroom1") IN (lcRoom)
	ENDSCAN
	dclose("crevroom1")
	SELECT * FROM (lcRoom) WHERE 1=1 ORDER BY &tcRoomKey INTO CURSOR (lcRoom) READWRITE
ENDIF


IF RECCOUNT(lcRoom) > 0 AND TYPE("toForm.cntFilterRooms.stxtFeature.curSelect") = "C"
	LOCAL ARRAY laSelRoomFeat(1)
	IF toForm.GetFeatRooms(@laSelRoomFeat, lcHotCode)
		DELETE FOR ASCAN(laSelRoomFeat, rm_roomnum) = 0 IN (lcRoom)
	ENDIF
	SELECT * FROM &lcRoom WHERE &tcFilter INTO CURSOR &lcRoom
ENDIF

* fill into array
lnRoomsNo = 0
IF RECCOUNT(lcRoom) > 0
	SELECT &lcRoom
	lnStart = IIF(EMPTY(toForm.RoomNumber[1,1]), 0, ALEN(toForm.RoomNumber,1))
	lnCount = lnStart + RECCOUNT()
	DIMENSION toForm.RoomNumber(MAX(1,lnCount),12)
	IF VARTYPE(toRpSession) = "O"
		toRpSession.nStartLine = lnStart+1
		toRpSession.nEndLine = lnCount
	ENDIF
*	IF lnStart > 0
*		toForm.RoomNumber[lnStart,7] = .T.	&& First room in hotel
*	ENDIF
	SCAN
		lnRoomsNo = lnRoomsNo + 1
		toForm.RoomNumber[lnStart+lnRoomsNo,1] = rm_roomnum
*		toForm.RoomNumber[lnStart+lnRoomsNo,2] = rm_roomtyp
*		toForm.RoomNumber[lnStart+lnRoomsNo,3] = rm_rpseq
*		toForm.RoomNumber[lnStart+lnRoomsNo,4] = rm_tempera
*		toForm.RoomNumber[lnStart+lnRoomsNo,5] = rm_rmname
*		toForm.RoomNumber[lnStart+lnRoomsNo,6] = rm_status
*		toForm.RoomNumber[lnStart+lnRoomsNo,7] = rm_newgrp
*		toForm.RoomNumber[lnStart+lnRoomsNo,8] = rm_link
		toForm.RoomNumber[lnStart+lnRoomsNo,9] = RpGetToolTipText(toForm, lcRoom, "ROOM",,toRpSession)
		toForm.RoomNumber[lnStart+lnRoomsNo,10] = lcHotCode
		toForm.RoomNumber[lnStart+lnRoomsNo,11] = RpGetCaption(toForm, lcRoom, "ROOM",,toRpSession)
*		toForm.RoomNumber[lnStart+lnRoomsNo,12] = rt_bcolor

		IF tnFirstRoom = 0 AND rm_rpseq >= toSearchTunnel.SelRoomNoN AND lcHotCode = toSearchTunnel.SelRoomNoH
			tnFirstRoom = lnStart+lnRoomsNo
		ENDIF
	ENDSCAN
	IF NOT EMPTY(toSearchTunnel.SelName) OR NOT EMPTY(toSearchTunnel.SelCompany) OR NOT EMPTY(toSearchTunnel.SelGroup)
		IF EMPTY(toSearchTunnel.SelStatus)
			lcStatusFilter = [INLIST(rs_status, '6PM', 'ASG', 'DEF', 'IN ', 'OUT', 'OPT', 'LST', 'TEN')]
		ELSE
			lcStatusFilter = [rs_status = ] + SqlCnv(toSearchTunnel.SelStatus,.T.)
		ENDIF
		lcSearchResName = toForm.SearchResName(toSearchTunnel.SelName,toSearchTunnel.SelCompany,toSearchTunnel.SelGroup)
		lcPeriod = IIF(EMPTY(toSearchTunnel.SelectedDate) OR EMPTY(toSearchTunnel.SelDaysNum), "", Str2Msg(" AND BETWEEN(rs_arrdate, %s1, %s2)", "%s", ;
					SqlCnv(toSearchTunnel.SelectedDate,.T.), SqlCnv(toSearchTunnel.SelectedDate+toSearchTunnel.SelDaysNum-1,.T.)))
		TEXT TO lcWhere TEXTMERGE NOSHOW PRETEXT 15
			 <<lcStatusFilter>><<toForm.OtherSearchResCondition()>><<lcSearchResName>><<lcPeriod>>
		ENDTEXT
		lcurReservat = SqlCursor("SELECT rs_reserid, rs_roomnum, rs_arrdate, rs_lname, rs_company FROM reservat WHERE " + lcWhere,,,,,,,.T.)
		SELECT rs_reserid, rs_roomnum, rs_arrdate FROM &lcurReservat ;
			INNER JOIN &lcRoom ON rm_roomnum = rs_roomnum ;
			ORDER BY &tcRoomKey, rs_arrdate, rs_lname, rs_company ;
			INTO CURSOR &lcurReservat
		IF _tally > 0
			lnStart = IIF(EMPTY(toForm.ClosestRes[1,1]), 0, ALEN(toForm.ClosestRes,1))
			lnCount = lnStart + RECCOUNT()
			DIMENSION toForm.ClosestRes(MAX(1,lnCount),4)
			SCAN
				toForm.ClosestRes[lnStart+RECNO(),1] = rs_reserid
				toForm.ClosestRes[lnStart+RECNO(),2] = rs_roomnum
				toForm.ClosestRes[lnStart+RECNO(),3] = rs_arrdate
				toForm.ClosestRes[lnStart+RECNO(),4] = lcHotCode
			ENDSCAN
		ENDIF

		DClose(lcurReservat)
		toForm.ClosestResNo = toForm.ClosestResNo + _tally
		toSearchTunnel.SelDaysNum = 0
	ENDIF
ENDIF

DClose(lcRoom)

SELECT (lnArea)

RETURN lnRoomsNo
ENDPROC
*
PROCEDURE RpGetRoomsRevenue
LPARAMETERS lp_lDesc

*******************************************************************************************
*
* Get forecest revenue for all rooms, for sorting in roomplan.
* Returns cursor crevroom1 with rm_roomnum and revenue.
*
*******************************************************************************************

LOCAL min1, max1, min2, max2, tcResFilter, lcLabel, cmaingroup

* From to date
min1 = sysdate()
TRY
     min1 = EVALUATE(_screen.oGlobal.csortroomsonrevenuefromdate)
CATCH
ENDTRY

max1 = sysdate() + 30
TRY
     max1 = EVALUATE(_screen.oGlobal.csortroomsonrevenuetodate)
CATCH
ENDTRY

* Main group
cmaingroup = _screen.oGlobal.csortroomsonrevenuemaingroups

tcResFilter = ".T."
lcLabel = "ROOMNUM"

*******************************************************************************************
*
* SQL copied from preproc _fc05000 version 8.30
*
* BEGIN
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
* SQL copied from preproc _fc05000 version 8.30
*
* END
*
*******************************************************************************************

IF lp_lDesc
     SELECT CAST(rescode AS Char(4)) AS rm_roomnum, CAST('' AS Char(10)) AS rm_rmname, SUM(ps_amount) FROM curPost WHERE rescode <> "*****" AND ar_main IN (&cmaingroup) GROUP BY 1,2 ORDER BY 3 DESC INTO CURSOR crevroom1 READWRITE
ELSE
     SELECT CAST(rescode AS Char(4)) AS rm_roomnum, CAST('' AS Char(10)) AS rm_rmname, SUM(ps_amount) FROM curPost WHERE rescode <> "*****" AND ar_main IN (&cmaingroup) GROUP BY 1,2 ORDER BY 3 ASC  INTO CURSOR crevroom1 READWRITE
ENDIF

****************************************************************
*
* Uncomment when debugging
*

*!*	SCAN ALL
*!*	     REPLACE rm_rmname WITH get_rm_rmname(rm_roomnum)
*!*	ENDSCAN

dclose("curPost")

SELECT crevroom1

RETURN .T.
ENDPROC
*
PROCEDURE RpRefreshRooms
LPARAMETERS toForm, toRpSession
LOCAL i, lnArea, lnStartLine, lnEndLine, lcRoom, lcHotCode

lnArea = SELECT()

IF VARTYPE(toRpSession) = "O"
	lnStartLine = MAX(1, toRpSession.nStartLine)
	lnEndLine = MIN(ALEN(toForm.RoomNumber,1), toRpSession.nEndLine)
	lcHotCode = toRpSession.cHotCode
ELSE
	lnStartLine = 1
	lnEndLine = ALEN(toForm.RoomNumber,1)
	lcHotCode = ""
ENDIF

PRIVATE pcHotCode
pcHotCode = lcHotCode

lcRoom = SqlCursor(toForm.cRmSqlSelect,,,,,,,.T.)
IF USED(lcRoom) AND RECCOUNT(lcRoom) > 0
	INDEX ON rm_roomnum TAG rm_roomnum
	IF lnStartLine > 1
		toForm.RoomNumber[lnStartLine-1,7] = .T.	&& First room in hotel
	ENDIF
	FOR i = lnStartLine TO lnEndLine
		IF SEEK(toForm.RoomNumber[i,1], lcRoom, "rm_roomnum")
			toForm.RoomNumber[i,2] = rm_roomtyp
			toForm.RoomNumber[i,3] = rm_rpseq
			toForm.RoomNumber[i,4] = rm_tempera
			toForm.RoomNumber[i,5] = rm_rmname
			toForm.RoomNumber[i,6] = rm_status
			toForm.RoomNumber[i,7] = rm_newgrp
			toForm.RoomNumber[i,8] = rm_link
			toForm.RoomNumber[i,12] = rt_bcolor
		ENDIF
	NEXT
ENDIF
DClose(lcRoom)

SELECT (lnArea)
ENDPROC
*
PROCEDURE RpDisplayLine
LPARAMETERS toForm, tnFirstLine, tnLastLine, tnFirstDate, tnLastDate, toRpSession
LOCAL i, lnArea, llAllRooms, lcSearchRooms, lcRoomNumber, lnLine, lcHotCode, lcWhere, lcLinked, lcKey
LOCAL lcSqlSelect, lcurResrooms, lcurOutoford, lcurOutofser, lnStartLine

lnArea = SELECT()

IF VARTYPE(toRpSession) = "O"
	lnStartLine = toRpSession.nStartLine
	lcHotCode = toRpSession.cHotCode
ELSE
	lnStartLine = 1
	lcHotCode = ""
ENDIF

PRIVATE pcHotCode
pcHotCode = lcHotCode

lcSearchRooms = ""
FOR lnLine = tnFirstLine TO tnLastLine
	IF NOT llAllRooms AND (EMPTY(lcHotCode) OR lcHotCode = toForm.RoomNumber[lnLine + toForm.FirstLine - 1, 10])
		lcRoomNumber = toForm.RoomNumber[lnLine + toForm.FirstLine - 1, 1]
		lcLinked = get_rm_rmname(lcRoomNumber, "rm_linked", toRpSession)
		lcLinked = lcRoomNumber + IIF(EMPTY(lcLinked), "", ",") + lcLinked
		FOR i = 1 TO GETWORDCOUNT(lcLinked, ",")
			lcRoomNumber = ALLTRIM(GETWORDNUM(lcLinked,i,","))
			IF NOT (","+lcRoomNumber+",") $ (","+lcSearchRooms+",")
				lcSearchRooms = lcSearchRooms + IIF(EMPTY(lcSearchRooms), "", ",") + lcRoomNumber
			ENDIF
		NEXT
		IF GETWORDCOUNT(lcSearchRooms,",") > 24
			llAllRooms = .T.
			EXIT
		ENDIF
	ENDIF
NEXT
DO CASE
	CASE EMPTY(lcSearchRooms)
		lcWhere = " AND " + IIF(EMPTY(toForm.oSearchtunnel.SelRoomType), "rt_group = 1", "rt_roomtyp = " + SqlCnv(toForm.oSearchtunnel.SelRoomType,.T.))
	CASE llAllRooms
		lcWhere = ""
	OTHERWISE
		lcWhere = " AND (" + IIF(EMPTY(toForm.oSearchtunnel.SelRoomType), "rt_group = 1", "rt_roomtyp = " + SqlCnv(toForm.oSearchtunnel.SelRoomType,.T.)) + ;
			" OR INLIST(ri_roomnum,'" + STRTRAN(lcSearchRooms,",","','") + "'))"
ENDCASE

* Attention! Fields from this SQL SELECT cursor are used in expressions too, in fields:
* param2.pa_romcapt, param2.pa_concapt, param2.pa_cdcapt, param2.pa_gromcap

TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT resrooms.*, reservat.*, apartner.*, roomtype.*, gr_color, al_allott, dc_reserid, CAST('' AS Char(254)) AS c_feature FROM resrooms
		INNER JOIN roomtype ON ri_roomtyp = rt_roomtyp
		INNER JOIN reservat ON ri_reserid = rs_reserid
		LEFT JOIN althead ON al_altid = rs_altid
		LEFT JOIN groupres ON gr_groupid = rs_groupid
		LEFT JOIN apartner ON ap_apid = rs_apid
		LEFT JOIN document ON dc_reserid = rs_reserid
		WHERE ri_date <= <<SqlCnv(tnLastDate,.T.)>> AND ri_todate >= <<SqlCnv(tnFirstDate,.T.)>> AND
		<<IIF(EMPTY(toForm.oSearchtunnel.SelStatus), "NOT INLIST(rs_status, 'CXL', 'NS ')", "rs_status = " + SqlCnv(toForm.oSearchtunnel.SelStatus,.T.))>><<lcWhere>>
ENDTEXT
lcurResrooms = SqlCursor(lcSqlSelect,,,,,,,.T.)
CFCursorNullsRemove(.T.,lcurResrooms)
CFCursorNullsRemoveAll(.T.,lcurResrooms)
RpSetFeature(lcurResrooms)
TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT a1.* FROM (
		SELECT ad_addrid FROM resrooms
			INNER JOIN roomtype ON ri_roomtyp = rt_roomtyp
			INNER JOIN reservat ON ri_reserid = rs_reserid
			INNER JOIN address ON ad_addrid = rs_addrid
			WHERE ri_date <= <<SqlCnv(tnLastDate,.T.)>> AND ri_todate >= <<SqlCnv(tnFirstDate,.T.)>> AND
			<<IIF(EMPTY(toForm.oSearchtunnel.SelStatus), "NOT INLIST(rs_status, 'CXL', 'NS ')", "rs_status = " + SqlCnv(toForm.oSearchtunnel.SelStatus,.T.))>><<lcWhere>>
			GROUP BY ad_addrid
		) c1 INNER JOIN address a1 ON c1.ad_addrid = a1.ad_addrid
ENDTEXT
SqlCursor(lcSqlSelect,"_l",,,,,,.T.)
CFCursorNullsRemove(.T.,"_l")
INDEX ON ad_addrid TAG ad_addrid
TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT a1.* FROM (
		SELECT ad_addrid FROM resrooms
			INNER JOIN roomtype ON ri_roomtyp = rt_roomtyp
			INNER JOIN reservat ON ri_reserid = rs_reserid
			INNER JOIN address ON ad_addrid = rs_compid
			WHERE ri_date <= <<SqlCnv(tnLastDate,.T.)>> AND ri_todate >= <<SqlCnv(tnFirstDate,.T.)>> AND
			<<IIF(EMPTY(toForm.oSearchtunnel.SelStatus), "NOT INLIST(rs_status, 'CXL', 'NS ')", "rs_status = " + SqlCnv(toForm.oSearchtunnel.SelStatus,.T.))>><<lcWhere>>
			GROUP BY ad_addrid
		) c1 INNER JOIN address a1 ON c1.ad_addrid = a1.ad_addrid
ENDTEXT
SqlCursor(lcSqlSelect,"_c",,,,,,.T.)
CFCursorNullsRemove(.T.,"_c")
INDEX ON ad_addrid TAG ad_addrid
TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT a1.* FROM (
		SELECT ad_addrid FROM resrooms
			INNER JOIN roomtype ON ri_roomtyp = rt_roomtyp
			INNER JOIN reservat ON ri_reserid = rs_reserid
			INNER JOIN address ON ad_addrid = rs_saddrid
			WHERE ri_date <= <<SqlCnv(tnLastDate,.T.)>> AND ri_todate >= <<SqlCnv(tnFirstDate,.T.)>> AND
			<<IIF(EMPTY(toForm.oSearchtunnel.SelStatus), "NOT INLIST(rs_status, 'CXL', 'NS ')", "rs_status = " + SqlCnv(toForm.oSearchtunnel.SelStatus,.T.))>><<lcWhere>>
			GROUP BY ad_addrid
		) c1 INNER JOIN address a1 ON c1.ad_addrid = a1.ad_addrid
ENDTEXT
SqlCursor(lcSqlSelect,"_s",,,,,,.T.)
CFCursorNullsRemove(.T.,"_s")
INDEX ON ad_addrid TAG ad_addrid

SET RELATION TO rs_addrid INTO _l, rs_compid INTO _c, rs_saddrid INTO _s IN &lcurResrooms

TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT outoford.*, rm_roomtyp FROM outoford
		INNER JOIN room ON oo_roomnum = rm_roomnum
		INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp
		WHERE oo_fromdat <= <<SqlCnv(tnLastDate,.T.)>> AND oo_todat > <<SqlCnv(tnFirstDate,.T.)>> AND NOT oo_cancel<<STRTRAN(lcWhere,"ri_roomnum","oo_roomnum")>>
ENDTEXT
lcurOutoford = SqlCursor(lcSqlSelect)

TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT outofser.*, rm_roomtyp FROM outofser
		INNER JOIN room ON os_roomnum = rm_roomnum
		INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp
		WHERE os_fromdat <= <<SqlCnv(tnLastDate,.T.)>> AND os_todat > <<SqlCnv(tnFirstDate,.T.)>> AND NOT os_cancel<<STRTRAN(lcWhere,"ri_roomnum","os_roomnum")>>
ENDTEXT
lcurOutofser = SqlCursor(lcSqlSelect)

SELECT (lcurResrooms)
SCAN
	lcLinked = get_rm_rmname(ri_roomnum, "rm_link", toRpSession)
	lnLine = ASCAN(toForm.RoomNumber,ri_roomnum,lnStartLine,0,1,14) - toForm.FirstLine + 1
	lcKey = "R"+TRANSFORM(ri_rroomid)
	IF BETWEEN(lnLine, tnFirstLine, tnLastLine) AND toForm.RoomsInf[lnLine, 5].FindData(lcKey) = 0
		RpDisplay1Reservation(toForm, lnLine, lcurResrooms,,toRpSession)
	ENDIF
	IF NOT EMPTY(lcLinked)
		FOR i = 1 TO GETWORDCOUNT(lcLinked, ",")
			lnLine = ASCAN(toForm.RoomNumber,PADR(GETWORDNUM(lcLinked,i,","),4),lnStartLine,0,1,14) - toForm.FirstLine + 1
			lcKey = "L"+TRANSFORM(ri_rroomid)
			IF BETWEEN(lnLine, tnFirstLine, tnLastLine) AND toForm.RoomsInf[lnLine, 5].FindData(lcKey) = 0
				RpDisplay1Reservation(toForm, lnLine, lcurResrooms, .T., toRpSession)
			ENDIF
		NEXT
	ENDIF
ENDSCAN
SELECT (lcurOutoford)
SCAN
	lcLinked = get_rm_rmname(oo_roomnum, "rm_link", toRpSession)
	lnLine = ASCAN(toForm.RoomNumber,oo_roomnum,lnStartLine,0,1,14) - toForm.FirstLine + 1
	lcKey = "O"+TRANSFORM(oo_id)
	IF BETWEEN(lnLine, tnFirstLine, tnLastLine) AND toForm.RoomsInf[lnLine, 5].FindData(lcKey) = 0
		RpDisplayOooLine(toForm, lnLine, lcurOutoford, toRpSession)
	ENDIF
	IF NOT EMPTY(lcLinked)
		FOR i = 1 TO GETWORDCOUNT(lcLinked, ",")
			lnLine = ASCAN(toForm.RoomNumber,PADR(GETWORDNUM(lcLinked,i,","),4),lnStartLine,0,1,14) - toForm.FirstLine + 1
			IF BETWEEN(lnLine, tnFirstLine, tnLastLine) AND toForm.RoomsInf[lnLine, 5].FindData(lcKey) = 0
				RpDisplayOooLine(toForm, lnLine, lcurOutoford, toRpSession)
			ENDIF
		NEXT
	ENDIF
ENDSCAN
SELECT (lcurOutofser)
SCAN
	lcLinked = get_rm_rmname(os_roomnum, "rm_link", toRpSession)
	lnLine = ASCAN(toForm.RoomNumber,os_roomnum,lnStartLine,0,1,14) - toForm.FirstLine + 1
	lcKey = "S"+TRANSFORM(os_id)
	IF BETWEEN(lnLine, tnFirstLine, tnLastLine) AND toForm.RoomsInf[lnLine, 5].FindData(lcKey) = 0
		RpDisplayOosLine(toForm, lnLine, lcurOutofser, toRpSession)
	ENDIF
	IF NOT EMPTY(lcLinked)
		FOR i = 1 TO GETWORDCOUNT(lcLinked, ",")
			lnLine = ASCAN(toForm.RoomNumber,PADR(GETWORDNUM(lcLinked,i,","),4),lnStartLine,0,1,14) - toForm.FirstLine + 1
			IF BETWEEN(lnLine, tnFirstLine, tnLastLine) AND toForm.RoomsInf[lnLine, 5].FindData(lcKey) = 0
				RpDisplayOosLine(toForm, lnLine, lcurOutofser, toRpSession)
			ENDIF
		NEXT
	ENDIF
ENDSCAN

DClose(lcurOutoford)
DClose(lcurOutofser)
DClose(lcurResrooms)
DClose("_l")
DClose("_c")
DClose("_s")

SELECT (lnArea)
ENDPROC
*
PROCEDURE RpDisplay1Reservation
* Displays one reservation - selected in table Reservat.
LPARAMETERS toForm, tnLineNum, tcResAlias, tlLinked, toRpSession
LOCAL lnArea, lnRoomnumPeriods, llAddressIntervals, lcurAdrint
LOCAL i, lnStart, lnEnd, loReservation, lnFirstDateOffset, lnLineStart
LOCAL ARRAY l_aTempAdrInt(1)

PRIVATE pcHotCode
pcHotCode = IIF(VARTYPE(toRpSession) = "O", toRpSession.cHotCode, "")

lnArea = SELECT()

SELECT &tcResAlias

toForm.NewTextLine()

DO CASE
	CASE rs_status = "TEN"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkTENColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.FrTENColor, gr_color)
	CASE rs_status = "6PM"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.Bk6PMColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.Fr6PMColor, gr_color)
	CASE rs_status = "ASG"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkAssignColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.FrAssignColor, gr_color)
	CASE rs_status = "DEF"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkDeffiniteColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.FrDeffiniteColor, gr_color)
	CASE rs_status = "IN"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkInColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.FrInColor, gr_color)
	CASE rs_status = "OUT"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkOutColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.FrOutColor, gr_color)
	CASE rs_status = "OPT"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkOptionColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.FrOptionColor, gr_color)
	CASE rs_status = "LST"
		toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkWaitingColor
		toForm.Pool[toForm.ActiveHead].ForeColor = IIF(gr_color = 0, g_oPredefinedColors.FrWaitingColor, gr_color)
	OTHERWISE
		toForm.ActiveHead = toForm.ActiveHead - 1
		RETURN .F.
ENDCASE
toForm.Pool[toForm.ActiveHead].Hotcode = pcHotCode
toForm.Pool[toForm.ActiveHead].SelectedBorderColor = g_oPredefinedColors.IntSelColor
IF toForm.lRCColor AND NOT Odbc()
	toForm.Pool[toForm.ActiveHead].ForeColor = ProcRatecode("GetRatecodeColor", ALIAS(), toForm.Pool[toForm.ActiveHead].ForeColor)
ENDIF

toForm.Pool[toForm.ActiveHead].Top = toForm.GreenBk.Top + (tnLineNum - 1) * toForm.ColumnHeight
toForm.Pool[toForm.ActiveHead].BkLeft = toForm.GreenBk.Left + (ri_date - toForm.FirstDate + 1) * toForm.ColumnWidth
toForm.Pool[toForm.ActiveHead].BkWidth = MAX(ri_todate - ri_date + 1, 1) * toForm.ColumnWidth

IF _screen.oGlobal.oParam2.pa_noaddr AND rs_noaddr
	IF NOT ALLTRIM(rs_lname) == RESADDR_GUEST_NOT_SELECTED
		lcurAdrint = PAResAddrGetRestGuestNames(toForm.CheckResObj,tcResAlias,,.T.)
	ENDIF
	DIMENSION toForm.Pool[toForm.ActiveHead].AdrInt(1)
	STORE .F. TO toForm.Pool[toForm.ActiveHead].AdrInt
	IF NOT EMPTY(lcurAdrint) AND USED(lcurAdrint) AND RECCOUNT(lcurAdrint) > 0
		SELECT changed_fromday, changed_today, cur_arrdate, cur_depdate, rg_title, rg_fname, rg_lname, rg_country ;
			FROM (lcurAdrint) INTO ARRAY l_aTempAdrInt
		ACOPY(l_aTempAdrInt, toForm.Pool[toForm.ActiveHead].AdrInt)
		llAddressIntervals = .T.
	ENDIF
	DClose(lcurAdrint)
	SELECT (tcResAlias)
ENDIF

toForm.Pool[toForm.ActiveHead].Caption = RpGetCaption(toForm, tcResAlias, "RES", llAddressIntervals, toRpSession)
toForm.Pool[toForm.ActiveHead].SpecialCaption = NOT EMPTY(rs_group)
toForm.Pool[toForm.ActiveHead].ToolTipText = RpGetToolTipText(toForm, tcResAlias, "RES", llAddressIntervals, toRpSession)

SCATTER FIELDS rs_rsid, rs_reserid, rs_arrdate, rs_depdate, rs_lname, rs_company, rs_roomnum, rs_roomtyp, rs_altid, rs_status, rs_noaddr NAME toForm.Pool[toForm.ActiveHead].ResData
DO CASE
	CASE tlLinked
		* for composite rooms (rm_link <> "")
		toForm.Pool[toForm.ActiveHead].ReserId = -rs_reserid
		toForm.Pool[toForm.ActiveHead].ResRoomId = -ri_rroomid
		toForm.Pool[toForm.ActiveHead].p_lType = "L"
	CASE rs_arrdate < ri_date OR rs_depdate-1 > ri_todate
		* for variable rooms changed in resrooms
		toForm.Pool[toForm.ActiveHead].ReserId = rs_reserid
		toForm.Pool[toForm.ActiveHead].ResRoomId = ri_rroomid
		toForm.Pool[toForm.ActiveHead].p_lType = "I"
	OTHERWISE
		toForm.Pool[toForm.ActiveHead].ReserId = rs_reserid
		toForm.Pool[toForm.ActiveHead].ResRoomId = ri_rroomid
		toForm.Pool[toForm.ActiveHead].p_lType = "R"
ENDCASE
toForm.Pool[toForm.ActiveHead].lHasDocument = NOT EMPTY(dc_reserid)
toForm.Pool[toForm.ActiveHead].ArrPosition = toForm.ActiveHead
toForm.Pool[toForm.ActiveHead].Beyond = .F.

lnFirstDateOffset = ri_date - toForm.FirstDate
lnStart = MAX(1, lnFirstDateOffset+2)
lnEnd = MAX(lnStart, MIN(ri_todate-toForm.FirstDate+2, toForm.VisibleDays))
FOR i = lnStart TO lnEnd
	loReservation = toForm.GetResObjectAt(i, tnLineNum)
	IF NOT ISNULL(loReservation) AND (ISNULL(toForm.MovingReser) OR toForm.MovingReser <> loReservation)
		lnLineStart = ROUND((toForm.Pool[toForm.ActiveHead].BkLeft-loReservation.BkLeft)/toForm.ColumnWidth, 0) + i-lnFirstDateOffset-1
		loReservation.Beyond = .T.
		loReservation.AddBeyond(lnLineStart)
		toForm.Pool[toForm.ActiveHead].Beyond = .T.
		toForm.Pool[toForm.ActiveHead].AddBeyond(i-lnFirstDateOffset-1)
		toForm.Pool[toForm.ActiveHead].ZOrder()
	ENDIF
NEXT
toForm.RoomsInf[tnLineNum, 5].Add(toForm.Pool[toForm.ActiveHead],IIF(tlLinked,"L","R")+TRANSFORM(ri_rroomid))
toForm.Pool[toForm.ActiveHead].Visible = .T.

IF toForm.cFormLabel = "GROOMPLAN" AND TYPE("toForm.nAllotID") = "N" AND NOT EMPTY(toForm.nAllotID)
	IF rs_altid <> toForm.nAllotID OR INLIST(rs_status, "CXL", "NS") OR rt_group = 2
		toForm.Pool[toForm.ActiveHead].BackColor = ConvColors(toForm.Pool[toForm.ActiveHead].BackColor, 3)
	ENDIF
	toForm.Pool[toForm.ActiveHead].lHasBill = ProcReservat("GetDummyBill", rs_rsid)
ENDIF

SELECT (lnArea)
ENDPROC
*
PROCEDURE RpDisplayOooLine
* Displays OOO inf. for one room (line).
LPARAMETERS toForm, tnLineNum, tcOooAlias, toRpSession
LOCAL i, lnNights, lnStart, lnEnd, loReservation, llFound, lnFirstDateOffset, lnLineStart

PRIVATE pcHotCode
pcHotCode = IIF(VARTYPE(toRpSession) = "O", toRpSession.cHotCode, "")

SELECT &tcOooAlias

lnNights = oo_todat - oo_fromdat

toForm.NewTextLine()
toForm.Pool[toForm.ActiveHead].Hotcode = pcHotCode
toForm.Pool[toForm.ActiveHead].p_lType = "O"
toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkOOOColor
toForm.Pool[toForm.ActiveHead].ForeColor = g_oPredefinedColors.FrOOOColor
toForm.Pool[toForm.ActiveHead].Top = toForm.GreenBk.Top + (tnLineNum - 1)* toForm.ColumnHeight
toForm.Pool[toForm.ActiveHead].BkLeft = toForm.GreenBk.Left + (oo_fromdat - toForm.FirstDate + 1) * toForm.ColumnWidth
toForm.Pool[toForm.ActiveHead].BkWidth = MAX(lnNights, 1) * toForm.ColumnWidth
toForm.Pool[toForm.ActiveHead].Caption = RpGetCaption(toForm, tcOooAlias, "OOO",,toRpSession)
toForm.Pool[toForm.ActiveHead].SpecialCaption = .F.
toForm.Pool[toForm.ActiveHead].ReserId = -oo_id
toForm.Pool[toForm.ActiveHead].ArrPosition = toForm.ActiveHead
toForm.Pool[toForm.ActiveHead].Selected = .F.
toForm.Pool[toForm.ActiveHead].Beyond = .F.
toForm.Pool[toForm.ActiveHead].ToolTipText = RpGetToolTipText(toForm, tcOooAlias, "OOO",,toRpSession)

lnFirstDateOffset = oo_fromdat - toForm.FirstDate
lnStart = MAX(1, lnFirstDateOffset+2)
lnEnd = MAX(lnStart, MIN(oo_todat-toForm.FirstDate+1, toForm.VisibleDays))
FOR i = lnStart TO lnEnd
	loReservation = toForm.GetResObjectAt(i, tnLineNum)
	IF NOT ISNULL(loReservation) AND (ISNULL(toForm.MovingReser) OR toForm.MovingReser <> loReservation)
		lnLineStart = ROUND((toForm.Pool[toForm.ActiveHead].BkLeft-loReservation.BkLeft)/toForm.ColumnWidth, 0) + i-lnFirstDateOffset-1
		loReservation.Beyond = .T.
		loReservation.AddBeyond(lnLineStart)
		toForm.Pool[toForm.ActiveHead].Beyond = .T.
		toForm.Pool[toForm.ActiveHead].AddBeyond(i-lnFirstDateOffset-1)
		toForm.Pool[toForm.ActiveHead].ZOrder()
	ENDIF
NEXT
toForm.RoomsInf[tnLineNum, 5].Add(toForm.Pool[toForm.ActiveHead], "O"+TRANSFORM(oo_id))
toForm.Pool[toForm.ActiveHead].Visible = .T.
ENDPROC
*
PROCEDURE RpDisplayOosLine
* Displays OOS inf. for one room (line).
LPARAMETERS toForm, tnLineNum, tcOosAlias, toRpSession
LOCAL i, lnNights, lnStart, lnEnd, loReservation, llFound, lnFirstDateOffset, lnLineStart

PRIVATE pcHotCode
pcHotCode = IIF(VARTYPE(toRpSession) = "O", toRpSession.cHotCode, "")

SELECT &tcOosAlias

lnNights = os_todat - os_fromdat

toForm.NewTextLine()
toForm.Pool[toForm.ActiveHead].Hotcode = pcHotCode
toForm.Pool[toForm.ActiveHead].p_lType = "S"
toForm.Pool[toForm.ActiveHead].BackColor = g_oPredefinedColors.BkOOSColor
toForm.Pool[toForm.ActiveHead].ForeColor = g_oPredefinedColors.FrOOSColor
toForm.Pool[toForm.ActiveHead].Top = toForm.GreenBk.Top + (tnLineNum - 1)* toForm.ColumnHeight
toForm.Pool[toForm.ActiveHead].BkLeft = toForm.GreenBk.Left + (os_fromdat - toForm.FirstDate + 1) * toForm.ColumnWidth
toForm.Pool[toForm.ActiveHead].BkWidth = MAX(lnNights, 1) * toForm.ColumnWidth
toForm.Pool[toForm.ActiveHead].Caption = RpGetCaption(toForm, tcOosAlias, "OOS",,toRpSession)
toForm.Pool[toForm.ActiveHead].SpecialCaption = .F.
toForm.Pool[toForm.ActiveHead].ReserId = -os_id
toForm.Pool[toForm.ActiveHead].ArrPosition = toForm.ActiveHead
toForm.Pool[toForm.ActiveHead].Selected = .F.
toForm.Pool[toForm.ActiveHead].Beyond = .F.
toForm.Pool[toForm.ActiveHead].ToolTipText = RpGetToolTipText(toForm, tcOosAlias, "OOS",,toRpSession)

lnFirstDateOffset = os_fromdat - toForm.FirstDate
lnStart = MAX(1, lnFirstDateOffset+2)
lnEnd = MAX(lnStart, MIN(os_todat-toForm.FirstDate+1, toForm.VisibleDays))
FOR i = lnStart TO lnEnd
	loReservation = toForm.GetResObjectAt(i, tnLineNum)
	IF NOT ISNULL(loReservation) AND (ISNULL(toForm.MovingReser) OR toForm.MovingReser <> loReservation)
		lnLineStart = ROUND((toForm.Pool[toForm.ActiveHead].BkLeft-loReservation.BkLeft)/toForm.ColumnWidth, 0) + i-lnFirstDateOffset-1
		loReservation.Beyond = .T.
		loReservation.AddBeyond(lnLineStart)
		toForm.Pool[toForm.ActiveHead].Beyond = .T.
		toForm.Pool[toForm.ActiveHead].AddBeyond(i-lnFirstDateOffset-1)
		toForm.Pool[toForm.ActiveHead].ZOrder()
	ENDIF
NEXT
toForm.RoomsInf[tnLineNum, 5].Add(toForm.Pool[toForm.ActiveHead], "S"+TRANSFORM(os_id))
toForm.Pool[toForm.ActiveHead].Visible = .T.
ENDPROC
*
PROCEDURE RpGetCaption
LPARAMETERS toForm, tcAlias, tcObject, tlAddressIntervals, toRpSession
LOCAL i, lnArea, lcCaption, lcUDCaption, lcTTTName, lcRoomName, lcRoomType, lcNote, lcurAddress, lcHotCode

lnArea = SELECT()
lcHotCode = IIF(VARTYPE(toRpSession) = "O", toRpSession.cHotCode, "")

PRIVATE pcHotCode
pcHotCode = lcHotCode

SELECT &tcAlias
lcUDCaption = toForm.ResCaption.GetCaption(tcObject, toRpSession)
lcCaption = ""

DO CASE
	CASE NOT EMPTY(lcUDCaption)
		lcCaption = lcUDCaption
	CASE tcObject = "RES"
		IF INLIST(toForm.cFormLabel, "CONFPLAN", "CONFDPLAN")
			DO CASE
				CASE NOT EMPTY(rs_group) AND _screen.oGlobal.oParam.pa_confgrp
					lcCaption = rs_group
				CASE NOT EMPTY(rs_company)
					lcCaption = rs_company
				CASE NOT EMPTY(rs_agent) AND _screen.oGlobal.oParam.pa_confgrp
					lcCaption = rs_agent
				OTHERWISE
					lcCaption = rs_lname
			ENDCASE
			lcCaption = ALLTRIM(IIF(_screen.oGlobal.oParam.pa_rsus3 AND NOT EMPTY(rs_usrres3), "#", "") + ALLTRIM(rs_cnfstat) + " " + PROPER(ALLTRIM(lcCaption)) + " " + ;
				IIF(rs_depdate - rs_arrdate < 2, TRANSFORM(rs_adults+rs_childs+rs_childs2+rs_childs3), TRANSFORM(rs_adults) + "/" + TRANSFORM(rs_childs)))
		ELSE
			DO CASE
				CASE EMPTY(rs_lname)
					lcCaption = ALLTRIM(_c.ad_company)
				CASE NOT _screen.oGlobal.oParam2.pa_noaddr OR NOT rs_noaddr
					lcCaption = IIF(_screen.oGlobal.oParam.pa_rsus3 AND NOT EMPTY(rs_usrres3), "#", "") + MakeProperName(rs_lname) + ;
						IIF(EMPTY(rs_sname), "", "/"+ALLTRIM(_s.ad_lname))
				CASE tlAddressIntervals
					lcCaption = IIF(_screen.oGlobal.oParam.pa_rsus3 AND NOT EMPTY(rs_usrres3), "#", "") + "|" + ADR_INT_SIGN + "|" + ;
						IIF(EMPTY(rs_sname), "", "/"+ALLTRIM(_s.ad_lname))
				OTHERWISE
					lcCaption = " " + RESADDR_GUEST_NOT_SELECTED + " " + ALLTRIM(_c.ad_company)
			ENDCASE
		ENDIF
	CASE tcObject = "OOO"
		lcCaption = ALLTRIM(oo_reason)
	CASE tcObject = "OOS"
		lcCaption = ALLTRIM(os_reason)
	CASE tcObject = "ROOM"
		DO CASE
			CASE toForm.cFormLabel = "MPROOMPLAN"
				lcCaption = Get_rm_rmname(rm_roomnum,,toRpSession) + " " + Get_rt_roomtyp(rm_roomtyp, "ALLTRIM(rd_roomtyp)",,toRpSession) + " ("+ALLTRIM(lcHotCode)+")"
			OTHERWISE
				lcCaption = Get_rm_rmname(rm_roomnum,,toRpSession) + " " + Get_rt_roomtyp(rm_roomtyp, "ALLTRIM(rd_roomtyp)+IIF(EMPTY(rt_buildng), [], [ (]+ALLTRIM(rt_buildng)+[)])",,toRpSession)
		ENDCASE
	OTHERWISE
ENDCASE

SELECT (lnArea)

RETURN lcCaption
ENDPROC
*
PROCEDURE RpGetToolTipText
LPARAMETERS toForm, tcAlias, tcObject, tlAddressIntervals, toRpSession
LOCAL i, lnArea, lcToolTipText, lcUDToolTipText, lcTTTName, lcFeature, lcFeatVal, lcRoomName, lcRoomType, lcNote, lcurAddress, lcHotCode
LOCAL llConf, lnMaxPers, lnConfGroupId, lnOccupied

lnArea = SELECT()
llConf = INLIST(toForm.cFormLabel, "CONFPLAN", "CONFDPLAN")
lcHotCode = IIF(VARTYPE(toRpSession) = "O", toRpSession.cHotCode, "")

PRIVATE pcHotCode
pcHotCode = lcHotCode

SELECT &tcAlias
lcUDToolTipText = toForm.ResCaption.GetToolTipText(tcObject, toRpSession)
lcToolTipText = "|%TTTCAPTION%|\n|#TTTHEADER1#|"

DO CASE
	CASE NOT EMPTY(lcUDToolTipText)
		lcToolTipText = lcUDToolTipText
		IF NOT toForm.lLargetooltip
			lcToolTipText = STRTRAN(lcToolTipText, "|%"+STREXTRACT(lcToolTipText,"|%","%|")+"%|")
			DO WHILE NOT EMPTY(STREXTRACT(lcToolTipText,"|#","#|"))
				lcToolTipText = STRTRAN(lcToolTipText, "|#"+STREXTRACT(lcToolTipText,"|#","#|")+"#|")
			ENDDO
		ENDIF
	CASE tcObject = "RES"
		IF TYPE("ri_roomnum") = "C"
			lcRoomName = ri_roomnum
			lcRoomType = ri_roomtyp
		ELSE
			lcRoomName = rs_roomnum
			lcRoomType = rs_roomtyp
		ENDIF
		lcTTTName = ""
		IF NOT EMPTY(rs_lname)
			DO CASE
				CASE tlAddressIntervals
					lcTTTName = lcTTTName + ADR_INT_GUEST
				CASE rs_addrid = rs_compid AND NOT EMPTY(rs_apname) AND NOT EMPTY(ap_lname)
					IF NOT EMPTY(ap_title)
						lcTTTName = lcTTTName + " " + ALLTRIM(ap_title)
					ENDIF
					IF NOT EMPTY(ap_fname)
						lcTTTName = lcTTTName + " " + ALLTRIM(ap_fname)
					ENDIF
					IF NOT EMPTY(ap_lname)
						lcTTTName = lcTTTName + " " + Flip(ALLTRIM(ap_lname))
					ENDIF
				CASE _screen.oGlobal.oParam2.pa_noaddr AND rs_noaddr
					IF NOT EMPTY(rs_title)
						lcTTTName = lcTTTName + " " + ALLTRIM(rs_title)
					ENDIF
					IF NOT EMPTY(rs_fname)
						lcTTTName = lcTTTName + " " + ALLTRIM(rs_fname)
					ENDIF
					IF NOT EMPTY(rs_lname)
						lcTTTName = lcTTTName + " " + ALLTRIM(rs_lname)
					ENDIF
				OTHERWISE
					IF NOT EMPTY(_l.ad_title)
						lcTTTName = lcTTTName + " " + ALLTRIM(_l.ad_title)
					ENDIF
					IF NOT EMPTY(_l.ad_fname)
						lcTTTName = lcTTTName + " " + ALLTRIM(_l.ad_fname)
					ENDIF
					IF NOT EMPTY(_l.ad_lname)
						lcTTTName = lcTTTName + " " + Flip(ALLTRIM(_l.ad_lname))
					ENDIF
			ENDCASE
			lcToolTipText = lcToolTipText + "\n" + toForm.NameText + ":" + lcTTTName
			IF NOT EMPTY(rs_sname)
				lcToolTipText = lcToolTipText + "\n" + toForm.SNameText + ":"
				IF EMPTY(rs_saddrid)
					lcToolTipText = lcToolTipText + " " + MakeProperName(rs_sname)
				ELSE
					IF NOT EMPTY(_s.ad_title)
						lcToolTipText = lcToolTipText + " " + ALLTRIM(_s.ad_title)
					ENDIF
					IF NOT EMPTY(_s.ad_fname)
						lcToolTipText = lcToolTipText + " " + ALLTRIM(_s.ad_fname)
					ENDIF
					IF NOT EMPTY(_s.ad_lname)
						lcToolTipText = lcToolTipText + " " + Flip(ALLTRIM(_s.ad_lname))
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		IF NOT EMPTY(rs_company)
			lcToolTipText = lcToolTipText + "\n" + toForm.CompText + ": " + ALLTRIM(_c.ad_company)
		ENDIF
		lcToolTipText = lcToolTipText + "\n|#TTTHEADER2#|"
		IF NOT EMPTY(rs_group)
			lcToolTipText = lcToolTipText + "\n" + toForm.GroupText + ": " + ALLTRIM(rs_group)
		ENDIF
		IF NOT EMPTY(rs_altid)
			lcToolTipText = lcToolTipText + "\n" + toForm.AllottText + ": " + ALLTRIM(al_allott)
		ENDIF

		IF TYPE("ri_date") = "D" AND (rs_arrdate < ri_date OR rs_depdate-1 > ri_todate)
			lcToolTipText = lcToolTipText + "\n" + toForm.InRoomText + ": " + Get_rm_rmname(rs_roomnum,,toRpSession)
		ENDIF

		lcToolTipText = lcToolTipText + "\n" + toForm.FromToText + ": " + IIF(tlAddressIntervals, ADR_INT_DATES, DTOC(rs_arrdate) + " - " + DTOC(rs_depdate))
		IF NOT EMPTY(rs_orgarrd)
			lcToolTipText = lcToolTipText + "\n" + toForm.MovedToText + ": " + DTOC(rs_orgarrd)
		ENDIF
		IF NOT EMPTY(rs_optdate)
			lcToolTipText = lcToolTipText + "\n" + toForm.OptionText + ": " + DTOC(rs_optdate)
		ENDIF
		IF llConf
			lcToolTipText = lcToolTipText + "\n" + toForm.FromToTimeText + ": " + rs_arrtime + " - " + rs_deptime
		ENDIF
		lcToolTipText = lcToolTipText + "\n" + toForm.AddultsText + ": " + TRANSFORM(rs_adults)
		IF NOT EMPTY(rs_childs + rs_childs2 + rs_childs3)
			lcToolTipText = lcToolTipText + "\n" + toForm.ChildsText + ": " + TRANSFORM(rs_childs + rs_childs2 + rs_childs3)
		ENDIF
		IF toForm.lLargetooltip AND NOT EMPTY(c_feature)
			lcFeature = ""
			FOR i = 1 TO GETWORDCOUNT(c_feature, ",")
				lcFeatVal = PADR(ALLTRIM(GETWORDNUM(c_feature, i, ",")),3)
				lcFeature = lcFeature + IIF(EMPTY(lcFeature), "", "\n:") + lcFeatVal + " - " + toForm.GetFeatText(,lcFeatVal, lcHotCode)
			NEXT
		ELSE
			lcFeature = ALLTRIM(c_feature)
		ENDIF
		IF NOT EMPTY(lcFeature)
			lcToolTipText = lcToolTipText + "\n" + toForm.FeaturesText + ": " + lcFeature
		ENDIF

		IF _l.ad_vip OR _c.ad_vip
			lcToolTipText = lcToolTipText + "\nVIP"
		ENDIF

		IF _screen.oGlobal.oParam.pa_rsus3 AND (NOT EMPTY(rs_usrres3) OR SUBSTR(_screen.oGlobal.oParam.pa_setusre,3,1) = "C")
			lcToolTipText = lcToolTipText + "\n" + ALLTRIM(_screen.oGlobal.oParam.pa_usrres3) + ": " + ICASE(SUBSTR(_screen.oGlobal.oParam.pa_setusre,3,1) = "T", rs_usrres3, EMPTY(rs_usrres3), GetLangText("AR","T_NO"), GetLangText("AR","T_YES"))
		ENDIF
		*lcToolTipText = lcToolTipText + "\n" + toForm.BedsText + ": " + TRANSFORM(Get_rm_rmname(lcRoomName, "rm_beds", toRpSession))
		*lcToolTipText = lcToolTipText + "\n" + toForm.MaxPersText + ": " + TRANSFORM(Get_rm_rmname(lcRoomName, "rm_maxpers", toRpSession))
		lcToolTipText = lcToolTipText + "\n|#TTTHEADER3#|"
		lcToolTipText = lcToolTipText + "\n" + toForm.RateCodeText + ": " + ALLTRIM(rs_ratecod)
		lcToolTipText = lcToolTipText + "\n" + toForm.PriceText + ": " + ALLTRIM(STR(rs_rate,10,2))
		IF llConf
			lcToolTipText = lcToolTipText + "\n" + toForm.SeatsText + ": " + toForm.GetSeatsForReser(rs_reserid)
		ENDIF
		lcNote = ProcRatecode("GetRatecode", rs_reserid, MAX(rs_arrdate, SysDate()), "rc_note")
		lcNote = STRTRAN(ALLTRIM(lcNote,0,CRLF), CRLF, IIF(toForm.lLargetooltip, "\n:", "\n"))
		lcToolTipText = lcToolTipText + "\n" + toForm.NoteText + ": " + lcNote
		IF llConf AND NOT EMPTY(CHRTRAN(rs_arrtime,"0:","")) AND EVL(Get_rt_roomtyp(lcRoomType, "rt_group = 2 AND rt_confev",,toRpSession),.F.)
			lnMaxPers = Get_rm_rmname(lcRoomName, "rm_maxpers", toRpSession)
			IF lnMaxPers > 0
				lnConfGroupId = DLookUp("rescfgue", "rj_crsid = " + SqlCnv(rs_rsid,.T.), "rj_cgid")
				CALCULATE COUNT() FOR rj_cgid = lnConfGroupId AND NOT rj_deleted TO lnOccupied IN rescfgue
				lcToolTipText = lcToolTipText + "\n" + toForm.ConfGroupText + ": " + TRANSFORM(lnOccupied) + "/" + TRANSFORM(lnMaxPers)
			ENDIF
		ENDIF
		IF toForm.lLargetooltip
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n", "|%" + Get_rm_rmname(lcRoomName,,toRpSession) + " (" + Get_rt_roomtyp(lcRoomType,,,toRpSession) + ") " + lcTTTName + "%|")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|\n", "|#" + toForm.TTTHeaderAddress + "#|")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER2#|\n", "|#" + toForm.TTTHeaderReservat + "#|")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER3#|\n", "|#" + toForm.TTTHeaderPrice + "#|")
		ELSE
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|\n")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER2#|\n")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER3#|\n")
		ENDIF
	CASE tcObject = "OOO"
		lcToolTipText = lcToolTipText + "\n" + toForm.FromToText + ": " + DTOC(oo_fromdat) + " - " + DTOC(oo_todat)
		lcToolTipText = lcToolTipText + "\n" + toForm.ReasonText + ": " + ALLTRIM(oo_reason)
		IF toForm.lLargetooltip
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n", "|%" + Get_rm_rmname(oo_roomnum,,toRpSession) + " (" + Get_rt_roomtyp(rm_roomtyp,,,toRpSession) + ") " + ALLTRIM(oo_reason) + "%|")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|\n", "|#" + toForm.TTTHeaderOOO + "#|")
		ELSE
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|", toForm.TTTHeaderOOO)
		ENDIF
	CASE tcObject = "OOS"
		lcToolTipText = lcToolTipText + "\n" + toForm.FromToText + ": " + DTOC(os_fromdat) + " - " + DTOC(os_todat)
		lcToolTipText = lcToolTipText + "\n" + toForm.ReasonText + ": " + ALLTRIM(os_reason)
		IF toForm.lLargetooltip
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n", "|%" + Get_rm_rmname(os_roomnum,,toRpSession) + " (" + Get_rt_roomtyp(rm_roomtyp,,,toRpSession) + ") " + ALLTRIM(os_reason) + "%|")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|\n", "|#" + toForm.TTTHeaderOOS + "#|")
		ELSE
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|", toForm.TTTHeaderOOS)
		ENDIF
	CASE tcObject = "ROOM"
		lcRoomName = Get_rm_rmname(rm_roomnum,,toRpSession)
		lcDescript = Get_rm_rmname(rm_roomnum, "rm_lang", toRpSession)
		lcRoomType = Get_rt_roomtyp(rm_roomtyp, "rt_lang",,toRpSession)
		IF NOT toForm.lLargetooltip
			lcToolTipText = lcToolTipText + "\n" + toForm.RoomText + ": " + lcRoomName + IIF(llConf, " (" + lcDescript + ")", "")
			lcToolTipText = lcToolTipText + "\n" + toForm.TypeText + ": " + lcRoomType
		ENDIF
		IF llConf
			lcToolTipText = lcToolTipText + toForm.GetSeatsForRoom(rm_roomnum)
		ELSE
			lcToolTipText = lcToolTipText + "\n" + toForm.BuildingText + ": " + Get_rt_roomtyp(rm_roomtyp, "bu_lang",,toRpSession)
			lcToolTipText = lcToolTipText + "\n" + toForm.FloorText + ": " + TRANSFORM(rm_floor)
			lcToolTipText = lcToolTipText + "\n" + toForm.BedsText + ": " + TRANSFORM(rm_beds)
			lcToolTipText = lcToolTipText + "\n" + toForm.MaxPersText + ": " + TRANSFORM(rm_maxpers)
		ENDIF
		IF NOT EMPTY(rm_phone)
			lcToolTipText = lcToolTipText + "\n" + toForm.PhoneText + ": " + ALLTRIM(rm_phone)
		ENDIF
		lcToolTipText = lcToolTipText + "\n" + toForm.FeaturesText + ": " + toForm.GetFeatText(rm_roomnum,,lcHotCode)
		lcToolTipText = lcToolTipText + "\n" + toForm.CommentText + ": " + TRANSFORM(rm_comment)
		IF llConf AND toForm.p_ShowDayIntervalsInTT
			lcToolTipText = lcToolTipText + "\n" + toForm.DaypartsText + ": " + toForm.DaypartsValue
		ENDIF
		IF toForm.lLargetooltip
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n", "|%" + lcRoomName + " (" + lcRoomType + ")%|")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|\n", "|#" + toForm.TTTHeaderRoom + "#|")
		ELSE
			lcToolTipText = STRTRAN(lcToolTipText, "|%TTTCAPTION%|\n")
			lcToolTipText = STRTRAN(lcToolTipText, "|#TTTHEADER1#|\n")
		ENDIF
	OTHERWISE
ENDCASE

SELECT (lnArea)

RETURN lcToolTipText + "\n"
ENDPROC
*
PROCEDURE TrCreateTblDayParts
LOCAL luRetval, loDayParts, lcDayParts

lcDayParts = GetLangText("ARGUS", "TXT_DAYPARTS")

CREATE CURSOR tblDayParts (c_dpid N(1), c_caption C(15), c_start C(5), c_end C(5), c_nstart C(5))
SCATTER NAME loDayParts

luRetval = ""
AOGetParam("pa_dpart11", @luRetval)
loDayParts.c_dpid = 1
loDayParts.c_caption = GETWORDNUM(lcDayParts,1,",")
loDayParts.c_start = EVL(luRetval, "08:00")
luRetval = ""
AOGetParam("pa_dpart12", @luRetval)
loDayParts.c_end = EVL(luRetval, "11:00")
INSERT INTO tblDayParts FROM NAME loDayParts

luRetval = ""
AOGetParam("pa_dpart21", @luRetval)
loDayParts.c_dpid = 2
loDayParts.c_caption = GETWORDNUM(lcDayParts,2,",")
loDayParts.c_start = EVL(luRetval, "12:00")
REPLACE c_nstart WITH loDayParts.c_start IN tblDayParts
luRetval = ""
AOGetParam("pa_dpart22", @luRetval)
loDayParts.c_end = EVL(luRetval, "16:00")
INSERT INTO tblDayParts FROM NAME loDayParts

luRetval = ""
AOGetParam("pa_dpart31", @luRetval)
loDayParts.c_dpid = 3
loDayParts.c_caption = GETWORDNUM(lcDayParts,3,",")
loDayParts.c_start = EVL(luRetval, "17:00")
REPLACE c_nstart WITH loDayParts.c_start IN tblDayParts
luRetval = ""
AOGetParam("pa_dpart32", @luRetval)
loDayParts.c_end = EVL(luRetval, "22:00")
loDayParts.c_nstart = "24:00"
INSERT INTO tblDayParts FROM NAME loDayParts
ENDPROC
*