LOCAL l_oAuditExPos AS cauditexpos OF progs\auditexpos.prg

l_oAuditExPos = CREATEOBJECT("cauditexpos")
l_oAuditExPos.Start()

RETURN .T.
ENDPROC
*
DEFINE CLASS cauditexpos AS Session
*
#IF .F. && Make sure this is false, otherwise error
   *-- Define This for IntelliSense use
   LOCAL this AS cauditexpos OF auditexpos.prg
#ENDIF
*
oSettings = .NULL.
dsysdate = {}
cIniLoc = ""
nps_vat0 = 0.000000
nps_vat1 = 0.000000
nps_vat2 = 0.000000
nps_vat3 = 0.000000
nps_vat4 = 0.000000
nps_vat5 = 0.000000
nps_vat6 = 0.000000
nps_vat7 = 0.000000
nps_vat8 = 0.000000
nps_vat9 = 0.000000
*
PROCEDURE Init
ini()
this.dsysdate = _screen.oGlobal.oParam.pa_sysdate
RETURN .T.
ENDPROC
*
PROCEDURE Start
LOCAL l_lSuccess
IF this.InitDB()
     this.GetSettings()
     IF this.oSettings.SettingsOK()
          l_lSuccess = this.Import()
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE Import
LOCAL l_cSql

* Store temp post data in cursor
SELECT * FROM curpost WHERE 0=1 INTO CURSOR curoutpost READWRITE

* Get data
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT * FROM pichk WHERE pz_sysdate = __EMPTY_DATE__ ORDER BY 1
ENDTEXT
sqlcursor(l_cSql,"curchecks")

this.ProcessBills()
this.ProcessWriteToPost()

RETURN .T.
ENDPROC
*
PROCEDURE ProcessBills
SELECT curchecks
SCAN ALL
     this.GetBillDetails()
     this.ProcessRoomCharge()
     this.ProcessArticles()
     this.ProcessPayments()
     this.ProcessMarkAsFinished()
ENDSCAN
RETURN .T.
ENDPROC
*
PROCEDURE GetBillDetails
LOCAL l_cSql, l_nSelect
l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT * FROM piart WHERE pi_pzid = <<SqlCnv(curchecks.pz_pzid,.T.)>>
ENDTEXT
sqlcursor(l_cSql,"curpiart")

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT * FROM pipay WHERE pp_pzid = <<SqlCnv(curchecks.pz_pzid,.T.)>>
ENDTEXT
sqlcursor(l_cSql,"curpipay")

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ProcessArticles
LOCAL l_nSelect, l_nArtiNum, l_oData, l_nPostId
l_nSelect = SELECT(l_nSelect)

SELECT ps_artinum, ps_amount, ps_vat1 AS c_vat1, ps_vat1 AS c_vat2, ps_vat1 AS c_vat0 ;
     FROM curpost ;
     WHERE 0=1 ;
     INTO CURSOR curpart READWRITE

SELECT curpiart
SCAN ALL
     l_nArtiNum = 0
     IF this.dlocate("curag",this.GetArticleFilter())
          l_nArtiNum = curag.ar_artinum
     ENDIF
     IF EMPTY(l_nArtiNum)
          l_nArtiNum = this.oSettings.ndefaultarticlegroup
     ENDIF
     SELECT curpart
     IF this.dlocate("curpart", "ps_artinum = " + TRANSFORM(l_nArtiNum))
          SCATTER NAME l_oData MEMO
     ELSE
          SCATTER NAME l_oData MEMO BLANK
          l_oData.ps_artinum = l_nArtiNum
          INSERT INTO curpart FROM NAME l_oData
     ENDIF
     l_oData.ps_amount = l_oData.ps_amount + curpiart.pi_amount
     l_oData.c_vat1 = l_oData.c_vat1 + curpiart.pi_vat1
     l_oData.c_vat2 = l_oData.c_vat2 + curpiart.pi_vat2
     l_oData.c_vat0 = l_oData.c_vat0 + curpiart.pi_amnotax
     GATHER NAME l_oData MEMO
ENDSCAN
SELECT curpart

