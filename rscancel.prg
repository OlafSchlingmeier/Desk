*
PROCEDURE RsCancel
 PARAMETER npReserid, plGroup, pdArrival
 PRIVATE cnAme
 PRIVATE crEason
 PRIVATE nrScchoice
 PRIVATE cbUttons
 PRIVATE ncXlchoice
 PRIVATE lcAncel
 LOCAL l_nSelect
 l_nSelect = SELECT()
 SELECT reservat
 IF (PCOUNT()==1)
      plGroup = .F.
      pdArrival = {}
 ENDIF
 DO WHILE (.T.)
      IF  .NOT. EMPTY(rs_out)
           = alErt(GetLangText("RESERV2","TXT_CHECKEDOUT"),GetLangText("RESERV2", ;
             "TXT_IMPOSSIBLE"))
           EXIT
      ENDIF
      lcAncel = .F.
      DO dpCancel IN DP WITH npReserid, lcAncel
      IF lcAncel
           EXIT
      ENDIF
      ntOtbalance = baLance(npReserid,1)+baLance(npReserid,2)+ ;
                    baLance(npReserid,3)
      IF ( .NOT. EMPTY(reServat.rs_in) .AND. EMPTY(reServat.rs_out))
           IF plGroup
                = alErt(GetLangText("RESERV2","TXT_IMPOSSIBLE")+"!")
           ENDIF
           IF ( .NOT. plGroup .AND. yeSno(GetLangText("RESERV2","TA_ISINUNDO")+"?"))
                IF (reServat.rs_arrdate<>sySdate())
                     = alErt(GetLangText("RESERV2","TA_ARRTODAY"))
                ELSE
                     IF (ntOtbalance<>0)
                          IF ( .NOT. yeSno(GetLangText("RESERV2", ;
                             "TA_HASBALANCE")+";;"+GetLangText("RESERV2", ;
                             "TXT_CONTINUE")+"?",GetLangText("RESERV2","TXT_NOTE")))
                               EXIT
                          ENDIF
                     ENDIF
                     REPLACE reServat.rs_changes WITH  ;
                             rsHistry(reServat.rs_changes,"CANCEL", ;
                             "Room has balance "+LTRIM(STR(ntOtbalance,  ;
                             15, paRam.pa_currdec)))
                     REPLACE reServat.rs_in WITH ""
                     REPLACE reServat.rs_status WITH "DEF"
                     IF NOT EMPTY(reservat.rs_share)
                         DO ChangeShare IN ProcReservat WITH 2, "reservat"
		                 USE IN curChangeRes
                         = TABLEUPDATE(.F.,.T.,"sharing")
                     ENDIF
                     DO ifCcheck IN Interfac WITH reServat.rs_roomnum, "CHECKOUT"
                ENDIF
           ENDIF
           EXIT
      ENDIF
      IF ntOtbalance<>0
           IF  .NOT. plGroup
                = alErt(GetLangText("RESERV2","TA_HASBALANCE")+"!")
           ENDIF
           EXIT
      ENDIF
      IF INLIST(reServat.rs_status, "CXL", "NS")
           IF  .NOT. plGroup
                = alErt(GetLangText("RESERV2","TA_ISCXL")+"!")
           ENDIF
           EXIT
      ENDIF
      do form "forms\ResCancelForm" To nrScchoice
*      clEvel = "RlEd"
*      cbUttons = "\!"+buTton(clEvel,GetLangText("RESERV2","TXT_CXLRESERVATION"), ;
*                 9,.T.)+buTton(clEvel,GetLangText("RESERV2", ;
*                 "TXT_DELRESERVATION"),-10,.T.)
*      nrScchoice = seLectmessage(GetLangText("RESERV2","TXT_CXLORDELETE"),cbUttons)
      IF ( .NOT. BETWEEN(nrScchoice, 1, 2))
           EXIT
      ENDIF
      DO CASE
           CASE nrScchoice==1
                IF ( .NOT. plGroup .AND. paRam.pa_cxlpost)
                     DO poStpasserby IN PasserBy WITH "RES"
                ENDIF
