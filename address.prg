*
PROCEDURE BrwAddress
 PARAMETER p_Order, p_Size, plSelectmode, pcAlias
 clEvel = "ADDR"
LOCAL ARRAY LArray(12)
LArray(12) = .T.
doform('addressmask','forms\addressmask','',.F.,@LArray)
 RETURN .T.
ENDPROC
*
FUNCTION MakeSalut
 LPARAMETER pcTitle, pcLastname, pcRet
 PRIVATE crEt
 PRIVATE ctEmp

 crEt = ""
 ctEmp = TRIM(flIp(pcLastname))
 IF  .NOT. EMPTY(ctEmp)
      crEt = UPPER(SUBSTR(ctEmp, 1, 1))
      IF LEN(ctEmp)>1
           crEt = crEt+SUBSTR(ctEmp, 2)
      ENDIF
 ENDIF
 crEt = TRIM(pcTitle)+IIF(EMPTY(crEt),""," "+crEt)+","
 pcRet = crEt

 RETURN crEt
ENDFUNC
*
FUNCTION PHONENOTE
 LOCAL ARRAY LParamArray(5)
 IF (WEXIST ('FAddressMask'))
	 DO CASE 
	 	case _screen.activeform.name = 'FAddressMask'
			LParamArray(1) = "FADDRESSMASK"
			LParamArray(2) =_screen.activeform.DataSessionId
			LParamArray(3) = "NEW"
			DO FORM forms\phonenote NAME phonenote LINKED WITH LParamArray
	 ENDCASE
 ENDIF
 RETURN .T.
ENDFUNC
*