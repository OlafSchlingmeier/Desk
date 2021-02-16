*
FUNCTION SqlCursor
LPARAMETERS pcsql, pccursor, plnofilter, pcsqldef, poparam, plremovesign, paresult, plRW, plEB90, plSqlRemote, plSetAnsiOff, plforcelocalsqlcursor
EXTERNAL ARRAY paresult
LOCAL lansichanged, lnArea
lnArea = SELECT()
IF EMPTY(pccursor)
     pccursor = SYS(2015)
ENDIF
IF PCOUNT()>3 AND NOT EMPTY(pcsqldef)
     pcsql = gosqlwrapper.GetSqlStatment(pcsqldef, poparam)
ENDIF
IF plremovesign
     pcsql = STRTRAN(pcsql, ";", "") && Remove ; line breaks, to allow macro execution
ENDIF
IF odbc() AND NOT plforcelocalsqlcursor
     IF USED(pccursor)
          USE IN (pccursor)
     ENDIF
     * Result cursor from SQLEXEC is always READWRITE! But when used, we must first close it, and prevent SQLEXEC
     * to populate same cursor again, and eventualy issue error 1545
     *IF plRW
     *     l_cOrigCurName = pccursor
     *     pccursor = SYS(2015)
     *ENDIF

     * Set default buffering mode for cursors. Needed for sqlcursor function, to prevent that
     * resulting cursor are buffered.
     IF CURSORGETPROP("Buffering",0)<>1
          CURSORSETPROP("Buffering",1,0)
     ENDIF
ELSE
     plnofilter = .T. && Always .T., to prevent RECCOUNT() te return wrong number of records.
     pcsql = pcsql + ' INTO CURSOR ' + pccursor + IIF(plnofilter, ' NOFILTER', '') + IIF(plRW, ' READWRITE', '')
ENDIF
IF plSetAnsiOff
     IF SET("Ansi")="ON"
          SET ANSI OFF
          lansichanged = .T.
     ENDIF
ENDIF
IF plforcelocalsqlcursor
     = sql(pcsql,pccursor,plEB90,"SQLCURSOR",plSqlRemote,plforcelocalsqlcursor)
ELSE
     = sql(pcsql,pccursor,plEB90,"SQLCURSOR",plSqlRemote)
ENDIF
IF lansichanged
     SET ANSI ON
ENDIF
IF PCOUNT()>6 AND paresult
     DIMENSION paresult(1)
     paresult(1) = .F.
     IF USED(pccursor)
          SELECT * FROM (pccursor) INTO ARRAY paresult
          USE IN (pccursor)
     ENDIF
     SELECT(lnArea)
ENDIF
*IF odbc()
     *IF plRW
     *     SELECT * FROM (pccursor) INTO CURSOR (l_cOrigCurName) READWRITE
     *     dclose(pccursor)
     *     pccursor = l_cOrigCurName
     *ENDIF
*ENDIF
RETURN pccursor
ENDFUNC
*