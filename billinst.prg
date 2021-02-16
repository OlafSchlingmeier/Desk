 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, lp_uParam6
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal

 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO PCOUNT()-1
    l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"
 *l_cCallProc = MakeCallProc(lp_cFuncName, "lp_uParam", PCOUNT()-1)
 l_uRetVal = &l_cCallProc

 RETURN l_uRetVal
ENDFUNC
*
PROCEDURE BillInstr
 PARAMETER p_Artinum, p_Billinst, p_Reserid, p_Window, p_lSilent, p_oReservat
 PRIVATE ALL LIKE l_*
 LOCAL ARRAY l_aWin(1)
 LOCAL l_lAllow, l_nWindowSuggestion, l_oEnvironment

 l_Instr1 = SUBSTR(MLINE(p_Billinst, 1), 13)
 l_Id1 = myVal(SUBSTR(MLINE(p_Billinst, 1), 1, 12))
 l_Instr2 = SUBSTR(MLINE(p_Billinst, 2), 13)
 l_Id2 = myVal(SUBSTR(MLINE(p_Billinst, 2), 1, 12))
 l_Instr3 = SUBSTR(MLINE(p_Billinst, 3), 13)
 l_Id3 = myVal(SUBSTR(MLINE(p_Billinst, 3), 1, 12))
 l_Instr4 = SUBSTR(MLINE(p_Billinst, 4), 13)
 l_Id4 = myVal(SUBSTR(MLINE(p_Billinst, 4), 1, 12))
 l_Msg = ""
 l_nWindowSuggestion = 0
 IF TYPE("p_oReservat") <> "O"
      p_oReservat = .NULL.
 ENDIF
 DO CASE
      CASE arTiininstr(p_Artinum,l_Instr1) AND Restricted(p_Reserid, p_oReservat)
           l_oEnvironment = SetEnvironment("reservat")
           SET ORDER IN "reservat" TO
           CursorQuery("reservat", StrToSql("rs_reserid = %n1", l_Id1))
           IF DLocate("reservat", StrToSql("rs_reserid = %n1", l_Id1))
                IF EMPTY(reServat.rs_out) AND NOT INLIST(reServat.rs_status, "CXL", "NS")
                     l_nWindowSuggestion = PBGetFreeWindow(reservat.rs_reserid,1)
                     l_aWin(1) = l_nWindowSuggestion
                     DO BillsReserCheck IN ProcBill WITH reservat.rs_reserid, l_aWin, "POST_NEW", l_lAllow, p_lSilent
                     IF l_lAllow
                          p_Window = l_nWindowSuggestion
                          p_Reserid = l_Id1
                          l_Msg = GetLangText("BILLINST","T_GOESTO")+Get_rm_rmname(reServat.rs_roomnum)+" "+PROPER(TRIM(reServat.rs_lname))
                     ENDIF
                ENDIF
           ENDIF
      CASE arTiininstr(p_Artinum,l_Instr2)
           l_nWindowSuggestion = PBGetFreeWindow(reservat.rs_reserid,2)
           l_aWin(1) = l_nWindowSuggestion
           DO BillsReserCheck IN ProcBill WITH p_Reserid, l_aWin, "POST_NEW", l_lAllow, p_lSilent
           IF l_lAllow
                p_Window = l_nWindowSuggestion
                l_Msg = GetLangText("BILLINST","T_GOESTO")+" "+GetLangText("BILLINST","T_WINDOW")+" 2"
           ENDIF
      CASE arTiininstr(p_Artinum,l_Instr3)
           l_nWindowSuggestion = PBGetFreeWindow(reservat.rs_reserid,3)
           l_aWin(1) = l_nWindowSuggestion
           DO BillsReserCheck IN ProcBill WITH p_Reserid, l_aWin, "POST_NEW", l_lAllow, p_lSilent
           IF l_lAllow
                p_Window = l_nWindowSuggestion
                l_Msg = GetLangText("BILLINST","T_GOESTO")+" "+GetLangText("BILLINST","T_WINDOW")+" 3"
           ENDIF
 ENDCASE
 IF NOT EMPTY(l_Msg) AND EMPTY(p_lSilent) AND NOT g_lFakeResAndPost
      WAIT WINDOW l_Msg NOWAIT
 ENDIF

 RETURN
