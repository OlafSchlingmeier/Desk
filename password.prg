*
FUNCTION SetPassword
 Local NewPass, nOldArea

 nOldArea = SELECT()
 do form "forms\UserPassForm" with cuSerid to NewPass
 IF NOT EMPTY(NewPass)
      sqlupdate("user","us_id = " + sqlcnv(PADR(UPPER(cuSerid),10),.T.),"us_pass = " + sqlcnv(NewPass,.T.))
 ENDIF
 SELECT (nOldArea)
 RETURN .T.
 
 PRIVATE clEvel
 PRIVATE cbUttons
 PRIVATE nsElectedbutton
 PRIVATE cpAss1
 PRIVATE cpAss2
 nsElectedbutton = 1
 cpAss1 = SPACE(10)
 cpAss2 = SPACE(10)
 DEFINE WINDOW wlOgin AT 0, 0 SIZE 6, 80 FONT "Arial", 10 NOGROW NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("USER","TXT_SETPASS")) NOMDI DOUBLE
 MOVE WINDOW wlOgin CENTER
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
 ACTIVATE WINDOW wlOgin
 DO paNel WITH 1/4, 2/3, WROWS()-(0.25), WCOLS()-(0.666666666666667)
 DO paNel WITH 15/16, 17/6, 33/16, 139/6, 2
 DO paNel WITH 35/16, 17/6, 53/16, 139/6, 2
 DO paNel WITH 55/16, 17/6, 73/16, 139/6, 2
 @ 15/16, 74/3 TO 33/16, 121/3
 @ 1.000, 4.000 SAY GetLangText("USER","TXT_USERID")
 @ 2.250, 4.000 SAY GetLangText("USER","TXT_PASSWORD")
 @ 3.500, 4.000 SAY GetLangText("USER","TXT_RETYPE")
 @ 1.000, 25.000 SAY cuSerid
 @ 2.250, 25.000 GET cpAss1 SIZE 1, 15 PICTURE "@K !!!!!!!!!!" WHEN  ;
   faKespace() COLOR ,RGB(192,192,192,192,192,192),,,,RGB(192,192,192,192, ;
   192,192)
 @ 3.500, 25.000 GET cpAss2 SIZE 1, 15 PICTURE "@K !!!!!!!!!!" WHEN  ;
   faKespace() COLOR ,RGB(192,192,192,192,192,192),,,,RGB(192,192,192,192, ;
   192,192)
 @ 1, 60 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"V" PICTURE cbUttons
 PUSH KEY CLEAR
 READ CYCLE OBJECT 1 MODAL
 POP KEY
 cpAss1 = ALLTRIM(cpAss1)
 cpAss2 = ALLTRIM(cpAss2)
 IF (nsElectedbutton==1)
      = vpAssword()
 ENDIF
 RELEASE WINDOW wlOgin
 = chIldtitle("")
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION vPassword
 SELECT usEr
 LOCATE ALL FOR UPPER(ALLTRIM(usEr.us_id))==UPPER(ALLTRIM(cuSerid))
 IF (FOUND())
      IF (cpAss1==cpAss2)
           REPLACE usEr.us_pass WITH SYS(2007, cpAss1)
           = alErt(GetLangText("USER","TXT_NEWPASS"))
      ELSE
           = alErt(GetLangText("USER","TXT_NOPASS"))
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION FakeSpace
 KEYBOARD " "+CHR(19)
 RETURN .T.
ENDFUNC
*
