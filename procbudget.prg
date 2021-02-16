PROCEDURE CopyFromBudgetIntoBgdcur

* Budget table must be opened

LOCAL lnSelected, loName, lcMacro, llNoteValue
lnSelected = SELECT()

SELECT bgdcur
SCATTER MEMO NAME loName BLANK
loName.bg_artinum = curbudget.bg_artinum
loName.bg_label = curbudget.bg_label
loName.bg_main = curbudget.bg_main
loName.bg_market = curbudget.bg_market
loName.bg_sub = curbudget.bg_sub
loName.bg_year = curbudget.bg_year
loName.bg_hgnr = curbudget.bg_hgnr
loName.bg_sgnr = curbudget.bg_sgnr
lcMacro = [loName.bg_roomn] + ALLTRIM(STR(curbudget.bg_period))
STORE curbudget.bg_roomnts TO &lcMacro
lcMacro = [loName.bg_reven] + ALLTRIM(STR(curbudget.bg_period))
STORE curbudget.bg_revenue TO &lcMacro
lcMacro = [loName.bg_note] + ALLTRIM(STR(curbudget.bg_period))
llNoteValue = NOT EMPTY(curbudget.bg_note)
STORE llNoteValue TO &lcMacro
IF NOT SEEK(STR(curbudget.bg_artinum,4)+PADR(UPPER(curbudget.bg_label),20)+;
     STR(curbudget.bg_main,1)+PADR(UPPER(curbudget.bg_market),3)+;
     STR(curbudget.bg_sub,2)+STR(curbudget.bg_year,4)+STR(curbudget.bg_hgnr,2)+;
     STR(curbudget.bg_sgnr,3))
	APPEND BLANK
ENDIF
lcMacro = [bg_artinum, bg_label, bg_main, bg_market, bg_sub, bg_year, bg_hgnr, bg_sgnr, ]+;
		  [bg_roomn] + ALLTRIM(STR(curbudget.bg_period)) + [, bg_reven] + ;
		  ALLTRIM(STR(curbudget.bg_period)) + [, bg_note] + ALLTRIM(STR(curbudget.bg_period))
GATHER NAME loName FIELDS &lcMacro MEMO

SELECT (lnSelected)

RETURN .T.
ENDPROC
*
PROCEDURE CopyFromBgdcurIntoBudget
LPARAMETERS plnPeriod
LOCAL lcMacro
IF PCOUNT() <> 1
	RETURN .F.
ENDIF
IF SEEK(STR(bgdcur.bg_year,4)+STR(plnPeriod,2)+STR(bgdcur.bg_artinum,4)+;
	 PADR(UPPER(bgdcur.bg_label),20)+STR(bgdcur.bg_main,1)+PADR(UPPER(bgdcur.bg_market),3)+;
     STR(bgdcur.bg_sub,2)+STR(bgdcur.bg_hgnr,2)+STR(bgdcur.bg_sgnr,3),"curbudget","tag4")
	lcMacro = [bgdcur.bg_roomn] + ALLTRIM(STR(plnPeriod))
	REPLACE curbudget.bg_roomnts WITH &lcMacro IN curbudget
	lcMacro = [bgdcur.bg_reven] + ALLTRIM(STR(plnPeriod))
	REPLACE curbudget.bg_revenue WITH &lcMacro IN curbudget
*	this.m_checksum(1,plnPeriod)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE DeleteRecordsInBgdDays
LOCAL lcKey
lcKey = PADR(STR(bg_year,4)+STR(bg_period,2)+STR(bg_artinum,4)+;
		PADR(UPPER(bg_label),20)+STR(bg_main,1)+PADR(UPPER(bg_market),3)+;
		STR(bg_sub,2)+STR(bg_hgnr,2)+STR(bg_sgnr,3),50)
DELETE FOR bd_key+str(bd_day,3) = lcKey IN curbgddays
RETURN .T.
ENDPROC
*
PROCEDURE InsertIntoBgdDays
LPARAMETERS plcKey, plnDay, plnRevenue, plnRoomnts
LOCAL lnSelected, loName, llOnlyInsert
IF PCOUNT()=2
	llOnlyInsert = .T.
ENDIF

lnSelected = SELECT()

