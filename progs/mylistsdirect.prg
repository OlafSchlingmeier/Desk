*PROCEDURE mylistsdirect

* Call direct report file. Report language file would be used, when exists.

LPARAMETERS lp_cRepFile, lp_lPreview, lp_cCurAlias, lp_lCloseAlias, lp_cFor, lp_lListsTable, lp_cRepLang

LOCAL l_cRepFile, loSession, lnRetVal, l_lAutoYield, loXFF, loExtensionHandler, loPreview, l_cLangFile, ;
          l_nSelect, l_lNoListsTable
IF EMPTY(lp_cRepFile)
     RETURN .F.
ENDIF
l_cRepFile = ADDBS(gcReportdir)+ALLTRIM(lp_cRepFile)

IF NOT FILE(l_cRepFile)
     alert(StrFmt(getlangtext("AR","TA_NOFRX"),l_cRepFile))
     RETURN .F.
ENDIF

IF EMPTY(lp_cFor)
     lp_cFor = ".T."
ENDIF
l_lNoListsTable = NOT lp_lListsTable
IF EMPTY(lp_cRepLang)
     lp_cRepLang = g_Language
ENDIF

l_nSelect = SELECT()
l_cLangFile = FORCEEXT(l_cRepFile, "dbf")

DO PBSetReportLanguage IN prntbill WITH lp_cRepLang
IF FILE(l_cLangFile)
     dclose("rePtext")
     USE SHARED NOUPDATE (l_cLangFile) ALIAS rePtext IN 0
ENDIF

IF NOT EMPTY(lp_cCurAlias)
     SELECT (lp_cCurAlias)
ENDIF

IF lp_lPreview
     IF g_lUseNewRepPreview
          loSession=EVALUATE([xfrx("XFRX#LISTENER")])
          lnRetVal = loSession.SetParams("",,,,,,"XFF") && no name = just in memory
          IF lnRetVal = 0
               l_lAutoYield = _vfp.AutoYield
               _vfp.AutoYield = .T.
               REPORT FORM (l_cRepFile) FOR &lp_cFor OBJECT loSession
               loXFF = loSession.oxfDocument 
               _vfp.AutoYield = l_lAutoYield
               loExtensionHandler = CREATEOBJECT("MyExtensionHandler")
               loExtensionHandler.lNoListsTable = l_lNoListsTable
               loPreview = CREATEOBJECT("frmMpPreviewerDesk")
               loPreview.setExtensionHandler(loExtensionHandler)
               loPreview.PreviewXFF(loXFF)
               loPreview.show(1)
               loExtensionHandler = .NULL.
          ENDIF
     ELSE
          REPORT FORM (l_cRepFile) FOR &lp_cFor PREVIEW
     ENDIF
ELSE
     REPORT FORM (l_cRepFile) FOR &lp_cFor TO PRINTER PROMPT NOCONSOLE
ENDIF

IF NOT EMPTY(lp_cCurAlias) AND lp_lCloseAlias
     dclose(lp_cCurAlias)
ENDIF
dclose("rePtext")

SELECT (l_nSelect)

RETURN .T.
ENDPROC