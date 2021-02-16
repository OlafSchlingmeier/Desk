PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.01"
RETURN tcVersion
ENDPROC
*
* Usage:
* Data structure: curMngExt (Building C(3), Date D, c_mangrp N(3), c_lang C(25), c_dayg B(2), c_mong B(2), c_yeag B(2), c_dvat B(6), c_mvat B(6), c_yvat B(6))
* Label:        DLookup('curMngExt', 'Building = '+SqlCnv(Building)+' AND c_mangrp = <1..99> AND Date = '+SqlCnv(min1), 'c_lang')
* Day field:    DLookup('curMngExt', 'Building = '+SqlCnv(Building)+' AND c_mangrp = <1..99> AND Date = '+SqlCnv(min1), 'ROUND(c_dayg-c_dvat,2)')
* Period field: DLookup('curMngExt', 'Building = '+SqlCnv(Building)+' AND c_mangrp = <1..99> AND Date = '+SqlCnv(min1), 'ROUND(c_mong-c_mvat,2)')
* Year field:   DLookup('curMngExt', 'Building = '+SqlCnv(Building)+' AND c_mangrp = <1..99> AND Date = '+SqlCnv(min1), 'ROUND(c_yeag-c_yvat,2)')
*
PROCEDURE mg00101
DO _mg00100

LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing...Extended"

loSession = CREATEOBJECT("mg00101")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

PpCusorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO curMngExt FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
*
PROCEDURE PpCusorCreate
SELECT mg_buildng AS Building, mg_date AS Date, pl_numcod AS c_mangrp, pl_lang1 AS c_lang, mg_dayg1 AS c_dayg, mg_mong1 AS c_mong, mg_yeag1 AS c_yeag, mg_dvat1 AS c_dvat, mg_mvat1 AS c_mvat, mg_yvat1 AS c_yvat ;
     FROM MngBuild, Picklist ;
     WHERE 0=1 ;
     INTO CURSOR curMngExt READWRITE
ENDPROC
**********
DEFINE CLASS mg00101 AS Session

PROCEDURE Init
Ini()
OpenFile(,"Article")
OpenFile(,"Picklist")
OpenFile(,"Manager")
OpenFile(,"MngBuild")
OpenFile(,"Period")
PpCusorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER taPreProc
LOCAL ldMin, ldMax, lcLang, ldDateM1, ldDateY1, ldDateM2, ldDateY2, loManager

ldMin = IIF(Min1=EVL(Max1,{}),GetRelDate(Min1,"-1Y"),Min1)
ldMax = EVL(Max1,Min1)
lcLang = "pl_lang"+g_LangNum

DO CASE
     CASE EMPTY(RptBulding)
          INSERT INTO curMngExt (Date, c_mangrp, c_lang) ;
               SELECT mg_date, pl_numcod, &lcLang FROM Manager, Picklist ;
                    WHERE INLIST(DTOS(mg_date), DTOS(ldMin), DTOS(ldMax)) AND pl_label = "MANGRP    " ;
                    ORDER BY 1,2
     CASE RptBulding = "*"
          INSERT INTO curMngExt (Building, Date, c_mangrp, c_lang) ;
               SELECT mg_buildng, mg_date, pl_numcod, &lcLang FROM MngBuild, Picklist ;
                    WHERE INLIST(DTOS(mg_date), DTOS(ldMin), DTOS(ldMax)) AND pl_label = "MANGRP    " ;
                    ORDER BY 1,2,3
     OTHERWISE
          INSERT INTO curMngExt (Building, Date, c_mangrp, c_lang) ;
               SELECT mg_buildng, mg_date, pl_numcod, &lcLang FROM MngBuild, Picklist ;
                    WHERE INLIST(mg_mngbid, DTOS(ldMin)+RptBulding, DTOS(ldMax)+RptBulding) AND pl_label = "MANGRP    " ;
                    ORDER BY 1,2,3
ENDCASE

