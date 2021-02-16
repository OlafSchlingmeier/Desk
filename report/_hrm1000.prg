PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.02"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hrm1000
LPARAMETERS tcType, tlNoRev
LOCAL loSession
LOCAL ARRAY laPreProc(1)

WAIT WINDOW NOWAIT "Preprocessing..."

DO PpCursorCreate IN _hr01000

SqlCursor("SELECT * FROM hotel WHERE NOT ho_mainsrv ORDER BY ho_hotcode", "curHotel")
SELECT curHotel
SCAN
     WAIT WINDOW NOWAIT "Preprocessing... " + curHotel.ho_hotcode
     DIMENSION laPreProc(1)
     loSession = NEWOBJECT("_hr01000", "_hr01000.prg", "", curHotel.ho_hotcode, curHotel.ho_path)
     loSession.DoPreproc(tcType, tlNoRev, @laPreProc)
     RELEASE loSession

     IF ALEN(laPreProc) > 1
          INSERT INTO PreProc FROM ARRAY laPreProc
     ENDIF
ENDSCAN

DO PpCursorGroup IN _hr01000

DClose("curHotel")

WAIT CLEAR
ENDPROC
*