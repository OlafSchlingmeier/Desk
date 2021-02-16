*
PROCEDURE PpVersion
PARAMETER cversion
cversion = "1.10"
RETURN
ENDPROC
*
PROCEDURE DEPBILL
LOCAL nreserid, nbIllwindow, naddrid, l_csql, nheadid, nrecnores, nrecnodep, ndepcnt, ndepositamount, nbillamount, odata, i, ;
          nreceiptnr, cwhere, l_cRCDescript, l_nArtiNum, l_nPrintFormat, ndepositid, lusedrecidetfield, ndepositadded
          
LOCAL ARRAY l_aReportHeader(7)

* Set global settings for bill frx
g_dbilldate = sysdate()
g_Rptlng = "GER"
g_Rptlngnr = "3"

nreserid = min1
l_nPrintFormat = IIF(EMPTY(min3),1,min3)
nrecnores = RECNO("reservat")
=SEEK(nreserid,"reservat","tag1")
nheadid = deposit.dp_headid
nrecnodep = RECNO("deposit")
dlocate("deposit","dp_reserid = reservat.rs_reserid AND dp_headid = " + TRANSFORM(nheadid) + " AND dp_headid = dp_lineid")

ndepcnt = deposit.dp_depcnt
nreceiptnr = deposit.dp_receipt
ndepositid = deposit.dp_lineid
lusedrecidetfield = TYPE("deposit.dp_recidet")="M"

nbIllwindow = IIF(EMPTY(reservat.rs_compid),1,2)
naddrid = IIF(EMPTY(reservat.rs_compid),reservat.rs_addrid,reservat.rs_compid)
_screen.oGlobal.oBill.nAddrId = naddrid
_screen.oGlobal.oBill.nReserId = nreserid
_screen.oGlobal.oBill.nWindow = nbIllwindow

IF lusedrecidetfield AND nreceiptnr > 0 AND NOT EMPTY(deposit.dp_recidet) AND DepBillReadOnlyMode()
     DepBillLoadBillDetails()
