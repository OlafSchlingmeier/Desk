*
#INCLUDE "include\constdefines.h"
*
LPARAMETER lp_cCaption, lp_cLabel, lp_aDlg, lp_lNoESC, lp_nLabelWidth, lp_lClose, lp_lDontRefreshToolbar
LOCAL l_oDlg, l_n, l_cDefData, l_cClassName
LOCAL l_cName, l_cLabel, l_Default, l_cPicture, l_nSize, l_cValid, l_cError, l_cSql, l_lReadOnly
LOCAL l_oCtrl, l_oLabel, l_nOptNo
LOCAL l_lRet, l_nTop, l_nLeft, l_oAddParams
LOCAL ARRAY l_aOptItems(1)
IF EMPTY(lp_nLabelWidth)
	lp_nLabelWidth = 120
ENDIF
l_cSql = ""
STORE .NULL. TO l_lReadOnly, l_oAddParams
EXTERNAL ARRAY lp_aDlg
l_oDlg = CREATEOBJECT("frmdialog")
l_oDlg.lRefreshToolbar = NOT lp_lDontRefreshToolbar
l_oDlg.w = 240
l_oDlg.Caption = lp_cCaption
l_oDlg.oDlgData.AddProperty("aDlg(1)")
ACOPY(lp_aDlg,l_oDlg.oDlgData.aDlg)
l_nTop = 10
l_nLeft = 10
IF NOT EMPTY(lp_cLabel)
	FOR i = 1 TO GETWORDCOUNT(lp_cLabel,CRLF)
		l_oDlg.AddObject("lbl"+PADL(i-1,3,"0"), "tlabel")
		l_oLabel = EVALUATE("l_oDlg.lbl"+PADL(i-1,3,"0"))
		l_oLabel.Caption = GETWORDNUM(lp_cLabel,i,CRLF)
		l_oLabel.l = 10
		l_oLabel.t = l_nTop
		l_oLabel.Autosize = .T.
		l_oLabel.Visible = .T.
		l_oDlg.w = MAX(l_oDlg.w, l_oLabel.Width + 20)
		l_nTop = l_nTop + 15
	NEXT
