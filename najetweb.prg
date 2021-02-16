#INCLUDE "include\constdefines.h"

*FUNCTION najetweb
LPARAMETERS lp_cMode, lp_nAction, lp_lOnlyPrint
LOCAL l_oJetweb, l_oIniXML, l_lRet, l_nSecToWait, l_cIniFile, l_cSecToWait, l_nReserId, l_lDone, l_cError, l_lPrintIt, l_oGetReserIdResult, l_lGroup
l_lRet = .F.
l_nReserId = 0

IF VARTYPE(lp_cMode) = "L"
	lp_cMode = ""
ENDIF

IF VARTYPE(lp_nAction)<>"N" OR NOT INLIST(lp_nAction, 0, 1, 2)
	lp_nAction = 0
ENDIF

IF INLIST(lp_nAction, 1, 2)
	l_oGetReserIdResult = najetweb_GetReserId()
	IF l_oGetReserIdResult.nReserId = 0
		alert(l_oGetReserIdResult.cMessage)
		RETURN .T.
	ENDIF
	l_nReserId = l_oGetReserIdResult.nReserId
	l_lGroup = l_oGetReserIdResult.lGroup
ENDIF

IF lp_cMode = "BEFOREAUDIT" OR l_nReserId>0 OR lp_lOnlyPrint
	l_oJetweb = NEWOBJECT("resjetweb","procreservat.prg")
	IF TYPE("l_oJetweb") = "O"
		l_cIniFile = FULLPATH(INI_FILE)
		l_oJetWeb.SetMode(l_cIniFile)
		l_nSecToWait = 2
		IF FILE(l_cIniFile)
			l_cSecToWait = readini(l_cIniFile, "jetweb","sectowaitbeforeprinting", "2")
		ENDIF
		TRY
			l_nSecToWait = IIF(EMPTY(l_cSecToWait),l_nSecToWait,INT(VAL(l_cSecToWait)))
		CATCH
		ENDTRY
		IF TYPE("p_oAudit.name") = "C"
			p_oAudit.txtInfo("JETWEB",1)
			p_oAudit.txtInfo("HotelAccess Version: " + l_oJetweb.GetVersion(),1)
		ENDIF
		IF lp_lOnlyPrint
			l_lPrintIt = .T.
		ELSE
			l_lContinue = l_oJetWeb.createXML(l_nReserId, lp_nAction, l_lGroup)
			IF l_lContinue
				l_oJetWeb.SaveXMLToFile("jwsend.xml")
				l_oJetWeb.Send(@l_lDone, @l_cError)
				IF l_nReserId>0
					IF l_lDone
						l_lPrintIt = yesno("Meldeschein ist gesendet." + CHR(13) + CHR(13) + "Wollen Sie diesen auch ausdrucken?")
					ELSE
						IF VARTYPE(l_cError)="L"
							msgbox("Nichts zu senden", 64, "Meldeschein")
						ELSE
							msgbox(PROPER(GetLangText("ERRORSYS","TXT_ERROR_MESSAGE")) + ":" + CHR(13) + CHR(13) + l_cError, 16, "Meldeschein")
						ENDIF
					ENDIF
				ELSE
					IF l_oJetWeb.ojetweb.cVersion <> "deskline3"
						* Wait, give server time
						WAIT WINDOW NOWAIT "Warten auf Server, um Daten zu speichern..."
						sleep(l_nSecToWait*1000)
						WAIT CLEAR
					ENDIF
					l_oJetWeb.PrintMBlatt()
				ENDIF
			ENDIF
		ENDIF
		IF l_lPrintIt
			IF NOT l_oJetWeb.PrintMBlatt(l_nReserId)
				msgbox("Meldeschein kann nicht ausgedruckt werden!", 16, "Meldeschein")
			ENDIF
		ENDIF
		l_lRet = .T.
	ENDIF
	l_oJetweb = .NULL.
