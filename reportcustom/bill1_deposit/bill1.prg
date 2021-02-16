*PROCEDURE bill1

* This properties and global variables can be used:
*
* _screen.oGlobal.oBill.nAddrId - address id
* _screen.oGlobal.oBill.nReserId - ps_reserid
* _screen.oGlobal.oBill.nWindow - ps_window
* _screen.oGlobal.oBill.cArtForClause - additional filter, depending on VAT settings
* g_Billstyle - Bill Style 1 - 13

LOCAL l_nreserid, l_cBillCur, l_nDepArt, l_cArtField, l_lHist, l_cSql, l_cMacro, l_cResCur, l_lDataInHistory

l_cBillCur = ALIAS()

IF LOWER(l_cBillCur) <> "temppost"
     l_lHist = .T.
ENDIF

l_nreserid = _screen.oGlobal.oBill.nReserId
l_nDepArt = _screen.oGlobal.oparam.pa_depxfer
l_cArtField = IIF(l_lHist,"hp","ps")+"_artinum"
l_cResCur = sqlcursor("SELECT rs_rsid FROM reservat WHERE rs_reserid = " + sqlcnv(l_nreserid,.T.))
IF RECCOUNT(l_cResCur)=0
     l_lDataInHistory = .T.
ENDIF
dclose(l_cResCur)

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT pl_numcod, pl_numval, SUM(dp_debit) AS csum ;
     FROM <<IIF(l_lDataInHistory,"h","")>>deposit ;
     INNER JOIN article ON dp_artinum = ar_artinum ;
     INNER JOIN picklist ON pl_label = 'VATGROUP' AND pl_numcod = ar_vat ;
     WHERE dp_reserid = l_nreserid AND dp_artinum > 0 ;
     GROUP BY 1,2 ;
     INTO CURSOR cdepdatax143
ENDTEXT
l_cSql = STRTRAN(l_cSql, ";","")
&l_cSql

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT <<IIF(l_lHist,"hp_","ps_")>>vat0 AS c_vat0, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat1 AS c_vat1, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat2 AS c_vat2, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat3 AS c_vat3, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat4 AS c_vat4, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat5 AS c_vat5, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat6 AS c_vat6, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat7 AS c_vat7, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat8 AS c_vat8, ;
       <<IIF(l_lHist,"hp_","ps_")>>vat9 AS c_vat9, ;
       0000000000.00 AS c_amt0, ;
       0000000000.00 AS c_amt1, ;
       0000000000.00 AS c_amt2, ;
       0000000000.00 AS c_amt3, ;
       0000000000.00 AS c_amt4, ;
       0000000000.00 AS c_amt5, ;
       0000000000.00 AS c_amt6, ;
       0000000000.00 AS c_amt7, ;
       0000000000.00 AS c_amt8, ;
       0000000000.00 AS c_amt9 ;
       FROM (l_cBillCur) ;
       WHERE &l_cArtField = l_nDepArt INTO CURSOR cdepa129 READWRITE
ENDTEXT
l_cSql = STRTRAN(l_cSql, ";","")
&l_cSql

SELECT cdepdatax143
SCAN ALL
     IF pl_numval = 0
          REPLACE c_vat0 WITH cdepdatax143.csum*-1 IN cdepa129
     ELSE
          l_cMacro = "c_amt" + TRANSFORM(pl_numcod)
          REPLACE &l_cMacro WITH cdepdatax143.csum*-1 IN cdepa129
     ENDIF
ENDSCAN

dclose("cdepdatax143")

* It is NOT ALLOWED to delete records from temppost!
* When printing more bill copies, same temppost cursor is used many times!

*SELECT * FROM (l_cBillCur) WHERE &l_cArtField <> l_nDepArt INTO CURSOR temppostdep872 NOFILTER
SELECT (l_cBillCur)
GO TOP

RETURN .T.
ENDPROC
*
PROCEDURE PpVersion
PARAMETER cversion
cversion = "1.00"
RETURN
ENDPROC
*