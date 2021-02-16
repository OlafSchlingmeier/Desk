LPARAMETER lp_lPack, lp_nRecordNumber, lp_lConsist, lp_lTalk, lp_lProgress, lp_lForcePackAll
EXTERNAL ARRAY alGroup
LOCAL l_cAliasDBF
LOCAL l_nOldArea
LOCAL l_lUsedApartner, l_oIndexProgress
LOCAL l_nChoice
LOCAL l_cDesExpression
LOCAL l_cDescriptionMacro
LOCAL l_lDoneIt
LOCAL l_nFileRecordNumber
LOCAL l_nFileIndexOrder
LOCAL l_cFileName
LOCAL l_cKeyExpression
LOCAL l_cKeyMacro
LOCAL l_cOrder
LOCAL l_nRecNo
LOCAL l_cTagExpression
LOCAL l_nTagNumber
LOCAL l_cTempAlias
LOCAL l_lUniqueMacro
LOCAL l_cUniExpression
LOCAL l_cLastName, l_nGroupToMaintain
LOCAL l_lForcePack, l_cDeleted, l_cSqlSelect, l_curDupl, l_uRecId, l_lCloseHistres, l_lCloseReservat, l_curMaxId, l_nRiMaxId, l_nCurrent, ;
		l_nCodePage, l_cTableNameAndPath, l_lEnabled, l_lRemoteFlagTablesEnabled
LOCAL ARRAY l_aOpenAlias(1)
IF PCOUNT()<3
	lp_lConsist = .F.
ENDIF
IF PCOUNT()<4
	lp_lTalk = .T.
ENDIF

IF ALEN(alGroup,1)=10
      DIMENSION alGroup[11]
ENDIF

DO FORM "forms\progress" WITH ;
		IIF(lp_lPack, GetLangText("OPENFILE","TXT_PACKANDINDEX"), ;
			GetLangText("OPENFILE","TXT_INDEX")), ;
			lp_lTalk, lp_lProgress NAME l_oIndexProgress

l_nOldArea = SELECT()
l_nFileRecordNumber = RECNO("Files")
l_nFileIndexOrder = ORDER("Files")
l_nCodePage = CPCURRENT()

IF NOT _screen.oGlobal.lmultiproper
     l_nGroupToMaintain = 10
ELSE
     * This station maintains server tables too
     l_nGroupToMaintain = 11
ENDIF


IF (_screen.oGlobal.lusemainserver AND _screen.oGlobal.lmultiproper) OR NOT _screen.oGlobal.lusemainserver
	* if multiproper install, and this is main station, maintain remote tables
	* if this is no multiproper install, maintain all tables (bspost, bsarcct etc.)
	l_lRemoteFlagTablesEnabled = .T.
ELSE
	l_lRemoteFlagTablesEnabled = .F.
ENDIF
SELECT fiLes
SET ORDER TO 1   && UPPER(FI_NAME)

