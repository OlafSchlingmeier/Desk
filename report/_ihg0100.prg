* erstellt 18.04.2004 Dipl-Ing. H.Knabe
PROCEDURE PpVersion
PARAMETER cversion
cversion = "6.04"
RETURN
ENDPROC

PROCEDURE _IHG0100
LOCAL start, ende
PRIVATE art
A = 0
zaehler = max1 - min1
oldselect = SELECT()
CREATE CURSOR preproc (pp_reserid N(12,3), pp_group C(25), pp_company c(30), pp_name C(30), pp_arrdate D(8), pp_depdate D(8), ;
	pp_roomnum C(4), pp_roomtyp C(4), pp_cnfstat C(10), pp_status C(4), pp_rooms N(2), pp_adults N(3), ;
	pp_childs N(3), pp_childs2 N(3), pp_childs3 N(3), pp_arrtime C(5), pp_deptime C(5), pp_Day D(8))
** SELECT rt_roomtyp FROM RoomType WHERE rt_group = 2 INTO ARRAY art
SELECT reservat
FOR A = 0 TO zaehler
SCAN ALL
     WAIT WINDOW NOWAIT DTOC(min1 + A) + " - " + STR(rs_reserid, 12, 3)
     IF BETWEEN(min1 + A, rs_arrdate, rs_depdate) AND rs_depdate > min1 + A AND !INLIST(rs_status, 'CXL', 'NS') &&AND ASCAN(art, rs_roomtyp) > 0
		 INSERT INTO preproc (pp_reserid, pp_group, pp_company, pp_name, pp_arrdate, pp_depdate, pp_roomnum, pp_roomtyp, ;
		 	pp_cnfstat, pp_status, pp_rooms, pp_adults, pp_childs, pp_childs2, pp_childs3, pp_arrtime, pp_deptime, pp_day) ;
		 	VALUES (reservat.rs_reserid, reservat.rs_group, LTrim(reservat.rs_company), LTRIM(reservat.rs_lname), reservat.rs_arrdate, ;
		 	reservat.rs_depdate, reservat.rs_roomnum, reservat.rs_roomtyp, reservat.rs_cnfstat, reservat.rs_status, ;
		 	reservat.rs_rooms, reservat.rs_adults, reservat.rs_childs, reservat.rs_childs2, reservat.rs_childs3, ;
		 	reservat.rs_arrtime, reservat.rs_deptime, Min1 + A)
	ENDIF
ENDSCAN
endfor
SELECT = oldselect
WAIT clear
RETURN
ENDPROC 
