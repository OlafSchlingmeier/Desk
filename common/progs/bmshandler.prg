#DEFINE DESK		1
#DEFINE TERMINAL	2
#DEFINE WELLNESS	3

#DEFINE CRLF				CHR(13)+CHR(10)

#DEFINE NO_ERROR			 0
#DEFINE ERR_INSERTION_FAILED	-1
#DEFINE ERR_UPDATING_FAILED	-2
#DEFINE ERR_DELETION_FAILED	-3
#DEFINE ERR_INVALID_ACCT_ID	-4
#DEFINE ERR_INVALID_ADDR_ID	-5

#DEFINE BILL_POST		0
#DEFINE BILL_PAY		1
#DEFINE MANUAL_EARN		2
#DEFINE MANUAL_SPENT	3

#DEFINE USE_DEFAULT		0
#DEFINE GENERATE_POINTS	1
#DEFINE USE_DISCOUNT	2

#DEFINE ERRC_INSERTION_FAILED	"Inserting from cursor %s failed!"
#DEFINE ERRC_UPDATING_FAILED	"Updating from cursor %s failed!"
#DEFINE ERRC_DELETION_FAILED	"Deleting from cursor %s failed!"
#DEFINE ERRC_INVALID_ACCT_ID	"Invalid BMS account ID!"
#DEFINE ERRC_INVALID_ADDR_ID	"Invalid BMS address!"
#DEFINE ERRC_DATA_FAILED		CRLF+MESSAGE()&&+"("+TRANSFORM(ERROR())+")"

**************************************************
*-- Class:        cbmshandler (\common\progs\bmshandler.prg)
*-- ParentClass:  
*-- BaseClass:    custom
*-- Time Stamp:   31.10.11 14:00:00
*
DEFINE CLASS cbmshandler AS Custom

	#IF .F. && Make sure this is false, otherwise error
	     *-- Define This for IntelliSense use
	     LOCAL this AS cbmshandler OF bmshandler.prg
	#ENDIF

	PROTECTED nerrorcode
	PROTECTED cerror

	nerrorcode = NO_ERROR
	cerror = ""
	cReprocessScript = ""
	DIMENSION aTables(1)
	dsysdate = {}
	cuserid = ""
	cdesklangnum = "1"
	nwaiternr = 0
	nApp = DESK	&& DESK, TERMINAL, WELLNESS
	lAutoGeneratePoints = .T.
	lAutoDiscount = .T.
	pa_bmstype = 0
	pa_bsdays = 0
	pa_hotcode = ""

	PROCEDURE Init
		LPARAMETERS tdSysDate, tuUserId, tnApp, tPa_bmstype, tnPa_bsdays, tnpa_hotcode

		this.dSysDate = tdSysDate
		this.nApp = tnApp
		this.pa_bmstype = tPa_bmstype
		this.pa_bsdays = tnPa_bsdays
		DO CASE
			CASE this.nApp = DESK
				this.cUserId = tuUserId
				this.pa_hotcode = IIF(EMPTY(tnpa_hotcode),"",tnpa_hotcode)
				this.cDeskLangnum = g_langnum
				this.lAutoGeneratePoints = TYPE("glAutoGeneratePoints") <> "L" OR glAutoGeneratePoints
				this.lAutoDiscount = TYPE("glAutoDiscount") <> "L" OR glAutoDiscount
			CASE this.nApp = TERMINAL
				this.nWaiterNr = tuUserId
				this.cDeskLangnum = TRANSFORM(MAX(1,param.pa_folang))
				this.lAutoGeneratePoints = TYPE("glAutoGeneratePoints") <> "L" OR glAutoGeneratePoints
				this.lAutoDiscount = TYPE("glAutoDiscount") <> "L" OR glAutoDiscount
			CASE this.nApp = WELLNESS
				this.cUserId = tuUserId
				this.cDeskLangnum = TRANSFORM(MAX(1,g_nBrilliantLangCode))
				this.lAutoGeneratePoints = TYPE("g_lAutoGeneratePoints") <> "L" OR g_lAutoGeneratePoints
				this.lAutoDiscount = TYPE("g_lAutoDiscount") <> "L" OR g_lAutoDiscount
			OTHERWISE
		ENDCASE
	ENDPROC


	PROCEDURE BMSTablesOnLine
		LOCAL llOnline, lnSelect
		lnSelect = SELECT()
		* Check if we can access remote bms tables. Should be used from wellness, argus und multiproper desk.
		this.SqlCursor("SELECT bb_bbid, bs_bbid FROM __#SRV.BSACCT#__ LEFT JOIN __#SRV.BSPOST#__ ON bb_bbid = bs_bbid WHERE 0=1","cbmstestc65",,,,,,.T.)
		IF USED("cbmstestc65")
			llOnline = .T.
			dclose("cbmstestc65")
		ENDIF
		SELECT (lnSelect)
		RETURN llOnline
	ENDPROC


	PROCEDURE AccountGetById
		LPARAMETERS tnAcctId, tlOnlyBsAcct, tlNoBuffering, tcBsAcctCurName, tcBsCardCurname
		LOCAL ARRAY laAcctId(1)

		IF EMPTY(tcBsAcctCurName)
			tcBsAcctCurName = "curBsacct"
		ENDIF
		
		IF EMPTY(tcBsCardCurname)
			tcBsCardCurname = "curBsCard"
		ENDIF
		
		IF EMPTY(tnAcctId)
			this.SqlCursor("SELECT * FROM __#SRV.BSACCT#__ WHERE 0 = 1",tcBsAcctCurName,,,,,,.T.)
			IF NOT tlOnlyBsAcct
				this.SqlCursor("SELECT * FROM __#SRV.BSCARD#__ WHERE 0 = 1",tcBsCardCurname,,,,,,.T.)
			ENDIF
			laAcctId(1) = .T.
			this.SqlCursor("SELECT MAX(bb_bbid) FROM __#SRV.BSACCT#__",,,,,,@laAcctId,.T.,,,.T.)
			IF NOT EMPTY(laAcctId(1))
				tnAcctId = laAcctId(1) + 1
			ELSE
				tnAcctId = 1
			ENDIF
		ELSE
			this.SqlCursor("SELECT * FROM __#SRV.BSACCT#__ WHERE bb_bbid = " + SqlCnv(tnAcctId,.T.),tcBsAcctCurName,,,,,,.T.)
			IF NOT tlOnlyBsAcct
				this.SqlCursor("SELECT * FROM __#SRV.BSCARD#__ WHERE bc_bbid = " + SqlCnv(tnAcctId,.T.) + " AND NOT bc_deleted",tcBsCardCurname,,,,,,.T.)
			ENDIF
		ENDIF
		IF NOT tlNoBuffering
			CURSORSETPROP("Buffering",5,tcBsAcctCurName)
			IF NOT tlOnlyBsAcct
				CURSORSETPROP("Buffering",5,tcBsCardCurname)
			ENDIF
		ENDIF
		RETURN .T.
	ENDPROC


	PROCEDURE ValidateAccount
		IF EMPTY(curBsacct.bb_bbid)
			this.nErrorCode = ERR_INVALID_ACCT_ID
			this.cError = g_oBridgeFunc.GetLanguageText("XT| |MGRFINAN","BMS_INVALID_ACCT_ID")&&ERRC_INVALID_ACCT_ID
			RETURN
		ENDIF
		IF EMPTY(curBsacct.bb_addrid) AND EMPTY(curBsacct.bb_adid)
			this.nErrorCode = ERR_INVALID_ADDR_ID
			this.cError = g_oBridgeFunc.GetLanguageText("XT| |MGRFINAN","BMS_INVALID_ADDR_ID")&&ERRC_INVALID_ADDR_ID
			RETURN
		ENDIF
	ENDPROC


	PROCEDURE SaveAccount
		LPARAMETERS tcError

		this.ResetError()
		this.ValidateAccount()
		this.UpdateTable("curBsacct", "__#SRV.BSACCT#__", "bb_bbid", "bsacct.dbf")
		* Mark card as deleted if used for another account id
		SELECT curBsCard
		SCAN FOR NOT bc_deleted AND NOT DELETED() AND RECNO() < 0
			this.SqlUpdate("UPDATE __#SRV.BSCARD#__ SET bc_deleted = (1=1) WHERE bc_cardid = " + SqlCnv(bc_cardid,.T.) + " AND bc_bbid <> " + SqlCnv(bc_bbid,.T.), "bscard.dbf")
		ENDSCAN
		this.UpdateTable("curBsCard", "__#SRV.BSCARD#__", "bc_bcid", "bscard.dbf")
		RETURN this.GetError(@tcError)
	ENDPROC


	PROCEDURE DeleteAccount
		LPARAMETERS tnAcctId, tcError

		IF this.nErrorCode = NO_ERROR
			this.SqlDelete("DELETE FROM __#SRV.BSCARD#__ WHERE bc_bbid = " + SqlCnv(tnAcctId,.T.), "bscard.dbf")
		ENDIF
		IF this.nErrorCode = NO_ERROR
			this.SqlDelete("DELETE FROM __#SRV.BSPOST#__ WHERE bs_bbid = " + SqlCnv(tnAcctId,.T.), "bspost.dbf")
		ENDIF
		IF this.nErrorCode = NO_ERROR
			this.SqlDelete("DELETE FROM __#SRV.BSACCT#__ WHERE bb_bbid = " + SqlCnv(tnAcctId,.T.), "bsacct.dbf")
		ENDIF

		RETURN this.GetError(@tcError)
	ENDPROC


	PROCEDURE DeletePoints
		LPARAMETERS tnBsPostId, tlCancel, tcError

		IF this.nErrorCode = NO_ERROR
			IF tlCancel
				this.SqlUpdate("UPDATE __#SRV.BSPOST#__ SET bs_cancel = (1=1) WHERE bs_bsid = " + SqlCnv(tnBsPostId,.T.), "bspost.dbf")
			ELSE
				this.SqlDelete("DELETE FROM __#SRV.BSPOST#__ WHERE bs_bsid = " + SqlCnv(tnBsPostId,.T.), "bspost.dbf")
			ENDIF
		ENDIF

		RETURN this.GetError(@tcError)
	ENDPROC


	PROCEDURE CancelPoints
		LPARAMETERS lp_cBillNum
		LOCAL l_nBb_bbid, lnNewId, lcSql, llSuccess

		IF EMPTY(lp_cBillNum)
			RETURN .F.
		ENDIF

		IF this.BMSTablesOnLine()
			* Mark all postings for bill as canceled

			SqlUpdate("__#SRV.BSPOST#__", "bs_billnum = " + SqlCnv(lp_cBillNum,.T.) + ;
				" AND bs_appl = " + SqlCnv(this.nApp,.T.) + ;
				" AND bs_hotcode = " + sqlcnv(this.pa_hotcode,.T.) + ;
				" AND NOT bs_cancel AND bs_type = " + TRANSFORM(BILL_POST), ;
				"bs_cancel = " + SqlCnv(.T.,.T.))
			llSuccess = .T.
		ELSE
			* Add into bspendin, to proccess is later. We add for whole bill only one record. For that bill, we will later mark all
			* records as canceled (bspost.bs_cancel = .T.)
			
			* TO DO: Check this process.

