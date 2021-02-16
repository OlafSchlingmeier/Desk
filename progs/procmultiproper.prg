LOCAL l_cHotCode

l_cHotCode = GetHotel(_screen.oGlobal.oParam2.pa_hotcode)
IF NOT EMPTY(l_cHotCode) AND NOT _screen.oGlobal.oMultiProper.IsThisHotelSelected(l_cHotCode)
     _screen.oGlobal.oMultiProper.HotelSwitchCall(l_cHotCode)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE GetHotel
LPARAMETERS lp_cDefaultHotel, lp_cHotCode
LOCAL l_cHotels, l_oDatabaseProp
LOCAL ARRAY l_aDialogData(1,11)

lp_cHotCode = ""
IF OpenFile(.F., "hotel")
     l_cHotels = ""
     SELECT hotel
     SCAN FOR NOT ho_mainsrv
          IF goDatabases.GetKey(ALLTRIM(ho_hotcode)) > 0
               l_oDatabaseProp = goDatabases.Item(ALLTRIM(ho_hotcode))
               IF NOT EMPTY(l_oDatabaseProp.cServerName) AND NOT EMPTY(l_oDatabaseProp.nServerPort)
                    l_cHotels = l_cHotels + "," + SqlCnv(ho_hotcode)
               ENDIF
          ENDIF
     ENDSCAN
     l_aDialogData(1,1) = "cbohotels"
     l_aDialogData(1,2) = GetLangText("MULTIPRO","TXT_HOTEL")
     l_aDialogData(1,3) = SqlCnv(lp_cDefaultHotel)
     l_aDialogData(1,4) = "@G"
     l_aDialogData(1,5) = 20
     l_aDialogData(1,6) = ""
     l_aDialogData(1,7) = ""
     l_aDialogData(1,9) = "SELECT ho_hotcode, ho_descrip, ho_path FROM hotel" + IIF(EMPTY(l_cHotels), "", " WHERE NOT INLIST(ho_hotcode"+l_cHotels+")")
     l_aDialogData(1,11) = CREATEOBJECT("collection")
     l_aDialogData(1,11).Add(3,"ColumnCount")
     l_aDialogData(1,11).Add(1,"BoundColumn")
     l_aDialogData(1,11).Add(.T.,"BoundTo")
     l_aDialogData(1,11).Add(.F.,"ColumnLines")
     l_aDialogData(1,11).Add("100,200,0","ColumnWidths")
     l_aDialogData(1,11).Add(3,"RowSourceType")
     IF Dialog(GetLangText("MULTIPRO","TXT_SWITCH_HOTEL"), "", @l_aDialogData)
          lp_cHotCode = ALLTRIM(TRANSFORM(l_aDialogData(1,8)))
     ENDIF
ENDIF

RETURN lp_cHotCode
ENDPROC
*
PROCEDURE PMSwitchToHotel
LPARAMETERS lp_cHotCode, lp_cCallForm
_screen.oGlobal.oMultiProper.SwitchToHotel(lp_cHotCode, lp_cCallForm)
ENDPROC
*
**********************************************************************************************************
*
DEFINE CLASS cMultiProper AS Custom
oSelectedHotel = .NULL.
oPreviousHotel = .NULL.
DIMENSION aFormParams[1], aScriptParams[1]
nswitchretrycounter = 0
cOldDataDir = ""
cExecScript = ""
lSwitchingHotel = .F.
*
PROCEDURE SwitchToHotel
LPARAMETERS lp_cHotCode, lp_cCallForm
LOCAL l_cDir, l_cHotPath, l_cMacro, l_cHotelDir, l_cCur
IF EMPTY(lp_cHotCode)
     RETURN .F.
ENDIF
IF NOT openfiledirect(.F., "hotel",,FNGetMPDataPath(_screen.oGlobal.oParam2.pa_srvpath))
     RETURN .F.
ENDIF

* Get data for new hotel
l_cCur = sqlcursor("SELECT * FROM hotel WHERE ho_hotcode = " + sqlcnv(lp_cHotCode,.T.))
IF RECCOUNT()>0
     SELECT (l_cCur)
     SCATTER MEMO NAME this.oSelectedHotel
ELSE
     dclose(l_cCur)
     RETURN .F.
ENDIF
dclose(l_cCur)

IF NOT EMPTY(this.oSelectedHotel.ho_path) AND DIRECTORY(this.oSelectedHotel.ho_path)
     l_cDir = FNGetMPDataPath(this.oSelectedHotel.ho_path)
ELSE
     alert(Getlangtext("SRVSETTI","TXT_HOTEL_PATH") + CHR(13) + ;
               ALLTRIM(TRANSFORM(this.oSelectedHotel.ho_path)) + CHR(13) + ;
               LOWER(Getlangtext("RESERVAT","TA_NOTFOUND")))
     RETURN .F.
ENDIF

* Get data for old hotel
l_cCur = sqlcursor("SELECT * FROM hotel WHERE ho_hotcode = " + sqlcnv(_screen.oGlobal.oParam2.pa_hotcode,.T.))
IF RECCOUNT()>0
     SELECT (l_cCur)
     SCATTER MEMO NAME this.oPreviousHotel
ELSE
     dclose(l_cCur)
     RETURN .F.
ENDIF
dclose(l_cCur)
dclose("hotel")
dclose("rtrdbld")

closeallfiles(.T.)
gcHotCode = ALLTRIM(UPPER(lp_cHotCode))

DO MainSetPath IN main WITH l_cDir
DO MainPrepareData IN main
DO SetBaseAppSettings IN main
DO MainPrepareDataClose IN main

DO SetupPrepareData IN setup
DO SetupAppSettings IN setup
DO SetupPrepareDataClose IN setup