ENDIF
FOR l_n = 1 TO ALEN(lp_aDlg,1)
	l_cName = lp_aDlg(l_n, 1)
	l_cLabel = lp_aDlg(l_n, 2)
	l_Default = IIF(GETWORDCOUNT(lp_aDlg(l_n, 3),CRLF) = 1, EVALUATE(EVL(lp_aDlg(l_n, 3),"''")), lp_aDlg(l_n, 3))
	l_cPicture = EVL(lp_aDlg(l_n, 4),"")
	l_nSize = IIF(EMPTY(lp_aDlg(l_n, 5)),120,lp_aDlg(l_n, 5)*6)	&&foxel
	l_cValid = lp_aDlg(l_n, 6)
	l_cError = EVL(lp_aDlg(l_n, 7),"")
	l_oDlg.oDlgData.aDlg(l_n,8) = l_Default
	IF TYPE("lp_aDlg(l_n, 9)") == "C"
		l_cSql = lp_aDlg(l_n, 9)
	ELSE
		l_cSql = ""
	ENDIF
	IF TYPE("lp_aDlg(l_n, 10)") = "L"
		l_lReadOnly = lp_aDlg(l_n, 10)
	ENDIF
	IF NOT EMPTY(l_cLabel)
		l_nLeft = 10
	ENDIF
	l_oAddParams = IIF(TYPE("lp_aDlg(l_n, 11)") = "O", lp_aDlg(l_n, 11), .NULL.)
	DO CASE
		CASE TYPE("l_Default") = "D"
			l_cClassName = "ldatectrl"
		CASE OCCURS("E", l_cPicture) > 0 AND OCCURS("@", l_cPicture) > 0
			l_cClassName = "leditbox"
		CASE OCCURS("C", l_cPicture) > 0 AND OCCURS("@", l_cPicture) > 0
			l_cClassName = "tcheckbox"
		CASE OCCURS("S", l_cPicture) > 0 AND OCCURS("@", l_cPicture) > 0
			l_cClassName = "lspinner"
		CASE OCCURS("R", l_cPicture) > 0 AND OCCURS("@", l_cPicture) > 0
			l_cClassName = "loptiongroup"
			l_cLabel = l_cLabel + ";"
			DIMENSION l_aOptItems(OCCURS(';', l_cLabel))
			FOR l_nOptNo = 1 TO ALEN(l_aOptItems,1)
				l_aOptItems(l_nOptNo) = LEFT(l_cLabel, AT(";", l_cLabel)-1)
				l_cLabel = SUBSTR(l_cLabel, AT(";", l_cLabel)+1)
			ENDFOR
		CASE OCCURS("G", l_cPicture) > 0 AND OCCURS("@", l_cPicture) > 0
			l_cClassName = "lcombobox"
		CASE OCCURS("B", l_cPicture) > 0 AND OCCURS("@", l_cPicture) > 0
			l_cClassName = "cmdButton"
		OTHERWISE
			l_cClassName = "ltext"
	ENDCASE
	IF NOT EMPTY(l_cLabel) AND l_cClassName <> "tcheckbox"
		l_oDlg.AddObject("lbl"+l_cName, "tlabel")
		l_oLabel = EVALUATE("l_oDlg.lbl"+l_cName)
		l_oLabel.t = l_nTop
		l_oLabel.l = l_nLeft
		l_oLabel.Visible = .T.
		l_oLabel.Autosize = .T.
		l_oLabel.Caption = l_cLabel
		l_nLeft = l_nLeft + lp_nLabelWidth
	ENDIF
	l_oDlg.AddObject(l_cName, l_cClassName)
	l_oCtrl = EVALUATE("l_oDlg."+l_cName)
	DO CASE
		CASE l_cClassName = "tcheckbox"
			l_oCtrl.Caption = l_cLabel
			l_oCtrl.Autosize = .T.
		CASE l_cClassName = "loptiongroup"
			l_oCtrl.init(@l_aOptItems)
			l_oCtrl.Autosize = .T.
		CASE l_cClassName = "lcombobox"
			l_oCtrl.init(l_cSql, l_nSize, l_oAddParams)
		CASE l_cClassName = "lspinner"
			l_oCtrl.init(l_oAddParams)
		CASE l_cClassName = "ltext"
			l_oCtrl.Init(l_oAddParams)
			l_oCtrl.InputMask = l_cPicture
			IF NOT ISNULL(l_lReadOnly)
				l_oCtrl.Enabled = NOT l_lReadOnly
			ENDIF
		CASE l_cClassName = "leditbox"
			l_oCtrl.Init(l_oAddParams)
		CASE l_cClassName = "cmdButton"
			l_oCtrl.Autosize = .T.
		CASE l_cClassName = "ldatectrl"
			IF NOT ISNULL(l_lReadOnly)
				l_oCtrl.Enabled = NOT l_lReadOnly
			ENDIF
	ENDCASE
	l_oCtrl.t = l_nTop
	l_oCtrl.l = l_nLeft
	l_oCtrl.w = l_nSize
	l_oCtrl.Visible = .T.
	IF l_cClassName = "cmdButton"
		IF TYPE("lp_aDlg(l_n,11)")="O" AND NOT ISNULL(lp_aDlg(l_n,11))
			l_oCtrl.oHandler = lp_aDlg(l_n,11)
			l_oCtrl.Caption = l_oCtrl.oHandler.Caption
		ENDIF
	ELSE
		l_oCtrl.ControlSource = [thisform.oDlgData.aDlg(]+ALLTRIM(STR(l_n))+[,8)]
	ENDIF
	l_oCtrl.AddProperty("cValid",l_cValid)
	l_oCtrl.AddProperty("cError",l_cError)
	l_oCtrl.Refresh()
	DO CASE
		CASE TYPE("lp_aDlg(l_n+1,12)") = "L" AND lp_aDlg(l_n+1,12)	&& Next to object
			l_nLeft = l_nLeft + 1
		CASE l_cClassName = "loptiongroup"
			l_nTop = l_nTop + 24 * ALEN(l_aOptItems,1)
		CASE l_cClassName = "leditbox"
			l_nTop = l_nTop + l_oCtrl.Height + 1
		OTHERWISE
			l_nTop = l_nTop + 24
	ENDCASE
	l_nLeft = l_nLeft + l_nSize
	l_oDlg.w = MAX(l_oDlg.w, l_nLeft + 10)
