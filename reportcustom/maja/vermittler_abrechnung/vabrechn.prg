PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE vabrechn
LOCAL l_nAddrId, l_dFrom, l_dTo, l_oData, l_nProvPerc, l_nSum, l_cFrom, l_cTo

l_nAddrId = Min1
l_dFrom = min3
l_dTo = max3
l_cFrom = DTOS(l_dFrom)
l_cTo = DTOS(l_dTo)

* Create results cursor. Here are financial data, but also base address data. Base data are copied into every record.

SELECT address.*, ;
     000 AS c_pos, CAST('' AS Char(100)) AS c_descript, 000000000.00 AS c_amount, 000000000.00 AS c_sum ;
     FROM address ;
     WHERE ad_addrid = l_nAddrId ;
     INTO CURSOR cres ;
     READWRITE

* Select room price and provision for selected dates

SELECT NVL(SUM(c_price),0) AS c_sprice, NVL(SUM(c_prov),0) AS c_sprov, NVL(SUM(c_owner),0) AS c_sowner ;
     FROM ;
     (SELECT c_bnumber, c_price, c_prov, c_price - c_prov AS c_owner ;
          FROM ;
          (SELECT CAST(STRTRAN(rs_usrres1,",",".") AS Char(10)) AS c_bnumber, CAST(STRTRAN(rs_usrres6,",",".") AS Numeric(10,2)) AS c_price, CAST(STRTRAN(rs_usrres2,",",".") AS Numeric(10,2)) AS c_prov ;
          FROM reservat ;
          WHERE DTOS(rs_depdate)+rs_roomnum BETWEEN l_cFrom AND l_cTo AND rs_agentid = l_nAddrId ;
          ) c1) c2 ;
     INTO CURSOR cfinr
GO TOP

SELECT NVL(SUM(c_price),0) AS c_sprice, NVL(SUM(c_prov),0) AS c_sprov, NVL(SUM(c_owner),0) AS c_sowner ;
     FROM ;
     (SELECT c_bnumber, c_price, c_prov, c_price - c_prov AS c_owner ;
          FROM ;
          (SELECT CAST(STRTRAN(hr_usrres1,",",".") AS Char(10)) AS c_bnumber, CAST(STRTRAN(hr_usrres6,",",".") AS Numeric(10,2)) AS c_price, CAST(STRTRAN(hr_usrres3,",",".") AS Numeric(10,2)) AS c_prov ;
          FROM histres ;
          LEFT JOIN reservat ON hr_reserid = rs_reserid ;
          WHERE hr_depdate BETWEEN l_dFrom AND l_dTo AND hr_agentid = l_nAddrId AND ISNULL(rs_reserid) ;
          ) c1) c2 ;
     INTO CURSOR cfinh
GO TOP

SELECT * ;
     FROM cfinr ;
     WHERE 1=0 ;
     INTO CURSOR cfin ;
     READWRITE

SCATTER NAME l_oData BLANK
l_oData.c_sprice = cfinr.c_sprice + cfinh.c_sprice
l_oData.c_sprov = cfinr.c_sprov + cfinh.c_sprov
l_oData.c_sowner = cfinr.c_sowner + cfinh.c_sowner
INSERT INTO cfin FROM NAME l_oData

SELECT cres
REPLACE c_pos WITH 1, c_amount WITH cfin.c_sprice, c_descript WITH "Mieteinnahmen"

* Calculate provision percent
l_nProvPerc = ROUND(cfin.c_sprov / cfin.c_sprice,2) * 100

SCATTER NAME l_oData
l_oData.c_pos = 2
l_oData.c_amount = cfin.c_sprov
l_oData.c_descript = "Provision (" + TRANSFORM(l_nProvPerc) + "%)"
INSERT INTO cres FROM NAME l_oData

* Calculate sum amount
SUM c_amount FOR c_pos = 2 TO l_nSum
REPLACE c_sum WITH l_nSum ALL

* Copy results to preproc cursor

SELECT * FROM cres WHERE 1=1 INTO CURSOR preproc

dclose("cres")
dclose("croom")
dclose("cfin")
dclose("cfinr")
dclose("cfinh")

RETURN .T.
ENDPROC
*