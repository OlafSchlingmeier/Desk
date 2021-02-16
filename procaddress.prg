#INCLUDE "include\constdefines.h"
*
* ? PAResAddrChangeGuestTest(5574.100, {^2008-10-14})
* ? PAResAddrGetRestGuestNamesTest(207.100)
*
PROCEDURE AddressChanged
LPARAMETERS pl_oOldAddressData, pl_oNewAddressData, pl_cResAlias

IF ISNULL(pl_oOldAddressData)
	* New record, nothing to update in child records
	PAInsertPhones(pl_oNewAddressData)
	RETURN .T.
ENDIF
PAUpdatePhones(pl_oNewAddressData, pl_oOldAddressData)
IF EMPTY(pl_cResAlias)
	pl_cResAlias = "reservat"
ENDIF
IF USED(pl_cResAlias)
	IF pl_oOldAddressData.ad_lname <> pl_oNewAddressData.ad_lname
		ad_lname_change(@pl_oNewAddressData, pl_cResAlias)
	ENDIF
	IF pl_oOldAddressData.ad_company <> pl_oNewAddressData.ad_company
		ad_company_change(@pl_oNewAddressData, pl_cResAlias)
	ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE ad_lname_change
LPARAMETERS pl_oNewAddressData, pl_cResAlias
REPLACE rs_lname WITH UPPER(pl_oNewAddressData.ad_lname) ;
	FOR rs_addrid = pl_oNewAddressData.ad_addrid AND ;
	NOT (rs_addrid = rs_compid AND NOT rs_apname = "") IN &pl_cResAlias
IF param.pa_accomp = "11"
	REPLACE rs_sname WITH UPPER(pl_oNewAddressData.ad_lname) ;
		FOR rs_saddrid = pl_oNewAddressData.ad_addrid IN &pl_cResAlias
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE ad_company_change
LPARAMETERS pl_oNewAddressData, pl_cResAlias
REPLACE rs_company WITH UPPER(pl_oNewAddressData.ad_company) ;
	FOR rs_compid = pl_oNewAddressData.ad_addrid IN &pl_cResAlias
REPLACE rs_agent WITH UPPER(pl_oNewAddressData.ad_company) ;
	FOR rs_agentid = pl_oNewAddressData.ad_addrid IN &pl_cResAlias
ENDPROC
*
PROCEDURE AddrIntrests
LPARAMETERS lp_nAddrId, lp_cIntrestsString
lp_cIntrestsString = ""
IF SEEK(lp_nAddrId,"adrtoin","tag1")
	LOCAL l_nSelect
	l_nSelect = SELECT()
	SELECT ae_addrid, ae_abid, ab_abid, ab_descrip, UPPER(ab_descrip) AS ab_descupper ;
		FROM adrtoin LEFT JOIN adintrst ON ae_abid = ab_abid WHERE ae_addrid = lp_nAddrId ;
		ORDER BY ab_descupper INTO CURSOR curTempAdrtoin
	SCAN FOR NOT ISNULL(ab_descrip)
		lp_cIntrestsString = lp_cIntrestsString + TRIM(curTempAdrtoin.ab_descrip) + ", "
	ENDSCAN
	USE
	SELECT (l_nSelect)
	lp_cIntrestsString = LEFT(lp_cIntrestsString,LEN(lp_cIntrestsString)-2)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE AddrReservationIntervals
LPARAMETERS lp_nAddrId, lp_cResIntString
lp_cResIntString = ""
IF SEEK(lp_nAddrId,"adrtosi","tag1")
	LOCAL l_nSelect
	l_nSelect = SELECT()
	SELECT * FROM adrtosi LEFT JOIN adrstint ON ao_aiid = ai_aiid WHERE ao_addrid = lp_nAddrId ;
		ORDER BY ai_fromdat INTO CURSOR curTempAdrtosi
	SCAN FOR NOT ISNULL(ai_descrip)
		lp_cResIntString = lp_cResIntString + TRIM(curTempAdrtosi.ai_descrip) + ", "
	ENDSCAN
	USE
	SELECT (l_nSelect)
	lp_cResIntString = LEFT(lp_cResIntString,LEN(lp_cResIntString)-2)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE AddrAgreedRates
LPARAMETERS lp_nAddrId, lp_cRatecode, lp_nAmnt1, lp_nAmnt2, lp_nAmnt3, lp_nCamnt1, lp_nCamnt2, lp_nCamnt3
STORE 0 TO lp_nAmnt1, lp_nAmnt2, lp_nAmnt3, lp_nCamnt1, lp_nCamnt2, lp_nCamnt3
LOCAL l_cCur
lp_cRatecode = ""
IF SEEK(lp_nAddrId,'adrrates','tag1')
	lp_cRatecode = adrrates.af_ratecod
	IF adrrates.af_urcprc
		l_cCur = sqlcursor("SELECT TOP 1 rc_rcid, rc_amnt1, rc_amnt2, rc_amnt3, rc_camnt1, rc_camnt2, rc_camnt3 FROM ratecode WHERE rc_ratecod = "+ sqlcnv(lp_cRatecode,.T.) + " AND rc_todat >= " + sqlcnv(sysdate(),.T.) + " ORDER BY 1 DESC")
		IF USED(l_cCur) AND RECCOUNT(l_cCur)>0
			lp_nAmnt1 = &l_cCur..rc_amnt1
			lp_nAmnt2 = &l_cCur..rc_amnt2
			lp_nAmnt3 = &l_cCur..rc_amnt3
			lp_nCamnt1 = &l_cCur..rc_camnt1
			lp_nCamnt2 = &l_cCur..rc_camnt2
			lp_nCamnt3 = &l_cCur..rc_camnt3
		ENDIF
		dclose(l_cCur)
	ELSE
		lp_nAmnt1 = adrrates.af_amnt1
		lp_nAmnt2 = adrrates.af_amnt2
		lp_nAmnt3 = adrrates.af_amnt3
		lp_nCamnt1 = adrrates.af_camnt1
		lp_nCamnt2 = adrrates.af_camnt2
		lp_nCamnt3 = adrrates.af_camnt3
	ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE AddrLastContact
LPARAMETERS lp_nAddrId, lp_dContactDate, lp_cContactType, l_cNear
LOCAL l_nSelect, l_nOrder, l_dSysDate
lp_dContactDate = {}
lp_cContactType = ""
l_dSysDate = sysdate()
l_nSelect = SELECT()
l_cNear = SET("Near")
SET NEAR ON
SELECT document1
l_nOrder = ORDER()
SET ORDER TO TAG3 DESCENDING
= SEEK(PADR(lp_nAddrId,8)+DTOS(l_dSysDate))
IF dc_addrid = lp_nAddrId
	lp_dContactDate = dc_date
	lp_cContactType = GetDocumentType(dc_type)
ENDIF
SET ORDER TO l_nOrder
SET NEAR &l_cNear
IF _screen.OL
	SELECT * FROM einboxsn LEFT JOIN einbox ON eb_eiid = ei_eiid ;
			WHERE STR(eb_addrid,8)+STR(eb_apid,8) = STR(lp_nAddrId,8) AND TTOD(ei_datime) > lp_dContactDate ;
			INTO CURSOR tmpEMailResult
	IF RECCOUNT()>0
		GO TOP
		lp_dContactDate =TTOD(tmpEMailResult.ei_datime)
		lp_cContactType = GetDocumentType("EINBOX")
	ENDIF
	USE
	SELECT * FROM esentrcp LEFT JOIN esent ON ec_esid = es_esid ;
			WHERE STR(ec_addrid,8)+STR(ec_apid,8) = STR(lp_nAddrId,8) AND TTOD(es_datime) > lp_dContactDate ;
			INTO CURSOR tmpEMailResult
	IF RECCOUNT()>0
		GO TOP
		lp_dContactDate = TTOD(tmpEMailResult.es_datime)
		lp_cContactType = GetDocumentType("ESENT")
	ENDIF
	USE
ENDIF
IF SEEK(lp_nAddrId,"laststay","tag1") AND lp_dContactDate < laststay.ls_depdate
	lp_dContactDate = laststay.ls_depdate
	lp_cContactType = GetLangText("RESERVAT","T_STAY")
ENDIF
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE RecalculateMonths
LOCAL ni, l_nCurrentDate, l_oData, l_nSelect
l_nSelect = SELECT()
l_nCurrentDate = sysdate()
SELECT adrstint
FOR ni = 1 TO 12
	LOCATE FOR ai_month = ni
	IF NOT FOUND()
		SCATTER NAME l_oData MEMO BLANK
		l_oData.ai_aiid = nextid("adrstint")
		l_oData.ai_month = ni
		l_oData.ai_fromdat = DATE(YEAR(l_nCurrentDate), ni, 1)
		l_oData.ai_todat = DATE(YEAR(l_nCurrentDate), ni, lastday(DATE(YEAR(l_nCurrentDate), ni, 27)))
		l_oData.ai_descrip = GetLangText("FUNC","TXT_"+UPPER(CMONTH(l_oData.ai_fromdat)))
		APPEND BLANK
		GATHER NAME l_oData MEMO
	ENDIF
ENDFOR
SCAN ALL FOR NOT EMPTY(ai_todat)
	IF ai_todat < l_nCurrentDate
		SCATTER NAME l_oData MEMO
		l_nYears = MAX(YEAR(l_nCurrentDate) - YEAR(ai_todat),1)
		l_oData.ai_fromdat = ChangeYear(ai_fromdat,l_nYears)
		l_oData.ai_todat = ChangeYear(ai_todat,l_nYears)
		GATHER NAME l_oData MEMO
	ENDIF
ENDSCAN
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
FUNCTION ChangeYear
LPARAMETERS lp_dDate, lp_nYears
LOCAL l_dResult, l_nDay
l_nDay = DAY(lp_dDate)
IF MONTH(lp_dDate) = 2 AND INLIST(l_nDay, 28, 29)
	l_nDay = lastday(DATE(YEAR(lp_dDate)+lp_nYears, 2, 27))
