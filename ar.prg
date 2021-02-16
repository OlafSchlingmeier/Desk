*
PROCEDURE ARBrowse
 LPARAMETERS lp_lCreditors
 PRIVATE cbUttons, clEvel, a_Fields, naRea, cbTnfunc
 PRIVATE ccUrsor, cwHere, coRder
 doform(IIF(lp_lCreditors,'craccountsform','araccountsform'),'forms\araccountsform','WITH ' + sqlcnv(lp_lCreditors))
 RETURN .T.
ENDPROC
*
PROCEDURE ArReceivables
 LPARAMETERS lp_lCreditors
 LOCAL l_oPrintParams
 doform(IIF(lp_lCreditors,'crarremprint','arremprint'),'forms\arremprint','WITH ' + sqlcnv(lp_lCreditors))
 RETURN .T.
ENDPROC
*
PROCEDURE ArSelectArReceivables
 LPARAMETERS lp_oPrintParams, lp_lContinue, lp_lCreditors
 lp_lContinue = .F.
 ArCreatePrintParams(@lp_oPrintParams, lp_lCreditors)
 DO FORM forms\arselprintbills WITH lp_oPrintParams TO lp_oPrintParams
 IF NOT ISNULL(lp_oPrintParams)
      = ArNewReceivablesList(@lp_oPrintParams)
      lp_lContinue = .T.
 ENDIF
 RETURN lp_lContinue
ENDPROC
*
PROCEDURE ArGetSelectedReceivables
 LPARAMETERS lp_oPrintParams, lp_lActiveRemainderAdvanceFound
 LOCAL l_nSelect, l_lActiveRemainderAdvanceFound, l_cSql
 l_lActiveRemainderAdvanceFound = .F.
 l_cCurName = SYS(2015)
 l_nSelect = SELECT()
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
      SELECT TOP 1 ag_agid AS cur_agid, * ;
           FROM argenrem ;
           WHERE NOT ag_compl AND ag_userid = g_userid ;
           <<IIF(lp_oPrintParams.lCreditors," AND ag_credito", "AND NOT ag_credito")>>
           ORDER BY 1
 ENDTEXT
 l_cCurName = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
 IF RECCOUNT()>0&& AND dlocate("arremlet","ak_agid = " + sqlcnv(ag_agid))
      lp_oPrintParams.nAgId = ag_agid
      lp_oPrintParams.nFrom = ag_acfrom
      lp_oPrintParams.nTo = ag_acto
      lp_oPrintParams.cDebitorType = ag_actype
      lp_oPrintParams.dSettlementDay = ag_setday
      lp_oPrintParams.nRemainderFilter = ag_remfil
      lp_oPrintParams.nStatmentFilter = ag_stmfil
      lp_oPrintParams.lDisputed = ag_inclds
      lp_oPrintParams.lWriteInDocuments = ag_wrdoc
      lp_oPrintParams.cDescText = ag_docdesc
      lp_oPrintParams.lCreditors = ag_credito
      lp_oPrintParams.lOnlyDeposits = ag_onlydep
      l_lActiveRemainderAdvanceFound = .T.
 ENDIF
 dclose(l_cCurName)
 SELECT (l_nSelect)
 lp_lActiveRemainderAdvanceFound = l_lActiveRemainderAdvanceFound
 RETURN l_lActiveRemainderAdvanceFound
ENDPROC
*
PROCEDURE ArCreatePrintParams
 LPARAMETERS lp_oPrintParams, lp_lCreditors
 lp_oPrintParams = .NULL.
 lp_oPrintParams = CREATEOBJECT("custom")
 lp_oPrintParams.AddProperty("nAgId",0)
 lp_oPrintParams.AddProperty("nFrom",0)
 lp_oPrintParams.AddProperty("nTo",9999999999)
 lp_oPrintParams.AddProperty("cDebitorType",SPACE(3))
 lp_oPrintParams.AddProperty("dSettlementDay",{})
 lp_oPrintParams.AddProperty("nRemainderFilter",0)
 lp_oPrintParams.AddProperty("nStatmentFilter",0)
 lp_oPrintParams.AddProperty("lDisputed",.F.)
 lp_oPrintParams.AddProperty("lWriteInDocuments",.F.)
 lp_oPrintParams.AddProperty("cDescText","")
 lp_oPrintParams.AddProperty("nEventId",0)
 lp_oPrintParams.AddProperty("lCreditors",lp_lCreditors)
 lp_oPrintParams.AddProperty("lOnlyDeposits",.F.)
 RETURN lp_oPrintParams
ENDPROC
*
PROCEDURE ArGetRemainderFilter
 LPARAMETERS lp_oPrintParams
 LOCAL l_cWhere
 IF lp_oPrintParams.lCreditors
      DO CASE
           CASE lp_oPrintParams.nRemainderFilter = 2
                l_cWhere = "NOT ac_cautobk AND cur_peramt >= 0"
           CASE lp_oPrintParams.nRemainderFilter = 3
                l_cWhere = "ac_cautobk AND cur_peramt >= 0"
           CASE lp_oPrintParams.nRemainderFilter = 4
                l_cWhere = "NOT ac_cautobk AND cur_peramt < 0"
           CASE lp_oPrintParams.nRemainderFilter = 5
                l_cWhere = "ac_cautobk AND cur_peramt < 0"
           OTHERWISE
                l_cWhere = ".T."
      ENDCASE
      RETURN l_cWhere
 ENDIF
 IF lp_oPrintParams.nRemainderFilter = 6
      l_cWhere = ".F."
      RETURN l_cWhere
 ENDIF
 DO CASE
      CASE lp_oPrintParams.nRemainderFilter = 2
           l_cWhere = sqland(l_cWhere,"ap_remlev>0 OR cur_remlev>0")
      CASE lp_oPrintParams.nRemainderFilter = 3
           l_cWhere = sqland(l_cWhere,"cur_remlev>ap_remlev")
      CASE lp_oPrintParams.nRemainderFilter = 5
           l_cWhere = sqland(l_cWhere,"cur_remlev>ap_remlev")
      CASE lp_oPrintParams.nRemainderFilter = 7
           l_cWhere = sqland(l_cWhere,"cur_remlev=1 AND cur_remlev>ap_remlev")
      CASE lp_oPrintParams.nRemainderFilter = 8
           l_cWhere = sqland(l_cWhere,"cur_remlev=2 AND cur_remlev>ap_remlev")
      CASE lp_oPrintParams.nRemainderFilter = 9
           l_cWhere = sqland(l_cWhere,"cur_remlev=3 AND cur_remlev>ap_remlev")
      CASE lp_oPrintParams.nRemainderFilter = 10
           l_cWhere = sqland(l_cWhere,"cur_remlev=4 AND cur_remlev>ap_remlev")
      OTHERWISE && lp_oPrintParams.nRemainderFilter = 1, 4
           l_cWhere = sqland(l_cWhere,"cur_remlev>=0")
 ENDCASE
 *l_cWhere = sqland(l_cWhere,"ap_rmsdat<"+sqlcnv(sysdate()))
 RETURN l_cWhere
ENDPROC
*
PROCEDURE ArGetStatmentFilter
 LPARAMETERS lp_oPrintParams
 LOCAL l_cWhere
 IF lp_oPrintParams.nStatmentFilter = 1
      l_cWhere = ".F."
      RETURN l_cWhere
 ENDIF
 DO CASE
      CASE lp_oPrintParams.nStatmentFilter = 3
           l_cWhere = sqland(l_cWhere,"ap_remlev>0 AND cur_remlev>0")
      CASE lp_oPrintParams.nStatmentFilter = 4
           l_cWhere = sqland(l_cWhere,"cur_remlev>ap_remlev")
      OTHERWISE && lp_oPrintParams.nStatmentFilter = 2    
           l_cWhere = ".T."
 ENDCASE
 *l_cWhere = sqland(l_cWhere,"ap_stmlast<"+sqlcnv(sysdate()))
 RETURN l_cWhere
