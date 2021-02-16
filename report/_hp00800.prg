PROCEDURE PpVersion
 PARAMETER cversion
 cversion = "1.03"
 RETURN
ENDPROC

PROCEDURE _hp00800
LOCAL l_payonld
**** TEST
*!*	min2 = CTOD("01.10.2016")
*!*	max2 = CTOD("31.10.2016")
*!*	Min3 = "KRANKENHAUS GMBH"
***
oldselect = SELECT()
l_payonld = param.pa_payonld

SELECT hp_addrid as ReAdr, CAST(0 as I) as hr_rsid, 00000000 as pw_addrid, SPACE(25) as hr_lname, histpost.* ;
FROM histpost ;
WHERE BETWEEN(hp_date, min2, max2) ;
AND hp_paynum = l_payonld ;
AND hp_reserid > 0 ;
AND NOT hp_cancel ;
ORDER BY hp_date ;
INTO CURSOR preproc READWRITE 

SELECT preproc
SCAN
	IF hp_reserid = 0.1 AND hp_addrid = 0
		REPLACE ReAdr WITH -9999999
	ELSE
		REPLACE ReAdr WITH hp_addrid
	ENDIF 
	IF hp_reserid <> 0.1
		SELECT histres
		SET ORDER TO TAG1
		SEEK preproc.hp_reserid
		IF FOUND()
			REPLACE preproc.hr_rsid WITH hr_rsid
			REPLACE preproc.hr_lname WITH hr_lname
			SELECT hpwindow
			SET ORDER TO TAG2
			SEEK histres.hr_rsid
			IF FOUND()
				REPLACE preproc.pw_addrid WITH pw_addrid
				IF pw_addrid <> 0
					REPLACE preproc.ReAdr WITH pw_addrid
				ELSE
					IF pw_window = 2
						REPLACE preproc.ReAdr WITH histres.hr_compid
					ELSE
						REPLACE preproc.ReAdr WITH histres.hr_addrid
					ENDIF 
				ENDIF 
			ENDIF 
		ENDIF
	ENDIF  
ENDSCAN

SELECT * FROM preproc LEFT JOIN address ON ReAdr = ad_addrid WHERE 1=1 INTO CURSOR preproc

l_cCompany = UPPER(alltrim(min3))

IF NOT EMPTY(min3)
	SELECT * FROM preproc WHERE UPPER(ad_company) = l_cCompany INTO CURSOR preproc
ENDIF

SELECT (oldselect)
ENDPROC
