*
FUNCTION QASRapid
 LPARAMETERS pcStreet1, pcStreet2, pcPostcode, pcTown, pcCounty
 DECLARE LONG QARapidUI_Startup IN '.\QAS\qaruiea.dll' STRING, STRING,  ;
         STRING, LONG
 DECLARE LONG QARapidUI_Shutdown IN '.\QAS\qaruiea.dll' LONG
 DECLARE LONG QARapidUI_Popup IN '.\QAS\qaruiea.dll' STRING, STRING @, LONG
 DECLARE LONG QARapidUI_DPPopup IN '.\QAS\qaruiea.dll' STRING, STRING @,  ;
         LONG, STRING @
 LOCAL nrEtstartup, nrEtpopup, nrEtshutdown, cbUff, neNd, cmSg
 nrEtstartup = qaRapidui_startup('QuickAddress Rapid & Brilliant','.\QAS\QAS.INI','',0)
 IF nrEtstartup<0
      DO CASE
           CASE nrEtstartup=-1001
                cmSg = "NO MEMORY"
           CASE nrEtstartup=-1028
                cmSg = "INVALID PATH"
           CASE nrEtstartup=-1031
                cmSg = "INVALID INIFILE"
           CASE nrEtstartup=-9800
                cmSg = "NO DATABASE"
           OTHERWISE
                cmSg = "UNKNOWN"
      ENDCASE
      = alErt("Can't start QuickAddress Rapid: (QAS_ERROR="+cmSg+")")
      RETURN .T.
 ENDIF
 cbUff = SPACE(255)
 nrEtpopup = qaRapidui_popup('',@cbUff,LEN(cbUff))
 cbUff = SUBSTR(cbUff, 1, AT(CHR(0), cbUff)-1)
 nrEtshutdown = qaRapidui_shutdown(0)
 IF nrEtpopup=0
      RETURN .T.
 ENDIF
 neNd = AT(CHR(10), cbUff)
 pcStreet1 = SUBSTR(cbUff, 1, neNd-1)
 cbUff = SUBSTR(cbUff, neNd+1)
 neNd = AT(CHR(10), cbUff)
 pcStreet2 = SUBSTR(cbUff, 1, neNd-1)
 cbUff = SUBSTR(cbUff, neNd+1)
 neNd = AT(CHR(10), cbUff)
 pcTown = SUBSTR(cbUff, 1, neNd-1)
 cbUff = SUBSTR(cbUff, neNd+1)
 neNd = AT(CHR(10), cbUff)
 pcCounty = SUBSTR(cbUff, 1, neNd-1)
 cbUff = SUBSTR(cbUff, neNd+1)
 neNd = AT(CHR(10), cbUff)
 pcPostcode = SUBSTR(cbUff, 1, neNd-1)
 cbUff = SUBSTR(cbUff, neNd+1)
 SHOW GETS
 RETURN .T.
ENDFUNC
*
