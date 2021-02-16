 LPARAMETERS lp_nAltId
 PRIVATE l_cRet
 l_cRet = ""
 LOCAL l_nArea, l_cOrder, l_nRecNo, l_cRT
 l_nArea = SELECT()
 SELECT roomtype
 l_cOrder = ORDER()
 SET ORDER TO
 l_nRecNo = RECNO()
 * Following two Locate commands are optimized using index Tag1.
 * Rushmore optimization level for table roomtype: partial.
 * Command 1
 
 l_cRT = "DUM "
 IF .F.&&g_lShips AND NOT EMPTY(lp_nAltId)
 	LOCAL ARRAY l_aRT(1)
 	SELECT rt_roomtyp ;
 		FROM althead ;
 		INNER JOIN roomtype ON al_buildng = rt_buildng ;
 		INNER JOIN rtypedef ON rt_rdid = rd_rdid ;
 		WHERE al_altid = lp_nAltId AND rd_roomtyp = "DUM" ;
 		INTO ARRAY l_aRT
 		IF NOT EMPTY(l_aRT(1))
 			l_cRT = l_aRT(1)
 		ENDIF
 	LOCATE FOR rt_roomtyp = l_cRT AND rt_group = 3
 	IF FOUND()
 	    l_cRet = l_cRT
 	ENDIF
 ELSE
 	LOCATE FOR rt_roomtyp = l_cRT AND rt_group = 3 AND rt_paymstr
 	IF FOUND()
 	    l_cRet = "DUM"
 	ENDIF
 ENDIF
 IF EMPTY(l_cRet)
	* Command 2
	LOCATE FOR rt_roomtyp = "PM  " AND rt_group = 3 AND rt_paymstr
	IF FOUND()
		l_cRet = "PM"
	ENDIF
 ENDIF
 IF EMPTY(l_cRet)
	* Following Locate command is not optimized.
	LOCATE FOR rt_group = 3 AND rt_paymstr
	IF FOUND()
		l_cRet = roomtype.rt_roomtyp
	ENDIF
 ENDIF
 IF EMPTY(l_cRet)
	* Seek using index Tag1.
	IF SEEK("DUM ", "roomtype", "tag1")
		l_cRet = "DUM"
	ENDIF
 ENDIF
 IF EMPTY(l_cRet)
	* Seek using index Tag1.
	IF SEEK("PM  ", "roomtype", "tag1")
		l_cRet = "PM"
	ENDIF
 ENDIF
 IF EMPTY(l_cRet)
	* Following Locate command is not optimized.
	LOCATE FOR rt_group = 3
	IF FOUND()
		l_cRet = roomtype.rt_roomtyp
	ENDIF
 ENDIF
 GO l_nRecNo
 SET ORDER TO l_cOrder
 SELECT(l_nArea)
 RETURN l_cRet
ENDFUNC
*
PROCEDURE GetPayMasterRatecode
LPARAMETERS lp_dArrdate, lp_dDepdate, lp_cRoomtype, lp_cRatecode
 LOCAL l_nArea, l_cOrder, l_cCur, l_cSql
 lp_cRatecode = ""
 l_nArea = SELECT()
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2+8
 SELECT rc_ratecod FROM ratecode 
      WHERE rc_roomtyp = <<sqlcnv(PADR(lp_cRoomtype,4),.T.)>> AND 
      (rc_fromdat <= <<sqlcnv(lp_dArrdate,.T.)>>) AND (rc_todat > <<sqlcnv(lp_dDepdate,.T.)>>)
 ENDTEXT
 l_cCur = sqlcursor(l_cSql)
 IF USED(l_cCur) AND RECCOUNT(l_cCur)>0
      IF dlocate(l_cCur, "rc_ratecod = 'DUM       '")
           lp_cRatecode = &l_cCur..rc_ratecod
      ELSE
           GO TOP IN &l_cCur
           lp_cRatecode = &l_cCur..rc_ratecod
      ENDIF
 ENDIF
 dclose(l_cCur)
 SELECT(l_nArea)
ENDPROC
*