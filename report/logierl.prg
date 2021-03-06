FUNCTION PpVersion
PARAMETER cversion
cversion = "9.06"
RETURN .T.
ENDFUNC

PROCEDURE Logierl
PRIVATE ALL LIKE l_*
l_rsord = ORDER("Reservat")
l_rford = ORDER("Roomfeat")
l_rsrec = RECNO("Reservat")
l_rmrec = RECNO('Room')
l_oldarea = SELECT()
SELECT 0
IF !USED('outofser')
     openfiledirect(.F., "outofser")
endif
WAIT WINDOW NOWAIT "Preprocessing..."
DO roomstat IN Interfac
CREATE CURSOR preproc (pp_rpseq N (4), pp_roomnum C (4), pp_roomtyp C (4), pp_floor N (2), pp_status C (3), pp_feat C (50), pp_date D (8), pp_move C  ;
       (1), pp_reserid N (12, 3), pp_oooreas C (25), pp_fixnote C(254), pp_arrdate D(8), pp_depdate D(8))
= dopen('OutOfOrd')
SELECT room
GOTO TOP IN "Room"
SCAN FOR dblookup("RoomType", "Tag1",room.rm_roomtyp, "Rt_Group") == 1 WHILE  .NOT. EOF("room")
     l_date = min1
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
          	l_status = 'OLD'
         ENDIF 
     ENDIF
     SELECT preproc
     INSERT INTO PreProc (pp_rpseq, pp_roomnum, pp_roomtyp, pp_floor, pp_status, pp_date, pp_oooreas) VALUES  ;
            (room.rm_rpseq, room.rm_roomnum, room.rm_roomtyp, room.rm_floor, l_status, l_date, l_oooreas)
     SELECT room
ENDSCAN
**** Features werden gesucht
SELECT preproc
GO top
DO WHILE EOF()=.f.
	SELECT roomfeat
	SET ORDER TO TAG2
	SEEK preproc.pp_roomnum
		IF FOUND()
			DO WHILE rf_roomnum = preproc.pp_roomnum AND EOF()=.f.
				IF EMPTY(ALLTRIM(preproc.pp_feat))
					replace preproc.pp_feat WITH ALLTRIM(rf_feature)
				ELSE 
					replace preproc.pp_feat WITH ALLTRIM(preproc.pp_feat) +","+ALLTRIM(rf_feature)
				ENDIF 
				SKIP
			ENDDO
		ENDIF
	SELECT preproc
	SKIP
ENDDO 
***
SELECT roomfeat
SET ORDER TO TAG2
SELECT reservat
SET ORDER IN 'Reservat' TO 13
SELECT preproc
GOTO TOP IN "PreProc"
SCAN WHILE  .NOT. EOF("PreProc")
     l_status = ""
     l_reserid = 0
     l_date = preproc.pp_date
     SELECT reservat
     IF  .NOT. SEEK(preproc.pp_roomnum, "Reservat")
          l_status = "V"
     ELSE
          SCAN WHILE reservat.rs_roomnum == preproc.pp_roomnum .AND. reservat.rs_arrdate <= l_date
               DO CASE
                    CASE INLIST(reservat.rs_status, "NS", "CXL")
                    CASE reservat.rs_depdate == l_date
                    CASE reservat.rs_arrdate == l_date .AND. EMPTY(l_status) .AND. min4 = .T.
                         l_status = 'A'
                         l_reserid = reservat.rs_reserid
                    CASE reservat.rs_arrdate == l_date .AND. EMPTY(l_status) .AND. min4 = .F. .AND. reservat.rs_status =  "IN"
                         l_status = 'A'
                         l_reserid = reservat.rs_reserid
                    CASE reservat.rs_arrdate == l_date .AND. EMPTY(l_status) .AND. min4 = .F. .AND. reservat.rs_status <> "IN"
                         l_status = 'V'
                         l_reserid = reservat.rs_reserid
                    CASE reservat.rs_arrdate < l_date .AND. reservat.rs_depdate > l_date
                         l_status =  'S'
                         l_reserid = reservat.rs_reserid
               ENDCASE
               l_arrdate = reservat.rs_arrdate
               l_depdate = reservat.rs_depdate
          ENDSCAN
     ENDIF
     SELECT preproc
     REPLACE preproc.pp_move WITH IIF(EMPTY(l_status), "V", l_status)
     REPLACE preproc.pp_reserid WITH l_reserid
     REPLACE preproc.pp_arrdate WITH l_arrdate
     replace preproc.pp_depdate WITH l_depdate
ENDSCAN
*!* Fixleistungen und GAragen werden in pp_fixnote eingefügt
= dopen('Resfix')
SELECT preproc
GO top
SCAN
	IF !EMPTY(pp_reserid)
		SELECT resfix
		SET ORDER TO TAG1
		SEEK preproc.pp_reserid
		IF FOUND() 
			DO WHILE EOF()=.f. AND rf_reserid = preproc.pp_reserid
				IF rf_alldays=.t. OR (rf_alldays=.f. AND preproc.pp_arrdate+rf_day=min1)
					IF EMPTY(preproc.pp_fixnote)
						replace preproc.pp_fixnote WITH ALLTRIM(STR(rf_units,2,0)) + "x" + ALLTRIM(LOOKUP(article.ar_lang3, rf_artinum, article.ar_artinum, 'TAG1'))
					ELSE
						replace preproc.pp_fixnote WITH ALLTRIM(preproc.pp_fixnote) + " " +ALLTRIM(STR(rf_units,2,0)) + "x" + ALLTRIM(LOOKUP(article.ar_lang3, rf_artinum, article.ar_artinum, 'TAG1'))
					ENDIF
				ENDIF 
				SKIP 
			ENDDO 
		ENDIF
		SELECT reservat
		SET ORDER TO TAG1
		SEEK preproc.pp_reserid
		IF FOUND()
			DO WHILE EOF()=.f. AND INT(preproc.pp_reserid) = INT(rs_reserid)
				IF INLIST(get_rt_roomtyp(rs_roomtyp),"TG","PD") AND BETWEEN(preproc.pp_date, rs_arrdate, rs_depdate) AND rs_depdate> preproc.pp_date
					IF EMPTY(preproc.pp_fixnote)
						replace preproc.pp_fixnote WITH ALLTRIM(get_rt_roomtyp(rs_roomtyp))
					ELSE 
						replace preproc.pp_fixnote WITH ALLTRIM(preproc.pp_fixnote) + " -" +ALLTRIM(get_rt_roomtyp(rs_roomtyp))
					ENDIF
				ENDIF
				SKIP
			ENDDO 
		ENDIF 
	ENDIF
ENDSCAN							

WAIT CLEAR
SET ORDER IN 'Reservat' TO l_RsOrd
SET ORDER in 'Roomfeat' to l_rford
GOTO l_rsrec IN 'Reservat'
GOTO l_rmrec IN 'Room'
= dclose('Resfix')
= dclose('OutOfOrd')
SELECT (l_oldarea)
RETURN
ENDPROC

