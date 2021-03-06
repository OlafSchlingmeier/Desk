*
#INCLUDE "include\constdefines.h"
*
 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
			lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal
 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO PCOUNT()-1
	l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"
 l_uRetVal = &l_cCallProc
 RETURN l_uRetVal
ENDFUNC
*
PROCEDURE FromAddrToRes
 LPARAMETERS lmode, lpcAddress, lpcReservat, lp_aChanges, lp_lSilent, lp_lSameFeat, lp_curFeatureSelect
 IF PCOUNT()=0
	lmode=0
 ENDIF
 LOCAL LAddrfield, LReserfield, LDostring, LTypeAddr, LTypeRes, LCheck
 LOCAL LOccur, l_lFeatures, i, lcReservat, lcAddress, llOpenedAdr2Res, lnArea, l_lCurFeat

 lnArea = SELECT()
 IF PCOUNT() < 2
	lcAddress = "address"
 ELSE
	lcAddress = lpcAddress
 ENDIF
 IF PCOUNT() < 3
	lcReservat = "reservat"
 ELSE
	lcReservat = lpcReservat
 ENDIF
 
 l_lFeatures = .F.
 l_lCurFeat = NOT EMPTY(lp_curFeatureSelect) AND USED(lp_curFeatureSelect)
 llOpenedAdr2Res = .T.
 IF !USED("adrtores")
	openfiledirect(.F., "adrtores",,,,.T.)
	llOpenedAdr2Res = .F.
 ENDIF
 SELECT adrtores
 SCAN
	IF UPPER(ALLTRIM(adrtores.resfield)) = "RESFEAT.FR_FEATURE"
		IF l_lCurFeat
			SELECT * FROM (SELECT * FROM adrfeat WHERE fa_addrid = &lcAddress..ad_addrid) fa ;
				FULL JOIN (SELECT c_feature AS fr_feature, &lcReservat..rs_rsid AS fr_rsid FROM &lp_curFeatureSelect WHERE NOT EMPTY(c_feature) AND c_selected) fr ON fa_feature = fr_feature ;
				INTO CURSOR curAdrResFeat
		ELSE
			SELECT * FROM (SELECT * FROM adrfeat WHERE fa_addrid = &lcAddress..ad_addrid) fa ;
				FULL JOIN (SELECT * FROM resfeat WHERE fr_rsid = &lcReservat..rs_rsid) fr ON fa_feature = fr_feature ;
				INTO CURSOR curAdrResFeat
		ENDIF
		IF DLocate("curAdrResFeat", "ISNULL(fa_addrid) OR ISNULL(fr_rsid)") AND NOT lp_lSameFeat
			l_lFeatures = .T.
		ENDIF
	ELSE
		LAddrfield = ALLTRIM(adrtores.adrfield)
		IF AT("(",LAddrfield)=0
			IF lmode=1
				LAddrfield = lcAddress + '.' + LAddrfield
			ELSE
				laddrfield='m.'+laddrfield
			ENDIF
			LTypeAddr = TYPE(LAddrfield)
		ELSE
			LOccur = RAT("(",LAddrfield)
			LCheck = SUBSTR(LAddrfield, LOccur+1)
			IF lmode=1
				LCheck = lcAddress + '.' + LCheck
			ELSE
				lcheck='m.'+lcheck
			ENDIF
			LAddrfield= LEFT(LAddrfield, LOccur)+LCheck 
			LTypeAddr = TYPE(LAddrfield)
		ENDIF
		*LReserfield = 'm.'+ALLTRIM(adrtores.resfield)
		LReserfield = lcReservat + '.' + ALLTRIM(adrtores.resfield)
		LTypeRes = TYPE(LReserfield)
		IF LTypeAddr == LTypeRes OR (LTypeAddr = "C" AND LTypeRes = "M")
			*LDostring = LReserfield +'='+LAddrfield
			IF EMPTY(&LReserfield)
				IF PCOUNT() < 4
					LDostring = 'replace '+LReserfield +' with '+LAddrfield +' in ' + lcReservat
					&LDostring
				ELSE
					DIMENSION lp_aChanges(ALEN(lp_aChanges,1)+1,3)
					lp_aChanges(ALEN(lp_aChanges,1),1) = ALLTRIM(adrtores.resfield)
					lp_aChanges(ALEN(lp_aChanges,1),2) = EVALUATE(LAddrfield)
					lp_aChanges(ALEN(lp_aChanges,1),3) = NOT IsResSetCommonField(ALLTRIM(adrtores.resfield))
				ENDIF
			ENDIF
		ENDIF
	ENDIF
 ENDSCAN
 IF l_lFeatures
 	LOCAL l_cMessage, l_cOldMsg, l_cNewMsg, l_lReplace, l_lAsk
 	IF NOT lp_lSilent
	 	l_cOldMsg = ""
	 	l_cNewMsg = ""
	 	SELECT curAdrResFeat
	 	SCAN
		 	IF NOT ISNULL(fr_feature)
		 		l_cOldMsg = l_cOldMsg + IIF(EMPTY(l_cOldMsg), "", ",") + PADR(fr_feature,8)
		 	ENDIF
		 	IF NOT ISNULL(fa_feature)
		 		l_cNewMsg = l_cNewMsg + IIF(EMPTY(l_cNewMsg), "", ",") + PADR(fa_feature,8)
		 	ENDIF
	 	ENDSCAN
	 	l_cMessage = GetLangText("RESERVAT","TXT_DIFF_FEAT") + "        ;"
	 	l_cMessage = l_cMessage + "    " + GetLangText("RESERVAT","TXT_OLD_FEAT") + "              " + l_cOldMsg + ";"
	 	l_cMessage = l_cMessage + "    " + GetLangText("RESERVAT","TXT_NEW_FEAT") + "             " + l_cNewMsg + ";"
	 	l_cMessage = l_cMessage + GetLangText("RESERVAT","TXT_UPD_FEAT")
		l_lReplace = YesNo(l_cMessage)
	ELSE
		l_lReplace = .T.
	ENDIF
	IF l_lReplace
	 	IF l_lCurFeat
		 	IF DLocate("curAdrResFeat", "NOT ISNULL(fa_feature)")
		 		REPLACE c_selected WITH RECNO() > 1 AND DLocate("curAdrResFeat", "NOT ISNULL(fa_feature) AND fa_feature = "+lp_curFeatureSelect+".c_feature") ALL IN &lp_curFeatureSelect
		 	ELSE
		 		REPLACE c_selected WITH (RECNO() = 1) ALL IN &lp_curFeatureSelect
		 	ENDIF
	 	ELSE
		 	SELECT curAdrResFeat
		 	SCAN
			 	IF ISNULL(fr_feature)
			 		INSERT INTO resfeat (fr_frid, fr_rsid, fr_feature) VALUES (NextId("resfeat"), &lcReservat..rs_rsid, curAdrResFeat.fa_feature)
			 	ENDIF
			 	IF ISNULL(fa_feature)
			 		DELETE FOR fr_frid = curAdrResFeat.fr_frid AND fr_feature = curAdrResFeat.fr_feature IN resfeat
			 	ENDIF
		 	ENDSCAN
	 	ENDIF
	ENDIF
 ENDIF
 dclose("curAdrResFeat")
 IF !llOpenedAdr2Res
	dclose("adrtores")
 ENDIF

 SELECT(lnArea)
ENDPROC
*
PROCEDURE IsResSetCommonField
LPARAMETERS lp_cField, lp_lAnswer
 lp_cField = UPPER(lp_cField)
 DO CASE
  CASE (lp_cField == "RS_ADDRID") OR ;
		(lp_cField == "RS_AGENT") OR ;
		(lp_cField == "RS_AGENTID") OR ;
		(lp_cField == "RS_ALTID") OR ;
		(lp_cField == "RS_APID") OR ;
		(lp_cField == "RS_APNAME") OR ;
		(lp_cField == "RS_BILLINS") OR ;
		(lp_cField == "RS_CCNUM") OR ;
		(lp_cField == "RS_CCEXPY") OR ;
		(lp_cField == "RS_CCLIMIT") OR ;
		(lp_cField == "RS_CCAUTH") OR ;
		(lp_cField == "RS_COMPANY") OR ;
		(lp_cField == "RS_COMPID") OR ;
		(lp_cField == "RS_CONRES") OR ;
		(lp_cField == "RS_DISCNT") OR ;
		(lp_cField == "RS_GROUP") OR ;
		(lp_cField == "RS_GROUPID") OR ;
		(lp_cField == "RS_INVAP") OR ;
		(lp_cField == "RS_INVAPID") OR ;
		(lp_cField == "RS_INVID") OR ;
		(lp_cField == "RS_LNAME") OR ;
		(lp_cField == "RS_MARKET") OR ;
		(lp_cField == "RS_NOTECO") OR ;
		(lp_cField == "RS_PAYMETH") OR ;
		(lp_cField == "RS_SOURCE") OR ;
		(lp_cField == "RS_SADDRID") OR ;
		(lp_cField == "RS_SNAME")
	lp_lAnswer = .T.
  *CASE INLIST(lp_cField, "")
	*lp_lAnswer = .F.
  OTHERWISE
	*IF g_lDevelopment
	*	= Alert(StrFmt([Please report "ResSetCommon-%s1 Error" to your vendor!], ;
	*			lp_cField))
	*ENDIF
	lp_lAnswer = .F.
 ENDCASE
RETURN lp_lAnswer
ENDPROC
*
PROCEDURE FromHistToRes
LPARAMETERS lp_nReserId, lp_cResAlias, lp_lOnlyHistres
 LOCAL l_lCloseHistres, lcReplaceClause, l_cSetDeleted, l_oData
 IF EMPTY(lp_cResAlias)
 	lp_cResAlias = "reservat"
 ENDIF
 IF SEEK(lp_nReserId,lp_cResAlias,"tag1")
	RETURN .F.
 ENDIF
 IF NOT USED("histres")
	openfiledirect(.F., "histres")
	l_lCloseHistres = .T.
 ENDIF
 CursorQuery("histres", "hr_reserid = " + SqlCnv(lp_nReserId,.T.))
 IF NOT SEEK(lp_nReserId,"histres","tag1")
	IF l_lCloseHistres
		dclose("histres")
	ENDIF
	RETURN .F.
 ENDIF
 lcReplaceClause = GetReplaceClauseForSimilarFields("histres", lp_cResAlias)
 l_cSetDeleted = SET("Deleted")
 SET DELETED OFF
 IF SEEK(histres.hr_rsid,lp_cResAlias,"tag33") AND DELETED(lp_cResAlias)
 	SELECT &lp_cResAlias
 	RECALL
 	SCATTER NAME l_oData MEMO BLANK
 	l_oData.rs_rsid = histres.hr_rsid
 	GATHER NAME l_oData MEMO
 ELSE
	 INSERT INTO &lp_cResAlias (rs_rsid) VALUES (histres.hr_rsid)
 ENDIF
 
 SET DELETED &l_cSetDeleted
 *APPEND BLANK IN &lp_cResAlias
 REPLACE &lcReplaceClause IN &lp_cResAlias
 DO FromHResExtToRes WITH histres.hr_rsid, lp_cResAlias
 IF NOT lp_lOnlyHistres
	 DO FromHistToResrooms WITH histres.hr_reserid
	 DO FromHistToResAddr WITH histres.hr_reserid
	 DO FromHistToResCard WITH histres.hr_rsid
	 DO FromHistToPsWindow WITH histres.hr_rsid
	 DO FromHistToResFeat WITH histres.hr_rsid
	 IF l_lCloseHistres
		dclose("histres")
	 ENDIF
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE FromResToHist
LPARAMETERS lp_nReserId, lp_cResAlias
 LOCAL l_lCloseHistres, lcReplaceClause, lcSkipFields
 IF PCOUNT() < 2
 	lp_cResAlias = "reservat"
 ENDIF
 IF lp_nReserId <> &lp_cResAlias..rs_reserid AND ;
		NOT SEEK(lp_nReserId,lp_cResAlias,"tag1")
	RETURN .F.
 ENDIF
 IF NOT USED("histres")
	openfiledirect(.F., "histres")
	l_lCloseHistres = .T.
 ENDIF
 IF _screen.oGlobal.lDontSaveCreditCard
	lcSkipFields = "RS_CCAUTH,RS_CCEXPY,RS_CCNUM,"
 ELSE
	lcSkipFields = ""
 ENDIF
 lcReplaceClause = GetReplaceClauseForSimilarFields(lp_cResAlias, "histres", .T., lcSkipFields)
 IF NOT SEEK(lp_nReserId,"histres","tag1")
 	INSERT INTO histres (hr_rsid) VALUES (&lp_cResAlias..rs_rsid)
 	*APPEND BLANK
 ENDIF
 REPLACE &lcReplaceClause IN histres
 IF NOT (histres.hr_billins==&lp_cResAlias..rs_billins) OR ;
		NOT (histres.hr_changes==&lp_cResAlias..rs_changes) OR ;
		NOT (histres.hr_note==&lp_cResAlias..rs_note) OR ;
		NOT (histres.hr_notew1==&lp_cResAlias..rs_notew1) OR ;
		NOT (histres.hr_notew2==&lp_cResAlias..rs_notew2) OR ;
		NOT (histres.hr_notew3==&lp_cResAlias..rs_notew3) OR ;
		NOT (histres.hr_notew4==&lp_cResAlias..rs_notew4) OR ;
		NOT (histres.hr_notew5==&lp_cResAlias..rs_notew5) OR ;
		NOT (histres.hr_notew6==&lp_cResAlias..rs_notew6)
 	* Memo fields are replace only if there are changed.
	REPLACE hr_billins WITH &lp_cResAlias..rs_billins, ;
			hr_changes WITH &lp_cResAlias..rs_changes, ;
			hr_note WITH &lp_cResAlias..rs_note, ;
			hr_notew1 WITH &lp_cResAlias..rs_notew1, ;
			hr_notew2 WITH &lp_cResAlias..rs_notew2, ;
			hr_notew3 WITH &lp_cResAlias..rs_notew3, ;
			hr_notew4 WITH &lp_cResAlias..rs_notew4, ;
			hr_notew5 WITH &lp_cResAlias..rs_notew5, ;
			hr_notew6 WITH &lp_cResAlias..rs_notew6 IN histres
 ENDIF
 DO FromResToHResExt WITH &lp_cResAlias..rs_rsid, lp_cResAlias
 DO FromResroomsToHist WITH &lp_cResAlias..rs_reserid
 DO FromResAddrToHist WITH &lp_cResAlias..rs_reserid
 DO FromResCardToHist WITH &lp_cResAlias..rs_rsid
 DO FromPsWindowToHist WITH &lp_cResAlias..rs_rsid
 DO FromResFeatToHist WITH &lp_cResAlias..rs_rsid
 *****************************************************************************************************
 * ATTENTION!                                                                                        *
 * When you add here some child table, to be copied into history table, don't forget to              *
 * add code in HistReservat function in audit.prg, to delete records from this child table,          *
 * when reservation is deleted from reservat table!                                                  *
 * IMPORTANT:                                                                                        *
 * FromResCardToHist, and other functions here, shouldn't delete records from dynamic child tables!! *
 *****************************************************************************************************
 IF l_lCloseHistres
	dclose("histres")
 ENDIF
ENDPROC
*
PROCEDURE FromHistToPost
LPARAMETERS lp_nReserId, lp_cPostAlias, lp_lOnlyPost
 LOCAL l_lCloseHPostcng, l_lCloseHpostifc, l_cOrder, lcReplaceClause
 IF EMPTY(lp_cPostAlias)
 	lp_cPostAlias = "post"
 ENDIF
 l_cOrder = ORDER("histpost")
 IF NOT lp_lOnlyPost AND NOT USED("hpostcng")
	openfiledirect(.F., "hpostcng")
	l_lCloseHPostcng = .T.
 ENDIF
 IF NOT USED("hpostifc")
	openfiledirect(.F., "hpostifc")
	l_lCloseHpostifc = .T.
 ENDIF
 lcReplaceClause = GetReplaceClauseForSimilarFields("histpost", lp_cPostAlias)
 SELECT histpost
 SET ORDER TO
 SCAN FOR hp_reserid = lp_nReserId
	IF SEEK(histpost.hp_postid,lp_cPostAlias,"tag3")
		LOOP
	ENDIF
	APPEND BLANK IN &lp_cPostAlias
	REPLACE &lcReplaceClause IN &lp_cPostAlias
	FromHistToRpostifc(histpost.hp_setid)
	IF NOT lp_lOnlyPost
		FromHistToPostchanges(histpost.hp_postid)
	ENDIF
 ENDSCAN
 SET ORDER TO l_cOrder
 IF l_lCloseHPostcng
	dclose("hpostcng")
 ENDIF
 IF l_lCloseHPostifc
	dclose("hpostifc")
 ENDIF
ENDPROC
*
PROCEDURE FromPostToHist
LPARAMETERS lp_nReserId
LOCAL l_lCloseHPostcng, l_lCloseHpostifc, lcReplaceClause
 IF NOT USED("hpostcng")
	openfiledirect(.F., "hpostcng")
	l_lCloseHPostcng = .T.
 ENDIF
 IF NOT USED("hpostifc")
	openfiledirect(.F., "hpostifc")
	l_lCloseHpostifc = .T.
 ENDIF
 lcReplaceClause = GetReplaceClauseForSimilarFields("post", "histpost", .T.)
 SELECT post
 SCAN FOR ps_reserid = lp_nReserId
	IF NOT SEEK(ps_postid,"histpost","tag3")
		APPEND BLANK IN histpost
		IF post.ps_date = g_SysDate
			* Update Statistics
			DO AaPost IN AaUpd WITH "histstat", ps_date
			DO OrPost IN OrUpd WITH "histors"
		ENDIF
	ENDIF
	IF post.ps_touched OR NOT FOUND("histpost")
		REPLACE &lcReplaceClause IN histpost
		IF NOT (histpost.hp_currtxt == post.ps_currtxt) OR ;
				NOT (histpost.hp_note == post.ps_note) OR ;
				NOT (histpost.hp_ifc == post.ps_ifc)
			* Memo fields are replace only if there are changed.
			REPLACE hp_currtxt WITH post.ps_currtxt, ;
					hp_note WITH post.ps_note, ;
					hp_ifc WITH post.ps_ifc IN histpost
		ENDIF
		FromRpostifcToHist(post.ps_setid)
		FromPostchangesToHist(post.ps_postid)
	ENDIF
	SELECT post
	IF (poSt.ps_date < g_SysDate) AND NOT post.ps_touched
		IF NOT EMPTY(post.ps_setid)
			DELETE FOR rk_setid = post.ps_setid IN rpostifc
		ENDIF
		DELETE FOR ph_postid = post.ps_postid IN postchng
		DELETE
	ENDIF
 ENDSCAN
 IF l_lCloseHPostcng
	dclose("hpostcng")
 ENDIF
 IF l_lCloseHPostifc
	dclose("hpostifc")
 ENDIF
ENDPROC
*
PROCEDURE FromRpostifcToHist
LPARAMETERS lp_nSetId
LOCAL l_nSelect, l_lCloseHPostifc, l_oRpostifc
 IF EMPTY(lp_nSetId)
	RETURN .T.
 ENDIF
 l_nSelect = SELECT()
 IF NOT USED("hpostifc")
	openfiledirect(.F., "hpostifc")
	l_lCloseHpostifc = .T.
 ENDIF
 IF SEEK(lp_nSetId, "rpostifc", "tag2")
	SELECT rpostifc
	SCATTER NAME l_oRpostifc MEMO
	SELECT hpostifc
	IF NOT SEEK(lp_nSetId, "hpostifc", "tag1")
		APPEND BLANK
	ENDIF
	GATHER NAME l_oRpostifc MEMO
 ENDIF
 IF l_lCloseHPostifc
	dclose("hpostifc")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToRpostifc
LPARAMETERS lp_nSetId
LOCAL l_nSelect, l_lCloseHPostifc, l_oRpostifc
 IF EMPTY(lp_nSetId)
	RETURN .T.
 ENDIF
 l_nSelect = SELECT()
 IF NOT USED("hpostifc")
	openfiledirect(.F., "hpostifc")
	l_lCloseHPostifc = .T.
 ENDIF
 IF SEEK(lp_nSetId, "hpostifc", "tag1")
	SELECT hpostifc
	SCATTER NAME l_oRpostifc MEMO
	SELECT rpostifc
	IF NOT SEEK(lp_nSetId, "rpostifc", "tag2")
		APPEND BLANK
	ENDIF
	GATHER NAME l_oRpostifc MEMO
 ENDIF
 IF l_lCloseHPostifc
	dclose("hpostifc")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromPostchangesToHist
LPARAMETERS lp_nPostId
LOCAL l_nSelect, l_lCloseHPostcng
 l_nSelect = SELECT()
 IF NOT USED("hpostcng")
	openfiledirect(.F., "hpostcng")
	l_lCloseHPostcng = .T.
 ENDIF
 SELECT hpostcng
 DELETE ALL FOR ph_postid = lp_nPostId
 AppendFrom("postchng","ph_postid="+SqlCnv(lp_nPostId))
 IF l_lCloseHPostcng
	dclose("hpostcng")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToPostchanges
LPARAMETERS lp_nPostId
LOCAL l_nSelect, l_lCloseHPostcng
 l_nSelect = SELECT()
 IF NOT USED("hpostcng")
	openfiledirect(.F., "hpostcng")
	l_lCloseHPostcng = .T.
 ENDIF
 IF NOT SEEK(lp_nPostId,"postchng","tag1")
	 AppendFrom("hpostcng","ph_postid="+SqlCnv(lp_nPostId),"postchng")
 ENDIF
 IF l_lCloseHPostcng
	dclose("hpostcng")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResToHResExt
LPARAMETERS lp_nRsId, lp_cResAlias
LOCAL l_nSelect, l_lCloseHResExt, l_oResObj, l_cFieldsExcept
 l_nSelect = SELECT()
 IF NOT USED("hresext")
	openfiledirect(.F., "hresext")
	l_lCloseHResExt = .T.
 ENDIF
 IF (lp_nRsId = &lp_cResAlias..rs_rsid) OR SEEK(lp_nRsId,lp_cResAlias,"tag33")
 	IF _screen.oGlobal.lDontSaveCreditCard
 		l_cFieldsExcept = "FIELDS EXCEPT rs_cclimit,rs_ccref"
 	ELSE
 		l_cFieldsExcept = ""
 	ENDIF
 	SELECT &lp_cResAlias
 	SCATTER NAME l_oResObj MEMO
 	SELECT hresext
 	IF NOT SEEK(lp_nRsId,"hresext","tag3")
 		APPEND BLANK
 		GATHER NAME l_oResObj MEMO &l_cFieldsExcept
 	ELSE
 		GATHER NAME l_oResObj &l_cFieldsExcept
 		IF NOT (hresext.rs_message==&lp_cResAlias..rs_message) OR ;
				NOT (hresext.rs_noteco==&lp_cResAlias..rs_noteco) OR ;
				NOT (hresext.rs_custom1==&lp_cResAlias..rs_custom1) OR ;
				NOT (hresext.rs_rminfo1==&lp_cResAlias..rs_rminfo1) OR ;
				NOT (hresext.rs_rminfo2==&lp_cResAlias..rs_rminfo2)
 	* Memo fields are replace only if there are changed.
			REPLACE rs_message WITH &lp_cResAlias..rs_message, ;
					rs_noteco WITH &lp_cResAlias..rs_noteco, ;
					rs_custom1 WITH &lp_cResAlias..rs_custom1, ;
					rs_rminfo1 WITH &lp_cResAlias..rs_rminfo1, ;
					rs_rminfo2 WITH &lp_cResAlias..rs_rminfo2 ;
					IN hresext
		ENDIF
 	ENDIF
 	* From Reservat table copy only fields whoose are in HResExt table.
 ENDIF
 IF l_lCloseHResExt
	dclose("hresext")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHResExtToRes
LPARAMETERS lp_nRsId, lp_cResAlias
LOCAL l_nSelect, l_lCloseHResExt, l_oResObj
 l_nSelect = SELECT()
 IF NOT USED("hresext")
	openfiledirect(.F., "hresext")
	l_lCloseHResExt = .T.
 ENDIF
 CursorQuery("hresext", "rs_rsid = " + SqlCnv(lp_nRsId,.T.))
 IF SEEK(lp_nRsId,"hresext","tag3") AND SEEK(lp_nRsId,lp_cResAlias,"tag33")
 	SELECT hresext
 	SCATTER NAME l_oResObj MEMO
 	* To Reservat table copy only fields whoose are in HResExt table.
 	SELECT &lp_cResAlias
 	GATHER NAME l_oResObj MEMO
 ENDIF
 IF l_lCloseHResExt
	dclose("hresext")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResroomsToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHResroom
 l_nSelect = SELECT()
 IF NOT USED("hresroom")
	openfiledirect(.F., "hresroom")
	l_lCloseHResroom = .T.
 ENDIF
 SELECT hresroom
 DELETE FOR ri_reserid = lp_nReserId
 AppendFrom("resrooms","ri_reserid="+SqlCnv(lp_nReserId),"hresroom","ri_rroomid")
 IF l_lCloseHResroom
	dclose("hresroom")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToResrooms
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHResroom
 l_nSelect = SELECT()
 IF NOT USED("hresroom")
	openfiledirect(.F., "hresroom")
	l_lCloseHResroom = .T.
 ENDIF
 SELECT resrooms
 DELETE FOR ri_reserid = lp_nReserId
 AppendFrom("hresroom","ri_reserid="+SqlCnv(lp_nReserId),"resrooms","ri_rroomid")
 IF l_lCloseHResroom
	dclose("hresroom")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResAddrToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect
 l_nSelect = SELECT()
 = openfile(.F., "hresaddr")
 SELECT hresaddr
 DELETE ALL FOR rg_reserid = lp_nReserId
 AppendFrom("resaddr","rg_reserid="+SqlCnv(lp_nReserId),"hresaddr")
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToResAddr
LPARAMETERS lp_nReserId
LOCAL l_nSelect
 l_nSelect = SELECT()
 = openfile(.F., "hresaddr")
 IF NOT SEEK(lp_nReserId,"resaddr","tag2")
     AppendFrom("hresaddr","rg_reserid="+SqlCnv(lp_nReserId),"resaddr")
     IF CURSORGETPROP("Buffering","resaddr")<>1
          = TABLEUPDATE(.T.,.T.,"resaddr")
     ENDIF
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromBanquetToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHBanquet
 l_nSelect = SELECT()
 IF NOT USED("hbanquet")
	openfiledirect(.F., "hbanquet")
	l_lCloseHBanquet = .T.
 ENDIF
 AppendFrom("banquet","bq_reserid="+SqlCnv(lp_nReserId),"hbanquet")
 SELECT banquet
 DELETE ALL FOR bq_reserid = lp_nReserId
 IF l_lCloseHBanquet
	dclose("hbanquet")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToBanquet
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHBanquet
 l_nSelect = SELECT()
 IF NOT USED("hbanquet")
	openfiledirect(.F., "hbanquet")
	l_lCloseHBanquet = .T.
 ENDIF
 IF NOT SEEK(lp_nReserId,"banquet","tag1")
	AppendFrom("hbanquet","bq_reserid="+SqlCnv(lp_nReserId),"banquet")
 ENDIF
 IF l_lCloseHBanquet
	dclose("hbanquet")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResfixToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHResfix
 l_nSelect = SELECT()
 IF NOT USED("hresfix")
	openfiledirect(.F., "hresfix")
	l_lCloseHResfix = .T.
 ENDIF
 AppendFrom("resfix","rf_reserid="+SqlCnv(lp_nReserId),"hresfix")
 SELECT resfix
 DELETE ALL FOR rf_reserid = lp_nReserId
 IF l_lCloseHResfix
	dclose("hresfix")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToResfix
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHResfix
 l_nSelect = SELECT()
 IF NOT USED("hresfix")
	openfiledirect(.F., "hresfix")
	l_lCloseHResfix = .T.
 ENDIF
 IF NOT SEEK(lp_nReserId,"resfix","tag1")
	AppendFrom("hresfix","rf_reserid="+SqlCnv(lp_nReserId),"resfix")
 ENDIF
 IF l_lCloseHResfix
	dclose("hresfix")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResrateToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHResrate
 l_nSelect = SELECT()
 IF NOT USED("reservat")
 	openfiledirect(.F., "reservat")
 ENDIF
 IF NOT USED("hresrate")
	openfiledirect(.F., "hresrate")
	l_lCloseHResrate = .T.
 ENDIF
 AppendFrom("resrate","rr_reserid="+SqlCnv(lp_nReserId),"hresrate")
 SELECT resrate
 DELETE ALL FOR rr_reserid = lp_nReserId
 IF l_lCloseHResrate
	dclose("hresrate")
 ENDIF
 DO FromYiofferToHist WITH 0, DLookUp("reservat", "rs_reserid = " + SqlCnv(lp_nReserId), "rs_rsid")
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToResrate
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHResrate
 l_nSelect = SELECT()
 IF NOT USED("hresrate")
	openfiledirect(.F., "hresrate")
	l_lCloseHResrate = .T.
 ENDIF
 IF NOT SEEK(lp_nReserId,"resrate","tag3")
	AppendFrom("hresrate","rr_reserid="+SqlCnv(lp_nReserId),"resrate")
 ENDIF
 IF l_lCloseHResrate
	dclose("hresrate")
 ENDIF
 DO FromHistToYioffer WITH DLookUp("hresext", "rs_reserid = " + SqlCnv(lp_nReserId), "rs_yoid")
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromRessplitToHist
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseRessplit, l_lCloseHResplit
 l_nSelect = SELECT()
 IF NOT USED("ressplit")
	OpenFile(.F.,"ressplit")
	l_lCloseRessplit = .T.
 ENDIF
 IF NOT USED("hresplit")
	OpenFile(.F.,"hresplit")
	l_lCloseHResplit = .T.
 ENDIF
 AppendFrom("ressplit","rl_rsid="+SqlCnv(lp_nRsId),"hresplit")
 SELECT ressplit
 DELETE ALL FOR rl_rsid = lp_nRsId
 IF l_lCloseRessplit
	CloseFile("ressplit")
 ENDIF
 IF l_lCloseHResplit
	CloseFile("hresplit")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToRessplit
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseRessplit, l_lCloseHResplit
 l_nSelect = SELECT()
 IF NOT USED("ressplit")
	OpenFile(.F.,"ressplit")
	l_lCloseRessplit = .T.
 ENDIF
 IF NOT USED("hresplit")
	OpenFile(.F.,"hresplit")
	l_lCloseHResplit = .T.
 ENDIF
 IF NOT SEEK(lp_nRsId,"ressplit","tag1")
	AppendFrom("hresplit","rl_rsid="+SqlCnv(lp_nRsId),"ressplit")
	IF CURSORGETPROP("Buffering","ressplit") <> 1
		= TABLEUPDATE(.T.,.T.,"ressplit")
	ENDIF
 ENDIF
 IF l_lCloseRessplit
	CloseFile("ressplit")
 ENDIF
 IF l_lCloseHResplit
	CloseFile("hresplit")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResrartToHist
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseResrart, l_lCloseHResrart
 l_nSelect = SELECT()
 IF NOT USED("Resrart")
	OpenFile(.F.,"Resrart")
	l_lCloseResrart = .T.
 ENDIF
 IF NOT USED("HResrart")
	OpenFile(.F.,"HResrart")
	l_lCloseHResrart = .T.
 ENDIF
 AppendFrom("Resrart","ra_rsid="+SqlCnv(lp_nRsId),"HResrart")
 SELECT Resrart
 DELETE ALL FOR ra_rsid = lp_nRsId
 IF l_lCloseResrart
	CloseFile("Resrart")
 ENDIF
 IF l_lCloseHResrart
	CloseFile("HResrart")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToResrart
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseResrart, l_lCloseHResrart
 l_nSelect = SELECT()
 IF NOT USED("Resrart")
	OpenFile(.F.,"Resrart")
	l_lCloseResrart = .T.
 ENDIF
 IF NOT USED("HResrart")
	OpenFile(.F.,"HResrart")
	l_lCloseHResrart = .T.
 ENDIF
 IF NOT SEEK(lp_nRsId,"Resrart","tag3")
	AppendFrom("HResrart","ra_rsid="+SqlCnv(lp_nRsId),"Resrart")
	IF CURSORGETPROP("Buffering","Resrart") <> 1
		= TABLEUPDATE(.T.,.T.,"Resrart")
	ENDIF
 ENDIF
 IF l_lCloseResrart
	CloseFile("Resrart")
 ENDIF
 IF l_lCloseHResrart
	CloseFile("HResrart")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromDepositToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHDeposit
 l_nSelect = SELECT()
 IF NOT USED("hdeposit")
	openfiledirect(.F., "hdeposit")
	l_lCloseHDeposit = .T.
 ENDIF
 AppendFrom("deposit","dp_reserid="+SqlCnv(lp_nReserId),"hdeposit")
 SELECT deposit
 DELETE ALL FOR dp_reserid = lp_nReserId
 IF l_lCloseHDeposit
	dclose("hdeposit")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToDeposit
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHDeposit
 l_nSelect = SELECT()
 IF NOT USED("hdeposit")
	openfiledirect(.F., "hdeposit")
	l_lCloseHDeposit = .T.
 ENDIF
 IF NOT SEEK(lp_nReserId,"deposit","tag3")
	AppendFrom("hdeposit","dp_reserid="+SqlCnv(lp_nReserId),"deposit")
 ENDIF
 IF l_lCloseHDeposit
	dclose("hdeposit")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromRescardToHist
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseRescard, l_lCloseHRescard
 l_nSelect = SELECT()
 IF NOT USED("rescard")
	OpenFile(.F.,"rescard")
	l_lCloseRescard = .T.
 ENDIF
 IF NOT USED("hrescard")
	OpenFile(.F.,"hrescard")
	l_lCloseHRescard = .T.
 ENDIF
 SELECT hrescard
 DELETE ALL FOR cr_rsid = lp_nRsId
 AppendFrom("rescard","cr_rsid="+SqlCnv(lp_nRsId),"hrescard")
 IF l_lCloseRescard
	CloseFile("rescard")
 ENDIF
 IF l_lCloseHRescard
	CloseFile("hrescard")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToRescard
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseRescard, l_lCloseHRescard
 l_nSelect = SELECT()
 IF NOT USED("rescard")
	OpenFile(.F.,"rescard")
	l_lCloseRescard = .T.
 ENDIF
 IF NOT USED("hrescard")
	OpenFile(.F.,"hrescard")
	l_lCloseHRescard = .T.
 ENDIF
 IF NOT SEEK(lp_nRsId,"rescard","tag2")
	AppendFrom("hrescard","cr_rsid="+SqlCnv(lp_nRsId),"rescard")
	IF CURSORGETPROP("Buffering","rescard")<>1
		= TABLEUPDATE(.T.,.T.,"rescard")
	ENDIF
 ENDIF
 IF l_lCloseRescard
	CloseFile("rescard")
 ENDIF
 IF l_lCloseHRescard
	CloseFile("hrescard")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResFeatToHist
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseResFeat, l_lCloseHResFeat
 l_nSelect = SELECT()
 IF NOT USED("resfeat")
	OpenFile(.F.,"resfeat")
	l_lCloseResFeat = .T.
 ENDIF
 IF NOT USED("hresfeat")
	OpenFile(.F.,"hresfeat")
	l_lCloseHResFeat = .T.
 ENDIF
 SELECT hresfeat
 DELETE ALL FOR fr_rsid = lp_nRsId
 AppendFrom("resfeat","fr_rsid="+SqlCnv(lp_nRsId),"hresfeat")
 IF l_lCloseResFeat
	CloseFile("resfeat")
 ENDIF
 IF l_lCloseHResFeat
	CloseFile("hresfeat")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToResFeat
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lCloseResFeat, l_lCloseHResFeat
 l_nSelect = SELECT()
 IF NOT USED("resfeat")
	OpenFile(.F.,"resfeat")
	l_lCloseResFeat = .T.
 ENDIF
 IF NOT USED("hresfeat")
	OpenFile(.F.,"hresfeat")
	l_lCloseHResFeat = .T.
 ENDIF
 IF NOT SEEK(lp_nRsId,"resfeat","tag2")
	AppendFrom("hresfeat","fr_rsid="+SqlCnv(lp_nRsId),"resfeat")
	IF CURSORGETPROP("Buffering","resfeat")<>1
		= TABLEUPDATE(.T.,.T.,"resfeat")
	ENDIF
 ENDIF
 IF l_lCloseResFeat
	CloseFile("resfeat")
 ENDIF
 IF l_lCloseHResFeat
	CloseFile("hresfeat")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromPsWindowToHist
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lClosePsWindow, l_lCloseHpWindow
 l_nSelect = SELECT()
 IF NOT USED("pswindow")
	OpenFile(.F.,"pswindow")
	l_lClosePsWindow = .T.
 ENDIF
 IF NOT USED("hpwindow")
	OpenFile(.F.,"hpwindow")
	l_lCloseHpWindow = .T.
 ENDIF
 SELECT hpwindow
 DELETE ALL FOR pw_rsid = lp_nRsId
 AppendFrom("pswindow","pw_rsid="+SqlCnv(lp_nRsId),"hpwindow")
 IF l_lClosePsWindow
	CloseFile("pswindow")
 ENDIF
 IF l_lCloseHpWindow
	CloseFile("hpwindow")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToPsWindow
