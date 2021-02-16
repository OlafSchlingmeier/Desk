FUNCTION GetLangText
 LPARAMETER tcProgramName, tcTxtLabel, tcLanguage, tlWithoutLine

 DO CASE
      CASE TYPE("_screen.oGlobal") # "O"
           RETURN tcTxtLabel
      CASE PCOUNT() < 3
           RETURN _screen.oGlobal.GetLangText(tcProgramName, tcTxtLabel)
      OTHERWISE
           RETURN _screen.oGlobal.GetLangText(tcProgramName, tcTxtLabel, tcLanguage, tlWithoutLine)
 ENDCASE
ENDFUNC
*
FUNCTION GetText
 LPARAMETER tcProgramName, tcTxtLabel, tcLanguage, tlWithoutLine

 RETURN GetLangText(tcProgramName, tcTxtLabel, tcLanguage, tlWithoutLine)
ENDFUNC
*
FUNCTION GetAppLangText
 LPARAMETERS tcProgramName, tcTxtLabel

 RETURN GetLangText(tcProgramName, tcTxtLabel)
ENDFUNC
*