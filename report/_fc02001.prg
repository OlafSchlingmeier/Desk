#INCLUDE "include\constdefines.h"
*
PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.10"
RETURN tcVersion
ENDPROC
*
PROCEDURE _fc02001
LOCAL o AS cWebStats OF _fc02001.prg, l_cMode, l_dFrom, l_dTo, l_oData

l_dFrom = min1
l_dTo = max1
l_nMode = min2
l_lNeto = min3

o = CREATEOBJECT("cWebStats")
o.Do(l_dFrom, l_dTo, l_nMode, l_lNeto)

* We must respect TAG1 index order in curresult cursor

SELECT * FROM curresult WHERE 1=0 INTO CURSOR ctemp READWRITE

SELECT curresult
SCAN ALL
     SCATTER NAME l_oData MEMO
     INSERT INTO ctemp FROM NAME l_oData
ENDSCAN

SELECT * FROM ctemp WHERE 1=1 INTO CURSOR preproc NOFILTER

USE IN ctemp

SELECT preproc

RETURN .T.
ENDPROC
*
DEFINE CLASS cWebStats AS Custom
*
****************************************************
#IF .F. && Make sure this is false, otherwise error
     *-- Define This for IntelliSense use
     LOCAL this AS cWebStats OF webstats.prg
#ENDIF
****************************************************
*
dFrom = {}
dTo = {}
nDays = 0
dSumValuesDummyDate = {^2500-1-1} && Dummy date used to filter cumulative values, shouldn't be displayed on report, 
                                  && used to show cumulative records on end of cursor
cDefaultSourceCode = ""
nMode = 0 && 0 -> Only logis, 1 -> Revenue arrangment - all posts, 2 -> Logis + breakfast
lNeto = .F.
cReservationsFilter = ""
*
******************************************************************************************
*
* Main entry point. Receives filter parameters, results are in curresult cursor
*
* lp_dFrom  Date     From which date to get reservations
* lp_dTo    Date     To which date to get reservations
* lp_nMode  Numeric  How to display amounts. See in nMode propery declaration for details
* lp_lNeto  Logical  When true show amounts as neto values
*
******************************************************************************************
*
PROCEDURE Do
LPARAMETERS lp_dFrom, lp_dTo, lp_nMode, lp_lNeto

this.Initialize(lp_dFrom, lp_dTo, lp_nMode, lp_lNeto)

this.GetSourceCodes()

this.CreateResultCursor()

this.InitializeResultCursor()

this.GetWebCountData()

this.GetReservationsData()

this.GetRevenue()

this.CalculateCumulativeValues()

this.CalculateIBE()

this.CalculateConversionRate()

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Store received parameters in object properties for easy access, and set default values
*
* lp_dFrom  Date
* lp_dTo    Date
* lp_nMode  Numeric
* lp_lNeto  Logical
*
******************************************************************************************
*
PROCEDURE Initialize
LPARAMETERS lp_dFrom, lp_dTo, lp_nMode, lp_lNeto

this.dFrom = IIF(EMPTY(lp_dFrom), sysdate(), lp_dFrom)
this.dTo = IIF(EMPTY(lp_dTo), sysdate() + 2, lp_dTo)
this.nDays = MAX(this.dTo - this.dFrom + 1, 1)
this.cDefaultSourceCode = PADR(UPPER(readini(FULLPATH(INI_FILE), [extreser], [defaultsourcecode], [])),3)
IF NOT EMPTY(lp_nMode)
     this.nMode = lp_nMode
ENDIF
this.lNeto = lp_lNeto

TEXT TO this.cReservationsFilter TEXTMERGE NOSHOW PRETEXT 15
NOT INLIST(rs_status, 'OUT', 'CXL', 'NS', 'LST') 
<<IIF(param.pa_optidef,""," AND rs_status <> 'OPT'")>>
<<IIF(param.pa_tentdef,""," AND rs_status <> 'TEN'")>>
ENDTEXT

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Read reservation source codes from picklist table, marked as "Internet" source codes, 
* and use those to populate result cursor
*
******************************************************************************************
*
PROCEDURE GetSourceCodes

SELECT pl_charcod, pl_lang3 AS pl_lang, '2' AS c_order ;
     FROM picklist ;
     WHERE pl_label = 'SOURCE' AND pl_numcod = 1 ;
     INTO CURSOR curpl READWRITE

INDEX ON c_order + pl_lang TAG TAG1

IF NOT EMPTY(this.cDefaultSourceCode)
     LOCATE FOR pl_charcod = this.cDefaultSourceCode
     IF FOUND()
          REPLACE c_order WITH '1', pl_lang WITH "Direkt"
     ENDIF
