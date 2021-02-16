PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.12"
RETURN tcVersion
ENDPROC
*
PROCEDURE fc01000p
PARAMETER tlWithoutVat
LOCAL lcAdrFilter, lcMin3, lcMax3

IF NOT EMPTY(min3) AND NOT EMPTY(max3)
	lcAdrFilter = [between(padl(alltrim(ad_zip),5," "),"]+min3+[","]+max3+[") AND NOT empty(ad_zip) AND ad_country IN ("D ", "DE") AND fc01000pIsGermanZipCode(ad_zip)]
	*lcAdrFilter = StrToSql("between(padl(alltrim(ad_zip),5,' '),%s1,%s2) AND NOT empty(ad_zip) AND ad_country IN ('D ', 'DE'),%n1,%n2)", min3, max3)
	*lcAdrFilter = StrToSql("BETWEEN(VAL(ad_zip),%n1,%n2)", min3, max3)
ENDIF
lcMin3 = min3
lcMax3 = max3
STORE 0 TO min3, max3
_fc01000(tlWithoutVat,,lcAdrFilter)
min3 = lcMin3
max3 = lcMax3
ENDPROC
*
PROCEDURE fc01000pIsGermanZipCode
LPARAMETER lp_cString
LOCAL l_lIsString, i
l_lIsString = .T.
IF VARTYPE(lp_cString)="C"
     lp_cString = ALLTRIM(lp_cString)
     IF LEN(lp_cString)==5
          FOR i = 1 TO LEN(lp_cString)
               l_cChar = substr(lp_cString,i,1)
               IF NOT ISDIGIT(l_cChar)
                    l_lIsString = .F.
                    EXIT
               ENDIF
          ENDFOR
     ELSE
          l_lIsString = .F.
     ENDIF
ENDIF
RETURN l_lIsString
endproc
*