ENDPROC
*
PROCEDURE ArRefreshAracct
 LPARAMETERS lp_nAracct, lp_oPrintParams, lp_cCurResult
 LOCAL l_nSelect, l_cProgressTitle, l_lRefreshOneArrAcct, l_oPrintParams, l_cFor, l_cKey, l_oCurData, l_nSelectedRecords, l_lDelete
 l_nSelect = SELECT()
 l_oPrintParams = lp_oPrintParams
 l_oPrintParams.nFrom = lp_nAracct
 l_oPrintParams.nTo = lp_nAracct
 l_cProgressTitle = GetLangText("AR","TXT_REFRESHING_ARRACT") + " " + sqlcnv(lp_nAracct)
 l_lRefreshOneArrAcct = .T.
 DELETE FOR ac_aracct = lp_nAracct IN &lp_cCurResult
 = ArGetReceivablesData(lp_cCurResult, l_oPrintParams, l_cProgressTitle, l_lRefreshOneArrAcct, @l_nSelectedRecords)
 IF l_nSelectedRecords = 0
      ArDeleteUncompleteReceivables(lp_oPrintParams.nAgId)
 ELSE
      SELECT &lp_cCurResult
      SCAN FOR ac_aracct = lp_nAracct
           l_lDelete =  .F.
           l_cKey = STR(lp_oPrintParams.nAgId,8) + STR(ap_lineid,8)
           IF dlocate("arremlet","STR(ak_agid,8)+STR(ak_lineid,8) = " + sqlcnv(l_cKey))
                REPLACE cur_printed WITH arremlet.ak_printed
                l_lDelete = (arremlet.ak_compl OR arremlet.ak_deleted)
           ENDIF
           IF l_lDelete
                DELETE
           ELSE
                SCATTER MEMO NAME l_oCurData
                ArSaveSelectedReceivables(@lp_oPrintParams, ap_lineid, @l_oCurData)
           ENDIF
      ENDSCAN
      FLUSH
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArGetReceivablesFilter
 LPARAMETERS lp_oPrintParams, lp_cWhere, lp_cHaving, lp_cFields
 LOCAL l_cWhere
 l_cWhere = ""
 IF NOT EMPTY(lp_oPrintParams.nTo)
      l_cWhere = sqland(l_cWhere,"BETWEEN(ac_aracct, " + sqlcnv(lp_oPrintParams.nFrom) + ", " + sqlcnv(lp_oPrintParams.nTo) +")")
 ENDIF
 IF NOT EMPTY(lp_oPrintParams.cDebitorType)
      l_cWhere = sqland(l_cWhere,"ac_accttyp = " + sqlcnv(lp_oPrintParams.cDebitorType))
 ENDIF
 IF NOT EMPTY(lp_oPrintParams.nEventId)
      l_cWhere = sqland(l_cWhere,"al_eiid = " + sqlcnv(lp_oPrintParams.nEventId))
 ENDIF
 l_cWhere = sqland(l_cWhere,"ac_remind AND ap_lineid = ap_headid")
 IF lp_oPrintParams.lCreditors
      l_cWhere = sqland(l_cWhere,"ac_credito")
 ELSE
      l_cWhere = sqland(l_cWhere,"NOT ac_credito")
 ENDIF
 l_cWhere = sqland(l_cWhere,"NOT ap_hiden")
 IF lp_oPrintParams.nRemainderFilter <> 6
      lp_cHaving = sqland("","cur_bal>0")
 ELSE
      lp_cHaving = sqland("","cur_bal<>0")
 ENDIF
 IF lp_oPrintParams.lDisputed
      lp_cFields = "aracct.*, arpost.*, address.*, apartner.*, arPstbal(ap_headid,0,.T.) AS cur_bal"
 ELSE
      l_cWhere = sqland(l_cWhere,"NOT ArAccount([ArIsDisputed], ap_dispute, ap_disdate)")
      lp_cFields = "aracct.*, arpost.*, address.*, apartner.*, arPstbal(ap_headid,0,.F.) AS cur_bal"
 ENDIF
 lp_cWhere = l_cWhere
 RETURN .T.
