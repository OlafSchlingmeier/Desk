PROCEDURE Denial
 PARAMETER pdArrival, pdDeparture, pcRoomtype
	 LOCAL ARRAY lArray(3)
	 lArray(1)=pdArrival
	 lArray(2)=pdDeparture
	 lArray(3)=pcRoomtype
	 doform('denial','forms\denial','',.F.,@lArray)
	 RETURN
ENDPROC