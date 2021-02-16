 PARAMETER pnReserid, pnWindow, pnArticle, pnQuantity, pnPrice, pcCustom,  ;
           pcSupplement, plNoVat, podata
 PRIVATE naRea
 PRIVATE nvAt1field, nvAt2field, cmAcro, nvAt1amount, nvAt2amount
 LOCAL l_nReserId, l_cCur
 naRea = SELECT()
 LOCAL ARRAY l_aWin(1)
 l_nReserId = pnReserid
 l_cCur = sqlcursor("SELECT rs_roomnum, rs_billins, NVL(ad_lname,'') AS ad_lname FROM reservat " + ;
           "LEFT JOIN address ON rs_addrid = ad_addrid " + ;
           "WHERE rs_reserid = " + sqlcnv(l_nReserId,.T.))
 
 DO biLlinstr IN BillInst WITH pnArticle,  ;
      &l_cCur..rs_billins, pnReserid, pnWindow

 IF (pnReserid<>l_nReserId)
      pcSupplement = ALLTRIM(pcSupplement) + " " + ;
                get_rm_rmname(&l_cCur..rs_roomnum) + " " + &l_cCur..ad_lname
 ENDIF
 
 l_aWin(1) = pnWindow
 DO BillsReserCheck IN ProcBill WITH pnReserid, l_aWin, ;
           "POST_NEW", .T., .F., .T.
 SELECT poSt
 SCATTER BLANK MEMVAR
 M.ps_postid = neXtid('Post')
 M.ps_amount = pnQuantity*pnPrice
 M.ps_artinum = pnArticle
 M.ps_cashier = g_Cashier
 M.ps_date = sySdate()
 M.ps_descrip = pcCustom
 M.ps_reserid = pnReserid
 M.ps_window = pnWindow
 M.ps_origid = l_nReserId
 M.ps_price = pnPrice
 M.ps_supplem = pcSupplement
 M.ps_time = TIME()
 M.ps_units = pnQuantity
 M.ps_userid = g_Userid
 nvAt1field = 0
 nvAt2field = 0
 nvAt1amount = 0
 nvAt2amount = 0
 IF plNoVat
      STORE 0 TO m.ps_vat0, m.ps_vat1, m.ps_vat2, m.ps_vat3, m.ps_vat4, m.ps_vat5, m.ps_vat6, m.ps_vat7, m.ps_vat8, m.ps_vat9
 ELSE
      IF PCOUNT()>=9 AND VARTYPE(podata)="O"
           m.ps_vat0 = podata.ps_vat0
           m.ps_vat1 = podata.ps_vat1
           m.ps_vat2 = podata.ps_vat2
           m.ps_vat3 = podata.ps_vat3
           m.ps_vat4 = podata.ps_vat4
           m.ps_vat5 = podata.ps_vat5
           m.ps_vat6 = podata.ps_vat6
           m.ps_vat7 = podata.ps_vat7
           m.ps_vat8 = podata.ps_vat8
           m.ps_vat9 = podata.ps_vat9
      ELSE
           = geTvat(pnArticle,pnQuantity*pnPrice,@nvAt1field,@nvAt2field, ;
             @nvAt1amount,@nvAt2amount)
           cmAcro = "m.ps_vat"+STR(nvAt1field, 1)
           &cMacro = nVat1Amount
           IF nvAt2field>0
                cmAcro = "m.ps_vat"+STR(nvAt2field, 1)
                &cMacro  = nVat2Amount
           ENDIF
      ENDIF
 ENDIF
 INSERT INTO Post FROM MEMVAR
 IF CURSORGETPROP("Buffering") == 1
     FLUSH
 ELSE
     = TABLEUPDATE(.T.,.T.)&& post table
 ENDIF
 dclose(l_cCur)
 SELECT (naRea)
 RETURN M.ps_postid
ENDFUNC
*