ELSE

     SELECT ps_reserid,ps_window,ps_units,ps_artinum,ps_price,ps_supplem,ps_date,ps_note,ps_descrip,;
            ps_vat0,ps_vat1,ps_vat2,ps_vat3,ps_vat4,ps_vat5,ps_vat6,ps_vat7,ps_vat8,ps_vat9,ps_amount,ps_paynum,ps_ratecod, ;
            00000000000.00 AS cur_amount, ;
            00000000000.00 AS cur_price, ;
            00000000000.00 AS cf_amount, ;
            00000000000.00 AS cf_price, ;
            00000000000.00 AS cf_sumamt, ;
            CAST(0 AS Double) AS cf_vat0, ;
            CAST(0 AS Double) AS cf_vat1, ;
            CAST(0 AS Double) AS cf_vat2, ;
            CAST(0 AS Double) AS cf_vat3, ;
            CAST(0 AS Double) AS cf_vat4, ;
            CAST(0 AS Double) AS cf_vat5, ;
            CAST(0 AS Double) AS cf_vat6, ;
            CAST(0 AS Double) AS cf_vat7, ;
            CAST(0 AS Double) AS cf_vat8, ;
            CAST(0 AS Double) AS cf_vat9, ;
            CAST(0 AS Double) AS cf_ratio, ;
            CAST('' AS Char(50)) AS cTitle, ;
            CAST('' AS Char(100)) AS CDEPARTMEN, ;
            CAST('' AS Char(200)) AS cName, ;
            CAST('' AS Char(200)) AS cStreet1, ;
            CAST('' AS Char(200)) AS cStreet2, ;
            CAST('' AS Char(200)) AS cCity, ;
            CAST('' AS Char(25)) AS cCountry, ;
            CAST('' AS Char(25)) AS crclang, ;
            CAST('' AS Char(25)) AS carlang, ;
            CAST(0 AS Numeric(8)) AS creceiptnr ;
            FROM post ;
            WHERE 1=0 ;
            INTO CURSOR cdeppost43 ;
            READWRITE
     DO dpgetreservatfilterclause IN dp WITH cwhere

     TEXT TO l_csql TEXTMERGE NOSHOW PRETEXT 15
     SELECT rl_artinum, rl_artityp, rl_price, rl_ratecod, ;
          pl_numcod, pl_numval, CAST(NVL(<<"rc_lang" + g_RptLngNr>>,'') AS Char(25)) AS crclang, ;
          CAST(NVL(<<"ar_lang" + g_RptLngNr>>,'') AS Char(25)) AS carlang, ;
          CAST(SUM(rl_units*rs_rooms) AS Numeric(5)) AS c_units ;
          FROM reservat WITH (BUFFERING = .T.);
          INNER JOIN ressplit ON rs_rsid = rl_rsid ;
          INNER JOIN article ON rl_artinum = ar_artinum ;
          INNER JOIN picklist p1 ON p1.pl_label = 'VATGROUP' AND ar_vat = p1.pl_numcod ;
          LEFT JOIN ratecode ON rl_ratecod = rc_key ;
          WHERE <<cwhere>> ;
          GROUP BY 1,2,3,4,5,6,7,8 ;
          ORDER BY 2,1 DESC ;
          INTO CURSOR c2
     ENDTEXT
     l_csql = STRTRAN(l_csql,";","")
     &l_csql

     SCAN ALL
          SELECT cdeppost43
          SCATTER NAME odata MEMO BLANK
          odata.ps_reserid = nreserid
          odata.ps_window = 1
          odata.ps_artinum = c2.rl_artinum
          odata.ps_units = c2.c_units
          odata.cf_price = c2.rl_price               && Full price
          odata.cf_amount = c2.rl_price * c2.c_units && Full amount
          odata.ps_price = c2.rl_price
          odata.ps_amount = c2.rl_price * c2.c_units
          odata.ps_date = sysdate()
          odata.ps_ratecod = c2.rl_ratecod
          IF c2.pl_numval = 0
               odata.ps_vat0 = odata.ps_amount
          ELSE
               l_cMacro = "odata.ps_vat" + TRANSFORM(c2.pl_numcod)
               &l_cMacro = odata.ps_amount*c2.pl_numval/(100+c2.pl_numval)
          ENDIF
          odata.crclang = c2.crclang
          odata.carlang = c2.carlang
          INSERT INTO cdeppost43 FROM NAME odata
     ENDSCAN

     IF l_nPrintFormat=2 && Arrangment
          SELECT *, ps_amount AS cf_amount, ps_amount AS cf_price, ps_amount AS ps_price ;
          FROM ( ;
               SELECT SUM(ps_vat0) AS ps_vat0, SUM(ps_vat1) AS ps_vat1, SUM(ps_vat2) AS ps_vat2, SUM(ps_vat3) AS ps_vat3, SUM(ps_vat4) AS ps_vat4, ;
                      SUM(ps_vat5) AS ps_vat5, SUM(ps_vat6) AS ps_vat6, SUM(ps_vat7) AS ps_vat7, SUM(ps_vat8) AS ps_vat8, SUM(ps_vat9) AS ps_vat9, ;
                      SUM(ps_amount) AS ps_amount ;
                      FROM cdeppost43 ;
               ) c1 ;
          INTO CURSOR cgrpone19
          SELECT c2
          LOCATE FOR NOT EMPTY(crclang)
          IF FOUND()
               l_cRCDescript = crclang
          ELSE
               l_cRCDescript = "Arrangment"
          ENDIF
          LOCATE FOR NOT EMPTY(rl_artinum) AND rl_artityp=1
          IF FOUND()
               l_nArtiNum = rl_artinum
          ELSE
               LOCATE FOR NOT EMPTY(rl_artinum)
               l_nArtiNum = rl_artinum
          ENDIF
          SELECT cdeppost43
          ZAP
          SELECT cgrpone19
          SCATTER NAME l_oData MEMO
          ADDPROPERTY(l_oData, "ps_window",1)
          ADDPROPERTY(l_oData, "ps_artinum",l_nArtiNum)
          ADDPROPERTY(l_oData, "ps_units",1)
          ADDPROPERTY(l_oData, "ps_reserid",nreserid)
          ADDPROPERTY(l_oData, "ps_date",sysdate())
          ADDPROPERTY(l_oData, "crclang",l_cRCDescript)
          ADDPROPERTY(l_oData, "carlang",l_cRCDescript)
          INSERT INTO cdeppost43 FROM NAME l_oData
          dclose("cgrpone19")
     ENDIF

     SELECT cdeppost43
     SUM ps_amount TO nbillamount

     * Show articles added later in deposit
     TEXT TO l_csql TEXTMERGE NOSHOW PRETEXT 15
          SELECT dp_artinum, dp_debit, dp_ref, dp_descrip, dp_supplem, ;
               CAST(NVL(<<"ar_lang" + g_RptLngNr>>,'') AS Char(25)) AS carlang, ;
               pl_numval, pl_numcod ;
               FROM deposit WITH (BUFFERING=.T.) ;
               INNER JOIN article ON dp_artinum = ar_artinum AND ar_depuse ;
               INNER JOIN picklist p1 ON p1.pl_label = 'VATGROUP' AND ar_vat = p1.pl_numcod ;
               WHERE dp_headid = nheadid AND dp_artinum > 0 AND dp_cashier > 0 ;
               INTO CURSOR caddposting6771
     ENDTEXT
     l_csql = STRTRAN(l_csql,";","")
     &l_csql
     ndepositadded = 0
     SCAN ALL
          SELECT cdeppost43
          SCATTER NAME odata MEMO BLANK
          odata.ps_reserid = nreserid
          odata.ps_window = 1
          odata.ps_artinum = caddposting6771.dp_artinum
          odata.ps_units = 1
          ndepositadded = ndepositadded + caddposting6771.dp_debit
          odata.cf_price = caddposting6771.dp_debit
          odata.cf_amount = caddposting6771.dp_debit
          odata.ps_price = caddposting6771.dp_debit
          odata.ps_amount = caddposting6771.dp_debit
          odata.ps_supplem = EVL(caddposting6771.dp_supplem,caddposting6771.dp_ref)
          odata.ps_descrip = caddposting6771.dp_descrip
          odata.ps_date = reservat.rs_arrdate
          IF caddposting6771.pl_numval = 0
               odata.ps_vat0 = odata.ps_amount
          ELSE
               l_cMacro = "odata.ps_vat" + TRANSFORM(caddposting6771.pl_numcod)
               &l_cMacro = odata.ps_amount*caddposting6771.pl_numval/(100+caddposting6771.pl_numval)
          ENDIF
          odata.carlang = caddposting6771.carlang
          INSERT INTO cdeppost43 FROM NAME odata
     ENDSCAN

     nbillamount = nbillamount + ndepositadded
     SELECT deposit
     SUM dp_debit FOR dp_headid  = nheadid AND dp_artinum>0 TO ndepositamount
     *ndepositamount = EVALUATE("reservat.rs_depamt"+TRANSFORM(ndepcnt)) + ndepositadded
     nratio = ndepositamount/nbillamount
     * Calculate deposit price, amount and vat in report
     *SCAN ALL
     *     SCATTER NAME odata MEMO
     *     odata.ps_price = ROUND(odata.ps_price * nratio,2)
     *     odata.ps_amount = ROUND(odata.ps_amount * nratio,2)
     *     FOR i = 0 TO 9
     *          nvatamt = EVALUATE("odata.ps_vat"+TRANSFORM(i))
     *          IF NOT EMPTY(nvatamt)
     *               l_cMacro = "odata.ps_vat"+TRANSFORM(i)
     *               &l_cMacro = nvatamt * nratio
     *          ENDIF
     *     ENDFOR
     *     GATHER NAME odata MEMO
     *ENDSCAN

     * Add deposit payments to bill
     TEXT TO l_csql TEXTMERGE NOSHOW PRETEXT 15
          SELECT dp_paynum, dp_credit, dp_ref, dp_descrip, dp_supplem, dp_date, ;
               CAST(NVL(<<"pm_lang" + g_RptLngNr>>,'') AS Char(25)) AS cpmlang ;
               FROM deposit WITH (BUFFERING=.T.) ;
               INNER JOIN paymetho ON dp_paynum = pm_paynum ;
               WHERE dp_headid = nheadid AND dp_paynum > 0 AND dp_cashier > 0 ;
               INTO CURSOR caddpayments6771
     ENDTEXT
     l_csql = STRTRAN(l_csql,";","")
     &l_csql
     SCAN ALL
          SELECT cdeppost43
          SCATTER NAME odata MEMO BLANK
          odata.ps_reserid = nreserid
          odata.ps_window = 1
          odata.ps_paynum = caddpayments6771.dp_paynum
          odata.ps_units = 1
          odata.cf_price = caddpayments6771.dp_credit
          odata.cf_amount = caddpayments6771.dp_credit
          odata.ps_price = caddpayments6771.dp_credit
          odata.ps_amount = caddpayments6771.dp_credit
          odata.ps_supplem = EVL(caddpayments6771.dp_supplem,caddpayments6771.dp_ref)
          odata.ps_descrip = caddpayments6771.dp_descrip
          odata.ps_date = caddpayments6771.dp_date
          odata.carlang = caddpayments6771.cpmlang 
          INSERT INTO cdeppost43 FROM NAME odata
     ENDSCAN
     
     
     =SEEK(naddrid,"address","tag1")

     DO BillReportHeader IN ProcBill WITH .F., nbIllwindow, l_aReportHeader

     REPLACE cTitle WITH l_aReportHeader(1), ;
             CDEPARTMEN WITH l_aReportHeader(2), ;
             cName WITH l_aReportHeader(3), ;
             cStreet1 WITH l_aReportHeader(4), ;
             cStreet2 WITH l_aReportHeader(5), ;
             cCity WITH l_aReportHeader(6), ;
             cCountry WITH l_aReportHeader(7), ;
             cf_sumamt WITH nbillamount, ;
             cf_ratio WITH nratio, ;
             creceiptnr WITH nreceiptnr ;
             ALL ;
             IN cdeppost43

     SELECT * FROM cdeppost43 INTO CURSOR preproc NOFILTER

     IF lusedrecidetfield AND nreceiptnr > 0
          DepBillStoreBillDetails(ndepositid)
     ENDIF

     dclose("c2")
     dclose("cdeppost43")
     dclose("caddposting6771")
     dclose("caddpayments6771")
