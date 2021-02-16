 PARAMETER cmPinwindowname, nmProw, nmPcol, nmPheight, acMpfields,  ;
           cmPforclause, cmPwhileclause, cmPheading
 PRIVATE npArams
 PRIVATE ALL LIKE l_*
 PRIVATE a_Recs
 EXTERNAL ARRAY acMpfields
 npArams = PARAMETERS()
 l_Currline = 1
 l_Currthumb = piXv(16)+piXv(1)
 l_Maxlines = nmPheight
 l_Retval = 0
 l_Ready = .F.
 l_Len = ALEN(acMpfields, 1)
 l_Width = wiDth()
 l_Window = SUBSTR(STRTRAN(cmPinwindowname, " ", ""), 1, 10)
 DIMENSION a_Recs(l_Maxlines)
 STORE -1 TO a_Recs
 if !&cMpWhileClause						
      locate all for ( &cMpForClause .and. &cMpWhileClause )
      IF  .NOT. (FOUND())
           RETURN -1
      ENDIF
 ENDIF
 if !&cMpForClause							
      locate rest for &cMpForClause while &cMpWhileClause
      IF  .NOT. (FOUND())
           RETURN -2
      ENDIF
 ENDIF
 IF (npArams<8)
      DEFINE WINDOW wpOpup AT 0, 0 SIZE l_Maxlines+piXv(4), l_Width+ ;
             piXh(20) FONT "Arial", 10 NOGROW NOFLOAT NOCLOSE TITLE  ;
             "Select" IN (l_Window) NOMDI SYSTEM COLOR RGB(0,0,0,255,255,255)
      MOVE WINDOW wpOpup CENTER
 ELSE
      DEFINE WINDOW wpOpup AT nmProw, nmPcol-0.4 SIZE l_Maxlines+(0.1),  ;
             l_Width+3 FONT "Arial", 10 NOCLOSE TITLE cmPheading IN  ;
             (l_Window) DOUBLE
 ENDIF
 ACTIVATE WINDOW NOSHOW wpOpup
 l_Line = 1
 IF  .NOT. EOF()
      l_Firstrec = RECNO()
      locate rest for &cMpForClause while &cMpWhileClause
      DO WHILE (FOUND() .AND. l_Line<=l_Maxlines)
           a_Recs[l_Line] = RECNO()
           DO mpDispline WITH l_Line
           l_Line = l_Line+1
           CONTINUE
      ENDDO
      GOTO l_Firstrec
 ELSE
      a_Recs[l_Line] = RECNO()
      DO mpDispline WITH l_Line
 ENDIF
 DO diSpscroll
 SHOW WINDOW wpOpup
 DO WHILE  .NOT. (l_Ready)
      l_Key = INKEY(0, "MH")
      DO CASE
           CASE l_Key==5 .OR. l_Key==19 .OR. l_Key==15
                DO moVe WITH -1
           CASE l_Key==24 .OR. l_Key==4 .OR. l_Key==9
                DO moVe WITH 1
           CASE l_Key==18
                DO moVe WITH (-l_Maxlines)
           CASE l_Key==3
                DO moVe WITH (l_Maxlines)
           CASE l_Key==1
                DO moVe WITH (-l_Currline+1)
           CASE l_Key==6
                DO moVe WITH (l_Maxlines-l_Currline)
           CASE l_Key==27
                l_Retval = 0
                EXIT
           CASE l_Key==151
                l_Mouserow = FLOOR(MROW())
                l_Mousecol = FLOOR(MCOL())
                DO CASE
                     CASE (l_Mouserow==0 .AND. l_Mousecol>=l_Width-3)
                          DO moVe WITH -1
                     CASE (l_Mouserow==l_Maxlines-1 .AND. l_Mousecol>= ;
                          l_Width-3)
                          DO moVe WITH 1
                     CASE (l_Mouserow>=0 .AND. l_Mouserow<=l_Maxlines  ;
                          .AND. l_Mousecol>=0 .AND. l_Mousecol<=l_Width-3)
                          l_Limit = SECONDS()+_DBLCLICK
                          DO WHILE SECONDS()<l_Limit
                               l_Nextkey = INKEY("HM")
                               IF l_Nextkey==151
                                    l_Mouserow = l_Mouserow+1
                                    IF a_Recs(l_Mouserow)>0
                                         l_Oldcurr = l_Currline
                                         l_Currline = l_Mouserow
                                         DO mpDispline WITH (l_Oldcurr)
                                         DO mpDispline WITH (l_Currline)
                                         = INKEY(_DBLCLICK, "H")
                                         GOTO a_Recs(l_Mouserow)
                                         RELEASE WINDOW wpOpup
                                         RETURN RECNO()
                                    ENDIF
                               ENDIF
                          ENDDO
                          DO moVe WITH (l_Mouserow-l_Currline)+1
                ENDCASE
           CASE l_Key==13
                GOTO a_Recs(l_Currline)
                l_Retval = RECNO()
                EXIT
      ENDCASE
 ENDDO
 RELEASE WINDOW wpOpup
 RETURN l_Retval
