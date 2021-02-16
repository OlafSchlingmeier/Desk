*
FUNCTION SplitPst
 PRIVATE clEvel
 PRIVATE nsElectedbutton
 PRIVATE cbUttons
 PRIVATE l_Oldarea, l_Split, l_Amount, l_Vat1, l_Vat2, l_Vat3
 nsElectedbutton = 1
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),-2)
 l_Split = 0
 DEFINE WINDOW wsPlitpost AT 0, 0 SIZE 6, 80 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("CHKOUT2","TW_SPLIT")) NOMDI DOUBLE
 MOVE WINDOW wsPlitpost CENTER
 ACTIVATE WINDOW wsPlitpost
 = paNelborder()
 = paNel((0.9375),(2.66666666666667),(2.0625),(23.3333333333333),2)
 @ 1, 4 SAY GetLangText("CHKOUT2","T_SPLIT")
 @ 1, 25 GET l_Split SIZE 1, 15 PICTURE "@KB "+RIGHT(gcCurrcy, 10)
 @ 1, 60 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"V" PICTURE cbUttons
 READ CYCLE MODAL
 IF (nsElectedbutton==1)
      l_Oldarea = SELECT()
      SELECT poSt
      IF (poSt.ps_artinum>0 .AND. l_Split>0 .AND. l_Split<poSt.ps_amount)  ;
         .OR. (poSt.ps_paynum>0 .AND. l_Split<0 .AND. l_Split>poSt.ps_amount)
           SCATTER MEMVAR
           l_Amount = M.ps_amount
           l_Vat0 = M.ps_vat0
           l_Vat1 = M.ps_vat1
           l_Vat2 = M.ps_vat2
           l_Vat3 = M.ps_vat3
           l_Vat4 = M.ps_vat4
           l_Vat5 = M.ps_vat5
           l_Vat6 = M.ps_vat6
           l_Vat7 = M.ps_vat7
           l_Vat8 = M.ps_vat8
           l_Vat9 = M.ps_vat9
           M.ps_amount = M.ps_amount-l_Split
           IF (poSt.ps_artinum>0 .AND. l_Split>0 .AND. l_Split<l_Amount)
               M.ps_units = 1
               M.ps_price = M.ps_amount
           ELSE
               M.ps_units = -M.ps_amount
               M.ps_price = 1
           ENDIF
           M.ps_vat0 = M.ps_vat0*(l_Amount-l_Split)/l_Amount
           M.ps_vat1 = M.ps_vat1*(l_Amount-l_Split)/l_Amount
           M.ps_vat2 = M.ps_vat2*(l_Amount-l_Split)/l_Amount
           M.ps_vat3 = M.ps_vat3*(l_Amount-l_Split)/l_Amount
           M.ps_vat4 = M.ps_vat4*(l_Amount-l_Split)/l_Amount
           M.ps_vat5 = M.ps_vat5*(l_Amount-l_Split)/l_Amount
           M.ps_vat6 = M.ps_vat6*(l_Amount-l_Split)/l_Amount
           M.ps_vat7 = M.ps_vat7*(l_Amount-l_Split)/l_Amount
           M.ps_vat8 = M.ps_vat8*(l_Amount-l_Split)/l_Amount
           M.ps_vat9 = M.ps_vat9*(l_Amount-l_Split)/l_Amount
           M.ps_touched = .T.
           GATHER MEMVAR
           *FLUSH
           M.ps_amount = l_Split
           IF (poSt.ps_artinum>0 .AND. l_Split>0 .AND. l_Split<l_Amount)
               M.ps_units = 1
               M.ps_price = M.ps_amount
           ELSE
               M.ps_units = -M.ps_amount
               M.ps_price = 1
           ENDIF
           M.ps_vat0 = l_Vat0*l_Split/l_Amount
           M.ps_vat1 = l_Vat1*l_Split/l_Amount
           M.ps_vat2 = l_Vat2*l_Split/l_Amount
           M.ps_vat3 = l_Vat3*l_Split/l_Amount
           M.ps_vat4 = l_Vat4*l_Split/l_Amount
           M.ps_vat5 = l_Vat5*l_Split/l_Amount
           M.ps_vat6 = l_Vat6*l_Split/l_Amount
           M.ps_vat7 = l_Vat7*l_Split/l_Amount
           M.ps_vat8 = l_Vat8*l_Split/l_Amount
           M.ps_vat9 = l_Vat9*l_Split/l_Amount
           M.ps_touched = .T.
           M.ps_setid = 0
           M.ps_postid = neXtid('Post')
           INSERT INTO Post FROM MEMVAR
           FLUSH
      ENDIF
      SELECT (l_Oldarea)
 ENDIF
 RELEASE WINDOW wsPlitpost
 = chIldtitle("")
 RETURN .T.
ENDFUNC
*
