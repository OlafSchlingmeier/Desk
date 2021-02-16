PROCEDURE InitializeMsgHandler
 g_oTmrLogOut = NEWOBJECT("logouttimer","libs\cit_system.vcx")
 DO FORM forms\MessagesForm.scx NAME g_oMsgHandler LINKED NOSHOW
 RETURN .T.
ENDPROC
*
PROCEDURE SetMessagesOn
 IF VARTYPE(g_oMsgHandler)="O" AND NOT ISNULL(g_oMsgHandler)
      g_oMsgHandler.SetMessagesOn()
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE SetMessagesOff
 IF VARTYPE(g_oMsgHandler)="O" AND NOT ISNULL(g_oMsgHandler)
      g_oMsgHandler.SetMessagesOff()
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE ShowMessages
 IF VARTYPE(g_oMsgHandler)="O" AND NOT ISNULL(g_oMsgHandler)
      g_oMsgHandler.Show()
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE ClearAllMessages
 LOCAL l_cAlias, l_nSelect
 l_cAlias = SYS(2015)
 l_nSelect = SELECT()
 openfiledirect(.F.,"messages")
 IF USED(l_cAlias)
      DELETE ALL IN &l_cAlias
      USE IN &l_cAlias
 ENDIF
 SELECT (l_nSelect)
 RETURN .T.
ENDPROC
*