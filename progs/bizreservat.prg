#INCLUDE "include\constdefines.h"
*
PROCEDURE PRrs_billins_address_change_alowed
LPARAMETERS lp_nLine, lp_cResAlias, lp_lMessage, lp_cOldInstrLine, lp_cNewInstrLine, lp_nOldAddrid, lp_nNewAddrId, lp_oCheckReser
LOCAL l_lAllowed, l_lBillClosed, l_cDVCur, l_cSql, l_nSelect, l_cBillNum, l_nWin, l_nOldAddrid,l_nNewAddrid, l_nReserID, ;
		l_cForClause, l_nRecNo
l_lAllowed = .T.

* Determine ps_window
l_nWin = ICASE(lp_nLine=1 OR lp_nLine=4,0,lp_nLine=0,1,lp_nLine>3,lp_nLine-1,lp_nLine) && Line 1 is not ps_window 1! ps_window 1 ad_addrid is determined from rs_addrid!

IF EMPTY(l_nWin)
	RETURN l_lAllowed
ENDIF

IF NOT _screen.DV
	RETURN l_lAllowed
ENDIF

IF l_nWin = 1 && For 1 we know this is rs_addrid
	IF lp_nOldAddrid = lp_nNewAddrId
		RETURN l_lAllowed
	ENDIF
ELSE
	* Is addrid changed?
	l_nOldAddrid = myVal(SUBSTR(lp_cOldInstrLine, 1, 12))
	l_nNewAddrid = myVal(SUBSTR(lp_cNewInstrLine, 1, 12))

	IF l_nOldAddrid = l_nNewAddrid
		RETURN l_lAllowed
	ENDIF
ENDIF

l_nSelect = SELECT()

IF VARTYPE(lp_oCheckReser)<>"O"
	lp_oCheckReser = CREATEOBJECT("checkreservat")
ENDIF
l_nReserID = &lp_cResAlias..rs_reserid
l_cForClause = lp_oCheckReser.resset_forclause_get(.T., "l_nReserID", lp_cResAlias, &lp_cResAlias..rs_roomlst, l_nReserID)

SELECT (lp_cResAlias)
l_nRecNo = RECNO()
SCAN FOR &l_cForClause
	* has this bill window debitor posting?

	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT COUNT(*) AS c_debcnt 
		FROM post 
		INNER JOIN paymetho ON ps_paynum = pm_paynum AND pm_paytyp = 4 
		WHERE ps_reserid = <<sqlcnv(EVALUATE(lp_cResAlias+".rs_reserid"))>> AND ps_window = <<TRANSFORM(l_nWin)>> AND 
		NOT ps_cancel
	ENDTEXT
	l_cDVCur = sqlcursor(l_cSql)
	IF USED(l_cDVCur) AND &l_cDVCur..c_debcnt>0
		* don't allow change of address for bill which has debitor payment
		l_lAllowed = .F.
		IF lp_lMessage AND NOT g_lAutomationMode
			alert(GetLangText("BILL","TXT_BILL_HAS_DEBITOR_PAYMENT"))
		ENDIF
	ENDIF
	dclose(l_cDVCur)

	IF NOT l_lAllowed
		EXIT
	ENDIF
ENDSCAN
GO l_nRecNo IN &lp_cResAlias
lp_oCheckReser = .NULL.
SELECT (l_nSelect)

RETURN l_lAllowed
ENDPROC
*
PROCEDURE PRDeleteReservat
LPARAMETERS lp_cResAlias
LOCAL l_cChanges

l_cChanges = TRANSFORM(DATETIME())+" | "+FNGetCallStack()
l_cChanges = RsHistry(&lp_cResAlias..rs_changes, "ERASED", l_cChanges)

REPLACE rs_changes WITH l_cChanges IN &lp_cResAlias

DELETE IN &lp_cResAlias

RETURN .T.
ENDPROC

