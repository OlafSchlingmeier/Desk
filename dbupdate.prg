 #INCLUDE "common\progs\cryptor.h"
 #INCLUDE "include\constdefines.h"
 # DEFINE DB_UNKNOWN      0
 # DEFINE DB_LOWER_VER    1
 # DEFINE DB_EQUAL_VER    2
 # DEFINE DB_HIGHIER_VER  3
 # DEFINE DB_UPDATE_BACKUP_DIR "BACKUP"
 *
 PRIVATE cuPdatefile
 PRIVATE p_cCurReindex
 PRIVATE p_cBackupFolder
 p_cCurReindex = ""
 p_cBackupFolder = ""
 LOCAL l_lCheckConst, l_lAvlRebuild, l_lOnlyTables, l_cVerMsg

 IF DBVersionOK()
      DBCheckAfterUpdateFirstStart()
      RETURN .T.
 ENDIF

 l_cVerMsg = "DB: " + FormatVersion(GetDBVersion()) + CHR(13) + ;
           "AP: " + FormatVersion(GetFileVersion(APP_EXE_NAME))

 IF NOT yesno(getapplangtext("DBUPDATE","VERSION_CHANGE_DETECTED") + CHR(13) + CHR(13) + ;
           l_cVerMsg)
      RETURN .F.
 ENDIF

 DBShowProgress("START")

 cuPdatefile = "Hotel.Upd"
 = loGdata("Starting file update",cuPdatefile)
 = loGdata(l_cVerMsg,cuPdatefile)
 = loGdata(DTOC(DATE())+"/ "+TIME(),cuPdatefile)

 IF NOT DBBlockOtherWorkStations()
      RETURN .F.
 ENDIF

 IF NOT OpenAllTablesExclusive()
      RETURN .F.
 ENDIF

 CreateBackupFolder()
 
 CreateReindexCursor()
 
 BeforeUpdateDataToVersion()
 
 GenerateUpdate()

 DBCheckStructure()

 DBOdbcSynchronize()

 ProcArchive("CheckStructure")
 
 l_lOnlyTables = .T.
 CloseAllFiles(l_lOnlyTables, "[license]")
 
 IF NOT odbc()
      ProcCryptor(CR_ENCODE)
 ENDIF
 
 DBShowProgress()
 IF NOT odbc()
      DBReindexRest()
 ENDIF
 
 DBUpdateLists()
 
 AfterUpdateDataToVersion(@l_lCheckConst, @l_lAvlRebuild)
 IF NOT odbc()
      DoCreatinxAfter(l_lCheckConst, l_lAvlRebuild)
 ENDIF
 IF NOT odbc()
      * TO DO: add support for odbc!

      DO plDefaults IN MgrPList
 
      CheckIfRecordsExits()
 ENDIF
 SetExeToDBVersion()
 
 DBCopyNewExe()

 DBCheckCodePage()

 DBShowProgress("END")

 l_lOnlyTables = .F.
 CloseAllFiles(l_lOnlyTables, "[license]")
 DBUnlockOtherWorkStations()
 
 = loGdata("Finished file update",cuPdatefile)
 = loGdata(DTOC(DATE())+"/ "+TIME(),cuPdatefile)
 
 * We need to refresh it here too, when some new fields are added in older version
 _screen.oGlobal.RefreshTableParam()
 _screen.oGlobal.RefreshTableParam2()
 
 RETURN .T.
ENDFUNC
*
PROCEDURE DBOdbcSynchronize
 LOCAL l_lOldODBC
 IF _screen.oGlobal.lODBCSYNC
      l_lOldODBC = Odbc()
      SetODBC(.T.)
      DBCheckStructure()
      _screen.oGlobal.oGData.ReleaseHandles()
      SetODBC(l_lOldODBC)
 ENDIF
ENDPROC
*
PROCEDURE DBCheckStructure

 ***
 *** Main part for database structure changes
 ***
 IF odbc()
      DBCheckStructureOdbcRemoveDependencies()
      DBCheckStructureOdbc()
      DBCheckStructureOdbcTableIndexes()
      DBCheckStructureOdbcDoOnEveryUpdate()
      DBCheckStructureOdbcSource()
      RETURN .T.
 ENDIF
 PRIVATE cdBfname
 PRIVATE lnEwfile
 PRIVATE cfIeld
 PRIVATE lfIeldorderchange
 PRIVATE ncUrrent
 PRIVATE lcHangedfieldtype
 LOCAL l_cExclusive
 l_cExclusive = SET("Exclusive")
 SET EXCLUSIVE ON
 USE (gcDatadir+'Fields') IN 0
 SELECT fiElds
 DELETE TAG alL
 INDEX ON UPPER(fd_table+fd_name) TAG fiElds
 SET ORDER TO 1
 USE (gcDatadir+'Files') IN 0
 SELECT fiLes
 DELETE TAG alL
 INDEX ON UPPER(fi_name) TAG taG1
 INDEX ON UPPER(fi_alias) TAG taG2
 INDEX ON STR(fi_group, 2) TAG taG3
 SET ORDER TO 1
 SELECT fiElds
 GOTO TOP IN "Fields"
 DO WHILE ( .NOT. EOF("Fields"))
      lfIeldorderchange = .F.
      lnEwfile = .F.
      cdBfname = UPPER(TRIM(fiElds.fd_table))
      IF ( .NOT. SEEK(cdBfname, "Files"))
           WAIT WINDOW TIMEOUT 3 cdBfname+" NOT in Files.Dbf!"
           = loGdata("File "+cdBfname+" not in Files.Dbf!",cuPdatefile)
           DO WHILE (UPPER(TRIM(fiElds.fd_table))==cdBfname)
                SKIP 1 IN fiElds
           ENDDO
      ELSE
           IF cdBfname == "LICENSE"
                * dont update this table
                DO WHILE (UPPER(TRIM(fiElds.fd_table))==cdBfname)
                     SKIP 1 IN fiElds
                ENDDO
                LOOP
           ENDIF
           IF NOT _screen.oGlobal.lUseMainServer
                * Normal installation. Update all tables.
                ctHename = DBCheckStructureGetDBFFullPath()
           ELSE
                * Multiproper installlation!
                IF "R" $ files.fi_flag
                     IF NOT _screen.oGlobal.lmultiproper
                          * Only on multiproper exe update of remote tables is enabled!
                          DO WHILE (UPPER(TRIM(fiElds.fd_table))==cdBfname)
                               SKIP 1 IN fiElds
                          ENDDO
                          LOOP
                     ENDIF
                ENDIF
                ctHename = DBCheckStructureGetDBFFullPath()
           ENDIF

           = loGdata("File:"+ctHename,cuPdatefile)
           IF ( .NOT. FILE(ctHename+".Dbf"))
                = loGdata("..New file.",cuPdatefile)
                WAIT WINDOW NOWAIT "Creating "+ctHename+".Dbf"
                CREATE CURSOR Struct (fiEld_name C (128), fiEld_type C  ;
                       (1), fiEld_len N (3, 0), fiEld_dec N (3, 0),  ;
                       fiEld_null L, fiEld_nocp L, fiEld_defa M,  ;
                       fiEld_rule M, fiEld_err M, taBle_rule M, taBle_err  ;
                       M, taBle_name C (128), inS_trig M, upD_trig M,  ;
                       deL_trig M, taBle_cmt M)
                COPY TO TMPSTRUC STRUCTURE
                USE
                USE EXCLUSIVE TMPSTRUC ALIAS stRuct IN 0
                SELECT stRuct
                DO WHILE (UPPER(TRIM(fiElds.fd_table))==cdBfname)
                     INSERT INTO Struct (fiEld_name, fiEld_type,  ;
                            fiEld_len, fiEld_dec, fiEld_nocp) VALUES (fiElds.fd_name,  ;
                            fiElds.fd_type, fiElds.fd_len, fiElds.fd_dec, ;
                            DBCheckNoCapsFlagForField(fiElds.fd_name) ;
                            )
                     SKIP 1 IN "Fields"
                ENDDO
                SELECT stRuct
                USE
                CREATE (ctHename) FROM TMPSTRUC
                SELECT (cdBfname)
                USE
                DELETE FILE TMPSTRUC.DBF
                DELETE FILE TMPSTRUC.FPT
                WAIT CLEAR
                = loGdata("..File created.",cuPdatefile)
                * Generate Index
                IF OpenFile(.F.,cdBfname)
                     CloseFile(cdBfname)
                ENDIF
                SELECT 0
           ELSE
                = loGdata("..File exists.",cuPdatefile)
                IF (cdBfname=="SHEET" OR cdBfname=="HSHEET")
                     = loGdata( ;
                       "..Skipping " + cdBfname + ", it's user defined.",cuPdatefile)
                     SKIP 1 IN fields
                ELSE
                     WAIT WINDOW NOWAIT "Checking "+cdBfname+".DBF"
                     USE (ctHename) IN 0
                     SELECT (cdBfname)
                     COPY TO TMPSTRUC STRUCTURE EXTENDED
                     USE
                     USE EXCLUSIVE TMPSTRUC ALIAS stRuct IN 0
                     SELECT stRuct
                     REPLACE fiEld_dec WITH 000 ALL FOR INLIST(fiEld_type,  ;
                             "L", "D", "C", "M")
                     nfIeldcounter = 1
                     lcHangedfieldtype = .F.
                     SELECT fiElds
                     DO WHILE (UPPER(TRIM(fiElds.fd_table))==cdBfname)
                          cfIeld = UPPER(TRIM(fiElds.fd_name))
                          SELECT stRuct
                          LOCATE ALL FOR UPPER(TRIM(stRuct.fiEld_name))==cfIeld
                          DO CASE
                               CASE  .NOT. FOUND("Struct")
                                    = loGdata("..New field: "+cfIeld+", "+ ;
                                      fiElds.fd_type+", "+ ;
                                      STR(fiElds.fd_len, 4)+", "+ ;
                                      STR(fiElds.fd_dec, 2)+".",cuPdatefile)
                                    INSERT INTO Struct (fiEld_name,  ;
                                     fiEld_type, fiEld_len, fiEld_dec, fiEld_nocp)  ;
                                     VALUES (fiElds.fd_name,  ;
                                     fiElds.fd_type, fiElds.fd_len,  ;
                                     fiElds.fd_dec, DBCheckNoCapsFlagForField(fiElds.fd_name))
                                    lnEwfile = .T.
                               CASE Struct.field_type # Fields.fd_type OR ;
                                         Struct.field_len # Fields.fd_len AND INLIST(Struct.field_type, "C", "N", "F", "Q", "V") OR ;
                                         Struct.field_dec # Fields.fd_dec AND INLIST(Struct.field_type, "B", "N", "F")
                                    = loGdata("..Field change from: "+ ;
                                      cfIeld+", "+stRuct.fiEld_type+", "+ ;
                                      STR(stRuct.fiEld_len, 4)+", "+ ;
                                      STR(stRuct.fiEld_dec, 2)+".",cuPdatefile)
                                    = loGdata("..Field change to  : "+ ;
                                      cfIeld+", "+fiElds.fd_type+", "+ ;
                                      STR(fiElds.fd_len, 4)+", "+ ;
                                      STR(fiElds.fd_dec, 2)+".",cuPdatefile)
                                    lcHangedfieldtype = lcHangedfieldtype OR ;
                                         (Fields.fd_type <> Struct.Field_type)
                                    REPLACE stRuct.fiEld_type WITH  ;
                                     fiElds.fd_type
                                    REPLACE stRuct.fiEld_len WITH fiElds.fd_len
                                    REPLACE stRuct.fiEld_dec WITH fiElds.fd_dec
                                    REPLACE stRuct.fiEld_nocp WITH DBCheckNoCapsFlagForField(fiElds.fd_name)
                                    lnEwfile = .T.
                               CASE UPPER(ALLTRIM(stRuct.fiEld_name))<>cfIeld
                                    lnEwfile = .T.
                                    lfIeldorderchange = .T.
                          ENDCASE
                          nfIeldcounter = nfIeldcounter+1
                          SELECT fiElds
                          SKIP 1 IN "Fields"
                     ENDDO
                     IF (lfIeldorderchange)
                          = loGdata( ;
                            "..Field order change, complete file will be recreated!", ;
                            cuPdatefile)
                     ENDIF
                     SELECT fiElds
                     ncUrrent = IIF(EOF(), 0, RECNO())
                     * Check if some field should be deleted from database
                     SELECT stRuct
                     GOTO TOP
                     DO WHILE ( .NOT. EOF("Struct"))
                          IF ( .NOT. SEEK(UPPER(PADR(cdBfname, 8)+PADR(stRuct.fiEld_name, 10)), "Fields"))
                               = loGdata(".."+ALLTRIM(stRuct.fiEld_name)+ " is not used anymore, and was automaticly deleted!",cuPdatefile)
                               SELECT stRuct
                               DELETE
                               lnEwfile = .T.
                          ENDIF
                          SKIP 1 IN stRuct
                     ENDDO
                     SELECT fiElds
                     IF (ncUrrent==0)
                          GOTO BOTTOM
                          SKIP 1
                     ELSE
                          GOTO ncUrrent
                     ENDIF
                     SELECT stRuct
                     PACK TABLE
                     USE
                     IF (lnEwfile)
                          WAIT WINDOW NOWAIT "Updating "+cdBfname+".DBF"
                          = dbFupdate(cdBfname,cuPdatefile, ;
                            lcHangedfieldtype,ctHename)
                     ENDIF
                ENDIF
           ENDIF
      ENDIF
      = loGdata("",cuPdatefile)
 ENDDO
 
 closefile('TMPSTRUC.DBF')
 closefile('TMPSTRUC.FPT')
 closefile('TMPSORT.DBF')
 closefile('TMPSORT.FPT')
 = fiLedelete('TMPSTRUC.DBF')
 = fiLedelete('TMPSTRUC.FPT')
 = fiLedelete('TMPSORT.DBF')
 = fiLedelete('TMPSORT.FPT')
 SET EXCLUSIVE &l_cExclusive
ENDPROC
*
PROCEDURE DBCheckNoCapsFlagForField
LPARAMETERS lp_cFdName
RETURN IIF(INLIST(lp_cFdName,"ER_CCNUM  ","ER_CCEXPY ","ER_CCCVC  ","RS_CCAUTH ","RS_CCEXPY ","RS_CCNUM  ","HR_CCAUTH ","HR_CCEXPY ","HR_CCNUM  "),.T.,.F.)
ENDPROC
*
PROCEDURE DBCheckStructureGetDBFFullPath
LOCAL l_cFile
 IF "data" $ LOWER(fiLes.fi_path)
      l_cFile = gcDatadir+cdBfname
 ELSE
      l_cFile = _screen.oGlobal.choteldir+ALLTRIM(fiLes.fi_path)+cdBfname
 ENDIF
RETURN l_cFile
ENDPROC
*
FUNCTION DbfUpdate
 PARAMETER cdBftodo, cuPdatefile, lfIeldchange, ctHedbf
 LOCAL l_cPath, l_cName
 PRIVATE ctMpdbfname
 PRIVATE ctMpfptname
 PRIVATE cdBfname
 PRIVATE cfPtname
 PRIVATE cCdxname
 ctMpdbfname = "Tmp00001.Dbf"
 ctMpfptname = "Tmp00001.Fpt"
 cdBfname = ctHedbf+".Dbf"
 cfPtname = ctHedbf+".Fpt"
 cCdxname = ctHedbf+".Cdx"
 IF (FILE(ctMpdbfname))
      DELETE FILE (ctMpdbfname)
 ENDIF
 IF (FILE(ctMpfptname))
      DELETE FILE (ctMpfptname)
 ENDIF
 USE TmpStruc ALIAS stRuct IN 0
 SELECT stRuct
 SORT TO TmpSort  ON fiEld_name
 USE
 = loGdata("..Create "+ctMpdbfname+".",cuPdatefile)
 CREATE (ctMpdbfname) FROM TmpSort
 USE
 USE (ctMpdbfname) ALIAS tmPf IN 0
 SELECT tmPf
 IF ( .NOT. lfIeldchange)
      APPEND FROM (ctHedbf)
 ELSE
      WAIT WINDOW NOWAIT "Field Type Change...."
      USE (ctHedbf) ALIAS srCf IN 0
      SELECT srCf
      GOTO TOP
      DO WHILE ( .NOT. EOF())
           IF (MOD(RECNO(), 10)==0)
                WAIT WINDOW NOWAIT ALLTRIM(cdBftodo)+" "+LTRIM(STR(RECNO()))
           ENDIF
           SELECT tmPf
           APPEND BLANK
           FOR ni = 1 TO FCOUNT("Tmpf")
                ciNmacro = "Srcf."+FIELD(ni)
                coUtmacro = "Tmpf."+FIELD(ni)
                DO CASE
                     CASE (TYPE(coUtmacro)==TYPE(ciNmacro))
                          Replace &cOutMacro With &cInMacro
                     CASE (TYPE(coUtmacro)=="C" .AND. TYPE(ciNmacro)=="N")
                          Replace &cOutMacro With AllTrim(Str(&cInMacro))
                     CASE (TYPE(coUtmacro)=="N" .AND. TYPE(ciNmacro)=="C")
                          Replace &cOutMacro With Val(&cInMacro)
                     CASE (TYPE(coUtmacro)=="D" .AND. TYPE(ciNmacro)=="C")
                          Replace &cOutMacro With CtoD(&cInMacro)
                     CASE (TYPE(coUtmacro)=="C" .AND. TYPE(ciNmacro)=="D")
                          Replace &cOutMacro With DtoC(&cInMacro)
                     CASE (TYPE(coUtmacro)=="L" .AND. TYPE(ciNmacro)=="C")
                          Replace &cOutMacro With (&cInMacro == "Y")
                     CASE (TYPE(coUtmacro)=="L" .AND. TYPE(ciNmacro)=="N")
                          Replace &cOutMacro With (&cInMacro != 0)
                     CASE (TYPE(coUtmacro)=="M" .AND. TYPE(ciNmacro)=="C")
                          Replace &cOutMacro With &cInMacro
                     CASE (TYPE(coUtmacro)=="M" .AND. TYPE(ciNmacro)=="N")
                          Replace &cOutMacro With AllTrim(Str(&cInMacro))
                     CASE (TYPE(coUtmacro)=="C" .AND. TYPE(ciNmacro)=="M")
                          Replace &cOutMacro With &cInMacro
                     OTHERWISE
                ENDCASE
           ENDFOR
           SELECT srCf
           SKIP 1
      ENDDO
      WAIT CLEAR
      SELECT srCf
      USE
 ENDIF
 = loGdata("..Appended "+LTRIM(STR(RECCOUNT()))+" records from "+ ;
   ctMpdbfname+".",cuPdatefile)
 SELECT tmPf
 USE
 l_cPath = JUSTPATH(cdBfname)+"\"
 l_cName = JUSTSTEM(cdBfname)
 ProcCryptor(CR_UNREGISTER, l_cPath, l_cName)
 = fiLedelete(cdBfname)
 = fiLedelete(cfPtname)
 = fiLedelete(cCdxname)
 IF (FILE(ctMpdbfname) .AND.  .NOT. FILE(cdBfname))
      COPY FILE (ctMpdbfname) TO (cdBfname)
 ENDIF
 IF (FILE(ctMpfptname) .AND.  .NOT. FILE(cfPtname))
      COPY FILE (ctMpfptname) TO (cfPtname)
 ENDIF
 IF OpenFile(.F.,l_cName)
      CloseFile(l_cName)
      IF TYPE("p_cCurReindex")="C" AND NOT EMPTY(p_cCurReindex) AND USED(p_cCurReindex)
           DELETE FOR fi_name == PADR(l_cName,8) IN &p_cCurReindex
      ENDIF
 ENDIF
 = fiLedelete(ctMpdbfname)
 = fiLedelete(ctMpfptname)
 = fiLedelete("TmpStruc.DBF")
 = fiLedelete("TmpStruc.FPT")
 = fiLedelete("TmpSort.DBF")
 = fiLedelete("TmpSort.FPT")
 RETURN .T.
ENDFUNC
*
PROCEDURE DBCheckStructureOdbc
 LOCAL l_cSql, l_cType, l_nLen, l_nDec, l_lSkipTable, l_lArchive

 WAIT WINDOW "Chacking for database structure changes..." NOWAIT

 l_lArchive = TYPE("plTemporalOdbcForArchiving") = "L" AND plTemporalOdbcForArchiving     && Archiving sequence
 SELECT fd_table, fd_name, fd_type, fd_len, fd_dec, fi_unikey FROM files ;
     INNER JOIN fields ON fi_name = fd_table ;
     WHERE ALLTRIM(LOWER(fi_name)) == ALLTRIM(LOWER(fi_alias)) AND NOT fi_vfp AND (NOT l_lArchive OR 'A' $ fi_flag) ;
     ORDER BY 1,2 ;
     INTO CURSOR curflfd8 READWRITE

 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
 SELECT CAST(UPPER(table_name) AS Char(8)) AS fd_table, 
     CAST(UPPER(column_name) AS Char(10)) AS fd_name, 
     CAST('' AS Char(1)) AS fd_type, 
     CAST(0 AS Numeric(4)) AS fd_len, 
     CAST(COALESCE(numeric_scale,0) AS Numeric(4)) AS fd_dec, 
     CAST(UPPER(data_type) AS Char(30)) AS fd_otype, 
     CAST(COALESCE(character_maximum_length,0) AS Numeric(4)) AS fd_clen, 
     CAST(COALESCE(numeric_precision,0) AS Numeric(4)) AS fd_nlen 
     FROM information_schema.columns WHERE table_schema='desk<<IIF(EMPTY(gcHotCode), "", "_"+LOWER(gcHotCode))>>' AND is_updatable='YES' 
     ORDER BY 1,2;
 ENDTEXT

 IF USED("odbcdb7")
     USE IN odbcdb7
 ENDIF
 sqlcursor(l_cSql,"odbcdb7")

 SELECT odbcdb7
 SCAN ALL
     =DBCheckStructureOdbcGetTypeAndLen(@l_cType, @l_nLen, @l_nDec)
     REPLACE fd_type WITH l_cType, fd_len WITH l_nLen, fd_dec WITH l_nDec
 ENDSCAN

 * Fix dec for double
 REPLACE fd_dec WITH 0 FOR fd_type = "B" IN curflfd8

 SELECT curflfd8
 l_lSkipTable = ""
 SCAN ALL
     WAIT WINDOW "Checking " + " " + fd_name + " " + fd_table NOWAIT
     IF NOT EMPTY(l_lSkipTable)
          IF curflfd8.fd_table = l_lSkipTable
               LOOP
          ELSE
               * we are over another table now
               l_lSkipTable = ""
          ENDIF
     ENDIF
     l_cAction = ""
     SELECT odbcdb7
     LOCATE FOR fd_table = curflfd8.fd_table
     IF FOUND()
          LOCATE FOR fd_table = curflfd8.fd_table AND fd_name = curflfd8.fd_name
          IF FOUND()
               IF fd_type <> curflfd8.fd_type OR fd_len <> curflfd8.fd_len OR fd_dec <> curflfd8.fd_dec
                    l_cAction = "ALTER"
               ENDIF
          ELSE
               l_cAction = "ADD"
          ENDIF
     ELSE
          l_cAction = "CREATE"
     ENDIF
     IF NOT EMPTY(l_cAction)
          ASSERT .F. MESSAGE curflfd8.fd_table + " " + curflfd8.fd_name + "|" + l_cAction
          DBCheckStructureOdbcUpdate(l_cAction)
          IF l_cAction = "CREATE"
               * Skip to next table
               l_lSkipTable = curflfd8.fd_table
          ENDIF
     ENDIF
 ENDSCAN

dclose("odbcdb7")
dclose("curflfd8")
dclose("cresult")
dclose("cmytbl1")
WAIT CLEAR
RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcGetTypeAndLen
LPARAMETERS lp_cType, lp_nLen, lp_nDec
lp_cType = ""
lp_nLen = 0
lp_nDec = fd_dec
DO CASE
     CASE fd_otype = "BOOLEAN"
          lp_cType = "L"
          lp_nLen = 1
     CASE fd_otype = "CHARACTER"
          lp_cType = "C"
          lp_nLen = fd_clen
     CASE fd_otype = "DATE"
          lp_cType = "D"
          lp_nLen = 8
     CASE fd_otype = "DOUBLE PRECISION"
          lp_cType = "B"
          lp_nLen = 8
     CASE fd_otype = "INTEGER"
          lp_cType = "I"
          lp_nLen = 4
     CASE fd_otype = "NUMERIC" AND fd_nlen = 15 AND fd_dec = 4
          lp_cType = "Y"
          lp_nLen = 0
          lp_nDec = 0
     CASE fd_otype = "NUMERIC"
          lp_cType = "N"
          lp_nLen = fd_nlen
     CASE fd_otype = "TEXT"
          lp_cType = "M"
          lp_nLen = 4
     CASE fd_otype = "TIMESTAMP WITHOUT TIME ZONE"
          lp_cType = "T"
          lp_nLen = 8
ENDCASE
RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcConvertVfpToOdbc
LPARAMETERS lp_cType, lp_cDefault, lp_cUsing, lp_cAlias
IF EMPTY(lp_cAlias)
     lp_cAlias = "curflfd8"
ENDIF
DO CASE
     CASE &lp_cAlias..fd_type = "L"
          lp_cType = "BOOLEAN"
          lp_cDefault = "false"
     CASE &lp_cAlias..fd_type = "C"
          lp_cType = "CHARACTER(" + TRANSFORM(&lp_cAlias..fd_len) + ")"
          lp_cDefault = "''"
     CASE &lp_cAlias..fd_type = "D"
          lp_cType = "DATE"
          lp_cDefault = "'1611-11-11'::date"
     CASE &lp_cAlias..fd_type = "B"
          lp_cType = "DOUBLE PRECISION"
          lp_cDefault = "0"
     CASE &lp_cAlias..fd_type = "I"
          lp_cType = "INTEGER"
          lp_cDefault = "0"
     CASE &lp_cAlias..fd_type = "N"
          lp_cType = "NUMERIC(" + TRANSFORM(&lp_cAlias..fd_len) + IIF(EMPTY(&lp_cAlias..fd_dec),"",","+TRANSFORM(&lp_cAlias..fd_dec)) + ")"
          lp_cDefault = "0"
     CASE &lp_cAlias..fd_type = "M"
          lp_cType = "TEXT"
          lp_cDefault = "''"
     CASE &lp_cAlias..fd_type = "T"
          lp_cType = "TIMESTAMP WITHOUT TIME ZONE"
          lp_cDefault = "'1611-11-11 11:11:11'::timestamp without time zone"
     CASE &lp_cAlias..fd_type = "Y"
          lp_cType = "NUMERIC(15,4)"
          lp_cDefault = "0"
ENDCASE
lp_cUsing = lp_cType
RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcUpdate
LPARAMETERS lp_cAction
DO CASE 
     CASE lp_cAction = "ADD"
          DBCheckStructureOdbcUpdateAdd()
     CASE lp_cAction = "ALTER"
          DBCheckStructureOdbcUpdateAlter()
     CASE lp_cAction = "CREATE"
          DBCheckStructureOdbcUpdatCreate()
ENDCASE
RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcUpdateAdd
LOCAL l_cSql, l_cType, l_cDefault, l_cUsing

DBCheckStructureOdbcConvertVfpToOdbc(@l_cType, @l_cDefault, @l_cUsing)

TEXT TO l_cSql TEXTMERGE  NOSHOW PRETEXT 15
ALTER TABLE <<_screen.oGlobal.oGData.CheckTableName(ALLTRIM(LOWER(curflfd8.fd_table)))>> 
     ADD COLUMN <<ALLTRIM(LOWER(curflfd8.fd_name))>> <<l_cType>> DEFAULT <<l_cDefault>> NOT NULL;
ENDTEXT
sqlcursor(l_cSql, "cresult")

RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcUpdateAlter
LOCAL l_cSql, l_cType, l_cDefault, l_cUsing

DBCheckStructureOdbcConvertVfpToOdbc(@l_cType, @l_cDefault, @l_cUsing)

TEXT TO l_cSql TEXTMERGE  NOSHOW PRETEXT 15
ALTER TABLE <<_screen.oGlobal.oGData.CheckTableName(ALLTRIM(LOWER(curflfd8.fd_table)))>> ALTER COLUMN <<ALLTRIM(LOWER(curflfd8.fd_name))>> TYPE <<l_cType>> USING <<ALLTRIM(LOWER(curflfd8.fd_name))>>::<<l_cUsing>>;
ALTER TABLE <<_screen.oGlobal.oGData.CheckTableName(ALLTRIM(LOWER(curflfd8.fd_table)))>> ALTER COLUMN <<ALLTRIM(LOWER(curflfd8.fd_name))>> SET DEFAULT <<l_cDefault>>;
ALTER TABLE <<_screen.oGlobal.oGData.CheckTableName(ALLTRIM(LOWER(curflfd8.fd_table)))>> ALTER COLUMN <<ALLTRIM(LOWER(curflfd8.fd_name))>> SET NOT NULL;
ENDTEXT

