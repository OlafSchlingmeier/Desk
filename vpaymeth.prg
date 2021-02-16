 PARAMETER p_Row, p_Col, p_Windowname, pnAddressid
 PRIVATE lvOucherisvalid
 PRIVATE lpMisvalid
 PRIVATE l_Oldarea
 PRIVATE a_Field
 DIMENSION a_Field[3, 2]
 a_Field[1, 1] = "pm_paynum"
 a_Field[1, 2] = 5
 a_Field[2, 1] = "pm_lang"+g_Langnum
 a_Field[2, 2] = 20
 a_Field[3, 1] = "Iif(pm_paytyp = 2, pm_rate, Space(12))"
 a_Field[3, 2] = 17
 l_Oldarea = SELECT()
 lpMisvalid = .F.
 SELECT paYmetho
 nlAstkey = LASTKEY()
 IF ((nlAstkey==27 .OR. nlAstkey==24) .AND. UPPER(p_Windowname)=="WPAY")
      lpMisvalid = .T.
 ELSE
      IF EMPTY(M.ps_paynum) .OR.  .NOT. SEEK(M.ps_paynum) .OR.  ;
         INLIST(paYmetho.pm_paynum, paRam.pa_payonld, paRam.pa_rndpay) .or. pm_inactiv
           GOTO TOP
           IF myPopup(p_Windowname,p_Row+1,p_Col,5,@a_Field, ;
              "!Inlist(Paymetho.pm_paynum, Param.pa_payonld, Param.pa_rndpay) .and. !pm_inactiv", ;
              ".t.")>0
                M.ps_paynum = paYmetho.pm_paynum
                M.ps_price = IIF(EMPTY(paYmetho.pm_rate) .OR.  ;
                             paYmetho.pm_paynum=1, 1.00, paYmetho.pm_rate)
                M.ps_units = ROUND(l_Balance/paYmetho.pm_calcrat, 2)
                M.l_Lang = EVALUATE("pm_lang"+g_Langnum)
                M.ps_supplem = ""
                lpMisvalid = .T.
           ENDIF
      ELSE
           M.ps_price = IIF(EMPTY(paYmetho.pm_rate) .OR.  ;
                        paYmetho.pm_paynum=1, 1.00, paYmetho.pm_rate)
           M.ps_units = ROUND(l_Balance/paYmetho.pm_calcrat, 2)
           M.l_Lang = EVALUATE("pm_lang"+g_Langnum)
           M.ps_supplem = ""
           lpMisvalid = .T.
      ENDIF
      IF (lpMisvalid)
           DO CASE
                CASE paYmetho.pm_paytyp=4
                     lpMisvalid = EMPTY(alWcledg(pnAddressid,.T.))
                CASE paYmetho.pm_paytyp=3
                     IF  _SCREEN.DV .AND. EMPTY(paYmetho.pm_aracct)
                          = alErt(GetLangText("VPAYMETH","TA_NOARACCT"))
                     ENDIF
                     IF UPPER(p_Windowname)=='WPAY'
                          M.ps_supplem = TRIM(reServat.rs_ccnum)+' '+ ;
                           TRIM(reServat.rs_ccexpy)
                     ENDIF
                CASE paYmetho.pm_paytyp==7
                     lvOuchervalid = .F.
                     nnUmber = 0
                     naMount = ROUND(l_Balance/M.ps_price, 2)
                     DO voUcherv IN Voucher WITH lvOuchervalid, nnUmber,  ;
                        naMount
                     IF ( .NOT. lvOuchervalid)
                          lpMisvalid = .F.
                     ELSE
                          M.ps_price = 1
                          M.ps_units = naMount
                          M.l_Lang = EVALUATE("pm_lang"+g_Langnum)
                          M.ps_supplem = "V#:"+ALLTRIM(STR(nnUmber, 12, 0))
                          lpMisvalid = .T.
                     ENDIF
           ENDCASE
           SHOW GETS
      ENDIF
 ENDIF
 SELECT (l_Oldarea)
 RETURN lpMisvalid
ENDFUNC
*