ENDIF

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Here is defined structure of result cursor
*
******************************************************************************************
*
PROCEDURE CreateResultCursor

SELECT {} AS pp_date, ;
     00000000 AS pp_websum, ;
     '   ' AS pp_source, '                         ' AS pp_sdescr, ;
     00000000 AS pp_callsws, ;
     00000000 AS pp_callswb, ;
     000.00 AS pp_userwb, ;
     00000000 AS pp_resqty, ;
     000.00 AS pp_conrate, ;
     00000000 AS pp_resnigh, ;
     0000000000.00 AS pp_rate, ;
     0000000000.00 AS pp_ratevat, ;
     0000000000.00 AS pp_ratesum, ;
     0000000000.00 AS pp_ratesuv, ;
     ' ' AS pp_order ;
     FROM param WHERE 0=1 INTO CURSOR curresult READWRITE

INDEX ON DTOS(pp_date) + pp_order + pp_sdescr TAG TAG1

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* For every date, and for every source code add 1 record. At end add records for 
* dummy date (this.dSumValuesDummyDate), for saving cumulative values.
*
******************************************************************************************
*
PROCEDURE InitializeResultCursor
LOCAL i, l_oData

SELECT curpl
SCAN ALL
     SELECT curresult
     FOR i = 1 TO this.nDays + 1
          SCATTER NAME l_oData MEMO BLANK
          IF i = this.nDays + 1
               l_oData.pp_date = this.dSumValuesDummyDate
          ELSE
               l_oData.pp_date = this.dFrom + i - 1
          ENDIF
          l_oData.pp_source = curpl.pl_charcod
          DO CASE
               CASE l_oData.pp_date = this.dSumValuesDummyDate AND curpl.pl_charcod = this.cDefaultSourceCode && Cumulative records marker
                    l_oData.pp_order = '1'
               CASE curpl.pl_charcod = this.cDefaultSourceCode
                    l_oData.pp_order = '2'
               OTHERWISE
                    l_oData.pp_order = '3'
          ENDCASE
          l_oData.pp_sdescr = curpl.pl_lang
          INSERT INTO curresult FROM NAME l_oData
     ENDFOR
ENDSCAN

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Get data from extstat table, statistics from which search engine or booking provider
* reservations are created.
*
******************************************************************************************
*
PROCEDURE GetWebCountData
LOCAL l_dCurrentDate, l_lMustSave, l_nDefaultSourceCodeSum

SELECT * FROM extstat WHERE ex_date BETWEEN this.dFrom AND this.dTo ORDER BY ex_date INTO CURSOR curexts
l_dCurrentDate = {}
SCAN ALL
     l_lMustSave = .F.
     IF l_dCurrentDate <> curexts.ex_date
          l_dCurrentDate = curexts.ex_date
          l_nDefaultSourceCodeSum = 0
     ENDIF
     SELECT curresult
     LOCATE FOR pp_date = curexts.ex_date AND pp_source = curexts.ex_source
     IF FOUND()
          REPLACE pp_callsws WITH curexts.ex_website, ;
                  pp_callswb WITH curexts.ex_webbook
          l_nDefaultSourceCodeSum = l_nDefaultSourceCodeSum + curexts.ex_website
     ENDIF
     SELECT curexts
     SKIP 1
     IF ex_date <> l_dCurrentDate OR EOF()
          l_lMustSave = .T.
     ENDIF
     SKIP -1
     IF l_lMustSave
          SELECT curresult
          LOCATE FOR pp_date = curexts.ex_date AND pp_source = this.cDefaultSourceCode
          IF FOUND()
               REPLACE pp_websum WITH l_nDefaultSourceCodeSum
          ENDIF
     ENDIF
ENDSCAN

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Calculate "IBE"
*
******************************************************************************************
*
PROCEDURE CalculateIBE
LOCAL l_nIBE

SELECT curresult
SCAN ALL
     IF NOT EMPTY(pp_callsws) AND NOT EMPTY(pp_callswb)
          l_nIBE = ROUND((pp_callswb / pp_callsws) * 100,2)
          REPLACE pp_userwb WITH l_nIBE
     ENDIF
ENDSCAN

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Get reservations data
*
******************************************************************************************
*
PROCEDURE GetReservationsData
LOCAL l_cReservationFilterMacro

l_cReservationFilterMacro = this.cReservationsFilter

SELECT rs_created, rs_source, CAST(SUM(rs_depdate - rs_arrdate) AS Integer) AS c_nights, COUNT(*) AS c_count ;
     FROM reservat ;
     WHERE rs_created BETWEEN this.dFrom AND this.dTo AND &l_cReservationFilterMacro ;
     GROUP BY 1, 2 ;
     ORDER BY 1 ;
     INTO CURSOR curressrc

