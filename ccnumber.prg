 PARAMETER pcCcno
 PRIVATE nlEn, nfActor, ntOtal, i, ntMp, ccHeckno, lrEt
 IF EMPTY(pcCcno) .OR. LASTKEY()=27
      RETURN .T.
 ENDIF
 nfActor = 2
 ntOtal = 0
 ccHeckno = STRTRAN(pcCcno, " ", "")
 ccHeckno = STRTRAN(ccHeckno, "-", "")
 ccHeckno = PADL(ccHeckno, 16, "0")
 nlEn = LEN(ccHeckno)-1
 FOR i = 1 TO nlEn
      ntMp = VAL(SUBSTR(ccHeckno, i, 1))*nfActor
      ntOtal = ntOtal+INT(MOD(ntMp, 10))+INT(ntMp/10)
      nfActor = IIF(nfActor==1, 2, 1)
 ENDFOR
 ntOtal = 10-(MOD(ntOtal, 10))
 IF (ntOtal==10)
      ntOtal = 0
 ENDIF
 IF ntOtal<>VAL(SUBSTR(ccHeckno, nlEn+1, 1))
      crEaderror = GetLangText("CCNUMBER","TA_CCINVALID")
      lrEt = .F.
 ELSE
      lrEt = .T.
 ENDIF
 RETURN lrEt
ENDFUNC
*
