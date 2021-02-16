PROCEDURE PpVersion
PARAMETER cversion
cversion = "1.15"
RETURN
ENDPROC

PROCEDURE _vo00101
LOCAL l_dForDay, l_lArgusDatabaseAvailable, l_oData, l_nArgusPartAmount
*l_dForDay = {^2008-5-20}
l_dforday = min1
oldselect = SELECT()
IF !used('voucher.dbf')
     openfiledirect(.F., "voucher")
ENDIF

l_lArgusDatabaseAvailable = NOT EMPTY(_screen.oGlobal.oParam2.pa_argusdr) AND _screen.oGlobal.oParam.pa_argus

IF l_lArgusDatabaseAvailable

     USE (ADDBS(ALLTRIM(_screen.oGlobal.oParam2.pa_argusdr)) + "hpayment") SHARED IN 0 ALIAS AOhpayment AGAIN

     * Get data from Desk
     SELECT vo_number, vo_addrid, vo_amount, vo_artinum, vo_created, vo_date, vo_descrip, vo_expdate, ;
                vo_unused, vo_userid, ;
                ad_company, ad_title, ad_fname, ad_lname, ad_zip, ad_city, ;
                l_dForDay AS onday, ; 
                SUM(hp_amount) as dayamount, ;
                COUNT(*) AS hpreccount ;
                FROM histpost ;
                INNER JOIN voucher ON hp_voucnum = vo_number ;
                LEFT JOIN address ON vo_addrid = ad_addrid ;
                WHERE BETWEEN(hp_date, vo_date, l_dForDay) AND hp_userid <> 'POSZ2     ' ;
                GROUP BY vo_number, vo_addrid, vo_amount, vo_artinum, vo_created, vo_date, vo_descrip, vo_expdate, ;
                          vo_unused, vo_userid ;
                ORDER BY vo_date ;
                INTO CURSOR curhp READWRITE

     * Get data from Argus
     SELECT vo_number, vo_addrid, vo_amount, vo_artinum, vo_created, vo_date, vo_descrip, vo_expdate, ;
           vo_unused, vo_userid, ;
           ad_company, ad_title, ad_fname, ad_lname, ad_zip, ad_city, ;
           l_dForDay AS onday, ; 
           CAST(vo_amount-SUM(py_amt) AS b(2)) AS dayamount, ;
           COUNT(*) AS hpreccount ;
           FROM AOhpayment;
           INNER JOIN voucher ON INT(VAL(LEFT(ALLTRIM(SUBSTR(py_text,AT(":",py_text)+1)), LEN(ALLTRIM(SUBSTR(py_text,AT(":",py_text)+1)))-2))) = vo_number ;
           LEFT JOIN address ON vo_addrid = ad_addrid ;
           WHERE BETWEEN(py_sysdate, vo_date, l_dForDay) AND LEFT(py_text,3) = 'V#:' ;
           GROUP BY vo_number, vo_addrid, vo_amount, vo_artinum, vo_created, vo_date, vo_descrip, vo_expdate, ;
                     vo_unused, vo_userid ;
           ORDER BY vo_date ;
           INTO CURSOR c1

     * Merge data from Argus with data from Desk
     SCAN ALL
          SELECT curhp
          LOCATE FOR vo_number = c1.vo_number
          IF FOUND()
               l_nArgusPartAmount = c1.vo_amount- c1.dayamount
               REPLACE dayamount WITH dayamount - l_nArgusPartAmount IN curhp
          ELSE
               SELECT c1
               SCATTER NAME l_oData MEMO
               INSERT INTO curhp FROM NAME l_oData
          ENDIF
     ENDSCAN
     USE

     DELETE FROM curhp WHERE dayamount <= 0

     dclose("AOhpayment")

ELSE
     SELECT vo_number, vo_addrid, vo_amount, vo_artinum, vo_created, vo_date, vo_descrip, vo_expdate, ;
                vo_unused, vo_userid, ;
                ad_company, ad_title, ad_fname, ad_lname, ad_zip, ad_city, ;
                l_dForDay AS onday, ; 
                SUM(hp_amount) AS dayamount, ;
                COUNT(*) AS hpreccount ;
                FROM histpost ;
                INNER JOIN voucher ON hp_voucnum = vo_number ;
                LEFT JOIN address ON vo_addrid = ad_addrid ;
                WHERE BETWEEN(hp_date, vo_date, l_dForDay) ;
                GROUP BY vo_number, vo_addrid, vo_amount, vo_artinum, vo_created, vo_date, vo_descrip, vo_expdate, ;
                          vo_unused, vo_userid ;
                HAVING dayamount > 0 ;
                ORDER BY vo_date ;
                INTO CURSOR curhp
ENDIF

*BROWSE LAST
SELECT(oldselect)
RETURN .T.
ENDPROC