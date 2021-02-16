#INCLUDE "include\constdefines.h"
*
 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
               lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13, ;
               lp_uParam14
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
FUNCTION NightAudit
 PRIVATE caUditlogfile, ceXtprg, p_oAudit
 LOCAL llAuditOK, lcAbortText, l_nCount, l_lContinue, l_lSuccess
 LOCAL ARRAY aProgress(3)
 llAuditOK = .F.
 lcAbortText = ""
 caUditlogfile = "Audit.Log"
 IF _screen.oGlobal.lDoAuditOnStartup
      = loGdata("Try AUTOMATIC nightaudit on "+DTOC(DATE())+ " at "+TIME(),caUditlogfile)
       * Automatic audit
      IF NOT _screen.oGlobal.oParam2.pa_autoaud
          = loGdata("Automatic audit disabled. Aborting.",caUditlogfile)
          RETURN .F.
      ENDIF
      IF EMPTY(GETENV("BFW_LOGIN"))
          = loGdata("BFW_LOGIN empty. Aborting.",caUditlogfile)
          RETURN .F.
      ELSE
          login(.F.)
          IF EMPTY(g_Userid)
               = loGdata("Can't login with user "+GETENV("BFW_LOGIN")+". Aborting.",caUditlogfile)
               RETURN .F.
          ENDIF
      ENDIF
      DO DBBlockOtherWorkStations IN dbupdate WITH l_lSuccess
      IF NOT l_lSuccess
           = loGdata("Can't logout users. Aborting.",caUditlogfile)
           RETURN .F.
      ENDIF
 ENDIF

 IF !TYPE("_screen.ActiveForm.name")="U"
      IF (WEXIST ('FAddressMask') OR WEXIST ('FWeekform'))
           MESSAGEBOX(GetLangText("COMMON","T_CLOSEALLWINDOWSFIRST"),16,GetLangText("RECURRES","TXT_INFORMATION"))
           RETURN
      ENDIF
 ENDIF
 DO WHILE (.T.)
      DO SetMessagesOff IN procmessages
      IF NOT allowlogin(.f.) && Dont allow access to other users
           = loGdata(TRANSFORM(DATETIME())+"|Detected users logged in. Aborting.",caUditlogfile)
           EXIT
      ENDIF
      IF NOT _screen.oGlobal.lDoAuditOnStartup
           IF ( .NOT. yeSno(GetLangText("AUDIT","TA_STARTAUDIT")+" "+DTOC(sySdate())+"?"))
                EXIT
           ENDIF
      ENDIF
      DO FORM "forms\audit" WITH ChildTitle(GetLangText("MANAGER","TXT_AUDITINFO")) NAME p_oAudit
      p_oAudit.Initprogress(14)
      = loGdata("Start nightaudit by user "+cuSerid+" on "+DTOC(DATE())+ ;
        " at "+TIME(),caUditlogfile)
      NAuditBackup()
      IF param.pa_audtbl
           l_lContinue = .T.
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                l_lContinue = yesno(GetLangText("AUDIT","TA_START_DATABASE_REBUILD"))
           ENDIF
           IF l_lContinue
                TryRebuildDatabase()
           ENDIF
      ENDIF

      IF NOT (USED("license") AND ISEXCLUSIVE("license"))&&( .NOT. opEnfile(.T.,"param"))
           = loGdata("There are users in "+gcApplication,caUditlogfile)
           l_lContinue = .F.
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                l_lContinue = ;
                          yesno(STRTRAN(TRIM(GetLangText("AUDIT","TA_USERSACTIVE1"))+ ;
                          ' '+TRIM(GetLangText("AUDIT","TA_USERSACTIVE2"))+' '+ ;
                          TRIM(GetLangText("AUDIT","TA_USERSACTIVE3")), ';', (CHR(13)+ ;
                          CHR(10))))
           ENDIF
           IF NOT l_lContinue
                = loGdata("Stop audit for this reason",caUditlogfile)
                EXIT
           ENDIF
           = loGdata("Continue audit with other users in "+gcApplication, ;
             caUditlogfile)
      ENDIF
      IF (DATE()==paRam.pa_lastaud)
           = loGdata("Another audit executed today",caUditlogfile)
           l_lContinue = .F.
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                l_lContinue = ;
                          yeSno(GetLangText("AUDIT","TXT_TODAYYOUDIDANAUDIT")+ ;
                          (CHR(13)+CHR(10))+GetLangText("AUDIT","TXT_CONTINUE")+"?@2")
           ENDIF
           IF NOT l_lContinue
                = loGdata("Do not continue Audit",caUditlogfile)
                EXIT
           ENDIF
           = loGdata("Continue audit for this date",caUditlogfile)
      ENDIF
      IF ( .NOT. auDitallowed())
           = loGdata("Audit not allowed, time interval to small",caUditlogfile)
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                = alErt(GetLangText("AUDIT","TXT_TE1")+(CHR(13)+CHR(10))+GetLangText("AUDIT", ;
                  "TXT_TE2")+(CHR(13)+CHR(10))+GetLangText("AUDIT","TXT_TE3")+ ;
                  (CHR(13)+CHR(10))+GetLangText("AUDIT","TXT_TE4")+(CHR(13)+CHR(10))+ ;
                  GetLangText("AUDIT","TXT_TE5")+(CHR(13)+CHR(10)))
           ENDIF
           EXIT
      ENDIF
      IF ( .NOT. opEnfile(.F.,"Manager") .OR.  .NOT. opEnfile(.F., ;
         "Sheet") .OR.  .NOT. opEnfile(.F.,"Banquet") .OR.  .NOT.  ;
         opEnfile(.F.,"ResFix"))
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                = alErt(GetLangText("AUDIT","TXT_CANNOTOPENMANAGER"))
           ENDIF
           lcAbortText = GetLangText("AUDIT","TXT_CANNOTOPENMANAGER")
           EXIT
      ENDIF

      aProgress(1) = RECCOUNT("reservat")
      aProgress(2) = aProgress(1)
      IF param.pa_audnost
	  	l_nCount = 2
	  ELSE
		aProgress(3) = RECCOUNT("post")
		l_nCount = 3
      ENDIF
      p_oAudit.Progress()
      p_oAudit.scrollProgressInit(@aProgress, l_nCount)
      IF param2.pa_restran AND param2.pa_delrstr
           p_oAudit.txTinfo(GetLangText("AUDIT","TXT_DELETE_RES_TRAN_LOG"),1)
           PRT_NAreservattransactions()
      ENDIF
      p_oAudit.txTinfo(GetLangText("AUDIT","TXT_AUDIT")+" "+DTOC(sySdate()),1)
      p_oAudit.txTinfo(GetLangText("AUDIT","TXT_CHKARRIVALS")+" "+DTOC(sySdate()),1)
      IF  .NOT. EMPTY(paRam.pa_naxprg)
           ceXtprg = _screen.oGlobal.choteldir+'NA'+TRIM(paRam.pa_naxprg)+'.FXP'
           IF FILE(ceXtprg)
                RELEASE daexit
                PUBLIC daexit
                daexit = .f.
                do &cExtPrg with 'BEFOREAUDIT'
                IF TYPE("daexit")="L"
                    IF daexit
                         RELEASE daexit
                         IF NOT _screen.oGlobal.lDoAuditOnStartup
                              MESSAGEBOX(GetLangText("AUDIT","TXT_STOPEDFROMPROGRAM"),16,GetLangText("RECURRES","TXT_INFORMATION"))
                         ENDIF
                         = loGdata(GetLangText("AUDIT","TXT_STOPEDFROMPROGRAM"),caUditlogfile)
                         = loGdata("Stop audit for this reason",caUditlogfile)
                         EXIT
                    ENDIF
                ENDIF
                RELEASE daexit
           ENDIF
      ENDIF
      IF param.pa_jetwb
           najetweb("BEFOREAUDIT")
      ENDIF
      IF ( .NOT. arRivals())
           lcAbortText = [Answered with NO on question: ] + GetLangText("AUDIT","TXT_ARRIVALS")
           EXIT
      ENDIF
      p_oAudit.Progress()
      p_oAudit.txTinfo(GetLangText("AUDIT","TXT_CHKDEPARTURES")+" "+DTOC(sySdate()),1)
      IF ( .NOT. dePartures())
           lcAbortText = [Answered with NO on question: ] + GetLangText("AUDIT","TXT_DEPARTURES")
           EXIT
      ENDIF
      IF (paRam2.pa_imexpos)
           p_oAudit.Progress()
           p_oAudit.txTinfo(GetLangText("AUDIT","TXT_POSTTPOS") + " extern",1)
           IF ( .NOT. auditexpos())
                lcAbortText = [Aborted in TPOSAUDIEXTERN] 
                EXIT
           ENDIF
      ENDIF
      p_oAudit.Progress()
      p_oAudit.txTinfo(GetLangText("AUDIT","TXT_CLOSECASHIERS"),1)
      IF ( .NOT. caShclos())
           lcAbortText = [Answered with NO on question: ] + GetLangText("AUDIT","TXT_CASHIERSOPEN")
           EXIT
      ENDIF
      IF (paRam.pa_postpos .OR. paRam.pa_argus)
           p_oAudit.Progress()
           p_oAudit.txTinfo(GetLangText("AUDIT","TXT_POSTTPOS"),1)
           IF ( .NOT. tpOsaudi())
                lcAbortText = [Aborted in TPOSAUDI] 
                EXIT
           ENDIF
      ENDIF
      IF param2.pa_waaudit AND NOT EMPTY(param2.pa_wexedir) AND DIRECTORY(param2.pa_wexedir)
           p_oAudit.Progress()
           p_oAudit.txTinfo(GetLangText("AUDIT","TXT_WELLNESS"),1)
           IF NOT NAWellnessAudit()
                lcAbortText = [Aborted in Wellness audit.]
                EXIT
           ENDIF
      ENDIF

      * This is main funtion. Can be called from server
      **************************************************
      NADoMainFunctions()
      **************************************************

      SELECT paRam
      REPLACE paRam.pa_sysdate WITH paRam.pa_sysdate+1
      REPLACE paRam.pa_lastaud WITH DATE()
      REPLACE paRam.pa_lasttim WITH TIME()
      g_Sysdate = paRam.pa_sysdate
      _screen.oGlobal.RefreshTableParam()
      _screen.oGlobal.RefreshTableParam2()

      DO SetRoomsStatus IN procoos
      = opEnfile(.F.,"param")
      IF _SCREEN.OR
          p_oAudit.txtinfo(GetLangText("AUDIT","TXT_EXTRESER"),1)
          = ExtreserDoneStatus()
      ENDIF
      DO MLSaveResultsPack IN mylists
      p_oAudit.Progress()
      p_oAudit.txTinfo(GetLangText("AUDIT","TA_IMREADY"),1)
      IF  .NOT. EMPTY(paRam.pa_naxprg)
           ceXtprg = _screen.oGlobal.choteldir+'NA'+TRIM(paRam.pa_naxprg)+'.FXP'
           IF FILE(ceXtprg)
                do &cExtPrg with 'AFTERAUDIT'
           ENDIF
      ENDIF
      IF _screen.OL
           procemail("PESendAuto",.T.)
      ENDIF
      DO seTstatus IN Setup
      = clOsefile("Manager")
      = clOsefile("Sheet")
      = clOsefile("Banquet")
      = clOsefile("ResFix")
      llAuditOK = .T.
      EXIT
 ENDDO
 TRY
      p_oAudit.Release()
 CATCH
 ENDTRY
 IF llAuditOK
      IF NOT EMPTY(param.pa_audbat)
          = loGdata("Start Printing Batches at "+TIME(),caUditlogfile)
          = PrintBatches()
          = loGdata("End Printing Batches at "+TIME(),caUditlogfile)
      ENDIF
      IF NOT EMPTY(param2.pa_audsbat)
          = loGdata("Start Sending Batches at "+TIME(),caUditlogfile)
          = SendBatches()
          = loGdata("End Sending Batches at "+TIME(),caUditlogfile)
      ENDIF
      pbelpaykassenschnitt()
      = loGdata("Normal end of audit at "+TIME(),caUditlogfile)
      = loGdata("",caUditlogfile)      

     = opEnfile(.F.,"param")
     NAResetLogFiles()
     allowlogin(.t.)
     NAGetAddressMainChanges()
     IF NOT _screen.oGlobal.lDoAuditOnStartup
          = alErt(GetLangText("AUDIT","TA_IMREADY")+"!")
          = checkwin("LOGIN WITH .T.",.T.)
     ELSE
          RETURN TO MASTER
     ENDIF
 ELSE
      IF NOT EMPTY(lcAbortText)
           = loGdata("Stop audit for this reason: "+ lcAbortText,caUditlogfile)
           = loGdata("",caUditlogfile)    
      ENDIF
      = opEnfile(.F.,"param")
      DO SetMessagesOn IN procmessages
      allowlogin(.t.)
 ENDIF
 
 RETURN .T.
