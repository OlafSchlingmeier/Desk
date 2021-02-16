* Used in deskserver.exe as entry point.

#INCLUDE "common\progs\cryptor.h"
#INCLUDE "include\constdefines.h"
#INCLUDE "include\registry.h"
*
** TEST **
*
LPARAMETERS lp_cCmd, lp_lXML, lp_lCom, lp_cCur, lp_cMethod, lp_cParam1, lp_cParam2, lp_cParam3, lp_cParam4, lp_cParam5, lp_cParam6, lp_cParam7, lp_cParam8, lp_lOpenFiles
IF EMPTY(lp_cCur)
     lp_cCur = "rec1"
ENDIF

SET ASSERTS ON
*ASSERT .f.
* Example:
* Create COM Server, use XML:
* procdeskserver("CREATE_DESKSERVER",.T.,.T.)
* Create fox object:
* procdeskserver("CREATE_DESKSERVER",.T.,.F.)
* procdeskserver("RESERVAT_GETALLCURSORSTEST")
* Checkout with balance for rs_rsid = 24556:
* procdeskserver("CHECKOUT",,,,,"24556",.T.)
* procdeskserver("UGOS_IMPORT_EVENT")
* procdeskserver("CHECKRIGHT",,,,,"View",9,.T.)   && Visible Roomplan menu
* procdeskserver("CHECKRIGHT",,,,,"ButHous",1)    && Clean button in housekeeping
* procdeskserver("RESERVAT_ROOMPLANGET",,,,,"D|"+PDSDateToString(date(2010,7,5)),"C|","C|","N|7","N|1","C|")
* procdeskserver("RESERVAT_ROOMPLANGET",,,,,"D|"+PDSDateToString(date(2010,7,5)),"C|","C|","N|1","N|2","C|")