ENDFOR
l_nTop = l_nTop + 6
l_oDlg.AddObject("cmdOK","OKCommand")
l_oDlg.cmdOK.l = l_oDlg.w / 2 - IIF(lp_lClose, 42, 90)
l_oDlg.cmdOK.t = l_nTop
l_oDlg.cmdOK.Caption = GetLangText("COMMON","TXT_OK")
l_oDlg.cmdOK.Visible = .T.
IF NOT lp_lClose
	l_oDlg.AddObject("cmdCancel","CancelCommand")
	l_oDlg.cmdCancel.l = l_oDlg.w / 2 + 6
	l_oDlg.cmdCancel.t = l_nTop
	l_oDlg.cmdCancel.Caption = GetLangText("COMMON","TXT_CANCEL")
	l_oDlg.cmdCancel.Visible = .T.
ENDIF
l_oDlg.h = MAX(80,l_nTop + 34)
l_oDlg.height = l_oDlg.h
l_oDlg.width = l_oDlg.w
l_oDlg.SetAll("lUseAlwaysOnTopDataPicker", .T., "ldatectrl")
l_oDlg.Resize()
l_oDlg.Show(1)
l_lRet = l_oDlg.oDlgData.lRet
ACOPY(l_oDlg.oDlgData.aDlg, lp_aDlg)
l_oDlg.Release()
RETURN l_lRet
*
DEFINE CLASS datatunnel AS cdatatunnel
	lRet = .F.
ENDDEFINE
*
DEFINE CLASS frmDialog AS tform
	ADD OBJECT oDlgData AS datatunnel
	Closable = .T.
	ControlBox = .T.
	Icon = "bitmap\checkmrk.ico"
	MaxButton = .F.
	MinButton = .F.
	PROCEDURE resize
		LOCAL l_n, l_cCtrl, l_oCtrl
		DODEFAULT()
		FOR l_n = 1 TO this.ControlCount
			l_cCtrl = "this.Controls("+ALLTRIM(STR(l_n))+")"
			IF TYPE(l_cCtrl+".lsizeable") <> "U"
				l_oCtrl = &l_cCtrl
				l_oCtrl.resize()
			ENDIF
		ENDFOR
	ENDPROC
	*
	PROCEDURE QueryUnload
		NODEFAULT
		IF PEMSTATUS(this, "cmdCancel", 5)
			this.cmdCancel.click()
		ENDIF
	ENDPROC
ENDDEFINE
*
DEFINE CLASS ldatectrl AS tdatectrl
	lsizeable = .T.
	PROCEDURE valid
		LOCAL l_lRet, l_n, l_cLocVar
		l_lRet = DODEFAULT()
		FOR l_n = 1 TO ALEN(thisform.oDlgData.aDlg,1)
			l_cLocVar = thisform.oDlgData.aDlg(l_n,1)
			&l_cLocVar = thisform.oDlgData.aDlg(l_n,8)
		ENDFOR
		cReadError = this.cError
		IF TYPE("l_lRet") = "L" AND l_lRet ;
				AND NOT EMPTY(this.cValid) AND NOT EVALUATE(this.cValid)
			this.DropDown()
			RETURN 0
		ENDIF
		RETURN l_lRet
	ENDPROC
	PROCEDURE resize
		thisform.resizetdatectrl(this)
	ENDPROC
ENDDEFINE
*
DEFINE CLASS ltext AS ttext
	PROCEDURE Init
		LPARAMETERS lp_oAddParams
		LOCAL i, l_cPropName, l_cMacro

		IF VARTYPE(lp_oAddParams) = "O"
			* Collection with properties from combo
			FOR i = 1 TO lp_oAddParams.Count
				l_cMacro = "this." + lp_oAddParams.GetKey(i) + " = " + SqlCnv(lp_oAddParams.Item(i))
				TRY
					&l_cMacro
				CATCH
					ASSERT .F. MESSAGE PROGRAM()
				ENDTRY
			NEXT
		ENDIF

		DODEFAULT()
	ENDPROC
	*
	PROCEDURE valid
		LOCAL l_lRet, l_n, l_cLocVar
		l_lRet = DODEFAULT()
		FOR l_n = 1 TO ALEN(thisform.oDlgData.aDlg,1)
			l_cLocVar = thisform.oDlgData.aDlg(l_n,1)
			&l_cLocVar = thisform.oDlgData.aDlg(l_n,8)
		ENDFOR
		cReadError = this.cError
		IF TYPE("l_lRet") = "L" AND l_lRet ;
				AND NOT EMPTY(this.cValid) AND NOT EVALUATE(this.cValid)
			l_lRet = .F.
		ENDIF
		RETURN l_lRet
	ENDPROC