ENDFUNC
*
PROCEDURE NAMainFunctions
 LPARAMETERS lp_lNoProgressbarUpdate
 LOCAL l_lOldFlushForce, ceXtprg
 * From here, without user interaction
 IF lp_lNoProgressbarUpdate
      PRIVATE p_oAudit
      p_oAudit = NEWOBJECT("cauditfakeprogressbar","audit.prg")
 ENDIF
 IF TYPE("caUditlogfile")<>"C"
      PRIVATE caUditlogfile
      caUditlogfile = "Audit.Log"
 ENDIF
 IF g_lAutomationMode
      l_lOldFlushForce = _screen.oGlobal.lflushforce
      _screen.oGlobal.lflushforce = .F. && For optimize
      IF PEMSTATUS(p_oAudit,"deleteremotelog",5)
           p_oAudit.deleteremotelog()
      ENDIF
 ENDIF
 p_oAudit.txTinfo(GetLangText("AUDIT","TXT_AVAILABILITY"),1)
 g_auditactive = .T.
 relations()
 = StatOpenTables()
 DO ooodelete IN outoford WITH g_sysdate
 DO DeleteExpiredOOS IN procoos
 DO NaProcAZE IN ProcAze
 DO avLrebuild IN AvlUpdat
 p_oAudit.Progress()
 = upDledger()
 DO dpUpdate IN DP
 = NArrsyncreser()
 = poStall()
 p_oAudit.Progress()
 = nabmsdiscounts()
 = moVephonebooth()
 = hiStpost()
 p_oAudit.Progress()
 IF  .NOT. EMPTY(paRam.pa_naxprg)
      ceXtprg = _screen.oGlobal.choteldir+'NA'+TRIM(paRam.pa_naxprg)+'.FXP'
      IF FILE(ceXtprg)
           do &cExtPrg with 'BEFOREMANAGER'
      ENDIF
 ENDIF
 = maNager()
 = managerbuildings()
 p_oAudit.Progress()
 IF  _SCREEN.DV
      DO arAudit IN AR
 ENDIF
 IF _screen.dp
      DO dpAudit IN DP
 ENDIF
 **** DELETE THIS *********
 *mngbuildtest(g_sysdate)&&*
 *****!!!!!!!!!!!!*********
 DO acTaudit IN procaction
 = deLetepasserby()
 p_oAudit.Progress()
 = hiStreservat()
 p_oAudit.Progress()
 p_oAudit.TxtInfo(GetLangText("AUDIT","TA_STATISTICS"),1)
 IF NOT param.pa_audnost
     = Statistics(0)
     REPLACE pa_statdat WITH param.pa_sysdate+1 IN param
 ENDIF
 = StatCloseTables()
 p_oAudit.Progress()
 p_oAudit.txTinfo(GetLangText("AUDIT","TXT_DONE"),0)
 IF (_screen.oGlobal.opaRam.pa_keyifc .OR. _screen.oGlobal.opaRam.pa_posifc .OR. _screen.oGlobal.opaRam.pa_pttifc .OR.  ;
    _screen.oGlobal.opaRam.pa_ptvifc .OR. _screen.oGlobal.oParam2.pa_intifc)
      p_oAudit.txTinfo(GetLangText("AUDIT","TXT_INTERFACE"),1)
      DO ifCasciiaudit IN Interfac
 ENDIF
 ***
 DO ClearAllMessages IN procmessages
 p_oAudit.txTinfo(GetLangText("AUDIT","TXT_OUTDEBTS"),1)
 procbill("CalcOutDebts")
 p_oAudit.Progress()
 IF g_lAutomationMode
      _screen.oGlobal.lflushforce = l_lOldFlushForce
      IF PEMSTATUS(p_oAudit,"deleteremotelog",5)
           p_oAudit.deleteremotelog()
      ENDIF
 ENDIF
 g_auditactive = .F.
 * Here end block