SCAN ALL
     SELECT curresult
     LOCATE FOR pp_date = curressrc.rs_created AND pp_source = curressrc.rs_source
     IF FOUND()
          REPLACE pp_resqty   WITH curressrc.c_count, ;
                  pp_resnigh  WITH curressrc.c_nights
     ENDIF
ENDSCAN

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Calculate conversion rate
*
******************************************************************************************
*
PROCEDURE CalculateConversionRate
LOCAL l_nCRate

SELECT curresult
SCAN ALL
     IF NOT EMPTY(pp_callsws) AND NOT EMPTY(pp_callswb)
          l_nCRate = ROUND((pp_resqty / pp_callswb) * 100,2)
          REPLACE pp_conrate WITH l_nCRate
     ENDIF
ENDSCAN

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Calculate cumulative values
*
******************************************************************************************
*
PROCEDURE CalculateCumulativeValues

SELECT pp_source, ;
     SUM(pp_websum) AS websumc, ;
     SUM(pp_callsws) AS callswsc, ;
     SUM(pp_callswb) AS callswbc, ;
     SUM(pp_resqty) AS resqtyc, ;
     SUM(pp_resnigh) AS resnightsc, ;
     SUM(pp_ratesum) AS ratesumc, ;
     SUM(pp_ratesuv) AS ratesumvatc ;
     FROM curresult ;
     WHERE 1=1 ;
     GROUP BY 1 ;
     INTO CURSOR curcval

SELECT curresult
SCAN FOR pp_date = this.dSumValuesDummyDate
     SELECT curcval
     LOCATE FOR pp_source = curresult.pp_source
     IF FOUND()
          REPLACE pp_websum     WITH curcval.websumc, ;
                  pp_callsws    WITH curcval.callswsc, ;
                  pp_callswb    WITH curcval.callswbc, ;
                  pp_resqty     WITH curcval.resqtyc, ;
                  pp_resnigh    WITH curcval.resnightsc, ;
                  pp_ratesum    WITH curcval.ratesumc, ;
                  pp_ratesuv    WITH curcval.ratesumvatc ;
                  IN curresult
     ENDIF
ENDSCAN

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Get revenue data. Data is calculated from post, histpost or ressplit table.
*
******************************************************************************************
*
PROCEDURE GetRevenue
LOCAL l_cVatnumMacro, l_nRevSum, l_nVatSum, l_cReservationFilterMacro, lcArchScripts

******************** Prepare SQLs for archive ******************************************************
*
TEXT TO lcArchScripts TEXTMERGE NOSHOW PRETEXT 15
SELECT histres.* FROM histres
     WHERE BETWEEN(hr_created, <<SqlCnvB(this.dFrom)>>, <<SqlCnvB(this.dTo)>>);

SELECT histpost.* FROM histpost
     INNER JOIN histres ON hr_reserid = hp_origid
     WHERE BETWEEN(hr_created, <<SqlCnvB(this.dFrom)>>, <<SqlCnvB(this.dTo)>>);
ENDTEXT
ProcArchive("RestoreArchive", "histres,histpost", lcArchScripts, this.dFrom)
*
****************************************************************************************************

l_cVatnumMacro = IIF(param.pa_exclvat,"rl_price*rl_units*pl_numval/100","rl_price*rl_units*pl_numval/(100+pl_numval)")
l_cReservationFilterMacro = this.cReservationsFilter

SELECT 0 AS src, ps_postid, rs1.rs_created, rs1.rs_source, rs1.rs_reserid, rs1.rs_rsid, ;
       NVL(ar_main,0) AS ar_main, NVL(ar_sub,0) AS ar_sub, ;
       ps_date, ps_amount, ;
       ps_vat0, ps_vat1, ;
       ps_vat2, ps_vat3, ;
       ps_vat4, ps_vat5, ;
       ps_vat6, ps_vat7, ;
       ps_vat8, ps_vat9 ;
     FROM reservat rs1 ;
     INNER JOIN post ON ps_origid = rs1.rs_reserid AND NOT EMPTY(ps_artinum) AND NOT EMPTY(ps_amount) AND NOT ps_cancel AND (EMPTY(ps_ratecod) OR ps_split) ;
     INNER JOIN article ON ps_artinum = ar_artinum AND ar_artityp = 1 ;
     WHERE rs1.rs_created BETWEEN this.dFrom AND this.dTo ;
