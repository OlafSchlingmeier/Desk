IF g_newversionactive
	DOFORM("GETROOM","FORMS\GETROOM")
	RETURN
ENDIF
External Array a_Data
External Array paFeature
Push Key Clear
Private cbOfeat1, cbOfeat2, cbOfeat3, lsTroom, afEature, arOom
Private cmDok, cmDcancel, cmDfind
Private naRea, nrEc, noRd
Private nrMrec, lcAncel
Private daRrival, ddEparture, crOomtype, ncUrrow, lrEsscreen, lrEsbrowse,  ;
	cbRowsewin
lrEsscreen = .F.
lrEsbrowse = .F.
lroomlist=.F.
lcheckbox = .T.
_cbOfeat1 = 1
_cbOfeat2 = 1
_cbOfeat3 = 1
LOCAL m.NumOfFeat, LOldRoomtype, LOldRoom, LHistStr, lnMode, loResOld
LOldRoomtype = ""
LOldRoom = ""
LHistStr = ""
SET DATASESSION TO
	daRrival = {}
	ddEparture = {}
	crOomtype = ''
Do Case
Case Wontop()="WRESERVAT" .And. agEtcol()==8
	ncUrrow = agEtrow()
	daRrival = a_Data(ncUrrow,1)
	ddEparture = a_Data(ncUrrow,3)
	crOomtype = a_Data(ncUrrow,7)
	lrEsscreen = .T.
Case Wontop()='WRSBROWSE'
	If  .Not. Empty(reServat.rs_out) .Or.  ;
			INLIST(reServat.rs_status, "NS", "CXL") .Or. reServat.rs_rooms>1
		?? Chr(7)
		Pop Key
		Return
	Endif
	daRrival = reServat.rs_arrdate
	ddEparture = reServat.rs_depdate
	crOomtype = reServat.rs_roomtyp
	LOldRoomtype = reServat.rs_roomtyp
	lrEsbrowse = .T.
Case Wontop()='FORMEDIT'
	For i=1 To _Screen.FormCount
		If Alltrim(Upper(_Screen.Forms(i).Name))=='FORMEDIT'
			If _Screen.Forms(i).Parent.cbroomnumgotfocus
				lroomlist=.T.
				Set DataSession To _Screen.forms(i).DataSessionId
				daRrival=reServat.rs_arrdate
				ddEparture=reServat.rs_depdate
				crOomtype=reServat.rs_roomtyp
				Set DataSession To
			Endif
		Endif
	Next
Otherwise
	daRrival = {}
	ddEparture = {}
	crOomtype = ''
Endcase
cfEature = "***"
naRea = Select()
Dimension afEature[1, 2]
afEature[1, 1] = ""
afEature[1, 2] = "***"
Dimension arOom[1, 2]
arOom[1, 1] = ""
arOom[1, 2] = "***"
Select piCklist
noRd = Order()
nrEc = Recno()
Set Order To tag4
Seek "FEATURE"
m.NumOfFeat = 0
Scan While pl_label="FEATURE"
	m.NumOfFeat = m.NumOfFeat + 1
	nrOw = Alen(afEature, 1)
	Dimension afEature[nrOw+1, 2]
	afEature[nrOw+1, 1] = Evaluate("pl_lang"+g_Langnum)
	afEature[nrOw+1, 2] = pl_charcod
Endscan
If m.NumOfFeat > 0
	If lrEsscreen
		For i = 1 To nrOw+1
			If !Empty(m.rs_feat1)
				If m.rs_feat1 = afEature[i, 2]
					_cbOfeat1 = i
				Endif
			Endif
			If !Empty(m.rs_feat2)
				If m.rs_feat2 = afEature[i, 2]
					_cbOfeat2 = i
				Endif
			Endif
			If !Empty(m.rs_feat3)
				If m.rs_feat3 = afEature[i, 2]
					_cbOfeat3 = i
				Endif
			Endif
		Next
	Endif
	If lrEsbrowse
		For i = 1 To nrOw+1
			If !Empty(reServat.rs_feat1)
				If reServat.rs_feat1 = afEature[i, 2]
					_cbOfeat1 = i
				Endif
			Endif
			If !Empty(reServat.rs_feat2)
				If reServat.rs_feat2 = afEature[i, 2]
					_cbOfeat2 = i
				Endif
			Endif
			If !Empty(reServat.rs_feat3)
				If reServat.rs_feat3 = afEature[i, 2]
					_cbOfeat3 = i
				Endif
			Endif
		Next
	Endif