RETURN .T.
ENDPROC
*
FUNCTION PostAll
 PRIVATE noLdarea
 PRIVATE noLdorder
 PRIVATE noLdrecord
 LOCAL l_dSysDate
 l_dSysDate = sySdate()
 p_oAudit.txTinfo(GetLangText("AUDIT","TXT_POSTALL"),1)
 p_oAudit.txTinfo("",1)
 noLdarea = SELECT()
 noLdorder = ORDER("reservat")
 noLdrecord = RECNO("reservat")
 SELECT reServat
 SET ORDER IN "Reservat" TO 6
 = SEEK("1", "Reservat")
 SCAN FOR EMPTY(reServat.rs_out) .AND. reServat.rs_depdate>l_dSysDate  ;
      WHILE  .NOT. EMPTY(reServat.rs_in)
      p_oAudit.txTinfo(reServat.rs_lname,0)
      IF (paRam.pa_keyifc .OR. paRam.pa_posifc .OR. paRam.pa_pttifc .OR.  ;
         paRam.pa_ptvifc)
           DO ifCasciipost IN Interfac WITH reServat.rs_reserid,  ;
              reServat.rs_roomnum
      ENDIF
      DO raTecodepost IN RatePost WITH (l_dSysDate), ""
      FLUSH
 ENDSCAN
 SET ORDER IN "Reservat" TO nOldOrder
 GOTO noLdrecord IN "Reservat"
 SELECT (noLdarea)
 p_oAudit.txTinfo(GetLangText("AUDIT","TXT_DONE"),0)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION PostAllRooms
 PRIVATE noLdarea
 PRIVATE noLdorder
 PRIVATE noLdrecord
 LOCAL l_dSysDate
 l_dSysDate = sySdate()
 IF (paRam.pa_keyifc .OR. paRam.pa_posifc .OR. paRam.pa_pttifc .OR.  ;
    paRam.pa_ptvifc)
      noLdarea = SELECT()
      noLdorder = ORDER("reservat")
      noLdrecord = RECNO("reservat")
      SELECT reServat
      SET ORDER IN "Reservat" TO 6
      = SEEK("1", "Reservat")
      SCAN FOR EMPTY(reServat.rs_out) .AND. reServat.rs_depdate>= ;
           l_dSysDate WHILE  .NOT. EMPTY(reServat.rs_in)
           DO ifCasciipost IN Interfac WITH reServat.rs_reserid,  ;
              reServat.rs_roomnum
           FLUSH
      ENDSCAN
      SET ORDER IN "Reservat" TO nOldOrder
      GOTO noLdrecord IN "Reservat"
      SELECT (noLdarea)
      WAIT CLEAR
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION HistPost
 PRIVATE noLdarea, noLdorder
 LOCAL l_cOrderHistpost, l_dSysDate, l_lClosePostchng, l_lCloseRpostifc, lcReplaceClause, l_lArchived
 l_dSysDate = sysdate()
 noLdarea = SELECT()
 noLdorder = ORDER("Post")
 SET ORDER IN "Post" TO 0
 l_cOrderHistpost = ORDER("histpost")
 SET ORDER TO "" IN histpost
 p_oAudit.txTinfo(GetLangText("AUDIT","TA_ADDTOPOSTHIST"),1)
 p_oAudit.txTinfo("",1)
 lcReplaceClause = GetReplaceClauseForSimilarFields("post", "histpost", .T.)
 FNNextIdTempWriteRealId("post", "ps_postid", "POST", .T.)
 SELECT poSt
 SCAN ALL FOR poSt.ps_date=l_dSysDate .OR. poSt.ps_touched
      IF EMPTY(poSt.ps_postid)
           IF poSt.ps_date=l_dSysDate
                = daPpend('HistPost')
           ELSE
                LOOP
           ENDIF
      ELSE
           IF  .NOT. dlOcate('HistPost','hp_postid = '+sqLcnv(poSt.ps_postid))
                = daPpend('HistPost')
           ENDIF
      ENDIF
      p_oAudit.txTinfo(poSt.ps_reserid,0)
      REPLACE &lcReplaceClause IN histpost
      IF NOT (histpost.hp_currtxt == post.ps_currtxt) OR ;
                NOT (histpost.hp_note == post.ps_note) OR ;
                NOT (histpost.hp_ifc == post.ps_ifc)
           * Every change in folowing REPLACE command
           * causes change in FromHistToPost and FromPostToHist procedures in ProcReservat program.
           * Memo fields are replace only if there are changed.
           REPLACE hp_currtxt WITH post.ps_currtxt, ;
                   hp_note WITH post.ps_note, ;
                   hp_ifc WITH post.ps_ifc IN histpost
      ENDIF
      DO FromRpostifcToHist IN ProcReservat WITH post.ps_setid
      DO FromPostchangesToHist IN ProcReservat WITH post.ps_postid
      SELECT poSt
      IF NOT _screen.oGlobal.lArchive OR ProcArchive("ArchivePost", @l_lArchived, post.ps_postid) AND l_lArchived
           REPLACE poSt.ps_touched WITH .F.
      ENDIF
      FLUSH
 ENDSCAN
 p_oAudit.txTinfo(GetLangText("AUDIT","TXT_DONE"),0)
 IF NOT USED("postchng")
      openfiledirect(.F., "postchng")
      l_lClosePostchng = .T.
 ENDIF
 IF NOT USED("rpostifc")
      openfiledirect(.F., "rpostifc")
      l_lCloseRpostifc = .T.
 ENDIF
 SELECT poSt
 SCAN FOR (INLIST(poSt.ps_reserid, -2, -1, 0.100, 0.200, 0.300,  ;
        0.400, 0.500, 0.700) .AND. poSt.ps_date<l_dSysDate) .OR. (poSt.ps_supplem= ;
        'LEDGER ' .AND. poSt.ps_paynum>0 .AND. poSt.ps_origid=0 .AND.  ;
        poSt.ps_date<l_dSysDate) .OR. (poSt.ps_reserid>1 .AND.  ;
        NOT SEEK(poSt.ps_reserid,"reservat","TAG1") .AND. poSt.ps_date=l_dSysDate)
      IF NOT EMPTY(post.ps_setid)
           DELETE FOR rk_setid = post.ps_setid IN rpostifc
      ENDIF
      DELETE FOR ph_postid = post.ps_postid IN postchng
      DELETE
 ENDSCAN
 *SCAN FOR (ps_date<l_dSysDate) AND ;
 *         (INLIST(poSt.ps_reserid, -2, -1, 0.100, 0.200, 0.300, 0.400, 0.500) OR ;
 *         (poSt.ps_supplem='LEDGER ' AND poSt.ps_paynum>0 AND poSt.ps_origid=0))
 *     DO AaPost IN AaUpd WITH "histstat", ps_date
 **     DO OrPost IN OrUpd WITH "histors"
 *     SELECT post
 *     DELETE
 *ENDSCAN
 FLUSH
 IF l_lClosePostchng
      USE IN postchng
 ENDIF
 IF l_lCloseRpostifc
      USE IN rpostifc
 ENDIF
 DO PRHistresUpdateSumRecords IN procreservat WITH l_dSysDate

 SET ORDER IN "Post" TO nOldOrder
 SET ORDER TO l_cOrderHistpost IN histpost
 SELECT (noLdarea)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION HistReservat
 PRIVATE noLdarea
 PRIVATE noLdorder
 PRIVATE lhAsbalance
 LOCAL LCloseRateperi, l_Retval, LDateToChange, lnGroupid, LRecNo, l_nShareid, l_nReserid, l_lClosePostchng, l_lCloseRpostifc, l_lSendToHistory
 LOCAL l_lChanged, l_oReservat, l_nPrice, l_cForClause, l_lFound, l_nRecno, l_oCheckRes, l_nRsId, l_lHasPost, l_lHasBill, l_dSysDate, l_lArchived
 STORE "" TO l_Retval
 l_dSysDate = sySdate()
 LRecNo = 0
 lnGroupid = 0
 l_oCheckRes = CREATEOBJECT("checkreservat")
 noLdarea = SELECT()
 noLdorder = ORDER("Reservat")
 p_oAudit.txTinfo(GetLangText("AUDIT","TA_ADDTORESERVATHIST"),1)
 p_oAudit.txTinfo("",1)
 doPen('Deposit')
 IF NOT USED("postchng")
      openfiledirect(.F., "postchng")
      l_lClosePostchng = .T.
 ENDIF
 IF NOT USED("rpostifc")
      openfiledirect(.F., "rpostifc")
      l_lCloseRpostifc = .T.
 ENDIF
 IF NOT USED("billnum")
      openfile(.F.,"billnum")
 ENDIF
 IF NOT USED("company")
    = openfiledirect(.F.,"address","company")
 ENDIF
 IF NOT USED("agent")
    = openfiledirect(.F.,"address","agent")
 ENDIF
  = relations() && Prevent wrong values in hr_country!!!
 SELECT reServat
 SET ORDER IN "Reservat" TO
 SCAN
      p_oAudit.txTinfo(reServat.rs_lname,0)
      *p_oAudit.progress(RECNO())
      lhAsbalance = (Balance(reservat.rs_reserid)<>0.00)
      l_lHasPost = SEEK(reservat.rs_reserid, "post", "tag1")
      l_lHasBill = SEEK(reservat.rs_reserid, "billnum", "tag2")
      l_lSendToHistory = (reServat.rs_arrdate <= l_dSysDate OR lhAsbalance OR l_lHasBill OR l_lHasPost)
      PAAddressDeleteMarkOnAudit()
      IF l_lSendToHistory
           SELECT hiStres
           DO FromResToHist IN ProcReservat WITH reservat.rs_reserid
           REPLACE hr_country WITH address.ad_country IN histres
           FLUSH
           IF ProcArchive("ArchiveReservation", @l_lArchived, reservat.rs_reserid, reservat.rs_rsid)
                REPLACE rs_doarch WITH NOT l_lArchived IN reServat
           ENDIF
           SELECT reServat
           IF reServat.rs_depdate<=l_dSysDate-paRam.pa_holdres AND NOT lhAsbalance AND dpRescrd(reServat.rs_reserid)=0
                IF NOT (_screen.oGlobal.lArchive AND reServat.rs_doarch)
                     SELECT poSt
                     *************************************************
                     *DELETE ALL FOR ps_reserid=reservat.rs_reserid
                     LOCAL l_order, l_lGoToHistory, l_nResRoomsRecno
                     l_order = ORDER()
                     SET ORDER TO
                     SCAN FOR ps_reserid=reservat.rs_reserid
                          IF NOT param.pa_statoff
                               DO AaPost IN AaUpd WITH "histstat", ps_date
                               DO OrPost IN OrUpd WITH "histors"
                          ENDIF
                          IF NOT EMPTY(post.ps_setid)
                               DELETE FOR rk_setid = post.ps_setid IN rpostifc
                          ENDIF
                          DELETE FOR ph_postid = post.ps_postid IN postchng
                          SELECT post
                          DELETE
                     ENDSCAN
                     IF .NOT. EMPTY(l_order)
                         SET ORDER TO l_order
                     ENDIF
                    *************************************************
                     FLUSH
                     DO FromBillinstToHist IN ProcReservat WITH reservat.rs_reserid
                     DO FromBanquetToHist IN ProcReservat WITH reservat.rs_reserid
                     DO FromSheetToHist IN ProcReservat WITH reservat.rs_reserid
                     DO FromResfixToHist IN ProcReservat WITH reservat.rs_reserid
                     DO FromDepositToHist IN ProcReservat WITH reservat.rs_reserid
                     DO FromResrateToHist IN ProcReservat WITH reservat.rs_reserid
                     DO FromRessplitToHist IN ProcReservat WITH reservat.rs_rsid
                     DO FromResrartToHist IN ProcReservat WITH reservat.rs_rsid
                     FLUSH
                     SELECT reservat
                     *************************************************
                     IF param.pa_statoff
                          REPLACE rs_statoff WITH .T. ALL FOR rs_reserid = reservat.rs_reserid IN hresext
                     ELSE
                          DO AaReservat IN AaUpd WITH "histstat", rs_arrdate
                          DO OrReservat IN OrUpd WITH "histors"
                     ENDIF
                     SELECT reservat
                     l_cChanges = rsHistry(reServat.rs_changes,"DELETED", "AUTOMATIC during AUDIT - moved to history")
                     REPLACE reServat.rs_changes WITH l_cChanges
                     lnGroupid = reservat.rs_groupid
                     l_nReserid = reservat.rs_reserid
                     l_nRsId = reservat.rs_rsid
                     PRDeleteReservat("reservat")
                     SELECT reservat
                     IF SEEK(l_nRsId,"histres","tag15")
                          REPLACE hr_changes WITH l_cChanges IN histres
                     ENDIF
                     SELECT resrooms
                     SCAN FOR ri_reserid = l_nReserid
                          IF NOT EMPTY(resrooms.ri_shareid) AND SEEK(resrooms.ri_shareid,"sharing","tag1")
                               l_lGoToHistory = .T.
                               l_nResRoomsRecno = RECNO("resrooms")
                               SELECT resrmshr
                               SCAN FOR sr_shareid = resrooms.ri_shareid
                                    IF SEEK(resrmshr.sr_rroomid,"resrooms","tag3")
                                         l_lGoToHistory = .F.
                                         EXIT
                                    ENDIF
                               ENDSCAN
                               IF l_lGoToHistory
                                    REPLACE sd_history WITH .T. IN sharing
                                    = TABLEUPDATE(.F.,.T.,"sharing")
                               ENDIF
                               SELECT resrooms
                               GO l_nResRoomsRecno
                               DELETE
                          ENDIF
                     ENDSCAN
                     DO PlanSet IN AvlUpdat WITH l_nReserid
                     IF g_newversionactive AND !EMPTY(lnGroupid)
                          LRecNo = RECNO("reservat")
                          IF !SEEK(lnGroupid,'reservat','tag24')
                               DELETE FOR gr_groupid=lnGroupid IN groupres 
                          ENDIF
                          GO LRecNo IN reservat
                     ENDIF
                     * Here delete child records, when not deleted in "From" group functions in procreservat.prg
                     * Don't forget bills.onclose() for bills.cMode = "OUT_HIST"
                     sqldelete("resrooms", "ri_reserid = " + sqlcnv(l_nReserid,.T.))
                     sqldelete("resaddr", "rg_reserid = " + sqlcnv(l_nReserid,.T.))
                     sqldelete("rescard", "cr_rsid = " + sqlcnv(l_nRsId,.T.))
                ENDIF
           ELSE
                IF NOT param.pa_audnost
                     SELECT reservat
                     DO AaReservat IN AaUpd WITH "astat", rs_arrdate
                     DO OrReservat IN OrUpd WITH "orstat"
                ENDIF

                NASetRoomStatus()

                * Change values in reservat.dbf on settings in resrate.dbf for tomorrow
                IF NOT EMPTY(reservat.rs_in) AND EMPTY(reservat.rs_out) AND reservat.rs_depdate > param.pa_sysdate &&Include only Checked IN Reservations
                     SELECT reservat
                     SCATTER NAME l_oReservat
                     LDateToChange = param.pa_sysdate+1
                     l_lChanged = .F.
                     IF NOT _screen.oGlobal.lUgos && In ugos mode room change must occur on dermined date. This would be done in exkisimport.fxp
                          * change room
                          IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(LDateToChange),"resrooms","tag2")
                               IF (reservat.rs_roomtyp <> resrooms.ri_roomtyp) OR (reservat.rs_roomnum <> resrooms.ri_roomnum)
                                    l_oReservat.rs_roomtyp = resrooms.ri_roomtyp
                                    l_oReservat.rs_roomnum = resrooms.ri_roomnum
                                    l_lChanged = .T.
                               ENDIF
                          ENDIF
                     ENDIF
                     * change price
                     LDateToChange = MIN(param.pa_sysdate+1,reservat.rs_depdate)
                     IF SEEK(STR(reservat.rs_reserid,12,3)+DTOS(LDateToChange),"resrate","tag2") AND NOT EMPTY(resrate.rr_ratecod)
                          l_cRatecod = LEFT(resrate.rr_ratecod,10)
                          IF INLIST(resrate.rr_status, "OUS", "ORU", "OFF")
                               l_cRatecod = "*" + l_cRatecod
                          ELSE
                               IF INLIST(resrate.rr_status, "OAL", "ORA")
                                    l_cRatecod = "!" + l_cRatecod
                               ENDIF
                          ENDIF
                          l_nPrice = ProcResRate("RrDayPrice", l_oReservat, LDateToChange, l_oReservat.rs_rate)
                          IF (reservat.rs_ratecod <> l_cRatecod) OR (reservat.rs_rate <> l_nPrice) OR ;
                                  (reservat.rs_adults <> resrate.rr_adults) OR ;
                                  (reservat.rs_childs <> resrate.rr_childs) OR ;
                                  (reservat.rs_childs2 <> resrate.rr_childs2) OR ;
                                  (reservat.rs_childs3 <> resrate.rr_childs3) OR ;
                                  (reservat.rs_arrtime <> resrate.rr_arrtime) OR ;
                                  (reservat.rs_deptime <> resrate.rr_deptime)
                               l_oReservat.rs_adults = resrate.rr_adults
                               l_oReservat.rs_childs = resrate.rr_childs
                               l_oReservat.rs_childs2 = resrate.rr_childs2
                               l_oReservat.rs_childs3 = resrate.rr_childs3
                               l_oReservat.rs_arrtime = resrate.rr_arrtime
                               l_oReservat.rs_deptime = resrate.rr_deptime
                               l_oReservat.rs_ratecod = l_cRatecod
                               l_oReservat.rs_rate = l_nPrice
                               l_lChanged = .T.
                          ENDIF
                     ENDIF
                     * change guest
                     IF param2.pa_noaddr
                          IF PAResAddrChangeGuest(l_oCheckRes, l_oReservat, param.pa_sysdate+1)
                               l_lChanged = .T.
                          ENDIF
                     ENDIF
                     IF l_lChanged
                          DO CheckAndSave IN ProcReservat WITH l_oReservat, .F., .F., "RELOCATE"
                     ENDIF
                ENDIF
           ENDIF
      ENDIF
      SELECT reServat
      FLUSH
 ENDSCAN
 IF ProcArchive("ArchiveBillnum", @l_lArchived)
      p_oAudit.txTinfo(GetLangText("AUDIT","TA_ARCHIVEBILLNUM"),1)
      p_oAudit.txTinfo("",1)
      _screen.oGlobal.oArchive.Disconnect()
 ENDIF
 IF l_lClosePostchng
      USE IN postchng
 ENDIF
 IF l_lCloseRpostifc
      USE IN rpostifc
 ENDIF
 p_oAudit.txTinfo(GetLangText("AUDIT","TXT_DONE"),0)
 WAIT CLEAR
 dcLose('Deposit')
 SET ORDER IN "Reservat" TO nOldOrder
 l_oCheckRes.Release()
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION CashClos
 PRIVATE nnOtclosed
 PRIVATE ldOntabort
 PRIVATE ncAshrecord
 LOCAL l_lContinue, l_dSysDate
 l_dSysDate = sySdate()
 nnOtclosed = 0
 GOTO TOP IN caShier
 DO WHILE ( .NOT. EOF("Cashier"))
      IF (caShier.ca_isopen)
           nnOtclosed = nnOtclosed+1
      ENDIF
      SKIP 1 IN caShier
 ENDDO
 IF (nnOtclosed>0)
      l_lContinue = .T.
      IF NOT _screen.oGlobal.lDoAuditOnStartup
           l_lContinue = yeSno(GetLangText("AUDIT","TXT_CASHIERSOPEN")+"?",GetLangText("AUDIT", "TXT_OPENCASH"))
      ENDIF
      IF l_lContinue
           GOTO TOP IN caShier
           DO WHILE ( .NOT. EOF("Cashier"))
                ncAshrecord = RECNO()
                p_oAudit.txTinfo(GetLangText("AUDIT","TXT_CLOSED")+" "+ LTRIM(STR(ClOsCash(caShier.ca_number))),1)
                SELECT caShier
                GOTO ncAshrecord
                IF NOT param.pa_noclose
                     IF cashier.ca_isopen
                          REPLACE ca_isopen WITH .F. ;
                                  ca_clodate WITH l_dSysDate ;
                                  ca_clotime WITH TIME() IN cashier
                     ENDIF
                     REPLACE ca_opcount WITH 0 IN cashier
                ENDIF
                SKIP 1 IN caShier
           ENDDO
           ldOntabort = .T.
      ELSE
           ldOntabort = .F.
      ENDIF
 ELSE
      ldOntabort = .T.
 ENDIF
 RETURN ldOntabort
