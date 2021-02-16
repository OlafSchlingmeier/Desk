FUNCTION getcheckno
LPARAMETERS lp_lIncludeYear, lp_nNewID
LOCAL nyearfourdigit, csysdateyear, cnewid, cappid, ncheckid
cappid = _screen.oGlobal.GettBillFirst2Numbers()
ncheckid = 0
IF lp_lIncludeYear
     nyearfourdigit = YEAR(sysdate())
     csysdateyear = RIGHT(STR(nyearfourdigit,4),2)
     cnewid = ALLTRIM(STR(lp_nNewID))
     ncheckid = INT(VAL(cappid + csysdateyear + PADL(RIGHT(cnewid,6),6,"0")))
ELSE
     cnewid = ALLTRIM(STR(lp_nNewID))
     ncheckid = INT(VAL(cappid + PADL(RIGHT(cnewid,8),8,"0")))
ENDIF
RETURN ncheckid
ENDFUNC
*