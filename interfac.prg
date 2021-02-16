#INCLUDE "include\registry.h"
#INCLUDE "include\constdefines.h"
*
PROCEDURE IfcPost
 PARAMETER p_Reserid, p_Roomnum
 PRIVATE ALL LIKE l_*
 l_Appendall = (PCOUNT()==0)
 IF ((paRam.pa_keyifc .OR. paRam.pa_posifc .OR. paRam.pa_pttifc .OR.  ;
    paRam.pa_ptvifc OR _screen.ogLOBAL.opARAM2.pa_intifc) .AND.  .NOT. EMPTY(reServat.rs_in) .AND.  ;
    EMPTY(reServat.rs_out)) AND (_SCREEN.IS or _SCREEN.IK or _SCREEN.IT or _SCREEN.IP)
      FNWaitWindow("Reading interface charges...",.T.)
      l_Oldarea = SELECT()
      DO ifCasciipost WITH p_Reserid, p_Roomnum
      SELECT (l_Oldarea)
      FNWaitWindow(,,,.T.)
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE IfcPrint
 PARAMETER p_Reserid, p_Window
 PRIVATE ALL LIKE l_*
 PRIVATE adLg, cfOr, coUtput
 l_Area = SELECT()
 IF (p_Window<>1)
      l_Addrid = FNGetWindowData(reServat.rs_rsid, p_Window, "pw_addrid")
      IF ( .NOT. EMPTY(l_Addrid))
           l_Oldaddrec = RECNO("address")
           IF ( .NOT. SEEK(l_Addrid, "address"))
                GOTO l_Oldaddrec IN "address"
           ENDIF
      ENDIF
 ENDIF
 IF  .NOT. paRam.pa_billlng .OR. (EMPTY(adDress.ad_lang) .AND.  ;
     paRam.pa_billlng)
      l_Currlang = g_Language
 ELSE
      l_Currlang = ALLTRIM(adDress.ad_lang)
 ENDIF
 l_Frx = gcReportdir+"bill2.frx"
 IF ( .NOT. FILE(l_Frx))
      = alErt(l_Frx,"File not found")
      RETURN
 ENDIF
 g_Rptlng = l_Currlang
 g_Rptlngnr = STR(dlOokup('PickList', ;
              'pl_label=[LANGUAGE] and pl_charcod = '+sqLcnv(l_Currlang), ;
              'pl_numval'), 1)
 IF g_Rptlngnr='0'
      g_Rptlngnr = g_Langnum
 ENDIF
 l_Langdbf = STRTRAN(UPPER(l_Frx), '.FRX', '.DBF')
 IF FILE(l_Langdbf)
      USE SHARED NOUPDATE (l_Langdbf) ALIAS rePtext IN 0
 ENDIF
 l_Oldpostrec = RECNO("post")
 IF dlOcate('Post','ps_reserid = '+sqLcnv(p_Reserid)+' and ps_window = '+ ;
    sqLcnv(p_Window))
      DIMENSION adLg[5, 8]
      adLg[1, 1] = "ptt"
      adLg[1, 2] = GetLangText("INTERFAC","T_PBXCHARGES")
      adLg[1, 3] = "Param.pa_pttifc"
      adLg[1, 4] = '@*C'
      adLg[1, 5] = 15
      adLg[1, 6] = ""
      adLg[1, 7] = ""
      adLg[1, 8] = '.t.'
      adLg[2, 1] = "pos"
      adLg[2, 2] = GetLangText("INTERFAC","T_POSCHARGES")
      adLg[2, 3] = "Param.pa_posifc"
      adLg[2, 4] = '@*C'
      adLg[2, 5] = 15
      adLg[2, 6] = ""
      adLg[2, 7] = ""
      adLg[2, 8] = '.t.'
      adLg[3, 1] = "ptv"
      adLg[3, 2] = GetLangText("INTERFAC","T_PTVCHARGES")
      adLg[3, 3] = "Param.pa_ptvifc"
      adLg[3, 4] = '@*C'
      adLg[3, 5] = 15
      adLg[3, 6] = ""
      adLg[3, 7] = ""
      adLg[3, 8] = '.t.'
      adLg[4, 1] = "key"
      adLg[4, 2] = GetLangText("INTERFAC","T_KEYCHARGES")
      adLg[4, 3] = "Param.pa_keyifc"
      adLg[4, 4] = '@*C'
      adLg[4, 5] = 15
      adLg[4, 6] = ""
      adLg[4, 7] = ""
      adLg[4, 8] = '.t.'
      adLg[5, 1] = "output"
      adLg[5, 2] = GetLangText("INTERFAC","TXT_PRINTER")+';'+GetLangText("INTERFAC", ;
          "TXT_PREVIEW")
      adLg[5, 3] = "1"
      adLg[5, 4] = '@*RH'
      adLg[5, 5] = 10
      adLg[5, 6] = ""
      adLg[5, 7] = ""
      adLg[5, 8] = '1'
      IF diAlog(GetLangText("INTERFAC","TW_OUTPUT"),'',@adLg)
           l_Psrec = RECNO("post")
           l_Rsrec = RECNO("reservat")
           l_Adrec = RECNO("address")
           cfOr = ''
           IF adLg(1,8)
                cfOr = sqLor(cfOr,'PS_ARTINUM = PARAM.PA_PTTARTI')
           ENDIF
           IF adLg(2,8)
                cfOr = sqLor(cfOr,'PS_ARTINUM = PARAM.PA_POSARTI')
           ENDIF
           IF adLg(3,8)
                cfOr = sqLor(cfOr,'PS_ARTINUM = PARAM.PA_PTVARTI')&& Changed von PTT on PTV!! 24.3.2002.
           ENDIF
           IF adLg(4,8)
                cfOr = sqLor(cfOr,'PS_ARTINUM = PARAM.PA_KEYARTI')
           ENDIF
           IF EMPTY(cfOr)
                cfOr = '.T.'
           ENDIF
           IF adLg(5,8)=1
                coUtput = 'TO PRINTER'
           ELSE
                coUtput = 'PREVIEW'
           ENDIF
           report form (l_Frx)	 for !post.ps_cancel .and. !post.ps_split .and. !Empty(post.ps_ifc) and &cFor  while post.ps_reserid = p_ReserId .and. post.ps_window = p_Window  NOCONSOLE &cOutput
           GOTO l_Psrec IN "post"
           GOTO l_Adrec IN "address"
           GOTO l_Rsrec IN "reservat"
      ENDIF
 ENDIF
 GOTO l_Oldpostrec IN "post"
 IF (p_Window<>1)
      IF ( .NOT. EMPTY(l_Addrid))
           GOTO l_Oldaddrec IN "address"
      ENDIF
 ENDIF
 = dcLose('RepText')
 SELECT (l_Area)
 RETURN
ENDPROC
*
FUNCTION IfcCheck
 LPARAMETERS lp_cRoomnum, lp_cAction, lp_lSync, lp_lSkipKey, lp_lUpdateOnly, lp_cOldRoomnum, lp_cMode
 LOCAL l_nRecno, l_cCardType, l_cFxp, l_nNumberOfCards, l_nGroup, l_lContinue, l_cLinked, i, l_cRoomNum
 PRIVATE p_cForceRoomNum
 p_cForceRoomNum = ""
 l_nRecno = RECNO("room")
 IF SEEK(lp_cRoomnum, "room", "tag1") AND NOT _screen.oGlobal.lIfcCheckBlock
      l_lContinue = .T.
      IF NOT lp_lSync AND param2.pa_syncstd
           l_nGroup = dlookup("roomtype","rt_roomtyp = " + sqlcnv(room.rm_roomtyp,.T.),"rt_group")
           IF NOT INLIST(l_nGroup,1,2)
                * Don't send IN/OUT/ACT files for non standard rooms
                l_lContinue = .F.
           ENDIF
      ENDIF
      IF EMPTY(lp_cMode)
           lp_cMode = ""
      ENDIF
      l_cCardType = "K"
      l_nNumberOfCards = 1
      IF l_lContinue
           DO IfcCheckAscii WITH lp_cRoomnum, lp_cAction, l_cCardType, l_nNumberOfCards, lp_lSync, lp_lSkipKey, lp_lUpdateOnly, lp_cOldRoomnum, lp_cMode
           IF room.rm_linkifc
                l_cLinked = get_rm_rmname(lp_cRoomnum, "rm_linked")
                IF NOT EMPTY(l_cLinked)
                     FOR i = 1 TO GETWORDCOUNT(l_cLinked, ",")
                          l_cRoomNum = PADR(GETWORDNUM(l_cLinked,i,","),4)
                          IF SEEK(l_cRoomNum, "room", "tag1")
                               p_cForceRoomNum = l_cRoomNum
                               DO IfcCheckAscii WITH l_cRoomNum, lp_cAction, l_cCardType, l_nNumberOfCards, lp_lSync, lp_lSkipKey, lp_lUpdateOnly, l_cRoomNum, lp_cMode
                          ENDIF
                     ENDFOR
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 GOTO l_nRecno IN room

 RETURN .T.
ENDFUNC
*
PROCEDURE IfcCheckAscii
 LPARAMETERS lp_cRoomnum, lp_cAction, lp_cCardType, lp_nNumberOfCards, lp_lSync, lp_lSkipKey, lp_lUpdateOnly, lp_cOldRoomnum, lp_cMode
 LOCAL i, l_nArea, l_cCardString, l_cTempFile, l_cFile, l_cExt, l_cFxp, l_lDontCreateFile, l_cClass, l_lUpdateOnlyPTT

 l_nArea = SELECT()

 l_cFile = ""
 l_cExt = IIF(lp_cAction == "CHECKIN", ".IN", ".OUT")

 *******
 * POS *
 *******
 IF _screen.IK AND param.pa_posifc AND (EMPTY(lp_cMode) OR lp_cMode = "POS")
      l_cCardString = CreateInterfaceString("POS",lp_cCardType,lp_nNumberOfCards,"",0,"0000")
      IF UPPER(LEFT(ALLTRIM(room.rm_roomnum), 1)) = "A" AND NOT EOF("reservat") AND reservat.rs_out = " "
           l_cFile = PosDir() + ALLTRIM(SUBSTR(get_rm_rmname(room.rm_roomnum), 2, 10)) + ".IN"
           IF lp_cAction = "CHECKIN"
                DO PosChkIn WITH l_cFile, l_cCardString, (NOT lp_lSync OR param.pa_possync)
           ELSE
                IF FILE(l_cFile)
                     l_cTempFile = FORCEEXT(l_cFile,"OUT")
                     COPY FILE (l_cFile) TO (l_cTempFile)
                ENDIF
                DO PosChkOut WITH l_cFile, reservat.rs_reserid, (NOT lp_lSync OR param.pa_possync)
           ENDIF
      ELSE
           DO CASE
                CASE param.pa_postpos
                     ctProom = ""
                     ntPposition = RAT("TOUCHPOSROOM:", reservat.rs_changes)
                     IF ntPposition > 0
                          ctProom = ALLTRIM(SUBSTR(reservat.rs_changes, ntPposition+13, 1))
                     ENDIF
                     l_cFile = PosDir() + GetPOSFileName() + ctProom + ".IN"
                OTHERWISE
                     l_cFile = PosDir() + GetPOSFileName() + ".IN"
           ENDCASE
           IF lp_cAction = "CHECKIN"
                DO PosChkIn WITH l_cFile, l_cCardString, (NOT lp_lSync OR param.pa_possync)
                l_cTempFile = FORCEEXT(l_cFile,"OUT")
                FileDelete(l_cTempFile)
           ELSE
                IF FILE(l_cFile)
                     l_cTempFile = FORCEEXT(l_cFile,"OUT")
                     COPY FILE (l_cFile) TO (l_cTempFile)
                ENDIF
                DO PosChkOut WITH l_cFile, reservat.rs_reserid, (NOT lp_lSync OR param.pa_possync)
                l_cTempFile = FORCEEXT(l_cFile,"IN")
                FileDelete(l_cTempFile)
           ENDIF
           IF NOT EMPTY(reservat.rs_keycard)
                l_cExt = LEFT(l_cExt, 3)+"N"
                l_cFile = PosDir() + ALLTRIM(STR(VAL(reServat.rs_keycard)))
                DO AsciiWrite WITH l_cFile, l_cExt, l_cCardString
           ENDIF
      ENDIF
 ENDIF
 *******
 * PTV *
 *******
 IF _screen.IP AND param.pa_ptvifc AND (EMPTY(lp_cMode) OR lp_cMode = "PTV") AND IIF(lp_lSync, param.pa_ptvsync, NOT _screen.oGlobal.lUgos)
      IF EMPTY(param.pa_ptvname)
           LOCAL l_cInitValues, i
           LOCAL ARRAY l_aResults(1,2)
           l_cInitValues = ""
           GetFileName("PTV", @l_cFile)
           IF lp_cAction = "CHECKOUT"
                l_cCardString = CreateInterfaceString("PTV",lp_cCardType,lp_nNumberOfCards,"",0,"0000",,lp_lUpdateOnly,lp_cOldRoomnum)
           ELSE
                IF EMPTY(reservat.rs_ptvflag)
                      l_cInitValues = REPLICATE("0",10)
                      GetCardInitValues("PTV", @l_aResults)
                      IF ALEN(l_aResults,1) > 1
                           FOR i = 1 TO ALEN(l_aResults,1)
                                DO CASE
                                     CASE l_aResults(i,1) = "OPTIONDEFAULT1" AND l_aResults(i,2)
                                          l_cInitValues = STUFF(l_cInitValues,1,1,"1")
                                     CASE l_aResults(i,1) = "OPTIONDEFAULT2" AND l_aResults(i,2)
                                          l_cInitValues = STUFF(l_cInitValues,2,1,"1")
                                     CASE l_aResults(i,1) = "OPTIONDEFAULT3" AND l_aResults(i,2)
                                          l_cInitValues = STUFF(l_cInitValues,3,1,"1")
                                     CASE l_aResults(i,1) = "OPTIONDEFAULT4" AND l_aResults(i,2)
                                          l_cInitValues = STUFF(l_cInitValues,4,1,"1")
                                     CASE l_aResults(i,1) = "OPTIONDEFAULT5" AND l_aResults(i,2)
                                          l_cInitValues = STUFF(l_cInitValues,5,1,"1")
                                ENDCASE
                           ENDFOR
                      ENDIF
                  ELSE
                        l_cInitValues = PADR(reservat.rs_ptvflag,10,"0")
                  ENDIF
                l_cCardString = CreateInterfaceString("PTV",lp_cCardType,lp_nNumberOfCards,l_cInitValues,0,"0000",,lp_lUpdateOnly,lp_cOldRoomnum)
           ENDIF
           DO AsciiWrite WITH l_cFile, l_cExt, l_cCardString
           IF NOT EMPTY(l_cInitValues) AND NOT reservat.rs_ptvflag == l_cInitValues
                 REPLACE rs_ptvflag WITH l_cInitValues IN reservat
           ENDIF
      ELSE
           l_cFxp = "Ptv" + ALLTRIM(param.pa_ptvname)
           IF FILE(FORCEEXT(l_cFxp,"fxp"))
                DO &l_cFxp WITH lp_cAction, lp_cRoomnum
           ELSE
                MsgBox("Pay-TV interface driver " + FORCEEXT(l_cFxp,"fxp") + " not found!", "Brilliant Interface", 16)
           ENDIF
      ENDIF
 ENDIF
 *******
 * KEY *
 *******
 IF _screen.IS AND param.pa_keyifc AND (EMPTY(lp_cMode) OR lp_cMode = "KEY") AND (NOT lp_lSync OR param.pa_keysync) AND NOT lp_lSkipKey
      IF EMPTY(param.pa_keyname)
           GetFileName("KEY", @l_cFile)
           LOCAL l_cInitValues, i, l_nkeydefcards
           LOCAL ARRAY l_aResults(1,2)
           l_nkeydefcards = 0
           l_cInitValues = REPLICATE("0",10)
           GetCardInitValues("KEY",@l_aResults)
           IF ALEN(l_aResults,1) > 1
                FOR i = 1 TO ALEN(l_aResults,1)
                     DO CASE
                          CASE l_aResults(i,1) = "OPTIONDEFAULT1" AND l_aResults(i,2)
                               l_cInitValues = STUFF(l_cInitValues,1,1,"1")
                          CASE l_aResults(i,1) = "OPTIONDEFAULT2" AND l_aResults(i,2)
                               l_cInitValues = STUFF(l_cInitValues,2,1,"1")
                          CASE l_aResults(i,1) = "OPTIONDEFAULT3" AND l_aResults(i,2)
                               l_cInitValues = STUFF(l_cInitValues,3,1,"1")
                          CASE l_aResults(i,1) = "OPTIONDEFAULT4" AND l_aResults(i,2)
                               l_cInitValues = STUFF(l_cInitValues,4,1,"1")
                          CASE l_aResults(i,1) = "DUMMYROOMS"
                               IF NOT l_aResults(i,2)
                                    * Dont create file when dummy!
                                    IF DLookup('RoomType', 'rt_roomtyp = ' + SqlCnv(reservat.rs_roomtyp),'rt_group')=3
                                         l_lDontCreateFile = .T.
                                    ENDIF
                               ENDIF
                          CASE l_aResults(i,1) = "CONFROOMS"
                               IF NOT l_aResults(i,2)
                                    * Dont create file when conference room!
                                    IF DLookup('RoomType', 'rt_roomtyp = ' + SqlCnv(reservat.rs_roomtyp),'rt_group')=2
                                         l_lDontCreateFile = .T.
                                    ENDIF
                               ENDIF
                          CASE l_aResults(i,1) = "CARDCOUNTDEFAULT"
                               l_nkeydefcards = INT(VAL(l_aResults(i,2)))
                     ENDCASE
                ENDFOR
           ENDIF
           IF NOT l_lDontCreateFile
                IF lp_cAction = "CHECKOUT"
                     l_cCardString = CreateInterfaceString("KEY",lp_cCardType,lp_nNumberOfCards,"",0,"0000",,lp_lUpdateOnly,lp_cOldRoomnum)
                ELSE
                     IF l_nkeydefcards > 1 AND lp_nNumberOfCards < 2
                          * Set default number of keycard to create
                          lp_nNumberOfCards = l_nkeydefcards
                     ENDIF
                     l_cCardString = CreateInterfaceString("KEY",lp_cCardType,lp_nNumberOfCards,l_cInitValues,NextId("KEYCARD"),"0000",,lp_lUpdateOnly,lp_cOldRoomnum)
                ENDIF
                DO AsciiWrite WITH l_cFile, l_cExt, l_cCardString
           ENDIF
      ELSE
           l_cFxp = "Key" + ALLTRIM(param.pa_keyname)
           IF FILE(FORCEEXT(l_cFxp,"fxp"))
                DO &l_cFxp WITH lp_cAction, lp_cRoomnum
           ELSE
                MsgBox("Keycard interface driver " + FORCEEXT(l_cFxp,"fxp") + " not found!", "Brilliant Interface", 16)
           ENDIF
      ENDIF
 ENDIF
 *******
 * PTT *
 *******
 IF _screen.IT AND param.pa_pttifc AND (EMPTY(lp_cMode) OR lp_cMode = "PTT") AND IIF(lp_lSync, param.pa_pttsync, NOT _screen.oGlobal.lUgos) AND NOT EMPTY(room.rm_phone)
      LOCAL l_lOnlyFirstNum, l_cAction, l_cPhone, l_cPttExt

      l_cAction = lp_cAction
      IF UPPER(LEFT(ALLTRIM(room.rm_roomnum), 1)) = "A" AND (EOF("reservat") OR reservat.rs_out = "1")
           l_lOnlyFirstNum = .T.
      ENDIF
      l_cClass = GetIfcClass("PTT")
      IF _screen.oGlobal.lUgos AND l_cAction <> "CHECKOUT" AND (LEFT(l_cClass,1) <> "1" OR NOT HasCreditForPTT(ALLTRIM(room.rm_phone)))
           l_cAction = "CHECKOUT"
      ENDIF
      l_cPttExt = IIF(l_cAction == "CHECKIN", ".IN", ".OUT")

      FOR i = 1 TO GETWORDCOUNT(ALLTRIM(room.rm_phone))
           l_cPhone = GETWORDNUM(ALLTRIM(room.rm_phone),i,",")
           IF NOT EMPTY(l_cPhone)
                GetFileName("PTT", @l_cFile, l_cPhone)
                IF l_cAction = "CHECKOUT" AND FILE(l_cFile+".MSW")
                     Alert(StrFmt(GetLangText("INTERFAC", "T_MSGWAITING"),l_cPhone))
                     FileDelete(l_cFile+".MSW")
                ENDIF
                IF l_cAction = "CHECKOUT"
                     IF param2.pa_pttrmc AND lp_lUpdateOnly AND NOT EMPTY(lp_cOldRoomnum)
                          * Room change. Dont do checkout. We will send room change command in .IN file,
                          * with old room number.
                          FileDelete(l_cFile+".IN")
                     ELSE
                          l_cCardString = CreateInterfaceString("PTT",lp_cCardType,lp_nNumberOfCards,"",0,"0000")
                          IF param.pa_pttrsid
                               DO AsciiWrite WITH l_cFile, l_cPttExt, l_cCardString
                          ELSE
                               DO AsciiWrite WITH l_cFile, l_cPttExt, l_cCardString, (NOT lp_lSync OR param.pa_pttsync)
                          ENDIF
                     ENDIF
                ELSE
                     IF NOT param2.pa_pttrmc AND lp_lUpdateOnly AND NOT EMPTY(lp_cOldRoomnum)
                          * Dont send update for room change. Send CheckIn.
                          l_lUpdateOnlyPTT = .F.
                     ELSE
                          l_lUpdateOnlyPTT = lp_lUpdateOnly
                     ENDIF
                     l_cCardString = CreateInterfaceString("PTT",lp_cCardType, lp_nNumberOfCards,l_cClass,NextId("KEYCARD"),"0000",,l_lUpdateOnlyPTT,lp_cOldRoomnum)
                     DO AsciiWrite WITH l_cFile, l_cPttExt, l_cCardString, (NOT lp_lSync OR param.pa_pttsync)
                ENDIF
                IF l_lOnlyFirstNum
                     EXIT
                ENDIF
           ENDIF
      ENDFOR
 ENDIF
 **********
 * ENERGIE*
 **********
 IF _screen.EI AND (EMPTY(lp_cMode) OR lp_cMode = "ENERGIE") AND NOT EOF("reservat")
      IfcEnergie(room.rm_roomnum, lp_cAction, .F., reservat.rs_arrdate, reservat.rs_depdate)
 ENDIF
 ************
 * INTERNET *
 ************
 IF param2.pa_intifc AND (EMPTY(lp_cMode) OR lp_cMode = "INT") AND IIF(lp_lSync, param2.pa_intsync, NOT _screen.oGlobal.lUgos) AND NOT EOF("reservat")
      GetFileName("INT", @l_cFile)
      l_cCardString = CreateInterfaceString("INT",lp_cCardType,lp_nNumberOfCards,GetIfcClass("INT"),NextId("KEYCARD"),"0000",,lp_lUpdateOnly,lp_cOldRoomnum)
      DO AsciiWrite WITH l_cFile, l_cExt, l_cCardString, .T.,, lp_lUpdateOnly
 ENDIF

 SELECT (l_nArea)

 RETURN .T.
