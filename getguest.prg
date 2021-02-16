 PARAMETER pcSearch, pcSharename, pnId , PCCALL
 PRIVATE naRea, naDrec, naDord, cnEar
 PRIVATE lrEt, lsAme, lfOund, leNterkey, clAstname, ccIty, nmEmber,  ;
         naTpos, ciDsearch
 LOCAL nsEppos, clAstname, csHarename
 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 IF LASTKEY()=10
      leNterkey = .t.
 ELSE
      leNterkey = .F.
 ENDIF
 IF EMPTY(pcSearch) .AND.  .NOT. EMPTY(pnId)
      pnId = 0
      RETURN .T.
 ENDIF
 IF EMPTY(pcSearch) .AND. EMPTY(pnId)
      RETURN .T.
 ENDIF
 naRea = SELECT()
*wait window str(_screen.datasessionid)
if !used('address')
	return
endif
 SELECT adDress
 naDrec = RECNO()
 naDord = ORDER()
 lrEt = .F.
 lsAme = .F.
 IF  .NOT. EMPTY(pnId)
      SET ORDER TO 1
      lfOund = SEEK(pnId)
      IF lfOund
           SET ORDER TO 2
      ELSE
           = alErt("Unable to find Guest address ID "+LTRIM(STR(pnId)))
      ENDIF
      ciDsearch = UPPER(TRIM(SUBSTR(ad_lname, 1, 30)))
      IF UPPER(TRIM(SUBSTR(pcSearch, 1, 30)))==ciDsearch
           lrEt = .T.
           lsAme = .T.
      ELSE
      	IF TYPE("m.rs_apid")="U"

		ELSE
	      	= SEEK(m.rs_apid,'apartner','tag3')
	      	IF pnId = pnidcompany AND allTRIM(pcSearch) == UPPER(allTRIM(apartner.ap_lname))
	      		 lsAme = .T.
	      	ENDIF
		ENDIF
      ENDIF
 ENDIF
 IF  .NOT. lsAme
      IF isNumber(pcSearch)
           nmEmber = VAL(pcSearch)
      ELSE
           nmEmber = 0
      ENDIF
      naTpos = AT('@', pcSearch)
      IF naTpos>0
           clAstname = UPPER(TRIM(SUBSTR(pcSearch, 1, naTpos-1)))
           IF naTpos<LEN(pcSearch)
                ccIty = UPPER(TRIM(SUBSTR(pcSearch, naTpos+1)))
           ELSE
                ccIty = ''
           ENDIF
      ELSE
           clAstname = UPPER(TRIM(pcSearch))
           ccIty = ''
      ENDIF
      IF nmEmber>0
           SET ORDER TO 6
           lfOund = SEEK(nmEmber)
      ELSE
           SET ORDER TO 2
           lfOund = SEEK(clAstname)
           IF  .NOT. EMPTY(ccIty)
                LOCATE REST FOR UPPER(ad_city)=ccIty WHILE  ;
                       UPPER(ad_lname)=clAstname
                lfOund = FOUND()
           ENDIF
      ENDIF
 ENDIF
 IF  .NOT. lfOund
      IF MESSAGEBOX(GetLangText('RESERVAT','TA_NAMENOTFOUND'),36,GetLangText("FUNC","TXT_QUESTION")) = 6 &&yeSno(GetLangText('RESERVAT','TA_NAMENOTFOUND'))
		do form "forms\ADDRESSMASK" WITH 'EDITL',MakeProperName(pcsearch),tagno(),PCCALL
        gl_valid=.t.
     ELSE
           cnEar = SET('near')
           SET NEAR ON
           = SEEK(clAstname)
           set near &cNear
           lfOund = .T.
      ENDIF
 ENDIF
 IF (lfOund .AND.  .NOT. lsAme) .OR. (lsAme .AND. leNterkey)
   *   DO brWaddress IN Address WITH TAGNO(), 10, .T., "Address"
     * DO FORM FORMS\ADDRESSMASK WITH "BRWL" , pcsearch,tagno(),pccall
	   DO FORM FORMS\ADDRESSMASK WITH "BRWL" , pcsearch,tagno(),pccall, IIF(leNterkey,RECNO(),0)
 *     DO FORM FORMS\ADDRESSMASK WITH "BRWL" , pcsearch,2,pccall, IIF(leNterkey,RECNO(),0)
      gl_valid=.t.
       IF LASTKEY()<>27
           biRthday()
           pnId = adDress.ad_addrid
           lrEt = .T.
           nsEppos = AT('/', adDress.ad_lname)
           IF nsEppos>0
                pcSearch = UPPER(adDress.ad_lname)
                IF nsEppos<LEN(adDress.ad_lname)
                     pcSharename = UPPER(SUBSTR(adDress.ad_lname, nsEppos+1))
                ELSE
                     pcSharename = ''
                ENDIF
           ELSE
                pcSearch = UPPER(adDress.ad_lname)
                pcSharename = ''
           ENDIF
      ELSE
           IF pnId=0
                pcSearch = ''
           ELSE
                pcSearch = ciDsearch
           ENDIF
      ENDIF
 ENDIF
 if nadrec<=reccount()
 	GOTO naDrec
 else
 	go bott
 endif
 SET ORDER TO nAdOrd
 SELECT (naRea)
 FLUSH
 RETURN .T.
ENDFUNC
*
