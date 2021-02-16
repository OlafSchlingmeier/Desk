*
PROCEDURE COminutesfromtime
LPARAMETERS m.tTime
LOCAL m.nPos, m.Result
m.nPos = AT(":", m.tTime)

m.Result = VAL(LEFT(m.tTime, m.nPos - 1)) * 60 + VAL(SUBSTR(m.tTime, m.nPos + 1))

IF m.Result < 0
     m.Result = m.Result + 1440
ENDIF

RETURN m.Result
ENDPROC
*
PROCEDURE COTimeFromMinutes
LPARAMETERS m.Minutes

m.Minutes = MOD(m.Minutes, 1440)

RETURN STRTRAN(PADL(ALLTRIM(STR(INT(m.Minutes / 60))), 2), " ", "0") + ":" + STRTRAN(PADL(ALLTRIM(STR(MOD(m.Minutes, 60))), 2), " ", "0")
ENDPROC
*
DEFINE CLASS CODetermineDayPart AS Custom
*
nStarthr = 0
nDayprt1 = 0
nDayprt2 = 0
nArrtime = 0
nDeptime = 0
lPeriod1 = .F.
lPeriod2 = .F.
lPeriod3 = .F.
nFromReserId = 0
*
PROCEDURE Init
this.nStarthr = COminutesfromtime(PADL(_screen.oGlobal.oParam.pa_starthr,2,"0")+":00")
this.nDayprt1 = COminutesfromtime(PADL(_screen.oGlobal.oParam.pa_dayprt1,2,"0")+":00")
this.nDayprt2 = COminutesfromtime(PADL(_screen.oGlobal.oParam.pa_dayprt2,2,"0")+":00")

RETURN .T.
ENDPROC
*
PROCEDURE Do
* Day is from START hr. to START hr. next day. So Arrtime and deptime must be between (START, START+1440min)
this.nArrtime = EVL(COminutesfromtime(rr_arrtime),this.nStarthr)
this.nDeptime = EVL(COminutesfromtime(rr_deptime),this.nStarthr+1440)
IF this.nArrtime < this.nStarthr
	this.nArrtime = this.nArrtime+1440
ENDIF
IF this.nDeptime < this.nStarthr
	this.nDeptime = this.nDeptime+1440
ENDIF
IF this.nDeptime < this.nArrtime
	this.nDeptime = this.nStarthr+1440
ENDIF

this.lPeriod1 = (this.nArrtime < this.nDayprt1)
this.lPeriod2 = (this.nDeptime > this.nDayprt1 AND this.nArrtime < this.nDayprt2)
this.lPeriod3 = (this.nDeptime > this.nDayprt2)

RETURN .T.
ENDPROC
*
PROCEDURE IsRmFreeSetFromReserId(l_nReserid)
this.nFromReserId = l_nReserid
RETURN .T.
ENDPROC
*
PROCEDURE IsRmFree
LPARAMETERS lp_nToReserId
LOCAL l_lConflictFound, l_nSelect, l_cFromCur, l_cToCur, l_cSql, lFromPeriod1, lFromPeriod2, lFromPeriod3, lToPeriod1, lToPeriod2, lToPeriod3
l_nSelect = SELECT()

l_cFromCur = SYS(2015)
l_cToCur = sqlcursor("SELECT rr_date, rr_arrtime, rr_deptime FROM resrate WHERE rr_reserid = " + sqlcnv(lp_nToReserId,.T.) + " ORDER BY 1")
l_cSql = "SELECT rr_date, rr_arrtime, rr_deptime FROM resrate WITH (Buffering = .T.) WHERE rr_reserid = " + sqlcnv(this.nFromReserId,.T.) + " ORDER BY 1"
&l_cSql INTO CURSOR &l_cFromCur
SCAN ALL
     this.Do()
     lFromPeriod1 = this.lPeriod1
     lFromPeriod2 = this.lPeriod2
     lFromPeriod3 = this.lPeriod3
     SELECT &l_cToCur
     LOCATE FOR rr_date = &l_cFromCur..rr_date
     IF FOUND()
          this.Do()
          lToPeriod1 = this.lPeriod1
          lToPeriod2 = this.lPeriod2
          lToPeriod3 = this.lPeriod3
          IF (lFromPeriod1 AND lToPeriod1) OR (lFromPeriod2 AND lToPeriod2) OR (lFromPeriod3 AND lToPeriod3)
               l_lConflictFound = .T.
          ENDIF
     ENDIF
     IF l_lConflictFound
          EXIT
     ENDIF
ENDSCAN

dclose(l_cFromCur)
dclose(l_cToCur)

SELECT (l_nSelect)
RETURN l_lConflictFound
ENDPROC
*
ENDDEFINE
*