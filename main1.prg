*
FUNCTION Main1
 PARAMETER ccOmmand
 PRIVATE cdUmmy
 PUBLIC leXit
 PUBLIC gcApplication
 PUBLIC glTraining
 PUBLIC g_Lite
 IF WEXIST('Standard')
      HIDE WINDOW stAndard
 ENDIF
 PUBLIC gcReportdir
 PUBLIC gcDatadir
 gcReportdir=sys(5)+sys(2003)+"\report\"
 gcDatadir=sys(5)+sys(2003)+"\data\"
 * gcReportdir = "Report\"  
 * gcDatadir = "Data\"   
 IF (FILE("Hotel.Dbg"))
      WAIT WINDOW NOWAIT "You started in debug mode!"+(CHR(13)+CHR(10))+ ;
           "Please delete \Hotel\Hotel.Dbg!"
 ENDIF
 PUSH KEY CLEAR
 CLOSE DATABASES
 CLEAR MACROS
 DECLARE INTEGER GetPrivateProfileString IN Win32API STRING, STRING,  ;
         STRING, STRING @, INTEGER, STRING
 DECLARE INTEGER WritePrivateProfileString IN Win32API STRING, STRING,  ;
         STRING, STRING
 DECLARE INTEGER GetProfileString IN Win32API STRING, STRING, STRING,  ;
         STRING @, INTEGER
 DECLARE INTEGER WriteProfileString IN Win32API STRING, STRING, STRING
 SET CENTURY TO 19 ROLLOVER 40
 SET PROCEDURE TO Func
 gcApplication = "Application"
 glTraining = .F.
 IF (PARAMETERS()>0)
      DO CASE
           CASE LEFT(UPPER(ccOmmand), 4)=="STRU"
                = dbUpdate()
           CASE AT("TRAINING", UPPER(ALLTRIM(ccOmmand)))>0
                glTraining = .T.
      ENDCASE
 ENDIF
 SET SYSMENU TO
 = chEcknetid()
 = acTion(1)
 leXit = .F.
 = seTup()
* = loGin(.F.)
 cdUmmy = GetLangText("MAIN","TXT_LANGUAGE")
* READ EVENTS
 POP KEY
 RETURN .T.
ENDFUNC
*
FUNCTION vFoundation
 RETURN leXit
ENDFUNC
*
FUNCTION vClear
 CLEAR READ
 RETURN .T.
ENDFUNC
*
FUNCTION CheckNetID
 PRIVATE nlOcks
 nlOcks = 0
 SET REPROCESS TO 1
 IF (opEnfile(.F.,"Param") .AND. opEnfile(.F.,"License"))
      IF  .NOT. (SUBSTR(DBF("Param"), 1, 3)==SUBSTR(DBF("License"), 1, 3))
           = alErt("Missing license file!")
           = clEanup()
      ENDIF
      SELECT liCense
      GOTO TOP
      LOCATE FOR ALLTRIM(UPPER(lc_station))==wiNpc()
      IF ( .NOT. EOF())
           = acTion(3)
           IF ( .NOT. RLOCK())
                WAIT CLEAR
                WAIT WINDOW TIMEOUT 10  ;
                     "Brilliant is already running on this station!"+ ;
                     (CHR(13)+CHR(10))+"Unable to start Brilliant again"+ ;
                     (CHR(13)+CHR(10))+(CHR(13)+CHR(10))+ ;
                     "Use ALT+TAB to switch to Brilliant"
                = clEanup(.T.)
           ELSE
                SCATTER BLANK MEMVAR
                GATHER MEMVAR
           ENDIF
      ENDIF
      UNLOCK ALL
      DO WHILE (RECCOUNT()<=paRam.pa_maxuser+1)
           APPEND BLANK
           UNLOCK
      ENDDO
      GOTO TOP
      DO WHILE ( .NOT. EOF("License"))
           IF (RLOCK("license"))
                UNLOCK
           ELSE
                nlOcks = nlOcks+1
                IF (FILE("Hotel.Dbg"))
                     WAIT CLEAR
                     WAIT WINDOW NOWAIT "Locked:"+LTRIM(STR(nlOcks))
                ENDIF
           ENDIF
           SKIP 1 IN "License"
      ENDDO
      IF (nlOcks>=paRam.pa_maxuser)
           = alErt("No Available Network ID!")
           = clEanup()
      ENDIF
      GOTO TOP IN "license"
      DO WHILE ( .NOT. EOF("License"))
           IF RLOCK()
                EXIT
           ENDIF
           SKIP 1 IN "license"
      ENDDO
      IF (EOF("License"))
           = alErt("No Available Network ID!")
           = clEanup()
      ENDIF
      REPLACE liCense.lc_user WITH "STARTUP"
      REPLACE liCense.lc_date WITH DATE()
      REPLACE liCense.lc_time WITH TIME()
      REPLACE liCense.lc_station WITH wiNpc()
 ENDIF
 = clOsefile("Param")
 SET REPROCESS TO AUTOMATIC
 IF (FILE("Hotel.Dbg"))
      WAIT WINDOW NOWAIT "Total Locks is "+LTRIM(STR(nlOcks+1))
 ENDIF
 RETURN .T.
ENDFUNC
*
