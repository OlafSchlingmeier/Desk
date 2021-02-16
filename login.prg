#INCLUDE "include\constdefines.h"
*
FUNCTION Login
 LPARAMETER liNfinite
 PUBLIC llOgin
 PRIVATE cbMpfile
 PRIVATE cuSer_id
 PRIVATE cpAssword
 PRIVATE ncAshier
 PRIVATE ncHoice
 PRIVATE nlOcks
 PRIVATE noLdarea
 LOCAL _wasopened, l_lResult, l_oLoginProgress AS Form, l_cCurUser, l_cCurGroup, l_cCurPicklist, l_cSql, ;
           l_lPassCrypted, l_lSuccessCheckNetId, l_lCalledToChangeDatabase
 noLdarea = SELECT()
 IF FILE("logo.bmp")
     cbMpfile = "Logo.Bmp"
 ELSE
     cbMpfile = ""
 ENDIF
 cuSer_id = SPACE(10)
 cpAssword = SPACE(10)
 ncAshier = 0
 ncHoice = 0
 = SetLicenceParameters()

 IF NOT ISNULL(goTbrQuick)
     goTbrQuick.ChangeMode(TLB_DISABLE)
 ENDIF

 DO CASE
      CASE  .NOT. EMPTY(GETENV("BFW_LOGIN")) .AND.  .NOT. liNfinite
           cuSer_id = PADR(GETENV("BFW_LOGIN"),10)
           ncAshier = VAL(GETENV("BFW_CASHIER"))
           cpAssword = PADR(GETENV("BFW_PASSWORD"),10)
      CASE TYPE("g_oUserData.cuser") = "C" AND ;
                 .NOT. EMPTY(g_oUserData.cuser) .AND.  .NOT. liNfinite
           cuSer_id = PADR(g_oUserData.cuser,10)
           ncAshier = VAL(g_oUserData.ccashier)
           cpAssword = PADR(g_oUserData.cpass,10)
           IF g_oUserData.lpassc && Use this property, to indicate when login function is called to just change database.
                l_lPassCrypted = g_oUserData.lpassc
                g_oUserData.lpassc = .F.
                l_lCalledToChangeDatabase = .T.
           ENDIF
 ENDCASE
 procnavpane("ReleaseNavPane")
 MdMyDesk()
 IF EMPTY(cuSer_id)
      cuSer_id = SPACE(10)
      cpAssword = SPACE(10)
      ncAshier = 0
      IF openfiledirect(.F.,"user")
           l_cCurUser = sqlcursor([SELECT * FROM "user" WHERE 0=1])
           SELECT(l_cCurUser)
           SCATTER NAME _screen.oGlobal.oUser MEMO BLANK
           dclose(l_cCurUser)
      ENDIF
      IF openfiledirect(.F.,"group")
           l_cCurGroup = sqlcursor([SELECT * FROM "group" WHERE 0=1])
           SELECT(l_cCurGroup)
           SCATTER NAME _screen.oGlobal.oGroup MEMO BLANK
           dclose(l_cCurGroup)
      ENDIF
      llOgin = .T.
      SetStatusBarMessage()
      DO SetMessagesOff IN procmessages
      DO FORM "forms\login"
 ELSE
      IF ( .NOT. vcHeckthem(,l_lPassCrypted,l_lCalledToChangeDatabase))
           IF l_lCalledToChangeDatabase
                RETURN .F.
           ELSE
                = msGbox("Check the BFW_ environment settings!", ;
                  "Automatic Login Error",0)
                DO MainQuit IN Main
                RETURN TO MASTER
           ENDIF
      ENDIF
 ENDIF

 IF EMPTY(cUser_id) OR _screen.oGlobal.lLoginFailed
      _screen.oGlobal.lLoginFailed = .F.
      RETURN .F.
 ENDIF

 *DO FORM "forms\progresslogin" WITH getapplangtext("LOGIN","TXT_LOGGING_IN") + " " + ALLTRIM(cuSer_id) + "..." NAME l_oLoginProgress
