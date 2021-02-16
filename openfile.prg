*Programm: Openfile.prg
 LPARAMETER leXclusive, caLias, lcHeckfiles, usenewway, nBufferMode, ctablealias, oDataEnv, oCursorAdapter
 PRIVATE caLiasdbf
 PRIVATE laLlopen
 PRIVATE ccDxname
 PRIVATE cdBfname
 PRIVATE ldIdclose
 PRIVATE cfIledbf
 PRIVATE cfIlecdx
 PRIVATE cfIlename
 PRIVATE loPened
 PRIVATE loPenerror
 PRIVATE cpAth
 PRIVATE nrEcno
 PRIVATE alGroup
 PRIVATE npArameters
 PRIVATE p_lOFRemoteTable
 LOCAL LProeceed, LUsenewway, LnBufferMode, l_lMakeTransacTable, l_cMainServerPath, l_lDontOpenLicence, l_lNoAliases, ;
           l_lSkip, l_cErrorText
 DO CASE
      CASE NOT Odbc()
      CASE EMPTY(caLias)
           _screen.oGlobal.oGData.StaticDataRefresh()
           SELECT files
           SCAN FOR UPPER(fi_name) = UPPER(fi_alias) AND fi_vfp AND fi_autopen AND _screen.oGlobal.oGData.UseTablesVfp(fi_name)
                OpenFile(leXclusive,ALLTRIM(fi_name))
           ENDSCAN
           RETURN .T.
      CASE _screen.oGlobal.oGData.UseTablesVfp(caLias)
      OTHERWISE
           OpenCommonTable(caLias,,oDataEnv, @oCursorAdapter)
           RETURN .T.
 ENDCASE
 l_cMainServerPath = ""
 LProeceed = .T.
 loPenerror = .F.
 DIMENSION alGroup[10]
 STORE .F. TO alGroup
 npArameters = PCOUNT()
 p_lOFRemoteTable = .F.
