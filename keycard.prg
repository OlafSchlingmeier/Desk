*
FUNCTION CheckKeyCard
 PARAMETER lcHeckin, ccArdtype, nnUmberofcards, dfRomdate, dtOdate
 PRIVATE clEvel
 PRIVATE cbUttons
 PRIVATE cpButtons
 PRIVATE nsElect
 clEvel = ""
 cpButtons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
             buTton(clEvel,GetLangText("COMMON","TXT_CANCEL"),-2)
 PRIVATE ncArdtype
 PRIVATE ncHoice
 PRIVATE dfRmdate
 PRIVATE dtO_date
 PRIVATE nnEwextra
 PRIVATE crOomnumber
 ncArdtype = AT(ccArdtype, "KC")
 ncHoice = 1
 IF (PARAMETERS()<>5)
      dfRomdate = DATE()
      dtOdate = DATE()+1
 ENDIF
 cbUttons = buTton("",GetLangText("KEYCARD","TXT_KCARD"),1)+buTton("", ;
            GetLangText("KEYCARD","TXT_CCARD"),-2)
 cbUtnewex = buTton("",GetLangText("KEYCARD","TXT_NEW"),1)+buTton("", ;
             GetLangText("KEYCARD","TXT_EXISTING"),-2)
 dfRmdate = dfRomdate
 dtO_date = dtOdate
 nnEwextra = 1
 crOomnumber = "    "
 IF (paRam.pa_askcard)
      = keYcardwindow(0)
      IF ( .NOT. lcHeckin)
           = txTpanel(0.50,2,20,GetLangText("KEYCARD","TXT_ROOMNUMBER"),18)
           = txTpanel(1.75,2,20,GetLangText("KEYCARD","TXT_DATES"),18)
      ENDIF
      = txTpanel(3.00,2,20,GetLangText("KEYCARD","TXT_TYPECARD"),18)
      = txTpanel(4.25,2,20,GetLangText("KEYCARD","TXT_NUMBEROFCARDS"),18)
      IF ( .NOT. lcHeckin)
           = txTpanel(5.50,2,20,GetLangText("KEYCARD","TXT_KIND"),18)
           @ 0.500, 25 GET crOomnumber PICTURE "@K !!!!" VALID  ;
             viSroom(crOomnumber,@dfRmdate,@dtO_date)
           @ 1.750, 25 GET dfRmdate PICTURE "@K " VALID dfRmdate .AND.  ;
             viSdate(dfRmdate)
           @ 1.750, 40 GET dtO_date PICTURE "@K " VALID viSdate(dtO_date, ;
             dfRmdate)
      ENDIF
      @ 3.000, 25 GET ncArdtype FUNCTION "*R"+"H" PICTURE cbUttons
      @ 4.250, 25 GET nnUmberofcards PICTURE "9"
      IF ( .NOT. lcHeckin)
           @ 5.500, 25 GET nnEwextra FUNCTION "*R"+"H" PICTURE cbUtnewex
      ENDIF
      @ 7.500, (WCOLS()/2)-15 GET ncHoice STYLE "B" SIZE nbUttonheight,  ;
        15 FUNCTION "*"+"H" PICTURE cpButtons
      READ MODAL
      ccArdtype = SUBSTR("KC", ncArdtype, 1)
      = keYcardwindow(1)
 ENDIF
 dfRomdate = dfRmdate
 dtOdate = dtO_date
 IF (LASTKEY()==27)
      crOomnumber = "    "
 ENDIF
 RETURN crOomnumber
ENDFUNC
*
FUNCTION KeyCardWindow
 PARAMETER naCtivate
 IF (naCtivate==0)
      DEFINE WINDOW wkEycard AT 00, 00 SIZE 10, 60 FONT "Arial", 10  ;
             NOGROW NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("KEYCARD", ;
             "TXT_KEYCARDCAPTION")) SYSTEM
      MOVE WINDOW wkEycard CENTER
      ACTIVATE WINDOW wkEycard
 ELSE
      DEACTIVATE WINDOW wkEycard
      RELEASE WINDOW wkEycard
      = chIldtitle("")
      lwEredone = .T.
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION ExtraCards
 PRIVATE dfRomdate
 PRIVATE dtOdate
 PRIVATE nsElect
 PRIVATE ccArdtype
 PRIVATE nnUmberofcards
 PRIVATE crOomnumber
 PRIVATE lfOund
 nsElect = SELECT()
 dfRomdate = DATE()
 dtOdate = DATE()+1
 lfOund = .F.
 nnUmberofcards = 1
 ccArdtype = "K"
 crOomnumber = chEckkeycard(.F.,ccArdtype,@nnUmberofcards,@dfRomdate,@dtOdate)
 IF ( .NOT. EMPTY(crOomnumber) .AND. nnUmberofcards>0)
      IF ( .NOT. paRam.pa_keychck)
           SELECT roOm
           SEEK crOomnumber
           IF (FOUND())
                DO ifCcheckascii IN Interfac WITH crOomnumber, "CHECKIN",  ;
                   ccArdtype, nnUmberofcards, .F.
           ELSE
                = msGbox(GetLangText("KEYCARD","TXT_NOTAROOM"),GetLangText("KEYCARD", ;
                  "TXT_MESSAGE"),48)
           ENDIF
      ELSE
           SELECT reServat
           SET ORDER TO 6
           SEEK "1"+ALLTRIM(crOomnumber)
           IF (FOUND())
                DO ifCcheckascii IN Interfac WITH crOomnumber, "CHECKIN",  ;
                   ccArdtype, nnUmberofcards, .F.
           ELSE
                = msGbox(GetLangText("KEYCARD","TXT_NOTCHECKEDIN"), ;
                  GetLangText("KEYCARD","TXT_MESSAGE"),48)
           ENDIF
           SELECT reServat
           SET ORDER TO 1
      ENDIF
 ENDIF
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION vIsRoom
 PARAMETER crOomnumber, dfRmdate, dtO_date
 PRIVATE loKay
 loKay = .T.
 IF (LASTKEY()<>27)
      loKay = SEEK(crOomnumber, "Room")
      IF ( .NOT. loKay)
           crEaderror = GetLangText("KEYCARD","TXT_NOTAROOM")
      ELSE
           IF (paRam.pa_keychck)
                SELECT reServat
                SET ORDER TO 6
                loKay = SEEK("1"+ALLTRIM(crOomnumber), "Reservat")
                SET ORDER TO 1
                IF ( .NOT. loKay)
                     crEaderror = GetLangText("KEYCARD","TXT_NOTCHECKEDIN")
                ELSE
                     dfRmdate = reServat.rs_arrdate
                     dtO_date = reServat.rs_depdate
                     SHOW GETS
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 RETURN loKay
ENDFUNC
*
FUNCTION vIsDate
 PARAMETER ddAte, dfRmdate
 PRIVATE loKay
 PRIVATE dfRomdate
 loKay = .T.
 IF (LASTKEY()<>27)
      loKay =  .NOT. EMPTY(ddAte)
      IF ( .NOT. loKay)
           crEaderror = GetLangText("KEYCARD","TXT_INVALIDDATE")
      ELSE
           IF (PARAMETERS()==2)
                dfRomdate = dfRmdate
                loKay = (ddAte>=dfRomdate)
                IF ( .NOT. loKay)
                     crEaderror = GetLangText("KEYCARD","TXT_RANGEERROR")
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 RETURN loKay
ENDFUNC
*