ENDFUNC
*
FUNCTION Arrivals
 PRIVATE ldOntabort
 PRIVATE nrEsorder
 PRIVATE nrEsrecno
 PRIVATE nsElect
 PRIVATE lfIrst
 LOCAL l_oReser, l_dSysDate
 nsElect = SELECT()
 l_dSysDate = sySdate()
 ldOntabort = .T.
 lfIrst = .T.
 SELECT reServat
 nrEsrecno = RECNO()
 nrEsorder = ORDER()
 SET ORDER TO tag8
 IF (SEEK(DTOS(l_dSysDate), "Reservat"))
      DO WHILE ( .NOT. EOF("Reservat") .AND. reServat.rs_arrdate==l_dSysDate)
           IF (EMPTY(reServat.rs_in) .AND.  .NOT.  ;
              INLIST(reServat.rs_status, "CXL", "NS", "OUT"))
                IF NOT _screen.oGlobal.lDoAuditOnStartup
                     IF (lfIrst)
                          IF ( .NOT. yeSno(GetLangText("AUDIT","TXT_ARRIVALS"), ;
                             GetLangText("AUDIT","TXT_NOTIN")))
                               ldOntabort = .F.
                               EXIT
                          ELSE
                               =loGdata([Answered with YES on question: ] + GetLangText("AUDIT","TXT_ARRIVALS"),caUditlogfile)
                          ENDIF
                     ENDIF
                ENDIF
                p_oAudit.txTinfo(GetLangText("AUDIT","TXT_NOSHOW")+" "+ ;
                  ALLTRIM(reServat.rs_lname),1)
                SELECT reservat
                SCATTER NAME l_oReser MEMO
                l_oReser.rs_cxlstat = l_oReser.rs_status
                l_oReser.rs_status = "NS"
                l_oReser.rs_updated = l_dSysDate
                l_oReser.rs_cxldate = l_dSysDate
                DO CheckAndSave IN ProcReservat WITH l_oReser, .F., .F., "NOSHOW"
                lfIrst = .F.
           ENDIF
           SKIP 1 IN reServat
           FLUSH
      ENDDO
 ENDIF
 SELECT reServat
 SET ORDER TO nResOrder
 GOTO nrEsrecno
 SELECT (nsElect)
 RETURN ldOntabort
ENDFUNC
*
FUNCTION Departures
 PRIVATE ldOntabort
 PRIVATE nrEsorder
 PRIVATE nrEsrecno
 PRIVATE nsElect
 PRIVATE lfIrst
 LOCAL l_dSysDate, l_cDepDateChange
 nsElect = SELECT()
 l_dSysDate = sySdate()
 ldOntabort = .T.
 lfIrst = .T.
 SELECT reServat
 nrEsrecno = RECNO()
 nrEsorder = ORDER()
 SET ORDER TO tag9
 IF (SEEK(DTOS(l_dSysDate), "Reservat"))
      DO WHILE ( .NOT. EOF("Reservat") .AND. reServat.rs_depdate==l_dSysDate)
           IF (EMPTY(reServat.rs_out) .AND. reServat.rs_status="IN")
                IF NOT _screen.oGlobal.lDoAuditOnStartup
                     IF (lfIrst)
                          IF ( .NOT. yeSno(GetLangText("AUDIT","TXT_DEPARTURES"), ;
                             GetLangText("AUDIT","TXT_NOTOUT")))
                               ldOntabort = .F.
                               EXIT
                          ENDIF
                     ENDIF
                ENDIF
                p_oAudit.txTinfo(GetLangText("AUDIT","TXT_NOCHECKOUT")+" "+ ;
                  ALLTRIM(reServat.rs_lname),1)
                LOCAL l_nMode, l_oReser, l_oNewRes
                SCATTER NAME l_oReser
                l_cDepDateChange = "LATE DEPARTURE " + DTOC(reServat.rs_depdate+1) + "..." + DTOC(reServat.rs_depdate)
                REPLACE reServat.rs_depdate WITH reServat.rs_depdate+1
                REPLACE reServat.rs_updated WITH l_dSysDate
                REPLACE reServat.rs_changes WITH  ;
                        rsHistry(reServat.rs_changes,l_cDepDateChange, ;
                        "AUTOMATIC during AUDIT")
                lfIrst = .F.
                DO RiCheck IN ProcResrooms WITH reservat.rs_reserid, reservat.rs_arrdate, reservat.rs_depdate, ;
                    reservat.rs_roomtyp, reservat.rs_roomnum
                DO CheckRoomNum IN ProcReservat WITH l_nMode, "reservat"
                IF l_nMode > 0
                    DO ChangeShare IN ProcReservat WITH l_nMode, "reservat"
                    DELETE FOR sd_nomembr = 0 IN sharing
                    = TABLEUPDATE(.T.,.T.,"sharing")
                    = TABLEUPDATE(.T.,.T.,"resrmshr")
                ENDIF
                SELECT reservat
                SCATTER NAME l_oNewRes MEMO
                DO RrUpdate IN ProcResRate WITH l_oReser, l_oNewRes, .F., l_dSysDate, l_dSysDate
                SEEK DTOS(l_dSysDate)
           ELSE
                SKIP 1 IN reServat
           ENDIF
      ENDDO
 ENDIF
 SELECT reServat
 SET ORDER TO nResOrder
 GOTO nrEsrecno
 SELECT (nsElect)
 RETURN ldOntabort
