FUNCTION RateCodeEval
LPARAMETERS lp_dDate, lp_cRateCode, lp_nRate, lp_cRoomType, lp_nAltId, nadults, nchilds, nchilds2, nchilds3, ;
		darrdate, ddepdate, carrtime, cdeptime, lp_lLeaveValid, lp_lSilent, lp_lLogError
LOCAL l_cRateCode, l_nRate, l_fFound

l_cRateCode = STRTRAN(STRTRAN(lp_cRateCode,"*"),"!")
IF (LEFT(lp_cRateCode,1) = "!") && changed ratecode in allotments
	IF SEEK(lp_nAltId,"althead","tag1")
		IF SEEK(PADR(althead.al_altid,8)+DTOS(lp_dDate)+lp_cRoomType+l_cRateCode,"altsplit","tag2") OR ;
			SEEK(PADR(althead.al_altid,8)+DTOS(lp_dDate)+"*   "+l_cRateCode,"altsplit","tag2")
			l_fFound = .T.
		ENDIF
	ENDIF
ENDIF

IF NOT l_fFound OR NOT (SEEK(PADR(l_cRateCode, 10)+lp_cRoomType,"RateCode","Tag1") OR SEEK(PADR(l_cRateCode, 10)+"*","RateCode","Tag1"))
	l_fFound = RatecodeLocate(lp_dDate, lp_cRateCode, lp_cRoomType, darrdate, ddepdate, NOT lp_lLeaveValid, lp_lSilent,,lp_lLogError)
ENDIF
IF l_fFound
	l_nRate = RateCalculate(lp_dDate, lp_cRateCode, lp_cRoomType, lp_nAltId, lp_nRate, nadults, nchilds, nchilds2, nchilds3, darrdate, ddepdate, carrtime, cdeptime)
ELSE
	l_nRate = -1
ENDIF

RETURN l_nRate
ENDFUNC
*