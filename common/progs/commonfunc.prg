#DEFINE CF_PSQL_EMPTY_DATE		{^1611/11/11}
#DEFINE CF_PSQL_EMPTY_DATETIME	{^1611/11/11 11:11:11}
#DEFINE CRLF					CHR(13)+CHR(10)
#DEFINE CF_ENCRYPT_MAIN_KEY		"NeKDGRUFmLA4LmOHE3NMLaTmI2lNbEWW"
*
FUNCTION CFCleanSTring
LPARAMETERS tcString
LOCAL lcBadChars

* Add to string 'lcBadChars' non printable characters.
lcBadChars = CHR(19)
tcString = CHRTRAN(tcString, lcBadChars, "")

RETURN tcString
ENDFUNC
*
PROCEDURE CFCleanRecordText
LPARAMETERS toRecord, tcOnlyFields, tcExcludeFields
LOCAL i, lcField
LOCAL ARRAY laFields(1)

FOR i = 1 TO AMEMBERS(laFields, toRecord)
	lcField = laFields(i)
	DO CASE
		CASE TYPE("toRecord."+lcField) <> "C"
		CASE NOT EMPTY(tcOnlyFields) AND NOT LOWER(","+lcField+",") $ LOWER(","+tcOnlyFields+",")
		CASE NOT EMPTY(tcExcludeFields) AND LOWER(","+lcField+",") $ LOWER(","+tcExcludeFields+",")
		OTHERWISE
			toRecord.&lcField = CFCleanSTring(toRecord.&lcField)
	ENDCASE
NEXT
ENDPROC
*
FUNCTION CFCalcInterval
LPARAMETERS tcCode, tdDate, ttBegin, ttEnd, tnBegin, tnEnd
LOCAL lnBegin, lnEnd

DO CASE
	CASE EMPTY(tcCode) OR EMPTY(tdDate) OR ISNULL(ttBegin) OR ISNULL(ttEnd)
		RETURN 0
	CASE tcCode = "NIGHT" AND VARTYPE(tnBegin) = "N" AND VARTYPE(tnEnd) = "N"
		IF tnBegin <= 8
			tnBegin = tnBegin + 24
		ENDIF
		IF tnEnd <= 8
			tnEnd = tnEnd + 24
		ENDIF
		lnBegin = MAX(0, tnBegin - 24)
		lnEnd = MAX(0, tnEnd - 24)
		RETURN MAX(0, MIN(ttEnd, DTOT(tdDate)+lnEnd*3600) - MAX(ttBegin, DTOT(tdDate)+lnBegin*3600)) + ;
			MAX(0, MIN(ttEnd, DTOT(tdDate)+tnEnd*3600) - MAX(ttBegin, DTOT(tdDate)+tnBegin*3600))
	OTHERWISE
		RETURN 0
ENDCASE
ENDFUNC
*
PROCEDURE WinExecute
LPARAMETERS lp_cFile, lp_nShowMode
LOCAL l_nRet, l_cSysDir, l_cRun, l_cParameters
IF PCOUNT() < 2
	lp_nShowMode = 1
ENDIF
DECLARE INTEGER GetDesktopWindow IN user32.dll
DECLARE INTEGER GetSystemDirectory IN kernel32.dll STRING @, INTEGER
DECLARE INTEGER ShellExecute IN shell32.dll INTEGER, STRING @, STRING @, STRING @, STRING @, INTEGER
l_nRet = ShellExecute(GetDesktopWindow(), "Open", @lp_cFile, "", "", lp_nShowMode)
IF l_nRet = 31
	l_cSysDir = SPACE(260)
	l_nRet = GetSystemDirectory(@l_cSysDir, LEN(l_cSysDir))
	l_cSysDir = LEFT(l_cSysDir, l_nRet)
	l_cRun = "Rundll32.exe"
	l_cParameters = "Shell32.dll, OpenAs_RunDLL "
	l_nRet = ShellExecute(GetDesktopWindow(), "Open", "Rundll32.exe", l_cParameters + lp_cFile, l_cSysDir, lp_nShowMode)
ENDIF
ENDPROC
*
#DEFINE LOCALE_SYSTEM_DEFAULT		0x800
#DEFINE LOCALE_USER_DEFAULT		0x400
#DEFINE LOCALE_ILANGUAGE			0x1 
#DEFINE LANG_ENGLISH			0x09
#DEFINE LANG_GERMAN				0x07
#DEFINE LANG_SERBIAN			0x1A
*
FUNCTION DatePickerSize
LPARAMETERS tnAttrib
LOCAL lnRetVal, lnFontRatio, lcLocaleInfo

IF TYPE("_screen.nPrimaryLangID") <> "N"
	DECLARE INTEGER GetLocaleInfo IN Win32API INTEGER, INTEGER, STRING @, INTEGER
	lcLocaleInfo = REPLICATE(CHR(0),5)
	GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_ILANGUAGE, @lcLocaleInfo, LEN(lcLocaleInfo))
	_screen.AddProperty("nPrimaryLangID", BITAND(EVALUATE("0x" + STRTRAN(lcLocaleInfo, CHR(0))), 0x3FF))
ENDIF
lnFontRatio = GetDPI()
* Windows 7/10
*	DPI		  ENG	  GER	  SER	  Min.
*  96(100%)	194x178	173x178	166x178	126x32
* 120(125%)	236x208	187x208	187x208	152x39
* 144(150%)	278x238	215x238	229x238	188x49	DPI-aware		DECLARE INTEGER SetProcessDPIAware IN Win32API;	SetProcessDPIAware()
*  96(150%)	194x178	173x178	166x178	188x49
*
* Windows 8
*	DPI		  ENG	  GER	  SER	  Min.
*  96(100%)	194x178	173x178	187x178	134x33
* 120(125%)	236x208	187x208	215x208	172x41
* 144(150%)	278x238	215x238	264x238	204x50	DPI-aware		DECLARE INTEGER SetProcessDPIAware IN Win32API;	SetProcessDPIAware()
*  96(150%)	194x178	173x178	187x178	204x50
DO CASE
	CASE tnAttrib = 1
		* Height Value
		DO CASE
			CASE lnFontRatio < 168				&&         x < 175%
				lnRetVal = 5/4 * lnFontRatio + 58
			CASE lnFontRatio > 167				&& 175% <= x
				lnRetVal = 2 * lnFontRatio - 66
		ENDCASE
	CASE tnAttrib = 2
		* Width Value
		DO CASE
			CASE lnFontRatio < 96				&&         x < 100%
				lnRetVal = 7/6 * lnFontRatio + 61
			CASE BETWEEN(lnFontRatio, 96, 119)	&& 100% <= x < 125%
				lnRetVal = 7/12 * lnFontRatio + ICASE(_screen.nPrimaryLangID = LANG_GERMAN, 117, _screen.nPrimaryLangID = LANG_SERBIAN, IIF(GetOsVersion() = "Win8", 131, 110), 138)
			CASE BETWEEN(lnFontRatio, 120, 143)	&& 125% <= x < 150%
				lnRetVal = 7/6 * lnFontRatio + ICASE(_screen.nPrimaryLangID = LANG_GERMAN, 47, _screen.nPrimaryLangID = LANG_SERBIAN, IIF(GetOsVersion() = "Win8", 75, 47), 96)
			CASE BETWEEN(lnFontRatio, 144, 167)	&& 150% <= x < 175%
				lnRetVal = 7/6 * lnFontRatio + ICASE(_screen.nPrimaryLangID = LANG_GERMAN, 47, _screen.nPrimaryLangID = LANG_SERBIAN, IIF(GetOsVersion() = "Win8", 96, 61), 110)
			CASE BETWEEN(lnFontRatio, 168, 191)	&& 175% <= x < 200%
				lnRetVal = 7/12 * lnFontRatio + 145
			CASE lnFontRatio > 191				&& 200% <= x
				lnRetVal = 7/6 * lnFontRatio + ICASE(_screen.nPrimaryLangID = LANG_GERMAN, 33, _screen.nPrimaryLangID = LANG_SERBIAN, 82, 145)
		ENDCASE
	OTHERWISE
		lnRetVal = 0
ENDCASE

RETURN INT(lnRetVal)
ENDFUNC
*
PROCEDURE GetDPI
#DEFINE LOGPIXELSX 88
DECLARE INTEGER GetDeviceCaps IN Win32API INTEGER hDC, INTEGER Item
DECLARE INTEGER GetDC IN Win32API INTEGER hWnd
DECLARE INTEGER ReleaseDC IN Win32API INTEGER hWnd, INTEGER hDC

LOCAL hDC, iScreenDPI

hDC = GetDC(0)
iScreenDPI = GetDeviceCaps(hDC, LOGPIXELSX)
ReleaseDC(0, hDC)

RETURN iScreenDPI
ENDPROC
*
PROCEDURE GetFileVersion
LPARAMETERS lp_cExeName, lp_lSpecial
LOCAL ARRAY l_aVersion(15)
LOCAL l_cVersion
l_cVersion = ""
IF TYPE("application.StartMode") = "N" AND application.StartMode = 4 AND ;
		TYPE("application.ServerName") = "C" AND NOT EMPTY(application.ServerName)
	= AGETFILEVERSION(l_aVersion, application.ServerName)
	l_cVersion = l_aVersion(4)
	lp_lSpecial = ("Special" $ l_aVersion(3))
ELSE
	IF TYPE("application.ActiveProject.VersionNumber") = "C"
		l_cVersion = application.ActiveProject.VersionNumber
	ELSE
		IF NOT EMPTY(lp_cExeName) AND FILE(lp_cExeName)
			= AGETFILEVERSION(l_aVersion, lp_cExeName)
			l_cVersion = ALLTRIM(l_aVersion(4))
			lp_lSpecial = ("Special" $ l_aVersion(3))
		ENDIF
	ENDIF
ENDIF
RETURN l_cVersion
ENDPROC
*
PROCEDURE ControlRefresh
LPARAMETERS toForm, toControl
LOCAL loControl

IF PCOUNT() < 1
	IF TYPE("_screen.ActiveForm") = "O"
		toForm = _screen.ActiveForm
	ELSE
		RETURN .F.
	ENDIF
ENDIF
IF PCOUNT() < 2
	IF VARTYPE(toForm) # "O"
		RETURN .F.
	ENDIF
	IF TYPE("toForm.ActiveControl") = "O"
		toControl = toForm.ActiveControl
	ELSE
		toControl = toForm
	ENDIF
ENDIF

IF PEMSTATUS(toControl, "SetFocus", 5) AND toControl.Enabled AND toControl.BaseClass <> "Grid"
	toControl.SetFocus()
	RETURN .T.
ENDIF

DO CASE
	CASE PCOUNT() < 2 AND toControl <> toForm
		RETURN ControlRefresh(toForm, toForm)
	CASE TYPE("toForm.ActiveControl") = "O" AND toControl = toForm.ActiveControl
	CASE INLIST(toControl.BaseClass, "Form", "Container", "Control", "ToolBar")
		FOR EACH loControl IN toControl.Controls
			IF ControlRefresh(toForm, loControl)
				RETURN .T.
			ENDIF
		NEXT
	CASE toControl.BaseClass == "PageFrame"
		FOR EACH loControl IN toControl.Pages
			IF ControlRefresh(toForm, loControl)
				RETURN .T.
			ENDIF
		NEXT
	CASE INLIST(toControl.BaseClass, "CommandGroup", "OptionGroup")
		FOR EACH loControl IN toControl.Buttons
			IF ControlRefresh(toForm, loControl)
				RETURN .T.
			ENDIF
		NEXT
ENDCASE

RETURN .F.
ENDPROC
*
PROCEDURE ControlSetFocus
LPARAMETERS toControl, tlAnyClass
LOCAL lnControl, loControl, lnActivePage

IF tlAnyClass AND PEMSTATUS(toControl,"SetFocus",5) OR INLIST(toControl.BaseClass, "Textbox", "Grid")
	toControl.SetFocus()
	RETURN .T.
ENDIF
IF PEMSTATUS(toControl,"ControlCount",5)
	FOR lnControl = 1 TO toControl.ControlCount
		IF VARTYPE(toControl.Controls(lnControl)) = "O" AND ControlSetFocus(toControl.Controls(lnControl), tlAnyClass)
			RETURN .T.
		ENDIF
	NEXT
ENDIF
IF PEMSTATUS(toControl,"PageCount",5)
	lnActivePage = toControl.ActivePage
	* Select on ActivePage first.
	IF VARTYPE(toControl.Pages(lnActivePage)) = "O" AND ControlSetFocus(toControl.Pages(lnActivePage), tlAnyClass)
		RETURN .T.
	ENDIF
	FOR lnControl = 1 TO toControl.PageCount
		IF toControl.ActivePage <> lnActivePage AND VARTYPE(toControl.Pages(lnControl)) = "O" AND ControlSetFocus(toControl.Pages(lnControl), tlAnyClass)
			RETURN .T.
		ENDIF
	NEXT
ENDIF
IF PEMSTATUS(toControl,"ButtonCount",5)
	FOR lnControl = 1 TO toControl.ButtonCount
		IF VARTYPE(toControl.Buttons(lnControl)) = "O" AND ControlSetFocus(toControl.Buttons(lnControl), tlAnyClass)
			RETURN .T.
		ENDIF
	NEXT
ENDIF

RETURN .F.
ENDPROC
*
FUNCTION CalculateFontSize
LPARAMETERS toForm, tcText, tnHeight, tnWidth
LOCAL i, lnFontSize, lnFormFontSize, lcText

lnFormFontSize = toForm.FontSize
toForm.FontSize = MIN(MAX(INT(tnHeight * 2/3), 4), 127)
FOR i = 1 TO GETWORDCOUNT(tcText, CRLF)
	lcText = GETWORDNUM(tcText, i, CRLF)
	DO WHILE toForm.TextWidth(lcText) > tnWidth AND toForm.FontSize > 4
		toForm.FontSize = toForm.FontSize - 1
	ENDDO
NEXT
lnFontSize = toForm.FontSize
toForm.FontSize = lnFormFontSize

RETURN lnFontSize
ENDFUNC
*
FUNCTION GetAErrorText
LOCAL ctext, i
LOCAL ARRAY aErrorData(1)
AERROR(aErrorData)
ctext = ""
FOR i = 1 TO ALEN(aErrorData)
	ctext = ctext + TRANSFORM(aErrorData(i)) + CHR(13)
ENDFOR
RETURN ctext
ENDFUNC
*
PROCEDURE LogData
LPARAMETERS tcMessage, tcFile, tlOverwrite
IF EMPTY(tcFile)
	tcFile = "App.log"
ENDIF
STRTOFILE(tcMessage+CHR(13)+CHR(10), tcFile, NOT tlOverwrite)
ENDPROC
*
FUNCTION Hex
LPARAMETERS tnExpression, tlDelimited
LOCAL lcExpression, i, lcDelimiter
LOCAL ARRAY laHexDigits(16)

laHexDigits(1) = "0"
laHexDigits(2) = "1"
laHexDigits(3) = "2"
laHexDigits(4) = "3"
laHexDigits(5) = "4"
laHexDigits(6) = "5"
laHexDigits(7) = "6"
laHexDigits(8) = "7"
laHexDigits(9) = "8"
laHexDigits(10) = "9"
laHexDigits(11) = "A"
laHexDigits(12) = "B"
laHexDigits(13) = "C"
laHexDigits(14) = "D"
laHexDigits(15) = "E"
laHexDigits(16) = "F"
lcExpression = ""
lcDelimiter = " "
i = MOD(tnExpression,16)
DO WHILE LEN(lcExpression) < 2 OR i > 0 OR tnExpression > 0
	lcExpression = laHexDigits(i+1) + IIF(tlDelimited AND MOD(LEN(lcExpression),3)=2, lcDelimiter, "") + lcExpression
	tnExpression = INT(tnExpression/16)
	i = MOD(tnExpression,16)
