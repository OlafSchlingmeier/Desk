LPARAMETERS lp_dFrom, lp_dTo, lp_cExportPath, lp_lShowDialog
LOCAL ogdpu, lsuccess, nRow

IF EMPTY(lp_dFrom)
     lp_dFrom = sysdate()-1
ENDIF
IF EMPTY(lp_dTo)
     lp_dTo = sysdate()-1
ENDIF
IF EMPTY(lp_cExportPath)
     lp_cExportPath = ADDBS(GetMyDocumentsFolderPath())+"citadel_gdpdu_export\"+DTOS(DATE())+"\"
ENDIF

IF lp_lShowDialog
     LOCAL ARRAY aDlg(1, 13)
     nRow = 1
     aDlg(nRow, 1) = "txtDateFrom"
     aDlg(nRow, 2) = "From"
     aDlg(nRow, 3) = sqlcnv(lp_dFrom)
     aDlg(nRow, 5) = 20
     aDlg(nrow, 6) = 'NOT Empty(ThisForm.txtDateFrom.Value) AND ThisForm.txtDateFrom.Value <= SysDate()-1 AND ThisForm.txtDateFrom.Value <= ThisForm.txtDateTo.Value'
     nRow = AAdd(@aDlg)
     aDlg(nRow, 1) = "txtDateTo"
     aDlg(nRow, 2) = "To"
     aDlg(nRow, 3) = sqlcnv(lp_dTo)
     aDlg(nRow, 5) = 20
     aDlg(nrow, 6) = 'NOT Empty(ThisForm.txtDateTo.Value) AND ThisForm.txtDateTo.Value <= SysDate()-1 AND ThisForm.txtDateFrom.Value <= ThisForm.txtDateTo.Value'
     nRow = AAdd(@aDlg)
     aDlg(nRow, 1) = "txtPath"
     aDlg(nRow, 2) = "Export to folder"
     aDlg(nRow, 3) = sqlcnv(lp_cExportPath)
     aDlg(nRow, 5) = 60
     aDlg(nrow, 6) = 'NOT Empty(ThisForm.txtPath.Value)'
     IF Dialog(GetLangText("MENU","FIN_GDPDU",,.T.),,@aDlg)
          IF NOT EMPTY(aDlg(1, 8))
               lp_dFrom = aDlg(1, 8)
          ENDIF
          IF NOT EMPTY(aDlg(2, 8))
               lp_dTo = aDlg(2, 8)
          ENDIF
          IF NOT EMPTY(aDlg(3, 8))
               lp_cExportPath = ADDBS(aDlg(3, 8))
          ENDIF
     ELSE
          RETURN .F.
     ENDIF
ENDIF

IF openfile(,"article")
     ogdpu = CREATEOBJECT("cgdpu")
     WAIT WINDOW NOWAIT GetLangText("COMMON","T_PLEASEWAIT")
     lsuccess = ogdpu.Start(lp_dFrom, lp_dTo, lp_cExportPath)
     WAIT CLEAR
ENDIF

IF lsuccess
     FNOpenWindowsExplorer(lp_cExportPath)
ENDIF

RETURN lsuccess
*
FUNCTION GetMyDocumentsFolderPath
DECLARE INTEGER SHGetSpecialFolderPath IN shell32 INTEGER, STRING @, INTEGER, INTEGER
LOCAL cDir, iRetval

cDir = SPACE(256)
iRetval = SHGetSpecialFolderPath(0, @cdir, 0x0005, 1)
IF iRetval = 1
     *- function succeeded
     cDir = STRTRAN(cdir,CHR(0),'')
ENDIF
CLEAR DLLS SHGetSpecialFolderPath

RETURN ALLTRIM(cDir)
ENDFUNC
*
PROCEDURE FNOpenWindowsExplorer
LPARAMETERS lp_cDir
LOCAL loshell AS Shell32.application

IF EMPTY(lp_cDir)
     lp_cDir = FULLPATH(CURDIR())
ENDIF
loshell = CREATEOBJECT('shell.application')
loShell.Explore(lp_cDir)
loShell = .NULL.

