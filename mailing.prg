* Mailing.prg
*
LPARAMETERS lp_oForm, lp_cFullPath, lp_oParams, lp_oProgress, lp_lRemote
LOCAL i, l_lFound, l_cMacro, LDay1, LMonth1, LDay2, LMonth2, l_lProgressBarUsed, l_lURes, l_cResAlias, l_cHResTag3, l_cHResTag4, l_cHResTag5, l_cRptFields, l_cCurName, ;
     l_cForClause, LString, LStringMultiProper, l_cMail, l_cNear, l_lMpCondition, l_nStayed, l_nSumNights, l_nRevenue, l_nID

l_cRptFields = lp_oParams.RptFields1 + lp_oParams.RptFields2
IF NOT lp_oParams.LMultiProper
     SELECT &l_cRptFields, CAST(0 AS N(8)) AS ap_apid FROM address WHERE 0=1 INTO CURSOR curReport READWRITE
     INDEX ON ad_addrid TAG ad_addrid
ELSE
     MFUseTables()
     IF NOT FILE(lp_cFullPath)
          l_cCurName = JUSTSTEM(lp_cFullPath)
          SELECT &l_cRptFields, CAST(0 AS N(8)) AS ap_apid, 0=1 AS c_cond, ;
               CAST(0 AS I) AS c_stayed, CAST(0 AS I) AS c_nights, CAST(0 AS B(2)) AS c_revenue ;
               FROM address ;
               WHERE 0=1 ;
               INTO TABLE (lp_cFullPath)
          INDEX ON ad_addrid TAG ad_addrid
          DClose(l_cCurName)
     ENDIF
     USE (lp_cFullPath) IN 0 ALIAS curReport
ENDIF

LMonth1 = INT(VAL(STREXTRACT(lp_oParams.LBirth1,"","/",1,2)))
LDay1 = INT(VAL(STREXTRACT(lp_oParams.LBirth1,"/","",1,2)))
LMonth2 = INT(VAL(STREXTRACT(lp_oParams.LBirth2,"","/",1,2)))
LDay2 = INT(VAL(STREXTRACT(lp_oParams.LBirth2,"/","",1,2)))

STORE "" TO l_cForClause, LString, LStringMultiProper
IF lp_oParams.LMultiProper
     l_cForClause = LString + "ad_adid > 0"
ENDIF
if !Empty(lp_oParams.LAddressid1) AND !Empty(lp_oParams.LAddressid2)
     l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + StrToMsg("BETWEEN(%s1,%n2,%n3)", IIF(lp_oParams.LMultiProper,"ad_adid","ad_addrid"), lp_oParams.LAddressid1, lp_oParams.LAddressid2)
endif

if !Empty(lp_oParams.LCompany1) AND !Empty(lp_oParams.LCompany2)
     l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + StrToSql("BETWEEN(UPPER(ad_company)+UPPER(ad_lname),%s1,%s2)", lp_oParams.LCompany1, lp_oParams.LCompany2)
endif

if !Empty(lp_oParams.LLName1) AND !Empty(lp_oParams.LLName2)
     l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + StrToSql("BETWEEN(UPPER(ad_lname)+UPPER(ad_fname)+UPPER(ad_city),%s1,%s2)", lp_oParams.LLName1, lp_oParams.LLName2)
endif

if !Empty(lp_oParams.LCompkey1) AND !Empty(lp_oParams.LCompkey2)
     l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + StrToSql("BETWEEN(UPPER(ad_compkey),%s1,%s2)", lp_oParams.LCompkey1, lp_oParams.LCompkey2)
endif

if !Empty(lp_oParams.LCompnum1) AND !Empty(lp_oParams.LCompnum2)
     l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + StrToSql("BETWEEN(ad_compnum,%n1,%n2)", lp_oParams.LCompnum1, lp_oParams.LCompnum2)
endif

if !Empty(lp_oParams.LMember1) AND !Empty(lp_oParams.LMember2)
     l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + StrToSql("BETWEEN(ad_member,%n1,%n2)", lp_oParams.LMember1, lp_oParams.LMember2)
endif

if lp_oParams.LCOnlyWithEmail = 1
     l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + "UPPER(ad_email)>[ ]"
endif

