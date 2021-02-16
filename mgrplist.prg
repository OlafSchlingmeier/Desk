*
PROCEDURE MgrStatus
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 3]
 DIMENSION a_Say[2, 3]
 l_Label = "RESSTATUS"
 l_Browsetext = GetLangText("MGRPLIST","TXT_RSBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_RSWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_RSNUM")
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_RSLANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_RSNUM")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_RSLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4,  ;
    "RsNotAll"
 RETURN
ENDPROC
*
FUNCTION RsNotAll
 IF (piCklist.pl_numcod<=5)
      SHOW OBJECT 2 DISABLE
      SHOW OBJECT 3 DISABLE
      SHOW OBJECT 4 DISABLE
 ELSE
      SHOW OBJECT 2 ENABLE
      SHOW OBJECT 3 ENABLE
      SHOW OBJECT 4 ENABLE
 ENDIF
 RETURN .T.
ENDFUNC
*
PROCEDURE MgrSource
	do Form "forms\MngForm" with "MngSourcesCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 3]
 DIMENSION a_Say[2, 3]
 l_Label = "SOURCE"
 l_Browsetext = GetLangText("MGRPLIST","TXT_SCBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_SCWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_SCCODE")
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_SCLANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_SCCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_SCLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrMarket
	do Form "forms\MngForm" with "MngMarkCCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 3]
 DIMENSION a_Say[2, 3]
 l_Label = "MARKET"
 l_Browsetext = GetLangText("MGRPLIST","TXT_MCBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_MCWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_MCCODE")
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_MCLANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_MCCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_MCLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrCountry
	do Form "forms\MngForm" with "MngCountryCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[3, 4]
 STORE '' TO a_Brow
 DIMENSION a_Say[3, 3]
 l_Label = "COUNTRY"
 l_Browsetext = GetLangText("MGRPLIST","TXT_CCBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_CCWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 10
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_CCCODE")
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_CCLANG")
 a_Brow[3, 1] = "pl_numcod"
 a_Brow[3, 2] = 20
 a_Brow[3, 3] = GetLangText("MGRPLIST","TXT_CCNUM")
 a_Brow[3, 4] = '999 '
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_CCCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_CCLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 a_Say[3, 1] = GetLangText("MGRPLIST","TXT_CCNUM")
 a_Say[3, 2] = "m.pl_numcod"
 a_Say[3, 3] = "B 999"
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrLanguage
	do Form "forms\MngForm" with "MngLangCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[3, 4]
 STORE '' TO a_Brow
 DIMENSION a_Say[3, 3]
 l_Label = "LANGUAGE"
 l_Browsetext = GetLangText("MGRPLIST","TXT_LABROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_LAWINDOW")
 a_Brow[1, 1] = "PickList.pl_numcod"
 a_Brow[1, 2] = 10
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_LANUM")
 a_Brow[1, 4] = '9 '
 a_Brow[2, 1] = "pl_charcod"
 a_Brow[2, 2] = 10
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_LACODE")
 a_Brow[3, 1] = "pl_lang"+g_Langnum
 a_Brow[3, 2] = 40
 a_Brow[3, 3] = GetLangText("MGRPLIST","TXT_LALANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_LANUM")
 a_Say[1, 2] = "m.pl_numcod"
 a_Say[1, 3] = "B 9"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_LACODE")
 a_Say[2, 2] = "m.pl_charcod"
 a_Say[2, 3] = " !!!"
 a_Say[3, 1] = GetLangText("MGRPLIST","TXT_LALANG")
 a_Say[3, 2] = "m.pl_lang"+g_Langnum
 a_Say[3, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 3
 RETURN
ENDPROC
*
PROCEDURE MgrMailing
	do Form "forms\MngForm" with "MngMailCCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 3]
 DIMENSION a_Say[2, 3]
 l_Label = "MAILING"
 l_Browsetext = GetLangText("MGRPLIST","TXT_MABROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_MAWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_MACODE")
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_MALANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_MACODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_MALANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrMainGroup
	do Form "forms\MngForm" with "MngMainGrCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 4]
 STORE '' TO a_Brow
 DIMENSION a_Say[2, 3]
 l_Label = "MAINGROUP"
 l_Browsetext = GetLangText("MGRPLIST","TXT_MGBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_MGWINDOW")
 a_Brow[1, 1] = "PickList.pl_numcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_MGNUM")
 a_Brow[1, 4] = '9 '
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_MGLANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_MGNUM")
 a_Say[1, 2] = "m.pl_numcod"
 a_Say[1, 3] = "B 9"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_MGLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 3
 RETURN
ENDPROC
*
PROCEDURE MngManGrpCtrl
     do Form "forms\MngForm" with "MngManGrpCtrl"
     return
ENDPROC
*
PROCEDURE MgrSubGroup
	do Form "forms\MngForm" with "MngSubGrCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 4]
 STORE '' TO a_Brow
 DIMENSION a_Say[2, 3]
 l_Label = "SUBGROUP"
 l_Browsetext = GetLangText("MGRPLIST","TXT_SGBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_SGWINDOW")
 a_Brow[1, 1] = "PickList.pl_numcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_SGNUM")
 a_Brow[1, 4] = '99 '
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_SGLANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_SGNUM")
 a_Say[1, 2] = "m.pl_numcod"
 a_Say[1, 3] = "B 99"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_SGLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 3
 RETURN
