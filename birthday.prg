*
PROCEDURE Birthday
 LOCAL coLdbell
 IF FILE('BirthDay.WAV')
      IF MONTH(adDress.ad_birth)=MONTH(sySdate()) .AND.  ;
         DAY(adDress.ad_birth)=DAY(sySdate())
           coLdbell = SET('bell')
           SET BELL TO ('BirthDay.WAV'), 10
           ?? CHR(7)
           SET BELL TO
           set bell &cOldBell
      ENDIF
 ENDIF
ENDPROC
*