FOR i = 1 TO 10
     if !Empty(lp_oParams.LUser(i))
          l_cForClause = l_cForClause + IIF(EMPTY(l_cForClause), "", " AND ") + StrToSql("UPPER(ad_usr%n1)=%s2", i, lp_oParams.LUser(i))
     endif
NEXT

if !Empty(lp_oParams.LLang)
     LString = StrToSql("UPPER(ad_lang)=%s1", lp_oParams.LLang)
endif

if !Empty(lp_oParams.LCountry)
     LString = LString + IIF(EMPTY(LString), "", " AND ") + StrToSql("UPPER(ad_country)=%s1", lp_oParams.LCountry)
endif

if !Empty(lp_oParams.LZip1) AND !Empty(lp_oParams.LZip2)
     LString = LString + IIF(EMPTY(LString), "", " AND ") + StrToSql("BETWEEN(UPPER(ad_zip),%s1,%s2)", lp_oParams.LZip1, lp_oParams.LZip2)
endif

if !Empty(LDay1) AND !Empty(LDay2) AND !Empty(LMonth1) AND !Empty(LMonth2)
     LString = LString + IIF(EMPTY(LString), "", " AND ") + StrToSql("NOT EMPTY(ad_birth) AND BETWEEN(RIGHT(DTOS(ad_birth),4),%s1,%s2)", ;
          PADL(LMonth1,2,"0")+PADL(LDay1,2,"0"), PADL(LMonth2,2,"0")+PADL(LDay2,2,"0"))
endif

IF NOT EMPTY(lp_oParams.LMail1) OR NOT EMPTY(lp_oParams.LMail2) OR NOT EMPTY(lp_oParams.LMail3)
     l_cMail = ""
     FOR i = 1 TO 3
          l_cMacro = "lp_oParams.LMail"+TRANSFORM(i)
          if !Empty(&l_cMacro)
               IF lp_oParams.LOrLink = 1
                    l_cMail = l_cMail + IIF(EMPTY(l_cMail), "", " OR ") + StrToSql("INLIST(%s1,ad_mail1,ad_mail2,ad_mail3,ad_mail4,ad_mail5)", &l_cMacro)
               ELSE
                    l_cMail = l_cMail + IIF(EMPTY(l_cMail), "", " AND ") + StrToSql("INLIST(%s1,ad_mail1,ad_mail2,ad_mail3,ad_mail4,ad_mail5)", &l_cMacro)
               ENDIF
          endif
     NEXT
     LString = LString + IIF(EMPTY(LString), "", " AND ") + "(" + l_cMail + ")"
ENDIF

IF NOT EMPTY(lp_oParams.LExMail1) OR NOT EMPTY(lp_oParams.LExMail2) OR NOT EMPTY(lp_oParams.LExMail3)
     l_cMail = ""
     FOR i = 1 TO 3
          l_cMacro = "lp_oParams.LExMail"+TRANSFORM(i)
          if !Empty(&l_cMacro)
               IF lp_oParams.LOr_ExLink = 1
                    l_cMail = l_cMail + IIF(EMPTY(l_cMail), "", " OR ") + StrToSql("INLIST(%s1,ad_mail1,ad_mail2,ad_mail3,ad_mail4,ad_mail5)", &l_cMacro)
               ELSE
                    l_cMail = l_cMail + IIF(EMPTY(l_cMail), "", " AND ") + StrToSql("INLIST(%s1,ad_mail1,ad_mail2,ad_mail3,ad_mail4,ad_mail5)", &l_cMacro)
               ENDIF
          endif
     NEXT
     LStringMultiProper = StrToMsg("NOT(%s1)", l_cMail)
ENDIF

if !Empty(lp_oParams.LTCreated1) AND !Empty(lp_oParams.LTCreated2)
     LString = LString + IIF(EMPTY(LString), "", " AND ") + StrToSql("BETWEEN(ad_created,%d1,%d2)", lp_oParams.LTCreated1, lp_oParams.LTCreated2)
endif

if lp_oParams.LVip1
     LString = LString + IIF(EMPTY(LString), "", " AND ") + "ad_vip"
endif

if lp_oParams.LVip2
     LString = LString + IIF(EMPTY(LString), "", " AND ") + "ad_vip2"
endif

if NOT EMPTY(lp_oParams.LAdrType)
     LString = LString + IIF(EMPTY(LString), "", " AND ") + StrToSql("ad_adrtype=%s1", lp_oParams.LAdrType)
endif

