*
FUNCTION PrinterSetUp
 PARAMETER ctItle
 = chIldtitle(ctItle)
 = SYS(1037)
 = chIldtitle("")
 RETURN .T.
ENDFUNC
*
FUNCTION FiscalMenu
 LOCAL l_lSuccess
 LOCAL ARRAY l_aDialogData(3, 11)
 IF _screen.oGlobal.lfiskaltrustactive
     l_aDialogData(1,1) = "cboFunction"
     l_aDialogData(1,2) = GetLangText("MGRPLIST","TXT_FISCALTRUST_FUNC")
     l_aDialogData(1,3) = ""
     l_aDialogData(1,4) = "@G"
     l_aDialogData(1,5) = 30
     l_aDialogData(1,6) = ""
     l_aDialogData(1,7) = ""
     l_aDialogData(1,9) = GetLangText("FISKALTR","TXT_ZERO_SLIP") + ",ZERO_SLIP," + ;
                          IIF(paRights(63), GetLangText("FISKALTR","TXT_STARTUP_SLIP") + ",START-UP_SLIP,", "") + ;
                          IIF(paRights(64), GetLangText("FISKALTR","TXT_SHUTDOWN_SLIP") + ",SHUT-DOWN_SLIP,", "") + ;
                          GetLangText("FISKALTR","TXT_MONTH_SLIP") + ",MONTH_SLIP," + ;
                          GetLangText("FISKALTR","TXT_YEAR_SLIP") + ",YEAR_SLIP," + ;
                          GetLangText("FISKALTR","TXT_DEP_EXPORT") + ",DEP_EXPORT"
     l_aDialogData(1,11) = CREATEOBJECT("Collection")
     l_aDialogData(1,11).Add("150,0","ColumnWidths")
     l_aDialogData(1,11).Add(1,"RowSourceType")
     l_aDialogData(1,11).Add("","DisplayValue")
     l_aDialogData(1,11).Add(CREATEOBJECT("oDepExportCboHandler"),"ohandler")
     l_aDialogData(2,1) = "txtStartDate"
     l_aDialogData(2,2) = GetLangText("BILLHIST","TH_FROM")
     l_aDialogData(2,3) = "{}"
     l_aDialogData(2,5) = 16
     l_aDialogData(2,10) = .T.
     l_aDialogData(3,1) = "txtEndDate"
     l_aDialogData(3,2) = GetLangText("BILLHIST","TH_TO")
     l_aDialogData(3,3) = "{}"
     l_aDialogData(3,5) = 16
     l_aDialogData(3,10) = .T.
     IF Dialog(GetLangText("MGRPLIST","TXT_SELECT_FUNCTION"), "", @l_aDialogData) AND NOT EMPTY(l_aDialogData(1,8))
          l_lSuccess = FpFiskalTrust(l_aDialogData(1,8), l_aDialogData(2,8), l_aDialogData(3,8))
          PRIVATE l_cTitle
          l_cTitle = l_aDialogData(1,11).Item("DisplayValue")
          DO CASE
               CASE NOT l_lSuccess
                    Alert(StrToMsg(GetLangText("FISKALTR","TA_FUNC_FAILED"), l_cTitle))
               CASE INLIST(l_aDialogData(1,8), "ZERO_SLIP", "START-UP_SLIP", "SHUT-DOWN_SLIP", "MONTH_SLIP", "YEAR_SLIP")
                    SELECT param
                    PrintReport(ADDBS(gcReportdir)+"zeroslip1.frx")
               OTHERWISE
          ENDCASE
          LogMenu("FILE|FISKALTRUST " + l_cTitle + "(" + STRTRAN(TRANSFORM(l_lSuccess),".") + ")",,.T.)
     ENDIF
 ENDIF
 RETURN .T.
ENDFUNC
*
DEFINE CLASS oDepExportCboHandler AS Custom
*
PROCEDURE LostFocus
LPARAMETERS lp_oFormRef
STORE lp_oFormRef.cboFunction.Value = "DEP_EXPORT" TO lp_oFormRef.txtStartDate.Enabled, lp_oFormRef.txtEndDate.Enabled
ENDPROC
*
PROCEDURE Release
RELEASE this
ENDPROC
*
ENDDEFINE
*