ENDDO
RETURN lcExpression
ENDFUNC
*
FUNCTION ColorToStr
LPARAMETERS tnColor
LOCAL lcColor, lnRed, lnGreen, lnBlue

lnRed = BITAND(tnColor,RGB(255,0,0))
lnGreen = BITRSHIFT(BITAND(tnColor,RGB(0,255,0)),8)
lnBlue = BITRSHIFT(BITAND(tnColor,RGB(0,0,255)),16)
lcColor = TRANSFORM(lnRed)+","+TRANSFORM(lnGreen)+","+TRANSFORM(lnBlue)

RETURN lcColor
ENDFUNC
*
FUNCTION HexToStr
LPARAMETERS tcMessage
LOCAL i, lcMsgConv, lcAsc
tcMessage = STRTRAN(tcMessage," ")
lcMsgConv = ""
FOR i = 1 TO INT(LEN(tcMessage)/2)
	lcAsc = "0x" + SUBSTR(tcMessage,(i)*2-1,2)
	lcMsgConv = lcMsgConv + CHR(&lcAsc)
ENDFOR
RETURN lcMsgConv
ENDFUNC
*
FUNCTION StrToHex
LPARAMETERS tcMessage, tlDelimited
LOCAL i, lcMsgConv
lcMsgConv = ""
FOR i = 1 TO LEN(tcMessage)
	lcMsgConv = lcMsgConv + Hex(ASC(SUBSTR(tcMessage,i,1)),tlDelimited)
ENDFOR
RETURN lcMsgConv
ENDFUNC
*
FUNCTION StrToMsg
LPARAMETERS tcMessage, tvExp1, tvExp2, tvExp3, tvExp4, tvExp5, tvExp6, tvExp7, tvExp8, tvExp9, tvExp10, ;
	tvExp11, tvExp12, tvExp13, tvExp14, tvExp15, tvExp16, tvExp17, tvExp18, tvExp19, tvExp20
LOCAL i, lcI, lvExp, lcMessage, lcExpressionSought, lcReplacement

lcMessage = STRTRAN(tcMessage, ";", CRLF)

FOR i = 1 TO PCOUNT() - 1
	lcI = TRANSFORM(i)
	lvExp = EVALUATE("tvExp" + lcI)
	DO CASE
		CASE INLIST(VARTYPE(lvExp), "N", "Y")
			lcExpressionSought = "%n" + lcI
			lcReplacement = TRANSFORM(lvExp)
		CASE VARTYPE(lvExp) = "D"
			lcExpressionSought = "%d" + lcI
			lcReplacement = DTOC(lvExp)
		CASE VARTYPE(lvExp) = "T"
			lcExpressionSought = "%t" + lcI
			lcReplacement = TTOC(lvExp)
		OTHERWISE
			lcExpressionSought = "%s" + lcI
			lcReplacement = ALLTRIM(TRANSFORM(lvExp))
	ENDCASE
	lcMessage = STRTRAN(lcMessage, lcExpressionSought, lcReplacement, 1, 1)
ENDFOR

RETURN lcMessage
ENDFUNC
*
FUNCTION StrToSql
LPARAMETERS tcMessage, tvExp1, tvExp2, tvExp3, tvExp4, tvExp5, tvExp6, tvExp7, tvExp8, tvExp9, tvExp10, ;
	tvExp11, tvExp12, tvExp13, tvExp14, tvExp15, tvExp16, tvExp17, tvExp18, tvExp19, tvExp20
LOCAL i, llOdbc, lcI, lvExp, lcMessage, lcExpressionSought, lcReplacement, llForceVFP
llForceVFP = (CHR(3) $ tcMessage)
IF llForceVFP
	lcMessage = SUBSTR(tcMessage,2)
ELSE
	lcMessage = tcMessage
	llOdbc = .F.
	TRY
		llOdbc = Odbc() OR (TYPE("plExternalODBC")="L" AND plExternalODBC)
	CATCH
	ENDTRY