ENDIF
RETURN l_lRet
ENDFUNC
*
&& najetweb_GetReserId checks if reservation is selected, then checks if that reservation is allowed to send guest card.
&& Then it checks if this reservation is part of group, then it looks for group main reservation, which is used for all
&& reservations in group.
&& Is it not allowed to send guest card for not standard reservation, or for not splitted reservation.
PROCEDURE najetweb_GetReserId
LOCAL l_nSelect, l_cSelectedReservationCur, l_cgroupresfield, l_oResult, l_cMainReservationCur, l_cGroupReservationsNotSplitedCur

l_oResult = CREATEOBJECT("Empty")
ADDPROPERTY(l_oResult, "nReserId", 0)
ADDPROPERTY(l_oResult, "lGroup", .F.)
ADDPROPERTY(l_oResult, "cMessage", "")

l_nSelect = SELECT()

l_oResult.nReserId = FNGetReserIdForActiveWindow()
IF l_oResult.nReserId > 0
	IF TYPE("_screen.oGlobal.cjetwebgroupresfield")<>"C"
		_screen.oGlobal.AddProperty("cjetwebgroupresfield", readini(FULLPATH(INI_FILE), "jetweb","groupresfield", "rs_usrres2"))
	ENDIF
	l_cSelectedReservationCur = sqlcursor("SELECT rs_reserid, rs_rsid, rs_group, rs_groupid, rs_roomlst, rs_rooms, rs_roomtyp, " + _screen.oGlobal.cjetwebgroupresfield + " AS c_group FROM reservat WHERE rs_reserid = " + sqlcnv(l_oResult.nReserId, .T.))
	IF NOT INLIST(dlookup("roomtype", "rt_roomtyp = " + sqlcnv(&l_cSelectedReservationCur..rs_roomtyp,.T.),"rt_group"),1,4)
		l_oResult.nReserId = 0
		l_oResult.cMessage = GetLangText("MGRRESER","TXT_ONLY_STANDARD_ROOMS") + " " + LOWER(GetLangText("KEYCARD1","TXT_ALLOWED")) + "!"
	ELSE
		IF &l_cSelectedReservationCur..rs_groupid > 0 OR &l_cSelectedReservationCur..rs_rooms > 1
			IF NOT &l_cSelectedReservationCur..rs_roomlst
				l_oResult.nReserId = 0
				l_oResult.cMessage = GetLangText("RESERV2","TA_SPLITFIRST")
			ELSE
				l_cGroupReservationsNotSplitedCur = sqlcursor("SELECT COUNT(*) AS c_result FROM reservat INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp WHERE rs_reserid >= " + SqlCnv(INT(l_oResult.nReserId),.T.) + " AND rs_reserid < " + SqlCnv(INT(l_oResult.nReserId)+1,.T.) + " AND rs_groupid > 0 AND INLIST(roomtype.rt_group,1,4) AND rs_rooms > 1 AND NOT rs_status IN ('CXL', 'NS ')")
				IF &l_cGroupReservationsNotSplitedCur..c_result > 0
					l_oResult.nReserId = 0
					l_oResult.cMessage = "Alle Gruppenreservierungen sollen gesplittet werden!"
				ELSE
					IF EMPTY(&l_cSelectedReservationCur..c_group)
						l_cMainReservationCur = sqlcursor("SELECT rs_reserid, rs_roomlst FROM reservat INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp WHERE rs_reserid >= " + SqlCnv(INT(l_oResult.nReserId),.T.) + " AND rs_reserid < " + SqlCnv(INT(l_oResult.nReserId)+1,.T.) + " AND rs_groupid > 0 AND INLIST(roomtype.rt_group,1,4) AND " + _screen.oGlobal.cjetwebgroupresfield + " = 'T'")
						IF RECCOUNT()=0
							l_oResult.nReserId = 0
							l_oResult.cMessage = "Keine Hauptreservierung für die Gruppe " + ALLTRIM(&l_cSelectedReservationCur..rs_group) + " ist eingereichtet!"
						ELSE
							l_oResult.nReserId = &l_cMainReservationCur..rs_reserid
							l_oResult.lGroup = .T.
						ENDIF
					ELSE
						l_oResult.nReserId = &l_cSelectedReservationCur..rs_reserid
						l_oResult.lGroup = .T.
					ENDIF
				ENDIF
			ENDIF
		ELSE
			l_oResult.nReserId = &l_cSelectedReservationCur..rs_reserid
		ENDIF
	ENDIF
