*
#INCLUDE "include\constdefines.h"
*
PROCEDURE MonthTimePlan
LOCAL i, l_lCloseJob, l_dSearchDate, l_nSelectedJob, l_nRow
LOCAL ARRAY l_aMonthPlan(1,5)

IF NOT USED("job")
	Openfile(.F.,"job")
	l_lCloseJob = .T.
ENDIF

IF ChangeWorkHourPeriod(,@l_dSearchDate, @l_nSelectedJob)
	l_nRow = 1
	l_aMonthPlan[l_nRow, 1] = "cr_name"
	l_aMonthPlan[l_nRow, 2] = GetLangText("ADDRESS","TH_NAME")
	l_aMonthPlan[l_nRow, 3] = 130
	l_nRow = Aadd(@l_aMonthPlan)
	l_aMonthPlan[l_nRow, 1] = "IIF(EMPTY(cr_vacatio+cr_unusvac), '', TRANSFORM(cr_vacatio)+'+'+TRANSFORM(cr_unusvac)+'/'+TRANSFORM(cr_vacatio+cr_unusvac-cr_usedvac))"
	l_aMonthPlan[l_nRow, 2] = GetLangText("TIMETYPE","TH_VACATION") + " / " + CRLF + GetLangText("TIMETYPE","TH_REMVACATION")
	l_aMonthPlan[l_nRow, 3] = 70
	l_aMonthPlan[l_nRow, 4] = .T.
	l_aMonthPlan[l_nRow, 5] = 2
	FOR i = 1 TO 31
		l_nRow = Aadd(@l_aMonthPlan)
		l_aMonthPlan[l_nRow, 1] = "cr_day" + TRANSFORM(i)
		l_aMonthPlan[l_nRow, 2] = TRANSFORM(i) + " " + CRLF + LEFT(MyCDoW(DOW(l_dSearchDate-1+i)),2)
		l_aMonthPlan[l_nRow, 3] = 25
		l_aMonthPlan[l_nRow, 4] = .T.
	ENDFOR
	DO FORM "forms\timemonthview" WITH l_aMonthPlan, l_dSearchDate, l_nSelectedJob
ENDIF
IF l_lCloseJob
	Closefile("job")
ENDIF

SetStatusLine()
ENDPROC
*
PROCEDURE TimePlanBrowse
LPARAMETERS lp_nEmplID
LOCAL ARRAY l_aMonthPlan(1,3)
LOCAL l_nRow, l_cCaption

l_nRow = 1
l_aMonthPlan[l_nRow, 1] = 'ae_from'
l_aMonthPlan[l_nRow, 2] = GetLangText("RESERVAT","TH_FROM")
l_aMonthPlan[l_nRow, 3] = 100
l_nRow = aadd(@l_aMonthPlan)
l_aMonthPlan[l_nRow, 1] = 'ae_to'
l_aMonthPlan[l_nRow, 2] = GetLangText("RESERVAT","TH_TO")
l_aMonthPlan[l_nRow, 3] = 100
l_nRow = aadd(@l_aMonthPlan)
l_aMonthPlan[l_nRow, 1] = 'tt_descr'
l_aMonthPlan[l_nRow, 2] = GetLangText("MGRPLIST","TXT_TIMETYPE")
l_aMonthPlan[l_nRow, 3] = 150

l_cCaption = DLookUp("employee", "em_emid = " + SqlCnv(lp_nEmplID), "ALLTRIM(em_lname) + ', ' + ALLTRIM(em_fname)")
DO FORM "forms\timeemployee" WITH l_cCaption, l_aMonthPlan, lp_nEmplID
ENDPROC
*
PROCEDURE CreateTimePlanCursor
LPARAMETERS lp_cCursorName, lp_nEmplID, lp_lReadWrite
LOCAL l_cRW

l_cRW = IIF(lp_lReadWrite, "READWRITE", "")

SELECT asgempl.*, tt_descr ;
	FROM asgempl ;
	LEFT JOIN timetype ON ae_ttnr = tt_ttnr ;
	WHERE ae_emid = lp_nEmplID ;
	ORDER BY ae_from ;
	INTO CURSOR (lp_cCursorName) &l_cRW

SetStatusLine()
ENDPROC
*
PROCEDURE WorkPlanBrowse
LOCAL ARRAY l_aWorkPlan(1,5)
LOCAL l_nRow, l_cCaption

