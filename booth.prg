*
FUNCTION Booth
 LOCAL nArea
 WAIT WINDOW NOWAIT GetLangText("BOOTH","TXT_READING_INTERFACES")
 DO BoothRead IN Interfac
 WAIT CLEAR
     SELECT post
     LOCATE FOR ps_reserid <= -10
     IF FOUND()
         doform("PhoneBooth","Forms\PhoneCalls")
     ELSE
         = alErt(GetLangText("BOOTH","TXT_NO_PHONE_BOOTH_RECORDS"))
     ENDIF
 SELECT (naRea)
 RETURN .T.
ENDFUNC
*
FUNCTION BoothNum
 LPARAMETERS lp_nReserid, lp_nExtens
 lp_nExtens = ABS(lp_nReserid)
 IF BETWEEN(lp_nExtens, 10001, 10009)
     lp_nExtens = lp_nExtens - 10000
 ENDIF
 RETURN lp_nExtens
ENDFUNC
*