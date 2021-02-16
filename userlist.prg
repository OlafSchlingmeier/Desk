 doform('userListForm','forms\userlist')
* DO FORM forms\userlist
 RETURN 
 
 PRIVATE nsElect
 PRIVATE nrEcord
 PRIVATE acFields
 PRIVATE ncOunt
 PRIVATE cbUttons
 PRIVATE clEvel
 SELECT liCense
 nsElect = SELECT()
 nrEcord = RECNO()
 DIMENSION acFields[4, 3]
 acFields[1, 1] = 'License.Lc_User'
 acFields[1, 2] = 15
 acFields[1, 3] = GetLangText("USERLIST","TXT_USERID")
 acFields[2, 1] = 'Lc_Station'
 acFields[2, 2] = 18
 acFields[2, 3] = GetLangText("USERLIST","TXT_STATIONID")
 acFields[3, 1] = 'Lc_Date'
 acFields[3, 2] = 15
 acFields[3, 3] = GetLangText("USERLIST","TXT_DATE")
 acFields[4, 1] = 'Lc_Time'
 acFields[4, 2] = 15
 acFields[4, 3] = GetLangText("USERLIST","TXT_TIME")
 clEvel = ""
 cbUttons = "\!"+buTton(clEvel,GetLangText("COMMON","TXT_CLOSE"),-1)
 SELECT liCense
 ncOunt = RECCOUNT()
 GOTO TOP
 cuS1button = gcButtonfunction
 gcButtonfunction = ""
 = myBrowse(GetLangText("USERLIST","TXT_USERLIST"),ncOunt,@acFields,".t.",".t.", ;
   cbUttons,"vUlControl","UserList")
 gcButtonfunction = cuS1button
 SELECT liCense
 GOTO nrEcord
 SELECT (nsElect)
 RETURN .T.
ENDFUNC
*
