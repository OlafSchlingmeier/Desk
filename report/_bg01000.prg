PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "7.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _bg01000
LOCAL loSession
LOCAL ARRAY laPreProc(1), laPPStruct(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_bg01000")
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
DEFINE CLASS _bg01000 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("histres,histpost,roomtype,article,manager,picklist,param,budget", tcHotCode, tcPath)
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc, taPPStruct

     IF this.lUseRemote
          TEXT TO this.cRemoteScript TEXTMERGE NOSHOW PRETEXT 3
          <<this.cRemoteScript>>
          DO PpDo IN _bg01000
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
PRIVATE narea, nhrrec, nday, dfor, nrooms, coldcollate
PRIVATE art, artsuite, aar
PRIVATE nplrec, nrtrec, nrmrec, nrcrec, nrcord
PRIVATE nmgrmnt, nmgrmntptd, nmgrmntytd
PRIVATE dstart, dend, nfyear, nfper, ncurfyear, ncurfper, lexcltax

LOCAL lcExp, ldStartYearDate, lnPeriod, ldStartPeriodDate, lnDays, lnbyrev, lnRevnueForDays
LOCAL lnDaysPassedFromPeriodStart, lcLabel, lnRoomntsForDays, lnbyrmn, lcArchScripts
LOCAL l_dOneStartYearDate, l_dOneStartPeriodDate

STORE {} TO ldStartYearDate, ldStartPeriodDate
STORE 0 TO lnPeriod, lnDays, lnbyrev, lnDaysPassedFromPeriodStart, lnRoomntsForDays, lnbyrmn
lcLabel = ""
narea = SELECT()
dend = min1

DO GetPeriodInfo IN procperiod WITH dend, ldStartYearDate, lnPeriod, ldStartPeriodDate, lnDays, lnDaysPassedFromPeriodStart
ncurfyear = YEAR(dend)
ncurfper = lnPeriod

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE hr_arrdate <= <<SqlCnvB(dend)>> AND hr_depdate >= <<SqlCnvB(ldStartYearDate)>>;

SELECT histpost.* FROM histpost
     WHERE BETWEEN(hp_date, <<SqlCnvB(ldStartYearDate)>>, <<SqlCnvB(dend)>>)
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, ldStartYearDate)
*
****************************************************************************************************

SELECT rt_roomtyp FROM RoomType WHERE INLIST(rt_group, 1, 4) INTO ARRAY art
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
     aar = ''
ENDIF
lexcltax = min3
narea = SELECT()
USE (gcdatadir + 'Manager.DBF') IN 0
SELECT histres
nhrrec = RECNO()
WAIT WINDOW NOWAIT "Preprocessing..."
CREATE CURSOR Tmp0 (pp_date D, pp_fyear N (4), pp_fper N (2), pp_market C (3), pp_rmnt N (4),  ;
       pp_rev B (2))
CREATE CURSOR PreProc (pp_market C (3), pp_descr C (25), pp_rmnt N (4), pp_rmntptd N (5),  ;
       pp_rmntytd N (6), pp_rev B (2), pp_revptd B (2), pp_revytd B (2), ;
       pp_brmnptd N (5),pp_brevptd B (2), pp_brmnytd N (6), pp_brevytd B (2))
FOR nday = 0 TO (dend - ldStartYearDate)
     WAIT WINDOW NOWAIT DTOC(ldStartYearDate + nday)
     nfyear = 0
     nfper = 0
     *budgetperiod(dstart + nday,@nfyear,@nfper)
     l_dOneStartYearDate = {}
     l_dOneStartPeriodDate = {}
     DO GetPeriodInfo IN procperiod WITH ldStartYearDate+ nday, l_dOneStartYearDate, nfper, l_dOneStartPeriodDate
     nfyear = YEAR(l_dOneStartPeriodDate)
     SELECT picklist
     nplrec = RECNO()
     SCAN ALL FOR pl_label = 'MARKET'
          INSERT INTO Tmp0 (pp_date, pp_fyear, pp_fper, pp_market) VALUES ((ldStartYearDate + nday), nfyear,  ;
                 nfper, picklist.pl_charcod)
     ENDSCAN
     GOTO nplrec
     INSERT INTO Tmp0 (pp_date, pp_fyear, pp_fper) VALUES (ldStartYearDate + nday, nfyear, nfper)
ENDFOR
SELECT picklist
nplrec = RECNO()
SCAN ALL FOR pl_label = 'MARKET'
     INSERT INTO PreProc (pp_market, pp_descr) VALUES (picklist.pl_charcod,  ;
            EVALUATE('PickList.pl_lang' + g_langnum))
