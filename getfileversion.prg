PROCEDURE GetFileVersion
LPARAMETERS lp_cExeName, lp_lSpecial
LOCAL ARRAY l_aVersion(15)
LOCAL l_cVersion
l_cVersion = ""
IF TYPE("application.StartMode")=="N" AND Application.StartMode = 4 AND ;
          TYPE("application.ServerName")=="C" AND NOT EMPTY(application.ServerName)
     = AGETFILEVERSION(l_aVersion,application.ServerName)
     l_cVersion= l_aVersion(4)
     lp_lSpecial = ("Special" $ l_aVersion(3))
ELSE
     IF TYPE("application.ActiveProject.VersionNumber")=="C"
          l_cVersion = application.ActiveProject.VersionNumber
     ELSE
          IF NOT EMPTY(lp_cExeName) AND FILE(lp_cExeName)
               = AGETFILEVERSION(l_aVersion,lp_cExeName)
               l_cVersion = ALLTRIM(l_aVersion(4))
               lp_lSpecial = ("Special" $ l_aVersion(3))
          ENDIF
     ENDIF
ENDIF
RETURN l_cVersion
*