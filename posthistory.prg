PROCEDURE PostHistory
LPARAMETERS lp_oOldPost, lp_oNewPost, lp_cAction, lp_cPostAlias
LOCAL i, l_cMacro, l_nArea, l_tTime, l_dSysDate, l_oPostchng
LOCAL ARRAY l_aPostFields(1)

IF EMPTY(lp_cPostAlias)
	lp_cPostAlias = "post"
ENDIF
IF NOT (LOWER(lp_cPostAlias) == "post")
	RETURN .F.
ENDIF
l_nArea = SELECT()
l_dSysdate = SysDate()
l_tTime = DATETIME()
IF NOT USED("postchng")
     openfiledirect(.F.,"postchng")
ENDIF
SELECT postchng
SCATTER NAME l_oPostchng BLANK
l_oPostchng.ph_postid = lp_oNewPost.ps_postid
l_oPostchng.ph_time = DATETIME(YEAR(l_dSysDate),MONTH(l_dSysDate),DAY(l_dSysDate),HOUR(l_tTime),MINUTE(l_tTime),SEC(l_tTime))
l_oPostchng.ph_user = cUserId
DO CASE
	CASE "CREATED" $ lp_cAction
		APPEND BLANK
		l_oPostchng.ph_action = lp_cAction
		GATHER NAME l_oPostchng
	CASE "SPLITTED" $ lp_cAction
		l_oPostchng.ph_action = "CREATED splitted"
		l_oPostchng.ph_field = GetLangText("CHKOUT2","T_AMOUNT")	&& Amount
		l_oPostchng.ph_oldval = "0.00"
		l_oPostchng.ph_newval = ALLTRIM(STR(lp_oNewPost.ps_amount,20,2))
		APPEND BLANK
		GATHER NAME l_oPostchng
		l_oPostchng.ph_postid = lp_oOldPost.ps_postid
		l_oPostchng.ph_action = "SPLITTED " + ALLTRIM(STR(lp_oOldPost.ps_postid)) + " --> " + ALLTRIM(STR(lp_oOldPost.ps_postid)) + ", " + ALLTRIM(STR(lp_oNewPost.ps_postid))
		l_oPostchng.ph_field = GetLangText("CHKOUT2","T_AMOUNT")
		l_oPostchng.ph_oldval = ALLTRIM(STR(lp_oOldPost.ps_amount,20,2))
		l_oPostchng.ph_newval = ALLTRIM(STR(lp_oOldPost.ps_amount-lp_oNewPost.ps_amount,20,2))
		APPEND BLANK
		GATHER NAME l_oPostchng
	CASE "ARGUSCASH" $ lp_cAction
		l_oPostchng.ph_action = "CHANGED"
		l_oPostchng.ph_field = GetLangText("CHKOUT2","T_AMOUNT")	&& Amount
		l_oPostchng.ph_oldval = ALLTRIM(STR(lp_oOldPost.ps_amount,20,2))
		l_oPostchng.ph_newval = ALLTRIM(STR(lp_oNewPost.ps_amount,20,2))
		APPEND BLANK
		GATHER NAME l_oPostchng
	CASE "ADJUSTED" $ lp_cAction
		l_oPostchng.ph_action = "ADJUSTED price"
		l_oPostchng.ph_field = GetLangText("CHKOUT2","T_AMOUNT")     && Amount
		l_oPostchng.ph_oldval = ALLTRIM(STR(lp_oOldPost.ps_amount,20,2))
		l_oPostchng.ph_newval = ALLTRIM(STR(lp_oNewPost.ps_amount,20,2))
		APPEND BLANK
		GATHER NAME l_oPostchng
	OTHERWISE
		SELECT &lp_cPostAlias
		AFIELDS(l_aPostFields)
		SELECT postchng
		FOR i = 1 TO ALEN(l_aPostFields,1)
			IF INLIST(l_aPostFields(i,1), "PS_CANCEL", "PS_DESCRIP", "PS_RESERID", "PS_SUPPLEM", "PS_WINDOW")
				l_cMacro = "lp_oNewPost." + l_aPostFields(i,1) + " <> lp_oOldPost." + l_aPostFields(i,1)
				IF &l_cMacro
					DO CASE
						CASE l_aPostFields(i,1) = "PS_CANCEL"
							IF lp_oNewPost.ps_cancel
								l_oPostchng.ph_action = "DELETED"
								l_oPostchng.ph_field = ""
								l_oPostchng.ph_oldval = ""
								l_oPostchng.ph_newval = ""
								APPEND BLANK
								GATHER NAME l_oPostchng
							ENDIF
						CASE l_aPostFields(i,1) = "PS_RESERID"
							l_oPostchng.ph_action = "REDIRECTED"
							l_oPostchng.ph_field = GetLangText("RESERVAT","TW_RESERVAT")	&& Reservation
							l_oPostchng.ph_oldval = ALLTRIM(STR(EVALUATE("lp_oOldPost." + l_aPostFields(i,1)),12,3)) + " -->"
							l_oPostchng.ph_newval = "--> " + ALLTRIM(STR(EVALUATE("lp_oNewPost." + l_aPostFields(i,1)),12,3))
							APPEND BLANK
							GATHER NAME l_oPostchng
						CASE l_aPostFields(i,1) = "PS_WINDOW"
							l_oPostchng.ph_action = "MOVED"
							l_oPostchng.ph_field = GetLangText("BILL","TXT_WINDOW")	&& Window
							l_oPostchng.ph_oldval = STR(EVALUATE("lp_oOldPost." + l_aPostFields(i,1)),1) + " -->"
							l_oPostchng.ph_newval = "--> " + STR(EVALUATE("lp_oNewPost." + l_aPostFields(i,1)),1)
							APPEND BLANK
							GATHER NAME l_oPostchng
						CASE l_aPostFields(i,1) = "PS_SUPPLEM"
							l_oPostchng.ph_action = "CHANGED"
							l_oPostchng.ph_field = GetLangText("CHKOUT2","T_SUPPLEM")	&& Supplementary text
							l_oPostchng.ph_oldval = EVALUATE("lp_oOldPost." + l_aPostFields(i,1))
							l_oPostchng.ph_newval = EVALUATE("lp_oNewPost." + l_aPostFields(i,1))
							APPEND BLANK
							GATHER NAME l_oPostchng
						CASE l_aPostFields(i,1) = "PS_DESCRIP"
							l_oPostchng.ph_action = "CHANGED"
							l_oPostchng.ph_field = GetLangText("MGRFINAN","TH_DESCRIPT")	&& Description
							l_oPostchng.ph_oldval = EVALUATE("lp_oOldPost." + l_aPostFields(i,1))
							l_oPostchng.ph_newval = EVALUATE("lp_oNewPost." + l_aPostFields(i,1))
							APPEND BLANK
							GATHER NAME l_oPostchng
					ENDCASE
				ENDIF
			ENDIF
		ENDFOR
ENDCASE

SELECT (l_nArea)
ENDPROC
*