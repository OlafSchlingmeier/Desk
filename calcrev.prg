 LPARAMETER pnReserid, pnMainGroup
 LOCAL nrEt
 LOCAL noLdarea
 LOCAL cCurName
 nrEt = 0.00
 noLdarea = SELECT()
 cCurName = SYS(2015)
 IF NOT EMPTY(pnMainGroup) AND BETWEEN(pnMainGroup, 1, 9)
      SELECT SUM(hp_amount) AS hp_result FROM histpost LEFT JOIN article ON hp_artinum = ar_artinum ;
                WHERE hp_reserid = pnReserid AND ar_main = pnMainGroup AND ;
                NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) AND hp_artinum > 0 ;
                INTO CURSOR &cCurName
 ELSE
       SELECT SUM(hp_amount) AS hp_result FROM histpost ;
                WHERE hp_reserid = pnReserid AND ;
                NOT hp_cancel AND NOT hp_split AND hp_artinum > 0 ;
                INTO CURSOR &cCurName
 ENDIF
 IF RECCOUNT()>0
      nrEt = hp_result
 ENDIF
 USE
 SELECT (noLdarea)
 RETURN nrEt
ENDFUNC
*