g_oUserData.cuser = _screen.oGlobal.oUser.us_id
g_oUserData.cpass = IIF(EMPTY(_screen.oGlobal.oUser.us_pass),"65535     ",_screen.oGlobal.oUser.us_pass) && Fix when empty
g_oUserData.lPassc = .T.
g_oUserData.ccashier = TRANSFORM(g_Cashier)
this.nswitchretrycounter = this.nswitchretrycounter + 1

DO CASE
     CASE login()
          this.lSwitchingHotel = .F.
          this.nswitchretrycounter = 0
          this.HotelSelected(lp_cHotCode, lp_cCallForm)
     CASE this.nswitchretrycounter > 3
          alert(stRfmt(Getlangtext("MULTIPRO","TXT_MUST_ABORT_SWITCH"),ALLTRIM(this.oPreviousHotel.ho_descrip)))
          DO CHECKWIN IN CHECKWIN WITH 'CLEANUP',.T.,.T.,.F.,.T.
          RETURN TO MASTER
     OTHERWISE
          this.HotelUndoSelect()
          this.lSwitchingHotel = .F.
ENDCASE

RETURN .T.
ENDPROC
*
PROCEDURE HotelCloseData
LPARAMETERS tcHotCodeNeeded, tlReleaseAll
LOCAL lnRow, loForm

FOR EACH loForm IN _screen.Forms
     IF INLIST(LOWER(loForm.Name), "brwmultipropavail", "frmmultipropavail", "mailingform", "mpweekform", "mpresbrw")
          lnRow = ASCAN(loForm.aHotels, tcHotCodeNeeded, 1, 0, 1, 8)
          IF lnRow > 0
               loForm.aHotels[lnRow,4].CloseData()
               IF tlReleaseAll
                    loForm.aHotels[lnRow,4].CloseSystemData()
               ENDIF
          ENDIF
     ENDIF
NEXT
ENDPROC
*
PROCEDURE HotelSwitchCall
LPARAMETERS tcHotCodeNeeded, tcCallForm
LOCAL lcMacro, lnRow, loForm

this.lSwitchingHotel = .T.
this.HotelCloseData(tcHotCodeNeeded)
lcMacro = 'PMSwitchToHotel IN procmultiproper WITH ' + SqlCnv(ALLTRIM(tcHotCodeNeeded)) + ', ' + SqlCnv(tcCallForm)
DO checkwin WITH lcMacro,.T.,,,,.T.
ENDPROC
*
PROCEDURE HotelSelected
LPARAMETERS lp_cHotCode, lp_cCallForm
LOCAL l_cHotelDir
l_cHotelDir = ADDBS(LOWER(this.oSelectedHotel.ho_path))
gcReportdir = l_cHotelDir + "Report\"
gcTemplatedir = l_cHotelDir + "Dot\"
gcDocumentdir = l_cHotelDir + "Document\"
_screen.oGlobal.oStatusBar.SetHotelSelected(.T.)
IF EMPTY(lp_cCallForm)
     this.CallProcess(lp_cHotCode)
ELSE
     this.CallForm(lp_cHotCode, lp_cCallForm)
ENDIF
ENDPROC
*
PROCEDURE HotelUndoSelect
LOCAL l_cHotCode
alert(Getlangtext("MULTIPRO","TXT_LOGIN_FAILED"))
l_cHotCode = ALLTRIM(TRANSFORM(this.oPreviousHotel.ho_hotcode))
this.HotelSwitchCall(l_cHotCode)
ENDPROC
*
PROCEDURE IsThisHotelSelected
LPARAMETERS lp_cHotCode
IF EMPTY(lp_cHotCode)
     RETURN .F.
ENDIF
IF PADR(ALLTRIM(_screen.oGlobal.oParam2.pa_hotcode),10) = PADR(ALLTRIM(lp_cHotCode),10)
     RETURN .T.
ELSE
     RETURN .F.
ENDIF
ENDPROC
*
PROCEDURE GetSelectedHotelPath
RETURN ADDBS(ALLTRIM(this.oSelectedHotel.ho_path))
ENDPROC
*
PROCEDURE CallForm
LPARAMETERS lp_cHotCodeNeeded, lp_cForm

IF EMPTY(lp_cHotCodeNeeded) OR EMPTY(lp_cForm)
     RETURN .F.
