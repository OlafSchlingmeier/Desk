*
FUNCTION DepSpec
 LOCAL lrEt, liTems, nrEsid, c1, clAngcol, naRea, cmSg
 lrEt = .T.
 IF dlOokup('Article','ar_return = .T.','ar_artinum')>0
      nrEsid = reServat.rs_reserid
      naRea = SELECT()
      c1 = SYS(2015)
      clAngcol = 'ar_lang'+g_Langnum
      SELECT &cLangCol AS descr, SUM(ps_units) AS qty  FROM Post, Article  WHERE ps_reserid = nResId  AND ps_artinum = ar_artinum  AND !ps_split  AND !ps_cancel  AND ar_return  GROUP BY ar_artinum  INTO CURSOR (c1)
      IF _TALLY>0
           cmSg = GetLangText("DEPSPEC","TXT_RETURN_ARTICLES")+';;'
           liTems = .F.
           SCAN ALL FOR qtY<>0
                liTems = .T.
                cmSg = cmSg+LTRIM(STR(qtY))+' x '+TRIM(deScr)+';'
           ENDSCAN
           IF liTems
                lrEt = yeSno(cmSg+'@2',TRIM(reServat.rs_rmname)+' '+ ;
                       TRIM(reServat.rs_lname))
                IF lrEt
                     reFunddepspec()
                ENDIF
           ELSE
                lrEt = .T.
           ENDIF
      ENDIF
      dcLose(c1)
      SELECT (naRea)
 ENDIF
 RETURN lrEt
ENDFUNC
*
PROCEDURE RefundDepSpec
 LOCAL nrEfart, nrEsid, naRea
 nrEfart = paRam.pa_depspec
 IF nrEfart<>0
      nrEsid = reServat.rs_reserid
      naRea = SELECT()
      c1 = SYS(2015)
      SELECT ps_window, SUM(ps_amount) AS amT FROM Post WHERE ps_reserid= ;
             nrEsid AND ps_artinum=nrEfart AND  NOT ps_cancel AND  NOT  ;
             ps_split GROUP BY ps_window INTO CURSOR (c1)
      IF _TALLY>0
           SCAN ALL FOR amT<>0
                poStart(nrEsid,ps_window,nrEfart,-1,amT,'',GetLangText("DEPSPEC", ;
                       "TXT_REFUNDED"))
           ENDSCAN
      ENDIF
      dcLose(c1)
      SELECT (naRea)
 ENDIF
ENDPROC
*
