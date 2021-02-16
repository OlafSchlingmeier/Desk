*PROCEDURE ccopyandzip
LPARAMETERS lp_cSrcFolder, lp_cDestFolder, lp_cZipName, lp_cExceptionFiles
LOCAL l_oCZ AS clsCopyAndZip OF ccopyandzip.prg, l_lSuccess

IF EMPTY(lp_cSrcFolder) OR EMPTY(lp_cDestFolder)
     RETURN l_lSuccess
ENDIF
IF EMPTY(lp_cZipName)
     lp_cZipName = DTOS(DATE()) + ".zip"
ENDIF
l_oCZ = CREATEOBJECT("clsCopyAndZip")
l_lSuccess = l_oCZ.Start(lp_cSrcFolder, lp_cDestFolder, lp_cZipName, lp_cExceptionFiles)
RETURN l_lSuccess
ENDPROC
*
*
* Dummy functions, to prevent building errors
*
FUNCTION ZIPOPEN
ENDFUNC
*
FUNCTION ZIPFILE
ENDFUNC
*
FUNCTION ZIPCLOSE
ENDFUNC
*
DEFINE CLASS clsCopyAndZip AS Custom
oShell = .NULL.
cTmpFileDir = ""
cSrcFolder = ""
cDestFolder = ""
cZipName = ""
cTempShellRunFile = "shellrun.txt"
cExceptionFilesCur = ""
nSelect = 0
*
PROCEDURE Start
LPARAMETERS lp_cSrcFolder, lp_cDestFolder, lp_cZipName, lp_cExceptionFiles
LOCAL l_lSuccess
this.cSrcFolder = ADDBS(lp_cSrcFolder)
this.cDestFolder = ADDBS(lp_cDestFolder)
this.cZipName = lp_cZipName
IF NOT EMPTY(lp_cExceptionFiles)
     this.CreateExceptionFilesCur(lp_cExceptionFiles)
ENDIF
IF this.Prepare()
     IF NOT this.ZIPExists()
          IF this.CreateTmpFolder()
               this.CopyTables()
               this.ZipTables()
               this.CopyToDestionation()
               this.CleanUp()
               l_lSuccess = .T.
          ENDIF
     ENDIF
ENDIF

this.DeleteExceptionFilesCur()

RETURN l_lSuccess
ENDPROC
*
PROCEDURE CreateExceptionFilesCur
LPARAMETERS lp_cExceptionFiles
LOCAL i, l_cFile
this.nSelect = SELECT()
this.cExceptionFilesCur = SYS(2015)
CREATE CURSOR (this.cExceptionFilesCur) (c_file C(254))
FOR i = 1 TO GETWORDCOUNT(lp_cExceptionFiles,"|")
     l_cFile = UPPER(ALLTRIM(GETWORDNUM(lp_cExceptionFiles,i,"|")))
     IF NOT EMPTY(l_cFile)
          INSERT INTO (this.cExceptionFilesCur) (c_file) VALUES (l_cFile)
     ENDIF
ENDFOR
RETURN .T.
ENDPROC
*
PROCEDURE InExceptionFilesCur
LPARAMETERS lp_cFile
LOCAL l_lFound, l_nSelect, l_cFileToCheck
IF EMPTY(this.cExceptionFilesCur) OR EMPTY(lp_cFile)
     RETURN l_lFound
ENDIF
l_nSelect = SELECT()

l_cFileToCheck = PADR(UPPER(ALLTRIM(lp_cFile)),254)

SELECT (this.cExceptionFilesCur)
LOCATE FOR c_file = l_cFileToCheck
IF FOUND()
     SET STEP ON
     l_lFound = .T.
ENDIF

SELECT (l_nSelect)
RETURN l_lFound
ENDPROC
*
PROCEDURE DeleteExceptionFilesCur
IF NOT EMPTY(this.cExceptionFilesCur) AND USED(this.cExceptionFilesCur)
     USE IN (this.cExceptionFilesCur)
     SELECT (this.nSelect)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE Prepare