*!*				this.OpenTable("bspendin")
*!*				lnNewId = this.NextId("BSPENDIN")

*!*				TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
*!*					INSERT INTO curBspendin (bs_bsid,bs_bbid,bs_billnum,bs_cancel) 
*!*						VALUES (<<TRANSFORM(lnNewId)>>,<<TRANSFORM(0)>>,<<sqlcnv(lp_cBillNum,.T.)>>,<<sqlcnv(.T.,.T.)>>)
*!*				ENDTEXT

*!*				llSuccess = this.SqlInsert(lcSql, "bspendin.dbf")
*!*				this.CloseTable("curBspendin")
			llSuccess = .T.
		ENDIF
		RETURN llSuccess
	ENDPROC


	PROCEDURE CancelBonusPayment
		LPARAMETERS lp_nPostId
		LOCAL l_nBb_bbid, lnNewId, lcSql, llSuccess

		IF EMPTY(lp_nPostId)
			RETURN .F.
		ENDIF

		IF this.BMSTablesOnLine()
			* Mark bonus payment als canceled

			SqlUpdate("__#SRV.BSPOST#__", "bs_postid = " + SqlCnv(lp_nPostId,.T.) + ;
				" AND bs_appl = " + SqlCnv(this.nApp,.T.) + ;
				" AND bs_hotcode = " + sqlcnv(this.pa_hotcode,.T.) + ;
				" AND NOT bs_cancel AND bs_type = " + TRANSFORM(BILL_PAY), ;
				"bs_cancel = " + SqlCnv(.T.,.T.))
			llSuccess = .T.
		ENDIF
		
		RETURN llSuccess
	ENDPROC

	PROCEDURE UpdateBillNum
		* When bill is payed with bonus points, bill is not closed immedetly.
		* Later, when bill is closed, and receives new bill number, we must update records
		* in bspost table with this bill num.

		LPARAMETERS tnBbId, tcBillNum, tcCursor, lp_nAddrId, lp_nAdId
		LOCAL l_nBb_bbid, lnNewId, lcSql, llSuccess, lnSelect, l_nBb_bbid

		IF EMPTY(tcBillNum) OR EMPTY(tcCursor)
			RETURN .F.
		ENDIF

		lnSelect = SELECT()

		IF this.BMSTablesOnLine()
			IF EMPTY(tnBbId)
				l_nBb_bbid = this.GetBonusAccountByAddress(lp_nAddrId, lp_nAdId)
			ELSE
				l_nBb_bbid = tnBbId
			ENDIF
			SELECT &tcCursor
			SCAN ALL
				SqlUpdate("__#SRV.BSPOST#__", "bs_bbid = " + sqlcnv(l_nBb_bbid,.T.) + ;
					" AND bs_postid = " + SqlCnv(&tcCursor..ps_postid,.T.) + ;
					" AND bs_appl = " + SqlCnv(this.nApp,.T.) + ;
					" AND bs_hotcode = " + sqlcnv(this.pa_hotcode,.T.), ;
					"bs_billnum = " + SqlCnv(tcBillNum,.T.))
			ENDSCAN
			llSuccess = .T.
		ELSE
			* Add into bspendin, to proccess is later. We add for whole bill only one record. For that bill, we will later mark all
			* records as canceled (bspost.bs_cancel = .T.)

			* TO DO:
			* Process bspendin, when database offline!

*!*				this.OpenTable("bspendin")
*!*				lnNewId = this.NextId("BSPENDIN")

*!*				TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
*!*					INSERT INTO curBspendin (bs_bsid,bs_bbid,bs_billnum,bs_cancel) 
*!*						VALUES (<<TRANSFORM(lnNewId)>>,<<TRANSFORM(lp_nAddrId)>>,<<sqlcnv(lp_cBillNum,.T.)>>,<<sqlcnv(.T.,.T.)>>)
*!*				ENDTEXT

