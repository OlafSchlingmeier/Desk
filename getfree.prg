*
FUNCTION GetFree
LPARAMETER lp_cRoomtype, lp_dArrdate, lp_dDepdate
LOCAL i, l_nArea, l_cRoomnum, l_cRtGroup, l_nDumType, l_curRoom, l_curResrooms, l_cSql, l_cLinked, l_cRoomnums

l_nArea = SELECT()

l_cRoomnum = ""
lp_cRoomtype = PADR(UPPER(lp_cRoomtype),4)

l_cRtGroup = Get_rt_roomtyp(lp_cRoomtype,"EVL(rt_group,3)")
l_nDumType = Get_rt_roomtyp(lp_cRoomtype,"EVL(rt_dumtype,1)")

l_curResrooms = SYS(2015)
l_curRoom = SqlCursor("SELECT rm_roomnum FROM room WHERE rm_roomtyp = " + SqlCnv(lp_cRoomtype) + " ORDER BY rm_roomtyp, rm_sequ, rm_rpseq, rm_roomnum")
SCAN WHILE EMPTY(l_cRoomnum)
     IF l_cRtGroup = 3 AND l_nDumType = 2     && Allowed double booking DUM room
          l_cRoomnum = rm_roomnum
     ELSE
          l_cLinked = get_rm_rmname(rm_roomnum, "rm_linked")
          l_cRoomnums = "'" + rm_roomnum + "'"
          FOR i = 1 TO GETWORDCOUNT(l_cLinked, ",")
               l_cRoomnums = l_cRoomnums + ",'" + PADR(GETWORDNUM(l_cLinked,i,","),4) + "'"
          NEXT
          TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
               SELECT TOP 1 'x' FROM resrooms
                    INNER JOIN reservat ON ri_reserid = rs_reserid
                    WHERE ri_date <= <<SqlCnv(MAX(lp_dArrdate,lp_dDepdate-1),.T.)>> AND ri_todate >= <<SqlCnv(lp_dArrdate,.T.)>> AND
                    NOT INLIST(rs_status, 'CXL', 'NS ') AND INLIST(ri_roomnum,<<l_cRoomnums>>)
                    ORDER BY 1
          ENDTEXT
          SqlCursor(l_cSql, l_curResrooms)
          SELECT &l_curRoom
          IF RECCOUNT(l_curResrooms) = 0
               l_cRoomnum = rm_roomnum
          ENDIF
     ENDIF
ENDSCAN
DClose(l_curResrooms)
DClose(l_curRoom)

SELECT (l_nArea)

RETURN l_cRoomnum
ENDFUNC
*