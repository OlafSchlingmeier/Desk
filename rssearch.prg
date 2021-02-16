*
PROCEDURE RSSearch
 PRIVATE ALL LIKE l_*
 DEFINE POPUP puSearch MARGIN SHORTCUT
 DEFINE BAR 1 OF puSearch PROMPT GetLangText("RESERVAT","TM_LASTNAME")
 DEFINE BAR 2 OF puSearch PROMPT GetLangText("RESERVAT","TM_COMPANY")
 DEFINE BAR 3 OF puSearch PROMPT GetLangText("RESERVAT","TM_AGENT")
 DEFINE BAR 4 OF puSearch PROMPT GetLangText("RESERVAT","TM_GROUP")
 DEFINE BAR 5 OF puSearch PROMPT GetLangText("RESERVAT","TM_ALLOTT")
 DEFINE BAR 6 OF puSearch PROMPT "\-"
 DEFINE BAR 7 OF puSearch PROMPT GetLangText("RESERVAT","TM_ARRDATE")
 DEFINE BAR 8 OF puSearch PROMPT GetLangText("RESERVAT","TM_DEPDATE")
 DEFINE BAR 9 OF puSearch PROMPT GetLangText("RESERVAT","TM_ROOMNUM")
 DEFINE BAR 10 OF puSearch PROMPT GetLangText("RESERVAT","TM_ROOMTYPE")
 DEFINE BAR 11 OF puSearch PROMPT GetLangText("RESERVAT","TM_STATUS")
 DEFINE BAR 12 OF puSearch PROMPT GetLangText("RESERVAT","TM_RESNUM")
 DEFINE BAR 13 OF puSearch PROMPT "\-"
 DEFINE BAR 14 OF puSearch PROMPT GetLangText("RESERVAT","TM_ALL")
 DEFINE BAR 15 OF puSearch PROMPT "\-"
 DEFINE BAR 16 OF puSearch PROMPT GetLangText("RESERVAT","TM_ONLYROOMS")
 DEFINE BAR 17 OF puSearch PROMPT GetLangText("RESERVAT","TM_ONLYCONF")
 DEFINE BAR 18 OF puSearch PROMPT "\-"
 DEFINE BAR 19 OF puSearch PROMPT GetLangText("RESERVAT","TXT_RECNAME")
 DEFINE BAR 20 OF puSearch PROMPT "\-"
 DEFINE BAR 21 OF puSearch PROMPT GetLangText("RESERVAT","TXT_MEMBER")
 DEFINE BAR 22 OF puSearch PROMPT GetLangText("RESERVAT","TXT_USERDEF")
 DEFINE BAR 23 OF puSearch PROMPT GetLangText("RESERVAT","T_RATECODE")
 DEFINE BAR 24 OF puSearch PROMPT GetLangText("RESERVAT","T_CARDAUTH")
 DEFINE BAR 25 OF puSearch PROMPT "\-"
 DEFINE BAR 26 OF puSearch PROMPT GetLangText("RESERVAT","TM_CANCNUM")
 
 SET MARK OF BAR 16 OF puSearch TO M.q_Onlyrooms
 SET MARK OF BAR 17 OF puSearch TO M.q_Onlyconf
 ON SELECTION POPUP puSearch DO DLGSEARCH WITH BAR()
 l_Bars = CNTBAR("puSearch")
 l_Max = 1
 FOR l_I = 1 TO l_Bars
      l_Max = MAX(l_Max, LEN(PRMBAR("puSearch", l_I)))
 ENDFOR
 l_Row = (WROWS()-l_Bars)/2
 l_Col = (WCOLS()-l_Max-4)/2
 MOVE POPUP puSearch TO l_Row, l_Col
 ACTIVATE POPUP puSearch
 RETURN