ENDPROC
*
PROCEDURE MgrVatGroup

 do form "forms\MngForm" with "MngVatGrCtrl"
 return

 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[3, 4]
 STORE '' TO a_Brow
 DIMENSION a_Say[4, 3]
 l_Label = "VATGROUP"
 l_Browsetext = GetLangText("MGRPLIST","TXT_VGBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_VGWINDOW")
 a_Brow[1, 1] = "PickList.pl_numcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_VGNUM")
 a_Brow[1, 4] = '9 '
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_VGLANG")
 a_Brow[3, 1] = "pl_numval"
 a_Brow[3, 2] = 12
 a_Brow[3, 3] = GetLangText("MGRPLIST","TXT_VGPERC")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_VGNUM")
 a_Say[1, 2] = "m.pl_numcod"
 a_Say[1, 3] = "B 9"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_VGLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 a_Say[3, 1] = GetLangText("MGRPLIST","TXT_VGPERC")
 a_Say[3, 2] = "m.pl_numval"
 a_Say[3, 3] = "B 99.99"
 a_Say[4, 1] = GetLangText("MGRPLIST","TXT_ACCOUNT")
 a_Say[4, 2] = "m.Pl_User2"
 a_Say[4, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 3
 RETURN
ENDPROC
*
PROCEDURE MgrDepartment
	do Form "forms\MngForm" with "MngDepartCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 3]
 DIMENSION a_Say[2, 3]
 l_Label = "DEPARTMENT"
 l_Browsetext = GetLangText("MGRPLIST","TXT_DEBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_DEWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_DENUM")
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_DELANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_DENUM")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_DELANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrBatch
	do Form "forms\MngForm" with "MngBatchCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 3]
 DIMENSION a_Say[2, 3]
 l_Label = "BATCH"
 l_Browsetext = "Batches"
 l_Wintext = "Batch"
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = "Code"
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = "Description"
 a_Say[1, 1] = "Batch Code"
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = "Description"
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE PickList
 PARAMETER q_Label, p_Browsetext, p_Wintext, p_Browse, p_Say, p_Order,  ;
           cbUtfunction
 PRIVATE cbUttons
 PRIVATE clEvel
 PRIVATE npArameters
 PRIVATE ALL LIKE l_*
 EXTERNAL ARRAY p_Browse, p_Say
 npArameters = PARAMETERS()
 IF (npArameters<7)
      cbUtfunction = ""
 ENDIF
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_DELETE"),-4)
 l_Oldarea = SELECT()
 SELECT piCklist
 l_Oldrec = RECNO("picklist")
 l_Oldord = ORDER("picklist")
 SET ORDER IN "picklist" TO p_Order
 = SEEK(q_Label, "picklist")
 cpLibutton = gcButtonfunction
 gcButtonfunction = cbUtfunction
 = myBrowse(p_Browsetext,10,@p_Browse,".t.","pl_label = q_Label",cbUttons, ;
   "vControl","MGRPLIST")
 gcButtonfunction = cpLibutton
 SET ORDER IN "picklist" TO l_OldOrd
 GOTO l_Oldrec IN "picklist"
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
PROCEDURE vControl
 PARAMETER p_Option
 PRIVATE ALL LIKE l_*
 l_Fld = "pl_lang"+g_Langnum
 l_Fld = &l_Fld
 DO CASE
      CASE p_Option==1
      CASE p_Option==2
           DO scRpicklist WITH "EDIT"
           g_Refreshall = .T.
      CASE p_Option==3
           DO scRpicklist WITH "NEW"
           g_Refreshall = .T.
      CASE p_Option==4
           IF (yeSno(GetLangText("MGRPLIST","TXT_DELIT")+";"+ALLTRIM(l_Fld)))
                DELETE
           ENDIF
 ENDCASE
 RETURN
ENDPROC
*
PROCEDURE ScrPickList
 PARAMETER p_Option, ltHeextraflag
 PRIVATE ALL LIKE l_*
 l_Choice = 1
 l_Height = 0
 FOR l_I = 1 TO ALEN(p_Say, 1)
      IF p_Say(l_I,3)='MEMO'
           l_Height = l_Height+3.75
      ELSE
           l_Height = l_Height+1.25
      ENDIF
 ENDFOR
 DO CASE
      CASE p_Option="EDIT"
           SCATTER MEMO MEMVAR
      CASE p_Option="NEW"
           SCATTER BLANK MEMO MEMVAR
           M.pl_label = q_Label
 ENDCASE
 DEFINE WINDOW wpIcklist FROM 0.000, 0.000 TO l_Height+6.5, 60.000 FONT  ;
        "Arial", 10 NOCLOSE NOZOOM TITLE p_Wintext NOMDI DOUBLE
 MOVE WINDOW wpIcklist CENTER
 ACTIVATE WINDOW wpIcklist
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 DO paNel WITH 1/4, 2/3, l_Height+1+(0.5), WCOLS()-(0.666666666666667)
 FOR l_I = 1 TO ALEN(p_Say, 1)
      l_Row = 1.00+((l_I-1)*1.25)
      l_Get = p_Say(l_I,2)
      l_Pict = p_Say(l_I,3)
      IF l_Pict='MEMO'
           @ l_Row, 3.000 EDIT M.pl_memo SIZE 3.75, 53 SCROLL COLOR RGB(0, ;
             0,0,192,192,192)
      ELSE
           DO paNel WITH l_Row-(0.0625), 8/3, l_Row+1+(0.0625), 70/3, 2
           @ l_Row, 4.000 SAY p_Say(l_I,1)
           @ l_Row, 25.00 Get &l_Get 				 Picture "@K" + l_Pict 			 valid Iif(VarRead() = "PL_LANG", LangEdit("PL_", p_WinText), .t.)  Size 1, 30
      ENDIF
 ENDFOR
 l_Row = WROWS()-2
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice STYLE "B" SIZE nbUttonheight, 15 PICTURE  ;
   "@*TH "+cbUttons VALID vcHoice(p_Option)
 READ CYCLE MODAL
 RELEASE WINDOW wpIcklist
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
                     INSERT INTO picklist FROM MEMVAR
                CASE (p_Option="EDIT")
                     GATHER MEMO MEMVAR
           ENDCASE
           CLEAR READ
      CASE M.l_Choice==2
           l_Retval = .T.
           CLEAR READ
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
FUNCTION PlSetLanguage
 PRIVATE ni
 PRIVATE clAbel
 PRIVATE acLanguages
 clAbel = "LANGUAGE"
 DIMENSION acLanguages[9, 2]
 acLanguages[1, 1] = "ENG"
 acLanguages[1, 2] = "English"
 acLanguages[2, 1] = "DUT"
 acLanguages[2, 2] = "Dutch"
 acLanguages[3, 1] = "GER"
 acLanguages[3, 2] = "German"
 acLanguages[4, 1] = "FRE"
 acLanguages[4, 2] = "French"
 acLanguages[5, 1] = "INT"
 acLanguages[5, 2] = "International English"
 acLanguages[6, 1] = "SER"
 acLanguages[6, 2] = "Serbian"
 acLanguages[7, 1] = "POR"
 acLanguages[7, 2] = "Portuguese"
 acLanguages[8, 1] = "ITA"
 acLanguages[8, 2] = "Italian"
 acLanguages[9, 1] = "POL"
 acLanguages[9, 2] = "Polish"
 SELECT piCklist
 noRder = ORDER()
 SET ORDER TO 3
 FOR ni = 1 TO 9
      IF ( .NOT. SEEK(PADR(clAbel, 10)+STR(ni, 3), "PickList"))
           SELECT piCklist
           APPEND BLANK
      ENDIF
      REPLACE piCklist.pl_label WITH clAbel
      IF (piCklist.pl_charcod<>PADR(acLanguages(ni,1), 10))
           REPLACE piCklist.pl_charcod WITH acLanguages(ni,1)
           REPLACE piCklist.pl_lang1 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang2 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang3 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang4 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang5 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang6 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang7 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang8 WITH acLanguages(ni,2)
           REPLACE piCklist.pl_lang9 WITH acLanguages(ni,2)
      ENDIF
      REPLACE piCklist.pl_numval WITH ni
      REPLACE piCklist.pl_sequ WITH ni
      REPLACE piCklist.pl_numcod WITH ni
      FOR nfIelds = 1 TO 9
           cfIeld = "PickList.Pl_Lang"+STR(nfIelds, 1)
           If ( Empty(&cField) )
                Replace &cField With acLanguages[nI, 2]
           ENDIF
      ENDFOR
 ENDFOR
 SELECT piCklist
 SET ORDER TO (noRder)
 RETURN .T.
ENDFUNC
*
FUNCTION PlSetDepartment
 PRIVATE clAbel
 clAbel = "DEPARTMENT"
 ctExt = "Hotel"
 SELECT piCklist
 noRder = ORDER()
 SET ORDER TO 1
 IF ( .NOT. SEEK(PADR(clAbel, 10), "PickList"))
      SELECT piCklist
      APPEND BLANK
      REPLACE piCklist.pl_label WITH clAbel
      REPLACE piCklist.pl_charcod WITH "HOT"
 ENDIF
 FOR nfIelds = 1 TO 9
      cfIeld = "PickList.Pl_Lang"+STR(nfIelds, 1)
      If ( Empty(&cField) )
           Replace &cField With cText
      ENDIF
 ENDFOR
 SELECT piCklist
 SET ORDER TO (noRder)
 RETURN .T.
ENDFUNC
*
FUNCTION PlSetRtGroups
 PRIVATE ni
 PRIVATE clAbel
 PRIVATE acRoomtypes
 clAbel = "ROOMTYPEGR"
 SELECT piCklist
 noRder = ORDER()
 SET ORDER TO 3
 FOR ni = 1 TO 4
      IF ( .NOT. SEEK(PADR(clAbel, 10)+STR(ni, 3), "PickList"))
           SELECT piCklist
           APPEND BLANK
      ENDIF
      REPLACE piCklist.pl_label WITH clAbel
      REPLACE piCklist.pl_lang1 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "ENG")
      REPLACE piCklist.pl_lang2 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "DUT")
      REPLACE piCklist.pl_lang3 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "GER")
      REPLACE piCklist.pl_lang4 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "FRE")
      REPLACE piCklist.pl_lang5 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "INT")
      REPLACE piCklist.pl_lang6 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "SER")
      REPLACE piCklist.pl_lang7 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "POR")
      REPLACE piCklist.pl_lang8 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "ITA")
      REPLACE piCklist.pl_lang9 WITH GetLangText("PICKLIST","TXT_RTG"+STR(ni, 1), ;
              "POL")
      REPLACE piCklist.pl_numcod WITH ni
 ENDFOR
 SELECT piCklist
 SET ORDER TO (noRder)
 RETURN .T.
