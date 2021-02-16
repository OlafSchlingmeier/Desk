#INCLUDE "include\constdefines.h"
*
PROCEDURE TrainingVersion
LOCAL l_nSelect, i, l_cFile

IF glTraining
     alert(GetLangText("KEYCARD1","TXT_BLOCKED"))
     RETURN .T.
ENDIF

IF YesNo(GetLangText("TRAINING","MNT_TRAINING_ASK"))
	WAIT GetLangText("TRAINING","MNT_CREATING_TRAINING") WINDOW NOWAIT
	*RUN XCOPY *.* ..\Training\ /E /Y /C
     IF NOT DIRECTORY(APP_TRAINING_FOLDER)
          MKDIR APP_TRAINING_FOLDER
     ENDIF
     l_nSelect = SELECT()
     FOR i = 1 TO ADIR(adbf, gcDatadir + '\*.DBF')
          l_cFile = UPPER(JUSTSTEM(adbf(i,1)))
          WAIT WINDOW NOWAIT l_cFile + '...'
          USE SHARED (gcDatadir + l_cFile) AGAIN ALIAS src IN 0
          SELECT src
          
          IF INLIST(l_cFile, "HBANQUET","HBILLINS","HDEPOSIT","HISTORS","HISTPOST","HISTRES",;
                    "HISTSTAT","HOUTOFOR","HOUTOFSR","HPOSTCNG","HRESADDR","HRESCARD","HRESEXT",;
                    "HRESFIX","HRESRATE","HRESROOM","HSHEET","IFCLOST","ERRORLOG")
          
               COPY TO (APP_TRAINING_FOLDER + '\' + l_cFile) STRUCTURE WITH CDX
          ELSE
               COPY TO (APP_TRAINING_FOLDER + '\' + l_cFile) WITH CDX ALL
          ENDIF
          USE IN src
          IF l_cFile == "PARAM"
               * turn off interfaces
               USE (APP_TRAINING_FOLDER + '\' + l_cFile) SHARED IN 0 AGAIN ALIAS trnparam
               REPLACE pa_fiscprt WITH "", ;
                         PA_PTVIFC WITH .F., ;
                         PA_PTTIFC WITH .F., ;
                         PA_POSIFC WITH .F., ;
                         PA_WAKEUP WITH .F., ;
                         PA_KEYIFC WITH .F. ;
                         IN trnparam
               FLUSH
               dclose("trnparam")
          ENDIF
          IF l_cFile == "PARAM2"
               * turn off interfaces
               USE (APP_TRAINING_FOLDER + '\' + l_cFile) SHARED IN 0 AGAIN ALIAS trnparam2
               REPLACE pa_tempcon WITH .F. ;
                         IN trnparam2
               FLUSH
               dclose("trnparam2")
          ENDIF
     ENDFOR
     SELECT (l_nSelect)
     
	WAIT CLEAR
     alert(GetLangText("AUDIT","TXT_DONE"))
ENDIF
ENDPROC
*
