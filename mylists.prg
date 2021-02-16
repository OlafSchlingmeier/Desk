#INCLUDE "include\constdefines.h"
#DEFINE ERROR_SUCCESS	0	&& OK
*
Function Lists
Parameter nmEnugroup, cpRompt, lMultiProp, nLetterType
Private cbUttons
Private ccOntrolfunction
Private ncUrrentarea
Private cfOrclause
Private ni
Private clEvel
Private acListsfields
Private nlIstsrecord
Private nsIzeofbrowse
Private cwHileclause
Private csAvebutton
Private lUseApartner
LOCAL l_oFormData, l_nReserId, l_nAddrId, l_nApid, l_oActiveForm, l_oPrivacyPolicy, l_cLangCode
LOCAL ARRAY l_aMin1Param(1)
_deleteconf = .F.
_letters = .F.
lUseApartner = .F.
STORE 0 TO l_nReserId, l_nAddrId, l_nApId
csAvebutton = gcButtonfunction
ncUrrentarea = Select()
LOCAL i, l_cModule, LString1, l_tag, LStoreListsOrder 
STORE "" TO LString1, l_tag, LStoreListsOrder 

DO CASE
	CASE nmEnugroup = 0
		DO FORM "FORMS\MngForm" With "MngReportsCtrl"
		Return
	CASE INLIST(nmEnugroup, 9)
		nlIstsrecord = Recno("Lists")
		LStoreListsOrder = ORDER('Lists')
		For ni = 1 To 11
			Select Lists
			Set Order To 11+ni
			If (Seek(Str(nmEnugroup, 2)+Upper(cpRompt)))
				EXIT
			Endif
		ENDFOR
		IF !EMPTY(LStoreListsOrder)
			SET ORDER TO &LStoreListsOrder IN LISTS
		ENDIF
		If ( .Not. Found())
			= alErt(GetLangText("MYLISTS","TXT_REPORTNAME")+":"+ ;
				UPPER(Alltrim(cpRompt))+";"+GetLangText("MYLISTS", ;
				"TXT_GROUPNUMBER")+":"+Str(nmEnugroup, 2), ;
				GetLangText("MYLISTS","TA_NOFRX"))
		Else
			= prTreport()
		Endif
		DO restoreListsEnv WITH nListsRecord, nCurrentArea
	OTHERWISE
		IF TYPE("_screen.ActiveForm") = "O"
			l_oActiveForm = _screen.ActiveForm
		ELSE
			l_oActiveForm = .NULL.
		ENDIF
		IF TYPE("l_oActiveForm.ActiveControl.Parent") = "O" AND LOWER(l_oActiveForm.ActiveControl.Parent.Class) = "privacypolicy"
			l_oPrivacyPolicy = l_oActiveForm.ActiveControl.Parent
		ELSE
			l_oPrivacyPolicy = .NULL.
		ENDIF
		l_tag = 'tag' + g_Langnum
		SET ORDER TO &l_tag IN lists&& Setting order for showing in mybrowse window, sorted an li_order+li_langX
		nlIstsrecord = Recno("Lists")
		LString1 = "EMPTY(li_license)"
		FOR i = 1 TO GETWORDCOUNT(_screen.liclist,",")
			l_cModule = GETWORDNUM(_screen.liclist,i,",")
			IF _screen.&l_cModule
				LString1 = LString1 + " OR '" + l_cModule + "' $ li_license" 
			ENDIF
		NEXT
		cfOrclause = "(EMPTY(li_usrgrp) OR g_UserGroup $ li_usrgrp) AND NOT li_hide AND (" + LString1 + ")"
		cfOrclause = cfOrclause + " AND li_mainsrv = " + SqlCnv(lMultiProp, .T.)
		cwHileclause = "li_menu = " + STR(nMenuGroup)
		clEvel = ""

		ccOntrolfunction = "vPrint"
		nSizeOfBrowse = 0

		IF WEXIST("frmRepList")
			RELEASE WINDOWS "frmRepList"
		ENDIF

		SELECT lists
		IF nmEnugroup = 8
			cwInname = wnAme(.T.)
			DO CASE
				CASE VARTYPE(nLetterType) = "N"
					cfOrclause = cfOrclause + " AND li_lettype = " + TRANSFORM(nLetterType)
					IF NOT ISNULL(l_oPrivacyPolicy)
						l_nAddrId = l_oPrivacyPolicy.GetAddressId()
					Endif
					l_cLangCode = MLGetLangCode(,l_nAddrId)
					COUNT ALL FOR li_menu = nMenuGroup AND li_lettype = nLetterType TO nSizeOfBrowse
					IF nLetterType = 4
						_deleteconf = .T.	&& Delete address confirmation. When print a confirmation then start deleting an address.
					ENDIF
					_letters = .T.
				CASE INLIST(cwInname, 'WADBROWSE', 'WLDBROWSE')
					nLetterType = 0
					cfOrclause = cfOrclause + " AND li_lettype = 0"
					l_nAddrId = saddress.ad_addrid
					l_cLangCode = MLGetLangCode(,l_nAddrId)
					COUNT ALL FOR li_menu = nMenuGroup AND li_lettype = 0 TO nSizeOfBrowse
					_letters = .T.
				CASE INLIST(cwInname, 'WRESERVAT', 'WRSBROWSE')
					nLetterType = 1
					cfOrclause = cfOrclause + " AND li_lettype = 1"
					* Find language for address
					l_nReserId = _screen.oGlobal.oBill.nReserId
					l_cLangCode = MLGetLangCode(l_nReserId)
					COUNT ALL FOR li_menu = nMenuGroup AND li_lettype = 1 TO nSizeOfBrowse
					_letters = .T.
				CASE INLIST(cwInname, 'BMSMANAGER')
					nLetterType = 2
					cfOrclause = cfOrclause + " AND li_lettype = 2"
					COUNT ALL FOR li_menu = nMenuGroup AND li_lettype = 2 TO nSizeOfBrowse
					_letters = .T.
			ENDCASE
		ELSE
			COUNT ALL FOR li_menu = nMenuGroup AND li_mainsrv = lMultiProp TO nSizeOfBrowse
		ENDIF
		IF nSizeOfBrowse = 0
			= alErt(GetLangText("MYLISTS","TXT_NOLISTSINTHISGROUP"))
			DO restoreListsEnv WITH nListsRecord, nCurrentArea
		ELSE
			IF NOT ISNULL(l_oActiveForm) AND l_oActiveForm.Name = 'FAddressMask'
				DLocate("saddress","ad_addrid = " + sqlcnv(l_oActiveForm.Parent.m_getselectedaddress(@l_nApid)))
				IF NOT EMPTY(l_nApid)
					DLocate("apartner", "ap_apid = " + SqlCnv(l_nApid))
					lUseApartner = NOT EMPTY(apartner.ap_apid)
				Endif
			Endif
			IF NOT ISNULL(l_oPrivacyPolicy)
				DLocate("saddress","ad_addrid = " + sqlcnv(l_oPrivacyPolicy.GetAddressId()))
			Endif
			DIMENSION acListsfields[1, 3]
			acListsfields[1, 1] = "lists.li_lang"+g_Langnum
			acListsfields[1, 2] = 50
			acListsfields[1, 3] = GetLangText("MYLISTS","TH_DESCRIPT")
			SELECT lists
			= SEEK(STR(nmEnugroup, 2))
			l_oFormData = CREATEOBJECT("cdatatunnel")
			l_oFormData.AddProperty("lletters",_letters)
			l_oFormData.AddProperty("ldeleteconf",_deleteconf)
			l_oFormData.AddProperty("nMenuGroup",nMenuGroup)
			l_oFormData.AddProperty("nListsRecord",nListsRecord)
			l_oFormData.AddProperty("nCurrentArea",nCurrentArea)
			l_oFormData.AddProperty("lUseApartner",lUseApartner)
			l_oFormData.AddProperty("nReserId",l_nReserId)
			l_oFormData.AddProperty("nAddrId",l_nAddrId)
			l_oFormData.AddProperty("nApId",l_nApId)
			IF nmEnugroup = 8 AND cwInname = 'BMSMANAGER' AND TYPE("l_oActiveForm.MngCtrl.gtAlias") = "C"
				l_oFormData.AddProperty("aMin1Param(1)")
				l_oFormData.aMin1Param(1) = 0
				l_oActiveForm.DoEval("SELECT bb_bbid FROM (this.MngCtrl.gtAlias) WHERE c_selected INTO ARRAY lp_uParam1.aMin1Param", .T., l_oFormData)
				IF EMPTY(l_oFormData.aMin1Param(1))
					l_oFormData.aMin1Param(1) = l_oActiveForm.DoEval("EVALUATE(this.MngCtrl.gtAlias + '.bb_bbid')")
				ENDIF
			ENDIF
			nSizeOfBrowse = MAX(MIN(nSizeOfBrowse, 20), 3)
			DO FORM "forms\repmain" WITH 1, l_oFormData, ;
				GetLangText("MYLISTS","TW_REPORTS")+"/ "+cpRompt, ;
				"Li_Lang"+g_Langnum, GetLangText("MYLISTS","TH_DESCRIPT"), ;
				cForClause, cWhileClause, nSizeofBrowse, l_cLangCode
		ENDIF
ENDCASE

RETURN .T.
ENDFUNC
*
PROCEDURE restoreListsEnv
LPARAMETERS nListsRecord, nCurrentArea
	LOCAL l_nRecno
	Select Lists
	Goto nlIstsrecord
	Select (ncUrrentarea)
*	gcButtonfunction = csAvebutton
	l_nRecno = RECNO('reservat')
	= reLations()
	GO l_nRecno IN reservat
	Select (ncUrrentarea)
ENDPROC 
*
Function vPrint
Parameter p_Choice
Do Case
Case p_Choice==1
Case p_Choice==2
	= prTreport((nmEnugroup==8))
ENDCASE
Return .T.
Endfunc
*
Procedure scRreport
Parameter p_Option
Private cdEscription
Private clEvel
Private cbUttons, ceNabled
Private All Like l_*
l_Choice = 1
Define Window wrEport From 0, 0 To 24, 70 Font "Arial", 10 Noclose  ;
	NOZOOM Title chIldtitle(GetLangText("MYLISTS","TW_REPORTS")) Nomdi Double
Move Window wrEport Center
Move Window wrEport By -1, 0
Activate Window wrEport
clEvel = ""
cbUttons = "\!"+Button(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
	buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),2)+Button(clEvel, ;
	'\<'+GetLangText("MYLISTS","TXT_DIALOG"),3)+Button(clEvel, ;
	GetLangText("MYLISTS","TXT_LETTER"),-4)
Select Lists
Do Case
Case p_Option="NEW"
	Scatter Blank Memo Memvar
	m.li_custom = .T.
Case p_Option="COPY" .Or. p_Option="EDIT"
	Scatter Memo Memvar
	If (p_Option=="COPY")
		m.li_listid = ''
		m.li_custom = .T.
	Endif
Endcase
Dimension acChecks[18]
Dimension alChecks[18]
Store "" To acChecks
Store .F. To alChecks
Do geTchecks In MainMenu With acChecks, alChecks, "REPORT"
cdDelink = geTddelink()
For ni = 17 To 1 Step -1
	acChecks[ni+1] = acChecks(ni)
Endfor
acChecks[1] = GetLangText("MYLISTS","TXT_BILL")
m.li_menu = M.li_menu+1
cdEscription = "m.Li_Lang"+g_Langnum
cpRompt1 = "m.P1_Lang"+g_Langnum
cpRompt2 = "m.P2_Lang"+g_Langnum
cpRompt3 = "m.P3_Lang"+g_Langnum
cpRompt4 = "m.P4_Lang"+g_Langnum
Do Panel With 1/4, 2/3, 5.00, Wcols()-(0.666666666666667), 1
Do Panel With 5.25, 2/3, Wrows()-3, Wcols()-(0.666666666666667), 1
Do Panel With 11/16, 5/3, 29/16, 70/3, 2
Do Panel With 31/16, 5/3, 49/16, 70/3, 2
Do Panel With 51/16, 5/3, 69/16, 70/3, 2
Do Panel With 91/16, 5/3, 109/16, 70/3, 2
Do Panel With 111/16, 5/3, 129/16, 70/3, 2
Do Panel With 131/16, 5/3, 149/16, 70/3, 2
Do Panel With 151/16, 5/3, 169/16, 70/3, 2
Do Panel With 171/16, 5/3, 189/16, 70/3, 2
Do Panel With 191/16, 5/3, 209/16, 70/3, 2
Do Panel With 211/16, 5/3, 229/16, 70/3, 2
@ 0.750, 2 Say "Id"+" / "+GetLangText("MYLISTS","T_BASEDON")
@ 2.000, 2 Say GetLangText("MYLISTS","T_DESCRIPT")
@ 3.250, 2 Say GetLangText("MYLISTS","T_MENU")
@ 5.750, 2 Say GetLangText("MYLISTS","T_OUTPUT")
@ 7.000, 2 Say GetLangText("MYLISTS","T_REPOFILE")
@ 8.250, 2 Say GetLangText("MYLISTS","T_DDELINK")
@ 9.500, 2 Say GetLangText("MYLISTS","T_DDEMACRO")+" / "+GetLangText("MYLISTS", ;
	"TXT_DOTFILE")
@ 10.750, 2 Say GetLangText("MYLISTS","T_USRGRP")
@ 12.000, 2 Say GetLangText("MYLISTS","T_BATCH")
@ 13.250, 2 Say GetLangText("MYLISTS","T_WHEN")
@ 14.500, 2 Say GetLangText("MYLISTS","T_PREPOST")
ceNabled = Iif(Inlist(p_Option, 'NEW', 'COPY'), 'ENABLED', 'DISABLED')
@ 0.75, 25 Get m.li_listid  Picture 'A!!!!!!!'  Size 1, 10  Color ,,,,,,,,,Rgb(0,0,255,192,192,192)  Valid Empty(DLookup('Lists', 'li_listid = ' + SqlCnv(m.li_listid), 'li_listid'))  &ceNabled
@ 0.750, 37 Get M.li_basedon Size 1, 10 Picture '!!!!!!!!' Valid  ;
	(Empty(M.li_basedon) .Or.  .Not. Empty(DLookup('Lists','li_listid = '+ ;
	SqlCnv(M.li_basedon),'li_listid')))
@ 2,   25 Get &cdEscription  Picture "@K " + Replicate("X", 50)	 Valid LangEdit("LI_", GetLangText("MYLISTS",    "TXT_LIWINDOW"), 50)  Size 1, 40
@ 3.250, 247/10 Get M.li_menu Size 1, 23 From acChecks Function "^"  ;
	VALID xeNable('m.li_reslet',M.li_menu=9)
@ 5.750, 25.000 Get M.li_output Default 1 Picture "@*RNH "+ ;
	GetLangText("MYLISTS","TXT_DIALOG")+";"+GetLangText("MYLISTS","TXT_OPRINTER")+";"+ ;
	GetLangText("MYLISTS","TXT_DBF")+";CSV" Valid xeNable('m.li_frx', ;
	INLIST(M.li_output, 1, 2)) .And. xeNable('m.li_outfile',M.li_output=3)  ;
	.And. xeNable('m.li_ddelink',Inlist(M.li_output, 3, 4)) .And.  ;
	xeNable('m.li_ddemcro',Inlist(M.li_output, 3, 4)) .And.  ;
	xeNable('m.li_dotfile',Inlist(M.li_output, 3, 4))
ceNabled = Iif(Inlist(M.li_output, 1, 2), 'ENABLED', 'DISABLED')
@ 07.00, 25.00 Get m.li_frx  Picture "@K " + Replicate("!", 12)  Size 1, 19  &ceNabled
ceNabled = Iif(M.li_output=3, 'ENABLED', 'DISABLED')
@ 07.00, 46.00 Get m.li_outfile  Picture "@K " + Replicate("!", 12)  Size 1, 19  &ceNabled
ceNabled = Iif(Inlist(M.li_output, 3, 4), 'ENABLED', 'DISABLED')
@ 08.25, 25.00 Get m.li_ddelink  Picture "@*RNH " + cdDelink  Size 1, 10  &ceNabled
ceNabled = Iif(Inlist(M.li_output, 3, 4), 'ENABLED', 'DISABLED')
@ 09.50, 25.00 Get m.li_ddemcro  Picture "@K " + Replicate("!", 10)  Size 1, 19  &ceNabled
ceNabled = Iif(Inlist(M.li_output, 3, 4), 'ENABLED', 'DISABLED')
@ 09.50, 46.00 Get m.li_dotfile  Picture "@K " + Replicate("!", 10)  Size 1, 19  &ceNabled
@ 10.750, 25.000 Get M.li_usrgrp Size 1, 40 Picture "@K "+Replicate("!", 40)
@ 12.000, 25.000 Get M.li_batch Size 1, 40 Picture "@K "+Replicate("!", 20)
@ 13.250, 25.000 Get M.li_when Size 1, 40 Picture "@K "+Replicate("X", 40)
@ 14.500, 25.000 Get M.li_preproc Size 1, 19 Picture "@K "+Replicate("!",  ;
	40) Valid (Empty(M.li_preproc) .Or. isPreproc(M.li_preproc))
@ 14.500, 46.000 Get M.li_postpro Size 1, 19 Picture "@K "+Replicate("!", 20)
ceNabled = Iif(M.li_menu=9, 'ENABLED', 'DISABLED')
@ 15.75, 2 Get m.li_reslet  Picture GetLangText("MYLISTS",    "TXT_RESLET")  Function "*C"  &ceNabled
@ 17.000, 2 Get M.li_custom Function "*C" Picture GetLangText("MYLISTS","TXT_CUSTOM")
@ 18.250, 2 Get M.li_hide Function "*C" Picture GetLangText("MYLISTS","TXT_HIDE")
l_Row = Wrows()-2
l_Col = (Wcols()-0048-1)/2-1
@ l_Row, l_Col Get l_Choice Size nbUttonheight, 12 Picture "@*NH "+ ;
	cbUttons Valid vcHoice(p_Option)
Read Cycle Modal
Release Window wrEport
= chIldtitle("")
Return
Endproc
*
	Function vcHoice
	Parameter p_Option
	Private l_Retval
	l_Retval = .F.
	Do Case
	Case M.l_Choice==1
		l_Retval = .T.
		m.li_menu = M.li_menu-1
		Do Case
		Case (p_Option="NEW" .Or. p_Option="COPY")
			Insert Into Lists From Memvar
			Flush
		Case (p_Option="EDIT")
			Gather Memo Memvar
			Flush
		Endcase
		Clear Read
	Case M.l_Choice==2
		l_Retval = .T.
		Clear Read
	Case M.l_Choice==3
		Do scRdialog
	Case M.l_Choice==4
		= meMoedit(@M.li_memo)
	Case l_Choice==5
		= biGedit()
	Endcase
	Return l_Retval
Endfunc
*
	Function biGedit
	Private csQlmemo
	Copy Memo Lists.li_sql To "SqlState.Txt"
	= Ddesetoption("TIMEOUT", Param.pa_ddetout)
	= Ddesetoption("SAFETY", .F.)
	Run /N3 NotePad SqlState.Txt
	Wait Window GetLangText("MYLISTS","TXT_DONTFORGETTOSAVE")
	Select Lists
	coLdsql = Lists.li_sql
	If (File("SqlState.Txt"))
		Append Memo Lists.li_sql From "SqlState.Txt" Overwrite
	Else
		Replace Lists.li_sql With ""
	Endif
	If (coLdsql<>Lists.li_sql)
		If ( .Not. yeSno(GetLangText("MYLISTS","TXT_SAVESQL")))
			Replace Lists.li_sql With coLdsql
		Endif
	Endif
	m.li_sql = Lists.li_sql
	Return .F.
Endfunc
*
	Function meMoedit
	Parameter p_Memo
	Private l_Memo
	l_Memo = p_Memo
