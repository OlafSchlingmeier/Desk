 PRIVATE lcOntinue
 PRIVATE cmOvefilename
 PRIVATE naRtiorder
 PRIVATE naRtirecord
 PRIVATE npAymorder
 PRIVATE npAymrecord
 PRIVATE naRtitotal
 PRIVATE npAymtotal
 SELECT arTicle
 naRtiorder = ORDER()
 naRtirecord = RECNO()
 SET ORDER TO 1
 SELECT paYmetho
 npAymorder = ORDER()
 npAymrecord = RECNO()
 SET ORDER TO 1
 lcOntinue = .T.
 IF (lcOntinue)
      = opEnfile(.F.,"POSArti")
      = opEnfile(.F.,"POSPaym")
      = opEnfile(.T.,"TpPayDay")
      SELECT tpPayday
      ZAP
      = clOsefile("TpPayDay")
      = opEnfile(.T.,"TpJrnDay")
      SELECT tpJrnday
      ZAP
      = clOsefile("TpJrnDay")
      IF (opEnfile(.T.,"TpTmpPay"))
           SELECT tpTmppay
           ZAP
           FOR ndEpacount = 1 TO MAX(paRam.pa_depas, 1)
                cdEpa = SUBSTR("S23456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",  ;
                        ndEpacount, 1)
                cpAth = ALLTRIM(paRam.pa_posdir)+"\Journal"+cdEpa+"\"
                nfIles = ADIR(acFiles, cpAth+"*.Tdr")
                IF (nfIles>0)
                     IF (opEnfile(.F.,"TpAudit"))
                          FOR ni = 1 TO nfIles
                               lrEadthisone = .F.
                               IF ( .NOT. SEEK(cdEpa+UPPER(acFiles(ni,1))+ ;
                                  DTOS(acFiles(ni,3))+acFiles(ni,4),  ;
                                  "TpAudit"))
                                    SELECT tpAudit
                                    INSERT INTO TpAudit (au_depa, au_date,  ;
                                     au_time, au_file, au_size,  ;
                                     au_filedat, au_filetim, au_fileatt,  ;
                                     au_positio) VALUES (cdEpa, sySdate(),  ;
                                     TIME(), acFiles(ni,1), acFiles(ni,2),  ;
                                     acFiles(ni,3), acFiles(ni,4),  ;
                                     acFiles(ni,5), -1)
                                    lrEadthisone = .T.
                               ELSE
                                    IF (tpAudit.au_positio<>-1)
                                         SELECT tpAudit
                                         REPLACE tpAudit.au_positio WITH -1
                                         lrEadthisone = .T.
                                    ENDIF
                               ENDIF
                               IF (lrEadthisone)
                                    = reAdfile(cpAth+acFiles(ni,1), ;
                                      "TpTmpPay",.T.)
                                    IF ( .NOT. EMPTY(paRam.pa_posmove))
                                         cmOvefilename = cpAth+acFiles(ni,1)
                                         cdEstfilename =  ;
                                          ALLTRIM(paRam.pa_posmove)+"\"+ ;
                                          acFiles(ni,1)
                                         ncOunt = 0
                                         DO WHILE (FILE(cdEstfilename))
                                              cdEstfilename =  ;
                                               LEFT(cdEstfilename, AT(".",  ;
                                               cdEstfilename)+2)+ ;
                                               PADL(ALLTRIM(STR(ncOunt)),  ;
                                               2, "0")
                                              ncOunt = ncOunt+1
                                         ENDDO
                                         WAIT WINDOW NOWAIT  ;
                                          GetLangText("TOUCHPOS", ;
                                          "TXT_MOVINGJOURNAL")+" "+ ;
                                          cmOvefilename+" To "+cdEstfilename
                                         COPY FILE (cmOvefilename) TO  ;
                                          (cdEstfilename)
                                         ERASE (cmOvefilename)
                                         WAIT CLEAR
                                    ENDIF
                               ENDIF
                          ENDFOR
                     ENDIF
                     = clOsefile("TpAudit")
                ENDIF
                = clOsefile("TpAudit")
                IF (opEnfile(.F.,"TpPay"))
                     WAIT WINDOW NOWAIT GetLangText("TOUCHPOS","TXT_APPENDTOHIST")
                     SELECT tpPay
                     APPEND FROM (_screen.oGlobal.choteldir+"Tpos\TpTmpPay")
                     WAIT CLEAR
                ENDIF
           ENDFOR
      ENDIF
      IF (opEnfile(.T.,"TpTmpJou"))
           SELECT tpTmpjou
           ZAP
           INDEX ON DTOS(orDerdate)+STR(dePt, 5)+STR(leDg, 4) TAG taG1
           FOR ndEpacount = 1 TO MAX(paRam.pa_depas, 1)
                cdEpa = SUBSTR("S23456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",  ;
                        ndEpacount, 1)
                cpAth = ALLTRIM(paRam.pa_posdir)+"\Journal"+cdEpa+"\"
                nfIles = ADIR(acFiles, cpAth+"*.Jnl")
                IF (nfIles>0)
                     IF (opEnfile(.F.,"TpAudit"))
                          FOR ni = 1 TO nfIles
                               lrEadthisone = .F.
                               IF ( .NOT. SEEK(cdEpa+UPPER(acFiles(ni,1))+ ;
                                  DTOS(acFiles(ni,3))+acFiles(ni,4),  ;
                                  "TpAudit"))
                                    SELECT tpAudit
                                    INSERT INTO TpAudit (au_depa, au_date,  ;
                                     au_time, au_file, au_size,  ;
                                     au_filedat, au_filetim, au_fileatt,  ;
                                     au_positio) VALUES (cdEpa, sySdate(),  ;
                                     TIME(), acFiles(ni,1), acFiles(ni,2),  ;
                                     acFiles(ni,3), acFiles(ni,4),  ;
                                     acFiles(ni,5), -1)
                                    lrEadthisone = .T.
                               ELSE
                                    IF (tpAudit.au_positio<>-1)
                                         SELECT tpAudit
                                         REPLACE tpAudit.au_positio WITH -1
                                         lrEadthisone = .T.
                                    ENDIF
                               ENDIF
                               IF (lrEadthisone)
                                    = reAdfile(cpAth+acFiles(ni,1), ;
                                      "TpTmpJou",.T.)
                                    IF ( .NOT. EMPTY(paRam.pa_posmove))
                                         cmOvefilename = cpAth+acFiles(ni,1)
                                         cdEstfilename =  ;
                                          ALLTRIM(paRam.pa_posmove)+"\"+ ;
                                          acFiles(ni,1)
                                         ncOunt = 0
                                         DO WHILE (FILE(cdEstfilename))
                                              WAIT WINDOW NOWAIT  ;
                                               "Renaming file"
                                              cdEstfilename =  ;
                                               LEFT(cdEstfilename, AT(".",  ;
                                               cdEstfilename)+2)+ ;
                                               PADL(ALLTRIM(STR(ncOunt)),  ;
                                               2, "0")
                                              ncOunt = ncOunt+1
                                         ENDDO
                                         WAIT WINDOW NOWAIT  ;
                                          GetLangText("TOUCHPOS", ;
                                          "TXT_MOVINGJOURNAL")+" "+ ;
                                          cmOvefilename+" To "+cdEstfilename
                                         COPY FILE (cmOvefilename) TO  ;
                                          (cdEstfilename)
                                         ERASE (cmOvefilename)
                                         WAIT CLEAR
                                    ENDIF
                               ENDIF
                          ENDFOR
                     ENDIF
                     = clOsefile("TpAudit")
                ENDIF
                nfIles = ADIR(acFiles, cpAth+"*.vds")
                IF (nfIles>0)
                     IF (opEnfile(.F.,"TpAudit"))
                          FOR ni = 1 TO nfIles
                               lrEadthisone = .F.
                               IF ( .NOT. SEEK(cdEpa+UPPER(acFiles(ni,1))+ ;
                                  DTOS(acFiles(ni,3))+acFiles(ni,4),  ;
                                  "TpAudit"))
                                    SELECT tpAudit
                                    INSERT INTO TpAudit (au_depa, au_date,  ;
                                     au_time, au_file, au_size,  ;
                                     au_filedat, au_filetim, au_fileatt,  ;
                                     au_positio) VALUES (cdEpa, sySdate(),  ;
                                     TIME(), acFiles(ni,1), acFiles(ni,2),  ;
                                     acFiles(ni,3), acFiles(ni,4),  ;
                                     acFiles(ni,5), -1)
                                    lrEadthisone = .T.
                               ELSE
                                    IF (tpAudit.au_positio<>-1)
                                         SELECT tpAudit
                                         REPLACE tpAudit.au_positio WITH -1
                                         lrEadthisone = .T.
                                    ENDIF
                               ENDIF
                               IF (lrEadthisone)
                                    = reAdfile(cpAth+acFiles(ni,1), ;
                                      "TpTmpJou",.T.)
                                    IF ( .NOT. EMPTY(paRam.pa_posmove))
                                         cmOvefilename = cpAth+acFiles(ni,1)
                                         cdEstfilename =  ;
                                          ALLTRIM(paRam.pa_posmove)+"\"+ ;
                                          acFiles(ni,1)
                                         ncOunt = 0
                                         DO WHILE (FILE(cdEstfilename))
                                              cdEstfilename =  ;
                                               LEFT(cdEstfilename, AT(".",  ;
                                               cdEstfilename)+2)+ ;
                                               PADL(ALLTRIM(STR(ncOunt)),  ;
                                               2, "0")
                                              ncOunt = ncOunt+1
                                         ENDDO
                                         WAIT WINDOW NOWAIT  ;
                                          GetLangText("TOUCHPOS", ;
                                          "TXT_MOVINGJOURNAL")+" "+ ;
                                          cmOvefilename+" To "+cdEstfilename
                                         COPY FILE (cmOvefilename) TO  ;
                                          (cdEstfilename)
                                         ERASE (cmOvefilename)
                                         WAIT CLEAR
                                    ENDIF
                               ENDIF
                          ENDFOR
                     ENDIF
                ENDIF
                = clOsefile("TpAudit")
           ENDFOR
           IF (paRam.pa_topost)
                IF ( .NOT. USED("TpTmpJou"))
                     = opEnfile(.T.,"TpTmpJou")
                ENDIF
                naRtitotal = 0
                npAymtotal = 0
                SELECT poSt
                npOstorder = ORDER()
                SET ORDER TO 1
                SELECT tpTmpjou
                GOTO TOP
                DO WHILE ( .NOT. EOF("TpTmpJou"))
                     cnOw = DTOS(sySdate())+STR(tpTmpjou.dePt, 5)+ ;
                            STR(tpTmpjou.leDg)
                     DO WHILE (DTOS(sySdate())+STR(tpTmpjou.dePt, 5)+ ;
                        STR(tpTmpjou.leDg)==cnOw)
                          IF  .NOT. dlOcate('PosArti','po_artinum = '+ ;
                              sqLcnv(tpTmpjou.leDg))
                               lfOundit = .F.
                          ELSE
                               IF  .NOT. dlOcate('Article', ;
                                   'ar_artinum = '+sqLcnv(poSarti.po_brilart))
                                    lfOundit = .F.
                               ELSE
                                    nbRilarticle = arTicle.ar_artinum
                                    cdEscription =  ;
                                     EVALUATE("Article.Ar_Lang"+g_Langnum)
                                    csUpplement = ""
                                    lfOundit = .T.
                               ENDIF
                          ENDIF
                          IF lfOundit
                               cpOsarticle = ""
                          ELSE
                               nbRilarticle = paRam.pa_posdifa
                               = dlOcate('Article','ar_artinum = '+ ;
                                 sqLcnv(nbRilarticle))
                               cdEscription = EVALUATE("Article.Ar_Lang"+ ;
                                g_Langnum)
                               csUpplement = sqLcnv(tpTmpjou.leDg)+" "+ ;
                                ALLTRIM(tpTmpjou.itEmname)
                               cpOsarticle = sqLcnv(tpTmpjou.leDg)
                          ENDIF
                          IF  .NOT. dlOcate('Post','ps_date = '+ ;
                              sqLcnv(sySdate())+' and ps_artinum = '+ ;
                              sqLcnv(nbRilarticle)+ ;
                              ' and ps_userid = [TOUCHPOS]'+ ;
                              ' and ps_supplem = '+sqLcnv(cpOsarticle))
                               npOstid = neXtid('Post')
                               SELECT poSt
                               INSERT INTO Post (ps_postid, ps_date,  ;
                                      ps_artinum, ps_cashier, ps_descrip,  ;
                                      ps_ifc, ps_supplem, ps_time,  ;
                                      ps_units, ps_userid, ps_window,  ;
                                      ps_reserid, ps_origid, ps_paynum,  ;
                                      ps_price, ps_vat0, ps_vat1, ps_vat2,  ;
                                      ps_vat3, ps_vat4, ps_vat5, ps_vat6,  ;
                                      ps_vat7, ps_vat8, ps_vat9,  ;
                                      ps_cancel, ps_split, ps_prtype)  ;
                                      VALUES (npOstid, sySdate(),  ;
                                      nbRilarticle, 0, cdEscription, "",  ;
                                      csUpplement, TIME(), 1, "TOUCHPOS",  ;
                                      1, paRam.pa_extrsid,  ;
                                      paRam.pa_extrsid, 0, tpTmpjou.prIce,  ;
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, .F.,  ;
                                      .F., 0)
                          ENDIF
                          REPLACE poSt.ps_amount WITH poSt.ps_amount+ ;
                                  tpTmpjou.toTal
                          nvAt1field = 0
                          nvAt2field = 0
                          nvAt1amount = 0
                          nvAt2amount = 0
                          = geTvat(nbRilarticle,tpTmpjou.toTal, ;
                            @nvAt1field,@nvAt2field,@nvAt1amount,@nvAt2amount)
                          cmAcro = "Post.Ps_Vat"+STR(nvAt1field, 1)
                          Replace &cMacro With &cMacro + nVat1Amount
                          IF (nvAt2field>0)
                               cmAcro = "Post.Ps_Vat"+STR(nvAt2field, 1)
                               Replace &cMacro  With &cMacro + nVat2Amount
                          ENDIF
                          naRtitotal = naRtitotal+tpTmpjou.toTal
                          SKIP 1 IN tpTmpjou
                     ENDDO
                ENDDO
                SELECT tpTmpjou
                REPLACE orDerdate WITH sySdate() ALL
                = clOsefile("TpTmpJou")
                SELECT poSt
                SET ORDER TO nPostOrder
           ENDIF
           IF (opEnfile(.F.,"TpJour"))
                WAIT WINDOW NOWAIT GetLangText("TOUCHPOS","TXT_APPENDTOHIST")
                SELECT tpJour
                APPEND FROM (_screen.oGlobal.choteldir+"Tpos\TpTmpJou")
                = clOsefile("TpJour")
                WAIT CLEAR
           ENDIF
           IF (paRam.pa_topost)
                IF ( .NOT. USED("TpTmpPay"))
                     = opEnfile(.T.,"TpTmpPay")
                ENDIF
                SELECT poSt
                npOstorder = ORDER()
                SET ORDER TO 1
                SELECT tpTmppay
                GOTO TOP
                DO WHILE ( .NOT. EOF("TpTmpPay"))
                     cnOw = DTOS(sySdate())+STR(tpTmppay.dePt, 5)+ ;
                            STR(tpTmppay.reC, 4)
                     DO WHILE (DTOS(sySdate())+STR(tpTmppay.dePt, 5)+ ;
                        STR(tpTmppay.reC, 4)==cnOw)
                          IF  .NOT. dlOcate('PosPaym','py_paynum = '+ ;
                              sqLcnv(tpTmppay.reC))
                               lfOundit = .F.
                          ELSE
                               IF dlOcate('Paymetho','pm_paynum = '+ ;
                                  sqLcnv(poSpaym.py_paymeth))
                                    nbRilpaymethod = paYmetho.pm_paynum
                                    cdEscription =  ;
                                     EVALUATE("Paymetho.Pm_Lang"+g_Langnum)
                                    csUpplement = "Bill:"+ ;
                                     ALLTRIM(STR(tpTmppay.reCeiptn))
                                    lfOundit = .T.
                               ELSE
                                    lfOundit = .F.
                               ENDIF
                          ENDIF
                          IF (lfOundit)
                               cpOspayment = ""
                          ELSE
                               nbRilpaymethod = paRam.pa_posnpay
                               = dlOcate('Paymetho','pm_paynum = '+ ;
                                 sqLcnv(nbRilpaymethod))
                               = SEEK(nbRilpaymethod, "Paymetho")
                               cdEscription = EVALUATE("Paymetho.Pm_Lang"+ ;
                                g_Langnum)
                               csUpplement = sqLcnv(tpTmppay.reC)+" "+ ;
                                ALLTRIM(tpTmppay.teNdername)
                               cpOspayment = sqLcnv(tpTmppay.reC)
                          ENDIF
                          IF (poSpaym.py_post)
                               npOstid = neXtid('Post')
                               SELECT poSt
                               INSERT INTO Post (ps_postid, ps_date,  ;
                                      ps_paynum, ps_cashier, ps_descrip,  ;
                                      ps_ifc, ps_supplem, ps_time,  ;
                                      ps_units, ps_amount, ps_userid,  ;
                                      ps_window, ps_reserid, ps_origid,  ;
                                      ps_price, ps_vat0, ps_vat1, ps_vat2,  ;
                                      ps_vat3, ps_vat4, ps_vat5, ps_vat6,  ;
                                      ps_vat7, ps_vat8, ps_vat9,  ;
                                      ps_cancel, ps_split, ps_prtype)  ;
                                      VALUES (npOstid, sySdate(),  ;
                                      nbRilpaymethod, 0, cdEscription, "",  ;
                                      csUpplement, TIME(), tpTmppay.toTal,  ;
                                      tpTmppay.toTal*-1, "TOUCHPOS", 1,  ;
                                      paRam.pa_extrsid, paRam.pa_extrsid,  ;
                                      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  ;
                                      .F., .F., 0)
                          ENDIF
                          npAymtotal = npAymtotal+tpTmppay.toTal
                          SKIP 1 IN tpTmppay
                     ENDDO
                ENDDO
                IF (naRtitotal<>npAymtotal)
                     npOsamount = naRtitotal-npAymtotal
                     nbRilarticle = paRam.pa_posdifa
                     = SEEK(nbRilarticle, "Article")
                     cdEscription = EVALUATE("Article.Ar_Lang"+g_Langnum)
                     csUpplement = ""
                     npOstid = neXtid('Post')
                     SELECT poSt
                     INSERT INTO Post (ps_postid, ps_date, ps_artinum,  ;
                            ps_cashier, ps_descrip, ps_ifc, ps_supplem,  ;
                            ps_time, ps_units, ps_userid, ps_window,  ;
                            ps_reserid, ps_origid, ps_paynum, ps_price,  ;
                            ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4,  ;
                            ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9,  ;
                            ps_cancel, ps_split, ps_prtype) VALUES  ;
                            (npOstid, sySdate(), nbRilarticle, 0,  ;
                            cdEscription, "", csUpplement, TIME(), 1,  ;
                            "TOUCHPOS", 1, paRam.pa_extrsid,  ;
                            paRam.pa_extrsid, 0, npOsamount, 0, 0, 0, 0,  ;
                            0, 0, 0, 0, 0, 0, .F., .F., 0)
                     REPLACE poSt.ps_userid WITH "TOUCHPOS"
                     REPLACE poSt.ps_amount WITH npOsamount
                     REPLACE poSt.ps_units WITH 1
                ENDIF
                SELECT tpTmppay
                REPLACE enDdate WITH sySdate() ALL
                = clOsefile("TpTmpPay")
                SELECT poSt
                SET ORDER TO nPostOrder
           ENDIF
      ENDIF
 ENDIF
 SELECT arTicle
 SET ORDER TO nArtiOrder
 GOTO naRtirecord
 SELECT paYmetho
 SET ORDER TO nPaymOrder
 GOTO npAymrecord
 = clOsefile("POSArti")
 = clOsefile("POSPaym")
 RETURN lcOntinue