_vfp.AutoYield = .T. && For progress bar
 DO FORM "forms\progresssimple" NAME l_oLoginProgress
 l_oLoginProgress.SetInfo(getapplangtext("LOGIN","TXT_LOGGING_IN") + " " + ALLTRIM(cuSer_id) + "...")
 l_oLoginProgress.InitProgress(6)

 DO CheckNetID IN Main WITH ,l_lSuccessCheckNetId,l_lCalledToChangeDatabase&& Don't quit, when no success
 IF NOT l_lSuccessCheckNetId
      l_oLoginProgress.Release()
      RETURN .F.
 ENDIF
 l_oLoginProgress.Progress()
 SELECT liCense
 REPLACE liCense.lc_user WITH cuSer_id
 FLUSH
 WAIT CLEAR

 = opEnfile()
 l_oLoginProgress.Progress()
 = chEcklite()
 = reLations()
 = SetUserEnv()
 l_oLoginProgress.Progress()
 g_oPredefinedColors.GetColors()

 llOgin = .F.
 = acTion(4)
 ProcToolbar()
 l_oLoginProgress.Progress()

 * It is possible, that user was logged out, audit was performed, and param.pa_sysdate was changed, but
 * not refreshed in _screen.oGlobal.oparam.pa_sysdate, so wrong sysdate was used in system!
 _screen.oGlobal.RefreshTableParam()
 _screen.oGlobal.RefreshTableParam2()

 DO seTstatus IN Setup
 l_oLoginProgress.Progress()
 SELECT (noLdarea)
 IF NOT _screen.oGlobal.lDoAuditOnStartup AND NOT _screen.oGlobal.oMultiProper.lSwitchingHotel
      DO CheckForActions IN procaction WITH l_lResult
 ENDIF
 l_oLoginProgress.Progress()
 l_oLoginProgress.Release()
 IF l_lResult
      doform('activities','forms\activities WITH "CURRENTUSER"')
 ENDIF
 _vfp.AutoYield = .F.
 _screen.oGlobal.AfterLogin()
 IF NOT _screen.oGlobal.lDoAuditOnStartup
      DO SetMessagesOn IN procmessages
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION LoginWindow
 PARAMETER naCtivate, plReconfirm
 PRIVATE nhEight, ctItle
 IF plReconfirm
      nhEight = 8
      ctItle = GetLangText("USER","TXT_CONFIRM")
 ELSE
      nhEight = 20
      ctItle = GetLangText("USER","TXT_LOGIN")
 ENDIF
 IF (naCtivate==0)
      DEFINE WINDOW wlOgin AT 0, 0 SIZE nhEight, 45 FONT "Arial", 10  ;
             NOGROW NOCLOSE NOZOOM TITLE chIldtitle(ctItle) SYSTEM
      MOVE WINDOW wlOgin CENTER
      ACTIVATE WINDOW wlOgin
 ELSE
      DEACTIVATE WINDOW wlOgin
      RELEASE WINDOW wlOgin
      = chIldtitle("")
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION vCheckThem
 LPARAMETERS plReconfirm, plPassC, plCalledToChangeDatabase
 PRIVATE lrEturn
 PRIVATE neRrorcode
 LOCAL l_nSelect, l_oCaUser, l_oCaGroup, l_oCaCashier, l_cPass, l_lSuccessCheckNetId
 l_nSelect = SELECT()
 lrEturn = .F.
 neRrorcode = 0
 DO CheckNetID IN Main WITH ,l_lSuccessCheckNetId,plCalledToChangeDatabase
 IF NOT l_lSuccessCheckNetId AND plCalledToChangeDatabase
      RETURN lrEturn
 ENDIF
 IF g_totalandsuperuser
      IF UPPER(ALLTRIM(cuSer_id))<>"SUPERVISOR" OR ;
           ( ;
           (cpAssword<> STR(YEAR(sySdate())*2+MONTH(sySdate())+DAY(sySdate()), 4)) AND NOT plCalledToChangeDatabase ;
           )
                * DON'T FORGET TO CHANGE PASSWORD DOWN TOO!!!
           = alErt("No Available Network ID!")
           IF plCalledToChangeDatabase
                RETURN lrEturn
           ELSE
                DO CHECKWIN IN CHECKWIN WITH 'CLEANUP',.T.,.T.,.F.,.T.
                RETURN TO MASTER
           ENDIF
      ENDIF
      g_totalandsuperuser = .F.
 ENDIF
 
 l_oCaUser = NEWOBJECT("causer","progs\cadefdesk.prg")
 l_oCaGroup = NEWOBJECT("cagroup","progs\cadefdesk.prg")
 l_oCaCashier = NEWOBJECT("cacashier","progs\cadefdesk.prg")
 
 DO WHILE (.T.)
      l_oCaUser.cfilterclause = "us_id="+sqlcnv(PADR(UPPER(ALLTRIM(cuSer_id)),10),.T.) + " AND NOT us_inactiv"
      l_oCaUser.CursorFill()
      
      SELECT causer
      LOCATE FOR ALLTRIM(us_id)==UPPER(ALLTRIM(cuSer_id))
      IF (EOF())
           neRrorcode = 1
           EXIT
      ENDIF
      IF EMPTY(ncAshier)
           ncAshier = causer.us_cashier
      ENDIF

      l_oCaGroup.cfilterclause = "gr_group="+sqlcnv(causer.us_group,.T.)
      l_oCaGroup.CursorFill()
      
      SELECT cagroup
      LOCATE FOR gr_group==causer.us_group
      IF (EOF())
           neRrorcode = 2
           EXIT
      ENDIF
      IF plPassC
           l_cPass = ALLTRIM(cpAssword) && Sent direct from us_pass field.
      ELSE
           l_cPass = SYS(2007, ALLTRIM(UPPER(cpAssword)))
      ENDIF
      IF (l_cPass<>ALLTRIM(UPPER(causer.us_pass)))
           IF (UPPER(ALLTRIM(cuSer_id))<>"SUPERVISOR" .OR. cpAssword<> ;
              STR(YEAR(sySdate())*2+MONTH(sySdate())+DAY(sySdate()), 4))
              * DON'T FORGET TO CHANGE PASSWORD ABOVE TOO!!!
                neRrorcode = 3
                EXIT
           ENDIF
      ENDIF

      l_oCaCashier.cfilterclause = "ca_number="+sqlcnv(ncAshier,.T.)
      l_oCaCashier.CursorFill()

      SELECT cacashier
      LOCATE FOR (ca_number==ncAshier)
      IF (EOF())
           = alErt(GetLangText("USER","TXT_NOCASH"))
           EXIT
      ENDIF
      gcCashier = ""
      IF ( .NOT. cacashier.ca_isopen)
           IF _screen.oGlobal.lDoAuditOnStartup OR (yeSno(GetLangText("USER","TXT_OPEN")+" "+ALLTRIM(cacashier.ca_name)+ ;
              "?",GetLangText("USER","TXT_CASHISCLOSED")))
                IF (cacashier.ca_opcount<cacashier.ca_opmax)
                     REPLACE ca_opdate WITH sySdate(), ;
                             ca_optime WITH TIME(), ;
                             ca_opcount WITH cacashier.ca_opcount+1, ;
                             ca_isopen WITH .T. ;
                             IN cacashier
                     l_oCaCashier.DoTableUpdate(.F.)
                     EndTransaction()
                ELSE
                     = alErt(GetLangText("USER","TXT_MAXOPEN"))
                     ncAshier = 0
                     EXIT
                ENDIF
           ELSE
                neRrorcode = 4
                ncAshier = 0
                EXIT
           ENDIF
      ENDIF
      
      * User selected, set properties for user
      
      SELECT causer
      SCATTER NAME _screen.oGlobal.oUser MEMO
      SELECT cagroup
      SCATTER NAME _screen.oGlobal.oGroup MEMO
      
      STORE cuSer_id TO cuSerid, g_Userid
      g_Cashier = ncAshier
      gcCashier = ALLTRIM(cacashier.ca_name)
      g_Usergroup = ALLTRIM(_screen.oGlobal.oUser.us_group)
      g_username = ALLTRIM(_screen.oGlobal.oUser.us_name)
      LoginSetPaRights()
      LoginSetUserLanguage()

      lrEturn = .T.

      EXIT
 ENDDO

 l_oCaUser.dclose()
 l_oCaGroup.dclose()
 l_oCaCashier.dclose()
 STORE .NULL. TO l_oCaUser, l_oCaGroup, l_oCaCashier

 IF (neRrorcode<>0)
       = alErt(GetLangText("USER","TXT_NOACCESS"))
 ENDIF

 IF  .NOT. plReconfirm
      = clOsefile("User")
      = clOsefile("Group")
      = clOsefile("PickList")
      = clOsefile("Cashier")
      = clOsefile("files")
 ENDIF
 SELECT(l_nSelect)
 RETURN lrEturn