ELSE
	l_oResult.cMessage = GetLangText("BILLINST","T_RESERVAT_NOT_FOUND1")
ENDIF

dclose(l_cMainReservationCur)
dclose(l_cSelectedReservationCur)
dclose(l_cGroupReservationsNotSplitedCur)

SELECT (l_nSelect)

RETURN l_oResult
ENDPROC 
*
DEFINE CLASS najetwebguests AS Custom
*
nSelect = 0
nPerson = 0
nPersons = 0
nPersonsSum = 0
lCancel = .F.
oData = .NULL.
oJW = .NULL.
oAddress = .NULL.
oSaddress = .NULL.
cDefaultGastArt = ""
cIniFile = ""
*
PROCEDURE Init
LPARAMETERS lp_oJW
this.oJW = lp_oJW

this.nSelect = SELECT()
this.cIniFile = FULLPATH(INI_FILE)

this.cDefaultGastArt = this.readini("jetweb-groups","default", "P")

this.CreateComboBoxCursors()
this.CreateGuestsCursor()
this.StoredGuestsLoad()
this.CreateReservationsCursor()
this.RefreshGuestsList()

RETURN .T.
ENDPROC
*
PROCEDURE readini
LPARAMETERS lp_cSection, lp_cEntry, lp_cDefault
RETURN readini(this.cIniFile, lp_cSection,lp_cEntry, lp_cDefault)
ENDPROC
*
PROCEDURE CreateComboBoxCursors
LOCAL i, l_cOneLine, l_cCode, l_cDescription

* Cursor for country combobox
sqlcursor("SELECT pl_lang3, pl_charcod FROM picklist WHERE pl_label = 'COUNTRY' ORDER BY 1", "cpl8223")

* Cursor for title
sqlcursor("SELECT ti_title FROM title WHERE ti_lang = 'GER' AND ti_title <> '   ' ORDER BY ti_titlcod","ctitle8")

* Cursor for dsgvo
SELECT '    ' AS c_choice FROM cpl8223 WHERE 1=0 INTO CURSOR cdsgvo READWRITE
INSERT INTO cdsgvo (c_choice) VALUES ("Nein")
INSERT INTO cdsgvo (c_choice) VALUES ("Ja")

* Cursor for gasttyp combobox
SELECT '  ' AS c_code, SPACE(20) AS c_descript FROM cpl8223 WHERE 1=0 INTO CURSOR gasttyp5 READWRITE
INSERT INTO gasttyp5 (c_code, c_descript) VALUES ("HG", "Hauptgemeldeter Gast")
INSERT INTO gasttyp5 (c_code, c_descript) VALUES ("MP", "Mitreisende Person")
INSERT INTO gasttyp5 (c_code, c_descript) VALUES ("KI", "Kind")
INSERT INTO gasttyp5 (c_code, c_descript) VALUES ("RL", "Reiseleiter")
INSERT INTO gasttyp5 (c_code, c_descript) VALUES ("RG", "Reisegruppe")