SCAN ALL
     this.GetVat(c_vat0, c_vat1 , c_vat2)
     SELECT curoutpost
     SCATTER NAME l_oData BLANK
     l_oData.ps_artinum = curpart.ps_artinum
     l_oData.ps_amount = curpart.ps_amount
     l_oData.ps_vat0 = this.nps_vat0
     l_oData.ps_vat1 = this.nps_vat1
     l_oData.ps_vat2 = this.nps_vat2
     l_oData.ps_vat3 = this.nps_vat3
     l_oData.ps_vat4 = this.nps_vat4
     l_oData.ps_vat5 = this.nps_vat5
     l_oData.ps_vat6 = this.nps_vat6
     l_oData.ps_vat7 = this.nps_vat7
     l_oData.ps_vat8 = this.nps_vat8
     l_oData.ps_vat9 = this.nps_vat9
     INSERT INTO curoutpost FROM NAME l_oData
ENDSCAN

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
&& GetArticleFilter returns WHERE clause for LOCATE command over curag cursor, to position over right Desk article (ar_artinum)
PROCEDURE GetArticleFilter
LOCAL l_nValue, l_cValue, l_cArticleGroup, l_cWhere, l_cPosName

l_nValue = 0
l_cWhere = ""

DO CASE
     CASE this.oSettings.lusemaingan
          l_cArticleGroup = ALLTRIM(pi_maingan)
          IF NOT EMPTY(l_cArticleGroup) AND ISDIGIT(l_cArticleGroup)
               l_nValue = INT(VAL(l_cArticleGroup))
               IF this.oSettings.luseposname
                    l_cPosName = PADR(UPPER(ALLTRIM(curchecks.pz_posname)),20)
                    IF NOT EMPTY(l_cPosName)
                         l_cWhere = "c_ag = " + TRANSFORM(l_nValue) + " AND c_posname = [" + l_cPosName + "]"
                    ENDIF
               ENDIF
          ENDIF
     CASE this.oSettings.luseplu
          l_nValue = pi_plu
     OTHERWISE
          l_nValue = pi_depno
ENDCASE

IF EMPTY(l_cWhere)
     l_cWhere = "c_ag = " + TRANSFORM(l_nValue)
ENDIF

RETURN l_cWhere
ENDPROC
*
PROCEDURE ProcessPayments
LOCAL l_nSelect, l_nPayNum, l_oData, l_nPostId
l_nSelect = SELECT(l_nSelect)

SELECT ps_paynum, ps_amount FROM curpost WHERE 0=1 INTO CURSOR curppay READWRITE

SELECT curpipay
SCAN FOR IIF(EMPTY(this.oSettings.croomchargepaymentname), pp_paynum <> this.oSettings.nroomchargepaymentno, NOT LOWER(ALLTRIM(pp_payname)) == this.oSettings.croomchargepaymentname) && Don't proccess roomcharge payments
     l_nPayNum = 0
     IF EMPTY(this.oSettings.croomchargepaymentname)
          IF this.dlocate("curpaymetho","c_paynum = " + TRANSFORM(pp_paynum))
               l_nPayNum = curpaymetho.pm_paynum
          ENDIF
     ELSE
          IF this.dlocate("curpaymetho","LOWER(ALLTRIM(c_payname)) == '" + LOWER(ALLTRIM(pp_payname)) + "'")
               l_nPayNum = curpaymetho.pm_paynum
          ENDIF
     ENDIF
     IF EMPTY(l_nPayNum)
          l_nPayNum = this.oSettings.ndefaultpayment
     ENDIF
     SELECT curppay
     IF this.dlocate("curppay", "ps_paynum = " + TRANSFORM(l_nPayNum))
          SCATTER NAME l_oData
     ELSE
          SCATTER NAME l_oData BLANK
          l_oData.ps_paynum = l_nPayNum
          INSERT INTO curppay FROM NAME l_oData
     ENDIF
     l_oData.ps_amount = l_oData.ps_amount + curpipay.pp_amount
     GATHER NAME l_oData
ENDSCAN

SELECT curppay
this.GetVat(0, 0 , 0)
SCAN ALL
     SELECT curoutpost
     SCATTER NAME l_oData BLANK
     l_oData.ps_paynum = curppay.ps_paynum
     l_oData.ps_amount = curppay.ps_amount
     INSERT INTO curoutpost FROM NAME l_oData