DO CASE

     CASE TRANSFORM(lp_cCmd)="CREATE_DESKSERVER"
          PUBLIC g_ods
          IF lp_lCom
               g_ods = CREATEOBJECT("citadel.cdeskserver")
               = COMARRAY(g_ods, 11)
          ELSE
               IF NOT "procdeskserver" $ LOWER(SET("Procedure"))
                    SET PROCEDURE TO procdeskserver ADDITIVE
               ENDIF

               g_ods = NEWOBJECT("cdeskserver","progs\procdeskserver.prg")
          ENDIF
     *!*     PROCEDURE Start(lp_cSignature AS String, lp_cUserId AS String, lp_cPassword AS String, ;
     *!*               lp_cCashier AS String, lp_cExportType AS String, lp_cPrepareCursorStructure AS String, lp_cInstanceId AS String, ;
     *!*               lp_cNoLogOutTimer AS String, lp_cUseExclusive AS String) AS String

          * Open all tables exclusive, only not license.dbf:
          *? g_ods.start("d0b02830-e8e3-11df-9492-0800200c9a66","AUDIT","","1",IIF(lp_lXML,"XML",""),IIF(lp_lXML,"1",""),,,"1")

          *? g_ods.start("d0b02830-e8e3-11df-9492-0800200c9a66","IOP","123","1",IIF(lp_lXML,"XML",""),IIF(lp_lXML,"1",""))

           *? g_ods.start("d0b02830-e8e3-11df-9492-0800200c9a66","FR","","1",IIF(lp_lXML,"XML",""),IIF(lp_lXML,"1",""))
          *? g_ods.start("d0b02830-e8e3-11df-9492-0800200c9a66","FR","","1",,,,,"","d:\keza\code\main\desk910")
          *? g_ods.start("d0b02830-e8e3-11df-9492-0800200c9a66","SUPERVISOR",SYS(2007,TRANSFORM(2010*2+7+5)),"1",,,,,"","",.T.)
          ? g_ods.start("d0b02830-e8e3-11df-9492-0800200c9a66", "FR", SYS(2007,""),,,, "2CCCA3C3-F06D-4118-8033-7E76CF83305A",,,,.T.,lp_lOpenFiles)
          TRY
          ? "Hotel datum: " + TRANSFORM(EVALUATE(GETWORDNUM(g_ods.do("EVALUATE","C|g_sysdate"),2,"|")))
          ? "Log: " + TRANSFORM(EVALUATE(GETWORDNUM(g_ods.do("EXECCMD","C|= loGdata('"+"Started on "+TRANSFORM(DATETIME())+"', 'deskserver.log')"),2,"|")))
          CATCH
          ENDTRY
     CASE TRANSFORM(lp_cCmd)="UGOS_IMPORT_EVENT"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ougosimport')")<>"O"
               g_ods.do("CREATEOBJECT","ougosimport","ttimerbasedprocesses","libs\cit_system.vcx")
          ENDIF
          ? g_ods.do("USEOBJECT","ougosimport","ImportPatients")
     CASE TRANSFORM(lp_cCmd)="CHECKOUT"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF NOT EMPTY(lp_cParam2)
               ? g_ods.Do("CHECKOUT","N|"+lp_cParam1, "L|"+TRANSFORM(lp_cParam2))
          ELSE
               ? g_ods.Do("CHECKOUT","N|"+lp_cParam1)
          ENDIF
     CASE TRANSFORM(lp_cCmd)="CHECKRIGHT"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          *? g_ods.Do("CHECKRIGHT","C|View", "N|9", "L|.T.")     && Visible Roomplan menu
          *? g_ods.Do("CHECKRIGHT","C|ButHous", "N|1", "L|.F.")  && Clean button in housekeeping
          ? g_ods.Do("CHECKRIGHT","C|"+lp_cParam1, "N|"+TRANSFORM(lp_cParam2), "L|"+TRANSFORM(lp_cParam3))
     CASE TRANSFORM(lp_cCmd)="HOTELSTAT"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.oHs')")<>"O"
               g_ods.do("CREATEOBJECT","oHs","chotelstat","progs\procavailability.prg")
          ENDIF
          
          IF USED("g1")
               USE IN g1
          ENDIF
          IF USED("g2")
               USE IN g2
          ENDIF

          *? g_ods.do("USEOBJECT","oHs","ListGet","D|{^2011-11-18}","N|10")
          ? g_ods.do("USEOBJECT","oHs","ListGet",lp_cParam1,lp_cParam2)
          l_cTable = g_ods.do("GETPROPERTY","oHs","cResultTable")
          l_cTable = GETWORDNUM(l_cTable,2,"|")
          l_cTableProps = g_ods.do("GETPROPERTY","oHs","cResultEvent")
          l_cTableProps = GETWORDNUM(l_cTableProps,2,"|")
          IF lp_lXML
               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR g1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,l_cTable,g_ods.cxmLTABLE)

               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR g2 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,l_cTableProps,g_ods.cxmLTABLE)

          ELSE
               USE (l_cTable) IN 0 ALIAS g1 SHARED
               USE (l_cTableProps) IN 0 ALIAS g2 SHARED
          ENDIF

          BROWSE LAST NOWAIT
     CASE TRANSFORM(lp_cCmd)="AVAILAB"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.oav')")<>"O"
               g_ods.do("CREATEOBJECT","oav","cavailability","progs\procavailability.prg")
          ENDIF
          
          IF USED("g1")
               USE IN g1
          ENDIF
          IF USED("g2")
               USE IN g2
          ENDIF

          *? g_ods.do("USEOBJECT","oav","ListGet","D|{^2010-7-1}","N|30")
          ? g_ods.do("USEOBJECT","oav","ListGet",lp_cParam1,lp_cParam2)
          IF lp_lXML
               l_cTable = g_ods.do("GETPROPERTY","oav","cResultAvailab")
               l_cTable = GETWORDNUM(l_cTable,2,"|")

               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR g1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,l_cTable,g_ods.cxmLTABLE)

               l_cTableProps = g_ods.do("GETPROPERTY","oav","cresulttable")
               l_cTableProps = GETWORDNUM(l_cTableProps,2,"|")

               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR g1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,l_cTable,g_ods.cxmLTABLE)

          ELSE
               l_cTable = g_ods.do("GETPROPERTY","oav","cResultAvailab")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               USE (l_cTable) IN 0 ALIAS g1 SHARED

               l_cTableProps = g_ods.do("GETPROPERTY","oav","cresulttable")
               l_cTableProps = GETWORDNUM(l_cTableProps,2,"|")

               USE (l_cTableProps) IN 0 ALIAS g2 SHARED


          ENDIF

          BROWSE LAST NOWAIT
     CASE TRANSFORM(lp_cCmd)="HOUSEKEEPING_LISTGET"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ohk')")<>"O"
               g_ods.do("CREATEOBJECT","ohk","chousekeeping","progs\procroom.prg")
          ENDIF

          IF USED("h1")
               USE IN h1
          ENDIF

          ? g_ods.do("USEOBJECT","ohk","ListGet")

          SELECT 0
          IF lp_lXML
               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR g1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,"g1",g_ods.cxmLTABLE)
          ELSE
               l_cTable = g_ods.do("GETPROPERTY","ohk","cresulttable")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               USE (l_cTable) SHARED ALIAS h1
          ENDIF
          BROWSE LAST NOWAIT
     CASE TRANSFORM(lp_cCmd)="HOUSEKEEPING_RECGET"
          IF USED("hrec1")
               USE IN hrec1
          ENDIF

          ? g_ods.do("USEOBJECT","ohk","RecGet","C|"+h1.rm_roomnum)

          SELECT 0
          IF g_ods.cExportType = "XML"
               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR rec1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,"rec1",g_ods.cxmLTABLE)
          ELSE
               l_cTable = g_ods.do("GETPROPERTY","ohk","cresulttable")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               SELECT 0
               USE (l_cTable) SHARED ALIAS hrec1
          ENDIF
          BROWSE LAST NOWAIT
     CASE TRANSFORM(lp_cCmd)="HOUSEKEEPING_RECSAVE"
          IF g_ods.cExportType = "XML"
               l_cResXML = ""
               CURSORTOXML("rec1","l_cResXML",1,32,0,"1")
               g_ods.cXML = l_cResXML
               g_ods.cXMLTable = "rec1"
          ENDIF
          lsuccess = g_ods.do("USEOBJECT","ohk","RecSave")
          lsuccess = GETWORDNUM(lsuccess,2,"|")
          IF lsuccess = ".T."
               ? lsuccess
          ELSE
               lvaliderr = g_ods.do("GETPROPERTY","ohk","lvaliderr")
               IF lvaliderr = ".T."
                    ? g_ods.do("GETPROPERTY","ohk","cvaliderr")
               ENDIF
          ENDIF

     CASE TRANSFORM(lp_cCmd)="RESERVAT_RECGET"

          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ores')")<>"O"
               g_ods.do("CREATEOBJECT","ores","cquickreser","procreservat.prg")
          ENDIF
          IF USED(lp_cCur)
               USE IN (lp_cCur)
          ENDIF
          ? g_ods.do("USEOBJECT","ores","RecGet",ALLTRIM(TRANSFORM(lp_cParam1)))
          ? IIF(GETWORDNUM(g_ods.do("GETPROPERTY","ores","csourcerequired"),2,"|")="1","Source code REQUIRED","")
          ? IIF(GETWORDNUM(g_ods.do("GETPROPERTY","ores","cmarketrequired"),2,"|")="1","Market code REQUIRED","")
          ? IIF(GETWORDNUM(g_ods.do("GETPROPERTY","ores","cpaytyperequired"),2,"|")="1","Payment code REQUIRED","")

          SELECT 0
          IF g_ods.cExportType = "XML"
               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR rec1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,lp_cCur,g_ods.cxmLTABLE)
          ELSE
               l_cTable = g_ods.do("GETPROPERTY","ores","cresulttable")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               SELECT 0
               USE (l_cTable) SHARED ALIAS (lp_cCur)
          ENDIF
          BROWSE LAST NOWAIT
     CASE TRANSFORM(lp_cCmd)="RESERVAT_RECSAVE"
          IF g_ods.cExportType = "XML"
               l_cResXML = ""
               CURSORTOXML(lp_cCur,"l_cResXML",1,32,0,"1")
               g_ods.cXML = l_cResXML
               g_ods.cXMLTable = lp_cCur
          ENDIF
          lsuccess = g_ods.do("USEOBJECT","ores","RecSave")
          lsuccess = GETWORDNUM(lsuccess,2,"|")
          IF lsuccess = ".T."
               ? lsuccess
          ELSE
               lvaliderr = g_ods.do("GETPROPERTY","ores","lvaliderr")
               lvaliderr = GETWORDNUM(lvaliderr,2,"|")
               IF lvaliderr = ".T."
                    ? g_ods.do("GETPROPERTY","ores","cvaliderr")
                    ? g_ods.do("GETPROPERTY","ores","cerrfield")
               ENDIF
          ENDIF
     CASE TRANSFORM(lp_cCmd)="RESERVAT_DATAGET"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ores')")<>"O"
               g_ods.do("CREATEOBJECT","ores","cquickreser","procreservat.prg")
          ENDIF

          IF USED(lp_cCur)
               USE IN (lp_cCur)
          ENDIF

          DO CASE
               CASE NOT EMPTY(lp_cParam3)
                    ? g_ods.do("USEOBJECT","ores",lp_cMethod,lp_cParam1, lp_cParam2, lp_cParam3)
               CASE NOT EMPTY(lp_cParam2)
                    ? g_ods.do("USEOBJECT","ores",lp_cMethod,lp_cParam1, lp_cParam2)
               CASE NOT EMPTY(lp_cParam1)
                    ? g_ods.do("USEOBJECT","ores",lp_cMethod,lp_cParam1)
               OTHERWISE
                    ? g_ods.do("USEOBJECT","ores",lp_cMethod)
          ENDCASE

          SELECT 0
          IF g_ods.cExportType = "XML"
               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR rec1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,lp_cCur,g_ods.cxmLTABLE)
          ELSE
               l_cTable = g_ods.do("GETPROPERTY","ores","cresulttable")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               SELECT 0
               USE (l_cTable) SHARED ALIAS (lp_cCur)
          ENDIF
          BROWSE LAST NOWAIT

     CASE TRANSFORM(lp_cCmd)="RESERVAT_GETALLCURSORSTEST"

          *Example to create reservation:
          *DO procdeskserver WITH "CREATE_DESKSERVER"
          *DO procdeskserver WITH "CREATE_DESKSERVER",,.T.
          DO procdeskserver WITH "RESERVAT_GETPROPERTIES"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"cursource","SourceCodesGet"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"curmarket","MarketCodesGet"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"curresstatus","ResStatusGet"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"curtitles","TitlesGet"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"curcountries","CountriesGet"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"curroomrange","ConfRoomRangesGet"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"curpaymethods","PaymethodsGet"
          DO procdeskserver WITH "RESERVAT_DATAGET",,,"curstyles","StylesGet"
          
          IF g_ods.do("GETPROPERTY","ores","cbuildingson")="1"
               DO procdeskserver WITH "RESERVAT_DATAGET",,,"curbuildings","BuildingsGet"
          ELSE
               DO procdeskserver WITH "RESERVAT_DATAGET",,,"currt","RoomTypesGet"
          ENDIF
          DO procdeskserver WITH "RESERVAT_RECGET",,,"curres","",IIF(EMPTY(lp_cParam1),"",lp_cParam1)
          * User must first select building, roomtype, to receive rooms und ratecodes cursor!
          *DO procdeskserver WITH "RESERVAT_DATAGET",,,"currm","RoomTypesGet","C|"+curbuildings.bu_buildng
          *DO procdeskserver WITH "RESERVAT_DATAGET",,,"currm","RoomsGet","C|"+currt.rt_roomtyp,"D|"+PDSDateToString(curres.rs_arrdate),"D|"+PDSDateToString(curres.rs_depdate)
          *DO procdeskserver WITH "RESERVAT_DATAGET",,,"currc","RateCodesGet","C|"+currm.rm_roomtyp,"D|"+PDSDateToString(curres.rs_arrdate),"D|"+PDSDateToString(curres.rs_depdate)
          
          BROWSE FIELDS rs_title, rs_fname, rs_lname, rs_company, rs_country, rs_arrdate, rs_depdate, rs_roomtyp, rs_rooms, rs_adults, rs_roomnum, rs_ratecod, rs_rate, rs_note, rs_noteco, rs_source, rs_market, c_rareason
          *REPLACE rs_ratecod WITH currc.rs_ratecod, rs_roomtyp WITH currt.rt_roomtyp, rs_roomnum WITH currm.rm_roomnum IN curres
          *DO procdeskserver WITH "RESERVAT_RECSAVE",,,"curres"

     CASE TRANSFORM(lp_cCmd)="RESERVAT_LISTGET"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ores')")<>"O"
               g_ods.do("CREATEOBJECT","ores","cquickreser","procreservat.prg")
          ENDIF

          IF USED(lp_cCur)
               USE IN (lp_cCur)
          ENDIF

          DO CASE
               CASE NOT EMPTY(lp_cParam3)
                    ? g_ods.do("USEOBJECT","ores","ListGet",lp_cParam1, lp_cParam2, lp_cParam3)
               CASE NOT EMPTY(lp_cParam2)
                    ? g_ods.do("USEOBJECT","ores","ListGet",lp_cParam1, lp_cParam2)
               CASE NOT EMPTY(lp_cParam1)
                    ? g_ods.do("USEOBJECT","ores","ListGet",lp_cParam1)
               OTHERWISE
                    ? g_ods.do("USEOBJECT","ores","ListGet")
          ENDCASE

          SELECT 0
          IF lp_lXML
               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR g1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,"g1",g_ods.cxmLTABLE)
          ELSE
               l_cTable = g_ods.do("GETPROPERTY","ores","cresulttable")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               USE (l_cTable) SHARED ALIAS (lp_cCur)
          ENDIF
          BROWSE LAST NOWAIT
     CASE TRANSFORM(lp_cCmd)="RESERVAT_GETPROPERTIES"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ores')")<>"O"
               g_ods.do("CREATEOBJECT","ores","cquickreser","procreservat.prg")
          ENDIF

          l_cValue = g_ods.do("GETPROPERTY","ores","cbuildingson")
          ? "cbuildingson: "+ GETWORDNUM(l_cValue,2,"|")
          l_cValue = g_ods.do("GETPROPERTY","ores","cchild1on")
          ? "cchild1on: "+ GETWORDNUM(l_cValue,2,"|")
          l_cValue = g_ods.do("GETPROPERTY","ores","cchild1caption")
          ? "cchild1caption: "+ GETWORDNUM(l_cValue,2,"|")
          l_cValue = g_ods.do("GETPROPERTY","ores","cchild2on")
          ? "cchild2on: "+ GETWORDNUM(l_cValue,2,"|")
          l_cValue = g_ods.do("GETPROPERTY","ores","cchild2caption")
          ? "cchild2caption: "+ GETWORDNUM(l_cValue,2,"|")
          l_cValue = g_ods.do("GETPROPERTY","ores","cchild3on")
          ? "cchild3on: "+ GETWORDNUM(l_cValue,2,"|")
          l_cValue = g_ods.do("GETPROPERTY","ores","cchild3caption")
          ? "cchild3caption: "+ GETWORDNUM(l_cValue,2,"|")
     CASE TRANSFORM(lp_cCmd)="RESERVAT_RATEGET"
          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ores')")<>"O"
               g_ods.do("CREATEOBJECT","ores","cquickreser","procreservat.prg")
          ENDIF

          *DO procdeskserver WITH "RESERVAT_RATEGET",,,"","RateGet","D|"+PDSDateToString(curres.rs_arrdate),"D|"+PDSDateToString(curres.rs_depdate),"C|"+curres.rs_roomtyp,"N|"+transform(curres.rs_adults),"N|"+transform(curres.rs_childs),"N|"+transform(curres.rs_childs2),"N|"+transform(curres.rs_childs3),"C|"+curres.rs_ratecod
          ? g_ods.do("USEOBJECT","ores","RateGet",lp_cParam1, lp_cParam2, lp_cParam3, lp_cParam4, lp_cParam5, lp_cParam6, lp_cParam7, lp_cParam8)
     CASE TRANSFORM(lp_cCmd)="RESERVAT_ROOMPLANGET"
          LOCAL l_cParams

          IF NOT (TYPE("g_ods")="O" AND NOT ISNULL(g_ods))
               RETURN .F.
          ENDIF
          IF g_ods.MyEval("TYPE('this.ores')")<>"O"
               g_ods.do("CREATEOBJECT","ores","cquickreser","procreservat.prg")
          ENDIF
          *lp_cCur = "RpDaysAlias"
          lp_cRoomplan = "RpAlias"

          IF USED(lp_cCur)
               USE IN (lp_cCur)
          ENDIF
          IF USED(lp_cRoomplan)
               USE IN (lp_cRoomplan)
          ENDIF

          *RoomplanGet(<lp_dFromDate>, <lp_cRoomtype>, <lp_cBuilding>, <lp_nDays>, <lp_nConf>, <lp_cRange>)
          *DO procdeskserver WITH "RESERVAT_ROOMPLANGET",,,,,"D|"+PDSDateToString(date(2010,7,1)),"C|@AAK","C|EZ","N|10"
          *DO procdeskserver WITH "RESERVAT_ROOMPLANGET",,,,,"D|"+PDSDateToString(date(2010,7,5)),"C|","C|","N|7","N|1","C|"
          l_cParams = ""
          FOR i = 1 TO PCOUNT()-5
               l_cParams = l_cParams + ",lp_cParam" + TRANSFORM(i)
          NEXT
          ? g_ods.do("USEOBJECT","ores","RoomplanGet" &l_cParams)

          IF lp_lXML
               l_aXML = .F.
               DIMENSION l_aXML(1,18)
               g_ods.getxmltablestructarray(@l_aXML)
               CREATE CURSOR g1 FROM ARRAY l_aXML
               l_owwXML = NEWOBJECT("wwxml",LOCFILE("wwxml.vcx"))
               ? l_owwXML.DataSetXMLToCursor(g_ods.cxmL,"g1",g_ods.cxmLTABLE)
          ELSE
               l_cTable = g_ods.do("GETPROPERTY","ores","cCurRoomplan")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               USE (l_cTable) IN 0 ALIAS (lp_cRoomplan) SHARED
               l_cTable = g_ods.do("GETPROPERTY","ores","cresulttable")
               l_cTable = GETWORDNUM(l_cTable,2,"|")
               USE (l_cTable) IN 0 ALIAS (lp_cCur) SHARED
          ENDIF
          BROWSE LAST NOWAIT
     CASE TRANSFORM(lp_cCmd)="RESERVAT_RESCHECKIN"
          *RoomplanGet(<lp_nRsId>)
          *DO procdeskserver WITH "CREATE_DESKSERVER"
          *DO procdeskserver WITH "RESERVAT_RESCHECKIN",,,,,"N|1469"
          IF g_ods.cExportType = "XML"
               l_cResXML = ""
               CURSORTOXML(lp_cCur,"l_cResXML",1,32,0,"1")
               g_ods.cXML = l_cResXML
               g_ods.cXMLTable = lp_cCur
          ENDIF
          IF g_ods.MyEval("TYPE('this.ores')")<>"O"
               g_ods.do("CREATEOBJECT","ores","cquickreser","procreservat.prg")
          ENDIF
          lsuccess = g_ods.do("USEOBJECT","ores","ResCheckIn",lp_cParam1)
          lsuccess = GETWORDNUM(lsuccess,2,"|")
          IF lsuccess = ".T."
               ? lsuccess
          ELSE
               lvaliderr = g_ods.do("GETPROPERTY","ores","lvaliderr")
               lvaliderr = GETWORDNUM(lvaliderr,2,"|")
               IF lvaliderr = ".T."
                    ? g_ods.do("GETPROPERTY","ores","cvaliderr")
               ENDIF
          ENDIF
     CASE TRANSFORM(lp_cCmd)="BILL_ACTION"
          * [{"action":"procbill_checkout","debug":false,"param1":2156}]
          ? g_ods.DoBillAction(lp_cParam1)
