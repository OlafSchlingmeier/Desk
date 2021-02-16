*
FUNCTION MgrPeriod
   do form "forms\MngForm" with "MngPeriodsCtrl"
   return


 PRIVATE clEvel
 PRIVATE cbUttons
 PRIVATE noLdarea
 PRIVATE acFields
 DIMENSION acFields[3, 4]
 acFields[1, 1] = "Period.Pe_Period"
 acFields[1, 2] = 20
 acFields[1, 3] = GetLangText("MGRPRIOD","T_PERIOD")
 acFields[1, 4] = ""
 acFields[2, 1] = "Period.Pe_FromDat"
 acFields[2, 2] = 20
 acFields[2, 3] = GetLangText("MGRPRIOD","T_FROM")
 acFields[2, 4] = ""
 acFields[3, 1] = "Period.Pe_ToDat"
 acFields[3, 2] = 20
 acFields[3, 3] = GetLangText("MGRPRIOD","T_TO")
 acFields[3, 4] = ""
 clEvel = ""
 cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
            buTton(clEvel,GetLangText("COMMON","TXT_EDIT"),2)+buTton(clEvel, ;
            GetLangText("COMMON","TXT_NEW"),3)+buTton(clEvel,GetLangText("COMMON", ;
            "TXT_DELETE"),-4)
 noLdarea = SELECT()
 = opEnfile(.F.,"Period")
 SELECT peRiod
 SET ORDER TO 1
 = myBrowse(GetLangText("MGRPRIOD","TW_PEBROWSE"),10,@acFields,".t.",".t.", ;
   cbUttons,"vPeControl","MGRPRIOD")
 = chEckall()
 = clOsefile("Period")
 SELECT (noLdarea)
 RETURN .T.
ENDFUNC
*
FUNCTION vPeControl
 PARAMETER ncHoice, cwIndow
 DO CASE
      CASE ncHoice==1
      CASE ncHoice==2
           IF  .NOT. EOF()
                = scRperiod("EDIT")
                g_Refreshall = .T.
           ENDIF
      CASE ncHoice==3
           = scRperiod("NEW")
           g_Refreshall = .T.
      CASE ncHoice==4
           IF peRiod.pe_fromdat>=sySdate()
                IF yeSno(GetLangText("MGRPRIOD","TA_DELETE")+";"+ ;
                   DTOC(peRiod.pe_fromdat)+" "+DTOC(peRiod.pe_todat))
                     DELETE
                ENDIF
           ELSE
                = alErt(GetLangText("MGRPRIOD","TA_PASTPERIOD"))
           ENDIF
 ENDCASE
 RETURN .T.
ENDFUNC
*
PROCEDURE ScrPeriod
 PARAMETER coPtion
 PRIVATE ALL LIKE l_*
 l_Choice = 1
 DO CASE
      CASE coPtion="NEW"
           SCATTER BLANK MEMVAR
      CASE coPtion="EDIT"
           SCATTER MEMVAR
 ENDCASE
 DEFINE WINDOW wpEriod AT 0, 0 SIZE 8, 40 FONT "Arial", 10 NOGROW NOFLOAT  ;
        NOCLOSE TITLE chIldtitle(GetLangText("MGRPRIOD","TW_PEWINDOW")) NOMDI SYSTEM
 MOVE WINDOW wpEriod CENTER
 ACTIVATE WINDOW wpEriod
 l_Level = ""
 l_Buttons = "\!"+buTton(l_Level,GetLangText("COMMON","TXT_OK"),1)+ ;
             buTton(l_Level,GetLangText("COMMON","TXT_CANCEL"),-2)
 = paNelborder()
 = txTpanel(1,4,23,GetLangText("MGRPRIOD","T_PERIOD"),0)
 = txTpanel(2.25,4,23,GetLangText("MGRPRIOD","T_FROM"),0)
 = txTpanel(3.50,4,23,GetLangText("MGRPRIOD","T_TO"),0)
 @ 1, 25 GET M.pe_period SIZE 1, 12 PICTURE "@KB 99" WHEN  ;
   EMPTY(M.pe_fromdat) .OR. M.pe_fromdat>=sySdate()
 @ 2.250, 25 GET M.pe_fromdat SIZE 1, 12 PICTURE "@KD" VALID LASTKEY()=27  ;
   .OR. M.pe_fromdat>=sySdate() WHEN EMPTY(M.pe_fromdat) .OR.  ;
   M.pe_fromdat>=sySdate()
 @ 3.500, 25 GET M.pe_todat SIZE 1, 12 PICTURE "@KD" VALID LASTKEY()=27  ;
   .OR. M.pe_todat>=M.pe_fromdat WHEN EMPTY(M.pe_todat) .OR. M.pe_todat>= ;
   sySdate()
 l_Row = WROWS()-2.5
 l_Col = (WCOLS()-0032-1)/2
 @ l_Row, l_Col GET l_Choice DEFAULT 1 STYLE "B" SIZE nbUttonheight, 15  ;
   PICTURE "@*NH "+l_Buttons VALID vpEchoice(coPtion)
 READ CYCLE MODAL
 RELEASE WINDOW wpEriod
 = chIldtitle("")
 RETURN
