#INCLUDE "include\constdefines.h"
*
* PROCEDURE procemail
 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
               lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, ;
               lp_uParam12, lp_uParam13, lp_uParam14
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal
 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO PCOUNT()-1
     l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"
 l_uRetVal = &l_cCallProc
 RETURN l_uRetVal
ENDPROC
*
PROCEDURE LinkOneAddress
 LPARAMETERS pl_nMaId, pl_nAddrId
 INSERT INTO einboxsn (eb_eiid, eb_addrid, eb_apid) ;
      VALUES (pl_nMaId, pl_nAddrId, 0)
 RETURN .T.
ENDPROC
*
*PROCEDURE ResetEMailClient
* LOCAL l_oEmail
* IF yesno(GetLangText("EMAIL","TXT_PROCEED_WITH_RESET"))
*      l_oEmail = .NULL.
*      l_oEmail = NEWOBJECT("emailclient","cit_email","",.T.)
*      = alert(GetLangText("EMAIL","TXT_CLIENT_IS_RESET"))
* ENDIF
* RETURN .T.
*ENDPROC
*
PROCEDURE einbox_delete
 LPARAMETERS lp_eiid
 LOCAL l_lSentMessage
 IF USED("einbox") AND SEEK(lp_eiid,"einbox","tag1")
      REPLACE ei_deleted WITH .T., ;
              ei_attachm WITH 0 IN einbox
      l_lSentMessage = .F.
      DO attachment_delete WITH lp_eiid, l_lSentMessage
      RETURN .T.
 ENDIF
 RETURN .F.
ENDPROC
*
PROCEDURE attachment_delete
LPARAMETERS lp_MsgID, lp_lSentMessage

LOCAL l_cFilePath, l_cCurrTag, l_nOldArea
LOCAL l_cOrder, l_cFieldToSearch
l_nOldArea = SELECT()
SELECT eattachm
l_cCurrTag = TAG()

IF lp_lSentMessage     && sent messages
     l_cOrder = "Tag2"
     l_cFieldToSearch = "eattachm.ea_esid"
ELSE
     l_cOrder = "Tag1"
     l_cFieldToSearch = "eattachm.ea_eiid"
ENDIF

SET ORDER TO &l_cOrder
IF NOT SEEK(lp_MsgID,"eattachm",[&l_cOrder])
     RETURN .F.
ENDIF
DO WHILE &l_cFieldToSearch = lp_MsgID
     l_cFilePath = ALLTRIM(ea_path)+STRTRAN(STR(IIF(lp_lSentMessage,ea_sntatid,ea_attid),8), " ","0")+RTRIM(ea_attname)
     IF FILE(l_cFilePath)
          DELETE FILE(l_cFilePath)
     ENDIF
     DELETE IN eattachm
     SKIP 1 IN eattachm
ENDDO
SET ORDER TO &l_cCurrTag
SELECT (l_nOldArea)
RETURN .T.
ENDPROC
*
PROCEDURE esent_delete
 LPARAMETERS lp_esid
 LOCAL l_lSentMessage
 IF USED("esent") AND SEEK(lp_esid,"esent","tag1")
      REPLACE es_deleted WITH .T. IN esent
      l_lSentMessage = .T.
        DO attachment_delete WITH lp_esid, l_lSentMessage
      RETURN .T.
 ENDIF
 RETURN .F.
ENDPROC
*
PROCEDURE einbox_status_change
 * 1 - received
 * 2 - linked to address
 * 3 - linked to address and replying in progress
 * 4 - linked to address and replyed
 LPARAMETERS lp_eiid, lp_nStatus
 IF BETWEEN(lp_nStatus, 1, 4) AND USED("einbox") AND SEEK(lp_eiid,"einbox","tag1")
      REPLACE ei_status WITH lp_nStatus IN einbox
      RETURN .T.
 ENDIF
 RETURN .F.
