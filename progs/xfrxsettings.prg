#INCLUDE "include\constdefines.h"
*
LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
            lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10
LOCAL l_cCallProc, l_nParamNo, l_uRetVal
l_cCallProc = lp_cFuncName + "("
FOR l_nParamNo = 1 TO PCOUNT()-1
     l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
NEXT
l_cCallProc = l_cCallProc + ")"
l_uRetVal = &l_cCallProc
RETURN l_uRetVal
ENDFUNC
*
PROCEDURE XFSetupExcel
LPARAMETERS lp_oListener, lp_cOutputFile, lp_lNotOpenViewer, lp_cArchive
LOCAL l_nRetVal, l_cXLSMode, l_cIniFile, l_lLEAVE_FULL_FIELD_CONTENT, l_nHORIZONTAL_ADJUSTMENT, l_nVERTICAL_ADJUSTMENT

IF g_lDevelopment
     l_cIniFile = FULLPATH(INI_FILE)
     l_lLEAVE_FULL_FIELD_CONTENT = IIF(LOWER(readini(l_cIniFile, "ExcelExport","LEAVE_FULL_FIELD_CONTENT", "yes"))=="no",.F.,.T.)
     l_nHORIZONTAL_ADJUSTMENT = INT(VAL(readini(l_cIniFile, "ExcelExport","HORIZONTAL_ADJUSTMENT", "0")))
     l_nVERTICAL_ADJUSTMENT = INT(VAL(readini(l_cIniFile, "ExcelExport","VERTICAL_ADJUSTMENT", "0")))
ELSE
     l_lLEAVE_FULL_FIELD_CONTENT = _screen.oGlobal.lLEAVE_FULL_FIELD_CONTENT
     l_nHORIZONTAL_ADJUSTMENT = _screen.oGlobal.nHORIZONTAL_ADJUSTMENT       && default value = 76
     l_nVERTICAL_ADJUSTMENT = _screen.oGlobal.nVERTICAL_ADJUSTMENT           && default value = 180
ENDIF

l_cXLSMode = "XLS"

l_nRetVal = lp_oListener.SetParams(lp_cOutputFile   ,,lp_lNotOpenViewer,,,,l_cXLSMode,lp_cArchive,NOT EMPTY(lp_cArchive))
IF l_nRetVal = 0
     lp_oListener.SetOtherParams("LEAVE_FULL_FIELD_CONTENT",l_lLEAVE_FULL_FIELD_CONTENT) 
     lp_oListener.SetOtherParams("HORIZONTAL_ADJUSTMENT",l_nHORIZONTAL_ADJUSTMENT) && default value = 76  
     lp_oListener.SetOtherParams("VERTICAL_ADJUSTMENT",l_nVERTICAL_ADJUSTMENT) && default value = 180 
ENDIF

RETURN l_nRetVal
ENDPROC