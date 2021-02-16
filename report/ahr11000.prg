procedure PpVersion
parameter cversion
cversion = "6.10"
return
endproc
*
procedure AHR11000
parameter pctype
private narea, nhrrec, nhrord, nrow, nday, dfor, nrev, nrooms
private art, artsuite, aar
private cthelabel, cthefield, cthecol
private nplrec, nrtrec, nrmrec, nrcrec, nrcord
private c1, c2
private ntmprev, ntmpvat, ctmpcode, dtmp
do CASE
     case pctype == 'M'
          cthelabel = 'MARKET'
          cthefield = 'HistRes.hr_market'
          cthecol = 'hr_market'
     case pctype == 'S'
          cthelabel = 'SOURCE'
          cthefield = 'HistRes.hr_source'
          cthecol = 'hr_source'
     case pctype == 'RC'
          cthefield = 'StrTran(HistRes.hr_ratecod, [*], [])'
          cthecol = 'StrTran(hr_ratecod, [*], [])'
ENDCASE 
select rt_roomtyp FROM RoomType WHERE rt_group=2 INTO ARRAY art
if _TALLY = 0
     dimension art[1]
     art = ''
endif
select rt_roomtyp FROM RoomType WHERE rt_group = 4 INTO ARRAY artsuite
if _TALLY = 0
     dimension artsuite[1]
     artsuite = ''
endif
select ar_artinum FROM Article WHERE INLIST(ar_artityp, 1, 3) AND BETWEEN(ar_main, min2, max2) INTO ARRAY aar
if _TALLY = 0
     dimension aar[1]
     aar[1] = -1
endif
narea = SELECT()
select histres
nhrord = ORDER()
nhrrec = RECNO()
wait WINDOW NOWAIT "Preprocessing..."
create CURSOR PreProc (pp_date D, pp_code C (10), pp_descr C (25), pp_rms N (6), pp_pax N (6), pp_dayrms N (6), pp_daypax N (6), pp_arrrms N (6), pp_arrpax N (6), pp_deprms N (6), pp_deppax N (6), pp_rev N (16, 2), pp_vat N (16, 6))
do CASE
     case INLIST(pctype, 'M', 'S', 'C')
		for nday = 0 TO (max1 - min1)
			wait WINDOW NOWAIT DTOC(min1 + nday)
	    	select picklist
	    	nplrec = RECNO()
		    scan ALL FOR pl_label = cthelabel
	    		insert INTO PreProc (pp_date, pp_code, pp_descr) VALUES ((min1 + nday), picklist.pl_charcod, EVALUATE('PickList.pl_lang' + g_langnum))
    		endscan
		    goto nplrec
		    insert INTO PreProc (pp_date, pp_descr) VALUES (min1 + nday, '<Unknown>')
		ENDFOR
     case pctype == 'RC'
         cidx = filetemp()
         select ratecode
         nrcord = ORDER()
         index ON rc_ratecod TO (cidx) UNIQUE
         for nday = 0 TO (max1 - min1)
              wait WINDOW NOWAIT DTOC(min1 + nday)
              select ratecode
              nrcrec = RECNO()
              scan ALL
                   insert INTO PreProc (pp_date, pp_code, pp_descr) VALUES ((min1 + nday), ratecode.rc_ratecod, EVALUATE('RateCode.rc_lang' + g_langnum))
              endscan
              goto nrcrec
              insert INTO PreProc (pp_date, pp_descr) VALUES (min1 + nday, '<Unknown>')
         endfor
         set ORDER TO nRCOrd
         = filedelete(cidx)
