 PARAMETER pnId, pnTop, pnLeft, pnWidth, pnapid, pninvapid, pnapname, pnlname
 PRIVATE naRea, naDrec, naDord, nrOw
 LOCAL _k, _check, LApartCheck
 _k = PARAMETERS()
 naRea = SELECT()
  if !used('address')
 	return
 endif
 SELECT adDress
 naDord = ORDER()
 naDrec = RECNO()
 SET ORDER TO 1
 IF EMPTY(pnId)
      nrOw = pnTop
      @ nrOw, pnLeft SAY '' SIZE 1, pnWidth
      nrOw = nrOw+1
      @ nrOw, pnLeft SAY '' SIZE 1, pnWidth
      nrOw = nrOw+1
      @ nrOw, pnLeft SAY '' SIZE 1, pnWidth
      nrOw = nrOw+1
      @ nrOw, pnLeft SAY '' SIZE 1, pnWidth
      nrOw = nrOw+1
      @ nrOw, pnLeft SAY '' SIZE 1, pnWidth
 ELSE
      IF SEEK(pnId)
           nrOw = pnTop
           IF  .NOT. EMPTY(ad_company)
                IF _k = 8 AND pnapid > 0
	                IF SEEK (m.rs_apid,'apartner','tag3')
	                	  IF pnId =  pninvapid AND UPPER(ALLTRIM(apartner.ap_lname)) == ALLTRIM(pnlname)
	                	  	_check = .T.
	                	  	LApartCheck = .T.
	                	  ENDIF
	                ENDIF
	           ELSE
	                @ nrOw, pnLeft SAY flIp(ad_company) SIZE 1, pnWidth COLOR  ;
	                  RGB(0,0,255,192,192,192)
	                nrOw = nrOw+1
		    ENDIF
           ENDIF
           IF _k = 5 AND !_check
              IF m.rs_apid > 0
              	IF SEEK(m.rs_apid, 'apartner', 'TAG3')
              		_check = .T.
              	endif
              ENDIF
           ENDIF
           IF _k = 6 AND !_check
              IF m.rs_invapid > 0
              	IF SEEK(m.rs_invapid, 'apartner', 'TAG3')
              		_check = .T.
              	endif
              ENDIF
           ENDIF

           IF _check
  		       @ nrOw, pnLeft SAY IIF(EMPTY(apartner.ap_title),"",TRIM(apartner.ap_title)+' ')+IIF(EMPTY(apartner.ap_fname),"",TRIM(apartner.ap_fname)+' ')+ ;
        		 flip(apartner.ap_lname) SIZE 1, pnWidth COLOR RGB(0,0,255,192,192,192)
       		   nrOw = nrOw+1
	     ELSE
			   @ nrOw, pnLeft SAY TRIM(ad_title)+' '+TRIM(ad_fname)+' '+ ;
		             flIp(ad_lname) SIZE 1, pnWidth COLOR RGB(0,0,255,192,192,192)
		           nrOw = nrOw+1
	     ENDIF
		IF !LApartCheck
		           @ nrOw, pnLeft SAY ad_street SIZE 1, pnWidth COLOR RGB(0,0,255, ;
		             192,192,192)
		           nrOw = nrOw+1
		           @ nrOw, pnLeft SAY TRIM(ad_zip)+' '+TRIM(ad_city)+ ;
		             IIF(ad_country<>paRam.pa_country, ' '+ad_country, '') SIZE 1,  ;
		             pnWidth COLOR RGB(0,0,255,192,192,192)
		           nrOw = nrOw+1
		           IF _check
			           @ nrOw, pnLeft SAY 'Tel:'+TRIM(apartner.ap_phone1)+' Fax:'+TRIM(apartner.ap_fax)  ;
			             SIZE 1, pnWidth COLOR RGB(0,0,255,192,192,192)
			           nrOw = nrOw+1
				   ELSE
		  	           @ nrOw, pnLeft SAY 'Tel:'+TRIM(ad_phone)+' Fax:'+TRIM(ad_fax)  ;
					     SIZE 1, pnWidth COLOR RGB(0,0,255,192,192,192)
					   nrOw = nrOw+1
			     ENDIF
		ENDIF
      ELSE
           = alErt("Address ID not found!")
      ENDIF
 ENDIF
 GOTO naDrec
 SET ORDER TO nAdOrd
 SELECT (naRea)
 RETURN
ENDPROC
*
