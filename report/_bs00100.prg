PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.01"
RETURN tcVersion
ENDPROC
*
PROCEDURE _bs00100
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_bs00100")
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
LOCAL lcSql, lcAddressTable, lcJoinField, llcloseadrmain

IF _screen.oglobal.lusemainserver
     IF NOT USED("adrmain")
          openfile(.F.,"adrmain")
          llcloseadrmain = .T.
     ENDIF
     lcAddressTable = "adrmain"
     lcJoinField = "bb_adid = ad_adid"
ELSE
     lcAddressTable = "address"
     lcJoinField = "bb_addrid = ad_addrid"
ENDIF

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT bb_bbid, bb_addrid, bb_inactiv, bs_points, NVL(pl_lang<<g_langnum>>,'                         ') AS c_vipstat, <<IIF(_screen.oglobal.lusemainserver,"adrmain.*","address.*")>>
     FROM __#SRV.BSACCT#__ 
     LEFT JOIN __#SRV.BSPOST#__ ON bb_bbid = bs_bbid 
     LEFT JOIN <<lcAddressTable>> ON <<lcJoinField>> 
     LEFT JOIN picklist ON pl_label = 'VIPSTATUS' AND pl_numcod = ad_vipstat 
     WHERE 0=1 
ENDTEXT
sqlcursor(lcSql ,"PreProc",,,,,,.T.)

IF llcloseadrmain
     dclose("adrmain")
ENDIF

RETURN .T.
ENDPROC
**********
DEFINE CLASS _bs00100 AS Session

PROCEDURE Init
Ini()
ENDPROC

PROCEDURE DoPreproc
PARAMETER taPreProc
LOCAL lcSql, lcAddressTable, lcJoinField

IF _screen.oglobal.lusemainserver
     lcAddressTable = "adrmain"
     lcJoinField = "bb_adid = ad_adid"
ELSE
     lcAddressTable = "address"
     lcJoinField = "bb_addrid = ad_addrid"
ENDIF

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
SELECT bb_bbid, bb_addrid, bb_inactiv, bs_points, NVL(pl_lang<<g_langnum>>,'                         ') AS c_vipstat, <<lcAddressTable>>.* 
     FROM (
          SELECT bb_bbid, bb_adid, bb_addrid, bb_inactiv, CAST(NVL(SUM(bs_points),0) AS Numeric(12)) AS bs_points
               FROM __#SRV.BSACCT#__
               LEFT JOIN __#SRV.BSPOST#__ ON bb_bbid = bs_bbid AND NOT bs_cancel AND (bs_bspayid = 0 OR bs_bsid = bs_bspayid) AND (bs_vdate = __EMPTY_DATE__ OR bs_vdate >= <<SqlCnv(SysDate(),.T.)>>)
               GROUP BY bb_bbid, bb_addrid, bb_inactiv
          ) c1 
          LEFT JOIN <<lcAddressTable>> ON <<lcJoinField>> 
          LEFT JOIN picklist ON pl_label = 'VIPSTATUS' AND pl_numcod = ad_vipstat 
ENDTEXT

taPreProc[1] = .T.
SqlCursor(lcSql,,,,,,@taPreProc)

RETURN .T.
ENDPROC

ENDDEFINE
**********