ENDFUNC
*
FUNCTION ReadFile
 PARAMETER ctPosfilename, cdEstination, laPpend, npOsition
 PRIVATE ccOpy
 PRIVATE ac_fields
 PRIVATE cfIelds
 PRIVATE cfIeldname
 PRIVATE nhAndle
 PRIVATE nlEngth
 PRIVATE ctMpname
 PRIVATE nrEturnpos
 IF (PARAMETERS()==3)
      npOsition = 0
 ENDIF
 nrEturnpos = 0
 IF (FILE(ctPosfilename))
      COPY FILE (ctPosfilename) TO "TouchPos.Tmp"
      nhAndle = FOPEN("TouchPos.Tmp")
      WAIT WINDOW NOWAIT GetLangText("TOUCHPOS","TXT_READING")
      IF (nhAndle==-1)
           = alErt(GetLangText("TOUCHPOS","TXT_CANNOTOPEN")+" "+ctPosfilename, ;
             GetLangText("TOUCHPOS","TXT_OPENERROR"))
      ELSE
           nlEngth = 0
           cfIelds = FGETS(nhAndle)
           IF EMPTY(cfIelds)
                = FCLOSE(nhAndle)
                RETURN
           ENDIF
           cfIelds = cfIelds+","
           DO WHILE (LEN(cfIelds)>0)
                nlEngth = nlEngth+1
                DIMENSION ac_fields[nlEngth, 4]
                npOs = AT(",", cfIelds)
                cfIeldname = ALLTRIM(STRTRAN(SUBSTR(cfIelds, 1, npOs-1),  ;
                             "#", "NR"))
                cfIelds = SUBSTR(cfIelds, npOs+1)
                ac_fields[nlEngth, 1] = cfIeldname
           ENDDO
           neNtry = 0
           cfIelds = FGETS(nhAndle)
           IF EMPTY(cfIelds)
                = FCLOSE(nhAndle)
                RETURN
           ENDIF
           cfIelds = cfIelds+","
           ccOpy = cfIelds
           DO WHILE (LEN(cfIelds)>1)
                neNtry = neNtry+1
                npOs = AT(",", cfIelds)
                cfIeldname = SUBSTR(cfIelds, 1, npOs-1)
                nfIeldlength = LEN(cfIeldname)
                cfIeldname = ALLTRIM(cfIeldname)
                cfIelds = SUBSTR(cfIelds, npOs+1)
                DO CASE
                     CASE AT(":", cfIeldname)>0
                          ac_fields[neNtry, 2] = "C"
                          ac_fields[neNtry, 3] = 8
                          ac_fields[neNtry, 4] = 0
                     CASE VAL(cfIeldname)==0 .AND. LEFT(cfIeldname, 1)<> ;
                          "0" .AND. LEFT(cfIeldname, 1)<>"-"
                          ac_fields[neNtry, 2] = "C"
                          ac_fields[neNtry, 3] = nfIeldlength
                          ac_fields[neNtry, 4] = 0
                     CASE AT("-", cfIeldname)>0 .AND. RAT("-",  ;
                          cfIeldname)<>AT("-", cfIeldname)
                          ac_fields[neNtry, 2] = "D"
                          ac_fields[neNtry, 3] = 8
                          ac_fields[neNtry, 4] = 0
                     OTHERWISE
                          ac_fields[neNtry, 2] = "N"
                          ac_fields[neNtry, 3] = nfIeldlength*2
                          ac_fields[neNtry, 4] = IIF(AT(".", cfIeldname)== ;
                                   0, 0, LEN(cfIeldname)-RAT(".",  ;
                                   cfIeldname))*2
                ENDCASE
           ENDDO
           CREATE CURSOR TouchPos FROM ARRAY ac_fields
           IF (npOsition==0)
                cfIelds = ccOpy
           ELSE
                = FSEEK(nhAndle, npOsition, 0)
                cfIelds = FGETS(nhAndle)+","
                WAIT WINDOW NOWAIT GetLangText("TOUCHPOS","TXT_READING")+" ("+ ;
                     ALLTRIM(STR(npOsition))+")"
           ENDIF
           DO WHILE (LEN(cfIelds)>1)
                IF (OCCURS(",", cfIelds)<>neNtry)
                     WAIT WINDOW TIMEOUT 2 "Too Many Fields"
                     = loGdata(cfIelds,"Errors.POS")
                ELSE
                     APPEND BLANK
                     nlEngth = 0
                     DO WHILE (LEN(cfIelds)>1)
                          nlEngth = nlEngth+1
                          npOs = AT(",", cfIelds)
                          cfIeldname = SUBSTR(cfIelds, 1, npOs-1)
                          cfIeldname = ALLTRIM(cfIeldname)
                          cfIelds = SUBSTR(cfIelds, npOs+1)
                          DO CASE
                               CASE ac_fields(nlEngth,2)=="N"
                                    xdAta = VAL(cfIeldname)
                                    Replace &ac_Fields[nLength, 1] With xData
                               CASE ac_fields(nlEngth,2)=="C"
                                    xdAta = cfIeldname
                                    Replace &ac_Fields[nLength, 1] With OemToAnsi(xData)
                               CASE ac_fields(nlEngth,2)=="D"
                                    xdAta = CTOD(cfIeldname)
                                    Replace &ac_Fields[nLength, 1] With xData
                          ENDCASE
                     ENDDO
                ENDIF
                cfIelds = FGETS(nhAndle)+","
           ENDDO
           nrEturnpos = FSEEK(nhAndle, 0, 2)
           IF ( .NOT. FCLOSE(nhAndle))
                = alErt(GetLangText("TOUCHPOS","TXT_CLOSECANNOT")+" "+ ;
                  ctPosfilename,GetLangText("TOUCHPOS","TXT_CLOSEERROR"))
           ENDIF
           IF (USED("TouchPos"))
                IF (opEnfile(.T.,cdEstination))
                     SELECT toUchpos
                     ctMpname = fiLetemp()
                     COPY TO (ctMpname) ALL
                     SELECT (cdEstination)
                     IF ( .NOT. laPpend)
                          ZAP
                     ENDIF
                     APPEND FROM (ctMpname)
                ENDIF
                = clOsefile(cdEstination)
                = clOsefile("TouchPos")
           ENDIF
      ENDIF
 ENDIF
 WAIT CLEAR
 RETURN nrEturnpos
ENDFUNC
*
