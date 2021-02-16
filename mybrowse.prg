 PARAMETER ctItle, nlInes, acFields, cfOrclause, cwHileclause,  ;
           cbRowsebuttons, cfUnction, csOurce, ccAlcfunction,  ;
           ccOlorfunction, nbRowsetimeout, cuSealias
 PRIVATE laCtivebar
 PRIVATE ncHoice1
 PRIVATE ncHoice2
 PRIVATE ncOl
 PRIVATE ndUmmy
 PRIVATE ndEfault
 PRIVATE lmOve
 PRIVATE nrOw, npOs
 PRIVATE ncHoice
 PRIVATE ncUrline
 PRIVATE ncUrthumb
 PRIVATE nfIeldarraylength
 PRIVATE lhAspicture
 PRIVATE nmAxlines
 PRIVATE anRecordnumbers
 PRIVATE nrEturnvalue
 PRIVATE ntOtalwidth
 PRIVATE cwIndowname
 PRIVATE npArameters
 EXTERNAL ARRAY acFields
 npArameters = PARAMETERS()
 DO WHILE (.T.)
      ndEfault = 1
      lmOve = .F.
      IF (SUBSTR(ctItle, 5, 1)==">")
           lmOve = .T.
           nrOw = VAL(SUBSTR(ctItle, 1, 2))
           ncOl = VAL(SUBSTR(ctItle, 3, 2))
           ctItle = SUBSTR(ctItle, 6)
      ENDIF
      ncHoice = 1
      ncHoice1 = 1
      ncHoice2 = 1
      ndUmmy = 1
      ncUrline = 1
      ncUrthumb = piXv(17)
      nmAxlines = nlInes
      nrEturnvalue = 0
      nfIeldarraylength = ALEN(acFields, 1)
      ntOtalwidth = wiDth()
      laCtivebar = .T.
      lhAspicture = .F.
      npOs = AT('@', ctItle)
      IF npOs>0
           cwIndowname = SUBSTR(ctItle, 1, npOs-1)
           ctItle = SUBSTR(ctItle, npOs+1)
      ELSE
           cwIndowname = SYS(2015)
      ENDIF
      DIMENSION anRecordnumbers(nmAxlines)
      STORE -1 TO anRecordnumbers
      IF (npArameters<12)
           cuSealias = ""
      ENDIF
      IF (npArameters<11)
           nbRowsetimeout = 0
      ENDIF
      IF (npArameters<10)
           ccOlorfunction = ""
      ENDIF
      IF (npArameters==8)
           ccAlcfunction = ""
      ENDIF
      IF (ALEN(acFields, 2)==4)
           lhAspicture = .T.
      ENDIF
      IF (WVISIBLE(cwIndowname))
           ACTIVATE WINDOW TOP (cwIndowname)
           nrEturnvalue = -3
           EXIT
      ENDIF
      If !(&cWhileClause) And !Eof()
           Locate All For ((&cForClause) And (&cWhileClause))
           IF ( .NOT. FOUND())
                nrEturnvalue = -1
                EXIT
           ENDIF
      ENDIF
      If !(&cForClause) And !Eof()
           Locate Rest For (&cForClause) While (&cWhileClause)
           IF  .NOT. (FOUND())
                nrEturnvalue = -2
                EXIT
           ENDIF
      ENDIF
      IF (EMPTY(cbRowsebuttons))
           clEvel = ""
           cbRowsebuttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+ ;
                            "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
           l_Buttonsize = 15
      ELSE
           IF (LEFT(cbRowsebuttons, 1)=="#")
                l_Buttonsize = 12
                cbRowsebuttons = SUBSTR(cbRowsebuttons, 2)
           ELSE
                l_Buttonsize = 14
           ENDIF
      ENDIF
      DO CASE
           CASE SUBSTR(cbRowsebuttons, 1, 1)=="2"
                DEFINE WINDOW (cwIndowname) FROM 0, 0 TO nmAxlines+ ;
                       piXv(96), ntOtalwidth FONT "Arial", 10 FLOAT NOCLOSE  ;
                       NOZOOM TITLE chIldtitle(ctItle) ICON FILE  ;
                       "bitmap\Hotel.Ico" NOMDI DOUBLE
                IF (lmOve)
                     MOVE WINDOW (cwIndowname) TO nrOw, ncOl
                ELSE
                     MOVE WINDOW (cwIndowname) CENTER
                ENDIF
                ACTIVATE WINDOW NOSHOW (cwIndowname)
                l_Maxbuttons = OCCURS(";", cbRowsebuttons)+1
                l_Maxbuttons = CEILING(l_Maxbuttons/2)
                l_Seppos = AT(";", cbRowsebuttons, l_Maxbuttons)
                l_Buttons1 = SUBSTR(cbRowsebuttons, 2, l_Seppos-2)
                l_Buttons2 = SUBSTR(cbRowsebuttons, l_Seppos+1)
                l_Maxbuttons = OCCURS(";", l_Buttons1)+1
                l_Col = (WCOLS()-(l_Maxbuttons*l_Buttonsize))/2
                l_Row = WROWS()-piXv(50)
                l_Maxbuttons = l_Maxbuttons+OCCURS(";", l_Buttons2)+1
                cbUttons = cbRowsebuttons+";"
                ncOunter = 1
                DO WHILE (LEN(cbUttons)>0)
                     npOs = AT(";", cbUttons)
                     ccUrrent = SUBSTR(cbUttons, 1, npOs-1)
                     IF (AT("\!", ccUrrent)>0)
                          ndEfault = ncOunter
                          EXIT
                     ENDIF
                     cbUttons = SUBSTR(cbUttons, npOs+1)
                     ncOunter = ncOunter+1
                ENDDO
                @ l_Row, l_Col GET ncHoice1 SIZE nbUttonheight,  ;
                  l_Buttonsize, 0 FUNCTION "*"+"H"+"N" PICTURE l_Buttons1  ;
                  VALID vcHoice()
                @ l_Row+nbUttonheight, l_Col GET ncHoice2 SIZE  ;
                  nbUttonheight, l_Buttonsize, 0 FUNCTION "*"+"H"+"N"  ;
                  PICTURE l_Buttons2 VALID vcHoice()
                @ 0, 0 GET ndUmmy STYLE "B" SIZE nmAxlines+piXv(20),  ;
                  WCOLS() FUNCTION "*"+"*I"+"N" PICTURE "" WHEN viNvisible()
           OTHERWISE
                DEFINE WINDOW (cwIndowname) FROM 0, 0 TO nmAxlines+ ;
                       piXv(72), ntOtalwidth FONT "Arial", 10 FLOAT NOCLOSE  ;
                       NOZOOM TITLE chIldtitle(ctItle) ICON FILE  ;
                       "bitmap\Hotel.Ico" NOMDI DOUBLE
                IF (lmOve)
                     MOVE WINDOW (cwIndowname) TO nrOw, ncOl
                ELSE
                     MOVE WINDOW (cwIndowname) CENTER
                ENDIF
                ACTIVATE WINDOW NOSHOW (cwIndowname)
                l_Maxbuttons = OCCURS(";", cbRowsebuttons)+1
                l_Col = (WCOLS()-(l_Maxbuttons*l_Buttonsize)-1)/2
                l_Row = WROWS()-piXv(26)
                cbUttons = cbRowsebuttons+";"
                ncOunter = 1
                DO WHILE (LEN(cbUttons)>0)
                     npOs = AT(";", cbUttons)
                     ccUrrent = SUBSTR(cbUttons, 1, npOs-1)
                     IF (AT("\!", ccUrrent)>0)
                          ndEfault = ncOunter
                          EXIT
                     ENDIF
                     cbUttons = SUBSTR(cbUttons, npOs+1)
                     ncOunter = ncOunter+1
                ENDDO
                @ l_Row, l_Col GET ncHoice SIZE nbUttonheight,  ;
                  l_Buttonsize, 0 FUNCTION "*"+"H"+"N" PICTURE  ;
                  cbRowsebuttons VALID vcHoice()
                @ 0, 0 GET ndUmmy SIZE nmAxlines+piXv(20), WCOLS()  ;
                  FUNCTION "*"+"*I"+"N" PICTURE "" WHEN viNvisible()
      ENDCASE
      = diSpheader()
      l_Line = 1
      IF ( .NOT. EOF())
           l_Firstrec = RECNO()
           Locate Rest For (&cForClause) While (&cWhileClause)
           DO WHILE (FOUND() .AND. l_Line<=nmAxlines)
                anRecordnumbers[l_Line] = RECNO()
                l_Line = diSpline(l_Line)+1
                CONTINUE
           ENDDO
           GOTO l_Firstrec
      ELSE
           anRecordnumbers[l_Line] = RECNO()
           = diSpline(l_Line)
      ENDIF
      SHOW WINDOW (cwIndowname)
      PUSH KEY CLEAR
      ON KEY LABEL F1 HELP()
      ON KEY LABEL UPARROW DO MOVE WITH   -1
      ON KEY LABEL DNARROW DO MOVE WITH    1
      ON KEY LABEL PGUP DO MOVE WITH (-NMAXLINES)
      ON KEY LABEL PGDN DO MOVE WITH (NMAXLINES)
      ON KEY LABEL HOME DO MOVE WITH (-NCURLINE + 1)
      ON KEY LABEL END DO MOVE WITH (NMAXLINES - NCURLINE)
      lbRcontinue = .T.
      READ TIMEOUT nbRowsetimeout CYCLE OBJECT ndEfault ACTIVATE  ;
           acTivate() DEACTIVATE deActivate() valid 0
      POP KEY
      CLEAR GETS
      RELEASE WINDOW (cwIndowname)
      = chIldtitle("")
      EXIT
 ENDDO
 RETURN nrEturnvalue
