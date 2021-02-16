 PARAMETER cAlias, cResAlias
 *PRIVATE ni
 LOCAL l_nVoucherNumber, l_lVoucherNumberUnique, l_cLang
 PRIVATE nsElect
 LOCAL LVoAddrid, LParamCall, l_lUsed
 nsElect = SELECT()
 l_nVoucherNumber = 0
 IF PCOUNT() > 1
      cResAlias = IIF(EMPTY(cResAlias) OR VARTYPE(cResAlias) <> "C", "reservat", cResAlias)
 ENDIF
 l_lUsed = USED("voucher")
 IF (opEnfile(.F.,"Voucher",.f.,.t.))
      SELECT (caLias)
      LVoAddrid = ps_addrid
      IF NOT EMPTY(cResAlias)
           DO BillAddrId IN ProcBill WITH ps_window,&cResAlias..rs_rsid,&cResAlias..rs_addrid,LVoAddrid
      ENDIF
      IF ps_units = 1
           SELECT voUcher
           APPEND BLANK
           SELECT (caLias)
           REPLACE voUcher.vo_addrid WITH LVoAddrid&&ps_addrid
           REPLACE voUcher.vo_amount WITH (ps_amount/ps_units)
           REPLACE voUcher.vo_postid WITH ps_postid
           REPLACE voUcher.vo_artinum WITH ps_artinum
           REPLACE voUcher.vo_copy WITH 0
           REPLACE voUcher.vo_created WITH sySdate()
           REPLACE voUcher.vo_date WITH sySdate()
           l_cLang = "arTicle.ar_lang" + g_Langnum
           REPLACE voUcher.vo_descrip WITH &l_cLang
           IF arTicle.ar_voucrev AND DLocate("picklist", "pl_label = 'VATGROUP' AND pl_numcod = " + SqlCnv(arTicle.ar_vat,.T.))
                REPLACE voUcher.vo_vat WITH picklist.pl_numcod
                l_cLang = "picklist.pl_lang" + g_Langnum
                REPLACE voUcher.vo_vatdesc WITH &l_cLang
                REPLACE voUcher.vo_vatval WITH picklist.pl_numval
           ENDIF
           IF NOT param.pa_vounoex
                REPLACE voUcher.vo_expdate WITH exPires(sySdate(),arTicle.ar_expire)
           ENDIF
           DO WHILE NOT l_lVoucherNumberUnique
                l_nVoucherNumber = UniqueNumber()
                IF NOT DbLookUp("voucher","tag3",STR(l_nVoucherNumber,10),"FOUND()")
                     REPLACE voUcher.vo_number WITH l_nVoucherNumber
                     l_lVoucherNumberUnique = .T.
                     IF _screen.oGlobal.lexternalvouchers AND TYPE("_screen.oglobal.oExtVouchersData.nveid")="N"
                          REPLACE voUcher.vo_veid WITH _screen.oglobal.oExtVouchersData.nveid
                     ENDIF
                ENDIF
           ENDDO
           REPLACE voUcher.vo_station WITH wiNpc()
           REPLACE voUcher.vo_time WITH TIME()
           REPLACE voUcher.vo_unused WITH (ps_amount/ps_units)
           REPLACE voUcher.vo_userid WITH ps_userid
           IF NOT EMPTY(ps_note)
                REPLACE voUcher.vo_note WITH ps_note
           ENDIF
           l_nVoucherNumber = voucher.vo_number
      ENDIF
 ENDIF
 IF NOT l_lUsed
      = clOsefile("Voucher")
 ENDIF
 SELECT (nsElect)
 RETURN l_nVoucherNumber
