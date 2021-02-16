*PROCEDURE RateCodeGetRates
LPARAMETERS lp_dDate,lp_cRateCode,lp_cRoomType,lp_nRate1,lp_nRate2,lp_nRate3,lp_nRate4,lp_nRate5
LOCAL l_nArea, l_cOrder
l_nArea = SELECT()
LOCAL l_cSeason, l_cRateCode
l_cRateCode = STRTRAN(lp_cRateCode,'*','')
l_cRateCode = STRTRAN(l_cRateCode,'!','')
l_cSeason = dlookup('Season','se_date = '+sqlcnv(lp_dDate),'se_season')
SELECT ratecode
l_cOrder = ORDER()
SET ORDER TO tag1
= SEEK(PADR(l_cRateCode, 10)+lp_cRoomType, "RateCode")
LOCATE REST FOR (ratecode.rc_fromdat <= lp_dDate) .AND.  ;
				(ratecode.rc_todat > lp_dDate) .AND. ;
				(EMPTY(rc_season) .OR. rc_season=l_cSeason) ;
			WHILE ratecode.rc_ratecod = l_cRateCode
IF .NOT. FOUND("RateCode")
	= SEEK(PADR(l_cRateCode, 10)+"*", "RateCode")
	LOCATE REST FOR (ratecode.rc_fromdat <= lp_dDate) .AND.  ;
					(ratecode.rc_todat > lp_dDate) .AND.  ;
					(EMPTY(rc_season) .OR. rc_season=l_cSeason) ;
				WHILE ratecode.rc_ratecod= l_cRateCode
ENDIF
IF FOUND("RateCode")
	lp_nRate1 = ratecode.rc_amnt1
	lp_nRate2 = ratecode.rc_amnt2
	lp_nRate3 = ratecode.rc_amnt3
	lp_nRate4 = ratecode.rc_amnt4
	lp_nRate5 = ratecode.rc_amnt5
ELSE
	lp_nRate1 = 0
	lp_nRate2 = 0
	lp_nRate3 = 0
	lp_nRate4 = 0
	lp_nRate5 = 0
ENDIF
SET ORDER TO l_cOrder IN ratecode
SELECT(l_nArea)
ENDPROC