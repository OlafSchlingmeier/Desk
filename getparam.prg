*
FUNCTION GetParam
 PARAMETER cgRoup, cvAriable, ciNiname, cdEfault
 PRIVATE ccOntents
 PRIVATE neQualsstart
 PRIVATE nhAndle
 PRIVATE clIne
 PRIVATE nvArstart
 PRIVATE npArameters
 npArameters = PARAMETERS()
 IF (npArameters<3)
      ciNiname = "Hotel.Ini"
 ENDIF
 IF (npArameters<4)
      cdEfault = ""
 ENDIF
 ccOntents = ""
 IF ( .NOT. FILE(ciNiname))
      nhAndle = FCREATE(ciNiname)
 ELSE
      nhAndle = FOPEN(ciNiname, 2)
 ENDIF
 IF (nhAndle<>-1)
      DO WHILE ( .NOT. FEOF(nhAndle))
           clIne = FGETS(nhAndle)
           IF (AT("["+UPPER(cgRoup)+"]", UPPER(clIne))>0)
                DO WHILE ( .NOT. FEOF(nhAndle))
                     clIne = FGETS(nhAndle)
                     IF (SUBSTR(ALLTRIM(clIne), 1, 1)=="[")
                          EXIT
                     ENDIF
                     nvArstart = AT(UPPER(cvAriable), UPPER(clIne))
                     IF (nvArstart>0)
                          neQualsstart = AT("=", clIne)
                          IF (neQualsstart>nvArstart)
                               ccOntents = ALLTRIM(SUBSTR(clIne,  ;
                                neQualsstart+1))
                               EXIT
                          ENDIF
                     ENDIF
                ENDDO
           ENDIF
      ENDDO
      = FCLOSE(nhAndle)
 ENDIF
 RETURN ccOntents
ENDFUNC
*
