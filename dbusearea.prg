#INCLUDE "include\constdefines.h"
#DEFINE CRLF          CHR(13)+CHR(10)
*
*FUNCTION dbUseArea
 LPARAMETERS lp_cFileName, lp_cAlias, lp_lExclusive, lp_lAgain, lp_nAreaNumber, lp_nBufferMode, lp_lMakeTransacTable
 LOCAL i, l_lSuccess, l_oExepction, l_cCommand, l_lShowError, l_lErrorOccured, l_lMustRepair, l_lRemoteTable, l_cIniFile

 l_lSuccess = .F.
 IF EMPTY(lp_cFileName)
      RETURN l_lSuccess
 ENDIF
 IF EMPTY(lp_cAlias)
      lp_cAlias = lp_cFileName
 ENDIF
 IF EMPTY(lp_nAreaNumber)
      lp_nAreaNumber = 0
 ENDIF
 IF EMPTY(lp_nBufferMode)
      lp_nBufferMode = 0
 ENDIF
 l_lRemoteTable = IIF(TYPE("p_lOFRemoteTable")="L" AND p_lOFRemoteTable,.T.,.F.)
 * create use command macro
 l_cCommand = "USE " + ;
           IIF(lp_lExclusive, "EXCLUSIVE ", "SHARED ") + ;
           sqlcnv(lp_cFileName) + " " + ;
           IIF((lp_lExclusive AND lp_lAgain) OR NOT lp_lExclusive, "AGAIN ", "") + ;
           "ALIAS " + lp_cAlias + " " + ;
           "IN " + sqlcnv(lp_nAreaNumber)
 * process errors localy, when trying to open table
 FOR i = 1 TO 2
      l_oExepction = .NULL.
      TRY
           &l_cCommand
      CATCH TO l_oExepction
      ENDTRY
      IF TYPE("l_oExepction.ErrorNo") <> "N" OR l_oExepction.ErrorNo <> 1707
           * Structural .CDX file is not found. Try to open table again, it should work now.
           * Otherwise don't try any more.
           EXIT
      ENDIF
 ENDFOR

 IF TYPE("l_oExepction.ErrorNo") = "N"
      * here should be added another possible errors
      l_lMustRepair = .T.
      l_lShowError = .T.
      DO CASE
           CASE l_oExepction.ErrorNo = 15
                l_cErrorText = "it is not a table/DBF. (Error 15)"
           CASE l_oExepction.ErrorNo = 41
                l_cErrorText = "the memo file is missing. (Error 41)"
           CASE l_oExepction.ErrorNo = 2091
                l_cErrorText = "table " + JUSTSTEM(lp_cFileName) + " has become corrupted. The table will need to be repaired before using again. (Error 2091)"
           OTHERWISE
                l_lMustRepair = .F.
                l_lShowError = .F.
      ENDCASE
      IF l_lShowError
           l_cErrorText = DTOC(DATE())+"/"+TIME() + " Repair required of " + lp_cAlias + " because " + l_cErrorText + CRLF + l_cCommand + CRLF
           = loGdata(l_cErrorText, "hotel.err")
           alert(l_cErrorText)
      ENDIF
      IF l_lMustRepair AND _screen.oGlobal.lAutoRepairTables AND FILE(_screen.oGlobal.choteldir + "cmrepair.app")
           LOCAL llAutoRepair, lnRiskRecords, lcLogFile, lnSilence, lnRiskRecordsini
           lnRiskRecords = 1000     && store here number of records you are ready to lose in auto-repair mode
           l_cIniFile = FULLPATH(INI_FILE)
           IF FILE(l_cIniFile)
                lnRiskRecordsini = INT(VAL(readini(l_cIniFile, "system","autorepairtablesriskrecords", "1000")))
                IF NOT EMPTY(lnRiskRecordsini)
                     lnRiskRecords = lnRiskRecordsini
                ENDIF
           ENDIF
           llAutoRepair = .T.     && store here .t. if you like to automatically repair bad table
           lcLogFile = _screen.oGlobal.choteldir + "repair.log"          && here you can specify file in which to log all activities of cmrepair.app
           lnSilence = 1          && store here 1 for no interface, no progress messages, see readme.htm for more possibilities

           lcMessage = 'Structure of the table is damaged.;Please first shutdown all other workstations!;Start repairing?'
           IF yesno(m.lcMessage)
                LOCAL l_cConsole, l_cProcedure, l_cClassLib, l_cSetDialog, tcPathName, l_cBackupPathName
                STORE "" TO l_cConsole, l_cProcedure, l_cClassLib, l_cSetDialog
                ASSERT .F. MESSAGE PROGRAM()
                tcPathName = FULLPATH(lp_cFileName)

                IF NOT DIRECTORY(_screen.oGlobal.choteldir + "backup_table_repair")
                     MKDIR (_screen.oGlobal.choteldir + "backup_table_repair")
                ENDIF
                l_cBackupPathName = _screen.oGlobal.choteldir + "backup_table_repair\"+TTOC(DATETIME(),1)
                MKDIR (l_cBackupPathName)
                * Copy table
                COPY FILE (FORCEEXT(tcPathName,"*")) TO (l_cBackupPathName)

                l_cConsole = SET("CONSOLE")
                l_cProcedure = SET("PROCEDURE")
                l_cClassLib = SET("CLASSLIB")
                l_cSetDialog = SET("CPDIALOG")

                ON ERROR *
                SET PROCEDURE TO
                SET CLASSLIB TO
                SET LIBRARY TO

                DO (_screen.oGlobal.choteldir + 'cmrepair.app') WITH tcPathName, llAutoRepair, lnRiskRecords, lcLogFile, lnSilence

                SET CONSOLE &l_cConsole
                SET PROCEDURE TO &l_cProcedure
                SET CLASSLIB TO &l_cClassLib
                SET CPDIALOG &l_cSetDialog

                alert("OK. Now must restart application.")

                CLEAR READ
                ON ERROR *
                = checkwin("cleanup",.T.,.T.,.T.)
                RETURN TO MASTER
           ENDIF
      ENDIF
      * When error occurred, send it to default error handler
      IF l_lRemoteTable
           * Don't close application. Create fake tables as cursor.
           dbuafaketable(JUSTSTEM(lp_cFileName))
      ELSE
           ErrorSys(l_oExepction.ErrorNo, l_oExepction.Message, UPPER(l_oExepction.Procedure), ;
                     l_oExepction.LineNo, l_cCommand)
      ENDIF
 ENDIF
 
 l_lSuccess = USED(lp_cAlias)
 IF l_lSuccess
      IF lp_lMakeTransacTable
           SetTransactable(lp_cAlias)
      ENDIF
      IF BETWEEN(lp_nBufferMode, 2, 5)
           CURSORSETPROP("Buffering", lp_nBufferMode, lp_cAlias)
      ENDIF
 ENDIF
 RETURN l_lSuccess