ENDIF
l_dResult = DATE(YEAR(lp_dDate)+lp_nYears, MONTH(lp_dDate), l_nDay)
RETURN l_dResult
ENDFUNC
*
PROCEDURE GetDocumentType
LPARAMETERS lp_cDocumentType, lp_cResult
LOCAL l_cText
DO CASE
	CASE INLIST(lp_cDocumentType, " ", "WORDDOC ", "WORDDOCX")
		l_cText = GetLangText("DOC","TXT_WORD_DOCUMENT")
	CASE lp_cDocumentType = "TELENOTE"
		l_cText = GetLangText("DOC","TXT_PHONE_NOTE")
	CASE lp_cDocumentType = "EINBOX"
		l_cText = GetLangText("DOC","TXT_MAIL_INBOX")
	CASE lp_cDocumentType = "ESENT"
		l_cText = GetLangText("DOC","TXT_MAIL_SENT")
	CASE lp_cDocumentType = "ARRECIVABL"
		l_cText = GetLangText("DOC","TXT_RECIVABLES_DOC_TYPE")
	CASE lp_cDocumentType = "WRITERDOC"
		l_cText = GetLangText("DOC","TXT_WRITER_DOCUMENT")
	CASE lp_cDocumentType = "CALCDOC"
		l_cText = GetLangText("DOC","TXT_CALC_DOCUMENT")
	CASE lp_cDocumentType = "PDFDOC"
		l_cText = GetLangText("DOC","TXT_PDF_DOCUMENT")
	CASE lp_cDocumentType = "EXTERNAL"
		l_cText = GetLangText("DOC","TXT_EXTERN_DOCUMENT")

	OTHERWISE
		l_cText = ""
ENDCASE
lp_cResult = l_cText
RETURN l_cText
*
PROCEDURE PANewExternalDocument
LPARAMETERS lp_nAddrId, lp_oConsent
LOCAL l_cFile, l_lSuccess, l_cPath, l_cExtension, l_cNewFileName, l_cNewFile, l_cOldFileName, l_cDescription, l_cForbbiden, l_lConsent

IF TYPE("lp_oConsent.cAlias") = "C" AND NOT EMPTY(lp_oConsent.cAlias)
	l_cFile = lp_oConsent.cAlias
ELSE
	l_cFile = GETFILE("","","",2,"")
ENDIF
IF EMPTY(l_cFile) OR EMPTY(lp_nAddrId)
	RETURN l_lSuccess
ENDIF

IF FILE(l_cFile)
	l_cPath = JUSTPATH(l_cFile)
	l_cExtension = JUSTEXT(l_cFile)
	l_cForbbiden = PAGetDangerouseFilesList()
	IF ["]+UPPER(ALLTRIM(l_cExtension))+["] $ l_cForbbiden
		alert(GetLangText("KEYCARD1","TXT_BLOCKED")+"!")
		RETURN l_lSuccess
	ENDIF
	l_cOldFileName = JUSTFNAME(l_cFile)
	IF PCOUNT() = 2
		l_lConsent = .T.
		l_cNewFileName = FORCEEXT("Consent_" + CFGetGuid(),l_cExtension)
		lp_oConsent = MakeStructure("cFileName, cAlias", lp_oConsent)
		lp_oConsent.cAlias = JUSTFNAME(l_cFile)
		lp_oConsent.cFileName = l_cNewFileName
	ELSE
		l_cNewFileName = JUSTSTEM(l_cFile)
		l_cNewFileName = STRTRAN(l_cNewFileName," ","_")
		l_cNewFileName = LEFT(l_cNewFileName,37)
		l_cNewFileName = ALLTRIM(l_cNewFileName)
		l_cNewFileName = FORCEEXT(l_cNewFileName + "_" + PADL(LTRIM(STR(NextId('Document'))),8,'0'),l_cExtension)
	ENDIF
	l_cNewFile = FULLPATH(gcDocumentdir + l_cNewFileName)
	COPY FILE (l_cFile) TO (l_cNewFile)
	IF FILE(l_cNewFile)
		IF NOT l_lConsent
			l_cDescription = INPUTBOX(GetLangText("DOC","T_DESCR"),l_cOldFileName,l_cOldFileName)
			IF EMPTY(l_cDescription)
				l_cDescription = l_cOldFileName
			ENDIF
			DO SaveInDocuments IN mylists WITH l_cNewFile, l_cDescription, lp_nAddrId,,,.T.
		ENDIF
		l_lSuccess = .T.
	ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE PAGetDangerouseFilesList
LOCAL l_cList
TEXT TO l_cList NOSHOW PRETEXT 15
"EXE","COM","MSI","BAT","DBF","CDX","FPT","PIF","APPLICATION","GADGET","MSP","SCR","HTA","CPL","MSC","JAR","CMD","VB","VBS","VBE",
"JS","JSE","WS","WSF","WSC","WSH","PS1","PS1XML","PS2","PS2XML","PSC1","PSC2","MSH","MSH1","MSH2","MSHXML","MSH1XML","MSH2XML",
"SCF","LNK","INF","REG","FXP","VCX","VCT","SCX","SCT","APP","DLL","FLL","OCX","TLB","PRG","H","BAK","FRX","FRT"
ENDTEXT
RETURN l_cList
ENDPROC
*
PROCEDURE GetEvents
LOCAL l_dIntFrom, l_dIntTo, l_cCurEvent, l_cAlias, l_cOrder
l_cAlias = ALIAS()
l_dIntFrom = DATE(YEAR(sysdate()),1,1)
l_dIntTo = DATE(YEAR(sysdate()),12,31) - 1
l_cCurEvent = SYS(2015)
SELECT * FROM adrstint ;
		LEFT JOIN events ON ev_evid = adrstint.ai_evid ;
		LEFT JOIN evint ON ei_evid = events.ev_evid AND ei_from <= l_dIntTo AND ei_to >= l_dIntFrom ;
		WHERE adrstint.ai_evid > 0 ;
		INTO CURSOR (l_cCurEvent)
l_cOrder = ORDER("adrstint")
SET ORDER TO tag2 IN adrstint
SET RELATION TO ai_evid INTO adrstint IN (l_cCurEvent)
SELECT (l_cCurEvent)
SCAN
	IF ISNULL(ev_evid)
		DELETE IN adrstint
	ELSE		
		REPLACE ai_descrip WITH &l_cCurEvent..ev_name IN adrstint
		IF ISNULL(ei_from) OR ISNULL(ei_to)
			REPLACE ai_fromdat WITH {}, ;
					ai_todat WITH {} IN adrstint
		ELSE
			REPLACE ai_fromdat WITH &l_cCurEvent..ei_from, ;
					ai_todat WITH &l_cCurEvent..ei_to IN adrstint
		ENDIF
	ENDIF
ENDSCAN
USE IN (l_cCurEvent)
SET ORDER TO (l_cOrder) IN adrstint
SELECT (l_cAlias)
ENDPROC
*
PROCEDURE GetAllReferralList
	LPARAMETERS lp_nAddressID, lp_lMarkAllAddresses
	LOCAL l_cAddressText, l_cCityText, l_lMarker, l_nFirstAddress, l_nAddressRecno
* this function is called with address.ad_addrid as parameter, and there is no need for LOCATE() or SEEK()
	l_nAddressRecno = RECNO("address")
	DO CASE
		CASE lp_lMarkAllAddresses
			l_nFirstAddress = lp_nAddressID
			l_lMarker = .T.
		CASE FindFirstAddrid(lp_nAddressID, @l_nFirstAddress)
			=SEEK(l_nFirstAddress,'address','Tag1')
			l_lMarker = .F.
		OTHERWISE
			l_nFirstAddress = lp_nAddressID
			l_lMarker = .T.
	ENDCASE
	l_cAddressText = IIF(NOT EMPTY(address.ad_company), ;
			UPPER(ALLTRIM(address.ad_company)),UPPER(ALLTRIM(address.ad_lname)))
	l_cCityText = UPPER(ALLTRIM(address.ad_city))
	INSERT INTO curLinkedAddress (re_addrid, re_from, re_to, re_addtext, re_mark, re_city) ;
			VALUES (l_nFirstAddress, l_nFirstAddress, l_nFirstAddress, l_cAddressText, l_lMarker, l_cCityText)
	=GetLinkedAddress(lp_nAddressID)
	SELECT curLinkedAddress
	IF lp_lMarkAllAddresses
		REPLACE re_mark WITH .T. FOR NOT re_mark IN curLinkedAddress
	ENDIF
	GO l_nAddressRecno IN address
	GO TOP IN curLinkedAddress
