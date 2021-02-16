 LPARAMETERS lp_cFuncName, lp_uParam1, lp_uParam2, lp_uParam3, lp_uParam4, lp_uParam5, ;
               lp_uParam6, lp_uParam7, lp_uParam8, lp_uParam9, lp_uParam10, lp_uParam11, lp_uParam12, lp_uParam13, ;
               lp_uParam14, lp_uParam15, lp_uParam16, lp_uParam17, lp_uParam18, lp_uParam19
 LOCAL l_cCallProc, l_nParamNo, l_uRetVal
 l_cCallProc = lp_cFuncName + "("
 FOR l_nParamNo = 1 TO PCOUNT()-1
     l_cCallProc = l_cCallProc + IIF(l_nParamNo = 1, "", ", ") + "@lp_uParam" + ALLTRIM(STR(l_nParamNo))
 NEXT
 l_cCallProc = l_cCallProc + ")"
 l_uRetVal = &l_cCallProc
 RETURN l_uRetVal
ENDFUNC
*
PROCEDURE BqPost
 PRIVATE naRea, ntOid, ntOwindow
 naRea = SELECT()
 IF doPen("Banquet")
      SELECT baNquet
      SET ORDER TO 1
      IF dlOcate("Banquet","bq_reserid = "+sqLcnv(reServat.rs_reserid))
           WAIT WINDOW NOWAIT "Posting Banqueting..."
           SCAN REST FOR  .NOT. EMPTY(bq_artinum) .AND.  .NOT.  ;
                EMPTY(bq_price) .AND.  .NOT. EMPTY(bq_units) .AND.  ;
                bq_calc WHILE bq_reserid=reServat.rs_reserid
                ntOid = reServat.rs_reserid
                ntOwindow = 1
                DO biLlinstr IN BillInst WITH baNquet.bq_artinum,  ;
                   reServat.rs_billins, ntOid, ntOwindow
                = poStart(ntOid,ntOwindow,baNquet.bq_artinum, ;
                  baNquet.bq_units,baNquet.bq_price,baNquet.bq_descrip,"")
           ENDSCAN
           WAIT CLEAR
      ENDIF
      IF !g_newversionactive
          = dcLose("Banquet")
      ENDIF
 ENDIF
 SELECT (naRea)
 RETURN
ENDPROC
*
PROCEDURE checkresource
LPARAMETERS lp_cResAlias
LOCAL l_oCR AS cCheckResource OF banquet.prg

l_oCR = CREATEOBJECT("cCheckResource",lp_cResAlias)
IF NOT l_oCR.IsAvailable()
     alert(l_oCR.cMessage)
ENDIF

RETURN .T.
ENDPROC
*
DEFINE CLASS cCheckResource AS Custom
*
lAvailable = .T.
cMessage = ""
nRsId = 0
dArrDate = {}
dDepDate = {}
cResArrTime = ""
cResDepTime = ""
*
PROCEDURE Init
LPARAMETERS lp_cResAlias
this.nRsId = &lp_cResAlias..rs_rsid
this.dArrDate = &lp_cResAlias..rs_arrdate
this.dDepDate = &lp_cResAlias..rs_depdate
this.cResArrTime = IIF(VAL(&lp_cResAlias..rs_arrtime)=0,"00:00",&lp_cResAlias..rs_arrtime)
this.cResDepTime = IIF(VAL(&lp_cResAlias..rs_deptime)=0,"24:00",&lp_cResAlias..rs_deptime)
RETURN .T.
ENDPROC
*
PROCEDURE IsAvailable
LOCAL l_cCurList, l_nCapacityUsed, l_cCurOne, l_cSql, l_cFromTime, l_cToTime

TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
SELECT rl_artinum, <<"ar_lang"+g_langnum>> AS c_lang, pl_numval AS c_rescap, SUM(rl_units) AS c_qty 
     FROM ressplit 
     INNER JOIN article ON rl_artinum = ar_artinum AND ar_resourc <> '   ' 
     INNER JOIN picklist ON pl_label = 'RESOURCE' AND ar_resourc = pl_charcod AND pl_numval>0 
     WHERE rl_rsid = <<TRANSFORM(this.nRsId)>> 
     GROUP BY 1,2,3 
     HAVING SUM(rl_units) > 0 
     ORDER BY 1 
ENDTEXT

l_cCurList = sqlcursor(l_cSql)

SCAN ALL

     l_nCapacityUsed = &l_cCurList..c_qty

     TEXT TO l_cSql TEXTMERGE NOSHOW PRETEXT 15
     SELECT rs_arrtime, rs_deptime, SUM(rl_units) AS c_qty 
          FROM ressplit 
          INNER JOIN reservat ON rl_rsid = rs_rsid AND NOT INLIST(rs_status, 'CXL', 'NS', 'OUT') 
          INNER JOIN roomtype ON rs_roomtyp = rt_roomtyp 
          WHERE rl_rdate BETWEEN <<sqlcnv(this.dArrDate,.T.)>> AND <<sqlcnv(this.dDepDate,.T.)>> AND rl_artinum = <<TRANSFORM(EVALUATE(l_cCurList+".rl_artinum"))>> AND 
          rl_rsid <> <<TRANSFORM(this.nRsId)>> AND rt_group = 2 
          GROUP BY 1,2 
          HAVING SUM(rl_units)>0 
          ORDER BY 1,2 
     ENDTEXT

     l_cCurOne = sqlcursor(l_cSql)

     SCAN ALL

          l_cFromTime = IIF(VAL(rs_arrtime)=0, "00:00", rs_arrtime)
          l_cToTime = IIF(VAL(rs_deptime)=0, "24:00", rs_deptime)
          IF l_cFromTime <= this.cResDepTime AND l_cToTime >= this.cResArrTime
               l_nCapacityUsed = l_nCapacityUsed + c_qty
          ENDIF

     ENDSCAN

     IF l_nCapacityUsed>&l_cCurList..c_rescap
          this.AddMessage(&l_cCurList..c_lang, &l_cCurList..c_rescap, l_nCapacityUsed)
     ENDIF

     dclose(l_cCurOne)

ENDSCAN

dclose(l_cCurList)

RETURN this.lAvailable
ENDPROC
*
PROCEDURE AddMessage
LPARAMETERS lp_cArtiLang, lp_nCapacity, lp_nCapacityUsed

IF this.lAvailable
     this.lAvailable = .F.
ENDIF

this.cMessage = this.cMessage + ;
     stRfmt(GetLangText("BANQUET","TA_RSCCAPACITY"), ALLTRIM(lp_cArtiLang), lp_nCapacity, lp_nCapacityUsed) + CHR(13)

RETURN .T.
ENDPROC
*
ENDDEFINE
*