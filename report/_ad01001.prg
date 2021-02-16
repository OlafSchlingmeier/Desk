PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "2.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _ad01001
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Daten werden erfasst...."

loSession = CREATEOBJECT("_ad01001")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

WAIT CLEAR

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
ENDPROC
**********
DEFINE CLASS _ad01001 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("astat,histstat,laststay", tcHotCode, tcPath)
     PpCursorCreate()
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc

     PpDo()

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
CREATE CURSOR preproc (addrid n(8), aayear N(4), aadate D(8), aa0amt1 B(2), aa0amt2 B(2), aa0amt3 B(2),;
     aa0amt4 B(2), aa0amt5 B(2), aa0amt6 B(2), aa0amt7 B(2), aa0amt8 B(2), aa0amt9 B(2), aa0amount B(2),;
     aa0ns n(10), aa0nights N(10), aa0res N(10), aa0cxl N(10), aa0vat1 B(2), aa0vat2 B(2), aa0vat3 B(2),;
     aa0vat4 B(2), aa0vat5 B(2), aa0vat6 B(2), aa0vat7 B(2), aa0vat8 B(2), aa0vat9 B(2), lastarrd D(8),;
     lastdepd D(8), lastmark C(3), lastrate B(2), lastratec C(10), lastroom C(10), lastroomty C(4), lastsource C(3))
ENDPROC
*
PROCEDURE PpDo
SELECT aa_addrid as addrid, YEAR(aa_date) as aayear, aa_date as aadate, aa_0amt1 as aa0amt1, aa_0amt2 as aa0amt2, ;
       aa_0amt3 as aa0amt3, aa_0amt4 as aa0amt4, aa_0amt5 as aa0amt5, aa_0amt6 as aa0amt6, aa_0amt7 as aa0amt7, ;
       aa_0amt8 as aa0amt8, aa_0amt9 as aa0amt9, aa_0amount as aa0amount, aa_0ns as aa0ns, aa_0nights as aa0nights, ;
       aa_0res as aa0res, aa_0cxl as aa0cxl, aa_0vat1 as aa0vat1, aa_0vat2 as aa0vat2, aa_0vat3 as aa0vat3, ;
       aa_0vat4 as aa0vat4, aa_0vat5 as aa0vat5, aa_0vat6 as aa0vat6, aa_0vat7 as aa0vat7, aa_0vat8 as aa0vat8, aa_0vat9 as aa0vat9 ;
     FROM astat ;
     WHERE BETWEEN(aa_date, min1, max1) ;
UNION ALL ;
SELECT aa_addrid as addrid, YEAR(aa_date) as aayear, aa_date as aadate, aa_0amt1 as aa0amt1, aa_0amt2 as aa0amt2, ;
       aa_0amt3 as aa0amt3, aa_0amt4 as aa0amt4, aa_0amt5 as aa0amt5, aa_0amt6 as aa0amt6, aa_0amt7 as aa0amt7, ;
       aa_0amt8 as aa0amt8, aa_0amt9 as aa0amt9, aa_0amount as aa0amount, aa_0ns as aa0ns, aa_0nights as aa0nights, ;
       aa_0res as aa0res, aa_0cxl as aa0cxl, aa_0vat1 as aa0vat1, aa_0vat2 as aa0vat2, aa_0vat3 as aa0vat3, ;
       aa_0vat4 as aa0vat4, aa_0vat5 as aa0vat5, aa_0vat6 as aa0vat6, aa_0vat7 as aa0vat7, aa_0vat8 as aa0vat8, aa_0vat9 as aa0vat9 ;
     FROM histstat ;
     WHERE BETWEEN(aa_date, min1, max1) ;
     ORDER BY addrid, aadate ;
     INTO CURSOR aatmp

SELECT preproc
APPEND FROM DBF("aatmp")
SCAN FOR SEEK(addrid, "laststay", "tag1")
     REPLACE lastarrd WITH laststay.ls_arrdat, ;
             lastdepd WITH laststay.ls_depdate, ;
             lastmark WITH laststay.ls_market,;
             lastrate WITH laststay.ls_rate, ;
             lastratec WITH laststay.ls_ratecod, ;
             lastroom WITH laststay.ls_roomnum,;
             lastroomty WITH laststay.ls_roomtyp, ;
             lastsource WITH laststay.ls_source
ENDSCAN
ENDPROC
*