ENDFUNC
*
FUNCTION Activate
 IF  .NOT. EMPTY(gcButtonfunction)
      do &gcButtonFunction
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION Deactivate
 IF WONTOP()='REPORT DESIGNER' 
      RETURN .F.
 ELSE
 	if gl_valid
 		CLEAR READ
 	ENDIF
 	RETURN .T.
 ENDIF
 RETURN
ENDFUNC
*
FUNCTION vInvisible
 PRIVATE nmOuserow
 PRIVATE nmOusecol
 PRIVATE nnExtkey
 PRIVATE nlImit
 nmOuserow = FLOOR(MROW()-piXv(18))+1
 nmOusecol = FLOOR(MCOL())
 DO CASE
      CASE nmOuserow==0 .AND. nmOusecol>=WCOLS()-piXh(24)
           = moVe(-1)
           WAIT WINDOW TIMEOUT _DBLCLICK ""
           DO WHILE MDOWN()
                = moVe(-1)
           ENDDO
      CASE nmOuserow==nmAxlines .AND. nmOusecol>=WCOLS()-piXh(24)
           = moVe(1)
           WAIT WINDOW TIMEOUT _DBLCLICK ""
           DO WHILE MDOWN()
                = moVe(1)
           ENDDO
      CASE nmOuserow>=1 .AND. nmOuserow<=nmAxlines .AND. nmOusecol>=0  ;
           .AND. nmOusecol<=WCOLS()-piXh(24)
           nlImit = SECONDS()+_DBLCLICK
           DO WHILE (SECONDS()<nlImit)
                nnExtkey = INKEY("HM")
                IF (nnExtkey==151)
                     IF (anRecordnumbers(nmOuserow)>0)
                          l_Oldcurr = ncUrline
                          ncUrline = nmOuserow
                          l_Oldcurr = diSpline(l_Oldcurr)
                          ncUrline = diSpline(ncUrline)
                          = INKEY(_DBLCLICK, "H")
                          GOTO anRecordnumbers(nmOuserow)
                          M.ncHoice = M.ndEfault