ENDIF
FOR i = 1 TO PCOUNT() - 1
	lcI = TRANSFORM(i)
	lvExp = EVALUATE("tvExp" + lcI)
	DO CASE
		CASE VARTYPE(lvExp) = "C"
			lcExpressionSought = "%s"
			IF llOdbc
				IF NOT lvExp == CHRTRAN(lvExp, "'\", "")
					lcReplacement = "$$" + lvExp + "$$"
				ELSE
					lcReplacement = "'" + lvExp + "'"
				ENDIF
			ELSE
				lcReplacement = "[" + lvExp + "]"
			ENDIF
		CASE INLIST(VARTYPE(lvExp), "N", "Y")
			lcExpressionSought = "%n"
			lcReplacement = STRTRAN(TRANSFORM(MTON(lvExp)),",",".")
			*IF llOdbc AND VARTYPE(lvExp) = "Y"
			*	lcReplacement = "'$" + lcReplacement + "'"
			*ENDIF
		CASE VARTYPE(lvExp) = "D"
			lcExpressionSought = "%d"
			IF llOdbc
				lcReplacement = IIF(EMPTY(lvExp), "'1611-11-11'", StrToMsg("'%n1-%n2-%n3'", YEAR(lvExp), MONTH(lvExp), DAY(lvExp)))
			ELSE
				lcReplacement = IIF(EMPTY(lvExp), "{}", StrToMsg("{^%n1-%n2-%n3}", YEAR(lvExp), MONTH(lvExp), DAY(lvExp)))
			ENDIF
		CASE VARTYPE(lvExp) = "T"
			lcExpressionSought = "%t"
			IF llOdbc
				lcReplacement = IIF(EMPTY(lvExp), "'1611-11-11 11:11:11'", StrToMsg("'%n1-%n2-%n3 %n4:%n5:%n6'", YEAR(lvExp), MONTH(lvExp), DAY(lvExp), HOUR(lvExp), MINUTE(lvExp), SEC(lvExp)))
			ELSE
				lcReplacement = IIF(EMPTY(lvExp), "{.. :}", StrToMsg("{^%n1-%n2-%n3,%n4:%n5:%n6}", YEAR(lvExp), MONTH(lvExp), DAY(lvExp), HOUR(lvExp), MINUTE(lvExp), SEC(lvExp)))
			ENDIF
		CASE VARTYPE(lvExp) = "L"
			lcExpressionSought = "%l"
			lcReplacement = IIF(lvExp, "1=1", "0=1")
		OTHERWISE
			LOOP
	ENDCASE
	lcMessage = STRTRAN(lcMessage, "%u"+lcI, lcReplacement, 1, 1)
	lcMessage = STRTRAN(lcMessage, lcExpressionSought+lcI, lcReplacement, 1, 1)
ENDFOR

RETURN lcMessage
ENDFUNC
*
FUNCTION StrToVfp
LPARAMETERS tcMessage, tvExp1, tvExp2, tvExp3, tvExp4, tvExp5, tvExp6, tvExp7, tvExp8, tvExp9, tvExp10, ;
	tvExp11, tvExp12, tvExp13, tvExp14, tvExp15, tvExp16, tvExp17, tvExp18, tvExp19, tvExp20
LOCAL lnParamNo, llOdbc, lcCallProc, lcMessage

tcMessage = CHR(3) + tcMessage

lcCallProc = "StrToSql(@tcMessage,"
FOR lnParamNo = 1 TO PCOUNT()-1
	lcCallProc = lcCallProc + IIF(lnParamNo = 1, "", ", ") + "@tvExp" + ALLTRIM(STR(lnParamNo))
NEXT
lcCallProc = lcCallProc + ")"
lcMessage = &lcCallProc

RETURN lcMessage
ENDFUNC
*
PROCEDURE StrRevert
LPARAMETERS tcStr
LOCAL i, lcString

lcString = ""
FOR i = 1 TO LEN(tcStr)
	lcString = SUBSTR(tcStr,i,1) + lcString
ENDFOR

RETURN lcString
ENDPROC
*
FUNCTION GetLongFileName
* Convert old 8.3 filenames to window's long filename
LPARAMETERS tcName
LOCAL lcBuffer, lnResult

lcBuffer = REPLICATE(CHR(0),512)
DECLARE INTEGER GetLongPathName IN Kernel32 STRING lpszShortPath, STRING @ lpszLongPath, INTEGER cchBuffer
lnResult = GetLongPathName(tcName, @lcBuffer, LEN(lcBuffer))

RETURN IIF(EMPTY(lnResult), tcName, LEFT(lcBuffer, lnResult))
ENDFUNC
*
FUNCTION JustFAttr
LPARAMETERS lp_cFileName
LOCAL l_cAttributes, l_nAttrValue

l_cAttributes = ""
l_nAttrValue = GetFileAttributes(lp_cFileName)
IF l_nAttrValue >= 0
	IF BITTEST(l_nAttrValue, 0)
		l_cAttributes = l_cAttributes + "R"
	ENDIF
	IF BITTEST(l_nAttrValue, 5)
		l_cAttributes = l_cAttributes + "A"
	ENDIF
	IF BITTEST(l_nAttrValue, 1)
		l_cAttributes = l_cAttributes + "H"
	ENDIF
	IF BITTEST(l_nAttrValue, 2)
		l_cAttributes = l_cAttributes + "S"
	ENDIF
ENDIF

RETURN l_cAttributes
ENDFUNC
*
PROCEDURE SetFAttr
LPARAMETERS lp_cFileName, lp_cAttributes
LOCAL l_nAttrValue, l_nOldAttrValue

l_nOldAttrValue = GetFileAttributes(lp_cFileName)
l_nAttrValue = l_nOldAttrValue
IF l_nAttrValue >= 0
	IF "R" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITSET(l_nAttrValue, 0)
	ENDIF
	IF "A" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITSET(l_nAttrValue, 5)
	ENDIF
	IF "H" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITSET(l_nAttrValue, 1)
	ENDIF
	IF "S" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITSET(l_nAttrValue, 2)
	ENDIF
	IF l_nAttrValue <> l_nOldAttrValue
		SetFileAttributes(lp_cFileName, l_nAttrValue)
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE ClearFAttr
LPARAMETERS lp_cFileName, lp_cAttributes
LOCAL l_nAttrValue, l_nOldAttrValue

l_nOldAttrValue = GetFileAttributes(lp_cFileName)
l_nAttrValue = l_nOldAttrValue
IF l_nAttrValue >= 0
	IF "R" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITCLEAR(l_nAttrValue, 0)
	ENDIF
	IF "A" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITCLEAR(l_nAttrValue, 5)
	ENDIF
	IF "H" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITCLEAR(l_nAttrValue, 1)
	ENDIF
	IF "S" $ UPPER(lp_cAttributes)
		l_nAttrValue = BITCLEAR(l_nAttrValue, 2)
	ENDIF
	IF l_nAttrValue <> l_nOldAttrValue
		SetFileAttributes(lp_cFileName, l_nAttrValue)
	ENDIF
ENDIF
ENDPROC
*
FUNCTION LastDay
LPARAMETERS lp_dDate
RETURN DAY(DATE(YEAR(lp_dDate),MOD(MONTH(lp_dDate),12)+1,1)-1)
ENDFUNC
*
FUNCTION GetRelDate
LPARAMETERS lp_dDate, lp_cRelMonth, lp_nDay
LOCAL l_dDate, l_nAddMonths, l_nAddYears

IF EMPTY(lp_dDate)
	l_dDate = {}
ELSE
	lp_cRelMonth = UPPER(EVL(lp_cRelMonth,""))
	DO CASE
		CASE "M" $ lp_cRelMonth
			l_nAddMonths = INT(VAL(STREXTRACT(lp_cRelMonth,"","M")))
		CASE "Y" $ lp_cRelMonth
			l_nAddMonths = 12*INT(VAL(STREXTRACT(lp_cRelMonth,"","Y")))
		OTHERWISE
			l_nAddMonths = 0
	ENDCASE

	l_nMonths = 12*YEAR(lp_dDate)+MONTH(lp_dDate)-1+l_nAddMonths
	l_dDate = DATE(INT(l_nMonths/12), MOD(l_nMonths,12)+1, 1)

	lp_nDay = MIN(EVL(MAX(0,EVL(lp_nDay,0)),DAY(lp_dDate)), LastDay(l_dDate))
	l_dDate = DATE(YEAR(l_dDate), MONTH(l_dDate), lp_nDay)
ENDIF

RETURN l_dDate
ENDFUNC
*
FUNCTION Secs
LPARAMETERS lp_tTime

RETURN lp_tTime-DTOT(TTOD(lp_tTime))
ENDFUNC
*
FUNCTION DayParts
LPARAMETERS lp_cFromTime, lp_cToTime, lp_cArrDate, lp_cDepDate, lp_dDate, lp_cPaAlias
LOCAL l_nParts, l_nArrHours, l_nDepHours, l_nArrDayPart, l_nDepDayPart

lp_cPaAlias = EVL(lp_cPaAlias, "param")
lp_cFromTime = IIF(EMPTY(lp_cFromTime), "  :  ", lp_cFromTime)
lp_cToTime = IIF(EMPTY(lp_cToTime), "  :  ", lp_cToTime)
lp_dDate = IIF(NOT EMPTY(lp_dDate) AND BETWEEN(lp_dDate, lp_cArrDate, lp_cDepDate), lp_dDate, {})
l_nArrHours = ROUND((VAL(SUBSTR(lp_cFromTime, 1, 2))*3600 + VAL(SUBSTR(lp_cFromTime, 4, 2))*60)/3600, 0)
l_nDepHours = ROUND((VAL(SUBSTR(lp_cToTime, 1, 2))*3600 + VAL(SUBSTR(lp_cToTime, 4, 2))*60)/3600, 0)
DO CASE
	CASE BETWEEN(l_nArrHours, 0, &lp_cPaAlias..pa_dayprt1-1)
		l_nArrDayPart = 1
	CASE BETWEEN(l_nArrHours, &lp_cPaAlias..pa_dayprt1, &lp_cPaAlias..pa_dayprt2-1)
		l_nArrDayPart = 2
	CASE BETWEEN(l_nArrHours, &lp_cPaAlias..pa_dayprt2, 24)
		l_nArrDayPart = 3
ENDCASE
DO CASE
	CASE BETWEEN(l_nDepHours, 0, &lp_cPaAlias..pa_dayprt1-1)
		l_nDepDayPart = 1
	CASE BETWEEN(l_nDepHours, &lp_cPaAlias..pa_dayprt1, &lp_cPaAlias..pa_dayprt2-1)
		l_nDepDayPart = 2
	CASE BETWEEN(l_nDepHours, &lp_cPaAlias..pa_dayprt2, 24)
		l_nDepDayPart = 3
ENDCASE
l_nParts = MAX(1,(lp_cDepDate-lp_cArrDate)*3 + (l_nDepDayPart-l_nArrDayPart) + IIF(l_nArrHours=l_nDepHours, 0, 1))
IF NOT EMPTY(lp_dDate)
	DO CASE
		CASE lp_dDate = lp_cArrDate
			l_nParts = MIN(l_nParts, 4-l_nArrDayPart)
		CASE lp_dDate = lp_cDepDate
			l_nParts = MIN(l_nParts, l_nDepDayPart)
		OTHERWISE
			l_nParts = 3
	ENDCASE
ENDIF

RETURN l_nParts
ENDFUNC
*
FUNCTION Hours
LPARAMETERS lp_cFromTime, lp_cToTime, lp_dStartDate, lp_dEndDate, lp_dDate
LOCAL l_nHours, l_tFromTime, l_tToTime

l_tFromTime = CTOT(DTOC(lp_dStartDate) + IIF(EMPTY(lp_cFromTime), "", " " + lp_cFromTime))
l_tToTime = CTOT(DTOC(lp_dEndDate) + IIF(EMPTY(lp_cToTime), "", " " + lp_cToTime))

lp_dDate = IIF(NOT EMPTY(lp_dDate) AND BETWEEN(lp_dDate, lp_dStartDate, lp_dEndDate), lp_dDate, {})

l_nHours = MAX(0,(l_tToTime-l_tFromTime)/3600)
DO CASE
	CASE EMPTY(lp_dDate)
	CASE lp_dDate = lp_dStartDate
		l_nHours = MIN(l_nHours, (DTOT(lp_dStartDate+1)-l_tFromTime)/3600)
	CASE lp_dDate = lp_dEndDate
		l_nHours = MIN(l_nHours, (l_tToTime-DTOT(lp_dEndDate))/3600)
	OTHERWISE
		l_nHours = 24
ENDCASE
IF ROUND(l_nHours,4) = ROUND(l_nHours,0)
	l_nHours = ROUND(l_nHours,0)
ENDIF

RETURN l_nHours
ENDFUNC
*
FUNCTION Months
LPARAMETERS lp_dStartDate, lp_dEndDate, lp_dDate
LOCAL l_nMonths

lp_dDate = IIF(NOT EMPTY(lp_dDate) AND BETWEEN(lp_dDate, lp_dStartDate, lp_dEndDate), lp_dDate, {})

l_nMonths = MAX(0, YEAR(lp_dEndDate)*12+MONTH(lp_dEndDate)+DAY(lp_dEndDate)/LastDay(lp_dEndDate)-(YEAR(lp_dStartDate)*12+MONTH(lp_dStartDate)+DAY(lp_dStartDate)/LastDay(lp_dStartDate)))
DO CASE
	CASE EMPTY(lp_dDate)
	CASE MONTH(lp_dDate) = MONTH(lp_dStartDate)
		l_nMonths = MIN(l_nMonths, 1 - DAY(lp_dStartDate)/LastDay(lp_dStartDate))
	CASE MONTH(lp_dDate) = MONTH(lp_dEndDate)
		l_nMonths = MIN(l_nMonths, DAY(lp_dEndDate)/LastDay(lp_dEndDate))
	OTHERWISE
		l_nMonths = 1
ENDCASE

RETURN l_nMonths
ENDFUNC
*
FUNCTION STOT
LPARAMETERS lp_cDateTime
IF LEN(lp_cDateTime) = 8
	RETURN DATE(VAL(LEFT(lp_cDate,4)), VAL(SUBSTR(lp_cDate,5,2)), VAL(SUBSTR(lp_cDate,7,2)))
ELSE
	RETURN DATETIME(VAL(LEFT(lp_cDate,4)), VAL(SUBSTR(lp_cDate,5,2)), VAL(SUBSTR(lp_cDate,7,2)), VAL(SUBSTR(lp_cDate,9,2)), VAL(SUBSTR(lp_cDate,11,2)), VAL(SUBSTR(lp_cDate,13,2)))
ENDIF
ENDFUNC
*
FUNCTION GetTime
LPARAMETERS lp_tDateTime

RETURN LEFT(TTOC(lp_tDateTime,2),5)
ENDFUNC
*
FUNCTION Time2Num
LPARAMETERS lp_cTime
IF OCCURS(":", lp_cTime) = 2
	RETURN VAL(STREXTRACT(lp_cTime, "", ":"))*3600 + VAL(STREXTRACT(lp_cTime, ":", ":"))*60 + VAL(STREXTRACT(lp_cTime, ":", "",2))
ELSE
	RETURN VAL(STREXTRACT(lp_cTime, "", ":"))*60 + VAL(STREXTRACT(lp_cTime, ":", ""))
ENDIF
ENDFUNC
*
FUNCTION Num2Time
LPARAMETERS lp_nNum, lp_nFormat, lp_lDummy
* If this function a control source of grid, must be passed third parameter
* lp_nFormat = 5	&&  hh:mm
* lp_nFormat = 6	&& hhh:mm
* lp_nFormat = 8	&&  hh:mm:ss
* lp_nFormat = 9	&& hhh:mm:ss
lp_nNum = INT(lp_nNum)
IF lp_nFormat > 7
	RETURN PADL(INT(lp_nNum/3600),lp_nFormat-6,"0")+":"+PADL(MOD(INT(lp_nNum/60),60),2,"0")+":"+PADL(MOD(lp_nNum,60),2,"0")
ELSE
	RETURN PADL(INT(lp_nNum/60),lp_nFormat-3,"0")+":"+PADL(MOD(lp_nNum,60),2,"0")
ENDIF
ENDFUNC
*
PROCEDURE Time2Ticks
* The value of ticks is the number of 100-nanosecond intervals that have elapsed since 12:00 AM, January 1, 0001.
LPARAMETERS lp_tMoment
LOCAL l_nMilisec
l_nMilisec = 0
DO CASE
	CASE PCOUNT() = 0
		lp_tMoment = DATETIME()
		l_nMilisec = MOD(SECONDS(),1)
	CASE VARTYPE(lp_tMoment) = "D"
		lp_tMoment = DTOT(lp_tMoment)
	CASE VARTYPE(lp_tMoment) = "T"
	OTHERWISE
		RETURN 0
ENDCASE
RETURN (lp_tMoment - DTOT(CTOD("01.01.0001")) + l_nMilisec) * 10000000
ENDPROC
*
PROCEDURE Ticks2Time
LPARAMETERS lp_ticks
RETURN DTOT(CTOD("01.01.0001")) + lp_ticks / 10000000
ENDPROC
*
FUNCTION Sec2Time
LPARAMETERS lp_nNum
LOCAL lcTime, lnDays, lnHours, lnMinutes, lnSeconds, lnSecondParts

lnDays = INT(lp_nNum/86400)
lnHours = MOD(INT(lp_nNum/3600),24)
lnMinutes = MOD(INT(lp_nNum/60),60)
lnSeconds = MOD(INT(lp_nNum),60)
lnSecondParts = MOD(lp_nNum,1)
lcTime = ""
IF NOT EMPTY(lcTime) OR lnDays > 0
	lcTime = lcTime + TRANSFORM(lnDays,"999d ")
ENDIF
IF NOT EMPTY(lcTime) OR lnHours > 0
	lcTime = lcTime + PADL(lnHours,2,"0")+":"
ENDIF
IF NOT EMPTY(lcTime) OR lnMinutes > 0
	lcTime = lcTime + PADL(lnMinutes,2,"0")+":"
ENDIF
lcTime = lcTime + PADL(lnSeconds,2,"0") + TRANSFORM(lnSecondParts,".999")

RETURN lcTime
ENDFUNC
*
FUNCTION ConvSecToTime
LPARAMETERS lp_nSeconds, lp_nFormat, lp_lDummy
* lp_nFormat = 5	&&  hh:mm		(Default format)
* lp_nFormat = 6	&& hhh:mm
* lp_nFormat = 8	&&  hh:mm:ss
* lp_nFormat = 9	&& hhh:mm:ss
LOCAL l_cTime

IF EMPTY(lp_nFormat)
	lp_nFormat = 5		
ENDIF
IF lp_nSeconds < 0
	l_cTime = "-"
	lp_nSeconds = ABS(lp_nSeconds)
ELSE
	l_cTime = ""
ENDIF
IF lp_nFormat > 7
	l_cTime = l_cTime + Num2Time(lp_nSeconds, lp_nFormat)
ELSE
	l_cTime = l_cTime + Num2Time(INT(lp_nSeconds/60), lp_nFormat)
ENDIF

RETURN l_cTime
ENDFUNC
*
FUNCTION TimeValidate
LPARAMETERS lp_cTime
LOCAL l_nHours, l_nMins, l_lOK

l_nHours = INT(VAL(STREXTRACT(lp_cTime, "", ":")))
l_nMins = INT(VAL(STREXTRACT(lp_cTime, ":", "")))

l_lOK = BETWEEN(l_nHours, 0, 23) AND BETWEEN(l_nMins, 0, 59)
IF l_lOK
	lp_cTime = PADL(l_nHours,2,"0")+":"+PADL(l_nMins,2,"0")
ENDIF

RETURN l_lOK
ENDFUNC
*
FUNCTION StrHotKey
LPARAMETERS lp_cPrompt
LOCAL l_nPos, l_cHotKeyChar
l_nPos = AT('\<', lp_cPrompt)
l_cHotKeyChar = ""
IF l_nPos > 0
	l_cHotKeyChar = SUBSTR(lp_cPrompt, l_nPos + 2, 1)
ENDIF
RETURN l_cHotKeyChar
ENDFUNC
*
FUNCTION PasswordCode
LPARAMETERS lp_cPassword
RETURN SYS(2007, RTRIM(lp_cPassword))
ENDFUNC
*
PROCEDURE CallScript
LPARAMETERS tcCallProc, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10
LOCAL i, luRetVal, lcParams

lcParams = "tcCallProc"
FOR i = 1 TO PCOUNT()-1
	lcParams = lcParams + ", @p" + TRANSFORM(i)
NEXT

luRetVal = EXECSCRIPT(&lcParams)

RETURN luRetVal
ENDPROC
*
FUNCTION CallFunc
LPARAMETERS tcMacro, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10

RETURN &tcMacro
ENDFUNC
*
FUNCTION CallCmd
LPARAMETERS tlRetval, tcMacro, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10
LOCAL luRetVal

IF tlRetval
	luRetVal = &tcMacro
ELSE
	luRetVal = .T.
	&tcMacro
ENDIF

RETURN luRetVal
ENDFUNC
*
FUNCTION MakeCallProc
LPARAMETERS lp_cFuncName, lp_cParamName, lp_nParamCount
LOCAL l_cCallProc, l_cParamName, l_cParamLast, l_nParamNo, l_nWords, i

l_nWords = GETWORDCOUNT(lp_cParamName, ",")
l_cParamLast = ALLTRIM(GETWORDNUM(lp_cParamName, l_nWords, ","))
l_nParamNo = 0

l_cCallProc = lp_cFuncName + "("
FOR i = 1 TO lp_nParamCount
	l_cParamName = ALLTRIM(GETWORDNUM(lp_cParamName, i, ","))
	IF EMPTY(l_cParamName) OR l_nWords = 1 OR i = l_nWords AND i < lp_nParamCount
		l_nParamNo = l_nParamNo + 1
		l_cParamName = l_cParamLast + ALLTRIM(STR(l_nParamNo))
	ENDIF
	l_cCallProc = l_cCallProc + IIF(i = 1, "@", ", @") + l_cParamName
NEXT
l_cCallProc = l_cCallProc + ")"
 
RETURN l_cCallProc
ENDFUNC
*
FUNCTION MakeStructure
LPARAMETERS lp_cParams, lp_oStruct
LOCAL l_cProperty, l_nPropertyNo

IF VARTYPE(lp_oStruct) <> "O"
	lp_oStruct = CREATEOBJECT("Empty")
ENDIF
FOR l_nPropertyNo = 1 TO GETWORDCOUNT(lp_cParams, ",")
	l_cProperty = ALLTRIM(GETWORDNUM(lp_cParams, l_nPropertyNo, ","))
	IF PCOUNT() = 1 OR NOT PEMSTATUS(lp_oStruct, l_cProperty, 5)
		ADDPROPERTY(lp_oStruct, l_cProperty)
	ENDIF
NEXT

RETURN lp_oStruct
ENDFUNC
*
FUNCTION ParamObject
LPARAMETERS lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
LOCAL l_oParamObj, l_nParamNo
l_oParamObj = CREATEOBJECT("Empty")
FOR l_nParamNo = 1 TO PCOUNT()
	ADDPROPERTY(l_oParamObj, "uParam" + ALLTRIM(STR(l_nParamNo)), EVALUATE("lp_uParam" + ALLTRIM(STR(l_nParamNo))))
NEXT
RETURN l_oParamObj
ENDFUNC
*
FUNCTION ExtractParams
LPARAMETERS lp_oParamObj, lp_oParamObjName
LOCAL l_cParams, l_nParamNo
LOCAL ARRAY l_aParams(1)
l_cParams = ""
IF TYPE("lp_oParamObj") = "O"
	FOR l_nParamNo = 1 TO AMEMBERS(l_aParams, lp_oParamObj)
		l_cParams = l_cParams + IIF(EMPTY(l_cParams), "", ", ") + lp_oParamObjName + "." + LOWER(l_aParams(l_nParamNo))
	NEXT
ENDIF
RETURN l_cParams
ENDFUNC
*
FUNCTION ExtractFuncParams
LPARAMETERS lp_cString, lp_cFuncName, lp_cParamDelimiter
* lp_cFuncName - Function name +"("
LOCAL l_cParams, l_cString, l_nCounter, l_cParamDelimiter, l_nL, l_nR

l_cParams = ""

l_nL = AT(UPPER(lp_cFuncName), UPPER(lp_cString))		&& Function name could be case insensitive
IF l_nL > 0
	l_nCounter = 1
	l_cString = SUBSTR(lp_cString, l_nL + LEN(lp_cFuncName))
	DO WHILE l_nCounter > 0 AND LEN(l_cString) > 0
		l_nL = AT("(", l_cString)
		l_nR = AT(")", l_cString)
		l_cParamDelimiter = IIF(l_nCounter <> 1 OR EMPTY(lp_cParamDelimiter), "", lp_cParamDelimiter)
		DO CASE
			CASE l_nL > 0 AND (l_nR = 0 OR l_nL < l_nR)		&& (
				l_cParams = l_cParams + EFPSetParamDelimiter(LEFT(l_cString, l_nL), l_cParamDelimiter)
				l_cString = SUBSTR(l_cString, l_nL+1)
				l_nCounter = l_nCounter + 1
			CASE l_nR > 0 AND (l_nL = 0 OR l_nL > l_nR)		&& )
				l_cParams = l_cParams + EFPSetParamDelimiter(LEFT(l_cString, l_nR), l_cParamDelimiter)
				l_cString = SUBSTR(l_cString, l_nR+1)
				l_nCounter = l_nCounter - 1
			OTHERWISE
				l_cParams = l_cParams + EFPSetParamDelimiter(l_cString, l_cParamDelimiter)
				l_cString = ""
		ENDCASE
	ENDDO
	DO CASE
		CASE l_nCounter > 0
			l_cParams = ""
		CASE INLIST(RIGHT(l_cParams, 1), "(", ")")
			l_cParams = LEFT(l_cParams, LEN(l_cParams)-1)
		OTHERWISE
	ENDCASE
ENDIF

RETURN l_cParams
ENDFUNC
*
FUNCTION EFPSetParamDelimiter
LPARAMETERS lp_cString, lp_cParamDelimiter

IF NOT EMPTY(lp_cParamDelimiter)
	lp_cString = STRTRAN(lp_cString, ",", lp_cParamDelimiter)	&& Parameter delimiter is CHR(255)
ENDIF

RETURN lp_cString
ENDFUNC
*
FUNCTION Blank
LPARAMETERS lp_uExpr
LOCAL l_cType
l_cType = TYPE("lp_uExpr")
DO CASE
	CASE l_cType = "C"
		RETURN ""
	CASE l_cType = "N"
		RETURN 0
	CASE l_cType = "Y"
		RETURN NTOM(0)
	CASE l_cType = "D"
		RETURN CTOD("")
	CASE l_cType = "T"
		RETURN CTOT("")
	CASE l_cType = "L"
		RETURN .F.
ENDCASE
ENDFUNC
*
PROCEDURE LogChanges
LPARAMETERS tdWhen, tcWho, tcWhat, tuRecordNew, tuRecordOld, tcExcludeFields, tcOnlyFields
LOCAL i, lcChanges, lcField, lcFieldCaption, lcFieldMacro, lcRecordNew, lcRecordOld
LOCAL ARRAY laFields(1)

lcChanges = ""
IF tcWhat = "CHANGED"
	DO CASE
		CASE VARTYPE(tuRecordNew) = "O"
			AMEMBERS(laFields, tuRecordNew)
			lcFieldMacro = "laFields(i)"
			lcRecordNew = "tuRecordNew"
		CASE VARTYPE(tuRecordNew) = "C" AND NOT EMPTY(tuRecordNew) AND USED(tuRecordNew)
			AFIELDS(laFields, tuRecordNew)
			lcFieldMacro = "laFields(i,1)"
			lcRecordNew = tuRecordNew
		OTHERWISE
			RETURN ""
	ENDCASE
	DO CASE
		CASE VARTYPE(tuRecordOld) = "O"
			lcRecordOld = "tuRecordOld"
		CASE VARTYPE(tuRecordOld) = "C" AND NOT EMPTY(tuRecordOld) AND USED(tuRecordOld)
			lcRecordOld = tuRecordOld
		OTHERWISE
			RETURN ""
	ENDCASE

	FOR i = 1 TO ALEN(laFields, 1)
		lcField = &lcFieldMacro
		lcFieldCaption = PROPER(STREXTRACT(lcField,"_","",1,2))
		DO CASE
			CASE NOT EMPTY(tcOnlyFields) AND NOT LOWER(","+lcField+",") $ LOWER(","+tcOnlyFields+",")
			CASE NOT EMPTY(tcExcludeFields) AND LOWER(","+lcField+",") $ LOWER(","+tcExcludeFields+",")
			CASE TYPE(lcRecordNew+"."+lcField) = "U" OR TYPE(lcRecordOld+"."+lcField) = "U"
			CASE TYPE(lcRecordNew+"."+lcField) = "C"
				IF NOT (ALLTRIM(&lcRecordOld..&lcField) == ALLTRIM(&lcRecordNew..&lcField))
					lcChanges = lcChanges + IIF(EMPTY(lcChanges), "", ", ") + ;
						lcFieldCaption + " (" + ALLTRIM(&lcRecordOld..&lcField) + " -> " + ALLTRIM(&lcRecordNew..&lcField) + ")"
				ENDIF
			CASE TYPE(lcRecordNew+"."+lcField) = "T"
				IF &lcRecordOld..&lcField <> &lcRecordNew..&lcField
					lcChanges = lcChanges + IIF(EMPTY(lcChanges), "", ", ") + ;
						lcFieldCaption + " (" + LEFT(TTOC(&lcRecordOld..&lcField),16) + " -> " + LEFT(TTOC(&lcRecordNew..&lcField),16) + ")"
				ENDIF
			CASE TYPE(lcRecordNew+"."+lcField) = "L"
				IF &lcRecordOld..&lcField <> &lcRecordNew..&lcField
					lcChanges = lcChanges + IIF(EMPTY(lcChanges), "", ", ") + ;
						lcFieldCaption + " (" + IIF(&lcRecordOld..&lcField),"True","False") + " -> " + IIF(&lcRecordNew..&lcField),"True","False") + ")"
				ENDIF
			OTHERWISE
				IF &lcRecordOld..&lcField <> &lcRecordNew..&lcField
					lcChanges = lcChanges + IIF(EMPTY(lcChanges), "", ", ") + ;
						lcFieldCaption + " (" + TRANSFORM(&lcRecordOld..&lcField) + " -> " + TRANSFORM(&lcRecordNew..&lcField) + ")"
				ENDIF
		ENDCASE
	NEXT