LOCAL l_cVfpComp, l_lSuccess, i, l_lFoundDll
LOCAL ARRAY l_aDlls(1)
l_lSuccess = .T.
* Check FLL and DLL
IF NOT "vfpcompression.fll" $ SET("Library")
     IF FILE("vfpcompression.fll")
          l_cVfpComp = LOCFILE("vfpcompression.fll")
     ELSE
          IF FILE("common\dll\vfpcompression.fll")
               l_cVfpComp = LOCFILE("common\dll\vfpcompression.fll")
          ENDIF
     ENDIF
     IF EMPTY(l_cVfpComp)
          l_lSuccess = .F.
          MESSAGEBOX("Missing file vfpcompression.fll!",16,"Backup")
          RETURN l_lSuccess
     ENDIF
     SET LIBRARY TO (l_cVfpComp) ADDITIVE
ENDIF

IF ADLLS(l_aDlls)>0
     FOR i = 1 TO ALEN(l_aDlls,1)
          IF LOWER(ALLTRIM(l_aDlls(i,1))) == "copyfile"
               l_lFoundDll = .T.
          ENDIF
          EXIT
     ENDFOR
ENDIF
IF NOT l_lFoundDll
     DECLARE INTEGER CopyFile IN kernel32;
         STRING  lpExistingFileName,;
         STRING  lpNewFileName,;
         INTEGER bFailIfExists
ENDIF
this.oShell = CREATEOBJECT("Wscript.Shell")
RETURN l_lSuccess
ENDPROC
*
PROCEDURE ZIPExists
LOCAL l_cFullPath
l_cFullPath = this.cDestFolder + this.cZipName
IF FILE(l_cFullPath)
     RETURN .T.
ELSE
     RETURN .F.
ENDIF
ENDPROC
*
PROCEDURE CreateTmpFolder
LOCAL l_lSuccess
this.cTmpFileDir = ADDBS(ADDBS(SYS(2023))+TTOC(DATETIME(),1)+SYS(2015))
MKDIR (this.cTmpFileDir)
l_lSuccess = DIRECTORY(this.cTmpFileDir)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE CopyTables
LOCAL i, l_cSrcFile, l_cDestFile
LOCAL ARRAY l_aFiles(1)
IF ADIR(l_aFiles, this.cSrcFolder + "*.*")>0
     FOR i = 1 TO ALEN(l_aFiles, 1)
          IF NOT this.InExceptionFilesCur(l_aFiles(i,1))
               l_cSrcFile = LOWER(this.cSrcFolder + l_aFiles(i,1))
               l_cDestFile = LOWER(this.cTmpFileDir + l_aFiles(i,1))
               CopyFile(l_cSrcFile, l_cDestFile, 0)
          ENDIF
     ENDFOR
ENDIF
ENDPROC
*
PROCEDURE ZipTables
LOCAL i, l_cFile
LOCAL ARRAY l_aFiles(1)
IF ADIR(l_aFiles, this.cTmpFileDir + "*.*")>0
     ZipOpen(this.cZipName, this.cTmpFileDir, .F.)
     FOR i = 1 TO ALEN(l_aFiles, 1)
          l_cFile = LOWER(this.cTmpFileDir + l_aFiles(i,1))
          ZipFile(l_cFile, .F.)
     ENDFOR
     ZipClose()
ENDIF
ENDPROC
*
PROCEDURE CopyToDestionation
LOCAL l_cSrcFile, l_cDestFile
l_cSrcFile = this.cTmpFileDir + this.cZipName
l_cDestFile = this.cDestFolder + this.cZipName
IF FILE(l_cSrcFile)
     CopyFile(l_cSrcFile, l_cDestFile, 0)
ENDIF
ENDPROC
*
PROCEDURE CleanUp
LOCAL l_cCommand
l_cCommand = "%comspec% /c rmdir /s /q " + this.cTmpFileDir
this.ExecCommand(l_cCommand)
RETURN .T.
ENDPROC
*
PROCEDURE ExecCommand
LPARAMETERS pcCommand
LOCAL l_cOutPut
l_cOutPut = ""

IF EMPTY(pcCommand)
     RETURN l_cOutPut
ENDIF

l_oRunScript = this.oShell.Run([%COMSPEC% /C ] + pcCommand + [  > ] + this.cTempShellRunFile, 0, .T.)
IF FILE(this.cTempShellRunFile)
     l_cOutPut = FILETOSTR(this.cTempShellRunFile)
ENDIF
DELETE FILE (this.cTempShellRunFile)
RETURN l_cOutPut
ENDPROC
*
ENDDEFINE