ENDPROC
*
PROCEDURE AddAttachment
LPARAMETERS lp_cNewAttach
LOCAL l_cFilePath, l_cFileName, l_nAttSize, l_nAttID, l_nOldArea
l_cFileName = SUBSTR(lp_cNewAttach,RAT("\", lp_cNewAttach)+1)
l_cFilePath = SUBSTR(lp_cNewAttach,1,RAT("\", lp_cNewAttach))
l_nAttSize = FileSize(lp_cNewAttach)
l_nOldArea = SELECT()
SELECT curAttachments
APPEND BLANK
REPLACE ea_attname WITH l_cFileName, ;
          ea_attsize WITH l_nAttSize, ;
          ea_path WITH l_cFilePath IN curAttachments

SELECT(l_nOldArea)
ENDPROC
*
PROCEDURE CheckAttachmentsText
LPARAMETERS lp_nMsgId, lp_lSentMsg, lp_cRetText
LOCAL l_cFieldToSeek, l_nOldArea, l_nRecNo, l_cTagName

l_nOldArea = SELECT()
SELECT eattachm
l_nRecNo = RECNO()
l_cTagName = SYS(22)

IF lp_lSentMsg
     SET ORDER TO Tag2
     l_cFieldToSeek = "ea_esid"
ELSE     && inbox or linked folder
     SET ORDER TO Tag1
     l_cFieldToSeek = "ea_eiid"
ENDIF
SEEK lp_nMsgId
IF FOUND()
     LOCATE FOR &l_cFieldToSeek = lp_nMsgId AND EMPTY(ea_path) WHILE &l_cFieldToSeek = lp_nMsgId
     IF FOUND()
          lp_cRetText = "!"+GetLangText("AR","T_YES")
     ELSE
          lp_cRetText = GetLangText("AR","T_YES")
     ENDIF
ELSE
     lp_cRetText = GetLangText("AR","T_NO")
ENDIF
SET ORDER TO TAG l_cTagName
GO l_nRecNo IN eattachm
SELECT (l_nOldArea)
RETURN PADR(lp_cRetText,5)
ENDPROC
*
PROCEDURE SendLetterAutomatic
LPARAMETERS lp_cDocumentName, lp_nAddressID, lp_nReserId
LOCAL l_aDocumentsToSend(1)
IF _SCREEN.OL
     IF parights(135)
          DIMENSION l_aDocumentsToSend(GETWORDCOUNT(lp_cDocumentName,","))
          FOR i = 1 TO GETWORDCOUNT(lp_cDocumentName,",")
               l_aDocumentsToSend(i) = GETWORDNUM(lp_cDocumentName,i,",")
          NEXT
          IF EMPTY(lp_nReserId)
               lp_nReserId = 0
          ENDIF
          g_oWinEvents.CallSendEmailForm(lp_nAddressID, lp_nReserId, @l_aDocumentsToSend)
     ENDIF
ENDIF
ENDPROC
*
PROCEDURE PESendMail
* Send email without custom vfp form.
* Works too when no OL licence.
LPARAMETERS lp_cEMail, lp_uAttachPathName, lp_cDisplayName, lp_cSubject, lp_cMsgNoteText, lp_lOutLook, ;
          lp_nAddrId, lp_lDontShowComposeWindow, lp_lSilent, lp_lNoSignature, lp_nRsId
LOCAL l_lSuccess, l_nSelect, l_cCurAdrEMail, l_oData, l_cAttachPathName, l_lShowComposeWindow
LOCAL l_oEmail AS emailclient OF cit_email, l_nEmailRcps, l_cOneEmail, i
l_nSelect = SELECT()
l_cCurAdrEMail = SYS(2015)

openfiledirect(.F.,"esent")
openfiledirect(.F.,"esentrcp")
openfiledirect(.F.,"eattachm")
openfiledirect(.F.,"emprop")
openfiledirect(.F.,"picklist")

* Subject
IF EMPTY(lp_cSubject)
     lp_cSubject = TRIM(g_hotel) + " " + TRANSFORM(DATETIME())
ENDIF

* Body
IF EMPTY(lp_cMsgNoteText)
     lp_cMsgNoteText = ""
ENDIF
IF NOT lp_lNoSignature
     lp_cMsgNoteText = lp_cMsgNoteText + PEgetsignature()
ENDIF

IF EMPTY(lp_nAddrId)
     lp_nAddrId = 0
ENDIF
* Add email address to recipient list cursor
SELECT *, .F. AS ec_mark FROM esentrcp WHERE .F. INTO CURSOR (l_cCurAdrEMail) READWRITE
l_nEmailRcps = GETWORDCOUNT(lp_cEMail,";")
FOR i = 1 TO l_nEmailRcps
     l_cOneEmail = ALLTRIM(GETWORDNUM(lp_cEMail, i, ";"))
     SCATTER MEMO NAME l_oData BLANK
     l_oData.ec_addrid = lp_nAddrId
     l_oData.ec_apid = 0
     l_oData.ec_email = l_cOneEmail
     IF NOT EMPTY(lp_cDisplayName)
          l_oData.ec_disname = ALLTRIM(lp_cDisplayName)
     ELSE
          l_oData.ec_disname = ALLTRIM(l_cOneEmail)
     ENDIF
     l_oData.ec_mark = .T.
     APPEND BLANK
     GATHER MEMO NAME l_oData
ENDFOR
* add attachemnts
SELECT *, .F. AS ea_mark FROM eattachm WHERE .F. INTO CURSOR curAttachments READWRITE

IF TYPE("lp_uAttachPathName")="O" AND LOWER(lp_uAttachPathName.BaseClass) = "collection"
     FOR EACH l_cAttachPathName IN lp_uAttachPathName FOXOBJECT
          DO AddAttachment IN procemail WITH l_cAttachPathName
          REPLACE ea_mark WITH .T. IN curAttachments
     ENDFOR
ELSE
     IF NOT EMPTY(lp_uAttachPathName)
          DO AddAttachment IN procemail WITH lp_uAttachPathName
          REPLACE ea_mark WITH .T. IN curAttachments
     ENDIF
ENDIF

* Send e-mail
l_oEmail = .NULL.
l_oEmail = NEWOBJECT("emailclient","cit_email")

IF ISNULL(l_oEmail)
     RETURN .F.
ENDIF

IF lp_lDontShowComposeWindow
     l_lShowComposeWindow = .F.
ELSE
     l_lShowComposeWindow = .T.
ENDIF
l_lSuccess = l_oEmail.SendMsg(l_cCurAdrEMail, lp_cSubject, lp_cMsgNoteText, l_lShowComposeWindow, lp_nRsId, lp_lSilent)
IF NOT l_lSuccess
     IF NOT lp_lSilent
          = alert(GetLangText("ADDRESS","T_MAILNOTSENT"))
     ENDIF
ENDIF

l_oEmail = .NULL.

dclose(l_cCurAdrEMail)
dclose("curAttachments")

SELECT (l_nSelect)
RETURN l_lSuccess
ENDPROC
*
PROCEDURE PESendWithBlat
LPARAMETERS lp_cTo, lp_cBCC, lp_cFrom, lp_cServer, lp_cUser, lp_cPass, lp_cMessage, lp_cSubject, ;
          lp_cAttachments, lp_lDebug, lp_cLog, lp_lSuccess, lp_lSilent, lp_lShowMsgBoxWhenError
LOCAL l_cMessageFile, l_cSendString, i, l_nResponse, l_oException AS Exception, l_cError
lp_lSuccess = .F.
IF EMPTY(lp_cFrom) OR EMPTY(lp_cServer) OR EMPTY(lp_cUser)
     RETURN lp_lSuccess
ENDIF
lp_cTo = CHRTRAN(EVL(lp_cTo,""),";",",")
lp_cBCC = CHRTRAN(EVL(lp_cBCC,""),";",",")
IF EMPTY(lp_cPass)
     lp_cPass = ""
ENDIF
IF EMPTY(lp_cMessage)
     lp_cMessage = "No text"
ENDIF
IF EMPTY(lp_cSubject)
     lp_cSubject= "No subject"
ENDIF
lp_cSubject = ["] + lp_cSubject + ["]
l_cMessageFile = filetemp()
STRTOFILE(lp_cMessage, l_cMessageFile, 0)
IF EMPTY(lp_cSubject)
     lp_cSubject = ""
ENDIF
IF NOT lp_lSilent
     WAIT WINDOW GetLangText("ADDRESS","TXT_SEND_EMAIL") NOWAIT
ENDIF
l_cSendString = l_cMessageFile + [ ] + ;
          [-to "] + lp_cTo + [" ] + ;
          IIF(EMPTY(lp_cBCC), "", [-bcc "] + lp_cBCC + [" ]) + ;
          [-f ] + lp_cFrom + [ ] + ;
          [-s ] + ansitooem(lp_cSubject) + [ ] + ;
          IIF(NOT EMPTY(lp_cAttachments),[-attach ] + ansitooem(lp_cAttachments) + [ ],[]) + ;
          [-server ] + lp_cServer + [ ] + ;
          [-u ] + lp_cUser + [ ] + ;
          [-pw ] + lp_cPass + [ ] + ;
          IIF(lp_lDebug,[-debug ],[ ]) + ;
          IIF(EMPTY(lp_cLog), [], [-log ] + lp_cLog)

l_nResponse = 99
FOR i = 1 TO 3
     l_oException = .NULL.
     TRY
          l_nResponse = Send(l_cSendString)
     CATCH TO l_oException
     ENDTRY
     IF l_nResponse = 0
          lp_lSuccess = .T.
          EXIT
     ENDIF
ENDFOR

IF l_nResponse <> 0
     l_cError = "BLAT.DLL: (" + TRANSFORM(l_nResponse) + ") "
     IF NOT ISNULL(l_oException) AND TYPE("l_oException.ErrorNo") = "N"
          l_cError = l_cError + CHR(13) + ;
                    TRANSFORM(l_oException.ErrorNo) + CHR(13) + ;
                    TRANSFORM(l_oException.Message) + CHR(13) + ;
                    TRANSFORM(l_oException.LineContents)
     ENDIF
     errormsg(l_cError)
ENDIF
DELETE FILE (l_cMessageFile)
IF NOT lp_lSilent
     WAIT CLEAR
     IF NOT lp_lSuccess AND lp_lShowMsgBoxWhenError
          = alert(GetLangText("ADDRESS","T_MAILNOTSENT"))
     ENDIF
ENDIF

RETURN lp_lSuccess
ENDPROC
*
PROCEDURE PEgetsignature
LPARAMETERS lp_cQuoteText, lp_lSignatureBeforeReply
LOCAL l_cText, l_cUserName, l_cDep, l_cEmCur, l_nSelect, l_cUsCur
STORE "" TO l_cText, lp_cQuoteText

l_nSelect = SELECT()

= openfiledirect(.F.,"emprop")

l_cEmCur = sqlcursor("SELECT ep_sgcustm, ep_quote, ep_sgbfrpl FROM emprop WHERE 1=1")

IF USED(l_cEmCur) AND RECCOUNT(l_cEmCur)>0
     lp_cQuoteText = ALLTRIM(&l_cEmCur..ep_quote)
     lp_lSignatureBeforeReply = &l_cEmCur..ep_sgbfrpl
     IF NOT EMPTY(&l_cEmCur..ep_sgcustm)
          l_cUsCur = sqlcursor([SELECT * FROM "user" WHERE us_id = ] + sqlcnv(PADR(TRIM(g_userid),10),.T.))
          IF USED(l_cUsCur) AND RECCOUNT(l_cUsCur)>0
               l_cText = l_cText + &l_cEmCur..ep_sgcustm
               l_cText = STRTRAN(l_cText, "#BN",ALLTRIM(&l_cUsCur..us_name))
               l_cText = STRTRAN(l_cText, "#BE",ALLTRIM(&l_cUsCur..us_email))
               l_cText = STRTRAN(l_cText, "#BP",ALLTRIM(&l_cUsCur..us_phone))
               l_cText = STRTRAN(l_cText, "#BF",ALLTRIM(&l_cUsCur..us_fax))
               l_cText = STRTRAN(l_cText, "#AB",ALLTRIM(&l_cUsCur..us_dep))
          ENDIF
          dclose(l_cUsCur)
     ENDIF
ENDIF

dclose(l_cEmCur)

SELECT (l_nSelect)

RETURN l_cText
ENDPROC
*
PROCEDURE PECreateEmailClient
LOCAL l_oEmail

l_oEmail = NEWOBJECT("emailclient","cit_email")
IF VARTYPE(l_oEmail) <> "O"
     l_oEmail = .NULL.
ENDIF

RETURN l_oEmail
ENDPROC
*
PROCEDURE PEGetHEader
LPARAMETERS lp_nListId, lp_cTitle, lp_cFname, lp_cLname, lp_cSalute, lp_cLang
LOCAL l_cText, l_nListId, l_cLangNum, l_aListsRec(1)

l_cText = ""
l_nListId = lp_nListId
IF NOT EMPTY(l_nListId)
     l_aListsRec(1) = .T.
     l_cLangNum = STR(DLookUp('PickList', 'pl_label = [LANGUAGE] AND pl_charcod = ' + ;
          SqlCnv(IIF(EMPTY(lp_cLang), _screen.oGlobal.oParam.pa_lang, lp_cLang)), 'pl_numval'), 1)
     SqlCursor("SELECT li_emhea"+l_cLangNum+" FROM lists WHERE li_liid = " + SqlCnv(l_nListId,.T.),,,,,, @l_aListsRec)
     l_cText = l_aListsRec(1)
ENDIF

IF EMPTY(l_cText)
     l_cText = emprop.ep_head
ELSE
     
ENDIF
l_cText = STRTRAN(l_cText, "#AR", ALLTRIM(lp_cTitle))
l_cText = STRTRAN(l_cText, "#EN", ALLTRIM(lp_cFname))
l_cText = STRTRAN(l_cText, "#NA", ALLTRIM(lp_cLname))
l_cText = STRTRAN(l_cText, "#BA", ALLTRIM(lp_cSalute))

RETURN l_cText
ENDPROC
*
PROCEDURE PESendAuto
* Send automaticlly arrival and departure greeting emails to guests
LPARAMETERS lp_lAudit
LOCAL l_nSelect, l_cIniFile, l_lDoIt
PRIVATE p_cEmCursor, p_cSubject, p_cText, p_nCountArr, p_nCountDep
p_cEmCursor = ""
p_cSubject = ""
p_cText = ""
p_cAttachment = ""
p_nCountArr = 0
p_nCountDep = 0
IF NOT _screen.OL
     RETURN .T.
ENDIF

= loGdata(TRANSFORM(DATETIME())+"|"+"Start|UserId: "+IIF(lp_lAudit,"AUDIT",g_userid)+"|SysDate:"+TRANSFORM(sysdate()),"autoemail.log")
*ASSERT .F.
l_lDoIt = .NULL.

l_nSelect = SELECT()

= openfiledirect(.F.,"emprop")

p_cEmCursor = sqlcursor("SELECT * FROM emprop WHERE 1=1",,,,,,,.T.)
IF USED(p_cEmCursor) AND RECCOUNT(p_cEmCursor) > 0
     IF &p_cEmCursor..ep_autosna
          l_lDoIt = .T.&&yesno(GetLangText("EMAIL","TXT_PROCEED_WITH_AUTO_SEND_EMAILS"))
          IF l_lDoIt
               PESendAutoCheckEnivroment()
               PESendAutoArrivals()
          ENDIF
     ENDIF
     IF &p_cEmCursor..ep_autosnd
          IF NOT VARTYPE(l_lDoIt)="L"
               l_lDoIt = .T.&&yesno(GetLangText("EMAIL","TXT_PROCEED_WITH_AUTO_SEND_EMAILS"))
          ENDIF
          IF l_lDoIt
               PESendAutoCheckEnivroment()
               PESendAutoDepartures()
          ENDIF
     ENDIF
     IF p_nCountArr+p_nCountDep>0
          alert(GetLangText("VIEW","TW_ARRIVALS")+": "+TRANSFORM(p_nCountArr) + " E-Mail(s)"+CHR(13)+CHR(10)+;
               GetLangText("VIEW","TW_DEPARTS")+": "+TRANSFORM(p_nCountDep) + " E-Mail(s)")
     ENDIF
ENDIF

= loGdata(TRANSFORM(DATETIME())+"|"+;
     "Send?: " + IIF(l_lDoIt,"YES","NO")+"|"+;
     "Sent arrival emails: " + TRANSFORM(p_nCountArr)+"|departure emails:"+TRANSFORM(p_nCountDep),"autoemail.log")

dclose(p_cEmCursor)
SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE PESendAutoArrivals
LOCAL l_cResCur, l_cSql, l_dCutDate, l_nLangNum, l_lSuccess, l_dSysDate, l_cMainWhere

p_cAttachment = ALLTRIM(&p_cEmCursor..ep_earrat)
IF NOT EMPTY(p_cAttachment)
     p_cAttachment = FULLPATH(ADDBS(ALLTRIM(emprop.ep_attpath)) + p_cAttachment)
     IF NOT FILE(p_cAttachment)
          p_cAttachment = FULLPATH(ALLTRIM(&p_cEmCursor..ep_earrat))
          IF NOT FILE(p_cAttachment)
               p_cAttachment = ""
          ENDIF
     ENDIF
ENDIF
l_dSysDate = sysdate()
l_dCutDate = l_dSysDate + &p_cEmCursor..ep_earrd
IF odbc()
     l_cMainWhere = "rs_arrdate >= " + sqlcnv(l_dSysDate,.T.) + " AND rs_arrdate <= " + sqlcnv(l_dCutDate,.T.)
ELSE
     l_cMainWhere = "DTOS(rs_arrdate)+rs_lname >= '" + DTOS(l_dSysDate) + "' AND DTOS(rs_arrdate)+rs_lname <= '" + DTOS(l_dCutDate) + "'"
ENDIF

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT reservat.*, address.* 
          FROM ( 
               SELECT rs_rsid, CAST(IIF(rs_addrid=0,rs_compid,rs_addrid) AS Numeric(8)) AS c_addrid 
               FROM reservat 
               INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp AND rt_group IN (1,4) 
               WHERE <<l_cMainWhere>> AND rs_emailst = 0 AND NOT rs_status IN ('NS','CXL','IN','OUT','OPT','LST','TEN') AND rs_depdate - rs_arrdate>0 
               ) c1 
          INNER JOIN reservat ON c1.rs_rsid = reservat.rs_rsid 
          INNER JOIN address ON c1.c_addrid = ad_addrid 
          WHERE ad_email <> '         ' AND NOT ad_nomail 
ENDTEXT

l_cResCur = sqlcursor(l_cSql)
IF USED(l_cResCur)
     SELECT (l_cResCur)
     SCAN ALL
          l_nLangNum = dlookup("picklist", "pl_label = 'LANGUAGE' AND pl_charcod = '" + TRANSFORM(IIF(EMPTY(ad_lang),"ENG",ad_lang)) + "'", "pl_numval")
          p_cSubject = PESendAutoParseEMailSubject(EVALUATE(p_cEmCursor + ".ep_earrre" + TRANSFORM(l_nLangNum)))
          p_cText = PESendAutoParseEMailBody(EVALUATE(p_cEmCursor + ".ep_earrtm" + TRANSFORM(l_nLangNum)))
          l_lSuccess = PESendAutoOneEMail()
          IF l_lSuccess
               p_nCountArr = p_nCountArr + 1
               sqlupdate("reservat","rs_rsid = " + TRANSFORM(&l_cResCur..rs_rsid),"rs_emailst = 1")
          ENDIF
          = loGdata(TRANSFORM(DATETIME())+"|"+"Arrival E-Mail for" + ; 
                    " rs_rsid:"+TRANSFORM(&l_cResCur..rs_rsid) + ;
                    " ad_email:"+ALLTRIM(&l_cResCur..ad_email) + ;
                    " sending success: "+TRANSFORM(l_lSuccess),"autoemail.log")
     ENDSCAN
ENDIF

= loGdata(TRANSFORM(DATETIME())+"|"+"Arrivals found: " + TRANSFORM(p_nCountArr),"autoemail.log")

dclose(l_cResCur)
RETURN .T.
ENDPROC
*
PROCEDURE PESendAutoDepartures
LOCAL l_cResCur, l_cSql, l_dCutDate, l_nLangNum, l_lSuccess, l_dSysDate, l_cMainWhere, l_dMaxPastDate

p_cAttachment = ALLTRIM(&p_cEmCursor..ep_edepat)
IF NOT EMPTY(p_cAttachment)
     p_cAttachment = FULLPATH(ADDBS(ALLTRIM(emprop.ep_attpath)) + p_cAttachment)
     IF NOT FILE(p_cAttachment)
          p_cAttachment = FULLPATH(ALLTRIM(&p_cEmCursor..ep_edepat))
          IF NOT FILE(p_cAttachment)
               p_cAttachment = ""
          ENDIF
     ENDIF
ENDIF

l_dSysDate = sysdate()
l_dCutDate = l_dSysDate - &p_cEmCursor..ep_edepd
l_dMaxPastDate = MAX(l_dSysDate - 60,&p_cEmCursor..ep_autosns) && Hardcoded, max. 2 months in the past
l_cMainWhere = "hr_depdate <= " + sqlcnv(l_dCutDate,.T.) + " AND hr_depdate >= " + sqlcnv(l_dMaxPastDate,.T.)

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT histres.*, address.* 
          FROM ( 
               SELECT hr_rsid, CAST(IIF(hr_addrid=0,hr_compid,hr_addrid) AS Numeric(8)) AS c_addrid 
               FROM histres 
               INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp AND rt_group IN (1,4) 
               WHERE <<l_cMainWhere>> AND hr_status = 'OUT' AND hr_emailst IN (0,1) AND hr_depdate - hr_arrdate > 0 
               ) c1 
          INNER JOIN histres ON c1.hr_rsid = histres.hr_rsid 
          INNER JOIN address ON c1.c_addrid = ad_addrid 
          WHERE ad_email <> '         ' AND NOT ad_nomail
ENDTEXT

l_cResCur = sqlcursor(l_cSql)
IF USED(l_cResCur)
     SELECT (l_cResCur)
     SCAN ALL
          l_nLangNum = dlookup("picklist", "pl_label = 'LANGUAGE' AND pl_charcod = '" + TRANSFORM(IIF(EMPTY(ad_lang),"ENG",ad_lang)) + "'", "pl_numval")
          p_cSubject = PESendAutoParseEMailSubject(EVALUATE(p_cEmCursor + ".ep_edepre" + TRANSFORM(l_nLangNum)))
          p_cText = PESendAutoParseEMailBody(EVALUATE(p_cEmCursor + ".ep_edeptm" + TRANSFORM(l_nLangNum)))
          l_lSuccess = PESendAutoOneEMail()
          IF l_lSuccess
               p_nCountDep = p_nCountDep + 1
               sqlupdate("histres","hr_rsid = " + TRANSFORM(&l_cResCur..hr_rsid),"hr_emailst = 2")
               sqlupdate("reservat","rs_rsid = " + TRANSFORM(&l_cResCur..hr_rsid),"rs_emailst = 2")
          ENDIF
          = loGdata(TRANSFORM(DATETIME())+"|"+"Departure E-Mail for" + ; 
                    " hr_rsid:"+TRANSFORM(&l_cResCur..hr_rsid) + ;
                    " ad_email:"+ALLTRIM(&l_cResCur..ad_email) + ;
                    " sending success: "+TRANSFORM(l_lSuccess),"autoemail.log")
     ENDSCAN
ENDIF

= loGdata(TRANSFORM(DATETIME())+"|"+"Departures found: " + TRANSFORM(p_nCountDep),"autoemail.log")

dclose(l_cResCur)
RETURN .T.
ENDPROC
*
PROCEDURE PESendAutoParseEMailSubject
LPARAMETERS lp_cText
lp_cText = ALLTRIM(lp_cText)
l_cText = TEXTMERGE(lp_cText)
RETURN l_cText
ENDPROC
*
PROCEDURE PESendAutoParseEMailBody
LPARAMETERS lp_cText
l_cText = TEXTMERGE(lp_cText)
RETURN l_cText
ENDPROC
*
PROCEDURE PESendAutoOneEMail
LOCAL l_lSuccess, l_oAttach, l_cEmail, l_nRsId, l_lHist
l_lSuccess = .T.

IF NOT EMPTY(p_cAttachment)
     l_oAttach = CREATEOBJECT("collection")
     l_oAttach.Add(p_cAttachment,"1")
ENDIF
l_cEmail = ALLTRIM(ad_email)
l_lHist = IIF(TYPE("hr_rsid")="N",.T., .F.)
l_nRsId = IIF(l_lHist,hr_rsid, rs_rsid)
WAIT WINDOW "E-Mail " + TRANSFORM(IIF(l_lHist,hr_reserid,rs_reserid)) NOWAIT
l_lSuccess = PESendMail( ;
          l_cEmail, ;
          l_oAttach, ;
          l_cEmail, ;
          p_cSubject, ;
          p_cText, ;
          .T., ;
          ad_addrid, ;
          .T., ;
          .T., ;
          .T., ;
          l_nRsId ;
          )
WAIT CLEAR
FNDoEvents()
RETURN l_lSuccess
ENDPROC
*
PROCEDURE PESendAutoCheckEnivroment
* To prevent error in TEXTMERGE, when called get_rm_rmname()
IF NOT USED("RMRTBLD")
     get_rm_rmname("XXX")
ENDIF
* check start date for departure e-mails
IF EMPTY(&p_cEmCursor..ep_autosns)
     sqlupdate("emprop","1=1","ep_autosns = " + sqlcnv(sysdate(),.T.))
     REPLACE ep_autosns WITH sysdate() IN &p_cEmCursor
ENDIF
RETURN .T.
ENDPROC