ENDIF

lcChanges = ALLTRIM(DTOC(tdWhen) + " " + TIME() + " " +  + PADR(tcWho,12) + tcWhat + "  " + lcChanges)

RETURN lcChanges
ENDPROC
*
PROCEDURE RecordChanged
LPARAMETERS tuRecordNew, tuRecordOld, tcExcludeFields, tcOnlyFields
LOCAL i, lcField, lcFieldMacro, llChanged, lcRecordNew, lcRecordOld
LOCAL ARRAY laFields(1)

DO CASE
	CASE VARTYPE(tuRecordNew) = "O"
		AMEMBERS(laFields, tuRecordNew)
		lcFieldMacro = "laFields(i)"
		lcRecordNew = "tuRecordNew"
	CASE VARTYPE(tuRecordNew) = "C" AND NOT EMPTY(tuRecordNew) AND USED(tuRecordNew)
		AFIELDS(laFields, tuRecordNew)
		lcFieldMacro = "laFields(i,1)"
		lcRecordNew = tuRecordNew
	OTHERWISE
		RETURN .F.
ENDCASE
DO CASE
	CASE VARTYPE(tuRecordOld) = "O"
		lcRecordOld = "tuRecordOld"
	CASE VARTYPE(tuRecordOld) = "C" AND NOT EMPTY(tuRecordOld) AND USED(tuRecordOld)
		lcRecordOld = tuRecordOld
	OTHERWISE
		RETURN .F.
ENDCASE
FOR i = 1 TO ALEN(laFields, 1)
	lcField = &lcFieldMacro
	DO CASE
		CASE NOT EMPTY(tcOnlyFields) AND NOT LOWER(","+lcField+",") $ LOWER(","+tcOnlyFields+",")
		CASE NOT EMPTY(tcExcludeFields) AND LOWER(","+lcField+",") $ LOWER(","+tcExcludeFields+",")
		CASE TYPE(lcRecordNew+"."+lcField) = "U" OR TYPE(lcRecordOld+"."+lcField) = "U"
		CASE TYPE(lcRecordNew+"."+lcField) = "C"
			IF NOT (ALLTRIM(&lcRecordOld..&lcField) == ALLTRIM(&lcRecordNew..&lcField))
				llChanged = .T.
				EXIT
			ENDIF
		OTHERWISE
			IF &lcRecordOld..&lcField <> &lcRecordNew..&lcField
				llChanged = .T.
				EXIT
			ENDIF
	ENDCASE
NEXT

RETURN llChanged
ENDPROC
*
PROCEDURE RecordCopyObj
LPARAMETERS toRecord
LOCAL i, loRecord, lcField, lcFields
LOCAL ARRAY laMembers(1)

lcFields = ""
FOR i = 1 TO AMEMBERS(laMembers, toRecord)
	lcFields = lcFields + IIF(EMPTY(lcFields), "", ",") + LOWER(laMembers(i))
NEXT
loRecord = MakeStructure(lcFields)
FOR i = 1 TO ALEN(laMembers)
	lcField = LOWER(laMembers(i))
	loRecord.&lcField = toRecord.&lcField
NEXT

RETURN loRecord
ENDPROC
*
PROCEDURE CommitChanges
LPARAMETERS tcAlias
DO CASE
	CASE CURSORGETPROP("Buffering", tcAlias) > 3
		= TABLEUPDATE(.T., .T., tcAlias)
	CASE CURSORGETPROP("Buffering", tcAlias) = 3
		= TABLEUPDATE(.F., .T., tcAlias)
	OTHERWISE
ENDCASE
ENDPROC
*
PROCEDURE IsCursor
LPARAMETERS tcAlias

RETURN NOT JUSTEXT(DBF(tcAlias)) == "DBF"
ENDPROC
*
*** append string without word duplication
FUNCTION AddField
LPARAMETERS lp_cStr1, lp_cStr2, lp_cDelimiter
LOCAL l_nField, l_cField, l_cResult, l_nField2, l_cField2, l_lAdd, l_nPos
IF EMPTY(lp_cDelimiter)
	lp_cDelimiter = ","
ENDIF
l_cResult = lp_cStr1
FOR l_nField = 1 TO GETWORDCOUNT(lp_cStr2, lp_cDelimiter)
	l_cField = ALLTRIM(GETWORDNUM(lp_cStr2, l_nField, lp_cDelimiter))
	l_nPos = AT(" AS ", l_cField)
	IF l_nPos > 0
		l_cField = ALLTRIM(SUBSTR(l_cField, l_nPos + LEN(" AS ")))
	ENDIF
	IF EMPTY(l_cField)
		l_lAdd = .F.
	ELSE
		l_lAdd = .T.
		FOR l_nField2 = 1 TO GETWORDCOUNT(l_cResult, lp_cDelimiter)
			l_cField2 = ALLTRIM(GETWORDNUM(l_cResult, l_nField2, lp_cDelimiter))
			l_nPos = AT(" AS ", l_cField2)
			IF l_nPos > 0
				l_cField2 = ALLTRIM(SUBSTR(l_cField2, l_nPos + LEN(" AS ")))
			ENDIF
			IF LOWER(l_cField) == LOWER(l_cField2)
				l_lAdd = .F.
				EXIT
			ENDIF
		ENDFOR
	ENDIF
	IF l_lAdd
		IF NOT EMPTY(l_cResult)
			l_cResult = l_cResult + lp_cDelimiter
		ENDIF
		l_cResult = l_cResult + l_cField
	ENDIF
ENDFOR
RETURN l_cResult
ENDFUNC
*
FUNCTION CurToObj
LPARAMETERS tcurName
LOCAL i, loCursor, lnIndexCount

tcurName = EVL(tcurName,ALIAS())
IF NOT EMPTY(tcurName) AND USED(tcurName)
	loCursor = MakeStructure("curName, aContent(1), aStruct(1), aIndex(1)")
	loCursor.curName = tcurName
	SELECT * FROM (tcurName) INTO ARRAY loCursor.aContent
	AFIELDS(loCursor.aStruct, tcurName)
	lnIndexCount = TAGCOUNT()
	IF lnIndexCount > 0
		DIMENSION loCursor.aIndex(lnIndexCount,2)
		FOR i = 1 TO lnIndexCount
			loCursor.aIndex(i,1) = LOWER(KEY(i))
			loCursor.aIndex(i,2) = LOWER(TAG(i))
		NEXT
	ENDIF
ENDIF

RETURN loCursor
ENDFUNC
*
PROCEDURE ObjToCur
LPARAMETERS toCursor, tcurName

IF VARTYPE(toCursor) = "O"
	tcurName = EVL(tcurName,toCursor.curName)
	CREATE CURSOR (tcurName) FROM ARRAY toCursor.aStruct
	FOR i = 1 TO ALEN(toCursor.aIndex,1)
		IF NOT EMPTY(toCursor.aIndex(1))
			INDEX ON (toCursor.aIndex(i,1)) TAG (toCursor.aIndex(i,2))
		ENDIF
	NEXT
	INSERT INTO (tcurName) FROM ARRAY toCursor.aContent
ENDIF
ENDPROC
*
PROCEDURE CreateCursorFromArray
LPARAMETERS lp_cCursorName, lp_aFields
* Creates a cursor from array without any feature.
EXTERNAL ARRAY lp_aFields
LOCAL l_nFieldNo, l_nColumnNo

FOR l_nFieldNo = 1 TO ALEN(lp_aFields,1)
	FOR l_nColumnNo = 7 TO 16
		lp_aFields[l_nFieldNo, l_nColumnNo] = ""
	NEXT
NEXT

CREATE CURSOR (lp_cCursorName) FROM ARRAY lp_aFields
ENDPROC
*
PROCEDURE CursorAddField
LPARAMETERS lp_aFields, lp_cNewName, lp_cNewType, lp_nNewWidth, lp_nDecPlaces, lp_lNullValues
LOCAL l_nNewRow, l_nColumn
IF EMPTY(lp_aFields(1))
	l_nNewRow = 1
ELSE
	l_nNewRow = ALEN(lp_aFields, 1)+1
ENDIF
DIMENSION lp_aFields[l_nNewRow, ALEN(lp_aFields, 2)]
lp_aFields[l_nNewRow, 1] = lp_cNewName
lp_aFields[l_nNewRow, 2] = lp_cNewType
lp_aFields[l_nNewRow, 3] = lp_nNewWidth
lp_aFields[l_nNewRow, 4] = lp_nDecPlaces
lp_aFields[l_nNewRow, 5] = lp_lNullValues
lp_aFields[l_nNewRow, 6] = .F.
lp_aFields[l_nNewRow, 7] = ""
lp_aFields[l_nNewRow, 8] = ""
lp_aFields[l_nNewRow, 9] = ""
lp_aFields[l_nNewRow, 10] = ""
lp_aFields[l_nNewRow, 11] = ""
lp_aFields[l_nNewRow, 12] = ""
lp_aFields[l_nNewRow, 13] = ""
lp_aFields[l_nNewRow, 14] = ""
lp_aFields[l_nNewRow, 15] = ""
lp_aFields[l_nNewRow, 16] = ""
ENDPROC
*
PROCEDURE MakeDatesCursor
LPARAMETERS tdFromDate, tdToDate, tcFieldName, tcCursorName

tcFieldName = EVL(tcFieldName, "c_date")
RETURN MakeIntervalDataCursor(tdFromDate, tdToDate, tcFieldName, @tcCursorName)
ENDPROC
*
PROCEDURE MakeIntervalDataCursor
LPARAMETERS tuFrom, tuTo, tcFieldName, tcCursorName
LOCAL lcType
LOCAL ARRAY laData(tuTo-tuFrom+1,1)

tcCursorName = EVL(tcCursorName, SYS(2015))
lcType = TYPE("tuFrom")
IF lcType = "N"
	lcType = "I"
ENDIF

IF USED(tcCursorName)
	USE IN &tcCursorName
ENDIF

CREATE CURSOR &tcCursorName (&tcFieldName &lcType)
INSERT INTO &tcCursorName FROM ARRAY laData
REPLACE &tcFieldName WITH tuFrom+RECNO()-1 ALL IN &tcCursorName

RETURN tcCursorName
ENDPROC
*
PROCEDURE RemoveAliasFilter
LPARAMETERS lp_cAlias, lp_nRecNo, lp_cFilter

lp_nRecNo = RECNO(lp_cAlias)
lp_cFilter = FILTER(lp_cAlias)
IF NOT EMPTY(lp_cFilter)
	SET FILTER TO IN &lp_cAlias
ENDIF
ENDPROC
*
PROCEDURE RestoreAliasFilter
LPARAMETERS lp_cAlias, lp_nRecNo, lp_cFilter

IF NOT EMPTY(lp_cFilter)
	SET FILTER TO &lp_cFilter IN &lp_cAlias
ENDIF
GO lp_nRecNo IN &lp_cAlias
ENDPROC
*
FUNCTION AAdd
LPARAMETERS taArray, tcArrayPropertyName
LOCAL lnRows, lnCols, lcArray

lcArray = "taArray" + IIF(PCOUNT() = 2 AND VARTYPE(taArray) = "O", "." + tcArrayPropertyName, "")
lnRows = ALEN(&lcArray, 1) + 1
lnCols = ALEN(&lcArray, 2)
IF lnCols = 0
	DIMENSION &lcArray(lnRows)
ELSE
	DIMENSION &lcArray(lnRows, lnCols)
ENDIF

RETURN lnRows
ENDFUNC
*
FUNCTION GetListFromCursor
LPARAMETERS lp_cCursorName, lp_cFormat, lp_cFields, lp_cDelimiter
LOCAL l_cList, l_cSubstitute

IF EMPTY(lp_cDelimiter)
	lp_cDelimiter = ","
ENDIF

l_cList = ""
SELECT &lp_cCursorName
SCAN
	l_cSubstitute = "Str2Msg(lp_cFormat, " + lp_cFields + ")"
	l_cList = l_cList + IIF(EMPTY(l_cList), "", lp_cDelimiter) + &l_cSubstitute
ENDSCAN

RETURN l_cList
ENDFUNC
*
FUNCTION GetListFromParams
LPARAMETERS lp_cDelimiter, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, lp_uParam6, lp_uParam7, ;
	lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13, lp_uParam14, lp_uParam15
LOCAL i, l_cList, l_cParam

lp_cDelimiter = EVL(lp_cDelimiter,",")

l_cList = ""
FOR i = 1 TO PCOUNT()-1
	l_cParam = "lp_uParam" + TRANSFORM(i)
	IF NOT EMPTY(NVL(&l_cParam,""))
		l_cList = l_cList + IIF(EMPTY(l_cList), "", lp_cDelimiter) + ALLTRIM(TRANSFORM(&l_cParam))
	ENDIF
NEXT

RETURN l_cList
ENDFUNC
*
PROCEDURE ProperValue
LPARAMETERS lp_uValue, lp_uType
LOCAL l_cType
l_cType = TYPE("lp_uType")
RETURN CAST(lp_uValue AS &l_cType)
ENDPROC
*
FUNCTION ConvColors
LPARAMETERS lp_nColor, lp_nKoef
LOCAL l_nConvColor, l_nRed, l_nGreen, l_nBlue