ENDPROC
*
PROCEDURE ArGetReceivablesData
 LPARAMETERS lp_cCurResult, lp_oPrintParams, lp_cProgressTitle, lp_lRefreshOneArrAcct, lp_nSelectedRecords
 LOCAL l_cCurArpost, l_cCurPrepared, l_cWhere, l_cReportFilter, l_oData, ;
           l_title, l_fname, l_lname, l_salute, l_cIncLev, l_lIncLev1, l_lIncLev2, l_lIncLev3, ;
           l_nAm_number, l_dSysDate, l_nDaysPassed, ;
           l_dRemainder1Date, l_dRemainder2Date, l_dRemainder3Date, l_dStartRemFee, ;
           l_nSelect, l_oProgress, l_cProgressTitle, l_nI, l_cDataField, l_cCurField, l_cFields, l_cHaving, ;
           l_nSelectedRecords, l_lForbidenRem4
 l_lForbidenRem4 = param.pa_noreml4
 IF EMPTY(lp_cProgressTitle)
      l_cProgressTitle = GetLangText("AR","TXT_CREATING_REMAINDERS")
 ELSE
      l_cProgressTitle = lp_cProgressTitle
 ENDIF
 l_oProgress = NEWOBJECT("_thermometer","_therm.vcx","",l_cProgressTitle,0)
 l_oProgress.Show()
 l_nSelect = SELECT()
 l_cCurArpost = SYS(2015)
 l_cCurPrepared = SYS(2015)
 l_dSysDate = sysdate()
 ArGetReceivablesFilter(@lp_oPrintParams, @l_cWhere, @l_cHaving, @l_cFields)
 IF NOT EMPTY(lp_oPrintParams.nEventId)
      SELECT &l_cFields FROM aracct ;
                INNER JOIN arpost ON ac_aracct = ap_aracct ;
                INNER JOIN reservat ON ap_reserid = rs_reserid ;
                INNER JOIN althead ON rs_altid = al_altid ;
                LEFT JOIN address ON ac_addrid = ad_addrid ;
                LEFT JOIN apartner ON ac_apid = ap_apid ;
                WHERE &l_cWhere ;
                HAVING &l_cHaving ;
                ORDER BY ac_aracct, ap_headid ;
                INTO CURSOR &l_cCurArpost
 ELSE
       SELECT &l_cFields FROM aracct ;
                LEFT JOIN arpost ON ac_aracct = ap_aracct ;
                LEFT JOIN address ON ac_addrid = ad_addrid ;
                LEFT JOIN apartner ON ac_apid = ap_apid ;
                WHERE &l_cWhere ;
                HAVING &l_cHaving ;
                ORDER BY ac_aracct, ap_headid ;
                INTO CURSOR &l_cCurArpost
 ENDIF
 l_oProgress.iBasis = RECCOUNT() + 1
 = CreateRemainderCursor(l_cCurArpost,l_cCurPrepared)
 IF NOT lp_lRefreshOneArrAcct
      = CreateRemainderCursor(l_cCurArpost,lp_cCurResult)
 ENDIF
 SELECT &l_cCurArpost
 SCAN ALL
      l_oProgress.Update(RECNO())
      = ArCopyData(l_cCurArpost, l_cCurPrepared, @l_oData)
      = ArFixAddress(@l_oData)

      l_nAm_number = ArAccount("GetRemainderDays", ap_aracct)
      IF NOT dlocate("arremd", "am_number = " + sqlcnv(l_nAm_number) + " AND " + ;
                "am_credito = " + sqlcnv(lp_oPrintParams.lCreditors))
           * default remainder not found, set to empty record
           GO BOTTOM IN arremd
           SKIP 1 IN arremd
      ENDIF
      l_oData.cur_amid = arremd.am_amid
      ArAccount("ArGetDueDate", ap_aracct, ap_sysdate, ap_duedat, @l_dRemainder1Date, @l_dStartRemFee)
      l_oData.cur_duedate = l_dRemainder1Date
      l_dRemainder2Date = ap_remlast + arremd.am_dayrem2
      l_dRemainder3Date = ap_remlast + arremd.am_dayrem3
      l_dRemainder4Date = ap_remlast + arremd.am_dayrem4
      l_oData.cur_headtext = arremd.am_header
      DO CASE
           CASE l_dRemainder1Date<=l_dSysDate AND ap_remlev=0
                l_nDaysPassed = MAX(0, l_dSysDate - l_dStartRemFee)
                l_nPercentRemAmount = ArAccount("CalcPercentRemAmount", cur_bal, l_nDaysPassed, arremd.am_perrem1)
                l_oData.cur_text = arremd.am_remtxt1
                l_oData.cur_fixamt = arremd.am_feerem1
                l_oData.cur_peramt = l_nPercentRemAmount
                l_oData.cur_remlev = 1
           CASE l_dRemainder2Date<=l_dSysDate AND ap_remlev=1
                l_nDaysPassed = MAX(0, l_dSysDate - l_dStartRemFee)
                l_nPercentRemAmount = ArAccount("CalcPercentRemAmount", cur_bal, l_nDaysPassed, arremd.am_perrem2)
                l_oData.cur_text = arremd.am_remtxt2
                l_oData.cur_fixamt = arremd.am_feerem2
                l_oData.cur_peramt = l_nPercentRemAmount
                l_oData.cur_remlev = 2
           CASE l_dRemainder3Date<=l_dSysDate AND ap_remlev=2
                l_nDaysPassed = MAX(0, l_dSysDate - l_dStartRemFee)
                l_nPercentRemAmount = ArAccount("CalcPercentRemAmount", cur_bal, l_nDaysPassed, arremd.am_perrem3)
                l_oData.cur_text = arremd.am_remtxt3
                l_oData.cur_fixamt = arremd.am_feerem3
                l_oData.cur_peramt = l_nPercentRemAmount
                l_oData.cur_remlev = 3
           CASE NOT l_lForbidenRem4 AND (l_dRemainder4Date<=l_dSysDate AND ap_remlev=3) && More then 3 times remainded!
                l_nDaysPassed = MAX(0, ap_inclev3 - l_dStartRemFee)
                l_nPercentRemAmount = ArAccount("CalcPercentRemAmount", cur_bal, l_nDaysPassed, arremd.am_perrem3)
                l_oData.cur_text = arremd.am_remtxt3
                l_oData.cur_fixamt = arremd.am_feerem3
                l_oData.cur_peramt = l_nPercentRemAmount
                l_oData.cur_remlev = 4
           CASE ap_remlev>0 && No new remainder level is rised, take current rem. lev., if exists
                IF INLIST(ap_remlev, 3, 4)
                     l_nDaysPassed = MAX(0, ap_inclev3 - l_dStartRemFee)
                     l_nPercentRemAmount = ArAccount("CalcPercentRemAmount", cur_bal, l_nDaysPassed, ;
                               arremd.am_perrem3)
                     l_oData.cur_peramt = l_nPercentRemAmount
                     l_oData.cur_fixamt = arremd.am_feerem3
                ELSE
                     l_nDaysPassed = MAX(0, ap_remlast - l_dStartRemFee)
                     l_nPercentRemAmount = ArAccount("CalcPercentRemAmount", cur_bal, l_nDaysPassed, ;
                               EVALUATE("arremd.am_perrem"+STR(ap_remlev,1)))
                     
                     l_oData.cur_fixamt = EVALUATE("arremd.am_feerem"++STR(ap_remlev,1))
                     l_oData.cur_peramt = l_nPercentRemAmount
                     l_oData.cur_remlev = ap_remlev
                ENDIF
                l_oData.cur_text = EVALUATE("arremd.am_remtxt"++STR(ap_remlev,1))
                l_oData.cur_remlev = ap_remlev
           OTHERWISE
                l_nPercentRemAmount = 0
                IF lp_oPrintParams.lCreditors
                     * calculate skonto
                     IF dlocate("arpcond", "ay_ayid = " + sqlcnv(l_oData.ac_ayid))
                          DO CASE
                               CASE BETWEEN(l_dSysDate, ap_sysdate + arpcond.ay_daydis2 + 1, ap_sysdate + arpcond.ay_daydis3)
                                    l_nPercentRemAmount = -1*ROUND(cur_bal * (arpcond.ay_discou3/100), param.pa_currdec)
                               CASE BETWEEN(l_dSysDate, ap_sysdate + arpcond.ay_daydis1 + 1, ap_sysdate + arpcond.ay_daydis2)
                                    l_nPercentRemAmount = -1*ROUND(cur_bal * (arpcond.ay_discou2/100), param.pa_currdec)
                               CASE BETWEEN(l_dSysDate, ap_sysdate, ap_sysdate + arpcond.ay_daydis1)
                                    l_nPercentRemAmount = -1*ROUND(cur_bal * (arpcond.ay_discou1/100), param.pa_currdec)
                          ENDCASE
                     ENDIF
                ENDIF
                l_nDaysPassed = 0
                l_oData.cur_text = arremd.am_remtxt0
                l_oData.cur_remlev = 0
                l_oData.cur_fixamt = 0
                l_oData.cur_peramt = l_nPercentRemAmount
      ENDCASE
      SELECT &l_cCurPrepared
      APPEND BLANK
      GATHER NAME l_oData MEMO
      SELECT &l_cCurArpost
 ENDSCAN
 
 IF NOT lp_oPrintParams.lCreditors

      IF lp_oPrintParams.nRemainderFilter <> 6
           l_cReportFilter = sqland("",ArGetRemainderFilter(lp_oPrintParams))
      ELSE
           l_cReportFilter = sqland("",ArGetStatmentFilter(lp_oPrintParams))
      ENDIF
      SELECT &l_cCurPrepared
      SCAN FOR &l_cReportFilter
           SCATTER NAME l_oData MEMO
           SELECT &lp_cCurResult
           APPEND BLANK
           GATHER NAME l_oData MEMO
           SELECT &l_cCurPrepared
      ENDSCAN
 
      IF lp_oPrintParams.nRemainderFilter <> 6 AND ;
                INLIST(lp_oPrintParams.nRemainderFilter,1,4)
           * Additional filter. 
           * Dont show bills with rem. level 0 or X, when no other bill for this debitor with rem.lev 1-3 is found.
           SELECT ap_aracct, MAX(cur_remlev) AS cur_maxrlv FROM &lp_cCurResult ;
                     WHERE BETWEEN(ap_remlev,1,3) OR (ap_remlev = 0 AND cur_remlev > 0) ;
                     INTO CURSOR curOnlyAbove GROUP BY ap_aracct
           SCAN ALL
                REPLACE cur_maxrlv WITH curOnlyAbove.cur_maxrlv FOR ap_aracct = curOnlyAbove.ap_aracct IN &lp_cCurResult
           ENDSCAN
           USE IN curOnlyAbove
           SELECT &lp_cCurResult
           SCAN FOR (cur_remlev=0 OR ap_remlev=4) AND cur_maxrlv=0
                DELETE
           ENDSCAN
      ENDIF
      
      IF lp_oPrintParams.lOnlyDeposits
           LOCAL l_nPostId
           SELECT &lp_cCurResult
           SCAN ALL
                l_nPostId = NVL(ap_postid,0)
                IF l_nPostId = 0
                     DELETE
                ELSE
                     IF NOT (dlocate([deposit], [dp_postid = ] + SqlCnv(l_nPostId)) OR ;
                               dlocate([hdeposit], [dp_postid = ] + SqlCnv(l_nPostId)))
                          DELETE
                     ENDIF
                ENDIF
           ENDSCAN
      ENDIF
      
 ELSE
      l_cReportFilter = sqland("",ArGetRemainderFilter(lp_oPrintParams))
      SELECT &l_cCurPrepared
      SCAN FOR &l_cReportFilter
           SCATTER NAME l_oData MEMO
           SELECT &lp_cCurResult
           APPEND BLANK
           GATHER NAME l_oData MEMO
           SELECT &l_cCurPrepared
      ENDSCAN
 ENDIF
 SELECT &lp_cCurResult
 COUNT ALL TO l_nSelectedRecords
 USE IN &l_cCurArpost
 USE IN &l_cCurPrepared
 l_oProgress.Complete(GetLangText("COMMON","TXT_DONE"))
 l_oProgress.Release()
 SELECT(l_nSelect)
 lp_nSelectedRecords = l_nSelectedRecords
 RETURN .T.
