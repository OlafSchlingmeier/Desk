*
PROCEDURE Sql
LPARAMETERS lp_cSql, lp_cCursor, lp_nOldEB, lp_cCmd, lp_lSqlRemote
LOCAL i, l_nArea, l_nRetVal, l_nOldEB, l_cErrorText, l_oDatabaseProp, l_lSuccess, l_lReconnected, l_oExepction

l_lSuccess = .T.

IF g_debug
     LogData(TRANSFORM(DATETIME()) + " | " + winpc() + " | " + IIF(EMPTY(g_userid), "", g_userid) + CHR(13) + CHR(10) + lp_cSql + CHR(13) + CHR(10), "sql.log")
ENDIF

lp_cSql = SqlParse(lp_cSql,.T.,lp_lSqlRemote)
DO CASE
     CASE ISNULL(gcUseDatabase)
          l_lSuccess = .F.
          gcUseDatabase = ""
     CASE NOT EMPTY(gcUseDatabase)
          l_oDatabaseProp = goDatabases.Item(gcUseDatabase)
          gcUseDatabase = ""
          lp_cSql = STREXTRACT(lp_cSql, "", "INTO CURSOR", 1, 2)
          SqlRemote(lp_cCmd, lp_cSql, lp_cCursor, l_oDatabaseProp.cApplication,,@l_lSuccess, l_oDatabaseProp.cServerName, l_oDatabaseProp.nServerPort, l_oDatabaseProp.lEncrypt)
     CASE Odbc()
          * here add dynamic changes of sql statment
          *_cliptext = lp_cSql
          IF EMPTY(lp_cCursor)
               l_nArea = SELECT()
          ENDIF
          FOR i = 1 TO 2
               l_nRetVal = SQLEXEC(_screen.oGlobal.oGData.GetHandle(), lp_cSql, EVL(lp_cCursor,""))

               IF EMPTY(lp_cCursor)
                    DClose("SqlResult")
                    SELECT (l_nArea)
               ENDIF
               IF l_nRetVal < 0
                    l_lSuccess = .F.
                    l_cErrorText = getaerrortext()
                    IF NOT l_lReconnected AND _screen.oGlobal.oGData.Reconnected()
                         l_lReconnected = .T.
                         LOOP
                    ENDIF
                    ASSERT .F. MESSAGE PROGRAM()
                    MESSAGEBOX(l_cErrorText,48,"ODBC Error")
                    LogData(TRANSFORM(DATETIME())+" " + l_cErrorText, "odbc.err")
               ENDIF
               EXIT
          NEXT
     CASE lp_lSqlRemote AND FSqlTryRemote(@l_oDatabaseProp)
          lp_cSql = STREXTRACT(lp_cSql, "", "INTO CURSOR", 1, 2)
          SqlRemote(lp_cCmd, lp_cSql, lp_cCursor, l_oDatabaseProp.cApplication,,@l_lSuccess, l_oDatabaseProp.cServerName, l_oDatabaseProp.nServerPort, l_oDatabaseProp.lEncrypt)
     OTHERWISE
          IF lp_nOldEB
               l_nOldEB = SET("EngineBehavior")
               IF l_nOldEB <> 90
                    SET ENGINEBEHAVIOR 90
               ENDIF
          ENDIF
          TRY
               &lp_cSql
          CATCH TO l_oExepction
               l_lSuccess = .F.
               ASSERT .F. MESSAGE PROGRAM()
          ENDTRY
          IF lp_nOldEB
               IF l_nOldEB <> SET("EngineBehavior")
                    SET ENGINEBEHAVIOR l_nOldEB
               ENDIF
          ENDIF
          IF NOT l_lSuccess
               IF _screen.oGlobal.lSqlCursorErrorIgnore
                    TEXT TO l_cErrorText TEXTMERGE NOSHOW
                    <<TRANSFORM(DATETIME())>> SQL Error
                    -------------------------------------
                    <<lp_cSql>>
                    -------------------------------------
                    ErrorNo:<<TRANSFORM(l_oExepction.ErrorNo)>>
                    Message:<<TRANSFORM(l_oExepction.Message)>>
                    Procedure:<<TRANSFORM(l_oExepction.Procedure)>>
                    LineNo:<<TRANSFORM(l_oExepction.LineNo)>>
                    LineContents:<<TRANSFORM(l_oExepction.LineContents)>>
                    Details:<<TRANSFORM(l_oExepction.Details)>>
                    ENDTEXT
                    LogData(l_cErrorText, "hotel.err")
                    *alert(l_cErrorText)
                    IF l_oExepction.ErrorNo = 1104 OR l_oExepction.ErrorNo = 1103
                         IF _screen.oGlobal.lexitwhennetworksharelost
                              MESSAGEBOX("Lost connection to database. Application would exit now!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Time: " +TTOC(DATETIME()),48,"Citadel Desk",30000)
                              ExitProcess()
                         ENDIF
                    ENDIF
               ELSE
                     ErrorSys(l_oExepction.ErrorNo, l_oExepction.Message, UPPER(l_oExepction.Procedure), ;
                               l_oExepction.LineNo, lp_cSql)
               ENDIF
          ENDIF
ENDCASE

RETURN l_lSuccess
ENDPROC
*
PROCEDURE FSqlTryRemote
LPARAMETERS l_oDatabaseProp
LOCAL l_lSuccess
l_oDatabaseProp = goDatabases.Item("DESK")
l_lSuccess = NOT EMPTY(l_oDatabaseProp.cServerName) AND NOT EMPTY(l_oDatabaseProp.nServerPort)
RETURN l_lSuccess
ENDPROC