* {"action":"procbill_pay_bill","param1":1234,"param2":1,"param3":4,,"param4":87.12}
* param1 is reservat.rs_rsid

LPARAMETERS lp_oJSON
LOCAL l_oInstance AS cPayBill OF procbill_pay_bill.prg, l_cJSON
l_oInstance = CREATEOBJECT("cPayBill",lp_oJSON.param1, lp_oJSON.param2, lp_oJSON.param3, lp_oJSON.param4, g_oBillFormSet)

l_cJSON = l_oInstance.Start()
l_oInstance.Release()

RETURN l_cJSON
ENDPROC
*
DEFINE CLASS cPayBill AS Custom
*
#IF .F.
     LOCAL this AS cPayBill OF procbill_pay_bill.prg
#ENDIF
*
nBalance = ""
nRsId = 0
nReserId = 0
nWindow = 0
nPayNum = 0
nAmount = 0
oFormSet = .NULL.
oJSON = .NULL.
nRecNoPaymetho = -9999
*
PROCEDURE Init
LPARAMETERS lp_nRsId, lp_nWindow, lp_nPayNum, lp_nAmount, lp_oFormSet
this.nRsId = lp_nRsId
this.nWindow = lp_nWindow
this.nPayNum = lp_nPayNum
this.nAmount = lp_nAmount
this.oFormSet = lp_oFormSet

this.InitJSON()

ENDPROC
*
PROCEDURE Start

this.CheckReservation()

IF this.oJSON.success
	this.CheckWindow()
ENDIF

IF this.oJSON.success
	this.InitializeBillsFormSet()
ENDIF

IF this.oJSON.success
	this.CheckPayment()
ENDIF

IF this.oJSON.success
	this.CheckAmount()
ENDIF

IF this.oJSON.success
	this.TryToPay()
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
PROCEDURE CheckWindow
IF NOT BETWEEN(this.nWindow,1,6)
	this.oJSON.success = .F.
	this.oJSON.errorcode = 2
	this.oJSON.errormessage = GetLangText("BILL","TXT_WINDOW") + " " + GetLangText("RECURRES","TXT_NOT_VALID")
ENDIF
ENDPROC
*
PROCEDURE CheckPayment
this.nRecNoPaymetho = RECNO("paymetho")
IF NOT SEEK(this.nPayNum,"paymetho","tag1") OR NOT paymetho.pm_kiosk
	this.oJSON.success = .F.
	this.oJSON.errorcode = 3
	this.oJSON.errormessage = GetLangText("AR","TXT_PAYMENT") + " " + GetLangText("RECURRES","TXT_NOT_VALID")
ENDIF
ENDPROC
*
PROCEDURE CheckAmount
IF this.nAmount = 0.00
	this.oJSON.success = .F.
	this.oJSON.errorcode = 4
	this.oJSON.errormessage = GetLangText("GROUPBIL","TXT_AMOUNT") + " " + GetLangText("RECURRES","TXT_NOT_VALID")
ENDIF
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
PROCEDURE TryToPay
LOCAL l_lSuccess, l_nUnits
l_nUnits = ROUND(this.nAmount / paymetho.pm_calcrat, param.pa_currdec)
l_lSuccess = BillPayProcess("post", this.nReserId, this.nWindow, 0, "", "DESKAPI", this.nPayNum, this.nAmount, l_nUnits)
IF NOT l_lSuccess
	this.oJSON.success = .F.
	this.oJSON.errorcode = 5
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
IF this.nRecNoPaymetho <> -9999
	GO this.nRecNoPaymetho IN paymetho
ENDIF
ENDPROC
*
PROCEDURE Release
this.oFormSet = .NULL.
RELEASE this
ENDPROC
*
ENDDEFINE