RETURN .T.
ENDPROC
*
DEFINE CLASS cgdpu AS Custom
*
dFrom = {}
dTo = {}
cExportPath = ""
cPoint = ""
*
PROCEDURE Init
this.cPoint = SET("Point")
SET POINT TO ","
RETURN .T.
ENDPROC
*
PROCEDURE Destroy
SET POINT TO (this.cPoint)
RETURN .T.
ENDPROC
*
PROCEDURE Start
LPARAMETERS lp_dFrom, lp_dTo, lp_cExportPath
this.dFrom = lp_dFrom
this.dTo = lp_dTo
this.cExportPath = ADDBS(lp_cExportPath)
IF DIRECTORY(this.cExportPath)
     DELETE FILE (this.cExportPath+"*.*")
ELSE
     MKDIR (this.cExportPath)
ENDIF
this.getpayments()
this.getbookings()
this.getbills()
this.getstatictables()
this.CreateDTD()
this.CreateXML()
RETURN .T.
ENDPROC
*
PROCEDURE getpayments
LOCAL lcSql, lcurName, min1, max1

min1 = this.dFrom
max1 = this.dTo

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT hp_postid, STR(hp_reserid,12,3)+STR(hp_window,10) AS hp_billid, hp_billnum, hp_paynum, CAST(DTOS(hp_date) AS C(8)) AS hp_date,
               CAST(hp_amount AS N(12,2)) AS hp_amount, hp_cancel, hp_descrip, hp_userid, hp_cashier, hp_supplem
               FROM histpost
               WHERE hp_date BETWEEN <<sqlcnv(min1)>> AND <<sqlcnv(max1)>> AND hp_paynum > 0 AND hp_reserid > 0 AND (EMPTY(hp_ratecod) OR hp_split)
               ORDER BY hp_date, hp_paynum, hp_postid
ENDTEXT
lcurName = sqlcursor(lcSql,,,,,,,.T.)
REPLACE hp_descrip WITH STRTRAN(hp_descrip, ";"," ") FOR ";" $ hp_descrip
REPLACE hp_supplem WITH STRTRAN(hp_supplem, ";"," ") FOR ";" $ hp_supplem
COPY TO (this.cExportPath+"payments.csv") DELIMITED WITH CHARACTER ";"
DClose(lcurName)

RETURN .T.
ENDPROC
*
PROCEDURE getbookings
LOCAL lcSql, lcurName, min1, max1

min1 = this.dFrom
max1 = this.dTo

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT hp_postid, STR(hp_reserid,12,3)+STR(hp_window,10) AS hp_billid, hp_artinum, CAST(DTOS(hp_date) AS C(8)) AS hp_date, hp_cancel, hp_descrip, hp_supplem, hp_userid,
               CAST(hp_amount AS N(12,2)) AS hp_amount, CAST(hp_price AS N(12,2)) AS hp_price, CAST(hp_units AS N(12,2)) AS hp_units,
               CAST(hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9 AS N(14,4)) AS hp_vat
               FROM histpost
               WHERE hp_date BETWEEN <<sqlcnv(min1)>> AND <<sqlcnv(max1)>> AND hp_artinum > 0 AND hp_reserid > 0 AND (EMPTY(hp_ratecod) OR hp_split)
               ORDER BY hp_date, hp_postid
ENDTEXT
lcurName = sqlcursor(lcSql,,,,,,,.T.)
REPLACE hp_descrip WITH STRTRAN(hp_descrip, ";"," ") FOR ";" $ hp_descrip
REPLACE hp_supplem WITH STRTRAN(hp_supplem, ";"," ") FOR ";" $ hp_supplem
COPY TO (this.cExportPath+"bookings.csv") DELIMITED WITH CHARACTER ";"
DClose(lcurName)

RETURN .T.
ENDPROC
*
PROCEDURE getbills
LOCAL lcSql, lcurName, min1, max1

min1 = this.dFrom
max1 = this.dTo

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT bn_billnum, STR(bn_reserid,12,3)+STR(bn_window,10) AS bn_billid, CAST(DTOS(bn_date) AS C(8)) AS bn_date, CAST(DTOS(bn_cxldate) AS C(8)) AS bn_cxldate,
               CAST(bn_amount AS N(12,2)) AS bn_amount, bn_paynum, bn_status, bn_userid, ad_company AS bn_company, ad_departm AS bn_departm
               FROM billnum
               LEFT JOIN address ON bn_addrid = ad_addrid
               WHERE bn_date BETWEEN <<sqlcnv(min1)>> AND <<sqlcnv(max1)>>
               GROUP BY 1,3,4,7
               ORDER BY 3,1
