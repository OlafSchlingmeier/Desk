FUNCTION CHECKDATES
LPARAMETERS DDATE1,DDATE2,DRSARRIVAL,DRSDEPARTURE
* check dates in rateperiods
* dDate1 must be between max(rs_arrdate+1,g_sysdate+1) and rs_depdate-1 and smaller or equal than dDate2
* dDate2 must be between max(rs_arrdate+1,g_sysdate+1) and rs_depdate-1 and greater or equal dDate1
* Return values
* 1 Dates are valid
* -1 Date1 is smaller than max(rs_arrdate+1,g_sysdate+1)
* -2 Date1 is greather than rs_depdate-1
* -3 Date2 is smaller than max(rs_arrdate+1,g_sysdate+1)
* -4 Date2 is greather than rs_depdate-1
* -5 Date2 is smaller than Date1

LOCAL LDDATE1,LDDATE2,LNRET
LNRET=1

LDDATE1=MAX(DRSARRIVAL+1,G_SYSDATE+1)
LDDATE2=DRSDEPARTURE-1

DO CASE
CASE DDATE1<LDDATE1
	LNRET=-1
CASE DDATE1>LDDATE2
	LNRET=-2
CASE DDATE2<LDDATE1
	LNRET=-3
CASE DDATE2>LDDATE2
	LNRET=-4
CASE DDATE2<DDATE1
	LNRET=-5
ENDCASE

RETURN LNRET
ENDFUNC

FUNCTION CHECKADULTS
LPARAMETERS NADULTS
* check number of adults
* return values
* 1 OK
* - 1 number of adults is invalid
LOCAL LNRET
LNRET=1

IF PARAM.PA_CHKADTS .AND. NADULTS<=0
	LNRET=-1
ENDIF

RETURN LNRET
ENDFUNC

FUNCTION CHECKRATECODE
LPARAMETERS DDATE,CRATECODE,CROOMTYPe

* check ratecode for date and roomtype
* open tables season, ratecode
* retun values 
* 1 ok
* -1 ratecode for ddate and roomtype is invalid

LOCAL CSEASON,LFOUND,LCRATECODE,LNRET,LCALIAS

LCALIAS=ALIAS()
LNRET=1
CSEASON=''
LCRATECODE=STRTRAN(CRATECODE,'*','')
LCRATECODE=STRTRAN(LCRATECODE,'!','')
LFOUND=.F.
* automatic
IF SEEK(DDATE,'season','tag1') .AND. !EMPTY(SEASON.SE_SEASON)
	CSEASON=SEASON.SE_SEASON
	SELECT RATECODE
* look for ratecode for season
	LOCATE FOR RC_SEASON=CSEASON .AND. RC_RATECOD=LCRATECODE .AND. RC_ROOMTYP=CROOMTYPE .AND. RC_FROMDAT<=DDATE
	LFOUND=FOUND()
* check roomtype *
	IF !LFOUND
		LOCATE FOR RC_SEASON=CSEASON .AND. RC_RATECOD=LCRATECODE .AND. RC_ROOMTYP='*' .AND. RC_FROMDAT<=DDATE
		LFOUND=FOUND()
* check empty season
		IF !LFOUND
			LOCATE FOR EMPTY(RC_SEASON) .AND. RC_RATECOD=LCRATECODE .AND. RC_ROOMTYP=CROOMTYPE .AND. RC_FROMDAT<=DDATE
			LFOUND=FOUND()
* check empty season and roomtype *
			IF !LFOUND
				LOCATE FOR EMPTY(RC_SEASON) .AND. RC_RATECOD=LCRATECODE .AND. RC_ROOMTYP='*' .AND. RC_FROMDAT<=DDATE
				LFOUND=FOUND()
			ENDIF
		ENDIF
	ENDIF
	IF !LFOUND
*			Wait Window 'Could not find ratecode '+lcratecode+Dtoc(ddate)+' Season '+cseason
		LNRET=-1
	ENDIF
ELSE
	SELECT RATECODE
* no season, look for ratecode
	LOCATE FOR EMPTY(RC_SEASON) .AND. RC_RATECOD=LCRATECODE .AND. RC_ROOMTYP=CROOMTYPE .AND. RC_FROMDAT<=DDATE
	LFOUND=FOUND()
* check empty season and roomtype *
	IF !LFOUND
		LOCATE FOR EMPTY(RC_SEASON) .AND. RC_RATECOD=LCRATECODE .AND. RC_ROOMTYP='*' .AND. RC_FROMDAT<=DDATE
		LFOUND=FOUND()
	ENDIF
	IF !LFOUND
*			Wait Window 'Could not find ratecode "'+lcratecode+'"'+Dtoc(ddate)+' No season'
		LNRET= -1
	ENDIF
ENDIF
IF !EMPTY(LCALIAS)
	SELECT &LCALIAS
ENDIF

RETURN LNRET
ENDFUNC

FUNCTION checkrateperi
LPARAMETERS ddate,nAdults,cRatecode,cRoomtype,dRsArrival,dRsDeparture
* check record in rateperi
* return value
* 1 Ok
* -1 Date is invalid
* -2 Adults number is invalid
* -3 Ratecode is invalid
LOCAL lnRet
lnRet=1
lnRet=checkdates(DDATE,DDATE,DRSARRIVAL,DRSDEPARTURE)
IF lnRet<0
	lnRet=-1
ENDIF

IF lnRet=1
	lnRet=checkadults(nAdults)
	IF lnRet=-1
		lnRet=-2
	endif
ENDIF

IF lnRet=1
	lnRet=checkratecode(DDATE,CRATECODE,CROOMTYPe)
	IF lnRet=-1
		lnRet=-3
	endif
ENDIF

RETURN lnRet
endfunc