ENDPROC
*
PROCEDURE AsciiWrite
 LPARAMETER lp_cFile, lp_cExt, lp_cString, lp_lWithAct, lp_lOnlyAct, lp_lUpdateOnly
 LOCAL l_cDelExt, l_cActExt, l_nHandle
 lp_cFile = IfcFixFileName(lp_cFile)
 IF PCOUNT() = 3
      lp_lWithAct = .T.
 ENDIF
 DO CASE
      CASE lp_cExt = ".IN"
           l_cDelExt = ".OUT"
           l_cActExt = ".ACT"
      CASE lp_cExt = ".OUT"
           l_cDelExt = ".IN"
           l_cActExt = ".ACT"
      CASE lp_cExt = ".INN"
           l_cDelExt = ".OUN"
           l_cActExt = ".ACN"
      CASE lp_cExt = ".OUN"
           l_cDelExt = ".INN"
           l_cActExt = ".ACN"
      CASE lp_cExt = ".ACT"
           l_cActExt = ".ACT"
 ENDCASE
 IF NOT lp_lOnlyAct
      FileDelete(lp_cFile+l_cDelExt)
      l_nHandle = FCREATE(lp_cFile+lp_cExt)
      IF l_nHandle >= 0
           = FPUTS(l_nHandle, lp_cString)
           = FCLOSE(l_nHandle)
      ELSE
           MsgBox("Cannot create "+lp_cFile+lp_cExt+" !","Citadel Desk Interface",16)
      ENDIF
 ENDIF
 IF lp_lWithAct
      l_nHandle = FCREATE(lp_cFile+l_cActExt)
      IF l_nHandle >= 0
           DO CASE
                CASE TYPE("p_lSynchronise") = "L" AND p_lSynchronise
                     FWRITE(l_nHandle,"D")
                CASE lp_lUpdateOnly
                     FWRITE(l_nHandle,"U")
                OTHERWISE
           ENDCASE
           = FCLOSE(l_nHandle)
      ELSE
           MsgBox("Cannot create "+lp_cFile+l_cActExt+"!","Citadel Desk Interface",16)
      ENDIF
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE HasCreditForPTT
LPARAMETERS lp_cPhones
LOCAL l_nSelect, l_nTotAmt, l_curBalance

l_nSelect = SELECT()

* Check postings in DAT file.
l_nTotAmt = PttAmountFromDAT(lp_cPhones)

l_curBalance = SqlCursor("SELECT NVL(SUM(ps_amount),0) AS c_amt FROM post WHERE ps_reserid = "+SqlCnv(reservat.rs_reserid,.T.)+" AND ps_window = 2 AND NOT ps_cancel AND NOT ps_split")
IF USED(l_curBalance)
     * Check postings in DAT file!
     l_nTotAmt = l_nTotAmt + c_amt
ENDIF
DClose(l_curBalance)

SELECT (l_nSelect)

RETURN (l_nTotAmt < 0.00)
ENDPROC
*
PROCEDURE PttAmountFromDAT
LPARAMETERS lp_cPhones
* Get debit amount directly from DAT file, to add it to guest balance.
LOCAL i, l_nRetAmt, l_cFile, l_cPhone, l_cRow, l_cText, l_nQty, l_nAmt
LOCAL ARRAY l_aDat(1)

l_nRetAmt = 0.00

FOR i = 1 TO GETWORDCOUNT(lp_cPhones)
     l_cPhone = GETWORDNUM(lp_cPhones,i,",")
     IF NOT EMPTY(l_cPhone)
          GetFileName("PTT", @l_cFile, l_cPhone)
          l_cFile = FORCEEXT(l_cFile,"DAT")
          IF FILE(l_cFile)
               IF param.pa_pttcs
                    l_cText = FILETOSTR(l_cFile)
                    FOR i = 1 TO ALINES(l_aDat, l_cText)
                         l_cRow = l_aDat(i)
                         l_nQty = INT(VAL(GETWORDNUM(l_cRow,5,",")))
                         l_nAmt = VAL(STRTRAN(GETWORDNUM(l_cRow,6,","),",","."))
                         l_nRetAmt = l_nRetAmt + l_nQty * l_nAmt
                    ENDFOR
               ELSE
                    * TO DO: process SDF
               ENDIF
          ENDIF
     ENDIF
NEXT

RETURN l_nRetAmt
ENDPROC
*
PROCEDURE IfcAsciiPost
 PARAMETER p_Reserid, p_Roomnum
 PRIVATE ALL LIKE l_*
 loLdarea = SELECT()
 l_Oldrmrec = RECNO("room")
 l_Oldrmord = ORDER("room")
 nrEcreservat = RECNO("Reservat")
 SELECT roOm
 SET ORDER IN "room" TO 1
 IF (SEEK(p_Roomnum, "room"))
      IF (paRam.pa_posifc)
           IF UPPER(ALLTRIM(LEFT(roOm.rm_roomnum, 1)))="A"
                l_File = poSdir()+TRIM(SUBSTR(get_rm_rmname(roOm.rm_roomnum), 2, 10))+".DAT"
                DO asCiiread WITH l_File, "POS", p_Reserid, ""
           ELSE
                l_File = poSdir() + GetPOSFileName() + ".DAT"
                DO asCiiread WITH l_File, "POS", p_Reserid, ""
                IF ( .NOT. EMPTY(reServat.rs_keycard))
                     l_File = poSdir()+ALLTRIM(reServat.rs_keycard)+".DAT"
                     DO asCiiread WITH l_File, "POS", p_Reserid, ""
                ENDIF
           ENDIF
      ENDIF
      IF (paRam.pa_ptvifc)
               	IF param.PA_TELPTV
				m.paynum = ALLTRIM(roOm.rm_phone)
				IF AT(",",m.paynum)>0
					m.paynum = ALLTRIM(LEFT(m.paynum,AT(",",m.paynum)-1))
				ENDIF
				l_File = _screen.oGlobal.choteldir+"ifc\PTV\"+m.paynum +".DAT"
  	                  DO asCiiread WITH l_File, "PTV", p_Reserid, ""
			else
           IF UPPER(ALLTRIM(LEFT(roOm.rm_roomnum, 1)))="A"
                l_File = _screen.oGlobal.choteldir+"ifc\PTV\"+TRIM(SUBSTR(get_rm_rmname(roOm.rm_roomnum), 2,  ;
                         10))+".DAT"
                DO asCiiread WITH l_File, "PTV", p_Reserid, ""
           ELSE
                l_File = _screen.oGlobal.choteldir+"ifc\PTV\"+get_rm_rmname(roOm.rm_roomnum)+".DAT"
                l_File = IfcFixFileName(l_File)
                DO asCiiread WITH l_File, "PTV", p_Reserid, ""
           ENDIF
      ENDIF
      ENDIF
      IF (paRam.pa_keyifc)
           l_File = _screen.oGlobal.choteldir+"ifc\KEY\"+get_rm_rmname(roOm.rm_roomnum)+".DAT"
           DO asCiiread WITH l_File, "KEY", p_Reserid, ""
      ENDIF
      IF (paRam.pa_pttifc .AND.  .NOT. EMPTY(roOm.rm_phone))
           l_Dummy = ALLTRIM(roOm.rm_phone)+","
           IF (paRam.pa_pttvip)
                IF ( .NOT. EMPTY(adDress.ad_usr6))
                     l_Dummy = l_Dummy+ALLTRIM(adDress.ad_usr6)+","
                ENDIF
           ENDIF
           l_End = AT(",", l_Dummy)
           DO WHILE (l_End>0)
                l_Phone = ALLTRIM(SUBSTR(l_Dummy, 1, l_End-1))
                IF ( .NOT. EMPTY(l_Phone))
                     l_File = _screen.oGlobal.choteldir+"ifc\PTT\"+l_Phone+".DAT"
                     DO asCiiread WITH l_File, "PTT", p_Reserid, l_Phone
                ENDIF
                l_Dummy = SUBSTR(l_Dummy, l_End+1)
                l_End = AT(",", l_Dummy)
           ENDDO
      ENDIF
      IF (_screen.ogLOBAL.opARAM2.pa_intifc)
           l_File = _screen.oGlobal.choteldir+"ifc\INT\"+TRANSFORM(reservat.rs_rsid)+".DAT"
           DO asCiiread WITH l_File, "INT", p_Reserid, ""
      ENDIF
 ENDIF
 SELECT roOm
 SET ORDER TO l_OldRmOrd
 GOTO l_Oldrmrec IN "room"
 GOTO nrEcreservat IN "Reservat"
 SELECT (loLdarea)
 RETURN