ENDSCAN
GOTO nplrec
INSERT INTO PreProc (pp_descr) VALUES ('<Unknown>')
SELECT manager
LOCATE ALL FOR mg_date = dend
nmgrmnt = mg_roomocc + mg_rmduse
nmgrmntptd = mg_rmoccm + mg_rmdusem
nmgrmntytd = mg_rmoccy + mg_rmdusey
SELECT tmp0
INDEX ON pp_market TAG pp_market
INDEX ON pp_date TAG pp_date
SELECT histres
SCAN ALL FOR ((hr_arrdate <= dend AND hr_depdate >= ldStartYearDate) OR (BETWEEN(hr_arrdate, ldStartYearDate, dend)  ;
     AND hr_depdate = hr_arrdate))
     WAIT WINDOW NOWAIT STR(histres.hr_reserid, 12, 3)
     SELECT tmp0
     dfor = histres.hr_arrdate
     DO WHILE dfor <= histres.hr_depdate
          LOCATE ALL FOR pp_date = dfor AND pp_market == histres.hr_market
          IF NOT FOUND()
               LOCATE ALL FOR pp_date = dfor AND pp_market = SPACE(3)
          ENDIF
          IF FOUND()
               IF NOT INLIST(histres.hr_status, 'CXL', 'NS', 'LST', 'OPT', 'TEN') AND ASCAN(art,  ;
                  histres.hr_roomtyp) > 0 AND EMPTY(histres.hr_share)
                    IF ASCAN(artsuite, histres.hr_roomtyp) > 0
                         nrooms = histres.hr_rooms * (OCCURS(',', dlookup('Room','rm_roomnum = ' +  ;
                                  sqlcnv(histres.hr_roomnum),'rm_link')) + 1)
                    ELSE
                         nrooms = histres.hr_rooms
                    ENDIF
                    IF (histres.hr_arrdate = histres.hr_depdate) OR (histres.hr_arrdate <  ;
                       histres.hr_depdate AND dfor < histres.hr_depdate)
                         REPLACE pp_rmnt WITH pp_rmnt + nrooms
                    ENDIF
               ENDIF
          ENDIF
          dfor = dfor + 1
     ENDDO
     SELECT histres
ENDSCAN
WAIT WINDOW NOWAIT 'Revenue...'
coldcollate = SET('collate')
SET COLLATE TO 'machine'
SELECT hp_amount, hp_origid, hp_date, hp_vat1, hp_vat2, hp_vat3, hp_vat4, hp_vat5, hp_vat6, ;
       hp_vat7, hp_vat8, hp_vat9 FROM HistPost WHERE NOT hp_cancel AND (EMPTY(hp_ratecod) OR  ;
       hp_split) AND BETWEEN(hp_date, ldStartYearDate, dend) AND ASCAN(aar, hp_artinum) > 0 INTO CURSOR  ;
       Tmp1
IF lexcltax AND NOT param.pa_exclvat
     SELECT hr_market, hp_date, SUM(hp_amount - hp_vat1 - hp_vat2 - hp_vat3 - hp_vat4 - hp_vat5 -  ;
            hp_vat6 - hp_vat7 - hp_vat8 - hp_vat9) AS xx_rev FROM HistRes, Tmp1 WHERE hr_reserid =  ;
            hp_origid GROUP BY hr_market, hp_date INTO CURSOR Tmp2
ELSE
     SELECT hr_market, hp_date, SUM(hp_amount) AS xx_rev FROM HistRes, Tmp1 WHERE hr_reserid =  ;
            hp_origid GROUP BY hr_market, hp_date INTO CURSOR Tmp2
ENDIF
SET COLLATE TO coldcollate
SCAN ALL
     SELECT tmp0
     LOCATE ALL FOR pp_market = tmp2.hr_market AND pp_date = tmp2.hp_date
     IF FOUND()
          REPLACE pp_rev WITH pp_rev + tmp2.xx_rev
     ENDIF
     SELECT tmp2
ENDSCAN
USE IN tmp1
USE IN tmp2
SELECT pp_market, pp_rmnt AS rmnt, pp_rev AS rev FROM Tmp0 WHERE pp_date = dend GROUP BY pp_market  ;
       INTO CURSOR Tmp1
SELECT tmp1
SCAN ALL
     SELECT preproc
     LOCATE ALL FOR pp_market = tmp1.pp_market
     IF FOUND()
          REPLACE pp_rev WITH tmp1.rev, pp_rmnt WITH tmp1.rmnt
     ENDIF
     SELECT tmp1
ENDSCAN
USE IN tmp1
SELECT pp_market, SUM(pp_rmnt) AS rmnt, SUM(pp_rev) AS rev FROM Tmp0 WHERE pp_fyear = ncurfyear AND  ;
       pp_fper = ncurfper GROUP BY pp_market, pp_fyear, pp_fper INTO CURSOR Tmp1