GOTO TOP IN "Files"
l_oIndexProgress.InitProgress(RECCOUNT("files"))
DO WHILE ( NOT EOF("Files"))
	l_oIndexProgress.Progress()
	l_cAliasDBF = UPPER(ALLTRIM(fiLes.fi_alias))
	l_cFileName = UPPER(ALLTRIM(fiLes.fi_name))
	l_lEnabled = RECNO("Files")==lp_nRecordNumber .OR. ; && This table is selected thru parameter
		(BETWEEN(fiLes.fi_group, 1,  l_nGroupToMaintain) AND alGroup(fiLes.fi_group) AND IIF(l_lRemoteFlagTablesEnabled,.T.,NOT "R" $ files.fi_flag)) ; && Table is in fi_group, and this group is selected and remote tables are enabled
		AND l_cFileName==l_cAliasDBF && Process table only once, when wame table is entered unter multiple aliases

	IF l_lEnabled
		IF l_cFileName == "LICENSE"
			IF USED("LICENSE")
				IF ISEXCLUSIVE("LICENSE")
					* Delete all records from license table. Function CheckNetID would add needed records automaticly.
					SELECT license
					DELETE ALL
					PACK
				ENDIF
			ENDIF
			SKIP 1 IN "Files"
			LOOP
		ENDIF
		l_nRecNo = RECNO("Files")
		IF NOT EMPTY(l_aOpenAlias(1))
			DIMENSION l_aOpenAlias(1)
			l_aOpenAlias(1) = .F.
		ENDIF
		= SEEK(UPPER(l_cFileName), "Files")
		DO WHILE (NOT EOF("Files") AND UPPER(TRIM(fiLes.fi_name)) == UPPER(l_cFileName))
			l_cTempAlias = ALLTRIM(fiLes.fi_alias)
			IF (USED(l_cTempAlias))
				IF EMPTY(l_aOpenAlias(1))
					DIMENSION l_aOpenAlias(1,3)
				ELSE
					DIMENSION l_aOpenAlias(ALEN(l_aOpenAlias,1)+1,3)
				ENDIF
				l_aOpenAlias(ALEN(l_aOpenAlias,1),1) = l_cTempAlias
				l_aOpenAlias(ALEN(l_aOpenAlias,1),2) = ISEXCLUSIVE(l_cTempAlias)
				l_aOpenAlias(ALEN(l_aOpenAlias,1),3) =  CURSORGETPROP("Buffering", l_cTempAlias)
				= dcLose(l_cTempAlias)
			ENDIF
			SKIP 1 IN "Files"
		ENDDO
		GOTO l_nRecNo IN "Files"
		l_lSuccessOpenTable = (opEnfile(.T.,l_cAliasDBF,.F.,.F.,1))
		* Check if we realy opened remote table
		IF l_lSuccessOpenTable AND ("R" $ files.fi_flag)
			l_lSuccessOpenTable = (UPPER(JUSTSTEM(DBF(l_cAliasDBF))) == UPPER(l_cAliasDBF))
		ENDIF
		IF l_lSuccessOpenTable
			l_oIndexProgress.SetCaption(ALLTRIM(fiLes.fi_descrip))
			l_lForcePack = .F.

			* Code page check
			IF CPDBF(l_cAliasDBF)<>l_nCodePage
				*ASSERT .F.
				l_cTableNameAndPath = DBF(l_cAliasDBF)
				dclose(l_cAliasDBF)
				cpzero(l_cTableNameAndPath,l_nCodePage,.T.)
				GOTO l_nRecNo IN "Files"
				opEnfile(.T.,l_cAliasDBF,.F.,.F.,1)
			ENDIF

			IF INLIST(PADR(l_cAliasDBF,8), "HISTRES ", "RESERVAT", "RESIFCIN", "HRESROOM", "RESROOMS")
				l_oIndexProgress.SetLabel(1, GetLangText("OPENFILE","TXT_CHECKING_FOR_CANDIDATE"))
				l_oIndexProgress.SetLabel(2, UPPER(TRIM(l_cAliasDBF)))
				l_oIndexProgress.SetLabel(3, LTRIM(STR(RECCOUNT(l_cAliasDBF))) + " " + GetLangText("OPENFILE","TXT_RECORD"))
				DO CASE
					CASE Odbc()
					CASE INLIST(PADR(l_cAliasDBF,8), "HRESROOM", "RESROOMS")
						IF NOT USED("histres")
							l_lCloseHistres = .T.
							OpenFile(,"histres")
						ENDIF
						IF NOT USED("reservat")
							l_lCloseReservat = .T.
							OpenFile(,"reservat")
						ENDIF
						l_cDeleted = SET("Deleted")
						SET DELETED OFF
						TEXT TO l_cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
							SELECT ri_rroomid, COUNT(ri_rroomid) FROM <<l_cAliasDBF>>
								GROUP BY 1
								HAVING COUNT(ri_rroomid) > 1
						ENDTEXT
						l_curDupl = SqlCursor(l_cSqlSelect)
						l_lForcePack = (RECCOUNT(l_curDupl) > 0)
						DClose(l_curDupl)
						SET DELETED ON
						DELETE FOR ri_rroomid = 0 IN &l_cAliasDBF
						TEXT TO l_cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
							SELECT <<l_cAliasDBF>>.*, <<IIF(PADR(l_cAliasDBF,8) = "HRESROOM", "histres.hr_reserid", "reservat.rs_reserid")>> AS reserid FROM <<l_cAliasDBF>>
								INNER JOIN
									(SELECT ri_rroomid, COUNT(ri_rroomid) FROM <<l_cAliasDBF>>
										WHERE ri_rroomid > 0
										GROUP BY 1
										HAVING COUNT(ri_rroomid) > 1) a
									ON <<l_cAliasDBF>>.ri_rroomid = a.ri_rroomid
								LEFT JOIN <<IIF(PADR(l_cAliasDBF,8) = "HRESROOM", "histres ON ri_reserid = hr_reserid AND BETWEEN(ri_date, hr_arrdate, hr_depdate)","reservat ON ri_reserid = rs_reserid AND BETWEEN(ri_date, rs_arrdate, rs_depdate)")>>
								ORDER BY <<l_cAliasDBF>>.ri_rroomid
						ENDTEXT
						l_curDupl = SqlCursor(l_cSqlSelect)
						SET DELETED &l_cDeleted
						IF RECCOUNT(l_curDupl) > 0
							SET ORDER TO "" IN &l_cAliasDBF
							SET ORDER TO "" IN histres
							SET ORDER TO "" IN reservat
							l_uRecId = 0
							IF EMPTY(l_nRiMaxId)
								l_curMaxId = SqlCursor("SELECT MAX(ri_rroomid) AS c_rimaxid FROM (SELECT hresroom.ri_rroomid FROM hresroom UNION ALL SELECT resrooms.ri_rroomid FROM resrooms) a")
								l_nRiMaxId = &l_curMaxId..c_rimaxid
								DClose(l_curMaxId)
							ENDIF
							ON KEY LABEL ALT+Q GO BOTTOM IN &l_curDupl
							l_nCurrent = 0
							SELECT &l_curDupl
							SCAN
								IF ROUND(100*RECNO()/RECCOUNT(),0) > l_nCurrent
									l_nCurrent = ROUND(100*RECNO()/RECCOUNT(),0)
									WAIT l_cAliasDBF + " duplicates: " + TRANSFORM(l_nCurrent)+" %" WINDOW NOWAIT
								ENDIF
								DO CASE
									CASE NOT DLocate(l_cAliasDBF, "ri_rroomid = " + SqlCnv(ri_rroomid,.T.) + ;
											" AND STR(ri_reserid,12,3)+DTOS(ri_date) = " + SqlCnv(STR(ri_reserid,12,3)+DTOS(ri_date),.T.))
										* Locate suspicious record in hresroom.dbf or resrooms.dbf
									CASE ISNULL(reserid)
										* Delete record from hresroom.dbf which not exists in histres.dbf
										DELETE IN &l_cAliasDBF
									CASE l_uRecId <> ri_rroomid
										* If this is first duplicate record than leave old ID
										l_uRecId = ri_rroomid
									OTHERWISE
										* Get new ID for valid duplikates
										l_nRiMaxId = l_nRiMaxId + 1
										REPLACE ri_rroomid WITH l_nRiMaxId IN &l_cAliasDBF
								ENDCASE
							ENDSCAN
							WAIT CLEAR
							ON KEY LABEL ALT+Q
							NextId("RESROOMS",l_nRiMaxId)
						ENDIF
						IF l_lCloseHistres
							DClose("histres")
						ENDIF
						IF l_lCloseReservat
							DClose("reservat")
						ENDIF
						DClose(l_curDupl)
					OTHERWISE
				ENDCASE
			ENDIF
			IF lp_lForcePackAll OR l_lForcePack OR (lp_lPack AND AT("P", fiLes.fi_flag)>0)
				l_oIndexProgress.SetLabel(1, GetLangText("OPENFILE","TXT_PACKING"))
				l_oIndexProgress.SetLabel(2, UPPER(TRIM(l_cAliasDBF)))
				l_oIndexProgress.SetLabel(3, LTRIM(STR(RECCOUNT(l_cAliasDBF)))+" "+ ;
					GetLangText("OPENFILE","TXT_RECORD"))
				DoPack(l_cAliasDBF)
				IF AT("C", fiLes.fi_flag)>0
					DoPackCopyPacked(l_cAliasDBF)
				ENDIF
			ENDIF
			IF ("L"$fiLes.fi_flag)
				l_oIndexProgress.SetLabel(1, GetLangText("OPENFILE","TXT_LANGUAGE_FIELD_UPDATE"))
				l_oIndexProgress.SetLabel(2, UPPER(TRIM(l_cAliasDBF)))
				l_oIndexProgress.SetLabel(3, LTRIM(STR(RECCOUNT(l_cAliasDBF)))+" "+ ;
					GetLangText("OPENFILE","TXT_RECORD"))
				cdEfaultlanguage = STR(MAX(defaultLanguage(), 1), 1)
				SELECT (l_cAliasDBF)
				GOTO TOP
				cfIeld = SUBSTR(FIELD(1), 1, 3)+"Lang"
				DO WHILE ( NOT EOF())
					cdEfamacro = cfIeld+cdEfaultlanguage
					IF ( !Empty(&cDefaMacro) )
						cdEfatext = EVALUATE(cdEfamacro)
					ELSE
						cdEfatext = EVALUATE(cfIeld+"1")
					ENDIF
					FOR nfLdcount = 1 TO 9
						ccUrfield = cfIeld+STR(nfLdcount, 1)
						If ( Empty(&cCurField) )
							Replace &cCurField With cDefaText
						ENDIF
					ENDFOR
					SKIP 1
				ENDDO
				l_oIndexProgress.SetCaption(IIF(lp_lPack,  ;
					GetLangText("OPENFILE","TXT_PACKANDINDEX"),  ;
					GetLangText("OPENFILE","TXT_INDEX")))
			ENDIF
			l_oIndexProgress.SetLabel(1, GetLangText("OPENFILE","TXT_INDEXING"))
			SELECT (l_cAliasDBF)
			DELETE TAG alL
			FOR l_nTagNumber = 1 TO 45
				l_cKeyMacro = "files.fi_key"+LTRIM(STR(l_nTagNumber))
				l_cDescriptionMacro = "files.fi_des"+LTRIM(STR(l_nTagNumber))
				l_lUniqueMacro = "files.fi_uni"+LTRIM(STR(l_nTagNumber))

				IF TYPE(l_cKeyMacro)="C" ; && Check if exists this key field in files table in sole old version
						AND ( NOT EMPTY(EVALUATE(l_cKeyMacro)))
					l_cTagExpression = "TAG"+LTRIM(STR(l_nTagNumber))
					l_cKeyExpression = ALLTRIM(EVALUATE(l_cKeyMacro))
					l_cDesExpression = EVALUATE(l_cDescriptionMacro)
					l_cUniExpression = EVALUATE(l_lUniqueMacro)
					SELECT (l_cAliasDBF)
					l_oIndexProgress.SetLabel(2, UPPER(TRIM(l_cAliasDBF)+" "+ ;
						l_cTagExpression))
					l_oIndexProgress.SetLabel(3, LTRIM(STR(RECCOUNT()))+" "+ ;
						GetLangText("OPENFILE","TXT_RECORD"))
					SET TALK ON  
					SET TALK WINDOW wtAlk
					DO CASE
						CASE (l_cUniExpression)
							IF (l_cDesExpression)
								Index On &l_cKeyExpression Tag &l_cTagExpression DESCENDING CANDIDATE
							ELSE
								Index On &l_cKeyExpression Tag &l_cTagExpression CANDIDATE
							ENDIF
						CASE (l_cDesExpression)
							Index On &l_cKeyExpression Tag &l_cTagExpression DESCENDING
						OTHERWISE
							Index On &l_cKeyExpression Tag &l_cTagExpression
					ENDCASE
					SET TALK OFF
				ENDIF
			ENDFOR
		ENDIF
		= dcLose(l_cAliasDBF)
		SELECT fiLes
		l_lDoneIt = .F.
		IF NOT EMPTY(l_aOpenAlias(1))
			l_nRecNo = RECNO("Files")
			FOR i = 1 TO ALEN(l_aOpenAlias,1)
				l_lDoneIt = .T.
				OpenFile(l_aOpenAlias[i,2],l_aOpenAlias[i,1],,,l_aOpenAlias[i,3])
			NEXT
			GOTO l_nRecNo IN "Files"
			SELECT fiLes
		ENDIF
		IF (l_lDoneIt)
			= reLations()
		ENDIF
		IF (l_cFileName=="ADDRESS" AND USED("Reservat"))
			l_oIndexProgress.SetLabel(1, GetLangText("OPENFILE","TXT_RELATING"))
			l_oIndexProgress.SetLabel(3, LTRIM(STR(RECCOUNT("Reservat")))+" "+ ;
				GetLangText("OPENFILE","TXT_RECORD"))
			l_lUsedApartner = .T.
			IF NOT USED("apartner")
				openfiledirect(.F., "apartner")
				l_lUsedApartner = .F.
			ENDIF
			SELECT reServat
			SET ORDER IN "Reservat" TO 0
			SCAN WHILE ( NOT EOF("Reservat"))
				IF (MOD(RECNO("reservat"), 25)==0)
					l_oIndexProgress.SetLabel(2, STR(RECNO("Reservat")))
				ENDIF
