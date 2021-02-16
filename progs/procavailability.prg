*
#INCLUDE "include\constdefines.h"
*PROCEDURE ProcAvailability
ENDPROC
*
DEFINE CLASS cavailability AS cbobj OF commonclasses.prg
*
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS cavailability OF procavailability.prg
#ENDIF
*
DataSession = 2
dSysDate = {}
cResultAvailab = ""
oAvlData = .NULL.
DIMENSION aRTLink(1)
DIMENSION aDLink(1)
DIMENSION aVRLink(1)
*
PROCEDURE Init
Ini(,,,,.T.)
DODEFAULT()
this.UseTables()
ENDPROC
*
PROCEDURE UseTables
OpenFile(,"availab")
OpenFile(,"season")
OpenFile(,"altsplit")
OpenFile(,"althead")
OpenFile(,"param")
OpenFile(,"reservat")
OpenFile(,"picklist")
OpenFile(,"citcolor")
OpenFile(,"address")
OpenFile(,"rtypedef")
OpenFile(,"roomtype")
OpenFile(,"room")
OpenFile(,"sharing")
OpenFile(,"resrooms")
OpenFile(,"resrmshr")
OpenFile(,"histres")
OpenFile(,"extreser")
SET RELATION TO rt_rdid INTO rtypedef IN roomtype
SET RELATION TO rs_roomtyp INTO roomtype IN reservat
SET RELATION TO sd_roomtyp INTO roomtype IN sharing
SET RELATION TO av_roomtyp INTO roomtype IN availab
SET RELATION TO av_date INTO season IN availab ADDITIVE
ENDPROC
*
PROCEDURE ListGet
LPARAMETERS lp_dStartDate, lp_nDays, lp_lNoExport, lp_cBuliding, lp_lMultiProper
LOCAL l_oAvailParam, l_nSelect, l_lSuccess, l_lNoExport, o AS Form, ldMinDate, ldMaxDate

l_nSelect = SELECT()

l_oData = MakeStructure("FromDate, Days, ResultCursor, PropsCursor, nRoomTypeNo, ndummyno, nVirtualNo, aColumns(1)")
l_oData.FromDate = lp_dStartDate
l_oData.Days = lp_nDays

l_oAvailParam = CREATEOBJECT("Collection")
l_oAvailParam.Add(l_oData)
l_lNoExport = PCOUNT()>=3 AND lp_lNoExport
IF l_lNoExport
     DO CASE
          CASE lp_lMultiProper
               ldMinDate = {}
               ldMaxDate = {}
               p_oFakeAvlForm = CREATEOBJECT("form")
               p_oFakeAvlForm.name = "brwmultipropavail"
               p_oFakeAvlForm.AddObject("frmSearch","Custom")
               p_oFakeAvlForm.frmSearch.AddObject("frmBrowse","Custom")
               p_oFakeAvlForm.frmSearch.frmBrowse.AddProperty("aHotels(1)")
               p_oFakeAvlForm.frmSearch.frmBrowse.ahotels(1)=""
               p_oFakeAvlForm.frmSearch.frmBrowse.AddObject("oParams", "Custom")
               SqlCursor("SELECT .T. AS ho_select, ho_descrip, [   ] AS ho_buildng, ho_hotcode, ho_path FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotels",,,,,,.T.)
               IF NOT EMPTY(lp_cBuliding)
                    REPLACE ho_select WITH .F. FOR ho_hotcode <> lp_cBuliding IN curHotels
               ENDIF
               SELECT ho_hotcode, ho_buildng, ho_path, .F. FROM curHotels WHERE ho_select INTO ARRAY p_oFakeAvlForm.frmSearch.frmBrowse.ahotels
               FOR i = 1 TO ALEN(p_oFakeAvlForm.frmSearch.frmBrowse.ahotels,1)
                    p_oFakeAvlForm.frmSearch.frmBrowse.aHotels[i,4] = NEWOBJECT("AvlSession", "ProcMultiProper.prg", "", p_oFakeAvlForm.frmSearch.frmBrowse.ahotels[i,1])
                    p_oFakeAvlForm.frmSearch.frmBrowse.aHotels[i,4].GetInterval(@ldMinDate, @ldMaxDate)
               NEXT
          CASE NOT EMPTY(lp_cBuliding)
               o = CREATEOBJECT("form")
               o.name = "brwavail"
               o.AddProperty("cBuilding",lp_cBuliding)
     ENDCASE
     BrwAvailab(IIF(lp_lMultiProper,"brwmultipropavail",.F.),,,,l_oAvailParam,,.T.,lp_cBuliding)
     o = .NULL.