LPARAMETERS lp_nRsId
LOCAL l_nSelect, l_lClosePsWindow, l_lCloseHpWindow
 l_nSelect = SELECT()
 IF NOT USED("pswindow")
	OpenFile(.F.,"pswindow")
	l_lClosePsWindow = .T.
 ENDIF
 IF NOT USED("hpwindow")
	OpenFile(.F.,"hpwindow")
	l_lCloseHpWindow = .T.
 ENDIF
 IF NOT SEEK(lp_nRsId,"pswindow","tag2")
	AppendFrom("hpwindow","pw_rsid="+SqlCnv(lp_nRsId),"pswindow")
	IF CURSORGETPROP("Buffering","pswindow")<>1
		= TABLEUPDATE(.T.,.T.,"pswindow")
	ENDIF
 ENDIF
 IF l_lClosePsWindow
	CloseFile("pswindow")
 ENDIF
 IF l_lCloseHpWindow
	CloseFile("hpwindow")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromSheetToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHSheet
 l_nSelect = SELECT()
 IF NOT USED("hsheet")
	openfiledirect(.F., "hsheet")
	l_lCloseHSheet = .T.
 ENDIF
 AppendFrom("sheet","sh_reserid="+SqlCnv(lp_nReserId),"hsheet")
 SELECT sheet
 DELETE ALL FOR sh_reserid = lp_nReserId
 IF l_lCloseHSheet
	dclose("hsheet")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToSheet
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHSheet
 l_nSelect = SELECT()
 IF NOT USED("hsheet")
	openfiledirect(.F., "hsheet")
	l_lCloseHSheet = .T.
 ENDIF
 IF NOT SEEK(lp_nReserId,"sheet","tag1")
	AppendFrom("hsheet","sh_reserid="+SqlCnv(lp_nReserId),"sheet")
 ENDIF
 IF l_lCloseHSheet
	dclose("hsheet")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromBillinstToHist
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHBillins
 l_nSelect = SELECT()
 IF NOT USED("hbillins")
	openfiledirect(.F., "hbillins")
	l_lCloseHBillins = .T.
 ENDIF
 AppendFrom("billinst","bi_reserid="+SqlCnv(lp_nReserId),"hbillins")
 SELECT billinst
 DELETE ALL FOR bi_reserid = lp_nReserId
 IF l_lCloseHBillins
	dclose("hbillins")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToBillinst
LPARAMETERS lp_nReserId
LOCAL l_nSelect, l_lCloseHBillins
 l_nSelect = SELECT()
 IF NOT USED("hbillins")
	openfiledirect(.F., "hbillins")
	l_lCloseHBillins = .T.
 ENDIF
 IF NOT SEEK(lp_nReserId,"billinst","tag1")
	AppendFrom("hbillins","bi_reserid="+SqlCnv(lp_nReserId),"billinst")
 ENDIF
 IF l_lCloseHBillins
	dclose("hbillins")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromResyieldToHist
LPARAMETERS lp_nYoId
LOCAL l_nSelect, l_lCloseHresyild

 l_nSelect = SELECT()
 IF NOT USED("hresyild")
	OpenFileDirect(.F., "hresyild")
	l_lCloseHresyild = .T.
 ENDIF
 AppendFrom("resyield","ry_yoid="+SqlCnv(lp_nYoId),"hresyild")
 SELECT resyield
 DELETE ALL FOR ry_yoid = lp_nYoId
 IF l_lCloseHresyild
	DClose("hresyild")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToResyield
LPARAMETERS lp_nYoId
LOCAL l_nSelect, l_lCloseHresyild

 l_nSelect = SELECT()
 IF NOT USED("hresyild")
	OpenFileDirect(.F., "hresyild")
	l_lCloseHresyild = .T.
 ENDIF
 IF NOT SEEK(lp_nYoId,"resyield","tag2")
	AppendFrom("hresyild","ry_yoid="+SqlCnv(lp_nYoId),"resyield")
 ENDIF
 IF l_lCloseHresyild
	DClose("hresyild")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromYiofferToHist
LPARAMETERS lp_nYoId, lp_nRsId
LOCAL l_nSelect, l_nRecno, l_lCloseHYioffer, l_nYoId

 IF EMPTY(lp_nYoId) AND EMPTY(lp_nRsId)
	RETURN .T.
 ENDIF
 l_nSelect = SELECT()
 IF NOT USED("hyioffer")
	OpenFileDirect(.F., "hyioffer")
	l_lCloseHYioffer = .T.
 ENDIF
 IF EMPTY(lp_nYoId)
	* 1. Send all offers to history, for which is this main reservation and no reservation is linked to this offer
	SELECT yioffer
	SCAN FOR yo_rsid = lp_nRsId AND ;
			dlookup("reservat","rs_rsid <> " + sqlcnv(lp_nRsId) + " AND rs_yoid = " + sqlcnv(yioffer.yo_yoid),"rs_rsid")=0
		l_nRecno = RECNO()
		DO FromYiofferToHist WITH yioffer.yo_yoid
		GO l_nRecno
	ENDSCAN
	
	* 2. Send offer to history, for which this reservation was linkedm and no other reservation is linked to this offer
	l_nYoId = DLookUp("reservat", "rs_rsid = " + SqlCnv(lp_nRsId), "rs_yoid")
	IF l_nYoId > 0
		IF SEEK(l_nYoId, "yioffer", "tag1")
			IF DLookUp("reservat", "rs_rsid = " + SqlCnv(yioffer.yo_rsid), "rs_rsid")=0 AND ;
					dlookup("reservat","rs_rsid <> " + sqlcnv(lp_nRsId) + " AND rs_yoid = " + sqlcnv(l_nYoId), "rs_rsid")=0
				DO FromYiofferToHist WITH l_nYoId
			ENDIF
		ENDIF
	ENDIF
 ELSE
	AppendFrom("yioffer","yo_yoid="+SqlCnv(lp_nYoId),"hyioffer")
	DELETE FOR yo_yoid = lp_nYoId IN yioffer
	DO FromYicondToHist WITH lp_nYoId
	DO FromResyieldToHist WITH lp_nYoId
 ENDIF
 IF l_lCloseHYioffer
	DClose("hyioffer")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToYioffer
LPARAMETERS lp_nYoId
LOCAL l_nSelect, l_lCloseHYioffer

 IF EMPTY(lp_nYoId)
	RETURN .T.
 ENDIF
 l_nSelect = SELECT()
 IF NOT USED("hyioffer")
	OpenFileDirect(.F., "hyioffer")
	l_lCloseHYioffer = .T.
 ENDIF
 IF NOT SEEK(lp_nYoId,"yioffer","tag1")
	AppendFrom("hyioffer","yo_yoid="+SqlCnv(lp_nYoId),"yioffer")
 ENDIF
 IF l_lCloseHYioffer
	DClose("hyioffer")
 ENDIF
 DO FromHistToYicond WITH lp_nYoId
 DO FromHistToResyield WITH lp_nYoId
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromYicondToHist
LPARAMETERS lp_nYoId
LOCAL l_nSelect, l_lCloseHYicond

 l_nSelect = SELECT()
 IF NOT USED("hyicond")
	OpenFileDirect(.F., "hyicond")
	l_lCloseHYicond = .T.
 ENDIF
 AppendFrom("yicond","yc_yoid="+SqlCnv(lp_nYoId),"hyicond")
 SELECT yicond
 DELETE ALL FOR yc_yoid = lp_nYoId
 IF l_lCloseHYicond
	DClose("hyicond")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE FromHistToYicond
LPARAMETERS lp_nYoId
LOCAL l_nSelect, l_lCloseHYicond

 l_nSelect = SELECT()
 IF NOT USED("hyicond")
	OpenFileDirect(.F., "hyicond")
	l_lCloseHYicond = .T.
 ENDIF
 IF NOT SEEK(lp_nYoId,"yicond","tag2")
	AppendFrom("hyicond","yc_yoid="+SqlCnv(lp_nYoId),"yicond")
 ENDIF
 IF l_lCloseHYicond
	DClose("hyicond")
 ENDIF
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE ResetReservation
LPARAMETERS pl_oReservat, pl_nReserId
LOCAL i, l_nNights, l_lUsed, l_cPa_UserRes, l_cPa_UserReo, l_cRsUsrRes

pl_oReservat.rs_reserid = pl_nReserId
pl_oReservat.rs_rsid = NextId("RESUNQID")
pl_oReservat.rs_in = ""
pl_oReservat.rs_out = ""
pl_oReservat.rs_posstat = ""
pl_oReservat.rs_ratein = .F.
pl_oReservat.rs_rateout = .F.
pl_oReservat.rs_codate = {}
pl_oReservat.rs_cidate = {}
pl_oReservat.rs_cotime = ""
pl_oReservat.rs_citime = ""
pl_oReservat.rs_ratedat = {}
pl_oReservat.rs_rfixdat = {}
pl_oReservat.rs_cxldate = {}
pl_oReservat.rs_cxlstat = ""
pl_oReservat.rs_depdat1 = {}
pl_oReservat.rs_depdat2 = {}
pl_oReservat.rs_deppdat = {}
pl_oReservat.rs_depamt1 = 0
pl_oReservat.rs_depamt2 = 0
pl_oReservat.rs_deppaid = 0
pl_oReservat.rs_yoid = 0
pl_oReservat.rs_share = ""
pl_oReservat.rs_recur = ""
pl_oReservat.rs_interns = ""
pl_oReservat.rs_orgarrd = {}
pl_oReservat.rs_odepdat = {}
pl_oReservat.rs_ratexch = 0

* Dont copy user fields, which are not used, or are marked as readonly.
FOR i = 1 TO 10
     l_cPa_UserRes = "_screen.oglobal.oparam.pa_usrres" + IIF(i = 10,"0",TRANSFORM(i))
     l_lUsed = .F.
     IF NOT EMPTY(EVALUATE(l_cPa_UserRes))
          l_cPa_UserReo = "_screen.oglobal.oparam2.pa_usrero" + IIF(i = 10,"0",TRANSFORM(i))
          IF NOT EVALUATE(l_cPa_UserReo)
               l_lUsed = .T.
          ENDIF
     ENDIF
     IF NOT l_lUsed
          l_cRsUsrRes = "pl_oReservat.rs_usrres" + IIF(i = 10,"0",TRANSFORM(i))
          &l_cRsUsrRes = ""
     ENDIF
ENDFOR

l_nNights = pl_oReservat.rs_depdate - pl_oReservat.rs_arrdate
pl_oReservat.rs_arrdate = MAX(pl_oReservat.rs_arrdate, SysDate())
pl_oReservat.rs_depdate = pl_oReservat.rs_arrdate + l_nNights
IF INLIST(pl_oReservat.rs_status,"IN","OUT","CXL","NS")
	pl_oReservat.rs_status = _screen.oglobal.oparam.pa_defstat
ENDIF
pl_oReservat.rs_created = SysDate()
pl_oReservat.rs_updated = SysDate()
pl_oReservat.rs_userid = g_userid
pl_oReservat.rs_creatus = g_userid
ENDPROC
*
PROCEDURE ResDataCopy
LPARAMETERS pl_oReservat, pl_cChangeText, pl_nReserId, pl_lCopyCharges, pl_lCopyNoAddr, pl_lCopyDocuments
LOCAL l_nRecNo, l_nSelect, l_nNights, l_dOldArrdate, l_nOldReserid, l_nOldRsid, l_lAskForCopy, l_oResrooms, l_cOrder, i, ;
		l_cPa_UserRes, l_lUsed, l_cPa_UserReo, l_cRsUsrRes

l_nSelect = SELECT()
l_lAskForCopy = (PCOUNT() < 4)
l_nOldReserid = pl_oReservat.rs_reserid
l_nOldRsid = pl_oReservat.rs_rsid
ResetReservation(pl_oReservat, pl_nReserId)
pl_oReservat.rs_changes = RsHistry("", "COPY", pl_cChangeText)
IF NOT pl_lCopyNoAddr
	* IF pl_lCopyNoAddr = .T.
	* 	Use value from original reservation
	* ELSE
	* 	Set new value, as for new resrvation
	* ENDIF
	pl_oReservat.rs_noaddr = param2.pa_noaddr AND pl_oReservat.rs_addrid = pl_oReservat.rs_compid
ENDIF

= SEEK(STR(l_nOldReserid,12,3),"resrooms","tag2")
l_dOldArrdate = resrooms.ri_date
IF NOT EMPTY(MLINE(pl_oReservat.rs_billins,1)) AND SEEK(l_nOldReserid,'billinst','tag1')
	SELECT billinst
	SCAN FOR bi_reserid = l_nOldReserid
		SCATTER MEMO MEMVAR
		l_nRecNo = RECNO()
		m.bi_reserid = pl_oReservat.rs_reserid
		INSERT INTO billinst FROM MEMVAR
		GO l_nRecNo
	ENDSCAN
ENDIF
IF SEEK(l_nOldRsid,'pswindow','Tag2')
	SELECT pswindow
	SCAN FOR pw_rsid = l_nOldRsid AND (NOT EMPTY(pw_billsty) OR NOT EMPTY(pw_udbdate) OR NOT EMPTY(pw_note) OR NOT EMPTY(pw_blamid) OR NOT EMPTY(pw_addrid))
		SCATTER MEMO MEMVAR
		l_nRecNo = RECNO()
		m.pw_rsid = pl_oReservat.rs_rsid
		m.pw_pwid = NextId("PSWINDOW")
		m.pw_copy = 0
		m.pw_bmsto1w = .F.
		INSERT INTO pswindow FROM MEMVAR
		GO l_nRecNo
	ENDSCAN
ENDIF
IF SEEK(l_nOldReserid,'sheet','tag1')
	IF pl_lCopyCharges OR (l_lAskForCopy AND yesno(GetLangText("RESERVAT","TA_COPYSHEET")+"?"))
		SELECT sheet
		SCAN FOR sh_reserid = l_nOldReserid
			SCATTER MEMO MEMVAR
			m.sh_reserid = pl_oReservat.rs_reserid
			l_nRecNo = RECNO()
			INSERT INTO sheet FROM MEMVAR
			GO l_nRecNo
		ENDSCAN
	ENDIF
ENDIF
IF SEEK(l_nOldReserid,'banquet','tag1')
	IF pl_lCopyCharges OR (l_lAskForCopy AND yesno(GetLangText("RESERVAT","TA_COPYBANQUET")))
		SELECT BANQUET
		SCAN FOR bq_reserid = l_nOldReserid
			SCATTER MEMO MEMVAR
			l_nRecNo = RECNO()
			m.bq_reserid = pl_oReservat.rs_reserid
			m.bq_date = m.bq_date + (pl_oReservat.rs_arrdate - l_dOldArrdate)
			m.bq_bqid = NextId("BANQUET")
			INSERT INTO BANQUET FROM MEMVAR
			GO l_nRecNo
		ENDSCAN
	ENDIF
ENDIF
IF SEEK(l_nOldReserid,'resfix','tag1')
	IF pl_lCopyCharges OR (l_lAskForCopy AND yesno(GetLangText("RESERVAT","TA_COPYFIX")))
		SELECT resfix
		SCAN FOR rf_reserid = l_nOldReserid
			SCATTER MEMO MEMVAR
			l_nRecNo = RECNO()
			m.rf_reserid = pl_oReservat.rs_reserid
			m.rf_rfid = NextId("RESFIX")
			INSERT INTO resfix FROM MEMVAR
			GO l_nRecNo
		ENDSCAN
	ENDIF
ENDIF
IF SEEK(l_nOldReserid,'document','tag2')
	IF pl_lCopyDocuments
		SELECT document
		SCAN FOR dc_reserid = l_nOldReserid
			SCATTER MEMO MEMVAR
			l_nRecNo = RECNO()
			m.dc_reserid = pl_oReservat.rs_reserid
			INSERT INTO document FROM MEMVAR
			GO l_nRecNo
		ENDSCAN
	ENDIF
ENDIF
IF pl_oReservat.rs_noaddr AND SEEK(l_nOldReserid,'resaddr','tag2')
	SELECT resaddr
	SCAN FOR rg_reserid = l_nOldReserid
		SCATTER MEMO MEMVAR
		l_nRecNo = RECNO()
		m.rg_reserid = pl_oReservat.rs_reserid
		m.rg_rgid = nextid("RESADDR")
		INSERT INTO resaddr FROM MEMVAR
		GO l_nRecNo
	ENDSCAN
ENDIF
IF SEEK(STR(l_nOldReserid,12,3) + "OR",'resrate','Tag5')
	IF pl_lCopyCharges OR (l_lAskForCopy AND YesNo(GetLangText("RESERVAT","TA_COPYRATEPERIODS")))
		SELECT resrate
		SCAN FOR STR(rr_reserid,12,3)+LEFT(rr_status,2)+DTOS(rr_date) = STR(l_nOldReserid,12,3) + "OR"
			SCATTER MEMO MEMVAR
			l_nRecNo = RECNO()
			m.rr_reserid = pl_oReservat.rs_reserid
			m.rr_date = m.rr_date + (pl_oReservat.rs_arrdate - l_dOldArrdate)
			m.rr_rrid = NextId("RESRATE")
			INSERT INTO resrate FROM MEMVAR
			GO l_nRecNo
		ENDSCAN
	ENDIF
ENDIF
IF SEEK(l_nOldRsid,'resrart','Tag3')
	IF pl_lCopyCharges OR (l_lAskForCopy AND YesNo(GetLangText("RESERVAT","TA_COPYRATEARTI")))
		SELECT resrart
		SCAN FOR ra_rsid = l_nOldRsid
			SCATTER MEMO MEMVAR
			l_nRecNo = RECNO()
			m.ra_rsid = pl_oReservat.rs_rsid
			m.ra_raid = NextId("RESRATE")
			INSERT INTO resrart FROM MEMVAR
			GO l_nRecNo
		ENDSCAN
	ENDIF
ENDIF
SELECT resrooms
SCAN FOR STR(ri_reserid,12,3)+DTOS(ri_date) = STR(l_nOldReserid,12,3)+DTOS(l_dOldArrdate)
	SCATTER MEMO MEMVAR
	l_nRecNo = RECNO()
	m.ri_reserid = pl_oReservat.rs_reserid
	m.ri_date = m.ri_date + (pl_oReservat.rs_arrdate - l_dOldArrdate)
	IF m.ri_date = pl_oReservat.rs_arrdate
		m.ri_roomtyp = pl_oReservat.rs_roomtyp
		m.ri_roomnum = pl_oReservat.rs_roomnum
	ENDIF
	m.ri_rroomid = NextId("RESROOMS")
	m.ri_shareid = 0
	INSERT INTO resrooms FROM MEMVAR
	GO l_nRecNo
ENDSCAN
IF SEEK(l_nOldRsid,'resfeat','Tag2')
	SELECT resfeat
	SCAN FOR fr_rsid = l_nOldRsid
		SCATTER MEMO MEMVAR
		l_nRecNo = RECNO()
		m.fr_rsid = pl_oReservat.rs_rsid
		m.fr_frid = NextId("RESFEAT")
		INSERT INTO resfeat FROM MEMVAR
		GO l_nRecNo
	ENDSCAN
ENDIF

= SEEK(STR(pl_oReservat.rs_reserid,12,3)+DTOS(pl_oReservat.rs_arrdate),"resrooms","tag2")
pl_oReservat.rs_roomtyp = resrooms.ri_roomtyp
pl_oReservat.rs_roomnum = resrooms.ri_roomnum

SELECT(l_nSelect)

ENDPROC
*
PROCEDURE ResGroupInfo
LPARAMETERS lp_cGroupIdAlias, lp_cInfoAlias, lp_aInfoRoomTypes
 LOCAL l_nArea, l_nRecNo, l_dTotal, l_nGroupId, l_dDate, l_nCount
 LOCAL l_cFieldRoom, l_cFieldPers, l_nRooms, l_nPersons, l_nColumnOrder
 EXTERNAL ARRAY lp_aInfoRoomTypes
 lp_aInfoRoomTypes(1) = ""
 l_nArea = SELECT()
 l_nRecNo = RECNO("reservat")
 CREATE CURSOR &lp_cInfoAlias ;
		(gi_date D, gi_day C(10), gi_rtotal I, gi_ptotal I)
 l_dTotal = {^3000-1-1}
 INSERT INTO &lp_cInfoAlias (gi_date, gi_day) ;
		VALUES (l_dTotal, ;
		SUBSTR(GetLangText("RESERVAT","TXT_TOTAL"),1,10))
 SELECT(lp_cGroupIdAlias)
 SCAN
	l_nGroupId = gr_groupid
	SELECT reservat
	SCAN FOR rs_groupid = l_nGroupId AND ;
			NOT INLIST(rs_status, "CXL", "NS")
		l_nRooms = rs_rooms
		l_nPersons = rs_rooms * (rs_adults + ;
				rs_childs + rs_childs2 + rs_childs3)
		l_nColumnOrder = ASCAN(lp_aInfoRoomTypes,rs_roomtyp)
		IF l_nColumnOrder == 0
			l_nCount = ALEN(lp_aInfoRoomTypes,1)
			IF l_nCount = 1 AND EMPTY(lp_aInfoRoomTypes(1))
				lp_aInfoRoomTypes(1) = rs_roomtyp
			ELSE
				DIMENSION lp_aInfoRoomTypes(l_nCount+1)
				lp_aInfoRoomTypes(l_nCount+1) = rs_roomtyp
			ENDIF
			l_cFieldRoom = "gi_r" + ALLTRIM(STR(ALEN(lp_aInfoRoomTypes,1)))
			l_cFieldPers = "gi_p" + ALLTRIM(STR(ALEN(lp_aInfoRoomTypes,1)))
			ALTER TABLE &lp_cInfoAlias ;
					ADD &l_cFieldRoom I ;
					ADD &l_cFieldPers I
			SELECT reservat
		ELSE
			l_cFieldRoom = "gi_r" + ALLTRIM(STR(l_nColumnOrder))
			l_cFieldPers = "gi_p" + ALLTRIM(STR(l_nColumnOrder))
		ENDIF
		FOR l_nCount = 0 TO rs_depdate-rs_arrdate-1
			SELECT(lp_cInfoAlias)
			LOCATE FOR gi_date = reservat.rs_arrdate+l_nCount
			IF NOT FOUND(lp_cInfoAlias)
				APPEND BLANK
				REPLACE gi_date WITH reservat.rs_arrdate+l_nCount, ;
						gi_day WITH DTOC(reservat.rs_arrdate+l_nCount)
			ENDIF
				REPLACE &l_cFieldRoom WITH &l_cFieldRoom + l_nRooms, ;
					&l_cFieldPers WITH &l_cFieldPers + l_nPersons
				IF DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(reservat.rs_roomtyp), "rt_group") <> 3
					* Calculate only non dummys to total per day
					REPLACE gi_rtotal WITH gi_rtotal + l_nRooms, ;
							gi_ptotal WITH gi_ptotal + l_nPersons
				ENDIF
			LOCATE FOR gi_date = l_dTotal
			IF FOUND(lp_cInfoAlias)
				REPLACE &l_cFieldRoom WITH &l_cFieldRoom + l_nRooms, ;
						&l_cFieldPers WITH &l_cFieldPers + l_nPersons
				IF DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(reservat.rs_roomtyp), "rt_group") <> 3
					* Calculate only non dummys to total
					REPLACE gi_rtotal WITH gi_rtotal + l_nRooms, ;
							gi_ptotal with gi_ptotal + l_nPersons
				ENDIF
			ENDIF
			SELECT reservat
		ENDFOR
	ENDSCAN
	SELECT(lp_cGroupIdAlias)
 ENDSCAN
 SELECT(lp_cInfoAlias)
 INDEX ON gi_date TAG tagDate
 GO l_nRecNo IN reservat
 SELECT(l_nArea)
 RETURN .T.
ENDPROC
*
PROCEDURE GrPayMasterBlank
LPARAMETERS lp_nGroupId, lp_nPMResId
 LOCAL l_nRecNo
 l_nRecNo = RECNO("groupres")
 IF NOT EMPTY(lp_nGroupId) AND SEEK(lp_nGroupId,"groupres","tag1") ;
		AND groupres.gr_pmresid == lp_nPMResId
	REPLACE gr_pmresid WITH 0 IN groupres
 ENDIF
 GO l_nRecNo IN groupres
ENDPROC
*
PROCEDURE GetReserPrices
LPARAMETERS pl_cResAlias, pl_cText, pl_nReserid, pl_dArrdate
LOCAL l_nSelect, l_lPackage, l_lResfix, l_cOrder, l_cGetRsg, l_cSql
pl_cText = ""
l_nSelect = SELECT()

IF Odbc()
     l_cGetRsg = SqlCursor(Str2Msg("SELECT * FROM GetRsg(%s1,%s2)","%s",SqlCnv(pl_nReserid,.T.),SqlCnv(pl_dArrdate,.T.)))
     IF USED(l_cGetRsg)
     	pl_cText = &l_cGetRsg..getrsg
     ENDIF
