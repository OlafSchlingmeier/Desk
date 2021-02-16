*
FUNCTION AlwCLedg
 PARAMETER pnId, plStrict, plGuest
 PRIVATE crEt, naRea, laCused

 IF NOT USED('param')
 	RETURN
 ENDIF
 IF  .NOT. _screen.dv
      RETURN ''
 ENDIF

 naRea = SELECT()

 laCused = USED('ArAcct')
 IF  .NOT. laCused
      IF  .NOT. doPen('ArAcct')
           = alErt("Can't open ARACCT.DBF!")
           RETURN ''
      ENDIF
 ENDIF
 crEt = ''
 IF pnId>0 .AND. dlOcate('ArAcct','ac_addrid = '+sqLcnv(pnId)+' AND NOT ac_inactiv')
      DO CASE
           CASE arAcct.ac_status=1
                crEt = ''
           CASE arAcct.ac_status=2 AND NOT plGuest
                = alErt(stRfmt(GetLangText("ALWCLEDG","T_ARSTATUS"), ;
                  GetLangText("ALWCLEDG","T_CASHONLY")))
                crEt = GetLangText("ALWCLEDG","T_CASHONLY")
           CASE arAcct.ac_status=3
                = alErt(stRfmt(GetLangText("ALWCLEDG",IIF(plGuest, "T_ARSTATUSG", "T_ARSTATUS")), ;
                  GetLangText("ALWCLEDG","T_BLACKLIST")))
                crEt = GetLangText("ALWCLEDG","T_BLACKLIST")
      ENDCASE
 ELSE
      IF plStrict
           = alErt(stRfmt(GetLangText("ALWCLEDG","T_ARSTATUS"),GetLangText("ALWCLEDG", ;
             "T_NOACCOUNT")))
           crEt = GetLangText("ALWCLEDG","T_NOACCOUNT")
      ENDIF
 ENDIF
 IF  .NOT. laCused
      = dcLose('ArAcct')
 ENDIF

 SELECT (naRea)

 RETURN crEt
ENDFUNC
*