l_nRed = BITAND(lp_nColor, 0xFF)
l_nGreen = BITAND(BITRSHIFT(lp_nColor,8), 0xFF)
l_nBlue = BITAND(BITRSHIFT(lp_nColor,16), 0xFF)

l_nRed = MIN(255, ROUND(l_nRed * lp_nKoef,0))
l_nGreen = MIN(255, ROUND(l_nGreen * lp_nKoef,0))
l_nBlue = MIN(255, ROUND(l_nBlue * lp_nKoef,0))

l_nConvColor = RGB(l_nRed, l_nGreen, l_nBlue)

RETURN l_nConvColor
ENDFUNC
*
PROCEDURE CFCursorNullsRemove
LPARAMETERS lp_lAllRecords, lp_cAlias, lp_lExternalODBC

* When null data or datetime is found, we must convert it to empty date
IF NOT Odbc() AND NOT lp_lExternalODBC
	RETURN .T.
ENDIF

IF EMPTY(lp_cAlias) OR NOT USED(lp_cAlias)
	RETURN .T.
ENDIF

LOCAL i, l_nArea, l_nFieldsCount, l_cField, l_nRecNo, l_cFType
LOCAL ARRAY l_aFields(1)
l_nArea = SELECT()

SELECT (lp_cAlias)
l_nRecNo = RECNO()
l_nFieldsCount = AFIELDS(l_aFields)
FOR i = 1 TO l_nFieldsCount
	l_cField = l_aFields(i,1)
	l_cFType = VARTYPE(&l_cField)
	DO CASE
		CASE NOT INLIST(l_cFType, "D", "T")
		CASE lp_lAllRecords
			BLANK FIELDS &l_cField FOR &l_cField = IIF(l_cFType = "D", CF_PSQL_EMPTY_DATE, CF_PSQL_EMPTY_DATETIME)
		CASE &l_cField = IIF(l_cFType = "D", CF_PSQL_EMPTY_DATE, CF_PSQL_EMPTY_DATETIME)
			BLANK FIELDS &l_cField
		OTHERWISE
	ENDCASE
ENDFOR

IF lp_lAllRecords
	GO l_nRecNo
ENDIF

SELECT (l_nArea)

RETURN .T.
ENDPROC
*
PROCEDURE CFCursorNullsAdd
LPARAMETERS lp_lAllRecords, lp_cAlias, lp_lExternalODBC

* When null data or datetime is found, we must convert it to empty date
IF NOT Odbc() AND NOT lp_lExternalODBC
	RETURN .T.
ENDIF

IF EMPTY(lp_cAlias) OR NOT USED(lp_cAlias)
	RETURN .T.
ENDIF

LOCAL i, l_nArea, l_nFieldsCount, l_cField, l_nRecNo, l_cFType
LOCAL ARRAY l_aFields(1)

l_nArea = SELECT()

SELECT (lp_cAlias)
l_cFor = IIF(CURSORGETPROP("Buffering") = 1, "", "AND GETFLDSTATE(l_cField) > 1")
l_nRecNo = RECNO()
l_nFieldsCount = AFIELDS(l_aFields)
FOR i = 1 TO l_nFieldsCount
	l_cField = l_aFields(i,1)
	l_cFType = VARTYPE(&l_cField)
	DO CASE
		CASE NOT INLIST(l_cFType, "D", "T")
		CASE lp_lAllRecords
			REPLACE &l_cField WITH IIF(l_cFType = "D", CF_PSQL_EMPTY_DATE, CF_PSQL_EMPTY_DATETIME) FOR EMPTY(&l_cField) &l_cFor
		CASE EMPTY(&l_cField) &l_cFor
			REPLACE &l_cField WITH IIF(l_cFType = "D", CF_PSQL_EMPTY_DATE, CF_PSQL_EMPTY_DATETIME)
		OTHERWISE
	ENDCASE
ENDFOR

IF lp_lAllRecords
	GO l_nRecNo
ENDIF

SELECT (l_nArea)

RETURN .T.
ENDPROC
*
PROCEDURE CFCursorNullsRemoveAll
LPARAMETERS lp_lAllRecords, lp_cAlias
LOCAL i, l_nArea, l_cField, l_nRecNo

IF EMPTY(lp_cAlias) OR NOT USED(lp_cAlias)
	RETURN .T.
ENDIF

l_nArea = SELECT()

SELECT (lp_cAlias)
l_nRecNo = RECNO()
FOR i = 1 TO FCOUNT()
	l_cField = FIELD(i)
	DO CASE
		CASE lp_lAllRecords
			BLANK FIELDS &l_cField FOR ISNULL(&l_cField)
		CASE ISNULL(&l_cField)
			BLANK FIELDS &l_cField
		OTHERWISE
	ENDCASE
ENDFOR

IF lp_lAllRecords
	GO l_nRecNo
ENDIF

SELECT (l_nArea)

RETURN .T.
ENDPROC
*
PROCEDURE CFEncryptString
LPARAMETERS lp_cPlainString
LOCAL l_cResult
IF EMPTY(lp_cPlainString)
	l_cResult = ""
ELSE
	l_cResult = Encrypt(lp_cPlainString,CF_ENCRYPT_MAIN_KEY)
ENDIF
RETURN l_cResult
ENDPROC
*
PROCEDURE CFDecryptString
LPARAMETERS lp_cCryptedString
LOCAL l_cResult
IF EMPTY(lp_cCryptedString)
	l_cResult = ""
ELSE
	l_cResult = ALLTRIM(Decrypt(lp_cCryptedString,CF_ENCRYPT_MAIN_KEY))
ENDIF
RETURN l_cResult
ENDPROC
*
PROCEDURE CFGetEncryptKey
RETURN CF_ENCRYPT_MAIN_KEY
ENDPROC
*
PROCEDURE CFFileInfo
LPARAMETERS lp_cFile, lp_cHash, lp_nFileSize
LOCAL l_lSuccess, l_cFileFullPath
LOCAL ARRAY l_aFiles(1)
lp_cHash = ""
lp_nFileSize = 0
IF NOT EMPTY(lp_cFile)
     l_cFileFullPath = FULLPATH(lp_cFile)
     IF ADIR(l_aFiles, l_cFileFullPath)>0
          lp_cHash = LOWER(LEFT(STRCONV(HASHFILE(l_cFileFullPath,5),15),32))
          lp_nFileSize = l_aFiles(1,2)
          l_lSuccess = .T.
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*

PROCEDURE DataAccessInit
LPARAMETERS tcApplication, tcPrefix, tcDataFolder, tcIniFile, tlDefaultDB
LOCAL loDatabaseProp, lcIni, lcSection
IF EMPTY(tcPrefix)
	tcPrefix = ""
ENDIF
IF EMPTY(tcDataFolder)
	tcDataFolder = ""
ENDIF

lcIni = ""
lcSection = "Database"+tcApplication

* CAUTION!  If added new property here then must be added in MpSession class in Procmultiproper.prg also.
loDatabaseProp = MakeStructure("cApplication, cPgSchema, cPrefix, cDataFolder, cServerName, nServerPort, lEncrypt, lSilent")
loDatabaseProp.cApplication = tcApplication
loDatabaseProp.cPgSchema = ""
loDatabaseProp.cPrefix = tcPrefix
loDatabaseProp.cDataFolder = ""
loDatabaseProp.cServerName = ""
loDatabaseProp.nServerPort = 0
loDatabaseProp.lEncrypt = .F.
loDatabaseProp.lSilent = .F.

IF NOT EMPTY(tcIniFile)
	lcIni = FULLPATH(tcIniFile)
	IF FILE(lcIni)
		loDatabaseProp.cPgSchema = CFReadIni(lcIni, lcSection, "PgSchema", "")
		loDatabaseProp.cServerName = CFReadIni(lcIni, lcSection, "ServerName", "")
		loDatabaseProp.nServerPort = INT(VAL(CFReadIni(lcIni, lcSection, "ServerPort", "0")))
		loDatabaseProp.lEncrypt = (LOWER(CFReadIni(lcIni, lcSection, "Encrypt", "no")) = "yes")
		loDatabaseProp.lSilent = (LOWER(CFReadIni(lcIni, lcSection, "Silent", "no")) = "yes")
	ENDIF
ENDIF
IF (EMPTY(loDatabaseProp.cServerName) OR EMPTY(loDatabaseProp.nServerPort)) AND VARTYPE(tcDataFolder) = "C"
	IF DIRECTORY(tcDataFolder)
		loDatabaseProp.cDataFolder = tcDataFolder
	ENDIF
ENDIF
IF NOT tlDefaultDB AND EMPTY(loDatabaseProp.cDataFolder) AND EMPTY(loDatabaseProp.cPgSchema) AND ;
		(EMPTY(loDatabaseProp.cServerName) OR EMPTY(loDatabaseProp.nServerPort))
	loDatabaseProp = .NULL.
ENDIF

RETURN loDatabaseProp
ENDPROC
*
PROCEDURE CFDeleteOldestXFilesInFolder
LPARAMETERS lp_cDir, lp_nNumberOfBackups
LOCAL l_nNumberOfBackups, l_cDir, l_nSelect, l_cCur, l_nCount, i, l_oData
LOCAL ARRAY l_aFiles(1)

IF EMPTY(lp_cDir) OR NOT DIRECTORY(lp_cDir)
	RETURN .F.
ENDIF
IF EMPTY(lp_nNumberOfBackups)
	l_nNumberOfBackups = 30
ELSE
	l_nNumberOfBackups = lp_nNumberOfBackups
ENDIF
l_cDir = ADDBS(lp_cDir)
l_cCur = SYS(2015)
l_nSelect = SELECT()

CREATE CURSOR (l_cCur) (cur_name c(254), cur_date d, cur_time c(8))
INDEX ON DTOS(cur_date) + cur_time TAG TAG1 DESCENDING

ADIR(l_aFiles,l_cDir+"*")
FOR i = 1 TO ALEN(l_aFiles,1)
	SCATTER NAME l_oData BLANK
	l_oData.cur_name = l_aFiles(i,1)
	l_oData.cur_date = l_aFiles(i,3)
	l_oData.cur_time = l_aFiles(i,4)
	INSERT INTO (l_cCur) FROM NAME l_oData
ENDFOR

l_nCount = 0
SELECT (l_cCur)
SCAN ALL
	l_nCount = l_nCount + 1
	IF l_nCount > l_nNumberOfBackups
		DELETE FILE (l_cDir+ALLTRIM(cur_name))
	ENDIF
ENDSCAN

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
**************************************************
*-- Class:		SetEnvironment (commonfunc.prg)
*-- ParentClass:	Custom
*-- BaseClass:		Custom
*-- Time Stamp:	10/11/06 11:15:00 AM
*
FUNCTION CFSetEnvironment
LPARAMETERS tcAliases, tcOrders, tcMacroInit, tcMacroDestroy

RETURN CREATEOBJECT("SetEnvironment", tcAliases, tcOrders,,tcMacroInit, tcMacroDestroy)
ENDFUNC
*
DEFINE CLASS SetEnvironment AS Custom
	PROTECTED cOldAlias, cOldAliasOrder, nAliasCount, nExtraPropertyCount, cMacroInit, cMacroDestroy, aEnvironment(1), aWatchProperty(1)
	cOldAlias = ""
	cOldAliasOrder = ""
	cMacroDestroy = ""
	nAliasCount = 0
	nExtraPropertyCount = 0

	PROCEDURE Init
		LPARAMETERS tcAliases, tcOrders, taWatchProperty, tcMacroInit, tcMacroDestroy
		EXTERNAL ARRAY taWatchProperty
		LOCAL i, j, lcAlias, lcOrder

		*** Save current work area
		this.cOldAlias = ALIAS()
		this.cOldAliasOrder = ORDER()

		*** Check parameters
		IF EMPTY(tcAliases)
			tcAliases = ""
		ENDIF
		IF EMPTY(tcOrders)
			tcOrders = ""
		ELSE
			tcOrders = STRTRAN(tcOrders,","," , ")
		ENDIF
		IF TYPE("taWatchProperty",1) = "A"
			=ACOPY(taWatchProperty, this.aWatchProperty)
			this.nExtraPropertyCount = ALEN(this.aWatchProperty)
		ENDIF
		IF NOT EMPTY(tcMacroInit)
			&tcMacroInit
		ENDIF
		IF NOT EMPTY(tcMacroDestroy)
			this.cMacroDestroy = tcMacroDestroy
		ENDIF

		this.nAliasCount = GETWORDCOUNT(tcAliases, ",")

		IF this.nAliasCount > 0
			*** Save environment for requested aliases
			DIMENSION this.aEnvironment(this.nAliasCount,6)
			FOR i = 1 TO this.nAliasCount
				lcAlias = ALLTRIM(GETWORDNUM(tcAliases, i, ","))
				lcOrder = ALLTRIM(GETWORDNUM(tcOrders, i, ","))
				this.aEnvironment(i,1) = lcAlias
				this.aEnvironment(i,4) = USED(lcAlias)
				IF this.aEnvironment(i,4)
					this.aEnvironment(i,2) = ORDER(lcAlias)
					this.aEnvironment(i,3) = RECNO(lcAlias)
					FOR j = 1 TO this.nExtraPropertyCount
						this.aEnvironment(i,4+j) = this.GetWatchProperty(this.aEnvironment(i,1), this.aWatchProperty(j))
					NEXT
				ELSE
					this.OpenTable(lcAlias)
				ENDIF
				IF NOT EMPTY(lcOrder)
					SET ORDER TO lcOrder IN &lcAlias
				ENDIF
			NEXT

			*** Select first alias
			SELECT (this.aEnvironment(1,1))
		ENDIF
	ENDPROC
	*
	PROCEDURE OpenTable
		LPARAMETERS tcAlias
		USE (tcAlias) IN 0 AGAIN SHARED
	ENDPROC
	*
	PROCEDURE GetWatchProperty
		LPARAMETERS tcAlias, tcProperty
		RETURN .F.
	ENDPROC
	*
	PROCEDURE SetWatchProperty
		LPARAMETERS tcAlias, tcProperty, luValue
	ENDPROC
	*
	PROCEDURE Destroy
		LOCAL i, j, lcAlias, lcOrder, lcMacroDestroy

		*** If table opened by this object, close it
		FOR i = 1 TO this.nAliasCount
			lcAlias = this.aEnvironment(i,1)
			IF this.aEnvironment(i,4)
				GO this.aEnvironment(i,3) IN &lcAlias
				FOR j = 1 TO this.nExtraPropertyCount
					this.SetWatchProperty(this.aEnvironment(i,1), this.aWatchProperty(j), this.aEnvironment(i,4+j))
				NEXT
				lcOrder = this.aEnvironment(i,2)
				SET ORDER TO lcOrder IN &lcAlias
			ELSE
				IF USED(lcAlias)
					USE IN (lcAlias)
				ENDIF
			ENDIF
		NEXT

		*** Restore Previous work area
		IF NOT EMPTY(this.cOldAlias) AND USED(this.cOldAlias)
			SELECT (this.cOldAlias)
			SET ORDER TO (this.cOldAliasOrder)
		ENDIF

		IF NOT EMPTY(this.cMacroDestroy)
			lcMacroDestroy = this.cMacroDestroy
			&lcMacroDestroy
		ENDIF
	ENDPROC
ENDDEFINE
*-- EndDefine: SetEnvironment
**************************************************
*
**************************************************
*-- Class:		TransactObject (commonfunc.prg)
*-- ParentClass:	Custom
*-- BaseClass:		Custom
*-- Time Stamp:	28/05/15 16:45:00 PM
*
PROCEDURE ReleaseTransactObject
RELEASE g_oTransaction
ENDPROC
*
PROCEDURE SetTransactable
LPARAMETERS lp_cTableName

IF VARTYPE(g_oTransaction) == "O"
	g_oTransaction.MakeTransactable(SET("Datasession"), lp_cTableName)