ELSE
	IF SEEK(STR(&pl_cResAlias..rs_reserid,12,3)+"OR","resrateRSG","Tag5")
		pl_cText = "I"
	ENDIF
	SELECT resrateRSG
	LOCATE FOR STR(rr_reserid,12,3)+LEFT(rr_status,2)+DTOS(rr_date) = STR(&pl_cResAlias..rs_reserid,12,3)+"OK" AND ;
		SEEK(rr_ratecod, "ratecode", "tag1") AND SUBSTR(ratecode.rc_weekend, DOW(rr_date,2), 1) = '1' AND ;
		SUBSTR(ratecode.rc_closarr, DOW(&pl_cResAlias..rs_arrdate,2), 1) = ' '
	IF FOUND()
		pl_cText = pl_cText + "S"
	ENDIF
	SELECT resroomsRSG
	l_cOrder = ORDER()
	SET ORDER TO
	LOCATE FOR (STR(ri_reserid,12,3)+DTOS(ri_date) = STR(&pl_cResAlias..rs_reserid,12,3)) AND (ri_date > &pl_cResAlias..rs_arrdate)
	IF FOUND()
		pl_cText = pl_cText + "U"
	ENDIF
	SET ORDER TO l_cOrder
	SELECT resfixRSG
	SCAN FOR resfixRSG.rf_reserid = &pl_cResAlias..rs_reserid AND NOT(l_lPackage AND l_lResfix)
		IF NOT l_lPackage AND resfixRSG.rf_package
			l_lPackage = .T.
			pl_cText = pl_cText + "P"
		ENDIF
		IF NOT l_lResfix AND NOT resfixRSG.rf_package
			l_lResfix = .T.
			pl_cText = pl_cText + "F"
		ENDIF
	ENDSCAN
	IF SEEK(&pl_cResAlias..rs_rsid,"resrartRSG","Tag3")
		pl_cText = pl_cText + "B"
	ENDIF
	IF _screen.TP AND INLIST(&pl_cResAlias..rs_status, 'DEF', '6PM', 'IN')
		pl_cText = pl_cText + CHRTRAN(ALLTRIM(&pl_cResAlias..rs_extflag), CHRTRAN(ALLTRIM(&pl_cResAlias..rs_extflag), "tT", ""), "")
	ENDIF
	IF param2.pa_wellifc AND NOT EMPTY(param2.pa_welldir) AND INLIST(&pl_cResAlias..rs_status, 'DEF', '6PM', 'ASG', 'IN')
		pl_cText = pl_cText + WOGetRSG(&pl_cResAlias..rs_rsid, CHRTRAN(ALLTRIM(&pl_cResAlias..rs_extflag), CHRTRAN(ALLTRIM(&pl_cResAlias..rs_extflag), "wW", ""), ""))
	ENDIF
ENDIF

SELECT (l_nSelect)
RETURN pl_cText
ENDPROC
*
FUNCTION WOGetRSG
LPARAMETERS pnRsID, pcRsg
LOCAL l_cSql, l_cRsg, l_curIndicators

IF EMPTY(pcRsg)
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2+8
	SELECT DISTINCT 'w' AS rsg FROM Ressplit
		LEFT JOIN Resrart rra ON rra.ra_rsid = rl_rsid AND rra.ra_raid = rl_raid AND rra.ra_ratecod = rl_ratecod
		LEFT JOIN Ratearti ra ON ra.ra_raid = rl_raid AND ra.ra_ratecod = rl_ratecod
		WHERE rl_rsid = <<SqlCnv(pnRsID,.T.)>> AND NVL(NVL(rra.ra_wservid, ra.ra_wservid), 0) <> 0
	ENDTEXT
	l_curIndicators = SqlCursor(l_cSql)
	IF USED(l_curIndicators) AND RECCOUNT(l_curIndicators) > 0
		SELECT &l_curIndicators
		SCAN
			pcRsg = pcRsg + rsg
		ENDSCAN
	ENDIF
	DClose(l_curIndicators)
ENDIF

RETURN pcRsg
ENDFUNC
*
PROCEDURE GetDummyBill
* Send Yes, when advanced bill is issued for whole group.
* For now, we only check rs_ratedat for paymaster.
LPARAMETERS lp_nRsId
LOCAL lcSql
LOCAL ARRAY laRatedat(1)

STORE .T. TO laRatedat

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT r2.rs_ratedat FROM reservat r1
	INNER JOIN groupres ON r1.rs_groupid = gr_groupid
	INNER JOIN reservat r2 ON gr_pmresid = r2.rs_reserid
	WHERE r1.rs_rsid = <<SqlCnv(lp_nRsId)>>
ENDTEXT
SqlCursor(lcSql,,,,,,@laRatedat)

RETURN NOT EMPTY(laRatedat(1))
ENDPROC
*
PROCEDURE Sharing_status
LPARAMETERS lp_cStatus, lp_cStatus2
LOCAL l_cStatus

l_cStatus = "IN"
IF INLIST(l_cStatus, ALLTRIM(lp_cStatus), ALLTRIM(lp_cStatus2))
	lp_cStatus = l_cStatus
	RETURN
ENDIF
l_cStatus = "DEF"
IF INLIST(l_cStatus, ALLTRIM(lp_cStatus), ALLTRIM(lp_cStatus2))
	lp_cStatus = l_cStatus
	RETURN
ENDIF
l_cStatus = "6PM"
IF INLIST(l_cStatus, ALLTRIM(lp_cStatus), ALLTRIM(lp_cStatus2))
	lp_cStatus = l_cStatus
	RETURN
ENDIF
l_cStatus = "ASG"
IF INLIST(l_cStatus, ALLTRIM(lp_cStatus), ALLTRIM(lp_cStatus2))
	lp_cStatus = l_cStatus
	RETURN
ENDIF
l_cStatus = "OPT"
IF INLIST(l_cStatus, ALLTRIM(lp_cStatus), ALLTRIM(lp_cStatus2))
	lp_cStatus = l_cStatus
	RETURN
ENDIF
l_cStatus = "LST"
IF INLIST(l_cStatus, ALLTRIM(lp_cStatus), ALLTRIM(lp_cStatus2))
	lp_cStatus = l_cStatus
	RETURN
ENDIF
l_cStatus = "TEN"
IF INLIST(l_cStatus, ALLTRIM(lp_cStatus), ALLTRIM(lp_cStatus2))
	lp_cStatus = l_cStatus
	RETURN
ENDIF
IF (ALLTRIM(lp_cStatus) = "OUT") AND (ALLTRIM(lp_cStatus2) = "OUT")
	lp_cStatus = "OUT"
	RETURN
ENDIF
lp_cStatus = "DEF"
ENDPROC
*
PROCEDURE CreateCurBckShareResRooms
LPARAMETERS lp_nReserid, lp_lRecreate
LOCAL l_nArea, l_cOrder

IF lp_lRecreate
	DClose("curBckShareResRooms")
ENDIF
IF NOT USED("curBckShareResRooms") OR RECCOUNT("curBckShareResRooms") = 0 OR NOT DLocate("curBckShareResRooms", "ri_reserid = " + SqlCnv(lp_nReserid))
	l_nArea = SELECT()
	l_cOrder = ORDER("resrooms")
	SET ORDER TO "" IN resrooms

	SELECT * FROM resrooms WITH (BUFFERING = .T.) WHERE ri_reserid = lp_nReserid AND NOT EMPTY(ri_shareid) INTO CURSOR curBckShareResRooms

	SET ORDER TO l_cOrder IN resrooms
	SELECT (l_nArea)
ENDIF
ENDPROC
*
PROCEDURE SaveIntoCurChangeRes
LPARAMETERS lp_nReserid
LOCAL l_nArea

IF NOT USED("curChangeRes")
	l_nArea = SELECT()
	SELECT rs_reserid AS cr_reserid FROM reservat WHERE 0=1 INTO CURSOR curChangeRes READWRITE
	INDEX ON cr_reserid TAG tag1
	SELECT (l_nArea)
ENDIF
IF NOT SEEK(lp_nReserid,"curChangeRes","tag1")
	INSERT INTO curChangeRes (cr_reserid) VALUES (lp_nReserid)
ENDIF
ENDPROC
*
PROCEDURE CheckRoomNum
LPARAMETERS lp_nMode, cResAlias, lp_lMessage, lp_lImportConfReser
*	Parameters :
*	cResAlias		-	current reservat alias.
*	lp_lMessage		-	if .T. then display messages.
*
*	lp_nMode :	-	checkmode for share changing.
*	0	-	no room sharing.
*	1	-	adding a room sharing.
*	2	-	changing a room sharing.
*	3	-	removing reservation from room sharing.
*	-1	-	roomnum required.
*	-2	-	not proceed a reservation.
LOCAL l_lCanShare
IF EMPTY(lp_nMode)
	lp_nMode = 0
ENDIF
IF EMPTY(lp_nMode) AND RoomNumRequired(cResAlias, lp_lMessage)
	lp_nMode = -1
ENDIF
IF lp_nMode >= 0
	CheckShare(cResAlias, @lp_nMode, lp_lMessage, lp_lImportConfReser)
ENDIF
ENDPROC
*
FUNCTION RoomnumRequired
LPARAMETERS cResAlias, lp_lMessage
LOCAL l_lRequired, l_nArea, l_nRecnoRt, l_nRecnoRr, l_lRoomTypeClose, l_lResRoomsClose

IF &cResAlias..rs_rooms = 1
	l_nArea = SELECT()
	IF NOT USED("roomtype")
		openfiledirect(.F., "roomtype")
		l_lRoomTypeClose = .T.
	ENDIF
	IF NOT USED("resrooms")
		openfiledirect(.F., "resrooms")
		l_lResRoomsClose = .T.
	ENDIF
	l_nRecnoRt = RECNO("roomtype")
	l_nRecnoRr = RECNO("resrooms")
	SELECT resrooms
	SCAN FOR (ri_reserid = &cResAlias..rs_reserid) AND EMPTY(ri_roomnum)
		IF &cResAlias..rs_status = "IN"
			IF lp_lMessage
				Alert(GetLangText("RESERVAT","TXT_YOU_ENTERED_INVALID_DATA"))
			ENDIF
			l_lRequired = .T.
			EXIT
		ENDIF
		IF SEEK(resrooms.ri_roomtyp,"roomtype","tag1")
			IF (roomtype.rt_group = 2) AND NOT param.pa_bqnropt
				IF lp_lMessage
					Alert(GetLangText("RESERVAT","TXT_YOU_ENTERED_INVALID_DATA"))
				ENDIF
				l_lRequired = .T.
				EXIT
			ENDIF
			IF roomtype.rt_roomreq
				IF lp_lMessage
					Alert(GetLangText("RESERVAT","TXT_ROOMNUMMBERISREQ"))
				ENDIF
				l_lRequired = .T.
				EXIT
			ENDIF
		ENDIF
	ENDSCAN
	GO l_nRecnoRr IN resrooms
	GO l_nRecnoRt IN roomtype
	IF l_lRoomTypeClose
		dclose("roomtype")
	ENDIF
	IF l_lResRoomsClose
		dclose("resrooms")
	ENDIF
	SELECT (l_nArea)
ENDIF
RETURN l_lRequired
ENDFUNC
*
PROCEDURE CheckShare
LPARAMETERS lp_cResAlias, lp_nMode, lp_lMessage, lp_lImportConfReser
*	Parameters :
*	lp_cResAlias	-	current reservat alias.
*	lp_lMessage		-	if .T. then display messages
*
*	lp_nMode :	-	checkmode for share changing.
*	0	-	no room sharing.
*	1	-	adding a room sharing.
*	2	-	changing a room sharing.
*	3	-	removing reservation from room sharing.
*	-2	-	not proceed a reservation.
LOCAL l_nArea, l_nRecNo, l_cFilter, l_lShare

IF NOT _screen.oGlobal.oParam.pa_rshare AND lp_nMode = 3
	RETURN
ENDIF

l_nReserid = &lp_cResAlias..rs_reserid

* Put virtual room number to sharing.sd_roomnum, resrooms.ri_roomnum = VIRTUAL_ROOMNUM for pending sharings (sharings without assigned room).
PutVirtualRoomNumber(l_nReserid)

IF lp_nMode = 3
	RETURN
ENDIF

l_nArea = SELECT()

RemoveAliasFilter(lp_cResAlias, @l_nRecNo, @l_cFilter)

* Collect all old affected room intervals in cursor curResRooms.
CreateCurResrooms(.T.)				&& lp_lRecreate = .T.

* Get old shared room intervals for updating these intervals in ChangeShare().
CreateCurBckShareResRooms(l_nReserid)	&& lp_lRecreate = .F.

* Ask if want to apply room change to all sharers in sharing.
AskForApplyToAllSharers(lp_cResAlias)

* Here is added physical room to all VIRTUAL_ROOMNUM sharers.
SetRoomToPendingSharing(lp_cResAlias)

* If want to be applied changes to all sharers than change room to all of them.
ChangeRoomToAllSharers(lp_cResAlias)

GO l_nRecNo IN &lp_cResAlias
IF IsRmFree(lp_cResAlias, @l_lShare, lp_lMessage, lp_lImportConfReser)
	lp_nMode = ICASE(l_lShare, 1, _screen.oGlobal.oParam.pa_rshare, 2, 0)
	DClose("tmpResroomsBackup")
ELSE
	IF lp_lMessage
		Alert(GetLangText("RESERVAT","TXT_CANT_GET_ROOM"))
	ENDIF
	lp_nMode = -2
	RestoreFromTmpResroomsBackup()
	RemoveVirtualRoomNumber()
ENDIF

RestoreAliasFilter(lp_cResAlias, l_nRecNo, l_cFilter)

SELECT (l_nArea)
ENDPROC
*
PROCEDURE AskForApplyToAllSharers
LPARAMETERS lp_cResAlias
* Ask if want to apply room change to all sharers in sharing.
* Don't ask for pending sharing interval (sharings without assigned room).
* Ask only if room changed and interval of room is in interval of sharing.
LOCAL l_lQuestion, l_oResrooms

l_lQuestion = .T.

SELECT curBckShareResRooms	&& Saved in CreateCurBckShareResRooms(rs_reserid) for changing reservation.
SCAN
	SCATTER MEMO NAME l_oResrooms
	INSERT INTO curResRooms FROM NAME l_oResrooms
	IF l_lQuestion AND _screen.oGlobal.oParam.pa_rshare AND NOT EMPTY(ri_roomnum) AND ;
			SEEK(curBckShareResRooms.ri_rroomid,"resrooms","tag3") AND ri_roomnum <> resrooms.ri_roomnum AND ;
			SEEK(curBckShareResRooms.ri_shareid,"sharing","tag1") AND sharing.sd_lowdat <= resrooms.ri_todate AND sharing.sd_highdat >= resrooms.ri_date
		IF YesNo(GetLangText("RESERVAT","TXT_APPLY_TO_ALLRESINSHARING"))
			REPLACE ri_shapply WITH .T., ;
					ri_shrate WITH &lp_cResAlias..rs_rate, ;
					ri_shrc WITH &lp_cResAlias..rs_ratecod ;
					IN curResRooms
		ENDIF
		l_lQuestion = .F.
	ENDIF
ENDSCAN

RETURN .T.
ENDPROC
*
PROCEDURE SetRoomToPendingSharing
LPARAMETERS lp_cResAlias
* Here is added physical room to all VIRTUAL_ROOMNUM sharers.
LOCAL l_nRecno, l_nRiRecno, l_nReserid, l_cRoomnum, l_cRoomtype 

l_nRecNo = RECNO(lp_cResAlias)

l_nReserid = &lp_cResAlias..rs_reserid

SELECT resrooms
SCAN FOR ri_reserid = l_nReserid AND NOT EMPTY(ri_shareid) AND ri_roomnum <> VIRTUAL_ROOMNUM AND ;
		SEEK(ri_shareid,"sharing","tag1") AND sharing.sd_roomnum = VIRTUAL_ROOMNUM
	l_cRoomnum = ri_roomnum
	l_cRoomtype = ri_roomtyp
	l_nRiRecno = RECNO()
	SELECT resrmshr
	SCAN FOR sr_shareid = sharing.sd_shareid AND SEEK(sr_rroomid,"resrooms","tag3") AND resrooms.ri_roomnum <> l_cRoomnum
		SaveIntoTmpResroomsBackup(sr_rroomid)
		IF SEEK(resrooms.ri_reserid, lp_cResAlias, "tag1") AND &lp_cResAlias..rs_arrdate = resrooms.ri_date
			REPLACE rs_roomtyp WITH l_cRoomtype, rs_roomnum WITH l_cRoomnum IN &lp_cResAlias
		ENDIF
		DO RiPutRoom IN ProcResrooms WITH resrooms.ri_reserid, resrooms.ri_date, {}, l_cRoomtype, l_cRoomnum, sharing.sd_shareid
		SELECT resrmshr
	ENDSCAN
	SELECT resrooms
	GO l_nRiRecno
ENDSCAN

GO l_nRecNo IN &lp_cResAlias
ENDPROC
*
PROCEDURE ChangeRoomToAllSharers
LPARAMETERS lp_cResAlias
* If want to be applied changes to all sharers than change room to all of them.
LOCAL l_nRecNo, l_cRoomnum, l_cRoomtype

l_nRecNo = RECNO(lp_cResAlias)

SELECT curResRooms
SCAN FOR ri_shapply AND SEEK(ri_shareid,"sharing","tag1") AND SEEK(ri_rroomid,"resrooms","tag3") AND sharing.sd_roomnum <> resrooms.ri_roomnum
	l_cRoomnum = EVL(resrooms.ri_roomnum,VIRTUAL_ROOMNUM)
	l_cRoomtype = resrooms.ri_roomtyp
	SELECT resrmshr
	SCAN FOR sr_shareid = sharing.sd_shareid AND SEEK(sr_rroomid,"resrooms","tag3") AND resrooms.ri_roomnum <> l_cRoomnum
		SaveIntoTmpResroomsBackup(sr_rroomid)
		IF SEEK(resrooms.ri_reserid, lp_cResAlias, "tag1") AND &lp_cResAlias..rs_arrdate = resrooms.ri_date
			REPLACE rs_roomtyp WITH l_cRoomtype, rs_roomnum WITH STRTRAN(l_cRoomnum, VIRTUAL_ROOMNUM) IN &lp_cResAlias
		ENDIF
		DO RiPutRoom IN ProcResrooms WITH resrooms.ri_reserid, resrooms.ri_date, {}, l_cRoomtype, l_cRoomnum, sharing.sd_shareid
		
		ChangeRoomToAllSharers_CheckPrice(lp_cResAlias, curResRooms.ri_shrate, curResRooms.ri_shrc)
		
		SELECT resrmshr
	ENDSCAN
	SELECT curResRooms
ENDSCAN

GO l_nRecNo IN &lp_cResAlias
ENDPROC
*
PROCEDURE ChangeRoomToAllSharers_CheckPrice()
LPARAMETERS lp_cResAlias, lp_nMainSharingRate, lp_cMainSharingRateCode
* Check if price should be changed

LOCAL l_nSelect, l_oOldRes, l_oNewRes, l_lResrateUpdateFromReservat

IF "*" $ &lp_cResAlias..rs_ratecod OR "!" $ &lp_cResAlias..rs_ratecod
	RETURN .T.
ENDIF

IF NOT (&lp_cResAlias..rs_rate <> lp_nMainSharingRate OR ;
		&lp_cResAlias..rs_ratecod <> lp_cMainSharingRateCode)
	RETURN .T.
ENDIF

l_nSelect = SELECT()

SELECT &lp_cResAlias

SCATTER NAME l_oOldRes MEMO

REPLACE rs_rate WITH lp_nMainSharingRate, ;
		rs_ratecod WITH lp_cMainSharingRateCode

SCATTER NAME l_oNewRes MEMO

l_lResrateUpdateFromReservat = .T.
DO RrUpdate IN ProcResRate WITH l_oOldRes, l_oNewRes, .F., {}, {}, l_lResrateUpdateFromReservat

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE SaveIntoTmpResroomsBackup
LPARAMETERS lp_nResroomId
LOCAL l_nArea, l_oResrooms

IF lp_nResroomId = resrooms.ri_rroomid OR SEEK(lp_nResroomId,"resrooms","tag3")
	l_nArea = SELECT()

	IF NOT USED("tmpResroomsBackup")
		SELECT * FROM resrooms WHERE 0=1 INTO CURSOR tmpResroomsBackup READWRITE
		INDEX ON ri_rroomid TAG ri_rroomid
	ENDIF
	IF NOT SEEK(lp_nResroomId,"tmpResroomsBackup","ri_rroomid")
		SELECT resrooms
		SCATTER MEMO NAME l_oResrooms
		INSERT INTO tmpResroomsBackup FROM NAME l_oResrooms
	ENDIF

	SELECT (l_nArea)
ENDIF
ENDPROC
*
PROCEDURE RestoreFromTmpResroomsBackup
IF USED("tmpResroomsBackup")
	SELECT tmpResroomsBackup
	SCAN FOR SEEK(ri_rroomid,"resrooms","tag3")
		REPLACE ri_roomtyp WITH tmpResroomsBackup.ri_roomtyp, ri_roomnum WITH tmpResroomsBackup.ri_roomnum IN resrooms
	ENDSCAN
	DClose("tmpResroomsBackup")
ENDIF
ENDPROC
*
PROCEDURE ChangeShare
LPARAMETERS lp_nMode, lp_cResAlias, lp_nReserid
*	Parameters :
*	lp_nMode		-	checkmode for share changing.
*	lp_cResAlias	-	current reservat alias.
*	lp_nReserid	-	reservation ID for removing from room sharing.
*
*	lp_nMode :
*	0	-	No room sharing.
*	1	-	Adding a room sharing.
*	2	-	Changing a room sharing.
*	3	-	Removing reservation from room sharing.
LOCAL l_nArea, l_nRecNo, l_cFilter, l_lCloseHResroom

IF NOT _screen.oGlobal.oParam.pa_rshare OR NOT INLIST(lp_nMode, 1, 2, 3)
	RETURN
ENDIF

l_nArea = SELECT()

IF NOT USED("hresroom")
	l_lCloseHResroom = OpenFileDirect(,"hresroom")
ENDIF
RemoveAliasFilter(lp_cResAlias, @l_nRecNo, @l_cFilter)

* Collect all affected room intervals in cursor curResRooms.
CollectAffectedResrooms(lp_cResAlias)

* Collect all new and old room sharers in cursor curResRmShr.
CollectResroomSharers(lp_nMode, lp_cResAlias)

* Collect all afected sharings in cursor curCxlSharing for RESET and group all sharers (set curResRmShr.sd_id).
GroupSharersToSharing()

* RESET all collected sharing from cursor curCxlSharing in sharing.dbf, resrmshr.dbf, resrooms.dbf and reservat.dbf.
RemoveSharingRelations(lp_cResAlias)

* Prepare new sharing headers in curSharing and update sharing.dbf and resrmshr.dbf from cursors curSharing and curResRmShr.
UpdateSharingDbf(lp_cResAlias)

CreateCurBckShareResRooms(&lp_cResAlias..rs_reserid, .T.)	&& lp_lRecreate = .T.

RemoveVirtualRoomNumber()

RestoreAliasFilter(lp_cResAlias, l_nRecNo, l_cFilter)

IF l_lCloseHResroom
	DClose("hresroom")
ENDIF

SELECT (l_nArea)
ENDPROC
*
PROCEDURE CreateCurResrooms
LPARAMETERS lp_lRecreate

IF lp_lRecreate
	DClose("curResrooms")
ENDIF
IF NOT USED("curResrooms")
	SELECT *, 0=1 AS ri_shapply, 0000000000.00 AS ri_shrate, SPACE(10) AS ri_shrc FROM resrooms WHERE 0=1 INTO CURSOR curResRooms READWRITE
	INDEX ON STR(ri_rroomid,8)+ri_roomnum TAG ri_rroomid
	INDEX ON ri_roomnum+DTOS(ri_date) TAG ri_roomnum
ENDIF
ENDPROC
*
PROCEDURE CollectAffectedResrooms
LPARAMETERS lp_cResAlias
* Collect all affected room intervals in cursor curResRooms.
LOCAL l_oResrooms, l_nReserid, l_cRoomnum, l_dHighdate

l_nReserid = &lp_cResAlias..rs_reserid

CreateCurResrooms()		&& lp_lRecreate = .F.	Structure like resrooms + ri_shapply (logical)

* Collect all room intervals for current reservation
SELECT resrooms
SCAN FOR ri_reserid = l_nReserid AND NOT EMPTY(ri_roomnum) AND NOT SEEK(STR(ri_rroomid,8)+ri_roomnum,"curResRooms","ri_rroomid")
	SCATTER MEMO NAME l_oResrooms
	INSERT INTO curResRooms FROM NAME l_oResrooms
ENDSCAN

* Save old sharing ID if room interval not in new sharing.
IF DLocate("curResRooms", "ri_shapply") AND NOT EMPTY(curResRooms.ri_shareid)
	SELECT curResRooms
	SCATTER MEMO NAME l_oResrooms
	REPLACE ri_shareid WITH l_oResrooms.ri_shareid FOR EMPTY(ri_shareid) AND ri_rroomid = l_oResrooms.ri_rroomid
ENDIF

* Remove invalid room intervals from curResRooms and merge same room intervals.
SELECT curResRooms
SET ORDER TO ri_roomnum
l_cRoomnum = ""
SCAN
	IF EMPTY(ri_roomnum) OR DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(curResRooms.ri_roomtyp), "rt_group") <> 1
		AddToCurCxlSharing(ri_shareid)
		DELETE
	ELSE
		IF ri_roomnum == l_cRoomnum
			* Compare resroom interval with same room
			IF ri_date <= l_dHighdate
				SCATTER MEMO NAME l_oResrooms
				AddToCurCxlSharing(ri_shareid)
				DELETE
				SKIP -1
				REPLACE ri_todate WITH MAX(ri_todate, l_oResrooms.ri_todate)
				IF EMPTY(ri_shareid) AND NOT EMPTY(l_oResrooms.ri_shareid)
					REPLACE ri_shareid WITH l_oResrooms.ri_shareid
				ENDIF
			ENDIF
		ELSE
			l_cRoomnum = ri_roomnum
		ENDIF
		l_dHighdate = ri_todate
	ENDIF
ENDSCAN
ENDPROC
*
PROCEDURE CreateCurResRmShr
SELECT CAST(0 AS Int) AS sd_id, * FROM resrmshr, sharing WHERE 0=1 INTO CURSOR curResRmShr READWRITE
INDEX ON sd_roomnum+DTOS(sd_lowdat) TAG sd_roomnum
INDEX ON sd_id TAG sd_id
INDEX ON sr_rroomid TAG sr_rroomid
ENDPROC
*
PROCEDURE CollectResroomSharers
LPARAMETERS lp_nMode, lp_cResAlias
* Collect all new and old room sharers in cursor curResRmShr.
LOCAL l_nRecNo, l_nReserid, l_cStatus

l_nRecNo = RECNO(lp_cResAlias)

l_nReserid = &lp_cResAlias..rs_reserid

CreateCurResRmShr()		&& Structure from resrmshr, sharing + sd_id (integer)
SELECT curResRooms
SCAN
	* Collect all occupation of room for specified room interval.
	* There could be more than one occupation of room by other reservations.
	SELECT ri_rroomid, ri_shareid, ri_roomnum, ri_date, ri_todate, rs_status FROM resrooms WITH (BUFFERING = .T.) ;
		INNER JOIN reservat WITH (BUFFERING = .T.) ON rs_reserid = ri_reserid ;
		WHERE ri_roomnum = curResRooms.ri_roomnum AND ri_date <= curResRooms.ri_todate AND ri_todate >= curResRooms.ri_date AND ;
			NOT INLIST(rs_status,"NS","CXL","OUT") ;
		ORDER BY 1 ;
		INTO CURSOR tmpResRmShr READWRITE
	SELECT tmpResRmShr
	SCAN
		IF NOT SEEK(tmpResRmShr.ri_rroomid,"curResRmShr","sr_rroomid")
			IF lp_nMode = 3 AND SEEK(tmpResRmShr.ri_rroomid,"resrooms","tag3") AND resrooms.ri_reserid = l_nReserid
				* If lp_nMode = 3 (removing from sharing mode) then don't share current reservation parts (room intervals) with each other.
			ELSE
				* Insert all room sharers in curResRmShr.
				INSERT INTO curResRmShr (sr_rroomid, sr_shareid, sd_roomnum, sd_lowdat, sd_highdat, sd_status, sd_history) ;
					VALUES (tmpResRmShr.ri_rroomid, tmpResRmShr.ri_shareid, tmpResRmShr.ri_roomnum, tmpResRmShr.ri_date, tmpResRmShr.ri_todate, tmpResRmShr.rs_status, .F.)
			ENDIF
		ENDIF
		IF NOT EMPTY(ri_shareid)
			* For existing SHARING insert all old room sharers in curResRmShr.
			SELECT resrmshr
			SCAN FOR sr_shareid = tmpResRmShr.ri_shareid AND NOT SEEK(sr_rroomid,"curResRmShr","sr_rroomid") &&AND NOT DLookUp("tmpResRmShr", "ri_rroomid = " + SqlCnv(sr_rroomid),"FOUND()")
				IF SEEK(resrmshr.sr_rroomid,"resrooms","tag3")
					IF lp_nMode = 3 AND resrooms.ri_reserid = l_nReserid
						* If lp_nMode = 3 (removing from sharing mode) then don't share current reservation parts (room intervals) with each other.
					ELSE
						l_cStatus = IIF(SEEK(resrooms.ri_reserid,lp_cResAlias,"tag1"), &lp_cResAlias..rs_status, rs_status)
						INSERT INTO curResRmShr (sr_rroomid, sr_shareid, sd_roomnum, sd_lowdat, sd_highdat, sd_status, sd_history) ;
							VALUES (resrooms.ri_rroomid, resrooms.ri_shareid, resrooms.ri_roomnum, resrooms.ri_date, resrooms.ri_todate, l_cStatus, .F.)
					ENDIF
				ELSE
					IF SEEK(resrmshr.sr_rroomid,"hresroom","tag3")
						INSERT INTO curResRmShr (sr_rroomid, sr_shareid, sd_roomnum, sd_lowdat, sd_highdat, sd_status, sd_history) ;
							VALUES (hresroom.ri_rroomid, hresroom.ri_shareid, hresroom.ri_roomnum, hresroom.ri_date, hresroom.ri_todate, "OUT", .T.)
					ELSE
						* Not found in the resrooms neather in hresroom. Maybe never happend.
					ENDIF
				ENDIF
			ENDSCAN
			SELECT tmpResRmShr
		ENDIF
	ENDSCAN
	SELECT curResRooms
ENDSCAN
DClose("tmpResRmShr")
DClose("curResRooms")

GO l_nRecNo IN &lp_cResAlias
ENDPROC
*
PROCEDURE GroupSharersToSharing
* Collect all afected sharings in cursor curCxlSharing for RESET and group all sharers (set curResRmShr.sd_id).
LOCAL i, l_nRecno, l_lShared, l_oResRmShr

i = 1
SELECT curResRmShr
SET ORDER TO sd_roomnum
SCAN FOR EMPTY(sd_id)
	SCATTER MEMO NAME l_oResRmShr
	l_nRecno = RECNO()
	AddToCurCxlSharing(sr_shareid)
	l_lShared = .F.
	SCAN REST FOR EMPTY(sd_id) AND sr_rroomid <> l_oResRmShr.sr_rroomid WHILE sd_roomnum = l_oResRmShr.sd_roomnum AND sd_lowdat <= l_oResRmShr.sd_highdat
		AddToCurCxlSharing(sr_shareid)
		l_oResRmShr.sd_highdat = MAX(l_oResRmShr.sd_highdat, sd_highdat)
		REPLACE sd_id WITH i		&& Group all sharers in one sharing.
		l_lShared = .T.
	ENDSCAN
	GO l_nRecno
	IF l_lShared
		REPLACE sd_id WITH i		&& Group all sharers in one sharing.
		i = i + 1
	ENDIF
ENDSCAN
ENDPROC
*
PROCEDURE AddToCurCxlSharing
LPARAMETERS lp_nShareId
LOCAL l_nArea

IF NOT EMPTY(lp_nShareId)
	IF NOT USED("curCxlSharing")
		l_nArea = SELECT()
		SELECT sd_shareid FROM sharing WHERE 0=1 INTO CURSOR curCxlSharing READWRITE
		INDEX ON sd_shareid TAG sd_shareid
		SELECT (l_nArea)
	ENDIF
	IF NOT SEEK(lp_nShareId,"curCxlSharing","sd_shareid")
		INSERT INTO curCxlSharing (sd_shareid) VALUES (lp_nShareId)
	ENDIF