*                cnAme = SPACE(25)
*                crEason = SPACE(25)
*                DEFINE WINDOW wrEason AT 0, 0 SIZE 5, 90 FONT "Arial", 10  ;
*                       NOCLOSE NOZOOM TITLE chIldtitle(GetLangText("RESERV2", ;
*                       "TW_REASON")) NOMDI DOUBLE
*                MOVE WINDOW wrEason CENTER
*                ACTIVATE WINDOW wrEason
*                ncXlchoice = 1
*                cbUttons = "\!"+buTton("",GetLangText("COMMON","TXT_OK"),1)+"\?"+ ;
*                           buTton("",GetLangText("COMMON","TXT_CANCEL"),-2)
*                = paNelborder()
*                = txTpanel(1,3,27,GetLangText("RESERV2","T_NAME"),24)
*                = txTpanel(2.25,3,27,GetLangText("RESERV2","T_REASON"),24)
*                @ 1, 30 GET cnAme SIZE 1, 30 PICTURE "@K "+REPLICATE("X", 25)
*                @ 2.250, 30 GET crEason SIZE 1, 30 PICTURE "@K "+ ;
*                  REPLICATE("X", 25)
*                @ 1, 70 GET ncXlchoice STYLE "B" SIZE nbUttonheight, 15  ;
*                  FUNCTION "*"+"V" PICTURE cbUttons
*                READ VALID vcHecknameandreason(cnAme,crEason) MODAL
*                RELEASE WINDOW wrEason
*                = chIldtitle("")
				Local m.Result

				m.Result = NewObject("Custom")
				m.Result.AddProperty("UName")
				m.Result.AddProperty("Reason")
				do form "forms\CancReasonForm" with m.Result to ncXlchoice
				cnAme = m.Result.UName
				crEason = m.Result.Reason
				release m.Result

                IF (ncXlchoice==1)
                     = avLsave()
                     REPLACE reServat.rs_cxldate WITH sySdate()
                     REPLACE reServat.rs_updated WITH sySdate()
                     REPLACE reServat.rs_changes WITH  ;
                             rsHistry(reServat.rs_changes,"CANCELLED","("+ ;
                             reServat.rs_status+") "+TRIM(cnAme)+ ;
                             " REASON:"+TRIM(crEason)+" CXL-Nr."+alltrim(str(reservat.rs_cxlnr)))
                     IF NOT EMPTY(reservat.rs_share)
                         DO ChangeShare IN ProcReservat WITH 3, "reServat"
                     ENDIF
                     REPLACE reServat.rs_cxlstat WITH reServat.rs_status
                     REPLACE reServat.rs_status WITH "CXL"
                     = avLupdat()
                     deleteactions(reservat.rs_reserid, reServat.rs_cxldate)
                     IF plGroup
                          DO grPcancel WITH reServat.rs_reserid,  ;
                             pdArrival, cnAme, crEason
                     ENDIF
                     DO UpdateShareRes IN ProcReservat WITH "reServat"
                ENDIF
           CASE nrScchoice==2
                IF  .NOT. dlOokup('Post','ps_reserid = '+ ;
                    sqLcnv(reServat.rs_reserid),'Found()')
                     = avLsave()
                     REPLACE reServat.rs_cxlstat WITH reServat.rs_status
                     REPLACE reServat.rs_status WITH "CXL"
                     REPLACE reServat.rs_updated WITH sySdate()
                     REPLACE reServat.rs_cxldate WITH sySdate()
                     REPLACE reServat.rs_changes WITH  ;
                             rsHistry(reServat.rs_changes,"DELETED","")
                     IF NOT EMPTY(reservat.rs_share)
                         DO ChangeShare IN ProcReservat WITH 3, "reServat"
                     ENDIF
                     DELETE
                     DO reSfixdel IN ResFix WITH reServat.rs_reserid
                     = avLupdat()
                     deleteactions(reservat.rs_reserid, reServat.rs_cxldate)
                ENDIF
                IF plGroup
                     DO grPdelete WITH reServat.rs_reserid, pdArrival
                ENDIF
                DO UpdateShareRes IN ProcReservat WITH "reServat"
      ENDCASE
      EXIT
 ENDDO
 SELECT (l_nSelect)
 RETURN
ENDPROC
*
FUNCTION vCheckNameAndReason
 PARAMETER cnAme, crEason
 PRIVATE loKay
 loKay = .F.
 IF (ncXlchoice==2 .OR. ( .NOT. EMPTY(cnAme) .AND.  .NOT. EMPTY(crEason)))
      loKay = .T.
 ELSE
      WAIT WINDOW TIMEOUT 2 GetLangText("RESERV2","TXT_BOTH_NAME_AND_REASON")
      _CUROBJ = 1
 ENDIF
 RETURN loKay