if NOT EMPTY(lp_oParams.LVipStat)
     LString = LString + IIF(EMPTY(LString), "", " AND ") + StrToSql("ad_vipstat=%n1", lp_oParams.LVipStat)
endif

if lp_oParams.LSortCompOrName = 2
     LString = LString + IIF(EMPTY(LString), "", " AND ") + "NOT EMPTY(ad_company)"
endif

if lp_oParams.LSortCompOrName = 3
     LString = LString + IIF(EMPTY(LString), "", " AND ") + "EMPTY(ad_company) AND NOT EMPTY(ad_lname)"
endif

if lp_oParams.LCIncluding = 0
     LString = LString + IIF(EMPTY(LString), "", " AND ") + "NOT EMPTY(ad_street) AND NOT EMPTY(ad_zip) AND NOT EMPTY(ad_city)"
endif

LString = LString + IIF(EMPTY(LString), "", " AND ") + "NOT ad_nomail" + IIF(_screen.GO, " AND DLookUp('adrprvcy', 'ap_addrid = address.ad_addrid', 'ap_consent > 1')", "")

IF NOT lp_oParams.LMultiProper AND NOT EMPTY(LStringMultiProper)
     LString = LString + IIF(EMPTY(LString), "", " AND ") + LStringMultiProper
ENDIF

IF EMPTY(l_cForClause)
     l_cForClause = "0=0"
ENDIF

l_cNear = SET("Near")
IF l_cNear <> "ON"
     SET NEAR ON
ENDIF

* Check should be reservat or histres used
l_lURes = (NOT EMPTY(lp_oParams.LTArrival1) AND lp_oParams.LTArrival1 >= param.pa_sysdate)

IF l_lURes
     l_cResAlias = "reservat"
     SELECT histres
     SET RELATION TO
     SELECT reservat
     SET ORDER TO TAG10
     SET RELATION TO rs_roomtyp INTO roomtype
     l_cHResTag3 = "TAG10"
     l_cHResTag4 = "TAG11"
     l_cHResTag5 = "TAG12"
ELSE
     l_cResAlias = "histres"
     SELECT reservat
     SET RELATION TO
     SELECT histres
     SET ORDER TO TAG3
     SET RELATION TO hr_roomtyp INTO roomtype
     l_cHResTag3 = "TAG3"
     l_cHResTag4 = "TAG4"
     l_cHResTag5 = "TAG5"
ENDIF
l_lProgressBarUsed = (VARTYPE(lp_oProgress)="O")

