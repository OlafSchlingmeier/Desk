PROCEDURE PpVersion
LPARAMETERS tcVersion
*
IF .F.
     _ReFox_ORCBPGJCKJGQ = (9876543210)
\\                                 
     _ReFox_AFPFETDGIPPQ = (9876543210)
ENDIF
*
tcVersion = "3.00"
RETURN
*
RETURN
= _ReFox_00_
*
*
ENDPROC
*
PROCEDURE _zc01006
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_zc01006")
loSession.DoPreproc(@laPreProc, @laPPStruct)
RELEASE loSession

IF ALEN(laPPStruct) > 1
     CREATE CURSOR PreProc FROM ARRAY laPPStruct
     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
     ENDIF
ENDIF

WAIT CLEAR
ENDPROC
**********
DEFINE CLASS _zc01006 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("roomtype,room,article,manager,zipcode,histres,address", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _zc01006
          SELECT * FROM PreProc INTO TABLE (l_cFullPath)
          USE
          DClose("PreProc")
          ENDTEXT
          SqlRemote("SQLPROC", this.cRemoteScript, "PreProc", this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          this.cRemoteScript = ""
     ELSE
          PpDo()
     ENDIF

     IF USED("PreProc")
          AFIELDS(taPPStruct, "PreProc")
          IF RECCOUNT("PreProc") > 0
               SELECT * FROM PreProc INTO ARRAY taPreProc
          ENDIF
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpDo
PRIVATE narea, nhrrec, nhrord, nrow, nday, dfor, nrev, nrooms
PRIVATE art, artsuite, aar
PRIVATE cthelabel, cthefield, cthecol
PRIVATE nplrec, nrtrec, nrmrec, nrcrec, nrcord
PRIVATE nmgrms, nmgpax, nmgdayrms, nmgdaypax, nmgarrpax, nmgarrrms, nmgdeppax, nmgdeprms
PRIVATE c1, c2
PRIVATE ntmprev, ntmpvat, ctmpcode, dtmp
LOCAL lcArchScripts

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE hr_reserid >= 1 AND hr_arrdate <= <<SqlCnvB(max1)>> AND hr_depdate >= <<SqlCnvB(min1)>>
ENDTEXT
ProcArchive("RestoreArchive", "histres", lcArchScripts, min1)
*
****************************************************************************************************

SELECT rt_roomtyp FROM RoomType WHERE INLIST(rt_group, 1, 4) INTO ARRAY art
zcstate = SPACE(30)
IF _TALLY = 0
     DIMENSION art[1]
     art = ''
ENDIF
SELECT rt_roomtyp FROM RoomType WHERE rt_group = 4 INTO ARRAY artsuite
IF _TALLY = 0
     DIMENSION artsuite[1]
     artsuite = ''
ENDIF
SELECT ar_artinum FROM Article WHERE ar_artityp = 1 AND BETWEEN(ar_main, min2, max2) INTO ARRAY aar
IF _TALLY = 0
     DIMENSION aar[1]
     aar[1] = -1
ENDIF
narea = SELECT()
USE (gcdatadir + 'Manager.DBF') IN 0
SELECT 0
IF !USED('zipcode')
     openfiledirect(.F., "zipcode")
ENDIF 
SELECT 0
SELECT histres
nhrord = ORDER()
nhrrec = RECNO()
WAIT WINDOW NOWAIT "Preprocessing..."
CREATE CURSOR PreProc (pp_date D, pp_code C (10), pp_descr C (30), pp_rms N (6), pp_pax N (6),  ;
       pp_dayrms N (6), pp_daypax N (6), pp_arrrms N (6), pp_arrpax N (6), pp_deprms N (6),  ;
       pp_deppax N (6), pp_rev N (16, 2), pp_vat N (16, 6), pp_numcod N (3))
FOR nday = 0 TO (max1 - min1)
     WAIT WINDOW NOWAIT DTOC(min1 + nday)
     SELECT zipcode
     SELECT * from zipcode WHERE zc_country="D" GROUP BY zc_state ORDER BY zc_state INTO CURSOR zctmp
     SELECT zctmp
     SCAN 
         INSERT INTO PreProc (pp_date, pp_descr) VALUES (min1 + nday, zctmp.zc_state)
     ENDSCAN
ENDFOR 
SELECT manager
SUM mg_roomocc, mg_bedocc, mg_rmduse, mg_prduse, mg_persarr, mg_roomarr, mg_persdep, mg_roomdep TO  ;
    nmgrms, nmgpax, nmgdayrms, nmgdaypax, nmgarrpax, nmgarrrms, nmgdeppax, nmgdeprms ALL FOR  ;
    BETWEEN(mg_date, min1, max1)
SELECT preproc
INDEX ON pp_descr TAG pp_descr
INDEX ON pp_date TAG pp_date
SELECT histres
SCAN ALL FOR ((hr_arrdate <= max1 AND hr_depdate >= min1) OR (BETWEEN(hr_arrdate, min1, max1) AND  ;
     hr_depdate = hr_arrdate))
     WAIT WINDOW NOWAIT STR(histres.hr_reserid, 12, 3)
     SELECT preproc
     dfor = histres.hr_arrdate
     IF EMPTY(histres.hr_addrid)
          addrid = histres.hr_compid
     ELSE
          addrid = histres.hr_addrid
     ENDIF 
     SELECT address
     SET order to 1
     SEEK addrid
     IF FOUND()
          SELECT zipcode
          SET ORDER TO 1
          SEEK address.ad_country+address.ad_zip
          IF FOUND()
               zcstate = zc_state
          ELSE
               zcstate = SPACE(30)
          ENDIF
     ENDIF
     SELECT preproc
     DO WHILE dfor <= histres.hr_depdate
          locate all for pp_date = dFor and pp_descr == PadR(zcstate, 30)
          IF NOT FOUND()
               LOCATE ALL FOR pp_date = dfor AND pp_descr = SPACE(30)
          ENDIF
          IF FOUND()
               IF NOT INLIST(histres.hr_status, 'CXL', 'NS', 'LST', 'OPT', 'TEN') AND ASCAN(art,  ;
                  histres.hr_roomtyp) > 0
                    IF ASCAN(artsuite, histres.hr_roomtyp) > 0
                         nrooms = histres.hr_rooms * (OCCURS(',', dlookup('Room','rm_roomnum = ' +  ;
                                  sqlcnv(histres.hr_roomnum),'rm_link')) + 1)
                    ELSE
                         nrooms = histres.hr_rooms
                    ENDIF
                    IF dfor = histres.hr_arrdate
                         REPLACE pp_arrrms WITH pp_arrrms + nrooms, pp_arrpax WITH pp_arrpax +  ;
                                 histres.hr_adults + histres.hr_childs + histres.hr_childs2 +  ;
                                 histres.hr_childs3
                    ENDIF
                    IF dfor = histres.hr_depdate
                         REPLACE pp_deprms WITH pp_deprms + nrooms, pp_deppax WITH pp_deppax +  ;
                                 histres.hr_adults + histres.hr_childs + histres.hr_childs2 +  ;
                                 histres.hr_childs3
                    ENDIF
                    DO CASE
                         CASE histres.hr_arrdate = histres.hr_depdate
                              IF TYPE('HistRes.hr_share') <> 'C' OR EMPTY(histres.hr_share)
                                   REPLACE pp_dayrms WITH pp_dayrms + nrooms, pp_daypax WITH  ;
                                           pp_daypax + histres.hr_adults + histres.hr_childs +  ;
                                           histres.hr_childs2 + histres.hr_childs3
                              ELSE
                                   REPLACE pp_daypax WITH pp_daypax + histres.hr_adults +  ;
                                           histres.hr_childs + histres.hr_childs2 +  ;
                                           histres.hr_childs3
                              ENDIF
                         CASE histres.hr_arrdate < histres.hr_depdate AND dfor < histres.hr_depdate
                              IF TYPE('HistRes.hr_share') <> 'C' OR EMPTY(histres.hr_share)
                                   REPLACE pp_rms WITH pp_rms + nrooms, pp_pax WITH pp_pax +  ;
                                           histres.hr_adults + histres.hr_childs +  ;
                                           histres.hr_childs2 + histres.hr_childs3
                              ELSE
                                   REPLACE pp_pax WITH pp_pax + histres.hr_adults +  ;
                                           histres.hr_childs + histres.hr_childs2 +  ;
                                           histres.hr_childs3
                              ENDIF
                    ENDCASE
               ENDIF
          ENDIF
          dfor = dfor + 1
     ENDDO
     SELECT histres
ENDSCAN

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************
ENDPROC
*