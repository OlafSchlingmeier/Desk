#INCLUDE "include\constdefines.h"
*
FUNCTION GetReservatName
LPARAMETERS lcReservatAlias, lcAddressAlias, lcApartnerAlias, llHistory
LOCAL lcReturnValue

IF PCOUNT() = 0
     lcReservatAlias = "reservat"
     lcAddressAlias = "address"
     lcApartnerAlias = "apartner"
ENDIF

lcReturnValue = ""
IF llHistory
     DO CASE
          CASE &lcReservatAlias..hr_addrid = &lcReservatAlias..hr_compid AND &lcReservatAlias..hr_noaddr
               lcReturnValue = TRIM(&lcReservatAlias..hr_lname)+', '+TRIM(&lcReservatAlias..hr_fname)
          CASE &lcReservatAlias..hr_addrid = &lcReservatAlias..hr_compid AND NOT EMPTY(&lcReservatAlias..hr_apname)
               lcReturnValue = TRIM(NVL(&lcApartnerAlias..ap_lname,""))+', '+TRIM(NVL(&lcApartnerAlias..ap_fname,""))
          CASE AT('/', &lcAddressAlias..ad_lname)>0
               lcReturnValue = TRIM(NVL(&lcAddressAlias..ad_lname,""))
          OTHERWISE
               lcReturnValue = TRIM(NVL(&lcAddressAlias..ad_lname,""))+', '+TRIM(NVL(&lcAddressAlias..ad_fname,""))
     ENDCASE

     IF NOT EMPTY(hresext.rs_sname)
          lcReturnValue = lcReturnValue + '/'+TRIM(PROPER(hresext.rs_sname))
     ENDIF
ELSE
     DO CASE
          CASE &lcReservatAlias..rs_addrid = &lcReservatAlias..rs_compid AND &lcReservatAlias..rs_noaddr
               lcReturnValue = IIF(&lcReservatAlias..rs_addrid = _screen.oglobal.oparam2.pa_defadri,"!","")+TRIM(&lcReservatAlias..rs_lname)+', '+TRIM(&lcReservatAlias..rs_fname)
          CASE &lcReservatAlias..rs_addrid = &lcReservatAlias..rs_compid AND NOT EMPTY(&lcReservatAlias..rs_apname)
               lcReturnValue = TRIM(NVL(&lcApartnerAlias..ap_lname,""))+', '+TRIM(NVL(&lcApartnerAlias..ap_fname,""))
          CASE AT('/', &lcAddressAlias..ad_lname)>0
               lcReturnValue = TRIM(NVL(&lcAddressAlias..ad_lname,""))
          OTHERWISE
               lcReturnValue = TRIM(NVL(&lcAddressAlias..ad_lname,""))+', '+TRIM(NVL(&lcAddressAlias..ad_fname,""))
     ENDCASE

     IF NOT EMPTY(&lcReservatAlias..rs_sname)
          lcReturnValue = lcReturnValue + '/'+TRIM(PROPER(&lcReservatAlias..rs_sname))
     ENDIF
ENDIF
RETURN lcReturnValue
ENDFUNC
*
FUNCTION GetReservatLongName
LPARAMETERS lcReservatAlias, lcAddressAlias, lcApartnerAlias, lnRsId, cCursorName
LOCAL lcReturnValue, lnSelect, lcSql, lcCur

IF PCOUNT() = 0
     lcReservatAlias = "reservat"
     lcAddressAlias = "address"
     lcApartnerAlias = "apartner"
ELSE
     IF NOT EMPTY(lnRsId)
          lnSelect = SELECT()
          TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 2 + 8
          SELECT rs_addrid, rs_compid, rs_noaddr, rs_title, rs_fname, rs_lname, rs_apname, ;
               NVL(a1.ad_title,'') AS ad_title, NVL(a1.ad_lname,'') AS ad_lname, NVL(a1.ad_fname,'') AS ad_fname, ;
               NVL(a2.ad_company,'') AS ad_company, ;
               NVL(ap1.ap_title,'') AS ap_title, NVL(ap1.ap_lname,'') AS ap_lname, NVL(ap1.ap_fname,'') AS ap_fname ;
               FROM reservat ;
               LEFT JOIN address a1 ON rs_addrid = a1.ad_addrid ;
               LEFT JOIN address a2 ON rs_compid = a2.ad_addrid ;
               LEFT JOIN apartner ap1 ON rs_apid = ap1.ap_apid ;
               WHERE rs_rsid = <<lnRsId>> 
          ENDTEXT
          lcCur = sqlcursor(lcSql,,,,,.T.)
          STORE lcCur TO lcReservatAlias, lcAddressAlias, lcApartnerAlias
     ENDIF
ENDIF
lcReturnValue = ""
DO CASE
     CASE &lcReservatAlias..rs_addrid = &lcReservatAlias..rs_compid AND &lcReservatAlias..rs_noaddr
          lcReturnValue = ALLTRIM(&lcReservatAlias..rs_title)+" "+ALLTRIM(&lcReservatAlias..rs_fname)+" "+flIp(ALLTRIM(&lcReservatAlias..rs_lname))
     CASE &lcReservatAlias..rs_addrid = &lcReservatAlias..rs_compid AND NOT EMPTY(&lcReservatAlias..rs_apname)
          lcReturnValue = ALLTRIM(NVL(&lcApartnerAlias..ap_title,""))+" "+ALLTRIM(NVL(&lcApartnerAlias..ap_fname,""))+" "+Flip(ALLTRIM(NVL(&lcApartnerAlias..ap_lname,"")))
     OTHERWISE
          lcReturnValue = ALLTRIM(NVL(&lcAddressAlias..ad_title,""))+" "+ALLTRIM(NVL(&lcAddressAlias..ad_fname,""))+" "+Flip(ALLTRIM(NVL(&lcAddressAlias..ad_lname,"")))
ENDCASE
IF NOT EMPTY(lnRsId)
     IF VARTYPE(cCursorName)="C"
          cCursorName = lcCur && Send cursor name through reference variable back, don't close it
     ELSE
          dclose(lcCur)
     ENDIF
     IF VARTYPE(lnSelect)="N"
          SELECT (lnSelect)
     ENDIF
ENDIF
RETURN lcReturnValue
ENDFUNC
*
FUNCTION GetAddressName
LPARAMETERS tcLname, tcFname, tcTitle

RETURN IIF(EMPTY(tcTitle),'',ALLTRIM(tcTitle)+' ') + IIF(EMPTY(tcFname),'',ALLTRIM(tcFname)+' ')+IIF(EMPTY(tcLname),'',tcLname)
ENDFUNC
*
FUNCTION GetReservatCaption
LPARAMETERS tvReservatAlias
LOCAL lcReturnValue
IF PCOUNT() = 0
     tvReservatAlias = "reservat"
ENDIF
IF VARTYPE(tvReservatAlias) = "O"
     lcReturnValue = IIF(EMPTY(tvReservatAlias.rs_lname),tvReservatAlias.rs_company,tvReservatAlias.rs_lname)
ELSE
     lcReturnValue = IIF(EMPTY(&tvReservatAlias..rs_lname),&tvReservatAlias..rs_company,&tvReservatAlias..rs_lname)
ENDIF

RETURN lcReturnValue
ENDFUNC
*
FUNCTION MakeProperName
 PARAMETERS _pc
 LOCAL _a, _s
 _pc = PROPER(_pc)
 _a = AT("-", _pc, 1)
 _s = SUBSTR(_pc, _a+1,1)
 IF _s == " "
      _a = _a+1
      _s = SUBSTR(_pc, _a+1,1)
 ENDIF
 IF EMPTY(_s)
      _s = ""
 ENDIF
 _t = ALLTRIM(STUFF(_pc, _a+1, 1, UPPER(_s)))
 RETURN _t
ENDFUNC
*
FUNCTION NoUserRights
 PARAMETER cmEnupad, nmEnubar
 PRIVATE cmAcro
 PRIVATE crIghts
 PRIVATE lhAsnorights
 lhAsnorights = .T.
 IF NOT ISNULL(_screen.oGlobal.oGroup)
      cmAcro = "_screen.oGlobal.oGroup.Gr_"+cmEnupad
      cRights      = &cMacro
      IF (SUBSTR(crIghts, nmEnubar, 1)=="1")
           lhAsnorights = .F.
      ENDIF
 ENDIF
 RETURN lhAsnorights
ENDFUNC
*
FUNCTION Button
 PARAMETER clEvel, cbUttontext, nnUmber, laNylength
 PRIVATE cmAcro
 PRIVATE crIghts
 IF (PCOUNT()<4)
      laNylength = .F.
 ENDIF
 DO CASE
      CASE EMPTY(clEvel)
           crIghts = REPLICATE("1", 16)
      CASE clEvel=="-"
           crIghts = REPLICATE("0", 16)
      OTHERWISE
           cmAcro = "Group.Gr_But"+clEvel
           cRights        = &cMacro
 ENDCASE
 cnEwbuttontext = cbUttontext
 IF ( .NOT. laNylength)
      ntMplength = IIF(g_Nscreenmode==1, 11, 14)
      DO WHILE (TXTWIDTH(STRTRAN(STRTRAN(cnEwbuttontext, "\<", ""), "\\",  ;
         ""), "Arial", 10, "B")>ntMplength)
           cnEwbuttontext = SUBSTR(cnEwbuttontext, 1, LEN(cnEwbuttontext)-1)
      ENDDO
 ENDIF
 IF (nnUmber<0)
      ncHecknumber = nnUmber*-1
 ELSE
      ncHecknumber = nnUmber
 ENDIF
 IF (SUBSTR(crIghts, ncHecknumber, 1)<>"1")
      cnEwbuttontext = "\\"+cnEwbuttontext
 ENDIF
 IF (nnUmber>0)
      cnEwbuttontext = cnEwbuttontext+";"
 ENDIF
 RETURN cnEwbuttontext
ENDFUNC
*
FUNCTION RepoText
 PARAMETER cpRogramname, ctXtlabel
 PRIVATE caSsignedtext
 PRIVATE ncUrrentarea
 PRIVATE clAbel
 PRIVATE cpRg
 PRIVATE ctExt
 ncUrrentarea = SELECT()
 caSsignedtext = ctXtlabel
 IF (USED("RepText"))
      SELECT rePtext
      IF (TYPE("g_RptLng")<>"C")
           g_Rptlng = "ENG"
      ENDIF
      LOCATE FOR rePtext.la_lang==g_Rptlng .AND.  ;
             ALLTRIM(UPPER(rePtext.la_label))==ctXtlabel
      IF ( .NOT. FOUND())
           LOCATE FOR rePtext.la_lang=="ENG" .AND.  ;
                  ALLTRIM(UPPER(rePtext.la_label))==ctXtlabel
      ENDIF
      caSsignedtext = ALLTRIM(rePtext.la_text)
 ENDIF
 SELECT (ncUrrentarea)
 IF (EMPTY(caSsignedtext))
      caSsignedtext = ctXtlabel
 ENDIF
 RETURN caSsignedtext
ENDFUNC
*
FUNCTION Flip
 PARAMETER ctExt
 PRIVATE cfLippedtext
 PRIVATE npOsition
 npOsition = AT(",", ctExt)
 IF (npOsition>0)
      IF npOsition<LEN(ctExt)
           cfLippedtext = ALLTRIM(SUBSTR(ctExt, npOsition+1))+" "+ ;
                          ALLTRIM(SUBSTR(ctExt, 1, npOsition-1))
      ELSE
           cfLippedtext = ALLTRIM(SUBSTR(ctExt, 1, npOsition-1))
      ENDIF
 ELSE
      cfLippedtext = ctExt
 ENDIF
 RETURN cfLippedtext
ENDFUNC
*
PROCEDURE UpdateRecord
LPARAMETERS tcAlias, toRecord
LOCAL i, lcField

FOR i = 1 TO AFIELDS(laFields,tcAlias)
     lcField = laFields(i,1)
     DO CASE
          CASE TYPE("toRecord."+lcField) = "U"
          CASE TYPE("toRecord."+lcField) = "C"
               IF &tcAlias..&lcField <> PADR(toRecord.&lcField,laFields(i,3))
                    REPLACE &lcField WITH toRecord.&lcField IN &tcAlias
               ENDIF
          OTHERWISE
               IF &tcAlias..&lcField <> toRecord.&lcField
                    REPLACE &lcField WITH toRecord.&lcField IN &tcAlias
               ENDIF
     ENDCASE
NEXT
ENDPROC
*
PROCEDURE LinkRoomtype
LPARAMETERS lp_cRoomnum, lp_cRoomtype, lp_aRoomtype
LOCAL i, l_nArea, l_cCurRoom, l_nRooms, l_nLines
LOCAL ARRAY l_aLinkDetails(1)

l_nArea = SELECT()

IF EMPTY(lp_cRoomnum)
     l_cCurRoom = SqlCursor("SELECT rt_roomtyp, rt_group FROM roomtype WHERE rt_roomtyp = " + SqlCnv(lp_cRoomtype,.T.))
ELSE
     l_cCurRoom = SqlCursor("SELECT rm_link, rt_roomtyp, rt_group FROM room INNER JOIN roomtype ON rt_roomtyp = rm_roomtyp WHERE rm_roomnum = " + SqlCnv(lp_cRoomnum,.T.))
ENDIF
l_nRooms = 1
DIMENSION lp_aRoomtype[l_nRooms,5]
lp_aRoomtype[l_nRooms,1] = &l_cCurRoom..rt_roomtyp
lp_aRoomtype[l_nRooms,2] = 1
lp_aRoomtype[l_nRooms,3] = &l_cCurRoom..rt_group
lp_aRoomtype[l_nRooms,4] = lp_cRoomnum
lp_aRoomtype[l_nRooms,5] = .F.
IF NOT EMPTY(lp_cRoomnum) AND NOT EMPTY(STRTRAN(&l_cCurRoom..rm_link,","))
     l_nLines = ALINES(l_aLinkDetails, Get_rm_rmname(lp_cRoomnum, "rm_linkdt"))
     DIMENSION lp_aRoomtype[l_nRooms+l_nLines,5]
     FOR i = 1 TO l_nLines
          l_nRooms = l_nRooms + 1
          lp_aRoomtype[l_nRooms,1] = GETWORDNUM(l_aLinkDetails(i),1,";")
          lp_aRoomtype[l_nRooms,2] = VAL(GETWORDNUM(l_aLinkDetails(i),2,";"))
          lp_aRoomtype[l_nRooms,3] = INT(VAL(GETWORDNUM(l_aLinkDetails(i),3,";")))
          lp_aRoomtype[l_nRooms,4] = GETWORDNUM(l_aLinkDetails(i),4,";")
          lp_aRoomtype[l_nRooms,5] = .T.
     ENDFOR
ENDIF
DClose(l_cCurRoom)

SELECT(l_nArea)

RETURN l_nRooms
ENDPROC
*
FUNCTION Alert
 PARAMETER ctExt, chEader
 PRIVATE nmBreturn
 nmBreturn = 0
 IF g_lAutomationMode OR _screen.oGlobal.lDoAuditOnStartup
      _screen.oGlobal.MsgAdd(ctExt)
 ELSE
      IF (PCOUNT()==1)
           chEader = GetLangText("FUNC","TXT_MESSAGE")
      ENDIF
      ctExt = STRTRAN(ctExt, ";", (CHR(13)+CHR(10)))
      nmBreturn = msGbox(ctExt,chEader,048)
 ENDIF
 RETURN nmBreturn
ENDFUNC
*
FUNCTION OkCancel
 PARAMETER ctExt, chEader
 PRIVATE loKay
 IF (PCOUNT()==1)
      chEader = GetLangText("FUNC","TXT_QUESTION")
 ENDIF
 loKay = (msGbox(ctExt,chEader,1+icOnquestion)==1)
 RETURN loKay
ENDFUNC
*
FUNCTION OkCancel
 PARAMETER ctExt, chEader
 PRIVATE nrEturn
 IF (PCOUNT()==1)
      chEader = GetLangText("FUNC","TXT_QUESTION")
 ENDIF
 nrEturn = (msGbox(ctExt,chEader,2+icOnquestion)-3)
 RETURN nrEturn
ENDFUNC
*
PROCEDURE YesNoCancel
LPARAMETERS ctExt, chEader
 IF (PCOUNT()==1)
      chEader = GetLangText("FUNC","TXT_QUESTION")
 ENDIF
 ctExt = STRTRAN(ctExt, ";", CRLF)
 RETURN MsgBox(ctExt, chEader, 35)
ENDFUNC
*
FUNCTION ButText
 PARAMETER cbUttons, nsElected
 PRIVATE ctExt
 PRIVATE npOs
 PRIVATE nnUmber
 nnUmber = 0
 cbUttons = cbUttons+";"
 npOs = AT(";", cbUttons)
 DO WHILE (npOs>0)
      nnUmber = nnUmber+1
      ctExt = STRTRAN(SUBSTR(cbUttons, 1, npOs-1), "\<", "")
      IF (nnUmber==nsElected)
           EXIT
      ENDIF
      cbUttons = SUBSTR(cbUttons, npOs+1)
      npOs = AT(";", cbUttons)
 ENDDO
 RETURN ctExt