*				  IF UPPER(_screen.ActiveForm.name) = 'WRSBROWSE'
                          	keyboard '{SPACEBAR}'&&Push currently selected button on mybrowse window
*                          ELSE	
*                          	= vcHoice()
*                          ENDIF
                          RETURN .F.
                     ENDIF
                ENDIF
           ENDDO
           = moVe(nmOuserow-ncUrline)
 ENDCASE
 RETURN .F.
ENDFUNC
*
FUNCTION vChoice
 PUSH KEY CLEAR
 ON KEY LABEL F1 HELP()
 PRIVATE l_Line
 = reSelect(acFields(1,1),M.cuSealias)
 IF _CUROBJ>0 .AND. VARREAD()<>'NDUMMY'
      M.ncHoice = _CUROBJ
 ENDIF
 DO CASE
      CASE M.ncHoice==1
           CLEAR READ
           nrEturnvalue = IIF( .NOT. EOF(), RECNO(), -3)
      CASE  .NOT. EMPTY(cfUnction)
           IF (anRecordnumbers(ncUrline)<>RECNO() .AND.  ;
              anRecordnumbers(ncUrline)>0)
                GOTO anRecordnumbers(ncUrline)
           ENDIF
           IF DELETED()
                ?? CHR(7)
           ELSE
                Do &cFunction With m.nChoice In (cSource)
           ENDIF
           FLUSH
           IF (g_Refreshall)
                = diSpbackground()
                STORE -1 TO anRecordnumbers
                anRecordnumbers[1] = RECNO()
                l_Line = 1
                ncUrline = 1
                Locate Rest For (&cForClause) While (&cWhileClause)
                DO WHILE (FOUND() .AND. l_Line<=nmAxlines)
                     anRecordnumbers[l_Line] = RECNO()
                     l_Line = diSpline(l_Line)+1
                     CONTINUE
                ENDDO
                GOTO anRecordnumbers(1)
                g_Refreshall = .F.
           ELSE
                = moVe(0)
           ENDIF
           IF g_Refreshcurr
                ncUrline = diSpline(ncUrline)
                g_Refreshcurr = .F.
           ENDIF
      CASE M.ncHoice==2
           CLEAR READ
           nrEturnvalue = 0
 ENDCASE
 POP KEY
 RETURN .T.