ENDFUNC
*
FUNCTION VoucherAddress
LPARAMETERS lp_nAddrId
 LOCAL l_nSelect, l_cStation, l_lClose

 l_nSelect = SELECT()
 l_lClose = NOT USED("voucher")
 IF openfile(.F.,"voucher",.F.,.T.)
      l_cStation = PADR(WinPC(),12)
      SELECT voUcher
      SET ORDER TO
      IF SEEK(l_cStation,"voucher","tag6")
           REPLACE vo_addrid WITH lp_nAddrId FOR vo_station = l_cStation IN voucher
      ENDIF
      IF l_lClose
           = closefile("voucher")
      ENDIF
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDFUNC
*
FUNCTION PrintTheVoucher
 LOCAL l_nArea, l_cStation, l_nRecno, l_lUsed

 l_nArea = SELECT()
 l_lUsed = USED("voucher")
 IF l_lUsed OR opEnfile(.F.,"Voucher",.f.,.t.)
      l_cStation = PADR(WinPC(),12)
      SELECT voUcher
      SET ORDER TO
      IF SEEK(l_cStation,"voucher","tag6")
           IF YesNo(GetLangText("VOUCHER","TXT_PRINTVOUCHER")+"?")
                l_nRecno = RECNO("post")
                SELECT voucher
                SCAN FOR vo_station = l_cStation
                     IF NOT EMPTY(voUcher.vo_copyp)
                          REPLACE voUcher.vo_copy WITH voUcher.vo_copyp
                          REPLACE voUcher.vo_copyp WITH 0
                     ENDIF
                     PrintVoucher(ALLTRIM(UPPER(DLookUp("article", "ar_artinum = voucher.vo_artinum", "ar_layout"))))
                     SELECT voUcher
                     REPLACE voUcher.vo_copy WITH voUcher.vo_copy+1
                     IF NOT EMPTY(voUcher.vo_postid)
                          REPLACE ps_vouccpy WITH voUcher.vo_copy FOR ps_postid = voUcher.vo_postid IN post
                     ENDIF
                ENDSCAN
                GO l_nRecno IN post
           ENDIF
           BLANK FIELDS vo_station FOR vo_station = l_cStation IN Voucher
      ENDIF
      IF NOT l_lUsed
           = clOsefile("Voucher")
      ENDIF
 ENDIF
 SELECT (l_nArea)
 RETURN .T.
ENDFUNC
*
PROCEDURE PrintVoucher
 PARAMETER cvOucherlayout
 PRIVATE ni
 LOCAL LStoreListsOrder, l_nAddressRecNo
 LOCAL l_cDocFile, l_cCsvFile, l_cOldErrorHandler, l_lStart, l_cActiveDocName, l_oWord, l_cDotFileName, l_cOutputFile, l_cDocDescription
 LStoreListsOrder = ""
 LStoreListsOrder = ORDER('Lists')
 SELECT liSts
 FOR ni = 1+11 TO 9+11
      SET ORDER TO nI
      IF (SEEK("14"+cvOucherlayout))
           EXIT
      ENDIF
 ENDFOR
 IF !EMPTY(LStoreListsOrder)
      SET ORDER TO &LStoreListsOrder IN LISTS
