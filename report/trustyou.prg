PROCEDURE ppVersion
PARAMETERS cversion
cversion = "1.02"
RETURN
ENDPROC

PROCEDURE trustyou
PARAMETERS hotelid
oldselect = SELECT()
Select  HOTELID as HOTEL_ID,;
	Iif(hr_compid = hr_addrid and hr_apid > 0, ap_email, ad_email) as EMAIL,;
 	Iif(hr_compid = hr_addrid and hr_apid > 0, ap_fname, ad_fname) as FIRST_NAME, ;
 	Iif(hr_compid = hr_addrid and hr_apid > 0, ap_lname, ad_lname) as LAST_NAME,;
	STR(YEAR(hr_ArrDate),4)+"-"+STR(MONTH(hr_arrdate),2)+"-"+STR(DAY(hr_arrdate),2) as ARRIVAL_DATE,;
	STR(YEAR(hr_depDate),4)+"-"+STR(MONTH(hr_depdate),2)+"-"+STR(DAY(hr_depdate),2) as DEPARTURE_DATE,;
	Iif(ad_lang="GER","de",iif(ad_lang="ENG","en",iif(ad_lang="DUT", "nl", iif(ad_lang="FRE", "fr","en")))) as LANG;
From 	histres, RoomType, Address, Room, Apartner;
Where 	between(hR_DepDate,min1,max1);
And 	hR_RoomTyp = Rt_RoomTyp;
And	hr_status="OUT";
And	!Inlist(Rt_Group, 2, 3);
And	iif(empty(hr_addrid), hr_compid, hr_addrid) = Ad_AddrID;
And	!ad_nomail;
And	hR_RoomNum = Rm_RoomNum;
And	Iif(empty(hr_apid), -9999, hr_apid) = ap_apid;
order by 6,4 INTO CURSOR preproc
COPY all to "export\"+DTOS(DATE())+ALLTRIM(param.pa_hotel)+".csv" delimited with chara ";"
SELECT (oldselect)
WAIT clear
RETURN
ENDPROC 