ENDFUNC
*
PROCEDURE Move
 PARAMETER p_Tomove
 PRIVATE l_Moved, l_Var
 DO CASE
      CASE p_Tomove==1
           DO CASE
                CASE (l_Currline<l_Maxlines .AND. a_Recs(l_Currline+1)>0)
                     l_Currline = l_Currline+1
                     DO mpDispline WITH (l_Currline-1)
                     DO mpDispline WITH (l_Currline)
                CASE (skIp(1)==1)
                     SCROLL 1/20, 1/4, M.l_Maxlines-1, M.l_Width-3+1.5, 1
                     = ADEL(a_Recs, 1)
                     a_Recs[M.l_Maxlines] = RECNO()
                     DO mpDispline WITH (l_Currline-1)
                     DO mpDispline WITH (l_Currline)
                     DO moVescroll WITH 1
                OTHERWISE
                     ?? CHR(7)
                     DO moVescroll WITH 99
           ENDCASE
      CASE p_Tomove==-1
           DO CASE
                CASE (l_Currline>1)
                     l_Currline = l_Currline-1
                     DO mpDispline WITH (l_Currline+1)
                     DO mpDispline WITH (l_Currline)
                CASE (skIp(-1)==-1)
                     SCROLL 1/20, 1/4, M.l_Maxlines-1, M.l_Width-3+1.5, -1
                     = AINS(a_Recs, 1)
                     a_Recs[1] = RECNO()
                     DO mpDispline WITH (l_Currline+1)
                     DO mpDispline WITH (l_Currline)
                     DO moVescroll WITH -1
                OTHERWISE
                     ?? CHR(7)
                     DO moVescroll WITH 0
           ENDCASE
      CASE (p_Tomove==l_Maxlines)
           IF a_Recs(l_Maxlines)>0
                GOTO a_Recs(l_Maxlines)
                l_Moved = 0
                DO WHILE (l_Moved<p_Tomove .AND. skIp(1)==1)
                     l_Moved = l_Moved+1
                     = ADEL(a_Recs, 1)
                     a_Recs[l_Maxlines] = RECNO()
                ENDDO
                l_Currline = 1
                SCROLL 1/20, 1/4, M.l_Maxlines-1, M.l_Width-3+1.5, 0
                DO diSpall
                DO moVescroll WITH IIF(l_Moved=0, 99, l_Moved)
           ENDIF
      CASE (p_Tomove==-l_Maxlines)
           GOTO a_Recs(1)
           l_Moved = 0
           DO WHILE (l_Moved<-p_Tomove .AND. skIp(-1)==-1)
                l_Moved = l_Moved+1
                = AINS(a_Recs, 1)
                a_Recs[1] = RECNO()
           ENDDO
           l_Currline = 1
           SCROLL 1/20, 1/4, M.l_Maxlines-1, M.l_Width-3+1.5, 0
           DO diSpall
           DO moVescroll WITH IIF(l_Moved=0, 0, -l_Moved)
      CASE (p_Tomove>1 .AND. l_Currline+p_Tomove<=l_Maxlines .AND.  ;
           a_Recs(l_Currline+p_Tomove)>0)
           l_Currline = l_Currline+p_Tomove
           DO mpDispline WITH (l_Currline-p_Tomove)
           DO mpDispline WITH (l_Currline)
      CASE (p_Tomove<1 .AND. p_Tomove<>0 .AND. l_Currline<=l_Maxlines-p_Tomove)
           l_Currline = l_Currline+p_Tomove
           DO mpDispline WITH (l_Currline-p_Tomove)
           DO mpDispline WITH (l_Currline)
 ENDCASE
 RETURN
ENDPROC
*
PROCEDURE DispAll
 PRIVATE l_Line
 l_Line = 1
 DO WHILE (l_Line<=M.l_Maxlines .AND. a_Recs(l_Line)>0)
      DO mpDispline WITH (l_Line)
      l_Line = l_Line+1
 ENDDO
 RETURN