ENDPROC
*
PROCEDURE GetLinkedAddress
	LPARAMETERS lp_nAddressID
	LOCAL l_nForCurrentAddress, l_nCurRecNo, l_cAddressText, l_cCityText, l_lMarker, l_nAdrRecNo
	STORE '' TO l_cAddressText, l_cCityText
	l_nAdrRecNo = RECNO("address")
	
	SELECT curLinkedAddress
	SCAN
		l_nCurRecNo = RECNO()
		l_nForCurrentAddress = re_addrid
		l_lMarker = (l_nForCurrentAddress = lp_nAddressID)
		SELECT referral
		SET ORDER TO TAG3
		IF SEEK(l_nForCurrentAddress)
			SCAN REST WHILE re_to = l_nForCurrentAddress
				IF NOT SEEK(re_from, 'curLinkedAddress','Tag1') AND SEEK(re_from, "address", "tag1")
					l_cAddressText = IIF(SEEK(referral.re_from,'address3','tag1') AND NOT EMPTY(address3.ad_company), ;
						UPPER(ALLTRIM(address3.ad_company)),UPPER(ALLTRIM(address3.ad_lname)))
					l_cCityText = IIF(SEEK(referral.re_from,'address3','tag1'),UPPER(ALLTRIM(address3.ad_city)),'')
					INSERT INTO curLinkedAddress (re_from, re_to, re_addrid, re_addtext, re_city) VALUES ;
						(referral.re_from, referral.re_to, referral.re_from, l_cAddressText, l_cCityText)
					REPLACE re_mark WITH l_lMarker OR (re_addrid = lp_nAddressID) IN curLinkedAddress
				ELSE
					REPLACE re_mark WITH re_mark OR l_lMarker IN curLinkedAddress
				ENDIF
			ENDSCAN
		ENDIF
		
		SET ORDER TO TAG2
		IF SEEK(l_nForCurrentAddress)
			SCAN REST WHILE re_from = l_nForCurrentAddress
				IF NOT SEEK(re_to, 'curLinkedAddress','Tag1') AND SEEK(re_to, "address", "tag1")
					l_cAddressText = IIF(SEEK(referral.re_to,'address3','tag1') AND NOT EMPTY(address3.ad_company), ;
						UPPER(ALLTRIM(address3.ad_company)),UPPER(ALLTRIM(address3.ad_lname)))
					l_cCityText = IIF(SEEK(referral.re_to,'address3','tag1'),UPPER(ALLTRIM(address3.ad_city)),'')
					INSERT INTO curLinkedAddress (re_from, re_to, re_addrid, re_addtext, re_city) VALUES ;
						(referral.re_from, referral.re_to, referral.re_to, l_cAddressText, l_cCityText)
					REPLACE re_mark WITH l_lMarker OR (re_addrid = lp_nAddressID) IN curLinkedAddress
				ELSE
					REPLACE re_mark WITH re_mark OR l_lMarker IN curLinkedAddress
				ENDIF
			ENDSCAN
		ENDIF
		SELECT curLinkedAddress
		GO l_nCurRecNo IN curLinkedAddress
	ENDSCAN
	GO l_nAdrRecNo IN address
	RETURN .T.
ENDPROC
*
PROCEDURE FindFirstAddrid
	LPARAMETERS lp_nAddressID, lp_nFirstAddress
	LOCAL l_nCurRecNo, l_nForAddress, l_lReturnVal, l_nAdrRecNo
	l_nAdrRecNo = RECNO("address")
	CREATE CURSOR curTempAddridList (cur_addrid n(8))
	INDEX ON cur_addrid TAG Tag1
	SET ORDER TO
	INSERT INTO curTempAddridList (cur_addrid) VALUES (lp_nAddressID)

	SELECT curTempAddridList
	SCAN
		l_nCurRecNo = RECNO()
		SELECT referral
		SET ORDER TO TAG3
		l_nForAddress = curTempAddridList.cur_addrid
		IF SEEK(l_nForAddress)
			SCAN REST WHILE re_to = l_nForAddress
				IF NOT SEEK(re_from, 'curTempAddridList','Tag1') AND ;
							SEEK(referral.re_from,"address","tag1")
					INSERT INTO curTempAddridList (cur_addrid) VALUES (referral.re_from)
				ENDIF
			ENDSCAN
		ELSE
			lp_nFirstAddress = l_nForAddress
			l_lReturnVal = .T.
			EXIT
		ENDIF
		SELECT curTempAddridList
		GO l_nCurRecNo IN curTempAddridList
	ENDSCAN
	USE IN curTempAddridList
	GO l_nAdrRecNo IN address
	RETURN l_lReturnVal
ENDPROC
*
PROCEDURE PAIsCompany
LPARAMETERS lp_nAddrid
LOCAL l_lIsCompany, l_cAdrResCur, l_nSelect
IF EMPTY(lp_nAddrid)
	RETURN l_lIsCompany
ENDIF

l_nSelect = SELECT()

l_cAdrResCur = sqlcursor("SELECT ad_company FROM address WHERE ad_addrid = " + sqlcnv(lp_nAddrid))
IF RECCOUNT(l_cAdrResCur)>0
	IF NOT EMPTY(&l_cAdrResCur..ad_company)
		l_lIsCompany = .T.
	ENDIF
ENDIF
dclose(l_cAdrResCur)

SELECT(l_nSelect)
RETURN l_lIsCompany
ENDPROC
*

***************************************************
* Bussines logic for resaddr - Address intervalls *
***************************************************

*
PROCEDURE PAResAddrGetData
LPARAMETERS lp_cResAlias
LOCAL l_cSql, l_cCur, l_nReserId, l_cForClause, l_lFilterSplited, l_nRecnoRes

IF NOT EMPTY(lp_cResAlias)
	IF &lp_cResAlias..rs_roomlst
		l_cForClause = "rg_reserid = " + sqlcnv(&lp_cResAlias..rs_reserid)
	ELSE
		l_cForClause = "rg_reserid>=" + ALLTRIM(STR(INT(&lp_cResAlias..rs_reserid))) + ;
				" AND rg_reserid<" + ALLTRIM(STR(INT(&lp_cResAlias..rs_reserid)+1))
		l_lFilterSplited = .T.
	ENDIF
ELSE
	l_cForClause = "rg_reserid = " + sqlcnv(0)
ENDIF
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15

	SELECT * ;
		 FROM resaddr WITH (BUFFERING = .T.) ;
		WHERE <<l_cForClause>> ;
		ORDER BY rg_fromday READWRITE

ENDTEXT
l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)

IF l_lFilterSplited
	l_nRecnoRes = RECNO(lp_cResAlias)
	SELECT (l_cCur)
	SCAN FOR dlocate(lp_cResAlias,"rs_reserid = " + sqlcnv(&l_cCur..rg_reserid)) AND &lp_cResAlias..rs_roomlst
		DELETE IN &l_cCur
	ENDSCAN
	GO l_nRecnoRes IN &lp_cResAlias
ENDIF

RETURN l_cCur
ENDPROC
*
PROCEDURE PAResAddrGetResDates
LPARAMETERS lp_cResAlias, lp_oCheckReservat
LOCAL l_nReserID, l_cForClause, l_cTmpCur
l_cTmpCur = SYS(2015)
l_nReserID = &lp_cResAlias..rs_reserid
l_cForClause = lp_oCheckReservat.resset_forclause_get(.T., "l_nReserID", lp_cResAlias)

SELECT MIN(rs_arrdate) AS setarrdate, MAX(rs_depdate) AS setdepdate ;
	FROM &lp_cResAlias WITH (BUFFERING = .T.) ;
	WHERE &l_cForClause ;
	INTO CURSOR &l_cTmpCur READWRITE

* We must check if this is 0 day reservation
IF &l_cTmpCur..setarrdate = &l_cTmpCur..setdepdate
	REPLACE setdepdate WITH setdepdate + 1 IN &l_cTmpCur
ENDIF

RETURN l_cTmpCur
ENDPROC
*
PROCEDURE PAResAddrNew
LPARAMETERS lp_oResAddrData
lp_oResAddrData.rg_rgid = nextid("RESADDR")
sqlinsert("resaddr", ;
	"rg_rgid, rg_reserid, rg_lname, " + ;
	"rg_fname, rg_title, rg_fromday, " + ;
	"rg_today, rg_country" ,;
	1, ;
	sqlcnv(lp_oResAddrData.rg_rgid,.T.)+","+sqlcnv(lp_oResAddrData.rg_reserid,.T.)+","+sqlcnv(lp_oResAddrData.rg_lname,.T.)+","+ ;
	sqlcnv(lp_oResAddrData.rg_fname,.T.)+","+sqlcnv(lp_oResAddrData.rg_title,.T.)+","+sqlcnv(lp_oResAddrData.rg_fromday,.T.)+","+ ;
	sqlcnv(lp_oResAddrData.rg_today,.T.)+","+sqlcnv(lp_oResAddrData.rg_country,.T.);
	)
RETURN .T.
ENDPROC
*
PROCEDURE PAResAddrUpdate
LPARAMETERS lp_oResAddrData, lp_nReserId
sqlupdate("resaddr", ;
	"rg_rgid = " + sqlcnv(lp_oResAddrData.rg_rgid,.T.), ;
	"rg_reserid = " + sqlcnv(lp_nReserId,.T.) + "," + ;
	"rg_lname = " + sqlcnv(lp_oResAddrData.rg_lname,.T.) + "," + ;
	"rg_fname= " + sqlcnv(lp_oResAddrData.rg_fname,.T.) + "," + ;
	"rg_title = " + sqlcnv(lp_oResAddrData.rg_title,.T.) + "," + ;
	"rg_fromday = " + sqlcnv(lp_oResAddrData.rg_fromday,.T.) + "," + ;
	"rg_today = " + sqlcnv(lp_oResAddrData.rg_today,.T.) + "," + ;
	"rg_country = " + sqlcnv(lp_oResAddrData.rg_country,.T.) ;
	)
RETURN .T.
ENDPROC
*
PROCEDURE PAResAddrDelete
LPARAMETERS lp_nrgid
sqldelete("resaddr", ;
	"rg_rgid = " + sqlcnv(lp_nrgid,.T.) ;
	)
RETURN .T.
ENDPROC
*
PROCEDURE PAResAddrAdjust
LPARAMETERS lp_oResAddrData, lp_nReserId, lp_cResAlias
LOCAL l_cCur, l_nSelect, l_oData, l_cResAddrCur
l_nSelect = SELECT()

l_cCur = SYS(2015)
l_nLeftNew = lp_oResAddrData.rg_fromday
l_nRightNew = lp_oResAddrData.rg_today

l_cResAddrCur = PAResAddrGetData(lp_cResAlias)

SELECT *, rg_fromday AS left_i, rg_today AS right_i, .F. AS delete_i FROM (l_cResAddrCur) ;
	WHERE rg_rgid <> lp_oResAddrData.rg_rgid AND rg_today > l_nLeftNew AND rg_fromday < l_nRightNew ;
	ORDER BY rg_fromday ;
	INTO CURSOR (l_cCur) READWRITE