ENDCASE

ENDPROC
*
PROCEDURE PDSIsDataBaseBlocked
LOCAL l_cFile, l_lBlocked, l_nHandle
l_lBlocked = .F.
l_cFile = gcDatadir + C_COMSERVERS_BLOCK_FILE
IF FILE(l_cFile)
     l_nHandle = FOPEN(l_cFile)
     IF l_nHandle < 0
          * Logout cmd detected
          l_lBlocked = .T.
     ELSE
        FCLOSE(l_nHandle)
     ENDIF
ENDIF
RETURN l_lBlocked
ENDPROC
*
PROCEDURE PDSDateToString
LPARAMETERS lp_dDate
RETURN "{^"+TRANSFORM(YEAR(lp_dDate))+"-"+TRANSFORM(MONTH(lp_dDate))+"-"+TRANSFORM(DAY(lp_dDate))+"}"
ENDPROC
*********************************
* FAKE functions, for build exe *
******************************* *
*!*     PROCEDURE EMCREATEMESSAGE
*!*     ENDPROC
*!*     PROCEDURE EMADDRECIPIENT
*!*     ENDPROC
*!*     PROCEDURE EMADDATACHMENT
*!*     ENDPROC
*!*     PROCEDURE EMADDATTACHMENT
*!*     ENDPROC
*!*     PROCEDURE EMDISPLAY
*!*     ENDPROC
*!*     PROCEDURE EMSEND
*!*     ENDPROC
*!*     PROCEDURE MYPOPUP
*!*     ENDPROC
*!*     PROCEDURE CHECKWIN
*!*     ENDPROC
*!*     PROCEDURE ERRORSYS
*!*     ENDPROC
*!*     PROCEDURE creatinx
*!*     ENDPROC
*!*     PROCEDURE CLEANUP
*!*     ENDPROC
*!*     PROCEDURE CHECKNETID
*!*     ENDPROC
*!*     PROCEDURE MAIN
*!*     ENDPROC
*!*     PROCEDURE PASSERBY
*!*     ENDPROC
*!*     PROCEDURE DIALOG
*!*     ENDPROC
*!*     PROCEDURE ERRORMSG
*!*     ENDPROC
*!*     PROCEDURE DOFORM
*!*     ENDPROC
*!*     PROCEDURE SETSTATUS
*!*     ENDPROC
*!*     PROCEDURE SIZEDATE
*!*     ENDPROC
*!*     PROCEDURE PIXH
*!*     ENDPROC
*!*     PROCEDURE MYBROWSE
*!*     ENDPROC
*!*     PROCEDURE XSETVAR
*!*     ENDPROC
*!*     PROCEDURE SPLITPST
*!*     ENDPROC
*!*     PROCEDURE GROUPBIL
*!*     ENDPROC
*!*     PROCEDURE VPAYMETH
*!*     ENDPROC
********************************

PROCEDURE DeskServerError
LPARAMETERS nError, cMethod, nLine

#DEFINE CRLF          CHR(13)+CHR(10)
LOCAL llShowErrorMessage, lcErrorMsg, lcErrorDescription, lcCallStack, lnStackCount, lcProgram, l_cError
LOCAL ARRAY laError(1)

AERROR(laError)

DO CASE
     CASE nError = 5
          llShowErrorMessage = .F.
     CASE nError = 38
          llShowErrorMessage = .F.
     CASE nError = 4
          llShowErrorMessage = .F.
     CASE nError = 1108
          llShowErrorMessage = .F.
     OTHERWISE
          llShowErrorMessage = .T.
ENDCASE

IF NOT llShowErrorMessage
     RETURN .T.
ENDIF

l_cError = ON("Error")
*ON ERROR *
IF BETWEEN(nError, 1427, 1429) OR nError = 1526
     lcErrorMsg = TRANSFORM(nError)+" "+TRANSFORM(laError(3))
ELSE
     lcErrorMsg = TRANSFORM(nError)+" "+MESSAGE()
ENDIF

lcErrorDescription = "Procedure: " + TRANSFORM(cMethod) + CRLF + ;
          "Line: " + TRANSFORM(nLine) + CRLF + ;
          "1:" + TRANSFORM(laError(1)) + CRLF + ;
          "2:" + TRANSFORM(laError(2)) + CRLF + ;
          IIF(EMPTY(TRANSFORM(NVL(laError(3),""))),"","3:" + TRANSFORM(NVL(laError(3),"")) + CRLF) + ;
          IIF(EMPTY(TRANSFORM(NVL(laError(4),""))),"","4:" + TRANSFORM(NVL(laError(4),"")) + CRLF) + ;
          IIF(EMPTY(TRANSFORM(NVL(laError(5),""))),"","5:" + TRANSFORM(NVL(laError(5),"")) + CRLF) + ;
          IIF(EMPTY(TRANSFORM(NVL(laError(6),""))),"","6:" + TRANSFORM(NVL(laError(6),"")) + CRLF) + ;
          IIF(EMPTY(TRANSFORM(NVL(laError(7),""))),"","7:" + TRANSFORM(NVL(laError(7),"")) + CRLF)

lnStackCount = 1
lcCallStack = ""
lcProgram = PROGRAM()
DO WHILE PROGRAM(lnStackCount) <> lcProgram
     lcCallStack = lcCallStack + PROGRAM(lnStackCount) + " "
     lnStackCount = lnStackCount + 1
ENDDO

