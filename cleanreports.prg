IF MESSAGEBOX(GetLangText("COMMON","TXT_CLEANREPORTS"),33,GetLangText("FUNC","TXT_QUESTION"))=1
	LOCAL LNotUsed, LSelected, LRecno, LFrx
	LSelected = ALIAS()
	LRecno = RECNO()
	WAIT window nowait GetLangText("COMMON", "T_PLEASEWAIT")
	IF !USED('lists')
		LNotUsed = .T.
		OpenFileDirect(.F.,"lists")
		SELECT lists
	ELSE
		SELECT lists
		GOTO TOP
	ENDIF
	SCAN ALL FOR (!EMPTY(li_frx) AND !li_custom)
		LFrx = gcReportdir+ALLTRIM(li_frx)
		IF FILE(LFrx)
			USE &LFrx ALIAS onereport IN 0
			SELECT onereport
			BLANK FIELDS Tag, Tag2
			USE
			SELECT lists
		ENDIF
	ENDSCAN
	IF LNotUsed
		SELECT lists
		USE
	ENDIF
	SELECT &LSelected
	GO LRecno
	WAIT CLEAR
	MESSAGEBOX(GetLangText("COMMON","TXT_COMPLETED"),64,GetLangText("RECURRES","TXT_INFORMATION"))
ENDIF