ENDDEFINE
*
DEFINE CLASS leditbox AS teditbox
	PROCEDURE Init
		LPARAMETERS lp_oAddParams
		LOCAL i, l_cPropName, l_vPropValue

		IF VARTYPE(lp_oAddParams) = "O"
			* Collection with properties from combo
			FOR i = 1 TO lp_oAddParams.Count
				l_cPropName = lp_oAddParams.GetKey(i)
				l_vPropValue = lp_oAddParams.Item(i)
				TRY
					this.&l_cPropName = l_vPropValue
				CATCH
					ASSERT .F. MESSAGE PROGRAM()
				ENDTRY
			NEXT
		ENDIF

		DODEFAULT()
	ENDPROC
	*
	PROCEDURE Valid
		LOCAL l_lRet, l_n, l_cLocVar
		l_lRet = DODEFAULT()
		FOR l_n = 1 TO ALEN(thisform.oDlgData.aDlg,1)
			l_cLocVar = thisform.oDlgData.aDlg(l_n,1)
			&l_cLocVar = thisform.oDlgData.aDlg(l_n,8)
		ENDFOR
		cReadError = this.cError
		IF TYPE("l_lRet") = "L" AND l_lRet AND NOT EMPTY(this.cValid) AND NOT EVALUATE(this.cValid)
			l_lRet = .F.
		ENDIF
		RETURN l_lRet
	ENDPROC
ENDDEFINE
*
DEFINE CLASS loptiongroup AS toptiongroup
	PROCEDURE init
		LPARAMETERS lp_aOptData
		LOCAL l_nOptNo
		IF PCOUNT() > 0
			EXTERNAL ARRAY lp_aOptData
			this.ButtonCount = ALEN(lp_aOptData)
			DODEFAULT()
			this.w = 120
			this.h = 8 + this.ButtonCount * 19
			FOR l_nOptNo = 1 TO this.ButtonCount
				WITH EVALUATE("this.option"+ALLTRIM(STR(l_nOptNo)))
					.Left = 5
					.Top = 5 + 19*(l_nOptNo-1)
					.AutoSize = .T.
					.Caption = lp_aOptData(l_nOptNo)
					this.bl(l_nOptNo) = .Left
					this.bt(l_nOptNo) = .Top
					this.bw(l_nOptNo) = .Width
				ENDWITH
			ENDFOR
		ELSE
			NODEFAULT
		ENDIF
	ENDPROC
ENDDEFINE
*
DEFINE CLASS lcombobox as tcombobox
	rowsourcetype = 3
	columncount = 2
	columnlines = .F.
	boundcolumn = 2
	boundto = .T.
	style = 2
	lcursor = ''
	jsql = ''
	oHandler = .NULL.
	PROCEDURE Init
		LPARAMETERS pl_cSql, pl_nWidth, pl_oAddParams
		LOCAL l_nValue

		this.jsql = pl_cSql
		DO CASE
			CASE EMPTY(pl_cSql)
			CASE UPPER(LEFT(pl_cSql, 7)) == 'SELECT '
				this.lcursor = SYS(2015)
				this.RowSource = '=sqlcursor(this.jsql,this.lcursor)'
				this.ColumnWidths = ntoc(pl_nWidth) + ',0'
			CASE INLIST(LOWER(pl_cSql), "padow", "pamonths")
				l_nValue = this.Value
				this.RowSourceType = 5
				this.RowSource = pl_cSql
				this.BoundTo = .F.
				this.ColumnWidths = ntoc(pl_nWidth) + ',0'
				this.Value = l_nValue
			OTHERWISE
				this.RowSourceType = 1
				this.RowSource = pl_cSql
				this.ColumnWidths = ntoc(pl_nWidth) + ',0'
		ENDCASE
		IF VARTYPE(pl_oAddParams) = "O"
			* Collection with properties from combo
			FOR i = 1 TO pl_oAddParams.Count
				l_cPropName = pl_oAddParams.GetKey(i)
				IF l_cPropName = "ohandler"
					this.oHandler = pl_oAddParams.Item(i)
					LOOP
				ENDIF
				l_cMacro = "this." + l_cPropName + " = " + sqlcnv(pl_oAddParams.Item(i))
				TRY
					&l_cMacro
				CATCH
					ASSERT .F. MESSAGE PROGRAM()
				ENDTRY
			ENDFOR
		ENDIF
		DODEFAULT()
	ENDPROC
	*
	PROCEDURE LostFocus
	IF TYPE("this.oHandler")="O" AND NOT ISNULL(this.oHandler)
		TRY
			this.oHandler.LostFocus(thisform)
		CATCH
			ASSERT .F. MESSAGE PROGRAM()
		ENDTRY
	ENDIF
	ENDPROC
	*
	PROCEDURE Destroy
	IF NOT ISNULL(this.oHandler) AND PEMSTATUS(this.oHandler,"Release",5)
		this.oHandler.Release()
	ENDIF
	dclose(this.lcursor)
	RETURN .T.
	ENDPROC
	*
