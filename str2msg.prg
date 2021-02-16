FUNCTION Str2Msg
LPARAMETERS lp_String, lp_str, lp_exp1, lp_exp2, lp_exp3, lp_exp4, lp_exp5, lp_exp6, lp_exp7, lp_exp8, lp_exp9, lp_exp10, lp_exp11, lp_exp12, lp_exp13, lp_exp14, lp_exp15
LOCAL l_Message, i, l_str, l_nOccurs

l_Message = lp_String
l_Message = STRTRAN(l_Message, ";", CHR(13) + CHR(10))
l_nOccurs = IIF(PCOUNT() < 2, 0, OCCURS(lp_str, lp_String))
FOR i = 1 TO l_nOccurs
	IF l_nOccurs = 1
		l_str = lp_str
	ELSE
		l_str = lp_str + ALLTRIM(STR(i))
	ENDIF
	l_Message = STRTRAN(l_Message, l_str, EVALUATE("lp_exp" + ALLTRIM(STR(i))), 1, 1)
ENDFOR

RETURN l_Message
ENDFUNC