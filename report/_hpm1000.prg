PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.10"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hpm1000
PARAMETER tcLiart, tlWithoutVat
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

DO PpCursorCreate IN _hp10000

SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
SELECT curHotel
SCAN
     WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
     DIMENSION laPreProc(1)
     loSession = NEWOBJECT("_hp10000", "_hp10000.prg", "", curHotel.ho_hotcode, curHotel.ho_path)
     loSession.DoPreproc(tcLiart, tlWithoutVat, @laPreProc)
     RELEASE loSession

     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
     ENDIF
ENDSCAN

DO PpCursorGroup IN _hp10000

DClose("curHotel")

WAIT CLEAR
ENDPROC
*