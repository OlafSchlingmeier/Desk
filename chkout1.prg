*
PROCEDURE BatchChkOut
 PRIVATE naRea, nrSres, nrSord, cfOr
 PRIVATE ntMpreserid, ctMproom, ddOne
 LOCAL l_lUsedResFix
 cgRoup = ""
 IF  .NOT. baTchdlg(@cgRoup)
      RETURN
 ENDIF
 IF  .NOT. EMPTY(cgRoup)
      cfOr = "rs_group = "+sqLcnv(cgRoup)
 ELSE
      cfOr = ".t."
 ENDIF
 naRea = SELECT()
 l_lUsedResFix = USED("resfix")
 IF NOT l_lUsedResFix
      openfiledirect(.F.,"resfix")
      SET ORDER TO TAG1 IN resfix
 ENDIF
 SELECT reServat
 nrSrec = RECNO()
 nrSord = ORDER()
 ndOne = 0
 SET ORDER TO 6
 IF SEEK("1", "Reservat")
      SCAN REST FOR NOT EMPTY(rs_in) AND EMPTY(rs_out) AND rs_depdate = SysDate() AND ;
                INLIST(DLookup('RoomType', 'rt_roomtyp = ' + SqlCnv(rs_roomtyp), 'rt_group'), 1, 4) ;
                AND Balance(rs_reserid, 1) + Balance(rs_reserid, 2) + Balance(rs_reserid, 3) + ;
                Balance(rs_reserid, 4) + Balance(rs_reserid, 5) + Balance(rs_reserid, 6) = 0.00 ;
                AND &cFor
           WAIT WINDOW NOWAIT TRIM(reServat.rs_roomnum)+" "+ ;
                TRIM(reServat.rs_lname)
           DO raTecodepost IN RatePost WITH (sySdate()), "CHECKOUT"
           ntMpreserid = reServat.rs_reserid
           ctMproom = poStroom()
           DO ifCpost IN Interfac WITH ntMpreserid, ctMproom
           DO chEckout IN ChkOut2 WITH ntMpreserid, 0, .F.
           WAIT CLEAR
           ndOne = ndOne+1
      ENDSCAN
 ENDIF
 SET ORDER TO nRsOrd
 GOTO nrSrec
 IF NOT l_lUsedResFix AND USED("resfix")
      dclose("resfix")
 ENDIF
 SELECT (naRea)
 = alErt(stRfmt(GetLangText("CHKOUT1","T_BATCHDONE"),ndOne),GetLangText("CHKOUT1", ;
   "TW_BATCHCHECKOUT"))
 RETURN
ENDPROC
*
FUNCTION BatchDlg
 PARAMETER pcGroup
 PRIVATE adLg, lrEt
 DIMENSION adLg[1, 8]
 adLg[1, 1] = "group"
 adLg[1, 2] = GetLangText("CHKOUT1","TH_GROUP")
 adLg[1, 3] = "[]"
 adLg[1, 4] = REPLICATE("!", 20)
 adLg[1, 5] = 20
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = ""
 IF diAlog(GetLangText("CHKOUT1","TW_BATCHCHECKOUT"),GetLangText("CHKOUT1", ;
    "T_BATCHINFO"),@adLg)
      pcGroup = UPPER(ALLTRIM(adLg(1,8)))
      lrEt = .T.
 ELSE
      lrEt = .F.
 ENDIF
 RETURN lrEt
ENDFUNC
*