ENDIF

ENDPROC
*
PROCEDURE RemoveSharingRelations
LPARAMETERS lp_cResAlias
* RESET all collected sharing from cursor curCxlSharing in sharing.dbf, resrmshr.dbf, resrooms.dbf and reservat.dbf.
*
* Remove sharing relations from reservat.dbf and resrooms.dbf for reservation that are already in sharing.
* If this reservation will create new or existing sharing, relation would be set later.
LOCAL l_nRecNo, l_lUpdate

IF USED("curCxlSharing")
	l_nRecNo = RECNO(lp_cResAlias)

	SELECT curCxlSharing
	SCAN FOR SEEK(curCxlSharing.sd_shareid,"sharing","tag1") AND sharing.sd_status <> "CXL"
		REPLACE sd_status WITH "CXL", sd_nomembr WITH 0 IN sharing
		SELECT resrmshr
		SCAN FOR sr_shareid = sharing.sd_shareid
			IF SEEK(resrmshr.sr_rroomid,"resrooms","tag3")
				l_lUpdate = .F.
				IF NOT EMPTY(resrooms.ri_shareid)
					REPLACE ri_shareid WITH 0 IN resrooms
					l_lUpdate = .T.
				ENDIF
				IF SEEK(resrooms.ri_reserid, lp_cResAlias, "tag1") AND NOT EMPTY(&lp_cResAlias..rs_share)
					REPLACE rs_share WITH "" IN &lp_cResAlias
					l_lUpdate = .T.
				ENDIF
				IF l_lUpdate
					SaveIntoCurChangeRes(resrooms.ri_reserid)
				ENDIF
			ENDIF
			DELETE
		ENDSCAN
		SELECT curCxlSharing
	ENDSCAN
	DClose("curCxlSharing")

	GO l_nRecNo IN &lp_cResAlias
ENDIF
ENDPROC
*
PROCEDURE CreateCurSharing
SELECT CAST(0 AS Int) AS sd_id, * FROM sharing WHERE 0=1 INTO CURSOR curSharing READWRITE
INDEX ON sd_shareid TAG sd_shareid
ENDPROC
*
PROCEDURE UpdateSharingDbf
LPARAMETERS lp_cResAlias
* Prepare new sharing headers in curSharing and update sharing.dbf and resrmshr.dbf from cursors curSharing and curResRmShr.
*
* In curResRmShr cursor prepared all resrooms records, which could create new sharing or update existing sharing.
*	curResRmShr.sd_id = 0 - these resroom records doesn't belong to any sharing.
*	COUNT(sd_id) > 1 groupped by sd_id - these resroom records belong to sharings.
LOCAL l_nRecNo, l_nReserid, l_cRsStatus, l_oSharing, l_cStatus

l_nRecNo = RECNO(lp_cResAlias)

l_nReserid = &lp_cResAlias..rs_reserid
l_cRsStatus = &lp_cResAlias..rs_status

CreateCurSharing()		&& Structure from sharing + sd_id (integer)
SELECT curResRmShr
SET ORDER TO sd_id
SCAN FOR sd_id > 0
	SCATTER BLANK NAME l_oSharing
	l_oSharing.sd_id = sd_id
	l_cStatus = l_cRsStatus
	* Collect properties for sharing.
	SCAN WHILE sd_id = l_oSharing.sd_id
		IF sd_history
			IF SEEK(curResRmShr.sr_rroomid,"hresroom","tag3")
				l_oSharing.sd_nomembr = l_oSharing.sd_nomembr + 1
				l_oSharing.sd_shareid = hresroom.ri_shareid
				l_oSharing.sd_lowdat = IIF(EMPTY(l_oSharing.sd_lowdat), hresroom.ri_date, MIN(l_oSharing.sd_lowdat, hresroom.ri_date))
				l_oSharing.sd_highdat = MAX(l_oSharing.sd_highdat, hresroom.ri_todate)
				l_oSharing.sd_roomnum = EVL(l_oSharing.sd_roomnum, hresroom.ri_roomnum)
				l_oSharing.sd_roomtyp = EVL(l_oSharing.sd_roomtyp, hresroom.ri_roomtyp)
				Sharing_status(@l_cStatus, sd_status)
			ENDIF
		ELSE
			IF SEEK(curResRmShr.sr_rroomid,"resrooms","tag3")
				l_oSharing.sd_nomembr = l_oSharing.sd_nomembr + 1
				l_oSharing.sd_lowdat = IIF(EMPTY(l_oSharing.sd_lowdat), sd_lowdat, MIN(l_oSharing.sd_lowdat, sd_lowdat))
				l_oSharing.sd_highdat = MAX(l_oSharing.sd_highdat, sd_highdat)
				l_oSharing.sd_roomnum = EVL(l_oSharing.sd_roomnum, resrooms.ri_roomnum)
				l_oSharing.sd_roomtyp = EVL(l_oSharing.sd_roomtyp, resrooms.ri_roomtyp)
				Sharing_status(@l_cStatus, sd_status)
			ENDIF
		ENDIF
		IF EMPTY(l_oSharing.sd_shareid) AND NOT EMPTY(sr_shareid) AND NOT SEEK(curResRmShr.sr_shareid,"curSharing","sd_shareid")
			l_oSharing.sd_shareid = sr_shareid		&& Leave current Shareid (for not wasting ID - update old sharing record)
		ENDIF
	ENDSCAN
	SKIP -1
	IF l_oSharing.sd_nomembr > 1
		* Prepare new sharing.
		IF EMPTY(l_oSharing.sd_shareid)
			l_oSharing.sd_shareid = NextId("SHARING")
		ENDIF
		l_oSharing.sd_status = l_cStatus
		INSERT INTO curSharing FROM NAME l_oSharing
	ENDIF
ENDSCAN

* Update sharing.dbf and resrmshr.dbf
SELECT curSharing
SCAN
	SCATTER NAME l_oSharing
	SELECT sharing
	IF NOT SEEK(l_oSharing.sd_shareid,"sharing","tag1")	&& for not wasting ID - update old sharing record
		APPEND BLANK
	ENDIF
	GATHER NAME l_oSharing FIELDS sd_shareid, sd_roomtyp, sd_roomnum, sd_lowdat, sd_highdat, sd_status, sd_nomembr
	SELECT curResRmShr
	SCAN FOR sd_id = curSharing.sd_id
		IF SEEK(curResRmShr.sr_rroomid,"resrooms","tag3") AND SEEK(resrooms.ri_reserid,lp_cResAlias,"tag1") AND ;
				(resrooms.ri_shareid <> curSharing.sd_shareid OR EMPTY(&lp_cResAlias..rs_share))
			* Set sharing relations in reservat.dbf and resrooms.dbf.
			SaveIntoCurChangeRes(resrooms.ri_reserid)
			REPLACE ri_shareid WITH curSharing.sd_shareid IN resrooms
			REPLACE rs_share WITH "S" IN &lp_cResAlias
		ENDIF
		INSERT INTO resrmshr (sr_shareid, sr_rroomid) VALUES (curSharing.sd_shareid, curResRmShr.sr_rroomid)
	ENDSCAN
	SELECT curSharing
ENDSCAN
DClose("curResRmShr")
DClose("curSharing")

GO l_nRecNo IN &lp_cResAlias
ENDPROC
*
PROCEDURE UpdateShareRes
LPARAMETERS cResAlias, oCheckReservat
LOCAL l_nRecNo, l_nSelect, l_cChanges, l_oValNew, l_oValOld

IF USED("curChangeRes")
	l_nSelect = SELECT()
	l_nRecNo = RECNO(cResAlias)
	IF TYPE("oCheckReservat") == "O"
		l_oValNew = oCheckReservat.ValNew
		l_oValOld = oCheckReservat.ValOld
	ENDIF
	SELECT curChangeRes
	SCAN FOR TransactionIsOK()
		IF SEEK(curChangeRes.cr_reserid, cResAlias, "tag1")
			IF TYPE("oCheckReservat") == "O"
				oCheckReservat.oldandnew(cResAlias)
				oCheckReservat.msavereser(cResAlias,"EDIT")
				oCheckReservat.ValNew = l_oValNew
				oCheckReservat.ValOld = l_oValOld
			ELSE
				IF CURSORGETPROP("Buffering",cResAlias) == 1
					= avlSave(1, &cResAlias..rs_arrdate, &cResAlias..rs_depdate, &cResAlias..rs_rooms, ;
						"", "", &cResAlias..rs_status, &cResAlias..rs_altid, &cResAlias..rs_reserid, ;
						&cResAlias..rs_lstart, &cResAlias..rs_lfinish)
					= avlupdat()
				ELSE
					= avlupdat2(&cResAlias..rs_reserid, cResAlias)
					DoTableUpdate(.F.,.T.,cResAlias)
				ENDIF
			ENDIF
		ENDIF
	ENDSCAN
	GO l_nRecNo IN &cResAlias
	SELECT (l_nSelect)
ENDIF
ENDPROC
*
PROCEDURE BackupSharing
LOCAL l_nSelect

IF USED("curChangeRes")
	l_nSelect = SELECT()
	= AFIELDS(l_aCurField, "sharing")
	CREATE CURSOR curBkpSharing FROM ARRAY l_aCurField
	= AFIELDS(l_aCurField, "resrmshr")
	CREATE CURSOR curBkpResrmshr FROM ARRAY l_aCurField
	SELECT sharing
	SCAN FOR NOT sd_history
		SCATTER MEMO TO p_aRecord
		INSERT INTO curBkpSharing FROM ARRAY p_aRecord
		SELECT resrmshr
		SCAN FOR sr_shareid = sharing.sd_shareid
			SCATTER MEMO TO p_aRecordR
			INSERT INTO curBkpResrmshr FROM ARRAY p_aRecordR
		ENDSCAN
		SELECT sharing
	ENDSCAN
	= AFIELDS(l_aCurField, "curChangeRes")
	CREATE CURSOR curBkpChangeRes FROM ARRAY l_aCurField
	SELECT curChangeRes
	SCAN
		SCATTER MEMO TO p_aRecord
		INSERT INTO curBkpChangeRes FROM ARRAY p_aRecord
	ENDSCAN
	SELECT (l_nSelect)
ENDIF
ENDPROC
*
PROCEDURE ClearBackupSharing
LOCAL l_nSelect

IF USED("curBkpChangeRes")
	l_nSelect = SELECT()
	dclose("curBkpSharing")
	dclose("curBkpResrmshr")
	dclose("curBkpChangeRes")
	SELECT (l_nSelect)
ENDIF
ENDPROC
*
PROCEDURE RestoreSharing
LPARAMETERS lp_cResAlias
LOCAL l_nSelect, l_nRecNo

l_nSelect = SELECT()
l_nRecNo = RECNO(lp_cResAlias)
SELECT sharing
SCAN FOR NOT sd_history
	SELECT resrmshr
	SCAN FOR sr_shareid = sharing.sd_shareid
		IF SEEK(resrmshr.sr_rroomid, "resrooms", "tag3") AND SEEK(resrooms.ri_reserid, lp_cResAlias, "tag1")
			REPLACE ri_shareid WITH 0 IN resrooms
			REPLACE rs_share WITH "" IN &lp_cResAlias
		ENDIF
	ENDSCAN
	SELECT sharing
ENDSCAN
IF USED("curBkpChangeRes")
	LOCAL l_nSelect, l_nMaxShareid
	l_nSelect = SELECT()
	l_nMaxShareid = 0

	SELECT curBkpSharing
	SCAN
		SCATTER MEMVAR
		SELECT sharing
		l_nMaxShareid = MAX(l_nMaxShareid, m.sd_shareid)
		= SEEK(m.sd_shareid,"sharing","tag1")
		GATHER MEMVAR
		DELETE FOR sr_shareid = m.sd_shareid IN resrmshr
		SELECT curBkpSharing
	ENDSCAN
	DELETE FOR sd_shareid > l_nMaxShareid IN sharing
	DELETE FOR sr_shareid > l_nMaxShareid IN resrmshr

	SELECT curBkpResrmshr
	SCAN
		SCATTER MEMVAR
		INSERT INTO resrmshr FROM MEMVAR
	ENDSCAN
	SELECT curChangeRes
	SCAN
		SELECT curBkpChangeRes
		LOCATE FOR curBkpChangeRes.cr_reserid = curChangeRes.cr_reserid
		IF NOT FOUND()
			DELETE IN curChangeRes
		ENDIF
		SELECT curChangeRes
	ENDSCAN
	SELECT (l_nSelect)
ELSE
	DoTableRevert(.T.,"sharing")
	DoTableRevert(.T.,"resrmshr")
	DClose("curChangeRes")
ENDIF
SELECT sharing
SCAN FOR NOT sd_history
	SELECT resrmshr
	SCAN FOR sr_shareid = sharing.sd_shareid
		IF SEEK(resrmshr.sr_rroomid, "resrooms", "tag3") AND SEEK(resrooms.ri_reserid, lp_cResAlias, "tag1")
			REPLACE ri_shareid WITH resrmshr.sr_shareid IN resrooms
			REPLACE rs_share WITH "S" IN &lp_cResAlias
		ENDIF
	ENDSCAN
	SELECT sharing
ENDSCAN
SELECT (l_nSelect)
GO l_nRecNo IN &lp_cResAlias
ENDPROC
*
PROCEDURE RefreshRoomlist
LPARAMETERS lp_nCount, lp_cTblGrid, lp_cResAlias
LOCAL l_nRecnoR, l_nRecnoG, l_nSelect
l_nSelect = SELECT()
l_nRecnoR = RECNO(lp_cResAlias)
l_nRecnoG = RECNO(lp_cTblGrid)
lp_nCount = 0
SELECT &lp_cTblGrid
SCAN
	IF SEEK(&lp_cTblGrid..rs_reserid, lp_cResAlias, "tag1") AND (&lp_cTblGrid..rs_roomnum <> &lp_cResAlias..rs_roomnum)
		SELECT &lp_cResAlias
		SCATTER MEMO TO p_aRecord
		SELECT &lp_cTblGrid
		GATHER FROM p_aRecord MEMO
		lp_nCount = lp_nCount + 1
	ENDIF
ENDSCAN
GO l_nRecNoR IN &lp_cResAlias
GO l_nRecNoG IN &lp_cTblGrid
SELECT (l_nSelect)
ENDPROC
*
PROCEDURE AddrAgreedPrice
 LPARAMETERS lp_cResAlias, lp_nCurrentRate, lp_lResult
 LOCAL l_lUsedAdrrates, l_nSelected, l_nPrice, l_cChanges, l_nAddrid, l_cName, l_cCur, l_nRecNo
 l_nSelected = SELECT()
 l_lUsedAdrrates = .T.
 lp_lResult = .F.
 IF NOT USED("adrrates")
 	openfiledirect(.F., "adrrates")
 	l_lUsedAdrrates = .F.
 ENDIF
 DO CASE
	CASE NOT EMPTY(&lp_cResAlias..rs_addrid) AND SEEK(&lp_cResAlias..rs_addrid,'adrrates','tag1')
		l_nAddrid = &lp_cResAlias..rs_addrid
		l_cName = &lp_cResAlias..rs_lname
	CASE NOT EMPTY(&lp_cResAlias..rs_compid) AND SEEK(&lp_cResAlias..rs_compid,'adrrates','tag1')
		l_nAddrid = &lp_cResAlias..rs_compid
		l_cName = &lp_cResAlias..rs_company
	OTHERWISE
 ENDCASE
 IF NOT EMPTY(l_nAddrid)
	IF adrrates.af_urcprc
		IF NOT "*" $ &lp_cResAlias..rs_ratecod AND adrrates.af_ratecod <> &lp_cResAlias..rs_ratecod
			l_cCur = sqlcursor("SELECT TOP 1 rc_rcid FROM ratecode WHERE rc_ratecod = "+ sqlcnv(adrrates.af_ratecod,.T.) + " AND rc_todat >= " + sqlcnv(sysdate(),.T.) + " ORDER BY 1 DESC")
			IF USED(l_cCur) AND RECCOUNT(l_cCur)>0
				l_nRecNo = RECNO("ratecode")
				IF dlocate("ratecode","rc_rcid = " + TRANSFORM(&l_cCur..rc_rcid))
					l_nPrice = RateCalculate(,adrrates.af_ratecod, &lp_cResAlias..rs_roomtyp, ;
						&lp_cResAlias..rs_altid, 0, &lp_cResAlias..rs_adults, &lp_cResAlias..rs_childs, ;
						&lp_cResAlias..rs_childs2, &lp_cResAlias..rs_childs3, &lp_cResAlias..rs_arrdate, &lp_cResAlias..rs_depdate)
					IF YesNo(strfmt(GetLangText("RESERVAT","TXT_AGREED_PRICE_APPLY"),ALLTRIM(l_cName)) + ";" + ;
							GetLangText("RESERVAT","T_RATECODE") +": " + ALLTRIM(adrrates.af_ratecod) + ";" + ;
							GetLangText("RESERVAT","T_RATE") + ": " + TRANSFORM(l_nPrice,"9999999.99"))
						l_cChanges = RsHistry(&lp_cResAlias..rs_changes,"CHANGED", ;
							GetLangText("RESERVAT","TXT_AGREED_PRICE_SELECTED") + ":" + ;
							adrrates.af_ratecod + "; " + TRANSFORM(l_nPrice,"9999999.99"))
						REPLACE rs_ratecod WITH adrrates.af_ratecod, ;
										rs_changes WITH l_cChanges, ;
										rs_rate WITH l_nPrice ;
										IN &lp_cResAlias
						lp_lResult = .T.
					ENDIF
				ENDIF
				GO l_nRecNo IN ratecode
			ENDIF
			dclose(l_cCur)
		ENDIF
	ELSE
		l_nPrice = CalculatePrice(lp_cResAlias)
		IF l_nPrice > 0 AND l_nPrice <> lp_nCurrentRate AND ;
				YesNo(strfmt(GetLangText("RESERVAT","TXT_AGREED_PRICE_APPLY"),ALLTRIM(l_cName)) + ";" + ;
				GetLangText("RESERVAT","T_RATECODE") +": " + ALLTRIM(adrrates.af_ratecod) + ";" + ;
				GetLangText("RESERVAT","T_RATE") + ": " + TRANSFORM(l_nPrice,"9999999.99"))
			l_cChanges = RsHistry(&lp_cResAlias..rs_changes,"CHANGED", ;
				GetLangText("RESERVAT","TXT_AGREED_PRICE_SELECTED") + ":" + ;
				"*" + LEFT(adrrates.af_ratecod,9) + "; " + TRANSFORM(l_nPrice,"9999999.99"))
			REPLACE rs_ratecod WITH "*" + LEFT(adrrates.af_ratecod,9), ;
				rs_rate WITH l_nPrice, ;
				rs_changes WITH l_cChanges ;
				IN &lp_cResAlias
			lp_lResult = .T.
		ENDIF
	ENDIF
 ENDIF
 IF NOT l_lUsedAdrrates
 	dclose("adrrates")
 ENDIF
 SELECT (l_nSelected)
 RETURN lp_lResult
ENDPROC
*
FUNCTION CalculatePrice
 LPARAMETERS lp_cResAlias
 LOCAL l_nPrice
 l_nPrice = 0
 IF BETWEEN(&lp_cResAlias..rs_adults,1,3) AND EVALUATE("adrrates.af_amnt"+STR(&lp_cResAlias..rs_adults,1)) > 0
	l_nPrice = EVALUATE("adrrates.af_amnt"+STR(&lp_cResAlias..rs_adults,1))
 ELSE
 	l_nPrice = &lp_cResAlias..rs_adults * adrrates.af_amnt1
 ENDIF
 IF &lp_cResAlias..rs_childs > 0
 	l_nPrice = l_nPrice + &lp_cResAlias..rs_childs * adrrates.af_camnt1
 ENDIF
 IF &lp_cResAlias..rs_childs2 > 0
 	l_nPrice = l_nPrice + &lp_cResAlias..rs_childs2 * adrrates.af_camnt2
 ENDIF
 IF &lp_cResAlias..rs_childs3 > 0
 	l_nPrice = l_nPrice + &lp_cResAlias..rs_childs3 * adrrates.af_camnt3
 ENDIF
 RETURN l_nPrice
ENDFUNC
*
PROCEDURE AvailableRoomTypes
 LPARAMETERS lp_cCurName, lp_dFrom, lp_dTo, lp_nAllotCorrection, lp_lInclOpt, lp_lInclAllot, lp_lInclOos, lp_lInclTen
 LOCAL l_nSelected, l_cRTCur, l_cAVCur, l_nOpt, l_nOos, l_nAllot, l_nFree
 lp_nAllotCorrection = EVL(lp_nAllotCorrection,0)
 IF PCOUNT() < 5
 	lp_lInclOpt = param.pa_optidef
 ENDIF
 IF PCOUNT() < 6
 	lp_lInclAllot = param.pa_allodef
 ENDIF
 IF PCOUNT() < 7
 	lp_lInclOos = param2.pa_oosdef
 ENDIF
 IF PCOUNT() < 8
 	lp_lInclTen = param.pa_tentdef
 ENDIF
 lp_cCurName = ""
 l_nOpt = 0
 l_nAllot = 0
 l_nOos = 0
 l_nFree = 0
 l_cRTCur = SYS(2015)
 l_cAVCur = SYS(2015)
 l_nSelected = SELECT()
 SELECT *, 9999 AS rt_free, IIF(EMPTY(rt_sequenc),"Z",STR(rt_sequenc,2))+rt_roomtyp AS TAG2 ;
 		FROM roomtype WHERE INLIST(rt_group, 1, 4) ORDER BY TAG2 INTO CURSOR &l_cRTCur READWRITE
 SELECT *, DTOS(av_date)+av_roomtyp AS TAG2 FROM availab ;
 		WHERE BETWEEN(DTOS(av_date)+av_roomtyp, DTOS(lp_dFrom), DTOS(lp_dTo)) ;
 		ORDER BY TAG2 ;
 		INTO CURSOR &l_cAVCur
 IF RECCOUNT(l_cRTCur)> 0 AND RECCOUNT(l_cAVCur) > 0
	 SCAN
	 	SELECT &l_cRTCur
	 	LOCATE FOR rt_roomtyp == &l_cAVCur..av_roomtyp
	 	SELECT &l_cAVCur
	 	IF FOUND(l_cRTCur)
	 		l_nFree = av_avail - av_definit - IIF(lp_lInclOpt,av_option,0) - IIF(lp_lInclTen,av_tentat,0) - IIF(lp_lInclOos,av_ooservc,0) - IIF(lp_lInclAllot,MAX(av_allott-av_pick-lp_nAllotCorrection,0),0)
	 		IF &l_cRTCur..rt_free = 9999 && First value
	 			REPLACE rt_free WITH l_nFree IN &l_cRTCur
	 		ELSE
		 		IF l_nFree < &l_cRTCur..rt_free
		 			REPLACE rt_free WITH l_nFree IN &l_cRTCur
		 		ENDIF 			
	 		ENDIF
	 	ENDIF
	 ENDSCAN
 ELSE
 	dclose(l_cRTCur)
 	l_cRTCur = ""
 ENDIF
 dclose(l_cAVCur)
 SELECT (l_nSelected)
 lp_cCurName = l_cRTCur
 RETURN .T.
ENDPROC
*
PROCEDURE MoveResToAnotherHotel
* Moving reservation from one hotel to another.
* 1. Check if reservation could be created in new hotel (do all validations - checkreser)
* 2. Delete reservation in current hotel
* 3. Create reservation in new hotel
LPARAMETERS taParams
EXTERNAL ARRAY taParams
LOCAL llSuccess, lnRowOld, lnRowNew, lcExecScript, loReser
* taParams(1) = Old reser. Id
* taParams(2) = NEW rs_arrdate
* taParams(3) = NEW rs_depdate
* taParams(4) = NEW rs_roomnum
* taParams(5) = NEW rs_roomtyp
* taParams(6) = Action code for CheckAndSave: CHANGEHOTEL<lnXPos>,<lnYPos>
* taParams(7) = NEW hotel code
* taParams(8) = CURRENT hotel code
* taParams(9) = Reference to calling form (weekform)

lnRowNew = ASCAN(taParams(9).aHotels, taParams(7), 1, 0, 1, 8+2)
lnRowOld = ASCAN(taParams(9).aHotels, taParams(8), 1, 0, 1, 8+2)
IF lnRowNew > 0 AND lnRowOld > 0
	TEXT TO lcExecScript TEXTMERGE NOSHOW
		LPARAMETERS tnReserId, toReservat, tdArrdate
		LOCAL ARRAY laRates(1), laResfix(1)

		=SEEK(tnReserId,"reservat","tag1")
		SELECT reservat
		SCATTER MEMO NAME toReservat
		ADDPROPERTY(toReservat, "aAddresses(5)")
		ADDPROPERTY(toReservat, "aRates(1)")
		ADDPROPERTY(toReservat, "aResfix(1)")
		toReservat.aAddresses(1) = IIF(EMPTY(toReservat.rs_addrid), 0, DLookUp("address", "ad_addrid = " + SqlCnv(toReservat.rs_addrid,.T.), "ad_adid"))
		toReservat.aAddresses(2) = IIF(EMPTY(toReservat.rs_compid), 0, DLookUp("address", "ad_addrid = " + SqlCnv(toReservat.rs_compid,.T.), "ad_adid"))
		toReservat.aAddresses(3) = IIF(EMPTY(toReservat.rs_invid), 0, DLookUp("address", "ad_addrid = " + SqlCnv(toReservat.rs_invid,.T.), "ad_adid"))
		toReservat.aAddresses(4) = IIF(EMPTY(toReservat.rs_saddrid), 0, DLookUp("address", "ad_addrid = " + SqlCnv(toReservat.rs_saddrid,.T.), "ad_adid"))
		toReservat.aAddresses(5) = IIF(EMPTY(toReservat.rs_agentid), 0, DLookUp("address", "ad_addrid = " + SqlCnv(toReservat.rs_agentid,.T.), "ad_adid"))
		laRates(1) = .T.
		SqlCursor("SELECT rr_date+" + SqlCnv(tdArrdate-toReservat.rs_arrdate) + ", rr_raterc, rr_adults, rr_childs, rr_childs2, rr_childs3, rr_curcoef, rr_ratcoef FROM resrate WHERE rr_reserid = " + SqlCnv(tnReserId),,,,,,@laRates)
		ACOPY(laRates, toReservat.aRates)
		IF DLocate("resfix", "rf_reserid = " + SqlCnv(tnReserId) + " AND EMPTY(rf_ratecod)")
			laResfix(1) = .T.
			SqlCursor("SELECT rf_day, rf_alldays, rf_artinum, rf_price, rf_units, rf_ratecod, rf_adults, rf_childs, rf_childs2, rf_childs3, rf_forcurr, rf_package FROM resfix WHERE rf_reserid = " + SqlCnv(tnReserId) + " AND EMPTY(rf_ratecod)",,,,,,@laResfix)
			ACOPY(laResfix, toReservat.aResfix)
		ENDIF
	ENDTEXT
	taParams(9).aHotels[lnRowOld,4].CallScript(lcExecScript, taParams(1), @loReser, taParams(2))
	loReser.rs_arrdate = taParams(2)
	loReser.rs_depdate = taParams(3)
	loReser.rs_roomnum = taParams(4)
	loReser.rs_roomtyp = taParams(5)
	IF 0 < taParams(9).aHotels[lnRowNew,4].CheckForNewReser(taParams(9), @loReser, taParams(6))	&& Returns error code
		WAIT Str2Msg(GetLangText("ROOMPLAN","TXT_MOVE_RES_FROM_HOTEL"), "%s", ALLTRIM(taParams(8))) WINDOW NOWAIT
		DIMENSION _screen.oGlobal.oMultiProper.aScriptParams(7)
		_screen.oGlobal.oMultiProper.aScriptParams(1) = taParams(9)		&& Reference to calling form (weekform)
		_screen.oGlobal.oMultiProper.aScriptParams(2) = taParams(1)		&& Old reser. Id
		_screen.oGlobal.oMultiProper.aScriptParams(3) = loReser		&& New reservation object (scattered) with adrmain IDs (aAddresses), rates (aRates) and fix charges (aResfix)
		_screen.oGlobal.oMultiProper.aScriptParams(4) = taParams(6)		&& Action code for CheckAndSave: CHANGEHOTEL<lnXPos>,<lnYPos>
		_screen.oGlobal.oMultiProper.aScriptParams(5) = taParams(7)		&& NEW hotel code
		_screen.oGlobal.oMultiProper.aScriptParams(6) = taParams(8)		&& CURRENT hotel code
		* ExecScript for deleting reservation in current hotel
		TEXT TO _screen.oGlobal.oMultiProper.cExecScript TEXTMERGE NOSHOW
			LPARAMETERS taParams
			EXTERNAL ARRAY taParams
			IF ProcReservat("DeleteReser", @taParams)
				WAIT Str2Msg(GetLangText("ROOMPLAN","TXT_CREATE_RES_IN_HOTEL"), "%s", ALLTRIM(taParams(5))) WINDOW NOWAIT
				DIMENSION _screen.oGlobal.oMultiProper.aScriptParams(1)
				ACOPY(taParams, _screen.oGlobal.oMultiProper.aScriptParams)
				_screen.oGlobal.oMultiProper.cExecScript = taParams(7)		&& ExecScript for create new reservation in new hotel
				_screen.oGlobal.oMultiProper.CallProcess(taParams(5))		&& NEW hotel code
			ENDIF
		ENDTEXT
		* ExecScript for create new reservation in new hotel
		TEXT TO _screen.oGlobal.oMultiProper.aScriptParams(7) TEXTMERGE NOSHOW
			LPARAMETERS taParams
			EXTERNAL ARRAY taParams
			LOCAL loSession
			loSession = CREATEOBJECT("PrivateSession")
			loSession.CallProc("ProcReservat('CreateReservation', @tuParam1)", @taParams)
			taParams(1).OnRefresh()
			IF PEMSTATUS(taParams(1), "RefreshSignal", 5)
				taParams(1).RefreshSignal()
			ENDIF
		ENDTEXT
		_screen.oGlobal.oMultiProper.CallProcess(taParams(8))
		llSuccess = .T.
	ENDIF
ENDIF

RETURN llSuccess
ENDPROC
*
PROCEDURE DeleteReser
LPARAMETERS taParams
EXTERNAL ARRAY taParams
LOCAL loCheckReservat

IF SEEK(taParams(2),"reservat","tag1")
	loCheckReservat = CREATEOBJECT("Checkreservat")
	loCheckReservat.DeleteReser(,,,,,,,@taParams)
ENDIF
ENDPROC
*
PROCEDURE CheckReser
LPARAMETERS toReser, tcAction, toSession
LOCAL lnErrorCode, lcHotCode, lnOldReserId, lnNewReserId, loCheckReservat, loParam, loParam2

lcHotCode = IIF(VARTYPE(toSession.cHotCode) = "C", toSession.cHotCode, "")

IF NOT EMPTY(lcHotCode)
	_screen.oGlobal.oMultiProper.DataPathChange(lcHotCode)
ENDIF
loCheckReservat = CREATEOBJECT("Checkreservat")
loCheckReservat.mAdjustEnvironment()
IF NOT EMPTY(lcHotCode)
	_screen.oGlobal.oMultiProper.DataPathRestore()
