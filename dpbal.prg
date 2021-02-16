 PARAMETER pnHeaderid, pnLineid
 PRIVATE naRea, ndPrec, nrEt, coLdtalk
 naRea = SELECT()
 IF  .NOT. USED('Deposit')
      OpenFileDirect(.F.,"deposit")
 ENDIF
 SELECT dePosit
 ndPrec = RECNO()
 coLdtalk = SET('talk')
 SET TALK OFF
 IF pnHeaderid=0
      SUM dp_debit-dp_credit TO nrEt FOR dp_lineid=pnLineid
 ELSE
      SUM dp_debit-dp_credit TO nrEt FOR dp_headid=pnHeaderid
 ENDIF
 set talk &cOldTalk
 GOTO ndPrec
 SELECT (naRea)
 RETURN nrEt
ENDFUNC
*
