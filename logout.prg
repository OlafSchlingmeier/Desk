PROCEDURE LogOut
 LOCAL l_lResult
 l_lResult = .F.
 DO CheckForActions IN procaction WITH l_lResult
 IF l_lResult AND NOT yesno(GetLangText("ACT","TXT_UNCOMPLETED_ACTIONS_DETECTED"))
      doform('activities','forms\activities WITH "CURRENTUSER"')
      RETURN .T.
 ENDIF
 = chEckwin("LOGIN WITH .T.",.T.)
 RETURN .T.
ENDPROC