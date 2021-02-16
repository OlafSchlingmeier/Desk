#INCLUDE "include\constdefines.h"
*
PROCEDURE MainVersion
LOCAL l_cVersion, l_nPosition
l_cVersion = GetFileVersion(APP_EXE_NAME)
l_nPosition = AT(".",l_cVersion,2)
g_buildversion = ALLTRIM(SUBSTR(l_cVersion,l_nPosition+1,3))
RETURN g_buildversion
ENDPROC