* Cursor for gasttyp combobox
SELECT CAST('' AS Char(4)) AS c_code, SPACE(20) AS c_descript FROM cpl8223 WHERE 1=0 INTO CURSOR gastart5 READWRITE
 FOR i = 1 TO 10
      l_cOneLine = this.readini("jetweb-groups",TRANSFORM(i), "")
      IF NOT EMPTY(l_cOneLine)
           l_cCode = GETWORDNUM(l_cOneLine, 1, "|")
           l_cDescription = GETWORDNUM(l_cOneLine, 2, "|")
           INSERT INTO gastart5 (c_code, c_descript) VALUES (l_cCode, l_cDescription)
      ENDIF
 ENDFOR
IF RECCOUNT("gastart5")=0
     INSERT INTO gastart5 (c_code, c_descript) VALUES ("ERW", "Erwachsene")
     INSERT INTO gastart5 (c_code, c_descript) VALUES ("F", "Frei")
ENDIF

ENDPROC
*
PROCEDURE CreateGuestsCursor

SELECT 000 AS c_no, 0000000000.000 AS c_reserid, 000 AS c_reserno, CAST('' AS Char(25)) AS c_title, CAST('' AS Char(30)) AS c_lname, CAST('' AS Char(20)) AS c_fname, ;
     CAST('' AS Char(25)) AS gasttyp, CAST('' AS Char(4)) AS gastart, {} AS gebdatum, ;
     CAST({} AS Char(8)) AS c_arrdate, CAST('' AS Char(8)) AS c_depdate, CAST('' AS Char(10)) AS c_rmname, ;
     {} AS rs_arrdate, {} AS rs_depdate, SPACE(100) AS c_street, SPACE(10) AS c_zip, SPACE(30) AS c_city, '   ' AS c_country, ;
     .F. AS c_remove, '    ' AS c_dsgvo ;
     FROM reservat WHERE 1=0 INTO CURSOR jbguests READWRITE
INDEX ON c_no TAG TAG1
RETURN .T.
ENDPROC
*
PROCEDURE CreateReservationsCursor
LOCAL l_cSql, l_cWhere

IF this.oJW.lGroup
     TEXT TO l_cWhere TEXTMERGE NOSHOW PRETEXT 15
     rs_reserid >= <<SqlCnv(INT(this.oJW.oReservat.rs_reserid),.T.)>> AND rs_reserid < <<SqlCnv(INT(this.oJW.oReservat.rs_reserid)+1,.T.)>> AND rs_groupid > 0
     ENDTEXT
ELSE
     TEXT TO l_cWhere TEXTMERGE NOSHOW PRETEXT 15
     rs_reserid = <<SqlCnv(this.oJW.oReservat.rs_reserid),.T.)>>
     ENDTEXT
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT rs_reserid, rs_addrid, rs_saddrid, rs_adults, rs_childs, rs_childs2, rs_childs3, rs_arrdate, rs_depdate, rs_rmname 
     FROM reservat 
     INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp 
     WHERE <<l_cWhere>>
     ORDER BY rs_reserid
ENDTEXT
sqlcursor(l_cSql, "curres993")

ENDPROC
*
PROCEDURE RefreshGuestsList

SELECT curres993
SCAN ALL
     this.ProcessOneReservation()
ENDSCAN

ENDPROC
*
PROCEDURE ProcessOneReservation
LOCAL l_nSelect
l_nSelect = SELECT()

this.SetAddress()

this.nPersons = rs_adults + rs_childs + rs_childs2 + rs_childs3

FOR this.nPerson = 1 TO this.nPersons
     this.ProcessOnePerson()

     SELECT jbguests
     GATHER NAME this.oData

ENDFOR

SELECT (l_nSelect)

ENDPROC
*
PROCEDURE ProcessOnePerson
LOCAL l_lPersonFound, l_nSelect

l_nSelect = SELECT()

SELECT jbguests
LOCATE FOR c_reserid = curres993.rs_reserid AND c_reserno = this.nPerson
l_lPersonFound = FOUND()
IF l_lPersonFound
     SCATTER NAME this.oData
ELSE
     APPEND BLANK
     SCATTER NAME this.oData BLANK
ENDIF

SELECT curres993

