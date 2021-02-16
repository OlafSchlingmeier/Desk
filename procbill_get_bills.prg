* {"action":"procbill_get_bills","param1":1234}
* param1 is reservat.rs_rsid

LPARAMETERS lp_oJSON
LOCAL l_oBW AS cBillWindows OF procbill_get_bills.prg, l_cJSON

l_oBW = CREATEOBJECT("cBillWindows",lp_oJSON.param1, g_oBillFormSet)

l_cJSON = l_oBW.Start()
l_oBW.Release()

RETURN l_cJSON
ENDPROC
*
DEFINE CLASS cBillWindows AS Custom
*
#IF .F.
     LOCAL this AS cBillWindows OF procbill_get_bills.prg
#ENDIF
*
cBalance = ""
nRsId = 0
nReserId = 0
oFormSet = .NULL.
oJSON = .NULL.
*
PROCEDURE Init
LPARAMETERS lp_nRsId, lp_oFormSet
this.nRsId = lp_nRsId
this.oFormSet = lp_oFormSet
ENDPROC
*
PROCEDURE Start

IF NOT this.SetReservation()
	RETURN ""
ENDIF

this.InitializeBillsFormSet()
this.GetBalance()

RETURN this.GetJSON()
ENDPROC
*
PROCEDURE SetReservation
LOCAL l_lFound
IF SEEK(this.nRsId,"reservat","tag33")
	this.nReserId = reservat.rs_reserid
	l_lFound = .T.
ENDIF
RETURN l_lFound
ENDPROC
*
PROCEDURE InitializeBillsFormSet
this.oFormSet.MainEntryPoint(this.nReserId)
ENDPROC
*
PROCEDURE GetBalance
this.cBalance = STRTRAN(this.oFormSet.frmBills.txtBalance.Value,",",".")
ENDPROC
*
PROCEDURE GetJSON
LOCAL l_cJSON, l_oJSON

JSONStart()
JSON.stringDelimitator = ["]
JSON.quotePropertyNames = .T.

this.oJSON = JSONObject()
this.oJSON.Add("balance",this.GetJSON_ConvertToNumeric(this.cBalance))
this.oJSON.Add("guestname",ALLTRIM(reservat.rs_lname))
this.oJSON.Add("id",this.nRsId)

this.GetJSON_billwindows()

l_cJSON = this.oJSON.ToJSON()

RETURN l_cJSON
ENDPROC
*
PROCEDURE GetJSON_billwindows
LOCAL i, l_cAlias, l_oBillWindow, l_oArticle, l_oPayment
this.oJSON.addArray("billwindows")

FOR i = 1 TO 6
	l_oBillWindow = JSONObject("{balance:0,number:'',status:'',window:0,address:{}}")
	l_cAlias = "tblpostwin" + TRANSFORM(i)
	IF RECCOUNT(l_cAlias)>0
		l_oBillWindow.window = i
		l_oBillWindow.balance = this.GetJSON_ConvertToNumeric(EVALUATE("this.oFormSet.frmBills.grdBill"+TRANSFORM(i)+".GrcAmount.GrhAmount.Caption"))
		l_oBillWindow.status = ALLTRIM(FNGetBillData(reservat.rs_reserid, i, "bn_status"))
		l_oBillWindow.number = ALLTRIM(FNGetBillData(reservat.rs_reserid, i, "bn_billnum"))
		l_oBillWindow.address = this.GetJSON_address(i)
		l_oBillWindow.addArray("articles")
		l_oBillWindow.addArray("payments")
		SELECT &l_cAlias
		SCAN ALL
			IF ps_artinum > 0
				l_oArticle = JSONObject()
				l_oArticle.Add("date", this.GetJSON_ConvertDate(ps_date))
				l_oArticle.Add("description", ALLTRIM(tw_arlang))
				l_oArticle.Add("plu", ps_artinum)
				l_oArticle.Add("price", ps_price)
				l_oArticle.Add("quantity", ps_units)
				l_oArticle.Add("vat", this.GetJSON_vat(ps_artinum))
				l_oBillWindow.articles.Add(l_oArticle)
			ELSE
				l_oPayment = JSONObject()
				l_oPayment.Add("date", this.GetJSON_ConvertDate(ps_date))
				l_oPayment.Add("description", ALLTRIM(tw_paylang))
				l_oPayment.Add("paynum", ps_paynum)
				l_oPayment.Add("amount", ps_amount*-1)
				l_oBillWindow.payments.Add(l_oPayment)
			ENDIF
		ENDSCAN
		this.oJSON.billwindows.Add(l_oBillWindow)
	ENDIF
ENDFOR

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
PROCEDURE GetJSON_vat
LPARAMETERS lp_nArtiNum
LOCAL l_nVat, l_nRecNoArticle, l_nRecNoPicklist
l_nRecNoArticle = RECNO("article")
l_nRecNoPicklist = RECNO("picklist")

l_nVat = 0

IF SEEK(lp_nArtiNum,"article","tag1") AND SEEK("VATGROUP  "+STR(article.ar_vat,3),"picklist","tag3")
	l_nVat = picklist.pl_numval
ENDIF

GO l_nRecNoArticle IN article
GO l_nRecNoPicklist IN picklist

RETURN l_nVat
ENDPROC
*
PROCEDURE GetJSON_address
LPARAMETERS lp_nWindow
LOCAL l_nAddressID, l_oAddress, l_nRecNo
l_oAddress = JSONObject()
l_nAddressID = 0

DO BillAddrId IN ProcBill WITH lp_nWindow, reservat.rs_rsid, reservat.rs_addrid, l_nAddressID

l_nRecNo = RECNO("address")

IF SEEK(l_nAddressID, "address", "tag1")

	l_oAddress.Add("city", ALLTRIM(address.ad_city))
	l_oAddress.Add("company", ALLTRIM(address.ad_company))
	l_oAddress.Add("country", ALLTRIM(address.ad_country))
	l_oAddress.Add("email", ALLTRIM(address.ad_email))
	l_oAddress.Add("fax", ALLTRIM(address.ad_fax))
	l_oAddress.Add("fname", ALLTRIM(address.ad_fname))
	l_oAddress.Add("id", address.ad_addrid)
	l_oAddress.Add("lname", ALLTRIM(address.ad_lname))
	l_oAddress.Add("phone", ALLTRIM(address.ad_phone))
	l_oAddress.Add("phone2", ALLTRIM(address.ad_phone2))
	l_oAddress.Add("phone3", ALLTRIM(address.ad_phone3))
	l_oAddress.Add("salute", ALLTRIM(address.ad_salute))
	l_oAddress.Add("street", ALLTRIM(address.ad_street))
	l_oAddress.Add("street2", ALLTRIM(address.ad_street2))
	l_oAddress.Add("titlcod", address.ad_titlcod)
	l_oAddress.Add("title", ALLTRIM(address.ad_title))
	l_oAddress.Add("zip", ALLTRIM(address.ad_zip))
	
ENDIF

GO l_nRecNo IN address

RETURN l_oAddress
ENDPROC
*	
PROCEDURE Release
this.oFormSet = .NULL.
RELEASE this
ENDPROC
*
ENDDEFINE