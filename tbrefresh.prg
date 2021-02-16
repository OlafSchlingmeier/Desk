*
PROCEDURE TbRefresh
LPARAMETERS pcalias
IF USED(pcalias)
     GOTO RECNO(pcalias) IN (pcalias)
ENDIF
ENDPROC
*
