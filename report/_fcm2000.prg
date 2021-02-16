PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "2.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _fcm2000
LPARAMETERS tlWithoutVat, tcResFilter
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

DO PpCursorCreate IN _fc02000

SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
SELECT curHotel
SCAN
     WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
     DIMENSION laPreProc(1)
     loSession = NEWOBJECT("_fc02000", "_fc02000.prg", "", curHotel.ho_hotcode, curHotel.ho_path)
     loSession.DoPreproc(tlWithoutVat, tcResFilter, @laPreProc)
     RELEASE loSession

     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
          REPLACE ho_hotcode WITH curHotel.ho_hotcode, ho_descrip WITH curHotel.ho_descrip FOR EMPTY(ho_hotcode) IN PreProc
     ENDIF
ENDSCAN

DO PpCursorGroup IN _fc02000

DClose("curHotel")

WAIT CLEAR
ENDPROC
*