ENDPROC
*
PROCEDURE AsciiRead
 PARAMETER p_File, p_Prefix, p_Reserid, p_Phone, p_DontCallBillinst
 LOCAL l_lContinue
 IF NOT EMPTY(_screen.oGlobal.cIfcBeforeReadDataFXP) AND FILE(_screen.oGlobal.choteldir+_screen.oGlobal.cIfcBeforeReadDataFXP)
      l_lContinue = .T.
      DO (_screen.oGlobal.choteldir+_screen.oGlobal.cIfcBeforeReadDataFXP) WITH l_lContinue
      IF NOT l_lContinue
           RETURN .T.
      ENDIF
 ENDIF
 PRIVATE cpOint, ldElimited, cBillInfo
 PRIVATE ALL LIKE l_*
 PUBLIC lnEterror
 LOCAL l_nSelect, l_lCloseIfcptt, l_lSearchForHigherWindow, cbillnrb, nposb, cbilldetailb, l_cLine, l_cBillHeader
 LOCAL ARRAY l_aWin(1)
 LOCAL ARRAY l_aDatFile(1)
 cBillInfo = ""
 l_cBillHeader = "Restaurant Nr." && Constant. Marks bill header in one line in DAT file when param2.pa_posssch = .T.
 l_Id = 0
 IF p_Prefix="INT"
      ldElimited = _screen.ogLOBAL.opARAM2.pa_intcs
 ELSE
      ldElimited = EVALUATE("Param.Pa_"+p_Prefix+"CS")
 ENDIF
 IF (FILE(p_File))
      l_Oldarea = SELECT()
      = crEateifctemp(ldElimited)
      SELECT ifCtemp
      IF IfcParseBillDetails(@l_aDatFile)
           cpOint = SET('point')
           SET POINT TO '.'
           IF ldElimited
                APPEND FROM (p_File) DELIMITED
           ELSE
                APPEND FROM (p_File) SDF
           ENDIF
           SET POINT TO cpOint
           IF (cpOint=",")
                REPLACE reSerid WITH STRTRAN(reSerid, ".", ",") ALL
           ENDIF
      ELSE
           lnEterror = .T.
      ENDIF
      IF (lnEterror)
           lnEterror = .F.
      ELSE
           DELETE FILE (p_File)
           IF p_Prefix = "PTT" AND param.pa_pttatbl AND FILE(gcDatadir+"ifcptt.dbf")
                l_nSelect = SELECT()
                l_lCloseIfcptt = .F.
                IF NOT USED("ifcptt")
                     openfiledirect(.F., "ifcptt")
                     l_lCloseIfcptt = .T.
                ENDIF
                SELECT (l_nSelect)
           ENDIF
           l_Previd = 0.000
           GOTO TOP IN "ifctemp"
           SCAN ALL
                SELECT poSt
                SCATTER BLANK MEMO MEMVAR
                SELECT ifCtemp
                M.ps_date = sySdate()
                M.ps_time = TIME()
                M.ps_userid = "INTERFACE"
                M.ps_artinum = GetIFCArticle(p_Prefix)
                M.ps_units = ifCtemp.quAntity
                = caLculate()
                IF (paRam.pa_pttrsid)
                     l_Id = VAL(ifCtemp.reSerid)
                ENDIF
                IF (EMPTY(l_Id))
                     l_Id = p_Reserid
                ENDIF
                l_lSearchForHigherWindow = _screen.oGlobal.lUgos AND INLIST(p_Prefix, "PTT")
                l_Window = IIF(_screen.oGlobal.lUgos AND INLIST(p_Prefix, "PTT"), 2, 1)
                l_Window = PBGetFreeWindow(l_Id, l_Window, l_lSearchForHigherWindow)
                IF NOT p_DontCallBillinst
                    DO biLlinstr IN BillInst WITH M.ps_artinum,  ;
                           reServat.rs_billins, l_Id, l_Window
                ENDIF
                IF (l_Id<>p_Reserid)
                     M.ps_supplem = get_rm_rmname(reServat.rs_roomnum)+" "+adDress.ad_lname
                ENDIF
                IF l_Previd=0.000
                     l_Previd = l_Id
                ENDIF
                IF l_Previd<>l_Id
                     l_Cancumulate = .F.
                     l_Previd = l_Id
                ELSE
                     l_Cancumulate = .T.
                ENDIF
                M.ps_reserid = l_Id
                M.ps_window = l_Window
                M.ps_origid = p_Reserid
                l_aWin(1) = l_Window
                DO BillsReserCheck IN ProcBill WITH l_Id, l_aWin, ;
                          "POST_NEW", .T., .T., .T.
                M.ps_ifc = OEMTOANSI(ifCtemp.roOmphone+" "+ifCtemp.daTe+ ;
                           " "+ifCtemp.tiMe+" "+TRIM(ifCtemp.inFo))
                l_Oldpsrec = RECNO("post")
                DO CASE
                     CASE p_Prefix=="PTT" .AND. paRam.pa_pttcumu .AND.  ;
                          M.ps_reserid>=0 .AND. dlOcate('Post', ;
                          'ps_reserid = '+sqLcnv(M.ps_reserid)+ ;
                          ' and ps_window = '+sqLcnv(M.ps_window)+ ;
                          ' and ps_artinum = '+sqLcnv(M.ps_artinum)+ ;
                          ' and ps_date = '+sqLcnv(sySdate())) .AND.  ;
                          l_Cancumulate
                          M.ps_amount = poSt.ps_amount+M.ps_amount
                          M.ps_units = poSt.ps_units+M.ps_units
                          M.ps_vat0 = poSt.ps_vat0+M.ps_vat0
                          M.ps_vat1 = poSt.ps_vat1+M.ps_vat1
                          M.ps_vat2 = poSt.ps_vat2+M.ps_vat2
                          M.ps_vat3 = poSt.ps_vat3+M.ps_vat3
                          M.ps_vat4 = poSt.ps_vat4+M.ps_vat4
                          M.ps_vat5 = poSt.ps_vat5+M.ps_vat5
                          M.ps_vat6 = poSt.ps_vat6+M.ps_vat6
                          M.ps_vat7 = poSt.ps_vat7+M.ps_vat7
                          M.ps_vat8 = poSt.ps_vat8+M.ps_vat8
                          M.ps_vat9 = poSt.ps_vat9+M.ps_vat9
                          M.ps_ifc = OEMTOANSI(poSt.ps_ifc+(CHR(13)+ ;
                                     CHR(10))+M.ps_ifc)
                          M.ps_time = TIME()
                          SELECT poSt
                          GATHER MEMO MEMVAR FIELDS ps_amount, ps_units,  ;
                                 ps_ifc, ps_time, ps_vat0, ps_vat1,  ;
                                 ps_vat2, ps_vat3, ps_vat4, ps_vat5,  ;
                                 ps_vat6, ps_vat7, ps_vat8, ps_vat9
                          SELECT ifCtemp
                     CASE p_Prefix=="PTV"
                          M.ps_postid = neXtid('Post')
                          INSERT INTO Post FROM MEMVAR
                          FLUSH
                     CASE p_Prefix=="POS" AND _screen.oglobal.oparam2.pa_posssch
                          * ****************************************************************************************************************************************
                          * "100","20180827","14:48","Restaurant Nr. 88729901",1,42.36,0.00,0.00,0.654206,0.00,2.08,0.00,0.00,0.00, 4.368403,0.00,"250","HOT","","",
                          * "100","20180827","14:53","Bier Krombacher        ",2, 2.80,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 0.728067,0.00,"250","HOT","","",
                          * "100","20180827","14:53","Altbierbolle           ",1, 3.20,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 0.510924,0.00,"250","HOT","","",
                          * "100","20180827","14:53","Calvados 0,2cl         ",3, 4.00,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 1.915966,0.00,"250","HOT","","",
                          * "100","20180827","14:53","Himmbergeist           ",1, 3.60,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 0.574790,0.00,"250","HOT","","",
                          * "100","20180827","14:53","Wiskey 0,2cl           ",1, 4.00,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 0.638655,0.00,"250","HOT","","",
                          * "100","20180827","14:53","Logis                  ",1,10.00,0.00,0.00,0.654206,0.00,0.00,0.00,0.00,0.00, 0.00    ,0.00,"250","HOT","","",
                          * "100","20180827","14:53","Zigaretten             ",1, 5.00,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 0.00    ,0.00,"250","HOT","","",
                          * "100","20180827","17:13","Restaurant Nr. 88729924",1,66.24,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00,10.576134,0.00,"250","HOT","","",
                          * "100","20180827","17:13","Bier Krombacher        ",3, 2.80,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 1.092101,0.00,"250","HOT","","",
                          * "100","20180827","17:13","Rumpsteak              ",2,21.20,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 6.769748,0.00,"250","HOT","","",
                          * "100","20180827","17:13","Toast Hawai            ",1,10.80,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 1.724370,0.00,"250","HOT","","",
                          * "100","20180827","17:13","Kümmerling             ",4, 1.55,0.00,0.00,0.00    ,0.00,0.00,0.00,0.00,0.00, 0.989916,0.00,"250","HOT","","",
                          * ****************************************************************************************************************************************
                          DO WHILE ( .NOT. EOF("ifctemp") .AND. SUBSTR(ifCtemp.inFo, 1, 14)==l_cBillHeader)
                               cbIllnumber = ALLTRIM(SUBSTR(ifCtemp.inFo, 15))
                               M.ps_units = 1
                               M.ps_ifc = GetLangText("INTERFAC","TXT_BILLNUMBER") + ": " + cbIllnumber
                               M.ps_amount = ifCtemp.amOunt
                               M.ps_supplem = GetLangText("INTERFAC","TXT_SHORTBILL") + ": " + cbIllnumber
                               IF (EMPTY(paRam.pa_vatconv))
                                    FOR ni = 0 TO 9
                                         cmAcro1 = "m.Ps_Vat"+STR(ni, 1)
                                         cmAcro2 = "IfcTemp.Vat"+STR(ni, 1)
                                         &cMacro1 = &cMacro2
                                    ENDFOR
                               ELSE
                                    STORE 0 TO M.ps_vat0, M.ps_vat1, M.ps_vat2, M.ps_vat3, M.ps_vat4, ;
                                         M.ps_vat5, M.ps_vat6, M.ps_vat7, M.ps_vat8, M.ps_vat9
                                    ccOnvert = STRTRAN(param.pa_vatconv, " ")
                                    FOR ni = 1 TO GETWORDCOUNT(ccOnvert,",")
                                         cmAcro1 = "m.Ps_Vat"+STREXTRACT(GETWORDNUM(ccOnvert, ni, ","),"","=")
                                         cmAcro2 = "IfcTemp.Vat"+STREXTRACT(GETWORDNUM(ccOnvert, ni, ","),"=","")
                                         &cMacro1 = &cMacro2
                                    ENDFOR
                               ENDIF
                               M.ps_postid = neXtid('Post')
                               SKIP 1 IN ifCtemp
                               DO WHILE ( .NOT. EOF("ifctemp") .AND. SUBSTR(ifCtemp.inFo, 1, 14)<>l_cBillHeader)
                                    M.ps_ifc = M.ps_ifc + (CHR(13) + CHR(10)) + STR(ifCtemp.quAntity, 3) + " " + PADR(ALLTRIM(ifCtemp.inFo),40) + " " + STR(ifCtemp.quAntity*ifCtemp.amOunt, 10, 2)
                                    SKIP 1 IN ifCtemp
                               ENDDO
                               SKIP -1 IN ifCtemp
                               INSERT INTO Post FROM MEMVAR
                               FLUSH
                               IF (paRam.pa_topost)
                                    SELECT poSt
                                    SCATTER MEMO MEMVAR
                                    M.ps_amount = -1*M.ps_amount
                                    M.ps_units = -1
                                    M.ps_reserid = 0.100
                                    M.ps_origid = 0.100
                                    M.ps_supplem = "Touch PoS"
                                    FOR ni = 1 TO 9
                                         cmAcro1 = "m.Ps_Vat"+STR(ni, 1)
                                         &cMacro1 = (&cMacro1 * -1)
                                    ENDFOR
                                    M.ps_postid = neXtid('Post')
                                    INSERT INTO Post FROM MEMVAR
                                    FLUSH
                               ENDIF
                               SKIP 1 IN ifCtemp
                          ENDDO
                     CASE p_Prefix=="POS" AND (param.pa_posrmus OR param.pa_postpos OR param.pa_argus)
                          cbIllnumber = LEFT(ifCtemp.inFo, 8)
                          M.ps_units = 1
                          M.ps_ifc = GetLangText("INTERFAC","TXT_BILLNUMBER")+ ;
                                     ":"+LEFT(ifCtemp.inFo, 8)+(CHR(13)+ ;
                                     CHR(10))+ ;
                                     ALLTRIM(STR(ifCtemp.quAntity))+" * "+ ;
                                     OEMTOANSI(SUBSTR(ifCtemp.inFo, 9))+ ;
                                     STR(ifCtemp.amOunt, 12, 2)
                          M.ps_amount = ifCtemp.amOunt
                          M.ps_supplem = GetLangText("INTERFAC","TXT_SHORTBILL")+ ;
                           ":"+ALLTRIM(LEFT(ifCtemp.inFo, 8))
                          IF (EMPTY(paRam.pa_vatconv))
                               FOR ni = 0 TO 9
                                    cmAcro1 = "m.Ps_Vat"+STR(ni, 1)
                                    cmAcro2 = "IfcTemp.Vat"+STR(ni, 1)
                                    &cMacro1 = &cMacro2
                               ENDFOR
                          ELSE
                               STORE 0 TO M.ps_vat0, M.ps_vat1, M.ps_vat2, M.ps_vat3, M.ps_vat4, ;
                                    M.ps_vat5, M.ps_vat6, M.ps_vat7, M.ps_vat8, M.ps_vat9
                               ccOnvert = STRTRAN(param.pa_vatconv, " ")
                               FOR ni = 1 TO GETWORDCOUNT(ccOnvert,",")
                                    cmAcro1 = "m.Ps_Vat"+STREXTRACT(GETWORDNUM(ccOnvert, ni, ","),"","=")
                                    cmAcro2 = "IfcTemp.Vat"+STREXTRACT(GETWORDNUM(ccOnvert, ni, ","),"=","")
                                    &cMacro1 = &cMacro2
                               ENDFOR
                          ENDIF
                          M.ps_postid = neXtid('Post')
                          INSERT INTO Post FROM MEMVAR
                          FLUSH
                          SKIP 1 IN ifCtemp
                          DO WHILE ( .NOT. EOF("ifctemp") .AND.  ;
                             LEFT(ifCtemp.inFo, 8)==cbIllnumber)
                               M.ps_amount = M.ps_amount+ifCtemp.amOunt
                               M.ps_ifc = M.ps_ifc+(CHR(13)+CHR(10))+ ;
                                ALLTRIM(STR(ifCtemp.quAntity))+" * "+ ;
                                OEMTOANSI(SUBSTR(ifCtemp.inFo, 9))+ ;
                                STR(ifCtemp.amOunt, 12, 2)
                               IF (EMPTY(paRam.pa_vatconv))
                                    FOR ni = 0 TO 9
                                         cmAcro1 = "m.Ps_Vat"+STR(ni, 1)
                                         cmAcro2 = "IfcTemp.Vat"+STR(ni, 1)
                                         &cMacro1 = &cMacro1 + &cMacro2
                                    ENDFOR
                               ELSE
                                    ccOnvert = STRTRAN(param.pa_vatconv, " ")
                                    FOR ni = 1 TO GETWORDCOUNT(ccOnvert,",")
                                         cmAcro1 = "m.Ps_Vat"+STREXTRACT(GETWORDNUM(ccOnvert, ni, ","),"","=")
                                         cmAcro2 = "IfcTemp.Vat"+STREXTRACT(GETWORDNUM(ccOnvert, ni, ","),"=","")
                                         &cMacro1 = &cMacro1 + &cMacro2
                                    ENDFOR
                               ENDIF
                               SKIP 1 IN ifCtemp
                          ENDDO
                          SKIP -1 IN ifCtemp
                          SELECT poSt
                          REPLACE poSt.ps_amount WITH M.ps_amount
                          REPLACE poSt.ps_ifc WITH M.ps_ifc
                          FOR ni = 0 TO 9
                               cmAcro1 = "m.Ps_Vat"+STR(ni, 1)
                               cmAcro2 = "Post.Ps_Vat"+STR(ni, 1)
                               Replace &cMacro2 With &cMacro1
                          ENDFOR
                          IF (paRam.pa_topost)
                               SELECT poSt
                               SCATTER MEMO MEMVAR
                               M.ps_amount = -1*M.ps_amount
                               M.ps_units = -1
                               M.ps_reserid = 0.100
                               M.ps_origid = 0.100
                               M.ps_supplem = "Touch PoS"
                               FOR ni = 1 TO 9
                                    cmAcro1 = "m.Ps_Vat"+STR(ni, 1)
                                    &cMacro1 = (&cMacro1 * -1)
                               ENDFOR
                               M.ps_postid = neXtid('Post')
                               INSERT INTO Post FROM MEMVAR
                               FLUSH
                          ENDIF
                     CASE p_Prefix=="POS"
                          l_cLine = ""
                          TRY
                               l_cLine = l_aDatFile(RECNO("ifctemp"))
                          CATCH
                          ENDTRY
                          IF NOT EMPTY(l_cLine) AND CHR(2) $ l_cLine
                               * Add bill details
                               cbillnrb = STREXTRACT(l_cLine,CHR(2),CHR(3))
                               nposb = AT(CHR(3),l_cLine)
                               cbilldetailb = SUBSTR(l_cLine,nposb+1)
                               IF NOT EMPTY(cbilldetailb)
                                    M.ps_ifc = STRTRAN(cbilldetailb,CHR(4),CHR(13)+CHR(10))
                               ENDIF
                               IF NOT EMPTY(cbillnrb)
                                    M.ps_supplem = IIF(M.ps_amount<0,"Storno:","Rechnung:") + cbillnrb
                               ENDIF
                          ENDIF
                          M.ps_postid = neXtid('Post')
                          INSERT INTO Post FROM MEMVAR
                          FLUSH
                     OTHERWISE
                          M.ps_postid = neXtid('Post')
                          INSERT INTO Post FROM MEMVAR
                          FLUSH
                ENDCASE
                GOTO l_Oldpsrec IN "post"
           ENDSCAN
           IF param.pa_pttatbl AND l_lCloseIfcptt AND USED("ifcptt")
                USE IN ifcptt
           ENDIF
      ENDIF
      SELECT ifCtemp
      USE
      SELECT (l_Oldarea)
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE IfcParseBillDetails
LPARAMETERS lp_aDatFile
EXTERNAL ARRAY lp_aDatFile
LOCAL l_cTmpFile, l_cTmpFileFull, l_lSuccess, l_nLines, l_cFileCont, l_cFileContNew, i, l_cLine, l_nPos, l_cNewLine, ;
          y, k, l_cTmpDir
* p_File is used here, as PRIVATE variable!
* DAT File contents are returned in lp_aDatFile array too
l_lSuccess = .T.
l_cTmpFile = SYS(2015)
l_cTmpDir = ADDBS(JUSTPATH(p_File))
l_cTmpFileFull = l_cTmpDir+l_cTmpFile
IF FILE(l_cTmpFileFull)
     l_lSuccess = .F.
     FOR k = 1 TO 50
          l_cTmpFile = SYS(2015)
          l_cTmpFileFull = l_cTmpDir + l_cTmpFile
          = Sleep(1)
          wait window "" timeout .001
          DOEVENTS
          IF NOT FILE(l_cTmpFileFull)
               l_lSuccess = .T.
               EXIT
          ENDIF
     ENDFOR
ENDIF
IF NOT l_lSuccess
     RETURN l_lSuccess
ENDIF

l_lSuccess = .T.
FOR y = 1 TO 3
     TRY
          RENAME (p_File) TO (l_cTmpFileFull)
     CATCH
          l_lSuccess = .F.
     ENDTRY
     IF l_lSuccess OR y=3
          EXIT
     ELSE
          l_lSuccess = .T.
          = Sleep(1)
          wait window "" timeout .001
          DOEVENTS
     ENDIF
