FUNCTION LocalOleError
LOCAL ARRAY laError(1)
=AERROR(laError)

DO CASE
	CASE laError(1)=1426
		IF g_WordTest
			* Do Nothing, Word could not be started, while he is not yet opened
		ELSE
			= alert("This error occoured:"+CHR(13)+laError(2)+CHR(13)+laError(3)+CHR(13)+CHR(13)+;
			           "Operation is canceled!")
		ENDIF
*	CASE laError(1)=1429 AND laError(7)=4605
		* Do Nothing, Word could not be started, while he is not yet opened
	OTHERWISE
		DO ERRORSYS WITH 	ERROR(),MESSAGE(),"PRTREPORT",LINENO(),MESSAGE(1) IN ERRORSYS
ENDCASE

RETURN .T.