sqlcursor(l_cSql, "cresult")
RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcUpdatCreate
LOCAL l_cScript, l_cTable, l_cType, l_cDefault, l_cUsing
l_cTable = ALLTRIM(LOWER(curflfd8.fd_table))
l_cScript = [CREATE TABLE "] + _screen.oGlobal.oGData.CheckTableName(l_cTable) + [" (]
SELECT * FROM curflfd8 WHERE ALLTRIM(LOWER(fd_table)) == l_cTable INTO CURSOR cmytbl1
SCAN ALL
     DBCheckStructureOdbcConvertVfpToOdbc(@l_cType, @l_cDefault, @l_cUsing, "cmytbl1")
     l_cScript = l_cScript + LOWER(ALLTRIM(cmytbl1.fd_name)) + [ ] + ;
               l_cType + [ DEFAULT ] + l_cDefault + [ NOT NULL ] + ;
               [, ]
ENDSCAN
LOCATE
l_cScript = LEFT(l_cScript,LEN(l_cScript)-2)
IF NOT EMPTY(cmytbl1.fi_unikey)
     l_cScript = l_cScript + [, PRIMARY KEY (] + ALLTRIM(LOWER(cmytbl1.fi_unikey)) + [) DEFERRABLE]
ENDIF
l_cScript = l_cScript + [);]

sqlcursor(l_cScript, "cresult")

RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcTableIndexes
LOCAL i, l_cIndexName, l_cField, l_cSql, l_cTag, l_cField, l_lArchive

l_lArchive = TYPE("plTemporalOdbcForArchiving") = "L" AND plTemporalOdbcForArchiving     && Archiving sequence
SELECT files
SCAN FOR NOT l_lArchive OR 'A' $ fi_flag
     WAIT WINDOW fi_name + " checking indexes..." NOWAIT
     * Get indexes from odbc
     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT relname 
          FROM pg_class
          WHERE oid IN (
                        SELECT indexrelid
                               FROM pg_index, pg_class
                               WHERE pg_class.relname='<<ALLTRIM(LOWER(fi_name))>>'
                               AND pg_class.oid=pg_index.indrelid
                               AND indisunique != 't'
                               AND indisprimary != 't'
                       );
     ENDTEXT
     sqlcursor(l_cSql, "myidx3")
     FOR i = 1 TO 20
          SELECT files
          l_cIndexName = ALLTRIM(LOWER(fi_name))+"_tag" + TRANSFORM(i)
          l_cIndexExp = "fi_pidx" + TRANSFORM(i)
          IF NOT EMPTY(&l_cIndexExp)
               
               * Index for primary key was created automaticly!
               
               SELECT myidx3
               LOCATE FOR ALLTRIM(relname)==l_cIndexName
               IF NOT FOUND()
                    SELECT files
                    l_cField = ALLTRIM(LOWER(&l_cIndexExp))
                    TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
                    CREATE INDEX <<l_cIndexName>> ON desk<<IIF(EMPTY(gcHotCode), "", "_"+LOWER(gcHotCode))>>.<<_screen.oGlobal.oGData.CheckTableName(ALLTRIM(LOWER(fi_name)))>> USING btree (<<l_cField>>);
                    ENDTEXT
                    sqlcursor(l_cSql, "cresult")
               ENDIF
          ENDIF
     ENDFOR
     SELECT files
     * Get primary keys from odbc
     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT relname 
          FROM pg_class
          WHERE oid IN (
                        SELECT indexrelid
                               FROM pg_index, pg_class
                               WHERE pg_class.relname='<<ALLTRIM(LOWER(fi_name))>>'
                               AND pg_class.oid=pg_index.indrelid
                               AND indisprimary = 't'
                       );
     ENDTEXT
     sqlcursor(l_cSql, "mypk3")
     SELECT files
     l_cIndexName = ALLTRIM(LOWER(fi_name))+"_pkey"
     l_cIndexExp = "fi_unikey"
     IF NOT EMPTY(fi_unikey)
          SELECT mypk3
          LOCATE FOR ALLTRIM(relname)==l_cIndexName
          IF NOT FOUND()
               SELECT files
               l_cField = ALLTRIM(LOWER(fi_unikey))
               TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
               ALTER TABLE desk<<IIF(EMPTY(gcHotCode), "", "_"+LOWER(gcHotCode))>>.<<_screen.oGlobal.oGData.CheckTableName(ALLTRIM(LOWER(fi_name)))>> ADD PRIMARY KEY (<<l_cField>>) DEFERRABLE;
               ENDTEXT
               sqlcursor(l_cSql, "cresult")
          ENDIF
     ENDIF
ENDSCAN
dclose("myidx3")
dclose("mypk3")
dclose("cresult")
WAIT CLEAR
RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcRemoveDependencies
sqlcursor("DROP VIEW IF EXISTS res_vw_resbrw;", "cresult")
ENDPROC
*
PROCEDURE DBCheckStructureOdbcSource
LOCAL l_cOdbcSrcFiles, l_nFiles, i, l_cScript, l_cFile
LOCAL ARRAY l_aLines(1)
 * res_ - reservation module
 * bil_ - bill module
 * adr_ - address module
 * etc.

 * vw_ - view
 * pl_ - plpg func
 * sq_ - sql func
 * tr_ - trigger

DO CASE
     CASE TYPE("plTemporalOdbcForArchiving") = "L" AND plTemporalOdbcForArchiving     && Archiving sequence
          TEXT TO l_cOdbcSrcFiles NOSHOW PRETEXT 3
          pl_remove_duplicates.sql
          ENDTEXT
     OTHERWISE
          TEXT TO l_cOdbcSrcFiles NOSHOW PRETEXT 3
          pl_remove_duplicates.sql
          res_pl_balance.sql
          res_pl_geteventname.sql
          res_pl_getrccolor.sql
          res_pl_getreservatname.sql
          res_pl_getrsg.sql
          res_pl_hassharing.sql
          res_vw_resbrw.sql
          rcd_tr_onrckeyupdate.sql
          ENDTEXT
ENDCASE

l_nFiles = ALINES(l_aLines, l_cOdbcSrcFiles)
FOR i = 1 TO l_nFiles
     l_cFile = _screen.oGlobal.choteldir + "metadata\sql\" + l_aLines(i)
     IF FILE(l_cFile)
          l_cScript = FILETOSTR(l_cFile)
          l_cScript = "---" + SUBSTR(l_cScript,4) && Remove UTF8 mark
          sqlcursor(l_cScript, "cresult")
     ENDIF
ENDFOR

RETURN .T.
ENDPROC
*
PROCEDURE DBCheckStructureOdbcDoOnEveryUpdate
* Here add odbc code, which must be done on every update.
dclose("cresult")

*!*     * Add rc_key to ratecode table, as workaround.
*!*     * This should be removed, when rc_key field is added in fields table!
*!*     sqlcursor("SELECT column_name FROM information_schema.columns WHERE table_schema='desk"+IIF(EMPTY(gcHotCode), "", "_"+LOWER(gcHotCode))+"' AND table_name='ratecode' AND column_name='rc_key'","cresult")
*!*     IF USED("cresult") AND EMPTY(cresult.column_name)
*!*          sqlcursor("ALTER TABLE ratecode ADD COLUMN rc_key character(23) DEFAULT ''::bpchar NOT NULL","cresult")
*!*     ENDIF
*!*     dclose("cresult")

