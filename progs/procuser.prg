#INCLUDE "include\constdefines.h"
*
LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
              lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13
LOCAL l_cCallProc, l_nParamNo, l_uRetVal
l_cCallProc = lp_cFuncName + "("
FOR l_nParamNo = 1 TO PCOUNT()-1
     l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
NEXT
l_cCallProc = l_cCallProc + ")"
l_uRetVal = &l_cCallProc
RETURN l_uRetVal
ENDPROC

* Add here code related with user settings
*
PROCEDURE UserFavInsert
LPARAMETERS lp_cUserId, lp_cMenu, lp_cMenuKey
LOCAL l_oCa, l_nSelect

l_nSelect = SELECT()

l_oCa = CREATEOBJECT("causerfav")
l_oCa.lDontFill = .T.
l_oCa.CursorFill()
INSERT INTO causerfav (uf_userid, uf_menu, uf_menukey) VALUES (lp_cUserId, lp_cMenu, lp_cMenuKey)
l_oCa.DoTableUpdate()
l_oCa.dclose()

SELECT (l_nSelect)
ENDPROC
*
PROCEDURE UserFavDelete
LPARAMETERS lp_cUserId, lp_cMenu, lp_cMenuKey
sqldelete("userfav", ;
          "uf_userid = " + sqlcnv(PADR(lp_cUserId,10),.T.) + ;
          " AND uf_menu = " + sqlcnv(PADR(lp_cMenu,20),.T.) + ;
          " AND uf_menukey = " + sqlcnv(PADR(lp_cMenuKey,20),.T.) ;
          )
RETURN .T.

LOCAL l_oCa, l_nSelect
l_nSelect = SELECT()
l_oCa = CREATEOBJECT("causerfav")
l_oCa.cfilterclause = "uf_userid = " + sqlcnv(PADR(lp_cUserId,10),.T.) + ;
          " AND uf_menu = " + sqlcnv(PADR(lp_cMenu,20),.T.) + " AND uf_menukey = " + sqlcnv(PADR(lp_cMenuKey,20),.T.)
l_oCa.CursorFill()
DELETE FOR UPPER(PADR(uf_userid,10)+uf_menu+uf_menukey) = UPPER(PADR(lp_cUserId,10)+PADR(lp_cMenu,20)+PADR(lp_cMenuKey,20)) IN causerfav

l_oCa.DoTableUpdate()
l_oCa.dclose()

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE TbSettingsGet
LPARAMETERS tlSmallButtons

_screen.oGlobal.Toolbar_RestoreState(@tlSmallButtons)
ENDPROC
*
PROCEDURE TbSettingsSave
LPARAMETERS tlSmallButtons

_screen.oGlobal.Toolbar_SaveState(tlSmallButtons)
ENDPROC
*
PROCEDURE NpSettingsGet
LPARAMETERS tcFieldName, tuValue

RETURN _screen.oGlobal.Navpane_RestoreState(tcFieldName, tuValue)
ENDPROC
*
PROCEDURE NpSettingsSave
LPARAMETERS tcFieldName, tuValue

_screen.oGlobal.Navpane_SaveState(tcFieldName, tuValue)
ENDPROC
*
PROCEDURE MdSettingsGet
LPARAMETERS toSettings

RETURN _screen.oGlobal.Mydesk_RestoreState(@toSettings)
ENDPROC
*
PROCEDURE MdSettingsSave
RETURN _screen.oGlobal.Mydesk_SaveState()
ENDPROC
*
PROCEDURE GetUsers
LPARAMETERS lp_cCur
IF EMPTY(lp_cCur)
	lp_cCur = SYS(2015)
ENDIF
sqlcursor("SELECT * FROM user WHERE NOT us_inactiv ORDER BY us_id", lp_cCur)
RETURN lp_cCur
ENDPROC
*