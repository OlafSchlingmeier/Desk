&& FUNCTION FileOpWithProgressbar
&& The SHFileOperation.h is posted at the bottom of the page
#INCLUDE include\SHFileOperation.h
 
LPARAMETERS tcSource, tcDestination, tcAction, tlUserCanceled
LOCAL lcSourceString, lcDestString, nStringBase, lcFileOpStruct, lnFlag, lnStringBase
LOCAL loHeap, lcAction, lnRetCode, llCanceled, laActionList[1]
 
DECLARE INTEGER SHFileOperation IN SHELL32.DLL STRING @ LPSHFILEOPSTRUCT
&& Heap allocation class
If AT("CLSHEAP", SET("PROCEDURE")) = 0  
    SET PROCEDURE TO CLSHEAP ADDITIVE
EndIf
loHeap = CREATEOBJ('Heap')
 
lcAction = UPPER(IIF( Empty( tcAction) Or VarType(tcAction) <> "C", "COPY", tcAction))
&& Convert Action name into function parameter
ALINES(laActionList, "MOVE,COPY,DELETE,RENAME", ",")
lnAction = ASCAN(laActionList, lcAction)
IF lnAction = 0
     && Unknown action
     RETURN Null
ENDIF
 
lcSourceString = tcSource + CHR(0) + CHR(0)
lcDestString   = tcDestination + CHR(0) + CHR(0)
lnStringBase   = loHeap.AllocBlob(lcSourceString+lcDestString)
 
lnFlag = FOF_NOCONFIRMATION + FOF_NOCONFIRMMKDIR + FOF_NOERRORUI
 
lcFileOpStruct  = NumToLONG(_screen.hWnd) + ;
                NumToLONG(lnAction) + ;
                NumToLONG(lnStringBase) + ;
                NumToLONG(lnStringBase + LEN(lcSourceString)) + ;
                NumToWORD(lnFlag) + ;
                NumToLONG(0) + NumToLONG(0) + NumToLONG(0)
 
lnRetCode = SHFileOperation(@lcFileOpStruct) 
 
&& Did user canceled operation?
tlUserCanceled= ( SUBSTR(lcFileOpStruct, 19, 4) <> NumToLONG(0) )
 
RETURN (lnRetCode = 0)