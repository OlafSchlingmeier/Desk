 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
			lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal, l_nPCount

* TEST 

*!*     * Example how to use sqlcursor

*!*     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15

*!*          SELECT TOP 1 as_ratecod ;
*!*               FROM altsplit ;
*!*               INNER JOIN roomtype ON as_roomtyp = rt_roomtyp ;
*!*               WHERE as_altid = <<l_nAltId>> AND ;
*!*               as_date = <<l_dArrDate>> AND ;
*!*               as_roomtyp = <<l_cRoomType>> ;
*!*               ORDER BY 1

*!*     ENDTEXT
*!*     l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)

* How to Calculate How Much VAT Has Cost
* ( 100 / ( 100 + VAT_Rate ) ) * Final_Price = Pre_VAT_Price

* How to Calculate How Much VAT Will Cost
* ( VAT_Rate / 100 ) * Original_Price = Amount_of_VAT_Payable

*STZapAllTables("d:\keza\code\test\desk\webbooking\data\")
*STZapAllTables()
*PrepareTestEnv()
*MetaDataTxt("INTO_TXT")
*MetaDataTxt("INTO_DBF")
 
 l_nPCount = PCOUNT()
 
 IF EMPTY(lp_cFuncName)
 	lp_cFuncName = "MetaDataTxt"
 	lp_uParam1 = "INTO_TXT"
 	l_nPCount = 2
 ENDIF

 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO l_nPCount-1
	l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"
 l_uRetVal = &l_cCallProc
 RETURN l_uRetVal
ENDFUNC

* Various tools
PROCEDURE MetaDataTxt
LPARAMETERS lp_cMode, lp_lDontUpdateLanguage
RELEASE gometadata
PUBLIC gometadata
gometadata = .NULL.
gometadata = CREATEOBJECT("cmetadata")

IF lp_cMode = "INTO_TXT"
     gometadata.CreateMetadataTxt(lp_lDontUpdateLanguage)
     IF NOT "progs" $ LOWER(SET("Path"))
          SET PATH TO "progs" ADDITIVE
     ENDIF
     caclasses()
     COMPILE common/progs/cadefdesk.prg
ELSE
     gometadata.CreateMetadataDbf()
ENDIF
gometadata = .NULL.
RELEASE gometadata
ENDPROC
*
PROCEDURE PrepareTestEnv
SET PATH TO "data"
SET PROCEDURE TO func, main
MainInitPublics()
MainInitLibs()
= openfile()
ENDPROC
*
PROCEDURE STZapAllTables
LPARAMETERS lp_lDataPath
LOCAL l_oError AS Exception
IF EMPTY(lp_lDataPath)
	lp_lDataPath = "data\"
ENDIF
lp_lDataPath = ADDBS(lp_lDataPath)
* Delete all transact tabled
SET SAFETY OFF
l_cTableList = ;
     ['action','althead','altsplit','astat','arpost','availab','banquet','billinst',]+;
     ['billnum','deposit','document','eattachm','einbox','einboxsn','esent',]+;
     ['esentrcp','exterror','extreser','grid','gridprop','groupres','hbanquet',]+;
     ['hbillins','hdeposit','histors','histpost','histres','histstat','houtofor',]+;
     ['houtofsr','hpostcng','hresaddr','hrescard','hresext','hresfix','hresrate',]+;
     ['hresroom','hsheet','hpostifc','resifcbr','rpostifc',]+;
     ['ifclost','jetweb','laststay','ledgpaym','ledgpost',]+;
     ['logger','manager','mngbuild','orstat','outdebts','outoford','outofser',]+;
     ['post','postchng','postcxl','resaddr','rescard','reservat','resfix',]+;
     ['respict','resrate','resrmshr','resrooms','roomplan','sharing','sheet',]+;
     ['voucher','wakeup','workbrk','workint','ressplit','elpay','hresplit',]+;
     ['resrart','hresrart','rsifsync','hpwindow','pswindow','screens','import',]+;
     ['pichk','piart','pipay']
FOR i = 1 TO GETWORDCOUNT(l_cTableList,",")
     l_cTable = GETWORDNUM(l_cTableList,i,",")
     TRY
          USE (lp_lDataPath+&l_cTable) EXCLUSIVE IN 0
          ZAP IN &l_cTable
          USE IN &l_cTable
     CATCH TO l_oError
          MESSAGEBOX(l_oError.Message)
     ENDTRY
ENDFOR
ENDPROC
*
PROCEDURE STZAPAllTablesFromFiles
* deletes all filed in data folder, which are not tables.
* ZAP on all tables!
SET SAFETY OFF
CLOSE TABLES ALL
USE data\files SHARED IN 0
SET ORDER TO TAG1
ADIR(l_aDir,"data\*.*")
FOR i = 1 TO ALEN(l_aDir,1)
	l_lOK = .F.
	l_cFile = UPPER(l_aDir(i,1))
	l_cExtWP = RIGHT(l_cFile,4)
	IF INLIST(l_cExtWP,".DBF",".CDX",".FPT")
		l_cTable = GETWORDNUM(l_cFile,1,".")
		IF INLIST(l_cTable, "FILES", "FIELDS")
			l_lOK = .T.
		ELSE
			IF SEEK(l_cTable,"files")
				l_lOK = .T.
				IF l_cExtWP == ".DBF"
					USE ("data\"+l_cTable) EXCLUSIVE IN 0
					ZAP IN &l_cTable
					USE IN &l_cTable
				ENDIF
			ENDIF
		ENDIF
	ENDIF
	IF NOT l_lOK
		DELETE FILE ("data\"+l_cFile)
	ENDIF
ENDFOR
RETURN .T.
ENDPROC
*
PROCEDURE STDeleteSvnFolders

ENDPROC
*
PROCEDURE STDeleteNotUsedTableFilesFromDataFolder
LPARAMETERS lp_cDataPath
LOCAL l_cDir, l_nFiles, l_nFiles, l_lDelete, l_cFile, l_cFileWithoutExt, l_cTable

IF EMPTY(lp_cDataPath)
	lp_cDataPath = ADDBS(SYS(5)+SYS(2003))+"data"
ENDIF

l_cDir = lp_cDataPath

IF NOT USED("files")
	USE (ADDBS(l_cDir) + "files") IN 0 SHARED AGAIN
ENDIF

l_nFiles = ADIR(l_aDir, l_cDir + "\*.dbf")
FOR i = 1 TO l_nFiles
	l_lDelete = .F.
	l_cFile = UPPER(l_aDir(i,1))
	l_cFileWithoutExt = FORCEEXT(l_cFile,"")
	l_cTable = PADR(JUSTSTEM(l_cFile),8)
	IF INLIST(l_cTable, "FILES   ", "FIELDS  ")
		LOOP
	ENDIF
	IF LEN(l_cFileWithoutExt)>8
		l_lDelete = .T.
	ENDIF
	IF NOT l_lDelete
		SELECT files
		LOCATE FOR fi_name == l_cTable
		IF NOT FOUND()
			l_lDelete = .T.
		ENDIF
	ENDIF
	IF l_lDelete
		DELETE FILE (l_cDir + "\" + ALLTRIM(l_cFileWithoutExt) + ".*")
	ENDIF
ENDFOR
ENDPROC
*
PROCEDURE CopyReservatToHistory
 LPARAMETERS lp_nreserid
 SELECT rs_reserid FROM reservat WHERE INT(rs_reserid)=INT(lp_nreserid) ORDER BY 1 INTO CURSOR cur1
 SCAN ALL
      SELECT reServat
      =SEEK(cur1.rs_reserid, "reservat", "tag1")
      SELECT hiStres
      DO FromResToHist IN ProcReservat WITH reservat.rs_reserid
      lcReplaceClause = GetReplaceClauseForSimilarFields("post", "histpost", .T.)
      SELECT poSt
      SCAN ALL FOR poSt.ps_reserid=cur1.rs_reserid
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
           DO FromPostchangesToHist IN ProcReservat WITH post.ps_postid
           SELECT poSt
           REPLACE poSt.ps_touched WITH .F.
           FLUSH
      ENDSCAN
      SELECT cur1
 ENDSCAN
ENDPROC
*
PROCEDURE ReleaseScx
LPARAMETERS lp_cFormName
LOCAL l_cFormName, l_cRealFormName, l_oForm
DO CASE
     CASE LOWER(lp_cFormName) = "reservat.scx"
          l_cFormName = "reservat"
          l_cRealFormName = "tform12"
     CASE LOWER(lp_cFormName) = "addressmask.scx"
          l_cFormName = "addressmask"
          l_cRealFormName = "faddressmask"
     CASE LOWER(lp_cFormName) = "bills.scx"
          l_cFormName = "frmbills"
          l_cRealFormName = "frmbills"
     OTHERWISE
     
ENDCASE
IF NOT EMPTY(l_cFormName)
     FOR EACH l_oForm IN _screen.Forms
          IF TYPE("l_oForm.formname")="C" AND LOWER(l_oForm.Name) = l_cRealFormName AND LOWER(l_oForm.formname) = l_cFormName
               l_oForm.lcloseonfinish = .T.
               l_oForm.Parent.MainExitPoint()
               ? "OK"
               EXIT
          ENDIF
     ENDFOR
ENDIF

RETURN .T.
ENDPROC
*
DEFINE CLASS cmetadata AS Custom
#IF .F. && Make sure this is false, otherwise error
   *-- Define This for IntelliSense use
   LOCAL This AS cmetadata OF aaa_dev_tools.prg
#ENDIF
cProjectDir = ""
*
PROCEDURE Init
this.cProjectDir = application.ActiveProject.HomeDir
SET DEFAULT TO (this.cProjectDir)
IF NOT "FUNC" $ UPPER(SET("Procedure"))
     SET PROCEDURE TO progs\func ADDITIVE
ENDIF
SET SAFETY OFF
ENDPROC
*
PROCEDURE CreateMetadataTxt
LPARAMETERS lp_lDontUpdateLanguage
* Creates txt files in metadata folder, from tables in data folder
this.WriteMetaDataTxtFromTable("files")
this.WriteMetaDataTxtFromTable("fields")
IF NOT lp_lDontUpdateLanguage
     this.WriteMetaDataTxtFromTable("language",.T.,.T.,"la_prg+la_label+la_lang",.T.)	&& Creates from UpdLang
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE WriteMetaDataTxtFromTable
LPARAMETERS lp_cTable, lp_lXML, lp_lNoCursorAlias, lp_cOrder, lp_lNoOrder
LOCAL l_cCursor, l_cTablePath, l_cTextFile, l_cTextFilePath, l_nSelect, l_cXML, l_cIndexFile

l_cTablePath = ADDBS(this.cProjectDir) + "data\"
l_cTextFilePath = ADDBS(this.cProjectDir) + "metadata\"
l_nSelect = SELECT()
IF lp_lNoCursorAlias
     l_cCursor = lp_cTable
     IF USED(lp_cTable)
          dclose(lp_cTable)
     ENDIF
ELSE
     l_cCursor = SYS(2015)
ENDIF
USE (l_cTablePath+lp_cTable) SHARED IN 0 AGAIN ALIAS (l_cCursor)
SELECT (l_cCursor)
DO CASE
     CASE lp_lNoOrder
     CASE NOT EMPTY(lp_cOrder)
          l_cIndexFile = SYS(2015)
          INDEX ON &lp_cOrder TAG savetag OF (l_cIndexFile)
     OTHERWISE
          SET ORDER TO 1
ENDCASE
IF lp_lXML
     CURSORTOXML(l_cCursor,"l_cXML",3,32+2+4,0,"1")
     STRTOFILE(STRCONV(l_cXML,9), l_cTextFilePath+lp_cTable+".xml")
ELSE
     COPY TO (l_cTextFilePath+lp_cTable) DELIMITED WITH ~ WITH TAB
ENDIF
USE IN (l_cCursor)
IF NOT EMPTY(l_cIndexFile)
     filedelete(FORCEEXT(l_cIndexFile,"cdx"))
ENDIF
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE CreateMetadataDbf
* Creates dbf files in data folder, from text files in metadata folder
 WAIT "Updating metadata..." WINDOW NOWAIT
 * Files.txt
 IF FILE("Metadata\Files.def") AND FILE("Metadata\Files.txt")
      this.CheckStructure("Metadata\Files.def")
      USE data\Files IN 0 EXCLUSIVE
      SELECT Files
      INDEX ON fi_name TAG Tag1
      INDEX ON UPPER(fi_alias) TAG Tag2
      INDEX ON fi_group TAG Tag3
      SET ORDER TO Tag1
      APPEND FROM Metadata\Files.txt DELIMITED WITH ~ WITH TAB
      USE IN Files
 ENDIF

 * Fields.txt
 IF FILE("Metadata\Fields.def") AND FILE("Metadata\Fields.txt")
      this.CheckStructure("Metadata\Fields.def")
      USE data\Fields IN 0 EXCLUSIVE
      SELECT Fields
      INDEX ON UPPER(fd_table+fd_name) TAG Fields
      SET ORDER TO Fields
      APPEND FROM Metadata\Fields.txt DELIMITED WITH ~ WITH TAB
      USE IN Fields
 ENDIF

 * language.txt
*	 IF FILE("Metadata\language.def") AND FILE("Metadata\language.xml")	&& language.dbf not need to update any more
*	      IF USED("language")
*	           USE IN language
*	      ENDIF
*	      this.CheckStructure("Metadata\language.def")
*	      USE data\language IN 0 EXCLUSIVE
*	      SELECT language
*	      XMLTOCURSOR("Metadata\language.xml","curlanguage",512)
*	      SELECT language
*	      APPEND FROM DBF("curlanguage")
*	      INDEX ON UPPER(la_lang+la_prg+la_label) TAG TAG1
*	      SET ORDER TO TAG1
*	      USE IN language
*	      USE IN curlanguage
*	 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE CheckStructure
LPARAMETERS lp_cDefFile
LOCAL l_cAlias, l_cTablePath, l_cTmpStruct

l_cAlias = JUSTSTEM(lp_cDefFile)

l_cTablePath = ADDBS(this.cProjectDir) + "data\" + l_cAlias
FileDelete(FORCEEXT(l_cTablePath, "dbf"))
FileDelete(FORCEEXT(l_cTablePath, "cdx"))
FileDelete(FORCEEXT(l_cTablePath, "fpt"))


CREATE CURSOR curStruct (Field Numeric(7), Name Character(16), Type Character(15), Width Numeric(10), Dec Numeric(7))
APPEND FROM &lp_cDefFile TYPE SDF
REPLACE Type WITH "W" FOR Field > 0 AND Type = PADR("Blob",16) IN curStruct
REPLACE Type WITH "Y" FOR Field > 0 AND Type = PADR("Currency",16) IN curStruct
REPLACE Type WITH "T" FOR Field > 0 AND Type = PADR("DateTime",16) IN curStruct
REPLACE Type WITH "B" FOR Field > 0 AND Type = PADR("Double",16) IN curStruct
REPLACE Type WITH "Q" FOR Field > 0 AND Type = PADR("Varbinary",16) IN curStruct

l_cTmpStruct = Filetemp('DBF')
COPY STRUCTURE EXTENDED TO &l_cTmpStruct
USE (l_cTmpStruct) IN 0 ALIAS Struct EXCLUSIVE
ZAP IN Struct
INSERT INTO Struct (field_name, field_type, field_len, field_dec) SELECT Name, Type, Width, Dec FROM curStruct WHERE Field > 0
USE IN Struct
USE IN curStruct

SELECT 0
CREATE (l_cTablePath) FROM (l_cTmpStruct)
USE IN (l_cAlias)

FileDelete(FORCEEXT(l_cTmpStruct,'dbf'))
FileDelete(FORCEEXT(l_cTmpStruct,'fpt'))
RETURN .T.
ENDPROC
*
ENDDEFINE
*