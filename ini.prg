* PROCEDURE ini
LPARAMETERS lp_lOpenCommonTables, lp_lOpenMainServerTables, lp_oDE AS DataEnvironment, lp_uMainServerFormOrHotcode, lp_lDontUseTables, lp_lCreateCAinDE
IniSetEnvironment()
IF NOT EMPTY(lp_uMainServerFormOrHotcode) AND _screen.oGlobal.lUseMainServer AND _screen.oGlobal.lMainServerDirectoryAvailable
     _screen.oGlobal.oMultiProper.DataPathChange(lp_uMainServerFormOrHotcode)
ENDIF
SetSystemPoint()
SET REPROCESS TO 15 SECONDS
IF NOT odbc() AND NOT lp_lDontUseTables
     openfiledirect(.F.,"files")
     openfile(.F.,"license")
     openfile(.F.,"param2")
     openfile(.F.,"resaddr",.F.,.F.,5)
     openfile(.F.,"rtypedef")
     openfile(.F.,"roomtype")
     openfile(.F.,"room")
     openfile(.F.,"building")
     openfile(.F.,"logger")
     IF lp_lOpenCommonTables
          openfile(.F.,"param")
          openfile(.F.,"id")
          openfile(.F.,"picklist")
          IF lp_lOpenMainServerTables AND _screen.oGlobal.lUseMainServer
               IF openfile(.F.,"adrmain")
                    = openfile(.F.,"idmain")
                    = openfile(.F.,"hotel")
               ENDIF
          ENDIF
     ENDIF
ENDIF
IF PCOUNT() > 2 AND TYPE("lp_oDE") = "O"
     IF NOT lp_oDE.AutoOpenTables
          setdatapath(lp_oDE, lp_lCreateCAinDE)
          lp_oDE.OpenTables()
     ENDIF
ENDIF
IF Odbc() AND NOT lp_lDontUseTables
     LOCAL i, lCommonTables, lcTable
     *lCommonTables = "param, param2, RESADDR, building, rtypedef, roomtype, room, logger, id, picklist"
     lCommonTables = "param, param2"
     FOR i = 1 TO GETWORDCOUNT(lCommonTables, ",")
          lcTable = ALLTRIM(GETWORDNUM(lCommonTables, i, ","))
          OpenCommonTable(lcTable,,lp_oDE)
     NEXT
ENDIF
IF NOT EMPTY(lp_uMainServerFormOrHotcode) AND _screen.oGlobal.lUseMainServer AND _screen.oGlobal.lMainServerDirectoryAvailable
     _screen.oGlobal.oMultiProper.DataPathRestore()
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE IniSetEnvironment
SET DATE german
SET MARK TO .
SET CENTURY ON
IF _screen.oGlobal.cSetCurrencyPosition = "LEFT"
     SET CURRENCY LEFT
ELSE
     SET CURRENCY RIGHT
ENDIF
SET CURRENCY TO _screen.oGlobal.cSetCurrencySign
SET DECIMALS TO _screen.oGlobal.nSetDecimals
SET HOURS TO _screen.oGlobal.nSetHours
SET SEPARATOR TO _screen.oGlobal.cSetSeparator
SET DELETED ON
SET SAFETY OFF
SET TALK OFF
SET ANSI OFF
SET MULTILOCKS ON
ENDPROC
*
PROCEDURE SetSystemPoint
LOCAL l_cDefaultPoint, l_cCurrentPoint, l_cNewPoint
l_cDefaultPoint = ","
IF TYPE("g_cPoint") = "C" AND NOT EMPTY(g_cPoint)
	l_cDefaultPoint = g_cPoint
ELSE
	l_cDefaultPoint = ","
ENDIF
l_cCurrentPoint = SET("Point")
IF TYPE("_screen.oGlobal.oParam.pa_point") = "C" AND NOT EMPTY(_screen.oGlobal.oParam.pa_point)
	l_cNewPoint = _screen.oGlobal.oParam.pa_point
ELSE
	l_cNewPoint = l_cDefaultPoint
ENDIF
IF l_cCurrentPoint <> l_cNewPoint
	SET POINT TO l_cNewPoint
	IF TYPE("g_cPoint") = "C"
		g_cPoint = l_cNewPoint
	ENDIF
ENDIF
ENDPROC
*