ENDFUNC
*
FUNCTION CheckBoxMessage
 PARAMETER ctItle, alChecks, acChecks
 EXTERNAL ARRAY acChecks
 EXTERNAL ARRAY alChecks
 PRIVATE ncHecks
 PRIVATE nsElectedbutton
 PRIVATE ncOunt
 PRIVATE nbUtton
 nbUtton = 0
 ncHecks = ALEN(acChecks)
 DEFINE WINDOW wcHkmessage FROM 0, 0 TO 5.5+((ncHecks+1)*1.25), 50 FONT  ;
        "Arial", 10 NOCLOSE NOZOOM TITLE ctItle IN scReen NOMDI DOUBLE
 MOVE WINDOW wcHkmessage CENTER
 ACTIVATE WINDOW wcHkmessage
 = paNelborder()
 FOR ncOunt = 1 TO ncHecks
      @ ncOunt*1.25, 2 GET alChecks[ncOunt] FUNCTION "*C" PICTURE  ;
        acChecks(ncOunt)
 ENDFOR
 @ WROWS()-2, 2 GET nbUtton STYLE "B" SIZE nbUttonheight, 15 FUNCTION "*"+ ;
   "H" PICTURE GetLangText("COMMON","TXT_OK")+";"+GetLangText("COMMON","TXT_CANCEL")
 READ CYCLE MODAL
 DEACTIVATE WINDOW wcHkmessage
 RETURN (nbUtton==1)
ENDFUNC
*
FUNCTION Panel
 PARAMETER ntOp, nlEft, nbOttom, nrIght, ntYpe, ctItle
 PRIVATE npArameters
 npArameters = PCOUNT()
 IF (npArameters<5)
      ntYpe = 1
 ENDIF
 IF (ntYpe==1)
      @ ntOp, nlEft TO ntOp, nrIght PEN 0 COLOR RGB(128,128,128,192,192,192)
      @ ntOp, nlEft TO nbOttom, nlEft PEN 0 COLOR RGB(128,128,128,192,192,192)
      @ nbOttom, nlEft TO nbOttom, nrIght+1/FONTMETRIC(6) PEN 0 COLOR  ;
        RGB(255,255,255,192,192,192)
      @ ntOp, nrIght TO nbOttom, nrIght PEN 0 COLOR RGB(255,255,255,192, ;
        192,192)
 ELSE
      @ ntOp, nlEft TO ntOp, nrIght PEN 0 COLOR RGB(255,255,255,192,192,192)
      @ ntOp, nlEft TO nbOttom, nlEft PEN 0 COLOR RGB(255,255,255,192,192,192)
      @ nbOttom, nlEft TO nbOttom, nrIght+1/FONTMETRIC(6) PEN 0 COLOR  ;
        RGB(128,128,128,192,192,192)
      @ ntOp, nrIght TO nbOttom, nrIght PEN 0 COLOR RGB(128,128,128,192, ;
        192,192)
 ENDIF
 IF (npArameters==6)
      @ ntOp-0.5, nlEft+2 SAY ctItle STYLE "I"
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION Relations
 PRIVATE laLlset
 laLlset = .T.
 IF (USED("Reservat") .AND. USED("Address") .AND. USED("Company") .AND.  ;
    USED("Agent")) .AND. USED("Apartner")
      SELECT reServat
*      SET ORDER TO 3 IN Apartner
      SET RELATION TO rs_addrid INTO adDress
      SET RELATION ADDITIVE TO rs_compid INTO coMpany
      SET RELATION ADDITIVE TO rs_agentid INTO agEnt
*      SET RELATION ADDITIVE TO rs_apid INTO Apartner
      GOTO TOP
 *     SELECT address
  *    SET ORDER TO 1 IN Apaddr
   *   SET RELATION TO Ad_Addrid INTO Apaddr
     *  GOTO TOP
     * SELECT reServat
 ELSE
      laLlset = .F.
 ENDIF
 RETURN laLlset
ENDFUNC
*
FUNCTION MyCDoW
 PARAMETER ndAy
 PRIVATE cdAyintext
 cdAyintext = ""
 ndAy = IIF(TYPE("nDay")=="D", DOW(ndAy), ndAy)
 DO CASE
      CASE ndAy==1
           cdAyintext = GetLangText("FUNC","TXT_SUNDAY")
      CASE ndAy==2
           cdAyintext = GetLangText("FUNC","TXT_MONDAY")
      CASE ndAy==3
           cdAyintext = GetLangText("FUNC","TXT_TUESDAY")
      CASE ndAy==4
           cdAyintext = GetLangText("FUNC","TXT_WEDNESDAY")
      CASE ndAy==5
           cdAyintext = GetLangText("FUNC","TXT_THURSDAY")
      CASE ndAy==6
           cdAyintext = GetLangText("FUNC","TXT_FRIDAY")
      CASE ndAy==7
           cdAyintext = GetLangText("FUNC","TXT_SATURDAY")
 ENDCASE
 RETURN PROPER(cdAyintext)
ENDFUNC
*
PROCEDURE LogData
 LPARAMETER ctExt, cfIlename
 LOCAL nhAndle
 cfIlename = _screen.oGlobal.choteldir + cfIlename
 IF ( .NOT. FILE(cfIlename))
      nhAndle = FCREATE(cfIlename, 0)
 ELSE
      nhAndle = FOPEN(cfIlename, 2)
 ENDIF
 IF (nhAndle<>-1)
      = FSEEK(nhAndle, 0, 2)
      = FPUTS(nhAndle, ctExt)
      = FCLOSE(nhAndle)
 ELSE
      WAIT WINDOW TIMEOUT 1 "Open error on logfile"
 ENDIF
 RETURN .T.
ENDPROC
*
FUNCTION MyCMonth
 PARAMETER nmOnth, lfLag
 PRIVATE nmOnthintext
 IF (PCOUNT()==1)
      lfLag = .F.
 ENDIF
 nmOnthintext = ""
 nmOnth = IIF(TYPE("nMonth")=="D", MONTH(nmOnth), nmOnth)
 DO CASE
      CASE nmOnth==1
           nmOnthintext = GetLangText("FUNC","TXT_JANUARY")
      CASE nmOnth==2
           nmOnthintext = GetLangText("FUNC","TXT_FEBRUARY")
      CASE nmOnth==3
           nmOnthintext = GetLangText("FUNC","TXT_MARCH")
      CASE nmOnth==4
           nmOnthintext = GetLangText("FUNC","TXT_APRIL")
      CASE nmOnth==5
           nmOnthintext = GetLangText("FUNC","TXT_MAY")
      CASE nmOnth==6
           nmOnthintext = GetLangText("FUNC","TXT_JUNE")
      CASE nmOnth==7
           nmOnthintext = GetLangText("FUNC","TXT_JULY")
      CASE nmOnth==8
           nmOnthintext = GetLangText("FUNC","TXT_AUGUST")
      CASE nmOnth==9
           nmOnthintext = GetLangText("FUNC","TXT_SEPTEMBER")
      CASE nmOnth==10
           nmOnthintext = GetLangText("FUNC","TXT_OCTOBER")
      CASE nmOnth==11
           nmOnthintext = GetLangText("FUNC","TXT_NOVEMBER")
      CASE nmOnth==12
           nmOnthintext = GetLangText("FUNC","TXT_DECEMBER")
 ENDCASE
 IF ( .NOT. lfLag)
      nmOnthintext = STRTRAN(nmOnthintext, "\<", "")
 ENDIF
 RETURN nmOnthintext
ENDFUNC
*
FUNCTION Picklist
 PARAMETER clAbel, cvAriable, nrOw, ncOlumn, ctYpe, cpArentwindow, laLlowempty
 PRIVATE acPlfields
 PRIVATE npLcurrentarea
 PRIVATE lsElectok
 IF LASTKEY()==27
      RETURN .T.
 ENDIF
 DIMENSION acPlfields[2, 2]
 IF (PCOUNT()<7)
      laLlowempty = .F.
 ENDIF
 npLcurrentarea = SELECT()
 lsElectok = .F.
 IF (laLlowempty .AND. EMPTY(cvAriable))
      lsElectok = .T.
 ELSE
      IF (ctYpe="C")
           SET ORDER IN piCklist TO 4
           IF (EMPTY(cvAriable) .OR.  .NOT. SEEK(PADR(clAbel, 10)+ ;
              PADR(UPPER(ALLTRIM(cvAriable)), 3), "PickList"))
                acPlfields[1, 1] = "Pl_CharCod"
                acPlfields[1, 2] = 6
                acPlfields[2, 1] = "Trim(Pl_Lang"+g_Langnum+")"
                acPlfields[2, 2] = 20
                SELECT piCklist
                SET ORDER TO 2
                = SEEK(PADR(clAbel, 10), "PickList")
                IF (myPopup(cpArentwindow,nrOw+1,ncOlumn,5,@acPlfields, ;
                   ".t.",'pl_label = "'+clAbel+'"')>0)
                     cvAriable = piCklist.pl_charcod
                     lsElectok = .T.
                ENDIF
           ELSE
                cvAriable = piCklist.pl_charcod
                lsElectok = .T.
           ENDIF
      ELSE
           SET ORDER IN piCklist TO 3
           IF (EMPTY(cvAriable) .OR.  .NOT. SEEK(PADR(clAbel, 10)+ ;
              STR(cvAriable, 3), 'PickList'))
                acPlfields[1, 1] = "Pl_NumCod"
                acPlfields[1, 2] = 6
                acPlfields[2, 1] = "Trim(pl_lang"+g_Langnum+")"
                acPlfields[2, 2] = 20
                SELECT piCklist
                = SEEK(PADR(clAbel, 10), "PickList")
                IF (myPopup(cpArentwindow,nrOw+1,ncOlumn,5,@acPlfields, ;
                   ".t.",'pl_label = "'+clAbel+'"')>0)
                     cvAriable = piCklist.pl_numcod
                     lsElectok = .T.
                ENDIF
           ELSE
                cvAriable = piCklist.pl_numcod
                lsElectok = .T.
           ENDIF
      ENDIF
      SET ORDER IN piCklist TO 1
      SELECT (npLcurrentarea)
 ENDIF
 RETURN lsElectok
ENDFUNC
*
FUNCTION Up
 PRIVATE nlAstkey
 nlAstkey = LASTKEY()
 RETURN (nlAstkey==5 .OR. nlAstkey==19 .OR. nlAstkey=15)
ENDFUNC
*
FUNCTION aGetRow
 PARAMETER cvAriable
 PRIVATE nsTart
 PRIVATE neNd
 PRIVATE nrOw
 IF (PCOUNT()==0)
      cvAriable = VARREAD()
 ENDIF
 nsTart = AT("(", cvAriable)
 neNd = AT(",", cvAriable)
 IF neNd=0
      neNd = AT(")", cvAriable)
 ENDIF
 nrOw = VAL(SUBSTR(cvAriable, nsTart+1, neNd-nsTart))
 IF TYPE('nRow')<>'N' .OR.  .NOT. BETWEEN(nrOw, 1, 9)
      nrOw = 1
 ENDIF
 RETURN nrOw
ENDFUNC
*
FUNCTION aGetCol
 PARAMETER cvAriable
 PRIVATE nsTart
 PRIVATE neNd
 IF (PCOUNT()==0)
      cvAriable = VARREAD()
 ENDIF
 nsTart = AT(",", cvAriable)
 neNd = AT(")", cvAriable)
 ncOlumn = VAL(SUBSTR(cvAriable, nsTart+1, neNd-nsTart))
 RETURN ncOlumn
ENDFUNC
*
FUNCTION DbLookup
 PARAMETER caLias, ctAg, csEekexpression, crEturnexpression, lkEeprec, lNotInGlobal
 PRIVATE lcLosealias

 IF NOT USED(caLias) AND NOT lNotInGlobal
      RETURN _screen.oGlobal.oGData.DbLookup(caLias, ctAg, csEekexpression, crEturnexpression, lkEeprec)
 ENDIF

 lcLosealias = .F.
 IF PCOUNT()<5
      lkEeprec = .F.
 ENDIF
 PRIVATE clOokuparea
 PRIVATE nlOokuporder
 PRIVATE nlOokuprecord
 PRIVATE crEturn
 clOokuparea = SELECT()
 IF ( .NOT. USED(caLias))
      lcLosealias = .T.
      = opEnfile(.F.,caLias)
 ENDIF
 nlOokuporder = ORDER(caLias)
 nlOokuprecord = RECNO(caLias)
 SELECT (caLias)
 SET ORDER IN (caLias) TO (ctAg)
 = SEEK(csEekexpression, caLias)
 crEturn = EVALUATE(crEturnexpression)
 IF NOT lkEeprec
      IF nlookuprecord > RECCOUNT()
           GO BOTTOM
           IF NOT EOF()
                SKIP
           ENDIF
      ELSE
           GOTO nlOokuprecord IN (caLias)
     ENDIF
 ENDIF
 SET ORDER IN (caLias) TO nLookUpOrder
 SELECT (clOokuparea)
 IF (lcLosealias)
      = clOsefile(caLias)
 ENDIF
 RETURN crEturn
ENDFUNC
*
FUNCTION DLangLookup
 LPARAMETER tcAlias, tcWhere, tcLangField, tcLangnum
 LOCAL lcDescrip, lcLangNum

 lcDescrip = DLookUp(tcAlias, tcWhere, tcLangField + tcLangnum)
 IF EMPTY(lcDescrip)
      lcLangNum = TRANSFORM(DLookUp("picklist", "pl_label = [LANGUAGE] AND pl_charcod = " + SqlCnv(param.pa_lang), "pl_numval"))
      lcDescrip = DLookUp(tcAlias, tcWhere, tcLangField + lcLangNum)
 ENDIF

 RETURN lcDescrip
ENDFUNC
*
FUNCTION DemoMax
 PARAMETER caLias
 PRIVATE lrEturn
 PRIVATE nmAxrecords
 lrEturn = .F.
 nmAxrecords = IIF(caLias=="Post", 150, 50)
 IF (g_Demo .AND. RECCOUNT(caLias)>nmAxrecords)
      = msGbox(GetLangText("FUNC","TXT_MAXRECORDSREACHED")+"!",GetLangText("FUNC", ;
        "TXT_BRILLIANTERROR"),16)
      lrEturn = .T.
 ENDIF
 RETURN lrEturn
ENDFUNC
*
FUNCTION Balance
LPARAMETER lp_nReserid, lp_nWindow, lp_dSysdate
LOCAL l_nRetval, l_nArea, l_nRecno, l_cOrder, l_cExpression, l_cWhere, l_nWinBal
LOCAL ARRAY l_aWinBal(1)

l_nArea = SELECT()

l_nRetval = 0
IF EMPTY(lp_nWindow)
     lp_nWindow = 0
ENDIF

IF Odbc()
     l_aWinBal(1) = .T.
     SqlCursor(Str2Msg("SELECT * FROM res_pl_balance(%s1,%s2)","%s",SqlCnv(lp_nReserid,.T.),SqlCnv(lp_nWindow,.T.)),,,,,,@l_aWinBal)
     l_nRetval = RoundForDisplay(l_aWinBal(1))
ELSE
     IF _screen.oGlobal.oparam.pa_exclvat
          l_cExpression = "ps_amount + ps_vat1 + ps_vat2 + ps_vat3 + ps_vat4 + ps_vat5 + ps_vat6 + ps_vat7 + ps_vat8 + ps_vat9"
     ELSE
          l_cExpression = "ps_amount"
     ENDIF

     IF EMPTY(lp_dSysdate)
          l_cWhere = "ps_reserid = lp_nReserid AND NOT ps_split AND NOT ps_cancel"
     ELSE
          l_cWhere = "ps_reserid = lp_nReserid AND ps_date <= lp_dSysdate AND NOT ps_split AND NOT ps_cancel"
     ENDIF

     IF EMPTY(lp_nWindow)
          SELECT ps_window, SUM(&l_cExpression) FROM post WHERE &l_cWhere GROUP BY ps_window INTO ARRAY l_aWinBal
          IF ALEN(l_aWinBal) > 1
               FOR l_nWinBal = 1 TO ALEN(l_aWinBal,1)
                    l_nRetval = l_nRetval + RoundForDisplay(l_aWinBal(l_nWinBal,2))
               NEXT
          ENDIF
     ELSE
          SELECT post
          l_nRecno = RECNO()
          l_cOrder = ORDER()
          SET ORDER TO
          SUM &l_cExpression FOR &l_cWhere AND ps_window = lp_nWindow TO l_nRetval
          l_nRetval = RoundForDisplay(l_nRetval)
          SET ORDER TO l_cOrder
          GOTO l_nRecno
     ENDIF
ENDIF

SELECT (l_nArea)

RETURN l_nRetval
ENDFUNC
*
FUNCTION RoundForDisplay
LPARAMETERS lp_nAmount
LOCAL l_nRetVal
IF ABS(lp_nAmount) < 0.01
     l_nRetVal = 0.00