ENDPROC
*
FUNCTION vPeChoice
 PARAMETER coPtion
 PRIVATE lrEtval
 lrEtval = .F.
 DO CASE
      CASE M.l_Choice==1
           DO CASE
                CASE coPtion="NEW"
                     IF chEcknew()
                          INSERT INTO Period FROM MEMVAR
                          lrEtval = .T.
                          CLEAR READ
                     ENDIF
                CASE coPtion="EDIT"
                     IF chEckedit()
                          GATHER MEMVAR
                          lrEtval = .T.
                          CLEAR READ
                     ENDIF
           ENDCASE
      CASE M.l_Choice==2
           lrEtval = .T.
           CLEAR READ
 ENDCASE
 RETURN lrEtval
ENDFUNC
*
FUNCTION CheckNew
 PRIVATE nrEc, lrEt
 nrEc = RECNO()
 lrEt = .T.
 LOCATE ALL FOR pe_period=M.pe_period .AND. YEAR(pe_fromdat)=YEAR(M.pe_fromdat)
 IF FOUND()
      = alErt(GetLangText("MGRPRIOD","TA_EXISTPERIOD"))
 ENDIF
 GOTO nrEc
 RETURN lrEt
ENDFUNC
*
FUNCTION CheckEdit
 PRIVATE nrEc, lrEt
 nrEc = RECNO()
 lrEt = .T.
 LOCATE ALL FOR pe_period=M.pe_period .AND. YEAR(pe_fromdat)= ;
        YEAR(M.pe_fromdat) .AND. RECNO()<>nrEc
 IF FOUND()
      = alErt(GetLangText("MGRPRIOD","TA_EXISTPERIOD"))
 ENDIF
 GOTO nrEc
 RETURN lrEt
ENDFUNC
*
FUNCTION CheckAll
 PRIVATE dsTart, deNd, dmAx, lrEt, npRevious, ncUrrent
 dsTart = {}
 deNd = {}
 lrEt = .T.
 GOTO TOP
 DO WHILE  .NOT. EOF()
      deNd = peRiod.pe_todat
      npRevious = peRiod.pe_period
      SKIP 1
      IF  .NOT. EOF()
           dsTart = peRiod.pe_fromdat
           ncUrrent = peRiod.pe_period
           IF dsTart<>deNd+1
                = alErt(GetLangText("MGRPRIOD","TA_NONCONTIN")+";;"+DTOC(deNd)+ ;
                  " -> "+DTOC(dsTart)+";;"+GetLangText("MGRPRIOD","TA_PLEASEFIX"))
                lrEt = .F.
                EXIT
           ENDIF
      ENDIF
 ENDDO
 GOTO TOP
 GOTO BOTTOM
 IF  .NOT. EOF() .AND. YEAR(peRiod.pe_todat)=YEAR(sySdate())
      = alErt(GetLangText("MGRPRIOD","TA_ONENEXTYEAR")+";;"+GetLangText("MGRPRIOD", ;
        "TA_PLEASEFIX"))
      lrEt = .F.
 ENDIF
 GOTO TOP
 RETURN lrEt
ENDFUNC
*