ENDFUNC
*
PROCEDURE Move
 PARAMETER ntOmove
 CLEAR TYPEAHEAD 
 IF SET("Datasession")>1
 	RETURN
 ENDIF
 PUSH KEY CLEAR
 PRIVATE nrEcsmoved
 = reSelect(acFields(1,1),M.cuSealias)
 ACTIVATE WINDOW NOSHOW (cwIndowname)
 DO CASE
      CASE ntOmove==1
           DO CASE
                CASE ncUrline<nmAxlines .AND. anRecordnumbers(ncUrline+1)>0
                     ncUrline = ncUrline+1
                     = diSpline(ncUrline-1)
                     = diSpline(ncUrline)
                CASE (skIp(1)==1)
                     SCROLL piXv(19), piXh(1), nmAxlines+piXv(3), WCOLS()- ;
                            piXh(24), 1
                     = ADEL(anRecordnumbers, 1)
                     anRecordnumbers[nmAxlines] = RECNO()
                     = diSpline(ncUrline-1)
                     = diSpline(ncUrline)
                     = moVescroll(1)
                OTHERWISE
                     ?? CHR(7)
                     = moVescroll(99)
           ENDCASE
      CASE ntOmove==-1
           DO CASE
                CASE ncUrline>1
                     ncUrline = ncUrline-1
                     = diSpline(ncUrline+1)
                     = diSpline(ncUrline)
                CASE skIp(-1)==-1
                     SCROLL piXv(19), piXh(1), nmAxlines+piXv(3), WCOLS()- ;
                            piXh(24), -1
                     = AINS(anRecordnumbers, 1)
                     anRecordnumbers[1] = RECNO()
                     = diSpline(ncUrline+1)
                     = diSpline(ncUrline)
                     = moVescroll(-1)
                OTHERWISE
                     ?? CHR(7)
                     = moVescroll(0)
           ENDCASE
      CASE ntOmove==nmAxlines
           IF (anRecordnumbers(nmAxlines)>0)
                GOTO anRecordnumbers(nmAxlines)
                nrEcsmoved = 0
                DO WHILE (nrEcsmoved<ntOmove .AND. skIp(1)==1)
                     nrEcsmoved = nrEcsmoved+1
                     = ADEL(anRecordnumbers, 1)
                     anRecordnumbers[nmAxlines] = RECNO()
                ENDDO
                ncUrline = 1
                SCROLL 2, 2, nmAxlines+1, ntOtalwidth, 0
                = diSpall()
                = moVescroll(IIF(nrEcsmoved=0, 99, nrEcsmoved))
                = moVe(1)
                = moVe(-1)
           ENDIF
      CASE ntOmove==-nmAxlines
           GOTO anRecordnumbers(1)
           nrEcsmoved = 0
           DO WHILE (nrEcsmoved<-ntOmove .AND. skIp(-1)==-1)
                nrEcsmoved = nrEcsmoved+1
                = AINS(anRecordnumbers, 1)
                anRecordnumbers[1] = RECNO()
           ENDDO
           ncUrline = 1
           SCROLL 2, 2, nmAxlines+1, ntOtalwidth, 0
           = diSpall()
           = moVescroll(IIF(nrEcsmoved=0, 0, -nrEcsmoved))
           = moVe(1)
           = moVe(-1)
      CASE ntOmove>1 .AND. ncUrline+ntOmove<=nmAxlines
           DO WHILE (anRecordnumbers(ncUrline+ntOmove)<0)
                ntOmove = ntOmove-1
           ENDDO
           IF (ntOmove<>0)
                ncUrline = ncUrline+ntOmove
                = diSpline(ncUrline-ntOmove)
                = diSpline(ncUrline)
           ENDIF
      CASE ntOmove<1 .AND. ntOmove<>0 .AND. ncUrline<=nmAxlines-ntOmove
           ncUrline = ncUrline+ntOmove
           = diSpline(ncUrline-ntOmove)
           = diSpline(ncUrline)
      CASE ntOmove==0
           SET DELETED OFF
           IF EOF()
                IF  .NOT. BOF()
                     SKIP -1
                ENDIF
                IF  .NOT. EOF()
                     SKIP 1
                ENDIF
           ELSE
                IF  .NOT. EOF()
                     SKIP 1
                ENDIF
                IF  .NOT. BOF()
                     SKIP -1
                ENDIF
           ENDIF
           SET DELETED ON
           = diSpline(ncUrline)
 ENDCASE
 POP KEY
 SHOW WINDOW (cwIndowname)
 RETURN
