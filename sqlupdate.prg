*
PROCEDURE SqlUpdate
LPARAMETERS tcTable, tcWhere, tuValues, tnType, tcAlias
* tnType = 3	- Array
* tnType = 4	- Memvar
* tnType = 5	- Object
LOCAL lcSql, lnRec, lcSet, lcDelimiter, lcField, i, lcPrvVar, llODBC
LOCAL ARRAY laMembers(1)
llODBC = Odbc()
IF EMPTY(tcAlias)
     tcAlias = tcTable && tcAlias is used only for AFIELDS and FIELD functions!
ENDIF
DO CASE
	CASE EMPTY(tnType)
		lcSet = tuValues
	CASE tnType = 3
		EXTERNAL ARRAY tuValues
		lcSet = []
		lcDelimiter = []
		AFIELDS(laMembers, tcAlias)
		FOR i = 1 TO ALEN(tuValues)
			lcField = laMembers(i)
			lcSet = lcSet + lcDelimiter + lcField + [=] + SqlCnv(tuValues(i))
			lcDelimiter = [, ]
		NEXT
	CASE tnType = 4
		lcSet = []
		lcDelimiter = []
		FOR i = 1 TO AFIELDS(laMembers, tcAlias)
			lcField = laMembers(i)
			IF TYPE([m.]+lcField) # [U]
				lcSet = lcSet + lcDelimiter + lcField + [=] + SqlCnv(EVALUATE([m.]+lcField))
				lcDelimiter = [, ]
			ENDIF
		NEXT
	CASE tnType = 5
		lcSet = []
		lcDelimiter = []
		FOR i = 1 TO AMEMBERS(laMembers, tuValues)
			lcField = laMembers(i)
			IF NOT EMPTY(FIELD(lcField,tcAlias))
				lcSet = lcSet + lcDelimiter + lcField + [=] + SqlCnv(EVALUATE([tuValues.]+lcField))
				lcDelimiter = [, ]
			ENDIF
		NEXT
	CASE tnType = 6
		lcSet = []
		lcDelimiter = []
		FOR i = 1 TO AMEMBERS(laMembers, tuValues)
			lcField = laMembers(i)
			IF NOT EMPTY(FIELD(lcField,tcAlias))
				lcPrvVar = "p_" + lcField
				PRIVATE &lcPrvVar
				&lcPrvVar = EVALUATE([tuValues.]+lcField)
				lcSet = lcSet + lcDelimiter + lcField + [=] + IIF(llODBC,[?]+lcPrvVar,lcPrvVar)
				lcDelimiter = [, ]
			ENDIF
		NEXT
	OTHERWISE
		RETURN .F.
ENDCASE

IF llODBC
	lcSql = [UPDATE ] + _screen.oGlobal.oGData.CheckTableName(tcTable) + [ SET ] + lcSet + [ ] + SqlWhere([],tcWhere)
	Sql(lcSql, '',,'SQLUPDATE')
ELSE
	lcSql = [UPDATE ] + tcTable + [ SET ] + lcSet + [ ] + SqlWhere([],tcWhere)
	IF USED(tcTable)
		lnRec = RECNO(tcTable)
	ENDIF
	Sql(lcSql, '',,'SQLUPDATE')
	FLUSH
	IF USED(tcTable) AND VARTYPE(lnRec)="N"
		GOTO lnRec IN (tcTable)
	ENDIF
ENDIF
ENDPROC
*