ENDFUNC
*
FUNCTION RefreshUser
 LOCAL l_nSelect
 l_nSelect = SELECT()
 IF USED("user")
      SELECT usEr
      LOCATE FOR ALLTRIM(usEr.us_id)==UPPER(ALLTRIM(g_Userid))
 ENDIF
 IF USED("group")
      SELECT grOup
      LOCATE FOR grOup.gr_group==usEr.us_group
 ENDIF
 SELECT(l_nSelect)
 RETURN .T.
ENDFUNC
*
FUNCTION CloseFiles
 LOCAL l_lTablesOnly
 IF (USED("License"))
      SELECT liCense
      REPLACE liCense.lc_user WITH ""
      REPLACE liCense.lc_station WITH ""
      REPLACE liCense.lc_time WITH TIME()
      REPLACE liCense.lc_date WITH DATE()
 ENDIF
 *CLOSE DATABASES
 l_lTablesOnly = .T.
 CloseAllFiles(l_lTablesOnly)
 RETURN .T.
ENDFUNC
*
FUNCTION SizeName
 PARAMETER cuSerid
 cuSerid = PADR(ALLTRIM(cuSerid), 10)
 RETURN .T.
ENDFUNC
*
PROCEDURE CheckLite
 LOCAL naRea, nsTdrooms, npMrooms, ncOnfrooms, lcSql
 IF g_Lite
      STORE 0 TO nsTdrooms, npMrooms, ncOnfrooms
      
      naRea = SELECT()

      TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
           SELECT rt_group, COUNT(*) AS counted ;
                FROM room ;
                INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp ;
                GROUP BY 1
      ENDTEXT

      l_cCur = SqlCursor(lcSql,,,"",.NULL.,.T.)
      IF RECCOUNT()>0
           nsTdrooms = LOOKUP(counted,1,rt_group)
           ncOnfrooms = LOOKUP(counted,2,rt_group)
           npMrooms = LOOKUP(counted,2,rt_group)
      ENDIF

      dclose(l_cCur)

      IF nsTdrooms>30 .OR. ncOnfrooms>0 .OR. npMrooms>5
           = msGbox( ;
             "This " + gcApplication + " Lite version has the following limitations:"+ ;
             CHR(13)+CHR(10)+CHR(13)+CHR(10)+ ;
             "30 Standard rooms, 5 Dummy rooms and no Conference rooms."+ ;
             CHR(13)+CHR(10)+CHR(10)+ ;
             "Your database exceeds these limitations and the program is now switching to Demo mode!", ;
             "Warning",16)
           g_Demo = .T.
           g_Hotel = gcApplication + " Lite Demo Hotel, Warendorf"
           = msGbox("Limited demo version!"+CHR(13)+CHR(10)+ ;
             "Maximum 50/150 transactions","Warning",48)
      ENDIF
      
      SELECT (naRea)
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE Reconfirm
 LPARAMETERS plCancel
 PRIVATE naRea, cuSer_id, cpAssword, cbUttons, nbTn, ncAshier
 LOCAL l_lCancel
 plCancel = .T.
 naRea = SELECT()
 cuSer_id = g_Userid
 cpAssword = SPACE(10)
 ncAshier = g_Cashier
 DO FORM "forms\relogin" TO l_lCancel
 IF NOT l_lCancel
       IF vcHeckthem(.T.)
           DO seTstatus IN Setup
           plCancel = .F.
      ENDIF
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE SetLicenceParameters
 LOCAL i, j, l_cLicence, l_cModule, l_cLicenceSet, l_cInterfaceModule

 l_cLicence = UPPER(STRTRAN(_screen.oGlobal.oParam.pa_lizopt," "))
 IF EMPTY(l_cLicence)
      RETURN .T.
 ENDIF
 FOR i = 1 TO GETWORDCOUNT(l_cLicence,",")
      l_cModule = ALLTRIM(GETWORDNUM(l_cLicence, i, ","))
      IF LEFT(l_cModule,1) = "I"
          l_cLicenceSet = SUBSTR(l_cModule,2)
          FOR j = 1 TO LEN(l_cLicenceSet)
               l_cInterfaceModule = SUBSTR(l_cLicenceSet,j,1)
               l_cModule = IIF(l_cInterfaceModule = "E", "EI", "I"+l_cInterfaceModule)
               IF ","+l_cModule+"," $ ","+_screen.liclist+","
                   _screen.&l_cModule = .T.
               ENDIF
          NEXT
      ELSE
          IF ","+l_cModule+"," $ ","+_screen.liclist+","
              _screen.&l_cModule = .T.
          ENDIF
      ENDIF
 NEXT
 _screen.TP = _screen.TP AND ArgusOffice("LICENSE", "TP",,.T.)

 DO SetAllottMode IN procallott

 RETURN .T.