UNION ALL ;
SELECT 1, hp_postid, hr_created, hr_source, hr_reserid, hr_rsid, ;
       NVL(ar_main,0), NVL(ar_sub,0), ;
       hp_date, hp_amount, ;
       hp_vat0, hp_vat1, ;
       hp_vat2, hp_vat3, ;
       hp_vat4, hp_vat5, ;
       hp_vat6, hp_vat7, ;
       hp_vat8, hp_vat9 ;
     FROM histres hr1 ;
     INNER JOIN histpost ON hr1.hr_reserid = hp_origid AND NOT EMPTY(hp_artinum) AND NOT EMPTY(hp_amount) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
     INNER JOIN article ON hp_artinum = ar_artinum AND ar_artityp = 1 ;
     LEFT JOIN post ON hp_postid = ps_postid ;
     WHERE hr_created BETWEEN this.dFrom AND this.dTo AND ISNULL(ps_postid) ;
UNION ALL ;
SELECT 2, rl_rlid, rs_created, rs_source, rs_reserid, rs_rsid, ;
       NVL(ar_main,0), NVL(ar_sub,0), ;
       rl_date, rl_price*rl_units, ;
       IIF(NVL(ar_vat,0)=0,&l_cVatnumMacro,0), IIF(NVL(ar_vat,0)=1,&l_cVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=2,&l_cVatnumMacro,0), IIF(NVL(ar_vat,0)=3,&l_cVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=4,&l_cVatnumMacro,0), IIF(NVL(ar_vat,0)=5,&l_cVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=6,&l_cVatnumMacro,0), IIF(NVL(ar_vat,0)=7,&l_cVatnumMacro,0), ;
       IIF(NVL(ar_vat,0)=8,&l_cVatnumMacro,0), IIF(NVL(ar_vat,0)=9,&l_cVatnumMacro,0) ;
     FROM reservat ;
     INNER JOIN ressplit ON rs_rsid = rl_rsid AND rl_date > rs_ratedat AND NOT EMPTY(rl_price*rl_units) ;
     LEFT JOIN article ON rl_artinum = ar_artinum AND ar_artityp = 1 ;
     LEFT JOIN picklist ON pl_label = [VATGROUP] AND pl_numcod = ar_vat ;
     WHERE rs_created BETWEEN this.dFrom AND this.dTo AND ;
          &l_cReservationFilterMacro ;
     ORDER BY 1,2 ;
     INTO CURSOR curposts

SCAN ALL
     SELECT curresult
     LOCATE FOR pp_date = curposts.rs_created AND pp_source = curposts.rs_source
     IF FOUND()
          STORE 0 TO l_nRevSum, l_nVatSum
          DO CASE
               CASE this.nMode = 1 && Revenue arrangment - all posts
                    this.GetRevenueGetSum(@l_nRevSum, @l_nVatSum)
               CASE this.nMode = 2 && Logis + breakfast
                    IF INLIST(curposts.ar_main, 1, 2)
                         this.GetRevenueGetSum(@l_nRevSum, @l_nVatSum)
                    ENDIF
               OTHERWISE && Only logis
                    IF curposts.ar_main = 1
                         this.GetRevenueGetSum(@l_nRevSum, @l_nVatSum)
                    ENDIF
          ENDCASE

          REPLACE pp_rate       WITH ROUND(IIF(curresult.pp_resnigh=0,0,l_nRevSum/curresult.pp_resnigh),2), ;
                  pp_ratevat    WITH ROUND(IIF(curresult.pp_resnigh=0,0,l_nVatSum/curresult.pp_resnigh),2), ;
                  pp_ratesum    WITH l_nRevSum, ;
                  pp_ratesuv    WITH l_nVatSum

     ENDIF
ENDSCAN

******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres,histpost")
*
****************************************************************************************************

RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Helper function for GetRevenue, calculates cumulative values when iterating through
* curposts cursor.
*
******************************************************************************************
*
PROCEDURE GetRevenueGetSum
LPARAMETERS lp_nRevSum, lp_nVatSum
LOCAL l_nVatAmount
l_nVatAmount = this.GetRevenueGetVat()
lp_nRevSum = curresult.pp_ratesum + curposts.ps_amount - IIF(this.lNeto,l_nVatAmount,0)
lp_nVatSum = curresult.pp_ratesuv + l_nVatAmount
RETURN .T.
ENDPROC
*
******************************************************************************************
*
* Helper function for GetRevenueGetSum, calculates cumulative VAT values.
*
******************************************************************************************
*
PROCEDURE GetRevenueGetVat
RETURN curposts.ps_vat1 + curposts.ps_vat2 + curposts.ps_vat3 + curposts.ps_vat4 + curposts.ps_vat5 + ;
       curposts.ps_vat6 + curposts.ps_vat7 + curposts.ps_vat8 + curposts.ps_vat9
ENDPROC
*
ENDDEFINE
*