SELECT curbgddays
SCATTER NAME loName BLANK
loName.bd_key = plcKey
loName.bd_day = plnDay
loName.bd_revenue = plnRevenue
loName.bd_roomnts = plnRoomnts
IF NOT SEEK(PADR(plcKey,50)+STR(plnDay,3),"curbgddays","tag1")
	APPEND BLANK
	GATHER NAME loName
ELSE
	IF NOT llOnlyInsert
		GATHER NAME loName
	ENDIF
ENDIF

SELECT (lnSelected)

RETURN .T.
ENDPROC
*
PROCEDURE CopyFromBgddaysIntoDayscur
LPARAMETERS lnType, lcCode
IF PCOUNT()<>2
	RETURN .F.
ENDIF
LOCAL lnSelected, loName, lcMacro
lnSelected = SELECT()

SELECT dayscur
SCATTER NAME loName BLANK

loName.bd_key = curbgddays.bd_key
loName.bd_code = lcCode
lcMacro = [loName.bd_value] + ALLTRIM(STR(curbgddays.bd_day))
IF lnType = 1
	STORE curbgddays.bd_roomnts TO &lcMacro
ELSE
	STORE curbgddays.bd_revenue TO &lcMacro
ENDIF

IF NOT SEEK(curbgddays.bd_key)
	APPEND BLANK
ENDIF
lcMacro = [bd_key, bd_code, bd_value]+ALLTRIM(STR(curbgddays.bd_day))
GATHER NAME loName FIELDS &lcMacro

SELECT (lnSelected)

RETURN .T.
ENDPROC
*
PROCEDURE DaysSum
LPARAMETERS plcSearchExp, plnSumRevenue, plnSumRoomnts
LOCAL lnSelected
lnSelected = SELECT()

SELECT curbgddays
SUM bd_revenue, bd_roomnts FOR (bd_key+STR(bd_day,3) = plcSearchExp) TO plnSumRevenue, plnSumRoomnts

SELECT (lnSelected)
RETURN .T.
ENDPROC
*
PROCEDURE LevelDaysSum
LPARAMETERS plcSearchExp, pllType, plnDaysSum, plnDays
LOCAL lcMacro1, lcMacro2, lnValue, lnNewSum
IF PCOUNT()<>4
	RETURN .F.
ENDIF
IF pllType = 1 OR pllType = 8
	lcMacro1 = "curbudget.bg_revenue"
	lcMacro2 = "curbgddays.bd_revenue"
ELSE
	lcMacro1 = "curbudget.bg_roomnts"
	lcMacro2 = "curbgddays.bd_roomnts"
ENDIF
IF SEEK(PADR(plcSearchExp,50)+STR(1,3),"curbgddays","tag1")
	IF &lcMacro1 > plnDaysSum
		lnValue = (&lcMacro1 - plnDaysSum) + &lcMacro2
		REPLACE &lcMacro2 WITH lnValue IN curbgddays
	ELSE
		lnNewSum = plnDaysSum
		FOR i = 1 TO plnDays
			IF SEEK(PADR(plcSearchExp,50)+STR(i,3),"curbgddays","tag1")
				lnNewSum = lnNewSum - &lcMacro2
				REPLACE &lcMacro2 WITH 0 IN curbgddays
				IF lnNewSum <= &lcMacro1
					REPLACE &lcMacro2 WITH &lcMacro1 - lnNewSum IN curbgddays
					EXIT
				ENDIF
			ENDIF
		ENDFOR
	ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE PeriodsCursorCreate
LPARAMETERS lp_cCursorName
 LOCAL ARRAY l_aFields(1)
 = AFIELDS(l_aFields,"curperiod")
 DO CursorAddField IN ProcBill WITH l_aFields, 'PE_CPERIOD', 'C', 2, 0
 DO CursorAddField IN ProcBill WITH l_aFields, 'PE_LENGTH', 'N', 2, 0
 DO CursorAddField IN ProcBill WITH l_aFields, 'PE_DESCRIP', 'C', 25, 0
 CREATE CURSOR &lp_cCursorName FROM ARRAY l_aFields
