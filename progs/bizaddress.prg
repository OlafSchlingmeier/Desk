#INCLUDE "include\constdefines.h"

**************************************************
*-- Class:        cbizaddress (\progs\bizaddress.prg)
*-- ParentClass:  cbizbase (\progs\bizbase.prg)
*-- BaseClass:    collection
*-- Time Stamp:   30.09.11 14:00:00
*
DEFINE CLASS cbizaddress AS cbizbase


	ctables = "address"


	PROCEDURE adrgetbyaddrid
		LPARAMETERS tnRecordId

		IF EMPTY(tnRecordId)
			this.CursorFill("address", "0=1")
		ELSE
			this.CursorFill("address", "ad_addrid = " + SqlCnv(tnRecordId, .T.))
		ENDIF
	ENDPROC


	PROCEDURE adrsave
		LPARAMETERS tcError

		this.ResetError()
		this.CursorRefresh("address")
		DO CASE
			CASE this.AddressCheck()
				this.Save()
			OTHERWISE
		ENDCASE

		RETURN this.GetError(@tcError)
	ENDPROC


	PROCEDURE addresscheck

		RETURN .T.
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cbizaddress
**************************************************


**************************************************
*-- Class:        cbizaddressblk (\progs\bizaddress.prg)
*-- ParentClass:  cbizbase (\progs\bizbase.prg)
*-- BaseClass:    collection
*-- Time Stamp:   30.09.11 14:00:00
*
DEFINE CLASS cbizaddressblk AS cbizbase


	ctables = "address,apartner,referral"
	caddressalias = ""
	capartneralias = ""
	creferralalias = ""


	PROCEDURE init
		this.cAddressAlias = SYS(2015)
		this.cApartnerAlias = SYS(2015)
		this.cReferralAlias = SYS(2015)
	ENDPROC


	PROCEDURE initialize
		LPARAMETERS tcTables

		this.AddTable("address", this.cAddressAlias)
		this.AddTable("apartner", this.cApartnerAlias)
		this.AddTable("referral", this.cReferralAlias)
	ENDPROC


	PROCEDURE adrgetclause
		LPARAMETERS tcFilterClause

		this.CursorFill("address", tcFilterClause, this.cAddressAlias)
	ENDPROC


	PROCEDURE addresscheckfordelete
	ENDPROC


	PROCEDURE adrdelete
		this.ResetError()
		this.AddressCheckForDelete()
		IF this.nErrorCode = NO_ERROR
			DELETE ALL IN curAddress
		ENDIF
	ENDPROC


ENDDEFINE
*
*-- EndDefine: cbizaddressblk
**************************************************