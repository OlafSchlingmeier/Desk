#INCLUDE "include\constdefines.h"
* PROCEDURE proctoolbar
LPARAMETERS tlChangeCaptions, tlSmallButtons
IF tlChangeCaptions
	ProcUser("TbSettingsSave", tlSmallButtons)
ELSE
	ProcUser("TbSettingsGet", @tlSmallButtons)
ENDIF
g_lToolBarNoCaption = tlSmallButtons
PTSetToolbar()
RETURN .T.
ENDPROC
*
PROCEDURE PTSetToolbar
IF VARTYPE(goTbrQuick) # "O"
	goTbrQuick = CREATEOBJECT('tbrQuick')
	goTbrQuick.ChangeMode(TLB_VISIBLE)
	PTBSetCitadelPicture()
ENDIF

goTbrQuick.ChangeMode(TLB_ENABLE)
IF VARTYPE(goTbrMain) # "O"
	goTbrMain = CREATEOBJECT('tbrmain')
ENDIF
IF _screen.oGlobal.lshowtabs
	IF VARTYPE(g_oTabsToolBar) # "O"
		g_oTabsToolBar = NEWOBJECT("frmtoolbar","cit_formtabs.vcx")
		g_oTabsToolBar.Dock(0,0,200)
		g_oTabsToolBar.Visible = .T.
	ENDIF
ENDIF

goTbrQuick.RefreshCaptions()

IF TYPE("_screen.ActiveForm") = "O" AND NOT ISNULL(_screen.ActiveForm)
	_screen.ActiveForm.Activate()
ENDIF

PTBSetCitadelPicture()

RETURN .T.
ENDPROC
*
PROCEDURE PTBSetCitadelPicture
LOCAL l_nNewLeft, l_nNewTop
IF TYPE('_screen.citadel') = "U"
	_screen.AddObject('citadel','image')
	_screen.citadel.Width = 415
	_screen.citadel.height = 122
	_screen.citadel.Picture = IIF(_screen.oGlobal.lUgos, '..\bitmap\ugoscitadel.png', '..\bitmap\citadel.png')
ENDIF
*l_nNewLeft = _screen.Width - 450 - IIF(_screen.oGlobal.lshowtabs AND NOT ISNULL(g_oNavigPane),200,0)
*l_nNewTop = _screen.Height - 165 - IIF(_screen.oGlobal.lshowtabs,32,0)

l_nNewLeft = _screen.Width - 450
l_nNewTop = _screen.Height - 165

IF _screen.citadel.top <> l_nNewTop
	_screen.citadel.top = l_nNewTop
ENDIF
IF _screen.citadel.left <> l_nNewLeft
	_screen.citadel.left = l_nNewLeft
ENDIF
IF NOT _screen.citadel.visible
	_screen.citadel.visible = .T.
ENDIF
IF TYPE("_Screen.imgBackground") = "O" AND NOT ISNULL(_Screen.imgBackground)
	IF _Screen.imgBackground.Width <> _Screen.Width
		_Screen.imgBackground.Width = _Screen.Width
	ENDIF
	IF _Screen.imgBackground.Height <> _Screen.Height
		_Screen.imgBackground.Height = _Screen.Height
	ENDIF
ENDIF
RETURN .T.
ENDPROC
*
DEFINE CLASS ctoolbarhnd AS Custom
	lcitMainVisible = .F.
	lcitQuickVisible = .F.
	lcitTabsVisible = .F.
	lcitToolEnable = .F.
	lcitMainEnable = .F.
	lcitQuickEnable = .F.
	lcitTabsEnable = .F.

	PROCEDURE HideToolbars
		LPARAMETERS lp_lDontHideQuick
		this.lcitMainVisible = goTbrMain.lToolVisible
		this.lcitQuickVisible = goTbrQuick.lToolVisible
		IF _screen.oGlobal.lshowtabs
			this.lcitTabsVisible = g_oTabsToolBar.Visible
			IF this.lcitTabsVisible
				IF TYPE("g_oNavigPane") = "O" AND NOT ISNULL(g_oNavigPane) AND g_oNavigPane.Active
					g_oNavigPane.HideIt()
				ENDIF
			ENDIF
		ENDIF
		IF this.lcitMainVisible
			goTbrMain.Hide()
		ENDIF
		IF _screen.oGlobal.lshowtabs
			IF this.lcitTabsVisible
				g_oTabsToolBar.Hide()
			ENDIF
		ENDIF
		IF this.lcitQuickVisible AND NOT lp_lDontHideQuick
			goTbrQuick.Hide()
		ENDIF
	ENDPROC

	PROCEDURE ShowToolbars
		IF this.lcitQuickVisible
			goTbrQuick.OnShow()
		ENDIF
		IF this.lcitMainVisible
			*goTbrMain.Dock(0)
			goTbrMain.OnShow()
		ENDIF
		IF _screen.oGlobal.lshowtabs
			IF this.lcitTabsVisible
				g_oTabsToolBar.Dock(0,0,200)
				g_oTabsToolBar.Show()
				IF TYPE("g_oNavigPane") = "O" AND NOT ISNULL(g_oNavigPane) AND g_oNavigPane.Active
					g_oNavigPane.ShowIt()
				ENDIF
			ENDIF
		ENDIF
	ENDPROC

	PROCEDURE DisableToolbars
		this.lcitMainEnable = goTbrMain.Enabled
		this.lcitQuickEnable = goTbrQuick.Enabled
		IF this.lcitMainEnable
			goTbrMain.Enabled = .F.
		ENDIF
		IF _screen.oGlobal.lshowtabs
			this.lcitTabsEnable = g_oTabsToolBar.Enabled
			IF this.lcitTabsEnable
				g_oTabsToolBar.Enabled = .F.
			ENDIF
		ENDIF
		IF this.lcitQuickEnable
			goTbrQuick.Enabled = .F.
			IF _screen.oGlobal.lshowtabs
				g_oTabsToolBar.Enabled = .F.
				IF TYPE("g_oNavigPane") = "O" AND NOT ISNULL(g_oNavigPane) AND g_oNavigPane.Active
					g_oNavigPane.Enabled = .F.
				ENDIF
			ENDIF
		ENDIF
	ENDPROC

	PROCEDURE EnableToolbars
		LPARAMETERS lp_lOnlyFormToolbar
		IF lp_lOnlyFormToolbar
			IF this.lcitMainEnable
				goTbrMain.Enabled = .T.
			ENDIF
			RETURN .T.
		ENDIF
		IF this.lcitQuickEnable
			goTbrQuick.Enabled = .T.
			IF _screen.oGlobal.lshowtabs
				g_oTabsToolBar.Enabled = .T.
			ENDIF
		ENDIF
		IF this.lcitMainEnable
			goTbrMain.Enabled = .T.
		ENDIF
		IF _screen.oGlobal.lshowtabs
			IF this.lcitTabsEnable
				g_oTabsToolBar.Enabled = .T.
				IF TYPE("g_oNavigPane") = "O" AND NOT ISNULL(g_oNavigPane) AND g_oNavigPane.Active
					g_oNavigPane.Enabled = .T.
				ENDIF
			ENDIF
		ENDIF
		RETURN .T.
	ENDPROC
ENDDEFINE