*
PROCEDURE ADPurge
 PRIVATE noLdarea
 PRIVATE lnOsave, liNcomplete, lnOstreet, lnOcity, lnOzip, dlAststay, ltEstrun, lNotInHistory, lnOemail
 PRIVATE cfIlter
 LOCAL l_oDlgData, l_lStartBtn, l_nNoAddressId, l_Continue
 l_nNoAddressId = -9999999
 l_oDlgData = CREATEOBJECT("cdatatunnel")
WITH  l_oDlgData
     .AddProperty("lSave", .F.)
     .AddProperty("lStreet", .F.)
     .AddProperty("lCity", .F.)
     .AddProperty("lZip", .F.)
     .AddProperty("lEmail", .F.)
     .AddProperty("lIncomplete", .F.)
     .AddProperty("lTestRun", .T.)
     .AddProperty("lNotInHistory", .F.)
     .AddProperty("dLastStay", {})
     .AddProperty("lStartBtn", .F.)
     DO FORM "forms\adpurge" WITH l_oDlgData
     lNoSave = .lSave
     lNoStreet = .lStreet
     lNoCity = .lCity
     lNoZip = .lZip
     lnOemail = .lEmail
     lIncomplete = .lIncomplete
     lTestRun = .lTestRun
     lNotInHistory = .lNotInHistory
     dLastStay = .dLastStay
     l_lStartBtn = .lStartBtn
