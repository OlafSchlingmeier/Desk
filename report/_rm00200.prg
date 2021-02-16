FUNCTION PpVersion
PARAMETER cversion
cversion = "6.01"
RETURN .T.
ENDFUNC
*
PROCEDURE _RM00200
PRIVATE ALL LIKE l_*
l_rsord = ORDER("Reservat")
l_rsrec = RECNO("Reservat")
l_rmrec = RECNO('Room')
l_oldarea = SELECT()
WAIT WINDOW NOWAIT "Preprocessing..."
DO roomstat IN Interfac
l_fromdate = IIF(EMPTY(min1), sysdate(), min1)
l_todate = IIF(EMPTY(max1), min1, max1)
IF TYPE('Min2') = 'L'
     l_incldeps = min2
ELSE
     l_incldeps = .F.
ENDIF
CREATE CURSOR preproc (pp_rpseq N (4), pp_roomnum C (4), pp_roomtyp C (4), pp_floor N (2), pp_status C (3), pp_date D (8), pp_move C  ;
       (1), pp_reserid N (12, 3), pp_oooreas C (25))
= dopen('OutOfOrd')
SELECT room
GOTO TOP IN "Room"
SCAN FOR dblookup("RoomType", "Tag1",room.rm_roomtyp, "Rt_Group") == 1 WHILE .NOT. EOF("room")
     l_date = l_fromdate
     SELECT preproc
     DO WHILE (l_date <= l_todate)
          l_status = ''
          l_oooreas = ''
          IF dlocate('OutOfOrd', 'oo_fromdat <= ' + sqlcnv(l_date) +  ' and oo_todat >= ' + sqlcnv(l_date) +  ;
             ' and oo_roomnum = ' + sqlcnv(room.rm_roomnum) + 'and !oo_cancel')
               l_status = 'OOO'
               l_oooreas = outoford.oo_reason
          ELSE
               IF l_date = sysdate()
                    l_status = room.rm_status
               ENDIF
          ENDIF
          SELECT preproc
          INSERT INTO PreProc (pp_rpseq, pp_roomnum, pp_roomtyp, pp_floor, pp_status, pp_date, pp_oooreas)  ;
                 VALUES (room.rm_rpseq, room.rm_roomnum, room.rm_roomtyp, room.rm_floor, l_status, l_date, l_oooreas)
          SELECT room
          l_date = l_date + 1
     ENDDO
ENDSCAN
SELECT reservat
SET ORDER IN 'Reservat' TO 13
SELECT preproc
GOTO TOP IN "PreProc"
SCAN WHILE  .NOT. EOF("PreProc")
     l_status = ""
     l_reserid = 0
     l_date = preproc.pp_date
     SELECT reservat
     IF  .NOT.  ;
         SEEK(preproc.pp_roomnum, "Reservat")
          l_status = "V"
     ELSE
          SCAN WHILE reservat.rs_roomnum == preproc.pp_roomnum  .AND. reservat.rs_arrdate <= l_date
               DO CASE
                    CASE INLIST(reservat.rs_status, "NS", "CXL")
                    CASE reservat.rs_depdate == l_date
                         IF l_incldeps
                              l_status = 'D'
                              l_reserid = reservat.rs_reserid
                         ENDIF
                    CASE reservat.rs_arrdate == l_date
                         IF EMPTY(l_status)
                              l_status = 'A'
                         ELSE
                              l_status = 'C'
                         ENDIF
                         l_reserid = reservat.rs_reserid
                    CASE reservat.rs_arrdate < l_date .AND. reservat.rs_depdate > l_date
                         l_status = 'S'
                         l_reserid = reservat.rs_reserid
               ENDCASE
          ENDSCAN
     ENDIF
     SELECT preproc
     REPLACE preproc.pp_move WITH IIF(EMPTY(l_status), "V", l_status)
     REPLACE preproc.pp_reserid WITH l_reserid
ENDSCAN
WAIT CLEAR
SET ORDER IN 'Reservat' TO l_RsOrd
GOTO l_rsrec IN 'Reservat'
GOTO l_rmrec IN 'Room'
= dclose('OutOfOrd')
SELECT (l_oldarea)
RETURN
ENDPROC


