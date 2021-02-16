PUBLIC goOdbcHandles, g_cFile
LOCAL oCA
SET MEMOWIDTH TO 200
SET ASSERTS ON
*SET PROCEDURE TO progs\sqlupdateb.prg
*SET PROCEDURE TO odbcclasses
*goOdbcHandles = CREATEOBJECT("codbchandler")
oCA = .NULL.
g_cFile = "common\progs\cadefdesk.prg"
IF NOT USED("files")
     USE data\files SHARED IN 0
ENDIF
SET ORDER TO 1 IN files
IF NOT USED("fields")
     USE data\fields SHARED IN 0
ENDIF
SET ORDER TO 1 IN fields

DELETE FILE (g_cFile)

SELECT files
SCAN FOR NOT fi_vfp AND NOT EMPTY(fi_unikey)
     GetCa(@oCA)
     oCA.CaName = "ca" + LOWER(ALLTRIM(fi_name))
     oCA.Alias = "ca" + LOWER(ALLTRIM(fi_name))
     oCA.Tables = LOWER(ALLTRIM(fi_name))
     IF .F. AND INLIST(PADR(oCA.Tables,8),"user    ","order   ","check   ","table   ","group   ")
          oCA.Tables = '"'+oCA.Tables+'"'
     ENDIF
     oCA.KeyFieldList = ALLTRIM(LOWER(fi_unikey))
     
     SELECT fields
     SCAN FOR fd_table = files.fi_name
          WriteFieldDescr(@oCA)
     ENDSCAN
     FinishFieldDescr(@oCA)
     WriteClassDefinition(@oCA)
ENDSCAN

ENDPROC
*
PROCEDURE GetCA
LPARAMETERS poCA
poCA = CREATEOBJECT("Empty")
ADDPROPERTY(poCA,"CaName", "")
ADDPROPERTY(poCA,"Alias", "")
ADDPROPERTY(poCA,"Tables", "")
ADDPROPERTY(poCA,"SelectCmd", "")
ADDPROPERTY(poCA,"CursorSchema", "")
ADDPROPERTY(poCA,"KeyFieldList", "")
ADDPROPERTY(poCA,"InsertCmdRefreshKeyFieldList", "")
ADDPROPERTY(poCA,"InsertCmdRefreshFieldList", "")
ADDPROPERTY(poCA,"InsertCmdRefreshCmd", "")
ADDPROPERTY(poCA,"UpdatableFieldList", "")
ADDPROPERTY(poCA,"UpdateNameList", "")
ADDPROPERTY(poCA,"Name", "")

RETURN .T.
ENDPROC
*
PROCEDURE WriteFieldDescr
LPARAMETERS poCA, plPKey
IF plPKey
*!*          poCA.KeyFieldList = ALLTRIM(LOWER(fd_name))
*!*          IF files.fi_autoinc
*!*               * set properties to automaticly receive serial value in cursor
*!*               poCA.InsertCmdRefreshKeyFieldList = poCA.KeyFieldList
*!*               poCA.InsertCmdRefreshFieldList = poCA.KeyFieldList
*!*               poCA.InsertCmdRefreshCmd = "SELECT currval('"+LOWER(TRIM(files.fi_name))+"_"+ALLTRIM(LOWER(files.fi_key))+"_seq');"
*!*          ELSE
*!*               poCA.UpdatableFieldList = poCA.UpdatableFieldList + ALLTRIM(LOWER(fd_name)) + ", "
*!*          ENDIF
*!*     ELSE
     
ENDIF

poCA.UpdatableFieldList = poCA.UpdatableFieldList + "    " + ALLTRIM(LOWER(fd_name)) + "," + CHR(13) + CHR(10)
poCA.SelectCmd = poCA.SelectCmd + "       " + ALLTRIM(LOWER(fd_name)) + "," + CHR(13) + CHR(10)
poCA.UpdateNameList = poCA.UpdateNameList + "    " + PADR(LOWER(fd_name),10) + " " + STRTRAN(poCA.Tables, '"') + "." + ALLTRIM(LOWER(fd_name)) + "," + CHR(13) + CHR(10)
poCA.CursorSchema = poCA.CursorSchema + "    " + PADR(LOWER(fd_name),10) + " " + PADR(GetFieldDesc(),7) + " " + GetDefaultValue() + "," + CHR(13) + CHR(10)
RETURN .T.
ENDPROC
*
PROCEDURE GetDefaultValue
LOCAL cDef
cDef = ""
DO CASE
     CASE fd_type="L"
          cDef = ".F."
     CASE INLIST(fd_type,"C","V","M")
          cDef = [""]
     CASE INLIST(fd_type,"N","B","Y","I")
          cDef = "0"
     CASE fd_type="D"
          cDef = "{}"
     CASE fd_type="T"
          cDef = "{}"
