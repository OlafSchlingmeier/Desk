PROCEDURE Enigma
PARAMETER pldemo, pllite, pchotel, plexpire
 pldemo = .T.
 pllite = .F.
 plexpire = .F.
 IF finalenigma(_screen.oGlobal.oParam.pa_expires)
      IF NOT EMPTY(_screen.oGlobal.oParam.pa_expires) AND _screen.oGlobal.oParam.pa_sysdate > _screen.oGlobal.oParam.pa_expires
           plexpire = .T.
      ELSE
           pldemo = .F.
           pchotel = ALLTRIM(_screen.oGlobal.oParam.pa_hotel)+", "+ALLTRIM(_screen.oGlobal.oParam.pa_city)
      ENDIF
 ENDIF
 RETURN
ENDPROC
*
FUNCTION FinalEnigma
 PARAMETER dexpirationdate
 PRIVATE nchecksum, ncounter, nfactor, chotel, nkey, nkeydate, lisnodemo, anprime, ccriptor, I
 LOCAL ln_MaxRooms
 ccriptor = "hHzd83$-c!"
 chotel = ANSITOOEM(ALLTRIM(_screen.oGlobal.oParam.pa_hotel)+ccRiptor+ALLTRIM(_screen.oGlobal.oParam.pa_city) + ALLTRIM(_screen.oGlobal.oParam.pa_lizopt) + ;
           IIF(_screen.oGlobal.oParam.pa_expd2,"!TX-c",""))
 DIMENSION anprime[LEN(chotel)] 
 FOR I = LEN(chotel) TO 1 STEP -1
      anprime[I] = VAL(SYS(2007, RIGHT(chotel, LEN(chotel) - I + 1)))
 ENDFOR
 nkey = 0
 nkeydate = 0
 lisnodemo = .F.
 nchecksum = 0
 IF EMPTY(dexpirationdate)
      dexpirationdate = {^1968-12-28}
 ENDIF
 IF (NOT EMPTY(_screen.oGlobal.oParam.pa_hotel) AND NOT EMPTY(_screen.oGlobal.oParam.pa_city))
      nkeydate = INT(VAL(SYS(2007,DTOS(dexpirationdate))))+_screen.oGlobal.oParam.pa_maxroom
      FOR ncounter = 1 TO LEN(ALLTRIM(STR(nkeydate)))
           nkey = nkey + VAL(SUBSTR(ALLTRIM(STR(nkeydate)),ncounter,1))
      ENDFOR
      FOR ncounter = LEN(chotel) TO 1 STEP -1
           nfactor = anprime(ncounter)
           nchecksum = nchecksum+INT(ASC(SUBSTR(chotel, ncounter, 1))*nfactor*nkey)
      ENDFOR
      nchecksum = nchecksum+INT((INT(_screen.oGlobal.oParam.pa_version)*147+_screen.oGlobal.oParam.pa_maxuser*13)^3)+nkeydate
      lisnodemo = (nchecksum==_screen.oGlobal.oParam.pa_license)
 ENDIF
 ln_MaxRooms = CountRoomsInHotel()
 IF ln_MaxRooms > _screen.oGlobal.oParam.pa_maxroom
      lisnodemo = .F.
 ENDIF
 RETURN lisnodemo
ENDFUNC
*
FUNC stod
 PARAMETERS p_string
 PRIVATE ALL LIKE l_*
 l_olddate = SET("date")
 l_oldcentury = SET("century")
 SET DATE ansi
 SET CENTURY ON
 p_string = STUFF(p_string, 5, 0, ".")
 p_string = STUFF(p_string, 8, 0, ".")
 l_retval = CTOD(p_string)
 SET DATE &l_OldDate
 SET CENTURY &l_OldCentury
 RETURN l_retval
ENDFUNC
*
