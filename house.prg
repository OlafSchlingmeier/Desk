*
FUNCTION HouseKeep
 do form "forms\MngForm" with "MngHouseKeepCtrl"
 RETURN
 
 PRIVATE cbUttons
 PRIVATE csTatus, nfLoor, adLg
 PRIVATE clEvel
 PRIVATE nhOusearea
 PRIVATE cfOrexpression
 PRIVATE acHkfields
 DIMENSION adLg[2, 8]
 adLg[1, 1] = "status"
 adLg[1, 2] = GetLangText("HOUSE","T_STATUS")
 adLg[1, 3] = "Space(3)"
 adLg[1, 4] = "!!!"
 adLg[1, 5] = 6
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = ""
 adLg[2, 1] = "floor"
 adLg[2, 2] = GetLangText("HOUSE","T_FLOOR")
 adLg[2, 3] = "0"
 adLg[2, 4] = "99"
 adLg[2, 5] = 6
 adLg[2, 6] = ""
 adLg[2, 7] = ""
 adLg[2, 8] = 0
 IF diAlog(GetLangText("HOUSE","TH_HOUSE"),"",@adLg)
      csTatus = adLg(1,8)
      nfLoor = adLg(2,8)
      DO roOmstat IN Interfac
      DIMENSION acHkfields[8, 3]
      acHkfields[1, 1] = "PadC(TmpHouse.TmpMarker, 3)"
      acHkfields[1, 2] = 3
      acHkfields[1, 3] = PADC(CHR(187), 3)
      acHkfields[2, 1] = 'rm_roomnum'
      acHkfields[2, 2] = 8
      acHkfields[2, 3] = GetLangText("HOUSE","TH_ROOMNUM")
      acHkfields[3, 1] = 'rm_roomtyp'
      acHkfields[3, 2] = 8
      acHkfields[3, 3] = GetLangText("HOUSE","TH_ROOMTYPE")
      acHkfields[4, 1] = 'rm_lang'+g_Langnum
      acHkfields[4, 2] = 25
      acHkfields[4, 3] = GetLangText("HOUSE","TH_DESCRIPT")
      acHkfields[5, 1] = 'rm_floor'
      acHkfields[5, 2] = 8
      acHkfields[5, 3] = GetLangText("HOUSE","TH_FLOOR")
      acHkfields[6, 1] = 'rm_status'
      acHkfields[6, 2] = 8
      acHkfields[6, 3] = GetLangText("HOUSE","TH_STATUS")
      acHkfields[7, 1] = 'DispOccupied()'
      acHkfields[7, 2] = 16
      acHkfields[7, 3] = GetLangText("HOUSE","TH_RESERVATION")
      acHkfields[8, 1] = 'rm_maid'
      acHkfields[8, 2] = 12
      acHkfields[8, 3] = GetLangText("HOUSE","TH_MAID")
      cfOrexpression = ""
      clEvel = ""
      cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
                 buTton(clEvel,GetLangText("HOUSE","TXT_CLEAN"),2)+buTton(clEvel, ;
                 GetLangText("HOUSE","TXT_DIRTY"),3)+buTton(clEvel,GetLangText("HOUSE", ;
                 "TXT_CLNALL"),4)+buTton(clEvel,GetLangText("HOUSE", ;
                 "TXT_DIRALL"),5)+buTton(clEvel,GetLangText("HOUSE","TXT_MARK"), ;
                 6)+buTton(clEvel,GetLangText("HOUSE","TXT_MARKALL"),7)+ ;
                 buTton(clEvel,GetLangText("HOUSE","TXT_MAID"),-8)
      CREATE CURSOR TmpHouse (tmPrecno N (13), tmPmarker C (1))
      INDEX ON tmPrecno TAG taG1
      SELECT roOm
      SET RELATION ADDITIVE TO RECNO() INTO tmPhouse
      GOTO TOP
      IF ( .NOT. EMPTY(csTatus))
           cfOrexpression = cfOrexpression+[rm_status = ']+csTatus+['.and.]
      ENDIF
      IF ( .NOT. EMPTY(nfLoor))
           cfOrexpression = cfOrexpression+'rm_floor = '+ ;
                            LTRIM(STR(nfLoor))+'.and.'
      ENDIF
      IF ( .NOT. EMPTY(cfOrexpression))
           cfOrexpression = SUBSTR(cfOrexpression, 1, LEN(cfOrexpression)-5)
      ELSE
           cfOrexpression = ".t."
      ENDIF
      chOubutton = gcButtonfunction
      gcButtonfunction = ""
      = myBrowse(GetLangText("HOUSE","TH_HOUSE"),20,@acHkfields,cfOrexpression, ;
        ".t.",'2'+cbUttons,"vControl","house",'','',0,'Room')
      gcButtonfunction = chOubutton
      USE IN tmPhouse
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION vControl
 PARAMETER p_Option
 PRIVATE ncUrrent
 PRIVATE crOommaid
 DO CASE
      CASE p_Option==1
      CASE p_Option==2
           IF (roOm.rm_status<>"OOO")
                REPLACE roOm.rm_status WITH "CLN"
                g_Refreshcurr = .T.
           ELSE
                IF (yeSno(GetLangText("HOUSE","TXT_CLN_OOO_ROOM")))
                     REPLACE roOm.rm_status WITH "CLN"
                     g_Refreshcurr = .T.
                ENDIF
           ENDIF
      CASE p_Option==3
           IF (roOm.rm_status<>"OOO")
                REPLACE roOm.rm_status WITH "DIR"
                g_Refreshcurr = .T.
           ELSE
                IF (yeSno(GetLangText("HOUSE","TXT_DIR_OOO_ROOM")))
                     REPLACE roOm.rm_status WITH "CLN"
                     g_Refreshcurr = .T.
                ENDIF
           ENDIF
      CASE p_Option==4
           SELECT roOm
           ncUrrent = RECNO()
           GOTO TOP
           DO WHILE ( .NOT. EOF("Room"))
                If ( &cForExpression )
                     IF (roOm.rm_status<>"OOO")
                          REPLACE roOm.rm_status WITH "CLN"
                     ENDIF
                ENDIF
                SKIP 1 IN roOm
           ENDDO
           GOTO ncUrrent
           g_Refreshall = .T.
      CASE p_Option==5
           SELECT roOm
           ncUrrent = RECNO()
           GOTO TOP
           DO WHILE ( .NOT. EOF("Room"))
                If ( &cForExpression )
                     IF (roOm.rm_status<>"OOO")
                          REPLACE roOm.rm_status WITH "DIR"
                     ENDIF
                ENDIF
                SKIP 1 IN roOm
           ENDDO
           GOTO ncUrrent
           g_Refreshall = .T.
      CASE p_Option==6
           SELECT roOm
           DO toGglemove
           g_Refreshcurr = .T.
      CASE p_Option==7
           SELECT roOm
           ncUrrent = RECNO()
           GOTO TOP
           DO WHILE ( .NOT. EOF("Room"))
                If ( &cForExpression )
                     IF (roOm.rm_status<>"OOO")
                          DO toGgle
                     ENDIF
                ENDIF
                SKIP 1 IN roOm
           ENDDO
           GOTO ncUrrent
           g_Refreshall = .T.
      CASE p_Option==8
           crOommaid = SPACE(20)
           IF geTmaid(@crOommaid)
                SELECT roOm
                ncUrrent = RECNO()
                scan all for ( &cForExpression ) and !Eof('TmpHouse') and TmpHouse.TmpMarker == Chr(187)
                     REPLACE roOm.rm_maid WITH crOommaid
                     DO toGgle
                ENDSCAN
                GOTO ncUrrent
                g_Refreshall = .T.
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE RoomHistory
*
	doform("frmroomhistory","forms\roomhistory")
	RETURN
