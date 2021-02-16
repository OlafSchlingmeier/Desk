#INCLUDE "include\constdefines.h"

**************************************************
*-- Class:        cbizallot (\progs\bizallotment.prg)
*-- ParentClass:  cbizbase (\progs\bizbase.prg)
*-- BaseClass:    collection
*-- Time Stamp:   29.08.11 13:36:09
*
DEFINE CLASS cbizallot AS cbizbase


	ctables = "althead,altsplit"


	PROCEDURE altgetbyalid
		LPARAMETERS tnRecordId

		IF EMPTY(tnRecordId)
			this.CursorFill("althead", "0=1")
			this.CursorFill("altsplit", "0=1")
		ELSE
			this.CursorFill("althead", "al_altid = " + SqlCnv(tnRecordId, .T.))
			this.CursorFill("altsplit", "as_altid = " + SqlCnv(tnRecordId, .T.))
		ENDIF
	ENDPROC


	PROCEDURE altsave
		LPARAMETERS tcError

		this.ResetError()
		this.CursorRefresh("altsplit")
		DO CASE
			CASE this.AllotCheck()
				this.AllotAvlUpdate()
				this.Save()
			OTHERWISE
		ENDCASE

		RETURN this.GetError(@tcError)
	ENDPROC


	PROCEDURE allotcheck

		RETURN .T.
	ENDPROC


	PROCEDURE allotcheckfordelete
		IF DLocate("curAltsplit", "as_pick <> 0")
			this.cError = Str2Msg(GetLangText("ALZOOMIN","TXT_DONTCHANGEDAY"), "%s", DTOS(curAltsplit.as_date))
			this.nErrorCode = ERR_RES_EXISTS
		ENDIF
	ENDPROC


	PROCEDURE allotcheckforchange
		LPARAMETERS tdFromDate, tdToDate, tcDays
		LOCAL i

		IF tdFromDate > curAlthead.al_fromdat AND DLocate("curAltsplit", "as_pick <> 0 AND as_date < " + SqlCnv(tdFromDate))
			this.cError = Str2Msg(GetLangText("ALZOOMIN","TXT_MAXSTARTDAT"), "%s", DTOS(curAltsplit.as_date))
			this.nErrorCode = ERR_RES_EXISTS
			RETURN
		ENDIF

		IF tdToDate < curAlthead.al_todat AND DLocate("curAltsplit", "as_pick <> 0 AND as_date > " + SqlCnv(tdToDate))
			this.cError = Str2Msg(GetLangText("ALZOOMIN","TXT_MINENDDAT"), "%s", DTOS(curAltsplit.as_date))
			this.nErrorCode = ERR_RES_EXISTS
			RETURN
		ENDIF

		IF tcDays <> curAlthead.al_days
			FOR i = 1 TO 7
				IF SUBSTR(curAlthead.al_days,i,1) = "1" AND SUBSTR(tcDays,i,1) <> "1"
					IF DLocate("curAltsplit", "as_pick <> 0 AND SUBSTR("+SqlCnv(tcDays)+",MOD(DOW(as_date,3),7)+1,1) <> '1'")
						this.cError = Str2Msg(GetLangText("ALZOOMIN","TXT_DONTCHANGEDAY"), "%s", DTOS(curAltsplit.as_date))
						this.nErrorCode = ERR_RES_EXISTS
						RETURN
					ENDIF
				ENDIF
			NEXT
		ENDIF
	ENDPROC


	PROCEDURE altchange
		LPARAMETERS tdFromDate, tdToDate, tcDays

		this.ResetError()
		this.AllotCheckForChange(tdFromDate, tdToDate, tcDays)
		IF this.nErrorCode = NO_ERROR
			DELETE FOR NOT BETWEEN(as_date, tdFromDate, tdToDate) OR SUBSTR(tcDays, MOD(DOW(as_date,3),7)+1, 1) <> "1" IN curAltsplit
		ENDIF
	ENDPROC


	PROCEDURE altcutdatechange
		LPARAMETERS tdCutDate, tnCutDay

		IF tdCutDate <> curAlthead.al_cutdate OR tnCutDay <> curAlthead.al_cutday
			REPLACE as_cutdate WITH IIF(NOT EMPTY(tnCutDay) OR EMPTY(tdCutDate), as_date - tnCutDay, tdCutDate) ALL IN curAltsplit
			REPLACE as_rooms WITH ICASE(as_cutdate < SysDate(), as_pick, EMPTY(as_orgroom), as_rooms, as_orgroom) ALL IN curAltsplit
		ENDIF
	ENDPROC


	PROCEDURE altdelete
		this.ResetError()
		this.AllotCheckForDelete()
		IF this.nErrorCode = NO_ERROR
			DELETE ALL IN curAltsplit
			DELETE IN curAlthead
		ENDIF
	ENDPROC


	PROCEDURE allotavlupdate
		LOCAL lnArea, lnRecNo, lnLastModifiedRec, llUpdateMaxAvail, ldFromdate, ldTodate

		lnArea = SELECT()

		IF NOT Odbc()
			this.AddTable("availab")
			SELECT curAlthead
			IF DELETED() AND RECNO() < 0
				this.CursorFill("availab", "0=1")
			ELSE
				ldFromdate = ICASE(RECNO() < 0, al_fromdat, DELETED(), OLDVAL("al_fromdat"), MIN(al_fromdat,OLDVAL("al_fromdat")))
				ldTodate = ICASE(RECNO() < 0, al_todat, DELETED(), OLDVAL("al_todat"), MAX(al_todat,OLDVAL("al_todat")))
				this.CursorFill("availab", "BETWEEN(av_date, " + SqlCnv(ldFromdate,.T.) + ", " + SqlCnv(ldTodate,.T.) + ")")
			ENDIF
		ENDIF
		llUpdateMaxAvail = g_lShips AND DLookUp("building", "bu_buildng = " + SqlCnv(curAlthead.al_buildng,.T.), "bu_hired")
		SELECT curAltsplit
		lnRecNo = RECNO()
		LOCATE
		lnLastModifiedRec = GETNEXTMODIFIED(0)
		DO WHILE lnLastModifiedRec <> 0
			GO lnLastModifiedRec
			IF GETFLDSTATE(0) <> 4
				this.AvlUpdateAlsRecord(llUpdateMaxAvail)
			ENDIF
			lnLastModifiedRec = GETNEXTMODIFIED(lnLastModifiedRec)
		ENDDO
		GO lnRecNo

		SELECT (lnArea)
	ENDPROC


	PROCEDURE avlupdatealsrecord
		LPARAMETERS tlUpdateMaxAvail
		LOCAL lcNewRoomType, lcOldRoomType, lnNewRooms, lnOldRooms

		lcNewRoomType = IIF(DELETED(), "", as_roomtyp)
		lnNewRooms = IIF(DELETED(), 0, as_rooms)
		lcOldRoomType = NVL(OLDVAL("as_roomtyp"),"")
		lnOldRooms = NVL(OLDVAL("as_rooms"),0)
		IF Odbc()
			DO CASE
				CASE EMPTY(lcNewRoomType) AND EMPTY(lcOldRoomType) OR lcNewRoomType == lcOldRoomType AND lnNewRooms = lnOldRooms
				CASE lcNewRoomType == lcOldRoomType
					Sql(Str2Msg("SELECT Avlupdatealsrecord(%s1,%s2,%s3,%s4)","%s",SqlCnv(tlUpdateMaxAvail,.T.),SqlCnv(as_date,.T.), SqlCnv(lcNewRoomType,.T.),SqlCnv(lnNewRooms - lnOldRooms,.T.)),"","SQLOTHER")
				OTHERWISE
					IF NOT EMPTY(lnNewRooms) AND NOT EMPTY(lcNewRoomType)
						Sql(Str2Msg("SELECT Avlupdatealsrecord(%s1,%s2,%s3,%s4)","%s",SqlCnv(tlUpdateMaxAvail,.T.),SqlCnv(as_date,.T.), SqlCnv(lcNewRoomType,.T.),SqlCnv(lnNewRooms,.T.)),"","SQLOTHER")
					ENDIF
					IF NOT EMPTY(lnOldRooms) AND NOT EMPTY(lcOldRoomType)
						Sql(Str2Msg("SELECT Avlupdatealsrecord(%s1,%s2,%s3,%s4)","%s",SqlCnv(tlUpdateMaxAvail,.T.),SqlCnv(as_date,.T.), SqlCnv(lcOldRoomType,.T.),SqlCnv(-lnOldRooms,.T.)),"","SQLOTHER")
					ENDIF
			ENDCASE
		ELSE
			DO CASE
				CASE EMPTY(lcNewRoomType) AND EMPTY(lcOldRoomType) OR lcNewRoomType == lcOldRoomType AND lnNewRooms = lnOldRooms
				CASE lcNewRoomType == lcOldRoomType
					IF DLocate("curAvailab", "av_date = " + SqlCnv(as_date) + " AND av_roomtyp = " + SqlCnv(IIF(lcNewRoomType = "*", _screen.oGlobal.oParam.pa_lsallot, lcNewRoomType)))
						IF lcNewRoomType = "*"
							REPLACE av_altall WITH curAvailab.av_altall + lnNewRooms - lnOldRooms IN curAvailab
						ELSE
							REPLACE av_allott WITH curAvailab.av_allott + lnNewRooms - lnOldRooms IN curAvailab
						ENDIF
						IF tlUpdateMaxAvail
							REPLACE av_avail WITH curAvailab.av_avail + lnNewRooms - lnOldRooms IN curAvailab
						ENDIF
					ENDIF
				OTHERWISE
					IF NOT EMPTY(lnNewRooms) AND NOT EMPTY(lcNewRoomType) AND DLocate("curAvailab", "av_date = " + SqlCnv(as_date) + ;
							" AND av_roomtyp = " + SqlCnv(IIF(lcNewRoomType = "*", _screen.oGlobal.oParam.pa_lsallot, lcNewRoomType)))
						IF lcNewRoomType = "*"
							REPLACE av_altall WITH curAvailab.av_altall + lnNewRooms IN curAvailab
						ELSE
							REPLACE av_allott WITH curAvailab.av_allott + lnNewRooms IN curAvailab
						ENDIF
						IF tlUpdateMaxAvail
							REPLACE av_avail WITH curAvailab.av_avail + lnNewRooms IN curAvailab
						ENDIF
					ENDIF
					IF NOT EMPTY(lnOldRooms) AND NOT EMPTY(lcOldRoomType) AND DLocate("curAvailab", "av_date = " + SqlCnv(as_date) + ;
							" AND av_roomtyp = " + SqlCnv(IIF(lcOldRoomType = "*", _screen.oGlobal.oParam.pa_lsallot, lcOldRoomType)))
						IF lcOldRoomType = "*"
							REPLACE av_altall WITH MAX(0, curAvailab.av_altall - lnOldRooms) IN curAvailab
						ELSE
							REPLACE av_allott WITH MAX(0, curAvailab.av_allott - lnOldRooms) IN curAvailab
						ENDIF
						IF tlUpdateMaxAvail
							REPLACE av_avail WITH MAX(0, curAvailab.av_avail - lnOldRooms) IN curAvailab
						ENDIF
					ENDIF
			ENDCASE
		ENDIF
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cbizallot
**************************************************