*!*				llSuccess = this.SqlInsert(lcSql, "bspendin.dbf")
*!*				this.CloseTable("curBspendin")
		ENDIF
		
		SELECT (lnSelect)
		
		RETURN llSuccess
	ENDPROC


	PROCEDURE UpdateTable
		LPARAMETERS tcCursor, tcTable, tcPrimaryKey, tcUpdatingTable
		LOCAL lnArea, lnRecNo, lnLastModifiedRec

		IF this.nErrorCode = NO_ERROR
			lnArea = SELECT()

			SELECT &tcCursor
			lnRecNo = RECNO()
			LOCATE
			lnLastModifiedRec = GETNEXTMODIFIED(0)
			DO WHILE this.nErrorCode = NO_ERROR AND lnLastModifiedRec <> 0
				GO lnLastModifiedRec
				IF GETFLDSTATE(0) <> 4
					this.UpdateRecord(tcTable, tcPrimaryKey, tcUpdatingTable)
				ENDIF
				lnLastModifiedRec = GETNEXTMODIFIED(lnLastModifiedRec)
			ENDDO
			GO lnRecNo

			SELECT (lnArea)
		ENDIF
	ENDPROC


	PROCEDURE UpdateRecord
		LPARAMETERS tcTable, tcPrimaryKey, tcUpdatingTable
		LOCAL i, lcSql, lcField, lcSet, lcFields, lcValues

		DO CASE
			CASE NOT DELETED() AND RECNO() < 0					&& inserted record
				lcFields = ""
				lcValues = ""
				FOR i = 1 TO FCOUNT()
					lcField = LOWER(FIELD(i))
					IF NOT EMPTY(&lcField)
						lcFields = lcFields + IIF(EMPTY(lcFields), "", ",") + lcField
						lcValues = lcValues + IIF(EMPTY(lcValues), "", ",") + SqlCnv(&lcField,.T.)
					ENDIF
				NEXT
				IF NOT EMPTY(lcFields)
					lcSql = "INSERT INTO " + tcTable + " (" + lcFields + ") VALUES (" + lcValues + ")"
					this.SqlInsert(lcSql, tcUpdatingTable)
				ENDIF
			CASE DELETED() AND RECNO() < 0					&& deleted appended record - ignore
			CASE NOT DELETED()								&& update record
				lcSet = ""
				FOR i = 1 TO FCOUNT()
					lcField = LOWER(FIELD(i))
					IF OLDVAL(lcField) <> &lcField
						lcSet = lcSet + IIF(EMPTY(lcSet), "", ",") + lcField + " = " + SqlCnv(&lcField,.T.)
					ENDIF
				NEXT
				IF NOT EMPTY(lcSet)
					lcSql = "UPDATE " + tcTable + " SET " + lcSet + " WHERE " + tcPrimaryKey + " = " + SqlCnv(OLDVAL(tcPrimaryKey),.T.)
					this.SqlUpdate(lcSql, tcUpdatingTable)
				ENDIF
			CASE DELETED()									&& delete record
				lcSql = "DELETE FROM " + tcTable + " WHERE " + tcPrimaryKey + " = " + SqlCnv(&tcPrimaryKey,.T.)
				this.SqlDelete(lcSql, tcUpdatingTable)
			OTHERWISE										&& unknown condition
		ENDCASE
	ENDPROC


	PROCEDURE GetBonusAccountByAddress
		LPARAMETERS tnAddrid, tnAdid
		LOCAL lnArea, lnBonusAccountId, lcSqlSelect
		LOCAL ARRAY laBsacct(1)

		lnBonusAccountId = 0
		IF NOT EMPTY(tnAddrid) OR NOT EMPTY(tnAdid)
			lnArea = SELECT()
			TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
				SELECT bb_bbid, bb_addrid, bb_adid, bb_inactiv FROM __#SRV.BSACCT#__
					WHERE <<IIF(EMPTY(tnAdid), "bb_addrid = " + SqlCnv(tnAddrid,.T.), "bb_adid = " + SqlCnv(tnAdid,.T.))>>
			ENDTEXT
			laBsacct(1) = .T.
			lcBsacct = this.SqlCursor(lcSqlSelect,,,,,,@laBsacct)
			IF NOT EMPTY(laBsacct(1))
				lnBonusAccountId = laBsacct(1)
			ENDIF
			SELECT (lnArea)
		ENDIF

		RETURN lnBonusAccountId
	ENDPROC


	PROCEDURE GetVipStatusDiscount
		LPARAMETERS tnBonusAccountId, tcDiscCode, tnDiscPct
		LOCAL lnArea, lcSqlSelect, lcVipStatus, lcurBsacct, lcurVipStatus, lnAdid, lnAddrid

		lnArea = SELECT()

		lcVipStatus = ""
		tcDiscCode = ""
		tnDiscPct = 0
		lcurBsacct = this.SqlCursor("SELECT * FROM __#SRV.BSACCT#__ WHERE bb_bbid = " + SqlCnv(tnBonusAccountId,.T.))
		IF USED(lcurBsacct)
			lnAdid = &lcurBsacct..bb_adid
			lnAddrid = &lcurBsacct..bb_addrid
			DClose(lcurBsacct)
			IF NOT EMPTY(lnAdid) OR NOT EMPTY(lnAddrid)
				TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
					SELECT NVL(vs.pl_lang<<this.cDeskLangnum>>,'') AS pl_vipstat, NVL(dc.pl_charcod,'') AS pl_disccod, NVL(dc.pl_numval,0) AS pl_discpct
						FROM <<IIF(EMPTY(lnAdid), "__#SRV.ADDRESS#__", "__#SRV.ADRMAIN#__")>>
						LEFT JOIN __#SRV.PICKLIST vs#__ ON vs.pl_label = 'VIPSTATUS ' AND vs.pl_numcod = ad_vipstat
						LEFT JOIN __#SRV.PICKLIST dc#__ ON dc.pl_label = 'BILLDISCNT' AND dc.pl_charcod = vs.pl_user2
						WHERE <<IIF(EMPTY(lnAdid), "ad_addrid = " + SqlCnv(lnAddrid,.T.), "ad_adid = " + SqlCnv(lnAdid,.T.))>>
				ENDTEXT
				lcurVipStatus = this.SqlCursor(lcSqlSelect)
				lcVipStatus = &lcurVipStatus..pl_vipstat
				tcDiscCode = &lcurVipStatus..pl_disccod
				tnDiscPct = &lcurVipStatus..pl_discpct
				DClose(lcurVipStatus)
			ENDIF
		ENDIF

		SELECT (lnArea)

		RETURN lcVipStatus
	ENDPROC


	PROCEDURE CheckBonusAccount
		LPARAMETERS tnAddrid, tnBonusAccountId, tnPurpose, tlDontCopyInBsPending, tnbonuscardid, tlDontUseCardReader
		* tnPurpose = GENERATE_POINTS	; generating bonus points for bill
		* tnPurpose = USE_DISCOUNT	; using a discount based on VIP status
		LOCAL lcSqlSelect, lcBsacct, llSuccess, lnAdid, llReInsertCard, llRightCardSelected

		IF EMPTY(tnPurpose)
			tnPurpose = USE_DEFAULT
		ENDIF
		lnAdid = 0
		IF NOT EMPTY(tnAddrid)
			lcAddress = this.SqlCursor("SELECT ad_adid FROM __#DESK.ADDRESS#__ WHERE ad_addrid = " + SqlCnv(tnAddrid,.T.))
			lnAdid = IIF(USED(lcAddress), &lcAddress..ad_adid, 0)
			DClose(lcAddress)
		ENDIF

		llReInsertCard = .T. && Is posssible that user inserts wrong card. So here we add possibility, to user, to insert another card.
		DO WHILE llReInsertCard
			llReInsertCard = .F.
			tnBonusAccountId = 0
			tnbonuscardid = 0
			tlDontCopyInBsPending = .F. && .T. when user don't wannt to post bonus points, when using card reader. Then is llSuccess = .F., but we don't wannt to insert posting into bspending table.
			DO CASE
				CASE TYPE("_screen.oCardReaderHandler.lAvailable") <> "L"
					* Card reader module not installed. (Orderman?)
				CASE tlDontUseCardReader OR NOT _screen.oCardReaderHandler.lAvailable OR TYPE("plAutomatic") = "L" AND plAutomatic
					IF NOT EMPTY(tnAddrid)
						TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
							SELECT bb_bbid, bb_inactiv FROM __#SRV.BSACCT#__
								WHERE <<IIF(EMPTY(lnAdid),"bb_addrid = " + SqlCnv(tnAddrid,.T.), "bb_adid = " + SqlCnv(lnAdid,.T.))>>
						ENDTEXT
						lcBsacct = this.SqlCursor(lcSqlSelect)
						DO CASE
							CASE NOT USED(lcBsacct)
								* BMS database is not accessible!
								_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1369|CARDREADER","BMS is not reachable."))
							CASE RECCOUNT(lcBsacct) = 0
								IF tnPurpose = USE_DEFAULT
									_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1374|CARDREADER","No account in system for this customer."))
								ENDIF
							CASE tnPurpose = GENERATE_POINTS AND NOT (this.lAutoGeneratePoints OR this.pa_bmstype = 1 OR _screen.oCardReaderHandler.Msgbox(48+4, g_oBridgeFunc.GetLanguageText("A|1371|CARDREADER","Do you want to generate bonus points for bill?")))
							CASE tnPurpose = USE_DISCOUNT AND NOT (this.lAutoDiscount OR _screen.oCardReaderHandler.Msgbox(48+4, g_oBridgeFunc.GetLanguageText("A|1385|CARDREADER","Do you want to use a discount based on VIP status?")))
							CASE &lcBsacct..bb_inactiv
								_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1373|CARDREADER","This account is not active."))
							OTHERWISE
								llSuccess = .T.
								tnBonusAccountId = &lcBsacct..bb_bbid
						ENDCASE
					ENDIF
				CASE tnPurpose = GENERATE_POINTS AND NOT (this.lAutoGeneratePoints OR _screen.oCardReaderHandler.Msgbox(48+4, g_oBridgeFunc.GetLanguageText("A|1371|CARDREADER","Do you want to generate bonus points for bill?")))
					tlDontCopyInBsPending = .T.
				CASE tnPurpose = USE_DISCOUNT AND NOT (this.lAutoDiscount OR _screen.oCardReaderHandler.Msgbox(48+4, g_oBridgeFunc.GetLanguageText("A|1385|CARDREADER","Do you want to use a discount based on VIP status?")))
				CASE (tnPurpose <> USE_DEFAULT AND this.lAutoGeneratePoints AND this.lAutoDiscount OR _screen.oCardReaderHandler.WaitForCard("BMS")) AND ;
						 NOT EMPTY(_screen.oCardReaderHandler.Content.BonusAccountId)
					TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
						SELECT bb_addrid, bb_adid, bb_inactiv, bc_bcid FROM __#SRV.BSACCT#__
							INNER JOIN __#SRV.BSCARD#__ ON bc_bbid = bb_bbid AND NOT bc_deleted
							WHERE bb_bbid = <<SqlCnv(_screen.oCardReaderHandler.Content.BonusAccountId,.T.)>> AND
							bc_cardid = <<SqlCnv(_screen.oCardReaderHandler.cCardId,.T.)>>
					ENDTEXT
					lcBsacct = this.SqlCursor(lcSqlSelect)
					DO CASE
						CASE NOT USED(lcBsacct)
							* BMS database is not accessible!
							_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1369|CARDREADER","BMS is not reachable."))
						CASE RECCOUNT(lcBsacct) = 0
							*_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1372|CARDREADER","No account in system for this card."))
							*llReInsertCard = _screen.oCardReaderHandler.ReinsertCard()
						CASE &lcBsacct..bb_inactiv
							*_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1373|CARDREADER","This account is not active."))
							*llReInsertCard = _screen.oCardReaderHandler.ReinsertCard()
						OTHERWISE
							llRightCardSelected = IIF(EMPTY(lnAdid), tnAddrid = &lcBsacct..bb_addrid, lnAdid = &lcBsacct..bb_adid)
							IF NOT llRightCardSelected
								llReInsertCard = _screen.oCardReaderHandler.ReinsertCard()
								IF NOT llReInsertCard
									llRightCardSelected = .T.
								ENDIF
							ENDIF
							IF llRightCardSelected
								llSuccess = .T.
								tnBonusAccountId = _screen.oCardReaderHandler.Content.BonusAccountId
								tnbonuscardid = &lcBsacct..bc_bcid
							ENDIF
					ENDCASE
				OTHERWISE
			ENDCASE
			DClose(lcBsacct)
		ENDDO
		RETURN llSuccess
	ENDPROC


	PROCEDURE SpendBonusPoints
		LPARAMETERS tcDonated, tnBonusAccountId, tnAvailablePoints, tnPayAmount, tnPoints, tnbonuscardid
		LOCAL lcSql, lcValues, lnPrice, lnQuantity, lnPoints

		tnPayAmount = 0
		tnPoints = 0
		IF EMPTY(tnbonuscardid)
			tnbonuscardid = 0
		ENDIF
		SELECT &tcDonated
		SCAN FOR c_selected
			DO CASE
				CASE this.nApp = DESK
					lnPrice = ps_price
					lnQuantity = ps_units
					lnPoints = lnQuantity * ROUND(lnPrice / ar_bsdbamt, 0)
					lcValues = SqlCnv(this.NextId("__#SRV.BSPOST#__",,.T.),.T.) + "," + ;
							   SqlCnv(tnBonusAccountId,.T.) + "," + ;
							   SqlCnv(this.nApp,.T.) + "," + ;
							   SqlCnv(BILL_PAY,.T.) + "," + ;
							   SqlCnv(ps_postid,.T.) + "," + ;
							   SqlCnv(this.pa_hotcode,.T.) + "," + ;
							   SqlCnv(ps_artinum,.T.) + "," + ;
							   SqlCnv(ar_lang,.T.) + "," + ;
							   SqlCnv(lnQuantity,.T.) + "," + ;
							   SqlCnv(lnQuantity*lnPrice,.T.) + "," + ;
							   SqlCnv(DATETIME(),.T.) + "," + ;
							   SqlCnv(-lnPoints,.T.) + "," + ;
							   SqlCnv(this.dSysDate,.T.) + "," + ;
							   SqlCnv(this.cUserId,.T.) + "," + ;
							   SqlCnv(this.nWaiterNr,.T.)
				CASE this.nApp = TERMINAL
					lnPrice = or_prc - ROUND(or_prc * or_discpct / 100, 2)
					lnQuantity = or_qty
					lnPoints = lnQuantity * ROUND(lnPrice / ar_bsdbamt, 0)
					lcValues = SqlCnv(this.NextId("__#SRV.BSPOST#__",,.T.),.T.) + "," + ;
							   SqlCnv(tnBonusAccountId,.T.) + "," + ;
							   SqlCnv(this.nApp,.T.) + "," + ;
							   SqlCnv(BILL_PAY,.T.) + "," + ;
							   SqlCnv(or_orderid,.T.) + "," + ;
							   SqlCnv("",.T.) + "," + ;
							   SqlCnv(or_artid,.T.) + "," + ;
							   SqlCnv(or_ldescr,.T.) + "," + ;
							   SqlCnv(lnQuantity,.T.) + "," + ;
							   SqlCnv(lnQuantity*lnPrice,.T.) + "," + ;
							   SqlCnv(DATETIME(),.T.) + "," + ;
							   SqlCnv(-lnPoints,.T.) + "," + ;
							   SqlCnv(this.dSysDate,.T.) + "," + ;
							   SqlCnv(this.cUserId,.T.) + "," + ;
							   SqlCnv(this.nWaiterNr,.T.)
				CASE this.nApp = WELLNESS
					lnPrice = ps_price
					lnQuantity = ps_qty
					lnPoints = lnQuantity * ROUND(lnPrice / ar_bsdbamt, 0)
					lcValues = SqlCnv(this.NextId("__#SRV.BSPOST#__",,.T.),.T.) + "," + ;
							   SqlCnv(tnBonusAccountId,.T.) + "," + ;
							   SqlCnv(this.nApp,.T.) + "," + ;
							   SqlCnv(BILL_PAY,.T.) + "," + ;
							   SqlCnv(ps_postid,.T.) + "," + ;
							   SqlCnv("",.T.) + "," + ;
							   SqlCnv(ar_plu,.T.) + "," + ;
							   SqlCnv(ar_descrip,.T.) + "," + ;
							   SqlCnv(lnQuantity,.T.) + "," + ;
							   SqlCnv(lnQuantity*lnPrice,.T.) + "," + ;
							   SqlCnv(DATETIME(),.T.) + "," + ;
							   SqlCnv(-lnPoints,.T.) + "," + ;
							   SqlCnv(this.dSysDate,.T.) + "," + ;
							   SqlCnv(this.cUserId,.T.) + "," + ;
							   SqlCnv(this.nWaiterNr,.T.)
				OTHERWISE
					EXIT
			ENDCASE
			lcSql = "INSERT INTO __#SRV.BSPOST#__ (bs_bsid,bs_bbid,bs_appl,bs_type,bs_postid,bs_hotcode,bs_artinum,bs_descrip,bs_qty,bs_amount,bs_date,bs_points,bs_sysdate,bs_userid,bs_waitnr,bs_bcid)" + ;
				" VALUES (" + lcValues + ","+sqlcnv(tnbonuscardid,.T.) + ")"
			IF lnPoints <= tnAvailablePoints AND this.SqlInsert(lcSql, "bspost.dbf")
				tnAvailablePoints = tnAvailablePoints - lnPoints
				tnPayAmount = tnPayAmount + lnQuantity*lnPrice
				tnPoints = tnPoints + lnPoints
			ELSE
				BLANK FIELDS c_selected IN &tcDonated
			ENDIF
		ENDSCAN
	ENDPROC


	PROCEDURE SetBonusPayment
		LPARAMETERS tcDonated, tnBonusAccountId, tnPostId, tnPayAmount, tnPoints, tnbonuscardid
		LOCAL lcSql, lcValues, lnBspayid, lnBspostid
		IF EMPTY(tnbonuscardid)
			tnbonuscardid = 0
		ENDIF
		lnBspayid = this.NextId("__#SRV.BSPOST#__",,.T.)
		lcValues = SqlCnv(lnBspayid,.T.) + "," + ;
				   SqlCnv(lnBspayid,.T.) + "," + ;
				   SqlCnv(tnBonusAccountId,.T.) + "," + ;
				   SqlCnv(this.nApp,.T.) + "," + ;
				   SqlCnv(BILL_PAY,.T.) + "," + ;
				   SqlCnv(tnPostId,.T.) + "," + ;
				   SqlCnv(this.pa_hotcode,.T.) + "," + ;
				   SqlCnv(g_oBridgeFunc.GetLanguageText("XT| |BILL","Points redeem"),.T.) + "," + ;
				   "1," + ;
				   SqlCnv(tnPayAmount,.T.) + "," + ;
				   SqlCnv(DATETIME(),.T.) + "," + ;
				   SqlCnv(-tnPoints,.T.) + "," + ;
				   SqlCnv(this.dSysDate,.T.) + "," + ;
				   SqlCnv(this.cUserId,.T.) + "," + ;
				   SqlCnv(this.nWaiterNr,.T.)
		lcSql = "INSERT INTO __#SRV.BSPOST#__ (bs_bsid,bs_bspayid,bs_bbid,bs_appl,bs_type,bs_postid,bs_hotcode,bs_descrip,bs_qty,bs_amount,bs_date,bs_points,bs_sysdate,bs_userid,bs_waitnr,bs_bcid)" + ;
			" VALUES (" + lcValues + ","+sqlcnv(tnbonuscardid,.T.) + ")"
		this.SqlInsert(lcSql, "bspost.dbf")
		SELECT &tcDonated
		SCAN FOR c_selected
			DO CASE
				CASE this.nApp = DESK
					lnBspostid = ps_postid
				CASE this.nApp = TERMINAL
					lnBspostid = or_orderid
				CASE this.nApp = WELLNESS
					lnBspostid = ps_postid
				OTHERWISE
					EXIT
			ENDCASE
			this.SqlUpdate("UPDATE __#SRV.BSPOST#__ SET bs_bspayid = "+SqlCnv(lnBspayid,.T.)+" WHERE bs_postid = " + SqlCnv(lnBspostid,.T.), "bspost.dbf")
		ENDSCAN
	ENDPROC


	PROCEDURE ProceedPendingBonus
		LOCAL i, lcSql, lcFields, lcValues, llOpenedBspendin, llOpenedBspost, llSuccess, lnBsId, lnStoredAddrId, lcAddress, lnAdid, ;
				lnNewId, lcField, luValue, lnBbId

		lcFields = "bs_bbid,bs_appl,bs_type,bs_billnum,bs_postid,bs_hotcode,bs_artinum,bs_descrip,bs_qty,bs_amount,bs_date,bs_points,bs_sysdate,bs_userid,bs_vdate,bs_waitnr"
		this.OpenTable("bspendin", @llOpenedBspendin)
		SELECT curBspendin
		SCAN ALL
			IF NOT this.BMSTablesOnLine()
				EXIT
			ENDIF
			lnStoredAddrId = curBspendin.bs_bbid
			lcAddress = this.SqlCursor("SELECT ad_adid FROM __#DESK.ADDRESS#__ WHERE ad_addrid = " + SqlCnv(lnStoredAddrId,.T.))
			lnAdid = IIF(USED(lcAddress), &lcAddress..ad_adid, 0)
			dclose(lcAddress)
			lnBbId = this.GetBonusAccountByAddress(lnStoredAddrId,lnAdid)
			SELECT curBspendin
			IF lnBbId > 0
				* We found bms account for this address. This was realy BMS post.
				IF curBspendin.bs_cancel
					* This is bill cancel. We have 1 record to cancel all bill records
					SqlUpdate("__#SRV.BSPOST#__", "bs_bbid = " + sqlcnv(lnBbId,.T.) + ;
						" AND bs_billnum = " + SqlCnv(curBspendin.bs_billnum,.T.) + ;
						" AND bs_appl = " + SqlCnv(this.nApp,.T.) + ;
						" AND bs_hotcode = " + sqlcnv(this.pa_hotcode,.T.) + ;
						" AND NOT bs_cancel", ;
						"bs_cancel = " + SqlCnv(.T.,.T.))
					llSuccess = .T.
				ELSE
					* New posting for bspost
					lcValues = ""
					FOR i = 1 TO GETWORDCOUNT(lcFields,",")
						lcField = ALLTRIM(LOWER(GETWORDNUM(lcFields,i,",")))
						IF lcField == "bs_bbid"
							luValue = lnBbId
						ELSE
							luValue = EVALUATE(lcField)
						ENDIF
						lcValues = lcValues + IIF(EMPTY(lcValues),"",",") + SqlCnv(luValue,.T.)
					NEXT
					lnNewId = this.NextId("__#SRV.BSPOST#__",,.T.)
					IF lnNewId > 0
						lcSql = "INSERT INTO __#SRV.BSPOST#__ (bs_bsid," + lcFields + ") VALUES (" + SqlCnv(lnNewId,.T.) + "," + lcValues + ")"
						llSuccess = this.SqlInsert(lcSql, "bspost.dbf")
					ELSE
						llSuccess = .F.
					ENDIF
				ENDIF
			ELSE
				* NO BMS account found for this address. Delete this pending record.
				llSuccess = .T.
			ENDIF
			IF llSuccess
				DELETE IN curBspendin
			ELSE
				EXIT
			ENDIF
		ENDSCAN
		this.CloseTable("curBspendin", llOpenedBspendin)
	ENDPROC


	PROCEDURE NextId
		LPARAMETERS tcCode, tuLast, tlFromMain
		* Initialize ID for tcCode

		LOCAL luLastID, lnArea, llTableOpen, lcCodeField, llSuccess, loDatabaseProp 

		tcCode = UPPER(this.SqlParseTables(tcCode,,.T.))
		DO CASE
			CASE ISNULL(gcUseDatabase)
				gcUseDatabase = ""
			CASE NOT EMPTY(gcUseDatabase)
				loDatabaseProp = goDatabases.Item(gcUseDatabase)
				luLastID = SqlRemote("EVAL", "NextId('"+TRANSFORM(tcCode)+"',"+TRANSFORM(tuLast)+","+TRANSFORM(tlFromMain)+")",, ;
					loDatabaseProp.cApplication,,@llSuccess, loDatabaseProp.cServerName, loDatabaseProp.nServerPort, loDatabaseProp.lEncrypt)
				IF NOT llSuccess
					luLastID = 0
				ENDIF
				gcUseDatabase = ""
			OTHERWISE
		ENDCASE

		IF EMPTY(luLastID)
			lnArea = SELECT()

			tcCode = UPPER(PADR(tcCode,8))

			* Which id table is needed? Open table if needed. Don't close it here, to prevent overhead of opening id table
			* for every record.
			IF tlFromMain
				lcIdTableName = "idmain"
				IF USED(lcIdTableName)
					llTableOpen = .T.
				ELSE
					* Must use SQL to use table.
					lcCur = this.SqlCursor("SELECT * FROM __#SRV.IDMAIN#__ WHERE 0=1",,,,,,,,,.T.)
					IF USED(lcCur) AND USED(lcIdTableName)
						llTableOpen = .T.
						dclose(lcCur)
					ENDIF
				ENDIF
			ELSE
				lcIdTableName = "id"
				IF USED(lcIdTableName)
					llTableOpen = .T.
				ELSE
					llTableOpen = this.OpenTable("id",,.T.)
				ENDIF
			ENDIF

			IF NOT llTableOpen
				* Return as -1, to mark this case (couldn't open table)
				luLastID = -1
				RETURN luLastID
			ENDIF
			
			SELECT (lcIdTableName)
			lcCodeField = IIF(TYPE("id_name")="C", "id_name","id_code")
			LOCATE FOR &lcCodeField = tcCode
			IF FOUND()
				IF LOCK()
					luLastID = id_last + 1
					REPLACE id_last WITH luLastID
					FLUSH
				ENDIF
				UNLOCK
			ELSE
				luLastID =  1
				INSERT INTO (lcIdTableName) (&lcCodeField, id_last) VALUES (tcCode, luLastID)
			ENDIF
			SELECT(lnArea)
		ENDIF

		RETURN luLastID
	ENDPROC


	PROCEDURE GetBonusPoints
		LPARAMETERS tnBonusAccountId, tnAvailablePoints, tnCollectedPoints, tnSpentPoints
		LOCAL lnArea, lcBspost, lcSqlSelect, lcBsCredit, lcBsDebt, lnPoints, lnActivePoints, lnSpentPoints

		lnArea = SELECT()
		tnAvailablePoints = 0
		tnCollectedPoints = 0
		tnSpentPoints = 0
		TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
			SELECT bs_bsid, bs_bspayid, bs_postid, bs_hotcode, bs_appl, bs_points, bs_type, bs_sysdate, bs_vdate FROM __#SRV.BSPOST#__
				WHERE bs_bbid = <<SqlCnv(tnBonusAccountId,.T.)>> AND NOT bs_cancel
		ENDTEXT
		lcBspost = this.SqlCursor(lcSqlSelect,,,,,,,.T.)
		IF EMPTY(lcBspost) OR NOT USED(lcBspost)
			_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1369|CARDREADER","BMS is not reachable."))
		ELSE
			IF DLocate(lcBspost, "NOT EMPTY(bs_vdate)")
				lcBsCredit = SYS(2015)
				lcBsDebt = SYS(2015)
				SELECT *, IIF(EMPTY(bs_vdate),'99999999',DTOS(bs_vdate)) AS c_vdate FROM &lcBspost ;
					WHERE INLIST(bs_type, BILL_POST, MANUAL_EARN) ;
					ORDER BY bs_sysdate, c_vdate ;
					INTO CURSOR &lcBsCredit READWRITE
				CALCULATE SUM(bs_points) TO tnCollectedPoints IN &lcBsCredit
				SELECT * FROM &lcBspost ;
					WHERE INLIST(bs_type, BILL_PAY, MANUAL_SPENT) AND (bs_bspayid = 0 OR bs_bsid = bs_bspayid) ;
					INTO CURSOR &lcBsDebt READWRITE
				INDEX ON bs_sysdate TAG bs_sysdate
				SET ORDER TO
				CALCULATE SUM(-bs_points) TO tnSpentPoints IN &lcBsDebt
				SELECT &lcBsCredit
				SCAN
					SELECT &lcBsDebt
					SCAN FOR &lcBsDebt..bs_points < 0 AND &lcBsCredit..bs_points > 0 AND (EMPTY(&lcBsCredit..bs_vdate) OR &lcBsDebt..bs_sysdate <= &lcBsCredit..bs_vdate)
						lnPoints = MIN(&lcBsCredit..bs_points, -&lcBsDebt..bs_points)
						REPLACE bs_points WITH bs_points - lnPoints IN &lcBsCredit
						REPLACE bs_points WITH bs_points + lnPoints IN &lcBsDebt
						IF &lcBsCredit..bs_points <= 0
							EXIT
						ENDIF
					ENDSCAN
					SELECT &lcBsCredit
					IF &lcBsCredit..bs_points > 0 AND NOT EMPTY(&lcBsCredit..bs_vdate) AND &lcBsCredit..bs_vdate < this.dSysDate
						REPLACE bs_points WITH 0 IN &lcBsCredit
					ENDIF
				ENDSCAN
				CALCULATE SUM(bs_points) TO lnActivePoints IN &lcBsCredit
				CALCULATE SUM(-bs_points) TO lnSpentPoints IN &lcBsDebt
				tnAvailablePoints = lnActivePoints - lnSpentPoints
				DClose(lcBsCredit)
				DClose(lcBsDebt)
			ELSE
				CALCULATE SUM(bs_points) FOR INLIST(bs_type, BILL_POST, MANUAL_EARN) TO tnCollectedPoints IN &lcBspost
				CALCULATE SUM(-bs_points) FOR INLIST(bs_type, BILL_PAY, MANUAL_SPENT) AND (bs_bspayid = 0 OR bs_bsid = bs_bspayid) TO tnSpentPoints IN &lcBspost
				tnAvailablePoints = tnCollectedPoints - tnSpentPoints
			ENDIF
			tnAvailablePoints = INT(tnAvailablePoints)
			tnCollectedPoints = INT(tnCollectedPoints)
			tnSpentPoints = INT(tnSpentPoints)
		ENDIF
		IF PCOUNT() > 2
			DClose(lcBspost)
		ENDIF
		SELECT (lnArea)

		RETURN lcBspost
	ENDPROC


	PROCEDURE AddBonusPoints
		LPARAMETERS tnAcctId, tnAddPoints, tcDescription, tcNote, tlSpent
		LOCAL lcValues, lcSql, llOpenedBspendin, llSuccess, lnBsId

		this.OpenTable("bspendin", @llOpenedBspendin)
		lnBsId = this.NextId("__#SRV.BSPOST#__",,.T.)
		tcNote = STRTRAN(tcNote, CHR(13)+CHR(10)," ")
		tcNote = STRTRAN(tcNote, CHR(13),"")
		tcNote = STRTRAN(tcNote, CHR(10),"")
		lcValues = SqlCnv(lnBsId,.T.) + "," + ;
				   SqlCnv(tnAcctId,.T.) + "," + ;
				   SqlCnv(this.nApp,.T.) + "," + ;
				   SqlCnv(IIF(tlSpent, MANUAL_SPENT, MANUAL_EARN),.T.) + "," + ;
				   SqlCnv(tcDescription,.T.) + "," + ;
				   SqlCnv(tcNote,.T.) + "," + ;
				   "1," + ;
				   SqlCnv(DATETIME(),.T.) + "," + ;
				   SqlCnv(tnAddPoints,.T.) + "," + ;
				   SqlCnv(this.dSysDate,.T.) + "," + ;
				   SqlCnv(this.cUserId,.T.) + "," + ;
				   SqlCnv(this.nWaiterNr,.T.) + "," + ;
				   IIF(EMPTY(this.pa_bsdays) OR tlSpent, "__EMPTY_DATE__", SqlCnv(this.dSysDate+this.pa_bsdays,.T.))
		lcSql = "INSERT INTO __#SRV.BSPOST#__ (bs_bsid,bs_bbid,bs_appl,bs_type,bs_descrip,bs_note,bs_qty,bs_date,bs_points,bs_sysdate,bs_userid,bs_waitnr,bs_vdate)" + ;
			" VALUES (" + lcValues + ")"
		IF NOT this.SqlInsert(lcSql, "bspost.dbf")
			lcSql = STRTRAN(lcSql, "__#SRV.BSPOST#__", "curBspendin")
			llSuccess = this.SqlInsert(lcSql, "bspendin.dbf")
			_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1369|CARDREADER","BMS is not reachable."))
		ENDIF
		this.CloseTable("curBspendin", llOpenedBspendin)
		RETURN lnBsId
	ENDPROC


	PROCEDURE GenerateBonusPoints
		LPARAMETERS tcurBonusArticles, tnBonusAccountId, tlInsertIntoPending, tnAddrId, tnbonuscardid
		LOCAL lcValues, lnPrice, lnPoints, lcSql, llOpenedBspendin, llSuccess, llShowMessage, llNewId, lnBonusAccountId
		llShowMessage = .T.
		IF EMPTY(tnbonuscardid)
			tnbonuscardid = 0
		ENDIF

		IF tlInsertIntoPending
			* If inserting into pending table as account id use tnAddrId.
			* When we later insert this record from bspendin into bspost, we will find real bs_bbid. When not found, then ignore this record.
			lnBonusAccountId = tnAddrId
			this.OpenTable("bspendin", @llOpenedBspendin)
		ELSE
			lnBonusAccountId = tnBonusAccountId
		ENDIF

		SELECT &tcurBonusArticles
		SCAN
			lnPoints = 0
			IF tlInsertIntoPending
				* If inserting into pending table, get id from local table.
				llNewId = this.NextId("BSPENDIN")
			ELSE
				llNewId = this.NextId("__#SRV.BSPOST#__",,.T.)
			ENDIF
			DO CASE
				CASE this.nApp = DESK
					lnPrice = ps_price
					lnPoints = ps_units * ROUND(ar_bscramt * lnPrice, 0)
					IF lnPoints <> 0
						lcValues = SqlCnv(llNewId,.T.) + "," + ;
								   SqlCnv(lnBonusAccountId,.T.) + "," + ;
								   SqlCnv(this.nApp,.T.) + "," + ;
								   SqlCnv(BILL_POST,.T.) + "," + ;
								   SqlCnv(ps_billnum,.T.) + "," + ;
								   SqlCnv(ps_postid,.T.) + "," + ;
								   SqlCnv(this.pa_hotcode,.T.) + "," + ;
								   SqlCnv(ps_artinum,.T.) + "," + ;
								   SqlCnv(ar_lang,.T.) + "," + ;
								   SqlCnv(ps_units,.T.) + "," + ;
								   SqlCnv(ps_units*lnPrice,.T.) + "," + ;
								   SqlCnv(DATETIME(),.T.) + "," + ;
								   SqlCnv(lnPoints,.T.) + "," + ;
								   SqlCnv(this.dSysDate,.T.) + "," + ;
								   SqlCnv(this.cUserId,.T.) + "," + ;
								   SqlCnv(this.nWaiterNr,.T.) + "," + ;
								   IIF(EMPTY(MAX(ar_bsdays,this.pa_bsdays)), "__EMPTY_DATE__", SqlCnv(this.dSysDate+MAX(ar_bsdays,this.pa_bsdays),.T.))
					ENDIF
				CASE this.nApp = TERMINAL
					lnPrice = or_prc - ROUND(or_prc * or_discpct / 100, 2)
					lnPoints = or_qty * ROUND(ar_bscramt * lnPrice, 0)
					IF lnPoints <> 0
						lcValues = SqlCnv(llNewId,.T.) + "," + ;
								   SqlCnv(lnBonusAccountId,.T.) + "," + ;
								   SqlCnv(this.nApp,.T.) + "," + ;
								   SqlCnv(BILL_POST,.T.) + "," + ;
								   SqlCnv(TRANSFORM(ck_billnum),.T.) + "," + ;
								   SqlCnv(or_orderid,.T.) + "," + ;
								   SqlCnv("",.T.) + "," + ;
								   SqlCnv(ar_plu,.T.) + "," + ;
								   SqlCnv(or_ldescr,.T.) + "," + ;
								   SqlCnv(or_qty,.T.) + "," + ;
								   SqlCnv(or_qty*lnPrice,.T.) + "," + ;
								   SqlCnv(DATETIME(),.T.) + "," + ;
								   SqlCnv(lnPoints,.T.) + "," + ;
								   SqlCnv(this.dSysDate,.T.) + "," + ;
								   SqlCnv(this.cUserId,.T.) + "," + ;
								   SqlCnv(this.nWaiterNr,.T.) + "," + ;
								   IIF(EMPTY(MAX(ar_bsdays,this.pa_bsdays)), "__EMPTY_DATE__", SqlCnv(this.dSysDate+MAX(ar_bsdays,this.pa_bsdays),.T.))
					ENDIF
				CASE this.nApp = WELLNESS
					lnPrice = ps_price
					lnPoints = ps_qty * ROUND(ar_bscramt * lnPrice, 0)
					IF lnPoints <> 0
						lcValues = SqlCnv(llNewId,.T.) + "," + ;
								   SqlCnv(lnBonusAccountId,.T.) + "," + ;
								   SqlCnv(this.nApp,.T.) + "," + ;
								   SqlCnv(BILL_POST,.T.) + "," + ;
								   SqlCnv(TRANSFORM(ck_billnum),.T.) + "," + ;
								   SqlCnv(ps_postid,.T.) + "," + ;
								   SqlCnv("",.T.) + "," + ;
								   SqlCnv(ar_plu,.T.) + "," + ;
								   SqlCnv(ar_descrip,.T.) + "," + ;
								   SqlCnv(ps_qty,.T.) + "," + ;
								   SqlCnv(ps_qty*lnPrice,.T.) + "," + ;
								   SqlCnv(DATETIME(),.T.) + "," + ;
								   SqlCnv(lnPoints,.T.) + "," + ;
								   SqlCnv(this.dSysDate,.T.) + "," + ;
								   SqlCnv(this.cUserId,.T.) + "," + ;
								   SqlCnv(this.nWaiterNr,.T.) + "," + ;
								   IIF(EMPTY(MAX(ar_bsdays,this.pa_bsdays)), "__EMPTY_DATE__", SqlCnv(this.dSysDate+MAX(ar_bsdays,this.pa_bsdays),.T.))
					ENDIF
				OTHERWISE
					EXIT
			ENDCASE
			IF lnPoints <> 0
				lcSql = "INSERT INTO __#SRV.BSPOST#__ (bs_bsid,bs_bbid,bs_appl,bs_type,bs_billnum,bs_postid,bs_hotcode,bs_artinum,bs_descrip,bs_qty,bs_amount,bs_date,bs_points,bs_sysdate,bs_userid,bs_waitnr,bs_vdate,bs_bcid)" + ;
					" VALUES (" + lcValues + ","+sqlcnv(tnbonuscardid,.T.)+")"

				IF tlInsertIntoPending
					llSuccess = .F.
				ELSE
					llSuccess = this.SqlInsert(lcSql, "bspost.dbf")
				ENDIF
				IF NOT llSuccess
					lcSql = STRTRAN(lcSql, "__#SRV.BSPOST#__", "curBspendin")
					llSuccess = this.SqlInsert(lcSql, "bspendin.dbf")
					IF llShowMessage
						llShowMessage = .F.
						_screen.oCardReaderHandler.Msgbox(48+0, g_oBridgeFunc.GetLanguageText("A|1369|CARDREADER","BMS is not reachable."))
					ENDIF
				ENDIF
			ENDIF
		ENDSCAN
		this.CloseTable("curBspendin", llOpenedBspendin)
		RETURN llSuccess
	ENDPROC


	PROCEDURE SqlParseTables
		LPARAMETERS tcSql, tlAddAlias, tlDontAddPath
		LOCAL lcSql

		lcSql = tcSql
		DO SqlParseTables IN SqlParse WITH lcSql, tlAddAlias, tlDontAddPath

		RETURN lcSql
	ENDPROC


	PROCEDURE SqlCursor
		LPARAMETERS tcSql, tcCursor, tlNoFilter, tcSqldef, toParam, tlRemoveSign, taResult, tlRW, tlEB90, tlDontCloseTables, tlDeleteOff
		EXTERNAL ARRAY taResult
		LOCAL lcSql, llSuccess

		IF EMPTY(tcCursor)
			tcCursor = SYS(2015)
		ENDIF
		IF tlRemoveSign
			tcSql = STRTRAN(tcSql, ";") && Remove ; line breaks, to allow macro execution
		ENDIF
		IF Odbc()
			IF USED(tcCursor)
				USE IN (tcCursor)
			ENDIF
			* Result cursor from SQLEXEC is always READWRITE! But when used, we must first close it, and prevent SQLEXEC
			* to populate same cursor again, and eventualy issue error 1545
		ELSE
			tlNoFilter = .T. && Always .T., to prevent RECCOUNT() te return wrong number of records.
			tcSql = tcSql + ' INTO CURSOR ' + tcCursor + IIF(tlNoFilter, ' NOFILTER', '') + IIF(tlRW, ' READWRITE', '')
		ENDIF
		this.SaveEnv()
		IF tlDeleteOff
			SET DELETED OFF
		ENDIF
		llSuccess = Sql(tcSql, tcCursor, tlEB90, "SQLCURSOR")
		IF tlDeleteOff
			SET DELETED ON
		ENDIF
		IF NOT tlDontCloseTables
			this.CloseOpened(tcCursor)
		ENDIF
		IF PCOUNT() > 6 AND taResult
			DIMENSION taResult(1)
			taResult(1) = .F.
			IF USED(tcCursor)
				SELECT * FROM (tcCursor) INTO ARRAY taResult
				USE IN (tcCursor)
			ENDIF
		ENDIF

		RETURN tcCursor
	ENDPROC


	PROCEDURE SqlInsert
		LPARAMETERS tcSql, tcUpdatingTable
		LOCAL lcSql, llSuccess

		lcSql = this.SqlParseTables(tcSql)

		this.SaveEnv()
		IF Sql(lcSql, '',,"SQLINSERT")
			llSuccess = .T.
		ELSE
			this.nErrorCode = ERR_INSERTION_FAILED
			this.cError = STRTRAN(ERRC_INSERTION_FAILED,"%s",tcUpdatingTable) + ERRC_DATA_FAILED
		ENDIF
		this.CloseOpened()

		IF NOT Odbc()
			FLUSH
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE SqlUpdate
		LPARAMETERS tcSql, tcUpdatingTable
		LOCAL lcSql, llSuccess

		lcSql = this.SqlParseTables(tcSql)

		this.SaveEnv()
		IF Sql(lcSql, '',,"SQLUPDATE")
			llSuccess = .T.
		ELSE
			this.nErrorCode = ERR_UPDATING_FAILED
			this.cError = STRTRAN(ERRC_UPDATING_FAILED,"%s",tcUpdatingTable) + ERRC_DATA_FAILED
		ENDIF
		this.CloseOpened()

		IF NOT Odbc()
			FLUSH
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE SqlDelete
		LPARAMETERS tcSql, tcUpdatingTable
		LOCAL lcSql, llSuccess

		lcSql = this.SqlParseTables(tcSql)

		this.SaveEnv()
		IF Sql(lcSql, '',,"SQLDELETE")
			llSuccess = .T.
		ELSE
			this.nErrorCode = ERR_DELETION_FAILED
			this.cError = STRTRAN(ERRC_DELETION_FAILED,"%s",tcUpdatingTable) + ERRC_DATA_FAILED
		ENDIF
		this.CloseOpened()

		IF NOT Odbc()
			FLUSH
		ENDIF

		RETURN llSuccess
	ENDPROC


	PROCEDURE OpenTable
		LPARAMETERS tcTable, tlOpened, tlNoCurAlias
		LOCAL llSuccess, lcDataPathWellness, lcmacro, lcalias
		lcalias = IIF(tlNoCurAlias,tcTable,'cur'+tcTable)
		DO CASE
			CASE USED(lcalias)
				tlOpened = .F.
				llSuccess = .T.
			CASE this.nApp = DESK
				llSuccess = EVALUATE("OpenFileDirect(,tcTable, lcalias)")
				tlOpened = .T.
			CASE this.nApp = TERMINAL
				llSuccess = EVALUATE("TbOpen(tcTable, lcalias)")
				tlOpened = .T.
			CASE this.nApp = WELLNESS
				lcmacro = [_Screen.oDM.GetDefaultConnectionDataPath()]
				lcDataPathWellness = &lcmacro
				lcDataPathWellness = ADDBS(lcDataPathWellness)
				USE (lcDataPathWellness + tcTable) SHARED IN 0 AGAIN ALIAS &lcalias
				*llSuccess = EVALUATE("thisform.oData.Do('SetUpCursor', IIF(tlNoCurAlias,'','cur')+tcTable)")
				llSuccess = USED(lcalias)
				tlOpened = .T.
			OTHERWISE
		ENDCASE
		RETURN llSuccess
	ENDPROC


	PROCEDURE CloseTable
		LPARAMETERS tcTable, tlOpened

		DO CASE
			CASE NOT USED(tcTable)
			CASE this.nApp = DESK
				IF tlOpened
					USE IN &tcTable
				ENDIF
			CASE this.nApp = TERMINAL
				IF tlOpened
					USE IN &tcTable
				ENDIF
			CASE this.nApp = WELLNESS
				EVALUATE("thisform.oData.oDs.TryUpdate(tcTable)")
			OTHERWISE
		ENDCASE
	ENDPROC


	PROCEDURE SaveEnv
		AUSED(this.aTables)
		this.cReprocessScript = "SET MESSAGE TO '" + SET("Message",1) + "'" + CRLF + ;
			"SET REPROCESS TO (" + TRANSFORM(SET("Reprocess")) + ")" + IIF(SET("Reprocess",2) = 1, " SECONDS", "")
		SET REPROCESS TO 5
	ENDPROC


	PROCEDURE CloseOpened
		LPARAMETERS tcResultCursor
		LOCAL ARRAY laTables(1)
		LOCAL i, lcArea

		=EXECSCRIPT(this.cReprocessScript)
		IF EMPTY(tcResultCursor)
			tcResultCursor = ""
		ENDIF
		FOR i = 1 TO AUSED(laTables)
			lcArea = laTables(i,1)
			IF UPPER(tcResultCursor) # lcArea AND 0 = ASCAN(this.aTables, lcArea, 1, 0, 1, 15)
				USE IN &lcArea
			ENDIF
		ENDFOR
		DIMENSION this.aTables[1]
		this.aTables[1] = .F.
	ENDPROC


	PROCEDURE geterror
		LPARAMETERS tcError

		tcError = this.cError

		RETURN this.nErrorcode
	ENDPROC


	PROCEDURE reseterror
		this.nErrorCode = NO_ERROR
		this.cError = ""
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cbmshandler
**************************************************