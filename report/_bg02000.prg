PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "7.10"
RETURN tcVersion
ENDPROC
*
PROCEDURE _bg02000
LPARAMETER tcType
LOCAL lcLabel, loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

IF TYPE("tcType") # "C"
     tcType = "A"
ENDIF
DO CASE
     CASE tcType = "M"             && M = Maingroup
          lcLabel = "MAINGROUP"
     CASE tcType = "S"             && S = Subgroup
          lcLabel = "SUBGROUP"
     OTHERWISE && tcType = "A"     && A = Article
          lcLabel = "ARTICLE"
ENDCASE

loSession = CREATEOBJECT("_bg02000")
loSession.DoPreproc(lcLabel, @laPreProc)
RELEASE loSession

PpCusorCreate()
IF NOT EMPTY(laPreProc(1))
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
*
PROCEDURE PpCusorCreate
CREATE CURSOR PreProc (pp_label C(20), pp_num N(4), pp_descr C(35), pp_rev B(2), pp_revptd B(2), pp_revytd B(2), pp_bmrev B(2), pp_byrev B(2))
INDEX ON pp_num TAG pp_num
ENDPROC
*
PROCEDURE PpCusorInit
LPARAMETERS tcLabel, tdStartDate, tdEndDate
LOCAL ldDate, lcLang, lnPeriod, ldStartPeriodDate, lnDays, llUsePeriod

DO CASE
     CASE tcLabel = "ARTICLE"
          lcLang = "ar_lang" + g_Langnum
          INSERT INTO PreProc (pp_label, pp_num, pp_descr) ;
               SELECT [REV_PER_] + tcLabel, ar_artinum, &lcLang FROM article WHERE ar_artityp = 1 ORDER BY ar_artinum
     CASE tcLabel = "MAINGROUP"
          lcLang = "pl_lang" + g_Langnum
          INSERT INTO PreProc (pp_label, pp_num, pp_descr) ;
               SELECT [REV_PER_] + tcLabel, pl_numcod, &lcLang FROM picklist WHERE pl_label = tcLabel ORDER BY pl_numcod
     CASE tcLabel = "SUBGROUP"
          lcLang = "pl_lang" + g_Langnum
          INSERT INTO PreProc (pp_label, pp_num, pp_descr) ;
               SELECT [REV_PER_] + tcLabel, pl_numcod, &lcLang FROM picklist WHERE pl_label = tcLabel ORDER BY pl_numcod
ENDCASE

CREATE CURSOR curPeriod (tp_date D(8), tp_period N(2))
llUsePeriod = .F.
ldDate = tdStartDate
DO WHILE ldDate <= tdEndDate
     IF NOT llUsePeriod OR ldDate >= ldStartPeriodDate + lnDays
          *DO GetPeriodInfo IN ProcPeriod WITH ldDate, , lnPeriod, ldStartPeriodDate, lnDays, , llUsePeriod
          llUsePeriod = GetPeriodInfo(ldDate, , @lnPeriod, @ldStartPeriodDate, @lnDays)
     ENDIF
     INSERT INTO curPeriod (tp_date, tp_period) VALUES (ldDate, lnPeriod)
     ldDate = ldDate + 1
ENDDO
ENDPROC
*
PROCEDURE GetPeriodInfo     && Identical procedure is built-in Citadel Desk EXE from version 9.8.62
LPARAMETERS tdDate, tdStartYearDate, tnPeriod, tdStartPeriodDate, tnDays, tnDaysPassedFromPeriodStart, tlUsePeriod
* Receives Parameter :
* tdDate
* Changes and returns :
* tdStartYearDate, tnPeriod, tdStartPeriodDate, tnDays, tnDaysPassedFromPeriodStart, tlUsePeriod

LOCAL llPeriodUsed, lnOrder, lnSelect, lnPeriod, llFound

tnPeriod = MONTH(tdDate)
tdStartPeriodDate = DATE(YEAR(tdDate),MONTH(tdDate),1)
tnDays = LastDay(tdDate)
tdStartYearDate = DATE(YEAR(tdDate),1,1)
tlUsePeriod = .F.

lnSelect = SELECT()

llPeriodUsed = USED("period")
IF llPeriodUsed
     lnOrder = ORDER("period")
ELSE
     OpenFileDirect(.F., "period")
ENDIF

IF USED("period")
     SELECT period
     SET ORDER TO Tag1 DESCENDING
     LOCATE FOR DTOS(pe_fromdat) <= DTOS(tdDate) AND pe_todat >= tdDate
     IF FOUND()
          tlUsePeriod = .T.
          tnPeriod = pe_period
          tdStartPeriodDate = pe_fromdat
          tnDays = pe_todat - pe_fromdat + 1
          lnPeriod = pe_period + 1
          SCAN REST WHILE BETWEEN(pe_period, 1, lnPeriod-1)
               lnPeriod = pe_period
               tdStartYearDate = pe_fromdat
          ENDSCAN
     ENDIF
