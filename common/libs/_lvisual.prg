**************************************************
*-- Default Column class for tGrid objects.
DEFINE CLASS tColumn AS Column 
	HeaderClass = "tHeader"
	HeaderClassLibrary = "_lvisual.prg"
	StartWidth = 75
	cControlSource = ""
	FieldSource = ""
	lCheckBox = .F.
	lEditBox = .F.

	ADD OBJECT tTextGrid1 AS tTextGrid

	PROTECTED PROCEDURE lCheckBox_assign
		LPARAMETERS tlValue

		this.lCheckBox = tlValue
		IF this.lCheckBox AND PEMSTATUS(this, "tTextGrid1", 5) AND NOT PEMSTATUS(this, "tCheckGrid1", 5)
			this.ControlSource = ""
			this.RemoveObject("tTextGrid1")
			this.AddObject("tCheckGrid1", "tCheckGrid")
			this.AddProperty("aCheckBoxValue(1)")
			this.Sparse = .F.
		ENDIF
		IF this.lCheckBox
			this.cControlSource = "thisform." + this.Parent.Name + "." + this.Name + ".aCheckBoxValue[RECNO()]"
		ENDIF
	ENDPROC

	PROTECTED PROCEDURE lEditBox_assign
		LPARAMETERS tlValue

		this.lEditBox = tlValue
		IF this.lEditBox AND PEMSTATUS(this, "tTextGrid1", 5) AND NOT PEMSTATUS(this, "tEditGrid1", 5)
			this.RemoveObject("tTextGrid1")
			this.AddObject("tEditGrid1", "tEditGrid")
			this.tEditGrid1.SelectedBackColor = RGB(150,180,230)
			this.tEditGrid1.Visible = .T.
		ENDIF
	ENDPROC

	PROTECTED PROCEDURE FontSize_assign
		LPARAMETERS tnValue

		IF this.Parent.lResizeRows
			this.FontSize = tnValue
		ENDIF
	ENDPROC

	PROTECTED PROCEDURE Width_assign
		LPARAMETERS tnValue

		IF this.Parent.lResizeColumns
			this.Width = tnValue
			IF NOT this.Parent.lResizeOnProgress AND PEMSTATUS(this.Parent, "ScaleWidth", 5)
				this.StartWidth = ROUND(this.Width / this.Parent.ScaleWidth, 0)
			ENDIF
		ENDIF
	ENDPROC

ENDDEFINE
*
*-- EndDefine: tColumn
**************************************************

**************************************************
*-- Default Header class for tColumn objects.
DEFINE CLASS tHeader AS Header
	PROTECTED lLangTextAssigned
	Alignment = 2
	lLangTextAssigned = .F.
	cTagName = ""
	cAppPart = ""

	PROCEDURE Caption_assign
		LPARAMETERS tcNewVal

		IF NOT this.lLangTextAssigned AND TYPE("goApp.oFunc.oText") = "O" AND PEMSTATUS(goApp.oFunc.oText, "Th", 5)
			LOCAL lcAppPart
			DO CASE
				CASE NOT EMPTY(this.cAppPart)
					lcAppPart = this.cAppPart
				CASE TYPE("thisform.Name")="C"
					lcAppPart = thisform.Name
				OTHERWISE
					lcAppPart = ""
			ENDCASE
			tcNewVal = goApp.oFunc.oText.Th(tcNewVal, lcAppPart)
			this.lLangTextAssigned = .T.
		ENDIF

		this.Caption = tcNewVal
	ENDPROC

	PROTECTED PROCEDURE FontSize_assign
		LPARAMETERS tnValue

		IF this.Parent.Parent.lResizeRows
			this.FontSize = tnValue
		ENDIF
	ENDPROC

	PROCEDURE DblClick
		this.SetOrder(.T.)
	ENDPROC

	PROCEDURE SetOrder
		LPARAMETERS tlChangeOrder
		LOCAL lnArea, lnRecno, llLockScreen, loGrid, lcIdxExpr, lcTag, lcOldTag, lcAscend

		IF this.Parent.Parent.lAllowSorting AND NOT EMPTY(this.cTagName)
			loGrid = this.Parent.Parent
			lcTag = UPPER(this.cTagName)
			lcOldTag = IIF(TYPE("loGrid.oActiveHeader.cTagName") = "C", UPPER(loGrid.oActiveHeader.cTagName), "")
			llLockScreen = thisform.LockScreen
			thisform.LockScreen = .T.
			lnArea = SELECT()
			SELECT (loGrid.RecordSource)
			lnRecno = RECNO()
			IF lcTag == lcOldTag
				IF tlChangeOrder
					lcAscend = IIF(DESCENDING(), "ASCENDING", "DESCENDING")
				ENDIF
				SET ORDER TO &lcTag &lcAscend
			ELSE
				IF EMPTY(TAGNO(lcTag))
					IF CURSORGETPROP("Buffering") < 4
						lcAscend = "ASCENDING"
						lcIdxExpr = this.Parent.ControlSource
						INDEX ON &lcIdxExpr TAG &lcTag ADDITIVE
					ENDIF
				ELSE
					lcAscend = "ASCENDING"
					SET ORDER TO &lcTag &lcAscend
				ENDIF
			ENDIF
			this.SetImage(lcAscend)
			GO TOP
			IF thisform.Visible
				loGrid.SetFocus()
			ENDIF
			GO lnRecno
			SELECT (lnArea)
			thisform.LockScreen = llLockScreen
		ENDIF
	ENDPROC

	PROCEDURE SetImage
		LPARAMETERS tcAscend
		LOCAL loGrid

		IF NOT EMPTY(tcAscend)
			loGrid = this.Parent.Parent
			IF VARTYPE(loGrid.oActiveHeader) = "O"
				loGrid.oActiveHeader.Picture = ""
			ENDIF
			loGrid.oActiveHeader = this
			IF tcAscend = "DESCENDING"
				loGrid.oActiveHeader.Picture = "picts\down.png"
			ELSE
				loGrid.oActiveHeader.Picture = "picts\up.png"
			ENDIF
		ENDIF
	ENDPROC

ENDDEFINE
*
*-- EndDefine: tHeader
**************************************************