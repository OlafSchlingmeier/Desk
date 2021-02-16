 LPARAMETER lp_cTitle, lp_cButtons, lp_cMessage, lp_cIconfile, lp_lEditBoxEnabled, lp_lWidth
 LOCAL l_oDlg, l_nPCount, l_n, l_cLine, l_nLeft, l_nTop, l_nHeight
 LOCAL l_nButtonCount, l_nRet
 l_nLeft = 10
 l_nTop = 10
 l_nHeight = 0
 l_nPCount = PCOUNT()
 l_oDlg = CREATEOBJECT("lform")
 l_oDlg.Caption = lp_cTitle
 IF l_nPCount > 3
 	WITH l_oDlg.AddControl("imgIcon","timage", l_nLeft, l_nTop)
 		.w = 36
 		.h = 36
 		.Picture = lp_cIconFile
 		l_nHeight = MAX(l_nHeight, .h+10)
	 	l_nLeft = l_nLeft + .w + 10
 	ENDWITH
 ENDIF
 IF l_nPCount > 2
 	WITH l_oDlg.AddControl("lblMessage","teditbox", l_nLeft, l_nTop)
 		.h = 15
 		.BorderStyle = 0
 		IF NOT lp_lEditBoxEnabled
 			.Enabled = .F.
 			.Scrollbars = 0
 			.DisabledForeColor = RGB(0,0,0)
 		ENDIF
 		lp_cMessage = lp_cMessage + ';'
 		FOR l_n = 1 TO OCCURS(';', lp_cMessage)
 			l_cLine = SUBSTR(lp_cMessage, 1, AT(';', lp_cMessage)-1)+CHR(13)+CHR(10)
 			lp_cMessage = SUBSTR(lp_cMessage, AT(';', lp_cMessage)+1,LEN(lp_cMessage))
 			.SelText = l_cLine
 			IF NOT EMPTY(lp_lWidth)
	 			.w = lp_lWidth
 			ELSE
	 			.w = MAX(.w, l_oDlg.TextWidth(l_cLine)+10)
	 		ENDIF
 		ENDFOR
 		.SelStart = 0
		.h = MAX(.h, l_oDlg.TextHeight(.Text))
 		l_nHeight = MAX(l_nHeight, .h)
	 	l_nLeft = l_nLeft + .w + 10
 	ENDWITH
 ENDIF
 l_oDlg.w = l_nLeft
 l_nTop = l_nTop + l_nHeight
 IF NOT EMPTY(lp_cButtons)
 	lp_cButtons = lp_cButtons + ";"
 	l_nButtonCount = OCCURS(";", lp_cButtons)
 	l_oDlg.w = MAX(l_oDlg.w, l_nButtonCount*96+20)
 	l_nLeft = (l_oDlg.w - l_nButtonCount*96) / 2 + 6
	FOR l_n = 1 TO l_nButtonCount
		l_cLine = SUBSTR(lp_cButtons, 1, AT(";", lp_cButtons)-1)
	 	lp_cButtons = SUBSTR(lp_cButtons, AT(";", lp_cButtons)+1, LEN(lp_cButtons))
	 	WITH l_oDlg.AddControl("btn"+ALLTRIM(STR(l_n)),"lcommandbutton", l_nLeft, l_nTop)
	 		.w = 84
	 		.h = 24
	 		.Caption = l_cLine
	 		.nButtonNo = l_n
	 		l_nLeft = l_nLeft + 96
	 	ENDWITH
	ENDFOR
	l_nTop = l_nTop + 34
 ENDIF
 l_oDlg.h = MAX(80,l_nTop)
 l_oDlg.Height = l_oDlg.h
 l_oDlg.Width = l_oDlg.w
 l_oDlg.Resize()
 l_oDlg.AutoCenter = .T.
 l_oDlg.show(1)
 l_nRet = l_oDlg.nButtonNo
 l_oDlg.Release()
 RETURN l_nRet
* 
DEFINE CLASS lform AS tform
 nButtonNo = 0
 BorderStyle = 2
 FUNCTION AddControl
 	LPARAMETERS lp_cName, lp_cClass, lp_nLeft, lp_nTop
 	LOCAL l_oRet
 	this.AddObject(lp_cName, lp_cClass)
 	l_oRet = EVALUATE("this."+lp_cName)
 	l_oRet.l = lp_nLeft
 	l_oRet.t = lp_nTop
 	l_oRet.Visible = .T.
 	RETURN l_oRet
 ENDPROC
ENDDEFINE
*
DEFINE CLASS lcommandbutton AS tcommandbutton
 nButtonNo = -1
 PROCEDURE click
 	thisform.nButtonNo = this.nButtonNo
 	thisform.Hide()
 ENDPROC
ENDDEFINE
*