SELECT address
SCAN FOR &l_cForClause
     IF l_lProgressBarUsed
          lp_oProgress.Progress()
     ENDIF
     IF lp_oParams.LMultiProper
          IF SEEK(address.ad_adid,"curReport","ad_addrid") && When address already selected, skip it
               LOOP
          ENDIF
     ENDIF
     IF NOT (ad_addrid > 0 AND &LString)
          LOOP
     ENDIF
     IF lp_oParams.LMultiProper AND NOT EMPTY(LStringMultiProper)
          l_lMpCondition = &LStringMultiProper
     ENDIF
     IF l_cResAlias = "histres"     &&******************** Prepare SQLs for archive ******************************************************
          ProcArchive("RestoreArchive", "histres", "SELECT histres.* FROM histres WHERE hr_addrid = "+SqlCnvB(address.ad_addrid)+" OR hr_compid = "+SqlCnvB(address.ad_addrid)+" OR hr_agentid = "+SqlCnvB(address.ad_addrid), {}, .T., .T.)
     ENDIF
     l_lFound = .T.
     STORE 0 TO l_nStayed, l_nSumNights, l_nRevenue
     SELECT &l_cResAlias
     IF l_lFound AND NOT EMPTY(lp_oParams.LSource)
          l_lFound = .F.
          IF SEEK(address.ad_addrid,l_cResAlias,l_cHResTag3)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(EVALUATE(IIF(l_lURes,"rs","hr")+"_source")) = lp_oParams.LSource REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_addrid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag4
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag4)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(EVALUATE(IIF(l_lURes,"rs","hr")+"_source")) = lp_oParams.LSource REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_compid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag5
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag5)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(EVALUATE(IIF(l_lURes,"rs","hr")+"_source")) = lp_oParams.LSource REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_agentid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag3
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LMarktcode)
          l_lFound = .F.
          IF SEEK(address.ad_addrid,l_cResAlias,l_cHResTag3)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(EVALUATE(IIF(l_lURes,"rs","hr")+"_market")) = lp_oParams.LMarktcode REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_addrid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag4
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag4)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(EVALUATE(IIF(l_lURes,"rs","hr")+"_market")) = lp_oParams.LMarktcode REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_compid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag5
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag5)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(EVALUATE(IIF(l_lURes,"rs","hr")+"_market")) = lp_oParams.LMarktcode REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_agentid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag3
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LHRRAtecode)
          l_lFound = .F.
          IF SEEK(address.ad_addrid,l_cResAlias,l_cHResTag3)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(CHRTRAN(EVALUATE(IIF(l_lURes,"rs","hr")+"_ratecod"),"!*","")) = lp_oParams.LHRRAtecode REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_addrid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag4
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag4)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(CHRTRAN(EVALUATE(IIF(l_lURes,"rs","hr")+"_ratecod"),"!*","")) = lp_oParams.LHRRAtecode REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_compid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag5
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag5)
               LOCATE FOR NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") AND ALLTRIM(CHRTRAN(EVALUATE(IIF(l_lURes,"rs","hr")+"_ratecod"),"!*","")) = lp_oParams.LHRRAtecode REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_agentid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag3
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LTArrival1) AND NOT EMPTY(lp_oParams.LTArrival2)
          l_lFound = .F.
          IF SEEK(address.ad_addrid,l_cResAlias,l_cHResTag3)
               LOCATE FOR BETWEEN(EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate"), lp_oParams.LTArrival1, lp_oParams.LTArrival2) AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_addrid") = address.ad_addrid
               IF lp_oParams.LOnlyUntil
                    * Get only addresses which were in hotel from LTArrival2, but not later
                    IF FOUND()
                         LOCATE FOR EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate") > lp_oParams.LTArrival2 AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_addrid") = address.ad_addrid
                         IF NOT FOUND()
                              l_lFound = .T.
                         ENDIF
                    ENDIF
               ELSE
                    l_lFound = FOUND()
               ENDIF
          ENDIF
          SET ORDER TO &l_cHResTag4
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag4)
               LOCATE FOR BETWEEN(EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate"), lp_oParams.LTArrival1, lp_oParams.LTArrival2) AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_compid") = address.ad_addrid
               IF lp_oParams.LOnlyUntil
                    IF FOUND()
                         LOCATE FOR EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate") > lp_oParams.LTArrival2 AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_compid") = address.ad_addrid
                         IF NOT FOUND()
                              l_lFound = .T.
                         ENDIF
                    ENDIF
               ELSE
                    l_lFound = FOUND()
               ENDIF
          ENDIF
          SET ORDER TO &l_cHResTag5
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag5)
               LOCATE FOR BETWEEN(EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate"), lp_oParams.LTArrival1, lp_oParams.LTArrival2) AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_agentid") = address.ad_addrid
               IF lp_oParams.LOnlyUntil
                    IF FOUND()
                         LOCATE FOR EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate") > lp_oParams.LTArrival2 AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_agentid") = address.ad_addrid
                         IF NOT FOUND()
                              l_lFound = .T.
                         ENDIF
                    ENDIF
               ELSE
                    l_lFound = FOUND()
               ENDIF
          ENDIF
          SET ORDER TO &l_cHResTag3
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LTDepar1) AND NOT EMPTY(lp_oParams.LTDepar2)
          l_lFound = .F.
          IF SEEK(address.ad_addrid,l_cResAlias,l_cHResTag3)
               LOCATE FOR BETWEEN(EVALUATE(IIF(l_lURes,"rs","hr")+"_depdate"), lp_oParams.LTDepar1, lp_oParams.LTDepar2) AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_addrid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag4
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag4)
               LOCATE FOR BETWEEN(EVALUATE(IIF(l_lURes,"rs","hr")+"_depdate"), lp_oParams.LTDepar1, lp_oParams.LTDepar2) AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_compid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag5
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag5)
               LOCATE FOR BETWEEN(EVALUATE(IIF(l_lURes,"rs","hr")+"_depdate"), lp_oParams.LTDepar1, lp_oParams.LTDepar2) AND NOT INLIST(EVALUATE(IIF(l_lURes,"rs","hr")+"_status"), "NS ", "CXL") REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_agentid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag3
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LNNights)
          l_cMacro = IIF(l_lURes,"rs","hr")+"_depdate" + " - " + IIF(l_lURes,"rs","hr")+"_arrdate" + IIF(lp_oParams.LONights = 1," = "," >= ") + TRANSFORM(lp_oParams.LNNights)
          l_lFound = .F.
          IF SEEK(address.ad_addrid,l_cResAlias,l_cHResTag3)
               LOCATE FOR EVALUATE(IIF(l_lURes,"rs","hr")+"_depdate") >= EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate") AND IIF(l_lURes,INLIST(rs_status,'6PM', 'ASG', 'DEF', 'IN ', 'OUT', 'OPT', 'LST', 'TEN'),hr_status='OUT') AND EVALUATE(IIF(l_lURes,"rs","hr")+"_roomtyp") = roomtype.rt_roomtyp AND ;
                    INLIST(roomtype.rt_group,1,4) AND &l_cMacro REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_addrid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag4
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag4)
               LOCATE FOR EVALUATE(IIF(l_lURes,"rs","hr")+"_depdate") >= EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate") AND IIF(l_lURes,INLIST(rs_status,'6PM', 'ASG', 'DEF', 'IN ', 'OUT', 'OPT', 'LST', 'TEN'),hr_status='OUT') AND EVALUATE(IIF(l_lURes,"rs","hr")+"_roomtyp") = roomtype.rt_roomtyp AND ;
                    INLIST(roomtype.rt_group,1,4) AND &l_cMacro REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_compid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag5
          IF NOT l_lFound AND SEEK(address.ad_addrid,l_cResAlias,l_cHResTag5)
               LOCATE FOR EVALUATE(IIF(l_lURes,"rs","hr")+"_depdate") >= EVALUATE(IIF(l_lURes,"rs","hr")+"_arrdate") AND IIF(l_lURes,INLIST(rs_status,'6PM', 'ASG', 'DEF', 'IN ', 'OUT', 'OPT', 'LST', 'TEN'),hr_status='OUT') AND EVALUATE(IIF(l_lURes,"rs","hr")+"_roomtyp") = roomtype.rt_roomtyp AND ;
                    INLIST(roomtype.rt_group,1,4) AND &l_cMacro REST WHILE EVALUATE(IIF(l_lURes,"rs","hr")+"_agentid") = address.ad_addrid
               l_lFound = FOUND()
          ENDIF
          SET ORDER TO &l_cHResTag3
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LNStayed)
          l_nStayed = MFCalcNightStayed(address.ad_addrid)
          IF NOT lp_oParams.LMultiProper
               l_lFound = EVALUATE("l_nStayed" + IIF(lp_oParams.LOStayed = 1," = "," >= ") + TRANSFORM(lp_oParams.LNStayed))
          ENDIF
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LNSumNights)
          l_nSumNights = MFCalcSumNightStayed(address.ad_addrid)
          IF NOT lp_oParams.LMultiProper
               l_lFound = EVALUATE("l_nSumNights" + IIF(lp_oParams.LOSumNights = 1," = "," >= ") + TRANSFORM(lp_oParams.LNSumNights))
          ENDIF
     ENDIF
     IF l_lFound AND lp_oParams.LCNotHistres = 1
          SELECT histres
          SET ORDER TO
          LOCATE FOR hr_addrid = address.ad_addrid AND NOT INLIST(hr_status, "NS ", "CXL")
          l_lFound = NOT FOUND()
          IF l_lFound
               LOCATE FOR hr_compid = address.ad_addrid AND NOT INLIST(hr_status, "NS ", "CXL")
               l_lFound = NOT FOUND()
          ENDIF
          IF l_lFound
               LOCATE FOR hr_agentid = address.ad_addrid AND NOT INLIST(hr_status, "NS ", "CXL")
               l_lFound = NOT FOUND()
          ENDIF
          SET ORDER TO TAG3 IN histres
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.LNMinPosting)
          l_nRevenue = MFCalcPosting(address.ad_addrid)
          IF NOT lp_oParams.LMultiProper
               l_lFound = (l_nRevenue >= lp_oParams.LNMinPosting)
          ENDIF
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.AbIds)
          SELECT adrtoin
          FOR i = 1 TO GETWORDCOUNT(lp_oParams.AbIds,",")
               l_nID = INT(VAL(GETWORDNUM(lp_oParams.AbIds,i,",")))
               LOCATE FOR ae_addrid = address.ad_addrid AND ae_abid = l_nID
               IF NOT FOUND()
                    l_lFound = .F.
                    EXIT
               ENDIF
          NEXT
     ENDIF
     IF l_lFound AND NOT EMPTY(lp_oParams.AiIds)
          SELECT adrtosi
          FOR i = 1 TO GETWORDCOUNT(lp_oParams.AiIds,",")
               l_nID = INT(VAL(GETWORDNUM(lp_oParams.AiIds,i,",")))
               LOCATE FOR ao_addrid = address.ad_addrid AND ao_aiid = l_nID
               IF NOT FOUND()
                    l_lFound = .F.
                    EXIT
               ENDIF
          NEXT
     ENDIF
     IF l_lFound
          IF INLIST(lp_oParams.l_nIncludeApartners,1,2)
               SELECT address
               SCATTER FIELDS &l_cRptFields MEMO NAME l_oAddress
               l_oAddress.ad_feat1 = FNGetAddressFeature(ad_addrid, 1)
               l_oAddress.ad_feat2 = FNGetAddressFeature(ad_addrid, 2)
               l_oAddress.ad_feat3 = FNGetAddressFeature(ad_addrid, 3)
               IF lp_oParams.LMultiProper
                    l_oAddress.ad_addrid = ad_adid
               ENDIF
               INSERT INTO curReport FROM NAME l_oAddress
               IF TYPE("curReport.c_stayed") = "N"
                    REPLACE c_cond WITH l_lMpCondition, c_stayed WITH l_nStayed, c_nights WITH l_nSumNights, c_revenue WITH l_nRevenue IN curReport
               ENDIF
          ENDIF
          IF INLIST(lp_oParams.l_nIncludeApartners,1,3) AND SEEK(address.ad_addrid,'apartner','tag1')
               IF lp_oParams.LMultiProper AND VARTYPE(lp_oForm) = "O"
                    lp_oForm.MFAddApartners(address.ad_adid, lp_oParams)
               ELSE
                    MFAddApartners(lp_oForm, lp_oParams)
               ENDIF
          ENDIF
     ENDIF
