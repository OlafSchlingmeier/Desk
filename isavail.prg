 PARAMETER daRrival, ddEparture, cfRomtime, ctOtime, crOomtype, nrOoms, crOom
 PRIVATE dtMpdate
 PRIVATE nfRee
 PRIVATE liTis
 LOCAL nRpOrder
 naRea = SELECT()
 liTis = .T.
 IF ( .NOT. EMPTY(crOom))
      ngRoup = dbLookup("RoomType","Tag1",crOomtype,"Rt_Group")
      DO CASE
           CASE ngRoup==2
                naRea = SELECT()
                SELECT roOmplan
                nrPorder = ORDER()
                SET ORDER IN roOmplan TO 1
                SET NEAR ON
                SEEK crOom+DTOS(daRrival)
                SET NEAR OFF
                nrSrecord = RECNO("Reservat")
                nrSorder = ORDER("Reservat")
                SET ORDER IN "Reservat" TO 1
                SCAN REST WHILE roOmplan.rp_roomnum=crOom .AND.  ;
                     roOmplan.rp_date<=ddEparture
                     IF BETWEEN(roOmplan.rp_status, 1, 99)
                          IF SEEK(roOmplan.rp_reserid, "reservat")
                               nfIrststart = IIF(roOmplan.rp_date== ;
                                reServat.rs_arrdate, reServat.rs_arrtime,  ;
                                "00:00")
                               nfIrstend = IIF(roOmplan.rp_date== ;
                                reServat.rs_depdate, reServat.rs_deptime,  ;
                                "24:00")
                               nsEcondstart = IIF(roOmplan.rp_date== ;
                                daRrival, cfRomtime, "00:00")
                               nsEcondend = IIF(roOmplan.rp_date== ;
                                ddEparture, ctOtime, "24:00")
                               IF (reServat.rs_arrdate<=ddEparture .AND.  ;
                                  reServat.rs_depdate>=daRrival .AND.  ;
                                  nfIrststart<=nsEcondend .AND. nfIrstend>= ;
                                  nsEcondstart .AND.  .NOT.  ;
                                  INLIST(reServat.rs_status, "NS", "CXL",  ;
                                  "OUT"))
                                    liTis = .F.
                                    EXIT
                               ENDIF
                          ENDIF
                     ELSE
                          liTis = .F.
                          EXIT
                     ENDIF
                ENDSCAN
                SET ORDER IN reServat TO nRsOrder
                GOTO nrSrecord IN reServat
                SELECT roOmplan
                SET ORDER TO nRpOrder
                SELECT (naRea)
           OTHERWISE
                SELECT roOmplan
                nrPorder = ORDER()
                SET ORDER IN roOmplan TO 1
                dtMpdate = daRrival
                DO WHILE (dtMpdate<ddEparture)
                     IF (SEEK(PADR(crOom, 4)+DTOS(dtMpdate), "RoomPlan"))
                          crOom = ""
                          EXIT
                     ENDIF
                     dtMpdate = dtMpdate+1
                ENDDO
                SELECT roOmplan
                SET ORDER TO nRpOrder
      ENDCASE
 ENDIF
 IF (EMPTY(crOom))
      SELECT avAilab
      naVorder = ORDER()
      SET ORDER IN avAilab TO 2
      IF (SEEK(crOomtype+DTOS(daRrival), "Availab"))
           DO WHILE (avAilab.av_roomtyp=crOomtype .AND. avAilab.av_date< ;
              ddEparture .AND.  .NOT. EOF("Availab"))
                nfRee = avAilab.av_avail-avAilab.av_definit- ;
                        IIF(paRam.pa_optidef, avAilab.av_option, 0)- ;
                        IIF(paRam.pa_allodef, avAilab.av_allott, 0)
                IF (nfRee<nrOoms)
                     liTis = .F.
                     EXIT
                ENDIF
                SKIP 1 IN avAilab
           ENDDO
      ENDIF
      SELECT avAilab
      SET ORDER TO nAvOrder
 ENDIF
 SELECT (naRea)
 RETURN liTis
ENDFUNC
*