l_nRow = 1
l_aWorkPlan[l_nRow, 1] = 'cr_pernr'
l_aWorkPlan[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_PERSONNEL_NO")
l_aWorkPlan[l_nRow, 3] = 100
l_nRow = aadd(@l_aWorkPlan)
l_aWorkPlan[l_nRow, 1] = 'cr_name'
l_aWorkPlan[l_nRow, 2] = GetLangText("ADDRESS","TH_NAME")
l_aWorkPlan[l_nRow, 3] = 150
l_nRow = Aadd(@l_aWorkPlan)
l_aWorkPlan[l_nRow, 1] = "IIF(EMPTY(cr_vacatio+cr_unusvac), '', TRANSFORM(cr_vacatio)+'+'+TRANSFORM(cr_unusvac)+'/'+TRANSFORM(cr_vacatio+cr_unusvac-cr_usedvac))"
l_aWorkPlan[l_nRow, 2] = GetLangText("TIMETYPE","TH_VACATION") + " / " + CRLF + GetLangText("TIMETYPE","TH_REMVACATION")
l_aWorkPlan[l_nRow, 3] = 70
l_aWorkPlan[l_nRow, 4] = .T.
l_aWorkPlan[l_nRow, 5] = 2
l_nRow = aadd(@l_aWorkPlan)
l_aWorkPlan[l_nRow, 1] = 'ConvSecToTime(cr_sec,6,)'
l_aWorkPlan[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_HOURS")
l_aWorkPlan[l_nRow, 3] = 70

l_cCaption = TRANSFORM(MONTH(sysdate()))+"/"+TRANSFORM(YEAR(sysdate()))
DO FORM "forms\timeworkhours" WITH l_cCaption, l_aWorkPlan
SetStatusLine()
ENDPROC
*
PROCEDURE WorkHoursDetailsBrowse
LPARAMETERS lp_nEmployeeID, lp_dSelectedDate
LOCAL ARRAY l_aWorkDetailPlan(1,4)
LOCAL l_nRow, l_oWorkTimeHandler, l_cCaption

l_oWorkTimeHandler = CREATEOBJECT("brilliantworktime")

l_nRow = 1
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_sysdate), '', LEFT(MyCDoW(cr_sysdate),2))"
l_aWorkDetailPlan[l_nRow, 2] = "----"
l_aWorkDetailPlan[l_nRow, 3] = 30
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_sysdate), '', DAY(cr_sysdate))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("RESERVAT","T_OFFSET")
l_aWorkDetailPlan[l_nRow, 3] = 30
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_sysdate) OR EMPTY(cr_event), '', cr_event)"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("EVENT","TXT_EVENT")
l_aWorkDetailPlan[l_nRow, 3] = 50
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_sysdate) OR EMPTY(cr_ttcode), '', cr_ttcode)"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("MGRPLIST","TXT_TIMETYPE")
l_aWorkDetailPlan[l_nRow, 3] = 50
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_whintend), '', ConvSecToTime(cr_whintend,9,))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_INTENDED")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_begin), '', LEFT(TTOC(cr_begin,2),5))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("RESERVAT","TH_FROM")
l_aWorkDetailPlan[l_nRow, 3] = 50
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_end), '', LEFT(TTOC(cr_end,2),5))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("RESERVAT","TH_TO")
l_aWorkDetailPlan[l_nRow, 3] = 50
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_nwhours), '', ConvSecToTime(cr_nwhours,9,))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_SUM_WORKTIME")
l_aWorkDetailPlan[l_nRow, 3] = 100
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_npause + IIF(cr_defbrk, 60*cr_dmin, 0)), '', ConvSecToTime(cr_npause + IIF(cr_defbrk, 60*cr_dmin, 0),9,))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_SUM_PAUSE")
l_aWorkDetailPlan[l_nRow, 3] = 100
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_nrwhours), '', ConvSecToTime(cr_nrwhours,9,))"
l_aWorkDetailPlan[l_nRow, 2] = l_oWorkTimeHandler.GetRoundedHoursCaption()
l_aWorkDetailPlan[l_nRow, 3] = 100
l_aWorkDetailPlan[l_nRow, 4] = .T.
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_overtime), '', ConvSecToTime(cr_overtime,9,))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_OVERTIME")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_whsun), '', ConvSecToTime(cr_whsun,9,))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("FUNC","TXT_SUNDAY")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_whhol), '', ConvSecToTime(cr_whhol,9,))"
l_aWorkDetailPlan[l_nRow, 2] = GetLangText("FUNC","TXT_HOLIDAY")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_whng1), '', ConvSecToTime(cr_whng1,9,))"
l_aWorkDetailPlan[l_nRow, 2] = l_oWorkTimeHandler.GetCaption("NIGHT")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_aWorkDetailPlan[l_nRow, 4] = .T.
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_whng2), '', ConvSecToTime(cr_whng2,9,))"
l_aWorkDetailPlan[l_nRow, 2] = l_oWorkTimeHandler.GetCaption("MIDNIGHT 1")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_aWorkDetailPlan[l_nRow, 4] = .T.
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_whng2), '', ConvSecToTime(cr_whng3,9,))"
l_aWorkDetailPlan[l_nRow, 2] = l_oWorkTimeHandler.GetCaption("MIDNIGHT 2")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_aWorkDetailPlan[l_nRow, 4] = .T.
l_nRow = aadd(@l_aWorkDetailPlan)
l_aWorkDetailPlan[l_nRow, 1] = "IIF(EMPTY(cr_whng1-cr_whng2-cr_whng3), '', ConvSecToTime(cr_whng1-cr_whng2-cr_whng3,9,))"
l_aWorkDetailPlan[l_nRow, 2] = l_oWorkTimeHandler.GetCaption("EVENING")
l_aWorkDetailPlan[l_nRow, 3] = 70
l_aWorkDetailPlan[l_nRow, 4] = .T.