SCAN ALL
	DO CASE
		CASE BETWEEN(left_i, l_nLeftNew, l_nRightNew) AND BETWEEN(right_i, l_nLeftNew, l_nRightNew)
			* Found interval is enteirely overlaped with new interval. So delete it.
			REPLACE delete_i WITH .T.
		CASE right_i > l_nLeftNew AND left_i < l_nLeftNew
			* adjust only right side of found interval.
			REPLACE right_i WITH l_nLeftNew
		OTHERWISE && left_i < l_nRightNew
			* adjust only left side of found interval
			REPLACE left_i WITH l_nRightNew
		ENDCASE
ENDSCAN

SCAN ALL
	IF delete_i
		PAResAddrDelete(rg_rgid)
	ELSE
		SCATTER NAME l_oData
		l_oData.rg_fromday = left_i
		l_oData.rg_today = right_i
		PAResAddrUpdate(l_oData, lp_nReserId)
	ENDIF
ENDSCAN

dclose(l_cResAddrCur)
dclose(l_cCur)
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PAResAddrAdjustAllIntervals
LPARAMETERS lp_cResAlias, lp_dSetArrDate, lp_dSetDepDate, lp_oCheckReservat
LOCAL l_nSelect, l_cResAddrCur, l_nIntervals, i, l_nPreviousToDay, l_nLastDay, l_oData, l_nFirstDay, l_cCurResSet
IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF
IF VARTYPE(lp_oCheckReservat)="O"
	l_cCurResSet = ""
	l_cCurResSet = PAResAddrGetResDates(lp_cResAlias, lp_oCheckReservat)
	IF RECCOUNT(l_cCurResSet)>0
		lp_dSetArrDate = &l_cCurResSet..setarrdate
		lp_dSetDepDate = &l_cCurResSet..setdepdate
	ENDIF
	dclose(l_cCurResSet)
ENDIF
IF EMPTY(lp_dSetArrDate) OR EMPTY(lp_dSetDepDate)
	RETURN .F.
ENDIF
l_nSelect = SELECT()
l_cResAddrCur = PAResAddrGetData(lp_cResAlias)
SELECT (l_cResAddrCur)
l_nPreviousToDay = 0
l_nFirstDay = 1
l_nLastDay = lp_dSetDepDate - lp_dSetArrDate + 1
l_nIntervals = 0

* Delete intervals which are outside reservation duration. But don't delete if only 1 interval exists.
COUNT TO l_nIntervals
SCAN FOR rg_fromday > l_nLastDay AND l_nIntervals > 1
	PAResAddrDelete(&l_cResAddrCur..rg_rgid)
ENDSCAN
dclose(l_cResAddrCur)

* Now process intervals
l_cResAddrCur = PAResAddrGetData(lp_cResAlias)
COUNT TO l_nIntervals
i = 0
SCAN ALL
	SCATTER NAME l_oData
	i = i + 1
	DO CASE
		CASE i = 1
			* First interval
			IF &l_cResAddrCur..rg_fromday <> l_nFirstDay
				l_oData.rg_fromday = l_nFirstDay
				PAResAddrUpdate(l_oData, &lp_cResAlias..rs_reserid)
			ENDIF
			IF l_nIntervals = 1
				* Only one interval, check today.
				IF &l_cResAddrCur..rg_today <> l_nLastDay
					l_oData.rg_today = l_nLastDay
					PAResAddrUpdate(l_oData, &lp_cResAlias..rs_reserid)
				ENDIF
			ENDIF
			l_nPreviousToDay = &l_cResAddrCur..rg_today
		CASE i = l_nIntervals
			* Last interval
			* Check if to day from previous interval is same as from day for next interval.
			IF &l_cResAddrCur..rg_fromday <> l_nPreviousToDay
				l_oData.rg_fromday = l_nPreviousToDay
				PAResAddrUpdate(l_oData, &lp_cResAlias..rs_reserid)
			ENDIF
			IF &l_cResAddrCur..rg_today <> l_nLastDay
				l_oData.rg_today = l_nLastDay
				PAResAddrUpdate(l_oData, &lp_cResAlias..rs_reserid)
			ENDIF
		OTHERWISE
			* Check if to day from previous interval is same as from day for next interval.
			IF &l_cResAddrCur..rg_fromday <> l_nPreviousToDay
				l_oData.rg_fromday = l_nPreviousToDay
				PAResAddrUpdate(l_oData, &lp_cResAlias..rs_reserid)
			ENDIF
			l_nPreviousToDay = &l_cResAddrCur..rg_today
	ENDCASE
*!*		IF l_oData.rg_fromday = l_oData.rg_today OR l_oData.rg_fromday < l_nLastDay
*!*			* Delete interval with 0 days. This can happen, when reservation duration has been changed.
*!*			PAResAddrDelete(l_oData.rg_rgid)
*!*		ENDIF

ENDSCAN
dclose(l_cResAddrCur)

* Delete interval with 0 days. This can happen, when reservation duration has been changed.
l_cResAddrCur = PAResAddrGetData(lp_cResAlias)
SCAN FOR rg_fromday = rg_today
	PAResAddrDelete(&l_cResAddrCur..rg_rgid)
ENDSCAN
dclose(l_cResAddrCur)

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PAResAddrValid
LPARAMETERS lp_nValid, l_oResAddrData, lp_dArrDate, lp_dDepDate
lp_nValid = 0
* Here add code
IF EMPTY(lp_dArrDate) OR EMPTY(lp_dDepDate)
	RETURN lp_nValid
ENDIF
IF NOT BETWEEN(PAResAddrGetFromDate(lp_dArrDate, l_oResAddrData.rg_fromday), lp_dArrDate, lp_dDepDate)
	lp_nValid = 1
ENDIF
IF EMPTY(lp_nValid) AND NOT BETWEEN(PAResAddrGetToDate(lp_dArrDate, l_oResAddrData.rg_today), lp_dArrDate, lp_dDepDate)
	lp_nValid = 2
ENDIF
IF EMPTY(lp_nValid) AND PAResAddrGetFromDate(lp_dArrDate, l_oResAddrData.rg_fromday) = ;
		PAResAddrGetToDate(lp_dArrDate, l_oResAddrData.rg_today)
	lp_nValid = 3
ENDIF
RETURN lp_nValid
ENDPROC
*
PROCEDURE PAResAddrGetFromDate
LPARAMETERS lp_dArrDate, lp_nDayFrom
RETURN lp_dArrDate + lp_nDayFrom - RESADDR_DAY_CORRECTION
ENDPROC
*
PROCEDURE PAResAddrGetToDate
LPARAMETERS lp_dArrDate, lp_nDayTo
RETURN lp_dArrDate + lp_nDayTo - RESADDR_DAY_CORRECTION
ENDPROC
*
PROCEDURE PaResAddrGetUpdateWhere
LPARAMETERS lp_dOnDate, lp_dArrivalDate
LOCAL l_cWhere
l_cWhere = ;
		"BETWEEN("+sqlcnv(lp_dOnDate)+","+;
				"PAResAddrGetFromDate(" + sqlcnv(lp_dArrivalDate)+",rg_fromday),"+;
				"PAResAddrGetToDate("+sqlcnv(lp_dArrivalDate)+",rg_today)-"+sqlcnv(RESADDR_LAST_DAY_CORRECTION)+")"
RETURN l_cWhere
ENDPROC
*
PROCEDURE PAResAddrChangeGuest
LPARAMETERS lp_oCheckRes, lp_oReservat, lp_dOnDate, lp_cResAlias
LOCAL l_lChanged, l_nSelect, l_cResList, l_cResAddrCur, l_nRecno, l_cForClause, l_nReserID, l_cWhere, ;
		l_cTemp, l_oData, l_nOrder, l_dSetArrDate

IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF

IF NOT &lp_cResAlias..rs_noaddr
	RETURN l_lChanged
ENDIF

l_nSelect = SELECT()
l_cResList = SYS(2015)
l_cResAddrCur = SYS(2015)
l_cTemp = SYS(2015)

* Create cursor l_cResList and get all reservation ids, which have same address.
* We use here scans and not sql select becouse of buffering.

SELECT rs_reserid AS lst_reserid FROM &lp_cResAlias WHERE .F. INTO CURSOR &l_cResList READWRITE

SELECT &lp_cResAlias
l_nRecno = RECNO()
l_nReserID = &lp_cResAlias..rs_reserid
l_cForClause = lp_oCheckRes.resset_forclause_get(.F., "l_nReserID", lp_cResAlias)
l_nOrder = ORDER()
SET ORDER TO
SCAN FOR &l_cForClause
	IF EMPTY(l_dSetArrDate)
		l_dSetArrDate= rs_arrdate
	ENDIF
	l_dSetArrDate = MIN(l_dSetArrDate, rs_arrdate)
	INSERT INTO (l_cResList) (lst_reserid) VALUES (&lp_cResAlias..rs_reserid)
ENDSCAN
SET ORDER TO l_nOrder
GO l_nRecno

l_cWhere = PaResAddrGetUpdateWhere(lp_dOnDate, l_dSetArrDate)

SELECT resaddr
SELECT * FROM resaddr WHERE .F. INTO CURSOR &l_cResAddrCur READWRITE
INDEX ON rg_fromday TAG TAG1

SELECT &l_cResList
SCAN ALL
	SELECT * FROM resaddr WITH (BUFFERING = .T.) WHERE rg_reserid = &l_cResList..lst_reserid INTO CURSOR &l_cTemp
	SCAN FOR &l_cWhere
		SCATTER NAME l_oData MEMO
		INSERT INTO &l_cResAddrCur FROM NAME l_oData
	ENDSCAN
	SELECT &l_cResList
ENDSCAN