lcErrorMsg = TTOC(DATETIME()) + " ::" + _VFP.ServerName + ":: " +  CRLF + lcErrorMsg + CRLF
lcErrorMsg = lcErrorMsg + lcErrorDescription + ALLTRIM(lcCallStack) + CRLF + CRLF

STRTOFILE(lcErrorMsg, "deskserver.err", .T.)

*ON ERROR &l_cError

IF Application.StartMode = 0
     SET STEP ON
     IF .F.
          RETRY          && Step here in debuger, to retry program execution
     ENDIF
ENDIF
*COMRETURNERROR("DeskServer",lcErrorMsg)

*this.chaserror = ".T."
*this.cError = this.cError + lcErrorMsg + "|"
*RETURN TO MASTER



RETURN .T.
ENDPROC
*
DEFINE CLASS cdeskserver AS Session OLEPUBLIC
*
HIDDEN cCashier, lsigned, cinstanceid, oLogOutTmr, lNoLogOutTimer
*
DIMENSION axmltablestruct(1,18) && AFIELDS array for XML table structure
cmsg = ""
cerror = ""
chaserror = ""
cUserId = "FIASIFC"
cPassword = ""
lPasswordEncrypted = .F.
lGuest = .F.
UserName = ""
UserLangCode = ""
VerificationCode = ""
cBookingOfferJSONString = ""
cXSRFToken = ""
cCashier = ""
lsigned = .F.
lshowerror = .F.
cExportType = "" && DBF, XML
cxml = "" && Used to set/get XML in BizObjs
cxmltable = "" && Table name in exported XML dataset
lPrepareCursorStructure = .F. && When cursor is sent as XML, send table structure witn AFIELDS
cinstanceid = ""
oLogOutTmr = .NULL.
nLastLive = 0
nSessionIdleTime = 60 && IdleTime - (Release DskServer after X minutes) Default is 60 minutes
lNoLogOutTimer = .F.
lUseExclusive = .F.
cCustomDefaultPath = ""
lOpenFiles = .F.
lUnattendedServerMode = .F.
lUseLicense = .F.

DIMENSION cxml_COMATTRIB[4]
cxml_COMATTRIB[2] = "XML with cursor data, IN and OUT"
cxml_COMATTRIB[3] = "cxml"  && Proper capitalization.
cxml_COMATTRIB[4] = "String"        && Data type

DIMENSION cxmltable_COMATTRIB[4]
cxmltable_COMATTRIB[2] = "Name of table in XML data set"
cxmltable_COMATTRIB[3] = "cxmltable"  && Proper capitalization.
cxmltable_COMATTRIB[4] = "String"        && Data type

DIMENSION cmsg_COMATTRIB[4]
cmsg_COMATTRIB[2] = "Last message from messagebox"
cmsg_COMATTRIB[3] = "cmsg"  && Proper capitalization.
cmsg_COMATTRIB[4] = "String"        && Data type

DIMENSION cerror_COMATTRIB[4]
cerror_COMATTRIB[2] = "Last error message"
cerror_COMATTRIB[3] = "cerror"  && Proper capitalization.
cerror_COMATTRIB[4] = "String"        && Data type

DIMENSION chaserror_COMATTRIB[4]
chaserror_COMATTRIB[2] = "Error occured when returns '.T.'"
chaserror_COMATTRIB[3] = "chaserror"  && Proper capitalization.
chaserror_COMATTRIB[4] = "String"        && Data type

*
Datasession = 2
*
HIDDEN PROCEDURE Init
SET PATH TO 'data'
RETURN .T.
ENDPROC
*
PROCEDURE Release
IF VARTYPE(g_oBillFormSet)="O"
     g_oBillFormSet.Release()
     g_oBillFormSet = .NULL.
ENDIF
ON ERROR *
ON SHUTDOWN
RELEASE this
ENDPROC
*
PROCEDURE Start(lp_cSignature AS String, lp_cUserId AS String, lp_cPassword AS String, ;
          lp_cCashier AS String, lp_cExportType AS String, lp_cPrepareCursorStructure AS String, lp_cInstanceId AS String, ;
          lp_cNoLogOutTimer AS String, lp_cUseExclusive AS String, lp_cCustomDefaultPath AS String, lp_lPasswordEncrypted AS Logical, ;
          lp_lOpenFiles AS Logical, lp_lUnattendedServerMode AS Logical, lp_lUseLicense AS Logical) AS String
LOCAL loTypeLib, l_lSuccess, l_cInstanceId
IF EMPTY(lp_cSignature)
     RETURN ""
ENDIF
IF NOT ALLTRIM(TRANSFORM(lp_cSignature)) == DS_SIGNATURE
     RETURN ""
ENDIF

this.lSigned = .T.
this.lPasswordEncrypted = lp_lPasswordEncrypted

ON ERROR DO DeskServerError WITH ERROR(),PROGRAM(),LINENO() IN progs\procdeskserver.prg

IF NOT EMPTY(lp_cUserId)
     this.cUserId = ALLTRIM(TRANSFORM(lp_cUserId))
ENDIF
IF NOT EMPTY(lp_cPassword)
     this.cPassword = ALLTRIM(TRANSFORM(lp_cPassword))
ENDIF
IF NOT EMPTY(lp_cCashier)
     this.cCashier = ALLTRIM(TRANSFORM(lp_cCashier))
ENDIF
IF TRANSFORM(lp_cExportType)="XML"
     this.cExportType = "XML"
ELSE
     this.cExportType = "DBF"
ENDIF
IF TRANSFORM(lp_cPrepareCursorStructure)="1"
     this.lPrepareCursorStructure = .T.
ENDIF
IF EMPTY(lp_cInstanceId)
     loTypeLib = CREATEOBJECT("Scriptlet.TypeLib")
     l_cInstanceId = STREXTRACT(loTypeLib.Guid,"{","}")
     loTypeLib = .NULL.
ELSE
     l_cInstanceId = lp_cInstanceId
ENDIF

IF TRANSFORM(lp_cNoLogOutTimer)="1"
     this.lNoLogOutTimer = .T.
ENDIF
IF TRANSFORM(lp_cUseExclusive)="1"
     this.lUseExclusive = .T.
ENDIF
IF LEN(TRANSFORM(lp_cCustomDefaultPath))>3
     this.cCustomDefaultPath = ALLTRIM(TRANSFORM(lp_cCustomDefaultPath))
ENDIF
IF lp_lOpenFiles
     this.lOpenFiles = .T.
ENDIF
IF lp_lUseLicense
     this.lUseLicense = .T.
ENDIF
IF lp_lUnattendedServerMode
     this.lUnattendedServerMode = .T.
ENDIF
l_lSuccess = this.StartInit()
IF l_lSuccess
     this.cInstanceId = l_cInstanceId
     RETURN this.cInstanceId
ELSE
     this.lSigned = .F.
     CLOSE TABLES ALL
     *RELEASE this
     RETURN ""
ENDIF
ENDPROC
*
PROCEDURE Reset(lp_cSignature AS String, lp_cInstanceId AS String) AS String
LOCAL loTypeLib, l_cInstanceId

this.lSigned = ALLTRIM(TRANSFORM(lp_cSignature)) == DS_SIGNATURE
IF NOT this.lSigned
     RETURN ""
ENDIF

IF EMPTY(lp_cInstanceId)
     loTypeLib = CREATEOBJECT("Scriptlet.TypeLib")
     l_cInstanceId = STREXTRACT(loTypeLib.Guid,"{","}")
     loTypeLib = .NULL.
ELSE
     l_cInstanceId = lp_cInstanceId
ENDIF

this.cInstanceId = l_cInstanceId

RETURN this.cInstanceId
ENDPROC
*
HIDDEN PROCEDURE StartInit
PUBLIC g_lAutomationMode
g_lAutomationMode = .T.

IF TYPE("_screen.oGlobal")="O" AND NOT ISNULL(_screen.oGlobal)
     _screen.RemoveObject("oGlobal")
ENDIF
_screen.NewObject("oGlobal","cglobal","commonclasses.prg")

this.SetDefaultPath()

this.chaserror = ""
this.cError = ""
this.cmsg = ""

this.MainInitPublics()
this.MainMiscSettings()
this.MainSetEnvSettings()
IF this.MainStartNotAllowed()
     this.MainCleanUp()
     RETURN .F.
ENDIF
this.MainInitLibs()
IF NOT ProcCryptor(CR_ENCODE) OR NOT ProcCryptor(CR_REGISTER)
     alert(getapplangtext("MAIN","DATA_ACCESS_IS_FAILED"))
     this.MainCleanUp()
     RETURN .F.
ENDIF
this.MainPrepareData()
IF NOT this.SetBaseAppSettings()
     this.MainCleanUp()
     RETURN .F.
ENDIF
this.MainPrepareDataClose()
this.MainCreateGlobalObjects()
this.MainSetDeskServerSettings()

IF NOT EMPTY(_screen.oGlobal.ccomservertempfolder) AND NOT DIRECTORY(_screen.oGlobal.ccomservertempfolder)
     MKDIR (_screen.oGlobal.ccomservertempfolder)
ENDIF
IF this.lOpenFiles
     ini(.F.,.F.,,,.T.)
     SET MULTILOCKS ON
     = openfile()
     = relations()
ELSE
     ini(.T.)
ENDIF
IF this.Setup()
     IF NOT this.Login()
          RETURN .F.
     ENDIF
ELSE
     RETURN .F.
ENDIF
IF this.lUseLicense
     IF NOT openfile(,"license")
          RETURN .F.
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainStartNotAllowed
LPARAMETERS ccOmmand, lp_lDontChangeScreen, lp_lNoCryptor
* lp_lNoCryptor - Dont register with cryptor, when calling from login form.
* Table is allready registered with cryptor.
LOCAL l_lBlocked
l_lBlocked = FILE(_screen.oGlobal.choteldir+"hotel.stop")
IF NOT l_lBlocked
     IF NOT DIRECTORY(gcDataDir)
          l_lBlocked = .T.
          this.cmsg = "No DATA dir!"
          = loGdata(TRANSFORM(DATETIME())+" "+this.cmsg, "hotel.err")
     ENDIF