Define Window wbIgedit At 0.000, 0.000 Size 30, 110 Font "Arial", 10  ;
	NOCLOSE Nozoom Title chIldtitle("Memo") Nomdi Double
Move Window wbIgedit Center
Activate Window wbIgedit
@ 1/4, 2/3 Edit l_Memo Size Wrows()-(0.5), Wcols()-(1.33333333333333)  ;
	SCROLL Tab Color Rgb(0,0,0,192,192,192)
Read Deactivate Deact()
If Lastkey()<>27
	p_Memo = l_Memo
Endif
Release Window wbIgedit
= chIldtitle("")
Return .F.
Endfunc
*
	Function Deact
	Clear Read
	Return .T.
Endfunc
*
	Procedure scRdialog
	Private All Like l_*
	l_Choice = 1
Define Window wdIalog From 0.000, 0.000 To 31, 70 Font "Arial", 10  ;
	NOCLOSE Nozoom Title chIldtitle(GetLangText("MYLISTS","TW_DIALOG"))  ;
	NOMDI Double
Move Window wdIalog Center
Activate Window wdIalog
coPerator = GetLangText("MYLISTS","TXT_EQUALS")+";"+GetLangText("MYLISTS","TXT_RANGE")
ctYpe = GetLangText("MYLISTS","TXT_CHARACTER")+";"+GetLangText("MYLISTS", ;
	"TXT_NUMERIC")+";"+GetLangText("MYLISTS","TXT_DATE")+";"+GetLangText("MYLISTS", ;
	"TXT_LOGICAL")+";"+GetLangText("MYLISTS","TXT_MEMO")
Do Panel With 1/4, 2/3, 25/4, Wcols()-(0.666666666666667), 1
Do Panel With 13/2, 2/3, 49/4, Wcols()-(0.666666666666667), 1
Do Panel With 25/2, 2/3, 73/4, Wcols()-(0.666666666666667), 1
Do Panel With 37/2, 2/3, 97/4, Wcols()-(0.666666666666667), 1
Do Panel With 49/2, 2/3, 111/4, Wcols()-(0.666666666666667), 1
Do Panel With 15/16, 8/3, 33/16, 70/3, 2
Do Panel With 35/16, 8/3, 53/16, 70/3, 2
Do Panel With 55/16, 8/3, 73/16, 70/3, 2
Do Panel With 75/16, 8/3, 93/16, 70/3, 2
Do Panel With 111/16, 8/3, 129/16, 70/3, 2
Do Panel With 131/16, 8/3, 149/16, 70/3, 2
Do Panel With 151/16, 8/3, 169/16, 70/3, 2
Do Panel With 171/16, 8/3, 189/16, 70/3, 2
Do Panel With 207/16, 8/3, 225/16, 70/3, 2
Do Panel With 227/16, 8/3, 245/16, 70/3, 2
Do Panel With 247/16, 8/3, 265/16, 70/3, 2
Do Panel With 267/16, 8/3, 285/16, 70/3, 2
Do Panel With 303/16, 8/3, 321/16, 70/3, 2
Do Panel With 323/16, 8/3, 341/16, 70/3, 2
Do Panel With 343/16, 8/3, 361/16, 70/3, 2
Do Panel With 363/16, 8/3, 381/16, 70/3, 2
Do Panel With 399/16, 8/3, 417/16, 70/3, 2
Do Panel With 419/16, 8/3, 437/16, 70/3, 2
@ 1.000, 4.000 Say GetLangText("MYLISTS","T_PRMTPICT")+" 1"
@ 2.250, 4.000 Say GetLangText("MYLISTS","T_OPERATOR")
@ 3.500, 4.000 Say GetLangText("MYLISTS","T_TYPE")
@ 4.750, 4.000 Say GetLangText("MYLISTS","T_DEFAULT")
@ 7.000, 4.000 Say GetLangText("MYLISTS","T_PRMTPICT")+" 2"
@ 8.250, 4.000 Say GetLangText("MYLISTS","T_OPERATOR")
@ 9.500, 4.000 Say GetLangText("MYLISTS","T_TYPE")
@ 10.750, 4.000 Say GetLangText("MYLISTS","T_DEFAULT")
@ 13.000, 4.000 Say GetLangText("MYLISTS","T_PRMTPICT")+" 3"
@ 14.250, 4.000 Say GetLangText("MYLISTS","T_OPERATOR")
@ 15.500, 4.000 Say GetLangText("MYLISTS","T_TYPE")
@ 16.750, 4.000 Say GetLangText("MYLISTS","T_DEFAULT")
@ 19.000, 4.000 Say GetLangText("MYLISTS","T_PRMTPICT")+" 4"
@ 20.250, 4.000 Say GetLangText("MYLISTS","T_OPERATOR")
@ 21.500, 4.000 Say GetLangText("MYLISTS","T_TYPE")
@ 22.750, 4.000 Say GetLangText("MYLISTS","T_DEFAULT")
@ 25.000, 4.000 Say "Index on"
@ 26.250, 4.000 Say "Filter on"
@ 01.00, 25.00 Get &cpRompt1  Picture "@K " + Replicate("X", 20)  Valid LangEdit("P1_", GetLangText("MYLISTS",    "TXT_PRWINDOW"))  Size 1, 19
@ 1.000, 46.000 Get M.li_pict1 Size 1, 19 Picture "@K "+Replicate("X", 40)
@ 2.250, 25.000 Get M.li_operat1 Default 1 Picture "@*RNH "+coPerator
@ 3.500, 25.000 Get M.li_type1 Default 1 Font "Arial", 007 Style "B"  ;
	SIZE 1, 25 Function "^" Picture ctYpe
@ 4.750, 25.000 Get M.li_mindef1 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 4.750, 46.000 Get M.li_maxdef1 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 07.00, 25.00 Get &cpRompt2  Picture "@K " + Replicate("X", 20)  Valid LangEdit("P2_", GetLangText("MYLISTS",    "TXT_PRWINDOW"))  Size 1, 19
@ 7.000, 46.000 Get M.li_pict2 Size 1, 19 Picture "@K "+Replicate("X", 40)
@ 8.250, 25.000 Get M.li_operat2 Default 1 Size 1, 10 Picture "@*RNH "+ ;
	coPerator
@ 9.500, 25.000 Get M.li_type2 Default 1 Font "Arial", 007 Style "B"  ;
	SIZE 1, 25 Function "^" Picture ctYpe
@ 10.750, 25.000 Get M.li_mindef2 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 10.750, 46.000 Get M.li_maxdef2 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 13.00, 25.00 Get &cpRompt3  Picture "@K " + Replicate("X", 20)  Valid LangEdit("P3_", GetLangText("MYLISTS",    "TXT_PRWINDOW"))  Size 1, 19
@ 13.000, 46.000 Get M.li_pict3 Size 1, 19 Picture "@K "+Replicate("X", 40)
@ 14.250, 25.000 Get M.li_operat3 Default 1 Size 1, 10 Picture "@*RNH "+ ;
	coPerator
@ 15.500, 25.000 Get M.li_type3 Default 1 Font "Arial", 007 Style "B"  ;
	SIZE 1, 25 Function "^" Picture ctYpe
@ 16.750, 25.000 Get M.li_mindef3 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 16.750, 46.000 Get M.li_maxdef3 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 19.00, 25.00 Get &cpRompt4  Picture "@K " + Replicate("X", 20)  Valid LangEdit("P4_", GetLangText("MYLISTS",    "TXT_PRWINDOW"))  Size 1, 19
@ 19.000, 46.000 Get M.li_pict4 Size 1, 19 Picture "@K "+Replicate("X", 40)
@ 20.250, 25.000 Get M.li_operat4 Default 1 Size 1, 10 Picture "@*RNH "+ ;
	coPerator
@ 21.500, 25.000 Get M.li_type4 Default 1 Font "Arial", 007 Style "B"  ;
	SIZE 1, 25 Function "^" Picture ctYpe
@ 22.750, 25.000 Get M.li_mindef4 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 22.750, 46.000 Get M.li_maxdef4 Size 1, 19 Picture "@K "+Replicate("X", 20)
@ 25.000, 25.000 Get M.li_index Size 1, 40 Picture "@K "+Replicate("X", 100)
@ 26.250, 25.000 Get M.li_filter Size 1, 40 Picture "@K "+Replicate("X", 100)
l_Row = Wrows()-1.50
l_Col = (Wcols()-0016-1)/2
@ l_Row, l_Col Get l_Choice Style "B" Size nbUttonheight, 15 Function  ;
	"*"+"H" Picture GetLangText("COMMON","TXT_OK")
Read Cycle Modal
Release Window wdIalog
= chIldtitle("")
Return
Endproc
*
Procedure prTreport
Parameter p_Batchmode, _letters, p_oDefaults, p_lRptGroup, p_lNoDialog

Private llAyoutok
Private ntHischoice
Private cdEmoversion
Private acFileareas, aCurrFileAreas
Private ldOnesomeprinting
Private ccSvfile, lcSvfileok
Private ndDeretry
Private cdOcdescr, cdOcfile, ndOcaddrid, ndOcreserid, ndOcbonusid, ndOcarea
Private All Like l_*
Private prOmpt1, prOmpt2, prOmpt3, prOmpt4, miN1, miN2, miN3, miN4, maX1,  ;
	maX2, maX3, maX4, Title, RptBulding, RptUseBookKeepingDate
Private sySdate
LOCAL l_docname, lcOldErrorHandlerDefinition, l_result, l_lUnbindWhenFinish, l_cOutputAlias, lcPpFile, lnRow, lcLiMemo
LOCAL l_cOutputFile, l_lExternCall, l_cArchive, l_lNotOpenViewer, l_nPeferedType, l_cZipFileName, l_lSaveInDoc, l_nSelect, l_cQRCodePDF
ldOnesomeprinting = .F.
cdEmoversion = gcApplication+Iif(g_Demo, " DEMO VERSION .....  ",  ;
	" TRAININGS VERSION ...")
IF TYPE("lUseApartner") <> "L"
	PRIVATE lUseApartner
	lUseApartner = .F.
ENDIF
If (PCOUNT()==0)
	p_Batchmode = .T.
	llAyoutok = .T.
Else
	llAyoutok = .F.
ENDIF
l_lExternCall = (VARTYPE(p_oDefaults) = "O")
IF l_lExternCall
	RptBulding = IIF(PEMSTATUS(p_oDefaults, "RptBulding", 5), p_oDefaults.RptBulding, "")
	l_nPeferedType = IIF(PEMSTATUS(p_oDefaults, "nPeferedType", 5), p_oDefaults.nPeferedType, 0)
	l_cArchive = IIF(PEMSTATUS(p_oDefaults, "cArchive", 5), p_oDefaults.cArchive, "")
	RptUseBookKeepingDate = IIF(PEMSTATUS(p_oDefaults, "RptUseBookKeepingDate", 5), p_oDefaults.RptUseBookKeepingDate, .NULL.)
ELSE
	RptBulding = ""
	l_nPeferedType = 0
	IF p_Batchmode
		p_Batchmode = NOT lists.li_dialog&&Check if report dialog must appear, over parameter lists.li_dialog
	ENDIF
	RptUseBookKeepingDate = .NULL.
ENDIF
If Lists.li_menu<>8
	nsElx = Select()
	nrEcx = Recno()
	Do poStallrooms In Audit
	Select (nsElx)
	Goto nrEcx
