#INCLUDE "include\dvapi32.h"

LPARAMETERS lp_cEMail, lp_uAttachPathName, lp_cDisplayName, lp_cSubject, lp_cMsgNoteText, lp_lOutLook
LOCAL l_cEmail, l_cDisplayName, l_cPath, l_cDef, l_oMapiSession, l_oMapiMessages
LOCAL l_nSelect, l_lSuccess, l_oErr, l_nEmailAddressCount, i, l_cOneEmail, l_cError
LOCAL l_oDvApi, l_oAccount, l_oArchive, l_oMailItem
LOCAL l_cAttachPathName

IF EMPTY(lp_cDisplayName)
     lp_cDisplayName = lp_cEMail
ENDIF
IF EMPTY(lp_cSubject)
     lp_cSubject = g_hotel + " " + TRANSFORM(DATETIME())
ENDIF
IF PCOUNT()<6
     lp_lOutLook = IIF(_screen.oGlobal.emtype=2,.T.,.F.)
ENDIF
l_nSelect = SELECT()
l_cPath = SET("Path")
l_cDef = SYS(5)+SYS(2003)
l_cEmail = ALLTRIM(lp_cEMail)
l_cDisplayName = ALLTRIM(lp_cDisplayName)
IF NOT EMPTY(l_cEmail)
     DO CASE
          CASE _screen.oGlobal.emtype = 3
               l_lSuccess = .T.
               TRY
                    l_oDvApi = CREATEOBJECT("DVOBJAPILib.DvISEAPI")
                    l_oAccount = l_oDvApi.Logon("", "", "", "", "", "AUTH")
                    l_oArchive = l_oAccount.GetSpecialArchive(DvArchivePersonalOut)
                    l_oMailItem = l_oArchive.NewItem(DvEMailItem)

                    * Recipts
                    l_nEmailAddressCount = GETWORDCOUNT(l_cEmail,";")
                    FOR i = 1 TO l_nEmailAddressCount
                         l_cOneEmail = ALLTRIM(GETWORDNUM(l_cEmail,i,";"))
                         IF NOT EMPTY(l_cOneEmail) AND "@" $ l_cEmail
                              l_cDisplayName = l_cOneEmail
                              l_oMailItem.Recipients.Add(l_cOneEmail, l_cDisplayName)
                         ENDIF
                    ENDFOR
                    
                    * Main Body Text
                    IF NOT EMPTY(lp_cMsgNoteText)
                         l_oMailItem.BodyText.HTMLText = lp_cMsgNoteText
                    ENDIF
                    
                    * Subject
                    l_oMailItem.Subject = lp_cSubject
                    
                    * Attachments
                    IF TYPE("lp_uAttachPathName")="O" AND LOWER(lp_uAttachPathName.BaseClass) = "collection"
                         FOR EACH l_cAttachPathName IN lp_uAttachPathName FOXOBJECT
                              IF FILE(l_cAttachPathName)
                                   l_oMailItem.Attachments.Add(l_cAttachPathName)
                              ENDIF
                         ENDFOR
                    ELSE
                         IF NOT EMPTY(lp_uAttachPathName) AND FILE(lp_uAttachPathName)
                              l_oMailItem.Attachments.Add(lp_uAttachPathName)
                         ENDIF
                    ENDIF

                    l_oMailItem.Send()
                    l_oAccount.Logoff()
               CATCH TO l_oErr
                    l_lSuccess = .F.
               ENDTRY
          OTHERWISE
               l_oMapiSession = NEWOBJECT("cntmapisession","cit_email.vcx")
               l_oMapiMessages = NEWOBJECT("cntmapimessages","cit_email.vcx")

               l_lSuccess = .T.
               TRY
                    l_oMapiSession.omapiseasson.DownloadMail = .F.
                    l_oMapiSession.omapiseasson.SignOn
                    l_oMapiMessages.omapimessages.SessionID = l_oMapiSession.omapiseasson.SessionID
                    l_oMapiMessages.omapimessages.DoVerb(-1)
                    l_oMapiMessages.omapimessages.Compose
                    
                    * Recipts
                    l_nEmailAddressCount = GETWORDCOUNT(l_cEmail,";")
                    FOR i = 1 TO l_nEmailAddressCount
                         l_cOneEmail = ALLTRIM(GETWORDNUM(l_cEmail,i,";"))
                         IF NOT EMPTY(l_cOneEmail) AND "@" $ l_cEmail
                              l_cDisplayName = l_cOneEmail
                              l_oMapiMessages.omapimessages.RecipIndex = i - 1
                              l_oMapiMessages.omapimessages.RecipType = 1
                              l_oMapiMessages.omapimessages.RecipDisplayName = l_cDisplayName
                              l_oMapiMessages.omapimessages.RecipAddress = IIF(lp_lOutLook,"SMTP:","")+l_cOneEmail
                         ENDIF
                    ENDFOR
                    
                    * Main Body Text
                    IF NOT EMPTY(lp_cMsgNoteText)
                         l_oMapiMessages.omapimessages.MsgNoteText = lp_cMsgNoteText
                    ENDIF
                    
                    * Subject
                    l_oMapiMessages.omapimessages.MsgSubject = lp_cSubject
                    
                    * Attachments
                    IF TYPE("lp_uAttachPathName")="O" AND LOWER(lp_uAttachPathName.BaseClass) = "collection"
                         FOR EACH l_cAttachPathName IN lp_uAttachPathName FOXOBJECT
                              l_oMapiMessages.omapimessages.MsgNoteText = l_oMapiMessages.omapimessages.MsgNoteText + " " && Make sure body is large enough for attachments
                              l_oMapiMessages.omapimessages.AttachmentIndex = l_oMapiMessages.omapimessages.AttachmentCount
                              l_oMapiMessages.omapimessages.AttachmentPosition = l_oMapiMessages.omapimessages.AttachmentIndex
                              l_oMapiMessages.omapimessages.AttachmentName = JUSTFNAME(l_cAttachPathName)
                              l_oMapiMessages.omapimessages.AttachmentPathName = l_cAttachPathName
                         ENDFOR
                    ELSE
                         IF NOT EMPTY(lp_uAttachPathName)
                              l_oMapiMessages.omapimessages.MsgNoteText = l_oMapiMessages.omapimessages.MsgNoteText + " " && Make sure body is large enough for attachments
                              l_oMapiMessages.omapimessages.AttachmentIndex = 0
                              l_oMapiMessages.omapimessages.AttachmentPathName = lp_uAttachPathName
                         ENDIF
                    ENDIF
                    
                    l_oMapiMessages.omapimessages.Send(.T.)
                    l_oMapiSession.omapiseasson.SignOff
               CATCH TO l_oErr
                    l_lSuccess = .F.
               ENDTRY
     ENDCASE

     SET PATH TO (l_cPath)
     SET DEFAULT TO (l_cDef)

     IF NOT l_lSuccess
          l_cError = TRANSFORM(DATETIME()) + CHR(13) + "Error:" + ;
                    TRANSFORM(l_oErr.ErrorNo) + CHR(13) + ;
                    TRANSFORM(l_oErr.Message) + CHR(13) + ;
                    TRANSFORM(l_oErr.Details) + CHR(13) + ;
                    TRANSFORM(l_oErr.LineContents) + CHR(13) + ;
                    TRANSFORM(l_oErr.Procedure)
          
          = loGdata(l_cError,"sendmail.err")
          MESSAGEBOX(GetLangText("ADDRESS","T_MAILNOTSENT") + CHR(13) + CHR(13) + l_cError,64,GetLangText("RECURRES","TXT_INFORMATION"))
     ENDIF
     
     RELEASE l_oMapiSession, l_oMapiMessages
ELSE
     l_lSuccess = .F.
ENDIF
SELECT (l_nSelect)
RETURN l_lSuccess
ENDPROC
*