ENDIF
lnOldReserId = toReser.rs_reserid
lnNewReserId = NextId("RESERVAT") + 0.1
ResetReservation(toReser, lnNewReserId)
toReser.rs_group = ""
toReser.rs_groupid = 0
toReser.rs_roomlst = .F.
toReser.rs_changes = RsHistry(ALLTRIM(toReser.rs_changes), "__MOVE__", "Old ReserID " + TRANSFORM(lnOldReserId))
INSERT INTO reservat FROM NAME toReser
loCheckReservat.plApplyGroupChanges = .F.
loCheckReservat.lResrateUpdateFromReservat = .T.
loCheckReservat.cAction = tcAction

*Backup param objects
loParam = _screen.oGlobal.oParam
loParam2 = _screen.oGlobal.oParam2
SELECT param
SCATTER MEMO NAME _screen.oGlobal.oParam
SELECT param2
SCATTER MEMO NAME _screen.oGlobal.oParam2
IF VARTYPE(toSession) = "O"
	PRIVATE poGlobalRmRtBld
	poGlobalRmRtBld = toSession
ENDIF
lnErrorCode = loCheckReservat.JustCheckReservation(,.T.)
*Restore param objects
_screen.oGlobal.oParam = loParam
_screen.oGlobal.oParam2 = loParam2
RELEASE poGlobalRmRtBld

IF lnErrorCode > 0
	LOCAL ARRAY laAddresses(1), laRates(1), laResfix(1)

	ACOPY(toReser.aAddresses, laAddresses)
	ACOPY(toReser.aRates, laRates)
	ACOPY(toReser.aResfix, laResfix)
	SELECT reservat
	SCATTER MEMO NAME toReser
	ADDPROPERTY(toReser, "aAddresses(1)")
	ADDPROPERTY(toReser, "aRates(1)")
	ADDPROPERTY(toReser, "aResfix(1)")
	ACOPY(laAddresses, toReser.aAddresses)
	ACOPY(laRates, toReser.aRates)
	ACOPY(laResfix, toReser.aResfix)
ELSE
	Alert(loCheckReservat.cLastError+" ("+TRANSFORM(lnErrorCode)+")")
ENDIF
loCheckReservat.mRestoreEnvironment()

RETURN lnErrorCode
ENDPROC
*
PROCEDURE CreateReservation
LPARAMETERS taParams
EXTERNAL ARRAY taParams
* taParams(1) = Reference to calling form (weekform)
* taParams(2) = Old reser. Id
* taParams(3) = New reservation object (scattered) with adrmain IDs (aAddresses), rates (aRates) and fix charges (aResfix)
* taParams(4) = Action code for CheckAndSave: CHANGEHOTEL<lnXPos>,<lnYPos>
* taParams(5) = NEW hotel code
* taParams(6) = CURRENT hotel code
LOCAL loReser, lcAction, lcNewHotel, lcOldHotel, loProcAddress, lcApName

loReser = taParams(3)
lcAction = taParams(4)
lcNewHotel = taParams(5)
lcOldHotel = taParams(6)

OpenFile(,"param")
OpenFile(,"address",,,5)
OpenFile(,"apartner")
OpenFile(,"reservat",,,5)
OpenFile(,"resrate",,,5)
OpenFile(,"resfix",,,5)

* Check address in reservation (rs_addrid, rs_compid, rs_invid, rs_saddrid, rs_agentid, rs_apid, rs_apname, rs_invapid and rs_invap).
loProcAddress = NEWOBJECT("ProcAddress","libs\proc_address.vcx")
IF NOT EMPTY(loReser.aAddresses(1))
	loReser.rs_addrid = loProcAddress.AddressGetByAdId(loReser.aAddresses(1))
ENDIF
IF NOT EMPTY(loReser.aAddresses(2))
	loReser.rs_compid = loProcAddress.AddressGetByAdId(loReser.aAddresses(2))
ENDIF
IF NOT EMPTY(loReser.aAddresses(3))
	loReser.rs_invid = loProcAddress.AddressGetByAdId(loReser.aAddresses(3))
ENDIF
IF NOT EMPTY(loReser.aAddresses(4))
	loReser.rs_saddrid = loProcAddress.AddressGetByAdId(loReser.aAddresses(4))
ENDIF
IF NOT EMPTY(loReser.aAddresses(5))
	loReser.rs_agentid = loProcAddress.AddressGetByAdId(loReser.aAddresses(5))
ENDIF
IF NOT EMPTY(loReser.rs_apid) AND NOT EMPTY(loReser.rs_compid)
	DLocate("apartner", "ap_addrid = " + SqlCnv(loReser.rs_compid,.T.) + " AND (ap_apid = " + SqlCnv(loReser.rs_apid,.T.) + " OR ap_lname = " + SqlCnv(loReser.rs_apname,.T.) + ")")
	loReser.rs_apid = apartner.ap_apid
	loReser.rs_apname = apartner.ap_lname
ENDIF
IF NOT EMPTY(loReser.rs_invapid) AND NOT EMPTY(loReser.rs_invid)
	DLocate("apartner", "ap_addrid = " + SqlCnv(loReser.rs_invid,.T.) + " AND (ap_apid = " + SqlCnv(loReser.rs_invapid,.T.) + " OR ap_lname = " + SqlCnv(loReser.rs_invap,.T.) + ")")
	loReser.rs_invapid = apartner.ap_apid
	loReser.rs_invap = apartner.ap_lname
ENDIF

loReser.rs_changes = STRTRAN(ALLTRIM(loReser.rs_changes), "__MOVE__", "MOVE from " + ALLTRIM(lcOldHotel) + " to " + ALLTRIM(lcNewHotel))
INSERT INTO reservat FROM NAME loReser
FOR i = 1 TO ALEN(loReser.aRates,1)
	INSERT INTO resrate (rr_rrid, rr_reserid, rr_ratecod) VALUES (NextId("RESRATE"), loReser.rs_reserid, ALLTRIM(CHRTRAN(loReser.rs_ratecod,"*!","")))
	REPLACE rr_date WITH loReser.aRates(i,1), ;
		   rr_raterc  WITH loReser.aRates(i,2), ;
		   rr_adults  WITH loReser.aRates(i,3), ;
		   rr_childs  WITH loReser.aRates(i,4), ;
		   rr_childs2  WITH loReser.aRates(i,5), ;
		   rr_childs3  WITH loReser.aRates(i,6), ;
		   rr_curcoef  WITH loReser.aRates(i,7), ;
		   rr_ratcoef  WITH loReser.aRates(i,8), ;
		   rr_status WITH IIF(loReser.aRates(i,2) = loReser.aRates(1,2), "OUS", "ORU") IN resrate
NEXT
IF ALEN(loReser.aResfix) > 1
	FOR i = 1 TO ALEN(loReser.aResfix,1)
		INSERT INTO resfix (rf_rfid, rf_reserid) VALUES (NextId("RESFIX"), loReser.rs_reserid)
		REPLACE rf_day WITH loReser.aResfix(i,1), ;
			   rf_alldays WITH loReser.aResfix(i,2), ;
			   rf_artinum WITH loReser.aResfix(i,3), ;
			   rf_price WITH loReser.aResfix(i,4), ;
			   rf_units WITH loReser.aResfix(i,5), ;
			   rf_ratecod WITH loReser.aResfix(i,6), ;
			   rf_adults WITH loReser.aResfix(i,7), ;
			   rf_childs WITH loReser.aResfix(i,8), ;
			   rf_childs2 WITH loReser.aResfix(i,9), ;
			   rf_childs3 WITH loReser.aResfix(i,10), ;
			   rf_forcurr WITH loReser.aResfix(i,11), ;
			   rf_package WITH loReser.aResfix(i,12) IN resfix
	NEXT
ENDIF
CheckAndSave(loReser,,,lcAction)

Alert(GetLangText("ROOMPLAN","TXT_CHECK_FIXCHARGES_RATES"))
ENDPROC
*
PROCEDURE CheckAndSave
LPARAMETERS lp_oReservat, lp_lMessage, lp_lApplyGroupChanges, lp_cAction, lp_nErrorCode, lp_lResrateUpdateFromReservat
LOCAL l_oSession, l_nArea, l_nRecno

IF SET("Datasession") = 1
	LOCAL l_oSession
	l_oSession = CREATEOBJECT("PrivateSession")
	l_oSession.FakeParam()
	lp_nErrorCode = l_oSession.CallProc("ProcReservat('DoCheckAndSave', .T., tuParam1, tuParam2, tuParam3, tuParam4, tuParam5)", ;
		lp_oReservat, lp_lMessage, lp_lApplyGroupChanges, lp_cAction, lp_lResrateUpdateFromReservat)
ELSE
	l_nArea = SELECT()
	l_nRecno = IIF(USED("reservat"),RECNO("reservat"),0)
	lp_nErrorCode = DoCheckAndSave(,lp_oReservat, lp_lMessage, lp_lApplyGroupChanges, lp_cAction, lp_lResrateUpdateFromReservat)
	IF NOT EMPTY(l_nRecno)
		GO l_nRecno IN reservat
	ENDIF
	SELECT (l_nArea)
ENDIF
ENDPROC
*
PROCEDURE DoCheckAndSave
LPARAMETERS lp_lPrivate, lp_oReservat, lp_lMessage, lp_lApplyGroupChanges, lp_cAction, lp_lResrateUpdateFromReservat
LOCAL l_oCheckreservat, l_lAuditActive
LOCAL ARRAY l_aEnvCheckAndSave(2,5)

IF lp_lPrivate AND g_AuditActive
	l_lAuditActive = .T.
	g_AuditActive = .F.
	_screen.oGlobal.oParam.pa_sysdate = _screen.oGlobal.oParam.pa_sysdate + 1
	SysDate()
ENDIF
l_oCheckreservat = CREATEOBJECT("Checkreservat")
l_aEnvCheckAndSave(1,1) = "reservat"
l_aEnvCheckAndSave(2,1) = "address"
l_oCheckreservat.mOpenTables(@l_aEnvCheckAndSave)
IF SEEK(lp_oReservat.rs_reserid, "reservat", "tag1")
	SELECT reservat
	GATHER NAME lp_oReservat MEMO
	l_oCheckreservat.plMessage = lp_lMessage
	l_oCheckreservat.plApplyGroupChanges = lp_lApplyGroupChanges
	l_oCheckreservat.lResrateUpdateFromReservat = lp_lResrateUpdateFromReservat
	l_oCheckreservat.cAction = IIF(EMPTY(lp_cAction), "", lp_cAction)
	lp_nErrorCode = l_oCheckreservat.CheckAndSave()
ELSE
	lp_nErrorCode = -1
ENDIF
l_oCheckreservat.mCloseTables(@l_aEnvCheckAndSave)
IF lp_lPrivate AND l_lAuditActive
	g_AuditActive = .T.
	_screen.oGlobal.oParam.pa_sysdate = _screen.oGlobal.oParam.pa_sysdate - 1
	SysDate()
ENDIF

RETURN lp_nErrorCode
ENDPROC
*
PROCEDURE PutVirtualRoomNumber
* Put virtual room number to sharing.sd_roomnum, resrooms.ri_roomnum = VIRTUAL_ROOMNUM for pending sharings (sharings without assigned room).
LPARAMETERS lp_nReserid
LOCAL l_nRiRecNo, l_cOrderRi, l_cRoomtype

l_cOrderRi = ORDER("resrooms")
SELECT resrooms
SET ORDER TO
SCAN FOR ri_reserid = lp_nReserid AND NOT EMPTY(ri_shareid)
	l_cRoomtype = resrooms.ri_roomtyp
	IF SEEK(resrooms.ri_shareid,"sharing","tag1") AND EMPTY(sharing.sd_roomnum)
		REPLACE sd_roomnum WITH VIRTUAL_ROOMNUM, sd_roomtyp WITH l_cRoomtype IN sharing
		l_nRiRecNo = RECNO("resrooms")
		SELECT resrmshr
		SCAN FOR sr_shareid = sharing.sd_shareid
			IF SEEK(resrmshr.sr_rroomid,"resrooms","tag3") AND (EMPTY(resrooms.ri_roomnum) OR resrooms.ri_reserid <> lp_nReserid)
				DO RiPutRoom IN ProcResrooms WITH resrooms.ri_reserid, resrooms.ri_date, {}, l_cRoomtype, VIRTUAL_ROOMNUM, sharing.sd_shareid
			ENDIF
		ENDSCAN
		SELECT resrooms
		GO l_nRiRecNo IN resrooms
	ENDIF
ENDSCAN
SET ORDER TO l_cOrderRi IN resrooms
ENDPROC
*
PROCEDURE RemoveVirtualRoomNumber
LOCAL l_cOrderRi, l_cOrderRp, l_cOrderSh

l_cOrderRi = ORDER("resrooms")
SET ORDER TO "" IN resrooms
BLANK FIELDS ri_roomnum FOR ri_roomnum = VIRTUAL_ROOMNUM IN resrooms
SET ORDER TO l_cOrderRi IN resrooms
l_cOrderSh = ORDER("sharing")
SET ORDER TO "" IN sharing
BLANK FIELDS sd_roomnum FOR NOT sd_history AND (sd_roomnum = VIRTUAL_ROOMNUM) IN sharing
SET ORDER TO l_cOrderSh IN sharing
*l_cOrderRp = ORDER("roomplan")
*SET ORDER TO "" IN roomplan
*DELETE FOR rp_roomnum+DTOS(rp_date) = VIRTUAL_ROOMNUM IN roomplan
*SET ORDER TO l_cOrderRp IN roomplan
ENDPROC
*
PROCEDURE GetRelocationText
LPARAMETERS lp_nReserId, lp_dArrDate, lp_cRelocationText, lp_cLineFeedString
LOCAL l_cResultCur, l_cResRoomsCur, l_cResFixCur, l_cResRate, l_cRatecod, l_nSelect, l_nLines, l_nMaxLines, l_cResCur, l_lConfRoomIntervals

IF PCOUNT()<4
	lp_cLineFeedString = CHR(10)
ENDIF
STORE "" TO lp_cRelocationText, l_cRatecod
l_nMaxLines = 20
l_cResultCur = SYS(2015)
l_cResRoomsCur = SYS(2015)
l_cResRate = SYS(2015)
l_nSelect = SELECT()

* Main result cursor
CREATE CURSOR &l_cResultCur (cu_date d, cu_roomtyp c(4), cu_roomnum c(4), cu_ratecod C(11), cu_raterc b, cu_arrtime c(5), cu_deptime c(5))
INDEX ON cu_date TAG TAG1

IF _screen.oGlobal.oParam2.pa_connew
	* Check if this is conference room with more then 1 day
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
		SELECT rt_group, rs_arrdate, rs_depdate 
			FROM reservat 
			INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp 
			WHERE rs_reserid = <<sqlcnv(lp_nReserId,.T.)>> AND rs_arrtime <> '     ' AND rs_deptime <> '     '
	ENDTEXT
	l_cResCur = SqlCursor(l_cSql)
	l_lConfRoomIntervals = (&l_cResCur..rt_group = 2 AND rs_depdate - rs_arrdate > 0)
	dclose(l_cResCur)
ENDIF

* Check if there are room changes
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT * FROM resrooms WHERE ri_reserid = <<SqlCnv(lp_nReserId,.T.)>> AND ri_date > <<SqlCnv(lp_dArrDate,.T.)>>
ENDTEXT
l_cResRoomsCur = SqlCursor(l_cSql)
IF RECCOUNT(l_cResRoomsCur)>0
	SCAN
		INSERT INTO &l_cResultCur (cu_date, cu_roomtyp, cu_roomnum) ;
			VALUES (&l_cResRoomsCur..ri_date, &l_cResRoomsCur..ri_roomtyp, &l_cResRoomsCur..ri_roomnum)
	ENDSCAN
ENDIF
dclose(l_cResRoomsCur)

* Check for price changes
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT resrate.*, rc_weekend, rc_closarr FROM resrate
		LEFT JOIN ratecode ON rr_ratecod = rc_ratecod__||__rc_roomtyp__||__DTOS(rc_fromdat)__||__rc_season
		WHERE rr_reserid = <<SqlCnv(lp_nReserId,.T.)>> AND PADR(rr_status,2) IN('OR', 'OK', 'OF')
ENDTEXT
l_cResRate = SqlCursor(l_cSql)
IF RECCOUNT(l_cResRate) > 0
	SCAN FOR LEFT(rr_status,2) = "OR" OR rr_status = "OFF" OR ISNULL(rc_weekend) OR ;
			(SUBSTR(rc_weekend, DOW(rr_date,2), 1) = '1' AND SUBSTR(rc_closarr, DOW(lp_dArrDate,2), 1) = ' ')
		l_cRatecod = LEFT(rr_ratecod,10)
		DO CASE
			CASE INLIST(rr_status, "OUS", "ORU", "OFF")
				l_cRatecod = "*" + l_cRatecod
			CASE INLIST(rr_status, "OAL", "ORA")
				l_cRatecod = "!" + l_cRatecod
			OTHERWISE
		ENDCASE
		IF SEEK(&l_cResRate..rr_date,l_cResultCur,"tag1")
			REPLACE cu_ratecod WITH l_cRatecod, ;
					cu_raterc WITH &l_cResRate..rr_raterc IN &l_cResultCur
		ELSE
			INSERT INTO &l_cResultCur (cu_date, cu_ratecod, cu_raterc) ;
				VALUES (&l_cResRate..rr_date, l_cRatecod, &l_cResRate..rr_raterc)
		ENDIF
	ENDSCAN
	IF l_lConfRoomIntervals
		SCAN ALL
			IF SEEK(&l_cResRate..rr_date,l_cResultCur,"tag1")
				REPLACE cu_arrtime WITH &l_cResRate..rr_arrtime, ;
						cu_deptime WITH &l_cResRate..rr_deptime ;
						IN &l_cResultCur
			ELSE
				INSERT INTO &l_cResultCur (cu_date, cu_arrtime, cu_deptime) ;
					VALUES (&l_cResRate..rr_date, &l_cResRate..rr_arrtime, &l_cResRate..rr_deptime)
			ENDIF
		ENDSCAN
	ENDIF
ENDIF
dclose(l_cResRate)

* Create tooltip text
IF RECCOUNT(l_cResultCur) > 0
	l_nLines = 0
	SELECT &l_cResultCur
	SCAN
		l_nLines = l_nLines + 1
		lp_cRelocationText = lp_cRelocationText + IIF(EMPTY(lp_cRelocationText), "", lp_cLineFeedString) + "INT: " + ;
				DTOC(cu_date) + " " + ;
				IIF(EMPTY(cu_arrtime),"", cu_arrtime + " - " + cu_deptime) + " " + ;
				Get_rt_roomtyp(cu_roomtyp) + " " + Get_rm_rmname(cu_roomnum) + " " + ;
				cu_ratecod + IIF(EMPTY(cu_raterc) AND EMPTY(cu_ratecod),""," " + STR(cu_raterc,10,2))
		IF l_nLines = l_nMaxLines
			lp_cRelocationText = lp_cRelocationText + lp_cLineFeedString + "INT: ..."
			EXIT
		ENDIF
	ENDSCAN
ENDIF
dclose(l_cResultCur)

* Check for resfix changes
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
	SELECT DISTINCT rf_package, rf_alldays, rf_day, rf_artinum, rf_ratecod, rf_units, rf_price,
		CAST(NVL(NVL(ar_lang<<g_Langnum>>,rc_lang<<g_Langnum>>),"") AS char(35)) AS rf_lang FROM resfix
		LEFT JOIN article ON ar_artinum = rf_artinum
		LEFT JOIN ratecode ON rc_ratecod = rf_ratecod
	WHERE rf_reserid = <<SqlCnv(lp_nReserId,.T.)>>
ENDTEXT
l_cResFixCur = SqlCursor(l_cSql)

* Add resfix changes to tooltip text
IF RECCOUNT(l_cResFixCur) > 0
	l_nLines = 0
	SELECT &l_cResFixCur
	SCAN
		l_nLines = l_nLines + 1
		lp_cRelocationText = lp_cRelocationText + IIF(EMPTY(lp_cRelocationText), "", lp_cLineFeedString) + ;
			IIF(rf_package, "PCK: ", "FIX: ") + PADR(IIF(rf_alldays, GetLangText("RESERVAT","TXT_EVERY_DAY"), DTOC(lp_dArrDate+rf_day)),15) + ;
			PADR(IIF(EMPTY(rf_artinum), rf_ratecod, rf_artinum),15) + " " + rf_lang + " " + TRANSFORM(rf_units) + "x " + ALLTRIM(STR(rf_price,10,2))
		IF l_nLines = l_nMaxLines
			lp_cRelocationText = lp_cRelocationText + lp_cLineFeedString + "FIX: ..."
			EXIT
		ENDIF
	ENDSCAN
ENDIF
DClose(l_cResFixCur)

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE AllowGroupSplit
LPARAMETERS lp_nReserid, lp_lSuccess
LOCAL ARRAY l_aResData(1)
lp_lSuccess = .F.
l_aResData(1) = .F.
IF parights(13)
	SELECT rs_reserid, rs_status, rt_group ;
			FROM reservat ;
			LEFT JOIN roomtype ON rt_roomtyp = rs_roomtyp ;
			WHERE rs_reserid = lp_nReserid ;
			INTO ARRAY l_aResData
	IF ALEN(l_aResData,2) > 1
		IF NOT INLIST(l_aResData(2), "CXL", "NS")
			IF _screen.oGlobal.lAllowConfGroupSplit OR NOT ISNULL(l_aResData(3)) AND l_aResData(3) <> 2
				lp_lSuccess = .T.
			ELSE
				= alert(GetLangText("RESERV2","TA_ONLYSTANDARD"))
			ENDIF
		ELSE
			= alert(GetLangText("RESERV2","TA_ISCXL")+"!")
		ENDIF
	ELSE
		= alert("Reservat record is NOT found!")
	ENDIF
ENDIF
RETURN lp_lSuccess
ENDPROC
*
PROCEDURE AutoAssignRooms
LPARAMETERS lp_oCheckReser, lp_cResAlias, lp_cRsFilter, lp_cRmFilter, lp_cRsWhile, lp_cRsOrder
* Automaticly assign room number
LOCAL l_nReserId, l_cOrderRS, l_nArea, l_nFound, l_nNotFound, l_lAutoFound, l_cRsWhile, l_cRtFilter, l_cRsFilter, l_cRmFilter
LOCAL l_cFilterRT, l_cFilterRM, l_nDay, l_cRoomnum, l_dResDepDate, l_lReservationProccesed, l_cBuilding, l_cAssignRoomText
LOCAL l_lDontCheckNetworkChangesForCurVal
l_lDontCheckNetworkChangesForCurVal = .T.

IF EMPTY(lp_cRsWhile) AND NOT YesNo(GetLangText("RESERV2","TXT_ARE_YOU_SURE"))
	* if lp_cRsWhile in not empty then user was asked to continue before in rent mode room plan.
	RETURN
ENDIF

IF EMPTY(lp_cRsFilter)
	l_cRsFilter = SqlCnv(.T.)
ELSE
	l_cRsFilter = lp_cRsFilter
ENDIF
IF EMPTY(lp_cRmFilter)
	l_cRmFilter = SqlCnv(.T.)
ELSE
	l_cRmFilter = lp_cRmFilter
ENDIF
l_nReserId = &lp_cResAlias..rs_reserid
IF EMPTY(lp_cRsWhile)
	l_cRsWhile = "rs_reserid >= " + SqlCnv(INT(l_nReserId)) + " AND rs_reserid < " + SqlCnv(INT(l_nReserId)+1)
ELSE
	l_cRsWhile = lp_cRsWhile
ENDIF
IF EMPTY(lp_cRsOrder)
	lp_cRsOrder = "Tag1"
ENDIF

l_nArea = SELECT()

l_nRecnoRS = RECNO(lp_cResAlias)
l_cOrderRS = ORDER(lp_cResAlias)
SET ORDER TO lp_cRsOrder IN &lp_cResAlias

l_cFilterRT = FILTER("Roomtype")
SET FILTER TO IN Roomtype

l_cFilterRM = FILTER("Room")
SET FILTER TO IN Room
l_cOrderRM = ORDER("Room")
SET ORDER TO Tag2 IN Room
l_nFound = 0
l_nNotFound = 0
l_cAssignRoomText = GetLangText("RESERV2","TXT_ASSIGNING_ROOMS") + " ... "
IF DLocate(lp_cResAlias, l_cRsWhile)
	SELECT &lp_cResAlias
	SCAN FOR &l_cRsFilter AND rs_rooms = 1 AND EMPTY(rs_roomnum) AND NOT INLIST(rs_status, [NS], [CXL]) ;
			WHILE &l_cRsWhile
		l_lAutoFound = .F.
		l_cBuilding = DLookUp("althead", "al_altid = " + SqlCnv(&lp_cResAlias..rs_altid), "al_buildng") 
		IF g_lShips AND NOT EMPTY(l_cBuilding)
			l_cRtFilter = "roomtype.rt_buildng = " + SqlCnv(l_cBuilding)
		ELSE
			l_cRtFilter = SqlCnv(.T.)
		ENDIF
		IF SEEK(&lp_cResAlias..rs_roomtyp,"RoomType","tag1") AND roomtype.rt_group <> 2 AND &l_cRtFilter
			l_dResDepDate = GetResDepDate(&lp_cResAlias..rs_reserid, &lp_cResAlias..rs_arrdate, lp_cResAlias)
			SELECT Room
			= SEEK(&lp_cResAlias..rs_roomtyp, "Room", "Tag2")
			SCAN FOR &l_cRmFilter WHILE rm_roomtyp = &lp_cResAlias..rs_roomtyp
				IF ReserveRoom()
					l_lReservationProccesed = .F.
					l_cRoomnum = Room.rm_roomnum
					FOR l_nDay = 0 TO l_dResDepDate - &lp_cResAlias..rs_arrdate
						IF SEEK(l_cRoomnum+DTOS(&lp_cResAlias..rs_arrdate+l_nDay),"RoomPlan","Tag1")
							l_cRoomnum = ""
							EXIT
						ENDIF
					NEXT
					IF NOT EMPTY(l_cRoomnum)
						REPLACE rs_roomnum WITH l_cRoomnum IN &lp_cResAlias
						IF 0 < lp_oCheckReser.CheckAndSave(lp_cResAlias,,,l_lDontCheckNetworkChangesForCurVal)
							l_lAutoFound = .T.
						ELSE
							REPLACE rs_roomnum WITH "" IN &lp_cResAlias
						ENDIF
						l_lReservationProccesed = .T.
					ENDIF
					SELECT Room
					ReleaseRoom()
					IF l_lReservationProccesed
						* room assigned, go to next reservation
						* exit from scaning through room candidates
						EXIT
					ENDIF
				ENDIF
			ENDSCAN
			SELECT &lp_cResAlias
		ENDIF
		IF l_lAutoFound
			l_nFound = l_nFound + 1
		ELSE
			l_nNotFound = l_nNotFound + 1
		ENDIF
		WAIT l_cAssignRoomText + TRANSFORM(l_nFound) + "/" + TRANSFORM(l_nNotFound) + "..." WINDOW NOWAIT
	ENDSCAN
	WAIT CLEAR
ENDIF
IF EMPTY(lp_cRmFilter)
	Alert(GetLangText("AUDIT","TXT_DONE"))
ELSE
	MsgBox(GetLangText("RESERV2","TA_AUTOFOUND") + " " + TRANSFORM(l_nFound) + CHR(13) + ;
		GetLangText("RESERV2","TA_AUTONOTFOUND") + " " + TRANSFORM(l_nNotFound) + "!", GetLangText("FUNC","TXT_MESSAGE"), 48)
ENDIF

SET FILTER TO &l_cFilterRT IN Roomtype
SET FILTER TO &l_cFilterRM IN Room
SET ORDER TO l_cOrderRM IN Room
SET ORDER TO l_cOrderRS IN &lp_cResAlias
GO l_nRecnoRS IN &lp_cResAlias

SELECT (l_nArea)
ENDPROC
*
PROCEDURE ReserveRoom
LOCAL l_lSuccess, l_lNoMessage
l_lSuccess = .F.
l_lNoMessage = .T.
IF dlock("room",5,l_lNoMessage)
	l_lSuccess = .T.
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE ReleaseRoom
dunlock("room")
RETURN .T.
ENDPROC
*
PROCEDURE CheckIsRoomFree
* Check direct in database for some room, is those free for given date period
LPARAMETERS lp_cRoomNum, lp_dFromDate, lp_dToDate
LOCAL l_nSelect, l_cSql, l_lFree, l_cResCur
l_lFree = .F.

IF EMPTY(lp_cRoomNum) OR EMPTY(lp_dFromDate) OR EMPTY(lp_dToDate)
	RETURN l_lFree
ENDIF

l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT DISTINCT rp_roomnum FROM roomplan ;
		LEFT JOIN reservat ON rp_reserid = rs_reserid ;
		WHERE rp_roomnum = <<sqlcnv(lp_cRoomNum, .T.)>> AND ;
		rp_date BETWEEN <<sqlcnv(lp_dFromDate, .T.)>> AND <<sqlcnv(lp_dToDate, .T.)>> AND rp_nights > 0 AND ;
		(ISNULL(rs_reserid) OR NOT (rs_status IN ("OUT", "NS", "CXL")))
ENDTEXT
l_cResCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
IF RECCOUNT()=0
	l_lFree = .T.
ENDIF
dclose(l_cResCur)

SELECT (l_nSelect)

RETURN l_lFree
ENDPROC
*
PROCEDURE CheckIsConfRoomOccupied
LPARAMETERS lp_cRoomNum, lp_dArrDate, lp_dDepDate, lp_cArrTime, lp_cDepTime, lp_cResAlias
LOCAL l_nRecNoRp, l_nSelect, l_lRoomOccupied, l_nRecNoRes
IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF

l_lRoomOccupied = .F.

l_nRecNoRp = RECNO("roomplan")

IF SEEK(lp_cRoomNum+DTOS(lp_dArrDate),"roomplan","tag1")

	l_nRecNoRes = RECNO(lp_cResAlias)
	l_nSelect = SELECT()

	SELECT roomplan
	SCAN REST WHILE rp_roomnum = lp_cRoomNum AND rp_date <= lp_dDepDate AND NOT l_lRoomOccupied
		IF roomplan.rp_status > 0 AND SEEK(roomplan.rp_reserid, lp_cResAlias, "tag1")
			l_nFirstStart = IIF(roomplan.rp_date = &lp_cResAlias..rs_arrdate, &lp_cResAlias..rs_arrtime, "00:00")
			l_nFirstStart = IIF(EMPTY(STRTRAN(l_nFirstStart,":")), "00:00", l_nFirstStart)
			l_nFirstEnd = IIF(roomplan.rp_date = &lp_cResAlias..rs_depdate, &lp_cResAlias..rs_deptime, "24:00")
			l_nFirstEnd = IIF(EMPTY(STRTRAN(l_nFirstEnd,":")), "24:00", l_nFirstEnd)
			l_nSecondStart = IIF(roomplan.rp_date = lp_dArrDate, lp_cArrTime, "00:00")
			l_nSecondStart = IIF(EMPTY(STRTRAN(l_nSecondStart,":")), "00:00", l_nSecondStart)
			l_nSecondEnd = IIF(roomplan.rp_date = lp_dDepDate, lp_cDepTime, "24:00")
			l_nSecondEnd = IIF(EMPTY(STRTRAN(l_nSecondEnd,":")), "24:00", l_nSecondEnd)

			IF (l_nFirstStart < l_nSecondEnd) AND (l_nFirstEnd > l_nSecondStart) AND ;
					NOT INLIST(&lp_cResAlias..rs_status, "NS", "CXL", "OUT")
				l_lRoomOccupied = .T.
			ENDIF

		ELSE
			l_lRoomOccupied = .T.
		ENDIF
	
	ENDSCAN
	
	SELECT (l_nSelect)
	GO l_nRecNoRes IN &lp_cResAlias