ENDIF
ENDPROC
*
PROCEDURE CheckCodePage
LPARAMETERS lp_cTableNameAndPath, lp_nCodePage

IF VARTYPE(g_oTransaction) == "O"
	g_oTransaction.CheckCodePage(lp_cTableNameAndPath, lp_nCodePage)
ENDIF
ENDPROC
*
PROCEDURE ForceEndAllTransaction
g_oTransaction.ForceEndAllTransaction()
ENDPROC
*
PROCEDURE FNDoEvents
= Sleep(1)
wait window "" timeout .001
DOEVENTS
RETURN .T.
ENDPROC
*
DEFINE CLASS TransactObject AS Custom
	PROTECTED oTransactions
	cLogErrorProc = ""
	*
	PROCEDURE Init
	this.oTransactions = CREATEOBJECT("Collection")
	ENDPROC
	*
	PROCEDURE Destroy
	LOCAL loTransaction

	IF VARTYPE(this.oTransactions) = "O" AND this.oTransactions.Count > 0
		FOR EACH loTransaction IN this.oTransactions FOXOBJECT
			this.EndTransaction(loTransaction.nDataSessionId)
		NEXT
	ENDIF
	this.oTransactions = .NULL.
	ENDPROC
	*
	PROCEDURE CheckCodePage
	LPARAMETERS tcTableNameAndPath, tnCodePage
	LOCAL lcTableName, llUsed, lcCpFunc

	IF VARTYPE(g_oTransaction) == "O"
		lcTableName = JUSTSTEM(tcTableNameAndPath)
		llUsed = USED(lcTableName)
		IF NOT llUsed
			USE (tcTableNameAndPath) SHARED IN 0
		ENDIF
		IF CPDBF(lcTableName) <> tnCodePage
			USE IN &lcTableName
			lcCpFunc = "CpZero"
			&lcCpFunc(tcTableNameAndPath, tnCodePage, .T.)
			IF llUsed
				USE (tcTableNameAndPath) SHARED IN 0
			ENDIF
		ENDIF
	ENDIF
	ENDPROC
	*
	PROCEDURE MakeTransactable
	LPARAMETERS tnDataSession, tcTableName
	LOCAL llSuccess, lnBufferMode, lnOldDS

	llSuccess = .T.

	lnOldDS = SET("Datasession")
	SET DATASESSION TO (tnDataSession)

	IF NOT EMPTY(tcTableName) AND USED(tcTableName) AND NOT ISTRANSACTABLE(tcTableName)
		* Check if buffering is active. Before we set that table can support transactions, buffering must be set to 1!
		lnBufferMode = CURSORGETPROP("Buffering", tcTableName)
		IF lnBufferMode > 3
			this.TableRevert(.T.,tcTableName)
			CURSORSETPROP("Buffering", 1, tcTableName)
		ENDIF
		llSuccess = MAKETRANSACTABLE(tcTableName)
		IF lnBufferMode > 3
			CURSORSETPROP("Buffering", lnBufferMode, tcTableName)
		ENDIF
		IF NOT llSuccess
			this.LogError("MAKETRANSACTABLE on table " + tcTableName + " failed!")
		ENDIF
	ENDIF

	SET DATASESSION TO (lnOldDS)

	RETURN llSuccess
	ENDPROC
	*
	PROCEDURE GetTransaction
	LPARAMETERS tnDataSession
	LOCAL lcKey, loTransaction

	lcKey = TRANSFORM(tnDataSession)
	IF 0 = this.oTransactions.GetKey(lcKey)
		loTransaction = .NULL.
	ELSE
		* Get existing transaction
		loTransaction = this.oTransactions.Item(lcKey)
	ENDIF

	RETURN loTransaction
	ENDPROC
	*
	PROCEDURE BeginTransaction
	LPARAMETERS tnDataSession
	LOCAL i, lnNSIndexes, lcAlias, lcDbfFile, lcKey, loTransaction, lnOldDS
	LOCAL ARRAY laUsed(1,3)

	lcKey = TRANSFORM(tnDataSession)
	IF 0 = this.oTransactions.GetKey(lcKey)
		* Create and begin new transaction
		loTransaction = MakeStructure("nDataSessionId,lStatus,cAfterGoodSaveProc,aNSIndexes[1]")
		loTransaction.nDataSessionId = tnDataSession
		loTransaction.lStatus = .T.
		this.oTransactions.Add(loTransaction, lcKey)
		lnOldDS = SET("Datasession")
		SET DATASESSION TO (loTransaction.nDataSessionId)
		lnNSIndexes = 0
		FOR i = 1 TO AUSED(laUsed)
			lcAlias = LOWER(laUsed[i,1])
			lcDbfFile = UPPER(DBF(lcAlias))
			IF JUSTEXT(lcDbfFile) == "DBF" AND ISTRANSACTABLE(lcAlias) AND NOT EMPTY(CDX(1,lcAlias)) AND ;
					NOT (JUSTSTEM(lcDbfFile) == JUSTSTEM(CDX(1,lcAlias)) AND EMPTY(CDX(2,lcAlias)))
				lnNSIndexes = lnNSIndexes + 1
				SELECT &lcAlias
				DIMENSION loTransaction.aNSIndexes(lnNSIndexes,2)
				loTransaction.aNSIndexes[lnNSIndexes,1] = lcAlias
				loTransaction.aNSIndexes[lnNSIndexes,2] = SET("Index")
				SET INDEX TO
			ENDIF
		NEXT
		BEGIN TRANSACTION
		SET DATASESSION TO (lnOldDS)
	ENDIF
	ENDPROC
	*
	PROCEDURE EndTransaction
	LPARAMETERS tnDataSession
	LOCAL i, llSuccess, lcKey, loTransaction, lnOldDS, lcIndexFiles, lcAfterGoodSaveMacro

	lcKey = TRANSFORM(tnDataSession)
	IF 0 = this.oTransactions.GetKey(lcKey)
		* Transaction has been closed
		llSuccess = .T.
	ELSE
		loTransaction = this.oTransactions.Item(lcKey)
		lnOldDS = SET("Datasession")
		SET DATASESSION TO (loTransaction.nDataSessionId)
		IF loTransaction.lStatus
			TRY
				* Try to commit
				END TRANSACTION
			CATCH
				* Otherwise rollback
				loTransaction.lStatus = .F.
			ENDTRY
			IF NOT loTransaction.lStatus
				this.LogError("Commit failed, changes have been rolled back")
			ENDIF
		ENDIF
		DO CASE
			CASE NOT loTransaction.lStatus
				* Rollback unsuccessful transaction
				ROLLBACK
			CASE NOT EMPTY(loTransaction.cAfterGoodSaveProc)
				lcAfterGoodSaveMacro = loTransaction.cAfterGoodSaveProc
				loTransaction.cAfterGoodSaveProc = ""
				TRY
					&lcAfterGoodSaveMacro
				CATCH
				ENDTRY
			OTHERWISE
		ENDCASE
		IF NOT EMPTY(loTransaction.aNSIndexes[1])
			FOR i = 1 TO ALEN(loTransaction.aNSIndexes,1)
				SELECT (loTransaction.aNSIndexes[i,1])
				lcIndexFiles = loTransaction.aNSIndexes[i,2]
				SET INDEX TO &lcIndexFiles
			NEXT
		ENDIF
		llSuccess = loTransaction.lStatus
		IF 0 = TXNLEVEL()
			this.oTransactions.Remove(lcKey)
		ENDIF
		SET DATASESSION TO (lnOldDS)
	ENDIF

	RETURN llSuccess
	ENDPROC
	*
	PROCEDURE ForceEndAllTransaction
	LOCAL loTransaction, lnOldDS

	lnOldDS = SET("Datasession")
	FOR EACH loTransaction IN this.oTransactions
		SET DATASESSION TO (loTransaction.nDataSessionId)
		ROLLBACK
	NEXT
	SET DATASESSION TO (lnOldDS)
	this.oTransactions.Remove(-1)
	ENDPROC
	*
	PROCEDURE TableUpdate
	LPARAMETERS tnDataSession, tnRows, tlForce, tcTableAlias
	LOCAL lcMessage, lcRecords, lcDelimiter, lnRecId, lnOldDS, llSuccess
	LOCAL ARRAY laError(1), lcErrorArray(1)

	lnOldDS = SET("Datasession")
	SET DATASESSION TO (tnDataSession)

	IF EMPTY(tcTableAlias)
		tcTableAlias = ALIAS()
	ENDIF

	IF USED(tcTableAlias) AND CURSORGETPROP("Buffering", tcTableAlias) > 2
		IF VARTYPE(tnRows) == "L" AND tnRows
			tnRows = 2
		ENDIF

		llSuccess = TABLEUPDATE(tnRows, tlForce, tcTableAlias, lcErrorArray)

		IF NOT llSuccess
			AERROR(laError)
			ASSERT .F.
			IF lcErrorArray(1) = -1
				lcRecords = ""
			ELSE
				lcRecords = " ("
				lcDelimiter = ""
				FOR EACH lnRecId IN lcErrorArray
					lcRecords = lcRecords + lcDelimiter + TRANSFORM(lnRecId)
					lcDelimiter = ","
				NEXT
				lcRecords = lcRecords + ")"
			ENDIF
			TEXT TO lcMessage TEXTMERGE NOSHOW PRETEXT 15
				Transaction error on table <<UPPER(tcTableAlias)>><<lcRecords>>: <<TRANSFORM(laError(1,1))>>. <<laError(1,2)>>
			ENDTEXT
			this.LogError(lcMessage)
		ENDIF
	ELSE
		llSuccess = .T.
	ENDIF

	SET DATASESSION TO (lnOldDS)

	RETURN llSuccess
	ENDPROC
	*
	PROCEDURE TableRevert
	LPARAMETERS tnDataSession, tlAllRows, tcTableAlias
	LOCAL lnRecCount

	lnOldDS = SET("Datasession")
	SET DATASESSION TO (tnDataSession)

	IF EMPTY(tcTableAlias)
		tcTableAlias = ALIAS()
	ENDIF

	lnRecCount = 0
	IF USED(tcTableAlias) AND CURSORGETPROP("Buffering", tcTableAlias) > 2
		lnRecCount = TABLEREVERT(tlAllRows, tcTableAlias)
	ENDIF

	SET DATASESSION TO (lnOldDS)

	RETURN lnRecCount
	ENDPROC
	*
	PROCEDURE GetStatus
	LPARAMETERS tnDataSession, tcProperty
	LOCAL luValue, loTransaction

	loTransaction = this.GetTransaction(tnDataSession)
	DO CASE
		CASE UPPER(tcProperty) == "TRANACTIVE"
			luValue = (VARTYPE(loTransaction) == "O")
		CASE UPPER(tcProperty) == "STATUS"
			luValue = (VARTYPE(loTransaction) == "O") AND loTransaction.lStatus
		OTHERWISE
	ENDCASE

	RETURN luValue
	ENDPROC
	*
	PROCEDURE LogError
	LPARAMETERS tcMessage
	LOCAL llLogged, lcLogErrorMacro

	IF NOT EMPTY(this.cLogErrorProc)
		lcLogErrorMacro = this.cLogErrorProc
		TRY
			&lcLogErrorMacro
			llLogged = .T.
		CATCH
		ENDTRY
	ENDIF
	IF NOT llLogged
		STRTOFILE(TRANSFORM(DATETIME()) + " " + tcMessage + CRLF, "Transact.err", .T.)
	ENDIF
	ENDPROC
ENDDEFINE
*-- EndDefine: TransactObject
**************************************************
*
**************************************************
*-- Class:		MyExtensionHandler (commonfunc.prg)
*-- ParentClass:	Custom
*-- BaseClass:		Custom
*-- Time Stamp:	10/08/15 11:15:00 AM
*
DEFINE CLASS MyExtensionHandler AS Custom
	lNoListsTable = .F.
	curData = ""
	*
	PROCEDURE Print
		LPARAMETERS toXFF
		RETURN .T. && continue with the default behavior
	ENDPROC

	PROCEDURE Export 
		LPARAMETERS toXFF
		*
		* now you can process the XFF file
		*
		RETURN .T. && override the default behavior
	ENDPROC
ENDDEFINE
*-- EndDefine: MyExtensionHandler
**************************************************
*
#DEFINE cnBUFFER_SIZE	256
#DEFINE ccNULL			CHR(0)
#DEFINE ccCR			CHR(13)
FUNCTION CFReadIni
LPARAMETERS tcINIFile, tcSection, tuEntry, tcDefault, taEntries
LOCAL lcBuffer, lcDefault, lnSize, luReturn

DECLARE integer GetPrivateProfileString IN Win32API string cSection, string cEntry, string cDefault, string @cBuffer, integer nBufferSize, string cINIFile

lcBuffer = REPLICATE(ccNULL, cnBUFFER_SIZE)
lcDefault = IIF(VARTYPE(tcDefault) <> 'C', '', tcDefault)
lnSize = GetPrivateProfileString(tcSection, tuEntry, lcDefault, @lcBuffer, cnBUFFER_SIZE, tcINIFile)
lcBuffer = LEFT(lcBuffer, lnSize)
lcBuffer = ALLTRIM(STREXTRACT(lcBuffer,"",";",1,2))
DO CASE
	CASE VARTYPE(tuEntry) = 'C'
		luReturn = lcBuffer
	CASE lnSize = 0
		luReturn = 0
	OTHERWISE
		luReturn = ALINES(taEntries, lcBuffer, .T., ccNULL, ccCR)
ENDCASE

RETURN luReturn
ENDFUNC
*
PROCEDURE CFGetGuid
LOCAL l_oTypeLib
l_oTypeLib = CREATEOBJECT("Scriptlet.TypeLib")
RETURN STREXTRACT(l_oTypeLib.Guid,"{","}")
ENDPROC
*
PROCEDURE CFExecCommand
LPARAMETERS lp_cCommand, lp_lLogError
LOCAL l_cOutPut, l_cTempShellRunFile, l_oShell
l_cOutPut = ""

IF EMPTY(lp_cCommand)
	RETURN l_cOutPut
ENDIF

* Initialize
l_oShell = CREATEOBJECT("Wscript.Shell")

* Create unique file name as guid
l_cTempShellRunFile = CFGetGuid()

* When guid wasn't created, create vfp unique name
IF EMPTY(l_cTempShellRunFile)
	l_cTempShellRunFile = SYS(2015)
ENDIF

* Set txt extension
l_cTempShellRunFile = FORCEEXT(l_cTempShellRunFile,"txt")
l_cTempShellRunFile = FULLPATH(ADDBS(SYS(2023))+l_cTempShellRunFile)

* Run command
l_oRunScript = l_oShell.Run([%COMSPEC% /C ] + lp_cCommand + [  > ] + l_cTempShellRunFile + IIF(lp_lLogError,[ 2>&1],[]), 0, .T.)

* Check for output
IF FILE(l_cTempShellRunFile)
	l_cOutPut = FILETOSTR(l_cTempShellRunFile)
ENDIF

* Delete output file
DELETE FILE (l_cTempShellRunFile)

* Clean up
l_oShell = .NULL.
l_oTypeLib = .NULL.

RETURN l_cOutPut
ENDPROC
*
PROCEDURE CFLogReqAndRes
* Log HTTP request and response
LPARAMETERS lp_cCmd, lp_cMethod, lp_cURL, lp_cPayLoad, lp_cFileName
LOCAL l_cFile2, l_nLimit

IF EMPTY(lp_cMethod)
     lp_cMethod = "GET"
ENDIF
IF EMPTY(lp_cURL)
     lp_cURL = ""
ENDIF

IF EMPTY(lp_cPayLoad)
     lp_cPayLoad = ""
ENDIF

l_cFile2 = lp_cFileName + ".2"
l_nLimit = 50000000 && 50 MB

IF FILE(lp_cFileName)
     IF ADIR(l_aFile,LOCFILE(lp_cFileName))>0
          IF l_aFile(2)>l_nLimit
               IF FILE(l_cFile2)
                    DELETE FILE (l_cFile2)
               ENDIF
               RENAME (lp_cFileName) TO (l_cFile2)
          ENDIF
     ENDIF
