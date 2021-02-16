 PARAMETER cfIlealias, crOom, ccAption, cfLagtext
 PRIVATE ncHoice
 PRIVATE ctExt
 PRIVATE lsHowatcheckin
 PRIVATE cfLagmacro
 PRIVATE cmEssmacro
 PRIVATE noBject
 IF (PARAMETERS()==2)
      lsHowname = .T.
      ccAption = GetLangText("MESSAGE","TXT_ROOM")
      cfLagtext = GetLangText("MESSAGE","TXT_ACTLAMP")
 ELSE
      lsHowname = .F.
 ENDIF
 cmEssmacro = cfIlealias+".Rs_Message"
 cfLagmacro = cfIlealias+".Rs_MsgShow"
 ncHoice = 1
 noBject = 1
 = meSsagewindow(0,IIF(UPPER(cfIlealias)=="RESERVAT", GetLangText("MESSAGE", ;
   "TXT_RESERVAT"), ccAption))
 = SEEK(crOom, "Room")
 cText          = &cMessMacro
 lShowAtCheckIn = iIf(Empty(cText), iIf(Upper(cFileAlias) == "RESERVAT", Param.Pa_MsgShow, Param.Pa_WaiShow), &cFlagMacro)
 IF (lsHowname)
      = txTpanel(1,2,40,GetLangText("MESSAGE","TXT_NAME")+":"+ ;
        TRIM(adDress.ad_lname)+", "+TRIM(adDress.ad_fname),38)
 ELSE
      = txTpanel(1,2,40,GetLangText("MESSAGE","TXT_NOTE_FOR_ROOM")+" "+crOom,38)
 ENDIF
 = txTpanel(1,42,64,"",10)
 = paNel(3,2,17,65,1)
 @ 1, 44 GET lsHowatcheckin FUNCTION "*C" PICTURE IIF(UPPER(cfIlealias)== ;
   "RESERVAT", GetLangText("MESSAGE","TXT_SHOWATCHECKIN"), cfLagtext)
 noBject = 2
 @ 3.250, 3 EDIT ctExt SIZE 13.5, 61.5
 @ 18, 2 GET ncHoice STYLE "B" SIZE nbUttonheight, 15 FUNCTION "*"+"H"  ;
   PICTURE "\!"+GetLangText("COMMON","TXT_OK")+";\?"+GetLangText("COMMON","TXT_CANCEL")+ ;
   ";"+GetLangText("MESSAGE","TXT_PRINTOUT")+";"+GetLangText("MESSAGE","TXT_DELETE")
 READ VALID vmSgdone(@ncHoice,@ctExt,@lsHowatcheckin,cfIlealias) OBJECT  ;
      noBject MODAL
 = meSsagewindow(1)
 RETURN .T.
ENDFUNC
*
FUNCTION MessageWindow
 PARAMETER naCtivate, chEading
 IF (naCtivate==0)
      DEFINE WINDOW wmEssage AT 00, 00 SIZE 20, 67 FONT "Arial", 10  ;
             NOGROW NOCLOSE NOZOOM TITLE chIldtitle(chEading) SYSTEM
      MOVE WINDOW wmEssage CENTER
      ACTIVATE WINDOW wmEssage
 ELSE
      DEACTIVATE WINDOW wmEssage
      RELEASE WINDOW wmEssage
      = chIldtitle("")
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION vMsgDone
 PARAMETER ncHoice, ctExt, lsHow, cfIlename
 PRIVATE lrEturn
 PRIVATE cmAcro
 PRIVATE nsElected
 PRIVATE cmEssage
 lrEturn = .T.
 DO CASE
      CASE ncHoice==1
           cmAcro = cfIlename+".Rs_Message"
           Replace &cMacro With cText
           cmAcro = cfIlename+".Rs_MsgShow"
           Replace &cMacro With lShow
           IF (UPPER(cfIlename)=="ROOM")
                IF (paRam.pa_pttmess .AND. roOm.rs_msgshow)
                     = wrItepttmessagewaiting(ALLTRIM(roOm.rm_roomnum), ;
                       roOm.rs_message)
                ENDIF
                IF (paRam.pa_ptvmess .AND. roOm.rs_msgshow)
                     = wrIteptvmessagewaiting(ALLTRIM(roOm.rm_roomnum), ;
                       roOm.rs_message)
                ENDIF
           ENDIF
           lrEturn = .T.
      CASE ncHoice==2
           cmAcro = cfIlename+".Rs_Message"
           If ( !(AllTrim(cText) == AllTrim(&cMacro)) )
                IF ( .NOT. yeSno(GetLangText("MESSAGE","TXT_OKTOLOSEALLCHANGES")))
                     lrEturn = .F.
                ENDIF
           ENDIF
      CASE ncHoice==3
           IF  .NOT. EMPTY(TRIM(ctExt))
                l_Area = SELECT()
                g_Rptlngnr = g_Langnum
                g_Rptlng = g_Language
                l_Frx = gcReportdir+"_message.FRX"
                l_Langdbf = STRTRAN(UPPER(l_Frx), '.FRX', '.DBF')
                IF FILE(l_Langdbf)
                     USE SHARED NOUPDATE (l_Langdbf) ALIAS rePtext IN 0
                ENDIF
                cmEssage = M.ctExt
                SELECT reServat
                l_Rsrec = RECNO()
                REPORT FORM (l_Frx) TO PRINTER PROMPT NOCONSOLE FOR  ;
                       RECNO()=l_Rsrec
                GOTO l_Rsrec
                = dcLose('RepText')
                DO seTstatus IN Setup
                SELECT (l_Area)
           ELSE
                = alErt(GetLangText("MESSAGE","TXT_NOMSG"))
           ENDIF
           ncHoice = 0
           lrEturn = .F.
      CASE ncHoice==4
           IF (yeSno(GetLangText("MESSAGE","TXT_DELMESSAGE")))
                ctExt = ""
                lsHow = paRam.pa_msgshow
                SHOW GETS
           ENDIF
           lrEturn = .F.
 ENDCASE
 SHOW GETS
 RETURN lrEturn