*
 PRIVATE naRea
 PRIVATE adLg, crOomnum, dfRom, dtO
 PRIVATE a_Fields
 LOCAL l_cCurName, l_cRoomName
 l_cCurName = SYS(2015)
 naRea = SELECT()
 DIMENSION a_Fields[8, 3]
 a_Fields[1, 1] = 'hr_rmname'
 a_Fields[1, 2] = 12
 a_Fields[1, 3] = GetLangText("HOUSE","TH_ROOMNUM")
 a_Fields[2, 1] = 'hr_roomtyp'
 a_Fields[2, 2] = 6
 a_Fields[2, 3] = GetLangText("HOUSE","TH_ROOMTYPE")
 a_Fields[3, 1] = 'Trim(ad_lname) + ", " + Trim(ad_fname)'
 a_Fields[3, 2] = 25
 a_Fields[3, 3] = GetLangText("HOUSE","TH_NAME")
 a_Fields[4, 1] = 'ad_city'
 a_Fields[4, 2] = 20
 a_Fields[4, 3] = GetLangText("HOUSE","TH_CITY")
 a_Fields[5, 1] = 'hr_arrdate'
 a_Fields[5, 2] = 10
 a_Fields[5, 3] = GetLangText("HOUSE","TH_ARRDATE")
 a_Fields[6, 1] = 'hr_depdate'
 a_Fields[6, 2] = 10
 a_Fields[6, 3] = GetLangText("HOUSE","TH_DEPDATE")
 a_Fields[7, 1] = 'hr_arrtime'
 a_Fields[7, 2] = 8
 a_Fields[7, 3] = GetLangText("HOUSE","TH_FROM")
 a_Fields[8, 1] = 'hr_deptime'
 a_Fields[8, 2] = 8
 a_Fields[8, 3] = GetLangText("HOUSE","TH_TO")
 DIMENSION adLg[3, 8]
 adLg[1, 1] = "roomnum"
 adLg[1, 2] = GetLangText("HOUSE","T_ROOMNUM")
 adLg[1, 3] = "Space(10)"
 adLg[1, 4] = "!!!!!!!!!!"
 adLg[1, 5] = 12
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = ""
 adLg[2, 1] = "from"
 adLg[2, 2] = GetLangText("HOUSE","T_DEPDATE")
 adLg[2, 3] = "SysDate() - 8"
 adLg[2, 4] = ""
 adLg[2, 5] = 11
 adLg[2, 6] = "!Empty(from)"
 adLg[2, 7] = ""
 adLg[2, 8] = {}
 adLg[3, 1] = "to"
 adLg[3, 2] = ""
 adLg[3, 3] = "SysDate() - 1"
 adLg[3, 4] = ""
 adLg[3, 5] = 11
 adLg[3, 6] = "!Empty(to) And to >= from"
 adLg[3, 7] = ""
 adLg[3, 8] = {}
 IF diAlog(GetLangText("HOUSE","TW_ROOMHIST"),"",@adLg)
      l_cRoomName = adLg(1,8)
      crOomnum = get_rm_roomnum(l_cRoomName)
      dfRom = adLg(2,8)
      dtO = adLg(3,8)
      SELECT PADR(Get_rm_rmname(hr_roomnum),10) AS hr_rmname, * FROM histres, address WHERE hr_roomnum=crOomnum AND  ;
               BETWEEN(hr_depdate, dfRom, dtO) AND hr_addrid=ad_addrid  ;
               ORDER BY hr_depdate INTO CURSOR &l_cCurName
      IF _TALLY>0
           chO1button = gcButtonfunction
           gcButtonfunction = ""
           DO myBrowse WITH GetLangText("HOUSE","TW_ROOMHIST"), 5, a_Fields,  ;
              ".t.", ".t.", GetLangText("COMMON","TXT_OK"), "", ""
           gcButtonfunction = chO1button
      ELSE
           = alErt(GetLangText("HOUSE","TA_NOHIST")+"!")
      ENDIF
      = clOsefile(l_cCurName)
 ENDIF
 SELECT (naRea)
 RETURN