ENDPROC
*
PROCEDURE LoginAllowed
 * Not used anymore
 LPARAMETERS lp_cUserID
 RETURN .T.
 
*!*      LOCAL l_lAllowed
*!*      l_lAllowed = .F.
*!*      IF openfile(.F.,"param") AND DLock("param",2,.T.)
*!*           l_lAllowed = .T.
*!*      ENDIF
*!*      = closefile("param")
*!*      IF NOT l_lAllowed
*!*           IF lp_cUserID == "SUPERVISOR"
*!*                = MESSAGEBOX("Warning, System maintenance is in progress!",16,"Information",60000)
*!*                l_lAllowed = .T.
*!*           ELSE
*!*                = MESSAGEBOX("Login not allowed, System maintenance is in progress!",16,"Information",60000)
*!*           ENDIF
*!*      ENDIF
*!*      RETURN l_lAllowed
ENDPROC
*
PROCEDURE SetUserEnv
 LOCAL l_nSelect
 l_nSelect = SELECT()
 IF USED("user")
      SELECT usEr
      LOCATE FOR usEr.us_id==g_Userid
      ncAshier = usEr.us_cashier
 ENDIF
 IF USED("group")
      SELECT grOup
      LOCATE FOR grOup.gr_group==usEr.us_group
      SELECT caShier
      LOCATE FOR (caShier.ca_number==ncAshier)
 ENDIF
 _screen.oGlobal.SearchResCriteriums()
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
FUNCTION CheckSpecLogin
LPARAMETERS lp_cUser, lp_cPassword, lp_lRet
IF g_Userid == lp_cUser AND VAL(lp_cPassword) = _screen.oGlobal.oParam.pa_license
     lp_lRet = .T.
