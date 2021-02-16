FUNCTION SqlParse
LPARAMETER tcExpression, tlOdbc, lp_lSqlRemote, tlExternalODBC
LOCAL l_lSqlRemote
IF "__#" $ tcExpression
     tcExpression = SqlParseTables(tcExpression, .T.)
ENDIF
IF tlOdbc AND (Odbc() OR tlExternalODBC)
     RETURN SqlParseB(tcExpression)
ENDIF

IF lp_lSqlRemote OR NOT EMPTY(gcUseDatabase)
     l_lSqlRemote = .T.
ENDIF
tcExpression = STRTRAN(tcExpression, "__EMPTY_DATE__", "{}")
tcExpression = STRTRAN(tcExpression, "__EMPTY_DATETIME__","{.. :}")
tcExpression = STRTRAN(tcExpression, "__MAX__", "MAX")
tcExpression = STRTRAN(tcExpression, "__STR__", "STR")
tcExpression = STRTRAN(tcExpression, "__||__", "+")
tcExpression = STRTRAN(tcExpression, "__LOGICAL__", "LOGICAL")
tcExpression = STRTRAN(tcExpression, "__MEMO__", "MEMO")
IF NOT l_lSqlRemote
     tcExpression = STRTRAN(tcExpression, "__SQLPARAM__", "")
ENDIF
tcExpression = STRTRAN(tcExpression, "__ARGUSTABLE__", "AO")
tcExpression = STRTRAN(tcExpression, "__SQLSTRTRAN__", "STRTRAN")
IF "=__NULL__" $ tcExpression
     tcExpression = SqlIsNullVfp(tcExpression)
ENDIF

RETURN tcExpression
ENDFUNC
*
FUNCTION SqlIsNullVfp
LPARAMETER tcExpression
LOCAL i, lnPos, lcNullExpr

lnPos = AT("=__NULL__", tcExpression)
FOR i = lnPos TO 1 STEP -1
     IF INLIST(SUBSTR(tcExpression,i,1), " ", "(")
          lcNullExpr = SUBSTR(tcExpression, i+1, lnPos-i-1)
          tcExpression = STRTRAN(tcExpression, lcNullExpr + "=__NULL__", " ISNULL(" + lcNullExpr + ")")
          EXIT
     ENDIF
ENDFOR

RETURN tcExpression
ENDFUNC
*
FUNCTION SqlParseTables
LPARAMETERS tcSql, tlAddAlias, tlDontAddPath
LOCAL lcSql, lcTableCode, lcTable, lcDbCode, lcUseDatabase, loDatabaseProp, llUseRemoteServerForSql

IF TYPE("_screen.oGlobal.luseremoteserverforsql") <> "L" OR _screen.oGlobal.luseremoteserverforsql
     llUseRemoteServerForSql = .T.
ENDIF

tlAddAlias = tlAddAlias AND ("SELECT " == UPPER(LEFT(tcSql,7)))     && Only for SQL SELECT statements
lcSql = tcSql
DO WHILE NOT EMPTY(STREXTRACT(lcSql, "__#", "#__", 1))
     lcTableCode = STREXTRACT(lcSql, "__#", "#__", 1)
     lcDbCode = STREXTRACT(lcTableCode, "", ".")
     lcUseDatabase = lcDbCode
     loDatabaseProp = IIF(goDatabases.GetKey(lcDbCode) = 0, .NULL., goDatabases.Item(lcDbCode))
     IF lcDbCode = "SRV" AND ISNULL(loDatabaseProp)
          lcUseDatabase = "DESK"
          loDatabaseProp = IIF(goDatabases.GetKey("DESK") = 0, .NULL., goDatabases.Item("DESK"))
     ENDIF
     DO CASE
          CASE ISNULL(loDatabaseProp)
               lcTable = LOWER(STRTRAN(lcTableCode, lcDbCode+"."))
               gcUseDatabase = .NULL.
          CASE NOT EMPTY(loDatabaseProp.cPgSchema)
               lcTable = LOWER(STRTRAN(lcTableCode, lcDbCode+".", IIF(tlDontAddPath, "", loDatabaseProp.cPgSchema+".")))
               gcUseDatabase = ""
          CASE Odbc()
               lcTable = LOWER(STRTRAN(lcTableCode, lcDbCode+"."))
               gcUseDatabase = ""
          CASE EMPTY(loDatabaseProp.cServerName) OR EMPTY(loDatabaseProp.nServerPort) OR NOT llUseRemoteServerForSql
               lcTable = LOWER(STRTRAN(lcTableCode, lcDbCode+".", IIF(tlDontAddPath, "", loDatabaseProp.cDataFolder))) + ;
                    IIF(tlAddAlias AND NOT EMPTY(loDatabaseProp.cPrefix) AND EMPTY(GETWORDNUM(lcTableCode,2)), " " + loDatabaseProp.cPrefix + GETWORDNUM(lcTableCode,2,"."), "")
               gcUseDatabase = ""
          OTHERWISE
               lcTable = LOWER(STRTRAN(lcTableCode, lcDbCode+"."))
               gcUseDatabase = IIF(EMPTY(gcUseDatabase), lcUseDatabase, gcUseDatabase)
     ENDCASE
     lcSql = STRTRAN(lcSql, "__#"+lcTableCode+"#__", lcTable)