ENDFUNC
*
FUNCTION DeletePasserBy
 LOCAL l_order
 SELECT post
 l_order = ORDER()
 SET ORDER TO
 SCAN FOR ps_reserid==0.100
      DO AaPost IN AaUpd WITH "histstat", ps_date
      DO OrPost IN OrUpd WITH "histors"
      SELECT post
      DELETE
 ENDSCAN
 IF .NOT. EMPTY(l_order)
    SET ORDER TO l_order
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION UpdLedger
 PRIVATE naDdrid
 PRIVATE naDord
 PRIVATE caUditlogfile
 PRIVATE noLdarea
 PRIVATE noLdrec
 PRIVATE npMrecord
 PRIVATE npSord
 PRIVATE nrSord
 PRIVATE ctExt
 PRIVATE leXtendedar
 LOCAL l_dSysdate, l_lSomethingDeleted, l_nDpReceipt, l_lDepositPost
 l_dSysdate = sySdate()
 leXtendedar = _SCREEN.DV
 IF leXtendedar
      = doPen('ArAcct')
      = doPen('ArPost')
 ENDIF
 IF (opEnfile(.F.,"LedgPost") .AND. opEnfile(.F.,"LedgPaym"))
      caUditlogfile = "Audit.Log"
      noLdarea = SELECT()
      noLdrec = RECNO()
      p_oAudit.txTinfo("Updating Ledgers & CreditCards",1)
      SELECT adDress
      naDord = ORDER()
      SET ORDER TO 1
      SELECT reServat
      nrSord = ORDER()
      SET ORDER TO 1
      SELECT poSt
      npSord = ORDER()
      SET ORDER TO 0
      SCAN FOR ps_reserid>0 AND ps_date=l_dSysdate ;
              AND ps_paynum<>0 AND NOT ps_cancel
          IF SEEK(post.ps_paynum,"paymetho","tag1") AND INLIST(paymetho.pm_paytyp, 3, 4) AND ;
                    NOT SEEK(post.ps_postid,"ledgpost","tag7") && Insert in only once
                nAddrId = post.ps_addrid
                DO CASE
                     CASE post.ps_reserid = 0.100
                          M.ld_billnum = SUBSTR(PADR(poSt.ps_ifc, 10), 1, 10)
                     CASE post.ps_window = 0
                          M.ld_billnum = poSt.ps_billnum
                     CASE SEEK(poSt.ps_reserid, "Reservat")
                          DO BillAddrId IN ProcBill WITH post.ps_window, reservat.rs_rsid, IIF(EMPTY(reservat.rs_addrid),reservat.rs_compid,reservat.rs_addrid), nAddrId
                          M.ld_billnum = FNGetBillData(reservat.rs_reserid, poSt.ps_window, "bn_billnum")
                     CASE SEEK(poSt.ps_reserid, "Histres")
                          DO BillAddrId IN ProcBill WITH post.ps_window, histres.hr_rsid, IIF(EMPTY(histres.hr_addrid),histres.hr_compid,histres.hr_addrid), nAddrId
                          M.ld_billnum = FNGetBillData(histres.hr_reserid, poSt.ps_window, "bn_billnum")
                     OTHERWISE
                          ctExt = "LEDGERS: Reservation ID not found: "+ STR(poSt.ps_reserid, 12, 3) + STR(RECNO("Post")) + "!"
                          = loGdata(ctExt,caUditlogfile)
                          IF (param.pa_debug)
                               WAIT WINDOW ctExt
                          ENDIF
                ENDCASE
                * Copy deposit bill number into ld_billnum
                l_lDepositPost = dlocate("deposit", "dp_postid = " + sqlcnv(post.ps_postid))
                IF l_lDepositPost
                     l_nDpReceipt = dlookup("deposit","dp_lineid = " + sqlcnv(deposit.dp_headid),"dp_receipt")
                     IF NOT EMPTY(l_nDpReceipt)
                          M.ld_billnum = TRANSFORM(l_nDpReceipt)
                     ENDIF
                ENDIF
                M.ld_addrid = naDdrid
                M.ld_postid = poSt.ps_postid
                M.ld_reserid = poSt.ps_reserid
                M.ld_origid = poSt.ps_origid
                M.ld_paynum = poSt.ps_paynum
                M.ld_billamt = -poSt.ps_amount
                M.ld_billdat = poSt.ps_date
                M.ld_company = ""
                M.ld_lname = ""
                IF M.ld_addrid = 0
                     * When record came from Argus. On Argus is paymethod defined as Paytyp "Standard", 
                     * but connected to Paymethod from typ Ledger in Brilliant.
                ELSE
                     IF SEEK(M.ld_addrid, "Address")
                          M.ld_company = UPPER(adDress.ad_company)
                          M.ld_lname = UPPER(adDress.ad_lname)
                     ELSE
                          ctExt = "LEDGERS: Address ID not found!"
                          = loGdata(ctExt,caUditlogfile)
                          IF (param.pa_debug)
                               WAIT WINDOW ctExt
                          ENDIF
                     ENDIF
                ENDIF
                M.ld_ldid = nextid("LEDGPOST")
                sqlinsert("ledgpost",,4)
                FLUSH
                IF leXtendedar AND NOT post.ps_tano
                     M.ap_billnr = M.ld_billnum
                     M.ap_paynum = poSt.ps_paynum
                     M.ap_debit = -poSt.ps_amount
                     M.ap_credit = 0.00
                     M.ap_date = poSt.ps_date
                     M.ap_sysdate = poSt.ps_date
                     M.ap_reserid = poSt.ps_reserid
                     IF paYmetho.pm_paytyp=4
                          M.ap_aracct = dlOokup('ArAcct','ac_addrid = '+ ;
                                        sqLcnv(naDdrid) + ' AND NOT ac_inactiv AND NOT ac_credito','ac_aracct')
                     ELSE
                          M.ap_aracct = paYmetho.pm_aracct
                     ENDIF
                     DO CASE
                          CASE poSt.ps_reserid=0.100
                               M.ap_ref = LTRIM(poSt.ps_supplem)
                          CASE l_lDepositPost
                               * deposit
                               M.ap_ref = "DEP: " + ALLTRIM(reServat.rs_lname) + " " + ALLTRIM(poSt.ps_supplem)
                          OTHERWISE
                               M.ap_ref = reServat.rs_lname
                     ENDCASE
                     M.ap_duedat = araccount("ArGetDueDate",M.ap_aracct,M.ap_sysdate, {})
                     M.ap_postid = poSt.ps_postid
                     M.ap_userid = poSt.ps_userid
                     IF dlOcate('ArPost','ap_postid = '+sqLcnv(M.ap_postid))
                          SELECT arPost
                          GATHER MEMVAR
                          SELECT poSt
                     ELSE
                          M.ap_lineid = neXtid('ARPOST')
                          M.ap_headid = M.ap_lineid
                          INSERT INTO ArPost FROM MEMVAR
                     ENDIF
                     FLUSH
                ENDIF
          ENDIF && INLIST(ps_paynum, 3, 4) AND SEEK(post.ps_paynum,"paymetho","tag1")
      ENDSCAN
      IF (paRam.pa_delledg>0)
           l_lSomethingDeleted = .F.
           SELECT ledgpaym
           SET ORDER TO
           SELECT leDgpost
           SCAN ALL FOR ROUND(leDgpost.ld_billamt-leDgpost.ld_paidamt, 2)= ;
                0.00 .AND. l_dSysdate-leDgpost.ld_paiddat>paRam.pa_delledg
                IF procvoucher("DebitorForVoucherDeleteAllowed",leDgpost.ld_billnum)
                     IF NOT l_lSomethingDeleted
                          l_lSomethingDeleted = .T.
                     ENDIF
                     DELETE FROM ledgpaym WHERE lp_reserid = ledgpost.ld_reserid AND lp_billnum = ledgpost.ld_billnum

     *!*                     SELECT leDgpaym
     *!*                     SET ORDER TO 1
     *!*                     IF (SEEK(leDgpost.ld_billnum, 'LedgPaym'))
     *!*                          DELETE REST FOR leDgpaym.lp_reserid= ;
     *!*                                 leDgpost.ld_reserid WHILE leDgpaym.lp_billnum== ;
     *!*                                 leDgpost.ld_billnum
     *!*                     ENDIF

                     SELECT leDgpost
                     DELETE
                ELSE
                     IF NOT leDgpost.ld_vblock
                          REPLACE ld_vblock WITH .T. IN leDgpost
                     ENDIF
                ENDIF
           ENDSCAN
           IF l_lSomethingDeleted
                * To prevent "Internal consistency error" do reindex
                FLUSH FORCE
                dclose("ledgpaym")
                IF openfiledirect(.T.,"ledgpaym")
                     SELECT ledgpaym
                     DELETE TAG ALL
                     dclose("ledgpaym")
                     openfile(.F.,"ledgpaym")
                ENDIF
           ENDIF
      ENDIF
      SELECT poSt
      SET ORDER TO nPsOrd
      SELECT reServat
      SET ORDER TO nRsOrd
      SELECT adDress
      SET ORDER TO nAdOrd
      SELECT (noLdarea)
      GOTO noLdrec
      = clOsefile("LedgPost")
      = clOsefile("LedgPaym")
 ENDIF
 IF leXtendedar
      = dcLose('ArAcct')
      = dcLose('ArPost')
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION MovePhoneBooth
 IF (opEnfile(.F.,"IfcLost"))
      p_oAudit.txTinfo(GetLangText("AUDIT","TXT_POSTPHONEBOOTH"),1)
      p_oAudit.txTinfo("",1)
      LOCAL l_nExtens
      SELECT poSt
      SCAN FOR ps_reserid <= -10
                SCATTER MEMO MEMVAR
                DO BoothNum IN Booth WITH M.ps_reserid, l_nExtens
                M.ps_phone = LTRIM(STR(l_nExtens))
                M.ps_room = M.ps_phone
                INSERT INTO IfcLost FROM MEMVAR
                SELECT poSt
                DELETE
      ENDSCAN
 ENDIF
 = clOsefile("IfcLost")
 RETURN .T.
ENDFUNC
*
FUNCTION AuditAllowed
 PRIVATE ldO
 IF (paRam.pa_lastint<1)
      ldO = .T.
 ELSE
      ldO = (hoUrs(paRam.pa_lasttim,TIME(),paRam.pa_lastaud,DATE())> ;
            paRam.pa_lastint)
 ENDIF
 RETURN ldO
ENDFUNC
*
PROCEDURE TryRebuildDatabase
* Use citadelsrv to do audit main part, if available.
* When not available, do it from here
LOCAL l_lSuccess, l_lResultSqlR, l_nSelect, l_nSecToWait, l_cIniFile, l_lDoRemoteAudit, l_cWinPc, l_cServerPc, ;
          l_oDatabaseProp

l_nSelect = SELECT()

l_cIniFile = FULLPATH(INI_FILE)
IF FILE(l_cIniFile)
     l_lDoRemoteAudit = LOWER(readini(l_cIniFile, "audit","DoRemoteReindex", "no"))="yes"
     IF l_lDoRemoteAudit
          l_nSecToWait = INT(VAL(readini(l_cIniFile, "audit","DoRemoteReindexTimeout", "1200"))) && 20 minutes
     ENDIF
ENDIF 

IF l_lDoRemoteAudit
     l_oDatabaseProp = goDatabases.Item("DESK")
     l_cWinPc = LOWER(ALLTRIM(winpc()))
     l_cServerPc = LOWER(ALLTRIM(l_oDatabaseProp.cServerName))

     IF NOT EMPTY(l_cServerPc) AND NOT l_cWinPc == l_cServerPc && Dont use citadel server, when tables are lcoaly used (citadel.exe started an PC where dbf-s are)

          CloseAllFiles(.T., "[license]")
          p_oAudit.txTinfo(GetLangText("AUDIT","TXT_STARTING_REMOTE"),1)
          p_oAudit.txTinfo(GetLangText("PARAMS","TXT_DO_REINDEX_IN_AUDIT"),1)
          
          = loGdata(TRANSFORM(DATETIME())+"|Remote audit started|SERVER:"+l_cServerPc+"|TIMEOUT(seconds):"+TRANSFORM(l_nSecToWait), caUditlogfile)
          p_oAudit.oimgprogressbar.Visible = .T.
          p_oAudit.RemoteLogStart()

          l_lResultSqlR = sqlremote("REINDEX",,,l_oDatabaseProp.cApplication,l_nSecToWait,@l_lSuccess, l_oDatabaseProp.cServerName, l_oDatabaseProp.nServerPort, l_oDatabaseProp.lEncrypt)

          p_oAudit.RemoteLogStop()
          p_oAudit.txTinfo(IIF(l_lSuccess,"OK.","FAILED!"),1)
          = loGdata(TRANSFORM(DATETIME())+"|Remote audit "+IIF(l_lSuccess,"OK.","FAILED!"), caUditlogfile)
          p_oAudit.txTinfo(GetLangText("USER","TXT_OPENINGFILES"),1)
          openfile()
          relations()
          p_oAudit.oimgprogressbar.Visible = .F.
          WAIT CLEAR
          IF NOT l_lSuccess
               * Don't do reindex from local PC over network, when failed over TCP!
               l_lSuccess = .T.
          ENDIF
     ENDIF
