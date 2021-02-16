PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "3.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _fcm5000
LPARAMETERS tlWithoutVat, tcType, tcResFilter, tcAvailFilter
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

DO PpCursorCreate IN _fc05000

SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
SELECT curHotel
SCAN
     WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
     DIMENSION laPreProc(1)
     loSession = NEWOBJECT("_fc05000", "_fc05000.prg", "", curHotel.ho_hotcode, curHotel.ho_path)
     loSession.DoPreproc(tlWithoutVat, tcType, tcResFilter, tcAvailFilter, @laPreProc)
     RELEASE loSession

     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
     ENDIF
ENDSCAN

DO PpCursorGroup IN _fc05000

DClose("curHotel")

WAIT CLEAR
ENDPROC
*