ENDFUNC
*
FUNCTION WritePTTMessageWaiting
 PARAMETER crOom, ctExt, lsYnchronise
 PRIVATE cfIlename
 PRIVATE ccHeckfilename
 PRIVATE nhAndle
 IF (PARAMETERS()==2)
      lsYnchronise = .F.
 ENDIF
 cfIlename = _screen.oGlobal.choteldir+"ifc\Ptt\Message\"+phOnenr(crOom)+".MSG"
 IF (EMPTY(ctExt))
      IF (FILE(cfIlename))
           DELETE FILE (cfIlename)
      ENDIF
      cfIlename = LEFT(cfIlename, AT(".MSG", cfIlename))+"OFF"
 ELSE
      ccHeckfilename = LEFT(cfIlename, AT(".MSG", cfIlename))+"OFF"
      IF (FILE(ccHeckfilename))
           DELETE FILE (ccHeckfilename)
      ENDIF
 ENDIF
 nhAndle = FCREATE(cfIlename)
 IF (nhAndle==-1)
      = alErt(GetLangText("MESSAGE","TXT_OPENERROR"))
 ELSE
      = FWRITE(nhAndle, DTOC(DATE())+TIME()+(CHR(13)+CHR(10)))
      = FWRITE(nhAndle, ctExt)
      = FCLOSE(nhAndle)
      IF ( .NOT. lsYnchronise)
           IF (EMPTY(ctExt))
                WAIT WINDOW TIMEOUT 1 GetLangText("MESSAGE","TXT_PTT")+CHR(13)+ ;
                     CHR(10)+GetLangText("MESSAGE","TXT_FILE_DELETED")
           ELSE
                WAIT WINDOW TIMEOUT 1 GetLangText("MESSAGE","TXT_PTT")+CHR(13)+ ;
                     CHR(10)+GetLangText("MESSAGE","TXT_ACTIVATED")
           ENDIF
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION WritePTVMessageWaiting
 PARAMETER crOom, ctExt, lsYnchronise
 PRIVATE cfIlename
 PRIVATE ccHeckfilename
 PRIVATE nhAndle
 IF (PARAMETERS()==2)
      lsYnchronise = .F.
 ENDIF

 cfIlename = _screen.oGlobal.choteldir+"ifc\Ptv\"+get_rm_rmname(crOom)+".MSG"
 DO IfcFixFileName IN interfac WITH cfIlename
 IF (EMPTY(ctExt))
      IF (FILE(cfIlename))
           DELETE FILE (cfIlename)
      ENDIF
      cfIlename = LEFT(cfIlename, AT(".MSG", cfIlename))+"OFF"
 ELSE
      ccHeckfilename = LEFT(cfIlename, AT(".MSG", cfIlename))+"OFF"
      IF (FILE(ccHeckfilename))
           DELETE FILE (ccHeckfilename)
      ENDIF
 ENDIF
 nhAndle = FCREATE(cfIlename)
 IF (nhAndle==-1)
      = alErt(GetLangText("MESSAGE","TXT_OPENERROR"))
 ELSE
      = FWRITE(nhAndle, DTOC(DATE())+TIME()+(CHR(13)+CHR(10)))
      = FWRITE(nhAndle, ctExt)
      = FCLOSE(nhAndle)
      IF ( .NOT. lsYnchronise)
           IF (EMPTY(ctExt))
                WAIT WINDOW TIMEOUT 1 GetLangText("MESSAGE","TXT_PAYTV")+CHR(13)+ ;
                     CHR(10)+GetLangText("MESSAGE","TXT_FILE_DELETED")
           ELSE
                WAIT WINDOW TIMEOUT 1 GetLangText("MESSAGE","TXT_PAYTV")+CHR(13)+ ;
                     CHR(10)+GetLangText("MESSAGE","TXT_ACTIVATED")
           ENDIF
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION WriteMessageWaiting
 PARAMETER crOom, ctExt, lsYnchronise
 PRIVATE nsElect
 PRIVATE noRder
 nsElect = SELECT()
 SELECT roOm
 noRder = ORDER()
 SET ORDER TO 1
 IF (SEEK(PADR(crOom, 4), "Room"))
      = wrIteptvmessagewaiting(crOom,ctExt,lsYnchronise)
      = wrItepttmessagewaiting(crOom,ctExt,lsYnchronise)
 ENDIF
 SELECT roOm
 SET ORDER TO nOrder
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