ENDSCAN
******************** Delete temp files *************************************************************
*
ProcArchive("DeleteTempArchive", "histres")
*
****************************************************************************************************

IF l_cNear <> "ON"
     SET NEAR &l_cNear
ENDIF
IF NOT EMPTY(lp_cFullPath) AND USED("curReport")
     USE IN curReport
ENDIF

RETURN .T.
ENDPROC
*
PROCEDURE MFUseTables
IF NOT USED("address")
     USE address IN 0 SHARED
ENDIF
IF NOT USED("apartner")
     USE apartner IN 0 SHARED ORDER TAG Tag1
ENDIF
IF NOT USED("astat")
     USE astat IN 0 SHARED
ENDIF
IF NOT USED("adrprvcy")
     USE adrprvcy IN 0 SHARED
ENDIF
IF NOT USED("adrtoin")
     USE adrtoin IN 0 SHARED
ENDIF
IF NOT USED("adintrst")
     USE adintrst IN 0 SHARED
ENDIF
IF NOT USED("adrfeat")
     USE adrfeat IN 0 SHARED
ENDIF
IF NOT USED("histstat")
     USE histstat IN 0 SHARED
ENDIF
IF NOT USED("adrtosi")
     USE adrtosi IN 0 SHARED
ENDIF
IF NOT USED("adrstint")
     USE adrstint IN 0 SHARED
