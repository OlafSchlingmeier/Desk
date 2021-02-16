 PARAMETER pnHeaderid, pnLineid, plIncldisp, pcAlias
 PRIVATE naRea, naPrec, nrEt, coLdtalk
 naRea = SELECT()
 IF (EMPTY(pcAlias) OR pcAlias = "arpost") AND .NOT. USED('ArPost')
      OpenFileDirect(.F.,"arpost")
 ENDIF
 IF EMPTY(pcAlias)
 	pcAlias = "arpost"
 ENDIF
 SELECT &pcAlias
 naPrec = RECNO()
 coLdtalk = SET('talk')
 SET TALK OFF
 IF pnHeaderid=0
      IF plIncldisp
           SUM ap_debit-ap_credit TO nrEt FOR ap_lineid=pnLineid
      ELSE
           SUM ap_debit-ap_credit TO nrEt FOR ap_lineid=pnLineid .AND.   ;
               .NOT. ArAccount("ArIsDisputed", ap_dispute, ap_disdate)
      ENDIF
 ELSE
      IF plIncldisp
           SUM ap_debit-ap_credit TO nrEt FOR ap_headid=pnHeaderid
      ELSE
           SUM ap_debit-ap_credit TO nrEt FOR ap_headid=pnHeaderid .AND.   ;
               .NOT. ArAccount("ArIsDisputed", ap_dispute, ap_disdate)
      ENDIF
 ENDIF
 set talk &cOldTalk
 GOTO naPrec
 SELECT (naRea)
 RETURN nrEt
ENDFUNC
*
