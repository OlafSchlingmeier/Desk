*---- Editing mode Values ----

#DEFINE EDIT_MODE			1
#DEFINE NEW_MODE			2
#DEFINE COPY_MODE			3
#DEFINE PREVIEW_MODE		4
#DEFINE PASS_MODE			5
#DEFINE EDIT_GROUP_MODE		6
#DEFINE DELETE_MODE			7
#DEFINE CANCEL_MODE			8
#DEFINE DELETE_NOSET_MODE	9

*---- Messagebox subset from FOXPRO.H ----

#DEFINE MB_OK				0	&& OK button only
#DEFINE MB_OKCANCEL			1	&& OK and Cancel buttons
#DEFINE MB_ABORTRETRYIGNORE	2	&& Abort, Retry, and Ignore buttons
#DEFINE MB_YESNOCANCEL		3	&& Yes, No, and Cancel buttons
#DEFINE MB_YESNO			4	&& Yes and No buttons
#DEFINE MB_RETRYCANCEL		5	&& Retry and Cancel buttons

#DEFINE MB_ICONSTOP			16	&& Critical message
#DEFINE MB_ICONQUESTION		32	&& Warning query
#DEFINE MB_ICONEXCLAMATION	48	&& Warning message
#DEFINE MB_ICONINFORMATION	64	&& Information message

#DEFINE MB_APPLMODAL		0	&& Application modal message box
#DEFINE MB_DEFBUTTON1		0	&& First button is default
#DEFINE MB_DEFBUTTON2		256	&& Second button is default
#DEFINE MB_DEFBUTTON3		512	&& Third button is default
#DEFINE MB_SYSTEMMODAL		4096	&& System Modal

*-- MsgBox return values
#DEFINE IDOK				1	&& OK button pressed
#DEFINE IDCANCEL			2	&& Cancel button pressed
#DEFINE IDABORT			3	&& Abort button pressed
#DEFINE IDRETRY			4	&& Retry button pressed
#DEFINE IDIGNORE			5	&& Ignore button pressed
#DEFINE IDYES				6	&& Yes button pressed
#DEFINE IDNO				7	&& No button pressed

*---- Toolbar mode Values ----

#DEFINE TLB_INVISIBLE			0
#DEFINE TLB_VISIBLE				1
#DEFINE TLB_DISABLE				2
#DEFINE TLB_ENABLE				3

*---- Process ID Values ----

#DEFINE P_COLUMNS				1

*---- Color Values ----

#DEFINE COLOR_WHITE					RGB(255,255,255)
#DEFINE COLOR_BLACK					RGB(0,0,0)
#DEFINE COLOR_WEEKEND				RGB(255,1,1)

*---- Scroll Directions ----
*same as fox's directions

#DEFINE SCROLL_UP			0
#DEFINE SCROLL_DOWN			1
#DEFINE SCROLL_PAGE_UP		2
#DEFINE SCROLL_PAGE_DOWN	3
#DEFINE SCROLL_LEFT			4
#DEFINE SCROLL_RIGHT		5

*---- Dialogue types ----

#DEFINE MONOLOG		1
#DEFINE DIALOG		2

*---- String constants
#DEFINE CRLF		CHR(13)+CHR(10)

*---- Bind Event ----

#define WINDOW_MENU		"Window menu"

*---- Windows Messages ----

#DEFINE WM_ACTIVATE				0x0006
#DEFINE WM_ENTERMENULOOP		0x0211
#DEFINE GWL_WNDPROC				-4

*--WM_ACTIVATE state values--
#define WA_ACTIVE				1