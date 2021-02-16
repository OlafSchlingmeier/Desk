 *
 #INCLUDE "include\constdefines.h"
 *
 PARAMETER lp_cResAlias, lp_lShare, lp_lMessage, lp_lImportConfReser
 LOCAL l_nArea, l_nRecno, l_cSql, l_lRet, l_lYes, l_nGroup, l_nDumType, l_lConfev, l_nOccPersons, l_nMaxpers
 LOCAL l_nReserid, l_dArrdate, l_dDepdate, l_cArrtime, l_cDeptime, l_cStatus, l_nPersons, l_nApplyToShr
 LOCAL l_tConfStart, l_tConfEnd, l_lLookForOOO, l_nRc, l_cWhereRm, l_nIntervals, l_lLookForExtReser, l_cAlertMessage, l_nAltId
 LOCAL ARRAY l_aRoomtypes(1)
 PRIVATE p_oDetermineDayPartIsRmFree
 p_oDetermineDayPartIsRmFree = NULL

 IF PCOUNT() < 2
 	lp_lMessage = .T.
 ENDIF
 IF EMPTY(lp_cResAlias)
 	lp_cResAlias = "reservat"
 ENDIF

 lp_lShare = .F.
 l_lRet = .T.
 l_cStatus = &lp_cResAlias..rs_status
 IF INLIST(l_cStatus, "NS", "CXL", "OUT")
      RETURN l_lRet
 ENDIF
 l_cAlertMessage = ""
 l_nArea = SELECT()
 l_nRecno = RECNO(lp_cResAlias)
 l_nReserid = &lp_cResAlias..rs_reserid
 l_nAltId = &lp_cResAlias..rs_altid
 l_dArrdate = &lp_cResAlias..rs_arrdate
 l_dDepdate = &lp_cResAlias..rs_depdate
 l_cArrtime = &lp_cResAlias..rs_arrtime
 l_cDeptime = &lp_cResAlias..rs_deptime
 l_nPersons = &lp_cResAlias..rs_adults + &lp_cResAlias..rs_childs + &lp_cResAlias..rs_childs2 + &lp_cResAlias..rs_childs3
 * Collect all reservation in SHARING
 * In resroom don't check this reservations because they already in sharing.
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
      SELECT DISTINCT resrooms.ri_reserid AS cr_reserid FROM curResRooms
           INNER JOIN resrmshr WITH (BUFFERING = .T.) ON resrmshr.sr_shareid = curResRooms.ri_shareid
           INNER JOIN resrooms WITH (BUFFERING = .T.) ON resrooms.ri_rroomid = resrmshr.sr_rroomid
 ENDTEXT
 &l_cSql INTO CURSOR curResRoomsId READWRITE
 INDEX ON cr_reserid TAG cr_reserid
 SET ORDER TO
 IF NOT SEEK(l_nReserid, "curResRoomsId", "cr_reserid")
      INSERT INTO curResRoomsId VALUES (l_nReserid)
 ENDIF
 * Collect all reservation room intervals for checking room conficts.
 l_nApplyToShr = DLookUp("curResRooms","ri_shapply","ri_shareid")
 TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
      SELECT resrooms.*, NVL(rt_group,0) AS rt_group, NVL(rt_dumtype,0) AS rt_dumtype, NVL(rt_confev,0) AS rt_confev, NVL(rm_maxpers,0000) AS rm_maxpers
           FROM resrooms WITH (BUFFERING = .T.)
           <<IIF(l_nApplyToShr > 0, "LEFT JOIN resrmshr WITH (BUFFERING = .T.) ON sr_rroomid = ri_rroomid","")>>
           LEFT JOIN room ON rm_roomnum = ri_roomnum
           LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp
           WHERE ri_reserid = <<SqlCnv(l_nReserid)>> AND NOT EMPTY(ri_roomnum) AND ri_todate >= <<SqlCnv(g_sysdate)>>
           <<IIF(l_nApplyToShr > 0, " OR sr_shareid = "+SqlCnv(l_nApplyToShr),"")>>
 ENDTEXT
 &l_cSql INTO CURSOR curCheckIntervals READWRITE
 INDEX ON ri_rroomid TAG ri_rroomid
 INDEX ON ri_date TAG ri_date
 l_nIntervals = RECCOUNT()
 SET ORDER TO
 IF l_nApplyToShr > 0
      TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
           SELECT resrooms.*, NVL(rt_group,0) AS rt_group, NVL(rt_dumtype,0) AS rt_dumtype, NVL(rt_confev,0) AS rt_confev, NVL(rm_maxpers,0000) AS rm_maxpers
                FROM resrooms WITH (BUFFERING = .T.)
                INNER JOIN resrmshr WITH (BUFFERING = .T.) ON sr_rroomid = ri_rroomid
                LEFT JOIN room ON rm_roomnum = ri_roomnum
                LEFT JOIN roomtype ON rt_roomtyp = ri_roomtyp
                WHERE ri_reserid <> <<SqlCnv(l_nReserid,.T.)>> AND NOT EMPTY(ri_roomnum) AND ri_todate >= <<SqlCnv(g_sysdate)>> AND sr_shareid = <<SqlCnv(l_nApplyToShr,.T.)>>
      ENDTEXT
      l_cTmpResrooms = SYS(2015)
      &l_cSql INTO CURSOR &l_cTmpResrooms
      SCAN FOR NOT SEEK(ri_rroomid, "curCheckIntervals", "ri_rroomid")
           SCATTER MEMO NAME l_oResrooms
           INSERT INTO curCheckIntervals FROM NAME l_oResrooms
      ENDSCAN
      DClose(l_cTmpResrooms)
 ENDIF
 * Collect also linked rooms for checking room conficts.
 SELECT curCheckIntervals
 SCAN FOR RECNO() <= l_nIntervals     && Add linked rooms at end of cursor
      SCATTER MEMO NAME l_oResrooms
      l_nRc = RECNO()
      FOR i = 2 TO LinkRoomtype(ri_roomnum, ri_roomtyp, @l_aRoomtypes)
           l_oResrooms.ri_roomnum = l_aRoomtypes(i,4)
           INSERT INTO curCheckIntervals FROM NAME l_oResrooms
      NEXT
      GO l_nRc
 ENDSCAN

 * Check all intervals...
 SELECT curCheckIntervals
 LOCATE
 SCAN WHILE l_lRet
      DO CASE
           CASE ri_roomnum = VIRTUAL_ROOMNUM
                l_nGroup = 1
                l_nDumType = 0
                l_lConfev = .F.
           CASE rt_group = 3 AND NOT INLIST(rt_dumtype, 1, 3)
                LOOP
           CASE rt_group > 0 AND rt_group <> 4
                l_nGroup = rt_group
                l_nDumType = rt_dumtype
                l_lConfev = (rt_group = 2 AND rt_confev)
           OTHERWISE
                LOOP
      ENDCASE
      l_lLookForOOO = .F.
      l_lLookForExtReser = .F.
      * Collect conflicted reservations.
      DO CASE
           CASE NOT l_lConfev
                l_cWhereRm = "ri_roomnum = " + SqlCnv(ri_roomnum,.T.)
           CASE RECNO() > l_nIntervals
                LOOP
           OTHERWISE
                * Collect reservations in linked room too.
                l_cWhereRm = "INLIST(ri_roomnum "
                FOR i = 1 TO LinkRoomtype(ri_roomnum, ri_roomtyp, @l_aRoomtypes)
                     l_cWhereRm = l_cWhereRm + ", " + SqlCnv(l_aRoomtypes(i,4),.T.)
                NEXT
                l_cWhereRm = l_cWhereRm + ")"
      ENDCASE
      TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
           SELECT * FROM resrooms WITH (BUFFERING = .T.)
                INNER JOIN reservat WITH (BUFFERING = .T.) ON rs_reserid = ri_reserid
                WHERE <<l_cWhereRm>> AND ri_date <= <<IIF(l_cStatus = "IN" AND l_dDepdate = g_sysdate AND l_dDepdate <= ri_todate+1, "IIF(rs_status = 'IN', "+SqlCnv(l_dDepdate)+", "+SqlCnv(ri_todate)+")", SqlCnv(ri_todate))>> AND
                     <<IIF(l_cStatus = "IN", "IIF(rs_status = 'IN' AND rs_depdate = "+SqlCnv(g_sysdate)+" AND rs_depdate <= ri_todate+1, rs_depdate, ri_todate)", "ri_todate")>> >= <<SqlCnv(ri_date)>> AND
                     NOT INLIST(rs_status,"NS","CXL","OUT") AND NOT SEEK(resrooms.ri_reserid, "curResRoomsId", "cr_reserid")
                ORDER BY ri_date
      ENDTEXT
      &l_cSql INTO CURSOR curConflicted
      IF RECCOUNT("curConflicted") = 0
           SELECT curCheckIntervals
           l_lLookForOOO = .T.
           * No conflicted reservations than look for OOO or OOS records.
           TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 2 + 8
                SELECT os_fromdat, os_reason, -2 AS os_status FROM outofser
                     WHERE os_roomnum = <<SqlCnv(ri_roomnum,.T.)>> AND NOT os_cancel AND
                          os_fromdat <= <<SqlCnv(ri_todate,.T.)>> AND os_todat > <<SqlCnv(MAX(g_sysdate,ri_date),.T.)>>
                     UNION SELECT oo_fromdat, oo_reason, -1 FROM outoford
                     WHERE oo_roomnum = <<SqlCnv(ri_roomnum,.T.)>> AND NOT oo_cancel AND
                          oo_fromdat <= <<SqlCnv(ri_todate,.T.)>> AND oo_todat > <<SqlCnv(MAX(g_sysdate,ri_date),.T.)>>
                     ORDER BY 1
           ENDTEXT
           SqlCursor(l_cSql, "curConflicted")
           IF RECCOUNT("curConflicted") = 0
                SELECT curCheckIntervals
                IF RIIsRmFreeExtReser(MAX(g_sysdate,ri_date),ri_todate,ri_roomnum,@l_cAlertMessage,l_nReserid)
                     LOOP     && Not found any conflicts.
                ELSE
                     l_lLookForExtReser = .T.
                ENDIF
           ENDIF
      ENDIF
      * Conflict exists.
      SELECT curConflicted
      LOCATE     && locate first by ri_date or os_fromdat order
      DO CASE
           CASE l_lLookForExtReser
                IF lp_lMessage
                     Alert(l_cAlertMessage)
                ENDIF
                l_lRet = .F.
           CASE l_lLookForOOO AND os_status = -1
                IF lp_lMessage
                     Alert(GetLangText("RESERVAT","TXT_ROOM_OUT_OF_ORDER")+";-"+ALLTRIM(os_reason))
                ENDIF
                l_lRet = _screen.oGlobal.oParam.pa_oooover
           CASE l_lLookForOOO AND os_status = -2
                IF lp_lMessage
                     Alert(GetLangText("RESERVAT","TXT_ROOM_OUT_OF_SERVICE")+";-"+ALLTRIM(os_reason))
                ENDIF
                l_lRet = _screen.oGlobal.oParam.pa_oooover
           CASE l_lLookForOOO
           CASE l_nGroup = 2
                l_tConfStart = DTOT(l_dArrdate) + GetSecondsFromTime(l_cArrtime)
                l_tConfEnd = DTOT(l_dDepdate) + GetSecondsFromTime(IIF(EMPTY(l_cDeptime), "24:00", l_cDeptime))
                l_nMaxpers = curCheckIntervals.rm_maxpers
                IF l_lConfev AND l_nMaxpers > 0 AND NOT EMPTY(CHRTRAN(l_cArrtime,"0:",""))
                     CALCULATE SUM(rs_adults+rs_childs+rs_childs2+rs_childs3) FOR NOT EMPTY(CHRTRAN(rs_arrtime,"0:","")) AND NOT EMPTY(CHRTRAN(rs_deptime,"0:","")) AND ;
                          BETWEEN(l_tConfStart, DTOT(rs_arrdate) + GetSecondsFromTime(rs_arrtime), DTOT(rs_depdate) + GetSecondsFromTime(rs_deptime) - 1) ;
                          TO l_nOccupied IN curConflicted
                     IF EMPTY(l_nOccupied) AND NOT EMPTY(CHRTRAN(l_cDeptime,"0:",""))
                          l_tConfEnd = DTOT(l_dDepdate) + GetSecondsFromTime(l_cDeptime)
                          CALCULATE SUM(rs_adults+rs_childs+rs_childs2+rs_childs3) FOR NOT EMPTY(CHRTRAN(rs_arrtime,"0:","")) AND NOT EMPTY(CHRTRAN(rs_deptime,"0:","")) AND ;
                               BETWEEN(l_tConfEnd, DTOT(rs_arrdate) + GetSecondsFromTime(rs_arrtime) + 1, DTOT(rs_depdate) + GetSecondsFromTime(rs_deptime)) ;
                               TO l_nOccupied IN curConflicted
                     ENDIF
                     DO CASE
                          CASE l_nPersons <= l_nMaxpers - l_nOccupied
                          CASE lp_lMessage      && Too many persons
                               Alert(IIF(l_nMaxpers > l_nOccupied, Str2Msg(GetLangText("RESERVAT","TA_AVAILABLE"),"%s",TRANSFORM(l_nMaxpers-l_nOccupied)), GetLangText("RESERVAT","TA_ALLBOOKED")))
                               l_lRet = .F.
                          OTHERWISE
                               l_lRet = .F.
                     ENDCASE
                ELSE
                     IF _screen.oGlobal.oParam2.pa_connew
                          IF VARTYPE(p_oDetermineDayPartIsRmFree)<>"O"
                               p_oDetermineDayPartIsRmFree = NEWOBJECT("CODetermineDayPart", "procconf.prg")
                               p_oDetermineDayPartIsRmFree.IsRmFreeSetFromReserId(l_nReserid)
                          ENDIF
                          l_lFound = p_oDetermineDayPartIsRmFree.IsRmFree(curConflicted.rs_reserid)
                     ELSE
                          LOCATE FOR DTOT(rs_arrdate) + GetSecondsFromTime(rs_arrtime) < l_tConfEnd AND ;
                               DTOT(rs_depdate) + GetSecondsFromTime(IIF(EMPTY(rs_deptime), "24:00", rs_deptime)) > l_tConfStart
                          l_lFound = FOUND()
                     ENDIF
                     IF l_lFound
                          IF lp_lMessage
                               Alert(GetLangText("RESERVAT","TA_NOTFREE")+";"+ ;
                                    PROPER(TRIM(rs_company))+"/"+PROPER(TRIM(rs_lname))+";"+ ;
                                    DTOC(rs_arrdate)+" "+DTOC(rs_depdate)+" "+rs_arrtime+" "+rs_deptime+" ("+ALLTRIM(STR(rs_adults+rs_childs+rs_childs2+rs_childs3))+")!")
                          ENDIF
                          l_lRet = IIF(lp_lImportConfReser,.F.,_screen.oGlobal.oParam.pa_dblbook)
                     ENDIF
                ENDIF
           CASE l_nGroup = 3 AND l_nDumType > 1
                IF lp_lMessage
                     Alert(GetLangText("RESERVAT","TA_NOTFREE")+";"+ ;
                          PROPER(TRIM(rs_company))+"/"+PROPER(TRIM(rs_lname))+";"+ ;
                          DTOC(rs_arrdate)+" "+DTOC(rs_depdate)+" ("+LTRIM(STR(rs_adults+rs_childs+rs_childs2+rs_childs3))+")!")
                ENDIF
                l_lRet = .F.
           OTHERWISE
                IF l_lRet AND _screen.oGlobal.oParam.pa_rshare AND rs_altid <> l_nAltId
                     IF lp_lMessage
                          Alert(GetLangText("RESERVAT","TXT_NOSHARE_OTHER_ALLOTT"))
                     ENDIF
                     l_lRet = .F.
                ENDIF
                IF NOT _screen.oGlobal.oParam.pa_multioc AND rs_status = "IN" AND l_cStatus = "IN"
                     IF lp_lMessage
                          Alert(GetLangText("RESERVAT","TXT_NOTALLOWEDMULTIOC")+";;"+ ;
                               GetLangText("RESERVAT","TXT_ROOM_IS_ASSIGNED_TO")+" "+rs_lname+";"+ ;
                               GetLangText("RESERVAT","TXT_FROM")+" "+DTOC(rs_arrdate)+" "+GetLangText("RESERVAT","TH_TO")+" "+DTOC(rs_depdate), ;
                               GetLangText("RESERVAT","TXT_MULTIPLE_OCCUPATION")) 
                     ENDIF
                     l_lRet = .F.
                ENDIF
                IF l_lRet
                     LOCAL l_lMessage
                     l_lMessage = .F.
                     IF NOT _screen.oGlobal.oParam.pa_rshare
                          l_lMessage = .T.
                          l_lRet = _screen.oGlobal.oParam.pa_dblbook
                     ENDIF
                     IF l_lRet AND NOT _screen.oGlobal.oParam.pa_multioc AND rs_status = "IN" AND l_cStatus <> "IN" OR ;
                               (rs_arrdate = rs_depdate OR l_dArrdate = l_dDepdate) AND (rs_status = "IN" OR l_cStatus = "IN")
                          l_lMessage = .T.
                     ENDIF
                     IF l_lMessage AND lp_lMessage
                          Alert(GetLangText("RESERVAT","TXT_ROOM_IS_ASSIGNED_TO")+" '"+PROPER(TRIM(rs_lname))+"';"+ ;
                               GetLangText("RESERVAT","TXT_FROM")+" "+DTOC(rs_arrdate)+" "+ ;
                               GetLangText("RESERVAT","TXT_UNTIL")+" "+DTOC(rs_depdate)+";;", ;
                               GetLangText("RESERVAT","TXT_MULTIPLE_OCCUPATION"))
                     ENDIF
                ENDIF
                IF l_lRet AND _screen.oGlobal.oParam.pa_rshare
                     l_lYes = .T.
                     IF lp_lMessage AND rs_status <> "OUT" AND rs_arrdate < rs_depdate AND l_dArrdate < l_dDepdate
                          l_lYes = YesNo(GetLangText("RESERVAT","TXT_ROOM_IS_ASSIGNED_TO")+" '"+PROPER(TRIM(rs_lname))+"';"+ ;
                               GetLangText("RESERVAT","TXT_FROM")+" "+DTOC(rs_arrdate)+" "+GetLangText("RESERVAT","TXT_UNTIL")+" "+DTOC(rs_depdate)+";;"+ ;
                               GetLangText("RESERVAT","TXT_CONT_AS_ROOMSHARE")+"?", ;
                               GetLangText("RESERVAT","TXT_MULTIPLE_OCCUPATION"))
                     ENDIF
                     IF l_lYes AND rs_arrdate < rs_depdate AND l_dArrdate < l_dDepdate
                          lp_lShare = .T.
                     ENDIF
                     l_lRet = l_lYes
                ENDIF
      ENDCASE
      SELECT curCheckIntervals
 ENDSCAN
 DClose("curResRoomsid")
 DClose("curCheckIntervals")
 DClose("curConflicted")
 GOTO l_nRecno IN &lp_cResAlias
 SELECT (l_nArea)
 RETURN l_lRet
ENDFUNC
*