ENDPROC
*
PROCEDURE DlgSearch
 PARAMETER p_Menu
 PRIVATE ALL LIKE l_*
 PRIVATE nwInheight
 PRIVATE adLg
 l_Oldord = ORDER()
 l_Oldrec = RECNO()
 l_Continue = .F.
 l_Relpopup = .T.
 q_Lname = SPACE(30)
 q_Company = SPACE(30)
 q_Agent = SPACE(30)
 q_Group = SPACE(30)
 q_Recur = SPACE(30)
 q_Allott = SPACE(10)
 q_Roomtype = SPACE(4)
 q_Roomnum = SPACE(4)
 q_Status = SPACE(3)
 q_ratecode = SPACE(10)
 q_ccauth = SPACE(10)
 q_Reserid = 0.000
 q_Arr1 = CTOD("")
 q_Arr2 = CTOD("")
 q_Dep1 = CTOD("")
 q_Dep2 = CTOD("")
 q_cxlnr=0
 l_Locate = ''
 STORE SPACE(25) TO q_User1, q_User2, q_User3
 DO CASE
      CASE p_Menu==16
           M.q_Onlyrooms = IIF(M.q_Onlyrooms, .F., .T.)
           M.q_Onlyconf = .F.
           M.q_Filter = IIF(M.q_Onlyrooms, "Val(rs_deptime) == 0.00.and.", "")
           SET MARK OF BAR 16 OF puSearch TO M.q_Onlyrooms
           SET MARK OF BAR 17 OF puSearch TO M.q_Onlyconf
           l_Relpopup = .F.
      CASE p_Menu==17
           M.q_Onlyconf = IIF(M.q_Onlyconf, .F., .T.)
           M.q_Onlyrooms = .F.
           M.q_Filter = IIF(M.q_Onlyconf, "Val(rs_deptime) > 0.00.and.", "")
           SET MARK OF BAR 16 OF puSearch TO M.q_Onlyrooms
           SET MARK OF BAR 17 OF puSearch TO M.q_Onlyconf
           l_Relpopup = .F.
      CASE p_Menu==14
           M.cfOrclause = q_Filter+".t."
           M.cwHileclause = ".t."
           GOTO TOP IN "reservat"
           locate rest for &cForClause
      OTHERWISE
           DO CASE
                CASE INLIST(p_Menu,12,19,21,26)
                     DIMENSION adLg[1, 8]
                CASE p_Menu=22
                     DIMENSION adLg[3, 8]
                OTHERWISE
                     DIMENSION adLg[2, 8]
           ENDCASE
           DO CASE
                CASE p_Menu=1
                     adLg[1, 1] = "lname"
                     adLg[1, 2] = GetLangText("RESERVAT","T_LNAME")
                     adLg[1, 3] = "q_LName"
                     adLg[1, 4] = "@K "+REPLICATE("X", LEN(q_Lname))
                     adLg[1, 5] = 30
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "q_Arr1"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Lname = UPPER(ALLTRIM(adLg(1,8)))
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 2
                          l_Locate = 'RS_LNAME = '+sqLcnv(q_Lname)+ ;
                                     ' .OR. RS_SNAME = '+sqLcnv(q_Lname)
                          M.cwHileclause = '.T.'
                          IF  .NOT. EMPTY(q_Arr1)
                               M.cfOrclause = q_Filter+ ;
                                "rs_arrdate = q_Arr1 AND "+l_Locate
                          ELSE
                               M.cfOrclause = q_Filter+l_Locate
                          ENDIF
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=2
                     adLg[1, 1] = "company"
                     adLg[1, 2] = GetLangText("RESERVAT","T_COMPANY")
                     adLg[1, 3] = "q_Company"
                     adLg[1, 4] = "@K "+REPLICATE("X", LEN(q_Company))
                     adLg[1, 5] = 30
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "q_Arr1"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Company = UPPER(ALLTRIM(adLg(1,8)))
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 3
                          l_Locate = 'RS_COMPANY + DTOS(RS_ARRDATE) = '+ ;
                                     sqLcnv(q_Company)
                          M.cwHileclause = "RS_COMPANY = q_Company"
                          IF  .NOT. EMPTY(q_Arr1)
                               M.cfOrclause = q_Filter+"rs_arrdate = q_Arr1"
                          ELSE
                               M.cfOrclause = q_Filter+".t."
                          ENDIF
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=3
                     adLg[1, 1] = "agent"
                     adLg[1, 2] = GetLangText("RESERVAT","T_AGENT")
                     adLg[1, 3] = "q_agent"
                     adLg[1, 4] = "@K "+REPLICATE("X", LEN(q_Agent))
                     adLg[1, 5] = 30
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "q_Arr1"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Agent = UPPER(ALLTRIM(adLg(1,8)))
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 4
                          l_Locate = 'RS_AGENT + DTOS(RS_ARRDATE) = '+ ;
                                     sqLcnv(q_Agent)
                          M.cwHileclause = "RS_AGENT = q_Agent"
                          IF  .NOT. EMPTY(q_Arr1)
                               M.cfOrclause = q_Filter+"rs_arrdate = q_Arr1"
                          ELSE
                               M.cfOrclause = q_Filter+".t."
                          ENDIF
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=4
                     adLg[1, 1] = "group"
                     adLg[1, 2] = GetLangText("RESERVAT","T_GROUP")
                     adLg[1, 3] = "q_Group"
                     adLg[1, 4] = "@K "+REPLICATE("X", LEN(q_Group))
                     adLg[1, 5] = 30
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "q_Arr1"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Group = UPPER(ALLTRIM(adLg(1,8)))
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 5
                          l_Locate = 'RS_GROUP + DTOS(RS_ARRDATE) + RS_LNAME = '+ ;
                                     sqLcnv(q_Group)
                          M.cwHileclause = "RS_GROUP = q_Group"
                          IF  .NOT. EMPTY(q_Arr1)
                               M.cfOrclause = q_Filter+"rs_arrdate = q_Arr1"
                          ELSE
                               M.cfOrclause = q_Filter+".t."
                          ENDIF
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=5
                     adLg[1, 1] = "allot"
                     adLg[1, 2] = GetLangText("RESERVAT","T_ALLOTT")
                     adLg[1, 3] = "q_Allott"
                     adLg[1, 4] = "@K "+REPLICATE("X", LEN(q_Allott))
                     adLg[1, 5] = 30
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "SysDate()"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Allott = UPPER(ALLTRIM(adLg(1,8)))
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 8
                          l_Seek = DTOS(q_Arr1)
                          M.cwHileclause = "rs_arrdate >= q_Arr1"
                          M.cfOrclause = q_Filter+ ;
                           "Upper(AllTrim(rs_allott)) = Upper(AllTrim(q_Allott))"
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=7
                     adLg[1, 1] = "arrdate1"
                     adLg[1, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[1, 3] = "SysDate()"
                     adLg[1, 4] = "@K"
                     adLg[1, 5] = siZedate()
                     adLg[1, 6] = "XSet('m.arrdate2', m.arrdate1 + 7)"
                     adLg[1, 7] = ""
                     adLg[1, 8] = {}
                     adLg[2, 1] = "arrdate2"
                     adLg[2, 2] = ""
                     adLg[2, 3] = "SysDate() + 7"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8)) .AND.  .NOT.  ;
                        EMPTY(adLg(2,8))
                          q_Arr1 = adLg(1,8)
                          q_Arr2 = adLg(2,8)
                          SET ORDER IN "reservat" TO 8
                          l_Seek = DTOS(q_Arr1)
                          M.cwHileclause =  ;
                           "rs_arrdate >= q_Arr1 .and. rs_arrdate <= q_Arr2"
                          M.cfOrclause = q_Filter+".t."
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=8
                     adLg[1, 1] = "depdate1"
                     adLg[1, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[1, 3] = "SysDate()"
                     adLg[1, 4] = "@K"
                     adLg[1, 5] = siZedate()
                     adLg[1, 6] = "XSet('m.depdate2', m.depdate1 + 7)"
                     adLg[1, 7] = ""
                     adLg[1, 8] = {}
                     adLg[2, 1] = "depdate2"
                     adLg[2, 2] = ""
                     adLg[2, 3] = "SysDate() + 7"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8)) .AND.  .NOT.  ;
                        EMPTY(adLg(2,8))
                          q_Dep1 = adLg(1,8)
                          q_Dep2 = adLg(2,8)
                          SET ORDER IN "reservat" TO 9
                          l_Seek = DTOS(q_Dep1)
                          M.cwHileclause =  ;
                           "rs_depdate >= q_Dep1 .and. rs_depdate <= q_Dep2"
                          M.cfOrclause = q_Filter+".t."
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=9
                     adLg[1, 1] = "roomnum"
                     adLg[1, 2] = GetLangText("RESERVAT","T_ROOMNUM")
                     adLg[1, 3] = "q_RoomNum"
                     adLg[1, 4] = "@K !!!!"
                     adLg[1, 5] = 6
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "SysDate()"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Roomnum = adLg(1,8)
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 13
                          l_Seek = q_Roomnum
                          M.cwHileclause = "rs_roomnum == q_RoomNum"
                          IF  .NOT. EMPTY(q_Arr1)
                               M.cfOrclause = q_Filter+"rs_arrdate = q_Arr1"
                          ELSE
                               M.cfOrclause = q_Filter+".t."
                          ENDIF
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=10
                     adLg[1, 1] = "roomtype"
                     adLg[1, 2] = GetLangText("RESERVAT","T_ROOMTYPE")
                     adLg[1, 3] = "q_RoomType"
                     adLg[1, 4] = "@K !!!!"
                     adLg[1, 5] = 6
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "SysDate()"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Roomtype = adLg(1,8)
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 8
                          l_Seek = DTOS(q_Arr1)
                          M.cwHileclause = "rs_arrdate >= q_Arr1"
                          M.cfOrclause = q_Filter+"rs_roomtyp == q_RoomType"
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=11
                     adLg[1, 1] = "roomtype"
                     adLg[1, 2] = GetLangText("RESERVAT","T_STATUS")
                     adLg[1, 3] = "q_status"
                     adLg[1, 4] = "@K !!!"
                     adLg[1, 5] = 6
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "SysDate()"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Status = adLg(1,8)
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 8
                          l_Seek = DTOS(q_Arr1)
                          M.cfOrclause = q_Filter+"rs_status == q_Status"
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=12
                     adLg[1, 1] = "resid"
                     adLg[1, 2] = GetLangText("RESERVAT","T_RESNUM")
                     adLg[1, 3] = "0.000"
                     adLg[1, 4] = "@K 99999999.999"
                     adLg[1, 5] = 15
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = 0
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Reserid = adLg(1,8)
                          SET ORDER IN "reservat" TO 1
                          l_Seek = q_Reserid
                          M.cwHileclause = "rs_reserid == q_ReserId"
                          M.cfOrclause = q_Filter+".t."
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu==19
                     adLg[1, 1] = "recname"
                     adLg[1, 2] = GetLangText("RESERVAT","TXT_RECURNAME")
                     adLg[1, 3] = "q_Recur"
                     adLg[1, 4] = "@K "+REPLICATE("!", LEN(q_Recur))
                     adLg[1, 5] = 30
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Recur = adLg(1,8)
                          SET ORDER IN "Reservat" TO 14
                          l_Seek = UPPER(ALLTRIM(q_Recur))
                          M.cwHileclause =  ;
                           "Upper(AllTrim(Rs_Recur)) = Upper(AllTrim(q_Recur))"
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu==21
                     adLg[1, 1] = "resid"
                     adLg[1, 2] = GetLangText("RESERVAT","TXT_MEMBER")
                     adLg[1, 3] = "0"
                     adLg[1, 4] = "@K 999999999"
                     adLg[1, 5] = 10
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = 0
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_Member = adLg(1,8)
                          SET ORDER IN "Reservat" TO 1
                          l_Seek = 0
                          M.cfOrclause = q_Filter+ ;
                           "DbLookup('Address', 'Tag6', "+ ;
                           LTRIM(STR(q_Member))+ ;
                           ", 'Ad_AddrId') = Reservat.Rs_AddrId"
                          M.cwHileclause = ".t."
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu==22
                     adLg[1, 1] = "user1"
                     adLg[1, 2] = TRIM(paRam.pa_usrres1)
                     IF EMPTY(adLg(1,2))
                          adLg[1, 2] = "<User1>"
                     ENDIF
                     adLg[1, 3] = "q_User1"
                     adLg[1, 4] = "@K "+REPLICATE("!", LEN(q_User1))
                     adLg[1, 5] = 30
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "user2"
                     adLg[2, 2] = TRIM(paRam.pa_usrres2)
                     IF EMPTY(adLg(2,2))
                          adLg[2, 2] = "<User2>"
                     ENDIF
                     adLg[2, 3] = "q_User2"
                     adLg[2, 4] = "@K "+REPLICATE("!", LEN(q_User2))
                     adLg[2, 5] = 30
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = ""
                     adLg[3, 1] = "user3"
                     adLg[3, 2] = TRIM(paRam.pa_usrres3)
                     IF EMPTY(adLg(3,2))
                          adLg[3, 2] = "<User3>"
                     ENDIF
                     adLg[3, 3] = "q_User3"
                     adLg[3, 4] = "@K "+REPLICATE("!", LEN(q_User3))
                     adLg[3, 5] = 30
                     adLg[3, 6] = ""
                     adLg[3, 7] = ""
                     adLg[3, 8] = ""
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8)+adLg(2,8)+adLg(3,8))
                          q_User1 = adLg(1,8)
                          q_User2 = adLg(2,8)
                          q_User3 = adLg(3,8)
                          SET ORDER IN "Reservat" TO 1
                          l_Seek = 0
                          M.cfOrclause = q_Filter+"Upper(Rs_UsrRes1) = '"+ ;
                           UPPER(ALLTRIM(q_User1))+ ;
                           "' And Upper(Rs_UsrRes2) = '"+ ;
                           UPPER(ALLTRIM(q_User2))+ ;
                           "' And Upper(Rs_UsrRes3) = '"+ ;
                           UPPER(ALLTRIM(q_User3))+"'"
                          M.cwHileclause = ".t."
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=23
                     adLg[1, 1] = "ratecod"
                     adLg[1, 2] = GetLangText("RESERVAT","T_RATECODE")
                     adLg[1, 3] = "q_ratecode"
                     adLg[1, 4] = "@K "+REPLICATE("!", LEN(q_ratecode))
                     adLg[1, 5] = 10
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "SysDate()"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_ratecode =TRIM(adLg(1,8))
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 8
                          l_Seek = DTOS(q_Arr1)
                          M.cfOrclause = q_Filter+"rs_ratecod = q_ratecode .OR. rs_ratecod='*'+q_ratecode"
                          l_Continue = .T.
                     ENDIF
                CASE p_Menu=24
                     adLg[1, 1] = "ccauth"
                     adLg[1, 2] = GetLangText("RESERVAT","T_CARDAUTH")
                     adLg[1, 3] = "q_ccauth"
                     adLg[1, 4] = "@K "+REPLICATE("!", LEN(q_ccauth))
                     adLg[1, 5] = 10
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = ""
                     adLg[2, 1] = "arrdate"
                     adLg[2, 2] = GetLangText("RESERVAT","T_ARRDATE")
                     adLg[2, 3] = "SysDate()"
                     adLg[2, 4] = "@K"
                     adLg[2, 5] = siZedate()
                     adLg[2, 6] = ""
                     adLg[2, 7] = ""
                     adLg[2, 8] = {}
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg)  ;
                        .AND.  .NOT. EMPTY(adLg(1,8))
                          q_ccauth = adLg(1,8)
                          q_Arr1 = adLg(2,8)
                          SET ORDER IN "reservat" TO 8
                          l_Seek = DTOS(q_Arr1)
                          M.cfOrclause = q_Filter+"rs_ccauth == q_ccauth"
                          l_Continue = .T.
                     ENDIF
               CASE p_Menu==26 && Cancelation number
                     adLg[1, 1] = "cxlnumber"
                     adLg[1, 2] = GetLangText("RESERVAT","T_CANCNUM")
                     adLg[1, 3] = "0"
                     adLg[1, 4] = "@K 99999999"
                     adLg[1, 5] = 10
                     adLg[1, 6] = ""
                     adLg[1, 7] = ""
                     adLg[1, 8] = 0
                     IF diAlog(GetLangText("RESERVAT","TW_RSSEARCH"), ,@adLg) .AND. !EMPTY(adLg(1,8))
                          q_cxlnr = adLg(1,8)
                          SET ORDER IN "Reservat" TO 1
                          l_Seek = 0
                          M.cfOrclause = q_Filter+"Reservat.Rs_cxlnr="+ALLTRIM(STR(q_cxlnr))
                          M.cwHileclause = ".t."
                          l_Continue = .T.
                     ENDIF              
           ENDCASE
           IF l_Continue
                IF  .NOT. EMPTY(l_Locate)
                     locate all for &l_Locate
                ELSE
                     IF ( .NOT. SEEK(l_Seek, "reservat"))
                          SET NEAR ON
                          = SEEK(l_Seek, "Reservat")
                          SET NEAR OFF
                     ENDIF
                ENDIF
                locate rest for &cForClause while &cWhileClause
                IF  .NOT. FOUND()
                     = alErt(GetLangText("RESERVAT","TA_NOTFOUND")+"!")
                     SET ORDER TO (l_Oldord)
                     GOTO l_Oldrec
                     M.cfOrclause = q_Filter+".t."
                     M.cwHileclause = ".t."
                ENDIF
           ENDIF
 ENDCASE
 IF l_Relpopup
      DEACTIVATE POPUP puSearch
 ENDIF
 RETURN
ENDPROC
*