RETURN .T.
ENDPROC
*
PROCEDURE DBUpdateLists
 LOCAL i, l_oCA, l_oData
 IF FILE(_screen.oGlobal.choteldir+'Update\Lists.dbf')

      WAIT WINDOW NOWAIT 'Updating standard reports definitions...'

      openfiledirect(.F.,"lists")
      * Get current lists table into curlists cursor
      sqlcursor("SELECT * FROM lists","curlists")
      SELECT curlists
      * Copy it to oldlists.dbf, as backup
      COPY TO (_screen.oGlobal.choteldir+"Tmp\OldLists") ALL
      * open new lists table
      USE (_screen.oGlobal.choteldir+"Update\Lists") ALIAS newlists SHARED IN 0

      * delete all system reports
      sqldelete("lists","SUBSTR(li_listid,1,1)='_'")

      * scan thru new lists table, and copy all reports to lists table
      l_oCA = CREATEOBJECT("calists")
      l_oCA.SetProp(.T.,.T.)
      l_oCA.CursorFill()
      SELECT newlists
      SCAN ALL
           SELECT newlists
           SCATTER NAME l_oData MEMO
           IF dlocate("curlists","li_listid = " + sqlcnv(newlists.li_listid))
                * Copy custom setting for exsisting report
                l_oData.li_hide = curlists.li_hide
                l_oData.li_batch = curlists.li_batch
                l_oData.li_when = curlists.li_when
                l_oData.li_usrgrp = curlists.li_usrgrp
           ENDIF
           INSERT INTO (l_oCA.Alias) FROM NAME l_oData
      ENDSCAN
      l_oCA.DoTableUpdate(.T.,.T.,.T.)

      dclose("curlists")
      dclose("newlists")
      l_oCA.DClose()
      l_oCA = .NULL.

      * Copy frx and dbf
      PRIVATE i, asYsfrx, asYsfrt, asYsdbf, asYsfxp
      WAIT WINDOW NOWAIT 'Deleting old report forms...'
      FOR i = 1 TO ADIR(asYsfrx, gcReportdir+'_*.FRX')
           DELETE FILE (gcReportdir+asYsfrx(i,1))
      ENDFOR
      FOR i = 1 TO ADIR(asYsfrt, gcReportdir+'_*.FRT')
           DELETE FILE (gcReportdir+asYsfrt(i,1))
      ENDFOR
      FOR i = 1 TO ADIR(asYsdbf, gcReportdir+'_*.DBF')
           DELETE FILE (gcReportdir+asYsdbf(i,1))
      ENDFOR
      FOR i = 1 TO ADIR(asYsfxp, gcReportdir+'_*.FXP')
           DELETE FILE (gcReportdir+asYsfxp(i,1))
      ENDFOR
      IF g_lDevelopment
           FOR i = 1 TO ADIR(asYsfxp, gcReportdir+'_*.PRG')
                DELETE FILE (gcReportdir+asYsfxp(i,1))
           ENDFOR
      ENDIF
      WAIT WINDOW NOWAIT 'Copying new report forms...'
      FOR i = 1 TO ADIR(asYsfrx, _screen.oGlobal.choteldir+'Update\_*.FRX')
           COPY FILE (_screen.oGlobal.choteldir+'Update\'+asYsfrx(i,1)) TO (gcReportdir+asYsfrx(i,1))
      ENDFOR
      FOR i = 1 TO ADIR(asYsfrt, _screen.oGlobal.choteldir+'Update\_*.FRT')
           COPY FILE (_screen.oGlobal.choteldir+'Update\'+asYsfrt(i,1)) TO (gcReportdir+asYsfrt(i,1))
      ENDFOR
      FOR i = 1 TO ADIR(asYsdbf, _screen.oGlobal.choteldir+'Update\_*.DBF')
           COPY FILE (_screen.oGlobal.choteldir+'Update\'+asYsdbf(i,1)) TO (gcReportdir+asYsdbf(i,1))
      ENDFOR
      FOR i = 1 TO ADIR(asYsfxp, _screen.oGlobal.choteldir+'Update\_*.FXP')
           COPY FILE (_screen.oGlobal.choteldir+'Update\'+asYsfxp(i,1)) TO (gcReportdir+asYsfxp(i,1))
      ENDFOR
      IF g_lDevelopment
           FOR i = 1 TO ADIR(asYsfxp, _screen.oGlobal.choteldir+'Update\_*.PRG')
                COPY FILE (_screen.oGlobal.choteldir+'Update\'+asYsfxp(i,1)) TO (gcReportdir+asYsfxp(i,1))
           ENDFOR
      ENDIF
      IF NOT g_lDevelopment
           * In development mode, don't delete contents of update folder!
           DELETE FILE (_screen.oGlobal.choteldir+'Update\*.*')
      ENDIF

      WAIT CLEAR
 ENDIF
ENDPROC
*
PROCEDURE Cnv663
 PARAMETER pnAddrid, pnReserid, pnDebbill, pnBillnum
 IF NOT OpenFileDirect(,"id")
      CREATE TABLE (gcDatadir+'Id') (id_code C (8), id_last N (8, 0))
      INSERT INTO id (id_code, id_last) VALUES ('ADDRESS', pnAddrid)
      INSERT INTO id (id_code, id_last) VALUES ('RESERVAT', pnReserid)
      INSERT INTO id (id_code, id_last) VALUES ('INVOICE', pnDebbill)
      INSERT INTO id (id_code, id_last) VALUES ('BILL', pnBillnum)
      FLUSH
      = dcLose('Id')
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE CnvPrType
 PRIVATE naRea, i, cfLd
 naRea = SELECT()
 WAIT WINDOW NOWAIT "Converting PRTYPES.DBF..."
 IF doPen('pr_type')
      SELECT prType
      FOR i = 1 TO 9
           cfLd = 'PT_LANG'+STR(i, 1)
           replace all &cFld with pt_descrip
      ENDFOR
      = dcLose('prtype')
 ENDIF
 WAIT CLEAR
 SELECT (naRea)
 RETURN
ENDPROC
*
PROCEDURE DelPostAr
 WAIT WINDOW NOWAIT "Deleting A/R records in POST and HISTPOST..."
 IF OpenFileDirect(.F., "HistPost", "hp")
      SELECT hp
      DELETE ALL FOR hp_supplem='CITYLEDG_'
      USE IN hp
 ENDIF
 IF OpenFileDirect(.F., "Post", "ps")
      SELECT ps
      DELETE ALL FOR ps_supplem='CITYLEDG_'
      USE IN ps
 ENDIF
 WAIT CLEAR
ENDPROC
*
PROCEDURE NewPwd
 PRIVATE naRea
 naRea = SELECT()
 IF OpenFileDirect(.F., "User", "usR")
      SELECT usR
      LOCATE ALL FOR us_id='SUPERVISOR' .AND. us_pass=REPLICATE(CHR(255), 10)
      IF FOUND()
           REPLACE us_pass WITH SYS(2007, UPPER(ALLTRIM(us_pass))) ALL
           FLUSH
      ENDIF
      USE IN usR
 ENDIF
 SELECT (naRea)
ENDPROC
*
PROCEDURE GenerateUpdate
 LOCAL l_cXML
 PRIVATE p_aFilesTableBackup
 DIMENSION p_aFilesTableBackup(1)

 IF NOT (openfiledirect(.T.,"files") AND openfiledirect(.T.,"fields"))
      closefile("files")
      closefile("fields")
      RETURN .F.
 ENDIF
 
 DBAlterFilesTable()
 
 GetTablesWhereIndexAreChanged()
 
 * Backup files table
 SELECT * FROM files INTO ARRAY p_aFilesTableBackup

 SELECT files
 ZAP
 filedelete(gcDatadir+"files.cdx")
  
 APPEND FROM metadata\files.txt DELIMITED WITH ~ WITH TAB
 INDEX ON UPPER(fi_name) TAG tag1
 INDEX ON UPPER(fi_alias) TAG tag2
 INDEX ON STR(fi_group, 2) TAG tag3
 
 DBRestoreFilesTableBackup()
 
 SELECT fields
 ZAP
 filedelete(gcDatadir+"fields.cdx")
  
 APPEND FROM metadata\fields.txt DELIMITED WITH ~ WITH TAB
 INDEX ON UPPER(fd_table+fd_name) TAG Fields

 IF NOT odbc()
      dclose("curlanguage")
      l_cXML = STRCONV(FILETOSTR("Metadata\language.xml"),11)
      XMLTOCURSOR(l_cXML, "curlanguage")
      INDEX ON UPPER(la_lang+la_prg+la_label) TAG Tag1
      dclose("language")
      IF openfile(.T.,"language")
           SELECT language
           DELETE ALL
           PACK
           APPEND FROM DBF("curlanguage")
      ENDIF
      dclose("language")
      dclose("curlanguage")
 ENDIF

 closefile("files")
 closefile("fields")

 RETURN .T.
ENDPROC
*
FUNCTION FormatVersion
LPARAMETERS tcVersion, tcRetVal
* Copied from Registerdotnetcomponent.prg and used from extra\exexportrev.prg
LOCAL lcVersion

lcVersion = ""     && aaaa.bbbb.cccc.ddddd
FOR i = 1 TO GETWORDCOUNT(tcVersion,".")
     lcVersion = lcVersion + IIF(EMPTY(lcVersion), "", ".") + PADL(GETWORDNUM(tcVersion, i, "."), IIF(i=4,5,4), "0")
NEXT

tcRetVal = lcVersion

RETURN lcVersion
ENDFUNC
*
FUNCTION GetDBVersion
 LPARAMETERS lp_cRetVal
 LOCAL l_cVersion
 IF TYPE("_screen.oGlobal.oParam2.pa_dbvers") == "U" OR EMPTY(ALLTRIM(_screen.oGlobal.oParam2.pa_dbvers))
      l_cVersion = ALLTRIM(STR(_screen.oGlobal.oParam.pa_version,7,2))+'.'+;
                ALLTRIM(STR(_screen.oGlobal.oParam.pa_build))
      l_cVersion = STRTRAN(l_cVersion, ",", ".")
 ELSE
      l_cVersion = ALLTRIM(_screen.oGlobal.oParam2.pa_dbvers)
 ENDIF
 lp_cRetVal = l_cVersion
 RETURN l_cVersion
ENDFUNC
*
FUNCTION CompareVersion
 LPARAMETERS lp_cVersion
 * Return Value
 * DB_LOWER_VER   - if lp_cFirstVersion < lp_cSecondVersion
 * DB_EQUAL_VER   - if lp_cFirstVersion = lp_cSecondVersion
 * DB_HIGHIER_VER - if lp_cFirstVersion > lp_cSecondVersion
 LOCAL l_nCompValue, l_cFirstVersion, l_cSecondVersion

 l_cFirstVersion = FormatVersion(GetDBVersion())
 l_cSecondVersion = FormatVersion(lp_cVersion)

 DO CASE
     CASE l_cFirstVersion < l_cSecondVersion
          l_nCompValue = DB_LOWER_VER
     CASE l_cFirstVersion = l_cSecondVersion
          l_nCompValue = DB_EQUAL_VER
     CASE l_cFirstVersion > l_cSecondVersion
          l_nCompValue = DB_HIGHIER_VER
     OTHERWISE
          l_nCompValue = DB_UNKNOWN
 ENDCASE

 RETURN l_nCompValue
ENDFUNC
*
PROCEDURE SetExeToDBVersion
 LOCAL l_cVersion, l_cOldVersion
 OpenFile(.F., "Param2")
 OpenFile(.F., "Param")
 DO SetAppVersion IN main WITH l_cVersion
 IF DB_LOWER_VER = CompareVersion(l_cVersion)
      l_cOldVersion = FormatVersion(GetDBVersion())
      sqlupdate("param","1=1","pa_version = " + sqlcnv(g_Version,.T.) + ", pa_revisio = '', pa_build = " + sqlcnv(g_Build,.T.))
      
      *UPDATE param SET pa_version = g_Version, pa_revisio = "", pa_build = g_Build
      sqlupdate("param2","1=1","pa_dbvers = " + sqlcnv(l_cVersion,.T.) + ", pa_updatef = " + sqlcnv(l_cOldVersion,.T.))
      *UPDATE param2 SET pa_dbvers = l_cVersion, pa_updatef = l_cOldVersion
      *FLUSH
 ENDIF
 CloseFile("Param2")
ENDPROC
*
PROCEDURE BeforeUpdateDataToVersion
 openfiledirect(.F., "Param")
 sqlcursor("SELECT * FROM param","curparam5")
 IF DB_LOWER_VER = CompareVersion("6.64")
      PRIVATE naDdrid, nrEserid, ndEbbill, nbIllnum
      naDdrid = Param.pa_addrid
      nrEserid = Param.pa_reserid
      ndEbbill = Param.pa_debbill
      nbIllnum = Param.pa_billnum
      IF  .NOT. EMPTY(Param.pa_posdifa)
           SELECT Param
           IF TYPE('pa_posdifa')='C' .AND. LEN(TRIM(pa_posdifa))>4
                REPLACE Param.pa_posdifa WITH SUBSTR(Param.pa_posdifa, 4)
           ENDIF
      ENDIF
      = cnV663(naDdrid,nrEserid,ndEbbill,nbIllnum)
 ENDIF
 IF curparam5.pa_billsty > 9
      sqlupdate("param","1=1","pa_billsty = 1")
 ENDIF
 dclose("Param")
 dclose("curparam5")

 IF NOT odbc()
      IF DB_LOWER_VER = CompareVersion("7.50")
           deLpostar()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("7.53")
           neWpwd()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.06.44")
           DBUpdateSetPointIndex()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.45")
           UpdateAllotment()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.47")
           UpdateAlthead()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.49")
           UpdateRoomTypeFromRoom()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.96")
           UpdateUnqResrId()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.106")
           UpdateAltHeadEventsBefore()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.80")
           DBFixRsIdBefore()
      ENDIF
 ENDIF
 * From now, make sure no error occurs, when updating PostgreSQL
  
 ************************************************************
 * ATTENTION!!!!!!                                          *
 * Keep in mind, update MUST work with PostgreSql too!!!!   *
 ************************************************************
 
 RETURN .T.
ENDPROC
*
PROCEDURE AfterUpdateDataToVersion
LPARAMETERS lp_lCheckConst, lp_lAvlRebuild
* lp_lCheckConst, lp_lAvlRebuild - Returned as reference
 LOCAL l_cMainWhere, l_dStartDate, l_dEndDate, l_dDate, i, y, l_oData, l_cVatNr, l_cWhere, l_cMacro, l_cMacro2, l_nRecNo, l_cAlias, ;
           l_nLines, l_cLine, l_cUserId, l_oRessplit, l_nCount, l_nPercent, l_nRecCount

 ************************************************************************************
 * ATTENTION!!!!!!                                                                  *
 * Don't define variables down in if statments, because of possibility              *
 * that error Illegal redefinition of variable "name" (Error 1960) can happen !!!   *
 * Define variables as LOCAL in begining of this procedure !!!!                     *
 ************************************************************************************


 IF NOT odbc()
      IF DB_LOWER_VER = CompareVersion("6.64.120")
           cnVprtype()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.06")
           STORE .T. TO lp_lCheckConst, lp_lAvlRebuild
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.06.8")
           UpdateSeason()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.06.25")
           DBUpdateParam2()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.06.33")
           DO UpdateVersion IN ClosCash
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.47")
           UpdateBuilding()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.49")
           UpdateRoomtypDef()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.56")
           UpdateResBrwRtColWidth()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.86")
           ActivateBuildings()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.93")
           UpdateResAddr()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.102")
           UpdateResAddrMustHaveRecord()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.106")
           UpdateAltHeadEventsAfter()
           UpdateActionsAfter()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.07.107")
           IF FILE("brilliant.ini")
                RENAME brilliant.ini TO INI_FILE
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.4")
           UpdateHrrsId()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.20")
           * remove old settings for RSB grid
           IF openfile(.F.,"grid")
                * set all gr_show to .T. and let grid set it again, when user starts form.
                 sqlupdate("grid", sqlcnv(.T.,.T.), "gr_show = " + sqlcnv(.T.,.T.))
                * delete all settings for resbrw.scx for columns column15 - column22.
                * Probably those settings are messed up. Let user set it again.
                 sqldelete("grid", "gr_label = " + sqlcnv("RSBGRID",.T.) + ;
                           " AND INLIST(LOWER(gr_column),[column15],[column16],[column17],[column18]," + ;
                           "[column19],[column20],[column21],[column22])")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.24")
           * remove old settings for ADDRESSGRID and SEARCHADRADDRESSGRID grid
           IF openfile(.F.,"grid")
                * delete all settings for addressmask.scx for column column12
                 sqldelete("grid", "gr_label = " + sqlcnv("ADDRESSGRID",.T.) + ;
                           " OR gr_label = " + sqlcnv("SEARCHADRADDRESSGRID",.T.) + ;
                           " AND LOWER(gr_column) = " + sqlcnv("column12"))
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.26")
           * Update DUM as paymaster
           * Only one paymaster allowed
           IF openfile(.F.,"rtypedef")
               sqlupdate("rtypedef", ;
                    "rd_roomtyp = " + sqlcnv(PADR("DUM",10),.T.), ;
                    "rd_paymstr = " + sqlcnv(.T.,.T.))
                IF openfile(.F.,"roomtype")
                    sqlupdate("roomtype", ;
                         "rt_roomtyp = " + sqlcnv(PADR("DUM",4),.T.) + " AND NOT rt_paymstr", ;
                         "rt_paymstr = " + sqlcnv(.T.,.T.))
                ENDIF
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.39")
           * Update rr_curcoef to 1
           IF openfile(.F.,"resrate")
                sqlupdate("resrate", sqlcnv(.T.,.T.), "rr_curcoef = " + sqlcnv(1,.T.))
                IF openfile(.F.,"hresrate")
                     sqlupdate("hresrate", sqlcnv(.T.,.T.), "rr_curcoef = " + sqlcnv(1,.T.))
                ENDIF
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.42")
           IF FILE("errorlog.dbf")
                DELETE FILE FULLPATH("errorlog.dbf")
                DELETE FILE FULLPATH("errorlog.fpt")
           ENDIF
           IF FILE(gcDatadir+"errorlog.dbf")
                DELETE FILE FULLPATH(gcDatadir+"errorlog.dbf")
                DELETE FILE FULLPATH(gcDatadir+"errorlog.fpt")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.79")
           * Add IDs for grid table
           IF openfile(.F.,"grid")
                SELECT grid
                SCAN ALL
                     IF EMPTY(gr_grid)
                          l_nGrId = nextid("GRID")
                          REPLACE gr_grid WITH l_nGrId IN grid
                     ENDIF
                     IF gr_width > 1000
                          * Adjust it, this can be so big number becouse of bug!
                          REPLACE gr_width WITH 75 IN grid
                     ENDIF
                ENDSCAN
           ENDIF
      ENDIF
       IF DB_LOWER_VER = CompareVersion("9.08.90")
           * Add IDs for logger table
           LOCAL l_nId, l_cIdCode, l_nBillNumBillType
           IF openfile(.F.,"logger")
                SELECT logger
                SCAN FOR EMPTY(lg_lgid)
                    l_nId = nextid("LOGGER")
                    REPLACE lg_lgid WITH l_nId IN logger
                ENDSCAN
                FLUSH
           ENDIF
           IF openfile(.F.,"lists") AND openfile(.F.,"id")
               l_cIdCode = "LISTS   "
               SELECT lists
               SET ORDER TO
               l_nId = 0
               SCAN ALL
                    l_nId = l_nId + 1
                    REPLACE li_liid WITH l_nId IN lists
               ENDSCAN
               SELECT id
               LOCATE FOR id_code = l_cIdCode
               IF FOUND()
                    REPLACE id_last WITH l_nId
               ELSE
                    INSERT INTO ID (id_code, id_last) VALUES (l_cIdCode, l_nId)
               ENDIF
               FLUSH
           ENDIF
           IF openfile(.F.,"billnum") AND openfile(.F.,"address")
                SELECT billnum
                SET ORDER TO
                SET ORDER TO TAG1 IN address
                SET RELATION TO bn_addrid INTO address
                SCAN FOR bn_type = 0
                     WAIT WINDOW NOWAIT "Update billnum type for bill " + TRANSFORM(bn_billnum)
                     IF EMPTY(address.ad_company)
                          l_nBillNumBillType = 1&&C_BILL_TYPE_GUEST
                     ELSE
                          l_nBillNumBillType = 2&&C_BILL_TYPE_COMPANY
                     ENDIF
                     REPLACE bn_type WITH l_nBillNumBillType IN billnum
                ENDSCAN
                WAIT CLEAR
                FLUSH
                SET RELATION TO
           ENDIF
      ENDIF
      
      IF DB_LOWER_VER = CompareVersion("9.08.91")
           * Add IDs for ledgpost table
           LOCAL l_nLdgId
           IF openfile(.F.,"ledgpost")
                SELECT ledgpost
                SET ORDER TO
                SCAN FOR EMPTY(ld_ldid)
                    l_nLdgId = nextid("LEDGPOST")
                    REPLACE ld_ldid WITH l_nLdgId IN ledgpost
                ENDSCAN
                FLUSH
           ENDIF
           IF openfile(.F.,"ledgpaym")
                SELECT ledgpaym
                SET ORDER TO
                SCAN FOR EMPTY(lp_lpid)
                    l_nLdgId = nextid("LEDGPAYM")
                    REPLACE lp_lpid WITH l_nLdgId IN ledgpaym
                ENDSCAN
                FLUSH
           ENDIF
      ENDIF

      IF DB_LOWER_VER = CompareVersion("9.08.100")
           = openfile(.F.,"id")
           = openfile(.F.,"banken")
           = openfile(.F.,"zipcode")
           = openfile(.F.,"histres")
           SELECT banken
           REPLACE ba_baid WITH RECNO() ALL
           GO BOTTOM
           SELECT id
           LOCATE FOR id_code = "BANKEN"
           IF FOUND()
                REPLACE id_last WITH banken.ba_baid
           ELSE
                INSERT INTO ID(id_code, id_last) VALUES ("BANKEN", banken.ba_baid)
           ENDIF
           SELECT zipcode
           REPLACE zc_zcid WITH RECNO() ALL
           GO BOTTOM
           SELECT id
           LOCATE FOR id_code = "ZIPCODE"
           IF FOUND()
                REPLACE id_last WITH zipcode.zc_zcid
           ELSE
                INSERT INTO ID(id_code, id_last) VALUES ("ZIPCODE", zipcode.zc_zcid)
           ENDIF
           l_cWhere = "hr_reserid IN (" + ;
               sqlcnv(0.100) + "," + ;
               sqlcnv(0.200) + "," + ;
               sqlcnv(0.300) + "," + ;
               sqlcnv(0.400) + "," + ;
               sqlcnv(0.500) + "," + ;
               sqlcnv(0.700) + ;
               ") AND hr_rsid = 0"

           UPDATE histres SET hr_rsid = nextid("RESUNQID") WHERE &l_cWhere
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.127")
            IF openfile(.F.,"action")
                = loGdata("Generating action.at_atid",cuPdatefile)
                SELECT action
                SET ORDER TO
                SCAN FOR EMPTY(at_atid)
                     REPLACE at_atid WITH nextid("ACTION")
                ENDSCAN
                FLUSH
            ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.128")
            IF openfile(.F.,"action")
                = loGdata("Generating deleting : from EMPTY(at_time)",cuPdatefile)
                SELECT action
                SET ORDER TO
                SCAN FOR EMPTY(STRTRAN(at_time,":",""))
                     REPLACE at_time WITH ""
                ENDSCAN
                FLUSH
            ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.130")
            IF openfile(.F.,"screens")
                = loGdata("Changing labels in screens.dbf",cuPdatefile)
                UPDATE screens SET sc_label = "ADDRBOOK" WHERE sc_label = "FORMSET1FADDRESSMASK"
                UPDATE screens SET sc_label = "AVAILAB" WHERE sc_label = "BRWAVAIL"
                UPDATE screens SET sc_label = "AVLALLOT" WHERE sc_label = "BRWALLOTTAVAIL"
                UPDATE screens SET sc_label = "AVLEVENT" WHERE sc_label = "BRWEVENTAVAIL"
                UPDATE screens SET sc_label = "BILLS" WHERE sc_label = "FRSBILLSFRMBILLS"
                UPDATE screens SET sc_label = "BILLHIST" WHERE sc_label = "FRSBILLHISTFRMBHISTB"
                UPDATE screens SET sc_label = "RESERVAT" WHERE sc_label = "FSRESERVATTFORM12"
                UPDATE screens SET sc_label = "ROOMPLAN" WHERE sc_label = "WEEKPLAN"
                UPDATE screens SET sc_label = "GROOMPLAN" WHERE sc_label = "WEEKPLANRM"
                UPDATE screens SET sc_label = "CONFPLAN" WHERE sc_label = "CONFERENCE"
                UPDATE screens SET sc_label = "CONFDPLAN" WHERE sc_label = "CONF_DAY"
                UPDATE screens SET sc_label = "HOTELSTAT" WHERE sc_label = "FRMSHOTSTATFRMHOTSTA"
                FLUSH
            ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.135")
           IF openfile(.F.,"param") AND param.pa_country = "D"
                IF openfile(.F.,"menu")
                     SELECT menu
                     LOCATE FOR LOWER(mn_func) = LOWER("exvatchange(.T.)")
                     IF NOT FOUND()
                          SCATTER NAME l_oData
                          l_oData.mn_func = "exvatchange(.T.)"
                          SELECT TOP 1 mn_sequ FROM menu ORDER BY 1 DESC INTO ARRAY l_aMenuExtra
                          IF _TALLY > 0
                               l_oData.mn_sequ = l_aMenuExtra(1)+1
                          ELSE
                               l_oData.mn_sequ = 1
                          ENDIF
                          SELECT menu
                          l_oData.mn_lang1 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang2 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang3 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang4 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang5 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang6 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang7 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang8 = "MwSt7% Tool Einstell"
                          l_oData.mn_lang9 = "MwSt7% Tool Einstell"
                          INSERT INTO menu FROM NAME l_oData
                     ENDIF
                     IF openfile(.F.,"group")
                          REPLACE gr_extra WITH "1111111111111111" ALL IN group
                     ENDIF
                     REPLACE pa_mnuextr WITH .T. IN param
                ENDIF
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.08.140")
           IF openfile(.F.,"param") AND openfile(.F.,"param2") AND NOT ALLTRIM(param.pa_country) == "D"
                REPLACE pa_spabill WITH .T. IN param2
                FLUSH
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.08")
           UpdateEventRelations()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.10")
           UpdateLedgerToPostRelation()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.17")
           * Update billnum bn_window=1 for passerby bills!
           IF openfile(.F.,"billnum")
                WAIT WINDOW NOWAIT "Updating billnum for 0.100"
                REPLACE bn_window WITH 1 FOR bn_reserid = 0.100 AND bn_window = 0 IN billnum
                FLUSH
                WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.23")
           * Delete orphan records from resrooms and resaddr
           IF openfile(.F.,"resrooms") AND openfile(.F.,"resaddr") AND openfile(.F.,"reservat")
                WAIT WINDOW NOWAIT "Deleting old records from resrooms..."
                SELECT resrooms
                SCAN FOR NOT SEEK(resrooms.ri_reserid,"reservat","tag1")
                     DELETE IN resrooms
                ENDSCAN
                SELECT resaddr
                SCAN FOR NOT SEEK(resaddr.rg_reserid,"reservat","tag1")
                     DELETE IN resaddr
                ENDSCAN
                FLUSH
                WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.29")
           IF OpenFile(.F.,"grid")
                * Change column name for TGRIDCOMPARE, TGRIDYEARS grids from ColumnXX -> GrdbasesortcolumnXX
                 SqlUpdate("grid", "UPPER(gr_label) IN ([TGRIDCOMPARE],[TGRIDYEARS]) AND UPPER(LEFT(gr_column,6)) = [COLUMN]", "gr_column = STUFF(gr_column,1,6,[Grdbasesortcolumn])")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.46")
           UpdateRatecode90946()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.70")
           UpdateBanquetAndResfixId90970()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.77")
           * Allow everyone to make storno as default
           IF openfile(.F.,"group")
                LOCAL l_cbtcout2
                SELECT group
                SCAN ALL
                     l_cbtcout2 = STUFF(gr_btcout2,5,1,"1")
                     REPLACE gr_btcout2 WITH l_cbtcout2
                ENDSCAN
                FLUSH
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.113")
           * Delete settings for printgroupingcode form and grid in manager.
           IF openfile(.F.,"grid") AND openfile(.F.,"screens")
                DELETE FROM grid WHERE gr_label = 'MNGPRGRCODESCTRL'
                DELETE FROM screens WHERE sc_label = 'MNGPRGRCODESCTRL'
                FLUSH
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.116")
           * Delete all records from license, and let checknetid function to add only needed records
           IF USED("license")
                ZAP IN license
           ENDIF
           * Delete settings for user form and grid in manager.
           IF openfile(.F.,"grid") AND openfile(.F.,"screens")
                DELETE FROM grid WHERE gr_label = 'MNGUSERCTRL'
                DELETE FROM screens WHERE sc_label = 'MNGUSERCTRL'
                FLUSH
           ENDIF

      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.125")
           * Delete settings for paymethod form and grid in manager.
           IF openfile(.F.,"grid") AND openfile(.F.,"screens")
                DELETE FROM grid WHERE gr_label = 'MNGPAYMETHODCTRL'
                DELETE FROM screens WHERE sc_label = 'MNGPAYMETHODCTRL'
                FLUSH
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.133")
           UpdateVoucherToPostRelation909133()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.09.140")
           * Update ri_todate in resrooms.dbf.
           IF OpenFile(.F.,"reservat") AND OpenFile(.F.,"histres") AND OpenFile(.F.,"resrooms") AND OpenFile(.F.,"hresroom") AND OpenFile(.F.,"roomtype")
                DO RiRebuildToDate IN ProcResrooms
           ENDIF
           CloseFile("reservat")
           CloseFile("histres")
           CloseFile("resrooms")
           CloseFile("hresroom")
           CloseFile("roomtype")
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.1")
           * Make "hole" in gr_order for new "title" column, before lname column.
           IF openfile(.F.,"grid")
                sqlupdate("grid", "gr_label = " + sqlcnv("RSBGRID",.T.) + ;
                          " AND gr_order > 11", ;
                           "gr_order = gr_order + 1")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.7")
           * Moved button rights for housekeeping from gr_other in gr_buthous field.
           IF openfile(.F.,"group")
                sqlupdate("group", "1=1", ;
                           "gr_buthous = '11'+SUBSTR(gr_other,14,2)+'111111111111'")
                sqlupdate("group", "1=1", ;
                           "gr_other = LEFT(gr_other,13)+'00'+SUBSTR(gr_other,16,1)")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.18")
           LOCAL l_nNewIdForLisTbl
           OpenFile(.F., "lists")
           OpenFile(.F., "id")
           l_nNewIdForLisTbl = 1000
           SELECT lists
           SET ORDER TO
           SCAN FOR LEFT(li_listid,1)<>"_"
                l_nNewIdForLisTbl = l_nNewIdForLisTbl + 1
                REPLACE li_liid WITH l_nNewIdForLisTbl
           ENDSCAN
           SELECT id
           LOCATE FOR id_code = "LISTS   "
           IF FOUND()
                REPLACE id_last WITH l_nNewIdForLisTbl
           ELSE
                INSERT INTO id (id_code, id_last) VALUES ("LISTS   ", l_nNewIdForLisTbl)
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.34")
           IF OpenFile(,"param2")
                REPLACE pa_oosdef WITH .T. IN param2
           ENDIF
           IF OpenFile(,"grid")
                DELETE FOR gr_label = "MNGALTSPLITCTRL" IN grid
                REPLACE gr_label WITH "MNGALTSPLITCTRL", gr_column WITH STRTRAN(UPPER(gr_column),"COLUMN","Grdbasesortcolumn") FOR gr_label = "ZOOMGRID" IN grid
           ENDIF
           IF OpenFile(,"screens")
                DELETE FOR sc_label = "MNGALTSPLITCTRL" IN screens
                REPLACE sc_label WITH "MNGALTSPLITCTRL" FOR sc_label = "SELFORMSETZOOMINFORM" IN screens
           ENDIF
           FLUSH
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.45")
           LOCAL ARRAY laOrder(13)
           laOrder(1) = 7
           laOrder(2) = 6
           laOrder(3) = 12
           laOrder(4) = 1
           laOrder(5) = 2
           laOrder(6) = 3
           laOrder(7) = 4
           laOrder(8) = 9
           laOrder(9) = 13
           laOrder(10) = 15
           laOrder(11) = 14
           laOrder(12) = 20
           laOrder(13) = 26
           IF OpenFile(,"grid")
                DELETE FOR gr_label = "GGUESTS" AND NOT BETWEEN(gr_order, 1, 13) IN grid
                REPLACE gr_column WITH "Column" + PADR(laOrder(gr_order),3) ;
                        gr_label WITH "RSBGRIDINHGUEST" ;
                     FOR gr_label = "GGUESTS" IN grid
           ENDIF
           IF OpenFile(,"screens")
                REPLACE sc_label WITH "RESBRWINHGUEST" FOR sc_label = "INHOUSEGUESTSFORMINH" IN screens
           ENDIF
           FLUSH
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.55")
           OpenFile(,"picklist")
           IF DLocate("picklist", "pl_label+pl_charcod = 'ROOM      ID '") AND NOT EMPTY(picklist.pl_user1)
                NextId("ROOM",picklist.pl_user1)
                DELETE IN picklist
           ENDIF
           IF DLocate("picklist", "pl_label+pl_charcod = 'ROOMTYPE  ID '") AND NOT EMPTY(picklist.pl_user1)
                NextId("ROOMTYPE",picklist.pl_user1)
                DELETE IN picklist
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.62")
           IF OpenFile(,"grid")
                REPLACE gr_label WITH "GRDROOMSAVAILYM" FOR gr_label = "GRDROOMSAVAIL" IN grid
           ENDIF
           IF OpenFile(,"gridprop")
                REPLACE gp_label WITH "GRDROOMSAVAILYM", gp_hheight WITH 35 FOR gp_label = "GRDROOMSAVAIL" IN gridprop
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.66")
           IF openfile(,"reservat") AND openfile(,"param")
               WAIT WINDOW "Updating rs_rcsync field" NOWAIT
               l_cDate = DTOS(param.pa_sysdate)
               sqlupdate(;
                    "reservat", ;
                    "DTOS(rs_depdate)+rs_roomnum >= "+sqlcnv(l_cDate,.T.) + ;
                    " AND rs_status NOT IN ('OUT','CXL','NS ','LST') AND " + ;
                    "(rs_ratedat = {} OR rs_ratedat < rs_depdate-1) AND NOT rs_ratecod IN ('DUM','COMP')", ;
                    "rs_rcsync="+sqlcnv(.T.,.T.) ;
                        )
               WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.70")
           IF OpenFile(,"grid")
                DELETE FOR INLIST(UPPER(gr_label),"ADDRESSGRID","SEARCHADRADDRESSGRID") AND INLIST(UPPER(gr_column),"COLUMN2","COLUMN4","COLUMN14") IN grid
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.74")
           IF OpenFile(,"grid")
                DELETE FOR UPPER(gr_label) = "MNGVIPSTATUSCTRL" IN grid
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.76")
           IF OpenFile(,"lists")
                REPLACE li_lettype WITH 1 FOR EMPTY(li_lettype) AND li_reslet IN lists
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.80")
           IF OpenFile(,"bspost")
                IF RECCOUNT("bspost")>0 AND TYPE("bspost.bs_type")="N"
                     REPLACE bs_type WITH IIF(EMPTY(bs_postid), IIF(bs_points > 0, 2, 3), IIF(EMPTY(bs_bspayid), 0, 1)) ALL IN bspost
                ENDIF
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.88")
            IF OpenFile(,"histres") AND OpenFile(,"address")
                SELECT histres
                SET ORDER TO
                SCAN FOR hr_reserid > 1
                     IF SEEK(hr_addrid, "address", "tag1") AND histres.hr_country <> address.ad_country
                          WAIT WINDOW "Fixing hr_country for hr_reserid = " + TRANSFORM(histres.hr_reserid) NOWAIT
                          REPLACE hr_country WITH address.ad_country IN histres
                     ENDIF
                ENDSCAN
                FLUSH FORCE
                WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.112")
           IF openfiledirect(,"ratecode")
                IF odbc()
                     sqlupdate("ratecode","1=1","rc_key = rpad(rc_ratecod,10)||rpad(rc_roomtyp,4)||to_char(rc_fromdat,'YYYYMMDD')||rc_season")
                ELSE
                     sqlupdate("ratecode","1=1","rc_key = rc_ratecod+rc_roomtyp+DTOS(rc_fromdat)+rc_season")
                ENDIF
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.131")
           IF OpenFile(,"grid")
                REPLACE gr_order WITH VAL(GETWORDNUM("4,5,6,7,14,2,1,15,8,16,17,3,9,11,10,18,19,20,21,12,22,23,24,25,26,13", VAL(STRTRAN(gr_column,"Column")),",")) ;
                     FOR gr_label = "RSBGRIDINHGUEST" IN grid
           ENDIF
           FLUSH
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.151")
           IF OpenFileDirect(,"grid")
                SqlDelete("grid", "gr_label = 'MNGVIPSTATUSCTRL'")
           ENDIF
           IF OpenFileDirect(,"article")
                SqlUpdate("article", "1=1", "ar_discnt = (1=1)")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.158")
           IF NOT odbc() AND OpenFileDirect(,"reservat") AND OpenFileDirect(,"ressplit")
                WAIT WINDOW "Updating rs_rcsync for reservations with wrong prices in ressplit..." NOWAIT
                UPDATE reservat SET rs_rcsync = (1=1) ;
                     WHERE rs_rsid IN ;
                     (SELECT rs_rsid FROM ressplit INNER JOIN reservat ON rl_rsid = rs_rsid AND NOT rs_rcsync ;
                     WHERE rl_artityp = 1 AND rl_price = 0 AND NOT 'DUM       ' $ rl_ratecod AND NOT 'COMP      ' $ rl_ratecod GROUP BY 1)
                WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.159")
           IF OpenFileDirect(,"cwrates")
                WAIT WINDOW "Updating new rate fields for table cwrates..." NOWAIT
                sqlupdate("cwrates","1=1","ew_rate2 = ew_rate, ew_rate3 = ew_rate, ew_rate4 = ew_rate, ew_rate5 = ew_rate")
                WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.162")
           IF OpenFileDirect(,"grid")
                SqlDelete("grid", "gr_label = 'MNGCOUNTRYCTRL'")
           ENDIF
           UpdateBanquetId910162()
           UpdateResrateSplit910162()
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.163")
           IF OpenFileDirect(,"grid")
                SqlUpdate("grid", "gr_label IN ('RSBGRIDARR','RSBGRIDDEP','RSBGRIDINH','RSBGRIDINHGUEST','RSBGRID') AND gr_column = 'Column20'", "gr_activ = (1=1), gr_show = (1=1)")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.171")
           IF NOT odbc() AND OpenFileDirect(,"rateprop") AND OpenFileDirect(,"id")
                * Fix duplicate IDs in rateprop table
               SELECT id
               LOCATE FOR id_code = 'RATEPROP'
               IF FOUND()
                    l_nId = id.id_last
                    SELECT rateprop
                    SET ORDER TO
                    SELECT rd_rcpid, COUNT(*) FROM rateprop GROUP BY 1 HAVING COUNT(*)>1 INTO CURSOR curduprp1
                    SCAN ALL
                         SELECT rateprop
                         SCAN FOR rd_rcpid = curduprp1.rd_rcpid
                              l_nId = l_nId + 1
                              REPLACE rd_rcpid WITH l_nId
                         ENDSCAN
                    ENDSCAN
                    USE
                    IF l_nId <> id.id_last
                         REPLACE id_last WITH l_nId IN id
                    ENDIF
                    SELECT rd_ratecod, rd_rcpname, rd_valdate, rd_valtype, COUNT(*) FROM rateprop GROUP BY 1,2,3,4 HAVING COUNT(*)>1 INTO CURSOR curduprp1
                    SCAN ALL
                         SELECT rateprop
                         l_nRecNo = 0
                         SCAN FOR rd_ratecod = curduprp1.rd_ratecod AND rd_rcpname = curduprp1.rd_rcpname AND rd_valdate = curduprp1.rd_valdate AND rd_valtype = curduprp1.rd_valtype
                              l_nRecNo = RECNO()
                         ENDSCAN
                         IF l_nRecNo > 0
                              DELETE FOR rd_ratecod = curduprp1.rd_ratecod AND rd_rcpname = curduprp1.rd_rcpname AND rd_valdate = curduprp1.rd_valdate AND rd_valtype = curduprp1.rd_valtype AND RECNO() <> l_nRecNo
                         ENDIF
                    ENDSCAN
                    USE
               ENDIF
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.185")
           IF OpenFile(,"adrtores") AND NOT DLocate("adrtores", "adrfield = 'ad_market'")
                SqlInsert("adrtores", "adrfield,resfield", 1, "'ad_market','rs_market'")
                SqlInsert("adrtores", "adrfield,resfield", 1, "'ad_source','rs_source'")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.186")
           IF OpenFile(,"adrtores") AND NOT DLocate("adrtores", "adrfield = 'ad_discnt'")
                SqlInsert("adrtores", "adrfield,resfield", 1, "'ad_discnt','rs_discnt'")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.193")
           IF OpenFileDirect(,"grid") AND OpenFileDirect(,"screens")
                SqlDelete("grid", "gr_label = 'MNGBESTUHLUNGCTRL'")
                SqlDelete("screens", "sc_label = 'MNGBESTUHLUNGCTRL'")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.200")
           IF OpenFile(,"param")
                SqlUpdate("param", "pa_avltime = 0", "pa_avltime = 1")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.204")
           IF OpenFile(,"ressplit") AND OpenFile(,"ratearti")
                UPDATE ressplit SET rl_rdate = rl_date + ratearti.ra_onlyon WHERE SEEK(ressplit.rl_ratecod+STR(ressplit.rl_raid,10),"ratearti","Tag2") OR 1=1
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.215")
           IF OpenFile(,"ressplit")
                UPDATE ressplit SET rl_rdate = rl_date WHERE EMPTY(rl_rdate)
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.217")
          IF _screen.oGlobal.lUseMainServer AND _screen.oGlobal.lmultiproper
               IF openfile(.F.,"hotel") AND openfile(.F.,"adrmain") AND openfile(.F.,"adrhot")
                    SELECT adrhot
                    SET ORDER TO
                    SELECT hotel
                    SCAN FOR NOT EMPTY(ho_hotcode)
                         l_cAlias = "address_" + ALLTRIM(ho_hotcode)
                         IF USED(l_cAlias)
                              USE IN (l_cAlias)
                         ENDIF
                         USE (ADDBS(ALLTRIM(ho_path))+"data\address.dbf") SHARED IN 0 ALIAS (l_cAlias) AGAIN
                    ENDSCAN
                    SELECT adrmain
                    SET ORDER TO
                    l_nCount = 0
                    WAIT WINDOW "Updating adrhot.dbf" NOWAIT
                    SCAN ALL
                         l_nCount = l_nCount + 1
                         IF MOD(l_nCount,100)=0
                              WAIT WINDOW "Updating adrhot.dbf for adrmain.ad_adid = " + TRANSFORM(adrmain.ad_adid) NOWAIT
                         ENDIF
                         SELECT hotel
                         SCAN FOR NOT EMPTY(ho_hotcode) AND SEEK(adrmain.ad_adid,"address_" + ALLTRIM(ho_hotcode),"tag24")
                              SELECT adrhot
                              l_cFor = "an_adid = " + TRANSFORM(EVALUATE("address_" + ALLTRIM(hotel.ho_hotcode) + ".ad_adid")) + " AND an_hotcode = '" + hotel.ho_hotcode + "'"
                              LOCATE FOR &l_cFor
                              IF NOT FOUND()
                                   INSERT INTO adrhot (an_adid, an_hotcode) VALUES (EVALUATE("address_" + ALLTRIM(hotel.ho_hotcode) + ".ad_adid"), hotel.ho_hotcode)
                              ENDIF
                         ENDSCAN
                    ENDSCAN
                    WAIT CLEAR
               ENDIF
          ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.218")
           IF OpenFileDirect(,"grid") AND OpenFileDirect(,"screens") AND OpenFileDirect(,"gridprop")
               DELETE FROM screens WHERE sc_label = 'FRMEXTRESER '
               DELETE FROM gridprop WHERE gp_label = 'GRDLIST'
               DELETE FROM grid WHERE gr_label = 'GRDLIST'
               REPLACE sc_label WITH "MPRESBRW" FOR sc_label = "FRMRESERVAT" IN screens
           ENDIF
           IF OpenFileDirect(,"billnum")
               SELECT billnum
               SET ORDER TO
               WAIT WINDOW "Updating billnum.bn_userid" NOWAIT
               l_nCount = 0
               SCAN ALL
                    l_nCount = l_nCount + 1
                    IF MOD(l_nCount,100)=0
                         WAIT WINDOW "Updating billnum.bn_userid for bn_billnum = " + TRANSFORM(bn_billnum) NOWAIT
                    ENDIF
                    l_nLines = ALINES(l_aLines,bn_history)
                    IF bn_status = 'CXL' AND l_nLines > 1
                         l_nLines = l_nLines - 1
                    ENDIF

                    l_cLine = l_aLines(l_nLines)
                    l_cUserId = TRIM(SUBSTR(l_cLine, 21, 10))

                    REPLACE bn_userid WITH l_cUserId
               ENDSCAN
               WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.225")
           IF NOT Odbc() AND OpenFile(,"ressplit")
                WAIT WINDOW NOWAIT "Updating ID for RESSPLIT..."
                REPLACE rl_rlid WITH RECNO("ressplit") ALL IN ressplit
                GO BOTTOM IN ressplit
                NextId("RESSPLIT", ressplit.rl_rlid)
                WAIT CLEAR
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.245")
           IF OpenFile(,"param2")
                SqlUpdate("param2",,"pa_docname = (0=0)")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.263")
           IF OpenFileDirect(,"grid") AND OpenFileDirect(,"screens") AND OpenFileDirect(,"gridprop")
                SqlDelete("grid", "gr_label = 'MNGVATGRCTRL'")
                SqlDelete("gridprop", "gp_label = 'MNGVATGRCTRL'")
                SqlDelete("screens", "sc_label = 'MNGVATGRCTRL'")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.292")
           IF OpenFileDirect(,"grid")
                SqlDelete("grid", "gr_label = 'MNGTERMINALCTRL'")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.297")
           IF OpenFileDirect(,"grid") AND OpenFileDirect(,"screens") AND OpenFileDirect(,"gridprop")
                SqlDelete("screens", "sc_label = 'FORMSETFRMLEDGERSBRO'")
                SqlDelete("grid", "gr_label = 'GRDLEDGERSBROWSE'")
                SqlDelete("gridprop", "gp_label = 'GRDLEDGERSBROWSE'")
           ENDIF
      ENDIF
      IF DB_LOWER_VER = CompareVersion("9.10.317")
           IF NOT Odbc() AND OpenFileDirect(,"id") AND OpenFileDirect(,"ratecode")
               IF NOT dlocate("id","id_code = 'RTCODEID'")
                    = nextid("RTCODEID",100)
                    SELECT ratecode
                    REPLACE rc_rcid WITH 0 ALL
                    REPLACE rc_rcid WITH nextid("RTCODEID") ALL
               ENDIF
           ENDIF
      ENDIF
 ENDIF
 * From now, make sure no error occurs, when updating PostgreSQL

 IF DB_LOWER_VER = CompareVersion("9.10.302")
      IF OpenFileDirect(,"building") AND OpenFileDirect(,"param2")
           sqlcursor("SELECT COUNT(*) AS bc FROM building WHERE bu_buildng <> '   '", "curbuildings")
           IF USED("curbuildings") AND curbuildings.bc>0
                SqlUpdate("param2",,"pa_buildin = (0=0)")
           ENDIF
           dclose("curbuildings")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.314")
      IF OpenFile(,"param2")
           SqlUpdate("param2",,"pa_dpend = 24")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.321")
      IF OpenFile(,"param2")
           LOCAL lcDefs
           lcDefs = "%s1 = '<<<START_RES>>>'__||__%s2__||__'<<<END_RES>>><<<START_OOO>>><<<END_OOO>>><<<START_OOS>>><<<END_OOS>>><<<START_ROOM>>><<<END_ROOM>>>'"
           SqlUpdate("param2",,StrToMsg(lcDefs, "pa_romcapt", "IIF(EMPTY(pa_romcapt),'','<<'__||__TRIM(pa_romcapt)__||__'>>')"))
           SqlUpdate("param2",,StrToMsg(lcDefs, "pa_concapt", "IIF(EMPTY(pa_concapt),'','<<'__||__TRIM(pa_concapt)__||__'>>')"))
           SqlUpdate("param2",,StrToMsg(lcDefs, "pa_cdcapt", "IIF(EMPTY(pa_cdcapt),'','<<'__||__TRIM(pa_cdcapt)__||__'>>')"))
           SqlUpdate("param2",,StrToMsg(lcDefs, "pa_gromcap", "IIF(EMPTY(pa_gromcap),'','<<'__||__TRIM(pa_gromcap)__||__'>>')"))
           SqlUpdate("param2",,StrToMsg(lcDefs, "pa_romttt", "TRIM(pa_romttt)"))
           SqlUpdate("param2",,StrToMsg(lcDefs, "pa_conttt", "TRIM(pa_conttt)"))
           SqlUpdate("param2",,StrToMsg(lcDefs, "pa_cdttt", "TRIM(pa_cdttt)"))
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.330")
      IF NOT Odbc()
           PAImportPhones()
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.331")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label = 'MNGTABLERESERCTRL'")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'MNGTABLERESERCTRL'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.333")
      IF NOT Odbc() AND OpenFile(,"reservat") AND OpenFile(,"histres") AND OpenFile(,"post") AND OpenFile(,"histpost") AND OpenFile(,"billnum")
           WAIT WINDOW NOWAIT "Restoring bill numbers..."
           
           SELECT ps_billnum, ps_reserid, ps_window, ps_date, ps_time ;
                FROM post ;
                LEFT JOIN billnum ON bn_billnum = ps_billnum ;
                WHERE ps_date > DATE(2013,1,1) AND ps_reserid > 1 AND ps_window > 0 AND NOT EMPTY(ps_billnum) AND ISNULL(bn_billnum) ;
           UNION ALL ;
           SELECT hp_billnum, hp_reserid, hp_window, hp_date, hp_time ;
                FROM histpost ;
                LEFT JOIN post ON ps_postid = hp_postid ;
                LEFT JOIN billnum ON bn_billnum = hp_billnum ;
                WHERE hp_date > DATE(2013,1,1) AND hp_reserid > 1 AND hp_window > 0 AND NOT EMPTY(hp_billnum) AND ISNULL(ps_postid) AND ISNULL(bn_billnum) ;
                INTO CURSOR curBillnum

           SELECT *, MAX(ps_date) AS bn_date FROM curBillnum GROUP BY ps_billnum INTO CURSOR curBillnum

           SELECT curBillnum.*, NVL(rs_rsid,hr_rsid) AS rs_rsid, NVL(rs_addrid,hr_addrid) AS rs_addrid, ;
                  NVL(rs_compid,hr_compid) AS rs_compid, NVL(rs_invid,hr_invid) AS rs_invid, ;
                  NVL(rs_apid,hr_apid) AS rs_apid, NVL(rs_invapid,hr_invapid) AS rs_invapid, ;
                  NVL(rs_billins,hr_billins) AS rs_billins, ;
                  NVL(rs_paynum1,hr_paynum1) AS rs_paynum1, ;
                  NVL(rs_paynum2,hr_paynum2) AS rs_paynum2, ;
                  NVL(rs_paynum3,hr_paynum3) AS rs_paynum3, ;
                  NVL(rs_paynum4,hr_paynum4) AS rs_paynum4, ;
                  NVL(rs_paynum5,hr_paynum5) AS rs_paynum5, ;
                  NVL(rs_paynum6,hr_paynum6) AS rs_paynum6 ;
                FROM curBillnum ;
                LEFT JOIN reservat ON rs_reserid = ps_reserid ;
                LEFT JOIN histres ON hr_reserid = ps_reserid ;
                WHERE NOT ISNULL(rs_reserid) OR NOT ISNULL(hr_reserid) ;
                INTO CURSOR curBillnum

           SELECT post.ps_billnum, ps_amount ;
                FROM post ;
                INNER JOIN curBillnum ON curBillnum.ps_billnum = post.ps_billnum ;
                WHERE ps_artinum <> 0 AND NOT ps_cancel AND NOT ps_split ;
           UNION ALL ;
           SELECT hp_billnum, hp_amount ;
                FROM histpost ;
                LEFT JOIN post ON ps_postid = hp_postid ;
                INNER JOIN curBillnum ON curBillnum.ps_billnum = histpost.hp_billnum ;
                WHERE hp_artinum <> 0 AND NOT hp_cancel AND NOT hp_split AND ISNULL(ps_postid) ;
                INTO CURSOR curPost

           SELECT ps_billnum, SUM(ps_amount) AS ps_amount FROM curPost GROUP BY ps_billnum INTO CURSOR curPost

           SELECT curBillnum.ps_billnum AS bn_billnum, ;
                  ps_reserid AS bn_reserid, ;
                  ps_window AS bn_window, ;
                  ProcBill("BillAddrId", ps_window, rs_rsid, rs_addrid) AS bn_addrid, ;
                  NVL(ps_amount,0) AS bn_amount, ;
                  CRLF+DTOC(bn_date)+" "+ps_time+" "+g_userid+" CHECK OUT CREATED"+CRLF+DTOC(bn_date)+" "+ps_time+" "+g_userid+" CHKOUT No Print - Quick Out" AS bn_history, ;
                  "PCO" AS bn_status, ;
                  bn_date, ;
                  ICASE(ps_window=1, rs_paynum1, ps_window=2, rs_paynum2, ps_window=3, rs_paynum3, ps_window=4, rs_paynum4, ps_window=5, rs_paynum5, ps_window=6, rs_paynum6, 0) AS bn_paynum, ;
                  ProcBill("BillApId", ps_window, rs_addrid, rs_compid, rs_invid, rs_apid, rs_invapid) AS bn_apid, ;
                  g_userid AS bn_userid ;
                FROM curBillnum ;
                LEFT JOIN curPost ON curPost.ps_billnum = curBillnum.ps_billnum ;
                INTO CURSOR curBillnum

           SELECT curBillnum.*, IIF(EMPTY(NVL(ad_company,"")), 1, 2) AS bn_type FROM curBillnum ;
                LEFT JOIN address ON ad_addrid = bn_addrid AND NOT EMPTY(bn_addrid) ;
                INTO CURSOR curBillnum
           WAIT WINDOW NOWAIT "Restoring "+TRANSFORM(RECCOUNT())+" bill numbers..."
           SCAN
                DO CASE
                     CASE SEEK(bn_reserid,"reservat","tag1")
                          REPLACE ("rs_billnr"+TRANSFORM(EVL(curBillnum.bn_window,1))) WITH curBillnum.bn_billnum, rs_copyw1 WITH 1 IN reservat
                     CASE SEEK(bn_reserid,"histres","tag1")
                          REPLACE ("hr_billnr"+TRANSFORM(EVL(curBillnum.bn_window,1))) WITH curBillnum.bn_billnum, hr_copyw1 WITH 1 IN histres
                     OTHERWISE
                ENDCASE
           ENDSCAN

           SELECT billnum
           APPEND FROM DBF("curBillnum")

           DClose("curBillnum")
           DClose("curPost")

           WAIT CLEAR
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.338")
      IF NOT Odbc() AND OpenFile(,"reservat") AND OpenFile(,"histres") AND OpenFile(,"extreser")
          LOCAL l_lLibLoaded, l_cNewVal
          l_lLibLoaded = "vfpencryption71.fll" $ LOWER(SET("Library"))
          IF NOT l_lLibLoaded
               SET LIBRARY TO common\dll\vfpencryption71.fll ADDITIVE
          ENDIF
          LOCAL l_cNewVal
          SELECT reservat
          SCAN ALL
               WAIT WINDOW "Encrypting Creditcards rs_reserid:" + TRANSFORM(rs_reserid) NOWAIT
               IF NOT EMPTY(rs_ccnum)
                    l_cNewVal = CFEncryptString(rs_ccnum)
                    REPLACE rs_ccnum WITH l_cNewVal
               ENDIF
               IF NOT EMPTY(rs_ccexpy)
                    l_cNewVal = CFEncryptString(rs_ccexpy)
                    REPLACE rs_ccexpy WITH l_cNewVal
               ENDIF
               IF NOT EMPTY(rs_ccauth)
                    l_cNewVal = CFEncryptString(rs_ccauth)
                    REPLACE rs_ccauth WITH l_cNewVal
               ENDIF
          ENDSCAN
          SELECT histres
          SCAN ALL
               WAIT WINDOW "Encrypting Creditcards hr_reserid:" + TRANSFORM(hr_reserid) NOWAIT
               IF NOT EMPTY(hr_ccnum)
                    l_cNewVal = CFEncryptString(hr_ccnum)
                    REPLACE hr_ccnum WITH l_cNewVal
               ENDIF
               IF NOT EMPTY(hr_ccexpy)
                    l_cNewVal = CFEncryptString(hr_ccexpy)
                    REPLACE hr_ccexpy WITH l_cNewVal
               ENDIF
               IF NOT EMPTY(hr_ccauth)
                    l_cNewVal = CFEncryptString(hr_ccauth)
                    REPLACE hr_ccauth WITH l_cNewVal
               ENDIF
          ENDSCAN
          SELECT extreser
          SCAN ALL
               WAIT WINDOW "Encrypting Creditcards er_extid:" + TRANSFORM(er_extid) NOWAIT
               IF NOT EMPTY(er_ccnum)
                    l_cNewVal = CFEncryptString(er_ccnum)
                    REPLACE er_ccnum WITH l_cNewVal
               ENDIF
               IF NOT EMPTY(er_ccexpy)
                    l_cNewVal = CFEncryptString(er_ccexpy)
                    REPLACE er_ccexpy WITH l_cNewVal
               ENDIF
               IF NOT EMPTY(er_cccvc)
                    IF ALLTRIM(er_cccvc)=="0"
                         l_cNewVal = ""
                    ELSE
                         l_cNewVal = CFEncryptString(er_cccvc)
                    ENDIF
                    REPLACE er_cccvc WITH l_cNewVal
               ENDIF
          ENDSCAN
          IF NOT l_lLibLoaded
               RELEASE LIBRARY vfpencryption71.fll
          ENDIF
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.339")
      IF OpenFile(,"ratecode")
           SqlUpdate("ratecode", "rc_period = 5 AND rc_moposon = 0", "rc_moposon = 1")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.357")
      IF OpenFile(,"param2")
           SqlUpdate("param2",,"pa_wbautoc = (pa_wbmin > 0)")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.375")
      IF OpenFile(,"reservat")
           WAIT WINDOW "Updating rs_rcsync..." NOWAIT
           SqlUpdate("reservat", "DTOS(rs_depdate)__||__rs_roomnum >= " + SqlCnv(DTOS(SysDate()),.T.) + " AND rs_status NOT IN ('OUT','CXL','NS ','LST') " + ;
                "AND (rs_ratedat = {} OR rs_ratedat < rs_depdate-1) AND NOT rs_ratecod IN ('DUM','COMP')", "rs_rcsync = (1=1)")
           WAIT CLEAR
      ENDIF
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label = 'MNGRTCTRL'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.380")
      IF OpenFile(,"post")
           SqlUpdate("post","ps_setid > 0 AND EMPTY(ps_ratecod) AND NOT ps_split","ps_setid = 0")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.383")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label = 'GRDCWRATES'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.387")
      IF OpenFile(,"reservat") AND OpenFile(,"ressplit") AND OpenFile(,"hresplit")
           WAIT WINDOW "Reservation splits moving to history..." NOWAIT
           IF Odbc()
                SqlInsert("hresplit",,2, "SELECT rl_artinum, rl_artityp, rl_date, rl_price, rl_ratecod, rl_rdate, rl_rlid, rl_rsid, rl_units FROM ressplit WHERE rl_rlid NOT IN (SELECT rl_rlid FROM hresplit) AND rl_rsid NOT IN (SELECT rs_rsid FROM reservat)")
                SqlDelete("ressplit", "rl_rlid IN (SELECT rl_rlid FROM hresplit)")
           ELSE
                SELECT ressplit
                l_nCount = RECCOUNT()
                l_nPercent = 0
                SCAN FOR NOT SEEK(ressplit.rl_rlid, "hresplit", "tag1") AND NOT SEEK(ressplit.rl_rsid, "reservat", "tag33")
                     IF l_nPercent < 100*RECNO()/l_nCount
                          l_nPercent = ROUND(100*RECNO()/l_nCount,0)
                          WAIT "Reservation splits moving to history: " + TRANSFORM(l_nPercent) + " %" WINDOW NOWAIT
                     ENDIF
                     SCATTER MEMO NAME l_oRessplit
                     INSERT INTO hresplit FROM NAME l_oRessplit
                     DELETE
                ENDSCAN
           ENDIF
           WAIT CLEAR
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.389")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label = 'MNGEMPLOYEECTRL'")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'MNGEMPLOYEECTRL'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.398")
      IF OpenFile(,"param2")
           * As default it should be false!
           SqlUpdate("param2",,"pa_ooostd = (0=1)")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.409")
      IF _screen.oGlobal.lVehicleRentMode AND OpenFile(,"roomtype") AND OpenFile(,"reservat") AND OpenFile(,"histres")
           SqlUpdate("reservat","rt_roomtyp = rs_roomtyp AND rs_lstart = '   '","rs_lstart = rt_buildng, rs_lfinish = rt_buildng FROM roomtype")
           SqlUpdate("histres","rt_roomtyp = hr_roomtyp AND hr_lstart = '   '","hr_lstart = rt_buildng, hr_lfinish = rt_buildng FROM roomtype")
      ENDIF
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('MNGOOOCTRL','MNGOOSCTRL')")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("9.10.416")
      IF OpenFile(,"reservat")
           WAIT WINDOW "Updating rs_rcsync..." NOWAIT
           SqlUpdate("reservat", "DTOS(rs_depdate)__||__rs_roomnum >= " + SqlCnv(DTOS(SysDate()),.T.) + " AND rs_status NOT IN ('OUT','CXL','NS ','LST') " + ;
                "AND (rs_ratedat = {} OR rs_ratedat < rs_depdate-1) AND NOT rs_ratecod IN ('DUM','COMP')", "rs_rcsync = (1=1)")
           WAIT CLEAR
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.2")
      IF OpenFile(,"param2")
           SqlUpdate("param2",,"pa_wimax = 24")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.8")
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'FRMEXTRESER'")
      ENDIF
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('GRDLIST')")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.13")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('GRDRESFIX','MNGHOUSEKEEPCTRL')")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'FRSRESFIXFRMRESFIX'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.19")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('MNGFEATCTRL')")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'MNGFEATCTRL'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.37")
      IF OpenFileDirect(,"grid") AND OpenFileDirect(,"gridprop")
           SqlDelete("grid", "gr_label = 'TIMEWORKHOURSDETAILS'")
           SqlDelete("gridprop", "gp_label = 'TIMEWORKHOURSDETAILS'")
      ENDIF
      IF OpenFileDirect(,"azepick")
           SqlInsert("azepick", "aq_label, aq_charcod, aq_nval1, aq_lang1, aq_lang2, aq_lang3, aq_lang4, aq_lang5, aq_lang6, aq_lang7, aq_lang8, aq_lang9, aq_lang10, aq_lang11", 1, "'PARAMS', 'NGS', 20" + REPLICATE(", 'Night hours start'", 11))
           SqlInsert("azepick", "aq_label, aq_charcod, aq_nval1, aq_lang1, aq_lang2, aq_lang3, aq_lang4, aq_lang5, aq_lang6, aq_lang7, aq_lang8, aq_lang9, aq_lang10, aq_lang11", 1, "'PARAMS', 'NGE', 6" + REPLICATE(", 'Night hours end'", 11))
           SqlInsert("azepick", "aq_label, aq_charcod, aq_nval1, aq_lang1, aq_lang2, aq_lang3, aq_lang4, aq_lang5, aq_lang6, aq_lang7, aq_lang8, aq_lang9, aq_lang10, aq_lang11", 1, "'PARAMS', 'MDS', 0" + REPLICATE(", 'Midnight hours start'", 11))
           SqlInsert("azepick", "aq_label, aq_charcod, aq_nval1, aq_lang1, aq_lang2, aq_lang3, aq_lang4, aq_lang5, aq_lang6, aq_lang7, aq_lang8, aq_lang9, aq_lang10, aq_lang11", 1, "'PARAMS', 'MDE', 4" + REPLICATE(", 'Midnight hours end'", 11))
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.41")
      IF OpenFileDirect(,"reservat") AND OpenFileDirect(,"ressplit")
           *DELETE FROM ressplit WHERE rl_rdate < rl_date AND rl_rlid IN ;
                (SELECT rl_rlid FROM ressplit ;
                     INNER JOIN reservat ON rl_rsid = rs_rsid ;
                     WHERE DTOS(rs_depdate)+rs_roomnum >= DTOS(SysDate()) AND rl_rdate < rs_arrdate)
           SELECT reservat
           SCAN FOR DTOS(rs_depdate)+rs_roomnum >= DTOS(SysDate())
                DELETE FOR rl_rsid = reservat.rs_rsid AND rl_rdate < reservat.rs_arrdate AND rl_rdate < rl_date IN ressplit
           ENDSCAN
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.51")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('MNGCITWEBRATESCTRL')")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'MNGCITWEBRATESCTRL'")
      ENDIF
      IF OpenFileDirect(,"cwvrrt")
           SqlUpdate("cwvrrt","NOT eq_inactiv","eq_ymactiv = (1=1)")
      ENDIF
      IF OpenFileDirect(,"season") AND OpenFileDirect(,"evint") AND OpenFileDirect(,"events")
           LOCAL lcSql, lcurEvents
           TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2+8
                SELECT ev_evid, se_color FROM evint
                     INNER JOIN events ON ei_evid = ev_evid
                     INNER JOIN season ON se_date = ei_from
                     WHERE EMPTY(ev_color)
                     ORDER BY ev_evid, ei_from
           ENDTEXT
           lcurEvents = SqlCursor(lcSql,,,,,,,.T.)
           SCAN
                SqlUpdate("events", "ev_evid = " + SqlCnv(ev_evid), "ev_color = " + SqlCnv(se_color))
           ENDSCAN
           DClose(lcurEvents)
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.54")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('GRDCWRATES')")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'FRMMNGCWVRRT'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.57")
      IF OpenFileDirect(,"roomfeat")
           SqlUpdate("roomfeat","NOT EMPTY(rf_artinum)","rf_resfix = (1=1)")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.66")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('MNGBUILDINGCTRL')")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.75")
      IF NOT odbc() AND OpenFileDirect(,"reservat") AND OpenFileDirect(,"resrate") AND OpenFileDirect(,"grid")
           WAIT WINDOW "Updating reservat.rs_rcsync for reservations with wrong ratecode key in resrate.rr_ratecod..." NOWAIT
           UPDATE reservat SET rs_rcsync = (1=1) WHERE rs_rcsync = (1=0) AND rs_reserid IN (SELECT DISTINCT rr_reserid FROM resrate WHERE SUBSTR(rr_ratecod,15,8) = ' ')
           WAIT CLEAR
           SqlDelete("grid", "gr_label IN ('MNGALLOTTCTRL')")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.80")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label LIKE 'MNG%'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.102")
      IF OpenFileDirect(,"histres") AND OpenFileDirect(,"reservat") AND OpenFileDirect(,"billnum") AND OpenFileDirect(,"pswindow") AND OpenFileDirect(,"hpwindow")
           LOCAL i, llHpwindowFound, llCurHpwindowFound, llPswindowFound, llCurPswindowFound, loPswindow, lcCopyField, lcNoteField, lcBlamidField, lnWindow, lnPaynum

           SELECT * FROM pswindow WHERE 0=1 INTO CURSOR curPswindow READWRITE
           INDEX ON PADL(pw_rsid,10)+PADL(pw_window,10) TAG tag4
           SELECT * FROM hpwindow WHERE 0=1 INTO CURSOR curHpwindow READWRITE
           INDEX ON PADL(pw_rsid,10)+PADL(pw_window,10) TAG tag4

           SELECT billnum
           SET ORDER TO
           REPLACE bn_rsid WITH histres.hr_rsid FOR bn_reserid > 0.1 AND EMPTY(bn_rsid) AND SEEK(billnum.bn_reserid,"histres","tag1")
           REPLACE bn_rsid WITH reservat.rs_rsid FOR bn_reserid > 0.1 AND EMPTY(bn_rsid) AND SEEK(billnum.bn_reserid,"reservat","tag1")
           SCAN FOR bn_reserid > 0.1
                WAIT WINDOW "BILLNUM -> PSWINDOW ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                IF EMPTY(bn_window) OR EMPTY(bn_paynum)
                     lnWindow = 0
                     lnPaynum = 0
                     DO CASE
                          CASE SEEK(billnum.bn_reserid, "histres", "tag1")
                               DO CASE
                                    CASE histres.hr_billnr1 = bn_billnum
                                         lnWindow = 1
                                         lnPaynum = histres.hr_paynum1
                                    CASE histres.hr_billnr2 = bn_billnum
                                         lnWindow = 2
                                         lnPaynum = histres.hr_paynum2
                                    CASE histres.hr_billnr3 = bn_billnum
                                         lnWindow = 3
                                         lnPaynum = histres.hr_paynum3
                                    CASE histres.hr_billnr4 = bn_billnum
                                         lnWindow = 4
                                         lnPaynum = histres.hr_paynum4
                                    CASE histres.hr_billnr5 = bn_billnum
                                         lnWindow = 5
                                         lnPaynum = histres.hr_paynum5
                                    CASE histres.hr_billnr6 = bn_billnum
                                         lnWindow = 6
                                         lnPaynum = histres.hr_paynum6
                                    OTHERWISE
                               ENDCASE
                          CASE SEEK(billnum.bn_reserid, "reservat", "tag1")
                               DO CASE
                                    CASE reservat.rs_billnr1 = bn_billnum
                                         lnWindow = 1
                                         lnPaynum = reservat.rs_paynum1
                                    CASE reservat.rs_billnr2 = bn_billnum
                                         lnWindow = 2
                                         lnPaynum = reservat.rs_paynum2
                                    CASE reservat.rs_billnr3 = bn_billnum
                                         lnWindow = 3
                                         lnPaynum = reservat.rs_paynum3
                                    CASE reservat.rs_billnr4 = bn_billnum
                                         lnWindow = 4
                                         lnPaynum = reservat.rs_paynum4
                                    CASE reservat.rs_billnr5 = bn_billnum
                                         lnWindow = 5
                                         lnPaynum = reservat.rs_paynum5
                                    CASE reservat.rs_billnr6 = bn_billnum
                                         lnWindow = 6
                                         lnPaynum = reservat.rs_paynum6
                                    OTHERWISE
                               ENDCASE
                          OTHERWISE
                     ENDCASE
                     IF EMPTY(bn_window) AND NOT EMPTY(lnWindow)
                          REPLACE bn_window WITH lnWindow
                     ENDIF
                     IF EMPTY(bn_paynum) AND NOT EMPTY(lnPaynum)
                          REPLACE bn_paynum WITH lnPaynum
                     ENDIF
                ENDIF
                IF NOT EMPTY(bn_rsid) AND NOT EMPTY(bn_window)
                     llHpwindowFound = SEEK(PADL(billnum.bn_rsid,10)+PADL(billnum.bn_window,10),"hpwindow","tag4")
                     llCurHpwindowFound = SEEK(PADL(billnum.bn_rsid,10)+PADL(billnum.bn_window,10),"curHpwindow","tag4")
                     llPswindowFound = SEEK(PADL(billnum.bn_rsid,10)+PADL(billnum.bn_window,10),"pswindow","tag4")
                     llCurPswindowFound = SEEK(PADL(billnum.bn_rsid,10)+PADL(billnum.bn_window,10),"curPswindow","tag4")
                     DO CASE
                          CASE llHpwindowFound
                               SELECT hpwindow
                          CASE llCurHpwindowFound
                               SELECT curHpwindow
                          CASE llCurPswindowFound
                               SELECT curPswindow
                          OTHERWISE
                               SELECT pswindow
                     ENDCASE
                     SCATTER MEMO NAME loPswindow
                     loPswindow.pw_rsid = billnum.bn_rsid
                     loPswindow.pw_window = billnum.bn_window
                     loPswindow.pw_winpos = billnum.bn_window
                     IF NOT llHpwindowFound AND NOT llCurHpwindowFound AND SEEK(billnum.bn_rsid,"histres","tag15")
                          INSERT INTO curHpwindow FROM NAME loPswindow
                     ENDIF
                     IF NOT llPswindowFound AND NOT llCurPswindowFound AND SEEK(billnum.bn_rsid,"reservat","tag33")
                          INSERT INTO curPswindow FROM NAME loPswindow
                     ENDIF
                ENDIF
                SELECT billnum
           ENDSCAN
           SELECT hpwindow
           SCATTER MEMO BLANK NAME loPswindow
           SELECT histres
           SET ORDER TO
           SCAN FOR NOT EMPTY(hr_billins) OR NOT EMPTY(hr_rglayou) OR NOT EMPTY(hr_bmsto1w) OR ;
                     NOT EMPTY(hr_copyw1) OR NOT EMPTY(hr_copyw2) OR NOT EMPTY(hr_copyw3) OR NOT EMPTY(hr_copyw4) OR NOT EMPTY(hr_copyw5) OR NOT EMPTY(hr_copyw6) OR ;
                     NOT EMPTY(hr_notew1) OR NOT EMPTY(hr_notew2) OR NOT EMPTY(hr_notew3) OR NOT EMPTY(hr_notew4) OR NOT EMPTY(hr_notew5) OR NOT EMPTY(hr_notew6)
                WAIT WINDOW "HISTRES -> HPWINDOW ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                FOR i = 1 TO 6
                     lcCopyField = "hr_copyw" + TRANSFORM(i)
                     lcNoteField = "hr_notew" + TRANSFORM(i)
                     lnUseBDate = ASC(SUBSTR(hr_rglayou,7,1))
                     loPswindow.pw_rsid = hr_rsid
                     loPswindow.pw_window = i
                     loPswindow.pw_winpos = i
                     loPswindow.pw_addrid = IIF(i=1, 0, INT(VAL(SUBSTR(MLINE(hr_billins, IIF(i>3,i+1,i)), 1, 12))))
                     loPswindow.pw_billsty = SUBSTR(hr_rglayou,i,1)
                     loPswindow.pw_udbdate = BITTEST(lnUseBDate,6) AND BITTEST(lnUseBDate,i-1)
                     loPswindow.pw_bmsto1w = (i > 1) AND (SUBSTR(hr_bmsto1w,i-1,1) = "1")
                     loPswindow.pw_copy = &lcCopyField
                     loPswindow.pw_note = &lcNoteField
                     DO CASE
                          CASE EMPTY(loPswindow.pw_addrid) AND EMPTY(loPswindow.pw_billsty) AND NOT loPswindow.pw_udbdate AND ;
                                    NOT loPswindow.pw_bmsto1w AND EMPTY(loPswindow.pw_copy) AND EMPTY(loPswindow.pw_note)
                          CASE SEEK(PADL(histres.hr_rsid,10)+PADL(i,10),"hpwindow","tag4")
                               SELECT hpwindow
                               GATHER NAME loPswindow FIELDS pw_addrid, pw_billsty, pw_udbdate, pw_bmsto1w, pw_copy, pw_note MEMO
                          CASE SEEK(PADL(histres.hr_rsid,10)+PADL(i,10),"curHpwindow","tag4")
                               SELECT curHpwindow
                               GATHER NAME loPswindow FIELDS pw_addrid, pw_billsty, pw_udbdate, pw_bmsto1w, pw_copy, pw_note MEMO
                          OTHERWISE
                               INSERT INTO curHpwindow FROM NAME loPswindow
                     ENDCASE
                     SELECT histres
                NEXT
           ENDSCAN
           SELECT reservat
           SET ORDER TO
           SCAN FOR NOT EMPTY(rs_billins) OR NOT EMPTY(rs_rglayou) OR NOT EMPTY(rs_bmsto1w) OR ;
                     NOT EMPTY(rs_copyw1) OR NOT EMPTY(rs_copyw2) OR NOT EMPTY(rs_copyw3) OR NOT EMPTY(rs_copyw4) OR NOT EMPTY(rs_copyw5) OR NOT EMPTY(rs_copyw6) OR ;
                     NOT EMPTY(rs_notew1) OR NOT EMPTY(rs_notew2) OR NOT EMPTY(rs_notew3) OR NOT EMPTY(rs_notew4) OR NOT EMPTY(rs_notew5) OR NOT EMPTY(rs_notew6) OR ;
                     NOT EMPTY(rs_blamid1) OR NOT EMPTY(rs_blamid2) OR NOT EMPTY(rs_blamid3) OR NOT EMPTY(rs_blamid4) OR NOT EMPTY(rs_blamid5) OR NOT EMPTY(rs_blamid6)
                WAIT WINDOW "RESERVAT -> PSWINDOW ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                FOR i = 1 TO 6
                     lcCopyField = "rs_copyw" + TRANSFORM(i)
                     lcNoteField = "rs_notew" + TRANSFORM(i)
                     lcBlamidField = "rs_blamid" + TRANSFORM(i)
                     lnUseBDate = ASC(SUBSTR(rs_rglayou,7,1))
                     loPswindow.pw_rsid = rs_rsid
                     loPswindow.pw_window = i
                     loPswindow.pw_winpos = i
                     loPswindow.pw_addrid = IIF(i=1, 0, INT(VAL(SUBSTR(MLINE(rs_billins, IIF(i>3,i+1,i)), 1, 12))))
                     loPswindow.pw_billsty = SUBSTR(rs_rglayou,i,1)
                     loPswindow.pw_udbdate = BITTEST(lnUseBDate,6) AND BITTEST(lnUseBDate,i-1)
                     loPswindow.pw_bmsto1w = (i > 1) AND (SUBSTR(rs_bmsto1w,i-1,1) = "1")
                     loPswindow.pw_copy = &lcCopyField
                     loPswindow.pw_note = &lcNoteField
                     loPswindow.pw_blamid = &lcBlamidField
                     DO CASE
                          CASE EMPTY(loPswindow.pw_addrid) AND EMPTY(loPswindow.pw_billsty) AND NOT loPswindow.pw_udbdate AND ;
                                    NOT loPswindow.pw_bmsto1w AND EMPTY(loPswindow.pw_copy) AND EMPTY(loPswindow.pw_note) AND EMPTY(loPswindow.pw_blamid)
                          CASE SEEK(PADL(reservat.rs_rsid,10)+PADL(i,10),"pswindow","tag4")
                               SELECT pswindow
                               GATHER NAME loPswindow FIELDS pw_addrid, pw_billsty, pw_udbdate, pw_bmsto1w, pw_copy, pw_note, pw_blamid MEMO
                          CASE SEEK(PADL(reservat.rs_rsid,10)+PADL(i,10),"curPswindow","tag4")
                               SELECT curPswindow
                               GATHER NAME loPswindow FIELDS pw_addrid, pw_billsty, pw_udbdate, pw_bmsto1w, pw_copy, pw_note, pw_blamid MEMO
                          OTHERWISE
                               INSERT INTO curPswindow FROM NAME loPswindow
                     ENDCASE
                     SELECT reservat
                NEXT
           ENDSCAN
           IF RECCOUNT("curHpwindow") > 0 OR RECCOUNT("curPswindow") > 0
                loPswindow.pw_pwid = NextId("PSWINDOW")-1
                REPLACE pw_pwid WITH loPswindow.pw_pwid + RECNO("curHpwindow") ALL IN curHpwindow
                loPswindow.pw_pwid = loPswindow.pw_pwid + RECCOUNT("curHpwindow")
                REPLACE pw_pwid WITH loPswindow.pw_pwid + RECNO("curPswindow") ALL IN curPswindow
                loPswindow.pw_pwid = loPswindow.pw_pwid + RECCOUNT("curPswindow")
                NextId("PSWINDOW", loPswindow.pw_pwid)
                SELECT hpwindow
                APPEND FROM DBF("curHpwindow")
                SELECT pswindow
                APPEND FROM DBF("curPswindow")
           ENDIF
           USE IN curHpwindow
           USE IN curPswindow
           REPLACE pw_winpos WITH hpwindow.pw_window FOR EMPTY(pw_winpos) IN hpwindow
           REPLACE pw_winpos WITH pswindow.pw_window FOR EMPTY(pw_winpos) IN pswindow
           WAIT CLEAR
      ENDIF
      DO FmtBill1Note IN FmtFrx
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.113")
      IF OpenFileDirect(,"billnum") AND OpenFileDirect(,"reservat") AND OpenFileDirect(,"post") AND OpenFileDirect(,"pswindow")
           REPLACE bn_rsid WITH IIF(bn_reserid > 0.1 AND SEEK(billnum.bn_reserid,"reservat","tag1"), reservat.rs_rsid, 0) FOR EMPTY(bn_rsid) IN billnum
           REPLACE pw_winpos WITH pswindow.pw_window FOR EMPTY(pw_winpos) IN pswindow
           SELECT * FROM pswindow WHERE 0=1 INTO CURSOR curPswindow READWRITE
           SELECT rs_rsid, ps_window FROM post ;
                INNER JOIN reservat ON rs_reserid = ps_reserid ;
                WHERE ps_reserid > 0.1 AND ps_window > 0 ;
                GROUP BY 1, 2 ;
                ORDER BY 1, 2 ;
                INTO CURSOR curPost
           SCAN
                WAIT WINDOW "POST -> PSWINDOW ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                IF NOT SEEK(PADL(curPost.rs_rsid,10)+PADL(curPost.ps_window,10),"pswindow","tag4")
                     INSERT INTO curPswindow (pw_rsid, pw_window, pw_winpos) VALUES (curPost.rs_rsid, curPost.ps_window, curPost.ps_window)
                ENDIF
                SELECT curPost
           ENDSCAN
           IF RECCOUNT("curPswindow") > 0
                lnPswindowId = NextId("PSWINDOW")-1
                REPLACE pw_pwid WITH lnPswindowId + RECNO("curPswindow") ALL IN curPswindow
                lnPswindowId = lnPswindowId + RECCOUNT("curPswindow")
                NextId("PSWINDOW", lnPswindowId)
                SELECT pswindow
                APPEND FROM DBF("curPswindow")
           ENDIF
           USE IN curPost
           USE IN curPswindow
           WAIT CLEAR
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.114")
      IF OpenFileDirect(,"article") AND OpenFileDirect(,"resrart") AND OpenFileDirect(,"ratearti")
           REPLACE ar_notef WITH ar_note FOR NOT EMPTY(ar_note) IN article
           REPLACE ra_notef WITH ra_note FOR NOT EMPTY(ra_note) IN resrart
           REPLACE ra_notef WITH ra_note FOR NOT EMPTY(ra_note) IN ratearti
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.119")
      UpdateVoucherToPostRelation100119()
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.124")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('GRDRATES')")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'FRSRATESFRMRATES'")
      ENDIF
      IF OpenFileDirect(,"resrate") AND OpenFileDirect(,"reservat") AND OpenFileDirect(,"roomtype")
           SELECT reservat
           l_nRecCount = RECCOUNT()
           SCAN FOR NOT EMPTY(rs_arrtime) AND NOT EMPTY(rs_deptime)
                WAIT WINDOW "Update resrate.rr_arrtime and resrate.rr_deptime for conference reservations " + PADL(INT((RECNO()/l_nRecCount)*100),3,"0") + " %" NOWAIT
                IF DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(reservat.rs_roomtyp,.T.), "rt_group = 2")
                     UPDATE resrate SET rr_arrtime = reservat.rs_arrtime, rr_deptime = reservat.rs_deptime WHERE rr_reserid = reservat.rs_reserid AND rr_arrtime = '     ' AND rr_arrtime = '     '
                ENDIF
           ENDSCAN
           WAIT CLEAR
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.139")
      IF OpenFileDirect(,"employee") AND TYPE("employee.em_vacatio") = "N" AND DLocate("employee", "NOT EMPTY(em_vacatio)") AND OpenFileDirect(,"employeh")
           INSERT INTO employeh (eh_emid, eh_vacatio) SELECT em_emid, em_vacatio FROM employee WHERE NOT EMPTY(em_vacatio)
           LOCAL l_nYear
           l_nYear = YEAR(SysDate())
           BLANK FIELDS em_vacatio ALL IN employee
           REPLACE eh_ehid WITH NextId("EMPLOYEH"), eh_year WITH l_nYear ALL IN employeh
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.142")
      IF OpenFileDirect(,"param2") AND OpenFileDirect(,"workbrkd")
           UPDATE workbrkd ;
                SET wd_cwhour0 = param2.pa_cwhour0, wd_cwhour1 = param2.pa_cwhour1, wd_cwhour2 = param2.pa_cwhour2, wd_cwhour3 = param2.pa_cwhour3, ;
                wd_wbmin1 = param2.pa_wbmin1, wd_wbmin2 = param2.pa_wbmin2, wd_wbmin3 = param2.pa_wbmin3 ;
                FROM param2 ;
                WHERE .T.
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.153")
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'MNGEMPLOYEECTRL'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.155")
      DBUpdateVersion10_00_155()
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.0.185")
      IF OpenFileDirect(,"address") AND OpenFileDirect(,"hresext") AND OpenFileDirect(,"reservat") AND ;
                OpenFileDirect(,"adrfeat") AND OpenFileDirect(,"hresfeat") AND OpenFileDirect(,"resfeat")
           SELECT address
           SCAN FOR NOT EMPTY(ad_feat1+ad_feat2+ad_feat3)
                WAIT WINDOW "ADDRESS -> ADRFEAT ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                IF NOT EMPTY(ad_feat1)
                     INSERT INTO adrfeat (fa_addrid, fa_feature) VALUES (address.ad_addrid, address.ad_feat1)
                ENDIF
                IF NOT EMPTY(ad_feat2) AND ad_feat2 <> ad_feat1
                     INSERT INTO adrfeat (fa_addrid, fa_feature) VALUES (address.ad_addrid, address.ad_feat2)
                ENDIF
                IF NOT EMPTY(ad_feat3) AND ad_feat3 <> ad_feat1 AND ad_feat3 <> ad_feat2
                     INSERT INTO adrfeat (fa_addrid, fa_feature) VALUES (address.ad_addrid, address.ad_feat3)
                ENDIF
           ENDSCAN
           SELECT hresext
           SCAN FOR NOT EMPTY(rs_feat1+rs_feat2+rs_feat3)
                WAIT WINDOW "HRESEXT -> HRESFEAT ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                IF NOT EMPTY(rs_feat1)
                     INSERT INTO hresfeat (fr_rsid, fr_feature) VALUES (hresext.rs_rsid, hresext.rs_feat1)
                ENDIF
                IF NOT EMPTY(rs_feat2) AND rs_feat2 <> rs_feat1
                     INSERT INTO hresfeat (fr_rsid, fr_feature) VALUES (hresext.rs_rsid, hresext.rs_feat2)
                ENDIF
                IF NOT EMPTY(rs_feat3) AND rs_feat3 <> rs_feat1 AND rs_feat3 <> rs_feat2
                     INSERT INTO hresfeat (fr_rsid, fr_feature) VALUES (hresext.rs_rsid, hresext.rs_feat3)
                ENDIF
           ENDSCAN
           SELECT reservat
           SCAN FOR NOT EMPTY(rs_feat1+rs_feat2+rs_feat3)
                WAIT WINDOW "RESERVAT -> RESFEAT ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                IF NOT EMPTY(rs_feat1)
                     INSERT INTO resfeat (fr_rsid, fr_feature) VALUES (reservat.rs_rsid, reservat.rs_feat1)
                ENDIF
                IF NOT EMPTY(rs_feat2) AND rs_feat2 <> rs_feat1
                     INSERT INTO resfeat (fr_rsid, fr_feature) VALUES (reservat.rs_rsid, reservat.rs_feat2)
                ENDIF
                IF NOT EMPTY(rs_feat3) AND rs_feat3 <> rs_feat1 AND rs_feat3 <> rs_feat2
                     INSERT INTO resfeat (fr_rsid, fr_feature) VALUES (reservat.rs_rsid, reservat.rs_feat3)
                ENDIF
           ENDSCAN
           IF RECCOUNT("adrfeat") > 0
                REPLACE fa_faid WITH RECNO("adrfeat") ALL IN adrfeat
                NextId("ADRFEAT", RECCOUNT("adrfeat"))
           ENDIF
           IF RECCOUNT("hresfeat") + RECCOUNT("resfeat") > 0
                REPLACE fr_frid WITH RECNO("hresfeat") ALL IN hresfeat
                REPLACE fr_frid WITH RECCOUNT("hresfeat") + RECNO("resfeat") ALL IN resfeat
                NextId("RESFEAT", RECCOUNT("hresfeat") + RECCOUNT("resfeat"))
           ENDIF
           WAIT CLEAR
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.1.3")
      IF OpenFileDirect(,"picklist") AND NOT SEEK("GSGVO     ","picklist","tag1")
           SqlInsert("picklist", "pl_label, pl_numcod, pl_lang3, pl_lang1, pl_lang2, pl_lang4, pl_lang5, pl_lang6, pl_lang7, pl_lang8, pl_lang9, pl_lang10, pl_lang11", 1, "'GSGVO', 1, 'liegt nicht vor'" + REPLICATE(", 'is not available'", 10))
           SqlInsert("picklist", "pl_label, pl_numcod, pl_lang3, pl_lang1, pl_lang2, pl_lang4, pl_lang5, pl_lang6, pl_lang7, pl_lang8, pl_lang9, pl_lang10, pl_lang11", 1, "'GSGVO', 2, 'elektronisch erteilt'" + REPLICATE(", 'electronically issued'", 10))
           SqlInsert("picklist", "pl_label, pl_numcod, pl_lang3, pl_lang1, pl_lang2, pl_lang4, pl_lang5, pl_lang6, pl_lang7, pl_lang8, pl_lang9, pl_lang10, pl_lang11", 1, "'GSGVO', 3, 'schriftlich erteilt'" + REPLICATE(", 'given in writing'", 10))
           SqlInsert("picklist", "pl_label, pl_numcod, pl_lang3, pl_lang1, pl_lang2, pl_lang4, pl_lang5, pl_lang6, pl_lang7, pl_lang8, pl_lang9, pl_lang10, pl_lang11", 1, "'GSGVO', 4, 'm�ndlich erteilt'" + REPLICATE(", 'orally granted'", 10))
           SqlInsert("picklist", "pl_label, pl_numcod, pl_lang3, pl_lang1, pl_lang2, pl_lang4, pl_lang5, pl_lang6, pl_lang7, pl_lang8, pl_lang9, pl_lang10, pl_lang11", 1, "'GSGVO', 5, 'zur�ckgenommen'" + REPLICATE(", 'redeemed'", 10))
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.1.8")
      IF OpenFileDirect(,"grid")
           SqlDelete("grid", "gr_label IN ('GRDLIST')")
      ENDIF
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'FRMEXTRESER'")
      ENDIF
      IF OpenFileDirect(,"param2") AND EMPTY(param2.pa_wrndmin) AND BETWEEN(param2.pa_tkround, 1, 4)
           LOCAL l_nRoundMode, l_nRoundMin
           l_nRoundMode = ICASE(INLIST(param2.pa_tkround, 1, 3), 2, INLIST(param2.pa_tkround, 2, 4), 3, 1)
           l_nRoundMin = ICASE(INLIST(param2.pa_tkround, 1, 2), 30, INLIST(param2.pa_tkround, 3, 4), 15, 0)
           SqlUpdate("param2",,"pa_tkround = " + SqlCnv(l_nRoundMode) + ", pa_wrndmin = " + SqlCnv(l_nRoundMin))
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.1.9")
      IF OpenFileDirect(,"azepick") AND NOT DLocate("azepick", "aq_label = 'PARAMS' AND aq_charcod = 'MD1'")
           LOCAL lnValue
           lnValue = DLookUp("azepick", "aq_label = 'PARAMS' AND aq_charcod = 'MDS'", "aq_nval1")
           SqlInsert("azepick", "aq_label, aq_charcod, aq_nval1, aq_lang1, aq_lang2, aq_lang3, aq_lang4, aq_lang5, aq_lang6, aq_lang7, aq_lang8, aq_lang9, aq_lang10, aq_lang11", 1, "'PARAMS', 'MD1', " + TRANSFORM(lnValue) + REPLICATE(", 'Midnight part 1'", 11))
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.1.11")
      IF OpenFile(,"adrtores") AND NOT DLocate("adrtores", "adrfield = 'adrfeat.fa_feature'")
           SqlDelete("adrtores", "LEFT(LOWER(adrfield),7) = 'ad_feat'")
           SqlInsert("adrtores", "adrfield,resfield", 1, "'adrfeat.fa_feature','resfeat.fr_feature'")
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.1.68")
      IF OpenFileDirect(,"histres") AND OpenFileDirect(,"reservat") AND OpenFileDirect(,"pswindow") AND OpenFileDirect(,"hpwindow")
           LOCAL i, lnAddrId

           SELECT histres
           SET ORDER TO
           SCAN FOR NOT EMPTY(VAL(SUBSTR(MLINE(hr_billins,2),1,12))) OR NOT EMPTY(VAL(SUBSTR(MLINE(hr_billins,3),1,12)))
                WAIT WINDOW "HISTRES -> HPWINDOW ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                FOR i = 2 TO 3
                     lnAddrId = INT(VAL(SUBSTR(MLINE(hr_billins, i), 1, 12)))
                     FNSetWindowData(hr_rsid, i, "pw_addrid", lnAddrId, "hpwindow")
                     SELECT histres
                NEXT
           ENDSCAN
           SELECT reservat
           SET ORDER TO
           SCAN FOR NOT EMPTY(VAL(SUBSTR(MLINE(rs_billins,2),1,12))) OR NOT EMPTY(VAL(SUBSTR(MLINE(rs_billins,3),1,12)))
                WAIT WINDOW "RESERVAT -> PSWINDOW ... " + TRANSFORM(RECNO()) + " of " + TRANSFORM(RECCOUNT()) NOWAIT
                FOR i = 2 TO 3
                     lnAddrId = INT(VAL(SUBSTR(MLINE(rs_billins, i), 1, 12)))
                     FNSetWindowData(rs_rsid, i, "pw_addrid", lnAddrId)
                     SELECT reservat
                NEXT
           ENDSCAN
           WAIT CLEAR
      ENDIF
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.1.71")
      LOCAL lcMessage
      WAIT WINDOW "Registering CitHealthSCX.dll as ActiveX control" NOWAIT
      loGdata("Try do register a .Net COM component 'CitHealthSCX.dll' as ActiveX control using RegAsm for Health insurance cards.",cuPdatefile)
      RegisterDotNetComponent("common\dll\CitHealthSCX.dll", "CitHealthCardX.HealthCardX", @lcMessage)
      IF NOT EMPTY(lcMessage)
           loGdata(lcMessage,cuPdatefile)
      ENDIF
      WAIT CLEAR
 ENDIF
 IF DB_LOWER_VER = CompareVersion("10.1.90")
      IF OpenFileDirect(,"screens")
           SqlDelete("screens", "sc_label = 'MNGRTDCTRL' OR sc_label = 'MNGRTCTRL'")
      ENDIF
 ENDIF
 ************************************************************************************
 * ATTENTION!!!!!!                                                                  *
 * Don't define variables up in if statments, because of possibility                *
 * that error Illegal redefinition of variable "name" (Error 1960) can happen !!!   *
 * Define variables as LOCAL in begining of this procedure !!!!                     *
 ************************************************************************************

 *************************************************
 * ATTENTION!!!!!!
 * Keep in mind, update MUST work with PostgreSql too!!!!
 *
 * WARNNING!
 *
 * IF DB_LOWER_VER = CompareVersion("9.08.79")
 *
 * 9.08.79 should be next version build number!
 *
 *************************************************