ELSE
     BrwAvailab(,,,,l_oAvailParam)
ENDIF
l_lSuccess = NOT EMPTY(l_oData.ResultCursor) AND USED(l_oData.ResultCursor)
IF l_lSuccess
     IF l_lNoExport
          this.oAvlData = l_oData
          l_oData = .NULL.
     ELSE
          this.Export(l_oData.ResultCursor)
          this.cResultAvailab = this.cResultTable
          this.Export(l_oData.PropsCursor)
     ENDIF
ENDIF

SELECT (l_nSelect)

RETURN l_lSuccess
ENDPROC
*
PROCEDURE PrintReport
LPARAMETERS lp_dFromDate, lp_dToDate, lp_cBuliding, lp_lMultiProper
LOCAL l_dEndDate, l_dStartDate, l_cField, l_cMacro, l_nOldArea, l_cRecordSource
LOCAL l_nIndexNoDispRT, l_nIndexDispRT, l_nIndexRT, l_i, l_nColCount
LOCAL l_nRecNo, l_cDescripVar, l_nIndexDispNS, l_nIndexNoDispNS, lcSearchValue
LOCAL l_lOOO, l_lAllott, l_lExpCol, l_nMaxRTForCursor, l_cRtVarMacro, l_l6PM, l_lExtRes
LOCAL l_cFrx, l_cLangDbf, l_lAskForEndDate
LOCAL l_oData, l_lSuccess, l_nDays, l_nNewValue

PRIVATE txTtitle, txTdate, txTevent
PRIVATE txTns1, txTns2, txTns3
PRIVATE txTfree, txTdefinit, txToption, txTwaiting, txTtentat,  ;
          txTooorder, txTooservice, txTallott, txTpick, txTsixpm
PRIVATE p_oFakeAvlForm
p_oFakeAvlForm = .NULL.
STORE "" TO txTtitle, txTdate, txTevent
STORE "" TO txTns1, txTns2, txTns3
STORE "" TO txTfree, txTdefinit, txToption, txTwaiting, txTtentat, txTooorder, txTooservice, txTallott, txTpick, txTsixpm, txText

IF EMPTY(lp_dFromDate)
     lp_dFromDate = sysdate()
ENDIF

txTtitle = GetLangText("VIEW","TXT_AVWINDOW")
txTdate = GetLangText("VIEW","TXT_AVDATE")
txTevent = GetLangText("VIEW","TXT_AVEVENT")
txTfree = GetLangText("VIEW","TXT_AVFREE")
txTdefinit = GetLangText("VIEW","TXT_AVDEFI")
txToption = GetLangText("VIEW","TXT_AVOPTI")
txTwaiting = GetLangText("VIEW","TXT_AVWAIT")
txTtentat = GetLangText("VIEW","TXT_AVTENT")
txTsixpm = GetLangText("VIEW","TXT_6PM")
txTooorder = GetLangText("VIEW","TXT_AVOOORDER")
txTooservice = GetLangText('VIEW','TXT_AVOOSERVC')
txTallott = GetLangText("VIEW","TXT_AVALLOTT")
txTpick = GetLangText("VIEW","TXT_AVPICK")
txText = GetLangText("VIEW","TXT_EXT_RESER")

l_lAskForEndDate = _screen.oGlobal.lAvailabilityShowPrintDialog
l_dStartDate = lp_dFromDate