SELECT (l_cResAddrCur)
IF RECCOUNT()>0

	* When more valid intervals found, allways get first one, with min day.
	GO TOP

	IF &lp_cResAlias..rs_rgid <> &l_cResAddrCur..rg_rgid OR ;
			&lp_cResAlias..rs_lname <> &l_cResAddrCur..rg_lname OR ;
			&lp_cResAlias..rs_fname <> &l_cResAddrCur..rg_fname OR ;
			&lp_cResAlias..rs_title <> &l_cResAddrCur..rg_title OR ;
			&lp_cResAlias..rs_country <> &l_cResAddrCur..rg_country

		lp_oReservat.rs_rgid = &l_cResAddrCur..rg_rgid
		lp_oReservat.rs_lname = &l_cResAddrCur..rg_lname
		lp_oReservat.rs_fname = &l_cResAddrCur..rg_fname
		lp_oReservat.rs_title = &l_cResAddrCur..rg_title
		lp_oReservat.rs_country = &l_cResAddrCur..rg_country
		l_lChanged = .T.

	ENDIF
ENDIF

dclose(l_cResAddrCur)
dclose(l_cResList)
dclose(l_cTemp)

SELECT (l_nSelect)

RETURN l_lChanged
ENDPROC
*
PROCEDURE PAResAddrGetRestGuestNames
LPARAMETERS lp_oCheckRes, lp_cResAlias, lp_lComplete, lp_lJustGiveCursor, lp_lForce
LOCAL l_lChanged, l_nSelect, l_cResList, l_cResAddrCur, l_nRecno, l_cForClause, l_nReserID, l_cTemp, ;
		l_oData, l_cText, l_nOrder, l_dArrival, l_dMinArrival, l_dMaxArrival, l_cRetString
IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF

l_cText = ""
IF NOT &lp_cResAlias..rs_noaddr AND NOT lp_lForce
	RETURN l_cText
ENDIF

IF NOT lp_lJustGiveCursor AND TRIM(&lp_cResAlias..rs_lname) == RESADDR_GUEST_NOT_SELECTED
	* When * in rs_lname, then user has not yet entered guest name
	RETURN l_cText
ENDIF

l_nSelect = SELECT()
l_cResList = SYS(2015)
l_cResAddrCur = SYS(2015)
l_cTemp = SYS(2015)

* Create cursor l_cResList and get all reservation ids, which have same address.
* We use here scans and not sql select becouse of buffering.

SELECT rs_reserid AS lst_reserid, rs_arrdate AS lst_arrdate FROM &lp_cResAlias WHERE .F. INTO CURSOR &l_cResList READWRITE

SELECT &lp_cResAlias
l_nRecno = RECNO()
l_nOrder = ORDER()
l_nReserID = &lp_cResAlias..rs_reserid
l_dArrival = &lp_cResAlias..rs_arrdate
l_cForClause = lp_oCheckRes.resset_forclause_get(.F., "l_nReserID", lp_cResAlias)
SET ORDER TO
STORE {} to l_dMinArrival, l_dMaxArrival
SCAN FOR &l_cForClause
	INSERT INTO (l_cResList) (lst_reserid, lst_arrdate) VALUES (&lp_cResAlias..rs_reserid, &lp_cResAlias..rs_arrdate)
	l_dMinArrival = IIF(EMPTY(l_dMinArrival), &lp_cResAlias..rs_arrdate, MIN(l_dMinArrival, &lp_cResAlias..rs_arrdate))
	l_dMaxArrival = IIF(EMPTY(l_dMaxArrival), &lp_cResAlias..rs_depdate, MIN(l_dMaxArrival, &lp_cResAlias..rs_depdate))
ENDSCAN
SET ORDER TO l_nOrder
GO l_nRecno

SELECT resaddr
SELECT *, 000 AS changed_fromday, 000 AS changed_today, {} AS set_mindate, ;
		{} AS set_maxdate, {} AS cur_arrdate, {} AS cur_depdate ;
		FROM resaddr WHERE .F. INTO CURSOR &l_cResAddrCur READWRITE
INDEX ON rg_fromday TAG TAG1

SELECT &l_cResList
SCAN ALL
	SELECT * FROM resaddr WITH (BUFFERING = .T.) WHERE rg_reserid = &l_cResList..lst_reserid ORDER BY rg_fromday INTO CURSOR &l_cTemp
	SCAN ALL
		SCATTER NAME l_oData MEMO
		ADDPROPERTY(l_oData, "set_mindate", l_dMinArrival)
		ADDPROPERTY(l_oData, "set_maxdate", l_dMaxArrival)
		ADDPROPERTY(l_oData, "cur_arrdate", PAResAddrGetFromDate(l_oData.set_mindate, l_oData.rg_fromday))
		ADDPROPERTY(l_oData, "cur_depdate", PAResAddrGetToDate(l_oData.set_mindate, l_oData.rg_today))
		ADDPROPERTY(l_oData, "changed_fromday", MAX(1,l_oData.rg_fromday - (l_dArrival-l_dMinArrival)))
		ADDPROPERTY(l_oData, "changed_today", l_oData.rg_today - (l_dArrival-l_dMinArrival))
		INSERT INTO &l_cResAddrCur FROM NAME l_oData
	ENDSCAN
	SELECT &l_cResList
ENDSCAN

DO CASE
	CASE lp_lJustGiveCursor
		l_cRetString = l_cResAddrCur
	CASE lp_lComplete
		SELECT &l_cResAddrCur
		l_cText = l_cText + CHR(10) + getlangtext("ADDRESS","TXT_ADDRESS_INTERVALS") + ":" + CHR(10)
		SCAN ALL
			l_cText = l_cText + ;
			DTOC(PAResAddrGetFromDate(l_dMinArrival, rg_fromday)) + " - " + ;
			DTOC(PAResAddrGetToDate(l_dMinArrival, rg_today-1)) + " " + ;
			TRIM(rg_title) + " " + TRIM(rg_lname) + " " + TRIM(rg_fname) + CHR(10)
		ENDSCAN
		l_cRetString = LEFT(l_cText,LEN(l_cText)-1)
	OTHERWISE
		SELECT &l_cResAddrCur
		SCAN FOR changed_today > 0
			l_cText = l_cText + ALLTRIM(STR(changed_fromday))+"-"+ALLTRIM(STR(changed_today))+" "+ALLTRIM(rg_lname) + "\"
		ENDSCAN
		l_cRetString = LEFT(l_cText,LEN(l_cText)-1)
ENDCASE

dclose(l_cResList)
dclose(l_cTemp)

IF lp_lJustGiveCursor
	SELECT &l_cResAddrCur
ELSE
	dclose(l_cResAddrCur)
	SELECT (l_nSelect)
ENDIF

RETURN l_cRetString
ENDPROC
*
PROCEDURE PAAddrLastStay
LPARAMETERS tcMode, tnAddrId, tlHasLastStay, tdArrdate, tdDepdate, tcRoomtype, tcRoomname, tcRatecode, tnRate, tcMarketcode, tcSourcecode
LOCAL lcLastStayCur, lcSql, lcSqlSelect, lcRoomtypeCur, lcRoomnumCur

DO CASE
	CASE tcMode = "ADDRESS"
		lcSqlSelect = "SELECT ls_addrid, ls_arrdat, ls_depdate, ls_roomtyp, ls_roomnum, ls_ratecod, ls_rate, ls_market, ls_source " + ;
			"FROM _#LASTSTAY#_ WHERE ls_addrid = " + SqlCnv(tnAddrId,.T.)
		lcLastStayCur = QueryHotData(lcSqlSelect)
		IF USED(lcLastStayCur) AND NOT EMPTY(&lcLastStayCur..ls_addrid)
			tlHasLastStay = .T.
			tdArrdate = &lcLastStayCur..ls_arrdat
			tdDepdate = &lcLastStayCur..ls_depdate
			tcRoomtype = Get_rt_roomtyp(&lcLastStayCur..ls_roomtyp)
			tcRoomname = Get_rm_rmname(&lcLastStayCur..ls_roomnum)
			tcRatecode = &lcLastStayCur..ls_ratecod
			tnRate = &lcLastStayCur..ls_rate
			tcMarketcode = &lcLastStayCur..ls_market
			tcSourcecode = &lcLastStayCur..ls_source
		ENDIF
		DClose(lcLastStayCur)
	CASE tcMode = "ADRMAIN"
		lcSqlSelect = "SELECT ls_addrid, ls_arrdat, ls_depdate, ls_roomtyp, ls_roomnum, ls_ratecod, ls_rate, ls_market, ls_source " + ;
			"FROM _#LASTSTAY#_ INNER JOIN _#ADDRESS#_ ON ls_addrid = ad_addrid WHERE ad_adid = " + SqlCnv(tnAddrId,.T.)
		tdDepdate = {}
		SELECT hotel
		SCAN
			lcLastStayCur = QueryHotData(lcSqlSelect, ho_hotcode)
			IF USED(lcLastStayCur) AND NOT EMPTY(&lcLastStayCur..ls_addrid) AND tdDepdate < &lcLastStayCur..ls_depdate
				tlHasLastStay = .T.
				tdArrdate = &lcLastStayCur..ls_arrdat
				tdDepdate = &lcLastStayCur..ls_depdate
				lcSql = "SELECT rd_roomtyp, rt_buildng FROM _#ROOMTYPE#_ LEFT JOIN _#RTYPEDEF#_ ON rd_rdid = rt_rdid WHERE rt_roomtyp = " + SqlCnv(&lcLastStayCur..ls_roomtyp,.T.)
				lcRoomtypeCur = QueryHotData(lcSql, ho_hotcode)
				tcRoomtype = IIF(USED(lcRoomtypeCur) AND NOT EMPTY(&lcRoomtypeCur..rd_roomtyp), ;
					ALLTRIM(&lcRoomtypeCur..rd_roomtyp)+[ ]+&lcRoomtypeCur..rt_buildng, &lcLastStayCur..ls_roomtyp)
				DClose(lcRoomtypeCur)
				lcSql = "SELECT rm_rmname FROM _#ROOM#_ WHERE rm_roomnum = " + SqlCnv(&lcLastStayCur..ls_roomnum,.T.)
				lcRoomnumCur = QueryHotData(lcSql, ho_hotcode)
				tcRoomname = IIF(USED(lcRoomnumCur) AND NOT EMPTY(&lcRoomnumCur..rm_rmname), &lcRoomnumCur..rm_rmname, &lcLastStayCur..ls_roomnum)
				DClose(lcRoomnumCur)
				tcRatecode = &lcLastStayCur..ls_ratecod
				tnRate = &lcLastStayCur..ls_rate
				tcMarketcode = &lcLastStayCur..ls_market
				tcSourcecode = &lcLastStayCur..ls_source
			ENDIF
			DClose(lcLastStayCur)
		ENDSCAN
	OTHERWISE
