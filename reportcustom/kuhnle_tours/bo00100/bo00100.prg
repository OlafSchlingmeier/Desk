FUNCTION PpVersion
PARAMETER cversion
cversion = "1.00"
RETURN .T.
ENDFUNC
*
PROCEDURE BO00100
LOCAL l_dOnDate, l_cBoatType
l_dOnDate = IIF(EMPTY(min1), sysdate(), min1)
l_cBoatType = min2


VehicleRent("VehicleRentRM", l_dOnDate, l_dOnDate)

SELECT rm_rmname, rd_roomtyp, rm_lang3, tf_homeport, IIF(EMPTY(tf_port), tf_homeport, tf_port) AS tf_port, rm_status, rm_roomnum, rm_roomtyp, ;
       tf_boatnum, tf_hometyp, tf_porttyp, tf_fromdat, tf_todat, tf_transfer ;
       FROM curroomplan ;
       WHERE NOT rd_roomtyp IN ('SLG','SLK','WLF','WLH','WLW') ;
       ORDER BY tf_port, rm_rmname ;
       INTO CURSOR preproc READWRITE

IF NOT EVL(RptBulding,"*") = "*"
     * Filter on harbor
     DELETE FOR tf_port <> RptBulding
ENDIF
IF NOT EMPTY(l_cBoatType)
     DELETE FOR rd_roomtyp <> l_cBoatType
ENDIF

RETURN .T.
ENDPROC


