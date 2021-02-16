#INCLUDE "include\constdefines.h"
*
*********************************************************************
*                                                                   *
* Used to test FXP defined in paRam.pa_naxprg and called from audit *
*                                                                   *
*********************************************************************
*
PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.0.0.0"
RETURN tcVersion
ENDPROC
*
PROCEDURE natest
PARAMETERS pcMode, ptdFrom, ptdTo, ptlskipgenerate, ptlShowDialog
PRIVATE p_cIniFilem, p_dSysDate
LOCAL l_cTentFilter, l_cDefiFilter, l_cDays, l_cTentativeList
LOCAL ARRAY adLg[2, 8]

DO CASE
     CASE EMPTY(pcMode) OR VARTYPE(pcMode) <> "C"
     CASE pcMode = "VERSION"
          pcMode = PpVersion()
          alert(pcMode + " OK")
          RETURN .T.
     CASE pcMode = "BEFOREAUDIT"
          alert(pcMode + " OK")
     CASE pcMode = "AFTERAUDIT"
          alert(pcMode + " OK")
     CASE pcMode = "BEFOREMANAGER"
          alert(pcMode + " OK")
     OTHERWISE
          alert(pcMode + " UNKNOWN!")
ENDCASE

RETURN .T.
ENDPROC
*