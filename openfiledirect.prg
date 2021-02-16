*PROCEDURE openfiledirect
LPARAMETERS lp_lExclusive, lp_cTable, lp_cAlias, lp_cPath, lp_lForceDBF, lp_oDataEnv, lp_oCursorAdapter
LOCAL l_cMode, l_cAlias, l_lOpenOK, l_oErr, i, l_nStackCount, l_cCallStack, l_cProgram, l_cErrorText

IF Odbc() AND NOT lp_lForceDBF AND NOT _screen.oGlobal.oGData.UseTablesVfp(lp_cTable)
     OpenCommonTable(lp_cTable, lp_cAlias, lp_oDataEnv, @lp_oCursorAdapter)
     RETURN .T.
ENDIF
IF PCOUNT()<2
     RETURN .F.
ENDIF
IF EMPTY(lp_cTable)
     RETURN .F.
ENDIF
IF EMPTY(lp_cAlias)
     l_cAlias = ""
     lp_cAlias = lp_cTable
ELSE
     l_cAlias = " ALIAS " + lp_cAlias
ENDIF
IF EMPTY(lp_cPath)
     lp_cPath = gcDatadir
ELSE
     lp_cPath = ADDBS(lp_cPath)
ENDIF
IF lp_lExclusive OR ;
          UPPER(ALLTRIM(lp_cTable)) == "LICENSE" AND _screen.oGlobal.lblockusers
     l_cMode = "EXCLUSIVE"
ELSE
     l_cMode = "SHARED"
ENDIF
l_lOpenOK = .F.
IF USED(lp_cAlias)
     DO CASE
          CASE NOT JUSTPATH(DBF(lp_cAlias)) == JUSTPATH(FULLPATH(lp_cPath))
               closefile(lp_cAlias)
          CASE l_cMode = "SHARED"
               IF NOT ISEXCLUSIVE(lp_cAlias)
                    l_lOpenOK = .T.
               ELSE
                    closefile(lp_cAlias)
               ENDIF
          CASE l_cMode = "EXCLUSIVE"
               IF ISEXCLUSIVE(lp_cAlias)
                    l_lOpenOK = .T.
               ELSE
                    closefile(lp_cAlias)
               ENDIF
     ENDCASE
ENDIF

IF NOT l_lOpenOK
     FOR i = 1 TO 2
          l_lRetry = .F.
          l_oErr = .NULL.
          TRY
               USE (lp_cPath+lp_cTable) &l_cMode IN 0 &l_cAlias AGAIN
          CATCH TO l_oErr
          ENDTRY
          IF TYPE("l_oErr.ErrorNo") = "N"

               l_nStackCount = 1
               l_cCallStack = ""
               l_cProgram = PROGRAM()
               DO WHILE PROGRAM(l_nStackCount) <> l_cProgram
                    l_cCallStack = l_cCallStack + PROGRAM(l_nStackCount) + " "
                    l_nStackCount = l_nStackCount + 1
               ENDDO

               l_cErrorText = FNGetErrorHeader()+;
                                "Error: "+LTRIM(STR(l_oErr.ErrorNo))+CHR(10)+ ;
                                "Message: "+l_oErr.Message+CHR(10)+"Procedure: "+ ;
                                l_cProgram+CHR(10)+"Called from: "+ ;
                                l_cCallStack+CHR(10)+"Line: "+ ;
                                LTRIM(STR(l_oErr.LineNo))+CHR(10)+"Code: "+l_oErr.Details+CHR(10)

              = loGdata(l_cErrorText, "hotel.err")

               IF l_oErr.ErrorNo = 1104 OR l_oErr.ErrorNo = 1103
                    IF _screen.oGlobal.lexitwhennetworksharelost
                         MESSAGEBOX("Lost connection to database. Application would exit now!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Time: " +TTOC(DATETIME()),48,"Citadel Desk",30000)
                         ExitProcess()
                    ENDIF
               ENDIF
               IF l_oErr.ErrorNo = 1707
                    * CDX file was deleted
                    l_lRetry = .T.
               ENDIF
          ENDIF
          IF NOT l_lRetry
               EXIT
          ENDIF
     ENDFOR
ELSE
     SELECT(lp_cAlias)
ENDIF

RETURN USED(lp_cAlias)
ENDPROC