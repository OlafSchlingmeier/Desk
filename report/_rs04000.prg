procedure ppversion
parameter cversion
cversion = "6.12"
return
endproc
*
procedure _rs04000
oldselect = SELECT()
create CURSOR preproc (pp_arrdate D (8), ppdate D (8), pp_ratecod C (10), pp_rrrcod C (10), pp_reserid N (12, 3), pp_depdate D (8), pp_rooms N (3), pp_adults N (2), pp_childs N (2), pp_childs2 N (2), pp_childs3 N (2), pp_roomnum C (4), pp_share C (1), pp_roomtyp C (4), pp_rate N (8, 3), pp_agent C (25), pp_saddrid N (8), pp_sname C (25), pp_note M (4), pp_status C (3), pp_arrtime C (5), pp_group C (25), pp_paymeth C (4), pp_addrid N (8), pp_compid N (8), pp_invid N (8), pp_apid N (8), pp_ratestat C (4))
select reservat.*, resrate.* FROM reservat, resrate, roomtype WHERE BETWEEN(rs_arrdate, min1, max1) AND IIF(min2, ALLTRIM(rs_in) = "1", EMPTY(rs_in)) AND rs_roomtyp = rt_roomtyp AND !INLIST(rt_group, 2, 3) AND !INLIST(rs_status, 'CXL', 'NS', 'OUT') AND rs_reserid = rr_reserid INTO CURSOR restmp
select restmp
scan
     insert INTO preproc (pp_arrdate, ppdate, pp_ratecod, pp_rrrcod, pp_reserid, pp_depdate, pp_rooms, pp_roomnum, pp_share, pp_roomtyp, pp_agent, pp_saddrid, pp_sname, pp_note, pp_status, pp_arrtime, pp_group, pp_paymeth, pp_addrid, pp_compid, pp_invid, pp_apid, pp_adults, pp_childs, pp_childs2, pp_childs3, pp_rate, pp_ratestat) VALUES (restmp.rs_arrdate, restmp.rr_date, STRTRAN(restmp.rs_ratecod, "*", ""), SUBSTR(restmp.rr_ratecod, 1, 10), restmp.rs_reserid, restmp.rs_depdate, restmp.rs_rooms, restmp.rs_roomnum, restmp.rs_share, restmp.rs_roomtyp, restmp.rs_agent, restmp.rs_saddrid, restmp.rs_sname, restmp.rs_note, restmp.rs_status, restmp.rs_arrtime, restmp.rs_group, restmp.rs_paymeth, restmp.rs_addrid, restmp.rs_compid, restmp.rs_invid, restmp.rs_apid, restmp.rr_adults, restmp.rr_childs, restmp.rr_childs2, restmp.rr_childs3, restmp.rr_raterc, restmp.rr_status)
endscan
select preproc
goto TOP
do WHILE EOF() = .F.
     select resrooms
     set ORDER TO 2
     seek STR(preproc.pp_reserid, 12, 3) + DTOS(preproc.ppdate) 
     if FOUND()
          replace preproc.pp_roomnum WITH ri_roomnum
          replace preproc.pp_roomtyp WITH ri_roomtyp
     endif
     select preproc
     skip
enddo
select = oldselect
endproc