ENDSCAN

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ProcessWriteToPost
LOCAL l_nSelect, l_nPostId, l_nPayNum
l_nSelect = SELECT()
l_nPayNum = ICASE(_screen.oGlobal.oparam.pa_currloc<>0,_screen.oGlobal.oparam.pa_currloc,EMPTY(_screen.oGlobal.oParam2.pa_paidopm),1,_screen.oGlobal.oParam2.pa_paidopm)

SELECT ps_artinum, SUM(ps_amount) AS ps_amount, SUM(ps_vat1) AS ps_vat1, SUM(ps_vat2) AS ps_vat2, ;
     SUM(ps_vat3) AS ps_vat3, SUM(ps_vat4) AS ps_vat4, SUM(ps_vat5) AS ps_vat5, SUM(ps_vat6) AS ps_vat6, ;
     SUM(ps_vat7) AS ps_vat7, SUM(ps_vat8) AS ps_vat8, SUM(ps_vat9) AS ps_vat9, SUM(ps_vat0) AS ps_vat0 ;
     FROM curoutpost ;
     WHERE ps_artinum > 0 ;
     GROUP BY 1 ;
     ORDER BY 1 ;
     INTO CURSOR curoutart
SCAN ALL
     l_nPostId = NextId("POST")
     sqlinsert("post", ;
               "ps_artinum, ps_amount, ps_units, ps_price, ps_date, ps_time, ps_userid, ps_reserid, ps_origid, " + ;
               "ps_postid, ps_cashier, " + ;
               "ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ps_vat0", ;
               1, ;
               sqlcnv(ps_artinum,.T.) + "," + sqlcnv(ps_amount,.T.) + "," + sqlcnv(IIF(ps_amount<0.00,-1,1),.T.) + "," + sqlcnv(ABS(ps_amount),.T.) + "," + ;
               sqlcnv(this.dsysdate,.T.) + "," + sqlcnv(TIME(),.T.) + "," + sqlcnv('POSZ2',.T.) + "," + sqlcnv(0.100,.T.) + "," + ;
               sqlcnv(0.100,.T.) + "," + sqlcnv(l_nPostId,.T.) + "," + sqlcnv(98,.T.) + "," + ;
               sqlcnv(ps_vat1,.T.) + "," + sqlcnv(ps_vat2,.T.) + "," + sqlcnv(ps_vat3,.T.) + "," + ;
               sqlcnv(ps_vat4,.T.) + "," + sqlcnv(ps_vat5,.T.) + "," + sqlcnv(ps_vat6,.T.) + "," + ;
               sqlcnv(ps_vat7,.T.) + "," + sqlcnv(ps_vat8,.T.) + "," + sqlcnv(ps_vat9,.T.) + "," + sqlcnv(ps_vat0,.T.) ;
               )
     IF dlookup("article","ar_artinum = " + sqlcnv(curoutart.ps_artinum,.T.),"ar_artityp")=2 && Auslagen
          l_nPostId = NextId("POST")
          SELECT curoutart
          sqlinsert("post", ;
                    "ps_artinum, ps_amount, ps_units, ps_price, ps_date, ps_time, ps_userid, ps_reserid, ps_origid, " + ;
                    "ps_postid, ps_cashier, ps_paynum, " + ;
                    "ps_vat1, ps_vat2, ps_vat3, ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ps_vat0", ;
                    1, ;
                    sqlcnv(0,.T.) + "," + sqlcnv(ps_amount,.T.) + "," + sqlcnv(-ps_amount,.T.) + "," + sqlcnv(1,.T.) + "," + ;
                    sqlcnv(this.dsysdate,.T.) + "," + sqlcnv(TIME(),.T.) + "," + sqlcnv('POSZ2',.T.) + "," + sqlcnv(0.200,.T.) + "," + ;
                    sqlcnv(0.200,.T.) + "," + sqlcnv(l_nPostId,.T.) + "," + sqlcnv(98,.T.) + "," + sqlcnv(l_nPayNum,.T.) + "," + ;
                    sqlcnv(ps_vat1,.T.) + "," + sqlcnv(ps_vat2,.T.) + "," + sqlcnv(ps_vat3,.T.) + "," + ;
                    sqlcnv(ps_vat4,.T.) + "," + sqlcnv(ps_vat5,.T.) + "," + sqlcnv(ps_vat6,.T.) + "," + ;
                    sqlcnv(ps_vat7,.T.) + "," + sqlcnv(ps_vat8,.T.) + "," + sqlcnv(ps_vat9,.T.) + "," + sqlcnv(ps_vat0,.T.) ;
                    )
     ENDIF
