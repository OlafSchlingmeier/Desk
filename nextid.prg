LPARAMETERS lp_cCode, lp_uLast, lp_lFromMain
* Initialize ID for lp_cCode
LOCAL l_uLastID, l_nArea, l_lInitialize, l_cIdTableName, l_cPrefix, l_nIDLength

l_nArea = SELECT()
lp_cCode = UPPER(PADR(lp_cCode,8))

IF lp_lFromMain
     l_cIdTableName = "idmain"
ELSE
     l_cIdTableName = "id"
ENDIF
DO CASE
	CASE odbc()
		IF PCOUNT()>1
			l_uLastID = _screen.oGlobal.oGData.TBNextId(lp_cCode, lp_uLast)
		ELSE
			l_uLastID = _screen.oGlobal.oGData.TBNextId(lp_cCode)
		ENDIF
	CASE INLIST(lp_cCode, "ROOM    ", "ROOMTYPE", "CWRTLINK")
		l_cPrefix = "@"
		l_nIDLength = 3		&& ID length without prefix
		l_lInitialize = (PCOUNT() > 1) AND TYPE("lp_uLast") == "C"
		l_uLastID = IIF(l_lInitialize, ALLTRIM(IIF(LEFT(lp_uLast,LEN(l_cPrefix)) == l_cPrefix, SUBSTR(lp_uLast,LEN(l_cPrefix)+1), lp_uLast)), "")
		IF DOpen(l_cIdTableName)
			IF DLocate(l_cIdTableName, 'id_code = ' + SqlCnv(lp_cCode))
				IF DLock(l_cIdTableName, -1)
					IF NOT l_lInitialize
						l_uLastID = GetNewCharId(PADL(SUBSTR(ALLTRIM(&l_cIdTableName..id_clast), LEN(l_cPrefix)+1), l_nIDLength))
					ENDIF
					IF NOT EMPTY(l_uLastID)
						l_uLastID = l_cPrefix + PADL(l_uLastID, l_nIDLength, "A")
					ENDIF
					REPLACE id_clast WITH l_uLastID IN &l_cIdTableName
					FLUSH
					DUnLock()
				ENDIF
			ELSE
				IF DAppend(l_cIdTableName)
					IF DLock(l_cIdTableName, -1)
						IF NOT l_lInitialize
							l_uLastID = GetNewCharId(PADL(SUBSTR(ALLTRIM(&l_cIdTableName..id_clast), LEN(l_cPrefix)+1), l_nIDLength))
						ENDIF
						IF NOT EMPTY(l_uLastID)
							l_uLastID = l_cPrefix + PADL(l_uLastID, l_nIDLength, "A")
						ENDIF
						REPLACE id_clast WITH l_uLastID, ;
								id_code WITH lp_cCode IN &l_cIdTableName
						FLUSH
						DUnlock()
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	CASE lp_cCode = "LISTS   "
		IF DOpen(l_cIdTableName)
			IF DLocate(l_cIdTableName, 'id_code = ' + SqlCnv(lp_cCode))
				IF DLock(l_cIdTableName, -1)
					l_uLastID = MAX(1000,&l_cIdTableName..id_last + 1)
					REPLACE id_last WITH l_uLastID IN &l_cIdTableName
					FLUSH
					DUnlock()
				ENDIF
			ELSE
				IF DAppend(l_cIdTableName)
					IF DLock(l_cIdTableName, -1)
						l_uLastID = 1000
						REPLACE id_last WITH l_uLastID, ;
								id_code WITH lp_cCode IN &l_cIdTableName
						FLUSH
						DUnlock()
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	OTHERWISE
		l_lInitialize = (PCOUNT() > 1) AND TYPE("lp_uLast") == "N"
		l_uLastID = IIF(l_lInitialize, lp_uLast, 0)
		IF DOpen(l_cIdTableName)
			IF DLocate(l_cIdTableName, 'id_code = ' + SqlCnv(lp_cCode))
				IF DLock(l_cIdTableName, -1)
					IF NOT l_lInitialize
						l_uLastID = &l_cIdTableName..id_last + 1
					ENDIF
					REPLACE id_last WITH l_uLastID IN &l_cIdTableName
					FLUSH
					DUnlock()
				ENDIF
			ELSE
				IF DAppend(l_cIdTableName)
					IF DLock(l_cIdTableName, -1)
						IF NOT l_lInitialize
							l_uLastID = 1
						ENDIF
						REPLACE id_last WITH l_uLastID, ;
								id_code WITH lp_cCode IN &l_cIdTableName
						FLUSH
						DUnlock()
					ENDIF
				ENDIF
			ENDIF
		ENDIF
ENDCASE

SELECT (l_nArea)

RETURN l_uLastID
ENDFUNC
*
FUNCTION GetNewCharId
LPARAMETERS lp_cLastID
LOCAL l_cLastID, l_nIDLength, l_nCurrPos, l_cNextChar

l_nIDLength = LEN(lp_cLastID)
l_cLastID = PADL(ALLTRIM(lp_cLastID), l_nIDLength, "A")

IF NOT EMPTY(lp_cLastID)
	FOR l_nCurrPos = l_nIDLength TO 1 STEP -1
		l_cCurrChar = SUBSTR(l_cLastID, l_nCurrPos, 1)
		IF BETWEEN(l_cCurrChar, "A", "Y")
			l_cNextChar = CHR(ASC(l_cCurrChar) + 1)
			l_cLastID = STUFF(l_cLastID, l_nCurrPos, 1, l_cNextChar)
			EXIT
		ELSE
			l_cLastID = STUFF(l_cLastID, l_nCurrPos, 1, "A")
		ENDIF
	NEXT
ENDIF

RETURN l_cLastID
ENDFUNC
*