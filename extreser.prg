LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
               lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
LOCAL l_cCallProc, l_nParamNo, l_uRetVal

IF PCOUNT()=0
     doform("extreser","forms\extreser")
     RETURN .T.
ENDIF

l_cCallProc = lp_cFuncName + "("

FOR l_nParamNo = 1 TO PCOUNT()-1
     l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
ENDFOR

l_cCallProc = l_cCallProc + ")"

l_uRetVal = &l_cCallProc

RETURN l_uRetVal
ENDPROC
*
PROCEDURE GetCountryCode
* Try to find desk country code in picklist table.
* When not found, return hotel country code.

LPARAMETERS lp_cCitwebCountryCode
LOCAL l_cDeskCountryCode, l_cCitwebCountryCode

l_cDeskCountryCode = ""

IF NOT EMPTY(lp_cCitwebCountryCode)
     l_cCitwebCountryCode = UPPER(PADR(ALLTRIM(lp_cCitwebCountryCode),3))
     l_cDeskCountryCode = dlookup("picklist","pl_label = 'COUNTRY   ' AND pl_user2 = " + sqlcnv(l_cCitwebCountryCode,.T.),"pl_charcod")
     IF EMPTY(l_cDeskCountryCode)
          l_cDeskCountryCode = _screen.oGlobal.oParam.pa_country
     ENDIF
     l_cDeskCountryCode = ALLTRIM(l_cDeskCountryCode)
ENDIF

RETURN l_cDeskCountryCode
ENDPROC