Endif
AUSED(acFileareas)
l_Oldarea = Select()
l_Numoffields = IIF(g_lBuildings AND lists.li_buildng, 1, 0)
l_Error = .F.
l_Errortext = ""
l_Memo = .F.
l_Expandwindow = .F.
Title = ""
prOmpt1 = ""
prOmpt2 = ""
prOmpt3 = ""
prOmpt4 = ""
miN1 = ""
miN2 = ""
miN3 = ""
miN4 = ""
maX1 = ""
maX2 = ""
maX3 = ""
maX4 = ""
sySdate = sySdate()
Memo = ""
_screen.oGlobal.lRptlngSettled = .F.
Do While (.T.)
	Do Case
	Case Lists.li_output==3
		IF NOT DIRECTORY("dde")
			MKDIR dde
		ENDIF
		If (Empty(Lists.li_outfile))
			= alErt(GetLangText("MYLISTS","TA_DEFOUTPUT")+"!")
			l_Outfile = Upper("dde\"+"output.dbf")
		Else
			l_Outfile = Upper("dde\"+Alltrim(Lists.li_outfile))
		Endif
	Case Lists.li_output==4
	Otherwise
		If Empty(Lists.li_frx) .And.  .Not. Empty(Lists.li_basedon)
			l_Report = gcReportdir+Alltrim(DLookup('Lists', ;
				'li_listid = '+SqlCnv(Lists.li_basedon), ;
				'li_frx'))
		Else
			l_Report = gcReportdir+Alltrim(Lists.li_frx)
		Endif
		If ( .Not. File(l_Report)) AND NOT lists.li_exptype = "CSV" && For CSV no frx file needed
			l_Errortext = GetLangText("MYLISTS","TA_NOFRX")
			l_Error = .T.
			Exit
		Endif
	Endcase
	l_memo = .f.
	For l_I = 1 To 4
		l_Promptvar = "Prompt"+Str(l_I, 1)
		&l_Promptvar = Strtran(Evaluate("lists.P" + Str(l_I, 1) + "_lang" + g_Langnum), '*', '')
		If  .Not. Empty(Evaluate("Lists.P"+Str(l_I, 1)+"_lang"+ ;
				g_Langnum)) .And. Evaluate("Lists.P"+Str(l_I, 1)+"_lang"+ ;
				g_Langnum)<>'*'
			l_Numoffields = l_Numoffields+1
		Endif
		l_Type = Evaluate("lists.li_type"+Str(l_I, 1))
		l_Operat = Iif(Evaluate("lists.li_operat"+Str(l_I, 1)) = 2, 2, 1)
		IF l_lExternCall AND NOT EMPTY(EVALUATE("p_oDefaults.Min"+Str(l_I, 1)))
			l_Mindef = "p_oDefaults.Min"+Str(l_I, 1)
		ELSE
			l_Mindef = Trim(Evaluate("lists.li_mindef"+Str(l_I, 1)))
		ENDIF
		IF l_lExternCall AND NOT EMPTY(EVALUATE("p_oDefaults.Max"+Str(l_I, 1)))
			l_Maxdef = "p_oDefaults.Max"+Str(l_I, 1)
		ELSE
			l_Maxdef = Trim(Evaluate("lists.li_maxdef"+Str(l_I, 1)))
		ENDIF
		l_Minvar = "min"+Str(l_I, 1)
		l_Maxvar = "max"+Str(l_I, 1)
		&l_Minvar  = Iif(EMPTY(l_Mindef) OR EMPTY(Evaluate(l_Mindef)), Iif(l_Type == 4, .F., Iif(l_Type == 3, Date(), Iif(l_Type == 2, 0, Space(20)))), Evaluate(l_Mindef))
		&l_Maxvar  = Iif(l_Operat = 1, "", Iif(EMPTY(l_Maxdef) OR EMPTY(Evaluate(l_Maxdef)), &l_Minvar, Evaluate(l_Maxdef)))
		IF l_type == 5
			l_memo= .t.
		ENDIF
		If (l_Operat==2)
			l_Expandwindow = .T.
		Endif
	Endfor
*
	If l_Numoffields > 0 AND NOT l_lExternCall AND NOT p_batchmode AND NOT p_lNoDialog
		IF l_memo
			DO FORM "Forms\RepMemo" WITH lists.li_memo TO lcLiMemo
			IF NOT lists.li_memo == lcLiMemo
				REPLACE li_memo WITH lcLiMemo IN lists
			ENDIF
			RETURN
		ELSE
			DO FORM "forms\repDlg" TO l_result
			IF NOT l_result
				RETURN
			ENDIF
		ENDIF
	ENDIF
*	
	Title = Trim(Evaluate("Lists.Li_Lang"+g_Langnum))+" ("+TRIM(Lists.li_listid)+")  "+ ;
		IIF(Lists.li_buildng AND NOT EMPTY(RptBulding),GetText("HOTSTAT","TXT_FOR_BUILDING")+": "+IIF(RptBulding="*","<"+GetText("COMMON","TXT_ALL")+">",ALLTRIM(RptBulding)),"")
	If Empty(Lists.li_preproc) .And.  .Not. Empty(Lists.li_basedon)
		l_Preproc = Alltrim(DLookup('Lists','li_listid = '+ ;
			SqlCnv(Lists.li_basedon),'li_preproc'))
	Else
		l_Preproc = Alltrim(Lists.li_preproc)
	Endif
	IF NOT EMPTY(l_Preproc)
		lcPpFile = IIF(Lists.li_ddelink < 2, gcReportdir, gcTemplatedir) + STREXTRACT(l_Preproc, "","(", 0, 2)
		IF g_lDevelopment AND FILE(FORCEEXT(lcPpFile,"prg")) OR FILE(FORCEEXT(lcPpFile,"fxp"))
			&l_Preproc
		ELSE
			l_Preproc = ""
		ENDIF
	ENDIF
	If  .Not. Empty(Lists.li_basedon)
		csQlstatement = DLookup('Lists','li_listid = '+ ;
			SqlCnv(Lists.li_basedon),'li_sql')
	Else
		csQlstatement = Lists.li_sql
	Endif
	IF EMPTY(csQlstatement)
		IF l_lExternCall AND PEMSTATUS(p_oDefaults, "aStruct", 5)
			CREATE CURSOR Query FROM ARRAY p_oDefaults.aStruct
			IF ALEN(p_oDefaults.aContent) > 1
				INSERT INTO Query FROM ARRAY p_oDefaults.aContent
			ENDIF
			l_cOutputAlias = ALIAS()
			l_Tally = RECCOUNT()
		ELSE
			l_Tally = 0
		ENDIF
	ELSE
		csQlstatement = SqlParse(csQlstatement)
		csQlstatement = CHRTRAN(csQlstatement, ";"+CRLF, "   ")
		If ( .Not. (" INTO "$csQlstatement))
			If Lists.li_output==3
				If (File(l_Outfile))
					Erase (l_Outfile)
				Endif
				csQlstatement = csQlstatement+" INTO TABLE "+l_Outfile
			Else
				csQlstatement = csQlstatement+" INTO CURSOR QUERY"
			Endif
		Endif
		l_Talk = Set('talk')
		Define Window wtAlk At -2, -2 Size 1, 1
		Set Talk Window wtAlk
		&csQlstatement
		l_cOutputAlias = ALIAS()
		Release Window wtAlk
		Set Talk &l_Talk
		If (lsYserror)
			lsYserror = .F.
			Exit
		Endif
		l_Tally = _Tally
	ENDIF
	If Lists.li_output<>3
		If  .Not. Empty(Lists.li_index)
			Wait Window Nowait 'Sorting...'
			l_Index = Trim(Lists.li_index)
			Select &l_cOutputAlias
			Index On &l_Index Tag Order
			Set Order To Order
			Goto Top
			Wait Clear
		Endif
		If  .Not. Empty(Lists.li_filter)
			Wait Window Nowait 'Filtering...'
			l_Filter = Trim(Lists.li_filter)
			Select &l_cOutputAlias
			Set Filter To &l_Filter
			Count All To l_Tally
			Goto Top
			Wait Clear
		Endif
	Endif
	IF l_Tally=0
		Wait Window Timeout 2 GetLangText("MYLISTS","TA_NORECS")+"!"
		Exit
	ELSE
		MLSaveResults(l_cOutputAlias)
	ENDIF
	If (Lists.li_output=3 .Or. Lists.li_output=4)
		Do Case
		Case Lists.li_output=3
			lcSvfileok = .F.
		Case Lists.li_output=4
			ccSvfile = Sys(2023)+"\BFWMERGE.TXT"
			lcSvfileok = fiLecsv(l_cOutputAlias,ccSvfile,.T.)
			IF lists.li_menu = 8 AND NOT INLIST(lists.li_lettype, 3, 4) &&Only when a Letter is written, call for Description Dialog
				cdOcdescr = geTdocdescr()
			ELSE
				LOCAL lcDescription
				lcDescription = "lists.Li_Lang"+g_Langnum
				cdOcdescr = EVALUATE(lcDescription)
			ENDIF
		Endcase
		Do Case
		Case Lists.li_ddelink==2
			cdOcfile = ""
			l_docname = IIF(_screen.oGlobal.oParam2.pa_docname,ALLTRIM(JUSTSTEM(lists.li_dotfile)),"")+PADL(LTRIM(STR(NextId('Document'))),8,'0')+'.DOC'
			l_cOutputFile = FULLPATH(gcDocumentdir + l_docname)
			l_cQRCodePDF = MLQRCodeCreate()
			If Param.pa_olemtd=2
				lcOldErrorHandlerDefinition=ON('error')
				RELEASE g_WordTest
				PUBLIC g_WordTest
				ON ERROR DO localoleerror IN localoleerror
				LOCAL LStart, LActiveDocName 
				WRDDOC = .null.
				g_WordTest = .T.
				WRDDOC=getobject(,"WORD.APPLICATION")
				g_WordTest = .F.				
				IF ISNULL(wrddoc)
					WRDDOC=Createobject("WORD.APPLICATION")
					IF ISNULL(wrddoc)
						MESSAGEBOX("Install word")
						On Error &lcOldErrorHandlerDefinition
						RETURN
					ELSE
						wrddoc.displayalerts = 0
					endif
				ELSE
					LStart = .t.
					wrddoc.displayalerts = 0
	*				wrddoc.Documents.Close
				ENDIF
				cdotfile="'"+Fullpath(gcTemplatedir+Alltrim(Lists.li_dotfile))+".DOC'"
				cdotfile1="'"+Alltrim(Lists.li_dotfile)+".DOC'"
				ccSvfile="'"+ccSvfile+"'"
				If !Empty(Lists.li_dotfile)
					If lcSvfileok
						cdOcfile="'"+l_cOutputFile+"'"
						ndOcaddrid = 0
						ndOcreserid = 0
						ndOcbonusid = 0
						DO CASE
							CASE INLIST(Lists.li_lettype, 0, 3, 4)
								ndOcaddrid = miN1
							CASE Lists.li_lettype = 1
								ndOcreserid = miN1
							CASE Lists.li_lettype = 2
								ndOcbonusid = miN1
							OTHERWISE
						ENDCASE
						WRDDOC.DOCUMENTS.Open(&cdotfile)
						IF lists.li_delaymm
							LOCAL l_cMergeFile
							l_cMergeFile = SYS(2023)+"\"+SYS(2015)+".TXT"
							COPY FILE (ccSvfile) TO (l_cMergeFile)
							WRDDOC.ACTIVEDOCUMENT.mailmerge.OPENDATASOURCE(l_cMergeFile)
							WRDDOC.ACTIVEDOCUMENT.SaveAs(&cdOcfile)
							LActiveDocName = WRDDOC.ACTIVEDOCUMENT.name
						ELSE
							WRDDOC.ACTIVEDOCUMENT.mailmerge.OPENDATASOURCE(&ccSvfile)
							WRDDOC.ACTIVEDOCUMENT.mailmerge.execute
							WRDDOC.ACTIVEDOCUMENT.SaveAs(&cdOcfile)
							LActiveDocName = WRDDOC.ACTIVEDOCUMENT.name
							WRDDOC.DOCUMENTS(&cdotfile1).Close
						ENDIF
						IF NOT (g_lAutomationMode AND lists.li_attpdf)
							SaveInDocuments(l_cOutputFile, cdOcdescr, @ndOcaddrid, ndOcreserid, ndOcbonusid)
						ENDIF
					Else
						WRDDOC.DOCUMENTS.Add(&cdotfile)
					Endif
				Endif
				If !Empty(Lists.li_ddemcro)
	*RUN MACRO
					cmacro_="'"+Lists.li_ddemcro+"'"
					WRDDOC.Run(&cmacro)
				ENDIF
				IF g_lAutomationMode
					IF lists.li_attpdf
						l_cOutputFile = ConvertToOtherFormat(l_cOutputFile, "PDF")
						IF UPPER(JUSTEXT(l_cOutputFile)) == "PDF"
							SaveInDocuments(l_cOutputFile, cdOcdescr, @ndOcaddrid, ndOcreserid, ndOcbonusid)
						ENDIF
					ENDIF
				ELSE
					IF LStart
						WRDDOC.Visible=.T.
						wrddoc.documents(LActiveDocName ).Activate
						wrddoc.WindowState = 2
						wrddoc.WindowState = 1
					ELSE
						WRDDOC.Visible=.T.
					ENDIF
				ENDIF
				On Error &lcOldErrorHandlerDefinition
				RELEASE g_WordTest
			Else
				= Ddesetoption("TIMEOUT", Param.pa_ddetout)
				= Ddesetoption("SAFETY", .F.)
				l_Channel = Ddeinitiate("WinWord", "System")
				If (l_Channel==-1)
					Wait Window Nowait GetLangText("MYLISTS", ;
						"TA_STARTING")+" MS Word ("+ ;
						ALLTRIM(Param.pa_wordlng)+")..."
					wiNexecute('WinWord.EXE',7)
					l_Secs = Seconds()
					Do While Seconds()-l_Secs<1
						DoEvents
					Enddo
					If (lsYserror)
						lsYserror = .F.
						Exit
					Endif
					For ndDeretry = 1 To 10
						l_Channel = Ddeinitiate("winword", "System")
						DoEvents
						If l_Channel>=1
							Exit
						Endif
					Endfor
					Wait Clear
				Endif
				If (l_Channel==-1)
					l_Errortext = "DDE Error"
					l_Error = .T.
					Exit
				Endif
				Do Case
				Case Substr(Param.pa_wordlng, 1, 3)=="ENG" .Or.  ;
						EMPTY(Param.pa_wordlng)
					If (Alltrim(Lists.li_outfile)=Alias())
						= clOsefile(Alias())
					Endif
					= Ddeexecute(l_Channel, '[AppMinimize]')
					= Ddeexecute(l_Channel, '[AppMaximize]')
					If ( .Not. Empty(Lists.li_dotfile))
						If lcSvfileok
							cdOcfile = l_docname
							ndOcaddrid = 0
							ndOcreserid = 0
							ndOcbonusid = 0
							DO CASE
								CASE INLIST(Lists.li_lettype, 0, 3, 4)
									ndOcaddrid = miN1
								CASE Lists.li_lettype = 1
									ndOcreserid = miN1
								CASE Lists.li_lettype = 2
									ndOcbonusid = miN1
								OTHERWISE
							ENDCASE
							= Ddeexecute(l_Channel,  ;
								'[FileOpen.Name = "'+ ;
								FULLPATH(gcTemplatedir+ ;
								ALLTRIM(Lists.li_dotfile))+'"]')
							= Ddeexecute(l_Channel,  ;
								'[MailMergeOpenDataSource.Name = "'+ ;
								ccSvfile+'"]')
							= Ddeexecute(l_Channel,  ;
								'[MailMergeToDoc]')
							= Ddeexecute(l_Channel,  ;
								'[FileSaveAs.Name = "'+ ;
								FULLPATH(gcDocumentdir+cdOcfile)+'"]')
							= Ddeexecute(l_Channel,  ;
								'[NextWindow]')
							DoEvents
							= Ddeexecute(l_Channel,  ;
								'[DocClose 2]')
							DoEvents
							= Ddeexecute(l_Channel,  ;
								'[PrevWindow]')
							SaveInDocuments(cdOcfile, cdOcdescr, @ndOcaddrid, ndOcreserid, ndOcbonusid)
						Else
							= Ddeexecute(l_Channel,  ;
								'[FileNew.Template = "'+ ;
								FULLPATH(gcTemplatedir+ ;
								ALLTRIM(Lists.li_dotfile))+'"]')
						Endif
					Endif
					If ( .Not. Empty(Lists.li_ddemcro))
						If ( .Not. Ddeexecute(l_Channel,  ;
								'[ToolsMacro.Name = "'+ ;
								ALLTRIM(Lists.li_ddemcro)+'", .run]'))
							If (Ddelasterror()==12)
								l_Errortext =  ;
									"DDE TimeOut, increase the DDETOUT parameter"
							Else
								l_Errortext =  ;
									"DDE Command Error "+ ;
									LTRIM(Str(Ddelasterror()))
							Endif
							l_Error = .T.
						Endif
					Endif
				Case Substr(Param.pa_wordlng, 1, 3)=="DUT"
					If (Alltrim(Lists.li_outfile)=Alias())
						= clOsefile(Alias())
					Endif
					If (Substr(Param.pa_wordlng, 4, 1)=="7")
						= Ddeexecute(l_Channel,  ;
							'[ToepasMinimaliseren]')
					Else
						= Ddeexecute(l_Channel,  ;
							'[ToepasPictogram]')
					Endif
					= Ddeexecute(l_Channel, '[ToepasMaxVenster]')
					If ( .Not. Empty(Lists.li_dotfile))
						If lcSvfileok
							= Ddeexecute(l_Channel,  ;
								'[BestandOpenen.Naam = "'+ ;
								FULLPATH(gcTemplatedir+ ;
								ALLTRIM(Lists.li_dotfile))+'"]')
							= Ddeexecute(l_Channel,  ;
								'[AfdrSamenvGegBestOpenen.Naam = "'+ ;
								ccSvfile+'"]')
							= Ddeexecute(l_Channel,  ;
								'[AfdrSamenvNaarDoc]')
						Else
							= Ddeexecute(l_Channel,  ;
								'[BestandNieuw.Sjabloon = "'+ ;
								FULLPATH(gcTemplatedir+ ;
								ALLTRIM(Lists.li_dotfile))+'"]')
						Endif
					Endif
					If ( .Not. Empty(Lists.li_ddemcro))
						If ( .Not. Ddeexecute(l_Channel,  ;
								'[ExtraMacro.Naam = "'+ ;
								ALLTRIM(Lists.li_ddemcro)+ ;
								'", .starten]'))
							If (Ddelasterror()==12)
								l_Errortext =  ;
									"DDE TimeOut, increase the DDETOUT parameter"
							Else
								l_Errortext =  ;
									"DDE Command Error "+ ;
									LTRIM(Str(Ddelasterror()))
							Endif
							l_Error = .T.
						Endif
					Endif
				Case Substr(Param.pa_wordlng, 1, 3)=="GER"
					If (Alltrim(Lists.li_outfile)=Alias())
						= clOsefile(Alias())
					Endif
					= Ddeexecute(l_Channel, '[AnwMinimieren]')
					= Ddeexecute(l_Channel, '[AnwMaximieren]')
					If ( .Not. Empty(Lists.li_dotfile))
						If lcSvfileok
							= Ddeexecute(l_Channel,  ;
								OEMTOANSI( ;
								'[Dateiôffnen.Name = "'+ ;
								FULLPATH(gcTemplatedir+ ;
								ALLTRIM(Lists.li_dotfile))+'"]'))
							= Ddeexecute(l_Channel,  ;
								OEMTOANSI( ;
								'[SeriendruckôffnenDatenquelle.Name = "'+ ;
								ccSvfile+'"]'))
							= Ddeexecute(l_Channel,  ;
								'[SeriendruckInDokument]')
						Else
							= Ddeexecute(l_Channel,  ;
								'[DateiNeu.DokVorlage = "'+ ;
								FULLPATH(gcTemplatedir+ ;
								ALLTRIM(Lists.li_dotfile))+'"]')
						Endif
					Endif
					If ( .Not. Empty(Lists.li_ddemcro))
						If ( .Not. Ddeexecute(l_Channel,  ;
								OEMTOANSI('[ExtraMakro.Name = "'+ ;
								ALLTRIM(Lists.li_ddemcro)+ ;
								'", .AusfÅhren]')))
							If (Ddelasterror()==12)
								l_Errortext =  ;
									"DDE TimeOut, increase the DDETOUT parameter"
							Else
								l_Errortext =  ;
									"DDE Command Error "+ ;
									LTRIM(Str(Ddelasterror()))
							Endif
							l_Error = .T.
						Endif
					Endif
				Otherwise
					= alErt( ;
						"WORD LANGUAGE NOT DEFINED IN THE PARAMETERS")
				Endcase
				= Ddeterminate(l_Channel)
			ENDIF
			IF NOT EMPTY(l_docname) AND lcSvfileok AND NOT p_lRptGroup
				SendEMail(l_cOutputFile, ndOcaddrid, ndOcreserid, cdOcdescr, ndOcbonusid, l_cQRCodePDF)
				SendFax(l_cOutputFile, ndOcaddrid)
			ENDIF
		CASE Lists.li_ddelink = 3
               LOCAL l_cOutputResultFile, llDeleteTemp
               l_cOutputResultFile = DBF(l_cOutputAlias)
               IF UPPER(JUSTEXT(l_cOutputResultFile)) # "DBF"
                    l_cOutputResultFile = FileTemp("DBF")
                    SELECT * FROM &l_cOutputAlias INTO TABLE (l_cOutputResultFile)
                    IF NOT l_lExternCall
                         llDeleteTemp = .T.
                    ENDIF
               ENDIF
               IF l_lExternCall AND NOT p_Batchmode
                    p_oDefaults.cOutPutFile = l_cOutputResultFile
               ELSE
                    l_cOutputFile = RunPPAutomation(lists.li_liid, l_cOutputResultFile, p_Batchmode)
                    IF llDeleteTemp
                         FileDelete(l_cOutputResultFile)
                    ENDIF
               ENDIF
		CASE Lists.li_ddelink = 4
			LOCAL l_oMailMergeObj, l_cSource, l_cTemplate, l_nReserId, l_nAddrId, l_nBonusId, l_oOpenOfficeDesktop
			IF NOT EMPTY(lists.li_dotfile) AND lcSvfileok
				l_cQRCodePDF = MLQRCodeCreate()
				l_cSource = ccSvfile
				l_cTemplate = FULLPATH(gcTemplatedir+ALLTRIM(lists.li_dotfile)+".ott")
				l_cOutputFile = FULLPATH(gcDocumentdir+IIF(_screen.oGlobal.oParam2.pa_docname,ALLTRIM(JUSTSTEM(lists.li_dotfile)),"")+PADL(LTRIM(STR(NextId("Document"))),8,"0")+".odt")
				l_oMailMergeObj = NEWOBJECT("OpenOfficeMailMerge", "cit_system", "", l_cSource, l_cTemplate)
				IF l_oMailMergeObj.Execute(l_cOutputFile)
					* Must be released because l_oOpenOfficeDesktop object than create his own 
					* instance of OpenOffice.org ServiceManager.
					RELEASE l_oMailMergeObj
					l_nAddrId = IIF(lists.li_lettype = 0, Min1, 0)
					l_nReserId = IIF(lists.li_lettype = 1, Min1, 0)
					l_nBonusId = IIF(lists.li_lettype = 2, Min1, 0)
					SaveInDocuments(l_cOutputFile, cdOcdescr, @l_nAddrId, l_nReserId, l_nBonusId)
					l_oOpenOfficeDesktop = NEWOBJECT("AutoOpenOffice", "cit_system")
					IF NOT l_oOpenOfficeDesktop.OpenDocument(l_cOutputFile)
						Alert(GetLangText("EMBROWS","TXT_OPERATION_UNSUCCESSFULL"))
					ENDIF
					IF NOT p_lRptGroup AND NOT g_lAutomationMode
						SendEMail(l_cOutputFile, l_nAddrId, l_nReserId, cdOcdescr, l_nBonusId, l_cQRCodePDF)
						SendFax(l_cOutputFile, l_nAddrId)
					ENDIF
				ELSE
					Alert(GetLangText("EMBROWS","TXT_OPERATION_UNSUCCESSFULL"))
				ENDIF
			ENDIF
			IF NOT EMPTY(lists.li_ddemcro)		&& RUN MACRO
				IF TYPE("l_oOpenOfficeDesktop") <> "O" 
					l_oOpenOfficeDesktop = NEWOBJECT("AutoOpenOffice", "cit_system")
				ENDIF
				l_oOpenOfficeDesktop.InvokeMacro(ALLTRIM(lists.li_ddemcro))
			ENDIF
		CASE Lists.li_ddelink = 6
			LOCAL lcDotTemplateFile, lcDocOutputFile, lnDocAddrId, lnDocReserId, lnDocBonusId, lcDocDescription
			lnDocAddrId = 0
			lnDocReserId = 0
			lnDocBonusId = 0
			DO CASE
				CASE Lists.li_lettype = 0
					lnDocAddrId = miN1
				CASE Lists.li_lettype = 1
					lnDocReserId = miN1
				CASE Lists.li_lettype = 2
					lnDocBonusId = miN1
				OTHERWISE
			ENDCASE
			lcDotTemplateFile = FULLPATH(gcTemplatedir + FORCEEXT(ALLTRIM(Lists.li_dotfile),"DOTX"))
			lcDocOutputFile = FULLPATH(gcDocumentdir + IIF(_screen.oGlobal.oParam2.pa_docname,ALLTRIM(JUSTSTEM(lists.li_dotfile)),"") + FORCEEXT(PADL(NextId('Document'),8,'0'),"DOCX"))
			lcDocDescription = EVALUATE("Lists.li_lang"+g_Langnum)
			IF Lists.li_output = 3
				IF lists.li_menu = 8 AND NOT INLIST(lists.li_lettype, 3, 4) &&Only when a Letter is written, call for Description Dialog
					lcDocDescription = GetDocDescr()
				ENDIF
				MergeWordDocument(1, l_cOutputAlias, lcDotTemplateFile, lcDocOutputFile)
			ELSE
				MergeWordDocument(2, ccSvfile, lcDotTemplateFile, lcDocOutputFile)
			ENDIF
			SaveInDocuments(lcDocOutputFile, lcDocDescription, @lnDocAddrId, lnDocReserId, lnDocBonusId)
			IF NOT EMPTY(lcDocOutputFile) AND NOT p_lRptGroup
				SendEMail(lcDocOutputFile, lnDocAddrId, lnDocReserId, lcDocDescription, lnDocBonusId)
				SendFax(lcDocOutputFile, lnDocAddrId)
			ENDIF
			l_cOutputFile = lcDocOutputFile
		ENDCASE
		EXIT
	Else
          l_cOutputFile = ""
          crEptext = Left(l_Report, Len(l_Report)-3)+"DBF"
          If (File(crEptext))
               IF NOT _screen.oGlobal.lRptlngSettled
                    g_Rptlng = g_Language
                    g_Rptlngnr = g_Langnum
               ENDIF
               dclose("rePtext")
               Use Shared (crEptext) Alias rePtext In 0
          Endif
          If Between(Lists.li_output, 1, 2)
               IF TYPE("_letters") = "U"
                    _letters = .F.
               ENDIF
               IF NOT p_Batchmode OR llAyoutok OR _letters OR l_lExternCall OR NOT EMPTY(lists.li_expath)
                    DO CASE
                         CASE _letters AND NOT EMPTY(lists.li_lexptyp)
                              l_Output = 3
                              l_nPeferedType = lists.li_lexptyp
                              l_cOutputFile = FULLPATH(gcDocumentdir + IIF(_screen.oGlobal.oParam2.pa_docname,ALLTRIM(JUSTSTEM(EVL(lists.li_dotfile,lists.li_frx))),"") + PADL(NextId('Document'),8,'0'))
                              lcDocDescription = GetDocDescr()
                              l_lSaveInDoc = .T.
                              l_lNotOpenViewer = g_lAutomationMode
                         CASE NOT EMPTY(lists.li_exptype)
                              IF lists.li_etsavdc
                                   l_cOutputFile = FULLPATH(gcDocumentdir + IIF(_screen.oGlobal.oParam2.pa_docname,ALLTRIM(JUSTSTEM(EVL(lists.li_dotfile,lists.li_frx))),"") + PADL(NextId('Document'),8,'0'))
                                   lcDocDescription = GetDocDescr()
                                   l_lSaveInDoc = .T.
                                   l_lNotOpenViewer = .F.
                              ELSE
                                   l_lNotOpenViewer = .T.
                              ENDIF
                              l_Output = 3
                              IF NOT EMPTY(lists.li_exptype)
                                   DO CASE
                                        CASE lists.li_exptype = "XLS"
                                             l_nPeferedType = 1
                                        CASE lists.li_exptype = "DOC"
                                             l_nPeferedType = 2
                                        CASE lists.li_exptype = "PDF"
                                             l_nPeferedType = 3
                                        CASE lists.li_exptype = "XFF"
                                             l_nPeferedType = 10
                                        CASE lists.li_exptype = "CSV"
                                             l_nPeferedType = 11
                                        OTHERWISE
                                             l_nPeferedType = 1
                                   ENDCASE
                              ENDIF
                         CASE p_Batchmode AND l_lExternCall
                              l_Output = 3
                         CASE Lists.li_output = 1
                              LOCAL LSendCaption
                              LSendCaption = ""
*                             cbUttons = "\!"+Button("",GetLangText("MYLISTS", ;
                                   "TXT_PRINTER"),1)+Button("", ;
                                   GetLangText("MYLISTS","TXT_PREVIEW"),2)+ ;
                                   "\?"+Button("",GetLangText("COMMON", ;
                                   "TXT_CANCEL"),-3)
                              LSendCaption = GetLangText("MYLISTS", ;
                                   "TW_OUTPUT")+" ("+ ;
                                   LTRIM(Str(l_Tally))+") "+ ;
                                   GetLangText("MYLISTS","T_RECORDS")
                              DO FORM forms\nodepartureform WITH 1,LSendCaption  TO l_Output
*                             l_Output = seLectmessage(GetLangText("MYLISTS", ;
*                                  "TW_OUTPUT")+" ("+ ;
*                                  LTRIM(Str(l_Tally))+") "+ ;
*                                  GetLangText("MYLISTS","T_RECORDS"),cbUttons)
                         OTHERWISE
                              l_Output = 1
                    ENDCASE
                    glInreport = .T.
                    Do Case
                    Case (l_Output==1)
                         If g_Demo .Or. glTraining
                              Report Form (l_Report) Heading  ;
                                   REPLICATE(cdEmoversion, 3) To  ;
                                   PRINTER Prompt Noconsole
                              Do seTstatus In Setup
                              ldOnesomeprinting = .T.
                         Else
                              Report Form (l_Report) To Printer  ;
                                   PROMPT Noconsole
                              Do seTstatus In Setup
                              ldOnesomeprinting = .T.
                         Endif
                    Case (l_Output==2)
                         If g_Demo .Or. glTraining
                              Report Form (l_Report) Preview  ;
                                   HEADING Replicate(cdEmoversion, 3)  ;
                                   NOCONSOLE
                              Do seTstatus In Setup
                              ldOnesomeprinting = .T.
                         ELSE

                              LOCAL l_cReport, l_cFor, l_lNoListsTable
                              l_cReport = l_Report
                              l_cFor = ".T."
                              l_lNoListsTable = .F.
                              IF g_lUseNewRepPreview
                                   LOCAL loSession, lnRetval, loXFF, loPreview, loExtensionHandler, l_lAutoYield
                                   loSession=EVALUATE([xfrx("XFRX#LISTENER")])
                                   loSession.CallEvaluateContents = 2
                                   loSession.Successor = NEWOBJECT('EffectsListener', 'DynamicFormatting.prg')
                                   loSession.Successor.OutputType = 1
                                   lnRetVal = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
                                   IF lnRetVal = 0
                                        l_lAutoYield = _vfp.AutoYield
                                        _vfp.AutoYield = .T.
                                        REPORT FORM (l_cReport) FOR &l_cFor OBJECT loSession  
                                        loXFF = loSession.oxfDocument 
                                        _vfp.AutoYield = l_lAutoYield
                                        loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
                                        loExtensionHandler.lNoListsTable = l_lNoListsTable
                                        loPreview = CREATEOBJECT("frmMpPreviewerDesk")
                                        loPreview.setExtensionHandler(loExtensionHandler)
                                        loPreview.PreviewXFF(loXFF)
                                        loPreview.show(1)
                                        loExtensionHandler = .NULL.
                                   ENDIF 
                              ELSE
                                   LOCAL LDefForm, loToolbarHnd
                                   loToolbarHnd = NEWOBJECT("ctoolbarhnd","proctoolbar.prg")
                                   loToolbarHnd.DisableToolbars()
                                   LDefForm = .NULL.
                                   do form forms\PREVIEW.SCX NAME LDefForm LINKED
                                   Report Form (l_cReport) FOR &l_cFor Preview NOCONSOLE window PREVIEW
                                   LDefForm.release()
                                   Do seTstatus In Setup
                                   loToolbarHnd.EnableToolbars()
                              ENDIF

                              ldOnesomeprinting = .T.
                         Endif
                    Case (l_Output==3)
                              IF g_lUseNewRepExp
                                   LOCAL loObj, lnRetVal, l_lAutoYield
                                   l_cQRCodePDF = MLQRCodeCreate()
                                   IF l_lExternCall
                                        l_lNotOpenViewer = .T.
                                   ENDIF
                                   loObj = EVALUATE([XFRX("XFRX#LISTENER")])
                                   loObj.CallEvaluateContents = 2
                                   loObj.Successor = NEWOBJECT('EffectsListener', 'DynamicFormatting.prg')
                                   loObj.Successor.OutputType = 1
                                   IF EMPTY(l_cOutputFile)
                                        l_cOutputFile = _screen.oGlobal.oRG.GetExportPath(lists.li_expath)+_screen.oGlobal.oRG.GetFileName(lists.li_listid, lists.li_expfile, lists.li_expfnod)
                                   ENDIF
                                   IF NOT EMPTY(l_cArchive)
                                        l_cArchive = _screen.oGlobal.oRG.GetExportPath()+l_cArchive
                                   ENDIF
                                   IF EMPTY(l_nPeferedType)
                                        LOCAL ARRAY l_aDialog(1,8)
                                        l_aDialog(1,1) = "exportmode"
                                        l_aDialog(1,2) = "Excel;Word;PDF;HTML;TXT;JPG;OpenOffice Writer;OpenOffice Calc;RTF;XFF"
                                        l_aDialog(1,3) = "1"
                                        l_aDialog(1,4) = "@R"
                                        IF Dialog("Export", "W‰hlen", @l_aDialog)
                                             l_nPeferedType = l_aDialog(1,8)
                                        ENDIF
                                   ENDIF
                                   l_lAutoYield = _vfp.AutoYield
                                   _vfp.AutoYield = .T.
                                   DO CASE
                                        CASE EMPTY(l_nPeferedType)
                                        CASE l_nPeferedType = 1
                                             * Excel
                                             l_cOutputFile = l_cOutputFile + ".xls"
                                             lnRetVal = xfrxsettings("XFSetupExcel", loObj, l_cOutputFile, l_lNotOpenViewer, l_cArchive)
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 2
                                             * Word
                                             l_cOutputFile = l_cOutputFile + ".doc"
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"FDOC",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 3
                                             * PDF
                                             l_cOutputFile = l_cOutputFile + ".pdf"
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"PDF",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 4
                                             * HTML
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"HTML",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 5
                                             * TXT
                                             l_cOutputFile = l_cOutputFile + ".txt"
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"PLAIN",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 6
                                             * JPG
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,,,,,"XFF",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                                  local loXFF
                                                  loXFF = loObj.oxfDocument
                                                  LOCAL lnI, lnJpegQuality
                                                  lnJpegQuality = 80
                                                  FOR lnI = 1 TO loXFF.pagecount
                                                       loXFF.savePicture(l_cOutputFile+"-Seite"+ALLTRIM(STR(lnI))+".jpg","jpg",lnI,lnI,24,lnJpegQuality)
                                                  ENDFOR
                                                  alert("Bilder gespeichert.")
                                             ENDIF
                                        CASE l_nPeferedType = 7
                                             * OO Writer
                                             l_cOutputFile = l_cOutputFile + ".odt"
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"ODT",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 8
                                             * OO Calc
                                             l_cOutputFile = l_cOutputFile + ".ods"
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"ODS",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 9
                                             * RTF
                                             l_cOutputFile = l_cOutputFile + ".rtf"
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"FRTF",l_cArchive,NOT EMPTY(l_cArchive))
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                        CASE l_nPeferedType = 10
                                             * XFF
                                             l_cOutputFile = l_cOutputFile + ".xff"
                                             lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"XFF")
                                             IF lnRetVal = 0
                                                  Report Form (l_Report) OBJECT loObj
                                             ENDIF
                                             loObj = .NULL. && We must release it here, to release created tables, an zip it
                                             l_cZipFileName = MLZipXFF(l_cArchive,l_cOutputFile)
                                        CASE l_nPeferedType = 11
                                             l_nSelect = SELECT()
                                             l_cOutputFile = l_cOutputFile + ".csv"
                                             SELECT (l_cOutputAlias)
                                             COPY TO (l_cOutputFile) CSV
                                             SELECT (l_nSelect)
                                   ENDCASE

                                   * Release XFRX Object, to close cursor, and let send XFF data
                                   loObj = .NULL.

                                   IF l_lSaveInDoc
                                        lnDocAddrId = IIF(lists.li_lettype = 0, Min1, 0)
                                        lnDocReserId = IIF(lists.li_lettype = 1, Min1, 0)
                                        lnDocBonusId = IIF(lists.li_lettype = 2, Min1, 0)
                                        SaveInDocuments(l_cOutputFile, lcDocDescription, @lnDocAddrId, lnDocReserId, lnDocBonusId)
                                        IF NOT EMPTY(l_cOutputFile) AND NOT p_lRptGroup AND NOT g_lAutomationMode
                                             SendEMail(l_cOutputFile, lnDocAddrId, lnDocReserId, lcDocDescription, lnDocBonusId, l_cQRCodePDF)
                                             SendFax(l_cOutputFile, lnDocAddrId)
                                        ENDIF
                                   ELSE
                                        IF NOT l_lExternCall AND lists.li_expsend AND NOT EMPTY(lists.li_expmail)
                                             LOCAL l_oAttach, l_cExpFileToSend
                                             l_cExpFileToSend = ""
                                             l_oAttach = CREATEOBJECT("collection")

                                             IF l_nPeferedType = 10
                                                  IF NOT EMPTY(l_cZipFileName) AND FILE(l_cZipFileName)
                                                       l_cExpFileToSend = l_cZipFileName
                                                  ENDIF
                                             ELSE
                                                  l_cExpFileToSend = FULLPATH(l_cOutputFile)
                                             ENDIF
                                             IF emprop.ep_usesmtp
                                                  procemail("PESendWithBlat", ;
                                                             ALLTRIM(lists.li_expmail), ;
                                                             "", ;
                                                             ALLTRIM(emprop.ep_from), ;
                                                             ALLTRIM(emprop.ep_server), ;
                                                             ALLTRIM(emprop.ep_user), ;
                                                             ALLTRIM(emprop.ep_pass), ;
                                                             procemail("PEgetsignature"), ;
                                                             TRIM(g_hotel) + " " + TRANSFORM(DATETIME()), ;
                                                             l_cExpFileToSend, ;
                                                             emprop.ep_log, ;
                                                             _screen.oGlobal.choteldir + "autoemail.log", ;
                                                             .F., ;
                                                             .F., ;
                                                             .T.)
                                             ELSE
                                                  IF NOT EMPTY(l_cExpFileToSend)
                                                       l_oAttach.Add(FULLPATH(l_cExpFileToSend),"1")
                                                  ENDIF
                                                  procemail("PESendMail", ALLTRIM(lists.li_expmail), l_oAttach)
                                             ENDIF
                                        ENDIF
                                   ENDIF
                                   
                                   _vfp.AutoYield = l_lAutoYield
                              ELSE
                                   LOCAL l_oPrinting AS printing
                                   l_oPrinting = CREATEOBJECT("printform")
                                   l_oPrinting.cCaption = EVALUATE("lists.li_lang"+g_langnum)
                                   l_oPrinting.Printfrxtoxls(l_Report, ALIAS())
                              ENDIF
                    Endcase
               Else
                    If g_Demo .Or. glTraining
                         Report Form (l_Report) Heading  ;
                              REPLICATE(cdEmoversion, 3) To Printer  ;
                              NOCONSOLE
                         Do seTstatus In Setup
                         ldOnesomeprinting = .T.
                    Else
                         Report Form (l_Report) To Printer Noconsole
                         Do seTstatus In Setup
                         ldOnesomeprinting = .T.
                    Endif
               Endif
          Endif
		glInreport = .F.
		If (glErrorinreport)
			= alErt( ;
				"Some error in report definition, please check the functions!" ;
				)
			glErrorinreport = .F.
		Endif
		If (ldOnesomeprinting)
			If ( .Not. Empty(Lists.li_postpro))
				l_Preproc = Alltrim(Lists.li_postpro)
				&l_Preproc
			Endif
		Endif
		= clOsefile("RepText")
		= clOsefile("outPut")
		= clOsefile("PreProc")
		Exit
	Endif