ENDFUNC
*
FUNCTION PlSetBillText
 PRIVATE clAbel
 PRIVATE noRder
 clAbel = "BILLTEXT"
 SELECT piCklist
 noRder = ORDER()
 SET ORDER TO 1
 IF ( .NOT. SEEK(PADR(clAbel, 10), "PickList"))
      SELECT piCklist
      APPEND BLANK
 ENDIF
 REPLACE piCklist.pl_label WITH clAbel
 REPLACE piCklist.pl_lang1 WITH GetLangText("PICKLIST","TXT_BIL1","ENG")
 REPLACE piCklist.pl_lang2 WITH GetLangText("PICKLIST","TXT_BIL1","DUT")
 REPLACE piCklist.pl_lang3 WITH GetLangText("PICKLIST","TXT_BIL1","GER")
 REPLACE piCklist.pl_lang4 WITH GetLangText("PICKLIST","TXT_BIL1","FRE")
 REPLACE piCklist.pl_lang5 WITH GetLangText("PICKLIST","TXT_BIL1","INT")
 REPLACE piCklist.pl_lang6 WITH GetLangText("PICKLIST","TXT_BIL1","SER")
 REPLACE piCklist.pl_lang7 WITH GetLangText("PICKLIST","TXT_BIL1","POR")
 REPLACE piCklist.pl_lang8 WITH GetLangText("PICKLIST","TXT_BIL1","ITA")
 REPLACE piCklist.pl_lang9 WITH GetLangText("PICKLIST","TXT_BIL1","POL")
 SELECT piCklist
 SET ORDER TO (noRder)
 RETURN .T.
