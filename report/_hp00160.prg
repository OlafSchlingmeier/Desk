PROCEDURE PpVersion
LPARAMETERS tcVersion

tcVersion = "1.00"
RETURN tcVersion
ENDPROC
*
PROCEDURE _hp00160
WAIT WINDOW NOWAIT "Preprocessing...   0%"

DoPreproc()

WAIT CLEAR
ENDPROC
*
PROCEDURE DoPreproc
LOCAL lcHistPostTemp, ldDate, loResCurrent, loResNext, lcRoomtype, ldLowDate, ldHighDate, lnCount, lnCurrent

openfiledirect(.F., "roomtype")
openfiledirect(.F., "hresrooms")
openfiledirect(.F., "histpost")
openfiledirect(.F., "histres")

SELECT * FROM histpost WHERE .F. INTO CURSOR Preproc READWRITE
SELECT DISTINCT ri_reserid FROM hresroom INNER JOIN roomtype ON rt_roomtyp = ri_roomtyp WHERE rt_buildng = min2 AND ri_reserid IN (;
     SELECT hp_origid FROM histpost WHERE hp_origid > 1 AND BETWEEN(hp_date, min1, max1) AND NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split)) ;
     INTO CURSOR curHistres

SELECT curHistres
lnCount = RECCOUNT()
lnCurrent = 0
SCAN FOR SEEK(ri_reserid, "histres", "tag1")
     IF ROUND(100*RECNO()/lnCount, 0) > lnCurrent
          lnCurrent = ROUND(100*RECNO()/lnCount, 0)
          WAIT "Preprocessing... "+PADL(lnCurrent,3)+"%" WINDOW NOWAIT
     ENDIF
     ldDate = MAX(min1, histres.hr_arrdate)
     DO WHILE ldDate <= MIN(max1, histres.hr_depdate)
          RiGetRoom(histres.hr_reserid, ldDate, @loResCurrent, @loResNext, "hresroom")
          DO CASE
               CASE ISNULL(loResCurrent) OR ISNULL(loResNext)
                    ldLowDate = MAX(min1, histres.hr_arrdate)
                    ldHighDate = MIN(max1, histres.hr_depdate)
               CASE loResCurrent.ri_rroomid = loResNext.ri_rroomid
                    ldLowDate = MAX(min1, loResCurrent.ri_date)
                    ldHighDate = MIN(max1, histres.hr_depdate)
               OTHERWISE
                    ldLowDate = MAX(min1, loResCurrent.ri_date)
                    ldHighDate = MIN(max1, loResNext.ri_date-1)
          ENDCASE
          lcRoomtype = IIF(ISNULL(loResCurrent), histres.hr_roomtype, loResCurrent.ri_roomtyp)
          IF DLookup("roomtype", "rt_roomtyp = " + SqlCnv(lcRoomtype), "rt_buildng = " + SqlCnv(PADR(min2,3)))
               INSERT INTO Preproc ;
                    SELECT * FROM histpost ;
                         WHERE BETWEEN(hp_date, ldLowDate, ldHighDate) AND hp_origid = histres.hr_reserid AND ;
                         NOT hp_cancel AND (EMPTY(hp_ratecod) OR hp_split) 
          ENDIF
          ldDate = ldHighDate + 1
     ENDDO
ENDSCAN

USE IN curHistres
ENDPROC
*