ENDIF
 IF ( .NOT. FOUND())
      = alErt(cvOucherlayout,"FILE NOT FOUND")
 ELSE
      l_nAddressRecNo = RECNO("address")
      DO CASE
      CASE lists.li_output = 4
          l_cCsvFile = SYS(2023)+"\BFWMERGE.TXT"
          DO CASE
               CASE lists.li_ddelink = 2
                    l_cDocFile = FULLPATH(gcTemplatedir+ALLTRIM(lists.li_dotfile)+".doc")
                    l_cDotFileName = JUSTFNAME(l_cDocFile)
                    IF FILE(l_cDocFile)
                         IF GenerateData(l_cCsvFile)
                              l_cOldErrorHandler = ON('error')
                              RELEASE g_WordTest
                              PUBLIC g_WordTest
                              ON ERROR DO localoleerror IN localoleerror
                              l_oWord = NULL
                              g_WordTest = .T.
                              l_oWord = GETOBJECT(,"WORD.APPLICATION")
                              g_WordTest = .F.
                              IF ISNULL(l_oWord)
                                   l_oWord = CREATEOBJECT("WORD.APPLICATION")
                                   IF ISNULL(l_oWord)
                                       Alert("Install Word Application")
                                   ELSE
                                       l_oWord.displayalerts = 0
                                   ENDIF
                              ELSE
                                   l_lStart = .T.
                                   l_oWord.displayalerts = 0
                              ENDIF
                              IF NOT ISNULL(l_oWord)
                                   l_oWord.Documents.Open([&l_cDocFile])
                                   l_oWord.ActiveDocument.MailMerge.OpenDataSource([&l_cCsvFile])
                                   l_oWord.ActiveDocument.MailMerge.Execute()
                                   IF NOT EMPTY(voucher.vo_addrid)
                                        l_cOutputFile = FULLPATH(gcDocumentdir + UPPER(JUSTSTEM(l_cDocFile)+PADL(NextId("DOCUMENT"),8,"0")+".doc"))
                                        l_oWord.ActiveDocument.SaveAs([&l_cOutputFile])
                                        l_cDocDescription = GetLangText("MGRFINAN","TXT_VOUCHER") + " " + PADL(voucher.vo_number,10,"0") + PADL(EVL(voucher.vo_copyp, voucher.vo_copy) + 1,2,"0")
                                        DO SaveInDocuments IN MyLists WITH l_cOutputFile, l_cDocDescription, voucher.vo_addrid
                                   ENDIF
                                   l_cActiveDocName = l_oWord.ActiveDocument.Name
                                   l_oWord.Documents([&l_cDotFileName]).Close
                                   IF l_lStart
                                       l_oWord.Visible=.T.
                                       l_oWord.Activate()
                                       l_oWord.Documents(l_cActiveDocName).Activate
                                       *l_oWord.WindowState = 2
                                       *l_oWord.WindowState = 1
                                   ELSE
                                       l_oWord.Visible=.T.
                                   ENDIF
                              ENDIF
                              ON ERROR &l_cOldErrorHandler
                              RELEASE g_WordTest
                              DELETE FILE (l_cCsvFile)
                         ELSE
                              = alert("Can't create merge text file in TEMP folder!")
                         ENDIF
                    ELSE
                         = alert("Can't find file " + l_cDocFile)
                    ENDIF
               CASE lists.li_ddelink = 4
                    l_cDotFileName = FULLPATH(gcTemplatedir+ALLTRIM(lists.li_dotfile)+".ott")
                    IF FILE(l_cDotFileName)
                         IF GenerateData(l_cCsvFile)
                              IF EMPTY(voucher.vo_addrid)
                                   l_cOutputFile = FULLPATH(SYS(2023) + "\Voucher" + SYS(2015) + ".odt")
                              ELSE
                                   l_cOutputFile = FULLPATH(gcDocumentdir + UPPER(JUSTSTEM(l_cDotFileName)+PADL(NextId("DOCUMENT"),8,"0")+".odt"))
                              ENDIF
                              l_oMailMergeObj = NEWOBJECT("OpenOfficeMailMerge", "cit_system", "", l_cCsvFile, l_cDotFileName)
                              IF l_oMailMergeObj.Execute(l_cOutputFile)
                                   * Must be released because l_oOpenOfficeDesktop object than create his own 
                                   * instance of OpenOffice.org ServiceManager.
                                   RELEASE l_oMailMergeObj
                                   l_oOpenOfficeDesktop = NEWOBJECT("AutoOpenOffice", "cit_system")
                                   IF l_oOpenOfficeDesktop.OpenDocument(l_cOutputFile)
                                        IF NOT EMPTY(voucher.vo_addrid)
                                             l_cDocDescription = GetLangText("MGRFINAN","TXT_VOUCHER") + " " + PADL(voucher.vo_number,10,"0") + PADL(EVL(voucher.vo_copyp, voucher.vo_copy) + 1,2,"0")
                                             DO SaveInDocuments IN MyLists WITH l_cOutputFile, l_cDocDescription, voucher.vo_addrid
                                        ENDIF
                                   ELSE
                                        Alert(GetLangText("EMBROWS","TXT_OPERATION_UNSUCCESSFULL"))
                                   ENDIF
                              ELSE
                                   Alert(GetLangText("EMBROWS","TXT_OPERATION_UNSUCCESSFULL"))
                              ENDIF
                              DELETE FILE (l_cCsvFile)
                         ELSE
                              Alert("Can't create merge text file in TEMP folder!")
                         ENDIF
                    ELSE
                         Alert("Can't find file " + JUSTFNAME(l_cDotFileName))
                    ENDIF
               OTHERWISE
          ENDCASE
      OTHERWISE && lists.li_output = 1
           ctMpfrx = ''
           ctMpfrt = ''
           crEportname = ALLTRIM(liSts.li_frx)
           IF (chEcklayout(crEportname,@ctMpfrx,@ctMpfrt))
                SELECT arTicle
                = SEEK(voUcher.vo_artinum)
                SELECT adDress
                = SEEK(voUcher.vo_addrid)
                SELECT voUcher
                IF (g_Demo)
                     REPORT FORM (ctMpfrx) HEADING REPLICATE(gcApplication+ ;
                            " DEMO VERSION... ", 3) TO PRINTER NOCONSOLE NEXT 1
                     DO seTstatus IN Setup
                ELSE
                     REPORT FORM (ctMpfrx) TO PRINTER NOCONSOLE NEXT 1
                     DO seTstatus IN Setup
                ENDIF
           ENDIF
           = fiLedelete(ctMpfrx)
           = fiLedelete(ctMpfrt)
      ENDCASE
      GOTO l_nAddressRecNo IN address
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE GenerateData
LPARAMETERS lp_cCsvFile
*= SEEK(voucher.vo_artinum, "article", "tag1"))
 = SEEK(voucher.vo_addrid, "address", "tag1")
 CREATE CURSOR cdocdata (c_x C(1), c_name c(70), c_unused c(20), c_number c(12), c_hotel c(72), c_vatdesc c(25), c_vatval c(6), c_note m)
 INSERT INTO cdocdata (c_x, ;
                      c_name, ;
                      c_unused, ;
                      c_number, ;
                      c_hotel, ;
                      c_vatdesc, ;
                      c_vatval, ;
                      c_note) ;
              VALUES ("æ", ;
                      GuestName("Address"), ;
                      STR(voucher.vo_unused, 20, 2), ;
                      LTRIM(STR(voucher.vo_number)) + ;
                      StrZero(IIF(EMPTY(voucher.vo_copyp), voucher.vo_copy + 1, ;
                      voucher.vo_copyp + 1),2), ;
                      g_hotel, ;
                      voucher.vo_vatdesc, ;
                      TRANSFORM(voucher.vo_vatval,"99.99%"), ;
                      voucher.vo_note)
 RETURN FileCSV("cdocdata", lp_cCsvFile, .T.)
