*
FUNCTION RoomType
	do form "forms\MngForm" with "MngRtCtrl"
	return
 PRIVATE cbUttons
 PRIVATE clEvel
 PRIVATE noLdarea
 PRIVATE noLdrec
 PRIVATE a_Field
 DIMENSION a_Field[3, 3]
 a_Field[1, 1] = "RoomType.Rt_RoomTyp"
 a_Field[1, 2] = 15
 a_Field[1, 3] = GetLangText("MGRRESER","TXT_RTTYPE")
 a_Field[2, 1] = "Rt_Lang"+g_Langnum
 a_Field[2, 2] = 40
 a_Field[2, 3] = GetLangText("MGRRESER","TXT_RTLANG")
 a_Field[3, 1] = "Rt_RateCod"
 a_Field[3, 2] = 20
 a_Field[3, 3] = GetLangText("MGRRESER","TXT_RTRATECOD")
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_DELETE"),-4)
 noLdarea = SELECT()
 SELECT roOmtype
 noLdrec = RECNO("RoomType")
 GOTO TOP
 crT1button = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("MGRRESER","TXT_RTBROWSE"),15,@a_Field,".t.",".t.", ;
   cbUttons,"vRTControl","RoomType")
 gcButtonfunction = crT1button
 GOTO noLdrec IN "roomtype"
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION RoomTypeDef
	DO FORM "forms\MngForm" with "MngRtdCtrl"
ENDFUNC
*
FUNCTION vRTControl
 PARAMETER noPtion
 PRIVATE cfIeldname
 cfIeldname = "roomtype.rt_lang"+g_Langnum
 DO CASE
      CASE noPtion==1
      CASE noPtion==2
           = scRroomtype("EDIT")
           g_Refreshcurr = UPDATED()
      CASE noPtion==3
           = scRroomtype("NEW")
           g_Refreshall = UPDATED()
      CASE noPtion==4
           If ( YesNo(GetLangText("MGRRESER"			, "TXT_RTDELETE") + ";" + AllTrim(&cFieldName)) )
                DELETE
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION ScrRoomType
 PARAMETER coPtion
 PRIVATE ncHoice
 PRIVATE clAnguage
 PRIVATE nrOw
 PRIVATE ncOl
 PRIVATE crOomtypegroups
 PRIVATE nsElect
 PRIVATE noRder
 PRIVATE nrEcord
 PRIVATE cmAcro
 ncHoice = 1
 nsElect = SELECT()
 SELECT piCklist
 noRder = ORDER()
 nrEcord = RECNO()
 SET ORDER TO 3
 IF ( .NOT. SEEK("ROOMTYPEGR", "PickList"))
      crOomtypegroups = "NOT DEFINED"
 ELSE
      cmAcro = "PickList.Pl_Lang"+g_Langnum
      crOomtypegroups = ""
      DO WHILE ( .NOT. EOF("PickList") .AND.  ;
         UPPER(ALLTRIM(piCklist.pl_label))=="ROOMTYPEGR")
           cRoomTypeGroups = cRoomTypeGroups + iIf(Empty(cRoomTypeGroups), "", ";") + &cMacro
           SKIP 1 IN piCklist
      ENDDO
 ENDIF
 SET ORDER TO nOrder
 GOTO nrEcord
 SELECT (nsElect)
 DO CASE
      CASE coPtion="EDIT"
           SCATTER MEMVAR
      CASE coPtion="NEW"
           SCATTER BLANK MEMVAR
 ENDCASE
 clAnguage = "m.Rt_Lang"+M.g_Langnum
 DEFINE WINDOW wrOomtype AT 0, 0 SIZE 16.750, 60 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("MGRRESER","TXT_RTWINDOW")) NOMDI DOUBLE
 MOVE WINDOW wrOomtype CENTER
 ACTIVATE WINDOW wrOomtype
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 = paNel((0.25),(0.666666666666667),13.5,WCOLS()-(0.666666666666667))
 = txTpanel(1,3,23,GetLangText("MGRRESER","TXT_RTTYPE"),20)
 = txTpanel(2.25,3,23,GetLangText("MGRRESER","TXT_RTLANG"),20)
 = txTpanel(3.5,3,23,GetLangText("MGRRESER","TXT_RTGROUP"),20)
 = txTpanel(5.25,3,23,GetLangText("MGRRESER","TXT_RTRATECOD"),20)
 = txTpanel(6.5,3,23,GetLangText("MGRRESER","TXT_RTSEQUENCE"),20)
 = txTpanel(10.25,3,23,GetLangText("MGRRESER","TXT_VIEWSIZE"),20)
 = txTpanel(11.5,3,23,GetLangText("MGRRESER","TXT_VIEWFORMAT"),20)
 @ 1, 25 GET M.rt_roomtyp SIZE 1, 30 PICTURE "@K !!!!"
 @ 2.25,	25 	Get &cLanguage 							 Picture "@K " + Replicate("X", 25) 	 Valid LangEdit("RT_", GetLangText("MGRRESER"			, "TXT_RTWINDOW"))	 Size 1, 30
 @ 3.500, 25 GET M.rt_group SIZE 1, 30 FUNCTION "^" PICTURE  ;
   crOomtypegroups VALID xeNable('m.Rt_VwShow',M.rt_group<>2) .AND.  ;
   xeNable('m.Rt_VwSum',M.rt_group<>2) .AND. xeNable('m.Rt_VwSize', ;
   M.rt_group<>2)
 @ 5.250, 25 GET M.rt_ratecod SIZE 1, 30 PICTURE "@K "+REPLICATE("!", 10)
 @ 6.500, 25 GET M.rt_sequenc SIZE 1, 3 PICTURE "@K ##"
 ceNable = IIF(M.rt_group<>2, 'ENABLE', 'DISABLE')
 @ 7.75, 25	Get m.Rt_VwShow  function "*C" + " " + 	GetLangText("MGRRESER"			, "TXT_VIEWAVL")  &cEnable  valid XEnable('m.Rt_VwSum', m.Rt_VwShow) and  XEnable('m.Rt_VwSize', m.Rt_VwShow) and  XEnable('m.Rt_VwFmt', m.Rt_VwShow)
 @ 9.00, 25	Get m.Rt_VwSum  function "*C" + " " + 	GetLangText("MGRRESER"			, "TXT_SUMAVL")  &cEnable
 @ 10.25, 25	Get m.rt_VwSize  picture "@K 99.9"  size 1, 8  &cEnable
 @ 11.5, 25	Get m.rt_VwFmt  picture "@K!!!!!!"  size 1, 8  &cEnable
 nrOw = WROWS()-2.5
 ncOl = (WCOLS()-0032-1)/2
 @ nrOw, ncOl GET ncHoice STYLE "B" SIZE nbUttonheight, 15 FUNCTION "*"+ ;
   "T"+"H" PICTURE cbUttons VALID vrTchoice(coPtion)
 READ CYCLE MODAL
 RELEASE WINDOW wrOomtype
 = chIldtitle("")
 RETURN .T.
ENDFUNC
*
FUNCTION vRTChoice
 PARAMETER coPtion
 PRIVATE lrEtval
 lrEtval = .F.
 DO CASE
      CASE M.ncHoice==1
           DO CASE
                CASE (coPtion="NEW")
                     INSERT INTO RoomType FROM MEMVAR
                CASE (coPtion="EDIT")
                     GATHER MEMVAR
           ENDCASE
           CLEAR READ
           lrEtval = .T.
      CASE M.ncHoice==2
           CLEAR READ
           lrEtval = .T.
 ENDCASE
 RETURN lrEtval
ENDFUNC
*
