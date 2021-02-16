*PROCEDURE procnavpane
LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
          lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
LOCAL l_cCallProc, l_nParamNo, l_uRetVal
l_cCallProc = lp_cFuncName + "("
FOR l_nParamNo = 1 TO PCOUNT()-1
     l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
NEXT
l_cCallProc = l_cCallProc + ")"
l_uRetVal = &l_cCallProc
RETURN l_uRetVal
ENDFUNC
*
PROCEDURE TurnOnNavPane
LOCAL l_nTurnOnNavPane

l_nTurnOnNavPane = GetProperty("Visible")
NavigationPane(l_nTurnOnNavPane)

RETURN .T.
ENDPROC
*
PROCEDURE Execute
LPARAMETERS lp_cNode, lp_cProcedure
LOCAL l_lAllowed, l_lModal

l_lAllowed = .T.
IF TYPE("_screen.ActiveForm.Name")="C"
     l_lModal = (_screen.ActiveForm.WindowType = 1)
     IF l_lModal
          l_lAllowed = .F.
     ENDIF
ENDIF
 
IF l_lAllowed
     DO LogNavPane IN LogMenu WITH lp_cNode, lp_cProcedure
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE ReleaseNavPane
IF TYPE("g_oNavigPane") = "O" AND NOT ISNULL(g_oNavigPane)
     IF LOWER(g_oNavigPane.Name) = "tnbthemedoutlooknavbarfrm"
          g_oNavigPane.Release()
          g_oNavigPane = .NULL.
     ELSE
          g_oNavigPane = .NULL.
          _Screen.RemoveObject("oNavigPane")
     ENDIF
ENDIF
DO PTBSetCitadelPicture IN proctoolbar
RETURN .T.
ENDPROC
*
PROCEDURE NavigationPane
LPARAMETERS lp_lVisible
LOCAL l_lVisible, l_cKey, l_nTheme, l_nWidth, l_lShrunk

IF PCOUNT()<1 && No parameter sent, we wan't to change current setting
     IF ISNULL(g_oNavigPane) OR (NOT ISNULL(g_oNavigPane) AND NOT g_oNavigPane.Active)
          * TurnOn
          l_lVisible = .T.
     ELSE
          * TurnOff
          l_lVisible = .F.
     ENDIF
ELSE
     l_lVisible = lp_lVisible
ENDIF

IF l_lVisible AND ISNULL(g_oNavigPane)
     IF _screen.oGlobal.lshowtabs
          _Screen.AddProperty("oNavigPane",.NULL.)
          _Screen.oNavigPane = NEWOBJECT("tnbThemedOutlookNavBarfrm", "libs\cit_ctrl.vcx")
          _screen.oNavigPane.Dockable = 1
          _screen.oNavigPane.Dock(1)
     ELSE
          _Screen.Newobject("oNavigPane", "tnbThemedOutlookNavBar", "libs\cit_ctrl.vcx")
          _screen.oNavigPane.Visible = .T.
     ENDIF
     g_oNavigPane = _screen.oNavigPane
ENDIF

IF NOT ISNULL(g_oNavigPane)
     VisibleChanged(l_lVisible)
     MainMenu()
     l_cKey = PADR("FRMNAVPANE",20)+PADR(g_userid,10)
     IF l_lVisible
          l_lShrunk = GetProperty("shrunk")
          IF g_oNavigPane.GetShrunk() <> l_lShrunk
               g_oNavigPane.SetShrunk(l_lShrunk)
          ENDIF
          IF NOT g_oNavigPane.GetShrunk()
               l_nWidth = GetProperty("width")
               IF l_nWidth > 0 AND g_oNavigPane.Width <> l_nWidth
                    IF PEMSTATUS(g_oNavigPane,"WidthChange",5)
                         g_oNavigPane.WidthChange(l_nWidth)
                    ELSE
                         g_oNavigPane.Width = l_nWidth
                    ENDIF
               ENDIF
          ENDIF
          l_nTheme = GetProperty("theme")
          IF l_nTheme > 0 AND _screen.oThemesManager.ThemeNumber <> l_nTheme
               _screen.oThemesManager.ThemeNumber = l_nTheme
          ENDIF
     ENDIF
     g_oNavigPane.Active = l_lVisible
ENDIF

DO PTBSetCitadelPicture IN proctoolbar
RETURN .T.
ENDPROC
*
PROCEDURE ThemeChanged
LPARAMETERS lp_nThemeNo

IF PCOUNT()<1
     RETURN .F.
ENDIF

PropertyChanged("theme",lp_nThemeNo)

RETURN .T.
ENDPROC
*
PROCEDURE WidthChanged
LPARAMETERS lp_nNewWidth

IF PCOUNT()<1
     RETURN .F.
ENDIF

PropertyChanged("width",lp_nNewWidth)

RETURN .T.
ENDPROC
*
PROCEDURE VisibleChanged
LPARAMETERS lp_lVisible

IF PCOUNT()<1
     RETURN .F.
ENDIF

PropertyChanged("visible",lp_lVisible)

RETURN .T.
ENDPROC
*
PROCEDURE ShrunkChanged
LPARAMETERS lp_lShrunk

IF PCOUNT()<1
     RETURN .F.
ENDIF

PropertyChanged("shrunk",lp_lShrunk)

RETURN .T.
ENDPROC
*
PROCEDURE PropertyChanged
LPARAMETERS lp_cPropertyName, lp_uNewValue
LOCAL l_cFieldName

IF PCOUNT()<2
     RETURN .F.
ENDIF

DO CASE
     CASE LOWER(lp_cPropertyName)=="visible"
          l_cFieldName = "sc_usset1"
     CASE LOWER(lp_cPropertyName)=="width"
          l_cFieldName = "sc_width"
     CASE LOWER(lp_cPropertyName)=="theme"
          l_cFieldName = "sc_wrange1"
     CASE LOWER(lp_cPropertyName)=="shrunk"
          l_cFieldName = "sc_usset2"
     OTHERWISE
          RETURN .F.
ENDCASE

ProcUser("NpSettingsSave", l_cFieldName, lp_uNewValue)

RETURN .T.
ENDPROC
*
PROCEDURE GetProperty
LPARAMETERS lp_cPropertyName
LOCAL l_cFieldName, l_uRetVal

IF PCOUNT()<1
     RETURN .F.
ENDIF

DO CASE
     CASE LOWER(lp_cPropertyName)=="visible"
          l_cFieldName = "sc_usset1"
          l_uRetVal = .T.
     CASE LOWER(lp_cPropertyName)=="width"
          l_cFieldName = "sc_width"
          l_uRetVal = 150
     CASE LOWER(lp_cPropertyName)=="theme"
          l_cFieldName = "sc_wrange1"
          l_uRetVal = 2
     CASE LOWER(lp_cPropertyName)=="shrunk"
          l_cFieldName = "sc_usset2"
          l_uRetVal = .F.
     OTHERWISE
          RETURN .F.
ENDCASE

l_uRetVal = ProcUser("NpSettingsGet", l_cFieldName, l_uRetVal)

RETURN l_uRetVal
ENDPROC
*