Endif
Goto nrEc
Set Order To noRd
Define Window wgEtroom From 0, 0 To 22, 67 Font "Arial", 10 Noclose  ;
	NOZOOM Title GetLangText("GETROOM","TW_GETROOM") Nomdi Double
Activate Window Noshow wgEtroom
Move Window wgEtroom Center
@ 0.250, 2/3 Say GetLangText("GETROOM","T_ARRIVAL")
@ 0.250, 12.400 Get daRrival Size 1, 14 Valid Lastkey()=27 .Or. daRrival>= ;
	sySdate() Color Scheme 2,2
@ 1.500, 2/3 Say GetLangText("GETROOM","T_DEPARTURE")
@ 1.500, 12.400 Get ddEparture Size 1, 14 Valid Lastkey()=27 .Or.  ;
	ddEparture>=daRrival Color Scheme 2,2
@ 2.750, 2/3 Say GetLangText("GETROOM","T_ROOMTYPE")
@ 2.750, 12.400 Get crOomtype Size 1, 6 Picture '!!!!' Valid Lastkey()= ;
	27 .Or.  .Not. Empty(dlOokup('RoomType','rt_roomtyp = '+ ;
	sqLcnv(crOomtype),'rt_roomtyp')) .Or. crOomtype = "*"  Color Scheme 2,2
@ 2.750, 23.000 Get lcheckbox Size 1, 10 Picture "@*C" + " " + GetLangText("RESERVAT","T_CLEANROOMFIRST")
@ 4, 2/3 Say GetLangText("GETROOM","TX_FEATURE")+' 1'
@ 4, 12 Get cbOfeat1 Default _cbOfeat1 Font "Arial", 10 Style "N" Size 1, 109/3  ;
	FROM afEature Picture "@^" Color Scheme 2,2
@ 5.750, 2/3 Say GetLangText("GETROOM","TX_FEATURE")+' 2'
@ 5.750, 12 Get cbOfeat2 Default _cbOfeat2 Font "Arial", 10 Style "N" Size 1,  ;
	109/3 From afEature Picture "@^" Color Scheme 2,2
@ 7.500, 2/3 Say GetLangText("GETROOM","TX_FEATURE")+' 3'
@ 7.500, 12 Get cbOfeat3 Default _cbOfeat3 Font "Arial", 10 Style "N" Size 1,  ;
	109/3 From afEature Picture "@^" Color Scheme 2,2
cmDfind = 0
@ 0.250, 50 Get cmDfind Size nbUttonheight, 12 Picture '@*N '+ ;
	GetLangText("GETROOM","TB_FIND") Valid fiLlroom(crOomtype,cbOfeat1,cbOfeat2, ;
	cbOfeat3,daRrival,ddEparture)
@ 9.500, 2/3 Say GetLangText("GETROOM","TX_ROOM")
@ 9.500, 12 Get lsTroom Default 1 Font "Fixedsys", 10 Style "N" Size 8.5, 40 From arOom Picture "@&"
@ 18.500, 20 Get cmDok Default 0 Size nbUttonheight, 12 Picture "@*T \!"+ ;
	GetLangText("GETROOM","TB_OK")
@ 18.500, 34 Get cmDcancel Default 0 Size nbUttonheight, 12 Picture  ;
	"@*T \?"+GetLangText("GETROOM","TB_CANCEL")