ENDPROC
*
PROCEDURE DBUpdateVersion10_00_155
 LOCAL l_cHash, l_nFileSize, l_nRecCount, l_lRemoveEncryptLibrary
 IF OpenFileDirect(,"pictures")
      IF NOT "vfpencryption71" $ LOWER(SET("Library"))
           IF FILE("common\dll\vfpencryption71.fll")
                SET LIBRARY TO common\dll\vfpencryption71.fll ADDITIVE
                l_lRemoveEncryptLibrary = .T.
           ENDIF
      ENDIF
      SELECT pictures
      SET ORDER TO
      l_nRecCount = RECCOUNT()
      SCAN FOR NOT EMPTY(pc_picture)
           WAIT WINDOW "Update new fields pictures.pc_hash and pictures.pc_flength " + PADL(INT((RECNO()/l_nRecCount)*100),3,"0") + " %" NOWAIT
           l_cHash = ""
           l_nFileSize = 0

           CFFileInfo(FULLPATH("pictures\"+ALLTRIM(pc_picture)), @l_cHash, @l_nFileSize)

           IF NOT EMPTY(l_cHash) AND NOT EMPTY(l_nFileSize)
                REPLACE pc_hash WITH l_cHash, pc_flength WITH l_nFileSize
           ENDIF
      ENDSCAN
      IF l_lRemoveEncryptLibrary AND "vfpencryption71" $ LOWER(SET("Library"))
           RELEASE LIBRARY vfpencryption71.fll
      ENDIF
      WAIT CLEAR
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE UpdateSeason
 PRIVATE pnSegmentId, pdLastDate, pcEventName
 LOCAL lcSafety

 OpenFile(.T., "Events")
 OpenFile(.T., "Evint")
 OpenFile(.F., "Season")

 lcSafety = SET("Safety")
 SET SAFETY OFF

 IF USED("Events")
      IF ISEXCLUSIVE("Events")
           ZAP IN Events
      ELSE
           DELETE ALL IN Events
      ENDIF
 ENDIF
 IF USED("Evint")
      IF ISEXCLUSIVE("Evint")
           ZAP IN Evint
      ELSE
           DELETE ALL IN Evint
      ENDIF
 ENDIF

 SET SAFETY &lcSafety

 pnSegmentId = 0
 pdLastDate = {}
 pcEventName = ""

 SELECT SegmentId, EventName, MIN(se_date) AS FromDate, MAX(se_date) AS ToDate ;
      FROM (SELECT GetSegmentId(se_date, UPPER(se_event)) AS SegmentId, se_date, UPPER(se_event) AS EventName FROM Season ORDER BY se_date) c1 ;
      WHERE SegmentId > 0 ;
      GROUP BY SegmentId, EventName ;
      ORDER BY FromDate ;
      INTO CURSOR curOldEventIntervals

 * Update events.dbf
 INSERT INTO events (ev_evid, ev_name) ;
      SELECT RECNO(), EventName ;
           FROM (SELECT EventName FROM curOldEventIntervals GROUP BY EventName) c2

 * Update evint.dbf
 INSERT INTO evint (ei_eiid, ei_evid, ei_from, ei_to) ;
      SELECT RECNO(), ev_evid, FromDate, ToDate ;
           FROM (SELECT ev_evid, FromDate, ToDate FROM curOldEventIntervals LEFT JOIN events ON ev_name = EventName) c3

 * Update id.dbf
 NextId("EVENTS", RECCOUNT("Events"))
 NextId("EVINT", RECCOUNT("Evint"))

 * Update season.dbf
 BLANK FIELDS se_event ALL IN Season
 SELECT curOldEventIntervals
 SCAN
      REPLACE se_event WITH IIF(EMPTY(se_event), "", ALLTRIM(se_event)+"/") + curOldEventIntervals.EventName FOR BETWEEN(se_date, curOldEventIntervals.FromDate, curOldEventIntervals.ToDate) IN Season
 ENDSCAN

 CloseFile("curOldEventIntervals")
 CloseFile("Events")
 CloseFile("Evint")
 CloseFile("Id")
 CloseFile("Season")
ENDPROC
*
PROCEDURE GetSegmentId
 LPARAMETERS tdForDate, tcEventName
 LOCAL lnSegmentId

 IF EMPTY(tcEventName)
      lnSegmentId = 0
 ELSE
      IF EMPTY(pdLastDate) OR EMPTY(pcEventName) OR YEAR(tdForDate) # YEAR(pdLastDate) OR pcEventName # tcEventName
           pnSegmentId = pnSegmentId + 1
      ENDIF

      pdLastDate = tdForDate
      pcEventName = tcEventName
      lnSegmentId = pnSegmentId
 ENDIF

 RETURN CAST(lnSegmentId AS Integer NOT NULL)
ENDPROC
*
PROCEDURE UpdateAllotment
 IF OpenFile(,"Althead") AND USED("Althead")
      IF OpenFile(.T., "reservat") AND USED("reservat") AND ISEXCLUSIVE("reservat")
           IF TYPE("reservat.rs_altid") == "U"
                ALTER TABLE reservat ADD rs_altid n(8)
           ENDIF
           SELECT reservat
           IF TYPE("reservat.rs_allott") <> "U"
                SCAN FOR rs_allott <> " "
                     REPLACE rs_altid WITH DbLookUp("althead","tag2",rs_allott,"al_altid")
                ENDSCAN
                FLUSH
           ENDIF
      ENDIF
      CloseFile("reservat")
      IF OpenFile(.T., "histres") AND USED("histres") AND ISEXCLUSIVE("histres")
           IF TYPE("histres.hr_altid") == "U"
                ALTER TABLE histres ADD hr_altid n(8)
           ENDIF
           IF TYPE("histres.hr_allott") <> "U"
                SELECT histres
                SCAN FOR hr_allott <> " "
                     REPLACE hr_altid WITH DbLookUp("althead","tag2",hr_allott,"al_altid")
                ENDSCAN
                FLUSH
            ENDIF
      ENDIF
      CloseFile("histres")
 ENDIF
 CloseFile("Althead")
 IF OpenFile(.T., "evint") AND USED("evint") AND ISEXCLUSIVE("evint")
      IF TYPE("evint.ei_eiid") == "U"
           ALTER TABLE evint ADD ei_eiid n(8)
      ENDIF
      REPLACE ei_eiid WITH NextId("evint") FOR ei_eiid = 0 IN evint
      FLUSH
 ENDIF
 CloseFile("evint")
ENDPROC
*
PROCEDURE UpdateAlthead
 IF OpenFile(.T., "Althead") AND USED("Althead") AND ISEXCLUSIVE("Althead")
      IF TYPE("Althead.al_buildng") == "U"
           ALTER TABLE Althead ADD COLUMN al_buildng C(3)
      ENDIF
      IF TYPE("Althead.al_rentoid") == "C"
           REPLACE al_buildng WITH STUFF(Althead.al_rentoid, 1, 10, "") FOR EMPTY(al_buildng) IN Althead
           FLUSH
      ENDIF
 ENDIF
 CloseFile("Althead")
ENDPROC
*
PROCEDURE UpdateRoomTypeFromRoom
 OpenFile(.F., "Room")
 IF TYPE("Room.rm_buildng") == "C" AND OpenFile(,"Roomtype") AND USED("Roomtype") AND OpenFile(,"Reservat") AND USED("Reservat") AND OpenFile(,"ResRooms") AND USED("ResRooms") AND ;
           OpenFile(,"Sharing") AND USED("Sharing") AND OpenFile(,"Althead") AND USED("Althead") AND OpenFile(,"Altsplit") AND USED("Altsplit")
      SELECT * FROM (;
           SELECT r1.* FROM (SELECT DISTINCT rm_roomtyp, rm_buildng FROM room) r1 ;
                INNER JOIN (;
                     SELECT rm_roomtyp FROM (SELECT DISTINCT rm_roomtyp, rm_buildng FROM room) r1 ;
                          GROUP BY rm_roomtyp HAVING COUNT(*)>1) r2 ON r1.rm_roomtyp = r2.rm_roomtyp ;
                LEFT JOIN roomtype ON rt_roomtyp = r1.rm_roomtyp AND rt_buildng = r1.rm_buildng ;
                WHERE ISNULL(rt_roomtyp)) r3 ;
           INNER JOIN roomtype ON rt_roomtyp = r3.rm_roomtyp ;
           INTO CURSOR curRoomtypes READWRITE
      IF _tally > 0
           INDEX ON rm_roomtyp+rm_buildng TAG Tag1
           UPDATE curRoomtypes SET rt_buildng = rm_buildng, rt_roomtyp = NextId("ROOMTYPE")
           UPDATE Room SET rm_roomtyp = curRoomtypes.rt_roomtyp WHERE SEEK(Room.rm_roomtyp+Room.rm_buildng,"curRoomtypes","Tag1")
           UPDATE Reservat SET rs_roomtyp = Room.rm_roomtyp WHERE SEEK(Reservat.rs_roomnum,"Room","Tag1") AND SEEK(Reservat.rs_roomtyp+Room.rm_buildng,"curRoomtypes","Tag1")
           UPDATE ResRooms SET ri_roomtyp = Room.rm_roomtyp WHERE SEEK(ResRooms.ri_roomnum,"Room","Tag1") AND SEEK(ResRooms.ri_roomtyp+Room.rm_buildng,"curRoomtypes","Tag1")
           UPDATE Sharing SET sd_roomtyp = Room.rm_roomtyp WHERE SEEK(Sharing.sd_roomnum,"Room","Tag1") AND SEEK(Sharing.sd_roomtyp+Room.rm_buildng,"curRoomtypes","Tag1")
           UPDATE Altsplit SET as_roomtyp = curRoomtypes.rt_roomtyp WHERE SEEK(Altsplit.as_altid,"Althead","Tag1") AND SEEK(Altsplit.as_roomtyp+Althead.al_buildng,"curRoomtypes","Tag1")
           UPDATE Reservat SET rs_roomtyp = curRoomtypes.rt_roomtyp WHERE SEEK(Reservat.rs_altid,"Althead","Tag1") AND SEEK(Reservat.rs_roomtyp+Althead.al_buildng,"curRoomtypes","Tag1")
           REPLACE ri_roomtyp WITH curRoomtypes.rt_roomtyp FOR SEEK(ResRooms.ri_reserid,"Reservat","Tag1") AND SEEK(Reservat.rs_altid,"Althead","Tag1") AND SEEK(ResRooms.ri_roomtyp+Althead.al_buildng,"curRoomtypes","Tag1") IN ResRooms
           *UPDATE ResRooms SET ri_roomtyp = curRoomtypes.rt_roomtyp WHERE SEEK(ResRooms.ri_reserid,"Reservat","Tag1") AND SEEK(Reservat.rs_altid,"Althead","Tag1") AND SEEK(ResRooms.ri_roomtyp+Althead.al_buildng,"curRoomtypes","Tag1")
           SELECT Roomtype
           APPEND FROM DBF("curRoomtypes")
           *** Set Roomtype.rt_rdid in AfterUpdateDataToVersion().
           PUBLIC ARRAY g_aRoomTypeConv(1)
           SELECT rm_roomtyp, rt_roomtyp FROM curRoomtypes INTO ARRAY g_aRoomTypeConv
           ***
      ENDIF
 ENDIF
 CloseFile("curRoomtypes")
 CloseFile("Altsplit")
 CloseFile("Althead")
 CloseFile("Sharing")
 CloseFile("ResRooms")
 CloseFile("Reservat")
 CloseFile("Roomtype")
 CloseFile("Room")
ENDPROC
*
PROCEDURE UpdateAltHeadEventsBefore
 * When updating to new version, copy altev table to backup folder, and use it
 * after database update, to copy data into new field.
 
 LOCAL l_cVersion, l_cTable
 l_cTable = "altev.dbf"
 IF NOT FILE(p_cBackupFolder+l_cTable)
      IF FILE(gcDatadir+l_cTable)
           = loGdata("Coping table " + l_cTable,cuPdatefile)
           COPY FILE (gcDatadir+l_cTable) TO (ADDBS(p_cBackupFolder)+l_cTable)
           IF FILE(gcDatadir+FORCEEXT(l_cTable,"cdx"))
                COPY FILE (gcDatadir+FORCEEXT(l_cTable,"cdx")) TO (ADDBS(p_cBackupFolder)+FORCEEXT(l_cTable,"cdx"))
           ENDIF
      ENDIF
 ELSE
      = loGdata("Table " + l_cTable + " already copied. Skiping.",cuPdatefile)
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE DBFixRsIdBefore

* Before we make rs_rsid as CANDIDATE, we must fix duplicate rs_rsid-s.
* First scan through reservat and histres tables, set on order rs_rsid. When records with duplicate
* id-s found, copy it to cursor, and apply changes after scan through table, to prevent problems 
* when order is changed when we change rs_rsid.

LOCAL l_nMaxIdInTable, l_nLastRsId, l_nMaxIdInTable, l_oData, l_nNewRsId, l_lTest, i, l_oRes, l_nRecNo, ;
          l_nOldId, l_lUsedResSplit, l_nDeleted, l_nCountHEXT

= loGdata("Fix duplicate rs_rsid, before rs_rsid is CANDIDATE index.",cuPdatefile)

closefile("reservat")
closefile("histres")

* Create index, when deleted
openfile(.F.,"reservat")
openfile(.F.,"histres")

closefile("reservat")
closefile("histres")

* Must PACK histres and reservat, before using CANDIDATE, becouse records marked as DELETED() are checked too.

IF OpenFile(.T., "reservat") AND USED("reservat") AND ISEXCLUSIVE("reservat")
     SELECT reservat
     PACK
     = loGdata("reservat.dbf PACK",cuPdatefile)
ENDIF
IF OpenFile(.T., "histres") AND USED("histres") AND ISEXCLUSIVE("histres")
     SELECT histres
     PACK
     = loGdata("histres.dbf PACK",cuPdatefile)
ENDIF
IF TYPE("reservat.rs_rsid")="U" OR DB_LOWER_VER = CompareVersion("9.07.96")
     * rs_rsid was not yet used in this version, so no need to check uniquess of this id.
     closefile("reservat")
     closefile("histres")
     = loGdata("Fix duplicate rs_rsid: Finished.",cuPdatefile)
     RETURN .T.
ENDIF

WAIT WINDOW NOWAIT "Fix duplicate rs_rsid, before rs_rsid is CANDIDATE index."

openfile(.F.,"hresext")
openfile(.F.,"id")

TRY
     openfiledirect(.F.,"ressplit")
CATCH
ENDTRY
l_lUsedResSplit = USED("ressplit")
IF l_lUsedResSplit
     SELECT ressplit
     SET ORDER TO
ENDIF

* Check Last id for RESUNQID - rs_rsid in id table, and fix it when needed.

SELECT MAX(hr_rsid) AS c_max FROM histres INTO CURSOR curhmax
SELECT MAX(rs_rsid) AS c_max FROM reservat INTO CURSOR currmax
l_nMaxIdInTable = MAX(currmax.c_max, curhmax.c_max, 1)

SELECT id
LOCATE FOR id_code="RESUNQID"
IF FOUND()
     l_nLastRsId = id.id_last
ELSE
     l_nLastRsId = 1
     SCATTER NAME l_oData BLANK
     l_oData.id_code = "RESUNQID"
     l_oData.id_last = l_nLastRsId
     INSERT INTO id FROM NAME l_oData
ENDIF
l_nLastRsId = MAX(l_nMaxIdInTable, l_nLastRsId)

* Fix hr_depdate in another record with same hr_rsid.
FOR i = 1 TO 7
     l_nReserId = 0.1 * i
     SELECT histres
     LOCATE FOR hr_reserid = l_nReserId
     IF FOUND()
          l_nRecNo = RECNO()
          SCATTER NAME l_oData
          SCAN FOR hr_rsid = l_oData.hr_rsid AND hr_reserid <> l_oData.hr_reserid
               IF hr_depdate <> hr_codate AND NOT EMPTY(hr_codate)
                    REPLACE hr_depdate WITH hr_codate
                    = loGdata("Changed hr_depdate to " + TRANSFORM(hr_codate) + " for hr_reserid " + TRANSFORM(hr_reserid),cuPdatefile)
               ENDIF
          ENDSCAN
          GO l_nRecNo
          * Give new rs_rsid for 0.X records, to prevent duplicates with reservat table
          l_nLastRsId = l_nLastRsId + 1
          REPLACE hr_rsid WITH l_nLastRsId
     ENDIF
ENDFOR

* Check for duplicate rs_rsid id-s in reservat. When found, create new id.

SELECT rs_reserid, rs_rsid FROM reservat WHERE .F. INTO CURSOR restmpc1 READWRITE
SELECT reservat
SET ORDER TO TAG33   && RS_RSID
SCATTER NAME l_oData BLANK
SCAN ALL
     WAIT WINDOW NOWAIT "Checking rs_reserid:" + TRANSFORM(reservat.rs_reserid)
     IF l_oData.rs_rsid = reservat.rs_rsid OR ;
               (SEEK(reservat.rs_rsid, "histres","tag15") AND reservat.rs_reserid <> histres.hr_reserid)
          * Duplicate ID found. Store reserid in cursor, and proccess it later.
          SELECT restmpc1
          SCATTER NAME l_oRes
          l_nLastRsId = l_nLastRsId + 1
          l_oRes.rs_rsid = l_nLastRsId
          l_oRes.rs_reserid = reservat.rs_reserid
          INSERT INTO restmpc1 FROM NAME l_oRes
     ELSE
          SCATTER NAME l_oData
     ENDIF
ENDSCAN

SELECT restmpc1
SCAN FOR SEEK(restmpc1.rs_reserid,"reservat","tag1")
     l_nNewRsId = restmpc1.rs_rsid
     l_nOldId = reservat.rs_rsid

     WAIT WINDOW NOWAIT "Update rs_reserid:" + TRANSFORM(reservat.rs_reserid)
     = loGdata("Changed rs_rsid to " + TRANSFORM(l_nNewRsId) + " for rs_reserid " + TRANSFORM(reservat.rs_reserid),cuPdatefile)
     
     REPLACE rs_rsid WITH l_nNewRsId IN reservat
     IF SEEK(reservat.rs_reserid,"histres","tag1")
          REPLACE hr_rsid WITH l_nNewRsId IN histres
     ENDIF
     IF SEEK(reservat.rs_reserid,"hresext","tag1")
          REPLACE rs_rsid WITH l_nNewRsId IN hresext
     ENDIF
     IF l_lUsedResSplit
          REPLACE rl_rsid WITH l_nNewRsId FOR rl_rsid = l_nOldId IN ressplit
     ENDIF
ENDSCAN

* Check for duplicate ids in histres.

SELECT hr_reserid, hr_rsid FROM histres WHERE .F. INTO CURSOR hrestmpc1 READWRITE
SELECT histres
SET ORDER TO TAG15   && HR_RSID
SCATTER NAME l_oData BLANK
SCAN ALL
     WAIT WINDOW NOWAIT "Checking hr_reserid:" + TRANSFORM(histres.hr_reserid)
     IF l_oData.hr_rsid = histres.hr_rsid
          * Duplicate ID found
          SELECT hrestmpc1
          SCATTER NAME l_oRes
          l_nLastRsId = l_nLastRsId + 1
          l_oRes.hr_rsid = l_nLastRsId
          l_oRes.hr_reserid = histres.hr_reserid
          INSERT INTO hrestmpc1 FROM NAME l_oRes
     ELSE
          SCATTER NAME l_oData
     ENDIF
ENDSCAN

SELECT hrestmpc1
SCAN FOR SEEK(hrestmpc1.hr_reserid,"histres","tag1")
     l_nNewRsId = hrestmpc1.hr_rsid

     WAIT WINDOW NOWAIT "Updating hr_reserid:" + TRANSFORM(histres.hr_reserid)
     = loGdata("Changed hr_rsid to " + TRANSFORM(l_nNewRsId) + " for hr_reserid " + TRANSFORM(histres.hr_reserid),cuPdatefile)

     REPLACE hr_rsid WITH l_nNewRsId IN histres
     IF SEEK(histres.hr_reserid,"hresext","tag1")
          REPLACE rs_rsid WITH l_nNewRsId IN hresext
     ENDIF
     IF SEEK(histres.hr_reserid,"reservat","tag1")
          l_nOldId = reservat.rs_rsid
          REPLACE rs_rsid WITH l_nNewRsId IN reservat
          IF l_lUsedResSplit
               REPLACE rl_rsid WITH l_nNewRsId FOR rl_rsid = l_nOldId IN ressplit
          ENDIF
     ENDIF
ENDSCAN

* Save last rs_rsid into id table

IF id.id_last <> l_nLastRsId
     REPLACE id_last WITH l_nLastRsId IN id
     = loGdata("Changed id_last to " + TRANSFORM(l_nLastRsId) + " for id_code='RESUNQID'",cuPdatefile)
ENDIF

FLUSH FORCE

l_nDeleted = 0
l_nCountHEXT = 0
* Fix wrong rs_rsid in histres
SELECT hresext
SET ORDER TO
SCAN ALL
     IF SEEK(hresext.rs_reserid, "histres","tag1")
          IF histres.hr_rsid <> hresext.rs_rsid
               REPLACE rs_rsid WITH histres.hr_rsid IN hresext
               l_nCountHEXT = l_nCountHEXT+ 1
          ENDIF
     ELSE
          DELETE IN hresext
          l_nDeleted = l_nDeleted + 1
     ENDIF
ENDSCAN

* delete duplicate records in hresext
SELECT rs_rsid,rs_reserid FROM hresext ORDER BY rs_rsid INTO CURSOR cdbupdhrs129
l_oData = .NULL.
SCAN ALL
     IF NOT ISNULL(l_oData) AND l_oData.rs_rsid = cdbupdhrs129.rs_rsid
          IF SEEK(cdbupdhrs129.rs_reserid, "hresext","tag1")
               DELETE IN hresext
               l_nDeleted = l_nDeleted + 1
          ENDIF
     ENDIF
     SCATTER NAME l_oData
ENDSCAN

FLUSH FORCE

= loGdata("hresext: changed rs_rsid for " + TRANSFORM(l_nCountHEXT) + " records.",cuPdatefile)
= loGdata("Duplicate records deleted from hresext: " + TRANSFORM(l_nDeleted),cuPdatefile)

closefile("curhmax")
closefile("currmax")
closefile("restmpc1")
closefile("hrestmpc1")
closefile("reservat")
closefile("histres")
closefile("cdbupdhrs129")
closefile("ressplit")

= loGdata("Fix duplicate rs_rsid: Finished.",cuPdatefile)

WAIT CLEAR
RETURN .T.
ENDPROC
*
PROCEDURE UpdateResAddr
 LOCAL l_nSelect, l_cCur, l_oResAddr
 l_nSelect = SELECT()
 = OpenFile(.T., "resaddr")
 = OpenFile(.F., "reservat")
 = OpenFile(.F., "param2")
 = OpenFile(.F., "address")
 IF param2.pa_noaddr
      ZAP IN resaddr
      REPLACE rs_rgid WITH 0 FOR rs_rgid <> 0 IN reservat
      FLUSH
      TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15

           SELECT rs_reserid, rs_lname, rs_fname, rs_title, rs_arrdate, rs_depdate, rs_country, ;
                  rs_rgid, rs_compid ;
           FROM reservat ;
           WHERE rs_noaddr = <<SqlCnv(.T.,.T.)>> AND EMPTY(rs_rgid) ;
           ORDER BY 1

      ENDTEXT
      l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
      SELECT &l_cCur
      SCAN ALL
           SELECT resaddr
           SCATTER NAME l_oResAddr MEMO BLANK
           SELECT &l_cCur
           l_oResAddr.rg_reserid = &l_cCur..rs_reserid
           l_oResAddr.rg_lname = PROPER(&l_cCur..rs_lname)
           l_oResAddr.rg_fromday = 1
           l_oResAddr.rg_today = &l_cCur..rs_depdate - &l_cCur..rs_arrdate + 1
           l_oResAddr.rg_country = DLookUp("address", "ad_addrid = " + SqlCnv(&l_cCur..rs_compid), "ad_country")
           DO PAResAddrNew IN procaddress WITH l_oResAddr
           sqlupdate("reservat", ;
                     "rs_reserid = " + sqlcnv(l_oResAddr.rg_reserid,.T.), ;
                     "rs_rgid = " + sqlcnv(l_oResAddr.rg_rgid,.T.) ;
                     )
      ENDSCAN
      dclose(l_cCur)
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE UpdateResAddrMustHaveRecord
 LOCAL l_nSelect, l_cCur, l_oResAddr
 l_nSelect = SELECT()
 = OpenFile(.T., "resaddr")
 = OpenFile(.F., "reservat")
 = OpenFile(.F., "param2")
 = OpenFile(.F., "address")
 IF param2.pa_noaddr

      TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15

           SELECT rs_reserid, rs_lname, rs_fname, rs_title, rs_arrdate, rs_depdate, rs_country, ;
                  rs_rgid, rs_compid ;
           FROM reservat ;
           WHERE rs_noaddr = <<SqlCnv(.T.,.T.)>> AND EMPTY(rs_rgid) ;
           ORDER BY 1

      ENDTEXT
      l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
      SELECT &l_cCur
      SCAN ALL
           SELECT resaddr
           SCATTER NAME l_oResAddr MEMO BLANK
           SELECT &l_cCur
           l_oResAddr.rg_reserid = &l_cCur..rs_reserid
           l_oResAddr.rg_lname = PROPER(&l_cCur..rs_lname)
           l_oResAddr.rg_fromday = 1
           l_oResAddr.rg_today = &l_cCur..rs_depdate - &l_cCur..rs_arrdate + 1
           l_oResAddr.rg_country = DLookUp("address", "ad_addrid = " + SqlCnv(&l_cCur..rs_compid), "ad_country")
           DO PAResAddrNew IN procaddress WITH l_oResAddr
           sqlupdate("reservat", ;
                     "rs_reserid = " + sqlcnv(l_oResAddr.rg_reserid,.T.), ;
                     "rs_rgid = " + sqlcnv(l_oResAddr.rg_rgid,.T.) ;
                     )
      ENDSCAN
      dclose(l_cCur)
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE UpdateBuilding
 OpenFile(.F., "PickList")
 OpenFile(.F., "Building")
 OpenFile(.F., "Room")
 OpenFile(.F., "Roomtype")
 SELECT PickList
 SCAN FOR INLIST(pl_label, "BUILDING", "RENTOBJ")
      IF NOT SEEK(PickList.pl_charcod, "Building", "tag2")
           INSERT INTO Building (bu_buid, bu_buildng, bu_webtop, bu_lang1, bu_lang2, bu_lang3, bu_lang4, ;
                bu_lang5, bu_lang6, bu_lang7, bu_lang8, bu_lang9, bu_lang10, bu_lang11) ;
                VALUES (NextId("BUILDING"), PickList.pl_charcod, PickList.pl_user1, PickList.pl_lang1, ;
                PickList.pl_lang2, PickList.pl_lang3, PickList.pl_lang4, PickList.pl_lang5, PickList.pl_lang6, ;
                PickList.pl_lang7, PickList.pl_lang8, PickList.pl_lang9, PickList.pl_lang10, PickList.pl_lang11)
      ENDIF
      DELETE
 ENDSCAN
 IF TYPE("Room.rm_buildng") == "C"
      SELECT Roomtype
      SCAN FOR NOT EMPTY(rt_buildng)
           REPLACE rm_buildng WITH Roomtype.rt_buildng FOR EMPTY(rm_buildng) AND rm_roomtyp = Roomtype.rt_roomtyp IN Room
      ENDSCAN
 ENDIF
 CloseFile("Roomtype")
 CloseFile("Room")
 CloseFile("Building")
 CloseFile("PickList")
ENDPROC
*
PROCEDURE UpdateRoomtypDef
 OpenFile(.F., "Rtypedef")
 OpenFile(.F., "Roomtype")
 INSERT INTO Rtypedef (rd_rdid, rd_roomtyp, rd_group, rd_cocolid, rd_ftbold, rd_ftcolid, rd_lang1, rd_lang2, ;
      rd_lang3, rd_lang4, rd_lang5, rd_lang6, rd_lang7, rd_lang8, rd_lang9, rd_lang10, rd_lang11) ;
      SELECT NVL(rd_rdid, 0), rt_roomtyp, rt_group, rt_cocolid, rt_ftbold, rt_ftcolid, ;
      rt_lang1, rt_lang2, rt_lang3, rt_lang4, rt_lang5, rt_lang6, rt_lang7, rt_lang8, rt_lang9, rt_lang10, rt_lang11 FROM Roomtype ;
      LEFT JOIN Rtypedef ON rd_rdid = rt_rdid ;
      WHERE ISNULL(rd_rdid) AND LEFT(rt_roomtyp,1) # "@"
 UPDATE Rtypedef SET rd_rdid = NextId("RTYPEDEF") WHERE EMPTY(rd_rdid)
 UPDATE Roomtype SET rt_rdid = Rtypedef.rd_rdid WHERE EMPTY(rt_rdid) AND SEEK(Roomtype.rt_roomtyp,"Rtypedef","Tag2")
 IF VARTYPE(g_aRoomTypeConv) # "U"
      LOCAL i
      FOR i = 1 TO ALEN(g_aRoomTypeConv,1)
           UPDATE Roomtype SET rt_rdid = Rtypedef.rd_rdid WHERE EMPTY(rt_rdid) AND rt_roomtyp = g_aRoomTypeConv(i,2) AND SEEK(g_aRoomTypeConv(i,1),"Rtypedef","Tag2")
      NEXT
      RELEASE g_aRoomTypeConv
 ENDIF
 CloseFile("Roomtype")
 CloseFile("Rtypedef")
ENDPROC
*
PROCEDURE UpdateResBrwRtColWidth
 OpenFile(.F., "Grid")
 UPDATE Grid SET gr_width = 60 WHERE UPPER(gr_label) = "RSBGRID" AND UPPER(gr_column) = "COLUMN6"
 CloseFile("Grid")
ENDPROC
*
PROCEDURE UpdateUnqResrId
 IF OpenFile(.T., "Reservat") AND USED("Reservat") AND ISEXCLUSIVE("Reservat") AND OpenFile(.T., "histres") AND USED("histres") AND ISEXCLUSIVE("histres") AND ;
           OpenFile(.T., "Hresext") AND USED("Hresext") AND ISEXCLUSIVE("Hresext")
      IF TYPE("reservat.rs_rsid") == "U"
           ALTER TABLE reservat ADD COLUMN rs_rsid i
      ENDIF
      IF TYPE("histres.hr_rsid") == "U"
           ALTER TABLE histres ADD COLUMN hr_rsid i
      ENDIF
      IF TYPE("hresext.rs_rsid") == "U"
           ALTER TABLE hresext ADD COLUMN rs_rsid i
      ENDIF
      UPDATE Histres SET hr_rsid = NextId("RESUNQID") WHERE EMPTY(hr_rsid)
      UPDATE Hresext SET rs_rsid = Histres.hr_rsid WHERE EMPTY(rs_rsid) AND SEEK(Hresext.rs_reserid,"Histres","Tag1")
      UPDATE Hresext SET rs_rsid = NextId("RESUNQID") WHERE EMPTY(rs_rsid)
      UPDATE Reservat SET rs_rsid = Histres.hr_rsid WHERE EMPTY(rs_rsid) AND SEEK(Reservat.rs_reserid,"Histres","Tag1")
      UPDATE Reservat SET rs_rsid = NextId("RESUNQID") WHERE EMPTY(rs_rsid)
 ENDIF
 CloseFile("Hresext")
 CloseFile("Histres")
 CloseFile("Reservat")
ENDPROC
*
PROCEDURE UpdateHrrsId
 OpenFile(.F., "Reservat")
 OpenFile(.F., "Histres")
 OpenFile(.F., "Hresext")
 UPDATE Hresext SET rs_rsid = Reservat.rs_rsid WHERE EMPTY(rs_rsid) AND SEEK(Hresext.rs_reserid,"Reservat","Tag1")
 UPDATE Hresext SET rs_rsid = NextId("RESUNQID") WHERE EMPTY(rs_rsid)
 UPDATE Histres SET hr_rsid = Hresext.rs_rsid WHERE EMPTY(hr_rsid) AND SEEK(Histres.hr_reserid,"Hresext","Tag1")
 UPDATE Histres SET hr_rsid = NextId("RESUNQID") WHERE EMPTY(hr_rsid)
 CloseFile("Hresext")
 CloseFile("Histres")
 CloseFile("Reservat")
ENDPROC
*
PROCEDURE UpdateAltHeadEventsAfter
 * Open backap of altev table, and link althead table to evint table over new field al_eiid.
 
 LOCAL l_cVersion, l_cAltEvCur, l_cAltHeadCur
 STORE "" TO l_cVersion, l_cAltEvCur, l_cAltHeadCur
 
 IF NOT FILE(ADDBS(p_cBackupFolder) + "altev.dbf")
      = loGdata("Table " + "altev.dbf" + " NOT found. Aborting.",cuPdatefile)
      *Alert(Str2Msg(getapplangtext("DBUPDATE","MISSING_TABLE"), "%s", ADDBS(p_cBackupFolder) + "altev.dbf"))
      RETURN .F.
 ENDIF
 
 IF openfiledirect(.T.,"altev","",p_cBackupFolder)
      IF OpenFile(.F., "althead")
           = loGdata("Updating althead.al_eiid from altev.",cuPdatefile)
           TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
           SELECT * FROM altev ORDER BY aj_altid
           ENDTEXT
           l_cAltEvCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
           
           TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
           SELECT al_altid FROM althead ORDER BY al_altid
           ENDTEXT
           l_cAltHeadCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)

           SELECT &l_cAltHeadCur
           SCAN ALL
                IF dlocate(l_cAltEvCur,"aj_altid = " + sqlcnv(&l_cAltHeadCur..al_altid))
                      sqlupdate("althead", ;
                          "al_altid = " + sqlcnv(&l_cAltEvCur..aj_altid,.T.), ;
                          "al_eiid = " + sqlcnv(&l_cAltEvCur..aj_eiid,.T.) ;
                          )
                ENDIF
           ENDSCAN
           = loGdata("Finished updating althead.al_eiid from altev.",cuPdatefile)
           filedelete(gcDatadir+"altev.dbf")
           filedelete(gcDatadir+"altev.cdx")
           = loGdata("Deleted altev.dbf.",cuPdatefile)
      ENDIF
 ENDIF
 dclose("altev")
 dclose("althead")
 dclose(l_cAltEvCur)
 dclose(l_cAltHeadCur)
 RETURN .T.
ENDPROC
*
PROCEDURE UpdateActionsAfter
 LOCAL l_cSql, l_cAltHeadCur, l_oAltHead

 * Add action type in picklist for allotment
 IF openfile(.F.,"param") AND "KT" $ param.pa_lizopt
      IF openfile(.F.,"picklist")
           IF NOT dlocate("picklist", "pl_label = " + sqlcnv("ACTION") + " AND pl_charcod = " + sqlcnv("KON"))
                = loGdata("Inserting action type KON in picklist table.",cuPdatefile)
                SELECT picklist
                SCATTER MEMO NAME l_oPickList BLANK
                l_oPickList.pl_label = "ACTION"
                l_oPickList.pl_charcod = "KON"
                STORE "Allotment expired" TO ;
                     l_oPickList.pl_lang1, l_oPickList.pl_lang2, l_oPickList.pl_lang4, l_oPickList.pl_lang5, ;
                     l_oPickList.pl_lang6, l_oPickList.pl_lang7, l_oPickList.pl_lang8, l_oPickList.pl_lang9
                l_oPickList.pl_lang3 = "Kontingent ist abgelaufen"
                INSERT INTO picklist FROM NAME l_oPickList
           ENDIF
      ENDIF
      IF openfile(.F.,"action")
           = loGdata("Generating action.at_atid",cuPdatefile)
           SELECT action
           SET ORDER TO
           SCAN FOR EMPTY(at_atid)
                REPLACE at_atid WITH nextid("ACTION")
           ENDSCAN
           FLUSH
          * now for every allotment with al_cutdate >= sysdate() make action
           TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
           SELECT * FROM althead ;
                WHERE NOT EMPTY(al_cutdate) AND al_cutdate >= <<sqlcnv(sysdate(),.T.)>> ;
                ORDER BY al_altid
           ENDTEXT
           l_cAltHeadCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
           IF RECCOUNT()>0
                = loGdata("Generating actions for allotments",cuPdatefile)
                SELECT &l_cAltHeadCur
                SCAN ALL
                     SCATTER MEMO NAME l_oAltHead
                     DO ActInsertForAllotment IN procaction WITH l_oAltHead
                ENDSCAN
           ENDIF
           dclose(l_cAltHeadCur)
      ENDIF
 ENDIF

 dclose("param")
 dclose("picklist")
 dclose("action")
RETURN .T.
ENDPROC
*
PROCEDURE ActivateBuildings
 OpenFile(.F., "Building")
 IF NOT DLocate("Building", "bu_active")
      UPDATE Building SET bu_active = .T.
 ENDIF
 CloseFile("Building")
ENDPROC
*
PROCEDURE UpdateEventRelations
 OpenFile(.F., "events")
 OpenFile(.F., "evint")
 DELETE FOR NOT SEEK(evint.ei_evid, "events", "tag1") IN evint          && delete broken relations
 CloseFile("events")
 CloseFile("evint")
ENDPROC
*
PROCEDURE UpdateLedgerToPostRelation
 LOCAL lnPostId, llSeekInHistpost, lnAddrId, lnCount, lnPercent
 OpenFile(.F., "ledgpost")
 OpenFile(.F., "ledgpaym")
 OpenFile(.F., "arpost")
 OpenFile(.F., "reservat")
 OpenFile(.F., "histres")
 OpenFile(.F., "post")
 OpenFile(.F., "histpost")
 SET ORDER TO "" IN ledgpost
 SET ORDER TO "" IN ledgpaym
 SET ORDER TO "" IN arpost
 SET ORDER TO tag1 IN post
 SET ORDER TO tag1 IN histpost

 lnPercent = 0
 SELECT ledgpost
 lnCount = RECCOUNT()
 SCAN FOR EMPTY(ld_postid)
      IF lnPercent < 100*RECNO()/lnCount
           lnPercent = ROUND(100*RECNO()/lnCount,0)
           WAIT "Updating ledgepost relations: " + STR(lnPercent,3) + " %" WINDOW NOWAIT
      ENDIF
      lnPostId = 0
      llSeekInHistpost = .T.
      IF SEEK(ledgpost.ld_reserid, "post", "tag1")
           SELECT post
           SCAN FOR ps_date = ledgpost.ld_billdat AND ps_paynum = ledgpost.ld_paynum AND ps_amount = -ledgpost.ld_billamt AND ;
                     (ledgpost.ld_reserid <> 0.100 AND ps_window > 0 OR ps_addrid = ledgpost.ld_addrid) WHILE ps_reserid = ledgpost.ld_reserid AND EMPTY(lnPostId)
                lnAddrId = post.ps_addrid
                DO CASE
                     CASE post.ps_reserid = 0.100 OR post.ps_window = 0
                          lnPostId = post.ps_postid
                     CASE SEEK(poSt.ps_reserid, "Reservat", "tag1")
                          DO BillAddrId IN ProcBill WITH post.ps_window, reservat.rs_rsid, reservat.rs_addrid, lnAddrId
                          IF lnAddrId = ledgpost.ld_addrid
                               lnPostId = post.ps_postid
                          ENDIF
                     CASE SEEK(poSt.ps_reserid, "Histres", "tag1")
                          DO BillAddrId IN ProcBill WITH post.ps_window, histres.hr_rsid, histres.hr_addrid, lnAddrId
                          IF lnAddrId = ledgpost.ld_addrid
                               lnPostId = post.ps_postid
                          ENDIF
                     OTHERWISE
                ENDCASE
           ENDSCAN
           llSeekInHistpost = EMPTY(lnPostId) AND (ledgpost.ld_reserid < 1)
      ENDIF
      IF llSeekInHistpost AND SEEK(ledgpost.ld_reserid, "histpost", "tag1")
           SELECT histpost
           SCAN FOR hp_date = ledgpost.ld_billdat AND hp_paynum = ledgpost.ld_paynum AND hp_amount = -ledgpost.ld_billamt AND ;
                     (ledgpost.ld_reserid <> 0.100 AND hp_window > 0 OR hp_addrid = ledgpost.ld_addrid) WHILE hp_reserid = ledgpost.ld_reserid AND EMPTY(lnPostId)
                lnAddrId = histpost.hp_addrid
                DO CASE
                     CASE histpost.hp_reserid = 0.100 OR histpost.hp_window = 0
                          lnPostId = histpost.hp_postid
                     CASE SEEK(histpost.hp_reserid, "Reservat", "tag1")
                          DO BillAddrId IN ProcBill WITH histpost.hp_window, reservat.rs_rsid, reservat.rs_addrid, lnAddrId
                          IF lnAddrId = ledgpost.ld_addrid
                               lnPostId = histpost.hp_postid
                          ENDIF
                     CASE SEEK(histpost.hp_reserid, "Histres", "tag1")
                          DO BillAddrId IN ProcBill WITH histpost.hp_window, histres.hr_rsid, histres.hr_addrid, lnAddrId
                          IF lnAddrId = ledgpost.ld_addrid
                               lnPostId = histpost.hp_postid
                          ENDIF
                     OTHERWISE
                ENDCASE
           ENDSCAN
      ENDIF
      SELECT ledgpost
      IF NOT EMPTY(lnPostId)
           REPLACE ld_postid WITH lnPostId
      ENDIF
 ENDSCAN

 lnPercent = 0
 SELECT ledgpaym
 lnCount = RECCOUNT()
 SCAN FOR EMPTY(lp_postid)
      IF lnPercent < 100*RECNO()/lnCount
           lnPercent = ROUND(100*RECNO()/lnCount,0)
           WAIT "Updating ledgpaym relations: " + STR(lnPercent,3) + " %" WINDOW NOWAIT
      ENDIF
      lnPostId = 0
      llSeekInHistpost = .T.
      IF SEEK(ledgpaym.lp_reserid, "post", "tag1")
           SELECT post
           SCAN FOR ps_date = ledgpaym.lp_paymdat AND ps_window = 0 AND ps_billnum = ledgpaym.lp_billnum AND ps_paynum = ledgpaym.lp_paynum AND ;
                     ps_amount = -ledgpaym.lp_paymamt AND ps_descrip = ledgpaym.lp_descrip AND LEFT(ps_supplem,7) = "LEDGER " ;
                     WHILE ps_reserid = ledgpaym.lp_reserid AND EMPTY(lnPostId)
                lnPostId = post.ps_postid
           ENDSCAN
           llSeekInHistpost = EMPTY(lnPostId) AND (ledgpaym.lp_reserid < 1)
      ENDIF
      IF llSeekInHistpost AND SEEK(ledgpaym.lp_reserid, "histpost", "tag1")
           SELECT histpost
           SCAN FOR hp_date = ledgpaym.lp_paymdat AND hp_window = 0 AND hp_billnum = ledgpaym.lp_billnum AND hp_paynum = ledgpaym.lp_paynum AND ;
                     hp_amount = -ledgpaym.lp_paymamt AND hp_descrip = ledgpaym.lp_descrip AND LEFT(hp_supplem,7) = "LEDGER " ;
                     WHILE hp_reserid = ledgpaym.lp_reserid AND EMPTY(lnPostId)
                lnPostId = histpost.hp_postid
           ENDSCAN
      ENDIF
      SELECT ledgpaym
      IF NOT EMPTY(lnPostId)
           REPLACE lp_postid WITH lnPostId
      ENDIF
 ENDSCAN

 lnPercent = 0
 SELECT arpost
 lnCount = RECCOUNT()
 SCAN FOR EMPTY(ap_postid)
      IF lnPercent < 100*RECNO()/lnCount
           lnPercent = ROUND(100*RECNO()/lnCount,0)
           WAIT "Updating arpost relations: " + STR(lnPercent,3) + " %" WINDOW NOWAIT
      ENDIF
      lnPostId = 0
      llSeekInHistpost = .T.
      IF SEEK(arpost.ap_reserid, "post", "tag1")
           SELECT post
           SCAN FOR ps_date = arpost.ap_sysdate AND ps_paynum = arpost.ap_paynum AND ps_amount = -arpost.ap_credit AND ;
                     ps_window = 0 AND ps_ifc = arpost.ap_billnr AND ps_supplem = PADL(DTOC(arpost.ap_date)+arpost.ap_ref,25) ;
                     WHILE ps_reserid = arpost.ap_reserid AND EMPTY(lnPostId)
                lnPostId = post.ps_postid
           ENDSCAN
           llSeekInHistpost = EMPTY(lnPostId) AND (arpost.ap_reserid < 1)
      ENDIF
      IF SEEK(arpost.ap_reserid, "histpost", "tag1")
           SELECT histpost
           SCAN FOR hp_date = arpost.ap_sysdate AND hp_paynum = arpost.ap_paynum AND hp_amount = -arpost.ap_credit AND ;
                     hp_window = 0 AND hp_ifc = arpost.ap_billnr AND hp_supplem = PADL(DTOC(arpost.ap_date)+arpost.ap_ref,25) ;
                     WHILE hp_reserid = arpost.ap_reserid AND EMPTY(lnPostId)
                lnPostId = histpost.hp_postid
           ENDSCAN
      ENDIF
      SELECT arpost
      IF NOT EMPTY(lnPostId)
           REPLACE ap_postid WITH lnPostId
      ENDIF
 ENDSCAN
 CloseFile("ledgpost")
 CloseFile("ledgpaym")
 CloseFile("arpost")
 CloseFile("reservat")
 CloseFile("histres")
 CloseFile("post")
 CloseFile("histpost")
ENDPROC
*
PROCEDURE UpdateRatecode90946
 LOCAL lnSetId
 
 IF OpenFile(.F.,"ratecode")
      SELECT DISTINCT rc_ratecod, rc_fromdat, rc_season FROM ratecode WHERE rc_rcsetid = 0 ORDER BY 1,2,3 INTO CURSOR curRatecode
      SELECT curRatecode
      SCAN
           UPDATE ratecode SET rc_rcsetid = NextId("RATESET") ;
                WHERE rc_rcsetid = 0 AND rc_ratecod = curRatecode.rc_ratecod AND ;
                rc_fromdat = curRatecode.rc_fromdat AND rc_season = curRatecode.rc_season AND rc_roomtyp = '*'
           lnSetId = NextId("RATESET")
           UPDATE ratecode SET rc_rcsetid = lnSetId ;
                WHERE rc_rcsetid = 0 AND rc_ratecod = curRatecode.rc_ratecod AND ;
                rc_fromdat = curRatecode.rc_fromdat AND rc_season = curRatecode.rc_season AND rc_roomtyp <> '*'
      ENDSCAN
      CloseFile("curRatecode")
 ENDIF
 CloseFile("ratecode")
ENDPROC
*
PROCEDURE UpdateBanquetAndResfixId90970
 OpenFile(.F., "Banquet")
 OpenFile(.F., "Hbanquet")
 OpenFile(.F., "Resfix")
 OpenFile(.F., "Hresfix")
 UPDATE Hbanquet SET bq_bqid = NextId("BANQUET")
 UPDATE Banquet SET bq_bqid = NextId("BANQUET")
 UPDATE Hresfix SET rf_rfid = NextId("RESFIX")
 UPDATE Resfix SET rf_rfid = NextId("RESFIX")
 CloseFile("Banquet")
 CloseFile("Hbanquet")
 CloseFile("Resfix")
 CloseFile("Hresfix")
ENDPROC
*
PROCEDURE UpdateVoucherToPostRelation909133
 LOCAL lnCountPost, lnCount, lnPercent

 OpenFile(.F., "voucher")
 OpenFile(.F., "article")
 OpenFile(.F., "post")
 OpenFile(.F., "histpost")
 SET ORDER TO "" IN voucher
 SET ORDER TO "" IN article
 SET ORDER TO "" IN post
 SET ORDER TO "" IN histpost

 lnPercent = 0
 lnCountPost = RECCOUNT("post")
 lnCount = lnCountPost + RECCOUNT("histpost")
 SELECT post
 SCAN FOR NOT EMPTY(ps_voucnum) AND NOT EMPTY(ps_artinum) AND DLookUp("article", "ar_artinum = " + SqlCnv(ps_artinum,.T.), "ar_artityp") = 4 AND ;
           SEEK(ps_voucnum, "voucher", "tag11") AND EMPTY(voucher.vo_postid)
      IF lnPercent < 100*RECNO()/lnCount
           lnPercent = ROUND(100*RECNO()/lnCount,0)
           WAIT "Updating voucher relations from post: " + STR(lnPercent,3) + " %" WINDOW NOWAIT
      ENDIF
      REPLACE vo_postid WITH post.ps_postid IN voucher
 ENDSCAN

 SELECT histpost
 SCAN FOR NOT EMPTY(hp_voucnum) AND NOT EMPTY(hp_artinum) AND DLookUp("article", "ar_artinum = " + SqlCnv(hp_artinum,.T.), "ar_artityp") = 4 AND ;
           SEEK(hp_voucnum, "voucher", "tag11") AND EMPTY(voucher.vo_postid)
      IF lnPercent < 100*(lnCountPost+RECNO())/lnCount
           lnPercent = ROUND(100*(lnCountPost+RECNO())/lnCount,0)
           WAIT "Updating voucher relations from histpost: " + STR(lnPercent,3) + " %" WINDOW NOWAIT
      ENDIF
      REPLACE vo_postid WITH histpost.hp_postid IN voucher
 ENDSCAN

 CloseFile("voucher")
 CloseFile("article")
 CloseFile("post")
 CloseFile("histpost")
ENDPROC
*
PROCEDURE UpdateVoucherToPostRelation100119
 LOCAL lnCountPost, lnCount, lnPercent

 OpenFile(.F., "voucher")
 OpenFile(.F., "article")
 OpenFile(.F., "post")
 OpenFile(.F., "histpost")
 SET ORDER TO "" IN voucher
 SET ORDER TO "" IN article
 SET ORDER TO "" IN post
 SET ORDER TO "" IN histpost

 lnPercent = 0
 lnCountPost = RECCOUNT("histpost")
 lnCount = lnCountPost + RECCOUNT("post")
 SELECT histpost
 SCAN FOR hp_voucnum > 0 AND NOT EMPTY(hp_artinum) AND DLookUp("article", "ar_artinum = " + SqlCnv(hp_artinum,.T.), "ar_artityp") = 4 AND ;
           SEEK(hp_voucnum, "voucher", "tag11") AND voucher.vo_postid <= 0
      IF lnPercent < 100*RECNO()/lnCount
           lnPercent = ROUND(100*RECNO()/lnCount,0)
           WAIT "Updating voucher relations from histpost: " + STR(lnPercent,3) + " %" WINDOW NOWAIT
      ENDIF
      REPLACE vo_postid WITH histpost.hp_postid IN voucher
 ENDSCAN

 SELECT post
 SCAN FOR ps_voucnum > 0 AND NOT EMPTY(ps_artinum) AND DLookUp("article", "ar_artinum = " + SqlCnv(ps_artinum,.T.), "ar_artityp") = 4 AND ;
           SEEK(ps_voucnum, "voucher", "tag11") AND voucher.vo_postid <= 0
      IF lnPercent < 100*(lnCountPost+RECNO())/lnCount
           lnPercent = ROUND(100*(lnCountPost+RECNO())/lnCount,0)
           WAIT "Updating voucher relations from post: " + STR(lnPercent,3) + " %" WINDOW NOWAIT
      ENDIF
      REPLACE vo_postid WITH post.ps_postid IN voucher
 ENDSCAN

 CloseFile("voucher")
 CloseFile("article")
 CloseFile("post")
 CloseFile("histpost")
ENDPROC
*
PROCEDURE UpdateBanquetId910162
 OpenFile(.F., "Banquet")
 OpenFile(.F., "Hbanquet")
 WAIT "Updating hbanquet.bq_bqid..." WINDOW NOWAIT
 UPDATE Hbanquet SET bq_bqid = NextId("BANQUET") WHERE bq_bqid = 0
 WAIT "Updating banquet.bq_bqid..." WINDOW NOWAIT
 UPDATE Banquet SET bq_bqid = NextId("BANQUET") WHERE bq_bqid = 0
 CloseFile("Banquet")
 CloseFile("Hbanquet")
 WAIT CLEAR
ENDPROC
*
PROCEDURE UpdateResrateSplit910162
LOCAL l_oOldRes, l_oNewRes

OpenFile(,"reservat")
OpenFile(,"resrate", "ResrateOld")
OpenFile(,"resrooms", "ResroomsOld")
OpenFile(,"resrooms")
OpenFile(,"ressplit")
OpenFile(,"althead")
OpenFile(,"altsplit")
OpenFile(,"resfix")
OpenFile(,"banquet")
OpenFile(,"picklist")
OpenFile(,"paymetho")
OpenFile(,"article")
OpenFile(,"ratearti")
SELECT reservat
SCAN FOR NOT EMPTY(rs_arrdate) AND NOT EMPTY(rs_depdate) AND NOT EMPTY(rs_roomtyp) AND NOT EMPTY(rs_ratecod) AND NOT INLIST(rs_status, 'NS', 'CXL') AND ;
          get_rt_roomtyp(rs_roomtyp, "rt_group") = 2
     WAIT "Updating conference reservations: " + TRANSFORM(rs_reserid) WINDOW NOWAIT
     SCATTER NAME l_oOldRes MEMO
     SCATTER NAME l_oNewRes MEMO
     RrUpdate(l_oOldRes, l_oNewRes, .T., rs_depdate, rs_depdate)
ENDSCAN
WAIT CLEAR
CloseFile("reservat")
CloseFile("ResrateOld")
CloseFile("ResroomsOld")
CloseFile("resrooms")
CloseFile("ressplit")
CloseFile("althead")
CloseFile("altsplit")
CloseFile("resfix")
CloseFile("banquet")
CloseFile("picklist")
CloseFile("paymetho")
CloseFile("article")
CloseFile("ratearti")
ENDPROC
*
PROCEDURE DBVersionOK
 LOCAL l_cVersion
 l_cVersion = GetFileVersion(APP_EXE_NAME)
 DO CASE
      CASE DB_LOWER_VER == CompareVersion(l_cVersion)
           *Must Update
           RETURN .F.
      CASE DB_HIGHIER_VER == CompareVersion(l_cVersion)
           Alert(getapplangtext("DBUPDATE","EXE_IS_LOWER_VERSION_THEN_DB"))
           RETURN .T.
      OTHERWISE
           * No update needed
           RETURN .T.
 ENDCASE
ENDPROC
*
PROCEDURE DoCreatinxAfter
 LPARAMETERS lp_lCheckConst, lp_lAvlRebuild
 LOCAL l_nSelect, l_lPack, l_lConsist

 * prepare for creatinx
 PRIVATE alGroup
 DIMENSION alGroup[10]

 l_nSelect = SELECT()

 IF lp_lCheckConst
      IF openfile() AND openfile(.F.,"license")
           STORE .F. TO alGroup
           l_lPack = .F.
           l_lConsist = .T.
           = crEatinx(l_lPack,0,l_lConsist, .T., .T.)
      ENDIF
 ENDIF

 IF lp_lAvlRebuild
      IF openfile()
           DO avlrebuild IN avlupdat
      ENDIF
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
PROCEDURE OpenAllTablesExclusive
 PRIVATE ctExt
 LOCAL l_lTry, l_lSuccess, l_cAlert
 
 IF openfiledirect(.T., "files")
      dclose("files")
 ELSE
      l_cAlert = getapplangtext("DBUPDATE","CANT_OPEN_FILES_EXCLUSIVE") + ":" + CHR(13) + "files.dbf"
      = loGdata(l_cAlert,cuPdatefile)
      = alert(l_cAlert)
      RETURN .F.
 ENDIF
 IF openfiledirect(.T., "fields")
      dclose("fields")
 ELSE
      l_cAlert = getapplangtext("DBUPDATE","CANT_OPEN_FILES_EXCLUSIVE") + ":" + CHR(13) + "fields.dbf"
      = loGdata(l_cAlert,cuPdatefile)
      = alert(l_cAlert)
      RETURN .F.
 ENDIF
 
 IF odbc()
      l_lSuccess = .T.
 ELSE
      l_lTry = .T.
      DO WHILE l_lTry
           * Sending "L" as sign not to open license table
           l_lSuccess = opEnfile(.T.,"LN",.T.)
           IF NOT l_lSuccess
                ctExt = getapplangtext("DBUPDATE","CANT_OPEN_FILES_EXCLUSIVE") + CHR(13) + getapplangtext("DBUPDATE","TRY_AGAIN")
                IF NOT yesno(ctExt,"Open Error")
                    ctExt = ctExt + " [NO] - Abort."
                    l_lTry = .F.
                ENDIF
           ELSE
                l_lTry = .F.
           ENDIF
      ENDDO
      IF l_lSuccess AND _screen.oGlobal.lmultiproper
           LOCAL l_cFailTablesList

           * Try to open server tables: adrmain, idmain etc. When no tables found, then skip it, and let update
           * procedure create it.

           l_cFailTablesList = ""
           SELECT fi_name FROM files WHERE "R" $ fi_flag INTO CURSOR curremotetables
           SCAN ALL
                    IF FILE(gcDatadir+FORCEEXT(LOWER(ALLTRIM(curremotetables.fi_name)),"dbf"))
                         IF NOT openfile(.T.,curremotetables.fi_name)
                              l_cFailTablesList = l_cFailTablesList + LOWER(ALLTRIM(curremotetables.fi_name)) + ","
                         ENDIF
                    ENDIF
           ENDSCAN
           dclose("curremotetables")
           IF NOT EMPTY(l_cFailTablesList)
                l_cFailTablesList = LEFT(l_cFailTablesList, LEN(l_cFailTablesList)-1)
                l_cAlert = getapplangtext("DBUPDATE","CANT_OPEN_FILES_EXCLUSIVE") + ":" + CHR(13) + l_cFailTablesList
                = loGdata(l_cAlert,cuPdatefile)
                = alert(l_cAlert)
                RETURN .F.
           ENDIF
      ENDIF
 ENDIF
 IF NOT l_lSuccess
      = loGdata(ctExt,cuPdatefile)
      RETURN .F.
 ELSE
      = loGdata("All files can be opened exclusive, start update!",cuPdatefile)
 ENDIF
 CloseAllFiles(, "[license]")
 RETURN .T.
ENDPROC
*
PROCEDURE DBUpdateParam2
LOCAL l_nSelect, l_oData
l_nSelect = SELECT()
= openfile(.F.,"param2")
SELECT param2
IF RECCOUNT()=0
     SCATTER NAME l_oData BLANK
     INSERT INTO param2 FROM NAME l_oData
ENDIF
= CloseFile("param2")
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE GetTablesWhereIndexAreChanged
LOCAL l_nSelect, l_cTmpCur
IF NOT openfiledirect(.T.,"files")
     RETURN .F.
ENDIF
l_cTmpCur = SYS(2015)
SELECT * FROM files WHERE .F. INTO CURSOR fnew READWRITE
APPEND FROM metadata\files.txt DELIMITED WITH ~ WITH TAB

SELECT fi_name FROM ;
      ( ;
      SELECT fi_name, ;
           fi_key1,  fi_key2,  fi_key3,  fi_key4,  fi_key5,  fi_key6,  fi_key7,  fi_key8,  fi_key9,  fi_key10, ; 
           fi_key11, fi_key12, fi_key13, fi_key14, fi_key15, fi_key16, fi_key17, fi_key18, fi_key19, fi_key20, ; 
           fi_key21, fi_key22, fi_key23, fi_key24, fi_key25, fi_key26, fi_key27, fi_key28, fi_key29, fi_key30, ; 
           fi_key31, fi_key32, fi_key33, fi_key34, fi_key35, fi_key36, fi_key37, fi_key38, fi_key39, fi_key40, ; 
           fi_key41, fi_key42, fi_key43, fi_key44, fi_key45, ;
           fi_uni1,  fi_uni2,  fi_uni3,  fi_uni4,  fi_uni5,  fi_uni6,  fi_uni7,  fi_uni8,  fi_uni9,  fi_uni10, ; 
           fi_uni11, fi_uni12, fi_uni13, fi_uni14, fi_uni15, fi_uni16, fi_uni17, fi_uni18, fi_uni19, fi_uni20, ; 
           fi_uni21, fi_uni22, fi_uni23, fi_uni24, fi_uni25, fi_uni26, fi_uni27, fi_uni28, fi_uni29, fi_uni30, ; 
           fi_uni31, fi_uni32, fi_uni33, fi_uni34, fi_uni35, fi_uni36, fi_uni37, fi_uni38, fi_uni39, fi_uni40, ; 
           fi_uni41, fi_uni42, fi_uni43, fi_uni44, fi_uni45, ;
           fi_des1,  fi_des2,  fi_des3,  fi_des4,  fi_des5,  fi_des6,  fi_des7,  fi_des8,  fi_des9,  fi_des10, ; 
           fi_des11, fi_des12, fi_des13, fi_des14, fi_des15, fi_des16, fi_des17, fi_des18, fi_des19, fi_des20, ; 
           fi_des21, fi_des22, fi_des23, fi_des24, fi_des25, fi_des26, fi_des27, fi_des28, fi_des29, fi_des30, ; 
           fi_des31, fi_des32, fi_des33, fi_des34, fi_des35, fi_des36, fi_des37, fi_des38, fi_des39, fi_des40, ; 
           fi_des41, fi_des42, fi_des43, fi_des44, fi_des45 ;
         FROM files fold WHERE UPPER(ALLTRIM(fi_name)) == UPPER(ALLTRIM(fi_alias)) ;
      UNION ;
      SELECT fi_name, ;
           fi_key1,  fi_key2,  fi_key3,  fi_key4,  fi_key5,  fi_key6,  fi_key7,  fi_key8,  fi_key9,  fi_key10, ; 
           fi_key11, fi_key12, fi_key13, fi_key14, fi_key15, fi_key16, fi_key17, fi_key18, fi_key19, fi_key20, ; 
           fi_key21, fi_key22, fi_key23, fi_key24, fi_key25, fi_key26, fi_key27, fi_key28, fi_key29, fi_key30, ; 
           fi_key31, fi_key32, fi_key33, fi_key34, fi_key35, fi_key36, fi_key37, fi_key38, fi_key39, fi_key40, ; 
           fi_key41, fi_key42, fi_key43, fi_key44, fi_key45, ;
           fi_uni1,  fi_uni2,  fi_uni3,  fi_uni4,  fi_uni5,  fi_uni6,  fi_uni7,  fi_uni8,  fi_uni9,  fi_uni10, ; 
           fi_uni11, fi_uni12, fi_uni13, fi_uni14, fi_uni15, fi_uni16, fi_uni17, fi_uni18, fi_uni19, fi_uni20, ; 
           fi_uni21, fi_uni22, fi_uni23, fi_uni24, fi_uni25, fi_uni26, fi_uni27, fi_uni28, fi_uni29, fi_uni30, ; 
           fi_uni31, fi_uni32, fi_uni33, fi_uni34, fi_uni35, fi_uni36, fi_uni37, fi_uni38, fi_uni39, fi_uni40, ; 
           fi_uni41, fi_uni42, fi_uni43, fi_uni44, fi_uni45, ;
           fi_des1,  fi_des2,  fi_des3,  fi_des4,  fi_des5,  fi_des6,  fi_des7,  fi_des8,  fi_des9,  fi_des10, ; 
           fi_des11, fi_des12, fi_des13, fi_des14, fi_des15, fi_des16, fi_des17, fi_des18, fi_des19, fi_des20, ; 
           fi_des21, fi_des22, fi_des23, fi_des24, fi_des25, fi_des26, fi_des27, fi_des28, fi_des29, fi_des30, ; 
           fi_des31, fi_des32, fi_des33, fi_des34, fi_des35, fi_des36, fi_des37, fi_des38, fi_des39, fi_des40, ; 
           fi_des41, fi_des42, fi_des43, fi_des44, fi_des45 ;
         FROM fnew WHERE UPPER(ALLTRIM(fi_name)) == UPPER(ALLTRIM(fi_alias)) ;
      ) c1 ;
      GROUP BY 1 ;
      HAVING COUNT(*)>1 ;
      INTO CURSOR (l_cTmpCur) READWRITE

closefile("fnew")

SELECT (l_cTmpCur)
SCAN FOR NOT dlocate(p_cCurReindex, "fi_name = " + sqlcnv(&l_cTmpCur..fi_name))
     INSERT INTO (p_cCurReindex) (fi_name) VALUES (&l_cTmpCur..fi_name)
ENDSCAN
closefile(l_cTmpCur)

SELECT(l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE DBReindexRest
* Here reindex wath was left in cursor p_cCurReindex
LOCAL l_nSelect, l_cTableName, cCdxname
IF TYPE("p_cCurReindex")="C" AND NOT EMPTY(p_cCurReindex) AND USED(p_cCurReindex)
     l_nSelect = SELECT()
     SELECT &p_cCurReindex
     SCAN ALL
          l_cTableName = ALLTRIM(&p_cCurReindex..fi_name)
          *ProcCryptor(CR_UNREGISTER, gcDatadir, l_cTableName)
          cCdxname = gcDatadir+l_cTableName+".Cdx"
          fiLedelete(cCdxname)
          *ProcCryptor(CR_ENCODE, gcDatadir, l_cTableName)
          IF OpenFile(.F.,l_cTableName)
               CloseFile(l_cTableName)
          ENDIF
     ENDSCAN
     closefile(p_cCurReindex)
     SELECT(l_nSelect)
ENDIF
ENDPROC
*
PROCEDURE DBUpdateSetPointIndex
* Set point is taken over new function in ini.prg.
* In all datasessions is now same SET POINT
* We must rebuild all tables where STR() over rs_reserid is used, to prevent SEEK failures.
LOCAL l_nSelect, l_cCurTbl
IF TYPE("p_cCurReindex")="C" AND NOT EMPTY(p_cCurReindex) AND USED(p_cCurReindex)
     l_nSelect = SELECT()
     l_cCurTbl = SYS(2015)
     CREATE CURSOR (l_cCurTbl) (fi_name c(8))
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("BILLINST")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("HBILLINS")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("HRESRATE")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("HRESROOM")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("RESPICT")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("RESRATE")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("RESROOMS")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("ROOMPLAN")
     INSERT INTO (l_cCurTbl) (fi_name) VALUES ("SHEET")
     SCAN FOR NOT dlocate(p_cCurReindex, "fi_name = " + sqlcnv(&l_cCurTbl..fi_name))
          INSERT INTO (p_cCurReindex) (fi_name) VALUES (&l_cCurTbl..fi_name)
     ENDSCAN
     closefile(l_cCurTbl)
     SELECT(l_nSelect)
ENDIF
ENDPROC
*
PROCEDURE CreateReindexCursor
LOCAL l_nSelect
l_nSelect = SELECT()
p_cCurReindex = SYS(2015)
SELECT 0
CREATE CURSOR (p_cCurReindex) (fi_name c(8))
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE DBAlterFilesTable
LOCAL l_nTag
IF NOT openfiledirect(.T.,"files")
     RETURN .F.
ENDIF

FOR l_nTag = 1 TO 45
     IF TYPE('files.fi_key'+ALLTRIM(STR(l_nTag)))="U"
          ALTER TABLE files ADD COLUMN ('fi_key'+ALLTRIM(STR(l_nTag))) c (254)
     ENDIF
     IF TYPE('files.fi_uni'+ALLTRIM(STR(l_nTag)))="U"
          ALTER TABLE files ADD COLUMN ('fi_uni'+ALLTRIM(STR(l_nTag))) l
     ENDIF
     IF TYPE('files.fi_des'+ALLTRIM(STR(l_nTag)))="U"
          ALTER TABLE files ADD COLUMN ('fi_des'+ALLTRIM(STR(l_nTag))) l
     ENDIF
ENDFOR
IF TYPE('files.fi_unikey')="U"
     ALTER TABLE files ADD COLUMN fi_unikey c (254)
ENDIF
IF TYPE('files.fi_vfp')="U"
     ALTER TABLE files ADD COLUMN fi_vfp l
ENDIF

* Postgre indexes definition.
FOR l_nTag = 1 TO 20
     IF TYPE('files.fi_pidx'+ALLTRIM(STR(l_nTag)))="U"
          ALTER TABLE files ADD COLUMN ('fi_pidx'+ALLTRIM(STR(l_nTag))) c (254)
     ENDIF
ENDFOR

RETURN .T.
ENDPROC
*
PROCEDURE DBRestoreFilesTableBackup
LOCAL i, l_cKey
 * Now add data from original table, in this case, "X" Flag
 IF ALEN(p_aFilesTableBackup,1)>1
      FOR i = 1 TO ALEN(p_aFilesTableBackup,1)
           IF "X" $ p_aFilesTableBackup(i,7)
                l_cKey = UPPER(p_aFilesTableBackup(i,1)+p_aFilesTableBackup(i,2)+p_aFilesTableBackup(i,4))
                SELECT files
                LOCATE FOR UPPER(fi_name+fi_path+fi_alias) == l_cKey
                IF FOUND() AND NOT ("X" $ fi_flag)
                     REPLACE fi_flag WITH ALLTRIM(fi_flag) + "X"
                     FLUSH
                ENDIF
           ENDIF
      ENDFOR
 ENDIF
ENDPROC
*
PROCEDURE DBShowProgress
LPARAMETERS lp_cPart
DO CASE
     CASE EMPTY(lp_cPart)
          DBShowProgressMessage(getapplangtext("DBUPDATE","UPDATE_IN_PROGRESS"))
     CASE lp_cPart = "END"
          DBShowProgressMessage(getapplangtext("DBUPDATE","UPDATE_FINISHED"))
          WAIT CLEAR
     OTHERWISE
          DBShowProgressMessage(getapplangtext("DBUPDATE","UPDATE_IN_PROGRESS"))
     ENDCASE
ENDPROC
*
PROCEDURE DBShowProgressMessage
LPARAMETERS lp_cText
IF EMPTY(lp_cText)
     lp_cText = ""
ENDIF
WAIT WINDOW lp_cText NOWAIT
IF TYPE("frmsplash")="O"
     frmsplash.SetLabelCaption(lp_cText)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE CheckIfRecordsExits
* Here add standard records, which must exists.
LOCAL l_oData

* Add record to param2, when missing
IF openfile(.F.,"param2")
     IF RECCOUNT("param2")=0
          SELECT param2
          APPEND BLANK
     ENDIF
ENDIF

* Add records for debitor
IF openfile(.F.,"arpcond") AND openfile(.F.,"arremd") AND openfile(.F.,"picklist")
     
     * arpcond
     SELECT COUNT(*) FROM arpcond WHERE NOT ay_credito INTO ARRAY l_aResult
     IF l_aResult(1)=0
          SELECT arpcond
          SCATTER NAME l_oData MEMO BLANK
          l_oData.ay_ayid = nextid("ARPCOND")
          l_oData.ay_number = 1
          l_oData.ay_label = "Standard"
          l_oData.ay_header = "Standard"
          INSERT INTO arpcond FROM NAME l_oData
     ENDIF
     * set standard
     SELECT pl_numcod FROM picklist WHERE pl_label = "ARPCOND" AND pl_charcod = "DEF" INTO CURSOR curpicklist
     IF RECCOUNT()=0
          SELECT TOP 1 ay_number FROM arpcond ORDER BY ay_number INTO ARRAY l_aResult
          SELECT picklist
          SCATTER NAME l_oData MEMO BLANK
          l_oData.pl_label = "ARPCOND"
          l_oData.pl_charcod = "DEF"
          l_oData.pl_numcod = l_aResult(1)
          INSERT INTO picklist FROM NAME l_oData
     ENDIF
     * arremd
     SELECT COUNT(*) FROM arremd INTO ARRAY l_aResult
     IF l_aResult(1)=0
          SELECT arremd
          SCATTER NAME l_oData MEMO BLANK
          l_oData.am_amid = nextid("ARREMD")
          l_oData.am_number = 1
          l_oData.am_label = "Standard"
          l_oData.am_header = "Standard"
          l_oData.am_dayrem1 = 28
          l_oData.am_dayrem2 = 21
          l_oData.am_dayrem3 = 14

* Set default text
TEXT TO l_oData.am_remtxt1 TEXTMERGE NOSHOW
Trotz unserer Zahlungserinnerung steht die unten genannte Rechnung bei uns immer noch zur Zahlung offen.
Unten genannte Rechnung steht bis zum heutigen Tag bei uns noch zur Zahlung offen.
Sicherlich ist es Ihnen entgangen den offenen Betrag zu begleichen.
Wir bitten Sie daher, Ihre Zahlung nunmehr innerhalb der n�chsten 8 Tage auf das
unten angegebene Konto vorzunehmen.

Sollten Sie in der Zwischenzeit gezahlt haben, betrachten Sie dieses Schreiben bitte
als gegenstandslos.
ENDTEXT

TEXT TO l_oData.am_remtxt2 TEXTMERGE NOSHOW
Wir m�ssen Sie daher bitten, den Rechnungsbetrag nunmehr unverz�glich auf das unten stehende Konto
zu �berweisen.

Wir erwarten Ihre Zahlung, oder falls es bei uns zu einer Fehlbuchung gekommen ist, Ihre Mitteilung
wann und wie Sie die Rechnung beglichen haben.
ENDTEXT

TEXT TO l_oData.am_remtxt3 TEXTMERGE NOSHOW
Trotz unserer Zahlungserinnerung und unserer Mahnung steht die unten genannte Rechnung bei uns
immer noch zur Zahlung offen. Wir fordern Sie daher letztmalig auf, den Gesamtbetrag innerhalb von
5 Tagen auf das unten stehende Konto zu �berweisen.

Falls es bei uns zu einer Fehlbuchung gekommen ist, teilen Sie uns bitte mit, wann und wie Sie die 
Rechnung beglichen haben.

Sollten wir auch auf diese Mahnung keine Zahlung oder Nachricht von Ihnen erhalten, werden wir
unseren Rechtsanwalt mit der Eintreibung beauftragen.
ENDTEXT
          
          INSERT INTO arremd FROM NAME l_oData
     ENDIF
     * set standard
     SELECT pl_numcod FROM picklist WHERE pl_label = "ARREMD" AND pl_charcod = "DEF" INTO CURSOR curpicklist
     IF RECCOUNT()=0
          SELECT TOP 1 am_number FROM arremd ORDER BY am_number INTO ARRAY l_aResult
          SELECT picklist
          SCATTER NAME l_oData MEMO BLANK
          l_oData.pl_label = "ARREMD"
          l_oData.pl_charcod = "DEF"
          l_oData.pl_numcod = l_aResult(1)
          INSERT INTO picklist FROM NAME l_oData
     ENDIF
     closefile("curpicklist")

ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE DBBlockOtherWorkStations
#DEFINE WAIT_SEC_FOR_USERS_TO_LOG_OFF     30
LPARAMETERS lp_lSuccess
PRIVATE p_nHandle
LOCAL LDateTime, l_cStation, l_lMustLogOut, l_lTry, l_lStillLoged, l_cMessage, l_tDateTime, l_lUseExcl, l_tTimeStartedBlock
p_nHandle = 0
l_cMessage = ""
IF EMPTY(g_userid)
     g_userid = "SUPERVISOR"
ENDIF
DBBlockOtherWorkStationsComServers(.T.)
l_tTimeStartedBlock = DATETIME()
IF openfiledirect(.F.,"license") AND openfiledirect(.F.,"messages")
     LDateTime = DATETIME()
     l_cStation = winpc()
     DBBrowseLicense(l_cStation)
     SELECT license
     SCAN ALL
          IF NOT dlock(,2,.T.)
               l_lMustLogOut = .T.
               * send log off message only once
               IF NOT dlocate("messages", "ms_code = " + sqlcnv(LOG_OFF_MSG) + ;
                         " AND ms_2userid = " + sqlcnv(license.lc_user) + ;
                         " AND ms_station = " + sqlcnv(license.lc_station))
                    INSERT INTO messages (ms_id, ms_time, ms_code, ms_text, ms_userid, ms_2userid, ms_station) ;
                              VALUES (nextid("MESSAGES") , LDateTime , LOG_OFF_MSG, GetLangText("USERLIST","TXT_LOGOUTINSEC"), ;
                                        g_userid, license.lc_user, license.lc_station)
               ENDIF
          ELSE
               IF NOT EMPTY(lc_date)
                    REPLACE lc_date WITH {}, lc_station WITH "", lc_time WITH "", lc_user WITH "" IN license
                    FLUSH
               ENDIF
               dunlock()
          ENDIF
          DBBrowseLicense(l_cStation)
     ENDSCAN
     IF NOT l_lMustLogOut
          l_lUseExcl = openfiledirect(.T.,"license")
          openfiledirect(.F.,"license")
          l_lMustLogOut = NOT l_lUseExcl
     ENDIF
     IF l_lMustLogOut
          WAIT WINDOW getapplangtext("DBUPDATE","WAIT_USERS_LOGOFF") NOWAIT
          l_tDateTime = DATETIME()
          DO WHILE DATETIME()-l_tDateTime < WAIT_SEC_FOR_USERS_TO_LOG_OFF
               sleep(1000)
               WAIT WINDOW getapplangtext("DBUPDATE","WAIT_USERS_LOGOFF") NOWAIT
               DOEVENTS FORCE
          ENDDO
          IF _screen.oGlobal.lUseMainServer
               * send Release data message to multiproper installation
               l_lUseExcl = OpenFileDirect(.T.,"license")
               OpenFileDirect(.F.,"license")
               IF NOT l_lUseExcl AND OpenFileDirect(,"messages", "messages_srv", FNGetMPDataPath(_screen.oGlobal.oParam2.pa_srvpath))
                    IF NOT DLocate("messages_srv", "ms_code = " + SqlCnv(RELEASE_DATA_MSG) + " AND ms_station = " + SqlCnv(l_cStation))
                         INSERT INTO messages_srv (ms_id, ms_time, ms_code, ms_userid, ms_hotcode, ms_text) ;
                              VALUES (NextId("MESSAGES"), LDateTime, RELEASE_DATA_MSG, g_userid, _screen.oGlobal.oParam2.pa_hotcode, ;
                              Str2Msg(GetLangText("MESSAGE","TXT_NA_AUTO_LOGOUT_10"),"%s",ALLTRIM(_screen.oGlobal.oParam2.pa_hotcode)))
                    ENDIF
                    WAIT WINDOW getapplangtext("DBUPDATE","WAIT_USERS_LOGOFF") NOWAIT
                    l_tDateTime = DATETIME()
                    DO WHILE DATETIME()-l_tDateTime < WAIT_SEC_FOR_USERS_TO_LOG_OFF
                         Sleep(1000)
                         WAIT WINDOW getapplangtext("DBUPDATE","WAIT_USERS_LOGOFF") NOWAIT
                         DOEVENTS FORCE
                    ENDDO
               ENDIF
               DClose("messages_srv")
          ENDIF
          WAIT CLEAR
     ENDIF
ENDIF

l_lTry = .T.
DO WHILE l_lTry
     l_lSuccess = openfiledirect(.T.,"license")

     IF NOT l_lSuccess
          IF openfiledirect(.F.,"license")
               l_lStillLoged = .F.
               SELECT license
               SCAN ALL
                    IF dlock(,1,.T.)
                         IF NOT EMPTY(lc_date)
                              REPLACE lc_date WITH {}, lc_station WITH "", lc_time WITH "", lc_user WITH "" IN license
                              FLUSH
                         ENDIF
                         dunlock()
                    ELSE
                         l_lStillLoged = .T.
                    ENDIF
               ENDSCAN
               DBBrowseLicense(l_cStation)
          ENDIF
          IF l_lStillLoged
               l_cMessage = getapplangtext("DBUPDATE","SOME_USERS_ARE_LOGGED")
          ELSE
               l_cMessage = "License " + getapplangtext("DBUPDATE","TABLE_CANT_OPEN_EXCLUSIVE")
          ENDIF
          IF NOT _screen.oGlobal.lDoAuditOnStartup
               l_lTry = yesno(l_cMessage + " " + getapplangtext("DBUPDATE","TRY_AGAIN"))
               IF l_lTry
                    action(102)
               ELSE
                    action(101)
               ENDIF
          ELSE
               l_lTry = .F.
          ENDIF
     ELSE
          l_lTry = .F.
     ENDIF
ENDDO
RELEASE p_ogrdlicense
dclose("curlicense") && To close browse window
dclose("messages")
IF DATETIME() - l_tTimeStartedBlock < 2
     WAIT WINDOW NOWAIT "Wait additional 2 sec."
     sleep(2000)
ENDIF
DBBlockOtherWorkStationsComServers(.F.)
lp_lSuccess = l_lSuccess
RETURN l_lSuccess
ENDPROC
*
PROCEDURE DBBrowseLicense
LPARAMETERS lp_cStation
LOCAL l_nSelect, l_nRecords
l_nSelect = SELECT()
lp_cStation = PADR(lp_cStation,15)
IF USED("license")
     IF NOT USED("curlicense")
          RELEASE p_ogrdlicense
          PUBLIC p_ogrdlicense AS Grid
          SELECT TRANSFORM(lc_date)+' '+TRANSFORM(lc_time) AS Started, lc_station AS PC, lc_user AS User FROM license WHERE .F. INTO CURSOR curlicense READWRITE
          BROWSE ;
                    TITLE getapplangtext("DBUPDATE","WAITING_FOR_STATIONS") ;
                    NOWAIT NAME p_ogrdlicense ;
                    NOAPPEND NODELETE NOMODIFY NOMENU IN SCREEN
          p_ogrdlicense.Visible = .F.
          p_ogrdlicense.DeleteMark = .F.
          p_ogrdlicense.RecordMark = .F.
          p_ogrdlicense.GridLines = 0
          p_ogrdlicense.ScrollBars = 0
          p_ogrdlicense.Width = 600
          p_ogrdlicense.Height = 500
          p_ogrdlicense.Top = 0
          p_ogrdlicense.Left = 0
          p_ogrdlicense.ReadOnly = .T.
     ENDIF
     SELECT TRANSFORM(lc_date)+' '+TRANSFORM(lc_time) AS Started, lc_station AS PC, lc_user AS User ;
          FROM license ;
          WHERE lc_user<>"          " AND lc_station<>lp_cStation INTO CURSOR tmpcurlicense
     SELECT curlicense
     DELETE ALL
     APPEND FROM DBF("tmpcurlicense")
     COUNT TO l_nRecords
     LOCATE
     dclose("tmpcurlicense")
     IF l_nRecords > 0
          IF NOT p_ogrdlicense.Visible
               p_ogrdlicense.Visible = .T.
          ENDIF
          p_ogrdlicense.Refresh()
     ENDIF
ELSE
     p_ogrdlicense = .NULL.
ENDIF
SELECT (l_nSelect)
RETURN p_ogrdlicense
ENDPROC
*
PROCEDURE DBUnlockOtherWorkStations
     getapplangtext("DBUPDATE","ALLOW_USERS_TO_LOGIN")
IF yesno(getapplangtext("DBUPDATE","ALLOW_USERS_TO_LOGIN"))
     dclose("license")
ELSE
    DO DebugBlockAllUsers IN Debug WITH .T., .T.
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE DBBlockOtherWorkStationsComServers
#DEFINE C_COMSERVERS_BLOCK_FILE     "dsrvblock.txt"
LPARAMETERS lp_lBlock
LOCAL l_cFile, i, l_lSuccess
l_cFile = gcDatadir + C_COMSERVERS_BLOCK_FILE
IF NOT FILE(l_cFile)
     STRTOFILE("",l_cFile,0)
ENDIF
IF lp_lBlock
     FOR i = 1 TO 60
          p_nHandle = FOPEN(l_cFile,2)
          IF p_nHandle > 0
               EXIT
          ELSE
               sleep(100)
               DOEVENTS
          ENDIF
     ENDFOR
     l_lSuccess = (p_nHandle > 0)
ELSE
     l_lSuccess = FCLOSE(p_nHandle)
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE DBCopyNewExe
LOCAL ARRAY laToDoList[1,7]
LOCAL l_cCurExe, l_cOldExe, l_cNewExe, l_lError, l_cNewExeName, l_nCount, l_cDestDir, l_cSourceDir, l_cMacro, ;
          l_lMultiProper, l_cIniFile, l_cData, l_lDontRegister, l_cMessage, l_nRow

l_cNewExe = g_cexenameandpath
l_cNewExeName = LOWER(ALLTRIM(JUSTFNAME(g_cexenameandpath)))
l_cCurExe = ADDBS(JUSTPATH(l_cNewExe)) + APP_EXE_NAME
IF l_cNewExeName <> APP_EXE_NAME

     * We must copy it
     WAIT WINDOW "Copy new EXE..." NOWAIT
     l_cOldExe = ADDBS(JUSTPATH(l_cNewExe)) + APP_EXE_OLD_NAME
     IF FILE(l_cOldExe)
          DELETE FILE (l_cOldExe)
          IF FILE(l_cOldExe)
               * Delete failed. Rename it.
               TRY
                    RENAME (l_cOldExe) TO (l_cOldExe+SYS(2015))
               CATCH
               ENDTRY
          ENDIF
     ENDIF
     IF NOT FILE(l_cOldExe)
          IF TYPE("g_myshell") = "O" AND NOT ISNULL(g_myshell)
               l_nCount = 1
               DO WHILE l_nCount < 10
                    g_myshell.Run([%COMSPEC% /C RENAME ] + l_cCurExe + [ ] + APP_EXE_OLD_NAME,0)
                    sleep(1000)
                    IF NOT FILE(l_cCurExe)
                         EXIT
                    ENDIF
                    l_nCount = l_nCount + 1
               ENDDO
               IF NOT FILE(l_cCurExe)
                    l_nCount = 1
                    DO WHILE l_nCount < 10
                         CopyFile(l_cNewExe, l_cCurExe, 0)
                         sleep(1000)
                         IF FILE(l_cCurExe)
                              EXIT
                         ENDIF
                         l_nCount = l_nCount + 1
                    ENDDO
               ENDIF
               
          ENDIF

          IF FILE(l_cCurExe)
               = loGdata(APP_EXE_NAME + " copied",cuPdatefile)
               
               IF FILE(p_cBackupFolder + APP_EXE_OLD_NAME)
                    DELETE FILE (p_cBackupFolder + APP_EXE_OLD_NAME)
                    sleep(500)
               ENDIF
               
               IF FILE(l_cOldExe)
                    CopyFile(l_cOldExe, p_cBackupFolder + APP_EXE_OLD_NAME, 0)
                    sleep(500)
               ENDIF
               IF FILE(l_cOldExe)
                    DELETE FILE (l_cOldExe)
                    IF FILE(l_cOldExe)
                         * Delete failed. Rename it.
                         TRY
                              RENAME (l_cOldExe) TO (l_cOldExe+SYS(2015))
                         CATCH
                         ENDTRY
                    ENDIF
               ENDIF
          ENDIF
     ENDIF
     WAIT CLEAR
ENDIF

* copy all from dbupdate folder to hotel root
l_cDestDir = ADDBS(JUSTPATH(g_cexenameandpath))
l_cSourceDir = l_cDestDir+"apupdate"

IF DIRECTORY(l_cSourceDir)
     WAIT WINDOW "Copy other files..." NOWAIT
     l_cSourceDir = ADDBS(l_cSourceDir) + "*.*"
     llSuccess = FileOpWithProgressbar(l_cSourceDir, l_cDestDir, "Copy")
     WAIT WINDOW "Copy other files... Finished!" NOWAIT
ENDIF

* Try do register citadel.exe as automation server
* For multiproper versions don't do it. In multiproper we have more then 1 installations
* on single PC, and registering is pointless, it would be only last updated installation
* active.

l_lMultiProper = .F.
l_lDontRegister = .F.
l_cIniFile = FULLPATH(INI_FILE)
IF FILE(l_cIniFile)
     l_cData = readini(l_cIniFile, "System","UseMainServer", "no")
     IF NOT EMPTY(l_cData) AND ALLTRIM(LOWER(l_cData))=="yes"
          l_lMultiProper = .T.
     ENDIF
     IF NOT l_lMultiProper
          l_lDontRegister = LOWER(readini(l_cIniFile, "update","dontregistercitadelexe", "no"))="yes"
     ENDIF
ENDIF
DO CASE
     CASE l_lMultiProper
          WAIT WINDOW "Skiping registering citadel.exe as automation server, because this is MULTIPROPER!" NOWAIT
          = loGdata("Skiping registering citadel.exe as automation server, because this is MULTIPROPER!",cuPdatefile)
     CASE l_lDontRegister
          WAIT WINDOW "Skiping registering citadel.exe as automation server, because dontregistercitadelexe=yes in citadel.ini!" NOWAIT
          = loGdata("Skiping registering citadel.exe as automation server, because dontregistercitadelexe=yes in citadel.ini!",cuPdatefile)
     OTHERWISE
          WAIT WINDOW "Registering citadel.exe as automation server" NOWAIT
          = loGdata("Try do register citadel.exe as automation server",cuPdatefile)
          RegisterCOMComponent(l_cCurExe, "Citadel.cDeskServer", @l_cMessage, @laToDoList)
ENDCASE
IF _screen.oGlobal.lTableReservationPlans AND FILE("common\dll\wpftableres.dll")
     WAIT WINDOW "Registering wpftableres.dll as ActiveX control" NOWAIT
     = loGdata("Try do register a .Net COM component 'wpftableres.dll' as ActiveX control using RegAsm for Argus table reservation plans.",cuPdatefile)
     RegisterDotNetComponent("common\dll\wpftableres.dll", "WpfTableRes.HTableRes", @l_cMessage, @laToDoList)
     IF NOT EMPTY(l_cMessage)
          = loGdata(l_cMessage,cuPdatefile)
     ENDIF
ENDIF

WAIT WINDOW "Registering TAPIExCt.dll" NOWAIT
= loGdata("Try do register TAPIExCt.dll",cuPdatefile)
RegisterCOMComponent(l_cDestDir+"common\dll\TAPIExCt.dll", "TAPIEx.TAPIEx_b.1", @l_cMessage, @laToDoList)

BatchRegistration(@laToDoList)
FOR l_nRow = 1 TO ALEN(laToDoList,1)
     IF NOT EMPTY(laToDoList[l_nRow,7])
          = loGdata(laToDoList[l_nRow,7],cuPdatefile)
     ENDIF
NEXT

WAIT CLEAR

RETURN .T.
ENDPROC
*
PROCEDURE DBCheckCodePage
* Check config.fpw
LOCAL l_lChanged, l_cCountry, l_cConfigFpwFile, l_cCodePage, l_cConfigFpwText, l_nCFLines, l_cConfigFpwTextNew, i, ;
          l_cCFLine, l_cParameter
LOCAL ARRAY l_aCFLines(1)
l_lChanged = .F.
l_cCountry = ""
l_cConfigFpwFile = FULLPATH("config.fpw")
IF NOT odbc() AND NOT USED("param")
     openfile(.F.,"param")
ENDIF
sqlcursor("SELECT pa_country FROM param","cpco6501")
IF USED("cpco6501")
     l_cCountry = PADR(ALLTRIM(cpco6501.pa_country),3)
ENDIF
dclose("cpco6501")
IF NOT EMPTY(l_cCountry)

     * Determine for which country which codepage should be used.
     DO CASE
          CASE l_cCountry=="RS "
               l_cCodePage = "1250" && Easteurope
          OTHERWISE
               l_cCodePage = "1252" && Westerneurope
     ENDCASE

     IF FILE(l_cConfigFpwFile)
          l_cConfigFpwText = FILETOSTR(l_cConfigFpwFile)
          l_nCFLines = ALINES(l_aCFLines,l_cConfigFpwText)
          l_cConfigFpwTextNew = ""
          FOR i = 1 TO l_nCFLines
               l_cCFLine = l_aCFLines(i)
               l_cParameter = ALLTRIM(LOWER(GETWORDNUM(l_cCFLine,1,"=")))
               IF l_cParameter == "codepage"
                    IF l_lChanged
                         * Remove duplicate codepage entries
                         l_cCFLine = ""
                    ELSE
                         l_cCFValue = ALLTRIM(GETWORDNUM(l_cCFLine,2,"="))
                         IF l_cCFValue <> l_cCodePage
                              l_cCFLine = "CodePage="+l_cCodePage
                              l_lChanged = .T.
                         ENDIF
                    ENDIF
               ENDIF
               l_cConfigFpwTextNew = l_cConfigFpwTextNew + l_cCFLine + CHR(13) + CHR(10)
          ENDFOR
          IF l_lChanged
               STRTOFILE(l_cConfigFpwTextNew,l_cConfigFpwFile,0)
               = loGdata("Code page in config.fpw changed to " + l_cCodePage,cuPdatefile)
          ENDIF
     ENDIF
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE CreateBackupFolder
IF EMPTY(p_cBackupFolder)
     p_cBackupFolder = ADDBS(DB_UPDATE_BACKUP_DIR)
     p_cBackupFolder = p_cBackupFolder + ADDBS(FormatVersion(GetDBVersion()))
ENDIF
IF NOT DIRECTORY(p_cBackupFolder)
     = loGdata("Creating folder " + p_cBackupFolder,cuPdatefile)
     MKDIR (p_cBackupFolder)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE DBCheckAfterUpdateFirstStart
LOCAL l_oCa, l_nSelect
l_nSelect = SELECT()
l_oCa = NEWOBJECT("caparam2","progs\cadefdesk.prg")
l_oCa.ldontfill = .F.
l_oCa.CursorFill()
IF NOT EMPTY(caparam2.pa_updatef)
     IF DBAfterUpdateFirstStart()
          REPLACE caparam2.pa_updatef WITH "" IN caparam2
          * l_oCa.DoTableUpdate(.F.,.T.) Dont working yet, no transaction object
          TRY
               SELECT caparam2
               TABLEUPDATE(.T.,.T.)
          CATCH
          ENDTRY
     ENDIF
ENDIF
l_oCa.dclose()
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE DBAfterUpdateFirstStart
LOCAL i
WAIT WINDOW NOWAIT 'Finishing update...'
IF FormatVersion(ALLTRIM(_screen.oGlobal.oParam2.pa_updatef)) >= FormatVersion("9.7.43")
     * From version 9.7.43 is new refox used, which allows exe to be renamed, when this exe is running.
     * So after update, we have new exe instead of old one, and now we can delete another exe's.
     FOR i = 1 TO ADIR(l_aCitadelExeFiles, "citadel*.exe")
          IF NOT ALLTRIM(LOWER(l_aCitadelExeFiles(i,1))) == APP_EXE_NAME AND ISDIGIT(SUBSTR(l_aCitadelExeFiles(i,1),8,1))
               DELETE FILE (l_aCitadelExeFiles(i,1))
          ENDIF
     ENDFOR
ENDIF
WAIT CLEAR
RETURN .T.
ENDPROC