ENDFUNC
*
FUNCTION PlSetPayTypes
 PRIVATE ni
 PRIVATE clAbel
 PRIVATE acPaytypes
 PRIVATE nnUmberofpaytypes
 nnUmberofpaytypes = 7
 SELECT piCklist
 DELETE ALL FOR ALLTRIM(UPPER(pl_label))=="PAYTYPES"
 GOTO TOP
 clAbel = "PAYTYPE"
 DIMENSION acPaytypes[nnUmberofpaytypes]
 acPaytypes[1] = "Standard"
 acPaytypes[2] = "Currency"
 acPaytypes[3] = "Credit Card"
 acPaytypes[4] = "Ledger"
 acPaytypes[5] = "Negative"
 acPaytypes[6] = "Payment on Ledger"
 acPaytypes[7] = "Voucher"
 SELECT piCklist
 noRder = ORDER()
 SET ORDER TO 3
 FOR ni = 1 TO nnUmberofpaytypes
      IF ( .NOT. SEEK(PADR(clAbel, 10)+STR(ni, 3), "PickList"))
           SELECT piCklist
           APPEND BLANK
      ENDIF
      REPLACE piCklist.pl_label WITH clAbel
      REPLACE piCklist.pl_lang1 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "ENG")
      REPLACE piCklist.pl_lang2 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "DUT")
      REPLACE piCklist.pl_lang3 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "GER")
      REPLACE piCklist.pl_lang4 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "FRE")
      REPLACE piCklist.pl_lang5 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "INT")
      REPLACE piCklist.pl_lang6 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "SER")
      REPLACE piCklist.pl_lang7 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "POR")
      REPLACE piCklist.pl_lang8 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "ITA")
      REPLACE piCklist.pl_lang9 WITH GetLangText("PICKLIST","TXT_PYT"+STR(ni, 1), ;
              "POL")
      REPLACE piCklist.pl_numcod WITH ni
      REPLACE piCklist.pl_numval WITH ni
      REPLACE piCklist.pl_sequ WITH ni
 ENDFOR
 SELECT piCklist
 SET ORDER TO (noRder)
 RETURN .T.
