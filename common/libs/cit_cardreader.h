*---- Key type Values ----
#DEFINE KEY_A	0x60	&& 96
#DEFINE KEY_B	0x61	&& 97

*---- MF_CLASS Values ----
#DEFINE MF_ULTRALIGHT	0x4400	&& 17408
#DEFINE MF_1K			0x0400	&& 1024
#DEFINE MF_4K			0x0200	&& 512
#DEFINE MF_PROX			0x0407	&& 1031
#DEFINE MF_DESFire		0x4403	&& 17411

*---- MF_CARDEVENT Values ----
#DEFINE MF_CARD_PRESENT		1
#DEFINE MF_CARD_REMOVE		0

*---- MF_OPT Values ----
#DEFINE MF_INC		0xC1	&& 193
#DEFINE MF_DEC		0xC0	&& 192

*---- Module start sector ----
#DEFINE RES_START	0
#DEFINE BMS_START	4

*---- Cryptor key Value ----
#DEFINE CR_CSRV_KEY			"6A3839626324236B6B6439214F6F6231"

*---- String constants ----
#DEFINE CRLF				CHR(13)+CHR(10)

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
#DEFINE MB_DEFBUTTON2	  256	&& Second button is default
#DEFINE MB_DEFBUTTON3	  512	&& Third button is default
#DEFINE MB_SYSTEMMODAL	 4096	&& System Modal

*-- MsgBox return values
#DEFINE IDOK				1	&& OK button pressed
#DEFINE IDCANCEL			2	&& Cancel button pressed
#DEFINE IDABORT				3	&& Abort button pressed
#DEFINE IDRETRY				4	&& Retry button pressed
#DEFINE IDIGNORE			5	&& Ignore button pressed
#DEFINE IDYES				6	&& Yes button pressed
#DEFINE IDNO				7	&& No button pressed