ENDSCAN

SELECT ps_paynum, SUM(ps_amount) AS ps_amount FROM curoutpost WHERE ps_paynum > 0 GROUP BY 1 ORDER BY 1 INTO CURSOR curoutpay
SCAN ALL
     l_nPostId = NextId("POST")
     sqlinsert("post", ;
               "ps_paynum, ps_amount, ps_units, ps_price, " + ;
               "ps_date, ps_time, ps_userid, ps_reserid, " + ;
               "ps_origid, ps_postid, ps_cashier", ;
               1, ;
               sqlcnv(ps_paynum,.T.) + "," + sqlcnv(-ps_amount,.T.) + "," + sqlcnv(ps_amount,.T.) + "," + sqlcnv(1.000000,.T.) + "," + ;
               sqlcnv(this.dsysdate,.T.) + "," + sqlcnv(TIME(),.T.) + "," + sqlcnv('POSZ2',.T.) + "," + sqlcnv(0.100,.T.) + "," + ;
               sqlcnv(0.100,.T.) + "," + sqlcnv(l_nPostId,.T.) + "," + sqlcnv(98,.T.) ;
               )
ENDSCAN

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*
PROCEDURE ProcessMarkAsFinished
sqlupdate("pichk","pz_pzid = " + sqlcnv(curchecks.pz_pzid,.T.),"pz_sysdate = " + sqlcnv(this.dsysdate,.T.))
RETURN .T.
ENDPROC
*
PROCEDURE ProcessRoomCharge
LOCAL npostid, nartnr, namt
IF pz_roomcha
     npostid = NextId("POST")
     nartnr = this.GetDepartmentArtiNum(pz_posno)
     namt = this.ProcessRoomChargeGetAmount()
     this.GetVat(pz_amnotax, pz_vat1, pz_vat2)
     INSERT INTO post (ps_artinum, ps_amount, ps_units, ps_price, ps_date, ps_time,  ;
            ps_supplem, ps_userid, ps_reserid, ps_window, ps_origid, ps_vat1, ps_vat2, ps_vat3,  ;
            ps_vat4, ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9, ps_postid, ps_vat0) ;
            VALUES (nartnr, - ;
            namt, -1, ABS(namt), this.dsysdate, TIME(), 'ARGUS T-POS', 'POS', 0.100 , 0, 0.100 , - ;
            this.nps_vat1, -this.nps_vat2, -this.nps_vat3, -this.nps_vat4, -this.nps_vat5, -this.nps_vat6, -this.nps_vat7, - ;
            this.nps_vat8, -this.nps_vat9, npostid, -this.nps_vat0)
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE ProcessRoomChargeGetAmount
LOCAL l_nAmount, l_cFor

l_nAmount = pz_amount

IF NOT this.oSettings.lpartialroomchargepossible
     RETURN l_nAmount
ENDIF

IF EMPTY(this.oSettings.croomchargepaymentname)
     l_cFor = "pp_paynum = " + TRANSFORM(this.oSettings.nroomchargepaymentno)
ELSE
     l_cFor = "pp_payname = '" + this.oSettings.croomchargepaymentname + "'"
ENDIF

IF this.dlocate("curpipay",l_cFor)
     l_nAmount = curpipay.pp_amount
ENDIF

RETURN l_nAmount
ENDPROC
*
PROCEDURE GetVat
LPARAMETERS lp_nVat0, lp_nVat1, lp_nVat2
LOCAL l_cMacro
this.nps_vat0 = 0.000000
this.nps_vat1 = 0.000000
this.nps_vat2 = 0.000000
this.nps_vat3 = 0.000000
this.nps_vat4 = 0.000000
this.nps_vat5 = 0.000000
this.nps_vat6 = 0.000000
this.nps_vat7 = 0.000000
this.nps_vat8 = 0.000000
this.nps_vat9 = 0.000000