DO CASE
     CASE l_lAskForEndDate
          l_dEndDate = this.onprintgettodate(l_dStartDate)
          IF EMPTY(l_dEndDate)
               SELECT(l_nOldArea)
               RETURN .T.
          ENDIF
     CASE NOT EMPTY(lp_dToDate)
          l_dEndDate = lp_dToDate
     CASE _screen.oGlobal.oParam.pa_expavl
          l_dEndDate = l_dStartDate + 49
     OTHERWISE
          * if first day od month is selected, then print all days for selected month
          IF MONTH(l_dStartDate-1)<>MONTH(l_dStartDate)
               l_dEndDate = GOMONTH(l_dStartDate, 1)-1
          ELSE
               * else print next 28 days
               l_dEndDate = l_dStartDate + 28
          ENDIF
ENDCASE

l_nDays = l_dEndDate - l_dStartDate + 1
l_lSuccess = this.listget(l_dStartDate,l_nDays,.T.,lp_cBuliding,lp_lMultiProper)
IF NOT l_lSuccess
     RETURN .F.
ENDIF
l_oData = this.oAvlData

l_nColCount = 0
l_nOldArea = SELECT()

TEXT TO l_cMacro TEXTMERGE NOSHOW PRETEXT 15
     CREATE CURSOR Query (date D (8), event C (30), free N (7, 2), 
               ns1 N (7, 2), ns2 N (7, 2), ns3 N (7, 2), 
               definit N (7, 2), option N (7, 2), 
               waiting N (7, 2), tentat N (7, 2), sixpm N (7, 2), 
               ooorder N (7, 2), ooservice N (7, 2), 
               allott N (7, 2), pick N (7, 2), 
               hs_arr_room N(7,2), hs_arr_pers N(7,2), hs_in_room  N(7,2), 
               hs_in_pers  N(7,2), hs_dep_room N(7,2), hs_dep_pers N(7,2),
               ext N (7, 2),
ENDTEXT
l_nMaxRTForCursor = MIN(MAX(l_oData.nroomtypeno, 10), 220)
FOR l_i = 1 TO l_nMaxRTForCursor
     * Initialize txTrt private variables for report here
     l_cRtVarMacro = "txTrt" + TRANSFORM(l_i)
     &l_cRtVarMacro = ""

     l_cMacro =  l_cMacro + "rt" + TRANSFORM(l_i) + " N (7, 2),"
ENDFOR
l_cMacro = LEFT(l_cMacro,LEN(l_cMacro)-1)
l_cMacro = l_cMacro + ")"

&l_cMacro

* check if all columns exists in cursor?
l_lOOO = .F.
IF this.fieldexists(GetLangText('VIEW','TXT_AVOOORDER')) AND ;
          this.fieldexists(GetLangText('VIEW','TXT_AVOOSERVC'))
     l_lOOO = .T.
ENDIF

l_lAllott = .F.
IF this.fieldexists(GetLangText('VIEW','TXT_AVALLOTT')) AND ;
          this.fieldexists(GetLangText('VIEW','TXT_AVPICK'))
     l_lAllott = .T.
ENDIF

l_lExpCol = .F.
IF this.fieldexists(GetLangText("VIEW","TXT_ARRROOM")) AND ;
          this.fieldexists(GetLangText("VIEW","TXT_ARRPERS")) AND ;
          this.fieldexists(GetLangText("VIEW","TXT_INROOM")) AND ;
          this.fieldexists(GetLangText("VIEW","TXT_INPERS")) AND ;
          this.fieldexists(GetLangText("VIEW","TXT_DEPROOM")) AND ;
          this.fieldexists(GetLangText("VIEW","TXT_DEPPERS"))
     l_lExpCol = .T.
ENDIF

l_l6PM = .T.
IF NOT this.fieldexists(txTsixpm)
     l_l6PM = .F.
     txTsixpm = "" && Hide column in report
ENDIF

l_lExtRes = .T.
IF NOT this.fieldexists(txText)
     l_lExtRes = .F.
     txText = "" && Hide column in report
ENDIF
l_cRCur = l_oData.ResultCursor

SELECT (l_cRCur)

this.LinkRT()
this.LinkDUM()
this.LinkVT()

GO TOP
DO WHILE NOT l_dStartDate > l_dEndDate
     SELECT Query
     APPEND BLANK
     REPLACE date WITH l_dStartDate, ;
               event WITH &l_cRCur..cevent, ;
               free WITH &l_cRCur..nfree, ;
               definit WITH &l_cRCur..ndef IN Query

     IF l_l6PM
          REPLACE sixpm WITH &l_cRCur..nsixpm ;
                    IN Query
               l_nColCount = 6
     ELSE
               l_nColCount = 5
     ENDIF

     REPLACE option WITH &l_cRCur..nopt IN Query
     l_nColCount = l_nColCount + 1
     
     IF "LST" == DbLookup("picklist", "tag4", PADR("RESSTATUS", 10) + "LST", "pl_charcod")
          REPLACE waiting WITH &l_cRCur..nlst IN Query
          l_nColCount = l_nColCount + 1
     ENDIF
     IF "TEN" == DbLookup("picklist", "tag4", PADR("RESSTATUS", 10) + "TEN", "pl_charcod")
          REPLACE tentat WITH &l_cRCur..nten ;
                    IN Query
          l_nColCount = l_nColCount + 1
     ENDIF
     IF l_lOOO
          REPLACE ooorder WITH &l_cRCur..nooo, ;
                    ooservice WITH &l_cRCur..noos ;
                    IN Query
               l_nColCount = l_nColCount + 2
     ENDIF
     IF l_lAllott
          IF RECCOUNT("Altsplit") > 0
               REPLACE allott WITH &l_cRCur..nalt, ;
                         pick WITH &l_cRCur..npick IN Query
               l_nColCount = l_nColCount + 2
          ENDIF
     ENDIF
     l_nIndexDispRT = 1
     l_nIndexNoDispRT = l_oData.nroomtypeno
     IF l_oData.nroomtypeno <> 0
          FOR l_i = 1 TO l_oData.nroomtypeno
               DO CASE
                    CASE EMPTY(l_oData.aColumns(l_i+2,9))
                         LOOP
                    CASE lp_lMultiProper
                         IF EMPTY(p_oFakeAvlForm.frmSearch.frmBrowse.aHotels)
                              lcSearchValue = ""
                         ELSE
                              lnRow = ASCAN(p_oFakeAvlForm.frmSearch.frmBrowse.aHotels, LEFT(l_oData.aColumns(l_i+2,9),10), 1, 0, 1, 8)
                              IF lnRow = 0
                                   lcSearchValue = ""
                              ELSE
                                   lcSearchValue = p_oFakeAvlForm.frmSearch.frmBrowse.aHotels[lnRow,4].GetRoomtype(STUFF(l_oData.aColumns(l_i+2,9),1,10,""),p_oFakeAvlForm.frmSearch.frmBrowse.aHotels[lnRow,2])
                              ENDIF
                         ENDIF
                    OTHERWISE
                         SELECT roomtype
                         IF VARTYPE(l_oData.aColumns(l_i+2,9)) = "N"
                              LOCATE FOR rt_rdid = l_oData.aColumns(l_i+2,9) AND rt_vwshow&& AND (EMPTY(this.cBuilding) OR rt_buildng = this.cBuilding)
                         ELSE
                              LOCATE FOR rt_roomtyp = l_oData.aColumns(l_i+2,9) AND rt_vwshow
                         ENDIF
                         lcSearchValue = roomtype.rt_roomtyp
               ENDCASE
               IF NOT EMPTY(lcSearchValue)
                    IF lp_lMultiProper
                         l_nNewValue = NVL(EVALUATE(l_cRCur + "." + this.aVRLink(l_i)),0)
                         l_cMacro = "REPLACE rt"+ ALLTRIM(STR(l_nIndexDispRT)) +" WITH l_nNewValue IN Query"
                    ELSE
                         l_nNewValue = NVL(EVALUATE(l_cRCur + "." + this.aRTLink(l_i)),0)
                         l_cMacro = "REPLACE rt"+ ALLTRIM(STR(l_nIndexDispRT)) +" WITH l_nNewValue IN Query"
                    ENDIF
                    &l_cMacro
                    l_cDescripVar = "txtRt" + ALLTRIM(STR(l_nIndexDispRT))
                    IF EMPTY(&l_cDescripVar)
                         &l_cDescripVar = l_oData.aColumns(l_i+2,3)
                    ENDIF
                    l_nIndexDispRT = l_nIndexDispRT + 1
               ENDIF
               IF l_nIndexDispRT > l_nIndexNoDispRT
                    EXIT
               ENDIF
          ENDFOR
     ENDIF
     l_nIndexDispNS = 1
     l_nIndexNoDispNS = 3
     IF l_oData.ndummyno <> 0
          FOR l_i = 1 TO l_oData.ndummyno
               l_cMacro = "REPLACE ns"+ ALLTRIM(STR(l_nIndexDispNS)) +" WITH "+ l_cRCur + ;
                              "."+this.aDLink(l_i) +" IN Query"
               &l_cMacro
               l_cDescripVar = "txtNs" + ALLTRIM(STR(l_nIndexDispNS))
               IF EMPTY(&l_cDescripVar)
                    &l_cDescripVar = l_oData.aColumns(l_i+3+l_oData.nroomtypeno,3)
               ENDIF
               l_nIndexDispNS = l_nIndexDispNS + 1
               IF l_nIndexDispNS > l_nIndexNoDispNS
                    EXIT
               ENDIF
          ENDFOR
     ENDIF
     SELECT Query
     l_nColCount = l_nColCount + l_oData.nroomtypeno + l_oData.ndummyno
     IF l_lExtRes
          REPLACE ext WITH &l_cRCur..nextreser ;
                    IN Query
               l_nColCount = l_nColCount + 1
     ENDIF
     IF _screen.oGlobal.oParam.pa_expavl AND l_lExpCol
          REPLACE hs_arr_room WITH &l_cRCur..nrmsarr, ;
                    hs_arr_pers WITH &l_cRCur..nprsarr, ;
                    hs_in_room WITH &l_cRCur..nrmsinh, ;
                    hs_in_pers WITH &l_cRCur..nprsinh, ;
                    hs_dep_room WITH &l_cRCur..nrmsdep, ;
                    hs_dep_pers WITH &l_cRCur..nprsdep ;
                    IN Query
          l_nColCount = l_nColCount + 6
     ENDIF
     SKIP 1 IN (l_cRCur)
     l_dStartDate = l_dStartDate + 1
ENDDO

IF .F.
     * For testing only!
      l_cRepName = "_AV00101.FRX"
      l_cFor = ".T."
      l_cReport = ADDBS(gcReportdir)+l_cRepName
      l_lNoListsTable = .T.
      IF g_lUseNewRepPreview
           loSession=EVALUATE([xfrx("XFRX#LISTENER")])
           lnRetVal = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
           IF lnRetVal = 0
                l_lAutoYield = _vfp.AutoYield
                _vfp.AutoYield = .T.
                REPORT FORM (l_cReport) FOR &l_cFor OBJECT loSession
                loXFF = loSession.oxfDocument 
                _vfp.AutoYield = l_lAutoYield
                loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
                loExtensionHandler.lNoListsTable = l_lNoListsTable
                loPreview = CREATEOBJECT("frmMpPreviewerDesk")
                loPreview.setExtensionHandler(loExtensionHandler)
                loPreview.PreviewXFF(loXFF)
                loPreview.show(1)
                loExtensionHandler = .NULL.
           ENDIF
      ENDIF

ELSE

     l_cFrx = ""
     IF _screen.oGlobal.oParam.pa_expavl OR this.Name = "brwmultipropavail"
          IF FILE(gcReportdir+"xAV00101.FRX")
               l_cFrx = gcReportdir+"xAV00101.FRX"
          ELSE
               l_cFrx = gcReportdir+"_AV00101.FRX"
          ENDIF
     ELSE
          IF FILE(gcReportdir+"xAV00100.FRX")
               l_cFrx = gcReportdir+"xAV00100.FRX"
          ELSE
               l_cFrx = gcReportdir+"_AV00100.FRX"
          ENDIF
     ENDIF

     l_cLangDbf = STRTRAN(UPPER(l_cFrx), '.FRX', '.DBF')
     IF FILE(l_cLangDbf)
          dclose("reptext")
          USE SHARED NOUPDATE (l_cLangDbf) ALIAS reptext IN 0
     ENDIF
     *REPORT FORM (l_cFrx) TO PRINTER PROMPT NOCONSOLE
     MLShowReportDialog(l_cFrx)
     dclose("reptext")
ENDIF

p_oFakeAvlForm = .NULL.

USE IN Query
SELECT (l_nOldArea)


RETURN .T.
ENDPROC
*
PROCEDURE LinkRT
LOCAL l_lFound, l_nSearchFrom, i, l_nIndex
LOCAL ARRAY l_aFields(1)
AFIELDS(l_aFields)
l_lFound = .T.
l_nSearchFrom = 1
i = 0
DO WHILE l_lFound
     l_nIndex = ASCAN(l_aFields,"RT_", l_nSearchFrom)
     IF l_nIndex > 0
          l_nSearchFrom = l_nIndex + 1
          * In cursor are fields with same prefix RT_, but for background color. Those field have letter in end of field name.
          * Eg: rt_2bc. Because of that, we check if last character in field name is number, and take only those fields.
          IF ISDIGIT(RIGHT(l_aFields(l_nIndex),1))
               i = i + 1
               l_nSearchFrom = l_nIndex + 1
               DIMENSION this.aRTLink(i)
               this.aRTLink(i) = l_aFields(l_nIndex)
          ENDIF
     ELSE
          l_lFound = .F.
     ENDIF
ENDDO
RETURN .T.
ENDPROC
*
PROCEDURE LinkDUM
LOCAL l_lFound, l_nSearchFrom, i, l_nIndex
LOCAL ARRAY l_aFields(1)
AFIELDS(l_aFields)
l_lFound = .T.
l_nSearchFrom = 1
i = 0
DO WHILE l_lFound
     i = i + 1
     l_nIndex = ASCAN(l_aFields,"D_", l_nSearchFrom)
     IF l_nIndex > 0
          l_nSearchFrom = l_nIndex + 1
          DIMENSION this.aDLink(i)
          this.aDLink(i) = l_aFields(l_nIndex)
     ELSE
          l_lFound = .F.
     ENDIF
ENDDO
ENDPROC
*
PROCEDURE LinkVT
LOCAL l_lFound, l_nSearchFrom, i, l_nIndex
LOCAL ARRAY l_aFields(1)
AFIELDS(l_aFields)
l_lFound = .T.
l_nSearchFrom = 1
i = 0
DO WHILE l_lFound
     i = i + 1
     l_nIndex = ASCAN(l_aFields,"VR_", l_nSearchFrom)
     IF l_nIndex > 0
          l_nSearchFrom = l_nIndex + 1
          DIMENSION this.aVRLink(i)
          this.aVRLink(i) = l_aFields(l_nIndex)
     ELSE
          l_lFound = .F.
     ENDIF
ENDDO
ENDPROC
PROCEDURE onprintgettodate
LPARAMETERS lp_dStartDate
LOCAL l_dEndDate
l_dEndDate = lp_dStartDate + _screen.oGlobal.nAvailabilityShowPrintDialogDefaultDays

LOCAL ARRAY adLg[2, 10]
adLg[1, 1] = "start"
adLg[1, 2] = GetLangText("MGRFINAN","TXT_RCFROMDATE")
adLg[1, 3] = sqlcnv(lp_dStartDate)
adLg[1, 4] = "!999999999"
adLg[1, 5] = siZedate()+5
adLg[1, 6] = "!Empty(start)"
adLg[1, 7] = ""
adLg[1, 8] = {}
adLg[1, 10] =.T.
adLg[2, 1] = "end"
adLg[2, 2] = GetLangText("MGRFINAN","TXT_RCTODATE")
adLg[2, 3] = sqlcnv(l_dEndDate)
adLg[2, 4] = "!999999999"
adLg[2, 5] = siZedate()+5
adLg[2, 6] = "!Empty(end)"
adLg[2, 7] = ""
adLg[2, 8] = {}
IF diAlog(GetLangText("AR","TXT_PRINT"),'',@adLg)
     IF NOT EMPTY(adLg(2,8)) AND adLg(2,8)>=lp_dStartDate
          l_dEndDate = adLg(2,8)
     ENDIF
ELSE
     l_dEndDate = {}
ENDIF

RETURN l_dEndDate
ENDPROC
*
PROCEDURE fieldexists
LPARAMETERS lp_cCaption
LOCAL l_lExists, i
l_lExists = .F.
IF EMPTY(lp_cCaption)
     RETURN l_lExists
ENDIF
* Find field
FOR i = 1 TO ALEN(this.oAvlData.aColumns,1)
     IF this.oAvlData.aColumns(i,3) = lp_cCaption
          l_lExists = .T.
          EXIT
     ENDIF
ENDFOR

RETURN l_lExists
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS chotelstatmydesk AS chotelstat OF procavailability.prg
DataSession = 1
*
PROCEDURE Init
RETURN .T.
ENDPROC
*
PROCEDURE CleanUp
dclose(this.curResultEvent)
dclose(this.curResultHotStat)
dclose(this.cResultEvent)
RETURN .T.
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS chotelstat AS cbobj OF commonclasses.prg
*
#IF .F.
   *-- Define This for IntelliSense use
   LOCAL this AS chotelstat OF procavailability.prg
#ENDIF
*
DataSession = 2
cResultEvent = ""
curResultHotStat = ""
curResultEvent = ""
*
PROCEDURE Init
Ini(,,,,.T.)
DODEFAULT()
this.UseTables()
ENDPROC
*
PROCEDURE UseTables
OpenFileDirect(,"room")
OpenFileDirect(,"roomtype")
OpenFileDirect(,"outoford")
OpenFileDirect(,"outofser")
OpenFileDirect(,"altsplit")
OpenFileDirect(,"building")
OpenFileDirect(,"reservat")
OpenFileDirect(,"histres")
OpenFileDirect(,"resrooms")
OpenFileDirect(,"hresroom")
OpenFileDirect(,"sharing")
OpenFileDirect(,"resrate")
OpenFileDirect(,"resrmshr")
OpenFileDirect(,"season")
OpenFileDirect(,"evint")
OpenFileDirect(,"events")
ENDPROC
*
PROCEDURE ListGet
LPARAMETERS tdStartDate, tnDays
LOCAL ARRAY laHsData[1], laToday[1], laVirtRt[1], laForecast[1]
LOCAL i, j, lnSelect, lcurSeason, lcSql, lcField, loRecord

lnSelect = SELECT()

this.curResultHotStat = SYS(2015)
this.curResultEvent = SYS(2015)

lcField = ""
FOR i = 1 TO tnDays
	lcField = lcField + ", cData" + TRANSFORM(i) + " C(30), BColor" + TRANSFORM(i) + " I"
NEXT

CREATE CURSOR (this.curResultEvent) (cDescr C(100) &lcField)
SCATTER BLANK NAME loRecord

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
SELECT se_date, se_event, se_color FROM season
	LEFT JOIN evint ON se_date BETWEEN ei_from AND ei_to
	LEFT JOIN events ON ev_evid = ei_evid
	WHERE se_date BETWEEN <<SqlCnv(tdStartDate,.T.)>> AND <<SqlCnv(tdStartDate+tnDays-1,.T.)>> AND
		(NOT se_event = '                              ' OR NOT se_color = '           ')
	ORDER BY se_date
ENDTEXT
lcurSeason = SqlCursor(lcSql)
SCAN
	IF NOT EMPTY(se_event)
		lcField = "cData" + TRANSFORM(se_date-tdStartDate+1)
		loRecord.&lcField = ALLTRIM(se_event)
	ENDIF
	IF NOT EMPTY(se_color)
		lcField = "BColor" + TRANSFORM(se_date-tdStartDate+1)
		loRecord.&lcField = EVALUATE("RGB(" + se_color + ")")
	ENDIF
ENDSCAN
DClose(lcurSeason)
INSERT INTO (this.curResultEvent) FROM NAME loRecord
this.Export(this.curResultEvent)
this.cResultEvent = this.cResultTable

lcField = ""
FOR i = 1 TO tnDays
	lcField = lcField + ", cData" + TRANSFORM(i) + " C(9)"
NEXT

CREATE CURSOR (this.curResultHotStat) (cDescr C(100), BColor I, FColor I, cData0 C(3) &lcField)
SCATTER BLANK NAME loRecord

PRIVATE	dFirst, cBuildingExp
dFirst = IIF(EMPTY(tdStartDate), SysDate(), tdStartDate)
cBuildingExp = "1=1"
DO ReadData IN Hotstat WITH 1, tnDays, laHsData, laToday, laVirtRt, laForecast

FOR j = 1 TO ALEN(laHsData,1)
	loRecord.cDescr = laHsData[j,1]
	loRecord.BColor = laHsData[j,2]
	loRecord.FColor = laHsData[j,3]
	loRecord.cData0 = ICASE(INLIST(j,12,13) AND NOT EMPTY(laToday[j-11]), TRANSFORM(laToday[j-11]), INLIST(j,16,17) AND NOT EMPTY(laToday[j-13]), TRANSFORM(laToday[j-13]), "")
	FOR i = 1 TO tnDays
		lcField = "cData" + TRANSFORM(i)
		loRecord.&lcField = TRANSFORM(ROUND(laHsData(j,i+4),laHsData(j,4)))
	NEXT
	INSERT INTO (this.curResultHotStat) FROM NAME loRecord
	IF j = 8 AND NOT EMPTY(laVirtRt[1])
		FOR k = 1 TO ALEN(laVirtRt,1)
			loRecord.cDescr = laVirtRt[k,1]
			loRecord.BColor = laVirtRt[k,2]
			loRecord.FColor = laVirtRt[k,3]
			loRecord.cData0 = ""
			FOR i = 1 TO tnDays
				lcField = "cData" + TRANSFORM(i)
				loRecord.&lcField = TRANSFORM(ROUND(laVirtRt(k,i+4),laVirtRt(k,4)))
			NEXT
			INSERT INTO (this.curResultHotStat) FROM NAME loRecord
		NEXT
	ENDIF
NEXT
IF NOT EMPTY(laForecast[1])
	FOR k = 1 TO ALEN(laVirtRt,1)
		loRecord.cDescr = laForecast[k,1]
		loRecord.BColor = laForecast[k,2]
		loRecord.FColor = laForecast[k,3]
		loRecord.cData0 = ""
		FOR i = 1 TO tnDays
			lcField = "cData" + TRANSFORM(i)
			loRecord.&lcField = TRANSFORM(ROUND(laForecast(k,i+4),laForecast(k,4)))
		NEXT
		INSERT INTO (this.curResultHotStat) FROM NAME loRecord
	NEXT
ENDIF
this.Export(this.curResultHotStat)

SELECT (lnSelect)

RETURN .T.
ENDPROC
*
PROCEDURE GetHtmlTable
* Hotel stat for MyDesk
LPARAMETERS tdStartDate, tnDays
LOCAL i, lcDataFld, lcTable, lcRow

lcTable = ""

this.ListGet(tdStartDate, tnDays)

SELECT (this.curResultHotStat)
SCAN
	lcRow = "<tr "+ICASE(RECNO()=5,"class='boldred'",RECNO()=8,"class='boldblue'","")+"><td class='descr'>"+ALLTRIM(cDescr)+"</td>"
	*lcRow = "<tr "+IIF(BColor<>RGB(255,255,255),"style='color:"+HtmlColor(BColor)+"'","")+"><td class='descr'>"+ALLTRIM(cDescr)+"</td>"
	FOR i = 1 TO tnDays
        lcDataFld = "cData" + TRANSFORM(i)
		lcRow = lcRow + "<td>" + ALLTRIM(&lcDataFld) + "</td>"
	NEXT
	lcRow = lcRow + "</tr>"
	lcTable = lcTable + lcRow + CRLF
ENDSCAN

RETURN lcTable
ENDPROC
*
ENDDEFINE
*
PROCEDURE HtmlColor
* Return HTML color code from VFP color code

* Parameters:
* lnrgbcolor - VFP color numberical value

* Returns: hmtl color code as string.
LPARAMETERS tnRgbColor
LOCAL lcColor

lcColor = RIGHT(TRANSFORM(tnRgbColor, "@0"), 6)
RETURN '#'+ SUBSTR(lcColor, 5, 2)+SUBSTR(lcColor, 3, 2)+LEFT(lcColor, 2)
ENDPROC
*