Enddo
If (l_Error)
	= alErt(l_Errortext+"!")
Endif
FOR nfIlehandle = 1 TO AUSED(aCurrFileAreas)
	caReaname = aCurrFileAreas(nfIlehandle,1)
	lnRow = ASCAN(acFileareas, caReaname, 1, 0, 1, 15)
	IF lnRow = 0
		IF caReaname # "QUERY"
			CloseFile(caReaname)
		ENDIF
	ELSE
		ADEL(acFileareas, lnRow)
	Endif
ENDFOR
FOR nfIlehandle = 1 TO ALEN(acFileareas,1)
	If NOT EMPTY(acFileareas(nfIlehandle,1)) AND NOT USED(acFileareas(nfIlehandle,1))
		OpenFile(.F., acFileareas(nfIlehandle,1))
	ENDIF
NEXT
*** Entered while decimal was '.' after calling Word
DO setsystempoint IN ini
If Set('point')=','
	Set Separator To '.'
	csEp1000 = '.'
Else
	Set Separator To ','
	csEp1000 = ','
Endif
If (Param.pa_currdec>0)
	gcCurrcy = Right(Replicate("9", 16)+"."+Replicate("9",  ;
		paRam.pa_currdec), 16)
	gcCurrcydisp = gcCurrcy
Else
	gcCurrcy = Replicate("9", 16)
	gcCurrcydisp = Replicate("999"+csEp1000, 4)+"999"
Endif

***
Select (l_Oldarea)
RETURN l_cOutputFile
ENDPROC
*
	Function vcHoicelist
	Clear Read
	Return .T.
Endfunc
*
	Procedure Batches
	Private All Like l_*
	LOCAL l_nNumberOfBrowse, l_oFormData
*
	IF WEXIST("frmRepList")
		RELEASE WINDOW frmRepList
	ENDIF
*
	l_For = ".t."
	l_While = 'pl_label = "BATCH"'
	l_Area = Select()

	Select piCklist
	= Seek(Padr("BATCH", 10))

	COUNT ALL FOR &l_while .and. &l_for TO l_nNumberOfBrowse
	l_oFormData = CREATEOBJECT("cdatatunnel")
	l_oFormData.AddProperty("nArea", l_Area)
	DO FORM forms\repMain WITH 2, l_oFormData, ;
		GetLangText("MYLISTS","TW_BATCHES"), ;
		"pl_lang"+g_Langnum, GetLangText("MYLISTS","TH_DESCRIPT"), ;
		l_for, l_while, Max(Min(l_nNumberOfBrowse, 20), 3)
*
	restoreBatchEnv(l_Area)
	Return
Endproc
*
PROCEDURE restoreBatchEnv
LPARAMETERS l_Area
	Select (l_Area)
ENDPROC
*
	Procedure vBatch
	LPARAMETERS lp_lExportAndSend, lp_cEMails, lp_cBatchCode, lp_lSmtp
*	Parameter p_Choice
	Private All Like l_*
	l_Batch = Alltrim(piCklist.pl_charcod)
	l_Oldarea = Select()
	Select Lists
	Goto Top In "lists"
*	Do Case
*	Case p_Choice==1
*	Case p_Choice==2
	IF lp_lExportAndSend
		_screen.oGlobal.oRG.BatchExportAndSend(lp_cEMails, lp_cBatchCode, lp_lSmtp)
	ELSE
		Scan
			If ((","+l_Batch+",")$(","+Alltrim(Lists.li_batch)+","))
				If Empty(Lists.li_when) .Or. Evaluate(Lists.li_when)
					Do prTreport With .T.
				Endif
			Endif
		Endscan
		= reLations()
	ENDIF
*		KEYBOARD '{ESC}'
*	Endcase
	Select (l_Oldarea)
	Return
Endproc
*
	Function Hours
	Private All Like l_*
	l_Arrhrs = Round(((Val(Substr(hiStres.hr_arrtime, 1, 2)))*3600+ ;
		(Val(Substr(hiStres.hr_arrtime, 4, 2)))*60)/3600, 0)
	l_Dephrs = Round(((Val(Substr(hiStres.hr_deptime, 1, 2)))*3600+ ;
		(Val(Substr(hiStres.hr_deptime, 4, 2)))*60)/3600, 0)
	l_Dephrs = Iif(hiStres.hr_arrdate==hiStres.hr_depdate .And. l_Dephrs< ;
		l_Arrhrs, l_Dephrs+24, l_Dephrs)
	Return (l_Dephrs-l_Arrhrs)
Endfunc
*
	Function Revenue
	Private l_Oldarea, l_Oldrec, l_Retval
	l_Oldarea = Select()
	l_Retval = 0
	Select hiStpost
	l_Oldord = Order("histpost")
	l_Oldrec = Recno("histpost")
	Set Order In "histpost" To 1
	If Seek(hiStres.hr_reserid, "histpost")
		Sum hiStpost.hp_amount To l_Retval Rest For  .Not.  ;
			hiStpost.hp_split .And.  .Not. hiStpost.hp_cancel .And.  ;
			hiStpost.hp_artinum>0 While hiStpost.hp_reserid==hiStres.hr_reserid
	Endif
	Set Order In "histpost" To l_Oldord
	Goto l_Oldrec In "histpost"
	Select (l_Oldarea)
	Return Round(l_Retval, Param.pa_currdec)
Endfunc
*
	Function WbConvert
	Parameter ccOntents
	Return Oemtoansi(Alltrim(ccOntents))
Endfunc
*
	Function seArchlist
	Private nsElectedbutton
	Private cdEscription
	Private nmEnunumber
	Private crEportname
	Private clEvel
	Private cbUttons
	Private nrEcord
	Dimension acChecks[18]
	Dimension alChecks[18]
	Store "" To acChecks
	Store .F. To alChecks
	Do geTchecks In MainMenu With acChecks, alChecks, "REPORT"
	For ni = 17 To 1 Step -1
		acChecks[ni+1] = acChecks(ni)
	Endfor
	acChecks[1] = GetLangText("MYLISTS","TXT_BILL")
	nrEcord = Recno("Lists")
	nsElectedbutton = 1
	cdEscription = Space(30)
	nmEnunumber = 0
	crEportname = Space(30)
Define Window wsRclist From 0, 0 To 8, 80 Font "Arial", 10 Noclose  ;
	NOZOOM Title chIldtitle(GetLangText("MYLISTS","TXT_SRCLIST")) Nomdi Double