ENDPROC
*
PROCEDURE MpDispLine
 PARAMETER p_Line
 PRIVATE l_Row, l_Col, l_Field, l_Var
 l_Row = piXv(2)+p_Line-1
 l_Col = piXh(2)
 IF (a_Recs(p_Line)<>RECNO())
      GOTO a_Recs(p_Line)
 ENDIF
 DO CASE
      CASE (p_Line==M.l_Currline)
           FOR l_Field = 1 TO M.l_Len
                l_Col = l_Col+IIF(l_Field==1, 0, acMpfields(l_Field-1,2)+1)
                l_Var = acMpfields(l_Field,1)
                @ l_Row, l_Col SAY EVALUATE(l_Var) SIZE 1,  ;
                  acMpfields(l_Field,2) COLOR (SCHEME(1, 6))
           ENDFOR
      OTHERWISE
           FOR l_Field = 1 TO M.l_Len
                l_Col = l_Col+IIF(l_Field==1, 0, acMpfields(l_Field-1,2)+1)
                l_Var = acMpfields(l_Field,1)
                @ l_Row, l_Col SAY EVALUATE(l_Var) SIZE 1,  ;
                  acMpfields(l_Field,2)
           ENDFOR
 ENDCASE
 RETURN
ENDPROC
*
PROCEDURE DispScroll
 @ 0, 0 TO WROWS(), WCOLS()
 IF nmPheight==l_Maxlines
      @ 0, WCOLS()-piXh(16)-piXh(2) TO WROWS(), WCOLS() PATTERN 1 COLOR  ;
        RGB(0,0,0,192,192,192)
      @ piXv(1), WCOLS()-piXh(16)-piXh(2) SAY "bitmap\Arrowup.bmp" BITMAP
      @ WROWS()-piXv(16)-piXv(2), WCOLS()-piXh(16)-piXh(2) SAY  ;
        "bitmap\arrowdn.bmp" BITMAP
      @ piXv(16)+piXv(1), WCOLS()-piXh(16)-piXh(2) SAY "bitmap\thumb.bmp" BITMAP
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE MoveScroll
 PARAMETER p_Move
 PRIVATE l_Nextthumb
 l_Nextthumb = l_Currthumb
 DO CASE
      CASE p_Move==0
           l_Nextthumb = piXv(16)+piXv(1)
      CASE p_Move==99
           l_Nextthumb = WROWS()-piXv(16)-piXv(16)-piXv(2)
      OTHERWISE
           l_Nextthumb = MAX(piXv(16)+piXv(1), MIN(l_Currthumb+p_Move* ;
                         ((l_Maxlines-2)/RECCOUNT()), WROWS()-piXv(16)- ;
                         piXv(16)-piXv(2)))
 ENDCASE
 IF l_Nextthumb<>l_Currthumb
      @ l_Currthumb, WCOLS()-piXh(18) SAY "bitmap\nothumb.bmp" BITMAP
      @ l_Nextthumb, WCOLS()-piXh(18) SAY "bitmap\thumb.bmp" BITMAP
      l_Currthumb = l_Nextthumb
 ENDIF
 RETURN
ENDPROC
*
FUNCTION Width
 PRIVATE l_Col, l_Field
 l_Col = 0
 FOR l_Field = 1 TO M.l_Len
      l_Col = l_Col+acMpfields(l_Field,2)+1
 ENDFOR
 RETURN l_Col
ENDFUNC
*
FUNCTION Skip
 PARAMETER p_Toskip
 PRIVATE l_Skipped, l_Lastrec
 l_Skipped = 0
 l_Lastrec = RECNO()
 DO WHILE (l_Skipped<>p_Toskip)
      DO CASE
           CASE (p_Toskip>0 .AND.  .NOT. EOF())
                SKIP 1
                if ( &cMpWhileClause .and. !Eof() )					
                     if ( &cMpForClause )
                          l_Skipped = l_Skipped+1
                          l_Lastrec = RECNO()
                     ENDIF
                ELSE
                     GOTO l_Lastrec
                     EXIT
                ENDIF
           CASE (p_Toskip<0 .AND.  .NOT. BOF() .AND.  .NOT. EOF())
                SKIP -1
                if ( &cMpWhileClause .and. !Bof() )    				
                     if ( &cMpForClause )
                          l_Skipped = l_Skipped-1
                          l_Lastrec = RECNO()
                     ENDIF
                ELSE
                     GOTO l_Lastrec
                     EXIT
                ENDIF
           OTHERWISE
                EXIT
      ENDCASE
 ENDDO
 RETURN l_Skipped
ENDFUNC
*
