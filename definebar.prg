PROCEDURE definebar
 LPARAMETERS lp_nBar, lp_cMenu, lp_cText, lp_cMenupad, lp_nMenubar, lp_cSkipFor, lp_cPicture, lp_cKey, lp_cStyle
 LOCAL l_lShowMenuBar, l_lNoUserRights, l_cSkipFor, l_lSwitch, l_cDefineBarMacro, l_cPicture, l_cKey, l_cStyle
 IF TYPE("_screen.oGlobal.oParam.pa_covmenu")="L"
      l_lSwitch = _screen.oGlobal.oParam.pa_covmenu
 ELSE
      l_lSwitch = .F.
 ENDIF
 l_lShowMenuBar = .F.
 IF EMPTY(lp_cMenupad)
      l_lNoUserRights = .F.
 ELSE
      l_lNoUserRights = noUserrights(lp_cMenupad,lp_nMenubar)
 ENDIF
 l_lShowMenuBar = NOT (l_lSwitch AND l_lNoUserRights)
 IF EMPTY(lp_cSkipFor)
      lp_cSkipFor = ""
 ELSE
      lp_cSkipFor = " " + lp_cSkipFor 
 ENDIF
 IF l_lNoUserRights
      l_cSkipFor = ".T." + lp_cSkipFor
 ELSE
      l_cSkipFor = ".F." + lp_cSkipFor
 ENDIF
 IF l_lShowMenuBar
      DO CASE
           CASE EMPTY(lp_cPicture)
                l_cPicture = ""
           CASE TYPE("_Screen.oGlobal.oColPictures") = "O"
                l_cPicture = " PICTURE '" + _Screen.oGlobal.oColPictures.GetPicture(lp_cPicture) + "'"
           OTHERWISE
                l_cPicture = " PICTURE '" + lp_cPicture + "'"
      ENDCASE
      l_cPicture = IIF(EMPTY(lp_cPicture), "", " PICTURE '" + lp_cPicture + "'")
      l_cKey = IIF(EMPTY(lp_cKey), "", " KEY " + lp_cKey)
      l_cStyle = IIF(EMPTY(lp_cStyle), "", " STYLE '" + lp_cStyle + "'")
      l_cDefineBarMacro = "DEFINE BAR %s1 OF %s2 PROMPT [%s3] SKIP FOR %s4%s5%s6%s7"
      l_cDefineBarMacro = Str2Msg(l_cDefineBarMacro, "%s", ALLTRIM(STR(lp_nBar)), lp_cMenu, lp_cText, l_cSkipFor, l_cPicture, l_cKey, l_cStyle)
      &l_cDefineBarMacro
 ENDIF
 RETURN l_lShowMenuBar
ENDPROC