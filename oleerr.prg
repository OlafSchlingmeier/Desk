PROCEDURE oleErr
PARAMETER mError
=AERROR(errarray)
DO case
	CASE errarray(1)=1426
*		asdf = 0
*		MESSAGEBOX("Install office aplication",48)
	CASE errarray(1)=1429 AND errarray(7)=4605
	
	OTHERWISE
		MESSAGEBOX(errarray(3)+' in '+errarray(4) ,48)
ENDCASE
RETURN&& TO mybrowse

*IF mError = 1426 then
* myword = CreateObject("word.application")
*ENDIF
