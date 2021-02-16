*Programm: particle.prg
*varticle.prg
FUNCTION pArticle
 PARAMETER p_Row, p_Col, p_Windowname
 PRIVATE lvAlid, cfOr
 PRIVATE l_Oldarea
 PRIVATE a_Field
 DIMENSION a_Field[3, 3]
 STORE '' TO a_Field
 a_Field[1, 1] = "Ar_ArtiNum"
 a_Field[1, 2] = 5
 a_Field[2, 1] = "Ar_Lang"+g_Langnum
 a_Field[2, 2] = 20
 a_Field[3, 1] = "Transform(Ar_Price, Right(gcCurrcyDisp, 11))"
 a_Field[3, 2] = 13
 a_Field[3, 3] = '@J'
 l_Oldarea = SELECT()
 lvAlid = .F.
 IF (LASTKEY()==27)
      lvAlid = .T.
 ELSE
      IF UPPER(p_Windowname)='WPOSTPASS'
           cfOr = 'AR_ARTITYP <> 2'
      ELSE
           cfOr = '.T.'
      ENDIF
      cfOr = cfOr + ' .and. !ar_inactiv'
      SELECT arTicle
      If ( Empty(m.ps_artinum) .or. !Seek(m.ps_artinum) .or. !&cFor .or. ar_inactiv)
           GOTO TOP IN arTicle
           IF (myPopup(p_Windowname,p_Row+1,p_Col,5,@a_Field,cfOr,".t.")>0)
                M.ps_artinum = arTicle.ar_artinum
                M.ps_price = arTicle.ar_price
                M.l_Lang = EVALUATE("Ar_Lang"+g_Langnum)
                M.l_Artitype = arTicle.ar_artityp
                SHOW OBJECT 4
                SHOW OBJECT 5
                lvAlid = .T.
           ENDIF
      ELSE
           M.ps_price = arTicle.ar_price
           M.l_Lang = EVALUATE("Ar_Lang"+g_Langnum)
           M.l_Artitype = ar_artityp
           SHOW OBJECT 4
           SHOW OBJECT 5
           lvAlid = .T.
      ENDIF
      IF (lvAlid)
           SELECT piCklist
           SET ORDER TO 3
           = SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat, 3))
           l_Vatnum = arTicle.ar_vat
           l_Vatpct = piCklist.pl_numval
           = SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat2, 3))
           l_Vatnum2 = arTicle.ar_vat2
           l_Vatpct2 = piCklist.pl_numval
           l_VatTyp2 = picklist.pl_user2
           SET ORDER TO 1
		   IF article.ar_stckctl
			   DO CASE
				 CASE article.ar_stckcur < m.ps_units
					= alert(GetLangText("BILL","TXT_ARTI_STOCK_NO")+ ;
						CHR(13)+ALLTRIM(STR(article.ar_stckcur)), ;
						GetLangText("CHKOUT2","TW_POST"))
					l_lRetVal = .F.
				 CASE article.ar_stckmin >= article.ar_stckcur-m.ps_units
					= alert(GetLangText("BILL","TXT_ARTI_STOCK_MIN"), ;
						GetLangText("CHKOUT2","TW_POST"))
			   ENDCASE
		   ENDIF
      ENDIF
      SELECT (l_Oldarea)
 ENDIF
 RETURN lvAlid
ENDFUNC

Procedure sarticle
PRIVATE L_oldarea
	l_oldarea=SELECT()
	SELECT article
	IF SEEK(m.ps_artinum)
		SELECT picklist
		SET ORDER TO 3
		=SEEK(PADR("VATGROUP",10)+STR(article.ar_vat,3))
		l_vatnum=article.ar_vat
		l_vatpct=picklist.pl_numval
		=SEEK(PADR("VATGROUP",10)+STR(article.ar_vat2,3))
		l_vatnum2=article.ar_vat2
		l_vatpct2=picklist.pl_numval
		SET ORDER TO 1
	ENDIF
	SeLECT (l_oldarea)
	Return.t.
EndProc

*