this.nPersonsSum = this.nPersonsSum + 1

this.oData.c_no = this.nPersonsSum
this.oData.c_reserid = rs_reserid
this.oData.c_reserno = this.nPerson
this.oData.rs_arrdate = rs_arrdate
this.oData.c_arrdate = MakeShorDateString(rs_arrdate)
this.oData.rs_depdate = rs_depdate
this.oData.c_depdate = MakeShorDateString(rs_depdate)
this.oData.c_rmname = rs_rmname

DO CASE
     CASE this.nPerson = 1
          IF NOT EMPTY(rs_addrid)
               IF EMPTY(this.oData.c_lname)
                    this.oData.c_lname = this.oAddress.ad_lname
                    this.oData.c_fname = this.oAddress.ad_fname
                    this.oData.c_title = ALLTRIM(dlookup("title","ti_titlcod = " + TRANSFORM(this.oAddress.ad_titlcod) + " AND ti_lang = 'GER'","ti_title"))
                    this.oData.c_street = this.oAddress.ad_street
                    this.oData.c_zip = this.oAddress.ad_zip
                    this.oData.c_city = this.oAddress.ad_city
                    this.oData.c_country = this.oAddress.ad_country
                    this.oData.c_dsgvo = IIF(PAAddressConsent(,this.oAddress.ad_addrid,,,.T.),"Ja","Nein")
               ENDIF
               IF EMPTY(this.oData.gebdatum)
                    this.oData.gebdatum = this.oAddress.ad_birth
               ENDIF
          ENDIF
     CASE this.nPerson = 2
          IF NOT EMPTY(rs_saddrid)
               IF EMPTY(this.oData.c_lname)
                    this.oData.c_lname = this.oSaddress.ad_lname
                    this.oData.c_fname = this.oSaddress.ad_fname
                    this.oData.c_title = ALLTRIM(dlookup("title","ti_titlcod = " + TRANSFORM(this.oSaddress.ad_titlcod) + " AND ti_lang = 'GER'","ti_title"))
                    this.oData.c_street = this.oSaddress.ad_street
                    this.oData.c_zip = this.oSaddress.ad_zip
                    this.oData.c_city = this.oSaddress.ad_city
                    this.oData.c_country = this.oSaddress.ad_country
                    this.oData.c_dsgvo = IIF(PAAddressConsent(,this.oSaddress.ad_addrid,,,.T.),"Ja","Nein")
               ENDIF
               IF EMPTY(this.oData.gebdatum)
                    this.oData.gebdatum = this.oSaddress.ad_birth
               ENDIF
          ENDIF
ENDCASE

IF EMPTY(this.oData.gasttyp)
     IF this.oJW.lGroup
          this.oData.gasttyp = "RG"
     ELSE
          this.oData.gasttyp = "MP"
     ENDIF
ENDIF
IF EMPTY(this.oData.gastart)
     this.oData.gastart = this.cDefaultGastArt
ENDIF
IF EMPTY(this.oData.c_dsgvo)
     this.oData.c_dsgvo = "Nein"
ENDIF

SELECT (l_nSelect)

ENDPROC
*
PROCEDURE ShowGuests

this.ShowInputMask()
this.CleanUp()

RETURN IIF(this.lCancel, "", "jbguests")
ENDPROC
*
PROCEDURE SetAddress
LOCAL l_nSelect, l_nAddrId, l_nSAddrId

l_nSelect = SELECT()
l_nAddrId = curres993.rs_addrid
l_nSAddrId = curres993.rs_saddrid

l_cAddrCur = sqlcursor("SELECT ad_addrid, ad_title, ad_titlcod, ad_lname, ad_fname, ad_birth, ad_street, ad_zip, ad_city, ad_country FROM address WHERE ad_addrid = " + TRANSFORM(l_nAddrId))
SCATTER NAME this.oAddress
dclose(l_cAddrCur)