ENDTEXT
lcurBillnum = sqlcursor(lcSql,,,,,,,.T.)
REPLACE bn_company WITH STRTRAN(bn_company, ";"," ") FOR ";" $ bn_company
REPLACE bn_departm WITH STRTRAN(bn_departm, ";"," ") FOR ";" $ bn_departm
COPY TO (this.cExportPath+"billnum.csv") DELIMITED WITH CHARACTER ";"
DClose(lcurName)

RETURN .T.
ENDPROC
*
PROCEDURE getstatictables
LOCAL lcSql, lcurName

* article
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT ar_artinum, ar_lang<<g_langnum>> AS ar_descr, ar_artityp, ar_vat, ar_main, ar_sub,
               CAST(ar_price AS Numeric(12,2)) AS ar_price, CAST(ar_inactiv AS Char(1)) AS ar_inactiv
               FROM article
               ORDER BY 1
ENDTEXT
lcurName = sqlcursor(lcSql,,,,,,,.T.)
REPLACE ar_descr WITH STRTRAN(ar_descr, ";"," ") FOR ";" $ ar_descr
COPY TO (this.cExportPath+"article.csv") DELIMITED WITH CHARACTER ";"

* artitype
CREATE CURSOR carttyp1e (at_artityp N(1), at_descr C(50))
INSERT INTO carttyp1e VALUES (1, GetLangText("MGRFINAN","TXT_STANDARD",,.T.))
INSERT INTO carttyp1e VALUES (2, GetLangText("MGRFINAN","TXT_PAIDOUT",,.T.))
INSERT INTO carttyp1e VALUES (3, GetLangText("MGRFINAN","TXT_INTERNAL",,.T.))
IF _SCREEN.GS
     INSERT INTO carttyp1e VALUES (4, GetLangText("MGRFINAN","TXT_VOUCHER",,.T.))
ENDIF
REPLACE at_descr WITH STRTRAN(at_descr, ";"," ") FOR ";" $ at_descr
COPY TO (this.cExportPath+"artitype.csv") DELIMITED WITH CHARACTER ";"

* vatgrp
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT pl_numcod AS vg_vat, pl_lang<<g_Langnum>> AS vg_descr, CAST(pl_numval AS N(5,2)) AS vg_pct, CAST(pl_inactiv AS C(1)) AS vg_inactiv
               FROM picklist
               WHERE pl_label = 'VATGROUP'
               ORDER BY 1
ENDTEXT
sqlcursor(lcSql,lcurName,,,,,,.T.)
REPLACE vg_descr WITH STRTRAN(vg_descr, ";"," ") FOR ";" $ vg_descr
COPY TO (this.cExportPath+"vatgrp.csv") DELIMITED WITH CHARACTER ";"

* maingrp
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT pl_numcod AS mg_main, pl_lang<<g_Langnum>> AS mg_descr, CAST(pl_inactiv AS C(1)) AS mg_inactiv
               FROM picklist
               WHERE pl_label = 'MAINGROUP'
               ORDER BY 1
ENDTEXT
sqlcursor(lcSql,lcurName,,,,,,.T.)
REPLACE mg_descr WITH STRTRAN(mg_descr, ";"," ") FOR ";" $ mg_descr
COPY TO (this.cExportPath+"maingrp.csv") DELIMITED WITH CHARACTER ";"

* subgrp
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT pl_numcod AS sg_sub, pl_lang<<g_Langnum>> AS sg_descr, CAST(pl_inactiv AS C(1)) AS sg_inactiv
               FROM picklist
               WHERE pl_label = 'SUBGROUP'
               ORDER BY 1
ENDTEXT
sqlcursor(lcSql,lcurName,,,,,,.T.)
REPLACE sg_descr WITH STRTRAN(sg_descr, ";"," ") FOR ";" $ sg_descr
COPY TO (this.cExportPath+"subgrp.csv") DELIMITED WITH CHARACTER ";"

* paymeth
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT pm_paynum, pm_paymeth, pm_lang<<g_Langnum>> AS pm_descr, pm_paytyp, CAST(pm_inactiv AS C(1)) AS pm_inactiv
               FROM paymetho
               ORDER BY 1
ENDTEXT
sqlcursor(lcSql,lcurName,,,,,,.T.)
REPLACE pm_descr WITH STRTRAN(pm_descr, ";"," ") FOR ";" $ pm_descr
COPY TO (this.cExportPath+"paymeth.csv") DELIMITED WITH CHARACTER ";"

* paytype
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT pl_numcod AS pt_paytyp, pl_lang<<g_Langnum>> AS pt_descr, CAST(pl_inactiv AS C(1)) AS pt_inactiv
               FROM picklist
               WHERE pl_label = 'PAYTYPE'
               ORDER BY 1