ENDIF

TRY
     IF lp_cCmd = "RESPONSE"
          STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cCmd+"|"+lp_cMethod+CHR(13)+CHR(10)+REPLICATE("-",50)+CHR(13)+CHR(10)+;
                    lp_cPayLoad+CHR(13)+CHR(10)+;
                    REPLICATE("-",50)+CHR(13)+CHR(10),lp_cFileName,1)
     ELSE && REQUEST
          STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cCmd+"|"+lp_cMethod+"|"+lp_cURL+CHR(13)+CHR(10)+REPLICATE("-",50)+CHR(13)+CHR(10)+;
                    lp_cPayLoad+CHR(13)+CHR(10)+;
                    REPLICATE("-",50)+CHR(13)+CHR(10),lp_cFileName,1)
     ENDIF
CATCH
ENDTRY
RETURN .T.
ENDPROC
*
PROCEDURE CFWaitWindow
LPARAMETERS lp_cText, lp_nTimeOutSec
LOCAL l_cTimeOut
IF EMPTY(lp_nTimeOutSec)
	l_cTimeOut = " NOWAIT"
ELSE
	l_cTimeOut = " TIMEOUT " + TRANSFORM(lp_nTimeOutSec)
ENDIF
WAIT lp_cText WINDOW &l_cTimeOut
ENDPROC
*
********************************************************* registerdotnetcomponent.prg *****************************************
* Registry roots
#DEFINE CRLF					CHR(13)+CHR(10)
#DEFINE SW_HIDE				0
#DEFINE SW_SHOWNORMAL			1

*** Win32 API Constants
#DEFINE ERROR_SUCCESS			0
#DEFINE MAX_INI_BUFFERSIZE		512
#DEFINE MAX_INI_ENUM_BUFFERSIZE	8196

*** Registry roots
#DEFINE HKEY_CLASSES_ROOT		0x80000000	&& -2147483648
#DEFINE HKEY_CURRENT_USER		0x80000001	&& -2147483647
#DEFINE HKEY_LOCAL_MACHINE		0x80000002	&& -2147483646
#DEFINE HKEY_USERS				0x80000003	&& -2147483645

*** Registry Value types
#DEFINE REG_NONE				0	&& Undefined Type (default)
#DEFINE REG_SZ					1	&& Regular Null Terminated String
#DEFINE REG_BINARY				3	&& ??? (unimplemented)
#DEFINE REG_DWORD				4	&& Long Integer value
#DEFINE MULTI_SZ				7	&& Multiple Null Term Strings (not implemented)
*
FUNCTION RegisterCOMComponent
*  Function: Registers a COM server component.
*      Pass: tcCOMServer - The COM server to register (Full path to .exe, .dll or .ocx)
*            tcProgId    - One of the ProgIds to register. Used to check if the component registered
*            @tcMessage  - Pass by reference in order to get error or result info
LPARAMETERS tcCOMServer, tcProgId, tcMessage, taToDoList
EXTERNAL ARRAY taToDoList
LOCAL llRegister, llUnregister, lnRetVal, llExecutable, lcVersion, lcClassId, lcClassDescript, lcModuleVersion, lnRow
PRIVATE pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack

STORE "" TO pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack, tcMessage
pcPlatform = GetOsVersion(@pc32Or64BitOS, @pcServicePack)
pcOperation = IIF(INLIST(pcPlatform, "Win8", "Win7", "Win2008R2", "Win2008", "Vista"), "RunAs", "Open")

* If the object has already registered last version then exit.
tcCOMServer = FULLPATH(tcCOMServer)
llExecutable = (UPPER(JUSTEXT(tcCOMServer)) = "EXE")
lcVersion = GetBinaryFileVersion(tcCOMServer)
DO CASE
	CASE NOT IsCOMObject(tcProgId, @lcClassId, @lcClassDescript, @lcModuleVersion)
	CASE NOT lcModuleVersion == lcVersion
		llUnregister = .T.
	OTHERWISE
		RETURN .T.
ENDCASE

IF PCOUNT() < 4
	DECLARE INTEGER ShellExecute IN Shell32.dll INTEGER nWinHandle, STRING cOperation, STRING cFileName, STRING cParameters, STRING cDirectory, INTEGER nShowWindow

	IF llUnregister
		IF llExecutable
			STRTOFILE('"' + tcCOMServer + '" /unregserver' + CRLF + '"' + tcCOMServer + '" /regserver', "registercomcomponent.bat")
		ELSE
			STRTOFILE('regsvr32 "' + tcCOMServer + '" /u /s' + CRLF + 'regsvr32 "' + tcCOMServer + '" /s', "registercomcomponent.bat")
		ENDIF
		lnRetVal = ShellExecute(0, pcOperation, "cmd", "/C "+FULLPATH("registercomcomponent.bat"), "", SW_HIDE)
		WAIT "Registering " + UPPER(JUSTFNAME(tcCOMServer)) + " COM server component..." WINDOW TIMEOUT 1
		DELETE FILE registercomcomponent.bat
	ELSE
		IF llExecutable
			lnRetVal = ShellExecute(0, pcOperation, tcCOMServer, "/regserver", "", SW_HIDE)
		ELSE
			lnRetVal = ShellExecute(0, pcOperation, "regsvr32", tcCOMServer + " /s", "", SW_HIDE)
		ENDIF
		WAIT "Registering " + UPPER(JUSTFNAME(tcCOMServer)) + " COM server component..." WINDOW TIMEOUT 1
	ENDIF

	IF IsCOMObject(tcProgId, @lcClassId, @lcClassDescript, @lcModuleVersion)
		tcMessage = "Registration of " + UPPER(JUSTFNAME(tcCOMServer)) + " succeed for version " + lcVersion + "."
		IF PCOUNT() < 3
			MESSAGEBOX(tcMessage)
		ENDIF
		RETURN .T.
	ELSE
		tcMessage = "Registration of " + UPPER(JUSTFNAME(tcCOMServer)) + " failed." + CRLF + CRLF + ;
			"You don't have sufficient rights to register COM server. " + CRLF + "Please, contact your vendor dealer."
		IF PCOUNT() < 3
			MESSAGEBOX(tcMessage)
		ENDIF
		RETURN .F.
	ENDIF
ELSE
	IF llExecutable OR NOT llUnregister && Don't register TAPIExCt.dll again!
		IF NOT EMPTY(taToDoList(1))
			DIMENSION taToDoList(ALEN(taToDoList,1)+1, ALEN(taToDoList,2))
		ENDIF
		lnRow = ALEN(taToDoList,1)
		taToDoList[lnRow,1] = tcCOMServer
		taToDoList[lnRow,2] = tcProgId
		taToDoList[lnRow,3] = IIF(llExecutable,"C","L") + IIF(llUnregister, "U", "")
		taToDoList[lnRow,4] = '"' + tcCOMServer + '"'
		taToDoList[lnRow,5] = lcModuleVersion
		RETURN .T.
	ENDIF
ENDIF
RETURN .T.
ENDFUNC
*
FUNCTION UnregisterCOMComponent
*  Function: Unregisters a COM server component.
*      Pass: tcCOMServer - The COM server to unregister (Full path to .exe or .dll)
*            tcProgId    - One of the ProgIds. Used to check if the component registered
*            @tcMessage  - Pass by reference in order to get error or result info
LPARAMETERS tcCOMServer, tcProgId, tcMessage
LOCAL lnRetVal, llExecutable, lcClassId, lcClassDescript, lcModuleVersion
PRIVATE pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack

STORE "" TO pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack, tcMessage
pcPlatform = GetOsVersion(@pc32Or64BitOS, @pcServicePack)
pcOperation = IIF(INLIST(pcPlatform, "Win8", "Win7", "Win2008R2", "Win2008", "Vista"), "RunAs", "Open")

* If the object hasn't yet registered then exit.
IF NOT IsCOMObject(tcProgId, @lcClassId, @lcClassDescript, @lcModuleVersion)
	RETURN .T.
ENDIF

DECLARE INTEGER ShellExecute IN Shell32.dll INTEGER nWinHandle, STRING cOperation, STRING cFileName, STRING cParameters, STRING cDirectory, INTEGER nShowWindow

tcCOMServer = FULLPATH(tcCOMServer)
llExecutable = (UPPER(JUSTEXT(tcCOMServer)) = "EXE")
IF llExecutable
	lnRetVal = ShellExecute(0, pcOperation, tcCOMServer, "/unregserver", "", SW_HIDE)
ELSE
	lnRetVal = ShellExecute(0, pcOperation, "regsvr32", tcCOMServer + " /u /s", "", SW_HIDE)
ENDIF
WAIT "Unregistering " + UPPER(JUSTFNAME(tcCOMServer)) + " COM server component..." WINDOW TIMEOUT 1

IF IsCOMObject(tcProgId, @lcClassId, @lcClassDescript, @lcModuleVersion)
	tcMessage = "Removing registration of " + UPPER(JUSTFNAME(tcCOMServer)) + " failed." + CRLF + CRLF + ;
		"You don't have sufficient rights to unregister COM server. " + CRLF + "Please, contact your vendor dealer."
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .F.
ELSE
	tcMessage = "Removing registration of " + UPPER(JUSTFNAME(tcCOMServer)) + " succeed."
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .T.
ENDIF
ENDFUNC
*
FUNCTION RegisterDotNetComponent
*  Function: Registers a .Net COM component using RegAsm by retrieving the runtime directory and executing RegAsm from there.
*      Pass: tcDotNetDLL - The .Net assembly to register (Full path to .dll)
*            tcProgId    - One of the ProgIds to register. Used to check if the component registered
*            @tcMessage  - Pass by reference in order to get error or result info
LPARAMETERS tcDotNetDLL, tcProgId, tcMessage, taToDoList
EXTERNAL ARRAY taToDoList
LOCAL llRegister, llUnregister, lcRegAsm, lcFrameworkPath, lnRetVal, lcVersion, lcDllVersion, lcClassId, lcClassDescript, lcModuleVersion, lnRow
PRIVATE pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack

STORE "" TO pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack, tcMessage, lcFrameworkPath, lcVersion
pcPlatform = GetOsVersion(@pc32Or64BitOS, @pcServicePack)
pcOperation = IIF(INLIST(pcPlatform, "Win8", "Win7", "Win2008R2", "Win2008", "Vista"), "RunAs", "Open")

* Try to register
IF NOT IsDotNet(@lcFrameworkPath, @lcVersion)
	tcMessage = "Microsoft .Net Framework version 4 or newer not installed."
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .F.
ENDIF

* If the object has already registered last version then exit.
lcDllVersion = GetBinaryFileVersion(tcDotNetDLL, 2)
DO CASE
	CASE NOT IsCOMObject(tcProgId, @lcClassId, @lcClassDescript, @lcModuleVersion)
	CASE NOT lcModuleVersion == lcDllVersion
		llUnregister = .T.
	OTHERWISE
		RETURN .T.
ENDCASE

lcRegAsm = ADDBS(lcFrameworkPath) + "regasm.exe"
IF NOT FILE(lcRegAsm)  && File doesn't exist
	tcMessage = "Couldn't find RegAsm.exe at:" + CRLF + lcRegAsm
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .F.
ENDIF

IF PCOUNT() < 4
	DECLARE INTEGER ShellExecute IN Shell32.dll INTEGER nWinHandle, STRING cOperation, STRING cFileName, STRING cParameters, STRING cDirectory, INTEGER nShowWindow

	IF llUnregister
		STRTOFILE('"' + lcRegAsm + '" "' + FULLPATH(tcDotNetDLL) + '" /unregister' + CRLF + ;
			'"' + lcRegAsm + '" "' + FULLPATH(tcDotNetDLL) + '" /codebase', "registerdotnetcomponent.bat")
		lnRetVal = ShellExecute(0, pcOperation, "cmd", "/C "+FULLPATH("registerdotnetcomponent.bat"), "", SW_HIDE)
		WAIT "Registering " + UPPER(JUSTFNAME(tcDotNetDLL)) + " .Net COM component..." WINDOW TIMEOUT 1
		DELETE FILE registerdotnetcomponent.bat
	ELSE
		lnRetVal = ShellExecute(0, pcOperation, lcRegAsm, '"' + FULLPATH(tcDotNetDLL) + '" /codebase', "", SW_HIDE)
		WAIT "Registering " + UPPER(JUSTFNAME(tcDotNetDLL)) + " .Net COM component..." WINDOW TIMEOUT 1
	ENDIF

	IF IsCOMObject(tcProgId, @lcClassId, @lcClassDescript)
		tcMessage = "Registration of " + UPPER(JUSTFNAME(tcDotNetDLL)) + " succeed from version " + lcModuleVersion + " -> " + lcDllVersion + "."
		IF PCOUNT() < 3
			MESSAGEBOX(tcMessage)
		ENDIF
		RETURN .T.
	ELSE
		tcMessage = "Registration of " + UPPER(JUSTFNAME(tcDotNetDLL)) + " failed." + CRLF + CRLF + ;
			"You don't have sufficient rights to register DLL. " + CRLF + "Please, contact your vendor dealer."
		IF PCOUNT() < 3
			MESSAGEBOX(tcMessage)
		ENDIF
		RETURN .F.
	ENDIF
ELSE
	IF NOT EMPTY(taToDoList(1))
		DIMENSION taToDoList(ALEN(taToDoList,1)+1, ALEN(taToDoList,2))
	ENDIF
	lnRow = ALEN(taToDoList,1)
	taToDoList[lnRow,1] = tcDotNetDLL
	taToDoList[lnRow,2] = tcProgId
	taToDoList[lnRow,3] = "D" + IIF(llUnregister, "U", "")
	taToDoList[lnRow,4] = '"' + lcRegAsm + '" "' + FULLPATH(tcDotNetDLL) + '"'
	taToDoList[lnRow,5] = lcModuleVersion
	RETURN .T.
ENDIF
ENDFUNC
*
FUNCTION UnRegisterDotNetComponent
*  Function: Unregisters a .Net COM component using RegAsm by retrieving the runtime directory and executing RegAsm from there.
*      Pass: tcDotNetDLL - The .Net assembly to unregister (Full path to .dll)
*            tcProgId    - One of the ProgIds. Used to check if the component registered
*            @tcMessage  - Pass by reference in order to get error or result info
LPARAMETERS tcDotNetDLL, tcProgId, tcMessage
LOCAL lcRegAsm, lnRetVal, lcFrameworkPath, lcVersion, lcClassId, lcClassDescript, lcModuleVersion
PRIVATE pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack

STORE "" TO pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack, tcMessage, lcFrameworkPath, lcVersion
pcPlatform = GetOsVersion(@pc32Or64BitOS, @pcServicePack)
pcOperation = IIF(INLIST(pcPlatform, "Win8", "Win7", "Win2008R2", "Win2008", "Vista"), "RunAs", "Open")

IF NOT IsDotNet(@lcFrameworkPath, @lcVersion)
	tcMessage = "Microsoft .Net Framework version 4 or newer not installed."
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .F.
ENDIF

* If the object hasn't yet registered then exit.
IF NOT IsCOMObject(tcProgId, @lcClassId, @lcClassDescript, @lcModuleVersion)
	RETURN .T.
ENDIF

lcRegAsm = ADDBS(lcFrameworkPath) + "regasm.exe"
IF NOT FILE(lcRegAsm)  && File doesn't exist
	tcMessage = "Couldn't find RegAsm.exe at:" + CRLF + lcRegAsm
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .F.
ENDIF

DECLARE INTEGER ShellExecute IN Shell32.dll INTEGER nWinHandle, STRING cOperation, STRING cFileName, STRING cParameters, STRING cDirectory, INTEGER nShowWindow

lnRetVal = ShellExecute(0, pcOperation, lcRegAsm, '"' + FULLPATH(tcDotNetDLL) + '" /unregister', "", SW_HIDE)
WAIT "Unregistering " + UPPER(JUSTFNAME(tcDotNetDLL)) + " .Net COM component..." WINDOW TIMEOUT 1