ENDIF
IF NOT l_lBlocked
     IF NOT this.lUseExclusive
          IF NOT lp_lNoCryptor
               = ProcCryptor(CR_REGISTER, gcDatadir, "license")
          ENDIF
          IF NOT openfiledirect(.F.,"license")
               l_lBlocked = .T.
          ELSE
               dclose("license")
          ENDIF
          IF NOT lp_lNoCryptor
               ProcCryptor(CR_UNREGISTER, gcDatadir, "license")
          ENDIF
     ENDIF
ENDIF
IF NOT l_lBlocked
     IF NOT this.lUseExclusive
          l_lBlocked = PDSIsDataBaseBlocked()
     ENDIF
ENDIF

IF l_lBlocked
     this.cmsg = "System maintance. Try to login later."
ENDIF
RETURN l_lBlocked
ENDPROC
*
HIDDEN PROCEDURE MainCleanUp
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainPrepareData
LOCAL l_oCa AS cabase OF common\libs\cit_ca.vcx

IF openfiledirect(.F.,"param","",gcDatadir)
     sqlcursor("SELECT * FROM param", "caparam")
ENDIF
IF openfiledirect(.F.,"param2","",gcDatadir)
     * In old Versions, param2 perhaps don't exist!
     sqlcursor("SELECT * FROM param2", "caparam2")
ENDIF

openfile(.F.,"picklist")
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainPrepareDataClose
dclose("capicklist")
dclose("caparam")
dclose("caparam2")
dclose("param")
dclose("param2")
dclose("picklist")
dclose("files")
dclose("fields")
ENDPROC
*
HIDDEN PROCEDURE SetBaseAppSettings

* Put here only minimal needed settings!
* This is done before update, so new fields and tables are not yet available.
* Go to function SetupAppSettings in setup.prg, and add new settings there.

LOCAL l_nSelect
IF USED("caparam")
     l_nSelect = SELECT()
     this.SetAppVersion()
     _screen.oGlobal.RefreshTableParam()
     _screen.oGlobal.RefreshTableParam2()
     DO setsystempoint IN ini 
     IF NOT g_debug
          g_debug = _screen.oGlobal.oParam.pa_debug
     ENDIF
     g_myerrorhandle = _screen.oGlobal.oParam.pa_error
     IF EMPTY(_screen.oGlobal.oParam.pa_lang)
          g_Language = "GER"
     ELSE
          g_Language = _screen.oGlobal.oParam.pa_lang
     ENDIF
     g_Sysdate = _screen.oGlobal.oParam.pa_sysdate
     g_Langnum = "3" && Default is german
     SqlCursor("SELECT pl_numcod FROM picklist WHERE pl_label = " + SqlCnv("LANGUAGE  ",.T.) + " AND pl_charcod = " + SqlCnv(g_Language, .T.), "capicklist")
     IF RECCOUNT("capicklist") > 0
          g_Langnum = ALLTRIM(TRANSFORM(capicklist.pl_numcod))
     ENDIF
     IF (_screen.oGlobal.oParam.pa_currdec>0)
          gcCurrcy = RIGHT(REPLICATE("9", 16)+"."+REPLICATE("9", _screen.oGlobal.oParam.pa_currdec), 16)
          gcCurrcydisp = gcCurrcy
     ELSE
          gcCurrcy = REPLICATE("9", 16)
          gcCurrcydisp = REPLICATE("999"+csEp1000, 4)+"999"
     ENDIF
     SELECT(l_nSelect)
ELSE
     IF NOT g_lDevelopment
          RELEASE g_CryptorObject
     ENDIF
     *MESSAGEBOX("Can't open PARAM.DBF!"+CHR(13)+"Data is crypted or system maintenance is in progress.",16 ,"Information")
     RETURN .F.
ENDIF
ENDPROC
*
HIDDEN PROCEDURE SetAppVersion
LPARAMETERS lp_cVersion
LOCAL l_cPoint, l_cVersion
l_cVersion = GetFileVersion(APP_EXE_NAME)
g_cexeversion = l_cVersion
l_cPoint = SET("Point")
SET POINT TO "."
g_Version = VAL(ALLTRIM(GETWORDNUM(l_cVersion,1,"."))+"."+PADL(ALLTRIM(GETWORDNUM(l_cVersion,2,".")),2,"0"))
SET POINT TO l_cPoint
g_Build = VAL(ALLTRIM(GETWORDNUM(l_cVersion,3,".")))
lp_cVersion = l_cVersion
ENDPROC
*
HIDDEN PROCEDURE MainInitPublics
PUBLIC leXit
PUBLIC gcApplication
PUBLIC glTraining
PUBLIC g_Lite
PUBLIC gl_valid
PUBLIC g_totalandsuperuser
PUBLIC _reser_mode
PUBLIC ARRAY parights(260)
PUBLIC g_debug
PUBLIC g_myerrorhandle
PUBLIC g_pushkeyactive
PUBLIC g_initpath
PUBLIC g_setdef
PUBLIC g_hh
PUBLIC g_newversionactive
PUBLIC g_dobilltimer
PUBLIC g_oWinEvents
PUBLIC g_IndexOnBuffFailed
PUBLIC g_lNewConferenceActive
PUBLIC g_lBillMode, gcReportdir, gcDatadir, g_BriliantToolBar, g_buildversion, g_cittool, goTbrQuick, goTbrMain, ;
          gcTemplatedir, gcDocumentdir, g_lCheckLang
PUBLIC g_lDevelopment, g_CryptorObject, g_cWinPc, g_lLogUserActions, g_cPoint
PUBLIC g_lShips, g_lBuildings
PUBLIC g_oUserData
PUBLIC gosqlwrapper
PUBLIC g_oBridgeFunc
PUBLIC g_Version
PUBLIC g_Build
PUBLIC g_Revision
PUBLIC lnEterror
PUBLIC g_Sysdate
PUBLIC llOgin
PUBLIC g_Nscreenmode
PUBLIC glDepositflag
PUBLIC glInreport
PUBLIC glErrorinreport
PUBLIC glOutIfErrorInReport
PUBLIC g_Rptlng
PUBLIC g_Rptlngnr
PUBLIC omapi
PUBLIC ocalendar
PUBLIC roomplanactive
PUBLIC g_auditactive
PUBLIC g_lFakeResAndPost
PUBLIC g_oMsgHandler
PUBLIC g_oTmrLogOut
PUBLIC g_oTmrRelease
PUBLIC g_dBillDate
PUBLIC g_oNavigPane
PUBLIC lsYserror
PUBLIC cuSerid
PUBLIC crEaderror
PUBLIC gcCurrcy
PUBLIC gcCurrcydisp
PUBLIC glCheckout
PUBLIC g_Usergroup
PUBLIC g_Cashier
PUBLIC gcCashier
PUBLIC g_Language
g_Language = "ENG"
PUBLIC g_Langnum
PUBLIC g_Tempdir
PUBLIC g_Refreshall
PUBLIC g_Refreshcurr
PUBLIC g_Data[10, 9]
PUBLIC g_Billnum
PUBLIC g_Billname
PUBLIC g_Billcopy
PUBLIC g_Billdupl
PUBLIC g_Billstyle, g_UseBDateInStyle
PUBLIC gcButtonfunction
PUBLIC g_Demo
PUBLIC g_Lite
PUBLIC g_Hotel
PUBLIC g_Nscreenmode
PUBLIC g_Userid
PUBLIC nbUttonheight
PUBLIC gcCompany1
PUBLIC gcCompany2
PUBLIC gcCopyright
PUBLIC glPrgerror
PUBLIC gnTworowoffset
PUBLIC gnOnerowoffset
PUBLIC gnReseroffset
PUBLIC ps_departm
PUBLIC hp_departm
PUBLIC ar_departm
PUBLIC rf_departm
PUBLIC bq_departm
PUBLIC g_username
PUBLIC g_nLastFiscalBillNr
PUBLIC g_cGridFontName
PUBLIC g_nGridFontSize
PUBLIC g_oPredefinedColors
PUBLIC g_lUseCreditor
PUBLIC g_lToolBarNoCaption
PUBLIC g_lNoReadEvents
PUBLIC g_lUseNewRepExp
PUBLIC g_lUseNewRepPreview
PUBLIC g_cexeversion
PUBLIC g_cexenameandpath
PUBLIC g_myshell
PUBLIC g_initialscreenheight
PUBLIC g_oTabsToolBar
PUBLIC goDatabases, gcUseDatabase, gcHotCode
PUBLIC glAutoGeneratePoints, glAutoDiscount, g_lSpecialVersion, gcCurrcy, gcCurrcydisp, g_oBillFormSet
gcCurrcy = ""
gcCurrcydisp = ""
g_oBillFormSet = .NULL.
gcApplication = "Citadel Desk"
goDatabases = CREATEOBJECT("Collection")
gcUseDatabase = ""
gcHotCode = ""

