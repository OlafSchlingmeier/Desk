FUNCTION PpVersion
 PARAMETER cvErsion
 cvErsion = "6.03"
 RETURN .T.
ENDFUNC
*
PROCEDURE _rm00210
 PRIVATE ALL LIKE l_*
 l_Rsord = ORDER("Reservat")
 l_Rsrec = RECNO("Reservat")
 l_Rmrec = RECNO('Room')
 l_Oldarea = SELECT()
 WAIT WINDOW NOWAIT "Preprocessing..."
 CREATE CURSOR preproc (pp_rpseq N (4), pp_roomnum C (4), pp_roomtyp C  ;
        (4), pp_floor N (2), pp_status C (3), pp_date D (8), pp_ndate D  ;
        (8), pp_move C (1), pp_reserid N (12, 3), pp_oooreas C (25))
 = doPen('OutOfOrd')
 SELECT roOm
 GOTO TOP IN "Room"
 SCAN FOR dbLookup("RoomType","Tag1",roOm.rm_roomtyp,"Rt_Group")==1 WHILE   ;
      .NOT. EOF("room")
      l_Date = miN1
      l_Ndate = CTOD(" ")
      SELECT prEproc
      l_Status = ''
      l_Oooreas = ''
      IF dlOcate('OutOfOrd','oo_fromdat <= '+sqLcnv(l_Date)+ ;
         ' and oo_todat >= '+sqLcnv(l_Date)+' and oo_roomnum = '+ ;
         sqLcnv(roOm.rm_roomnum))
           l_Status = 'OOO'
           l_Oooreas = ouToford.oo_reason
      ELSE
           l_Status = roOm.rm_status
      ENDIF
      l_Status = roOm.rm_status
      SELECT prEproc
      INSERT INTO PreProc (pp_rpseq, pp_roomnum, pp_roomtyp, pp_floor,  ;
             pp_status, pp_date, pp_ndate, pp_oooreas) VALUES  ;
             (roOm.rm_rpseq, roOm.rm_roomnum, roOm.rm_roomtyp,  ;
             roOm.rm_floor, l_Status, l_Date, l_Ndate, l_Oooreas)
      SELECT roOm
 ENDSCAN
 SELECT reServat
 SET ORDER IN 'Reservat' TO 13
 SELECT prEproc
 GOTO TOP IN "PreProc"
 SCAN WHILE  .NOT. EOF("PreProc")
      l_Status = ""
      l_Reserid = 0
      l_Date = prEproc.pp_date
      l_Ndate = CTOD(" ")
      SELECT reServat
      IF  .NOT. SEEK(prEproc.pp_roomnum, "Reservat")
           l_Status = "V"
      ELSE
           SCAN WHILE reServat.rs_roomnum==prEproc.pp_roomnum
                DO CASE
                     CASE INLIST(reServat.rs_status, "NS", "CXL","OUT")
                     CASE reServat.rs_depdate==l_Date
                          l_Status = 'V'
                          l_Reserid = reServat.rs_reserid
                     CASE reServat.rs_arrdate==l_Date
                          l_Status = 'A'
                          l_Reserid = reServat.rs_reserid
                     CASE reServat.rs_arrdate<l_Date .AND.  ;
                          reServat.rs_depdate>l_Date
                          l_Status = 'S'
                          l_Reserid = reServat.rs_reserid
                     CASE reServat.rs_arrdate>l_Date
                          IF EMPTY(l_Ndate)
                               l_Ndate = reServat.rs_arrdate
                          ENDIF
                ENDCASE
           ENDSCAN
      ENDIF
      SELECT prEproc
      REPLACE prEproc.pp_move WITH IIF(EMPTY(l_Status), "V", l_Status)
      REPLACE prEproc.pp_reserid WITH l_Reserid
      REPLACE prEproc.pp_ndate WITH l_Ndate
 ENDSCAN
 WAIT CLEAR
 SET ORDER IN 'Reservat' TO l_RsOrd
 GOTO l_Rsrec IN 'Reservat'
 GOTO l_Rmrec IN 'Room'
 = dcLose('OutOfOrd')
 SELECT (l_Oldarea)
 RETURN
ENDPROC
*