ENDIF

IF llPeriodUsed
     SET ORDER TO &lnOrder ASCENDING
ELSE
     USE IN period
ENDIF

SELECT (lnSelect)

tnDaysPassedFromPeriodStart = tdDate - tdStartPeriodDate + 1

RETURN tlUsePeriod
ENDPROC
*
DEFINE CLASS _bg02000 AS Session

PROCEDURE Init
Ini()
OpenFile()
PpCusorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER tcLabel, taPreProc
LOCAL ldStartYearDateCurr, lnYearCurr, lnPeriodCurr, ldStartPeriodDateCurr, lnDaysCurr, lnDaysPassedFromPeriodStartCurr
LOCAL ldEndDate, lcArticleField, lcBudgetField, lcAmountField, lcArchScripts

DO CASE
     CASE tcLabel = "ARTICLE"
          lcArticleField = "ar_artinum"
          lcBudgetField = "bg_artinum"
     CASE tcLabel = "MAINGROUP"
          lcArticleField = "ar_main"
          lcBudgetField = "bg_main"
     CASE tcLabel = "SUBGROUP"
          lcArticleField = "ar_sub"
          lcBudgetField = "bg_sub"
ENDCASE

ldEndDate = min1

GetPeriodInfo(ldEndDate, @ldStartYearDateCurr, @lnPeriodCurr, @ldStartPeriodDateCurr, @lnDaysCurr, @lnDaysPassedFromPeriodStartCurr)
lnYearCurr = YEAR(ldStartYearDateCurr)

PpCusorInit(tcLabel, ldStartYearDateCurr, ldEndDate)

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histpost.* FROM histpost
     WHERE BETWEEN(hp_date, <<SqlCnvB(ldStartYearDateCurr)>>, <<SqlCnvB(ldEndDate)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histpost", lcArchScripts, ldStartYearDateCurr)
*
****************************************************************************************************

IF min3 AND NOT param.pa_exclvat
     lcAmountField = "hp_amount-hp_vat1-hp_vat2-hp_vat3-hp_vat4-hp_vat5-hp_vat6-hp_vat7-hp_vat8-hp_vat9-hp_vat0"
ELSE
     lcAmountField = "hp_amount"
ENDIF

SELECT &lcArticleField AS xx_num, hp_date, SUM(&lcAmountField) AS xx_rev FROM HistPost INNER JOIN Article ON hp_artinum = ar_artinum ;
     WHERE BETWEEN(hp_date, ldStartYearDateCurr, ldEndDate) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND ar_artityp = 1 ;
     GROUP BY &lcArticleField, hp_date INTO CURSOR curPost
SCAN FOR hp_date = ldEndDate
     UPDATE preproc SET pp_rev = curPost.xx_rev WHERE pp_num = curPost.xx_num
ENDSCAN

SELECT xx_num, SUM(xx_rev) AS xx_rev FROM curPost INNER JOIN curPeriod ON hp_date = tp_date ;
     WHERE tp_period = lnPeriodCurr ;
     GROUP BY xx_num INTO CURSOR tmpPost
SCAN
     UPDATE Preproc SET pp_revptd = tmpPost.xx_rev WHERE pp_num = tmpPost.xx_num
ENDSCAN

SELECT xx_num, SUM(xx_rev) AS xx_rev FROM curPost ;
     GROUP BY xx_num INTO CURSOR tmpPost
SCAN
     UPDATE Preproc SET pp_revytd = tmpPost.xx_rev WHERE pp_num = tmpPost.xx_num
ENDSCAN

SELECT &lcBudgetField AS xx_num, SUM(bg_revenue) AS xx_rev FROM Budget ;
     WHERE bg_period = lnPeriodCurr AND bg_year = lnYearCurr AND bg_label = [REV_PER_] + tcLabel ;
     GROUP BY &lcBudgetField INTO CURSOR tmpBudget
SCAN
     UPDATE Preproc SET pp_bmrev = tmpBudget.xx_rev * lnDaysPassedFromPeriodStartCurr/lnDaysCurr, ;
                        pp_byrev = tmpBudget.xx_rev * lnDaysPassedFromPeriodStartCurr/lnDaysCurr WHERE pp_num = tmpBudget.xx_num
ENDSCAN

SELECT &lcBudgetField AS xx_num, SUM(bg_revenue) AS xx_rev FROM Budget ;
     WHERE bg_period < lnPeriodCurr AND bg_year = lnYearCurr AND bg_label = [REV_PER_] + tcLabel ;
     GROUP BY &lcBudgetField INTO CURSOR tmpBudget
SCAN
     UPDATE Preproc SET pp_byrev = pp_byrev + tmpBudget.xx_rev WHERE pp_num = tmpBudget.xx_num
ENDSCAN

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histpost")
*
****************************************************************************************************

USE IN curPost
USE IN tmpPost
USE IN tmpBudget

SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE
*