ENDCASE
IF NOT EMPTY(cDef)
     cDef = "DEFAULT " + cDef
ENDIF
RETURN cDef
ENDPROC
*
PROCEDURE GetFieldDesc
LOCAL cDesc
* Description of fields, for CREATE CURSOR command
DO CASE
     CASE INLIST(fd_type,"Y","D","T","I","L","M")
          cDesc = fd_type
     CASE INLIST(fd_type,"C","V")
          cDesc = fd_type + "(" + TRANSFORM(fd_len) + ")"
     CASE fd_type = "B"
          cDesc = fd_type + "(" + TRANSFORM(fd_dec) + ")"
     CASE INLIST(fd_type,"N","F")
          cDesc = fd_type + "(" + TRANSFORM(fd_len) + "," + TRANSFORM(fd_dec) + ")"
     OTHERWISE
          cDesc = ""
          ASSERT .F. MESSAGE PROGRAM()
ENDCASE
RETURN cDesc
ENDPROC
*
PROCEDURE FinishFieldDescr
LPARAMETERS poCA
LOCAL l_cTableName

IF INLIST(PADR(poCA.Tables,8),"user    ","order   ","check   ","table   ","group   ")
     l_cTableName = '"'+poCA.Tables+'"'
ELSE
     l_cTableName  = poCA.Tables
ENDIF
poCA.UpdatableFieldList = LEFT(poCA.UpdatableFieldList,LEN(poCA.UpdatableFieldList)-3)
poCA.SelectCmd =  LEFT(poCA.SelectCmd,LEN(poCA.SelectCmd)-3)
poCA.UpdateNameList = LEFT(poCA.UpdateNameList,LEN(poCA.UpdateNameList)-3)
poCA.CursorSchema = LEFT(poCA.CursorSchema,LEN(poCA.CursorSchema)-3)
RETURN .T.
ENDPROC
*
PROCEDURE WriteClassDefinition
LPARAMETERS poCA
LOCAL lcDef, l_cAdditionalProperties
l_cAdditionalProperties = ""
IF NOT EMPTY(poCA.InsertCmdRefreshKeyFieldList)
     l_cAdditionalProperties = l_cAdditionalProperties + CHR(13) + CHR(10) + ;
               "this.InsertCmdRefreshKeyFieldList = " + GetTruncated(poCA.InsertCmdRefreshKeyFieldList)
    
ENDIF
IF NOT EMPTY(poCA.InsertCmdRefreshFieldList)
     l_cAdditionalProperties = l_cAdditionalProperties + CHR(13) + CHR(10) + ;
               "this.InsertCmdRefreshFieldList = " + GetTruncated(poCA.InsertCmdRefreshFieldList)
    
ENDIF
IF NOT EMPTY(poCA.InsertCmdRefreshCmd)
     l_cAdditionalProperties = l_cAdditionalProperties + CHR(13) + CHR(10) + ;
               "this.InsertCmdRefreshCmd = " + GetTruncated(poCA.InsertCmdRefreshCmd)
    
ENDIF

TEXT TO lcDef TEXTMERGE NOSHOW &&PRETEXT 2 + 8

DEFINE CLASS <<poCA.CaName>> AS caBase OF cit_ca.vcx
Alias = [<<poCA.Alias>>]
Tables = [<<poCA.Tables>>]
KeyFieldList = [<<poCA.KeyFieldList>>]
PROCEDURE SetCommandProps
*TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
<<poCA.SelectCmd>>
    FROM <<poCA.Tables>>
*ENDTEXT
*TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
<<poCA.CursorSchema>>
*ENDTEXT
*TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
<<poCA.UpdatableFieldList>>
*ENDTEXT
*TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
<<poCA.UpdateNameList>>
*ENDTEXT
<<l_cAdditionalProperties>>
DODEFAULT()
ENDPROC
ENDDEFINE
ENDTEXT
lcDef = STRTRAN(lcDef, "*") + CHR(13) + CHR(10) + "*" + CHR(13) + CHR(10)
STRTOFILE(lcDef,g_cFile,1)
ENDPROC
*
PROCEDURE GetTruncated
LPARAMETERS pctext
LOCAL i, ctruncated, nlin
ctruncated = ''
nlin = MEMLINES(pctext)
FOR i = 1 TO nlin
     DO CASE
          CASE i = nlin
               * last line
               ctruncated = ctruncated + IIF(nlin=1,'',SPACE(5)) + '[' + MLINE(pctext,i) + ']' + CHR(13) + CHR(10)
          CASE i = 1
               * first line
               ctruncated = '[' + MLINE(pctext,i) + '] + ;' + CHR(13) + CHR(10)
          OTHERWISE
               ctruncated = ctruncated + SPACE(5) + '[' + MLINE(pctext,i) + ']+ ;' + CHR(13) + CHR(10)
     ENDCASE 
ENDFOR

RETURN ctruncated
ENDPROC
*