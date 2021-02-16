*
FUNCTION Num2RGB
 LPARAMETERS pnColor
 LOCAL chEx, nfActor, npOs, neXp, noRd
 LOCAL npIck, crGb, ncOl, chUe, nmSb, nlSb
 chEx = ''
 nfActor = 24
 FOR npOs = 6 TO 1 STEP -1
      nfActor = nfActor-4
      neXp = 2^nfActor
      FOR noRd = 15 TO 1 STEP -1
           IF pnColor<neXp
                chEx = chEx+"0"
                EXIT
           ENDIF
           IF pnColor>=neXp*noRd
                chEx = chEx+SUBSTR('123456789ABCDEF', noRd, 1)
                EXIT
           ENDIF
      ENDFOR
      pnColor = MOD(pnColor, neXp)
 ENDFOR
 chEx = RIGHT(chEx, 2)+SUBSTR(chEx, 3, 2)+LEFT(chEx, 2)
 npIck = 2
 crGb = ''
 FOR ncOl = 1 TO 3
      chUe = SUBSTR(chEx, (npIck*ncOl)-1, 2)
      nmSb = ASC(LEFT(chUe, 1))
      nlSb = ASC(RIGHT(chUe, 1))
      nmSb = nmSb-IIF(nmSb>57, 55, 48)
      nlSb = nlSb-IIF(nlSb>57, 55, 48)
      crGb = crGb+TRANSFORM(nmSb*16+nlSb, '@L 999')+','
 ENDFOR
 crGb = LEFT(crGb, LEN(crGb)-1)
 RETURN crGb
ENDFUNC
*
