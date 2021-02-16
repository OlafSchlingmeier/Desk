*
FUNCTION RoundIt
 PARAMETER pnResid, pnWindow, pnTopayamt, pnAmount, pnRate, pcSupplem, pcAlias
 PRIVATE naRea, nrOundamt, ndIffamt, nrEtamt
 PRIVATE ALL LIKE ps_*
 nrOundamt = ROUND(pnAmount*pnRate, paRam.pa_currdec)
 ndIffamt = RoundForDisplay(pnTopayamt-nrOundamt) && Post rounding only for diffamount >= 0.01
 nrEtamt = 0
 IF ndIffamt <> ROUND(0,paRam.pa_currdec)
      IF EMPTY(paRam.pa_rndpay)
           = alErt(GetLangText("BILL","TXT_ROUND_NOTFOUND"))
      ELSE
           naRea = SELECT()
           SELECT (pcAlias)
           SCATTER BLANK MEMVAR
           M.ps_paynum = paRam.pa_rndpay
           M.ps_amount = -ndIffamt
           M.ps_price = 1.00000
           M.ps_units = ndIffamt
           M.ps_reserid = pnResid
           M.ps_origid = pnResid
           M.ps_window = pnWindow
           M.ps_supplem = pcSupplem
           M.ps_date = sySdate()
           M.ps_time = TIME()
           M.ps_userid = cuSerid
           M.ps_cashier = g_Cashier
           M.ps_postid = neXtid('Post')
           INSERT INTO (pcAlias) FROM MEMVAR
           FLUSH
           SELECT (naRea)
           nrEtamt = -ndIffamt
      ENDIF
 ENDIF
 RETURN nrEtamt
ENDFUNC
*
