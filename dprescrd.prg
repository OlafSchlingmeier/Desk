 PARAMETER pnReserid
 PRIVATE naRea, ndPrec, nrEt, coLdtalk
 naRea = SELECT()
 IF  .NOT. USED('Deposit')
      OpenFileDirect(.F.,"deposit")
 ENDIF
 SELECT dePosit
 ndPrec = RECNO()
 coLdtalk = SET('talk')
 SET TALK OFF
 SUM dp_credit TO nrEt FOR dp_reserid=pnReserid .AND. dp_posted={}
 set talk &cOldTalk
 GOTO ndPrec
 SELECT (naRea)
 RETURN nrEt
ENDFUNC
*