**************************************************
*-- Class:        colreservat (\progs\bizreservat.prg)
*-- ParentClass:  colmodules (\progs\bizbase.prg)
*-- BaseClass:    collection
*-- Time Stamp:   29.08.11 13:36:09
*
DEFINE CLASS colreservat AS colmodules


	PROCEDURE ressave
		LPARAMETERS tcError

		this.ResetError()
		DO CASE
			CASE this.ResCheckAll()
				this.ResSaveAll()
			OTHERWISE
		ENDCASE

		RETURN this.GetError(@tcError)
	ENDPROC


	PROCEDURE rescheckall
		LOCAL llSuccess, loModule, lcError

		llSuccess = .T.
		FOR EACH loModule IN this
			llSuccess = loModule.ResCheck()
			this.nErrorcode = loModule.GetError(@lcError)
			this.cError = lcError
			IF NOT llSuccess
				EXIT
			ENDIF
		ENDFOR

		RETURN llSuccess
	ENDPROC


	PROCEDURE ressaveall
		LOCAL loModule, lcError

		this.ResetError()
		FOR EACH loModule IN this
			this.nErrorcode = loModule.Save(@lcError)
			this.cError = lcError
			IF this.nErrorcode < NO_ERROR
				EXIT
			ENDIF
		ENDFOR
	ENDPROC


ENDDEFINE
*
*-- EndDefine: colreservat
**************************************************

**************************************************
*-- Class:        cresbase (\progs\bizreservat.prg)
*-- ParentClass:  cbizbase (\progs\bizbase.prg)
*-- BaseClass:    collection
*-- Time Stamp:   29.08.11 13:36:09
*
DEFINE CLASS cresbase AS cbizbase


	ctables = "reservat,pswindow"


	PROCEDURE ressave
		LPARAMETERS tcError

		this.ResetError()
		DO CASE
			CASE this.ResCheck()
				this.Save()
			OTHERWISE
		ENDCASE

		RETURN this.GetError(@tcError)
	ENDPROC


	PROCEDURE rescheck

		RETURN .T.
	ENDPROC


	PROCEDURE resgetbyrsid
		LPARAMETERS tnRecordId

		this.CursorFill("reservat", "rs_rsid = " + SqlCnv(tnRecordId, .T.))
	ENDPROC


	PROCEDURE resgetclause
		LPARAMETERS tcFilterClause

		this.CursorFill("reservat", tcFilterClause)
	ENDPROC


	PROCEDURE sync_rescommon_field
		LPARAMETERS tcField, tvValue
		LOCAL i, lnArea, lnRecNo, lnAddrId

		lnArea = SELECT()

		SELECT curReservat
		lnRecNo = RECNO()
		SCAN
			IF NOT &tcField == tvValue
				REPLACE &tcField WITH tvValue
				IF LOWER(tcField) == "rs_billins"
					IF NOT EMPTY(tvValue)
						FOR i = 2 TO 6
							lnAddrId = INT(VAL(SUBSTR(MLINE(tvValue, IIF(i>3,i+1,i)), 1, 12)))
							FNSetWindowData(rs_rsid, i, "pw_addrid", lnAddrId, "curPswindow")
						ENDFOR
					ENDIF
				ENDIF
			ENDIF
		ENDSCAN
		GO lnRecNo

		SELECT (lnArea)
	ENDPROC


	PROCEDURE sync_rescommon_table
		LPARAMETERS tcAlias, tcKey, tcResKey
		LOCAL lnArea, lnRecNo, lcurResult, lnKeyValue

		lnArea = SELECT()

		lnKeyValue = curReservat.&tcResKey
		lcurResult = SYS(2015)
		SELECT * FROM &tcAlias WHERE &tcKey = lnKeyValue INTO CURSOR &lcurResult READWRITE

		SELECT curReservat
		lnRecNo = RECNO()
		SCAN FOR &tcResKey <> lnKeyValue
			REPLACE &tcKey WITH curReservat.&tcResKey ALL IN &lcurResult
			DELETE FOR &tcKey = curReservat.&tcResKey IN &tcAlias
			SELECT &tcAlias
			APPEND FROM DBF(lcurResult)
			SELECT curReservat
		ENDSCAN
		GO lnRecNo

		DClose(lcurResult)

		SELECT (lnArea)
	ENDPROC


	PROCEDURE resset_forclause_get
		LPARAMETERS tlSQL, tcReserIdVar, tcResAlias, tlRs_roomlst, tnRs_reserid
		LOCAL lcWhere

		IF EMPTY(tcResAlias)
			tcResAlias = "curReservat"
		ENDIF
		IF PCOUNT() < 4
			tlRs_roomlst = &tcResAlias..rs_roomlst
			tnRs_reserid = &tcResAlias..rs_reserid
		ENDIF
		DO CASE
			CASE NOT tlRs_roomlst
				lcWhere = "rs_reserid >= " + SqlCnv(INT(tnRs_reserid)) + " AND rs_reserid < " + SqlCnv(INT(tnRs_reserid)+1) + " AND NOT rs_roomlst AND NOT INLIST(rs_status, 'CXL', 'NS')"
			CASE tlSQL
				lcWhere = "RECNO() = " + TRANSFORM(RECNO(tcResAlias))
			CASE NOT EMPTY(tcReserIdVar)
				lcWhere = "rs_reserid = " + tcReserIdVar
			OTHERWISE
				lcWhere = "rs_reserid = " + SqlCnv(tnRs_reserid)
		ENDCASE

		RETURN lcWhere
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cresbase
**************************************************