IF IsCOMObject(tcProgId, @lcClassId, @lcClassDescript, @lcModuleVersion)
	tcMessage = "Removing registration of " + UPPER(JUSTFNAME(tcDotNetDLL)) + " failed." + CRLF + CRLF + ;
		"You don't have sufficient rights to unregister DLL. " + CRLF + "Please, contact your vendor dealer."
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .F.
ELSE
	tcMessage = "Removing registration of " + UPPER(JUSTFNAME(tcDotNetDLL)) + " succeed."
	IF PCOUNT() < 3
		MESSAGEBOX(tcMessage)
	ENDIF
	RETURN .T.
ENDIF
ENDFUNC
*
FUNCTION BatchRegistration
*  Function: Registers a .Net/COM server components using ShellExecute with ADMIN rights.
LPARAMETERS taToDoList
EXTERNAL ARRAY taToDoList
LOCAL lnRow, lcPlatform, lnRetVal, lcBatFile, lcClassId, lcClassDescript, lcModuleVersion

IF NOT EMPTY(taToDoList(1))
	lcBatFile = "registerdotnetcomcomponents.bat"
	FOR lnRow = 1 TO ALEN(taToDoList,1)
		DO CASE
			CASE "C" $ taToDoList[lnRow,3]
				IF "U" $ taToDoList[lnRow,3]
					STRTOFILE(CRLF + taToDoList[lnRow,4] + ' /unregserver', lcBatFile, .T.)
				ENDIF
				STRTOFILE(CRLF + taToDoList[lnRow,4] + ' /regserver', lcBatFile, .T.)
			CASE "D" $ taToDoList[lnRow,3]
				IF "U" $ taToDoList[lnRow,3]
					STRTOFILE(CRLF + taToDoList[lnRow,4] + ' /unregister', lcBatFile, .T.)
				ENDIF
				STRTOFILE(CRLF + taToDoList[lnRow,4] + ' /codebase', lcBatFile, .T.)
			CASE "L" $ taToDoList[lnRow,3]
				IF "U" $ taToDoList[lnRow,3]
					STRTOFILE(CRLF + "regsvr32 " + taToDoList[lnRow,4] + ' /u /s', lcBatFile, .T.)
				ENDIF
				STRTOFILE(CRLF + "regsvr32 " + taToDoList[lnRow,4] + ' /s', lcBatFile, .T.)
			OTHERWISE
		ENDCASE
	NEXT

	IF FILE(lcBatFile)
		PRIVATE pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack
		STORE "" TO pcOperation, pcPlatform, pc32Or64BitOS, pcServicePack
		pcPlatform = GetOsVersion(@pc32Or64BitOS, @pcServicePack)
		pcOperation = IIF(INLIST(pcPlatform, "Win8", "Win7", "Win2008R2", "Win2008", "Vista"), "RunAs", "Open")

		DECLARE INTEGER ShellExecute IN Shell32.dll INTEGER nWinHandle, STRING cOperation, STRING cFileName, STRING cParameters, STRING cDirectory, INTEGER nShowWindow

		lnRetVal = ShellExecute(0, pcOperation, "cmd", "/C "+FULLPATH(lcBatFile), "", SW_HIDE)

		FOR lnRow = 1 TO ALEN(taToDoList,1)
			WAIT "Registering " + UPPER(JUSTFNAME(taToDoList[lnRow,1])) + " .Net/COM server component..." WINDOW TIMEOUT 1
			lcVersion = GetBinaryFileVersion(taToDoList[lnRow,1], IIF("C" $ taToDoList[lnRow,3], 3, 2))
			taToDoList[lnRow,6] = IsCOMObject(taToDoList[lnRow,2], @lcClassId, @lcClassDescript, @lcModuleVersion)
			IF taToDoList[lnRow,6]
				taToDoList[lnRow,7] = "Registration of " + UPPER(JUSTFNAME(taToDoList[lnRow,1])) + " succeed " + ;
					IIF("C" $ taToDoList[lnRow,3], "for version ", "from version " + taToDoList[lnRow,5] + " -> ") + lcVersion + "."
			ELSE
				taToDoList[lnRow,7] = "Registration of " + UPPER(JUSTFNAME(taToDoList[lnRow,1])) + " failed." + CRLF + CRLF + ;
					"You don't have sufficient rights to register DLL/EXE. " + CRLF + "Please, contact your vendor dealer."
			ENDIF
		NEXT

		DELETE FILE (lcBatFile)
	ENDIF
ENDIF
ENDFUNC
*
FUNCTION IsDotNet
*  Function: Returns whether .Net is installed
*            Optionally returns the framework path and version
*            of the highest installed version.
LPARAMETERS tcFrameworkPath, tcVersion

STORE "" TO tcFrameworkPath, tcVersion

tcVersion = ReadRegistryString(HKEY_LOCAL_MACHINE,"Software\Microsoft\NET Framework Setup\NDP\v4\Client","Version")
IF ISNULL(tcVersion)
	tcVersion = ""
	RETURN .F.
ELSE
	IF GETWORDCOUNT(tcVersion,".") > 2
		tcVersion = LEFT(tcVersion, AT(".", tcVersion, 2) - 1)
	ENDIF
ENDIF

tcFrameworkPath = ReadRegistryString(HKEY_LOCAL_MACHINE,"Software\Microsoft\NET Framework Setup\NDP\v4\Client","InstallPath")
IF ISNULL(tcFrameworkPath)
	tcFrameworkPath = ""
ELSE
	tcFrameworkPath = ADDBS(tcFrameworkPath)
ENDIF

RETURN .T.
ENDFUNC
*
FUNCTION IsCOMObject
* Function: Checks to see if a COM object or ActiveX control exists
*     Pass: tcProgId        - Prog Id of the Class
*           tcClassId       - (Optional) If passed in by reference gets ClassId
*           tcClassDescript - (Optional) by ref
*           tcVersion       - (Optional) by ref
*   Return: .T. or .F.
LPARAMETER tcProgId, tcClassId, tcClassDescript, tcVersion

STORE "" TO tcClassId, tcClassDescript, tcVersion

IF EMPTY(tcProgId)
	RETURN .F.
ENDIF

*** Retrieve ClassId and Server Name
tcClassId = ReadRegistryString(HKEY_CLASSES_ROOT, tcProgId + "\CLSID", "")
IF ISNULL(tcClassId)
	tcClassId = ""
	RETURN .F.
ENDIF

tcClassDescript = ReadRegistryString(HKEY_CLASSES_ROOT, tcProgId, "")
IF ISNULL(tcClassDescript)
	tcClassDescript = ""
ENDIF

tcVersion = ReadRegistryString(HKEY_CLASSES_ROOT, IIF(pc32Or64BitOS = "64", "Wow6432Node\", "")+"CLSID\"+tcClassId+"\Version", "")
IF ISNULL(tcVersion)
	tcVersion = ""
ENDIF

RETURN .T.
ENDFUNC
*
FUNCTION ReadRegistryString
*  Function: Reads a string value from the registry.
*      Pass: tnHKEY    -  HKEY value (in CGIServ.h)
*            tcSubkey  -  The Registry subkey value
*            tcEntry   -  The actual Key to retrieve
*            tlInteger -  Optional - Return an DWORD value
*    Return: Registry String or .NULL. on not found
LPARAMETERS tnHKey, tcSubkey, tcEntry, tlInteger
LOCAL lnRegHandle, lnResult, lnSize, lcDataBuffer, tnType

tnHKey = IIF(VARTYPE(tnHKey) = "N", tnHKey, HKEY_LOCAL_MACHINE)

lnRegHandle = 0

* Open and close the registry key
DECLARE INTEGER RegOpenKey IN Win32API INTEGER nHKey, STRING cSubKey, INTEGER @nHandle
DECLARE Integer RegCloseKey IN Win32API INTEGER nHKey

lnResult = RegOpenKey(tnHKey, tcSubKey, @lnRegHandle)
IF lnResult = ERROR_SUCCESS
	* Return buffer to receive value
	* Need to define here specifically for Return Type for lpdData parameter or VFP will choke.
	IF tlInteger
		* Here's it's an INTEGER
		DECLARE INTEGER RegQueryValueEx IN Win32API AS RegQueryInt INTEGER nHKey, STRING lpszValueName, INTEGER dwReserved, INTEGER @lpdwType, INTEGER @lpbData, INTEGER @lpcbData

		lcDataBuffer = 0
		lnSize = 4
		lnType = REG_DWORD
		lnResult = RegQueryInt(lnRegHandle, tcEntry, 0, @lnType, @lcDataBuffer, @lnSize)
	ELSE
		*** Here it's STRING.
		DECLARE INTEGER RegQueryValueEx IN Win32API INTEGER nHKey, STRING lpszValueName, INTEGER dwReserved, INTEGER @lpdwType, STRING @lpbData, INTEGER @lpcbData

		lcDataBuffer = SPACE(MAX_INI_BUFFERSIZE)
		lnSize = LEN(lcDataBuffer)
		lnType = REG_DWORD
		lnResult = RegQueryValueEx(lnRegHandle, tcEntry, 0, @lnType, @lcDataBuffer, @lnSize)
	ENDIF
ENDIF

RegCloseKey(lnRegHandle)

DO CASE
	CASE lnResult <> ERROR_SUCCESS 
		*** Not Found
		RETURN .NULL.
	CASE tlInteger
		RETURN lcDataBuffer
	CASE lnSize > 1
		*** Return string and strip out NULLs
		RETURN LEFT(lcDataBuffer, lnSize-1)
	OTHERWISE
		RETURN ""
ENDCASE
ENDFUNC
*
PROCEDURE GetBinaryFileVersion
LPARAMETERS tcFileName, tnFormat
* tnFormat - Number of version numbers. >3 is default.
* tnFormat=3 - VVVV.vvvv.bbbb
* tnFormat=2 - VVVV.vvvv
LOCAL lcVersion, lnLen, lcRawData, lcData

DECLARE INTEGER GetFileVersionInfoSize IN version.dll STRING lptstrFilename, INTEGER lpdwHandle
DECLARE INTEGER GetFileVersionInfo IN version.dll STRING lptstrFilename, INTEGER dwHandle, INTEGER dwLen, STRING @lpData

tcFileName = FULLPATH(tcFileName)
lnLen = GetFileVersionInfoSize(tcFileName, 0)
lcRawData = SPACE(lnLen)
GetFileVersionInfo(tcFileName, 0, lnLen, @lcRawData)
lcData = STRCONV(lcRawData,6)
lcVersion = CHRTRAN(STREXTRACT(SUBSTR(lcData, AT("FileVersion",lcData)), CHR(0), CHR(0), 2, 2), ", ", ".")
IF NOT EMPTY(tnFormat) AND tnFormat < MIN(4,GETWORDCOUNT(lcVersion,"."))
	lcVersion = LEFT(lcVersion, AT(".", lcVersion, tnFormat) - 1)
ENDIF

RETURN lcVersion
ENDPROC
*
PROCEDURE GetOsVersion
LPARAMETERS tc32Or64BitOS, tcServicePack
LOCAL lcPlatform, lcOS, llIsWow64ProcessExists, llIs64BitOS, lnIsWow64Process

lcOS = OS(1)
DO CASE
	CASE "10.00" $ lcOS AND OS(11) = "1"	&& Need manifest otherwise 6.02
		lcPlatform = "Win10"
	CASE "10.00" $ lcOS						&& Need manifest otherwise 6.02
		lcPlatform = "Win2016"
	CASE "6.03" $ lcOS AND OS(11) = "1"		&& Need manifest otherwise 6.02
		lcPlatform = "Win81"
	CASE "6.03" $ lcOS						&& Need manifest otherwise 6.02
		lcPlatform = "Win2012R2"
	CASE "6.02" $ lcOS AND OS(11) = "1"
		lcPlatform = "Win8"
	CASE "6.02" $ lcOS
		lcPlatform = "Win2012"
	CASE "6.01" $ lcOS AND OS(11) = "1"
		lcPlatform = "Win7"
	CASE "6.01" $ lcOS
		lcPlatform = "Win2008R2"
	CASE "6.00" $ lcOS AND OS(11) = "1"
		lcPlatform = "Vista"
	CASE "6.00" $ lcOS
		lcPlatform = "Win2008"
	CASE "5.02" $ lcOS
		lcPlatform = "Win2003"
	CASE "5.01" $ lcOS
		lcPlatform = "WinXP"
	CASE "5.0" $ lcOS
		lcPlatform = "Win2000"
	CASE "NT" $ lcOS
		lcPlatform = "WinNT"
	CASE "4.0" $ lcOS OR "3.9" $ lcOS
		lcPlatform = "Win95"
	CASE "4.1" $ lcOS
		lcPlatform = "Win98"
	CASE "4.9" $ lcOS
		lcPlatform = "WinME"
	CASE "3." $ lcOS
		lcPlatform = "Win31"
	OTHERWISE
		lcPlatform = "(Unknown)"
ENDCASE

DECLARE LONG GetModuleHandle IN Win32API STRING lpModuleName
DECLARE LONG GetProcAddress IN Win32API LONG hModule, STRING lpProcName

llIsWow64ProcessExists = (GetProcAddress(GetModuleHandle("kernel32"),"IsWow64Process") <> 0)
llIs64BitOS = .F.
IF llIsWow64ProcessExists
	DECLARE LONG GetCurrentProcess IN Win32API
	DECLARE LONG IsWow64Process IN Win32API LONG hProcess, LONG @ Wow64Process
	lnIsWow64Process = 0
	* IsWow64Process function return value is nonzero if it succeeds
	* The second output parameter value will be nonzero if VFP application is running under 64-bit OS
	IF IsWow64Process(GetCurrentProcess(), @lnIsWow64Process) <> 0
		llIs64BitOS = (lnIsWow64Process <> 0)
	ENDIF
ENDIF
tc32Or64BitOS = IIF(llIs64BitOS, "64", "32")
tcServicePack = OS(7)

RETURN lcPlatform
ENDPROC
*
FUNCTION FormatVersion
LPARAMETERS tcVersion, tcRetVal
LOCAL lcVersion

lcVersion = ""	&& aaaa.bbbb.cccc.ddddd
FOR i = 1 TO GETWORDCOUNT(tcVersion,".")
	lcVersion = lcVersion + IIF(EMPTY(lcVersion), "", ".") + PADL(GETWORDNUM(tcVersion, i, "."), IIF(i=4,5,4), "0")
NEXT

tcRetVal = lcVersion

RETURN lcVersion
ENDFUNC
* Convert post fields to histpost fields in cursor or similar.
PROCEDURE ConvertFieldNames
LPARAMETERS tcFromAlias, tcToAlias, tcFromPrefix, tcToPrefix, tcWhere
LOCAL i, lnArea, lcFromField, lcToField, lcToFields
LOCAL ARRAY laFields(1)

lnArea = SELECT()
lcAlias = ALIAS()

tcToAlias = EVL(tcToAlias,tcFromAlias)
IF EMPTY(tcWhere)
	tcWhere = ""
ELSE
	tcWhere = "WHERE " + tcWhere
ENDIF
lcToFields = ""
FOR i = 1 TO AFIELDS(laFields, tcFromAlias)
	lcFromField = laFields(i,1)
	lcToField = STRTRAN(lcFromField, tcFromPrefix, tcToPrefix)
	lcToFields = lcToFields + IIF(EMPTY(lcToFields), "", ",") + IIF(lcFromField = lcToField, "", lcFromField+" AS ") + lcToField
NEXT
SELECT &lcToFields FROM &tcFromAlias INTO CURSOR &tcToAlias &tcWhere READWRITE

IF UPPER(tcToAlias) == UPPER(tcFromAlias) AND UPPER(lcAlias) == UPPER(tcFromAlias)
	SELECT(lcAlias)
ELSE
	SELECT(lnArea)
ENDIF
ENDPROC
*