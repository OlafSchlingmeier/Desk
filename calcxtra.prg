*
FUNCTION CalcXtra
 PARAMETER pcRatecode, pcRoomtype, pdFrom, pcSeason, daRrival, ddEparture,  ;
           pnAdults, pnChildren, pnChildren2, pnChildren3, pnRate
 PRIVATE nrEt, ckEy, naRea, nrAord, nrArec, ntImes, naMt
 nrEt = 0
 naRea = SELECT()
 SELECT raTearti
 nrArec = RECNO()
 nrAord = ORDER()
 SET ORDER TO 1
 ckEy = pcRatecode+pcRoomtype+DTOS(pdFrom)+pcSeason
 IF SEEK(ckEy)
      SCAN REST FOR ra_artityp=3 WHILE ra_ratecod=ckEy
           IF ra_onlyon=0
                ntImes = MAX(ddEparture-daRrival, 1)
           ELSE
                ntImes = 1
           ENDIF
           IF EMPTY(ra_amnt) .AND.  .NOT. EMPTY(ra_ratepct)
                naMt = ROUND(pnRate*ra_ratepct/100, paRam.pa_currdec)
           ELSE
                naMt = ra_amnt
           ENDIF
           DO CASE
                CASE ra_multipl=1
                     nrEt = nrEt+(naMt*pnAdults)*ntImes
                CASE ra_multipl=2
                     nrEt = nrEt+(naMt*(pnAdults+pnChildren))*ntImes
                CASE ra_multipl=3
                     nrEt = nrEt+(naMt*pnChildren)*ntImes
                CASE ra_multipl=4
                     nrEt = nrEt+(naMt*1)*ntImes
                CASE ra_multipl=5
                     nrEt = nrEt+(naMt*pnChildren2)*ntImes
                CASE ra_multipl=6
                     nrEt = nrEt+(naMt*pnChildren3)*ntImes
           ENDCASE
      ENDSCAN
 ENDIF
 GOTO nrArec
 SET ORDER TO nRaOrd
 SELECT (naRea)
 RETURN nrEt
ENDFUNC
*