*WAIT WINDOW "openfile.prg!!!!!"
 DO CASE
      CASE NOT EMPTY(caLias) AND UPPER(ALLTRIM(caLias)) = "LICENSE" AND _screen.oGlobal.lblockusers
           * Open licenese table allways exclusive to block other users to login
           DO CASE
                CASE SET("Datasession")<>1
                     RETURN .T.
                CASE NOT USED("license")
                CASE ISEXCLUSIVE("license")
                     RETURN .T.
                CASE NOT ISEXCLUSIVE("license")
                     dclose("license")
           ENDCASE
           LUsenewway = .T.
           leXclusive = .T.
      CASE npArameters==0
           IF g_Lite
                leXclusive = .T.
           ELSE
                leXclusive = .F.
           ENDIF
           caLias = ""
           lcHeckfiles = .F.
           nBufferMode = 1
      CASE npArameters==1
           caLias = ""
           lcHeckfiles = .F.
           nBufferMode = 1
      CASE npArameters==2
           lcHeckfiles = .F.
           nBufferMode = 1
      CASE npArameters==3
           l_lDontOpenLicence = IIF(caLias=="LN",.T.,.F.)
           l_lNoAliases = IIF(caLias=="LN",.T.,.F.)
           caLias = ""
           leXclusive = .T.
           lcHeckfiles = .T.
           nBufferMode = 1
     CASE npArameters>=4
           lcHeckfiles = .F.
           LUsenewway = usenewway
           IF EMPTY(nBufferMode)
                nBufferMode = 1
           ENDIF
 ENDCASE
 IF LUsenewway
      LOCAL LCheck1, LAlias, LMacro
      IF !USED('files')
           openfiledirect(.F.,"files")
      ENDIF
      LAlias = UPPER(ALLTRIM(caLias))
      ctablealias = IIF(EMPTY(ctablealias),LAlias,ctablealias)
      IF !USED(ctablealias)
           LCheck1=SEEK(LAlias,'files','tag2')
           IF LCheck1
                IF "R" $ files.fi_flag
                     l_cMainServerPath = _screen.oGlobal.MainServerPathGet()
                     p_lOFRemoteTable = .T.
                ELSE
                     l_cMainServerPath = ""
                     p_lOFRemoteTable = .F.
                ENDIF
                LCheck1 = FILE(l_cMainServerPath+gcDatadir+LAlias+'.dbf')
                IF LCheck1
                     IF leXclusive
                          LMacro = 'USE "' + l_cMainServerPath + gcDatadir+LAlias+'" ALIAS '+ctablealias+' IN 0 EXCLUSIVE AGAIN'
                     ELSE
                          LMacro = 'USE "' + l_cMainServerPath + gcDatadir+LAlias+'" ALIAS '+ctablealias+' IN 0 SHARED AGAIN'
                     ENDIF
                     &LMacro
                     IF "T" $ files.fi_flag
                          SetTransactable(ctablealias)
                     ENDIF
                     LnBufferMode = IIF(npArameters = 5, nBufferMode, IIF("B" $ files.fi_flag, 5, 1))
                     IF BETWEEN(LnBufferMode, 2, 5)
                          CURSORSETPROP("Buffering",LnBufferMode,ctablealias)
                     ENDIF
                     = NetErr()
                     LCheck1 = USED(ctablealias)
                ENDIF
           ENDIF
      ELSE
           IF (npArameters = 5) AND BETWEEN(nBufferMode, 1, 5) AND nBufferMode <> CURSORGETPROP("Buffering", LAlias)
                CURSORSETPROP("Buffering", nBufferMode, LAlias)
           ENDIF
           LCheck1 = .T.
      ENDIF
      IF !LCheck1
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                IF lExclusive
                     l_cErrorText = LAlias+" "+GetLangText("OPENFILE", "TXT_CANNOTBEOPENEDEXCLUSIVE")
                ELSE
                     l_cErrorText = LAlias+" "+GetLangText("OPENFILE", "TXT_CANTBEOPENEDSHARED")
                ENDIF
                = loGdata(FNGetErrorHeader()+l_cErrorText+CHR(10), "hotel.err")
                = MESSAGEBOX(l_cErrorText, 48,GetLangText("OPENFILE","TXT_BRILLIANTERROR"))
           ENDIF
      ENDIF
      laLlopen = LCheck1
      loPenerror = .f.
 ELSE
      laLlopen = .F.
      loPened = .F.
      cfIledbf = gcDatadir+"files.dbf"
      cfIlecdx = gcDatadir+"files.cdx"
      cfieldsdbf = gcDatadir+"fields.dbf"
      cfieldscdx = gcDatadir+"fields.cdx"
      IF ( .NOT. FILE(cfIledbf))
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                = msGbox(GetLangText("OPENFILE","TXT_NOSYSTEMFILES"),GetLangText("OPENFILE", ;
                          "TXT_BRILLIANTERROR"),16)
           ENDIF
           = clEanup()
      ELSE
           = neTerr()
           IF ( .NOT. USED("Fields"))
                IF ( .NOT. FILE(cfieldscdx))
                     IF (dbUsearea(cfieldsdbf ,"Fields",.T.))
                         SELECT Fields
                         INDEX ON UPPER(fd_table+fd_name) TAG fiElds
                     ENDIF
                     = dcLose("Fields")
                ENDIF
           ENDIF
           IF ( .NOT. USED("Files"))
                IF ( .NOT. FILE(cfIlecdx))
                     IF (dbUsearea(cfIledbf,"Files",.T.))
                          SELECT Files
                          INDEX ON UPPER(fi_name) TAG taG1
                          INDEX ON UPPER(fi_alias) TAG taG2
                          INDEX ON STR(fi_group, 2) TAG taG3
                     ENDIF
                     = dcLose("Files")
                ENDIF
                = dbUsearea(cfIledbf,"Files")
                SELECT fiLes
                GOTO TOP
                nrEcno = 1
           ELSE
                SELECT fiLes
                nrEcno = RECNO()
           ENDIF
           IF ( .NOT. neTerr())
                SELECT fiLes
                IF (EMPTY(caLias))
                     SET ORDER TO Tag1
                     GOTO TOP
                ELSE
                     SET ORDER TO Tag2
                     = SEEK(UPPER(caLias), "Files")
                ENDIF
                DO WHILE ( .NOT. EOF("Files")) AND  LProeceed
                     caLiasdbf = ALLTRIM(fiLes.fi_alias)
                     cdBfname = ALLTRIM(fiLes.fi_name)
                    IF "R" $ files.fi_flag OR _screen.oGlobal.MainServerTables(cdBfname)
                         l_cMainServerPath = _screen.oGlobal.MainServerPathGet()
                         IF NOT _screen.oGlobal.lMainServerDirectoryAvailable OR EMPTY(l_cMainServerPath)
                              cpAth = gcDatadir
                         ELSE
                              cpAth = ADDBS(l_cMainServerPath)+"data\"
                         ENDIF
                         p_lOFRemoteTable = .T.
                         IF _screen.oGlobal.lmainserverremote
                              SELECT fiLes
                              IF ( .NOT. EOF("Files"))
                                   SKIP 1 IN fiLes
                              ENDIF
                              LOOP
                         ENDIF
                    ELSE
                         l_cMainServerPath = ""
                         cpAth = l_cMainServerPath+IIF("data"$LOWER(ALLTRIM(fiLes.fi_path)),gcDatadir,_screen.oGlobal.choteldir+ALLTRIM(fiLes.fi_path))
                         p_lOFRemoteTable = .F.
                    ENDIF
                     
                     cfIlename = cpAth+cdBfname+".DBF"
                     ccDxname = IIF( .NOT. EMPTY(fiLes.fi_key1), cpAth+ ;
                                cdBfname+".CDX", "")
                        LnBufferMode = IIF(npArameters = 5, nBufferMode, IIF("B" $ files.fi_flag, 5, 1))
                        l_lMakeTransacTable = ("T" $ files.fi_flag)
                     loPened = .F.
                     DO CASE
                          CASE l_lDontOpenLicence AND cdBfname = "LICENSE "
                               * Skip license table
                          CASE  .NOT. FILE(cfIlename)
                               DO CASE
                                    CASE lcHeckfiles
                                    CASE fiLes.fi_autopen .AND. EMPTY(caLias)
                                         IF NOT _screen.oGlobal.lDoAuditOnStartup
                                              = msGbox(cfIlename+" "+ ;
                                                        GetLangText("OPENFILE","TXT_DOESNOTEXIST"), ;
                                                        GetLangText("OPENFILE","TXT_BRILLIANTERROR"),16)
                                         ENDIF
                                         = clEanup()
                                    CASE  .NOT. EMPTY(caLias)
                                         IF (WLAST()<>"WIDXREBUIL" .AND.  ;
                                            WLAST()<>"WTALK")
                                              IF NOT _screen.oGlobal.lDoAuditOnStartup
                                                   = msGbox(cfIlename+" "+ ;
                                                             GetLangText("OPENFILE", ;
                                                             "TXT_DOESNOTEXIST"), ;
                                                             GetLangText("OPENFILE", ;
                                                             "TXT_BRILLIANTERROR"),48)
                                              ENDIF
                                         ENDIF
                                         EXIT
                               ENDCASE
                          CASE (leXclusive .AND. ((fiLes.fi_autopen .AND.  ;
                               EMPTY(caLias)) .OR.  .NOT. EMPTY(caLias)))
                               l_lSkip = .F.
                               IF l_lNoAliases
                                    IF ALLTRIM(UPPER(cdBfname))<>ALLTRIM(UPPER(caLiasdbf))
                                         l_lSkip = .T.
                                    ENDIF
                               ENDIF
                               IF NOT l_lSkip
                                    IF (USED(caLiasdbf))
                                         SELECT (caLiasdbf)
                                         USE
                                         ldIdclose = .T.
                                    ELSE
                                         ldIdclose = .F.
                                    ENDIF
                                    IF (UPPER(caLiasdbf)<>UPPER(RIGHT(cdBfname,  ;
                                       LEN(caLiasdbf))))
                                         = dbUsearea(cfIlename,caLiasdbf,.T.,.T.,0,LnBufferMode,l_lMakeTransacTable)
                                    ELSE
                                         = dbUsearea(cfIlename,caLiasdbf,.T.,.F.,0,LnBufferMode,l_lMakeTransacTable)
                                    ENDIF
                                    IF (neTerr())
                                         IF (ldIdclose)
                                              ldIdclose = .F.
                                              IF (caLiasdbf<>cdBfname)
                                                   = dbUsearea(cfIlename,caLiasdbf, ;
                                                    .F.,.T.,0,LnBufferMode,l_lMakeTransacTable)
                                              ELSE
                                                   = dbUsearea(cfIlename,caLiasdbf, ;
                                                    .F.,.F.,0,LnBufferMode,l_lMakeTransacTable)
                                              ENDIF
                                         ENDIF
                                         IF ( .NOT. lcHeckfiles)
                                              IF NOT _screen.oGlobal.lDoAuditOnStartup
                                                   l_cErrorText = cfIlename+" "+ ;
                                                             GetLangText("OPENFILE", ;
                                                             "TXT_CANNOTBEOPENEDEXCLUSIVE")
                                                   = msGbox(l_cErrorText, GetLangText("OPENFILE","TXT_BRILLIANTERROR"),48)
                                                   = loGdata(FNGetErrorHeader()+l_cErrorText+CHR(10), "hotel.err")
                                              ENDIF
                                         ELSE
                                              loPenerror = .T.
                                         ENDIF
                                    ELSE
                                         laLlopen = .T.
                                         loPened = .T.
                                    ENDIF
                               ENDIF
                          CASE ( .NOT. leXclusive .AND. ((fiLes.fi_autopen  ;
                               .AND. EMPTY(caLias)) .OR.  .NOT. EMPTY(caLias)))
                               IF (USED(caLiasdbf))
                                    SELECT (caLiasdbf)
                                    USE
                               ENDIF
                               IF (UPPER(caLiasdbf)<>UPPER(RIGHT(cdBfname,  ;
                                  LEN(caLiasdbf))))
                                    = dbUsearea(cfIlename,caLiasdbf,.F.,.T.,0,LnBufferMode,l_lMakeTransacTable)
                               ELSE
                                    DO CASE
                                         CASE  .NOT. EMPTY(ccDxname) .AND.   ;
                                          .NOT. FILE(ccDxname)
                                              = dbUsearea(cfIlename,caLiasdbf,.T.)
                                              = crEatinx(.F.,RECNO("Files"))
                                              SELECT (caLiasdbf)
                                              USE
                                         CASE lcHeckfiles
                                              = dbUsearea(cfIlename,caLiasdbf,.T.)
                                              FOR ntAgcount = 1 TO 45
                                                   ckEymacro = "Files.Fi_Key"+ ;
                                                    LTRIM(STR(ntAgcount))
                                                   If ( !Empty(&cKeyMacro) )
                                                        SELECT (caLiasdbf)
                                                        IF (EMPTY(KEY(ntAgcount)))
                                                             = crEatinx(.F., ;
                                                              RECNO("Files"))
                                                             EXIT
                                                        ENDIF
                                                   ENDIF
                                              ENDFOR
                                              SELECT (caLiasdbf)
                                              USE
                                    ENDCASE
                                    = dbUsearea(cfIlename,caLiasdbf,.F.,.F.,0,LnBufferMode,l_lMakeTransacTable)
                               ENDIF
                               IF (neTerr())
                                    IF NOT _screen.oGlobal.lDoAuditOnStartup
                                         l_cErrorText = cfIlename+" "+GetLangText("OPENFILE", ;
                                                   "TXT_CANTBEOPENEDSHARED")
                                         = loGdata(FNGetErrorHeader()+l_cErrorText+CHR(10), "hotel.err")
                                         = msGbox(l_cErrorText, GetLangText("OPENFILE","TXT_BRILLIANTERROR"),48)
                                    ENDIF
                               ELSE
                                    laLlopen = .T.
                                    loPened = .T.
                               ENDIF
                          CASE ( .NOT. fiLes.fi_autopen)
                               IF ( .NOT. EMPTY(fiLes.fi_key1) .AND.  .NOT.  ;
                                  FILE(ccDxname))
                                    = dbUsearea(cfIlename,caLiasdbf,.T.)
                                    = crEatinx(.F.,RECNO("Files"))
                                    SELECT (caLiasdbf)
                                    USE
                               ENDIF
                               loPened = .F.
                     ENDCASE
                     IF loPened AND NOT("N" $ files.fi_flag) AND NOT EMPTY(fiLes.fi_key1)
                          SELECT (caLiasdbf)
                          IF (EMPTY(TAG(1)))
                               IF ( .NOT. leXclusive)
                                    = crEatinx(.F.,RECNO("Files"))
                               ENDIF
                          ELSE
                               SET ORDER TO 1
                          ENDIF
                     ENDIF
                     IF ( .NOT. EMPTY(caLias))
                          EXIT
                     ENDIF
                     SELECT fiLes
                     IF ( .NOT. EOF("Files"))
                          SKIP 1 IN fiLes
                     ENDIF
                ENDDO
           ENDIF
           SELECT fiLes
           IF nrEcno<=RECCOUNT()
                GOTO nrEcno
           ENDIF
           SET ORDER TO Tag1
      ENDIF
 ENDIF
 RETURN laLlopen .AND. ( .NOT. loPenerror)
