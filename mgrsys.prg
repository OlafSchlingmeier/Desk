#INCLUDE "include\constdefines.h"
*
PROCEDURE Users
 DO FORM "forms\MngForm" with "MngUserCtrl"
ENDPROC
*
PROCEDURE Terminals
   DO FORM "forms\MngForm" with "MngTerminalCtrl"
   RETURN
ENDPROC
*
PROCEDURE MSFillDescriptions
* When new record, then copy description for default language to all other languages.
LPARAMETERS tnMode, tuRefObj, tcFieldMacro, tcValue
LOCAL i, lcLangMacro

IF NOT EMPTY(tnMode) AND tnMode = NEW_MODE AND NOT EMPTY(tcValue) AND NOT EMPTY(tcFieldMacro) AND (VARTYPE(tuRefObj) = "O" OR NOT EMPTY(tuRefObj))
     FOR i = 1 TO 11
          IF NOT TRANSFORM(i) == g_langnum
               IF VARTYPE(tuRefObj) = "O"
                    lcLangMacro = "tuRefObj." + tcFieldMacro + TRANSFORM(i)
                    IF TYPE(lcLangMacro) = "C" AND EMPTY(&lcLangMacro)
                         &lcLangMacro = ALLTRIM(tcValue)
                    ENDIF
               ELSE
                    lcLangMacro = tuRefObj + "." + tcFieldMacro + TRANSFORM(i)
                    IF TYPE(lcLangMacro) = "C" AND EMPTY(&lcLangMacro)
                         REPLACE &lcLangMacro WITH ALLTRIM(tcValue) IN &tuRefObj
                    ENDIF
               ENDIF
          ENDIF
     NEXT
ENDIF

RETURN .T.
ENDPROC