STORE SPACE(3) TO ps_departm, hp_departm, ar_departm, rf_departm, bq_departm
g_Revision = " " && Not used, but here for compatibility reasons
g_oFP = .NULL.
g_oUserData = CREATEOBJECT("Empty")
ADDPROPERTY(g_oUserData,"cuser","")
ADDPROPERTY(g_oUserData,"cpass","")
ADDPROPERTY(g_oUserData,"lPassc",.F.)
ADDPROPERTY(g_oUserData,"ccashier","")
gosqlwrapper = NEWOBJECT("csqldef","sqlclasses.prg")
glTraining = .F.
g_IndexOnBuffFailed = 0
g_hh = .t.
g_setdef = ""
g_cWinPc = ""
g_cPoint = "," && Default set point, is changed by procedure SetSystemPoint, and used when param table is not accessable
g_pushkeyactive = .f.
g_myerrorhandle = .f. 
_reser_mode = ""
gl_valid=.f.
g_BriliantToolBar = .NULL.
gcReportdir = "Report\"
gcDatadir = "Data\"
gcTemplatedir = "Dot\"
gcDocumentdir = "Document\"
g_cittool=.null.
goTbrQuick = .NULL.
goTbrMain = .NULL.
g_oNavigPane=.null.
g_newversionactive = .T.
g_lNewConferenceActive = .T.
g_lBillMode = .T.
g_username = ""
g_nLastFiscalBillNr = 0
g_cGridFontName = "Arial"
g_nGridFontSize = 10
g_cexenameandpath = ""
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainSetEnvSettings
SET SYSFORMATS ON
SET SYSFORMATS OFF
SET DECIMALS TO 2
SET HOURS TO 24
SET DATE german
SET MARK TO .
SET CENTURY ON
SET TALK OFF
SET EXCLUSIVE OFF
SET DELETED ON
SET READBORDER ON
SET SAFETY OFF
SET POINT TO "."
SET REFRESH TO 0, 5
SET REPROCESS TO AUTOMATIC
SET AUTOSAVE ON
SET NEAR OFF
SET EXACT OFF
SET ANSI OFF
SET DEBUG OFF
SET MULTILOCKS ON
SET ENGINEBEHAVIOR 70
SET UDFPARMS TO VALUE
IF NOT g_lDevelopment
     SYS(2450,1)
     SYS(2340,1)
     IF this.lUnattendedServerMode
          SYS(2335,0)
     ENDIF
ENDIF
_screen.oGlobal.cSetCurrencyPosition = SET("Currency")
_screen.oGlobal.cSetCurrencySign = SET("Currency",1)
_screen.oGlobal.nSetDecimals = SET("Decimals")
_screen.oGlobal.nSetHours = SET("Hours")
_screen.oGlobal.cSetSeparator = SET("Separator")

SET PROCEDURE TO "progs\func.prg" && Set it here to allow calling alert funtion. We set it later again in MainSetEnvSetting function.

this.MainSetPath()

ENDPROC
*
HIDDEN PROCEDURE MainMiscSettings
DO MainMiscSettings IN main WITH this
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainSetPath
LPARAMETERS lp_cDatabaseDir
LOCAL l_cPath, l_cDataPath, l_cReportPath, l_cDotPath

* Add path to database
DO CASE
     CASE PCOUNT()>0 AND NOT EMPTY(lp_cDatabaseDir)
          gcDatadir = lp_cDatabaseDir
     CASE glTraining
          gcDatadir = APP_TRAINING_FOLDER
     CASE TYPE("g_setremotepath")=="C" AND NOT EMPTY(g_setremotepath)
          gcDatadir = LOWER(g_setremotepath)
     CASE NOT EMPTY(_screen.oGlobal.cdatabasedir)
          gcDatadir = _screen.oGlobal.cdatabasedir
     CASE NOT EMPTY(_screen.oGlobal.choteldir)
          gcDatadir = _screen.oGlobal.choteldir + "data"
     OTHERWISE
          gcDatadir = "data"
ENDCASE

gcDatadir = ADDBS(gcDatadir)

* Add path for reports, dots and documents
IF EMPTY(_screen.oGlobal.choteldir)
     IF NOT EMPTY(_screen.oGlobal.creportdir)
          gcReportdir = _screen.oGlobal.creportdir
     ENDIF
     IF NOT EMPTY(_screen.oGlobal.ctemplatedir)
          gcTemplatedir = _screen.oGlobal.ctemplatedir
     ENDIF
ELSE
     gcReportdir = _screen.oGlobal.choteldir + "report"
     gcTemplatedir = _screen.oGlobal.choteldir + "dot"
     gcDocumentdir = _screen.oGlobal.choteldir + "document"
     _screen.oGlobal.creportresultsdir = _screen.oGlobal.choteldir + "reportresults"
ENDIF
gcReportdir = ADDBS(gcReportdir)
gcTemplatedir = ADDBS(gcTemplatedir)
gcDocumentdir = ADDBS(gcDocumentdir)

l_cDataPath = LEFT(gcDatadir,LEN(gcDatadir)-1)
l_cReportPath = LEFT(gcReportdir,LEN(gcReportdir)-1)
l_cDotPath = LEFT(gcTemplatedir,LEN(gcTemplatedir)-1)

SET PATH TO l_cDataPath + "; " + l_cReportPath + "; " + l_cDotPath + "; tpos; forms; bitmap; include; libs; progs; " + ;
    "common\progs; common\libs; common\forms; common\dll; common\ffc; common\misc\xfrxlib; common\misc\ctl32; " + ;
    "common\misc\sfwtreeview"
    
g_initpath = SET("Path")

RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainInitLibs
DO MainInitLibs IN main
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainCreateGlobalObjects
LOCAL l_nSelect
_screen.oGlobal.Initialize()
SetTransactObject()
l_nSelect = SELECT()
_screen.oGlobal.RefreshTableParam2()
SELECT (l_nSelect)
IF NOT this.lNoLogOutTimer
     this.oLogOutTmr = CREATEOBJECT("clogouttmr",this)
     this.oLogOutTmr.Enabled = .T.
ENDIF
ENDPROC
*
HIDDEN PROCEDURE Setup
 * Just add new module here and in Setup.prg!!!  *
 _screen.AddProperty("liclist", "KT,DV,DP,GS,BG,TG,B2,US,OL,OR,AZE,TP,IP,IK,IT,IS,EI,SA,APS,BMS,GD,GO,BRO")
 FOR i = 1 TO GETWORDCOUNT(_screen.liclist,",")
     _screen.AddProperty(GETWORDNUM(_screen.liclist,i,","),.F.)
 NEXT
 *************************************************
 *                                               *
 * DONT FORGET TO ADD NEW MODULE IN Setup.prg!!! *
 *                                               *
 *************************************************
 _screen.oGlobal.oGData.RoomsRefresh()

* Are buildings used?
g_lBuildings = .F.
sqlcursor("SELECT COUNT(*) AS bc FROM building", "curbuildings")
IF USED("curbuildings") AND curbuildings.bc>0
     g_lBuildings = .T.
ENDIF
dclose("curbuildings")
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MainSetDeskServerSettings
*_screen.oGlobal.cBObjExportType = this.cExportType
_screen.oGlobal.oDeskServer = this
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE Login
LOCAL l_lSuccess
STORE this.cUserId TO g_userid, cuSer_id, cuSerid
IF UPPER(ALLTRIM(g_userid)) == "SUPERVISOR"
     cpAssword = this.cPassword
ELSE
     cpAssword = ALLTRIM(UPPER(this.cPassword))
ENDIF
ncAshier = INT(VAL(this.cCashier))
l_lSuccess = this.SetUserEnv()
IF l_lSuccess
     g_Cashier = ncAshier
     g_oPredefinedColors = CREATEOBJECT("CColorTunnel")
     g_oPredefinedColors.GetColors()
     this.LoginSetPaRights()
     this.SetLicenceParameters()
ENDIF
RETURN l_lSuccess
ENDPROC
*
HIDDEN PROCEDURE SetUserEnv
 LOCAL l_nSelect, l_lSuccess, l_cSupervisorPassword, l_cPassword
 l_nSelect = SELECT()
 openfile(.F.,"user")
 l_lSuccess = .T.
 IF USED("user")
      SELECT usEr
      IF this.lPasswordEncrypted
           l_cSupervisorPassword = SYS(2007,STR(YEAR(g_Sysdate)*2+MONTH(g_Sysdate)+DAY(g_Sysdate), 4))
           l_cPassword = cpAssword
      ELSE
           l_cSupervisorPassword = STR(YEAR(g_Sysdate)*2+MONTH(g_Sysdate)+DAY(g_Sysdate), 4)
           l_cPassword = SYS(2007,cpAssword)
      ENDIF
      IF this.lUseExclusive OR UPPER(ALLTRIM(g_userid)) == "SUPERVISOR" AND cpAssword == l_cSupervisorPassword
           LOCATE FOR us_id = UPPER(PADR("SUPERVISOR",10))
           l_lSuccess = NOT this.lUseExclusive OR FOUND()
      ELSE
           LOCATE FOR us_id = UPPER(PADR(g_userid,10)) AND us_pass = UPPER(PADR(l_cPassword,10))
           l_lSuccess = FOUND()
      ENDIF
      SCATTER NAME _screen.oGlobal.oUser MEMO
      ncAshier = usEr.us_cashier
      IF FOUND()
           g_Language = us_lang
      ENDIF
 ENDIF
 openfile(.F.,"group")
 openfile(.F.,"caShier")
 IF USED("group")
      SELECT grOup
      IF EMPTY(_screen.oGlobal.oUser.us_id)
           LOCATE FOR .F.
      ELSE
           LOCATE FOR grOup.gr_group==usEr.us_group
      ENDIF
      SCATTER NAME _screen.oGlobal.oGroup MEMO
      SELECT caShier
      LOCATE FOR (caShier.ca_number==ncAshier)
      IF this.lUseExclusive
           g_userid = "AUDIT"
           _screen.oGlobal.oUser.us_id = g_userid
      ENDIF
 ENDIF
 SELECT (l_nSelect)
 RETURN l_lSuccess
ENDPROC
*
HIDDEN PROCEDURE CheckRight
LPARAMETERS lp_cGroupName, lp_nItem, lp_lMenu
* Return value:     0 - don't show item; 1 - disabled item; 2 - show item (has full right)
LOCAL l_nRight, l_cField

l_cField = "gr_"+lp_cGroupName
DO CASE
     CASE UPPER(ALLTRIM(g_userid)) == "SUPERVISOR"
          l_nRight = 2
     CASE SUBSTR(_screen.oGlobal.oGroup.&l_cField, lp_nItem, 1) = "1"
          l_nRight = 2
     CASE lp_lMenu AND _screen.oGlobal.oParam.pa_covmenu
          l_nRight = 0
     OTHERWISE
          l_nRight = 1