ENDCASE

RETURN tlHasLastStay
ENDPROC
*
PROCEDURE PAAddReservationGuestReferalls
LPARAMETERS lp_nAddrId, lp_cName, lp_nCompId, lp_cCompany, lp_nInvId, lp_lShowMessages
LOCAL l_oProcAddress AS ProcAddress OF libs\proc_address.vcx, l_lHaveCompanyRef, l_lHaveInvoiceRef, i
LOCAL ARRAY l_aDialog(1,11)

l_lHaveCompanyRef = dlookup("referral", "re_from = " + sqlcnv(lp_nAddrId,.T.) + " AND re_to = " + sqlcnv(lp_nCompId,.T.) + " AND re_linkres = 'XC'","re_linkres") = "XC"
l_lHaveInvoiceRef = dlookup("referral", "re_from = " + sqlcnv(lp_nAddrId,.T.) + " AND re_to = " + sqlcnv(lp_nInvId,.T.) + " AND re_linkres = 'XI'","re_linkres") = "XI"

IF EMPTY(lp_nAddrId) OR (EMPTY(lp_nCompId) AND EMPTY(lp_nInvId))
	IF lp_lShowMessages
		alert(GetLangText("RESERVAT","TA_GUESTORCOMPANY"))
	ENDIF
	RETURN .F.
ENDIF

IF (l_lHaveCompanyRef OR EMPTY(lp_nCompId)) AND (l_lHaveInvoiceRef OR EMPTY(lp_nInvId))
	IF lp_lShowMessages
		alert(GetLangText("REFERRAL","TXT_REFERALS_ALREADY_DEFINED"))
	ENDIF
	RETURN .F.
ENDIF
i = 1
l_aDialog[i, 1] = "txtAddrId"
l_aDialog[i, 2] = GetLangText("REFERRAL","TXT_REF_THIS_CONTACT")
l_aDialog[i, 3] = "[" + ALLTRIM(lp_cName) + "]"
l_aDialog[i, 4] = ""
l_aDialog[i, 5] = 50
l_aDialog[i, 6] = ""
l_aDialog[i, 7] = ""
l_aDialog[i, 10] = .T.
IF NOT l_lHaveCompanyRef AND NOT EMPTY(lp_nCompId) AND lp_nAddrId <> lp_nCompId
	i = i + 1
	DIMENSION l_aDialog(i,11)
	l_aDialog[i, 1] = "txtCompId"
	l_aDialog[i, 2] = GetLangText("REFERRAL","TXT_LINK_COMPANY")
	l_aDialog[i, 3] = "[" + ALLTRIM(lp_cCompany) + "]"
	l_aDialog[i, 4] = ""
	l_aDialog[i, 5] = 50
	l_aDialog[i, 6] = ""
	l_aDialog[i, 7] = ""
	l_aDialog[i, 10] = .T.
ENDIF
IF NOT l_lHaveInvoiceRef AND NOT EMPTY(lp_nInvId) AND lp_nAddrId <> lp_nInvId
	i = i + 1
	DIMENSION l_aDialog(i,11)
	l_aDialog[i, 1] = "txtInvId"
	l_aDialog[i, 2] = GetLangText("REFERRAL","TXT_LINK_INVOICE")
	l_aDialog[i, 3] = "[" + ALLTRIM(dlookup("address","ad_addrid = " + sqlcnv(lp_nInvId,.T.),"ad_company")) + "]"
	l_aDialog[i, 4] = ""
	l_aDialog[i, 5] = 50
	l_aDialog[i, 6] = ""
	l_aDialog[i, 7] = ""
	l_aDialog[i, 10] = .T.
ENDIF

IF NOT Dialog(GETWORDNUM(GetLangText("ADDRESS","TT_BNEWREFERRAL"),1,"("),"",@l_aDialog,,250)
	RETURN .T.
ENDIF

l_oProcAddress = NEWOBJECT("ProcAddress","libs\proc_address.vcx")
l_oProcAddress.caddressalias = ""
l_oProcAddress.cReferralAlias = "referral"

IF NOT EMPTY(lp_nCompId)
	IF NOT l_lHaveCompanyRef
		l_oProcAddress.referralnew(lp_nAddrId, lp_nCompId)
		l_oProcAddress.oReferral.re_linkres = "XC"
		l_oProcAddress.referralsave()
	ENDIF
ENDIF

IF NOT EMPTY(lp_nInvId)
	IF NOT l_lHaveInvoiceRef
		l_oProcAddress.referralnew(lp_nAddrId, lp_nInvId)
		l_oProcAddress.oReferral.re_linkres = "XI"
		l_oProcAddress.referralsave()
	ENDIF
ENDIF

l_oProcAddress = .NULL.

RETURN .T.
ENDPROC
*
PROCEDURE PAAddressConsent
LPARAMETERS lp_nReserId, lp_nAddrId, lp_oAdrprvcy, lp_lDoConsent, lp_lDontAsk
LOCAL l_lOK

l_lOK = .T.

IF NOT _screen.GO
	RETURN l_lOK
ENDIF

OpenFileDirect(,"adrprvcy")
lp_oAdrprvcy = PAGetAddressConsent(lp_nReserId, lp_nAddrId)
DO CASE
	CASE EMPTY(lp_oAdrprvcy.ap_addrid)
	CASE lp_oAdrprvcy.ap_consent < 2
		l_lOK = .F.
		IF NOT lp_lDontAsk
			DO FORM "forms\addressconsent" WITH lp_oAdrprvcy, lp_lDoConsent TO l_lOK
		ENDIF
ENDCASE

RETURN l_lOK
ENDPROC
*
PROCEDURE PAGetAddressConsent
LPARAMETERS lp_nReserId, lp_nAddrId
LOCAL l_nArea, l_nAddrId, l_oAdrprvcy, l_lCompany

l_nArea = SELECT()

STORE 0 TO l_nAddrId

IF NOT EMPTY(lp_nReserId)
	l_nAddrId = EVL(lp_nAddrId,DLookUp("reservat", "rs_reserid = " + SqlCnv(lp_nReserId,.T.), "rs_addrid"))
	IF EMPTY(l_nAddrId) OR l_nAddrId = DLookUp("reservat", "rs_reserid = " + SqlCnv(lp_nReserId,.T.), "rs_compid")
		l_lCompany = .T.
	ENDIF
ELSE
	l_nAddrId = EVL(lp_nAddrId,0)
ENDIF
IF EMPTY(l_nAddrId)
	l_lCompany = .T.
	SELECT adrprvcy
	SCATTER MEMO BLANK NAME l_oAdrprvcy
ELSE
	IF NOT EMPTY(DLookUp("address", "ad_addrid = " + SqlCnv(l_nAddrId,.T.), "ad_company"))
		l_lCompany = .T.
	ENDIF
	DLocate("adrprvcy", "ap_addrid = " + SqlCnv(l_nAddrId,.T.))
	SELECT adrprvcy
	SCATTER MEMO NAME l_oAdrprvcy
	IF EMPTY(l_oAdrprvcy.ap_addrid)
		l_oAdrprvcy.ap_addrid = l_nAddrId
	ENDIF
ENDIF
IF l_lCompany
	l_oAdrprvcy.ap_consent = 2
ENDIF

SELECT(l_nArea)

RETURN l_oAdrprvcy
ENDPROC
*
PROCEDURE PAAddressDeleteAllowed
LPARAMETERS lp_nAddrId
LOCAL ARRAY l_aReser(1)

IF EMPTY(lp_nAddrId)
	RETURN .F.
ENDIF

l_aReser(1) = .T.
SqlCursor('SELECT rs_reserid FROM Reservat WHERE (rs_addrid = ' + SqlCnv(lp_nAddrId) + ' OR rs_saddrid = '+ SqlCnv(lp_nAddrId) + ') AND NOT INLIST(rs_status, "OUT", "NS", "CXL")',,,,,,@l_aReser)
IF NOT EMPTY(l_aReser(1))
	RETURN .F.
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PAAddressDeleteMarkOnAudit
LPARAMETERS lp_cResAlias
LOCAL l_oAdrprvcy

IF NOT _screen.GO
	RETURN .T.
ENDIF

IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF
IF INLIST(&lp_cResAlias..rs_status, "OUT", "NS ", "CXL")
	IF PAAddressDeleteMarkOn(&lp_cResAlias..rs_reserid, @l_oAdrprvcy)
		p_oAudit.txTinfo(GetLangText("ADDRESS","TXT_PRIVACY_PRSDATA_DELETED")+" "+TRANSFORM(l_oAdrprvcy.ap_addrid),1)
	ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PAAddressDeleteMarkOn
LPARAMETERS lp_nReserId, lp_oAdrprvcy
LOCAL l_lDeleted, l_nAddrid

IF NOT _screen.GO
	RETURN .T.
ENDIF
IF TYPE("lp_oAdrprvcy.ap_addrid") = "N"
	l_nAddrid = lp_oAdrprvcy.ap_addrid
ELSE
	l_nAddrid = 0
ENDIF
lp_oAdrprvcy = PAGetAddressConsent(lp_nReserId, l_nAddrid)