l_cSAddrCur = sqlcursor("SELECT ad_addrid, ad_title, ad_titlcod, ad_lname, ad_fname, ad_birth, ad_street, ad_zip, ad_city, ad_country FROM address WHERE ad_addrid = " + TRANSFORM(l_nSAddrId))
SCATTER NAME this.oSaddress
dclose(l_cSAddrCur)

SELECT (l_nSelect)

ENDPROC
*
PROCEDURE StoredGuestsLoad
LOCAL l_cJSON, l_lSuccess

l_cJSON = this.oJW.oReservat.rs_custom1

IF NOT EMPTY(l_cJSON)

     IF FNJsonToCursor(l_cJSON, "curguest1")

          SELECT jbguests
          APPEND FROM DBF("curguest1")
          dclose("curguest1")

     ENDIF
ENDIF

ENDPROC
*
PROCEDURE StoredGuestsSave
LOCAL l_cJSON

DELETE FOR c_remove IN jbguests
l_cJSON = FNCursorToJson("jbguests")

REPLACE rs_custom1 WITH l_cJSON FOR rs_reserid = this.oJW.oReservat.rs_reserid IN reservat

ENDPROC
*
PROCEDURE StoredGuestsValidate
SELECT jbguests
SCAN ALL
     * Remove spaces from begin and end, because it is possible that user wrongly entered those spaces
     REPLACE c_fname WITH ALLTRIM(c_fname), ;
             c_lname WITH ALLTRIM(c_lname), ;
             c_street WITH ALLTRIM(c_street), ;
             c_zip WITH ALLTRIM(c_zip), ;
             c_city WITH ALLTRIM(c_city)
ENDSCAN
ENDPROC 
*
PROCEDURE ShowInputMask
LOCAL ARRAY l_aDefs(1,7)

