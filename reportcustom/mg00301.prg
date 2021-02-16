PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.01"
RETURN tcVersion
ENDPROC
*
PROCEDURE mg00301
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("mg00301")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

PpCusorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
*
PROCEDURE PpCusorCreate
SELECT *, mg_date AS date FROM Manager WHERE 0=1 INTO CURSOR Preproc READWRITE
ENDPROC
**********
DEFINE CLASS mg00301 AS Session

PROCEDURE Init
Ini()
OpenFile(,"Period")
OpenFile(,"Manager")
PpCusorCreate()
ENDPROC

PROCEDURE DoPreproc
PARAMETER taPreProc
LOCAL ldMin1, lcFDate, ldDate, ldDateM, ldDateY, loManager

lcFDate = "EVL(hp_rdate,hp_date)"	&&	"hp_date"
ldMin1 = IIF(min1 = max1, GetRelDate(max1,"-1Y"), min1)
SELECT *, mg_date AS date FROM Manager WHERE INLIST(DTOS(mg_date), DTOS(ldMin1), DTOS(max1)) ORDER BY mg_date INTO CURSOR curPreproc
SELECT Preproc
APPEND FROM DBF("curPreproc")
SCAN
	ldDate = date
	ldDateM = IIF(DLocate("Period","BETWEEN("+SqlCnv(ldDate)+", pe_fromdat, pe_todat)"), Period.pe_fromdat, GetRelDate(ldDate,"",1))
	ldDateY = IIF(DLocate("Period","BETWEEN("+SqlCnv(ldDate)+", pe_fromdat, pe_todat) AND pe_period = 1"), Period.pe_fromdat, DATE(YEAR(ldDate),1,1))

	SELECT hp_date, hp_rdate, hp_amount, hp_vat1+hp_vat2+hp_vat3+hp_vat4+hp_vat5+hp_vat6+hp_vat7+hp_vat8+hp_vat9 AS hp_vat, ;
		CallFunc("MAX(NVL(p1,0),1)",ar_artityp) AS ar_artityp, CallFunc("MAX(NVL(p1,0),1)",ar_main) AS ar_main ;
		FROM histpost ;
		LEFT JOIN article ON ar_artinum = hp_artinum ;
		WHERE hp_reserid > 0 AND (EMPTY(hp_rdate) AND BETWEEN(hp_date, MIN(ldDateM,ldDateY), ldDate) OR ;
			NOT EMPTY(hp_rdate) AND BETWEEN(hp_rdate, MIN(ldDateM,ldDateY), ldDate)) AND ;
			hp_artinum <> 0 AND hp_amount <> 0 AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) ;
		INTO CURSOR curPost

	SELECT SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=1, 1, 0) * hp_amount) AS mg_dayg1, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=2, 1, 0) * hp_amount) AS mg_dayg2, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=3, 1, 0) * hp_amount) AS mg_dayg3, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=4, 1, 0) * hp_amount) AS mg_dayg4, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=5, 1, 0) * hp_amount) AS mg_dayg5, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=6, 1, 0) * hp_amount) AS mg_dayg6, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=7, 1, 0) * hp_amount) AS mg_dayg7, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=8, 1, 0) * hp_amount) AS mg_dayg8, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=9, 1, 0) * hp_amount) AS mg_dayg9, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=1, 1, 0) * hp_vat)    AS mg_dvat1, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=2, 1, 0) * hp_vat)    AS mg_dvat2, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=3, 1, 0) * hp_vat)    AS mg_dvat3, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=4, 1, 0) * hp_vat)    AS mg_dvat4, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=5, 1, 0) * hp_vat)    AS mg_dvat5, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=6, 1, 0) * hp_vat)    AS mg_dvat6, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=7, 1, 0) * hp_vat)    AS mg_dvat7, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=8, 1, 0) * hp_vat)    AS mg_dvat8, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=1 AND ar_main=9, 1, 0) * hp_vat)    AS mg_dvat9, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=2,               1, 0) * hp_amount) AS mg_pdoutd, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=3,               1, 0) * hp_amount) AS mg_internd, ;
		  SUM(IIF(&lcFDate = ldDate AND ar_artityp=4,               1, 0) * hp_amount) AS mg_gcertd, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=1, 1, 0) * hp_amount) AS mg_mong1, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=2, 1, 0) * hp_amount) AS mg_mong2, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=3, 1, 0) * hp_amount) AS mg_mong3, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=4, 1, 0) * hp_amount) AS mg_mong4, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=5, 1, 0) * hp_amount) AS mg_mong5, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=6, 1, 0) * hp_amount) AS mg_mong6, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=7, 1, 0) * hp_amount) AS mg_mong7, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=8, 1, 0) * hp_amount) AS mg_mong8, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=9, 1, 0) * hp_amount) AS mg_mong9, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=1, 1, 0) * hp_vat)    AS mg_mvat1, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=2, 1, 0) * hp_vat)    AS mg_mvat2, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=3, 1, 0) * hp_vat)    AS mg_mvat3, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=4, 1, 0) * hp_vat)    AS mg_mvat4, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=5, 1, 0) * hp_vat)    AS mg_mvat5, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=6, 1, 0) * hp_vat)    AS mg_mvat6, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=7, 1, 0) * hp_vat)    AS mg_mvat7, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=8, 1, 0) * hp_vat)    AS mg_mvat8, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=1 AND ar_main=9, 1, 0) * hp_vat)    AS mg_mvat9, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=2,               1, 0) * hp_amount) AS mg_pdoutm, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=3,               1, 0) * hp_amount) AS mg_internm, ;
		  SUM(IIF(&lcFDate>=ldDateM AND ar_artityp=4,               1, 0) * hp_amount) AS mg_gcertm, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=1, 1, 0) * hp_amount) AS mg_yeag1, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=2, 1, 0) * hp_amount) AS mg_yeag2, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=3, 1, 0) * hp_amount) AS mg_yeag3, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=4, 1, 0) * hp_amount) AS mg_yeag4, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=5, 1, 0) * hp_amount) AS mg_yeag5, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=6, 1, 0) * hp_amount) AS mg_yeag6, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=7, 1, 0) * hp_amount) AS mg_yeag7, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=8, 1, 0) * hp_amount) AS mg_yeag8, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=9, 1, 0) * hp_amount) AS mg_yeag9, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=1, 1, 0) * hp_vat)    AS mg_yvat1, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=2, 1, 0) * hp_vat)    AS mg_yvat2, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=3, 1, 0) * hp_vat)    AS mg_yvat3, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=4, 1, 0) * hp_vat)    AS mg_yvat4, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=5, 1, 0) * hp_vat)    AS mg_yvat5, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=6, 1, 0) * hp_vat)    AS mg_yvat6, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=7, 1, 0) * hp_vat)    AS mg_yvat7, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=8, 1, 0) * hp_vat)    AS mg_yvat8, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=1 AND ar_main=9, 1, 0) * hp_vat)    AS mg_yvat9, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=2,               1, 0) * hp_amount) AS mg_pdouty, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=3,               1, 0) * hp_amount) AS mg_interny, ;
		  SUM(IIF(&lcFDate>=ldDateY AND ar_artityp=4,               1, 0) * hp_amount) AS mg_gcerty ;
		  FROM curPost ;
		  INTO CURSOR curManager
	SCATTER NAME loManager
	SELECT Preproc
	GATHER NAME loManager
ENDSCAN

SELECT * FROM PreProc INTO ARRAY taPreProc
ENDPROC

ENDDEFINE
**********