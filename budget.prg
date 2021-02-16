 PARAMETER naRticle
 PRIVATE nbUdgetarea
 PRIVATE naRtiorder
 PRIVATE naRtirecord
 PRIVATE pcArticle
 PRIVATE pnArticle
 pnArticle = naRticle
 nbUdgetarea = SELECT()
 SELECT arTicle
 pcArticle = ALLTRIM(EVALUATE("Article.Ar_Lang"+g_Langnum))
 naRtiorder = ORDER()
 naRtirecord = RECNO("Article")
 IF (opEnfile(.F.,"Budget"))
      = buDgetwindow(0)
      = geTbudgetdata()
      = buDgetwindow(1)
 ENDIF
 = clOsefile("Budget")
 SELECT (nbUdgetarea)
 RETURN .T.
ENDFUNC
*
FUNCTION BudgetWindow
 PARAMETER naCtivate
 IF (naCtivate==0)
      DEFINE WINDOW wbUdget AT 0, 0 SIZE 8, 90 FONT "Arial", 10 NOGROW  ;
             NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("BUDGET", ;
             "TXT_CAPBUDGET")+"/"+pcArticle) SYSTEM
      MOVE WINDOW wbUdget CENTER
      ACTIVATE WINDOW wbUdget
 ELSE
      DEACTIVATE WINDOW wbUdget
      RELEASE WINDOW wbUdget
      = chIldtitle("")
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION GetBudgetData
 PRIVATE nbUtton
 PRIVATE cbUttons
 PRIVATE pnBudget
 PRIVATE pdEnddate
 PRIVATE pdStartdate
 PRIVATE plWearedone
 pnBudget = 0
 nbUtton = 1
 cbUttons = "\!"+buTton("",GetLangText("BUDGET","TXT_SAVE"),1)+"\?"+buTton("", ;
            GetLangText("COMMON","TXT_CLOSE"),-2)
 pdEnddate = CTOD("01/01/"+RIGHT(STR(YEAR(DATE())+1, 4), 2))-1
 pdStartdate = CTOD("01/01/"+RIGHT(STR(YEAR(DATE()), 4), 2))
 plWearedone = .F.
 = caLcbudget()
 = paNelborder()
 = txTpanel(2,2,20,GetLangText("BUDGET","TXT_ARTICLE"),17)
 = txTpanel(3.25,2,20,GetLangText("BUDGET","TXT_STARTDATE"),17)
 = txTpanel(4.5,2,20,GetLangText("BUDGET","TXT_ENDDATE"),17)
 = txTpanel(5.75,2,20,GetLangText("BUDGET","TXT_BUDGET"),17)
 @ 2, 22 SAY pcArticle STYLE "B"
 @ 3.250, 22 GET pdStartdate SIZE 1, siZedate() PICTURE "@K"
 @ 4.500, 22 GET pdEnddate SIZE 1, siZedate() PICTURE "@K"
 @ 5.750, 22 GET pnBudget SIZE 1, 15 PICTURE "@K "+RIGHT(gcCurrcy, 12)  ;
   WHEN caLcbudget()
 @ 2, 70 GET nbUtton STYLE "B" SIZE nbUttonheight, 15 FUNCTION "*"+"V"  ;
   PICTURE cbUttons VALID vbUdgetbuttons(nbUtton)
 READ VALID plWearedone CYCLE
 RETURN .T.
ENDFUNC
*
FUNCTION CalcBudget
 PRIVATE ncOunted
 ncOunted = 0
 SELECT buDget
 = SEEK(STR(pnArticle, 4)+DTOS(pdStartdate), "Budget")
 DO WHILE ( .NOT. EOF("Budget") .AND. buDget.bg_article==pnArticle .AND.  ;
    buDget.bg_date>=pdStartdate .AND. buDget.bg_date<=pdEnddate)
      ncOunted = ncOunted+buDget.bg_budget
      SKIP 1 IN buDget
 ENDDO
 pnBudget = ncOunted
 SHOW OBJECT OBJNUM(pnBudget)
 RETURN .T.
ENDFUNC
*
FUNCTION vBudgetButtons
 PARAMETER nsElected
 DO CASE
      CASE nsElected==1
           IF (yeSno(GetLangText("BUDGET","TXT_SAVETHISBUDGETCODE"), ;
              GetLangText("BUDGET","TXT_QUESTION")))
                = saVebudget()
                = alErt(GetLangText("BUDGET","TXT_DATASAVED"))
                _CUROBJ = OBJNUM(pdStartdate)
           ENDIF
      CASE nsElected==2
           plWearedone = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION SaveBudget
 PRIVATE naMount
 PRIVATE ncOunter
 PRIVATE ddAte
 PRIVATE ndAys
 ndAys = pdEnddate-pdStartdate+1
 naMount = ROUND(pnBudget/ndAys, paRam.pa_currdec)
 WAIT WINDOW NOWAIT GetLangText("BUDGET","TXT_SAVEIT")+" "+LTRIM(STR(naMount, 12,  ;
      paRam.pa_currdec))+"/Day"
 SELECT buDget
 FOR ncOunter = 1 TO ndAys
      ddAte = pdStartdate+(ncOunter-1)
      IF (SEEK(STR(pnArticle, 4)+DTOS(ddAte), "Budget"))
           REPLACE buDget.bg_budget WITH naMount
      ELSE
           APPEND BLANK
           REPLACE buDget.bg_article WITH pnArticle
           REPLACE buDget.bg_budget WITH naMount
           REPLACE buDget.bg_date WITH ddAte
      ENDIF
 ENDFOR
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