ENDPROC
*
PROCEDURE ArGetSavedReceivablesData
 LPARAMETERS lp_oPrintParams, lp_cResCurName
 LOCAL l_cWhere, l_cCurPrepared, l_oData, l_cProgressTitle, l_oProgress
 l_cProgressTitle = GetLangText("AR","TXT_PREPARE_DATA")
 l_oProgress = NEWOBJECT("_thermometer","_therm.vcx","",l_cProgressTitle,0)
 l_oProgress.Show()
 l_cCurPrepared = SYS(2015)
 l_cWhere = sqland("","ak_agid = " + sqlcnv(lp_oPrintParams.nAgId))
 l_cWhere = sqland(l_cWhere,"ak_compl = " + sqlcnv(.F.))
 l_cWhere = sqland(l_cWhere,"ak_deleted = " + sqlcnv(.F.))
 ArMarkLostRemaindersAsDeleted(lp_oPrintParams.nAgId)
 SELECT *, ak_balance AS cur_bal FROM arremlet ;
           LEFT JOIN arpost ON ak_lineid = ap_lineid ;
           LEFT JOIN aracct ON ap_aracct = ac_aracct ;
           LEFT JOIN address ON ac_addrid = ad_addrid ;
           LEFT JOIN apartner ON ac_apid = ap_apid ;
           WHERE &l_cWhere ;
           ORDER BY ac_aracct, ap_headid ;
           INTO CURSOR &l_cCurPrepared
 = CreateRemainderCursor(l_cCurPrepared,lp_cResCurName)
 SELECT &l_cCurPrepared
 l_oProgress.iBasis = RECCOUNT() + 1
 SCAN ALL
      l_oProgress.Update(RECNO())
      = ArCopyData(l_cCurPrepared, lp_cResCurName, @l_oData)
      = ArFixAddress(@l_oData)
      l_oData.cur_amid = ak_amid
      l_oData.cur_duedate = ak_duedat
      l_oData.cur_headtext = ak_header
      l_oData.cur_text = ak_remtxt
      l_oData.cur_bal = ak_balance
      l_oData.cur_fixamt = ak_feerem
      l_oData.cur_peramt = ak_perrem
      l_oData.cur_remlev = ak_remlev
      l_oData.cur_printed = ak_printed
      SELECT &lp_cResCurName
      APPEND BLANK
      GATHER NAME l_oData MEMO
      SELECT &l_cCurPrepared
 ENDSCAN
 l_oProgress.Complete(GetLangText("COMMON","TXT_DONE"))
 l_oProgress.Release()
 RETURN .T.
ENDPROC
*
PROCEDURE ArMarkLostRemaindersAsDeleted
* Check if some records in arpost are deleted, and mark those orphaned records in arremlet table as deleted
* ak_deleted = .T.
LPARAMETERS lp_nAgId
LOCAL l_nSelect, l_cCurLost, l_cKey
IF EMPTY(lp_nAgId)
     RETURN .F.
ENDIF
l_nSelect = SELECT()
l_cCurLost = SYS(2015)
SELECT ak_lineid FROM arremlet ;
          LEFT JOIN arpost ON ak_lineid = ap_lineid ;
          WHERE ak_agid = lp_nAgId AND ak_deleted = .F. ;
          HAVING ISNULL(ap_lineid) ;
          INTO CURSOR (l_cCurLost)
IF RECCOUNT(l_cCurLost)>0
     SCAN ALL
          l_cKey = STR(lp_nAgId,8) + STR(&l_cCurLost..ak_lineid,8)
          REPLACE ak_deleted WITH .T. ;
                    FOR STR(ak_agid,8) + STR(ak_lineid,8) = l_cKey ;
                    IN arremlet
          = erRormsg("ArMarkLostRemaindersAsDeleted: " + l_cKey)
     ENDSCAN
