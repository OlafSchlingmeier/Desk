PROCEDURE CheckIn
LPARAMETERS lp_oCheckReservat, lp_lOnlySelected, lp_cMessage, lp_nReserId
LOCAL lnRecNo, l_lEntireGroup, l_lCheckinPaymaster, l_nPMReserId, l_lSuccess, l_oCheckReservat
*IF PCOUNT() > 0
*	GOTO lp_nResRecNo
*ENDIF
IF NOT EMPTY(lp_nReserId)
	= SEEK(lp_nReserId, "reservat", "tag1")
ENDIF
l_oCheckReservat = IIF(VARTYPE(lp_oCheckReservat) = "O", lp_oCheckReservat, CREATEOBJECT("Checkreservat"))
IF reservat.rs_roomlst AND NOT param.pa_nogroup AND NOT param2.pa_gsknotg AND NOT lp_lOnlySelected
	l_nPMReserId = l_oCheckReservat.GroupGetPaymaster()
	LOCAL ARRAY l_aDialog(1,8)
	l_aDialog(1,1) = "groupchoice"
	l_aDialog(1,2) = GetLangText("RESERVAT","TXT_ONLY_SELECTED")+";"+GetLangText("RESERVAT","TXT_ENTIRE_GROUP")
	l_aDialog(1,3) = "1"
	l_aDialog(1,4) = "@R"
	IF l_nPMReserId <> reservat.rs_reserid
		DIMENSION l_aDialog(2,8)
		l_aDialog(2,1) = "checkinpaymaster"
		l_aDialog(2,2) = GetLangText("RESERVAT","TXT_CHECKIN_PAYMASTER")
		l_aDialog(2,3) = ".T."
		l_aDialog(2,4) = "@C"
	ENDIF
	IF Dialog(GetLangText("RESERVAT","TXT_GROUP_CHECKIN"), GetLangText("RESERVAT","TXT_CIGROUP"), @l_aDialog)
		l_lEntireGroup = (l_aDialog(1,8) = 2)
		l_lCheckinPaymaster = (l_nPMReserId = reservat.rs_reserid) OR l_aDialog(2,8)
	ELSE
		RETURN l_lSuccess
	ENDIF
ENDIF

nrSrec = RECNO("Reservat")
IF l_lEntireGroup
	ncUrid = reServat.rs_reserid
	nrSord = ORDER("Reservat")
	ndOne = 0
	nrEcs = 0
	SELECT reservat
	SET ORDER IN reServat TO 1
	= dlOcate('Reservat','rs_reserid >= '+sqLcnv(INT(ncUrid))+ ;
			' and rs_reserid < '+sqLcnv(INT(ncUrid)+1))
	SCAN REST WHILE INT(reServat.rs_reserid)==INT(ncUrid) .AND. .NOT. EOF("Reservat")
		WAIT WINDOW NOWAIT LTRIM(STR(nrEcs+1))+"..."
		IF .NOT. INLIST(reServat.rs_status, "CXL", "NS")  ;
				.AND. reServat.rs_arrdate==sySdate() .AND.  ;
				EMPTY(reServat.rs_in) .AND.  ;
				EMPTY(reServat.rs_out) .AND.  ;
				.NOT. EMPTY(reServat.rs_roomnum) .AND. reServat.rs_rooms==1 .AND. ;
				((reservat.rs_reserid <> l_nPMReserId) .OR. l_lCheckinPaymaster)
			lnRecNo= RECNO('reservat')
			DO rsCheckin IN Reserv2 WITH reServat.rs_reserid, .T.
			GO lnRecNo IN reservat
			IF NOT EMPTY(reServat.rs_in)
				ndOne = ndOne+1
			ENDIF
		ENDIF
		nrEcs = nrEcs+1
		WAIT CLEAR
		SELECT reservat
	ENDSCAN
	SET ORDER IN "Reservat" TO nrSord
	GOTO nrSrec IN "Reservat"
	l_lSuccess = .T.
	IF !g_newversionactive
		g_Refreshall = .T.
	ENDIF
	IF nrEcs>0
		cmSg = STRTRAN(GetLangText("RESERVAT","TA_CIN_DONE"), '%s2', LTRIM(STR(nrEcs)))
		cmSg = STRTRAN(cmSg, '%s1', LTRIM(STR(ndOne)))
	ELSE
		cmSg = GetLangText("RESERVAT","TA_CIN_FAIL")
	ENDIF
	= alErt(cmSg)
ELSE
	IF l_lCheckinPaymaster AND DLocate('reservat', 'rs_reserid = ' + SqlCnv(l_nPMReserId))
		DO rsCheckin IN Reserv2 WITH reServat.rs_reserid, .F.
	ENDIF
	GOTO nrSrec IN Reservat
	DO rsCheckin IN Reserv2 WITH reServat.rs_reserid, .F., lp_cMessage, NOT l_oCheckReservat.plmessage
	l_lSuccess = EMPTY(lp_cMessage)
	IF !g_newversionactive
		g_Refreshcurr = .T.
	ENDIF
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE CheckInAll
LOCAL ncUrid, nrSord, nrEcs, l_nSelect, l_dSysDate, nrSrec

IF NOT yesno(GetLangText("RESERVAT","TA_CHECK_IN_ALL"))
	RETURN .F.
ENDIF

ncUrid = reServat.rs_reserid
nrSord = ORDER("Reservat")
nrSrec = RECNO("Reservat")
ndOne = 0
nrEcs = 0
l_nSelect = SELECT()
l_dSysDate = sysdate()
SELECT reservat
SET ORDER IN reServat TO TAG8
IF dlOcate('Reservat','DTOS(rs_arrdate)+rs_lname = '+sqLcnv(DTOS(l_dSysDate)))
	SCAN REST WHILE DTOS(rs_arrdate)+rs_lname = DTOS(l_dSysDate) .AND. .NOT. EOF("Reservat")
		WAIT WINDOW NOWAIT LTRIM(STR(nrEcs+1))+"..."
		IF .NOT. INLIST(reServat.rs_status, "CXL", "NS")  ;
				.AND. reServat.rs_arrdate==l_dSysDate .AND.  ;
				EMPTY(reServat.rs_in) .AND.  ;
				EMPTY(reServat.rs_out) .AND.  ;
				.NOT. EMPTY(reServat.rs_roomnum) .AND. ;
				reServat.rs_rooms==1
			lnRecNo= RECNO('reservat')
			DO rsCheckin IN Reserv2 WITH reServat.rs_reserid, .T.
			GO lnRecNo IN reservat
			IF NOT EMPTY(reServat.rs_in)
				ndOne = ndOne+1
			ENDIF
			nrEcs = nrEcs+1
		ENDIF
		SELECT reservat
	ENDSCAN
	WAIT CLEAR
ENDIF
SET ORDER IN "Reservat" TO nrSord
GOTO nrSrec IN "Reservat"
IF nrEcs>0
	cmSg = STRTRAN(GetLangText("RESERVAT","TA_CIN_ALL_DONE"), '%s2', LTRIM(STR(nrEcs)))
	cmSg = STRTRAN(cmSg, '%s1', LTRIM(STR(ndOne)))
ELSE
	cmSg = GetLangText("RESERVAT","TA_CIN_ALL_FAIL")
ENDIF
= alErt(cmSg)
SELECT (l_nSelect)
RETURN .T.
ENDPROC