ENDPROC
*
FUNCTION DispAll
 PRIVATE ndAline
 ndAline = 1
 DO WHILE (ndAline<=nmAxlines .AND. anRecordnumbers(ndAline)>0)
      = diSpline(ndAline)
      ndAline = ndAline+1
 ENDDO
 RETURN .T.
ENDFUNC
*
FUNCTION DispLine
 PARAMETER nlInenumber
 PRIVATE ndLrow
 PRIVATE ndLcol
 PRIVATE nfIeldno
 PRIVATE cdEfcolor, ccOlor, csPeccolor, cdEfstyle, csTyle, cpIcture
 = reSelect(acFields(1,1),M.cuSealias)
 ndLrow = nlInenumber+(0.1875)
 ndLcol = 1/6
 IF (anRecordnumbers(nlInenumber)<>RECNO())
      GOTO anRecordnumbers(nlInenumber)
 ENDIF

  IF ( .NOT. EMPTY(ccAlcfunction))
      do &cCalcFunction in (cSource)
 ENDIF
 IF (nlInenumber==ncUrline .AND. laCtivebar)
      IF (WVISIBLE(M.cwIndowname) .AND.  .NOT. EMPTY(gcButtonfunction))
           Do &gcButtonFunction
      ENDIF
      cdEfcolor = SCHEME(1, 6)
      csPeccolor = SCHEME(1, 6)
      IF  .NOT. EMPTY(ccOlorfunction)
           IF (ccOlorfunction=="LocalColor")
                DO loCalcolor IN (csOurce) WITH csPeccolor, '', .F.
           ELSE
                csPeccolor = rsColor(reServat.rs_status)
           ENDIF
      ENDIF
 ELSE
      cdEfcolor = "RGB(0, 0, 0, 255, 255, 255)"
      csPeccolor = "RGB(0, 0, 0, 255, 255, 255)"
      IF  .NOT. EMPTY(ccOlorfunction)
           IF (ccOlorfunction=="LocalColor")
                DO loCalcolor IN (csOurce) WITH csPeccolor, '', .T.
           ELSE
                csPeccolor = rsColor(reServat.rs_status)
           ENDIF
      ENDIF
 ENDIF
 cdEfstyle = IIF(DELETED(), '-', '')
 FOR nfIeldno = 1 TO nfIeldarraylength
      IF (lhAspicture)
           cpIcture = acFields(nfIeldno,4)
           ccOlor = cdEfcolor
           csTyle = cdEfstyle
           IF cpIcture="B"
                csTyle = cdEfstyle+"B"
                cpIcture = SUBSTR(cpIcture, 2)
           ENDIF
           IF cpIcture="C"
                ccOlor = csPeccolor
                cpIcture = SUBSTR(cpIcture, 2)
           ENDIF
      ELSE
           csTyle = cdEfstyle
           cpIcture = ""
           ccOlor = cdEfcolor
      ENDIF
      ndLcol = ndLcol+IIF(nfIeldno==1, 0, acFields(nfIeldno-1,2)+ ;
               (0.166666666666667))
      IF acFields(nfIeldno,2)>0
           @ ndLrow, ndLcol SAY EVALUATE(acFields(nfIeldno,1)) STYLE  ;
             csTyle SIZE 1, acFields(nfIeldno,2) PICTURE cpIcture COLOR  ;
             (ccOlor)
      ENDIF
 ENDFOR
 RETURN nlInenumber
