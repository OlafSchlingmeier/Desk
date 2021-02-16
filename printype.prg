    do form forms\MngForm with "MngPrGrCodesCtrl"
    return

 PRIVATE cbUttons
 PRIVATE ncUrarea
 PRIVATE acFields
 DIMENSION acFields[2, 4]
 STORE '' TO acFields
 acFields[1, 1] = "PrTypes.Pt_Number"
 acFields[1, 2] = 14
 acFields[1, 3] = GetLangText("PRINTYPE","TXT_NUMBER")
 acFields[1, 4] = '99 '
 acFields[2, 1] = "PrTypes.Pt_Descrip"
 acFields[2, 2] = 60
 acFields[2, 3] = GetLangText("PRINTYPE","TXT_DESCRIPTION")
 ncUrarea = SELECT()
 IF (opEnfile(.F.,"PrTypes"))
      SELECT prTypes
      GOTO TOP
      cbUttons = "\?"+GetLangText("COMMON","TXT_CLOSE")+";"+"\!"+GetLangText("COMMON", ;
                 "TXT_EDIT")+";"+GetLangText("PRINTYPE","TXT_NEW")+";"+ ;
                 GetLangText("COMMON","TXT_SEARCH")+";"+GetLangText("COMMON","TXT_DELETE")
      cpT1button = gcButtonfunction
      gcButtonfunction = ""
      = myBrowse(GetLangText("PRINTYPE","TXT_PRINTTYPECAPTION"),20,@acFields, ;
        ".t.",".t.",cbUttons,"vTypeControl","PRINTYPE")
      gcButtonfunction = cpT1button
      SELECT prTypes
      USE
 ENDIF
 SELECT (ncUrarea)
 RETURN .T.
ENDFUNC
*
FUNCTION vTypeControl
 PARAMETER ncHoice
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           = prCode("EDIT")
           g_Refreshall = UPDATED()
      CASE ncHoice==3
           = prCode("NEW")
           g_Refreshall = .T.
      CASE ncHoice==4
           = prSearch()
           g_Refreshall = .T.
      CASE ncHoice==5
           IF (yeSno(GetLangText("PRINTYPE","TXT_PREDELETE")+" "+ ;
              ALLTRIM(prTypes.pt_descrip)+" "+GetLangText("PRINTYPE", ;
              "TXT_POSTDELETE")+"?"))
                DELETE
           ENDIF
           g_Refreshall = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION PrSearch
 PRIVATE ncOde
 PRIVATE ccOdename
 PRIVATE nrEcord
 ncOde = 0
 ccOdename = SPACE(25)
 nrEcord = RECNO()
 DEFINE WINDOW seArchprcode FROM 0, 0 TO 6, 40 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("PRINTYPE","TXT_PRSEARCH")) NOMDI DOUBLE
 MOVE WINDOW seArchprcode CENTER
 ACTIVATE WINDOW seArchprcode
 = paNel((0.25),(0.666666666666667),WROWS()-(0.25),WCOLS()-(0.666666666666667))
 = txTpanel(1,3,20,GetLangText("PRINTYPE","TXT_PRCODE"),0)
 = txTpanel(2.25,3,20,GetLangText("PRINTYPE","TXT_PRNAME"),0)
 @ 1, 25 GET ncOde SIZE 1, 10 PICTURE "@KB 99"
 @ 2.250, 25 GET ccOdename SIZE 1, 10 PICTURE "@KB" WHEN EMPTY(ncOde)
 READ MODAL
 RELEASE WINDOW seArchprcode
 = chIldtitle("")
 SET NEAR ON
 IF ( .NOT. EMPTY(ncOde))
      SET ORDER TO 1
      SEEK STR(ncOde, 2)
 ELSE
      SET ORDER TO 2
      SEEK ALLTRIM(UPPER(ccOdename))
 ENDIF
 SET ORDER TO 1
 IF (EOF())
      GOTO nrEcord
 ENDIF
 SET NEAR OFF
 RETURN .T.
ENDFUNC
*
FUNCTION PrCode
 PARAMETER coPtion
 PRIVATE ncHoice
 PRIVATE ncOl
 PRIVATE nrOw
 PRIVATE nsElect, cvAr, i
 ncHoice = 1
 DO CASE
      CASE coPtion="NEW"
           SCATTER BLANK MEMVAR
      CASE coPtion="EDIT"
           SCATTER MEMVAR
 ENDCASE
 nsElect = SELECT()
 DEFINE WINDOW wpRcode AT 0, 0 SIZE 8, 60 FONT "Arial", 10 NOGROW NOFLOAT  ;
        NOCLOSE TITLE chIldtitle(GetLangText("PRINTYPE","TXT_EDITCAPTION"))  ;
        NOMDI SYSTEM
 MOVE WINDOW wpRcode CENTER
 ACTIVATE WINDOW wpRcode
 DO paNel WITH 1/4, 2/3, 5, WCOLS()-(0.666666666666667)
 = txTpanel(1,4,23,GetLangText("PRINTYPE","TXT_PRCODE"),0)
 = txTpanel(2.25,4,23,GetLangText("PRINTYPE","TXT_PRNAME"),0)
 @ 1, 25 GET M.pt_number SIZE 1, 6 PICTURE "@KB 99" WHEN (coPtion=="NEW")
 @ 2.250, 25 GET M.pt_descrip SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)  ;
   VALID laNgedit("PT_",GetLangText("PRINTYPE","TXT_EDITCAPTION"))
 @ 3.500, 4 GET M.pt_copytxt FUNCTION "*C"+' '+GetLangText("PRINTYPE","TXT_COPYTEXT")
 nrOw = WROWS()-2
 ncOl = (WCOLS()-0032-1)/2
 @ nrOw, ncOl GET ncHoice STYLE "B" SIZE nbUttonheight, 15 FUNCTION "*"+ ;
   "H" PICTURE "\!"+GetLangText("COMMON","TXT_OK")+";"+"\?"+GetLangText("COMMON", ;
   "TXT_CANCEL") VALID vpRchoice(ncHoice,coPtion)
 READ CYCLE MODAL
 RELEASE WINDOW wpRcode
 = chIldtitle("")
 RETURN .T.
ENDFUNC
*
FUNCTION vPrChoice
 PARAMETER ncHoice, coPtion
 PRIVATE lvAlid, i, cvAr
 lvAlid = .F.
 DO CASE
      CASE ncHoice==1
           FOR i = 1 TO 9
                cvAr = 'm.pt_lang'+STR(i, 1)
                IF EMPTY(EVALUATE(cvAr))
                     &cVar = m.pt_descrip
                ENDIF
           ENDFOR
           DO CASE
                CASE coPtion=="NEW"
                     IF (SEEK(STR(M.pt_number, 2), "PrTypes"))
                          = alErt(GetLangText("PRINTYPE","TXT_CODEISINUSE"))
                     ELSE
                          INSERT INTO PrTypes FROM MEMVAR
                          lvAlid = .T.
                     ENDIF
                CASE coPtion=="EDIT"
                     GATHER MEMVAR
           ENDCASE
           CLEAR READ
      CASE ncHoice==2
           lvAlid = .T.
           CLEAR READ
 ENDCASE
 RETURN lvAlid
ENDFUNC
*
