 PARAMETER ctExt, nsCroll
 PUBLIC ccUrrenttext
 DO CASE
      CASE nsCroll==3
           SCROLL 10, 1, WROWS()-2, WCOLS()-3, 1
      CASE nsCroll==1
           SCROLL 1, 1, WROWS()-2, WCOLS()-3, 1
      CASE nsCroll==0
           SCROLL WROWS()-2, 1, WROWS()-2, WCOLS()-3, 0
      CASE nsCroll==2
           ctExt = ccUrrenttext+" "+ALLTRIM(ctExt)
 ENDCASE
 @ WROWS()-2, 3 SAY ctExt
 ccUrrenttext = ctExt
 RETURN .T.
ENDFUNC
*