ENDFUNC
*
FUNCTION DispHeader
 PRIVATE ndHrow
 PRIVATE ndHcol
 PRIVATE nfLdcounter
 ndHrow = 0
 ndHcol = 0
 = diSpbackground()
 FOR nfLdcounter = 1 TO nfIeldarraylength
      IF acFields(nfLdcounter,2)>0
           @ ndHrow+piXv(1), ndHcol+piXh(3) SAY acFields(nfLdcounter,3)  ;
             SIZE 1-piXv(2), acFields(nfLdcounter,2)-piXh(1) PICTURE  ;
             REPLICATE('X', acFields(nfLdcounter,2))
           @ ndHrow, ndHcol TO ndHrow+1+piXv(3), ndHcol+ ;
             acFields(nfLdcounter,2)+piXh(2)
           @ ndHrow+piXv(1), ndHcol+piXh(1) TO ndHrow+piXv(1), ndHcol+ ;
             acFields(nfLdcounter,2)+piXh(1) COLOR RGB(255,255,255)
           @ ndHrow+piXv(1), ndHcol+piXh(1) TO ndHrow+1+piXv(2), ndHcol+ ;
             piXh(1) COLOR RGB(255,255,255)
           ndHcol = ndHcol+acFields(nfLdcounter,2)+piXh(1)
      ENDIF
 ENDFOR
 @ 0, WCOLS()-piXh(18) TO nmAxlines+piXv(20), WCOLS()
 @ piXv(1), WCOLS()-piXh(18) SAY "bitmap\Arrowup.bmp" BITMAP
 @ nmAxlines+piXv(3), WCOLS()-piXh(18) SAY "bitmap\arrowdn.bmp" BITMAP
 @ piXv(17), WCOLS()-piXh(18) SAY "bitmap\thumb.bmp" BITMAP
 RETURN .T.
