 PARAMETER p_Text, p_Header, csTring
 PRIVATE ALL LIKE l_*
 PRIVATE npArams
 PRIVATE ndEfbutton
 l_Return = 0
 npArams = PCOUNT()
 IF (npArams==1)
      p_Header = GetLangText("FUNC","TXT_QUESTION")
 ENDIF
 IF (npArams==3)
      p_Text = STRTRAN(p_Text, "%s", csTring)
      p_Text = STRTRAN(p_Text, "%S", csTring)
 ENDIF
 DO CASE
      CASE AT("@3", p_Text)>0
           ndEfbutton = 512
           p_Text = STRTRAN(p_Text, "@3", "")
      CASE AT("@2", p_Text)>0
           ndEfbutton = 256
           p_Text = STRTRAN(p_Text, "@2", "")
      OTHERWISE
           ndEfbutton = 0
 ENDCASE
 p_Text = STRTRAN(p_Text, ";", CHR(13)+CHR(10))
 l_Return = msGbox(p_Text,p_Header,052+ndEfbutton)
 RETURN (l_Return==6)
ENDFUNC
*