ENDFOR
IF l_lSuccess
     p_File = l_cTmpFileFull
     cBillInfo = FILETOSTR(l_cTmpFileFull)
     l_nLines = ALINES(lp_aDatFile,cBillInfo)
     IF CHR(2) $ cBillInfo AND CHR(3) $ cBillInfo
          l_cFileContNew = ""
          FOR i = 1 TO l_nLines
                * Add bill details
               l_cLine = lp_aDatFile(i)
               IF CHR(2) $ l_cLine
                    l_nPos = AT(CHR(2), l_cLine)-1
                    l_cNewLine = SUBSTR(l_cLine,1,l_nPos) + CHR(13) + CHR(10)
               ELSE
                    l_cNewLine = l_cLine + CHR(13) + CHR(10)
               ENDIF
               l_cFileContNew = l_cFileContNew + l_cNewLine
          ENDFOR
          STRTOFILE(l_cFileContNew,p_File)
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
FUNCTION Calculate
 PRIVATE ALL LIKE l_*
 l_Oldarea = SELECT()
 l_Oldarrec = RECNO("article")
 l_Oldarord = ORDER("article")
 l_Oldplrec = RECNO("picklist")
 l_Oldplord = ORDER("picklist")
 l_Vatnum = 1
 l_Vatpct = 0
 SELECT arTicle
 SET ORDER TO TAG1
 IF (SEEK(M.ps_artinum, "article"))
      IF (EMPTY(ifCtemp.amOunt))
           IF (p_Prefix="PTT" .AND.  .NOT. EMPTY(paRam.pa_pttlim1))
                M.ps_amount = MIN(ifCtemp.quAntity, paRam.pa_pttlim1)* ;
                              paRam.pa_pttprc1+MAX(0,  ;
                              MIN(ifCtemp.quAntity-paRam.pa_pttlim1,  ;
                              paRam.pa_pttlim2-paRam.pa_pttlim1))* ;
                              paRam.pa_pttprc2+MAX(0,  ;
                              MIN(ifCtemp.quAntity-paRam.pa_pttlim2, 9999- ;
                              paRam.pa_pttlim2))*paRam.pa_pttprc3
           ELSE
                M.ps_amount = ifCtemp.quAntity*arTicle.ar_price
           ENDIF
      ELSE
           M.ps_amount = ifCtemp.amOunt
      ENDIF
      IF (EMPTY(ifCtemp.vaT1+ifCtemp.vaT2+ifCtemp.vaT3+ifCtemp.vaT4+ ;
         ifCtemp.vaT5+ifCtemp.vaT6+ifCtemp.vaT7+ifCtemp.vaT8+ifCtemp.vaT9+ifCtemp.vaT0))
           M.ps_vat0 = 0
           M.ps_vat1 = 0
           M.ps_vat2 = 0
           M.ps_vat3 = 0
           M.ps_vat4 = 0
           M.ps_vat5 = 0
           M.ps_vat6 = 0
           M.ps_vat7 = 0
           M.ps_vat8 = 0
           M.ps_vat9 = 0
           SELECT piCklist
           SET ORDER IN "picklist" TO 3
           IF (SEEK(PADR("VATGROUP", 10)+STR(arTicle.ar_vat, 3)))
                l_Vatnum = arTicle.ar_vat
                l_Vatpct = piCklist.pl_numval
           ENDIF
           SET ORDER IN "picklist" TO l_OldPlOrd
           GOTO l_Oldplrec IN "picklist"
           l_Vat = "m.ps_vat"+LTRIM(STR(l_Vatnum))
           &l_Vat	= m.ps_amount * (1 - (100 / (100 + l_VatPct)))
      ELSE
           M.ps_vat0 = ifCtemp.vaT0
           M.ps_vat1 = ifCtemp.vaT1
           M.ps_vat2 = ifCtemp.vaT2
           M.ps_vat3 = ifCtemp.vaT3
           M.ps_vat4 = ifCtemp.vaT4
           M.ps_vat5 = ifCtemp.vaT5
           M.ps_vat6 = ifCtemp.vaT6
           M.ps_vat7 = ifCtemp.vaT7
           M.ps_vat8 = ifCtemp.vaT8
           M.ps_vat9 = ifCtemp.vaT9
      ENDIF
      IF M.ps_amount <> 0 AND M.ps_units <> 0
           TRY
                M.ps_price = M.ps_amount / M.ps_units
           CATCH
           ENDTRY
      ENDIF
 ENDIF
 SET ORDER IN "article" TO l_OldArOrd
 GOTO l_Oldarrec IN "article"
 SELECT (l_Oldarea)
 RETURN .T.
ENDFUNC
*
PROCEDURE IfcAsciiAudit
 PRIVATE ALL LIKE l_*
 PRIVATE a_Files
 IF (_SCREEN.IS or _SCREEN.IK or _SCREEN.IT or _SCREEN.IP)
	 l_Oldarea = SELECT()
	 l_Oldrmrec = RECNO("room")
	 IF (opEnfile(.F.,"ifclost"))
	      IF (paRam.pa_posifc)
	           = reAdasciifiles("POS")
	      ENDIF
	      IF (paRam.pa_keyifc)
	           = reAdasciifiles("KEY")
	      ENDIF
	      IF (paRam.pa_pttifc)
	           = reAdasciifiles("PTT")
	      ENDIF
	      IF (paRam.pa_ptvifc)
	           = reAdasciifiles("PTV")
	      ENDIF
	 ENDIF
	 IF (USED("ifclost"))
	      SELECT ifClost
	      USE
	 ENDIF
	 GOTO l_Oldrmrec IN "room"
	 SELECT (l_Oldarea)
ENDIF 
IF _screen.oGlobal.oParam2.pa_intifc
     * Delete old OUT files
     DeleteIfc("INT","OUT",.T.)