ENDDO

tcSql = lcSql     && Return by reference too.
RETURN lcSql
ENDFUNC
*
PROCEDURE SqlCnvB
LPARAMETERS lp_cValue, lp_cReplacement
LOCAL lvExp
lvExp = EVALUATE("lp_cValue")
DO CASE
     CASE INLIST(VARTYPE(lvExp), "N", "I", "B")
          lp_cReplacement = STRTRAN(TRANSFORM(ROUND(lvExp,6)),",",".")
     CASE VARTYPE(lvExp) = "Y"
          lp_cReplacement = "'$"+ALLTRIM(STR(lvExp,10,2))+"'"
     CASE VARTYPE(lvExp) = "D"
          IF EMPTY(lvExp)
               lp_cReplacement = "'16111111'" + "::date"
          ELSE
               lp_cReplacement = "'" + DTOS(lvExp) + "'" + "::date"
          ENDIF
     CASE VARTYPE(lvExp) = "T"
          IF EMPTY(lvExp)
               lp_cReplacement = "'1611-11-11 11:11:11'"
          ELSE
               lp_cReplacement = "'" + STRTRAN(TTOC(lvExp,3),"T"," ") + "'"
          ENDIF
     CASE INLIST(VARTYPE(lvExp), "C", "M")
          vExp = TRIM(lvExp)
          IF AT(['], lvExp)>0 OR AT([\], lvExp)>0
               lp_cReplacement = "$$" + TRIM(lvExp) + "$$"
          ELSE
               lp_cReplacement = "'" + TRIM(lvExp) + "'"
          ENDIF
     CASE VARTYPE(lvExp) = "L"
          lp_cReplacement = IIF(lvExp, "true", "false")
     OTHERWISE
          ASSERT .F. MESSAGE PROGRAM()
ENDCASE

RETURN lp_cReplacement
ENDPROC
*
PROCEDURE SqlParseB
LPARAMETERS pcsql
pcsql = STRTRAN(pcsql,"[]","_#ARRAY#_")
pcsql = STRTRAN(pcsql,"[","$$")
pcsql = STRTRAN(pcsql,"]","$$")
pcsql = STRTRAN(pcsql,"_#ARRAY#_","[]")
pcsql = STRTRAN(pcsql,'""',"''")
pcsql = STRTRAN(pcsql,'" "',"' '")
pcsql = STRTRAN(pcsql,"==","=")
pcsql = STRTRAN(pcsql, "__EMPTY_DATE__","'16111111'")
pcsql = STRTRAN(pcsql, "{}","'16111111'")
pcsql = STRTRAN(pcsql, "__EMPTY_DATETIME__","'1611-11-11 11:11:11'")
pcsql = STRTRAN(pcsql, "__MAX__","GREATEST")
pcsql = STRTRAN(pcsql, "PADR(","RPAD(")
pcsql = STRTRAN(pcsql, "PADL(","LPAD(")
pcsql = STRTRAN(pcsql, "__||__","||")
pcsql = STRTRAN(pcsql, "__LOGICAL__","BOOLEAN")
pcsql = STRTRAN(pcsql, "__MEMO__","TEXT")
pcsql = STRTRAN(pcsql, "__SQLPARAM__","?")
pcsql = STRTRAN(pcsql, "__ARGUSTABLE__","argus.")
pcsql = STRTRAN(pcsql, "__SQLSTRTRAN__","REPLACE")
IF "SELECT TOP " $ pcsql
     pcsql = SqlTopIntoLimit(pcsql)
ENDIF
IF "__STR__(" $ pcsql && Don't use STR( because of SUBSTR( !!!
     pcsql = SqlStr(pcsql)
ENDIF
IF "AS DOUBLE(" $ UPPER(pcsql)
     pcsql = SqlDouble(pcsql)
ENDIF
IF "NVL(" $ pcsql
     pcsql = SqlNvl(pcsql)
ENDIF
IF "EMPTY(" $ pcsql
     pcsql = SqlEmpty(pcsql)
ENDIF
IF "DTOS(" $ pcsql
     pcsql = SqlDtos(pcsql)
ENDIF
IF " AT(" $ pcsql OR "(AT(" $ pcsql
     pcsql = SqlAt(pcsql)
ENDIF
IF "INLIST(" $ pcsql
     pcsql = SqlInlist(pcsql)
ENDIF
IF "BETWEEN(" $ pcsql
     pcsql = SqlBetween(pcsql)
ENDIF
IF "IIF(" $ pcsql
     pcsql = SqlICase(pcsql,.T.)
ENDIF
IF "ICASE(" $ pcsql
     pcsql = SqlICase(pcsql)
ENDIF
IF "ISNULL(" $ pcsql
     pcsql = SqlIsNull(pcsql)
ENDIF
pcsql = STRTRAN(pcsql, "=__NULL__"," IS NULL")
pcsql = STRTRAN(pcsql, "__NULL__"," IS NULL")
RETURN pcsql
ENDPROC
*
PROCEDURE SqlTopIntoLimit
LPARAMETERS lp_cSql
LOCAL l_cTopNum, l_cSqlTopExpCompl, l_cSqlRes

l_cTopNum = ALLTRIM(GETWORDNUM(STREXTRACT(lp_cSql, "SELECT TOP "),1))
l_cSqlTopExpCompl = "SELECT TOP " + l_cTopNum
l_cSqlRes = STRTRAN(lp_cSql, l_cSqlTopExpCompl, "SELECT") + " LIMIT " + l_cTopNum

RETURN l_cSqlRes
ENDPROC
*
PROCEDURE SqlStr
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdStart = "__STR__("
l_cCmdEnd = ")"
DO WHILE l_cCmdStart $ l_cSql
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart, CHR(255))
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cCmdParams = STRTRAN(l_cCmdParams, GETWORDNUM(l_cCmdParams,2,CHR(255)), "REPEAT('9',"+GETWORDNUM(l_cCmdParams,2,CHR(255))+")")
     l_cCmdParams = STRTRAN(l_cCmdParams, CHR(255), ",")
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, "to_char(" + l_cCmdParams + ")")
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlDouble
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdStart = "AS DOUBLE("
l_cCmdEnd = ")"
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart)
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, "double precision")
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlNvl
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdStart = "NVL("
l_cCmdEnd = ")"
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart)
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, "COALESCE(" + l_cCmdParams + ")")
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlDtos
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdStart = "DTOS("
l_cCmdEnd = ")"
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = STREXTRACT(l_cSql, l_cCmdStart, l_cCmdEnd)
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, "to_char(" + l_cCmdParams + ",'YYYYMMDD')")
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlEmpty
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdStart = "EMPTY("
l_cCmdEnd = ")"
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart)
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, l_cCmdParams + "=''")
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlAt
LPARAMETERS lp_cSql
LOCAL i, l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdEnd = ")"
FOR i = 1 TO 2
     l_cCmdStart = IIF(i = 1, " ", "(") + "AT("
     DO WHILE l_cCmdStart $ UPPER(l_cSql)
          l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart, CHR(255))
          l_nStart = AT(l_cCmdStart, l_cSql)
          l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
          l_cCmdParams = STRTRAN(l_cCmdParams, CHR(255), " in ")
          l_cSql = STUFF(l_cSql, l_nStart, l_nChars, LEFT(l_cCmdStart,1) + "position(" + l_cCmdParams + ")")
     ENDDO