*				nsEppos = AT('/', adDress.ad_lname)
*				IF nsEppos>0
*					clAstname = UPPER(adDress.ad_lname)
*                         IF nsEppos<LEN(adDress.ad_lname)
*                               csHarename = UPPER(SUBSTR(adDress.ad_lname,  ;
*                               nsEppos+1))
*                         ELSE
*                               csHarename = ''
*                         ENDIF
*                    ELSE
*                         clAstname = UPPER(adDress.ad_lname)
*                         csHarename = ''
*                    ENDIF
				IF reservat.rs_addrid # reservat.rs_compid OR NOT reservat.rs_noaddr
					IF (reServat.rs_addrid = reServat.rs_compid AND ;
						NOT EMPTY(rs_apname)) AND USED("apartner") AND ;
						SEEK(reservat.rs_apid,"apartner","tag3")
						l_cLastName = UPPER(apartner.ap_lname)
					ELSE
						l_cLastName = UPPER(adDress.ad_lname)
					ENDIF
					REPLACE reServat.rs_lname WITH l_cLastName&&,  ;
*							reServat.rs_sname WITH csHarename
				ENDIF
				IF ( NOT EMPTY(reServat.rs_compid))
					REPLACE reServat.rs_company WITH  ;
						UPPER(coMpany.ad_company)
				ELSE
					REPLACE reServat.rs_company WITH ""
				ENDIF
				IF ( NOT EMPTY(reServat.rs_agentid))
					REPLACE reServat.rs_agent WITH  ;
						UPPER(agEnt.ad_company)
				ELSE
					REPLACE reServat.rs_agent WITH ""
				ENDIF
			ENDSCAN
			SET ORDER IN "Reservat" TO 1
			SELECT fiLes
			IF NOT l_lUsedApartner
				USE IN apartner
			ENDIF
		ENDIF
	ENDIF
	SKIP 1 IN "Files"
ENDDO
SET TALK OFF
l_oIndexProgress.release()
IF lp_lConsist AND USED("address") AND USED("reservat") AND USED("post") AND USED("id")
	= CheckReserID()
	= CheckAddressID()
	= CheckPostID()
ENDIF
IF lp_lConsist
	= CheckAraccounts()
	= CheckRooms()
	= CheckResrooms()
	= CheckRatecodeID()
	= CheckSharing()
	= CheckRessplit()
	= CheckListID()
ENDIF
GOTO l_nFileRecordNumber IN "Files"
SET ORDER IN "Files" TO l_nFileIndexOrder
SELECT (l_nOldArea)
RETURN
ENDFUNC
*
FUNCTION CitadelPack
LPARAMETER lp_cAliasDbf
 PRIVATE cfIlename
 PRIVATE nrEcords
 PRIVATE ntHeselect
 LOCAL tdate, ctemptable, lpackneeded
 ntHeselect = SELECT()
 ctemptable = _screen.oGlobal.choteldir+"Tmp\"+SYS(2015)
 SET DELETED OFF
 SELECT (lp_cAliasDbf)
 COPY TO (ctemptable) ALL FOR DELETED()
 nrEcords = _TALLY
 IF (nrEcords>0)
      lpackneeded = .T.
      USE (ctemptable) ALIAS temptbl IN 0 EXCLUSIVE
      SELECT temptbl
      ALTER TABLE temptbl ADD datepacked t
      tdate = DATETIME()
      REPLACE ALL datepacked WITH tdate IN temptbl
      cfIlename = _screen.oGlobal.choteldir+"Packed\"+lp_cAliasDbf+".DBF"
      IF NOT FILE(cfIlename)
           SELECT temptbl
           COPY TO (cfIlename) STRUCTURE
      ENDIF
      USE (cfIlename) ALIAS coPyofit IN 0 EXCLUSIVE
      IF USED("coPyofit")
           CitadelPackCheckStructure(lp_cAliasDbf, "coPyofit")
           SELECT coPyofit
           IF TYPE("coPyofit.datepacked")=="U" && If old pack file is found, without datepacked field
                ALTER TABLE coPyofit ADD datepacked t
           ENDIF
           APPEND FROM DBF("temptbl")
           = clOsefile("CopyOfIt")
      ELSE
           calerttext = "Fehler: kann nicht Datei " + cfIlename + " öffnen."
           alert(calerttext)
           = erRormsg("CITADELPACK: " + calerttext,.F.)
      ENDIF
      = clOsefile("temptbl")
 ENDIF
 SET DELETED ON
 SELECT (ntHeselect)
 DELETE FILE (ctemptable+".*")
 RETURN lpackneeded
ENDFUNC
*
PROCEDURE CitadelPackCheckStructure
* Check is table structure is changed, and update then table structure in packed folder, to prevent data loss
LPARAMETERS lp_cOrig, lp_cCopy
LOCAL l_nFieldsCount, i, l_lMustUpdate, l_nFieldsCountCopy, l_cField, l_cFType, l_nFLength, l_nFDec, l_nPos
LOCAL ARRAY l_aFields(1), l_aFieldsCopy(1)

l_nFieldsCountCopy = AFIELDS(l_aFieldsCopy, lp_cCopy)
l_nFieldsCount = AFIELDS(l_aFields, lp_cOrig)

FOR i = 1 TO l_nFieldsCount
     l_cField = l_aFields(i,1)
     l_cFType = l_aFields(i,2)
     l_nFLength = l_aFields(i,3)
     l_nFDec = l_aFields(i,4)

     l_nPos = ASCAN(l_aFieldsCopy,l_cField)
     IF l_nPos = 0
          * New field detected
          l_lMustUpdate = .T.
          EXIT
     ELSE
          * Field is modified
          IF NOT (l_cFType == l_aFieldsCopy(l_nPos + 1) AND l_nFLength == l_aFieldsCopy(l_nPos + 2) AND l_nFDec == l_aFieldsCopy(l_nPos + 3))
               l_lMustUpdate = .T.
               EXIT
          ENDIF
     ENDIF
ENDFOR

