PROCEDURE ppVersion
 PARAMETER cversion
 cversion = '1.02'
 RETURN
ENDPROC
**
PROCEDURE _wp00100
PRIVATE ALL LIKE l_*
l_rsord = ORDER("Reservat")
l_rsrec = RECNO("Reservat")
l_rmrec = RECNO('Room')
l_oldarea = SELECT()
WAIT WINDOW NOWAIT "Preprocessing..."
l_fromdate = IIF(EMPTY(min1), sysdate(), min1)
CREATE CURSOR preproc (pp_roomnum C (4), pp_roomtyp C (4), pp_reserid N(12,3), ;
	pp_day1li1 C(50), pp_day1li2 C(50), pp_day1li3 C(10), pp_day1li4 C(15), pp_day1li5 C(100), pp_day1sta C(1), ;
	pp_day2li1 C(50), pp_day2li2 C(50), pp_day2li3 C(10), pp_day2li4 C(15), pp_day2li5 C(100), pp_day2sta C(1), ;
	pp_day3li1 C(50), pp_day3li2 C(50), pp_day3li3 C(10), pp_day3li4 C(15), pp_day3li5 C(100), pp_day3sta C(1), ;
	pp_day4li1 C(50), pp_day4li2 C(50), pp_day4li3 C(10), pp_day4li4 C(15), pp_day4li5 C(100), pp_day4sta C(1), ;
	pp_day5li1 C(50), pp_day5li2 C(50), pp_day5li3 C(10), pp_day5li4 C(15), pp_day5li5 C(100), pp_day5sta C(1), ;
	pp_day6li1 C(50), pp_day6li2 C(50), pp_day6li3 C(10), pp_day6li4 C(15), pp_day6li5 C(100), pp_day6sta C(1), ;
	pp_day7li1 C(50), pp_day7li2 C(50), pp_day7li3 C(10), pp_day7li4 C(15), pp_day7li5 C(100), pp_day7sta C(1)  ;
	)
