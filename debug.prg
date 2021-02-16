 FUNCTION debug
 LOCAL _message
 IF opEnfile(.F.,"Param",.F.,.T.)
 	IF param.pa_debug
 		replace pa_debug WITH .F. in param
 		_message = "Debug mode is OFF."
 		g_debug = .f.
 	ELSE
 		replace pa_debug WITH .T. in param
 		_message = "Debug mode is ON."
 		g_debug = .t.
 	ENDIF
 	FLUSH
 	MESSAGEBOX( _message,  48, GetLangText("RESERV2","TW_INFO"))
 ENDIF
 RETURN .t.
 ENDFUNC 
 *
 FUNCTION ERROR 
 LOCAL _message
 IF opEnfile(.F.,"Param",.F.,.T.)
 	IF param.pa_error 
 		replace pa_error WITH .F. in param
 		_message = "Expanded Error Handler is OFF."
 		g_myerrorhandle = .f.
 	ELSE
 		replace pa_error WITH .T. in param
 		_message = "Expanded Error Handler mode is ON."
 		g_myerrorhandle = .t.
 	ENDIF
 	FLUSH
 	MESSAGEBOX( _message,  48, GetLangText("RESERV2","TW_INFO"))
 ENDIF
 RETURN .T.
 ENDFUNC
 *
 FUNCTION SETGRID
 _screen.oGlobal.GridScreen_RestoreDefaults()
 RETURN 
 ENDFUNC
*
FUNCTION UPDATETABLES
	IF MESSAGEBOX(GetLangText("COMMON", "TXT_PROCEED_UPDTBL"),260,GetLangText("FUNC","TXT_QUESTION"))=6	
		chEckwin("updtbl",.t.)
	ENDIF
	RETURN .t.
ENDFUNC
*
FUNCTION UPDATELANG
	IF MESSAGEBOX(GetLangText("COMMON", "TXT_PROCEED_UPDLANG"),260,GetLangText("FUNC","TXT_QUESTION"))=6	
		chEckwin("updlang",.t.)
	ENDIF
	RETURN .t.
ENDFUNC
*
FUNCTION UPDATELISTS
     Alert("Not used anymore!")
	RETURN .t.
ENDFUNC
*
PROCEDURE DebugBlockAllUsers
LPARAMETERS lp_lBlock, lp_lSilent
LOCAL l_lSuccess, l_cMsg, l_lOldVal
IF PCOUNT()=0
     lp_lBlock = NOT _screen.oGlobal.lblockusers
ENDIF
l_lOldVal = _screen.oGlobal.lblockusers
_screen.oGlobal.lblockusers = lp_lBlock
l_lSuccess = openfile(.F.,"license")
IF l_lSuccess
     IF PEMSTATUS(_Screen,"StatusBar", 5)
          _screen.oGlobal.oStatusBar.SetUserBlocked()
     ENDIF
ELSE
     _screen.oGlobal.lblockusers = l_lOldVal
ENDIF
IF _screen.oGlobal.lblockusers
     l_cMsg = GetLangText("CONFPLAN", "T_BLOCK") + ": " + GetLangText("COMMON", "TXT_YES")
ELSE
     l_cMsg = GetLangText("CONFPLAN", "T_BLOCK") + ": " + GetLangText("COMMON", "TXT_NO")
ENDIF
IF NOT lp_lSilent
     alert(l_cMsg)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE testserver
LOCAL l_oDatabaseProp, l_cServerPc, l_lSuccess, l_cMsg, l_nSelect, l_cDateTime, l_cHotelName, l_lWinsockError, l_lDeskAsCom
l_nSelect = SELECT()
l_oDatabaseProp = goDatabases.Item("DESK")
l_cServerPc = LOWER(ALLTRIM(l_oDatabaseProp.cServerName))
l_cDateTime = ""
l_cHotelName = ""

WAIT WINDOW "Connecting to " + l_cServerPc + " on port " + TRANSFORM(l_oDatabaseProp.nServerPort) TIMEOUT 2

l_cDateTime = sqlremote("EVAL","DATETIME()",,l_oDatabaseProp.cApplication,,@l_lSuccess, l_oDatabaseProp.cServerName, l_oDatabaseProp.nServerPort, l_oDatabaseProp.lEncrypt)
IF l_lSuccess
     = sqlremote("SQLCURSOR","SELECT pa_hotel FROM param","ctestx6b",l_oDatabaseProp.cApplication,,@l_lSuccess, l_oDatabaseProp.cServerName, l_oDatabaseProp.nServerPort, l_oDatabaseProp.lEncrypt)
     l_lSuccess = USED("ctestx6b")
     IF l_lSuccess
          l_cHotelName = ALLTRIM(ctestx6b.pa_hotel)
          dclose("ctestx6b")
          = sqlremote("DESKCOMTEST",,,l_oDatabaseProp.cApplication,,@l_lSuccess, l_oDatabaseProp.cServerName, l_oDatabaseProp.nServerPort, l_oDatabaseProp.lEncrypt)
          IF l_lSuccess
               l_lDeskAsCom = .T.
          ENDIF
     ENDIF
ELSE
     IF NOT (TYPE("g_oSqlRemote.ocntws") = "O" AND NOT ISNULL(g_oSqlRemote.ocntws))
          l_lWinsockError = .T.
     ENDIF
ENDIF
TEXT TO l_cMsg TEXTMERGE NOSHOW PRETEXT 3
-----------------------------------
Connection settings in citadel.ini:
-----------------------------------
Server: <<l_cServerPc>>
port: <<TRANSFORM(TRANSFORM(l_oDatabaseProp.nServerPort))>>
Encrypted: <<IIF(l_oDatabaseProp.lEncrypt,"yes","no")>>
-----------------------------------
Test results:
-----------------------------------
mswinsck.ocx <<IIF(l_lWinsockError,"failed","is OK")>>
TCP connection <<IIF(EMPTY(l_cDateTime),"failed","is OK")>> (Time on server: <<l_cDateTime>> )
Database connection <<IIF(EMPTY(l_cHotelName),"failed","is OK")>> (param.pa_hotel: <<l_cHotelName>>)
citadel.exe as COM Server <<IIF(NOT l_lDeskAsCom,"failed","is OK")>>
ENDTEXT
alert(l_cMsg)
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*