ENDIF

GO l_nRecNoRp IN roomplan

RETURN l_lRoomOccupied
ENDPROC
*
PROCEDURE GetResDepDate
LPARAMETERS lp_nReserId, lp_nResArrDate, lp_cResAlias
IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF
LOCAL l_dResDepDate, l_oResRooms1, l_oResRooms2, l_nRecNo
l_dResDepDate = {}
l_nRecNo = RECNO(lp_cResAlias)

IF SEEK(lp_nReserId, lp_cResAlias, "tag1")

	RiGetRoom(lp_nReserId, lp_nResArrDate, @l_oResRooms1, @l_oResRooms2)
	IF NOT (ISNULL(l_oResRooms1) OR ISNULL(l_oResRooms2) OR l_oResRooms1.ri_rroomid = l_oResRooms2.ri_rroomid)
		l_dResDepDate = l_oResRooms2.ri_date - 1
	ELSE
		IF &lp_cResAlias..rs_arrdate = &lp_cResAlias..rs_depdate
			l_dResDepDate = &lp_cResAlias..rs_depdate
		ELSE
			l_dResDepDate = &lp_cResAlias..rs_depdate - 1
		ENDIF
	ENDIF

ENDIF

GO l_nRecNo IN &lp_cResAlias

RETURN l_dResDepDate
ENDPROC
*

&& PRAssignRoomToReservation assigns room to reservation. Room must be of same room type, as set in reservat.rs_roomtyp field.
&& Returns numeric value, where > 0 means process was OK, and negative value means some error occured, and room is not assigned.
PROCEDURE PRAssignRoomToReservation
LPARAMETERS lp_nRsId, lp_cRoomNum
LOCAL l_oReser, l_lSuccess, l_nError, l_nSelect, l_dResDepDate, l_nDay, l_nError

l_nError = -999

IF EMPTY(lp_nRsId)
	l_nError = -998
	RETURN l_nError
ENDIF

IF EMPTY(lp_cRoomNum)
	l_nError = -997
	RETURN l_nError
ENDIF

l_nSelect = SELECT()

openfiledirect(.F.,"reservat")
openfiledirect(.F.,"room")
openfiledirect(.F.,"roomplan")
openfiledirect(.F.,"resrooms")

SELECT reservat
LOCATE FOR rs_rsid = lp_nRsId
IF NOT FOUND()
	l_nError = -996
	SELECT (l_nSelect)
	RETURN l_nError
ENDIF

l_dResDepDate = GetResDepDate(rs_reserid, rs_arrdate)

SELECT room
LOCATE FOR rm_roomnum = lp_cRoomNum
IF NOT FOUND() OR rm_roomtyp <> reservat.rs_roomtyp
	l_nError = -995
	SELECT (l_nSelect)
	RETURN l_nError
ENDIF

FOR l_nDay = 0 TO l_dResDepDate - reservat.rs_arrdate
	IF SEEK(lp_cRoomNum+DTOS(reservat.rs_arrdate+l_nDay),"roomplan","TAG1")
		* Room is not free
		l_nError = -994
		SELECT (l_nSelect)
		RETURN l_nError
	ENDIF
ENDFOR

IF NOT ReserveRoom()
	l_nError = -993
	SELECT (l_nSelect)
	RETURN l_nError
ENDIF

SELECT reservat
SCATTER NAME l_oReser
l_oReser.rs_roomnum = lp_cRoomNum

CheckAndSave(l_oReser, .F., .F., "", @l_nError)

ReleaseRoom()

SELECT (l_nSelect)

RETURN l_nError
ENDPROC
*
PROCEDURE PRGetFreeRoomsForReservation
LPARAMETERS lp_nRsId, lp_lReturnJSON, lp_lOpenTables
LOCAL l_arrival, l_departure, l_roomtype, l_buff, l_order, l_nReservatRecNo, l_nRtGroup, l_nReserId, l_oResRooms1, l_oResRooms2, l_cRoomplanOrder, l_nOldArea

l_nOldArea = SELECT()

l_nReservatRecNo = RECNO("reservat")

l_buff = ''

IF lp_lReturnJSON
	SELECT rs_roomnum AS rm_roomnum FROM reservat WHERE 1=0 INTO CURSOR crfreerm READWRITE
ENDIF

IF lp_lOpenTables
	OpenFileDirect(,"reservat")
	OpenFileDirect(,"roomplan","roomplan1")
	OpenFileDirect(,"room")
	OpenFileDirect(,"roomtype")
	OpenFileDirect(,"resrooms")
ENDIF

IF NOT EMPTY(lp_nRsId)
	IF NOT SEEK(lp_nRsId,"reservat","tag33")
		IF lp_lReturnJSON
			l_buff = FNStringifyCursor("crfreerm")
		ENDIF
		RETURN l_buff
	ENDIF
ENDIF

l_arrival = MAX(SysDate(),reservat.rs_arrdate)
l_nReserId = reservat.rs_reserid

RiGetRoom(reservat.rs_reserid, l_arrival, @l_oResRooms1, @l_oResRooms2)

IF NOT (ISNULL(l_oResRooms1) OR ISNULL(l_oResRooms2) OR l_oResRooms1.ri_rroomid = l_oResRooms2.ri_rroomid)
	l_departure = l_oResRooms2.ri_date - 1
ELSE
	IF reservat.rs_arrdate = reservat.rs_depdate
		l_departure = reservat.rs_depdate
	ELSE
		l_departure = reservat.rs_depdate - 1
	ENDIF
ENDIF

l_roomtype = reservat.rs_roomtyp
l_nRtGroup = DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(reservat.rs_roomtyp), "rt_group")

SELECT roomplan1
l_cRoomplanOrder = ORDER()
SET ORDER TO TAG Tag1
SELECT room
l_order = ORDER()
SET ORDER TO tag2 IN 'room'
SEEK l_roomtype

DO WHILE room.rm_roomtyp=l_roomtype .AND. .NOT. EOF()
	SELECT roomplan1
	SET NEAR ON
	=SEEK(room.rm_roomnum+DTOS(l_arrival),'roomplan1','tag1')
	SET NEAR OFF
	LOCATE REST FOR rp_reserid <> l_nReserId AND (rp_nights > 0 OR SEEK(rp_reserid, "reservat","Tag1") AND ;
			NOT INLIST(reservat.rs_status, "OUT", "NS", "CXL")) ;
			WHILE rp_roomnum=room.rm_roomnum .AND. rp_date<=l_departure
	IF .NOT. FOUND("roomplan1")
		IF lp_lReturnJSON
			INSERT INTO crfreerm (rm_roomnum) VALUES (room.rm_roomnum)
		ELSE
			IF l_arrival == sysdate()
				l_buff = l_buff+Get_rm_rmname(room.rm_roomnum)+' '+Get_rt_roomtyp(room.rm_roomtyp)+' '+room.rm_status+CHR(13)+CHR(10)
			ELSE
				l_buff = l_buff+Get_rm_rmname(room.rm_roomnum)+' '+Get_rt_roomtyp(room.rm_roomtyp)+' '+SPACE(3)+CHR(13)+CHR(10)
			ENDIF
		ENDIF
	ENDIF
	SELECT room
	SKIP 1
ENDDO

IF lp_lReturnJSON
	l_buff = FNStringifyCursor("crfreerm")
	dclose("crfreerm")
ENDIF

SET ORDER TO l_order IN 'room'
SELECT reservat
GO l_nReservatRecNo
SELECT roomplan1
SET ORDER TO &l_cRoomplanOrder

SELECT (l_nOldArea)

RETURN l_buff
ENDPROC
*
PROCEDURE PRCheckInReservation
LPARAMETERS lp_nRsId
LOCAL l_oQuickReser AS cQuickReser OF procreservat.prg, l_lSuccess, l_oResult

l_oResult = MakeStructure("success,errormessage")
l_oResult.success = .F.
l_oResult.errormessage = ""

IF EMPTY(lp_nRsId)
	l_oResult.errormessage = "No reservation id is provided"
ELSE
	l_oQuickReser = CREATEOBJECT("cQuickReser")
	l_oResult.success = l_oQuickReser.ResCheckIn(lp_nRsId)
	IF NOT l_oResult.success
		l_oResult.errormessage = l_oQuickReser.cvaliderr
	ENDIF
ENDIF

RETURN FNStringifyObject(l_oResult)
ENDPROC
*
PROCEDURE PROnGroupInfo
LPARAMETERS lp_nReserId, lp_cResAlias, lp_oCallForm
LOCAL l_cName, l_nSelect, l_nRecno
IF EMPTY(lp_cResAlias)
	lp_cResAlias = "reservat"
ENDIF

l_nSelect = SELECT()
l_nRecno = RECNO(lp_cResAlias)

IF SEEK(lp_nReserId,lp_cResAlias,"tag1")

	l_cName = ALLTRIM(&lp_cResAlias..rs_group)
	SELECT INT(rs_reserid) AS trs_id FROM reservat ;
			WHERE rs_group+DTOS(rs_arrdate)+rs_lname = l_cName ;
			GROUP BY trs_id ;
			INTO CURSOR tblResMultiple
	IF RECCOUNT("tblResMultiple") > 1
		DO FORM forms\resgroups.scx WITH "DEFAULT", lp_oCallForm, ;
				&lp_cResAlias..rs_groupid, &lp_cResAlias..rs_group, ;
				{}, {}
	ELSE
		LOCAL l_nIntId
		l_nIntId = INT(&lp_cResAlias..rs_reserid)
		SELECT gr_groupid FROM reservat ;
				INNER JOIN groupres ON rs_groupid = gr_groupid ;
				GROUP BY gr_groupid ;
				WHERE rs_reserid >= l_nIntId AND rs_reserid < l_nIntId+1 ;
				INTO CURSOR tblResGroupIds
		DO FORM forms\resgroupinfo.scx WITH "tblResGroupIds", lp_oCallForm
		dclose("tblResGroupIds")
	ENDIF
	dclose("tblResMultiple")

ENDIF

GO l_nRecno IN &lp_cResAlias
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE PRHistresUpdateSumRecords
LPARAMETERS lp_dSysDate
LOCAL l_nSelect, l_oCaHR
l_nSelect = SELECT()
IF EMPTY(lp_dSysDate)
     lp_dSysDate = sysdate()
ENDIF
l_cCurName = SYS(2015)
l_oCaHR = CREATEOBJECT("cahistres")
l_oCaHR.Alias = l_cCurName
l_oCaHR.cfilterclause = "hr_reserid IN (" + ;
          sqlcnv(0.100) + "," + ;
          sqlcnv(0.200) + "," + ;
          sqlcnv(0.300) + "," + ;
          sqlcnv(0.400) + "," + ;
          sqlcnv(0.500) + "," + ;
          sqlcnv(0.700) + ;
          ")"
l_oCaHR.CursorFill()
SELECT (l_cCurName)
IF .NOT. dlocate(l_cCurName, "hr_reserid = " + sqlcnv(0.100))
     INSERT INTO (l_cCurName) (hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_lname)  ;
          VALUES (nextid("RESUNQID"), 0.100, lp_dSysDate, lp_dSysDate, "PASSERBY")
ELSE
     REPLACE &l_cCurName..hr_depdate WITH lp_dSysDate
ENDIF
IF .NOT. dlocate(l_cCurName, "hr_reserid = " + sqlcnv(0.200))
     INSERT INTO (l_cCurName) (hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_lname)  ;
          VALUES (nextid("RESUNQID"), 0.200, lp_dSysDate, lp_dSysDate, "PAIDOUT")
ELSE
     REPLACE &l_cCurName..hr_depdate WITH lp_dSysDate
ENDIF
IF .NOT. dlocate(l_cCurName, "hr_reserid = " + sqlcnv(0.300))
     INSERT INTO (l_cCurName) (hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_lname)  ;
          VALUES (nextid("RESUNQID"), 0.300, lp_dSysDate, lp_dSysDate, "CASH IN/OUT")
ELSE
     REPLACE &l_cCurName..hr_depdate WITH lp_dSysDate
ENDIF
IF  .NOT. dlocate(l_cCurName, "hr_reserid = " + sqlcnv(0.400))
     INSERT INTO (l_cCurName) (hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_lname)  ;
          VALUES (nextid("RESUNQID"), 0.400, lp_dSysDate, lp_dSysDate, "TO/FROM HOUSEBANK")
ELSE
     REPLACE &l_cCurName..hr_depdate WITH lp_dSysDate
ENDIF
IF .NOT. dlocate(l_cCurName, "hr_reserid = " + sqlcnv(0.500))
     INSERT INTO (l_cCurName) (hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_lname)  ;
          VALUES (nextid("RESUNQID"), 0.500, lp_dSysDate, lp_dSysDate, "CURRENCY EXCHANGE")
ELSE
     REPLACE &l_cCurName..hr_depdate WITH lp_dSysDate
ENDIF
IF .NOT. dlocate(l_cCurName, "hr_reserid = " + sqlcnv(0.700))
     INSERT INTO (l_cCurName) (hr_rsid, hr_reserid, hr_arrdate, hr_depdate, hr_lname)  ;
          VALUES (nextid("RESUNQID"), 0.700, lp_dSysDate, lp_dSysDate, "LEDGER")
ELSE
     REPLACE &l_cCurName..hr_depdate WITH lp_dSysDate
ENDIF
l_oCaHR.DoTableUpdate(.T.)
l_oCaHR.dclose()
SELECT (l_nSelect)
ENDPROC
*
PROCEDURE PRAddressHistory
LPARAMETERS lp_nAddrID
LOCAL l_nArea, l_nRecno, l_curLaststay, l_cMessage, l_oAstat

l_nArea = SELECT()

l_curLaststay = SqlCursor("SELECT * FROM laststay WHERE ls_addrid = " + SqlCnv(lp_nAddrID,.T.))
l_cMessage = ALLTRIM(GetLangText("GSTSTAT","T_LAST")) + ":" + CRLF
IF USED(l_curLaststay) AND RECCOUNT(l_curLaststay) > 0
     l_cMessage = l_cMessage + "  " + SUBSTR(DTOC(&l_curLaststay..ls_arrdat),1,6) + "-" + MakeShorDateString(&l_curLaststay..ls_depdate) + CRLF
     l_cMessage = l_cMessage + "  " + Get_rt_roomtyp(&l_curLaststay..ls_roomtyp) + " / " + Get_rm_rmname(&l_curLaststay..ls_roomnum) + CRLF
     l_cMessage = l_cMessage + "  " + ALLTRIM(&l_curLaststay..ls_ratecod) + "  " + ALLTRIM(STR(&l_curLaststay..ls_rate,12,2)) + CRLF
ENDIF
DClose(l_curLaststay)

l_nRecno = RECNO("address")
IF SEEK(lp_nAddrID,"address","tag1") AND NOT EMPTY(address.ad_roomnum)
     l_cMessage = l_cMessage + "  " + GetLangText("GSTSTAT","TXT_WROOMNUM") + ": " + Get_rm_rmname(address.ad_roomnum) + CRLF
ENDIF
GO l_nRecno IN address

IF parights(48)
     l_oAstat = PRStatCreate(lp_nAddrID, DATE(YEAR(g_sysdate),12,31))
     l_cMessage = l_cMessage + TRANSFORM(YEAR(g_sysdate)) + ":" + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_cres,8) + " " + GetLangText("GSTSTAT","T_STAYS") + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_cnights,8) + " " + GetLangText("GSTSTAT","T_NIGHTS") + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_cns,8) + " " + GetLangText("GSTSTAT","T_NS") + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_ccxl,8) + " " + GetLangText("GSTSTAT","T_CXL") + CRLF
     l_cMessage = l_cMessage + "  " + STR(l_oAstat.aa_camount,8,2) + " " + GetLangText("GSTSTAT","T_REV") + CRLF                         

     l_oAstat = PRStatCreate(lp_nAddrID, DATE(YEAR(g_sysdate)-1,12,31))
     l_cMessage = l_cMessage + TRANSFORM(YEAR(g_sysdate)-1) + ":" + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_cres,8) + " " + GetLangText("GSTSTAT","T_STAYS") + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_cnights,8) + " " + GetLangText("GSTSTAT","T_NIGHTS") + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_cns,8) + " " + GetLangText("GSTSTAT","T_NS") + CRLF
     l_cMessage = l_cMessage + "  " + PADL(l_oAstat.aa_ccxl,8) + " " + GetLangText("GSTSTAT","T_CXL") + CRLF
     l_cMessage = l_cMessage + "  " + STR(l_oAstat.aa_camount,8,2) + " " + GetLangText("GSTSTAT","T_REV") + CRLF                         
ENDIF

SELECT(l_nArea)

RETURN l_cMessage
ENDPROC
*
PROCEDURE PRStatCreate
LPARAMETERS lp_addrid, lp_date
LOCAL l_oAstat, l_curAstat, l_curHiststat

l_curAstat = SqlCursor("SELECT TOP 1 * FROM astat WHERE aa_addrid = " + SqlCnv(lp_addrid,.T.) + " AND aa_date <= " + SqlCnv(lp_date,.T.) + " ORDER BY aa_date DESC")
l_curHiststat = SqlCursor("SELECT TOP 1 * FROM histstat WHERE aa_addrid = " + SqlCnv(lp_addrid,.T.) + " AND aa_date <= " + SqlCnv(lp_date,.T.) + " ORDER BY aa_date DESC")

SELECT &l_curAstat
IF aa_addrid = lp_addrid AND YEAR(aa_date) = YEAR(lp_date)
     SCATTER NAME l_oAstat
ELSE
     SCATTER NAME l_oAstat BLANK
     l_oAstat.aa_date = lp_date
     l_oAstat.aa_addrid = lp_addrid
ENDIF

SELECT &l_curHiststat
IF aa_addrid = lp_addrid AND YEAR(aa_date) = YEAR(lp_date)
     l_oAstat.aa_cres    = l_oAstat.aa_cres    + aa_cres
     l_oAstat.aa_cnights = l_oAstat.aa_cnights + aa_cnights
     l_oAstat.aa_cns     = l_oAstat.aa_cns     + aa_cns
     l_oAstat.aa_ccxl    = l_oAstat.aa_ccxl    + aa_ccxl
     l_oAstat.aa_camount = l_oAstat.aa_camount + aa_camount
     l_oAstat.aa_camt0   = l_oAstat.aa_camt0   + aa_camt0
     l_oAstat.aa_camt1   = l_oAstat.aa_camt1   + aa_camt1
     l_oAstat.aa_camt2   = l_oAstat.aa_camt2   + aa_camt2
     l_oAstat.aa_camt3   = l_oAstat.aa_camt3   + aa_camt3
     l_oAstat.aa_camt4   = l_oAstat.aa_camt4   + aa_camt4
     l_oAstat.aa_camt5   = l_oAstat.aa_camt5   + aa_camt5
     l_oAstat.aa_camt6   = l_oAstat.aa_camt6   + aa_camt6
     l_oAstat.aa_camt7   = l_oAstat.aa_camt7   + aa_camt7
     l_oAstat.aa_camt8   = l_oAstat.aa_camt8   + aa_camt8
     l_oAstat.aa_camt9   = l_oAstat.aa_camt9   + aa_camt9
     l_oAstat.aa_cvat0   = l_oAstat.aa_cvat0   + aa_cvat0
     l_oAstat.aa_cvat1   = l_oAstat.aa_cvat1   + aa_cvat1
     l_oAstat.aa_cvat2   = l_oAstat.aa_cvat2   + aa_cvat2
     l_oAstat.aa_cvat3   = l_oAstat.aa_cvat3   + aa_cvat3
     l_oAstat.aa_cvat4   = l_oAstat.aa_cvat4   + aa_cvat4
     l_oAstat.aa_cvat5   = l_oAstat.aa_cvat5   + aa_cvat5
     l_oAstat.aa_cvat6   = l_oAstat.aa_cvat6   + aa_cvat6
     l_oAstat.aa_cvat7   = l_oAstat.aa_cvat7   + aa_cvat7
     l_oAstat.aa_cvat8   = l_oAstat.aa_cvat8   + aa_cvat8
     l_oAstat.aa_cvat9   = l_oAstat.aa_cvat9   + aa_cvat9
ENDIF
DClose(l_curAstat)
DClose(l_curHiststat)

RETURN l_oAstat
ENDPROC
*
PROCEDURE PRGetCitwebRT
LPARAMETERS lp_cExtReserRT, lp_lDontCloseCursor
LOCAL l_cDeskRT, l_cCWData, l_nSelect
l_cDeskRT = ""

IF NOT EMPTY(lp_cExtReserRT)
	l_nSelect = SELECT()
	l_cDeskRT = lp_cExtReserRT
	IF NOT USED("curcwrt10")
		IF NOT EMPTY(_screen.oGlobal.oParam2.pa_ciwebdr)
			l_cCWData = ADDBS(ALLTRIM(_screen.oGlobal.oParam2.pa_ciwebdr))
			IF DIRECTORY(l_cCWData)
				IF openfiledirect(.F.,"virtrconn","",l_cCWData)
					SELECT vc_vroom, vc_room FROM virtrconn ORDER BY vc_vroom INTO CURSOR curcwrt10 NOFILTER
				ENDIF
			ENDIF
		ENDIF
	ENDIF
	IF USED("curcwrt10")
		IF dlocate("curcwrt10", "vc_vroom = " + sqlcnv(PADR(ALLTRIM(lp_cExtReserRT),3)))
			l_cDeskRT = curcwrt10.vc_room
		ENDIF
	ENDIF
	IF NOT lp_lDontCloseCursor
		dclose("virtrconn")
	ENDIF
	SELECT (l_nSelect)
ENDIF

RETURN l_cDeskRT
ENDPROC
*
PROCEDURE PRGetCitwebRC
LPARAMETERS lp_nServerID, lp_cExtReserRC, lp_cRoomType
LOCAL l_cDeskRC

IF NOT EMPTY(lp_cExtReserRC)
	l_cDeskRC = ALLTRIM(DLookUp("cwvrrt", "eq_channel = " + SqlCnv(lp_nServerID) + " AND eq_chvroom = " + SqlCnv(PADR(lp_cRoomType,3)) + " AND eq_rateid = " + SqlCnv(PADR(lp_cExtReserRC,16)), "eq_ratecod"))
ELSE
	l_cDeskRC = lp_cExtReserRC
ENDIF

RETURN l_cDeskRC
ENDPROC
*
&& PRImportExtreserPayment imports payments from Webbooking into Desk.
&& Reads payment from extoffer table and imports it into post table.
&& It is called from reservat.scx, when reservat.scx is called from extreser.scx.
PROCEDURE PRImportExtreserPayment
LPARAMETERS lp_cOfferId, lp_oReservatFormSet
LOCAL l_nPayNum

IF EMPTY(lp_cOfferId)
	RETURN .T.
ENDIF

IF VARTYPE(lp_oReservatFormSet)<>"O"
	RETURN .F.
ENDIF

IF NOT USED("extoffer") AND NOT openfile(.F.,"extoffer")
	RETURN .F.
ENDIF

IF NOT (SEEK(lp_cOfferId,"extoffer","tag2") AND extoffer.eo_paid AND NOT extoffer.eo_import AND NOT EMPTY(extoffer.eo_wbccafc))
	RETURN .F.
ENDIF

l_nPayNum = DLookUp("paymetho", "pm_wbccafc = "+SqlCnv(extoffer.eo_wbccafc,.T.), "pm_paynum")
IF EMPTY(l_nPayNum)
	l_nPayNum = 1
ENDIF

PBInsertPayment( ;
		reservat.rs_reserid, ;
		1, ;
		l_nPayNum, ;
		FNNextIdTemp("POST"), ;
		extoffer.eo_credit , ;
		"afc:" + ALLTRIM(extoffer.eo_chkoid) ;
		)
REPLACE eo_import WITH .T. IN extoffer

lp_oReservatFormSet.tform12.ebnoteco.Value = GetLangText("LEDGER","TXT_PAID_AMOUNT") + ": " + TRANSFORM(extoffer.eo_credit) + " (" + ALLTRIM(extoffer.eo_wbccafc) + ")"
lp_oReservatFormSet.tform12.ebnoteco.BackColor = RGB(255,128,128)

RETURN .T.
ENDPROC
*
&& PRCheckIsUserInSameBuildingAsReservation should send back true if user already loged in on system with same building as reservation
* Diese Procedure pr�ft ob der angemeldete User mit dem angemeldeten Geb�ude identisch ist mit dem Geb�ude vom aufgerufenen Zimmertyp
PROCEDURE PRCheckIsUserInSameBuildingAsReservation
LPARAMETERS lp_nReserId
LOCAL l_lSame, l_cRT, l_cBuilding, l_lBuildId

l_lSame = .F.

IF NOT g_lBuildings
	RETURN l_lSame
ENDIF

IF EMPTY(lp_nReserId)
	RETURN l_lSame
ENDIF

IF EMPTY(_screen.oGlobal.oBuilding.ccode)
	RETURN l_lSame
ENDIF

l_cRT = dlookup("reservat", "rs_reserid = " + sqlcnv(lp_nReserId,.T.),"rs_roomtyp")

l_lBuildId = .T.
l_cBuilding = GetBuilding('ROOMTYPE', l_cRT, l_lBuildId)

IF EMPTY(l_cBuilding)
	RETURN l_lSame
ENDIF

IF _screen.oGlobal.oBuilding.ccode == l_cBuilding
	l_lSame = .T.
ENDIF

RETURN l_lSame
ENDPROC
*
DEFINE CLASS ResGroupSplit AS privatesession
	GroupSplit = .NULL.
	Checkreservat = .NULL.
	Reserid = .NULL.
	PROCEDURE init
		LPARAMETERS lp_nDataSessionID
		DODEFAULT()
		IF TYPE("lp_nDataSession") = "N"
			this.DataSessionID = lp_nDataSessionID
		ENDIF
		this.GroupSplit = NEWOBJECT("cgroupsplit","cit_reservat.vcx")
		this.Checkreservat = CREATEOBJECT("checkreservat")
		openfile(.F., "ratecode")
		openfile(.F., "season")
		openfile(.F., "param")
		openfile(.F., "roomtype")
		openfile(.F., "address")
		this.Checkreservat.madjustenvironment()
		this.GroupSplit.Init(this.Checkreservat)
		this.Reserid = this.GroupSplit.oReserid
	ENDPROC
	PROCEDURE split
		LPARAMETERS lp_nReserid, lp_cResAlias, lp_lDontGetSplitRooms, lp_lSuppressQuestions
		RETURN this.GroupSplit.Split(lp_nReserid, lp_cResAlias, lp_lDontGetSplitRooms, lp_lSuppressQuestions)
	ENDPROC
	PROCEDURE addtosplit
		LPARAMETERS lp_nReserid, lp_oParamSet, lp_lAddPaymaster
		RETURN this.groupsplit.AddToSplit(lp_nReserid, lp_oParamSet, lp_lAddPaymaster)
	ENDPROC
ENDDEFINE
*
DEFINE CLASS resjetweb AS privatesession
	oJetWeb = .NULL.
	PROCEDURE init
		DODEFAULT()
		openfile(.F., "reservat")
		openfile(.F., "address")
		openfile(.F., "roomtype")
		openfile(.F., "jetweb")
		openfile(.F., "apartner")
		openfile(.F., "picklist")
		OpenFileDirect(,"address","saddress")
		this.oJetWeb = CREATEOBJECT("cjetweb")
		IF TYPE("this.oJetWeb") <> "O"
			RETURN .F.
		ENDIF
		RETURN .T.
	ENDPROC
	PROCEDURE createxml
		LPARAMETERS lp_nReserId, lp_nAction, lp_lGroup
		RETURN this.ojetweb.createxml(lp_nReserId, lp_nAction, lp_lGroup)
	ENDPROC
	PROCEDURE printmblatt
		LPARAMETERS lp_nReserId
		RETURN this.ojetweb.printmblatt(lp_nReserId)
	ENDPROC
	PROCEDURE savexmltofile
		LPARAMETERS lp_cFilename
		RETURN this.ojetweb.savexmltofile(lp_cFilename)
	ENDPROC
	PROCEDURE send
		LPARAMETERS lp_lDone, lp_cError
		RETURN this.ojetweb.send(@lp_lDone, @lp_cError)
	ENDPROC
	PROCEDURE GetVersion
		RETURN this.oJetWeb.GetVersion()
	ENDPROC
	PROCEDURE SetMode
		LPARAMETERS lp_cIniFile
		RETURN this.oJetWeb.SetMode(lp_cIniFile)
	ENDPROC
	PROCEDURE Destroy
		this.oJetweb = .NULL.
	ENDPROC
ENDDEFINE
*
DEFINE CLASS cquickreser AS cbobj OF commonclasses.prg
*
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS cquickreser OF commonclasses.prg
#ENDIF
*
DataSession = 2
ocheckreser = .NULL.
cOneResCur = ""
oMarketCodesCbo = .NULL.
oSourceCodesCbo = .NULL.
oRoomsCbo = .NULL.

oRoomTypesCnt = .NULL.
oRateCodeCbo = .NULL.
cbuildingscur = ""
croomtypecur = ""
croomcur = ""
cratecodecur = ""
ccurresstatus = ""
cmarketcodecur = ""
csourcecodecur = ""
ccurtitles = ""
ccurcountries = ""
croomrangecur = ""
ccurpaymethods = ""
ccurroomplan = ""
cletterscur = ""
ccurstyles = ""
lShowMessages = .T.

cchild1on = "0"
cchild1caption = ""
cchild2on = "0"
cchild2caption = ""
cchild3on = "0"
cchild3caption = ""

cbuildingson = "0"

csourcerequired = "0"
cmarketrequired = "0"
cpaytyperequired = "0"

cerrtext = ""
cerrfield = ""
cbuilding = ""
cEmailUserField = ""

*
PROCEDURE Init
LOCAL l_cIniFile
DODEFAULT()
this.UseTables()

this.lShowMessages = NOT g_lAutomationMode
l_cIniFile = FULLPATH(INI_FILE)

this.cOneResCur = SYS(2015)
this.cbuildingscur = SYS(2015)
this.croomtypecur = SYS(2015)
this.croomcur = SYS(2015)
this.cratecodecur = SYS(2015)
this.ccurresstatus = SYS(2015)
this.cmarketcodecur = SYS(2015)
this.csourcecodecur = SYS(2015)
this.ccurtitles = SYS(2015)
this.ccurcountries = SYS(2015)
this.croomrangecur = SYS(2015)
this.cletterscur = SYS(2015)
this.ccurstyles = SYS(2015)
this.cListCur = SYS(2015)
this.ccurpaymethods = SYS(2015)
this.ocheckreser = CREATEOBJECT("checkreservat")
this.ocheckreser.plmessage = this.lShowMessages
this.ocheckreser.plapplygroupchanges = .F.
this.cbuildingson = IIF(g_lBuildings,"1","0")
this.oRoomTypesCnt = CREATEOBJECT("Container")
this.SetChilds()

this.csourcerequired = IIF(NOT _screen.oGlobal.oParam.pa_nosour,"1","0")
this.cmarketrequired = IIF(NOT _screen.oGlobal.oParam.pa_nomark,"1","0")
this.cpaytyperequired = IIF(_screen.oGlobal.oParam.pa_chkpay,"1","0")
this.cEmailUserField = ALLTRIM(readini(l_cIniFile, "citadelwebserver","emailuserfield", "rs_usrres0"))
IF EMPTY(this.cEmailUserField)
	this.cEmailUserField = "rs_usrres0"
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE ListGet
LPARAMETERS lp_dFrom, lp_dTo, lp_cStatus
LOCAL l_cSql, l_cWhere, l_lSuccess
l_lSuccess = .F.
l_cWhere = ""

