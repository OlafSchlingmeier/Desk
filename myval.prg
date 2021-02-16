*
FUNCTION MyVal
 LPARAMETERS pcStr
 LOCAL nDecimals
 DO CASE
      CASE ','$pcStr
           nDecimals = LEN(pcStr) - AT(',',pcStr)
           IF SET('point')=','
                RETURN ROUND(VAL(pcStr),nDecimals)
           ELSE
                RETURN ROUND(VAL(STRTRAN(pcStr, ',', '.')), nDecimals)
           ENDIF
      CASE '.'$pcStr
           nDecimals = LEN(pcStr) - AT('.',pcStr)
           IF SET('point')=','
                RETURN ROUND(VAL(STRTRAN(pcStr, '.', ',')), nDecimals)
           ELSE
                RETURN ROUND(VAL(pcStr), nDecimals)
           ENDIF
      OTHERWISE
           RETURN ROUND(VAL(pcStr),0)
 ENDCASE
ENDFUNC
*
