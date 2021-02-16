*
PROCEDURE SqlInsert
PARAMETERS pcTable, pcFields, pnType, puValues, plSqlRemote
* pnType = 1	- Values
* pnType = 2	- Select
* pnType = 3	- Array
* pnType = 4	- Memvar
* pnType = 5	- Object
LOCAL lcInsert
lcInsert = 'INSERT INTO ' + pcTable
DO CASE
	CASE pnType = 1
		lcInsert = lcInsert + IIF(EMPTY(pcFields), ' ', ' (' + pcFields + ') ') + 'VALUES (' + puValues + ')'
	CASE pnType = 2
		lcInsert = lcInsert + IIF(EMPTY(pcFields), ' ', ' (' + pcFields + ') ') + puValues
	CASE pnType = 3
		EXTERNAL ARRAY pcValues
		lcInsert = lcInsert + ' FROM ARRAY puValues'
	CASE pnType = 4
		lcInsert = lcInsert + ' FROM MEMVAR'
	CASE pnType = 5
		lcInsert = lcInsert + ' FROM NAME puValues'
	OTHERWISE

ENDCASE
Sql(lcInsert, '',,'SQLINSERT',plSqlRemote)

IF ODBC()
     FLUSH
ENDIF

ENDPROC
*