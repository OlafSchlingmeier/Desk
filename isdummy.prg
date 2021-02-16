LPARAMETERS lp_cRoomType
 LOCAL l_nRecNo, l_lReturn
 l_nRecNo = RECNO("roomtype")
 l_lReturn = .F.
 IF SEEK(lp_cRoomType, "roomtype", "tag1")
	IF roomtype.rt_group == 3
		IF roomtype.rt_paymstr
			l_lReturn = .T.
		ELSE
			LOCAL l_nArea, l_cOrder
			l_nArea = SELECT()
			SELECT roomtype
			l_cOrder = ORDER()
			SET ORDER TO
			LOCATE FOR rt_paymstr
			IF NOT FOUND()
				l_lReturn = .T.
			ENDIF
			SET ORDER TO l_cOrder
			SELECT(l_nArea)
		ENDIF
	ENDIF
 ENDIF
 GO l_nRecNo IN roomtype
 RETURN l_lReturn
ENDFUNC
*
PROCEDURE GetPayMasterCondition
LPARAMETERS l_cRetStrCondition
 LOCAL l_nArea, l_cOrder
 l_nArea = SELECT()
 SELECT roomtype
 l_cOrder = ORDER()
 SET ORDER TO
 LOCATE FOR rt_paymstr
 IF FOUND()
	l_cRetStrCondition = "rt_paymstr"
 ELSE
	l_cRetStrCondition = "rt_group == 3"
 ENDIF
 SET ORDER TO l_cOrder
 SELECT(l_nArea)
 * l_cRetStrCondition will be retuned by reference.
ENDPROC
*