Move Window wsRclist Center
Activate Window wsRclist
clEvel = ""
cbUttons = "\!"+Button(clEvel,GetLangText("COMMON","TXT_OK"),1)+Button(clEvel, ;
	GetLangText("COMMON","TXT_CANCEL"),-2)
= paNelborder()
= txTpanel(1.25,3,20,GetLangText("MYLISTS","TXT_MENU"),0)
= txTpanel(2.75,3,20,GetLangText("MYLISTS","TXT_DESCRIP"),0)
= txTpanel(4,3,20,GetLangText("MYLISTS","TXT_REPORTNAME"),0)
@ 1, 25 Get nmEnunumber Size 1, 18 From acChecks Function "^" Color  ;
	RGB(0,0,0,255,255,255)
@ 2.750, 25 Get cdEscription Size 1, 30 Picture "@KB" When Empty(nmEnunumber)
@ 4, 25 Get crEportname Size 1, 30 Picture "@KB"
@ 1, 60 Get nsElectedbutton Style "B" Size nbUttonheight, 15 Function  ;
	"*"+"V" Picture cbUttons
Read Cycle Modal
Release Window wsRclist
= chIldtitle("")
If (nsElectedbutton==1)
	Do Case
	Case  .Not. Empty(nmEnunumber)
		= Seek(Str(nmEnunumber-1, 2), "Lists")
	Case  .Not. Empty(cdEscription)
		Select Lists
		Locate For Upper(Evaluate("Lists.Li_Lang"+g_Langnum))= ;
			UPPER(Alltrim(cdEscription))
	Case  .Not. Empty(crEportname)
		Select Lists
		Locate For Upper(Alltrim(Lists.li_frx))= ;
			UPPER(Alltrim(crEportname))
	Endcase
	If (Eof())
		Goto nrEcord
	Else
		g_Refreshall = .T.
	Endif
Endif
Return .T.
Endfunc
*
	Function vButton
	If ( .Not. Lists.li_custom)
		If (Alltrim(g_Userid)=="SUPERVISOR")
			Show Object 2 Enable
			Show Object 6 Enable
			Show Object 8 Enable
			Show Object 11 Enable
		Else
			Show Object 2 Disable
			Show Object 6 Disable
			Show Object 8 Disable
			Show Object 11 Disable
		Endif
	Else
		Show Object 2 Enable
		Show Object 6 Enable
		Show Object 8 Enable
		Show Object 11 Enable
	Endif
	Return .T.
Endfunc
*
	Function rePorttexts
	Private crEportfile
	Private naReaactive
	Private ctRanto
	Private adLg
	Dimension adLg[1, 8]
	adLg[1, 1] = "language"
	adLg[1, 2] = 'Language'
	adLg[1, 3] = "Space(3)"
	adLg[1, 4] = "!!!"
	adLg[1, 5] = 6
	adLg[1, 6] =  ;
		"Inlist(language, 'ENG','DUT','GER','FRE', 'ITA', 'SER', 'POR', 'POL')"
	adLg[1, 7] = ""
	adLg[1, 8] = ""
	If diAlog('Translate to','',@adLg)
		ctRanto = adLg(1,8)
	Else
		Return
	Endif
	crEportfile = Alltrim(Lists.li_frx)
	If ( .Not. File(gcReportdir+crEportfile))
		= alErt(GetLangText("MYLISTS","TA_NOFRX"))
	Else
		naReaactive = Select()
		Use Exclusive (gcReportdir+crEportfile) Alias Report In 0
		cdBffile = gcReportdir+Substr(crEportfile, 1, At(".", crEportfile))+"Dbf"
		If ( .Not. File(cdBffile))
			= alErt('Creating translation file!')
			Create Table (cdBffile) (la_label C (10), la_lang C (3),  ;
				la_text C (120))
			Use
		Endif
		Use Exclusive (cdBffile) Alias rePtext In 0
		Select Report
		Goto Top
		Do While ( .Not. Eof("Report"))
			If ( .Not. Empty(Report.Expr))
				If (At("REPOTEXT(", Upper(Report.Expr))>0 .Or. At("GetLangText(",  ;
						UPPER(Report.Expr))>0)
					Select rePtext
					clAbel = Upper(Alltrim(geTlabel(Report.Expr)))
					Locate For Alltrim(Upper(rePtext.la_label))== ;
						ALLTRIM(Upper(clAbel)) .And.  ;
						ALLTRIM(Upper(ctRanto))== ;
						ALLTRIM(Upper(rePtext.la_lang))
					If (Eof())
						Append Blank
						Replace rePtext.la_label With clAbel
						Replace rePtext.la_lang With ctRanto
					Endif
				Endif
			Endif
			Skip 1 In Report
		Enddo
		If (File("Tmp\English.Dbf"))
			Erase "Tmp\English.Dbf"
		Endif
		Select rePtext
		Copy To Tmp\English All For rePtext.la_lang=="ENG"
		Use Exclusive Tmp\English Alias English In 0
		If (ctRanto=="ENG")
			Select English
			Goto Top
			Browse Fields English.la_label :H = "Label" :R : 15,  ;
				English.la_text :H = ctRanto : 30
			Goto Top
			Do While ( .Not. Eof("English"))
				Select rePtext
				Locate For rePtext.la_label==English.la_label .And.  ;
					rePtext.la_lang==English.la_lang
				If (Found())
					If ( .Not. Empty(English.la_text))
						Replace rePtext.la_text With English.la_text
					Else
						Delete
					Endif
				Endif
				Skip 1 In English
			Enddo
			Select rePtext
			Pack
		Else
			Select rePtext
			If (Reccount()==0)
				Copy To "Tmp\Second" Structure
			Else
				Copy To Tmp\Second All For rePtext.la_lang==ctRanto
			Endif
			Use Exclusive Tmp\Second Alias Second In 0
			Select Second
			Index On Upper(la_label) To Tmp\Second
			Set Order To 1
			Select English
			Goto Top
			Do While ( .Not. Eof("English"))
				Select Second
				Locate For Second.la_lang==ctRanto .And. Second.la_label== ;
					English.la_label
				If ( .Not. Found())
					Append Blank
					Replace Second.la_lang With ctRanto
					Replace Second.la_text With English.la_text
					Replace Second.la_label With English.la_label
				Endif
				Skip 1 In English
			Enddo
			Select English
			Set Relation To Upper(English.la_label) Into Second
			Goto Top
			Browse Fields English.la_label :H = "Label" :R : 15,  ;
				English.la_text :H = "English" : 30, Second.la_text :H =  ;
				ctRanto : 30
			Goto Top
			Do While ( .Not. Eof("English"))
				Select rePtext
				Locate For rePtext.la_label==English.la_label .And.  ;
					rePtext.la_lang==English.la_lang
				If (Found())
					If ( .Not. Empty(English.la_text))
						Replace rePtext.la_text With English.la_text
					Else
						Delete
					Endif
				Endif
				Skip 1 In English
			Enddo
			Select English
			Pack
			Select Second
			Goto Top
			Do While ( .Not. Eof("Second"))
				Select rePtext
				Locate For rePtext.la_label==Second.la_label .And.  ;
					rePtext.la_lang==Second.la_lang
				If ( .Not. Found())
					Append Blank
					Replace rePtext.la_label With Second.la_label
					Replace rePtext.la_lang With Second.la_lang
				Endif
				If ( .Not. Empty(Second.la_text))
					Replace rePtext.la_text With Second.la_text
				Else
					Delete
				Endif
				Skip 1 In Second
			Enddo
			Select rePtext
			Pack
		Endif
		= clOsefile("RepText")
		= clOsefile("Report")
		= clOsefile("English")
		= clOsefile("Second")
		Select (naReaactive)
	Endif
	Return .T.
Endfunc
*
PROCEDURE RunPPAutomation
LPARAMETERS tnListID, tcOutputResultFile, tlDontShow
LOCAL lcOldErrorHnd, llCloseLists, lcXltTemplateFile, lcXlsOutputFile, lcPpFile, lcOutputAlias, lcPpAutamation

lcOldErrorHnd = ON("Error")
ON ERROR DO LocalOLEError
lcXlsOutputFile = ""
IF NOT USED("lists") AND OpenFileDirect(,"lists")
     llCloseLists = .T.
ENDIF
IF NOT EMPTY(tnListID) AND USED("lists") AND DLocate("lists", "li_liid = " + SqlCnv(tnListID)) AND ;
          lists.li_ddelink > 1 AND NOT EMPTY(lists.li_preproc) AND FILE(tcOutputResultFile)
     lcPpFile = gcTemplatedir + STREXTRACT(ALLTRIM(lists.li_preproc), "","(", 0, 2)
     IF NOT EMPTY(lcPpFile) AND NOT EMPTY(lists.li_dotfile)
          IF g_lDevelopment AND FILE(FORCEEXT(lcPpFile,"prg")) OR FILE(FORCEEXT(lcPpFile,"fxp"))
               lcXltTemplateFile = LOWER(FULLPATH(gcTemplatedir + ALLTRIM(lists.li_dotfile)))
               IF FILE(lcXltTemplateFile)
                    lcXlsOutputFile = _screen.oGlobal.oRG.GetExportPath()+_screen.oGlobal.oRG.GetFileName(lists.li_listid, lists.li_expfile,lists.li_expfnod)
                    lcXlsOutputFile = FORCEEXT(lcXlsOutputFile, "xlsx")
                    lcOutputAlias = SYS(2015)
                    lcPpAutamation = "RunAutomation"
                    USE (tcOutputResultFile) IN 0 AGAIN ALIAS &lcOutputAlias
                    DO (lcPpAutamation) IN (lcPpFile) WITH lcOutputAlias, lcXltTemplateFile, lcXlsOutputFile, tlDontShow
                    USE IN &lcOutputAlias
               ELSE
                    Alert(Str2Msg(GetLangText("MYLISTS","TA_NOXLT"),"%s",lcXltTemplateFile))
               ENDIF
          ENDIF
     ENDIF
ENDIF
IF llCloseLists
     DClose("lists")
ENDIF
ON ERROR &lcOldErrorHnd

RETURN lcXlsOutputFile
ENDPROC
*
PROCEDURE MLSaveResults
	LPARAMETERS lp_cOutputAlias
	LOCAL l_nSelect, l_cName, l_cFile, l_cCurResult, l_cCurTmp, l_cAliasSavedResults
	l_cCurResult = lp_cOutputAlias
	IF NOT (lists.li_saveres AND USED(l_cCurResult))
		RETURN .T.
	ENDIF
	l_nSelect = SELECT()
	l_cCurTmp = SYS(2015)
	l_cAliasSavedResults = SYS(2015)
	l_cName = PADL(TRANSFORM(RECNO("lists")),4,"0")+PADL(lists.li_listid,8,"_")
	l_cFile = ADDBS(_screen.oGlobal.cReportResultsDir) + l_cName
	
	IF NOT FILE(FORCEEXT(l_cFile,"dbf"))
		* Create table
		SELECT sysdate() AS __DATE, * FROM (l_cCurResult) WHERE .F. INTO TABLE (l_cFile)
		INDEX ON __DATE TAG TAG1
		IF l_nSelect <> SELECT()
			* Table created, close it, to flush it on disk
			dclose(ALIAS())
		ENDIF
	ENDIF
	
	IF openfiledirect(,l_cName,l_cAliasSavedResults,ADDBS(_screen.oGlobal.cReportResultsDir))
		* first delete all previous results for current day
		sqldelete(l_cAliasSavedResults,"__DATE = " + sqlcnv(sysdate()),.T.)
		SELECT sysdate() AS __DATE, * FROM (l_cCurResult) INTO CURSOR (l_cCurTmp)
		SELECT (l_cAliasSavedResults)
		APPEND FROM DBF(l_cCurTmp)
		dclose(l_cCurTmp)
		dclose(l_cAliasSavedResults)
	ENDIF
	SELECT (l_nSelect)
	RETURN .T.
ENDPROC
*
PROCEDURE MLSaveResultsPack
	LOCAL l_nSelect, l_cCurName, l_nFound, l_cName, i, l_cAliasSavedResults, l_lCloseLists
	l_nSelect = SELECT()
	IF NOT USED("lists")
		= openfile(.F.,"lists")
		l_lCloseLists = .T.
	ENDIF
	l_cCurName = sqlcursor([SELECT COUNT(*) FROM lists WHERE li_saveres],"",.F.,"",.NULL.,.T.)
	IF USED(l_cCurName) AND RECCOUNT(l_cCurName)>0
		l_nFound = ADIR(l_aResFiles,ADDBS(_screen.oGlobal.cReportResultsDir)+"*.dbf")
		FOR i = 1 TO l_nFound
			l_cName = FORCEEXT(l_aResFiles(i,1),"")
			l_cAliasSavedResults = SYS(2015)
			IF openfiledirect(.T.,l_cName,l_cAliasSavedResults,ADDBS(_screen.oGlobal.cReportResultsDir))
				SELECT (l_cAliasSavedResults)
				PACK
				INDEX ON __DATE TAG TAG1
				dclose(l_cAliasSavedResults)
			ENDIF
		ENDFOR
	ENDIF
	dclose(l_cCurName)
	IF l_lCloseLists
		dclose("lists")
	ENDIF
	SELECT (l_nSelect)
	RETURN .T.
ENDPROC
*
	Function geTlabel
	Parameter csTring
	Private npOs
	If (At('"~', csTring)==1)
		csTring = Substr(csTring, 2)
	Else
		npOs = At('LIST', csTring)
		csTring = Substr(csTring, npOs+6)
		npOs = At('"', csTring)
		csTring = Substr(csTring, npOs+1)
		csTring = Substr(csTring, 1, At('"', csTring)-1)
	Endif
	Return csTring
Endfunc
*
	Function puTlabels
	Parameter crEportname
	Private ncUrrent
	ncUrrent = Select()
	Use Exclusive (crEportname) Alias Report In 0
	Select Report
	Do While ( .Not. Eof("Report"))
		If (At('"~', Report.Expr)==1)
			clAbel = Substr(Report.Expr, 3)
			Replace Report.Expr With 'RepoText("LIST", "'+clAbel+')'
		Endif
		Skip 1 In Report
	Enddo
	= clOsefile("Report")
	Select (ncUrrent)
	Return .T.
Endfunc
*
	Function geTlabels
	Parameter crEportname
	Private ncUrrent
	ncUrrent = Select()
	Use Exclusive (crEportname) Alias Report In 0
	Select Report
	Do While ( .Not. Eof("Report"))
		Do Case
		Case At('REPOTEXT("', Upper(Report.Expr))==1
			clAbel = Upper(Alltrim(geTlabel(Report.Expr)))
			Replace Report.Expr With '"~'+clAbel+'"'
		Case At('GetLangText("', Upper(Report.Expr))==1
			clAbel = Upper(Alltrim(geTlabel(Report.Expr)))
			Replace Report.Expr With '"~'+clAbel+'"'
		Endcase
		Skip 1 In Report
	Enddo
	= clOsefile("Report")
	Select (ncUrrent)
	Return .T.
Endfunc
*
	Function geTddelink
	Private cdDelink
	cdDelink = Button("",GetLangText("MYLISTS","TXT_NONE"),1)+Button("", ;
		GetLangText("MYLISTS","TXT_WORD"),2)+Button("",GetLangText("MYLISTS", ;
		"TXT_EXCEL"),-3)
	Return cdDelink
Endfunc
*
	Function isPreproc
	Parameter cfUnction
	Private cvErsion
	Private cpPversion
	cvErsion = "0.00"
	cpPversion = "PpVersion"
	cfUnction = Substr(cfUnction, 1, At("(", cfUnction)-1)
	Do (cpPversion) In (cfUnction) With cvErsion
	Return .T.
Endfunc
*
	Function PpVer
	Parameter cfUnction
	Private cvErsion
	Private cpPversion
	Private cfXp, coLderr
	cvErsion = "0.00"
	cpPversion = "PpVersion"
	cfUnction = Substr(cfUnction, 1, At("(", cfUnction)-1)
	cfXp = gcReportdir+cfUnction+".FXP"
	If File(cfXp)
		coLderr = On('error')
		On Error Do LOCALERR
		Do (cpPversion) In (cfUnction) With cvErsion
		On Error &coLderr
	Endif
	Return cvErsion
Endfunc
*
	Procedure LOCALERR
	Return
Endproc
*
	Procedure scRminiedit
	Private adLg
	Dimension adLg[4, 8]
	adLg[1, 1] = "batch"
	adLg[1, 2] = GetLangText("MYLISTS","T_BATCH")
	adLg[1, 3] = "Lists.li_batch"
	adLg[1, 4] = Replicate("!", 40)
	adLg[1, 5] = 30
	adLg[1, 6] = ""
	adLg[1, 7] = ""
	adLg[1, 8] = ''
	adLg[2, 1] = "bwhen"
	adLg[2, 2] = GetLangText("MYLISTS","T_WHEN")
	adLg[2, 3] = "Lists.li_when"
	adLg[2, 4] = Replicate("!", 40)
	adLg[2, 5] = 30
	adLg[2, 6] = ""
	adLg[2, 7] = ""
	adLg[2, 8] = ''
	adLg[3, 1] = "usergrp"
	adLg[3, 2] = GetLangText("MYLISTS","T_USRGRP")
	adLg[3, 3] = "Lists.li_usrgrp"
	adLg[3, 4] = Replicate("!", 40)
	adLg[3, 5] = 30
	adLg[3, 6] = ""
	adLg[3, 7] = ""
	adLg[3, 8] = ''
	adLg[4, 1] = "hide"
	adLg[4, 2] = GetLangText("MYLISTS","TXT_HIDE")
	adLg[4, 3] = "Lists.li_hide"
	adLg[4, 4] = '@*C'
	adLg[4, 5] = 30
	adLg[4, 6] = ""
	adLg[4, 7] = ""
	adLg[4, 8] = .F.
	If diAlog(GetLangText("MYLISTS","TW_REPORTS"),'',@adLg)
		Replace Lists.li_batch With adLg(1,8), Lists.li_when With adLg(2,8),  ;
			Lists.li_usrgrp With adLg(3,8), Lists.li_hide With adLg(4,8)
		Flush
	Endif
Endproc
*
	Function geTdocdescr
	LangforDescr = "lists.Li_Lang"+g_Langnum
	IF g_lAutomationMode
		LangforDescr = ALLTRIM(EVALUATE(LangforDescr))
	ELSE
		Do Form "forms\docdescriptionform" With &LangforDescr To LangforDescr
	ENDIF
	If Empty(LangforDescr)
		Return ''
	Else
		Return LangforDescr
	Endif

	Return
	Private adLg
	LangforDescr = "lists.Li_Lang"+g_Langnum
	Dimension adLg[1, 8]
	adLg[1, 1] = "descr"
	adLg[1, 2] = GetLangText("MYLISTS","T_DESCRIPT")
	adLg[1, 3] = "Space(40)"
	adLg[1, 4] = Replicate("X", 40)
	adLg[1, 5] = 50
	adLg[1, 6] = ""
	adLg[1, 7] = ""
	adLg[1, 8] = Alltrim(&LangforDescr)&&''
****************
*LangforDescr = "lists.Li_Lang"+g_Langnum
*lists.la_langx
*  adLg[1, 4] = ALLTRIM(&LangforDescr)
****************
	If diAlog(GetLangText("MYLISTS","TW_DOCDESCR"),'',@adLg)
		Return Alltrim(adLg(1,8))
	Else
		Return ''
	Endif
Endfunc
*
PROCEDURE localoleerror
=AERROR(errarray)
DO case
	CASE errarray(1)=1426
