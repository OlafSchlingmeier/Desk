*
PROCEDURE HelpMe
 PARAMETER p_Search
 SET HELP TO "help\help_"+g_Language+".chm"
 IF (PARAMETERS()==0)
      SET TOPIC TO ""
 ELSE
      SET TOPIC TO "a"
 ENDIF
 HELP IN scReen
 RETURN
ENDPROC
*
PROCEDURE About
 PRIVATE noKaybutton
 PRIVATE nsYstembutton
 DO FORM "forms/about"
 return
 noKaybutton = 0
 nsYstembutton = 0
 = chIldtitle("About")
 DEFINE WINDOW abOut AT 0, 0 SIZE 19, 91 FONT "Arial", 009 NOCLOSE TITLE  ;
        gcApplication+" Front Office"
 MOVE WINDOW abOut CENTER
 ACTIVATE WINDOW abOut
 @ 2.000, 2 SAY "bitmap\About.bmp" BITMAP
 @ 2.000, 25 SAY gcApplication+" Front Office Version "+"7.9x" && ;
  * LTRIM(STR(g_Version, 4, 2))+g_Revision+" Build "+STR(g_Build, 3)+"."
 @ 3.250, 25 SAY gcCopyright
 @ 5.250, 25 say "Citadel ® ist ein eingetragenes Markenzeichen"
 @ 6.250, 25 say "der Schlingmeier + Partner KG, Warendorf"
 @ 8.000, 25 SAY "Dies Produkt ist lizensiert für:"
 DO paNel WITH 9.40, 25, 13, 90
 @ 9.500, 27 SAY ALLTRIM(paRam.pa_hotel)
 @ 10.500, 27 SAY ALLTRIM(paRam.pa_city)
 @ 12.000, 27 SAY "Serien Nummer:"
 @ 12.000, 45 SAY LTRIM(STR(paRam.pa_license))
 DO paNel WITH 14, 1, 14.1, 90
 IF (FILE("\Windows\MsApps\MsInfo\MsInfo"))
      cbUtton = "\<System Info..."
 ELSE
      cbUtton = "\\\<System Info..."
 ENDIF
 @ 15, 72 GET noKaybutton STYLE "B" SIZE nbUttonheight, 15 PICTURE  ;
   "@*N \<OK" VALID vsElect()
 @ 17, 72 GET nsYstembutton STYLE "B" SIZE nbUttonheight, 15 PICTURE  ;
   "@*N \<System Info..." VALID vsElect()
 READ CYCLE
 RELEASE WINDOW abOut
 = chIldtitle("")
 RETURN
ENDPROC
*
FUNCTION vSelect
 IF (nsYstembutton==1 .AND. noKaybutton=0)
      RUN /N3 \Windows\MsApps\MsInfo\MsInfo
 ELSE
      CLEAR READ
 ENDIF
 RETURN .T.
ENDFUNC
*
PROCEDURE System
LOCAL l_oRegistry, lcMSINFO
#INCLUDE common\ffc\dialogs.h
l_oRegistry = CREATEOBJECT("registry")
lnError = l_oRegistry.GetRegKey("Path",@lcMSINFO,KEY_WIN4_MSINFO,HKEY_LOCAL_MACHINE)
IF lnError = 0
	RUN/N1 &lcMSINFO
ELSE
	PRIVATE ALL LIKE l_*
	DEFINE WINDOW syStem FROM 0.000, 0.000 SIZE 10.750, 45.000 FONT "Arial",  ;
	       10 NOCLOSE NOZOOM TITLE chIldtitle("System") NOMDI DOUBLE
	MOVE WINDOW syStem CENTER
	ACTIVATE WINDOW syStem
	DO paNel WITH 1/4, 2/3, 7.75, WCOLS()-(0.666666666666667)
	DO paNel WITH 15/16, 8/3, 33/16, 70/3, 2
	DO paNel WITH 35/16, 8/3, 53/16, 70/3, 2
	DO paNel WITH 55/16, 8/3, 73/16, 70/3, 2
	DO paNel WITH 75/16, 8/3, 93/16, 70/3, 2
	DO paNel WITH 95/16, 8/3, 113/16, 70/3, 2
	@ 15/16, 74/3 TO 33/16, 121/3, 2
	@ 35/16, 74/3 TO 53/16, 121/3, 2
	@ 55/16, 74/3 TO 73/16, 121/3, 2
	@ 75/16, 74/3 TO 93/16, 121/3, 2
	@ 95/16, 74/3 TO 113/16, 121/3, 2
	@ 1.000, 04 SAY "Processor"
	@ 1.000, 25 SAY SYS(17) SIZE 1, 15
	@ 2.250, 04 SAY "Video driver"
	@ 2.250, 25 SAY SYS(2006) SIZE 1, 15
	@ 3.500, 04 SAY "Windows version"
	@ 3.500, 25 SAY OS(1) SIZE 1, 15
	@ 4.750, 04 SAY "Operating system"
	@ 4.750, 25 SAY OS() SIZE 1, 15
	@ 6.000, 04 SAY "Memory"
	@ 6.000, 25 SAY SYS(1001) SIZE 1, 15
	l_Row = WROWS()-2.5
	l_Col = (WCOLS()-15-1)/2
	@ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
	  PICTURE "@* \<OK"
	READ MODAL
	RELEASE WINDOW syStem
	= chIldtitle("")
ENDIF
RETURN .T.
ENDPROC
*