IF EMPTY(lp_dFrom) AND EMPTY(lp_dTo)
     IF odbc()
          l_cWhere = sqlwhere(l_cWhere,"rs_depdate >= " + sqlcnv(g_sysdate,.T.))
     ELSE
          l_cWhere = sqlwhere(l_cWhere,"DTOS(rs_depdate)+rs_roomnum >= " + sqlcnv(DTOS(g_sysdate)))
     ENDIF
ELSE
     IF NOT EMPTY(lp_dFrom)
          PRIVATE p_dFrom
          IF odbc()
               p_dFrom = lp_dFrom
               l_cWhere = sqlwhere(l_cWhere,"rs_arrdate >= __SQLPARAM__p_dFrom")
          ELSE
               p_dFrom = DTOS(lp_dFrom)
               l_cWhere = sqlwhere(l_cWhere,"DTOS(rs_arrdate)+rs_lname >= __SQLPARAM__p_dFrom")
          ENDIF
     ENDIF
     IF NOT EMPTY(lp_dTo)
          PRIVATE p_dTo
          IF odbc()
               p_dTo = lp_dTo
               l_cWhere = sqlwhere(l_cWhere,"rs_arrdate <= __SQLPARAM__p_dTo")
          ELSE
               p_dTo = DTOS(lp_dTo)
               l_cWhere = sqlwhere(l_cWhere,"DTOS(rs_arrdate)+rs_lname <= __SQLPARAM__p_dTo")
          ENDIF
     ENDIF
ENDIF

IF EMPTY(lp_cStatus)
     l_cWhere = sqlwhere(l_cWhere,"NOT rs_status IN ('NS ','CXL')")
ELSE
     PRIVATE p_cStatus
     p_cStatus = PADR(ALLTRIM(lp_cStatus),3)
     l_cWhere = sqlwhere(l_cWhere,"rs_status = __SQLPARAM__p_cStatus")
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT DISTINCT TOP 100 rs_rsid, rs_reserid, rs_arrdate, rs_depdate, rs_rooms, rd_roomtyp, rs_rmname, rs_adults+rs_childs+rs_childs2+rs_childs3 AS rs_persons, 
     rs_roomtyp, rs_status, CAST(0 AS Integer) AS rs_ratecfc, rs_ratecod, rs_rate, 
     CAST(IIF(NVL(dc_reserid,0)=0,'','*')+IIF(rs_addrid = param2.pa_defadri,'!','')+rs_lname AS Char(31)) AS rs_lname, rs_company, rs_group, rs_groupid, 
     CAST(IIF(rs_addrid = param2.pa_defadri,<<this.cEmailUserField>>,NVL(ad_addrid,'')) AS Char(100)) AS c_email, 
     rs_noaddr 
     FROM reservat 
     INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp 
     INNER JOIN rtypedef ON rt_rdid = rd_rdid 
     INNER JOIN param2 ON 1=1 
     LEFT JOIN address ON rs_addrid = ad_addrid 
     LEFT JOIN document ON rs_reserid = dc_reserid 
     <<l_cWhere>> 
     ORDER BY rs_arrdate, rs_group, rs_lname 
ENDTEXT
sqlcursor(l_cSql,this.cListCur,,,,,,.T.)

SELECT (this.cListCur)
SCAN
     lnColor = IIF(EMPTY(rs_groupid), 0, DLookUp("groupres", "gr_groupid = " + SqlCnv(rs_groupid,.T.), "gr_color"))
     lnColor = ProcRatecode("GetRatecodeColor", this.cListCur, lnColor)
     REPLACE rs_ratecfc WITH lnColor IN (this.cListCur)
ENDSCAN
IF USED(this.cListCur)
     l_lSuccess = .T.
     this.Export(this.cListCur)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE RecGet
LPARAMETERS lp_nId
LOCAL l_lSuccess, l_lNew, l_oData, l_nRsId
this.CheckCa()
IF EMPTY(lp_nId)
     l_lNew = .T.
ELSE
     l_nRsId = lp_nId
ENDIF
SELECT reservat
IF l_lNew
     APPEND BLANK
     SCATTER NAME l_oData MEMO
     l_oData.rs_arrdate = sysdate()
     l_oData.rs_depdate = sysdate()+1
     l_oData.rs_rsid = NextId('RESUNQID')
     l_oData.rs_reserid = nextid('RESERVAT')+0.100
     l_oData.rs_created = sysdate()
     l_oData.rs_updated = sysdate()
     l_oData.rs_userid = g_userid
     l_oData.rs_rooms = 1
     l_oData.rs_adults = this.ocheckreser.GetNewAdults(l_oData.rs_roomnum, l_oData.rs_roomtyp,,0)
     l_oData.rs_status = "DEF"
     l_oData.rs_market = _screen.oglobal.oparam2.pa_defmark
     l_oData.rs_source = _screen.oglobal.oparam2.pa_defsour
     IF SEEK(_screen.oglobal.oparam2.pa_defadri,"address","tag1")
          l_oData.rs_addrid = address.ad_addrid
          l_oData.rs_compid = address.ad_addrid
          l_oData.rs_noaddr = .T.
          l_oData.rs_country = address.ad_country
     ENDIF
     ADDPROPERTY(l_oData,"c_email","")
     ADDPROPERTY(l_oData,"c_buildng","")
     GATHER NAME l_oData MEMO
     l_lSuccess = .T.
ELSE
     l_lSuccess = SEEK(l_nRsId,"reservat","tag33")
     SCATTER NAME l_oData MEMO
     ADDPROPERTY(l_oData,"c_email","")
     IF rs_noaddr
          l_oData.c_email = ALLTRIM(EVALUATE(this.cEmailUserField))
     ELSE
          l_oData.c_email = ALLTRIM(dlookup("address","ad_addrid = " + sqlcnv(rs_addrid,.T.),"ad_email"))
     ENDIF
     ADDPROPERTY(l_oData,"c_buildng",dlookup("roomtype", "rt_roomtyp = " + sqlcnv(l_oData.rs_roomtyp, .T.), "rt_buildng"))
ENDIF
IF l_lSuccess
     SELECT reservat
     SCATTER NAME this.ocheckreser.CurrRes MEMO
     SELECT *, CAST('' AS Char(200)) AS c_rareason, CAST('' AS Char(100)) AS c_email, CAST('' AS Char(3)) AS c_buildng FROM reservat WHERE 0=1 INTO CURSOR (this.cOneResCur) READWRITE
     INSERT INTO (this.cOneResCur) FROM NAME l_oData
     this.Export(this.cOneResCur)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE RecReload
LPARAMETERS lp_cOneResCur
LOCAL l_lSuccess

DO CASE
     CASE TYPE("this.ocheckreser.CurrRes.rs_reserid") = "N" AND NOT EMPTY(this.ocheckreser.CurrRes.rs_reserid)
          l_lSuccess = .T.
     CASE NOT EMPTY(lp_cOneResCur)
          this.cOneResCur = lp_cOneResCur
          this.Import(this.cOneResCur)
          IF USED(this.cOneResCur)
               SCATTER NAME this.ocheckreser.CurrRes MEMO
               l_lSuccess = .T.
               this.Export(this.cOneResCur)
          ENDIF
     OTHERWISE
ENDCASE
IF l_lSuccess AND NOT SEEK(this.ocheckreser.CurrRes.rs_rsid,"reservat","tag33")
     INSERT INTO reservat FROM NAME this.ocheckreser.CurrRes
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE RecSave
LOCAL l_lSuccess, l_cCur, l_oMyData, l_nErrorCode, l_oNewData, l_oRAData, l_cMessage, l_lRateValid, l_cMacro
l_cCur = this.cOneResCur
this.CheckCa()
this.lvaliderr = .F.
this.cvaliderr = ""
l_lSuccess = .T.
this.Import(this.cOneResCur)

this.cerrfield = ""
this.cvaliderr = ""

this.ocheckreser.plmessage = this.lShowMessages
l_oMyData = this.ocheckreser.CurrRes

SELECT (l_cCur)
SCATTER NAME l_oNewData MEMO
IF rs_rsid <> l_oMyData.rs_rsid
     this.cvaliderr = GetLangText("BILL","T_NOTVALIDFIELDS") + " (rs_rsid): " + TRANSFORM(rs_rsid)
     this.lvaliderr = .T.
     l_lSuccess = .F.
ENDIF
IF l_lSuccess AND rs_reserid <> l_oMyData.rs_reserid
     this.cvaliderr = GetLangText("BILL","T_NOTVALIDFIELDS") + " (rs_reserid): " + TRANSFORM(rs_reserid)
     this.lvaliderr = .T.
     l_lSuccess = .F.
ENDIF
IF l_lSuccess AND rs_addrid <> l_oMyData.rs_addrid
     this.cvaliderr = GetLangText("BILL","T_NOTVALIDFIELDS") + " (rs_addrid): " + TRANSFORM(rs_addrid)
     this.lvaliderr = .T.
     l_lSuccess = .F.
ENDIF
IF l_lSuccess AND rs_compid <> l_oMyData.rs_compid
     this.cvaliderr = GetLangText("BILL","T_NOTVALIDFIELDS") + " (rs_compid): " + TRANSFORM(rs_compid)
     this.lvaliderr = .T.
     l_lSuccess = .F.
ENDIF
IF l_lSuccess AND EMPTY(rs_lname)
     this.cvaliderr = GetLangText("BILL","T_NOTVALIDFIELDS") + " " + GetLangText("GROUP","TXT_GUEST_NAME")
     this.lvaliderr = .T.
     this.cerrfield = "RS_LNAME"
     l_lSuccess = .F.
ENDIF

SELECT reservat
IF l_lSuccess AND NOT SEEK(l_oNewData.rs_rsid,"reservat","tag33")
     this.cvaliderr = "Unknown rs_rsid"
     this.lvaliderr = .T.
     l_lSuccess = .F.
ENDIF

IF l_lSuccess
     * fill resaddr
     IF NOT SEEK(l_oNewData.rs_reserid,"resaddr","tag2")
          SELECT resaddr
          SCATTER NAME l_oRAData BLANK
          l_oRAData.rg_rgid = nextid("RESADDR")
          l_oRAData.rg_reserid = l_oNewData.rs_reserid
          l_oRAData.rg_country = l_oNewData.rs_country
          l_oRAData.rg_title = l_oNewData.rs_title
          l_oRAData.rg_lname = l_oNewData.rs_lname
          l_oRAData.rg_fname = l_oNewData.rs_fname
          l_oRAData.rg_fromday = 1
          l_oRAData.rg_today = MAX(l_oNewData.rs_depdate - l_oNewData.rs_arrdate + 1,1)
          INSERT INTO resaddr FROM NAME l_oRAData
     ENDIF

     l_oNewData.rs_lname = UPPER(l_oNewData.rs_lname)
     l_oNewData.rs_company = UPPER(l_oNewData.rs_company)
     IF l_oNewData.rs_noaddr
          * When quick reservation, save address e-mail into reservat user field
          l_cMacro = "l_oNewData."+this.cEmailUserField
          &l_cMacro = l_oNewData.c_email
     ENDIF
     SELECT reservat
     GATHER NAME l_oNewData MEMO
     l_cMessage = ""

     this.ocheckreser.rs_rooms_change(,l_oMyData.rs_rooms)

     l_nErrorCode = this.ocheckreser.CheckSubReserData(.F., .F., "", @l_cMessage)
     IF reservat.rs_rate <> l_oNewData.rs_rate
          * CheckSubReserData changed rate, we set it back
          REPLACE reservat.rs_rate WITH l_oNewData.rs_rate IN reservat
     ENDIF
     IF l_nErrorCode = 0
          l_lRateValid = .T.
          * Check ratecode

          IF l_oMyData.rs_ratecod <> l_oNewData.rs_ratecod
               this.ocheckreser.ChangeRateCode()
          ELSE
               IF l_oMyData.rs_rate <> l_oNewData.rs_rate
                    * User manualy changed rate
                    l_uRetVal = this.ocheckreser.CheckRate(l_oNewData.rs_rate,l_oNewData.rs_reserid,,l_oNewData.c_rareason)
                    IF VARTYPE(l_uRetVal)="L" AND l_uRetVal = .T.
                         this.ocheckreser.ChangeRate()
                         l_lRateValid = .T.
                    ELSE
                         l_lRateValid = .F.
                    ENDIF
               ENDIF
          ENDIF

          IF l_lRateValid
               this.ocheckreser.lResrateUpdateFromReservat = .T.
               l_nErrorCode = this.ocheckreser.CheckAndSave("reservat", .T.)
               this.ocheckreser.lResrateUpdateFromReservat = .F.

               IF l_nErrorCode < 0
                    l_lSuccess = .F.
               ELSE
                    * Refresh saved reservation in cursor and scatter property
                    SELECT reservat
                    SCATTER NAME this.ocheckreser.CurrRes MEMO
                    SELECT (this.cOneResCur)
                    GATHER NAME this.ocheckreser.CurrRes MEMO
                    REPLACE c_rareason WITH ""
                    SELECT reservat
               ENDIF
          ELSE
               l_nErrorCode = 9
               l_lSuccess = .F.
          ENDIF
     ELSE
          l_lSuccess = .F.
     ENDIF
     IF l_lSuccess
          this.cerrfield = ""
          this.cvaliderr = ""
     ELSE
          this.lvaliderr = .T.
          * Get error message
          DO CASE
               CASE NOT EMPTY(l_cMessage)
                    this.cvaliderr = l_cMessage
               CASE NOT EMPTY(this.ocheckreser.clasterror)
                    this.cvaliderr = this.ocheckreser.clasterror
               CASE NOT EMPTY(_screen.oglobal.cmsglast)
                    this.cvaliderr = _screen.oglobal.cmsglast
               OTHERWISE
                    this.cvaliderr = "Error code:" + TRANSFORM(l_nErrorCode)
          ENDCASE
          DO CASE
               CASE l_nErrorCode = 3
                    this.cerrfield = "RS_ROOMTYP"
               CASE l_nErrorCode = 4
                    this.cerrfield = "RS_ROOMS"
               CASE l_nErrorCode = 5
                    this.cerrfield = "RS_ADULTS"
               CASE l_nErrorCode = 6
                    this.cerrfield = "RS_RATECOD"
               CASE l_nErrorCode = 7
                    this.cerrfield = "RS_STATUS"
               CASE l_nErrorCode = 8
                    this.cerrfield = "RS_ROOMNUM"
               CASE l_nErrorCode = -5
                    this.cerrfield = "RS_SOURCE"
               CASE l_nErrorCode = -4
                    this.cerrfield = "RS_MARKET"
               CASE l_nErrorCode = 9
                    this.cerrfield = "RS_RATE"
               OTHERWISE
                    this.cerrfield = ""
          ENDCASE
     ENDIF
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE ResCheckIn
LPARAMETERS lp_nRsId
LOCAL l_lSuccess, l_cMessage

IF DLocate("reservat", "rs_rsid = " + SqlCnv(lp_nRsId,.T.))
     l_lSuccess = CheckIn(this.ocheckreser, .T., @l_cMessage)
     IF l_lSuccess
          this.cvaliderr = ""
     ELSE
          this.lvaliderr = .T.
          * Get error message
          DO CASE
               CASE NOT EMPTY(l_cMessage)
                    this.cvaliderr = l_cMessage
               CASE NOT EMPTY(this.ocheckreser.clasterror)
                    this.cvaliderr = this.ocheckreser.clasterror
               CASE NOT EMPTY(_screen.oglobal.cmsglast)
                    this.cvaliderr = _screen.oglobal.cmsglast
               OTHERWISE
          ENDCASE
     ENDIF
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE BuildingsGet
IF this.cbuildingson = "1"
     IF TYPE("this.oRoomTypesCnt.oRoomTypesCbo")<>"O"
          this.oRoomTypesCnt.NewObject("oRoomTypesCbo","cbo_rs_roomtyp","libs\cit_ctrl.vcx")
     ENDIF
     SELECT * FROM (this.oRoomTypesCnt.oRoomTypesCbo.oBuildingCombo.ccursor) WHERE NOT EMPTY(bu_buildng) INTO CURSOR (this.cbuildingscur)
     this.Export(this.cbuildingscur)
ENDIF
ENDPROC
*
PROCEDURE RoomTypesGet
LPARAMETERS lp_cBuBuilding
LOCAL l_cBuilding, l_cSql, l_cJoin, l_cWhere 

IF NOT EMPTY(lp_cBuBuilding)
     this.cbuilding = lp_cBuBuilding
ENDIF

l_cJoin = ""
l_cWhere = "1=1"
l_cBuilding = DLookUp("building", "bu_buildng = " + SqlCnv(this.cbuilding,.T.), "bu_buildng")
DO CASE
     CASE g_lShips
          l_cJoin = "LEFT JOIN altsplit ON as_roomtyp = rt_roomtyp"
          l_cBuilding = DLookUp("althead", "al_altid = " + SqlCnv(reservat.rs_altid,.T.), "al_buildng")
          l_cWhere = "rt_paymstr OR as_altid = " + SqlCnv(reservat.rs_altid,.T.)
     CASE this.cbuildingson = "1"
          l_cJoin = "INNER JOIN building ON (bu_buildng = rt_buildng AND NOT bu_buildng='   ') OR rt_paymstr "
     OTHERWISE
ENDCASE
IF NOT EMPTY(l_cBuilding)
     l_cWhere = l_cWhere + " AND rt_buildng = " + SqlCnv(PADR(l_cBuilding,4))
ENDIF
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT rt_roomtyp, rt_buildng, rt_lang<<g_langnum>> AS rt_lang, rt_group, rt_sequenc, rd_roomtyp, ;
     CAST(RTRIM(rd_roomtyp)__||__' '__||__rt_buildng AS Char(14)) AS rt_rttype, ;
     STR(rt_group,1)+STR(rt_sequenc,2) AS rt_key FROM roomtype ;
     LEFT JOIN rtypedef ON rd_rdid = rt_rdid
     <<l_cJoin>>
     WHERE <<l_cWhere>>
     ORDER BY rt_key, rt_rttype
ENDTEXT
sqlcursor(l_cSql,this.croomtypecur,,,,.t.)
this.Export(this.croomtypecur)
RETURN .T.
ENDPROC
*
PROCEDURE RoomsGet
LPARAMETERS lp_cRoomType, lp_dArrDate, lp_dDepDate
LOCAL l_lSuccess, l_dArrDate, l_dDepDate, l_nRecNo, l_croomcur, l_cRoomNum, l_nReserId, l_oResRooms1, l_oResRooms2

l_dArrDate = lp_dArrDate
l_dDepDate = lp_dDepDate
IF NOT EMPTY(lp_cRoomType) AND NOT EMPTY(l_dArrDate) AND NOT EMPTY(l_dDepDate) AND ;
          TYPE("this.ocheckreser.CurrRes.rs_reserid") = "N" AND NOT EMPTY(this.ocheckreser.CurrRes.rs_reserid)
     l_nRecNo = RECNO("reservat")
     lp_cRoomType = TRANSFORM(lp_cRoomType)
     lp_cRoomType = ALLTRIM(lp_cRoomType)
     lp_cRoomType = PADR(lp_cRoomType,4)
     IF reservat.rs_roomtyp <> lp_cRoomType
          REPLACE rs_roomtyp WITH lp_cRoomType IN reservat
     ENDIF
     IF reservat.rs_arrdate <> l_dArrDate
          REPLACE rs_arrdate WITH l_dArrDate IN reservat
     ENDIF
     IF reservat.rs_depdate <> l_dDepDate
          REPLACE rs_depdate WITH l_dDepDate IN reservat
     ENDIF
     
     l_croomcur = sqlcursor("SELECT * FROM room WHERE 0=1",,,,,,,.T.)
     INSERT INTO (l_croomcur) FROM ARRAY _screen.oGLOBAL.ogData.aroomcur
     APPEND BLANK
     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
     SELECT <<l_croomcur>>.*, rm_lang<<g_langnum>> AS rm_lang, NVL(ALLTRIM(rd_roomtyp)+[ ]+rt_buildng,SPACE(1)) AS rm_rmtype, [ ] AS rm_free FROM <<l_croomcur>>
          LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp
          LEFT JOIN rtypedef ON rd_rdid = rt_rdid
          WHERE rm_roomnum = '    ' OR rm_roomtyp = '<<lp_cRoomType>>'
          ORDER BY rm_rmname
     ENDTEXT
     sqlcursor(l_cSql,this.croomcur,,,,,,.T.)

     l_nReserId = reservat.rs_reserid
     l_dArrDate = MAX(SysDate(),reservat.rs_arrdate)
     RiGetRoom(reservat.rs_reserid, l_dArrDate, @l_oResRooms1, @l_oResRooms2)

     l_dDepDate = {}
     IF NOT (ISNULL(l_oResRooms1) OR ISNULL(l_oResRooms2) OR l_oResRooms1.ri_rroomid = l_oResRooms2.ri_rroomid)
          l_dDepDate = l_oResRooms2.ri_date-1
     ENDIF
     IF EMPTY(l_dDepDate)
          l_dDepDate = MAX(reservat.rs_arrdate, reservat.rs_depdate-1)
     ENDIF

     SELECT (this.croomcur)
     SCAN FOR INLIST(rm_status, "CLN", "DIR") OR NOT param.pa_rmstat OR l_dArrDate <> g_sysdate
          l_cRoomNum = rm_roomnum
          SELECT roomplan
          LOCATE FOR rp_roomnum = l_cRoomNum AND BETWEEN(rp_date, l_dArrDate, l_dDepDate) AND rp_reserid <> l_nReserId AND ;
               (rp_nights > 0 OR SEEK(rp_reserid, "reservat", "Tag1") AND NOT INLIST(reservat.rs_status, "OUT", "NS", "CXL"))
          SELECT (this.croomcur)
          IF FOUND("roomplan")
               REPLACE rm_free WITH "*"
          ENDIF
     ENDSCAN
     GO l_nRecNo IN reservat

     this.Export(this.croomcur)
     l_lSuccess = .T.
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE RateCodesGet
LPARAMETERS lp_cRoomType, lp_dArrDate, lp_dDepDate, lp_cValue
LOCAL l_lSuccess, l_cSql, l_dArrDate, l_dDepDate, l_dCurrentResDate, l_cValue

l_dArrDate = lp_dArrDate
l_dDepDate = lp_dDepDate
IF NOT EMPTY(lp_cRoomType) AND NOT EMPTY(l_dArrDate) AND NOT EMPTY(l_dDepDate) AND ;
          TYPE("this.ocheckreser.CurrRes.rs_reserid") = "N" AND NOT EMPTY(this.ocheckreser.CurrRes.rs_reserid)
     lp_cRoomType = TRANSFORM(lp_cRoomType)
     lp_cRoomType = ALLTRIM(lp_cRoomType)
     lp_cRoomType = PADR(lp_cRoomType,4)
     IF reservat.rs_roomtyp <> lp_cRoomType
          REPLACE rs_roomtyp WITH lp_cRoomType IN reservat
     ENDIF
     IF reservat.rs_arrdate <> l_dArrDate
          REPLACE rs_arrdate WITH l_dArrDate IN reservat
     ENDIF
     IF reservat.rs_depdate <> l_dDepDate
          REPLACE rs_depdate WITH l_dDepDate IN reservat
     ENDIF
     
     l_dCurrentResDate = MIN(reservat.rs_depdate, MAX(reservat.rs_arrdate, SysDate()))
     IF EMPTY(reservat.rs_altid)
          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
               SELECT rc_ratecod+[ ] AS rs_ratecod, rc_ratecod, rc_amnt1, rc_amnt2, rc_lang<<g_langnum>> AS rc_lang, 
                    rc_roomtyp, rc_fromdat, rc_todat, rc_season, rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season AS rc_rckey, 
                    CAST(IIF(ISNULL(rd_roomtyp), "*", ALLTRIM(rd_roomtyp)+[ ]+rt_buildng) AS Char(12)) AS rc_rttype FROM ratecode 
                    LEFT JOIN roomtype ON rt_roomtyp = rc_roomtyp 
                    LEFT JOIN rtypedef ON rd_rdid = rt_rdid 
                    WHERE INLIST(rc_roomtyp, [*], <<SqlCnv(reservat.rs_roomtyp)>>) AND 
                    BETWEEN(<<SqlCnv(l_dCurrentResDate)>>, rc_fromdat, rc_todat - 1) AND 
                    <<SqlCnv(DLookUp("season", "se_date = " + SqlCnv(l_dCurrentResDate), "se_season"))>> = ALLTRIM(rc_season) AND 
                    rc_minstay <= <<SqlCnv(reservat.rs_depdate - reservat.rs_arrdate)>> AND NOT rc_inactiv
                    UNION SELECT [], [], 0, 0, [], [], {}, {}, [], [], [] FROM PARAM
                    ORDER BY 2, 6 DESC, 9 DESC, 7 DESC
          ENDTEXT
     ELSE
          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
               SELECT rcc.*, rc_lang<<g_langnum>> AS rc_lang, rc_roomtyp, rc_fromdat, rc_todat, rc_season, ratecode.rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season AS rc_rckey, 
                    CAST(IIF(ISNULL(rd_roomtyp), "*", ALLTRIM(rd_roomtyp)+[ ]+rt_buildng) AS Char(12)) AS rc_rttype FROM ( 
                    SELECT rc_ratecod+[ ] AS rs_ratecod, rc_ratecod, rc_amnt1, rc_amnt2 FROM ratecode 
                         UNION SELECT [!]+as_ratecod, as_ratecod, as_rate1, as_rate2 FROM altsplit 
                         WHERE PADR(as_altid,8)+DTOS(as_date)+as_roomtyp+as_ratecod = <<SqlCnv(PADR(reservat.rs_altid,8)+DTOS(l_dCurrentResDate)+reservat.rs_roomtyp)>>) rcc 
                    LEFT JOIN ratecode ON ratecode.rc_ratecod = rcc.rc_ratecod 
                    LEFT JOIN roomtype ON rt_roomtyp = rc_roomtyp 
                    LEFT JOIN rtypedef ON rd_rdid = rt_rdid 
                    WHERE INLIST(rc_roomtyp, [*], <<SqlCnv(rs_roomtyp)>>) AND 
                    BETWEEN(<<SqlCnv(l_dCurrentResDate)>>, rc_fromdat, rc_todat - 1) AND 
                    <<SqlCnv(DLookUp("season", "se_date = " + SqlCnv(l_dCurrentResDate), "se_season"))>> = ALLTRIM(rc_season) AND 
                    rc_minstay <= <<SqlCnv(rs_depdate - rs_arrdate)>> AND NOT rc_inactiv
                    UNION SELECT [], [], 0, 0, [], [], {}, {}, [], [], [] FROM PARAM
                    ORDER BY 2, 6 DESC, 9 DESC, 7 DESC
          ENDTEXT
     ENDIF
     sqlcursor(l_cSql,this.cratecodecur,,,,,,.T.)
     IF NOT EMPTY(lp_cValue)
          SELECT (this.cratecodecur)
          l_cValue = PADR(ALLTRIM(lp_cValue),11)
          LOCATE FOR rs_ratecod == l_cValue
          IF NOT FOUND()
               INSERT INTO (this.cratecodecur) (rs_ratecod, rc_ratecod) VALUES (l_cValue, l_cValue)
          ENDIF
     ENDIF
     this.Export(this.cratecodecur)
     l_lSuccess = .T.
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE RateGet
LPARAMETERS lp_dArrDate, lp_dDepDate, lp_cRoomType, lp_nAdults, lp_nChild1, lp_nChild2, lp_nChild3, lp_cRateCode
LOCAL l_nRate
l_nRate = 0.00
IF NOT EMPTY(lp_dArrDate) AND NOT EMPTY(lp_dDepDate) AND NOT EMPTY(lp_cRoomType) AND ;
          NOT EMPTY(lp_nAdults) AND NOT EMPTY(lp_cRateCode) AND ;
          TYPE("this.ocheckreser.CurrRes.rs_reserid") = "N" AND NOT EMPTY(this.ocheckreser.CurrRes.rs_reserid)
     lp_cRoomType = TRANSFORM(lp_cRoomType)
     lp_cRoomType = ALLTRIM(lp_cRoomType)
     lp_cRoomType = PADR(lp_cRoomType,4)

     IF reservat.rs_arrdate <> lp_dArrDate
          REPLACE rs_arrdate WITH lp_dArrDate IN reservat
     ENDIF
     IF reservat.rs_depdate <> lp_dDepDate
          REPLACE rs_depdate WITH lp_dDepDate IN reservat
     ENDIF
     IF reservat.rs_roomtyp <> lp_cRoomType
          REPLACE rs_roomtyp WITH lp_cRoomType IN reservat
     ENDIF
     IF reservat.rs_adults <> lp_nAdults
          REPLACE rs_adults WITH lp_nAdults IN reservat
     ENDIF
     IF reservat.rs_childs <> lp_nChild1
          REPLACE rs_childs WITH lp_nChild1 IN reservat
     ENDIF
     IF reservat.rs_childs2 <> lp_nChild2
          REPLACE rs_childs2 WITH lp_nChild2 IN reservat
     ENDIF
     IF reservat.rs_childs3 <> lp_nChild3
          REPLACE rs_childs3 WITH lp_nChild3 IN reservat
     ENDIF
     IF reservat.rs_ratecod <> lp_cRateCode
          REPLACE rs_ratecod WITH lp_cRateCode IN reservat
     ENDIF
     IF this.ocheckreser.rs_ratecod_valid(reservat.rs_ratecod, "reservat")
          this.ocheckreser.RateCalculate()
     ENDIF

     l_nRate = reservat.rs_rate
ENDIF

RETURN l_nRate
ENDPROC
*
PROCEDURE SourceCodesGet
LOCAL l_cSql

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT pl_charcod, pl_lang<<g_langnum>> AS pl_lang 
     FROM picklist 
     WHERE pl_label = 'SOURCE    ' AND NOT pl_inactiv 
     ORDER BY 1
ENDTEXT
sqlcursor(l_cSql, this.csourcecodecur)

this.Export(this.csourcecodecur)

RETURN .T.
ENDPROC
*
PROCEDURE MarketCodesGet
LOCAL l_cSql

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT pl_charcod, pl_lang<<g_langnum>> AS pl_lang 
     FROM picklist 
     WHERE pl_label = 'MARKET    ' AND NOT pl_inactiv 
     ORDER BY 1
ENDTEXT
sqlcursor(l_cSql, this.cmarketcodecur)

this.Export(this.cmarketcodecur)

RETURN .T.
ENDPROC
*
PROCEDURE ResStatusGet
LOCAL l_cSql
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT pl_charcod, pl_lang FROM 
(
SELECT pl_charcod,  <<"pl_lang" + g_langnum>> AS pl_lang, pl_sequ FROM picklist WHERE pl_label = <<SqlCnv("RESSTATUS",.T.)>> 
     UNION SELECT 'IN ' AS pl_charcod, 'In                      ' AS pl_lang, 90 as pl_sequ FROM param 
     UNION SELECT 'OUT' AS pl_charcod, 'Out                     ' AS pl_lang, 91 as pl_sequ FROM param 
     UNION SELECT 'NS ' AS pl_charcod, 'No-Show                 ' AS pl_lang, 92 as pl_sequ FROM param 
     UNION SELECT 'CXL' AS pl_charcod, 'Canceled                ' AS pl_lang, 93 as pl_sequ FROM param 
     UNION SELECT '   ' AS pl_charcod, '                        ' AS pl_lang, 0 as pl_sequ FROM param 
     ORDER BY pl_sequ
) c1
ENDTEXT
sqlcursor(l_cSql,this.ccurresstatus)
this.Export(this.ccurresstatus)
RETURN .T.
ENDPROC
*
PROCEDURE TitlesGet
LPARAMETERS lp_lAll
LOCAL l_cWhere
IF lp_lAll
     l_cWhere = "ti_title <> '" + SPACE(25)+ "'"