SELECT tmp1
SCAN ALL
     SELECT preproc
     LOCATE ALL FOR pp_market = tmp1.pp_market
     IF FOUND()
          REPLACE pp_revptd WITH tmp1.rev, pp_rmntptd WITH tmp1.rmnt
     ENDIF
     SELECT tmp1
ENDSCAN
USE IN tmp1
SELECT pp_market, SUM(pp_rmnt) AS rmnt, SUM(pp_rev) AS rev FROM Tmp0 WHERE pp_fyear = ncurfyear  ;
       GROUP BY pp_market, pp_fyear INTO CURSOR Tmp1
SELECT tmp1
SCAN ALL
     SELECT preproc
     LOCATE ALL FOR pp_market = tmp1.pp_market
     IF FOUND()
          REPLACE pp_revytd WITH tmp1.rev, pp_rmntytd WITH tmp1.rmnt
     ENDIF
     SELECT tmp1
ENDSCAN
USE IN tmp1
USE IN tmp0
= divrest(nmgrmnt,'PreProc','pp_rmnt')
= divrest(nmgrmntptd,'PreProc','pp_rmntptd')
= divrest(nmgrmntytd,'PreProc','pp_rmntytd')
WAIT CLEAR
SELECT histres
GOTO nhrrec
USE IN manager

SELECT preproc
GOTO TOP
SCAN
  lcLabel = "RMNT_PER_MARKET"
  lcExp = STR(YEAR(ldStartYearDate),4)+STR(lnPeriod,2)+STR(0,4)+;
          PADR(UPPER(lcLabel),20)+STR(0,1)+PADR(UPPER(pp_market),3)+STR(0,2)+;
          STR(0,2)+STR(0,3)
  IF SEEK(lcExp,"budget","tag4")
        lnRoomntsForDays = FLOOR((budget.bg_roomnts / lnDays) * lnDaysPassedFromPeriodStart)
        REPLACE preproc.pp_brmnptd WITH lnRoomntsForDays IN preproc
  ENDIF
  lcLabel = "REV_PER_MARKET"
  lcExp = STR(YEAR(ldStartYearDate),4)+STR(lnPeriod,2)+STR(0,4)+;
          PADR(UPPER(lcLabel),20)+STR(0,1)+PADR(UPPER(pp_market),3)+STR(0,2)+;
          STR(0,2)+STR(0,3)
  IF SEEK(lcExp,"budget","tag4")
        lnRevnueForDays = (budget.bg_revenue / lnDays) * lnDaysPassedFromPeriodStart 
        REPLACE preproc.pp_brevptd WITH lnRevnueForDays IN preproc
  ENDIF

  SELECT SUM(bg_roomnts) AS byrev, SUM(bg_revenue) AS byrmn ;
         FROM budget ;
         WHERE bg_market = preproc.pp_market ;
               AND BETWEEN(bg_period, 1, lnPeriod - 1) AND bg_year = YEAR(ldStartYearDate)  ;
         GROUP BY bg_market INTO CURSOR tmp11
  SELECT preproc
  lnbyrmn = preproc.pp_brmnptd + tmp11.byrev
  lnbyrev = preproc.pp_brevptd + tmp11.byrmn
  REPLACE preproc.pp_brmnytd WITH lnbyrmn, ;
          preproc.pp_brevytd WITH lnbyrev IN preproc
ENDSCAN

SELECT (narea)

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************
RETURN
ENDPROC
*
PROCEDURE DivRest
PARAMETER pntruetotal, pccursor, pccntfld
PRIVATE narea, nrec, nord, ncnttotal, ndiff, ncorr, nnextrec
narea = SELECT()
SELECT (pccursor)
nrec = RECNO()
nord = ORDER()
index on &pcCntFld tag DivRest descending
sum all &pcCntFld to nCntTotal
ndiff = pntruetotal - ncnttotal
IF ncnttotal <> 0
     SCAN ALL WHILE ndiff <> 0
          IF ndiff > 0
               nCorr = Ceil(nDiff * (&pcCntFld / nCntTotal))
          ELSE
               nCorr = Floor(nDiff * (&pcCntFld / nCntTotal))
          ENDIF
          SKIP 1
          nnextrec = RECNO()
          SKIP -1
          replace &pcCntFld with Eval(pcCntFld) + nCorr
          ndiff = ndiff - ncorr
          GOTO nnextrec
     ENDSCAN
ENDIF
IF ndiff <> 0
     GOTO TOP
     replace &pcCntFld with Eval(pcCntFld) + nDiff
ENDIF
DELETE TAG divrest
GOTO nrec
SET ORDER TO (nord)
SELECT (narea)
RETURN
ENDPROC
*