ENDIF
IF this.IsThisHotelSelected(lp_cHotCodeNeeded)
     LOCAL l_cForm
     LOCAL ARRAY l_aParameters[1]
     ACOPY(this.aFormParams, l_aParameters)
     DIMENSION this.aFormParams[1]
     STORE .F. TO this.aFormParams
     l_cForm = LOWER(lp_cForm)
     Doform(l_cForm,"Forms\"+l_cForm,,,@l_aParameters)
ELSE
     this.HotelSwitchCall(lp_cHotCodeNeeded, lp_cForm)
ENDIF
ENDPROC
*
PROCEDURE CallProcess
LPARAMETERS lp_cHotCodeNeeded

IF EMPTY(lp_cHotCodeNeeded)
     RETURN .F.
ENDIF
IF this.IsThisHotelSelected(lp_cHotCodeNeeded)
     LOCAL lcExecScript
     LOCAL ARRAY l_aScriptParams[1]

     ACOPY(this.aScriptParams, l_aScriptParams)
     lcExecScript = this.cExecScript

     DIMENSION this.aFormParams[1]
     STORE .F. TO this.cExecScript, this.aScriptParams

     IF NOT EMPTY(lcExecScript)
          RETURN EXECSCRIPT(lcExecScript, @l_aScriptParams)
     ENDIF
ELSE
     this.HotelSwitchCall(lp_cHotCodeNeeded)
ENDIF
ENDPROC
*
PROCEDURE Reservation
LPARAMETERS lp_cHotCodeNeeded

RETURN this.CallForm(lp_cHotCodeNeeded, "RESERVAT")
ENDPROC
*
PROCEDURE ResBrowse
LPARAMETERS lp_cHotCodeNeeded

RETURN this.CallForm(lp_cHotCodeNeeded, "RESBRW")
ENDPROC
*
PROCEDURE DataPathChange
LPARAMETERS tuMainServerFormOrHotcode

this.cOldDataDir = gcDataDir
gcDataDir = FNGetMPDataPath(_screen.oGlobal.oParam2.pa_srvpath)
IF VARTYPE(tuMainServerFormOrHotcode) = "C"
     OpenFile(,"hotel")
     gcDataDir = FNGetMPDataPath(DLookUp("hotel", "ho_hotcode = " + SqlCnv(tuMainServerFormOrHotcode), "ho_path"))
ENDIF
ENDPROC
*
PROCEDURE DataPathRestore
gcDataDir = this.cOldDataDir
ENDPROC
ENDDEFINE
*
DEFINE CLASS MpSession AS PrivateSession OF CommonClasses.prg
     cHotCode = ""
     lUseRemote = .F.
     cApplication = ""
     cPgSchema = ""
     cPrefix = ""
     cDataFolder = ""
     cServerName = ""
     nServerPort = 0
     lEncrypt = .F.
     lSilent = .F.
     DIMENSION aSystemData(1)

     PROCEDURE init
          LPARAMETERS tcHotCode
          LOCAL loDatabaseProp, lcProp
          LOCAL ARRAY laMemb(1)

          this.cHotCode = ALLTRIM(tcHotCode)
          this.Name = this.Name + "_" + LOWER(this.cHotCode)
          IF goDatabases.GetKey(this.cHotCode) > 0
               loDatabaseProp = goDatabases.Item(this.cHotCode)
               AMEMBERS(laMemb, loDatabaseProp)
               FOR EACH lcProp IN laMemb
                    this.&lcProp = loDatabaseProp.&lcProp
               NEXT
               this.lUseRemote = NOT EMPTY(this.cServerName) AND NOT EMPTY(this.nServerPort)
          ENDIF
          DO Ini WITH .T., .T.,,this.cHotCode, this.lUseRemote
          IF NOT this.lUseRemote
               IF DLookUp("hotel", "ho_hotcode = " + SqlCnv(this.cHotCode), "ho_mainsrv") AND NOT _screen.oGlobal.lMainServerDirectoryAvailable
                    this.cDataFolder = gcdatadir
               ELSE
                    this.cDataFolder = FNGetMPDataPath(DLookUp("hotel", "ho_hotcode = " + SqlCnv(this.cHotCode), "ho_path"))
               ENDIF
          ENDIF
     ENDPROC

     PROCEDURE CheckData
          IF this.lUseRemote
               RETURN .T.
          ENDIF
          IF NOT USED("license")
               IF _screen.oGlobal.oMultiProper.lSwitchingHotel
                    RETURN .F.
               ENDIF
               this.OpenSystemData()
          ENDIF

          RETURN USED("license")
     ENDPROC

     PROCEDURE CloseSystemData
          LOCAL i, lcTablePath, lnTables, lcAlias

          IF this.lUseRemote
               RETURN .T.
          ENDIF
          lcTablePath = this.cDataFolder
          lnTables = 0
          FOR i = 1 TO AUSED(laTables)
               lcAlias = LOWER(laTables(i,1))
               If NOT EMPTY(lcAlias) AND USED(lcAlias) AND ADDBS(JUSTPATH(DBF(lcAlias))) == UPPER(lcTablePath)
                    lnTables = lnTables + 1
                    DIMENSION this.aSystemData(lnTables,2)
                    this.aSystemData(lnTables,1) = lcAlias
                    this.aSystemData(lnTables,2) = ORDER(lcAlias)
                    CloseFile(lcAlias)
               ENDIF
          NEXT
     ENDPROC

     PROCEDURE OpenSystemData
          LOCAL i, lcTablePath

          IF NOT EMPTY(this.aSystemData(1))
               lcTablePath = this.cDataFolder
               FOR i = ALEN(this.aSystemData,1) TO 1 STEP -1
                    If NOT USED(this.aSystemData(i,1))
                         IF OpenFileDirect(,this.aSystemData(i,1),,lcTablePath)
                              SET ORDER TO this.aSystemData(i,2) IN (this.aSystemData(i,1))
                         ELSE
                              RETURN .F.
                         ENDIF
                    ENDIF
               NEXT
               DIMENSION this.aSystemData(1)
               STORE "" TO this.aSystemData
          ENDIF
     ENDPROC
ENDDEFINE
*
DEFINE CLASS ResSession AS MpSession
     PROCEDURE CheckData
          IF NOT DODEFAULT()
               RETURN .F.
          ENDIF
          IF NOT USED("reservat")
               IF _screen.oGlobal.oMultiProper.lSwitchingHotel
                    RETURN .F.
               ENDIF
               this.OpenData()
          ENDIF

          RETURN .T.
     ENDPROC

     PROCEDURE OpenData
          LOCAL lcTablePath

          lcTablePath = this.cDataFolder

          OpenFileDirect(,"reservat",,lcTablePath)
          SET ORDER TO tag1 IN reservat
          OpenFileDirect(,"address",,lcTablePath)
          SET ORDER TO tag1 IN address
          OpenFileDirect(,"resrate",,lcTablePath)
          SET ORDER TO tag1 IN resrate
          OpenFileDirect(,"resfix",,lcTablePath)
          SET ORDER TO tag1 IN resfix
     ENDPROC

     PROCEDURE CloseData
          DClose("reservat")
          DClose("address")
          DClose("resrate")
          DClose("resfix")
     ENDPROC

     PROCEDURE CheckForNewReser
          LPARAMETERS toForm, toReser, tcAction

          IF this.CheckData()
               RETURN ProcReservat("CheckReser", @toReser, tcAction, this)
          ENDIF
     ENDPROC
ENDDEFINE
*
DEFINE CLASS AvlSession AS MpSession
     PROCEDURE init
          LPARAMETERS tcHotCode

          DODEFAULT(tcHotCode)
          this.CheckData()
     ENDPROC

     PROCEDURE CheckData
          IF NOT DODEFAULT()
               RETURN .F.
          ENDIF
          IF NOT USED("availab")
               IF _screen.oGlobal.oMultiProper.lSwitchingHotel
                    RETURN .F.
               ENDIF
               this.OpenData()
          ENDIF

          RETURN .T.
     ENDPROC

     PROCEDURE OpenData
          LOCAL lcTablePath

          lcTablePath = this.cDataFolder

          OpenFileDirect(.F.,"availab",,lcTablePath)
          SET ORDER TO tag1 IN availab
          OpenFileDirect(.F.,"season",,lcTablePath)
          SET ORDER TO tag1 IN season
          OpenFileDirect(.F.,"altsplit",,lcTablePath)
          SET ORDER TO tag1 IN altsplit
          OpenFileDirect(.F.,"althead",,lcTablePath)
          SET ORDER TO tag1 IN althead
          *OpenFileDirect(.F.,"param",,lcTablePath)     &&
          OpenFileDirect(.F.,"reservat",,lcTablePath)
          SET ORDER TO tag1 IN reservat
          *OpenFileDirect(.F.,"picklist",,lcTablePath)     &&
          *SET ORDER TO tag1 IN picklist                    &&
          OpenFileDirect(.F.,"citcolor",,lcTablePath)
          SET ORDER TO tag1 IN citcolor
          OpenFileDirect(.F.,"address",,lcTablePath)
          SET ORDER TO tag1 IN address
          *OpenFileDirect(.F.,"room",,lcTablePath)     &&
          *SET ORDER TO tag1 IN room                    &&
          *OpenFileDirect(.F.,"rtypedef",,lcTablePath)     &&
          *SET ORDER TO tag1 IN rtypedef                    &&
          *OpenFileDirect(.F.,"roomtype",,lcTablePath)     &&
          *SET ORDER TO tag1 IN roomtype                    &&
          *OpenFileDirect(.F.,"building",,lcTablePath)     &&
          *SET ORDER TO tag1 IN building                    &&
          OpenFileDirect(.F.,"sharing",,lcTablePath)
          SET ORDER TO tag1 IN sharing
          OpenFileDirect(.F.,"resrooms",,lcTablePath)
          SET ORDER TO tag1 IN resrooms
          OpenFileDirect(.F.,"resrmshr",,lcTablePath)
          SET ORDER TO tag1 IN resrmshr
          OpenFileDirect(.F.,"histres",,lcTablePath)
          SET ORDER TO tag1 IN histres
          OpenFileDirect(.F.,"hresroom",,lcTablePath)
          SET ORDER TO tag1 IN hresroom
          OpenFileDirect(.F.,"evint",,lcTablePath)
          SET ORDER TO tag1 IN evint
          OpenFileDirect(.F.,"events",,lcTablePath)
          SET ORDER TO tag1 IN events
          IF _screen.oGlobal.oParam2.pa_shexria AND _screen.OR
               OpenFileDirect(.F.,"extreser",,lcTablePath)
               SET ORDER TO tag1 IN extreser
          ENDIF

          SET RELATION TO rt_rdid INTO rtypedef IN roomtype
          SET RELATION TO rs_roomtyp INTO roomtype IN reservat
          SET RELATION TO sd_roomtyp INTO roomtype IN sharing
          SET RELATION TO av_roomtyp INTO roomtype IN availab
          SET RELATION TO av_date INTO season IN availab ADDITIVE
     ENDPROC

     PROCEDURE CloseData
          DClose("availab")
          DClose("season")
          DClose("altsplit")
          DClose("althead")
          *DClose("param")
          DClose("reservat")
          *DClose("picklist")
          DClose("citcolor")
          DClose("address")
          *DClose("room")
          *DClose("rtypedef")
          *DClose("roomtype")
          *DClose("building")
          DClose("sharing")
          DClose("resrooms")
          DClose("resrmshr")
          DClose("histres")
          DClose("hresroom")
          DClose("evint")
          DClose("events")
          DClose("extreser")
     ENDPROC

     PROCEDURE GetAvlData
          LPARAMETERS toCurRec, tcBuilding

          IF this.CheckData()
               GetDate(@toCurRec, tcBuilding, this.cHotCode)
          ENDIF

          RETURN .T.
     ENDPROC

     PROCEDURE GetRoomtype
          LPARAMETERS tcVirtType, tcBuilding
          RETURN DLookUp("roomtype", "rt_virroom = " + SqlCnv(PADR(tcVirtType,3)) + " AND rt_buildng = " + SqlCnv(IIF(EMPTY(tcBuilding), "", PADR(tcBuilding,3))), "rt_roomtyp")
     ENDPROC

     PROCEDURE GetInterval
          LPARAMETERS tdMinDate, tdMaxDate
          LOCAL ldMinDate, ldMaxDate

          CALCULATE MIN(av_date), MAX(av_date) ALL TO ldMinDate, ldMaxDate IN availab
          IF NOT EMPTY(ldMinDate) AND (EMPTY(tdMinDate) OR tdMinDate > ldMinDate)
               tdMinDate = ldMinDate
          ENDIF
          IF NOT EMPTY(ldMaxDate) AND (EMPTY(tdMaxDate) OR tdMaxDate < ldMaxDate)
               tdMaxDate = ldMaxDate
          ENDIF
     ENDPROC

     PROCEDURE AvlGetRoomtypes
          LPARAMETERS taRoomtypes
          EXTERNAL ARRAY taRoomtypes

          AvlGetRoomtypes(@taRoomtypes,,this.cHotCode)
     ENDPROC

     PROCEDURE AvlGetEvents
          LPARAMETERS taEvents, tdStartDate, tdEndDate
          EXTERNAL ARRAY taEvents

          AvlGetEvents(@taEvents, tdStartDate, tdEndDate, this.cHotCode)
     ENDPROC

     PROCEDURE AvlEvData
          LPARAMETERS toAvailData, tdStartDate, tdEndDate

          IF this.CheckData()
               AvlEvData(toAvailData, tdStartDate, tdEndDate, this.cHotCode)
          ENDIF
     ENDPROC

     PROCEDURE AvlRtData
          LPARAMETERS toAvailData, tdStartDate, tdEndDate

          IF this.CheckData()
               AvlRtData(toAvailData, tdStartDate, tdEndDate, this.cHotCode)
          ENDIF
     ENDPROC

     PROCEDURE AvlRsData
          LPARAMETERS toAvailData, tdStartDate, tdEndDate, tlShowExpAvl

          IF this.CheckData()
               AvlRsData(toAvailData, tdStartDate, tdEndDate, tlShowExpAvl, this)
          ENDIF
     ENDPROC

     PROCEDURE AvlErData
          LPARAMETERS toAvailData, tdStartDate, tdEndDate

          IF this.CheckData()
               AvlErData(toAvailData, tdStartDate, tdEndDate, this.cHotCode)
          ENDIF
     ENDPROC
ENDDEFINE
*
DEFINE CLASS RpSession AS MpSession
     nStartLine = 0
     nEndLine = 0

     PROCEDURE CheckData
          IF NOT DODEFAULT()
               RETURN .F.
          ENDIF
          IF NOT USED("resrooms")
               IF _screen.oGlobal.oMultiProper.lSwitchingHotel
                    RETURN .F.
               ENDIF
               this.OpenData()
          ENDIF

          RETURN .T.
     ENDPROC

     PROCEDURE OpenData
          LOCAL lcTablePath

          lcTablePath = this.cDataFolder

          DO OpenData IN ProcRoomplan WITH lcTablePath
     ENDPROC

     PROCEDURE CloseData
          DO CloseData IN ProcRoomplan
     ENDPROC

     PROCEDURE RpGetFeatures
          LPARAMETERS taFeatures
          EXTERNAL ARRAY taFeatures

          IF this.CheckData()
               RETURN RpGetFeatures(@taFeatures, this.cHotCode)
          ENDIF
     ENDPROC

     PROCEDURE RpGetRooms
          LPARAMETERS toForm, toSearchTunnel, tcFilter, tcRoomKey, tnFirstRoom

          IF this.CheckData()
               RETURN RpGetRooms(toForm, toSearchTunnel, tcFilter, tcRoomKey, @tnFirstRoom, this)
          ENDIF
     ENDPROC

     PROCEDURE RpRefreshRooms
          LPARAMETERS toForm

          IF this.CheckData()
               RETURN RpRefreshRooms(toForm, this)
          ENDIF
     ENDPROC

     PROCEDURE RpDisplayLine
          LPARAMETERS toForm, tnFirstLine, tnLastLine, tnFirstDate, tnLastDate

          IF this.CheckData()
               RpDisplayLine(toForm, tnFirstLine, tnLastLine, tnFirstDate, tnLastDate, this)
          ENDIF
     ENDPROC

     PROCEDURE CheckForNewReser
          LPARAMETERS toForm, toReser, tcAction

          IF this.CheckData()
               RETURN ProcReservat("CheckReser", @toReser, tcAction, this)
          ENDIF
     ENDPROC
ENDDEFINE
*
DEFINE CLASS SrvData AS Custom
     PROCEDURE init
          LPARAMETERS tcHotCode

          this.cHotCode = tcHotCode
          this.Name = this.Name + "_" + LOWER(this.cHotCode)
          DO ini WITH .T., .T.
          this.OpenData()
     ENDPROC

     PROCEDURE QueryData
          LPARAMETERS tcHotCode, tcSqlSelect, tcCurName
          LOCAL llSuccess, lcTablePath, loTables, lcSqlSelect, lcSql, lnTable, lnPos, lcTable, lcAlias
          llSuccess = .T.
          lcTablePath = DLookUp("hotel", "ho_hotcode = " + SqlCnv(tcHotCode,.T.), "ho_path")
          lcTablePath = ADDBS(LOWER(ALLTRIM(lcTablePath)))
          loTables = CREATEOBJECT("Collection")
          lcSqlSelect = tcSqlSelect
          lcSql = tcSqlSelect
          FOR lnTable = 1 TO OCCURS(lcSqlSelect,"_#")
               lnPos = AT("_#",lcSqlSelect)
               lcSqlSelect = STUFF(lcSqlSelect,1,lnPos,"")
               lcTable = STREXTRACT(lcSqlSelect,"#","#_")
               IF Odbc()
                    lcTablePath = STUFF(lcTablePath, LEN(lcTablePath), 1, ".")
                    lcAlias = LOWER(lcTablePath+lcTable)
               ELSE
                    lcTablePath = FNGetMPDataPath(lcTablePath)
                    lcAlias = LOWER(tcHotCode+lcTable)
                    IF NOT OpenFileDirect(, lcTable, lcAlias, lcTablePath)
                         llSuccess = .F.
                         EXIT
                    ENDIF
                    loTables.Add(lcAlias,lcTable)
               ENDIF
               lcSql = STRTRAN(lcSql,"_#"+lcTable+"#_", lcAlias)
          NEXT
          IF llSuccess
               tcCurName = SqlCursor(lcSqlSelect,tcCurName)
          ENDIF
          FOR EACH lcAlias IN loTables
               DClose(lcAlias)
          NEXT

          RETURN tcCurName



*     IF USED(l_cHotelCur)  AND RECCOUNT()>0
*          l_cSql = "___?HOTCODE___ AS ho_hotcode, rs_reserid, rs_arrdate, rs_depdate, " + ;
*                    "rs_rooms, rd_roomtyp, rs_rmname, " + ;
*                    "rs_adults+rs_childs+rs_childs2+rs_childs3 AS rs_persons, rs_status, " + ;
*                    "rs_ratecod, " + ;
*                    "rs_lname, rs_company " + ;
*                    "FROM ___RESTABLE___ " + ;
*                    "INNER JOIN ___ROOMTYPE___ ON rs_roomtyp = rt_roomtyp " + ;
*                    "INNER JOIN ___RTYPEDEF___ ON rt_rdid = rd_rdid "
*          *l_cWhere = "WHERE rs_status IN (" + sqlcnv("DEF",.T.) + "," + sqlcnv("IN",.T.) + ")"
*          l_cWhere = "WHERE ___WHERE___"
*          IF NOT ISNULL(this.oTables)
*               this.oTables = .NULL.
*               this.oTables = CREATEOBJECT("Collection")
*          ENDIF
*          SELECT (l_cHotelCur)
*          SCAN ALL
*               l_cPath = ADDBS(LOWER(ALLTRIM(ho_path)))
*               l_cPath = IIF(odbc(),LEFT(l_cPath, LEN(l_cPath)-1)+".",l_cPath+"data\") && If odbc database, add . before table name
*               this.oTables.Add(l_cPath + "reservat" + "," + LOWER(ALLTRIM(ho_hotcode)))
*               l_cSqlPrep = STRTRAN(l_cSql, "___HOTCODE___", sqlcnv(ALLTRIM(ho_hotcode),.T.))
*               l_cSqlPrep = STRTRAN(l_cSqlPrep, "___RESTABLE___", l_cPath + "reservat")
*               l_cSqlPrep = STRTRAN(l_cSqlPrep, "___ROOMTYPE___", l_cPath + "roomtype")
*               l_cSqlPrep = STRTRAN(l_cSqlPrep, "___RTYPEDEF___", l_cPath + "rtypedef")
*               l_cSqlUnion = l_cSqlUnion + " " + ;
*                         l_cSqlPrep + " " + ;
*                         l_cWhere + " " + ;
*                         "UNION SELECT "
*          ENDSCAN
     ENDPROC

     PROCEDURE OpenData
          LOCAL lcTablePath

          lcTablePath = FNGetMPDataPath(DLookUp("hotel", "ho_hotcode = " + SqlCnv(this.cHotCode), "ho_path"))

          OpenFileDirect(.F.,"availab",,lcTablePath)
LOCAL l_cTable, l_lSuccess, l_cTablePath, l_cTableName, l_cAlias
IF ISNULL(this.oTables)
     RETURN l_lSuccess
ENDIF

l_lSuccess = .T.
IF NOT Odbc()
     FOR EACH lcTable IN this.oTables
          lcTablePath = GETWORDNUM(lcTable, 1, ",")
          lcTableName = JUSTSTEM(lcTablePath)
          lcAlias = GETWORDNUM(lcTable, 2, ",") + lcTableName
          IF NOT OpenFileDirect(, l_cTableName, lcAlias, JUSTPATH(lcTablePath))
               l_lSuccess = .F.
               EXIT
          ENDIF
     NEXT
ENDIF

RETURN l_lSuccess
     ENDPROC

     PROCEDURE CloseData
          LOCAL l_cTablem, l_lSuccess, l_cTableName, l_cAlias, l_cTablePath

          IF ISNULL(this.oTables)
               RETURN l_lSuccess
          ENDIF

          FOR EACH l_cTable IN this.oTables
               l_cTablePath = GETWORDNUM(l_cTable, 1, ",")
               l_cTableName = JUSTSTEM(l_cTablePath)
               l_cAlias = GETWORDNUM(l_cTable, 2, ",") + l_cTableName
               DClose(l_cAlias)
          ENDFOR

          l_lSuccess = .T.

          RETURN l_lSuccess
     ENDPROC

     PROCEDURE Destroy
          this.oTables = .NULL.
     ENDPROC

     PROCEDURE GetRoomtype
          LPARAMETERS tcVirtType, tcBuilding
          RETURN DLookUp("roomtype", "rt_virroom = " + SqlCnv(PADR(tcVirtType,3)) + " AND rt_buildng = " + SqlCnv(IIF(EMPTY(tcBuilding), "", PADR(tcBuilding,3))), "rt_roomtyp")
     ENDPROC

     PROCEDURE GetInterval
          LPARAMETERS tdMinDate, tdMaxDate
          LOCAL ldMinDate, ldMaxDate

          CALCULATE MIN(av_date), MAX(av_date) ALL TO ldMinDate, ldMaxDate IN availab
          IF NOT EMPTY(ldMinDate) AND (EMPTY(tdMinDate) OR tdMinDate > ldMinDate)
               tdMinDate = ldMinDate
          ENDIF
          IF NOT EMPTY(ldMaxDate) AND (EMPTY(tdMaxDate) OR tdMaxDate < ldMaxDate)
               tdMaxDate = ldMaxDate
          ENDIF
     ENDPROC
ENDDEFINE
*
DEFINE CLASS HotelSession AS PrivateSession OF CommonClasses.prg
     cHotCode = ""
     lUseRemote = .F.
     cApplication = ""
     cPgSchema = ""
     cPrefix = ""
     cDataFolder = ""
     cServerName = ""
     nServerPort = 0
     lEncrypt = .F.
     cTables = ""
     cRemoteScript = ""
     lSilent = .F.

     PROCEDURE Init
          LPARAMETERS tcTables, tcHotCode, tcPath
          LOCAL loDatabaseProp, lcProp
          LOCAL ARRAY laMemb(1)

          this.cTables = tcTables
          IF NOT EMPTY(tcHotCode)
               this.cHotCode = ALLTRIM(tcHotCode)
               this.Name = this.Name + "_" + LOWER(this.cHotCode)
               IF goDatabases.GetKey(this.cHotCode) > 0
                    loDatabaseProp = goDatabases.Item(this.cHotCode)
                    AMEMBERS(laMemb, loDatabaseProp)
                    FOR EACH lcProp IN laMemb
                         this.&lcProp = loDatabaseProp.&lcProp
                    NEXT
                    this.lUseRemote = NOT EMPTY(this.cServerName) AND NOT EMPTY(this.nServerPort)
               ENDIF
               IF NOT EMPTY(tcPath) AND NOT this.lUseRemote
                    this.cDataFolder = FNGetMPDataPath(tcPath)
               ENDIF
          ENDIF

          IF this.lUseRemote
               SET TEXTMERGE ON TO MEMVAR this.cRemoteScript ADDITIVE NOSHOW
               this.PrivateSet()
               this.OpenData()
               SET TEXTMERGE TO
               SET TEXTMERGE OFF
          ELSE
               DO IniSetEnvironment IN ini
               this.OpenData()
               DO SetSystemPoint IN ini
          ENDIF
     ENDPROC

     PROCEDURE PrivateSet
          \puSessionOrHotcode = <<SqlCnv(this.cHotCode)>>
          \g_langnum = <<SqlCnv(g_langnum)>>
          \g_cPoint = <<SqlCnv(g_cPoint)>>
          \IF g_cPoint <> SET("Point")
          \SET POINT TO g_cPoint
          \ENDIF
          \g_SysDate = <<SqlCnv(g_SysDate)>>
          \sysdate = <<SqlCnv(sysdate)>>
          \rptbulding = <<SqlCnv(rptbulding)>>
          \title = <<SqlCnv(title)>>
          \prompt1 = <<SqlCnv(prompt1)>>
          \prompt2 = <<SqlCnv(prompt2)>>
          \prompt3 = <<SqlCnv(prompt3)>>
          \prompt4 = <<SqlCnv(prompt4)>>
          \min1 = <<SqlCnv(min1)>>
          \min2 = <<SqlCnv(min2)>>
          \min3 = <<SqlCnv(min3)>>
          \min4 = <<SqlCnv(min4)>>
          \max1 = <<SqlCnv(max1)>>
          \max2 = <<SqlCnv(max2)>>
          \max3 = <<SqlCnv(max3)>>
          \max4 = <<SqlCnv(max4)>>
     ENDPROC

     PROCEDURE OpenData
          LOCAL lnTableNo

          IF this.lUseRemote
               FOR lnTableNo = 1 TO GETWORDCOUNT(this.cTables,',')
                    \USE <<GETWORDNUM(this.cTables,lnTableNo,',')>> IN 0 SHARED
               NEXT
          ELSE
               FOR lnTableNo = 1 TO GETWORDCOUNT(this.cTables,',')
                    OpenFileDirect(,GETWORDNUM(this.cTables,lnTableNo,','),,this.cDataFolder)
               NEXT
          ENDIF
     ENDPROC
ENDDEFINE
*
DEFINE CLASS MailingSession AS MpSession
     opa = .NULL.
     cParamScript = ""
     cRemoteTable = ""

     PROCEDURE CheckData
          IF NOT DODEFAULT()
               RETURN .F.
          ENDIF
          IF NOT this.lUseRemote AND NOT USED("address")
               IF _screen.oGlobal.oMultiProper.lSwitchingHotel
                    RETURN .F.
               ENDIF
               this.OpenData()
               IF VARTYPE(this.opa)<>"O"
                    this.opa = NEWOBJECT("procaddress","libs\proc_address.vcx")
               ENDIF
          ENDIF
          RETURN .T.
     ENDPROC

     PROCEDURE OpenData
          LOCAL lcTablePath

          IF NOT this.lUseRemote
               lcTablePath = this.cDataFolder
               openfiledirect(.F.,"address",,lcTablePath)
               openfiledirect(.F.,"apartner",,lcTablePath)
               SELECT apartner
               SET ORDER TO TAG1
               openfiledirect(.F.,"astat",,lcTablePath)
               openfiledirect(.F.,"adrtoin",,lcTablePath)
               openfiledirect(.F.,"adintrst",,lcTablePath)
               openfiledirect(.F.,"document",,lcTablePath)
               openfiledirect(.F.,"histstat",,lcTablePath)
               openfiledirect(.F.,"adrtosi",,lcTablePath)
               openfiledirect(.F.,"adrstint",,lcTablePath)
               openfiledirect(.F.,"lists",,lcTablePath)
               SELECT lists
               SET ORDER TO TAG1
               openfiledirect(.F.,"roomtype",,lcTablePath)
               SELECT roomtype
               SET ORDER TO TAG1
               openfiledirect(.F.,"histres",,lcTablePath)
               SELECT histres
               SET ORDER TO TAG3
               SET RELATION TO hr_roomtyp INTO roomtype
               openfiledirect(.F.,"reservat",,lcTablePath)

               dclose("param")
               dclose("param2")
               
               openfiledirect(.F.,"param",,lcTablePath)
               openfiledirect(.F.,"param2",,lcTablePath)
          ENDIF

          RETURN .T.
     ENDPROC

     PROCEDURE CloseData
          DClose("address")
          DClose("apartner")
          DClose("astat")
          DClose("adrtoin")
          DClose("adintrst")
          DClose("document")
          DClose("histstat")
          DClose("adrtosi")
          DClose("adrstint")
          DClose("lists")
          DClose("histres")
          DClose("reservat")
          DClose("param")
          DClose("param2")
          DClose("roomtype")
          DClose("picklist")
          DClose("id")
          DClose("logger")
          DClose("building")
          DClose("room")
          DClose("rtypedef")
          DClose("resaddr")
          RETURN .T.
     ENDPROC

     PROCEDURE MFFilterData
          LPARAMETERS toForm, toProgress
          LOCAL llSuccess, lcScript, lcRemoteTable

          IF this.lUseRemote
               TEXT TO lcScript TEXTMERGE NOSHOW PRETEXT 7
               <<toForm.cParamScript>>
               Mailing(,l_cFullPath, l_oParams,,.T.)
               ENDTEXT
               lcRemoteTable = "1"
               SqlRemote("SQLPROC", lcScript, "curHotReport", this.cApplication,,@llSuccess, this.cServerName, this.nServerPort, this.lEncrypt, @lcRemoteTable)
               IF llSuccess
                    this.cRemoteTable = JUSTSTEM(lcRemoteTable)
                    IF FILE(toForm.cTmpData)
                         USE (toForm.cTmpData) IN 0 ALIAS curReport
                         SELECT curHotReport
                         SCAN
                              IF EMPTY(curHotReport.ap_apid) AND SEEK(curHotReport.ad_addrid, "curReport", "ad_addrid") AND EMPTY(curReport.ap_apid)
                                   SELECT curReport
                                   SCATTER MEMO NAME loAddress
                                   loAddress.c_cond = loAddress.c_cond AND curHotReport.c_cond
                                   loAddress.c_stayed = loAddress.c_stayed + curHotReport.c_stayed
                                   loAddress.c_nights = loAddress.c_nights + curHotReport.c_nights
                                   loAddress.c_revenue = loAddress.c_revenue + curHotReport.c_revenue
                              ELSE
                                   SCATTER MEMO NAME loAddress
                                   SELECT curReport
                                   APPEND BLANK
                              ENDIF
                              GATHER NAME loAddress MEMO
                              SELECT curHotReport
                         ENDSCAN
                         DClose("curReport")
                         DClose("curHotReport")
                         DELETE FILE (FORCEEXT(lcRemoteTable,"*"))
                    ELSE
                         DClose("curHotReport")
                         toForm.cTmpData = lcRemoteTable
                         USE (toForm.cTmpData) IN 0 ALIAS curReport EXCLUSIVE
                         SELECT curReport
                         INDEX ON ad_addrid TAG ad_addrid
                         DClose("curReport")
                    ENDIF
               ENDIF
          ELSE
               llSuccess = Mailing(toForm, toForm.cTmpData, toForm.oParams, toProgress)
          ENDIF

          RETURN llSuccess
     ENDPROC

     PROCEDURE CleanData
          IF this.lUseRemote
               SqlRemote("EXEC","DELETE FILE (poSession.cTemp+'"+this.cRemoteTable+".*')",,this.cApplication,,,this.cServerName, this.nServerPort, this.lEncrypt)
          ENDIF
     ENDPROC

     PROCEDURE MFAddApartners
          LPARAMETERS toform, tnAdId, toParams, taData
          EXTERNAL ARRAY taData
          LOCAL l_nRecNo
          IF NOT this.lUseRemote
               l_nRecNo = RECNO("address")
               IF SEEK(tnAdId,"address","TAG24")
                    MFAddApartners(toform, toParams, @taData)
               ENDIF
               GO l_nRecNo IN address
          ENDIF
          RETURN .T.
     ENDPROC

     PROCEDURE adrmainchangesget
          IF NOT this.lUseRemote
               this.opa.adrmainchangesget()
          ENDIF
          RETURN .T.
     ENDPROC

     PROCEDURE ExecCmd
          LPARAMETERS tcCmd
          LOCAL l_uRetVal
          l_uRetVal = &tcCmd
          RETURN l_uRetVal
     ENDPROC

     PROCEDURE MFInsertIntoDocument
          LPARAMETERS toForm, tcText, tdSysDate, tcTime, tcUserId
          LOCAL llSuccess, lcScript

          IF this.lUseRemote
               IF NOT EMPTY(this.cRemoteTable)
                    TEXT TO lcScript TEXTMERGE NOSHOW PRETEXT 7
                    USE (poSession.cTemp+'<<this.cRemoteTable>>.dbf') IN 0 ALIAS curReport SHARED
                    DO MFInsertIntoDocument IN Mailing WITH '<<tcText>>', <<SqlCnv(tdSysDate)>>, '<<tcTime>>', '<<tcUserId>>', .T.
                    ENDTEXT
                    SqlRemote("EXEC",lcScript,,this.cApplication,,@llSuccess, this.cServerName, this.nServerPort, this.lEncrypt)
               ENDIF
          ELSE
               IF NOT USED("curReport") AND FILE(toForm.cTmpData)
                    USE (toForm.cTmpData) IN 0 ALIAS curReport SHARED
               ENDIF
               DO MFInsertIntoDocument IN Mailing WITH tcText, tdSysDate, tcTime, tcUserId, .T.
               llSuccess = .T.
          ENDIF

          RETURN llSuccess
     ENDPROC

     PROCEDURE MFCloseCurReport
          LPARAMETERS tlCloseDatabase, tcDBC
          LOCAL l_lErr
          dclose("curreport")
          IF tlCloseDatabase
               l_lErr = .F.
               TRY
                    SET DATABASE TO (tcDBC)
               CATCH
                    l_lErr = .T.
               ENDTRY
               IF NOT l_lErr
                    CLOSE DATABASES
               ENDIF
          ENDIF
          RETURN .T.
     ENDPROC
ENDDEFINE
*