IF RECCOUNT("curMngExt") > 0
     ldDateM1 = IIF(DLocate("Period","BETWEEN("+SqlCnv(ldMin)+", pe_fromdat, pe_todat)"), Period.pe_fromdat, GetRelDate(ldMin,"",1))
     ldDateY1 = IIF(DLocate("Period","BETWEEN("+SqlCnv(ldMin)+", pe_fromdat, pe_todat) AND pe_period = 1"), Period.pe_fromdat, DATE(YEAR(ldMin),1,1))
     ldDateM2 = IIF(DLocate("Period","BETWEEN("+SqlCnv(ldMax)+", pe_fromdat, pe_todat)"), Period.pe_fromdat, GetRelDate(ldMax,"",1))
     ldDateY2 = IIF(DLocate("Period","BETWEEN("+SqlCnv(ldMax)+", pe_fromdat, pe_todat) AND pe_period = 1"), Period.pe_fromdat, DATE(YEAR(ldMax),1,1))

     SELECT hp_date, hp_amount, hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9 AS hp_vat, ar_buildng, ar_mangrp ;
          FROM histpost ;
          INNER JOIN article ON ar_artinum = hp_artinum ;
          WHERE hp_reserid > 0 AND (BETWEEN(hp_date, MIN(ldDateM1,ldDateY1), ldMin) OR BETWEEN(hp_date, MIN(ldDateM2,ldDateY2), ldMax)) AND ;
               hp_artinum <> 0 AND hp_amount <> 0 AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND ;
               NOT INLIST(ar_artityp, 2, 3, 4) AND ar_mangrp > 0 AND (EMPTY(ar_buildng) OR EVL(RptBulding,"*") = "*" OR ar_buildng = RptBulding) ;
          INTO CURSOR curPost

     SELECT IIF(EMPTY(RptBulding), RptBulding, ar_buildng) AS Building, ldMin AS Date, ar_mangrp AS c_mangrp, ;
            SUM(IIF(hp_date = ldMin, 1, 0) * hp_amount) AS c_dayg, ;
            SUM(IIF(hp_date = ldMin, 1, 0) * hp_vat)    AS c_dvat, ;
            SUM(IIF(BETWEEN(hp_date, ldDateM1, ldMin), 1, 0) * hp_amount) AS c_mong, ;
            SUM(IIF(BETWEEN(hp_date, ldDateM1, ldMin), 1, 0) * hp_vat)    AS c_mvat, ;
            SUM(IIF(BETWEEN(hp_date, ldDateY1, ldMin), 1, 0) * hp_amount) AS c_yeag, ;
            SUM(IIF(BETWEEN(hp_date, ldDateY1, ldMin), 1, 0) * hp_vat)    AS c_yvat ;
            FROM curPost ;
            GROUP BY 1,2,3 ;
     UNION ;
     SELECT IIF(EMPTY(RptBulding), RptBulding, ar_buildng), ldMax, ar_mangrp, ;
            SUM(IIF(hp_date = ldMax, 1, 0) * hp_amount), ;
            SUM(IIF(hp_date = ldMax, 1, 0) * hp_vat), ;
            SUM(IIF(BETWEEN(hp_date, ldDateM2, ldMax), 1, 0) * hp_amount), ;
            SUM(IIF(BETWEEN(hp_date, ldDateM2, ldMax), 1, 0) * hp_vat), ;
            SUM(IIF(BETWEEN(hp_date, ldDateY2, ldMax), 1, 0) * hp_amount), ;
            SUM(IIF(BETWEEN(hp_date, ldDateY2, ldMax), 1, 0) * hp_vat) ;
            FROM curPost ;
            GROUP BY 1,2,3 ;
            INTO CURSOR curManager
     SCAN
          SCATTER NAME loManager
          SELECT curMngExt
          LOCATE FOR Building = loManager.Building AND Date = loManager.Date AND c_mangrp = loManager.c_mangrp
          GATHER NAME loManager FIELDS EXCEPT Building, Date, c_mangrp
          SELECT curManager
     ENDSCAN
ENDIF

SELECT * FROM curMngExt INTO ARRAY taPreProc
ENDPROC

ENDDEFINE
**********