ELSE
     l_nRetVal = ROUND(lp_nAmount, _screen.oglobal.oparam.pa_currdec)
ENDIF
RETURN l_nRetVal
ENDFUNC
*
FUNCTION VATBalance
LPARAMETER lp_nReserId, lp_nWindow, lp_nVat0, lp_nVat1, lp_nVat2, lp_nVat3, ;
     lp_nVat4, lp_nVat5, lp_nVat6, lp_nVat7, lp_nVat8, lp_nVat9
LOCAL l_nRetval, l_nArea, l_nRecno, l_cOrder

STORE 0 TO l_nRetval, lp_nVat0, lp_nVat1, lp_nVat2, lp_nVat3, ;
     lp_nVat4, lp_nVat5, lp_nVat6, lp_nVat7, lp_nVat8, lp_nVat9

l_nArea = SELECT()

SELECT post
l_nRecno = RECNO()
l_cOrder = ORDER()
SET ORDER TO
SUM ps_amount, ps_vat0, ps_vat1, ps_vat2, ps_vat3, ps_vat4, ;
     ps_vat5, ps_vat6, ps_vat7, ps_vat8, ps_vat9 ;
     TO l_nRetval, lp_nVat0, lp_nVat1, lp_nVat2,  lp_nVat3, lp_nVat4, ;
     lp_nVat5, lp_nVat6, lp_nVat7, lp_nVat8, lp_nVat9 ;
     FOR ps_reserid = lp_nReserId AND NOT ps_split AND NOT ps_cancel AND ps_window = lp_nWindow
SET ORDER TO l_cOrder
GOTO l_nRecno

SELECT (l_nArea)

RETURN l_nRetval + lp_nVat1 + lp_nVat2 + lp_nVat3 + lp_nVat4 + lp_nVat5 + lp_nVat6 + lp_nVat7 + lp_nVat8 + lp_nVat9
ENDFUNC
*
FUNCTION CheckLayout
 PARAMETER p_Frx, pcTmpfrx, pcTmpfrt
 PRIVATE ALL LIKE l_*
 PRIVATE nt1, nl1, nh1, nw1, nrEc
 PRIVATE coRgfrx, coRgfrt
 l_Retval = .T.
 l_Oldarea = SELECT()
 coRgfrx = UPPER(p_Frx)
 IF RIGHT(coRgfrx, 4)<>'.FRX'
      coRgfrx = coRgfrx+'.FRX'
 ENDIF
 coRgfrt = STRTRAN(coRgfrx, '.FRX', '.FRT')
 pcTmpfrx = fiLetemp('FRX')
 pcTmpfrt = STRTRAN(pcTmpfrx, '.FRX', '.FRT')
 COPY FILE (coRgfrx) TO (pcTmpfrx)
 COPY FILE (coRgfrt) TO (pcTmpfrt)
 SELECT 0
 USE EXCLUSIVE (pcTmpfrx) ALIAS laYout
 LOCATE ALL FOR UPPER(TRIM(exPr))=="G_HOTEL" .AND. obJtype=8 .AND.  ;
        foNtsize>=10 .AND. wiDth>=25000 .AND. heIght>=1750 .AND.  ;
        EMPTY(suPexpr) .AND. peNred=0 .AND. peNgreen=0 .AND. peNblue=0  ;
        .AND. fiLlred=255 .AND. fiLlgreen=255 .AND. fiLlblue=255
 IF  .NOT. FOUND()
      l_Retval = .F.
 ELSE
      REPLACE obJtype WITH 5, exPr WITH '"'+ALLTRIM(paRam.pa_hotel)+', '+ ;
              ALLTRIM(paRam.pa_city)+'"'
      IF  .NOT. INLIST(FONTMETRIC(17, foNtface, foNtsize), 0, 255,  ;
          FONTMETRIC(17, 'Arial', 10))
           l_Retval = .F.
      ELSE
           nt1 = vpOs
           nl1 = hpOs
           nh1 = heIght
           nw1 = wiDth
           nrEc = RECNO()
           LOCATE ALL FOR RECNO()<>nrEc .AND. vpOs<nt1+nh1 .AND. vpOs+ ;
                  heIght>nt1 .AND. hpOs<nl1+nw1 .AND. hpOs+wiDth>nl1  ;
                  .AND. obJtype<>9
           IF FOUND()
                l_Retval = .F.
           ENDIF
      ENDIF
 ENDIF
 USE
 SELECT (l_Oldarea)
 IF  .NOT. l_Retval
      =alErt(GetLangText("FUNC","TXT_NOVALIDHOTELNAME")+";"+UPPER(p_Frx)+"!")
 ENDIF
 RETURN l_Retval
ENDFUNC

*
FUNCTION StoD
 PARAMETER p_String
 PRIVATE ALL LIKE l_*
 l_Olddate = SET("date")
 l_Oldcentury = SET("century")
 SET DATE ansi
 SET CENTURY ON
 p_String = STUFF(p_String, 5, 0, ".")
 p_String = STUFF(p_String, 8, 0, ".")
 l_Retval = CTOD(p_String)
 set date &l_OldDate
 set century &l_OldCentury
 RETURN l_Retval
ENDFUNC
*
FUNCTION DtosToDate
LPARAMETERS lp_cDate
IF EMPTY(lp_cDate)
     lp_cDate = DATE()
ENDIF
l_dDate = {}
TRY
     l_dDate = DATE(INT(VAL(LEFT(lp_cDate,4))), INT(VAL(SUBSTR(lp_cDate, 5, 2))), INT(VAL(RIGHT(lp_cDate,2))))
CATCH
ENDTRY
RETURN l_dDate
ENDFUNC
*
FUNCTION TxtPanelGet
 PARAMETER ntOp, nlEft, nrIght, ctExt, ndAtapos, cdAta, nsIze, caTtribute
 IF (PCOUNT()<8)
      caTtribute = ""
 ENDIF
 IF ( .NOT. EMPTY(ctExt))
      DO paNel WITH ntOp-(0.0625), nlEft-1-(0.333333333333333), ntOp+1+ ;
         (0.0625), nrIght+(0.333333333333333), 2
      @ ntOp, nlEft SAY ctExt
 ENDIF
 IF (EMPTY(caTtribute))
      @ ntOp-(0.0625), ndAtapos-(0.333333333333333) TO ntOp+1+(0.0625),  ;
        ndAtapos+nsIze+(0.333333333333333)
 ELSE
      = paNel(ntOp-(0.0625),ndAtapos-(0.333333333333333),ntOp+1+(0.0625), ;
        ndAtapos+nsIze+(0.333333333333333),1)
 ENDIF
 @ ntOp, ndAtapos SAY cdAta STYLE caTtribute SIZE 1, nsIze
 RETURN .T.
ENDFUNC
*
FUNCTION TxtPanel
 PARAMETER ntOp, nlEft, nrIght, ctExt, nsIze, ctYpe
 IF (PCOUNT()<6)
      ctYpe = ""
 ENDIF
 = paNel(ntOp-(0.0625),nlEft-IIF(nsIze<0, 1, 0)-(0.333333333333333),ntOp+ ;
   1+(0.0625),nrIght+(0.333333333333333),2)
 IF ( .NOT. EMPTY(nsIze))
      @ ntOp, nlEft SAY ctExt STYLE ctYpe SIZE 1, ABS(nsIze)
 ELSE
      @ ntOp, nlEft SAY ctExt STYLE ctYpe
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION PanelBorder
 PARAMETER ntOp, nlEft, nrIght, nbOttom, chEading
 PRIVATE npArams
 npArams = PCOUNT()
 IF (npArams==0)
      = paNel(0.25,0.66,WROWS()-0.25,WCOLS()-0.66)
 ELSE
      = paNel(ntOp+0.25,nlEft+0.66,nrIght-0.25,nbOttom-0.66)
      IF (npArams==5)
           @ ntOp-0.25, nlEft+2 SAY " "+chEading+" "
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION ChildTitle
 LPARAMETER lp_cSubtitle, lp_lForceTitle
 LOCAL l_cTitle, l_nPosition, l_cWindow
 l_cTitle = _screen.Caption
 l_nPosition = AT("[", l_cTitle)
 IF (l_nPosition>0)
      l_cTitle = ALLTRIM(SUBSTR(l_cTitle, 1, l_nPosition-3))
 ENDIF
 IF ( .NOT. EMPTY(lp_cSubtitle)) OR lp_lForceTitle
      l_cTitle = l_cTitle+" - ["+upLow(lp_cSubtitle)+"]"
 ELSE
      l_cWindow = WONTOP()
      IF ( .NOT. EMPTY(l_cWindow))
           l_cTitle = l_cTitle+" - ["+upLow(WTITLE(l_cWindow))+"]"
      ENDIF
 ENDIF
 _screen.Caption = IIF(LEN(l_cTitle)>255,LEFT(l_cTitle,255),l_cTitle)
 RETURN lp_cSubtitle
ENDFUNC
*
FUNCTION UpLow
 PARAMETER csTring
 PRIVATE ni
 PRIVATE crEturn
 PRIVATE lsPace
 PRIVATE ccHar
 crEturn = UPPER(SUBSTR(csTring, 1, 1))
 lsPace = .F.
 FOR ni = 2 TO LEN(csTring)
      ccHar = SUBSTR(csTring, ni, 1)
      crEturn = crEturn+IIF(lsPace, UPPER(ccHar), LOWER(ccHar))
      lsPace = (ccHar==" ")
 ENDFOR
 RETURN crEturn
ENDFUNC
*
FUNCTION StrPoint
 PARAMETER nnUmber, nlEngth, ndEcimals
 RETURN (STRTRAN(STR(nnUmber, nlEngth, ndEcimals), ",", "."))
ENDFUNC
*
FUNCTION Bell
 ?? CHR(7)
 RETURN .T.
ENDFUNC
*
FUNCTION InLogIn
 PUBLIC llOgin
 RETURN llOgin
ENDFUNC
*
PROCEDURE CloseFile
 PARAMETER pcAlias
 IF (USED(pcAlias))
      USE IN (pcAlias)
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE CloseAllFiles
LPARAMETERS lp_lTablesOnly, lp_cSkipTablesList
IF EMPTY(lp_cSkipTablesList)
     lp_cSkipTablesList = ""
ENDIF
lp_cSkipTablesList = UPPER(lp_cSkipTablesList)
LOCAL i, l_nOpen
LOCAL ARRAY l_aOpenAliases(1)
l_nOpen = AUSED(l_aOpenAliases)
IF l_nOpen > 0
     FOR i = 1 TO ALEN(l_aOpenAliases,1)
          IF lp_lTablesOnly
               IF ".DBF" $ DBF(l_aOpenAliases(i,1)) AND NOT "["+ALLTRIM(UPPER(l_aOpenAliases(i,1)))+"]" $ lp_cSkipTablesList
                    CloseFile(l_aOpenAliases(i,1))
               ENDIF
          ELSE
               IF NOT "["+ALLTRIM(UPPER(l_aOpenAliases(i,1)))+"]" $ lp_cSkipTablesList
                    CloseFile(l_aOpenAliases(i,1))
               ENDIF
          ENDIF
     ENDFOR
ENDIF
RETURN .T.
ENDPROC
*
FUNCTION IsBirth
 PARAMETER dcHeckdate, dmIndate, dmAxdate
 PRIVATE dnEwdate
 dnEwdate = CTOD(LEFT(DTOC(dcHeckdate), 6)+PADL(YEAR(dmIndate)-1900, 2, "0"))
 RETURN (dnEwdate>=dmIndate .AND. dnEwdate<=dmAxdate)
ENDFUNC
*
FUNCTION NetErr
 PRIVATE lrEturn
 PUBLIC lnEterror
 lrEturn = lnEterror
 lnEterror = .F.
 RETURN lrEturn
ENDFUNC
*
FUNCTION FileDelete
 PARAMETER cfIlename
 IF (FILE(cfIlename))
      ERASE (cfIlename)
 ENDIF
 RETURN ( .NOT. FILE(cfIlename))
ENDFUNC
*
FUNCTION FileCopy
 PARAMETER cFileName1, cFileName2
 LOCAL l_lIsTable, l_cAlias
 LOCAL ARRAY l_aTables(5)

 IF FILE(cFileName1)
     l_lIsTable = (UPPER(JUSTEXT(cFileName1)) == "DBF")
     IF l_lIsTable
          l_cAlias = JUSTSTEM(cFileName1)
          l_aTables(1) = USED(l_cAlias)
          IF l_aTables(1)
              l_aTables(2) = ISEXCLUSIVE(l_cAlias)
              l_aTables(3) = ORDER(l_cAlias)
              l_aTables(4) = CURSORGETPROP("Buffering",l_cAlias)
              l_aTables(5) = RECNO(l_cAlias)
              USE IN &l_cAlias
          ENDIF
     ENDIF
     IF (l_lIsTable OR NOT FILE(cFileName2) OR YesNo(Str2Msg(GetText("SYSTEM","TXT_FILE_ALREADY_EXISTS"),"%s",LOWER(JUSTFNAME(cFileName2))))) AND FileDelete(cFileName2)
         COPY FILE (cFileName1) TO (cFileName2)
     ENDIF
     IF l_lIsTable AND l_aTables(1)
         IF l_aTables(2)
             USE (cFileName1) IN 0 EXCLUSIVE
         ELSE
             USE (cFileName1) IN 0 SHARED
         ENDIF
         IF NOT EMPTY(l_aTables(3))
             SET ORDER TO (l_aTables(3)) IN &l_cAlias
         ENDIF
         IF l_aTables(4) > 1
             CURSORSETPROP("Buffering", l_aTables(4), l_cAlias)
         ENDIF
         GO l_aTables(5) IN &l_cAlias
     ENDIF
 ENDIF

 RETURN FILE(cFileName2)
ENDFUNC
*
FUNCTION vExtraValid
 PRIVATE lrEturn
 IF ( .NOT. llOgin)
      lrEturn =  .NOT. leXtravalid
 ELSE
      lrEturn = .T.
 ENDIF
 RETURN lrEturn
ENDFUNC
*
FUNCTION SkipOK
 KEYBOARD CHR(13)
 RETURN .T.
ENDFUNC
*
FUNCTION ConvertTitle
 LPARAMETER lp_cTitle
 csPecial = "-+="
 FOR ni = 1 TO LEN(csPecial)
      lp_cTitle = STRTRAN(lp_cTitle, SUBSTR(csPecial, ni, 1), "_")
 ENDFOR
 RETURN lp_cTitle
ENDFUNC
*
FUNCTION CleanPhone
 PARAMETER cpHone
 PRIVATE cnEwnumber
 PRIVATE ctMpnumber
 PRIVATE cnUmber
 PRIVATE caReacode
 PRIVATE ceXtension
 PRIVATE ni
 cnEwnumber = cpHone
 cpHone = ALLTRIM(cpHone)
 ctMpnumber = ""
 FOR ni = 1 TO LEN(cpHone)
      cnUmber = SUBSTR(cpHone, ni, 1)
      DO CASE
           CASE AT(cnUmber, "0123456789-+")>0
                ctMpnumber = ctMpnumber+cnUmber
           CASE cnUmber==")"
                ctMpnumber = ctMpnumber+"-"
           CASE cnUmber==" " .AND. ni>=3 .AND. AT("-", ctMpnumber)==0
                ctMpnumber = ctMpnumber+"-"
      ENDCASE
 ENDFOR
 IF (paRam.pa_phnchk .AND. AT("-", ctMpnumber)>0 .AND. SUBSTR(ctMpnumber,  ;
    1, 2)<>"06" .AND. AT("+", ctMpnumber)==0 .AND. SUBSTR(ctMpnumber, 1,  ;
    2)<>"00" .AND. LEN(ctMpnumber)<=11)
      caReacode = SUBSTR(ctMpnumber, 1, AT("-", ctMpnumber)-1)
      ceXtension = SUBSTR(ctMpnumber, AT("-", ctMpnumber)+1)
      IF (paRam.pa_phnpres=="()")
           IF (LEN(caReacode)==3)
                cnEwnumber = "("+caReacode+") "+SUBSTR(ceXtension, 1, 3)+ ;
                             " "+SUBSTR(ceXtension, 4, 2)+" "+ ;
                             SUBSTR(ceXtension, 6)
           ELSE
                cnEwnumber = "("+caReacode+") "+SUBSTR(ceXtension, 1, 2)+ ;
                             " "+SUBSTR(ceXtension, 3, 2)+" "+ ;
                             SUBSTR(ceXtension, 5)
           ENDIF
      ELSE
           cnEwnumber = ALLTRIM(LEFT(paRam.pa_phnpres, 1))+caReacode+ ;
                        ALLTRIM(RIGHT(paRam.pa_phnpres, 1))+ceXtension
      ENDIF
 ELSE
      cnEwnumber = ctMpnumber
 ENDIF
 RETURN cnEwnumber
ENDFUNC
*
FUNCTION SysDate
 IF g_Sysdate <> _screen.oglobal.oparam.pa_sysdate
      g_Sysdate = _screen.oglobal.oparam.pa_sysdate
 ENDIF
 RETURN g_Sysdate