ENDFUNC
*
FUNCTION DefaultLanguage
 PRIVATE crEturn
 DIMENSION acLanguages[9]
 acLanguages[1] = "ENG"
 acLanguages[2] = "DUT"
 acLanguages[3] = "GER"
 acLanguages[4] = "FRE"
 acLanguages[5] = "INT"
 acLanguages[6] = "SER"
 acLanguages[7] = "POR"
 acLanguages[8] = "ITA"
 acLanguages[9] = "POL"
 IF ( .NOT. USED("Param"))
      = opEnfile(.F.,"Param")
      crEturn = ASCAN(acLanguages, paRam.pa_lang)
      = clOsefile("Param")
 ELSE
      crEturn = ASCAN(acLanguages, paRam.pa_lang)
 ENDIF
 RETURN crEturn
ENDFUNC
*
FUNCTION UsersLogedIn
 PRIVATE nrEturn
 nrEturn = 0
 IF (USED("license"))
      nlCrecord = RECNO("License")
      GOTO TOP IN liCense
      DO WHILE  .NOT. EOF("License")
           IF  .NOT. EMPTY(liCense.lc_station)
                nrEturn = nrEturn+1
           ENDIF
           SKIP 1 IN liCense
      ENDDO
      GOTO nlCrecord IN liCense
 ENDIF
 RETURN nrEturn
ENDFUNC
*