IF l_lMustUpdate
     l_cTempCopy = _screen.oGlobal.choteldir+"Tmp\"+SYS(2015)
     SELECT *, CAST({} AS DateTime) AS datepacked FROM (lp_cOrig) WHERE 1=0 INTO TABLE (l_cTempCopy)
     APPEND FROM DBF(lp_cCopy)
     USE
     dclose(lp_cCopy)
     l_cFileName = _screen.oGlobal.choteldir+"Packed\"+lp_cOrig
     DELETE FILE (FORCEEXT(l_cFileName,"*"))
     SELECT 0
     USE (l_cTempCopy) EXCLUSIVE
     COPY TO (l_cFileName) ALL
     USE
     USE (l_cFileName) ALIAS (lp_cCopy) IN 0 EXCLUSIVE
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE DoPack
LPARAMETERS lp_cAliasDBF
LOCAL l_cAliasDBF, l_cTmpFileDBF, l_cTmpFileFPT, l_cFileDBF, l_cFileFPT, l_lSuccess, l_oExepction AS Exception, l_cErrorText, i, l_lSuccessOpenTable, lpackneeded

l_cAliasDBF = lp_cAliasDBF
SELECT (l_cAliasDBF)
DELETE TAG alL
SET TALK ON 
SET TALK WINDOW wtAlk

lpackneeded = ciTadelpack(l_cAliasDBF)
IF NOT lpackneeded
	RETURN .T.
ENDIF

SELECT (l_cAliasDBF)

* Copy to TEMP
l_cTmpFileDBF = _screen.oGlobal.choteldir+"tmp\pack\"+l_cAliasDBF+".dbf"
l_cTmpFileFPT = _screen.oGlobal.choteldir+"tmp\pack\"+l_cAliasDBF+".fpt"
l_cFileDBF = gcDatadir+l_cAliasDBF+".dbf"
l_cFileFPT = gcDatadir+l_cAliasDBF+".fpt"

IF FILE(l_cTmpFileDBF)
	DELETE FILE (l_cTmpFileDBF)
ENDIF
IF FILE(l_cTmpFileFPT)
	DELETE FILE (l_cTmpFileFPT)
ENDIF

USE
COPY FILE (l_cFileDBF) TO (l_cTmpFileDBF)
IF FILE(l_cFileFPT)
	COPY FILE (l_cFileFPT) TO (l_cTmpFileFPT)
ENDIF
FOR i = 1 TO 3
	l_lSuccessOpenTable = (opEnfile(.T.,l_cAliasDBF,.F.,.F.,1))
	IF l_lSuccessOpenTable
		EXIT
	ENDIF
ENDFOR

IF l_lSuccessOpenTable
	SELECT (l_cAliasDBF)
	l_lSuccess = .T.
	TRY
		PACK
	CATCH TO l_oExepction
		l_lSuccess = .F.
		ASSERT .F. MESSAGE PROGRAM()
	ENDTRY
	IF NOT l_lSuccess
		TEXT TO l_cErrorText TEXTMERGE NOSHOW PRETEXT 3
	       <<TRANSFORM(DATETIME())>> Database maintaince - PACK command error
	       -------------------------------------
	       <<l_cAliasDBF>>
	       -------------------------------------
	       ErrorNo:<<TRANSFORM(l_oExepction.ErrorNo)>>
	       Message:<<TRANSFORM(l_oExepction.Message)>>
	       Procedure:<<TRANSFORM(l_oExepction.Procedure)>>
	       LineNo:<<TRANSFORM(l_oExepction.LineNo)>>
	       LineContents:<<TRANSFORM(l_oExepction.LineContents)>>
	       Details:<<TRANSFORM(l_oExepction.Details)>>
		ENDTEXT
		LogData(l_cErrorText, "hotel.err")
		SELECT (l_cAliasDBF)
		USE
		* Copy table back
		IF FILE(l_cTmpFileDBF)
			DELETE FILE (l_cFileDBF)
			COPY FILE (l_cTmpFileDBF) TO (l_cFileDBF)
		ENDIF
		IF FILE(l_cTmpFileFPT)
			DELETE FILE (l_cFileFPT)
			COPY FILE (l_cTmpFileFPT) TO (l_cFileFPT)
		ENDIF
		alert(l_cErrorText)
		IF l_oExepction.ErrorNo = 1104 OR l_oExepction.ErrorNo = 1103
			IF _screen.oGlobal.lexitwhennetworksharelost
				MESSAGEBOX("Lost connection to database. Application would exit now!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Time: " +TTOC(DATETIME()),48,"Citadel Desk",30000)
				ExitProcess()
			ENDIF
		ELSE
			FOR i = 1 TO 3
				l_lSuccessOpenTable = (opEnfile(.T.,l_cAliasDBF,.F.,.F.,1))
				IF l_lSuccessOpenTable
					EXIT
				ENDIF
			ENDFOR
			IF l_lSuccessOpenTable
				SELECT (l_cAliasDBF)
			ENDIF
		ENDIF
	ENDIF
ENDIF

SET TALK OFF
RETURN .T.
ENDPROC
*
PROCEDURE DoPackCopyPacked
LPARAMETERS l_cAliasDBF
LOCAL l_cPackedDir, l_cPackedTablesDir, l_cFilePackedDBF, l_cFilePackedFPT, l_cFilePackedTablesDBF, l_cFilePackedTablesFPT, l_dSysDate, l_cFilePartName

l_dSysDate = sysdate()

IF DAY(l_dSysDate) > 1
	RETURN .T.
ENDIF

l_cPackedDir = _screen.oGlobal.choteldir+"packed\"
l_cPackedTablesDir = _screen.oGlobal.choteldir+"packedtables\"

l_cFilePackedDBF = l_cPackedDir + l_cAliasDBF+".dbf"
l_cFilePackedFPT = l_cPackedDir + l_cAliasDBF+".fpt"

l_cFilePartName = "_" + TRANSFORM(YEAR(l_dSysDate)) + PADL(MONTH(l_dSysDate),2, "0")

l_cFilePackedTablesDBF = l_cPackedTablesDir + l_cAliasDBF + l_cFilePartName + ".dbf"
l_cFilePackedTablesFPT = l_cPackedTablesDir + l_cAliasDBF + l_cFilePartName + ".fpt"

IF NOT DIRECTORY(l_cPackedTablesDir)
     MKDIR (l_cPackedTablesDir)
ENDIF

IF NOT FILE(l_cFilePackedDBF)
	RETURN .T.
ENDIF

IF FILE(l_cFilePackedTablesDBF)
	RETURN .T.
ENDIF

COPY FILE (l_cFilePackedDBF) TO (l_cFilePackedTablesDBF)
IF FILE(l_cFilePackedFPT)
	COPY FILE (l_cFilePackedFPT) TO (l_cFilePackedTablesFPT)
ENDIF

IF FILE(l_cFilePackedTablesDBF)
	* Successfully copied, so delete source
	DELETE FILE (l_cFilePackedDBF)
	DELETE FILE (l_cFilePackedFPT)
ENDIF

RETURN .T.
ENDPROC
*
FUNCTION CheckReserID
LOCAL l_nArea, l_nRecno, l_cOrder, l_lSetNewId, l_cText, l_nChoice, l_nLast, l_nNewId
LOCAL l_lCloseHistres, l_cRmName
WAIT WINDOW NOWAIT "Checking Reservation file..."

l_nArea = SELECT()

IF NOT CreatinxAllowedCheckConsistency()
	Alert("Everybody should leave Briliant first;Please try again later!")