ENDCASE

RETURN l_nRight
ENDPROC
*
HIDDEN PROCEDURE LoginSetPaRights
 EXTERNAL ARRAY parights
 LOCAL i
 STORE .F. to parights
 WITH _screen.oGlobal.oGroup
      FOR i=1 TO 16
           parights(i)=EVALUATE('VAL(SUBSTR(.gr_butrese,i,1))=1')
           parights(i+16)=EVALUATE('VAL(SUBSTR(.gr_reserva,i,1))=1')
           parights(i+32)=EVALUATE('VAL(SUBSTR(.gr_butrscr,i,1))=1')
           parights(i+48)=EVALUATE('VAL(SUBSTR(.gr_butbill,i,1))=1')
           parights(i+64)=EVALUATE('VAL(SUBSTR(.gr_butcout,i,1))=1')
           parights(i+80)=EVALUATE('VAL(SUBSTR(.gr_butrate,i,1))=1')
           parights(i+96)=EVALUATE('VAL(SUBSTR(.gr_butaddr,i,1))=1')
           parights(i+112)=EVALUATE('VAL(SUBSTR(.gr_other,i,1))=1')
           parights(i+128)=EVALUATE('VAL(SUBSTR(.gr_butadd2,i,1))=1')
           parights(i+144)=EVALUATE('VAL(SUBSTR(.gr_butplan,i,1))=1')
           parights(i+160)=EVALUATE('VAL(SUBSTR(.gr_allott,i,1))=1')
           parights(i+176)=EVALUATE('VAL(SUBSTR(.gr_btcout2,i,1))=1')
           parights(i+192)=EVALUATE('VAL(SUBSTR(.gr_conplan,i,1))=1')
           parights(i+208)=EVALUATE('VAL(SUBSTR(.gr_condayp,i,1))=1')
           parights(i+244)=EVALUATE('VAL(SUBSTR(.gr_aze,i,1))=1')
      ENDFOR
 ENDWITH
 RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE SetLicenceParameters
 LOCAL i, j, l_cLicence, l_cModule, l_cLicenceSet, l_cInterfaceModule

 l_cLicence = UPPER(STRTRAN(_screen.oGlobal.oParam.pa_lizopt," "))
 IF EMPTY(l_cLicence)
      RETURN .T.
 ENDIF
 FOR i = 1 TO GETWORDCOUNT(l_cLicence,",")
      l_cModule = ALLTRIM(GETWORDNUM(l_cLicence, i, ","))
      IF LEFT(l_cModule,1) = "I"
          l_cLicenceSet = SUBSTR(l_cModule,2)
          FOR j = 1 TO LEN(l_cLicenceSet)
               l_cInterfaceModule = SUBSTR(l_cLicenceSet,j,1)
               l_cModule = IIF(l_cInterfaceModule = "E", "EI", "I"+l_cInterfaceModule)
               IF ","+l_cModule+"," $ ","+_screen.liclist+","
                   _screen.&l_cModule = .T.
               ENDIF
          NEXT
      ELSE
          IF ","+l_cModule+"," $ ","+_screen.liclist+","
              _screen.&l_cModule = .T.
          ENDIF
      ENDIF
 NEXT
 *_screen.TP = _screen.TP AND ArgusOffice("LICENSE", "TP",,.T.)

 RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE MsgAdd
LPARAMETERS lp_cTest
this.cmsg = this.cmsg + TRANSFORM(lp_cTest)+"|"
ENDPROC
*
HIDDEN PROCEDURE SetDefaultPath
LOCAL lcDefaultPath
LOCAL ARRAY laFileVersion(1)
IF EMPTY(this.cCustomDefaultPath)
     IF Application.StartMode == 2
          lcDefaultPath = JUSTPATH(_vfp.ServerName)
          SET DEFAULT TO (lcDefaultPath)
     ENDIF
ELSE
     _screen.oGlobal.choteldir = ADDBS(ALLTRIM(LOWER(this.cCustomDefaultPath)))
     SET DEFAULT TO (_screen.oGlobal.choteldir)
ENDIF
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE OpenFile
IF this.lUseExclusive
     = opEnfile(.F.,"LN",.T.)
ELSE
     = openfile()
ENDIF
IF NOT USED("company")
     = openfiledirect(.F.,"address","company")
ENDIF
IF NOT USED("agent")
     = openfiledirect(.F.,"address","agent")
ENDIF
= relations()
RETURN .T.
ENDPROC
*
HIDDEN PROCEDURE ConvertToString
LPARAMETERS lp_uVal
 LOCAL ctYpe, crEt, cpOint, cdAte, crettypedef, l_cString
 crEt = ''
 crettypedef = ''
 ctYpe = VARTYPE(lp_uVal)
 DO CASE
      CASE INLIST(ctYpe,'D','T') AND EMPTY(lp_uVal)
           crEt = '{}'
           crettypedef = 'D'
      CASE ctYpe='C' .OR. ctYpe='M'
           crEt = lp_uVal
           crettypedef = 'C'
      CASE ctYpe='D'
           cdAte = DTOS(lp_uVal)
           crEt = '{^'+SUBSTR(cdAte, 1, 4)+'-'+SUBSTR(cdAte, 5, 2)+'-'+ ;
                  SUBSTR(cdAte, 7, 2)+'}'
           crettypedef = 'D'
      CASE ctYpe='L'
           crEt = IIF(lp_uVal, '.T.', '.F.')
           crettypedef = 'L'
      CASE ctYpe='X'
           crEt = '.NULL.'
           crettypedef = 'X'
      CASE ctYpe='N'
           IF INT(lp_uVal)=lp_uVal
                crEt = LTRIM(STR(lp_uVal))
           ELSE
                cpOint = SET('point')
                crEt = LTRIM(STR(lp_uVal, 20, 8))
                crEt = STRTRAN(crEt, cpOint, '.')
                DO WHILE RIGHT(crEt, 1)='0'
                     crEt = SUBSTR(crEt, 1, LEN(crEt)-1)
                ENDDO
                * When converted string is longer as 16 character, that means, we have numeric
                * which has precision greater as 16.
                * In this case, use transform function, becouse numeric value can wrongly have more decimals numbers
                * on end.
                *
                * Example:
                * lp_uVal = 88094650.201 && ReserId
                * ? STR(lp_uVal, 20, 8) && Gives back 88094650.20100001
                IF LEN(crEt)>16
                     crEt = TRANSFORM(lp_uVal)
                     crEt = STRTRAN(crEt, cpOint, '.')
                ENDIF
           ENDIF
           crettypedef = 'N'
      CASE ctype = 'T'
           cret = "{^" + ALLTRIM(STR(YEAR(lp_uVal))) + "-" + ;
                   ALLTRIM(STR(MONTH(lp_uVal))) + "-" + ;
                   ALLTRIM(STR(DAY(lp_uVal))) + " " + ;
                   ALLTRIM(STR(HOUR(lp_uVal))) + ":" + ;
                   ALLTRIM(STR(MINUTE(lp_uVal))) + ":" + ;
                   ALLTRIM(STR(SEC(lp_uVal))) + "}"
           crettypedef = 'T'

 ENDCASE
 l_cString = crettypedef + "|" + crEt
RETURN l_cString
ENDPROC
*
PROCEDURE MyDoCmd(cCmd AS String) AS String
IF NOT this.lSigned
     RETURN ""
ENDIF
&cCmd     && just execute parm as if it were a fox command
RETURN ".T."
ENDPROC
*
FUNCTION MyEval(cExpr AS String) AS String
IF NOT this.lSigned
     RETURN ""
ENDIF
LOCAL l_uRetVal
l_uRetVal = .F.
l_uRetVal = &cExpr     && evaluate parm as if it were a fox expr
RETURN TRANSFORM(l_uRetVal)
ENDPROC
*
PROCEDURE Do(lp_cCmd AS String, lp_uParam1 AS String, lp_uParam2 AS String, lp_uParam3 AS String, lp_uParam4 AS String, lp_uParam5 AS String, ;
          lp_uParam6 AS String, lp_uParam7 AS String, lp_uParam8 AS String, lp_uParam9 AS String, lp_uParam10 AS String, lp_uParam11 AS String, ;
          lp_uParam12 AS String, lp_uParam13 AS String, lp_uParam14 AS String, lp_uParam15 AS String) ;
          AS String

LOCAL l_uLParam1, l_uLParam2, l_uLParam3, l_uLParam4, l_uLParam5, ;
          l_uLParam6, l_uLParam7, l_uLParam8, l_uLParam9, l_uLParam10, l_uLParam11, ;
          l_uLParam12, l_uLParam13, l_uLParam14, l_uLParam15

LOCAL l_cCmd, l_uRetVal, l_cCursor, l_nParam, l_cType, l_cValue, l_cParam, l_cPoint, i, l_cMacroL, l_cMacroR

* Here are processes which are called from outside. All parameters, IN and OUT are String type.

IF NOT this.lSigned
     RETURN ""
ENDIF
_screen.oglobal.cmsglast = ""
l_cCmd = TRANSFORM(lp_cCmd)

* Copy sent parameters to local variabels, to prevent errors with COM. Dont touch original parameter variables.
FOR i = 1 TO PCOUNT() - 1
     l_cMacroL = "l_uLParam" + TRANSFORM(i)
     l_cMacroR = "lp_uParam" + TRANSFORM(i)
     &l_cMacroL = &l_cMacroR
ENDFOR

