#INCLUDE "include\constdefines.h"
* procedures and valid function for araccountsform.scx
FUNCTION Araccount
LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
     lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam0
LOCAL l_uRetval
DO CASE
     CASE TYPE("lp_cFuncName") <> "C"
          l_uRetval = .F.
     CASE PCOUNT()-1 = 1
          l_uRetval = &lp_cFuncName(@lp_uParam1)
     CASE PCOUNT()-1 = 2
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2)
     CASE PCOUNT()-1 = 3
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3)
     CASE PCOUNT()-1 = 4
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3, @lp_uParam4)
     CASE PCOUNT()-1 = 5
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3, @lp_uParam4, @lp_uParam5)
     CASE PCOUNT()-1 = 6
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3, @lp_uParam4, @lp_uParam5, ;
               @lp_uParam6)
     CASE PCOUNT()-1 = 7
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3, @lp_uParam4, @lp_uParam5, ;
               @lp_uParam6, @lp_uParam7)
     CASE PCOUNT()-1 = 8
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3, @lp_uParam4, @lp_uParam5, ;
               @lp_uParam6, @lp_uParam7, @lp_uParam8)
     CASE PCOUNT()-1 = 9
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3, @lp_uParam4, @lp_uParam5, ;
               @lp_uParam6, @lp_uParam7, @lp_uParam8, @lp_uParam9)
     CASE PCOUNT()-1 = 10
          l_uRetval = &lp_cFuncName(@lp_uParam1, @lp_uParam2, @lp_uParam3, @lp_uParam4, @lp_uParam5, ;
               @lp_uParam6, @lp_uParam7, @lp_uParam8, @lp_uParam9, @lp_uParam0)
     OTHERWISE
          l_uRetval = &lp_cFuncName()
ENDCASE
RETURN l_uRetval
ENDFUNC
* Return Address block String from address
FUNCTION ArSayAddr
LPARAMETER pnAddrId, pnApId, lcRet
lcRet=''
IF !USED('address1')
	RETURN
ENDIF
IF EMPTY(pnAddrId)
	RETURN
ENDIF
IF SEEK(pnAddrId,'address1','tag1') AND EMPTY(pnApId)
	IF  !EMPTY(address1.ad_company)
		lcRet=flIp(address1.ad_company)+CHR(13)+CHR(10)
	ENDIF
	lcRet=lcRet+TRIM(address1.ad_title)+' '+TRIM(address1.ad_fname)+' '+ flIp(address1.ad_lname) +CHR(13)+CHR(10)
	lcRet=lcRet+address1.ad_street +CHR(13)+CHR(10)
	lcRet=lcRet+ TRIM(address1.ad_zip)+' '+TRIM(address1.ad_city)+ IIF(address1.ad_country<>PARAM.pa_country, ' '+address1.ad_country, '') +CHR(13)+CHR(10)
	lcRet=lcRet+ 'Tel:'+TRIM(address1.ad_phone)+' Fax:'+TRIM(address1.ad_fax)
ELSE
    IF NOT EMPTY(pnApId) AND USED('apartner') AND SEEK(pnApId,'apartner','tag3')
        IF NOT EMPTY(address1.ad_company)
            lcRet=flIp(address1.ad_company)+CHR(13)+CHR(10)
        ENDIF
        lcRet=lcRet+TRIM(apartner.ap_title)+' '+TRIM(apartner.ap_fname)+' '+ flIp(apartner.ap_lname) +CHR(13)+CHR(10)
        lcRet=lcRet+address1.ad_street +CHR(13)+CHR(10)
        lcRet=lcRet+ TRIM(address1.ad_zip)+' '+TRIM(address1.ad_city)+ IIF(address1.ad_country<>PARAM.pa_country, ' '+address1.ad_country, '') +CHR(13)+CHR(10)
        lcRet=lcRet+'Tel:'+TRIM(apartner.ap_phone1)+' Fax:'+TRIM(apartner.ap_fax)
    ELSE
        = alErt("Address ID not found!")
    ENDIF
ENDIF
RETURN lcRet
ENDFUNC

* Return date of Last Statement
FUNCTION ArLastStatement
PARAMETER pnAcct,ldRet
LOCAL naRea, naPrec
ldRet={}
naRea = SELECT()
SELECT arPost
naPrec = RECNO()
CALCULATE MAX(ap_stmlast) TO ldRet FOR ap_aracct=pnAcct .AND. ap_headid=ap_lineid
GOTO naPrec
SELECT (naRea)
RETURN ldRet
ENDFUNC

* Return date of Last Reminder
FUNCTION ArLastReminder
PARAMETER pnAcct,ldRet
LOCAL naRea, naPrec
ldRet={}
naRea = SELECT()
SELECT arPost
naPrec = RECNO()
CALCULATE MAX(ap_remlast) TO ldRet FOR ap_aracct=pnAcct .AND. ap_headid=ap_lineid
GOTO naPrec
SELECT (naRea)
RETURN ldRet
ENDFUNC

* Return description for Type
FUNCTION ArSayType
PARAMETER pcType,lcRet
LOCAL lcAlias,lcTmp
lcAlias=ALIAS()
lcRet=''
SELECT Picklist
LOCATE FOR ALLTRIM(pl_label)=='ACCTTYPE' .AND. ALLTRIM(pl_charcod)==ALLTRIM(pcType)
IF FOUND()
	lcTmp="lcRet=pl_lang"+ g_Langnum
	&lcTmp
ENDIF
IF !EMPTY(lcAlias)
	SELECT &lcAlias
ENDIF

RETURN lcRet
ENDFUNC

* Check ArAccount
* retrun '' if all OK
* return string with Error Message
FUNCTION CheckArAccount
PARAMETERS cAracct,nAddrid,plNew,lcRet,plInactive,plCreditors
LOCAL cCompany,niD,naCct ,lcAlias,lcFilter
lcAlias=ALIAS()
lcRet=''
IF EMPTY(cAracct)
	lcRet=GetLangText("AR","TA_ACCTREQ")
ENDIF
IF EMPTY(lcRet) .AND. EMPTY(nAddrid)
	lcRet=GetLangText("AR","TA_COMPREQ")
ENDIF
IF EMPTY(lcRet) .AND. plNew
	SELECT aracct
	lnRn=RECNO()
     lcFilter = FILTER()
     SET FILTER TO
	LOCATE FOR  ac_aracct=cAracct&& .AND. RECNO()<>lnRn
	IF FOUND()
		cCompany = TRIM(dlOokup('Address','ad_addrid = '+sqLcnv(aracct.ac_addrid),'Trim(ad_company) + [, ] + Trim(ad_lname)'))
		lcRet=stRfmt(GetLangText("AR","TA_ACCTEXIST"),cAracct,cCompany)
	ENDIF
     SET FILTER TO &lcFilter
	GO lnRn
ENDIF
IF EMPTY(lcRet) AND NOT plInactive
     * Here code relies on fact, that we have SET FILTER on ArAcct alias, and see only debitors or 
     * only Creditors!
     niD = dlOokup('ArAcct','ac_aracct <> '+sqLcnv(cAracct)+ ' AND ac_addrid = '+sqLcnv(nAddrid) + ;
               ' AND NOT ac_inactiv','ac_addrid')
     IF niD>0
          naCct = dlOokup('ArAcct','ac_addrid = '+sqLcnv(nAddrid),'ac_aracct')
          cCompany = TRIM(dlOokup('Address','ad_addrid = '+sqLcnv(niD),'Trim(ad_company) + [, ] + Trim(ad_lname)'))
          lcRet=stRfmt(GetLangText("AR","TA_ACCTLINK"),cCompany,naCct)
     ENDIF
ENDIF
IF !EMPTY(lcAlias)
	SELECT &lcAlias
ENDIF

RETURN lcRet
ENDFUNC

