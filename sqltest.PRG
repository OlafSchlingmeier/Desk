RptBulding = "FRD"
min1 = {^2020-5-1}
max1 = {^2020-5-30}
SELECT * FROM ;
( Select bn_billnum, bn_reserid, bn_addrid, bn_amount, bn_history, bn_status, bn_date, bn_window, bn_apid,  bn_paynum, bn_newnum, bn_oldnum, ad_company, iif(!empty(bn_apid), ap_lname, ad_lname) as name, ;
Iif(!empty(bn_apid), ap_fname, ad_fname) as vorname, ad_city, hr_roomnum, rt_buildng from billnum, address, apartner, histres, roomtype  ;
where BETWEEN(bn_date, min1, max1) and iif(!empty(bn_addrid), bn_addrid, -9999999) = ad_addrid and Iif(!empty(bn_apid), bn_apid, -9999) = ap_apid and bn_reserid = hr_reserid  and hr_roomtyp = rt_roomtyp ;
Union all ;
Select bn_billnum, bn_reserid, bn_addrid, bn_amount, bn_history, bn_status, bn_date, bn_window, bn_apid, bn_paynum, bn_newnum, bn_oldnum, ad_company, iif(!empty(bn_apid), ap_lname, ad_lname) as name, ;
Iif(!empty(bn_apid), ap_fname, ad_fname) as vorname, ad_city, space(4), rt_buildng from billnum, address, apartner, reservat, roomtype  ;
where between(bn_date, min1, max1) and iif(!empty(bn_addrid), bn_addrid, -9999999) = ad_addrid and Iif(!empty(bn_apid), bn_apid, -9999) = ap_apid  and rs_roomtyp = rt_roomtyp and ;
bn_billnum NOT IN (Select bn_billnum from billnum, histres where bn_reserid = hr_reserid) ) c1  ;
WHERE (EVL(RptBulding,"*") = "*" OR c1.rt_buildng = RptBulding) order by 1