ENDCASE 
select preproc
index ON pp_code TAG pp_code
index ON pp_date TAG pp_date
select histres
scan ALL FOR hr_arrdate <= max1 AND hr_depdate >= min1 AND hr_reserid > 1
     wait WINDOW NOWAIT STR(histres.hr_reserid, 12, 3)
     select preproc
     dfor = histres.hr_arrdate
     do WHILE dfor <= histres.hr_depdate
          locate all for pp_date = dFor and pp_code == PadR(&cTheField, 10)
          if !FOUND()
               locate ALL FOR pp_date = dfor AND ALLTRIM(pp_code) = "<Unknown>"
          endif
          if FOUND()
               if !INLIST(histres.hr_status, 'CXL', 'NS', 'LST', 'OPT', 'TEN') AND ASCAN(art, histres.hr_roomtyp) > 0
                    if ASCAN(artsuite, histres.hr_roomtyp) > 0
                         nrooms = histres.hr_rooms * (OCCURS(',', dlookup('Room','rm_roomnum = ' + sqlcnv(histres.hr_roomnum),'rm_link')) + 1)
                    else
                         nrooms = histres.hr_rooms
                    ENDIF
                    if dfor = histres.hr_arrdate
						 replace pp_arrrms WITH pp_arrrms + nrooms, pp_arrpax WITH pp_arrpax + histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
                    endif
                    if dfor = histres.hr_depdate
                         replace pp_deprms WITH pp_deprms + nrooms, pp_deppax WITH pp_deppax + histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
                    ENDIF
					** hiermit wird ausgeglichen, dass Tagungen pro Tag gezählt werden
                    IF histres.hr_arrdate <> histres.hr_depdate AND dfor = histres.hr_arrdate
                    	nrooms = nrooms +1
                    endif
                    do CASE
                         case histres.hr_arrdate = histres.hr_depdate
                              if TYPE('HistRes.hr_share') <> 'C' OR EMPTY(histres.hr_share)
                                   replace pp_dayrms WITH pp_dayrms + nrooms, pp_daypax WITH pp_daypax + histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
                              else
                                   replace pp_daypax WITH pp_daypax + histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
                              endif
                         case histres.hr_arrdate < histres.hr_depdate AND dfor < histres.hr_depdate
                              if TYPE('HistRes.hr_share') <> 'C' OR EMPTY(histres.hr_share)
                                   replace pp_rms WITH pp_rms + nrooms, pp_pax WITH pp_pax + histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
                              else
                                   replace pp_pax WITH pp_pax + histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
                              ENDIF
							  ** hier werden jetzt noch einmal d Personen für den Anreisetag dazugerechnet, weil Tagungs tageweise gerechnet werden müssen
	                      	  IF histres.hr_arrdate <> histres.hr_depdate AND dfor = histres.hr_arrdate
                         	  	   replace pp_pax WITH pp_pax + histres.hr_adults + histres.hr_childs + histres.hr_childs2 + histres.hr_childs3
                         	  endif
                    endcase
               endif
          endif
          dfor = dfor + 1
     enddo
     select histres
endscan
wait WINDOW NOWAIT 'Revenue...'
c1 = SYS(2015)
select hp_amount, hp_origid, hp_date, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, hp_vat7, hp_vat8, hp_vat9 FROM HistPost WHERE !hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND BETWEEN(hp_date, min1, max1) AND ASCAN(aar, hp_artinum) > 0 INTO CURSOR (c1)
c2 = SYS(2015)
SELECT &cTheCol AS xx_code, hp_date, SUM(hp_amount) AS xx_rev,  SUM(hp_vat1 + hp_vat2 + hp_vat3 + hp_vat4 + hp_vat5 + hp_vat6 + hp_vat7 + hp_vat8 + hp_vat9) AS xx_vat  FROM HistRes, (c1)  WHERE hr_reserid = hp_origid  AND AScan(aRT, hr_roomtyp) > 0  GROUP BY xx_code, hp_date INTO CURSOR (c2)
select (c2)
scan ALL FOR BETWEEN(hp_date, min1, max1)
     dtmp = hp_date
     ntmprev = xx_rev
     ntmpvat = xx_vat
     ctmpcode = PADR(xx_code, 10)
     select preproc
     locate ALL FOR pp_code == ctmpcode AND pp_date = dtmp
     if !FOUND()
          locate ALL FOR pp_code = SPACE(10) AND pp_date = dtmp
     endif
     if FOUND()
          replace pp_rev WITH pp_rev + ntmprev, pp_vat WITH pp_vat + ntmpvat
     endif
     select (c2)
endscan
use IN (c1)
use IN (c2)
wait CLEAR
select histres
goto nhrrec
set ORDER TO nHrOrd
select (narea)
return
endproc