ENDIF

IF NOT l_lSuccess
     p_oAudit.txTinfo(GetLangText("PARAMS","TXT_DO_REINDEX_IN_AUDIT"),1)
     RebuildDatabase()
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
FUNCTION RebuildDatabase
 LOCAL lpAck, lcOnsist, lnSelected
 PRIVATE  alGroup
 DIMENSION alGroup(11)

 IF TYPE("caUditlogfile")<>"C"
      PRIVATE caUditlogfile
      caUditlogfile = "Audit.Log"
 ENDIF
 
 IF g_lAutomationMode
      PRIVATE p_lRemoteAuditReindexing
      p_lRemoteAuditReindexing = .T. && Used in progress.scx
      openfile()
      relations()
      *openfiledirect(.T.,"param")
 ENDIF
 
 = loGdata("Started automatic Database reindexing",caUditlogfile)
 
 lnSelected = SELECT()
 
 FOR i = 1 TO 11
       alGroup(i) = .T.
 NEXT i
 lpAck = .t.
 lcOnsist = .t.
 = crEatinx(lpAck,0,lcOnsist, .T., .T.)
 DO reFreshuser IN Login
 IF (lcOnsist)
       DO plDefaults IN MgrPList
       lcOnsist = .F.
 ENDIF
 IF !SEEK(-9999,'apartner','tag3')
       INSERT INTO apartner (ap_apid) VALUES (-9999)
 ENDIF
 
 SELECT (lnSelected)
 
 = loGdata("Completed automatic Database reindexing",caUditlogfile)
 RETURN .T.
ENDFUNC
*
FUNCTION PrintBatches
      LOCAL lcBatch, lnSelected, lnRecNo, loForm

      loForm = CREATEOBJECT("form")
      loForm.addobject("lblText","label")
      loForm.autocenter = .T.
      loForm.TitleBar = 0
      loForm.height = 30
      loForm.width = 500
      loForm.lblText.width = loForm.width
      loForm.lblText.visible = .T.
      loForm.lblText.fontbold = .T.
      loForm.lblText.left = 5
      loForm.lblText.top = 5
      loForm.lblText.caption = GetLangText("AUDIT","TA_PRINTBATCHES")
      loForm.visible = .T.
      lcBatch = ALLTRIM(param.pa_audbat)

      lnSelected = SELECT()
      lnRecNo = RECNO()

      = openfile()
      = relations()
      SELECT lists
     GOTO TOP IN lists
     SCAN
           IF ((","+lcBatch +",")$(","+ALLTRIM(Lists.li_batch)+","))
                IF EMPTY(Lists.li_when) OR EVALUATE(Lists.li_when)
                      loForm.lblText.caption = GetLangText("AUDIT","TA_PRINTBATCHES") + " " + EVALUATE([Lists.li_lang]+g_Langnum)
                      DO prTreport IN mylists WITH .T.
                ENDIF
           ENDIF
      ENDSCAN
     = relations()
     RELEASE loForm
     SELECT (lnSelected)
     IF USED()
          GO lnRecNo
     ENDIF
ENDFUNC
*
FUNCTION SendBatches
     LOCAL lnSelected, lnRecNo, l_lExportAndSend, l_lSmtp

     lnSelected = SELECT()
     lnRecNo = RECNO()

     WAIT GetLangText("AUDIT","TA_SENDBATCHES") WINDOW NOWAIT

     IF DLocate("picklist", "pl_label+pl_charcod = " + SqlCnv("BATCH     "+param2.pa_audsbat))
          l_lExportAndSend = .T.
          l_lSmtp = .T.
          DO vbatch IN mylists WITH l_lExportAndSend, ALLTRIM(picklist.pl_memo), ALLTRIM(picklist.pl_charcod), l_lSmtp
     ENDIF

     SELECT (lnSelected)
     IF USED()
          GO lnRecNo
     ENDIF

     WAIT CLEAR
ENDFUNC
*
FUNCTION OpenZapFile
LPARAMETERS lp_cAlias, lp_lMessage
 IF USED(lp_cAlias)
	USE IN &lp_cAlias
 ENDIF
 IF OpenFile(.T.,lp_cAlias,.F.,.T.)
	ZAP IN &lp_cAlias
	RETURN .T.
 ELSE
	LOCAL l_lYesNo
	IF lp_lMessage AND NOT _screen.oGlobal.lDoAuditOnStartup
		l_lYesNo = YesNo(GetLangText("STATISTIC","TXT_ZAPFAIL_USEANYWAY"))
	ELSE
		l_lYesNo = .T.
	ENDIF
	IF l_lYesNo
		openfiledirect(.F., lp_cAlias)
		DELETE ALL IN &lp_cAlias
	ENDIF
	RETURN l_lYesNo
 ENDIF
ENDFUNC
*
FUNCTION StatOpenTables
 IF USED('astat')
	USE IN astat
 ENDIF
 IF NOT param.pa_audnost AND OpenZapFile('astat')
	SET ORDER TO tag2 IN astat
 ENDIF
 IF OpenFile(.F.,'histstat',.F.,.T.)
	SET ORDER TO tag2 IN histstat
 ENDIF
 = OpenFile(.F.,'laststay',.F.,.T.)
 IF NOT USED('rt')
     openfiledirect(.F., "roomtype", "rt")
 ENDIF
 IF USED('orstat')
	USE IN orstat
 ENDIF
 IF NOT param.pa_audnost AND OpenZapFile('orstat')
	SET ORDER TO tag1 IN orstat
 ENDIF
 IF OpenFile(.F.,'histors',.F.,.T.)
	SET ORDER TO tag1 IN histors
 ENDIF
 SELECT reservat
 SET RELATION TO rs_roomtyp INTO roomtype ADDITIVE
 SELECT post
 SET RELATION TO ps_artinum INTO article
ENDFUNC
*
FUNCTION StatCloseTables
 USE IN histstat
 USE IN laststay
 USE IN rt
 IF USED("astat")
	USE IN astat
 ENDIF
 IF USED("orstat")
	USE IN orstat
 ENDIF
 USE IN histors
 *SELECT reservat
 *SET RELATION TO
 *= Relations()
 SELECT post
 SET RELATION TO
ENDFUNC
*
FUNCTION Statistics
LPARAMETERS lp_nMode
 LOCAL l_cAlias, l_cOrder
 IF lp_nMode == 0
     l_cAlias = "post"
 ELSE
     l_cAlias = "reservat"
 ENDIF
 SELECT(l_cAlias)
 l_cOrder = ORDER()
 SET ORDER TO
 p_oAudit.TxtInfo("", 1)
 SCAN
 	 *p_oAudit.progress(RECNO())
     IF lp_nMode == 0
         =SEEK(ps_reserid, "reservat", "tag1")
	     DO AaPost IN AaUpd WITH "astat", ps_date
	     DO OrPost IN OrUpd WITH "orstat"
     ELSE
	     DO AaReservat IN AaUpd WITH "astat", rs_arrdate
	     DO OrReservat IN OrUpd WITH "orstat"
     ENDIF
     SELECT(l_cAlias)
 ENDSCAN
 IF NOT EMPTY(l_cOrder)
     SET ORDER TO l_cOrder
 ENDIF
ENDFUNC
*
PROCEDURE StatHist
 LOCAL l_nArea, l_cPercentage, l_nRecCount, l_cOrdHre, l_cOrdPst
 l_nArea = SELECT()
 SELECT histpost
 l_cOrdPst = ORDER()
 SELECT hresext
 l_nRecCount = RECCOUNT()
 l_cOrdHre = ORDER()
 SET ORDER TO
 SCAN FOR rs_statoff
      IF SEEK(hresext.rs_reserid, "histres", "tag1")
           SELECT histres
           DO AaHistRs IN AaUpd WITH "histstat", hr_arrdate
           DO OrHistRs IN OrUpd WITH "histors"
           SELECT histpost
           SCAN FOR hp_reserid = hresext.rs_reserid
                DO AaPost IN AaUpd WITH "histstat", hp_date
                DO OrPost IN OrUpd WITH "histors"
           ENDSCAN
           SELECT hresext
      ENDIF
      REPLACE rs_statoff WITH .F.
 ENDSCAN
 SET ORDER TO l_cOrdHre IN hresext
 SET ORDER TO l_cOrdPst IN histpost
 SELECT(l_nArea)
ENDPROC
*
* When param.pa_audnost is .T. statistics should be refreshed with folowing function
FUNCTION StatRefresh
 LOCAL l_lUsed, l_nCount
 PRIVATE p_oAudit
 LOCAL ARRAY aProcess(3)
 DO FORM "forms\audit" NAME p_oAudit WITH ChildTitle(GetLangText("AUDIT","TA_STATISTICS"))
 *IF USED('astat')
 *    USE IN astat
 *ENDIF
 l_lUsed = OpenZapFile('astat', .T.)
 IF l_lUsed
     SET ORDER TO tag2 IN astat
 ENDIF
 *IF USED('orstat')
 *    USE IN orstat
 *ENDIF
 l_lUsed = l_lUsed AND OpenZapFile('orstat', .T.)
 IF l_lUsed
     SET ORDER TO tag1 IN orstat
 ENDIF
 IF NOT USED('rt')
     openfiledirect(.F., "roomtype", "rt")
 ENDIF
 IF NOT USED('histstat')
     openfiledirect(.F., "histstat")
 ENDIF
 IF NOT USED('histors')
      openfiledirect(.F., "histors")
 ENDIF
 SELECT reservat
 SET RELATION TO rs_roomtyp INTO roomtype ADDITIVE
 SELECT post
 SET RELATION TO ps_artinum INTO article

 IF l_lUsed
	 SELECT hresext
	 COUNT ALL FOR rs_statoff TO l_nCount
	 aprocess(1) = RECCOUNT("reservat")
	 aprocess(2) = RECCOUNT("post")
	 aprocess(3) = l_nCount
 	 p_oAudit.scrollprogressinit(@aProcess,3)
	 p_oAudit.TxtInfo(GetLangText("AUDIT","TA_STATISTICS"), 1)
	 p_oAudit.TxtInfo("", 1)
	 p_oAudit.TxtInfo(GetLangText("STATISTIC","TXT_RESERVAT"), 1)
	 = Statistics(1)
	 p_oAudit.TxtInfo(GetLangText("STATISTIC","TXT_POST"), 1)
	 = Statistics(0)
	 p_oAudit.TxtInfo(GetLangText("STATISTIC","TXT_HISTORY"), 1)
	 = StatHist()
	 REPLACE pa_statdat WITH SysDate() IN param
 ENDIF

 IF USED('astat')
     USE IN astat
 ENDIF
 IF USED('orstat')
     USE IN orstat
 ENDIF
 USE IN rt
 IF USED('histstat')
     USE IN histstat
 ENDIF
 IF USED('histors')
     USE IN histors
 ENDIF
 SELECT reservat
 SET RELATION TO
 = Relations()
 SELECT post
 SET RELATION TO