ENDFUNC
*
PROCEDURE GrpCancel
 PARAMETER ncUrid, pdArrival, cnAme, crEason
 PRIVATE nrSrec, nrSord, ndOne, nrEcs, cmSg
 nrSrec = RECNO("Reservat")
 nrSord = ORDER("Reservat")
 nrEcs = 0
 ndOne = 1
 cmSg = ""
 SET ORDER IN reServat TO 1
 = dlOcate('Reservat','rs_reserid >= '+sqLcnv(INT(ncUrid))+ ;
   ' and rs_reserid < '+sqLcnv(INT(ncUrid)+1))
 SCAN REST FOR reServat.rs_arrdate=pdArrival WHILE  ;
      INT(reServat.rs_reserid)==INT(ncUrid) .AND.  .NOT. EOF("Reservat")
      WAIT WINDOW NOWAIT LTRIM(STR(nrEcs))+"..."
      IF  .NOT. INLIST(reServat.rs_status, "CXL", "NS") .AND.  ;
          EMPTY(reServat.rs_in) .AND. EMPTY(reServat.rs_out) .AND.  ;
          baLance(reServat.rs_reserid,1)+baLance(reServat.rs_reserid,2)+ ;
          baLance(reServat.rs_reserid,3)=0 .AND. reServat.rs_reserid<>ncUrid
           = avLsave()
           IF NOT EMPTY(reservat.rs_share)
               DO ChangeShare IN ProcReservat WITH 3, "reServat"
           ENDIF
           REPLACE reServat.rs_cxlstat WITH reServat.rs_status
           REPLACE reServat.rs_status WITH "CXL"
           REPLACE reServat.rs_cxldate WITH sySdate()
           REPLACE reServat.rs_updated WITH sySdate()
           REPLACE reServat.rs_changes WITH rsHistry(reServat.rs_changes, ;
                   "CANCELLED",TRIM(cnAme)+" REASON:"+TRIM(crEason))
           = avLupdat()
           ndOne = ndOne+1
      ENDIF
      nrEcs = nrEcs+1
      WAIT CLEAR
 ENDSCAN
 IF nrEcs>0
      cmSg = STRTRAN(GetLangText("RESERV2","TA_CXL_DONE"), '%s2', LTRIM(STR(nrEcs)))
      cmSg = STRTRAN(cmSg, '%s1', LTRIM(STR(MIN(nrEcs, ndOne))))
 ELSE
      cmSg = GetLangText("RESERV2","TA_CXL_FAIL")
 ENDIF
 = alErt(cmSg)
 SET ORDER IN "Reservat" TO nRsOrd
 GOTO nrSrec IN "Reservat"
 RETURN
ENDPROC
*
PROCEDURE GrpDelete
 PARAMETER ncUrid, pdArrival
 PRIVATE nrSrec, nrSord, ndOne, nrEcs, cmSg
 nrSrec = RECNO("Reservat")
 nrSord = ORDER("Reservat")
 nrEcs = 0
 ndOne = 1
 cmSg = ""
 SET ORDER IN reServat TO 1
 = dlOcate('Reservat','rs_reserid >= '+sqLcnv(INT(ncUrid))+ ;
   ' and rs_reserid < '+sqLcnv(INT(ncUrid)+1))
 SCAN REST FOR reServat.rs_arrdate=pdArrival WHILE  ;
      INT(reServat.rs_reserid)==INT(ncUrid) .AND.  .NOT. EOF("Reservat")
      WAIT WINDOW NOWAIT LTRIM(STR(nrEcs))+"..."
      IF  .NOT. INLIST(reServat.rs_status, "CXL", "NS") .AND.  ;
          EMPTY(reServat.rs_in) .AND. EMPTY(reServat.rs_out) .AND.  .NOT.  ;
          dlOokup('Post','ps_reserid = '+sqLcnv(reServat.rs_reserid), ;
          'Found()') .AND. reServat.rs_reserid<>ncUrid
           = avLsave()
           IF NOT EMPTY(reservat.rs_share)
               DO ChangeShare IN ProcReservat WITH 3, "reServat"
           ENDIF
           REPLACE reServat.rs_cxlstat WITH reServat.rs_status
           REPLACE reServat.rs_status WITH "CXL"
           REPLACE reServat.rs_updated WITH sySdate()
           REPLACE reServat.rs_cxldate WITH sySdate()
           REPLACE reServat.rs_changes WITH rsHistry(reServat.rs_changes, ;
                   "DELETED","")
           DELETE
           = avLupdat()
           DO reSfixdel IN ResFix WITH reServat.rs_reserid
           ndOne = ndOne+1
      ENDIF
      nrEcs = nrEcs+1
      WAIT CLEAR
 ENDSCAN
 IF nrEcs>0
      cmSg = STRTRAN(GetLangText("RESERV2","TA_CXL_DONE"), '%s2', LTRIM(STR(nrEcs)))
      cmSg = STRTRAN(cmSg, '%s1', LTRIM(STR(MIN(nrEcs, ndOne))))
 ELSE
      cmSg = GetLangText("RESERV2","TA_CXL_FAIL")
 ENDIF
 = alErt(cmSg)
 SET ORDER IN "Reservat" TO nRsOrd
 GOTO nrSrec IN "Reservat"
 RETURN
ENDPROC
*
FUNCTION deleteactions
PARAMETERS p_reserid, p_cxldate
LOCAL LActionUsed, LRecno, LSelected

LSelected = SELECT()

LActionUsed = .f.
LRecno = 0
IF !USED('action')
	OpenFileDirect(.F.,"action")
ELSE
	LActionUsed = .t.
	LRecno = RECNO('action')
ENDIF
SELECT action
SCAN FOR at_reserid = p_reserid
	replace at_compl WITH p_cxldate
ENDSCAN
IF LActionUsed
	GO LRecno
ELSE
	USE
ENDIF

SELECT (LSelected)

RETURN .T.
ENDFUNC