l_nRow = 1
l_aDefs(l_nRow,1) = "TRANSFORM(c_no)" + IIF(this.oJW.lGroup,"+' (' + TRANSFORM(c_reserno) + ')'","")
l_aDefs(l_nRow,2) = 35
l_aDefs(l_nRow,3) = "Nr."
l_aDefs(l_nRow,4) = "TXT"
l_aDefs(l_nRow,6) = .T.

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_reserid"
l_aDefs(l_nRow,2) = 80
l_aDefs(l_nRow,3) = "ReserId"
l_aDefs(l_nRow,4) = "TXT"
l_aDefs(l_nRow,6) = .T.

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_rmname"
l_aDefs(l_nRow,2) = 50
l_aDefs(l_nRow,3) = GetLangText("RESERVAT","TH_ROOMNUM")
l_aDefs(l_nRow,4) = "TXT"
l_aDefs(l_nRow,6) = .T.

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_arrdate"
l_aDefs(l_nRow,2) = 55
l_aDefs(l_nRow,3) = GetLangText("RESERVAT","TXT_ARRIVAL")
l_aDefs(l_nRow,4) = "TXT"
l_aDefs(l_nRow,6) = .T.

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_depdate"
l_aDefs(l_nRow,2) = 55
l_aDefs(l_nRow,3) = GetLangText("RESERVAT","TXT_DEPARTURE")
l_aDefs(l_nRow,4) = "TXT"
l_aDefs(l_nRow,6) = .T.

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_title"
l_aDefs(l_nRow,2) = 60
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_TITLE")
l_aDefs(l_nRow,4) = "CBO"
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource,ColumnCount,ColumnWidths")
l_aDefs(l_nRow,7).ColumnCount = 1
l_aDefs(l_nRow,7).ColumnWidths = "140"
l_aDefs(l_nRow,7).RowSourceType = 6
l_aDefs(l_nRow,7).RowSource = "ctitle8.ti_title"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_fname"
l_aDefs(l_nRow,2) = 130
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_FIRSTNAME")
l_aDefs(l_nRow,4) = "TXT"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_lname"
l_aDefs(l_nRow,2) = 130
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_LASTNAME")
l_aDefs(l_nRow,4) = "TXT"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "gebdatum"
l_aDefs(l_nRow,2) = 70
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_BIRTHDAY")
l_aDefs(l_nRow,4) = "TXT"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_street"
l_aDefs(l_nRow,2) = 130
l_aDefs(l_nRow,3) = GetLangText("RESERVAT","T_STREET")
l_aDefs(l_nRow,4) = "TXT"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_zip"
l_aDefs(l_nRow,2) = 50
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_CITYZIP")
l_aDefs(l_nRow,4) = "TXT"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_city"
l_aDefs(l_nRow,2) = 90
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_CITY")
l_aDefs(l_nRow,4) = "TXT"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_country"
l_aDefs(l_nRow,2) = 50
l_aDefs(l_nRow,3) = GetLangText("ADDRESS","TXT_COUNTRY")
l_aDefs(l_nRow,4) = "CBO"
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource,ColumnCount,ColumnWidths")
l_aDefs(l_nRow,7).ColumnCount = 2
l_aDefs(l_nRow,7).ColumnWidths = "30,140"
l_aDefs(l_nRow,7).RowSourceType = 6
l_aDefs(l_nRow,7).RowSource = "cpl8223.pl_charcod, pl_lang3"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_dsgvo"
l_aDefs(l_nRow,2) = 50
l_aDefs(l_nRow,3) = "dsgvo"
l_aDefs(l_nRow,4) = "CBO"
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource,ColumnCount,ColumnWidths")
l_aDefs(l_nRow,7).ColumnCount = 1
l_aDefs(l_nRow,7).ColumnWidths = "50"
l_aDefs(l_nRow,7).RowSourceType = 6
l_aDefs(l_nRow,7).RowSource = "cdsgvo.c_choice"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "gasttyp"
l_aDefs(l_nRow,2) = 40
l_aDefs(l_nRow,3) = "G. Typ"
l_aDefs(l_nRow,4) = "CBO"
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource")
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource,ColumnCount,ColumnWidths")
l_aDefs(l_nRow,7).ColumnCount = 2
l_aDefs(l_nRow,7).ColumnWidths = "30,140"
l_aDefs(l_nRow,7).RowSourceType = 6
l_aDefs(l_nRow,7).RowSource = "gasttyp5.c_code, c_descript"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "gastart"
l_aDefs(l_nRow,2) = 55
l_aDefs(l_nRow,3) = "G. Art"
l_aDefs(l_nRow,4) = "CBO"
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource")
l_aDefs(l_nRow,7) = MakeStructure("RowSourceType,RowSource,ColumnCount,ColumnWidths")
l_aDefs(l_nRow,7).ColumnCount = 2
l_aDefs(l_nRow,7).ColumnWidths = "40,140"
l_aDefs(l_nRow,7).RowSourceType = 6
l_aDefs(l_nRow,7).RowSource = "gastart5.c_code, c_descript"

l_nRow = Aadd(@l_aDefs)
l_aDefs(l_nRow,1) = "c_remove"
l_aDefs(l_nRow,2) = 25
l_aDefs(l_nRow,3) = "Entf."
l_aDefs(l_nRow,4) = "CHK"

SELECT jbguests
GO TOP

l_nResult = FNDoBrwMulSel("jbguests", @l_aDefs, GetLangText("MAILING","T_GUESTS"),,,GetLangText("MAILING","T_GUESTS"), .T.)

IF EMPTY(l_nResult)
     dclose("jbguests")
     this.lCancel = .T.
ELSE
     this.StoredGuestsValidate()
     this.StoredGuestsSave()
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE CleanUp

SELECT (this.nSelect)
dclose("curres993")
dclose("cpl8223")
dclose("gasttyp5")
dclose("gastart5")
dclose("ctitle8")
dclose("cdsgvo")

ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE