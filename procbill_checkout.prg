* {"action":"procbill_checkout","param1":1234}
* param1 is reservat.rs_rsid

#INCLUDE "include\constdefines.h"

LPARAMETERS lp_oJSON
LOCAL l_oInstance AS cCheckoutBill OF procbill_checkout.prg, l_cJSON
l_oInstance = CREATEOBJECT("cCheckoutBill",lp_oJSON.param1, g_oBillFormSet)

l_cJSON = l_oInstance.Start()
l_oInstance.Release()

RETURN l_cJSON
ENDPROC
*
DEFINE CLASS cCheckoutBill AS Custom
*
#IF .F.
     LOCAL this AS cCheckoutBill OF procbill_checkout.prg
#ENDIF
*
nRsId = 0
nReserId = 0
oFormSet = .NULL.
oJSON = .NULL.
*
PROCEDURE Init
LPARAMETERS lp_nRsId, lp_oFormSet
this.nRsId = lp_nRsId
this.oFormSet = lp_oFormSet

this.InitJSON()

ENDPROC
*
PROCEDURE Start

this.CheckReservation()

IF this.oJSON.success
	this.InitializeBillsFormSet()
ENDIF

IF this.oJSON.success
	this.CheckReservationStatus()
ENDIF

IF this.oJSON.success
	this.CheckIfAllBillsAreClosed()
ENDIF

IF this.oJSON.success
	this.TryToCheckOut()
ENDIF

this.CleanUp()

RETURN this.oJSON.ToJSON()
ENDPROC
*
PROCEDURE CheckReservation
LOCAL l_lFound
IF SEEK(this.nRsId,"reservat","tag33")
	this.nReserId = reservat.rs_reserid
	l_lFound = .T.
ENDIF
IF NOT l_lFound
	this.oJSON.success = .F.
	this.oJSON.errorcode = 1
	this.oJSON.errormessage = GetLangText("BILLINST","T_RESERVAT_NOT_FOUND1")
ENDIF
ENDPROC
*
PROCEDURE CheckReservationStatus
DO CASE
	CASE EMPTY(reservat.rs_in)
		this.oJSON.success = .F.
		this.oJSON.errorcode = 2
		this.oJSON.errormessage = GetLangText("CHKOUT2","TXT_NOTCHECKEDIN")+"!"
	CASE NOT EMPTY(reservat.rs_out)
		this.oJSON.success = .F.
		this.oJSON.errorcode = 3
		this.oJSON.errormessage = "Bereits ausgecheckt!"
ENDCASE
ENDPROC
*
PROCEDURE CheckIfAllBillsAreClosed
LOCAL i, l_lSuccess, l_nReserId, l_nWindow, l_cBillNum, l_nAmount, l_nSelect, l_lAllowedAutomaticPrint
l_nSelect = SELECT()
l_lSuccess = .F.
l_nReserId = this.nReserId

FOR i = 1 TO 6
	l_nWindow = i
	l_lAllowedAutomaticPrint = IIF(LOWER(readini(FULLPATH(INI_FILE), "expresscheckout", "allowedbillwindow"+TRANSFORM(l_nWindow), "yes"))="yes",.T.,.F.)
	IF l_lAllowedAutomaticPrint
		l_cBillNum = dlookup("billnum","bn_reserid = " + sqlcnv(l_nReserId,.T.) + " AND bn_window = " + sqlcnv(l_nWindow,.T.) + ;
				" AND bn_status = 'PCO'", "bn_billnum")
		IF EMPTY(l_cBillNum)
			l_nAmount = Balance(l_nReserId,l_nWindow)
			IF l_nAmount <> 0.00
				this.oJSON.success = .F.
				this.oJSON.errorcode = 1
				this.oJSON.errormessage = "Bitte erst alle Rechnungen schlieﬂen! (" + TRANSFORM(l_nWindow) + ")"
				l_lSuccess = .F.
			ELSE
				IF dlocate("post","ps_reserid = " + sqlcnv(l_nReserId) + " AND ps_window = " + sqlcnv(i) + " AND NOT ps_cancel")
					this.oJSON.success = .F.
					this.oJSON.errorcode = 4
					this.oJSON.errormessage = "Saldo ist 0, aber Rechnung ist nicht geschlossen! (" + TRANSFORM(l_nWindow) + ")"
					l_lSuccess = .F.
				ELSE
					l_lSuccess = .T.
				ENDIF
			ENDIF
		ELSE
			l_lSuccess = .T.
		ENDIF
	ELSE
		l_lSuccess = .T.
	ENDIF
	IF NOT l_lSuccess
		EXIT
	ENDIF
ENDFOR

SELECT (l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE InitializeBillsFormSet
this.oFormSet.MainEntryPoint(this.nReserId)
ENDPROC
*
PROCEDURE InitJSON
LOCAL l_cJSON, l_oJSON

JSONStart()
JSON.stringDelimitator = ["]
JSON.quotePropertyNames = .T.

this.oJSON = JSONObject()
this.oJSON.Add("errorcode",0)
this.oJSON.Add("errormessage","")
this.oJSON.Add("success",.T.)

ENDPROC
*
PROCEDURE TryToCheckOut
LOCAL l_lSuccess

l_lSuccess = this.oFormSet.oncheckout()

IF l_lSuccess
	* Mark in reservat record, that this reservation has automaticly issued bills
	sqlupdate("reservat", ;
		"rs_reserid = " + sqlcnv(this.nReserId,.T.), ;
		"rs_usrres3 = " + sqlcnv("T",.T.))
ELSE
	this.oJSON.success = .F.
	this.oJSON.errorcode = 1
	this.oJSON.errormessage = GetLangText("COMMON","TXT_FAILED")
ENDIF
ENDPROC
*
PROCEDURE GetJSON_ConvertToNumeric
LPARAMETERS lp_cAmount
RETURN EVALUATE(STRTRAN(lp_cAmount,",","."))
ENDPROC
*
PROCEDURE GetJSON_ConvertDate
LPARAMETERS lp_dDate
LOCAL l_cDateTime
* 2019-02-28T09:32:49.835Z
l_cDateTime = TRANSFORM(YEAR(lp_dDate))+"-"+PADL(MONTH(lp_dDate),2,"0")+"-"+PADL(DAY(lp_dDate),2,"0")+ "T00:00:00.000Z"
RETURN l_cDateTime
ENDPROC
*
PROCEDURE CleanUp

ENDPROC
*
PROCEDURE Release
this.oFormSet = .NULL.
RELEASE this
ENDPROC
*
ENDDEFINE