PROCEDURE PpVersion
PARAMETER cversion
cversion = "6.00"
RETURN
ENDPROC

PROCEDURE _ad01000
LOCAL i, a
CREATE CURSOR PreProc (addrid N(8), lastarrd D(8), lastdepd D(8), lastrate N(8,2), lastrc C(10), lastroom C(4), ;
      lastrt C(4), aayear N(4), aa0amt1 B, aa0amt2 B, aa0amt3 B, aa0amt4 B, aa0amt5 B, aa0amt6 B, aa0amt7 B, ;
      aa0amt8 B, aa0amt9 B, aa0amount B, aa0ns N(10), aa0nights N(10), aa0res N(10), aa0cxl N(10))

** TESTUMGEBUNG
*SET DATE german
*SET DEFAULT TO D:\aktuell\citadel903\data
*IF !USED('address')
*     USE address share
*endif
*min1 = CTOD("19.01.2004")
*max1 = CTOD("26.01.2004")
*min2 = ""
*min3 = .T.
**

oldselect = SELECT()
IF !USED('laststay')
     openfiledirect(.F., "laststay")
ENDIF
SELECT laststay

oldlsord = ORDER()
SET ORDER TO 1   && LS_ADDRID
IF !USED('astat')
     openfiledirect(.F., "astat")
ENDIF
SELECT astat
oldastord = ORDER()
SET ORDER TO 1
IF !USED('histstat')
     openfiledirect(.F., "histstat")
ENDIF
SELECT histstat
oldhstatord = ORDER()
SET ORDER TO 1
****
SELECT address
GO bott
a = RECNO()
I = 0
SCAN 
      WAIT WINDOW "Datensätze werden erfasst "  + STR((I * 100) / a) + " %" nowait
      IF BETWEEN(CTOD(STR(DAY(ad_birth),2) + "." + STR(MONTH(ad_birth),2) + "." + STR(YEAR(min1),4)), min1, max1) ;
       AND (PADR(min2,3) $ ad_mail1 + "," + ad_mail2 + "," + ad_mail3 + "," + ad_mail4 + "," + ad_mail5 OR EMPTY(min2)) ;
       AND IIF(min3=.T., .T., !EMPTY(ad_street+ad_phone+ad_fax))
           SELECT preproc
           APPEND BLANK
           replace addrid           WITH address.ad_addrid
** Letzter Aufenthalt ermitteln
           SELECT laststay
           SEEK preproc.addrid
           IF FOUND()
                REPLACE preproc.lastarrd      WITH ls_arrdat
                replace preproc.lastdepd      WITH ls_depdate
                replace preproc.lastrate      WITH ls_rate
                replace preproc.lastrc        WITH ls_ratecod
                replace preproc.lastroom      WITH ls_roomnum
                replace preproc.lastrt        WITH ls_roomtyp
           ENDIF
** Umsatzdaten aus ASTAT ermitteln
           SELECT astat
           SEEK preproc.addrid
           IF FOUND()
                DO WHILE aa_addrid = preproc.addrid &&AND aa_date <= g_sysdate
                     replace preproc.aayear WITH YEAR(aa_date)
                     replace preproc.aa0amt1  WITH preproc.aa0amt1 + aa_0amt1
                     replace preproc.aa0amt2  WITH preproc.aa0amt2 + aa_0amt2
                     replace preproc.aa0amt3  WITH preproc.aa0amt3 + aa_0amt3
                     replace preproc.aa0amt4  WITH preproc.aa0amt4 + aa_0amt4
                     replace preproc.aa0amt5  WITH preproc.aa0amt5 + aa_0amt5
                     replace preproc.aa0amt6  WITH preproc.aa0amt6 + aa_0amt6
                     replace preproc.aa0amt7  WITH preproc.aa0amt7 + aa_0amt7
                     replace preproc.aa0amt8  WITH preproc.aa0amt8 + aa_0amt8
                     replace preproc.aa0amt9  WITH preproc.aa0amt9 + aa_0amt9
                     replace preproc.aa0amount     WITH preproc.aa0amount + aa_0amount
                     replace preproc.aa0nights     WITH preproc.aa0nights + aa_0nights
                     replace preproc.aa0ns    WITH preproc.aa0ns + aa_0ns
                     replace preproc.aa0res   WITH preproc.aa0res + aa_0res
                     replace preproc.aa0cxl   WITH preproc.aa0cxl + aa_0cxl
                SKIP
                enddo
           endif