l_cCaption = TRIM(dlookup("employee","em_emid = " + sqlcnv(lp_nEmployeeID),"em_lname")) + ", " + ;
	PADR(MONTH(lp_dSelectedDate),2)+"/"+PADR(YEAR(lp_dSelectedDate),4)
DO FORM "forms\timeworkhoursdetails.scx" WITH l_cCaption, l_aWorkDetailPlan, lp_nEmployeeID, lp_dSelectedDate
SetStatusLine()
ENDPROC
*
PROCEDURE ChangeWorkHourPeriod
LPARAMETERS lp_lSuccess, lp_dFromDate, lp_nJobNumber
LOCAL ARRAY l_aDialogData(3,11)

l_aDialogData(1,1) = "cbomonth"
l_aDialogData(1,2) = GetLangText("EMPLOYEE","TXT_MONTH")
l_aDialogData(1,3) = SqlCnv(MONTH(EVL(lp_dFromDate, sysdate())))
l_aDialogData(1,4) = "@G"
l_aDialogData(1,5) = 10
l_aDialogData(1,6) = "NOT EMPTY(this.Value)"
l_aDialogData(1,9) = "pamonths"
l_aDialogData(2,1) = "txtyear"
l_aDialogData(2,2) = GetLangText("EMPLOYEE","TXT_YEAR")
l_aDialogData(2,3) = SqlCnv(YEAR(EVL(lp_dFromDate, sysdate())))
l_aDialogData(2,4) = "@S"
l_aDialogData(2,5) = 10
l_aDialogData(2,11) = CREATEOBJECT("Collection")
l_aDialogData(2,11).Add(YEAR(sysdate())-5,"KeyboardLowValue")
l_aDialogData(2,11).Add(YEAR(sysdate())+20,"KeyboardHighValue")
l_aDialogData(2,11).Add(YEAR(sysdate())-5,"SpinnerLowValue")
l_aDialogData(2,11).Add(YEAR(sysdate())+20,"SpinnerHighValue")
l_aDialogData(3,1) = "cboactivity"
l_aDialogData(3,2) = GetLangText("MGRPLIST","TXT_JOB")
l_aDialogData(3,3) = SqlCnv(EVL(lp_nJobNumber,0))
l_aDialogData(3,4) = "@G"
l_aDialogData(3,5) = 20
l_aDialogData(3,9) = "SELECT jb_lang"+g_Langnum+", jb_jbnr FROM Job WHERE NOT jb_deleted ORDER BY jb_lang"+g_Langnum

lp_lSuccess = dialog(GetLangText("EMPLOYEE","TXT_SELECT_PERIOD"), "", @l_aDialogData)
IF lp_lSuccess
	lp_dFromDate = DATE(l_aDialogData(2,8), l_aDialogData(1,8), 1)
	lp_nJobNumber = l_aDialogData(3,8)
ENDIF

