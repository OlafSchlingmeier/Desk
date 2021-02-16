*
FUNCTION RsHistry
 LPARAMETER ccUrrenttext, cwHat, ccHanges, cForceUser
 LOCAL cnEwtext, cUser
 cUser = IIF(EMPTY(cForceUser),cuSerid,cForceUser)
 cnEwtext = ccUrrenttext+(CHR(13)+CHR(10))+DTOC(sySdate())+" "+TIME()+" "+ ;
            cUser+" "+cwHat+" "+ccHanges
 RETURN cnEwtext
ENDFUNC
*
