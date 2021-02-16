 PARAMETER pcAlias, pcFile, plHeader
 PRIVATE naRea, nrEcno, nhAndle, i, nmAxfld, afLd, lrEt
 lrEt = .F.
 naRea = SELECT()
 nrEcno = RECNO()
 SELECT (pcAlias)
 GOTO TOP
 nhAndle = FCREATE(pcFile)
 IF nhAndle==-1
      WAIT WINDOW "Error creating CSV file ("+LTRIM(STR(FERROR()))+")"
 ELSE
      nmAxfld = FCOUNT()
      DIMENSION afLd(nmAxfld, 4)
      = AFIELDS(afLd)
      IF plHeader
           FOR i = 1 TO nmAxfld
                = FWRITE(nhAndle, afLd(i,1)+IIF(i=nmAxfld, "", ","))
           ENDFOR
           = FWRITE(nhAndle, CHR(13)+CHR(10))
      ENDIF
      SCAN
           FOR i = 1 TO nmAxfld
                = FWRITE(nhAndle, toStr(i,@afLd)+IIF(i=nmAxfld, "", ","))
           ENDFOR
           = FWRITE(nhAndle, CHR(13)+CHR(10))
      ENDSCAN
      = FCLOSE(nhAndle)
      lrEt = .T.
 ENDIF
 SELECT (naRea)
 GOTO nrEcno
 RETURN lrEt
ENDFUNC
*
FUNCTION ToStr
 PARAMETER pnIndex, paFld
 PRIVATE xvAl, crEt, cfLd, ctYpe, cpOint
 LOCAL l_nArea
 EXTERNAL ARRAY paFld
 cfLd = paFld(i,1)
 xvAl = EVALUATE(cfLd)
 ctYpe = paFld(i,2)
 DO CASE
      CASE ctYpe="N"
           l_nArea = SELECT()
           cpOint = SET('point')
           SET POINT TO
           crEt = LTRIM(STR(xvAl, paFld(i,3), paFld(i,4)))
           set point to &cPoint
           SELECT(l_nArea)
      CASE ctYpe="C"
           xvAl = ALLTRIM(xvAl)
           xvAl = STRTRAN(xvAl, '"', ['])
           IF EMPTY(xvAl)
                crEt = ""
           ELSE
                crEt = '"'+xvAl+'"'
           ENDIF
      CASE ctYpe="M"
           IF NOT _screen.oglobal.oparam2.pa_encrinw
                xvAl = STRTRAN(ALLTRIM(xvAl), CHR(13)+CHR(10), "")
           ENDIF
           xvAl = STRTRAN(xvAl, '"', ['])
           IF EMPTY(xvAl)
                crEt = ""
           ELSE
                crEt = '"'+xvAl+'"'
           ENDIF
      CASE ctYpe="D"
           IF EMPTY(xvAl)
                crEt = ""
           ELSE
                crEt = '"'+DTOC(xvAl)+'"'
           ENDIF
      CASE ctYpe="L"
           crEt = '"'+IIF(xvAl, "Y", "N")+'"'
      OTHERWISE
           crEt = ""
 ENDCASE
 RETURN crEt
ENDFUNC
*