ENDPROC
*
PROCEDURE PeriodsCursorLoad
LPARAMETERS lp_nYear, lp_cCursorName
 LOCAL l_nArea, l_cYear
 l_nArea = SELECT()
 IF USED(lp_cCursorName)
	ZAP IN &lp_cCursorName
 ELSE
	PeriodsCursorCreate(lp_cCursorName)
 ENDIF
 l_cYear = ALLTRIM(STR(lp_nYear))
 SELECT curperiod
 LOCATE FOR (DTOS(pe_fromdat) = l_cYear) AND (pe_period == 1)
 IF FOUND()
	LOCAL l_nPrevious
	l_nPrevious = 0
	SET ORDER TO tag1
	SCAN REST WHILE pe_period > l_nPrevious
		l_nPrevious = pe_period
		INSERT INTO &lp_cCursorName ( ;
				pe_fromdat, pe_todat, pe_period, ;
				pe_cperiod, pe_length, ;
				pe_descrip) ;
				VALUES ( ;
				curperiod.pe_fromdat, curperiod.pe_todat, curperiod.pe_period, ;
				STR(curperiod.pe_period,2), curperiod.pe_todat-curperiod.pe_fromdat+1, ;
				PADR(DTOC(curperiod.pe_fromdat)+"-"+DTOC(curperiod.pe_todat),25))
	ENDSCAN
 ELSE
	LOCAL l_nCounter, l_dFirstDay, l_dLastDay
	FOR l_nCounter = 1 TO 12
		l_dFirstDay = EVALUATE("{^"+l_cYear+"-"+TRIM(STR(l_nCounter))+"-1}")
		l_dLastDay = l_dFirstDay + LastDay(l_dFirstDay+26) - 1
		INSERT INTO &lp_cCursorName ( ;
				pe_fromdat, pe_todat, pe_period, ;
				pe_cperiod, pe_length, ;
				pe_descrip) ;
				VALUES ( ;
				l_dFirstDay, l_dLastDay, l_nCounter, ;
				STR(l_nCounter,2), l_dLastDay-l_dFirstDay+1, ;
				PADR(MyCMonth(l_nCounter),10))
	ENDFOR
 ENDIF
 SELECT(l_nArea)
ENDPROC
*
PROCEDURE BudgetOrUpd
LPARAMETERS lp_cAlias, lp_oOrstat, lp_cLabel, l_cOperation, lp_nMainGroup
 LOCAL l_cField, l_nValue
 DO CASE
  CASE lp_cLabel = "RMNT_PER_MARKET"
	l_cField = "bg_roomnts"
	l_nValue = lp_oOrstat.or_crms &&.or_cpax
  CASE lp_cLabel = "REV_PER_MARKET"
	l_cField = "bg_revenue"
	l_nValue = lp_oOrstat.or_crev0 + lp_oOrstat.or_crev1 + ;
			lp_oOrstat.or_crev2 + lp_oOrstat.or_crev3 + ;
			lp_oOrstat.or_crev4 + lp_oOrstat.or_crev5 + ;
			lp_oOrstat.or_crev6 + lp_oOrstat.or_crev7 + ;
			lp_oOrstat.or_crev8 + lp_oOrstat.or_crev9 + ;
			lp_oOrstat.or_crevx
  CASE lp_cLabel = "REV_PER_MAINGROUP"
	l_cField = "bg_revenue"
	l_nValue = EVALUATE("lp_oOrstat.or_crev" + ALLTRIM(STR(lp_nMainGroup)))
  OTHERWISE
	RETURN .F.
 ENDCASE
 IF l_cOperation = "SUB"
	l_nValue = -1 * l_nValue
 ENDIF
 REPLACE &l_cField WITH EVALUATE(lp_cAlias+"."+l_cField)+l_nValue IN &lp_cAlias
 RETURN .T.