ENDDEFINE
*
DEFINE CLASS lspinner as tspinner
	height = 23
	PROCEDURE Init
		LPARAMETERS lp_oAddParams
		LOCAL i, l_cPropName, l_cMacro

		IF VARTYPE(lp_oAddParams) = "O"
			* Collection with properties from combo
			FOR i = 1 TO lp_oAddParams.Count
				l_cMacro = "this." + lp_oAddParams.GetKey(i) + " = " + SqlCnv(lp_oAddParams.Item(i))
				TRY
					&l_cMacro
				CATCH
					ASSERT .F. MESSAGE PROGRAM()
				ENDTRY
			NEXT
		ENDIF

		DODEFAULT()
	ENDPROC
	*
	PROCEDURE Valid
		LOCAL l_lRet, l_n, l_cLocVar

		l_lRet = DODEFAULT()
		FOR l_n = 1 TO ALEN(thisform.oDlgData.aDlg,1)
			l_cLocVar = thisform.oDlgData.aDlg(l_n,1)
			&l_cLocVar = thisform.oDlgData.aDlg(l_n,8)
		ENDFOR
		cReadError = this.cError
		IF TYPE("l_lRet") = "L" AND l_lRet AND NOT EMPTY(this.cValid) AND NOT EVALUATE(this.cValid)
			l_lRet = .F.
		ENDIF
		RETURN l_lRet
	ENDPROC
ENDDEFINE
*
DEFINE CLASS OKCommand AS tcommandbutton
	PROCEDURE Click
		LOCAL i, j, l_cPropName, l_vPropValue, l_oControl

		thisform.oDlgData.lRet = .T.
		IF ALEN(thisform.oDlgData.aDlg,2) >= 11
			FOR i = 1 TO ALEN(thisform.oDlgData.aDlg,1)
				IF VARTYPE(thisform.oDlgData.aDlg(i,11)) = "O" AND thisform.oDlgData.aDlg(i,11).BaseClass = "Collection"
					FOR j = 1 TO thisform.oDlgData.aDlg(i,11).Count
						l_cPropName = thisform.oDlgData.aDlg(i,11).GetKey(j)
						l_vPropValue = thisform.oDlgData.aDlg(i,11).Item(j)
						l_oControl = EVALUATE("thisform."+thisform.oDlgData.aDlg(i,1))
						TRY
							IF NOT l_oControl.&l_cPropName == l_vPropValue
								thisform.oDlgData.aDlg(i,11).Remove(l_cPropName)
								thisform.oDlgData.aDlg(i,11).Add(l_oControl.&l_cPropName, l_cPropName)
							ENDIF
						CATCH
							ASSERT .F. MESSAGE PROGRAM()
						ENDTRY
					NEXT
				ENDIF
			NEXT
		ENDIF

		thisform.Hide()
	ENDPROC
ENDDEFINE
*
DEFINE CLASS CancelCommand AS tcommandbutton
	PROCEDURE Click
		thisform.hide()
	ENDPROC
ENDDEFINE
*
DEFINE CLASS cmdButton AS tcommandbutton
oHandler = .NULL.
FontSize = 7
PROCEDURE Click
IF TYPE("this.oHandler")="O" AND NOT ISNULL(this.oHandler)
	TRY
		this.oHandler.Click(thisform)
	CATCH
		ASSERT .F. MESSAGE PROGRAM()
	ENDTRY
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE Destroy
IF NOT ISNULL(this.oHandler) AND PEMSTATUS(this.oHandler,"Release",5)
	this.oHandler.Release()
ENDIF
RETURN .T.
ENDPROC
ENDDEFINE

