*
PROCEDURE MgrTitle
	do form "Forms\MngForm" with "MngTitleCtrl"
	return
 PRIVATE cbUttons
 PRIVATE clEvel
 PRIVATE ALL LIKE l_*
 PRIVATE a_Field
 DIMENSION a_Field[4, 4]
 STORE '' TO a_Field
 a_Field[1, 1] = "Title.ti_lang"
 a_Field[1, 2] = 10
 a_Field[1, 3] = GetLangText("MGRGUEST","TXT_TILANG")
 a_Field[2, 1] = "ti_titlcod"
 a_Field[2, 2] = 6
 a_Field[2, 3] = GetLangText("MGRGUEST","TXT_TICODE")
 a_Field[2, 4] = '9 '
 a_Field[3, 1] = "ti_title"
 a_Field[3, 2] = 25
 a_Field[3, 3] = GetLangText("MGRGUEST","TXT_TITITLE")
 a_Field[4, 1] = "Trim(ti_salute)"
 a_Field[4, 2] = 30
 a_Field[4, 3] = GetLangText("MGRGUEST","TXT_TISALUTE")
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_DELETE"),-4)
 l_Oldarea = SELECT()
 SELECT tiTle
 l_Oldrec = RECNO("title")
 GOTO TOP
 cmGebutton = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("MGRGUEST","TXT_TIBROWSE"),15,@a_Field,".t.",".t.", ;
   cbUttons,"vControl","mgrguest")
 gcButtonfunction = cmGebutton
 GOTO l_Oldrec IN "title"
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
PROCEDURE vControl
 PARAMETER p_Option
 DO CASE
      CASE p_Option==1
      CASE p_Option==2
           DO scRtitle WITH "EDIT"
           g_Refreshcurr = .T.
      CASE p_Option==3
           DO scRtitle WITH "NEW"
           g_Refreshall = .T.
      CASE p_Option==4
           IF (yeSno(GetLangText("MGRGUEST","TXT_TIDELETE")+";"+ ;
              ALLTRIM(tiTle.ti_title)))
                DELETE
           ENDIF
 ENDCASE
 RETURN
ENDPROC
*
PROCEDURE ScrTitle
 PARAMETER p_Option
 PRIVATE ALL LIKE l_*
 l_Choice = 1
 DO CASE
      CASE p_Option="EDIT"
           SCATTER MEMVAR
      CASE p_Option="NEW"
           SCATTER BLANK MEMVAR
 ENDCASE
 DEFINE WINDOW wtItle AT 0.000, 0.000 SIZE 10.500, 60.000 FONT "Arial",  ;
        10 NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("MGRGUEST", ;
        "TXT_TIWINDOW")) NOMDI DOUBLE
 MOVE WINDOW wtItle CENTER
 ACTIVATE WINDOW wtItle
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 DO paNel WITH 1/4, 2/3, 7.50, WCOLS()-(0.666666666666667)
 DO paNel WITH 15/16, 8/3, 33/16, 70/3, 2
 DO paNel WITH 35/16, 8/3, 53/16, 70/3, 2
 DO paNel WITH 55/16, 8/3, 73/16, 70/3, 2
 DO paNel WITH 75/16, 8/3, 93/16, 70/3, 2
 DO paNel WITH 95/16, 8/3, 113/16, 70/3, 2
 @ 1.000, 4.000 SAY GetLangText("MGRGUEST","TXT_TILANG")
 @ 2.250, 4.000 SAY GetLangText("MGRGUEST","TXT_TICODE")
 @ 3.500, 4.000 SAY GetLangText("MGRGUEST","TXT_TITITLE")
 @ 4.750, 4.000 SAY GetLangText("MGRGUEST","TXT_TISALUTE")
 @ 6.000, 4.000 SAY GetLangText("MGRGUEST","TXT_TIATTN")
 @ 1.000, 25.000 GET M.ti_lang SIZE 1, 30 PICTURE "@K !!!" VALID  ;
   piCklist("LANGUAGE",@M.ti_lang,1.25,25.00,"C","wTitle")
 @ 2.250, 25.000 GET M.ti_titlcod SIZE 1, 30 PICTURE "@KB 99"
 @ 3.500, 25.000 GET M.ti_title SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)
 @ 4.750, 25.000 GET M.ti_salute SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 50)
 @ 6.000, 25.000 GET M.ti_attn SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 10)
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice STYLE "B" SIZE nbUttonheight, 15 PICTURE  ;
   "@*TH "+cbUttons VALID vcHoice(p_Option)
 READ CYCLE MODAL
 RELEASE WINDOW wtItle
 = chIldtitle("")
 RETURN
ENDPROC
*
FUNCTION vChoice
 PARAMETER p_Option
 PRIVATE l_Retval
 l_Retval = .F.
 DO CASE
      CASE M.l_Choice==1
           l_Retval = .T.
           DO CASE
                CASE (p_Option="NEW")
                     INSERT INTO title FROM MEMVAR
                CASE (p_Option="EDIT")
                     GATHER MEMVAR
           ENDCASE
           CLEAR READ
      CASE M.l_Choice==2
           l_Retval = .T.
           CLEAR READ
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