ELSE
	IF NOT USED("histres")
		l_lCloseHistres = DOpen("histres")
	ENDIF
	l_cOrder = ORDER("histres")
	SET ORDER TO tag1 IN histres
	GO BOTTOM IN histres
	l_nLast = INT(histres.hr_reserid)
	SET ORDER TO l_cOrder IN histres
	SELECT reservat
	SET RELATION TO
	l_cOrder = ORDER()
	SET ORDER TO tag1
	GOTO BOTTOM
	l_nLast = MAX(l_nLast, INT(reservat.rs_reserid))
	DLocate('Id','id_code = [RESERVAT]')
	IF l_nLast > id.id_last
		l_cText = GetLangText("OPENFILE","TXT_1_RESERID")+" "+ ;
			LTRIM(STR(l_nLast))+","+CHR(13)+CHR(10)+ ;
			GetLangText("OPENFILE","TXT_2_RESERID")+" "+ ;
			LTRIM(STR(id.id_last))+"."+CHR(13)+CHR(10)+ ;
			GetLangText("OPENFILE","TXT_3_RESERID")
		l_nChoice = MsgBox(l_cText, GetLangText("OPENFILE","TXT_SERIOUSCHECK"), 051)
		l_cText = l_cText + CHR(13) + CHR(10) + "Answered with "
		DO CASE
			CASE l_nChoice = 6
				ErrorMsg(l_cText + "YES by " + g_Userid, .F.)
				NextId('RESERVAT', l_nLast)
				FLUSH
			CASE l_nChoice = 7
				ErrorMsg(l_cText + "NO by " + g_Userid, .F.)
			OTHERWISE
				ErrorMsg(l_cText + "CANCEL by " + g_Userid, .T.)
		ENDCASE
	ENDIF
	l_nLast = 0
	SELECT reservat
	SCAN
		l_nRecno = RECNO()
		l_cRmName = PADR(get_rm_rmname(rs_roomnum),10)
		IF NOT rs_rmname == l_cRmName
			REPLACE reservat.rs_rmname WITH l_cRmName IN reservat
		ENDIF
		l_lSetNewId = EMPTY(rs_reserid) OR l_nLast = rs_reserid
		IF NOT EMPTY(rs_reserid) AND NOT l_lSetNewId
			l_nLast = rs_reserid
		ENDIF
		IF l_lSetNewId
			l_nNewId = NextId('RESERVAT') + 0.1
			REPLACE rs_reserid WITH l_nNewId IN reservat
		ENDIF
		IF SEEK(Reservat.rs_rsid,"Histres","Tag15") AND Histres.hr_reserid <> Reservat.rs_reserid
			REPLACE hr_reserid WITH Reservat.rs_reserid IN Histres
		ENDIF
		GO l_nRecno
	ENDSCAN
	SET ORDER TO l_cOrder IN reservat
	UPDATE Reservat SET rs_rsid = Histres.hr_rsid WHERE EMPTY(rs_rsid) AND SEEK(Reservat.rs_reserid,"Histres","Tag1")
	UPDATE Reservat SET rs_rsid = NextId("RESUNQID") WHERE EMPTY(rs_rsid)
	IF l_lCloseHistres
		DClose("histres")
	ENDIF
	Relations()
ENDIF

SELECT (l_nArea)

WAIT CLEAR

RETURN .T.
ENDFUNC
*
FUNCTION CheckAddressID
LOCAL l_nArea, l_nRecno, l_cOrder, l_lSetNewId, l_cText, l_nChoice, l_nLast, l_nNewId

WAIT WINDOW NOWAIT "Checking Address file..."

l_nArea = SELECT()

IF NOT CreatinxAllowedCheckConsistency()
	Alert("Everybody should leave Briliant first;Please try again later!")
ELSE
	SELECT address
	SET RELATION TO
	l_cOrder = ORDER()
	SET ORDER TO tag1
	GOTO BOTTOM
	DLocate('Id','id_code = [ADDRESS]')
	IF address.ad_addrid > id.id_last
		l_cText = GetLangText("OPENFILE","TXT_1_ADDRESSID")+" "+ ;
			LTRIM(STR(adDress.ad_addrid))+","+CHR(13)+CHR(10)+ ;
			GetLangText("OPENFILE","TXT_2_ADDRESSID")+" "+ ;
			LTRIM(STR(id.id_last))+"."+CHR(13)+CHR(10)+ ;
			GetLangText("OPENFILE","TXT_3_ADDRESSID")
		l_nChoice = MsgBox(l_cText, GetLangText("OPENFILE","TXT_SERIOUSCHECK"), 051)
		l_cText = l_cText + CHR(13) + CHR(10) + "Answered with "
		DO CASE
			CASE l_nChoice = 6
				ErrorMsg(l_cText + "YES by " + g_Userid, .F.)
				NextId('ADDRESS', address.ad_addrid)
				FLUSH
			CASE l_nChoice = 7
				ErrorMsg(l_cText + "NO by " + g_Userid, .F.)
			OTHERWISE
				ErrorMsg(l_cText + "CANCEL by " + g_Userid, .T.)
		ENDCASE
	ENDIF
	l_nLast = 0
	SELECT address
	SCAN
		l_nRecno = RECNO()
		l_lSetNewId = EMPTY(ad_addrid) OR l_nLast = ad_addrid
		IF NOT EMPTY(ad_addrid) AND NOT l_lSetNewId
			l_nLast = ad_addrid
		ENDIF
		IF l_lSetNewId
			l_nNewId = NextId('ADDRESS')
			REPLACE ad_addrid WITH l_nNewId IN address
		ENDIF
		GO l_nRecno
	ENDSCAN
	SET ORDER TO l_cOrder
	Relations()
	
	* Check referrals
	IF openfile(.F.,"referral")
		SELECT referral
		SCAN ALL
			IF NOT SEEK(referral.re_from,"address","tag1") OR NOT SEEK(referral.re_to,"address","tag1")
				DELETE IN referral
			ENDIF
		ENDSCAN
	ENDIF
ENDIF

SELECT (l_nArea)

WAIT CLEAR

RETURN .T.
ENDFUNC
*
FUNCTION CheckPostID
LOCAL l_nArea, l_nRecno, l_cOrder, l_lSetNewId, l_cText, l_nChoice, l_nLast, l_nNewId
LOCAL l_lCloseHistpost
WAIT WINDOW NOWAIT "Checking Post file..."

l_nArea = SELECT()

IF NOT CreatinxAllowedCheckConsistency()
	Alert("Everybody should leave Briliant first;Please try again later!")
ELSE
	IF NOT USED("histpost")
		l_lCloseHistpost = DOpen("histpost")
	ENDIF
	l_cOrder = ORDER("histpost")
	SET ORDER TO tag3 IN histpost
	GO BOTTOM IN histpost
	l_nLast = histpost.hp_postid
	SET ORDER TO l_cOrder IN histpost
	IF l_lCloseHistpost
		DClose("histpost")
	ENDIF
	SELECT post
	l_cOrder = ORDER()
	SET ORDER TO tag3
	GOTO BOTTOM
	l_nLast = MAX(l_nLast, post.ps_postid)
	DLocate('Id','id_code = [POST]')
	IF l_nLast > id.id_last
		l_cText = GetLangText("OPENFILE","TXT_1_POSTID")+" "+ ;
			LTRIM(STR(l_nLast))+","+CHR(13)+CHR(10)+ ;
			GetLangText("OPENFILE","TXT_2_POSTID")+" "+ ;
			LTRIM(STR(id.id_last))+"."+CHR(13)+CHR(10)+ ;
			GetLangText("OPENFILE","TXT_3_POSTID")
		l_nChoice = MsgBox(l_cText, GetLangText("OPENFILE","TXT_SERIOUSCHECK"), 051)
		l_cText = l_cText + CHR(13) + CHR(10) + "Answered with "
		DO CASE
			CASE l_nChoice = 6
				ErrorMsg(l_cText + "YES by " + g_Userid, .F.)
				NextId('POST', l_nLast)
				FLUSH
			CASE l_nChoice = 7
				ErrorMsg(l_cText + "NO by " + g_Userid, .F.)
			OTHERWISE
				ErrorMsg(l_cText + "CANCEL by " + g_Userid, .T.)
		ENDCASE
	ENDIF
	l_nLast = 0
	SELECT post
	SCAN
		l_nRecno = RECNO()
		l_lSetNewId = EMPTY(ps_postid) OR l_nLast = ps_postid
		IF NOT EMPTY(ps_postid) AND NOT l_lSetNewId
			l_nLast = ps_postid
		ENDIF
		IF l_lSetNewId
			l_nNewId = NextId('POST')
			REPLACE ps_postid WITH l_nNewId IN post
		ENDIF
		GO l_nRecno
	ENDSCAN
	SET ORDER TO l_cOrder IN post