ENDFUNC
*
FUNCTION PlSetActionTypes
 LOCAL l_nSelect, l_cLabel, l_oData
 l_nSelect = SELECT()
 l_cLabel = "ACTION    "
 IF NOT dlocate("picklist","pl_label = "+sqlcnv(l_cLabel)+" AND pl_charcod = 'MOV'")
      SELECT picklist
      SCATTER NAME l_oData BLANK
      l_oData.pl_label = l_cLabel
      l_oData.pl_charcod = "MOV"
      l_oData.pl_lang1 = GetLangText("RESERVAT","T_ROOMMOVED","ENG")
      l_oData.pl_lang2 = GetLangText("RESERVAT","T_ROOMMOVED","DUT")
      l_oData.pl_lang3 = GetLangText("RESERVAT","T_ROOMMOVED","GER")
      l_oData.pl_lang4 = GetLangText("RESERVAT","T_ROOMMOVED","FRE")
      l_oData.pl_lang5 = GetLangText("RESERVAT","T_ROOMMOVED","INT")
      l_oData.pl_lang6 = GetLangText("RESERVAT","T_ROOMMOVED","SER")
      l_oData.pl_lang7 = GetLangText("RESERVAT","T_ROOMMOVED","POR")
      l_oData.pl_lang8 = GetLangText("RESERVAT","T_ROOMMOVED","ITA")
      l_oData.pl_lang9 = GetLangText("RESERVAT","T_ROOMMOVED","POL")
      INSERT INTO picklist FROM NAME l_oData
      FLUSH
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDFUNC
*
FUNCTION PlDefaults
 PRIVATE ldOclose
 WAIT WINDOW NOWAIT "Checking PickList..."
 ldOclose = .F.
 IF (SELECT("PickList")==0)
      = opEnfile(.F.,"PickList")
      ldOclose = .T.
 ENDIF
 = plSetlanguage()
 = plSetdepartment()
 = plSetrtgroups()
 = plSetbilltext()
 = plSetpaytypes()
 = PlSetActionTypes()
 IF (ldOclose)
      = clOsefile("PickList")
 ENDIF
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
PROCEDURE MgrWuLang
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[3, 3]
 DIMENSION a_Say[3, 3]
 l_Label = "WULANG"
 l_Browsetext = GetLangText("MGRPLIST","TXT_WULBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_WUWINDOW")
 a_Brow[1, 1] = "PickList.pl_numcod"
 a_Brow[1, 2] = 10
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_WUSEQU")
 a_Brow[2, 1] = "pl_charcod"
 a_Brow[2, 2] = 20
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_WUCODE")
 a_Brow[3, 1] = "pl_lang"+g_Langnum
 a_Brow[3, 2] = 40
 a_Brow[3, 3] = GetLangText("MGRPLIST","TXT_WULANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_WUCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_WULANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 a_Say[3, 1] = GetLangText("MGRPLIST","TXT_WUSEQU")
 a_Say[3, 2] = "m.pl_numcod"
 a_Say[3, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 3
 RETURN
ENDPROC
*
PROCEDURE MgrFeature
	do Form "forms\MngForm" with "MngFeatCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 3]
 DIMENSION a_Say[2, 3]
 l_Label = "FEATURE"
 l_Browsetext = GetLangText("MGRPLIST","TXT_RMFBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_RMFWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_RMFCODE")
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_RMFLANG")
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_RMFCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_RMFLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrResource
	do Form "forms\MngForm" with "MngResCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[3, 4]
 DIMENSION a_Say[3, 3]
 l_Label = "RESOURCE"
 l_Browsetext = GetLangText("MGRPLIST","TXT_RSCBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_RSCWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 10
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_RSCCODE")
 a_Brow[1, 4] = ""
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_RSCLANG")
 a_Brow[2, 4] = ""
 a_Brow[3, 1] = "pl_numval"
 a_Brow[3, 2] = 15
 a_Brow[3, 3] = GetLangText("MGRPLIST","TXT_RSCMAX")
 a_Brow[3, 4] = "9999"
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_RSCCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_RSCLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 a_Say[3, 1] = GetLangText("MGRPLIST","TXT_RSCMAX")
 a_Say[3, 2] = "m.pl_numval"
 a_Say[3, 3] = " 9999"
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrConfStatus
	do Form "forms\MngForm" with "MngConfSCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 4]
 DIMENSION a_Say[2, 3]
 l_Label = "CONFSTATUS"
 l_Browsetext = GetLangText("MGRPLIST","TXT_CFSTBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_CFSTWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_CFSTCODE")
 a_Brow[1, 4] = ""
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_CFSTLANG")
 a_Brow[2, 4] = ""
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_CFSTCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_CFSTLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrBillInstr
	do Form "forms\MngForm" with "MngBillInstrCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 4]
 DIMENSION a_Say[3, 3]
 l_Label = "BILLINSTR"
 l_Browsetext = GetLangText("MGRPLIST","TXT_BINSBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_BINSWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_BINSCODE")
 a_Brow[1, 4] = ""
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_BINSLANG")
 a_Brow[2, 4] = ""
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_BINSCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_BINSLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 a_Say[3, 1] = GetLangText("MGRPLIST","TXT_BINSART")
 a_Say[3, 2] = "m.pl_memo"
 a_Say[3, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrMenu
	do Form "forms\MngForm" with "MngMenuCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 4]
 DIMENSION a_Say[3, 3]
 l_Label = "MENU"
 l_Browsetext = GetLangText("MGRPLIST","TXT_MENUBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_MENUWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_MENUCODE")
 a_Brow[1, 4] = ""
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_MENULANG")
 a_Brow[2, 4] = ""
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_MENUCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_MENULANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 a_Say[3, 1] = "Memo"
 a_Say[3, 2] = "m.pl_memo"
 a_Say[3, 3] = "MEMO"
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrDenial
	do Form "forms\MngForm" with "MngDenirCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 4]
 DIMENSION a_Say[2, 3]
 l_Label = "DENIALREAS"
 l_Browsetext = GetLangText("MGRPLIST","TXT_DNLRBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_DNLRWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_DNLRCODE")
 a_Brow[1, 4] = ""
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_DNLRLANG")
 a_Brow[2, 4] = ""
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_DNLRCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_DNLRLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrAcctType
 DO FORM "forms\MngForm" WITH "MngARAccCtrl"
 RETURN
ENDPROC
*
PROCEDURE MGRACCTPAYCOND
 LPARAMETERS lp_lCreditors
 IF lp_lCreditors
      DO FORM "forms\MngForm" WITH "mngarpaycond", 0, "ay_credito = .T.", 2
 ELSE
      DO FORM "forms\MngForm" WITH "mngarpaycond", 0, "ay_credito = .F.", 1
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE MGRACCTREMKEY
 LPARAMETERS lp_lCreditors
 IF lp_lCreditors
      DO FORM "forms\MngForm" WITH "mngarremtypes", 0, "am_credito = .T.", 2
 ELSE
      DO FORM "forms\MngForm" WITH "mngarremtypes", 0, "am_credito = .F.", 1
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE MGRACCTBILLSTATUS
 DO FORM "forms\MngForm" WITH "mngarbillstatus"
 RETURN
ENDPROC
*
PROCEDURE MgrActivity
	do Form "forms\MngForm" with "MngActionCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[2, 4]
 DIMENSION a_Say[2, 3]
 l_Label = "ACTION"
 l_Browsetext = GetLangText("MGRPLIST","TXT_ACTBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_ACTWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 20
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_ACTCODE")
 a_Brow[1, 4] = ""
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_ACTLANG")
 a_Brow[2, 4] = ""
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_ACTCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_ACTLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrDiscount
	do Form "forms\MngForm" with "MngDiscountCtrl"
	return
 PRIVATE ALL LIKE l_*
 PRIVATE a_Brow, a_Say
 DIMENSION a_Brow[3, 4]
 DIMENSION a_Say[3, 3]
 l_Label = "DISCOUNT"
 l_Browsetext = GetLangText("MGRPLIST","TXT_DSCBROWSE")
 l_Wintext = GetLangText("MGRPLIST","TXT_DSCWINDOW")
 a_Brow[1, 1] = "PickList.pl_charcod"
 a_Brow[1, 2] = 10
 a_Brow[1, 3] = GetLangText("MGRPLIST","TXT_DSCCODE")
 a_Brow[1, 4] = ""
 a_Brow[2, 1] = "pl_lang"+g_Langnum
 a_Brow[2, 2] = 40
 a_Brow[2, 3] = GetLangText("MGRPLIST","TXT_DSCLANG")
 a_Brow[2, 4] = ""
 a_Brow[3, 1] = "pl_numval"
 a_Brow[3, 2] = 15
 a_Brow[3, 3] = GetLangText("MGRPLIST","TXT_DSCPCT")
 a_Brow[3, 4] = "99%"
 a_Say[1, 1] = GetLangText("MGRPLIST","TXT_DSCCODE")
 a_Say[1, 2] = "m.pl_charcod"
 a_Say[1, 3] = " !!!"
 a_Say[2, 1] = GetLangText("MGRPLIST","TXT_DSCLANG")
 a_Say[2, 2] = "m.pl_lang"+g_Langnum
 a_Say[2, 3] = ""
 a_Say[3, 1] = GetLangText("MGRPLIST","TXT_DSCPCT")
 a_Say[3, 2] = "m.pl_numval"
 a_Say[3, 3] = " 99"
 DO piCklist WITH l_Label, l_Browsetext, l_Wintext, a_Brow, a_Say, 4
 RETURN
ENDPROC
*
PROCEDURE MgrBillDiscount
	DO FORM "forms\MngForm" WITH "MngBillDiscountCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRVIRROOM
	do Form "forms\MngForm" with "MngVirroomsCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRREFERRAL
	do Form "forms\MngForm" with "MngReferralCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRMAINGROUPBASEL
	do Form "forms\MngForm" with "MngMainGrBaselCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRSUBGROUPBASEL
	do Form "forms\MngForm" with "MngSubGrBaselCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGROBERGROUPBASEL
	do Form "forms\MngForm" with "MngOberGrBaselCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRSETTINGS
	do Form "forms\MngForm" with "MngSettingsCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRPERSONALBASEL
	do Form "forms\MngForm" with "MngBaselPersonalCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRDEPARTMENTBASEL
	do Form "forms\MngForm" with "MngBaselDepartmentCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRSUPLBASEL
	do Form "forms\MngForm" with "MngBaselSupplCtrl"
	RETURN
ENDPROC
*
PROCEDURE MGRBESTUHLUNG
	do Form "forms\MngForm" with "MngBestuhlungCtrl"
	RETURN
ENDPROC
*
PROCEDURE MgrBuilding
	do Form "forms\MngForm" with "MngBuildingCtrl"
ENDPROC
*
PROCEDURE MGRACCOUNTS
	do Form "forms\MngForm" with "MngAccountsCtrl"
ENDPROC
*
PROCEDURE MgrEnergie
     do Form "forms\MngForm" with "MngEnergieCtrl"
ENDPROC
*
PROCEDURE MGRADRTYPE
     do Form "forms\MngForm" with "mngadrtypectrl"
ENDPROC
*
PROCEDURE MGRVIPSTATUS
     do Form "forms\MngForm" with "mngvipstatusctrl"
ENDPROC
*
PROCEDURE MGRCASHINOUT
     do Form "forms\MngForm" with "mngcashinoutctrl"
ENDPROC