PROCEDURE ArApHide
LPARAMETERS lp_nHeadid, lp_nLineid
* lp_nHeadid is value of Ap_headid field in ArPost table
* lp_nLineid is value of Ap_lineid field in ArPost table, and it is neaded only when Ap_headid=0 (unallocated payment)
 LOCAL l_nARea, l_nRecNo, l_lInsert, l_nBalance, l_recArPost, l_recPost
 l_nARea = SELECT()
 SELECT arpost
 l_nRecNo = RECNO()

 l_lInsert = .F.
 IF lp_nHeadid <> 0
     l_nBalance = ArPstBal(lp_nHeadid,0,.F.)
     LOCATE FOR ap_lineid = lp_nHeadid
     IF FOUND()
         *DO BillNumChange IN ProcBill WITH ap_billnr, "CANCEL", "from A/R Accounts (Debitoren)"
         REPLACE ap_hiden WITH .T. ALL FOR ap_headid = lp_nHeadid
         LOCATE FOR ap_lineid = lp_nHeadid
         l_lInsert = .T.
     *ELSE
         *MESSAGEBOX("Unsuccessful deleting!")
     ENDIF
 ELSE
     l_nBalance = 0
     LOCATE FOR ap_lineid = lp_nLineid
     IF FOUND()
         REPLACE ap_hiden WITH .T.
         l_lInsert = .T.
         l_nBalance = arpost.ap_debit - arpost.ap_credit
     *ELSE
         *MESSAGEBOX("Unsuccessful deleting!")
     ENDIF
 ENDIF

 IF l_lInsert
     * Insert into post opposing postment (Gegenbuchung)
     SELECT post
     SCATTER MEMO NAME l_recPost BLANK
     l_recPost.ps_postid  = nextid('POST')

     * Insert into arpost opposing postment (Gegenbuchung)
     SELECT arpost
     SCATTER MEMO NAME l_recArPost
     l_recArPost.ap_billnr = ""
     l_recArPost.ap_postid = l_recPost.ps_postid
     l_recArPost.ap_remcnt = 0
     l_recArPost.ap_remlast = {}
     l_recArPost.ap_remlev = 0
     l_recArPost.ap_credit  = l_nBalance
     l_recArPost.ap_debit   = 0
     l_recArPost.ap_belgdat = sysdate()
     l_recArPost.ap_sysdate = sysdate()
     l_recArPost.ap_userid  = g_userid
     l_recArPost.ap_cashier = g_cashier
     l_recArPost.ap_lineid  = nextid('ARPOST')
     APPEND BLANK
     GATHER NAME l_recArPost

     * Insert into post opposing postment (Gegenbuchung)
     SELECT post
     l_recPost.ps_tano    = .T.
     l_recPost.ps_split   = .F.
     l_recPost.ps_ifc     = arpost.ap_billnr
     l_recPost.ps_origid  = arpost.ap_reserid
     l_recPost.ps_reserid = arpost.ap_reserid
     l_recPost.ps_addrid  = 0
     l_recPost.ps_cancel  = .F.
     l_recPost.ps_cashier = g_cashier
     l_recPost.ps_userid  = g_userid
     l_recPost.ps_date    = sysdate()
     l_recPost.ps_price   = 1
     l_recPost.ps_prtype  = 0
     l_recPost.ps_setid   = 0
     l_recPost.ps_supplem = DTOC(arpost.ap_date)+arpost.ap_ref
     l_recPost.ps_time    = TIME()
     l_recPost.ps_touched = .F.
     l_recPost.ps_window  = 0

     IF lp_nHeadid = lp_nLineid
         l_recPost.ps_units = -arpost.ap_credit
     ELSE
         l_recPost.ps_units = arpost.ap_credit
     ENDIF
     l_recPost.ps_amount  = -l_recPost.ps_units
     IF EMPTY(arpost.ap_paynum)
         l_recPost.ps_paynum  = 0
         l_recPost.ps_artinum = arpost.ap_artinum
     ELSE
         l_recPost.ps_paynum  = arpost.ap_paynum
         l_recPost.ps_artinum = 0
     ENDIF
     APPEND BLANK
     GATHER NAME l_recPost

     IF lp_nHeadid <> lp_nLineid
         l_recPost.ps_units   = -l_recPost.ps_units
         l_recPost.ps_amount  = -l_recPost.ps_units
         l_recPost.ps_paynum  = param.pa_payonld
         l_recPost.ps_artinum = 0
         l_recPost.ps_postid  = nextid('POST')
         APPEND BLANK
         GATHER NAME l_recPost
     ENDIF
 ENDIF
 SELECT arpost
 GO l_nRecNo
 SELECT (l_nARea)
ENDPROC

* Transfer postings from account to another account
PROCEDURE arapTransfer
LPARAMETERS ntoacct
LOCAL naDdressid,ctOcompany,naRea,niD 
naRea = SELECT() 
SELECT aracct
LOCATE FOR ac_aracct=ntoacct
IF FOUND()
	naDdressid = aracct.ac_addrid
ELSE
	naDdressid = 0
ENDIF

IF EMPTY(naDdressid)
	= alErt(stRfmt(GetLangText("AR","TA_NOACCT"),ntOacct))
ELSE
	ctOcompany = TRIM(dlOokup('Address','ad_addrid = '+ sqLcnv(naDdressid),'Trim(ad_company) + [, ] + Trim(ad_lname)'))
	IF yeSno(stRfmt(GetLangText("AR","TA_YESTRANSTO"),ntOacct,ctOcompany))
		naRea = SELECT()
		SELECT arPost
		IF arPost.ap_headid=0
			niD = arPost.ap_lineid
			REPLACE ap_aracct WITH ntOacct ALL FOR ap_lineid=niD
		ELSE
			niD = arPost.ap_headid
			REPLACE ap_aracct WITH ntOacct ALL FOR ap_headid=niD
		ENDIF
	ENDIF
ENDIF

ENDPROC

* move payment from one bill to another
PROCEDURE ApAllocatePayment
LPARAMETERS cBillNr
IF EMPTY(cBillNr)
	= alErt(stRfmt(GetLangText("AR","TA_NOBILL"), cBillNr))
	RETURN
ENDIF
LOCAL lcAlias,nhEaderid 
lcAlias=ALIAS()
SELECT arpost
IF ap_paynum>0 && Any payment can be allocated.
	nhEaderid = dlOokup('ArPost','ap_billnr = '+sqLcnv(cbIllnr),'ap_headid')
	IF nhEaderid>0
		REPLACE ap_headid WITH nhEaderid IN arpost
	ELSE
		= alErt(stRfmt(GetLangText("AR","TA_NOBILL"),cbIllnr))
	ENDIF
ELSE
	= alErt(GetLangText("AR","TA_NOTPAYMENT"))
ENDIF
IF !EMPTY(lcAlias)
	SELECT &lcAlias
ENDIF
ENDPROC

* Check payment 
FUNCTION ArApPayValid
 PARAMETER ddate,npaynum,namt,ndefamt,lpayall,lcRet
lcRet=''
 IF EMPTY(ddate)
      lcRet=GetLangText("AR","TA_DATEREQ")
 ENDIF
 IF EMPTY(lcRet) .and. EMPTY(npaynum)
      lcRet=GetLangText("AR","TA_PAYREQ")
 ENDIF
 IF EMPTY(lcRet) .and. EMPTY(naMt)
      lcRet=GetLangText("AR","TA_AMTREQ")
 ENDIF
 
 IF EMPTY(lcRet) .and. lPayAll .and. namt>ndefamt
 	lcRet=GetLangText("AR","TA_AMT_IS_GREATHER_THAN_BILLS_BALANCE")
 endif
ENDFUNC

* Check adjustment
FUNCTION arapadjustvalid
LPARAMETERS ddate,nartinum,namt,lcRet
lcRet=''
IF EMPTY(ddate)
	lcRet=GetLangText("AR","TA_DATEREQ")
ENDIF
IF EMPTY(lcRet) .and. EMPTY(nartinum)
	lcRet=GetLangText("AR","TA_ARTREQ")
ENDIF
IF EMPTY(lcRet) .and. EMPTY(naMt)
	lcRet=GetLangText("AR","TA_AMTREQ")
ENDIF
ENDFUNC

PROCEDURE ArCreateBill
LPARAMETERS lp_oData
LOCAL l_lSuccess
lp_oData.ap_lineid = neXtid('ARPOST')
lp_oData.ap_headid = lp_oData.ap_lineid
lp_oData.ap_userid = g_userid
INSERT INTO arpost FROM NAME lp_oData
l_lSuccess = DoTableUpdate(.T.,.T.,"arpost")
EndTransaction()
RETURN l_lSuccess
ENDPROC