ENDFOR

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlInlist
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdEnd = ")"
l_cCmdStart = "INLIST("
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart, CHR(255))
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cCmdParams = GETWORDNUM(l_cCmdParams,1,CHR(255)) + " IN (" + STREXTRACT(l_cCmdParams,CHR(255),"",1,2) + ")"
     l_cCmdParams = STRTRAN(l_cCmdParams, CHR(255), ",")
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, l_cCmdParams)
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlBetween
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdEnd = ")"
l_cCmdStart = "BETWEEN("
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart, CHR(255))
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cCmdParams = GETWORDNUM(l_cCmdParams,1,CHR(255)) + " BETWEEN " + GETWORDNUM(l_cCmdParams,2,CHR(255)) + " AND " + GETWORDNUM(l_cCmdParams,3,CHR(255))
     l_cCmdParams = STRTRAN(l_cCmdParams, CHR(255), ",")
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, l_cCmdParams)
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlICase
LPARAMETERS lp_cSql, lp_lIif
LOCAL i, l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars, l_nParams

l_cSql = lp_cSql
l_cCmdStart = IIF(lp_lIif, "IIF(", "ICASE(")
l_cCmdEnd = ")"
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart, CHR(255))
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_nParams = GETWORDCOUNT(l_cCmdParams,CHR(255))
     FOR i = 2 TO l_nParams
          l_cCmdParams = STRTRAN(l_cCmdParams,CHR(255),ICASE(i = l_nParams, " ELSE ", MOD(i,2) = 0, " THEN ", " WHEN "),1,1)
     NEXT
     l_cCmdParams = STRTRAN(l_cCmdParams, CHR(255), ",")
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, " CASE WHEN " + l_cCmdParams + " END ")
ENDDO

RETURN l_cSql
ENDPROC
*
PROCEDURE SqlIsNull
LPARAMETERS lp_cSql
LOCAL l_cSql, l_cCmdStart, l_cCmdEnd, l_cCmdParams, l_nStart, l_nChars

l_cSql = lp_cSql
l_cCmdStart = "ISNULL("
l_cCmdEnd = ")"
DO WHILE l_cCmdStart $ UPPER(l_cSql)
     l_cCmdParams = ExtractFuncParams(l_cSql, l_cCmdStart)
     l_nStart = AT(l_cCmdStart, l_cSql)
     l_nChars = LEN(l_cCmdStart+l_cCmdParams+l_cCmdEnd)
     l_cSql = STUFF(l_cSql, l_nStart, l_nChars, l_cCmdParams + " ISNULL")
ENDDO

RETURN l_cSql
ENDPROC
*