ENDFUNC
*
PROCEDURE DispBackGround
 PRIVATE i, ndHrow, ndHcol
 ndHrow = 0
 ndHcol = 0
 @ piXv(18), 0 TO nmAxlines+piXv(20), WCOLS()-piXh(17) PATTERN 1 COLOR  ;
   RGB(0,0,0,255,255,255)
 FOR i = 1 TO nfIeldarraylength-1
      @ ndHrow+1+piXv(3), ndHcol+acFields(i,2)+piXh(1) TO nmAxlines+ ;
        piXv(19), ndHcol+acFields(i,2)+piXh(1) COLOR RGB(192,192,192)
      ndHcol = ndHcol+acFields(i,2)+piXh(1)
 ENDFOR
 RETURN
ENDPROC
*
FUNCTION MoveScroll
 PARAMETER nmSmove
 PRIVATE nnExtthumb
 nnExtthumb = ncUrthumb
 DO CASE
      CASE nmSmove==0
           nnExtthumb = piXv(17)
      CASE nmSmove==99
           nnExtthumb = nmAxlines-piXv(13)
      OTHERWISE
           nnExtthumb = MAX(piXv(36), MIN(ncUrthumb+nmSmove*((nmAxlines- ;
                        2)/RECCOUNT()), nmAxlines+piXv(20)))
 ENDCASE
 IF (nnExtthumb<>ncUrthumb)
      @ ncUrthumb, WCOLS()-piXh(18) SAY "bitmap\NoThumb.Bmp" BITMAP
      @ nnExtthumb, WCOLS()-piXh(18) SAY "bitmap\Thumb.Bmp" BITMAP
      ncUrthumb = nnExtthumb
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION Width
 PRIVATE nwIdthcolumn
 PRIVATE lwIdthfield
 nwIdthcolumn = piXh(23)
 FOR lwIdthfield = 1 TO nfIeldarraylength
      nwIdthcolumn = nwIdthcolumn+acFields(lwIdthfield,2)+piXh(1)
 ENDFOR
 RETURN nwIdthcolumn
ENDFUNC
*
FUNCTION Skip
 PARAMETER nsKipstodo
 PRIVATE nsKipped
 PRIVATE nlAstrecord
 = reSelect(acFields(1,1),M.cuSealias)
 nsKipped = 0
 nlAstrecord = RECNO()
 DO WHILE (nsKipped<>nsKipstodo)
      DO CASE
           CASE nsKipstodo>0 .AND.  .NOT. EOF()
                SKIP 1
                If ( (&cWhileClause) And !Eof() )
                     If ( &cForClause )
                          nsKipped = nsKipped+1
                          nlAstrecord = RECNO()
                     ENDIF
                ELSE
                     GOTO nlAstrecord
                     EXIT
                ENDIF
           CASE nsKipstodo<0 .AND.  .NOT. BOF() .AND.  .NOT. EOF()
                SKIP -1
                If ( (&cWhileClause) And !Bof() )
                     If ( &cForClause )
                          nsKipped = nsKipped-1
                          nlAstrecord = RECNO()
                     ENDIF
                ELSE
                     GOTO nlAstrecord
                     EXIT
                ENDIF
           OTHERWISE
                EXIT
      ENDCASE
 ENDDO
 RETURN nsKipped
ENDFUNC
*
FUNCTION ReSelect
 PARAMETER cfIrstfield, cuSealias
 PRIVATE caLias
 PRIVATE cmBmessage
 PRIVATE ccUralias
 IF (AT(".", cfIrstfield)>0 .OR.  .NOT. EMPTY(cuSealias))
      IF EMPTY(cuSealias)
           caLias = LEFT(cfIrstfield, AT(".", cfIrstfield)-1)
      ELSE
           caLias = cuSealias
      ENDIF
      IF (UPPER(caLias)<>UPPER(ALIAS()))
           cmBmessage = "Alias difference, reselecting...."+CHR(13)+ ;
                        CHR(10)+"Current:"+UPPER(ALIAS())+" must be:"+ ;
                        UPPER(caLias)+CHR(13)+CHR(10)+"Window:"+WTITLE()
           ccUralias = ALIAS()
           IF g_debug
                WAIT WINDOW NOWAIT cmBmessage
           ENDIF
           IF (SELECT(caLias)<>0)
                SELECT (caLias)
           ENDIF
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