*		asdf = 0
*		MESSAGEBOX("Install office aplication",48)
	CASE errarray(1)=1429 AND errarray(7)=4605
	
	CASE errarray(1)=1429 AND errarray(7)=4608
		MESSAGEBOX("Microsoft Office 2007 with add-in for conversion to PDF format must be installed.", 48)
	CASE errarray(1)=1429 AND errarray(7)=4198
		MESSAGEBOX("Add-in for conversion to PDF format must be installed.", 48)
	CASE errarray(1)=1429 AND NOT ISNULL(errarray(3)) AND NOT ISNULL(errarray(4))
		MESSAGEBOX(errarray(3)+' in '+errarray(4), 48)
	OTHERWISE
		MESSAGEBOX(TRANSFORM(errarray(1))+': '+errarray(2), 48)
ENDCASE
RETURN&& TO mybrowse
*
FUNCTION GetLetterDescription
LPARAMETERS lp_nAddressID, lp_nReserID
***************************************************
* lp_nAddressID - addres id
* lp_nReserID - reservation id
*
* from given aaddress id search for langnum and letter description
* return description for chosen letter, in the language of the guest
*
* IMPORTANT lists table expect to be on the right record
***************************************************
LOCAL l_cLang, l_nLangNum, l_cReserID, l_cDescriptionText, l_cTextMacro
LOCAL l_nPicklistRecNo, l_nAddressRecNo

l_cDescriptionText = ""
l_cReserID = ALLTRIM(STR(lp_nReserID,12,3))
l_nPicklistRecNo = RECNO("picklist")
l_nAddressRecNo = RECNO("address")

IF SEEK(lp_nAddressID,"address","Tag1")
	l_cLang = ALLTRIM(address.ad_lang)
ELSE
	GO l_nAddressRecNo IN address
	RETURN l_cDescriptionText
ENDIF

IF SEEK("LANGUAGE  "+l_cLang,"picklist","Tag4")
	l_nLangNum = picklist.pl_numcod
ELSE
	l_nLangNum = g_Langnum
ENDIF
l_cTextMacro = "lists.li_lang"+ALLTRIM(STR(l_nLangNum))
l_cDescriptionText = " "+GetLangText("COMMON","TXT_NUMBER",l_cLang)+" "+l_cReserID
l_cDescriptionText = ALLTRIM(&l_cTextMacro)+IIF(EMPTY(lp_nReserID),"",l_cDescriptionText)

GO l_nPicklistRecNo IN picklist
GO l_nAddressRecNo IN address

RETURN l_cDescriptionText
ENDFUNC
*
PROCEDURE SaveInDocuments
LPARAMETERS lp_cDocName, lp_cDocDescr, lp_nAddrId, lp_nReserId, lp_nBmsAcctId, lp_lExternal
LOCAL l_nArea, l_cDocType, l_lDocumentTableUsed

l_nArea = SELECT()

DO CASE
	CASE lp_lExternal
		lp_nBmsAcctId = 0
		lp_nReserId = 0
	CASE lists.li_menu = 8
		IF EMPTY(lp_nAddrId) AND NOT EMPTY(lp_nReserId) AND SEEK(lp_nReserId, "reservat", "tag1")
			IF EMPTY(reservat.rs_compid)
				lp_nAddrId = reservat.rs_addrid
			ELSE
				lp_nAddrId = reservat.rs_compid
			ENDIF
		ENDIF
	CASE lists.li_menu = 14
		IF EMPTY(lp_nAddrId)	&& Save voucher only for specified address.
			RETURN
		ENDIF
		lp_nReserId = 0
		lp_nBmsAcctId = 0
	OTHERWISE
		lp_nAddrId = 0
		lp_nReserId = 0
		lp_nBmsAcctId = 0
ENDCASE

l_lDocumentTableUsed = USED("document")
IF DOpen("Document")
	DO CASE
		CASE lp_lExternal
			l_cDocType = "EXTERNAL"
		CASE UPPER(JUSTEXT(lp_cDocName)) == "PDF"
			l_cDocType = "PDFDOC"
		CASE UPPER(JUSTEXT(lp_cDocName)) == "DOC"	&& lists.li_ddelink = 2
			l_cDocType = "WORDDOC"
		CASE UPPER(JUSTEXT(lp_cDocName)) == "XLS"	&& lists.li_ddelink = 3
			l_cDocType = "EXCELDOC"
		CASE UPPER(JUSTEXT(lp_cDocName)) == "ODT"	&& lists.li_ddelink = 4
			l_cDocType = "WRITERDOC"
		CASE UPPER(JUSTEXT(lp_cDocName)) == "ODS"	&& lists.li_ddelink = 5
			l_cDocType = "CALCDOC"
		CASE UPPER(JUSTEXT(lp_cDocName)) == "DOCX"	&& lists.li_ddelink = 6
			l_cDocType = "WORDDOCX"
		OTHERWISE
			l_cDocType = ""
	ENDCASE
	INSERT INTO document (dc_file, dc_descr, dc_userid, dc_date, dc_time, dc_addrid, dc_bbid, dc_reserid, dc_type) ;
		VALUES (JUSTFNAME(lp_cDocName), lp_cDocDescr, g_Userid, DATE(), TIME(), lp_nAddrId, lp_nBmsAcctId, lp_nReserId, l_cDocType)
	IF CURSORGETPROP("Buffering","document")=1
		FLUSH
	ELSE
		=TABLEUPDATE(0, .T., "document")
	ENDIF
	IF NOT l_lDocumentTableUsed
		DCLose("Document")
	ENDIF
ENDIF

SELECT (l_nArea)
ENDPROC
*
PROCEDURE SendEMail
LPARAMETERS lp_cDocName, lp_nAddrId, lp_nReserId, lp_cDocDescr, lp_nBonusId, lp_cPDF
LOCAL i, l_nArea, l_lUnbindWhenFinish, l_cDocName, l_cAttachments, l_cAttachment, l_nLiId

IF lists.li_menu = 8 AND lists.li_email
	l_cAttachments = ""
	FOR i = 1 TO GETWORDCOUNT(lp_cDocName,",")
		l_cDocName = GETWORDNUM(lp_cDocName,i,",")
		IF NOT lists.li_attpdf OR UPPER(JUSTEXT(l_cDocName)) == "PDF"
			l_cAttachment = l_cDocName
		ELSE
			l_cAttachment = ConvertToOtherFormat(l_cDocName, "PDF")
			IF UPPER(JUSTEXT(l_cAttachment)) == "PDF"
				SaveInDocuments(l_cAttachment, lp_cDocDescr, lp_nAddrId, lp_nReserId, lp_nBonusId)
			ENDIF
		ENDIF
		l_cAttachments = l_cAttachments + IIF(EMPTY(l_cAttachments), "", ",") + l_cAttachment
	NEXT
	IF NOT EMPTY(lp_cPDF)
		l_cAttachments = l_cAttachments + IIF(EMPTY(l_cAttachments), "", ",") + lp_cPDF
	ENDIF
	IF NOT EMPTY(lists.li_attcahm)
		IF NOT USED("emprop")
			= openfiledirect(.F.,"emprop")
		ENDIF
		FOR i = 1 TO GETWORDCOUNT(lists.li_attcahm,CHR(3))
			l_cAttachment = GETWORDNUM(lists.li_attcahm,i,CHR(3))

			l_nLiId = isattachmentareport(l_cAttachment)
			IF l_nLiId > 0
				l_cAttachment = lettersgeneratepdf(l_nLiId, reservat.rs_rsid)
			ELSE
				l_cAttachment = FULLPATH(ADDBS(ALLTRIM(emprop.ep_attpath))+"L_"+PADL(TRANSFORM(lists.li_liid),5,"0")+"_"+l_cAttachment)
			ENDIF

			l_cAttachments = l_cAttachments + IIF(EMPTY(l_cAttachments), "", ",") + l_cAttachment
		ENDFOR
	ENDIF
	g_oWinEvents.aMyLists(1) = l_cAttachments
	g_oWinEvents.aMyLists(2) = lp_nAddrId
	g_oWinEvents.aMyLists(5) = GetLetterDescription(lp_nAddrId, lp_nReserId)
	g_oWinEvents.aMyLists(6) = lists.li_liid
	g_oWinEvents.aMyLists(7) = lp_nReserId
	l_lUnbindWhenFinish = .T.
	g_oWinEvents.BindEvents(_VFP.HWnd, WM_ACTIVATE, LETTERS, l_lUnbindWhenFinish)
ENDIF
ENDPROC
*
PROCEDURE isattachmentareport
LPARAMETERS l_cAttachment, l_nLiId
l_nLiId = 0
* Check if attachment is actually a letter report, which should be executed and sent as PDF
IF UPPER(LEFT(l_cAttachment,3))=="LI_" AND UPPER(JUSTEXT(l_cAttachment)) == "FRX"
	TRY
		l_nLiId = INT(VAL(STREXTRACT(UPPER(l_cAttachment), "LI_", ".FRX")))
	CATCH
	ENDTRY
	IF l_nLiId > 0
		l_nLnId = dlookup("lists","li_liid = " + TRANSFORM(l_nLiId), "li_liid")
	ENDIF
ENDIF
RETURN l_nLiId
ENDPROC
*
PROCEDURE lettersgeneratepdf
LPARAMETERS lp_nLiId, lp_nRsId, l_cOutputFile
LOCAL o
l_cOutputFile = ""
g_lAutomationMode = .T.
o = NEWOBJECT("cquickreser","procreservat.prg")
l_cOutputFile = o.lettersgeneratepdf(lp_nLiId, lp_nRsId)
o = .NULL.
g_lAutomationMode = .F.
RETURN l_cOutputFile
ENDPROC
*
PROCEDURE SendFax
LPARAMETERS lp_cDocName, lp_nAddrId
LOCAL l_cMessage, l_oFaxServer, l_oFaxDocument, l_oWordApp, l_nDocNo
LOCAL l_cOldErrorHandlerDefinition

IF param.pa_fax AND FILE(lp_cDocName) AND NOT EMPTY(lp_nAddrId) AND SEEK(lp_nAddrId, "address", "tag1") AND NOT EMPTY(address.ad_fax)
	l_cMessage = GetLangText("MYLISTS","TXT_FAX_QUESTION") + lp_cDocName
	IF MsgBox(l_cMessage, GetLangText("MYLISTS","TXT_FAX_CAPTION"), 4+32+256) = 6
		l_cOldErrorHandlerDefinition = ON('error')
		RELEASE g_WordTest
		PUBLIC g_WordTest
		ON ERROR DO LocalOLEError
		l_oWordApp = .NULL.
		g_WordTest = .T.
		l_oWordApp = GETOBJECT(,"Word.Application")
		g_WordTest = .F.
		IF NOT ISNULL(l_oWordApp)
			FOR l_nDocNo = 1 TO l_oWordApp.Documents.Count
				IF l_oWordApp.Documents.Item(l_nDocNo).Name == JUSTFNAME(lp_cDocName)
					l_oWordApp.Documents.Item(l_nDocNo).Close()
					EXIT
				ENDIF
			ENDFOR
		ENDIF
		l_oFaxServer = .NULL.
		l_oFaxServer = CREATEOBJECT("FaxServer.FaxServer")
		IF ISNULL(l_oFaxServer)
			MsgBox(GetLangText("MYLISTS","TXT_FAX_INSTALL"), GetLangText("MYLISTS","TXT_FAX_CAPTION"), 16)
		ELSE
			l_oFaxServer.Connect(WinPC())
			l_oFaxDocument = l_oFaxServer.CreateDocument(lp_cDocName)
			l_oFaxDocument.FaxNumber = ALLTRIM(address.ad_fax)
			l_oFaxDocument.DisplayName = "Document sent by Briliant"
			l_oFaxDocument.RecipientName = ALLTRIM(address.ad_lname)
			l_oFaxDocument.Send()
		ENDIF
		IF NOT ISNULL(l_oWordApp) AND l_oWordApp.Documents.Count = 0
			l_oWordApp.Quit()
		ENDIF
		ON ERROR &l_cOldErrorHandlerDefinition
		RELEASE g_WordTest
	ENDIF
ENDIF
ENDPROC
*
PROCEDURE MergeWordDocument
LPARAMETERS lp_nSourceType, lp_cSourceName, lp_cTemplateName, lp_cMergedDocumentName
LOCAL l_oMailMerge, l_cTempPath, l_cAlias

l_oMailMerge = CREATEOBJECT("MailMerge")
l_cAlias = JUSTSTEM(lp_cTemplateName)

DO CASE
	CASE lp_nSourceType = 1		&& output table
		l_cTempPath = SYS(2023) + "\"
		DELETE FILE (l_cTempPath + l_cAlias + ".*")
		SELECT * FROM &lp_cSourceName INTO TABLE (l_cTempPath + l_cAlias + ".dbf")
		USE IN &lp_cSourceName
	CASE lp_nSourceType = 2		&& BFWMERGE.TXT
		l_oMailMerge.lUseCSVSource = .T.
		l_oMailMerge.cDataSrc = lp_cSourceName
	OTHERWISE
ENDCASE

l_oMailMerge.lMergeExecute = .T.
l_oMailMerge.cAppTitle = _Screen.Caption						&& application name, used in Alerts	
l_oMailMerge.nWordProc = 1										&& word processor (1 = Word 6+; 2 = CommaDelim; or user-defined (see below); default = 1)
l_oMailMerge.cDocName = LOWER(FULLPATH(lp_cTemplateName))		&& input document template name
l_oMailMerge.nNewDoc = IIF(FILE(l_oMailMerge.cDocName), 2, 1)	&& is it a new doc (1 = new, 2 = existing; default = 1)
l_oMailMerge.cMergedDocName = lp_cMergedDocumentName			&& output (merged) document name
l_oMailMerge.nTemplate = 1										&& type of main document (Word only, 1 = form letter; 2 = label; 3 = envelope; 4 = catalog; default = 1)
l_oMailMerge.MakeOutput()										&& do the merge

IF USED(l_cAlias)
	USE IN &l_cAlias
ENDIF
ENDPROC
*
PROCEDURE ConvertToOtherFormat
LPARAMETERS lp_cDocName, lp_cFormat
LOCAL l_cAttachment, l_oWordApp, l_cOldErrorHandlerDefinition, l_cDocAlias, l_nFormatCode, l_lConvert, l_nDocNo, ;
		l_oOpenOfficeDesktop, l_lSuccess

l_lConvert = .T.
DO CASE
	CASE NOT FILE(lp_cDocName)
		l_lConvert = .F.
	CASE EMPTY(lp_cFormat)
		l_lConvert = .F.
	CASE lp_cFormat == "DOCX"
		l_nFormatCode = wdFormatDocumentDefault
	CASE lp_cFormat == "PDF"
		l_nFormatCode = wdFormatPDF
	CASE lp_cFormat == "HTML"
		l_nFormatCode = wdFormatHTML
	CASE lp_cFormat == "MHTML"
		l_nFormatCode = wdFormatWebArchive
	CASE lp_cFormat == "XPS"
		l_nFormatCode = wdFormatXPS
	OTHERWISE
		l_lConvert = .F.
ENDCASE

IF l_lConvert
	l_cAttachment = FORCEEXT(lp_cDocName, lp_cFormat)
	IF Lists.li_ddelink = 4
		* OOO
		l_oOpenOfficeDesktop = NEWOBJECT("OpenOfficeMailMerge", "cit_system", "", lp_cDocName, "")
		l_lSuccess = l_oOpenOfficeDesktop.ConvertToPDF(l_cAttachment)
	ELSE
		l_cOldErrorHandlerDefinition = ON("Error")
		RELEASE g_WordTest
		PUBLIC g_WordTest
		ON ERROR DO LocalOLEError
		l_oWordApp = .NULL.
		g_WordTest = .T.
		l_oWordApp = GETOBJECT(,"Word.Application")
		g_WordTest = .F.
		IF NOT ISNULL(l_oWordApp)
			l_lOpened = .F.
			l_cDocAlias = JUSTFNAME(lp_cDocName)
			FOR l_nDocNo = 1 TO l_oWordApp.Documents.Count
				IF l_oWordApp.Documents(l_nDocNo).Name == l_cDocAlias
					l_lOpened = .T.
					EXIT
				ENDIF
			NEXT
			IF NOT l_lOpened
				l_oWordApp.Documents.Open(lp_cDocName)
			ENDIF
			l_oWordApp.Documents(l_cDocAlias).SaveAs(l_cAttachment, l_nFormatCode)
			IF NOT INLIST(lp_cFormat, "PDF") AND FILE(l_cAttachment)
				l_oWordApp.Documents(JUSTFNAME(l_cAttachment)).Close()
			ENDIF
		ENDIF
		ON ERROR &l_cOldErrorHandlerDefinition
		RELEASE g_WordTest
	ENDIF
	IF NOT FILE(l_cAttachment)
		l_cAttachment = lp_cDocName
	ENDIF
ELSE
	l_cAttachment = lp_cDocName
ENDIF

RETURN l_cAttachment
ENDPROC
*
PROCEDURE PreviewOrPrintReport
LPARAMETERS lp_oDefaults
LOCAL l_nListID

_screen.oGlobal.oRG.PreviewOrPrintReport(, lp_oDefaults)
IF NOT EMPTY(lp_oDefaults.cOutPutFile)
     IF NOT EMPTY(lp_oDefaults.cSystemID)
          l_nListID = DLookUp("lists", "li_listid = " + SqlCnv(lp_oDefaults.cSystemID), "li_liid")
          RunPPAutomation(l_nListID, lp_oDefaults.cOutPutFile)
     ENDIF
     IF UPPER(JUSTPATH(lp_oDefaults.cOutPutFile)) == UPPER(JUSTPATH(FileTemp()))
          FileDelete(lp_oDefaults.cOutPutFile)
     ENDIF
ENDIF
ENDPROC
*
PROCEDURE MLZipXFF

* We must zip 3 files for XFF type!
* When not sent zip archive name, name would be generated from lp_cOutputFile.
* Returns "" when not success.

LPARAMETERS lp_cArchive, lp_cOutputFile
LOCAL l_oAttach, l_cZipFileName, l_cFileToZip, l_cZipFile, l_cZipPath

l_cZipFileName = ""

IF NOT EMPTY(lp_cOutputFile)
     l_cFileToZip = FULLPATH(lp_cOutputFile)
     IF FILE(l_cFileToZip)
          IF EMPTY(lp_cArchive)
               l_cZipFileName = FULLPATH(FORCEEXT(lp_cOutputFile,".zip"))
          ELSE
               l_cZipFileName = lp_cArchive
          ENDIF
          l_cZipFile = JUSTFNAME(l_cZipFileName)
          l_cZipPath = ADDBS(JUSTPATH(l_cZipFileName))
          ZipOpen(l_cZipFile, l_cZipPath, .T.)

          IF FILE(l_cFileToZip)
               ZipFile(l_cFileToZip, .F.)
          ENDIF

          l_cFileToZip = FULLPATH(FORCEEXT(lp_cOutputFile,"fpt"))
          IF FILE(l_cFileToZip)
               ZipFile(l_cFileToZip, .F.)
          ENDIF

          l_cFileToZip = FULLPATH(FORCEEXT(lp_cOutputFile,"cdx"))
          IF FILE(l_cFileToZip)
               ZipFile(l_cFileToZip, .F.)
          ENDIF

          ZipClose()
     ENDIF

ENDIF

RETURN l_cZipFileName
ENDPROC
*
PROCEDURE MLSavePDFAsReservationDocument
LPARAMETERS lp_nReserId, lp_cFile, lp_cDescript
LOCAL l_cDocFile, l_cFullName
IF NOT EMPTY(lp_nReserId) AND NOT EMPTY(lp_cFile)
	IF EMPTY(lp_cDescript)
		lp_cDescript = ""
	ENDIF
	l_cDocFile = PADL(LTRIM(STR(NextId("Document"))),8,"0")+".PDF"
	l_cFullName = FULLPATH(gcDocumentdir+l_cDocFile)
	COPY FILE (lp_cFile) TO (l_cFullName)
	sqlinsert("document","dc_file, dc_reserid, dc_descr, dc_userid, dc_date, dc_time",;
		1,;
		sqlcnv(l_cDocFile,.T.)+","+sqlcnv(lp_nReserId,.T.)+","+sqlcnv(lp_cDescript,.T.)+","+sqlcnv(g_userid,.T.)+","+sqlcnv(DATE(),.T.)+","+sqlcnv(TIME(),.T.))
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE MLGetLangCode
LPARAMETERS lp_nReserId, lp_nAddrId
LOCAL l_cSql, l_cCur, l_nSelect, l_cLangCode
l_cLangCode = ""
l_nSelect = SELECT()

