PROCEDURE PpVersion
LPARAMETER cversion
*
cversion = "1.00"
RETURN
ENDPROC
*
PROCEDURE _GRAPH02
LOCAL narea, lctable
narea = SELECT()
lctable = _screen.oGlobal.choteldir+"tmp\"+ALLTRIM(winpc())+"\_GRAPH02.DBF"
SELECT * FROM &lctable INTO CURSOR preproc
SELECT (narea)
RETURN
ENDPROC

