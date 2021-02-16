LOCAL l_cRoomNumber
IF (paRam.pa_pttwake)
	DO FORM "forms\wakeup" TO l_cRoomNumber
	DO childtitle WITH ""
ENDIF
RETURN l_cRoomNumber
ENDFUNC
*
FUNCTION WriteWakeUp
 PARAMETER crOom, ddAte, ctIme, cwUlang, cOrigWakTime
 PRIVATE cfIlename
 PRIVATE nhAndle
 LOCAL cFileContents
 cfIlename = _screen.oGlobal.choteldir+"ifc\Ptt\WakeUp\"+PADR(phOnenr(crOom), 4, "_")+ ;
             SUBSTR(DTOS(ddAte), 5)+".WAK"
 cFileContents = ctIme+cwUlang+IIF(EMPTY(cOrigWakTime),SPACE(5),cOrigWakTime)+DTOS(ddAte)
 nhAndle = FCREATE(cfIlename)
 IF (nhAndle==-1)
      = alErt(txT_openerror)
 ELSE
      = FWRITE(nhAndle, cFileContents)
      = FCLOSE(nhAndle)
 ENDIF
 cfIlename = _screen.oGlobal.choteldir+"ifc\Ptv\"+PADR(get_rm_rmname(crOom), 10, "_")+SUBSTR(DTOS(ddAte), 5)+".WAK"
 nhAndle = FCREATE(cfIlename)
 IF (nhAndle==-1)
      = alErt(txT_openerror)
 ELSE
      = FWRITE(nhAndle, cFileContents)
      = FCLOSE(nhAndle)
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION SyncWakes
 PRIVATE naRea
 naRea = SELECT()
 IF doPen("WakeUp")
      SELECT waKeup
      DELETE ALL FOR wu_date<DATE()
      FLUSH
      SCAN ALL
           WAIT WINDOW NOWAIT waKeup.wu_room+" /"+DTOC(waKeup.wu_date)+ ;
                " /"+waKeup.wu_time
           = wrItewakeup(waKeup.wu_room,waKeup.wu_date,waKeup.wu_time, ;
             waKeup.wu_lang)
           SKIP 1 IN "WakeUp"
      ENDSCAN
      dcLose("WakeUp")
 ENDIF
 SELECT (naRea)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION vCheckDate
 PARAMETER crOomnumber, ddAte
 PRIVATE loKay
 PRIVATE noRder
 PRIVATE nrEcord
 loKay = .T.
 IF (LASTKEY()<>27)
      SELECT reServat
      noRder = ORDER()
      nrEcord = RECNO()
      SET ORDER TO 6
      IF ( .NOT. SEEK("1"+crOomnumber))
           crEaderror = GetLangText("WAKEUP","TXT_NOTCHECKEDIN")
           loKay = .F.
      ELSE
           IF (ddAte>=reServat.rs_arrdate .AND. ddAte<=reServat.rs_depdate)
                IF (ddAte<sySdate())
                     crEaderror = GetLangText("WAKEUP","TXT_SOMETIMEAGO")
                     loKay = .F.
                ELSE
                     loKay = .T.
                ENDIF
           ELSE
                crEaderror = GetLangText("WAKEUP","TXT_DATENOTVALID")
                loKay = .F.
           ENDIF
      ENDIF
      SELECT reServat
      SET ORDER TO nOrder
      GOTO nrEcord
 ENDIF
 RETURN loKay
ENDFUNC
*
FUNCTION vCheckTime
 PARAMETER ctIme
 PRIVATE loKay
 PRIVATE nhOur
 PRIVATE nmInute
 nhOur = VAL(SUBSTR(ctIme, 1, 2))
 nmInute = VAL(SUBSTR(ctIme, 4, 2))
 IF (LASTKEY()==27)
      loKay = .T.
 ELSE
      IF ((nhOur>=0 .AND. nhOur<24 .AND. nmInute>=0 .AND. nmInute<60))
           loKay = .T.
      ELSE
           crEaderror = txT_timenotvalid
           loKay = .F.
      ENDIF
 ENDIF
 RETURN loKay
ENDFUNC
*