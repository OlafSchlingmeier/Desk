FUNCTION PpVersion
PARAMETER cversion
cversion = "6.06"
RETURN .T.
ENDFUNC
*
PROCEDURE _rm00211
PRIVATE ALL LIKE l_*
l_rsord = ORDER("Reservat")
l_rsrec = RECNO("Reservat")
l_rmrec = RECNO('Room')
l_oldarea = SELECT()
SELECT 0
IF !USED('outofser')
     openfiledirect(.F., "outofser")
ENDIF 
WAIT WINDOW NOWAIT "Preprocessing..."
CREATE CURSOR preproc (pp_rpseq N (4), pp_roomnum C (4), pp_roomtyp C (4), pp_floor N (2), pp_status C (3), pp_date D (8), pp_ndate D (8), ;
      pp_move C (1), pp_reserid N (12, 3), pp_oooreas C (25))
= dopen('OutOfOrd')
SELECT room
GOTO TOP IN "Room"
SCAN FOR dblookup("RoomType", "Tag1",room.rm_roomtyp, "Rt_Group") == 1 WHILE   .NOT. EOF("room")
     l_date = min1
     l_ndate = CTOD(" ")
     SELECT preproc
     l_status = ''
     l_oooreas = ''
     IF dlocate('OutOfOrd', 'oo_fromdat <= ' + sqlcnv(l_date) + ' and oo_todat >= ' + sqlcnv(l_date) +  ;
        ' and oo_roomnum = ' + sqlcnv(room.rm_roomnum) + 'and !oo_cancel')
          l_status = 'OOO'
          l_oooreas = outoford.oo_reason
     ELSE
         IF dlocate('OutOfSer', 'os_fromdat <= ' + sqlcnv(l_date) + ' and os_todat >= ' + sqlcnv(l_date) +  ;
           ' and os_roomnum = ' + sqlcnv(room.rm_roomnum) + 'and !os_cancel')
        	l_status = 'OOS'
         	l_oooreas = outofser.os_reason
	     ELSE
          	l_status = room.rm_status
         ENDIF 
     ENDIF

     l_status = room.rm_status
     SELECT preproc
     INSERT INTO PreProc (pp_rpseq, pp_roomnum, pp_roomtyp, pp_floor, pp_status, pp_date, pp_ndate, pp_oooreas) VALUES (room.rm_rpseq,  ;
            room.rm_roomnum, room.rm_roomtyp, room.rm_floor, l_status, l_date, l_ndate, l_oooreas)
     SELECT room
ENDSCAN
SELECT reservat
SET ORDER IN 'Reservat' TO 13
SELECT preproc
GOTO TOP IN "PreProc"
SCAN WHILE  .NOT. EOF("PreProc")
     l_status = ""
     l_reserid = 0
     l_date = preproc.pp_date
     l_ndate = CTOD(" ")
     SELECT reservat
     IF  .NOT.  ;
         SEEK(preproc.pp_roomnum, "Reservat")
          l_status = "V"
     ELSE
          SCAN WHILE reservat.rs_roomnum == preproc.pp_roomnum
               DO CASE
                    CASE INLIST(reservat.rs_status, "NS", "CXL", "OUT")
                    CASE reservat.rs_depdate == l_date
                         l_status = 'V'
                         l_reserid = reservat.rs_reserid
                    CASE reservat.rs_arrdate == l_date
                         l_status = 'A'
                         l_reserid = reservat.rs_reserid
                    CASE reservat.rs_arrdate < l_date .AND. reservat.rs_depdate > l_date
                         l_status = 'S'
                         l_reserid = reservat.rs_reserid
                    CASE reservat.rs_arrdate > l_date
                         IF EMPTY(l_ndate)
                              l_ndate = reservat.rs_arrdate
                         ENDIF
               ENDCASE
          ENDSCAN
     ENDIF
     SELECT preproc
     REPLACE preproc.pp_move WITH IIF(EMPTY(l_status), "V", l_status)
     REPLACE preproc.pp_reserid WITH l_reserid
     REPLACE preproc.pp_ndate WITH l_ndate
ENDSCAN
WAIT CLEAR
SET ORDER IN 'Reservat' TO l_RsOrd
GOTO l_rsrec IN 'Reservat'
GOTO l_rmrec IN 'Room'
= dclose('OutOfOrd')
SELECT (l_oldarea)
RETURN
ENDPROC