ENDTEXT
sqlcursor(lcSql,lcurName,,,,,,.T.)
REPLACE pt_descr WITH STRTRAN(pt_descr, ";"," ") FOR ";" $ pt_descr
COPY TO (this.cExportPath+"paytyp.csv") DELIMITED WITH CHARACTER ";"

* user
TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT us_id AS us_userid, us_name, us_group
               FROM user
               ORDER BY 1
ENDTEXT
sqlcursor(lcSql,lcurName,,,,,,.T.)
COPY TO (this.cExportPath+"user.csv") DELIMITED WITH CHARACTER ";"
DClose(lcurName)

RETURN .T.
ENDPROC
*
PROCEDURE CreateXML
LOCAL ctxt
TEXT TO ctxt TEXTMERGE NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE DataSet SYSTEM "gdpdu-01-09-2004.dtd">
<DataSet>
     <Version>1.0</Version>
     <DataSupplier>
          <Name><<STRCONV(ALLTRIM(param.pa_hotel),9)>></Name>
          <Location><<STRCONV(ALLTRIM(param.pa_city)+"/Deutschland",9)>></Location>
          <Comment><<"Datentraegerüberlassung nach GDPdU vom " + DTOC(sysdate())>></Comment>
     </DataSupplier>
     <Media>
          <Name>CD Nummer 1</Name>
          <Table>
               <URL>billnum.csv</URL>
               <Name>billnum</Name>
               <Description>Erstellte Rechnungen</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>bn_billnum</Name>
                         <Description>Rechnungsnummer</Description>
                         <AlphaNumeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>bn_billid</Name>
                         <Description>Reservierungs ID + Rechnungsfenster(Folio)</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_date</Name>
                         <Description>Erstellt am</Description>
                         <Date>
                              <Format>YYYYMMDD</Format>
                         </Date>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_cxldate</Name>
                         <Description>Storniert am</Description>
                         <Date>
                              <Format>YYYYMMDD</Format>
                         </Date>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_amount</Name>
                         <Description>Rechnungsbetrag</Description>
                         <Numeric>
                              <Accuracy>2</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_paynum</Name>
                         <Description>Finanzweg</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_status</Name>
                         <Description>Rechnungsstatus OPN-Offen; PCO-Geschlossen; CXL-Storniert</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>OPN</From>
                              <To>Offen</To>
                         </Map>
                         <Map>
                              <From>PCO</From>
                              <To>Geschlossen</To>
                         </Map>
                         <Map>
                              <From>CXL</From>
                              <To>Storniert</To>
                         </Map>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_userid</Name>
                         <Description>Benutzer ID von Tabelle user</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_company</Name>
                         <Description>Firmenname</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>bn_departm</Name>
                         <Description>Abteilung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <ForeignKey>
                         <Name>bn_paynum</Name>
                         <References>paymeth</References>
                         <Alias>
                              <From>bn_paynum</From>
                              <To>pm_paynum</To>
                         </Alias>
                    </ForeignKey>
                    <ForeignKey>
                         <Name>bn_userid</Name>
                         <References>user</References>
                         <Alias>
                              <From>bn_userid</From>
                              <To>us_userid</To>
                         </Alias>
                    </ForeignKey>
               </VariableLength>
          </Table>
          <Table>
               <URL>bookings.csv</URL>
               <Name>bookings</Name>
               <Description>Buchungen auf eine Rechnung</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>hp_postid</Name>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>hp_billid</Name>
                         <Description>Reservierungs ID + Rechnungsfenster(Folio)</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_artinum</Name>
                         <Description>PLU</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_date</Name>
                         <Description>Erstellungsdatum</Description>
                         <Date>
                              <Format>YYYYMMDD</Format>
                         </Date>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_cancel</Name>
                         <Description>Buchung ist gelöscht</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_descrip</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_supplem</Name>
                         <Description>Ergänzungstext, vom Benutzer hinzugefügt</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_userid</Name>
                         <Description>Benutzer ID von Tabelle user</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_amount</Name>
                         <Description>Betrag</Description>
                         <Numeric>
                              <Accuracy>2</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_price</Name>
                         <Description>Preis</Description>
                         <Numeric>
                              <Accuracy>2</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_units</Name>
                         <Description>Menge</Description>
                         <Numeric>
                              <Accuracy>2</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_vat</Name>
                         <Description>MwSt. Betrag</Description>
                         <Numeric>
                              <Accuracy>4</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <ForeignKey>
                         <Name>hp_artinum</Name>
                         <References>article</References>
                         <Alias>
                              <From>hp_artinum</From>
                              <To>ar_artinum</To>
                         </Alias>
                    </ForeignKey>
                    <ForeignKey>
                         <Name>hp_userid</Name>
                         <References>user</References>
                         <Alias>
                              <From>hp_userid</From>
                              <To>us_userid</To>
                         </Alias>
                    </ForeignKey>
               </VariableLength>
          </Table>
          <Table>
               <URL>payments.csv</URL>
               <Name>payments</Name>
               <Description>Zahlungen auf eine Rechnung</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>hp_postid</Name>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>hp_billid</Name>
                         <Description>Reservierungs ID + Rechnungsfenster(Folio)</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_billnum</Name>
                         <Description>Rechnungsnummer</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_paynum</Name>
                         <Description>Finanzweg</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_date</Name>
                         <Description>Erstellungsdatum</Description>
                         <Date>
                              <Format>YYYYMMDD</Format>
                         </Date>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_amount</Name>
                         <Description>Betrag</Description>
                         <Numeric>
                              <Accuracy>2</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_cancel</Name>
                         <Description>Buchung ist gelöscht</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_descrip</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_userid</Name>
                         <Description>Benutzer ID von Tabelle user</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_cashier</Name>
                         <Description>Kasse</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>hp_supplem</Name>
                         <Description>Zusatztext</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <ForeignKey>
                         <Name>hp_billnum</Name>
                         <References>billnum</References>
                         <Alias>
                              <From>hp_billnum</From>
                              <To>bn_billnum</To>
                         </Alias>
                    </ForeignKey>
                    <ForeignKey>
                         <Name>hp_paynum</Name>
                         <References>paymeth</References>
                         <Alias>
                              <From>hp_paynum</From>
                              <To>pm_paynum</To>
                         </Alias>
                    </ForeignKey>
                    <ForeignKey>
                         <Name>hp_userid</Name>
                         <References>user</References>
                         <Alias>
                              <From>hp_userid</From>
                              <To>us_userid</To>
                         </Alias>
                    </ForeignKey>
               </VariableLength>
          </Table>
          <Table>
               <URL>article.csv</URL>
               <Name>article</Name>
               <Description>Artikelstamm</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>ar_artinum</Name>
                         <Description>PLU</Description>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>ar_descr</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>ar_artityp</Name>
                         <Description>Artikeltyp von artitype Tabelle</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>ar_vat</Name>
                         <Description>Steuernummer von maingrp Tabelle</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>ar_main</Name>
                         <Description>Artikel Hauptgruppennummer von maingrp Tabelle</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>ar_sub</Name>
                         <Description>Artikel Spartenummer von subgrp Tabelle</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>ar_price</Name>
                         <Description>Preis</Description>
                         <Numeric>
                              <Accuracy>2</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>ar_inactiv</Name>
                         <Description>Nicht aktiv</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
                    <ForeignKey>
                         <Name>ar_artityp</Name>
                         <References>artitype</References>
                         <Alias>
                              <From>ar_artityp</From>
                              <To>at_artityp</To>
                         </Alias>
                    </ForeignKey>
                    <ForeignKey>
                         <Name>ar_vat</Name>
                         <References>vatgrp</References>
                         <Alias>
                              <From>ar_vat</From>
                              <To>vg_vat</To>
                         </Alias>
                    </ForeignKey>
                    <ForeignKey>
                         <Name>ar_main</Name>
                         <References>maingrp</References>
                         <Alias>
                              <From>ar_main</From>
                              <To>mg_main</To>
                         </Alias>
                    </ForeignKey>
                    <ForeignKey>
                         <Name>ar_sub</Name>
                         <References>subgrp</References>
                         <Alias>
                              <From>ar_sub</From>
                              <To>sg_sub</To>
                         </Alias>
                    </ForeignKey>
               </VariableLength>
          </Table>
          <Table>
               <URL>artitype.csv</URL>
               <Name>artitype</Name>
               <Description>Artikeltypen</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>at_artityp</Name>
                         <Description>Nummer</Description>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>at_descr</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
               </VariableLength>
          </Table>
          <Table>
               <URL>vatgrp.csv</URL>
               <Name>vatgrp</Name>
               <Description>Steuergruppen</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>vg_vat</Name>
                         <Description>Nummer</Description>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>vg_descr</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>vg_pct</Name>
                         <Description>Prozentsatz</Description>
                         <Numeric>
                              <Accuracy>2</Accuracy>
                         </Numeric>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>vg_inactiv</Name>
                         <Description>Nicht aktiv</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
               </VariableLength>
          </Table>
          <Table>
               <URL>maingrp.csv</URL>
               <Name>maingrp</Name>
               <Description>Artikel Hauptgruppennummer</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>mg_main</Name>
                         <Description>Nummer</Description>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>mg_descr</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>mg_inactiv</Name>
                         <Description>Nicht aktiv</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
               </VariableLength>
          </Table>
          <Table>
               <URL>subgrp.csv</URL>
               <Name>subgrp</Name>
               <Description>Artikel Spartenummer</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>sg_sub</Name>
                         <Description>Nummer</Description>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>sg_descr</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>sg_inactiv</Name>
                         <Description>Nicht aktiv</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
               </VariableLength>
          </Table>
          <Table>
               <URL>paymeth.csv</URL>
               <Name>paymeth</Name>
               <Description>Zahlungsmethode</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>pm_paynum</Name>
                         <Description>Nummer</Description>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>pm_paymeth</Name>
                         <Description>Kode</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>pm_descr</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>pm_paytyp</Name>
                         <Description>Zahlungstyp von paytyp Tabelle</Description>
                         <Numeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>pm_inactiv</Name>
                         <Description>Nicht aktiv</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
                    <ForeignKey>
                         <Name>pm_paytyp</Name>
                         <References>paytyp</References>
                         <Alias>
                              <From>pm_paytyp</From>
                              <To>pt_paytyp</To>
                         </Alias>
                    </ForeignKey>
               </VariableLength>
          </Table>
          <Table>
               <URL>paytyp.csv</URL>
               <Name>paytyp</Name>
               <Description>Zahlungstyp</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>pt_paytyp</Name>
                         <Description>Nummer</Description>
                         <Numeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>pt_descr</Name>
                         <Description>Beschreibung</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>pt_inactiv</Name>
                         <Description>Nicht aktiv</Description>
                         <AlphaNumeric/>
                         <Map>
                              <From>T</From>
                              <To>True</To>
                         </Map>
                         <Map>
                              <From>F</From>
                              <To>False</To>
                         </Map>
                    </VariableColumn>
               </VariableLength>
          </Table>
          <Table>
               <URL>user.csv</URL>
               <Name>user</Name>
               <Description>Benutzer</Description>
               <VariableLength>
                    <VariablePrimaryKey>
                         <Name>us_userid</Name>
                         <Description>Nummer</Description>
                         <AlphaNumeric/>
                    </VariablePrimaryKey>
                    <VariableColumn>
                         <Name>us_name</Name>
                         <Description>Vorname und Nachname</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
                    <VariableColumn>
                         <Name>us_group</Name>
                         <Description>Benutzergruppe</Description>
                         <AlphaNumeric/>
                    </VariableColumn>
               </VariableLength>
          </Table>
     </Media>
