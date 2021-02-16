LOCAL LProceed
LOCAL ARRAY aserverversion(15), alocalversion(15)
LProceed = .t.
CLEAR
CLOSE all
IF !FILE('myapp.ini')
	MESSAGEBOX('Missing file MYAPP.INI !'+CHR(13)+"Automatic check for update on Server is not possible!",48,'Alert')
	RETURN .f.
endif
_screen.Visible=.f.
CREATE CURSOR ctmpcur (c1 c(100))
APPEND FROM myapp.ini DELIMITED WITH tab
GOTO TOP
cserverexepath=ALLTRIM(ctmpcur.c1)
clocalexepath=FULLPATH(justfname(cserverexepath))
cmypathinipath=JUSTPATH(cserverexepath)+'\mypath.ini'
AGETFILEVERSION(aserverversion,cserverexepath)
AGETFILEVERSION(alocalversion,clocalexepath)
IF EMPTY(aserverversion(4))
	MESSAGEBOX(cserverexepath+" not found!" +CHR(13)+"Check file name, and path!",16,"Build update aborted!")
	LProceed = .F.
ENDIF
IF LProceed
	IF EMPTY(alocalversion(4))
		MESSAGEBOX(clocalexepath+" not found!" +CHR(13)+"Check file name, and path!",16,"Build update aborted!")
		LProceed = .F.
	ENDIF
	IF LProceed
		IF aserverversion(4)<>alocalversion(4)
			IF 6=MESSAGEBOX("Local exe version "+alocalversion(4)+CHR(13)+;
							"New server exe version "+aserverversion(4)+CHR(13)+;
							"Do You want update?",36,"Question")
				SET SAFETY off
				CREATE CURSOR ctmp (cpath c(100))
				APPEND BLANK IN ctmp
				replace cpath WITH clocalexepath IN ctmp
				SELECT ctmp
				COPY TO mypath.ini DELIMITED WITH tab
				cserverpath=JUSTPATH(cmypathinipath)+'\myupdate.exe '+cserverexepath
				run /n &cserverpath
				QUIT
			endif
		endif
	ENDIF
ENDIF
_screen.Visible=.t.
RETURN LProceed