PROCEDURE ArUpdateBill
LPARAMETERS lp_oData
LOCAL l_lSuccess, l_nSelect
IF dlocate("arpost","ap_lineid = " + sqlcnv(lp_oData.ap_lineid))
     l_nSelect = SELECT()
     SELECT arpost
     GATHER NAME lp_oData MEMO
     l_lSuccess = DoTableUpdate(.T.,.T.,"arpost")
     EndTransaction()
     SELECT (l_nSelect)
ENDIF
RETURN l_lSuccess
ENDPROC

FUNCTION PrintBillCopy
LPARAMETERS pcBillNum, pnReserId
LOCAL lnAddressRecNo, lnAddressOrder, lnAddressOpened
LOCAL lnHistresRecNo, lnHistresOrder, lnHistresOpened
LOCAL lnHistpostRecNo, lnHistpostOrder, lnHistpostOpened
LOCAL lnRatecodeRecNo, lnRatecodeOrder,lnRatecodeOpened
LOCAL lnArticleRecNo, lnAddressOrder, lnArticleOpened
LOCAL lnPaymethoRecNo, lnPaymethoOrder, lnPaymethoOpened
LOCAL lnReservatRecNo, lnReservatOrder, lnReservatOpened
LOCAL lnArea, lnBillWindow, i, lRet, LDefStyle, lcHrTemp, l_nBillAddrId, llUseBDateInStyle
PRIVATE nsTyle
lret = .F.
LDefStyle = ""
lnBillWindow = 0
nsTyle = 0
lcHrTemp = SYS(2015)
lnArea = SELECT()
IF USED('address')
	lnAddressOpened = .T.
	lnAddressRecNo = RECNO('address')
	lnAddressOrder = ORDER('address')
ELSE
	openfiledirect(.F., "address")
ENDIF
SET ORDER TO TAG1 IN address
IF USED('paymetho')
	lnPaymethoOpened = .T.
	lnPaymethoRecNo = RECNO('paymetho')
	lnPaymethoOrder = ORDER('paymetho')
ELSE
	openfiledirect(.F., "paymetho")
ENDIF
SET ORDER TO TAG1 IN paymetho
IF USED('article')
	lnArticleOpened = .T.
	lnArticleRecNo = RECNO('article')
	lnArticleOrder = ORDER('article')
ELSE
	openfiledirect(.F., "article")
ENDIF
SET ORDER TO TAG1 IN article
IF USED('ratecode')
	lnRatecodeOpened = .T.
	lnRatecodeRecNo = RECNO('ratecode')
	lnRatecodeOrder = ORDER('ratecode')
ELSE
	openfiledirect(.F., "ratecode")
ENDIF
SET ORDER TO TAG1 IN ratecode
IF USED('histres')
	lnHistresOpened= .T.
	lnHistresRecNo= RECNO('histres')
	lnHistresOrder= ORDER('histres')
ELSE
	openfiledirect(.F., "histres")
ENDIF
SET ORDER TO TAG1 IN histres
openfiledirect(.F., "histres", lcHrTemp)
IF USED('histpost')
	lnHistpostOpened= .T.
	lnHistpostRecNo= RECNO('histpost')
	lnHistpostOrder= ORDER('histpost')
ELSE
	openfiledirect(.F., "histpost")
ENDIF
IF USED('reservat')
	lnReservatOpened= .T.
	lnReservatRecNo= RECNO('reservat')
	lnReservatOrder= ORDER('reservat')
ELSE
	openfiledirect(.F., "reservat")
ENDIF
SET ORDER TO TAG1 IN reservat

SELECT(lcHrTemp)
IF pnReserId == 0.1
	lnBillWindow = 1
ELSE
	IF SEEK(pnReserId, lcHrTemp, "tag1")
		FOR i = 1 TO 6
			IF pcBillNum = FNGetBillData(hr_reserid, i, "bn_billnum")
				lnBillWindow = i
				EXIT
			ENDIF
		ENDFOR
	ENDIF
ENDIF
IF NOT EMPTY(lnBillWindow)
	DO IsBill IN BillHist WITH pnReserId, lnBillWindow, lRet, pcBillNum
	IF lRet
		IF pnReserId == 0.1
			DO PrintPassCopy IN BillHist WITH pcBillNum, .T.
		ELSE
			nStyle = ProcBillStyle(hr_rsid, lnBillWindow, @llUseBDateInStyle, .T.)
			l_nBillAddrId = dlookup("billnum","bn_billnum = " + sqlcnv(pcBillNum,.T.),"bn_addrid")
			DO PrintCopy IN BillHist WITH pnReserId, lnBillWindow, .T., nStyle, llUseBDateInStyle, l_nBillAddrId
		ENDIF
	ENDIF
ELSE
	= Alert(StrFmt(GetLangText("AR", "TA_NOBILL"), pcBillNum))
ENDIF

IF lnAddressOpened
	IF NOT EMPTY(lnAddressOrder)
		SET ORDER TO &lnAddressOrder IN address
	ENDIF
	GO lnAddressRecNo IN address
ELSE
	USE IN address
ENDIF
IF lnPaymethoOpened
	IF NOT EMPTY(lnPaymethoOrder)
		SET ORDER TO &lnPaymethoOrder IN paymetho
	ENDIF
	GO lnPaymethoRecNo IN paymetho
ELSE
	USE IN paymetho
ENDIF
IF lnArticleOpened
	IF NOT EMPTY(lnArticleOrder)
		SET ORDER TO &lnArticleOrder IN article
	ENDIF
	GO lnArticleRecNo IN article
ELSE
	USE IN article
ENDIF
IF lnRatecodeOpened
	IF NOT EMPTY(lnRatecodeOrder)
		SET ORDER TO &lnRatecodeOrder IN ratecode
	ENDIF
	GO lnRatecodeRecNo IN ratecode
ELSE
	USE IN ratecode
ENDIF
IF lnHistresOpened
	IF NOT EMPTY(lnHistresOrder)
		SET ORDER TO &lnHistresOrder IN histres
	ENDIF
	GO lnHistresRecNo IN histres
ELSE
	USE IN histres
ENDIF
IF lnHistpostOpened
	IF NOT EMPTY(lnHistpostOrder)
		SET ORDER TO &lnHistpostOrder IN histpost
	ENDIF
	GO lnHistpostRecNo IN histpost
ELSE
	USE IN histpost
ENDIF
IF lnReservatOpened
	IF NOT EMPTY(lnReservatOrder)
		SET ORDER TO &lnReservatOrder IN reservat
	ENDIF
	GO lnReservatRecNo IN reservat
ELSE
	USE IN reservat
ENDIF
IF USED(lcHrTemp)
	USE IN (lcHrTemp)
ENDIF
SELECT(lnArea)
RETURN .T.
ENDFUNC

PROCEDURE ArApBalanceOut
LPARAMETERS lp_nPostingsBalance, lp_PaymentsBalace
* This procedure expects CArPost cursor with Cap_Marker logical field that indicates to marked records.
* And it expects Cap_OldHeadId numeric field like store for ID that could be changed.
 LOCAL l_cOrder
 SELECT carpost
 * first go thru selected payments
 * from every payment make free payment (yellow)
 * store bill nr. to which this payment has belonged in carpost.cap_headid
 SCAN FOR cap_marker AND (ap_paynum <> 0) AND (ap_headid <> ap_lineid)
	REPLACE cap_headid WITH carpost.ap_headid, ;
			ap_headid WITH 0
	IF SEEK(ap_lineid, 'arpost', 'tag1')
		REPLACE ap_headid WITH 0 IN arpost
	ENDIF
 ENDSCAN
 * now scan thru all marked records, bills and payments
 SCAN FOR cap_marker
 	* if this is a bill
	IF ap_headid = ap_lineid
		= ArApBalancePosting()
	ELSE
	* if this is a payment
		= ArApBalancePayment()
	ENDIF
 ENDSCAN
 l_cOrder = ORDER()
 SET ORDER TO
 * find all payments which were not free payment
 SCAN FOR cap_headid > 0
 	* check if there are not allocated payment, and return those payments to bill in ap_headid
	IF SEEK(ap_lineid, "arpost", "tag1") AND arpost.ap_headid == 0
		REPLACE ap_headid WITH carpost.cap_headid
		REPLACE ap_headid WITH carpost.cap_headid IN arpost
	ENDIF
	REPLACE cap_headid WITH 0
 ENDSCAN
 SET ORDER TO l_cOrder