ENDPROC
*
FUNCTION Expires
 PARAMETER ddAte, nvAlue
 PRIVATE deXpdate
 PRIVATE ni
 deXpdate = ddAte
 IF (paRam.pa_vouexpm)
      FOR ni = 1 TO nvAlue
           deXpdate = adDonemonth(deXpdate)
      ENDFOR
 ELSE
      deXpdate = ddAte+nvAlue
 ENDIF
 RETURN deXpdate
ENDFUNC
*
FUNCTION VoucherV
 PARAMETER lfLag, nvOunumber, naMount
 PRIVATE ceRrortext
 PRIVATE nsElect
 PRIVATE cvOuchernumber
 IF naMount<=0
      RETURN .F.
 ENDIF
 ceRrortext = ""
 lfLag = .F.
 nsElect = SELECT()
 IF (opEnfile(.F.,"Voucher",.f.,.t.))
      SELECT voUcher
      SET ORDER TO 3
      cvOuchernumber = SPACE(12)
      cvOuchernumber = geTgroup(cvOuchernumber,GetLangText("VOUCHER", ;
                       "TXT_VCAPTION"),GetLangText("VOUCHER","TXT_VQUESTION"), ;
                       GetLangText("VOUCHER","TXT_VHELP"),"999999999999",".t.")
      IF ( .NOT. SEEK(STR(INT(VAL(cvOuchernumber)/100), 10)))
           ceRrortext = GetLangText("VOUCHER","TXT_UNKNOWN")
      ELSE
           IF (VAL(RIGHT(STR(VAL(cvOuchernumber), 12), 2))<>voUcher.vo_copy)
                ceRrortext = GetLangText("VOUCHER","TXT_SEQUENCE_ERROR")
           ELSE
                IF (voUcher.vo_expdate<=sySdate()) AND NOT param.pa_vounoex
                     ceRrortext = GetLangText("VOUCHER","TXT_EXPIRED")
                ELSE
                     DO CASE
                          CASE voUcher.vo_unused==0
                               ceRrortext = GetLangText("VOUCHER", ;
                                "TXT_AMOUNT_IS_ZERO")
                               naMount = 0
                          CASE voUcher.vo_unused>=naMount
                               REPLACE voUcher.vo_unused WITH  ;
                                       voUcher.vo_unused-naMount
                               REPLACE voUcher.vo_station WITH wiNpc()
                               REPLACE voUcher.vo_copyp WITH voUcher.vo_copy
                               REPLACE voUcher.vo_copy WITH 0
                          OTHERWISE
                               naMount = voUcher.vo_unused
                               REPLACE voUcher.vo_unused WITH 0
                     ENDCASE
                     nvOunumber = VAL(cvOuchernumber)
                     lfLag = .T.
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 IF ( .NOT. EMPTY(ceRrortext))
      = alErt(ceRrortext,GetLangText("VOUCHER","TXT_VOUCHER"))
      lfLag = .F.
 ENDIF
 = clOsefile("Voucher")
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
FUNCTION BrwVoucher
***************************************
IF NOT EMPTY(g_lBillMode)
     DO FORM "forms\vouchers"
     RETURN .T.