Read Cycle Modal
Release Window wgEtroom
If Lastkey()<>27
	If arOom(lsTroom,2)<>"***"
		nrMrec = Recno('Room')
		If dlOcate('Room','rm_roomnum = '+sqLcnv(arOom(lsTroom,2)))
			crOomnum = arOom(lsTroom,2)
			crOomtype = roOm.rm_roomtyp
			Do Case
			Case lrEsscreen
				a_Data[ncUrrow, 8] = crOomnum
				Show Get a_Data[ncUrrow, 8]
				If a_Data(ncUrrow,7)<>crOomtype
					a_Data[ncUrrow, 7] = crOomtype
					Show Get a_Data[ncUrrow, 7]
				Endif
			Case lrEsbrowse .And.  .Not. (reServat.rs_roomnum== ;
					crOomnum) .And. reServat.rs_rooms=1
				lcAncel = .F.
				Do caNdrop In Plan With lcAncel
				If  .Not. lcAncel
					= avLsave()
					LOldRoom = reServat.rs_roomnum
					SELECT reservat
					SCATTER NAME loResOld
					Replace reServat.rs_roomnum With crOomnum,  ;
						reServat.rs_roomtyp With crOomtype
					DO CheckShare IN ProcReservat WITH "reservat", lnMode, .F., .T., loResOld
					IF lnMode >= 0
						DO ChangeShare IN ProcReservat WITH lnMode, "reservat"
						IF NOT EMPTY(reServat.rs_in)
							DO ifCcheck IN Interfac WITH reServat.rs_roomnum, "CHECKOUT"
							DO ifCcheck IN Interfac WITH crOomnum, "CHECKIN"
						ENDIF
						= avLupdat()
						DO UpdateShareRes IN ProcReservat WITH "reservat"
						LHistStr = GetLangText("RESERVAT","T_ROOMNUM")+" "+ ;
							TRIM(LOldRoom)+"..."+TRIM(reServat.rs_roomnum)+","
						IF reservat.rs_status = "IN" AND param.pa_rmstat
							IF SEEK(ALLTRIM(reServat.rs_roomnum),'room','tag1')
								REPLACE rm_status WITH "DIR" IN room
							ENDIF
						ENDIF
						IF NOT (ALLTRIM(LOldRoomtype)==ALLTRIM(reServat.rs_roomtyp))
							LHistStr = LHistStr+" "+GetLangText("RESERVAT","T_ROOMTYPE")+" "+ ;
							TRIM(LOldRoomtype)+"..."+TRIM(reServat.rs_roomtyp)+","
						ENDIF
						REPLACE reServat.rs_changes WITH rsHistry(reServat.rs_changes,"CHANGED",LHistStr)
						SELECT (naRea)
						DO DispAll IN MyBrowse
					ELSE
						REPLACE rs_roomnum WITH loResOld.rs_roomnum,  ;
								rs_roomtyp WITH loResOld.rs_roomtyp IN reservat
					ENDIF
				Endif
			Case lroomlist
				For i=1 To _Screen.FormCount
					If Alltrim(Upper(_Screen.Forms(i).Name))=='FORMEDIT'
						If _Screen.Forms(i).Parent.cbroomnumgotfocus
							SET DATASESSION TO _screen.forms(i).datasessionid
							replace rs_roomnum WITH croomnum IN reservat
							replace rs_roomtyp WITH croomtype IN reservat
							_screen.forms(i).cbroomnum.displayvalue=croomnum
							_screen.forms(i).cbroomtype.displayvalue=croomtype
							_screen.forms(i).cbroomnum.setfocus
							return
						Endif
					Endif
				Next
			Endcase
		Endif
		Goto nrMrec In roOm
	Endif