ENDPROC
*
FUNCTION ArtiInInstr
 PARAMETER p_Artinum, p_String
 PRIVATE ALL LIKE l_*
 IF EMPTY(p_String)
      RETURN .F.
 ENDIF
 l_Retval = .F.
 p_String = UPPER(ALLTRIM(p_String))
 p_String = CHRTRAN(p_String, " ", "")
 DO CASE
      CASE p_String=="*"
           l_Retval = .T.
      CASE LEFT(p_String, 2)=="*/"
           IF LEN(p_String)=2
                l_Retval = .T.
           ELSE
                l_Retval = .T.
                p_String = SUBSTR(p_String, 3)
                = rePlcode(@p_String)
                l_Commas = OCCURS(",", (p_String+","))
                l_Start = 1
                FOR l_I = 1 TO l_Commas
                     l_End = AT(",", (p_String+","), l_I)
                     l_Tmp = ALLTRIM(SUBSTR(p_String, l_Start, l_End-l_Start))
                     DO CASE
                          CASE ((","+LTRIM(STR(p_Artinum))+",")=(","+ ;
                               l_Tmp+","))
                               l_Retval = .F.
                          CASE ("-"$l_Tmp)
                               l_Minpos = AT("-", l_Tmp)
                               l_Minval = VAL(SUBSTR(l_Tmp, 1, l_Minpos-1))
                               l_Maxval = VAL(SUBSTR(l_Tmp, l_Minpos+1))
                               IF BETWEEN(p_Artinum, l_Minval, l_Maxval)
                                    l_Retval = .F.
                               ENDIF
                     ENDCASE
                     IF  .NOT. l_Retval
                          EXIT
                     ELSE
                          l_Start = l_End+1
                     ENDIF
                ENDFOR
           ENDIF
      OTHERWISE
           = rePlcode(@p_String)
           l_Commas = OCCURS(",", (p_String+","))
           l_Start = 1
           FOR l_I = 1 TO l_Commas
                l_End = AT(",", (p_String+","), l_I)
                l_Tmp = ALLTRIM(SUBSTR(p_String, l_Start, l_End-l_Start))
                DO CASE
                     CASE ((","+LTRIM(STR(p_Artinum))+",")=(","+l_Tmp+","))
                          l_Retval = .T.
                     CASE ("-"$l_Tmp)
                          l_Minpos = AT("-", l_Tmp)
                          l_Minval = VAL(SUBSTR(l_Tmp, 1, l_Minpos-1))
                          l_Maxval = VAL(SUBSTR(l_Tmp, l_Minpos+1))
                          IF BETWEEN(p_Artinum, l_Minval, l_Maxval)
                               l_Retval = .T.
                          ENDIF
                ENDCASE
                IF l_Retval
                     EXIT
                ELSE
                     l_Start = l_End+1
                ENDIF
           ENDFOR
 ENDCASE
 RETURN l_Retval
ENDFUNC
*
PROCEDURE ReplCode
 PARAMETER pcInstr
 PRIVATE naRea, npLrec
 naRea = SELECT()
 SELECT piCklist
 npLrec = RECNO()
 SCAN ALL FOR piCklist.pl_label='BILLINSTR'
      IF AT(','+pcInstr+',', ','+ALLTRIM(piCklist.pl_charcod)+',')>0
           pcInstr = STRTRAN(','+pcInstr+',', ','+ ;
                     ALLTRIM(piCklist.pl_charcod)+',',  ;
                     ALLTRIM(piCklist.pl_memo))
      ENDIF
 ENDSCAN
 GOTO npLrec
 SELECT (naRea)
 RETURN
ENDPROC
*
PROCEDURE ScrBillInstr
 LOCAL i
 for i=1 to _screen.formcount
      If Upper(_Screen.Forms(I).BaseClass)<>'TOOLBAR'
           _Screen.Forms(I).Enabled=.F.
      Endif
 NEXT
DO FORM forms\billinst WITH RECNO('reservat'), 3, M.RS_BILLINS
RETURN
*
FUNCTION Restricted
 LPARAMETERS lp_nReserid, lp_oReservat
 LOCAL l_lAllow, l_nArea, l_curReservat, l_dPostDate

 l_nArea = SELECT()

 IF NOT USED("billinst")
      OpenFileDirect(.F.,"billinst")
 ENDIF
 IF TYPE("p_dPostDate") <> "U" AND NOT EMPTY(p_dPostDate) AND (p_dPostDate <> g_sysdate)
      l_dPostDate = p_dPostDate
 ELSE
      l_dPostDate = g_sysdate
 ENDIF
 IF ISNULL(lp_oReservat)
      l_curReservat = SqlCursor(StrToSql("SELECT * FROM reservat WHERE rs_reserid = %n1", lp_nReserid))
      IF USED(l_curReservat) AND &l_curReservat..rs_reserid = lp_nReserid
           SELECT &l_curReservat
           SCATTER NAME lp_oReservat
      ENDIF
      DClose(l_curReservat)
 ENDIF
 l_lAllow = ISNULL(lp_oReservat) OR NOT SEEK(STR(lp_oReservat.rs_reserid,12,3)+STR(l_dPostDate - lp_oReservat.rs_arrdate,3),"billinst","tag2")

 SELECT (l_nArea)

 RETURN l_lAllow
ENDFUNC
*