ELSE
     l_cWhere = "ti_lang = " + sqlcnv(g_Language,.T.)
ENDIF
LOCAL l_cSql
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT ti_titlcod, ti_title, ti_salute, ti_lang, CAST(IIF(ti_lang= 'GER','AAA',ti_lang) AS Char(3)) AS c_lang 
     FROM title 
     WHERE <<l_cWhere>> 
     UNION 
     SELECT 00 AS ti_titlcod, '<<SPACE(25)>>' AS ti_title, '<<SPACE(50)>>' AS ti_salute, '   ' AS ti_lang, '   ' AS c_lang 
     FROM param 
     ORDER BY c_lang,ti_titlcod
ENDTEXT
sqlcursor(l_cSql,this.ccurtitles)
this.Export(this.ccurtitles)
ENDPROC
*
PROCEDURE CountriesGet
LOCAL l_cSql
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT pl_charcod, pl_lang<<g_langnum>> AS pl_lang 
     FROM picklist 
     WHERE pl_label = 'COUNTRY   ' AND NOT pl_inactiv 
     UNION 
     SELECT '', '' AS pl_lang 
     FROM param 
     ORDER BY 2
ENDTEXT
sqlcursor(l_cSql,this.ccurcountries)
this.Export(this.ccurcountries)
RETURN .T.
ENDPROC
*
PROCEDURE ConfRoomRangesGet
LOCAL l_cSql

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT pl_charcod, pl_lang<<g_langnum>> AS pl_lang 
     FROM picklist 
     WHERE pl_label = 'CONFRANG  ' 
     UNION 
     SELECT '', '' AS pl_lang 
     FROM param 
     ORDER BY 1
ENDTEXT
sqlcursor(l_cSql, this.croomrangecur)

this.Export(this.croomrangecur)

RETURN .T.
ENDPROC
*
PROCEDURE PaymethodsGet
LOCAL l_cSql
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT pm_paymeth, pm_lang<<g_langnum>> AS pm_lang, pm_paynum, 0 AS c_order 
     FROM paymetho 
     WHERE pm_paymeth <> '    ' AND NOT pm_inactiv 
     UNION 
     SELECT CAST('' AS Char(4)) AS pm_paymeth, CAST('' AS Char(25)) AS pm_lang, CAST(0 AS Numeric(3)) pm_paynum, 1 AS c_order
     FROM param 
     ORDER BY 4,1 
ENDTEXT
sqlcursor(l_cSql,this.ccurpaymethods)
this.Export(this.ccurpaymethods)
RETURN .T.
ENDPROC
*
PROCEDURE LettersGet
LOCAL l_cSql
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT CAST(li_liid AS Character(8)) AS c_liid, li_lang<<g_langnum>> AS li_lang FROM lists WHERE li_menu = 8 AND li_lettype = 1 AND li_lexptyp = 3
ENDTEXT
sqlcursor(l_cSql,this.cletterscur)
this.Export(this.cletterscur)
RETURN .T.
ENDPROC
*
PROCEDURE LettersGeneratePDF
LPARAMETERS lp_nLnId, lp_nRsId
LOCAL l_cFileName, l_oDefaults, l_lSuccess, l_nReserId, l_cFRX, l_oTempRG, l_nSelect, l_cFileShort
l_cFileShort = ""
IF NOT EMPTY(lp_nLnId) AND NOT EMPTY(lp_nRsId)
     l_nReserId = dlookup("reservat","rs_rsid = " + sqlcnv(lp_nRsId,.T.),"rs_reserid")
     l_oDefaults = MakeStructure("nPeferedType, cArchive, Min1, Max1, Min2, Max2, Min3, Max3, Min4, Max4")
     l_oDefaults.nPeferedType = 3 && PDF
     l_oDefaults.cArchive = ""
     l_oDefaults.Min1 = l_nReserId
     l_oDefaults.Max1 = ""
     l_oDefaults.Min2 = ""
     l_oDefaults.Max2 = ""
     l_oDefaults.Min3 = ""
     l_oDefaults.Max3 = ""
     l_oDefaults.Min4 = ""
     l_oDefaults.Max4 = ""
     
     l_nSelect = SELECT()
     
     IF dlocate("lists","li_liid = " + sqlcnv(lp_nLnId))
          IF NOT g_lUseNewRepExp
               g_lUseNewRepExp = .T.
          ENDIF
          IF NOT "mylist" $ LOWER(SET("Procedure"))
               SET PROCEDURE TO mylists.prg ADDITIVE
          ENDIF
          l_cFileName = prTreport(.F.,.T., l_oDefaults)
          IF NOT EMPTY(l_cFileName)
               l_cFileShort = FULLPATH(l_cFileName)
          ENDIF
     ENDIF
     SELECT (l_nSelect)
ENDIF
RETURN l_cFileShort
ENDPROC
*
PROCEDURE LettersGetEMailData
* Send address email, name etc., and email subject
LPARAMETERS lp_cFile, lp_nRsId, lp_nLiId
LOCAL l_nSelect, l_cData, l_cCursor, l_cSql
LOCAL l_nAddrId, l_cTitle, l_cLName, l_cFName, l_cEMail, l_cSalute, l_cLang
l_nAddrId = 0
STORE "" TO l_cData, l_cTitle, l_cLName, l_cFName, l_cEMail, l_cSalute, l_cLang

l_nSelect = SELECT()
IF NOT EMPTY(lp_cFile) AND NOT EMPTY(lp_nRsId) AND NOT EMPTY(lp_nLiId)
     IF dlocate("lists","li_liid = " + sqlcnv(lp_nLiId))
          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
          SELECT rs_reserid, rs_noaddr, rs_title, rs_lname, rs_fname, <<this.cEmailUserField>> AS c_email, 
               NVL(c1.ad_addrid,0) AS c1_addrid, NVL(c1.ad_title,'') AS c1_title, NVL(c1.ad_fname,'') AS c1_fname, NVL(c1.ad_lname,'') AS c1_lname, 
               NVL(c1.ad_salute,'') AS c1_salute, NVL(c1.ad_lang, '') AS c1_lang, NVL(c1.ad_email,'') AS c1_email, 
               NVL(c2.ad_addrid,0) AS c2_addrid, NVL(c2.ad_title,'') AS c2_title, NVL(c2.ad_fname,'') AS c2_fname, NVL(c2.ad_lname,'') AS c2_lname, 
               NVL(c2.ad_salute,'') AS c2_salute, NVL(c2.ad_lang, '') AS c2_lang, NVL(c2.ad_email,'') AS c2_email 
               FROM reservat 
               LEFT JOIN address c1 ON rs_addrid = c1.ad_addrid 
               LEFT JOIN address c2 ON rs_compid = c2.ad_addrid 
               WHERE rs_rsid = <<sqlcnv(lp_nRsId,.T.)>> 
          ENDTEXT
          l_cCursor = sqlcursor(l_cSql)
          IF USED(l_cCursor)
               SELECT (l_cCursor)
               DO CASE
                    CASE rs_noaddr
                         l_nAddrId = c1_addrid
                         l_cTitle = ALLTRIM(rs_title)
                         l_cLName = ALLTRIM(rs_lname)
                         l_cFName = ALLTRIM(rs_fname)
                         l_cEMail = ALLTRIM(c_email)
                         l_cSalute = ALLTRIM(dlookup("title","ti_title = " + sqlcnv(PADR(l_cTitle,25),.T.),"ti_salute"))
                         l_cLang = c1_lang
                    CASE NOT EMPTY(c1_email)
                         l_nAddrId = c1_addrid
                         l_cTitle = ALLTRIM(c1_title)
                         l_cLName = ALLTRIM(c1_lname)
                         l_cFName = ALLTRIM(c1_fname)
                         l_cEMail = ALLTRIM(c1_email)
                         l_cSalute = ALLTRIM(c1_salute)
                         l_cLang = c1_lang
                    CASE NOT EMPTY(c2_email)
                         l_nAddrId = c2_addrid
                         l_cTitle = ALLTRIM(c2_title)
                         l_cLName = ALLTRIM(c2_lname)
                         l_cFName = ALLTRIM(c2_fname)
                         l_cEMail = ALLTRIM(c2_email)
                         l_cSalute = ALLTRIM(c2_salute)
                         l_cLang = c2_lang
               ENDCASE

          ENDIF


          IF NOT EMPTY(l_cEMail)
               l_cData = l_cData + l_cEMail + CHR(4)
               l_cData = l_cData + ALLTRIM(procemail("PEGetHeader", lp_nLiId, l_cTitle, l_cFName, l_cLName, l_cSalute, l_cLang)) + CHR(4)
               l_cData = l_cData + ALLTRIM(procemail("PEgetsignature")) + CHR(4)
               l_cData = l_cData + GetLetterDescription(l_nAddrId, &l_cCursor..rs_reserid) + CHR(4)
          ENDIF

     ENDIF
ENDIF
SELECT (l_nSelect)
RETURN l_cData
ENDPROC
*
PROCEDURE LettersSendEMail
LPARAMETERS lp_cFile, lp_nRsId, lp_cMailTo, lp_cSubject, lp_cMailBody
LOCAL l_cIniFile, l_csmtphost, ;
          l_csmtpfrom, l_csmtpauthlogin, l_csmtpauthpassword, l_lSuccess, l_cFile
l_lSuccess = .F.
l_cIniFile = FULLPATH(INI_FILE)
IF FILE(l_cIniFile)
     l_csmtphost = ALLTRIM(readini(l_cIniFile, "E-Mail","smtphost", ""))
     l_csmtpfrom = ALLTRIM(readini(l_cIniFile, "E-Mail","smtpfrom", ""))
     l_csmtpauthlogin = ALLTRIM(readini(l_cIniFile, "E-Mail","smtpauthlogin", ""))
     l_csmtpauthpassword = ALLTRIM(readini(l_cIniFile, "E-Mail","smtpauthpassword", ""))
ENDIF

IF EMPTY(l_csmtphost) OR EMPTY(l_csmtpfrom) OR EMPTY(l_csmtpauthlogin) OR EMPTY(l_csmtpauthpassword) OR EMPTY(lp_cMailTo)
     RETURN l_lSuccess
ENDIF

l_cFile = FULLPATH(_screen.oGlobal.choteldir + "document\" + ALLTRIM(TRANSFORM(lp_cFile)))
IF FILE(l_cFile)
     DO PESendWithBlat IN procemail WITH lp_cMailTo, "", l_csmtpfrom, l_csmtphost, l_csmtpauthlogin, ;
          l_csmtpauthpassword, lp_cMailBody, lp_cSubject, l_cFile, .T., "cwsblat.log", l_lSuccess
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE StylesGet
CREATE CURSOR (this.ccurstyles) (st_name c(5), st_bcolor i, st_fcolor i)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSDEF", g_oPredefinedColors.BkDeffiniteColor, g_oPredefinedColors.FrDeffiniteColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSIN ", g_oPredefinedColors.BkInColor, g_oPredefinedColors.FrInColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSOUT", g_oPredefinedColors.BkOutColor, g_oPredefinedColors.FrOutColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RS6PM", g_oPredefinedColors.Bk6PMColor, g_oPredefinedColors.Fr6PMColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSASG", g_oPredefinedColors.BkAssignColor, g_oPredefinedColors.FrAssignColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSOPT", g_oPredefinedColors.BkOptionColor, g_oPredefinedColors.FrOptionColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSTEN", g_oPredefinedColors.BkTENColor, g_oPredefinedColors.FrTENColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSLST", g_oPredefinedColors.BkWaitingColor, g_oPredefinedColors.FrWaitingColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSCXL", g_oPredefinedColors.BkCanceledColor, g_oPredefinedColors.FrCanceledColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSNS ", g_oPredefinedColors.BkNoShowColor, g_oPredefinedColors.FrNoShowColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSOOO", g_oPredefinedColors.BkOOOColor, g_oPredefinedColors.FrOOOColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RSOOS", g_oPredefinedColors.BkOOSColor, g_oPredefinedColors.FrOOSColor)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RMOOO", g_oPredefinedColors.RmStOOOColor, 0)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RMOOS", g_oPredefinedColors.RmStOOSColor, 0)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RMCLN", g_oPredefinedColors.RmStClnColor, 0)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RMDIR", g_oPredefinedColors.RmStDirColor, 0)
INSERT INTO (this.ccurstyles) (st_name, st_bcolor, st_fcolor) VALUES ("RM   ", g_oPredefinedColors.RmStClnColor, 0)
this.Export(this.ccurstyles)
RETURN .T.
ENDPROC
*
PROCEDURE GetInterval
LPARAMETERS tnConf, tnDays, tnStart, tnEnd
LOCAL ltStartHr, ltArrival, ltDeparture, lnHours

DO CASE
     CASE tnConf = 0     && 1 - tnDays        - roomplan
          tnStart = MAX(ri_date - p_dFromDate + 1, 1)
          tnEnd = MIN(ri_todate, p_dToDate) - p_dFromDate + 1
     CASE tnConf = 1     && 1 - 3*tnDays      - conf week plan
          ltStartHr = DTOT(p_dFromDate)
          ltArrival = IIF(ri_date>rs_arrdate, DTOT(ri_date), CTOT(DTOC(rs_arrdate)+" "+rs_arrtime))
          ltDeparture = ICASE(ri_todate<rs_depdate, DTOT(ri_todate+1), EMPTY(CHRTRAN(rs_deptime,"0:","")), DTOT(rs_depdate+1), CTOT(DTOC(rs_depdate)+" "+rs_deptime))
          tnStart = FLOOR((ltArrival - ltStartHr)/3600)
          tnEnd = CEILING((ltDeparture - ltStartHr)/3600)
          lnHours = MOD(tnStart,24)
          tnStart = 3*FLOOR(tnStart/24) + ICASE(BETWEEN(lnHours,0,_screen.oGlobal.oParam.pa_dayprt1-1), 1, BETWEEN(lnHours,_screen.oGlobal.oParam.pa_dayprt1,_screen.oGlobal.oParam.pa_dayprt2-1), 2, 3)
          lnHours = MOD(tnEnd,24)
          tnEnd = 3*FLOOR(tnEnd/24) + ICASE(lnHours=0, 0, BETWEEN(lnHours,1,_screen.oGlobal.oParam.pa_dayprt1), 1, BETWEEN(lnHours,_screen.oGlobal.oParam.pa_dayprt1+1,_screen.oGlobal.oParam.pa_dayprt2), 2, 3)
          tnStart = MAX(1, MIN(3*tnDays, tnStart))
          tnEnd = MAX(1, MIN(3*tnDays, tnEnd))
     OTHERWISE && tnConf = 2     1 - 24*10    - conf day plan
          ltStartHr = DTOT(p_dFromDate)
          ltArrival = IIF(ri_date>rs_arrdate, DTOT(ri_date), CTOT(DTOC(rs_arrdate)+" "+rs_arrtime))
          ltDeparture = ICASE(ri_todate<rs_depdate, DTOT(ri_todate+1), EMPTY(CHRTRAN(rs_deptime,"0:","")), DTOT(rs_depdate+1), CTOT(DTOC(rs_depdate)+" "+rs_deptime))
          tnStart = FLOOR((ltArrival - ltStartHr)/360)+1
          tnEnd = CEILING((ltDeparture - ltStartHr)/360)
          tnStart = MAX(1, MIN(240, tnStart))
          tnEnd = MAX(1, MIN(240, tnEnd))
ENDCASE
ENDPROC
*
PROCEDURE RoomplanGet
LPARAMETERS lp_dFromDate, lp_cRoomtype, lp_cBuilding, lp_nDays, lp_nConf, lp_cRange
* lp_nConf=0     - standard room plan
* lp_nConf=1     - conference week plan
* lp_nConf=2     - conference day plan
LOCAL i, j, l_lSuccess, l_cSql, l_cWhere, l_cCurRooms, l_cCurDays, l_cCurRoomplan, l_cCursor
LOCAL lcFldSource, llSetFColor, lcLinked, lcRoomNum, lnColor, lcFields, lnStart, lnEnd

l_cWhere = ""
lp_nDays = IIF(EMPTY(lp_nDays), 20, lp_nDays)
lp_nConf = IIF(EMPTY(lp_nConf), 0, lp_nConf)

PRIVATE p_dFromDate, p_dToDate, p_cRoomtype, p_cBuilding, p_cRange
p_dFromDate = IIF(EMPTY(lp_dFromDate), SysDate(), lp_dFromDate)
p_dToDate = p_dFromDate + lp_nDays - 1
IF NOT EMPTY(lp_cBuilding)
     p_cBuilding = PADR(ALLTRIM(lp_cBuilding),3)
     l_cWhere = SqlWhere(l_cWhere,"rt_buildng = __SQLPARAM__p_cBuilding")
ENDIF
IF EMPTY(lp_cRoomtype)
     l_cWhere = SqlWhere(l_cWhere,"rt_group = "+IIF(EMPTY(lp_nConf),"1","2"))
ELSE
     p_cRoomtype = PADR(ALLTRIM(lp_cRoomtype),4)
     l_cWhere = SqlWhere(l_cWhere,"rt_roomtyp = __SQLPARAM__p_cRoomtype")
ENDIF
IF NOT EMPTY(lp_cRange)
     p_cRange = PADR(ALLTRIM(lp_cRange),3)
     l_cWhere = SqlWhere(l_cWhere,"rm_cnfrang = __SQLPARAM__p_cRange")
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT rm_roomnum, rm_roomtyp, rm_rmname, rm_status, rm_cnfrang, rd_roomtyp, rm_rpseq, rt_buildng FROM room
     INNER JOIN roomtype ON rt_roomtyp = rm_roomtyp
     INNER JOIN rtypedef ON rt_rdid = rd_rdid
     <<l_cWhere>>
     ORDER BY rm_rpseq, rt_buildng, rm_rmname
ENDTEXT
l_cCurRooms = SqlCursor(l_cSql)

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT DISTINCT ri_roomnum, ri_date, ri_todate, rs_rsid, rs_reserid, rs_arrdate, rs_depdate, rs_arrtime, rs_deptime, rs_groupid,
     rs_adults+rs_childs+rs_childs2+rs_childs3 AS rs_persons, rs_status, rs_roomtyp, rs_ratecod, rs_rate, rs_group, rs_addrid, rs_company,
     CAST(rs_lname AS Char(50)) AS rs_lname, CAST(0 AS Integer) AS rs_fcolor, 
     CAST(NVL(dc_reserid,0) AS Numeric(12,3)) AS dc_reserid 
     FROM resrooms
     INNER JOIN reservat ON ri_reserid = rs_reserid 
     LEFT JOIN document ON rs_reserid = dc_reserid 
     WHERE ri_date <= __SQLPARAM__p_dToDate AND ri_todate >= __SQLPARAM__p_dFromDate AND NOT INLIST(rs_status, 'NS ', 'CXL')
     ORDER BY 1, 2<<IIF(lp_nConf=0,"",", 8")>>
ENDTEXT
l_cCurRoomplan = SqlCursor(l_cSql,,,,,,,.T.)
INDEX ON rs_rsid TAG rs_rsid
SET ORDER TO
REPLACE rs_lname WITH ;
          IIF(dc_reserid=0,"","*")+;
          IIF(rs_addrid=_screen.oglobal.oparam2.pa_defadri,'!','')+;
          EVL(rs_lname,rs_company) ALL

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT oo_roomnum AS ri_roomnum, oo_fromdat AS ri_date, oo_todat-1 AS ri_todate, oo_id AS rs_rsid, oo_fromdat AS rs_arrdate, oo_todat AS rs_depdate, "OOO" AS rs_status, oo_reason AS rs_lname
     FROM outoford
     WHERE oo_fromdat <= __SQLPARAM__p_dToDate AND oo_todat >= __SQLPARAM__p_dFromDate AND NOT oo_cancel
     ORDER BY 1, 2
ENDTEXT
l_cCursor = SqlCursor(l_cSql)
IF RECCOUNT(l_cCursor) > 0
     SELECT &l_cCurRoomplan
     APPEND FROM DBF(l_cCursor)
ENDIF
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT os_roomnum AS ri_roomnum, os_fromdat AS ri_date, os_todat-1 AS ri_todate, os_id AS rs_rsid, os_fromdat AS rs_arrdate, os_todat AS rs_depdate, "OOS" AS rs_status, os_reason AS rs_lname
     FROM outofser
     WHERE os_fromdat <= __SQLPARAM__p_dToDate AND os_todat >= __SQLPARAM__p_dFromDate AND NOT os_cancel
     ORDER BY 1, 2
ENDTEXT
l_cCursor = SqlCursor(l_cSql)
IF RECCOUNT(l_cCursor) > 0
     SELECT &l_cCurRoomplan
     APPEND FROM DBF(l_cCursor)
ENDIF
DClose(l_cCursor)

lcFields = ""
FOR i = 1 TO ICASE(lp_nConf = 0, lp_nDays, lp_nConf = 1, 3*lp_nDays, 24*10)
     lcFields = lcFields + IIF(EMPTY(lcFields), "", ", ") + "cSource"+TRANSFORM(i)+" C(100)"
NEXT
l_cCurDays = SYS(2015)
CREATE CURSOR &l_cCurDays (&lcFields)
APPEND BLANK
SELECT * FROM &l_cCurRooms, &l_cCurDays INTO CURSOR &l_cCurRooms READWRITE
INDEX ON rm_roomnum TAG rm_roomnum
SET ORDER TO

SELECT &l_cCurRoomplan
SCAN FOR NOT EMPTY(ri_roomnum)
     llSetFColor = .T.
     this.GetInterval(lp_nConf, lp_nDays, @lnStart, @lnEnd)
     lcLinked = get_rm_rmname(ri_roomnum, "rm_link")
     lcLinked = ri_roomnum + IIF(EMPTY(lcLinked), "", ",") + lcLinked
     FOR i = 1 TO GETWORDCOUNT(lcLinked, ",")
          lcRoomNum = PADR(GETWORDNUM(lcLinked,i,","),4)
          IF NOT EMPTY(lcRoomNum) AND SEEK(lcRoomNum, l_cCurRooms, "rm_roomnum")
               FOR j = lnStart TO lnEnd
                    lcFldSource = l_cCurRooms+".cSource"+TRANSFORM(j)
                    DO CASE
                         CASE rs_status = "OOO"
                              REPLACE &lcFldSource WITH ALLTRIM(&lcFldSource)+IIF(EMPTY(&lcFldSource),"",",")+"OO"+TRANSFORM(&l_cCurRoomplan..rs_rsid) IN &l_cCurRooms
                         CASE rs_status = "OOS"
                              REPLACE &lcFldSource WITH ALLTRIM(&lcFldSource)+IIF(EMPTY(&lcFldSource),"",",")+"OS"+TRANSFORM(&l_cCurRoomplan..rs_rsid) IN &l_cCurRooms
                         OTHERWISE
                              IF llSetFColor
                                   lnColor = IIF(EMPTY(rs_groupid), 0, DLookUp("groupres", "gr_groupid = " + SqlCnv(rs_groupid,.T.), "gr_color"))
                                   lnColor = ProcRatecode("GetRatecodeColor", l_cCurRoomplan, lnColor)
                                   REPLACE rs_fcolor WITH lnColor IN &l_cCurRoomplan
                                   llSetFColor = .F.
                              ENDIF
                              REPLACE &lcFldSource WITH "RS"+TRANSFORM(&l_cCurRoomplan..rs_rsid)+IIF(EMPTY(&lcFldSource),"",",")+ALLTRIM(&lcFldSource) IN &l_cCurRooms
                    ENDCASE
               NEXT
          ENDIF
     NEXT
ENDSCAN

IF USED(l_cCurRooms) AND USED(l_cCurRoomplan)
     l_lSuccess = .T.
     this.Export(l_cCurRoomplan)
     this.cCurRoomplan = this.cResultTable
     this.Export(l_cCurRooms)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE CheckCa
ENDPROC
*
PROCEDURE UseTables
ini()
openfile(.F., "reservat", .F., .F., 5)
openfile(.F., "altsplit", .F., .F., 5)
openfile(.F., "althead")
openfile(.F., "availab", .F., .F., 5)
openfile(.F., "roomplan", .F., .F., 5)
openfile(.F., "sharing", .F., .F., 5)
openfile(.F., "resrmshr", .F., .F., 5)
openfile(.F., "groupres", .F., .F., 5)
openfile(.F., "sheet", .F., .F., 5)
openfile(.F., "deposit", .F., .F., 5)
openfile(.F., "banquet", .F., .F., 5)
openfile(.F., "resrate", .F., .F., 5)
openfile(.F., "ressplit", .F., .F., 5)
openfile(.F., "resfix", .F., .F., 5)
openfile(.F., "post", .F., .F., 5)
openfile(.F., "arpost", .F., .F., 5)
openfile(.F., "ledgpost", .F., .F., 5)
openfile(.F., "ledgpaym", .F., .F., 5)
openfile(.F., "billnum", .F., .F., 5)
openfile(.F., "respict", .F., .F., 5)
openfile(.F., "action", .F., .F., 5)
openfile(.F., "document", .F., .F., 5)
openfile(.F., "histres")
openfile(.F., "histpost")
openfile(.F., "hresext")
openfile(.F., "picklist")
openfile(.F., "billinst", .F., .F., 5)
openfile(.F., "paymetho")
openfile(.F., "resrooms", .F., .F., 5)
openfile(.F., "roomtype")
openfile(.F., "room")
openfile(.F., "param")
openfile(.F., "title")
openfile(.F., "ratecode")
openfile(.F., "season")
openfile(.F., "license")
openfile(.F., "ratearti")
openfile(.F., "article")
openfile(.F., "address", .F., .F., 5)
openfile(.F., "citcolor")
openfile(.F., "lists")
RETURN .T.
ENDPROC
*
PROCEDURE SetChilds
LOCAL l_nChildCats, l_nNo
l_nChildCats = lstcount(_screen.oGlobal.oParam.pa_childs)

IF l_nChildcats > 0
     FOR l_nNo = 1 TO l_nChildcats
          l_cMacro = "this.cchild" + TRANSFORM(l_nNo) + "on"
          &l_cMacro = "1"
          l_cMacro = "this.cchild" + TRANSFORM(l_nNo) + "caption"
          &l_cMacro = lstitem(_screen.oGlobal.oParam.pa_childs, l_nNo)
     ENDFOR
ENDIF
RETURN .T.
ENDPROC
*
*!*     PROCEDURE CovertDate
*!*     LPARAMETERS lp_cDate
*!*     LOCAL l_dDate, l_nYear, l_nMonth, l_nDay
*!*     IF EMPTY(lp_cDate)
*!*          l_dDate = {}
*!*     ENDIF
*!*     lp_cDate = TRANSFORM(lp_cDate)

*!*     TRY
*!*          l_nYear = INT(VAL(GETWORDNUM(lp_cDate,1,"-")))
*!*          l_nMonth = INT(VAL(GETWORDNUM(lp_cDate,2,"-")))
*!*          l_nDay = INT(VAL(GETWORDNUM(lp_cDate,3,"-")))
*!*          l_dDate = DATE(l_nYear, l_nMonth, l_nDay)
*!*     CATCH
*!*     ENDTRY

*!*     RETURN l_dDate
*!*     ENDPROC
*
ENDDEFINE
*
DEFINE CLASS PrCopyGroup AS Session
*
oGroupFunctions = .NULL.
*
PROCEDURE Init
ini(.T.)
this.oGroupFunctions = NEWOBJECT("cgroupfunctions","libs\cit_reservat.vcx")
this.oGroupFunctions.oCheckReservat = CREATEOBJECT("checkreservat")
this.oGroupFunctions.oCheckReservat.madjustenvironment()
RETURN .T.
ENDPROC
*
PROCEDURE OnCopyGroup
LPARAMETERS lp_nReserId
LOCAL l_lExist, l_nReserId, l_cSql, l_cCur, l_nnewgroupreserid
l_nnewgroupreserid = 0
IF EMPTY(lp_nReserId)
	RETURN l_nnewgroupreserid
ENDIF

l_nReserId = lp_nReserId
l_lExist = SEEK(l_nReserId, "reservat", "tag1")
IF NOT l_lExist
	* Must restore reservations from history
	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT hr_reserid, hr_rsid, NVL(rs_yoid,00000000) AS rs_yoid ;
		FROM histres ;
		LEFT JOIN hresext ON hr_rsid = rs_rsid ;
		WHERE hr_reserid >= <<ALLTRIM(STR(INT(l_nReserId)))>> AND ;
		hr_reserid < <<ALLTRIM(STR(INT(l_nReserId)+1))>> AND ;
		hr_roomlst AND hr_rooms = 1 AND NOT hr_status IN ('CXL','NS')
	ENDTEXT
	l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
	IF USED(l_cCur)
		SELECT (l_cCur)
		SCAN ALL
			DO FromHistToRes IN ProcReservat WITH &l_cCur..hr_reserid
			DO FromHistToBanquet IN ProcReservat WITH &l_cCur..hr_reserid
			DO FromHistToResfix IN ProcReservat WITH &l_cCur..hr_reserid
			DO FromHistToResrart IN ProcReservat WITH &l_cCur..hr_rsid
			DO FromHistToSheet IN ProcReservat WITH &l_cCur..hr_reserid
			DO FromHistToResrate IN ProcReservat WITH &l_cCur..hr_reserid
			DO FromHistToBillinst IN ProcReservat WITH &l_cCur..hr_reserid
		ENDSCAN
	ENDIF
ENDIF

this.oGroupFunctions.OnCopyGroup(.T.)
l_nnewgroupreserid = this.oGroupFunctions.nnewgroupreserid
IF NOT l_lExist
	SELECT (l_cCur)
	SCAN ALL
		SqlDelete("banquet", "bq_reserid = " + SqlCnv(&l_cCur..hr_reserid,.T.))
		SqlDelete("resfix", "rf_reserid = " + SqlCnv(&l_cCur..hr_reserid,.T.))
		SqlDelete("sheet", "sh_reserid = " + SqlCnv(&l_cCur..hr_reserid,.T.))
		SqlDelete("resrate", "rr_reserid = " + SqlCnv(&l_cCur..hr_reserid,.T.))
		SqlDelete("resrart", "ra_rsid = " + SqlCnv(&l_cCur..hr_rsid,.T.))
		SqlDelete("yioffer", "yo_yoid = " + SqlCnv(&l_cCur..rs_yoid,.T.))
		SqlDelete("yicond", "yc_yoid = " + SqlCnv(&l_cCur..rs_yoid,.T.))
		SqlDelete("resyield", "ry_yoid = " + SqlCnv(&l_cCur..rs_yoid,.T.))
		SqlDelete("billinst", "bi_reserid = " + SqlCnv(&l_cCur..hr_reserid,.T.))
		SqlDelete("rescard", "cr_rsid = " + SqlCnv(&l_cCur..hr_rsid,.T.))
		SqlDelete("resfeat", "fr_rsid = " + SqlCnv(&l_cCur..hr_rsid,.T.))
		SqlDelete("pswindow", "pw_rsid = " + SqlCnv(&l_cCur..hr_rsid,.T.))
	ENDSCAN
	dclose(l_cCur)
ENDIF
RETURN l_nnewgroupreserid
ENDPROC
*
PROCEDURE Release
this.oGroupFunctions.oCheckReservat.Release()
this.oGroupFunctions.oCheckReservat = .NULL.
this.oGroupFunctions.Release()
this.oGroupFunctions = .NULL.
RELEASE this
RETURN .T.
ENDPROC
*
ENDDEFINE