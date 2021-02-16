PROCEDURE PpVersion
PARAMETER cversion
cversion = "3.03"
RETURN
ENDPROC
*
FUNCTION pp_fbadv
p_checkid = 0
CREATE CURSOR preproc (t_covers N (5), t_hg1 N (12, 3), t_hg2 N (12, 3), m_hg1 N (12, 3), m_hg2 N  ;
       (12, 3), m_covers N (5), t_timznnr N (2), t_deptnr N (1), t_sysdate D (8))
INDEX ON DTOS(t_sysdate) + STR(t_deptnr, 1, 0) + STR(t_timznnr, 2, 0) TO preproc
SELECT 0
USE SHARED \argus\data\article ALIAS ar
SET ORDER TO 1
SELECT 0
USE SHARED \argus\data\vatgrp
SELECT 0
USE SHARED \argus\data\check
SET ORDER TO 1
SELECT 0
USE SHARED \argus\data\table
SET ORDER TO 1
SELECT 0
USE SHARED \argus\data\order
SET ORDER TO 2
p_checkid = 0
GOTO TOP
m_ende = min1
m_beginn = m_ende - DAY(m_ende) + 1
DO WHILE EOF() = .F.
     IF BETWEEN(order.or_sysdate, m_beginn, m_ende)
          SELECT ar
          SEEK (order.or_artid) 
          IF INLIST(ar_mainnr, 1, 2) AND INLIST(ar_arttyp, 1, 3)
               m_vatpct = LOOKUP(vatgrp.vt_vatpct, ar_vatnr, vatgrp.vt_vatnr)
               SELECT preproc
               keyschl = DTOS(m_ende) + STR(order.or_deptnr) + STR(order.or_timznnr, 2, 0)
               SEEK keyschl 
               IF !FOUND()
                    APPEND BLANK
                    REPLACE t_timznnr WITH order.or_timznnr
                    REPLACE t_deptnr WITH order.or_deptnr
                    REPLACE t_sysdate WITH m_ende
               ENDIF
               betrag = (order.or_qty * order.or_prc - ROUND(order.or_prc * order.or_discpct / 100,  ;
                        2)) * 100 / (100 + m_vatpct)
               DO CASE
                    CASE ar.ar_mainnr = 1
                         IF order.or_sysdate = min1
                              REPLACE t_hg1 WITH t_hg1 + betrag
                              REPLACE m_hg1 WITH m_hg1 + betrag
                         ELSE
                              REPLACE m_hg1 WITH m_hg1 + betrag
                         ENDIF
                    CASE ar.ar_mainnr = 2
                         IF order.or_sysdate = min1
                              REPLACE t_hg2 WITH t_hg2 + betrag
                              REPLACE m_hg2 WITH m_hg2 + betrag
                         ELSE
                              REPLACE m_hg2 WITH m_hg2 + betrag
                         ENDIF
               ENDCASE
               IF p_checkid = 0 OR p_checkid <> order.or_chkid
                    SELECT check
                    SEEK (order.or_chkid) 
                    IF FOUND()
                         SELECT table
                         SEEK check.ck_tableid 
                         IF order.or_sysdate = min1
                              REPLACE preproc.t_covers WITH preproc.t_covers + table.tb_covers
                              REPLACE preproc.m_covers WITH preproc.m_covers + table.tb_covers
                         ELSE
                              REPLACE preproc.m_covers WITH preproc.m_covers + table.tb_covers
                         ENDIF
                    ENDIF
                    p_checkid = order.or_chkid
               ENDIF
          ENDIF
     ENDIF
     SELECT order
     SKIP 1
ENDDO
SELECT order
USE
SELECT table
USE
SELECT check
USE
SELECT vatgrp
USE
SELECT ar
USE
RETURN .T.
ENDFUNC
*
*** 
*** ReFox - retrace your steps ... 
***