** Umsatzdaten aus Histstat ermitteln
           SELECT histstat
           SEEK preproc.addrid
           IF FOUND()
                DO WHILE aa_addrid = preproc.addrid
                     IF preproc.aayear = YEAR(aa_date) OR EMPTY(preproc.aayear)
                          replace preproc.aayear   WITH YEAR(aa_date)
                          replace preproc.aa0amt1  WITH preproc.aa0amt1 + aa_0amt1
                          replace preproc.aa0amt2  WITH preproc.aa0amt2 + aa_0amt2
                          replace preproc.aa0amt3  WITH preproc.aa0amt3 + aa_0amt3
                          replace preproc.aa0amt4  WITH preproc.aa0amt4 + aa_0amt4
                          replace preproc.aa0amt5  WITH preproc.aa0amt5 + aa_0amt5
                          replace preproc.aa0amt6  WITH preproc.aa0amt6 + aa_0amt6
                          replace preproc.aa0amt7  WITH preproc.aa0amt7 + aa_0amt7
                          replace preproc.aa0amt8  WITH preproc.aa0amt8 + aa_0amt8
                          replace preproc.aa0amt9  WITH preproc.aa0amt9 + aa_0amt9
                          replace preproc.aa0amount     WITH preproc.aa0amount + aa_0amount
                          replace preproc.aa0nights     WITH preproc.aa0nights + aa_0nights
                          replace preproc.aa0ns    WITH preproc.aa0ns + aa_0ns
                          replace preproc.aa0res   WITH preproc.aa0res + aa_0res
                          replace preproc.aa0cxl   WITH preproc.aa0cxl + aa_0cxl
                     ELSE
                          SELECT preproc
                          APPEND BLANK
                          SELECT histstat
                          replace preproc.addrid        WITH address.ad_addrid
                          REPLACE preproc.lastarrd      WITH laststay.ls_arrdat
                          replace preproc.lastdepd      WITH laststay.ls_depdate
                          replace preproc.lastrate      WITH laststay.ls_rate
                          replace preproc.lastrc        WITH laststay.ls_ratecod
                          replace preproc.lastroom      WITH laststay.ls_roomnum
                          replace preproc.lastrt        WITH laststay.ls_roomtyp
                          replace preproc.aa0amt1  WITH preproc.aa0amt1 + aa_0amt1
                          replace preproc.aa0amt2  WITH preproc.aa0amt2 + aa_0amt2
                          replace preproc.aa0amt3  WITH preproc.aa0amt3 + aa_0amt3
                          replace preproc.aa0amt4  WITH preproc.aa0amt4 + aa_0amt4
                          replace preproc.aa0amt5  WITH preproc.aa0amt5 + aa_0amt5
                          replace preproc.aa0amt6  WITH preproc.aa0amt6 + aa_0amt6
                          replace preproc.aa0amt7  WITH preproc.aa0amt7 + aa_0amt7
                          replace preproc.aa0amt8  WITH preproc.aa0amt8 + aa_0amt8
                          replace preproc.aa0amt9  WITH preproc.aa0amt9 + aa_0amt9
                          replace preproc.aa0amount     WITH preproc.aa0amount + aa_0amount
                          replace preproc.aa0nights     WITH preproc.aa0nights + aa_0nights
                          replace preproc.aa0ns    WITH preproc.aa0ns + aa_0ns
                          replace preproc.aa0res   WITH preproc.aa0res + aa_0res
                          replace preproc.aa0cxl   WITH preproc.aa0cxl + aa_0cxl
                     ENDIF
                SKIP
                enddo
           ENDIF
           SELECT preproc
      ENDIF
      I = I + 1
ENDSCAN
WAIT clear
SELECT laststay
SET order to oldlsord
SELECT astat
SET ORDER TO oldastord
SELECT histstat
SET ORDER TO oldhstatord
WAIT clear
SELECT preproc
SELECT = oldselect
RETURN
ENDPROC 

