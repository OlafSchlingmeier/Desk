 PARAMETER cgRoupname, ccAption, cqUestion, chElptext, cpIcture, cvAlid
 PRIVATE cbUttons
 PRIVATE csElectedbutton
 PRIVATE clEvel
 PRIVATE npArameters
 PRIVATE nsIze
 npArameters = PARAMETERS()
 IF (npArameters==1)
      ccAption = GetLangText("GETGROUP","TXT_GROUPNAME")
      cqUestion = GetLangText("GETGROUP","TXT_GROUP")
      chElptext = ""
 ENDIF
 IF (npArameters<5)
      cpIcture = REPLICATE("X", LEN(cgRoupname))
      cvAlid = '!Empty(cGroupName)'
      nsIze = 50
 ELSE
      nsIze = 15
 ENDIF
 nsElectedbutton = 1
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),-1)
 DEFINE WINDOW wgRoupname AT 0, 0 SIZE 5, 80.000 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(ccAption) NOMDI DOUBLE
 MOVE WINDOW wgRoupname CENTER
 ACTIVATE WINDOW wgRoupname
 = paNelborder()
 @ 1, 4 SAY chElptext STYLE "B"
 @ 3,  4 Say cQuestion						 Get cGroupName						 Picture "@K " + cPicture		 Size 1, nSize					 Valid &cValid
 @ 1, 60 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"V" PICTURE cbUttons
 READ CYCLE MODAL
 RELEASE WINDOW wgRoupname
 RETURN cgRoupname
ENDFUNC
*