ENDIF

SELECT (l_nArea)

WAIT CLEAR

RETURN .T.
ENDFUNC
*
FUNCTION CheckARAccounts
 LOCAL l_nCounter, l_oAracct, l_nFirstAracct, l_nSecondAracct, l_nSelect, l_cOrder, l_lFound, l_cFilter
 WAIT WINDOW NOWAIT "Checking A/R Accounts..."
 l_nSelect = SELECT()

 IF NOT CreatinxAllowedCheckConsistency()
      = alErt("Everybody should leave Briliant first;Please try again later!")
 ELSE
      LOCAL ARRAY l_aCopied(3,2)
      IF NOT USED("aracct")
           openfiledirect(.F., "aracct")
           l_aCopied(1,1) = .T.
      ENDIF
      IF NOT USED("arpost")
           openfiledirect(.F., "arpost")
           l_aCopied(2,1) = .T.
      ENDIF
      IF NOT USED("paymetho")
           openfiledirect(.F., "paymetho")
           l_aCopied(3,1) = .T.
      ENDIF
      SELECT aracct
      SET RELATION TO
      l_cOrder = ORDER()
      l_cFilter = FILTER()
      SET FILTER TO NOT ac_credito
      SET ORDER TO 2   && AC_ADDRID
      GOTO TOP
      
      * don't change arracounts with unknown address
      
      DO WHILE ac_addrid = -9999999 AND NOT EOF()
           SKIP 1
      ENDDO
      
      SCATTER NAME l_oAracct
      l_nCounter = 0
      DO WHILE NOT EOF()
           SKIP
           l_nCounter = l_nCounter + 1
           IF EOF()
                IF l_nCounter > 1
                     SKIP -1
                     GATHER NAME l_oAracct
                ENDIF
                EXIT
           ENDIF
           IF l_oAracct.ac_addrid = aracct.ac_addrid
                IF EMPTY(l_oAracct.ac_accttyp)
                     l_oAracct.ac_accttyp = aracct.ac_accttyp
                ENDIF
                l_oAracct.ac_credlim = l_oAracct.ac_credlim + aracct.ac_credlim
                l_oAracct.ac_perman = l_oAracct.ac_perman OR aracct.ac_perman
                l_oAracct.ac_remind = l_oAracct.ac_remind OR aracct.ac_remind
                l_oAracct.ac_statem = l_oAracct.ac_statem OR aracct.ac_statem
                l_oAracct.ac_status = MAX(l_oAracct.ac_status, aracct.ac_status)
                IF EMPTY(l_oAracct.ac_apid)
                     l_oAracct.ac_apid = aracct.ac_apid
                ENDIF
                IF NOT l_aCopied(2,2)
                     l_aCopied(2,2) = SEEK(aracct.ac_aracct, "arpost", "tag3") AND ;
                         filecopy(gcDatadir+"arpost.dbf", _screen.oGlobal.choteldir+"tmp\arpost.dbf")
                ENDIF
                REPLACE ap_aracct WITH l_oAracct.ac_aracct ;
                     FOR ap_aracct = aracct.ac_aracct IN arpost
                IF NOT l_aCopied(3,2)
                     SELECT paymetho
                     LOCATE FOR pm_aracct = aracct.ac_aracct
                     l_aCopied(3,2) = FOUND() AND filecopy(gcDatadir+"paymetho.dbf", _screen.oGlobal.choteldir+"tmp\paymetho.dbf")
                     SELECT aracct
                ENDIF
                REPLACE pm_aracct WITH l_oAracct.ac_aracct ;
                     FOR pm_aracct = aracct.ac_aracct IN paymetho
                IF NOT l_aCopied(1,2)
                     l_aCopied(1,2) = filecopy(gcDatadir+"aracct.dbf", _screen.oGlobal.choteldir+"tmp\aracct.dbf")
                ENDIF
                SELECT aracct
                DELETE
           ELSE
                IF l_nCounter > 1
                     SKIP -1
                     GATHER NAME l_oAracct
                     SKIP
                ENDIF
                SCATTER NAME l_oAracct
                l_nCounter = 0
           ENDIF
      ENDDO
      SELECT aracct
      SET ORDER TO TAG1
      GOTO TOP
      l_nFirstAracct = aracct.ac_aracct
      SKIP 1
      DO WHILE NOT EOF()
           l_nSecondAracct = aracct.ac_aracct
           IF l_nFirstAracct = l_nSecondAracct
                l_lFound = .T.
           ELSE
                l_lFound = .F.
           ENDIF
           IF l_lFound
                ceRrortxt = GetLangText("AR","TA_DUPLICACCT") + " " + ALLTRIM(STR(l_nFirstAracct)) + "."
                MESSAGEBOX(ceRrortxt,48,GetLangText("FUNC","TXT_MESSAGE"),10000)
                = erRormsg(ceRrortxt)
           ENDIF
           l_nFirstAracct = aracct.ac_aracct
           SKIP 1
      ENDDO
      SELECT aracct
      SET FILTER TO &l_cFilter
      SET ORDER TO l_cOrder
      IF l_aCopied(1,1)
           USE IN aracct
      ENDIF
      IF l_aCopied(2,1)
           USE IN arpost
      ENDIF
      IF l_aCopied(3,1)
           USE IN paymetho
      ENDIF
 ENDIF
 SELECT (l_nSelect)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION CheckRooms
 LOCAL l_nRooms, l_cRoomCur, l_cCurrentLinks, l_cLinkedRoom, l_cValidLinks, l_nPos, i, l_nSelect
 WAIT WINDOW NOWAIT "Checking Room names..."
 l_nSelect = SELECT()

 IF NOT CreatinxAllowedCheckConsistency()
      Alert("Everybody should leave Briliant first;Please try again later!")
 ELSE
      l_cRoomCur = SYS(2015)
      SELECT * FROM room INTO CURSOR (l_cRoomCur) READWRITE
      SELECT (l_cRoomCur)
      INDEX ON rm_roomnum TAG TAG1
      SELECT room
      SCAN ALL
           IF EMPTY(rm_rmname)
                REPLACE rm_rmname WITH rm_roomnum
           ENDIF
           IF NOT EMPTY(rm_link) AND USED(l_cRoomCur)
                l_cValidLinks = ""
                l_cCurrentLinks = ALLTRIM(room.rm_link)+","
                l_nRooms = OCCURS(",", l_cCurrentLinks)
                FOR i = 1 TO l_nRooms
                     l_nPos = AT(",", l_cCurrentLinks)
                     l_cLinkedRoom = PADR(SUBSTR(l_cCurrentLinks, 1, l_nPos - 1), 4)
                     * only existing room is valid. Room can't be linked to it self!
                     IF SEEK(l_cLinkedRoom,l_cRoomCur,"TAG1") AND ;
                               rm_roomnum <> &l_cRoomCur..rm_roomnum
                          l_cValidLinks = l_cValidLinks + ALLTRIM(l_cLinkedRoom) + ","
                     ENDIF
                     l_cCurrentLinks = SUBSTR(l_cCurrentLinks, l_nPos + 1)
                ENDFOR
                IF NOT EMPTY(l_cValidLinks)
                     * remove last ,
                     l_cValidLinks = ALLTRIM(LEFT(l_cValidLinks, LEN(l_cValidLinks)-1))
                ENDIF
                IF NOT (ALLTRIM(rm_link) == l_cValidLinks)
                     = erRormsg("ROOM:" + ALLTRIM(rm_rmname) + ;
                               " - Linked rooms changed from " + ALLTRIM(rm_link) + " to " + l_cValidLinks)
                     REPLACE rm_link WITH l_cValidLinks
                ENDIF
           ENDIF
      ENDSCAN
      USE IN (l_cRoomCur)
 ENDIF
 SELECT (l_nSelect)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION CheckResrooms
 LOCAL l_nSelect
 WAIT WINDOW NOWAIT "Checking Room periods..."
 l_nSelect = SELECT()

 IF NOT CreatinxAllowedCheckConsistency()
      Alert("Everybody should leave Briliant first;Please try again later!")
 ELSE
      DO RiRebuild IN ProcResrooms WITH .T.
 ENDIF
 SELECT (l_nSelect)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