ENDIF

GO nrecnores IN reservat
GO nrecnodep IN deposit

SELECT preproc

RETURN .T.
ENDPROC
*
PROCEDURE DepBillStoreBillDetails
LPARAMETERS ndepositid
LOCAL ojson, cxml, cdetails, opacked, cRecieptDetails
ojson = NEWOBJECT("json","common\progs\json.prg")
cxml = filetemp("XML",.T.)
FNStructureToXML(@cxml,"preproc")
cdetails = ojson.stringify("preproc")
opacked = CREATEOBJECT("Empty")
ADDPROPERTY(opacked, "cursorstructure", FILETOSTR(cxml))
ADDPROPERTY(opacked, "cursordata", cdetails)
cRecieptDetails = ojson.stringify(opacked)
UPDATE deposit SET dp_recidet = cRecieptDetails WHERE dp_lineid = ndepositid
IF DepBillReadOnlyMode()
     UPDATE hdeposit SET dp_recidet = cRecieptDetails WHERE dp_lineid = ndepositid
ELSE
     DoTableUpdate(.T.,.T.,"deposit")
     = EndTransaction()
ENDIF
filedelete(cxml)
RETURN .T.
ENDPROC
*
PROCEDURE DepBillLoadBillDetails
LOCAL ojson, odetails, cxml, ccurjsondata, ccurjsonalias
ojson = NEWOBJECT("json","common\progs\json.prg")
odetails = ojson.parse(deposit.dp_recidet)
cxml = odetails.cursorstructure
ccurjsondata = filetemp("DBF",.T.)
ccurjsonalias = JUSTSTEM(ccurjsondata)
FNTableFromXML(cxml, ccurjsondata)
= ojson.parse(odetails.cursordata, ,ccurjsonalias)
SELECT * FROM (ccurjsonalias) INTO CURSOR preproc NOFILTER
dclose(ccurjsonalias)
filedelete(ccurjsondata)
filedelete(FORCEEXT(ccurjsondata,"FPT"))
RETURN .T.
ENDPROC
*
PROCEDURE DepBillReadOnlyMode
LOCAL I_, lreadonly
lreadonly = .F.
FOR I_=1 TO _SCREEN.FORMCount
     IF UPPER(_SCREEN.FORMS(I_).NAME)='TFORM12'
          IF TYPE("_Screen.Forms(I_).formname") = "C"
               IF UPPER(_Screen.Forms(I_).formname)="FRMDP"
                    IF TYPE("_SCREEN.FORMS(I_).Parent.p_readonly")="L"
                         lreadonly = _SCREEN.FORMS(I_).Parent.p_readonly
                    ENDIF
                    EXIT
               ENDIF
          ENDIF
     ENDIF
NEXT
RETURN lreadonly
ENDPROC