ENDPROC

PROCEDURE ArApBalancePosting

 LOCAL l_nPostingBalance, l_nRecNo, l_nPaymentBalance, l_nStartBalance
 LOCAL l_nArAcct, l_nReserId, l_nHeadId, l_cRef
 SELECT CArPost
 l_nPostingBalance = ArPstBal(ap_headid, 0, .F.)
 l_nStartBalance = l_nPostingBalance
 l_nArAcct = ap_aracct
 l_nReserId = ap_reserid
 l_nHeadId = ap_headid
 * if bill has negative balance, then skip while this bill is overpayed(?)
 IF l_nPostingBalance <= 0
	RETURN l_nPostingBalance
 ENDIF
 l_nRecNo = RECNO()
 * go thru payments, and try to balance this bill
 SCAN FOR (ap_paynum <> 0) .AND. (ap_headid <> ap_lineid) ;
		.AND. cap_marker .AND. (l_nPostingBalance > 0)
	l_nPaymentBalance = ap_credit - ap_debit
	* if this is a negative payment, then skip to next payment
	IF l_nPaymentBalance <= 0
		LOOP
	ENDIF
	IF NOT "[Betrag:" $ ap_ref
		l_cRef = ALLTRIM(ap_ref) + "[Betrag:" + ;
				ALLTRIM(STR(ap_credit - ap_debit, 10, 2)) + "]"
	ELSE
		l_cRef = ALLTRIM(ap_ref)
	ENDIF
	IF l_nPaymentBalance <= l_nPostingBalance
		IF SEEK(ap_lineid, 'arpost', 'tag1')
			l_cMessage = ArApAlloc(ap_headid)
			IF EMPTY(l_cMessage)
				REPLACE cap_marker WITH .F., ;
						ap_ref WITH l_cRef
				REPLACE ap_ref WITH l_cRef IN arpost
				IF ap_debit < 0
					REPLACE ap_debit WITH 0, ;
							ap_credit WITH l_nPaymentBalance
					REPLACE ap_debit WITH 0, ;
							ap_credit WITH l_nPaymentBalance IN arpost
				ENDIF
				l_nPostingBalance = l_nPostingBalance - l_nPaymentBalance
			ENDIF
		ENDIF
	ELSE
		IF ap_debit < 0
			REPLACE ap_debit WITH MIN(0, ap_debit + l_nPostingBalance)
		ENDIF
		REPLACE ap_credit WITH l_nPaymentBalance - l_nPostingBalance + ap_debit, ;
				ap_ref WITH l_cRef
		IF SEEK(ap_lineid, 'arpost', 'tag1')
			IF ap_debit < 0
				REPLACE ap_debit WITH MIN(0, ap_debit + l_nPostingBalance) IN arpost
			ENDIF
			REPLACE ap_credit WITH l_nPaymentBalance - l_nPostingBalance + ap_debit, ;
					ap_ref WITH l_cRef IN arpost
		ENDIF
		ArApPay(l_nArAcct, sysdate(), ap_paynum, l_cRef, l_nPostingBalance, ;
				l_nReserId, l_nHeadId)
		l_nPostingBalance = 0
	ENDIF
 ENDSCAN
 
 GO l_nRecNo
 IF l_nPostingBalance == 0
	REPLACE cap_marker WITH .F.
 ENDIF
 RETURN (l_nStartBalance - l_nPostingBalance)
ENDPROC

PROCEDURE ArApBalancePayment

 LOCAL l_nPaymentBalance, l_nRecNo, l_nPostingBalance, l_nStartBalance
 LOCAL l_nPayNum, l_cRef
 LOCAL l_nPayLineId, l_cMessage, l_lIsGutschrift
 SELECT CArPost
 l_nPaymentBalance = ap_credit - ap_debit
 l_nStartBalance = l_nPaymentBalance
 l_nPayLineId = ap_lineid
 l_nPayNum = ap_paynum
 IF NOT "[Betrag:" $ ap_ref
	l_cRef = ALLTRIM(ap_ref) + "[Betrag:" + ALLTRIM(STR(l_nStartBalance, 10, 2)) + "]"
 ELSE
	l_cRef = ALLTRIM(ap_ref)
 ENDIF
 IF l_nPaymentBalance = 0
	RETURN 0
 ENDIF
 l_nRecNo = RECNO()
 * scan thru bills
 SCAN FOR (ap_headid = ap_lineid) .AND. cap_marker .AND. (l_nPaymentBalance <> 0)
	l_nPostingBalance = ArPstBal(ap_headid, 0, .F.)
	l_lIsGutschrift = (ap_credit = 0 AND ap_debit < 0)
	* add payment to bill only when bill is in minus. Do not overpay
	* only exepction can be "Gutschrift" bill
	IF l_nPostingBalance <= 0 AND NOT l_lIsGutschrift
		LOOP
	ENDIF
	* is whole payment gone to this bill?
	IF l_nPaymentBalance <= l_nPostingBalance
		IF SEEK(l_nPayLineId, 'arpost', 'tag1')
			l_cMessage = ArApAlloc(cArpost.ap_headid)
			IF EMPTY(l_cMessage)
				* if we covered whole bill with this payment, then unmark it
				IF l_nPaymentBalance == l_nPostingBalance
					REPLACE cap_marker WITH .F.
				ENDIF
				GO l_nRecNo
				* now jump to payment
				REPLACE cap_marker WITH .F., ;
						ap_ref WITH l_cRef
				REPLACE ap_ref WITH l_cRef IN arpost
				
				IF ap_debit < 0
					REPLACE ap_debit WITH 0
					REPLACE ap_debit WITH 0 IN arpost
				ENDIF
				REPLACE ap_credit WITH l_nPaymentBalance + ap_debit
				REPLACE ap_credit WITH l_nPaymentBalance + ap_debit IN arpost
				l_nPaymentBalance = 0
				EXIT
			ENDIF
		ENDIF
	ELSE
		REPLACE cap_marker WITH .F.
		ArApPay(ap_aracct, sysdate(), l_nPayNum, l_cRef, l_nPostingBalance, ;
				ap_reserid, ap_headid)
		l_nPaymentBalance = l_nPaymentBalance - l_nPostingBalance
	ENDIF
 ENDSCAN

 GO l_nRecNo

 IF NOT EMPTY(l_nPaymentBalance) AND (l_nPaymentBalance <> (ap_credit - ap_debit))
	REPLACE ap_ref WITH l_cRef
	REPLACE ap_ref WITH l_cRef IN arpost
	IF ap_debit < 0
		REPLACE ap_debit WITH MIN(0, ap_credit - l_nPaymentBalance)
		REPLACE ap_debit WITH MIN(0, ap_credit - l_nPaymentBalance) IN arpost
	ENDIF
	REPLACE ap_credit WITH l_nPaymentBalance + ap_debit
	REPLACE ap_credit WITH l_nPaymentBalance + ap_debit IN arpost
 ENDIF
 RETURN (l_nStartBalance - l_nPaymentBalance)
ENDPROC

PROCEDURE ArApAlloc
LPARAMETERS lp_nHeaderId
 LOCAL l_cAlias, l_cReturnMessage
 DO CASE
  CASE NOT (lp_nHeaderId > 0)
	l_cReturnMessage = GetLangText("AR","TXT_NOT_BILL")
  CASE NOT (arpost.ap_paynum > 0)
	l_cReturnMessage = GetLangText("AR","TA_NOTPAYMENT")
  OTHERWISE
	REPLACE ap_headid WITH lp_nHeaderId IN arpost
	l_cReturnMessage = ""
 ENDCASE
 RETURN l_cReturnMessage
ENDPROC

