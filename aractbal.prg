 PARAMETER pnAcct, plIncldisp
 PRIVATE naRea, nrEt, nrEc, coLdtalk
 naRea = SELECT()
 nrEt = 0
 IF  .NOT. USED('ArPost')
      OpenFileDirect(.F.,"arpost")
 ENDIF
 SELECT arPost
 nrEc = RECNO()
 coLdtalk = SET('talk')
 SET TALK OFF
 IF plIncldisp
      SUM ap_debit-ap_credit TO nrEt FOR ap_aracct=pnAcct AND NOT ap_hiden
 ELSE
      SUM ap_debit-ap_credit TO nrEt FOR ap_aracct=pnAcct .AND.  .NOT.  ;
          ArAccount("ArIsDisputed", ap_dispute, ap_disdate) AND NOT ap_hiden
 ENDIF
 set talk &cOldTalk
 IF RECCOUNT() > 0
 	GOTO nrEc
 endif
 SELECT (naRea)
 RETURN nrEt
ENDFUNC
*
