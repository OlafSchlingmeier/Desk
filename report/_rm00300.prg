PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "7.01"
RETURN tcVersion
ENDPROC
*
PROCEDURE _rm00300
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_rm00300")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

PpCusorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
*
PROCEDURE PpCusorCreate
CREATE CURSOR PreProc (pp_rpseq N(4), pp_roomnum C(4), pp_roomtyp C(4), pp_floor N(2), pp_status C(3), pp_date D(8), pp_move C(1), pp_reserid N(12,3), pp_oooreas C(25))
INDEX ON pp_roomnum TAG pp_roomnum
SET ORDER TO
ENDPROC
*
PROCEDURE PpCusorInit
SELECT rm_rpseq, rm_roomnum, rm_roomtyp, rm_floor, ;
     ICASE(NOT ISNULL(oo_id),"OOO",NOT ISNULL(os_id),"OOS",rm_status), ;
     min1, "V", 0, NVL(NVL(oo_reason,os_reason),"") ;
     FROM Room ;
     INNER JOIN RoomType ON rt_roomtyp = rm_roomtyp AND rt_group = 1 ;
     LEFT JOIN OutOfOrd ON oo_roomnum = rm_roomnum AND BETWEEN(min1, oo_fromdat, oo_todat) AND NOT oo_cancel ;
     LEFT JOIN OutOfSer ON os_roomnum = rm_roomnum AND BETWEEN(min1, os_fromdat, os_todat) AND NOT os_cancel ;
     ORDER BY rm_rpseq, rm_rmname ;
     INTO ARRAY laRoom
INSERT INTO PreProc FROM ARRAY laRoom
ENDPROC
**********
DEFINE CLASS _rm00300 AS Session

PROCEDURE Init
Ini()
*OpenFile()
OpenFileDirect(,"PickList")
OpenFileDirect(,"Resrooms")
OpenFileDirect(,"Reservat")
OpenFileDirect(,"OutOfOrd")
OpenFileDirect(,"OutOfSer")
PpCusorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER taPreProc
LOCAL lcStatus, loPreproc

DO RoomStat IN Interfac
PpCusorInit()

SELECT ri_roomtyp, ri_roomnum, rs_status, rs_arrdate, rs_depdate, ri_reserid, ri_date, ri_todate ;
     FROM Resrooms ;
     INNER JOIN Reservat ON ri_reserid = rs_reserid ;
     INNER JOIN RoomType ON rt_roomtyp = ri_roomtyp AND rt_group = 1 ;
     WHERE ri_date <= min1 AND ri_todate >= min1-1 AND NOT EMPTY(ri_roomnum) AND NOT INLIST(rs_status, "CXL", "NS") ;
     ORDER BY rs_arrdate, rs_depdate, ri_date, ri_todate, ri_roomtyp, ri_roomnum, ri_reserid ;
     INTO CURSOR curReservat

SELECT curReservat
SCAN FOR SEEK(ri_roomnum,"PreProc","pp_roomnum")
     DO CASE
          CASE rs_depdate = PreProc.pp_date
               lcStatus = "D"
          CASE rs_arrdate = PreProc.pp_date AND (min4 OR rs_status = "IN")
               lcStatus = "A"
          CASE rs_arrdate = PreProc.pp_date
               lcStatus = "V"
          CASE ri_todate = PreProc.pp_date - 1
               lcStatus = "M"
          OTHERWISE
               lcStatus = "S"
     ENDCASE
     IF NOT EMPTY(PreProc.pp_reserid) AND lcStatus <> "V"
          SELECT PreProc
          SCATTER FIELDS EXCEPT pp_reserid, pp_move NAME loPreproc
          INSERT INTO PreProc FROM NAME loPreproc
          SELECT curReservat
     ENDIF
     IF EMPTY(PreProc.pp_reserid)
          REPLACE pp_reserid WITH curReservat.ri_reserid, pp_move WITH lcStatus IN PreProc
     ENDIF
ENDSCAN
USE

SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE
**********