ENDFUNC
*
FUNCTION TimeEmpty
 PARAMETER ctMstr
 RETURN EMPTY(STRTRAN(ctMstr, ":", ""))
ENDFUNC
*
FUNCTION StrZero
 PARAMETER nnUmber, nlEngth
 RETURN PADL(LTRIM(STR(nnUmber)), nlEngth, "0")
ENDFUNC
*
FUNCTION AddOneMonth
 PARAMETER ddAte
 PRIVATE neXtramonth
 PRIVATE dtMpdate
 PRIVATE dcAlcdate
 dtMpdate = ddAte
 dcAlcdate = {}
 neXtramonth = 1
 DO WHILE (EMPTY(dcAlcdate))
      ndAy = DAY(dtMpdate)
      nmOnth = MONTH(dtMpdate)+neXtramonth
      nyEar = YEAR(dtMpdate)
      IF (nmOnth>12)
           nyEar = nyEar+1
           nmOnth = nmOnth-12
      ENDIF
      dcAlcdate = DATE(nyEar, nmOnth, ndAy)
      IF ( .NOT. EMPTY(dcAlcdate))
           dtMpdate = dcAlcdate
      ENDIF
      neXtramonth = neXtramonth+1
 ENDDO
 RETURN dtMpdate
ENDFUNC
*
FUNCTION AddOneYear
 PARAMETER ddAte
 PRIVATE neXtrayear
 PRIVATE dtMpdate
 PRIVATE dcAlcdate
 dtMpdate = ddAte
 dcAlcdate = {}
 neXtrayear = 1
 DO WHILE (EMPTY(dcAlcdate))
      ndAy = DAY(dtMpdate)
      nmOnth = MONTH(dtMpdate)
      nyEar = YEAR(dtMpdate)+neXtrayear
      dcAlcdate = DATE(nyEar, nmOnth, ndAy)
      IF ( .NOT. EMPTY(dcAlcdate))
           dtMpdate = dcAlcdate
      ENDIF
      neXtrayear = neXtrayear+1
 ENDDO
 RETURN dtMpdate
ENDFUNC
*
FUNCTION MonthStart
 PARAMETER ddAte
 PRIVATE dcAlcdate
 PRIVATE cdAteformat
 dcAlcdate = DATE(YEAR(ddAte),MONTH(ddAte),1)
 RETURN dcAlcdate
ENDFUNC
*
FUNCTION SeekDay
 PARAMETER ddAte, ndAyno
 PRIVATE dcAlcdate
 dcAlcdate = ddAte
 DO WHILE (DOW(dcAlcdate)<>ndAyno)
      dcAlcdate = dcAlcdate+1
 ENDDO
 RETURN dcAlcdate
ENDFUNC
*
FUNCTION DateOccurence
 PARAMETER dsTartdate, ndAyoccurence, noNoccurence
 IF (noNoccurence==5 .AND. ndAyoccurence==8)
      dtHedate = moNthstart(adDonemonth(moNthstart(dsTartdate)))-1
 ELSE
      dfIrstdate = seEkday(moNthstart(dsTartdate),ndAyoccurence)
      dsEconddate = dfIrstdate+7
      dtHirddate = dsEconddate+7
      dfOurthdate = dtHirddate+7
      dfIfthdate = dfOurthdate+7
      DO CASE
           CASE noNoccurence==1
                dtHedate = dfIrstdate
           CASE noNoccurence==2
                dtHedate = dsEconddate
           CASE noNoccurence==3
                dtHedate = dtHirddate
           CASE noNoccurence==4
                dtHedate = dfOurthdate
           CASE noNoccurence==5
                dtHedate = IIF(MONTH(dfIfthdate)==MONTH(dsTartdate),  ;
                           dfIfthdate, dfOurthdate)
           OTHERWISE
                WAIT WINDOW TIMEOUT 2 GetLangText("FUNC","TXT_SELECTFIRST")
                dtHedate = dsTartdate
      ENDCASE
 ENDIF
 RETURN dtHedate
ENDFUNC
*
FUNCTION InfoWindow
 LPARAMETER lp_cTitle
 IF (PCOUNT()==1)
      IF (SUBSTR(lp_cTitle, 1, 1)=="~")
           DEFINE WINDOW wbUsymessage FROM 0, 0 TO 20, 40 FONT "Arial",  ;
                  10 NOCLOSE NOZOOM TITLE SUBSTR(lp_cTitle, 2) IN scReen  ;
                  NOMDI DOUBLE
           MOVE WINDOW wbUsymessage CENTER
           ACTIVATE WINDOW wbUsymessage
           = paNelborder()
      ELSE
           SCROLL 2, 2, 17, 38, 1
           @ 16, 2 SAY lp_cTitle
      ENDIF
 ELSE
      RELEASE WINDOW wbUsymessage
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION dbSeek
 PARAMETER csEekwhat, csEekalias, nsEekorder
 PRIVATE ldBsfoundit
 PRIVATE ndBsselect
 PRIVATE ndBsorder
 ldBsfoundit = .F.
 ndBsselect = SELECT()
 SELECT (csEekalias)
 ndBsorder = ORDER()
 SET ORDER TO nSeekOrder
 ldBsfoundit = SEEK(csEekwhat, csEekalias)
 SET ORDER TO ndbSOrder
 SELECT (ndBsselect)
 RETURN ldBsfoundit
 EXTERNAL ARRAY paData
ENDFUNC
*
FUNCTION FirstArrDate
 PARAMETER paData
 PRIVATE daRrdate
 PRIVATE nrEscount
 daRrdate = paData(1,1)
 FOR nrEscount = 2 TO 9
      IF ( .NOT. EMPTY(paData(nrEscount,1)))
           daRrdate = MIN(daRrdate, paData(nrEscount,1))
      ENDIF
 ENDFOR
 RETURN daRrdate
ENDFUNC
*
FUNCTION Exclusive
 PRIVATE nlOcks, nrEc, naRea
 IF RECCOUNT("license")=0
      RETURN .T.
 ENDIF
 nlOcks = 0
 naRea = SELECT()
 SELECT liCense
 nrEc = RECNO()
 SCAN ALL
      IF dlOck('License',1)
           = duNlock('License')
      ELSE
           nlOcks = nlOcks+1
      ENDIF
 ENDSCAN
 SELECT liCense
 GOTO nrEc
 = dlOck('License',-1)
 SELECT (naRea)
 RETURN (nlOcks==0)
ENDFUNC
*
FUNCTION ConvertTxt
 PARAMETER ctExt, ctOconvert, ccOnvertto
 PRIVATE ncNvcount
 FOR ncNvcount = 1 TO LEN(ctOconvert)
      ctExt = STRTRAN(ctExt, SUBSTR(ctOconvert, ncNvcount, 1), ccOnvertto)
 ENDFOR
 RETURN ctExt
ENDFUNC
*
FUNCTION PhoneNr
 PARAMETER crOom
 PRIVATE cpHone
 PRIVATE naRea
 PRIVATE nrMorder
 PRIVATE nrMrecord
 naRea = SELECT()
 SELECT roOm
 nrMrecord = RECNO()
 nrMorder = ORDER()
 SET ORDER TO 1
 IF (SEEK(ALLTRIM(crOom), "Room"))
      IF (AT(",", roOm.rm_phone)>0)
           cpHone = LEFT(roOm.rm_phone, AT(",", roOm.rm_phone)-1)
      ELSE
           cpHone = roOm.rm_phone
      ENDIF
 ELSE
      cpHone = ""
 ENDIF
 SELECT roOm
 SET ORDER TO nRmOrder
 GOTO nrMrecord
 SELECT (naRea)
 RETURN ALLTRIM(cpHone)
ENDFUNC
*
FUNCTION RoomNr
 PARAMETER cpHone
 PRIVATE crOom
 PRIVATE naRea
 PRIVATE nrMorder
 PRIVATE nrMrecord
 naRea = SELECT()
 SELECT roOm
 nrMrecord = RECNO()
 nrMorder = ORDER()
 SET ORDER TO 1
 GOTO TOP
 LOCATE FOR LEFT(roOm.rm_phone, LEN(cpHone))=cpHone
 IF ( .NOT. EOF())
      crOom = ALLTRIM(roOm.rm_roomnum)
 ELSE
      crOom = ""
 ENDIF
 SELECT roOm
 SET ORDER TO nRmOrder
 GOTO nrMrecord
 SELECT (naRea)
 RETURN ALLTRIM(crOom)
ENDFUNC
*
FUNCTION StrPoint
 PARAMETER nvAlue, nlEngth, ndEcimals
 RETURN STRTRAN(STR(nvAlue, nlEngth, ndEcimals), ",", ".")
ENDFUNC
*
FUNCTION GuestName
 PARAMETER caLias
 PRIVATE nsElect
 PRIVATE cnAme
 nsElect = SELECT()
 SELECT (caLias)
 cnAme = ALLTRIM(ad_title)+" "+ALLTRIM(ad_fname)+" "+flIp(ALLTRIM(ad_lname))
 SELECT (nsElect)
 RETURN cnAme
ENDFUNC
*
FUNCTION CompanyName
 LPARAMETERS tcAlias
 LOCAL lcName

 IF EMPTY(tcAlias)
      tcAlias = "address"
 ENDIF
 lcName = Flip(ALLTRIM(&tcAlias..ad_company))

 RETURN lcName
ENDFUNC
*
FUNCTION DayNumber
 PARAMETER ddAte
 PRIVATE ndAys
 PRIVATE ni
 ndAys = 0
 IF (PCOUNT()==0)
      ddAte = sySdate()
 ENDIF
 FOR ni = 1 TO MONTH(ddAte)
      IF (MONTH(ddAte)==ni)
           ndAys = ndAys+DAY(ddAte)
      ELSE
           ndAys = ndAys+laStday(CTOD("01-"+stRzero(ni,2)+"-"+ ;
                   SUBSTR(STR(YEAR(ddAte)), 3, 2)))
      ENDIF
 ENDFOR
 RETURN ndAys
ENDFUNC
*
FUNCTION UniqueNumber
 RETURN VAL(ALLTRIM(STR(daYnumber(), 3))+stRzero(SECONDS()*100,7))
ENDFUNC
*
FUNCTION GetIni
 PARAMETER pcInifile, pcSection, pcKey, pcDefault
 PRIVATE nfN, nbYtes, cbUff
 cbUff = REPLICATE(CHR(0), 256)
 nbYtes = geTprivateprofilestring(pcSection,pcKey,pcDefault,@cbUff,256, ;
          pcInifile)
 RETURN LEFT(cbUff, nbYtes)
ENDFUNC
*
PROCEDURE PutIni
 PARAMETER pcInifile, pcSection, pcKey, pcString
 PRIVATE nfN, nbYtes
 nbYtes = wrIteprivateprofilestring(pcSection,pcKey,pcString,pcInifile)
 RETURN
ENDPROC
*
FUNCTION MsgBox
 LPARAMETERS pcText, pcTitle, pnFlags
 IF g_lAutomationMode
      RETURN 6 && Yes
 ELSE
      RETURN MESSAGEBOX(pcText, pnFlags, pcTitle)
 ENDIF
ENDFUNC
*
FUNCTION Chk
 LPARAMETERS plValid, pcMsg
 IF  .NOT. plValid
      alErt(pcMsg)
 ENDIF
 RETURN plValid
ENDFUNC
*
FUNCTION checkkeylabel
* IF g_pushkeyactive
*      g_pushkeyactive = .f.
*      POP KEY
* ENDIF
RETURN .T.
ENDFUNC
*
FUNCTION setkeylabel
*     IF !g_pushkeyactive
*          g_pushkeyactive = .t.
*          PUSH KEY CLEAR 
*     ENDIF
RETURN .T.
ENDFUNC
*
FUNCTION MakeShorDateString
     LPARAMETERS PDate
     LOCAL LRetVal
          LRetVal = SUBSTR(DTOC(PDate),1,6)+SUBSTR(DTOC(PDate),9,10)
     RETURN LRetVal
ENDFUNC
*
FUNCTION allowlogin
 LPARAMETERS PAllow
 LOCAL l_lSuccess, l_lRelogin, l_lBlock
 l_lRelogin = .T.
  
 IF PAllow
      l_lSuccess = openfiledirect(.F.,"license")
      IF l_lSuccess
           DO DebugBlockAllUsers IN debug WITH .F., .T.
           DO CheckNetID IN main WITH l_lRelogin
      ENDIF
 ELSE
      * USE license exclusive, so no another user can login.
      l_lSuccess = openfiledirect(.T.,"license")
      openfiledirect(.F.,"license")
      IF NOT l_lSuccess
           IF NOT _screen.oGlobal.lDoAuditOnStartup
                *IF yesno(getlangtext("SYSTEM","TXT_USERS_LOGGED_IN")+CHR(13)+CHR(13)+;
                          getlangtext("AUDIT","TXT_CONTINUE")+"?")
                     l_lSuccess = .F.
                     DO DBBlockOtherWorkStations IN dbupdate WITH l_lSuccess
                     
                     IF l_lSuccess
                          openfiledirect(.T.,"license")
                          l_lBlock = .T.
                     ELSE
                          * User forced to continue. Then use licencse shared, and lock record for this workstation.
                          openfiledirect(.F.,"license")
                          DO CheckNetID IN main WITH l_lRelogin
                          l_lSuccess = .T.
                     ENDIF
                *ENDIF
           ENDIF
      ELSE
           l_lBlock = .T.
      ENDIF
      IF l_lBlock
           DO DebugBlockAllUsers IN debug WITH .T., .T.
      ENDIF
 ENDIF
 RETURN l_lSuccess

*!*      IF PAllow
*!*           UNLOCK IN param
*!*      ELSE
*!*           LOCK('param')
*!*      ENDIF
*!*      FLUSH
ENDFUNC
*
FUNCTION checktime
LPARAMETERS cTime
LOCAL l_hours, l_minutes
l_hours = Max(0, Min(23, Val(Substr(cTime, 1, 2))))
l_minutes = Max(0, Min(59, Val(Substr(cTime, 4, 2))))
If  !Empty(Substr(cTime, 1, 2)+Substr(cTime, 4, 2))
     RETURN Padl(Ltrim(Str(l_hours)), 2, "0")+":"+Padl(Ltrim(Str(l_minutes)), 2, "0")
ELSE
     RETURN ""
ENDIF
ENDFUNC
*
FUNCTION CheckTimeEmpty
LPARAMETERS lp_cTime
RETURN EMPTY(SUBSTR(lp_cTime, 1, 2) + SUBSTR(lp_cTime, 4, 2))
ENDPROC
*
FUNCTION CountRoomsInHotel
LOCAL l_nSelected, l_nValue, l_nRecNo, l_lRoomOpened, l_lRoomtypeOpened, l_cSql, l_cCur
l_nValue = 0
l_nSelected = SELECT()
IF NOT USED("room")
     openfile(.F.,"room")
     l_lRoomOpened = .T.
ENDIF
IF NOT USED("roomtype")
     openfile(.F.,"roomtype")
     l_lRoomtypeOpened = .T.
ENDIF
TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT COUNT(*) AS counted ;
          FROM room ;
          INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp ;
          WHERE rt_group IN (1,4)
ENDTEXT

l_cCur = SqlCursor(l_cSql,,,"",.NULL.,.T.)
IF RECCOUNT() > 0
     l_nValue = &l_cCur..counted
ENDIF
dclose(l_cCur)

IF l_lRoomOpened
     dclose("room")
ENDIF
IF l_lRoomtypeOpened
     dclose("roomtype")
ENDIF
SELECT (l_nSelected)
RETURN l_nValue
ENDFUNC
*
FUNCTION HotelClosed
 * Receives a date, for wich is checked if hotel is closed
 * This is defined in season.dbf
 LPARAMETERS lp_dSysDate
 LOCAL l_lHotelClosed, l_cCursor, l_nSelect
 l_nSelect = SELECT()
 l_cCursor = SYS(2015)
 l_lHotelClosed = .F.
 SELECT se_hotclos FROM season WHERE se_date = lp_dSysDate INTO CURSOR &l_cCursor
 IF RECCOUNT()>0
      IF RECCOUNT()>1 && If more then 1 record is found for specified date, take first result. BTW, this should not happen
           GO TOP
      ENDIF
      l_lHotelClosed = se_hotclos
 ENDIF
 USE
 SELECT (l_nSelect)
 RETURN l_lHotelClosed
ENDFUNC
*
FUNCTION get_rm_rmname
LPARAMETERS lp_cRoomnum, lp_cFormat, lp_oGlobal
LOCAL l_uRoomName, l_cFormat

IF EMPTY(lp_cRoomnum)
     l_uRoomName = ""