ENDIF
***************************************
 PRIVATE cbUttons
 PRIVATE nsElectedbutton
 PRIVATE clEvel
 PRIVATE acFields
 PRIVATE nsElect
 PRIVATE cvObutton
 PRIVATE prDexpdate
 PRIVATE prCdescription
 PRIVATE prNvoucnumber
 PRIVATE prDpurchdate
 PRIVATE prNminunused
 PRIVATE prLunprinted
 DIMENSION acFields[7, 4]
 nsElectedbutton = 1
 LOCAL LSelectedTable
 LSelectedTable = ALIAS()
 IF (opEnfile(.F.,"Voucher",.f.,.t.))
      SELECT voUcher
      SET RELATION TO voUcher.vo_addrid INTO adDress
      prDexpdate = {}
      prCdescription = SPACE(20)
      prNvoucnumber = 0
      prDpurchdate = {}
      prNminunused = 0
      prLunprinted = .F.
      acFields[1, 1] = "Voucher.Vo_ExpDate"
      acFields[1, 2] = siZedate()+piXh(4)
      acFields[1, 3] = GetLangText("VOUCHER","TXT_EXPDATE")
      acFields[1, 4] = ""
      acFields[2, 1] = "Voucher.Vo_Created"
      acFields[2, 2] = siZedate()+piXh(4)
      acFields[2, 3] = GetLangText("VOUCHER","TXT_PURCHDATE")
      acFields[2, 4] = ""
      acFields[3, 1] = "Vo_Descrip"
      acFields[3, 2] = 20
      acFields[3, 3] = GetLangText("VOUCHER","TXT_DESCRIPTION")
      acFields[3, 4] = ""
      acFields[4, 1] = "Vo_Amount"
      acFields[4, 2] = 10
      acFields[4, 3] = GetLangText("VOUCHER","TXT_AMNT")
      acFields[4, 4] = "@J"
      acFields[5, 1] = "Vo_UnUsed"
      acFields[5, 2] = 10
      acFields[5, 3] = GetLangText("VOUCHER","TXT_UNUSED")
      acFields[5, 4] = "@J"
      acFields[6, 1] = "Str(Vo_Number, 10) + StrZero(Vo_Copy, 2)"
      acFields[6, 2] = 15
      acFields[6, 3] = GetLangText("VOUCHER","TXT_VONUMBER")
      acFields[6, 4] = ""
      acFields[7, 1] = "Address.Ad_lName"
      acFields[7, 2] = 20
      acFields[7, 3] = GetLangText("VOUCHER","TXT_NAME")
      acFields[7, 4] = ""
      nsElect = SELECT()
      clEvel = ""
      cbUttons = "\?"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),1)+"\!"+ ;
                 buTton(clEvel,GetLangText("COMMON","TXT_SEARCH"),-2)
      cvObutton = gcButtonfunction
      gcButtonfunction = ""
      SELECT voUcher
      GOTO TOP
      = myBrowse(GetLangText("VOUCHER","TXT_BRW_VOUCHER"),15,@acFields,".t.", ;
        ".t.",cbUttons,"vVoControl","VOUCHER")
      gcButtonfunction = cvObutton
      = clOsefile("Voucher")
      SELECT (nsElect)
 ENDIF
 SELECT &LSelectedTable
 RETURN .T.
ENDFUNC
*
FUNCTION vVoControl
 PARAMETER nvOchoice
 DO CASE
      CASE nvOchoice==1
      CASE nvOchoice==2
           = voSearch()
           g_Refreshall = .T.
 ENDCASE
 RETURN .T.