RETURN  lp_lSuccess
ENDPROC
*
PROCEDURE ManageWorkHours
LPARAMETERS lp_nWorkHourID, lp_lEditWorkHours, lp_nEmployeeID
* lp_lEditWorkHours = .T. - edit work hours
* lp_lEditWorkHours = .F. - insert new work hours
LOCAL ARRAY l_aDialogData(3,9)
LOCAL l_cWorkHourCursor, l_lSuccess, l_tLowDate, l_tHighDate
l_cWorkHourCursor = SYS(2015)

l_aDialogData(1,1) = "dtxtsysdate"
l_aDialogData(1,2) = GetLangText("EMPLOYEE","TXT_SYSTEM_DATE")
l_aDialogData(1,5) = 16
l_aDialogData(1,6) = "NOT EMPTY(this.Value)"
l_aDialogData(1,8) = l_cWorkHourCursor+".wi_sysdate"
l_aDialogData(2,1) = "dtxtbegin"
l_aDialogData(2,2) = GetLangText("EMPLOYEE","TXT_BEGIN")
l_aDialogData(2,5) = 22
l_aDialogData(2,6) = "NOT EMPTY(this.Value)"
l_aDialogData(2,8) = l_cWorkHourCursor+".wi_begin"
l_aDialogData(3,1) = "dtxtend"
l_aDialogData(3,2) = GetLangText("EMPLOYEE","TXT_END")
l_aDialogData(3,5) = 22
l_aDialogData(3,6) = "EMPTY(this.Value) OR BETWEEN(this.Value - thisform.dtxtbegin.Value, 1, 86399)"
l_aDialogData(3,8) = l_cWorkHourCursor+".wi_end"
IF lp_lEditWorkHours
	SELECT * FROM workint WHERE wi_whid = lp_nWorkHourID INTO CURSOR (l_cWorkHourCursor) READWRITE
ELSE
	SELECT * FROM workint WHERE .F. INTO CURSOR (l_cWorkHourCursor) READWRITE
	APPEND BLANK IN (l_cWorkHourCursor)
ENDIF
l_aDialogData(1,3) = l_cWorkHourCursor+".wi_sysdate"
l_aDialogData(2,3) = l_cWorkHourCursor+".wi_begin"
l_aDialogData(3,3) = l_cWorkHourCursor+".wi_end"

IF dialog(GetLangText("EMPLOYEE","TXT_WORK_HOURS"), "", @l_aDialogData)
	IF lp_lEditWorkHours
		CALCULATE MIN(wb_begin), MAX(wb_end) FOR wb_whid = lp_nWorkHourID TO l_tLowDate, l_tHighDate IN workbrk
		l_lSuccess = EMPTY(l_tLowDate) OR EMPTY(l_tHighDate) OR l_aDialogData(2,8) <= l_tLowDate AND (EMPTY(l_aDialogData(3,8)) OR l_aDialogData(3,8) >= l_tHighDate)
		l_lSuccess = l_lSuccess AND NOT DLookUp("workint", "wi_emid = " + SqlCnv(lp_nEmployeeID) + " AND wi_whid # " + SqlCnv(lp_nWorkHourID) + ;
			" AND wi_end >= " + SqlCnv(l_aDialogData(2,8)) + " AND wi_begin <= " + SqlCnv(l_aDialogData(3,8)), "FOUND()")
	ELSE
		l_lSuccess = NOT DLookUp("workint", "wi_emid = " + SqlCnv(lp_nEmployeeID) + ;
			" AND wi_end >= " + SqlCnv(l_aDialogData(2,8)) + " AND wi_begin <= " + SqlCnv(l_aDialogData(3,8)), "FOUND()")
	ENDIF
	IF l_lSuccess
		IF lp_lEditWorkHours
			=dlocate("workint","wi_whid = "+sqlcnv(lp_nWorkHourID))
		ELSE
			APPEND BLANK IN workint
			REPLACE wi_whid WITH NextId("WORKINT"), ;
					wi_emid WITH lp_nEmployeeID IN workint
		ENDIF
		REPLACE wi_sysdate WITH l_aDialogData(1,8), ;
				wi_begin WITH l_aDialogData(2,8), ;
				wi_end WITH l_aDialogData(3,8) IN workint
	ELSE
		Alert(GetLangText("EMPLOYEE","TXT_WORK_HOURS_OVERLAP"))
	ENDIF