**************************************************
*-- Class:        cresbillinst (\progs\bizreservat.prg)
*-- ParentClass:  cresbase (\progs\bizreservat.prg)
*-- BaseClass:    collection
*-- Time Stamp:   29.08.11 13:36:09
*
DEFINE CLASS cresbillinst AS cresbase


	ctables = "reservat,pswindow,billinst"


	PROCEDURE Save
		DoTableUpdate(.T.,.T.,"resrate")
		DoTableUpdate(.T.,.T.,"ressplit")
		DODEFAULT()
	ENDPROC


	PROCEDURE rs_billins_line_replace
		LPARAMETERS tnLine, tcRs_billins, tlDeleteInstrAllow, tcNewInstr
		LOCAL i, llBillIns1Changed, lcRs_billins

		IF NOT EMPTY(tcNewInstr) OR tlDeleteInstrAllow
			lcRs_billins = tcRs_billins
			tcRs_billins = ""
			FOR i = 1 TO 7
				IF i <> tnLine
					tcRs_billins = tcRs_billins + MLINE(lcRs_billins,i) + CRLF
				ELSE
					IF PRrs_billins_address_change_alowed(tnLine, "curReservat", .T., MLINE(lcRs_billins,i), tcNewInstr)
						tcRs_billins = tcRs_billins + tcNewInstr + CRLF
					ELSE
						tcRs_billins = tcRs_billins + MLINE(lcRs_billins,i) + CRLF
					ENDIF
				ENDIF
			ENDFOR

			this.sync_rescommon_field("rs_billins", tcRs_billins)

			IF tnLine = 1
				this.sync_rescommon_table("curBillinst", "bi_reserid", "rs_reserid")
				IF NOT SUBSTR(MLINE(lcRs_billins,1),13) == SUBSTR(tcNewInstr, 13)
					this.resset_resrate_update("curReservat")
				ENDIF
			ENDIF
		ENDIF

		RETURN tcRs_billins
	ENDPROC


	PROCEDURE resset_resrate_update
		LPARAMETERS tcResAlias, tlOnlyOne
		LOCAL lcForClause, lnArea, lnRecNo, lnReserId, loNewRes, loOldRes

		IF PCOUNT() = 0
			tcResAlias = "curReservat"
		ENDIF
		lnReserId = &tcResAlias..rs_reserid
		lnArea = SELECT()
		SELECT &tcResAlias
		lcForClause = this.resset_forclause_get(tlOnlyOne, "lnReserId", tcResAlias)

		lnRecNo = RECNO()
		SCAN FOR &lcForClause
			SCATTER NAME loOldRes MEMO
			loOldRes.rs_arrdate = IIF(RECNO() < 0, {}, OLDVAL("rs_arrdate",tcResAlias))
			loOldRes.rs_depdate = IIF(RECNO() < 0, {}, OLDVAL("rs_depdate",tcResAlias))
			SCATTER NAME loNewRes MEMO
			DO RrUpdate IN ProcResRate WITH loOldRes, loNewRes, .T.
		ENDSCAN
		GO lnRecNo
		SELECT (lnArea)
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cresbillinst
**************************************************

**************************************************
*-- Class:        cresgroup (\progs\bizreservat.prg)
*-- ParentClass:  cresbase (\progs\bizreservat.prg)
*-- BaseClass:    collection
*-- Time Stamp:   29.08.11 13:36:09
*
DEFINE CLASS cresgroup AS cresbase


	ctables = "reservat,groupres"


	PROCEDURE groupgetbygroupid
		LPARAMETERS tnRecordId

		IF EMPTY(tnRecordId)
			this.CursorFill("groupres", "0=1")
		ELSE
			this.CursorFill("groupres", "gr_groupid = " + SqlCnv(tnRecordId, .T.))
		ENDIF
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cresgroup
**************************************************