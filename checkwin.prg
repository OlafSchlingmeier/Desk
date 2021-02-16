PROCEDURE CheckWin
 LPARAMETERS lp_cMacro, lp_lSetMessagesOff, lp_lCloseAll, lp_lCalledFromReleaseTimer, lp_lForceExit, lp_lSkipServerForms
 LOCAL l_cFormCaption, l_lAllowed, l_lExit

 * When called to close all windows and exit Brilliant, check if active window is modal
 * and ask user a question, is he sure.
 l_lExit = "cleanup" $ LOWER(lp_cMacro)
 IF l_lExit AND NOT lp_lCalledFromReleaseTimer
      = FormClosingAllowed(@l_lAllowed, @l_cFormCaption)
      IF NOT l_lAllowed
           alert(strfmt(GetLangText("COMMON","TXT_CLOSE_WINDOW_FIRST"),l_cFormCaption))
           RETURN .F.
      ELSE
           IF NOT lp_lForceExit
                IF NOT yesno(getapplangtext("COMMON","TXT_CLOSE_PROGRAM") + "@2")
                     RETURN .F.
                ENDIF
           ENDIF
      ENDIF
 ENDIF

 IF lp_lSetMessagesOff
      DO SetMessagesOff IN procmessages
 ENDIF
 IF VARTYPE(g_oTmrRelease) = "O"
      g_oTmrRelease.StartReleasing(lp_cMacro, lp_lCloseAll, lp_lSkipServerForms)
 ELSE
      DO &lp_cMacro
 ENDIF
 RETURN .T.
ENDPROC
*
PROCEDURE FormClosingAllowed
 LPARAMETERS lp_lAllowed, lp_cFormCaption
 LOCAL l_lAllowed, l_lModal, l_oForm 
 lp_cFormCaption = ""
 l_lAllowed = .T.
 IF TYPE("_screen.ActiveForm.Name")="C"
      FOR EACH l_oForm IN _screen.Forms
           IF LOWER(l_oform.Name) = "preview"
                lp_cFormCaption = l_oForm.Caption
                l_lAllowed = .F.
           ENDIF
      ENDFOR
      IF l_lAllowed
           lp_cFormCaption = _screen.ActiveForm.Caption
           l_lModal = (_screen.ActiveForm.WindowType = 1)
           IF l_lModal
                IF NOT LOWER(_screen.ActiveForm.Name)=="frmlogin"
                     l_lAllowed = .F.
                ENDIF
           ENDIF
      ENDIF
 ENDIF
 lp_lAllowed = l_lAllowed
 RETURN l_lAllowed
ENDPROC