FUNCTION CheckRessplit
 LOCAL l_nSelect
 WAIT WINDOW NOWAIT "Checking Reservation's split articles..."
 l_nSelect = SELECT()

 IF NOT CreatinxAllowedCheckConsistency()
      Alert("Everybody should leave Briliant first;Please try again later!")
 ELSE
      ProcResrate("RlRebuild")
 ENDIF
 SELECT (l_nSelect)
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
PROCEDURE CheckSharing()
	LOCAL l_nNomembr, l_lReservat, l_lHistRes, l_lResRooms, l_lHResRoom, ;
			l_dLowDat, l_dHighDat, l_oRsr1, l_oRsr2, ;
			l_cStatus, l_cRoomTyp, l_cRoomNum, l_lHistory, ;
			l_oProgressBar
	LOCAL ARRAY l_aTasks(1,2)
	l_aTasks(1,1) = RECCOUNT("sharing")
	l_aTasks(1,2) = GetLangText("INDEXING","TXT_CHECK_SHARING")
	DO FORM forms\progressbar NAME l_oProgressBar ;
			WITH GetLangText("INDEXING","TXT_CHECK_SHARING"), l_aTasks

	*** go through sharing
	SELECT sharing
	SCAN
		l_oProgressBar.Update(RECNO(),1)
		l_nNomembr = 0
		STORE {} TO l_dLowDat, l_dHighDat
		STORE "" TO l_cStatus, l_cRoomTyp, l_cRoomNum
		l_lHistory = .T.
		
		*** relation from sharing to resrmshr
		SELECT resrmshr
		SCAN FOR resrmshr.sr_shareid = sharing.sd_shareid
			LOCAL l_dTempLowDat, l_dTempHighDat, l_cTempStatus, ;
					l_cTempRoomTyp, l_cTempRoomNum, ;
					l_nTempReserid, l_dTempResRoomsDate, l_cTempResRoomsAlias
			STORE .F. TO l_lReservat, l_lHistRes, l_lResRooms, l_lHResRoom

			*** locate related record in resrooms and reservat table
			l_lResRooms = SEEK(resrmshr.sr_rroomid,"resrooms","tag3")
			IF l_lResRooms
				l_lReservat = SEEK(resrooms.ri_reserid,"reservat","tag1")
			ELSE
				l_lHResRoom = SEEK(resrmshr.sr_rroomid,"hresroom","tag3")
				IF l_lHResRoom
					l_lHistRes = SEEK(hresroom.ri_reserid,"histres","tag1")
				ENDIF
			ENDIF
			DO CASE
				CASE l_lResRooms
					l_cTempResRoomsAlias = "resrooms"
					l_dTempResRoomsDate = resrooms.ri_date
				CASE l_lHResRoom
					l_cTempResRoomsAlias = "hresroom"
					l_dTempResRoomsDate = hresroom.ri_date
			ENDCASE
			DO CASE
				CASE l_lReservat
					l_cTempStatus = reservat.rs_status
					l_cTempRoomTyp = reservat.rs_roomtyp
					l_cTempRoomNum = reservat.rs_roomnum
					l_dTempLowDat = reservat.rs_arrdate
					l_dTempHighDat = MAX(reservat.rs_arrdate, reservat.rs_depdate - 1)
					l_nTempReserid = reservat.rs_reserid
				CASE l_lHistRes
					l_cTempStatus = histres.hr_status
					l_cTempRoomTyp = histres.hr_roomtyp
					l_cTempRoomNum = histres.hr_roomnum
					l_dTempLowDat = histres.hr_arrdate
					l_dTempHighDat = MAX(histres.hr_arrdate, histres.hr_depdate - 1)
					l_nTempReserid = histres.hr_reserid
			ENDCASE
			IF (l_lReservat OR l_lHistRes) ;
					AND NOT INLIST(l_cTempStatus,"CXL","NS ") ;
					AND sharing.sd_roomtyp = l_cTempRoomTyp ;
					AND sharing.sd_roomnum = l_cTempRoomNum

				*** still valid sharing
				l_nNomembr = l_nNomembr + 1	
				IF l_nNomembr = 1
					l_cStatus = l_cTempStatus
				ELSE
					ProcReservat("Sharing_status", @l_cStatus, l_cTempStatus)
				ENDIF
				IF l_lReservat
					l_lHistory = .F.
				ENDIF
				= RiGetRoom(l_nTempReserid, l_dTempResRoomsDate, @l_oRsr1, @l_oRsr2, l_cTempResRoomsAlias)
				IF NOT (ISNULL(l_oRsr1) OR ISNULL(l_oRsr2))
					l_dTempLowDat = l_oRsr1.ri_date
					IF l_oRsr1.ri_rroomid <> l_oRsr2.ri_rroomid
						l_dTempHighDat = l_oRsr2.ri_date - 1
					ENDIF
				ENDIF
				l_dLowDat = IIF(EMPTY(l_dLowDat), l_dTempLowDat, MIN(l_dLowDat, l_dTempLowDat))
				l_dHighDat = IIF(EMPTY(l_dHighDat), l_dTempHighDat, MAX(l_dHighDat, l_dTempHighDat))
			ELSE

				*** invalid sharing
				IF l_lResRooms OR l_lHResRoom
					REPLACE ri_shareid WITH 0 IN (l_cTempResRoomsAlias)
				ENDIF
				DELETE IN resrmshr
			ENDIF
		ENDSCAN

		*** relation from sharing to resrmshr
		SELECT resrmshr
		SCAN FOR resrmshr.sr_shareid = sharing.sd_shareid
			LOCAL l_cTempResRoomsAlias
			STORE .F. TO l_lReservat, l_lHistRes, l_lResRooms, l_lHResRoom
			l_lResRooms = SEEK(resrmshr.sr_rroomid,"resrooms","tag3")
			IF l_lResRooms
				l_lReservat = SEEK(resrooms.ri_reserid,"reservat","tag1")
			ELSE
				l_lHResRoom = SEEK(resrmshr.sr_rroomid,"hresroom","tag3")
				IF l_lHResRoom
					l_lHistRes = SEEK(hresroom.ri_reserid,"histres","tag1")
				ENDIF
			ENDIF
			DO CASE
				CASE l_lResRooms
					l_cTempResRoomsAlias = "resrooms"
				CASE l_lHResRoom
					l_cTempResRoomsAlias = "hresroom"
			ENDCASE

			IF l_nNomembr < 2

				*** invalid sharing
				IF l_lResRooms OR l_lHResRoom
					REPLACE ri_shareid WITH 0 IN (l_cTempResRoomsAlias)
				ENDIF
				DELETE IN resrmshr
			ELSE
				*** valid sharing
				IF l_lResRooms OR l_lHResRoom
					REPLACE ri_shareid WITH sharing.sd_shareid IN (l_cTempResRoomsAlias)
					l_cRoomTyp = &l_cTempResRoomsAlias..ri_roomtyp
					l_cRoomNum = &l_cTempResRoomsAlias..ri_roomnum
				ENDIF
			ENDIF
		ENDSCAN

		IF l_nNomembr < 2
			*** invalid sharing
			DELETE IN sharing
		ELSE
			*** valid sharing
			l_nNomembr = MIN(l_nNomembr, 99)
			REPLACE sharing.sd_nomembr WITH l_nNomembr, ;
					sharing.sd_status WITH l_cStatus, ;
					sharing.sd_lowdat WITH l_dLowDat, ;
					sharing.sd_highdat WITH l_dHighDat, ;
					sharing.sd_history WITH l_lHistory IN sharing
		ENDIF
		SELECT sharing
	ENDSCAN

	*** update
	IF CURSORGETPROP("Buffering", "sharing") = 5
		= TABLEUPDATE(.T., .T., "sharing")
	ENDIF
	IF CURSORGETPROP("Buffering", "resrmshr") = 5
		= TABLEUPDATE(.T., .T., "resrmshr")
	ENDIF
	IF CURSORGETPROP("Buffering", "resrooms") = 5
		= TABLEUPDATE(.T., .T., "resrooms")
	ENDIF
	l_oProgressBar.Release()