IF NOT EMPTY(lp_nVat1)
     l_cMacro = "this.n" + this.oSettings.cvat1
     &l_cMacro = lp_nVat1
ENDIF

IF NOT EMPTY(lp_nVat2)
     l_cMacro = "this.n" + this.oSettings.cvat2
     &l_cMacro = lp_nVat2
ENDIF

IF NOT EMPTY(lp_nVat0)
     this.nps_vat0 = lp_nVat0
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE GetDepartmentArtiNum
LPARAMETERS lp_nDep
LOCAL l_nArtiNum
IF dlocate("curdep","c_dep = " + TRANSFORM(lp_nDep))
     l_nArtiNum = curdep.ar_artinum
ELSE
     l_nArtiNum = this.oSettings.ndefaultdepartment
ENDIF
RETURN l_nArtiNum
ENDPROC
*
PROCEDURE InitDB
LOCAL l_lSuccess
l_lSuccess = openfile(.F.,"post") AND ;
          openfile(.F.,"pichk") AND ;
          openfile(.F.,"piart") AND ;
          openfile(.F.,"pipay") AND ;
          openfile(.F.,"article")
IF l_lSuccess
     sqlcursor("SELECT * FROM post WHERE 0=1","curpost")
     sqlcursor("SELECT ar_artinum FROM article WHERE 0=1","curarticle")
ENDIF

RETURN l_lSuccess
ENDPROC
*
PROCEDURE GetSettings
LOCAL l_cIniFile

l_cIniFile = FULLPATH(_screen.oGlobal.choteldir + "externalpos.ini")

this.oSettings = CREATEOBJECT("cAuditExPosSettings", l_cIniFile)
this.oSettings.Start()

