*
PROCEDURE GetPeriodInfo
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