FUNCTION DLock
LPARAMETER lp_cAlias, lp_nReprocess, lp_lNoMessage
LOCAL l_nReprocessCount, l_nReprocessType, l_lSuccess, l_cMessage

IF EMPTY(lp_cAlias)
	lp_cAlias = ALIAS()
ENDIF
IF EMPTY(lp_nReprocess)
	lp_nReprocess = 5
ENDIF

l_nReprocessCount = SET("Reprocess")
l_nReprocessType = SET("Reprocess", 2)
l_cMessage = SET("Message", 1)

SET REPROCESS TO (lp_nReprocess)
l_lSuccess = RLOCK(lp_cAlias)

SET MESSAGE TO l_cMessage
IF l_nReprocessType = 1
	SET REPROCESS TO (l_nReprocessCount) SECONDS
ELSE
	SET REPROCESS TO (l_nReprocessCount)
ENDIF

IF NOT l_lSuccess AND NOT lp_lNoMessage
	Alert("Record couldn't be locked!")
ENDIF

RETURN l_lSuccess
ENDFUNC
*