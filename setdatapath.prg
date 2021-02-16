*PROCEDURE SetDataPath
* Called from DataEnvironment.BeforeOpenTables() to correct path to tables

LPARAMETERS lp_oDE AS DataEnvironment, lp_lCreateCAinDE
LOCAL l_oCursor
IF odbc()
     LOCAL l_nObjCount, i, l_cName, l_cAlias, l_cSource, l_nBuffering, l_cOrder, l_cFlag
     l_nObjCount = 0
     FOR EACH l_oCursor IN lp_oDE.Objects
          l_nObjCount = l_nObjCount + 1
     ENDFOR
     FOR i = l_nObjCount TO 1 STEP -1
          l_oCursor = lp_oDE.Objects(i)
          DO CASE
               CASE NOT LOWER(l_oCursor.BaseClass) == "cursor"
               CASE _screen.oGlobal.oGData.IsVfpDataTable(JUSTSTEM(l_oCursor.CursorSource))
                    l_oCursor.CursorSource = gcDatadir+JUSTFNAME(l_oCursor.CursorSource)
               OTHERWISE
                    l_cName = l_oCursor.Name
                    l_cAlias = l_oCursor.Alias
                    l_cSource = JUSTSTEM(l_oCursor.CursorSource)
                    l_nBuffering = l_oCursor.BufferModeOverride
                    l_cOrder = l_oCursor.Order
                    l_cFlag = l_oCursor.Tag
                    lp_oDE.RemoveObject(l_cName)
                    IF lp_lCreateCAinDE
                         IF "R" $ l_cFlag AND _screen.oGlobal.oGData.IsStaticDataTable(l_cSource) AND _screen.oGlobal.oGData.IsStaticTableUsed(l_cSource)
                              StaticTableCopy(l_cSource, l_cAlias, l_cOrder)
                         ELSE
                              lp_oDE.AddObject(l_cAlias, "ca"+l_cSource)
                              lp_oDE.&l_cAlias..Alias = l_cAlias
                              lp_oDE.&l_cAlias..BufferModeOverride = IIF(l_nBuffering > 3, 5, 3)
                              lp_oDE.&l_cAlias..cOrder = l_cOrder
                              lp_oDE.&l_cAlias..lCreateIndexes = .T.
                              IF NOT "A" $ l_cFlag
                                   lp_oDE.&l_cAlias..cFilterClause = "0=1"
                              ENDIF
                              lp_oDE.&l_cAlias..lDetach = ("D" $ l_cFlag)
                         ENDIF
                    ENDIF
          ENDCASE
     ENDFOR
ELSE
     FOR EACH l_oCursor IN lp_oDE.Objects
         IF PEMSTATUS(l_oCursor, 'CursorSource',5 ) && Filter relation objects
              IF _screen.oGlobal.MainServerTables(JUSTSTEM(l_oCursor.CursorSource))
                   l_oCursor.CursorSource = ADDBS(_screen.oGlobal.MainServerPathGet())+"data\" + JUSTFNAME(l_oCursor.CursorSource)
              ELSE
                   l_oCursor.CursorSource = gcDatadir+JUSTFNAME(l_oCursor.CursorSource)
              ENDIF
         ENDIF
     ENDFOR
ENDIF
RETURN .T.
ENDPROC