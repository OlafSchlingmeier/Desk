*
FUNCTION RsCheck
 LOCAL l_nSelect, l_oReser, l_nNights, l_lChanged
 l_nSelect = SELECT()
 l_lChanged = .F.
 SELECT reservat
 SCATTER NAME l_oReser MEMO
 IF (INLIST(reServat.rs_status, "NS", "CXL") .AND. yeSno(GetLangText("RESERVAT", ;
    "TA_UNDOCXL")+"?@2"))
    LOCAL l_lChange
    l_lChange = .T.
    IF NOT USED("groupres")
         openfiledirect(.F., "groupres")
    ENDIF
    IF IsDummy(reservat.rs_roomtyp) AND NOT EMPTY(reservat.rs_groupid) ;
            AND SEEK(reservat.rs_groupid,"groupres","tag1") ;
            AND groupres.gr_pmresid <> reservat.rs_reserid
        IF EMPTY(groupres.gr_pmresid)
            IF YesNo(GetLangText("RESERVAT","TXT_ADD_PAYMASTER"))
                REPLACE gr_pmresid WITH reservat.rs_reserid IN groupres
            ELSE
                l_lChange = .F.
            ENDIF
        ELSE
            = Alert(GetLangText("RESERVAT","TXT_PAYMASTER_EXISTS")+" ;"+ ;
                    GetLangText("RESERVAT","TXT_RES_NO_GROUP"))
            l_lChange = .F.
        ENDIF
    ENDIF
    IF l_lChange
        l_oReser.rs_status = param.pa_defstat
        * When reactivating old reservations, arrival date must be adjusted!
        IF reservat.rs_arrdate < sysdate()
        	l_nNights = reservat.rs_depdate - reservat.rs_arrdate
        	l_oReser.rs_arrdate = sysdate()
        	l_oReser.rs_depdate = l_oReser.rs_arrdate + l_nNights
        ENDIF
        DO CheckAndSave IN ProcReservat WITH l_oReser, .T., .F., "REACTIVATE"
        l_lChanged = .T.
    ELSE
        = Alert(GetLangText("RESERVAT","TXT_UNDO_CXL_FAIL"))
    ENDIF
 ENDIF
 IF ( .NOT. EMPTY(reServat.rs_out) .AND. reServat.rs_depdate>=sySdate()  ;
        .AND. yeSno(GetLangText("RESERVAT","TA_UNDOOUT")+"?"))
    l_oReser.rs_out = ""
    l_oReser.rs_in = "1"
    l_oReser.rs_status = "IN"
    l_oReser.rs_posstat = "1"
    l_oReser.rs_codate = {}
    l_oReser.rs_cotime = ""
    DO CheckAndSave IN ProcReservat WITH l_oReser, .T., .F., "REACTIVATE"
    DO ifCcheck IN Interfac WITH reServat.rs_roomnum, "CHECKIN"
    l_lChanged = .T.
 ENDIF
 IF SUBSTR(reservat.rs_mshwcco,1,1)="1"
      DO FORM forms\msgedit WITH 1, reservat.rs_reserid, GetReservatLongName(), CompanyName()
 ENDIF
 SELECT(l_nSelect)
 RETURN l_lChanged
ENDFUNC
*
