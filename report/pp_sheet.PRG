**
*		File .........:	Pp_sheet.Prg
*		Rights .......:	CopyRight (C)1999 S+P KG
*		Author .......:	Olaf Schlingmeier
*		Last modified :	May 02, 1999 /HK for Version 7.5
*						02.11.99 home()-Funktion entfernt für Version 7.70
*						03.01.2000 HK  	Zimmertyp SU hinzugefügt
**						14.09.2000 HK   Modifiziert für Grefrather Hof
**						19.03.2001 HK	Modiffiziert für advena Hotel (Zimmertypen)
*		PREPROCESS
**
*		History:
*
*		February 20, 1999 /OS
*		Created this module.
**
**
*#Include Hotel.H
**
#define FONT_NAME		"Arial"
#define FONT_SIZE		10
**
*End Hotel.H
**
**
*#Include Common.H
**
#define	Local				Private
#define	Nil					.t.
#define	True				.t.
#define	False				.f.
**
*End Common.H
**
**
*#Include RoomType.H
**
#define	PP_VERSION				"1.12"
**
*End RoomType.H
**
**----------------------------------------------------------------------
*	PpVersion()
**----------------------------------------------------------------------
Function PpVersion
  Parameter cVersion
	*
	cVersion = PP_VERSION
	*
Return 

Function pp_sheet
Create Cursor PreProc			;
		(	ReserID		N(12,3),;
			abrkto		C(8),	;
			rm1Anz		N(6,0),	;
			rm1typ		C(5),	;
			rm1bel		N(2,0),	;
			rm1anr		D(8),	;
			rm1abr		D(8),	;
			rm1rate		N(8,2),	;
			rm2Anz		N(6,0),	;
			rm2typ		C(5),	;
			rm2bel		N(2,0),	;
			rm2anr		D(8),	;
			rm2abr		D(8),	;
			rm2rate		N(8,2),	;
			rm3Anz		N(6,0),	;
			rm3typ		C(5),	;
			rm3bel		N(2,0),	;
			rm3anr		D(8),	;
			rm3abr		D(8),	;
			rm3rate		N(8,2),	;
			rm4Anz		N(6,0),	;
			rm4typ		C(5),	;
			rm4bel		N(2,0),	;
			rm4anr		D(8),	;
			rm4abr		D(8),	;
			rm4rate		N(8,2),	;
			rm5Anz		N(6,0),	;
			rm5typ		C(5),	;
			rm5bel		N(2,0),	;
			rm5anr		D(8),	;
			rm5abr		D(8),	;
			rm5rate		N(8,2),	;
			rm6Anz		N(6,0),	;
			rm6typ		C(5),	;
			rm6bel		N(2,0),	;
			rm6anr		D(8),	;
			rm6abr		D(8),	;
			rm6rate		N(8,2)	;
			)
append blank
select reservat
set order to tag1
seek min1
do while eof()=.f. and int(min1)=int(reservat.rs_reserid)
	if inlist(reservat.rs_roomtyp, "BUS", "DZ1", "DZ2", "DZ3", "EZ1", "EZ2", "EZ3", "FRE", "JS") and !inlist(reservat.rs_status,"NS","OUT","CXL")
		select preproc	
		if empty(reserid)
			replace reserid		with reservat.rs_reserid
			replace rm1Anz		with reservat.rs_rooms
			replace rm1Typ		with reservat.rs_roomtyp
			replace rm1bel		with reservat.rs_adults
			replace rm1anr		with reservat.rs_arrdate
			replace rm1abr		with reservat.rs_depdate
			replace	rm1rate		with reservat.rs_rate
		else
			do case
				case rm1Typ = Reservat.rs_roomtyp and rm1bel=reservat.rs_adults
					replace	rm1Anz		with rm1Anz + reservat.rs_rooms
				case rm2Typ = Reservat.rs_roomtyp and rm2bel=reservat.rs_adults
					replace	rm2Anz		with rm2Anz + reservat.rs_rooms
				case rm3Typ = Reservat.rs_roomtyp and rm3bel=reservat.rs_adults
					replace	rm3Anz		with rm3Anz + reservat.rs_rooms	
				case rm4Typ = Reservat.rs_roomtyp and rm4bel=reservat.rs_adults
					replace	rm4Anz		with rm4Anz + reservat.rs_rooms
				case rm5Typ = Reservat.rs_roomtyp and rm5bel=reservat.rs_adults
					replace	rm5Anz		with rm5Anz + reservat.rs_rooms
				case rm6Typ = Reservat.rs_roomtyp and rm6bel=reservat.rs_adults
					replace	rm6Anz		with rm6Anz + reservat.rs_rooms	
			otherwise
				gs = .f.
				if empty(rm2Typ)
					replace rm2Anz		with reservat.rs_rooms
					replace rm2Typ		with reservat.rs_roomtyp
					replace rm2bel		with reservat.rs_adults
					replace rm2anr		with reservat.rs_arrdate
					replace rm2abr		with reservat.rs_depdate
					replace	rm2rate		with reservat.rs_rate
					gs =.t.
				endif
				if empty(rm3Typ) and gs=.f.
					replace rm3Anz		with reservat.rs_rooms
					replace rm3Typ		with reservat.rs_roomtyp
					replace rm3bel		with reservat.rs_adults
					replace rm3anr		with reservat.rs_arrdate
					replace rm3abr		with reservat.rs_depdate
					replace	rm3rate		with reservat.rs_rate
					gs=.t.
				endif
				if empty(rm4Typ)and gs=.f.
					replace rm4Anz		with reservat.rs_rooms
					replace rm4Typ		with reservat.rs_roomtyp
					replace rm4bel		with reservat.rs_adults
					replace rm4anr		with reservat.rs_arrdate
					replace rm4abr		with reservat.rs_depdate
					replace	rm4rate		with reservat.rs_rate
					gs=.t.
				endif
				if empty(rm5Typ) and gs=.f.
					replace rm5Anz		with reservat.rs_rooms
					replace rm5Typ		with reservat.rs_roomtyp
					replace rm5bel		with reservat.rs_adults
					replace rm5anr		with reservat.rs_arrdate
					replace rm5abr		with reservat.rs_depdate
					replace	rm5rate		with reservat.rs_rate
					gs=.t.
				endif
				if empty(rm6Typ) and gs=.f.
					replace rm6Anz		with reservat.rs_rooms
					replace rm6Typ		with reservat.rs_roomtyp
					replace rm6bel		with reservat.rs_adults
					replace rm6anr		with reservat.rs_arrdate
					replace rm6abr		with reservat.rs_depdate
					replace	rm6rate		with reservat.rs_rate
					gs=.t.
				endif
			endcase
		endif
	else
		if val(reservat.rs_roomnum)>=9000
			replace preproc.abrkto		with reservat.rs_roomnum
		endif
	endif
	select reservat
	skip
enddo		
use