**
** winexecute.fxp
**
*
PROCEDURE WinExecute
 LPARAMETERS pcFile, pnShowmode
 LOCAL nrEt, csYsdir, crUn, cpArameters
 IF PARAMETERS()<2
      pnShowmode = 1
 ENDIF
 DECLARE INTEGER GetDesktopWindow IN user32.dll
 DECLARE INTEGER GetSystemDirectory IN kernel32.dll STRING @, INTEGER
 DECLARE INTEGER ShellExecute IN shell32.dll INTEGER, STRING @, STRING @,  ;
         STRING @, STRING @, INTEGER
 nrEt = shEllexecute(geTdesktopwindow(),'open',@pcFile,'','',pnShowmode)
 IF nrEt=31
      csYsdir = SPACE(260)
      nrEt = geTsystemdirectory(@csYsdir,LEN(csYsdir))
      csYsdir = SUBSTR(csYsdir, 1, nrEt)
      crUn = 'RUNDLL32.EXE'
      cpArameters = 'shell32.dll,OpenAs_RunDLL '
      nrEt = shEllexecute(geTdesktopwindow(),'open',crUn,cpArameters+ ;
             pcFile,csYsdir,pnShowmode)
 ENDIF
ENDPROC
*
