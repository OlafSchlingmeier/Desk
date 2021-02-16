 PARAMETER pcSearch, pnId, pcCall&&, pnapid, pcapname
 PRIVATE naRea, naDrec, naDord, cnEar
 PRIVATE lrEt, lsAme, lfOund, leNterkey, clAstname, ccOmpany, cnUmber,  ;
         naTpos, ciDsearch
 Local nnUmber

 IF LASTKEY()=27
      RETURN .T.
 ENDIF
 IF LASTKEY()=10
      leNterkey = .t.
 	  nnUmber = 0
      ccOmpany = UPPER(TRIM(pcSearch))
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
           SET ORDER TO 3
      ELSE
           = alErt("Unable to find Company address ID "+LTRIM(STR(pnId)))
      ENDIF
      ciDsearch = UPPER(TRIM(SUBSTR(ad_company, 1, 30)))
      IF UPPER(TRIM(SUBSTR(pcSearch, 1, 30)))==ciDsearch
           lrEt = .T.
           lsAme = .T.
      ENDIF
 ENDIF
 IF  .NOT. lsAme
      IF isNumber(pcSearch)
           nnUmber = VAL(pcSearch)
      ELSE
           nnUmber = 0
      ENDIF
      naTpos = AT('@', pcSearch)
      IF naTpos>0
           clAstname = UPPER(TRIM(SUBSTR(pcSearch, 1, naTpos-1)))
           IF naTpos<LEN(pcSearch)
                ccOmpany = UPPER(TRIM(SUBSTR(pcSearch, naTpos+1)))
           ELSE
                ccOmpany = ''
           ENDIF
      ELSE
           ccOmpany = UPPER(TRIM(pcSearch))
           clAstname = ''
      ENDIF
      IF nnUmber>0
           SET ORDER TO 5
           lfOund = SEEK(nnUmber)
      ELSE
           SET ORDER TO 18
           lfOund = SEEK(PADR(ccOmpany, 15))
           IF  .NOT. lfOund
                SET ORDER TO 3
                lfOund = SEEK(ccOmpany)
                IF  .NOT. EMPTY(clAstname)
                     LOCATE REST FOR UPPER(ad_lname)=clAstname WHILE  ;
                            UPPER(ad_company)=ccOmpany
                     lfOund = FOUND()
                ENDIF
           ELSE
           		DO WHILE EMPTY(ad_company) AND !EOF()
           			SKIP 1
           		ENDDO
           		leNterkey = .t.
           ENDIF
      ENDIF
 ENDIF
 IF  .NOT. lfOund
      IF MESSAGEBOX(GetLangText('RESERVAT','TA_COMPNOTFOUND'),36,GetLangText("FUNC","TXT_QUESTION")) = 6&&yeSno(GetLangText('RESERVAT','TA_COMPNOTFOUND'))
            IF EMPTY(PCCALL)
           		do form "forms\ADDRESSMASK" WITH 'EDITC',PROPER(pcsearch),tagno(),pccall
           	ELSE
           		do form "forms\ADDRESSMASK" WITH 'EDITC',PROPER(pcsearch),tagno(),PCCALL
           	ENDIF
           gl_valid=.t.
      ELSE
           cnEar = SET('near')
           SET NEAR ON
           = SEEK(ccOmpany)
           set near &cNear
           lfOund = .T.
      ENDIF
 ENDIF
 IF (lfOund .AND.  .NOT. lsAme) .OR. (lsAme .AND. leNterkey)
	  *	DO FORM FORMS\ADDRESSMASK WITH "BRWC" , pcsearch,tagno(),pcCall
		IF nnumber>0
			DO FORM FORMS\ADDRESSMASK WITH "BRWC" , nnumber, 5 , pcCall, 0
		ELSE
			DO FORM FORMS\ADDRESSMASK WITH "BRWC" , PADR(ccOmpany, 15), tagno() , pcCall,IIF(leNterkey,RECNO(),0)
		ENDIF
		
    	gl_valid=.t.
     * DO brWaddress IN Address WITH TAGNO(), 10, .T., "Address"
      IF LASTKEY()<>27
           pnId = adDress.ad_addrid
           lrEt = .T.
           pcSearch = UPPER(TRIM(SUBSTR(ad_company, 1, 30)))
      ELSE
           IF pnId=0
                pcSearch = ''
           ELSE
                pcSearch = ciDsearch
           ENDIF
      ENDIF
 ENDIF
 IF NADREC>RECCOUNT()
 	GO BOTT
 ELSE
 	GOTO naDrec
 ENDIF
 SET ORDER TO nAdOrd
 SELECT (naRea)
 FLUSH
 RETURN .T.
ENDFUNC
*