Endif
Select roOm
Set Order To tag1
Select (naRea)
Pop Key
Return
Endproc
*
Function fiLlroom
	Parameter pcRoomtype, pnFeat1, pnFeat2, pnFeat3, pdArrival, pdDeparture
	Private ncUrarea, nsIze, nrEc, noRd, dCompareDep
	Private cfEat1, cfEat2, cfEat3
	LOCAL LOrderRoomtype
	LOrderRoomtype = ""
	If Empty(pcRoomtype)
		Return
	Endif
	If Empty(pdArrival)
		Return
	Endif
	If Empty(pdDeparture)
		Return
	Else
		dCompareDep = pdDeparture
		IF SEEK(pcRoomtype,"roomtype","TAG1")
			IF (pdArrival == pdDeparture) .AND. (roomtype.rt_group == 3)
				dCompareDep = pdDeparture + 1
			ENDIF
		ENDIF
	Endif
	cfEat1 = afEature(pnFeat1,2)
	cfEat2 = afEature(pnFeat2,2)
	cfEat3 = afEature(pnFeat3,2)
	nsIze = 0
	ncUrarea = Select()
	Select roOm
	noRd = Order()
	nrEc = Recno()
	Set Order In "room" To tag2
	If Alltrim(pcRoomtype) = "*"&&Search all free rooms
		If lcheckbox
			Set Order In "room" To tag4
			LOrderRoomtype = Order('roomtype')
			Set Order To tag1 In Roomtype
			Set Relation To rm_roomtyp Into Roomtype&& for rt_group check
			Go Top In 'room'
			Do While !Eof('room')
				If (cfEat1=="***" .Or. Seek(roOm.rm_roomnum+cfEat1, "roomfeat"))  ;
						.And. (cfEat2=="***" .Or. Seek(roOm.rm_roomnum+cfEat2,  ;
						"roomfeat")) .And. (cfEat3=="***" .Or. Seek(roOm.rm_roomnum+ ;
						cfEat3, "roomfeat"))
					Select roOmplan
					Set Near On
					Seek roOm.rm_roomnum+Dtos(pdArrival)
					Set Near Off
					Locate Rest While rp_roomnum=roOm.rm_roomnum .And. rp_date< ;
						dCompareDep
					If  .Not. Found() And Upper(roOm.rm_status) = "CLN" And !Inlist(Roomtype.rt_group, 2, 3)
						Select roOm
						nsIze = nsIze+1
						Dimension arOom[nsIze, 2]
						arOom[nsIze, 1] = getmydata()
						arOom[nsIze, 2] = rm_roomnum
					Endif
				Endif
				Select roOm
				Skip 1
			Enddo
			Go Top In 'room'
			Do While !Eof('room')
				If (cfEat1=="***" .Or. Seek(roOm.rm_roomnum+cfEat1, "roomfeat"))  ;
						.And. (cfEat2=="***" .Or. Seek(roOm.rm_roomnum+cfEat2,  ;
						"roomfeat")) .And. (cfEat3=="***" .Or. Seek(roOm.rm_roomnum+ ;
						cfEat3, "roomfeat"))
					Select roOmplan
					Set Near On
					Seek roOm.rm_roomnum+Dtos(pdArrival)
					Set Near Off
					Locate Rest While rp_roomnum=roOm.rm_roomnum .And. rp_date< ;
						dCompareDep
					If  .Not. Found() And Upper(roOm.rm_status) = "DIR" And !Inlist(Roomtype.rt_group, 2, 3)
						Select roOm
						nsIze = nsIze+1
						Dimension arOom[nsIze, 2]
						arOom[nsIze, 1] = getmydata()
						arOom[nsIze, 2] = rm_roomnum
					Endif
				Endif
				Select roOm
				Skip 1
			Enddo
		Else
			Set Order In "room" To  tag4
			LOrderRoomtype = Order('roomtype')
			Set Order To  tag1 In Roomtype
			Set Relation To rm_roomtyp Into Roomtype&& for rt_group check
			Go Top In 'room'
			Do While !Eof('room')
				If (cfEat1=="***" .Or. Seek(roOm.rm_roomnum+cfEat1, "roomfeat"))  ;
						.And. (cfEat2=="***" .Or. Seek(roOm.rm_roomnum+cfEat2,  ;
						"roomfeat")) .And. (cfEat3=="***" .Or. Seek(roOm.rm_roomnum+ ;
						cfEat3, "roomfeat"))
					Select roOmplan
					Set Near On
					Seek roOm.rm_roomnum+Dtos(pdArrival)
					Set Near Off
					Locate Rest While rp_roomnum=roOm.rm_roomnum .And. rp_date< ;
						dCompareDep
					If  .Not. Found() And !Inlist(Roomtype.rt_group, 2, 3)
						Select roOm
						nsIze = nsIze+1
						Dimension arOom[nsIze, 2]
						arOom[nsIze, 1] = getmydata()
						arOom[nsIze, 2] = rm_roomnum
					Endif
				Endif
				Select roOm
				Skip 1
			Enddo
		ENDIF lcheckbox
		Set Relation To && break relation
		Set Order To LOrderRoomtype In Roomtype
	Else&&Search only Rooms for specified Roomtype
		Seek pcRoomtype
		If lcheckbox
			Do While roOm.rm_roomtyp=pcRoomtype
				If (cfEat1=="***" .Or. Seek(roOm.rm_roomnum+cfEat1, "roomfeat"))  ;
						.And. (cfEat2=="***" .Or. Seek(roOm.rm_roomnum+cfEat2,  ;
						"roomfeat")) .And. (cfEat3=="***" .Or. Seek(roOm.rm_roomnum+ ;
						cfEat3, "roomfeat"))
					Select roOmplan
					Set Near On
					Seek roOm.rm_roomnum+Dtos(pdArrival)
					Set Near Off
					Locate Rest While rp_roomnum=roOm.rm_roomnum .And. rp_date< ;
						dCompareDep
					If  .Not. Found() And Upper(roOm.rm_status) = "CLN"
						Select roOm
						nsIze = nsIze+1
						Dimension arOom[nsIze, 2]
						arOom[nsIze, 1] = getmydata()
						arOom[nsIze, 2] = rm_roomnum
					Endif
				Endif
				Select roOm
				Skip 1
			Enddo
			Select roOm
			Seek pcRoomtype
			Do While roOm.rm_roomtyp=pcRoomtype
				If (cfEat1=="***" .Or. Seek(roOm.rm_roomnum+cfEat1, "roomfeat"))  ;
						.And. (cfEat2=="***" .Or. Seek(roOm.rm_roomnum+cfEat2,  ;
						"roomfeat")) .And. (cfEat3=="***" .Or. Seek(roOm.rm_roomnum+ ;
						cfEat3, "roomfeat"))
					Select roOmplan
					Set Near On
					Seek roOm.rm_roomnum+Dtos(pdArrival)
					Set Near Off
					Locate Rest While rp_roomnum=roOm.rm_roomnum .And. rp_date< ;
						dCompareDep
					If  .Not. Found() And Upper(roOm.rm_status) <> "CLN"
						Select roOm
						nsIze = nsIze+1
						Dimension arOom[nsIze, 2]
						arOom[nsIze, 1] = getmydata()
						arOom[nsIze, 2] = rm_roomnum
					Endif
				Endif
				Select roOm
				Skip 1
			Enddo
		Else
			Do While roOm.rm_roomtyp=pcRoomtype
				If (cfEat1=="***" .Or. Seek(roOm.rm_roomnum+cfEat1, "roomfeat"))  ;
						.And. (cfEat2=="***" .Or. Seek(roOm.rm_roomnum+cfEat2,  ;
						"roomfeat")) .And. (cfEat3=="***" .Or. Seek(roOm.rm_roomnum+ ;
						cfEat3, "roomfeat"))
					Select roOmplan
					Set Near On
					Seek roOm.rm_roomnum+Dtos(pdArrival)
					Set Near Off
					Locate Rest While rp_roomnum=roOm.rm_roomnum .And. rp_date< ;
						dCompareDep
					If  .Not. Found()
						Select roOm
						nsIze = nsIze+1
						Dimension arOom[nsIze, 2]
						arOom[nsIze, 1] = getmydata()
						arOom[nsIze, 2] = rm_roomnum
					Endif
				Endif
				Select roOm
				Skip 1
			Enddo
		ENDIF lcheckbox
	ENDIF Alltrim(pcRoomtype) = "*"
	If nsIze=0
		Dimension arOom[1, 2]
		arOom[1, 1] = ""
		arOom[1, 2] = "***"
	Endif
	Select roOm
	Set Order To noRd
	Goto nrEc
	Select (ncUrarea)
	m.lsTroom = 1
	Show Get M.lsTroom Enable
	Return .T.
Endfunc
*
FUNCTION getmydata
	LOCAL LRetVal
	LRetVal = PADR(Trim(rm_roomtyp),4)+" "+PADR(Trim(rm_roomnum),4)+" "+ ;
							PADR(TRIM(Evaluate("rm_lang"+g_Langnum)),20)+" "+Iif(pdArrival= ;
							sySdate(), " ("+Trim(rm_status)+")", "")
	RETURN LRetVal
ENDFUNC
*