ELSE
     DO CASE
          CASE VARTYPE(lp_oGlobal) = "O"
          CASE TYPE("poGlobalRmRtBld") = "O"
               lp_oGlobal = poGlobalRmRtBld
          OTHERWISE
               lp_oGlobal = _screen.oGlobal
     ENDCASE
     l_cFormat = IIF(EMPTY(lp_cFormat), "rm_rmname", lp_cFormat)
     l_uRoomName = lp_oGlobal.get_room(PADR(lp_cRoomnum,4), l_cFormat, "rm_roomnum")
     IF EMPTY(l_uRoomName) AND LOWER(l_cFormat) = "rm_rmname"
          l_uRoomName = lp_cRoomnum
     ENDIF
     IF VARTYPE(l_uRoomName) = "C"
          l_uRoomName = ALLTRIM(l_uRoomName)
     ENDIF
ENDIF

RETURN l_uRoomName
ENDFUNC
*
&& get_rm_rmname_linked receives string with roomnum ids 
&& separeted with commas, and returns string with rmnames 
&& also separated with commas.
FUNCTION get_rm_rmname_linked
LPARAMETERS lp_cRoomNums
LOCAL l_cRoomNames, i, l_cRoomNumber

l_cRoomNames = ""
IF EMPTY(lp_cRoomNums)
     RETURN l_cRoomNames
ENDIF

FOR i = 1 TO GETWORDCOUNT(lp_cRoomNums, ",")
     l_cRoomNumber = ALLTRIM(GETWORDNUM(lp_cRoomNums,i,","))
     l_cRoomNames = l_cRoomNames + get_rm_rmname(l_cRoomNumber) + ","
ENDFOR

IF NOT EMPTY(l_cRoomNames)
     l_cRoomNames = SUBSTR(l_cRoomNames,1,LEN(l_cRoomNames)-1)
ENDIF

RETURN l_cRoomNames
ENDFUNC
*
FUNCTION get_rm_roomnum
LPARAMETERS lp_cRm_rmname, lp_cRt_buildng, lp_oGlobal
LOCAL l_uRoomNum

IF EMPTY(lp_cRm_rmname)
     l_uRoomNum = ""
ELSE
     DO CASE
          CASE VARTYPE(lp_oGlobal) = "O"
          CASE TYPE("poGlobalRmRtBld") = "O"
               lp_oGlobal = poGlobalRmRtBld
          OTHERWISE
               lp_oGlobal = _screen.oGlobal
     ENDCASE
     IF EMPTY(lp_cRt_buildng)
          l_uRoomNum = lp_oGlobal.get_room(PADR(lp_cRm_rmname,10), "rm_roomnum", "rm_rmname")
     ELSE
          l_uRoomNum = lp_oGlobal.get_room(PADR(lp_cRt_buildng,3)+PADR(lp_cRm_rmname,10), "rm_roomnum", "rm_bldroom")
     ENDIF
     IF EMPTY(l_uRoomNum)
          l_uRoomNum = lp_cRm_rmname
     ENDIF
     IF VARTYPE(l_uRoomNum) = "C"
          l_uRoomNum = ALLTRIM(l_uRoomNum)
     ENDIF
ENDIF

RETURN l_uRoomNum
ENDFUNC
*
FUNCTION get_rm_room_count
LPARAMETERS lp_cWhere, lp_oGlobal
LOCAL l_nCount

DO CASE
     CASE VARTYPE(lp_oGlobal) = "O"
     CASE TYPE("poGlobalRmRtBld") = "O"
          lp_oGlobal = poGlobalRmRtBld
     OTHERWISE
          lp_oGlobal = _screen.oGlobal
ENDCASE
l_nCount = lp_oGlobal.get_room_count(lp_cWhere)

RETURN l_nCount
ENDFUNC
*
FUNCTION get_rt_roomtyp
LPARAMETERS lp_cRoomtype, lp_cFormat, lp_lRetRtId, lp_oGlobal
LOCAL l_uRoomtype, l_cWhere

IF EMPTY(lp_cRoomtype)
     l_uRoomtype = ""
ELSE
     DO CASE
          CASE VARTYPE(lp_oGlobal) = "O"
          CASE TYPE("poGlobalRmRtBld") = "O"
               lp_oGlobal = poGlobalRmRtBld
          OTHERWISE
               lp_oGlobal = _screen.oGlobal
     ENDCASE
     l_cFormat = IIF(EMPTY(lp_cFormat), "RTRIM(rd_roomtyp)+' '+rt_buildng", lp_cFormat)
     IF lp_lRetRtId
          l_cWhere = l_cFormat + " = " + SqlCnv(lp_cRoomtype)
          l_uRoomtype = lp_oGlobal.get_roomtype(l_cWhere, "rt_roomtyp")
     ELSE
          l_uRoomtype = lp_oGlobal.get_roomtype(PADR(lp_cRoomtype,4), l_cFormat, "rt_roomtyp")
     ENDIF
     IF VARTYPE(l_uRoomtype) = "C"
          l_uRoomtype = ALLTRIM(l_uRoomtype)
     ENDIF
ENDIF

RETURN l_uRoomtype
ENDFUNC
*
PROCEDURE Check_rmrtbld
LOCAL i, j, lnArea, lcSqlSelect, lnRecno, lnRecno1, lcRoomnum, lcLink, lcLinked, lcRoomLnk, lnRoomOcc, lnRoomOccLinked, lnRoomOccLinkedForAvl, lcLinkDetails

IF NOT USED("rmrtbld")
     lnArea = SELECT()
     * For optimization. Generate only once
     TEXT TO lcSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
          SELECT *, CAST(NVL(rm_lang<<g_langnum>>,'') AS Char(25)) AS rm_lang, CAST('' AS Char(100)) AS rm_linked, CAST('' AS Memo) AS rm_linkdt, CAST(0 AS Numeric(16,3)) AS rm_roomocc FROM room ;
               LEFT JOIN roomtype ON rt_roomtyp = rm_roomtyp
     ENDTEXT
     SqlCursor(lcSqlSelect, "rmrtbld",,,, .T.,, .T.)
     IF USED("rmrtbld")
          SELECT rmrtbld
          * Set standard room occupation rate.
          REPLACE rm_roomocc WITH IIF(rt_group = 1 AND rt_vwsum, 1, 0) ALL
          INDEX ON rm_roomnum TAG rm_roomnum
          INDEX ON rm_rmname TAG rm_rmname
          INDEX ON rt_buildng+rm_rmname TAG rm_bldroom
          SET ORDER TO
          * In field 'rm_linked' set all rooms from which is current room linked.
          SCAN FOR NOT EMPTY(rm_link)
               lnRecno = RECNO()
               lcRoomnum = ALLTRIM(rm_roomnum)
               lcLink = STRTRAN(rm_link," ")
               FOR i = 1 TO GETWORDCOUNT(lcLink,",")
                    lcRoomLnk = GETWORDNUM(lcLink,i,",")
                    IF SEEK(PADR(lcRoomLnk,4),"rmrtbld","rm_roomnum") AND NOT (","+lcRoomnum+",") $ (","+ALLTRIM(rm_linked)+",")
                         REPLACE rm_linked WITH ALLTRIM(rm_linked) + IIF(EMPTY(rm_linked),"",",") + lcRoomnum
                    ENDIF
               NEXT
               GO lnRecno
          ENDSCAN
          * Recalculate occupation rate for all rooms linked by standard rooms.
          SCAN FOR NOT EMPTY(rm_link)
               lnRecno = RECNO()
               lcRoomnum = ALLTRIM(rm_roomnum)
               lcLink = STRTRAN(rm_link," ")
               lnRoomOcc = rm_roomocc
               lcLinkDetails = ""
               FOR i = 1 TO GETWORDCOUNT(lcLink,",")
                    lcRoomLnk = GETWORDNUM(lcLink,i,",")
                    IF SEEK(PADR(lcRoomLnk,4),"rmrtbld","rm_roomnum")
                         STORE 0 TO lnRoomOccLinkedForAvl, lnRoomOccLinked
                         IF INLIST(rt_group, 1, 4) AND rt_vwsum
                              lnRoomOccLinkedForAvl = 1
                              IF rt_group = 1
                                   lnRoomOccLinked = 1
                              ENDIF
                              lcLinked = STRTRAN(rm_linked," ")
                              lnRecno1 = RECNO()
                              FOR j = 1 TO GETWORDCOUNT(lcLinked,",")
                                   lcRoomLnk = GETWORDNUM(lcLinked,j,",")
                                   IF lcRoomLnk <> lcRoomnum AND SEEK(PADR(lcRoomLnk,4),"rmrtbld","rm_roomnum") AND INLIST(rt_group, 1, 4) AND rt_vwsum
                                        lnRoomOccLinkedForAvl = lnRoomOccLinkedForAvl + 1
                                        IF rt_group = 1
                                             lnRoomOccLinked = lnRoomOccLinked + 1
                                        ENDIF
                                   ENDIF
                              NEXT
                              GO lnRecno1
                              IF rt_group = 1
                                   lnRoomOcc = lnRoomOcc + 1/lnRoomOccLinked
                              ENDIF
                         ENDIF
                         lcLinkDetails = lcLinkDetails + IIF(EMPTY(lcLinkDetails), "", CRLF) + ;
                              rt_roomtyp + ";" + TRANSFORM(IIF(lnRoomOccLinkedForAvl = 0, 0, 1/lnRoomOccLinkedForAvl)) + ";" + TRANSFORM(rt_group) + ";" + rm_roomnum
                    ENDIF
               NEXT
               GO lnRecno
               IF lnRoomOcc <> rm_roomocc
                    REPLACE rm_roomocc WITH lnRoomOcc
               ENDIF
               IF NOT EMPTY(lcLinkDetails)
                    REPLACE rm_linkdt WITH lcLinkDetails
               ENDIF
          ENDSCAN
     ENDIF
     SELECT(lnArea)
ENDIF
ENDPROC
*
PROCEDURE Check_rtrdbld
LOCAL l_nArea, l_cSqlSelect

IF NOT USED("rtrdbld")
     l_nArea = SELECT()
     * For optimization. Generate only once
     TEXT TO l_cSqlSelect TEXTMERGE NOSHOW PRETEXT 2 + 8
          SELECT *, CAST(NVL(rt_lang<<g_langnum>>,'') AS Char(25)) AS rt_lang, CAST(NVL(bu_lang<<g_langnum>>,'') AS Char(80)) AS bu_lang FROM Roomtype ;
               LEFT JOIN RTypeDef ON rd_rdid = rt_rdid ;
               LEFT JOIN Building ON bu_buildng = rt_buildng
     ENDTEXT
     SqlCursor(l_cSqlSelect, "rtrdbld",,,, .T.,, .T.)
     IF USED("rtrdbld")
          SELECT rtrdbld
          INDEX ON rt_roomtyp TAG rt_roomtyp
          SET ORDER TO
     ENDIF
     SELECT(l_nArea)
ENDIF
ENDPROC
*
PROCEDURE get_room
LPARAMETERS tcWhere, tcFormat, tcIndex
LOCAL lnArea, lcRoomName

lnArea = SELECT()

Check_rmrtbld()

SELECT rmrtbld
IF EMPTY(tcIndex)
     DLocate("rmrtbld", tcWhere)
ELSE
     * Optimization
     = SEEK(tcWhere, "rmrtbld", tcIndex)
ENDIF
lcRoomName = &tcFormat

SELECT (lnArea)

RETURN lcRoomName
ENDPROC
*
PROCEDURE get_roomtype
LPARAMETERS tcWhere, tcFormat, tcIndex
LOCAL lnArea, lcRoomtype

lnArea = SELECT()

Check_rtrdbld()

SELECT rtrdbld
IF EMPTY(tcIndex)
     DLocate("rtrdbld", tcWhere)
ELSE
     * Optimization
     = SEEK(tcWhere, "rtrdbld", tcIndex)
ENDIF
lcRoomtype = &tcFormat

SELECT (lnArea)

RETURN lcRoomtype
ENDPROC
*
PROCEDURE get_room_count
LPARAMETERS tcWhere
LOCAL lnCount

Check_rmrtbld()
CALCULATE CNT() FOR &tcWhere TO lnCount IN rmrtbld

RETURN lnCount
ENDPROC
*
PROCEDURE GetRoomLastOccDate
LPARAMETERS lp_cRoomName
LOCAL l_dOccDate
DO RiLastOccupiedDate IN procresrooms WITH lp_cRoomName, l_dOccDate
RETURN l_dOccDate
ENDPROC
*
FUNCTION FileSize
LPARAMETERS lp_cFilePath
LOCAL ARRAY l_aAttInfo(1)
ADIR(l_aAttInfo,lp_cFilePath)
IF TYPE("l_aAttInfo(2)")=="N"
     RETURN l_aAttInfo(2)
ELSE
     RETURN 0
ENDIF
ENDFUNC
*
PROCEDURE SetStatusLine
 SetStatusBarMessage()
*!*      LOCAL l_cMessage
*!*      l_cMessage = ALLTRIM(g_Hotel)+" | "+DTOC(sySdate())+" | "+ ;
*!*                ALLTRIM(cuSerid)+" | "+ALLTRIM(gcCashier)
*!*      _VFP.StatusBar = l_cMessage
 RETURN .T.
ENDPROC
*
PROCEDURE AppendFrom
LPARAMETERS lp_cFromAlias, lp_cCondition, lp_cToAlias, lp_cCandidateId
 LOCAL l_cTempAlias, l_nSelect, l_cDeleted
 l_nSelect = SELECT()
 IF EMPTY(lp_cCondition)
      lp_cCondition = "1=1"
 ENDIF
 IF EMPTY(lp_cToAlias)
      lp_cToAlias = ALIAS()
 ENDIF
 IF EMPTY(lp_cCandidateId)
      lp_cCandidateId = ""
 ELSE
      l_cDeleted = SET("Deleted")
      SET DELETED OFF
 ENDIF
 IF USED(lp_cFromAlias) AND IsCursor(lp_cFromAlias)
      l_cTempAlias = SYS(2015)
      l_cMacro = "SELECT * FROM " + lp_cFromAlias + " WHERE " + lp_cCondition + " INTO CURSOR " + l_cTempAlias
      &l_cMacro
 ELSE
     l_cTempAlias = SqlCursor("SELECT * FROM " + lp_cFromAlias + " WHERE " + lp_cCondition)
 ENDIF
 SCAN
      SCATTER MEMO MEMVAR
      IF EMPTY(lp_cCandidateId)
           INSERT INTO &lp_cToAlias FROM MEMVAR
      ELSE
           IF DLocate(lp_cToAlias, lp_cCandidateId + " = " + SqlCnv(m.&lp_cCandidateId,.T.))
                SELECT &lp_cToAlias
                RECALL
                GATHER MEMVAR MEMO
                SELECT &l_cTempAlias
           ELSE
                INSERT INTO &lp_cToAlias FROM MEMVAR
           ENDIF
      ENDIF
 ENDSCAN
 IF NOT EMPTY(lp_cCandidateId)
      SET DELETED &l_cDeleted
 ENDIF
 DClose(l_cTempAlias)
 SELECT (l_nSelect)
ENDPROC
*
PROCEDURE MsgQuestion
LPARAMETERS lp_cMsg, lp_nButtons, lp_cTitle
IF EMPTY(lp_nButtons)
     lp_nButtons = 260
ENDIF
RETURN msgbox(lp_cMsg,lp_cTitle,32 + lp_nButtons)
ENDFUNC
*
FUNCTION WaitWindowShow
LPARAMETERS lp_cWindowText
WAIT lp_cWindowText WINDOW NOWAIT NOCLEAR
ENDFUNC
*
FUNCTION WaitWindowClear
WAIT CLEAR
ENDFUNC
*
FUNCTION GetHotelLangNum
LOCAL l_nLangNum, l_cLangNum, l_cWhere, l_cCurResult, l_nSelect
l_nSelect = SELECT()
l_cWhere = "pl_label+pl_charcod = 'LANGUAGE  " + param.pa_lang + "'"
l_cCurResult = SYS(2015)
SELECT pl_numcod FROM picklist WHERE &l_cWhere INTO CURSOR (l_cCurResult)
IF RECCOUNT()>0
     l_cLangNum = ALLTRIM(STR(pl_numcod))
ELSE
     l_cLangNum = g_langnum
ENDIF
USE IN (l_cCurResult)
SELECT (l_nSelect)
RETURN l_cLangNum
ENDFUNC
*
FUNCTION GetBuilding
LPARAMETERS lp_cLabel, lp_uObjectId, l_lBuilId
LOCAL l_cBuildId, l_cBuilding

DO CASE
     CASE lp_cLabel == "ROOMTYPE"
          l_cBuildId = DLookUp("roomtype", "rt_roomtyp = " + SqlCnv(PADR(lp_uObjectId,4)), "rt_buildng")
     CASE lp_cLabel == "ALLOTT"
          l_cBuildId = DLookUp("althead", "al_altid = " + SqlCnv(lp_uObjectId), "al_buildng")
     OTHERWISE
          l_cBuildId = ""
ENDCASE

DO CASE
     CASE EMPTY(l_cBuildId)
          l_cBuilding = ""
     CASE l_lBuilId
          l_cBuilding = l_cBuildId
     OTHERWISE
          l_cBuilding = DLookUp("building", "bu_buildng = " + SqlCnv(PADR(l_cBuildId,3)), "bu_lang" + g_langnum)
ENDCASE