DO CASE
	CASE NOT EMPTY(lp_nReserId)

		TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
			SELECT rs_reserid, ;
				NVL(g.ad_addrid,0) AS g_addrid, NVL(g.ad_lang,'') AS g_lang, ;
				NVL(c.ad_addrid,0) AS c_addrid, NVL(c.ad_lang,'') AS c_lang ;
				FROM reservat ;
				LEFT JOIN address g ON rs_addrid = g.ad_addrid ;
				LEFT JOIN address c ON rs_compid = c.ad_addrid ;
				WHERE rs_reserid = <<sqlcnv(lp_nReserId,.T.)>>
		ENDTEXT

		l_cCur = sqlcursor(l_cSql,,,,,.T.)
		IF USED(l_cCur) AND RECCOUNT()>0
			l_cLangCode = IIF(EMPTY(g_addrid),c_lang,g_lang)
		ENDIF
		dclose(l_cCur)
	CASE NOT EMPTY(lp_nAddrId)
		TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
			SELECT NVL(ad_lang,'') AS c_lang ;
				FROM address ;
				WHERE ad_addrid = <<sqlcnv(lp_nAddrId,.T.)>>
		ENDTEXT

		l_cCur = sqlcursor(l_cSql,,,,,.T.)
		IF USED(l_cCur) AND RECCOUNT()>0
			l_cLangCode = c_lang
		ENDIF
		dclose(l_cCur)
ENDCASE

SELECT (l_nSelect)
RETURN l_cLangCode
ENDPROC
*
PROCEDURE MLShowReportDialog
LPARAMETERS lp_cFrx
LOCAL LSendCaption, l_cReport, l_cFor, l_lNoListsTable, l_Report, loObj, lnRetVal, l_lAutoYield, l_Tally, l_cOutputFile, l_cArchive, l_lNotOpenViewer

l_Report = lp_cFrx
l_Tally = RECCOUNT()

LSendCaption = ""
LSendCaption = GetLangText("MYLISTS", "TW_OUTPUT")+" ("+ LTRIM(Str(l_Tally))+") "+ GetLangText("MYLISTS","T_RECORDS")
DO FORM forms\nodepartureform WITH 1,LSendCaption  TO l_Output
Do CASE
     CASE (l_Output==1)
          Report Form (l_Report) To Printer PROMPT Noconsole
     CASE (l_Output==2)
          l_cReport = l_Report
          l_cFor = ".T."
          l_lNoListsTable = .T.
          IF g_lUseNewRepPreview
               LOCAL loSession, lnRetval, loXFF, loPreview, loExtensionHandler, l_lAutoYield
               loSession=EVALUATE([xfrx("XFRX#LISTENER")])
               loSession.CallEvaluateContents = 2
               loSession.Successor = NEWOBJECT('EffectsListener', 'DynamicFormatting.prg')
               loSession.Successor.OutputType = 1
               lnRetVal = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
               IF lnRetVal = 0
                    l_lAutoYield = _vfp.AutoYield
                    _vfp.AutoYield = .T.
                    REPORT FORM (l_cReport) FOR &l_cFor OBJECT loSession  
                    loXFF = loSession.oxfDocument 
                    _vfp.AutoYield = l_lAutoYield
                    loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
                    loExtensionHandler.lNoListsTable = l_lNoListsTable
                    loPreview = CREATEOBJECT("frmMpPreviewerDesk")
                    loPreview.setExtensionHandler(loExtensionHandler)
                    loPreview.PreviewXFF(loXFF)
                    loPreview.show(1)
                    loExtensionHandler = .NULL.
               ENDIF 
          ELSE
               LOCAL LDefForm, loToolbarHnd
               loToolbarHnd = NEWOBJECT("ctoolbarhnd","proctoolbar.prg")
               loToolbarHnd.DisableToolbars()
               LDefForm = .NULL.
               do form forms\PREVIEW.SCX NAME LDefForm LINKED
               Report Form (l_cReport) FOR &l_cFor Preview NOCONSOLE window PREVIEW
               LDefForm.release()
               Do seTstatus In Setup
               loToolbarHnd.EnableToolbars()
          ENDIF
     CASE (l_Output==3)
               loObj = EVALUATE([XFRX("XFRX#LISTENER")])
               loObj.CallEvaluateContents = 2
               loObj.Successor = NEWOBJECT('EffectsListener', 'DynamicFormatting.prg')
               loObj.Successor.OutputType = 1
               l_cOutputFile = _screen.oGlobal.oRG.GetExportPath()+TTOC(DATETIME(),1)+"-"+JUSTSTEM(l_Report)
               l_cArchive = _screen.oGlobal.oRG.GetExportPath()
               LOCAL ARRAY l_aDialog(1,8)
               l_aDialog(1,1) = "exportmode"
               l_aDialog(1,2) = "Excel;Word;PDF;HTML;TXT;JPG;OpenOffice Writer;OpenOffice Calc;RTF;XFF"
               l_aDialog(1,3) = "1"
               l_aDialog(1,4) = "@R"
               IF Dialog("Export", "W‰hlen", @l_aDialog)
                    l_nPeferedType = l_aDialog(1,8)
               ENDIF
               l_lAutoYield = _vfp.AutoYield
               _vfp.AutoYield = .T.
               DO CASE
                    CASE EMPTY(l_nPeferedType)
                    CASE l_nPeferedType = 1
                         * Excel
                         l_cOutputFile = l_cOutputFile + ".xls"
                         lnRetVal = xfrxsettings("XFSetupExcel", loObj, l_cOutputFile, l_lNotOpenViewer, l_cArchive)
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 2
                         * Word
                         l_cOutputFile = l_cOutputFile + ".doc"
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"FDOC",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 3
                         * PDF
                         l_cOutputFile = l_cOutputFile + ".pdf"
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"PDF",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 4
                         * HTML
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"HTML",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 5
                         * TXT
                         l_cOutputFile = l_cOutputFile + ".txt"
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"PLAIN",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 6
                         * JPG
                         lnRetVal = loObj.SetParams(l_cOutputFile,,,,,,"XFF",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                              local loXFF
                              loXFF = loObj.oxfDocument
                              LOCAL lnI, lnJpegQuality
                              lnJpegQuality = 80
                              FOR lnI = 1 TO loXFF.pagecount
                                   loXFF.savePicture(l_cOutputFile+"-Seite"+ALLTRIM(STR(lnI))+".jpg","jpg",lnI,lnI,24,lnJpegQuality)
                              ENDFOR
                              alert("Bilder gespeichert.")
                         ENDIF
                    CASE l_nPeferedType = 7
                         * OO Writer
                         l_cOutputFile = l_cOutputFile + ".odt"
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"ODT",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 8
                         * OO Calc
                         l_cOutputFile = l_cOutputFile + ".ods"
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"ODS",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 9
                         * RTF
                         l_cOutputFile = l_cOutputFile + ".rtf"
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"FRTF",l_cArchive,NOT EMPTY(l_cArchive))
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                    CASE l_nPeferedType = 10
                         * XFF
                         l_cOutputFile = l_cOutputFile + ".xff"
                         lnRetVal = loObj.SetParams(l_cOutputFile,,l_lNotOpenViewer,,,,"XFF")
                         IF lnRetVal = 0
                              Report Form (l_Report) OBJECT loObj
                         ENDIF
                         loObj = .NULL. && We must release it here, to release created tables, an zip it
                         l_cZipFileName = MLZipXFF(l_cArchive,l_cOutputFile)
                    CASE l_nPeferedType = 11
                         l_nSelect = SELECT()
                         l_cOutputFile = l_cOutputFile + ".csv"
                         SELECT (l_cOutputAlias)
                         COPY TO (l_cOutputFile) CSV
                         SELECT (l_nSelect)
               ENDCASE
               * Release XFRX Object, to close cursor, and let send XFF data
               loObj = .NULL.
               _vfp.AutoYield = l_lAutoYield
ENDCASE

RETURN .T.
ENDPROC
*

PROCEDURE MLQRCodeCreate
LOCAL l_cQRCode, l_cPDF

l_cPDF = ""

* Alow only if QrCodeDoorKeyActive is active
IF NOT _screen.oGlobal.lQrCodeDoorKeyActive
	RETURN l_cPDF
ENDIF

IF NOT (lists.li_menu = 8 AND lists.li_email)
	RETURN l_cPDF
ENDIF

l_cQRCode = MLQRCodeGet()
l_cPDF = MLQRCodeGenPicture(l_cQRCode)

RETURN l_cPDF
ENDPROC
*
PROCEDURE MLQRCodeGet
LOCAL l_cQRCode, l_oJSON, l_cDoorKey, l_oObj

l_cQRCode = ""

* Check if valid reservat user field is defined in QrCodeDoorKeyReservatUserField
IF EMPTY(_screen.oGlobal.cQrCodeDoorKeyReservatUserField) OR ;
		NOT INLIST(_screen.oGlobal.cQrCodeDoorKeyReservatUserField, ;
		"rs_usrres0", "rs_usrres1", "rs_usrres2", "rs_usrres3", "rs_usrres4", "rs_usrres5", ;
		"rs_usrres6", "rs_usrres7", "rs_usrres8", "rs_usrres9")
	RETURN l_cQRCode
ENDIF

* Check if Door key was already issued
IF EMPTY(EVALUATE("reservat." + _screen.oGlobal.cQrCodeDoorKeyReservatUserField))
	l_cDoorKey = STRTRAN(LOWER(CFGetGuid()),"-","")
	* Store Door key in reservat user field
	REPLACE (_screen.oGlobal.cQrCodeDoorKeyReservatUserField) WITH l_cDoorKey IN reservat
ELSE
	l_cDoorKey = EVALUATE("reservat." + _screen.oGlobal.cQrCodeDoorKeyReservatUserField)
ENDIF

* Generate QRCode
l_oJSON = NEWOBJECT("json","common\progs\json.prg")
l_oObj = CREATEOBJECT("Empty")
ADDPROPERTY(l_oObj,"door_key", l_cDoorKey)
ADDPROPERTY(l_oObj,"arrival",reservat.rs_arrdate)
ADDPROPERTY(l_oObj,"departure",reservat.rs_depdate)
ADDPROPERTY(l_oObj,"created",DATETIME())
ADDPROPERTY(l_oObj,"reserid",reservat.rs_reserid)
ADDPROPERTY(l_oObj,"rsid",reservat.rs_rsid)
l_cQRCode = l_oJSON.stringify(l_oObj)
* Convert to UTF8
l_cQRCode = STRCONV(l_cQRCode,9)

RETURN l_cQRCode
ENDPROC
*
PROCEDURE MLQRCodeGenPicture
LPARAMETERS lp_cQRCode
LOCAL l_cPDFFile, l_cHTMLFile, l_cURL, l_cQrCodePictureFile, l_cHOST, l_cCmd, lcResult, l_cPhone, l_cIsOK
PRIVATE p_oQRData

l_cPDFFile = ""
p_oQRData = .NULL.

IF EMPTY(lp_cQRCode)
	RETURN l_cPDFFile
ENDIF

IF NOT FILE(gcReportdir+"doorkey.frx")
	alert(stRfmt(GetLangText("AR","TA_NOFRX"),"doorkey.frx"))
	RETURN l_cPDFFile
ENDIF

l_cQrCodePictureFile = _screen.oGlobal.oQRCodeGen.QRBarcodeImage(lp_cQRCode,,12,2)
l_cPDFFile = FORCEEXT(l_cQrCodePictureFile, "pdf")
l_cHTMLFile = FORCEEXT(l_cQrCodePictureFile, "html")

* Store URL
IF NOT EMPTY(_screen.oGlobal.cQrCodeHost)
	l_cHOST = _screen.oGlobal.cQrCodeHost + IIF(RIGHT(_screen.oGlobal.cQrCodeHost,1)="/", "", "/")
	l_cURL = l_cHOST + "codes/"
	l_cURL = l_cURL + JUSTFNAME(l_cHTMLFile)
	IF NOT (EMPTY(_screen.oGlobal.cQrCodeURLReservatUserField) OR ;
			NOT INLIST(_screen.oGlobal.cQrCodeURLReservatUserField, ;
			"rs_usrres0", "rs_usrres1", "rs_usrres2", "rs_usrres3", "rs_usrres4", "rs_usrres5", ;
			"rs_usrres6", "rs_usrres7", "rs_usrres8", "rs_usrres9"))
		REPLACE (_screen.oGlobal.cQrCodeURLReservatUserField) WITH l_cURL IN reservat
	ENDIF
ENDIF

* p_oQRData object reference is used in report
p_oQRData = CREATEOBJECT("Empty")
ADDPROPERTY(p_oQRData, "cFile", l_cQrCodePictureFile)
ADDPROPERTY(p_oQRData, "nReserId", reservat.rs_reserid)
ADDPROPERTY(p_oQRData, "nRsId", reservat.rs_rsid)
ADDPROPERTY(p_oQRData, "nAddrId", address.ad_addrid)
ADDPROPERTY(p_oQRData, "cTitle", address.ad_title)
ADDPROPERTY(p_oQRData, "cLastName", address.ad_lname)
ADDPROPERTY(p_oQRData, "cFirstName", address.ad_fname)
ADDPROPERTY(p_oQRData, "dArrDate", reservat.rs_arrdate)
ADDPROPERTY(p_oQRData, "dDepDate", reservat.rs_depdate)
ADDPROPERTY(p_oQRData, "cRoom", reservat.rs_rmname)
ADDPROPERTY(p_oQRData, "cRoomNum", reservat.rs_roomnum)
ADDPROPERTY(p_oQRData, "cURL", l_cURL)

* Generate PDF and HTML file with QR Code
PrintReport(ADDBS(gcReportdir)+"doorkey.frx",,,,"PDF",l_cPDFFile)
PrintReport(ADDBS(gcReportdir)+"doorkey.frx",,,,"HTML",l_cHTMLFile)

* Fix encoding
l_cHTMLContents = FILETOSTR(l_cHTMLFile)
l_cHTMLContents = STRCONV(STRTRAN(STRTRAN(l_cHTMLContents, [charset=windows-1250"], [charset=utf-8"]), [charset=windows-1252"], [charset=utf-8"]) ,9)
STRTOFILE(l_cHTMLContents, l_cHTMLFile, 0)

* Send HTML file to server
TEXT TO l_cCmd TEXTMERGE NOSHOW PRETEXT 15
curl -X POST -F auth=oblaK123 -F rawdata=@<<l_cHTMLFile>> "<<l_cHOST + "upload.php">>"
ENDTEXT

CFLogReqAndRes("REQUEST", "POST", l_cHOST + "upload.php", l_cCmd, _screen.oGlobal.choteldir+"doorkey.log")
lcResult = CFExecCommand(l_cCmd, .T.)
CFLogReqAndRes("RESPONSE", "POST", l_cHOST + "upload.php", lcResult, _screen.oGlobal.choteldir+"doorkey.log")

l_cIsOK = RIGHT(lcResult,4)
l_cIsOK = STRTRAN(l_cIsOK,CHR(13),"")
l_cIsOK = STRTRAN(l_cIsOK,CHR(10),"")
l_cIsOK = ALLTRIM(l_cIsOK)

IF l_cIsOK <> "OK"
	alert("QR-Code kann nicht zum Server gesendet werden. SMS wurde nicht gesendet.")
ELSE
	IF NOT EMPTY(_screen.oGlobal.cQrCode_twilio_url)
		* Send SMS
		l_cPhone = ALLTRIM(STRTRAN(STRTRAN(address.ad_phone,"-",""),"/",""))
		IF EMPTY(l_cPhone)
			alert("QR-Code konnte nicht gesendet werden. Beim Gast ist keine Mobilfunk-Nummer eingegeben.")
		ELSE
			IF LEFT(l_cPhone,1)<>"+"
				alert("SMS konnte nicht gesendet werden. Mobilfunk-Nummer ist im falschen Format. G¸ltiges Format ist +49470776112 !")
			ELSE
				TEXT TO l_cCmd TEXTMERGE NOSHOW PRETEXT 15
				curl -X POST --data-urlencode "To=<<l_cPhone>>" --data-urlencode "From=<<_screen.oGlobal.cQrCode_twilio_from_phone>>" --data-urlencode "Body=<<STRTRAN(_screen.oGlobal.cQrCode_twilio_sms_message,"__URL__", l_cURL)>>" -u <<_screen.oGlobal.cQrCode_twilio_auth>> "<<_screen.oGlobal.cQrCode_twilio_url>>"
				ENDTEXT

				CFLogReqAndRes("REQUEST", "POST", _screen.oGlobal.cQrCode_twilio_url, l_cCmd, _screen.oGlobal.choteldir+"doorkey.log")
				lcResult = CFExecCommand(l_cCmd, .T.)
				CFLogReqAndRes("RESPONSE", "POST", _screen.oGlobal.cQrCode_twilio_url, lcResult, _screen.oGlobal.choteldir+"doorkey.log")

				IF NOT ["status": "queued"] $ lcResult
					alert("SMS konnte nicht gesendet werden!")
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