ELSE
     lp_lRet = .F.
     Alert(GetLangText("USER","TXT_NOACCESS"))
ENDIF
RETURN lp_lRet
ENDFUNC
*
PROCEDURE LoginSetPaRights
 EXTERNAL ARRAY parights
 LOCAL i
 STORE .F. to parights
 WITH _screen.oGlobal.oGroup
      FOR i=1 TO 16
           parights(i)=EVALUATE('VAL(SUBSTR(.gr_butrese,i,1))=1')
           parights(i+16)=EVALUATE('VAL(SUBSTR(.gr_reserva,i,1))=1')
           parights(i+32)=EVALUATE('VAL(SUBSTR(.gr_butrscr,i,1))=1')
           parights(i+48)=EVALUATE('VAL(SUBSTR(.gr_butbill,i,1))=1')
           parights(i+64)=EVALUATE('VAL(SUBSTR(.gr_butcout,i,1))=1')
           parights(i+80)=EVALUATE('VAL(SUBSTR(.gr_butrate,i,1))=1')
           parights(i+96)=EVALUATE('VAL(SUBSTR(.gr_butaddr,i,1))=1')
           parights(i+112)=EVALUATE('VAL(SUBSTR(.gr_other,i,1))=1')
           parights(i+128)=EVALUATE('VAL(SUBSTR(.gr_butadd2,i,1))=1')
           parights(i+144)=EVALUATE('VAL(SUBSTR(.gr_butplan,i,1))=1')
           parights(i+160)=EVALUATE('VAL(SUBSTR(.gr_allott,i,1))=1')
           parights(i+176)=EVALUATE('VAL(SUBSTR(.gr_btcout2,i,1))=1')
           parights(i+192)=EVALUATE('VAL(SUBSTR(.gr_conplan,i,1))=1')
           parights(i+208)=EVALUATE('VAL(SUBSTR(.gr_condayp,i,1))=1')
           parights(i+224)=EVALUATE('VAL(SUBSTR(.gr_aze,i,1))=1')
           parights(i+240)=EVALUATE('VAL(SUBSTR(.gr_buthous,i,1))=1')
      ENDFOR
 ENDWITH
 RETURN .T.
ENDPROC
*
PROCEDURE LoginSetUserLanguage
 IF (_screen.oGlobal.oUser.us_lang<>g_Language)
      LOCAL i, l_cLangNum
      l_cLangNum = dlookup( ;
           "picklist", ;
           "pl_label="+sqlcnv(PADR("LANGUAGE", 10),.T.)+" AND pl_charcod="+sqlcnv(_screen.oGlobal.oUser.us_lang,.T.), ;
           "pl_numcod", ;
           .F., ;
           .T.)
      l_cLangNum = TRANSFORM(l_cLangNum)
      g_Langnum = l_cLangNum
      g_Language = _screen.oGlobal.oUser.us_lang  
 ENDIF
 FOR i = 1 TO 7
      padow(i) = MyCDoW(i)
 NEXT
 FOR i = 1 TO 12
      pamonths(i) = MyCMonth(i)
 NEXT
 RETURN .T.
ENDPROC
*