ENDIF
USE IN (l_cWorkHourCursor)
ENDPROC
*
PROCEDURE WorkBreaksBrowse
LPARAMETERS lp_nWorkHourID, lp_oCallingFormRef, lp_dDate
LOCAL ARRAY l_aWorkBreakBrowse(1,3)
LOCAL l_nRow, l_cCaption

l_nRow = 1
l_aWorkBreakBrowse[l_nRow, 1] = "IIF(EMPTY(cr_wbid), '', TTOC(cr_begin))"
l_aWorkBreakBrowse[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_BEGIN")
l_aWorkBreakBrowse[l_nRow, 3] = 150
l_nRow = aadd(@l_aWorkBreakBrowse)
l_aWorkBreakBrowse[l_nRow, 1] = "IIF(EMPTY(cr_wbid), '+'+LEFT(TTOC(cr_end,2),5)+' min.', TTOC(cr_end))"
l_aWorkBreakBrowse[l_nRow, 2] = GetLangText("EMPLOYEE","TXT_END")
l_aWorkBreakBrowse[l_nRow, 3] = 150

l_cCaption = ""
DO FORM "forms\timeworkbreaks" WITH l_cCaption, l_aWorkBreakBrowse, lp_nWorkHourID, lp_oCallingFormRef, lp_dDate
SetStatusLine()
ENDPROC
*
PROCEDURE ManageWorkBreak
LPARAMETERS lp_nWorkBreakID, lp_nWorkHourID, lp_lEditWorkBreak
* lp_lEditWorkBreak = .T. - edit work breaks
* lp_lEditWorkBreak = .F. - insert new work break
LOCAL ARRAY l_aDialogData(2,9)
LOCAL l_cWorkBreakCursor, l_oWorkHourData, l_lSuccess
l_cWorkBreakCursor = SYS(2015)

IF lp_lEditWorkBreak
	SELECT * FROM workbrk WHERE wb_wbid = lp_nWorkBreakID INTO CURSOR &l_cWorkBreakCursor READWRITE
ELSE
	SELECT * FROM workbrk WHERE 0=1 INTO CURSOR &l_cWorkBreakCursor READWRITE
ENDIF

l_aDialogData(1,3) = l_cWorkBreakCursor+".wb_begin"
l_aDialogData(2,3) = l_cWorkBreakCursor+".wb_end"
=dlocate("workint","wi_whid = " + sqlcnv(lp_nWorkHourID))
SELECT workint
SCATTER NAME l_oWorkHourData

l_aDialogData(1,1) = "dtxtbegin"
l_aDialogData(1,2) = GetLangText("EMPLOYEE","TXT_BEGIN")
l_aDialogData(1,5) = 22
l_aDialogData(1,6) = "this.Value >= "+SqlCnv(l_oWorkHourData.wi_begin)+" AND (EMPTY(" + SqlCnv(l_oWorkHourData.wi_end)+") OR this.Value <= " + SqlCnv(l_oWorkHourData.wi_end)+")"
l_aDialogData(1,8) = l_cWorkBreakCursor+".wb_begin"
l_aDialogData(2,1) = "dtxtend"
l_aDialogData(2,2) = GetLangText("EMPLOYEE","TXT_END")
l_aDialogData(2,5) = 22
l_aDialogData(2,6) = "this.Value >= "+SqlCnv(l_oWorkHourData.wi_begin)+" AND (EMPTY(" + SqlCnv(l_oWorkHourData.wi_end)+") OR this.Value <= " + SqlCnv(l_oWorkHourData.wi_end)+") AND this.Value > thisform.dtxtbegin.Value"
l_aDialogData(2,8) = l_cWorkBreakCursor+".wb_end"

IF dialog(GetLangText("EMPLOYEE","TXT_WORK_BREAK"), "", @l_aDialogData)
	IF lp_lEditWorkBreak
		l_lSuccess = NOT DLookup("workbrk", "wb_whid = " + SqlCnv(l_oWorkHourData.wi_whid) + " AND wb_wbid # " + SqlCnv(lp_nWorkBreakID) + ;
			" AND wb_end >= " + SqlCnv(l_aDialogData(1,8)) + " AND wb_begin <= " + SqlCnv(l_aDialogData(2,8)), "FOUND()")
	ELSE
		l_lSuccess = NOT DLookup("workbrk", "wb_whid = " + SqlCnv(l_oWorkHourData.wi_whid) + ;
			" AND wb_end >= " + SqlCnv(l_aDialogData(1,8)) + " AND wb_begin <= " + SqlCnv(l_aDialogData(2,8)), "FOUND()")
	ENDIF
	IF l_lSuccess
		IF lp_lEditWorkBreak
			Dlocate("workbrk","wb_wbid = " + Sqlcnv(lp_nWorkBreakID))
		ELSE
			APPEND BLANK IN workbrk
			REPLACE wb_wbid WITH NextId("WORKBRK"), ;
					wb_whid WITH lp_nWorkHourID IN workbrk
		ENDIF
		REPLACE wb_begin WITH l_aDialogData(1,8), ;
				wb_end WITH l_aDialogData(2,8) IN workbrk
	ELSE
		Alert(GetLangText("EMPLOYEE","TXT_BREAK_OVERLAP"))
	ENDIF
ENDIF
USE IN (l_cWorkBreakCursor)
ENDPROC
*
PROCEDURE WorkHoursHandle
LOCAL l_oWorkPlanRef

IF NOT _screen.AZE
	RETURN .T.
ENDIF

l_oWorkPlanRef = CREATEOBJECT("brilliantworktime")

RETURN l_oWorkPlanRef.WorkHoursHandle()
ENDPROC
*
PROCEDURE WorkPauseHandle
LOCAL l_oWorkPlanRef

IF NOT _screen.AZE
	RETURN .T.
ENDIF

l_oWorkPlanRef = CREATEOBJECT("brilliantworktime")

RETURN l_oWorkPlanRef.WorkPauseHandle()
ENDPROC
*
PROCEDURE NaProcAZE
NaLogoutShift()
NaDefaultWorkPause()
ENDPROC
*
PROCEDURE NaLogoutShift
LOCAL l_oEnvironment, l_oWorkPlanRef, l_curBreaks, l_dEnd, l_nWbMin, l_nWiMax

IF _screen.AZE AND _screen.oGlobal.oParam2.pa_wimax > 0
	l_oEnvironment = SetEnvironment("workint, workbrk")
	l_dEnd = DATETIME()
	l_nWiMax = _screen.oGlobal.oParam2.pa_wimax
	l_oWorkPlanRef = CREATEOBJECT("brilliantworktime")

	SELECT workint
	SCAN FOR EMPTY(wi_end) AND wi_begin < l_dEnd - 3600*l_nWiMax
		* Check Work Interval
		REPLACE wi_end WITH wi_begin+3600*l_nWiMax
		IF DLocate('workbrk','wb_whid = ' + SqlCnv(wi_whid) + ' AND EMPTY(wb_end)')
			l_nWbMin = l_oWorkPlanRef.GetDefaultWorkBreak(@l_curBreaks,,wi_begin, wi_end, .T.)
			REPLACE wb_end WITH MAX(workint.wi_end, workbrk.wb_begin+60*l_nWbMin) IN workbrk
		ENDIF
	ENDSCAN
	DClose(l_curBreaks)
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE NaDefaultWorkPause
LOCAL l_oEnvironment, l_dSysDate

IF _screen.AZE AND _screen.oGlobal.oParam2.pa_wbmin > 0 OR _screen.oGlobal.oParam2.pa_wbmin1 > 0 OR _screen.oGlobal.oParam2.pa_wbmin2 > 0 OR _screen.oGlobal.oParam2.pa_wbmin3 > 0
	l_oEnvironment = SetEnvironment("workbrkd")
	l_dSysDate = SysDate()
	IF NOT DLocate("workbrkd", "wd_date = " + SqlCnv(l_dSysDate,.T.))
		SqlInsert("workbrkd", "wd_wdid, wd_date, wd_min, wd_cwhour0, wd_cwhour1, wd_wbmin1, wd_cwhour2, wd_wbmin2, wd_cwhour3, wd_wbmin3", 1, StrToSql("%n1, %d2, %n3, %n4, %n5, %n6, %n7, %n8, %n9, %n10", ;
			NextId("WORKBRKD"), l_dSysDate, _screen.oGlobal.oParam2.pa_wbmin, _screen.oGlobal.oParam2.pa_cwhour0, _screen.oGlobal.oParam2.pa_cwhour1, _screen.oGlobal.oParam2.pa_wbmin1, ;
			_screen.oGlobal.oParam2.pa_cwhour2, _screen.oGlobal.oParam2.pa_wbmin2, _screen.oGlobal.oParam2.pa_cwhour3, _screen.oGlobal.oParam2.pa_wbmin3))
	ENDIF
ENDIF

RETURN .T.
ENDPROC
*