ENDIF
RETURN .T.
ENDPROC
*
FUNCTION CreateIfcTemp
 PARAMETER plDelimited
 IF plDelimited
      CREATE CURSOR IfcTemp (roOmphone C (4), daTe C (8), tiMe C (8),  ;
             inFo C (40), quAntity N (4), amOunt N (12, 2), vaT0 N (8, 2),  ;
             vaT1 N (14, 6), vaT2 N (14, 6), vaT3 N (14, 6), vaT4 N (14, 6),  ;
             vaT5 N (14, 6), vaT6 N (14, 6), vaT7 N (14, 6), vaT8 N (14, 6),  ;
             vaT9 N (14, 6), arTicle N (4), dePartment C (3), chEcksum C  ;
             (12), reSerid C (12))
 ELSE
      CREATE CURSOR IfcTemp (roOmphone C (4), daTe C (8), tiMe C (8),  ;
             inFo C (25), quAntity N (4), amOunt N (12, 2), vaT1 N (14, 6),  ;
             vaT2 N (14, 6), vaT3 N (14, 6), vaT4 N (14, 6), vaT5 N (14, 6),  ;
             arTicle N (4), dePartment C (3), chEcksum C (12), vaT0 N (8,  ;
             2), vaT6 N (14, 6), vaT7 N (14, 6), vaT8 N (14, 6), vaT9 N (14,  ;
             6), reSerid C (12))
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION ReadAsciiFiles
 PARAMETER p_Cifctype
 PRIVATE ldElimited, cpOint
 PUBLIC lnEterror
 LOCAL l_nOldarea
 l_nOldarea = SELECT()
 ldElimited = EVALUATE("Param.Pa_"+p_Cifctype+"CS")
 = ADIR(a_Files, _screen.oGlobal.choteldir+"ifc\"+p_Cifctype+"\*.DAT")
 IF (TYPE("a_Files[1,1]")=="C")
      = crEateifctemp(ldElimited)
      SELECT ifCtemp
      l_Len = ALEN(a_Files, 1)
      FOR l_I = 1 TO l_Len
           IF param2.pa_poseigz
                l_cRoomNum = PADR(GETWORDNUM(a_Files(l_I,1),1,"."),4)
                IF DLookUp("room", "rm_roomnum=" + sqlcnv(l_cRoomNum), "NOT FOUND()")
                     LOOP
                ENDIF
           ENDIF
           l_File = _screen.oGlobal.choteldir+"ifc\"+p_Cifctype+"\"+a_Files(l_I,1)
           cpOint = SET('point')
           SET POINT TO '.'
           IF ldElimited
                APPEND FROM (l_File) DELIMITED
           ELSE
                APPEND FROM (l_File) SDF
           ENDIF
           SET POINT TO cpOint
           IF (lnEterror)
                lnEterror = .F.
           ELSE
                DELETE FILE (l_File)
           ENDIF
      ENDFOR
      SELECT ifCtemp
      GOTO TOP IN "ifctemp"
      SCAN WHILE  .NOT. EOF("ifctemp")
           l_Macro = "param.pa_"+p_Cifctype+"arti"
           l_Article    = &l_Macro
           M.ps_date = sySdate()
           M.ps_time = ifCtemp.tiMe
           M.ps_room = ifCtemp.roOmphone
           M.ps_amount = ifCtemp.amOunt
           M.ps_artinum = IIF(EMPTY(ifCtemp.arTicle), l_Article,  ;
                          ifCtemp.arTicle)
           M.ps_units = ifCtemp.quAntity
           M.ps_ifc = OEMTOANSI(ifCtemp.roOmphone+" "+ifCtemp.daTe+" "+ ;
                      ifCtemp.tiMe+" "+ifCtemp.inFo)
           INSERT INTO ifclost FROM MEMVAR
      ENDSCAN
      SELECT ifCtemp
      USE
 ENDIF
 SELECT(l_nOldarea)
 RETURN .T.
ENDFUNC
*
FUNCTION Synchronise
 LOCAL l_nArea, l_lRoomIN, l_cRoomnum, l_cOrder, l_nRecno, adLg, l_lGI, l_lGC, l_nNewVal, y, l_lSuccess
 PRIVATE p_lSynchronise

 p_lSynchronise = .T.

 IF MsgBox(GetLangText("INTERFAC","TXT_SYNCALL"),GetLangText("INTERFAC","TXT_SYNCMSG"),036) = 6
      IF _screen.oGlobal.lUgos
           DIMENSION adLg[2, 8]
           adLg[1, 1] = "GI"
           adLg[1, 2] = "GI - CheckIN"
           adLg[1, 3] = ".F."
           adLg[1, 4] = "@*C"
           adLg[1, 5] = 11
           adLg[1, 6] = ""
           adLg[1, 7] = ""
           adLg[1, 8] = .F.
           adLg[2, 1] = "GC"
           adLg[2, 2] = "GC - GuestChange"
           adLg[2, 3] = ".F."
           adLg[2, 4] = "@*C"
           adLg[2, 5] = 11
           adLg[2, 6] = ""
           adLg[2, 7] = ""
           adLg[2, 8] = .F.
           IF diAlog("Welches Datensatz?","",@adLg)
                l_lGI = adLg(1,8)
                l_lGC = adLg(2,8)
                DO CASE
                     CASE l_lGI AND l_lGC
                          l_nNewVal = 3
                     CASE l_lGI
                          l_nNewVal = 1
                     CASE l_lGC
                          l_nNewVal = 2
                     OTHERWISE
                          l_nNewVal = 0
                ENDCASE
                
                IF NOT EMPTY(l_nNewVal)
                     FOR y = 1 TO 10
                          l_lSuccess = .T.
                          TRY
                               STRTOFILE(TRANSFORM(l_nNewVal),_screen.oGlobal.choteldir+"ifc\ptv\ugossync.txt",0)
                          CATCH
                               l_lSuccess = .F.
                          ENDTRY
                          IF l_lSuccess
                               EXIT
                          ELSE
                               sleep(100)
                          ENDIF
                     ENDFOR
                     Alert("OK!")
                ELSE
                     alert(GetLangText("COMMON","TXT_NOTHING_MARKED")+"!")
                ENDIF
           ENDIF
      RETURN .T.
      ENDIF

      l_nArea = SELECT()

      WAIT WINDOW NOWAIT "Deleting ifc IN/OUT files..."

      IF param.pa_pttifc AND param.pa_pttsync
           DeleteIfc("Ptt","IN")
           DeleteIfc("Ptt","OUT")
           DeleteIfc("Ptt","ACT")
           DeleteIfc("Ptt\WakeUp","WAK")
           DeleteIfc("Ptt\Message","MSG")
      ENDIF
      IF param.pa_posifc AND param.pa_possync
           DeleteIfc("Pos","IN")
           DeleteIfc("Pos","OUT")
           DeleteIfc("Pos","ACT")
      ENDIF
      IF param.pa_keyifc AND param.pa_keysync
      ENDIF
      IF param.pa_ptvifc AND param.pa_ptvsync
           DeleteIfc("Ptv","IN")
           DeleteIfc("Ptv","OUT")
           DeleteIfc("Ptv","ACT")
           DeleteIfc("Ptv","WAK")
           DeleteIfc("Ptv","MSG")
      ENDIF
      IF param2.pa_intifc AND param2.pa_intsync
           DeleteIfc("Int","IN")
           DeleteIfc("Int","OUT")
           DeleteIfc("Int","ACT")
      ENDIF
      
      WAIT WINDOW NOWAIT "Getting reservations and room data..."
      
      l_cResCur = sqlcursor("SELECT rs_rsid, rs_roomnum, rs_rmname, rs_status FROM reservat WHERE rs_status = 'IN ' OR " + ;
                "(rs_status = 'OUT' AND rs_depdate = " + sqlcnv(param.pa_sysdate,.T.) + ") ORDER BY 2")
      l_cRoomCur = sqlcursor("SELECT rm_roomnum, rm_rmname, rt_group, rs_msgshow, rs_message FROM room " + ;
                "INNER JOIN roomtype ON rm_roomtyp = rt_roomtyp ORDER BY 2")
      
      SELECT (l_cRoomCur)
      l_cFor = IIF(param2.pa_syncstd,"INLIST(rt_group,1,2)",".T.")
      SCAN FOR &l_cFor
           WAIT WINDOW NOWAIT "Check room:" + rm_rmname
           DOEVENTS
           * Is there IN reservierung for this room?
           SELECT (l_cResCur)
           LOCATE FOR rs_roomnum = &l_cRoomCur..rm_roomnum AND rs_status = 'IN '
           l_lRoomIN = FOUND()
           SELECT (l_cRoomCur)
           IF l_lRoomIN AND SEEK(&l_cResCur..rs_rsid,"reservat","tag33")
                * We found reservation for this room. Mark it as IN.
                IfcCheck(ALLTRIM(&l_cRoomCur..rm_roomnum), "CHECKIN", .T.)
                IF param.pa_pttmess AND &l_cRoomCur..rs_msgshow
                     * Write pending messages for this reservation.
                     DO WriteMessageWaiting IN MsgEdit WITH &l_cRoomCur..rm_roomnum, &l_cRoomCur..rs_message, .T.
                ENDIF
           ELSE
                * No IN Reservation. Are there OUT reservations for today?
                SELECT (l_cResCur)
                LOCATE FOR rs_roomnum = &l_cRoomCur..rm_roomnum AND rs_status = 'OUT'
                IF NOT (FOUND() AND SEEK(&l_cResCur..rs_rsid,"reservat","tag33"))
                     * No. Then use blank reservat record for OUT file.
                     SELECT reservat
                     GO BOTTOM
                     SKIP 1
                ENDIF
                IfcCheck(ALLTRIM(&l_cRoomCur..rm_roomnum), "CHECKOUT", .T.)
           ENDIF
      ENDSCAN
      
      dclose(l_cResCur)
      dclose(l_cRoomCur)

      DO SyncWakes IN WakeUp

      WAIT CLEAR

      SELECT(l_nArea)
 ENDIF

 RETURN .T.
ENDFUNC
*
FUNCTION DeleteIfc
 PARAMETER cdIrname, ceXtension, lonlywithoutact
 PRIVATE acDirectory
 PRIVATE ni
 LOCAL ldeleteit
 IF (UPPER(cdIrname)=="POS")
      cdIrname = poSdir()
 ELSE
      cdIrname = _screen.oGlobal.choteldir+"ifc\"+cdIrname
 ENDIF
 IF (ADIR(acDirectory, cdIrname+"\*."+ceXtension)>0)
      FNWaitWindow(GetLangText("INTERFAC","TXT_DELETE_FILES_IN")+" " + cdIrname + " ("+ceXtension+")",.T.)
      FOR ni = 1 TO ALEN(acDirectory, 1)
           ldeleteit = .T.
           IF lonlywithoutact
                IF FILE(cdIrname+"\"+FORCEEXT(acDirectory(ni,1),"ACT"))
                     ldeleteit = .F.
                ENDIF
           ENDIF
           IF ldeleteit
                DELETE FILE (cdIrname+"\"+acDirectory(ni,1))
           ENDIF
      ENDFOR
      FNWaitWindow(,,,.T.)
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION RoomStat
 LOCAL l_cErrorText, l_oLogger, ni, nhAndle, crOomnumber, csTaffcode, crOomstatus, cread4spaces, creadnewstatus 
 LOCAL ARRAY acDirectory(1)

 IF _screen.oGlobal.oParam.pa_pttstat
      IF ADIR(acDirectory, _screen.oGlobal.choteldir+"ifc\Ptt\Status\*.STA") > 0
           nsTarea = SELECT()
           l_oLogger = CREATEOBJECT("ProcLogger")
           l_oLogger.cTable = "room"
           l_oLogger.cKeyExp = "rm_roomnum"
           FOR ni = 1 TO ALEN(acDirectory, 1)
                FNWaitWindow("Room Status",.T.)
                cfIlename = _screen.oGlobal.choteldir+"ifc\Ptt\Status\"+acDirectory(ni,1)
                nhAndle = FOPEN(cfIlename)
                LOCAL LGetRoomnum
                LGetRoomnum = ""
                LGetRoomnum = ALLTRIM(FREAD(nhAndle, 5))
                IF EMPTY(LGetRoomnum)
                     crOomnumber = ""
                ELSE
                     crOomnumber = RoomNr(LGetRoomnum)
                ENDIF
                IF _screen.oGlobal.lIfcRoomStatIsChar
                     cread4spaces = FREAD(nhAndle, 4)
                     csTaffcode = "    "
                     creadnewstatus = FREAD(nhAndle, 2)
                     IF creadnewstatus = "CL"
                          crOomstatus = "1"
                     ELSE
                          crOomstatus = "0"
                     ENDIF
                ELSE
                     csTaffcode = FREAD(nhAndle, 4)
                     crOomstatus = FREAD(nhAndle, 1)
                ENDIF
                = FCLOSE(nhAndle)
                IF " " $ cfIlename
                     IF TYPE("g_myshell") = "O" AND NOT ISNULL(g_myshell)
                          g_myshell.Run([%COMSPEC% /C del "] + cfIlename + [" /q],0)
                     ELSE
                          l_cErrorText = "File " + cfIlename  + " can't be deleted!" + CHR(13) + CHR(10)
                          = alert(l_cErrorText)
                          = loGdata(l_cErrorText, "hotel.err")
                     ENDIF
                ELSE
                     DELETE FILE (cfIlename)
                ENDIF
                IF SEEK(PADR(crOomnumber,4), "Room", "tag1") AND SEEK("STATUS    "+STR(VAL(ALLTRIM(crOomstatus)),3), "PickList", "tag3") AND Room.rm_status <> PADR(PickList.pl_charcod,4)
                     WAIT WINDOW NOWAIT "Changing room status"
                     l_oLogger.SetOldval("room")
                     REPLACE rm_status WITH PickList.pl_charcod IN room
                     l_oLogger.SetNewVal()
                     l_oLogger.Save()
                ENDIF
                FNWaitWindow(,,,.T.)
           ENDFOR
           SELECT (nsTarea)
      ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
FUNCTION PosDir
 PRIVATE cpOsname
 IF (EMPTY(paRam.pa_aposdir))
      cpOsname = _screen.oGlobal.choteldir+"ifc\POS\"
 ELSE
      cpOsname = STRTRAN(ALLTRIM(paRam.pa_aposdir)+"\", "\\", "\")
 ENDIF
 RETURN cpOsname
ENDFUNC
*
FUNCTION BoothNumber
 LPARAMETERS lp_cPhone
 LOCAL l_nReserid, l_cPoint
 l_cPoint = SET("Point")
 IF l_cPoint = ","
      lp_cPhone = STRTRAN(lp_cPhone, ".", ",")
 ELSE
      lp_cPhone = STRTRAN(lp_cPhone, ",", ".")
 ENDIF
 l_nReserid = VAL(lp_cPhone)
 IF ABS(l_nReserid) < 10
      * For phone booth with numeral <10.
      * Booth 1: ReserID -10001 and so on until Booth 9: ReserID -10009
      l_nReserid = 10000 + ABS(INT(l_nReserid))
 ENDIF
 RETURN l_nReserid
ENDFUNC
*
FUNCTION BoothRead
 PRIVATE cdUmmy
 PRIVATE neNd
 PRIVATE cpHone
 cdUmmy = ALLTRIM(paRam.pa_pttcel)+","
 neNd = AT(",", cdUmmy)
 DO WHILE (neNd>0)
      cpHone = ALLTRIM(SUBSTR(cdUmmy, 1, neNd-1))
      IF ( .NOT. EMPTY(cpHone))
           FNWaitWindow(GetLangText("INTERFAC","TXT_READ_BOOTH")+" "+cpHone,.T.)
           cfIle = _screen.oGlobal.choteldir+"ifc\PTT\"+cpHone+".DAT"
           nrId = BoothNumber(cpHone)*-1
           DO asCiiread WITH cfIle, "PTT", nrId, nrId, .T.
      ENDIF
      cdUmmy = SUBSTR(cdUmmy, neNd+1)
      neNd = AT(",", cdUmmy)
 ENDDO
 WAIT CLEAR
 RETURN .T.
ENDFUNC
*
PROCEDURE PosChkIn
 PARAMETER pcFile, pcBuff, plAction
 PRIVATE nhAndle, cnEwbuff, ctMp, caCtfile
 *IF FILE(pcFile)
 *     nhAndle = FOPEN(pcFile, 2)
 *ELSE
      nhAndle = FCREATE(pcFile)
 *ENDIF
 IF (nhAndle>=0)
      cnEwbuff = pcBuff
      DO WHILE  .NOT. FEOF(nhAndle)
           ctMp = FGETS(nhAndle)
           IF  .NOT. EMPTY(ctMp)
                cnEwbuff = cnEwbuff+CHR(13)+CHR(10)+ctMp
           ENDIF
      ENDDO
      = FSEEK(nhAndle, 0, 0)
      = FWRITE(nhAndle, cnEwbuff)
      = FCLOSE(nhAndle)
 ELSE
      = msGbox("Cannot create "+pcFile+" !","Brilliant Interface",16)
 ENDIF
 IF plAction
      caCtfile = STRTRAN(pcFile, '.IN', '.ACT')
      nhAndle = FCREATE(caCtfile)
      IF nhAndle=-1
           = msGbox("Cannot create "+caCtfile+" !","Brilliant Interface",16)
      ELSE
           = FCLOSE(nhAndle)
      ENDIF
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE PosChkOut
 PARAMETER pcFile, pnReserid, plAction
 PRIVATE nhAndle, cbUff, cnEwbuff, niDstart, caCtfile
 nhAndle = 0
 cbUff = ""
 cnEwbuff = ""
 niDstart = 108
 IF FILE(pcFile)
      nhAndle = FOPEN(pcFile, 2)
      IF (nhAndle>=0)
           DO WHILE  .NOT. FEOF(nhAndle)
                cbUff = FGETS(nhAndle)
                IF SUBSTR(cbUff, niDstart, 12)<>STR(pnReserid, 12, 3)
                     cnEwbuff = cnEwbuff+cbUff+CHR(13)+CHR(10)
                ENDIF
           ENDDO
           IF  .NOT. EMPTY(cnEwbuff)
                = FSEEK(nhAndle, 0, 0)
                = FWRITE(nhAndle, cnEwbuff)
                = FCHSIZE(nhAndle, LEN(cnEwbuff))
                = FCLOSE(nhAndle)
           ELSE
                = FCLOSE(nhAndle)
                DELETE FILE (pcFile)
           ENDIF
      ELSE
           = msGbox("Cannot create "+pcFile+" !","Brilliant Interface",16)
      ENDIF
 ENDIF
 IF plAction
      caCtfile = STRTRAN(pcFile, '.IN', '.ACT')
      nhAndle = FCREATE(caCtfile)
      IF nhAndle=-1
           = msGbox("Cannot create "+caCtfile+" !","Brilliant Interface",16)
      ELSE
           = FCLOSE(nhAndle)
      ENDIF
 ENDIF
 RETURN
ENDPROC
*
PROCEDURE GetIFCArticle
 LPARAMETERS lp_cPrefix
 LOCAL l_nArtiNum, l_DontUseIfcptt, l_nSelect, l_nRecNoArticle, l_lCloseIfcptt
 l_nArtiNum = 0
 l_DontUseIfcptt = .T.
 IF lp_cPrefix = "PTT" AND param.pa_pttatbl AND FILE(gcDatadir+"ifcptt.dbf")
      l_nSelect = SELECT()
      l_lCloseIfcptt = .F.
      IF NOT USED("ifcptt")
           openfiledirect(.F., "ifcptt")
           l_lCloseIfcptt = .T.
      ENDIF
      IF USED("ifcptt")
           l_nRecNoArticle = RECNO("article")
           SELECT ifcptt
           LOCATE FOR ifcptt.it_phone == ifctemp.roomphone
           IF FOUND() AND SEEK(ifcptt.it_artinum,"article","tag1")
                l_nArtiNum = ifcptt.it_artinum
                l_DontUseIfcptt = .F.
                IF EMPTY(ifcptt.it_price)
                     IF NOT EMPTY(article.ar_price)
                          REPLACE ifctemp.amount WITH ;
                               ifctemp.quantity*article.ar_price, ;
                               ifctemp.vat0 WITH 0, ;
                               ifctemp.vat1 WITH 0, ;
                               ifctemp.vat2 WITH 0, ;
                               ifctemp.vat3 WITH 0, ;
                               ifctemp.vat4 WITH 0, ;
                               ifctemp.vat5 WITH 0, ;
                               ifctemp.vat6 WITH 0, ;
                               ifctemp.vat7 WITH 0, ;
                               ifctemp.vat8 WITH 0, ;
                               ifctemp.vat9 WITH 0 ;
                               IN ifctemp
                     ENDIF
                ELSE
                     REPLACE ifctemp.amount WITH ;
                          ifctemp.quantity*ifcptt.it_price ;
                          ifctemp.vat0 WITH 0, ;
                          ifctemp.vat1 WITH 0, ;
                          ifctemp.vat2 WITH 0, ;
                          ifctemp.vat3 WITH 0, ;
                          ifctemp.vat4 WITH 0, ;
                          ifctemp.vat5 WITH 0, ;
                          ifctemp.vat6 WITH 0, ;
                          ifctemp.vat7 WITH 0, ;
                          ifctemp.vat8 WITH 0, ;
                          ifctemp.vat9 WITH 0 ;                                              
                          IN ifctemp
                ENDIF
           ENDIF
           GO l_nRecNoArticle IN article
           IF l_lCloseIfcptt AND USED("ifcptt")
                USE IN ifcptt
           ENDIF
      ENDIF
      SELECT (l_nSelect)
 ENDIF
 IF l_DontUseIfcptt
      l_nArtiNum = ifCtemp.arTicle
      IF EMPTY(l_nArtiNum) .OR.  .NOT. dlOokup('Article', ;
        'ar_artinum = '+sqLcnv(l_nArtiNum),'Found()')
           IF lp_cPrefix = "INT"
                l_nArtiNum = _screen.ogLOBAL.opARAM2.pa_intarti
           ELSE
                l_nArtiNum = EVALUATE("param.pa_"+lp_cPrefix+"arti")
           ENDIF
      ENDIF
 ENDIF
 RETURN l_nArtiNum
ENDPROC
*
PROCEDURE CreateInterfaceString
LPARAMETERS lp_cStringType, lp_cCardType, lp_nNumberOfCards, lp_cValue1, lp_nCardId, ;
     lp_cCardNum, lp_cString, lp_lUpdateOnly, lp_cOldRoomnum, pcClassOfService, pcIntExt
lp_cString = ""
LOCAL l_cFName, l_cLName, l_cTitle, l_lUsed, l_lFound, l_cUpdate, l_cOldPhone, l_cOldPhones, l_dBirth, ;
          l_nSelect, l_cPin, l_cCur, l_cOldRmName, l_lVip, l_cRmName
STORE "" TO l_cFName, l_cLName, l_cTitle, l_cOldPhone, l_cPin, l_cCur, l_cOldRmName
l_dBirth = {}

l_cUpdate = IIF(lp_lUpdateOnly,"U"," ")

IF NOT EMPTY(lp_cOldRoomnum) AND TYPE("lp_cOldRoomnum")="C"
     l_cOldPhones = DLookUp("room", "rm_roomnum = " + SqlCnv(PADR(lp_cOldRoomnum,4)), "rm_phone")
     l_cOldPhone = ALLTRIM(GETWORDNUM(l_cOldPhones,1,","))
     l_cOldRmName = DLookUp("room", "rm_roomnum = " + SqlCnv(PADR(lp_cOldRoomnum,4)), "rm_rmname")
ENDIF
l_cOldPhone = PADR(l_cOldPhone,8)
l_cOldRmName = PADR(l_cOldRmName,10)
IF EMPTY(pcClassOfService)
     pcClassOfService = "0"
ENDIF
pcClassOfService = PADL(SUBSTR(pcClassOfService,1,2),2,"0")

=SEEK(reservat.rs_addrid,"address","tag1")

IF reServat.rs_addrid = reServat.rs_compid AND NOT EMPTY(reServat.rs_apname)
     * guest is apartner
     l_lUsed = USED("apartner")
     IF NOT l_lUsed
          l_lUsed = openfile(.F.,"apartner")
     ENDIF
     IF l_lUsed
          IF reservat.rs_apid <> apartner.ap_apid
               l_lFound = SEEK(reservat.rs_apid,"apartner","tag3")
          ELSE
               l_lFound = .T.
          ENDIF
          IF l_lFound
               l_cLName = apartner.ap_lname
               l_cFName = apartner.ap_fname
               l_cTitle = apartner.ap_title
               l_dBirth = apartner.ap_gebdate
               l_lVip = apartner.ap_vip1
          ENDIF
     ENDIF
ELSE
     l_cLName = adDress.ad_lname
     l_cFName = adDress.ad_fname
     l_cTitle = adDress.ad_title
     l_dBirth = adDress.ad_birth
     l_lVip = adDress.ad_vip
ENDIF

IF lp_cStringType = "INT"
     l_nSelect = SELECT()
     l_cCur = sqlcursor("SELECT rn_pin FROM resifcin WHERE rn_rsid = " + TRANSFORM(reservat.rs_rsid))
     IF USED(l_cCur) AND RECCOUNT(l_cCur)>0
          l_cPin = &l_cCur..rn_pin
     ENDIF
     dclose(l_cCur)
     SELECT (l_nSelect)
     IF NOT _screen.oGlobal.lUgos
          * Allways enable internet for address
          IF EMPTY(lp_cValue1)
               lp_cValue1 = "1"
          ENDIF
     ENDIF
ENDIF

IF EMPTY(lp_cValue1) OR lp_cStringType = "POS"
     lp_cValue1 = adDress.ad_usr6
ENDIF

l_cRmName = PADR(ALLTRIM(get_rm_rmname(IIF(TYPE("p_cForceRoomNum")="C" AND NOT EMPTY(p_cForceRoomNum),p_cForceRoomNum,reServat.rs_roomnum))),10)

lp_cString = lp_cCardType+STR(lp_nNumberOfCards, 1)+ ;
        PADR(ANSITOOEM(l_cLName), 25)+ ;
        PADR(ANSITOOEM(l_cFName), 10)+PADR(l_cTitle,  ;
        10)+PADR(adDress.ad_lang, 3)+DTOS(reServat.rs_arrdate)+ ;
        DTOS(reServat.rs_depdate)+IIF(VAL(reServat.rs_arrtime)==0,  ;
        SPACE(8), reServat.rs_arrtime+":00")+ ;
        IIF(VAL(reServat.rs_deptime)==0, SPACE(8),  ;
        reServat.rs_deptime+":00")+PADR(address.ad_company, 25)+ ;
        STR(reServat.rs_reserid, 12, 3)+PADR(lp_cValue1, 10)+ ;
        PADR(wiNpc(), 15)+PADR(ANSITOOEM(reServat.rs_group), 25)+;
        PADR(ANSITOOEM(Get_rt_roomtyp(reServat.rs_roomtyp, "RTRIM(rd_roomtyp)")), 6)+;
        PADL(ALLTRIM(STR(lp_nCardId, 8, 0)),8,"0")+;
        ANSITOOEM("21")+ANSITOOEM(lp_cCardNum)+;
        l_cUpdate+;
        l_cOldPhone+;
        PADL(TRANSFORM(reServat.rs_rsid),10)+;
        pcClassOfService + ;
        l_cRmName + ;
        DTOS(l_dBirth)+;
        PADR(ALLTRIM(l_cPin),12)+;
        l_cOldRmName+;
        IIF(l_lVip,"1","0")+;
        reservat.rs_status

RETURN lp_cString
ENDPROC
*
PROCEDURE GetCardInitValues
 LPARAMETERS lp_cStringType, lp_aResults
 EXTERNAL ARRAY lp_aResults
 LOCAL l_lResult, l_cValue, l_cString, l_cClass, i
 lp_aResults(1,1) = "TYPE"
 lp_aResults(1,2) = lp_cStringType
 IF _screen.oGlobal.lUgos
      l_cClass = GetIfcClass("PTV")
      DIMENSION lp_aResults(11,2)
      FOR i = 1 TO 10
           lp_aResults(i+1,1) = "OPTIONDEFAULT" + TRANSFORM(i)
           lp_aResults(i+1,2) = ("1" = SUBSTR(l_cClass,i,1))
      NEXT
 ELSE
      l_lResult = .F.
      IF FILE(_screen.oGlobal.choteldir+"ifc.ini")
           CREATE CURSOR curifc (ifcline C(240))
           APPEND FROM (_screen.oGlobal.choteldir+"ifc.ini") TYPE SDF
           SCAN FOR ifcline = "["+lp_cStringType+"]"
                l_lResult = .T.
                SKIP 1
                EXIT
           ENDSCAN
      ENDIF
      IF l_lResult
           SCAN REST WHILE NOT ifcline = "["
                l_cValue = getinivalue()
                l_cString = getinivariable()
                DO CASE
                CASE l_cString = "OPTIONCOUNT"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONCOUNT"
                     lp_aResults(ALEN(lp_aResults,1),2) = VAL(l_cValue)
                CASE l_cString = "OPTIONTEXT1"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONTEXT1"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONTEXT2"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONTEXT2"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONTEXT3"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONTEXT3"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONTEXT4"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONTEXT4"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONTEXT5"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONTEXT5"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONDEFAULT1"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONDEFAULT1"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("OPD",l_cValue)
                CASE l_cString = "OPTIONDEFAULT2"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONDEFAULT2"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("OPD",l_cValue)
                CASE l_cString = "OPTIONDEFAULT3"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONDEFAULT3"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("OPD",l_cValue)
                CASE l_cString = "OPTIONDEFAULT4"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONDEFAULT4"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("OPD",l_cValue)
                CASE l_cString = "OPTIONDEFAULT5"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONDEFAULT5"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("OPD",l_cValue)
                CASE l_cString = "STATUSDEFAULT"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "STATUSDEFAULT"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("STD",l_cValue)
                CASE l_cString = "TOARRIVEROOMS"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "TOARRIVEROOMS"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("ARR",l_cValue)
                CASE l_cString = "DUMMYROOMS"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "DUMMYROOMS"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("OPD",l_cValue)
                CASE l_cString = "CONFROOMS"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "CONFROOMS"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("OPD",l_cValue)
                CASE l_cString = "CARDCOUNTDEFAULT"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "CARDCOUNTDEFAULT"
                     lp_aResults(ALEN(lp_aResults,1),2) = getsetting("STD",l_cValue)
                CASE l_cString = "OPTIONITECKEYLOCK1"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONITECKEYLOCK1"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONITECKEYLOCK2"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONITECKEYLOCK2"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONITECKEYLOCK3"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONITECKEYLOCK3"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "OPTIONITECKEYLOCK4"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "OPTIONITECKEYLOCK4"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "ITECSYSTEMCODE"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "ITECSYSTEMCODE"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                CASE l_cString = "ITECHOTELCODE"
                     DIMENSION lp_aResults(ALEN(lp_aResults,1)+1,2)
                     lp_aResults(ALEN(lp_aResults,1),1) = "ITECHOTELCODE"
                     lp_aResults(ALEN(lp_aResults,1),2) = l_cValue
                ENDCASE
           ENDSCAN
      ENDIF
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE getinivalue
 LOCAL n
 n = AT("=",ifcline,1)
 RETURN ALLTRIM(SUBSTR(ifcline, n+1, LEN(ALLTRIM(ifcline))-n))
ENDPROC
*
PROCEDURE getinivariable
 LOCAL n
 n = AT("=",ifcline,1)
 RETURN ALLTRIM(UPPER(LEFT(ifcline,n-1)))
ENDPROC
*
PROCEDURE GetFileName
 * param.dbf, roomplan.dbf and reservat.dbf must be opened and record should be selected
 * File name is returned thru lp_cFileName parameter, as reference
 LPARAMETERS lp_cCardType, lp_cFileName, lp_cPhoneNo
 LOCAL l_cPhoneNumer
 l_cPhoneNumer = ""
 lp_cFileName = ""
 DO CASE
 CASE lp_cCardType = "PTV"
      IF param.pa_telptv
           l_cPhoneNumer = ALLTRIM(roOm.rm_phone)
           IF AT(",",l_cPhoneNumer)>0
                l_cPhoneNumer = ALLTRIM(LEFT(l_cPhoneNumer,AT(",",l_cPhoneNumer)-1))
           ENDIF
           lp_cFileName = _screen.oGlobal.choteldir+"ifc\PTV\" + l_cPhoneNumer
      ELSE
           IF UPPER(LEFT(ALLTRIM(roOm.rm_roomnum), 1))="A" .AND.  .NOT.  ;
                     (reServat.rs_out="1" .OR. EOF("reservat"))
                lp_cFileName = _screen.oGlobal.choteldir+"ifc\PTV\"+TRIM(SUBSTR(get_rm_rmname(roOm.rm_roomnum), 2, 10))
           ELSE
                lp_cFileName = _screen.oGlobal.choteldir+"ifc\PTV\"+get_rm_rmname(roOm.rm_roomnum)
           ENDIF
      ENDIF
 CASE lp_cCardType = "KEY"
      lp_cFileName = _screen.oGlobal.choteldir+"ifc\KEY\"+get_rm_rmname(roOm.rm_roomnum)
 CASE lp_cCardType = "PTT"
      lp_cFileName = _screen.oGlobal.choteldir+"ifc\PTT\"+ALLTRIM(lp_cPhoneNo)
 CASE lp_cCardType = "INT"
      lp_cFileName = _screen.oGlobal.choteldir+"ifc\INT\"+TRANSFORM(reservat.rs_rsid)
 ENDCASE
 RETURN .T.
ENDPROC
*
PROCEDURE GetIfcClass
LPARAMETERS lp_cType
LOCAL i, l_cClass, l_nArea, l_cSql, l_cCurClasses
IF lp_cType = "INT"
     l_cClass = REPLICATE(" ",10)
ELSE
     l_cClass = REPLICATE("0",10)
ENDIF
IF _screen.oGlobal.lUgos AND INLIST(UPPER(lp_cType), "PTT", "PTV", "INT")
     l_nArea = SELECT()

     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT rk_<<lp_cType>>cls AS rk_class, rn_<<lp_cType>>cls AS rn_class FROM rpostifc 
          LEFT JOIN resifcin ON rk_rsid = rn_rsid 
          WHERE rk_rsid = <<SqlCnv(reservat.rs_rsid, .T.)>> AND BETWEEN(<<SqlCnv(Sysdate(), .T.)>>, rk_from, rk_to) AND 
          NOT rk_deleted AND EMPTY(rk_dsetid)
     ENDTEXT
     l_cCurClasses = SqlCursor(l_cSql)
     FOR i = 1 TO 10
          IF "1" = SUBSTR(rk_class,i,1) AND "1" = SUBSTR(rn_class,i,1)
               l_cClass = STUFF(l_cClass,i,1,"1")
          ENDIF
     ENDFOR
     DClose(l_cCurClasses)

     SELECT(l_nArea)
ENDIF

RETURN l_cClass
ENDPROC
*
PROCEDURE getsetting
 LPARAMETERS pl_cType,pl_cValue
 DO CASE
 CASE INLIST(pl_cType, "OPD", "ARR")
      LOCAL l_lResult
      l_lResult = .F.
      IF UPPER(pl_cValue) = "YES"
           l_lResult = .T.
      ELSE
           IF NOT EMPTY(pl_cValue) AND NOT UPPER(pl_cValue) = "NO"
                LOCAL l_cOnError
                l_cOnError = ON("ERROR")
                ON ERROR DO errorifcsettings
                l_lResult = EVALUATE(pl_cValue)
                ON ERROR &l_cOnError
           ENDIF
      ENDIF
      RETURN l_lResult
 CASE pl_cType = "STD"
      LOCAL l_nResult
      l_nResult = 1
      IF INLIST(UPPER(pl_cValue),"0","1")
           l_nResult = VAL(pl_cValue)
      ELSE
           IF NOT EMPTY(pl_cValue)
                LOCAL l_cOnError
                l_cOnError = ON("ERROR")
                ON ERROR DO errorifcsettings
                l_nResult = EVALUATE(pl_cValue)
                ON ERROR &l_cOnError
           ENDIF
      ENDIF
      RETURN ALLTRIM(STR(l_nResult))
 OTHERWISE
      RETURN .T.
 ENDCASE
ENDPROC
*
PROCEDURE errorifcsettings
 = alert(GetLangText("INTERFAC","TXT_WRONG_SETTINGS"))
 RETURN .T.
ENDPROC
*
FUNCTION GetPOSFileName
 LPARAMETERS lp_cFileName
 LOCAL l_cFileName, l_cRoomnum, l_cPOSRoomnum
 l_cRoomnum = room.rm_roomnum
 IF param.pa_posrmus
      IF EMPTY(room.rm_user1)
           l_cPOSRoomnum = Get_rm_rmname(l_cRoomnum)
      ELSE
           l_cPOSRoomnum = ALLTRIM(room.rm_user1)
      ENDIF
      l_cFileName = l_cPOSRoomnum
 ELSE
      l_cFileName = Get_rm_rmname(l_cRoomnum)
 ENDIF
 lp_cFileName = l_cFileName
 RETURN l_cFileName
ENDFUNC
*
PROCEDURE IfcFixFileName
 LPARAMETERS lp_cFile
 IF _screen.oGlobal.lUgos
      IF NOT EMPTY(lp_cFile)
          * For Ugos mode, replace "/" with "."
          lp_cFile = STRTRAN(lp_cFile,"/",".")
      ENDIF
 ENDIF
 RETURN lp_cFile
ENDPROC
*
PROCEDURE IfcEnergie
 LPARAMETERS lp_cRoomNum, lp_cAction, lp_lAutoOn, lp_dArrDate, lp_dDepDate
 IF NOT param2.pa_tempcon
      RETURN .T.
 ENDIF
 
 LOCAL l_oEModul AS cenergiemodul OF interfac.prg

 l_oEModul = NEWOBJECT("cenergiemodul","interfac.prg")
 l_oEModul.Start(lp_cRoomNum, lp_cAction, lp_lAutoOn, lp_dArrDate, lp_dDepDate, reservat.rs_benum)
 l_oEModul.Release()

 RETURN .T.
ENDPROC
*
PROCEDURE IfcEnergieAutoOn
LOCAL l_cSql, l_cCurTerm, l_nSelect, l_cCurRes, l_lAutoOn
l_lAutoOn = .T.

l_nSelect = SELECT()

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT tm_entime, NVL(tm_endate, <<sqlcnv({^2000-1-1},.T.)>>) AS c_endate FROM terminal ;
     WHERE tm_winname = <<sqlcnv(PADR(winpc(),15),.T.)>> AND NOT tm_entime = <<sqlcnv(SPACE(5),.T.)>>
ENDTEXT

l_cCurTerm = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
IF USED(l_cCurTerm) AND RECCOUNT(l_cCurTerm)>0
     * This is workstation, which is checking for reservations.
     IF &l_cCurTerm..c_endate < _screen.oglobal.oParam.pa_sysdate AND &l_cCurTerm..tm_entime < TIME()
          * Check reservations
          IF odbc()
               TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
               SELECT rs_roomnum, rs_arrdate, rs_depdate FROM reservat ;
                    INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp ;
                    WHERE rs_arrdate = <<sqlcnv(sysdate(),.T.)>> AND ;
                    NOT (rs_status IN ('OUT', 'NS', 'CXL', 'IN')) AND NOT rs_roomnum = '    ' ;
                    AND rt_group IN (1,4) ;
                    ORDER BY rs_rmname
               ENDTEXT
          ELSE
               TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
               SELECT rs_roomnum, rs_arrdate, rs_depdate FROM reservat ;
                    INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp ;
                    WHERE DTOS(rs_arrdate)+rs_lname = <<sqlcnv(DTOS(sysdate()))>> ;
                    AND NOT (rs_status IN ('OUT', 'NS', 'CXL', 'IN')) AND NOT rs_roomnum = '    ' ;
                    AND rt_group IN (1,4) ;
                    ORDER BY rs_rmname
               ENDTEXT
          ENDIF
          l_cCurRes = sqlcursor(l_cSql,"",.F.,"",.NULL.,.T.)
          IF USED(l_cCurRes) AND RECCOUNT(l_cCurRes)>0
               SCAN ALL
                    DO IfcEnergie WITH &l_cCurRes..rs_roomnum, "CHECKIN", l_lAutoOn, &l_cCurRes..rs_arrdate, &l_cCurRes..rs_depdate
               ENDSCAN
          ENDIF
          sqlupdate("terminal", ;
                    "tm_winname = " + sqlcnv(PADR(winpc(),15),.T.), ;
                    "tm_endate = " + sqlcnv(_screen.oglobal.oParam.pa_sysdate,.T.))
          sqlupdate("reschg","ch_chid=0","ch_refresh=ch_refresh+1") && Refresh roomplan
          DBTableFlushForce()
     ENDIF
ENDIF

dclose(l_cCurTerm)
dclose(l_cCurRes)

SELECT(l_nSelect)

RETURN .T.
ENDPROC
*
*
*
DEFINE CLASS cenergiemodul AS Custom
*
nselect = 0
cRoomNum = ""
cAction = ""
lAutoOn = .F.
dArrDate = {}
dDepDate = {}
nBeNum  =0
cRmName = ""
cBeCur = ""
cAdvancedHeating = "Vorheizen"
cDelimiter = ";"
cFilePath = ""
cFilePrefix = ""
cFileName = ""
cIniLoc = ""
lEnergieROA = .F.
cXMLResponse = ""
cXMLLogFile = ""
lEnergiePriva = .F.
cPrivaUrl = ""
cPRIVARoomName = ""
*
PROCEDURE Init
this.cIniLoc = FULLPATH(INI_FILE)
this.cXMLLogFile =  _screen.oGlobal.choteldir+"msr-priva.log"
RETURN .T.
ENDPROC
*
PROCEDURE Start
LPARAMETERS lp_cRoomNum, lp_cAction, lp_lAutoOn, lp_dArrDate, lp_dDepDate, lp_nBeNum
this.nSelect = SELECT()
this.cRoomNum = lp_cRoomNum
this.cAction = lp_cAction
this.lAutoOn = lp_lAutoOn
this.dArrDate = lp_dArrDate
this.dDepDate = lp_dDepDate
this.nBeNum = lp_nBeNum
this.cRmName = ALLTRIM(dlookup("room","rm_roomnum = " + sqlcnv(PADR(this.cRoomNum,4),.T.),"rm_rmname"))

this.cBeCur = sqlcursor("SELECT be_lang" + g_langnum + " AS c_lang, be_tempera FROM bproener WHERE be_benum = " + ;
          TRANSFORM(this.nBeNum))

this.InitROA()
this.InitPRIVA()

DO CASE
     CASE lp_cAction = "CHECKOUT"
          this.OnCheckOut()
     CASE lp_lAutoOn
          this.OnAuto()
     OTHERWISE
          * CHECKIN
          this.OnCheckIn()
ENDCASE

SELECT (this.nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE OnCheckOut
IF this.lEnergieROA
     this.OnCheckOutROA()
ENDIF
IF this.lEnergiePriva
     this.OnCheckOutPRIVA()
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE OnAuto
IF this.lEnergieROA
     this.OnAutoROA()
ENDIF
IF this.lEnergiePriva
     this.OnAutoPRIVA()
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE OnCheckIn
IF this.lEnergieROA
     this.OnCheckInROA()
ENDIF
IF this.lEnergiePriva
     this.OnCheckInPRIVA()
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE InitROA
this.cFilePath = readini(this.cIniLoc, "System","EModul", "")
IF NOT EMPTY(this.cFilePath)
     this.lEnergieROA = .T.
     this.cFilePrefix = readini(this.cIniLoc, "System","EModulFilePrefix", "")
     this.cFileName = FORCEEXT(this.cFilePrefix + this.cRmName,"ROA")
     this.cFilePath = ADDBS(this.cFilePath) + this.cFileName
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE OnCheckOutROA
IF FILE(this.cFilePath)
     STRTOFILE("",this.cFilePath,0)
     *DELETE FILE (l_cFilePath)
ENDIF
sqlupdate("room", ;
     "rm_roomnum = " + sqlcnv(PADR(this.cRoomNum,4),.T.), ;
     "rm_tempera = " + sqlcnv(_screen.oGlobal.oParam2.pa_tempout,.T.))
RETURN .T.
ENDPROC
*
PROCEDURE OnAutoROA
LOCAL l_cPoint, l_cString
l_cPoint = SET("Point")
SET POINT TO "."
l_cString = this.ROADate(this.dArrDate) + this.cDelimiter + ;
          this.ROADate(this.dDepDate) + this.cDelimiter + ;
          this.cAdvancedHeating + this.cDelimiter + ;
          CHR(13) + CHR(10)
SET POINT TO l_cPoint
STRTOFILE(l_cString,this.cFilePath,0)
sqlupdate("room", ;
     "rm_roomnum = " + sqlcnv(PADR(this.cRoomNum,4),.T.), ;
     "rm_tempera = " + sqlcnv(_screen.oGlobal.oParam2.pa_tempin,.T.))
RETURN .T.
ENDPROC
*
PROCEDURE OnCheckInROA
LOCAL l_cPoint, l_cString
l_cPoint = SET("Point")
SET POINT TO "."
l_cString = this.ROADate(this.dArrDate) + this.cDelimiter + ;
          this.ROADate(this.dDepDate) + this.cDelimiter + ;
          ALLTRIM(EVALUATE(this.cBeCur + ".c_lang")) + this.cDelimiter + ;
          CHR(13) + CHR(10)
SET POINT TO l_cPoint
STRTOFILE(l_cString,this.cFilePath,0)

sqlupdate("room", ;
     "rm_roomnum = " + sqlcnv(PADR(this.cRoomNum,4),.T.), ;
     "rm_tempera = " + sqlcnv(_screen.oGlobal.oParam2.pa_tempin,.T.))

RETURN .T.
ENDPROC
*
PROCEDURE ROADate
LPARAMETERS lp_dDate
RETURN RIGHT(ALLTRIM(STR(YEAR(lp_dDate))),2) + ;
          PADL(ALLTRIM(STR(MONTH(lp_dDate))),2,"0") + ;
          PADL(ALLTRIM(STR(DAY(lp_dDate))),2,"0")
ENDPROC
*
* PRIVA
*
PROCEDURE InitPRIVA
this.lEnergiePriva = IIF(LOWER(readini(this.cIniLoc, "System","EModulPriva", "no"))="yes",.T.,.F.)
IF this.lEnergiePriva
     this.cPrivaUrl = readini(this.cIniLoc, "System","EModulPrivaUrl", "")
     this.cPRIVARoomName = ALLTRIM(this.cRmName)
     IF EMPTY(this.cPrivaUrl)
          this.lEnergiePriva = .F.
     ENDIF
ENDIF
RETURN .T.
ENDPROC
*
PROCEDURE OnCheckOutPRIVA
LOCAL l_cCmd, l_lSuccess
l_cCmd = "?Raum"+this.cPRIVARoomName+"=0"
l_lSuccess = this.SendHttp(l_cCmd)

IF l_lSuccess
     sqlupdate("room", ;
          "rm_roomnum = " + sqlcnv(PADR(this.cRoomNum,4),.T.), ;
          "rm_tempera = " + sqlcnv(_screen.oGlobal.oParam2.pa_tempout,.T.))
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE OnAutoPRIVA
LOCAL l_cCmd, l_nNewTemperature, l_lSuccess

l_cBeCur = sqlcursor("SELECT be_tempera FROM bproener WHERE be_benum = " + ;
          TRANSFORM(_screen.oGlobal.oterminal.tm_benum))
IF USED(l_cBeCur) AND RECCOUNT(l_cBeCur)>0 AND NOT EMPTY(&l_cBeCur..be_tempera)
     l_nNewTemperature = &l_cBeCur..be_tempera
ELSE
     l_nNewTemperature = EVALUATE(this.cBeCur + ".be_tempera")
ENDIF

l_cCmd = "?Raum"+this.cRmName+"=1"

IF NOT EMPTY(l_nNewTemperature)
     l_cCmd = l_cCmd + "&Raum"+this.cPRIVARoomName+"_soll="+this.PIVAFormatTemperature(l_nNewTemperature)
ENDIF

l_lSuccess = this.SendHttp(l_cCmd)

IF l_lSuccess
     IF EMPTY(l_nNewTemperature)
          * Set default temperature for room, to be visible in roomplan.
          l_nNewTemperature = _screen.oGlobal.oParam2.pa_tempin
     ENDIF
     sqlupdate("room", ;
          "rm_roomnum = " + sqlcnv(PADR(this.cRoomNum,4),.T.), ;
          "rm_tempera = " + sqlcnv(l_nNewTemperature,.T.))
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE OnCheckInPRIVA
LOCAL l_cCmd, l_nNewTemperature, l_lSuccess
l_nNewTemperature = EVALUATE(this.cBeCur + ".be_tempera")

l_cCmd = "?Raum"+this.cRmName+"=1"

IF NOT EMPTY(l_nNewTemperature)
     l_cCmd = l_cCmd + "&Raum"+this.cPRIVARoomName+"_soll="+this.PIVAFormatTemperature(l_nNewTemperature)
ENDIF

l_lSuccess = this.SendHttp(l_cCmd)

IF l_lSuccess
     IF EMPTY(l_nNewTemperature)
          * Set default temperature for room, to be visible in roomplan.
          l_nNewTemperature = _screen.oGlobal.oParam2.pa_tempin
     ENDIF
     sqlupdate("room", ;
          "rm_roomnum = " + sqlcnv(PADR(this.cRoomNum,4),.T.), ;
          "rm_tempera = " + sqlcnv(l_nNewTemperature,.T.))
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE PIVAFormatTemperature
LPARAMETERS lp_nTemp
RETURN STRTRAN(TRANSFORM(lp_nTemp),",",".")
ENDPROC
*
PROCEDURE SendHttp
LPARAMETERS lp_cParam
LOCAL l_cServer, l_oHttp, l_cHttpSendError, l_oErr, l_lSuccess
l_cServer = this.cPrivaUrl + lp_cParam

this.cXMLResponse = l_cServer
this.LogItXml("SEND")

l_oHttp = CREATEOBJECT("MSXML2.ServerXMLHTTP")
l_oHttp.Open("GET", l_cServer, .F.)
l_oHttp.setRequestHeader('Content-Type', 'text/xml')
l_oHttp.setRequestHeader('Charset', 'UTF-8')

l_cHttpSendError = ""
TRY
     l_oHttp.send()
CATCH TO l_oErr
     l_cHttpSendError = "Error:"+TRANSFORM(l_oErr.ErrorNo) + ;
               "|Message:"+TRANSFORM(l_oErr.Message)
ENDTRY
IF EMPTY(l_cHttpSendError)
     this.cXMLResponse = l_oHTTP.responseText
     l_lSuccess = .T.
ELSE
     this.cXMLResponse = l_cHttpSendError
ENDIF

this.LogItXml("RESPONSE")

l_oHttp = .NULL.

RETURN l_lSuccess
ENDPROC
*
PROCEDURE LogItXml
LPARAMETERS lp_cCmd
LOCAL l_cFile2, l_nLimit, l_cFakedXMLReq

l_cFile2 = this.cXMLLogFile + ".2"
l_nLimit = 50000000 && 50 MB

IF FILE(this.cXMLLogFile)
     IF ADIR(l_aFile,LOCFILE(this.cXMLLogFile))>0
          IF l_aFile(2)>l_nLimit
               IF FILE(l_cFile2)
                    DELETE FILE (l_cFile2)
               ENDIF
               RENAME (p_cXMLLogFile) TO (l_cFile2)
          ENDIF
     ENDIF
ENDIF

TRY
     STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cCmd+CHR(10)+CHR(13)+REPLICATE("-",50)+CHR(10)+CHR(13)+;
               this.cXMLRESPONSE+CHR(10)+CHR(13)+;
               REPLICATE("-",50)+CHR(10)+CHR(13),this.cXMLLogFile,1)
CATCH
ENDTRY
RETURN .T.
ENDPROC
*
PROCEDURE Release
dclose(this.cBeCur)
RELEASE this
ENDPROC
*
ENDDEFINE
*
*
*
DEFINE CLASS ckeycardhafele AS Custom
*
cLogFile = "keyhafele.log"
cMsgHookMacro = "" && Name of method to which should be message sent, as parameter
cXML = ""
lEndDetected = "" && When .T., exit from sending/receiving loop
*

PROCEDURE Init
this.CreateWinSock()
RETURN .T.
ENDPROC
*
PROCEDURE WinSockUnvailable
IF VARTYPE(this.owscnt)<>"O"
     RETURN .T.
ENDIF
RETURN .F.
ENDPROC
*
PROCEDURE CheckIn(lp_cRoom AS String, lp_cKeyType AS String, lp_dDepDate AS Date, lp_cDepTime AS String, ;
          lp_cAccess AS String, lp_nNoOfKeys AS Integer, lp_nRsId AS Integer) AS Logical
LOCAL l_cTN, l_cCA, l_cDEP, l_lSuccess

IF this.WinSockUnvailable()
     RETURN .F.
ENDIF

* Prepare XML

l_cTN = TRANSFORM(nextid("TNHAFELE"))
l_cCA = IIF(TRANSFORM(lp_cKeyType)="E","2","1") && 2 - Copy card, 1 - New card
IF VARTYPE(lp_dDepDate) = "D"
     * <DEP>2004-06-05T11:00:00</DEP>
     l_cDEP = TRANSFORM(YEAR(lp_dDepDate)) + "-" + PADL(MONTH(lp_dDepDate),2,"0") + "-" + PADL(DAY(lp_dDepDate),2,"0")
     l_cDEP = l_cDEP + "T" + IIF(EMPTY(lp_cDepTime),"12:00:00",lp_cDepTime+":00")
ELSE
     l_cDEP = ""
ENDIF

TEXT TO this.cXML TEXTMERGE NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<datazone-document>
     <TN><<l_cTN>></TN>
     <OC>CI</OC>
     <CS><<ALLTRIM(_screen.oGlobal.oterminal.tm_hcoder)>></CS>
     <CA><<l_cCA>></CA>
     <DEP><<l_cDEP>></DEP>
     <RN><<lp_cRoom>></RN>
     <AP><<LEFT(lp_cAccess,4)>></AP>
     <NC><<TRANSFORM(lp_nNoOfKeys)>></NC>
     <GID><<TRANSFORM(lp_nRsId)>></GID>
     <ORG><<winpc()>></ORG>
</datazone-document>
ENDTEXT

* Send XML

l_lSuccess = this.SendCmd()

RETURN l_lSuccess
ENDPROC
*
PROCEDURE SendCmd
LOCAL l_oXML, l_tCounter, l_cResponse, l_oOneNode, l_cCmd, l_cMsg, l_lSuccess
this.LogIt(winpc()+"|Connecting")
this.MsgHook("Connecting")
IF this.owscnt.Connect(ALLTRIM(_screen.oGlobal.oterminal.tm_haddres), _screen.oGlobal.oterminal.tm_hport)
     this.MsgHook("Connected.")
     this.LogIt(winpc()+"|-->|"+this.cXML)
     this.owscnt.Send(this.cXML)
     this.lEndDetected = .F.
     l_oXML = CREATEOBJECT("MSXML2.DOMDocument")
     l_oXML.async = .F.
     l_tCounter = DATETIME()
     DO WHILE NOT this.lEndDetected
          l_cResponse = this.owscnt.GetResponse(5)
          l_cCmd = ""
          IF NOT EMPTY(l_cResponse)
               this.LogIt(winpc()+"|<--|"+l_cResponse)
               l_cResponse = STRTRAN(l_cResponse,CHR(4),"") && Remove 0x04 character from XML
               l_oXML.LoadXML(l_cResponse)
               l_oOneNode = l_oXML.selectSingleNode("datazone-document/OC")
               IF NOT ISNULL(l_oOneNode)
                    l_cCmd = l_oOneNode.Text
               ENDIF
          ENDIF
          DO CASE
               CASE DATETIME() - l_tCounter > 59 && Exit after 60 sec.
                    this.lEndDetected = .T.
                    this.LogIt(winpc()+"|Timedout, closing connection")
               CASE l_cCmd = "ACK"
                    l_oOneNode = l_oXML.selectSingleNode("datazone-document/MSG")
                    l_cMsg = ALLTRIM(l_oOneNode.Text)
                    this.MsgHook(l_cMsg)
                    l_oOneNode = l_oXML.selectSingleNode("datazone-document/RC")
                    l_lSuccess = IIF(ALLTRIM(l_oOneNode.Text)="0",.T.,.F.)
               CASE l_cCmd = "SM"
                    l_oOneNode = l_oXML.selectSingleNode("datazone-document/MSG")
                    l_cMsg = ALLTRIM(l_oOneNode.Text)
                    this.MsgHook(l_cMsg)
                    IF EMPTY(l_cMsg)
                         this.lEndDetected = .T.
                    ENDIF
          ENDCASE
     ENDDO
ENDIF
this.LogIt(winpc()+"|Disconnecting")
this.owscnt.Disconnect()
this.MsgHook("")
RETURN l_lSuccess
ENDPROC
*
PROCEDURE MsgHook(lp_cMsg AS String) AS Logical
IF NOT EMPTY(this.cMsgHookMacro)
     l_cMacro = this.cMsgHookMacro + "([" + lp_cMsg + "])"
     TRY
          &l_cMacro
     CATCH
     ENDTRY
ENDIF
ENDPROC
*
PROCEDURE CreateWinSock
LOCAL l_lSuccess, l_oCntWinSock
l_lSuccess = .T.
TRY
     l_oCntWinSock = NEWOBJECT("cntwinsock","libs\cit_winsock.vcx")
CATCH
     l_lSuccess = .F.
     = erRormsg("winsock.ocx not installed.")
     this.AddProperty("owscnt",.NULL.)
ENDTRY
l_oCntWinSock = .NULL.
IF l_lSuccess
     this.NewObject("owscnt","cntwinsock","libs\cit_winsock.vcx")
     this.owscnt.cOnCloseMacro = "this.Parent.OnConnectionClose()"
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE OnConnectionClose
this.MsgHook("Remote host closed connection")
this.lEndDetected = .T.
ENDPROC
*
PROCEDURE LogIt
LPARAMETERS lp_cText
LOCAL l_cFile2, l_nLimit, l_cRemoteHostIp
IF NOT EMPTY(lp_cText)

     l_cFile2 = this.cLogFile + ".2"
     l_nLimit = 50000000 && 50 MB
     IF FILE(this.cLogFile)
          IF ADIR(l_aFile,LOCFILE(this.cLogFile))>0
               IF l_aFile(2)>l_nLimit
                    IF FILE(l_cFile2)
                         DELETE FILE (l_cFile2)
                    ENDIF
                    RENAME (this.cLogFile) TO (l_cFile2)
               ENDIF
          ENDIF
     ENDIF
     l_cRemoteHostIp = "0.0.0.0"
     TRY
          l_cRemoteHostIp = TRANSFORM(this.owscnt.ows.Object.RemoteHostIp)
     CATCH
     ENDTRY
     IF EMPTY(l_cRemoteHostIp)
          l_cRemoteHostIp = "0.0.0.0"
     ENDIF
     l_cRemoteHostIp = PADR(l_cRemoteHostIp,15)
     TRY
          STRTOFILE(TRANSFORM(DATETIME())+"|"+l_cRemoteHostIp+"|"+lp_cText + CHR(13) + CHR(10), this.cLogFile, 1)
     CATCH
     ENDTRY

ENDIF
RETURN .T.
ENDPROC
*
ENDDEFINE
*
*
*
DEFINE CLASS ckeycarditec AS Custom
*
nBlock = 4
nEncrypt = 1
cLogFile = "ckeycarditec.log"
cMsgHookMacro = "" && Name of method to which should be message sent, as parameter
lEndDetected = "" && When .T., exit from sending/receiving loop
cRoom = ""
cKeyType = ""
dDepDate = {}
cDepTime = ""
cAccess = ""
nNoOfKeys = 0
nRsId = 0
nCardNo = 0
ckeyoptioniteckeylock1 = ""
ckeyoptioniteckeylock2 = ""
ckeyoptioniteckeylock3 = ""
ckeyoptioniteckeylock4 = ""
ckeyitecsystemcode = ""
ckeyitechotelcode = ""
cRPass = ""
nCom = 0
lOpenbolt = .F.
lTerminateOld = .F.
*
PROCEDURE Init
this.InitDLL()
this.nCom = _screen.oGlobal.oterminal.tm_itecp
ENDPROC
*
PROCEDURE CheckIn(lp_cRoom AS String, lp_cKeyType AS String, lp_dDepDate AS Date, lp_cDepTime AS String, ;
          lp_cAccess AS String, lp_nNoOfKeys AS Integer, lp_nRsId AS Integer, lp_nCardNo AS Integer, ;
          lp_ckeyoptioniteckeylock1 AS String, lp_ckeyoptioniteckeylock2 AS String, lp_ckeyoptioniteckeylock3 AS String, lp_ckeyoptioniteckeylock4 AS String, ;
          lp_ckeyitecsystemcode AS String, lp_ckeyitechotelcode AS String, ;
          lp_cRPass AS String, lp_lOpenbolt AS Logical, lp_lTerminateOld AS Logical) AS Logical

LOCAL i, l_nReponse, l_lContinue, l_cMsg, l_lSuccess

IF EMPTY(lp_cRoom)
     alert(GetLangText("MGRRESER","TXT_INVALID_ROOMNUM"))
     RETURN l_lSuccess
ENDIF

this.cRoom = ALLTRIM(lp_cRoom)
this.cKeyType = lp_cKeyType
this.dDepDate = lp_dDepDate
this.cDepTime = lp_cDepTime 
this.cAccess = lp_cAccess
this.nNoOfKeys = lp_nNoOfKeys
this.nRsId = lp_nRsId
this.nCardNo = lp_nCardNo
this.ckeyoptioniteckeylock1 = lp_ckeyoptioniteckeylock1
this.ckeyoptioniteckeylock2 = lp_ckeyoptioniteckeylock2
this.ckeyoptioniteckeylock3 = lp_ckeyoptioniteckeylock3
this.ckeyoptioniteckeylock4 = lp_ckeyoptioniteckeylock4
this.ckeyitecsystemcode = lp_ckeyitecsystemcode
this.ckeyitechotelcode = lp_ckeyitechotelcode
this.lOpenbolt = lp_lOpenbolt
this.lTerminateOld = lp_lTerminateOld

*!*     Use old rpass for extra cards.
IF this.cKeyType = "E" AND NOT EMPTY(lp_cRPass)
     this.cRPass = ALLTRIM(lp_cRPass)
ELSE
     this.cRPass = this.GetRPass()
ENDIF

this.WriteLog("CreateCardsRequest|"+"cRoom:"+this.cRoom+"|"+;
          "cKeyType:"+this.cKeyType+"|"+;
          "dDepDate:"+TRANSFORM(this.dDepDate)+"|"+;
          "cDepTime:"+TRANSFORM(this.cDepTime)+"|"+;
          "cAccess:"+TRANSFORM(this.cAccess)+"|"+;
          "nNoOfKeys:"+TRANSFORM(this.nNoOfKeys)+"|"+;
          "nRsId:"+TRANSFORM(this.nRsId)+"|"+;
          "nCardNo:"+TRANSFORM(this.nCardNo)+"|"+;
          "ckeyoptioniteckeylock1:"+TRANSFORM(this.ckeyoptioniteckeylock1)+"|"+;
          "ckeyoptioniteckeylock2:"+TRANSFORM(this.ckeyoptioniteckeylock2)+"|"+;
          "ckeyoptioniteckeylock3:"+TRANSFORM(this.ckeyoptioniteckeylock3)+"|"+;
          "ckeyoptioniteckeylock4:"+TRANSFORM(this.ckeyoptioniteckeylock4)+"|"+;
          "ckeyitecsystemcode:"+TRANSFORM(this.ckeyitecsystemcode)+"|"+;
          "ckeyitechotelcode:"+TRANSFORM(this.ckeyitechotelcode)+"|"+;
          "lOpenbolt:"+TRANSFORM(this.lOpenbolt)+"|"+;
          "lTerminateOld:"+TRANSFORM(this.lTerminateOld))

FOR i = 1 TO this.nNoOfKeys
     l_lContinue = .T.
     DO WHILE l_lContinue
          IF yesno(TRANSFORM(i) + ". " + IIF(this.cKeyType = "E",GetLangText("KEYCARD1","T_EXTRACARD"),GetLangText("KEYCARD1","T_NEWCARD")) + ;
                    CHR(13)+CHR(10) + CHR(13)+CHR(10) + ;
                    GetLangText("CARDREAD","TA_1351") ;
                    )
               l_nReponse = this.CreateCard()
               DO CASE
                    CASE l_nReponse = 0
                         l_lSuccess = .T.
                         l_cMsg = GetLangText("CARDREAD","TA_1358") + CHR(13)+CHR(10) + CHR(13)+CHR(10) + ;
                                   GetLangText("CARDREAD","TA_1357")
                         l_lContinue = .F.
                    CASE l_nReponse = 223
                         l_cMsg = GetLangText("CARDREAD","TA_1352")
                    OTHERWISE
                         l_cMsg = GetLangText("CARDREAD","TA_1359") + CHR(13)+CHR(10) + "(" + TRANSFORM(l_nReponse) + ")"
               ENDCASE
               alert(l_cMsg)
          ELSE
               l_lContinue = .F.
          ENDIF
     ENDDO
ENDFOR
lp_cRPass = this.cRPass
RETURN l_lSuccess
ENDPROC
*
PROCEDURE CreateCard
LOCAL l_nResult, l_cCardPass, l_cSystemCode, l_cHotelCode, l_cRPass, l_cAddress, l_cSDIn, l_cSTIn, l_cSDOut, l_cSTOut, ;
          l_nLEVEL_Pass, l_nPassMode, l_nAddressMode, l_nAddressQty, l_nTimeMode, l_nV8, l_nV16, l_nV24, l_nTerminateOld, ;
          l_nValidTimes, l_nComPort, l_nCardNo, l_nBlock, l_nEncrypt, i, l_cOptAddress

l_nComPort = this.nCom
l_nCardNo = this.nCardNo
l_nBlock = this.nBlock
l_nEncrypt = this.nEncrypt

l_cCardPass = "82A094FFFFFF"
l_cSystemCode = this.ckeyitecsystemcode
l_cHotelCode = this.ckeyitechotelcode
l_cRPass = this.cRPass
l_cAddress = this.cRoom
l_cSDIn = this.GetDate()
l_cSTIn = this.GetTime()
l_cSDOut = this.GetDate(this.dDepDate)
l_cSTOut = this.GetTime(this.cDepTime)

*!*     LEVEL_Pass, =3 Guest Card, only one room; =13 Guest Card, can open max 7 rooms.
*!*     constant long LEV_ROOM_PASS=3   //Guest Card, only one room   
*!*     constant long LEV_ROOM2_PASS=13// Guest Card, can open max 7 rooms
IF "1" $ this.cAccess
     *l_nLEVEL_Pass = 13
     l_nLEVEL_Pass = 3
     *l_nPassMode = 0 && PassMode, If LEVEL_Pass =3 then PassMode= 1,otherwise 0
     l_nPassMode = 1
     l_nAddressMode = 2 && AddressMode, If LEVEL_Pass =3 then AddressMode= 0;    If LEVEL_Pass =13 then AddressMode= 2,

*!*     AddressQty, the address quantity,   
*!*     example “01020300400” means AddressQty=1 
*!*     example “0102030040001020300500” means AddressQty=2
*!*     example “01020300400010203005000102030090001020301000” means AddressQty=4

     l_nAddressQty = 1
     FOR i = 1 TO 4
          l_cOptAddress = EVALUATE("this.ckeyoptioniteckeylock"+TRANSFORM(i))
          IF SUBSTR(this.cAccess,i,1)="1" AND NOT EMPTY(l_cOptAddress)
               l_cAddress = l_cAddress + l_cOptAddress
               l_nAddressQty = l_nAddressQty + 1
          ENDIF
     ENDFOR
ELSE
     l_nLEVEL_Pass = 3
     l_nPassMode = 1
     l_nAddressMode = 0
     l_nAddressQty = 1
ENDIF

l_nTimeMode = 0
l_nV8 = 0
l_nV16 = 0
l_nV24 = 0

*!*     AlwaysOpen, 1 means always open,   0 means no. Please note that, the Key card has OpenBolt 
*!*     function will make the lock always unlock. 
l_nAlwaysOpen = 0

*!*     OpenBolt, 1 means can open bolt, 0 means no. Please note that, the Key card has OpenBolt function 
*!*     will make the lock always unlock. 
l_nOpenBolt = IIF(this.lOpenbolt,1,0)

*!*     TerminateOld, for Guest Card 1 means Terminate the old Guest Card, 0 means no.(only use for 1 card 
*!*     1 room, cannot use   for 1 card more room)
IF l_nAddressQty > 1
     l_nTerminateOld = 0
ELSE
     l_nTerminateOld = IIF(this.lTerminateOld OR this.cKeyType = "K",1,0) && For New card (K) make all old card invalid!
ENDIF

l_nValidTimes = 255

this.WriteLog("WriteToCard|Sending|"+;
          "nComPort:"+TRANSFORM(l_nComPort)+"|"+;
          "nCardNo:"+TRANSFORM(l_nCardNo)+"|"+;
          "nBlock:"+TRANSFORM(l_nBlock)+"|"+;
          "nEncrypt:"+TRANSFORM(l_nEncrypt)+"|"+;
          "cCardPass:"+TRANSFORM(l_cCardPass)+"|"+;
          "cSystemCode:"+TRANSFORM(l_cSystemCode)+"|"+;
          "cHotelCode:"+TRANSFORM(l_cHotelCode)+"|"+;
          "cRPass:"+TRANSFORM(l_cRPass)+"|"+;
          "cAddress:"+TRANSFORM(l_cAddress)+"|"+;
          "cSDIn:"+TRANSFORM(l_cSDIn)+"|"+;
          "cSTIn:"+TRANSFORM(l_cSTIn)+"|"+;
          "cSDOut:"+TRANSFORM(l_cSDOut)+"|"+;
          "cSTOut:"+TRANSFORM(l_cSTOut)+"|"+;
          "nLEVEL_Pass:"+TRANSFORM(l_nLEVEL_Pass)+"|"+;
          "nPassMode:"+TRANSFORM(l_nPassMode)+"|"+;
          "nAddressMode:"+TRANSFORM(l_nAddressMode)+"|"+;
          "nAddressQty:"+TRANSFORM(l_nAddressQty)+"|"+;
          "nTimeMode:"+TRANSFORM(l_nTimeMode)+"|"+;
          "nV8:"+TRANSFORM(l_nV8)+"|"+;
          "nV16:"+TRANSFORM(l_nV16)+"|"+;
          "nV24:"+TRANSFORM(l_nV24)+"|"+;
          "nAlwaysOpen:"+TRANSFORM(l_nAlwaysOpen)+"|"+;
          "nOpenBolt:"+TRANSFORM(l_nOpenBolt)+"|"+;
          "nTerminateOld:"+TRANSFORM(l_nTerminateOld)+"|"+;
          "nValidTimes:"+TRANSFORM(l_nValidTimes))

FNWaitWindow(GetLangText("COMMON","TXT_UPDATING"),.T.)
l_nResult = ITECKeyCard(l_nComPort, ;
          l_nCardNo, ;
          l_nBlock, ;
          l_nEncrypt, ;
          @l_cCardPass, ;
          @l_cSystemCode, ;
          @l_cHotelCode, ;
          @l_cRPass, ;
          @l_cAddress, ;
          @l_cSDIn, ;
          @l_cSTIn, ;
          @l_cSDOut, ;
          @l_cSTOut, ;
          l_nLEVEL_Pass, ;
          l_nPassMode, ;
          l_nAddressMode, ;
          l_nAddressQty, ;
          l_nTimeMode, ;
          l_nV8, ;
          l_nV16, ;
          l_nV24, ;
          l_nAlwaysOpen, ;
          l_nOpenBolt, ;
          l_nTerminateOld, ;
          l_nValidTimes)
this.WriteLog("WriteToCard|Response:"+TRANSFORM(l_nResult))
FNWaitWindow(,,,.T.)

RETURN l_nResult
ENDPROC
*
PROCEDURE GetRPass
LPARAMETERS lp_tDateTime
LOCAL l_nYear, l_nMonth, l_nDay, l_nHour, l_nMin, l_nSec, dw, Scipher
lp_tDateTime = EVL(lp_tDateTime, DATETIME())
l_nYear = YEAR(lp_tDateTime)
l_nMonth = MONTH(lp_tDateTime)
l_nDay = DAY(lp_tDateTime)
l_nHour = HOUR(lp_tDateTime)
l_nMin= MINUTE(lp_tDateTime)
l_nSec = SEC(lp_tDateTime)
dw = (l_nMin/4)+ l_nHour*2^4 + l_nDay*(2^9)+ l_nMonth*(2^14) +(((l_nYear-8) % 1000)%63)* (2^18)
Scipher = TRANSFORM(dw,"@0")
Scipher = STRTRAN(Scipher, "0x", "00000000")
RETURN Scipher
ENDPROC
*
PROCEDURE GetDate
LPARAMETERS lp_dDate
IF EMPTY(lp_dDate)
     lp_dDate = DATE()
ENDIF
RETURN RIGHT(TRANSFORM(YEAR(lp_dDate)),2)+"-"+PADL(TRANSFORM(MONTH(lp_dDate)),2,"0")+"-"+PADL(TRANSFORM(DAY(lp_dDate)),2,"0")
ENDPROC
*
PROCEDURE GetTime
LPARAMETERS lp_cTime
IF EMPTY(lp_cTime) OR lp_cTime = "  :  "
     lp_cTime = TIME()
ENDIF
IF LEN(lp_cTime)=5
     lp_cTime = lp_cTime + ":00"
ENDIF
RETURN lp_cTime
ENDPROC
*
PROCEDURE CheckCard
LOCAL l_nDBCardNo, l_lSuccess, l_nRsId, l_cInfo, l_nSelect, l_cCur
l_nDBCardNo = this.ReadCard()
IF NOT EMPTY(l_nDBCardNo)
     l_nRsId = this.GetReservation(l_nDBCardNo)
     l_cInfo = ""
     IF NOT EMPTY(l_nRsId)
          l_nSelect = SELECT()
          l_cCur = sqlcursor("SELECT rs_reserid, rs_rmname, rs_status, rs_lname, rs_company, rs_arrdate, rs_depdate FROM reservat WHERE rs_rsid = " + TRANSFORM(l_nRsId))
          IF USED(l_cCur) AND RECCOUNT(l_cCur)>0
               TEXT TO l_cInfo TEXTMERGE NOSHOW PRETEXT 15
<<GetLangText("KEYCARD1","TXT_CARDID")>>: <<TRANSFORM(l_nDBCardNo)>>;
<<GetLangText("RESERVAT","T_RESNUM")>>: <<TRANSFORM(rs_reserid)>>;
<<GetLangText("RESERVAT","TH_ROOMNUM")>>: <<ALLTRIM(rs_rmname)>>;
<<GetLangText("RESERVAT","TH_STATUS")>>: <<ALLTRIM(rs_status)>>;
<<GetLangText("RESERVAT","TH_LNAME")>>: <<ALLTRIM(rs_lname)>>;
<<GetLangText("RESERVAT","TH_COMPANY")>>: <<ALLTRIM(rs_company)>>;
<<GetLangText("RESERVAT","TH_ARRDATE")>>: <<TRANSFORM(rs_arrdate)>>;
<<GetLangText("RESERVAT","TH_DEPDATE")>>: <<TRANSFORM(rs_depdate)>>
               ENDTEXT
          ENDIF
          dclose(l_cCur)
          SELECT (l_nSelect = SELECT())
     ENDIF
     IF EMPTY(l_cInfo)
          alert(GetLangText("KEYCARD1","TXT_CARDID") + ": " + TRANSFORM(l_nDBCardNo) + CHR(13) + CHR(10) + GetLangText("DP","TA_RESNOTFOUND"))
     ELSE
          l_lSuccess = .T.
          seLectmessage(GetLangText("PARAMS", "TXT_KEYINFOEXTRA"),GetLangText("COMMON", "TXT_OK"),l_cInfo,"bitmap\icons\binoculr.ico",.T.,300)
     ENDIF
ENDIF
RETURN l_lSuccess
ENDPROC
*
PROCEDURE ReadCard
LOCAL l_nReponse, l_nCom, l_nBlock, l_nEncrypt, l_nDBCardNo, l_nDBCardType, l_nDBPassLevel, l_cSystemCode, l_cDBAddress, l_cSDateTime, l_cMsg
l_nCom = this.nCom
l_nBlock = 4
l_nEncrypt = 1
l_nDBCardNo = 0
l_nDBCardType = 0
l_nDBPassLevel = 0
l_cCardPass = "82A094FFFFFF"
l_cSystemCode = SPACE(255)
l_cDBAddress = SPACE(255)
l_cSDateTime = SPACE(255)

this.WriteLog("ReadCard|Sending|"+;
          "nComPort:"+TRANSFORM(l_nCom)+"|"+;
          "nBlock:"+TRANSFORM(l_nBlock)+"|"+;
          "nEncrypt:"+TRANSFORM(l_nEncrypt))

FNWaitWindow(GetLangText("PHONE","TXT_READSTATUSPLEASEWAIT"),.T.)
l_nReponse = ITECReadMessage(l_nCom, l_nBlock, l_nEncrypt, @l_nDBCardNo, @l_nDBCardType, @l_nDBPassLevel, ;
          @l_cCardPass, @l_cSystemCode, @l_cDBAddress, @l_cSDateTime)
FNWaitWindow(,,,.T.)

this.WriteLog("ReadCard|Response:"+TRANSFORM(l_nReponse)+"|"+;
          "nComPort:"+TRANSFORM(l_nCom)+"|"+;
          "nDBCardNo:"+TRANSFORM(l_nDBCardNo)+"|"+;
          "nDBCardType:"+TRANSFORM(l_nDBCardType)+"|"+;
          "nDBPassLevel:"+TRANSFORM(l_nDBPassLevel)+"|"+;
          "cCardPass:"+TRANSFORM(l_cCardPass)+"|"+;
          "cSystemCode:"+TRANSFORM(l_cSystemCode)+"|"+;
          "cDBAddress:"+TRANSFORM(l_cDBAddress)+"|"+;
          "cSDateTime:"+TRANSFORM(l_cSDateTime))

DO CASE
     CASE l_nReponse = 0
          l_cMsg = ""
     CASE l_nReponse = 223
          l_cMsg = GetLangText("CARDREAD","TA_1352")
     OTHERWISE
          l_cMsg = GetLangText("CARDREAD","TA_1359") + CHR(13)+CHR(10) + "(" + TRANSFORM(l_nReponse) + ")"
ENDCASE
IF NOT EMPTY(l_cMsg)
     alert(l_cMsg)
ENDIF
RETURN l_nDBCardNo
ENDPROC
*
PROCEDURE GetReservation
LPARAMETERS lp_nCardNo
LOCAL l_nFiles, i, l_cFile, l_cContent, l_cCardId, l_nCardId, l_nRsId, l_cRsId
LOCAL ARRAY l_aFiles(1)
l_nRsId = 0
l_nFiles = ADIR(l_aFiles, _screen.oGlobal.choteldir+"ifc\key\*.IN")
FOR i = 1 TO l_nFiles
     l_cFile = _screen.oGlobal.choteldir+"ifc\key\" + l_aFiles(i,1)
     l_cContent = ""
     TRY
          l_cContent = FILETOSTR(l_cFile)
     CATCH
     ENDTRY
     IF NOT EMPTY(l_cContent)
          l_cCardId = SUBSTR(l_cContent,176,8)
          IF NOT EMPTY(l_cCardId)
               l_nCardId = INT(VAL(l_cCardId))
               IF l_nCardId = lp_nCardNo
                    l_cRsId = SUBSTR(l_cContent,199,10)
                    IF NOT EMPTY(l_cRsId)
                         l_nRsId = INT(VAL(l_cRsId))
                         EXIT
                    ENDIF
               ENDIF
          ENDIF
     ENDIF
ENDFOR
this.WriteLog("ReadCard|GetReservation|"+"|"+;
          "nRsId:"+TRANSFORM(l_nRsId))
RETURN l_nRsId
ENDPROC
*
PROCEDURE InitDLL
LOCAL l_lFoundITECKeyCard, l_lFoundITECReadMessage, i
LOCAL ARRAY l_aDlls(1)

* Declare DLLS, when needed

IF ADLLS(l_aDlls)>0
     FOR i = 1 TO ALEN(l_aDlls,1)
          IF LOWER(ALLTRIM(l_aDlls(i,2))) == "iteckeycard"
               l_lFoundITECKeyCard = .T.
          ENDIF
          IF LOWER(ALLTRIM(l_aDlls(i,2))) == "itecreadmessage"
               l_lFoundITECReadMessage = .T.
          ENDIF
     ENDFOR
ENDIF

IF NOT l_lFoundITECKeyCard
     DECLARE INTEGER KeyCard IN hnlock.dll AS ITECKeyCard ;
          INTEGER nCom, ;
          INTEGER nCardNo, ;
          INTEGER nBlock, ;
          INTEGER nEncrypt, ;
          STRING @ cCardPass, ;
          STRING @ cSystemCode, ;
          STRING @ cHotelCode, ;
          STRING @ cRPass, ;
          STRING @ cAddress, ;
          STRING @ cSDIn, ;
          STRING @ cSTIn, ;
          STRING @ cSDOut, ;
          STRING @ cSTOut, ;
          INTEGER nLEVEL_Pass, ;
          INTEGER nPassMode, ;
          INTEGER nAddressMode, ;
          INTEGER nAddressQty, ;
          INTEGER nTimeMode, ;
          INTEGER nV8, ;
          INTEGER nV16, ;
          INTEGER nV24, ;
          INTEGER nAlwaysOpen, ;
          INTEGER nOpenBolt, ;
          INTEGER nTerminateOld, ;
          INTEGER ValidTimes
ENDIF
IF NOT l_lFoundITECReadMessage
     DECLARE INTEGER ReadMessage IN hnlock.dll AS ITECReadMessage ;
          INTEGER nCom, ;
          INTEGER nBlock, ;
          INTEGER nEncrypt, ;
          INTEGER @ nDBCardNo, ;
          INTEGER @ nDBCardType, ;
          INTEGER @ nDBPassLevel, ;
          STRING @ cCardPass, ;
          STRING @ cSystemCode, ;
          STRING @ cDBAddress, ;
          STRING @ cSDateTime
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE WriteLog
LPARAMETERS lp_cMsg
this.LogIt(PADR(winpc(),15)+"|"+lp_cMsg)
ENDPROC
*
PROCEDURE LogIt
LPARAMETERS lp_cText
LOCAL l_cFile2, l_nLimit
IF NOT EMPTY(lp_cText)

     l_cFile2 = this.cLogFile + ".2"
     l_nLimit = 50000000 && 50 MB
     IF FILE(this.cLogFile)
          IF ADIR(l_aFile,LOCFILE(this.cLogFile))>0
               IF l_aFile(2)>l_nLimit
                    IF FILE(l_cFile2)
                         DELETE FILE (l_cFile2)
                    ENDIF
                    RENAME (this.cLogFile) TO (l_cFile2)
               ENDIF
          ENDIF
     ENDIF
     TRY
          STRTOFILE(TRANSFORM(DATETIME())+"|"+lp_cText + CHR(13) + CHR(10), this.cLogFile, 1)
     CATCH
     ENDTRY

ENDIF
RETURN .T.
ENDPROC
*
ENDDEFINE
*