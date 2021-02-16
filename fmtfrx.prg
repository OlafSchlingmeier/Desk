*
PROCEDURE FmtFrx
 LOCAL adLg, clAbel
 DIMENSION adLg[2, 8]
 adLg[1, 1] = "papersize"
 adLg[1, 2] = "A4;Letter"
 adLg[1, 3] = "1"
 adLg[1, 4] = '@*RH'
 adLg[1, 5] = 20
 adLg[1, 6] = ""
 adLg[1, 7] = ""
 adLg[1, 8] = 1
 IF paRam.pa_currdec=0
      clAbel = '999999;999'+SET('separator')+'999'
 ELSE
      clAbel = '9999'+SET('point')+'99;9'+SET('separator')+'999'+ ;
               SET('point')+'99'
 ENDIF
 adLg[2, 1] = "currency"
 adLg[2, 2] = clAbel
 adLg[2, 3] = "1"
 adLg[2, 4] = '@*RH'
 adLg[2, 5] = 20
 adLg[2, 6] = ""
 adLg[2, 7] = ""
 adLg[2, 8] = 1
 IF diAlog("Format report forms",'Specify Papersize and Currency Format',@adLg)
      fmTpaper(adLg(1,8)=2)
      fmTcurrency(adLg(2,8)=2)
 ENDIF
ENDPROC
*
PROCEDURE FmtCurrency
 LPARAMETERS plSeparator
 LOCAL naRea
 LOCAL r, nmAxpixels, cfOntname, cfOntstyle, nfOntsize, nlOop, npIxelsize,  ;
       cpIcture
 PRIVATE afRx
 naRea = SELECT()
 FOR r = 1 TO ADIR(afRx, 'Report\*.FRX')
      WAIT WINDOW NOWAIT afRx(r,1)
      USE ('Report\'+afRx(r,1)) ALIAS frX IN 0
      SELECT frX
      SCAN ALL FOR 'CURRENCY'$UPPER(coMment) .OR. 'EURO'$UPPER(coMment)
           nmAxpixels = CEILING(96*(frX.wiDth/10000))-9
           cfOntname = foNtface
           cfOntstyle = nuM2style(foNtstyle)
           nfOntsize = foNtsize
           npIxelsize = 0
           nlOop = 0
           IF paRam.pa_currdec=2 .OR. 'EURO'$UPPER(coMment)
                cpIcture = '.99'
           ELSE
                cpIcture = ''
           ENDIF
           DO WHILE npIxelsize<nmAxpixels
                nlOop = nlOop+1
                IF plSeparator .AND. MOD(nlOop, 3)=0
                     cpIcture = ',9'+cpIcture
                ELSE
                     cpIcture = '9'+cpIcture
                ENDIF
                nfOxelsize = TXTWIDTH(cpIcture, cfOntname, nfOntsize,  ;
                             cfOntstyle)
                npIxelsize = CEILING(nfOxelsize*FONTMETRIC(6, cfOntname,  ;
                             nfOntsize, cfOntstyle))
           ENDDO
           cpIcture = SUBSTR(cpIcture, 2)
           IF LEFT(cpIcture, 1)=','
                cpIcture = SUBSTR(cpIcture, 2)
           ENDIF
           IF LEFT(piCture, 4)=='"@Z '
                REPLACE piCture WITH '"@Z '+cpIcture+'"'
           ELSE
                REPLACE piCture WITH '"'+cpIcture+'"'
           ENDIF
      ENDSCAN
      USE IN frX
 ENDFOR
 WAIT CLEAR
 SELECT (naRea)
ENDPROC
*
PROCEDURE FmtPaper
 LPARAMETERS plLetter
 LOCAL naRea, r, cbUff, npOs
 PRIVATE afRx
 naRea = SELECT()
 FOR r = 1 TO ADIR(afRx, 'Report\*.FRX')
      WAIT WINDOW NOWAIT afRx(r,1)
      USE ('Report\'+afRx(r,1)) ALIAS frX IN 0
      SELECT frX
      LOCATE ALL FOR obJcode=53
      BLANK FIELDS taG, taG2
      cbUff = exPr
      nsTart = AT('PAPERSIZE=', cbUff)+10
      cbUff = SUBSTR(cbUff, 1, nsTart-1)+IIF(plLetter, '1', '9')+ ;
              SUBSTR(cbUff, nsTart+1)
      REPLACE exPr WITH cbUff, wiDth WITH -1
      FLUSH
      USE IN frX
 ENDFOR
 WAIT CLEAR
 SELECT (naRea)
ENDPROC
*
PROCEDURE FmtBill1Note
 LOCAL naRea, r
 PRIVATE afRx
 naRea = SELECT()
 FOR r = 1 TO ADIR(afRx, 'Report\bill1*.frx')
      WAIT WINDOW NOWAIT afRx(r,1)
      USE ('Report\'+afRx(r,1)) ALIAS frX IN 0
      SELECT frX
      REPLACE exPr WITH [FNGetWindowData(reservat.rs_rsid, ps_window, "pw_note")] ;
           FOR LOWER(CHRTRAN(exPr," ","")) == "iif(ps_window=1,reservat.rs_notew1,iif(ps_window=2,reservat.rs_notew2,reservat.rs_notew3))"
      FLUSH
      USE IN frX
 ENDFOR
 FOR r = 1 TO ADIR(afRx, 'Report\billcpy1*.frx')
      WAIT WINDOW NOWAIT afRx(r,1)
      USE ('Report\'+afRx(r,1)) ALIAS frX IN 0
      SELECT frX
      REPLACE exPr WITH [FNGetWindowData(histres.hr_rsid, hp_window, "pw_note", .T.)] ;
           FOR LOWER(CHRTRAN(exPr," ","")) == "iif(hp_window=1,histres.hr_notew1,iif(hp_window=2,histres.hr_notew2,histres.hr_notew3))"
      FLUSH
      USE IN frX
 ENDFOR
 WAIT CLEAR
 SELECT (naRea)
ENDPROC
*
FUNCTION Num2Style
 PARAMETER pnNum
 PRIVATE i, csTr, npOwer, csTyles, crEt
 IF pnNum=0
      RETURN 'N'
 ENDIF
 csTr = ""
 csTyles = "BIUOSCE-"
 FOR i = 8 TO 1 STEP -1
      npOwer = ROUND(2^(i-1), 0)
      IF pnNum>=npOwer
           csTr = csTr+SUBSTR(csTyles, i, 1)
      ENDIF
      pnNum = MOD(pnNum, npOwer)
 ENDFOR
 crEt = ""
 FOR i = 1 TO LEN(csTr)
      crEt = crEt+SUBSTR(csTr, LEN(csTr)+1-i, 1)
 ENDFOR
 RETURN crEt
ENDFUNC
*