PROCEDURE ArApPay
LPARAMETERS lp_aracct, lp_belgdat, lp_paynum, lp_ref, lp_credit, lp_reserid, lp_headid, lp_cMarkedRowsCur
 LOCAL l_cAlias, l_nRecNo, l_recAP, l_cAliasToSelect
 l_cAlias = ALIAS()
 IF PCOUNT() = 8
 	l_cAliasToSelect = lp_cMarkedRowsCur
 ELSE
 	l_cAliasToSelect = "arpost"
 ENDIF
 SELECT (l_cAliasToSelect)
 l_nRecNo = RECNO()
 SCATTER MEMO NAME l_recAP BLANK
 l_recAP.ap_aracct  = lp_aracct
 l_recAP.ap_date    = sysdate()
 l_recAP.ap_belgdat = lp_belgdat
 l_recAP.ap_paynum  = lp_paynum
 l_recAP.ap_ref     = lp_ref
 l_recAP.ap_sysdate = sysdate()
 l_recAP.ap_credit  = lp_credit
 l_recAP.ap_userid  = g_userid
 l_recAP.ap_cashier = g_cashier
 l_recAP.ap_reserid = lp_reserid
 l_recAP.ap_headid  = lp_headid
 l_recAP.ap_lineid  = nextid('ARPOST')
 SELECT (l_cAliasToSelect)
 APPEND BLANK
 GATHER NAME l_recAP MEMO
 GO l_nRecNo
 IF NOT EMPTY(l_cAlias)
	SELECT &l_cAlias
 ENDIF
ENDPROC

PROCEDURE ArRemainders
LPARAMETERS lp_addrid, lp_nBalance, lp_nRem0, lp_nRem1, lp_nRem2, lp_nRem3, lp_nRemX
 LOCAL l_nPstBal
 STORE 0 TO lp_nBalance, lp_nRem0, lp_nRem1, lp_nRem2, lp_nRem3, lp_nRemX, l_nPstBal
 SELECT ap_remlev, ap_headid, ap_lineid, ap_debit, ap_credit ;
           FROM aracct ;
           LEFT JOIN arpost ON ap_aracct = ac_aracct ;
           WHERE ac_addrid = lp_addrid AND EMPTY(ap_hiden) AND NOT ac_inactiv ;
           INTO CURSOR curRemainders
 SELECT curRemainders
 SCAN
      lp_nBalance = lp_nBalance + ap_debit - ap_credit
      IF ap_headid = ap_lineid
           l_nPstBal = ArPstBal(ap_headid, ap_lineid, .F.)
           DO CASE
                CASE ap_remlev = 0
                     lp_nRem0 = lp_nRem0 + l_nPstBal
                CASE ap_remlev = 1
                     lp_nRem1 = lp_nRem1 + l_nPstBal
                CASE ap_remlev = 2
                     lp_nRem2 = lp_nRem2 + l_nPstBal
                CASE ap_remlev = 3
                     lp_nRem3 = lp_nRem3 + l_nPstBal
                OTHERWISE
                     lp_nRemX = lp_nRemX + l_nPstBal
           ENDCASE
      ENDIF
 ENDSCAN
 USE
 RETURN .T.
ENDPROC
*
PROCEDURE ArAcctRemainders
LPARAMETERS lp_nAracct, lp_nBalance, lp_nRem0, lp_nRem1, lp_nRem2, lp_nRem3, lp_nRemX, lp_cForecRemLev, lp_nDisputed, lp_nFreePayments, ;
 		lp_nCountCA, lp_nCountX, lp_lNoForecast
 LOCAL l_nPstBal, l_nRemainderLevel, l_nRemLev1, l_nRemLev2, l_nRemLev3, l_nRemLevX, l_nSelect, l_cCurRemainders, l_lDisputed
 STORE 0 TO lp_nBalance, lp_nRem0, lp_nRem1, lp_nRem2, lp_nRem3, lp_nRemX, l_nPstBal, lp_nDisputed, lp_nFreePayments, lp_nCountCA, lp_nCountX
 l_cCurRemainders = SYS(2015)
 l_nSelect = SELECT()
 lp_cForecRemLev = ""
 SELECT ap_remlev, ap_headid, ap_lineid, ap_debit, ap_credit, ap_dispute, ap_disdate, ap_sysdate, ap_remlast, ap_aracct, ap_duedat, ap_colagnt ;
           FROM arpost ;
           WHERE ap_aracct = lp_nAracct AND EMPTY(ap_hiden) ;
           INTO CURSOR &l_cCurRemainders

 SELECT &l_cCurRemainders
 SCAN
      lp_nBalance = lp_nBalance + ap_debit - ap_credit
      l_lDisputed = ArIsDisputed(ap_dispute, ap_disdate)
      IF l_lDisputed
           lp_nDisputed = lp_nDisputed + ap_debit - ap_credit
      ENDIF
      IF ap_headid = ap_lineid
           l_nPstBal = ArPstBal(ap_headid, ap_lineid, .F.)
           IF l_nPstBal <> 0
                DO CASE
                     CASE ap_remlev = 0
                          lp_nRem0 = lp_nRem0 + l_nPstBal
                     CASE ap_remlev = 1
                          lp_nRem1 = lp_nRem1 + l_nPstBal
                     CASE ap_remlev = 2
                          lp_nRem2 = lp_nRem2 + l_nPstBal
                     CASE ap_remlev = 3
                          lp_nRem3 = lp_nRem3 + l_nPstBal
                     OTHERWISE
                          lp_nRemX = lp_nRemX + l_nPstBal
                ENDCASE
                IF ap_colagnt
	                lp_nCountCA = lp_nCountCA + 1
                ENDIF
                IF ap_remlev = 4
                	lp_nCountX = lp_nCountX + 1
                ENDIF
                IF NOT lp_lNoForecast
	                l_nRemainderLevel = arremainderforecast(ap_headid, ap_lineid, l_lDisputed, l_nPstBal, ap_sysdate, ap_remlast, ;
	                          ap_remlev, ap_aracct, ap_duedat)
	                DO CASE
	                     CASE l_nRemainderLevel = 1
	                          l_nRemLev1 = .T.
	                     CASE l_nRemainderLevel = 2
	                          l_nRemLev2 = .T.
	                     CASE l_nRemainderLevel = 3
	                          l_nRemLev3 = .T.
	                     CASE l_nRemainderLevel = 4
	                          l_nRemLevX = .T.
	                ENDCASE
	            ENDIF
           ENDIF
      ELSE           
           IF ap_headid = 0
                lp_nFreePayments = lp_nFreePayments + ArPstBal(ap_headid, ap_lineid, .F.)
           ENDIF
      ENDIF
 ENDSCAN
 USE IN &l_cCurRemainders
 IF NOT lp_lNoForecast
	 lp_cForecRemLev = IIF(l_nRemLev1,"1,","") + IIF(l_nRemLev2,"2,","") + IIF(l_nRemLev3,"3,","") + IIF(l_nRemLevX,"4,","")
	 IF NOT EMPTY(lp_cForecRemLev)
	      lp_cForecRemLev = LEFT(lp_cForecRemLev,LEN(lp_cForecRemLev)-1)
	 ENDIF
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*
FUNCTION ArGetDisputed
LPARAMETERS lp_nHeadId, lp_cAlias
LOCAL l_naRea, l_nRecno, l_nRetAmount, l_nCloseArpost
l_naRea = SELECT()
IF EMPTY(lp_cAlias)
     lp_cAlias = "arpost"
ENDIF
IF NOT USED(lp_cAlias)
     openfiledirect(.F., "ArPost", lp_cAlias)
     l_nCloseArpost = .T.
ENDIF
SELECT &lp_cAlias
l_nRecno = RECNO()
SUM ap_debit - ap_credit TO l_nRetAmount FOR ap_headid = lp_nHeadId AND ArIsDisputed(ap_dispute, ap_disdate)
GO l_nRecno
IF l_nCloseArpost
     USE IN &lp_cAlias
ENDIF
SELECT (l_naRea)
RETURN l_nRetAmount
ENDFUNC
*
PROCEDURE arremainderforecast
LPARAMETERS lp_nap_headid, lp_nAp_lineid, lp_lAp_dispute, lp_nBalance, lp_dap_sysdate, lp_dap_remlast, ;
		lp_nap_remlev, lp_nap_aracct, lp_dap_duedat
LOCAL l_nRemainderLevel, l_dSysDate, l_nAm_dayrem1, l_nAm_dayrem2, l_nAm_dayrem3, l_nAm_dayrem4, l_dDueDate
l_nRemainderLevel = 0