IF INLIST(l_cCmd, "CHECKOUT", "CHECKRIGHT", "USEOBJECT", "SETPROPERTY", "GETPROPERTY", "EVALUATE", "EXECCMD", "EXECSCRIPT", "EXECPROC")
     * Convert to proper data types
     l_cPoint = SET("Point")
     FOR l_nParam = 1 TO PCOUNT()-1
         l_cParam = "l_uLParam" + TRANSFORM(l_nParam)
         *l_cType = GETWORDNUM(&l_cParam,1,"|")
         l_cType = STREXTRACT(&l_cParam,"","|")
         *l_cValue = GETWORDNUM(&l_cParam,2,"|")
         l_cValue = STREXTRACT(&l_cParam,"|","")
         TRY
              DO CASE
                   CASE EMPTY(l_cType) AND EMPTY(l_cValue)
                   CASE l_cType == &l_cParam
                        && No datatype defined. Then treat it as string.
                   CASE l_cType == "L"
                        &l_cParam = IIF(l_cValue=".T.",.T.,.F.)
                   CASE l_cType == "N"
                        IF EMPTY(l_cValue)
                             &l_cParam = 0
                        ELSE
                             l_cValue = STRTRAN(l_cValue,l_cPoint,".")
                             &l_cParam = EVALUATE(l_cValue)
                        ENDIF
                   CASE l_cType == "D"
                        &l_cParam = &l_cValue
                   CASE l_cType == "X"
                        &l_cParam = .NULL.
                   OTHERWISE
                        * C - Character
                        &l_cParam = l_cValue
              ENDCASE
         CATCH
         ENDTRY
     NEXT
ENDIF
DO CASE
     CASE l_cCmd == "USEOBJECT"
          l_cObjName = l_uLParam1
          l_cMethod = l_uLParam2
          l_cMacro = "this." + l_cObjName + "." + l_cMethod + "("
          IF PCOUNT()>3
               FOR i = 4 TO PCOUNT()
                    l_cMacro2 = "l_uLParam" + TRANSFORM(i-1)
                    l_cMacro = l_cMacro + l_cMacro2 + ","
               ENDFOR
               IF RIGHT(l_cMacro,1)=","
                    l_cMacro = LEFT(l_cMacro,LEN(l_cMacro)-1)
               ENDIF
          ENDIF
          l_cMacro = l_cMacro + ")"
          l_uRetVal = &l_cMacro
     CASE l_cCmd == "GETPROPERTY"
          l_cObjName = l_uLParam1
          l_cProperty = l_uLParam2
          l_cMacro = "this." + l_cObjName + "." + l_cProperty
          l_uRetVal = &l_cMacro
     CASE l_cCmd == "SETPROPERTY"
          l_cObjName = l_uLParam1
          l_cProperty = l_uLParam2
          l_cMacro = "this." + l_cObjName + "." + l_cProperty
          &l_cMacro = l_uLParam3
          l_uRetVal = .T.
     CASE l_cCmd == "CREATEOBJECT"
          l_cObjName = l_uLParam1
          l_cClassName = l_uLParam2
          l_cModule = l_uLParam3
          l_oObj = NEWOBJECT(l_uLParam2,l_cModule)
          IF NOT PEMSTATUS(this,l_cObjName,5)
               this.AddProperty(l_cObjName,.NULL.)
          ENDIF
          l_cMacro = "this." + l_cObjName
          &l_cMacro = l_oObj
          l_oObj = .NULL.
          l_uRetVal = .T.
     CASE l_cCmd == "EXECCMD"
          IF NOT EMPTY(l_uLParam1)
               &l_uLParam1
               l_uRetVal = .T.
          ELSE
               l_uRetVal = .F.
          ENDIF
     CASE l_cCmd == "EXECSCRIPT"
          IF NOT EMPTY(l_uLParam1)
               IF EMPTY(l_uLParam2)
                    l_uRetVal = EXECSCRIPT(l_uLParam1)
               ELSE

                    * Use this case whem executing external prg file.
                    * Example in Go when procreservat_deskapi_conference_save.prg is file n citadel.exe directory:
                    * methodresponse, err := doCitadelExe("Do", "EXECSCRIPT", `FILETOSTR(FULLPATH("procreservat_deskapi_conference_save.prg"))`, `C|`+`Some data`)
                    * Code in procreservat_deskapi_conference_save.prg file:
                    *
                    * LPARAMETERS lp_cJSON
                    * LOCAL l_cReturnJSON
                    * 
                    * TEXT TO l_cReturnJSON TEXTMERGE NOSHOW PRETEXT 15
                    * {
                    *   "bookingid": "<<SYS(2015)>>",
                    *   "errorcode": 0,
                    *   "errormessage": "<<TRANSFORM(lp_cJSON)>>",
                    *   "success": true
                    * }
                    * ENDTEXT
                    * 
                    * RETURN l_cReturnJSON

                    l_uRetVal = EXECSCRIPT(&l_uLParam1, l_uLParam2)

               ENDIF
          ELSE
               l_uRetVal = .F.
          ENDIF
     CASE l_cCmd == "EVALUATE"
          IF NOT EMPTY(l_uLParam1)
               l_uRetVal = &l_uLParam1
          ELSE
               l_uRetVal = .F.
          ENDIF
     CASE l_cCmd == "CHECKOUT"
          * l_uLParam1 is rs_rsid
          l_uRetVal = .F.
          IF NOT EMPTY(l_uLParam1)
               this.OpenFile()
               l_cCursor = sqlcursor("SELECT rs_reserid, rs_ccnum, rs_paymeth FROM reservat WHERE rs_rsid = " + sqlcnv(l_uLParam1,.T.))
               IF NOT EMPTY(&l_cCursor..rs_reserid)
                    IF VARTYPE(l_uLParam2)="L" AND l_uLParam2
                         IF NOT EMPTY(&l_cCursor..rs_ccnum) AND NOT EMPTY(&l_cCursor..rs_paymeth)
                              * Only when credit card number given and selected pay method, then is allowed express checkout!
                              l_uRetVal = CheckOutBProc("SINGLE","",&l_cCursor..rs_reserid,.T.)
                         ELSE
                              l_uRetVal = .F.
                         ENDIF
                    ELSE
                         l_uRetVal = CheckOutBProc("SINGLE","",&l_cCursor..rs_reserid)
                    ENDIF
               ENDIF
               dclose(l_cCursor)
          ENDIF
     CASE l_cCmd == "ONLIVE"
          this.nLastLive = SECONDS()
          l_uRetVal = .T.
     CASE l_cCmd == "GETACTIVEUSER"
          l_uRetVal = this.cUserId
     CASE l_cCmd == "CHECKRIGHT"
          l_uRetVal = this.CheckRight(l_uLParam1, l_uLParam2, l_uLParam3)
     CASE l_cCmd == "AUDIT"
          l_uRetVal = .F.
          this.lUseExclusive = .F. && Do audit although all users are not logetout (all tables aren't closed)
          this.OpenFile()
          IF USED("param") AND USED("reservat") AND USED("post") AND USED("histres") AND USED("histpost") AND USED("article") AND USED("roomtype")
               l_uRetVal = audit("NAMainFunctions", .T.)
          ENDIF
          CLOSE TABLES ALL
     CASE l_cCmd == "REINDEX"
          l_uRetVal = .F.
          l_uRetVal = audit("RebuildDatabase")
          CLOSE TABLES ALL
     CASE l_cCmd == "EXECPROC"
          IF NOT EMPTY(l_uLParam1)
               l_uRetVal = &l_uLParam1
          ELSE
               l_uRetVal = .F.
          ENDIF
ENDCASE
this.cmsg = _screen.oglobal.cmsglast

FOR i = 1 TO PCOUNT() - 1
     l_cMacroL = "l_uLParam" + TRANSFORM(i)
     l_cMacroR = "lp_uParam" + TRANSFORM(i)
     l_cRefVal = this.ConvertToString(&l_cMacroL)
     IF &l_cMacroR <> l_cRefVal
          &l_cMacroR = l_cRefVal
     ENDIF
ENDFOR

l_cRetVal = this.ConvertToString(l_uRetVal)
RETURN l_cRetVal
ENDPROC
*
PROCEDURE GetXMLTableStructArray
LPARAMETERS lp_aArray
EXTERNAL ARRAY lp_aArray
IF Application.StartMode == 2
     = COMARRAY(this, 11)
ENDIF

*LOCAL ARRAY l_aXMLArray(1)
DIMENSION lp_aArray(ALEN(this.axmltablestruct,1),ALEN(this.axmltablestruct,2))
ACOPY(this.axmltablestruct,lp_aArray)
RETURN .T.
RETURN 
ENDPROC
*
PROCEDURE DoBillAction(lp_cActionJSON AS String) AS String
IF VARTYPE(g_oBillFormSet)<>"O"
     DO FORM forms\bills NAME g_oBillFormSet LINKED WITH 0
ENDIF
RETURN g_oBillFormSet.DoAction(lp_cActionJSON)
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS clogouttmr AS Timer
Interval = 10000
Enabled = .F.
oDeskServer = .NULL.
ldelayedrelease = .F.
*
HIDDEN PROCEDURE Init
LPARAMETERS lp_oDeskServer
this.oDeskServer = lp_oDeskServer
ENDPROC
*
PROCEDURE Timer
LOCAL l_cFile, l_nHandle

this.Enabled = .F.

IF this.ldelayedrelease
     this.oDeskServer.Release()
     RETURN TO MASTER
ENDIF

IF PDSIsDataBaseBlocked() OR ;
          (NOT EMPTY(this.oDeskServer.nLastLive) AND ;
          (60*this.oDeskServer.nSessionIdleTime < MOD(SECONDS()-this.oDeskServer.nLastLive, 24*3600)))
     * Mark for release in next cycle. So we give some additional time to deskbox.exe or citadelwebserver.exe
     * to release this instance of citadel.exe.
     * citadel.exe should release him self only when no other object is holding reference to him! When not so,
     * error can happen.
     this.ldelayedrelease = .T. 
ENDIF

this.Enabled = .T.
ENDPROC
*
ENDDEFINE