ENDFUNC
*
FUNCTION VoSearch
 PRIVATE cbUttons
 PRIVATE nrEcord
 nrEcord = RECNO()
 prDexpdate = {}
 prCdescription = SPACE(20)
 prNvoucnumber = 0
 prDpurchdate = {}
 prNminunused = 0
 prLunprinted = .F.
 _prN = ""
 DEFINE WINDOW wsRcvoucher AT 0, 0 SIZE 10, 80 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("VOUCHER","TXT_VOSEARCH")) NOMDI DOUBLE
 MOVE WINDOW wsRcvoucher CENTER
 ACTIVATE WINDOW wsRcvoucher
 = paNelborder()
 cbUttons = "\!"+buTton("",GetLangText("COMMON","TXT_OK"),1)+"\?"+buTton("", ;
            GetLangText("COMMON","TXT_CANCEL"),-2)
 = txTpanel(1,3,23,GetLangText("VOUCHER","TXT_EXPDATE"),20)
 = txTpanel(2.25,3,23,GetLangText("VOUCHER","TXT_DESCRIPTION"),20)
 = txTpanel(3.5,3,23,GetLangText("VOUCHER","TXT_VONUMBER"),20)
 = txTpanel(4.75,3,23,GetLangText("VOUCHER","TXT_PURCHDATE"),20)
 = txTpanel(6,3,23,GetLangText("VOUCHER","TXT_MINUNUSED"),20)
 = txTpanel(7.25,3,53,"",50)
 @ 1, 25 GET prDexpdate SIZE 1, siZedate() PICTURE "@D"
 @ 2.250, 25 GET prCdescription SIZE 1, 30 PICTURE "@K "+REPLICATE("!", 25)
 @ 3.500, 25 GET _prN SIZE 1, 20 PICTURE "@K "+REPLICATE("9", 12)
 @ 4.750, 25 GET prDpurchdate SIZE 1, siZedate() PICTURE "@D "
 @ 6, 25 GET prNminunused SIZE 1, 10 PICTURE "@K "+gcCurrcy
 @ 7.250, 4 GET prLunprinted FUNCTION "*C" PICTURE GetLangText("VOUCHER", ;
   "TXT_UNPRINTED")
 @ 1, 60 GET nsElectedbutton STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*"+"V" PICTURE cbUttons
 PUSH KEY CLEAR
 READ MODAL
 POP KEY
 RELEASE WINDOW wsRcvoucher
 = chIldtitle("")
 IF (LASTKEY()<>27 .AND. nsElectedbutton==1)
      prNvoucnumber = VAL(_prN)
      DO CASE
           CASE  .NOT. EMPTY(prDexpdate)
                DO CASE
                     CASE  .NOT. EMPTY(prCdescription)
                     OTHERWISE
                          SET ORDER TO 5
                          SEEK DTOS(prDexpdate)
                ENDCASE
           CASE  .NOT. EMPTY(prDpurchdate)
                DO CASE
                     CASE  .NOT. EMPTY(prCdescription)
                     OTHERWISE
                          SET ORDER TO 9
                          SEEK DTOS(prDpurchdate)
                ENDCASE
           CASE  .NOT. EMPTY(prCdescription)
                SET ORDER TO 8
                SEEK UPPER(ALLTRIM(prCdescription))
           CASE  .NOT. EMPTY(prNvoucnumber)
                SET ORDER TO 3
                SEEK STR(INT(prNvoucnumber/100), 10)+ ;
                     STR(VAL(RIGHT(STR(prNvoucnumber, 12, 0), 2)), 2)
      ENDCASE
      IF ( .NOT. FOUND())
           = alErt(GetLangText("VOUCHER","TXT_NOTFOUND"),GetLangText("VOUCHER", ;
             "TXT_VOSEARCH"))
           GOTO nrEcord
      ENDIF
      DO CASE
           CASE  .NOT. EMPTY(prNminunused)
                SET FILTER TO STR(voUcher.vo_unused, 12, 2)>=STR(prNminunused, 12, 2)
           CASE  .NOT. EMPTY(prLunprinted)
                SET FILTER TO voUcher.vo_copy==0
           OTHERWISE
                SET FILTER TO
      ENDCASE
 ENDIF
 RETURN .T.
ENDFUNC
*