IF lp_oAdrprvcy.ap_consent < 2 AND PAAddressDeleteAllowed(lp_oAdrprvcy.ap_addrid)
	l_lDeleted = PAAddressDeleteMark(lp_oAdrprvcy, .T.)
ENDIF

RETURN l_lDeleted
ENDPROC
*
PROCEDURE PAAddressDeleteMarkOff
LPARAMETERS lp_nReserId, lp_oAdrprvcy
LOCAL l_lRestored, l_nAddrid

IF NOT _screen.GO
	RETURN .T.
ENDIF

IF TYPE("lp_oAdrprvcy.ap_addrid") = "N"
	l_nAddrid = lp_oAdrprvcy.ap_addrid
ELSE
	l_nAddrid = 0
ENDIF
lp_oAdrprvcy = PAGetAddressConsent(lp_nReserId, l_nAddrid)
l_lRestored = PAAddressDeleteMark(lp_oAdrprvcy, .F.)

RETURN l_lRestored
ENDPROC
*
PROCEDURE PAAddressDeleteMark
LPARAMETERS lp_oAdrprvcy, lp_lDeleteMark
LOCAL l_nRecNo, l_lUpdate

IF EMPTY(lp_oAdrprvcy.ap_addrid)
	RETURN .F.
ENDIF

l_nRecNo = RECNO("adrprvcy")
DO CASE
	CASE Dlocate("adrprvcy", "ap_addrid = " + SqlCnv(lp_oAdrprvcy.ap_addrid,.T.))
		IF lp_lDeleteMark = EMPTY(adrprvcy.ap_delgdpr)
			l_lUpdate = .T.
			lp_oAdrprvcy.ap_delgdpr = IIF(lp_lDeleteMark,DATETIME(),{})
			lp_oAdrprvcy.ap_deluser = ICASE(NOT lp_lDeleteMark, "", g_auditactive, "AUTOMATIC", g_userid)
			REPLACE ap_delgdpr WITH lp_oAdrprvcy.ap_delgdpr, ap_deluser WITH lp_oAdrprvcy.ap_deluser IN adrprvcy
		ENDIF
	CASE lp_lDeleteMark
		l_lUpdate = .T.
		lp_oAdrprvcy.ap_apid = NextId("ADRPRVCY")
		lp_oAdrprvcy.ap_delgdpr = DATETIME()
		lp_oAdrprvcy.ap_deluser = IIF(g_auditactive, "AUTOMATIC", g_userid)
		INSERT INTO adrprvcy (ap_apid, ap_addrid, ap_delgdpr, ap_deluser) VALUES (lp_oAdrprvcy.ap_apid, lp_oAdrprvcy.ap_addrid, lp_oAdrprvcy.ap_delgdpr, lp_oAdrprvcy.ap_deluser)
	OTHERWISE
ENDCASE
GO l_nRecNo IN adrprvcy

IF lp_lDeleteMark AND l_lUpdate
	l_nRecNo = RECNO("address")
	IF address.ad_addrid = lp_oAdrprvcy.ap_addrid OR DLocate("address", "ad_addrid = " + SqlCnv(lp_oAdrprvcy.ap_addrid,.T.), .T.)
		DELETE FOR fa_addrid = lp_oAdrprvcy.ap_addrid IN adrfeat
		BLANK FIELDS LIKE ad_birth, ad_email, ad_fax, ad_feat*, ad_lasroom, ad_mail*, ad_note, ad_phone*, ad_usr*, ad_website IN address
		IF CURSORGETPROP("Buffering","address") = 1
			FLUSH
		ELSE
			TABLEUPDATE(.F.,.T.,"address")
		ENDIF
	ENDIF
	GO l_nRecNo IN address
	l_nRecNo = RECNO("apartner")
	IF DLocate("apartner", "ap_addrid = " + SqlCnv(lp_oAdrprvcy.ap_addrid,.T.), .T.)
		BLANK FIELDS LIKE ap_email, ap_fax, ap_gebdate, ap_note, ap_phone*, ap_user* FOR ap_addrid = lp_oAdrprvcy.ap_addrid IN apartner
		IF CURSORGETPROP("Buffering","apartner") = 1
			FLUSH
		ELSE
			TABLEUPDATE(.F.,.T.,"apartner")
		ENDIF
	ENDIF
	GO l_nRecNo IN apartner
ENDIF

RETURN l_lUpdate
ENDPROC
*
PROCEDURE PAImportPhones
LOCAL l_nId, l_nSelect
l_nSelect = SELECT()
dclose("adrphone")
IF openfile(.T.,"adrphone")
	SELECT adrphone
	ZAP
	USE
	openfile(.F.,"adrphone")
ELSE
	SELECT (l_nSelect)
	RETURN .F.
ENDIF
l_nId = 0
IF NOT USED("address")
	openfile(,"address")
ENDIF
IF NOT USED("apartner")
	openfile(,"apartner")
ENDIF
IF NOT USED("id")
	openfile(,"id")
ENDIF
DELETE FROM id WHERE id_code = "ADRPHONE"
SELECT apartner
SET ORDER TO
SELECT address
SET ORDER TO
SCAN ALL
	WAIT WINDOW "Update adrphone.dbf for ad_addrid = " + TRANSFORM(ad_addrid) NOWAIT
	IF NOT EMPTY(ad_phone)
		l_nId = l_nId + 1
		PAInsertAddress("ad_phone", l_nId)
	ENDIF
	IF NOT EMPTY(ad_phone2)
		l_nId = l_nId + 1
		PAInsertAddress("ad_phone2", l_nId)
	ENDIF
	IF NOT EMPTY(ad_phone3)
		l_nId = l_nId + 1
		PAInsertAddress("ad_phone3", l_nId)
	ENDIF
	IF NOT EMPTY(ad_fax)
		l_nId = l_nId + 1
		PAInsertAddress("ad_fax", l_nId)
	ENDIF
	SELECT apartner
	SCAN FOR ap_addrid = address.ad_addrid
		IF NOT EMPTY(ap_phone1)
			l_nId = l_nId + 1
			PAInsertApartner("ap_phone1", l_nId)
		ENDIF
		IF NOT EMPTY(ap_phone2)
			l_nId = l_nId + 1
			PAInsertApartner("ap_phone2", l_nId)
		ENDIF
		IF NOT EMPTY(ap_fax)
			l_nId = l_nId + 1
			PAInsertApartner("ap_fax", l_nId)
		ENDIF
	ENDSCAN
ENDSCAN
INSERT INTO id (id_code, id_last) VALUES ("ADRPHONE", l_nId)
WAIT CLEAR
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PAInsertAddress
LPARAMETERS lp_cField, lp_nId, lp_cAlias, lp_lCheck
LOCAL l_cPhone, l_nId, l_cAlias, l_lUpdate, l_nSelect
IF EMPTY(lp_nId)
	l_nId = nextid("ADRPHONE")
ELSE
	l_nId = lp_nId
ENDIF
IF EMPTY(lp_cAlias)
	l_cAlias = "address"
ELSE
	l_cAlias = lp_cAlias
ENDIF
l_nSelect = SELECT()
l_nAddrId = EVALUATE(l_cAlias+".ad_addrid")
l_cPhone = PAParsePhoneNumber(EVALUATE(l_cAlias+"."+lp_cField))
IF lp_lCheck
	l_cCur = sqlcursor("SELECT aj_addrid FROM adrphone WHERE aj_addrid = "+TRANSFORM(l_nAddrId)+" AND aj_field = '"+PADR(lp_cField,10)+"'")

	IF RECCOUNT(l_cCur)>0
		l_lUpdate = .T.
	ENDIF
	dclose(l_cCur)
ENDIF
IF NOT EMPTY(l_cPhone)
	IF l_lUpdate
		PAUpdateAddress(lp_cField,lp_cAlias)
	ELSE
		sqlinsert("adrphone", "aj_ajid, aj_phone, aj_field, aj_addrid, aj_apid", 1, TRANSFORM(l_nId) + ",'" + l_cPhone + "','" + lp_cField + "'," + TRANSFORM(l_nAddrId) + ",0")
	ENDIF
ENDIF
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PAUpdateAddress
LPARAMETERS lp_cField, lp_cAlias, lp_lCheck
LOCAL l_cAlias, l_cPhone, l_nAddrId, l_cCur, l_lUpdate, l_nSelect
IF EMPTY(lp_cAlias)
	l_cAlias = "address"
ELSE
	l_cAlias = lp_cAlias
ENDIF

l_nSelect = SELECT()

l_nAddrId = EVALUATE(l_cAlias+".ad_addrid")
l_cPhone = PAParsePhoneNumber(EVALUATE(l_cAlias+"."+lp_cField))
IF lp_lCheck
	l_cCur = sqlcursor("SELECT aj_addrid FROM adrphone WHERE aj_addrid = "+TRANSFORM(l_nAddrId)+" AND aj_field = '"+PADR(lp_cField,10)+"'")

	IF RECCOUNT(l_cCur)>0
		l_lUpdate = .T.
	ENDIF
	dclose(l_cCur)
ELSE
	l_lUpdate = .T.
ENDIF
IF l_lUpdate
	sqlupdate("adrphone","aj_addrid = " + TRANSFORM(l_nAddrId)+" AND aj_field = '"+PADR(lp_cField,10)+"'", "aj_phone = '" + l_cPhone + "'")
ELSE
	PAInsertAddress(lp_cField,,lp_cAlias)
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE PAInsertApartner
LPARAMETERS lp_cField, lp_nId, lp_cPhone, lp_nApId, lp_nAddrId
LOCAL l_cPhone, l_nId, l_nSelect
l_nSelect = SELECT()

IF EMPTY(lp_nId)
	l_nId = nextid("ADRPHONE")
ELSE
	l_nId = lp_nId
ENDIF

IF EMPTY(lp_cPhone)
	l_cPhone = PAParsePhoneNumber(EVALUATE("apartner."+lp_cField))