p_oAudit.Release()
= ChildTitle("")
RETURN .T.
ENDFUNC
*
FUNCTION ExtreserDoneStatus
     IF NOT USED("extreser")
          openfiledirect(.F., "extreser")
     ENDIF
     UPDATE extreser ;
          SET er_done = .T. ;
          WHERE NOT er_done AND er_reserid>0
     dclose("extreser")
ENDFUNC
*
PROCEDURE NAuditBackup
IF _screen.oGlobal.lAutoBackup
     LOCAL l_lSuccess, l_cSrcFolder, l_lParamClosed
     = loGdata("Start backup on " + TRANSFORM(DATETIME()), caUditlogfile)
     p_oAudit.txTinfo("System " + GetLangText("AUDIT","TXT_BACKUP") + "...",1)
     l_cSrcFolder = FULLPATH(gcdatadir)
     * Must close license and param tables, while they are opened exclusive, and cannot be copied!
     IF USED("param") AND ISEXCLUSIVE("param")
          l_lParamClosed = .T.
          dclose("param")
     ENDIF

     *************************************************************************************************************
     *
     * Don't close license table, because it is used to block other processes (deskbox.exe etc.) to use database!
     *
     *************************************************************************************************************

     IF NOT DIRECTORY(_screen.oGlobal.cAutoBackupDestination)
          MKDIR (_screen.oGlobal.cAutoBackupDestination)
     ENDIF
     
     ************************************************************************************************************
     *
     * Don't copy LICENSE table!
     *
     ************************************************************************************************************

     l_lSuccess = ccopyandzip(l_cSrcFolder, _screen.oGlobal.cAutoBackupDestination, "desk-"+DTOS(sysdate())+".zip", "LICENSE.DBF")

     IF l_lSuccess
          CFDeleteOldestXFilesInFolder(_screen.oGlobal.cAutoBackupDestination, _screen.oGlobal.nNumberOfAutobackups)
          = loGdata("Backup finished on " + TRANSFORM(DATETIME()), caUditlogfile)
          p_oAudit.txTinfo(GetLangText("AUDIT","TXT_BACKUP") + "... OK",1)
     ELSE
          = loGdata("Backup failed!", caUditlogfile)
          p_oAudit.txTinfo(GetLangText("AUDIT","TXT_BACKUP") + "... " + GetLangText("COMMON","TXT_FAILED") ,1)
     ENDIF
     IF l_lParamClosed
          openfile(.T.,"param")
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE NADoMainFunctions
* Use citadelsrv to do audit main part, if available.
* When not available, do it from here
LOCAL l_lSuccess, l_lResultSqlR, l_nSelect, l_nSecToWait, l_cIniFile, l_lDoRemoteAudit, l_cWinPc, l_cServerPc, l_oDatabaseProp

l_nSelect = SELECT()

l_cIniFile = FULLPATH(INI_FILE)
IF FILE(l_cIniFile)
     l_lDoRemoteAudit = LOWER(readini(l_cIniFile, "audit","DoRemoteAudit", "no"))="yes"
     IF l_lDoRemoteAudit
          l_nSecToWait = INT(VAL(readini(l_cIniFile, "audit","DoRemoteTimeout", "1200"))) && 20 minutes
     ENDIF
ENDIF 

IF l_lDoRemoteAudit
     l_oDatabaseProp = goDatabases.Item("DESK")
     l_cWinPc = LOWER(ALLTRIM(winpc()))
     l_cServerPc = LOWER(ALLTRIM(l_oDatabaseProp.cServerName))

     IF NOT EMPTY(l_cServerPc) AND NOT l_cWinPc == l_cServerPc && Dont use citadel server, when tables are lcoaly used (citadel.exe started an PC where dbf-s are)

          CloseAllFiles(.T., "[license]")
          p_oAudit.txTinfo(GetLangText("AUDIT","TXT_STARTING_REMOTE"),1)
          = loGdata(TRANSFORM(DATETIME())+"|Remote audit started|SERVER:"+l_cServerPc+"|TIMEOUT(seconds):"+TRANSFORM(l_nSecToWait), caUditlogfile)
          p_oAudit.oimgprogressbar.Visible = .T.
          p_oAudit.RemoteLogStart()
          l_lResultSqlR = sqlremote("AUDIT",,,l_oDatabaseProp.cApplication,l_nSecToWait,@l_lSuccess, l_oDatabaseProp.cServerName, l_oDatabaseProp.nServerPort, l_oDatabaseProp.lEncrypt)
          p_oAudit.RemoteLogStop()
          IF l_lSuccess
               l_lSuccess = l_lResultSqlR
          ENDIF
          p_oAudit.txTinfo(IIF(l_lSuccess,"OK.","FAILED!"),1)
          = loGdata(TRANSFORM(DATETIME())+"|Remote audit "+IIF(l_lSuccess,"OK.","FAILED!"), caUditlogfile)
          p_oAudit.txTinfo(GetLangText("USER","TXT_OPENINGFILES"),1)
          openfile()
          relations()
          p_oAudit.oimgprogressbar.Visible = .F.
     ENDIF
ENDIF

IF NOT l_lSuccess
     NAMainFunctions()
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE NAWellnessAudit
LOCAL l_lSuccess, l_cWellnessDir, l_cWellnessRoot, l_nModeOld, l_cWellnessMacro, l_oWshShell, l_lBlockUsers, l_lExclParam, l_lExclLicense
LOCAL l_cIniFile, l_nSecToWait, l_dDateTime, l_cAuditCtrlFile, l_lAuditCtrlFileExists
LOCAL ARRAY l_aLines(1)

p_oAudit.oimgprogressbar.Visible = .T.

l_cIniFile = FULLPATH(INI_FILE)
IF FILE(l_cIniFile)
     l_nSecToWait = INT(VAL(ReadIni(l_cIniFile, "Audit", "DoWellnessAuditTimeout", "1200"))) && 20 minutes
ELSE
     l_nSecToWait = 1200
ENDIF 
l_cWellnessDir = ADDBS(ALLTRIM(param2.pa_wexedir))
l_cIniFile = l_cWellnessDir+"wellocal.ini"
IF FILE(l_cIniFile)
     l_cWellnessRoot = ReadIni(l_cIniFile, "System", "WellnessDir", "")
ENDIF
IF EMPTY(l_cWellnessRoot)
     p_oAudit.cWellnessLogFile = l_cWellnessDir + "audit_desk.log"
     l_cAuditCtrlFile = l_cWellnessDir + "audit.log"
     l_cWellnessMacro = l_cWellnessDir + 'wellness.exe "| | |AUTOMATIC| |WELLNESS_AUDIT|"'
ELSE
     p_oAudit.cWellnessLogFile = ADDBS(l_cWellnessRoot)+"audit_desk.log"
     l_cAuditCtrlFile = ADDBS(l_cWellnessRoot) + "audit.log"
     l_cWellnessMacro = l_cWellnessDir+'wellness.exe "|'+l_cWellnessRoot+'| |AUTOMATIC| |WELLNESS_AUDIT|"'
ENDIF

l_lBlockUsers = _screen.oGlobal.lBlockUsers
_screen.oGlobal.lBlockUsers = .F.
IF ISEXCLUSIVE("param")
     l_lExclParam = .T.
     OpenFileDirect(,"param")
ENDIF
IF ISEXCLUSIVE("license")
     l_lExclLicense = .T.
     OpenFileDirect(,"license")
ENDIF

l_nModeOld = p_oAudit.nMode
p_oAudit.nMode = 1
p_oAudit.RemoteLogStart()
l_oWshShell = CREATEOBJECT("WScript.Shell")
l_oWshShell.Run(l_cWellnessMacro,0)

Sleep(2000)
l_dDateTime = DATETIME()
l_nWAHandle = 0
l_lAuditCtrlFileExists = FILE(l_cAuditCtrlFile)
DO WHILE DATETIME()-l_dDateTime < l_nSecToWait AND l_nWAHandle < 1
     IF l_lAuditCtrlFileExists
          l_nWAHandle = FOPEN(l_cAuditCtrlFile)
          IF l_nWAHandle > 0
               FCLOSE(l_nWAHandle)
               EXIT
          ENDIF
     ELSE
          l_lAuditCtrlFileExists = FILE(l_cAuditCtrlFile)
     ENDIF
     Sleep(1)
     WAIT WINDOW "" TIMEOUT .001
     DOEVENTS
ENDDO

p_oAudit.RemoteLogStop()
p_oAudit.nMode = l_nModeOld

l_lSuccess = .T.
DO CASE
     CASE p_oAudit.lWellnessAuditSuccess
          l_cMessage = "Wellness audit OK."
     CASE l_nWAHandle > 0
          l_nLines = ALINES(l_aLines,FILETOSTR(p_oAudit.cWellnessLogFile))
          IF ALLTRIM(l_aLines(l_nLines)) <> "OK"
               l_cMessage = ""
               FOR i = 2 TO l_nLines
                    DO CASE
                         CASE LEFT(l_aLines(i),1) = "@" OR ALLTRIM(l_aLines(i)) = "ERROR"
                         CASE INLIST(LEFT(l_aLines(i),3), "IN:", "NS:")
                              l_cMessage = l_cMessage + IIF(EMPTY(l_cMessage), "", ";") + STRTRAN(LEFT(l_aLines(i),255),"|","          ")
                         OTHERWISE
                              l_cMessage = l_cMessage + IIF(EMPTY(l_cMessage), "", ";") + LEFT(l_aLines(i),255)
                    ENDCASE
               NEXT
               l_lSuccess = YesNo(l_cMessage + IIF(EMPTY(l_cMessage), "", ";;") + GetLangText("AUDIT","TXT_WELLNESS_AUDIT_NOTFINISHED") + ";" + GetLangText("AUDIT","TXT_WITHOUT_WELLNESS"))
          ENDIF
          l_cMessage = "Wellness audit FAILED!"
     OTHERWISE
          l_lSuccess = YesNo(GetLangText("AUDIT","TXT_WELLNESS_NOTRESPOND") + ";" + GetLangText("AUDIT","TXT_WITHOUT_WELLNESS"))
          l_cMessage = "Wellness audit is NOT RESPONDING!"
ENDCASE

p_oAudit.txTinfo(l_cMessage,1)
LogData(TRANSFORM(DATETIME())+"|"+l_cMessage, caUditlogfile)

Sleep(2000)
_screen.oGlobal.lblockusers = l_lBlockUsers
IF l_lExclParam
     OpenFileDirect(.T.,"param")
ENDIF
IF l_lExclLicense
     OpenFileDirect(.T.,"license")
ENDIF

p_oAudit.oimgprogressbar.Visible = .F.

RETURN l_lSuccess
ENDFUNC
*
PROCEDURE NArrsyncreser
LOCAL l_cSql, l_cCurName, l_nSelect, l_lOldFlushForce