ENDPROC
*
PROCEDURE Toggle
 IF RECNO("room")<>tmPhouse.tmPrecno
      INSERT INTO TmpHouse (tmPrecno, tmPmarker) VALUES (RECNO("room"),  ;
             CHR(187))
 ELSE
      REPLACE tmPhouse.tmPmarker WITH IIF(EMPTY(tmPhouse.tmPmarker),  ;
              CHR(187), "")
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE ToggleMove
 PUSH KEY CLEAR
 DO toGgle
 DO moVe IN MyBrowse WITH 1
 POP KEY
 RETURN
ENDPROC
*
FUNCTION GetMaid
 PARAMETER pcRoommaid
 PRIVATE adLg, lrEt
 DIMENSION adLg[1, 8]
 adLg[1, 1] = "roommaid"
 adLg[1, 2] = GetLangText("HOUSE","T_MAID")
 adLg[1, 3] = "Space(20)"
 adLg[1, 4] = REPLICATE("!", 20)
 adLg[1, 5] = 20
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = ""
 IF diAlog(GetLangText("HOUSE","TW_MAID"),"",@adLg)
      pcRoommaid = adLg(1,8)
      lrEt = .T.
 ELSE
      lrEt = .F.
 ENDIF
 RETURN lrEt
ENDFUNC
*
FUNCTION DispOccupied
 PRIVATE crEt, naRea, nrSrec, nrPord
 crEt = ""
 naRea = SELECT()
 SELECT reServat
 nrSrec = RECNO()
 nrSord = ORDER()
 SET ORDER TO 6
 IF SEEK("1"+roOm.rm_roomnum) .AND.  .NOT. INLIST(rs_status, "NS", "CXL")  ;
    .AND. EMPTY(rs_out)
      crEt = GetLangText("HOUSE","TXT_OCCUPIED")+" ("+LTRIM(STR(sySdate()- ;
             rs_arrdate))+")"
 ENDIF
 SET ORDER TO 9
 IF SEEK(DTOS(sySdate())+roOm.rm_roomnum) .AND.  .NOT. INLIST(rs_status,  ;
    "NS", "CXL")
      crEt = GetLangText("HOUSE","TXT_DEPARTURE")+" ("+TRIM(rs_status)+")"
 ENDIF
 SET ORDER TO 13
 IF SEEK(roOm.rm_roomnum+DTOS(sySdate())) .AND.  .NOT. INLIST(rs_status,  ;
    "NS", "CXL")
      crEt = GetLangText("HOUSE","TXT_ARRIVAL")+" ("+TRIM(rs_status)+")"
 ENDIF
 SET ORDER TO nRsOrd
 GOTO nrSrec
 SELECT (naRea)
 RETURN crEt
ENDFUNC
*
