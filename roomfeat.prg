*
PROCEDURE RoomFeature
 PARAMETER pcRoom
 PRIVATE naRea
 PRIVATE clIst
 PRIVATE cnEwlist
 naRea = SELECT()
 clIst = ""
 SELECT roOmfeat
 SET ORDER TO 1
 SEEK PADR(pcRoom, 4)
 SCAN WHILE rf_roomnum==PADR(pcRoom, 4)
      clIst = clIst+TRIM(rf_feature)+","
 ENDSCAN
 cnEwlist = geTfeature(clIst)
 SELECT roOmfeat
 IF  .NOT. (cnEwlist==clIst)
      DELETE FOR rf_roomnum==PADR(pcRoom, 4)
      npOs = AT(",", cnEwlist)
      DO WHILE npOs>0
           INSERT INTO RoomFeat (rf_roomnum, rf_feature) VALUES (pcRoom,  ;
                  SUBSTR(cnEwlist, 1, npOs-1))
           cnEwlist = SUBSTR(cnEwlist, npOs+1)
           npOs = AT(",", cnEwlist)
      ENDDO
 ENDIF
 SELECT (naRea)
 RETURN
ENDPROC
*
FUNCTION GetFeature
 PARAMETER pcInit
 PRIVATE naVl, nsEl, xaAvl, xaSel
 PRIVATE ncMdsel, ncMddesel, ncMdok, ncMdcancel
 PRIVATE crEt, j
 PRIVATE wfEature
 PRIVATE naRea
 pcInit = IIF(PARAMETERS()=0, "", pcInit+",")
 ncMdsel = 1
 ncMddesel = 1
 ncMdok = 1
 ncMdcancel = 1
 naVl = 1
 nsEl = 1
 crEt = ""
 DIMENSION xaAvl[1, 2]
 DIMENSION xaSel[1, 2]
 xaSel[1, 1] = ""
 xaSel[1, 2] = "***"
 xaAvl[1, 1] = ""
 xaAvl[1, 2] = "***"
 naRea = SELECT()
 SELECT piCklist
 noRd = ORDER()
 nrEc = RECNO()
 SET ORDER TO 4
 SEEK "FEATURE"
 SCAN WHILE pl_label="FEATURE"
      IF TRIM(pl_charcod)+","$pcInit
           IF xaSel(1,2)="***"
                nrOw = 1
           ELSE
                nlEn = ALEN(xaSel, 1)
                DIMENSION xaSel[nlEn+1, 2]
                nrOw = nlEn+1
           ENDIF
           xaSel[nrOw, 1] = EVALUATE("pl_lang"+g_Langnum)
           xaSel[nrOw, 2] = pl_charcod
      ELSE
           IF xaAvl(1,2)="***"
                nrOw = 1
           ELSE
                nlEn = ALEN(xaAvl, 1)
                DIMENSION xaAvl[nlEn+1, 2]
                nrOw = nlEn+1
           ENDIF
           xaAvl[nrOw, 1] = EVALUATE("pl_lang"+g_Langnum)
           xaAvl[nrOw, 2] = pl_charcod
      ENDIF
 ENDSCAN
 SET ORDER TO nOrd
 GOTO nrEc
 DEFINE WINDOW wfEature FROM 0, 0 TO 15.500, 82 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE GetLangText("ROOMFEAT","TW_FEATURE") NOMDI DOUBLE
 ACTIVATE WINDOW NOSHOW wfEature
 MOVE WINDOW wfEature CENTER
 @ 0, 2 SAY GetLangText("ROOMFEAT","TX_AVAILAB")
 @ 1, 2 get nAvl  from xaAvl  size 10, 30  picture '@&N'  valid SelItem(nAvl)
 @ 4, 33 GET ncMdsel STYLE "B" SIZE nbUttonheight, 16 PICTURE "@*N "+ ;
   GetLangText("ROOMFEAT","TB_SELECT") VALID seLitem(naVl)
 @ 7, 33 GET ncMddesel STYLE "B" SIZE nbUttonheight, 16 PICTURE "@*N "+ ;
   GetLangText("ROOMFEAT","TB_REMOVE") VALID deSelitem(nsEl)
 @ 0, 50 SAY GetLangText("ROOMFEAT","TX_SELECT")
 @ 1, 50 get nSel  from xaSel  size 10, 30  picture '@&N'  valid DeSelItem(nSel)
 @ 12, 28 GET ncMdok STYLE "B" SIZE nbUttonheight, 12 PICTURE "@*T \!"+ ;
   GetLangText("ROOMFEAT","TB_OK")
 @ 12, 42 GET ncMdcancel STYLE "B" SIZE nbUttonheight, 12 PICTURE  ;
   "@*T \?"+GetLangText("ROOMFEAT","TB_CANCEL")
 READ CYCLE MODAL
 RELEASE WINDOW wfEature
 SELECT (naRea)
 IF LASTKEY()<>27
      FOR j = 1 TO ALEN(xaSel, 1)
           IF xaSel(j,2)<>"***"
                crEt = crEt+TRIM(xaSel(j,2))+","
           ENDIF
      ENDFOR
 ELSE
      crEt = pcInit
 ENDIF
 RETURN crEt
ENDFUNC
*
FUNCTION SelItem
 PARAMETER pnItem
 IF xaAvl(pnItem,2)="***"
      RETURN 0
 ENDIF
 nlEn = ALEN(xaSel, 1)
 IF xaSel(nlEn,2)="***"
      ncOl = nlEn
 ELSE
      DIMENSION xaSel[nlEn+1, 2]
      ncOl = nlEn+1
 ENDIF
 xaSel[ncOl, 1] = xaAvl(pnItem,1)
 xaSel[ncOl, 2] = xaAvl(pnItem,2)
 M.nsEl = ncOl
 nlEn = ALEN(xaAvl, 1)
 IF nlEn=1
      xaAvl[1, 1] = ""
      xaAvl[1, 2] = "***"
      M.naVl = 1
 ELSE
      FOR j = pnItem TO nlEn-1
           xaAvl[j, 1] = xaAvl(j+1,1)
           xaAvl[j, 2] = xaAvl(j+1,2)
      ENDFOR
      DIMENSION xaAvl[nlEn-1, 2]
      M.naVl = MAX(pnItem-1, 1)
 ENDIF
 SHOW GET M.naVl
 SHOW GET M.nsEl
 RETURN 0
ENDFUNC
*
FUNCTION DeSelItem
 PARAMETER pnItem
 IF xaSel(pnItem,2)="***"
      RETURN 0
 ENDIF
 nlEn = ALEN(xaAvl, 1)
 IF xaAvl(nlEn,2)="***"
      ncOl = nlEn
 ELSE
      DIMENSION xaAvl[nlEn+1, 2]
      ncOl = nlEn+1
 ENDIF
 xaAvl[ncOl, 1] = xaSel(pnItem,1)
 xaAvl[ncOl, 2] = xaSel(pnItem,2)
 M.naVl = ncOl
 nlEn = ALEN(xaSel, 1)
 IF nlEn=1
      xaSel[1, 1] = ""
      xaSel[1, 2] = "***"
      M.nsEl = 1
 ELSE
      FOR j = pnItem TO nlEn-1
           xaSel[j, 1] = xaSel(j+1,1)
           xaSel[j, 2] = xaSel(j+1,2)
      ENDFOR
      DIMENSION xaSel[nlEn-1, 2]
      M.nsEl = MAX(pnItem-1, 1)
 ENDIF
 SHOW GET M.naVl
 SHOW GET M.nsEl
 RETURN 0
ENDFUNC
*