p_oAudit.TxtInfo(GetLangText("INDEXING","TXT_RATECODE"), 0)
l_nSelect = SELECT()

IF NOT USED("reservat")
     = openfiledirect(,"reservat")
ENDIF
IF NOT USED("resrate")
     = openfiledirect(,"resrate")
ENDIF
IF NOT USED("ressplit")
     = openfiledirect(,"ressplit")
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT DISTINCT rs_rsid, rs_reserid 
     FROM reservat 
     WHERE DTOS(rs_depdate)+rs_roomnum >= <<sqlcnv(DTOS(sysdate()),.T.)>> AND rs_rcsync 
ENDTEXT

l_cCurName = sqlcursor(l_cSql)

IF USED(l_cCurName) AND RECCOUNT(l_cCurName)>0

     * Open resrateold and resroomsold aliases here, to prevent opening and closing in rrupdate function, ;
     * which causes slow down of NArrsyncreser function.
     openfiledirect(.F.,"resrate", "resrateold")
     openfiledirect(.F.,"resrooms", "resroomsold")
     l_lOldFlushForce = _screen.oGlobal.lflushforce
     _screen.oGlobal.lflushforce = .F. && Set to force for performance reasons

     SELECT (l_cCurName)
     SCAN ALL
          p_oAudit.TxtInfo(GetLangText("INDEXING","TXT_RATECODE") + " " + TRANSFORM(rs_reserid), 0)
          rrsyncreser(rs_rsid)
     ENDSCAN

     _screen.oGlobal.lflushforce = l_lOldFlushForce
     DBTableFlushForce()

ENDIF

dclose(l_cCurName)


SELECT (l_nSelect)

p_oAudit.TxtInfo(GetLangText("INDEXING","TXT_RATECODE") + " OK", 0)

RETURN .T.
ENDPROC
*
PROCEDURE nabmsdiscounts
PRIVATE plAutomatic, plSilent
LOCAL l_dSysDate, l_oBMSHandler, l_cCur, l_nSelect, l_nRecNo
IF NOT _screen.BMS
     RETURN .T.
ENDIF
l_nSelect = SELECT()
p_oAudit.txTinfo("BMS "+GetLangText("BILL","TXT_DISCOUNT"),1)
p_oAudit.txTinfo("",1)
SELECT reservat
l_nRecNo = RECNO()
l_dSysDate = sySdate()
STORE .T. TO plAutomatic, plSilent
l_oBMSHandler = NEWOBJECT("cBMSHandler", "common\progs\bmshandler.prg", "", l_dSysDate, g_userid, 1, _screen.oGlobal.oParam2.pa_bmstype, _screen.oGlobal.oParam2.pa_bsdays)
l_cCur = sqlcursor("SELECT ps_reserid FROM post WHERE ps_date = " + sqlcnv(l_dSysDate,.T.) + " AND NOT ps_cancel AND ps_reserid > 1 GROUP BY 1")
SELECT &l_cCur
SCAN FOR SEEK(&l_cCur..ps_reserid, "reservat","tag1")
     SELECT reservat
     p_oAudit.txTinfo(TRANSFORM(rs_reserid) + " " + TRIM(rs_lname),0)
     ProcBill("PBBonusDiscount",,l_oBMSHandler)
ENDSCAN
FLUSH
dclose(l_cCur)
IF l_nRecNo > 0
     GO l_nRecNo IN reservat
ENDIF
p_oAudit.txTinfo(GetLangText("AUDIT","TXT_DONE"),0)
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE NAResetLogFiles
LOCAL i, ldSysDate, lcLogFolder, lcLogName, lcBckName, lnCounter, lcLogFullName
LOCAL ARRAY laLogFiles[1]

ldSysDate = SysDate()
IF DAY(ldSysDate) = 1     && Do reset log files only 1st day on month.
     ************ Add here other log files ******************
     DIMENSION laLogFiles[13]
     laLogFiles[1] = "hotel.err"
     laLogFiles[2] = "hotel.act"
     laLogFiles[3] = "user.log"
     laLogFiles[4] = "audit.log"
     laLogFiles[5] = "auditremote.log"
     laLogFiles[6] = "odbc.err"
     laLogFiles[7] = "deskserver.err"
     laLogFiles[8] = "citadelsrv.err"
     laLogFiles[9] = "autoemail.log"
     laLogFiles[10] = "crypt.log"
     laLogFiles[11] = "cwsblat.log"
     laLogFiles[12] = "kkelpay.log"
     laLogFiles[13] = "fpwingslog.dbf"
     ********************************************************

     lcLogFolder = _screen.oGlobal.choteldir+"logs"
     IF NOT DIRECTORY(lcLogFolder)
          MKDIR &lcLogFolder
     ENDIF

     FOR i = 1 TO ALEN(laLogFiles)
          lcLogName = laLogFiles[i]
          lcLogFullName = _screen.oGlobal.choteldir+lcLogName
          IF FILE(lcLogFullName)
               lcBckName = ADDBS(lcLogFolder) + STRTRAN(lcLogName, ".", "_"+LEFT(DTOS(ldSysDate),6)+".")
               lnCounter = 0
               DO WHILE FILE(lcBckName)
                    lnCounter = lnCounter + 1
                    lcBckName = ADDBS(lcLogFolder) + STRTRAN(lcLogName, ".", "_"+LEFT(DTOS(ldSysDate),6)+"_"+TRANSFORM(lnCounter)+".")
               ENDDO
               RENAME (lcLogFullName) TO (lcBckName)
               IF JUSTEXT(lcLogName) = "dbf"
                    IF FILE(FORCEEXT(lcLogFullName,"fpt"))
                         RENAME (FORCEEXT(lcLogFullName,"fpt")) TO (FORCEEXT(lcBckName,"fpt"))
                    ENDIF
                    IF FILE(FORCEEXT(lcLogFullName,"cdx"))
                         RENAME (FORCEEXT(lcLogFullName,"cdx")) TO (FORCEEXT(lcBckName,"cdx"))
                    ENDIF
               ENDIF
          ENDIF
     NEXT
ENDIF
ENDPROC
*
PROCEDURE NAGetAddressMainChanges
LOCAL l_oObj AS cAdrmainChangesGet
IF NOT _screen.oGlobal.lUseMainServer
     RETURN .T.
ENDIF

WAIT WINDOW GetLangText("ADDRESS","TXT_MAIN_SERVER_ADDRESSES") NOWAIT

= loGdata(TRANSFORM(DATETIME())+"|Get address changes from main server. Starting...",caUditlogfile)

l_oObj = CREATEOBJECT("cAdrmainChangesGet")
l_oObj.Do()
l_oObj = .NULL.

= loGdata(TRANSFORM(DATETIME())+"|Get address changes from main server. Finished.",caUditlogfile)

WAIT CLEAR

RETURN .T.
ENDPROC
*
PROCEDURE NASetRoomStatus
IF NOT paRam.pa_rmstat
     RETURN .T.
ENDIF

IF SEEK(reservat.rs_roomtyp,"roomtype","tag1") AND SEEK(reservat.rs_roomnum,"room","tag1")
     IF INLIST(roomtype.rt_group, 1, 4) AND NOT INLIST(reservat.rs_status, "CXL", "NS") AND NOT EMPTY(reServat.rs_in) AND EMPTY(reServat.rs_out) AND NOT reServat.rs_depdate==g_sysdate
          IF roOm.rm_status<>"OOO" .AND. roOm.rm_status<>"OOS"
               REPLACE roOm.rm_status WITH "DIR" IN room
          ENDIF
     ENDIF
ENDIF

RETURN .T.
ENDPROC
*
DEFINE CLASS cauditfakeprogressbar AS Custom
*
lLog = .T.
cRemoteLogFile = ""
*
PROCEDURE Init
this.cRemoteLogFile = _screen.oGlobal.choteldir + "auditremote.log"
ENDPROC
*
PROCEDURE txTinfo
LPARAMETERS lp_cText, lp_nNum
LOCAL lcSec, lcWR, lcText
IF this.lLog
     lcText = TRANSFORM(lp_cText)
     lcSec = ALLTRIM(STR((SECONDS()-INT(SECONDS()))*1000))
     lcWR = TTOC(DATETIME()) + "." + PADL(lcSec,3,"0")+ " " + lcText
     = loGdata(lcWR,caUditlogfile)
     this.WriteProgress(lcText)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE WriteProgress
LPARAMETERS lp_cText
LOCAL l_lError, i
IF NOT g_lAutomationMode
     RETURN .T.
ENDIF
IF EMPTY(lp_cText)
     RETURN .T.
ENDIF
lp_cText = lp_cText + CHR(13) + CHR(10)
FOR i = 1 TO 3
     l_lError = .F.
     TRY
          STRTOFILE(lp_cText,this.cRemoteLogFile,1)
     CATCH
          l_lError = .T.
     ENDTRY
     IF l_lError
          sleep(100)
     ELSE
          EXIT
     ENDIF
ENDFOR
RETURN .T.
ENDPROC
*
PROCEDURE deleteremotelog
LOCAL i, l_lError

FOR i = 1 TO 3
     l_lError = .F.
     TRY
          DELETE FILE (this.cRemoteLogFile)
     CATCH
          l_lError = .T.
     ENDTRY
     IF l_lError
          sleep(100)
     ELSE
          EXIT
     ENDIF
ENDFOR

RETURN .T.
ENDPROC
*
PROCEDURE progress
LPARAMETERS lp_nStep
RETURN .T.
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS cRemoteAuditReindexTmr As Timer
*
cRemoteLogFile = ""
Interval = 2000
Enabled = .F.
*
PROCEDURE Init
this.cRemoteLogFile = _screen.oGlobal.choteldir + "auditremote.log"
RETURN .T.
ENDPROC
*
PROCEDURE deleteremotelog
LOCAL i, l_lError

FOR i = 1 TO 3
     l_lError = .F.
     TRY
          DELETE FILE (this.cRemoteLogFile)
     CATCH
          l_lError = .T.
     ENDTRY
     IF l_lError
          sleep(100)
     ELSE
          EXIT
     ENDIF
ENDFOR

RETURN .T.
ENDPROC
*
PROCEDURE Timer
this.Enabled = .F.
LOCAL i, l_cText, l_lError
l_cText = ""
IF FILE(this.cRemoteLogFile)
     FOR i = 1 TO 5
          l_lError = .F.
          TRY
               l_cText = FILETOSTR(this.cRemoteLogFile)
          CATCH
               l_lError = .T.
          ENDTRY
          IF l_lError
               sleep(100)
          ELSE
               EXIT
          ENDIF
     ENDFOR
     IF NOT EMPTY(l_cText)
          WAIT WINDOW LEFT(l_cText,255) NOWAIT
     ENDIF
ENDIF
this.Enabled = .T.
RETURN .T.
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS cAdrmainChangesGet AS Session

PROCEDURE Do
LOCAL l_oProcAddress AS procaddress OF libs\proc_address.vcx

ini(.T.,.T.)
openfile(.F.,"address")
l_oProcAddress = NEWOBJECT("procaddress","libs\proc_address.vcx")
l_oProcAddress.adrmainchangesget()

RETURN .T.
ENDPROC
*
ENDDEFINE
*