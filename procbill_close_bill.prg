* {"action":"procbill_close_bill","param1":1234,"param2":1,"param3":false}
* param1 is reservat.rs_rsid

#INCLUDE "include\constdefines.h"

LPARAMETERS lp_oJSON
LOCAL l_oInstance AS cCloseBill OF procbill_pay_bill.prg, l_cJSON
l_oInstance = CREATEOBJECT("cCloseBill",lp_oJSON.param1, lp_oJSON.param2, lp_oJSON.param3, g_oBillFormSet)

l_cJSON = l_oInstance.Start()
l_oInstance.Release()

RETURN l_cJSON
ENDPROC
*
DEFINE CLASS cCloseBill AS Custom
*
#IF .F.
     LOCAL this AS cCloseBill OF procbill_close_bill.prg
#ENDIF
*
nBalance = ""
nRsId = 0
nReserId = 0
nWindow = 0
lPrint = .F.
oFormSet = .NULL.
oJSON = .NULL.
*
PROCEDURE Init
LPARAMETERS lp_nRsId, lp_nWindow, lp_lPrint, lp_oFormSet
this.nRsId = lp_nRsId
this.nWindow = lp_nWindow
this.lPrint = lp_lPrint
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
	this.TryToClose()
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
LOCAL l_lAllowedAutomaticPrint

IF NOT BETWEEN(this.nWindow,1,6)
	this.oJSON.success = .F.
	this.oJSON.errorcode = 2
	this.oJSON.errormessage = GetLangText("BILL","TXT_WINDOW") + " " + GetLangText("RECURRES","TXT_NOT_VALID")
ENDIF
IF this.oJSON.success
	l_lAllowedAutomaticPrint = IIF(LOWER(readini(FULLPATH(INI_FILE), "expresscheckout", "allowedbillwindow"+TRANSFORM(this.nWindow), "yes"))="yes",.T.,.F.)
	IF NOT l_lAllowedAutomaticPrint
		this.oJSON.success = .F.
		this.oJSON.errorcode = 3
		this.oJSON.errormessage = GetLangText("BILL","TXT_WINDOW") + " nicht erlaubt!"
	ENDIF
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
PROCEDURE TryToClose
LOCAL l_lSuccess, l_oFrmBillPrint, l_lPrivateDataSession, l_lBillChkOut, l_cBillNum

l_lPrivateDataSession = .T.
l_lBillChkOut = .F.
DO FORM "forms\billprint" NAME l_oFrmBillPrint LINKED ;
		WITH this.nReserId, this.nWindow, ;
		1, l_lBillChkOut, .F., .F., l_lPrivateDataSession, NOT this.lPrint ;
		NOSHOW
l_oFrmBillPrint = .NULL.

l_cBillNum = ALLTRIM(FNGetBillData(this.nReserId, this.nWindow, "bn_billnum"))

l_lSuccess = NOT EMPTY(l_cBillNum)

IF l_lSuccess
	this.oJSON.errormessage = l_cBillNum
ELSE
	this.oJSON.success = .F.
	this.oJSON.errorcode = 4
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