IF lp_nAp_lineid = lp_nap_headid AND NOT lp_lAp_dispute AND lp_nBalance> 0
	l_dSysDate = sysdate()
	l_dDueDate = ArGetDueDate(lp_nap_aracct, lp_dap_sysdate, lp_dap_duedat)
	GetRemainderDays(lp_nap_aracct, @l_nAm_dayrem1, @l_nAm_dayrem2, @l_nAm_dayrem3, @l_nAm_dayrem4)
	DO CASE
		CASE (lp_dap_duedat <= l_dSysDate) AND lp_nap_remlev = 0
			l_nRemainderLevel = 1
		CASE (lp_dap_remlast <= (l_dSysDate - l_nAm_dayrem2)) AND lp_nap_remlev = 1
			l_nRemainderLevel = 2
		CASE (lp_dap_remlast <= (l_dSysDate - l_nAm_dayrem3)) AND lp_nap_remlev = 2
			l_nRemainderLevel = 3
		CASE (lp_dap_remlast <= (l_dSysDate - l_nAm_dayrem4)) AND lp_nap_remlev = 3
			l_nRemainderLevel = 4
		OTHERWISE
			l_nRemainderLevel = 0
	ENDCASE
ENDIF

RETURN l_nRemainderLevel
ENDPROC
*
PROCEDURE GetRemainderDays
 LPARAMETERS lp_nAracct, lp_nAm_dayrem1, lp_nAm_dayrem2, lp_nAm_dayrem3, lp_nAm_dayrem4
 LOCAL l_nAm_number
 LOCAL ARRAY l_aRemainders(1)
 LOCAL ARRAY l_aRemainderDays(1)
 STORE 0 TO lp_nAm_dayrem1, lp_nAm_dayrem2, lp_nAm_dayrem3, lp_nAm_dayrem4, l_nAm_number
 SELECT TOP 1 ac_aracct, ac_amid, ac_credito ;
           FROM aracct ;
           WHERE ac_aracct = lp_nAracct ORDER BY 1 INTO ARRAY l_aRemainders
 IF ALEN(l_aRemainders,2)>1
      *l_aRemainders(3) - is it creditor?
      IF l_aRemainders(2) = 0
          IF l_aRemainders(3)
               l_nAm_number = dblookup("picklist", "tag4", PADR(CREDITOR_REMAINDER_LABEL,10) + "DEF", "pl_numcod")
          ELSE
               l_nAm_number = dblookup("picklist", "tag4", PADR(DEBITOR_REMAINDER_LABEL,10) + "DEF", "pl_numcod")
          ENDIF
      ELSE
           l_nAm_number = dblookup("arremd", "tag1", l_aRemainders(2), "am_number")
      ENDIF
      SELECT TOP 1 am_number, am_dayrem1, am_dayrem2, am_dayrem3, am_dayrem4 ;
               FROM arremd ;
               WHERE am_number = l_nAm_number AND IIF(l_aRemainders(3), am_credito,NOT am_credito) ;
               ORDER BY 1 INTO ARRAY l_aRemainderDays
      IF ALEN(l_aRemainderDays,2) > 1
           lp_nAm_dayrem1 = l_aRemainderDays(2)
           lp_nAm_dayrem2 = l_aRemainderDays(3)
           lp_nAm_dayrem3 = l_aRemainderDays(4)
           lp_nAm_dayrem4 = l_aRemainderDays(5)
      ENDIF
 ENDIF
 RETURN l_nAm_number
ENDPROC
*
PROCEDURE GetConditionDays
 LPARAMETERS lp_nAracct, lp_nAy_daydis1, lp_nAy_daydis2, lp_nAy_daydis3
 LOCAL l_nAy_number
 LOCAL ARRAY l_aConditions(1)
 LOCAL ARRAY l_aConditionDays(1)
 STORE 0 TO lp_nAy_daydis1, lp_nAy_daydis2, lp_nAy_daydis3
 SELECT TOP 1 ac_aracct, ac_ayid, ac_credito ;
           FROM aracct ;
           WHERE ac_aracct = lp_nAracct ORDER BY 1 INTO ARRAY l_aConditions
 IF ALEN(l_aConditions,2)>1
     *l_aConditions(3) - is it creditor?
     IF l_aConditions(2) = 0
          IF l_aConditions(3)
               l_nAy_number = dblookup("picklist", "tag4", PADR(CREDITOR_PAY_COND_LABEL,10) + "DEF", "pl_numcod")
          ELSE
               l_nAy_number = dblookup("picklist", "tag4", PADR(DEBITOR_PAY_COND_LABEL,10) + "DEF", "pl_numcod")
          ENDIF
     ELSE
          l_nAy_number = dblookup("arpcond", "tag1", l_aConditions(2), "ay_number")
     ENDIF
     SELECT TOP 1 ay_number, ay_daydis1, ay_daydis2, ay_daydis3 ;
               FROM arpcond ;
               WHERE ay_number = l_nAy_number AND IIF(l_aConditions(3), ay_credito,NOT ay_credito) ;
               ORDER BY 1 INTO ARRAY l_aConditionDays
     IF ALEN(l_aConditionDays,2) > 1
           lp_nAy_daydis1 = l_aConditionDays(2)
           lp_nAy_daydis2 = l_aConditionDays(3)
           lp_nAy_daydis3 = l_aConditionDays(4)
     ENDIF
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE ArGetDueDate
 LPARAMETERS lp_nAracct, lp_dBillDate, lp_dAp_duedat, lp_dDueDate, lp_dStartRemFee
 LOCAL l_nDueDays, l_nAy_daydis1, l_nAy_daydis2, l_nAy_daydis3, l_nAm_dayrem1, l_nDaysToRemFee
 STORE {} TO lp_dDueDate, lp_dStartRemFee
 GetRemainderDays(lp_nAracct, @l_nAm_dayrem1)
 GetConditionDays(lp_nAracct, @l_nAy_daydis1, @l_nAy_daydis2, @l_nAy_daydis3)
 l_nDaysToRemFee = MAX(l_nAy_daydis1, l_nAy_daydis2, l_nAy_daydis3)
 lp_dStartRemFee = lp_dBillDate + l_nDaysToRemFee
 IF EMPTY(lp_dAp_duedat) && For old bills no due date was written, or new bill
      l_nDueDays = l_nDaysToRemFee + l_nAm_dayrem1
      lp_dDueDate = lp_dBillDate + l_nDueDays
 ELSE
      lp_dDueDate = lp_dAp_duedat
 ENDIF
 RETURN lp_dDueDate
ENDPROC
*
PROCEDURE ArIsDisputed
LPARAMETERS lp_lDisputed, lp_dDisputeEndDate
LOCAL l_lDisputed
l_lDisputed = (lp_lDisputed AND EMPTY(lp_dDisputeEndDate)) OR (lp_lDisputed AND lp_dDisputeEndDate >= sysdate())
RETURN l_lDisputed
ENDPROC
*
PROCEDURE CalcPercentRemAmount
 LPARAMETERS lp_nBillAmount, lp_nDaysPassed, lp_nRemainderPercentFee
 LOCAL l_nPercentRemAmount
 l_nPercentRemAmount = (lp_nBillAmount * lp_nDaysPassed * lp_nRemainderPercentFee) / (100*360)
 l_nPercentRemAmount = ROUND(l_nPercentRemAmount, param.pa_currdec)
 RETURN l_nPercentRemAmount
ENDFUNC
*
PROCEDURE ArPaymentDetails
LPARAMETERS lp_nArAcct, lp_cDescriptText, lp_cDiscountText, lp_nayid
LOCAL l_cCursor, l_nSelect, l_nAyNum
l_cCursor = SYS(2015)
STORE "" TO lp_cDescriptText, lp_cDiscountText
l_nSelect = SELECT()
IF EMPTY(lp_nayid)
	lp_nayid = dblookup("aracct", "tag1", lp_nArAcct, "ac_ayid")
	IF lp_nayid = 0
		* get default paying condition
		l_nAyNum = dblookup("picklist", "tag4", "ARPCOND   " + "DEF", "pl_numcod")
		lp_nayid = dblookup("arpcond", "tag2", l_nAyNum, "ay_ayid")
	ENDIF