ENDIF
USE IN (l_cCurLost)
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ArCopyData
 LPARAMETERS lp_cCurSource, lp_cCurTarget, lp_oData
 LOCAL l_nSelect
 LOCAL ARRAY l_aFields(1)
 l_nSelect = SELECT()
 SELECT &lp_cCurTarget
 SCATTER MEMO NAME lp_oData BLANK
 SELECT &lp_cCurSource
 = AFIELDS(l_aFields)
 FOR l_nI = 1 TO ALEN(l_aFields,1)
      l_cDataField = "lp_oData."+l_aFields(l_nI,1)
      l_cCurField = l_aFields(l_nI,1)
      &l_cDataField = &l_cCurField
 ENDFOR
 SELECT(l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArFixAddress
 LPARAMETERS lp_oData
 IF NOT EMPTY(lp_oData.ac_apid)
      lp_oData.cur_title = IIF(ISNULL(lp_oData.ap_title),"",lp_oData.ap_title)
      lp_oData.cur_fname = IIF(ISNULL(lp_oData.ap_fname),"",lp_oData.ap_fname)
      lp_oData.cur_lname = IIF(ISNULL(lp_oData.ap_lname),"",lp_oData.ap_lname)
      lp_oData.cur_salute = IIF(ISNULL(lp_oData.ap_salute),"",lp_oData.ap_salute)
 ELSE
      lp_oData.cur_title = IIF(ISNULL(lp_oData.ad_title),"",lp_oData.ad_title)
      lp_oData.cur_fname = IIF(ISNULL(lp_oData.ad_fname),"",lp_oData.ad_fname)
      lp_oData.cur_lname = IIF(ISNULL(lp_oData.ad_lname),"",lp_oData.ad_lname)
      lp_oData.cur_salute = IIF(ISNULL(lp_oData.ad_salute),"",lp_oData.ad_salute)
 ENDIF
 lp_oData.cur_company = IIF(ISNULL(lp_oData.ad_company),"",lp_oData.ad_company)
 lp_oData.cur_city = IIF(ISNULL(lp_oData.ad_city),"",lp_oData.ad_city)
ENDPROC
*
PROCEDURE ArPrintRemainders
 LPARAMETERS lp_oPrintParams, lp_cCurRem, lp_lOnlyMarked
 LOCAL l_cRemText, l_lDone, l_dSettlementDay, l_cWhere
 LOCAL loSession, lnRetval, loXFF, loPreview, loExtensionHandler, l_lAutoYield
 LOCAL l_cFor, l_cReport, l_lNoListsTable, l_oFrmPreview
 l_dSettlementDay = lp_oPrintParams.dSettlementDay
 * get max. rem level
 l_cWhere = sqland("","NOT ArAccount([ArIsDisputed], ap_dispute, ap_disdate)")
 IF lp_oPrintParams.nRemainderFilter <> 10
      * Dont take level 4
      l_cWhere = sqland(l_cWhere,"cur_remlev<4")
 ENDIF
 IF lp_lOnlyMarked
      l_cWhere = sqland(l_cWhere,"cur_mark")
 ENDIF
 SELECT ac_aracct, MAX(cur_remlev) AS cur_maxremlev;
           FROM &lp_cCurRem WHERE &l_cWhere GROUP BY ac_aracct INTO CURSOR curMaxRemLev
 IF RECCOUNT()=0
      * only remainder level 4 are marked. Now find max. rem level, including level 4
      USE
      l_cWhere = sqland("","NOT ArAccount([ArIsDisputed], ap_dispute, ap_disdate)")
      IF lp_lOnlyMarked
           l_cWhere = sqland(l_cWhere,"cur_mark")
      ENDIF
      SELECT ac_aracct, MAX(cur_remlev) AS cur_maxremlev;
                FROM &lp_cCurRem WHERE &l_cWhere GROUP BY ac_aracct INTO CURSOR curMaxRemLev
 ENDIF
 SCAN ALL
      SELECT &lp_cCurRem
      LOCATE FOR ac_aracct = curMaxRemLev.ac_aracct
      IF FOUND()
           l_cRemText = dlookup("arremd","am_amid = "+sqLcnv(&lp_cCurRem..cur_amid), ;
                     "am_remtxt"+STR(curMaxRemLev.cur_maxremlev,1))
      ELSE
           l_cRemText = ""
      ENDIF
      REPLACE cur_maxremlev WITH curMaxRemLev.cur_maxremlev, ;
                cur_remtext WITH l_cRemText ;
                FOR ap_aracct = curMaxRemLev.ac_aracct IN &lp_cCurRem
      SELECT curMaxRemLev
 ENDSCAN
 USE
 SELECT &lp_cCurRem
 IF lp_lOnlyMarked
      SET FILTER TO cur_mark
 ENDIF
 GO TOP
 IF INLIST(lp_oPrintParams.nRemainderFilter, 4, 5)
      INDEX ON STR(ac_aracct,10)+STR(cur_remlev,1) TAG TAG1
      l_cRepName = "arremainder2.frx"
 ELSE
      l_cRepName = "arremainder1.frx"
 ENDIF

 l_cFor = ".T."
 l_cReport = ADDBS(gcReportdir)+l_cRepName
 l_lNoListsTable = .T.

 IF g_lUseNewRepPreview
      loSession=EVALUATE([xfrx("XFRX#LISTENER")])
      lnRetVal = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
      IF lnRetVal = 0
           l_lAutoYield = _vfp.AutoYield
           _vfp.AutoYield = .T.
           REPORT FORM (l_cReport) FOR &l_cFor OBJECT loSession
           loXFF = loSession.oxfDocument 
           _vfp.AutoYield = l_lAutoYield
           loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
           loExtensionHandler.lNoListsTable = l_lNoListsTable
           loPreview = CREATEOBJECT("frmMpPreviewerDesk")
           loPreview.setExtensionHandler(loExtensionHandler)
           loPreview.PreviewXFF(loXFF)
           loPreview.show(1)
           loExtensionHandler = .NULL.
      ENDIF
 ELSE
      REPORT FORM (l_cReport) FOR &l_cFor PREVIEW
 ENDIF

 SELECT &lp_cCurRem
 IF INLIST(lp_oPrintParams.nRemainderFilter, 4, 5)
      SET ORDER TO
      DELETE TAG TAG1
 ENDIF

 ArSetStatusLine()
 l_lDone = .F.
 SCAN ALL
      ArSetPrinted(lp_oPrintParams, ap_lineid, .T.)
      REPLACE cur_printed WITH .T.
 ENDSCAN
 FLUSH
 = ArUpdateReceivablesList(@lp_oPrintParams)
 IF lp_lOnlyMarked
      SET FILTER TO
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE ArPrintStatments
 LPARAMETERS lp_oPrintParams, lp_cCurRem, lp_lOnlyMarked
 LOCAL l_dSettlementDay
 LOCAL loSession, lnRetval, loXFF, loPreview, loExtensionHandler, l_lAutoYield
 LOCAL l_cFor, l_cReport, l_lNoListsTable, l_oFrmPreview
 l_dSettlementDay = lp_oPrintParams.dSettlementDay
 SELECT &lp_cCurRem
 IF lp_lOnlyMarked
      SET FILTER TO cur_mark
 ENDIF
 GO TOP

 l_cRepName = "arstatments.frx"
 l_cFor = ".T."
 l_cReport = ADDBS(gcReportdir)+l_cRepName
 l_lNoListsTable = .T.

 IF g_lUseNewRepPreview
      loSession=EVALUATE([xfrx("XFRX#LISTENER")])
      lnRetVal = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
      IF lnRetVal = 0
           l_lAutoYield = _vfp.AutoYield
           _vfp.AutoYield = .T.
           REPORT FORM (l_cReport) FOR &l_cFor OBJECT loSession
           loXFF = loSession.oxfDocument 
           _vfp.AutoYield = l_lAutoYield
           loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
           loExtensionHandler.lNoListsTable = l_lNoListsTable
           loPreview = CREATEOBJECT("frmMpPreviewerDesk")
           loPreview.setExtensionHandler(loExtensionHandler)
           loPreview.PreviewXFF(loXFF)
           loPreview.show(1)
           loExtensionHandler = .NULL.
      ENDIF 
 ELSE
      REPORT FORM (l_cReport) FOR &l_cFor PREVIEW
 ENDIF
 SELECT &lp_cCurRem
 ArSetStatusLine()
 SCAN ALL
      ArSetPrinted(lp_oPrintParams, ap_lineid, .T.)
      REPLACE cur_printed WITH .T.
 ENDSCAN
 = ArUpdateReceivablesList(@lp_oPrintParams)
 IF lp_lOnlyMarked
      SET FILTER TO
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE ArConfirmRemainders
 LPARAMETERS lp_oPrintParams, lp_cCurRem
 LOCAL l_nSelect, l_lDone, l_cWhere
 l_nSelect = SELECT()
 l_lDone = .T.
 SELECT &lp_cCurRem
 SCAN FOR cur_printed
      UpdReminder(cur_remlev, lp_cCurRem)
      ArSetCompleted(ap_lineid, l_lDone, @lp_oPrintParams, lp_cCurRem)
 ENDSCAN
 IF ArCheckCompleteReceivablesList(lp_oPrintParams.nAgId)
      = ArCheckUncompleteReceivables(lp_oPrintParams.nAgId)
 ENDIF
 = ArUpdateReceivablesList(@lp_oPrintParams)
 DELETE FOR cur_printed IN &lp_cCurRem
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArConfirmStatments
 LPARAMETERS lp_oPrintParams, lp_cCurRem
 LOCAL l_nSelect, l_cWhere, l_lDone
 l_lDone = .T.
 l_nSelect = SELECT()
 SELECT &lp_cCurRem
 SCAN FOR cur_printed
      UpdStatement(ap_lineid)
      ArSetCompleted(ap_lineid, l_lDone, @lp_oPrintParams, lp_cCurRem)
 ENDSCAN
 IF ArCheckCompleteReceivablesList(lp_oPrintParams.nAgId)
      = ArCheckUncompleteReceivables(lp_oPrintParams.nAgId)
 ENDIF
 = ArUpdateReceivablesList(@lp_oPrintParams)
 DELETE FOR cur_printed IN &lp_cCurRem
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArSetPrinted
 LPARAMETERS lp_oPrintParams, lp_nLineId, lp_lPrinted
 LOCAL l_cKey
 l_cKey = STR(lp_oPrintParams.nAgId,8) + STR(lp_nLineId,8)
 REPLACE ak_printed WITH lp_lPrinted FOR STR(ak_agid,8)+STR(ak_lineid,8) = l_cKey IN arremlet
 FLUSH
 RETURN .T.
ENDPROC
*
PROCEDURE ArSetCompleted
 LPARAMETERS lp_nLineId, lp_lCompleted, lp_oPrintParams, lp_cCurRem
 LOCAL l_dSysdate, l_oCurData, l_nSelect
 l_nSelect = SELECT()
 l_dSysdate = sysdate()
 SELECT &lp_cCurRem
 SCATTER MEMO NAME l_oCurData
 ArSaveSelectedReceivables(@lp_oPrintParams, lp_nLineId, @l_oCurData, lp_lCompleted)
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArRemoveReceivableFromList
 LPARAMETERS lp_oPrintParams, lp_nLineId, lp_oCurData
 LOCAL l_lCompleted, l_lDeleted
 l_lCompleted = .F.
 l_lDeleted = .T.
 = ArSaveSelectedReceivables(@lp_oPrintParams, lp_nLineId, @lp_oCurData, l_lCompleted, l_lDeleted)
 IF ArCheckCompleteReceivablesList(lp_oPrintParams.nAgId)
      = ArCheckUncompleteReceivables(lp_oPrintParams.nAgId)
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE ArSaveSelectedReceivables
 LPARAMETERS lp_oPrintParams, lp_nLineId, l_oCurData, lp_lCompleted, lp_lDeleted
 LOCAL l_nSelect, l_oData, l_cKey
 l_nSelect = SELECT()
 l_cKey = STR(lp_oPrintParams.nAgId,8) + STR(lp_nLineId,8)
 IF dlocate("arremlet","STR(ak_agid,8)+STR(ak_lineid,8) = " + sqlcnv(l_cKey))
      SELECT arremlet
      SCATTER MEMO NAME l_oData
 ELSE
      SELECT arremlet
      SCATTER MEMO NAME l_oData BLANK
      l_oData.ak_agid = lp_oPrintParams.nAgId
      l_oData.ak_lineid = lp_nLineId
      l_oData.ak_showdoc = lp_oPrintParams.lWriteInDocuments
      APPEND BLANK
 ENDIF
 l_oData.ak_amid = l_oCurData.cur_amid
 l_oData.ak_duedat = l_oCurData.cur_duedate
 l_oData.ak_header = l_oCurData.cur_headtext
 l_oData.ak_remtxt = l_oCurData.cur_text
 l_oData.ak_balance = l_oCurData.cur_bal
 l_oData.ak_feerem = l_oCurData.cur_fixamt
 l_oData.ak_perrem = l_oCurData.cur_peramt
 l_oData.ak_remlev = l_oCurData.cur_remlev
 IF lp_lCompleted
      l_oData.ak_compl = .T.
      l_oData.ak_rmsdat = sysdate()
 ENDIF
 IF lp_lDeleted
      l_oData.ak_deleted = .T.
 ENDIF
 GATHER NAME l_oData MEMO
 FLUSH
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArNewReceivablesList
 LPARAMETERS lp_oPrintParams
 LOCAL l_oData, l_nSelect
 l_nSelect = SELECT()
 SELECT argenrem
 SCAN FOR NOT ag_compl AND ag_userid = g_userid AND ;
           IIF(lp_oPrintParams.lCreditors,ag_credito,NOT ag_credito)
      ArCheckUncompleteReceivables(ag_agid)
 ENDSCAN
 SELECT argenrem
 SCATTER MEMO NAME l_oData BLANK
 l_oData.ag_agid = nextid("ARGENREM")
 l_oData.ag_date = DATETIME()
 l_oData.ag_acfrom = lp_oPrintParams.nFrom
 l_oData.ag_acto = lp_oPrintParams.nTo
 l_oData.ag_actype = lp_oPrintParams.cDebitorType
 l_oData.ag_setday = lp_oPrintParams.dSettlementDay
 l_oData.ag_remfil = lp_oPrintParams.nRemainderFilter
 l_oData.ag_stmfil = lp_oPrintParams.nStatmentFilter
 l_oData.ag_inclds = lp_oPrintParams.lDisputed
 l_oData.ag_wrdoc = lp_oPrintParams.lWriteInDocuments
 l_oData.ag_docdesc = lp_oPrintParams.cDescText
 l_oData.ag_userid = g_userid
 l_oData.ag_credito = lp_oPrintParams.lCreditors
 l_oData.ag_onlydep = lp_oPrintParams.lOnlyDeposits
 APPEND BLANK
 GATHER NAME l_oData MEMO
 FLUSH
 lp_oPrintParams.nAgId = l_oData.ag_agid
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArCheckUncompleteReceivables
 LPARAMETERS lp_nAgId
 LOCAL l_nSelect
 l_nSelect = SELECT()
 SELECT arremlet
 LOCATE FOR STR(ak_agid,8)+STR(ak_lineid,8) = STR(lp_nAgId,8) AND ak_compl
 IF FOUND()
      ArSaveCompleteReceivablesList(lp_nAgId)
 ELSE
      ArDeleteUncompleteReceivables(lp_nAgId)
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArSaveCompleteReceivablesList
 LPARAMETERS lp_nAgId
 DELETE FOR STR(ak_agid,8)+STR(ak_lineid,8) = STR(lp_nAgId,8) AND NOT ak_compl IN arremlet
 REPLACE ag_compl WITH .T. ;
           ag_userid WITH g_userid ;
           FOR ag_agid = lp_nAgId IN argenrem
 FLUSH
 RETURN .T.
ENDPROC
*
PROCEDURE ArDeleteUncompleteReceivables
 LPARAMETERS lp_nAgId
 DELETE FOR STR(ak_agid,8)+STR(ak_lineid,8) = STR(lp_nAgId,8) IN arremlet
 DELETE FOR ag_agid = lp_nAgId IN argenrem
 FLUSH
 RETURN .T.
ENDPROC
*
PROCEDURE ArCheckCompleteReceivablesList
 LPARAMETERS lp_nAgId
 LOCAL l_nSelect, l_cOrder, l_nSumAll, l_nSumCompleted, l_lCompleted
 STORE 0 TO l_nSumAll, l_nSumCompleted
 l_nSelect = SELECT()
 SELECT arremlet
 l_cOrder = ORDER()
 SET ORDER TO
 SCAN FOR STR(ak_agid,8)+STR(ak_lineid,8) = STR(lp_nAgId,8) AND NOT ak_deleted
      l_nSumAll = l_nSumAll + 1
      IF ak_compl
           l_nSumCompleted = l_nSumCompleted + 1
      ENDIF
 ENDSCAN
 IF l_nSumAll = l_nSumCompleted
      l_lCompleted = .T.
 ENDIF
 SET ORDER TO l_cOrder
 SELECT (l_nSelect)
 RETURN l_lCompleted
ENDPROC
*
PROCEDURE ArUpdateReceivablesList
 LPARAMETERS lp_oPrintParams
 IF dlocate("argenrem","ag_agid = " + sqlcnv(lp_oPrintParams.nAgId))
      IF argenrem.ag_setday <> lp_oPrintParams.dSettlementDay
           REPLACE ag_setday WITH lp_oPrintParams.dSettlementDay IN argenrem
           FLUSH
      ENDIF
 ENDIF
 RETURN .T.
ENDPROC
*
FUNCTION CreateRemainderCursor
 LPARAMETERS lp_cSourceCur, lp_cDestCur
 LOCAL ARRAY l_aFields(1)
 = AFIELDS(l_aFields,lp_cSourceCur)
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_TEXT', 'M', 4, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_FIXAMT', 'B', 8, 2
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_PERAMT', 'B', 8, 2
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_TITLE', 'C', 20, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_FNAME', 'C', 20, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_LNAME', 'C', 30, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_SALUTE', 'C', 50, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_COMPANY', 'C', 50, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_REMLEV', 'N', 1, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_MAXREMLEV', 'N', 1, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_MARK', 'L', 1, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_DUEDATE', 'D', 8, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_CITY', 'C', 30, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_REMTEXT', 'M', 4, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_PRINTED', 'L', 1, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_HEADTEXT', 'C', 254, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_AMID', 'N', 8, 0
 DO CursorAddField IN procbill WITH l_aFields, 'CUR_MAXRLV', 'N', 1, 0
 CREATE CURSOR (lp_cDestCur) FROM ARRAY l_aFields
 RETURN .T.
ENDFUNC
*
PROCEDURE GetRemainderPrintModes
LPARAMETERS l_cCurName, lp_lCreditors
 CREATE CURSOR &l_cCurName (cur_no n(10), cur_name c(70))
 IF NOT lp_lCreditors
      LOCAL l_lForbidenRem4
      l_lForbidenRem4 = param.pa_noreml4
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (1, GetLangText("AR","TXT_REMAINDER_FILTER_1"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (2, GetLangText("AR","TXT_REMAINDER_FILTER_2"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (3, GetLangText("AR","TXT_REMAINDER_FILTER_3"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (4, GetLangText("AR","TXT_REMAINDER_FILTER_4"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (5, GetLangText("AR","TXT_REMAINDER_FILTER_5"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (6, GetLangText("AR","TXT_REMAINDER_FILTER_6"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (7, GetLangText("AR","TXT_REMAINDER_FILTER_7"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (8, GetLangText("AR","TXT_REMAINDER_FILTER_8"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (9, GetLangText("AR","TXT_REMAINDER_FILTER_9"))
      IF NOT l_lForbidenRem4
           INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (10, GetLangText("AR","TXT_REMAINDER_FILTER_10"))
      ENDIF
 ELSE
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (1, GetLangText("AR","TXT_CREDITOR_FILTER_1"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (2, GetLangText("AR","TXT_CREDITOR_FILTER_2"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (3, GetLangText("AR","TXT_CREDITOR_FILTER_3"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (4, GetLangText("AR","TXT_CREDITOR_FILTER_4"))
      INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (5, GetLangText("AR","TXT_CREDITOR_FILTER_5"))
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE GetStatmentPrintModes
LPARAMETERS l_cCurName
 CREATE CURSOR &l_cCurName (cur_no n(10), cur_name c(70))
 INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (1, GetLangText("AR","TXT_STATMENT_FILTER_1"))
 INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (2, GetLangText("AR","TXT_STATMENT_FILTER_2"))
 INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (3, GetLangText("AR","TXT_STATMENT_FILTER_3"))
 INSERT INTO &l_cCurName (cur_no, cur_name) VALUES (4, GetLangText("AR","TXT_STATMENT_FILTER_4"))
 RETURN .T.
ENDPROC
*
PROCEDURE ArDispute
 LPARAMETERS lp_oArpostRecord, lp_cCurName, lp_lSuccess
 LOCAL l_nSelect
 l_nSelect = SELECT()
 SELECT arpost
 LOCATE FOR ap_lineid = lp_oArpostRecord.ap_lineid
 IF NOT FOUND() OR ap_lineid <> ap_headid OR NOT lp_oArpostRecord.ap_dispute
      lp_lSuccess = .F.
      RETURN .F.
 ENDIF
 IF NOT EMPTY(lp_oArpostRecord.ap_disdate) AND lp_oArpostRecord.ap_disdate < sysdate()
      lp_oArpostRecord.ap_disdate = {}
 ENDIF
 REPLACE ap_dispute WITH .T., ;
           ap_disdate WITH lp_oArpostRecord.ap_disdate, ;
           ap_disreas WITH lp_oArpostRecord.ap_disreas
 FLUSH
 SCATTER NAME lp_oArpostRecord MEMO
 lp_lSuccess = .T.
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArCancelDispute
 LPARAMETERS lp_nLineID, lp_lSuccess
 LOCAL l_nSelect
 l_nSelect = SELECT()
 SELECT arpost
 LOCATE FOR ap_lineid = lp_nLineID
 IF NOT FOUND() OR ap_lineid <> ap_headid
      lp_lSuccess = .F.
      RETURN .F.
 ENDIF
 REPLACE ap_dispute WITH .F., ;
         ap_disdate WITH {}, ;
         ap_disreas WITH ""
 lp_lSuccess = .T.
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
PROCEDURE UpdStatement
 LPARAMETERS lp_nApLineId
 LOCAL l_nSelect
 l_nSelect = SELECT()
 IF dlOcate('ArPost','ap_lineid = '+sqLcnv(lp_nApLineId))
      SELECT arPost
      REPLACE ap_stmlast WITH sySdate()
      FLUSH
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE UpdReminder
 PARAMETER pnLevel, pcAlias, pdLastRemainderDate
 PRIVATE naRea, nrEc
 LOCAL l_oData, l_cIncLevField, l_dLastRemDat, l_ni
 naRea = SELECT()
 nrEc = RECNO()
 SELECT (pcAlias)
 IF dlOcate('ArPost','ap_lineid = '+sqLcnv(ap_lineid)) AND ;
           NOT (pnLevel = 0 AND ap_remlev = 0) AND NOT ArAccount([ArIsDisputed], ap_dispute, ap_disdate)
      SELECT arPost
      SCATTER NAME l_oData
      DO CASE
           CASE pnLevel < ap_remlev && Reduced remainder level
                DO CASE
                     CASE pnLevel = 0
                          l_oData.ap_remlev = 0
                          l_oData.ap_remlast = {}
                          l_oData.ap_inclev1 = {}
                          l_oData.ap_inclev2 = {}
                          l_oData.ap_inclev3 = {}
                          l_oData.ap_inclev4 = {}
                     CASE pnLevel = 1
                          l_cIncLevField = "l_oData.ap_inclev"+STR(pnLevel,1)
                          IF EMPTY(pdLastRemainderDate)
                               l_dLastRemDat = &l_cIncLevField
                          ELSE
                               l_dLastRemDat = pdLastRemainderDate
                          ENDIF
                          l_oData.ap_remlev = 1
                          l_oData.ap_remlast = l_dLastRemDat
                          l_oData.ap_inclev4 = {}
                          l_oData.ap_inclev3 = {}
                          l_oData.ap_inclev2 = {}
                          l_oData.ap_inclev1 = l_oData.ap_remlast
                     CASE pnLevel = 2
                          l_cIncLevField = "l_oData.ap_inclev"+STR(pnLevel,1)
                          IF EMPTY(pdLastRemainderDate)
                               l_dLastRemDat = &l_cIncLevField
                          ELSE
                               l_dLastRemDat = pdLastRemainderDate
                          ENDIF
                          l_oData.ap_remlev = 2
                          l_oData.ap_remlast = l_dLastRemDat
                          l_oData.ap_inclev4 = {}
                          l_oData.ap_inclev3 = {}
                          l_oData.ap_inclev2 = l_oData.ap_remlast
                     CASE pnLevel = 3
                          l_cIncLevField = "l_oData.ap_inclev"+STR(pnLevel,1)
                          IF EMPTY(pdLastRemainderDate)
                               l_dLastRemDat = &l_cIncLevField
                          ELSE
                               l_dLastRemDat = pdLastRemainderDate
                          ENDIF
                          l_oData.ap_remlev = 3
                          l_oData.ap_remlast = l_dLastRemDat
                          l_oData.ap_inclev4 = {}
                          l_oData.ap_inclev3 = l_oData.ap_remlast
                ENDCASE
           CASE pnLevel > ap_remlev && increased rem level
                l_dLastRemDat = IIF(EMPTY(pdLastRemainderDate),SysDate(),pdLastRemainderDate)
                l_oData.ap_remlast = l_dLastRemDat
                l_oData.ap_remcnt = MIN(ap_remcnt+1, 99)
                FOR l_ni = 1 TO pnLevel
                     l_cIncLevField = "l_oData.ap_inclev"+STR(l_ni,1)
                     IF EMPTY(&l_cIncLevField)
                          &l_cIncLevField  = l_dLastRemDat
                     ENDIF
                ENDFOR
                l_oData.ap_remlev = pnLevel
           OTHERWISE && Equal rem. level, but remainder letter with this bill is sent again
                l_oData.ap_remcnt = MIN(ap_remcnt+1, 99)
      ENDCASE
      GATHER NAME l_oData
      FLUSH
 ENDIF
 SELECT (pcAlias)
 SELECT (naRea)
 GOTO nrEc
 RETURN
ENDPROC
*
PROCEDURE ArChangeRemainder
 LPARAMETER lp_nLevel, lp_cAlias, lp_dLastRemainderDate, lp_lDontChangePrintStatus, lp_oPrintParams
 LOCAL l_nSelect
 l_nSelect = SELECT()
 UpdReminder(lp_nLevel, lp_cAlias, lp_dLastRemainderDate)
 IF NOT lp_lDontChangePrintStatus
      ArSetPrinted(lp_oPrintParams, ap_lineid, .F.)
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArGetRemainderDialog
 LPARAMETERS lp_adLg, lp_cDefRelLev, lp_lForbidenRem4
 EXTERNAL ARRAY lp_adLg
 lp_adLg[1, 1] = "l_nRemLev"
 lp_adLg[1, 2] = GetLangText("ADDRESS","TXT_REMAINDER_LEVEL")
 lp_adLg[1, 3] = lp_cDefRelLev
 lp_adLg[1, 4] = "9"
 lp_adLg[1, 5] = 8
 IF lp_lForbidenRem4
      lp_adLg[1, 6] = "BETWEEN(l_nRemLev,0,3)"
 ELSE
      lp_adLg[1, 6] = "BETWEEN(l_nRemLev,0,4)"
 ENDIF
 lp_adLg[1, 7] = ""
 lp_adLg[1, 8] = 0
 lp_adLg[2, 1] = "l_dLastRemDate"
 lp_adLg[2, 2] = GetLangText("AR","T_REMLAST")
 lp_adLg[2, 3] = "p_dDefLastRemDate"
 lp_adLg[2, 4] = "D"
 lp_adLg[2, 5] = 15
 lp_adLg[2, 6] = "l_dLastRemDate<=sysdate()"
 lp_adLg[2, 7] = ""
 lp_adLg[2, 8] = 0
RETURN .T.
ENDPROC
*
PROCEDURE ArAudit
 PRIVATE naRea
 naRea = SELECT()
 IF doPen('ArPost')
      IF paRam.pa_delledg>0
           SELECT arPost
           SCAN ALL
                IF ap_headid=ap_lineid .AND.  .NOT. ArAccount("ArIsDisputed", ap_dispute, ap_disdate)
                     IF arPstbal(ap_headid,0,.T.)=0
                          IF laSttransact(ap_headid)<=sySdate()- ;
                             paRam.pa_delledg
                             IF procvoucher("DebitorForVoucherDeleteAllowed",arPost.ap_billnr)
                                  = apDel(ap_headid)
                             ELSE
                                  IF NOT ap_vblock
                                       REPLACE ap_vblock WITH .T.
                                  ENDIF
                             ENDIF
                          ENDIF
                     ENDIF
                ENDIF
           ENDSCAN
      ENDIF
      = dcLose('ArPost')
 ENDIF
 SELECT (naRea)
 RETURN
ENDPROC
*
FUNCTION LastTransact
 PARAMETER pnHeadid
 PRIVATE naPrec, naRea, drEt
 drEt = {}
 naRea = SELECT()
 SELECT arPost
 naPrec = RECNO()
 CALCULATE MAX(ap_sysdate) TO drEt FOR ap_headid=pnHeadid
 GOTO naPrec
 SELECT (naRea)
 RETURN drEt
ENDFUNC
*
PROCEDURE ApDel
 PARAMETER pnHeadid
 PRIVATE naRea, nrEc
 IF pnHeadid<>0
      naRea = SELECT()
      SELECT arPost
      nrEc = RECNO()
      *LOCATE FOR ap_lineid = pnHeadid
      *DO BillNumChange IN ProcBill WITH ap_billnr, "CANCEL", "from A/R Accounts (Debitoren)"
      DELETE ALL FOR ap_headid=pnHeadid
      FLUSH
      GOTO nrEc
      SELECT (naRea)
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE ArSetStatusLine
 SetStatusLine()
 RETURN .T.
ENDPROC
*
PROCEDURE ArGetRecivablesForAddress
 LPARAMETERS lp_nAddrId, lp_cResCurName
 LOCAL l_nSelect, l_cCurPrintedRem, l_cDocType
 l_cDocType = "ARRECIVABL"
 l_nSelect = SELECT()
 l_cCurPrintedRem = SYS(2015)
 l_cWhere = sqland("","ac_addrid = " + sqlcnv(lp_nAddrId))
 l_cWhere = sqland(l_cWhere,"NOT ac_credito")
 l_cWhere = sqland(l_cWhere,"ak_showdoc = " + sqlcnv(.T.))
 l_cWhere = sqland(l_cWhere,"ak_compl = " + sqlcnv(.T.))
 SELECT ag_agid, ag_docdesc, ag_date, ag_userid FROM aracct ;
           LEFT JOIN arpost ON ac_aracct = ap_aracct ;
           LEFT JOIN arremlet ON ak_lineid = ap_lineid ;
           LEFT JOIN argenrem ON ag_agid = ak_agid ;
           WHERE &l_cWhere ;
           GROUP BY ag_agid ;
           HAVING NOT ISNULL(ag_agid) ;
           ORDER BY 1 ;
           INTO CURSOR &l_cCurPrintedRem
 IF RECCOUNT()>0
      SCAN ALL
           SELECT curTempDocument
           APPEND BLANK
           REPLACE dc_agid WITH &l_cCurPrintedRem..ag_agid, ;
                     dc_date WITH TTOD(&l_cCurPrintedRem..ag_date), ;
                     dc_time WITH PADL(HOUR(&l_cCurPrintedRem..ag_date), 2, "0")+":"+PADL(MINUTE(&l_cCurPrintedRem..ag_date), 2, "0"), ;
                     dc_addrid WITH lp_nAddrId, ;
                     dc_descr WITH &l_cCurPrintedRem..ag_docdesc, ;
                     dc_userid WITH &l_cCurPrintedRem..ag_userid, ;
                     dc_type WITH l_cDocType
           SELECT &l_cCurPrintedRem
      ENDSCAN
 ENDIF
 USE IN &l_cCurPrintedRem
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArShowRecivablesForAddress
 LPARAMETERS lp_nAddrid, lp_nAgId
 LOCAL ARRAY l_aParameters(2)
     l_aParameters(1) = lp_nAgId
     l_aParameters(2) = lp_nAddrid
     doform('arremshow','forms\arremshow','',.F.,@l_aParameters)
 RETURN .T.
ENDPROC
*
PROCEDURE ArDeleteRecivablesListFromAddress
 LPARAMETERS lp_nAddrid, lp_nAgId
 LOCAL l_nSelect, l_cWhere, l_cCurForDelete, l_cKey, l_lFound
 l_nSelect = SELECT()
 l_cCurForDelete = SYS(2015)
 l_lFound = ArGetRecivableListForAddress(lp_nAddrid, lp_nAgId, l_cCurForDelete)
  IF l_lFound
      SCAN ALL
           l_cKey = STR(lp_nAgId,8) + STR(ak_lineid,8)
           IF dlocate("arremlet","STR(ak_agid,8)+STR(ak_lineid,8) = " + sqlcnv(l_cKey))
                REPLACE ak_showdoc WITH .F. IN arremlet
                FLUSH
           ENDIF
      ENDSCAN
 ENDIF
 USE IN &l_cCurForDelete
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE ArGetRecivableListForAddress
 LPARAMETERS lp_nAddrid, lp_nAgId, lp_cResCurName
 LOCAL l_cResultsFound, l_cWhere
 l_cWhere = sqland("","ak_agid = " + sqlcnv(lp_nAgId))
 l_cWhere = sqland(l_cWhere,"ac_addrid = " + sqlcnv(lp_nAddrid))
 l_cWhere = sqland(l_cWhere,"ak_showdoc = " + sqlcnv(.T.))
 l_cWhere = sqland(l_cWhere,"ak_compl = " + sqlcnv(.T.))
 SELECT ak_lineid FROM arremlet ;
           LEFT JOIN arpost ON ap_lineid = ak_lineid ;
           LEFT JOIN aracct ON ac_aracct = ap_aracct ;
           WHERE &l_cWhere ;
           INTO CURSOR &lp_cResCurName
 IF RECCOUNT()>0
      l_cResultsFound = .T.
 ENDIF
 RETURN l_cResultsFound
ENDPROC
*
PROCEDURE ArCollectingAgencyUpdate
 LPARAMETERS l_oArpost, lp_lSuccess
 LOCAL l_lSuccess, l_nSelect, l_nArPostRecNo
 l_nSelect = SELECT()
 l_nArPostRecNo = RECNO("arpost")
 IF dlocate("arpost","ap_lineid = " + sqlcnv(l_oArpost.ap_lineid))
      SELECT arpost
      IF NOT l_oArpost.ap_colagnt
           REPLACE ap_colagnt WITH .F., ;
                     ap_coldate WITH {}, ;
                     ap_colnote WITH ""
      ELSE
           REPLACE ap_colagnt WITH l_oArpost.ap_colagnt, ;
                     ap_coldate WITH l_oArpost.ap_coldate, ;
                     ap_colnote WITH l_oArpost.ap_colnote
      ENDIF
      IF CURSORGETPROP("Buffering","arpost")==5
           = TABLEUPDATE(0,.T.,"arpost")
      ENDIF
      FLUSH
      l_lSuccess = .T.
 ENDIF
 GO l_nArPostRecNo IN arpost
 SELECT (l_nSelect)
 lp_lSuccess = l_lSuccess
 RETURN l_lSuccess
ENDPROC
*