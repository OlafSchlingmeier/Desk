PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "2.10"
RETURN tcVersion
ENDPROC
*
PROCEDURE _az00100
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

loSession = CREATEOBJECT("_az00100")
loSession.DoPreproc(@laPreProc)
RELEASE loSession

WAIT CLEAR

PpCursorCreate()
IF ALEN(laPreProc) > 1
     INSERT INTO PreProc FROM ARRAY laPreProc
ENDIF
ENDPROC
**********
DEFINE CLASS _az00100 AS HotelSession OF ProcMultiProper.prg

PROCEDURE Init
     LPARAMETERS tcHotCode, tcPath
     DODEFAULT("timetype,asgempl,azepick,workint,workbrk,workbrkd,employee,param2", tcHotCode, tcPath)
     PpCursorCreate()
ENDPROC

PROCEDURE DoPreproc
     LPARAMETERS taPreProc

     PpDo()

     IF USED("PreProc") AND RECCOUNT("PreProc") > 0
          SELECT * FROM PreProc INTO ARRAY taPreProc
     ENDIF
ENDPROC

ENDDEFINE
**********
PROCEDURE PpCursorCreate
LOCAL loWorkTimeFunc

loWorkTimeFunc = CREATEOBJECT("BrilliantWorkTime")
loWorkTimeFunc.CreateWorkHoursBreaksDetailsCursor("PreProc")
ENDPROC
*
PROCEDURE PpDo
LOCAL loWorkTimeFunc
PUBLIC croundcolumncaption_az00100, cnightcolumncaption_az00100, cmidnightcolumncaption_az00100, cmidnightcolumncaption2_az00100, ceveningcolumncaption_az00100

loWorkTimeFunc = CREATEOBJECT("BrilliantWorkTime")
croundcolumncaption_az00100 = loWorkTimeFunc.GetRoundedHoursCaption()
cnightcolumncaption_az00100 = loWorkTimeFunc.GetCaption("NIGHT")
cmidnightcolumncaption_az00100 = loWorkTimeFunc.GetCaption("MIDNIGHT 1")
cmidnightcolumncaption2_az00100 = loWorkTimeFunc.GetCaption("MIDNIGHT 2")
ceveningcolumncaption_az00100 = loWorkTimeFunc.GetCaption("EVENING")
loWorkTimeFunc.GetWorkHoursBreaksDetailsData(DATE(min3, min2, 1), min1, min4, "PreProc")
ENDPROC
*
PROCEDURE PostProc
RELEASE croundcolumncaption_az00100, cnightcolumncaption_az00100, cmidnightcolumncaption_az00100, cmidnightcolumncaption2_az00100, ceveningcolumncaption_az00100
ENDPROC
*