RETURN l_cBuilding
ENDFUNC
*
PROCEDURE SetStatusBarMessage
LPARAMETERS lp_cHotelSelected, lp_cExtReservations
LOCAL cmSg, l_cUser
IF EMPTY(lp_cHotelSelected)
     lp_cHotelSelected = ""
ENDIF
IF inLogin()
     cmSg = ALLTRIM(g_Hotel)+" | "+DTOC(sySdate()) + ;
               IIF(EMPTY(lp_cHotelSelected),""," | "+lp_cHotelSelected)
     l_cUser = ""
ELSE
*!*          cmSg = ALLTRIM(g_Hotel)+" | "+DTOC(sySdate())+" | "+ ;
*!*                    ALLTRIM(cuSerid)+" | "+ALLTRIM(gcCashier)
     cmSg = ALLTRIM(g_Hotel)+" | "+DTOC(sySdate())+" | "+ ;
               ALLTRIM(gcCashier) + ;
               IIF(EMPTY(_screen.oglobal.oBuilding.cdescription),""," | "+_screen.oglobal.oBuilding.cdescription) + ;
               IIF(EMPTY(lp_cHotelSelected),""," | "+lp_cHotelSelected) + ;
               IIF(EMPTY(lp_cExtReservations),""," | "+lp_cExtReservations)
     l_cUser = cuSerid
ENDIF
 *_vfp.StatusBar = PADR(cmSg, 114)
 *_screen.oGlobal.oStatusBar.SetText(PADR(cmSg, 114), l_cUser)
 _screen.oGlobal.oStatusBar.SetText(cmSg, l_cUser)
ENDPROC
*
PROCEDURE InitMousePointer
PUBLIC gnarrowpointer
_SCREEN.mousepointer = 1
DOEVENTS
gnarrowpointer = GetScreenCursor()
_SCREEN.mousepointer = 0
DOEVENTS
ENDPROC
*
FUNCTION SetVar
LPARAMETERS puvar, puvalue
puvar = puvalue
RETURN .T.
ENDFUNC
*
FUNCTION ConvColors
LPARAMETERS lp_nColor, lp_nKoef
LOCAL l_nConvColor, l_nRed, l_nGreen, l_nBlue

lp_nKoef = MIN(10,MAX(0,lp_nKoef))

l_nRed = BITAND(lp_nColor, 0xFF)
l_nGreen = BITAND(BITRSHIFT(lp_nColor,8), 0xFF)
l_nBlue = BITAND(BITRSHIFT(lp_nColor,16), 0xFF)

l_nRed = MIN(255, ROUND(l_nRed * IIF(lp_nKoef>1,1+(lp_nKoef/10)*(255-l_nRed)/l_nRed,lp_nKoef),0))
l_nGreen = MIN(255, ROUND(l_nGreen * IIF(lp_nKoef>1,1+(lp_nKoef/10)*(255-l_nGreen)/l_nGreen,lp_nKoef),0))
l_nBlue = MIN(255, ROUND(l_nBlue * IIF(lp_nKoef>1,1+(lp_nKoef/10)*(255-l_nBlue)/l_nBlue,lp_nKoef),0))

l_nConvColor = RGB(l_nRed, l_nGreen, l_nBlue)

RETURN l_nConvColor
ENDFUNC
*
FUNCTION ConvColorsA
LPARAMETERS lp_nColor, lp_nColorKoef
LOCAL l_nConvColor, l_nRed, l_nGreen, l_nBlue, l_nKoefR, l_nKoefG, l_nKoefB

l_nKoefR = BITAND(lp_nColorKoef, 0xFF) / 255
l_nKoefG = BITAND(BITRSHIFT(lp_nColorKoef,8), 0xFF) / 255
l_nKoefB = BITAND(BITRSHIFT(lp_nColorKoef,16), 0xFF) / 255

l_nRed = BITAND(lp_nColor, 0xFF)
l_nGreen = BITAND(BITRSHIFT(lp_nColor,8), 0xFF)
l_nBlue = BITAND(BITRSHIFT(lp_nColor,16), 0xFF)

l_nRed = MIN(255, ROUND(l_nRed * IIF(l_nKoefR>1,1+(l_nKoefR/10)*(255-l_nRed)/l_nRed,l_nKoefR),0))
l_nGreen = MIN(255, ROUND(l_nGreen * IIF(l_nKoefG>1,1+(l_nKoefG/10)*(255-l_nGreen)/l_nGreen,l_nKoefG),0))
l_nBlue = MIN(255, ROUND(l_nBlue * IIF(l_nKoefB>1,1+(l_nKoefB/10)*(255-l_nBlue)/l_nBlue,l_nKoefB),0))

l_nConvColor = RGB(l_nRed, l_nGreen, l_nBlue)

RETURN l_nConvColor
ENDFUNC
*
PROCEDURE GetEmptyDate
LPARAMETERS pddate
IF ISNULL(pddate) OR pddate = {^1611-11-11}
     RETURN {}
ELSE
     RETURN pddate
ENDIF
ENDPROC
*
PROCEDURE GetEmptyDateTime
LPARAMETERS ptdate
IF ISNULL(ptdate) OR ptdate = {^1611-11-11 11:11:11}
     RETURN {..::}
ELSE
     RETURN ptdate
ENDIF
ENDPROC
*
PROCEDURE GetArrayRef
LPARAMETERS lp_oRefObject, lp_cProperty
LOCAL l_cMacro

IF TYPE("lp_oRefObject") = "O"
     l_cMacro = "@lp_oRefObject."+lp_cProperty
ELSE
     l_cMacro = "@"+lp_cProperty
ENDIF

RETURN &l_cMacro
ENDPROC
*
PROCEDURE GetRaMulti
LPARAMETERS lp_nIndex, lp_WithoutLine
LOCAL l_cMulti

DO CASE
	CASE lp_nIndex = 1
		l_cMulti = GetLangText("MGRFINAN","TXT_ADULT",,lp_WithoutLine)
	CASE lp_nIndex = 2
		l_cMulti = GetLangText("MGRFINAN","TXT_PERSON",,lp_WithoutLine)
	CASE lp_nIndex = 3
		l_cMulti = GetLangText("MGRFINAN","TXT_CHILD",,lp_WithoutLine) + " " + LstItem(_screen.oglobal.oparam.pa_childs, 1)
	CASE lp_nIndex = 4
		l_cMulti = "1x"
	CASE lp_nIndex = 5
		l_cMulti = GetLangText("MGRFINAN","TXT_CHILD",,lp_WithoutLine) + " " + LstItem(_screen.oglobal.oparam.pa_childs, 2)
	CASE lp_nIndex = 6
		l_cMulti = GetLangText("MGRFINAN","TXT_CHILD",,lp_WithoutLine) + " " + LstItem(_screen.oglobal.oparam.pa_childs, 3)
	CASE lp_nIndex = 7
		l_cMulti = GetLangText("MGRFINAN","TXT_DONT_POST",,lp_WithoutLine)
	OTHERWISE
		l_cMulti = GetLangText("MGRFINAN","TXT_NOTDEFINED",,lp_WithoutLine)
ENDCASE

RETURN l_cMulti
ENDPROC
*
PROCEDURE GetRaType
LPARAMETERS lp_nIndex, lp_WithoutLine
LOCAL l_cType

DO CASE
	CASE lp_nIndex = 1
		l_cType = GetLangText("MGRFINAN","TXT_MAIN",,lp_WithoutLine)
	CASE lp_nIndex = 2
		l_cType = GetLangText("MGRFINAN","TXT_RASPLIT",,lp_WithoutLine)
	CASE lp_nIndex = 3
		l_cType = GetLangText("MGRFINAN","TXT_EXTRA",,lp_WithoutLine)
	OTHERWISE
		l_cType = GetLangText("MGRFINAN","TXT_NOTDEFINED",,lp_WithoutLine)
ENDCASE

RETURN l_cType
ENDPROC
*
* Check similar fields in Source and Destination aliases and get comma delimited replace fields clause.
PROCEDURE GetReplaceClauseForSimilarFields
LPARAMETERS tcSourceAlias, tcDestinationAlias, tlWithOutMemos, tcSkipFields
* Don't forget to add comma to last element in tcSkipFields list!
* Example: RS_CCAUTH,RS_CCEXPY,RS_CCLIMIT,RS_CCNUM,RS_CCREF,
LOCAL i, lcField, lcReplaceClause, lcSourceMark, lcDestinationMark
LOCAL ARRAY laSourceFields(1), laDestinationFields(1)