ENDWITH
IF l_lStartBtn
      l_Continue = .F.
      IF lNoSave .OR. ;
                (liNcomplete .AND. (lnOstreet .OR. lnOzip .OR. lnOcity .OR. lnOemail)) .OR. ;
                .NOT. EMPTY(dlAststay)
           IF lTestRun
                l_Continue = .T.
           ELSE
                IF yeSno(GetLangText("ADPURGE","TA_MADEBACKUP")+'@2')
                     IF yeSno(GetLangText("ADPURGE","TA_AREYOUSURE")+'@2')
                          l_Continue = .T.
                     ENDIF
                ENDIF
           ENDIF
     ENDIF
     IF l_Continue
           clOgmsg = stRfmt("ADDRESS CLEANUP STARTED BY '%s1' AT %s2", ;
                     TRIM(g_Userid),TTOC(DATETIME()))+CHR(13)+CHR(10)+ ;
                     '  NOSAVE     = '+cnV(lnOsave)+CHR(13)+CHR(10)+ ;
                     '  INCOMPLETE = '+cnV(liNcomplete)+CHR(13)+CHR(10)+ ;
                     '  NOSTREET   = '+cnV(lnOstreet)+CHR(13)+CHR(10)+ ;
                     '  NOZIP      = '+cnV(lnOzip)+CHR(13)+CHR(10)+ ;
                     '  NOCITY     = '+cnV(lnOcity)+CHR(13)+CHR(10)+ ;
                     '  NOHISTORY  = '+cnV(lNotInHistory)+CHR(13)+CHR(10)+ ;
                     '  LASTSTAY   = '+cnV(dlAststay)+CHR(13)+CHR(10)+ ;
                     '  TESTRUN    = '+cnV(ltEstrun)
           loGdata(clOgmsg,'Hotel.LOG')
           openfiledirect(.F., "reservat", "rs")
           openfiledirect(.F., "aracct", "ac")
           openfiledirect(.F., "address", "ad")
           openfiledirect(.F., "althead", "al")
           openfiledirect(.F., "histres", "hr")
           openfiledirect(.F., "hresext", "hre")
           openfiledirect(.F., "ledgpost", "ld")
           openfiledirect(.F., "pswindow", "pw")
           openfiledirect(.F., "hpwindow", "hw")
           openfiledirect(.F., "action", "at2985")
           openfiledirect(.F., "adrrates", "adrrates2985")
           openfiledirect(.F., "adrtoin", "adrtoin2985")
           openfiledirect(.F., "adrtosi", "adrtosi2985")
           openfiledirect(.F., "apartner", "apartner2985")
           openfiledirect(.F., "astat", "astat2985")
           openfiledirect(.F., "billnum", "billnum2985")
           openfiledirect(.F., "bsacct", "bsacct2985")
           openfiledirect(.F., "bscard", "bscard2985")
           openfiledirect(.F., "document", "document2985")
           openfiledirect(.F., "einboxsn", "einboxsn2985")
           openfiledirect(.F., "esentrcp", "esentrcp2985")
           openfiledirect(.F., "exterror", "exterror2985")
           openfiledirect(.F., "extreser", "extreser2985")
           openfiledirect(.F., "histstat", "histstat2985")
           openfiledirect(.F., "jetweb", "jetweb2985")
           openfiledirect(.F., "laststay", "laststay2985")
           openfiledirect(.F., "phnote", "phnote2985")
           openfiledirect(.F., "post", "ps2985")
           openfiledirect(.F., "postcxl", "postcxl2985")
           openfiledirect(.F., "rescfgue", "rescfgue2985")
           openfiledirect(.F., "voucher", "voucher2985")
           openfiledirect(.F., "adrphone", "adrphone2985")
           SELECT ad
           ndEleted = 0
           ncOunt = RECCOUNT()
           SCAN FOR ad_addrid <> -9999999
                WAIT WINDOW NOWAIT LTRIM(TRIM(ad_company)+' '+TRIM(ad_lname))
                IF lnOsave .AND. ad_save
                     LOOP
                ENDIF
                IF liNcomplete
                     IF lnOstreet .AND.  .NOT. EMPTY(ad_street+ad_street2)
                          LOOP
                     ENDIF
                     IF lnOzip .AND.  .NOT. EMPTY(ad_zip)
                          LOOP
                     ENDIF
                     IF lnOcity .AND.  .NOT. EMPTY(ad_city)
                          LOOP
                     ENDIF
                     IF lnOemail .AND.  .NOT. EMPTY(ad_email)
                          LOOP
                     ENDIF
                ENDIF
                IF  .NOT. EMPTY(dlAststay)
                     lsTayfailed = .F.
                     SELECT hr
                     SCAN ALL FOR hr_addrid=ad.ad_addrid .OR. hr_compid= ;
                          ad.ad_addrid .OR. hr_agentid=ad.ad_addrid OR (SEEK(hr.hr_rsid,"hre","tag3") AND hre.rs_saddrid=ad.ad_addrid)
                          IF hr_depdate>=dlAststay
                               lsTayfailed = .T.
                               EXIT
                          ENDIF
                     ENDSCAN
                     SELECT ad
                     IF lsTayfailed
                          LOOP
                     ENDIF
                ENDIF
                IF lNotInHistory
                     SELECT hr
                     LOCATE ALL FOR hr_addrid=ad.ad_addrid .OR. hr_compid= ;
                          ad.ad_addrid .OR. hr_agentid=ad.ad_addrid OR (SEEK(hr.hr_rsid,"hre","tag3") AND hre.rs_saddrid=ad.ad_addrid)
                     IF FOUND()
                          SELECT ad
                          LOOP
                     ENDIF
                     SELECT hw
                     LOCATE ALL FOR pw_addrid=ad.ad_addrid
                     IF FOUND()
                          SELECT ad
                          LOOP
                     ENDIF
                ENDIF
                SELECT rs
                LOCATE ALL FOR rs_addrid=ad.ad_addrid .OR. rs_compid= ;
                       ad.ad_addrid .OR. rs_agentid=ad.ad_addrid .OR.  ;
                       rs_invid=ad.ad_addrid .OR. rs_saddrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT pw
                LOCATE ALL FOR pw_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT ac
                LOCATE ALL FOR ac_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT al
                LOCATE ALL FOR al_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT ld
                LOCATE ALL FOR ld_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT billnum2985
                LOCATE ALL FOR bn_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT bsacct2985
                LOCATE ALL FOR bb_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT bscard2985
                LOCATE ALL FOR bc_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                SELECT voucher2985
                LOCATE ALL FOR vo_addrid=ad.ad_addrid
                IF FOUND()
                     SELECT ad
                     LOOP
                ENDIF
                ndEleted = ndEleted+1
                IF  .NOT. ltEstrun
                     SELECT hr
                     REPLACE hr_addrid WITH l_nNoAddressId ALL FOR hr_addrid= ;
                             ad.ad_addrid
                     REPLACE hr_compid WITH l_nNoAddressId ALL FOR hr_compid= ;
                             ad.ad_addrid
                     REPLACE hr_agentid WITH l_nNoAddressId ALL FOR hr_agentid= ;
                             ad.ad_addrid
                     REPLACE rs_saddrid WITH l_nNoAddressId ALL FOR rs_saddrid= ;
                             ad.ad_addrid IN hre
                     FLUSH
                     SELECT at2985
                     REPLACE at_addrid WITH l_nNoAddressId ALL FOR at_addrid = ad.ad_addrid
                     SELECT ps2985
                     REPLACE ps_addrid WITH l_nNoAddressId ALL FOR ps_addrid = ad.ad_addrid
                     SELECT postcxl2985
                     REPLACE ps_addrid WITH l_nNoAddressId ALL FOR ps_addrid = ad.ad_addrid
                     
                     
                     DELETE FOR af_addrid = ad.ad_addrid IN adrrates2985
                     DELETE FOR ae_addrid = ad.ad_addrid IN adrtoin2985
                     DELETE FOR ao_addrid = ad.ad_addrid IN adrtosi2985
                     DELETE FOR ap_addrid = ad.ad_addrid IN apartner2985
                     DELETE FOR aa_addrid = ad.ad_addrid IN astat2985
                     DELETE FOR dc_addrid = ad.ad_addrid IN document2985
                     DELETE FOR eb_addrid = ad.ad_addrid IN einboxsn2985
                     DELETE FOR ec_addrid = ad.ad_addrid IN esentrcp2985
                     DELETE FOR er_addrid = ad.ad_addrid IN exterror2985
                     DELETE FOR er_addrid = ad.ad_addrid IN extreser2985
                     DELETE FOR aa_addrid = ad.ad_addrid IN histstat2985
                     DELETE FOR jw_addrid = ad.ad_addrid IN jetweb2985
                     DELETE FOR ls_addrid = ad.ad_addrid IN laststay2985
                     DELETE FOR ph_addrid = ad.ad_addrid IN phnote2985
                     DELETE FOR rj_addrid = ad.ad_addrid IN rescfgue2985
                     DELETE FOR aj_addrid = ad.ad_addrid IN adrphone2985
                     SELECT ad
                     DELETE
                     FLUSH
                ENDIF
           ENDSCAN
           USE IN ad
           USE IN ac
           USE IN al
           USE IN rs
           USE IN hr
           USE IN ld
           USE IN pw
           USE IN hw
           dclose("hre")
           dclose("at2985")
           dclose("adrrates2985")
           dclose("adrtoin2985")
           dclose("adrtosi2985")
           dclose("apartner2985")
           dclose("astat2985")
           dclose("billnum2985")
           dclose("bsacct2985")
           dclose("bscard2985")
           dclose("document2985")
           dclose("einboxsn2985")
           dclose("esentrcp2985")
           dclose("exterror2985")
           dclose("extreser2985")
           dclose("histstat2985")
           dclose("jetweb2985")
           dclose("laststay2985")
           dclose("phnote2985")
           dclose("ps2985")
           dclose("postcxl2985")
           dclose("rescfgue2985")
           dclose("adrphone2985")
           dclose("voucher2985")
           IF ltEstrun
                alErt(stRfmt(GetLangText("ADPURGE","TA_TESTDONE"),ndEleted,ncOunt))
           ELSE
                alErt(stRfmt(GetLangText("ADPURGE","TA_DONE"),ndEleted,ncOunt))
           ENDIF
      ELSE
           alErt(GetLangText("ADPURGE","TA_NOCRITERIA"))
      ENDIF
ENDIF
RETURN .T.
ENDPROC
*