</DataSet>
ENDTEXT

ctxt = STRCONV(ctxt,9) && Convert to UTF-8
STRTOFILE(ctxt, this.cExportPath+"index.xml",0)

RETURN .T.
ENDPROC
*
PROCEDURE CreateDTD
LOCAL ctxt
TEXT TO ctxt NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<!--Versions available:
1.1 (August-01-2002)

1.2 (June-01-2003)
  New Element Alias

1.3 (November-01-2003)
  New Element Extension

1.4 (May-01-2004)
  New Element AcceptNoTables
  <Table> is now optional

1.5 (September-01-2004)
  Updated the ForeignKey and Alias elements so they allow
  multiple Alias elements per ForeignKey. This allows one to use alias
  elements for a Composite key.

  Example:

  <ForeignKey>
    <Name>Order</Name>
    <Name>Customer</Name>
    <References>Orders</References>
    <Alias>
      <From>Order</From>
      <To>OrderId</To>
    </Alias>
    <Alias>
      <From>Customer</From>
      <To>CustomerId</To>
    </Alias>
-->

<!-- Start Simple Types -->

<!-- Supplementary Vocabulary -->
<!ELEMENT Version (#PCDATA)>
<!ELEMENT Location (#PCDATA)>
<!ELEMENT Comment (#PCDATA)>
<!ELEMENT Length (#PCDATA)>
<!ELEMENT References (#PCDATA)>
<!ELEMENT From (#PCDATA)>
<!ELEMENT To (#PCDATA)>

<!-- Sometimes, it is desirable to have a <Media> with
     no tables.

     Example:
       An extension might provide metadata
       that describes all tax-relevant data.

     This option is turned off by default. -->
<!ELEMENT AcceptNoTables (#PCDATA)>

<!-- Use Alias to reference columns with different names in
     a ForeignKey element. These Alias elements are optional.

     The following rules apply to the Alias element:
       - One Alias can be used per ForeignKey.
       - Alias elements can appear in any order.

     Example:
       Table Orders has a primary key OrderId
       Table Accounts has a foreign key Order.

       You can use the Alias element to specify Order references OrderId.

       <ForeignKey>
          <Name>Order</Name>
          <Name>Customer</Name>
          <References>Orders</References>
          <Alias>
            <From>Order</From>
            <To>OrderId</To>
          </Alias>
        </ForeignKey> -->
<!ELEMENT Alias (From, To)>

<!-- Specifying a maximum length for a VariableLength column can
     reduce a VariableLength tables' import time. If MaxLength
     is not specified then we parse URL to determine the MaxLength
     for each column.

     * Only applies to VariableLength tables. -->
<!ELEMENT MaxLength (#PCDATA)>

<!-- Specifies which character (if any) encapsulates a
     VariableLength AlphaNumeric column.

     Doublequote is the default TextEncapsulator "

     * Only applies to VariableLength tables. (Optional) -->
<!ELEMENT TextEncapsulator (#PCDATA)>

<!-- Specifies how many digits appear to the right of the decimal symbol.

     CAUTION: Results are undefined when importing numeric data with
              greater Accuracy than the Accuracy defined in index.xml

              For example trying to import the value 1000,25 with an
              accuracy of 0 might result in 1000 or an error. This
              behavior is specific to the implementation.

     Zero is the default Accuracy '0' (Optional)
-->
<!ELEMENT Accuracy (#PCDATA)>

<!-- The decimal place is not always stored with numbers. If each number
     is supposed to have decimal places use ImpliedAccuracy -->
<!ELEMENT ImpliedAccuracy (#PCDATA)>

<!-- Enables you to change how GDPdU displays dates.
     DD.MM.YYYY is the default Format -->
<!ELEMENT Format (#PCDATA)>

<!-- Specifies the symbol that indicates decimal values.
     Comma is the default DecimalSymbol. ','
     Specified once per Table. -->
<!ELEMENT DecimalSymbol (#PCDATA)>

<!-- Specifies the symbol that groups the digits in large numbers.
     Dot is the default DigitGroupingSymbol or ThousandsSeperator. '.'
     Specified once per Table -->
<!ELEMENT DigitGroupingSymbol (#PCDATA)>

<!-- Command(s) are executed in the following manner
      * before the import process
      * after the import process
      * before a Media is imported
      * after a Media is imported
-->
<!ELEMENT Command (#PCDATA)>

<!-- Only the file protocol is supported at this time.

     * The standard uses relative URLs.

     Absolute URLs are not allowed. The following are all invalid:
     * http://www.somewhere.com/data/Accounts.dat
     * ftp://ftp.somewhere.com/data/Accounts.dat
     * file://localhost/Accounts.dat
     * file:///Accounts.dat

     The following are valid examples
      * Accounts.dat
      * data/Accounts.dat
      * data/january/Accounts.dat
      * ../Accounts.dat
-->
<!ELEMENT URL (#PCDATA)>

<!-- Textual description of specified element (Optional) -->
<!ELEMENT Description (#PCDATA)>

<!-- The logical name of specified element.
     Sometimes referred to business name.

     If missing, URL will be used in place of Name. -->
<!ELEMENT Name (#PCDATA)>

<!-- Y2K Window Any year before Epoch is 2000+
     Default value 30.  -->
<!ELEMENT Epoch (#PCDATA)>

<!-- Element(s) that separate columns or records.
     Semicolon is the default ColumnDelimiter. ';'
     CRLF or &#13;&#10; is the default RecordDelimiter. -->
<!ELEMENT ColumnDelimiter (#PCDATA)>
<!ELEMENT RecordDelimiter (#PCDATA)>

<!-- The number of bytes skipped before reading of URL commences.
     Zero is the default when not specified. '0'
-->
<!ELEMENT SkipNumBytes (#PCDATA)>

<!-- End Simple Types -->
<!-- Start Complex Types -->

<!-- Use Extension when you want to add application
     specific functionality to the existing standard.

     Name - the extension name or identifier.
     URL  - the supplementary .xml file that corresponds to the
            extension.

     An application that extends the standard should scan the
     Dataset element for the presence of zero or more Extension
     elements. The application can use the Name element to identify
     the extension.

     When choosing a name for your extension, do not choose a common
     name. This will reduce undefined results for name conflicts.

     It is possible that future extensions will be ratified as
     mandatory to meet GDPdU guidelines. -->
<!ELEMENT Extension (Name, URL)>

<!-- Self-explanatory -->
<!ELEMENT Range (From, (To | Length)?)>
<!ELEMENT FixedRange (From, (To | Length))>

<!-- The document element -->
<!ELEMENT DataSet (Extension*, Version, DataSupplier?, Command*, Media+, Command*)>

<!-- Supported datatypes (mandatory) -->
<!ELEMENT AlphaNumeric EMPTY>
<!ELEMENT Date (Format?)>
<!ELEMENT Numeric ((ImpliedAccuracy | Accuracy)?)>

<!-- Supported codepages:
     Be careful to explicitly define RecordDelimiter when using
     a non-default codepage.

     ANSI is the default codepage when not specified -->
<!ELEMENT ANSI EMPTY>
<!ELEMENT Macintosh EMPTY>
<!ELEMENT OEM EMPTY>
<!ELEMENT UTF16 EMPTY>
<!ELEMENT UTF7 EMPTY>
<!ELEMENT UTF8 EMPTY>

<!-- Supported file formats:
     FixedLength
     VariableLength -->
<!ELEMENT FixedLength ((Length | RecordDelimiter)?, ((FixedPrimaryKey+, FixedColumn*) | (FixedColumn+)), ForeignKey*)>
<!ELEMENT FixedColumn (Name, Description?, (Numeric | AlphaNumeric | Date), Map*, FixedRange)>
<!ELEMENT FixedPrimaryKey (Name, Description?, (Numeric | AlphaNumeric | Date), Map*, FixedRange)>
<!ELEMENT VariableLength (ColumnDelimiter?, RecordDelimiter?, TextEncapsulator?, ((VariablePrimaryKey+, VariableColumn*) | (VariableColumn+)), ForeignKey*)>
<!ELEMENT VariableColumn (Name, Description?, (Numeric | (AlphaNumeric, MaxLength?) | Date), Map*)>
<!ELEMENT VariablePrimaryKey (Name, Description?, (Numeric | (AlphaNumeric, MaxLength?) | Date), Map*)>

<!-- Description of the entity supplying the data. (Optional) -->
<!ELEMENT DataSupplier (Name, Location, Comment)>

<!-- The first Media will contain index.xml. Importing will process each media listed -->
<!ELEMENT Media (Name, Command*, Table*, Command*, AcceptNoTables?)>

<!-- Elements common to FixedLength & VariableLength are propagated to Table. -->
<!ELEMENT Table (URL, Name?, Description?, Validity?, (ANSI | Macintosh | OEM | UTF16 | UTF7 | UTF8)?, (DecimalSymbol, DigitGroupingSymbol)?, SkipNumBytes?, Range?, Epoch?, (VariableLength | FixedLength))>

<!-- ForeignKeys denote joins or relationships between tables.
     To successfully join two tables make sure both the PrimaryKey
     and the referenced column (ForeignKey) are of the same datatype.
     Results are undefined when joining two tables with different
     key datatypes. Most likely an error will occur.

     see line 35 for information about Alias -->
<!ELEMENT ForeignKey (Name+, References, Alias*)>

<!-- Maps AlphaNumeric columns from 'From' to 'To'
     ie. From         To
         ============ =============
         True         1
         True         -1
         False        0

     Basically, a map is an associative container.

     The standard implementation only supports
     AlphaNumeric datatypes. The following
     conversions are NOT supported.

     Numeric      -> AlphaNumeric
     Date         -> AlphaNumeric
     AplhaNumeric -> Date
     AlphaNumeric -> Numeric
-->
<!ELEMENT Map (Description?, From, To)>

<!-- Documentation for table validity. -->
<!ELEMENT Validity (Range, Format?)>

<!-- End Complex Types -->

ENDTEXT

STRTOFILE(ctxt, this.cExportPath+"gdpdu-01-09-2004.dtd",0)

RETURN .T.
ENDPROC
*
ENDDEFINE