=AFIELDS(laSourceFields, tcSourceAlias)
=AFIELDS(laDestinationFields, tcDestinationAlias)
lcSourceMark = LEFT(laSourceFields(1,1),3)
lcDestinationMark = LEFT(laDestinationFields(1,1),3)
lcReplaceClause = ""
FOR i = 1 TO ALEN(laSourceFields,1)
     lcField = IIF(lcSourceMark == lcDestinationMark, laSourceFields(i,1), STRTRAN(laSourceFields(i,1), lcSourceMark, lcDestinationMark))
     IF 0 < ASCAN(laDestinationFields, lcField, 1, 0, 1, 7) AND (NOT tlWithOutMemos OR laSourceFields(i,2) # 'M') AND ;
               (EMPTY(tcSkipFields) OR NOT laSourceFields(i,1)+"," $ tcSkipFields)
          lcReplaceClause = lcReplaceClause + IIF(EMPTY(lcReplaceClause), "", ", ") + ;
               LOWER(lcField) + " WITH " + LOWER(tcSourceAlias + "." + laSourceFields(i,1))
     ENDIF
NEXT
RETURN lcReplaceClause
ENDPROC
*
PROCEDURE CheckIsCtrlPressed
LOCAL l_lDllRegistered, i

#DEFINE VK_lSHIFT 0x10 && Relocate to a header file
#DEFINE VK_lCONTROL 0x11 && Relocate to a header file

IF ADLLS(l_aDllsTest)>0
     FOR i = 1 TO ALEN(l_aDllsTest,1)
          IF TRIM(LOWER(l_aDllsTest(i,1))) == "getkeystate"
               l_lDllRegistered = .T.
               EXIT
          ENDIF
     ENDFOR
ENDIF
IF NOT l_lDllRegistered
     DECLARE INTEGER GetKeyState IN WIN32API INTEGER && Relocate to where WinAPI calls are declared
ENDIF

RETURN GetKeyState(VK_lCONTROL) < 0 OR GetKeyState(VK_lCONTROL) > 1 && Check for control key press
ENDPROC
*
PROCEDURE X_TRIM
* Dummy procedure, to skip error when building.
* X_TRIM not found in xfrx.fxp.
ENDPROC
*
PROCEDURE GetNights
LPARAMETERS tdArrdate, tdDepdate, tlPrevYear, tdStartLY, tdEndLY, tdStartCY, tdEndCY, tdEvFrom, tdEvTo
DO CASE
     CASE EMPTY(tdArrdate) OR EMPTY(tdDepdate)
          RETURN 0
     CASE EMPTY(tdEvFrom) OR EMPTY(tdEvTo)
     OTHERWISE
          tdArrdate = MAX(tdArrdate,tdEvFrom)
          tdDepdate = MIN(tdDepdate,tdEvTo)
ENDCASE

DO CASE
     CASE tdDepdate = tdArrdate
          *RETURN IIF(EMPTY(tdEndLY) OR BETWEEN(tdArrdate,tdStartLY,tdEndLY) OR BETWEEN(tdArrdate,tdStartCY,tdEndCY), 1, 0)
          RETURN 0
     CASE tlPrevYear AND EMPTY(tdEndLY)
          RETURN DATE(YEAR(tdDepdate),1,1) - tdArrdate
     CASE tlPrevYear
          RETURN MAX(0, tdEndLY-tdArrdate) - MAX(0, tdStartLY-tdArrdate) + MAX(0, tdEndCY-tdArrdate) - MAX(0, tdStartCY-tdArrdate)
     CASE EMPTY(tdEndLY)
          RETURN tdDepdate - MAX(tdArrdate, DATE(YEAR(tdDepdate),1,1))
     CASE YEAR(tdDepdate) = YEAR(tdEndLY)
          RETURN MAX(0, tdDepdate-MAX(tdArrdate,tdStartLY,DATE(YEAR(tdDepdate),1,1))) - MAX(0, tdDepdate-tdEndLY)
     OTHERWISE
          RETURN MAX(0, tdDepdate-MAX(tdArrdate,tdStartCY,DATE(YEAR(tdDepdate),1,1))) - MAX(0, tdDepdate-tdEndCY)
ENDCASE
ENDPROC
*
PROCEDURE Fn_TotalPrice
* Calculating a TotalPrice of reservation.
LPARAMETERS lp_nReserId, lp_nRate, lp_nExtra, lp_nSumResFix, lp_nSumPackage, lp_nRedirectTotal, lp_nRsId, lp_aVats
LOCAL l_nSelect, l_lResrateClose, l_lRessplitClose, l_nTotalPrice, l_cCurPost, l_cCurVat, l_cVatnum1Macro, l_cVatnum2Macro, l_cLangMacro, l_lOnlyPrice
EXTERNAL ARRAY lp_aVats

IF PCOUNT()=0
     RETURN 0.00
ENDIF

* Check if lp_aVats ia array, to prevent error "name" is not an array (Error 232) in SQL SELECT using lp_aVats for results.
IF TYPE("lp_aVats(1)")="U"
     DIMENSION lp_aVats(1)
ENDIF

l_nSelect = SELECT()

l_lOnlyPrice = (PCOUNT()=1)
IF VARTYPE(lp_nRsId)<>"N"
     lp_nRsId = dlookup("reservat","rs_reserid = " + sqlcnv(lp_nReserId),"rs_rsid")
ENDIF

IF NOT USED("ressplit")
     OpenFile(.F.,"ressplit")
     l_lRessplitClose = .T.
ENDIF

IF NOT l_lOnlyPrice
     l_cVatnum1Macro = "rl_price*rl_units*pl1.pl_numval/" + IIF(param.pa_exclvat,"100","(100+pl1.pl_numval)")
     l_cVatnum2Macro = IIF(param.pa_exclvat AND param.pa_compvat,"(1+pl1.pl_numval/100)*","") + "rl_price*rl_units*pl2.pl_numval/" + IIF(param.pa_exclvat,"100","(100+pl2.pl_numval)")
     l_cLangMacro = "pl_lang"+g_Langnum
     l_cCurVat = SYS(2015)
     l_cCurPost = SYS(2015)
     SELECT rl_date, rl_price, rl_units, ar_vat, NVL(pl1.&l_cLangMacro,SPACE(25)) AS rl_vatlng1, ar_vat2, NVL(pl2.&l_cLangMacro,SPACE(25)) AS rl_vatlng2, ;
          IIF(ar_vat=1,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=1,&l_cVatnum2Macro,0.00000000) AS rl_vat1, ;
          IIF(ar_vat=2,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=2,&l_cVatnum2Macro,0.00000000) AS rl_vat2, IIF(ar_vat=3,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=3,&l_cVatnum2Macro,0.00000000) AS rl_vat3, ;
          IIF(ar_vat=4,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=4,&l_cVatnum2Macro,0.00000000) AS rl_vat4, IIF(ar_vat=5,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=5,&l_cVatnum2Macro,0.00000000) AS rl_vat5, ;
          IIF(ar_vat=6,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=6,&l_cVatnum2Macro,0.00000000) AS rl_vat6, IIF(ar_vat=7,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=7,&l_cVatnum2Macro,0.00000000) AS rl_vat7, ;
          IIF(ar_vat=8,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=8,&l_cVatnum2Macro,0.00000000) AS rl_vat8, IIF(ar_vat=9,&l_cVatnum1Macro,0.00000000)+IIF(ar_vat2=9,&l_cVatnum2Macro,0.00000000) AS rl_vat9 ;
          FROM ressplit WITH (BUFFERING = .T.) ;
          LEFT JOIN article ON rl_artinum = ar_artinum ;
          LEFT JOIN picklist pl1 ON pl1.pl_label = [VATGROUP] AND pl1.pl_numcod = ar_vat ;
          LEFT JOIN picklist pl2 ON pl2.pl_label = [VATGROUP] AND pl2.pl_numcod = ar_vat2 ;
          WHERE rl_rsid = lp_nRsId ;
          INTO CURSOR &l_cCurPost READWRITE
     SELECT SUM(rl_vat1), SUM(rl_vat2), SUM(rl_vat3), SUM(rl_vat4), SUM(rl_vat5), SUM(rl_vat6), SUM(rl_vat7), SUM(rl_vat8), SUM(rl_vat9) FROM &l_cCurPost ;
          INTO ARRAY lp_aVats
     DIMENSION lp_aVats(2,9)

     SELECT DISTINCT ar_vat, rl_vatlng1 FROM &l_cCurPost WHERE ar_vat > 0 ;
          UNION SELECT DISTINCT ar_vat2, rl_vatlng2 WHERE ar_vat2 > 0 FROM &l_cCurPost ;
          INTO CURSOR &l_cCurVat
     SCAN FOR EMPTY(lp_aVats(2,ar_vat))
          lp_aVats(2,ar_vat) = rl_vatlng1
     ENDSCAN
     CloseFile(l_cCurPost)
     CloseFile(l_cCurVat)
ENDIF

SELECT ressplit
SUM IIF((rl_rfid = 0 AND rl_bqid = 0) AND rl_artityp <> 3, rl_price*rl_units, 0), ;
    IIF((rl_rfid = 0 AND rl_bqid = 0) AND rl_artityp = 3, rl_price*rl_units, 0), ;
    IIF((rl_rfid > 0 OR  rl_bqid > 0) AND (rl_artityp <> 2 OR rl_raid > 0), rl_price*rl_units, 0), ;
    IIF((rl_rfid > 0 OR  rl_bqid > 0) AND (rl_artityp = 2 AND rl_raid = 0), rl_price*rl_units, 0), ;
    IIF(rl_rdrsid > 0, rl_price*rl_units, 0) ;
          FOR rl_rsid = lp_nRsId ;
          TO lp_nRate, lp_nExtra, lp_nSumResFix, lp_nSumPackage, lp_nRedirectTotal

l_nTotalPrice = lp_nRate + lp_nSumPackage + lp_nExtra + lp_nSumResFix - lp_nRedirectTotal

IF l_lRessplitClose
     CloseFile("ressplit")
ENDIF

SELECT (l_nSelect)

RETURN l_nTotalPrice
ENDPROC
*
FUNCTION GeneratePin
LPARAMETERS tcOldPin
LOCAL lcNewPin, i

IF EMPTY(tcOldPin)
     tcOldPin = ""
ENDIF
lcNewPin = ""
FOR i = 1 TO 10
     lcNewPin = RIGHT(CHRTRAN(TRANSFORM(RAND(SECONDS())*10000),".,",""),4)
     IF NOT lcNewPin == tcOldPin
          EXIT
     ENDIF
     Sleep(100)
ENDFOR

RETURN lcNewPin
ENDFUNC
*
FUNCTION GetLoggerChanges
LPARAMETERS tcTable, tcKeyExp, tuKeyId, tnDays, tcField
* EMPTY(tnDays)  - Get all changes
* tnDays = -1    - Get changes for last LOG_SHOW_DEF_DAYS (=7) days
* tnDays > 0     - Get changes for last 'tnDays' days
* EMPTY(tcField) - Get changes for all fields
* tcField        - Get only changes for field = 'tcField'
LOCAL i, lnArea, lcChanges, lcChange, lcWhereSysdate, lcSingleChange, lcurLogger
LOCAL ARRAY laLines(1)

lnArea = SELECT()
IF EMPTY(tnDays)
     lcWhereSysdate = ""
ELSE
     lcWhereSysdate = " AND BETWEEN(lg_sysdate, " + SqlCnv(Sysdate() - IIF(tnDays=-1, LOG_SHOW_DEF_DAYS, tnDays),.T.) + ", " + SqlCnv(Sysdate(),.T.) + ")"
ENDIF

lcChanges = ""

lcurLogger = Sqlcursor("SELECT lg_when, lg_sysdate, lg_action, lg_changes, lg_user FROM logger WHERE lg_table = " + SqlCnv(ALLTRIM(tcTable),.T.) + ;
     " AND lg_keyexp = " + SqlCnv(ALLTRIM(tcKeyExp),.T.) + " AND lg_keyid = " + SqlCnv(TRANSFORM(tuKeyId),.T.) + lcWhereSysdate)
SCAN
     lcChange = ""
     FOR i = 1 TO ALINES(laLines, STRTRAN(lg_changes, CRLF,"|/|"),"|/||/|")
          lcSingleChange = STREXTRACT(ALLTRIM(laLines(i)),"_","",1,2)
          IF EMPTY(tcField) OR ALLTRIM(UPPER(STREXTRACT(lcSingleChange,"","|/|",1))) == UPPER(STREXTRACT(tcField,"_","",1,2))
               lcChange = lcChange + IIF(EMPTY(lcChange), "", ", ") + ALLTRIM(STREXTRACT(lcSingleChange,"","|/|",1)) + ;
                    " (" + ALLTRIM(STREXTRACT(lcSingleChange,"|/|","|/|",1)) + "-->" + ALLTRIM(STREXTRACT(lcSingleChange,"|/|","",2)) + ")"
          ENDIF
     NEXT
     IF lg_action <> 'U' OR NOT EMPTY(lcChange)
          lcChanges = lcChanges + IIF(EMPTY(lcChanges), "", CRLF) + TRANSFORM(lg_when) + "  " + PADR(lg_user,11) + ;
               ICASE(lg_action = 'D', "DELETED", lg_action = 'I', "CREATED", "CHANGED    " + lcChange)
     ENDIF
ENDSCAN
DClose(lcurLogger)

SELECT(lnArea)

RETURN lcChanges
ENDFUNC
*
FUNCTION GetSecondsFromTime
LPARAMETERS lp_cTime

lp_cTime = CheckTime(lp_cTime)

RETURN IIF(EMPTY(lp_cTime), 0, 3600*INT(VAL(LEFT(lp_cTime,2)))+60*INT(VAL(RIGHT(lp_cTime,2))))
ENDFUNC
*
PROCEDURE FNGetErrorHeader
LOCAL l_cErrorText
l_cErrorText = ""
l_cErrorText = "#INT#|"+DTOC(DATE())+" "+TIME()+" "+wiNpc()+" "+IIF(TYPE("g_userid")="C",g_userid,"@") + CHR(10) + ;
          PROGRAM(1)+"|"+ALLTRIM(_screen.caption)+;
          IIF(TYPE("g_Hotel") = "C", CHR(10)+"Hotel: "+g_Hotel, "") + CHR(10)
RETURN l_cErrorText
ENDPROC
*
PROCEDURE FNGetMPDataPath
LPARAMETERS lp_cHotelPath
LOCAL l_cPath
l_cPath = ADDBS(LOWER(ALLTRIM(lp_cHotelPath)))
l_cPath = STUFF(l_cPath, LEN(l_cPath), 1, IIF(Odbc(),".","\"+IIF(glTraining,"training","data")+"\")) && If odbc database, add . before table name
RETURN l_cPath
ENDPROC
*
PROCEDURE FNStructureToXML
* StructureToXML.PRG
* Save the structure of a table in XML format
LPARAMETERS cXMLFile, uWorkArea
* uWorkArea - (numeric) work area or (character) alias.
* If omitted, use current work area.

LOCAL nCurrentArea, cStruFile, cOldSafety
IF VARTYPE(m.cXMLFile) <> "C" OR EMPTY(m.cXMLFile)
 ERROR 11
 RETURN .f.
ENDIF
nCurrentArea = SELECT()
IF NOT EMPTY(m.uWorkArea)
 SELECT (m.uWorkArea)
ENDIF
IF NOT USED()
 ERROR 52
 SELECT (m.nCurrentArea)
 RETURN .F.
ENDIF
cOldSafety = SET("Safety")
cStruFile = filetemp("DBF",.T.)
SET SAFETY OFF
COPY STRUCTURE EXTENDED TO (m.cStruFile)
SET SAFETY &cOldSafety
SELECT 0
USE (m.cStruFile) ALIAS __Stru
CURSORTOXML("__Stru", m.cXMLFile, 1, 8 + 512, 0, "1")
* Clean up
USE IN __Stru
ERASE (m.cStruFile)
ERASE FORCEEXT(m.cStruFile, "FPT")
SELECT (m.nCurrentArea)
RETURN
ENDPROC
*
PROCEDURE FNTableFromXML
* TableFromXML.PRG
* Create a new table from an XML structure file
LPARAMETERS cXMLFile, cTableFile
IF VARTYPE(m.cXMLFile) <> "C" OR EMPTY(m.cXMLFile)
 ERROR 11
 RETURN .f.
ENDIF
IF VARTYPE(m.cTableFile) <> "C" OR EMPTY(m.cTableFile)
 ERROR 11 
 RETURN .f.
ENDIF
LOCAL nCurrentArea, cStruTable, cOldSafety
nCurrentArea = SELECT()
cOldSafety = SET("Safety")
XMLTOCURSOR(m.cXMLFile, "__Stru", 0)
* Have to create an actual table
cStruTable = filetemp("DBF",.T.)
SELECT __Stru
SET SAFETY OFF
COPY TO (m.cStruTable)
SET SAFETY &cOldSafety
CREATE (m.cTableFile) from (m.cStruTable)
* Clean up
ERASE (m.cStruTable)
ERASE FORCEEXT(m.cStruTable, "FPT")
SELECT (m.nCurrentArea)
RETURN
ENDPROC
*
PROCEDURE FNNextIdTemp
LPARAMETERS lp_cTable
LOCAL l_nId, l_cTable
l_nId = -99999999
IF EMPTY(lp_cTable)
     RETURN l_nId
ENDIF
l_cTable = "_" + PADR(lp_cTable,7)
l_nId = nextid(l_cTable)
l_nId = l_nId * (-1)
RETURN l_nId
ENDPROC
*
PROCEDURE FNNextIdTempWriteRealId
* This function is updating id with real nextid function, after id for main and child tables is generated with FNNextIdTemp function.

LPARAMETERS lp_cTable, lp_cField, lp_cIdCode, lp_lForceOpentables, lp_lFastCheck
LOCAL l_nSelect, l_cCur, l_cTblCursor, l_cFieldId, l_cTable, l_cField, l_cWhere, l_cSet, l_nNewId, l_cFor, l_cSql, l_cOrder, l_nRecNo

IF EMPTY(lp_cTable) OR EMPTY(lp_cField) OR EMPTY(lp_cIdCode)
     RETURN .F.
ENDIF

lp_cTable = UPPER(lp_cTable)
lp_cField = UPPER(lp_cField)

IF lp_lFastCheck
     * Check if in table exists records with temporary ID. If not, exit immediately.
     IF NOT dlocate(lp_cTable, lp_cField + " < 0", .T.)
          RETURN .T.
     ENDIF
ENDIF

l_nSelect = SELECT()

l_cFieldId = SUBSTR(ALLTRIM(lp_cField),4)
l_cCur = SYS(2015)
SELECT fd_table, fd_name FROM fields WHERE l_cFieldId $ fd_name INTO CURSOR (l_cCur)
IF lp_lForceOpentables AND NOT USED(lp_cTable)
     openfile(.F.,lp_cTable)
ENDIF
l_cTblCursor = SYS(2015)
* I am using direct fox select sql, and not sqlcursor function, because of table buffering.
l_cSql = "SELECT " + LOWER(lp_cField) + " AS c_id FROM " + LOWER(lp_cTable) + " WITH (BUFFERING=.T.) WHERE " + lp_cField + " < 0 ORDER BY 1 DESC INTO CURSOR " + l_cTblCursor
&l_cSql
SELECT (l_cTblCursor)
SCAN ALL
     SELECT (l_cCur)
     l_cFor = "fd_table = '" + PADR(lp_cTable,8) + "' AND fd_name = '" + PADR(lp_cField,10) + "'"
     LOCATE FOR &l_cFor
     IF FOUND()
          l_nNewId = nextid(lp_cIdCode)
          l_cTable = LOWER(ALLTRIM(fd_table))
          l_cField = LOWER(ALLTRIM(fd_name))
          l_cWhere = l_cField + " = " + TRANSFORM(&l_cTblCursor..c_id)
          l_cSet = l_cField + " WITH " + TRANSFORM(l_nNewId)
          SELECT &l_cTable
          l_cOrder = ORDER()
          l_nRecNo = RECNO()
          SET ORDER TO
          l_cSql = "REPLACE " + l_cSet + " FOR " +  l_cWhere
          &l_cSql
          SET ORDER TO l_cOrder
          GO l_nRecNo
          SELECT (l_cCur)
          l_cFor = "fd_table <> '" + PADR(lp_cTable,8) + "'"
          SCAN FOR &l_cFor
               l_cTable = LOWER(ALLTRIM(fd_table))
               IF NOT USED(l_cTable)
                    openfile(.F.,l_cTable)
               ENDIF
               IF NOT USED(l_cTable)
                    * If table wasn't used, then i presume that nothing was written in this child table, and no update is needed.
                    LOOP
               ENDIF
               l_cField = LOWER(ALLTRIM(&l_cCur..fd_name))
               l_cWhere = l_cField + " = " + TRANSFORM(&l_cTblCursor..c_id)
               l_cSet = l_cField + " WITH " + TRANSFORM(l_nNewId)
               SELECT &l_cTable
               l_cOrder = ORDER()
               l_nRecNo = RECNO()
               SET ORDER TO
               l_cSql = "REPLACE " + l_cSet + " FOR " +  l_cWhere
               &l_cSql
               SET ORDER TO l_cOrder
               GO l_nRecNo
          ENDSCAN
     ENDIF
ENDSCAN

dclose(l_cCur)
dclose(l_cTblCursor)

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE FNGetCallStack
LOCAL l_nStackCount, l_cCallStack, l_cProgram
l_nStackCount = 1
l_cCallStack = ""
l_cProgram = PROGRAM()
DO WHILE PROGRAM(l_nStackCount) <> l_cProgram
	l_cCallStack = l_cCallStack + PROGRAM(l_nStackCount) + " "
	l_nStackCount = l_nStackCount + 1
ENDDO
RETURN l_cCallStack
ENDPROC
*
PROCEDURE FNDoBrwMulSel
LPARAMETERS lp_cRecordSource, lp_aDefs, lp_cCaption, lp_aUniButtonProp, lp_lSortColumns, lp_cGridToolTip, lp_lNoToggle, lp_lDontRefreshToolbar, lp_nRecno, lp_lNoOKButton
EXTERNAL ARRAY lp_aDefs
LOCAL l_nResult
SELECT 0
DO FORM forms\brwmulsel WITH lp_cRecordSource, lp_aDefs, lp_cCaption, lp_aUniButtonProp, lp_lSortColumns, lp_cGridToolTip, lp_lNoToggle, lp_lDontRefreshToolbar, lp_nRecno, lp_lNoOKButton TO l_nResult
RETURN l_nResult
ENDPROC
*
PROCEDURE FNCursorToJson
LPARAMETERS lp_cCursorName
LOCAL ojson, cxml, cdetails, opacked, cRecieptDetails
ojson = NEWOBJECT("json","common\progs\json.prg")
cxml = filetemp("XML",.T.)
FNStructureToXML(@cxml,lp_cCursorName)
cdetails = ojson.stringify(lp_cCursorName)
opacked = CREATEOBJECT("Empty")
ADDPROPERTY(opacked, "cursorstructure", FILETOSTR(cxml))
ADDPROPERTY(opacked, "cursordata", cdetails)
RETURN ojson.stringify(opacked)
ENDPROC
*
PROCEDURE FNJsonToCursor
LPARAMETERS lp_cJSON, lp_cCursorName
LOCAL ojson, odetails, cxml, ccurjsondata, ccurjsonalias
ojson = NEWOBJECT("json","common\progs\json.prg")
odetails = ojson.parse(lp_cJSON)
cxml = odetails.cursorstructure
ccurjsondata = filetemp("DBF",.T.)
ccurjsonalias = JUSTSTEM(ccurjsondata)
FNTableFromXML(cxml, ccurjsondata)
IF NOT odetails.cursordata == ["VFPData": {}] && Don't try to parse JSON without records in table
	= ojson.parse(odetails.cursordata, ,ccurjsonalias)
ENDIF
SELECT * FROM (ccurjsonalias) INTO CURSOR (lp_cCursorName) NOFILTER
dclose(ccurjsonalias)
filedelete(ccurjsondata)
filedelete(FORCEEXT(ccurjsondata,"FPT"))
RETURN USED(lp_cCursorName)
ENDPROC
*
PROCEDURE FNStringifyCursor
LPARAMETERS lp_cCursorName
LOCAL ojson
ojson = NEWOBJECT("json","common\progs\json.prg")
RETURN SUBSTR(ojson.stringify(lp_cCursorName),12)
ENDPROC
*
&& FNStringifyObject receives VFP object reference, and stringifies it to JSON object
PROCEDURE FNStringifyObject
LPARAMETERS lp_oObj
LOCAL ojson
ojson = NEWOBJECT("json","common\progs\json.prg")
RETURN ojson.stringify(lp_oObj)
ENDPROC
*
PROCEDURE FNGetWindowData
LPARAMETERS lp_nRsId, lp_nWindow, lp_cField, lp_lHistory

RETURN DLookUp(IIF(lp_lHistory, "hpwindow", "pswindow"), "pw_rsid = " + SqlCnv(lp_nRsId) + " AND pw_window = " + SqlCnv(lp_nWindow), ;
     IIF(UPPER(lp_cField) == "PW_WINPOS" AND BETWEEN(lp_nWindow, 1, 6), "EVL(pw_winpos,pw_window)", lp_cField))
ENDPROC
*
PROCEDURE FNSetWindowData
LPARAMETERS lp_nRsId, lp_nWindow, lp_cField, lp_uValue, lp_cPwAlias
LOCAL l_nSelect, l_lExists

l_nSelect = SELECT()

lp_cPwAlias = EVL(lp_cPwAlias, "pswindow")
IF NOT USED(lp_cPwAlias) AND lp_cPwAlias = "pswindow"
     openfile(,lp_cPwAlias)
ENDIF

l_lExists = SEEK(PADL(lp_nRsId,10)+PADL(lp_nWindow,10),lp_cPwAlias,"tag4")
IF l_lExists OR NOT EMPTY(lp_uValue)
     IF NOT l_lExists
          INSERT INTO &lp_cPwAlias (pw_pwid, pw_rsid, pw_window, pw_winpos) ;
               VALUES (NextId("PSWINDOW"), lp_nRsId, lp_nWindow, IIF(lp_nWindow < 7, lp_nWindow, 0))
     ENDIF
     REPLACE &lp_cField WITH lp_uValue IN &lp_cPwAlias
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE FNGetBillData
LPARAMETERS lp_nReserId, lp_nWindow, lp_cField

RETURN DLookUp("billnum", "bn_reserid = " + SqlCnv(lp_nReserId) + " AND bn_status <> 'CXL' AND bn_window = " + SqlCnv(lp_nWindow), lp_cField)
ENDPROC
*
PROCEDURE FNGetAddressFeature
LPARAMETERS lp_nAddrid, lp_nFeatNo
LOCAL i, l_nArea, l_cFeature

l_nArea = SELECT()
i = 0
l_cFeature = ""
SELECT adrfeat
SCAN FOR fa_addrid = lp_nAddrid
     i = i + 1
     IF i = lp_nFeatNo
          l_cFeature = fa_feature
          EXIT
     ENDIF
ENDSCAN
SELECT(l_nArea)

RETURN l_cFeature
ENDPROC
*
PROCEDURE FNMyGetWordNum
LPARAMETERS lp_cString, lp_nIndex, lp_cDelimiter
* Simplified version of VFP GETWORDNUM function.
* Deleimiter can be maximal 1 character long.
* Works also when no value between delimiters.

LOCAL l_cWord, l_nIndex, i
l_cWord = ""
IF EMPTY(lp_cDelimiter) OR LEN(lp_cDelimiter)>1
     lp_cDelimiter = " "
ENDIF
IF EMPTY(lp_nIndex)
     RETURN l_cWord
ENDIF

l_nIndex = 1
FOR i = 1 TO LEN(lp_cString)
     l_cChar = SUBSTR(lp_cString,i,1)
     IF l_cChar = lp_cDelimiter
          IF l_nIndex = lp_nIndex
               EXIT
          ELSE
               l_nIndex = l_nIndex + 1
               l_cWord = ""
          ENDIF
     ELSE
          l_cWord = l_cWord + l_cChar
     ENDIF
ENDFOR

RETURN l_cWord
ENDPROC
*
PROCEDURE FNRemoveHTMLTag
LPARAMETERS lp_cHTML
LOCAL l_nLines, i, l_cResult
LOCAL ARRAY l_aLines(1)

l_cResult = ""
l_nLines = ALINES(l_aLines, lp_cHTML)
FOR i = 1 TO l_nLines
     l_cLine = l_aLines(i)
     l_cLine = STRTRAN(l_cLine, "<P>", "")
     l_cLine = STRTRAN(l_cLine, "<P align=left>", "")
     l_cLine = STRTRAN(l_cLine, "<P align=right>", "")
     l_cLine = STRTRAN(l_cLine, "<P align=center>", "")
     l_cLine = STRTRAN(l_cLine, "</P>", "")
     l_cLine = STRTRAN(l_cLine, "<STRONG>", "")
     l_cLine = STRTRAN(l_cLine, "</STRONG>", "")
     l_cLine = STRTRAN(l_cLine, "<EM>", "")
     l_cLine = STRTRAN(l_cLine, "</EM>", "")
     l_cLine = STRTRAN(l_cLine, "<U>", "")
     l_cLine = STRTRAN(l_cLine, "</U>", "")
     l_cLine = STRTRAN(l_cLine, "&nbsp;", "")
     l_cLine = FNRemoveFONTTag(l_cLine)

     l_cResult = l_cResult + l_cLine + CHR(13) + CHR(10)
ENDFOR

RETURN l_cResult
ENDPROC
*
PROCEDURE FNRemoveFONTTag
LPARAMETERS lp_cLine
LOCAL l_cLine, i, l_cFontAttributes, l_cFontTag
LOCAL ARRAY l_FontsFound(1)
l_cLine = lp_cLine
l_nFontsFound = AT("<FONT ", l_cLine)
i = 0
IF l_nFontsFound = 0
     RETURN l_cLine
ENDIF
DO WHILE i <= l_nFontsFound
     i = i + 1
     l_cFontAttributes = STREXTRACT(l_cLine, "<FONT ", ">", i)
     DIMENSION l_FontsFound(i)
     l_FontsFound(i) = l_cFontAttributes
ENDDO

IF i > 0
     FOR i = 1 TO ALEN(l_FontsFound)
          l_cFontAttributes = l_FontsFound(i)
          l_cFontTag = "<FONT " + l_cFontAttributes + ">"
          l_cLine = STRTRAN(l_cLine, l_cFontTag, "")
          l_cLine = STRTRAN(l_cLine, "</FONT>", "")
     ENDFOR
ENDIF

RETURN l_cLine
ENDPROC
*
PROCEDURE FNIsRoomTypeAvailable
LPARAMETERS lp_cRT, lp_dFrom, lp_dTo
LOCAL l_lIsAvailable, l_cSql, l_nSelect, l_cCur

l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT MIN(av_avail - av_definit - IIF(param.pa_optidef,av_option,0) - IIF(param.pa_tentdef,av_tentat,0) - IIF(param.pa_allodef,av_allott-av_pick,0) - IIF(param2.pa_oosdef,av_ooservc,0)) 
	AS result 
	FROM availab 
	INNER JOIN param ON 1=1 
	INNER JOIN param2 ON 1=1 
	WHERE av_roomtyp = '<<PADR(lp_cRT,4)>>' AND av_date BETWEEN <<sqlcnv(lp_dFrom,.T.)>> AND <<sqlcnv(lp_dTo,.T.)>>
ENDTEXT

l_cCur = sqlcursor(l_cSql)
IF USED(l_cCur)
	SELECT (l_cCur)
	GO TOP
	IF result > 0
		l_lIsAvailable = .T.
	ENDIF
	dclose(l_cCur)
ENDIF

SELECT (l_nSelect)

RETURN l_lIsAvailable
ENDPROC
*
PROCEDURE FNGetReserIdForActiveWindow
LOCAL l_nReserId, l_cWinName
l_nReserId = 0
_screen.oGlobal.oBill.nReserId = 0
l_cWinName = wname()
IF INLIST(l_cWinName, "WRESERVAT","WRSBROWSE","TFORM12") AND _screen.oGlobal.oBill.nReserId > 1
     l_nReserId = _screen.oGlobal.oBill.nReserId
ENDIF
_screen.oGlobal.oBill.nReserId = 0
RETURN l_nReserId
ENDPROC
*
PROCEDURE FNWaitWindow
* Replaces VFP native WAIT WINDOW function, to prevent executing it in automation mode

LPARAMETERS lp_cText, lp_lNoWait, lp_nTimeOut, lp_lClear
IF g_lAutomationMode
	RETURN .T.
ENDIF
IF EMPTY(lp_cText)
	lp_cText = ""
ENDIF
IF VARTYPE(lp_nTimeOut)<>"N"
	lp_nTimeOut = 0
ENDIF
l_cCmd = [WAIT lp_cText WINDOW]
l_cParams = ""
DO CASE
	CASE lp_lNoWait
		l_cParams = "NOWAIT"
	CASE lp_nTimeOut > 0
		l_cParams = "TIMEOUT " + TRANSFORM(lp_nTimeOut)
	CASE lp_lClear
		l_cCmd = "WAIT"
		l_cParams = "CLEAR"
ENDCASE
&l_cCmd &l_cParams 
ENDPROC
*
*****************************************************************************************************************************
*
* Converting HTML codes generated by browser control (internet explorer) in noteformformat.scx form to codes for XFRX 17.1
*
* https://eqeuscom.atlassian.net/wiki/pages/viewpage.action?pageId=70654179
*
*****************************************************************************************************************************
*
****************************************
* BEGIN Converting HTML codes for XFRX *
****************************************
*
PROCEDURE FNReplaceHTMLTag
LPARAMETERS lp_cHTML
LOCAL l_nLines, i, l_cResult
LOCAL ARRAY l_aLines(1)

l_cResult = ""
l_nLines = ALINES(l_aLines, lp_cHTML)
FOR i = 1 TO l_nLines
     l_cLine = l_aLines(i)
     l_cLine = STRTRAN(l_cLine, "<P>", "")
     l_cLine = STRTRAN(l_cLine, "<P align=left>", "")
     l_cLine = STRTRAN(l_cLine, "<P align=right>", "")
     l_cLine = STRTRAN(l_cLine, "<P align=center>", "")
     l_cLine = STRTRAN(l_cLine, "</P>", "")
     l_cLine = STRTRAN(l_cLine, "<STRONG>", "<b>")
     l_cLine = STRTRAN(l_cLine, "</STRONG>", "</b>")
     l_cLine = STRTRAN(l_cLine, "<EM>", "<i>")
     l_cLine = STRTRAN(l_cLine, "</EM>", "</i>")
     l_cLine = STRTRAN(l_cLine, "<U>", "<u>")
     l_cLine = STRTRAN(l_cLine, "</U>", "</u>")
     l_cLine = STRTRAN(l_cLine, "&nbsp;", "")
     l_cLine = FNReplaceFONTTag(l_cLine)

     l_cResult = l_cResult + l_cLine + CHR(13) + CHR(10)
ENDFOR

RETURN l_cResult
ENDPROC
*
PROCEDURE FNReplaceFONTTag
LPARAMETERS lp_cLine
LOCAL l_cLine, i, l_cFontAttributes, l_cFontTag, l_cNewBeginTag, l_cNewEndTag
LOCAL ARRAY l_FontsFound(1)
l_cLine = lp_cLine
l_nFontsFound = OCCURS("<FONT ", l_cLine)
i = 0
IF l_nFontsFound = 0
     RETURN l_cLine
ENDIF
DO WHILE i < l_nFontsFound
     i = i + 1
     l_cFontAttributes = STREXTRACT(l_cLine, "<FONT ", ">", i)
     DIMENSION l_FontsFound(i)
     l_FontsFound(i) = l_cFontAttributes
ENDDO

IF i > 0
     FOR i = 1 TO ALEN(l_FontsFound)
          l_cFontAttributes = l_FontsFound(i)
          l_cFontTag = "<FONT " + l_cFontAttributes + ">"

          FNGetStylesFONTTag(@l_cNewBeginTag, @l_cNewEndTag, l_cFontAttributes)
          l_cLine = STRTRAN(l_cLine, l_cFontTag, l_cNewBeginTag,1,1)
          l_cLine = STRTRAN(l_cLine, "</FONT>", l_cNewEndTag,1,1)

     ENDFOR
ENDIF

RETURN l_cLine
ENDPROC
*
PROCEDURE FNGetStylesFONTTag
LPARAMETERS lp_cNewBeginTag, lp_cNewEndTag, lp_cFontAttributes
LOCAL l_nNumberOfProps, l_nProp, l_nPos, l_cProp, l_nPosNext, i, l_cChar, l_nPosEnd, l_cValue, l_nNewSize, l_nFontSize
lp_cNewBeginTag = ""
lp_cNewEndTag = ""
l_nNumberOfProps = OCCURS("=", lp_cFontAttributes)
l_nProp = 0

FOR l_nProp = 1 TO l_nNumberOfProps
     l_nPos = AT("=", lp_cFontAttributes,1)
     l_cProp = SUBSTR(lp_cFontAttributes,1,l_nPos-1)
     l_nPosNext = AT("=", lp_cFontAttributes,2)
     IF l_nPosNext > 0
          FOR i = l_nPosNext TO 1 STEP -1
               l_cChar = SUBSTR(lp_cFontAttributes,i,1)
               IF l_cChar = " "
                    l_nPosEnd = i
                    EXIT
               ENDIF
          ENDFOR
     ELSE
          l_nPosEnd = LEN(lp_cFontAttributes)
     ENDIF
     
     l_cValue = ALLTRIM(SUBSTR(lp_cFontAttributes,l_nPos+1,l_nPosEnd-l_nPos))
     lp_cFontAttributes = SUBSTR(lp_cFontAttributes, l_nPosEnd+1)

     DO CASE
          CASE l_cProp = "style" AND "BACKGROUND-COLOR:" $ l_cValue
               lp_cNewBeginTag = lp_cNewBeginTag + "<h=" + ALLTRIM(STREXTRACT(l_cValue, ["BACKGROUND-COLOR:], ["], 1)) + ">"
               lp_cNewEndTag = "</h>" + lp_cNewEndTag
          CASE l_cProp = "color"
               lp_cNewBeginTag = lp_cNewBeginTag + "<color=" + l_cValue + ">"
               lp_cNewEndTag = "</color>" + lp_cNewEndTag
          CASE l_cProp = "size"
               * We must translate fontsize from internet explorer to real font sizes
               * size 1 - 8, 9
               * size 2 - 10, 11
               * size 3 - 12, 14, 16, 18, 
               * size 4 - 20, 22
               * size 5 - 24, 26, 28
               * size 6 - 36
               * size 7 - 48, 72
               l_nFontSize = INT(VAL(l_cValue))
               l_nNewSize = 8
               DO CASE
                    CASE l_nFontSize = 2
                         l_nNewSize = 10
                    CASE l_nFontSize = 3
                         l_nNewSize = 12
                    CASE l_nFontSize = 4
                         l_nNewSize = 20
                    CASE l_nFontSize = 5
                         l_nNewSize = 24
                    CASE l_nFontSize = 6
                         l_nNewSize = 36
                    CASE l_nFontSize = 7
                         l_nNewSize = 48
               ENDCASE
               lp_cNewBeginTag = lp_cNewBeginTag + "<fontsize=" + TRANSFORM(l_nNewSize) + ">"
               lp_cNewEndTag = "</fontsize>" + lp_cNewEndTag
          CASE l_cProp = "face"
               lp_cNewBeginTag = lp_cNewBeginTag + "<fontname=" + l_cValue + ">"
               lp_cNewEndTag = "</fontname>" + lp_cNewEndTag
     ENDCASE
ENDFOR

RETURN .T.
ENDPROC
****************************************
* END   Converting HTML codes for XFRX *
****************************************
*
PROCEDURE FNHTTPSendExternal
LPARAMETERS lp_cRequest, lp_cResponse, lp_cError, lp_cServerOrParamFile, lp_cProxy, lp_lLogIt, lp_cMethod, lp_cUserID, lp_cPassword
LOCAL l_lSuccess, l_cResult, l_cCmd, l_cServer, l_cParamFile, l_cXMLFileName, l_cStatus

lp_cError = ""
lp_cResponse = ""
l_cStatus = ""
l_cXMLFileName = CFGetGuid()+".xml"
l_cXMLFileName = FULLPATH(ADDBS(SYS(2023))+l_cXMLFileName)
STRTOFILE(lp_cRequest,l_cXMLFileName,0)
IF PCOUNT() > 4
     l_cServer = lp_cServerOrParamFile
     TEXT TO l_cCmd TEXTMERGE NOSHOW PRETEXT 15
     <<FULLPATH("citadelhttp.exe")>> <<l_cServer>> <<l_cXMLFileName>> <<EVL(lp_cMethod,"POST")>> <<EVL(lp_cProxy,"NO_PROXY")>> text/xml GET_RESPONSE_INFO <<IIF(lp_lLogIt, "LOG_HTTP DEBUG", "NO_LOG NO_DEBUG")>> <<EVL(lp_cUserID, "NO_USER")>> <<EVL(lp_cPassword, "NO_PASS")>>
     ENDTEXT
ELSE
     l_cParamFile = lp_cServerOrParamFile
     TEXT TO l_cCmd TEXTMERGE NOSHOW PRETEXT 15
     <<FULLPATH("citadelhttp.exe")>> <<l_cParamFile>> <<l_cXMLFileName>>
     ENDTEXT
ENDIF

l_lSuccess = .T.

l_cResult = CFExecCommand(l_cCmd)
IF NOT EMPTY(l_cResult)
     l_cStatus = ALLTRIM(STREXTRACT(l_cResult, "___@@@___", "___###___"))
ENDIF

IF EMPTY(l_cResult) OR "getaddrinfow" $ l_cResult OR "no such host" $ l_cResult OR l_cStatus <> "200"
     lp_cError = "HTTP connect error! (1)" + CHR(13) + l_cResult
     l_lSuccess = .F.
ENDIF

IF l_lSuccess
     lp_cResponse = STREXTRACT(l_cResult, "", "___@@@___")
ENDIF

DELETE FILE (l_cXMLFileName)
IF NOT EMPTY(l_cParamFile)
     DELETE FILE (l_cParamFile)
ENDIF

RETURN l_lSuccess
ENDPROC
*