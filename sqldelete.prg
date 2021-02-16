*
PROCEDURE SqlDelete
LPARAMETERS pctable, pcwhere, plforcevfp, plSqlRemote
LOCAL nrec, lctablename
csql = 'DELETE FROM ' + pctable + ' ' + sqlwhere('',pcwhere)
IF odbc() AND NOT plforcevfp
     = sql(csql,'',,'SQLDELETE')
ELSE
     lctablename = STRTRAN(pctable, ["], [])
     nrec = RECNO(lctablename)
     = sql(csql,'',,'SQLDELETE',plSqlRemote)
     FLUSH
     GOTO nrec IN (lctablename)
ENDIF
ENDPROC
*
