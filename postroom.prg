*
FUNCTION PostRoom
 PRIVATE ctProom
 PRIVATE cpOstroom
 ctProom = ""
 DO CASE
      CASE _screen.oGlobal.oParam.pa_postpos
           ntPposition = RAT("TOUCHPOSROOM:", reServat.rs_changes)
           IF (ntPposition>0)
                ctProom = SUBSTR(reServat.rs_changes, ntPposition+13, 1)
           ENDIF
           cpOstroom = PADR(ALLTRIM(reServat.rs_roomnum)+ctProom, 4)
      OTHERWISE
           cpOstroom = PADR(ALLTRIM(reServat.rs_roomnum)+ctProom, 4)
 ENDCASE
 RETURN cpOstroom
ENDFUNC
*