ENDIF
IF NOT USED("roomtype")
     USE roomtype IN 0 SHARED ORDER TAG Tag1
ENDIF
IF NOT USED("histres")
     USE histres IN 0 SHARED ORDER TAG Tag3
     SET RELATION TO hr_roomtyp INTO roomtype IN histres
ENDIF
IF NOT USED("reservat")
     USE reservat IN 0 SHARED
ENDIF
IF NOT USED("param")
     USE param IN 0 SHARED
ENDIF
IF NOT USED("param2")
     USE param2 IN 0 SHARED
ENDIF
ENDPROC
*
PROCEDURE MFInsertIntoDocument
LPARAMETERS lp_cText, lp_dSysDate, lp_cTime, lp_cUserId, lp_lMultiProper
LOCAL l_curDocument, l_cAdrField

IF NOT USED("address")
     USE address IN 0 SHARED
ENDIF
IF NOT USED("document")
     USE document IN 0 SHARED
ENDIF
l_curDocument = SYS(2015)
l_cAdrField = IIF(lp_lMultiProper, "ad_adid", "ad_addrid")
SELECT address.ad_addrid AS dc_addrid, lp_cText AS dc_descr, lp_dSysDate AS dc_date, lp_cTime AS dc_time, lp_cUserId AS dc_userid FROM curReport ;
     INNER JOIN address ON address.&l_cAdrField = curReport.ad_addrid ;
     GROUP BY dc_addrid ;
     INTO CURSOR &l_curDocument