ENDPROC
*
PROCEDURE BudgetSuggest
LPARAMETERS lp_cLblBudget, lp_xCode, lp_cAlias, lp_dFrom, lp_dTo
 LOCAL l_cNear, l_oOrStat, l_dEndOfYear, l_cSql
 *LOCAL l_cOrderOrstat, l_cOrderHistors
 *l_cOrderOrstat = ORDER("orstat")
 *l_cOrderHistors = ORDER("histors")
 *SET ORDER TO tag1 IN orstat DESCENDING
 *SET ORDER TO tag1 IN histors DESCENDING
 l_cNear = SET("Near")
 DO CASE
  CASE INLIST(lp_cLblBudget, "RMNT_PER_MARKET", "REV_PER_MARKET")
	SET NEAR ON
	DO OrGetStat IN OrUpd WITH "curorstat", "MARKET", lp_xCode, lp_dTo, l_oOrstat
	= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "ADD")
	DO OrGetStat IN OrUpd WITH "curhistors", "MARKET", lp_xCode, lp_dTo, l_oOrstat
	= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "ADD")
	IF YEAR(lp_dTo) <> YEAR(lp_dFrom-1)
		l_dEndOfYear = EVALUATE("{^" + ALLTRIM(STR(YEAR(lp_dFrom-1))) + "-12-31}")
		DO OrGetStat IN OrUpd WITH "curorstat", "MARKET", lp_xCode, l_dEndOfYear, l_oOrstat
		= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "ADD")
		DO OrGetStat IN OrUpd WITH "curhistors", "MARKET", lp_xCode, l_dEndOfYear, l_oOrstat
		= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "ADD")
	ENDIF
	DO OrGetStat IN OrUpd WITH "curorstat", "MARKET", lp_xCode, lp_dFrom-1, l_oOrstat
	= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "SUB")
	DO OrGetStat IN OrUpd WITH "curhistors", "MARKET", lp_xCode, lp_dFrom-1, l_oOrstat
	= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "SUB")
	SET NEAR &l_cNear
  CASE lp_cLblBudget = "REV_PER_MAINGROUP"
	SET NEAR ON
	DO OrGetMainGrStat IN OrUpd WITH lp_xCode, lp_dTo, "", l_oOrStat
	= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "ADD", lp_xCode)
	IF YEAR(lp_dTo) <> YEAR(lp_dFrom-1)
		l_dEndOfYear = EVALUATE("{^" + ALLTRIM(STR(YEAR(lp_dFrom-1))) + "-12-31}")
		DO OrGetMainGrStat IN OrUpd WITH lp_xCode, lp_dFrom-1, "", l_oOrStat
		= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "ADD", lp_xCode)
	ENDIF
	DO OrGetMainGrStat IN OrUpd WITH lp_xCode, lp_dFrom-1, "", l_oOrStat
	= BudgetOrUpd(lp_cAlias, l_oOrstat, lp_cLblBudget, "SUB", lp_xCode)
	SET NEAR &l_cNear
  CASE INLIST(lp_cLblBudget, "REV_PER_SUBGROUP", "REV_PER_ARTICLE")
	LOCAL l_nArea, l_cField
	l_nArea = SELECT()
	DO CASE
	 CASE lp_cLblBudget = "REV_PER_SUBGROUP"
		l_cField = "ar_sub"
	 CASE lp_cLblBudget = "REV_PER_ARTICLE"
		l_cField = "ar_artinum"
	ENDCASE

	TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
	SELECT SUM(hp_amount) AS sum_hp_amount, <<l_cField>> 
			FROM histpost 
			INNER JOIN article ON hp_artinum = ar_artinum 
			WHERE hp_date BETWEEN <<sqlcnv(lp_dFrom,.T.)>> AND <<sqlcnv(lp_dTo,.T.)>> AND 
				NOT hp_cancel AND (hp_ratecod = '<<REPLICATE(" ",23)>>' OR hp_split) 
				AND <<l_cField>> = <<sqlcnv(lp_xCode,.T.)>> 
			GROUP BY <<l_cField>> 
	ENDTEXT
	sqlcursor(l_cSql,"tblBudgetSuggest")
*!*		SELECT SUM(hp_amount), &l_cField ;
*!*				FROM histpost ;
*!*				LEFT JOIN article ON hp_artinum = ar_artinum ;
*!*				WHERE BETWEEN(hp_date,lp_dFrom,lp_dTo) AND ;
*!*					NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
*!*					AND &l_cField = lp_xCode ;
*!*				GROUP BY &l_cField ;
*!*				INTO CURSOR tblBudgetSuggest
*!*					*AND (INLIST(ar_artityp,1,3) OR ISNULL(ar_artityp))
	SELECT(lp_cAlias)
	REPLACE bg_revenue WITH bg_revenue + tblBudgetSuggest.sum_hp_amount
	SELECT(l_nArea)
 ENDCASE
 *SET ORDER TO l_cOrderOrstat IN orstat
 *SET ORDER TO l_cOrderHistors IN histors
 RETURN .T.
ENDPROC
*
