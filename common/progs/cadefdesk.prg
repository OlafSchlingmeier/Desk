DEFINE CLASS caaction AS caBase OF cit_ca.vcx
Alias = [caaction]
Tables = [action]
KeyFieldList = [at_atid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       at_acttyp,
       at_addrid,
       at_altid,
       at_atid,
       at_compl,
       at_date,
       at_hkeep,
       at_insdate,
       at_instime,
       at_insuser,
       at_note,
       at_reccur,
       at_reserid,
       at_roomnum,
       at_status,
       at_time,
       at_userid
    FROM action
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    at_acttyp  C(3)    DEFAULT "",
    at_addrid  N(8,0)  DEFAULT 0,
    at_altid   I       DEFAULT 0,
    at_atid    I       DEFAULT 0,
    at_compl   D       DEFAULT {},
    at_date    D       DEFAULT {},
    at_hkeep   L       DEFAULT .F.,
    at_insdate D       DEFAULT {},
    at_instime C(5)    DEFAULT "",
    at_insuser C(10)   DEFAULT "",
    at_note    M       DEFAULT "",
    at_reccur  T       DEFAULT {},
    at_reserid N(12,3) DEFAULT 0,
    at_roomnum C(4)    DEFAULT "",
    at_status  N(1,0)  DEFAULT 0,
    at_time    C(5)    DEFAULT "",
    at_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    at_acttyp,
    at_addrid,
    at_altid,
    at_atid,
    at_compl,
    at_date,
    at_hkeep,
    at_insdate,
    at_instime,
    at_insuser,
    at_note,
    at_reccur,
    at_reserid,
    at_roomnum,
    at_status,
    at_time,
    at_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    at_acttyp  action.at_acttyp,
    at_addrid  action.at_addrid,
    at_altid   action.at_altid,
    at_atid    action.at_atid,
    at_compl   action.at_compl,
    at_date    action.at_date,
    at_hkeep   action.at_hkeep,
    at_insdate action.at_insdate,
    at_instime action.at_instime,
    at_insuser action.at_insuser,
    at_note    action.at_note,
    at_reccur  action.at_reccur,
    at_reserid action.at_reserid,
    at_roomnum action.at_roomnum,
    at_status  action.at_status,
    at_time    action.at_time,
    at_userid  action.at_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caaddress AS caBase OF cit_ca.vcx
Alias = [caaddress]
Tables = [address]
KeyFieldList = [ad_addrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ad_addrid,
       ad_adid,
       ad_adrtype,
       ad_attn,
       ad_billins,
       ad_birth,
       ad_changes,
       ad_city,
       ad_company,
       ad_compkey,
       ad_compnum,
       ad_country,
       ad_created,
       ad_departm,
       ad_discnt,
       ad_email,
       ad_fax,
       ad_feat1,
       ad_feat2,
       ad_feat3,
       ad_fname,
       ad_insurnc,
       ad_lang,
       ad_lasroom,
       ad_lname,
       ad_mail1,
       ad_mail2,
       ad_mail3,
       ad_mail4,
       ad_mail5,
       ad_market,
       ad_member,
       ad_memdat,
       ad_nomail,
       ad_note,
       ad_novat,
       ad_phone,
       ad_phone2,
       ad_phone3,
       ad_picture,
       ad_ratecod,
       ad_roomnum,
       ad_salute,
       ad_save,
       ad_source,
       ad_state,
       ad_street,
       ad_street2,
       ad_titlcod,
       ad_title,
       ad_updated,
       ad_updfail,
       ad_userid,
       ad_usr1,
       ad_usr10,
       ad_usr2,
       ad_usr3,
       ad_usr4,
       ad_usr5,
       ad_usr6,
       ad_usr7,
       ad_usr8,
       ad_usr9,
       ad_ustidnr,
       ad_vip,
       ad_vip2,
       ad_vipstat,
       ad_webpass,
       ad_website,
       ad_zcid,
       ad_zip
    FROM address
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_addrid  N(8,0)  DEFAULT 0,
    ad_adid    I       DEFAULT 0,
    ad_adrtype C(3)    DEFAULT "",
    ad_attn    C(10)   DEFAULT "",
    ad_billins C(40)   DEFAULT "",
    ad_birth   D       DEFAULT {},
    ad_changes M       DEFAULT "",
    ad_city    C(30)   DEFAULT "",
    ad_company C(50)   DEFAULT "",
    ad_compkey C(15)   DEFAULT "",
    ad_compnum N(10,0) DEFAULT 0,
    ad_country C(3)    DEFAULT "",
    ad_created D       DEFAULT {},
    ad_departm C(50)   DEFAULT "",
    ad_discnt  C(3)    DEFAULT "",
    ad_email   C(100)  DEFAULT "",
    ad_fax     C(100)  DEFAULT "",
    ad_feat1   C(3)    DEFAULT "",
    ad_feat2   C(3)    DEFAULT "",
    ad_feat3   C(3)    DEFAULT "",
    ad_fname   C(20)   DEFAULT "",
    ad_insurnc I       DEFAULT 0,
    ad_lang    C(3)    DEFAULT "",
    ad_lasroom C(4)    DEFAULT "",
    ad_lname   C(30)   DEFAULT "",
    ad_mail1   C(3)    DEFAULT "",
    ad_mail2   C(3)    DEFAULT "",
    ad_mail3   C(3)    DEFAULT "",
    ad_mail4   C(3)    DEFAULT "",
    ad_mail5   C(3)    DEFAULT "",
    ad_market  C(3)    DEFAULT "",
    ad_member  N(10,0) DEFAULT 0,
    ad_memdat  D       DEFAULT {},
    ad_nomail  L       DEFAULT .F.,
    ad_note    M       DEFAULT "",
    ad_novat   L       DEFAULT .F.,
    ad_phone   C(20)   DEFAULT "",
    ad_phone2  C(20)   DEFAULT "",
    ad_phone3  C(20)   DEFAULT "",
    ad_picture C(100)  DEFAULT "",
    ad_ratecod C(10)   DEFAULT "",
    ad_roomnum C(4)    DEFAULT "",
    ad_salute  C(50)   DEFAULT "",
    ad_save    L       DEFAULT .F.,
    ad_source  C(3)    DEFAULT "",
    ad_state   C(30)   DEFAULT "",
    ad_street  C(100)  DEFAULT "",
    ad_street2 C(100)  DEFAULT "",
    ad_titlcod N(2,0)  DEFAULT 0,
    ad_title   C(20)   DEFAULT "",
    ad_updated D       DEFAULT {},
    ad_updfail N(1,0)  DEFAULT 0,
    ad_userid  C(10)   DEFAULT "",
    ad_usr1    C(100)  DEFAULT "",
    ad_usr10   C(100)  DEFAULT "",
    ad_usr2    C(100)  DEFAULT "",
    ad_usr3    C(100)  DEFAULT "",
    ad_usr4    C(100)  DEFAULT "",
    ad_usr5    C(100)  DEFAULT "",
    ad_usr6    C(100)  DEFAULT "",
    ad_usr7    C(100)  DEFAULT "",
    ad_usr8    C(100)  DEFAULT "",
    ad_usr9    C(100)  DEFAULT "",
    ad_ustidnr C(20)   DEFAULT "",
    ad_vip     L       DEFAULT .F.,
    ad_vip2    L       DEFAULT .F.,
    ad_vipstat N(2,0)  DEFAULT 0,
    ad_webpass C(6)    DEFAULT "",
    ad_website C(60)   DEFAULT "",
    ad_zcid    I       DEFAULT 0,
    ad_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_addrid,
    ad_adid,
    ad_adrtype,
    ad_attn,
    ad_billins,
    ad_birth,
    ad_changes,
    ad_city,
    ad_company,
    ad_compkey,
    ad_compnum,
    ad_country,
    ad_created,
    ad_departm,
    ad_discnt,
    ad_email,
    ad_fax,
    ad_feat1,
    ad_feat2,
    ad_feat3,
    ad_fname,
    ad_insurnc,
    ad_lang,
    ad_lasroom,
    ad_lname,
    ad_mail1,
    ad_mail2,
    ad_mail3,
    ad_mail4,
    ad_mail5,
    ad_market,
    ad_member,
    ad_memdat,
    ad_nomail,
    ad_note,
    ad_novat,
    ad_phone,
    ad_phone2,
    ad_phone3,
    ad_picture,
    ad_ratecod,
    ad_roomnum,
    ad_salute,
    ad_save,
    ad_source,
    ad_state,
    ad_street,
    ad_street2,
    ad_titlcod,
    ad_title,
    ad_updated,
    ad_updfail,
    ad_userid,
    ad_usr1,
    ad_usr10,
    ad_usr2,
    ad_usr3,
    ad_usr4,
    ad_usr5,
    ad_usr6,
    ad_usr7,
    ad_usr8,
    ad_usr9,
    ad_ustidnr,
    ad_vip,
    ad_vip2,
    ad_vipstat,
    ad_webpass,
    ad_website,
    ad_zcid,
    ad_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_addrid  address.ad_addrid,
    ad_adid    address.ad_adid,
    ad_adrtype address.ad_adrtype,
    ad_attn    address.ad_attn,
    ad_billins address.ad_billins,
    ad_birth   address.ad_birth,
    ad_changes address.ad_changes,
    ad_city    address.ad_city,
    ad_company address.ad_company,
    ad_compkey address.ad_compkey,
    ad_compnum address.ad_compnum,
    ad_country address.ad_country,
    ad_created address.ad_created,
    ad_departm address.ad_departm,
    ad_discnt  address.ad_discnt,
    ad_email   address.ad_email,
    ad_fax     address.ad_fax,
    ad_feat1   address.ad_feat1,
    ad_feat2   address.ad_feat2,
    ad_feat3   address.ad_feat3,
    ad_fname   address.ad_fname,
    ad_insurnc address.ad_insurnc,
    ad_lang    address.ad_lang,
    ad_lasroom address.ad_lasroom,
    ad_lname   address.ad_lname,
    ad_mail1   address.ad_mail1,
    ad_mail2   address.ad_mail2,
    ad_mail3   address.ad_mail3,
    ad_mail4   address.ad_mail4,
    ad_mail5   address.ad_mail5,
    ad_market  address.ad_market,
    ad_member  address.ad_member,
    ad_memdat  address.ad_memdat,
    ad_nomail  address.ad_nomail,
    ad_note    address.ad_note,
    ad_novat   address.ad_novat,
    ad_phone   address.ad_phone,
    ad_phone2  address.ad_phone2,
    ad_phone3  address.ad_phone3,
    ad_picture address.ad_picture,
    ad_ratecod address.ad_ratecod,
    ad_roomnum address.ad_roomnum,
    ad_salute  address.ad_salute,
    ad_save    address.ad_save,
    ad_source  address.ad_source,
    ad_state   address.ad_state,
    ad_street  address.ad_street,
    ad_street2 address.ad_street2,
    ad_titlcod address.ad_titlcod,
    ad_title   address.ad_title,
    ad_updated address.ad_updated,
    ad_updfail address.ad_updfail,
    ad_userid  address.ad_userid,
    ad_usr1    address.ad_usr1,
    ad_usr10   address.ad_usr10,
    ad_usr2    address.ad_usr2,
    ad_usr3    address.ad_usr3,
    ad_usr4    address.ad_usr4,
    ad_usr5    address.ad_usr5,
    ad_usr6    address.ad_usr6,
    ad_usr7    address.ad_usr7,
    ad_usr8    address.ad_usr8,
    ad_usr9    address.ad_usr9,
    ad_ustidnr address.ad_ustidnr,
    ad_vip     address.ad_vip,
    ad_vip2    address.ad_vip2,
    ad_vipstat address.ad_vipstat,
    ad_webpass address.ad_webpass,
    ad_website address.ad_website,
    ad_zcid    address.ad_zcid,
    ad_zip     address.ad_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadintrst AS caBase OF cit_ca.vcx
Alias = [caadintrst]
Tables = [adintrst]
KeyFieldList = [ab_abid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ab_abid,
       ab_descrip
    FROM adintrst
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ab_abid    N(8,0)  DEFAULT 0,
    ab_descrip C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ab_abid,
    ab_descrip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ab_abid    adintrst.ab_abid,
    ab_descrip adintrst.ab_descrip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrfeat AS caBase OF cit_ca.vcx
Alias = [caadrfeat]
Tables = [adrfeat]
KeyFieldList = [fa_faid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       fa_addrid,
       fa_faid,
       fa_feature
    FROM adrfeat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    fa_addrid  N(8,0)  DEFAULT 0,
    fa_faid    I       DEFAULT 0,
    fa_feature C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fa_addrid,
    fa_faid,
    fa_feature
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fa_addrid  adrfeat.fa_addrid,
    fa_faid    adrfeat.fa_faid,
    fa_feature adrfeat.fa_feature
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrhot AS caBase OF cit_ca.vcx
Alias = [caadrhot]
Tables = [adrhot]
KeyFieldList = [an_adid,an_hotcode]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       an_adid,
       an_hotcode
    FROM adrhot
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    an_adid    I       DEFAULT 0,
    an_hotcode C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    an_adid,
    an_hotcode
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    an_adid    adrhot.an_adid,
    an_hotcode adrhot.an_hotcode
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrmain AS caBase OF cit_ca.vcx
Alias = [caadrmain]
Tables = [adrmain]
KeyFieldList = [ad_adid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ad_adid,
       ad_adrmupd,
       ad_birth,
       ad_city,
       ad_company,
       ad_compkey,
       ad_compnum,
       ad_country,
       ad_created,
       ad_departm,
       ad_email,
       ad_fax,
       ad_fname,
       ad_hotcode,
       ad_lang,
       ad_lname,
       ad_mail1,
       ad_mail2,
       ad_mail3,
       ad_mail4,
       ad_mail5,
       ad_nomail,
       ad_note,
       ad_phone,
       ad_phone2,
       ad_phone3,
       ad_salute,
       ad_state,
       ad_street,
       ad_street2,
       ad_titlcod,
       ad_title,
       ad_userid,
       ad_vipstat,
       ad_webpass,
       ad_website,
       ad_zcid,
       ad_zip
    FROM adrmain
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_adid    I       DEFAULT 0,
    ad_adrmupd T       DEFAULT {},
    ad_birth   D       DEFAULT {},
    ad_city    C(30)   DEFAULT "",
    ad_company C(50)   DEFAULT "",
    ad_compkey C(15)   DEFAULT "",
    ad_compnum N(10,0) DEFAULT 0,
    ad_country C(3)    DEFAULT "",
    ad_created D       DEFAULT {},
    ad_departm C(50)   DEFAULT "",
    ad_email   C(100)  DEFAULT "",
    ad_fax     C(100)  DEFAULT "",
    ad_fname   C(20)   DEFAULT "",
    ad_hotcode C(10)   DEFAULT "",
    ad_lang    C(3)    DEFAULT "",
    ad_lname   C(30)   DEFAULT "",
    ad_mail1   C(3)    DEFAULT "",
    ad_mail2   C(3)    DEFAULT "",
    ad_mail3   C(3)    DEFAULT "",
    ad_mail4   C(3)    DEFAULT "",
    ad_mail5   C(3)    DEFAULT "",
    ad_nomail  L       DEFAULT .F.,
    ad_note    M       DEFAULT "",
    ad_phone   C(20)   DEFAULT "",
    ad_phone2  C(20)   DEFAULT "",
    ad_phone3  C(20)   DEFAULT "",
    ad_salute  C(50)   DEFAULT "",
    ad_state   C(30)   DEFAULT "",
    ad_street  C(100)  DEFAULT "",
    ad_street2 C(100)  DEFAULT "",
    ad_titlcod N(2,0)  DEFAULT 0,
    ad_title   C(20)   DEFAULT "",
    ad_userid  C(10)   DEFAULT "",
    ad_vipstat N(2,0)  DEFAULT 0,
    ad_webpass C(6)    DEFAULT "",
    ad_website C(60)   DEFAULT "",
    ad_zcid    I       DEFAULT 0,
    ad_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_adid,
    ad_adrmupd,
    ad_birth,
    ad_city,
    ad_company,
    ad_compkey,
    ad_compnum,
    ad_country,
    ad_created,
    ad_departm,
    ad_email,
    ad_fax,
    ad_fname,
    ad_hotcode,
    ad_lang,
    ad_lname,
    ad_mail1,
    ad_mail2,
    ad_mail3,
    ad_mail4,
    ad_mail5,
    ad_nomail,
    ad_note,
    ad_phone,
    ad_phone2,
    ad_phone3,
    ad_salute,
    ad_state,
    ad_street,
    ad_street2,
    ad_titlcod,
    ad_title,
    ad_userid,
    ad_vipstat,
    ad_webpass,
    ad_website,
    ad_zcid,
    ad_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_adid    adrmain.ad_adid,
    ad_adrmupd adrmain.ad_adrmupd,
    ad_birth   adrmain.ad_birth,
    ad_city    adrmain.ad_city,
    ad_company adrmain.ad_company,
    ad_compkey adrmain.ad_compkey,
    ad_compnum adrmain.ad_compnum,
    ad_country adrmain.ad_country,
    ad_created adrmain.ad_created,
    ad_departm adrmain.ad_departm,
    ad_email   adrmain.ad_email,
    ad_fax     adrmain.ad_fax,
    ad_fname   adrmain.ad_fname,
    ad_hotcode adrmain.ad_hotcode,
    ad_lang    adrmain.ad_lang,
    ad_lname   adrmain.ad_lname,
    ad_mail1   adrmain.ad_mail1,
    ad_mail2   adrmain.ad_mail2,
    ad_mail3   adrmain.ad_mail3,
    ad_mail4   adrmain.ad_mail4,
    ad_mail5   adrmain.ad_mail5,
    ad_nomail  adrmain.ad_nomail,
    ad_note    adrmain.ad_note,
    ad_phone   adrmain.ad_phone,
    ad_phone2  adrmain.ad_phone2,
    ad_phone3  adrmain.ad_phone3,
    ad_salute  adrmain.ad_salute,
    ad_state   adrmain.ad_state,
    ad_street  adrmain.ad_street,
    ad_street2 adrmain.ad_street2,
    ad_titlcod adrmain.ad_titlcod,
    ad_title   adrmain.ad_title,
    ad_userid  adrmain.ad_userid,
    ad_vipstat adrmain.ad_vipstat,
    ad_webpass adrmain.ad_webpass,
    ad_website adrmain.ad_website,
    ad_zcid    adrmain.ad_zcid,
    ad_zip     adrmain.ad_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrphone AS caBase OF cit_ca.vcx
Alias = [caadrphone]
Tables = [adrphone]
KeyFieldList = [aj_ajid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       aj_addrid,
       aj_ajid,
       aj_apid,
       aj_field,
       aj_phone
    FROM adrphone
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    aj_addrid  I       DEFAULT 0,
    aj_ajid    I       DEFAULT 0,
    aj_apid    I       DEFAULT 0,
    aj_field   C(10)   DEFAULT "",
    aj_phone   C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aj_addrid,
    aj_ajid,
    aj_apid,
    aj_field,
    aj_phone
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aj_addrid  adrphone.aj_addrid,
    aj_ajid    adrphone.aj_ajid,
    aj_apid    adrphone.aj_apid,
    aj_field   adrphone.aj_field,
    aj_phone   adrphone.aj_phone
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrprvcy AS caBase OF cit_ca.vcx
Alias = [caadrprvcy]
Tables = [adrprvcy]
KeyFieldList = [ap_apid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ap_addrid,
       ap_apid,
       ap_cnfalas,
       ap_cnfname,
       ap_consent,
       ap_delgdpr,
       ap_deluser,
       ap_issudby,
       ap_issued,
       ap_note,
       ap_user1,
       ap_user2,
       ap_user3,
       ap_user4,
       ap_user5,
       ap_userid
    FROM adrprvcy
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_addrid  N(8,0)  DEFAULT 0,
    ap_apid    I       DEFAULT 0,
    ap_cnfalas C(100)  DEFAULT "",
    ap_cnfname C(100)  DEFAULT "",
    ap_consent N(3,0)  DEFAULT 0,
    ap_delgdpr T       DEFAULT {},
    ap_deluser C(10)   DEFAULT "",
    ap_issudby C(50)   DEFAULT "",
    ap_issued  T       DEFAULT {},
    ap_note    C(254)  DEFAULT "",
    ap_user1   C(50)   DEFAULT "",
    ap_user2   C(50)   DEFAULT "",
    ap_user3   C(50)   DEFAULT "",
    ap_user4   C(50)   DEFAULT "",
    ap_user5   C(50)   DEFAULT "",
    ap_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_addrid,
    ap_apid,
    ap_cnfalas,
    ap_cnfname,
    ap_consent,
    ap_delgdpr,
    ap_deluser,
    ap_issudby,
    ap_issued,
    ap_note,
    ap_user1,
    ap_user2,
    ap_user3,
    ap_user4,
    ap_user5,
    ap_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_addrid  adrprvcy.ap_addrid,
    ap_apid    adrprvcy.ap_apid,
    ap_cnfalas adrprvcy.ap_cnfalas,
    ap_cnfname adrprvcy.ap_cnfname,
    ap_consent adrprvcy.ap_consent,
    ap_delgdpr adrprvcy.ap_delgdpr,
    ap_deluser adrprvcy.ap_deluser,
    ap_issudby adrprvcy.ap_issudby,
    ap_issued  adrprvcy.ap_issued,
    ap_note    adrprvcy.ap_note,
    ap_user1   adrprvcy.ap_user1,
    ap_user2   adrprvcy.ap_user2,
    ap_user3   adrprvcy.ap_user3,
    ap_user4   adrprvcy.ap_user4,
    ap_user5   adrprvcy.ap_user5,
    ap_userid  adrprvcy.ap_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrrates AS caBase OF cit_ca.vcx
Alias = [caadrrates]
Tables = [adrrates]
KeyFieldList = [af_addrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       af_addrid,
       af_amnt1,
       af_amnt2,
       af_amnt3,
       af_camnt1,
       af_camnt2,
       af_camnt3,
       af_datum,
       af_ratecod,
       af_urcprc,
       af_userid
    FROM adrrates
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_addrid  N(8,0)  DEFAULT 0,
    af_amnt1   B(8)    DEFAULT 0,
    af_amnt2   B(8)    DEFAULT 0,
    af_amnt3   B(8)    DEFAULT 0,
    af_camnt1  B(8)    DEFAULT 0,
    af_camnt2  B(8)    DEFAULT 0,
    af_camnt3  B(8)    DEFAULT 0,
    af_datum   D       DEFAULT {},
    af_ratecod C(10)   DEFAULT "",
    af_urcprc  L       DEFAULT .F.,
    af_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_addrid,
    af_amnt1,
    af_amnt2,
    af_amnt3,
    af_camnt1,
    af_camnt2,
    af_camnt3,
    af_datum,
    af_ratecod,
    af_urcprc,
    af_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_addrid  adrrates.af_addrid,
    af_amnt1   adrrates.af_amnt1,
    af_amnt2   adrrates.af_amnt2,
    af_amnt3   adrrates.af_amnt3,
    af_camnt1  adrrates.af_camnt1,
    af_camnt2  adrrates.af_camnt2,
    af_camnt3  adrrates.af_camnt3,
    af_datum   adrrates.af_datum,
    af_ratecod adrrates.af_ratecod,
    af_urcprc  adrrates.af_urcprc,
    af_userid  adrrates.af_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrstint AS caBase OF cit_ca.vcx
Alias = [caadrstint]
Tables = [adrstint]
KeyFieldList = [ai_aiid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ai_aiid,
       ai_descrip,
       ai_evid,
       ai_fromdat,
       ai_month,
       ai_todat
    FROM adrstint
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_aiid    N(8,0)  DEFAULT 0,
    ai_descrip C(30)   DEFAULT "",
    ai_evid    N(8,0)  DEFAULT 0,
    ai_fromdat D       DEFAULT {},
    ai_month   N(2,0)  DEFAULT 0,
    ai_todat   D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_aiid,
    ai_descrip,
    ai_evid,
    ai_fromdat,
    ai_month,
    ai_todat
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_aiid    adrstint.ai_aiid,
    ai_descrip adrstint.ai_descrip,
    ai_evid    adrstint.ai_evid,
    ai_fromdat adrstint.ai_fromdat,
    ai_month   adrstint.ai_month,
    ai_todat   adrstint.ai_todat
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrtoin AS caBase OF cit_ca.vcx
Alias = [caadrtoin]
Tables = [adrtoin]
KeyFieldList = [ae_addrid,ae_abid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ae_abid,
       ae_addrid
    FROM adrtoin
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ae_abid    N(8,0)  DEFAULT 0,
    ae_addrid  N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ae_abid,
    ae_addrid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ae_abid    adrtoin.ae_abid,
    ae_addrid  adrtoin.ae_addrid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrtores AS caBase OF cit_ca.vcx
Alias = [caadrtores]
Tables = [adrtores]
KeyFieldList = [adrfield,resfield]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       adrfield,
       resfield
    FROM adrtores
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    adrfield   C(50)   DEFAULT "",
    resfield   C(50)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    adrfield,
    resfield
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    adrfield   adrtores.adrfield,
    resfield   adrtores.resfield
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrtosi AS caBase OF cit_ca.vcx
Alias = [caadrtosi]
Tables = [adrtosi]
KeyFieldList = [ao_addrid,ao_aiid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ao_addrid,
       ao_aiid
    FROM adrtosi
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ao_addrid  N(8,0)  DEFAULT 0,
    ao_aiid    N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ao_addrid,
    ao_aiid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ao_addrid  adrtosi.ao_addrid,
    ao_aiid    adrtosi.ao_aiid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caalthead AS caBase OF cit_ca.vcx
Alias = [caalthead]
Tables = [althead]
KeyFieldList = [al_altid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       al_addrid,
       al_allott,
       al_altid,
       al_apid,
       al_buildng,
       al_company,
       al_cutdate,
       al_cutday,
       al_days,
       al_eiid,
       al_fromdat,
       al_lname,
       al_locat,
       al_note,
       al_todat,
       al_unalloc
    FROM althead
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    al_addrid  N(8,0)  DEFAULT 0,
    al_allott  C(30)   DEFAULT "",
    al_altid   N(8,0)  DEFAULT 0,
    al_apid    N(8,0)  DEFAULT 0,
    al_buildng C(3)    DEFAULT "",
    al_company C(30)   DEFAULT "",
    al_cutdate D       DEFAULT {},
    al_cutday  N(3,0)  DEFAULT 0,
    al_days    C(7)    DEFAULT "",
    al_eiid    I       DEFAULT 0,
    al_fromdat D       DEFAULT {},
    al_lname   C(30)   DEFAULT "",
    al_locat   C(50)   DEFAULT "",
    al_note    M       DEFAULT "",
    al_todat   D       DEFAULT {},
    al_unalloc L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    al_addrid,
    al_allott,
    al_altid,
    al_apid,
    al_buildng,
    al_company,
    al_cutdate,
    al_cutday,
    al_days,
    al_eiid,
    al_fromdat,
    al_lname,
    al_locat,
    al_note,
    al_todat,
    al_unalloc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    al_addrid  althead.al_addrid,
    al_allott  althead.al_allott,
    al_altid   althead.al_altid,
    al_apid    althead.al_apid,
    al_buildng althead.al_buildng,
    al_company althead.al_company,
    al_cutdate althead.al_cutdate,
    al_cutday  althead.al_cutday,
    al_days    althead.al_days,
    al_eiid    althead.al_eiid,
    al_fromdat althead.al_fromdat,
    al_lname   althead.al_lname,
    al_locat   althead.al_locat,
    al_note    althead.al_note,
    al_todat   althead.al_todat,
    al_unalloc althead.al_unalloc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caaltsplit AS caBase OF cit_ca.vcx
Alias = [caaltsplit]
Tables = [altsplit]
KeyFieldList = [as_altid,as_date,as_roomtyp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       as_accept,
       as_altid,
       as_crate1,
       as_crate2,
       as_crate3,
       as_cutdate,
       as_date,
       as_orgroom,
       as_pick,
       as_rate1,
       as_rate2,
       as_rate3,
       as_rate4,
       as_rate5,
       as_ratecod,
       as_rooms,
       as_roomtyp
    FROM altsplit
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    as_accept  L       DEFAULT .F.,
    as_altid   N(8,0)  DEFAULT 0,
    as_crate1  N(6,2)  DEFAULT 0,
    as_crate2  N(6,2)  DEFAULT 0,
    as_crate3  N(6,2)  DEFAULT 0,
    as_cutdate D       DEFAULT {},
    as_date    D       DEFAULT {},
    as_orgroom N(3,0)  DEFAULT 0,
    as_pick    N(3,0)  DEFAULT 0,
    as_rate1   N(6,2)  DEFAULT 0,
    as_rate2   N(6,2)  DEFAULT 0,
    as_rate3   N(6,2)  DEFAULT 0,
    as_rate4   N(6,2)  DEFAULT 0,
    as_rate5   N(6,2)  DEFAULT 0,
    as_ratecod C(10)   DEFAULT "",
    as_rooms   N(3,0)  DEFAULT 0,
    as_roomtyp C(4)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    as_accept,
    as_altid,
    as_crate1,
    as_crate2,
    as_crate3,
    as_cutdate,
    as_date,
    as_orgroom,
    as_pick,
    as_rate1,
    as_rate2,
    as_rate3,
    as_rate4,
    as_rate5,
    as_ratecod,
    as_rooms,
    as_roomtyp
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    as_accept  altsplit.as_accept,
    as_altid   altsplit.as_altid,
    as_crate1  altsplit.as_crate1,
    as_crate2  altsplit.as_crate2,
    as_crate3  altsplit.as_crate3,
    as_cutdate altsplit.as_cutdate,
    as_date    altsplit.as_date,
    as_orgroom altsplit.as_orgroom,
    as_pick    altsplit.as_pick,
    as_rate1   altsplit.as_rate1,
    as_rate2   altsplit.as_rate2,
    as_rate3   altsplit.as_rate3,
    as_rate4   altsplit.as_rate4,
    as_rate5   altsplit.as_rate5,
    as_ratecod altsplit.as_ratecod,
    as_rooms   altsplit.as_rooms,
    as_roomtyp altsplit.as_roomtyp
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caapartner AS caBase OF cit_ca.vcx
Alias = [caapartner]
Tables = [apartner]
KeyFieldList = [ap_apid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ap_addrid,
       ap_apid,
       ap_email,
       ap_fax,
       ap_fname,
       ap_gebdate,
       ap_lang,
       ap_lname,
       ap_mail1,
       ap_note,
       ap_phone1,
       ap_phone2,
       ap_salute,
       ap_titlcod,
       ap_title,
       ap_user1,
       ap_user2,
       ap_user3,
       ap_vip1
    FROM apartner
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_addrid  N(8,0)  DEFAULT 0,
    ap_apid    N(8,0)  DEFAULT 0,
    ap_email   C(100)  DEFAULT "",
    ap_fax     C(100)  DEFAULT "",
    ap_fname   C(20)   DEFAULT "",
    ap_gebdate D       DEFAULT {},
    ap_lang    C(3)    DEFAULT "",
    ap_lname   C(30)   DEFAULT "",
    ap_mail1   C(3)    DEFAULT "",
    ap_note    M       DEFAULT "",
    ap_phone1  C(20)   DEFAULT "",
    ap_phone2  C(20)   DEFAULT "",
    ap_salute  C(50)   DEFAULT "",
    ap_titlcod N(2,0)  DEFAULT 0,
    ap_title   C(20)   DEFAULT "",
    ap_user1   C(30)   DEFAULT "",
    ap_user2   C(30)   DEFAULT "",
    ap_user3   C(30)   DEFAULT "",
    ap_vip1    L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_addrid,
    ap_apid,
    ap_email,
    ap_fax,
    ap_fname,
    ap_gebdate,
    ap_lang,
    ap_lname,
    ap_mail1,
    ap_note,
    ap_phone1,
    ap_phone2,
    ap_salute,
    ap_titlcod,
    ap_title,
    ap_user1,
    ap_user2,
    ap_user3,
    ap_vip1
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_addrid  apartner.ap_addrid,
    ap_apid    apartner.ap_apid,
    ap_email   apartner.ap_email,
    ap_fax     apartner.ap_fax,
    ap_fname   apartner.ap_fname,
    ap_gebdate apartner.ap_gebdate,
    ap_lang    apartner.ap_lang,
    ap_lname   apartner.ap_lname,
    ap_mail1   apartner.ap_mail1,
    ap_note    apartner.ap_note,
    ap_phone1  apartner.ap_phone1,
    ap_phone2  apartner.ap_phone2,
    ap_salute  apartner.ap_salute,
    ap_titlcod apartner.ap_titlcod,
    ap_title   apartner.ap_title,
    ap_user1   apartner.ap_user1,
    ap_user2   apartner.ap_user2,
    ap_user3   apartner.ap_user3,
    ap_vip1    apartner.ap_vip1
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caaracct AS caBase OF cit_ca.vcx
Alias = [caaracct]
Tables = [aracct]
KeyFieldList = [ac_aracct]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ac_accttyp,
       ac_addrid,
       ac_amid,
       ac_apid,
       ac_aracct,
       ac_ayid,
       ac_cautobk,
       ac_credito,
       ac_credlim,
       ac_inactiv,
       ac_perman,
       ac_remind,
       ac_statem,
       ac_status
    FROM aracct
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_accttyp C(3)    DEFAULT "",
    ac_addrid  N(8,0)  DEFAULT 0,
    ac_amid    N(8,0)  DEFAULT 0,
    ac_apid    N(8,0)  DEFAULT 0,
    ac_aracct  N(10,0) DEFAULT 0,
    ac_ayid    N(8,0)  DEFAULT 0,
    ac_cautobk L       DEFAULT .F.,
    ac_credito L       DEFAULT .F.,
    ac_credlim B(2)    DEFAULT 0,
    ac_inactiv L       DEFAULT .F.,
    ac_perman  L       DEFAULT .F.,
    ac_remind  L       DEFAULT .F.,
    ac_statem  L       DEFAULT .F.,
    ac_status  N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_accttyp,
    ac_addrid,
    ac_amid,
    ac_apid,
    ac_aracct,
    ac_ayid,
    ac_cautobk,
    ac_credito,
    ac_credlim,
    ac_inactiv,
    ac_perman,
    ac_remind,
    ac_statem,
    ac_status
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_accttyp aracct.ac_accttyp,
    ac_addrid  aracct.ac_addrid,
    ac_amid    aracct.ac_amid,
    ac_apid    aracct.ac_apid,
    ac_aracct  aracct.ac_aracct,
    ac_ayid    aracct.ac_ayid,
    ac_cautobk aracct.ac_cautobk,
    ac_credito aracct.ac_credito,
    ac_credlim aracct.ac_credlim,
    ac_inactiv aracct.ac_inactiv,
    ac_perman  aracct.ac_perman,
    ac_remind  aracct.ac_remind,
    ac_statem  aracct.ac_statem,
    ac_status  aracct.ac_status
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarbilsta AS caBase OF cit_ca.vcx
Alias = [caarbilsta]
Tables = [arbilsta]
KeyFieldList = [ah_ahid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ah_ahid,
       ah_number,
       ah_text1,
       ah_text2,
       ah_text3,
       ah_text4,
       ah_text5,
       ah_text6,
       ah_text7,
       ah_text8,
       ah_text9
    FROM arbilsta
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ah_ahid    N(8,0)  DEFAULT 0,
    ah_number  N(2,0)  DEFAULT 0,
    ah_text1   C(50)   DEFAULT "",
    ah_text2   C(50)   DEFAULT "",
    ah_text3   C(50)   DEFAULT "",
    ah_text4   C(50)   DEFAULT "",
    ah_text5   C(50)   DEFAULT "",
    ah_text6   C(50)   DEFAULT "",
    ah_text7   C(50)   DEFAULT "",
    ah_text8   C(50)   DEFAULT "",
    ah_text9   C(50)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ah_ahid,
    ah_number,
    ah_text1,
    ah_text2,
    ah_text3,
    ah_text4,
    ah_text5,
    ah_text6,
    ah_text7,
    ah_text8,
    ah_text9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ah_ahid    arbilsta.ah_ahid,
    ah_number  arbilsta.ah_number,
    ah_text1   arbilsta.ah_text1,
    ah_text2   arbilsta.ah_text2,
    ah_text3   arbilsta.ah_text3,
    ah_text4   arbilsta.ah_text4,
    ah_text5   arbilsta.ah_text5,
    ah_text6   arbilsta.ah_text6,
    ah_text7   arbilsta.ah_text7,
    ah_text8   arbilsta.ah_text8,
    ah_text9   arbilsta.ah_text9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caargenrem AS caBase OF cit_ca.vcx
Alias = [caargenrem]
Tables = [argenrem]
KeyFieldList = [ag_agid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ag_acfrom,
       ag_acto,
       ag_actype,
       ag_agid,
       ag_compl,
       ag_credito,
       ag_date,
       ag_docdesc,
       ag_inclds,
       ag_onlydep,
       ag_remfil,
       ag_setday,
       ag_stmfil,
       ag_userid,
       ag_wrdoc
    FROM argenrem
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_acfrom  N(10,0) DEFAULT 0,
    ag_acto    N(10,0) DEFAULT 0,
    ag_actype  C(3)    DEFAULT "",
    ag_agid    N(8,0)  DEFAULT 0,
    ag_compl   L       DEFAULT .F.,
    ag_credito L       DEFAULT .F.,
    ag_date    T       DEFAULT {},
    ag_docdesc C(40)   DEFAULT "",
    ag_inclds  L       DEFAULT .F.,
    ag_onlydep L       DEFAULT .F.,
    ag_remfil  N(2,0)  DEFAULT 0,
    ag_setday  D       DEFAULT {},
    ag_stmfil  N(2,0)  DEFAULT 0,
    ag_userid  C(10)   DEFAULT "",
    ag_wrdoc   L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_acfrom,
    ag_acto,
    ag_actype,
    ag_agid,
    ag_compl,
    ag_credito,
    ag_date,
    ag_docdesc,
    ag_inclds,
    ag_onlydep,
    ag_remfil,
    ag_setday,
    ag_stmfil,
    ag_userid,
    ag_wrdoc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_acfrom  argenrem.ag_acfrom,
    ag_acto    argenrem.ag_acto,
    ag_actype  argenrem.ag_actype,
    ag_agid    argenrem.ag_agid,
    ag_compl   argenrem.ag_compl,
    ag_credito argenrem.ag_credito,
    ag_date    argenrem.ag_date,
    ag_docdesc argenrem.ag_docdesc,
    ag_inclds  argenrem.ag_inclds,
    ag_onlydep argenrem.ag_onlydep,
    ag_remfil  argenrem.ag_remfil,
    ag_setday  argenrem.ag_setday,
    ag_stmfil  argenrem.ag_stmfil,
    ag_userid  argenrem.ag_userid,
    ag_wrdoc   argenrem.ag_wrdoc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarpcond AS caBase OF cit_ca.vcx
Alias = [caarpcond]
Tables = [arpcond]
KeyFieldList = [ay_ayid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ay_ayid,
       ay_credito,
       ay_daydis1,
       ay_daydis2,
       ay_daydis3,
       ay_discou1,
       ay_discou2,
       ay_discou3,
       ay_dsctxt1,
       ay_dsctxt2,
       ay_dsctxt3,
       ay_header,
       ay_label,
       ay_number,
       ay_show1,
       ay_show2,
       ay_show3
    FROM arpcond
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ay_ayid    N(8,0)  DEFAULT 0,
    ay_credito L       DEFAULT .F.,
    ay_daydis1 N(3,0)  DEFAULT 0,
    ay_daydis2 N(3,0)  DEFAULT 0,
    ay_daydis3 N(3,0)  DEFAULT 0,
    ay_discou1 N(5,2)  DEFAULT 0,
    ay_discou2 N(5,2)  DEFAULT 0,
    ay_discou3 N(5,2)  DEFAULT 0,
    ay_dsctxt1 C(60)   DEFAULT "",
    ay_dsctxt2 C(60)   DEFAULT "",
    ay_dsctxt3 C(60)   DEFAULT "",
    ay_header  C(60)   DEFAULT "",
    ay_label   C(40)   DEFAULT "",
    ay_number  N(2,0)  DEFAULT 0,
    ay_show1   L       DEFAULT .F.,
    ay_show2   L       DEFAULT .F.,
    ay_show3   L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ay_ayid,
    ay_credito,
    ay_daydis1,
    ay_daydis2,
    ay_daydis3,
    ay_discou1,
    ay_discou2,
    ay_discou3,
    ay_dsctxt1,
    ay_dsctxt2,
    ay_dsctxt3,
    ay_header,
    ay_label,
    ay_number,
    ay_show1,
    ay_show2,
    ay_show3
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ay_ayid    arpcond.ay_ayid,
    ay_credito arpcond.ay_credito,
    ay_daydis1 arpcond.ay_daydis1,
    ay_daydis2 arpcond.ay_daydis2,
    ay_daydis3 arpcond.ay_daydis3,
    ay_discou1 arpcond.ay_discou1,
    ay_discou2 arpcond.ay_discou2,
    ay_discou3 arpcond.ay_discou3,
    ay_dsctxt1 arpcond.ay_dsctxt1,
    ay_dsctxt2 arpcond.ay_dsctxt2,
    ay_dsctxt3 arpcond.ay_dsctxt3,
    ay_header  arpcond.ay_header,
    ay_label   arpcond.ay_label,
    ay_number  arpcond.ay_number,
    ay_show1   arpcond.ay_show1,
    ay_show2   arpcond.ay_show2,
    ay_show3   arpcond.ay_show3
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarpost AS caBase OF cit_ca.vcx
Alias = [caarpost]
Tables = [arpost]
KeyFieldList = [ap_lineid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ap_ahid,
       ap_aracct,
       ap_artinum,
       ap_ayid,
       ap_belgdat,
       ap_billnr,
       ap_cashier,
       ap_colagnt,
       ap_coldate,
       ap_colnote,
       ap_credit,
       ap_date,
       ap_debit,
       ap_disdate,
       ap_dispute,
       ap_disreas,
       ap_duedat,
       ap_headid,
       ap_hiden,
       ap_hidlnid,
       ap_inclev1,
       ap_inclev2,
       ap_inclev3,
       ap_inclev4,
       ap_lineid,
       ap_pagenr,
       ap_paynum,
       ap_postid,
       ap_ref,
       ap_remcnt,
       ap_remlast,
       ap_remlev,
       ap_reserid,
       ap_stmlast,
       ap_sysdate,
       ap_userid,
       ap_vblock
    FROM arpost
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_ahid    N(8,0)  DEFAULT 0,
    ap_aracct  N(10,0) DEFAULT 0,
    ap_artinum N(4,0)  DEFAULT 0,
    ap_ayid    N(8,0)  DEFAULT 0,
    ap_belgdat D       DEFAULT {},
    ap_billnr  C(10)   DEFAULT "",
    ap_cashier N(2,0)  DEFAULT 0,
    ap_colagnt L       DEFAULT .F.,
    ap_coldate D       DEFAULT {},
    ap_colnote M       DEFAULT "",
    ap_credit  B(2)    DEFAULT 0,
    ap_date    D       DEFAULT {},
    ap_debit   B(2)    DEFAULT 0,
    ap_disdate D       DEFAULT {},
    ap_dispute L       DEFAULT .F.,
    ap_disreas C(50)   DEFAULT "",
    ap_duedat  D       DEFAULT {},
    ap_headid  N(8,0)  DEFAULT 0,
    ap_hiden   L       DEFAULT .F.,
    ap_hidlnid N(8,0)  DEFAULT 0,
    ap_inclev1 D       DEFAULT {},
    ap_inclev2 D       DEFAULT {},
    ap_inclev3 D       DEFAULT {},
    ap_inclev4 D       DEFAULT {},
    ap_lineid  N(8,0)  DEFAULT 0,
    ap_pagenr  N(3,0)  DEFAULT 0,
    ap_paynum  N(3,0)  DEFAULT 0,
    ap_postid  N(8,0)  DEFAULT 0,
    ap_ref     C(150)  DEFAULT "",
    ap_remcnt  N(2,0)  DEFAULT 0,
    ap_remlast D       DEFAULT {},
    ap_remlev  N(1,0)  DEFAULT 0,
    ap_reserid N(12,3) DEFAULT 0,
    ap_stmlast D       DEFAULT {},
    ap_sysdate D       DEFAULT {},
    ap_userid  C(10)   DEFAULT "",
    ap_vblock  L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_ahid,
    ap_aracct,
    ap_artinum,
    ap_ayid,
    ap_belgdat,
    ap_billnr,
    ap_cashier,
    ap_colagnt,
    ap_coldate,
    ap_colnote,
    ap_credit,
    ap_date,
    ap_debit,
    ap_disdate,
    ap_dispute,
    ap_disreas,
    ap_duedat,
    ap_headid,
    ap_hiden,
    ap_hidlnid,
    ap_inclev1,
    ap_inclev2,
    ap_inclev3,
    ap_inclev4,
    ap_lineid,
    ap_pagenr,
    ap_paynum,
    ap_postid,
    ap_ref,
    ap_remcnt,
    ap_remlast,
    ap_remlev,
    ap_reserid,
    ap_stmlast,
    ap_sysdate,
    ap_userid,
    ap_vblock
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_ahid    arpost.ap_ahid,
    ap_aracct  arpost.ap_aracct,
    ap_artinum arpost.ap_artinum,
    ap_ayid    arpost.ap_ayid,
    ap_belgdat arpost.ap_belgdat,
    ap_billnr  arpost.ap_billnr,
    ap_cashier arpost.ap_cashier,
    ap_colagnt arpost.ap_colagnt,
    ap_coldate arpost.ap_coldate,
    ap_colnote arpost.ap_colnote,
    ap_credit  arpost.ap_credit,
    ap_date    arpost.ap_date,
    ap_debit   arpost.ap_debit,
    ap_disdate arpost.ap_disdate,
    ap_dispute arpost.ap_dispute,
    ap_disreas arpost.ap_disreas,
    ap_duedat  arpost.ap_duedat,
    ap_headid  arpost.ap_headid,
    ap_hiden   arpost.ap_hiden,
    ap_hidlnid arpost.ap_hidlnid,
    ap_inclev1 arpost.ap_inclev1,
    ap_inclev2 arpost.ap_inclev2,
    ap_inclev3 arpost.ap_inclev3,
    ap_inclev4 arpost.ap_inclev4,
    ap_lineid  arpost.ap_lineid,
    ap_pagenr  arpost.ap_pagenr,
    ap_paynum  arpost.ap_paynum,
    ap_postid  arpost.ap_postid,
    ap_ref     arpost.ap_ref,
    ap_remcnt  arpost.ap_remcnt,
    ap_remlast arpost.ap_remlast,
    ap_remlev  arpost.ap_remlev,
    ap_reserid arpost.ap_reserid,
    ap_stmlast arpost.ap_stmlast,
    ap_sysdate arpost.ap_sysdate,
    ap_userid  arpost.ap_userid,
    ap_vblock  arpost.ap_vblock
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarremd AS caBase OF cit_ca.vcx
Alias = [caarremd]
Tables = [arremd]
KeyFieldList = [am_amid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       am_amid,
       am_credito,
       am_dayrem1,
       am_dayrem2,
       am_dayrem3,
       am_dayrem4,
       am_feerem1,
       am_feerem2,
       am_feerem3,
       am_header,
       am_label,
       am_number,
       am_perrem1,
       am_perrem2,
       am_perrem3,
       am_remtxt0,
       am_remtxt1,
       am_remtxt2,
       am_remtxt3,
       am_remtxt4
    FROM arremd
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    am_amid    N(8,0)  DEFAULT 0,
    am_credito L       DEFAULT .F.,
    am_dayrem1 N(3,0)  DEFAULT 0,
    am_dayrem2 N(3,0)  DEFAULT 0,
    am_dayrem3 N(3,0)  DEFAULT 0,
    am_dayrem4 N(3,0)  DEFAULT 0,
    am_feerem1 B(2)    DEFAULT 0,
    am_feerem2 B(2)    DEFAULT 0,
    am_feerem3 B(2)    DEFAULT 0,
    am_header  C(254)  DEFAULT "",
    am_label   C(40)   DEFAULT "",
    am_number  N(2,0)  DEFAULT 0,
    am_perrem1 N(5,2)  DEFAULT 0,
    am_perrem2 N(5,2)  DEFAULT 0,
    am_perrem3 N(5,2)  DEFAULT 0,
    am_remtxt0 M       DEFAULT "",
    am_remtxt1 M       DEFAULT "",
    am_remtxt2 M       DEFAULT "",
    am_remtxt3 M       DEFAULT "",
    am_remtxt4 M       DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    am_amid,
    am_credito,
    am_dayrem1,
    am_dayrem2,
    am_dayrem3,
    am_dayrem4,
    am_feerem1,
    am_feerem2,
    am_feerem3,
    am_header,
    am_label,
    am_number,
    am_perrem1,
    am_perrem2,
    am_perrem3,
    am_remtxt0,
    am_remtxt1,
    am_remtxt2,
    am_remtxt3,
    am_remtxt4
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    am_amid    arremd.am_amid,
    am_credito arremd.am_credito,
    am_dayrem1 arremd.am_dayrem1,
    am_dayrem2 arremd.am_dayrem2,
    am_dayrem3 arremd.am_dayrem3,
    am_dayrem4 arremd.am_dayrem4,
    am_feerem1 arremd.am_feerem1,
    am_feerem2 arremd.am_feerem2,
    am_feerem3 arremd.am_feerem3,
    am_header  arremd.am_header,
    am_label   arremd.am_label,
    am_number  arremd.am_number,
    am_perrem1 arremd.am_perrem1,
    am_perrem2 arremd.am_perrem2,
    am_perrem3 arremd.am_perrem3,
    am_remtxt0 arremd.am_remtxt0,
    am_remtxt1 arremd.am_remtxt1,
    am_remtxt2 arremd.am_remtxt2,
    am_remtxt3 arremd.am_remtxt3,
    am_remtxt4 arremd.am_remtxt4
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarremlet AS caBase OF cit_ca.vcx
Alias = [caarremlet]
Tables = [arremlet]
KeyFieldList = [ak_agid,ak_lineid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ak_agid,
       ak_amid,
       ak_balance,
       ak_compl,
       ak_deleted,
       ak_duedat,
       ak_feerem,
       ak_header,
       ak_lineid,
       ak_perrem,
       ak_printed,
       ak_remlev,
       ak_remtxt,
       ak_rmsdat,
       ak_showdoc
    FROM arremlet
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ak_agid    N(8,0)  DEFAULT 0,
    ak_amid    N(8,0)  DEFAULT 0,
    ak_balance B(2)    DEFAULT 0,
    ak_compl   L       DEFAULT .F.,
    ak_deleted L       DEFAULT .F.,
    ak_duedat  D       DEFAULT {},
    ak_feerem  B(2)    DEFAULT 0,
    ak_header  C(254)  DEFAULT "",
    ak_lineid  N(8,0)  DEFAULT 0,
    ak_perrem  B(2)    DEFAULT 0,
    ak_printed L       DEFAULT .F.,
    ak_remlev  N(1,0)  DEFAULT 0,
    ak_remtxt  M       DEFAULT "",
    ak_rmsdat  D       DEFAULT {},
    ak_showdoc L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ak_agid,
    ak_amid,
    ak_balance,
    ak_compl,
    ak_deleted,
    ak_duedat,
    ak_feerem,
    ak_header,
    ak_lineid,
    ak_perrem,
    ak_printed,
    ak_remlev,
    ak_remtxt,
    ak_rmsdat,
    ak_showdoc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ak_agid    arremlet.ak_agid,
    ak_amid    arremlet.ak_amid,
    ak_balance arremlet.ak_balance,
    ak_compl   arremlet.ak_compl,
    ak_deleted arremlet.ak_deleted,
    ak_duedat  arremlet.ak_duedat,
    ak_feerem  arremlet.ak_feerem,
    ak_header  arremlet.ak_header,
    ak_lineid  arremlet.ak_lineid,
    ak_perrem  arremlet.ak_perrem,
    ak_printed arremlet.ak_printed,
    ak_remlev  arremlet.ak_remlev,
    ak_remtxt  arremlet.ak_remtxt,
    ak_rmsdat  arremlet.ak_rmsdat,
    ak_showdoc arremlet.ak_showdoc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarticle AS caBase OF cit_ca.vcx
Alias = [caarticle]
Tables = [article]
KeyFieldList = [ar_artinum]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ar_artinum,
       ar_artityp,
       ar_bscramt,
       ar_bscruse,
       ar_bsdays,
       ar_bsdbamt,
       ar_bsdbuse,
       ar_buildng,
       ar_cmhkord,
       ar_cmobora,
       ar_cmobord,
       ar_cmoborp,
       ar_copymtp,
       ar_departm,
       ar_depuse,
       ar_discnt,
       ar_expire,
       ar_fcst,
       ar_fcstofs,
       ar_hgnr,
       ar_inactiv,
       ar_lang1,
       ar_lang10,
       ar_lang11,
       ar_lang2,
       ar_lang3,
       ar_lang4,
       ar_lang5,
       ar_lang6,
       ar_lang7,
       ar_lang8,
       ar_lang9,
       ar_layout,
       ar_main,
       ar_mangrp,
       ar_memo,
       ar_note,
       ar_notecpy,
       ar_notef,
       ar_notep,
       ar_pprice,
       ar_price,
       ar_prtype,
       ar_resourc,
       ar_return,
       ar_sgnr,
       ar_stckctl,
       ar_stckcur,
       ar_stckmin,
       ar_sub,
       ar_user1,
       ar_user2,
       ar_user3,
       ar_user4,
       ar_user5,
       ar_user6,
       ar_user7,
       ar_vat,
       ar_vat2,
       ar_voucrev
    FROM article
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_artinum N(4,0)  DEFAULT 0,
    ar_artityp N(1,0)  DEFAULT 0,
    ar_bscramt N(12,3) DEFAULT 0,
    ar_bscruse L       DEFAULT .F.,
    ar_bsdays  N(4,0)  DEFAULT 0,
    ar_bsdbamt N(12,3) DEFAULT 0,
    ar_bsdbuse L       DEFAULT .F.,
    ar_buildng C(3)    DEFAULT "",
    ar_cmhkord N(4,0)  DEFAULT 0,
    ar_cmobora L       DEFAULT .F.,
    ar_cmobord N(4,0)  DEFAULT 0,
    ar_cmoborp L       DEFAULT .F.,
    ar_copymtp L       DEFAULT .F.,
    ar_departm C(3)    DEFAULT "",
    ar_depuse  L       DEFAULT .F.,
    ar_discnt  L       DEFAULT .F.,
    ar_expire  N(3,0)  DEFAULT 0,
    ar_fcst    C(3)    DEFAULT "",
    ar_fcstofs N(2,0)  DEFAULT 0,
    ar_hgnr    N(2,0)  DEFAULT 0,
    ar_inactiv L       DEFAULT .F.,
    ar_lang1   C(35)   DEFAULT "",
    ar_lang10  C(35)   DEFAULT "",
    ar_lang11  C(35)   DEFAULT "",
    ar_lang2   C(35)   DEFAULT "",
    ar_lang3   C(35)   DEFAULT "",
    ar_lang4   C(35)   DEFAULT "",
    ar_lang5   C(35)   DEFAULT "",
    ar_lang6   C(35)   DEFAULT "",
    ar_lang7   C(35)   DEFAULT "",
    ar_lang8   C(35)   DEFAULT "",
    ar_lang9   C(35)   DEFAULT "",
    ar_layout  C(30)   DEFAULT "",
    ar_main    N(1,0)  DEFAULT 0,
    ar_mangrp  N(2,0)  DEFAULT 0,
    ar_memo    M       DEFAULT "",
    ar_note    M       DEFAULT "",
    ar_notecpy L       DEFAULT .F.,
    ar_notef   M       DEFAULT "",
    ar_notep   M       DEFAULT "",
    ar_pprice  B(2)    DEFAULT 0,
    ar_price   B(2)    DEFAULT 0,
    ar_prtype  N(2,0)  DEFAULT 0,
    ar_resourc C(3)    DEFAULT "",
    ar_return  L       DEFAULT .F.,
    ar_sgnr    N(3,0)  DEFAULT 0,
    ar_stckctl L       DEFAULT .F.,
    ar_stckcur N(6,0)  DEFAULT 0,
    ar_stckmin N(6,0)  DEFAULT 0,
    ar_sub     N(2,0)  DEFAULT 0,
    ar_user1   C(20)   DEFAULT "",
    ar_user2   C(20)   DEFAULT "",
    ar_user3   C(20)   DEFAULT "",
    ar_user4   C(50)   DEFAULT "",
    ar_user5   C(50)   DEFAULT "",
    ar_user6   C(50)   DEFAULT "",
    ar_user7   C(50)   DEFAULT "",
    ar_vat     N(1,0)  DEFAULT 0,
    ar_vat2    N(1,0)  DEFAULT 0,
    ar_voucrev L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_artinum,
    ar_artityp,
    ar_bscramt,
    ar_bscruse,
    ar_bsdays,
    ar_bsdbamt,
    ar_bsdbuse,
    ar_buildng,
    ar_cmhkord,
    ar_cmobora,
    ar_cmobord,
    ar_cmoborp,
    ar_copymtp,
    ar_departm,
    ar_depuse,
    ar_discnt,
    ar_expire,
    ar_fcst,
    ar_fcstofs,
    ar_hgnr,
    ar_inactiv,
    ar_lang1,
    ar_lang10,
    ar_lang11,
    ar_lang2,
    ar_lang3,
    ar_lang4,
    ar_lang5,
    ar_lang6,
    ar_lang7,
    ar_lang8,
    ar_lang9,
    ar_layout,
    ar_main,
    ar_mangrp,
    ar_memo,
    ar_note,
    ar_notecpy,
    ar_notef,
    ar_notep,
    ar_pprice,
    ar_price,
    ar_prtype,
    ar_resourc,
    ar_return,
    ar_sgnr,
    ar_stckctl,
    ar_stckcur,
    ar_stckmin,
    ar_sub,
    ar_user1,
    ar_user2,
    ar_user3,
    ar_user4,
    ar_user5,
    ar_user6,
    ar_user7,
    ar_vat,
    ar_vat2,
    ar_voucrev
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_artinum article.ar_artinum,
    ar_artityp article.ar_artityp,
    ar_bscramt article.ar_bscramt,
    ar_bscruse article.ar_bscruse,
    ar_bsdays  article.ar_bsdays,
    ar_bsdbamt article.ar_bsdbamt,
    ar_bsdbuse article.ar_bsdbuse,
    ar_buildng article.ar_buildng,
    ar_cmhkord article.ar_cmhkord,
    ar_cmobora article.ar_cmobora,
    ar_cmobord article.ar_cmobord,
    ar_cmoborp article.ar_cmoborp,
    ar_copymtp article.ar_copymtp,
    ar_departm article.ar_departm,
    ar_depuse  article.ar_depuse,
    ar_discnt  article.ar_discnt,
    ar_expire  article.ar_expire,
    ar_fcst    article.ar_fcst,
    ar_fcstofs article.ar_fcstofs,
    ar_hgnr    article.ar_hgnr,
    ar_inactiv article.ar_inactiv,
    ar_lang1   article.ar_lang1,
    ar_lang10  article.ar_lang10,
    ar_lang11  article.ar_lang11,
    ar_lang2   article.ar_lang2,
    ar_lang3   article.ar_lang3,
    ar_lang4   article.ar_lang4,
    ar_lang5   article.ar_lang5,
    ar_lang6   article.ar_lang6,
    ar_lang7   article.ar_lang7,
    ar_lang8   article.ar_lang8,
    ar_lang9   article.ar_lang9,
    ar_layout  article.ar_layout,
    ar_main    article.ar_main,
    ar_mangrp  article.ar_mangrp,
    ar_memo    article.ar_memo,
    ar_note    article.ar_note,
    ar_notecpy article.ar_notecpy,
    ar_notef   article.ar_notef,
    ar_notep   article.ar_notep,
    ar_pprice  article.ar_pprice,
    ar_price   article.ar_price,
    ar_prtype  article.ar_prtype,
    ar_resourc article.ar_resourc,
    ar_return  article.ar_return,
    ar_sgnr    article.ar_sgnr,
    ar_stckctl article.ar_stckctl,
    ar_stckcur article.ar_stckcur,
    ar_stckmin article.ar_stckmin,
    ar_sub     article.ar_sub,
    ar_user1   article.ar_user1,
    ar_user2   article.ar_user2,
    ar_user3   article.ar_user3,
    ar_user4   article.ar_user4,
    ar_user5   article.ar_user5,
    ar_user6   article.ar_user6,
    ar_user7   article.ar_user7,
    ar_vat     article.ar_vat,
    ar_vat2    article.ar_vat2,
    ar_voucrev article.ar_voucrev
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caasgempl AS caBase OF cit_ca.vcx
Alias = [caasgempl]
Tables = [asgempl]
KeyFieldList = [ae_aeid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ae_aeid,
       ae_emid,
       ae_from,
       ae_to,
       ae_ttnr
    FROM asgempl
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ae_aeid    N(8,0)  DEFAULT 0,
    ae_emid    I       DEFAULT 0,
    ae_from    D       DEFAULT {},
    ae_to      D       DEFAULT {},
    ae_ttnr    N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ae_aeid,
    ae_emid,
    ae_from,
    ae_to,
    ae_ttnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ae_aeid    asgempl.ae_aeid,
    ae_emid    asgempl.ae_emid,
    ae_from    asgempl.ae_from,
    ae_to      asgempl.ae_to,
    ae_ttnr    asgempl.ae_ttnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caastat AS caBase OF cit_ca.vcx
Alias = [caastat]
Tables = [astat]
KeyFieldList = [aa_addrid,aa_date]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       aa_0amount,
       aa_0amt0,
       aa_0amt1,
       aa_0amt2,
       aa_0amt3,
       aa_0amt4,
       aa_0amt5,
       aa_0amt6,
       aa_0amt7,
       aa_0amt8,
       aa_0amt9,
       aa_0cxl,
       aa_0nights,
       aa_0ns,
       aa_0res,
       aa_0vat0,
       aa_0vat1,
       aa_0vat2,
       aa_0vat3,
       aa_0vat4,
       aa_0vat5,
       aa_0vat6,
       aa_0vat7,
       aa_0vat8,
       aa_0vat9,
       aa_addrid,
       aa_camount,
       aa_camt0,
       aa_camt1,
       aa_camt2,
       aa_camt3,
       aa_camt4,
       aa_camt5,
       aa_camt6,
       aa_camt7,
       aa_camt8,
       aa_camt9,
       aa_ccxl,
       aa_cnights,
       aa_cns,
       aa_cres,
       aa_cvat0,
       aa_cvat1,
       aa_cvat2,
       aa_cvat3,
       aa_cvat4,
       aa_cvat5,
       aa_cvat6,
       aa_cvat7,
       aa_cvat8,
       aa_cvat9,
       aa_date
    FROM astat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    aa_0amount B(2)    DEFAULT 0,
    aa_0amt0   B(2)    DEFAULT 0,
    aa_0amt1   B(2)    DEFAULT 0,
    aa_0amt2   B(2)    DEFAULT 0,
    aa_0amt3   B(2)    DEFAULT 0,
    aa_0amt4   B(2)    DEFAULT 0,
    aa_0amt5   B(2)    DEFAULT 0,
    aa_0amt6   B(2)    DEFAULT 0,
    aa_0amt7   B(2)    DEFAULT 0,
    aa_0amt8   B(2)    DEFAULT 0,
    aa_0amt9   B(2)    DEFAULT 0,
    aa_0cxl    N(10,0) DEFAULT 0,
    aa_0nights N(10,0) DEFAULT 0,
    aa_0ns     N(10,0) DEFAULT 0,
    aa_0res    N(10,0) DEFAULT 0,
    aa_0vat0   B(6)    DEFAULT 0,
    aa_0vat1   B(6)    DEFAULT 0,
    aa_0vat2   B(6)    DEFAULT 0,
    aa_0vat3   B(6)    DEFAULT 0,
    aa_0vat4   B(6)    DEFAULT 0,
    aa_0vat5   B(6)    DEFAULT 0,
    aa_0vat6   B(6)    DEFAULT 0,
    aa_0vat7   B(6)    DEFAULT 0,
    aa_0vat8   B(6)    DEFAULT 0,
    aa_0vat9   B(6)    DEFAULT 0,
    aa_addrid  N(8,0)  DEFAULT 0,
    aa_camount B(2)    DEFAULT 0,
    aa_camt0   B(2)    DEFAULT 0,
    aa_camt1   B(2)    DEFAULT 0,
    aa_camt2   B(2)    DEFAULT 0,
    aa_camt3   B(2)    DEFAULT 0,
    aa_camt4   B(2)    DEFAULT 0,
    aa_camt5   B(2)    DEFAULT 0,
    aa_camt6   B(2)    DEFAULT 0,
    aa_camt7   B(2)    DEFAULT 0,
    aa_camt8   B(2)    DEFAULT 0,
    aa_camt9   B(2)    DEFAULT 0,
    aa_ccxl    N(10,0) DEFAULT 0,
    aa_cnights N(10,0) DEFAULT 0,
    aa_cns     N(10,0) DEFAULT 0,
    aa_cres    N(10,0) DEFAULT 0,
    aa_cvat0   B(6)    DEFAULT 0,
    aa_cvat1   B(6)    DEFAULT 0,
    aa_cvat2   B(6)    DEFAULT 0,
    aa_cvat3   B(6)    DEFAULT 0,
    aa_cvat4   B(6)    DEFAULT 0,
    aa_cvat5   B(6)    DEFAULT 0,
    aa_cvat6   B(6)    DEFAULT 0,
    aa_cvat7   B(6)    DEFAULT 0,
    aa_cvat8   B(6)    DEFAULT 0,
    aa_cvat9   B(6)    DEFAULT 0,
    aa_date    D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aa_0amount,
    aa_0amt0,
    aa_0amt1,
    aa_0amt2,
    aa_0amt3,
    aa_0amt4,
    aa_0amt5,
    aa_0amt6,
    aa_0amt7,
    aa_0amt8,
    aa_0amt9,
    aa_0cxl,
    aa_0nights,
    aa_0ns,
    aa_0res,
    aa_0vat0,
    aa_0vat1,
    aa_0vat2,
    aa_0vat3,
    aa_0vat4,
    aa_0vat5,
    aa_0vat6,
    aa_0vat7,
    aa_0vat8,
    aa_0vat9,
    aa_addrid,
    aa_camount,
    aa_camt0,
    aa_camt1,
    aa_camt2,
    aa_camt3,
    aa_camt4,
    aa_camt5,
    aa_camt6,
    aa_camt7,
    aa_camt8,
    aa_camt9,
    aa_ccxl,
    aa_cnights,
    aa_cns,
    aa_cres,
    aa_cvat0,
    aa_cvat1,
    aa_cvat2,
    aa_cvat3,
    aa_cvat4,
    aa_cvat5,
    aa_cvat6,
    aa_cvat7,
    aa_cvat8,
    aa_cvat9,
    aa_date
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aa_0amount astat.aa_0amount,
    aa_0amt0   astat.aa_0amt0,
    aa_0amt1   astat.aa_0amt1,
    aa_0amt2   astat.aa_0amt2,
    aa_0amt3   astat.aa_0amt3,
    aa_0amt4   astat.aa_0amt4,
    aa_0amt5   astat.aa_0amt5,
    aa_0amt6   astat.aa_0amt6,
    aa_0amt7   astat.aa_0amt7,
    aa_0amt8   astat.aa_0amt8,
    aa_0amt9   astat.aa_0amt9,
    aa_0cxl    astat.aa_0cxl,
    aa_0nights astat.aa_0nights,
    aa_0ns     astat.aa_0ns,
    aa_0res    astat.aa_0res,
    aa_0vat0   astat.aa_0vat0,
    aa_0vat1   astat.aa_0vat1,
    aa_0vat2   astat.aa_0vat2,
    aa_0vat3   astat.aa_0vat3,
    aa_0vat4   astat.aa_0vat4,
    aa_0vat5   astat.aa_0vat5,
    aa_0vat6   astat.aa_0vat6,
    aa_0vat7   astat.aa_0vat7,
    aa_0vat8   astat.aa_0vat8,
    aa_0vat9   astat.aa_0vat9,
    aa_addrid  astat.aa_addrid,
    aa_camount astat.aa_camount,
    aa_camt0   astat.aa_camt0,
    aa_camt1   astat.aa_camt1,
    aa_camt2   astat.aa_camt2,
    aa_camt3   astat.aa_camt3,
    aa_camt4   astat.aa_camt4,
    aa_camt5   astat.aa_camt5,
    aa_camt6   astat.aa_camt6,
    aa_camt7   astat.aa_camt7,
    aa_camt8   astat.aa_camt8,
    aa_camt9   astat.aa_camt9,
    aa_ccxl    astat.aa_ccxl,
    aa_cnights astat.aa_cnights,
    aa_cns     astat.aa_cns,
    aa_cres    astat.aa_cres,
    aa_cvat0   astat.aa_cvat0,
    aa_cvat1   astat.aa_cvat1,
    aa_cvat2   astat.aa_cvat2,
    aa_cvat3   astat.aa_cvat3,
    aa_cvat4   astat.aa_cvat4,
    aa_cvat5   astat.aa_cvat5,
    aa_cvat6   astat.aa_cvat6,
    aa_cvat7   astat.aa_cvat7,
    aa_cvat8   astat.aa_cvat8,
    aa_cvat9   astat.aa_cvat9,
    aa_date    astat.aa_date
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caavailab AS caBase OF cit_ca.vcx
Alias = [caavailab]
Tables = [availab]
KeyFieldList = [av_date,av_roomtyp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       av_allott,
       av_altall,
       av_avail,
       av_booked,
       av_date,
       av_definit,
       av_inpers,
       av_inroom,
       av_ooorder,
       av_ooservc,
       av_option,
       av_pick,
       av_roomtyp,
       av_tentat,
       av_waiting
    FROM availab
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    av_allott  N(4,0)  DEFAULT 0,
    av_altall  N(4,0)  DEFAULT 0,
    av_avail   N(4,0)  DEFAULT 0,
    av_booked  N(4,0)  DEFAULT 0,
    av_date    D       DEFAULT {},
    av_definit N(7,2)  DEFAULT 0,
    av_inpers  N(4,0)  DEFAULT 0,
    av_inroom  N(4,0)  DEFAULT 0,
    av_ooorder N(4,0)  DEFAULT 0,
    av_ooservc N(4,0)  DEFAULT 0,
    av_option  N(7,2)  DEFAULT 0,
    av_pick    N(4,0)  DEFAULT 0,
    av_roomtyp C(4)    DEFAULT "",
    av_tentat  N(7,2)  DEFAULT 0,
    av_waiting N(7,2)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    av_allott,
    av_altall,
    av_avail,
    av_booked,
    av_date,
    av_definit,
    av_inpers,
    av_inroom,
    av_ooorder,
    av_ooservc,
    av_option,
    av_pick,
    av_roomtyp,
    av_tentat,
    av_waiting
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    av_allott  availab.av_allott,
    av_altall  availab.av_altall,
    av_avail   availab.av_avail,
    av_booked  availab.av_booked,
    av_date    availab.av_date,
    av_definit availab.av_definit,
    av_inpers  availab.av_inpers,
    av_inroom  availab.av_inroom,
    av_ooorder availab.av_ooorder,
    av_ooservc availab.av_ooservc,
    av_option  availab.av_option,
    av_pick    availab.av_pick,
    av_roomtyp availab.av_roomtyp,
    av_tentat  availab.av_tentat,
    av_waiting availab.av_waiting
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caazepick AS caBase OF cit_ca.vcx
Alias = [caazepick]
Tables = [azepick]
KeyFieldList = [aq_label,aq_charcod,aq_numcod]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       aq_charcod,
       aq_dval1,
       aq_dval2,
       aq_label,
       aq_lang1,
       aq_lang10,
       aq_lang11,
       aq_lang2,
       aq_lang3,
       aq_lang4,
       aq_lang5,
       aq_lang6,
       aq_lang7,
       aq_lang8,
       aq_lang9,
       aq_numcod,
       aq_nval1
    FROM azepick
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    aq_charcod C(3)    DEFAULT "",
    aq_dval1   D       DEFAULT {},
    aq_dval2   D       DEFAULT {},
    aq_label   C(10)   DEFAULT "",
    aq_lang1   C(25)   DEFAULT "",
    aq_lang10  C(25)   DEFAULT "",
    aq_lang11  C(25)   DEFAULT "",
    aq_lang2   C(25)   DEFAULT "",
    aq_lang3   C(25)   DEFAULT "",
    aq_lang4   C(25)   DEFAULT "",
    aq_lang5   C(25)   DEFAULT "",
    aq_lang6   C(25)   DEFAULT "",
    aq_lang7   C(25)   DEFAULT "",
    aq_lang8   C(25)   DEFAULT "",
    aq_lang9   C(25)   DEFAULT "",
    aq_numcod  N(3,0)  DEFAULT 0,
    aq_nval1   N(10,2) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aq_charcod,
    aq_dval1,
    aq_dval2,
    aq_label,
    aq_lang1,
    aq_lang10,
    aq_lang11,
    aq_lang2,
    aq_lang3,
    aq_lang4,
    aq_lang5,
    aq_lang6,
    aq_lang7,
    aq_lang8,
    aq_lang9,
    aq_numcod,
    aq_nval1
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aq_charcod azepick.aq_charcod,
    aq_dval1   azepick.aq_dval1,
    aq_dval2   azepick.aq_dval2,
    aq_label   azepick.aq_label,
    aq_lang1   azepick.aq_lang1,
    aq_lang10  azepick.aq_lang10,
    aq_lang11  azepick.aq_lang11,
    aq_lang2   azepick.aq_lang2,
    aq_lang3   azepick.aq_lang3,
    aq_lang4   azepick.aq_lang4,
    aq_lang5   azepick.aq_lang5,
    aq_lang6   azepick.aq_lang6,
    aq_lang7   azepick.aq_lang7,
    aq_lang8   azepick.aq_lang8,
    aq_lang9   azepick.aq_lang9,
    aq_numcod  azepick.aq_numcod,
    aq_nval1   azepick.aq_nval1
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabanken AS caBase OF cit_ca.vcx
Alias = [cabanken]
Tables = [banken]
KeyFieldList = [ba_baid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ba_baid,
       blz,
       name,
       ort
    FROM banken
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ba_baid    N(8,0)  DEFAULT 0,
    blz        N(8,0)  DEFAULT 0,
    name       C(50)   DEFAULT "",
    ort        C(50)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ba_baid,
    blz,
    name,
    ort
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ba_baid    banken.ba_baid,
    blz        banken.blz,
    name       banken.name,
    ort        banken.ort
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabanquet AS caBase OF cit_ca.vcx
Alias = [cabanquet]
Tables = [banquet]
KeyFieldList = [bq_bqid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bq_artinum,
       bq_bqid,
       bq_calc,
       bq_confirm,
       bq_date,
       bq_descrip,
       bq_endtime,
       bq_memo,
       bq_menu,
       bq_price,
       bq_reserid,
       bq_roomnum,
       bq_rsrc,
       bq_rsrcqty,
       bq_time,
       bq_units,
       bq_where,
       bq_who
    FROM banquet
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_artinum N(4,0)  DEFAULT 0,
    bq_bqid    I       DEFAULT 0,
    bq_calc    L       DEFAULT .F.,
    bq_confirm L       DEFAULT .F.,
    bq_date    D       DEFAULT {},
    bq_descrip C(25)   DEFAULT "",
    bq_endtime C(5)    DEFAULT "",
    bq_memo    M       DEFAULT "",
    bq_menu    C(3)    DEFAULT "",
    bq_price   B(2)    DEFAULT 0,
    bq_reserid N(12,3) DEFAULT 0,
    bq_roomnum C(4)    DEFAULT "",
    bq_rsrc    C(3)    DEFAULT "",
    bq_rsrcqty N(3,0)  DEFAULT 0,
    bq_time    C(5)    DEFAULT "",
    bq_units   N(4,0)  DEFAULT 0,
    bq_where   C(20)   DEFAULT "",
    bq_who     C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_artinum,
    bq_bqid,
    bq_calc,
    bq_confirm,
    bq_date,
    bq_descrip,
    bq_endtime,
    bq_memo,
    bq_menu,
    bq_price,
    bq_reserid,
    bq_roomnum,
    bq_rsrc,
    bq_rsrcqty,
    bq_time,
    bq_units,
    bq_where,
    bq_who
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_artinum banquet.bq_artinum,
    bq_bqid    banquet.bq_bqid,
    bq_calc    banquet.bq_calc,
    bq_confirm banquet.bq_confirm,
    bq_date    banquet.bq_date,
    bq_descrip banquet.bq_descrip,
    bq_endtime banquet.bq_endtime,
    bq_memo    banquet.bq_memo,
    bq_menu    banquet.bq_menu,
    bq_price   banquet.bq_price,
    bq_reserid banquet.bq_reserid,
    bq_roomnum banquet.bq_roomnum,
    bq_rsrc    banquet.bq_rsrc,
    bq_rsrcqty banquet.bq_rsrcqty,
    bq_time    banquet.bq_time,
    bq_units   banquet.bq_units,
    bq_where   banquet.bq_where,
    bq_who     banquet.bq_who
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabaselper AS caBase OF cit_ca.vcx
Alias = [cabaselper]
Tables = [baselper]
KeyFieldList = [bp_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bp_departm,
       bp_fname,
       bp_id,
       bp_lname,
       bp_positio
    FROM baselper
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bp_departm C(3)    DEFAULT "",
    bp_fname   C(20)   DEFAULT "",
    bp_id      N(8,0)  DEFAULT 0,
    bp_lname   C(30)   DEFAULT "",
    bp_positio C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bp_departm,
    bp_fname,
    bp_id,
    bp_lname,
    bp_positio
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bp_departm baselper.bp_departm,
    bp_fname   baselper.bp_fname,
    bp_id      baselper.bp_id,
    bp_lname   baselper.bp_lname,
    bp_positio baselper.bp_positio
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabgddays AS caBase OF cit_ca.vcx
Alias = [cabgddays]
Tables = [bgddays]
KeyFieldList = [bd_key,bd_day]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bd_day,
       bd_key,
       bd_revenue,
       bd_roomnts
    FROM bgddays
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bd_day     N(3,0)  DEFAULT 0,
    bd_key     C(50)   DEFAULT "",
    bd_revenue B(2)    DEFAULT 0,
    bd_roomnts N(6,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bd_day,
    bd_key,
    bd_revenue,
    bd_roomnts
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bd_day     bgddays.bd_day,
    bd_key     bgddays.bd_key,
    bd_revenue bgddays.bd_revenue,
    bd_roomnts bgddays.bd_roomnts
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabgdpayms AS caBase OF cit_ca.vcx
Alias = [cabgdpayms]
Tables = [bgdpayms]
KeyFieldList = [by_bpid,by_year,by_period]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       by_bospart,
       by_bpid,
       by_label,
       by_montpay,
       by_paybase,
       by_period,
       by_suppl1,
       by_suppl2,
       by_suppl3,
       by_suppl4,
       by_suppl5,
       by_suppl6,
       by_suppl7,
       by_suppl8,
       by_suppl9,
       by_year
    FROM bgdpayms
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    by_bospart N(6,2)  DEFAULT 0,
    by_bpid    N(8,0)  DEFAULT 0,
    by_label   C(10)   DEFAULT "",
    by_montpay B(2)    DEFAULT 0,
    by_paybase N(6,2)  DEFAULT 0,
    by_period  N(2,0)  DEFAULT 0,
    by_suppl1  B(2)    DEFAULT 0,
    by_suppl2  B(2)    DEFAULT 0,
    by_suppl3  B(2)    DEFAULT 0,
    by_suppl4  B(2)    DEFAULT 0,
    by_suppl5  B(2)    DEFAULT 0,
    by_suppl6  B(2)    DEFAULT 0,
    by_suppl7  B(2)    DEFAULT 0,
    by_suppl8  B(2)    DEFAULT 0,
    by_suppl9  B(2)    DEFAULT 0,
    by_year    N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    by_bospart,
    by_bpid,
    by_label,
    by_montpay,
    by_paybase,
    by_period,
    by_suppl1,
    by_suppl2,
    by_suppl3,
    by_suppl4,
    by_suppl5,
    by_suppl6,
    by_suppl7,
    by_suppl8,
    by_suppl9,
    by_year
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    by_bospart bgdpayms.by_bospart,
    by_bpid    bgdpayms.by_bpid,
    by_label   bgdpayms.by_label,
    by_montpay bgdpayms.by_montpay,
    by_paybase bgdpayms.by_paybase,
    by_period  bgdpayms.by_period,
    by_suppl1  bgdpayms.by_suppl1,
    by_suppl2  bgdpayms.by_suppl2,
    by_suppl3  bgdpayms.by_suppl3,
    by_suppl4  bgdpayms.by_suppl4,
    by_suppl5  bgdpayms.by_suppl5,
    by_suppl6  bgdpayms.by_suppl6,
    by_suppl7  bgdpayms.by_suppl7,
    by_suppl8  bgdpayms.by_suppl8,
    by_suppl9  bgdpayms.by_suppl9,
    by_year    bgdpayms.by_year
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabillinst AS caBase OF cit_ca.vcx
Alias = [cabillinst]
Tables = [billinst]
KeyFieldList = [bi_reserid,bi_day]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bi_day,
       bi_reserid
    FROM billinst
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bi_day     N(3,0)  DEFAULT 0,
    bi_reserid N(12,3) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bi_day,
    bi_reserid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bi_day     billinst.bi_day,
    bi_reserid billinst.bi_reserid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabillnum AS caBase OF cit_ca.vcx
Alias = [cabillnum]
Tables = [billnum]
KeyFieldList = [bn_billnum]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bn_address,
       bn_addrid,
       bn_adrchgd,
       bn_amount,
       bn_apid,
       bn_ayid,
       bn_billnum,
       bn_cxldate,
       bn_date,
       bn_fpid,
       bn_fpnr,
       bn_history,
       bn_negnum,
       bn_newnum,
       bn_oldaddr,
       bn_oldnum,
       bn_oldwin,
       bn_paynum,
       bn_pdf,
       bn_qrcode,
       bn_qrcodec,
       bn_reserid,
       bn_rsid,
       bn_status,
       bn_type,
       bn_userid,
       bn_window
    FROM billnum
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bn_address M       DEFAULT "",
    bn_addrid  N(8,0)  DEFAULT 0,
    bn_adrchgd D       DEFAULT {},
    bn_amount  B(2)    DEFAULT 0,
    bn_apid    N(8,0)  DEFAULT 0,
    bn_ayid    N(8,0)  DEFAULT 0,
    bn_billnum C(10)   DEFAULT "",
    bn_cxldate D       DEFAULT {},
    bn_date    D       DEFAULT {},
    bn_fpid    N(8,0)  DEFAULT 0,
    bn_fpnr    N(2,0)  DEFAULT 0,
    bn_history M       DEFAULT "",
    bn_negnum  C(10)   DEFAULT "",
    bn_newnum  C(10)   DEFAULT "",
    bn_oldaddr I       DEFAULT 0,
    bn_oldnum  C(10)   DEFAULT "",
    bn_oldwin  I       DEFAULT 0,
    bn_paynum  N(3,0)  DEFAULT 0,
    bn_pdf     L       DEFAULT .F.,
    bn_qrcode  C(254)  DEFAULT "",
    bn_qrcodec C(254)  DEFAULT "",
    bn_reserid N(12,3) DEFAULT 0,
    bn_rsid    I       DEFAULT 0,
    bn_status  C(3)    DEFAULT "",
    bn_type    N(1,0)  DEFAULT 0,
    bn_userid  C(10)   DEFAULT "",
    bn_window  I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bn_address,
    bn_addrid,
    bn_adrchgd,
    bn_amount,
    bn_apid,
    bn_ayid,
    bn_billnum,
    bn_cxldate,
    bn_date,
    bn_fpid,
    bn_fpnr,
    bn_history,
    bn_negnum,
    bn_newnum,
    bn_oldaddr,
    bn_oldnum,
    bn_oldwin,
    bn_paynum,
    bn_pdf,
    bn_qrcode,
    bn_qrcodec,
    bn_reserid,
    bn_rsid,
    bn_status,
    bn_type,
    bn_userid,
    bn_window
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bn_address billnum.bn_address,
    bn_addrid  billnum.bn_addrid,
    bn_adrchgd billnum.bn_adrchgd,
    bn_amount  billnum.bn_amount,
    bn_apid    billnum.bn_apid,
    bn_ayid    billnum.bn_ayid,
    bn_billnum billnum.bn_billnum,
    bn_cxldate billnum.bn_cxldate,
    bn_date    billnum.bn_date,
    bn_fpid    billnum.bn_fpid,
    bn_fpnr    billnum.bn_fpnr,
    bn_history billnum.bn_history,
    bn_negnum  billnum.bn_negnum,
    bn_newnum  billnum.bn_newnum,
    bn_oldaddr billnum.bn_oldaddr,
    bn_oldnum  billnum.bn_oldnum,
    bn_oldwin  billnum.bn_oldwin,
    bn_paynum  billnum.bn_paynum,
    bn_pdf     billnum.bn_pdf,
    bn_qrcode  billnum.bn_qrcode,
    bn_qrcodec billnum.bn_qrcodec,
    bn_reserid billnum.bn_reserid,
    bn_rsid    billnum.bn_rsid,
    bn_status  billnum.bn_status,
    bn_type    billnum.bn_type,
    bn_userid  billnum.bn_userid,
    bn_window  billnum.bn_window
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabproener AS caBase OF cit_ca.vcx
Alias = [cabproener]
Tables = [bproener]
KeyFieldList = [be_benum]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       be_benum,
       be_lang1,
       be_lang2,
       be_lang3,
       be_lang4,
       be_lang5,
       be_lang6,
       be_lang7,
       be_lang8,
       be_lang9,
       be_standar,
       be_tempera
    FROM bproener
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    be_benum   N(2,0)  DEFAULT 0,
    be_lang1   C(30)   DEFAULT "",
    be_lang2   C(30)   DEFAULT "",
    be_lang3   C(30)   DEFAULT "",
    be_lang4   C(30)   DEFAULT "",
    be_lang5   C(30)   DEFAULT "",
    be_lang6   C(30)   DEFAULT "",
    be_lang7   C(30)   DEFAULT "",
    be_lang8   C(30)   DEFAULT "",
    be_lang9   C(30)   DEFAULT "",
    be_standar L       DEFAULT .F.,
    be_tempera N(4,1)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    be_benum,
    be_lang1,
    be_lang2,
    be_lang3,
    be_lang4,
    be_lang5,
    be_lang6,
    be_lang7,
    be_lang8,
    be_lang9,
    be_standar,
    be_tempera
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    be_benum   bproener.be_benum,
    be_lang1   bproener.be_lang1,
    be_lang2   bproener.be_lang2,
    be_lang3   bproener.be_lang3,
    be_lang4   bproener.be_lang4,
    be_lang5   bproener.be_lang5,
    be_lang6   bproener.be_lang6,
    be_lang7   bproener.be_lang7,
    be_lang8   bproener.be_lang8,
    be_lang9   bproener.be_lang9,
    be_standar bproener.be_standar,
    be_tempera bproener.be_tempera
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabqbesthl AS caBase OF cit_ca.vcx
Alias = [cabqbesthl]
Tables = [bqbesthl]
KeyFieldList = [bq_kz]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bq_kz,
       bq_order,
       bq_text
    FROM bqbesthl
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_kz      C(4)    DEFAULT "",
    bq_order   N(3,0)  DEFAULT 0,
    bq_text    C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_kz,
    bq_order,
    bq_text
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_kz      bqbesthl.bq_kz,
    bq_order   bqbesthl.bq_order,
    bq_text    bqbesthl.bq_text
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabsacct AS caBase OF cit_ca.vcx
Alias = [cabsacct]
Tables = [bsacct]
KeyFieldList = [bb_bbid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bb_addrid,
       bb_adid,
       bb_bbid,
       bb_email,
       bb_history,
       bb_inactiv
    FROM bsacct
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bb_addrid  N(8,0)  DEFAULT 0,
    bb_adid    I       DEFAULT 0,
    bb_bbid    I       DEFAULT 0,
    bb_email   L       DEFAULT .F.,
    bb_history M       DEFAULT "",
    bb_inactiv L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bb_addrid,
    bb_adid,
    bb_bbid,
    bb_email,
    bb_history,
    bb_inactiv
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bb_addrid  bsacct.bb_addrid,
    bb_adid    bsacct.bb_adid,
    bb_bbid    bsacct.bb_bbid,
    bb_email   bsacct.bb_email,
    bb_history bsacct.bb_history,
    bb_inactiv bsacct.bb_inactiv
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabscard AS caBase OF cit_ca.vcx
Alias = [cabscard]
Tables = [bscard]
KeyFieldList = [bc_bcid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bc_addrid,
       bc_apid,
       bc_bbid,
       bc_bcid,
       bc_cardid,
       bc_content,
       bc_deleted,
       bc_name,
       bc_timech,
       bc_timecr,
       bc_timedl,
       bc_userch,
       bc_usercr,
       bc_userdl
    FROM bscard
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bc_addrid  I       DEFAULT 0,
    bc_apid    I       DEFAULT 0,
    bc_bbid    I       DEFAULT 0,
    bc_bcid    I       DEFAULT 0,
    bc_cardid  C(12)   DEFAULT "",
    bc_content C(16)   DEFAULT "",
    bc_deleted L       DEFAULT .F.,
    bc_name    C(100)  DEFAULT "",
    bc_timech  T       DEFAULT {},
    bc_timecr  T       DEFAULT {},
    bc_timedl  T       DEFAULT {},
    bc_userch  C(10)   DEFAULT "",
    bc_usercr  C(10)   DEFAULT "",
    bc_userdl  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bc_addrid,
    bc_apid,
    bc_bbid,
    bc_bcid,
    bc_cardid,
    bc_content,
    bc_deleted,
    bc_name,
    bc_timech,
    bc_timecr,
    bc_timedl,
    bc_userch,
    bc_usercr,
    bc_userdl
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bc_addrid  bscard.bc_addrid,
    bc_apid    bscard.bc_apid,
    bc_bbid    bscard.bc_bbid,
    bc_bcid    bscard.bc_bcid,
    bc_cardid  bscard.bc_cardid,
    bc_content bscard.bc_content,
    bc_deleted bscard.bc_deleted,
    bc_name    bscard.bc_name,
    bc_timech  bscard.bc_timech,
    bc_timecr  bscard.bc_timecr,
    bc_timedl  bscard.bc_timedl,
    bc_userch  bscard.bc_userch,
    bc_usercr  bscard.bc_usercr,
    bc_userdl  bscard.bc_userdl
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabspendin AS caBase OF cit_ca.vcx
Alias = [cabspendin]
Tables = [bspendin]
KeyFieldList = [bs_bsid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bs_amount,
       bs_appl,
       bs_artinum,
       bs_bbid,
       bs_bcid,
       bs_billnum,
       bs_bsid,
       bs_bspayid,
       bs_cancel,
       bs_date,
       bs_descrip,
       bs_hotcode,
       bs_note,
       bs_points,
       bs_postid,
       bs_qty,
       bs_sysdate,
       bs_type,
       bs_userid,
       bs_vdate,
       bs_waitnr
    FROM bspendin
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bs_amount  Y       DEFAULT 0,
    bs_appl    N(1,0)  DEFAULT 0,
    bs_artinum I       DEFAULT 0,
    bs_bbid    I       DEFAULT 0,
    bs_bcid    I       DEFAULT 0,
    bs_billnum C(10)   DEFAULT "",
    bs_bsid    I       DEFAULT 0,
    bs_bspayid I       DEFAULT 0,
    bs_cancel  L       DEFAULT .F.,
    bs_date    T       DEFAULT {},
    bs_descrip C(100)  DEFAULT "",
    bs_hotcode C(3)    DEFAULT "",
    bs_note    C(254)  DEFAULT "",
    bs_points  N(10,0) DEFAULT 0,
    bs_postid  I       DEFAULT 0,
    bs_qty     N(8,3)  DEFAULT 0,
    bs_sysdate D       DEFAULT {},
    bs_type    N(1,0)  DEFAULT 0,
    bs_userid  C(10)   DEFAULT "",
    bs_vdate   D       DEFAULT {},
    bs_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bs_amount,
    bs_appl,
    bs_artinum,
    bs_bbid,
    bs_bcid,
    bs_billnum,
    bs_bsid,
    bs_bspayid,
    bs_cancel,
    bs_date,
    bs_descrip,
    bs_hotcode,
    bs_note,
    bs_points,
    bs_postid,
    bs_qty,
    bs_sysdate,
    bs_type,
    bs_userid,
    bs_vdate,
    bs_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bs_amount  bspendin.bs_amount,
    bs_appl    bspendin.bs_appl,
    bs_artinum bspendin.bs_artinum,
    bs_bbid    bspendin.bs_bbid,
    bs_bcid    bspendin.bs_bcid,
    bs_billnum bspendin.bs_billnum,
    bs_bsid    bspendin.bs_bsid,
    bs_bspayid bspendin.bs_bspayid,
    bs_cancel  bspendin.bs_cancel,
    bs_date    bspendin.bs_date,
    bs_descrip bspendin.bs_descrip,
    bs_hotcode bspendin.bs_hotcode,
    bs_note    bspendin.bs_note,
    bs_points  bspendin.bs_points,
    bs_postid  bspendin.bs_postid,
    bs_qty     bspendin.bs_qty,
    bs_sysdate bspendin.bs_sysdate,
    bs_type    bspendin.bs_type,
    bs_userid  bspendin.bs_userid,
    bs_vdate   bspendin.bs_vdate,
    bs_waitnr  bspendin.bs_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabspost AS caBase OF cit_ca.vcx
Alias = [cabspost]
Tables = [bspost]
KeyFieldList = [bs_bsid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bs_amount,
       bs_appl,
       bs_artinum,
       bs_bbid,
       bs_bcid,
       bs_billnum,
       bs_bsid,
       bs_bspayid,
       bs_cancel,
       bs_date,
       bs_descrip,
       bs_hotcode,
       bs_note,
       bs_points,
       bs_postid,
       bs_qty,
       bs_sysdate,
       bs_type,
       bs_userid,
       bs_vdate,
       bs_waitnr
    FROM bspost
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bs_amount  Y       DEFAULT 0,
    bs_appl    N(1,0)  DEFAULT 0,
    bs_artinum I       DEFAULT 0,
    bs_bbid    I       DEFAULT 0,
    bs_bcid    I       DEFAULT 0,
    bs_billnum C(10)   DEFAULT "",
    bs_bsid    I       DEFAULT 0,
    bs_bspayid I       DEFAULT 0,
    bs_cancel  L       DEFAULT .F.,
    bs_date    T       DEFAULT {},
    bs_descrip C(100)  DEFAULT "",
    bs_hotcode C(3)    DEFAULT "",
    bs_note    C(254)  DEFAULT "",
    bs_points  N(10,0) DEFAULT 0,
    bs_postid  I       DEFAULT 0,
    bs_qty     N(8,3)  DEFAULT 0,
    bs_sysdate D       DEFAULT {},
    bs_type    N(1,0)  DEFAULT 0,
    bs_userid  C(10)   DEFAULT "",
    bs_vdate   D       DEFAULT {},
    bs_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bs_amount,
    bs_appl,
    bs_artinum,
    bs_bbid,
    bs_bcid,
    bs_billnum,
    bs_bsid,
    bs_bspayid,
    bs_cancel,
    bs_date,
    bs_descrip,
    bs_hotcode,
    bs_note,
    bs_points,
    bs_postid,
    bs_qty,
    bs_sysdate,
    bs_type,
    bs_userid,
    bs_vdate,
    bs_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bs_amount  bspost.bs_amount,
    bs_appl    bspost.bs_appl,
    bs_artinum bspost.bs_artinum,
    bs_bbid    bspost.bs_bbid,
    bs_bcid    bspost.bs_bcid,
    bs_billnum bspost.bs_billnum,
    bs_bsid    bspost.bs_bsid,
    bs_bspayid bspost.bs_bspayid,
    bs_cancel  bspost.bs_cancel,
    bs_date    bspost.bs_date,
    bs_descrip bspost.bs_descrip,
    bs_hotcode bspost.bs_hotcode,
    bs_note    bspost.bs_note,
    bs_points  bspost.bs_points,
    bs_postid  bspost.bs_postid,
    bs_qty     bspost.bs_qty,
    bs_sysdate bspost.bs_sysdate,
    bs_type    bspost.bs_type,
    bs_userid  bspost.bs_userid,
    bs_vdate   bspost.bs_vdate,
    bs_waitnr  bspost.bs_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabudget AS caBase OF cit_ca.vcx
Alias = [cabudget]
Tables = [budget]
KeyFieldList = [bg_year,bg_period,bg_artinum,bg_label,bg_main,bg_market,bg_sub,bg_hgnr,bg_sgnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bg_artinum,
       bg_hgnr,
       bg_label,
       bg_main,
       bg_market,
       bg_note,
       bg_period,
       bg_revenue,
       bg_roomnts,
       bg_sgnr,
       bg_sub,
       bg_year
    FROM budget
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bg_artinum N(4,0)  DEFAULT 0,
    bg_hgnr    N(2,0)  DEFAULT 0,
    bg_label   C(20)   DEFAULT "",
    bg_main    N(1,0)  DEFAULT 0,
    bg_market  C(3)    DEFAULT "",
    bg_note    M       DEFAULT "",
    bg_period  N(2,0)  DEFAULT 0,
    bg_revenue B(0)    DEFAULT 0,
    bg_roomnts N(6,0)  DEFAULT 0,
    bg_sgnr    N(3,0)  DEFAULT 0,
    bg_sub     N(2,0)  DEFAULT 0,
    bg_year    N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bg_artinum,
    bg_hgnr,
    bg_label,
    bg_main,
    bg_market,
    bg_note,
    bg_period,
    bg_revenue,
    bg_roomnts,
    bg_sgnr,
    bg_sub,
    bg_year
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bg_artinum budget.bg_artinum,
    bg_hgnr    budget.bg_hgnr,
    bg_label   budget.bg_label,
    bg_main    budget.bg_main,
    bg_market  budget.bg_market,
    bg_note    budget.bg_note,
    bg_period  budget.bg_period,
    bg_revenue budget.bg_revenue,
    bg_roomnts budget.bg_roomnts,
    bg_sgnr    budget.bg_sgnr,
    bg_sub     budget.bg_sub,
    bg_year    budget.bg_year
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabuilding AS caBase OF cit_ca.vcx
Alias = [cabuilding]
Tables = [building]
KeyFieldList = [bu_buid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bu_active,
       bu_billnrb,
       bu_buid,
       bu_buildng,
       bu_cashnr,
       bu_dontsum,
       bu_dontswb,
       bu_hired,
       bu_lang1,
       bu_lang10,
       bu_lang11,
       bu_lang2,
       bu_lang3,
       bu_lang4,
       bu_lang5,
       bu_lang6,
       bu_lang7,
       bu_lang8,
       bu_lang9,
       bu_note,
       bu_numcode,
       bu_webtop
    FROM building
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bu_active  L       DEFAULT .F.,
    bu_billnrb N(2,0)  DEFAULT 0,
    bu_buid    I       DEFAULT 0,
    bu_buildng C(3)    DEFAULT "",
    bu_cashnr  N(3,0)  DEFAULT 0,
    bu_dontsum L       DEFAULT .F.,
    bu_dontswb L       DEFAULT .F.,
    bu_hired   L       DEFAULT .F.,
    bu_lang1   C(80)   DEFAULT "",
    bu_lang10  C(80)   DEFAULT "",
    bu_lang11  C(80)   DEFAULT "",
    bu_lang2   C(80)   DEFAULT "",
    bu_lang3   C(80)   DEFAULT "",
    bu_lang4   C(80)   DEFAULT "",
    bu_lang5   C(80)   DEFAULT "",
    bu_lang6   C(80)   DEFAULT "",
    bu_lang7   C(80)   DEFAULT "",
    bu_lang8   C(80)   DEFAULT "",
    bu_lang9   C(80)   DEFAULT "",
    bu_note    M       DEFAULT "",
    bu_numcode N(2,0)  DEFAULT 0,
    bu_webtop  C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bu_active,
    bu_billnrb,
    bu_buid,
    bu_buildng,
    bu_cashnr,
    bu_dontsum,
    bu_dontswb,
    bu_hired,
    bu_lang1,
    bu_lang10,
    bu_lang11,
    bu_lang2,
    bu_lang3,
    bu_lang4,
    bu_lang5,
    bu_lang6,
    bu_lang7,
    bu_lang8,
    bu_lang9,
    bu_note,
    bu_numcode,
    bu_webtop
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bu_active  building.bu_active,
    bu_billnrb building.bu_billnrb,
    bu_buid    building.bu_buid,
    bu_buildng building.bu_buildng,
    bu_cashnr  building.bu_cashnr,
    bu_dontsum building.bu_dontsum,
    bu_dontswb building.bu_dontswb,
    bu_hired   building.bu_hired,
    bu_lang1   building.bu_lang1,
    bu_lang10  building.bu_lang10,
    bu_lang11  building.bu_lang11,
    bu_lang2   building.bu_lang2,
    bu_lang3   building.bu_lang3,
    bu_lang4   building.bu_lang4,
    bu_lang5   building.bu_lang5,
    bu_lang6   building.bu_lang6,
    bu_lang7   building.bu_lang7,
    bu_lang8   building.bu_lang8,
    bu_lang9   building.bu_lang9,
    bu_note    building.bu_note,
    bu_numcode building.bu_numcode,
    bu_webtop  building.bu_webtop
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabuildpic AS caBase OF cit_ca.vcx
Alias = [cabuildpic]
Tables = [buildpic]
KeyFieldList = [bt_picid,bt_buid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bt_buid,
       bt_picid
    FROM buildpic
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_buid    I       DEFAULT 0,
    bt_picid   N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_buid,
    bt_picid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_buid    buildpic.bt_buid,
    bt_picid   buildpic.bt_picid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacashier AS caBase OF cit_ca.vcx
Alias = [cacashier]
Tables = [cashier]
KeyFieldList = [ca_number]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ca_clodate,
       ca_clotime,
       ca_isopen,
       ca_name,
       ca_number,
       ca_opcount,
       ca_opdate,
       ca_opmax,
       ca_optime
    FROM cashier
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ca_clodate D       DEFAULT {},
    ca_clotime C(8)    DEFAULT "",
    ca_isopen  L       DEFAULT .F.,
    ca_name    C(25)   DEFAULT "",
    ca_number  N(2,0)  DEFAULT 0,
    ca_opcount N(2,0)  DEFAULT 0,
    ca_opdate  D       DEFAULT {},
    ca_opmax   N(2,0)  DEFAULT 0,
    ca_optime  C(8)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ca_clodate,
    ca_clotime,
    ca_isopen,
    ca_name,
    ca_number,
    ca_opcount,
    ca_opdate,
    ca_opmax,
    ca_optime
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ca_clodate cashier.ca_clodate,
    ca_clotime cashier.ca_clotime,
    ca_isopen  cashier.ca_isopen,
    ca_name    cashier.ca_name,
    ca_number  cashier.ca_number,
    ca_opcount cashier.ca_opcount,
    ca_opdate  cashier.ca_opdate,
    ca_opmax   cashier.ca_opmax,
    ca_optime  cashier.ca_optime
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacitcolor AS caBase OF cit_ca.vcx
Alias = [cacitcolor]
Tables = [citcolor]
KeyFieldList = [ct_colorid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ct_color,
       ct_colorid,
       ct_label,
       ct_lang1,
       ct_lang10,
       ct_lang11,
       ct_lang2,
       ct_lang3,
       ct_lang4,
       ct_lang5,
       ct_lang6,
       ct_lang7,
       ct_lang8,
       ct_lang9
    FROM citcolor
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ct_color   N(8,0)  DEFAULT 0,
    ct_colorid N(8,0)  DEFAULT 0,
    ct_label   C(10)   DEFAULT "",
    ct_lang1   C(30)   DEFAULT "",
    ct_lang10  C(30)   DEFAULT "",
    ct_lang11  C(30)   DEFAULT "",
    ct_lang2   C(30)   DEFAULT "",
    ct_lang3   C(30)   DEFAULT "",
    ct_lang4   C(30)   DEFAULT "",
    ct_lang5   C(30)   DEFAULT "",
    ct_lang6   C(30)   DEFAULT "",
    ct_lang7   C(30)   DEFAULT "",
    ct_lang8   C(30)   DEFAULT "",
    ct_lang9   C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ct_color,
    ct_colorid,
    ct_label,
    ct_lang1,
    ct_lang10,
    ct_lang11,
    ct_lang2,
    ct_lang3,
    ct_lang4,
    ct_lang5,
    ct_lang6,
    ct_lang7,
    ct_lang8,
    ct_lang9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ct_color   citcolor.ct_color,
    ct_colorid citcolor.ct_colorid,
    ct_label   citcolor.ct_label,
    ct_lang1   citcolor.ct_lang1,
    ct_lang10  citcolor.ct_lang10,
    ct_lang11  citcolor.ct_lang11,
    ct_lang2   citcolor.ct_lang2,
    ct_lang3   citcolor.ct_lang3,
    ct_lang4   citcolor.ct_lang4,
    ct_lang5   citcolor.ct_lang5,
    ct_lang6   citcolor.ct_lang6,
    ct_lang7   citcolor.ct_lang7,
    ct_lang8   citcolor.ct_lang8,
    ct_lang9   citcolor.ct_lang9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacmrtavl AS caBase OF cit_ca.vcx
Alias = [cacmrtavl]
Tables = [cmrtavl]
KeyFieldList = [cm_date, cm_roomtyp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       cm_date,
       cm_perc,
       cm_roomtyp
    FROM cmrtavl
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    cm_date    D       DEFAULT {},
    cm_perc    N(3,0)  DEFAULT 0,
    cm_roomtyp C(4)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cm_date,
    cm_perc,
    cm_roomtyp
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cm_date    cmrtavl.cm_date,
    cm_perc    cmrtavl.cm_perc,
    cm_roomtyp cmrtavl.cm_roomtyp
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacrlog AS caBase OF cit_ca.vcx
Alias = [cacrlog]
Tables = [crlog]
KeyFieldList = [cl_clid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       cl_clid,
       cl_date,
       cl_log,
       cl_termnr,
       cl_user
    FROM crlog
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    cl_clid    I       DEFAULT 0,
    cl_date    T       DEFAULT {},
    cl_log     M       DEFAULT "",
    cl_termnr  N(2,0)  DEFAULT 0,
    cl_user    C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cl_clid,
    cl_date,
    cl_log,
    cl_termnr,
    cl_user
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cl_clid    crlog.cl_clid,
    cl_date    crlog.cl_date,
    cl_log     crlog.cl_log,
    cl_termnr  crlog.cl_termnr,
    cl_user    crlog.cl_user
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacwrates AS caBase OF cit_ca.vcx
Alias = [cacwrates]
Tables = [cwrates]
KeyFieldList = [ew_date,ew_vroom]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ew_closed,
       ew_crate1,
       ew_crate2,
       ew_crate3,
       ew_date,
       ew_maxstay,
       ew_mealcod,
       ew_minstay,
       ew_rate,
       ew_rate2,
       ew_rate3,
       ew_rate4,
       ew_rate5,
       ew_vroom
    FROM cwrates
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ew_closed  N(1,0)  DEFAULT 0,
    ew_crate1  N(12,2) DEFAULT 0,
    ew_crate2  N(12,2) DEFAULT 0,
    ew_crate3  N(12,2) DEFAULT 0,
    ew_date    D       DEFAULT {},
    ew_maxstay N(3,0)  DEFAULT 0,
    ew_mealcod C(2)    DEFAULT "",
    ew_minstay N(3,0)  DEFAULT 0,
    ew_rate    N(12,2) DEFAULT 0,
    ew_rate2   N(12,2) DEFAULT 0,
    ew_rate3   N(12,2) DEFAULT 0,
    ew_rate4   N(12,2) DEFAULT 0,
    ew_rate5   N(12,2) DEFAULT 0,
    ew_vroom   C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ew_closed,
    ew_crate1,
    ew_crate2,
    ew_crate3,
    ew_date,
    ew_maxstay,
    ew_mealcod,
    ew_minstay,
    ew_rate,
    ew_rate2,
    ew_rate3,
    ew_rate4,
    ew_rate5,
    ew_vroom
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ew_closed  cwrates.ew_closed,
    ew_crate1  cwrates.ew_crate1,
    ew_crate2  cwrates.ew_crate2,
    ew_crate3  cwrates.ew_crate3,
    ew_date    cwrates.ew_date,
    ew_maxstay cwrates.ew_maxstay,
    ew_mealcod cwrates.ew_mealcod,
    ew_minstay cwrates.ew_minstay,
    ew_rate    cwrates.ew_rate,
    ew_rate2   cwrates.ew_rate2,
    ew_rate3   cwrates.ew_rate3,
    ew_rate4   cwrates.ew_rate4,
    ew_rate5   cwrates.ew_rate5,
    ew_vroom   cwrates.ew_vroom
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacwvrrt AS caBase OF cit_ca.vcx
Alias = [cacwvrrt]
Tables = [cwvrrt]
KeyFieldList = [eq_vroom]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       eq_adults,
       eq_adusta,
       eq_channel,
       eq_chvroom,
       eq_citcwcp,
       eq_citcwcr,
       eq_citucwr,
       eq_descrip,
       eq_inactiv,
       eq_ratecod,
       eq_rateid,
       eq_sent,
       eq_updated,
       eq_userid,
       eq_vroom,
       eq_ymactiv
    FROM cwvrrt
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    eq_adults  N(1,0)  DEFAULT 0,
    eq_adusta  N(1,0)  DEFAULT 0,
    eq_channel I       DEFAULT 0,
    eq_chvroom C(3)    DEFAULT "",
    eq_citcwcp N(6,2)  DEFAULT 0,
    eq_citcwcr N(6,2)  DEFAULT 0,
    eq_citucwr L       DEFAULT .F.,
    eq_descrip C(40)   DEFAULT "",
    eq_inactiv L       DEFAULT .F.,
    eq_ratecod C(10)   DEFAULT "",
    eq_rateid  C(16)   DEFAULT "",
    eq_sent    T       DEFAULT {},
    eq_updated T       DEFAULT {},
    eq_userid  C(10)   DEFAULT "",
    eq_vroom   C(3)    DEFAULT "",
    eq_ymactiv L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eq_adults,
    eq_adusta,
    eq_channel,
    eq_chvroom,
    eq_citcwcp,
    eq_citcwcr,
    eq_citucwr,
    eq_descrip,
    eq_inactiv,
    eq_ratecod,
    eq_rateid,
    eq_sent,
    eq_updated,
    eq_userid,
    eq_vroom,
    eq_ymactiv
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eq_adults  cwvrrt.eq_adults,
    eq_adusta  cwvrrt.eq_adusta,
    eq_channel cwvrrt.eq_channel,
    eq_chvroom cwvrrt.eq_chvroom,
    eq_citcwcp cwvrrt.eq_citcwcp,
    eq_citcwcr cwvrrt.eq_citcwcr,
    eq_citucwr cwvrrt.eq_citucwr,
    eq_descrip cwvrrt.eq_descrip,
    eq_inactiv cwvrrt.eq_inactiv,
    eq_ratecod cwvrrt.eq_ratecod,
    eq_rateid  cwvrrt.eq_rateid,
    eq_sent    cwvrrt.eq_sent,
    eq_updated cwvrrt.eq_updated,
    eq_userid  cwvrrt.eq_userid,
    eq_vroom   cwvrrt.eq_vroom,
    eq_ymactiv cwvrrt.eq_ymactiv
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cadenial AS caBase OF cit_ca.vcx
Alias = [cadenial]
Tables = [denial]
KeyFieldList = [dn_dnlid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       dn_adults,
       dn_arrdate,
       dn_childs,
       dn_created,
       dn_depdate,
       dn_dnlid,
       dn_dnlreas,
       dn_market,
       dn_note,
       dn_rooms,
       dn_roomtyp,
       dn_source,
       dn_userid
    FROM denial
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    dn_adults  N(3,0)  DEFAULT 0,
    dn_arrdate D       DEFAULT {},
    dn_childs  N(3,0)  DEFAULT 0,
    dn_created D       DEFAULT {},
    dn_depdate D       DEFAULT {},
    dn_dnlid   N(8,0)  DEFAULT 0,
    dn_dnlreas C(3)    DEFAULT "",
    dn_market  C(3)    DEFAULT "",
    dn_note    M       DEFAULT "",
    dn_rooms   N(3,0)  DEFAULT 0,
    dn_roomtyp C(4)    DEFAULT "",
    dn_source  C(3)    DEFAULT "",
    dn_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dn_adults,
    dn_arrdate,
    dn_childs,
    dn_created,
    dn_depdate,
    dn_dnlid,
    dn_dnlreas,
    dn_market,
    dn_note,
    dn_rooms,
    dn_roomtyp,
    dn_source,
    dn_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dn_adults  denial.dn_adults,
    dn_arrdate denial.dn_arrdate,
    dn_childs  denial.dn_childs,
    dn_created denial.dn_created,
    dn_depdate denial.dn_depdate,
    dn_dnlid   denial.dn_dnlid,
    dn_dnlreas denial.dn_dnlreas,
    dn_market  denial.dn_market,
    dn_note    denial.dn_note,
    dn_rooms   denial.dn_rooms,
    dn_roomtyp denial.dn_roomtyp,
    dn_source  denial.dn_source,
    dn_userid  denial.dn_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cadeposit AS caBase OF cit_ca.vcx
Alias = [cadeposit]
Tables = [deposit]
KeyFieldList = [dp_lineid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       dp_addpost,
       dp_artinum,
       dp_cashier,
       dp_credit,
       dp_date,
       dp_debit,
       dp_depcnt,
       dp_descrip,
       dp_due,
       dp_headid,
       dp_lineid,
       dp_paynum,
       dp_percent,
       dp_posted,
       dp_postid,
       dp_receipt,
       dp_recidet,
       dp_ref,
       dp_remcnt,
       dp_remlast,
       dp_reserid,
       dp_supplem,
       dp_sysdate,
       dp_userid
    FROM deposit
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_addpost L       DEFAULT .F.,
    dp_artinum N(4,0)  DEFAULT 0,
    dp_cashier N(2,0)  DEFAULT 0,
    dp_credit  B(2)    DEFAULT 0,
    dp_date    D       DEFAULT {},
    dp_debit   B(2)    DEFAULT 0,
    dp_depcnt  N(1,0)  DEFAULT 0,
    dp_descrip C(25)   DEFAULT "",
    dp_due     D       DEFAULT {},
    dp_headid  N(8,0)  DEFAULT 0,
    dp_lineid  N(8,0)  DEFAULT 0,
    dp_paynum  N(3,0)  DEFAULT 0,
    dp_percent B(8)    DEFAULT 0,
    dp_posted  D       DEFAULT {},
    dp_postid  N(8,0)  DEFAULT 0,
    dp_receipt I       DEFAULT 0,
    dp_recidet M       DEFAULT "",
    dp_ref     C(25)   DEFAULT "",
    dp_remcnt  N(2,0)  DEFAULT 0,
    dp_remlast D       DEFAULT {},
    dp_reserid N(12,3) DEFAULT 0,
    dp_supplem C(25)   DEFAULT "",
    dp_sysdate D       DEFAULT {},
    dp_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_addpost,
    dp_artinum,
    dp_cashier,
    dp_credit,
    dp_date,
    dp_debit,
    dp_depcnt,
    dp_descrip,
    dp_due,
    dp_headid,
    dp_lineid,
    dp_paynum,
    dp_percent,
    dp_posted,
    dp_postid,
    dp_receipt,
    dp_recidet,
    dp_ref,
    dp_remcnt,
    dp_remlast,
    dp_reserid,
    dp_supplem,
    dp_sysdate,
    dp_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_addpost deposit.dp_addpost,
    dp_artinum deposit.dp_artinum,
    dp_cashier deposit.dp_cashier,
    dp_credit  deposit.dp_credit,
    dp_date    deposit.dp_date,
    dp_debit   deposit.dp_debit,
    dp_depcnt  deposit.dp_depcnt,
    dp_descrip deposit.dp_descrip,
    dp_due     deposit.dp_due,
    dp_headid  deposit.dp_headid,
    dp_lineid  deposit.dp_lineid,
    dp_paynum  deposit.dp_paynum,
    dp_percent deposit.dp_percent,
    dp_posted  deposit.dp_posted,
    dp_postid  deposit.dp_postid,
    dp_receipt deposit.dp_receipt,
    dp_recidet deposit.dp_recidet,
    dp_ref     deposit.dp_ref,
    dp_remcnt  deposit.dp_remcnt,
    dp_remlast deposit.dp_remlast,
    dp_reserid deposit.dp_reserid,
    dp_supplem deposit.dp_supplem,
    dp_sysdate deposit.dp_sysdate,
    dp_userid  deposit.dp_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cadocument AS caBase OF cit_ca.vcx
Alias = [cadocument]
Tables = [document]
KeyFieldList = [dc_file]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       dc_addrid,
       dc_bbid,
       dc_date,
       dc_descr,
       dc_file,
       dc_reserid,
       dc_time,
       dc_type,
       dc_userid
    FROM document
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    dc_addrid  N(8,0)  DEFAULT 0,
    dc_bbid    I       DEFAULT 0,
    dc_date    D       DEFAULT {},
    dc_descr   C(40)   DEFAULT "",
    dc_file    C(50)   DEFAULT "",
    dc_reserid N(12,3) DEFAULT 0,
    dc_time    C(5)    DEFAULT "",
    dc_type    C(10)   DEFAULT "",
    dc_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dc_addrid,
    dc_bbid,
    dc_date,
    dc_descr,
    dc_file,
    dc_reserid,
    dc_time,
    dc_type,
    dc_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dc_addrid  document.dc_addrid,
    dc_bbid    document.dc_bbid,
    dc_date    document.dc_date,
    dc_descr   document.dc_descr,
    dc_file    document.dc_file,
    dc_reserid document.dc_reserid,
    dc_time    document.dc_time,
    dc_type    document.dc_type,
    dc_userid  document.dc_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caeattachm AS caBase OF cit_ca.vcx
Alias = [caeattachm]
Tables = [eattachm]
KeyFieldList = [ea_attid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ea_attid,
       ea_attname,
       ea_attsize,
       ea_eiid,
       ea_esid,
       ea_path,
       ea_sntatid
    FROM eattachm
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ea_attid   N(8,0)  DEFAULT 0,
    ea_attname C(254)  DEFAULT "",
    ea_attsize N(9,0)  DEFAULT 0,
    ea_eiid    N(8,0)  DEFAULT 0,
    ea_esid    N(8,0)  DEFAULT 0,
    ea_path    C(254)  DEFAULT "",
    ea_sntatid N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ea_attid,
    ea_attname,
    ea_attsize,
    ea_eiid,
    ea_esid,
    ea_path,
    ea_sntatid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ea_attid   eattachm.ea_attid,
    ea_attname eattachm.ea_attname,
    ea_attsize eattachm.ea_attsize,
    ea_eiid    eattachm.ea_eiid,
    ea_esid    eattachm.ea_esid,
    ea_path    eattachm.ea_path,
    ea_sntatid eattachm.ea_sntatid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caeinbox AS caBase OF cit_ca.vcx
Alias = [caeinbox]
Tables = [einbox]
KeyFieldList = [ei_eiid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ei_attachm,
       ei_body,
       ei_datime,
       ei_deleted,
       ei_disname,
       ei_eiid,
       ei_msysid,
       ei_sender,
       ei_status,
       ei_subject,
       ei_userid
    FROM einbox
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ei_attachm N(2,0)  DEFAULT 0,
    ei_body    M       DEFAULT "",
    ei_datime  T       DEFAULT {},
    ei_deleted L       DEFAULT .F.,
    ei_disname C(120)  DEFAULT "",
    ei_eiid    N(8,0)  DEFAULT 0,
    ei_msysid  C(87)   DEFAULT "",
    ei_sender  C(100)  DEFAULT "",
    ei_status  N(1,0)  DEFAULT 0,
    ei_subject C(254)  DEFAULT "",
    ei_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ei_attachm,
    ei_body,
    ei_datime,
    ei_deleted,
    ei_disname,
    ei_eiid,
    ei_msysid,
    ei_sender,
    ei_status,
    ei_subject,
    ei_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ei_attachm einbox.ei_attachm,
    ei_body    einbox.ei_body,
    ei_datime  einbox.ei_datime,
    ei_deleted einbox.ei_deleted,
    ei_disname einbox.ei_disname,
    ei_eiid    einbox.ei_eiid,
    ei_msysid  einbox.ei_msysid,
    ei_sender  einbox.ei_sender,
    ei_status  einbox.ei_status,
    ei_subject einbox.ei_subject,
    ei_userid  einbox.ei_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caeinboxsn AS caBase OF cit_ca.vcx
Alias = [caeinboxsn]
Tables = [einboxsn]
KeyFieldList = [eb_addrid,eb_apid,eb_eiid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       eb_addrid,
       eb_apid,
       eb_eiid
    FROM einboxsn
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    eb_addrid  N(8,0)  DEFAULT 0,
    eb_apid    N(8,0)  DEFAULT 0,
    eb_eiid    N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eb_addrid,
    eb_apid,
    eb_eiid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eb_addrid  einboxsn.eb_addrid,
    eb_apid    einboxsn.eb_apid,
    eb_eiid    einboxsn.eb_eiid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caelpay AS caBase OF cit_ca.vcx
Alias = [caelpay]
Tables = [elpay]
KeyFieldList = [el_elid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       el_elid,
       el_postid,
       el_print,
       el_reciv,
       el_sent
    FROM elpay
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    el_elid    I       DEFAULT 0,
    el_postid  I       DEFAULT 0,
    el_print   M       DEFAULT "",
    el_reciv   M       DEFAULT "",
    el_sent    M       DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    el_elid,
    el_postid,
    el_print,
    el_reciv,
    el_sent
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    el_elid    elpay.el_elid,
    el_postid  elpay.el_postid,
    el_print   elpay.el_print,
    el_reciv   elpay.el_reciv,
    el_sent    elpay.el_sent
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caemployee AS caBase OF cit_ca.vcx
Alias = [caemployee]
Tables = [employee]
KeyFieldList = [em_emid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       em_accnr,
       em_baid,
       em_birth,
       em_bkcity,
       em_bkname,
       em_bknr,
       em_city,
       em_dayweek,
       em_emid,
       em_empnr,
       em_fname,
       em_inactiv,
       em_jbnr,
       em_lname,
       em_note,
       em_pernr,
       em_phone1,
       em_phone2,
       em_state,
       em_street,
       em_title,
       em_uid,
       em_userid,
       em_waitnr,
       em_webcode,
       em_whweek,
       em_zcid,
       em_zip
    FROM employee
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    em_accnr   N(12,0) DEFAULT 0,
    em_baid    N(8,0)  DEFAULT 0,
    em_birth   D       DEFAULT {},
    em_bkcity  C(50)   DEFAULT "",
    em_bkname  C(50)   DEFAULT "",
    em_bknr    N(8,0)  DEFAULT 0,
    em_city    C(30)   DEFAULT "",
    em_dayweek N(1,0)  DEFAULT 0,
    em_emid    N(8,0)  DEFAULT 0,
    em_empnr   C(20)   DEFAULT "",
    em_fname   C(20)   DEFAULT "",
    em_inactiv L       DEFAULT .F.,
    em_jbnr    N(2,0)  DEFAULT 0,
    em_lname   C(30)   DEFAULT "",
    em_note    M       DEFAULT "",
    em_pernr   N(5,0)  DEFAULT 0,
    em_phone1  C(20)   DEFAULT "",
    em_phone2  C(20)   DEFAULT "",
    em_state   C(30)   DEFAULT "",
    em_street  C(30)   DEFAULT "",
    em_title   C(20)   DEFAULT "",
    em_uid     C(16)   DEFAULT "",
    em_userid  C(10)   DEFAULT "",
    em_waitnr  N(8,0)  DEFAULT 0,
    em_webcode C(4)    DEFAULT "",
    em_whweek  N(4,1)  DEFAULT 0,
    em_zcid    N(8,0)  DEFAULT 0,
    em_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    em_accnr,
    em_baid,
    em_birth,
    em_bkcity,
    em_bkname,
    em_bknr,
    em_city,
    em_dayweek,
    em_emid,
    em_empnr,
    em_fname,
    em_inactiv,
    em_jbnr,
    em_lname,
    em_note,
    em_pernr,
    em_phone1,
    em_phone2,
    em_state,
    em_street,
    em_title,
    em_uid,
    em_userid,
    em_waitnr,
    em_webcode,
    em_whweek,
    em_zcid,
    em_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    em_accnr   employee.em_accnr,
    em_baid    employee.em_baid,
    em_birth   employee.em_birth,
    em_bkcity  employee.em_bkcity,
    em_bkname  employee.em_bkname,
    em_bknr    employee.em_bknr,
    em_city    employee.em_city,
    em_dayweek employee.em_dayweek,
    em_emid    employee.em_emid,
    em_empnr   employee.em_empnr,
    em_fname   employee.em_fname,
    em_inactiv employee.em_inactiv,
    em_jbnr    employee.em_jbnr,
    em_lname   employee.em_lname,
    em_note    employee.em_note,
    em_pernr   employee.em_pernr,
    em_phone1  employee.em_phone1,
    em_phone2  employee.em_phone2,
    em_state   employee.em_state,
    em_street  employee.em_street,
    em_title   employee.em_title,
    em_uid     employee.em_uid,
    em_userid  employee.em_userid,
    em_waitnr  employee.em_waitnr,
    em_webcode employee.em_webcode,
    em_whweek  employee.em_whweek,
    em_zcid    employee.em_zcid,
    em_zip     employee.em_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caemployeh AS caBase OF cit_ca.vcx
Alias = [caemployeh]
Tables = [employeh]
KeyFieldList = [eh_ehid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       eh_ehid,
       eh_emid,
       eh_vacatio,
       eh_year
    FROM employeh
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    eh_ehid    N(8,0)  DEFAULT 0,
    eh_emid    N(8,0)  DEFAULT 0,
    eh_vacatio N(3,0)  DEFAULT 0,
    eh_year    N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eh_ehid,
    eh_emid,
    eh_vacatio,
    eh_year
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eh_ehid    employeh.eh_ehid,
    eh_emid    employeh.eh_emid,
    eh_vacatio employeh.eh_vacatio,
    eh_year    employeh.eh_year
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caemprop AS caBase OF cit_ca.vcx
Alias = [caemprop]
Tables = [emprop]
KeyFieldList = [ep_emtype]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ep_attpath,
       ep_autosna,
       ep_autosnd,
       ep_autosns,
       ep_earrat,
       ep_earrd,
       ep_earrre1,
       ep_earrre2,
       ep_earrre3,
       ep_earrre4,
       ep_earrre5,
       ep_earrre6,
       ep_earrre7,
       ep_earrre8,
       ep_earrre9,
       ep_earrtm1,
       ep_earrtm2,
       ep_earrtm3,
       ep_earrtm4,
       ep_earrtm5,
       ep_earrtm6,
       ep_earrtm7,
       ep_earrtm8,
       ep_earrtm9,
       ep_edepat,
       ep_edepd,
       ep_edepre1,
       ep_edepre2,
       ep_edepre3,
       ep_edepre4,
       ep_edepre5,
       ep_edepre6,
       ep_edepre7,
       ep_edepre8,
       ep_edepre9,
       ep_edeptm1,
       ep_edeptm2,
       ep_edeptm3,
       ep_edeptm4,
       ep_edeptm5,
       ep_edeptm6,
       ep_edeptm7,
       ep_edeptm8,
       ep_edeptm9,
       ep_emcnf1,
       ep_emcnf2,
       ep_emcnf3,
       ep_emcnf4,
       ep_emcnf5,
       ep_emcnf6,
       ep_emcnf7,
       ep_emcnf8,
       ep_emcnf9,
       ep_emcxlh1,
       ep_emcxlh2,
       ep_emcxlh3,
       ep_emcxlh4,
       ep_emcxlh5,
       ep_emcxlh6,
       ep_emcxlh7,
       ep_emcxlh8,
       ep_emcxlh9,
       ep_emhea1,
       ep_emhea10,
       ep_emhea11,
       ep_emhea2,
       ep_emhea3,
       ep_emhea4,
       ep_emhea5,
       ep_emhea6,
       ep_emhea7,
       ep_emhea8,
       ep_emhea9,
       ep_emtype,
       ep_from,
       ep_head,
       ep_log,
       ep_pass,
       ep_quote,
       ep_resign,
       ep_romcapt,
       ep_server,
       ep_sgbfrpl,
       ep_sgcustm,
       ep_user,
       ep_usesmtp,
       ep_useverc,
       ep_wbadman,
       ep_wbbkpid,
       ep_wbccafc,
       ep_wbchmpe,
       ep_wbconf,
       ep_wbdsiro,
       ep_wbemail,
       ep_wbexpir,
       ep_wbhcity,
       ep_wbhname,
       ep_wbhstre,
       ep_wbmrts,
       ep_wbmrtsr,
       ep_wbnocc,
       ep_wbnocus,
       ep_wbnogun,
       ep_wbnohna,
       ep_wbnoirt,
       ep_wbnospl,
       ep_wbonagp,
       ep_wbphone,
       ep_wbrandr,
       ep_wbratca,
       ep_wbrfpar,
       ep_wbrpalw,
       ep_wbselc1,
       ep_wbselc2,
       ep_wbselc3,
       ep_wbselc4,
       ep_wbselc5,
       ep_wbselc6,
       ep_wbselc7,
       ep_wbselc8,
       ep_wbselc9,
       ep_wbshavr,
       ep_wbshcvc,
       ep_wbshpch,
       ep_wbvoalw
    FROM emprop
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ep_attpath C(254)  DEFAULT "",
    ep_autosna L       DEFAULT .F.,
    ep_autosnd L       DEFAULT .F.,
    ep_autosns D       DEFAULT {},
    ep_earrat  C(250)  DEFAULT "",
    ep_earrd   N(2,0)  DEFAULT 0,
    ep_earrre1 C(254)  DEFAULT "",
    ep_earrre2 C(254)  DEFAULT "",
    ep_earrre3 C(254)  DEFAULT "",
    ep_earrre4 C(254)  DEFAULT "",
    ep_earrre5 C(254)  DEFAULT "",
    ep_earrre6 C(254)  DEFAULT "",
    ep_earrre7 C(254)  DEFAULT "",
    ep_earrre8 C(254)  DEFAULT "",
    ep_earrre9 C(254)  DEFAULT "",
    ep_earrtm1 M       DEFAULT "",
    ep_earrtm2 M       DEFAULT "",
    ep_earrtm3 M       DEFAULT "",
    ep_earrtm4 M       DEFAULT "",
    ep_earrtm5 M       DEFAULT "",
    ep_earrtm6 M       DEFAULT "",
    ep_earrtm7 M       DEFAULT "",
    ep_earrtm8 M       DEFAULT "",
    ep_earrtm9 M       DEFAULT "",
    ep_edepat  C(250)  DEFAULT "",
    ep_edepd   N(2,0)  DEFAULT 0,
    ep_edepre1 C(254)  DEFAULT "",
    ep_edepre2 C(254)  DEFAULT "",
    ep_edepre3 C(254)  DEFAULT "",
    ep_edepre4 C(254)  DEFAULT "",
    ep_edepre5 C(254)  DEFAULT "",
    ep_edepre6 C(254)  DEFAULT "",
    ep_edepre7 C(254)  DEFAULT "",
    ep_edepre8 C(254)  DEFAULT "",
    ep_edepre9 C(254)  DEFAULT "",
    ep_edeptm1 M       DEFAULT "",
    ep_edeptm2 M       DEFAULT "",
    ep_edeptm3 M       DEFAULT "",
    ep_edeptm4 M       DEFAULT "",
    ep_edeptm5 M       DEFAULT "",
    ep_edeptm6 M       DEFAULT "",
    ep_edeptm7 M       DEFAULT "",
    ep_edeptm8 M       DEFAULT "",
    ep_edeptm9 M       DEFAULT "",
    ep_emcnf1  M       DEFAULT "",
    ep_emcnf2  M       DEFAULT "",
    ep_emcnf3  M       DEFAULT "",
    ep_emcnf4  M       DEFAULT "",
    ep_emcnf5  M       DEFAULT "",
    ep_emcnf6  M       DEFAULT "",
    ep_emcnf7  M       DEFAULT "",
    ep_emcnf8  M       DEFAULT "",
    ep_emcnf9  M       DEFAULT "",
    ep_emcxlh1 M       DEFAULT "",
    ep_emcxlh2 M       DEFAULT "",
    ep_emcxlh3 M       DEFAULT "",
    ep_emcxlh4 M       DEFAULT "",
    ep_emcxlh5 M       DEFAULT "",
    ep_emcxlh6 M       DEFAULT "",
    ep_emcxlh7 M       DEFAULT "",
    ep_emcxlh8 M       DEFAULT "",
    ep_emcxlh9 M       DEFAULT "",
    ep_emhea1  M       DEFAULT "",
    ep_emhea10 M       DEFAULT "",
    ep_emhea11 M       DEFAULT "",
    ep_emhea2  M       DEFAULT "",
    ep_emhea3  M       DEFAULT "",
    ep_emhea4  M       DEFAULT "",
    ep_emhea5  M       DEFAULT "",
    ep_emhea6  M       DEFAULT "",
    ep_emhea7  M       DEFAULT "",
    ep_emhea8  M       DEFAULT "",
    ep_emhea9  M       DEFAULT "",
    ep_emtype  N(1,0)  DEFAULT 0,
    ep_from    C(100)  DEFAULT "",
    ep_head    M       DEFAULT "",
    ep_log     L       DEFAULT .F.,
    ep_pass    C(100)  DEFAULT "",
    ep_quote   C(80)   DEFAULT "",
    ep_resign  C(20)   DEFAULT "",
    ep_romcapt M       DEFAULT "",
    ep_server  C(100)  DEFAULT "",
    ep_sgbfrpl L       DEFAULT .F.,
    ep_sgcustm M       DEFAULT "",
    ep_user    C(100)  DEFAULT "",
    ep_usesmtp L       DEFAULT .F.,
    ep_useverc L       DEFAULT .F.,
    ep_wbadman L       DEFAULT .F.,
    ep_wbbkpid C(2)    DEFAULT "",
    ep_wbccafc L       DEFAULT .F.,
    ep_wbchmpe L       DEFAULT .F.,
    ep_wbconf  L       DEFAULT .F.,
    ep_wbdsiro L       DEFAULT .F.,
    ep_wbemail C(100)  DEFAULT "",
    ep_wbexpir I       DEFAULT 0,
    ep_wbhcity C(100)  DEFAULT "",
    ep_wbhname C(150)  DEFAULT "",
    ep_wbhstre C(100)  DEFAULT "",
    ep_wbmrts  N(2,0)  DEFAULT 0,
    ep_wbmrtsr C(254)  DEFAULT "",
    ep_wbnocc  L       DEFAULT .F.,
    ep_wbnocus L       DEFAULT .F.,
    ep_wbnogun L       DEFAULT .F.,
    ep_wbnohna L       DEFAULT .F.,
    ep_wbnoirt L       DEFAULT .F.,
    ep_wbnospl L       DEFAULT .F.,
    ep_wbonagp L       DEFAULT .F.,
    ep_wbphone C(100)  DEFAULT "",
    ep_wbrandr L       DEFAULT .F.,
    ep_wbratca L       DEFAULT .F.,
    ep_wbrfpar C(20)   DEFAULT "",
    ep_wbrpalw L       DEFAULT .F.,
    ep_wbselc1 M       DEFAULT "",
    ep_wbselc2 M       DEFAULT "",
    ep_wbselc3 M       DEFAULT "",
    ep_wbselc4 M       DEFAULT "",
    ep_wbselc5 M       DEFAULT "",
    ep_wbselc6 M       DEFAULT "",
    ep_wbselc7 M       DEFAULT "",
    ep_wbselc8 M       DEFAULT "",
    ep_wbselc9 M       DEFAULT "",
    ep_wbshavr L       DEFAULT .F.,
    ep_wbshcvc L       DEFAULT .F.,
    ep_wbshpch L       DEFAULT .F.,
    ep_wbvoalw L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ep_attpath,
    ep_autosna,
    ep_autosnd,
    ep_autosns,
    ep_earrat,
    ep_earrd,
    ep_earrre1,
    ep_earrre2,
    ep_earrre3,
    ep_earrre4,
    ep_earrre5,
    ep_earrre6,
    ep_earrre7,
    ep_earrre8,
    ep_earrre9,
    ep_earrtm1,
    ep_earrtm2,
    ep_earrtm3,
    ep_earrtm4,
    ep_earrtm5,
    ep_earrtm6,
    ep_earrtm7,
    ep_earrtm8,
    ep_earrtm9,
    ep_edepat,
    ep_edepd,
    ep_edepre1,
    ep_edepre2,
    ep_edepre3,
    ep_edepre4,
    ep_edepre5,
    ep_edepre6,
    ep_edepre7,
    ep_edepre8,
    ep_edepre9,
    ep_edeptm1,
    ep_edeptm2,
    ep_edeptm3,
    ep_edeptm4,
    ep_edeptm5,
    ep_edeptm6,
    ep_edeptm7,
    ep_edeptm8,
    ep_edeptm9,
    ep_emcnf1,
    ep_emcnf2,
    ep_emcnf3,
    ep_emcnf4,
    ep_emcnf5,
    ep_emcnf6,
    ep_emcnf7,
    ep_emcnf8,
    ep_emcnf9,
    ep_emcxlh1,
    ep_emcxlh2,
    ep_emcxlh3,
    ep_emcxlh4,
    ep_emcxlh5,
    ep_emcxlh6,
    ep_emcxlh7,
    ep_emcxlh8,
    ep_emcxlh9,
    ep_emhea1,
    ep_emhea10,
    ep_emhea11,
    ep_emhea2,
    ep_emhea3,
    ep_emhea4,
    ep_emhea5,
    ep_emhea6,
    ep_emhea7,
    ep_emhea8,
    ep_emhea9,
    ep_emtype,
    ep_from,
    ep_head,
    ep_log,
    ep_pass,
    ep_quote,
    ep_resign,
    ep_romcapt,
    ep_server,
    ep_sgbfrpl,
    ep_sgcustm,
    ep_user,
    ep_usesmtp,
    ep_useverc,
    ep_wbadman,
    ep_wbbkpid,
    ep_wbccafc,
    ep_wbchmpe,
    ep_wbconf,
    ep_wbdsiro,
    ep_wbemail,
    ep_wbexpir,
    ep_wbhcity,
    ep_wbhname,
    ep_wbhstre,
    ep_wbmrts,
    ep_wbmrtsr,
    ep_wbnocc,
    ep_wbnocus,
    ep_wbnogun,
    ep_wbnohna,
    ep_wbnoirt,
    ep_wbnospl,
    ep_wbonagp,
    ep_wbphone,
    ep_wbrandr,
    ep_wbratca,
    ep_wbrfpar,
    ep_wbrpalw,
    ep_wbselc1,
    ep_wbselc2,
    ep_wbselc3,
    ep_wbselc4,
    ep_wbselc5,
    ep_wbselc6,
    ep_wbselc7,
    ep_wbselc8,
    ep_wbselc9,
    ep_wbshavr,
    ep_wbshcvc,
    ep_wbshpch,
    ep_wbvoalw
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ep_attpath emprop.ep_attpath,
    ep_autosna emprop.ep_autosna,
    ep_autosnd emprop.ep_autosnd,
    ep_autosns emprop.ep_autosns,
    ep_earrat  emprop.ep_earrat,
    ep_earrd   emprop.ep_earrd,
    ep_earrre1 emprop.ep_earrre1,
    ep_earrre2 emprop.ep_earrre2,
    ep_earrre3 emprop.ep_earrre3,
    ep_earrre4 emprop.ep_earrre4,
    ep_earrre5 emprop.ep_earrre5,
    ep_earrre6 emprop.ep_earrre6,
    ep_earrre7 emprop.ep_earrre7,
    ep_earrre8 emprop.ep_earrre8,
    ep_earrre9 emprop.ep_earrre9,
    ep_earrtm1 emprop.ep_earrtm1,
    ep_earrtm2 emprop.ep_earrtm2,
    ep_earrtm3 emprop.ep_earrtm3,
    ep_earrtm4 emprop.ep_earrtm4,
    ep_earrtm5 emprop.ep_earrtm5,
    ep_earrtm6 emprop.ep_earrtm6,
    ep_earrtm7 emprop.ep_earrtm7,
    ep_earrtm8 emprop.ep_earrtm8,
    ep_earrtm9 emprop.ep_earrtm9,
    ep_edepat  emprop.ep_edepat,
    ep_edepd   emprop.ep_edepd,
    ep_edepre1 emprop.ep_edepre1,
    ep_edepre2 emprop.ep_edepre2,
    ep_edepre3 emprop.ep_edepre3,
    ep_edepre4 emprop.ep_edepre4,
    ep_edepre5 emprop.ep_edepre5,
    ep_edepre6 emprop.ep_edepre6,
    ep_edepre7 emprop.ep_edepre7,
    ep_edepre8 emprop.ep_edepre8,
    ep_edepre9 emprop.ep_edepre9,
    ep_edeptm1 emprop.ep_edeptm1,
    ep_edeptm2 emprop.ep_edeptm2,
    ep_edeptm3 emprop.ep_edeptm3,
    ep_edeptm4 emprop.ep_edeptm4,
    ep_edeptm5 emprop.ep_edeptm5,
    ep_edeptm6 emprop.ep_edeptm6,
    ep_edeptm7 emprop.ep_edeptm7,
    ep_edeptm8 emprop.ep_edeptm8,
    ep_edeptm9 emprop.ep_edeptm9,
    ep_emcnf1  emprop.ep_emcnf1,
    ep_emcnf2  emprop.ep_emcnf2,
    ep_emcnf3  emprop.ep_emcnf3,
    ep_emcnf4  emprop.ep_emcnf4,
    ep_emcnf5  emprop.ep_emcnf5,
    ep_emcnf6  emprop.ep_emcnf6,
    ep_emcnf7  emprop.ep_emcnf7,
    ep_emcnf8  emprop.ep_emcnf8,
    ep_emcnf9  emprop.ep_emcnf9,
    ep_emcxlh1 emprop.ep_emcxlh1,
    ep_emcxlh2 emprop.ep_emcxlh2,
    ep_emcxlh3 emprop.ep_emcxlh3,
    ep_emcxlh4 emprop.ep_emcxlh4,
    ep_emcxlh5 emprop.ep_emcxlh5,
    ep_emcxlh6 emprop.ep_emcxlh6,
    ep_emcxlh7 emprop.ep_emcxlh7,
    ep_emcxlh8 emprop.ep_emcxlh8,
    ep_emcxlh9 emprop.ep_emcxlh9,
    ep_emhea1  emprop.ep_emhea1,
    ep_emhea10 emprop.ep_emhea10,
    ep_emhea11 emprop.ep_emhea11,
    ep_emhea2  emprop.ep_emhea2,
    ep_emhea3  emprop.ep_emhea3,
    ep_emhea4  emprop.ep_emhea4,
    ep_emhea5  emprop.ep_emhea5,
    ep_emhea6  emprop.ep_emhea6,
    ep_emhea7  emprop.ep_emhea7,
    ep_emhea8  emprop.ep_emhea8,
    ep_emhea9  emprop.ep_emhea9,
    ep_emtype  emprop.ep_emtype,
    ep_from    emprop.ep_from,
    ep_head    emprop.ep_head,
    ep_log     emprop.ep_log,
    ep_pass    emprop.ep_pass,
    ep_quote   emprop.ep_quote,
    ep_resign  emprop.ep_resign,
    ep_romcapt emprop.ep_romcapt,
    ep_server  emprop.ep_server,
    ep_sgbfrpl emprop.ep_sgbfrpl,
    ep_sgcustm emprop.ep_sgcustm,
    ep_user    emprop.ep_user,
    ep_usesmtp emprop.ep_usesmtp,
    ep_useverc emprop.ep_useverc,
    ep_wbadman emprop.ep_wbadman,
    ep_wbbkpid emprop.ep_wbbkpid,
    ep_wbccafc emprop.ep_wbccafc,
    ep_wbchmpe emprop.ep_wbchmpe,
    ep_wbconf  emprop.ep_wbconf,
    ep_wbdsiro emprop.ep_wbdsiro,
    ep_wbemail emprop.ep_wbemail,
    ep_wbexpir emprop.ep_wbexpir,
    ep_wbhcity emprop.ep_wbhcity,
    ep_wbhname emprop.ep_wbhname,
    ep_wbhstre emprop.ep_wbhstre,
    ep_wbmrts  emprop.ep_wbmrts,
    ep_wbmrtsr emprop.ep_wbmrtsr,
    ep_wbnocc  emprop.ep_wbnocc,
    ep_wbnocus emprop.ep_wbnocus,
    ep_wbnogun emprop.ep_wbnogun,
    ep_wbnohna emprop.ep_wbnohna,
    ep_wbnoirt emprop.ep_wbnoirt,
    ep_wbnospl emprop.ep_wbnospl,
    ep_wbonagp emprop.ep_wbonagp,
    ep_wbphone emprop.ep_wbphone,
    ep_wbrandr emprop.ep_wbrandr,
    ep_wbratca emprop.ep_wbratca,
    ep_wbrfpar emprop.ep_wbrfpar,
    ep_wbrpalw emprop.ep_wbrpalw,
    ep_wbselc1 emprop.ep_wbselc1,
    ep_wbselc2 emprop.ep_wbselc2,
    ep_wbselc3 emprop.ep_wbselc3,
    ep_wbselc4 emprop.ep_wbselc4,
    ep_wbselc5 emprop.ep_wbselc5,
    ep_wbselc6 emprop.ep_wbselc6,
    ep_wbselc7 emprop.ep_wbselc7,
    ep_wbselc8 emprop.ep_wbselc8,
    ep_wbselc9 emprop.ep_wbselc9,
    ep_wbshavr emprop.ep_wbshavr,
    ep_wbshcvc emprop.ep_wbshcvc,
    ep_wbshpch emprop.ep_wbshpch,
    ep_wbvoalw emprop.ep_wbvoalw
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caesent AS caBase OF cit_ca.vcx
Alias = [caesent]
Tables = [esent]
KeyFieldList = [es_esid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       es_attachm,
       es_body,
       es_datime,
       es_deleted,
       es_esid,
       es_rsid,
       es_status,
       es_subject,
       es_sysdate,
       es_userid
    FROM esent
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    es_attachm N(2,0)  DEFAULT 0,
    es_body    M       DEFAULT "",
    es_datime  T       DEFAULT {},
    es_deleted L       DEFAULT .F.,
    es_esid    N(8,0)  DEFAULT 0,
    es_rsid    I       DEFAULT 0,
    es_status  N(1,0)  DEFAULT 0,
    es_subject C(254)  DEFAULT "",
    es_sysdate D       DEFAULT {},
    es_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    es_attachm,
    es_body,
    es_datime,
    es_deleted,
    es_esid,
    es_rsid,
    es_status,
    es_subject,
    es_sysdate,
    es_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    es_attachm esent.es_attachm,
    es_body    esent.es_body,
    es_datime  esent.es_datime,
    es_deleted esent.es_deleted,
    es_esid    esent.es_esid,
    es_rsid    esent.es_rsid,
    es_status  esent.es_status,
    es_subject esent.es_subject,
    es_sysdate esent.es_sysdate,
    es_userid  esent.es_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caesentrcp AS caBase OF cit_ca.vcx
Alias = [caesentrcp]
Tables = [esentrcp]
KeyFieldList = [ec_addrid,ec_apid,ec_esid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ec_addrid,
       ec_apid,
       ec_disname,
       ec_email,
       ec_esid
    FROM esentrcp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ec_addrid  N(8,0)  DEFAULT 0,
    ec_apid    N(8,0)  DEFAULT 0,
    ec_disname C(120)  DEFAULT "",
    ec_email   C(254)  DEFAULT "",
    ec_esid    N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ec_addrid,
    ec_apid,
    ec_disname,
    ec_email,
    ec_esid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ec_addrid  esentrcp.ec_addrid,
    ec_apid    esentrcp.ec_apid,
    ec_disname esentrcp.ec_disname,
    ec_email   esentrcp.ec_email,
    ec_esid    esentrcp.ec_esid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caevents AS caBase OF cit_ca.vcx
Alias = [caevents]
Tables = [events]
KeyFieldList = [ev_evid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ev_city,
       ev_color,
       ev_evid,
       ev_name,
       ev_picture
    FROM events
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ev_city    C(30)   DEFAULT "",
    ev_color   C(11)   DEFAULT "",
    ev_evid    N(8,0)  DEFAULT 0,
    ev_name    C(30)   DEFAULT "",
    ev_picture C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ev_city,
    ev_color,
    ev_evid,
    ev_name,
    ev_picture
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ev_city    events.ev_city,
    ev_color   events.ev_color,
    ev_evid    events.ev_evid,
    ev_name    events.ev_name,
    ev_picture events.ev_picture
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caevint AS caBase OF cit_ca.vcx
Alias = [caevint]
Tables = [evint]
KeyFieldList = [ei_eiid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ei_eiid,
       ei_evid,
       ei_from,
       ei_to
    FROM evint
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ei_eiid    N(8,0)  DEFAULT 0,
    ei_evid    N(8,0)  DEFAULT 0,
    ei_from    D       DEFAULT {},
    ei_to      D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ei_eiid,
    ei_evid,
    ei_from,
    ei_to
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ei_eiid    evint.ei_eiid,
    ei_evid    evint.ei_evid,
    ei_from    evint.ei_from,
    ei_to      evint.ei_to
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caexterror AS caBase OF cit_ca.vcx
Alias = [caexterror]
Tables = [exterror]
KeyFieldList = [er_extid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       er_addrid,
       er_adults,
       er_anrede,
       er_arrdate,
       er_booking,
       er_city,
       er_company,
       er_compid,
       er_country,
       er_created,
       er_depdate,
       er_done,
       er_email,
       er_extid,
       er_fname,
       er_lname,
       er_note,
       er_paymeth,
       er_phone,
       er_rate,
       er_receivd,
       er_reserid,
       er_roomnum,
       er_rooms,
       er_roomtyp,
       er_source,
       er_srvid,
       er_status,
       er_street,
       er_title,
       er_uniquid,
       er_zip
    FROM exterror
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    er_addrid  N(8,0)  DEFAULT 0,
    er_adults  N(3,0)  DEFAULT 0,
    er_anrede  C(20)   DEFAULT "",
    er_arrdate D       DEFAULT {},
    er_booking N(14,0) DEFAULT 0,
    er_city    C(30)   DEFAULT "",
    er_company C(50)   DEFAULT "",
    er_compid  N(8,0)  DEFAULT 0,
    er_country C(30)   DEFAULT "",
    er_created D       DEFAULT {},
    er_depdate D       DEFAULT {},
    er_done    L       DEFAULT .F.,
    er_email   C(100)  DEFAULT "",
    er_extid   N(8,0)  DEFAULT 0,
    er_fname   C(20)   DEFAULT "",
    er_lname   C(30)   DEFAULT "",
    er_note    M       DEFAULT "",
    er_paymeth C(20)   DEFAULT "",
    er_phone   C(20)   DEFAULT "",
    er_rate    M       DEFAULT "",
    er_receivd T       DEFAULT {},
    er_reserid N(12,3) DEFAULT 0,
    er_roomnum C(4)    DEFAULT "",
    er_rooms   N(3,0)  DEFAULT 0,
    er_roomtyp C(4)    DEFAULT "",
    er_source  C(3)    DEFAULT "",
    er_srvid   I       DEFAULT 0,
    er_status  C(3)    DEFAULT "",
    er_street  C(30)   DEFAULT "",
    er_title   C(20)   DEFAULT "",
    er_uniquid C(50)   DEFAULT "",
    er_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    er_addrid,
    er_adults,
    er_anrede,
    er_arrdate,
    er_booking,
    er_city,
    er_company,
    er_compid,
    er_country,
    er_created,
    er_depdate,
    er_done,
    er_email,
    er_extid,
    er_fname,
    er_lname,
    er_note,
    er_paymeth,
    er_phone,
    er_rate,
    er_receivd,
    er_reserid,
    er_roomnum,
    er_rooms,
    er_roomtyp,
    er_source,
    er_srvid,
    er_status,
    er_street,
    er_title,
    er_uniquid,
    er_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    er_addrid  exterror.er_addrid,
    er_adults  exterror.er_adults,
    er_anrede  exterror.er_anrede,
    er_arrdate exterror.er_arrdate,
    er_booking exterror.er_booking,
    er_city    exterror.er_city,
    er_company exterror.er_company,
    er_compid  exterror.er_compid,
    er_country exterror.er_country,
    er_created exterror.er_created,
    er_depdate exterror.er_depdate,
    er_done    exterror.er_done,
    er_email   exterror.er_email,
    er_extid   exterror.er_extid,
    er_fname   exterror.er_fname,
    er_lname   exterror.er_lname,
    er_note    exterror.er_note,
    er_paymeth exterror.er_paymeth,
    er_phone   exterror.er_phone,
    er_rate    exterror.er_rate,
    er_receivd exterror.er_receivd,
    er_reserid exterror.er_reserid,
    er_roomnum exterror.er_roomnum,
    er_rooms   exterror.er_rooms,
    er_roomtyp exterror.er_roomtyp,
    er_source  exterror.er_source,
    er_srvid   exterror.er_srvid,
    er_status  exterror.er_status,
    er_street  exterror.er_street,
    er_title   exterror.er_title,
    er_uniquid exterror.er_uniquid,
    er_zip     exterror.er_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caextoffer AS caBase OF cit_ca.vcx
Alias = [caextoffer]
Tables = [extoffer]
KeyFieldList = [eo_eoid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       eo_booked,
       eo_booking,
       eo_chkoid,
       eo_credit,
       eo_currenc,
       eo_debit,
       eo_eoid,
       eo_import,
       eo_offer,
       eo_offerid,
       eo_paid,
       eo_paylog,
       eo_type,
       eo_wbccafc
    FROM extoffer
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    eo_booked  T       DEFAULT {},
    eo_booking M       DEFAULT "",
    eo_chkoid  C(90)   DEFAULT "",
    eo_credit  B(2)    DEFAULT 0,
    eo_currenc C(10)   DEFAULT "",
    eo_debit   B(2)    DEFAULT 0,
    eo_eoid    I       DEFAULT 0,
    eo_import  L       DEFAULT .F.,
    eo_offer   M       DEFAULT "",
    eo_offerid C(32)   DEFAULT "",
    eo_paid    L       DEFAULT .F.,
    eo_paylog  M       DEFAULT "",
    eo_type    C(20)   DEFAULT "",
    eo_wbccafc C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eo_booked,
    eo_booking,
    eo_chkoid,
    eo_credit,
    eo_currenc,
    eo_debit,
    eo_eoid,
    eo_import,
    eo_offer,
    eo_offerid,
    eo_paid,
    eo_paylog,
    eo_type,
    eo_wbccafc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    eo_booked  extoffer.eo_booked,
    eo_booking extoffer.eo_booking,
    eo_chkoid  extoffer.eo_chkoid,
    eo_credit  extoffer.eo_credit,
    eo_currenc extoffer.eo_currenc,
    eo_debit   extoffer.eo_debit,
    eo_eoid    extoffer.eo_eoid,
    eo_import  extoffer.eo_import,
    eo_offer   extoffer.eo_offer,
    eo_offerid extoffer.eo_offerid,
    eo_paid    extoffer.eo_paid,
    eo_paylog  extoffer.eo_paylog,
    eo_type    extoffer.eo_type,
    eo_wbccafc extoffer.eo_wbccafc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caextreser AS caBase OF cit_ca.vcx
Alias = [caextreser]
Tables = [extreser]
KeyFieldList = [er_extid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       er_addrid,
       er_adrtype,
       er_adults,
       er_anrede,
       er_arrdate,
       er_bookcod,
       er_booking,
       er_bsetid,
       er_cccvc,
       er_ccexpy,
       er_cchold,
       er_ccnum,
       er_cctype,
       er_changes,
       er_childs,
       er_childs2,
       er_childs3,
       er_city,
       er_cmid,
       er_company,
       er_compid,
       er_country,
       er_created,
       er_createt,
       er_depamt1,
       er_depdat1,
       er_depdate,
       er_done,
       er_email,
       er_extid,
       er_fix,
       er_fname,
       er_groomid,
       er_guests,
       er_ianrede,
       er_icity,
       er_icompan,
       er_icountr,
       er_iemail,
       er_ifname,
       er_ilname,
       er_inote,
       er_iphone,
       er_iphone2,
       er_iphone3,
       er_istree2,
       er_istreet,
       er_ititle,
       er_izip,
       er_lang,
       er_lname,
       er_market,
       er_modifyt,
       er_note,
       er_offerid,
       er_paymeth,
       er_phone,
       er_phone2,
       er_phone3,
       er_pin,
       er_pmscxl,
       er_pmscxls,
       er_rate,
       er_ratecod,
       er_receivd,
       er_reserid,
       er_roomnum,
       er_rooms,
       er_roomtyp,
       er_rtname,
       er_sadrtyp,
       er_scity,
       er_scountr,
       er_semail,
       er_sfname,
       er_slname,
       er_source,
       er_srvid,
       er_sstree2,
       er_sstreet,
       er_status,
       er_stitle,
       er_street,
       er_street2,
       er_szip,
       er_title,
       er_uniquid,
       er_vamount,
       er_voucher,
       er_zip
    FROM extreser
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    er_addrid  N(8,0)  DEFAULT 0,
    er_adrtype C(10)   DEFAULT "",
    er_adults  N(3,0)  DEFAULT 0,
    er_anrede  C(20)   DEFAULT "",
    er_arrdate D       DEFAULT {},
    er_bookcod C(20)   DEFAULT "",
    er_booking N(14,0) DEFAULT 0,
    er_bsetid  C(19)   DEFAULT "",
    er_cccvc   C(32)   DEFAULT "",
    er_ccexpy  C(32)   DEFAULT "",
    er_cchold  C(100)  DEFAULT "",
    er_ccnum   C(32)   DEFAULT "",
    er_cctype  C(20)   DEFAULT "",
    er_changes M       DEFAULT "",
    er_childs  N(3,0)  DEFAULT 0,
    er_childs2 N(1,0)  DEFAULT 0,
    er_childs3 N(1,0)  DEFAULT 0,
    er_city    C(30)   DEFAULT "",
    er_cmid    C(32)   DEFAULT "",
    er_company C(50)   DEFAULT "",
    er_compid  N(8,0)  DEFAULT 0,
    er_country C(30)   DEFAULT "",
    er_created D       DEFAULT {},
    er_createt T       DEFAULT {},
    er_depamt1 B(2)    DEFAULT 0,
    er_depdat1 D       DEFAULT {},
    er_depdate D       DEFAULT {},
    er_done    L       DEFAULT .F.,
    er_email   C(100)  DEFAULT "",
    er_extid   N(8,0)  DEFAULT 0,
    er_fix     M       DEFAULT "",
    er_fname   C(20)   DEFAULT "",
    er_groomid I       DEFAULT 0,
    er_guests  M       DEFAULT "",
    er_ianrede C(20)   DEFAULT "",
    er_icity   C(30)   DEFAULT "",
    er_icompan C(30)   DEFAULT "",
    er_icountr C(30)   DEFAULT "",
    er_iemail  C(100)  DEFAULT "",
    er_ifname  C(20)   DEFAULT "",
    er_ilname  C(30)   DEFAULT "",
    er_inote   M       DEFAULT "",
    er_iphone  C(20)   DEFAULT "",
    er_iphone2 C(20)   DEFAULT "",
    er_iphone3 C(20)   DEFAULT "",
    er_istree2 C(100)  DEFAULT "",
    er_istreet C(100)  DEFAULT "",
    er_ititle  C(20)   DEFAULT "",
    er_izip    C(10)   DEFAULT "",
    er_lang    C(3)    DEFAULT "",
    er_lname   C(30)   DEFAULT "",
    er_market  C(3)    DEFAULT "",
    er_modifyt T       DEFAULT {},
    er_note    M       DEFAULT "",
    er_offerid C(32)   DEFAULT "",
    er_paymeth C(20)   DEFAULT "",
    er_phone   C(20)   DEFAULT "",
    er_phone2  C(20)   DEFAULT "",
    er_phone3  C(20)   DEFAULT "",
    er_pin     C(8)    DEFAULT "",
    er_pmscxl  N(1,0)  DEFAULT 0,
    er_pmscxls D       DEFAULT {},
    er_rate    M       DEFAULT "",
    er_ratecod C(50)   DEFAULT "",
    er_receivd T       DEFAULT {},
    er_reserid N(12,3) DEFAULT 0,
    er_roomnum C(4)    DEFAULT "",
    er_rooms   N(3,0)  DEFAULT 0,
    er_roomtyp C(4)    DEFAULT "",
    er_rtname  C(10)   DEFAULT "",
    er_sadrtyp C(10)   DEFAULT "",
    er_scity   C(30)   DEFAULT "",
    er_scountr C(30)   DEFAULT "",
    er_semail  C(100)  DEFAULT "",
    er_sfname  C(20)   DEFAULT "",
    er_slname  C(30)   DEFAULT "",
    er_source  C(3)    DEFAULT "",
    er_srvid   I       DEFAULT 0,
    er_sstree2 C(100)  DEFAULT "",
    er_sstreet C(100)  DEFAULT "",
    er_status  C(3)    DEFAULT "",
    er_stitle  C(20)   DEFAULT "",
    er_street  C(100)  DEFAULT "",
    er_street2 C(100)  DEFAULT "",
    er_szip    C(10)   DEFAULT "",
    er_title   C(20)   DEFAULT "",
    er_uniquid C(50)   DEFAULT "",
    er_vamount N(12,2) DEFAULT 0,
    er_voucher C(20)   DEFAULT "",
    er_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    er_addrid,
    er_adrtype,
    er_adults,
    er_anrede,
    er_arrdate,
    er_bookcod,
    er_booking,
    er_bsetid,
    er_cccvc,
    er_ccexpy,
    er_cchold,
    er_ccnum,
    er_cctype,
    er_changes,
    er_childs,
    er_childs2,
    er_childs3,
    er_city,
    er_cmid,
    er_company,
    er_compid,
    er_country,
    er_created,
    er_createt,
    er_depamt1,
    er_depdat1,
    er_depdate,
    er_done,
    er_email,
    er_extid,
    er_fix,
    er_fname,
    er_groomid,
    er_guests,
    er_ianrede,
    er_icity,
    er_icompan,
    er_icountr,
    er_iemail,
    er_ifname,
    er_ilname,
    er_inote,
    er_iphone,
    er_iphone2,
    er_iphone3,
    er_istree2,
    er_istreet,
    er_ititle,
    er_izip,
    er_lang,
    er_lname,
    er_market,
    er_modifyt,
    er_note,
    er_offerid,
    er_paymeth,
    er_phone,
    er_phone2,
    er_phone3,
    er_pin,
    er_pmscxl,
    er_pmscxls,
    er_rate,
    er_ratecod,
    er_receivd,
    er_reserid,
    er_roomnum,
    er_rooms,
    er_roomtyp,
    er_rtname,
    er_sadrtyp,
    er_scity,
    er_scountr,
    er_semail,
    er_sfname,
    er_slname,
    er_source,
    er_srvid,
    er_sstree2,
    er_sstreet,
    er_status,
    er_stitle,
    er_street,
    er_street2,
    er_szip,
    er_title,
    er_uniquid,
    er_vamount,
    er_voucher,
    er_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    er_addrid  extreser.er_addrid,
    er_adrtype extreser.er_adrtype,
    er_adults  extreser.er_adults,
    er_anrede  extreser.er_anrede,
    er_arrdate extreser.er_arrdate,
    er_bookcod extreser.er_bookcod,
    er_booking extreser.er_booking,
    er_bsetid  extreser.er_bsetid,
    er_cccvc   extreser.er_cccvc,
    er_ccexpy  extreser.er_ccexpy,
    er_cchold  extreser.er_cchold,
    er_ccnum   extreser.er_ccnum,
    er_cctype  extreser.er_cctype,
    er_changes extreser.er_changes,
    er_childs  extreser.er_childs,
    er_childs2 extreser.er_childs2,
    er_childs3 extreser.er_childs3,
    er_city    extreser.er_city,
    er_cmid    extreser.er_cmid,
    er_company extreser.er_company,
    er_compid  extreser.er_compid,
    er_country extreser.er_country,
    er_created extreser.er_created,
    er_createt extreser.er_createt,
    er_depamt1 extreser.er_depamt1,
    er_depdat1 extreser.er_depdat1,
    er_depdate extreser.er_depdate,
    er_done    extreser.er_done,
    er_email   extreser.er_email,
    er_extid   extreser.er_extid,
    er_fix     extreser.er_fix,
    er_fname   extreser.er_fname,
    er_groomid extreser.er_groomid,
    er_guests  extreser.er_guests,
    er_ianrede extreser.er_ianrede,
    er_icity   extreser.er_icity,
    er_icompan extreser.er_icompan,
    er_icountr extreser.er_icountr,
    er_iemail  extreser.er_iemail,
    er_ifname  extreser.er_ifname,
    er_ilname  extreser.er_ilname,
    er_inote   extreser.er_inote,
    er_iphone  extreser.er_iphone,
    er_iphone2 extreser.er_iphone2,
    er_iphone3 extreser.er_iphone3,
    er_istree2 extreser.er_istree2,
    er_istreet extreser.er_istreet,
    er_ititle  extreser.er_ititle,
    er_izip    extreser.er_izip,
    er_lang    extreser.er_lang,
    er_lname   extreser.er_lname,
    er_market  extreser.er_market,
    er_modifyt extreser.er_modifyt,
    er_note    extreser.er_note,
    er_offerid extreser.er_offerid,
    er_paymeth extreser.er_paymeth,
    er_phone   extreser.er_phone,
    er_phone2  extreser.er_phone2,
    er_phone3  extreser.er_phone3,
    er_pin     extreser.er_pin,
    er_pmscxl  extreser.er_pmscxl,
    er_pmscxls extreser.er_pmscxls,
    er_rate    extreser.er_rate,
    er_ratecod extreser.er_ratecod,
    er_receivd extreser.er_receivd,
    er_reserid extreser.er_reserid,
    er_roomnum extreser.er_roomnum,
    er_rooms   extreser.er_rooms,
    er_roomtyp extreser.er_roomtyp,
    er_rtname  extreser.er_rtname,
    er_sadrtyp extreser.er_sadrtyp,
    er_scity   extreser.er_scity,
    er_scountr extreser.er_scountr,
    er_semail  extreser.er_semail,
    er_sfname  extreser.er_sfname,
    er_slname  extreser.er_slname,
    er_source  extreser.er_source,
    er_srvid   extreser.er_srvid,
    er_sstree2 extreser.er_sstree2,
    er_sstreet extreser.er_sstreet,
    er_status  extreser.er_status,
    er_stitle  extreser.er_stitle,
    er_street  extreser.er_street,
    er_street2 extreser.er_street2,
    er_szip    extreser.er_szip,
    er_title   extreser.er_title,
    er_uniquid extreser.er_uniquid,
    er_vamount extreser.er_vamount,
    er_voucher extreser.er_voucher,
    er_zip     extreser.er_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caextstat AS caBase OF cit_ca.vcx
Alias = [caextstat]
Tables = [extstat]
KeyFieldList = [ex_exid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ex_date,
       ex_exid,
       ex_source,
       ex_webbook,
       ex_website
    FROM extstat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ex_date    D       DEFAULT {},
    ex_exid    I       DEFAULT 0,
    ex_source  C(3)    DEFAULT "",
    ex_webbook I       DEFAULT 0,
    ex_website I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ex_date,
    ex_exid,
    ex_source,
    ex_webbook,
    ex_website
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ex_date    extstat.ex_date,
    ex_exid    extstat.ex_exid,
    ex_source  extstat.ex_source,
    ex_webbook extstat.ex_webbook,
    ex_website extstat.ex_website
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caextvouch AS caBase OF cit_ca.vcx
Alias = [caextvouch]
Tables = [extvouch]
KeyFieldList = [ve_veid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ve_amountl,
       ve_amounts,
       ve_amountv,
       ve_bbankac,
       ve_bbankid,
       ve_bbanknm,
       ve_bcccode,
       ve_bccexpy,
       ve_bcchold,
       ve_bccnum,
       ve_bcctype,
       ve_bcity,
       ve_bcompan,
       ve_bcountr,
       ve_bemail,
       ve_bfname,
       ve_blname,
       ve_bpaytyp,
       ve_bphone,
       ve_bstreet,
       ve_btitle,
       ve_bzip,
       ve_deleted,
       ve_done,
       ve_gcity,
       ve_gcompan,
       ve_gcountr,
       ve_gemail,
       ve_gfname,
       ve_glname,
       ve_gphone,
       ve_gstreet,
       ve_gtitle,
       ve_gzip,
       ve_note,
       ve_srvid,
       ve_sysdate,
       ve_text,
       ve_timstmp,
       ve_type,
       ve_uniquid,
       ve_veid,
       ve_vouchno
    FROM extvouch
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ve_amountl N(10,2) DEFAULT 0,
    ve_amounts N(10,2) DEFAULT 0,
    ve_amountv N(10,2) DEFAULT 0,
    ve_bbankac C(10)   DEFAULT "",
    ve_bbankid C(10)   DEFAULT "",
    ve_bbanknm C(50)   DEFAULT "",
    ve_bcccode C(2)    DEFAULT "",
    ve_bccexpy C(5)    DEFAULT "",
    ve_bcchold C(100)  DEFAULT "",
    ve_bccnum  C(20)   DEFAULT "",
    ve_bcctype C(20)   DEFAULT "",
    ve_bcity   C(30)   DEFAULT "",
    ve_bcompan C(30)   DEFAULT "",
    ve_bcountr C(30)   DEFAULT "",
    ve_bemail  C(100)  DEFAULT "",
    ve_bfname  C(20)   DEFAULT "",
    ve_blname  C(30)   DEFAULT "",
    ve_bpaytyp C(15)   DEFAULT "",
    ve_bphone  C(20)   DEFAULT "",
    ve_bstreet C(30)   DEFAULT "",
    ve_btitle  C(20)   DEFAULT "",
    ve_bzip    C(10)   DEFAULT "",
    ve_deleted L       DEFAULT .F.,
    ve_done    L       DEFAULT .F.,
    ve_gcity   C(30)   DEFAULT "",
    ve_gcompan C(30)   DEFAULT "",
    ve_gcountr C(30)   DEFAULT "",
    ve_gemail  C(100)  DEFAULT "",
    ve_gfname  C(20)   DEFAULT "",
    ve_glname  C(30)   DEFAULT "",
    ve_gphone  C(20)   DEFAULT "",
    ve_gstreet C(30)   DEFAULT "",
    ve_gtitle  C(20)   DEFAULT "",
    ve_gzip    C(10)   DEFAULT "",
    ve_note    M       DEFAULT "",
    ve_srvid   I       DEFAULT 0,
    ve_sysdate D       DEFAULT {},
    ve_text    M       DEFAULT "",
    ve_timstmp T       DEFAULT {},
    ve_type    N(1,0)  DEFAULT 0,
    ve_uniquid C(20)   DEFAULT "",
    ve_veid    I       DEFAULT 0,
    ve_vouchno C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ve_amountl,
    ve_amounts,
    ve_amountv,
    ve_bbankac,
    ve_bbankid,
    ve_bbanknm,
    ve_bcccode,
    ve_bccexpy,
    ve_bcchold,
    ve_bccnum,
    ve_bcctype,
    ve_bcity,
    ve_bcompan,
    ve_bcountr,
    ve_bemail,
    ve_bfname,
    ve_blname,
    ve_bpaytyp,
    ve_bphone,
    ve_bstreet,
    ve_btitle,
    ve_bzip,
    ve_deleted,
    ve_done,
    ve_gcity,
    ve_gcompan,
    ve_gcountr,
    ve_gemail,
    ve_gfname,
    ve_glname,
    ve_gphone,
    ve_gstreet,
    ve_gtitle,
    ve_gzip,
    ve_note,
    ve_srvid,
    ve_sysdate,
    ve_text,
    ve_timstmp,
    ve_type,
    ve_uniquid,
    ve_veid,
    ve_vouchno
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ve_amountl extvouch.ve_amountl,
    ve_amounts extvouch.ve_amounts,
    ve_amountv extvouch.ve_amountv,
    ve_bbankac extvouch.ve_bbankac,
    ve_bbankid extvouch.ve_bbankid,
    ve_bbanknm extvouch.ve_bbanknm,
    ve_bcccode extvouch.ve_bcccode,
    ve_bccexpy extvouch.ve_bccexpy,
    ve_bcchold extvouch.ve_bcchold,
    ve_bccnum  extvouch.ve_bccnum,
    ve_bcctype extvouch.ve_bcctype,
    ve_bcity   extvouch.ve_bcity,
    ve_bcompan extvouch.ve_bcompan,
    ve_bcountr extvouch.ve_bcountr,
    ve_bemail  extvouch.ve_bemail,
    ve_bfname  extvouch.ve_bfname,
    ve_blname  extvouch.ve_blname,
    ve_bpaytyp extvouch.ve_bpaytyp,
    ve_bphone  extvouch.ve_bphone,
    ve_bstreet extvouch.ve_bstreet,
    ve_btitle  extvouch.ve_btitle,
    ve_bzip    extvouch.ve_bzip,
    ve_deleted extvouch.ve_deleted,
    ve_done    extvouch.ve_done,
    ve_gcity   extvouch.ve_gcity,
    ve_gcompan extvouch.ve_gcompan,
    ve_gcountr extvouch.ve_gcountr,
    ve_gemail  extvouch.ve_gemail,
    ve_gfname  extvouch.ve_gfname,
    ve_glname  extvouch.ve_glname,
    ve_gphone  extvouch.ve_gphone,
    ve_gstreet extvouch.ve_gstreet,
    ve_gtitle  extvouch.ve_gtitle,
    ve_gzip    extvouch.ve_gzip,
    ve_note    extvouch.ve_note,
    ve_srvid   extvouch.ve_srvid,
    ve_sysdate extvouch.ve_sysdate,
    ve_text    extvouch.ve_text,
    ve_timstmp extvouch.ve_timstmp,
    ve_type    extvouch.ve_type,
    ve_uniquid extvouch.ve_uniquid,
    ve_veid    extvouch.ve_veid,
    ve_vouchno extvouch.ve_vouchno
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cafinaccnt AS caBase OF cit_ca.vcx
Alias = [cafinaccnt]
Tables = [finaccnt]
KeyFieldList = [fa_account]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       fa_account,
       fa_descr
    FROM finaccnt
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    fa_account N(8,0)  DEFAULT 0,
    fa_descr   C(50)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fa_account,
    fa_descr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fa_account finaccnt.fa_account,
    fa_descr   finaccnt.fa_descr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cafprinter AS caBase OF cit_ca.vcx
Alias = [cafprinter]
Tables = [fprinter]
KeyFieldList = [fp_fpnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       fp_artsync,
       fp_drvfile,
       fp_drvpath,
       fp_footer,
       fp_fpnr,
       fp_header,
       fp_lastrcp,
       fp_serial,
       fp_setfoot,
       fp_sethead,
       fp_setop,
       fp_winname
    FROM fprinter
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    fp_artsync L       DEFAULT .F.,
    fp_drvfile C(100)  DEFAULT "",
    fp_drvpath C(100)  DEFAULT "",
    fp_footer  M       DEFAULT "",
    fp_fpnr    N(2,0)  DEFAULT 0,
    fp_header  M       DEFAULT "",
    fp_lastrcp N(8,0)  DEFAULT 0,
    fp_serial  C(8)    DEFAULT "",
    fp_setfoot L       DEFAULT .F.,
    fp_sethead L       DEFAULT .F.,
    fp_setop   L       DEFAULT .F.,
    fp_winname C(15)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fp_artsync,
    fp_drvfile,
    fp_drvpath,
    fp_footer,
    fp_fpnr,
    fp_header,
    fp_lastrcp,
    fp_serial,
    fp_setfoot,
    fp_sethead,
    fp_setop,
    fp_winname
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fp_artsync fprinter.fp_artsync,
    fp_drvfile fprinter.fp_drvfile,
    fp_drvpath fprinter.fp_drvpath,
    fp_footer  fprinter.fp_footer,
    fp_fpnr    fprinter.fp_fpnr,
    fp_header  fprinter.fp_header,
    fp_lastrcp fprinter.fp_lastrcp,
    fp_serial  fprinter.fp_serial,
    fp_setfoot fprinter.fp_setfoot,
    fp_sethead fprinter.fp_sethead,
    fp_setop   fprinter.fp_setop,
    fp_winname fprinter.fp_winname
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cagrid AS caBase OF cit_ca.vcx
Alias = [cagrid]
Tables = [grid]
KeyFieldList = [gr_grid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       gr_activ,
       gr_align,
       gr_bold,
       gr_caption,
       gr_column,
       gr_dybaco,
       gr_dyfoco,
       gr_grid,
       gr_inpmask,
       gr_label,
       gr_movable,
       gr_order,
       gr_resize,
       gr_show,
       gr_source,
       gr_usbd,
       gr_usdbc,
       gr_usdfc,
       gr_user,
       gr_width
    FROM grid
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_activ   L       DEFAULT .F.,
    gr_align   N(1,0)  DEFAULT 0,
    gr_bold    L       DEFAULT .F.,
    gr_caption C(50)   DEFAULT "",
    gr_column  C(30)   DEFAULT "",
    gr_dybaco  C(254)  DEFAULT "",
    gr_dyfoco  C(254)  DEFAULT "",
    gr_grid    I       DEFAULT 0,
    gr_inpmask C(30)   DEFAULT "",
    gr_label   C(30)   DEFAULT "",
    gr_movable L       DEFAULT .F.,
    gr_order   N(3,0)  DEFAULT 0,
    gr_resize  L       DEFAULT .F.,
    gr_show    L       DEFAULT .F.,
    gr_source  C(254)  DEFAULT "",
    gr_usbd    L       DEFAULT .F.,
    gr_usdbc   I       DEFAULT 0,
    gr_usdfc   I       DEFAULT 0,
    gr_user    C(10)   DEFAULT "",
    gr_width   N(10,0) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_activ,
    gr_align,
    gr_bold,
    gr_caption,
    gr_column,
    gr_dybaco,
    gr_dyfoco,
    gr_grid,
    gr_inpmask,
    gr_label,
    gr_movable,
    gr_order,
    gr_resize,
    gr_show,
    gr_source,
    gr_usbd,
    gr_usdbc,
    gr_usdfc,
    gr_user,
    gr_width
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_activ   grid.gr_activ,
    gr_align   grid.gr_align,
    gr_bold    grid.gr_bold,
    gr_caption grid.gr_caption,
    gr_column  grid.gr_column,
    gr_dybaco  grid.gr_dybaco,
    gr_dyfoco  grid.gr_dyfoco,
    gr_grid    grid.gr_grid,
    gr_inpmask grid.gr_inpmask,
    gr_label   grid.gr_label,
    gr_movable grid.gr_movable,
    gr_order   grid.gr_order,
    gr_resize  grid.gr_resize,
    gr_show    grid.gr_show,
    gr_source  grid.gr_source,
    gr_usbd    grid.gr_usbd,
    gr_usdbc   grid.gr_usdbc,
    gr_usdfc   grid.gr_usdfc,
    gr_user    grid.gr_user,
    gr_width   grid.gr_width
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cagridprop AS caBase OF cit_ca.vcx
Alias = [cagridprop]
Tables = [gridprop]
KeyFieldList = [gp_label,gp_user]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       gp_hheight,
       gp_label,
       gp_rheight,
       gp_user
    FROM gridprop
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    gp_hheight N(3,0)  DEFAULT 0,
    gp_label   C(30)   DEFAULT "",
    gp_rheight N(3,0)  DEFAULT 0,
    gp_user    C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gp_hheight,
    gp_label,
    gp_rheight,
    gp_user
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gp_hheight gridprop.gp_hheight,
    gp_label   gridprop.gp_label,
    gp_rheight gridprop.gp_rheight,
    gp_user    gridprop.gp_user
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cagroup AS caBase OF cit_ca.vcx
Alias = [cagroup]
Tables = [group]
KeyFieldList = [gr_group]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       gr_address,
       gr_allott,
       gr_aze,
       gr_btcout2,
       gr_butadd2,
       gr_butaddr,
       gr_butbill,
       gr_butcout,
       gr_butgrou,
       gr_buthous,
       gr_butplan,
       gr_butrate,
       gr_butrese,
       gr_butrled,
       gr_butrscr,
       gr_butuser,
       gr_condayp,
       gr_conplan,
       gr_extra,
       gr_file,
       gr_financ,
       gr_group,
       gr_interfa,
       gr_maint,
       gr_manager,
       gr_multipr,
       gr_other,
       gr_report,
       gr_reserva,
       gr_view
    FROM group
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_address C(16)   DEFAULT "",
    gr_allott  C(16)   DEFAULT "",
    gr_aze     C(16)   DEFAULT "",
    gr_btcout2 C(16)   DEFAULT "",
    gr_butadd2 C(16)   DEFAULT "",
    gr_butaddr C(16)   DEFAULT "",
    gr_butbill C(16)   DEFAULT "",
    gr_butcout C(16)   DEFAULT "",
    gr_butgrou C(16)   DEFAULT "",
    gr_buthous C(16)   DEFAULT "",
    gr_butplan C(16)   DEFAULT "",
    gr_butrate C(16)   DEFAULT "",
    gr_butrese C(16)   DEFAULT "",
    gr_butrled C(16)   DEFAULT "",
    gr_butrscr C(16)   DEFAULT "",
    gr_butuser C(16)   DEFAULT "",
    gr_condayp C(16)   DEFAULT "",
    gr_conplan C(16)   DEFAULT "",
    gr_extra   C(16)   DEFAULT "",
    gr_file    C(16)   DEFAULT "",
    gr_financ  C(16)   DEFAULT "",
    gr_group   C(10)   DEFAULT "",
    gr_interfa C(16)   DEFAULT "",
    gr_maint   C(16)   DEFAULT "",
    gr_manager C(16)   DEFAULT "",
    gr_multipr C(16)   DEFAULT "",
    gr_other   C(16)   DEFAULT "",
    gr_report  C(16)   DEFAULT "",
    gr_reserva C(16)   DEFAULT "",
    gr_view    C(16)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_address,
    gr_allott,
    gr_aze,
    gr_btcout2,
    gr_butadd2,
    gr_butaddr,
    gr_butbill,
    gr_butcout,
    gr_butgrou,
    gr_buthous,
    gr_butplan,
    gr_butrate,
    gr_butrese,
    gr_butrled,
    gr_butrscr,
    gr_butuser,
    gr_condayp,
    gr_conplan,
    gr_extra,
    gr_file,
    gr_financ,
    gr_group,
    gr_interfa,
    gr_maint,
    gr_manager,
    gr_multipr,
    gr_other,
    gr_report,
    gr_reserva,
    gr_view
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_address group.gr_address,
    gr_allott  group.gr_allott,
    gr_aze     group.gr_aze,
    gr_btcout2 group.gr_btcout2,
    gr_butadd2 group.gr_butadd2,
    gr_butaddr group.gr_butaddr,
    gr_butbill group.gr_butbill,
    gr_butcout group.gr_butcout,
    gr_butgrou group.gr_butgrou,
    gr_buthous group.gr_buthous,
    gr_butplan group.gr_butplan,
    gr_butrate group.gr_butrate,
    gr_butrese group.gr_butrese,
    gr_butrled group.gr_butrled,
    gr_butrscr group.gr_butrscr,
    gr_butuser group.gr_butuser,
    gr_condayp group.gr_condayp,
    gr_conplan group.gr_conplan,
    gr_extra   group.gr_extra,
    gr_file    group.gr_file,
    gr_financ  group.gr_financ,
    gr_group   group.gr_group,
    gr_interfa group.gr_interfa,
    gr_maint   group.gr_maint,
    gr_manager group.gr_manager,
    gr_multipr group.gr_multipr,
    gr_other   group.gr_other,
    gr_report  group.gr_report,
    gr_reserva group.gr_reserva,
    gr_view    group.gr_view
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cagroupres AS caBase OF cit_ca.vcx
Alias = [cagroupres]
Tables = [groupres]
KeyFieldList = [gr_groupid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       gr_arrdate,
       gr_color,
       gr_depdate,
       gr_dpapost,
       gr_groupid,
       gr_name,
       gr_pmresid
    FROM groupres
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_arrdate D       DEFAULT {},
    gr_color   I       DEFAULT 0,
    gr_depdate D       DEFAULT {},
    gr_dpapost L       DEFAULT .F.,
    gr_groupid N(8,0)  DEFAULT 0,
    gr_name    C(25)   DEFAULT "",
    gr_pmresid N(12,3) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_arrdate,
    gr_color,
    gr_depdate,
    gr_dpapost,
    gr_groupid,
    gr_name,
    gr_pmresid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gr_arrdate groupres.gr_arrdate,
    gr_color   groupres.gr_color,
    gr_depdate groupres.gr_depdate,
    gr_dpapost groupres.gr_dpapost,
    gr_groupid groupres.gr_groupid,
    gr_name    groupres.gr_name,
    gr_pmresid groupres.gr_pmresid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahauptgrp AS caBase OF cit_ca.vcx
Alias = [cahauptgrp]
Tables = [hauptgrp]
KeyFieldList = [hg_nummer]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       hg_erlos,
       hg_nummer,
       hg_text
    FROM hauptgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    hg_erlos   L       DEFAULT .F.,
    hg_nummer  N(2,0)  DEFAULT 0,
    hg_text    C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    hg_erlos,
    hg_nummer,
    hg_text
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    hg_erlos   hauptgrp.hg_erlos,
    hg_nummer  hauptgrp.hg_nummer,
    hg_text    hauptgrp.hg_text
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahbanquet AS caBase OF cit_ca.vcx
Alias = [cahbanquet]
Tables = [hbanquet]
KeyFieldList = [bq_bqid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bq_artinum,
       bq_bqid,
       bq_calc,
       bq_confirm,
       bq_date,
       bq_descrip,
       bq_endtime,
       bq_memo,
       bq_menu,
       bq_price,
       bq_reserid,
       bq_roomnum,
       bq_rsrc,
       bq_rsrcqty,
       bq_time,
       bq_units,
       bq_where,
       bq_who
    FROM hbanquet
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_artinum N(4,0)  DEFAULT 0,
    bq_bqid    I       DEFAULT 0,
    bq_calc    L       DEFAULT .F.,
    bq_confirm L       DEFAULT .F.,
    bq_date    D       DEFAULT {},
    bq_descrip C(25)   DEFAULT "",
    bq_endtime C(5)    DEFAULT "",
    bq_memo    M       DEFAULT "",
    bq_menu    C(3)    DEFAULT "",
    bq_price   B(8)    DEFAULT 0,
    bq_reserid N(12,3) DEFAULT 0,
    bq_roomnum C(4)    DEFAULT "",
    bq_rsrc    C(3)    DEFAULT "",
    bq_rsrcqty N(3,0)  DEFAULT 0,
    bq_time    C(5)    DEFAULT "",
    bq_units   N(4,0)  DEFAULT 0,
    bq_where   C(20)   DEFAULT "",
    bq_who     C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_artinum,
    bq_bqid,
    bq_calc,
    bq_confirm,
    bq_date,
    bq_descrip,
    bq_endtime,
    bq_memo,
    bq_menu,
    bq_price,
    bq_reserid,
    bq_roomnum,
    bq_rsrc,
    bq_rsrcqty,
    bq_time,
    bq_units,
    bq_where,
    bq_who
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bq_artinum hbanquet.bq_artinum,
    bq_bqid    hbanquet.bq_bqid,
    bq_calc    hbanquet.bq_calc,
    bq_confirm hbanquet.bq_confirm,
    bq_date    hbanquet.bq_date,
    bq_descrip hbanquet.bq_descrip,
    bq_endtime hbanquet.bq_endtime,
    bq_memo    hbanquet.bq_memo,
    bq_menu    hbanquet.bq_menu,
    bq_price   hbanquet.bq_price,
    bq_reserid hbanquet.bq_reserid,
    bq_roomnum hbanquet.bq_roomnum,
    bq_rsrc    hbanquet.bq_rsrc,
    bq_rsrcqty hbanquet.bq_rsrcqty,
    bq_time    hbanquet.bq_time,
    bq_units   hbanquet.bq_units,
    bq_where   hbanquet.bq_where,
    bq_who     hbanquet.bq_who
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahbillins AS caBase OF cit_ca.vcx
Alias = [cahbillins]
Tables = [hbillins]
KeyFieldList = [bi_reserid,bi_day]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bi_day,
       bi_reserid
    FROM hbillins
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bi_day     N(3,0)  DEFAULT 0,
    bi_reserid N(12,3) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bi_day,
    bi_reserid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bi_day     hbillins.bi_day,
    bi_reserid hbillins.bi_reserid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahdeposit AS caBase OF cit_ca.vcx
Alias = [cahdeposit]
Tables = [hdeposit]
KeyFieldList = [dp_lineid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       dp_addpost,
       dp_artinum,
       dp_cashier,
       dp_credit,
       dp_date,
       dp_debit,
       dp_depcnt,
       dp_descrip,
       dp_due,
       dp_headid,
       dp_lineid,
       dp_paynum,
       dp_percent,
       dp_posted,
       dp_postid,
       dp_receipt,
       dp_recidet,
       dp_ref,
       dp_remcnt,
       dp_remlast,
       dp_reserid,
       dp_supplem,
       dp_sysdate,
       dp_userid
    FROM hdeposit
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_addpost L       DEFAULT .F.,
    dp_artinum N(4,0)  DEFAULT 0,
    dp_cashier N(2,0)  DEFAULT 0,
    dp_credit  B(8)    DEFAULT 0,
    dp_date    D       DEFAULT {},
    dp_debit   B(2)    DEFAULT 0,
    dp_depcnt  N(1,0)  DEFAULT 0,
    dp_descrip C(25)   DEFAULT "",
    dp_due     D       DEFAULT {},
    dp_headid  N(8,0)  DEFAULT 0,
    dp_lineid  N(8,0)  DEFAULT 0,
    dp_paynum  N(3,0)  DEFAULT 0,
    dp_percent B(8)    DEFAULT 0,
    dp_posted  D       DEFAULT {},
    dp_postid  N(8,0)  DEFAULT 0,
    dp_receipt I       DEFAULT 0,
    dp_recidet M       DEFAULT "",
    dp_ref     C(25)   DEFAULT "",
    dp_remcnt  N(2,0)  DEFAULT 0,
    dp_remlast D       DEFAULT {},
    dp_reserid N(12,3) DEFAULT 0,
    dp_supplem C(25)   DEFAULT "",
    dp_sysdate D       DEFAULT {},
    dp_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_addpost,
    dp_artinum,
    dp_cashier,
    dp_credit,
    dp_date,
    dp_debit,
    dp_depcnt,
    dp_descrip,
    dp_due,
    dp_headid,
    dp_lineid,
    dp_paynum,
    dp_percent,
    dp_posted,
    dp_postid,
    dp_receipt,
    dp_recidet,
    dp_ref,
    dp_remcnt,
    dp_remlast,
    dp_reserid,
    dp_supplem,
    dp_sysdate,
    dp_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_addpost hdeposit.dp_addpost,
    dp_artinum hdeposit.dp_artinum,
    dp_cashier hdeposit.dp_cashier,
    dp_credit  hdeposit.dp_credit,
    dp_date    hdeposit.dp_date,
    dp_debit   hdeposit.dp_debit,
    dp_depcnt  hdeposit.dp_depcnt,
    dp_descrip hdeposit.dp_descrip,
    dp_due     hdeposit.dp_due,
    dp_headid  hdeposit.dp_headid,
    dp_lineid  hdeposit.dp_lineid,
    dp_paynum  hdeposit.dp_paynum,
    dp_percent hdeposit.dp_percent,
    dp_posted  hdeposit.dp_posted,
    dp_postid  hdeposit.dp_postid,
    dp_receipt hdeposit.dp_receipt,
    dp_recidet hdeposit.dp_recidet,
    dp_ref     hdeposit.dp_ref,
    dp_remcnt  hdeposit.dp_remcnt,
    dp_remlast hdeposit.dp_remlast,
    dp_reserid hdeposit.dp_reserid,
    dp_supplem hdeposit.dp_supplem,
    dp_sysdate hdeposit.dp_sysdate,
    dp_userid  hdeposit.dp_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahistors AS caBase OF cit_ca.vcx
Alias = [cahistors]
Tables = [histors]
KeyFieldList = [or_label,or_code,or_date]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       or_0arrpax,
       or_0arrrms,
       or_0daypax,
       or_0dayrms,
       or_0deppax,
       or_0deprms,
       or_0pax,
       or_0rev0,
       or_0rev1,
       or_0rev2,
       or_0rev3,
       or_0rev4,
       or_0rev5,
       or_0rev6,
       or_0rev7,
       or_0rev8,
       or_0rev9,
       or_0revx,
       or_0rms,
       or_0vat0,
       or_0vat1,
       or_0vat2,
       or_0vat3,
       or_0vat4,
       or_0vat5,
       or_0vat6,
       or_0vat7,
       or_0vat8,
       or_0vat9,
       or_0vatx,
       or_carrpax,
       or_carrrms,
       or_cdaypax,
       or_cdayrms,
       or_cdeppax,
       or_cdeprms,
       or_code,
       or_cpax,
       or_crev0,
       or_crev1,
       or_crev2,
       or_crev3,
       or_crev4,
       or_crev5,
       or_crev6,
       or_crev7,
       or_crev8,
       or_crev9,
       or_crevx,
       or_crms,
       or_cvat0,
       or_cvat1,
       or_cvat2,
       or_cvat3,
       or_cvat4,
       or_cvat5,
       or_cvat6,
       or_cvat7,
       or_cvat8,
       or_cvat9,
       or_cvatx,
       or_date,
       or_label
    FROM histors
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_0arrpax N(9,0)  DEFAULT 0,
    or_0arrrms N(7,0)  DEFAULT 0,
    or_0daypax N(9,0)  DEFAULT 0,
    or_0dayrms N(7,0)  DEFAULT 0,
    or_0deppax N(9,0)  DEFAULT 0,
    or_0deprms N(7,0)  DEFAULT 0,
    or_0pax    N(9,0)  DEFAULT 0,
    or_0rev0   N(20,2) DEFAULT 0,
    or_0rev1   N(20,2) DEFAULT 0,
    or_0rev2   N(20,2) DEFAULT 0,
    or_0rev3   N(20,2) DEFAULT 0,
    or_0rev4   N(20,2) DEFAULT 0,
    or_0rev5   N(20,2) DEFAULT 0,
    or_0rev6   N(20,2) DEFAULT 0,
    or_0rev7   N(20,2) DEFAULT 0,
    or_0rev8   N(20,2) DEFAULT 0,
    or_0rev9   N(20,2) DEFAULT 0,
    or_0revx   N(20,2) DEFAULT 0,
    or_0rms    N(7,0)  DEFAULT 0,
    or_0vat0   N(20,6) DEFAULT 0,
    or_0vat1   N(20,6) DEFAULT 0,
    or_0vat2   N(20,6) DEFAULT 0,
    or_0vat3   N(20,6) DEFAULT 0,
    or_0vat4   N(20,6) DEFAULT 0,
    or_0vat5   N(20,6) DEFAULT 0,
    or_0vat6   N(20,6) DEFAULT 0,
    or_0vat7   N(20,6) DEFAULT 0,
    or_0vat8   N(20,6) DEFAULT 0,
    or_0vat9   N(20,6) DEFAULT 0,
    or_0vatx   N(20,6) DEFAULT 0,
    or_carrpax N(9,0)  DEFAULT 0,
    or_carrrms N(7,0)  DEFAULT 0,
    or_cdaypax N(9,0)  DEFAULT 0,
    or_cdayrms N(7,0)  DEFAULT 0,
    or_cdeppax N(9,0)  DEFAULT 0,
    or_cdeprms N(7,0)  DEFAULT 0,
    or_code    C(10)   DEFAULT "",
    or_cpax    N(9,0)  DEFAULT 0,
    or_crev0   N(20,2) DEFAULT 0,
    or_crev1   N(20,2) DEFAULT 0,
    or_crev2   N(20,2) DEFAULT 0,
    or_crev3   N(20,2) DEFAULT 0,
    or_crev4   N(20,2) DEFAULT 0,
    or_crev5   N(20,2) DEFAULT 0,
    or_crev6   N(20,2) DEFAULT 0,
    or_crev7   N(20,2) DEFAULT 0,
    or_crev8   N(20,2) DEFAULT 0,
    or_crev9   N(20,2) DEFAULT 0,
    or_crevx   N(20,2) DEFAULT 0,
    or_crms    N(7,0)  DEFAULT 0,
    or_cvat0   N(20,6) DEFAULT 0,
    or_cvat1   N(20,6) DEFAULT 0,
    or_cvat2   N(20,6) DEFAULT 0,
    or_cvat3   N(20,6) DEFAULT 0,
    or_cvat4   N(20,6) DEFAULT 0,
    or_cvat5   N(20,6) DEFAULT 0,
    or_cvat6   N(20,6) DEFAULT 0,
    or_cvat7   N(20,6) DEFAULT 0,
    or_cvat8   N(20,6) DEFAULT 0,
    or_cvat9   N(20,6) DEFAULT 0,
    or_cvatx   N(20,6) DEFAULT 0,
    or_date    D       DEFAULT {},
    or_label   C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_0arrpax,
    or_0arrrms,
    or_0daypax,
    or_0dayrms,
    or_0deppax,
    or_0deprms,
    or_0pax,
    or_0rev0,
    or_0rev1,
    or_0rev2,
    or_0rev3,
    or_0rev4,
    or_0rev5,
    or_0rev6,
    or_0rev7,
    or_0rev8,
    or_0rev9,
    or_0revx,
    or_0rms,
    or_0vat0,
    or_0vat1,
    or_0vat2,
    or_0vat3,
    or_0vat4,
    or_0vat5,
    or_0vat6,
    or_0vat7,
    or_0vat8,
    or_0vat9,
    or_0vatx,
    or_carrpax,
    or_carrrms,
    or_cdaypax,
    or_cdayrms,
    or_cdeppax,
    or_cdeprms,
    or_code,
    or_cpax,
    or_crev0,
    or_crev1,
    or_crev2,
    or_crev3,
    or_crev4,
    or_crev5,
    or_crev6,
    or_crev7,
    or_crev8,
    or_crev9,
    or_crevx,
    or_crms,
    or_cvat0,
    or_cvat1,
    or_cvat2,
    or_cvat3,
    or_cvat4,
    or_cvat5,
    or_cvat6,
    or_cvat7,
    or_cvat8,
    or_cvat9,
    or_cvatx,
    or_date,
    or_label
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_0arrpax histors.or_0arrpax,
    or_0arrrms histors.or_0arrrms,
    or_0daypax histors.or_0daypax,
    or_0dayrms histors.or_0dayrms,
    or_0deppax histors.or_0deppax,
    or_0deprms histors.or_0deprms,
    or_0pax    histors.or_0pax,
    or_0rev0   histors.or_0rev0,
    or_0rev1   histors.or_0rev1,
    or_0rev2   histors.or_0rev2,
    or_0rev3   histors.or_0rev3,
    or_0rev4   histors.or_0rev4,
    or_0rev5   histors.or_0rev5,
    or_0rev6   histors.or_0rev6,
    or_0rev7   histors.or_0rev7,
    or_0rev8   histors.or_0rev8,
    or_0rev9   histors.or_0rev9,
    or_0revx   histors.or_0revx,
    or_0rms    histors.or_0rms,
    or_0vat0   histors.or_0vat0,
    or_0vat1   histors.or_0vat1,
    or_0vat2   histors.or_0vat2,
    or_0vat3   histors.or_0vat3,
    or_0vat4   histors.or_0vat4,
    or_0vat5   histors.or_0vat5,
    or_0vat6   histors.or_0vat6,
    or_0vat7   histors.or_0vat7,
    or_0vat8   histors.or_0vat8,
    or_0vat9   histors.or_0vat9,
    or_0vatx   histors.or_0vatx,
    or_carrpax histors.or_carrpax,
    or_carrrms histors.or_carrrms,
    or_cdaypax histors.or_cdaypax,
    or_cdayrms histors.or_cdayrms,
    or_cdeppax histors.or_cdeppax,
    or_cdeprms histors.or_cdeprms,
    or_code    histors.or_code,
    or_cpax    histors.or_cpax,
    or_crev0   histors.or_crev0,
    or_crev1   histors.or_crev1,
    or_crev2   histors.or_crev2,
    or_crev3   histors.or_crev3,
    or_crev4   histors.or_crev4,
    or_crev5   histors.or_crev5,
    or_crev6   histors.or_crev6,
    or_crev7   histors.or_crev7,
    or_crev8   histors.or_crev8,
    or_crev9   histors.or_crev9,
    or_crevx   histors.or_crevx,
    or_crms    histors.or_crms,
    or_cvat0   histors.or_cvat0,
    or_cvat1   histors.or_cvat1,
    or_cvat2   histors.or_cvat2,
    or_cvat3   histors.or_cvat3,
    or_cvat4   histors.or_cvat4,
    or_cvat5   histors.or_cvat5,
    or_cvat6   histors.or_cvat6,
    or_cvat7   histors.or_cvat7,
    or_cvat8   histors.or_cvat8,
    or_cvat9   histors.or_cvat9,
    or_cvatx   histors.or_cvatx,
    or_date    histors.or_date,
    or_label   histors.or_label
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahistpost AS caBase OF cit_ca.vcx
Alias = [cahistpost]
Tables = [histpost]
KeyFieldList = [hp_postid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       hp_addrid,
       hp_amount,
       hp_artinum,
       hp_bdate,
       hp_billnum,
       hp_buildng,
       hp_cancel,
       hp_cashier,
       hp_currtxt,
       hp_date,
       hp_descrip,
       hp_fibdat,
       hp_finacct,
       hp_ifc,
       hp_note,
       hp_origid,
       hp_paynum,
       hp_posbiln,
       hp_postid,
       hp_price,
       hp_prtype,
       hp_raid,
       hp_ratecod,
       hp_rdate,
       hp_reserid,
       hp_setid,
       hp_split,
       hp_supplem,
       hp_time,
       hp_units,
       hp_userid,
       hp_vat0,
       hp_vat1,
       hp_vat2,
       hp_vat3,
       hp_vat4,
       hp_vat5,
       hp_vat6,
       hp_vat7,
       hp_vat8,
       hp_vat9,
       hp_vouccpy,
       hp_voucnum,
       hp_window
    FROM histpost
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    hp_addrid  N(8,0)  DEFAULT 0,
    hp_amount  B(2)    DEFAULT 0,
    hp_artinum N(4,0)  DEFAULT 0,
    hp_bdate   D       DEFAULT {},
    hp_billnum C(10)   DEFAULT "",
    hp_buildng C(3)    DEFAULT "",
    hp_cancel  L       DEFAULT .F.,
    hp_cashier N(2,0)  DEFAULT 0,
    hp_currtxt M       DEFAULT "",
    hp_date    D       DEFAULT {},
    hp_descrip C(25)   DEFAULT "",
    hp_fibdat  T       DEFAULT {},
    hp_finacct N(8,0)  DEFAULT 0,
    hp_ifc     M       DEFAULT "",
    hp_note    M       DEFAULT "",
    hp_origid  N(12,3) DEFAULT 0,
    hp_paynum  N(3,0)  DEFAULT 0,
    hp_posbiln I       DEFAULT 0,
    hp_postid  N(8,0)  DEFAULT 0,
    hp_price   B(6)    DEFAULT 0,
    hp_prtype  N(2,0)  DEFAULT 0,
    hp_raid    N(10,0) DEFAULT 0,
    hp_ratecod C(23)   DEFAULT "",
    hp_rdate   D       DEFAULT {},
    hp_reserid N(12,3) DEFAULT 0,
    hp_setid   N(8,0)  DEFAULT 0,
    hp_split   L       DEFAULT .F.,
    hp_supplem C(150)  DEFAULT "",
    hp_time    C(5)    DEFAULT "",
    hp_units   B(2)    DEFAULT 0,
    hp_userid  C(10)   DEFAULT "",
    hp_vat0    B(6)    DEFAULT 0,
    hp_vat1    B(6)    DEFAULT 0,
    hp_vat2    B(6)    DEFAULT 0,
    hp_vat3    B(6)    DEFAULT 0,
    hp_vat4    B(6)    DEFAULT 0,
    hp_vat5    B(6)    DEFAULT 0,
    hp_vat6    B(6)    DEFAULT 0,
    hp_vat7    B(6)    DEFAULT 0,
    hp_vat8    B(6)    DEFAULT 0,
    hp_vat9    B(6)    DEFAULT 0,
    hp_vouccpy N(2,0)  DEFAULT 0,
    hp_voucnum N(10,0) DEFAULT 0,
    hp_window  I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    hp_addrid,
    hp_amount,
    hp_artinum,
    hp_bdate,
    hp_billnum,
    hp_buildng,
    hp_cancel,
    hp_cashier,
    hp_currtxt,
    hp_date,
    hp_descrip,
    hp_fibdat,
    hp_finacct,
    hp_ifc,
    hp_note,
    hp_origid,
    hp_paynum,
    hp_posbiln,
    hp_postid,
    hp_price,
    hp_prtype,
    hp_raid,
    hp_ratecod,
    hp_rdate,
    hp_reserid,
    hp_setid,
    hp_split,
    hp_supplem,
    hp_time,
    hp_units,
    hp_userid,
    hp_vat0,
    hp_vat1,
    hp_vat2,
    hp_vat3,
    hp_vat4,
    hp_vat5,
    hp_vat6,
    hp_vat7,
    hp_vat8,
    hp_vat9,
    hp_vouccpy,
    hp_voucnum,
    hp_window
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    hp_addrid  histpost.hp_addrid,
    hp_amount  histpost.hp_amount,
    hp_artinum histpost.hp_artinum,
    hp_bdate   histpost.hp_bdate,
    hp_billnum histpost.hp_billnum,
    hp_buildng histpost.hp_buildng,
    hp_cancel  histpost.hp_cancel,
    hp_cashier histpost.hp_cashier,
    hp_currtxt histpost.hp_currtxt,
    hp_date    histpost.hp_date,
    hp_descrip histpost.hp_descrip,
    hp_fibdat  histpost.hp_fibdat,
    hp_finacct histpost.hp_finacct,
    hp_ifc     histpost.hp_ifc,
    hp_note    histpost.hp_note,
    hp_origid  histpost.hp_origid,
    hp_paynum  histpost.hp_paynum,
    hp_posbiln histpost.hp_posbiln,
    hp_postid  histpost.hp_postid,
    hp_price   histpost.hp_price,
    hp_prtype  histpost.hp_prtype,
    hp_raid    histpost.hp_raid,
    hp_ratecod histpost.hp_ratecod,
    hp_rdate   histpost.hp_rdate,
    hp_reserid histpost.hp_reserid,
    hp_setid   histpost.hp_setid,
    hp_split   histpost.hp_split,
    hp_supplem histpost.hp_supplem,
    hp_time    histpost.hp_time,
    hp_units   histpost.hp_units,
    hp_userid  histpost.hp_userid,
    hp_vat0    histpost.hp_vat0,
    hp_vat1    histpost.hp_vat1,
    hp_vat2    histpost.hp_vat2,
    hp_vat3    histpost.hp_vat3,
    hp_vat4    histpost.hp_vat4,
    hp_vat5    histpost.hp_vat5,
    hp_vat6    histpost.hp_vat6,
    hp_vat7    histpost.hp_vat7,
    hp_vat8    histpost.hp_vat8,
    hp_vat9    histpost.hp_vat9,
    hp_vouccpy histpost.hp_vouccpy,
    hp_voucnum histpost.hp_voucnum,
    hp_window  histpost.hp_window
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahistres AS caBase OF cit_ca.vcx
Alias = [cahistres]
Tables = [histres]
KeyFieldList = [hr_rsid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       hr_addrid,
       hr_adults,
       hr_agent,
       hr_agentid,
       hr_allott,
       hr_altid,
       hr_apid,
       hr_apname,
       hr_arrdate,
       hr_arrtime,
       hr_benum,
       hr_billins,
       hr_billnr1,
       hr_billnr2,
       hr_billnr3,
       hr_billnr4,
       hr_billnr5,
       hr_billnr6,
       hr_bmsto1w,
       hr_ccauth,
       hr_ccexpy,
       hr_ccnum,
       hr_changes,
       hr_childs,
       hr_childs2,
       hr_childs3,
       hr_cidate,
       hr_citime,
       hr_cnfstat,
       hr_codate,
       hr_company,
       hr_compid,
       hr_complim,
       hr_conbill,
       hr_conres,
       hr_copyw1,
       hr_copyw2,
       hr_copyw3,
       hr_copyw4,
       hr_copyw5,
       hr_copyw6,
       hr_cotime,
       hr_country,
       hr_created,
       hr_creatus,
       hr_cxldate,
       hr_cxlnr,
       hr_depamt1,
       hr_depamt2,
       hr_depdat1,
       hr_depdat2,
       hr_depdate,
       hr_deppaid,
       hr_deptime,
       hr_discnt,
       hr_eiid,
       hr_emailst,
       hr_fname,
       hr_group,
       hr_groupid,
       hr_in,
       hr_invap,
       hr_invapid,
       hr_invid,
       hr_lfinish,
       hr_lname,
       hr_lstart,
       hr_market,
       hr_noaddr,
       hr_note,
       hr_notew1,
       hr_notew2,
       hr_notew3,
       hr_notew4,
       hr_notew5,
       hr_notew6,
       hr_optdate,
       hr_orgarrd,
       hr_out,
       hr_paymeth,
       hr_paynum1,
       hr_paynum2,
       hr_paynum3,
       hr_paynum4,
       hr_paynum5,
       hr_paynum6,
       hr_rate,
       hr_ratecod,
       hr_ratedat,
       hr_ratein,
       hr_rateout,
       hr_recur,
       hr_reserid,
       hr_rglayou,
       hr_roomlst,
       hr_roomnum,
       hr_rooms,
       hr_roomtyp,
       hr_rsid,
       hr_share,
       hr_source,
       hr_status,
       hr_title,
       hr_updated,
       hr_userid,
       hr_usrres0,
       hr_usrres1,
       hr_usrres2,
       hr_usrres3,
       hr_usrres4,
       hr_usrres5,
       hr_usrres6,
       hr_usrres7,
       hr_usrres8,
       hr_usrres9
    FROM histres
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    hr_addrid  N(8,0)  DEFAULT 0,
    hr_adults  N(3,0)  DEFAULT 0,
    hr_agent   C(30)   DEFAULT "",
    hr_agentid N(8,0)  DEFAULT 0,
    hr_allott  C(10)   DEFAULT "",
    hr_altid   N(8,0)  DEFAULT 0,
    hr_apid    N(8,0)  DEFAULT 0,
    hr_apname  C(50)   DEFAULT "",
    hr_arrdate D       DEFAULT {},
    hr_arrtime C(5)    DEFAULT "",
    hr_benum   N(2,0)  DEFAULT 0,
    hr_billins M       DEFAULT "",
    hr_billnr1 C(10)   DEFAULT "",
    hr_billnr2 C(10)   DEFAULT "",
    hr_billnr3 C(10)   DEFAULT "",
    hr_billnr4 C(10)   DEFAULT "",
    hr_billnr5 C(10)   DEFAULT "",
    hr_billnr6 C(10)   DEFAULT "",
    hr_bmsto1w C(6)    DEFAULT "",
    hr_ccauth  C(32)   DEFAULT "",
    hr_ccexpy  C(32)   DEFAULT "",
    hr_ccnum   C(32)   DEFAULT "",
    hr_changes M       DEFAULT "",
    hr_childs  N(3,0)  DEFAULT 0,
    hr_childs2 N(1,0)  DEFAULT 0,
    hr_childs3 N(1,0)  DEFAULT 0,
    hr_cidate  D       DEFAULT {},
    hr_citime  C(8)    DEFAULT "",
    hr_cnfstat C(3)    DEFAULT "",
    hr_codate  D       DEFAULT {},
    hr_company C(30)   DEFAULT "",
    hr_compid  N(8,0)  DEFAULT 0,
    hr_complim L       DEFAULT .F.,
    hr_conbill C(30)   DEFAULT "",
    hr_conres  C(30)   DEFAULT "",
    hr_copyw1  N(2,0)  DEFAULT 0,
    hr_copyw2  N(2,0)  DEFAULT 0,
    hr_copyw3  N(2,0)  DEFAULT 0,
    hr_copyw4  N(2,0)  DEFAULT 0,
    hr_copyw5  N(2,0)  DEFAULT 0,
    hr_copyw6  N(2,0)  DEFAULT 0,
    hr_cotime  C(8)    DEFAULT "",
    hr_country C(3)    DEFAULT "",
    hr_created D       DEFAULT {},
    hr_creatus C(10)   DEFAULT "",
    hr_cxldate D       DEFAULT {},
    hr_cxlnr   N(8,0)  DEFAULT 0,
    hr_depamt1 B(2)    DEFAULT 0,
    hr_depamt2 B(2)    DEFAULT 0,
    hr_depdat1 D       DEFAULT {},
    hr_depdat2 D       DEFAULT {},
    hr_depdate D       DEFAULT {},
    hr_deppaid N(12,0) DEFAULT 0,
    hr_deptime C(5)    DEFAULT "",
    hr_discnt  C(3)    DEFAULT "",
    hr_eiid    N(8,0)  DEFAULT 0,
    hr_emailst N(1,0)  DEFAULT 0,
    hr_fname   C(20)   DEFAULT "",
    hr_group   C(25)   DEFAULT "",
    hr_groupid N(8,0)  DEFAULT 0,
    hr_in      C(1)    DEFAULT "",
    hr_invap   C(30)   DEFAULT "",
    hr_invapid N(8,0)  DEFAULT 0,
    hr_invid   N(8,0)  DEFAULT 0,
    hr_lfinish C(3)    DEFAULT "",
    hr_lname   C(30)   DEFAULT "",
    hr_lstart  C(3)    DEFAULT "",
    hr_market  C(3)    DEFAULT "",
    hr_noaddr  L       DEFAULT .F.,
    hr_note    M       DEFAULT "",
    hr_notew1  M       DEFAULT "",
    hr_notew2  M       DEFAULT "",
    hr_notew3  M       DEFAULT "",
    hr_notew4  M       DEFAULT "",
    hr_notew5  M       DEFAULT "",
    hr_notew6  M       DEFAULT "",
    hr_optdate D       DEFAULT {},
    hr_orgarrd D       DEFAULT {},
    hr_out     C(1)    DEFAULT "",
    hr_paymeth C(4)    DEFAULT "",
    hr_paynum1 N(2,0)  DEFAULT 0,
    hr_paynum2 N(2,0)  DEFAULT 0,
    hr_paynum3 N(2,0)  DEFAULT 0,
    hr_paynum4 N(2,0)  DEFAULT 0,
    hr_paynum5 N(2,0)  DEFAULT 0,
    hr_paynum6 N(2,0)  DEFAULT 0,
    hr_rate    B(2)    DEFAULT 0,
    hr_ratecod C(10)   DEFAULT "",
    hr_ratedat D       DEFAULT {},
    hr_ratein  L       DEFAULT .F.,
    hr_rateout L       DEFAULT .F.,
    hr_recur   C(20)   DEFAULT "",
    hr_reserid N(12,3) DEFAULT 0,
    hr_rglayou C(7)    DEFAULT "",
    hr_roomlst L       DEFAULT .F.,
    hr_roomnum C(4)    DEFAULT "",
    hr_rooms   N(3,0)  DEFAULT 0,
    hr_roomtyp C(4)    DEFAULT "",
    hr_rsid    I       DEFAULT 0,
    hr_share   C(2)    DEFAULT "",
    hr_source  C(3)    DEFAULT "",
    hr_status  C(3)    DEFAULT "",
    hr_title   C(20)   DEFAULT "",
    hr_updated D       DEFAULT {},
    hr_userid  C(10)   DEFAULT "",
    hr_usrres0 C(100)  DEFAULT "",
    hr_usrres1 C(100)  DEFAULT "",
    hr_usrres2 C(100)  DEFAULT "",
    hr_usrres3 C(100)  DEFAULT "",
    hr_usrres4 C(100)  DEFAULT "",
    hr_usrres5 C(100)  DEFAULT "",
    hr_usrres6 C(100)  DEFAULT "",
    hr_usrres7 C(100)  DEFAULT "",
    hr_usrres8 C(100)  DEFAULT "",
    hr_usrres9 C(100)  DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    hr_addrid,
    hr_adults,
    hr_agent,
    hr_agentid,
    hr_allott,
    hr_altid,
    hr_apid,
    hr_apname,
    hr_arrdate,
    hr_arrtime,
    hr_benum,
    hr_billins,
    hr_billnr1,
    hr_billnr2,
    hr_billnr3,
    hr_billnr4,
    hr_billnr5,
    hr_billnr6,
    hr_bmsto1w,
    hr_ccauth,
    hr_ccexpy,
    hr_ccnum,
    hr_changes,
    hr_childs,
    hr_childs2,
    hr_childs3,
    hr_cidate,
    hr_citime,
    hr_cnfstat,
    hr_codate,
    hr_company,
    hr_compid,
    hr_complim,
    hr_conbill,
    hr_conres,
    hr_copyw1,
    hr_copyw2,
    hr_copyw3,
    hr_copyw4,
    hr_copyw5,
    hr_copyw6,
    hr_cotime,
    hr_country,
    hr_created,
    hr_creatus,
    hr_cxldate,
    hr_cxlnr,
    hr_depamt1,
    hr_depamt2,
    hr_depdat1,
    hr_depdat2,
    hr_depdate,
    hr_deppaid,
    hr_deptime,
    hr_discnt,
    hr_eiid,
    hr_emailst,
    hr_fname,
    hr_group,
    hr_groupid,
    hr_in,
    hr_invap,
    hr_invapid,
    hr_invid,
    hr_lfinish,
    hr_lname,
    hr_lstart,
    hr_market,
    hr_noaddr,
    hr_note,
    hr_notew1,
    hr_notew2,
    hr_notew3,
    hr_notew4,
    hr_notew5,
    hr_notew6,
    hr_optdate,
    hr_orgarrd,
    hr_out,
    hr_paymeth,
    hr_paynum1,
    hr_paynum2,
    hr_paynum3,
    hr_paynum4,
    hr_paynum5,
    hr_paynum6,
    hr_rate,
    hr_ratecod,
    hr_ratedat,
    hr_ratein,
    hr_rateout,
    hr_recur,
    hr_reserid,
    hr_rglayou,
    hr_roomlst,
    hr_roomnum,
    hr_rooms,
    hr_roomtyp,
    hr_rsid,
    hr_share,
    hr_source,
    hr_status,
    hr_title,
    hr_updated,
    hr_userid,
    hr_usrres0,
    hr_usrres1,
    hr_usrres2,
    hr_usrres3,
    hr_usrres4,
    hr_usrres5,
    hr_usrres6,
    hr_usrres7,
    hr_usrres8,
    hr_usrres9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    hr_addrid  histres.hr_addrid,
    hr_adults  histres.hr_adults,
    hr_agent   histres.hr_agent,
    hr_agentid histres.hr_agentid,
    hr_allott  histres.hr_allott,
    hr_altid   histres.hr_altid,
    hr_apid    histres.hr_apid,
    hr_apname  histres.hr_apname,
    hr_arrdate histres.hr_arrdate,
    hr_arrtime histres.hr_arrtime,
    hr_benum   histres.hr_benum,
    hr_billins histres.hr_billins,
    hr_billnr1 histres.hr_billnr1,
    hr_billnr2 histres.hr_billnr2,
    hr_billnr3 histres.hr_billnr3,
    hr_billnr4 histres.hr_billnr4,
    hr_billnr5 histres.hr_billnr5,
    hr_billnr6 histres.hr_billnr6,
    hr_bmsto1w histres.hr_bmsto1w,
    hr_ccauth  histres.hr_ccauth,
    hr_ccexpy  histres.hr_ccexpy,
    hr_ccnum   histres.hr_ccnum,
    hr_changes histres.hr_changes,
    hr_childs  histres.hr_childs,
    hr_childs2 histres.hr_childs2,
    hr_childs3 histres.hr_childs3,
    hr_cidate  histres.hr_cidate,
    hr_citime  histres.hr_citime,
    hr_cnfstat histres.hr_cnfstat,
    hr_codate  histres.hr_codate,
    hr_company histres.hr_company,
    hr_compid  histres.hr_compid,
    hr_complim histres.hr_complim,
    hr_conbill histres.hr_conbill,
    hr_conres  histres.hr_conres,
    hr_copyw1  histres.hr_copyw1,
    hr_copyw2  histres.hr_copyw2,
    hr_copyw3  histres.hr_copyw3,
    hr_copyw4  histres.hr_copyw4,
    hr_copyw5  histres.hr_copyw5,
    hr_copyw6  histres.hr_copyw6,
    hr_cotime  histres.hr_cotime,
    hr_country histres.hr_country,
    hr_created histres.hr_created,
    hr_creatus histres.hr_creatus,
    hr_cxldate histres.hr_cxldate,
    hr_cxlnr   histres.hr_cxlnr,
    hr_depamt1 histres.hr_depamt1,
    hr_depamt2 histres.hr_depamt2,
    hr_depdat1 histres.hr_depdat1,
    hr_depdat2 histres.hr_depdat2,
    hr_depdate histres.hr_depdate,
    hr_deppaid histres.hr_deppaid,
    hr_deptime histres.hr_deptime,
    hr_discnt  histres.hr_discnt,
    hr_eiid    histres.hr_eiid,
    hr_emailst histres.hr_emailst,
    hr_fname   histres.hr_fname,
    hr_group   histres.hr_group,
    hr_groupid histres.hr_groupid,
    hr_in      histres.hr_in,
    hr_invap   histres.hr_invap,
    hr_invapid histres.hr_invapid,
    hr_invid   histres.hr_invid,
    hr_lfinish histres.hr_lfinish,
    hr_lname   histres.hr_lname,
    hr_lstart  histres.hr_lstart,
    hr_market  histres.hr_market,
    hr_noaddr  histres.hr_noaddr,
    hr_note    histres.hr_note,
    hr_notew1  histres.hr_notew1,
    hr_notew2  histres.hr_notew2,
    hr_notew3  histres.hr_notew3,
    hr_notew4  histres.hr_notew4,
    hr_notew5  histres.hr_notew5,
    hr_notew6  histres.hr_notew6,
    hr_optdate histres.hr_optdate,
    hr_orgarrd histres.hr_orgarrd,
    hr_out     histres.hr_out,
    hr_paymeth histres.hr_paymeth,
    hr_paynum1 histres.hr_paynum1,
    hr_paynum2 histres.hr_paynum2,
    hr_paynum3 histres.hr_paynum3,
    hr_paynum4 histres.hr_paynum4,
    hr_paynum5 histres.hr_paynum5,
    hr_paynum6 histres.hr_paynum6,
    hr_rate    histres.hr_rate,
    hr_ratecod histres.hr_ratecod,
    hr_ratedat histres.hr_ratedat,
    hr_ratein  histres.hr_ratein,
    hr_rateout histres.hr_rateout,
    hr_recur   histres.hr_recur,
    hr_reserid histres.hr_reserid,
    hr_rglayou histres.hr_rglayou,
    hr_roomlst histres.hr_roomlst,
    hr_roomnum histres.hr_roomnum,
    hr_rooms   histres.hr_rooms,
    hr_roomtyp histres.hr_roomtyp,
    hr_rsid    histres.hr_rsid,
    hr_share   histres.hr_share,
    hr_source  histres.hr_source,
    hr_status  histres.hr_status,
    hr_title   histres.hr_title,
    hr_updated histres.hr_updated,
    hr_userid  histres.hr_userid,
    hr_usrres0 histres.hr_usrres0,
    hr_usrres1 histres.hr_usrres1,
    hr_usrres2 histres.hr_usrres2,
    hr_usrres3 histres.hr_usrres3,
    hr_usrres4 histres.hr_usrres4,
    hr_usrres5 histres.hr_usrres5,
    hr_usrres6 histres.hr_usrres6,
    hr_usrres7 histres.hr_usrres7,
    hr_usrres8 histres.hr_usrres8,
    hr_usrres9 histres.hr_usrres9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahiststat AS caBase OF cit_ca.vcx
Alias = [cahiststat]
Tables = [histstat]
KeyFieldList = [aa_addrid,aa_date]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       aa_0amount,
       aa_0amt0,
       aa_0amt1,
       aa_0amt2,
       aa_0amt3,
       aa_0amt4,
       aa_0amt5,
       aa_0amt6,
       aa_0amt7,
       aa_0amt8,
       aa_0amt9,
       aa_0cxl,
       aa_0nights,
       aa_0ns,
       aa_0res,
       aa_0vat0,
       aa_0vat1,
       aa_0vat2,
       aa_0vat3,
       aa_0vat4,
       aa_0vat5,
       aa_0vat6,
       aa_0vat7,
       aa_0vat8,
       aa_0vat9,
       aa_addrid,
       aa_camount,
       aa_camt0,
       aa_camt1,
       aa_camt2,
       aa_camt3,
       aa_camt4,
       aa_camt5,
       aa_camt6,
       aa_camt7,
       aa_camt8,
       aa_camt9,
       aa_ccxl,
       aa_cnights,
       aa_cns,
       aa_cres,
       aa_cvat0,
       aa_cvat1,
       aa_cvat2,
       aa_cvat3,
       aa_cvat4,
       aa_cvat5,
       aa_cvat6,
       aa_cvat7,
       aa_cvat8,
       aa_cvat9,
       aa_date
    FROM histstat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    aa_0amount B(2)    DEFAULT 0,
    aa_0amt0   B(2)    DEFAULT 0,
    aa_0amt1   B(2)    DEFAULT 0,
    aa_0amt2   B(2)    DEFAULT 0,
    aa_0amt3   B(2)    DEFAULT 0,
    aa_0amt4   B(2)    DEFAULT 0,
    aa_0amt5   B(2)    DEFAULT 0,
    aa_0amt6   B(2)    DEFAULT 0,
    aa_0amt7   B(2)    DEFAULT 0,
    aa_0amt8   B(2)    DEFAULT 0,
    aa_0amt9   B(2)    DEFAULT 0,
    aa_0cxl    N(10,0) DEFAULT 0,
    aa_0nights N(10,0) DEFAULT 0,
    aa_0ns     N(10,0) DEFAULT 0,
    aa_0res    N(10,0) DEFAULT 0,
    aa_0vat0   B(6)    DEFAULT 0,
    aa_0vat1   B(6)    DEFAULT 0,
    aa_0vat2   B(6)    DEFAULT 0,
    aa_0vat3   B(6)    DEFAULT 0,
    aa_0vat4   B(6)    DEFAULT 0,
    aa_0vat5   B(6)    DEFAULT 0,
    aa_0vat6   B(6)    DEFAULT 0,
    aa_0vat7   B(6)    DEFAULT 0,
    aa_0vat8   B(6)    DEFAULT 0,
    aa_0vat9   B(6)    DEFAULT 0,
    aa_addrid  N(8,0)  DEFAULT 0,
    aa_camount B(2)    DEFAULT 0,
    aa_camt0   B(2)    DEFAULT 0,
    aa_camt1   B(2)    DEFAULT 0,
    aa_camt2   B(2)    DEFAULT 0,
    aa_camt3   B(2)    DEFAULT 0,
    aa_camt4   B(2)    DEFAULT 0,
    aa_camt5   B(2)    DEFAULT 0,
    aa_camt6   B(2)    DEFAULT 0,
    aa_camt7   B(2)    DEFAULT 0,
    aa_camt8   B(2)    DEFAULT 0,
    aa_camt9   B(2)    DEFAULT 0,
    aa_ccxl    N(10,0) DEFAULT 0,
    aa_cnights N(10,0) DEFAULT 0,
    aa_cns     N(10,0) DEFAULT 0,
    aa_cres    N(10,0) DEFAULT 0,
    aa_cvat0   B(6)    DEFAULT 0,
    aa_cvat1   B(6)    DEFAULT 0,
    aa_cvat2   B(6)    DEFAULT 0,
    aa_cvat3   B(6)    DEFAULT 0,
    aa_cvat4   B(6)    DEFAULT 0,
    aa_cvat5   B(6)    DEFAULT 0,
    aa_cvat6   B(6)    DEFAULT 0,
    aa_cvat7   B(6)    DEFAULT 0,
    aa_cvat8   B(6)    DEFAULT 0,
    aa_cvat9   B(6)    DEFAULT 0,
    aa_date    D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aa_0amount,
    aa_0amt0,
    aa_0amt1,
    aa_0amt2,
    aa_0amt3,
    aa_0amt4,
    aa_0amt5,
    aa_0amt6,
    aa_0amt7,
    aa_0amt8,
    aa_0amt9,
    aa_0cxl,
    aa_0nights,
    aa_0ns,
    aa_0res,
    aa_0vat0,
    aa_0vat1,
    aa_0vat2,
    aa_0vat3,
    aa_0vat4,
    aa_0vat5,
    aa_0vat6,
    aa_0vat7,
    aa_0vat8,
    aa_0vat9,
    aa_addrid,
    aa_camount,
    aa_camt0,
    aa_camt1,
    aa_camt2,
    aa_camt3,
    aa_camt4,
    aa_camt5,
    aa_camt6,
    aa_camt7,
    aa_camt8,
    aa_camt9,
    aa_ccxl,
    aa_cnights,
    aa_cns,
    aa_cres,
    aa_cvat0,
    aa_cvat1,
    aa_cvat2,
    aa_cvat3,
    aa_cvat4,
    aa_cvat5,
    aa_cvat6,
    aa_cvat7,
    aa_cvat8,
    aa_cvat9,
    aa_date
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    aa_0amount histstat.aa_0amount,
    aa_0amt0   histstat.aa_0amt0,
    aa_0amt1   histstat.aa_0amt1,
    aa_0amt2   histstat.aa_0amt2,
    aa_0amt3   histstat.aa_0amt3,
    aa_0amt4   histstat.aa_0amt4,
    aa_0amt5   histstat.aa_0amt5,
    aa_0amt6   histstat.aa_0amt6,
    aa_0amt7   histstat.aa_0amt7,
    aa_0amt8   histstat.aa_0amt8,
    aa_0amt9   histstat.aa_0amt9,
    aa_0cxl    histstat.aa_0cxl,
    aa_0nights histstat.aa_0nights,
    aa_0ns     histstat.aa_0ns,
    aa_0res    histstat.aa_0res,
    aa_0vat0   histstat.aa_0vat0,
    aa_0vat1   histstat.aa_0vat1,
    aa_0vat2   histstat.aa_0vat2,
    aa_0vat3   histstat.aa_0vat3,
    aa_0vat4   histstat.aa_0vat4,
    aa_0vat5   histstat.aa_0vat5,
    aa_0vat6   histstat.aa_0vat6,
    aa_0vat7   histstat.aa_0vat7,
    aa_0vat8   histstat.aa_0vat8,
    aa_0vat9   histstat.aa_0vat9,
    aa_addrid  histstat.aa_addrid,
    aa_camount histstat.aa_camount,
    aa_camt0   histstat.aa_camt0,
    aa_camt1   histstat.aa_camt1,
    aa_camt2   histstat.aa_camt2,
    aa_camt3   histstat.aa_camt3,
    aa_camt4   histstat.aa_camt4,
    aa_camt5   histstat.aa_camt5,
    aa_camt6   histstat.aa_camt6,
    aa_camt7   histstat.aa_camt7,
    aa_camt8   histstat.aa_camt8,
    aa_camt9   histstat.aa_camt9,
    aa_ccxl    histstat.aa_ccxl,
    aa_cnights histstat.aa_cnights,
    aa_cns     histstat.aa_cns,
    aa_cres    histstat.aa_cres,
    aa_cvat0   histstat.aa_cvat0,
    aa_cvat1   histstat.aa_cvat1,
    aa_cvat2   histstat.aa_cvat2,
    aa_cvat3   histstat.aa_cvat3,
    aa_cvat4   histstat.aa_cvat4,
    aa_cvat5   histstat.aa_cvat5,
    aa_cvat6   histstat.aa_cvat6,
    aa_cvat7   histstat.aa_cvat7,
    aa_cvat8   histstat.aa_cvat8,
    aa_cvat9   histstat.aa_cvat9,
    aa_date    histstat.aa_date
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahotel AS caBase OF cit_ca.vcx
Alias = [cahotel]
Tables = [hotel]
KeyFieldList = [ho_hotcode]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ho_descrip,
       ho_hosecid,
       ho_hotcode,
       ho_mainsrv,
       ho_path
    FROM hotel
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ho_descrip C(100)  DEFAULT "",
    ho_hosecid I       DEFAULT 0,
    ho_hotcode C(10)   DEFAULT "",
    ho_mainsrv L       DEFAULT .F.,
    ho_path    C(254)  DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ho_descrip,
    ho_hosecid,
    ho_hotcode,
    ho_mainsrv,
    ho_path
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ho_descrip hotel.ho_descrip,
    ho_hosecid hotel.ho_hosecid,
    ho_hotcode hotel.ho_hotcode,
    ho_mainsrv hotel.ho_mainsrv,
    ho_path    hotel.ho_path
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahoutofor AS caBase OF cit_ca.vcx
Alias = [cahoutofor]
Tables = [houtofor]
KeyFieldList = [oo_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       oo_cancel,
       oo_cxlwh,
       oo_fromdat,
       oo_id,
       oo_reason,
       oo_roomnum,
       oo_status,
       oo_todat,
       rs_message,
       rs_msgshow
    FROM houtofor
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    oo_cancel  L       DEFAULT .F.,
    oo_cxlwh   C(30)   DEFAULT "",
    oo_fromdat D       DEFAULT {},
    oo_id      N(8,0)  DEFAULT 0,
    oo_reason  C(25)   DEFAULT "",
    oo_roomnum C(4)    DEFAULT "",
    oo_status  C(5)    DEFAULT "",
    oo_todat   D       DEFAULT {},
    rs_message M       DEFAULT "",
    rs_msgshow L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oo_cancel,
    oo_cxlwh,
    oo_fromdat,
    oo_id,
    oo_reason,
    oo_roomnum,
    oo_status,
    oo_todat,
    rs_message,
    rs_msgshow
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oo_cancel  houtofor.oo_cancel,
    oo_cxlwh   houtofor.oo_cxlwh,
    oo_fromdat houtofor.oo_fromdat,
    oo_id      houtofor.oo_id,
    oo_reason  houtofor.oo_reason,
    oo_roomnum houtofor.oo_roomnum,
    oo_status  houtofor.oo_status,
    oo_todat   houtofor.oo_todat,
    rs_message houtofor.rs_message,
    rs_msgshow houtofor.rs_msgshow
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahoutofsr AS caBase OF cit_ca.vcx
Alias = [cahoutofsr]
Tables = [houtofsr]
KeyFieldList = [os_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       os_cancel,
       os_changes,
       os_fromdat,
       os_id,
       os_reason,
       os_roomnum,
       os_todat
    FROM houtofsr
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    os_cancel  L       DEFAULT .F.,
    os_changes M       DEFAULT "",
    os_fromdat D       DEFAULT {},
    os_id      N(8,0)  DEFAULT 0,
    os_reason  C(50)   DEFAULT "",
    os_roomnum C(4)    DEFAULT "",
    os_todat   D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    os_cancel,
    os_changes,
    os_fromdat,
    os_id,
    os_reason,
    os_roomnum,
    os_todat
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    os_cancel  houtofsr.os_cancel,
    os_changes houtofsr.os_changes,
    os_fromdat houtofsr.os_fromdat,
    os_id      houtofsr.os_id,
    os_reason  houtofsr.os_reason,
    os_roomnum houtofsr.os_roomnum,
    os_todat   houtofsr.os_todat
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahpostcng AS caBase OF cit_ca.vcx
Alias = [cahpostcng]
Tables = [hpostcng]
KeyFieldList = [ph_postid,ph_time,ph_user,ph_field,ph_action]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ph_action,
       ph_field,
       ph_newval,
       ph_oldval,
       ph_postid,
       ph_time,
       ph_user
    FROM hpostcng
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_action  C(40)   DEFAULT "",
    ph_field   C(20)   DEFAULT "",
    ph_newval  C(30)   DEFAULT "",
    ph_oldval  C(30)   DEFAULT "",
    ph_postid  N(8,0)  DEFAULT 0,
    ph_time    T       DEFAULT {},
    ph_user    C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_action,
    ph_field,
    ph_newval,
    ph_oldval,
    ph_postid,
    ph_time,
    ph_user
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_action  hpostcng.ph_action,
    ph_field   hpostcng.ph_field,
    ph_newval  hpostcng.ph_newval,
    ph_oldval  hpostcng.ph_oldval,
    ph_postid  hpostcng.ph_postid,
    ph_time    hpostcng.ph_time,
    ph_user    hpostcng.ph_user
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahpostifc AS caBase OF cit_ca.vcx
Alias = [cahpostifc]
Tables = [hpostifc]
KeyFieldList = [rk_rkid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rk_deleted,
       rk_dsetid,
       rk_from,
       rk_intcls,
       rk_pttcls,
       rk_ptvcls,
       rk_rkid,
       rk_rsid,
       rk_setid,
       rk_to
    FROM hpostifc
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rk_deleted L       DEFAULT .F.,
    rk_dsetid  I       DEFAULT 0,
    rk_from    D       DEFAULT {},
    rk_intcls  C(10)   DEFAULT "",
    rk_pttcls  C(10)   DEFAULT "",
    rk_ptvcls  C(10)   DEFAULT "",
    rk_rkid    I       DEFAULT 0,
    rk_rsid    I       DEFAULT 0,
    rk_setid   I       DEFAULT 0,
    rk_to      D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rk_deleted,
    rk_dsetid,
    rk_from,
    rk_intcls,
    rk_pttcls,
    rk_ptvcls,
    rk_rkid,
    rk_rsid,
    rk_setid,
    rk_to
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rk_deleted hpostifc.rk_deleted,
    rk_dsetid  hpostifc.rk_dsetid,
    rk_from    hpostifc.rk_from,
    rk_intcls  hpostifc.rk_intcls,
    rk_pttcls  hpostifc.rk_pttcls,
    rk_ptvcls  hpostifc.rk_ptvcls,
    rk_rkid    hpostifc.rk_rkid,
    rk_rsid    hpostifc.rk_rsid,
    rk_setid   hpostifc.rk_setid,
    rk_to      hpostifc.rk_to
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahpwindow AS caBase OF cit_ca.vcx
Alias = [cahpwindow]
Tables = [hpwindow]
KeyFieldList = [pw_pwid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pw_addrid,
       pw_billsty,
       pw_blamid,
       pw_bmsto1w,
       pw_copy,
       pw_note,
       pw_pwid,
       pw_rsid,
       pw_udbdate,
       pw_window,
       pw_winpos
    FROM hpwindow
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pw_addrid  N(8,0)  DEFAULT 0,
    pw_billsty C(1)    DEFAULT "",
    pw_blamid  N(8,0)  DEFAULT 0,
    pw_bmsto1w L       DEFAULT .F.,
    pw_copy    N(2,0)  DEFAULT 0,
    pw_note    M       DEFAULT "",
    pw_pwid    I       DEFAULT 0,
    pw_rsid    I       DEFAULT 0,
    pw_udbdate L       DEFAULT .F.,
    pw_window  I       DEFAULT 0,
    pw_winpos  N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pw_addrid,
    pw_billsty,
    pw_blamid,
    pw_bmsto1w,
    pw_copy,
    pw_note,
    pw_pwid,
    pw_rsid,
    pw_udbdate,
    pw_window,
    pw_winpos
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pw_addrid  hpwindow.pw_addrid,
    pw_billsty hpwindow.pw_billsty,
    pw_blamid  hpwindow.pw_blamid,
    pw_bmsto1w hpwindow.pw_bmsto1w,
    pw_copy    hpwindow.pw_copy,
    pw_note    hpwindow.pw_note,
    pw_pwid    hpwindow.pw_pwid,
    pw_rsid    hpwindow.pw_rsid,
    pw_udbdate hpwindow.pw_udbdate,
    pw_window  hpwindow.pw_window,
    pw_winpos  hpwindow.pw_winpos
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresaddr AS caBase OF cit_ca.vcx
Alias = [cahresaddr]
Tables = [hresaddr]
KeyFieldList = [rg_rgid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rg_country,
       rg_fname,
       rg_fromday,
       rg_lname,
       rg_reserid,
       rg_rgid,
       rg_title,
       rg_today
    FROM hresaddr
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rg_country C(3)    DEFAULT "",
    rg_fname   C(20)   DEFAULT "",
    rg_fromday N(3,0)  DEFAULT 0,
    rg_lname   C(30)   DEFAULT "",
    rg_reserid N(12,3) DEFAULT 0,
    rg_rgid    I       DEFAULT 0,
    rg_title   C(20)   DEFAULT "",
    rg_today   N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rg_country,
    rg_fname,
    rg_fromday,
    rg_lname,
    rg_reserid,
    rg_rgid,
    rg_title,
    rg_today
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rg_country hresaddr.rg_country,
    rg_fname   hresaddr.rg_fname,
    rg_fromday hresaddr.rg_fromday,
    rg_lname   hresaddr.rg_lname,
    rg_reserid hresaddr.rg_reserid,
    rg_rgid    hresaddr.rg_rgid,
    rg_title   hresaddr.rg_title,
    rg_today   hresaddr.rg_today
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahrescard AS caBase OF cit_ca.vcx
Alias = [cahrescard]
Tables = [hrescard]
KeyFieldList = [cr_crid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       cr_cardid,
       cr_crid,
       cr_messcnt,
       cr_name,
       cr_rsid
    FROM hrescard
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_cardid  C(12)   DEFAULT "",
    cr_crid    I       DEFAULT 0,
    cr_messcnt C(16)   DEFAULT "",
    cr_name    C(100)  DEFAULT "",
    cr_rsid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_cardid,
    cr_crid,
    cr_messcnt,
    cr_name,
    cr_rsid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_cardid  hrescard.cr_cardid,
    cr_crid    hrescard.cr_crid,
    cr_messcnt hrescard.cr_messcnt,
    cr_name    hrescard.cr_name,
    cr_rsid    hrescard.cr_rsid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresext AS caBase OF cit_ca.vcx
Alias = [cahresext]
Tables = [hresext]
KeyFieldList = [rs_rsid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rs_bqkz,
       rs_cclimit,
       rs_ccref,
       rs_cowibal,
       rs_custom1,
       rs_cxlstat,
       rs_deppdat,
       rs_feat1,
       rs_feat2,
       rs_feat3,
       rs_interns,
       rs_intrsid,
       rs_keycard,
       rs_message,
       rs_msgshow,
       rs_mshwcco,
       rs_noaddr,
       rs_noteco,
       rs_odepdat,
       rs_posstat,
       rs_pttclas,
       rs_ptvflag,
       rs_ratexch,
       rs_reserid,
       rs_rfixdat,
       rs_rgid,
       rs_rminfo1,
       rs_rminfo2,
       rs_rsid,
       rs_saddrid,
       rs_sname,
       rs_statoff,
       rs_xchkout,
       rs_yoid
    FROM hresext
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rs_bqkz    C(4)    DEFAULT "",
    rs_cclimit B(2)    DEFAULT 0,
    rs_ccref   N(8,0)  DEFAULT 0,
    rs_cowibal L       DEFAULT .F.,
    rs_custom1 M       DEFAULT "",
    rs_cxlstat C(3)    DEFAULT "",
    rs_deppdat D       DEFAULT {},
    rs_feat1   C(3)    DEFAULT "",
    rs_feat2   C(3)    DEFAULT "",
    rs_feat3   C(3)    DEFAULT "",
    rs_interns C(20)   DEFAULT "",
    rs_intrsid C(12)   DEFAULT "",
    rs_keycard C(20)   DEFAULT "",
    rs_message M       DEFAULT "",
    rs_msgshow L       DEFAULT .F.,
    rs_mshwcco C(2)    DEFAULT "",
    rs_noaddr  L       DEFAULT .F.,
    rs_noteco  M       DEFAULT "",
    rs_odepdat D       DEFAULT {},
    rs_posstat C(1)    DEFAULT "",
    rs_pttclas N(2,0)  DEFAULT 0,
    rs_ptvflag C(10)   DEFAULT "",
    rs_ratexch B(6)    DEFAULT 0,
    rs_reserid N(12,3) DEFAULT 0,
    rs_rfixdat D       DEFAULT {},
    rs_rgid    I       DEFAULT 0,
    rs_rminfo1 M       DEFAULT "",
    rs_rminfo2 M       DEFAULT "",
    rs_rsid    I       DEFAULT 0,
    rs_saddrid N(8,0)  DEFAULT 0,
    rs_sname   C(30)   DEFAULT "",
    rs_statoff L       DEFAULT .F.,
    rs_xchkout L       DEFAULT .F.,
    rs_yoid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rs_bqkz,
    rs_cclimit,
    rs_ccref,
    rs_cowibal,
    rs_custom1,
    rs_cxlstat,
    rs_deppdat,
    rs_feat1,
    rs_feat2,
    rs_feat3,
    rs_interns,
    rs_intrsid,
    rs_keycard,
    rs_message,
    rs_msgshow,
    rs_mshwcco,
    rs_noaddr,
    rs_noteco,
    rs_odepdat,
    rs_posstat,
    rs_pttclas,
    rs_ptvflag,
    rs_ratexch,
    rs_reserid,
    rs_rfixdat,
    rs_rgid,
    rs_rminfo1,
    rs_rminfo2,
    rs_rsid,
    rs_saddrid,
    rs_sname,
    rs_statoff,
    rs_xchkout,
    rs_yoid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rs_bqkz    hresext.rs_bqkz,
    rs_cclimit hresext.rs_cclimit,
    rs_ccref   hresext.rs_ccref,
    rs_cowibal hresext.rs_cowibal,
    rs_custom1 hresext.rs_custom1,
    rs_cxlstat hresext.rs_cxlstat,
    rs_deppdat hresext.rs_deppdat,
    rs_feat1   hresext.rs_feat1,
    rs_feat2   hresext.rs_feat2,
    rs_feat3   hresext.rs_feat3,
    rs_interns hresext.rs_interns,
    rs_intrsid hresext.rs_intrsid,
    rs_keycard hresext.rs_keycard,
    rs_message hresext.rs_message,
    rs_msgshow hresext.rs_msgshow,
    rs_mshwcco hresext.rs_mshwcco,
    rs_noaddr  hresext.rs_noaddr,
    rs_noteco  hresext.rs_noteco,
    rs_odepdat hresext.rs_odepdat,
    rs_posstat hresext.rs_posstat,
    rs_pttclas hresext.rs_pttclas,
    rs_ptvflag hresext.rs_ptvflag,
    rs_ratexch hresext.rs_ratexch,
    rs_reserid hresext.rs_reserid,
    rs_rfixdat hresext.rs_rfixdat,
    rs_rgid    hresext.rs_rgid,
    rs_rminfo1 hresext.rs_rminfo1,
    rs_rminfo2 hresext.rs_rminfo2,
    rs_rsid    hresext.rs_rsid,
    rs_saddrid hresext.rs_saddrid,
    rs_sname   hresext.rs_sname,
    rs_statoff hresext.rs_statoff,
    rs_xchkout hresext.rs_xchkout,
    rs_yoid    hresext.rs_yoid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresfeat AS caBase OF cit_ca.vcx
Alias = [cahresfeat]
Tables = [hresfeat]
KeyFieldList = [fr_frid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       fr_feature,
       fr_frid,
       fr_rsid
    FROM hresfeat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    fr_feature C(3)    DEFAULT "",
    fr_frid    I       DEFAULT 0,
    fr_rsid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fr_feature,
    fr_frid,
    fr_rsid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fr_feature hresfeat.fr_feature,
    fr_frid    hresfeat.fr_frid,
    fr_rsid    hresfeat.fr_rsid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresfix AS caBase OF cit_ca.vcx
Alias = [cahresfix]
Tables = [hresfix]
KeyFieldList = [rf_rfid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rf_adults,
       rf_alldays,
       rf_artinum,
       rf_childs,
       rf_childs2,
       rf_childs3,
       rf_day,
       rf_forcurr,
       rf_package,
       rf_price,
       rf_ratecod,
       rf_reserid,
       rf_rfid,
       rf_showhk,
       rf_units
    FROM hresfix
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_adults  N(3,0)  DEFAULT 0,
    rf_alldays L       DEFAULT .F.,
    rf_artinum N(4,0)  DEFAULT 0,
    rf_childs  N(3,0)  DEFAULT 0,
    rf_childs2 N(3,0)  DEFAULT 0,
    rf_childs3 N(3,0)  DEFAULT 0,
    rf_day     N(3,0)  DEFAULT 0,
    rf_forcurr L       DEFAULT .F.,
    rf_package L       DEFAULT .F.,
    rf_price   B(8)    DEFAULT 0,
    rf_ratecod C(10)   DEFAULT "",
    rf_reserid N(12,3) DEFAULT 0,
    rf_rfid    I       DEFAULT 0,
    rf_showhk  L       DEFAULT .F.,
    rf_units   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_adults,
    rf_alldays,
    rf_artinum,
    rf_childs,
    rf_childs2,
    rf_childs3,
    rf_day,
    rf_forcurr,
    rf_package,
    rf_price,
    rf_ratecod,
    rf_reserid,
    rf_rfid,
    rf_showhk,
    rf_units
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_adults  hresfix.rf_adults,
    rf_alldays hresfix.rf_alldays,
    rf_artinum hresfix.rf_artinum,
    rf_childs  hresfix.rf_childs,
    rf_childs2 hresfix.rf_childs2,
    rf_childs3 hresfix.rf_childs3,
    rf_day     hresfix.rf_day,
    rf_forcurr hresfix.rf_forcurr,
    rf_package hresfix.rf_package,
    rf_price   hresfix.rf_price,
    rf_ratecod hresfix.rf_ratecod,
    rf_reserid hresfix.rf_reserid,
    rf_rfid    hresfix.rf_rfid,
    rf_showhk  hresfix.rf_showhk,
    rf_units   hresfix.rf_units
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresplit AS caBase OF cit_ca.vcx
Alias = [cahresplit]
Tables = [hresplit]
KeyFieldList = [rl_rlid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rl_artinum,
       rl_artityp,
       rl_date,
       rl_price,
       rl_ratecod,
       rl_rdate,
       rl_rlid,
       rl_rsid,
       rl_units
    FROM hresplit
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rl_artinum N(4,0)  DEFAULT 0,
    rl_artityp N(1,0)  DEFAULT 0,
    rl_date    D       DEFAULT {},
    rl_price   B(6)    DEFAULT 0,
    rl_ratecod C(23)   DEFAULT "",
    rl_rdate   D       DEFAULT {},
    rl_rlid    I       DEFAULT 0,
    rl_rsid    I       DEFAULT 0,
    rl_units   B(2)    DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rl_artinum,
    rl_artityp,
    rl_date,
    rl_price,
    rl_ratecod,
    rl_rdate,
    rl_rlid,
    rl_rsid,
    rl_units
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rl_artinum hresplit.rl_artinum,
    rl_artityp hresplit.rl_artityp,
    rl_date    hresplit.rl_date,
    rl_price   hresplit.rl_price,
    rl_ratecod hresplit.rl_ratecod,
    rl_rdate   hresplit.rl_rdate,
    rl_rlid    hresplit.rl_rlid,
    rl_rsid    hresplit.rl_rsid,
    rl_units   hresplit.rl_units
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresrart AS caBase OF cit_ca.vcx
Alias = [cahresrart]
Tables = [hresrart]
KeyFieldList = [ra_raid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ra_amnt,
       ra_artinum,
       ra_artityp,
       ra_atblres,
       ra_exinfo,
       ra_multipl,
       ra_note,
       ra_notef,
       ra_notep,
       ra_onlyon,
       ra_package,
       ra_pctexma,
       ra_pmlocal,
       ra_raid,
       ra_ratecod,
       ra_ratepct,
       ra_rcsetid,
       ra_rsid,
       ra_sagroup,
       ra_user1,
       ra_user2,
       ra_user3,
       ra_user4,
       ra_wservid
    FROM hresrart
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt    B(2)    DEFAULT 0,
    ra_artinum N(4,0)  DEFAULT 0,
    ra_artityp N(1,0)  DEFAULT 0,
    ra_atblres L       DEFAULT .F.,
    ra_exinfo  C(20)   DEFAULT "",
    ra_multipl N(1,0)  DEFAULT 0,
    ra_note    M       DEFAULT "",
    ra_notef   M       DEFAULT "",
    ra_notep   M       DEFAULT "",
    ra_onlyon  N(3,0)  DEFAULT 0,
    ra_package L       DEFAULT .F.,
    ra_pctexma L       DEFAULT .F.,
    ra_pmlocal L       DEFAULT .F.,
    ra_raid    N(10,0) DEFAULT 0,
    ra_ratecod C(23)   DEFAULT "",
    ra_ratepct N(7,2)  DEFAULT 0,
    ra_rcsetid N(8,0)  DEFAULT 0,
    ra_rsid    I       DEFAULT 0,
    ra_sagroup L       DEFAULT .F.,
    ra_user1   C(50)   DEFAULT "",
    ra_user2   C(50)   DEFAULT "",
    ra_user3   C(50)   DEFAULT "",
    ra_user4   C(50)   DEFAULT "",
    ra_wservid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt,
    ra_artinum,
    ra_artityp,
    ra_atblres,
    ra_exinfo,
    ra_multipl,
    ra_note,
    ra_notef,
    ra_notep,
    ra_onlyon,
    ra_package,
    ra_pctexma,
    ra_pmlocal,
    ra_raid,
    ra_ratecod,
    ra_ratepct,
    ra_rcsetid,
    ra_rsid,
    ra_sagroup,
    ra_user1,
    ra_user2,
    ra_user3,
    ra_user4,
    ra_wservid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt    hresrart.ra_amnt,
    ra_artinum hresrart.ra_artinum,
    ra_artityp hresrart.ra_artityp,
    ra_atblres hresrart.ra_atblres,
    ra_exinfo  hresrart.ra_exinfo,
    ra_multipl hresrart.ra_multipl,
    ra_note    hresrart.ra_note,
    ra_notef   hresrart.ra_notef,
    ra_notep   hresrart.ra_notep,
    ra_onlyon  hresrart.ra_onlyon,
    ra_package hresrart.ra_package,
    ra_pctexma hresrart.ra_pctexma,
    ra_pmlocal hresrart.ra_pmlocal,
    ra_raid    hresrart.ra_raid,
    ra_ratecod hresrart.ra_ratecod,
    ra_ratepct hresrart.ra_ratepct,
    ra_rcsetid hresrart.ra_rcsetid,
    ra_rsid    hresrart.ra_rsid,
    ra_sagroup hresrart.ra_sagroup,
    ra_user1   hresrart.ra_user1,
    ra_user2   hresrart.ra_user2,
    ra_user3   hresrart.ra_user3,
    ra_user4   hresrart.ra_user4,
    ra_wservid hresrart.ra_wservid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresrate AS caBase OF cit_ca.vcx
Alias = [cahresrate]
Tables = [hresrate]
KeyFieldList = [rr_rrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rr_adults,
       rr_arrtime,
       rr_childs,
       rr_childs2,
       rr_childs3,
       rr_curcoef,
       rr_date,
       rr_deptime,
       rr_package,
       rr_ratcoef,
       rr_ratecod,
       rr_rateex,
       rr_ratefrc,
       rr_ratepg,
       rr_raterc,
       rr_raterd,
       rr_raterf,
       rr_reserid,
       rr_rrid,
       rr_status
    FROM hresrate
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_adults  N(3,0)  DEFAULT 0,
    rr_arrtime C(5)    DEFAULT "",
    rr_childs  N(3,0)  DEFAULT 0,
    rr_childs2 N(1,0)  DEFAULT 0,
    rr_childs3 N(1,0)  DEFAULT 0,
    rr_curcoef B(8)    DEFAULT 0,
    rr_date    D       DEFAULT {},
    rr_deptime C(5)    DEFAULT "",
    rr_package B(8)    DEFAULT 0,
    rr_ratcoef B(8)    DEFAULT 0,
    rr_ratecod C(23)   DEFAULT "",
    rr_rateex  B(8)    DEFAULT 0,
    rr_ratefrc B(8)    DEFAULT 0,
    rr_ratepg  B(8)    DEFAULT 0,
    rr_raterc  B(8)    DEFAULT 0,
    rr_raterd  B(8)    DEFAULT 0,
    rr_raterf  B(8)    DEFAULT 0,
    rr_reserid N(12,3) DEFAULT 0,
    rr_rrid    N(8,0)  DEFAULT 0,
    rr_status  C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_adults,
    rr_arrtime,
    rr_childs,
    rr_childs2,
    rr_childs3,
    rr_curcoef,
    rr_date,
    rr_deptime,
    rr_package,
    rr_ratcoef,
    rr_ratecod,
    rr_rateex,
    rr_ratefrc,
    rr_ratepg,
    rr_raterc,
    rr_raterd,
    rr_raterf,
    rr_reserid,
    rr_rrid,
    rr_status
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_adults  hresrate.rr_adults,
    rr_arrtime hresrate.rr_arrtime,
    rr_childs  hresrate.rr_childs,
    rr_childs2 hresrate.rr_childs2,
    rr_childs3 hresrate.rr_childs3,
    rr_curcoef hresrate.rr_curcoef,
    rr_date    hresrate.rr_date,
    rr_deptime hresrate.rr_deptime,
    rr_package hresrate.rr_package,
    rr_ratcoef hresrate.rr_ratcoef,
    rr_ratecod hresrate.rr_ratecod,
    rr_rateex  hresrate.rr_rateex,
    rr_ratefrc hresrate.rr_ratefrc,
    rr_ratepg  hresrate.rr_ratepg,
    rr_raterc  hresrate.rr_raterc,
    rr_raterd  hresrate.rr_raterd,
    rr_raterf  hresrate.rr_raterf,
    rr_reserid hresrate.rr_reserid,
    rr_rrid    hresrate.rr_rrid,
    rr_status  hresrate.rr_status
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresroom AS caBase OF cit_ca.vcx
Alias = [cahresroom]
Tables = [hresroom]
KeyFieldList = [ri_rroomid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ri_date,
       ri_reserid,
       ri_roomnum,
       ri_roomtyp,
       ri_rroomid,
       ri_shareid,
       ri_todate
    FROM hresroom
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ri_date    D       DEFAULT {},
    ri_reserid N(12,3) DEFAULT 0,
    ri_roomnum C(4)    DEFAULT "",
    ri_roomtyp C(4)    DEFAULT "",
    ri_rroomid N(8,0)  DEFAULT 0,
    ri_shareid N(8,0)  DEFAULT 0,
    ri_todate  D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ri_date,
    ri_reserid,
    ri_roomnum,
    ri_roomtyp,
    ri_rroomid,
    ri_shareid,
    ri_todate
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ri_date    hresroom.ri_date,
    ri_reserid hresroom.ri_reserid,
    ri_roomnum hresroom.ri_roomnum,
    ri_roomtyp hresroom.ri_roomtyp,
    ri_rroomid hresroom.ri_rroomid,
    ri_shareid hresroom.ri_shareid,
    ri_todate  hresroom.ri_todate
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahresyild AS caBase OF cit_ca.vcx
Alias = [cahresyild]
Tables = [hresyild]
KeyFieldList = [ry_ryid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ry_date,
       ry_occup,
       ry_rate,
       ry_ratecod,
       ry_ryid,
       ry_ycid,
       ry_yoid
    FROM hresyild
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ry_date    D       DEFAULT {},
    ry_occup   N(3,0)  DEFAULT 0,
    ry_rate    B(8)    DEFAULT 0,
    ry_ratecod C(23)   DEFAULT "",
    ry_ryid    I       DEFAULT 0,
    ry_ycid    I       DEFAULT 0,
    ry_yoid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ry_date,
    ry_occup,
    ry_rate,
    ry_ratecod,
    ry_ryid,
    ry_ycid,
    ry_yoid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ry_date    hresyild.ry_date,
    ry_occup   hresyild.ry_occup,
    ry_rate    hresyild.ry_rate,
    ry_ratecod hresyild.ry_ratecod,
    ry_ryid    hresyild.ry_ryid,
    ry_ycid    hresyild.ry_ycid,
    ry_yoid    hresyild.ry_yoid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahyicond AS caBase OF cit_ca.vcx
Alias = [cahyicond]
Tables = [hyicond]
KeyFieldList = [yc_ycid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       yc_avail,
       yc_avltype,
       yc_days,
       yc_daytype,
       yc_prcpct,
       yc_prcset,
       yc_prcunit,
       yc_round,
       yc_ycid,
       yc_yoid,
       yc_yrid
    FROM hyicond
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    yc_avail   N(5,1)  DEFAULT 0,
    yc_avltype N(1,0)  DEFAULT 0,
    yc_days    N(3,0)  DEFAULT 0,
    yc_daytype N(1,0)  DEFAULT 0,
    yc_prcpct  N(6,2)  DEFAULT 0,
    yc_prcset  N(1,0)  DEFAULT 0,
    yc_prcunit N(1,0)  DEFAULT 0,
    yc_round   N(1,0)  DEFAULT 0,
    yc_ycid    I       DEFAULT 0,
    yc_yoid    I       DEFAULT 0,
    yc_yrid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yc_avail,
    yc_avltype,
    yc_days,
    yc_daytype,
    yc_prcpct,
    yc_prcset,
    yc_prcunit,
    yc_round,
    yc_ycid,
    yc_yoid,
    yc_yrid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yc_avail   hyicond.yc_avail,
    yc_avltype hyicond.yc_avltype,
    yc_days    hyicond.yc_days,
    yc_daytype hyicond.yc_daytype,
    yc_prcpct  hyicond.yc_prcpct,
    yc_prcset  hyicond.yc_prcset,
    yc_prcunit hyicond.yc_prcunit,
    yc_round   hyicond.yc_round,
    yc_ycid    hyicond.yc_ycid,
    yc_yoid    hyicond.yc_yoid,
    yc_yrid    hyicond.yc_yrid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahyioffer AS caBase OF cit_ca.vcx
Alias = [cahyioffer]
Tables = [hyioffer]
KeyFieldList = [yo_yoid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       yo_adults,
       yo_childs,
       yo_childs2,
       yo_childs3,
       yo_created,
       yo_from,
       yo_rooms,
       yo_roomtyp,
       yo_rsid,
       yo_sysdate,
       yo_to,
       yo_userid,
       yo_yoid
    FROM hyioffer
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    yo_adults  N(3,0)  DEFAULT 0,
    yo_childs  N(3,0)  DEFAULT 0,
    yo_childs2 N(1,0)  DEFAULT 0,
    yo_childs3 N(1,0)  DEFAULT 0,
    yo_created T       DEFAULT {},
    yo_from    D       DEFAULT {},
    yo_rooms   N(3,0)  DEFAULT 0,
    yo_roomtyp C(4)    DEFAULT "",
    yo_rsid    I       DEFAULT 0,
    yo_sysdate D       DEFAULT {},
    yo_to      D       DEFAULT {},
    yo_userid  C(10)   DEFAULT "",
    yo_yoid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yo_adults,
    yo_childs,
    yo_childs2,
    yo_childs3,
    yo_created,
    yo_from,
    yo_rooms,
    yo_roomtyp,
    yo_rsid,
    yo_sysdate,
    yo_to,
    yo_userid,
    yo_yoid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yo_adults  hyioffer.yo_adults,
    yo_childs  hyioffer.yo_childs,
    yo_childs2 hyioffer.yo_childs2,
    yo_childs3 hyioffer.yo_childs3,
    yo_created hyioffer.yo_created,
    yo_from    hyioffer.yo_from,
    yo_rooms   hyioffer.yo_rooms,
    yo_roomtyp hyioffer.yo_roomtyp,
    yo_rsid    hyioffer.yo_rsid,
    yo_sysdate hyioffer.yo_sysdate,
    yo_to      hyioffer.yo_to,
    yo_userid  hyioffer.yo_userid,
    yo_yoid    hyioffer.yo_yoid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caid AS caBase OF cit_ca.vcx
Alias = [caid]
Tables = [id]
KeyFieldList = [id_code]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       id_clast,
       id_code,
       id_last
    FROM id
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_clast   C(10)   DEFAULT "",
    id_code    C(8)    DEFAULT "",
    id_last    N(10,0) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_clast,
    id_code,
    id_last
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_clast   id.id_clast,
    id_code    id.id_code,
    id_last    id.id_last
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caidmain AS caBase OF cit_ca.vcx
Alias = [caidmain]
Tables = [idmain]
KeyFieldList = [id_code]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       id_clast,
       id_code,
       id_last
    FROM idmain
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_clast   C(10)   DEFAULT "",
    id_code    C(8)    DEFAULT "",
    id_last    N(10,0) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_clast,
    id_code,
    id_last
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_clast   idmain.id_clast,
    id_code    idmain.id_code,
    id_last    idmain.id_last
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caifcptt AS caBase OF cit_ca.vcx
Alias = [caifcptt]
Tables = [ifcptt]
KeyFieldList = [it_artinum,it_phone]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       it_artinum,
       it_phone,
       it_price
    FROM ifcptt
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    it_artinum N(4,0)  DEFAULT 0,
    it_phone   C(4)    DEFAULT "",
    it_price   N(6,2)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    it_artinum,
    it_phone,
    it_price
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    it_artinum ifcptt.it_artinum,
    it_phone   ifcptt.it_phone,
    it_price   ifcptt.it_price
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cajetweb AS caBase OF cit_ca.vcx
Alias = [cajetweb]
Tables = [jetweb]
KeyFieldList = [jw_jwid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       jw_addrid,
       jw_arrdate,
       jw_depdate,
       jw_done,
       jw_guid,
       jw_jwid,
       jw_lname,
       jw_mbnr,
       jw_mid,
       jw_note,
       jw_printed,
       jw_reserid,
       jw_status
    FROM jetweb
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    jw_addrid  N(8,0)  DEFAULT 0,
    jw_arrdate D       DEFAULT {},
    jw_depdate D       DEFAULT {},
    jw_done    L       DEFAULT .F.,
    jw_guid    C(36)   DEFAULT "",
    jw_jwid    N(8,0)  DEFAULT 0,
    jw_lname   C(30)   DEFAULT "",
    jw_mbnr    I       DEFAULT 0,
    jw_mid     I       DEFAULT 0,
    jw_note    M       DEFAULT "",
    jw_printed L       DEFAULT .F.,
    jw_reserid N(12,3) DEFAULT 0,
    jw_status  I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    jw_addrid,
    jw_arrdate,
    jw_depdate,
    jw_done,
    jw_guid,
    jw_jwid,
    jw_lname,
    jw_mbnr,
    jw_mid,
    jw_note,
    jw_printed,
    jw_reserid,
    jw_status
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    jw_addrid  jetweb.jw_addrid,
    jw_arrdate jetweb.jw_arrdate,
    jw_depdate jetweb.jw_depdate,
    jw_done    jetweb.jw_done,
    jw_guid    jetweb.jw_guid,
    jw_jwid    jetweb.jw_jwid,
    jw_lname   jetweb.jw_lname,
    jw_mbnr    jetweb.jw_mbnr,
    jw_mid     jetweb.jw_mid,
    jw_note    jetweb.jw_note,
    jw_printed jetweb.jw_printed,
    jw_reserid jetweb.jw_reserid,
    jw_status  jetweb.jw_status
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cajob AS caBase OF cit_ca.vcx
Alias = [cajob]
Tables = [job]
KeyFieldList = [jb_jbnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       jb_deleted,
       jb_jbnr,
       jb_lang1,
       jb_lang10,
       jb_lang11,
       jb_lang2,
       jb_lang3,
       jb_lang4,
       jb_lang5,
       jb_lang6,
       jb_lang7,
       jb_lang8,
       jb_lang9
    FROM job
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    jb_deleted L       DEFAULT .F.,
    jb_jbnr    N(2,0)  DEFAULT 0,
    jb_lang1   C(20)   DEFAULT "",
    jb_lang10  C(20)   DEFAULT "",
    jb_lang11  C(20)   DEFAULT "",
    jb_lang2   C(20)   DEFAULT "",
    jb_lang3   C(20)   DEFAULT "",
    jb_lang4   C(20)   DEFAULT "",
    jb_lang5   C(20)   DEFAULT "",
    jb_lang6   C(20)   DEFAULT "",
    jb_lang7   C(20)   DEFAULT "",
    jb_lang8   C(20)   DEFAULT "",
    jb_lang9   C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    jb_deleted,
    jb_jbnr,
    jb_lang1,
    jb_lang10,
    jb_lang11,
    jb_lang2,
    jb_lang3,
    jb_lang4,
    jb_lang5,
    jb_lang6,
    jb_lang7,
    jb_lang8,
    jb_lang9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    jb_deleted job.jb_deleted,
    jb_jbnr    job.jb_jbnr,
    jb_lang1   job.jb_lang1,
    jb_lang10  job.jb_lang10,
    jb_lang11  job.jb_lang11,
    jb_lang2   job.jb_lang2,
    jb_lang3   job.jb_lang3,
    jb_lang4   job.jb_lang4,
    jb_lang5   job.jb_lang5,
    jb_lang6   job.jb_lang6,
    jb_lang7   job.jb_lang7,
    jb_lang8   job.jb_lang8,
    jb_lang9   job.jb_lang9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS calanguage AS caBase OF cit_ca.vcx
Alias = [calanguage]
Tables = [language]
KeyFieldList = [la_label,la_prg,la_lang]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       la_label,
       la_lang,
       la_prg,
       la_status,
       la_text
    FROM language
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    la_label   C(30)   DEFAULT "",
    la_lang    C(3)    DEFAULT "",
    la_prg     C(8)    DEFAULT "",
    la_status  C(2)    DEFAULT "",
    la_text    C(150)  DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    la_label,
    la_lang,
    la_prg,
    la_status,
    la_text
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    la_label   language.la_label,
    la_lang    language.la_lang,
    la_prg     language.la_prg,
    la_status  language.la_status,
    la_text    language.la_text
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS calaststay AS caBase OF cit_ca.vcx
Alias = [calaststay]
Tables = [laststay]
KeyFieldList = [ls_addrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ls_addrid,
       ls_arrdat,
       ls_depdate,
       ls_market,
       ls_rate,
       ls_ratecod,
       ls_roomnum,
       ls_roomtyp,
       ls_source
    FROM laststay
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ls_addrid  N(8,0)  DEFAULT 0,
    ls_arrdat  D       DEFAULT {},
    ls_depdate D       DEFAULT {},
    ls_market  C(3)    DEFAULT "",
    ls_rate    B(2)    DEFAULT 0,
    ls_ratecod C(10)   DEFAULT "",
    ls_roomnum C(4)    DEFAULT "",
    ls_roomtyp C(4)    DEFAULT "",
    ls_source  C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ls_addrid,
    ls_arrdat,
    ls_depdate,
    ls_market,
    ls_rate,
    ls_ratecod,
    ls_roomnum,
    ls_roomtyp,
    ls_source
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ls_addrid  laststay.ls_addrid,
    ls_arrdat  laststay.ls_arrdat,
    ls_depdate laststay.ls_depdate,
    ls_market  laststay.ls_market,
    ls_rate    laststay.ls_rate,
    ls_ratecod laststay.ls_ratecod,
    ls_roomnum laststay.ls_roomnum,
    ls_roomtyp laststay.ls_roomtyp,
    ls_source  laststay.ls_source
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caledgpaym AS caBase OF cit_ca.vcx
Alias = [caledgpaym]
Tables = [ledgpaym]
KeyFieldList = [lp_lpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       lp_billnum,
       lp_descrip,
       lp_ldid,
       lp_lpid,
       lp_paymamt,
       lp_paymdat,
       lp_paynum,
       lp_postid,
       lp_reserid
    FROM ledgpaym
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    lp_billnum C(10)   DEFAULT "",
    lp_descrip C(25)   DEFAULT "",
    lp_ldid    I       DEFAULT 0,
    lp_lpid    I       DEFAULT 0,
    lp_paymamt B(2)    DEFAULT 0,
    lp_paymdat D       DEFAULT {},
    lp_paynum  N(3,0)  DEFAULT 0,
    lp_postid  N(8,0)  DEFAULT 0,
    lp_reserid N(12,3) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lp_billnum,
    lp_descrip,
    lp_ldid,
    lp_lpid,
    lp_paymamt,
    lp_paymdat,
    lp_paynum,
    lp_postid,
    lp_reserid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lp_billnum ledgpaym.lp_billnum,
    lp_descrip ledgpaym.lp_descrip,
    lp_ldid    ledgpaym.lp_ldid,
    lp_lpid    ledgpaym.lp_lpid,
    lp_paymamt ledgpaym.lp_paymamt,
    lp_paymdat ledgpaym.lp_paymdat,
    lp_paynum  ledgpaym.lp_paynum,
    lp_postid  ledgpaym.lp_postid,
    lp_reserid ledgpaym.lp_reserid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caledgpost AS caBase OF cit_ca.vcx
Alias = [caledgpost]
Tables = [ledgpost]
KeyFieldList = [ld_ldid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ld_addrid,
       ld_billamt,
       ld_billdat,
       ld_billnum,
       ld_company,
       ld_ldid,
       ld_lname,
       ld_origid,
       ld_paidamt,
       ld_paiddat,
       ld_paynum,
       ld_postid,
       ld_qrcode,
       ld_reserid,
       ld_vblock
    FROM ledgpost
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ld_addrid  N(8,0)  DEFAULT 0,
    ld_billamt B(2)    DEFAULT 0,
    ld_billdat D       DEFAULT {},
    ld_billnum C(10)   DEFAULT "",
    ld_company C(25)   DEFAULT "",
    ld_ldid    I       DEFAULT 0,
    ld_lname   C(25)   DEFAULT "",
    ld_origid  N(12,3) DEFAULT 0,
    ld_paidamt B(2)    DEFAULT 0,
    ld_paiddat D       DEFAULT {},
    ld_paynum  N(3,0)  DEFAULT 0,
    ld_postid  N(8,0)  DEFAULT 0,
    ld_qrcode  C(254)  DEFAULT "",
    ld_reserid N(12,3) DEFAULT 0,
    ld_vblock  L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ld_addrid,
    ld_billamt,
    ld_billdat,
    ld_billnum,
    ld_company,
    ld_ldid,
    ld_lname,
    ld_origid,
    ld_paidamt,
    ld_paiddat,
    ld_paynum,
    ld_postid,
    ld_qrcode,
    ld_reserid,
    ld_vblock
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ld_addrid  ledgpost.ld_addrid,
    ld_billamt ledgpost.ld_billamt,
    ld_billdat ledgpost.ld_billdat,
    ld_billnum ledgpost.ld_billnum,
    ld_company ledgpost.ld_company,
    ld_ldid    ledgpost.ld_ldid,
    ld_lname   ledgpost.ld_lname,
    ld_origid  ledgpost.ld_origid,
    ld_paidamt ledgpost.ld_paidamt,
    ld_paiddat ledgpost.ld_paiddat,
    ld_paynum  ledgpost.ld_paynum,
    ld_postid  ledgpost.ld_postid,
    ld_qrcode  ledgpost.ld_qrcode,
    ld_reserid ledgpost.ld_reserid,
    ld_vblock  ledgpost.ld_vblock
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS calists AS caBase OF cit_ca.vcx
Alias = [calists]
Tables = [lists]
KeyFieldList = [li_liid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       li_alang,
       li_attcahm,
       li_attpdf,
       li_basedon,
       li_batch,
       li_buildng,
       li_consent,
       li_custom,
       li_ddelink,
       li_ddemcro,
       li_delaymm,
       li_dialog,
       li_dotfile,
       li_email,
       li_emhea1,
       li_emhea10,
       li_emhea11,
       li_emhea2,
       li_emhea3,
       li_emhea4,
       li_emhea5,
       li_emhea6,
       li_emhea7,
       li_emhea8,
       li_emhea9,
       li_etsavdc,
       li_expath,
       li_expfile,
       li_expfnod,
       li_expmail,
       li_expsend,
       li_exptype,
       li_extra,
       li_filter,
       li_forms,
       li_frx,
       li_hide,
       li_index,
       li_lang1,
       li_lang10,
       li_lang11,
       li_lang2,
       li_lang3,
       li_lang4,
       li_lang5,
       li_lang6,
       li_lang7,
       li_lang8,
       li_lang9,
       li_lettype,
       li_lexptyp,
       li_license,
       li_liid,
       li_listid,
       li_mainsrv,
       li_maxdef1,
       li_maxdef2,
       li_maxdef3,
       li_maxdef4,
       li_memo,
       li_menu,
       li_mindef1,
       li_mindef2,
       li_mindef3,
       li_mindef4,
       li_operat1,
       li_operat2,
       li_operat3,
       li_operat4,
       li_order,
       li_outfile,
       li_output,
       li_picsql1,
       li_picsql2,
       li_picsql3,
       li_picsql4,
       li_pict1,
       li_pict2,
       li_pict3,
       li_pict4,
       li_postpro,
       li_preproc,
       li_reslet,
       li_rptgrp,
       li_saveres,
       li_showubd,
       li_sql,
       li_type1,
       li_type2,
       li_type3,
       li_type4,
       li_usrgrp,
       li_when,
       p1_lang1,
       p1_lang10,
       p1_lang11,
       p1_lang2,
       p1_lang3,
       p1_lang4,
       p1_lang5,
       p1_lang6,
       p1_lang7,
       p1_lang8,
       p1_lang9,
       p2_lang1,
       p2_lang10,
       p2_lang11,
       p2_lang2,
       p2_lang3,
       p2_lang4,
       p2_lang5,
       p2_lang6,
       p2_lang7,
       p2_lang8,
       p2_lang9,
       p3_lang1,
       p3_lang10,
       p3_lang11,
       p3_lang2,
       p3_lang3,
       p3_lang4,
       p3_lang5,
       p3_lang6,
       p3_lang7,
       p3_lang8,
       p3_lang9,
       p4_lang1,
       p4_lang10,
       p4_lang11,
       p4_lang2,
       p4_lang3,
       p4_lang4,
       p4_lang5,
       p4_lang6,
       p4_lang7,
       p4_lang8,
       p4_lang9
    FROM lists
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    li_alang   C(3)    DEFAULT "",
    li_attcahm M       DEFAULT "",
    li_attpdf  L       DEFAULT .F.,
    li_basedon C(8)    DEFAULT "",
    li_batch   C(30)   DEFAULT "",
    li_buildng L       DEFAULT .F.,
    li_consent L       DEFAULT .F.,
    li_custom  L       DEFAULT .F.,
    li_ddelink N(1,0)  DEFAULT 0,
    li_ddemcro C(20)   DEFAULT "",
    li_delaymm L       DEFAULT .F.,
    li_dialog  L       DEFAULT .F.,
    li_dotfile C(30)   DEFAULT "",
    li_email   L       DEFAULT .F.,
    li_emhea1  M       DEFAULT "",
    li_emhea10 M       DEFAULT "",
    li_emhea11 M       DEFAULT "",
    li_emhea2  M       DEFAULT "",
    li_emhea3  M       DEFAULT "",
    li_emhea4  M       DEFAULT "",
    li_emhea5  M       DEFAULT "",
    li_emhea6  M       DEFAULT "",
    li_emhea7  M       DEFAULT "",
    li_emhea8  M       DEFAULT "",
    li_emhea9  M       DEFAULT "",
    li_etsavdc L       DEFAULT .F.,
    li_expath  C(254)  DEFAULT "",
    li_expfile C(100)  DEFAULT "",
    li_expfnod L       DEFAULT .F.,
    li_expmail C(254)  DEFAULT "",
    li_expsend L       DEFAULT .F.,
    li_exptype C(3)    DEFAULT "",
    li_extra   C(10)   DEFAULT "",
    li_filter  C(100)  DEFAULT "",
    li_forms   C(254)  DEFAULT "",
    li_frx     C(30)   DEFAULT "",
    li_hide    L       DEFAULT .F.,
    li_index   C(100)  DEFAULT "",
    li_lang1   C(50)   DEFAULT "",
    li_lang10  C(50)   DEFAULT "",
    li_lang11  C(50)   DEFAULT "",
    li_lang2   C(50)   DEFAULT "",
    li_lang3   C(50)   DEFAULT "",
    li_lang4   C(50)   DEFAULT "",
    li_lang5   C(50)   DEFAULT "",
    li_lang6   C(50)   DEFAULT "",
    li_lang7   C(50)   DEFAULT "",
    li_lang8   C(50)   DEFAULT "",
    li_lang9   C(50)   DEFAULT "",
    li_lettype N(1,0)  DEFAULT 0,
    li_lexptyp N(1,0)  DEFAULT 0,
    li_license C(10)   DEFAULT "",
    li_liid    I       DEFAULT 0,
    li_listid  C(8)    DEFAULT "",
    li_mainsrv L       DEFAULT .F.,
    li_maxdef1 C(40)   DEFAULT "",
    li_maxdef2 C(40)   DEFAULT "",
    li_maxdef3 C(40)   DEFAULT "",
    li_maxdef4 C(40)   DEFAULT "",
    li_memo    M       DEFAULT "",
    li_menu    N(2,0)  DEFAULT 0,
    li_mindef1 C(40)   DEFAULT "",
    li_mindef2 C(40)   DEFAULT "",
    li_mindef3 C(40)   DEFAULT "",
    li_mindef4 C(40)   DEFAULT "",
    li_operat1 N(1,0)  DEFAULT 0,
    li_operat2 N(1,0)  DEFAULT 0,
    li_operat3 N(1,0)  DEFAULT 0,
    li_operat4 N(1,0)  DEFAULT 0,
    li_order   I       DEFAULT 0,
    li_outfile C(12)   DEFAULT "",
    li_output  N(1,0)  DEFAULT 0,
    li_picsql1 M       DEFAULT "",
    li_picsql2 M       DEFAULT "",
    li_picsql3 M       DEFAULT "",
    li_picsql4 M       DEFAULT "",
    li_pict1   C(20)   DEFAULT "",
    li_pict2   C(20)   DEFAULT "",
    li_pict3   C(20)   DEFAULT "",
    li_pict4   C(20)   DEFAULT "",
    li_postpro C(80)   DEFAULT "",
    li_preproc C(80)   DEFAULT "",
    li_reslet  L       DEFAULT .F.,
    li_rptgrp  C(20)   DEFAULT "",
    li_saveres L       DEFAULT .F.,
    li_showubd L       DEFAULT .F.,
    li_sql     M       DEFAULT "",
    li_type1   N(1,0)  DEFAULT 0,
    li_type2   N(1,0)  DEFAULT 0,
    li_type3   N(1,0)  DEFAULT 0,
    li_type4   N(1,0)  DEFAULT 0,
    li_usrgrp  C(30)   DEFAULT "",
    li_when    C(40)   DEFAULT "",
    p1_lang1   C(20)   DEFAULT "",
    p1_lang10  C(20)   DEFAULT "",
    p1_lang11  C(20)   DEFAULT "",
    p1_lang2   C(20)   DEFAULT "",
    p1_lang3   C(20)   DEFAULT "",
    p1_lang4   C(20)   DEFAULT "",
    p1_lang5   C(20)   DEFAULT "",
    p1_lang6   C(20)   DEFAULT "",
    p1_lang7   C(20)   DEFAULT "",
    p1_lang8   C(20)   DEFAULT "",
    p1_lang9   C(20)   DEFAULT "",
    p2_lang1   C(20)   DEFAULT "",
    p2_lang10  C(20)   DEFAULT "",
    p2_lang11  C(20)   DEFAULT "",
    p2_lang2   C(20)   DEFAULT "",
    p2_lang3   C(20)   DEFAULT "",
    p2_lang4   C(20)   DEFAULT "",
    p2_lang5   C(20)   DEFAULT "",
    p2_lang6   C(20)   DEFAULT "",
    p2_lang7   C(20)   DEFAULT "",
    p2_lang8   C(20)   DEFAULT "",
    p2_lang9   C(20)   DEFAULT "",
    p3_lang1   C(20)   DEFAULT "",
    p3_lang10  C(20)   DEFAULT "",
    p3_lang11  C(20)   DEFAULT "",
    p3_lang2   C(20)   DEFAULT "",
    p3_lang3   C(20)   DEFAULT "",
    p3_lang4   C(20)   DEFAULT "",
    p3_lang5   C(20)   DEFAULT "",
    p3_lang6   C(20)   DEFAULT "",
    p3_lang7   C(20)   DEFAULT "",
    p3_lang8   C(20)   DEFAULT "",
    p3_lang9   C(20)   DEFAULT "",
    p4_lang1   C(20)   DEFAULT "",
    p4_lang10  C(20)   DEFAULT "",
    p4_lang11  C(20)   DEFAULT "",
    p4_lang2   C(20)   DEFAULT "",
    p4_lang3   C(20)   DEFAULT "",
    p4_lang4   C(20)   DEFAULT "",
    p4_lang5   C(20)   DEFAULT "",
    p4_lang6   C(20)   DEFAULT "",
    p4_lang7   C(20)   DEFAULT "",
    p4_lang8   C(20)   DEFAULT "",
    p4_lang9   C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    li_alang,
    li_attcahm,
    li_attpdf,
    li_basedon,
    li_batch,
    li_buildng,
    li_consent,
    li_custom,
    li_ddelink,
    li_ddemcro,
    li_delaymm,
    li_dialog,
    li_dotfile,
    li_email,
    li_emhea1,
    li_emhea10,
    li_emhea11,
    li_emhea2,
    li_emhea3,
    li_emhea4,
    li_emhea5,
    li_emhea6,
    li_emhea7,
    li_emhea8,
    li_emhea9,
    li_etsavdc,
    li_expath,
    li_expfile,
    li_expfnod,
    li_expmail,
    li_expsend,
    li_exptype,
    li_extra,
    li_filter,
    li_forms,
    li_frx,
    li_hide,
    li_index,
    li_lang1,
    li_lang10,
    li_lang11,
    li_lang2,
    li_lang3,
    li_lang4,
    li_lang5,
    li_lang6,
    li_lang7,
    li_lang8,
    li_lang9,
    li_lettype,
    li_lexptyp,
    li_license,
    li_liid,
    li_listid,
    li_mainsrv,
    li_maxdef1,
    li_maxdef2,
    li_maxdef3,
    li_maxdef4,
    li_memo,
    li_menu,
    li_mindef1,
    li_mindef2,
    li_mindef3,
    li_mindef4,
    li_operat1,
    li_operat2,
    li_operat3,
    li_operat4,
    li_order,
    li_outfile,
    li_output,
    li_picsql1,
    li_picsql2,
    li_picsql3,
    li_picsql4,
    li_pict1,
    li_pict2,
    li_pict3,
    li_pict4,
    li_postpro,
    li_preproc,
    li_reslet,
    li_rptgrp,
    li_saveres,
    li_showubd,
    li_sql,
    li_type1,
    li_type2,
    li_type3,
    li_type4,
    li_usrgrp,
    li_when,
    p1_lang1,
    p1_lang10,
    p1_lang11,
    p1_lang2,
    p1_lang3,
    p1_lang4,
    p1_lang5,
    p1_lang6,
    p1_lang7,
    p1_lang8,
    p1_lang9,
    p2_lang1,
    p2_lang10,
    p2_lang11,
    p2_lang2,
    p2_lang3,
    p2_lang4,
    p2_lang5,
    p2_lang6,
    p2_lang7,
    p2_lang8,
    p2_lang9,
    p3_lang1,
    p3_lang10,
    p3_lang11,
    p3_lang2,
    p3_lang3,
    p3_lang4,
    p3_lang5,
    p3_lang6,
    p3_lang7,
    p3_lang8,
    p3_lang9,
    p4_lang1,
    p4_lang10,
    p4_lang11,
    p4_lang2,
    p4_lang3,
    p4_lang4,
    p4_lang5,
    p4_lang6,
    p4_lang7,
    p4_lang8,
    p4_lang9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    li_alang   lists.li_alang,
    li_attcahm lists.li_attcahm,
    li_attpdf  lists.li_attpdf,
    li_basedon lists.li_basedon,
    li_batch   lists.li_batch,
    li_buildng lists.li_buildng,
    li_consent lists.li_consent,
    li_custom  lists.li_custom,
    li_ddelink lists.li_ddelink,
    li_ddemcro lists.li_ddemcro,
    li_delaymm lists.li_delaymm,
    li_dialog  lists.li_dialog,
    li_dotfile lists.li_dotfile,
    li_email   lists.li_email,
    li_emhea1  lists.li_emhea1,
    li_emhea10 lists.li_emhea10,
    li_emhea11 lists.li_emhea11,
    li_emhea2  lists.li_emhea2,
    li_emhea3  lists.li_emhea3,
    li_emhea4  lists.li_emhea4,
    li_emhea5  lists.li_emhea5,
    li_emhea6  lists.li_emhea6,
    li_emhea7  lists.li_emhea7,
    li_emhea8  lists.li_emhea8,
    li_emhea9  lists.li_emhea9,
    li_etsavdc lists.li_etsavdc,
    li_expath  lists.li_expath,
    li_expfile lists.li_expfile,
    li_expfnod lists.li_expfnod,
    li_expmail lists.li_expmail,
    li_expsend lists.li_expsend,
    li_exptype lists.li_exptype,
    li_extra   lists.li_extra,
    li_filter  lists.li_filter,
    li_forms   lists.li_forms,
    li_frx     lists.li_frx,
    li_hide    lists.li_hide,
    li_index   lists.li_index,
    li_lang1   lists.li_lang1,
    li_lang10  lists.li_lang10,
    li_lang11  lists.li_lang11,
    li_lang2   lists.li_lang2,
    li_lang3   lists.li_lang3,
    li_lang4   lists.li_lang4,
    li_lang5   lists.li_lang5,
    li_lang6   lists.li_lang6,
    li_lang7   lists.li_lang7,
    li_lang8   lists.li_lang8,
    li_lang9   lists.li_lang9,
    li_lettype lists.li_lettype,
    li_lexptyp lists.li_lexptyp,
    li_license lists.li_license,
    li_liid    lists.li_liid,
    li_listid  lists.li_listid,
    li_mainsrv lists.li_mainsrv,
    li_maxdef1 lists.li_maxdef1,
    li_maxdef2 lists.li_maxdef2,
    li_maxdef3 lists.li_maxdef3,
    li_maxdef4 lists.li_maxdef4,
    li_memo    lists.li_memo,
    li_menu    lists.li_menu,
    li_mindef1 lists.li_mindef1,
    li_mindef2 lists.li_mindef2,
    li_mindef3 lists.li_mindef3,
    li_mindef4 lists.li_mindef4,
    li_operat1 lists.li_operat1,
    li_operat2 lists.li_operat2,
    li_operat3 lists.li_operat3,
    li_operat4 lists.li_operat4,
    li_order   lists.li_order,
    li_outfile lists.li_outfile,
    li_output  lists.li_output,
    li_picsql1 lists.li_picsql1,
    li_picsql2 lists.li_picsql2,
    li_picsql3 lists.li_picsql3,
    li_picsql4 lists.li_picsql4,
    li_pict1   lists.li_pict1,
    li_pict2   lists.li_pict2,
    li_pict3   lists.li_pict3,
    li_pict4   lists.li_pict4,
    li_postpro lists.li_postpro,
    li_preproc lists.li_preproc,
    li_reslet  lists.li_reslet,
    li_rptgrp  lists.li_rptgrp,
    li_saveres lists.li_saveres,
    li_showubd lists.li_showubd,
    li_sql     lists.li_sql,
    li_type1   lists.li_type1,
    li_type2   lists.li_type2,
    li_type3   lists.li_type3,
    li_type4   lists.li_type4,
    li_usrgrp  lists.li_usrgrp,
    li_when    lists.li_when,
    p1_lang1   lists.p1_lang1,
    p1_lang10  lists.p1_lang10,
    p1_lang11  lists.p1_lang11,
    p1_lang2   lists.p1_lang2,
    p1_lang3   lists.p1_lang3,
    p1_lang4   lists.p1_lang4,
    p1_lang5   lists.p1_lang5,
    p1_lang6   lists.p1_lang6,
    p1_lang7   lists.p1_lang7,
    p1_lang8   lists.p1_lang8,
    p1_lang9   lists.p1_lang9,
    p2_lang1   lists.p2_lang1,
    p2_lang10  lists.p2_lang10,
    p2_lang11  lists.p2_lang11,
    p2_lang2   lists.p2_lang2,
    p2_lang3   lists.p2_lang3,
    p2_lang4   lists.p2_lang4,
    p2_lang5   lists.p2_lang5,
    p2_lang6   lists.p2_lang6,
    p2_lang7   lists.p2_lang7,
    p2_lang8   lists.p2_lang8,
    p2_lang9   lists.p2_lang9,
    p3_lang1   lists.p3_lang1,
    p3_lang10  lists.p3_lang10,
    p3_lang11  lists.p3_lang11,
    p3_lang2   lists.p3_lang2,
    p3_lang3   lists.p3_lang3,
    p3_lang4   lists.p3_lang4,
    p3_lang5   lists.p3_lang5,
    p3_lang6   lists.p3_lang6,
    p3_lang7   lists.p3_lang7,
    p3_lang8   lists.p3_lang8,
    p3_lang9   lists.p3_lang9,
    p4_lang1   lists.p4_lang1,
    p4_lang10  lists.p4_lang10,
    p4_lang11  lists.p4_lang11,
    p4_lang2   lists.p4_lang2,
    p4_lang3   lists.p4_lang3,
    p4_lang4   lists.p4_lang4,
    p4_lang5   lists.p4_lang5,
    p4_lang6   lists.p4_lang6,
    p4_lang7   lists.p4_lang7,
    p4_lang8   lists.p4_lang8,
    p4_lang9   lists.p4_lang9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS calogger AS caBase OF cit_ca.vcx
Alias = [calogger]
Tables = [logger]
KeyFieldList = [lg_lgid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       lg_action,
       lg_changes,
       lg_keyexp,
       lg_keyid,
       lg_lgid,
       lg_sysdate,
       lg_table,
       lg_user,
       lg_when
    FROM logger
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    lg_action  C(1)    DEFAULT "",
    lg_changes M       DEFAULT "",
    lg_keyexp  C(50)   DEFAULT "",
    lg_keyid   C(35)   DEFAULT "",
    lg_lgid    I       DEFAULT 0,
    lg_sysdate D       DEFAULT {},
    lg_table   C(10)   DEFAULT "",
    lg_user    C(10)   DEFAULT "",
    lg_when    T       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lg_action,
    lg_changes,
    lg_keyexp,
    lg_keyid,
    lg_lgid,
    lg_sysdate,
    lg_table,
    lg_user,
    lg_when
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lg_action  logger.lg_action,
    lg_changes logger.lg_changes,
    lg_keyexp  logger.lg_keyexp,
    lg_keyid   logger.lg_keyid,
    lg_lgid    logger.lg_lgid,
    lg_sysdate logger.lg_sysdate,
    lg_table   logger.lg_table,
    lg_user    logger.lg_user,
    lg_when    logger.lg_when
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camanager AS caBase OF cit_ca.vcx
Alias = [camanager]
Tables = [manager]
KeyFieldList = [mg_date]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       mg_all30da,
       mg_all365d,
       mg_allendm,
       mg_allendy,
       mg_allnext,
       mg_alltomo,
       mg_arrival,
       mg_bdoccm,
       mg_bdoccy,
       mg_bdooom,
       mg_bdoooy,
       mg_bdoosm,
       mg_bdoosy,
       mg_bedavl,
       mg_bedavlm,
       mg_bedavly,
       mg_bedocc,
       mg_bedooo,
       mg_bedoos,
       mg_cldg,
       mg_cldgcrd,
       mg_cldgdeb,
       mg_compprd,
       mg_compprm,
       mg_comppry,
       mg_comprmd,
       mg_comprmm,
       mg_comprmy,
       mg_cxllate,
       mg_cxllatm,
       mg_cxllaty,
       mg_date,
       mg_dayg1,
       mg_dayg2,
       mg_dayg3,
       mg_dayg4,
       mg_dayg5,
       mg_dayg6,
       mg_dayg7,
       mg_dayg8,
       mg_dayg9,
       mg_dayp1,
       mg_dayp2,
       mg_dayp3,
       mg_dayp4,
       mg_dayp5,
       mg_dayp6,
       mg_dayp7,
       mg_dayp8,
       mg_dayp9,
       mg_def30da,
       mg_def365d,
       mg_defendm,
       mg_defendy,
       mg_defnext,
       mg_deftomo,
       mg_departu,
       mg_dldg,
       mg_dldgcrd,
       mg_dldgdeb,
       mg_dvat1,
       mg_dvat2,
       mg_dvat3,
       mg_dvat4,
       mg_dvat5,
       mg_dvat6,
       mg_dvat7,
       mg_dvat8,
       mg_dvat9,
       mg_gcertd,
       mg_gcertm,
       mg_gcerty,
       mg_gcldg,
       mg_gstldg,
       mg_internd,
       mg_internm,
       mg_interny,
       mg_max30da,
       mg_max365d,
       mg_maxendm,
       mg_maxendy,
       mg_maxnext,
       mg_maxtomo,
       mg_mong1,
       mg_mong2,
       mg_mong3,
       mg_mong4,
       mg_mong5,
       mg_mong6,
       mg_mong7,
       mg_mong8,
       mg_mong9,
       mg_monp1,
       mg_monp2,
       mg_monp3,
       mg_monp4,
       mg_monp5,
       mg_monp6,
       mg_monp7,
       mg_monp8,
       mg_monp9,
       mg_mvat1,
       mg_mvat2,
       mg_mvat3,
       mg_mvat4,
       mg_mvat5,
       mg_mvat6,
       mg_mvat7,
       mg_mvat8,
       mg_mvat9,
       mg_octopos,
       mg_opt30da,
       mg_opt365d,
       mg_optcxl,
       mg_optcxlm,
       mg_optcxly,
       mg_optendm,
       mg_optendy,
       mg_optnext,
       mg_opttomo,
       mg_pdoutd,
       mg_pdoutm,
       mg_pdouty,
       mg_perarrm,
       mg_perarry,
       mg_perdepm,
       mg_perdepy,
       mg_persarr,
       mg_persdep,
       mg_pic30da,
       mg_pic365d,
       mg_picendm,
       mg_picendy,
       mg_picnext,
       mg_pictomo,
       mg_prduse,
       mg_prdusem,
       mg_prdusey,
       mg_rescxl,
       mg_rescxlm,
       mg_rescxly,
       mg_resnew,
       mg_resnewm,
       mg_resnewy,
       mg_resns,
       mg_resnsm,
       mg_resnsy,
       mg_rmarrm,
       mg_rmarry,
       mg_rmduse,
       mg_rmdusem,
       mg_rmdusey,
       mg_rmoccm,
       mg_rmoccy,
       mg_rmooom,
       mg_rmoooy,
       mg_rmoosm,
       mg_rmoosy,
       mg_roodepm,
       mg_roodepy,
       mg_roomarr,
       mg_roomavl,
       mg_roomavm,
       mg_roomavy,
       mg_roomdep,
       mg_roomocc,
       mg_roomooo,
       mg_roomoos,
       mg_ten30da,
       mg_ten365d,
       mg_tencxl,
       mg_tencxlm,
       mg_tencxly,
       mg_tenendm,
       mg_tenendy,
       mg_tennext,
       mg_tentomo,
       mg_wai30da,
       mg_wai365d,
       mg_waiendm,
       mg_waiendy,
       mg_wainext,
       mg_waitomo,
       mg_yeag1,
       mg_yeag2,
       mg_yeag3,
       mg_yeag4,
       mg_yeag5,
       mg_yeag6,
       mg_yeag7,
       mg_yeag8,
       mg_yeag9,
       mg_yeap1,
       mg_yeap2,
       mg_yeap3,
       mg_yeap4,
       mg_yeap5,
       mg_yeap6,
       mg_yeap7,
       mg_yeap8,
       mg_yeap9,
       mg_yvat1,
       mg_yvat2,
       mg_yvat3,
       mg_yvat4,
       mg_yvat5,
       mg_yvat6,
       mg_yvat7,
       mg_yvat8,
       mg_yvat9
    FROM manager
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_all30da N(10,0) DEFAULT 0,
    mg_all365d N(10,0) DEFAULT 0,
    mg_allendm N(10,0) DEFAULT 0,
    mg_allendy N(10,0) DEFAULT 0,
    mg_allnext N(10,0) DEFAULT 0,
    mg_alltomo N(10,0) DEFAULT 0,
    mg_arrival N(10,0) DEFAULT 0,
    mg_bdoccm  N(10,0) DEFAULT 0,
    mg_bdoccy  N(10,0) DEFAULT 0,
    mg_bdooom  N(10,0) DEFAULT 0,
    mg_bdoooy  N(10,0) DEFAULT 0,
    mg_bdoosm  N(10,0) DEFAULT 0,
    mg_bdoosy  N(10,0) DEFAULT 0,
    mg_bedavl  N(10,0) DEFAULT 0,
    mg_bedavlm N(10,0) DEFAULT 0,
    mg_bedavly N(10,0) DEFAULT 0,
    mg_bedocc  N(10,0) DEFAULT 0,
    mg_bedooo  N(10,0) DEFAULT 0,
    mg_bedoos  N(10,0) DEFAULT 0,
    mg_cldg    B(2)    DEFAULT 0,
    mg_cldgcrd B(2)    DEFAULT 0,
    mg_cldgdeb B(2)    DEFAULT 0,
    mg_compprd N(10,0) DEFAULT 0,
    mg_compprm N(10,0) DEFAULT 0,
    mg_comppry N(10,0) DEFAULT 0,
    mg_comprmd N(10,0) DEFAULT 0,
    mg_comprmm N(10,0) DEFAULT 0,
    mg_comprmy N(10,0) DEFAULT 0,
    mg_cxllate N(10,0) DEFAULT 0,
    mg_cxllatm N(10,0) DEFAULT 0,
    mg_cxllaty N(10,0) DEFAULT 0,
    mg_date    D       DEFAULT {},
    mg_dayg1   B(2)    DEFAULT 0,
    mg_dayg2   B(2)    DEFAULT 0,
    mg_dayg3   B(2)    DEFAULT 0,
    mg_dayg4   B(2)    DEFAULT 0,
    mg_dayg5   B(2)    DEFAULT 0,
    mg_dayg6   B(2)    DEFAULT 0,
    mg_dayg7   B(2)    DEFAULT 0,
    mg_dayg8   B(2)    DEFAULT 0,
    mg_dayg9   B(2)    DEFAULT 0,
    mg_dayp1   B(2)    DEFAULT 0,
    mg_dayp2   B(2)    DEFAULT 0,
    mg_dayp3   B(2)    DEFAULT 0,
    mg_dayp4   B(2)    DEFAULT 0,
    mg_dayp5   B(2)    DEFAULT 0,
    mg_dayp6   B(2)    DEFAULT 0,
    mg_dayp7   B(2)    DEFAULT 0,
    mg_dayp8   B(2)    DEFAULT 0,
    mg_dayp9   B(2)    DEFAULT 0,
    mg_def30da N(10,0) DEFAULT 0,
    mg_def365d N(10,0) DEFAULT 0,
    mg_defendm N(10,0) DEFAULT 0,
    mg_defendy N(10,0) DEFAULT 0,
    mg_defnext N(10,0) DEFAULT 0,
    mg_deftomo N(10,0) DEFAULT 0,
    mg_departu N(10,0) DEFAULT 0,
    mg_dldg    B(2)    DEFAULT 0,
    mg_dldgcrd B(2)    DEFAULT 0,
    mg_dldgdeb B(2)    DEFAULT 0,
    mg_dvat1   B(6)    DEFAULT 0,
    mg_dvat2   B(6)    DEFAULT 0,
    mg_dvat3   B(6)    DEFAULT 0,
    mg_dvat4   B(6)    DEFAULT 0,
    mg_dvat5   B(6)    DEFAULT 0,
    mg_dvat6   B(6)    DEFAULT 0,
    mg_dvat7   B(6)    DEFAULT 0,
    mg_dvat8   B(6)    DEFAULT 0,
    mg_dvat9   B(6)    DEFAULT 0,
    mg_gcertd  B(2)    DEFAULT 0,
    mg_gcertm  B(2)    DEFAULT 0,
    mg_gcerty  B(2)    DEFAULT 0,
    mg_gcldg   B(2)    DEFAULT 0,
    mg_gstldg  B(2)    DEFAULT 0,
    mg_internd B(2)    DEFAULT 0,
    mg_internm B(2)    DEFAULT 0,
    mg_interny B(2)    DEFAULT 0,
    mg_max30da N(10,0) DEFAULT 0,
    mg_max365d N(10,0) DEFAULT 0,
    mg_maxendm N(10,0) DEFAULT 0,
    mg_maxendy N(10,0) DEFAULT 0,
    mg_maxnext N(10,0) DEFAULT 0,
    mg_maxtomo N(10,0) DEFAULT 0,
    mg_mong1   B(2)    DEFAULT 0,
    mg_mong2   B(2)    DEFAULT 0,
    mg_mong3   B(2)    DEFAULT 0,
    mg_mong4   B(2)    DEFAULT 0,
    mg_mong5   B(2)    DEFAULT 0,
    mg_mong6   B(2)    DEFAULT 0,
    mg_mong7   B(2)    DEFAULT 0,
    mg_mong8   B(2)    DEFAULT 0,
    mg_mong9   B(2)    DEFAULT 0,
    mg_monp1   B(2)    DEFAULT 0,
    mg_monp2   B(2)    DEFAULT 0,
    mg_monp3   B(2)    DEFAULT 0,
    mg_monp4   B(2)    DEFAULT 0,
    mg_monp5   B(2)    DEFAULT 0,
    mg_monp6   B(2)    DEFAULT 0,
    mg_monp7   B(2)    DEFAULT 0,
    mg_monp8   B(2)    DEFAULT 0,
    mg_monp9   B(2)    DEFAULT 0,
    mg_mvat1   B(6)    DEFAULT 0,
    mg_mvat2   B(6)    DEFAULT 0,
    mg_mvat3   B(6)    DEFAULT 0,
    mg_mvat4   B(6)    DEFAULT 0,
    mg_mvat5   B(6)    DEFAULT 0,
    mg_mvat6   B(6)    DEFAULT 0,
    mg_mvat7   B(6)    DEFAULT 0,
    mg_mvat8   B(6)    DEFAULT 0,
    mg_mvat9   B(6)    DEFAULT 0,
    mg_octopos L       DEFAULT .F.,
    mg_opt30da N(10,0) DEFAULT 0,
    mg_opt365d N(10,0) DEFAULT 0,
    mg_optcxl  N(10,0) DEFAULT 0,
    mg_optcxlm N(10,0) DEFAULT 0,
    mg_optcxly N(10,0) DEFAULT 0,
    mg_optendm N(10,0) DEFAULT 0,
    mg_optendy N(10,0) DEFAULT 0,
    mg_optnext N(10,0) DEFAULT 0,
    mg_opttomo N(10,0) DEFAULT 0,
    mg_pdoutd  B(2)    DEFAULT 0,
    mg_pdoutm  B(2)    DEFAULT 0,
    mg_pdouty  B(2)    DEFAULT 0,
    mg_perarrm N(10,0) DEFAULT 0,
    mg_perarry N(10,0) DEFAULT 0,
    mg_perdepm N(10,0) DEFAULT 0,
    mg_perdepy N(10,0) DEFAULT 0,
    mg_persarr N(10,0) DEFAULT 0,
    mg_persdep N(10,0) DEFAULT 0,
    mg_pic30da N(10,0) DEFAULT 0,
    mg_pic365d N(10,0) DEFAULT 0,
    mg_picendm N(10,0) DEFAULT 0,
    mg_picendy N(10,0) DEFAULT 0,
    mg_picnext N(10,0) DEFAULT 0,
    mg_pictomo N(10,0) DEFAULT 0,
    mg_prduse  N(10,0) DEFAULT 0,
    mg_prdusem N(10,0) DEFAULT 0,
    mg_prdusey N(10,0) DEFAULT 0,
    mg_rescxl  N(10,0) DEFAULT 0,
    mg_rescxlm N(10,0) DEFAULT 0,
    mg_rescxly N(10,0) DEFAULT 0,
    mg_resnew  N(10,0) DEFAULT 0,
    mg_resnewm N(10,0) DEFAULT 0,
    mg_resnewy N(10,0) DEFAULT 0,
    mg_resns   N(10,0) DEFAULT 0,
    mg_resnsm  N(10,0) DEFAULT 0,
    mg_resnsy  N(10,0) DEFAULT 0,
    mg_rmarrm  N(10,0) DEFAULT 0,
    mg_rmarry  N(10,0) DEFAULT 0,
    mg_rmduse  N(10,0) DEFAULT 0,
    mg_rmdusem N(10,0) DEFAULT 0,
    mg_rmdusey N(10,0) DEFAULT 0,
    mg_rmoccm  N(10,0) DEFAULT 0,
    mg_rmoccy  N(10,0) DEFAULT 0,
    mg_rmooom  N(10,0) DEFAULT 0,
    mg_rmoooy  N(10,0) DEFAULT 0,
    mg_rmoosm  N(10,0) DEFAULT 0,
    mg_rmoosy  N(10,0) DEFAULT 0,
    mg_roodepm N(10,0) DEFAULT 0,
    mg_roodepy N(10,0) DEFAULT 0,
    mg_roomarr N(10,0) DEFAULT 0,
    mg_roomavl N(10,0) DEFAULT 0,
    mg_roomavm N(10,0) DEFAULT 0,
    mg_roomavy N(10,0) DEFAULT 0,
    mg_roomdep N(10,0) DEFAULT 0,
    mg_roomocc N(10,0) DEFAULT 0,
    mg_roomooo N(10,0) DEFAULT 0,
    mg_roomoos N(10,0) DEFAULT 0,
    mg_ten30da N(10,0) DEFAULT 0,
    mg_ten365d N(10,0) DEFAULT 0,
    mg_tencxl  N(10,0) DEFAULT 0,
    mg_tencxlm N(10,0) DEFAULT 0,
    mg_tencxly N(10,0) DEFAULT 0,
    mg_tenendm N(10,0) DEFAULT 0,
    mg_tenendy N(10,0) DEFAULT 0,
    mg_tennext N(10,0) DEFAULT 0,
    mg_tentomo N(10,0) DEFAULT 0,
    mg_wai30da N(10,0) DEFAULT 0,
    mg_wai365d N(10,0) DEFAULT 0,
    mg_waiendm N(10,0) DEFAULT 0,
    mg_waiendy N(10,0) DEFAULT 0,
    mg_wainext N(10,0) DEFAULT 0,
    mg_waitomo N(10,0) DEFAULT 0,
    mg_yeag1   B(2)    DEFAULT 0,
    mg_yeag2   B(2)    DEFAULT 0,
    mg_yeag3   B(2)    DEFAULT 0,
    mg_yeag4   B(2)    DEFAULT 0,
    mg_yeag5   B(2)    DEFAULT 0,
    mg_yeag6   B(2)    DEFAULT 0,
    mg_yeag7   B(2)    DEFAULT 0,
    mg_yeag8   B(2)    DEFAULT 0,
    mg_yeag9   B(2)    DEFAULT 0,
    mg_yeap1   B(2)    DEFAULT 0,
    mg_yeap2   B(2)    DEFAULT 0,
    mg_yeap3   B(2)    DEFAULT 0,
    mg_yeap4   B(2)    DEFAULT 0,
    mg_yeap5   B(2)    DEFAULT 0,
    mg_yeap6   B(2)    DEFAULT 0,
    mg_yeap7   B(2)    DEFAULT 0,
    mg_yeap8   B(2)    DEFAULT 0,
    mg_yeap9   B(2)    DEFAULT 0,
    mg_yvat1   B(6)    DEFAULT 0,
    mg_yvat2   B(6)    DEFAULT 0,
    mg_yvat3   B(6)    DEFAULT 0,
    mg_yvat4   B(6)    DEFAULT 0,
    mg_yvat5   B(6)    DEFAULT 0,
    mg_yvat6   B(6)    DEFAULT 0,
    mg_yvat7   B(6)    DEFAULT 0,
    mg_yvat8   B(6)    DEFAULT 0,
    mg_yvat9   B(6)    DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_all30da,
    mg_all365d,
    mg_allendm,
    mg_allendy,
    mg_allnext,
    mg_alltomo,
    mg_arrival,
    mg_bdoccm,
    mg_bdoccy,
    mg_bdooom,
    mg_bdoooy,
    mg_bdoosm,
    mg_bdoosy,
    mg_bedavl,
    mg_bedavlm,
    mg_bedavly,
    mg_bedocc,
    mg_bedooo,
    mg_bedoos,
    mg_cldg,
    mg_cldgcrd,
    mg_cldgdeb,
    mg_compprd,
    mg_compprm,
    mg_comppry,
    mg_comprmd,
    mg_comprmm,
    mg_comprmy,
    mg_cxllate,
    mg_cxllatm,
    mg_cxllaty,
    mg_date,
    mg_dayg1,
    mg_dayg2,
    mg_dayg3,
    mg_dayg4,
    mg_dayg5,
    mg_dayg6,
    mg_dayg7,
    mg_dayg8,
    mg_dayg9,
    mg_dayp1,
    mg_dayp2,
    mg_dayp3,
    mg_dayp4,
    mg_dayp5,
    mg_dayp6,
    mg_dayp7,
    mg_dayp8,
    mg_dayp9,
    mg_def30da,
    mg_def365d,
    mg_defendm,
    mg_defendy,
    mg_defnext,
    mg_deftomo,
    mg_departu,
    mg_dldg,
    mg_dldgcrd,
    mg_dldgdeb,
    mg_dvat1,
    mg_dvat2,
    mg_dvat3,
    mg_dvat4,
    mg_dvat5,
    mg_dvat6,
    mg_dvat7,
    mg_dvat8,
    mg_dvat9,
    mg_gcertd,
    mg_gcertm,
    mg_gcerty,
    mg_gcldg,
    mg_gstldg,
    mg_internd,
    mg_internm,
    mg_interny,
    mg_max30da,
    mg_max365d,
    mg_maxendm,
    mg_maxendy,
    mg_maxnext,
    mg_maxtomo,
    mg_mong1,
    mg_mong2,
    mg_mong3,
    mg_mong4,
    mg_mong5,
    mg_mong6,
    mg_mong7,
    mg_mong8,
    mg_mong9,
    mg_monp1,
    mg_monp2,
    mg_monp3,
    mg_monp4,
    mg_monp5,
    mg_monp6,
    mg_monp7,
    mg_monp8,
    mg_monp9,
    mg_mvat1,
    mg_mvat2,
    mg_mvat3,
    mg_mvat4,
    mg_mvat5,
    mg_mvat6,
    mg_mvat7,
    mg_mvat8,
    mg_mvat9,
    mg_octopos,
    mg_opt30da,
    mg_opt365d,
    mg_optcxl,
    mg_optcxlm,
    mg_optcxly,
    mg_optendm,
    mg_optendy,
    mg_optnext,
    mg_opttomo,
    mg_pdoutd,
    mg_pdoutm,
    mg_pdouty,
    mg_perarrm,
    mg_perarry,
    mg_perdepm,
    mg_perdepy,
    mg_persarr,
    mg_persdep,
    mg_pic30da,
    mg_pic365d,
    mg_picendm,
    mg_picendy,
    mg_picnext,
    mg_pictomo,
    mg_prduse,
    mg_prdusem,
    mg_prdusey,
    mg_rescxl,
    mg_rescxlm,
    mg_rescxly,
    mg_resnew,
    mg_resnewm,
    mg_resnewy,
    mg_resns,
    mg_resnsm,
    mg_resnsy,
    mg_rmarrm,
    mg_rmarry,
    mg_rmduse,
    mg_rmdusem,
    mg_rmdusey,
    mg_rmoccm,
    mg_rmoccy,
    mg_rmooom,
    mg_rmoooy,
    mg_rmoosm,
    mg_rmoosy,
    mg_roodepm,
    mg_roodepy,
    mg_roomarr,
    mg_roomavl,
    mg_roomavm,
    mg_roomavy,
    mg_roomdep,
    mg_roomocc,
    mg_roomooo,
    mg_roomoos,
    mg_ten30da,
    mg_ten365d,
    mg_tencxl,
    mg_tencxlm,
    mg_tencxly,
    mg_tenendm,
    mg_tenendy,
    mg_tennext,
    mg_tentomo,
    mg_wai30da,
    mg_wai365d,
    mg_waiendm,
    mg_waiendy,
    mg_wainext,
    mg_waitomo,
    mg_yeag1,
    mg_yeag2,
    mg_yeag3,
    mg_yeag4,
    mg_yeag5,
    mg_yeag6,
    mg_yeag7,
    mg_yeag8,
    mg_yeag9,
    mg_yeap1,
    mg_yeap2,
    mg_yeap3,
    mg_yeap4,
    mg_yeap5,
    mg_yeap6,
    mg_yeap7,
    mg_yeap8,
    mg_yeap9,
    mg_yvat1,
    mg_yvat2,
    mg_yvat3,
    mg_yvat4,
    mg_yvat5,
    mg_yvat6,
    mg_yvat7,
    mg_yvat8,
    mg_yvat9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_all30da manager.mg_all30da,
    mg_all365d manager.mg_all365d,
    mg_allendm manager.mg_allendm,
    mg_allendy manager.mg_allendy,
    mg_allnext manager.mg_allnext,
    mg_alltomo manager.mg_alltomo,
    mg_arrival manager.mg_arrival,
    mg_bdoccm  manager.mg_bdoccm,
    mg_bdoccy  manager.mg_bdoccy,
    mg_bdooom  manager.mg_bdooom,
    mg_bdoooy  manager.mg_bdoooy,
    mg_bdoosm  manager.mg_bdoosm,
    mg_bdoosy  manager.mg_bdoosy,
    mg_bedavl  manager.mg_bedavl,
    mg_bedavlm manager.mg_bedavlm,
    mg_bedavly manager.mg_bedavly,
    mg_bedocc  manager.mg_bedocc,
    mg_bedooo  manager.mg_bedooo,
    mg_bedoos  manager.mg_bedoos,
    mg_cldg    manager.mg_cldg,
    mg_cldgcrd manager.mg_cldgcrd,
    mg_cldgdeb manager.mg_cldgdeb,
    mg_compprd manager.mg_compprd,
    mg_compprm manager.mg_compprm,
    mg_comppry manager.mg_comppry,
    mg_comprmd manager.mg_comprmd,
    mg_comprmm manager.mg_comprmm,
    mg_comprmy manager.mg_comprmy,
    mg_cxllate manager.mg_cxllate,
    mg_cxllatm manager.mg_cxllatm,
    mg_cxllaty manager.mg_cxllaty,
    mg_date    manager.mg_date,
    mg_dayg1   manager.mg_dayg1,
    mg_dayg2   manager.mg_dayg2,
    mg_dayg3   manager.mg_dayg3,
    mg_dayg4   manager.mg_dayg4,
    mg_dayg5   manager.mg_dayg5,
    mg_dayg6   manager.mg_dayg6,
    mg_dayg7   manager.mg_dayg7,
    mg_dayg8   manager.mg_dayg8,
    mg_dayg9   manager.mg_dayg9,
    mg_dayp1   manager.mg_dayp1,
    mg_dayp2   manager.mg_dayp2,
    mg_dayp3   manager.mg_dayp3,
    mg_dayp4   manager.mg_dayp4,
    mg_dayp5   manager.mg_dayp5,
    mg_dayp6   manager.mg_dayp6,
    mg_dayp7   manager.mg_dayp7,
    mg_dayp8   manager.mg_dayp8,
    mg_dayp9   manager.mg_dayp9,
    mg_def30da manager.mg_def30da,
    mg_def365d manager.mg_def365d,
    mg_defendm manager.mg_defendm,
    mg_defendy manager.mg_defendy,
    mg_defnext manager.mg_defnext,
    mg_deftomo manager.mg_deftomo,
    mg_departu manager.mg_departu,
    mg_dldg    manager.mg_dldg,
    mg_dldgcrd manager.mg_dldgcrd,
    mg_dldgdeb manager.mg_dldgdeb,
    mg_dvat1   manager.mg_dvat1,
    mg_dvat2   manager.mg_dvat2,
    mg_dvat3   manager.mg_dvat3,
    mg_dvat4   manager.mg_dvat4,
    mg_dvat5   manager.mg_dvat5,
    mg_dvat6   manager.mg_dvat6,
    mg_dvat7   manager.mg_dvat7,
    mg_dvat8   manager.mg_dvat8,
    mg_dvat9   manager.mg_dvat9,
    mg_gcertd  manager.mg_gcertd,
    mg_gcertm  manager.mg_gcertm,
    mg_gcerty  manager.mg_gcerty,
    mg_gcldg   manager.mg_gcldg,
    mg_gstldg  manager.mg_gstldg,
    mg_internd manager.mg_internd,
    mg_internm manager.mg_internm,
    mg_interny manager.mg_interny,
    mg_max30da manager.mg_max30da,
    mg_max365d manager.mg_max365d,
    mg_maxendm manager.mg_maxendm,
    mg_maxendy manager.mg_maxendy,
    mg_maxnext manager.mg_maxnext,
    mg_maxtomo manager.mg_maxtomo,
    mg_mong1   manager.mg_mong1,
    mg_mong2   manager.mg_mong2,
    mg_mong3   manager.mg_mong3,
    mg_mong4   manager.mg_mong4,
    mg_mong5   manager.mg_mong5,
    mg_mong6   manager.mg_mong6,
    mg_mong7   manager.mg_mong7,
    mg_mong8   manager.mg_mong8,
    mg_mong9   manager.mg_mong9,
    mg_monp1   manager.mg_monp1,
    mg_monp2   manager.mg_monp2,
    mg_monp3   manager.mg_monp3,
    mg_monp4   manager.mg_monp4,
    mg_monp5   manager.mg_monp5,
    mg_monp6   manager.mg_monp6,
    mg_monp7   manager.mg_monp7,
    mg_monp8   manager.mg_monp8,
    mg_monp9   manager.mg_monp9,
    mg_mvat1   manager.mg_mvat1,
    mg_mvat2   manager.mg_mvat2,
    mg_mvat3   manager.mg_mvat3,
    mg_mvat4   manager.mg_mvat4,
    mg_mvat5   manager.mg_mvat5,
    mg_mvat6   manager.mg_mvat6,
    mg_mvat7   manager.mg_mvat7,
    mg_mvat8   manager.mg_mvat8,
    mg_mvat9   manager.mg_mvat9,
    mg_octopos manager.mg_octopos,
    mg_opt30da manager.mg_opt30da,
    mg_opt365d manager.mg_opt365d,
    mg_optcxl  manager.mg_optcxl,
    mg_optcxlm manager.mg_optcxlm,
    mg_optcxly manager.mg_optcxly,
    mg_optendm manager.mg_optendm,
    mg_optendy manager.mg_optendy,
    mg_optnext manager.mg_optnext,
    mg_opttomo manager.mg_opttomo,
    mg_pdoutd  manager.mg_pdoutd,
    mg_pdoutm  manager.mg_pdoutm,
    mg_pdouty  manager.mg_pdouty,
    mg_perarrm manager.mg_perarrm,
    mg_perarry manager.mg_perarry,
    mg_perdepm manager.mg_perdepm,
    mg_perdepy manager.mg_perdepy,
    mg_persarr manager.mg_persarr,
    mg_persdep manager.mg_persdep,
    mg_pic30da manager.mg_pic30da,
    mg_pic365d manager.mg_pic365d,
    mg_picendm manager.mg_picendm,
    mg_picendy manager.mg_picendy,
    mg_picnext manager.mg_picnext,
    mg_pictomo manager.mg_pictomo,
    mg_prduse  manager.mg_prduse,
    mg_prdusem manager.mg_prdusem,
    mg_prdusey manager.mg_prdusey,
    mg_rescxl  manager.mg_rescxl,
    mg_rescxlm manager.mg_rescxlm,
    mg_rescxly manager.mg_rescxly,
    mg_resnew  manager.mg_resnew,
    mg_resnewm manager.mg_resnewm,
    mg_resnewy manager.mg_resnewy,
    mg_resns   manager.mg_resns,
    mg_resnsm  manager.mg_resnsm,
    mg_resnsy  manager.mg_resnsy,
    mg_rmarrm  manager.mg_rmarrm,
    mg_rmarry  manager.mg_rmarry,
    mg_rmduse  manager.mg_rmduse,
    mg_rmdusem manager.mg_rmdusem,
    mg_rmdusey manager.mg_rmdusey,
    mg_rmoccm  manager.mg_rmoccm,
    mg_rmoccy  manager.mg_rmoccy,
    mg_rmooom  manager.mg_rmooom,
    mg_rmoooy  manager.mg_rmoooy,
    mg_rmoosm  manager.mg_rmoosm,
    mg_rmoosy  manager.mg_rmoosy,
    mg_roodepm manager.mg_roodepm,
    mg_roodepy manager.mg_roodepy,
    mg_roomarr manager.mg_roomarr,
    mg_roomavl manager.mg_roomavl,
    mg_roomavm manager.mg_roomavm,
    mg_roomavy manager.mg_roomavy,
    mg_roomdep manager.mg_roomdep,
    mg_roomocc manager.mg_roomocc,
    mg_roomooo manager.mg_roomooo,
    mg_roomoos manager.mg_roomoos,
    mg_ten30da manager.mg_ten30da,
    mg_ten365d manager.mg_ten365d,
    mg_tencxl  manager.mg_tencxl,
    mg_tencxlm manager.mg_tencxlm,
    mg_tencxly manager.mg_tencxly,
    mg_tenendm manager.mg_tenendm,
    mg_tenendy manager.mg_tenendy,
    mg_tennext manager.mg_tennext,
    mg_tentomo manager.mg_tentomo,
    mg_wai30da manager.mg_wai30da,
    mg_wai365d manager.mg_wai365d,
    mg_waiendm manager.mg_waiendm,
    mg_waiendy manager.mg_waiendy,
    mg_wainext manager.mg_wainext,
    mg_waitomo manager.mg_waitomo,
    mg_yeag1   manager.mg_yeag1,
    mg_yeag2   manager.mg_yeag2,
    mg_yeag3   manager.mg_yeag3,
    mg_yeag4   manager.mg_yeag4,
    mg_yeag5   manager.mg_yeag5,
    mg_yeag6   manager.mg_yeag6,
    mg_yeag7   manager.mg_yeag7,
    mg_yeag8   manager.mg_yeag8,
    mg_yeag9   manager.mg_yeag9,
    mg_yeap1   manager.mg_yeap1,
    mg_yeap2   manager.mg_yeap2,
    mg_yeap3   manager.mg_yeap3,
    mg_yeap4   manager.mg_yeap4,
    mg_yeap5   manager.mg_yeap5,
    mg_yeap6   manager.mg_yeap6,
    mg_yeap7   manager.mg_yeap7,
    mg_yeap8   manager.mg_yeap8,
    mg_yeap9   manager.mg_yeap9,
    mg_yvat1   manager.mg_yvat1,
    mg_yvat2   manager.mg_yvat2,
    mg_yvat3   manager.mg_yvat3,
    mg_yvat4   manager.mg_yvat4,
    mg_yvat5   manager.mg_yvat5,
    mg_yvat6   manager.mg_yvat6,
    mg_yvat7   manager.mg_yvat7,
    mg_yvat8   manager.mg_yvat8,
    mg_yvat9   manager.mg_yvat9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camenu AS caBase OF cit_ca.vcx
Alias = [camenu]
Tables = [menu]
KeyFieldList = [mn_sequ]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       mn_files,
       mn_func,
       mn_lang1,
       mn_lang10,
       mn_lang11,
       mn_lang2,
       mn_lang3,
       mn_lang4,
       mn_lang5,
       mn_lang6,
       mn_lang7,
       mn_lang8,
       mn_lang9,
       mn_sequ
    FROM menu
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    mn_files   C(100)  DEFAULT "",
    mn_func    C(100)  DEFAULT "",
    mn_lang1   C(30)   DEFAULT "",
    mn_lang10  C(30)   DEFAULT "",
    mn_lang11  C(30)   DEFAULT "",
    mn_lang2   C(30)   DEFAULT "",
    mn_lang3   C(30)   DEFAULT "",
    mn_lang4   C(30)   DEFAULT "",
    mn_lang5   C(30)   DEFAULT "",
    mn_lang6   C(30)   DEFAULT "",
    mn_lang7   C(30)   DEFAULT "",
    mn_lang8   C(30)   DEFAULT "",
    mn_lang9   C(30)   DEFAULT "",
    mn_sequ    N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mn_files,
    mn_func,
    mn_lang1,
    mn_lang10,
    mn_lang11,
    mn_lang2,
    mn_lang3,
    mn_lang4,
    mn_lang5,
    mn_lang6,
    mn_lang7,
    mn_lang8,
    mn_lang9,
    mn_sequ
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mn_files   menu.mn_files,
    mn_func    menu.mn_func,
    mn_lang1   menu.mn_lang1,
    mn_lang10  menu.mn_lang10,
    mn_lang11  menu.mn_lang11,
    mn_lang2   menu.mn_lang2,
    mn_lang3   menu.mn_lang3,
    mn_lang4   menu.mn_lang4,
    mn_lang5   menu.mn_lang5,
    mn_lang6   menu.mn_lang6,
    mn_lang7   menu.mn_lang7,
    mn_lang8   menu.mn_lang8,
    mn_lang9   menu.mn_lang9,
    mn_sequ    menu.mn_sequ
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camessages AS caBase OF cit_ca.vcx
Alias = [camessages]
Tables = [messages]
KeyFieldList = [ms_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ms_2userid,
       ms_code,
       ms_hotcode,
       ms_id,
       ms_station,
       ms_text,
       ms_time,
       ms_userid
    FROM messages
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ms_2userid C(10)   DEFAULT "",
    ms_code    I       DEFAULT 0,
    ms_hotcode C(10)   DEFAULT "",
    ms_id      N(10,0) DEFAULT 0,
    ms_station C(15)   DEFAULT "",
    ms_text    C(254)  DEFAULT "",
    ms_time    T       DEFAULT {},
    ms_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ms_2userid,
    ms_code,
    ms_hotcode,
    ms_id,
    ms_station,
    ms_text,
    ms_time,
    ms_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ms_2userid messages.ms_2userid,
    ms_code    messages.ms_code,
    ms_hotcode messages.ms_hotcode,
    ms_id      messages.ms_id,
    ms_station messages.ms_station,
    ms_text    messages.ms_text,
    ms_time    messages.ms_time,
    ms_userid  messages.ms_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camngbuild AS caBase OF cit_ca.vcx
Alias = [camngbuild]
Tables = [mngbuild]
KeyFieldList = [mg_date,mg_buildng]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       mg_all30da,
       mg_all365d,
       mg_allendm,
       mg_allendy,
       mg_allnext,
       mg_alltomo,
       mg_arrival,
       mg_bdoccm,
       mg_bdoccy,
       mg_bdooom,
       mg_bdoooy,
       mg_bdoosm,
       mg_bdoosy,
       mg_bedavl,
       mg_bedavlm,
       mg_bedavly,
       mg_bedocc,
       mg_bedooo,
       mg_bedoos,
       mg_buildng,
       mg_cldg,
       mg_cldgcrd,
       mg_cldgdeb,
       mg_compprd,
       mg_compprm,
       mg_comppry,
       mg_comprmd,
       mg_comprmm,
       mg_comprmy,
       mg_cxllate,
       mg_cxllatm,
       mg_cxllaty,
       mg_date,
       mg_dayg1,
       mg_dayg2,
       mg_dayg3,
       mg_dayg4,
       mg_dayg5,
       mg_dayg6,
       mg_dayg7,
       mg_dayg8,
       mg_dayg9,
       mg_dayp1,
       mg_dayp2,
       mg_dayp3,
       mg_dayp4,
       mg_dayp5,
       mg_dayp6,
       mg_dayp7,
       mg_dayp8,
       mg_dayp9,
       mg_def30da,
       mg_def365d,
       mg_defendm,
       mg_defendy,
       mg_defnext,
       mg_deftomo,
       mg_departu,
       mg_dldg,
       mg_dldgcrd,
       mg_dldgdeb,
       mg_dvat1,
       mg_dvat2,
       mg_dvat3,
       mg_dvat4,
       mg_dvat5,
       mg_dvat6,
       mg_dvat7,
       mg_dvat8,
       mg_dvat9,
       mg_gcertd,
       mg_gcertm,
       mg_gcerty,
       mg_gcldg,
       mg_gstldg,
       mg_internd,
       mg_internm,
       mg_interny,
       mg_max30da,
       mg_max365d,
       mg_maxendm,
       mg_maxendy,
       mg_maxnext,
       mg_maxtomo,
       mg_mngbid,
       mg_mong1,
       mg_mong2,
       mg_mong3,
       mg_mong4,
       mg_mong5,
       mg_mong6,
       mg_mong7,
       mg_mong8,
       mg_mong9,
       mg_monp1,
       mg_monp2,
       mg_monp3,
       mg_monp4,
       mg_monp5,
       mg_monp6,
       mg_monp7,
       mg_monp8,
       mg_monp9,
       mg_mvat1,
       mg_mvat2,
       mg_mvat3,
       mg_mvat4,
       mg_mvat5,
       mg_mvat6,
       mg_mvat7,
       mg_mvat8,
       mg_mvat9,
       mg_octopos,
       mg_opt30da,
       mg_opt365d,
       mg_optcxl,
       mg_optcxlm,
       mg_optcxly,
       mg_optendm,
       mg_optendy,
       mg_optnext,
       mg_opttomo,
       mg_pdoutd,
       mg_pdoutm,
       mg_pdouty,
       mg_perarrm,
       mg_perarry,
       mg_perdepm,
       mg_perdepy,
       mg_persarr,
       mg_persdep,
       mg_pic30da,
       mg_pic365d,
       mg_picendm,
       mg_picendy,
       mg_picnext,
       mg_pictomo,
       mg_prduse,
       mg_prdusem,
       mg_prdusey,
       mg_rescxl,
       mg_rescxlm,
       mg_rescxly,
       mg_resnew,
       mg_resnewm,
       mg_resnewy,
       mg_resns,
       mg_resnsm,
       mg_resnsy,
       mg_rmarrm,
       mg_rmarry,
       mg_rmduse,
       mg_rmdusem,
       mg_rmdusey,
       mg_rmoccm,
       mg_rmoccy,
       mg_rmooom,
       mg_rmoooy,
       mg_rmoosm,
       mg_rmoosy,
       mg_roodepm,
       mg_roodepy,
       mg_roomarr,
       mg_roomavl,
       mg_roomavm,
       mg_roomavy,
       mg_roomdep,
       mg_roomocc,
       mg_roomooo,
       mg_roomoos,
       mg_ten30da,
       mg_ten365d,
       mg_tencxl,
       mg_tencxlm,
       mg_tencxly,
       mg_tenendm,
       mg_tenendy,
       mg_tennext,
       mg_tentomo,
       mg_wai30da,
       mg_wai365d,
       mg_waiendm,
       mg_waiendy,
       mg_wainext,
       mg_waitomo,
       mg_yeag1,
       mg_yeag2,
       mg_yeag3,
       mg_yeag4,
       mg_yeag5,
       mg_yeag6,
       mg_yeag7,
       mg_yeag8,
       mg_yeag9,
       mg_yeap1,
       mg_yeap2,
       mg_yeap3,
       mg_yeap4,
       mg_yeap5,
       mg_yeap6,
       mg_yeap7,
       mg_yeap8,
       mg_yeap9,
       mg_yvat1,
       mg_yvat2,
       mg_yvat3,
       mg_yvat4,
       mg_yvat5,
       mg_yvat6,
       mg_yvat7,
       mg_yvat8,
       mg_yvat9
    FROM mngbuild
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_all30da N(10,0) DEFAULT 0,
    mg_all365d N(10,0) DEFAULT 0,
    mg_allendm N(10,0) DEFAULT 0,
    mg_allendy N(10,0) DEFAULT 0,
    mg_allnext N(10,0) DEFAULT 0,
    mg_alltomo N(10,0) DEFAULT 0,
    mg_arrival N(10,0) DEFAULT 0,
    mg_bdoccm  N(10,0) DEFAULT 0,
    mg_bdoccy  N(10,0) DEFAULT 0,
    mg_bdooom  N(10,0) DEFAULT 0,
    mg_bdoooy  N(10,0) DEFAULT 0,
    mg_bdoosm  N(10,0) DEFAULT 0,
    mg_bdoosy  N(10,0) DEFAULT 0,
    mg_bedavl  N(10,0) DEFAULT 0,
    mg_bedavlm N(10,0) DEFAULT 0,
    mg_bedavly N(10,0) DEFAULT 0,
    mg_bedocc  N(10,0) DEFAULT 0,
    mg_bedooo  N(10,0) DEFAULT 0,
    mg_bedoos  N(10,0) DEFAULT 0,
    mg_buildng C(3)    DEFAULT "",
    mg_cldg    B(2)    DEFAULT 0,
    mg_cldgcrd B(2)    DEFAULT 0,
    mg_cldgdeb B(2)    DEFAULT 0,
    mg_compprd N(10,0) DEFAULT 0,
    mg_compprm N(10,0) DEFAULT 0,
    mg_comppry N(10,0) DEFAULT 0,
    mg_comprmd N(10,0) DEFAULT 0,
    mg_comprmm N(10,0) DEFAULT 0,
    mg_comprmy N(10,0) DEFAULT 0,
    mg_cxllate N(10,0) DEFAULT 0,
    mg_cxllatm N(10,0) DEFAULT 0,
    mg_cxllaty N(10,0) DEFAULT 0,
    mg_date    D       DEFAULT {},
    mg_dayg1   B(2)    DEFAULT 0,
    mg_dayg2   B(2)    DEFAULT 0,
    mg_dayg3   B(2)    DEFAULT 0,
    mg_dayg4   B(2)    DEFAULT 0,
    mg_dayg5   B(2)    DEFAULT 0,
    mg_dayg6   B(2)    DEFAULT 0,
    mg_dayg7   B(2)    DEFAULT 0,
    mg_dayg8   B(2)    DEFAULT 0,
    mg_dayg9   B(2)    DEFAULT 0,
    mg_dayp1   B(2)    DEFAULT 0,
    mg_dayp2   B(2)    DEFAULT 0,
    mg_dayp3   B(2)    DEFAULT 0,
    mg_dayp4   B(2)    DEFAULT 0,
    mg_dayp5   B(2)    DEFAULT 0,
    mg_dayp6   B(2)    DEFAULT 0,
    mg_dayp7   B(2)    DEFAULT 0,
    mg_dayp8   B(2)    DEFAULT 0,
    mg_dayp9   B(2)    DEFAULT 0,
    mg_def30da N(10,0) DEFAULT 0,
    mg_def365d N(10,0) DEFAULT 0,
    mg_defendm N(10,0) DEFAULT 0,
    mg_defendy N(10,0) DEFAULT 0,
    mg_defnext N(10,0) DEFAULT 0,
    mg_deftomo N(10,0) DEFAULT 0,
    mg_departu N(10,0) DEFAULT 0,
    mg_dldg    B(2)    DEFAULT 0,
    mg_dldgcrd B(2)    DEFAULT 0,
    mg_dldgdeb B(2)    DEFAULT 0,
    mg_dvat1   B(6)    DEFAULT 0,
    mg_dvat2   B(6)    DEFAULT 0,
    mg_dvat3   B(6)    DEFAULT 0,
    mg_dvat4   B(6)    DEFAULT 0,
    mg_dvat5   B(6)    DEFAULT 0,
    mg_dvat6   B(6)    DEFAULT 0,
    mg_dvat7   B(6)    DEFAULT 0,
    mg_dvat8   B(6)    DEFAULT 0,
    mg_dvat9   B(6)    DEFAULT 0,
    mg_gcertd  B(2)    DEFAULT 0,
    mg_gcertm  B(2)    DEFAULT 0,
    mg_gcerty  B(2)    DEFAULT 0,
    mg_gcldg   B(2)    DEFAULT 0,
    mg_gstldg  B(2)    DEFAULT 0,
    mg_internd B(2)    DEFAULT 0,
    mg_internm B(2)    DEFAULT 0,
    mg_interny B(2)    DEFAULT 0,
    mg_max30da N(10,0) DEFAULT 0,
    mg_max365d N(10,0) DEFAULT 0,
    mg_maxendm N(10,0) DEFAULT 0,
    mg_maxendy N(10,0) DEFAULT 0,
    mg_maxnext N(10,0) DEFAULT 0,
    mg_maxtomo N(10,0) DEFAULT 0,
    mg_mngbid  C(11)   DEFAULT "",
    mg_mong1   B(2)    DEFAULT 0,
    mg_mong2   B(2)    DEFAULT 0,
    mg_mong3   B(2)    DEFAULT 0,
    mg_mong4   B(2)    DEFAULT 0,
    mg_mong5   B(2)    DEFAULT 0,
    mg_mong6   B(2)    DEFAULT 0,
    mg_mong7   B(2)    DEFAULT 0,
    mg_mong8   B(2)    DEFAULT 0,
    mg_mong9   B(2)    DEFAULT 0,
    mg_monp1   B(2)    DEFAULT 0,
    mg_monp2   B(2)    DEFAULT 0,
    mg_monp3   B(2)    DEFAULT 0,
    mg_monp4   B(2)    DEFAULT 0,
    mg_monp5   B(2)    DEFAULT 0,
    mg_monp6   B(2)    DEFAULT 0,
    mg_monp7   B(2)    DEFAULT 0,
    mg_monp8   B(2)    DEFAULT 0,
    mg_monp9   B(2)    DEFAULT 0,
    mg_mvat1   B(6)    DEFAULT 0,
    mg_mvat2   B(6)    DEFAULT 0,
    mg_mvat3   B(6)    DEFAULT 0,
    mg_mvat4   B(6)    DEFAULT 0,
    mg_mvat5   B(6)    DEFAULT 0,
    mg_mvat6   B(6)    DEFAULT 0,
    mg_mvat7   B(6)    DEFAULT 0,
    mg_mvat8   B(6)    DEFAULT 0,
    mg_mvat9   B(6)    DEFAULT 0,
    mg_octopos L       DEFAULT .F.,
    mg_opt30da N(10,0) DEFAULT 0,
    mg_opt365d N(10,0) DEFAULT 0,
    mg_optcxl  N(10,0) DEFAULT 0,
    mg_optcxlm N(10,0) DEFAULT 0,
    mg_optcxly N(10,0) DEFAULT 0,
    mg_optendm N(10,0) DEFAULT 0,
    mg_optendy N(10,0) DEFAULT 0,
    mg_optnext N(10,0) DEFAULT 0,
    mg_opttomo N(10,0) DEFAULT 0,
    mg_pdoutd  B(2)    DEFAULT 0,
    mg_pdoutm  B(2)    DEFAULT 0,
    mg_pdouty  B(2)    DEFAULT 0,
    mg_perarrm N(10,0) DEFAULT 0,
    mg_perarry N(10,0) DEFAULT 0,
    mg_perdepm N(10,0) DEFAULT 0,
    mg_perdepy N(10,0) DEFAULT 0,
    mg_persarr N(10,0) DEFAULT 0,
    mg_persdep N(10,0) DEFAULT 0,
    mg_pic30da N(10,0) DEFAULT 0,
    mg_pic365d N(10,0) DEFAULT 0,
    mg_picendm N(10,0) DEFAULT 0,
    mg_picendy N(10,0) DEFAULT 0,
    mg_picnext N(10,0) DEFAULT 0,
    mg_pictomo N(10,0) DEFAULT 0,
    mg_prduse  N(10,0) DEFAULT 0,
    mg_prdusem N(10,0) DEFAULT 0,
    mg_prdusey N(10,0) DEFAULT 0,
    mg_rescxl  N(10,0) DEFAULT 0,
    mg_rescxlm N(10,0) DEFAULT 0,
    mg_rescxly N(10,0) DEFAULT 0,
    mg_resnew  N(10,0) DEFAULT 0,
    mg_resnewm N(10,0) DEFAULT 0,
    mg_resnewy N(10,0) DEFAULT 0,
    mg_resns   N(10,0) DEFAULT 0,
    mg_resnsm  N(10,0) DEFAULT 0,
    mg_resnsy  N(10,0) DEFAULT 0,
    mg_rmarrm  N(10,0) DEFAULT 0,
    mg_rmarry  N(10,0) DEFAULT 0,
    mg_rmduse  N(10,0) DEFAULT 0,
    mg_rmdusem N(10,0) DEFAULT 0,
    mg_rmdusey N(10,0) DEFAULT 0,
    mg_rmoccm  N(10,0) DEFAULT 0,
    mg_rmoccy  N(10,0) DEFAULT 0,
    mg_rmooom  N(10,0) DEFAULT 0,
    mg_rmoooy  N(10,0) DEFAULT 0,
    mg_rmoosm  N(10,0) DEFAULT 0,
    mg_rmoosy  N(10,0) DEFAULT 0,
    mg_roodepm N(10,0) DEFAULT 0,
    mg_roodepy N(10,0) DEFAULT 0,
    mg_roomarr N(10,0) DEFAULT 0,
    mg_roomavl N(10,0) DEFAULT 0,
    mg_roomavm N(10,0) DEFAULT 0,
    mg_roomavy N(10,0) DEFAULT 0,
    mg_roomdep N(10,0) DEFAULT 0,
    mg_roomocc N(10,0) DEFAULT 0,
    mg_roomooo N(10,0) DEFAULT 0,
    mg_roomoos N(10,0) DEFAULT 0,
    mg_ten30da N(10,0) DEFAULT 0,
    mg_ten365d N(10,0) DEFAULT 0,
    mg_tencxl  N(10,0) DEFAULT 0,
    mg_tencxlm N(10,0) DEFAULT 0,
    mg_tencxly N(10,0) DEFAULT 0,
    mg_tenendm N(10,0) DEFAULT 0,
    mg_tenendy N(10,0) DEFAULT 0,
    mg_tennext N(10,0) DEFAULT 0,
    mg_tentomo N(10,0) DEFAULT 0,
    mg_wai30da N(10,0) DEFAULT 0,
    mg_wai365d N(10,0) DEFAULT 0,
    mg_waiendm N(10,0) DEFAULT 0,
    mg_waiendy N(10,0) DEFAULT 0,
    mg_wainext N(10,0) DEFAULT 0,
    mg_waitomo N(10,0) DEFAULT 0,
    mg_yeag1   B(2)    DEFAULT 0,
    mg_yeag2   B(2)    DEFAULT 0,
    mg_yeag3   B(2)    DEFAULT 0,
    mg_yeag4   B(2)    DEFAULT 0,
    mg_yeag5   B(2)    DEFAULT 0,
    mg_yeag6   B(2)    DEFAULT 0,
    mg_yeag7   B(2)    DEFAULT 0,
    mg_yeag8   B(2)    DEFAULT 0,
    mg_yeag9   B(2)    DEFAULT 0,
    mg_yeap1   B(2)    DEFAULT 0,
    mg_yeap2   B(2)    DEFAULT 0,
    mg_yeap3   B(2)    DEFAULT 0,
    mg_yeap4   B(2)    DEFAULT 0,
    mg_yeap5   B(2)    DEFAULT 0,
    mg_yeap6   B(2)    DEFAULT 0,
    mg_yeap7   B(2)    DEFAULT 0,
    mg_yeap8   B(2)    DEFAULT 0,
    mg_yeap9   B(2)    DEFAULT 0,
    mg_yvat1   B(6)    DEFAULT 0,
    mg_yvat2   B(6)    DEFAULT 0,
    mg_yvat3   B(6)    DEFAULT 0,
    mg_yvat4   B(6)    DEFAULT 0,
    mg_yvat5   B(6)    DEFAULT 0,
    mg_yvat6   B(6)    DEFAULT 0,
    mg_yvat7   B(6)    DEFAULT 0,
    mg_yvat8   B(6)    DEFAULT 0,
    mg_yvat9   B(6)    DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_all30da,
    mg_all365d,
    mg_allendm,
    mg_allendy,
    mg_allnext,
    mg_alltomo,
    mg_arrival,
    mg_bdoccm,
    mg_bdoccy,
    mg_bdooom,
    mg_bdoooy,
    mg_bdoosm,
    mg_bdoosy,
    mg_bedavl,
    mg_bedavlm,
    mg_bedavly,
    mg_bedocc,
    mg_bedooo,
    mg_bedoos,
    mg_buildng,
    mg_cldg,
    mg_cldgcrd,
    mg_cldgdeb,
    mg_compprd,
    mg_compprm,
    mg_comppry,
    mg_comprmd,
    mg_comprmm,
    mg_comprmy,
    mg_cxllate,
    mg_cxllatm,
    mg_cxllaty,
    mg_date,
    mg_dayg1,
    mg_dayg2,
    mg_dayg3,
    mg_dayg4,
    mg_dayg5,
    mg_dayg6,
    mg_dayg7,
    mg_dayg8,
    mg_dayg9,
    mg_dayp1,
    mg_dayp2,
    mg_dayp3,
    mg_dayp4,
    mg_dayp5,
    mg_dayp6,
    mg_dayp7,
    mg_dayp8,
    mg_dayp9,
    mg_def30da,
    mg_def365d,
    mg_defendm,
    mg_defendy,
    mg_defnext,
    mg_deftomo,
    mg_departu,
    mg_dldg,
    mg_dldgcrd,
    mg_dldgdeb,
    mg_dvat1,
    mg_dvat2,
    mg_dvat3,
    mg_dvat4,
    mg_dvat5,
    mg_dvat6,
    mg_dvat7,
    mg_dvat8,
    mg_dvat9,
    mg_gcertd,
    mg_gcertm,
    mg_gcerty,
    mg_gcldg,
    mg_gstldg,
    mg_internd,
    mg_internm,
    mg_interny,
    mg_max30da,
    mg_max365d,
    mg_maxendm,
    mg_maxendy,
    mg_maxnext,
    mg_maxtomo,
    mg_mngbid,
    mg_mong1,
    mg_mong2,
    mg_mong3,
    mg_mong4,
    mg_mong5,
    mg_mong6,
    mg_mong7,
    mg_mong8,
    mg_mong9,
    mg_monp1,
    mg_monp2,
    mg_monp3,
    mg_monp4,
    mg_monp5,
    mg_monp6,
    mg_monp7,
    mg_monp8,
    mg_monp9,
    mg_mvat1,
    mg_mvat2,
    mg_mvat3,
    mg_mvat4,
    mg_mvat5,
    mg_mvat6,
    mg_mvat7,
    mg_mvat8,
    mg_mvat9,
    mg_octopos,
    mg_opt30da,
    mg_opt365d,
    mg_optcxl,
    mg_optcxlm,
    mg_optcxly,
    mg_optendm,
    mg_optendy,
    mg_optnext,
    mg_opttomo,
    mg_pdoutd,
    mg_pdoutm,
    mg_pdouty,
    mg_perarrm,
    mg_perarry,
    mg_perdepm,
    mg_perdepy,
    mg_persarr,
    mg_persdep,
    mg_pic30da,
    mg_pic365d,
    mg_picendm,
    mg_picendy,
    mg_picnext,
    mg_pictomo,
    mg_prduse,
    mg_prdusem,
    mg_prdusey,
    mg_rescxl,
    mg_rescxlm,
    mg_rescxly,
    mg_resnew,
    mg_resnewm,
    mg_resnewy,
    mg_resns,
    mg_resnsm,
    mg_resnsy,
    mg_rmarrm,
    mg_rmarry,
    mg_rmduse,
    mg_rmdusem,
    mg_rmdusey,
    mg_rmoccm,
    mg_rmoccy,
    mg_rmooom,
    mg_rmoooy,
    mg_rmoosm,
    mg_rmoosy,
    mg_roodepm,
    mg_roodepy,
    mg_roomarr,
    mg_roomavl,
    mg_roomavm,
    mg_roomavy,
    mg_roomdep,
    mg_roomocc,
    mg_roomooo,
    mg_roomoos,
    mg_ten30da,
    mg_ten365d,
    mg_tencxl,
    mg_tencxlm,
    mg_tencxly,
    mg_tenendm,
    mg_tenendy,
    mg_tennext,
    mg_tentomo,
    mg_wai30da,
    mg_wai365d,
    mg_waiendm,
    mg_waiendy,
    mg_wainext,
    mg_waitomo,
    mg_yeag1,
    mg_yeag2,
    mg_yeag3,
    mg_yeag4,
    mg_yeag5,
    mg_yeag6,
    mg_yeag7,
    mg_yeag8,
    mg_yeag9,
    mg_yeap1,
    mg_yeap2,
    mg_yeap3,
    mg_yeap4,
    mg_yeap5,
    mg_yeap6,
    mg_yeap7,
    mg_yeap8,
    mg_yeap9,
    mg_yvat1,
    mg_yvat2,
    mg_yvat3,
    mg_yvat4,
    mg_yvat5,
    mg_yvat6,
    mg_yvat7,
    mg_yvat8,
    mg_yvat9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_all30da mngbuild.mg_all30da,
    mg_all365d mngbuild.mg_all365d,
    mg_allendm mngbuild.mg_allendm,
    mg_allendy mngbuild.mg_allendy,
    mg_allnext mngbuild.mg_allnext,
    mg_alltomo mngbuild.mg_alltomo,
    mg_arrival mngbuild.mg_arrival,
    mg_bdoccm  mngbuild.mg_bdoccm,
    mg_bdoccy  mngbuild.mg_bdoccy,
    mg_bdooom  mngbuild.mg_bdooom,
    mg_bdoooy  mngbuild.mg_bdoooy,
    mg_bdoosm  mngbuild.mg_bdoosm,
    mg_bdoosy  mngbuild.mg_bdoosy,
    mg_bedavl  mngbuild.mg_bedavl,
    mg_bedavlm mngbuild.mg_bedavlm,
    mg_bedavly mngbuild.mg_bedavly,
    mg_bedocc  mngbuild.mg_bedocc,
    mg_bedooo  mngbuild.mg_bedooo,
    mg_bedoos  mngbuild.mg_bedoos,
    mg_buildng mngbuild.mg_buildng,
    mg_cldg    mngbuild.mg_cldg,
    mg_cldgcrd mngbuild.mg_cldgcrd,
    mg_cldgdeb mngbuild.mg_cldgdeb,
    mg_compprd mngbuild.mg_compprd,
    mg_compprm mngbuild.mg_compprm,
    mg_comppry mngbuild.mg_comppry,
    mg_comprmd mngbuild.mg_comprmd,
    mg_comprmm mngbuild.mg_comprmm,
    mg_comprmy mngbuild.mg_comprmy,
    mg_cxllate mngbuild.mg_cxllate,
    mg_cxllatm mngbuild.mg_cxllatm,
    mg_cxllaty mngbuild.mg_cxllaty,
    mg_date    mngbuild.mg_date,
    mg_dayg1   mngbuild.mg_dayg1,
    mg_dayg2   mngbuild.mg_dayg2,
    mg_dayg3   mngbuild.mg_dayg3,
    mg_dayg4   mngbuild.mg_dayg4,
    mg_dayg5   mngbuild.mg_dayg5,
    mg_dayg6   mngbuild.mg_dayg6,
    mg_dayg7   mngbuild.mg_dayg7,
    mg_dayg8   mngbuild.mg_dayg8,
    mg_dayg9   mngbuild.mg_dayg9,
    mg_dayp1   mngbuild.mg_dayp1,
    mg_dayp2   mngbuild.mg_dayp2,
    mg_dayp3   mngbuild.mg_dayp3,
    mg_dayp4   mngbuild.mg_dayp4,
    mg_dayp5   mngbuild.mg_dayp5,
    mg_dayp6   mngbuild.mg_dayp6,
    mg_dayp7   mngbuild.mg_dayp7,
    mg_dayp8   mngbuild.mg_dayp8,
    mg_dayp9   mngbuild.mg_dayp9,
    mg_def30da mngbuild.mg_def30da,
    mg_def365d mngbuild.mg_def365d,
    mg_defendm mngbuild.mg_defendm,
    mg_defendy mngbuild.mg_defendy,
    mg_defnext mngbuild.mg_defnext,
    mg_deftomo mngbuild.mg_deftomo,
    mg_departu mngbuild.mg_departu,
    mg_dldg    mngbuild.mg_dldg,
    mg_dldgcrd mngbuild.mg_dldgcrd,
    mg_dldgdeb mngbuild.mg_dldgdeb,
    mg_dvat1   mngbuild.mg_dvat1,
    mg_dvat2   mngbuild.mg_dvat2,
    mg_dvat3   mngbuild.mg_dvat3,
    mg_dvat4   mngbuild.mg_dvat4,
    mg_dvat5   mngbuild.mg_dvat5,
    mg_dvat6   mngbuild.mg_dvat6,
    mg_dvat7   mngbuild.mg_dvat7,
    mg_dvat8   mngbuild.mg_dvat8,
    mg_dvat9   mngbuild.mg_dvat9,
    mg_gcertd  mngbuild.mg_gcertd,
    mg_gcertm  mngbuild.mg_gcertm,
    mg_gcerty  mngbuild.mg_gcerty,
    mg_gcldg   mngbuild.mg_gcldg,
    mg_gstldg  mngbuild.mg_gstldg,
    mg_internd mngbuild.mg_internd,
    mg_internm mngbuild.mg_internm,
    mg_interny mngbuild.mg_interny,
    mg_max30da mngbuild.mg_max30da,
    mg_max365d mngbuild.mg_max365d,
    mg_maxendm mngbuild.mg_maxendm,
    mg_maxendy mngbuild.mg_maxendy,
    mg_maxnext mngbuild.mg_maxnext,
    mg_maxtomo mngbuild.mg_maxtomo,
    mg_mngbid  mngbuild.mg_mngbid,
    mg_mong1   mngbuild.mg_mong1,
    mg_mong2   mngbuild.mg_mong2,
    mg_mong3   mngbuild.mg_mong3,
    mg_mong4   mngbuild.mg_mong4,
    mg_mong5   mngbuild.mg_mong5,
    mg_mong6   mngbuild.mg_mong6,
    mg_mong7   mngbuild.mg_mong7,
    mg_mong8   mngbuild.mg_mong8,
    mg_mong9   mngbuild.mg_mong9,
    mg_monp1   mngbuild.mg_monp1,
    mg_monp2   mngbuild.mg_monp2,
    mg_monp3   mngbuild.mg_monp3,
    mg_monp4   mngbuild.mg_monp4,
    mg_monp5   mngbuild.mg_monp5,
    mg_monp6   mngbuild.mg_monp6,
    mg_monp7   mngbuild.mg_monp7,
    mg_monp8   mngbuild.mg_monp8,
    mg_monp9   mngbuild.mg_monp9,
    mg_mvat1   mngbuild.mg_mvat1,
    mg_mvat2   mngbuild.mg_mvat2,
    mg_mvat3   mngbuild.mg_mvat3,
    mg_mvat4   mngbuild.mg_mvat4,
    mg_mvat5   mngbuild.mg_mvat5,
    mg_mvat6   mngbuild.mg_mvat6,
    mg_mvat7   mngbuild.mg_mvat7,
    mg_mvat8   mngbuild.mg_mvat8,
    mg_mvat9   mngbuild.mg_mvat9,
    mg_octopos mngbuild.mg_octopos,
    mg_opt30da mngbuild.mg_opt30da,
    mg_opt365d mngbuild.mg_opt365d,
    mg_optcxl  mngbuild.mg_optcxl,
    mg_optcxlm mngbuild.mg_optcxlm,
    mg_optcxly mngbuild.mg_optcxly,
    mg_optendm mngbuild.mg_optendm,
    mg_optendy mngbuild.mg_optendy,
    mg_optnext mngbuild.mg_optnext,
    mg_opttomo mngbuild.mg_opttomo,
    mg_pdoutd  mngbuild.mg_pdoutd,
    mg_pdoutm  mngbuild.mg_pdoutm,
    mg_pdouty  mngbuild.mg_pdouty,
    mg_perarrm mngbuild.mg_perarrm,
    mg_perarry mngbuild.mg_perarry,
    mg_perdepm mngbuild.mg_perdepm,
    mg_perdepy mngbuild.mg_perdepy,
    mg_persarr mngbuild.mg_persarr,
    mg_persdep mngbuild.mg_persdep,
    mg_pic30da mngbuild.mg_pic30da,
    mg_pic365d mngbuild.mg_pic365d,
    mg_picendm mngbuild.mg_picendm,
    mg_picendy mngbuild.mg_picendy,
    mg_picnext mngbuild.mg_picnext,
    mg_pictomo mngbuild.mg_pictomo,
    mg_prduse  mngbuild.mg_prduse,
    mg_prdusem mngbuild.mg_prdusem,
    mg_prdusey mngbuild.mg_prdusey,
    mg_rescxl  mngbuild.mg_rescxl,
    mg_rescxlm mngbuild.mg_rescxlm,
    mg_rescxly mngbuild.mg_rescxly,
    mg_resnew  mngbuild.mg_resnew,
    mg_resnewm mngbuild.mg_resnewm,
    mg_resnewy mngbuild.mg_resnewy,
    mg_resns   mngbuild.mg_resns,
    mg_resnsm  mngbuild.mg_resnsm,
    mg_resnsy  mngbuild.mg_resnsy,
    mg_rmarrm  mngbuild.mg_rmarrm,
    mg_rmarry  mngbuild.mg_rmarry,
    mg_rmduse  mngbuild.mg_rmduse,
    mg_rmdusem mngbuild.mg_rmdusem,
    mg_rmdusey mngbuild.mg_rmdusey,
    mg_rmoccm  mngbuild.mg_rmoccm,
    mg_rmoccy  mngbuild.mg_rmoccy,
    mg_rmooom  mngbuild.mg_rmooom,
    mg_rmoooy  mngbuild.mg_rmoooy,
    mg_rmoosm  mngbuild.mg_rmoosm,
    mg_rmoosy  mngbuild.mg_rmoosy,
    mg_roodepm mngbuild.mg_roodepm,
    mg_roodepy mngbuild.mg_roodepy,
    mg_roomarr mngbuild.mg_roomarr,
    mg_roomavl mngbuild.mg_roomavl,
    mg_roomavm mngbuild.mg_roomavm,
    mg_roomavy mngbuild.mg_roomavy,
    mg_roomdep mngbuild.mg_roomdep,
    mg_roomocc mngbuild.mg_roomocc,
    mg_roomooo mngbuild.mg_roomooo,
    mg_roomoos mngbuild.mg_roomoos,
    mg_ten30da mngbuild.mg_ten30da,
    mg_ten365d mngbuild.mg_ten365d,
    mg_tencxl  mngbuild.mg_tencxl,
    mg_tencxlm mngbuild.mg_tencxlm,
    mg_tencxly mngbuild.mg_tencxly,
    mg_tenendm mngbuild.mg_tenendm,
    mg_tenendy mngbuild.mg_tenendy,
    mg_tennext mngbuild.mg_tennext,
    mg_tentomo mngbuild.mg_tentomo,
    mg_wai30da mngbuild.mg_wai30da,
    mg_wai365d mngbuild.mg_wai365d,
    mg_waiendm mngbuild.mg_waiendm,
    mg_waiendy mngbuild.mg_waiendy,
    mg_wainext mngbuild.mg_wainext,
    mg_waitomo mngbuild.mg_waitomo,
    mg_yeag1   mngbuild.mg_yeag1,
    mg_yeag2   mngbuild.mg_yeag2,
    mg_yeag3   mngbuild.mg_yeag3,
    mg_yeag4   mngbuild.mg_yeag4,
    mg_yeag5   mngbuild.mg_yeag5,
    mg_yeag6   mngbuild.mg_yeag6,
    mg_yeag7   mngbuild.mg_yeag7,
    mg_yeag8   mngbuild.mg_yeag8,
    mg_yeag9   mngbuild.mg_yeag9,
    mg_yeap1   mngbuild.mg_yeap1,
    mg_yeap2   mngbuild.mg_yeap2,
    mg_yeap3   mngbuild.mg_yeap3,
    mg_yeap4   mngbuild.mg_yeap4,
    mg_yeap5   mngbuild.mg_yeap5,
    mg_yeap6   mngbuild.mg_yeap6,
    mg_yeap7   mngbuild.mg_yeap7,
    mg_yeap8   mngbuild.mg_yeap8,
    mg_yeap9   mngbuild.mg_yeap9,
    mg_yvat1   mngbuild.mg_yvat1,
    mg_yvat2   mngbuild.mg_yvat2,
    mg_yvat3   mngbuild.mg_yvat3,
    mg_yvat4   mngbuild.mg_yvat4,
    mg_yvat5   mngbuild.mg_yvat5,
    mg_yvat6   mngbuild.mg_yvat6,
    mg_yvat7   mngbuild.mg_yvat7,
    mg_yvat8   mngbuild.mg_yvat8,
    mg_yvat9   mngbuild.mg_yvat9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caobergrp AS caBase OF cit_ca.vcx
Alias = [caobergrp]
Tables = [obergrp]
KeyFieldList = [og_nummer]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       og_nummer,
       og_text
    FROM obergrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    og_nummer  N(3,0)  DEFAULT 0,
    og_text    C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    og_nummer,
    og_text
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    og_nummer  obergrp.og_nummer,
    og_text    obergrp.og_text
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caorstat AS caBase OF cit_ca.vcx
Alias = [caorstat]
Tables = [orstat]
KeyFieldList = [or_label,or_code,or_date]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       or_0arrpax,
       or_0arrrms,
       or_0daypax,
       or_0dayrms,
       or_0deppax,
       or_0deprms,
       or_0pax,
       or_0rev0,
       or_0rev1,
       or_0rev2,
       or_0rev3,
       or_0rev4,
       or_0rev5,
       or_0rev6,
       or_0rev7,
       or_0rev8,
       or_0rev9,
       or_0revx,
       or_0rms,
       or_0vat0,
       or_0vat1,
       or_0vat2,
       or_0vat3,
       or_0vat4,
       or_0vat5,
       or_0vat6,
       or_0vat7,
       or_0vat8,
       or_0vat9,
       or_0vatx,
       or_carrpax,
       or_carrrms,
       or_cdaypax,
       or_cdayrms,
       or_cdeppax,
       or_cdeprms,
       or_code,
       or_cpax,
       or_crev0,
       or_crev1,
       or_crev2,
       or_crev3,
       or_crev4,
       or_crev5,
       or_crev6,
       or_crev7,
       or_crev8,
       or_crev9,
       or_crevx,
       or_crms,
       or_cvat0,
       or_cvat1,
       or_cvat2,
       or_cvat3,
       or_cvat4,
       or_cvat5,
       or_cvat6,
       or_cvat7,
       or_cvat8,
       or_cvat9,
       or_cvatx,
       or_date,
       or_label
    FROM orstat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_0arrpax N(9,0)  DEFAULT 0,
    or_0arrrms N(7,0)  DEFAULT 0,
    or_0daypax N(9,0)  DEFAULT 0,
    or_0dayrms N(7,0)  DEFAULT 0,
    or_0deppax N(9,0)  DEFAULT 0,
    or_0deprms N(7,0)  DEFAULT 0,
    or_0pax    N(9,0)  DEFAULT 0,
    or_0rev0   N(20,2) DEFAULT 0,
    or_0rev1   N(20,2) DEFAULT 0,
    or_0rev2   N(20,2) DEFAULT 0,
    or_0rev3   N(20,2) DEFAULT 0,
    or_0rev4   N(20,2) DEFAULT 0,
    or_0rev5   N(20,2) DEFAULT 0,
    or_0rev6   N(20,2) DEFAULT 0,
    or_0rev7   N(20,2) DEFAULT 0,
    or_0rev8   N(20,2) DEFAULT 0,
    or_0rev9   N(20,2) DEFAULT 0,
    or_0revx   N(20,2) DEFAULT 0,
    or_0rms    N(7,0)  DEFAULT 0,
    or_0vat0   N(20,6) DEFAULT 0,
    or_0vat1   N(20,6) DEFAULT 0,
    or_0vat2   N(20,6) DEFAULT 0,
    or_0vat3   N(20,6) DEFAULT 0,
    or_0vat4   N(20,6) DEFAULT 0,
    or_0vat5   N(20,6) DEFAULT 0,
    or_0vat6   N(20,6) DEFAULT 0,
    or_0vat7   N(20,6) DEFAULT 0,
    or_0vat8   N(20,6) DEFAULT 0,
    or_0vat9   N(20,6) DEFAULT 0,
    or_0vatx   N(20,6) DEFAULT 0,
    or_carrpax N(9,0)  DEFAULT 0,
    or_carrrms N(7,0)  DEFAULT 0,
    or_cdaypax N(9,0)  DEFAULT 0,
    or_cdayrms N(7,0)  DEFAULT 0,
    or_cdeppax N(9,0)  DEFAULT 0,
    or_cdeprms N(7,0)  DEFAULT 0,
    or_code    C(10)   DEFAULT "",
    or_cpax    N(9,0)  DEFAULT 0,
    or_crev0   N(20,2) DEFAULT 0,
    or_crev1   N(20,2) DEFAULT 0,
    or_crev2   N(20,2) DEFAULT 0,
    or_crev3   N(20,2) DEFAULT 0,
    or_crev4   N(20,2) DEFAULT 0,
    or_crev5   N(20,2) DEFAULT 0,
    or_crev6   N(20,2) DEFAULT 0,
    or_crev7   N(20,2) DEFAULT 0,
    or_crev8   N(20,2) DEFAULT 0,
    or_crev9   N(20,2) DEFAULT 0,
    or_crevx   N(20,2) DEFAULT 0,
    or_crms    N(7,0)  DEFAULT 0,
    or_cvat0   N(20,6) DEFAULT 0,
    or_cvat1   N(20,6) DEFAULT 0,
    or_cvat2   N(20,6) DEFAULT 0,
    or_cvat3   N(20,6) DEFAULT 0,
    or_cvat4   N(20,6) DEFAULT 0,
    or_cvat5   N(20,6) DEFAULT 0,
    or_cvat6   N(20,6) DEFAULT 0,
    or_cvat7   N(20,6) DEFAULT 0,
    or_cvat8   N(20,6) DEFAULT 0,
    or_cvat9   N(20,6) DEFAULT 0,
    or_cvatx   N(20,6) DEFAULT 0,
    or_date    D       DEFAULT {},
    or_label   C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_0arrpax,
    or_0arrrms,
    or_0daypax,
    or_0dayrms,
    or_0deppax,
    or_0deprms,
    or_0pax,
    or_0rev0,
    or_0rev1,
    or_0rev2,
    or_0rev3,
    or_0rev4,
    or_0rev5,
    or_0rev6,
    or_0rev7,
    or_0rev8,
    or_0rev9,
    or_0revx,
    or_0rms,
    or_0vat0,
    or_0vat1,
    or_0vat2,
    or_0vat3,
    or_0vat4,
    or_0vat5,
    or_0vat6,
    or_0vat7,
    or_0vat8,
    or_0vat9,
    or_0vatx,
    or_carrpax,
    or_carrrms,
    or_cdaypax,
    or_cdayrms,
    or_cdeppax,
    or_cdeprms,
    or_code,
    or_cpax,
    or_crev0,
    or_crev1,
    or_crev2,
    or_crev3,
    or_crev4,
    or_crev5,
    or_crev6,
    or_crev7,
    or_crev8,
    or_crev9,
    or_crevx,
    or_crms,
    or_cvat0,
    or_cvat1,
    or_cvat2,
    or_cvat3,
    or_cvat4,
    or_cvat5,
    or_cvat6,
    or_cvat7,
    or_cvat8,
    or_cvat9,
    or_cvatx,
    or_date,
    or_label
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_0arrpax orstat.or_0arrpax,
    or_0arrrms orstat.or_0arrrms,
    or_0daypax orstat.or_0daypax,
    or_0dayrms orstat.or_0dayrms,
    or_0deppax orstat.or_0deppax,
    or_0deprms orstat.or_0deprms,
    or_0pax    orstat.or_0pax,
    or_0rev0   orstat.or_0rev0,
    or_0rev1   orstat.or_0rev1,
    or_0rev2   orstat.or_0rev2,
    or_0rev3   orstat.or_0rev3,
    or_0rev4   orstat.or_0rev4,
    or_0rev5   orstat.or_0rev5,
    or_0rev6   orstat.or_0rev6,
    or_0rev7   orstat.or_0rev7,
    or_0rev8   orstat.or_0rev8,
    or_0rev9   orstat.or_0rev9,
    or_0revx   orstat.or_0revx,
    or_0rms    orstat.or_0rms,
    or_0vat0   orstat.or_0vat0,
    or_0vat1   orstat.or_0vat1,
    or_0vat2   orstat.or_0vat2,
    or_0vat3   orstat.or_0vat3,
    or_0vat4   orstat.or_0vat4,
    or_0vat5   orstat.or_0vat5,
    or_0vat6   orstat.or_0vat6,
    or_0vat7   orstat.or_0vat7,
    or_0vat8   orstat.or_0vat8,
    or_0vat9   orstat.or_0vat9,
    or_0vatx   orstat.or_0vatx,
    or_carrpax orstat.or_carrpax,
    or_carrrms orstat.or_carrrms,
    or_cdaypax orstat.or_cdaypax,
    or_cdayrms orstat.or_cdayrms,
    or_cdeppax orstat.or_cdeppax,
    or_cdeprms orstat.or_cdeprms,
    or_code    orstat.or_code,
    or_cpax    orstat.or_cpax,
    or_crev0   orstat.or_crev0,
    or_crev1   orstat.or_crev1,
    or_crev2   orstat.or_crev2,
    or_crev3   orstat.or_crev3,
    or_crev4   orstat.or_crev4,
    or_crev5   orstat.or_crev5,
    or_crev6   orstat.or_crev6,
    or_crev7   orstat.or_crev7,
    or_crev8   orstat.or_crev8,
    or_crev9   orstat.or_crev9,
    or_crevx   orstat.or_crevx,
    or_crms    orstat.or_crms,
    or_cvat0   orstat.or_cvat0,
    or_cvat1   orstat.or_cvat1,
    or_cvat2   orstat.or_cvat2,
    or_cvat3   orstat.or_cvat3,
    or_cvat4   orstat.or_cvat4,
    or_cvat5   orstat.or_cvat5,
    or_cvat6   orstat.or_cvat6,
    or_cvat7   orstat.or_cvat7,
    or_cvat8   orstat.or_cvat8,
    or_cvat9   orstat.or_cvat9,
    or_cvatx   orstat.or_cvatx,
    or_date    orstat.or_date,
    or_label   orstat.or_label
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caoutdebts AS caBase OF cit_ca.vcx
Alias = [caoutdebts]
Tables = [outdebts]
KeyFieldList = [ou_ouid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ou_amount,
       ou_artinum,
       ou_created,
       ou_date,
       ou_ouid,
       ou_vat1,
       ou_vat2,
       ou_vat3,
       ou_vat4,
       ou_vat5,
       ou_vat6,
       ou_vat7,
       ou_vat8,
       ou_vat9
    FROM outdebts
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ou_amount  B(2)    DEFAULT 0,
    ou_artinum N(4,0)  DEFAULT 0,
    ou_created T       DEFAULT {},
    ou_date    D       DEFAULT {},
    ou_ouid    N(8,0)  DEFAULT 0,
    ou_vat1    B(6)    DEFAULT 0,
    ou_vat2    B(6)    DEFAULT 0,
    ou_vat3    B(6)    DEFAULT 0,
    ou_vat4    B(6)    DEFAULT 0,
    ou_vat5    B(6)    DEFAULT 0,
    ou_vat6    B(6)    DEFAULT 0,
    ou_vat7    B(6)    DEFAULT 0,
    ou_vat8    B(6)    DEFAULT 0,
    ou_vat9    B(6)    DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ou_amount,
    ou_artinum,
    ou_created,
    ou_date,
    ou_ouid,
    ou_vat1,
    ou_vat2,
    ou_vat3,
    ou_vat4,
    ou_vat5,
    ou_vat6,
    ou_vat7,
    ou_vat8,
    ou_vat9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ou_amount  outdebts.ou_amount,
    ou_artinum outdebts.ou_artinum,
    ou_created outdebts.ou_created,
    ou_date    outdebts.ou_date,
    ou_ouid    outdebts.ou_ouid,
    ou_vat1    outdebts.ou_vat1,
    ou_vat2    outdebts.ou_vat2,
    ou_vat3    outdebts.ou_vat3,
    ou_vat4    outdebts.ou_vat4,
    ou_vat5    outdebts.ou_vat5,
    ou_vat6    outdebts.ou_vat6,
    ou_vat7    outdebts.ou_vat7,
    ou_vat8    outdebts.ou_vat8,
    ou_vat9    outdebts.ou_vat9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caoutoford AS caBase OF cit_ca.vcx
Alias = [caoutoford]
Tables = [outoford]
KeyFieldList = [oo_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       oo_cancel,
       oo_cxlwh,
       oo_fromdat,
       oo_id,
       oo_reason,
       oo_roomnum,
       oo_status,
       oo_todat,
       rs_message,
       rs_msgshow
    FROM outoford
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    oo_cancel  L       DEFAULT .F.,
    oo_cxlwh   C(30)   DEFAULT "",
    oo_fromdat D       DEFAULT {},
    oo_id      N(8,0)  DEFAULT 0,
    oo_reason  C(25)   DEFAULT "",
    oo_roomnum C(4)    DEFAULT "",
    oo_status  C(5)    DEFAULT "",
    oo_todat   D       DEFAULT {},
    rs_message M       DEFAULT "",
    rs_msgshow L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oo_cancel,
    oo_cxlwh,
    oo_fromdat,
    oo_id,
    oo_reason,
    oo_roomnum,
    oo_status,
    oo_todat,
    rs_message,
    rs_msgshow
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oo_cancel  outoford.oo_cancel,
    oo_cxlwh   outoford.oo_cxlwh,
    oo_fromdat outoford.oo_fromdat,
    oo_id      outoford.oo_id,
    oo_reason  outoford.oo_reason,
    oo_roomnum outoford.oo_roomnum,
    oo_status  outoford.oo_status,
    oo_todat   outoford.oo_todat,
    rs_message outoford.rs_message,
    rs_msgshow outoford.rs_msgshow
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caoutofser AS caBase OF cit_ca.vcx
Alias = [caoutofser]
Tables = [outofser]
KeyFieldList = [os_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       os_cancel,
       os_changes,
       os_fromdat,
       os_id,
       os_reason,
       os_roomnum,
       os_todat
    FROM outofser
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    os_cancel  L       DEFAULT .F.,
    os_changes M       DEFAULT "",
    os_fromdat D       DEFAULT {},
    os_id      N(8,0)  DEFAULT 0,
    os_reason  C(50)   DEFAULT "",
    os_roomnum C(4)    DEFAULT "",
    os_todat   D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    os_cancel,
    os_changes,
    os_fromdat,
    os_id,
    os_reason,
    os_roomnum,
    os_todat
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    os_cancel  outofser.os_cancel,
    os_changes outofser.os_changes,
    os_fromdat outofser.os_fromdat,
    os_id      outofser.os_id,
    os_reason  outofser.os_reason,
    os_roomnum outofser.os_roomnum,
    os_todat   outofser.os_todat
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caparam AS caBase OF cit_ca.vcx
Alias = [caparam]
Tables = [param]
KeyFieldList = [pa_hotel]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pa_accomp,
       pa_adchkrs,
       pa_addrlib,
       pa_addrsav,
       pa_adr2res,
       pa_adrbank,
       pa_adrcall,
       pa_allodef,
       pa_aposdir,
       pa_arage1,
       pa_arage2,
       pa_arage3,
       pa_arage4,
       pa_arage5,
       pa_arautid,
       pa_argus,
       pa_arrem1,
       pa_arrem2,
       pa_arrem3,
       pa_aruser1,
       pa_aruser2,
       pa_aruser3,
       pa_askcard,
       pa_askfa,
       pa_askreas,
       pa_audbat,
       pa_audnost,
       pa_audtbl,
       pa_autoprn,
       pa_avail,
       pa_avltime,
       pa_baselii,
       pa_bilcopy,
       pa_billext,
       pa_billlng,
       pa_billsty,
       pa_bqnropt,
       pa_build,
       pa_childs,
       pa_chkadts,
       pa_chklang,
       pa_chkpay,
       pa_cibill,
       pa_city,
       pa_compvat,
       pa_confgrp,
       pa_copydev,
       pa_country,
       pa_covmenu,
       pa_currdec,
       pa_currloc,
       pa_cxlpost,
       pa_dayprt1,
       pa_dayprt2,
       pa_dbclick,
       pa_dblbook,
       pa_ddetout,
       pa_debbill,
       pa_debug,
       pa_defstat,
       pa_delledg,
       pa_delpay,
       pa_delpost,
       pa_departi,
       pa_depas,
       pa_depcxl,
       pa_deprule,
       pa_depspec,
       pa_depxfer,
       pa_discnt,
       pa_dumgrup,
       pa_error,
       pa_exclvat,
       pa_expavl,
       pa_expd2,
       pa_expires,
       pa_extrsid,
       pa_fax,
       pa_fiscprt,
       pa_gchkout,
       pa_hidcash,
       pa_holdavl,
       pa_holdres,
       pa_hotel,
       pa_idyear,
       pa_ineuro,
       pa_jetwb,
       pa_keyarti,
       pa_keychck,
       pa_keycs,
       pa_keyifc,
       pa_keyname,
       pa_keysync,
       pa_lang,
       pa_lastaud,
       pa_lastint,
       pa_lasttim,
       pa_laundry,
       pa_layaddr,
       pa_license,
       pa_lizopt,
       pa_lsallot,
       pa_maxroom,
       pa_maxuser,
       pa_mnuextr,
       pa_msgshow,
       pa_multioc,
       pa_naxprg,
       pa_nights,
       pa_noagent,
       pa_noclose,
       pa_nogroup,
       pa_nomark,
       pa_norcclr,
       pa_noreml4,
       pa_nosour,
       pa_olemtd,
       pa_oooover,
       pa_optda,
       pa_optidef,
       pa_overbk,
       pa_payonld,
       pa_pbillst,
       pa_phnchk,
       pa_phnpres,
       pa_plancol,
       pa_planvar,
       pa_pmuser1,
       pa_pmuser2,
       pa_pmuser3,
       pa_point,
       pa_posartd,
       pa_posarti,
       pa_poscs,
       pa_posdifa,
       pa_posdir,
       pa_posifc,
       pa_posmove,
       pa_posnpay,
       pa_posrmus,
       pa_possync,
       pa_postpos,
       pa_pttarti,
       pa_pttask,
       pa_pttatbl,
       pa_pttcel,
       pa_pttchk,
       pa_pttcico,
       pa_pttcs,
       pa_pttcumu,
       pa_pttifc,
       pa_pttlim1,
       pa_pttlim2,
       pa_pttmess,
       pa_pttprc1,
       pa_pttprc2,
       pa_pttprc3,
       pa_pttrsid,
       pa_pttstat,
       pa_pttsync,
       pa_pttvip,
       pa_pttwake,
       pa_ptvarti,
       pa_ptvcs,
       pa_ptvifc,
       pa_ptvmess,
       pa_ptvname,
       pa_ptvpayn,
       pa_ptvsync,
       pa_quickrs,
       pa_rcpers,
       pa_relogin,
       pa_reopbil,
       pa_rep13,
       pa_rep14,
       pa_rep15,
       pa_resall,
       pa_resfind,
       pa_revisio,
       pa_rmstat,
       pa_rmuser1,
       pa_rmuser2,
       pa_rmuser3,
       pa_rndpay,
       pa_rshare,
       pa_rsus3,
       pa_setusad,
       pa_setusre,
       pa_showtv,
       pa_starthr,
       pa_statdat,
       pa_state,
       pa_statoff,
       pa_sysdate,
       pa_telmng,
       pa_telptv,
       pa_tentdef,
       pa_titlcod,
       pa_topost,
       pa_twovats,
       pa_untdec,
       pa_ures0v,
       pa_ures1v,
       pa_ures2v,
       pa_ures3v,
       pa_ures4v,
       pa_ures5v,
       pa_ures6v,
       pa_ures7v,
       pa_ures8v,
       pa_ures9v,
       pa_user1,
       pa_user10,
       pa_user10v,
       pa_user1v,
       pa_user2,
       pa_user2v,
       pa_user3,
       pa_user3v,
       pa_user4,
       pa_user4v,
       pa_user5,
       pa_user5v,
       pa_user6,
       pa_user6v,
       pa_user7,
       pa_user7v,
       pa_user8,
       pa_user8v,
       pa_user9,
       pa_user9v,
       pa_usrres0,
       pa_usrres1,
       pa_usrres2,
       pa_usrres3,
       pa_usrres4,
       pa_usrres5,
       pa_usrres6,
       pa_usrres7,
       pa_usrres8,
       pa_usrres9,
       pa_vatconv,
       pa_version,
       pa_vouexpm,
       pa_vounoex,
       pa_waishow,
       pa_wakedir,
       pa_wakeinp,
       pa_wakeup,
       pa_wordlng,
       pa_wudays,
       pa_wutimeo,
       pa_zip,
       pa_ziplen
    FROM param
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_accomp  C(2)    DEFAULT "",
    pa_adchkrs L       DEFAULT .F.,
    pa_addrlib C(3)    DEFAULT "",
    pa_addrsav L       DEFAULT .F.,
    pa_adr2res L       DEFAULT .F.,
    pa_adrbank L       DEFAULT .F.,
    pa_adrcall L       DEFAULT .F.,
    pa_allodef L       DEFAULT .F.,
    pa_aposdir C(40)   DEFAULT "",
    pa_arage1  N(3,0)  DEFAULT 0,
    pa_arage2  N(3,0)  DEFAULT 0,
    pa_arage3  N(3,0)  DEFAULT 0,
    pa_arage4  N(3,0)  DEFAULT 0,
    pa_arage5  N(3,0)  DEFAULT 0,
    pa_arautid L       DEFAULT .F.,
    pa_argus   L       DEFAULT .F.,
    pa_arrem1  N(3,0)  DEFAULT 0,
    pa_arrem2  N(3,0)  DEFAULT 0,
    pa_arrem3  N(3,0)  DEFAULT 0,
    pa_aruser1 C(15)   DEFAULT "",
    pa_aruser2 C(15)   DEFAULT "",
    pa_aruser3 C(15)   DEFAULT "",
    pa_askcard L       DEFAULT .F.,
    pa_askfa   L       DEFAULT .F.,
    pa_askreas L       DEFAULT .F.,
    pa_audbat  C(3)    DEFAULT "",
    pa_audnost L       DEFAULT .F.,
    pa_audtbl  L       DEFAULT .F.,
    pa_autoprn L       DEFAULT .F.,
    pa_avail   N(4,0)  DEFAULT 0,
    pa_avltime N(3,0)  DEFAULT 0,
    pa_baselii L       DEFAULT .F.,
    pa_bilcopy C(8)    DEFAULT "",
    pa_billext L       DEFAULT .F.,
    pa_billlng L       DEFAULT .F.,
    pa_billsty N(2,0)  DEFAULT 0,
    pa_bqnropt L       DEFAULT .F.,
    pa_build   N(3,0)  DEFAULT 0,
    pa_childs  C(15)   DEFAULT "",
    pa_chkadts L       DEFAULT .F.,
    pa_chklang L       DEFAULT .F.,
    pa_chkpay  L       DEFAULT .F.,
    pa_cibill  L       DEFAULT .F.,
    pa_city    C(30)   DEFAULT "",
    pa_compvat L       DEFAULT .F.,
    pa_confgrp L       DEFAULT .F.,
    pa_copydev C(40)   DEFAULT "",
    pa_country C(3)    DEFAULT "",
    pa_covmenu L       DEFAULT .F.,
    pa_currdec N(1,0)  DEFAULT 0,
    pa_currloc N(2,0)  DEFAULT 0,
    pa_cxlpost L       DEFAULT .F.,
    pa_dayprt1 N(2,0)  DEFAULT 0,
    pa_dayprt2 N(2,0)  DEFAULT 0,
    pa_dbclick N(4,2)  DEFAULT 0,
    pa_dblbook L       DEFAULT .F.,
    pa_ddetout N(5,0)  DEFAULT 0,
    pa_debbill N(10,0) DEFAULT 0,
    pa_debug   L       DEFAULT .F.,
    pa_defstat C(3)    DEFAULT "",
    pa_delledg N(3,0)  DEFAULT 0,
    pa_delpay  L       DEFAULT .F.,
    pa_delpost L       DEFAULT .F.,
    pa_departi N(4,0)  DEFAULT 0,
    pa_depas   N(2,0)  DEFAULT 0,
    pa_depcxl  N(4,0)  DEFAULT 0,
    pa_deprule N(1,0)  DEFAULT 0,
    pa_depspec N(4,0)  DEFAULT 0,
    pa_depxfer N(4,0)  DEFAULT 0,
    pa_discnt  L       DEFAULT .F.,
    pa_dumgrup L       DEFAULT .F.,
    pa_error   L       DEFAULT .F.,
    pa_exclvat L       DEFAULT .F.,
    pa_expavl  L       DEFAULT .F.,
    pa_expd2   L       DEFAULT .F.,
    pa_expires D       DEFAULT {},
    pa_extrsid N(12,3) DEFAULT 0,
    pa_fax     L       DEFAULT .F.,
    pa_fiscprt C(6)    DEFAULT "",
    pa_gchkout L       DEFAULT .F.,
    pa_hidcash L       DEFAULT .F.,
    pa_holdavl N(3,0)  DEFAULT 0,
    pa_holdres N(3,0)  DEFAULT 0,
    pa_hotel   C(60)   DEFAULT "",
    pa_idyear  L       DEFAULT .F.,
    pa_ineuro  L       DEFAULT .F.,
    pa_jetwb   L       DEFAULT .F.,
    pa_keyarti N(4,0)  DEFAULT 0,
    pa_keychck L       DEFAULT .F.,
    pa_keycs   L       DEFAULT .F.,
    pa_keyifc  L       DEFAULT .F.,
    pa_keyname C(5)    DEFAULT "",
    pa_keysync L       DEFAULT .F.,
    pa_lang    C(3)    DEFAULT "",
    pa_lastaud D       DEFAULT {},
    pa_lastint N(2,0)  DEFAULT 0,
    pa_lasttim C(8)    DEFAULT "",
    pa_laundry N(2,0)  DEFAULT 0,
    pa_layaddr N(1,0)  DEFAULT 0,
    pa_license N(12,0) DEFAULT 0,
    pa_lizopt  C(254)  DEFAULT "",
    pa_lsallot C(4)    DEFAULT "",
    pa_maxroom I       DEFAULT 0,
    pa_maxuser N(2,0)  DEFAULT 0,
    pa_mnuextr L       DEFAULT .F.,
    pa_msgshow L       DEFAULT .F.,
    pa_multioc L       DEFAULT .F.,
    pa_naxprg  C(6)    DEFAULT "",
    pa_nights  N(2,0)  DEFAULT 0,
    pa_noagent L       DEFAULT .F.,
    pa_noclose L       DEFAULT .F.,
    pa_nogroup L       DEFAULT .F.,
    pa_nomark  L       DEFAULT .F.,
    pa_norcclr L       DEFAULT .F.,
    pa_noreml4 L       DEFAULT .F.,
    pa_nosour  L       DEFAULT .F.,
    pa_olemtd  N(1,0)  DEFAULT 0,
    pa_oooover L       DEFAULT .F.,
    pa_optda   L       DEFAULT .F.,
    pa_optidef L       DEFAULT .F.,
    pa_overbk  L       DEFAULT .F.,
    pa_payonld N(3,0)  DEFAULT 0,
    pa_pbillst N(2,0)  DEFAULT 0,
    pa_phnchk  L       DEFAULT .F.,
    pa_phnpres C(2)    DEFAULT "",
    pa_plancol L       DEFAULT .F.,
    pa_planvar L       DEFAULT .F.,
    pa_pmuser1 C(15)   DEFAULT "",
    pa_pmuser2 C(15)   DEFAULT "",
    pa_pmuser3 C(15)   DEFAULT "",
    pa_point   C(1)    DEFAULT "",
    pa_posartd C(80)   DEFAULT "",
    pa_posarti N(4,0)  DEFAULT 0,
    pa_poscs   L       DEFAULT .F.,
    pa_posdifa N(4,0)  DEFAULT 0,
    pa_posdir  C(40)   DEFAULT "",
    pa_posifc  L       DEFAULT .F.,
    pa_posmove C(40)   DEFAULT "",
    pa_posnpay N(4,0)  DEFAULT 0,
    pa_posrmus L       DEFAULT .F.,
    pa_possync L       DEFAULT .F.,
    pa_postpos L       DEFAULT .F.,
    pa_pttarti N(4,0)  DEFAULT 0,
    pa_pttask  L       DEFAULT .F.,
    pa_pttatbl L       DEFAULT .F.,
    pa_pttcel  C(60)   DEFAULT "",
    pa_pttchk  L       DEFAULT .F.,
    pa_pttcico L       DEFAULT .F.,
    pa_pttcs   L       DEFAULT .F.,
    pa_pttcumu L       DEFAULT .F.,
    pa_pttifc  L       DEFAULT .F.,
    pa_pttlim1 N(4,0)  DEFAULT 0,
    pa_pttlim2 N(4,0)  DEFAULT 0,
    pa_pttmess L       DEFAULT .F.,
    pa_pttprc1 B(2)    DEFAULT 0,
    pa_pttprc2 B(2)    DEFAULT 0,
    pa_pttprc3 B(2)    DEFAULT 0,
    pa_pttrsid L       DEFAULT .F.,
    pa_pttstat L       DEFAULT .F.,
    pa_pttsync L       DEFAULT .F.,
    pa_pttvip  L       DEFAULT .F.,
    pa_pttwake L       DEFAULT .F.,
    pa_ptvarti N(4,0)  DEFAULT 0,
    pa_ptvcs   L       DEFAULT .F.,
    pa_ptvifc  L       DEFAULT .F.,
    pa_ptvmess L       DEFAULT .F.,
    pa_ptvname C(5)    DEFAULT "",
    pa_ptvpayn N(4,0)  DEFAULT 0,
    pa_ptvsync L       DEFAULT .F.,
    pa_quickrs L       DEFAULT .F.,
    pa_rcpers  N(1,0)  DEFAULT 0,
    pa_relogin L       DEFAULT .F.,
    pa_reopbil L       DEFAULT .F.,
    pa_rep13   C(20)   DEFAULT "",
    pa_rep14   C(20)   DEFAULT "",
    pa_rep15   C(20)   DEFAULT "",
    pa_resall  L       DEFAULT .F.,
    pa_resfind N(2,0)  DEFAULT 0,
    pa_revisio C(1)    DEFAULT "",
    pa_rmstat  L       DEFAULT .F.,
    pa_rmuser1 C(20)   DEFAULT "",
    pa_rmuser2 C(20)   DEFAULT "",
    pa_rmuser3 C(20)   DEFAULT "",
    pa_rndpay  N(3,0)  DEFAULT 0,
    pa_rshare  L       DEFAULT .F.,
    pa_rsus3   L       DEFAULT .F.,
    pa_setusad C(10)   DEFAULT "",
    pa_setusre C(10)   DEFAULT "",
    pa_showtv  L       DEFAULT .F.,
    pa_starthr N(2,0)  DEFAULT 0,
    pa_statdat D       DEFAULT {},
    pa_state   C(30)   DEFAULT "",
    pa_statoff L       DEFAULT .F.,
    pa_sysdate D       DEFAULT {},
    pa_telmng  L       DEFAULT .F.,
    pa_telptv  L       DEFAULT .F.,
    pa_tentdef L       DEFAULT .F.,
    pa_titlcod N(1,0)  DEFAULT 0,
    pa_topost  L       DEFAULT .F.,
    pa_twovats L       DEFAULT .F.,
    pa_untdec  L       DEFAULT .F.,
    pa_ures0v  N(3,0)  DEFAULT 0,
    pa_ures1v  N(3,0)  DEFAULT 0,
    pa_ures2v  N(3,0)  DEFAULT 0,
    pa_ures3v  N(3,0)  DEFAULT 0,
    pa_ures4v  N(3,0)  DEFAULT 0,
    pa_ures5v  N(3,0)  DEFAULT 0,
    pa_ures6v  N(3,0)  DEFAULT 0,
    pa_ures7v  N(3,0)  DEFAULT 0,
    pa_ures8v  N(3,0)  DEFAULT 0,
    pa_ures9v  N(3,0)  DEFAULT 0,
    pa_user1   C(20)   DEFAULT "",
    pa_user10  C(20)   DEFAULT "",
    pa_user10v N(3,0)  DEFAULT 0,
    pa_user1v  N(3,0)  DEFAULT 0,
    pa_user2   C(20)   DEFAULT "",
    pa_user2v  N(3,0)  DEFAULT 0,
    pa_user3   C(20)   DEFAULT "",
    pa_user3v  N(3,0)  DEFAULT 0,
    pa_user4   C(20)   DEFAULT "",
    pa_user4v  N(3,0)  DEFAULT 0,
    pa_user5   C(20)   DEFAULT "",
    pa_user5v  N(3,0)  DEFAULT 0,
    pa_user6   C(20)   DEFAULT "",
    pa_user6v  N(3,0)  DEFAULT 0,
    pa_user7   C(20)   DEFAULT "",
    pa_user7v  N(3,0)  DEFAULT 0,
    pa_user8   C(20)   DEFAULT "",
    pa_user8v  N(3,0)  DEFAULT 0,
    pa_user9   C(20)   DEFAULT "",
    pa_user9v  N(3,0)  DEFAULT 0,
    pa_usrres0 C(25)   DEFAULT "",
    pa_usrres1 C(15)   DEFAULT "",
    pa_usrres2 C(15)   DEFAULT "",
    pa_usrres3 C(15)   DEFAULT "",
    pa_usrres4 C(25)   DEFAULT "",
    pa_usrres5 C(25)   DEFAULT "",
    pa_usrres6 C(25)   DEFAULT "",
    pa_usrres7 C(25)   DEFAULT "",
    pa_usrres8 C(25)   DEFAULT "",
    pa_usrres9 C(25)   DEFAULT "",
    pa_vatconv C(35)   DEFAULT "",
    pa_version N(5,2)  DEFAULT 0,
    pa_vouexpm L       DEFAULT .F.,
    pa_vounoex L       DEFAULT .F.,
    pa_waishow L       DEFAULT .F.,
    pa_wakedir C(40)   DEFAULT "",
    pa_wakeinp C(40)   DEFAULT "",
    pa_wakeup  L       DEFAULT .F.,
    pa_wordlng C(4)    DEFAULT "",
    pa_wudays  N(2,0)  DEFAULT 0,
    pa_wutimeo N(3,0)  DEFAULT 0,
    pa_zip     C(10)   DEFAULT "",
    pa_ziplen  N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_accomp,
    pa_adchkrs,
    pa_addrlib,
    pa_addrsav,
    pa_adr2res,
    pa_adrbank,
    pa_adrcall,
    pa_allodef,
    pa_aposdir,
    pa_arage1,
    pa_arage2,
    pa_arage3,
    pa_arage4,
    pa_arage5,
    pa_arautid,
    pa_argus,
    pa_arrem1,
    pa_arrem2,
    pa_arrem3,
    pa_aruser1,
    pa_aruser2,
    pa_aruser3,
    pa_askcard,
    pa_askfa,
    pa_askreas,
    pa_audbat,
    pa_audnost,
    pa_audtbl,
    pa_autoprn,
    pa_avail,
    pa_avltime,
    pa_baselii,
    pa_bilcopy,
    pa_billext,
    pa_billlng,
    pa_billsty,
    pa_bqnropt,
    pa_build,
    pa_childs,
    pa_chkadts,
    pa_chklang,
    pa_chkpay,
    pa_cibill,
    pa_city,
    pa_compvat,
    pa_confgrp,
    pa_copydev,
    pa_country,
    pa_covmenu,
    pa_currdec,
    pa_currloc,
    pa_cxlpost,
    pa_dayprt1,
    pa_dayprt2,
    pa_dbclick,
    pa_dblbook,
    pa_ddetout,
    pa_debbill,
    pa_debug,
    pa_defstat,
    pa_delledg,
    pa_delpay,
    pa_delpost,
    pa_departi,
    pa_depas,
    pa_depcxl,
    pa_deprule,
    pa_depspec,
    pa_depxfer,
    pa_discnt,
    pa_dumgrup,
    pa_error,
    pa_exclvat,
    pa_expavl,
    pa_expd2,
    pa_expires,
    pa_extrsid,
    pa_fax,
    pa_fiscprt,
    pa_gchkout,
    pa_hidcash,
    pa_holdavl,
    pa_holdres,
    pa_hotel,
    pa_idyear,
    pa_ineuro,
    pa_jetwb,
    pa_keyarti,
    pa_keychck,
    pa_keycs,
    pa_keyifc,
    pa_keyname,
    pa_keysync,
    pa_lang,
    pa_lastaud,
    pa_lastint,
    pa_lasttim,
    pa_laundry,
    pa_layaddr,
    pa_license,
    pa_lizopt,
    pa_lsallot,
    pa_maxroom,
    pa_maxuser,
    pa_mnuextr,
    pa_msgshow,
    pa_multioc,
    pa_naxprg,
    pa_nights,
    pa_noagent,
    pa_noclose,
    pa_nogroup,
    pa_nomark,
    pa_norcclr,
    pa_noreml4,
    pa_nosour,
    pa_olemtd,
    pa_oooover,
    pa_optda,
    pa_optidef,
    pa_overbk,
    pa_payonld,
    pa_pbillst,
    pa_phnchk,
    pa_phnpres,
    pa_plancol,
    pa_planvar,
    pa_pmuser1,
    pa_pmuser2,
    pa_pmuser3,
    pa_point,
    pa_posartd,
    pa_posarti,
    pa_poscs,
    pa_posdifa,
    pa_posdir,
    pa_posifc,
    pa_posmove,
    pa_posnpay,
    pa_posrmus,
    pa_possync,
    pa_postpos,
    pa_pttarti,
    pa_pttask,
    pa_pttatbl,
    pa_pttcel,
    pa_pttchk,
    pa_pttcico,
    pa_pttcs,
    pa_pttcumu,
    pa_pttifc,
    pa_pttlim1,
    pa_pttlim2,
    pa_pttmess,
    pa_pttprc1,
    pa_pttprc2,
    pa_pttprc3,
    pa_pttrsid,
    pa_pttstat,
    pa_pttsync,
    pa_pttvip,
    pa_pttwake,
    pa_ptvarti,
    pa_ptvcs,
    pa_ptvifc,
    pa_ptvmess,
    pa_ptvname,
    pa_ptvpayn,
    pa_ptvsync,
    pa_quickrs,
    pa_rcpers,
    pa_relogin,
    pa_reopbil,
    pa_rep13,
    pa_rep14,
    pa_rep15,
    pa_resall,
    pa_resfind,
    pa_revisio,
    pa_rmstat,
    pa_rmuser1,
    pa_rmuser2,
    pa_rmuser3,
    pa_rndpay,
    pa_rshare,
    pa_rsus3,
    pa_setusad,
    pa_setusre,
    pa_showtv,
    pa_starthr,
    pa_statdat,
    pa_state,
    pa_statoff,
    pa_sysdate,
    pa_telmng,
    pa_telptv,
    pa_tentdef,
    pa_titlcod,
    pa_topost,
    pa_twovats,
    pa_untdec,
    pa_ures0v,
    pa_ures1v,
    pa_ures2v,
    pa_ures3v,
    pa_ures4v,
    pa_ures5v,
    pa_ures6v,
    pa_ures7v,
    pa_ures8v,
    pa_ures9v,
    pa_user1,
    pa_user10,
    pa_user10v,
    pa_user1v,
    pa_user2,
    pa_user2v,
    pa_user3,
    pa_user3v,
    pa_user4,
    pa_user4v,
    pa_user5,
    pa_user5v,
    pa_user6,
    pa_user6v,
    pa_user7,
    pa_user7v,
    pa_user8,
    pa_user8v,
    pa_user9,
    pa_user9v,
    pa_usrres0,
    pa_usrres1,
    pa_usrres2,
    pa_usrres3,
    pa_usrres4,
    pa_usrres5,
    pa_usrres6,
    pa_usrres7,
    pa_usrres8,
    pa_usrres9,
    pa_vatconv,
    pa_version,
    pa_vouexpm,
    pa_vounoex,
    pa_waishow,
    pa_wakedir,
    pa_wakeinp,
    pa_wakeup,
    pa_wordlng,
    pa_wudays,
    pa_wutimeo,
    pa_zip,
    pa_ziplen
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_accomp  param.pa_accomp,
    pa_adchkrs param.pa_adchkrs,
    pa_addrlib param.pa_addrlib,
    pa_addrsav param.pa_addrsav,
    pa_adr2res param.pa_adr2res,
    pa_adrbank param.pa_adrbank,
    pa_adrcall param.pa_adrcall,
    pa_allodef param.pa_allodef,
    pa_aposdir param.pa_aposdir,
    pa_arage1  param.pa_arage1,
    pa_arage2  param.pa_arage2,
    pa_arage3  param.pa_arage3,
    pa_arage4  param.pa_arage4,
    pa_arage5  param.pa_arage5,
    pa_arautid param.pa_arautid,
    pa_argus   param.pa_argus,
    pa_arrem1  param.pa_arrem1,
    pa_arrem2  param.pa_arrem2,
    pa_arrem3  param.pa_arrem3,
    pa_aruser1 param.pa_aruser1,
    pa_aruser2 param.pa_aruser2,
    pa_aruser3 param.pa_aruser3,
    pa_askcard param.pa_askcard,
    pa_askfa   param.pa_askfa,
    pa_askreas param.pa_askreas,
    pa_audbat  param.pa_audbat,
    pa_audnost param.pa_audnost,
    pa_audtbl  param.pa_audtbl,
    pa_autoprn param.pa_autoprn,
    pa_avail   param.pa_avail,
    pa_avltime param.pa_avltime,
    pa_baselii param.pa_baselii,
    pa_bilcopy param.pa_bilcopy,
    pa_billext param.pa_billext,
    pa_billlng param.pa_billlng,
    pa_billsty param.pa_billsty,
    pa_bqnropt param.pa_bqnropt,
    pa_build   param.pa_build,
    pa_childs  param.pa_childs,
    pa_chkadts param.pa_chkadts,
    pa_chklang param.pa_chklang,
    pa_chkpay  param.pa_chkpay,
    pa_cibill  param.pa_cibill,
    pa_city    param.pa_city,
    pa_compvat param.pa_compvat,
    pa_confgrp param.pa_confgrp,
    pa_copydev param.pa_copydev,
    pa_country param.pa_country,
    pa_covmenu param.pa_covmenu,
    pa_currdec param.pa_currdec,
    pa_currloc param.pa_currloc,
    pa_cxlpost param.pa_cxlpost,
    pa_dayprt1 param.pa_dayprt1,
    pa_dayprt2 param.pa_dayprt2,
    pa_dbclick param.pa_dbclick,
    pa_dblbook param.pa_dblbook,
    pa_ddetout param.pa_ddetout,
    pa_debbill param.pa_debbill,
    pa_debug   param.pa_debug,
    pa_defstat param.pa_defstat,
    pa_delledg param.pa_delledg,
    pa_delpay  param.pa_delpay,
    pa_delpost param.pa_delpost,
    pa_departi param.pa_departi,
    pa_depas   param.pa_depas,
    pa_depcxl  param.pa_depcxl,
    pa_deprule param.pa_deprule,
    pa_depspec param.pa_depspec,
    pa_depxfer param.pa_depxfer,
    pa_discnt  param.pa_discnt,
    pa_dumgrup param.pa_dumgrup,
    pa_error   param.pa_error,
    pa_exclvat param.pa_exclvat,
    pa_expavl  param.pa_expavl,
    pa_expd2   param.pa_expd2,
    pa_expires param.pa_expires,
    pa_extrsid param.pa_extrsid,
    pa_fax     param.pa_fax,
    pa_fiscprt param.pa_fiscprt,
    pa_gchkout param.pa_gchkout,
    pa_hidcash param.pa_hidcash,
    pa_holdavl param.pa_holdavl,
    pa_holdres param.pa_holdres,
    pa_hotel   param.pa_hotel,
    pa_idyear  param.pa_idyear,
    pa_ineuro  param.pa_ineuro,
    pa_jetwb   param.pa_jetwb,
    pa_keyarti param.pa_keyarti,
    pa_keychck param.pa_keychck,
    pa_keycs   param.pa_keycs,
    pa_keyifc  param.pa_keyifc,
    pa_keyname param.pa_keyname,
    pa_keysync param.pa_keysync,
    pa_lang    param.pa_lang,
    pa_lastaud param.pa_lastaud,
    pa_lastint param.pa_lastint,
    pa_lasttim param.pa_lasttim,
    pa_laundry param.pa_laundry,
    pa_layaddr param.pa_layaddr,
    pa_license param.pa_license,
    pa_lizopt  param.pa_lizopt,
    pa_lsallot param.pa_lsallot,
    pa_maxroom param.pa_maxroom,
    pa_maxuser param.pa_maxuser,
    pa_mnuextr param.pa_mnuextr,
    pa_msgshow param.pa_msgshow,
    pa_multioc param.pa_multioc,
    pa_naxprg  param.pa_naxprg,
    pa_nights  param.pa_nights,
    pa_noagent param.pa_noagent,
    pa_noclose param.pa_noclose,
    pa_nogroup param.pa_nogroup,
    pa_nomark  param.pa_nomark,
    pa_norcclr param.pa_norcclr,
    pa_noreml4 param.pa_noreml4,
    pa_nosour  param.pa_nosour,
    pa_olemtd  param.pa_olemtd,
    pa_oooover param.pa_oooover,
    pa_optda   param.pa_optda,
    pa_optidef param.pa_optidef,
    pa_overbk  param.pa_overbk,
    pa_payonld param.pa_payonld,
    pa_pbillst param.pa_pbillst,
    pa_phnchk  param.pa_phnchk,
    pa_phnpres param.pa_phnpres,
    pa_plancol param.pa_plancol,
    pa_planvar param.pa_planvar,
    pa_pmuser1 param.pa_pmuser1,
    pa_pmuser2 param.pa_pmuser2,
    pa_pmuser3 param.pa_pmuser3,
    pa_point   param.pa_point,
    pa_posartd param.pa_posartd,
    pa_posarti param.pa_posarti,
    pa_poscs   param.pa_poscs,
    pa_posdifa param.pa_posdifa,
    pa_posdir  param.pa_posdir,
    pa_posifc  param.pa_posifc,
    pa_posmove param.pa_posmove,
    pa_posnpay param.pa_posnpay,
    pa_posrmus param.pa_posrmus,
    pa_possync param.pa_possync,
    pa_postpos param.pa_postpos,
    pa_pttarti param.pa_pttarti,
    pa_pttask  param.pa_pttask,
    pa_pttatbl param.pa_pttatbl,
    pa_pttcel  param.pa_pttcel,
    pa_pttchk  param.pa_pttchk,
    pa_pttcico param.pa_pttcico,
    pa_pttcs   param.pa_pttcs,
    pa_pttcumu param.pa_pttcumu,
    pa_pttifc  param.pa_pttifc,
    pa_pttlim1 param.pa_pttlim1,
    pa_pttlim2 param.pa_pttlim2,
    pa_pttmess param.pa_pttmess,
    pa_pttprc1 param.pa_pttprc1,
    pa_pttprc2 param.pa_pttprc2,
    pa_pttprc3 param.pa_pttprc3,
    pa_pttrsid param.pa_pttrsid,
    pa_pttstat param.pa_pttstat,
    pa_pttsync param.pa_pttsync,
    pa_pttvip  param.pa_pttvip,
    pa_pttwake param.pa_pttwake,
    pa_ptvarti param.pa_ptvarti,
    pa_ptvcs   param.pa_ptvcs,
    pa_ptvifc  param.pa_ptvifc,
    pa_ptvmess param.pa_ptvmess,
    pa_ptvname param.pa_ptvname,
    pa_ptvpayn param.pa_ptvpayn,
    pa_ptvsync param.pa_ptvsync,
    pa_quickrs param.pa_quickrs,
    pa_rcpers  param.pa_rcpers,
    pa_relogin param.pa_relogin,
    pa_reopbil param.pa_reopbil,
    pa_rep13   param.pa_rep13,
    pa_rep14   param.pa_rep14,
    pa_rep15   param.pa_rep15,
    pa_resall  param.pa_resall,
    pa_resfind param.pa_resfind,
    pa_revisio param.pa_revisio,
    pa_rmstat  param.pa_rmstat,
    pa_rmuser1 param.pa_rmuser1,
    pa_rmuser2 param.pa_rmuser2,
    pa_rmuser3 param.pa_rmuser3,
    pa_rndpay  param.pa_rndpay,
    pa_rshare  param.pa_rshare,
    pa_rsus3   param.pa_rsus3,
    pa_setusad param.pa_setusad,
    pa_setusre param.pa_setusre,
    pa_showtv  param.pa_showtv,
    pa_starthr param.pa_starthr,
    pa_statdat param.pa_statdat,
    pa_state   param.pa_state,
    pa_statoff param.pa_statoff,
    pa_sysdate param.pa_sysdate,
    pa_telmng  param.pa_telmng,
    pa_telptv  param.pa_telptv,
    pa_tentdef param.pa_tentdef,
    pa_titlcod param.pa_titlcod,
    pa_topost  param.pa_topost,
    pa_twovats param.pa_twovats,
    pa_untdec  param.pa_untdec,
    pa_ures0v  param.pa_ures0v,
    pa_ures1v  param.pa_ures1v,
    pa_ures2v  param.pa_ures2v,
    pa_ures3v  param.pa_ures3v,
    pa_ures4v  param.pa_ures4v,
    pa_ures5v  param.pa_ures5v,
    pa_ures6v  param.pa_ures6v,
    pa_ures7v  param.pa_ures7v,
    pa_ures8v  param.pa_ures8v,
    pa_ures9v  param.pa_ures9v,
    pa_user1   param.pa_user1,
    pa_user10  param.pa_user10,
    pa_user10v param.pa_user10v,
    pa_user1v  param.pa_user1v,
    pa_user2   param.pa_user2,
    pa_user2v  param.pa_user2v,
    pa_user3   param.pa_user3,
    pa_user3v  param.pa_user3v,
    pa_user4   param.pa_user4,
    pa_user4v  param.pa_user4v,
    pa_user5   param.pa_user5,
    pa_user5v  param.pa_user5v,
    pa_user6   param.pa_user6,
    pa_user6v  param.pa_user6v,
    pa_user7   param.pa_user7,
    pa_user7v  param.pa_user7v,
    pa_user8   param.pa_user8,
    pa_user8v  param.pa_user8v,
    pa_user9   param.pa_user9,
    pa_user9v  param.pa_user9v,
    pa_usrres0 param.pa_usrres0,
    pa_usrres1 param.pa_usrres1,
    pa_usrres2 param.pa_usrres2,
    pa_usrres3 param.pa_usrres3,
    pa_usrres4 param.pa_usrres4,
    pa_usrres5 param.pa_usrres5,
    pa_usrres6 param.pa_usrres6,
    pa_usrres7 param.pa_usrres7,
    pa_usrres8 param.pa_usrres8,
    pa_usrres9 param.pa_usrres9,
    pa_vatconv param.pa_vatconv,
    pa_version param.pa_version,
    pa_vouexpm param.pa_vouexpm,
    pa_vounoex param.pa_vounoex,
    pa_waishow param.pa_waishow,
    pa_wakedir param.pa_wakedir,
    pa_wakeinp param.pa_wakeinp,
    pa_wakeup  param.pa_wakeup,
    pa_wordlng param.pa_wordlng,
    pa_wudays  param.pa_wudays,
    pa_wutimeo param.pa_wutimeo,
    pa_zip     param.pa_zip,
    pa_ziplen  param.pa_ziplen
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caparam2 AS caBase OF cit_ca.vcx
Alias = [caparam2]
Tables = [param2]
KeyFieldList = [pa_paid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pa_abcodat,
       pa_acctnr,
       pa_adesunq,
       pa_adrcomp,
       pa_adrmupd,
       pa_adrtyco,
       pa_adrtyeq,
       pa_agnbwin,
       pa_argusdr,
       pa_arhdate,
       pa_aruser4,
       pa_aruser5,
       pa_aruser6,
       pa_aruser7,
       pa_aruset4,
       pa_aruset5,
       pa_aruset6,
       pa_aruset7,
       pa_aselnam,
       pa_askbprn,
       pa_audsbat,
       pa_autadul,
       pa_autoaud,
       pa_autonoa,
       pa_autoper,
       pa_avl6pm,
       pa_avllvrt,
       pa_avlpct1,
       pa_avlpct2,
       pa_avlpct3,
       pa_billpm,
       pa_billrda,
       pa_biltsel,
       pa_blz,
       pa_bmspay,
       pa_bmstype,
       pa_bsdays,
       pa_bsrdfac,
       pa_bsslfac,
       pa_buildin,
       pa_cancrte,
       pa_cdcapt,
       pa_cdttt,
       pa_ciwebdr,
       pa_comsg,
       pa_concapt,
       pa_connew,
       pa_connold,
       pa_conttt,
       pa_copylng,
       pa_corprbc,
       pa_cpybcxl,
       pa_cpycini,
       pa_cwcompr,
       pa_cwhour0,
       pa_cwhour1,
       pa_cwhour2,
       pa_cwhour3,
       pa_cwrauto,
       pa_cwrunho,
       pa_cwsync,
       pa_dbvers,
       pa_defadri,
       pa_defmark,
       pa_defsour,
       pa_delrstr,
       pa_depbefa,
       pa_depgfor,
       pa_deppay,
       pa_depperc,
       pa_depvat,
       pa_docname,
       pa_dpend,
       pa_dppostp,
       pa_dpstart,
       pa_email,
       pa_encrinw,
       pa_exsdef,
       pa_faxno,
       pa_fcstdp1,
       pa_fcstdp2,
       pa_fcstdp3,
       pa_fixonda,
       pa_globlid,
       pa_grcacpr,
       pa_gromcap,
       pa_gsknotg,
       pa_hotcode,
       pa_iban,
       pa_ifcnoci,
       pa_imexpos,
       pa_incallt,
       pa_intarti,
       pa_intcs,
       pa_intifc,
       pa_intsync,
       pa_mailask,
       pa_mailreq,
       pa_manager,
       pa_noaddr,
       pa_nobalch,
       pa_nomsgci,
       pa_noresid,
       pa_ooostd,
       pa_oosdef,
       pa_opacstd,
       pa_optbefr,
       pa_paid,
       pa_paidopm,
       pa_phone,
       pa_posarde,
       pa_poseigz,
       pa_posssch,
       pa_ppuser1,
       pa_ppuser2,
       pa_ppuser3,
       pa_ppuser4,
       pa_ppuser5,
       pa_ppuset1,
       pa_ppuset2,
       pa_ppuset3,
       pa_ppuset4,
       pa_ppuset5,
       pa_pttrmc,
       pa_radetai,
       pa_rauser1,
       pa_rauser2,
       pa_rauser3,
       pa_rauser4,
       pa_rauset1,
       pa_rauset2,
       pa_rauset3,
       pa_rauset4,
       pa_rccxlat,
       pa_rentmod,
       pa_resnotf,
       pa_restran,
       pa_rftofix,
       pa_rminfo1,
       pa_rminfo2,
       pa_rmuser0,
       pa_rmuser4,
       pa_rmuser5,
       pa_rmuser6,
       pa_rmuser7,
       pa_rmuser8,
       pa_rmuser9,
       pa_romcapt,
       pa_romttt,
       pa_rpgrpsp,
       pa_rprtclr,
       pa_rsuset0,
       pa_rsuset1,
       pa_rsuset2,
       pa_rsuset3,
       pa_rsuset4,
       pa_rsuset5,
       pa_rsuset6,
       pa_rsuset7,
       pa_rsuset8,
       pa_rsuset9,
       pa_setbici,
       pa_setgbns,
       pa_sgrpbl,
       pa_shbsprc,
       pa_shciall,
       pa_shexria,
       pa_showufd,
       pa_spabill,
       pa_srvpath,
       pa_street,
       pa_swift,
       pa_syncstd,
       pa_tempcon,
       pa_tempin,
       pa_tempout,
       pa_tenaopt,
       pa_tkround,
       pa_tpdimax,
       pa_tpdimin,
       pa_updatef,
       pa_usrero0,
       pa_usrero1,
       pa_usrero2,
       pa_usrero3,
       pa_usrero4,
       pa_usrero5,
       pa_usrero6,
       pa_usrero7,
       pa_usrero8,
       pa_usrero9,
       pa_ustidnr,
       pa_vatnr,
       pa_vodebch,
       pa_waaudit,
       pa_wbautoc,
       pa_wbmin,
       pa_wbmin1,
       pa_wbmin2,
       pa_wbmin3,
       pa_website,
       pa_welldir,
       pa_wellifc,
       pa_wexedir,
       pa_wimax,
       pa_wrndmin,
       pa_wsrooms,
       pa_zearbil
    FROM param2
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_abcodat L       DEFAULT .F.,
    pa_acctnr  C(30)   DEFAULT "",
    pa_adesunq L       DEFAULT .F.,
    pa_adrcomp L       DEFAULT .F.,
    pa_adrmupd T       DEFAULT {},
    pa_adrtyco L       DEFAULT .F.,
    pa_adrtyeq L       DEFAULT .F.,
    pa_agnbwin I       DEFAULT 0,
    pa_argusdr C(100)  DEFAULT "",
    pa_arhdate D       DEFAULT {},
    pa_aruser4 C(20)   DEFAULT "",
    pa_aruser5 C(20)   DEFAULT "",
    pa_aruser6 C(20)   DEFAULT "",
    pa_aruser7 C(20)   DEFAULT "",
    pa_aruset4 C(1)    DEFAULT "",
    pa_aruset5 C(1)    DEFAULT "",
    pa_aruset6 C(1)    DEFAULT "",
    pa_aruset7 C(1)    DEFAULT "",
    pa_aselnam L       DEFAULT .F.,
    pa_askbprn L       DEFAULT .F.,
    pa_audsbat C(3)    DEFAULT "",
    pa_autadul L       DEFAULT .F.,
    pa_autoaud L       DEFAULT .F.,
    pa_autonoa L       DEFAULT .F.,
    pa_autoper L       DEFAULT .F.,
    pa_avl6pm  L       DEFAULT .F.,
    pa_avllvrt L       DEFAULT .F.,
    pa_avlpct1 N(2,0)  DEFAULT 0,
    pa_avlpct2 N(2,0)  DEFAULT 0,
    pa_avlpct3 N(2,0)  DEFAULT 0,
    pa_billpm  L       DEFAULT .F.,
    pa_billrda L       DEFAULT .F.,
    pa_biltsel L       DEFAULT .F.,
    pa_blz     C(20)   DEFAULT "",
    pa_bmspay  N(3,0)  DEFAULT 0,
    pa_bmstype N(1,0)  DEFAULT 0,
    pa_bsdays  N(4,0)  DEFAULT 0,
    pa_bsrdfac N(12,3) DEFAULT 0,
    pa_bsslfac N(12,3) DEFAULT 0,
    pa_buildin L       DEFAULT .F.,
    pa_cancrte L       DEFAULT .F.,
    pa_cdcapt  M       DEFAULT "",
    pa_cdttt   M       DEFAULT "",
    pa_ciwebdr C(70)   DEFAULT "",
    pa_comsg   M       DEFAULT "",
    pa_concapt M       DEFAULT "",
    pa_connew  L       DEFAULT .F.,
    pa_connold L       DEFAULT .F.,
    pa_conttt  M       DEFAULT "",
    pa_copylng C(3)    DEFAULT "",
    pa_corprbc L       DEFAULT .F.,
    pa_cpybcxl L       DEFAULT .F.,
    pa_cpycini L       DEFAULT .F.,
    pa_cwcompr L       DEFAULT .F.,
    pa_cwhour0 N(2,0)  DEFAULT 0,
    pa_cwhour1 N(2,0)  DEFAULT 0,
    pa_cwhour2 N(2,0)  DEFAULT 0,
    pa_cwhour3 N(2,0)  DEFAULT 0,
    pa_cwrauto L       DEFAULT .F.,
    pa_cwrunho N(2,0)  DEFAULT 0,
    pa_cwsync  L       DEFAULT .F.,
    pa_dbvers  C(14)   DEFAULT "",
    pa_defadri I       DEFAULT 0,
    pa_defmark C(3)    DEFAULT "",
    pa_defsour C(3)    DEFAULT "",
    pa_delrstr L       DEFAULT .F.,
    pa_depbefa N(3,0)  DEFAULT 0,
    pa_depgfor N(1,0)  DEFAULT 0,
    pa_deppay  N(2,0)  DEFAULT 0,
    pa_depperc N(2,0)  DEFAULT 0,
    pa_depvat  L       DEFAULT .F.,
    pa_docname L       DEFAULT .F.,
    pa_dpend   N(2,0)  DEFAULT 0,
    pa_dppostp L       DEFAULT .F.,
    pa_dpstart N(2,0)  DEFAULT 0,
    pa_email   C(100)  DEFAULT "",
    pa_encrinw L       DEFAULT .F.,
    pa_exsdef  L       DEFAULT .F.,
    pa_faxno   C(100)  DEFAULT "",
    pa_fcstdp1 C(100)  DEFAULT "",
    pa_fcstdp2 C(100)  DEFAULT "",
    pa_fcstdp3 C(100)  DEFAULT "",
    pa_fixonda L       DEFAULT .F.,
    pa_globlid C(13)   DEFAULT "",
    pa_grcacpr L       DEFAULT .F.,
    pa_gromcap M       DEFAULT "",
    pa_gsknotg L       DEFAULT .F.,
    pa_hotcode C(10)   DEFAULT "",
    pa_iban    C(25)   DEFAULT "",
    pa_ifcnoci L       DEFAULT .F.,
    pa_imexpos L       DEFAULT .F.,
    pa_incallt L       DEFAULT .F.,
    pa_intarti N(4,0)  DEFAULT 0,
    pa_intcs   L       DEFAULT .F.,
    pa_intifc  L       DEFAULT .F.,
    pa_intsync L       DEFAULT .F.,
    pa_mailask L       DEFAULT .F.,
    pa_mailreq L       DEFAULT .F.,
    pa_manager C(100)  DEFAULT "",
    pa_noaddr  L       DEFAULT .F.,
    pa_nobalch L       DEFAULT .F.,
    pa_nomsgci L       DEFAULT .F.,
    pa_noresid L       DEFAULT .F.,
    pa_ooostd  L       DEFAULT .F.,
    pa_oosdef  L       DEFAULT .F.,
    pa_opacstd L       DEFAULT .F.,
    pa_optbefr N(3,0)  DEFAULT 0,
    pa_paid    N(1,0)  DEFAULT 0,
    pa_paidopm N(2,0)  DEFAULT 0,
    pa_phone   C(20)   DEFAULT "",
    pa_posarde C(50)   DEFAULT "",
    pa_poseigz L       DEFAULT .F.,
    pa_posssch L       DEFAULT .F.,
    pa_ppuser1 C(20)   DEFAULT "",
    pa_ppuser2 C(20)   DEFAULT "",
    pa_ppuser3 C(20)   DEFAULT "",
    pa_ppuser4 C(20)   DEFAULT "",
    pa_ppuser5 C(20)   DEFAULT "",
    pa_ppuset1 C(1)    DEFAULT "",
    pa_ppuset2 C(1)    DEFAULT "",
    pa_ppuset3 C(1)    DEFAULT "",
    pa_ppuset4 C(1)    DEFAULT "",
    pa_ppuset5 C(1)    DEFAULT "",
    pa_pttrmc  L       DEFAULT .F.,
    pa_radetai L       DEFAULT .F.,
    pa_rauser1 C(20)   DEFAULT "",
    pa_rauser2 C(20)   DEFAULT "",
    pa_rauser3 C(20)   DEFAULT "",
    pa_rauser4 C(20)   DEFAULT "",
    pa_rauset1 C(1)    DEFAULT "",
    pa_rauset2 C(1)    DEFAULT "",
    pa_rauset3 C(1)    DEFAULT "",
    pa_rauset4 C(1)    DEFAULT "",
    pa_rccxlat C(3)    DEFAULT "",
    pa_rentmod L       DEFAULT .F.,
    pa_resnotf N(2,0)  DEFAULT 0,
    pa_restran L       DEFAULT .F.,
    pa_rftofix L       DEFAULT .F.,
    pa_rminfo1 C(30)   DEFAULT "",
    pa_rminfo2 C(30)   DEFAULT "",
    pa_rmuser0 C(20)   DEFAULT "",
    pa_rmuser4 C(20)   DEFAULT "",
    pa_rmuser5 C(20)   DEFAULT "",
    pa_rmuser6 C(20)   DEFAULT "",
    pa_rmuser7 C(20)   DEFAULT "",
    pa_rmuser8 C(20)   DEFAULT "",
    pa_rmuser9 C(20)   DEFAULT "",
    pa_romcapt M       DEFAULT "",
    pa_romttt  M       DEFAULT "",
    pa_rpgrpsp L       DEFAULT .F.,
    pa_rprtclr L       DEFAULT .F.,
    pa_rsuset0 C(1)    DEFAULT "",
    pa_rsuset1 C(1)    DEFAULT "",
    pa_rsuset2 C(1)    DEFAULT "",
    pa_rsuset3 C(1)    DEFAULT "",
    pa_rsuset4 C(1)    DEFAULT "",
    pa_rsuset5 C(1)    DEFAULT "",
    pa_rsuset6 C(1)    DEFAULT "",
    pa_rsuset7 C(1)    DEFAULT "",
    pa_rsuset8 C(1)    DEFAULT "",
    pa_rsuset9 C(1)    DEFAULT "",
    pa_setbici L       DEFAULT .F.,
    pa_setgbns L       DEFAULT .F.,
    pa_sgrpbl  L       DEFAULT .F.,
    pa_shbsprc L       DEFAULT .F.,
    pa_shciall L       DEFAULT .F.,
    pa_shexria L       DEFAULT .F.,
    pa_showufd L       DEFAULT .F.,
    pa_spabill L       DEFAULT .F.,
    pa_srvpath C(254)  DEFAULT "",
    pa_street  C(100)  DEFAULT "",
    pa_swift   C(15)   DEFAULT "",
    pa_syncstd L       DEFAULT .F.,
    pa_tempcon L       DEFAULT .F.,
    pa_tempin  I       DEFAULT 0,
    pa_tempout I       DEFAULT 0,
    pa_tenaopt L       DEFAULT .F.,
    pa_tkround N(2,0)  DEFAULT 0,
    pa_tpdimax I       DEFAULT 0,
    pa_tpdimin I       DEFAULT 0,
    pa_updatef C(14)   DEFAULT "",
    pa_usrero0 L       DEFAULT .F.,
    pa_usrero1 L       DEFAULT .F.,
    pa_usrero2 L       DEFAULT .F.,
    pa_usrero3 L       DEFAULT .F.,
    pa_usrero4 L       DEFAULT .F.,
    pa_usrero5 L       DEFAULT .F.,
    pa_usrero6 L       DEFAULT .F.,
    pa_usrero7 L       DEFAULT .F.,
    pa_usrero8 L       DEFAULT .F.,
    pa_usrero9 L       DEFAULT .F.,
    pa_ustidnr C(20)   DEFAULT "",
    pa_vatnr   C(20)   DEFAULT "",
    pa_vodebch L       DEFAULT .F.,
    pa_waaudit L       DEFAULT .F.,
    pa_wbautoc L       DEFAULT .F.,
    pa_wbmin   N(3,0)  DEFAULT 0,
    pa_wbmin1  N(3,0)  DEFAULT 0,
    pa_wbmin2  N(3,0)  DEFAULT 0,
    pa_wbmin3  N(3,0)  DEFAULT 0,
    pa_website C(60)   DEFAULT "",
    pa_welldir C(100)  DEFAULT "",
    pa_wellifc L       DEFAULT .F.,
    pa_wexedir C(100)  DEFAULT "",
    pa_wimax   N(2,0)  DEFAULT 0,
    pa_wrndmin N(2,0)  DEFAULT 0,
    pa_wsrooms L       DEFAULT .F.,
    pa_zearbil L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_abcodat,
    pa_acctnr,
    pa_adesunq,
    pa_adrcomp,
    pa_adrmupd,
    pa_adrtyco,
    pa_adrtyeq,
    pa_agnbwin,
    pa_argusdr,
    pa_arhdate,
    pa_aruser4,
    pa_aruser5,
    pa_aruser6,
    pa_aruser7,
    pa_aruset4,
    pa_aruset5,
    pa_aruset6,
    pa_aruset7,
    pa_aselnam,
    pa_askbprn,
    pa_audsbat,
    pa_autadul,
    pa_autoaud,
    pa_autonoa,
    pa_autoper,
    pa_avl6pm,
    pa_avllvrt,
    pa_avlpct1,
    pa_avlpct2,
    pa_avlpct3,
    pa_billpm,
    pa_billrda,
    pa_biltsel,
    pa_blz,
    pa_bmspay,
    pa_bmstype,
    pa_bsdays,
    pa_bsrdfac,
    pa_bsslfac,
    pa_buildin,
    pa_cancrte,
    pa_cdcapt,
    pa_cdttt,
    pa_ciwebdr,
    pa_comsg,
    pa_concapt,
    pa_connew,
    pa_connold,
    pa_conttt,
    pa_copylng,
    pa_corprbc,
    pa_cpybcxl,
    pa_cpycini,
    pa_cwcompr,
    pa_cwhour0,
    pa_cwhour1,
    pa_cwhour2,
    pa_cwhour3,
    pa_cwrauto,
    pa_cwrunho,
    pa_cwsync,
    pa_dbvers,
    pa_defadri,
    pa_defmark,
    pa_defsour,
    pa_delrstr,
    pa_depbefa,
    pa_depgfor,
    pa_deppay,
    pa_depperc,
    pa_depvat,
    pa_docname,
    pa_dpend,
    pa_dppostp,
    pa_dpstart,
    pa_email,
    pa_encrinw,
    pa_exsdef,
    pa_faxno,
    pa_fcstdp1,
    pa_fcstdp2,
    pa_fcstdp3,
    pa_fixonda,
    pa_globlid,
    pa_grcacpr,
    pa_gromcap,
    pa_gsknotg,
    pa_hotcode,
    pa_iban,
    pa_ifcnoci,
    pa_imexpos,
    pa_incallt,
    pa_intarti,
    pa_intcs,
    pa_intifc,
    pa_intsync,
    pa_mailask,
    pa_mailreq,
    pa_manager,
    pa_noaddr,
    pa_nobalch,
    pa_nomsgci,
    pa_noresid,
    pa_ooostd,
    pa_oosdef,
    pa_opacstd,
    pa_optbefr,
    pa_paid,
    pa_paidopm,
    pa_phone,
    pa_posarde,
    pa_poseigz,
    pa_posssch,
    pa_ppuser1,
    pa_ppuser2,
    pa_ppuser3,
    pa_ppuser4,
    pa_ppuser5,
    pa_ppuset1,
    pa_ppuset2,
    pa_ppuset3,
    pa_ppuset4,
    pa_ppuset5,
    pa_pttrmc,
    pa_radetai,
    pa_rauser1,
    pa_rauser2,
    pa_rauser3,
    pa_rauser4,
    pa_rauset1,
    pa_rauset2,
    pa_rauset3,
    pa_rauset4,
    pa_rccxlat,
    pa_rentmod,
    pa_resnotf,
    pa_restran,
    pa_rftofix,
    pa_rminfo1,
    pa_rminfo2,
    pa_rmuser0,
    pa_rmuser4,
    pa_rmuser5,
    pa_rmuser6,
    pa_rmuser7,
    pa_rmuser8,
    pa_rmuser9,
    pa_romcapt,
    pa_romttt,
    pa_rpgrpsp,
    pa_rprtclr,
    pa_rsuset0,
    pa_rsuset1,
    pa_rsuset2,
    pa_rsuset3,
    pa_rsuset4,
    pa_rsuset5,
    pa_rsuset6,
    pa_rsuset7,
    pa_rsuset8,
    pa_rsuset9,
    pa_setbici,
    pa_setgbns,
    pa_sgrpbl,
    pa_shbsprc,
    pa_shciall,
    pa_shexria,
    pa_showufd,
    pa_spabill,
    pa_srvpath,
    pa_street,
    pa_swift,
    pa_syncstd,
    pa_tempcon,
    pa_tempin,
    pa_tempout,
    pa_tenaopt,
    pa_tkround,
    pa_tpdimax,
    pa_tpdimin,
    pa_updatef,
    pa_usrero0,
    pa_usrero1,
    pa_usrero2,
    pa_usrero3,
    pa_usrero4,
    pa_usrero5,
    pa_usrero6,
    pa_usrero7,
    pa_usrero8,
    pa_usrero9,
    pa_ustidnr,
    pa_vatnr,
    pa_vodebch,
    pa_waaudit,
    pa_wbautoc,
    pa_wbmin,
    pa_wbmin1,
    pa_wbmin2,
    pa_wbmin3,
    pa_website,
    pa_welldir,
    pa_wellifc,
    pa_wexedir,
    pa_wimax,
    pa_wrndmin,
    pa_wsrooms,
    pa_zearbil
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_abcodat param2.pa_abcodat,
    pa_acctnr  param2.pa_acctnr,
    pa_adesunq param2.pa_adesunq,
    pa_adrcomp param2.pa_adrcomp,
    pa_adrmupd param2.pa_adrmupd,
    pa_adrtyco param2.pa_adrtyco,
    pa_adrtyeq param2.pa_adrtyeq,
    pa_agnbwin param2.pa_agnbwin,
    pa_argusdr param2.pa_argusdr,
    pa_arhdate param2.pa_arhdate,
    pa_aruser4 param2.pa_aruser4,
    pa_aruser5 param2.pa_aruser5,
    pa_aruser6 param2.pa_aruser6,
    pa_aruser7 param2.pa_aruser7,
    pa_aruset4 param2.pa_aruset4,
    pa_aruset5 param2.pa_aruset5,
    pa_aruset6 param2.pa_aruset6,
    pa_aruset7 param2.pa_aruset7,
    pa_aselnam param2.pa_aselnam,
    pa_askbprn param2.pa_askbprn,
    pa_audsbat param2.pa_audsbat,
    pa_autadul param2.pa_autadul,
    pa_autoaud param2.pa_autoaud,
    pa_autonoa param2.pa_autonoa,
    pa_autoper param2.pa_autoper,
    pa_avl6pm  param2.pa_avl6pm,
    pa_avllvrt param2.pa_avllvrt,
    pa_avlpct1 param2.pa_avlpct1,
    pa_avlpct2 param2.pa_avlpct2,
    pa_avlpct3 param2.pa_avlpct3,
    pa_billpm  param2.pa_billpm,
    pa_billrda param2.pa_billrda,
    pa_biltsel param2.pa_biltsel,
    pa_blz     param2.pa_blz,
    pa_bmspay  param2.pa_bmspay,
    pa_bmstype param2.pa_bmstype,
    pa_bsdays  param2.pa_bsdays,
    pa_bsrdfac param2.pa_bsrdfac,
    pa_bsslfac param2.pa_bsslfac,
    pa_buildin param2.pa_buildin,
    pa_cancrte param2.pa_cancrte,
    pa_cdcapt  param2.pa_cdcapt,
    pa_cdttt   param2.pa_cdttt,
    pa_ciwebdr param2.pa_ciwebdr,
    pa_comsg   param2.pa_comsg,
    pa_concapt param2.pa_concapt,
    pa_connew  param2.pa_connew,
    pa_connold param2.pa_connold,
    pa_conttt  param2.pa_conttt,
    pa_copylng param2.pa_copylng,
    pa_corprbc param2.pa_corprbc,
    pa_cpybcxl param2.pa_cpybcxl,
    pa_cpycini param2.pa_cpycini,
    pa_cwcompr param2.pa_cwcompr,
    pa_cwhour0 param2.pa_cwhour0,
    pa_cwhour1 param2.pa_cwhour1,
    pa_cwhour2 param2.pa_cwhour2,
    pa_cwhour3 param2.pa_cwhour3,
    pa_cwrauto param2.pa_cwrauto,
    pa_cwrunho param2.pa_cwrunho,
    pa_cwsync  param2.pa_cwsync,
    pa_dbvers  param2.pa_dbvers,
    pa_defadri param2.pa_defadri,
    pa_defmark param2.pa_defmark,
    pa_defsour param2.pa_defsour,
    pa_delrstr param2.pa_delrstr,
    pa_depbefa param2.pa_depbefa,
    pa_depgfor param2.pa_depgfor,
    pa_deppay  param2.pa_deppay,
    pa_depperc param2.pa_depperc,
    pa_depvat  param2.pa_depvat,
    pa_docname param2.pa_docname,
    pa_dpend   param2.pa_dpend,
    pa_dppostp param2.pa_dppostp,
    pa_dpstart param2.pa_dpstart,
    pa_email   param2.pa_email,
    pa_encrinw param2.pa_encrinw,
    pa_exsdef  param2.pa_exsdef,
    pa_faxno   param2.pa_faxno,
    pa_fcstdp1 param2.pa_fcstdp1,
    pa_fcstdp2 param2.pa_fcstdp2,
    pa_fcstdp3 param2.pa_fcstdp3,
    pa_fixonda param2.pa_fixonda,
    pa_globlid param2.pa_globlid,
    pa_grcacpr param2.pa_grcacpr,
    pa_gromcap param2.pa_gromcap,
    pa_gsknotg param2.pa_gsknotg,
    pa_hotcode param2.pa_hotcode,
    pa_iban    param2.pa_iban,
    pa_ifcnoci param2.pa_ifcnoci,
    pa_imexpos param2.pa_imexpos,
    pa_incallt param2.pa_incallt,
    pa_intarti param2.pa_intarti,
    pa_intcs   param2.pa_intcs,
    pa_intifc  param2.pa_intifc,
    pa_intsync param2.pa_intsync,
    pa_mailask param2.pa_mailask,
    pa_mailreq param2.pa_mailreq,
    pa_manager param2.pa_manager,
    pa_noaddr  param2.pa_noaddr,
    pa_nobalch param2.pa_nobalch,
    pa_nomsgci param2.pa_nomsgci,
    pa_noresid param2.pa_noresid,
    pa_ooostd  param2.pa_ooostd,
    pa_oosdef  param2.pa_oosdef,
    pa_opacstd param2.pa_opacstd,
    pa_optbefr param2.pa_optbefr,
    pa_paid    param2.pa_paid,
    pa_paidopm param2.pa_paidopm,
    pa_phone   param2.pa_phone,
    pa_posarde param2.pa_posarde,
    pa_poseigz param2.pa_poseigz,
    pa_posssch param2.pa_posssch,
    pa_ppuser1 param2.pa_ppuser1,
    pa_ppuser2 param2.pa_ppuser2,
    pa_ppuser3 param2.pa_ppuser3,
    pa_ppuser4 param2.pa_ppuser4,
    pa_ppuser5 param2.pa_ppuser5,
    pa_ppuset1 param2.pa_ppuset1,
    pa_ppuset2 param2.pa_ppuset2,
    pa_ppuset3 param2.pa_ppuset3,
    pa_ppuset4 param2.pa_ppuset4,
    pa_ppuset5 param2.pa_ppuset5,
    pa_pttrmc  param2.pa_pttrmc,
    pa_radetai param2.pa_radetai,
    pa_rauser1 param2.pa_rauser1,
    pa_rauser2 param2.pa_rauser2,
    pa_rauser3 param2.pa_rauser3,
    pa_rauser4 param2.pa_rauser4,
    pa_rauset1 param2.pa_rauset1,
    pa_rauset2 param2.pa_rauset2,
    pa_rauset3 param2.pa_rauset3,
    pa_rauset4 param2.pa_rauset4,
    pa_rccxlat param2.pa_rccxlat,
    pa_rentmod param2.pa_rentmod,
    pa_resnotf param2.pa_resnotf,
    pa_restran param2.pa_restran,
    pa_rftofix param2.pa_rftofix,
    pa_rminfo1 param2.pa_rminfo1,
    pa_rminfo2 param2.pa_rminfo2,
    pa_rmuser0 param2.pa_rmuser0,
    pa_rmuser4 param2.pa_rmuser4,
    pa_rmuser5 param2.pa_rmuser5,
    pa_rmuser6 param2.pa_rmuser6,
    pa_rmuser7 param2.pa_rmuser7,
    pa_rmuser8 param2.pa_rmuser8,
    pa_rmuser9 param2.pa_rmuser9,
    pa_romcapt param2.pa_romcapt,
    pa_romttt  param2.pa_romttt,
    pa_rpgrpsp param2.pa_rpgrpsp,
    pa_rprtclr param2.pa_rprtclr,
    pa_rsuset0 param2.pa_rsuset0,
    pa_rsuset1 param2.pa_rsuset1,
    pa_rsuset2 param2.pa_rsuset2,
    pa_rsuset3 param2.pa_rsuset3,
    pa_rsuset4 param2.pa_rsuset4,
    pa_rsuset5 param2.pa_rsuset5,
    pa_rsuset6 param2.pa_rsuset6,
    pa_rsuset7 param2.pa_rsuset7,
    pa_rsuset8 param2.pa_rsuset8,
    pa_rsuset9 param2.pa_rsuset9,
    pa_setbici param2.pa_setbici,
    pa_setgbns param2.pa_setgbns,
    pa_sgrpbl  param2.pa_sgrpbl,
    pa_shbsprc param2.pa_shbsprc,
    pa_shciall param2.pa_shciall,
    pa_shexria param2.pa_shexria,
    pa_showufd param2.pa_showufd,
    pa_spabill param2.pa_spabill,
    pa_srvpath param2.pa_srvpath,
    pa_street  param2.pa_street,
    pa_swift   param2.pa_swift,
    pa_syncstd param2.pa_syncstd,
    pa_tempcon param2.pa_tempcon,
    pa_tempin  param2.pa_tempin,
    pa_tempout param2.pa_tempout,
    pa_tenaopt param2.pa_tenaopt,
    pa_tkround param2.pa_tkround,
    pa_tpdimax param2.pa_tpdimax,
    pa_tpdimin param2.pa_tpdimin,
    pa_updatef param2.pa_updatef,
    pa_usrero0 param2.pa_usrero0,
    pa_usrero1 param2.pa_usrero1,
    pa_usrero2 param2.pa_usrero2,
    pa_usrero3 param2.pa_usrero3,
    pa_usrero4 param2.pa_usrero4,
    pa_usrero5 param2.pa_usrero5,
    pa_usrero6 param2.pa_usrero6,
    pa_usrero7 param2.pa_usrero7,
    pa_usrero8 param2.pa_usrero8,
    pa_usrero9 param2.pa_usrero9,
    pa_ustidnr param2.pa_ustidnr,
    pa_vatnr   param2.pa_vatnr,
    pa_vodebch param2.pa_vodebch,
    pa_waaudit param2.pa_waaudit,
    pa_wbautoc param2.pa_wbautoc,
    pa_wbmin   param2.pa_wbmin,
    pa_wbmin1  param2.pa_wbmin1,
    pa_wbmin2  param2.pa_wbmin2,
    pa_wbmin3  param2.pa_wbmin3,
    pa_website param2.pa_website,
    pa_welldir param2.pa_welldir,
    pa_wellifc param2.pa_wellifc,
    pa_wexedir param2.pa_wexedir,
    pa_wimax   param2.pa_wimax,
    pa_wrndmin param2.pa_wrndmin,
    pa_wsrooms param2.pa_wsrooms,
    pa_zearbil param2.pa_zearbil
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capaymetho AS caBase OF cit_ca.vcx
Alias = [capaymetho]
Tables = [paymetho]
KeyFieldList = [pm_paynum]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pm_addamnt,
       pm_addarti,
       pm_addpct,
       pm_aracct,
       pm_aronly,
       pm_askfa,
       pm_buildng,
       pm_calcrat,
       pm_ccifc,
       pm_commpct,
       pm_compid,
       pm_copy,
       pm_dep1day,
       pm_dep1per,
       pm_dep1whe,
       pm_dep2day,
       pm_dep2per,
       pm_dep2whe,
       pm_deposit,
       pm_elpay,
       pm_elpyman,
       pm_elpynum,
       pm_elpypad,
       pm_elpyza,
       pm_inactiv,
       pm_ineuro,
       pm_kiosk,
       pm_lang1,
       pm_lang10,
       pm_lang11,
       pm_lang2,
       pm_lang3,
       pm_lang4,
       pm_lang5,
       pm_lang6,
       pm_lang7,
       pm_lang8,
       pm_lang9,
       pm_opendrw,
       pm_paymeth,
       pm_paynum,
       pm_paytyp,
       pm_rate,
       pm_user1,
       pm_user2,
       pm_user3,
       pm_usrgrp,
       pm_wbccafc
    FROM paymetho
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pm_addamnt B(2)    DEFAULT 0,
    pm_addarti N(4,0)  DEFAULT 0,
    pm_addpct  B(2)    DEFAULT 0,
    pm_aracct  N(10,0) DEFAULT 0,
    pm_aronly  L       DEFAULT .F.,
    pm_askfa   L       DEFAULT .F.,
    pm_buildng C(3)    DEFAULT "",
    pm_calcrat B(14)   DEFAULT 0,
    pm_ccifc   L       DEFAULT .F.,
    pm_commpct B(2)    DEFAULT 0,
    pm_compid  N(8,0)  DEFAULT 0,
    pm_copy    N(1,0)  DEFAULT 0,
    pm_dep1day N(3,0)  DEFAULT 0,
    pm_dep1per B(2)    DEFAULT 0,
    pm_dep1whe N(1,0)  DEFAULT 0,
    pm_dep2day N(3,0)  DEFAULT 0,
    pm_dep2per B(2)    DEFAULT 0,
    pm_dep2whe N(1,0)  DEFAULT 0,
    pm_deposit L       DEFAULT .F.,
    pm_elpay   L       DEFAULT .F.,
    pm_elpyman L       DEFAULT .F.,
    pm_elpynum N(2,0)  DEFAULT 0,
    pm_elpypad L       DEFAULT .F.,
    pm_elpyza  C(2)    DEFAULT "",
    pm_inactiv L       DEFAULT .F.,
    pm_ineuro  L       DEFAULT .F.,
    pm_kiosk   L       DEFAULT .F.,
    pm_lang1   C(25)   DEFAULT "",
    pm_lang10  C(25)   DEFAULT "",
    pm_lang11  C(25)   DEFAULT "",
    pm_lang2   C(25)   DEFAULT "",
    pm_lang3   C(25)   DEFAULT "",
    pm_lang4   C(25)   DEFAULT "",
    pm_lang5   C(25)   DEFAULT "",
    pm_lang6   C(25)   DEFAULT "",
    pm_lang7   C(25)   DEFAULT "",
    pm_lang8   C(25)   DEFAULT "",
    pm_lang9   C(25)   DEFAULT "",
    pm_opendrw L       DEFAULT .F.,
    pm_paymeth C(4)    DEFAULT "",
    pm_paynum  N(3,0)  DEFAULT 0,
    pm_paytyp  N(1,0)  DEFAULT 0,
    pm_rate    B(6)    DEFAULT 0,
    pm_user1   C(20)   DEFAULT "",
    pm_user2   C(20)   DEFAULT "",
    pm_user3   C(20)   DEFAULT "",
    pm_usrgrp  C(100)  DEFAULT "",
    pm_wbccafc C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pm_addamnt,
    pm_addarti,
    pm_addpct,
    pm_aracct,
    pm_aronly,
    pm_askfa,
    pm_buildng,
    pm_calcrat,
    pm_ccifc,
    pm_commpct,
    pm_compid,
    pm_copy,
    pm_dep1day,
    pm_dep1per,
    pm_dep1whe,
    pm_dep2day,
    pm_dep2per,
    pm_dep2whe,
    pm_deposit,
    pm_elpay,
    pm_elpyman,
    pm_elpynum,
    pm_elpypad,
    pm_elpyza,
    pm_inactiv,
    pm_ineuro,
    pm_kiosk,
    pm_lang1,
    pm_lang10,
    pm_lang11,
    pm_lang2,
    pm_lang3,
    pm_lang4,
    pm_lang5,
    pm_lang6,
    pm_lang7,
    pm_lang8,
    pm_lang9,
    pm_opendrw,
    pm_paymeth,
    pm_paynum,
    pm_paytyp,
    pm_rate,
    pm_user1,
    pm_user2,
    pm_user3,
    pm_usrgrp,
    pm_wbccafc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pm_addamnt paymetho.pm_addamnt,
    pm_addarti paymetho.pm_addarti,
    pm_addpct  paymetho.pm_addpct,
    pm_aracct  paymetho.pm_aracct,
    pm_aronly  paymetho.pm_aronly,
    pm_askfa   paymetho.pm_askfa,
    pm_buildng paymetho.pm_buildng,
    pm_calcrat paymetho.pm_calcrat,
    pm_ccifc   paymetho.pm_ccifc,
    pm_commpct paymetho.pm_commpct,
    pm_compid  paymetho.pm_compid,
    pm_copy    paymetho.pm_copy,
    pm_dep1day paymetho.pm_dep1day,
    pm_dep1per paymetho.pm_dep1per,
    pm_dep1whe paymetho.pm_dep1whe,
    pm_dep2day paymetho.pm_dep2day,
    pm_dep2per paymetho.pm_dep2per,
    pm_dep2whe paymetho.pm_dep2whe,
    pm_deposit paymetho.pm_deposit,
    pm_elpay   paymetho.pm_elpay,
    pm_elpyman paymetho.pm_elpyman,
    pm_elpynum paymetho.pm_elpynum,
    pm_elpypad paymetho.pm_elpypad,
    pm_elpyza  paymetho.pm_elpyza,
    pm_inactiv paymetho.pm_inactiv,
    pm_ineuro  paymetho.pm_ineuro,
    pm_kiosk   paymetho.pm_kiosk,
    pm_lang1   paymetho.pm_lang1,
    pm_lang10  paymetho.pm_lang10,
    pm_lang11  paymetho.pm_lang11,
    pm_lang2   paymetho.pm_lang2,
    pm_lang3   paymetho.pm_lang3,
    pm_lang4   paymetho.pm_lang4,
    pm_lang5   paymetho.pm_lang5,
    pm_lang6   paymetho.pm_lang6,
    pm_lang7   paymetho.pm_lang7,
    pm_lang8   paymetho.pm_lang8,
    pm_lang9   paymetho.pm_lang9,
    pm_opendrw paymetho.pm_opendrw,
    pm_paymeth paymetho.pm_paymeth,
    pm_paynum  paymetho.pm_paynum,
    pm_paytyp  paymetho.pm_paytyp,
    pm_rate    paymetho.pm_rate,
    pm_user1   paymetho.pm_user1,
    pm_user2   paymetho.pm_user2,
    pm_user3   paymetho.pm_user3,
    pm_usrgrp  paymetho.pm_usrgrp,
    pm_wbccafc paymetho.pm_wbccafc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caperiod AS caBase OF cit_ca.vcx
Alias = [caperiod]
Tables = [period]
KeyFieldList = [pe_period,pe_fromdat,pe_todat]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pe_fromdat,
       pe_period,
       pe_todat
    FROM period
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pe_fromdat D       DEFAULT {},
    pe_period  N(2,0)  DEFAULT 0,
    pe_todat   D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pe_fromdat,
    pe_period,
    pe_todat
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pe_fromdat period.pe_fromdat,
    pe_period  period.pe_period,
    pe_todat   period.pe_todat
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caphnote AS caBase OF cit_ca.vcx
Alias = [caphnote]
Tables = [phnote]
KeyFieldList = [ph_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ph_addrid,
       ph_apid,
       ph_date,
       ph_docid,
       ph_endt,
       ph_id,
       ph_note,
       ph_startt,
       ph_updated,
       ph_upuser,
       ph_user
    FROM phnote
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_addrid  N(8,0)  DEFAULT 0,
    ph_apid    N(8,0)  DEFAULT 0,
    ph_date    D       DEFAULT {},
    ph_docid   N(8,0)  DEFAULT 0,
    ph_endt    C(5)    DEFAULT "",
    ph_id      N(8,0)  DEFAULT 0,
    ph_note    M       DEFAULT "",
    ph_startt  C(5)    DEFAULT "",
    ph_updated T       DEFAULT {},
    ph_upuser  C(10)   DEFAULT "",
    ph_user    C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_addrid,
    ph_apid,
    ph_date,
    ph_docid,
    ph_endt,
    ph_id,
    ph_note,
    ph_startt,
    ph_updated,
    ph_upuser,
    ph_user
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_addrid  phnote.ph_addrid,
    ph_apid    phnote.ph_apid,
    ph_date    phnote.ph_date,
    ph_docid   phnote.ph_docid,
    ph_endt    phnote.ph_endt,
    ph_id      phnote.ph_id,
    ph_note    phnote.ph_note,
    ph_startt  phnote.ph_startt,
    ph_updated phnote.ph_updated,
    ph_upuser  phnote.ph_upuser,
    ph_user    phnote.ph_user
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capiart AS caBase OF cit_ca.vcx
Alias = [capiart]
Tables = [piart]
KeyFieldList = [pi_piid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pi_amnotax,
       pi_amount,
       pi_depname,
       pi_depno,
       pi_detaino,
       pi_field,
       pi_mainga,
       pi_maingan,
       pi_maingb,
       pi_maingbn,
       pi_piid,
       pi_plu,
       pi_pluname,
       pi_plutyp,
       pi_prclev,
       pi_pzid,
       pi_qty,
       pi_vat1,
       pi_vat2
    FROM piart
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pi_amnotax N(10,2) DEFAULT 0,
    pi_amount  N(10,2) DEFAULT 0,
    pi_depname C(50)   DEFAULT "",
    pi_depno   I       DEFAULT 0,
    pi_detaino I       DEFAULT 0,
    pi_field   I       DEFAULT 0,
    pi_mainga  I       DEFAULT 0,
    pi_maingan C(50)   DEFAULT "",
    pi_maingb  I       DEFAULT 0,
    pi_maingbn C(50)   DEFAULT "",
    pi_piid    I       DEFAULT 0,
    pi_plu     I       DEFAULT 0,
    pi_pluname C(50)   DEFAULT "",
    pi_plutyp  I       DEFAULT 0,
    pi_prclev  I       DEFAULT 0,
    pi_pzid    I       DEFAULT 0,
    pi_qty     N(7,2)  DEFAULT 0,
    pi_vat1    B(6)    DEFAULT 0,
    pi_vat2    B(6)    DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pi_amnotax,
    pi_amount,
    pi_depname,
    pi_depno,
    pi_detaino,
    pi_field,
    pi_mainga,
    pi_maingan,
    pi_maingb,
    pi_maingbn,
    pi_piid,
    pi_plu,
    pi_pluname,
    pi_plutyp,
    pi_prclev,
    pi_pzid,
    pi_qty,
    pi_vat1,
    pi_vat2
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pi_amnotax piart.pi_amnotax,
    pi_amount  piart.pi_amount,
    pi_depname piart.pi_depname,
    pi_depno   piart.pi_depno,
    pi_detaino piart.pi_detaino,
    pi_field   piart.pi_field,
    pi_mainga  piart.pi_mainga,
    pi_maingan piart.pi_maingan,
    pi_maingb  piart.pi_maingb,
    pi_maingbn piart.pi_maingbn,
    pi_piid    piart.pi_piid,
    pi_plu     piart.pi_plu,
    pi_pluname piart.pi_pluname,
    pi_plutyp  piart.pi_plutyp,
    pi_prclev  piart.pi_prclev,
    pi_pzid    piart.pi_pzid,
    pi_qty     piart.pi_qty,
    pi_vat1    piart.pi_vat1,
    pi_vat2    piart.pi_vat2
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capichk AS caBase OF cit_ca.vcx
Alias = [capichk]
Tables = [pichk]
KeyFieldList = [pz_pzid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pz_amnotax,
       pz_amount,
       pz_checkno,
       pz_created,
       pz_field,
       pz_posname,
       pz_posno,
       pz_pzid,
       pz_roomcha,
       pz_sysdate,
       pz_vat1,
       pz_vat2,
       pz_waiter,
       pz_waitno
    FROM pichk
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pz_amnotax N(10,2) DEFAULT 0,
    pz_amount  N(10,2) DEFAULT 0,
    pz_checkno I       DEFAULT 0,
    pz_created T       DEFAULT {},
    pz_field   I       DEFAULT 0,
    pz_posname C(20)   DEFAULT "",
    pz_posno   I       DEFAULT 0,
    pz_pzid    I       DEFAULT 0,
    pz_roomcha L       DEFAULT .F.,
    pz_sysdate D       DEFAULT {},
    pz_vat1    B(6)    DEFAULT 0,
    pz_vat2    B(6)    DEFAULT 0,
    pz_waiter  C(50)   DEFAULT "",
    pz_waitno  I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pz_amnotax,
    pz_amount,
    pz_checkno,
    pz_created,
    pz_field,
    pz_posname,
    pz_posno,
    pz_pzid,
    pz_roomcha,
    pz_sysdate,
    pz_vat1,
    pz_vat2,
    pz_waiter,
    pz_waitno
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pz_amnotax pichk.pz_amnotax,
    pz_amount  pichk.pz_amount,
    pz_checkno pichk.pz_checkno,
    pz_created pichk.pz_created,
    pz_field   pichk.pz_field,
    pz_posname pichk.pz_posname,
    pz_posno   pichk.pz_posno,
    pz_pzid    pichk.pz_pzid,
    pz_roomcha pichk.pz_roomcha,
    pz_sysdate pichk.pz_sysdate,
    pz_vat1    pichk.pz_vat1,
    pz_vat2    pichk.pz_vat2,
    pz_waiter  pichk.pz_waiter,
    pz_waitno  pichk.pz_waitno
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capicklist AS caBase OF cit_ca.vcx
Alias = [capicklist]
Tables = [picklist]
KeyFieldList = [pl_label,pl_charcod,pl_numcod]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pl_charcod,
       pl_inactiv,
       pl_label,
       pl_lang1,
       pl_lang10,
       pl_lang11,
       pl_lang2,
       pl_lang3,
       pl_lang4,
       pl_lang5,
       pl_lang6,
       pl_lang7,
       pl_lang8,
       pl_lang9,
       pl_memo,
       pl_numcod,
       pl_numval,
       pl_sequ,
       pl_user1,
       pl_user2,
       pl_user3,
       pl_user4,
       pl_user5
    FROM picklist
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pl_charcod C(3)    DEFAULT "",
    pl_inactiv L       DEFAULT .F.,
    pl_label   C(10)   DEFAULT "",
    pl_lang1   C(25)   DEFAULT "",
    pl_lang10  C(25)   DEFAULT "",
    pl_lang11  C(25)   DEFAULT "",
    pl_lang2   C(25)   DEFAULT "",
    pl_lang3   C(25)   DEFAULT "",
    pl_lang4   C(25)   DEFAULT "",
    pl_lang5   C(25)   DEFAULT "",
    pl_lang6   C(25)   DEFAULT "",
    pl_lang7   C(25)   DEFAULT "",
    pl_lang8   C(25)   DEFAULT "",
    pl_lang9   C(25)   DEFAULT "",
    pl_memo    M       DEFAULT "",
    pl_numcod  N(3,0)  DEFAULT 0,
    pl_numval  N(10,2) DEFAULT 0,
    pl_sequ    N(2,0)  DEFAULT 0,
    pl_user1   C(20)   DEFAULT "",
    pl_user2   C(20)   DEFAULT "",
    pl_user3   C(20)   DEFAULT "",
    pl_user4   C(20)   DEFAULT "",
    pl_user5   C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pl_charcod,
    pl_inactiv,
    pl_label,
    pl_lang1,
    pl_lang10,
    pl_lang11,
    pl_lang2,
    pl_lang3,
    pl_lang4,
    pl_lang5,
    pl_lang6,
    pl_lang7,
    pl_lang8,
    pl_lang9,
    pl_memo,
    pl_numcod,
    pl_numval,
    pl_sequ,
    pl_user1,
    pl_user2,
    pl_user3,
    pl_user4,
    pl_user5
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pl_charcod picklist.pl_charcod,
    pl_inactiv picklist.pl_inactiv,
    pl_label   picklist.pl_label,
    pl_lang1   picklist.pl_lang1,
    pl_lang10  picklist.pl_lang10,
    pl_lang11  picklist.pl_lang11,
    pl_lang2   picklist.pl_lang2,
    pl_lang3   picklist.pl_lang3,
    pl_lang4   picklist.pl_lang4,
    pl_lang5   picklist.pl_lang5,
    pl_lang6   picklist.pl_lang6,
    pl_lang7   picklist.pl_lang7,
    pl_lang8   picklist.pl_lang8,
    pl_lang9   picklist.pl_lang9,
    pl_memo    picklist.pl_memo,
    pl_numcod  picklist.pl_numcod,
    pl_numval  picklist.pl_numval,
    pl_sequ    picklist.pl_sequ,
    pl_user1   picklist.pl_user1,
    pl_user2   picklist.pl_user2,
    pl_user3   picklist.pl_user3,
    pl_user4   picklist.pl_user4,
    pl_user5   picklist.pl_user5
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capictures AS caBase OF cit_ca.vcx
Alias = [capictures]
Tables = [pictures]
KeyFieldList = [pc_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pc_bestuhl,
       pc_flength,
       pc_hash,
       pc_id,
       pc_lang1,
       pc_lang10,
       pc_lang11,
       pc_lang2,
       pc_lang3,
       pc_lang4,
       pc_lang5,
       pc_lang6,
       pc_lang7,
       pc_lang8,
       pc_lang9,
       pc_persons,
       pc_picture
    FROM pictures
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pc_bestuhl C(4)    DEFAULT "",
    pc_flength I       DEFAULT 0,
    pc_hash    C(32)   DEFAULT "",
    pc_id      N(8,0)  DEFAULT 0,
    pc_lang1   C(250)  DEFAULT "",
    pc_lang10  C(250)  DEFAULT "",
    pc_lang11  C(250)  DEFAULT "",
    pc_lang2   C(250)  DEFAULT "",
    pc_lang3   C(250)  DEFAULT "",
    pc_lang4   C(250)  DEFAULT "",
    pc_lang5   C(250)  DEFAULT "",
    pc_lang6   C(250)  DEFAULT "",
    pc_lang7   C(250)  DEFAULT "",
    pc_lang8   C(250)  DEFAULT "",
    pc_lang9   C(250)  DEFAULT "",
    pc_persons N(4,0)  DEFAULT 0,
    pc_picture C(50)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pc_bestuhl,
    pc_flength,
    pc_hash,
    pc_id,
    pc_lang1,
    pc_lang10,
    pc_lang11,
    pc_lang2,
    pc_lang3,
    pc_lang4,
    pc_lang5,
    pc_lang6,
    pc_lang7,
    pc_lang8,
    pc_lang9,
    pc_persons,
    pc_picture
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pc_bestuhl pictures.pc_bestuhl,
    pc_flength pictures.pc_flength,
    pc_hash    pictures.pc_hash,
    pc_id      pictures.pc_id,
    pc_lang1   pictures.pc_lang1,
    pc_lang10  pictures.pc_lang10,
    pc_lang11  pictures.pc_lang11,
    pc_lang2   pictures.pc_lang2,
    pc_lang3   pictures.pc_lang3,
    pc_lang4   pictures.pc_lang4,
    pc_lang5   pictures.pc_lang5,
    pc_lang6   pictures.pc_lang6,
    pc_lang7   pictures.pc_lang7,
    pc_lang8   pictures.pc_lang8,
    pc_lang9   pictures.pc_lang9,
    pc_persons pictures.pc_persons,
    pc_picture pictures.pc_picture
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capipay AS caBase OF cit_ca.vcx
Alias = [capipay]
Tables = [pipay]
KeyFieldList = [pp_ppid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pp_amount,
       pp_cardno,
       pp_field,
       pp_lineno,
       pp_payname,
       pp_paynum,
       pp_ppid,
       pp_pzid
    FROM pipay
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pp_amount  N(10,2) DEFAULT 0,
    pp_cardno  C(20)   DEFAULT "",
    pp_field   I       DEFAULT 0,
    pp_lineno  I       DEFAULT 0,
    pp_payname C(50)   DEFAULT "",
    pp_paynum  I       DEFAULT 0,
    pp_ppid    I       DEFAULT 0,
    pp_pzid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pp_amount,
    pp_cardno,
    pp_field,
    pp_lineno,
    pp_payname,
    pp_paynum,
    pp_ppid,
    pp_pzid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pp_amount  pipay.pp_amount,
    pp_cardno  pipay.pp_cardno,
    pp_field   pipay.pp_field,
    pp_lineno  pipay.pp_lineno,
    pp_payname pipay.pp_payname,
    pp_paynum  pipay.pp_paynum,
    pp_ppid    pipay.pp_ppid,
    pp_pzid    pipay.pp_pzid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capost AS caBase OF cit_ca.vcx
Alias = [capost]
Tables = [post]
KeyFieldList = [ps_postid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ps_addrid,
       ps_amount,
       ps_artinum,
       ps_bdate,
       ps_billnum,
       ps_buildng,
       ps_cancel,
       ps_cashier,
       ps_currtxt,
       ps_date,
       ps_descrip,
       ps_fibdat,
       ps_finacct,
       ps_ifc,
       ps_marker,
       ps_note,
       ps_origid,
       ps_paynum,
       ps_posbiln,
       ps_postid,
       ps_price,
       ps_prtype,
       ps_raid,
       ps_ratecod,
       ps_rdate,
       ps_reserid,
       ps_setid,
       ps_split,
       ps_supplem,
       ps_tano,
       ps_time,
       ps_touched,
       ps_units,
       ps_userid,
       ps_vat0,
       ps_vat1,
       ps_vat2,
       ps_vat3,
       ps_vat4,
       ps_vat5,
       ps_vat6,
       ps_vat7,
       ps_vat8,
       ps_vat9,
       ps_vouccpy,
       ps_voucnum,
       ps_window
    FROM post
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ps_addrid  N(8,0)  DEFAULT 0,
    ps_amount  B(2)    DEFAULT 0,
    ps_artinum N(4,0)  DEFAULT 0,
    ps_bdate   D       DEFAULT {},
    ps_billnum C(10)   DEFAULT "",
    ps_buildng C(3)    DEFAULT "",
    ps_cancel  L       DEFAULT .F.,
    ps_cashier N(2,0)  DEFAULT 0,
    ps_currtxt M       DEFAULT "",
    ps_date    D       DEFAULT {},
    ps_descrip C(25)   DEFAULT "",
    ps_fibdat  T       DEFAULT {},
    ps_finacct N(8,0)  DEFAULT 0,
    ps_ifc     M       DEFAULT "",
    ps_marker  C(10)   DEFAULT "",
    ps_note    M       DEFAULT "",
    ps_origid  N(12,3) DEFAULT 0,
    ps_paynum  N(3,0)  DEFAULT 0,
    ps_posbiln I       DEFAULT 0,
    ps_postid  N(8,0)  DEFAULT 0,
    ps_price   B(6)    DEFAULT 0,
    ps_prtype  N(2,0)  DEFAULT 0,
    ps_raid    N(10,0) DEFAULT 0,
    ps_ratecod C(23)   DEFAULT "",
    ps_rdate   D       DEFAULT {},
    ps_reserid N(12,3) DEFAULT 0,
    ps_setid   N(8,0)  DEFAULT 0,
    ps_split   L       DEFAULT .F.,
    ps_supplem C(150)  DEFAULT "",
    ps_tano    L       DEFAULT .F.,
    ps_time    C(5)    DEFAULT "",
    ps_touched L       DEFAULT .F.,
    ps_units   B(2)    DEFAULT 0,
    ps_userid  C(10)   DEFAULT "",
    ps_vat0    B(6)    DEFAULT 0,
    ps_vat1    B(6)    DEFAULT 0,
    ps_vat2    B(6)    DEFAULT 0,
    ps_vat3    B(6)    DEFAULT 0,
    ps_vat4    B(6)    DEFAULT 0,
    ps_vat5    B(6)    DEFAULT 0,
    ps_vat6    B(6)    DEFAULT 0,
    ps_vat7    B(6)    DEFAULT 0,
    ps_vat8    B(6)    DEFAULT 0,
    ps_vat9    B(6)    DEFAULT 0,
    ps_vouccpy N(2,0)  DEFAULT 0,
    ps_voucnum N(10,0) DEFAULT 0,
    ps_window  I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ps_addrid,
    ps_amount,
    ps_artinum,
    ps_bdate,
    ps_billnum,
    ps_buildng,
    ps_cancel,
    ps_cashier,
    ps_currtxt,
    ps_date,
    ps_descrip,
    ps_fibdat,
    ps_finacct,
    ps_ifc,
    ps_marker,
    ps_note,
    ps_origid,
    ps_paynum,
    ps_posbiln,
    ps_postid,
    ps_price,
    ps_prtype,
    ps_raid,
    ps_ratecod,
    ps_rdate,
    ps_reserid,
    ps_setid,
    ps_split,
    ps_supplem,
    ps_tano,
    ps_time,
    ps_touched,
    ps_units,
    ps_userid,
    ps_vat0,
    ps_vat1,
    ps_vat2,
    ps_vat3,
    ps_vat4,
    ps_vat5,
    ps_vat6,
    ps_vat7,
    ps_vat8,
    ps_vat9,
    ps_vouccpy,
    ps_voucnum,
    ps_window
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ps_addrid  post.ps_addrid,
    ps_amount  post.ps_amount,
    ps_artinum post.ps_artinum,
    ps_bdate   post.ps_bdate,
    ps_billnum post.ps_billnum,
    ps_buildng post.ps_buildng,
    ps_cancel  post.ps_cancel,
    ps_cashier post.ps_cashier,
    ps_currtxt post.ps_currtxt,
    ps_date    post.ps_date,
    ps_descrip post.ps_descrip,
    ps_fibdat  post.ps_fibdat,
    ps_finacct post.ps_finacct,
    ps_ifc     post.ps_ifc,
    ps_marker  post.ps_marker,
    ps_note    post.ps_note,
    ps_origid  post.ps_origid,
    ps_paynum  post.ps_paynum,
    ps_posbiln post.ps_posbiln,
    ps_postid  post.ps_postid,
    ps_price   post.ps_price,
    ps_prtype  post.ps_prtype,
    ps_raid    post.ps_raid,
    ps_ratecod post.ps_ratecod,
    ps_rdate   post.ps_rdate,
    ps_reserid post.ps_reserid,
    ps_setid   post.ps_setid,
    ps_split   post.ps_split,
    ps_supplem post.ps_supplem,
    ps_tano    post.ps_tano,
    ps_time    post.ps_time,
    ps_touched post.ps_touched,
    ps_units   post.ps_units,
    ps_userid  post.ps_userid,
    ps_vat0    post.ps_vat0,
    ps_vat1    post.ps_vat1,
    ps_vat2    post.ps_vat2,
    ps_vat3    post.ps_vat3,
    ps_vat4    post.ps_vat4,
    ps_vat5    post.ps_vat5,
    ps_vat6    post.ps_vat6,
    ps_vat7    post.ps_vat7,
    ps_vat8    post.ps_vat8,
    ps_vat9    post.ps_vat9,
    ps_vouccpy post.ps_vouccpy,
    ps_voucnum post.ps_voucnum,
    ps_window  post.ps_window
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capostchng AS caBase OF cit_ca.vcx
Alias = [capostchng]
Tables = [postchng]
KeyFieldList = [ph_postid,ph_time,ph_user,ph_field,ph_action]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ph_action,
       ph_field,
       ph_newval,
       ph_oldval,
       ph_postid,
       ph_time,
       ph_user
    FROM postchng
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_action  C(40)   DEFAULT "",
    ph_field   C(20)   DEFAULT "",
    ph_newval  C(30)   DEFAULT "",
    ph_oldval  C(30)   DEFAULT "",
    ph_postid  N(8,0)  DEFAULT 0,
    ph_time    T       DEFAULT {},
    ph_user    C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_action,
    ph_field,
    ph_newval,
    ph_oldval,
    ph_postid,
    ph_time,
    ph_user
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ph_action  postchng.ph_action,
    ph_field   postchng.ph_field,
    ph_newval  postchng.ph_newval,
    ph_oldval  postchng.ph_oldval,
    ph_postid  postchng.ph_postid,
    ph_time    postchng.ph_time,
    ph_user    postchng.ph_user
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capostcxl AS caBase OF cit_ca.vcx
Alias = [capostcxl]
Tables = [postcxl]
KeyFieldList = [ps_billnum,ps_postid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ps_addrid,
       ps_amount,
       ps_artinum,
       ps_billnum,
       ps_cashier,
       ps_cxldatt,
       ps_date,
       ps_descrip,
       ps_fibdat,
       ps_finacct,
       ps_ifc,
       ps_note,
       ps_paynum,
       ps_postid,
       ps_price,
       ps_raid,
       ps_ratecod,
       ps_rsid,
       ps_setid,
       ps_split,
       ps_supplem,
       ps_time,
       ps_units,
       ps_userid,
       ps_vat0,
       ps_vat1,
       ps_vat2,
       ps_vat3,
       ps_vat4,
       ps_vat5,
       ps_vat6,
       ps_vat7,
       ps_vat8,
       ps_vat9,
       ps_vouccpy,
       ps_voucnum,
       ps_window
    FROM postcxl
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ps_addrid  N(8,0)  DEFAULT 0,
    ps_amount  B(2)    DEFAULT 0,
    ps_artinum N(4,0)  DEFAULT 0,
    ps_billnum C(10)   DEFAULT "",
    ps_cashier N(2,0)  DEFAULT 0,
    ps_cxldatt T       DEFAULT {},
    ps_date    D       DEFAULT {},
    ps_descrip C(25)   DEFAULT "",
    ps_fibdat  T       DEFAULT {},
    ps_finacct N(8,0)  DEFAULT 0,
    ps_ifc     M       DEFAULT "",
    ps_note    M       DEFAULT "",
    ps_paynum  N(3,0)  DEFAULT 0,
    ps_postid  N(8,0)  DEFAULT 0,
    ps_price   B(6)    DEFAULT 0,
    ps_raid    N(10,0) DEFAULT 0,
    ps_ratecod C(23)   DEFAULT "",
    ps_rsid    I       DEFAULT 0,
    ps_setid   N(8,0)  DEFAULT 0,
    ps_split   L       DEFAULT .F.,
    ps_supplem C(25)   DEFAULT "",
    ps_time    C(5)    DEFAULT "",
    ps_units   B(2)    DEFAULT 0,
    ps_userid  C(10)   DEFAULT "",
    ps_vat0    B(6)    DEFAULT 0,
    ps_vat1    B(6)    DEFAULT 0,
    ps_vat2    B(6)    DEFAULT 0,
    ps_vat3    B(6)    DEFAULT 0,
    ps_vat4    B(6)    DEFAULT 0,
    ps_vat5    B(6)    DEFAULT 0,
    ps_vat6    B(6)    DEFAULT 0,
    ps_vat7    B(6)    DEFAULT 0,
    ps_vat8    B(6)    DEFAULT 0,
    ps_vat9    B(6)    DEFAULT 0,
    ps_vouccpy N(2,0)  DEFAULT 0,
    ps_voucnum N(10,0) DEFAULT 0,
    ps_window  I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ps_addrid,
    ps_amount,
    ps_artinum,
    ps_billnum,
    ps_cashier,
    ps_cxldatt,
    ps_date,
    ps_descrip,
    ps_fibdat,
    ps_finacct,
    ps_ifc,
    ps_note,
    ps_paynum,
    ps_postid,
    ps_price,
    ps_raid,
    ps_ratecod,
    ps_rsid,
    ps_setid,
    ps_split,
    ps_supplem,
    ps_time,
    ps_units,
    ps_userid,
    ps_vat0,
    ps_vat1,
    ps_vat2,
    ps_vat3,
    ps_vat4,
    ps_vat5,
    ps_vat6,
    ps_vat7,
    ps_vat8,
    ps_vat9,
    ps_vouccpy,
    ps_voucnum,
    ps_window
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ps_addrid  postcxl.ps_addrid,
    ps_amount  postcxl.ps_amount,
    ps_artinum postcxl.ps_artinum,
    ps_billnum postcxl.ps_billnum,
    ps_cashier postcxl.ps_cashier,
    ps_cxldatt postcxl.ps_cxldatt,
    ps_date    postcxl.ps_date,
    ps_descrip postcxl.ps_descrip,
    ps_fibdat  postcxl.ps_fibdat,
    ps_finacct postcxl.ps_finacct,
    ps_ifc     postcxl.ps_ifc,
    ps_note    postcxl.ps_note,
    ps_paynum  postcxl.ps_paynum,
    ps_postid  postcxl.ps_postid,
    ps_price   postcxl.ps_price,
    ps_raid    postcxl.ps_raid,
    ps_ratecod postcxl.ps_ratecod,
    ps_rsid    postcxl.ps_rsid,
    ps_setid   postcxl.ps_setid,
    ps_split   postcxl.ps_split,
    ps_supplem postcxl.ps_supplem,
    ps_time    postcxl.ps_time,
    ps_units   postcxl.ps_units,
    ps_userid  postcxl.ps_userid,
    ps_vat0    postcxl.ps_vat0,
    ps_vat1    postcxl.ps_vat1,
    ps_vat2    postcxl.ps_vat2,
    ps_vat3    postcxl.ps_vat3,
    ps_vat4    postcxl.ps_vat4,
    ps_vat5    postcxl.ps_vat5,
    ps_vat6    postcxl.ps_vat6,
    ps_vat7    postcxl.ps_vat7,
    ps_vat8    postcxl.ps_vat8,
    ps_vat9    postcxl.ps_vat9,
    ps_vouccpy postcxl.ps_vouccpy,
    ps_voucnum postcxl.ps_voucnum,
    ps_window  postcxl.ps_window
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capostdisc AS caBase OF cit_ca.vcx
Alias = [capostdisc]
Tables = [postdisc]
KeyFieldList = [pd_postid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pd_discnt,
       pd_discpct,
       pd_origamt,
       pd_postid,
       pd_tmstamp,
       pd_userid
    FROM postdisc
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pd_discnt  C(3)    DEFAULT "",
    pd_discpct N(3,0)  DEFAULT 0,
    pd_origamt B(2)    DEFAULT 0,
    pd_postid  N(8,0)  DEFAULT 0,
    pd_tmstamp T       DEFAULT {},
    pd_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pd_discnt,
    pd_discpct,
    pd_origamt,
    pd_postid,
    pd_tmstamp,
    pd_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pd_discnt  postdisc.pd_discnt,
    pd_discpct postdisc.pd_discpct,
    pd_origamt postdisc.pd_origamt,
    pd_postid  postdisc.pd_postid,
    pd_tmstamp postdisc.pd_tmstamp,
    pd_userid  postdisc.pd_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capriceavg AS caBase OF cit_ca.vcx
Alias = [capriceavg]
Tables = [priceavg]
KeyFieldList = [pv_pvid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pv_high,
       pv_low,
       pv_pvid
    FROM priceavg
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pv_high    B(8)    DEFAULT 0,
    pv_low     B(8)    DEFAULT 0,
    pv_pvid    N(12,3) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pv_high,
    pv_low,
    pv_pvid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pv_high    priceavg.pv_high,
    pv_low     priceavg.pv_low,
    pv_pvid    priceavg.pv_pvid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caprtypes AS caBase OF cit_ca.vcx
Alias = [caprtypes]
Tables = [prtypes]
KeyFieldList = [pt_number]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pt_alwgrp,
       pt_copytxt,
       pt_descrip,
       pt_lang1,
       pt_lang10,
       pt_lang11,
       pt_lang2,
       pt_lang3,
       pt_lang4,
       pt_lang5,
       pt_lang6,
       pt_lang7,
       pt_lang8,
       pt_lang9,
       pt_number
    FROM prtypes
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pt_alwgrp  L       DEFAULT .F.,
    pt_copytxt L       DEFAULT .F.,
    pt_descrip C(20)   DEFAULT "",
    pt_lang1   C(20)   DEFAULT "",
    pt_lang10  C(20)   DEFAULT "",
    pt_lang11  C(20)   DEFAULT "",
    pt_lang2   C(20)   DEFAULT "",
    pt_lang3   C(20)   DEFAULT "",
    pt_lang4   C(20)   DEFAULT "",
    pt_lang5   C(20)   DEFAULT "",
    pt_lang6   C(20)   DEFAULT "",
    pt_lang7   C(20)   DEFAULT "",
    pt_lang8   C(20)   DEFAULT "",
    pt_lang9   C(20)   DEFAULT "",
    pt_number  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pt_alwgrp,
    pt_copytxt,
    pt_descrip,
    pt_lang1,
    pt_lang10,
    pt_lang11,
    pt_lang2,
    pt_lang3,
    pt_lang4,
    pt_lang5,
    pt_lang6,
    pt_lang7,
    pt_lang8,
    pt_lang9,
    pt_number
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pt_alwgrp  prtypes.pt_alwgrp,
    pt_copytxt prtypes.pt_copytxt,
    pt_descrip prtypes.pt_descrip,
    pt_lang1   prtypes.pt_lang1,
    pt_lang10  prtypes.pt_lang10,
    pt_lang11  prtypes.pt_lang11,
    pt_lang2   prtypes.pt_lang2,
    pt_lang3   prtypes.pt_lang3,
    pt_lang4   prtypes.pt_lang4,
    pt_lang5   prtypes.pt_lang5,
    pt_lang6   prtypes.pt_lang6,
    pt_lang7   prtypes.pt_lang7,
    pt_lang8   prtypes.pt_lang8,
    pt_lang9   prtypes.pt_lang9,
    pt_number  prtypes.pt_number
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capswindow AS caBase OF cit_ca.vcx
Alias = [capswindow]
Tables = [pswindow]
KeyFieldList = [pw_pwid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pw_addrid,
       pw_billsty,
       pw_blamid,
       pw_bmsto1w,
       pw_copy,
       pw_note,
       pw_pwid,
       pw_rsid,
       pw_udbdate,
       pw_window,
       pw_winpos
    FROM pswindow
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pw_addrid  N(8,0)  DEFAULT 0,
    pw_billsty C(1)    DEFAULT "",
    pw_blamid  N(8,0)  DEFAULT 0,
    pw_bmsto1w L       DEFAULT .F.,
    pw_copy    N(2,0)  DEFAULT 0,
    pw_note    M       DEFAULT "",
    pw_pwid    I       DEFAULT 0,
    pw_rsid    I       DEFAULT 0,
    pw_udbdate L       DEFAULT .F.,
    pw_window  I       DEFAULT 0,
    pw_winpos  N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pw_addrid,
    pw_billsty,
    pw_blamid,
    pw_bmsto1w,
    pw_copy,
    pw_note,
    pw_pwid,
    pw_rsid,
    pw_udbdate,
    pw_window,
    pw_winpos
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pw_addrid  pswindow.pw_addrid,
    pw_billsty pswindow.pw_billsty,
    pw_blamid  pswindow.pw_blamid,
    pw_bmsto1w pswindow.pw_bmsto1w,
    pw_copy    pswindow.pw_copy,
    pw_note    pswindow.pw_note,
    pw_pwid    pswindow.pw_pwid,
    pw_rsid    pswindow.pw_rsid,
    pw_udbdate pswindow.pw_udbdate,
    pw_window  pswindow.pw_window,
    pw_winpos  pswindow.pw_winpos
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caratearti AS caBase OF cit_ca.vcx
Alias = [caratearti]
Tables = [ratearti]
KeyFieldList = [ra_ratecod,ra_raid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ra_amnt,
       ra_artchng,
       ra_artinc1,
       ra_artinc2,
       ra_artinc3,
       ra_artinc4,
       ra_artinc5,
       ra_artinu1,
       ra_artinu2,
       ra_artinu3,
       ra_artinu4,
       ra_artinu5,
       ra_artinum,
       ra_artityp,
       ra_atblres,
       ra_exinfo,
       ra_multipl,
       ra_note,
       ra_notef,
       ra_notep,
       ra_onlyon,
       ra_package,
       ra_pctexma,
       ra_pmlocal,
       ra_raid,
       ra_ratecod,
       ra_ratepct,
       ra_sagroup,
       ra_user1,
       ra_user2,
       ra_user3,
       ra_user4,
       ra_wservid
    FROM ratearti
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt    B(2)    DEFAULT 0,
    ra_artchng N(4,0)  DEFAULT 0,
    ra_artinc1 N(4,0)  DEFAULT 0,
    ra_artinc2 N(4,0)  DEFAULT 0,
    ra_artinc3 N(4,0)  DEFAULT 0,
    ra_artinc4 N(4,0)  DEFAULT 0,
    ra_artinc5 N(4,0)  DEFAULT 0,
    ra_artinu1 N(4,0)  DEFAULT 0,
    ra_artinu2 N(4,0)  DEFAULT 0,
    ra_artinu3 N(4,0)  DEFAULT 0,
    ra_artinu4 N(4,0)  DEFAULT 0,
    ra_artinu5 N(4,0)  DEFAULT 0,
    ra_artinum N(4,0)  DEFAULT 0,
    ra_artityp N(1,0)  DEFAULT 0,
    ra_atblres L       DEFAULT .F.,
    ra_exinfo  C(20)   DEFAULT "",
    ra_multipl N(1,0)  DEFAULT 0,
    ra_note    M       DEFAULT "",
    ra_notef   M       DEFAULT "",
    ra_notep   M       DEFAULT "",
    ra_onlyon  N(3,0)  DEFAULT 0,
    ra_package L       DEFAULT .F.,
    ra_pctexma L       DEFAULT .F.,
    ra_pmlocal L       DEFAULT .F.,
    ra_raid    N(10,0) DEFAULT 0,
    ra_ratecod C(23)   DEFAULT "",
    ra_ratepct N(7,2)  DEFAULT 0,
    ra_sagroup L       DEFAULT .F.,
    ra_user1   C(50)   DEFAULT "",
    ra_user2   C(50)   DEFAULT "",
    ra_user3   C(50)   DEFAULT "",
    ra_user4   C(50)   DEFAULT "",
    ra_wservid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt,
    ra_artchng,
    ra_artinc1,
    ra_artinc2,
    ra_artinc3,
    ra_artinc4,
    ra_artinc5,
    ra_artinu1,
    ra_artinu2,
    ra_artinu3,
    ra_artinu4,
    ra_artinu5,
    ra_artinum,
    ra_artityp,
    ra_atblres,
    ra_exinfo,
    ra_multipl,
    ra_note,
    ra_notef,
    ra_notep,
    ra_onlyon,
    ra_package,
    ra_pctexma,
    ra_pmlocal,
    ra_raid,
    ra_ratecod,
    ra_ratepct,
    ra_sagroup,
    ra_user1,
    ra_user2,
    ra_user3,
    ra_user4,
    ra_wservid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt    ratearti.ra_amnt,
    ra_artchng ratearti.ra_artchng,
    ra_artinc1 ratearti.ra_artinc1,
    ra_artinc2 ratearti.ra_artinc2,
    ra_artinc3 ratearti.ra_artinc3,
    ra_artinc4 ratearti.ra_artinc4,
    ra_artinc5 ratearti.ra_artinc5,
    ra_artinu1 ratearti.ra_artinu1,
    ra_artinu2 ratearti.ra_artinu2,
    ra_artinu3 ratearti.ra_artinu3,
    ra_artinu4 ratearti.ra_artinu4,
    ra_artinu5 ratearti.ra_artinu5,
    ra_artinum ratearti.ra_artinum,
    ra_artityp ratearti.ra_artityp,
    ra_atblres ratearti.ra_atblres,
    ra_exinfo  ratearti.ra_exinfo,
    ra_multipl ratearti.ra_multipl,
    ra_note    ratearti.ra_note,
    ra_notef   ratearti.ra_notef,
    ra_notep   ratearti.ra_notep,
    ra_onlyon  ratearti.ra_onlyon,
    ra_package ratearti.ra_package,
    ra_pctexma ratearti.ra_pctexma,
    ra_pmlocal ratearti.ra_pmlocal,
    ra_raid    ratearti.ra_raid,
    ra_ratecod ratearti.ra_ratecod,
    ra_ratepct ratearti.ra_ratepct,
    ra_sagroup ratearti.ra_sagroup,
    ra_user1   ratearti.ra_user1,
    ra_user2   ratearti.ra_user2,
    ra_user3   ratearti.ra_user3,
    ra_user4   ratearti.ra_user4,
    ra_wservid ratearti.ra_wservid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caratecode AS caBase OF cit_ca.vcx
Alias = [caratecode]
Tables = [ratecode]
KeyFieldList = [rc_key]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rc_addform,
       rc_adperid,
       rc_adperra,
       rc_alltdef,
       rc_amnt1,
       rc_amnt2,
       rc_amnt3,
       rc_amnt4,
       rc_amnt5,
       rc_base,
       rc_camnt1,
       rc_camnt2,
       rc_camnt3,
       rc_citcwcp,
       rc_citcwcr,
       rc_citexid,
       rc_citmob1,
       rc_citmob2,
       rc_citmob3,
       rc_citmob4,
       rc_citmob5,
       rc_citmob6,
       rc_citmob7,
       rc_citmob8,
       rc_citmob9,
       rc_citmobi,
       rc_citmoss,
       rc_citmsre,
       rc_citucwr,
       rc_citvwrl,
       rc_closarr,
       rc_colorid,
       rc_complim,
       rc_cxlmsg,
       rc_cxltxt,
       rc_formule,
       rc_fromdat,
       rc_group,
       rc_inactiv,
       rc_key,
       rc_lang1,
       rc_lang10,
       rc_lang11,
       rc_lang2,
       rc_lang3,
       rc_lang4,
       rc_lang5,
       rc_lang6,
       rc_lang7,
       rc_lang8,
       rc_lang9,
       rc_market,
       rc_maxstay,
       rc_minrate,
       rc_minstay,
       rc_moposon,
       rc_mratepr,
       rc_noextr,
       rc_note,
       rc_notecp,
       rc_paymeth,
       rc_paynum,
       rc_period,
       rc_prcdur,
       rc_ratecod,
       rc_rcid,
       rc_rcsetid,
       rc_rhytm,
       rc_roomtyp,
       rc_sagroup,
       rc_salang1,
       rc_salang2,
       rc_salang3,
       rc_salang4,
       rc_salang5,
       rc_salang6,
       rc_salang7,
       rc_salang8,
       rc_salang9,
       rc_season,
       rc_source,
       rc_todat,
       rc_updated,
       rc_wamnt1,
       rc_wamnt2,
       rc_wamnt3,
       rc_wamnt4,
       rc_wamnt5,
       rc_wbase,
       rc_wcamnt1,
       rc_wcamnt2,
       rc_wcamnt3,
       rc_weekend
    FROM ratecode
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rc_addform C(80)   DEFAULT "",
    rc_adperid I       DEFAULT 0,
    rc_adperra B(2)    DEFAULT 0,
    rc_alltdef L       DEFAULT .F.,
    rc_amnt1   B(2)    DEFAULT 0,
    rc_amnt2   B(2)    DEFAULT 0,
    rc_amnt3   B(2)    DEFAULT 0,
    rc_amnt4   B(2)    DEFAULT 0,
    rc_amnt5   B(2)    DEFAULT 0,
    rc_base    B(2)    DEFAULT 0,
    rc_camnt1  B(2)    DEFAULT 0,
    rc_camnt2  B(2)    DEFAULT 0,
    rc_camnt3  B(2)    DEFAULT 0,
    rc_citcwcp N(6,2)  DEFAULT 0,
    rc_citcwcr N(6,2)  DEFAULT 0,
    rc_citexid C(10)   DEFAULT "",
    rc_citmob1 M       DEFAULT "",
    rc_citmob2 M       DEFAULT "",
    rc_citmob3 M       DEFAULT "",
    rc_citmob4 M       DEFAULT "",
    rc_citmob5 M       DEFAULT "",
    rc_citmob6 M       DEFAULT "",
    rc_citmob7 M       DEFAULT "",
    rc_citmob8 M       DEFAULT "",
    rc_citmob9 M       DEFAULT "",
    rc_citmobi L       DEFAULT .F.,
    rc_citmoss L       DEFAULT .F.,
    rc_citmsre L       DEFAULT .F.,
    rc_citucwr L       DEFAULT .F.,
    rc_citvwrl C(3)    DEFAULT "",
    rc_closarr C(7)    DEFAULT "",
    rc_colorid N(8,0)  DEFAULT 0,
    rc_complim L       DEFAULT .F.,
    rc_cxlmsg  L       DEFAULT .F.,
    rc_cxltxt  C(100)  DEFAULT "",
    rc_formule C(80)   DEFAULT "",
    rc_fromdat D       DEFAULT {},
    rc_group   C(3)    DEFAULT "",
    rc_inactiv L       DEFAULT .F.,
    rc_key     C(23)   DEFAULT "",
    rc_lang1   C(35)   DEFAULT "",
    rc_lang10  C(35)   DEFAULT "",
    rc_lang11  C(35)   DEFAULT "",
    rc_lang2   C(35)   DEFAULT "",
    rc_lang3   C(35)   DEFAULT "",
    rc_lang4   C(35)   DEFAULT "",
    rc_lang5   C(35)   DEFAULT "",
    rc_lang6   C(35)   DEFAULT "",
    rc_lang7   C(35)   DEFAULT "",
    rc_lang8   C(35)   DEFAULT "",
    rc_lang9   C(35)   DEFAULT "",
    rc_market  C(3)    DEFAULT "",
    rc_maxstay N(3,0)  DEFAULT 0,
    rc_minrate B(2)    DEFAULT 0,
    rc_minstay N(2,0)  DEFAULT 0,
    rc_moposon N(2,0)  DEFAULT 0,
    rc_mratepr B(2)    DEFAULT 0,
    rc_noextr  L       DEFAULT .F.,
    rc_note    M       DEFAULT "",
    rc_notecp  L       DEFAULT .F.,
    rc_paymeth C(4)    DEFAULT "",
    rc_paynum  N(3,0)  DEFAULT 0,
    rc_period  N(1,0)  DEFAULT 0,
    rc_prcdur  N(2,0)  DEFAULT 0,
    rc_ratecod C(10)   DEFAULT "",
    rc_rcid    I       DEFAULT 0,
    rc_rcsetid N(8,0)  DEFAULT 0,
    rc_rhytm   N(1,0)  DEFAULT 0,
    rc_roomtyp C(4)    DEFAULT "",
    rc_sagroup L       DEFAULT .F.,
    rc_salang1 C(35)   DEFAULT "",
    rc_salang2 C(35)   DEFAULT "",
    rc_salang3 C(35)   DEFAULT "",
    rc_salang4 C(35)   DEFAULT "",
    rc_salang5 C(35)   DEFAULT "",
    rc_salang6 C(35)   DEFAULT "",
    rc_salang7 C(35)   DEFAULT "",
    rc_salang8 C(35)   DEFAULT "",
    rc_salang9 C(35)   DEFAULT "",
    rc_season  C(1)    DEFAULT "",
    rc_source  C(3)    DEFAULT "",
    rc_todat   D       DEFAULT {},
    rc_updated D       DEFAULT {},
    rc_wamnt1  B(2)    DEFAULT 0,
    rc_wamnt2  B(2)    DEFAULT 0,
    rc_wamnt3  B(2)    DEFAULT 0,
    rc_wamnt4  B(2)    DEFAULT 0,
    rc_wamnt5  B(2)    DEFAULT 0,
    rc_wbase   B(2)    DEFAULT 0,
    rc_wcamnt1 B(2)    DEFAULT 0,
    rc_wcamnt2 B(2)    DEFAULT 0,
    rc_wcamnt3 B(2)    DEFAULT 0,
    rc_weekend C(7)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rc_addform,
    rc_adperid,
    rc_adperra,
    rc_alltdef,
    rc_amnt1,
    rc_amnt2,
    rc_amnt3,
    rc_amnt4,
    rc_amnt5,
    rc_base,
    rc_camnt1,
    rc_camnt2,
    rc_camnt3,
    rc_citcwcp,
    rc_citcwcr,
    rc_citexid,
    rc_citmob1,
    rc_citmob2,
    rc_citmob3,
    rc_citmob4,
    rc_citmob5,
    rc_citmob6,
    rc_citmob7,
    rc_citmob8,
    rc_citmob9,
    rc_citmobi,
    rc_citmoss,
    rc_citmsre,
    rc_citucwr,
    rc_citvwrl,
    rc_closarr,
    rc_colorid,
    rc_complim,
    rc_cxlmsg,
    rc_cxltxt,
    rc_formule,
    rc_fromdat,
    rc_group,
    rc_inactiv,
    rc_key,
    rc_lang1,
    rc_lang10,
    rc_lang11,
    rc_lang2,
    rc_lang3,
    rc_lang4,
    rc_lang5,
    rc_lang6,
    rc_lang7,
    rc_lang8,
    rc_lang9,
    rc_market,
    rc_maxstay,
    rc_minrate,
    rc_minstay,
    rc_moposon,
    rc_mratepr,
    rc_noextr,
    rc_note,
    rc_notecp,
    rc_paymeth,
    rc_paynum,
    rc_period,
    rc_prcdur,
    rc_ratecod,
    rc_rcid,
    rc_rcsetid,
    rc_rhytm,
    rc_roomtyp,
    rc_sagroup,
    rc_salang1,
    rc_salang2,
    rc_salang3,
    rc_salang4,
    rc_salang5,
    rc_salang6,
    rc_salang7,
    rc_salang8,
    rc_salang9,
    rc_season,
    rc_source,
    rc_todat,
    rc_updated,
    rc_wamnt1,
    rc_wamnt2,
    rc_wamnt3,
    rc_wamnt4,
    rc_wamnt5,
    rc_wbase,
    rc_wcamnt1,
    rc_wcamnt2,
    rc_wcamnt3,
    rc_weekend
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rc_addform ratecode.rc_addform,
    rc_adperid ratecode.rc_adperid,
    rc_adperra ratecode.rc_adperra,
    rc_alltdef ratecode.rc_alltdef,
    rc_amnt1   ratecode.rc_amnt1,
    rc_amnt2   ratecode.rc_amnt2,
    rc_amnt3   ratecode.rc_amnt3,
    rc_amnt4   ratecode.rc_amnt4,
    rc_amnt5   ratecode.rc_amnt5,
    rc_base    ratecode.rc_base,
    rc_camnt1  ratecode.rc_camnt1,
    rc_camnt2  ratecode.rc_camnt2,
    rc_camnt3  ratecode.rc_camnt3,
    rc_citcwcp ratecode.rc_citcwcp,
    rc_citcwcr ratecode.rc_citcwcr,
    rc_citexid ratecode.rc_citexid,
    rc_citmob1 ratecode.rc_citmob1,
    rc_citmob2 ratecode.rc_citmob2,
    rc_citmob3 ratecode.rc_citmob3,
    rc_citmob4 ratecode.rc_citmob4,
    rc_citmob5 ratecode.rc_citmob5,
    rc_citmob6 ratecode.rc_citmob6,
    rc_citmob7 ratecode.rc_citmob7,
    rc_citmob8 ratecode.rc_citmob8,
    rc_citmob9 ratecode.rc_citmob9,
    rc_citmobi ratecode.rc_citmobi,
    rc_citmoss ratecode.rc_citmoss,
    rc_citmsre ratecode.rc_citmsre,
    rc_citucwr ratecode.rc_citucwr,
    rc_citvwrl ratecode.rc_citvwrl,
    rc_closarr ratecode.rc_closarr,
    rc_colorid ratecode.rc_colorid,
    rc_complim ratecode.rc_complim,
    rc_cxlmsg  ratecode.rc_cxlmsg,
    rc_cxltxt  ratecode.rc_cxltxt,
    rc_formule ratecode.rc_formule,
    rc_fromdat ratecode.rc_fromdat,
    rc_group   ratecode.rc_group,
    rc_inactiv ratecode.rc_inactiv,
    rc_key     ratecode.rc_key,
    rc_lang1   ratecode.rc_lang1,
    rc_lang10  ratecode.rc_lang10,
    rc_lang11  ratecode.rc_lang11,
    rc_lang2   ratecode.rc_lang2,
    rc_lang3   ratecode.rc_lang3,
    rc_lang4   ratecode.rc_lang4,
    rc_lang5   ratecode.rc_lang5,
    rc_lang6   ratecode.rc_lang6,
    rc_lang7   ratecode.rc_lang7,
    rc_lang8   ratecode.rc_lang8,
    rc_lang9   ratecode.rc_lang9,
    rc_market  ratecode.rc_market,
    rc_maxstay ratecode.rc_maxstay,
    rc_minrate ratecode.rc_minrate,
    rc_minstay ratecode.rc_minstay,
    rc_moposon ratecode.rc_moposon,
    rc_mratepr ratecode.rc_mratepr,
    rc_noextr  ratecode.rc_noextr,
    rc_note    ratecode.rc_note,
    rc_notecp  ratecode.rc_notecp,
    rc_paymeth ratecode.rc_paymeth,
    rc_paynum  ratecode.rc_paynum,
    rc_period  ratecode.rc_period,
    rc_prcdur  ratecode.rc_prcdur,
    rc_ratecod ratecode.rc_ratecod,
    rc_rcid    ratecode.rc_rcid,
    rc_rcsetid ratecode.rc_rcsetid,
    rc_rhytm   ratecode.rc_rhytm,
    rc_roomtyp ratecode.rc_roomtyp,
    rc_sagroup ratecode.rc_sagroup,
    rc_salang1 ratecode.rc_salang1,
    rc_salang2 ratecode.rc_salang2,
    rc_salang3 ratecode.rc_salang3,
    rc_salang4 ratecode.rc_salang4,
    rc_salang5 ratecode.rc_salang5,
    rc_salang6 ratecode.rc_salang6,
    rc_salang7 ratecode.rc_salang7,
    rc_salang8 ratecode.rc_salang8,
    rc_salang9 ratecode.rc_salang9,
    rc_season  ratecode.rc_season,
    rc_source  ratecode.rc_source,
    rc_todat   ratecode.rc_todat,
    rc_updated ratecode.rc_updated,
    rc_wamnt1  ratecode.rc_wamnt1,
    rc_wamnt2  ratecode.rc_wamnt2,
    rc_wamnt3  ratecode.rc_wamnt3,
    rc_wamnt4  ratecode.rc_wamnt4,
    rc_wamnt5  ratecode.rc_wamnt5,
    rc_wbase   ratecode.rc_wbase,
    rc_wcamnt1 ratecode.rc_wcamnt1,
    rc_wcamnt2 ratecode.rc_wcamnt2,
    rc_wcamnt3 ratecode.rc_wcamnt3,
    rc_weekend ratecode.rc_weekend
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carateprop AS caBase OF cit_ca.vcx
Alias = [carateprop]
Tables = [rateprop]
KeyFieldList = [rd_rcpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rd_ratecod,
       rd_rcpid,
       rd_rcpname,
       rd_valdate,
       rd_valtype,
       rd_valuec,
       rd_valuel,
       rd_valuen
    FROM rateprop
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_ratecod C(23)   DEFAULT "",
    rd_rcpid   N(8,0)  DEFAULT 0,
    rd_rcpname C(15)   DEFAULT "",
    rd_valdate D       DEFAULT {},
    rd_valtype C(1)    DEFAULT "",
    rd_valuec  C(200)  DEFAULT "",
    rd_valuel  L       DEFAULT .F.,
    rd_valuen  N(12,3) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_ratecod,
    rd_rcpid,
    rd_rcpname,
    rd_valdate,
    rd_valtype,
    rd_valuec,
    rd_valuel,
    rd_valuen
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_ratecod rateprop.rd_ratecod,
    rd_rcpid   rateprop.rd_rcpid,
    rd_rcpname rateprop.rd_rcpname,
    rd_valdate rateprop.rd_valdate,
    rd_valtype rateprop.rd_valtype,
    rd_valuec  rateprop.rd_valuec,
    rd_valuel  rateprop.rd_valuel,
    rd_valuen  rateprop.rd_valuen
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carcyield AS caBase OF cit_ca.vcx
Alias = [carcyield]
Tables = [rcyield]
KeyFieldList = [yr_yrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       yr_ratecod,
       yr_ymid,
       yr_yrid
    FROM rcyield
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    yr_ratecod C(23)   DEFAULT "",
    yr_ymid    I       DEFAULT 0,
    yr_yrid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yr_ratecod,
    yr_ymid,
    yr_yrid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yr_ratecod rcyield.yr_ratecod,
    yr_ymid    rcyield.yr_ymid,
    yr_yrid    rcyield.yr_yrid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS careferral AS caBase OF cit_ca.vcx
Alias = [careferral]
Tables = [referral]
KeyFieldList = [re_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       re_date,
       re_from,
       re_id,
       re_linkres,
       re_lnkf,
       re_lnkt,
       re_mainadr,
       re_note,
       re_to,
       re_updated,
       re_upuser,
       re_user
    FROM referral
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    re_date    T       DEFAULT {},
    re_from    N(8,0)  DEFAULT 0,
    re_id      N(8,0)  DEFAULT 0,
    re_linkres C(2)    DEFAULT "",
    re_lnkf    N(3,0)  DEFAULT 0,
    re_lnkt    N(3,0)  DEFAULT 0,
    re_mainadr L       DEFAULT .F.,
    re_note    M       DEFAULT "",
    re_to      N(8,0)  DEFAULT 0,
    re_updated T       DEFAULT {},
    re_upuser  C(10)   DEFAULT "",
    re_user    C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    re_date,
    re_from,
    re_id,
    re_linkres,
    re_lnkf,
    re_lnkt,
    re_mainadr,
    re_note,
    re_to,
    re_updated,
    re_upuser,
    re_user
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    re_date    referral.re_date,
    re_from    referral.re_from,
    re_id      referral.re_id,
    re_linkres referral.re_linkres,
    re_lnkf    referral.re_lnkf,
    re_lnkt    referral.re_lnkt,
    re_mainadr referral.re_mainadr,
    re_note    referral.re_note,
    re_to      referral.re_to,
    re_updated referral.re_updated,
    re_upuser  referral.re_upuser,
    re_user    referral.re_user
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresaddr AS caBase OF cit_ca.vcx
Alias = [caresaddr]
Tables = [resaddr]
KeyFieldList = [rg_rgid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rg_country,
       rg_fname,
       rg_fromday,
       rg_lname,
       rg_reserid,
       rg_rgid,
       rg_title,
       rg_today
    FROM resaddr
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rg_country C(3)    DEFAULT "",
    rg_fname   C(20)   DEFAULT "",
    rg_fromday N(3,0)  DEFAULT 0,
    rg_lname   C(30)   DEFAULT "",
    rg_reserid N(12,3) DEFAULT 0,
    rg_rgid    I       DEFAULT 0,
    rg_title   C(20)   DEFAULT "",
    rg_today   N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rg_country,
    rg_fname,
    rg_fromday,
    rg_lname,
    rg_reserid,
    rg_rgid,
    rg_title,
    rg_today
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rg_country resaddr.rg_country,
    rg_fname   resaddr.rg_fname,
    rg_fromday resaddr.rg_fromday,
    rg_lname   resaddr.rg_lname,
    rg_reserid resaddr.rg_reserid,
    rg_rgid    resaddr.rg_rgid,
    rg_title   resaddr.rg_title,
    rg_today   resaddr.rg_today
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carescard AS caBase OF cit_ca.vcx
Alias = [carescard]
Tables = [rescard]
KeyFieldList = [cr_crid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       cr_cardid,
       cr_crid,
       cr_messcnt,
       cr_name,
       cr_rsid
    FROM rescard
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_cardid  C(12)   DEFAULT "",
    cr_crid    I       DEFAULT 0,
    cr_messcnt C(16)   DEFAULT "",
    cr_name    C(100)  DEFAULT "",
    cr_rsid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_cardid,
    cr_crid,
    cr_messcnt,
    cr_name,
    cr_rsid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_cardid  rescard.cr_cardid,
    cr_crid    rescard.cr_crid,
    cr_messcnt rescard.cr_messcnt,
    cr_name    rescard.cr_name,
    cr_rsid    rescard.cr_rsid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carescfgue AS caBase OF cit_ca.vcx
Alias = [carescfgue]
Tables = [rescfgue]
KeyFieldList = [rj_rjid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rj_addrid,
       rj_cgid,
       rj_crsid,
       rj_deleted,
       rj_fname,
       rj_lname,
       rj_priorit,
       rj_rjid,
       rj_rsid,
       rj_title
    FROM rescfgue
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rj_addrid  N(8,0)  DEFAULT 0,
    rj_cgid    I       DEFAULT 0,
    rj_crsid   I       DEFAULT 0,
    rj_deleted L       DEFAULT .F.,
    rj_fname   C(20)   DEFAULT "",
    rj_lname   C(30)   DEFAULT "",
    rj_priorit I       DEFAULT 0,
    rj_rjid    I       DEFAULT 0,
    rj_rsid    I       DEFAULT 0,
    rj_title   C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rj_addrid,
    rj_cgid,
    rj_crsid,
    rj_deleted,
    rj_fname,
    rj_lname,
    rj_priorit,
    rj_rjid,
    rj_rsid,
    rj_title
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rj_addrid  rescfgue.rj_addrid,
    rj_cgid    rescfgue.rj_cgid,
    rj_crsid   rescfgue.rj_crsid,
    rj_deleted rescfgue.rj_deleted,
    rj_fname   rescfgue.rj_fname,
    rj_lname   rescfgue.rj_lname,
    rj_priorit rescfgue.rj_priorit,
    rj_rjid    rescfgue.rj_rjid,
    rj_rsid    rescfgue.rj_rsid,
    rj_title   rescfgue.rj_title
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS careschg AS caBase OF cit_ca.vcx
Alias = [careschg]
Tables = [reschg]
KeyFieldList = [ch_chid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ch_chid,
       ch_refresh,
       ch_rfresh2
    FROM reschg
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ch_chid    I       DEFAULT 0,
    ch_refresh I       DEFAULT 0,
    ch_rfresh2 I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ch_chid,
    ch_refresh,
    ch_rfresh2
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ch_chid    reschg.ch_chid,
    ch_refresh reschg.ch_refresh,
    ch_rfresh2 reschg.ch_rfresh2
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS careservat AS caBase OF cit_ca.vcx
Alias = [careservat]
Tables = [reservat]
KeyFieldList = [rs_rsid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rs_addrid,
       rs_adults,
       rs_agent,
       rs_agentid,
       rs_allott,
       rs_altid,
       rs_apid,
       rs_apname,
       rs_arrdate,
       rs_arrtime,
       rs_autoper,
       rs_benum,
       rs_billins,
       rs_billnr1,
       rs_billnr2,
       rs_billnr3,
       rs_billnr4,
       rs_billnr5,
       rs_billnr6,
       rs_blamid1,
       rs_blamid2,
       rs_blamid3,
       rs_blamid4,
       rs_blamid5,
       rs_blamid6,
       rs_bmsto1w,
       rs_bqkz,
       rs_ccauth,
       rs_ccexpy,
       rs_cclimit,
       rs_ccnum,
       rs_ccref,
       rs_changes,
       rs_childs,
       rs_childs2,
       rs_childs3,
       rs_cidate,
       rs_citime,
       rs_cnfstat,
       rs_codate,
       rs_company,
       rs_compid,
       rs_complim,
       rs_conbill,
       rs_conres,
       rs_copyw1,
       rs_copyw2,
       rs_copyw3,
       rs_copyw4,
       rs_copyw5,
       rs_copyw6,
       rs_cotime,
       rs_country,
       rs_cowibal,
       rs_created,
       rs_creatus,
       rs_custom1,
       rs_cxldate,
       rs_cxlnr,
       rs_cxlstat,
       rs_debbill,
       rs_depamt1,
       rs_depamt2,
       rs_depdat1,
       rs_depdat2,
       rs_depdate,
       rs_deppaid,
       rs_deppdat,
       rs_deptime,
       rs_discnt,
       rs_doarch,
       rs_eiid,
       rs_emailst,
       rs_extflag,
       rs_feat1,
       rs_feat2,
       rs_feat3,
       rs_fname,
       rs_group,
       rs_groupid,
       rs_in,
       rs_interns,
       rs_invap,
       rs_invapid,
       rs_invid,
       rs_keycard,
       rs_lfinish,
       rs_lname,
       rs_lstart,
       rs_market,
       rs_message,
       rs_msgshow,
       rs_mshwcco,
       rs_noaddr,
       rs_note,
       rs_noteco,
       rs_notew1,
       rs_notew2,
       rs_notew3,
       rs_notew4,
       rs_notew5,
       rs_notew6,
       rs_odepdat,
       rs_optdate,
       rs_orgarrd,
       rs_out,
       rs_paymeth,
       rs_paynum1,
       rs_paynum2,
       rs_paynum3,
       rs_paynum4,
       rs_paynum5,
       rs_paynum6,
       rs_posstat,
       rs_pttclas,
       rs_ptvflag,
       rs_rate,
       rs_ratecod,
       rs_ratedat,
       rs_ratein,
       rs_rateout,
       rs_ratexch,
       rs_rcsync,
       rs_recur,
       rs_reserid,
       rs_rfixdat,
       rs_rgid,
       rs_rglayou,
       rs_rminfo1,
       rs_rminfo2,
       rs_rmname,
       rs_roomlst,
       rs_roomnum,
       rs_rooms,
       rs_roomtyp,
       rs_rsid,
       rs_saddrid,
       rs_share,
       rs_sname,
       rs_source,
       rs_status,
       rs_title,
       rs_updated,
       rs_userid,
       rs_usrres0,
       rs_usrres1,
       rs_usrres2,
       rs_usrres3,
       rs_usrres4,
       rs_usrres5,
       rs_usrres6,
       rs_usrres7,
       rs_usrres8,
       rs_usrres9,
       rs_xchkout,
       rs_yoid
    FROM reservat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rs_addrid  N(8,0)  DEFAULT 0,
    rs_adults  N(3,0)  DEFAULT 0,
    rs_agent   C(30)   DEFAULT "",
    rs_agentid N(8,0)  DEFAULT 0,
    rs_allott  C(10)   DEFAULT "",
    rs_altid   N(8,0)  DEFAULT 0,
    rs_apid    N(8,0)  DEFAULT 0,
    rs_apname  C(50)   DEFAULT "",
    rs_arrdate D       DEFAULT {},
    rs_arrtime C(5)    DEFAULT "",
    rs_autoper L       DEFAULT .F.,
    rs_benum   N(2,0)  DEFAULT 0,
    rs_billins M       DEFAULT "",
    rs_billnr1 C(10)   DEFAULT "",
    rs_billnr2 C(10)   DEFAULT "",
    rs_billnr3 C(10)   DEFAULT "",
    rs_billnr4 C(10)   DEFAULT "",
    rs_billnr5 C(10)   DEFAULT "",
    rs_billnr6 C(10)   DEFAULT "",
    rs_blamid1 N(8,0)  DEFAULT 0,
    rs_blamid2 N(8,0)  DEFAULT 0,
    rs_blamid3 N(8,0)  DEFAULT 0,
    rs_blamid4 N(8,0)  DEFAULT 0,
    rs_blamid5 N(8,0)  DEFAULT 0,
    rs_blamid6 N(8,0)  DEFAULT 0,
    rs_bmsto1w C(5)    DEFAULT "",
    rs_bqkz    C(4)    DEFAULT "",
    rs_ccauth  C(32)   DEFAULT "",
    rs_ccexpy  C(32)   DEFAULT "",
    rs_cclimit B(2)    DEFAULT 0,
    rs_ccnum   C(32)   DEFAULT "",
    rs_ccref   N(8,0)  DEFAULT 0,
    rs_changes M       DEFAULT "",
    rs_childs  N(3,0)  DEFAULT 0,
    rs_childs2 N(1,0)  DEFAULT 0,
    rs_childs3 N(1,0)  DEFAULT 0,
    rs_cidate  D       DEFAULT {},
    rs_citime  C(8)    DEFAULT "",
    rs_cnfstat C(3)    DEFAULT "",
    rs_codate  D       DEFAULT {},
    rs_company C(30)   DEFAULT "",
    rs_compid  N(8,0)  DEFAULT 0,
    rs_complim L       DEFAULT .F.,
    rs_conbill C(30)   DEFAULT "",
    rs_conres  C(30)   DEFAULT "",
    rs_copyw1  N(2,0)  DEFAULT 0,
    rs_copyw2  N(2,0)  DEFAULT 0,
    rs_copyw3  N(2,0)  DEFAULT 0,
    rs_copyw4  N(2,0)  DEFAULT 0,
    rs_copyw5  N(2,0)  DEFAULT 0,
    rs_copyw6  N(2,0)  DEFAULT 0,
    rs_cotime  C(8)    DEFAULT "",
    rs_country C(3)    DEFAULT "",
    rs_cowibal L       DEFAULT .F.,
    rs_created D       DEFAULT {},
    rs_creatus C(10)   DEFAULT "",
    rs_custom1 M       DEFAULT "",
    rs_cxldate D       DEFAULT {},
    rs_cxlnr   N(8,0)  DEFAULT 0,
    rs_cxlstat C(3)    DEFAULT "",
    rs_debbill N(10,0) DEFAULT 0,
    rs_depamt1 B(2)    DEFAULT 0,
    rs_depamt2 B(2)    DEFAULT 0,
    rs_depdat1 D       DEFAULT {},
    rs_depdat2 D       DEFAULT {},
    rs_depdate D       DEFAULT {},
    rs_deppaid B(2)    DEFAULT 0,
    rs_deppdat D       DEFAULT {},
    rs_deptime C(5)    DEFAULT "",
    rs_discnt  C(3)    DEFAULT "",
    rs_doarch  L       DEFAULT .F.,
    rs_eiid    N(8,0)  DEFAULT 0,
    rs_emailst N(1,0)  DEFAULT 0,
    rs_extflag C(4)    DEFAULT "",
    rs_feat1   C(3)    DEFAULT "",
    rs_feat2   C(3)    DEFAULT "",
    rs_feat3   C(3)    DEFAULT "",
    rs_fname   C(20)   DEFAULT "",
    rs_group   C(25)   DEFAULT "",
    rs_groupid N(8,0)  DEFAULT 0,
    rs_in      C(1)    DEFAULT "",
    rs_interns C(20)   DEFAULT "",
    rs_invap   C(30)   DEFAULT "",
    rs_invapid N(8,0)  DEFAULT 0,
    rs_invid   N(8,0)  DEFAULT 0,
    rs_keycard C(20)   DEFAULT "",
    rs_lfinish C(3)    DEFAULT "",
    rs_lname   C(30)   DEFAULT "",
    rs_lstart  C(3)    DEFAULT "",
    rs_market  C(3)    DEFAULT "",
    rs_message M       DEFAULT "",
    rs_msgshow L       DEFAULT .F.,
    rs_mshwcco C(2)    DEFAULT "",
    rs_noaddr  L       DEFAULT .F.,
    rs_note    M       DEFAULT "",
    rs_noteco  M       DEFAULT "",
    rs_notew1  M       DEFAULT "",
    rs_notew2  M       DEFAULT "",
    rs_notew3  M       DEFAULT "",
    rs_notew4  M       DEFAULT "",
    rs_notew5  M       DEFAULT "",
    rs_notew6  M       DEFAULT "",
    rs_odepdat D       DEFAULT {},
    rs_optdate D       DEFAULT {},
    rs_orgarrd D       DEFAULT {},
    rs_out     C(1)    DEFAULT "",
    rs_paymeth C(4)    DEFAULT "",
    rs_paynum1 N(2,0)  DEFAULT 0,
    rs_paynum2 N(2,0)  DEFAULT 0,
    rs_paynum3 N(2,0)  DEFAULT 0,
    rs_paynum4 N(2,0)  DEFAULT 0,
    rs_paynum5 N(2,0)  DEFAULT 0,
    rs_paynum6 N(2,0)  DEFAULT 0,
    rs_posstat C(1)    DEFAULT "",
    rs_pttclas N(2,0)  DEFAULT 0,
    rs_ptvflag C(10)   DEFAULT "",
    rs_rate    B(2)    DEFAULT 0,
    rs_ratecod C(10)   DEFAULT "",
    rs_ratedat D       DEFAULT {},
    rs_ratein  L       DEFAULT .F.,
    rs_rateout L       DEFAULT .F.,
    rs_ratexch B(6)    DEFAULT 0,
    rs_rcsync  L       DEFAULT .F.,
    rs_recur   C(20)   DEFAULT "",
    rs_reserid N(12,3) DEFAULT 0,
    rs_rfixdat D       DEFAULT {},
    rs_rgid    I       DEFAULT 0,
    rs_rglayou C(7)    DEFAULT "",
    rs_rminfo1 M       DEFAULT "",
    rs_rminfo2 M       DEFAULT "",
    rs_rmname  C(10)   DEFAULT "",
    rs_roomlst L       DEFAULT .F.,
    rs_roomnum C(4)    DEFAULT "",
    rs_rooms   N(3,0)  DEFAULT 0,
    rs_roomtyp C(4)    DEFAULT "",
    rs_rsid    I       DEFAULT 0,
    rs_saddrid N(8,0)  DEFAULT 0,
    rs_share   C(2)    DEFAULT "",
    rs_sname   C(30)   DEFAULT "",
    rs_source  C(3)    DEFAULT "",
    rs_status  C(3)    DEFAULT "",
    rs_title   C(20)   DEFAULT "",
    rs_updated D       DEFAULT {},
    rs_userid  C(10)   DEFAULT "",
    rs_usrres0 C(100)  DEFAULT "",
    rs_usrres1 C(100)  DEFAULT "",
    rs_usrres2 C(100)  DEFAULT "",
    rs_usrres3 C(100)  DEFAULT "",
    rs_usrres4 C(100)  DEFAULT "",
    rs_usrres5 C(100)  DEFAULT "",
    rs_usrres6 C(100)  DEFAULT "",
    rs_usrres7 C(100)  DEFAULT "",
    rs_usrres8 C(100)  DEFAULT "",
    rs_usrres9 C(100)  DEFAULT "",
    rs_xchkout L       DEFAULT .F.,
    rs_yoid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rs_addrid,
    rs_adults,
    rs_agent,
    rs_agentid,
    rs_allott,
    rs_altid,
    rs_apid,
    rs_apname,
    rs_arrdate,
    rs_arrtime,
    rs_autoper,
    rs_benum,
    rs_billins,
    rs_billnr1,
    rs_billnr2,
    rs_billnr3,
    rs_billnr4,
    rs_billnr5,
    rs_billnr6,
    rs_blamid1,
    rs_blamid2,
    rs_blamid3,
    rs_blamid4,
    rs_blamid5,
    rs_blamid6,
    rs_bmsto1w,
    rs_bqkz,
    rs_ccauth,
    rs_ccexpy,
    rs_cclimit,
    rs_ccnum,
    rs_ccref,
    rs_changes,
    rs_childs,
    rs_childs2,
    rs_childs3,
    rs_cidate,
    rs_citime,
    rs_cnfstat,
    rs_codate,
    rs_company,
    rs_compid,
    rs_complim,
    rs_conbill,
    rs_conres,
    rs_copyw1,
    rs_copyw2,
    rs_copyw3,
    rs_copyw4,
    rs_copyw5,
    rs_copyw6,
    rs_cotime,
    rs_country,
    rs_cowibal,
    rs_created,
    rs_creatus,
    rs_custom1,
    rs_cxldate,
    rs_cxlnr,
    rs_cxlstat,
    rs_debbill,
    rs_depamt1,
    rs_depamt2,
    rs_depdat1,
    rs_depdat2,
    rs_depdate,
    rs_deppaid,
    rs_deppdat,
    rs_deptime,
    rs_discnt,
    rs_doarch,
    rs_eiid,
    rs_emailst,
    rs_extflag,
    rs_feat1,
    rs_feat2,
    rs_feat3,
    rs_fname,
    rs_group,
    rs_groupid,
    rs_in,
    rs_interns,
    rs_invap,
    rs_invapid,
    rs_invid,
    rs_keycard,
    rs_lfinish,
    rs_lname,
    rs_lstart,
    rs_market,
    rs_message,
    rs_msgshow,
    rs_mshwcco,
    rs_noaddr,
    rs_note,
    rs_noteco,
    rs_notew1,
    rs_notew2,
    rs_notew3,
    rs_notew4,
    rs_notew5,
    rs_notew6,
    rs_odepdat,
    rs_optdate,
    rs_orgarrd,
    rs_out,
    rs_paymeth,
    rs_paynum1,
    rs_paynum2,
    rs_paynum3,
    rs_paynum4,
    rs_paynum5,
    rs_paynum6,
    rs_posstat,
    rs_pttclas,
    rs_ptvflag,
    rs_rate,
    rs_ratecod,
    rs_ratedat,
    rs_ratein,
    rs_rateout,
    rs_ratexch,
    rs_rcsync,
    rs_recur,
    rs_reserid,
    rs_rfixdat,
    rs_rgid,
    rs_rglayou,
    rs_rminfo1,
    rs_rminfo2,
    rs_rmname,
    rs_roomlst,
    rs_roomnum,
    rs_rooms,
    rs_roomtyp,
    rs_rsid,
    rs_saddrid,
    rs_share,
    rs_sname,
    rs_source,
    rs_status,
    rs_title,
    rs_updated,
    rs_userid,
    rs_usrres0,
    rs_usrres1,
    rs_usrres2,
    rs_usrres3,
    rs_usrres4,
    rs_usrres5,
    rs_usrres6,
    rs_usrres7,
    rs_usrres8,
    rs_usrres9,
    rs_xchkout,
    rs_yoid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rs_addrid  reservat.rs_addrid,
    rs_adults  reservat.rs_adults,
    rs_agent   reservat.rs_agent,
    rs_agentid reservat.rs_agentid,
    rs_allott  reservat.rs_allott,
    rs_altid   reservat.rs_altid,
    rs_apid    reservat.rs_apid,
    rs_apname  reservat.rs_apname,
    rs_arrdate reservat.rs_arrdate,
    rs_arrtime reservat.rs_arrtime,
    rs_autoper reservat.rs_autoper,
    rs_benum   reservat.rs_benum,
    rs_billins reservat.rs_billins,
    rs_billnr1 reservat.rs_billnr1,
    rs_billnr2 reservat.rs_billnr2,
    rs_billnr3 reservat.rs_billnr3,
    rs_billnr4 reservat.rs_billnr4,
    rs_billnr5 reservat.rs_billnr5,
    rs_billnr6 reservat.rs_billnr6,
    rs_blamid1 reservat.rs_blamid1,
    rs_blamid2 reservat.rs_blamid2,
    rs_blamid3 reservat.rs_blamid3,
    rs_blamid4 reservat.rs_blamid4,
    rs_blamid5 reservat.rs_blamid5,
    rs_blamid6 reservat.rs_blamid6,
    rs_bmsto1w reservat.rs_bmsto1w,
    rs_bqkz    reservat.rs_bqkz,
    rs_ccauth  reservat.rs_ccauth,
    rs_ccexpy  reservat.rs_ccexpy,
    rs_cclimit reservat.rs_cclimit,
    rs_ccnum   reservat.rs_ccnum,
    rs_ccref   reservat.rs_ccref,
    rs_changes reservat.rs_changes,
    rs_childs  reservat.rs_childs,
    rs_childs2 reservat.rs_childs2,
    rs_childs3 reservat.rs_childs3,
    rs_cidate  reservat.rs_cidate,
    rs_citime  reservat.rs_citime,
    rs_cnfstat reservat.rs_cnfstat,
    rs_codate  reservat.rs_codate,
    rs_company reservat.rs_company,
    rs_compid  reservat.rs_compid,
    rs_complim reservat.rs_complim,
    rs_conbill reservat.rs_conbill,
    rs_conres  reservat.rs_conres,
    rs_copyw1  reservat.rs_copyw1,
    rs_copyw2  reservat.rs_copyw2,
    rs_copyw3  reservat.rs_copyw3,
    rs_copyw4  reservat.rs_copyw4,
    rs_copyw5  reservat.rs_copyw5,
    rs_copyw6  reservat.rs_copyw6,
    rs_cotime  reservat.rs_cotime,
    rs_country reservat.rs_country,
    rs_cowibal reservat.rs_cowibal,
    rs_created reservat.rs_created,
    rs_creatus reservat.rs_creatus,
    rs_custom1 reservat.rs_custom1,
    rs_cxldate reservat.rs_cxldate,
    rs_cxlnr   reservat.rs_cxlnr,
    rs_cxlstat reservat.rs_cxlstat,
    rs_debbill reservat.rs_debbill,
    rs_depamt1 reservat.rs_depamt1,
    rs_depamt2 reservat.rs_depamt2,
    rs_depdat1 reservat.rs_depdat1,
    rs_depdat2 reservat.rs_depdat2,
    rs_depdate reservat.rs_depdate,
    rs_deppaid reservat.rs_deppaid,
    rs_deppdat reservat.rs_deppdat,
    rs_deptime reservat.rs_deptime,
    rs_discnt  reservat.rs_discnt,
    rs_doarch  reservat.rs_doarch,
    rs_eiid    reservat.rs_eiid,
    rs_emailst reservat.rs_emailst,
    rs_extflag reservat.rs_extflag,
    rs_feat1   reservat.rs_feat1,
    rs_feat2   reservat.rs_feat2,
    rs_feat3   reservat.rs_feat3,
    rs_fname   reservat.rs_fname,
    rs_group   reservat.rs_group,
    rs_groupid reservat.rs_groupid,
    rs_in      reservat.rs_in,
    rs_interns reservat.rs_interns,
    rs_invap   reservat.rs_invap,
    rs_invapid reservat.rs_invapid,
    rs_invid   reservat.rs_invid,
    rs_keycard reservat.rs_keycard,
    rs_lfinish reservat.rs_lfinish,
    rs_lname   reservat.rs_lname,
    rs_lstart  reservat.rs_lstart,
    rs_market  reservat.rs_market,
    rs_message reservat.rs_message,
    rs_msgshow reservat.rs_msgshow,
    rs_mshwcco reservat.rs_mshwcco,
    rs_noaddr  reservat.rs_noaddr,
    rs_note    reservat.rs_note,
    rs_noteco  reservat.rs_noteco,
    rs_notew1  reservat.rs_notew1,
    rs_notew2  reservat.rs_notew2,
    rs_notew3  reservat.rs_notew3,
    rs_notew4  reservat.rs_notew4,
    rs_notew5  reservat.rs_notew5,
    rs_notew6  reservat.rs_notew6,
    rs_odepdat reservat.rs_odepdat,
    rs_optdate reservat.rs_optdate,
    rs_orgarrd reservat.rs_orgarrd,
    rs_out     reservat.rs_out,
    rs_paymeth reservat.rs_paymeth,
    rs_paynum1 reservat.rs_paynum1,
    rs_paynum2 reservat.rs_paynum2,
    rs_paynum3 reservat.rs_paynum3,
    rs_paynum4 reservat.rs_paynum4,
    rs_paynum5 reservat.rs_paynum5,
    rs_paynum6 reservat.rs_paynum6,
    rs_posstat reservat.rs_posstat,
    rs_pttclas reservat.rs_pttclas,
    rs_ptvflag reservat.rs_ptvflag,
    rs_rate    reservat.rs_rate,
    rs_ratecod reservat.rs_ratecod,
    rs_ratedat reservat.rs_ratedat,
    rs_ratein  reservat.rs_ratein,
    rs_rateout reservat.rs_rateout,
    rs_ratexch reservat.rs_ratexch,
    rs_rcsync  reservat.rs_rcsync,
    rs_recur   reservat.rs_recur,
    rs_reserid reservat.rs_reserid,
    rs_rfixdat reservat.rs_rfixdat,
    rs_rgid    reservat.rs_rgid,
    rs_rglayou reservat.rs_rglayou,
    rs_rminfo1 reservat.rs_rminfo1,
    rs_rminfo2 reservat.rs_rminfo2,
    rs_rmname  reservat.rs_rmname,
    rs_roomlst reservat.rs_roomlst,
    rs_roomnum reservat.rs_roomnum,
    rs_rooms   reservat.rs_rooms,
    rs_roomtyp reservat.rs_roomtyp,
    rs_rsid    reservat.rs_rsid,
    rs_saddrid reservat.rs_saddrid,
    rs_share   reservat.rs_share,
    rs_sname   reservat.rs_sname,
    rs_source  reservat.rs_source,
    rs_status  reservat.rs_status,
    rs_title   reservat.rs_title,
    rs_updated reservat.rs_updated,
    rs_userid  reservat.rs_userid,
    rs_usrres0 reservat.rs_usrres0,
    rs_usrres1 reservat.rs_usrres1,
    rs_usrres2 reservat.rs_usrres2,
    rs_usrres3 reservat.rs_usrres3,
    rs_usrres4 reservat.rs_usrres4,
    rs_usrres5 reservat.rs_usrres5,
    rs_usrres6 reservat.rs_usrres6,
    rs_usrres7 reservat.rs_usrres7,
    rs_usrres8 reservat.rs_usrres8,
    rs_usrres9 reservat.rs_usrres9,
    rs_xchkout reservat.rs_xchkout,
    rs_yoid    reservat.rs_yoid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresfeat AS caBase OF cit_ca.vcx
Alias = [caresfeat]
Tables = [resfeat]
KeyFieldList = [fr_frid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       fr_feature,
       fr_frid,
       fr_rsid
    FROM resfeat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    fr_feature C(3)    DEFAULT "",
    fr_frid    I       DEFAULT 0,
    fr_rsid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fr_feature,
    fr_frid,
    fr_rsid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fr_feature resfeat.fr_feature,
    fr_frid    resfeat.fr_frid,
    fr_rsid    resfeat.fr_rsid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresfix AS caBase OF cit_ca.vcx
Alias = [caresfix]
Tables = [resfix]
KeyFieldList = [rf_rfid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rf_adults,
       rf_alldays,
       rf_artinum,
       rf_childs,
       rf_childs2,
       rf_childs3,
       rf_day,
       rf_feature,
       rf_forcurr,
       rf_package,
       rf_price,
       rf_ratecod,
       rf_reserid,
       rf_rfid,
       rf_showhk,
       rf_units
    FROM resfix
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_adults  N(3,0)  DEFAULT 0,
    rf_alldays L       DEFAULT .F.,
    rf_artinum N(4,0)  DEFAULT 0,
    rf_childs  N(3,0)  DEFAULT 0,
    rf_childs2 N(3,0)  DEFAULT 0,
    rf_childs3 N(3,0)  DEFAULT 0,
    rf_day     N(3,0)  DEFAULT 0,
    rf_feature C(7)    DEFAULT "",
    rf_forcurr L       DEFAULT .F.,
    rf_package L       DEFAULT .F.,
    rf_price   B(2)    DEFAULT 0,
    rf_ratecod C(10)   DEFAULT "",
    rf_reserid N(12,3) DEFAULT 0,
    rf_rfid    I       DEFAULT 0,
    rf_showhk  L       DEFAULT .F.,
    rf_units   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_adults,
    rf_alldays,
    rf_artinum,
    rf_childs,
    rf_childs2,
    rf_childs3,
    rf_day,
    rf_feature,
    rf_forcurr,
    rf_package,
    rf_price,
    rf_ratecod,
    rf_reserid,
    rf_rfid,
    rf_showhk,
    rf_units
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_adults  resfix.rf_adults,
    rf_alldays resfix.rf_alldays,
    rf_artinum resfix.rf_artinum,
    rf_childs  resfix.rf_childs,
    rf_childs2 resfix.rf_childs2,
    rf_childs3 resfix.rf_childs3,
    rf_day     resfix.rf_day,
    rf_feature resfix.rf_feature,
    rf_forcurr resfix.rf_forcurr,
    rf_package resfix.rf_package,
    rf_price   resfix.rf_price,
    rf_ratecod resfix.rf_ratecod,
    rf_reserid resfix.rf_reserid,
    rf_rfid    resfix.rf_rfid,
    rf_showhk  resfix.rf_showhk,
    rf_units   resfix.rf_units
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresifcbr AS caBase OF cit_ca.vcx
Alias = [caresifcbr]
Tables = [resifcbr]
KeyFieldList = [rb_rbid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rb_begin,
       rb_end,
       rb_rbid,
       rb_rsid
    FROM resifcbr
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rb_begin   D       DEFAULT {},
    rb_end     D       DEFAULT {},
    rb_rbid    I       DEFAULT 0,
    rb_rsid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rb_begin,
    rb_end,
    rb_rbid,
    rb_rsid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rb_begin   resifcbr.rb_begin,
    rb_end     resifcbr.rb_end,
    rb_rbid    resifcbr.rb_rbid,
    rb_rsid    resifcbr.rb_rsid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresifcin AS caBase OF cit_ca.vcx
Alias = [caresifcin]
Tables = [resifcin]
KeyFieldList = [rn_rsid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rn_intcls,
       rn_pin,
       rn_pttcls,
       rn_ptvcls,
       rn_rsid,
       rn_sync
    FROM resifcin
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rn_intcls  C(10)   DEFAULT "",
    rn_pin     C(12)   DEFAULT "",
    rn_pttcls  C(10)   DEFAULT "",
    rn_ptvcls  C(10)   DEFAULT "",
    rn_rsid    I       DEFAULT 0,
    rn_sync    N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rn_intcls,
    rn_pin,
    rn_pttcls,
    rn_ptvcls,
    rn_rsid,
    rn_sync
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rn_intcls  resifcin.rn_intcls,
    rn_pin     resifcin.rn_pin,
    rn_pttcls  resifcin.rn_pttcls,
    rn_ptvcls  resifcin.rn_ptvcls,
    rn_rsid    resifcin.rn_rsid,
    rn_sync    resifcin.rn_sync
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carespict AS caBase OF cit_ca.vcx
Alias = [carespict]
Tables = [respict]
KeyFieldList = [rr_reserid,rr_picid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rr_picid,
       rr_reserid
    FROM respict
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_picid   N(8,0)  DEFAULT 0,
    rr_reserid N(12,3) DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_picid,
    rr_reserid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_picid   respict.rr_picid,
    rr_reserid respict.rr_reserid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresrart AS caBase OF cit_ca.vcx
Alias = [caresrart]
Tables = [resrart]
KeyFieldList = [ra_raid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ra_amnt,
       ra_artinum,
       ra_artityp,
       ra_atblres,
       ra_exinfo,
       ra_multipl,
       ra_note,
       ra_notef,
       ra_notep,
       ra_onlyon,
       ra_package,
       ra_pctexma,
       ra_pmlocal,
       ra_raid,
       ra_ratecod,
       ra_ratepct,
       ra_rcsetid,
       ra_rsid,
       ra_sagroup,
       ra_user1,
       ra_user2,
       ra_user3,
       ra_user4,
       ra_wservid
    FROM resrart
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt    B(2)    DEFAULT 0,
    ra_artinum N(4,0)  DEFAULT 0,
    ra_artityp N(1,0)  DEFAULT 0,
    ra_atblres L       DEFAULT .F.,
    ra_exinfo  C(20)   DEFAULT "",
    ra_multipl N(1,0)  DEFAULT 0,
    ra_note    M       DEFAULT "",
    ra_notef   M       DEFAULT "",
    ra_notep   M       DEFAULT "",
    ra_onlyon  N(3,0)  DEFAULT 0,
    ra_package L       DEFAULT .F.,
    ra_pctexma L       DEFAULT .F.,
    ra_pmlocal L       DEFAULT .F.,
    ra_raid    N(10,0) DEFAULT 0,
    ra_ratecod C(23)   DEFAULT "",
    ra_ratepct N(7,2)  DEFAULT 0,
    ra_rcsetid N(8,0)  DEFAULT 0,
    ra_rsid    I       DEFAULT 0,
    ra_sagroup L       DEFAULT .F.,
    ra_user1   C(50)   DEFAULT "",
    ra_user2   C(50)   DEFAULT "",
    ra_user3   C(50)   DEFAULT "",
    ra_user4   C(50)   DEFAULT "",
    ra_wservid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt,
    ra_artinum,
    ra_artityp,
    ra_atblres,
    ra_exinfo,
    ra_multipl,
    ra_note,
    ra_notef,
    ra_notep,
    ra_onlyon,
    ra_package,
    ra_pctexma,
    ra_pmlocal,
    ra_raid,
    ra_ratecod,
    ra_ratepct,
    ra_rcsetid,
    ra_rsid,
    ra_sagroup,
    ra_user1,
    ra_user2,
    ra_user3,
    ra_user4,
    ra_wservid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ra_amnt    resrart.ra_amnt,
    ra_artinum resrart.ra_artinum,
    ra_artityp resrart.ra_artityp,
    ra_atblres resrart.ra_atblres,
    ra_exinfo  resrart.ra_exinfo,
    ra_multipl resrart.ra_multipl,
    ra_note    resrart.ra_note,
    ra_notef   resrart.ra_notef,
    ra_notep   resrart.ra_notep,
    ra_onlyon  resrart.ra_onlyon,
    ra_package resrart.ra_package,
    ra_pctexma resrart.ra_pctexma,
    ra_pmlocal resrart.ra_pmlocal,
    ra_raid    resrart.ra_raid,
    ra_ratecod resrart.ra_ratecod,
    ra_ratepct resrart.ra_ratepct,
    ra_rcsetid resrart.ra_rcsetid,
    ra_rsid    resrart.ra_rsid,
    ra_sagroup resrart.ra_sagroup,
    ra_user1   resrart.ra_user1,
    ra_user2   resrart.ra_user2,
    ra_user3   resrart.ra_user3,
    ra_user4   resrart.ra_user4,
    ra_wservid resrart.ra_wservid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresrate AS caBase OF cit_ca.vcx
Alias = [caresrate]
Tables = [resrate]
KeyFieldList = [rr_rrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rr_adults,
       rr_arrtime,
       rr_childs,
       rr_childs2,
       rr_childs3,
       rr_curcoef,
       rr_date,
       rr_deptime,
       rr_package,
       rr_ratcoef,
       rr_ratecod,
       rr_rateex,
       rr_ratefrc,
       rr_ratepg,
       rr_raterc,
       rr_raterd,
       rr_raterf,
       rr_reserid,
       rr_rrid,
       rr_status
    FROM resrate
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_adults  N(3,0)  DEFAULT 0,
    rr_arrtime C(5)    DEFAULT "",
    rr_childs  N(3,0)  DEFAULT 0,
    rr_childs2 N(1,0)  DEFAULT 0,
    rr_childs3 N(1,0)  DEFAULT 0,
    rr_curcoef B(8)    DEFAULT 0,
    rr_date    D       DEFAULT {},
    rr_deptime C(5)    DEFAULT "",
    rr_package B(8)    DEFAULT 0,
    rr_ratcoef B(8)    DEFAULT 0,
    rr_ratecod C(23)   DEFAULT "",
    rr_rateex  B(8)    DEFAULT 0,
    rr_ratefrc B(8)    DEFAULT 0,
    rr_ratepg  B(8)    DEFAULT 0,
    rr_raterc  B(8)    DEFAULT 0,
    rr_raterd  B(8)    DEFAULT 0,
    rr_raterf  B(8)    DEFAULT 0,
    rr_reserid N(12,3) DEFAULT 0,
    rr_rrid    N(8,0)  DEFAULT 0,
    rr_status  C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_adults,
    rr_arrtime,
    rr_childs,
    rr_childs2,
    rr_childs3,
    rr_curcoef,
    rr_date,
    rr_deptime,
    rr_package,
    rr_ratcoef,
    rr_ratecod,
    rr_rateex,
    rr_ratefrc,
    rr_ratepg,
    rr_raterc,
    rr_raterd,
    rr_raterf,
    rr_reserid,
    rr_rrid,
    rr_status
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rr_adults  resrate.rr_adults,
    rr_arrtime resrate.rr_arrtime,
    rr_childs  resrate.rr_childs,
    rr_childs2 resrate.rr_childs2,
    rr_childs3 resrate.rr_childs3,
    rr_curcoef resrate.rr_curcoef,
    rr_date    resrate.rr_date,
    rr_deptime resrate.rr_deptime,
    rr_package resrate.rr_package,
    rr_ratcoef resrate.rr_ratcoef,
    rr_ratecod resrate.rr_ratecod,
    rr_rateex  resrate.rr_rateex,
    rr_ratefrc resrate.rr_ratefrc,
    rr_ratepg  resrate.rr_ratepg,
    rr_raterc  resrate.rr_raterc,
    rr_raterd  resrate.rr_raterd,
    rr_raterf  resrate.rr_raterf,
    rr_reserid resrate.rr_reserid,
    rr_rrid    resrate.rr_rrid,
    rr_status  resrate.rr_status
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresrmshr AS caBase OF cit_ca.vcx
Alias = [caresrmshr]
Tables = [resrmshr]
KeyFieldList = [sr_shareid,sr_rroomid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sr_rroomid,
       sr_shareid
    FROM resrmshr
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sr_rroomid N(8,0)  DEFAULT 0,
    sr_shareid N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sr_rroomid,
    sr_shareid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sr_rroomid resrmshr.sr_rroomid,
    sr_shareid resrmshr.sr_shareid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresrooms AS caBase OF cit_ca.vcx
Alias = [caresrooms]
Tables = [resrooms]
KeyFieldList = [ri_rroomid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ri_date,
       ri_reserid,
       ri_roomnum,
       ri_roomtyp,
       ri_rroomid,
       ri_shareid,
       ri_todate
    FROM resrooms
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ri_date    D       DEFAULT {},
    ri_reserid N(12,3) DEFAULT 0,
    ri_roomnum C(4)    DEFAULT "",
    ri_roomtyp C(4)    DEFAULT "",
    ri_rroomid N(8,0)  DEFAULT 0,
    ri_shareid N(8,0)  DEFAULT 0,
    ri_todate  D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ri_date,
    ri_reserid,
    ri_roomnum,
    ri_roomtyp,
    ri_rroomid,
    ri_shareid,
    ri_todate
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ri_date    resrooms.ri_date,
    ri_reserid resrooms.ri_reserid,
    ri_roomnum resrooms.ri_roomnum,
    ri_roomtyp resrooms.ri_roomtyp,
    ri_rroomid resrooms.ri_rroomid,
    ri_shareid resrooms.ri_shareid,
    ri_todate  resrooms.ri_todate
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caressplit AS caBase OF cit_ca.vcx
Alias = [caressplit]
Tables = [ressplit]
KeyFieldList = [rl_rlid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rl_artinum,
       rl_artityp,
       rl_bqid,
       rl_date,
       rl_price,
       rl_raid,
       rl_ratecod,
       rl_rdate,
       rl_rdrsid,
       rl_rfid,
       rl_rlid,
       rl_rsid,
       rl_units
    FROM ressplit
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rl_artinum N(4,0)  DEFAULT 0,
    rl_artityp N(1,0)  DEFAULT 0,
    rl_bqid    I       DEFAULT 0,
    rl_date    D       DEFAULT {},
    rl_price   B(6)    DEFAULT 0,
    rl_raid    N(10,0) DEFAULT 0,
    rl_ratecod C(23)   DEFAULT "",
    rl_rdate   D       DEFAULT {},
    rl_rdrsid  I       DEFAULT 0,
    rl_rfid    I       DEFAULT 0,
    rl_rlid    I       DEFAULT 0,
    rl_rsid    I       DEFAULT 0,
    rl_units   B(2)    DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rl_artinum,
    rl_artityp,
    rl_bqid,
    rl_date,
    rl_price,
    rl_raid,
    rl_ratecod,
    rl_rdate,
    rl_rdrsid,
    rl_rfid,
    rl_rlid,
    rl_rsid,
    rl_units
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rl_artinum ressplit.rl_artinum,
    rl_artityp ressplit.rl_artityp,
    rl_bqid    ressplit.rl_bqid,
    rl_date    ressplit.rl_date,
    rl_price   ressplit.rl_price,
    rl_raid    ressplit.rl_raid,
    rl_ratecod ressplit.rl_ratecod,
    rl_rdate   ressplit.rl_rdate,
    rl_rdrsid  ressplit.rl_rdrsid,
    rl_rfid    ressplit.rl_rfid,
    rl_rlid    ressplit.rl_rlid,
    rl_rsid    ressplit.rl_rsid,
    rl_units   ressplit.rl_units
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caresyield AS caBase OF cit_ca.vcx
Alias = [caresyield]
Tables = [resyield]
KeyFieldList = [ry_ryid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ry_date,
       ry_occup,
       ry_rate,
       ry_ratecod,
       ry_ryid,
       ry_ycid,
       ry_yoid
    FROM resyield
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ry_date    D       DEFAULT {},
    ry_occup   N(3,0)  DEFAULT 0,
    ry_rate    B(8)    DEFAULT 0,
    ry_ratecod C(23)   DEFAULT "",
    ry_ryid    I       DEFAULT 0,
    ry_ycid    I       DEFAULT 0,
    ry_yoid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ry_date,
    ry_occup,
    ry_rate,
    ry_ratecod,
    ry_ryid,
    ry_ycid,
    ry_yoid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ry_date    resyield.ry_date,
    ry_occup   resyield.ry_occup,
    ry_rate    resyield.ry_rate,
    ry_ratecod resyield.ry_ratecod,
    ry_ryid    resyield.ry_ryid,
    ry_ycid    resyield.ry_ycid,
    ry_yoid    resyield.ry_yoid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caroom AS caBase OF cit_ca.vcx
Alias = [caroom]
Tables = [room]
KeyFieldList = [rm_roomnum]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rm_addrid,
       rm_bedchag,
       rm_bedchfr,
       rm_bedchld,
       rm_beds,
       rm_bmpfile,
       rm_cnfrang,
       rm_comment,
       rm_discr,
       rm_feature,
       rm_floor,
       rm_foocc,
       rm_foprs,
       rm_fostat,
       rm_geo,
       rm_hskdate,
       rm_hskocc,
       rm_hskprs,
       rm_inactiv,
       rm_keycard,
       rm_lang1,
       rm_lang10,
       rm_lang11,
       rm_lang2,
       rm_lang3,
       rm_lang4,
       rm_lang5,
       rm_lang6,
       rm_lang7,
       rm_lang8,
       rm_lang9,
       rm_link,
       rm_linkifc,
       rm_maid,
       rm_maxpers,
       rm_newgrp,
       rm_note,
       rm_phone,
       rm_ratecod,
       rm_rmname,
       rm_roomnum,
       rm_roomtyp,
       rm_rpseq,
       rm_sequ,
       rm_sqlink,
       rm_status,
       rm_tempera,
       rm_user1,
       rm_user10,
       rm_user2,
       rm_user3,
       rm_user4,
       rm_user5,
       rm_user6,
       rm_user7,
       rm_user8,
       rm_user9,
       rs_message,
       rs_msgshow
    FROM room
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rm_addrid  N(8,0)  DEFAULT 0,
    rm_bedchag N(1,0)  DEFAULT 0,
    rm_bedchfr N(1,0)  DEFAULT 0,
    rm_bedchld N(2,0)  DEFAULT 0,
    rm_beds    N(1,0)  DEFAULT 0,
    rm_bmpfile C(8)    DEFAULT "",
    rm_cnfrang C(3)    DEFAULT "",
    rm_comment C(30)   DEFAULT "",
    rm_discr   C(10)   DEFAULT "",
    rm_feature C(50)   DEFAULT "",
    rm_floor   N(2,0)  DEFAULT 0,
    rm_foocc   C(3)    DEFAULT "",
    rm_foprs   N(4,0)  DEFAULT 0,
    rm_fostat  C(30)   DEFAULT "",
    rm_geo     C(25)   DEFAULT "",
    rm_hskdate D       DEFAULT {},
    rm_hskocc  C(3)    DEFAULT "",
    rm_hskprs  N(4,0)  DEFAULT 0,
    rm_inactiv L       DEFAULT .F.,
    rm_keycard C(15)   DEFAULT "",
    rm_lang1   C(25)   DEFAULT "",
    rm_lang10  C(25)   DEFAULT "",
    rm_lang11  C(25)   DEFAULT "",
    rm_lang2   C(25)   DEFAULT "",
    rm_lang3   C(25)   DEFAULT "",
    rm_lang4   C(25)   DEFAULT "",
    rm_lang5   C(25)   DEFAULT "",
    rm_lang6   C(25)   DEFAULT "",
    rm_lang7   C(25)   DEFAULT "",
    rm_lang8   C(25)   DEFAULT "",
    rm_lang9   C(25)   DEFAULT "",
    rm_link    C(100)  DEFAULT "",
    rm_linkifc L       DEFAULT .F.,
    rm_maid    C(20)   DEFAULT "",
    rm_maxpers N(4,0)  DEFAULT 0,
    rm_newgrp  L       DEFAULT .F.,
    rm_note    M       DEFAULT "",
    rm_phone   C(20)   DEFAULT "",
    rm_ratecod C(10)   DEFAULT "",
    rm_rmname  C(10)   DEFAULT "",
    rm_roomnum C(4)    DEFAULT "",
    rm_roomtyp C(4)    DEFAULT "",
    rm_rpseq   N(4,0)  DEFAULT 0,
    rm_sequ    N(5,0)  DEFAULT 0,
    rm_sqlink  N(2,0)  DEFAULT 0,
    rm_status  C(3)    DEFAULT "",
    rm_tempera I       DEFAULT 0,
    rm_user1   C(50)   DEFAULT "",
    rm_user10  C(50)   DEFAULT "",
    rm_user2   C(50)   DEFAULT "",
    rm_user3   C(50)   DEFAULT "",
    rm_user4   C(50)   DEFAULT "",
    rm_user5   C(50)   DEFAULT "",
    rm_user6   C(50)   DEFAULT "",
    rm_user7   C(50)   DEFAULT "",
    rm_user8   C(50)   DEFAULT "",
    rm_user9   C(50)   DEFAULT "",
    rs_message M       DEFAULT "",
    rs_msgshow L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rm_addrid,
    rm_bedchag,
    rm_bedchfr,
    rm_bedchld,
    rm_beds,
    rm_bmpfile,
    rm_cnfrang,
    rm_comment,
    rm_discr,
    rm_feature,
    rm_floor,
    rm_foocc,
    rm_foprs,
    rm_fostat,
    rm_geo,
    rm_hskdate,
    rm_hskocc,
    rm_hskprs,
    rm_inactiv,
    rm_keycard,
    rm_lang1,
    rm_lang10,
    rm_lang11,
    rm_lang2,
    rm_lang3,
    rm_lang4,
    rm_lang5,
    rm_lang6,
    rm_lang7,
    rm_lang8,
    rm_lang9,
    rm_link,
    rm_linkifc,
    rm_maid,
    rm_maxpers,
    rm_newgrp,
    rm_note,
    rm_phone,
    rm_ratecod,
    rm_rmname,
    rm_roomnum,
    rm_roomtyp,
    rm_rpseq,
    rm_sequ,
    rm_sqlink,
    rm_status,
    rm_tempera,
    rm_user1,
    rm_user10,
    rm_user2,
    rm_user3,
    rm_user4,
    rm_user5,
    rm_user6,
    rm_user7,
    rm_user8,
    rm_user9,
    rs_message,
    rs_msgshow
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rm_addrid  room.rm_addrid,
    rm_bedchag room.rm_bedchag,
    rm_bedchfr room.rm_bedchfr,
    rm_bedchld room.rm_bedchld,
    rm_beds    room.rm_beds,
    rm_bmpfile room.rm_bmpfile,
    rm_cnfrang room.rm_cnfrang,
    rm_comment room.rm_comment,
    rm_discr   room.rm_discr,
    rm_feature room.rm_feature,
    rm_floor   room.rm_floor,
    rm_foocc   room.rm_foocc,
    rm_foprs   room.rm_foprs,
    rm_fostat  room.rm_fostat,
    rm_geo     room.rm_geo,
    rm_hskdate room.rm_hskdate,
    rm_hskocc  room.rm_hskocc,
    rm_hskprs  room.rm_hskprs,
    rm_inactiv room.rm_inactiv,
    rm_keycard room.rm_keycard,
    rm_lang1   room.rm_lang1,
    rm_lang10  room.rm_lang10,
    rm_lang11  room.rm_lang11,
    rm_lang2   room.rm_lang2,
    rm_lang3   room.rm_lang3,
    rm_lang4   room.rm_lang4,
    rm_lang5   room.rm_lang5,
    rm_lang6   room.rm_lang6,
    rm_lang7   room.rm_lang7,
    rm_lang8   room.rm_lang8,
    rm_lang9   room.rm_lang9,
    rm_link    room.rm_link,
    rm_linkifc room.rm_linkifc,
    rm_maid    room.rm_maid,
    rm_maxpers room.rm_maxpers,
    rm_newgrp  room.rm_newgrp,
    rm_note    room.rm_note,
    rm_phone   room.rm_phone,
    rm_ratecod room.rm_ratecod,
    rm_rmname  room.rm_rmname,
    rm_roomnum room.rm_roomnum,
    rm_roomtyp room.rm_roomtyp,
    rm_rpseq   room.rm_rpseq,
    rm_sequ    room.rm_sequ,
    rm_sqlink  room.rm_sqlink,
    rm_status  room.rm_status,
    rm_tempera room.rm_tempera,
    rm_user1   room.rm_user1,
    rm_user10  room.rm_user10,
    rm_user2   room.rm_user2,
    rm_user3   room.rm_user3,
    rm_user4   room.rm_user4,
    rm_user5   room.rm_user5,
    rm_user6   room.rm_user6,
    rm_user7   room.rm_user7,
    rm_user8   room.rm_user8,
    rm_user9   room.rm_user9,
    rs_message room.rs_message,
    rs_msgshow room.rs_msgshow
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caroomfeat AS caBase OF cit_ca.vcx
Alias = [caroomfeat]
Tables = [roomfeat]
KeyFieldList = [rf_roomnum,rf_feature]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rf_alldays,
       rf_artinum,
       rf_feature,
       rf_package,
       rf_price,
       rf_resfix,
       rf_roomnum,
       rf_units
    FROM roomfeat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_alldays L       DEFAULT .F.,
    rf_artinum N(4,0)  DEFAULT 0,
    rf_feature C(3)    DEFAULT "",
    rf_package L       DEFAULT .F.,
    rf_price   B(2)    DEFAULT 0,
    rf_resfix  L       DEFAULT .F.,
    rf_roomnum C(4)    DEFAULT "",
    rf_units   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_alldays,
    rf_artinum,
    rf_feature,
    rf_package,
    rf_price,
    rf_resfix,
    rf_roomnum,
    rf_units
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rf_alldays roomfeat.rf_alldays,
    rf_artinum roomfeat.rf_artinum,
    rf_feature roomfeat.rf_feature,
    rf_package roomfeat.rf_package,
    rf_price   roomfeat.rf_price,
    rf_resfix  roomfeat.rf_resfix,
    rf_roomnum roomfeat.rf_roomnum,
    rf_units   roomfeat.rf_units
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caroompict AS caBase OF cit_ca.vcx
Alias = [caroompict]
Tables = [roompict]
KeyFieldList = [ro_roomnum,ro_picid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ro_picid,
       ro_roomnum
    FROM roompict
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ro_picid   N(8,0)  DEFAULT 0,
    ro_roomnum C(4)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ro_picid,
    ro_roomnum
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ro_picid   roompict.ro_picid,
    ro_roomnum roompict.ro_roomnum
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caroomplan AS caBase OF cit_ca.vcx
Alias = [caroomplan]
Tables = [roomplan]
KeyFieldList = [rp_date,rp_roomnum,rp_rroomid,rp_ooid,rp_osid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rp_date,
       rp_exinfo,
       rp_link,
       rp_nights,
       rp_ooid,
       rp_osid,
       rp_reason,
       rp_reserid,
       rp_roomnum,
       rp_rroomid,
       rp_shareid,
       rp_status
    FROM roomplan
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rp_date    D       DEFAULT {},
    rp_exinfo  C(10)   DEFAULT "",
    rp_link    L       DEFAULT .F.,
    rp_nights  N(4,0)  DEFAULT 0,
    rp_ooid    N(8,0)  DEFAULT 0,
    rp_osid    N(8,0)  DEFAULT 0,
    rp_reason  C(20)   DEFAULT "",
    rp_reserid N(12,3) DEFAULT 0,
    rp_roomnum C(4)    DEFAULT "",
    rp_rroomid N(8,0)  DEFAULT 0,
    rp_shareid N(8,0)  DEFAULT 0,
    rp_status  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rp_date,
    rp_exinfo,
    rp_link,
    rp_nights,
    rp_ooid,
    rp_osid,
    rp_reason,
    rp_reserid,
    rp_roomnum,
    rp_rroomid,
    rp_shareid,
    rp_status
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rp_date    roomplan.rp_date,
    rp_exinfo  roomplan.rp_exinfo,
    rp_link    roomplan.rp_link,
    rp_nights  roomplan.rp_nights,
    rp_ooid    roomplan.rp_ooid,
    rp_osid    roomplan.rp_osid,
    rp_reason  roomplan.rp_reason,
    rp_reserid roomplan.rp_reserid,
    rp_roomnum roomplan.rp_roomnum,
    rp_rroomid roomplan.rp_rroomid,
    rp_shareid roomplan.rp_shareid,
    rp_status  roomplan.rp_status
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caroomtpic AS caBase OF cit_ca.vcx
Alias = [caroomtpic]
Tables = [roomtpic]
KeyFieldList = [ro_roomtyp,ro_picid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ro_picid,
       ro_roomtyp
    FROM roomtpic
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ro_picid   N(8,0)  DEFAULT 0,
    ro_roomtyp C(4)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ro_picid,
    ro_roomtyp
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ro_picid   roomtpic.ro_picid,
    ro_roomtyp roomtpic.ro_roomtyp
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caroomtype AS caBase OF cit_ca.vcx
Alias = [caroomtype]
Tables = [roomtype]
KeyFieldList = [rt_roomtyp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rt_avlpct1,
       rt_avlpct2,
       rt_avlpct3,
       rt_buildng,
       rt_cocolid,
       rt_confev,
       rt_dumtype,
       rt_ftbold,
       rt_ftcolid,
       rt_group,
       rt_lang1,
       rt_lang10,
       rt_lang11,
       rt_lang2,
       rt_lang3,
       rt_lang4,
       rt_lang5,
       rt_lang6,
       rt_lang7,
       rt_lang8,
       rt_lang9,
       rt_maxpers,
       rt_note,
       rt_paymstr,
       rt_ratecod,
       rt_rdid,
       rt_roomreq,
       rt_roomtyp,
       rt_sequenc,
       rt_virroom,
       rt_vwfmt,
       rt_vwshow,
       rt_vwsize,
       rt_vwsum,
       rt_wbcusrt,
       rt_wbmain,
       rt_wborder,
       rt_webroom,
       rt_wlang1,
       rt_wlang2,
       rt_wlang3,
       rt_wlang4,
       rt_wlang5,
       rt_wlang6,
       rt_wlang7,
       rt_wlang8,
       rt_wlang9
    FROM roomtype
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rt_avlpct1 N(2,0)  DEFAULT 0,
    rt_avlpct2 N(2,0)  DEFAULT 0,
    rt_avlpct3 N(2,0)  DEFAULT 0,
    rt_buildng C(3)    DEFAULT "",
    rt_cocolid N(8,0)  DEFAULT 0,
    rt_confev  L       DEFAULT .F.,
    rt_dumtype N(1,0)  DEFAULT 0,
    rt_ftbold  L       DEFAULT .F.,
    rt_ftcolid N(8,0)  DEFAULT 0,
    rt_group   N(1,0)  DEFAULT 0,
    rt_lang1   C(25)   DEFAULT "",
    rt_lang10  C(25)   DEFAULT "",
    rt_lang11  C(25)   DEFAULT "",
    rt_lang2   C(25)   DEFAULT "",
    rt_lang3   C(25)   DEFAULT "",
    rt_lang4   C(25)   DEFAULT "",
    rt_lang5   C(25)   DEFAULT "",
    rt_lang6   C(25)   DEFAULT "",
    rt_lang7   C(25)   DEFAULT "",
    rt_lang8   C(25)   DEFAULT "",
    rt_lang9   C(25)   DEFAULT "",
    rt_maxpers N(4,0)  DEFAULT 0,
    rt_note    M       DEFAULT "",
    rt_paymstr L       DEFAULT .F.,
    rt_ratecod C(10)   DEFAULT "",
    rt_rdid    I       DEFAULT 0,
    rt_roomreq L       DEFAULT .F.,
    rt_roomtyp C(4)    DEFAULT "",
    rt_sequenc N(2,0)  DEFAULT 0,
    rt_virroom C(3)    DEFAULT "",
    rt_vwfmt   C(6)    DEFAULT "",
    rt_vwshow  L       DEFAULT .F.,
    rt_vwsize  N(4,1)  DEFAULT 0,
    rt_vwsum   L       DEFAULT .F.,
    rt_wbcusrt C(4)    DEFAULT "",
    rt_wbmain  L       DEFAULT .F.,
    rt_wborder N(2,0)  DEFAULT 0,
    rt_webroom N(4,0)  DEFAULT 0,
    rt_wlang1  M       DEFAULT "",
    rt_wlang2  M       DEFAULT "",
    rt_wlang3  M       DEFAULT "",
    rt_wlang4  M       DEFAULT "",
    rt_wlang5  M       DEFAULT "",
    rt_wlang6  M       DEFAULT "",
    rt_wlang7  M       DEFAULT "",
    rt_wlang8  M       DEFAULT "",
    rt_wlang9  M       DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rt_avlpct1,
    rt_avlpct2,
    rt_avlpct3,
    rt_buildng,
    rt_cocolid,
    rt_confev,
    rt_dumtype,
    rt_ftbold,
    rt_ftcolid,
    rt_group,
    rt_lang1,
    rt_lang10,
    rt_lang11,
    rt_lang2,
    rt_lang3,
    rt_lang4,
    rt_lang5,
    rt_lang6,
    rt_lang7,
    rt_lang8,
    rt_lang9,
    rt_maxpers,
    rt_note,
    rt_paymstr,
    rt_ratecod,
    rt_rdid,
    rt_roomreq,
    rt_roomtyp,
    rt_sequenc,
    rt_virroom,
    rt_vwfmt,
    rt_vwshow,
    rt_vwsize,
    rt_vwsum,
    rt_wbcusrt,
    rt_wbmain,
    rt_wborder,
    rt_webroom,
    rt_wlang1,
    rt_wlang2,
    rt_wlang3,
    rt_wlang4,
    rt_wlang5,
    rt_wlang6,
    rt_wlang7,
    rt_wlang8,
    rt_wlang9
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rt_avlpct1 roomtype.rt_avlpct1,
    rt_avlpct2 roomtype.rt_avlpct2,
    rt_avlpct3 roomtype.rt_avlpct3,
    rt_buildng roomtype.rt_buildng,
    rt_cocolid roomtype.rt_cocolid,
    rt_confev  roomtype.rt_confev,
    rt_dumtype roomtype.rt_dumtype,
    rt_ftbold  roomtype.rt_ftbold,
    rt_ftcolid roomtype.rt_ftcolid,
    rt_group   roomtype.rt_group,
    rt_lang1   roomtype.rt_lang1,
    rt_lang10  roomtype.rt_lang10,
    rt_lang11  roomtype.rt_lang11,
    rt_lang2   roomtype.rt_lang2,
    rt_lang3   roomtype.rt_lang3,
    rt_lang4   roomtype.rt_lang4,
    rt_lang5   roomtype.rt_lang5,
    rt_lang6   roomtype.rt_lang6,
    rt_lang7   roomtype.rt_lang7,
    rt_lang8   roomtype.rt_lang8,
    rt_lang9   roomtype.rt_lang9,
    rt_maxpers roomtype.rt_maxpers,
    rt_note    roomtype.rt_note,
    rt_paymstr roomtype.rt_paymstr,
    rt_ratecod roomtype.rt_ratecod,
    rt_rdid    roomtype.rt_rdid,
    rt_roomreq roomtype.rt_roomreq,
    rt_roomtyp roomtype.rt_roomtyp,
    rt_sequenc roomtype.rt_sequenc,
    rt_virroom roomtype.rt_virroom,
    rt_vwfmt   roomtype.rt_vwfmt,
    rt_vwshow  roomtype.rt_vwshow,
    rt_vwsize  roomtype.rt_vwsize,
    rt_vwsum   roomtype.rt_vwsum,
    rt_wbcusrt roomtype.rt_wbcusrt,
    rt_wbmain  roomtype.rt_wbmain,
    rt_wborder roomtype.rt_wborder,
    rt_webroom roomtype.rt_webroom,
    rt_wlang1  roomtype.rt_wlang1,
    rt_wlang2  roomtype.rt_wlang2,
    rt_wlang3  roomtype.rt_wlang3,
    rt_wlang4  roomtype.rt_wlang4,
    rt_wlang5  roomtype.rt_wlang5,
    rt_wlang6  roomtype.rt_wlang6,
    rt_wlang7  roomtype.rt_wlang7,
    rt_wlang8  roomtype.rt_wlang8,
    rt_wlang9  roomtype.rt_wlang9
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carpostifc AS caBase OF cit_ca.vcx
Alias = [carpostifc]
Tables = [rpostifc]
KeyFieldList = [rk_rkid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rk_deleted,
       rk_dsetid,
       rk_from,
       rk_intcls,
       rk_pttcls,
       rk_ptvcls,
       rk_rkid,
       rk_rsid,
       rk_setid,
       rk_to
    FROM rpostifc
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rk_deleted L       DEFAULT .F.,
    rk_dsetid  I       DEFAULT 0,
    rk_from    D       DEFAULT {},
    rk_intcls  C(10)   DEFAULT "",
    rk_pttcls  C(10)   DEFAULT "",
    rk_ptvcls  C(10)   DEFAULT "",
    rk_rkid    I       DEFAULT 0,
    rk_rsid    I       DEFAULT 0,
    rk_setid   I       DEFAULT 0,
    rk_to      D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rk_deleted,
    rk_dsetid,
    rk_from,
    rk_intcls,
    rk_pttcls,
    rk_ptvcls,
    rk_rkid,
    rk_rsid,
    rk_setid,
    rk_to
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rk_deleted rpostifc.rk_deleted,
    rk_dsetid  rpostifc.rk_dsetid,
    rk_from    rpostifc.rk_from,
    rk_intcls  rpostifc.rk_intcls,
    rk_pttcls  rpostifc.rk_pttcls,
    rk_ptvcls  rpostifc.rk_ptvcls,
    rk_rkid    rpostifc.rk_rkid,
    rk_rsid    rpostifc.rk_rsid,
    rk_setid   rpostifc.rk_setid,
    rk_to      rpostifc.rk_to
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carsifsync AS caBase OF cit_ca.vcx
Alias = [carsifsync]
Tables = [rsifsync]
KeyFieldList = [rq_rqid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rq_action,
       rq_adults,
       rq_changes,
       rq_child1,
       rq_child2,
       rq_child3,
       rq_created,
       rq_done,
       rq_end,
       rq_market,
       rq_notroom,
       rq_ratedat,
       rq_resgues,
       rq_respost,
       rq_resroom,
       rq_resspli,
       rq_rooms,
       rq_rqid,
       rq_rsid,
       rq_source,
       rq_start,
       rq_status,
       rq_timesta,
       rq_timisec,
       rq_updated
    FROM rsifsync
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rq_action  C(8)    DEFAULT "",
    rq_adults  N(3,0)  DEFAULT 0,
    rq_changes M       DEFAULT "",
    rq_child1  N(2,0)  DEFAULT 0,
    rq_child2  N(2,0)  DEFAULT 0,
    rq_child3  N(2,0)  DEFAULT 0,
    rq_created D       DEFAULT {},
    rq_done    T       DEFAULT {},
    rq_end     D       DEFAULT {},
    rq_market  C(3)    DEFAULT "",
    rq_notroom L       DEFAULT .F.,
    rq_ratedat D       DEFAULT {},
    rq_resgues M       DEFAULT "",
    rq_respost M       DEFAULT "",
    rq_resroom M       DEFAULT "",
    rq_resspli M       DEFAULT "",
    rq_rooms   N(3,0)  DEFAULT 0,
    rq_rqid    N(10,0) DEFAULT 0,
    rq_rsid    N(8,0)  DEFAULT 0,
    rq_source  C(3)    DEFAULT "",
    rq_start   D       DEFAULT {},
    rq_status  C(3)    DEFAULT "",
    rq_timesta T       DEFAULT {},
    rq_timisec N(3,0)  DEFAULT 0,
    rq_updated D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rq_action,
    rq_adults,
    rq_changes,
    rq_child1,
    rq_child2,
    rq_child3,
    rq_created,
    rq_done,
    rq_end,
    rq_market,
    rq_notroom,
    rq_ratedat,
    rq_resgues,
    rq_respost,
    rq_resroom,
    rq_resspli,
    rq_rooms,
    rq_rqid,
    rq_rsid,
    rq_source,
    rq_start,
    rq_status,
    rq_timesta,
    rq_timisec,
    rq_updated
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rq_action  rsifsync.rq_action,
    rq_adults  rsifsync.rq_adults,
    rq_changes rsifsync.rq_changes,
    rq_child1  rsifsync.rq_child1,
    rq_child2  rsifsync.rq_child2,
    rq_child3  rsifsync.rq_child3,
    rq_created rsifsync.rq_created,
    rq_done    rsifsync.rq_done,
    rq_end     rsifsync.rq_end,
    rq_market  rsifsync.rq_market,
    rq_notroom rsifsync.rq_notroom,
    rq_ratedat rsifsync.rq_ratedat,
    rq_resgues rsifsync.rq_resgues,
    rq_respost rsifsync.rq_respost,
    rq_resroom rsifsync.rq_resroom,
    rq_resspli rsifsync.rq_resspli,
    rq_rooms   rsifsync.rq_rooms,
    rq_rqid    rsifsync.rq_rqid,
    rq_rsid    rsifsync.rq_rsid,
    rq_source  rsifsync.rq_source,
    rq_start   rsifsync.rq_start,
    rq_status  rsifsync.rq_status,
    rq_timesta rsifsync.rq_timesta,
    rq_timisec rsifsync.rq_timisec,
    rq_updated rsifsync.rq_updated
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cartypedef AS caBase OF cit_ca.vcx
Alias = [cartypedef]
Tables = [rtypedef]
KeyFieldList = [rd_rdid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rd_cocolid,
       rd_ftbold,
       rd_ftcolid,
       rd_group,
       rd_lang1,
       rd_lang10,
       rd_lang11,
       rd_lang2,
       rd_lang3,
       rd_lang4,
       rd_lang5,
       rd_lang6,
       rd_lang7,
       rd_lang8,
       rd_lang9,
       rd_maxpers,
       rd_paymstr,
       rd_rdid,
       rd_roomtyp,
       rd_verent,
       rd_vwshow,
       rd_vwsize,
       rd_vwsum
    FROM rtypedef
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_cocolid N(8,0)  DEFAULT 0,
    rd_ftbold  L       DEFAULT .F.,
    rd_ftcolid N(8,0)  DEFAULT 0,
    rd_group   N(1,0)  DEFAULT 0,
    rd_lang1   C(25)   DEFAULT "",
    rd_lang10  C(25)   DEFAULT "",
    rd_lang11  C(25)   DEFAULT "",
    rd_lang2   C(25)   DEFAULT "",
    rd_lang3   C(25)   DEFAULT "",
    rd_lang4   C(25)   DEFAULT "",
    rd_lang5   C(25)   DEFAULT "",
    rd_lang6   C(25)   DEFAULT "",
    rd_lang7   C(25)   DEFAULT "",
    rd_lang8   C(25)   DEFAULT "",
    rd_lang9   C(25)   DEFAULT "",
    rd_maxpers N(4,0)  DEFAULT 0,
    rd_paymstr L       DEFAULT .F.,
    rd_rdid    I       DEFAULT 0,
    rd_roomtyp C(10)   DEFAULT "",
    rd_verent  L       DEFAULT .F.,
    rd_vwshow  L       DEFAULT .F.,
    rd_vwsize  N(4,1)  DEFAULT 0,
    rd_vwsum   L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_cocolid,
    rd_ftbold,
    rd_ftcolid,
    rd_group,
    rd_lang1,
    rd_lang10,
    rd_lang11,
    rd_lang2,
    rd_lang3,
    rd_lang4,
    rd_lang5,
    rd_lang6,
    rd_lang7,
    rd_lang8,
    rd_lang9,
    rd_maxpers,
    rd_paymstr,
    rd_rdid,
    rd_roomtyp,
    rd_verent,
    rd_vwshow,
    rd_vwsize,
    rd_vwsum
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_cocolid rtypedef.rd_cocolid,
    rd_ftbold  rtypedef.rd_ftbold,
    rd_ftcolid rtypedef.rd_ftcolid,
    rd_group   rtypedef.rd_group,
    rd_lang1   rtypedef.rd_lang1,
    rd_lang10  rtypedef.rd_lang10,
    rd_lang11  rtypedef.rd_lang11,
    rd_lang2   rtypedef.rd_lang2,
    rd_lang3   rtypedef.rd_lang3,
    rd_lang4   rtypedef.rd_lang4,
    rd_lang5   rtypedef.rd_lang5,
    rd_lang6   rtypedef.rd_lang6,
    rd_lang7   rtypedef.rd_lang7,
    rd_lang8   rtypedef.rd_lang8,
    rd_lang9   rtypedef.rd_lang9,
    rd_maxpers rtypedef.rd_maxpers,
    rd_paymstr rtypedef.rd_paymstr,
    rd_rdid    rtypedef.rd_rdid,
    rd_roomtyp rtypedef.rd_roomtyp,
    rd_verent  rtypedef.rd_verent,
    rd_vwshow  rtypedef.rd_vwshow,
    rd_vwsize  rtypedef.rd_vwsize,
    rd_vwsum   rtypedef.rd_vwsum
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cascreens AS caBase OF cit_ca.vcx
Alias = [cascreens]
Tables = [screens]
KeyFieldList = [sc_label,sc_userid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sc_backlin,
       sc_fh,
       sc_fw,
       sc_height,
       sc_label,
       sc_left,
       sc_maxi,
       sc_set1,
       sc_top,
       sc_userid,
       sc_usset1,
       sc_usset2,
       sc_usset3,
       sc_ussets,
       sc_wcolor1,
       sc_wcolor2,
       sc_wcolor3,
       sc_wcolor4,
       sc_width,
       sc_wrange1,
       sc_wrange2,
       sc_wrange3,
       sc_wrange4
    FROM screens
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_backlin L       DEFAULT .F.,
    sc_fh      N(10,4) DEFAULT 0,
    sc_fw      N(10,4) DEFAULT 0,
    sc_height  N(4,0)  DEFAULT 0,
    sc_label   C(20)   DEFAULT "",
    sc_left    N(4,0)  DEFAULT 0,
    sc_maxi    L       DEFAULT .F.,
    sc_set1    L       DEFAULT .F.,
    sc_top     N(4,0)  DEFAULT 0,
    sc_userid  C(10)   DEFAULT "",
    sc_usset1  L       DEFAULT .F.,
    sc_usset2  L       DEFAULT .F.,
    sc_usset3  L       DEFAULT .F.,
    sc_ussets  C(30)   DEFAULT "",
    sc_wcolor1 N(8,0)  DEFAULT 0,
    sc_wcolor2 N(8,0)  DEFAULT 0,
    sc_wcolor3 N(8,0)  DEFAULT 0,
    sc_wcolor4 N(8,0)  DEFAULT 0,
    sc_width   N(4,0)  DEFAULT 0,
    sc_wrange1 N(2,0)  DEFAULT 0,
    sc_wrange2 N(2,0)  DEFAULT 0,
    sc_wrange3 N(2,0)  DEFAULT 0,
    sc_wrange4 N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_backlin,
    sc_fh,
    sc_fw,
    sc_height,
    sc_label,
    sc_left,
    sc_maxi,
    sc_set1,
    sc_top,
    sc_userid,
    sc_usset1,
    sc_usset2,
    sc_usset3,
    sc_ussets,
    sc_wcolor1,
    sc_wcolor2,
    sc_wcolor3,
    sc_wcolor4,
    sc_width,
    sc_wrange1,
    sc_wrange2,
    sc_wrange3,
    sc_wrange4
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_backlin screens.sc_backlin,
    sc_fh      screens.sc_fh,
    sc_fw      screens.sc_fw,
    sc_height  screens.sc_height,
    sc_label   screens.sc_label,
    sc_left    screens.sc_left,
    sc_maxi    screens.sc_maxi,
    sc_set1    screens.sc_set1,
    sc_top     screens.sc_top,
    sc_userid  screens.sc_userid,
    sc_usset1  screens.sc_usset1,
    sc_usset2  screens.sc_usset2,
    sc_usset3  screens.sc_usset3,
    sc_ussets  screens.sc_ussets,
    sc_wcolor1 screens.sc_wcolor1,
    sc_wcolor2 screens.sc_wcolor2,
    sc_wcolor3 screens.sc_wcolor3,
    sc_wcolor4 screens.sc_wcolor4,
    sc_width   screens.sc_width,
    sc_wrange1 screens.sc_wrange1,
    sc_wrange2 screens.sc_wrange2,
    sc_wrange3 screens.sc_wrange3,
    sc_wrange4 screens.sc_wrange4
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caseason AS caBase OF cit_ca.vcx
Alias = [caseason]
Tables = [season]
KeyFieldList = [se_date]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       se_color,
       se_date,
       se_event,
       se_hotclos,
       se_season
    FROM season
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    se_color   C(11)   DEFAULT "",
    se_date    D       DEFAULT {},
    se_event   C(100)  DEFAULT "",
    se_hotclos L       DEFAULT .F.,
    se_season  C(1)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    se_color,
    se_date,
    se_event,
    se_hotclos,
    se_season
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    se_color   season.se_color,
    se_date    season.se_date,
    se_event   season.se_event,
    se_hotclos season.se_hotclos,
    se_season  season.se_season
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS casharing AS caBase OF cit_ca.vcx
Alias = [casharing]
Tables = [sharing]
KeyFieldList = [sd_shareid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sd_highdat,
       sd_history,
       sd_lowdat,
       sd_nomembr,
       sd_roomnum,
       sd_roomtyp,
       sd_shareid,
       sd_status
    FROM sharing
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sd_highdat D       DEFAULT {},
    sd_history L       DEFAULT .F.,
    sd_lowdat  D       DEFAULT {},
    sd_nomembr N(2,0)  DEFAULT 0,
    sd_roomnum C(4)    DEFAULT "",
    sd_roomtyp C(4)    DEFAULT "",
    sd_shareid N(8,0)  DEFAULT 0,
    sd_status  C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sd_highdat,
    sd_history,
    sd_lowdat,
    sd_nomembr,
    sd_roomnum,
    sd_roomtyp,
    sd_shareid,
    sd_status
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sd_highdat sharing.sd_highdat,
    sd_history sharing.sd_history,
    sd_lowdat  sharing.sd_lowdat,
    sd_nomembr sharing.sd_nomembr,
    sd_roomnum sharing.sd_roomnum,
    sd_roomtyp sharing.sd_roomtyp,
    sd_shareid sharing.sd_shareid,
    sd_status  sharing.sd_status
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS casubgrp AS caBase OF cit_ca.vcx
Alias = [casubgrp]
Tables = [subgrp]
KeyFieldList = [sg_nummer]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sg_hg,
       sg_nummer,
       sg_og,
       sg_prozent,
       sg_text,
       sg_von
    FROM subgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sg_hg      N(2,0)  DEFAULT 0,
    sg_nummer  N(3,0)  DEFAULT 0,
    sg_og      N(3,0)  DEFAULT 0,
    sg_prozent N(6,2)  DEFAULT 0,
    sg_text    C(30)   DEFAULT "",
    sg_von     C(1)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sg_hg,
    sg_nummer,
    sg_og,
    sg_prozent,
    sg_text,
    sg_von
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sg_hg      subgrp.sg_hg,
    sg_nummer  subgrp.sg_nummer,
    sg_og      subgrp.sg_og,
    sg_prozent subgrp.sg_prozent,
    sg_text    subgrp.sg_text,
    sg_von     subgrp.sg_von
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caterminal AS caBase OF cit_ca.vcx
Alias = [caterminal]
Tables = [terminal]
KeyFieldList = [tm_termnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tm_benum,
       tm_callpre,
       tm_calltap,
       tm_calluse,
       tm_citwebm,
       tm_crwbaud,
       tm_crwdriv,
       tm_crwifc,
       tm_crwport,
       tm_debtap,
       tm_drwexe,
       tm_elcltid,
       tm_elksz2,
       tm_elpcph,
       tm_elpcpn,
       tm_elpcps,
       tm_elpcrt,
       tm_elpcrw,
       tm_elpdir,
       tm_elpfrx,
       tm_elpport,
       tm_elpprn,
       tm_elte1,
       tm_elte2,
       tm_elte3,
       tm_eltimeo,
       tm_elts1,
       tm_elts2,
       tm_elts3,
       tm_elwidth,
       tm_endate,
       tm_entime,
       tm_fpnr,
       tm_fpoff,
       tm_gexchda,
       tm_gexchon,
       tm_gexchtm,
       tm_haddres,
       tm_hafele,
       tm_hcoder,
       tm_hiactiv,
       tm_hport,
       tm_itec,
       tm_itecp,
       tm_nortap,
       tm_termnr,
       tm_winname
    FROM terminal
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tm_benum   N(2,0)  DEFAULT 0,
    tm_callpre C(10)   DEFAULT "",
    tm_calltap C(254)  DEFAULT "",
    tm_calluse L       DEFAULT .F.,
    tm_citwebm L       DEFAULT .F.,
    tm_crwbaud N(6,0)  DEFAULT 0,
    tm_crwdriv C(25)   DEFAULT "",
    tm_crwifc  L       DEFAULT .F.,
    tm_crwport C(6)    DEFAULT "",
    tm_debtap  L       DEFAULT .F.,
    tm_drwexe  C(254)  DEFAULT "",
    tm_elcltid N(3,0)  DEFAULT 0,
    tm_elksz2  L       DEFAULT .F.,
    tm_elpcph  C(1)    DEFAULT "",
    tm_elpcpn  C(5)    DEFAULT "",
    tm_elpcps  C(12)   DEFAULT "",
    tm_elpcrt  C(1)    DEFAULT "",
    tm_elpcrw  N(4,0)  DEFAULT 0,
    tm_elpdir  C(100)  DEFAULT "",
    tm_elpfrx  C(20)   DEFAULT "",
    tm_elpport C(30)   DEFAULT "",
    tm_elpprn  M       DEFAULT "",
    tm_elte1   C(10)   DEFAULT "",
    tm_elte2   C(10)   DEFAULT "",
    tm_elte3   C(10)   DEFAULT "",
    tm_eltimeo N(3,0)  DEFAULT 0,
    tm_elts1   C(10)   DEFAULT "",
    tm_elts2   C(10)   DEFAULT "",
    tm_elts3   C(10)   DEFAULT "",
    tm_elwidth N(3,0)  DEFAULT 0,
    tm_endate  D       DEFAULT {},
    tm_entime  C(5)    DEFAULT "",
    tm_fpnr    N(2,0)  DEFAULT 0,
    tm_fpoff   L       DEFAULT .F.,
    tm_gexchda D       DEFAULT {},
    tm_gexchon L       DEFAULT .F.,
    tm_gexchtm C(4)    DEFAULT "",
    tm_haddres C(20)   DEFAULT "",
    tm_hafele  L       DEFAULT .F.,
    tm_hcoder  C(20)   DEFAULT "",
    tm_hiactiv L       DEFAULT .F.,
    tm_hport   N(5,0)  DEFAULT 0,
    tm_itec    L       DEFAULT .F.,
    tm_itecp   N(2,0)  DEFAULT 0,
    tm_nortap  L       DEFAULT .F.,
    tm_termnr  N(2,0)  DEFAULT 0,
    tm_winname C(15)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tm_benum,
    tm_callpre,
    tm_calltap,
    tm_calluse,
    tm_citwebm,
    tm_crwbaud,
    tm_crwdriv,
    tm_crwifc,
    tm_crwport,
    tm_debtap,
    tm_drwexe,
    tm_elcltid,
    tm_elksz2,
    tm_elpcph,
    tm_elpcpn,
    tm_elpcps,
    tm_elpcrt,
    tm_elpcrw,
    tm_elpdir,
    tm_elpfrx,
    tm_elpport,
    tm_elpprn,
    tm_elte1,
    tm_elte2,
    tm_elte3,
    tm_eltimeo,
    tm_elts1,
    tm_elts2,
    tm_elts3,
    tm_elwidth,
    tm_endate,
    tm_entime,
    tm_fpnr,
    tm_fpoff,
    tm_gexchda,
    tm_gexchon,
    tm_gexchtm,
    tm_haddres,
    tm_hafele,
    tm_hcoder,
    tm_hiactiv,
    tm_hport,
    tm_itec,
    tm_itecp,
    tm_nortap,
    tm_termnr,
    tm_winname
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tm_benum   terminal.tm_benum,
    tm_callpre terminal.tm_callpre,
    tm_calltap terminal.tm_calltap,
    tm_calluse terminal.tm_calluse,
    tm_citwebm terminal.tm_citwebm,
    tm_crwbaud terminal.tm_crwbaud,
    tm_crwdriv terminal.tm_crwdriv,
    tm_crwifc  terminal.tm_crwifc,
    tm_crwport terminal.tm_crwport,
    tm_debtap  terminal.tm_debtap,
    tm_drwexe  terminal.tm_drwexe,
    tm_elcltid terminal.tm_elcltid,
    tm_elksz2  terminal.tm_elksz2,
    tm_elpcph  terminal.tm_elpcph,
    tm_elpcpn  terminal.tm_elpcpn,
    tm_elpcps  terminal.tm_elpcps,
    tm_elpcrt  terminal.tm_elpcrt,
    tm_elpcrw  terminal.tm_elpcrw,
    tm_elpdir  terminal.tm_elpdir,
    tm_elpfrx  terminal.tm_elpfrx,
    tm_elpport terminal.tm_elpport,
    tm_elpprn  terminal.tm_elpprn,
    tm_elte1   terminal.tm_elte1,
    tm_elte2   terminal.tm_elte2,
    tm_elte3   terminal.tm_elte3,
    tm_eltimeo terminal.tm_eltimeo,
    tm_elts1   terminal.tm_elts1,
    tm_elts2   terminal.tm_elts2,
    tm_elts3   terminal.tm_elts3,
    tm_elwidth terminal.tm_elwidth,
    tm_endate  terminal.tm_endate,
    tm_entime  terminal.tm_entime,
    tm_fpnr    terminal.tm_fpnr,
    tm_fpoff   terminal.tm_fpoff,
    tm_gexchda terminal.tm_gexchda,
    tm_gexchon terminal.tm_gexchon,
    tm_gexchtm terminal.tm_gexchtm,
    tm_haddres terminal.tm_haddres,
    tm_hafele  terminal.tm_hafele,
    tm_hcoder  terminal.tm_hcoder,
    tm_hiactiv terminal.tm_hiactiv,
    tm_hport   terminal.tm_hport,
    tm_itec    terminal.tm_itec,
    tm_itecp   terminal.tm_itecp,
    tm_nortap  terminal.tm_nortap,
    tm_termnr  terminal.tm_termnr,
    tm_winname terminal.tm_winname
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catimetype AS caBase OF cit_ca.vcx
Alias = [catimetype]
Tables = [timetype]
KeyFieldList = [tt_ttnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tt_code,
       tt_deleted,
       tt_descr,
       tt_setpl0,
       tt_timepct,
       tt_timunit,
       tt_ttnr,
       tt_vacatio
    FROM timetype
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tt_code    C(2)    DEFAULT "",
    tt_deleted L       DEFAULT .F.,
    tt_descr   C(20)   DEFAULT "",
    tt_setpl0  L       DEFAULT .F.,
    tt_timepct N(3,0)  DEFAULT 0,
    tt_timunit N(1,0)  DEFAULT 0,
    tt_ttnr    N(2,0)  DEFAULT 0,
    tt_vacatio L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tt_code,
    tt_deleted,
    tt_descr,
    tt_setpl0,
    tt_timepct,
    tt_timunit,
    tt_ttnr,
    tt_vacatio
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tt_code    timetype.tt_code,
    tt_deleted timetype.tt_deleted,
    tt_descr   timetype.tt_descr,
    tt_setpl0  timetype.tt_setpl0,
    tt_timepct timetype.tt_timepct,
    tt_timunit timetype.tt_timunit,
    tt_ttnr    timetype.tt_ttnr,
    tt_vacatio timetype.tt_vacatio
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catitle AS caBase OF cit_ca.vcx
Alias = [catitle]
Tables = [title]
KeyFieldList = [ti_titlcod,ti_lang]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ti_attn,
       ti_lang,
       ti_salute,
       ti_titlcod,
       ti_title
    FROM title
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ti_attn    C(10)   DEFAULT "",
    ti_lang    C(3)    DEFAULT "",
    ti_salute  C(50)   DEFAULT "",
    ti_titlcod N(2,0)  DEFAULT 0,
    ti_title   C(25)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ti_attn,
    ti_lang,
    ti_salute,
    ti_titlcod,
    ti_title
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ti_attn    title.ti_attn,
    ti_lang    title.ti_lang,
    ti_salute  title.ti_salute,
    ti_titlcod title.ti_titlcod,
    ti_title   title.ti_title
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caugimp AS caBase OF cit_ca.vcx
Alias = [caugimp]
Tables = [ugimp]
KeyFieldList = [ug_ugid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ug_file,
       ug_sysdate,
       ug_text,
       ug_time,
       ug_ugid
    FROM ugimp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ug_file    C(254)  DEFAULT "",
    ug_sysdate D       DEFAULT {},
    ug_text    M       DEFAULT "",
    ug_time    T       DEFAULT {},
    ug_ugid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ug_file,
    ug_sysdate,
    ug_text,
    ug_time,
    ug_ugid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ug_file    ugimp.ug_file,
    ug_sysdate ugimp.ug_sysdate,
    ug_text    ugimp.ug_text,
    ug_time    ugimp.ug_time,
    ug_ugid    ugimp.ug_ugid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS causer AS caBase OF cit_ca.vcx
Alias = [causer]
Tables = [user]
KeyFieldList = [us_id]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       us_cashier,
       us_dep,
       us_email,
       us_fax,
       us_group,
       us_id,
       us_inactiv,
       us_lang,
       us_name,
       us_pass,
       us_phone,
       us_websrv
    FROM user
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    us_cashier N(2,0)  DEFAULT 0,
    us_dep     C(30)   DEFAULT "",
    us_email   C(100)  DEFAULT "",
    us_fax     C(20)   DEFAULT "",
    us_group   C(10)   DEFAULT "",
    us_id      C(10)   DEFAULT "",
    us_inactiv L       DEFAULT .F.,
    us_lang    C(3)    DEFAULT "",
    us_name    C(40)   DEFAULT "",
    us_pass    C(10)   DEFAULT "",
    us_phone   C(20)   DEFAULT "",
    us_websrv  L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    us_cashier,
    us_dep,
    us_email,
    us_fax,
    us_group,
    us_id,
    us_inactiv,
    us_lang,
    us_name,
    us_pass,
    us_phone,
    us_websrv
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    us_cashier user.us_cashier,
    us_dep     user.us_dep,
    us_email   user.us_email,
    us_fax     user.us_fax,
    us_group   user.us_group,
    us_id      user.us_id,
    us_inactiv user.us_inactiv,
    us_lang    user.us_lang,
    us_name    user.us_name,
    us_pass    user.us_pass,
    us_phone   user.us_phone,
    us_websrv  user.us_websrv
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS causerfav AS caBase OF cit_ca.vcx
Alias = [causerfav]
Tables = [userfav]
KeyFieldList = [uf_userid,uf_menu,uf_menukey]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       uf_menu,
       uf_menukey,
       uf_userid
    FROM userfav
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    uf_menu    C(20)   DEFAULT "",
    uf_menukey C(20)   DEFAULT "",
    uf_userid  C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    uf_menu,
    uf_menukey,
    uf_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    uf_menu    userfav.uf_menu,
    uf_menukey userfav.uf_menukey,
    uf_userid  userfav.uf_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS causermsg AS caBase OF cit_ca.vcx
Alias = [causermsg]
Tables = [usermsg]
KeyFieldList = [um_umid,um_userid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       um_height,
       um_left,
       um_text,
       um_top,
       um_umid,
       um_userid,
       um_width
    FROM usermsg
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    um_height  N(4,0)  DEFAULT 0,
    um_left    N(4,0)  DEFAULT 0,
    um_text    M       DEFAULT "",
    um_top     N(4,0)  DEFAULT 0,
    um_umid    I       DEFAULT 0,
    um_userid  C(10)   DEFAULT "",
    um_width   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    um_height,
    um_left,
    um_text,
    um_top,
    um_umid,
    um_userid,
    um_width
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    um_height  usermsg.um_height,
    um_left    usermsg.um_left,
    um_text    usermsg.um_text,
    um_top     usermsg.um_top,
    um_umid    usermsg.um_umid,
    um_userid  usermsg.um_userid,
    um_width   usermsg.um_width
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cavoucher AS caBase OF cit_ca.vcx
Alias = [cavoucher]
Tables = [voucher]
KeyFieldList = [vo_number]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       vo_addrid,
       vo_amount,
       vo_artinum,
       vo_copy,
       vo_copyp,
       vo_created,
       vo_date,
       vo_descrip,
       vo_expdate,
       vo_note,
       vo_number,
       vo_postid,
       vo_station,
       vo_time,
       vo_unused,
       vo_userid,
       vo_vat,
       vo_vatdesc,
       vo_vatval,
       vo_veid
    FROM voucher
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    vo_addrid  N(8,0)  DEFAULT 0,
    vo_amount  B(2)    DEFAULT 0,
    vo_artinum N(4,0)  DEFAULT 0,
    vo_copy    N(2,0)  DEFAULT 0,
    vo_copyp   N(2,0)  DEFAULT 0,
    vo_created D       DEFAULT {},
    vo_date    D       DEFAULT {},
    vo_descrip C(30)   DEFAULT "",
    vo_expdate D       DEFAULT {},
    vo_note    M       DEFAULT "",
    vo_number  N(10,0) DEFAULT 0,
    vo_postid  N(8,0)  DEFAULT 0,
    vo_station C(12)   DEFAULT "",
    vo_time    C(8)    DEFAULT "",
    vo_unused  B(2)    DEFAULT 0,
    vo_userid  C(10)   DEFAULT "",
    vo_vat     N(1,0)  DEFAULT 0,
    vo_vatdesc C(25)   DEFAULT "",
    vo_vatval  N(5,2)  DEFAULT 0,
    vo_veid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    vo_addrid,
    vo_amount,
    vo_artinum,
    vo_copy,
    vo_copyp,
    vo_created,
    vo_date,
    vo_descrip,
    vo_expdate,
    vo_note,
    vo_number,
    vo_postid,
    vo_station,
    vo_time,
    vo_unused,
    vo_userid,
    vo_vat,
    vo_vatdesc,
    vo_vatval,
    vo_veid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    vo_addrid  voucher.vo_addrid,
    vo_amount  voucher.vo_amount,
    vo_artinum voucher.vo_artinum,
    vo_copy    voucher.vo_copy,
    vo_copyp   voucher.vo_copyp,
    vo_created voucher.vo_created,
    vo_date    voucher.vo_date,
    vo_descrip voucher.vo_descrip,
    vo_expdate voucher.vo_expdate,
    vo_note    voucher.vo_note,
    vo_number  voucher.vo_number,
    vo_postid  voucher.vo_postid,
    vo_station voucher.vo_station,
    vo_time    voucher.vo_time,
    vo_unused  voucher.vo_unused,
    vo_userid  voucher.vo_userid,
    vo_vat     voucher.vo_vat,
    vo_vatdesc voucher.vo_vatdesc,
    vo_vatval  voucher.vo_vatval,
    vo_veid    voucher.vo_veid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caworkbrk AS caBase OF cit_ca.vcx
Alias = [caworkbrk]
Tables = [workbrk]
KeyFieldList = [wb_wbid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       wb_begin,
       wb_end,
       wb_wbid,
       wb_whid
    FROM workbrk
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    wb_begin   T       DEFAULT {},
    wb_end     T       DEFAULT {},
    wb_wbid    N(8,0)  DEFAULT 0,
    wb_whid    N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wb_begin,
    wb_end,
    wb_wbid,
    wb_whid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wb_begin   workbrk.wb_begin,
    wb_end     workbrk.wb_end,
    wb_wbid    workbrk.wb_wbid,
    wb_whid    workbrk.wb_whid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caworkbrkd AS caBase OF cit_ca.vcx
Alias = [caworkbrkd]
Tables = [workbrkd]
KeyFieldList = [wd_wdid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       wd_cwhour0,
       wd_cwhour1,
       wd_cwhour2,
       wd_cwhour3,
       wd_date,
       wd_min,
       wd_wbmin1,
       wd_wbmin2,
       wd_wbmin3,
       wd_wdid
    FROM workbrkd
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    wd_cwhour0 N(2,0)  DEFAULT 0,
    wd_cwhour1 N(2,0)  DEFAULT 0,
    wd_cwhour2 N(2,0)  DEFAULT 0,
    wd_cwhour3 N(2,0)  DEFAULT 0,
    wd_date    D       DEFAULT {},
    wd_min     N(3,0)  DEFAULT 0,
    wd_wbmin1  N(3,0)  DEFAULT 0,
    wd_wbmin2  N(3,0)  DEFAULT 0,
    wd_wbmin3  N(3,0)  DEFAULT 0,
    wd_wdid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wd_cwhour0,
    wd_cwhour1,
    wd_cwhour2,
    wd_cwhour3,
    wd_date,
    wd_min,
    wd_wbmin1,
    wd_wbmin2,
    wd_wbmin3,
    wd_wdid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wd_cwhour0 workbrkd.wd_cwhour0,
    wd_cwhour1 workbrkd.wd_cwhour1,
    wd_cwhour2 workbrkd.wd_cwhour2,
    wd_cwhour3 workbrkd.wd_cwhour3,
    wd_date    workbrkd.wd_date,
    wd_min     workbrkd.wd_min,
    wd_wbmin1  workbrkd.wd_wbmin1,
    wd_wbmin2  workbrkd.wd_wbmin2,
    wd_wbmin3  workbrkd.wd_wbmin3,
    wd_wdid    workbrkd.wd_wdid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caworkint AS caBase OF cit_ca.vcx
Alias = [caworkint]
Tables = [workint]
KeyFieldList = [wi_whid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       wi_begin,
       wi_emid,
       wi_end,
       wi_sysdate,
       wi_whid
    FROM workint
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    wi_begin   T       DEFAULT {},
    wi_emid    N(8,0)  DEFAULT 0,
    wi_end     T       DEFAULT {},
    wi_sysdate D       DEFAULT {},
    wi_whid    N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wi_begin,
    wi_emid,
    wi_end,
    wi_sysdate,
    wi_whid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wi_begin   workint.wi_begin,
    wi_emid    workint.wi_emid,
    wi_end     workint.wi_end,
    wi_sysdate workint.wi_sysdate,
    wi_whid    workint.wi_whid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cayicond AS caBase OF cit_ca.vcx
Alias = [cayicond]
Tables = [yicond]
KeyFieldList = [yc_ycid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       yc_avail,
       yc_avlhot,
       yc_avltype,
       yc_days,
       yc_daytype,
       yc_prcpct,
       yc_prcset,
       yc_prcunit,
       yc_round,
       yc_ycid,
       yc_yoid,
       yc_yrid
    FROM yicond
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    yc_avail   N(5,1)  DEFAULT 0,
    yc_avlhot  L       DEFAULT .F.,
    yc_avltype N(1,0)  DEFAULT 0,
    yc_days    N(3,0)  DEFAULT 0,
    yc_daytype N(1,0)  DEFAULT 0,
    yc_prcpct  N(6,2)  DEFAULT 0,
    yc_prcset  N(1,0)  DEFAULT 0,
    yc_prcunit N(1,0)  DEFAULT 0,
    yc_round   N(1,0)  DEFAULT 0,
    yc_ycid    I       DEFAULT 0,
    yc_yoid    I       DEFAULT 0,
    yc_yrid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yc_avail,
    yc_avlhot,
    yc_avltype,
    yc_days,
    yc_daytype,
    yc_prcpct,
    yc_prcset,
    yc_prcunit,
    yc_round,
    yc_ycid,
    yc_yoid,
    yc_yrid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yc_avail   yicond.yc_avail,
    yc_avlhot  yicond.yc_avlhot,
    yc_avltype yicond.yc_avltype,
    yc_days    yicond.yc_days,
    yc_daytype yicond.yc_daytype,
    yc_prcpct  yicond.yc_prcpct,
    yc_prcset  yicond.yc_prcset,
    yc_prcunit yicond.yc_prcunit,
    yc_round   yicond.yc_round,
    yc_ycid    yicond.yc_ycid,
    yc_yoid    yicond.yc_yoid,
    yc_yrid    yicond.yc_yrid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cayieldmng AS caBase OF cit_ca.vcx
Alias = [cayieldmng]
Tables = [yieldmng]
KeyFieldList = [ym_ymid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ym_active,
       ym_avail,
       ym_avlhot,
       ym_avltype,
       ym_blocked,
       ym_days,
       ym_daytype,
       ym_lang1,
       ym_lang10,
       ym_lang11,
       ym_lang2,
       ym_lang3,
       ym_lang4,
       ym_lang5,
       ym_lang6,
       ym_lang7,
       ym_lang8,
       ym_lang9,
       ym_note,
       ym_prcpct,
       ym_prcpct2,
       ym_prcpct3,
       ym_prcunit,
       ym_round,
       ym_ymid,
       ym_ymnr
    FROM yieldmng
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ym_active  L       DEFAULT .F.,
    ym_avail   N(5,1)  DEFAULT 0,
    ym_avlhot  L       DEFAULT .F.,
    ym_avltype N(1,0)  DEFAULT 0,
    ym_blocked L       DEFAULT .F.,
    ym_days    N(3,0)  DEFAULT 0,
    ym_daytype N(1,0)  DEFAULT 0,
    ym_lang1   C(100)  DEFAULT "",
    ym_lang10  C(100)  DEFAULT "",
    ym_lang11  C(100)  DEFAULT "",
    ym_lang2   C(100)  DEFAULT "",
    ym_lang3   C(100)  DEFAULT "",
    ym_lang4   C(100)  DEFAULT "",
    ym_lang5   C(100)  DEFAULT "",
    ym_lang6   C(100)  DEFAULT "",
    ym_lang7   C(100)  DEFAULT "",
    ym_lang8   C(100)  DEFAULT "",
    ym_lang9   C(100)  DEFAULT "",
    ym_note    M       DEFAULT "",
    ym_prcpct  N(6,2)  DEFAULT 0,
    ym_prcpct2 N(6,2)  DEFAULT 0,
    ym_prcpct3 N(6,2)  DEFAULT 0,
    ym_prcunit N(1,0)  DEFAULT 0,
    ym_round   N(1,0)  DEFAULT 0,
    ym_ymid    I       DEFAULT 0,
    ym_ymnr    N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ym_active,
    ym_avail,
    ym_avlhot,
    ym_avltype,
    ym_blocked,
    ym_days,
    ym_daytype,
    ym_lang1,
    ym_lang10,
    ym_lang11,
    ym_lang2,
    ym_lang3,
    ym_lang4,
    ym_lang5,
    ym_lang6,
    ym_lang7,
    ym_lang8,
    ym_lang9,
    ym_note,
    ym_prcpct,
    ym_prcpct2,
    ym_prcpct3,
    ym_prcunit,
    ym_round,
    ym_ymid,
    ym_ymnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ym_active  yieldmng.ym_active,
    ym_avail   yieldmng.ym_avail,
    ym_avlhot  yieldmng.ym_avlhot,
    ym_avltype yieldmng.ym_avltype,
    ym_blocked yieldmng.ym_blocked,
    ym_days    yieldmng.ym_days,
    ym_daytype yieldmng.ym_daytype,
    ym_lang1   yieldmng.ym_lang1,
    ym_lang10  yieldmng.ym_lang10,
    ym_lang11  yieldmng.ym_lang11,
    ym_lang2   yieldmng.ym_lang2,
    ym_lang3   yieldmng.ym_lang3,
    ym_lang4   yieldmng.ym_lang4,
    ym_lang5   yieldmng.ym_lang5,
    ym_lang6   yieldmng.ym_lang6,
    ym_lang7   yieldmng.ym_lang7,
    ym_lang8   yieldmng.ym_lang8,
    ym_lang9   yieldmng.ym_lang9,
    ym_note    yieldmng.ym_note,
    ym_prcpct  yieldmng.ym_prcpct,
    ym_prcpct2 yieldmng.ym_prcpct2,
    ym_prcpct3 yieldmng.ym_prcpct3,
    ym_prcunit yieldmng.ym_prcunit,
    ym_round   yieldmng.ym_round,
    ym_ymid    yieldmng.ym_ymid,
    ym_ymnr    yieldmng.ym_ymnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cayioffer AS caBase OF cit_ca.vcx
Alias = [cayioffer]
Tables = [yioffer]
KeyFieldList = [yo_yoid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       yo_adults,
       yo_childs,
       yo_childs2,
       yo_childs3,
       yo_created,
       yo_from,
       yo_rooms,
       yo_roomtyp,
       yo_rsid,
       yo_sysdate,
       yo_to,
       yo_userid,
       yo_yoid
    FROM yioffer
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    yo_adults  N(3,0)  DEFAULT 0,
    yo_childs  N(3,0)  DEFAULT 0,
    yo_childs2 N(1,0)  DEFAULT 0,
    yo_childs3 N(1,0)  DEFAULT 0,
    yo_created T       DEFAULT {},
    yo_from    D       DEFAULT {},
    yo_rooms   N(3,0)  DEFAULT 0,
    yo_roomtyp C(4)    DEFAULT "",
    yo_rsid    I       DEFAULT 0,
    yo_sysdate D       DEFAULT {},
    yo_to      D       DEFAULT {},
    yo_userid  C(10)   DEFAULT "",
    yo_yoid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yo_adults,
    yo_childs,
    yo_childs2,
    yo_childs3,
    yo_created,
    yo_from,
    yo_rooms,
    yo_roomtyp,
    yo_rsid,
    yo_sysdate,
    yo_to,
    yo_userid,
    yo_yoid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yo_adults  yioffer.yo_adults,
    yo_childs  yioffer.yo_childs,
    yo_childs2 yioffer.yo_childs2,
    yo_childs3 yioffer.yo_childs3,
    yo_created yioffer.yo_created,
    yo_from    yioffer.yo_from,
    yo_rooms   yioffer.yo_rooms,
    yo_roomtyp yioffer.yo_roomtyp,
    yo_rsid    yioffer.yo_rsid,
    yo_sysdate yioffer.yo_sysdate,
    yo_to      yioffer.yo_to,
    yo_userid  yioffer.yo_userid,
    yo_yoid    yioffer.yo_yoid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caymngprop AS caBase OF cit_ca.vcx
Alias = [caymngprop]
Tables = [ymngprop]
KeyFieldList = [yp_ypid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       yp_date,
       yp_flags,
       yp_ymid,
       yp_ypid
    FROM ymngprop
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    yp_date    D       DEFAULT {},
    yp_flags   C(5)    DEFAULT "",
    yp_ymid    I       DEFAULT 0,
    yp_ypid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yp_date,
    yp_flags,
    yp_ymid,
    yp_ypid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    yp_date    ymngprop.yp_date,
    yp_flags   ymngprop.yp_flags,
    yp_ymid    ymngprop.yp_ymid,
    yp_ypid    ymngprop.yp_ypid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cazipcode AS caBase OF cit_ca.vcx
Alias = [cazipcode]
Tables = [zipcode]
KeyFieldList = [zc_zcid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       zc_city,
       zc_country,
       zc_prefix,
       zc_state,
       zc_zcid,
       zc_zip
    FROM zipcode
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    zc_city    C(30)   DEFAULT "",
    zc_country C(3)    DEFAULT "",
    zc_prefix  C(10)   DEFAULT "",
    zc_state   C(30)   DEFAULT "",
    zc_zcid    N(8,0)  DEFAULT 0,
    zc_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    zc_city,
    zc_country,
    zc_prefix,
    zc_state,
    zc_zcid,
    zc_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    zc_city    zipcode.zc_city,
    zc_country zipcode.zc_country,
    zc_prefix  zipcode.zc_prefix,
    zc_state   zipcode.zc_state,
    zc_zcid    zipcode.zc_zcid,
    zc_zip     zipcode.zc_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