ENDFUNC
*
PROCEDURE dbuafaketable
LPARAMETERS lp_cTable
LOCAL l_nSelect, cfakename, ctHename, l_cAliasDBF, l_nTagNumber, l_cDescriptionMacro, l_lUniqueMacro, l_cTagExpression, ;
          l_cKeyExpression, l_cDesExpression, l_cUniExpression
IF EMPTY(lp_cTable)
     RETURN .F.
ENDIF
l_nSelect = SELECT()
cdBfname = ALLTRIM(UPPER(lp_cTable))
cfakename = cdBfname+"1"
ctHename = _screen.oGlobal.choteldir+"tmp\"+cfakename

SELECT fd_name, fd_type, fd_len, fd_dec FROM fields WHERE fd_table = PADR(UPPER(cdBfname),8) INTO CURSOR curfieldsfortable1

CREATE CURSOR Struct (fiEld_name C (128), fiEld_type C  ;
        (1), fiEld_len N (3, 0), fiEld_dec N (3, 0),  ;
        fiEld_null L, fiEld_nocp L, fiEld_defa M,  ;
        fiEld_rule M, fiEld_err M, taBle_rule M, taBle_err  ;
        M, taBle_name C (128), inS_trig M, upD_trig M,  ;
        deL_trig M, taBle_cmt M)
COPY TO TMPSTRUC STRUCTURE
USE
USE EXCLUSIVE TMPSTRUC ALIAS stRuct IN 0
SELECT curfieldsfortable1
SCAN ALL
     INSERT INTO Struct (fiEld_name, fiEld_type,  ;
            fiEld_len, fiEld_dec) VALUES (curfieldsfortable1.fd_name,  ;
            curfieldsfortable1.fd_type, curfieldsfortable1.fd_len, curfieldsfortable1.fd_dec)
ENDSCAN
USE
SELECT stRuct
USE
CREATE (ctHename) FROM TMPSTRUC

DELETE FILE TMPSTRUC.DBF
DELETE FILE TMPSTRUC.FPT
 
SELECT * FROM (cfakename) WHERE 0=1 INTO CURSOR (cdBfname) READWRITE
USE IN (cfakename)
l_cAliasDBF = cdBfname
 
SELECT * FROM files WHERE fi_name = PADR(UPPER(cdBfname),8) INTO CURSOR curfilesloc1
IF RECCOUNT()>0

     FOR l_nTagNumber = 1 TO 45
          l_cKeyMacro = "curfilesloc1.fi_key"+LTRIM(STR(l_nTagNumber))
          l_cDescriptionMacro = "curfilesloc1.fi_des"+LTRIM(STR(l_nTagNumber))
          l_lUniqueMacro = "curfilesloc1.fi_uni"+LTRIM(STR(l_nTagNumber))

          IF TYPE(l_cKeyMacro)="C" ; && Check if exists this key field in files table in sole old version
                    AND ( NOT EMPTY(EVALUATE(l_cKeyMacro)))
               l_cTagExpression = "TAG"+LTRIM(STR(l_nTagNumber))
               l_cKeyExpression = ALLTRIM(EVALUATE(l_cKeyMacro))
               l_cDesExpression = EVALUATE(l_cDescriptionMacro)
               l_cUniExpression = EVALUATE(l_lUniqueMacro)
               SELECT (l_cAliasDBF)
               DO CASE
                    CASE (l_cUniExpression)
                         IF (l_cDesExpression)
                              Index On &l_cKeyExpression Tag &l_cTagExpression DESCENDING CANDIDATE
                         ELSE
                              Index On &l_cKeyExpression Tag &l_cTagExpression CANDIDATE
                         ENDIF
                    CASE (l_cDesExpression)
                         Index On &l_cKeyExpression Tag &l_cTagExpression DESCENDING
                    OTHERWISE
                         Index On &l_cKeyExpression Tag &l_cTagExpression
               ENDCASE
          ENDIF
     ENDFOR
ENDIF
USE IN "curfilesloc1"
DELETE FILE (FORCEEXT(cthename,"*"))
SELECT (l_nSelect)
RETURN .T.
ENDPROC