SELECT document
APPEND FROM DBF(l_curDocument)
DClose(l_curDocument)
DClose("curReport")

RETURN .T.
ENDPROC
*
PROCEDURE MFCalcPosting
LPARAMETERS lp_addrid, lp_nAmount
LOCAL i, l_nAmount, l_nFirstYear, l_nLastYear, l_nSelect
l_nSelect = SELECT()

IF .f.
     * more precise but too slower, not used astat and histat.dbfs.
     l_curReservat = SYS(2015)
     l_curAstat = SYS(2015)
     SELECT DISTINCT rs_reserid FROM reservat ;
          WHERE rs_addrid = lp_addrid OR rs_compid = lp_addrid OR rs_agentid = lp_addrid ;
     UNION ;
     SELECT hr_reserid FROM histres ;
          WHERE hr_addrid = lp_addrid OR hr_compid = lp_addrid OR hr_agentid = lp_addrid ;
          INTO CURSOR (l_curReservat)

     SELECT SUM(ps_amount) AS aa_camount FROM ( ;
          SELECT ps_amount FROM post INNER JOIN (l_curReservat) ON rs_reserid = ps_origid ;
               WHERE NOT ps_cancel AND ps_artinum > 0 AND (EMPTY(ps_ratecod) OR ps_split) ;
          UNION ALL ;
          SELECT hp_amount FROM histpost INNER JOIN (l_curReservat) ON rs_reserid = hp_origid ;
               WHERE NOT hp_cancel AND hp_artinum > 0 AND (EMPTY(hp_ratecod) OR hp_split)) a ;
          INTO CURSOR (l_curAstat)
     l_nAmount = &l_curAstat..aa_camount
     DClose(l_curReservat)
     DClose(l_curAstat)
ELSE
     l_nAmount = 0
     IF SEEK(PADL(lp_addrid,8,"0"),"histstat","tag2")
          SELECT histstat
          LOCATE FOR NOT EMPTY(aa_date) REST WHILE aa_addrid = lp_addrid
          IF FOUND()
               l_nFirstYear = YEAR(histstat.aa_date)
               SET ORDER TO tag2 DESCENDING
               =SEEK(PADL(lp_addrid,8,"0"))
               LOCATE FOR NOT EMPTY(aa_date) REST WHILE aa_addrid = lp_addrid
               IF FOUND()
                    l_nLastYear = YEAR(histstat.aa_date)
                    l_nAmount = l_nAmount + histstat.aa_camount
                    FOR i = l_nFirstYear TO l_nLastYear-1
                         =SEEK(PADL(lp_addrid,8,"0")+DTOS(DATE(i,12,31)))
                         IF i = YEAR(histstat.aa_date)
                              l_nAmount = l_nAmount + histstat.aa_camount
                         ENDIF
                    ENDFOR
               ENDIF
               SET ORDER TO tag2 ASCENDING
          ENDIF
     ENDIF
     IF SEEK(PADL(lp_addrid,8,"0"),"astat","tag2")
          SELECT astat
          LOCATE FOR NOT EMPTY(aa_date) REST WHILE aa_addrid = lp_addrid
          IF FOUND()
               l_nFirstYear = YEAR(astat.aa_date)
               SET ORDER TO tag2 DESCENDING
               =SEEK(PADL(lp_addrid,8,"0"))
               LOCATE FOR NOT EMPTY(aa_date) REST WHILE aa_addrid = lp_addrid
               IF FOUND()
                    l_nLastYear = YEAR(astat.aa_date)
                    l_nAmount = l_nAmount + astat.aa_camount
                    FOR i = l_nFirstYear TO l_nLastYear-1
                         =SEEK(PADL(lp_addrid,8,"0")+DTOS(DATE(i,12,31)))
                         IF i = YEAR(astat.aa_date)
                              l_nAmount = l_nAmount + astat.aa_camount
                         ENDIF
                    ENDFOR
               ENDIF
          SET ORDER TO tag2 ASCENDING
          ENDIF
     ENDIF