RETURN .T.
ENDPROC
*
PROCEDURE dlocate
LPARAMETERS lp_cAlias, lp_cExp
RETURN dlocate(lp_cAlias, lp_cExp)
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS cAuditExPosSettings AS Custom
     *
     cIniLoc = ""
     nroomchargepaymentno = 0
     croomchargepaymentname = ""
     lpartialroomchargepossible = .F.
     luseplu = .F.
     lusemaingan = .F.
     luseposname = .F.
     ndefaultarticlegroup = 0
     ndefaultpayment = 0
     ndefaultdepartment = 0
     cvat1 = ""
     cvat2 = ""
     nIniLines = 0

     DIMENSION aIni[1]

     *
     PROCEDURE Init

          LPARAMETERS lp_cIniLoc
          this.cIniLoc = lp_cIniLoc

          RETURN .T.

     ENDPROC
     *
     PROCEDURE Start

          IF NOT FILE(this.cIniLoc)
               RETURN .F.
          ENDIF

          this.GetMainSettings()
          this.GetVats()
          this.ReadIniContent()
          this.GetPosNames()
          this.GetDepartments()
          this.GetArticleGroups()
          this.GetPayments()

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetMainSettings

          this.nroomchargepaymentno = INT(VAL(readini(this.cIniLoc, "settings", "roomchargepaymentno", "0")))
          this.croomchargepaymentname = LOWER(ALLTRIM(readini(this.cIniLoc, "settings", "roomchargepaymentname", "")))
          this.lpartialroomchargepossible = IIF(LOWER(readini(this.cIniLoc, "settings", "partialroomchargepossible", "no"))=="yes",.T.,.F.)
          this.luseplu = IIF(LOWER(readini(this.cIniLoc, "settings", "useplu", "no"))=="yes",.T.,.F.)
          this.lusemaingan = IIF(LOWER(readini(this.cIniLoc, "settings", "usemaingan", "no"))=="yes",.T.,.F.)
          this.luseposname = IIF(LOWER(readini(this.cIniLoc, "settings", "useposname", "no"))=="yes",.T.,.F.)
          this.ndefaultarticlegroup = INT(VAL(readini(this.cIniLoc, "settings", "defaultarticlegroup", "0")))
          this.ndefaultpayment = INT(VAL(readini(this.cIniLoc, "settings", "defaultpayment", "0")))
          this.ndefaultdepartment = INT(VAL(readini(this.cIniLoc, "settings", "defaultdepartment", "0")))

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetVats

          this.cvat1 = readini(this.cIniLoc, "vat", "vat1", "")
          this.cvat2 = readini(this.cIniLoc, "vat", "vat2", "")

          RETURN .T.

     ENDPROC
     *
     PROCEDURE ReadIniContent

          LOCAL l_cIniContent
          l_cIniContent = FILETOSTR(this.cIniLoc)
          this.nIniLines = ALINES(this.aIni, l_cIniContent)

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetSectionEntries

          LPARAMETERS lp_cSection, lp_cGetSectionLineMethod
          LOCAL l_cHeader, i, l_cLine

          l_cHeader = ""

          FOR i = 1 TO this.nIniLines

               l_cLine = LOWER(this.aIni(i))

               DO CASE
                    CASE LEFT(l_cLine,1) = ";"
                         LOOP
                    CASE LEFT(l_cLine,1) = "["
                         l_cHeader = l_cLine
                    CASE EMPTY(l_cHeader)
                    CASE l_cHeader = "[" + lp_cSection + "]"
                         this.&lp_cGetSectionLineMethod(l_cLine)
               ENDCASE

          ENDFOR

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetPosNames

          SELECT SPACE(20) AS c_posname, 00 AS c_row FROM curarticle WHERE 0=1 INTO CURSOR curposna READWRITE

          this.GetSectionEntries("posname", "GetPosNamesLine")

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetPosNamesLine

          LPARAMETERS lp_cLine
          LOCAL l_cRow, l_cPosName

          l_cRow = GETWORDNUM(lp_cLine,1,"=")

          IF NOT (NOT EMPTY(l_cRow) AND ISDIGIT(l_cRow))
               RETURN .T.
          ENDIF

          IF dlocate("curposna","c_row = " + l_cRow)
               RETURN .T.
          ENDIF

          l_cPosName = GETWORDNUM(lp_cLine,2,"=")

          IF EMPTY(l_cPosName)
               RETURN .T.
          ENDIF

          l_cPosName = UPPER(ALLTRIM(l_cPosName))

          INSERT INTO curposna (c_posname, c_row) VALUES (l_cPosName,INT(VAL(l_cRow)))

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetDepartments

          SELECT ar_artinum, 00000000 AS c_dep FROM curarticle WHERE 0=1 INTO CURSOR curdep READWRITE

          this.GetSectionEntries("department", "GetDepartmentsLine")

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetDepartmentsLine

          LPARAMETERS lp_cLine
          LOCAL l_cDep, l_cArtiNum

          l_cDep = GETWORDNUM(lp_cLine,1,"=")

          IF NOT (NOT EMPTY(l_cDep) AND ISDIGIT(l_cDep))
               RETURN .T.
          ENDIF

          l_cArtiNum = GETWORDNUM(lp_cLine,2,"=")

          IF NOT (NOT EMPTY(l_cArtiNum) AND ISDIGIT(l_cArtiNum))
               RETURN .T.
          ENDIF

          IF dlocate("curdep","c_dep = " + l_cDep)
               RETURN .T.
          ENDIF

          INSERT INTO curdep (ar_artinum, c_dep) VALUES (INT(VAL(l_cArtiNum)),INT(VAL(l_cDep)))

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetArticleGroups

          SELECT ar_artinum, 00000000 AS c_ag, SPACE(20) AS c_posname FROM curarticle WHERE 0=1 INTO CURSOR curag READWRITE

          this.GetSectionEntries("articlegroups", "GetArticleGroupsLine")

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetArticleGroupsLine

          LPARAMETERS lp_cLine
          LOCAL l_cAG, l_cArtiNum, l_nNumberOfArticles, y, l_cPosName, l_cPosNameArtiNum
          
          l_cAG = GETWORDNUM(lp_cLine,1,"=")
          
          IF EMPTY(l_cAG)
               RETURN .T.
          ENDIF
          IF NOT ISDIGIT(l_cAG)
               RETURN .T.
          ENDIF

          l_cArtiNum = GETWORDNUM(lp_cLine,2,"=")

          IF EMPTY(l_cArtiNum)
               RETURN .T.
          ENDIF

          IF NOT ISDIGIT(l_cArtiNum)
               RETURN .T.
          ENDIF

          IF this.luseposname AND "|" $ l_cArtiNum

               l_nNumberOfArticles = GETWORDCOUNT(l_cArtiNum,"|")
               FOR y = 1 TO l_nNumberOfArticles
                    IF dlocate("curposna", "c_row = " + TRANSFORM(y))
                         l_cPosNameArtiNum = this.GetOneArticle(l_cArtiNum, y)
                         l_cPosName = ALLTRIM(curposna.c_posname)
                         IF NOT dlocate("curag","c_ag = " + l_cAG + " AND c_posname = [" + l_cPosName + "]")
                              INSERT INTO curag (ar_artinum, c_ag, c_posname) VALUES (INT(VAL(l_cPosNameArtiNum)),INT(VAL(l_cAG)),l_cPosName)
                         ENDIF
                    ENDIF
               ENDFOR

          ELSE

               IF dlocate("curag","c_ag = " + l_cAG)
                    RETURN .T.
               ENDIF

               INSERT INTO curag (ar_artinum, c_ag) VALUES (INT(VAL(l_cArtiNum)),INT(VAL(l_cAG)))

          ENDIF

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetOneArticle

          LPARAMETERS lp_cLine, lp_nRow
          LOCAL l_cArtiNum, l_cResult, i, l_cOneChar

          l_cResult = ""
          l_cArtiNum = GETWORDNUM(lp_cLine, lp_nRow, "|")

          FOR i = 1 TO LEN(l_cArtiNum)
               l_cOneChar = SUBSTR(l_cArtiNum, i, 1)
               IF l_cOneChar = ";" && Commant mark, ignore rest of string
                    EXIT
               ENDIF
               IF ISDIGIT(l_cOneChar)
                    l_cResult = l_cResult + l_cOneChar
               ENDIF
          ENDFOR

          RETURN l_cResult

     ENDPROC
     *
     PROCEDURE GetPayments

          SELECT 000 AS pm_paynum, 00000000 AS c_paynum, SPACE(50) AS c_payname FROM curarticle WHERE 0=1 INTO CURSOR curpaymetho READWRITE

          this.GetSectionEntries("payment", "GetPaymentsLine")

          RETURN .T.

     ENDPROC
     *
     PROCEDURE GetPaymentsLine

          LPARAMETERS lp_cLine
          LOCAL l_cPay, l_cPayNum

          l_cPay = LOWER(ALLTRIM(GETWORDNUM(lp_cLine,1,"=")))

          IF EMPTY(l_cPay)
               RETURN .T.
          ENDIF

          l_cPayNum = ALLTRIM(GETWORDNUM(lp_cLine,2,"="))
          IF EMPTY(l_cPayNum)
               RETURN .T.
          ENDIF

          IF EMPTY(this.croomchargepaymentname)
               IF ISDIGIT(l_cPayNum)
                    IF NOT dlocate("curpaymetho","c_paynum = " + l_cPay)
                         INSERT INTO curpaymetho (pm_paynum, c_paynum) VALUES (INT(VAL(l_cPayNum)),INT(VAL(l_cPay)))
                    ENDIF
               ENDIF
          ELSE
               IF NOT dlocate("curpaymetho","LOWER(ALLTRIM(c_payname)) = '" + LOWER(ALLTRIM(l_cPay)) + "'")
                    INSERT INTO curpaymetho (pm_paynum, c_payname) VALUES (INT(VAL(l_cPayNum)),l_cPay)
               ENDIF
          ENDIF

          RETURN .T.

     ENDPROC
     *
     PROCEDURE SettingsOK

          IF EMPTY(this.cvat1) OR EMPTY(this.cvat2) OR ;
                    (EMPTY(this.nroomchargepaymentno) AND EMPTY(this.croomchargepaymentname)) OR ;
                    EMPTY(this.ndefaultarticlegroup) OR ;
                    EMPTY(this.ndefaultdepartment)
               RETURN .F.
          ENDIF

          RETURN .T.

     ENDPROC
*
ENDDEFINE