ENDPROC
*
FUNCTION CheckListID
LOCAL l_nArea, l_nRecno, l_cOrder, l_nLast, l_lUpdateLists, l_lCloseLists

WAIT WINDOW NOWAIT "Checking Report file..."

l_nArea = SELECT()

IF NOT CreatinxAllowedCheckConsistency()
	Alert("Everybody should leave Briliant first;Please try again later!")
ELSE
	IF NOT USED("lists")
		l_lCloseLists = DOpen("lists")
	ENDIF
	SELECT lists
	l_cOrder = ORDER()
	SET ORDER TO tag23
	l_nLast = 0
	SCAN
		l_nRecno = RECNO()
		l_lSetNewId = EMPTY(li_liid) OR l_nLast = li_liid
		IF EMPTY(li_liid) OR l_nLast = li_liid
			BLANK FIELDS li_liid
			l_lUpdateLists = .T.
		ELSE
			l_nLast = li_liid
		ENDIF
		GO l_nRecno
	ENDSCAN
	SET ORDER TO l_cOrder
	IF l_lUpdateLists
		UPDATE lists SET li_liid = NextId("LISTS") WHERE EMPTY(li_liid)
	ENDIF
	IF l_lCloseLists
		DClose("lists")
	ENDIF
ENDIF

SELECT (l_nArea)

WAIT CLEAR

RETURN .T.
ENDFUNC
*
FUNCTION DefaultLanguage
 PRIVATE crEturn
 DIMENSION acLanguages[9]
 acLanguages[1] = "ENG"
 acLanguages[2] = "DUT"
 acLanguages[3] = "GER"
 acLanguages[4] = "FRE"
 acLanguages[5] = "INT"
 acLanguages[6] = "SER"
 acLanguages[7] = "POR"
 acLanguages[8] = "ITA"
 acLanguages[9] = "POL"
 IF ( .NOT. USED("Param"))
      = opEnfile(.F.,"Param")
      crEturn = ASCAN(acLanguages, paRam.pa_lang)
      = clOsefile("Param")
 ELSE
      crEturn = ASCAN(acLanguages, paRam.pa_lang)
 ENDIF
 RETURN crEturn
ENDFUNC
*
FUNCTION UsersLogedIn
 PRIVATE nrEturn
 nrEturn = 0
 IF (USED("license"))
      nlCrecord = RECNO("License")
      GOTO TOP IN liCense
      DO WHILE  .NOT. EOF("License")
           IF  .NOT. EMPTY(liCense.lc_station)
                nrEturn = nrEturn+1
           ENDIF
           SKIP 1 IN liCense
      ENDDO
      GOTO nlCrecord IN liCense
 ENDIF
 RETURN nrEturn
ENDFUNC
*
PROCEDURE CheckRatecodeID
LOCAL l_cArticleRateKey, l_cRateCodeSetID, l_nRateartiRecNo
LOCAL l_nIDCount, i, l_nOldArea, l_cRaOrder, l_cRcOrder, l_lRaClose, l_lRcClose, l_lIdClose
LOCAL ARRAY l_aRateartiNexdID(1), l_aMaxRaID(1)

WAIT WINDOW NOWAIT GetLangText("INDEXING","TXT_RATECODE")

l_cArticleRateKey = ""
l_aMaxRaID = 0
l_cRateCodeSetID = 0
l_nIDCount = 0
l_nOldArea = SELECT()
IF NOT USED("ID")
	openfiledirect(.F., "id")
	l_lIdClose = .T.
ENDIF
IF NOT USED("ratearti")
	openfiledirect(.F., "ratearti")
	l_lRaClose = .T.
ELSE
	l_cRaOrder = ORDER()
ENDIF
IF NOT USED("ratecode")
	openfiledirect(.F., "ratecode")
	l_lRcClose = .T.
ELSE
	l_cRcOrder = ORDER()
ENDIF

SELECT MAX(INT(ra_raid)) FROM ratearti INTO ARRAY l_aMaxRaID
IF dlOcate('Id','id_code = [RATEARTI]')
	REPLACE id.id_last WITH l_aMaxRaID FOR id.id_code = "RATEARTI" IN id
ELSE
	INSERT INTO ID(id_code, id_last) VALUES ("RATEARTI", l_aMaxRaID)
ENDIF

SELECT ratearti
SET ORDER TO TAG Tag1
SELECT ratecode
SET ORDER TO TAG Tag1
SCAN
	l_cArticleRateKey = PADR(rc_ratecod, 10) + PADR(rc_roomtyp, 4) + ;
			DTOS(rc_fromdat) + rc_season
	SELECT ratearti
	LOCATE FOR ra_ratecod = l_cArticleRateKey
	IF FOUND() AND NOT EMPTY(ra_raid)
		SELECT ratecode
		LOOP
	ENDIF
	IF (ratecode.rc_rcsetid <> l_cRateCodeSetID) OR EMPTY(l_cRateCodeSetID)
		l_cRateCodeSetID = ratecode.rc_rcsetid
		l_nRateartiRecNo = RECNO()
		COUNT FOR ra_ratecod = l_cArticleRateKey TO l_nIDCount
		GO l_nRateartiRecNo
		IF l_nIDCount > 0 && When at least one record in ratearti.dbf is found!
			DIMENSION l_aRateartiNexdID (l_nIDCount)
			FOR i = 1 TO l_nIDCount
				l_aRateartiNexdID(i) = NextID("RATEARTI")
			ENDFOR
		ELSE
			SELECT ratecode
			LOOP
		ENDIF
	ENDIF
	FOR i = 1 TO l_nIDCount
		IF ra_ratecod = l_cArticleRateKey AND NOT EOF()
			REPLACE ra_raid WITH l_aRateartiNexdID(i)
			SKIP 1
		ENDIF
	ENDFOR
	SELECT ratecode
ENDSCAN

IF l_lIdClose
	USE IN id
ENDIF
SELECT ratearti
IF l_lRaClose
	USE
ELSE
	SET ORDER TO &l_cRaOrder
ENDIF
SELECT ratecode
IF l_lRcClose
	USE
ELSE
	SET ORDER TO &l_cRcOrder
ENDIF
SELECT (l_nOldArea)
WAIT CLEAR
ENDPROC
*
PROCEDURE CreatinxAllowedCheckConsistency
LOCAL l_lContinue
* For know, always allow "check consistency" functions.
* Before was called Exclusive() function in func.prg, but i don't know why.
*l_lContinue = (TYPE("p_lRemoteAuditReindexing")="L" AND p_lRemoteAuditReindexing) OR ISEXCLUSIVE("param")
l_lContinue = .T.
RETURN l_lContinue
ENDPROC