ENDIF

SELECT (l_nSelect)
lp_nAmount = l_nAmount
RETURN l_nAmount
ENDPROC
*
PROCEDURE MFCalcNightStayed
LPARAMETERS lp_addrid, lp_nCount
LOCAL l_nSelect

l_nSelect = SELECT()

lp_nCount = 0
SELECT CAST(COUNT(*) AS Numeric(8)) AS c_stays ;
          FROM histres ;
          INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp AND rt_group IN (1,4) ;
          WHERE (hr_addrid = lp_addrid OR hr_compid = lp_addrid OR hr_agentid = lp_addrid) AND ;
          hr_depdate >= hr_arrdate AND hr_status = 'OUT' ;
          INTO CURSOR cursns77610
lp_nCount = cursns77610.c_stays
dclose("cursns77610")

SELECT (l_nSelect)

RETURN lp_nCount
ENDPROC
*
PROCEDURE MFCalcSumNightStayed
LPARAMETERS lp_addrid, lp_nSum
LOCAL l_nSelect

l_nSelect = SELECT()

lp_nSum = 0
SELECT CAST(SUM(hr_depdate - hr_arrdate) AS Numeric(8)) AS c_sum ;
          FROM histres ;
          INNER JOIN roomtype ON hr_roomtyp = rt_roomtyp AND rt_group IN (1,4) ;
          WHERE (hr_addrid = lp_addrid OR hr_compid = lp_addrid OR hr_agentid = lp_addrid) AND ;
          hr_depdate > hr_arrdate AND hr_status = 'OUT' ;
          INTO CURSOR cursns77611
lp_nSum = cursns77611.c_sum
dclose("cursns77611")

SELECT (l_nSelect)

RETURN lp_nSum
ENDPROC
*
PROCEDURE MFAddApartners
LPARAMETERS lp_oForm, lp_oParams, lp_aData
EXTERNAL ARRAY lp_aData
LOCAL i, l_nSelect, l_cAlias, l_lMultiProper, l_cRptFields, l_oAddress, l_cMacro
l_nSelect = SELECT()
l_lMultiProper = (PCOUNT()>2)

IF SEEK(address.ad_addrid,'apartner','tag1')
     IF NOT USED("curReport") AND FILE(lp_oForm.cTmpData)
          USE (lp_oForm.cTmpData) IN 0 ALIAS curReport
     ENDIF
     IF l_lMultiProper
          l_cAlias = "curApTmp8012"
          SELECT * FROM curReport WHERE 0=1 INTO CURSOR (l_cAlias) READWRITE
     ELSE
          l_cAlias = "curReport"
     ENDIF
     l_cRptFields = lp_oParams.RptFields1 + lp_oParams.RptFields2
     SELECT apartner
     SCAN REST WHILE address.ad_addrid = ap_addrid
          IF _screen.GO AND (NOT Dlocate("adrprvcy", "ap_addrid = " + SqlCnv(ap_addrid,.T.)) OR adrprvcy.ap_consent < 2)
               LOOP
          ENDIF
          SELECT address
          SCATTER FIELDS &l_cRptFields MEMO NAME l_oAddress
          IF l_lMultiProper
               l_oAddress.ad_addrid = ad_adid
          ENDIF
          FOR i = 1 TO GETWORDCOUNT(lp_oParams.AdApFlds,",")
               l_cMacro = "l_oAddress." + STRTRAN(GETWORDNUM(lp_oParams.AdApFlds,i,",")," "," = apartner.")
               &l_cMacro
          NEXT
          INSERT INTO (l_cAlias) FROM NAME l_oAddress
          REPLACE ap_apid WITH apartner.ap_apid IN (l_cAlias)
          SELECT apartner
     ENDSCAN
     IF l_lMultiProper
          IF RECCOUNT(l_cAlias)>0
               SELECT * FROM (l_cAlias) INTO ARRAY lp_aData
          ENDIF
          dclose(l_cAlias)
     ENDIF
ENDIF

SELECT (l_nSelect)
RETURN .T.
ENDPROC
*