* Return PDF file name
RETURN l_cPDFFile
ENDPROC
*
**************************************************
*-- Class:        ReportGenerator (mylists.prg)
*-- ParentClass:  PrivateSession
*-- BaseClass:    Session
*-- Time Stamp:   19/12/08 11:40:00 AM
*
DEFINE CLASS ReportGenerator AS PrivateSession OF commonclasses.prg
     ********************************
     * Used in default datasession! *
     ********************************
     DataSession = 1
     DIMENSION aFormDefs[1,3], aFormReport[1]
     cExportFolder = ""
     *
     PROCEDURE Init
          LOCAL l_cPath, l_cIniLoc, l_oIniReg, l_cData
          #INCLUDE "include\registry.h"
          l_cIniLoc = FULLPATH(INI_FILE)
          l_oIniReg = NEWOBJECT("oldinireg","libs\registry.vcx")
          IF l_oIniReg.GetINIEntry(@l_cData, "ExcelExport", "ExportFolder", l_cIniLoc) = ERROR_SUCCESS
               this.cExportFolder = l_cData
          ENDIF
          IF EMPTY(this.cExportFolder)
               this.cExportFolder = "export"
          ENDIF
          l_cPath = FULLPATH(this.cExportFolder)
          IF NOT DIRECTORY(l_cPath)
               MD (l_cPath)
          ENDIF
          this.FormDefGenerate()
     ENDPROC

     PROCEDURE FormDefGenerate
          LOCAL llGetDefinition, lcFormDefFilename

          DIMENSION this.aFormDefs[1,2]
          STORE "" TO this.aFormDefs

          lcFormDefFilename = FULLPATH("metadata\formdefs.txt")
          IF NOT FILE(lcFormDefFilename)
               RETURN .F.
          ENDIF

          CREATE CURSOR curFormDefsTxt (Field1 c(5), Field2 c(15), Field3 c(100))
          APPEND FROM (lcFormDefFilename) TYPE SDF

          * Skip header
          SELECT curFormDefsTxt
          LOCATE FOR ALLTRIM(Field3) = "End of header"
          SCAN REST
               DO CASE
                    CASE "*" $ Field1
                         * Commented line. Go to next line
                         LOOP
                    CASE EMPTY(Field2)
                         * Blank line. Go to next line
                         LOOP
                    CASE "[DEFINITION]" $ (Field1+Field2)
                         * Get form's definition
                         llGetDefinition = .T.
                         LOOP
               ENDCASE
               IF llGetDefinition
                    lnRows = IIF(EMPTY(this.aFormDefs[1]), 0, ALEN(this.aFormDefs,1)) + 1
                    DIMENSION this.aFormDefs[lnRows,2]
                    this.aFormDefs[lnRows,1] = ALLTRIM(Field2)
                    this.aFormDefs[lnRows,2] = ALLTRIM(Field3)
               ENDIF
          ENDSCAN
          USE IN curFormDefsTxt

          RETURN .T.
     ENDPROC

     PROCEDURE ListsRefresh
          LOCAL i, lcModule, lcCur, lnSelect, llUsedLists, lcWhere, lcSqlSelect

          lnSelect = SELECT()
          llUsedLists = USED("lists")
          IF OpenFile(.F.,"lists")
               lcWhere = "EMPTY(li_license)"
               FOR i = 1 TO GETWORDCOUNT(_screen.liclist,",")
                    lcModule = GETWORDNUM(_screen.liclist,i,",")
                    IF _screen.&lcModule
                         lcWhere = lcWhere + " OR li_license LIKE '%" + lcModule + "%'" 
                    ENDIF
               NEXT
               TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
                    SELECT li_liid, li_lang<<g_langnum>> AS li_lang, li_forms, IIF(li_order=0,9999,li_order) AS li_order 
                         FROM lists 
                         WHERE NOT li_hide AND NOT li_forms = <<sqlcnv(SPACE(254),.T.)>> AND 
                         (li_usrgrp = <<sqlcnv(SPACE(30),.T.)>> OR AT('<<g_UserGroup>>',li_usrgrp)>0) AND 
                         (<<lcWhere>>) 
                         ORDER BY 4, 2
               ENDTEXT
               lcCur = SqlCursor(lcSqlSelect)
               DIMENSION this.aFormReport[1,3]
               STORE .F. TO this.aFormReport
               SELECT li_liid, li_lang, li_forms FROM &lcCur INTO ARRAY this.aFormReport
               Dclose(lcCur)
          ENDIF
          IF NOT llUsedLists
               Dclose("lists")
          ENDIF
          SELECT (lnSelect)
     ENDPROC

     PROCEDURE RunReport
          LPARAMETERS tnListId, tlNoDialog
          IF DLocate("lists", "li_liid = " + SqlCnv(tnListId))
               SELECT lists
               prTreport(.F.,,,,tlNoDialog)
          ENDIF
     ENDPROC

     PROCEDURE Prepare
          *OpenFile()
     ENDPROC

     PROCEDURE CloseAllTables
          *CLOSE TABLES
     ENDPROC

     PROCEDURE GenerateOutPutFile
          LPARAMETERS lp_nRecNo, lp_oDefaults
          LOCAL l_cOutputFile
          IF lp_nRecNo <= RECCOUNT("lists")
               GO lp_nRecNo IN lists
               l_cOutputFile = prTreport(.T., , lp_oDefaults)
          ELSE
               l_cOutputFile = ""
          ENDIF

          RETURN l_cOutputFile
     ENDPROC
     
     PROCEDURE PreviewOrPrintReport
          LPARAMETERS lp_nRecNo, lp_oDefaults

          DO CASE
               CASE NOT EMPTY(lp_nRecNo) AND lp_nRecNo <= RECCOUNT("lists")
                    GO lp_nRecNo IN lists
               CASE TYPE("lp_oDefaults.cSystemID") = "C" AND DLocate("lists", "li_listid = " + SqlCnv(lp_oDefaults.cSystemID))
               OTHERWISE
                    RETURN .F.
          ENDCASE
          SELECT lists
          prTreport(,,lp_oDefaults)
     ENDPROC
     
     PROCEDURE GetFileName
          LPARAMETERS lp_cListId, lp_cexpfile, lp_lnodatetimestring
          LOCAL l_cFileName, l_cMacro, l_cNewText
          IF lp_lnodatetimestring
               l_cFileName = ""
          ELSE
               l_cFileName = TTOC(DATETIME(),1)
          ENDIF
          DO CASE
               CASE NOT EMPTY(lp_cexpfile)
                    IF "{" $ lp_cexpfile
                         * Some macro found
                         l_cMacro = STREXTRACT(lp_cexpfile,"{","}")
                         IF NOT EMPTY(l_cMacro)
                              l_cNewText = ""
                              TRY
                                   l_cNewText = TRANSFORM(&l_cMacro)
                              CATCH
                              ENDTRY
                              lp_cexpfile = STRTRAN(lp_cexpfile,"{"+l_cMacro+"}",l_cNewText)
                         ENDIF
                    ENDIF
                    l_cFileName = l_cFileName + IIF(EMPTY(l_cFileName),"","-" )+ ALLTRIM(lp_cexpfile)
               CASE NOT EMPTY(lp_cListId)
                    l_cFileName = l_cFileName + IIF(EMPTY(l_cFileName),"","-" ) + ALLTRIM(lp_cListId)
               OTHERWISE
                    l_cFileName = l_cFileName + IIF(EMPTY(l_cFileName),"","-" ) + PADL(LTRIM(STR(NextId('Document'))),8,'0')
          ENDCASE
          IF EMPTY(l_cFileName)
               * ups, we must assign some file name
               l_cFileName = TTOC(DATETIME(),1)
          ENDIF
          RETURN l_cFileName
     ENDPROC
     
     PROCEDURE GetExportPath
          LPARAMETERS lp_cPath
          LOCAL l_cPath
          IF EMPTY(lp_cPath)
               l_cPath = FULLPATH(this.cExportFolder)
               l_cPath = ADDBS(l_cPath)
          ELSE
               l_cPath = FULLPATH(lp_cPath)
               l_cPath = ADDBS(l_cPath)
          ENDIF
          RETURN l_cPath
     ENDPROC

     PROCEDURE BatchExportAndSend
     LPARAMETERS lp_cEmails, lp_cBatchCode, lp_lSmtp
     LOCAL l_oDefaults, l_cIniLoc, l_oIniReg, l_cBuffer, l_lPack, l_cEmailAddress, l_cAttachment, l_cCur
     LOCAL l_oAttach, l_lConvertOnLine, l_cServer, l_cPackedFile, l_lSuccess

     l_lPack = .T.
     l_cEmailAddress = ""
     l_cAttachment = ""
     l_oDefaults = MakeStructure("nPeferedType, cArchive, Min1, Max1, Min2, Max2, Min3, Max3, Min4, Max4")
     l_oDefaults.nPeferedType = 0
     l_oDefaults.cArchive = ""
     l_oDefaults.Min1 = ""
     l_oDefaults.Max1 = ""
     l_oDefaults.Min2 = ""
     l_oDefaults.Max2 = ""
     l_oDefaults.Min3 = ""
     l_oDefaults.Max3 = ""
     l_oDefaults.Min4 = ""
     l_oDefaults.Max4 = ""
     l_cServer = ""
     l_lConvertOnLine = .F.
     l_cPackedFile = ""
     * Get Parameters from Citadel.ini
     l_oIniReg = CREATEOBJECT("OldIniReg")
     l_cIniLoc = FULLPATH(INI_FILE)
     l_cBuffer = ""
     IF l_oIniReg.GetINIEntry(@l_cBuffer, "BatchReport", "Packed", l_cIniLoc) = ERROR_SUCCESS
          l_cBuffer = ALLTRIM(UPPER(l_cBuffer))
          IF NOT EMPTY(l_cBuffer) AND INLIST(l_cBuffer, "NO", "NEIN")
               l_lPack = .F.
          ENDIF
     ENDIF
     IF EMPTY(lp_cEmails)
          l_cBuffer = ""
          IF l_oIniReg.GetINIEntry(@l_cBuffer, "BatchReport", "EmailAddress", l_cIniLoc) = ERROR_SUCCESS
               l_cEmailAddress = ALLTRIM(LOWER(l_cBuffer))
          ENDIF
     ELSE
          l_cEmailAddress = ALLTRIM(lp_cEmails)
     ENDIF
     IF l_oIniReg.GetINIEntry(@l_cBuffer, "BatchReport", "server", l_cIniLoc) = ERROR_SUCCESS
          l_cBuffer = ALLTRIM(UPPER(l_cBuffer))
          IF NOT EMPTY(l_cBuffer)
               l_cServer = l_cBuffer
          ENDIF
     ENDIF
     l_cBuffer = ""
     IF l_oIniReg.GetINIEntry(@l_cBuffer, "BatchReport", "OutputFormat", l_cIniLoc) = ERROR_SUCCESS
          l_cBuffer = ALLTRIM(UPPER(l_cBuffer))
          DO CASE
               CASE l_cBuffer == "EXCEL"
                    l_oDefaults.nPeferedType = 1
               CASE l_cBuffer == "WORD"
                    l_oDefaults.nPeferedType = 2
               CASE l_cBuffer == "PDF"
                    l_oDefaults.nPeferedType = 3
               CASE l_cBuffer == "HTML"
                    l_oDefaults.nPeferedType = 4
               CASE l_cBuffer == "TXT"
                    l_oDefaults.nPeferedType = 5
               CASE l_cBuffer == "JPG"
                    l_oDefaults.nPeferedType = 6
               CASE l_cBuffer == "OO WRITER"
                    l_oDefaults.nPeferedType = 7
               CASE l_cBuffer == "OO CALC"
                    l_oDefaults.nPeferedType = 8
               CASE l_cBuffer == "RTF"
                    l_oDefaults.nPeferedType = 9
               CASE l_cBuffer == "XFF"
                    l_oDefaults.nPeferedType = 10
               OTHERWISE
                    l_oDefaults.nPeferedType = 1 && EXCEL
          ENDCASE
     ENDIF
     IF l_oIniReg.GetINIEntry(@l_cBuffer, "BatchReport", "ConvertOnLine", l_cIniLoc) = ERROR_SUCCESS
          l_cBuffer = ALLTRIM(UPPER(l_cBuffer))
          IF NOT EMPTY(l_cBuffer) AND INLIST(l_cBuffer, "YES", "JA") AND l_oDefaults.nPeferedType = 1 AND l_lPack
               l_lConvertOnLine = .T.
               l_oDefaults.nPeferedType = 10
          ENDIF
     ENDIF
     l_oAttach = CREATEOBJECT("collection")
     IF l_lPack
          l_oDefaults.cArchive = this.GetBatchArchiveName(lp_cBatchCode)
     ENDIF
     l_cCur = SYS(2015)
     SELECT *, RECNO() AS cur_recno FROM lists ;
               WHERE ((","+lp_cBatchCode+",")$(","+ALLTRIM(li_batch)+",")) AND li_output = 1 ;
               INTO CURSOR (l_cCur)
     SCAN ALL
          IF EMPTY(li_when) OR EVALUATE(li_when)
               l_cFile = this.GenerateOutPutFile(&l_cCur..cur_recno, l_oDefaults)
               IF NOT EMPTY(l_cFile)
                    IF l_lPack
                         filedelete(l_cFile)
                    ELSE
                         l_oAttach.Add(l_cFile,ALLTRIM(STR(&l_cCur..cur_recno)))
                    ENDIF
               ENDIF
          ENDIF
     ENDSCAN
     dclose(l_cCur)
     
     * Now generate li_output =  3 (from Excel Template file)
     SELECT *, RECNO() AS cur_recno FROM lists ;
               WHERE ((","+lp_cBatchCode+",")$(","+ALLTRIM(li_batch)+",")) AND li_output = 3 ;
               INTO CURSOR (l_cCur)
     SCAN ALL
          IF EMPTY(li_when) OR EVALUATE(li_when)
               l_cFile = this.GenerateOutPutFile(&l_cCur..cur_recno, l_oDefaults)
               * Add it to zip archive
               IF FILE(l_cFile)
                    IF l_lPack
                         ZipOpen(JUSTFNAME(l_oDefaults.cArchive), this.Getexportpath()+ADDBS(JUSTPATH(l_oDefaults.cArchive)), .T.)
                         ZipFile(l_cFile, .F.)
                         ZipClose()
                         filedelete(l_cFile)
                    ELSE
                         l_oAttach.Add(l_cFile,ALLTRIM(STR(&l_cCur..cur_recno)))
                    ENDIF
               ENDIF
          ENDIF
     ENDSCAN
     dclose(l_cCur)
     l_lSuccess = .T.
     IF l_lPack
          l_cPackedFile = FULLPATH(this.Getexportpath()+l_oDefaults.cArchive)
          IF l_lConvertOnLine
               l_lSuccess = this.ConvertOnLine(l_cPackedFile, l_cServer)
          ENDIF
          l_oAttach.Add(l_cPackedFile,"1")
     ENDIF

     DO CASE
          CASE NOT l_lSuccess
          CASE EMPTY(l_cEmailAddress)
               l_lSuccess = .F.
          CASE lp_lSmtp
               l_lSuccess = ProcEmail("PESendWithBlat", l_cEmailAddress,, ;
                          _screen.oGlobal.cSmtpFrom, _screen.oGlobal.cSmtpHost, _screen.oGlobal.cSmtpAuthLogin, _screen.oGlobal.cSmtpAuthPassword, ;
                          "", TRIM(g_hotel) + " " + TRANSFORM(DATETIME()), ;
                          l_cPackedFile, .T., _screen.oGlobal.cHotelDir + "autoemail.log",,.T.)
*!*               CASE emprop.ep_usesmtp
*!*                    l_lSuccess = ProcEmail("PESendWithBlat", l_cEmailAddress,, ;
*!*                               ALLTRIM(emprop.ep_from), ALLTRIM(emprop.ep_server), ALLTRIM(emprop.ep_user), ALLTRIM(emprop.ep_pass), ;
*!*                               ProcEmail("PEgetsignature"), TRIM(g_hotel) + " " + TRANSFORM(DATETIME()), ;
*!*                               l_cPackedFile, emprop.ep_log, _screen.oGlobal.cHotelDir + "autoemail.log",,.T.)
          OTHERWISE
               l_lSuccess = procemail("PESendMail", l_cEmailAddress, l_oAttach)
     ENDCASE

     FOR EACH l_cFile IN l_oAttach
          filedelete(l_cFile)
     NEXT

     RETURN l_lSuccess
     ENDPROC
     
     PROCEDURE ConvertOnLine
     LPARAMETERS lp_cPackedFile, lp_cServer
     LOCAL l_cResponse, l_cFileFullPath, l_cFile, l_cText, l_cCmd, ohttp, l_cUrl, nRESLOVETIMEOUT, nCONNECTTIMEOUT, ;
               nSENDTIMEOUT, nRECIVETIMEOUT, l_nStatus, l_lSuccess, cfilecontents, cfilenamenew, l_lExit, l_oErr, l_cErrorText
     IF EMPTY(lp_cPackedFile) OR EMPTY(lp_cServer)
          RETURN .T.
     ENDIF
     nRESLOVETIMEOUT = 30
     nCONNECTTIMEOUT = 300
     nSENDTIMEOUT = 300
     nRECIVETIMEOUT = 300
     ohttp = .NULL.
     l_cResponse = ""

     l_cFileFullPath = FULLPATH(lp_cPackedFile)
     l_cFile = JUSTFNAME(l_cFileFullPath)
     l_cText = STRCONV(FILETOSTR(l_cFileFullPath),15)

     TEXT TO l_cCmd TEXTMERGE NOSHOW
     Text1=<<l_cText>>
     ENDTEXT
     l_lExit = .F.
     DO WHILE NOT l_lExit
          l_oErr = .NULL.
          TRY
               IF ISNULL(ohttp)
                    ohttp = CREATEOBJECT("MSXML2.ServerXMLHTTP")
               ENDIF
               WAIT WINDOW GetLangText("AVAILAB","T_PROCESSING") NOWAIT
               l_cUrl = "http://"+lp_cServer+"/getxls.htm"
               ohttp.setTimeouts(nRESLOVETIMEOUT*1000,nCONNECTTIMEOUT*1000,nSENDTIMEOUT*1000,nRECIVETIMEOUT*1000)
               ohttp.Open("POST", l_cUrl, .F.)
               WAIT WINDOW GetLangText("AVAILAB","T_PROCESSING") NOWAIT
               ohttp.setRequestHeader("Content-Type", "text/plain")
               ohttp.setRequestHeader("Content-Length", TRANSFORM(LEN(l_cCmd)))
               WAIT WINDOW GetLangText("AVAILAB","T_PROCESSING") NOWAIT
               ohttp.Send(l_cCmd)
               WAIT WINDOW GetLangText("AVAILAB","T_PROCESSING") NOWAIT
               l_nStatus = 0
               TRY
                    l_nStatus = ohttp.status
               CATCH
               ENDTRY

               IF l_nStatus=200
                    cfilecontents = STREXTRACT(ohttp.responseText,"<data_block>","</data_block>")
                    cfilenamenew = lp_cPackedFile
                    STRTOFILE(STRCONV(cfilecontents,16),cfilenamenew)
                    l_lSuccess = .T.
                    l_lExit = .T.
               ENDIF
          CATCH TO l_oErr
          
          ENDTRY
          IF NOT l_lSuccess
               l_cErrorText = ""
               IF TYPE("l_oErr.ErrorNo") = "N"
                    l_cErrorText = "Convert XLS|"+ALLTRIM(_screen.caption)+;
                                     IIF(TYPE("g_Hotel") = "C", CHR(10)+;
                                     "Hotel: "+g_Hotel, "")+CHR(10)+;
                                     "Error: "+LTRIM(STR(l_oErr.ErrorNo))+CHR(10)+ ;
                                     "Message: "+l_oErr.Message+CHR(10)+;
                                     "Procedure: "+l_oErr.Procedure+CHR(10)+;
                                     "Line: "+ LTRIM(STR(l_oErr.LineNo))+CHR(10)+;
                                     "Code: "+l_oErr.Details+CHR(10)
                   = loGdata(l_cErrorText, "hotel.err")
               ENDIF
               IF NOT yesno(l_cErrorText + CHR(13) + CHR(13) + GetLangText("COMMON","TXT_TRY_AGAIN"))
                    l_lExit = .T.
               ENDIF
          ENDIF
     ENDDO
     WAIT CLEAR
     RETURN l_lSuccess
     ENDPROC
     
     PROCEDURE GetBatchArchiveName
          LPARAMETERS lp_cBatchCode
          LOCAL l_cFileName, l_cCur, l_cSql, l_nSelect
          l_nSelect = SELECT()

          l_cFileName = DTOS(sysdate()) + "-" + STRTRAN(LEFT(TIME(),5),":","")

          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
          SELECT TOP 1 pl_lang<<g_langnum>> AS descript ;
               FROM picklist ;
               WHERE pl_label = <<sqlcnv("BATCH     ")>> AND pl_charcod = <<sqlcnv(PADR(ALLTRIM(lp_cBatchCode),3))>> ;
               ORDER BY 1
          ENDTEXT

          l_cCur = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)

          IF RECCOUNT(l_cCur)>0
               l_cFileName = l_cFileName  + "-" + STRTRAN(ALLTRIM(&l_cCur..descript)," ", "_")
          ELSE
               l_cFileName = l_cFileName  + "-" + lp_cBatchCode
          ENDIF

          l_cFileName = l_cFileName  + "-" + STRTRAN(ALLTRIM(_screen.oGlobal.oParam.pa_hotel)," ", "_")
          l_cFileName = l_cFileName  + ".zip"
          
          dclose(l_cCur)
          SELECT (l_nSelect)
          
          RETURN l_cFileName
     ENDPROC
     
     PROCEDURE AddressReportsShow
          DO LISTS WITH 8, STRTRAN(GetLangText("MENU","RPT_LETTERS"),"\<","") IN MYLISTS
     ENDPROC
     
ENDDEFINE
*-- EndDefine: ReportGenerator
**************************************************
*