SELECT reservat
GO top
SCAN
	IF dblookup("RoomType", "Tag1", reservat.rs_roomtyp, "Rt_Group")==2 AND !INLIST(rs_status,"OUT","NS","CXL","LST","TEN") AND ;
	    rs_arrdate <= l_fromdate+6 AND rs_depdate >=l_fromdate
	   ** DAY 1
	   IF BETWEEN(l_fromdate, rs_arrdate, rs_depdate)
			SELECT preproc
			LOCATE FOR pp_roomnum = reservat.rs_roomnum AND pp_reserid = reservat.rs_reserid
				IF !FOUND()
					APPEND BLANK
				ENDIF 
			REPLACE pp_roomnum WITH reservat.rs_roomnum, pp_roomtyp WITH reservat.rs_roomtyp, pp_reserid WITH reservat.rs_reserid
			REPLACE pp_day1li1 WITH reservat.rs_group, pp_day1li2 WITH ALLTRIM(TRIM(reservat.rs_company)+" "+TRIM(reservat.rs_lname))
			replace pp_day1li3 WITH STR(reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3,3,0), pp_day1li4 WITH reservat.rs_arrtime+"-"+reservat.rs_deptime
			REPLACE pp_day1li5 WITH reservat.rs_usrres1
			DO case
				CASE reservat.rs_arrdate = l_fromdate
					replace pp_day1sta WITH "A"
				CASE reservat.rs_arrdate < l_fromdate AND reservat.rs_depdate= l_fromdate
					replace pp_day1sta WITH "D"
				CASE reservat.rs_arrdate < l_fromdate AND reservat.rs_depdate > l_fromdate
					replace pp_day1sta WITH "S"
			ENDCASE
		ENDIF 
		** DAY 2
	  	IF BETWEEN(l_fromdate+1, reservat.rs_arrdate, reservat.rs_depdate)
			SELECT preproc
			LOCATE FOR pp_roomnum = reservat.rs_roomnum AND pp_reserid = reservat.rs_reserid
				IF !FOUND()
					APPEND BLANK
				ENDIF 
			REPLACE pp_roomnum WITH reservat.rs_roomnum, pp_roomtyp WITH reservat.rs_roomtyp, pp_reserid WITH reservat.rs_reserid
			REPLACE pp_day2li1 WITH reservat.rs_group, pp_day2li2 WITH ALLTRIM(TRIM(reservat.rs_company)+" "+TRIM(reservat.rs_lname))
			replace pp_day2li3 WITH STR(reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3,3,0), pp_day2li4 WITH reservat.rs_arrtime+"-"+reservat.rs_deptime
			REPLACE pp_day2li5 WITH reservat.rs_usrres1
			DO case
				CASE reservat.rs_arrdate = l_fromdate+1
					replace pp_day2sta WITH "A"
				CASE reservat.rs_arrdate < l_fromdate+1 AND reservat.rs_depdate= l_fromdate+1
					replace pp_day2sta WITH "D"
				CASE reservat.rs_arrdate < l_fromdate+1 AND reservat.rs_depdate > l_fromdate+1
					replace pp_day2sta WITH "S"
			ENDCASE
		ENDIF 
		** DAY 3
	  	IF BETWEEN(l_fromdate+2, reservat.rs_arrdate, reservat.rs_depdate)
			SELECT preproc
			LOCATE FOR pp_roomnum = reservat.rs_roomnum AND pp_reserid = reservat.rs_reserid
				IF !FOUND()
					APPEND BLANK
				ENDIF 
			REPLACE pp_roomnum WITH reservat.rs_roomnum, pp_roomtyp WITH reservat.rs_roomtyp, pp_reserid WITH reservat.rs_reserid
			REPLACE pp_day3li1 WITH reservat.rs_group, pp_day3li2 WITH ALLTRIM(TRIM(reservat.rs_company)+" "+TRIM(reservat.rs_lname))
			replace pp_day3li3 WITH STR(reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3,3,0), pp_day3li4 WITH reservat.rs_arrtime+"-"+reservat.rs_deptime
			REPLACE pp_day3li5 WITH reservat.rs_usrres1
			DO case
				CASE reservat.rs_arrdate = l_fromdate+2
					replace pp_day3sta WITH "A"
				CASE reservat.rs_arrdate < l_fromdate+2 AND reservat.rs_depdate= l_fromdate+2
					replace pp_day3sta WITH "D"
				CASE reservat.rs_arrdate < l_fromdate+2 AND reservat.rs_depdate > l_fromdate+2
					replace pp_day3sta WITH "S"
			ENDCASE
		ENDIF 
		** DAY 4
	  	IF BETWEEN(l_fromdate+3, reservat.rs_arrdate, reservat.rs_depdate)
			SELECT preproc
			LOCATE FOR pp_roomnum = reservat.rs_roomnum AND pp_reserid = reservat.rs_reserid
				IF !FOUND()
					APPEND BLANK
				ENDIF 
			REPLACE pp_roomnum WITH reservat.rs_roomnum, pp_roomtyp WITH reservat.rs_roomtyp, pp_reserid WITH reservat.rs_reserid
			REPLACE pp_day4li1 WITH reservat.rs_group, pp_day4li2 WITH ALLTRIM(TRIM(reservat.rs_company)+" "+TRIM(reservat.rs_lname))
			replace pp_day4li3 WITH STR(reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3,3,0), pp_day4li4 WITH reservat.rs_arrtime+"-"+reservat.rs_deptime
			REPLACE pp_day4li5 WITH reservat.rs_usrres1
			DO case
				CASE reservat.rs_arrdate = l_fromdate+3
					replace pp_day4sta WITH "A"
				CASE reservat.rs_arrdate < l_fromdate+3 AND reservat.rs_depdate= l_fromdate+3
					replace pp_day4sta WITH "D"
				CASE reservat.rs_arrdate < l_fromdate+3 AND reservat.rs_depdate > l_fromdate+3
					replace pp_day4sta WITH "S"
			ENDCASE
		ENDIF 
		** DAY 5
	  	IF BETWEEN(l_fromdate+4, reservat.rs_arrdate, reservat.rs_depdate)
			SELECT preproc
			LOCATE FOR pp_roomnum = reservat.rs_roomnum AND pp_reserid = reservat.rs_reserid
				IF !FOUND()
					APPEND BLANK
				ENDIF 
			REPLACE pp_roomnum WITH reservat.rs_roomnum, pp_roomtyp WITH reservat.rs_roomtyp, pp_reserid WITH reservat.rs_reserid
			REPLACE pp_day5li1 WITH reservat.rs_group, pp_day5li2 WITH ALLTRIM(TRIM(reservat.rs_company)+" "+TRIM(reservat.rs_lname))
			replace pp_day5li3 WITH STR(reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3,3,0), pp_day5li4 WITH reservat.rs_arrtime+"-"+reservat.rs_deptime
			REPLACE pp_day5li5 WITH reservat.rs_usrres1
			DO case
				CASE reservat.rs_arrdate = l_fromdate+4
					replace pp_day5sta WITH "A"
				CASE reservat.rs_arrdate < l_fromdate+4 AND reservat.rs_depdate= l_fromdate+4
					replace pp_day5sta WITH "D"
				CASE reservat.rs_arrdate < l_fromdate+4 AND reservat.rs_depdate > l_fromdate+4
					replace pp_day5sta WITH "S"
			ENDCASE
		ENDIF 
		** DAY 6
	  	IF BETWEEN(l_fromdate+5, reservat.rs_arrdate, reservat.rs_depdate)
			SELECT preproc
			LOCATE FOR pp_roomnum = reservat.rs_roomnum AND pp_reserid = reservat.rs_reserid
				IF !FOUND()
					APPEND BLANK
				ENDIF 
			REPLACE pp_roomnum WITH reservat.rs_roomnum, pp_roomtyp WITH reservat.rs_roomtyp, pp_reserid WITH reservat.rs_reserid
			REPLACE pp_day6li1 WITH reservat.rs_group, pp_day6li2 WITH ALLTRIM(TRIM(reservat.rs_company)+" "+TRIM(reservat.rs_lname))
			replace pp_day6li3 WITH STR(reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3,3,0), pp_day6li4 WITH reservat.rs_arrtime+"-"+reservat.rs_deptime
			REPLACE pp_day6li5 WITH reservat.rs_usrres1
			DO case
				CASE reservat.rs_arrdate = l_fromdate+5
					replace pp_day6sta WITH "A"
				CASE reservat.rs_arrdate < l_fromdate+5 AND reservat.rs_depdate= l_fromdate+5
					replace pp_day6sta WITH "D"
				CASE reservat.rs_arrdate < l_fromdate+5 AND reservat.rs_depdate > l_fromdate+5
					replace pp_day6sta WITH "S"
			ENDCASE
		ENDIF 
		** DAY 7
	  	IF BETWEEN(l_fromdate+6, reservat.rs_arrdate, reservat.rs_depdate)
			SELECT preproc
			LOCATE FOR pp_roomnum = reservat.rs_roomnum AND pp_reserid = reservat.rs_reserid
				IF !FOUND()
					APPEND BLANK
				ENDIF 
			REPLACE pp_roomnum WITH reservat.rs_roomnum, pp_roomtyp WITH reservat.rs_roomtyp, pp_reserid WITH reservat.rs_reserid
			REPLACE pp_day7li1 WITH reservat.rs_group, pp_day7li2 WITH ALLTRIM(TRIM(reservat.rs_company)+" "+TRIM(reservat.rs_lname))
			replace pp_day7li3 WITH STR(reservat.rs_adults+reservat.rs_childs+reservat.rs_childs2+reservat.rs_childs3,3,0), pp_day7li4 WITH reservat.rs_arrtime+"-"+reservat.rs_deptime
			REPLACE pp_day7li5 WITH reservat.rs_usrres1
			DO case
				CASE reservat.rs_arrdate = l_fromdate+6
					replace pp_day7sta WITH "A"
				CASE reservat.rs_arrdate < l_fromdate+6 AND reservat.rs_depdate= l_fromdate+6
					replace pp_day7sta WITH "D"
				CASE reservat.rs_arrdate < l_fromdate+6 AND reservat.rs_depdate > l_fromdate+6
					replace pp_day7sta WITH "S"
			ENDCASE
		ENDIF
	ENDIF 
 ENDSCAN
 WAIT CLEAR
 GOTO l_rsrec IN 'Reservat'
 GOTO l_rmrec IN 'Room'
 SELECT (l_oldarea)
 RETURN
ENDPROC