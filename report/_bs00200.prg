PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.01"
RETURN tcVersion
ENDPROC
*
PROCEDURE _bs00200
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_bs00200")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF

WAIT CLEAR
ENDPROC
*
PROCEDURE PpCursorCreate
CREATE CURSOR PreProc (bs_date T, bs_sysdate D,bs_billnum C(10), bs_bspayid I, bs_qty N(8), bs_appl N(1), bs_type N(1), bs_artinum I, bs_descrip C(100), ;
	bs_amount Y, bs_points N(10), bs_vdate D, bs_userid C(10), bs_waitnr N(3), bs_cancel L, wt_name C(30), ar_plu I)
ENDPROC
**********
DEFINE CLASS _bs00200 AS Session

PROCEDURE Init
Ini()
ENDPROC

PROCEDURE DoPreproc
PARAMETER taPreProc
LOCAL lcSql, lcBsPost, lcWaiterArg, lcArticleArg, lcArticleWel

DO CASE
	CASE NOT EMPTY(min1)
	CASE _screen.ActiveForm.cFormLabel = "BMSMANAGER"
		min1 = _screen.ActiveForm.DoEval("EVALUATE(this.MngCtrl.gtAlias+'.bb_bbid')")
	CASE _screen.ActiveForm.cFormLabel = "BMSBOOKING"
		min1 = _screen.ActiveForm.DoEval("curBsacct.bb_bbid")
	OTHERWISE
ENDCASE
lcSql = "SELECT * FROM __#SRV.BSPOST#__ WHERE bs_bbid = " + SqlCnv(min1,.T.) + " AND (bs_bspayid = 0 OR bs_bspayid = bs_bsid)"
IF min2
	lcSql = lcSql + " AND NOT bs_cancel AND (bs_vdate = __EMPTY_DATE__ OR bs_vdate >= "+SqlCnv(SysDate()) + ")"
ENDIF
lcBsPost = SqlCursor(lcSql)

lcWaiterArg = SqlCursor("SELECT * FROM __#ARG.WAITER#__")
lcArticleArg = SqlCursor("SELECT * FROM __#ARG.ARTICLE#__")
lcArticleWel = SqlCursor("SELECT * FROM __#WEL.ARTICLE#__")

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT bs_date, bs_sysdate, bs_billnum, bs_bspayid, bs_qty, bs_appl, bs_type, bs_artinum, bs_descrip, bs_amount, bs_points, bs_vdate, bs_userid, bs_waitnr, bs_cancel,
	CAST(NVL(<<IIF(USED(lcWaiterArg), "wt_name","TRANSFORM(bs_waitnr)")>>,'') AS Char(30)) AS wt_name,
	CAST(NVL(ICASE(bs_appl = 2, <<IIF(USED(lcArticleArg), lcArticleArg+".ar_plu","bs_artinum")>>,
		  bs_appl = 3, <<IIF(USED(lcArticleWel), lcArticleWel+".ar_plu","bs_artinum")>>, bs_artinum),0) AS Integer) AS ar_plu
	FROM <<lcBsPost>>
	<<IIF(USED(lcWaiterArg),"LEFT JOIN "+lcWaiterArg+" ON wt_waitnr = bs_waitnr","")>>
	<<IIF(USED(lcArticleArg),"LEFT JOIN "+lcArticleArg+" ON "+lcArticleArg+".ar_artid = bs_artinum","")>>
	<<IIF(USED(lcArticleWel),"LEFT JOIN "+lcArticleWel+" ON "+lcArticleWel+".ar_artid = bs_artinum","")>>
ENDTEXT

taPreProc[1] = .T.
SqlCursor(lcSql,,,,,,@taPreProc)
ENDPROC

ENDDEFINE
**********