ENDIF
SELECT * FROM arpcond WHERE ay_ayid = lp_nayid INTO CURSOR &l_cCursor
IF RECCOUNT()>0
	lp_cDescriptText = TRIM(ay_header)
	IF ay_show1
		lp_cDiscountText = TRIM(strfmt(ay_dsctxt1,ay_daydis1,ay_discou1)) + CHR(10)
	ENDIF
	IF ay_show2
		lp_cDiscountText = lp_cDiscountText + TRIM(strfmt(ay_dsctxt2,ay_daydis2,ay_discou2)) + CHR(10)
	ENDIF
	IF ay_show3
		lp_cDiscountText = lp_cDiscountText + TRIM(strfmt(ay_dsctxt3,ay_daydis3,ay_discou3)) + CHR(10)
	ENDIF	
ENDIF
USE
SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ArNextAccID
 LPARAMETERS lp_nAccID
 LOCAL ARRAY l_aResult(1)
 SELECT MAX(ac_aracct) FROM aracct INTO ARRAY l_aResult
 IF TYPE("l_aResult(1)")="N"
      lp_nAccID = l_aResult(1) + 1
 ELSE
      lp_nAccID = 1
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE ArAllocateMarkedRows
LPARAMETERS lp_cMarkedRowsCur, lp_lSaveIntoTable
LOCAL l_IsCreditFP, l_IsCreditPB, l_IsCreditCN, l_IsCreditNB, l_IsCredit, l_IsDebitRE, l_IsDebitBL, l_IsDebitRB, l_IsDebit
LOCAL l_oCredit, l_nStoreCreditHeadId, l_nDebitCounted, l_nCreditCounted, l_nCreditNoteCounted, l_nBalance, l_nPaymentsOnBill
LOCAL l_lCreditAndDebitEqual, l_lNoMoreCredit, l_lContinue, l_cCreditRef, l_cDebitRef, l_nScanCursorRecNo
LOCAL l_nAllCreditMarked, l_nAllDebitMarked, l_lShowResult
l_lShowResult = .T.
l_cDebitRef = ""
l_cCreditRef = ""
l_IsCredit = ""
l_oCredit = .NULL.
l_IsDebit = ""
STORE 0 TO l_nAllCreditMarked, l_nAllDebitMarked, l_nBalance, l_nStoreCreditHeadId
STORE 0 TO l_nPaymentsOnBill, l_nCreditNoteCounted

*** credit rows
* Free Payment (FP)
l_IsCreditFP = [ap_headid = 0 AND ap_paynum > 0 AND ap_credit > 0]
* Payment on bill (PB)
l_IsCreditPB = [ap_headid <> 0 AND ap_headid <> ap_lineid AND ap_paynum > 0 AND ap_credit > 0]
* Credit Note (CN)
l_IsCreditCN = [ap_headid = ap_lineid AND ap_debit < 0]
* Credit Note which is aligned with bill (NB)
l_IsCreditNB = [ap_headid <> 0 AND ap_headid <> ap_lineid AND ap_paynum > 0 AND ap_debit < 0]
l_IsCredit = sqlor(l_IsCredit, l_IsCreditFP)
l_IsCredit = sqlor(l_IsCredit, l_IsCreditPB)
l_IsCredit = sqlor(l_IsCredit, l_IsCreditCN)
l_IsCredit = sqlor(l_IsCredit, l_IsCreditNB)
***

*** debit rows
* Regress (RE)
l_IsDebitRE = [ap_headid = 0 AND ap_paynum > 0 AND ap_credit < 0]
* Regress that is aligned with bill (RB)
l_IsDebitRB = [ap_headid <> 0 AND ap_headid <> ap_lineid AND ap_paynum > 0 AND ap_credit < 0]
* Bill paid with debitor payment (BL)
l_IsDebitBL = [ap_headid = ap_lineid AND ap_paynum > 0 AND ap_debit > 0]
l_IsDebit = sqlor(l_IsDebit, l_IsDebitRE)
l_IsDebit = sqlor(l_IsDebit, l_IsDebitBL)
l_IsDebit = sqlor(l_IsDebit, l_IsDebitRB)
***
l_nCreditCounted = 0
SELECT (lp_cMarkedRowsCur)
SET ORDER TO TAG8

SCAN ALL
	DO CASE
		CASE EVALUATE(l_IsCreditFP)
			l_nCreditCounted = l_nCreditCounted + 1
			REPLACE ap_balance WITH ap_credit, ;
					ap_type WITH "C", ;
					ap_dettype WITH "FP"
			l_nAllCreditMarked = l_nAllCreditMarked + ap_credit
		CASE EVALUATE(l_IsCreditPB)
			l_nCreditCounted = l_nCreditCounted + 1
			REPLACE ap_balance WITH ap_credit, ;
					ap_type WITH "C", ;
					ap_dettype WITH "PB"
			l_nAllCreditMarked = l_nAllCreditMarked + ap_credit
		CASE EVALUATE(l_IsCreditCN)
			l_nBalance = arpstbal(ap_headid, 0)
			REPLACE ap_balance WITH (l_nBalance * -1), ;
					ap_type WITH "C", ;
					ap_dettype WITH "CN"
			l_nAllCreditMarked = l_nAllCreditMarked + (l_nBalance * -1)
			l_nCreditNoteCounted = l_nCreditNoteCounted + 1
		CASE EVALUATE(l_IsCreditNB)
			l_nCreditCounted = l_nCreditCounted + 1
			REPLACE ap_balance WITH (ap_debit * -1), ;
					ap_type WITH "C", ;
					ap_dettype WITH "NB"
			l_nAllCreditMarked = l_nAllCreditMarked + (ap_debit * -1)
		OTHERWISE
			* invalid record!
	ENDCASE
ENDSCAN

l_lContinue = .T.
DO CASE
	CASE l_nCreditCounted = 0 AND l_nCreditNoteCounted = 0
		l_lContinue = .F.
		alert(GetLangText("AR","TXT_NOCREDIT_SELECTED"))
	CASE l_nCreditCounted > 0 AND l_nCreditNoteCounted > 0
		l_lContinue = .F.
		alert(GetLangText("AR","TXT_CREDITNOTE_OR_PAYMENT"))
	CASE l_nCreditNoteCounted > 1
		l_lContinue = .F.
		alert(GetLangText("AR","TXT_ONE_CREDIT_NOTE"))
	OTHERWISE
		l_lContinue = .T.
ENDCASE
IF NOT l_lContinue
	lp_lSaveIntoTable = .F.
	RETURN .F.
ENDIF

l_nDebitCounted = 0
SCAN ALL
	DO CASE
		CASE EVALUATE(l_IsDebitRE)
			l_nBalance = (ap_credit * -1)
			REPLACE ap_balance WITH l_nBalance, ;
					ap_type WITH "D", ;
					ap_dettype WITH "RE"
			IF l_nBalance > 0
				l_nDebitCounted = l_nDebitCounted + 1
			ENDIF
			l_nAllDebitMarked = l_nAllDebitMarked + l_nBalance
		CASE EVALUATE(l_IsDebitBL)
			l_nBalance = ArPstBal(ap_headid, 0)
			REPLACE ap_balance WITH l_nBalance, ;
					ap_type WITH "D", ;
					ap_dettype WITH "BL"
			IF l_nBalance > 0
				l_nDebitCounted = l_nDebitCounted + 1
			ENDIF
			l_nAllDebitMarked = l_nAllDebitMarked + l_nBalance
		CASE EVALUATE(l_IsDebitRB)
			l_nBalance = (ap_credit * -1)
			REPLACE ap_balance WITH l_nBalance, ;
					ap_type WITH "D", ;
					ap_dettype WITH "RB"
			IF l_nBalance > 0
				l_nDebitCounted = l_nDebitCounted + 1
			ENDIF
			l_nAllDebitMarked = l_nAllDebitMarked + l_nBalance
		OTHERWISE
			* invalid record!
	ENDCASE
ENDSCAN

