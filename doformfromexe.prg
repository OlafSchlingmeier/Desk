*
PROCEDURE DoFormFromExe
LPARAMETERS tvFormName, tvParam1, tvParam2, tvParam3, tvParam4, tvParam5, tvParam6, tvParam7, tvParam8, tvParam9, tvParam10, tvParam11, tvParam12, tvParam13, tvParam14, tvParam15
LOCAL lcParams

IF PCOUNT() > 1
	lcParams = "tvParam1, tvParam2, tvParam3, tvParam4, tvParam5, tvParam6, tvParam7, tvParam8, tvParam9,tvParam10,tvParam11,tvParam12,tvParam13,tvParam14,tvParam15"
	lcParams = "WITH " + LEFT(lcParams, (PCOUNT()-1)*10-2)
ELSE
	lcParams = ""
ENDIF
IF TYPE("p_uDoFormFromExeTo")="U"
     DO FORM &tvFormName &lcParams
ELSE
     DO FORM &tvFormName &lcParams TO p_uDoFormFromExeTo
ENDIF

RETURN .T.
ENDPROC
*