ELSE
	l_cPhone = lp_cPhone
ENDIF
IF EMPTY(lp_nApId)
	lp_nApId = apartner.ap_apid
ENDIF
IF EMPTY(lp_nAddrId)
	lp_nAddrId = address.ad_addrid
ENDIF
IF NOT EMPTY(l_cPhone)
	*INSERT INTO adrphone (aj_ajid, aj_phone, aj_field, aj_addrid, aj_apid) VALUES (l_nId, l_cPhone, lp_cField, address.ad_addrid, apartner.ap_apid)
	sqlinsert("adrphone", "aj_ajid, aj_phone, aj_field, aj_addrid, aj_apid", 1, TRANSFORM(l_nId) + ",'" + l_cPhone + "','" + lp_cField + "'," + TRANSFORM(lp_nAddrId) + ","+TRANSFORM(lp_nApId))
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE PAInsertPhones
PARAMETERS pp_oNewAddressDataForPhone
IF NOT EMPTY(PADR(pp_oNewAddressDataForPhone.ad_phone,20))
	PAInsertAddress("ad_phone",,"pp_oNewAddressDataForPhone",.T.)
ENDIF
IF NOT EMPTY(PADR(pp_oNewAddressDataForPhone.ad_phone2,20))
	PAInsertAddress("ad_phone2",,"pp_oNewAddressDataForPhone",.T.)
ENDIF
IF NOT EMPTY(PADR(pp_oNewAddressDataForPhone.ad_phone3,20))
	PAInsertAddress("ad_phone3",,"pp_oNewAddressDataForPhone",.T.)
ENDIF
IF NOT EMPTY(PADR(pp_oNewAddressDataForPhone.ad_fax,100))
	PAInsertAddress("ad_fax",,"pp_oNewAddressDataForPhone",.T.)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PAUpdatePhones
PARAMETERS pp_oNewAddressDataForPhone, pp_oOldAddressDataForPhone
IF PADR(pp_oNewAddressDataForPhone.ad_phone,20) <> pp_oOldAddressDataForPhone.ad_phone
	PAUpdateAddress("ad_phone","pp_oNewAddressDataForPhone",.T.)
ENDIF
IF PADR(pp_oNewAddressDataForPhone.ad_phone2,20) <> pp_oOldAddressDataForPhone.ad_phone2
	PAUpdateAddress("ad_phone2","pp_oNewAddressDataForPhone",.T.)
ENDIF
IF PADR(pp_oNewAddressDataForPhone.ad_phone3,20) <> pp_oOldAddressDataForPhone.ad_phone3
	PAUpdateAddress("ad_phone3","pp_oNewAddressDataForPhone",.T.)
ENDIF
IF PADR(pp_oNewAddressDataForPhone.ad_fax,100) <> pp_oOldAddressDataForPhone.ad_fax
	PAUpdateAddress("ad_fax","pp_oNewAddressDataForPhone",.T.)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE PAUpdateApartnerPhones
LPARAMETERS lp_nApId
LOCAL l_nSelect, l_cAPCur, l_cPHCur, i, l_cField, l_cPhone
l_nSelect = SELECT()

l_cAPCur = sqlcursor("SELECT ap_addrid, ap_phone1, ap_phone2, ap_fax FROM apartner WHERE ap_apid = " + TRANSFORM(lp_nApId))
IF RECCOUNT(l_cAPCur)>0
	l_cPHCur = sqlcursor("SELECT aj_phone, aj_field FROM adrphone WHERE aj_apid = " + TRANSFORM(lp_nApId))
	FOR i = 1 TO 3
		DO CASE
			CASE i = 1
				l_cField = "ap_phone1"
			CASE i = 2
				l_cField = "ap_phone2"
			CASE i = 3
				l_cField = "ap_fax"
		ENDCASE
		l_cPhone = PAParsePhoneNumber(EVALUATE(l_cAPCur + "." + l_cField))
		SELECT (l_cPHCur)
		LOCATE FOR aj_field = PADR(l_cField,10)
		IF FOUND()
			IF aj_phone <> l_cPhone
				sqlupdate("adrphone","aj_apid = " + TRANSFORM(lp_nApId)+" AND aj_field = '"+PADR(l_cField,10)+"'", "aj_phone = '" + l_cPhone + "'")
			ENDIF
		ELSE
			IF NOT EMPTY(l_cPhone)
				PAInsertApartner(l_cField,,l_cPhone,lp_nApId,&l_cAPCur..ap_addrid)
			ENDIF
		ENDIF
	ENDFOR
ENDIF

dclose(l_cAPCur)
dclose(l_cPHCur)

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PAParsePhoneNumber
LPARAMETERS lp_cPhoneNumber
LOCAL i, l_cPhoneCleanedUp, l_cOneChar
l_cPhoneCleanedUp = ""

FOR i = LEN(lp_cPhoneNumber) TO 1 STEP -1
	l_cOneChar = SUBSTR(lp_cPhoneNumber,i,1)
	IF ISDIGIT(l_cOneChar)
		l_cPhoneCleanedUp = l_cPhoneCleanedUp + l_cOneChar
	ENDIF
ENDFOR

RETURN l_cPhoneCleanedUp
ENDPROC
*
PROCEDURE PARemoveNonDigitsFromPhoneNumber
LPARAMETERS lp_cPhoneNumber
LOCAL i, l_cPhoneCleanedUp, l_cOneChar
l_cPhoneCleanedUp = ""

FOR i = 1 TO LEN(lp_cPhoneNumber)
	l_cOneChar = SUBSTR(lp_cPhoneNumber,i,1)
	IF ISDIGIT(l_cOneChar)
		l_cPhoneCleanedUp = l_cPhoneCleanedUp + l_cOneChar
	ENDIF
ENDFOR

RETURN l_cPhoneCleanedUp
ENDPROC
*
PROCEDURE PAAdjustPhoneNumberForSearch
LPARAMETERS lp_cNumber
LOCAL l_cAdjNumber, l_cNumberPrepared, l_Allow, l_cResult
l_cResult = ""
l_cNumberPrepared = ""
l_cAdjNumber = PARemoveNonDigitsFromPhoneNumber(lp_cNumber)

* remove 0 from begining of number (remove area code 0)
l_Allow = .F.
FOR i = 1 TO LEN(l_cAdjNumber)
	l_cDigit = SUBSTR(l_cAdjNumber, i, 1)
	IF l_cDigit <> "0"
		l_Allow = .T.
	ENDIF
	IF l_Allow
		l_cNumberPrepared = l_cNumberPrepared + l_cDigit
	ENDIF
ENDFOR

l_cResult = PAParsePhoneNumber(l_cNumberPrepared)

RETURN l_cResult
ENDPROC
*
PROCEDURE PAGetAddrIdForPhoneNumber
LPARAMETERS lp_cNumber
LOCAL l_cParsedPhoneNumber, l_nAddrId, l_cParsedPhoneNumber, l_cSql, l_cCur

l_cParsedPhoneNumber = PAAdjustPhoneNumberForSearch(lp_cNumber)

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT TOP 1 aj_addrid FROM adrphone WHERE aj_phone LIKE '<<l_cParsedPhoneNumber>>%' GROUP BY 1 ORDER BY 1
ENDTEXT

l_nSelect = SELECT()
l_cCur = sqlcursor(l_cSql)
l_nAddrId = &l_cCur..aj_addrid
dclose(l_cCur)
SELECT (l_nSelect)
RETURN l_nAddrId
ENDPROC
*
PROCEDURE PAGetAddrIdForPhoneNumberInCursor
LPARAMETERS lp_cNumber
LOCAL l_cParsedPhoneNumber, l_cParsedPhoneNumber, l_cSql, l_cCur

l_cParsedPhoneNumber = PAAdjustPhoneNumberForSearch(lp_cNumber)

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT aj_addrid FROM adrphone WHERE aj_phone LIKE '<<l_cParsedPhoneNumber>>%' GROUP BY 1 ORDER BY 1
ENDTEXT

l_cCur = sqlcursor(l_cSql,,,,,,,.T.)
SELECT (l_cCur)
INDEX ON aj_addrid TAG TAG1
RETURN l_cCur
ENDPROC
*
PROCEDURE PACreateCompanyKey
LPARAMETERS lp_cCompany
LOCAL l_cKey, l_cCompany, l_nSpace
l_cKey = ""

IF EMPTY(lp_cCompany)
     RETURN l_cKey
ENDIF

l_cCompany = LEFT(lp_cCompany,10)
l_nSpace = AT(" ",l_cCompany)

IF l_nSpace = 0
     l_nSpace = 10
ENDIF

l_cKey = UPPER(ALLTRIM(LEFT(l_cCompany, l_nSpace)))

RETURN l_cKey
ENDPROC
*

*********
* TESTS *
*********

*
PROCEDURE PAResAddrChangeGuestTest
LPARAMETERS lp_nReserId, lp_dSysDate
LOCAL l_oCheckRes, l_oReservat
dlocate("reservat","rs_reserid = " + sqlcnv(lp_nReserId))
SELECT reservat
SCATTER NAME l_oReservat MEMO
SELECT * FROM param INTO CURSOR paramtemp
dclose("param")
SELECT * FROM paramtemp INTO CURSOR param READWRITE
REPLACE pa_sysdate WITH lp_dSysDate IN param
l_oCheckRes = CREATEOBJECT("CheckReservat")
RETURN PAResAddrChangeGuest(l_oCheckRes, l_oReservat, lp_dSysDate)
ENDPROC
*
PROCEDURE PAResAddrGetRestGuestNamesTest
LPARAMETERS lp_nReserId
LOCAL l_oCheckRes, l_oReservat
dlocate("reservat","rs_reserid = " + sqlcnv(lp_nReserId))
l_oCheckRes = CREATEOBJECT("CheckReservat")
RETURN PAResAddrGetRestGuestNames(l_oCheckRes)
ENDPROC
*