SCAN FOR ap_type = "C" AND l_nAllCreditMarked > 0
	IF INLIST(ap_dettype, "PB", "NB")
		l_nStoreCreditHeadId = ap_headid
	ENDIF
	SCATTER MEMO NAME l_oCredit

	IF NOT "[Betrag:" $ l_oCredit.ap_ref
		l_cCreditRef = ALLTRIM(l_oCredit.ap_ref) + "[Betrag:" + ALLTRIM(STR(l_oCredit.ap_balance, 10, 2)) + "]"
	ELSE
		l_cCreditRef = ALLTRIM(l_oCredit.ap_ref)
	ENDIF

	l_nScanCursorRecNo = RECNO(lp_cMarkedRowsCur)
	SCAN FOR ap_type = "D" AND l_oCredit.ap_balance > 0
		IF NOT cap_marker 
			LOOP
		ENDIF
		IF NOT EMPTY(l_nStoreCreditHeadId) AND ap_headid = l_nStoreCreditHeadId
			REPLACE cap_marker WITH .F.
			EXIT
		ENDIF
		SCATTER MEMO NAME l_oDebit
		IF l_oCredit.ap_balance > l_oDebit.ap_balance
			l_NewDebitBalance = 0
			l_NewCreditBalance = l_oCredit.ap_balance - l_oDebit.ap_balance
			l_CreditPost = l_oDebit.ap_balance
			l_lNoMoreCredit = .F.
		ELSE
			l_NewDebitBalance = l_oDebit.ap_balance - l_oCredit.ap_balance
			l_lCreditAndDebitEqual = (l_NewDebitBalance = 0)
			l_NewCreditBalance = 0
			l_CreditPost = l_oCredit.ap_balance
			l_lNoMoreCredit = .T.
		ENDIF
		IF NOT "[Betrag:" $ l_oDebit.ap_ref
			l_cDebitRef = ALLTRIM(l_oDebit.ap_ref) + "[Betrag:" + ALLTRIM(STR(l_oDebit.ap_balance, 10, 2)) + "]"
		ELSE
			l_cDebitRef = ALLTRIM(l_oDebit.ap_ref)
		ENDIF
		l_oCredit.ap_balance = l_NewCreditBalance
		l_nAllCreditMarked = l_nAllCreditMarked - l_CreditPost
		DO CASE
			CASE ap_dettype = "BL" AND INLIST(l_oCredit.ap_dettype, "FP", "PB", "NB")
				IF l_lNoMoreCredit
					l_oDebit.cap_balanc = l_NewDebitBalance
					l_oDebit.ap_balance = l_NewDebitBalance
					
					IF l_oCredit.ap_dettype = "NB"
						l_oCredit.ap_credit = l_NewCreditBalance
						l_oCredit.ap_debit = (l_CreditPost * -1)
					ELSE
						l_oCredit.ap_credit = l_CreditPost
						l_oCredit.ap_debit = l_NewCreditBalance
					ENDIF
					l_oCredit.ap_headid = l_oDebit.ap_lineid
					l_oCredit.ap_ref = l_cCreditRef
				ELSE
					IF NOT EMPTY(l_CreditPost)
						ArApPay(l_oCredit.ap_aracct, sysdate(), l_oCredit.ap_paynum, l_cCreditRef, l_CreditPost, ;
								l_oCredit.ap_reserid, l_oDebit.ap_headid, lp_cMarkedRowsCur)
					ENDIF
					l_oDebit.cap_balanc = l_NewDebitBalance
					l_oDebit.ap_balance = l_NewDebitBalance
					l_oDebit.cap_marker = .F.
					
					IF l_oCredit.ap_dettype = "NB"
						l_oCredit.ap_debit = (l_NewCreditBalance * -1)
						l_oCredit.ap_credit = l_NewDebitBalance
					ELSE
						l_oCredit.ap_debit = l_NewDebitBalance
						l_oCredit.ap_credit = l_NewCreditBalance
					ENDIF
					l_oCredit.cap_balanc = (l_NewCreditBalance * -1)
					l_oCredit.ap_ref = l_cCreditRef
					l_oCredit.ap_headid = l_nStoreCreditHeadId
				ENDIF
				
			CASE ap_dettype = "BL" AND l_oCredit.ap_dettype = "CN"
				l_nPaymentsOnBill = l_oCredit.cap_balanc - l_oCredit.ap_debit
				l_oDebit.cap_balanc = l_oDebit.cap_balanc + l_oCredit.ap_debit + l_nPaymentsOnBill
				l_oDebit.ap_balance = l_oDebit.cap_balanc
				l_oDebit.cap_marker = .F.
		* OGRANICENJE: samo jedno dugovanje (BL) i jedno potrazivanje (CN) bice uzeti u obzir !!!!
				l_oCredit.ap_credit = 0
				l_oCredit.cap_balanc = 0
				l_oCredit.ap_balance = 0
				l_oCredit.ap_headid = l_oDebit.ap_lineid
				l_oCredit.ap_chkball = .T.
				
			CASE INLIST(ap_dettype, "RB", "RE") AND INLIST(l_oCredit.ap_dettype, "FP", "PB")
				IF  l_lNoMoreCredit
					l_oDebit.ap_credit = IIF(l_lCreditAndDebitEqual, 0, (l_NewDebitBalance * -1))
					l_oDebit.cap_balanc = IIF(l_lCreditAndDebitEqual, 0, l_NewDebitBalance)
					l_oDebit.ap_balance = l_oDebit.cap_balanc
					l_oDebit.ap_hiden = l_lCreditAndDebitEqual
					l_oDebit.ap_ref = l_cDebitRef
				
					l_oCredit.ap_credit = l_NewCreditBalance
					l_oCredit.cap_balanc = l_NewCreditBalance
					l_oCredit.ap_ref = l_cCreditRef
					l_oCredit.ap_hiden = .T.
					l_oCredit.ap_hidlnid = l_oDebit.ap_lineid
				ELSE
					l_oDebit.ap_hiden = .T.
					l_oDebit.ap_hidlnid = l_oCredit.ap_lineid
					l_oDebit.ap_credit = l_NewDebitBalance
					l_oDebit.cap_balanc = l_NewDebitBalance
					l_oDebit.ap_balance = l_NewDebitBalance
					l_oDebit.ap_ref = l_cDebitRef
					l_oDebit.cap_marker = .F.
					
					l_oCredit.ap_headid = l_nStoreCreditHeadId
					l_oCredit.ap_credit = l_NewCreditBalance
					l_oCredit.cap_balanc = (l_NewCreditBalance * -1)
					l_oCredit.ap_ref = l_cCreditRef
				ENDIF
			
			CASE INLIST(ap_dettype, "RB", "RE") AND l_oCredit.ap_dettype = "CN"
				IF  l_lNoMoreCredit AND NOT l_lCreditAndDebitEqual
					ArApPay(l_oDebit.ap_aracct, sysdate(), l_oDebit.ap_paynum, l_cDebitRef, (l_CreditPost * -1), ;
							l_oDebit.ap_reserid, l_oCredit.ap_headid, lp_cMarkedRowsCur)

					l_oDebit.ap_credit = (l_NewDebitBalance * -1)
					l_oDebit.cap_balanc = l_NewDebitBalance
					l_oDebit.ap_balance = l_NewDebitBalance
					l_oDebit.ap_ref = l_cDebitRef
					
					l_oCredit.cap_balanc = l_NewCreditBalance
				ELSE
					l_oDebit.ap_headid = l_oCredit.ap_lineid
					l_oDebit.cap_balanc = l_NewDebitBalance
					l_oDebit.ap_balance = l_NewDebitBalance
					l_oDebit.ap_ref = l_cDebitRef
					l_oDebit.cap_marker = .F.
					
					l_oCredit.cap_balanc = (l_NewCreditBalance * -1)
				ENDIF
			
			OTHERWISE
				alert(GetLangText("AR","TXT_NOCHANGES_MADE"))
				l_lShowResult = .F.

		ENDCASE
		GATHER MEMO NAME l_oDebit
	ENDSCAN
	GO l_nScanCursorRecNo IN (lp_cMarkedRowsCur)
	l_oCredit.cap_marker = .F.
	GATHER MEMO NAME l_oCredit
ENDSCAN

IF l_lShowResult
	DO FORM "forms\ShowDebitors" WITH lp_cMarkedRowsCur TO lp_lSaveIntoTable
ELSE
	lp_lSaveIntoTable = .F.
ENDIF

RETURN .T.
ENDPROC
