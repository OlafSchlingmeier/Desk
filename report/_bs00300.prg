PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _bs00300
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_bs00300")
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
CREATE CURSOR PreProc (bb_bbid I, bb_addrid N(8), bb_inactiv L, bs_points N(10), ad_city C(30), ;
	ad_company C(50), ad_fname C(20), ad_lname C(30), ad_street C(100), ad_title C(20), ad_vipstat N(2), pl_vipstat C(25))
ENDPROC
**********
DEFINE CLASS _bs00300 AS Session

PROCEDURE Init
Ini()
ENDPROC

PROCEDURE DoPreproc
PARAMETER taPreProc
LOCAL lcSql

IF EMPTY(min1)
	min1 = _screen.ActiveForm.DoEval("EVALUATE(this.MngCtrl.gtAlias + '.bb_bbid')")
ENDIF

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2+8
SELECT bb_bbid, bb_addrid, bb_inactiv, NVL(SUM(bs_points),0) AS bs_points,
	ad_city, ad_company, ad_fname, ad_lname, ad_street, ad_title, ad_vipstat, NVL(pl_lang<<g_langnum>>,'') AS pl_vipstat
	FROM __#SRV.BSACCT#__
	<<IIF(_screen.oGlobal.lUseMainServer, "LEFT JOIN __#SRV.ADRMAIN#__ ON bb_adid = ad_adid", "LEFT JOIN __#SRV.ADDRESS#__ ON bb_addrid = ad_addrid")>>
	LEFT JOIN __#SRV.PICKLIST#__ ON pl_label = 'VIPSTATUS ' AND pl_numcod = ad_vipstat
	LEFT JOIN __#SRV.BSPOST#__ ON bb_bbid = bs_bbid AND NOT bs_cancel AND (bs_bspayid = 0 OR bs_bsid = bs_bspayid) AND (bs_vdate = __EMPTY_DATE__ OR bs_vdate >= <<SqlCnv(SysDate(),.T.)>>)
	WHERE bb_bbid = <<SqlCnv(min1,.T.)>>
	GROUP BY bb_bbid
ENDTEXT

taPreProc[1] = .T.
SqlCursor(lcSql,,,,,,@taPreProc)
ENDPROC

ENDDEFINE
**********