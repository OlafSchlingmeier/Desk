DEFINE CLASS caaaddress AS caBase OF common\libs\cit_ca.vcx
Alias = [caaaddress]
Tables = [aaddress]
KeyFieldList = [ad_addrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ad_addrid,
       ad_attn,
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
       ad_lang,
       ad_lname,
       ad_member,
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
       ad_updated,
       ad_usr1,
       ad_website,
       ad_zip
    FROM aaddress
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_addrid  N(8,0)  DEFAULT 0,
    ad_attn    C(10)   DEFAULT "",
    ad_birth   D       DEFAULT {},
    ad_city    C(30)   DEFAULT "",
    ad_company C(50)   DEFAULT "",
    ad_compkey C(15)   DEFAULT "",
    ad_compnum N(10,0) DEFAULT 0,
    ad_country C(3)    DEFAULT "",
    ad_created D       DEFAULT {},
    ad_departm C(50)   DEFAULT "",
    ad_email   C(100)  DEFAULT "",
    ad_fax     C(20)   DEFAULT "",
    ad_fname   C(20)   DEFAULT "",
    ad_lang    C(3)    DEFAULT "",
    ad_lname   C(30)   DEFAULT "",
    ad_member  N(9,0)  DEFAULT 0,
    ad_note    M       DEFAULT "",
    ad_phone   C(20)   DEFAULT "",
    ad_phone2  C(20)   DEFAULT "",
    ad_phone3  C(20)   DEFAULT "",
    ad_salute  C(50)   DEFAULT "",
    ad_state   C(30)   DEFAULT "",
    ad_street  C(30)   DEFAULT "",
    ad_street2 C(30)   DEFAULT "",
    ad_titlcod N(2,0)  DEFAULT 0,
    ad_title   C(20)   DEFAULT "",
    ad_updated D       DEFAULT {},
    ad_usr1    C(40)   DEFAULT "",
    ad_website C(60)   DEFAULT "",
    ad_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_addrid,
    ad_attn,
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
    ad_lang,
    ad_lname,
    ad_member,
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
    ad_updated,
    ad_usr1,
    ad_website,
    ad_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ad_addrid  aaddress.ad_addrid,
    ad_attn    aaddress.ad_attn,
    ad_birth   aaddress.ad_birth,
    ad_city    aaddress.ad_city,
    ad_company aaddress.ad_company,
    ad_compkey aaddress.ad_compkey,
    ad_compnum aaddress.ad_compnum,
    ad_country aaddress.ad_country,
    ad_created aaddress.ad_created,
    ad_departm aaddress.ad_departm,
    ad_email   aaddress.ad_email,
    ad_fax     aaddress.ad_fax,
    ad_fname   aaddress.ad_fname,
    ad_lang    aaddress.ad_lang,
    ad_lname   aaddress.ad_lname,
    ad_member  aaddress.ad_member,
    ad_note    aaddress.ad_note,
    ad_phone   aaddress.ad_phone,
    ad_phone2  aaddress.ad_phone2,
    ad_phone3  aaddress.ad_phone3,
    ad_salute  aaddress.ad_salute,
    ad_state   aaddress.ad_state,
    ad_street  aaddress.ad_street,
    ad_street2 aaddress.ad_street2,
    ad_titlcod aaddress.ad_titlcod,
    ad_title   aaddress.ad_title,
    ad_updated aaddress.ad_updated,
    ad_usr1    aaddress.ad_usr1,
    ad_website aaddress.ad_website,
    ad_zip     aaddress.ad_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caaddrgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [caaddrgrp]
Tables = [addrgrp]
KeyFieldList = [ag_addrid,ag_aaddrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ag_aaddrid,
       ag_addrid,
       ag_gsgrpid
    FROM addrgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_aaddrid N(8,0)  DEFAULT 0,
    ag_addrid  N(8,0)  DEFAULT 0,
    ag_gsgrpid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_aaddrid,
    ag_addrid,
    ag_gsgrpid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_aaddrid addrgrp.ag_aaddrid,
    ag_addrid  addrgrp.ag_addrid,
    ag_gsgrpid addrgrp.ag_gsgrpid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrcomptyp AS caBase OF common\libs\cit_ca.vcx
Alias = [caadrcomptyp]
Tables = [adrcomptyp]
KeyFieldList = [ap_typeid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ap_cptype,
       ap_deleted,
       ap_typeid
    FROM adrcomptyp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_cptype  C(25)   DEFAULT "",
    ap_deleted L       DEFAULT .F.,
    ap_typeid  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_cptype,
    ap_deleted,
    ap_typeid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ap_cptype  adrcomptyp.ap_cptype,
    ap_deleted adrcomptyp.ap_deleted,
    ap_typeid  adrcomptyp.ap_typeid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caadrdetail AS caBase OF common\libs\cit_ca.vcx
Alias = [caadrdetail]
Tables = [adrdetail]
KeyFieldList = [ax_addrid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ax_addrid,
       ax_appetiz,
       ax_appoint,
       ax_beverag,
       ax_birth,
       ax_charact,
       ax_compan1,
       ax_compan2,
       ax_compan3,
       ax_compan4,
       ax_cp1birt,
       ax_cp1type,
       ax_cp2birt,
       ax_cp2type,
       ax_cp3birt,
       ax_cp3type,
       ax_cp4birt,
       ax_cp4type,
       ax_dish,
       ax_starter,
       ax_table,
       ax_weddday,
       ax_wine,
       ax_wishes
    FROM adrdetail
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ax_addrid  N(8,0)  DEFAULT 0,
    ax_appetiz M       DEFAULT "",
    ax_appoint M       DEFAULT "",
    ax_beverag M       DEFAULT "",
    ax_birth   D       DEFAULT {},
    ax_charact M       DEFAULT "",
    ax_compan1 C(40)   DEFAULT "",
    ax_compan2 C(40)   DEFAULT "",
    ax_compan3 C(40)   DEFAULT "",
    ax_compan4 C(40)   DEFAULT "",
    ax_cp1birt D       DEFAULT {},
    ax_cp1type N(2,0)  DEFAULT 0,
    ax_cp2birt D       DEFAULT {},
    ax_cp2type N(2,0)  DEFAULT 0,
    ax_cp3birt D       DEFAULT {},
    ax_cp3type N(2,0)  DEFAULT 0,
    ax_cp4birt D       DEFAULT {},
    ax_cp4type N(2,0)  DEFAULT 0,
    ax_dish    M       DEFAULT "",
    ax_starter M       DEFAULT "",
    ax_table   C(25)   DEFAULT "",
    ax_weddday D       DEFAULT {},
    ax_wine    M       DEFAULT "",
    ax_wishes  M       DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ax_addrid,
    ax_appetiz,
    ax_appoint,
    ax_beverag,
    ax_birth,
    ax_charact,
    ax_compan1,
    ax_compan2,
    ax_compan3,
    ax_compan4,
    ax_cp1birt,
    ax_cp1type,
    ax_cp2birt,
    ax_cp2type,
    ax_cp3birt,
    ax_cp3type,
    ax_cp4birt,
    ax_cp4type,
    ax_dish,
    ax_starter,
    ax_table,
    ax_weddday,
    ax_wine,
    ax_wishes
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ax_addrid  adrdetail.ax_addrid,
    ax_appetiz adrdetail.ax_appetiz,
    ax_appoint adrdetail.ax_appoint,
    ax_beverag adrdetail.ax_beverag,
    ax_birth   adrdetail.ax_birth,
    ax_charact adrdetail.ax_charact,
    ax_compan1 adrdetail.ax_compan1,
    ax_compan2 adrdetail.ax_compan2,
    ax_compan3 adrdetail.ax_compan3,
    ax_compan4 adrdetail.ax_compan4,
    ax_cp1birt adrdetail.ax_cp1birt,
    ax_cp1type adrdetail.ax_cp1type,
    ax_cp2birt adrdetail.ax_cp2birt,
    ax_cp2type adrdetail.ax_cp2type,
    ax_cp3birt adrdetail.ax_cp3birt,
    ax_cp3type adrdetail.ax_cp3type,
    ax_cp4birt adrdetail.ax_cp4birt,
    ax_cp4type adrdetail.ax_cp4type,
    ax_dish    adrdetail.ax_dish,
    ax_starter adrdetail.ax_starter,
    ax_table   adrdetail.ax_table,
    ax_weddday adrdetail.ax_weddday,
    ax_wine    adrdetail.ax_wine,
    ax_wishes  adrdetail.ax_wishes
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarchive AS caBase OF common\libs\cit_ca.vcx
Alias = [caarchive]
Tables = [archive]
KeyFieldList = [av_fileset]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       av_begin,
       av_end,
       av_fileset
    FROM archive
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    av_begin   D       DEFAULT {},
    av_end     D       DEFAULT {},
    av_fileset C(6)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    av_begin,
    av_end,
    av_fileset
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    av_begin   archive.av_begin,
    av_end     archive.av_end,
    av_fileset archive.av_fileset
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caartcomp AS caBase OF common\libs\cit_ca.vcx
Alias = [caartcomp]
Tables = [artcomp]
KeyFieldList = [ac_arcmpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ac_amtlev1,
       ac_amtlev2,
       ac_amtlev3,
       ac_amtlev4,
       ac_amtlev5,
       ac_amtlev6,
       ac_amtlev7,
       ac_amtlev8,
       ac_amtlev9,
       ac_arcmpid,
       ac_artid,
       ac_ptartid
    FROM artcomp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_amtlev1 Y       DEFAULT 0,
    ac_amtlev2 Y       DEFAULT 0,
    ac_amtlev3 Y       DEFAULT 0,
    ac_amtlev4 Y       DEFAULT 0,
    ac_amtlev5 Y       DEFAULT 0,
    ac_amtlev6 Y       DEFAULT 0,
    ac_amtlev7 Y       DEFAULT 0,
    ac_amtlev8 Y       DEFAULT 0,
    ac_amtlev9 Y       DEFAULT 0,
    ac_arcmpid I       DEFAULT 0,
    ac_artid   I       DEFAULT 0,
    ac_ptartid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_amtlev1,
    ac_amtlev2,
    ac_amtlev3,
    ac_amtlev4,
    ac_amtlev5,
    ac_amtlev6,
    ac_amtlev7,
    ac_amtlev8,
    ac_amtlev9,
    ac_arcmpid,
    ac_artid,
    ac_ptartid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_amtlev1 artcomp.ac_amtlev1,
    ac_amtlev2 artcomp.ac_amtlev2,
    ac_amtlev3 artcomp.ac_amtlev3,
    ac_amtlev4 artcomp.ac_amtlev4,
    ac_amtlev5 artcomp.ac_amtlev5,
    ac_amtlev6 artcomp.ac_amtlev6,
    ac_amtlev7 artcomp.ac_amtlev7,
    ac_amtlev8 artcomp.ac_amtlev8,
    ac_amtlev9 artcomp.ac_amtlev9,
    ac_arcmpid artcomp.ac_arcmpid,
    ac_artid   artcomp.ac_artid,
    ac_ptartid artcomp.ac_ptartid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caartfo AS caBase OF common\libs\cit_ca.vcx
Alias = [caartfo]
Tables = [artfo]
KeyFieldList = [af_artfoid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       af_artfoid,
       af_artid,
       af_deptnr,
       af_foart
    FROM artfo
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_artfoid I       DEFAULT 0,
    af_artid   I       DEFAULT 0,
    af_deptnr  N(2,0)  DEFAULT 0,
    af_foart   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_artfoid,
    af_artid,
    af_deptnr,
    af_foart
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_artfoid artfo.af_artfoid,
    af_artid   artfo.af_artid,
    af_deptnr  artfo.af_deptnr,
    af_foart   artfo.af_foart
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarticle AS caBase OF common\libs\cit_ca.vcx
Alias = [caarticle]
Tables = [article]
KeyFieldList = [ar_artid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ar_active,
       ar_adescr,
       ar_artid,
       ar_arttyp,
       ar_bscramt,
       ar_bscruse,
       ar_bsdays,
       ar_bsdbamt,
       ar_bsdbuse,
       ar_compdet,
       ar_decqty,
       ar_deleted,
       ar_devart,
       ar_devtype,
       ar_discnt,
       ar_ean,
       ar_eanplu,
       ar_fatindr,
       ar_foart,
       ar_ldescr,
       ar_mainnr,
       ar_manufac,
       ar_modgid1,
       ar_modgid2,
       ar_modgid3,
       ar_modgid4,
       ar_modgid5,
       ar_modgid6,
       ar_netqty,
       ar_plu,
       ar_plvatnr,
       ar_plvtnr2,
       ar_prclev1,
       ar_prclev2,
       ar_prclev3,
       ar_prclev4,
       ar_prclev5,
       ar_prclev6,
       ar_prclev7,
       ar_prclev8,
       ar_prclev9,
       ar_prcopen,
       ar_prcpur,
       ar_prtord1,
       ar_prtord2,
       ar_prtord3,
       ar_prtord4,
       ar_prtord5,
       ar_prtord6,
       ar_prtord7,
       ar_qdescr,
       ar_qtymes,
       ar_red,
       ar_sdescr,
       ar_slip,
       ar_sortnr,
       ar_subnr,
       ar_supplem,
       ar_ticket,
       ar_unit,
       ar_vatnr,
       ar_weighqt,
       ar_weitara
    FROM article
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_active  L       DEFAULT .F.,
    ar_adescr  C(40)   DEFAULT "",
    ar_artid   I       DEFAULT 0,
    ar_arttyp  N(1,0)  DEFAULT 0,
    ar_bscramt N(12,3) DEFAULT 0,
    ar_bscruse L       DEFAULT .F.,
    ar_bsdays  N(4,0)  DEFAULT 0,
    ar_bsdbamt N(12,3) DEFAULT 0,
    ar_bsdbuse L       DEFAULT .F.,
    ar_compdet L       DEFAULT .F.,
    ar_decqty  L       DEFAULT .F.,
    ar_deleted L       DEFAULT .F.,
    ar_devart  N(4,0)  DEFAULT 0,
    ar_devtype N(1,0)  DEFAULT 0,
    ar_discnt  L       DEFAULT .F.,
    ar_ean     C(13)   DEFAULT "",
    ar_eanplu  N(5,0)  DEFAULT 0,
    ar_fatindr C(40)   DEFAULT "",
    ar_foart   N(4,0)  DEFAULT 0,
    ar_ldescr  C(40)   DEFAULT "",
    ar_mainnr  N(2,0)  DEFAULT 0,
    ar_manufac C(40)   DEFAULT "",
    ar_modgid1 I       DEFAULT 0,
    ar_modgid2 I       DEFAULT 0,
    ar_modgid3 I       DEFAULT 0,
    ar_modgid4 I       DEFAULT 0,
    ar_modgid5 I       DEFAULT 0,
    ar_modgid6 I       DEFAULT 0,
    ar_netqty  N(7,3)  DEFAULT 0,
    ar_plu     N(8,0)  DEFAULT 0,
    ar_plvatnr N(1,0)  DEFAULT 0,
    ar_plvtnr2 N(1,0)  DEFAULT 0,
    ar_prclev1 Y       DEFAULT 0,
    ar_prclev2 Y       DEFAULT 0,
    ar_prclev3 Y       DEFAULT 0,
    ar_prclev4 Y       DEFAULT 0,
    ar_prclev5 Y       DEFAULT 0,
    ar_prclev6 Y       DEFAULT 0,
    ar_prclev7 Y       DEFAULT 0,
    ar_prclev8 Y       DEFAULT 0,
    ar_prclev9 Y       DEFAULT 0,
    ar_prcopen L       DEFAULT .F.,
    ar_prcpur  Y       DEFAULT 0,
    ar_prtord1 L       DEFAULT .F.,
    ar_prtord2 L       DEFAULT .F.,
    ar_prtord3 L       DEFAULT .F.,
    ar_prtord4 L       DEFAULT .F.,
    ar_prtord5 L       DEFAULT .F.,
    ar_prtord6 L       DEFAULT .F.,
    ar_prtord7 L       DEFAULT .F.,
    ar_qdescr  C(40)   DEFAULT "",
    ar_qtymes  C(3)    DEFAULT "",
    ar_red     L       DEFAULT .F.,
    ar_sdescr  C(20)   DEFAULT "",
    ar_slip    L       DEFAULT .F.,
    ar_sortnr  N(2,0)  DEFAULT 0,
    ar_subnr   N(4,0)  DEFAULT 0,
    ar_supplem L       DEFAULT .F.,
    ar_ticket  L       DEFAULT .F.,
    ar_unit    C(2)    DEFAULT "",
    ar_vatnr   N(1,0)  DEFAULT 0,
    ar_weighqt L       DEFAULT .F.,
    ar_weitara N(5,3)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_active,
    ar_adescr,
    ar_artid,
    ar_arttyp,
    ar_bscramt,
    ar_bscruse,
    ar_bsdays,
    ar_bsdbamt,
    ar_bsdbuse,
    ar_compdet,
    ar_decqty,
    ar_deleted,
    ar_devart,
    ar_devtype,
    ar_discnt,
    ar_ean,
    ar_eanplu,
    ar_fatindr,
    ar_foart,
    ar_ldescr,
    ar_mainnr,
    ar_manufac,
    ar_modgid1,
    ar_modgid2,
    ar_modgid3,
    ar_modgid4,
    ar_modgid5,
    ar_modgid6,
    ar_netqty,
    ar_plu,
    ar_plvatnr,
    ar_plvtnr2,
    ar_prclev1,
    ar_prclev2,
    ar_prclev3,
    ar_prclev4,
    ar_prclev5,
    ar_prclev6,
    ar_prclev7,
    ar_prclev8,
    ar_prclev9,
    ar_prcopen,
    ar_prcpur,
    ar_prtord1,
    ar_prtord2,
    ar_prtord3,
    ar_prtord4,
    ar_prtord5,
    ar_prtord6,
    ar_prtord7,
    ar_qdescr,
    ar_qtymes,
    ar_red,
    ar_sdescr,
    ar_slip,
    ar_sortnr,
    ar_subnr,
    ar_supplem,
    ar_ticket,
    ar_unit,
    ar_vatnr,
    ar_weighqt,
    ar_weitara
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_active  article.ar_active,
    ar_adescr  article.ar_adescr,
    ar_artid   article.ar_artid,
    ar_arttyp  article.ar_arttyp,
    ar_bscramt article.ar_bscramt,
    ar_bscruse article.ar_bscruse,
    ar_bsdays  article.ar_bsdays,
    ar_bsdbamt article.ar_bsdbamt,
    ar_bsdbuse article.ar_bsdbuse,
    ar_compdet article.ar_compdet,
    ar_decqty  article.ar_decqty,
    ar_deleted article.ar_deleted,
    ar_devart  article.ar_devart,
    ar_devtype article.ar_devtype,
    ar_discnt  article.ar_discnt,
    ar_ean     article.ar_ean,
    ar_eanplu  article.ar_eanplu,
    ar_fatindr article.ar_fatindr,
    ar_foart   article.ar_foart,
    ar_ldescr  article.ar_ldescr,
    ar_mainnr  article.ar_mainnr,
    ar_manufac article.ar_manufac,
    ar_modgid1 article.ar_modgid1,
    ar_modgid2 article.ar_modgid2,
    ar_modgid3 article.ar_modgid3,
    ar_modgid4 article.ar_modgid4,
    ar_modgid5 article.ar_modgid5,
    ar_modgid6 article.ar_modgid6,
    ar_netqty  article.ar_netqty,
    ar_plu     article.ar_plu,
    ar_plvatnr article.ar_plvatnr,
    ar_plvtnr2 article.ar_plvtnr2,
    ar_prclev1 article.ar_prclev1,
    ar_prclev2 article.ar_prclev2,
    ar_prclev3 article.ar_prclev3,
    ar_prclev4 article.ar_prclev4,
    ar_prclev5 article.ar_prclev5,
    ar_prclev6 article.ar_prclev6,
    ar_prclev7 article.ar_prclev7,
    ar_prclev8 article.ar_prclev8,
    ar_prclev9 article.ar_prclev9,
    ar_prcopen article.ar_prcopen,
    ar_prcpur  article.ar_prcpur,
    ar_prtord1 article.ar_prtord1,
    ar_prtord2 article.ar_prtord2,
    ar_prtord3 article.ar_prtord3,
    ar_prtord4 article.ar_prtord4,
    ar_prtord5 article.ar_prtord5,
    ar_prtord6 article.ar_prtord6,
    ar_prtord7 article.ar_prtord7,
    ar_qdescr  article.ar_qdescr,
    ar_qtymes  article.ar_qtymes,
    ar_red     article.ar_red,
    ar_sdescr  article.ar_sdescr,
    ar_slip    article.ar_slip,
    ar_sortnr  article.ar_sortnr,
    ar_subnr   article.ar_subnr,
    ar_supplem article.ar_supplem,
    ar_ticket  article.ar_ticket,
    ar_unit    article.ar_unit,
    ar_vatnr   article.ar_vatnr,
    ar_weighqt article.ar_weighqt,
    ar_weitara article.ar_weitara
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caartigrp AS caBase OF common\libs\cit_ca.vcx
Alias = [caartigrp]
Tables = [artigrp]
KeyFieldList = [ag_agid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ag_agid,
       ag_name
    FROM artigrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_agid    I       DEFAULT 0,
    ag_name    C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_agid,
    ag_name
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ag_agid    artigrp.ag_agid,
    ag_name    artigrp.ag_name
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caartinvt AS caBase OF common\libs\cit_ca.vcx
Alias = [caartinvt]
Tables = [artinvt]
KeyFieldList = [ai_ainvtid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ai_ainvtid,
       ai_artid,
       ai_invtamt,
       ai_invtid,
       ai_main,
       ai_sellqty,
       ai_unit
    FROM artinvt
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_ainvtid I       DEFAULT 0,
    ai_artid   I       DEFAULT 0,
    ai_invtamt Y       DEFAULT 0,
    ai_invtid  I       DEFAULT 0,
    ai_main    L       DEFAULT .F.,
    ai_sellqty B(3)    DEFAULT 0,
    ai_unit    C(2)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_ainvtid,
    ai_artid,
    ai_invtamt,
    ai_invtid,
    ai_main,
    ai_sellqty,
    ai_unit
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_ainvtid artinvt.ai_ainvtid,
    ai_artid   artinvt.ai_artid,
    ai_invtamt artinvt.ai_invtamt,
    ai_invtid  artinvt.ai_invtid,
    ai_main    artinvt.ai_main,
    ai_sellqty artinvt.ai_sellqty,
    ai_unit    artinvt.ai_unit
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caarttyp AS caBase OF common\libs\cit_ca.vcx
Alias = [caarttyp]
Tables = [arttyp]
KeyFieldList = [at_arttyp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       at_arttyp,
       at_de,
       at_descr,
       at_en,
       at_nl,
       at_rs
    FROM arttyp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    at_arttyp  N(1,0)  DEFAULT 0,
    at_de      C(20)   DEFAULT "",
    at_descr   C(20)   DEFAULT "",
    at_en      C(20)   DEFAULT "",
    at_nl      C(20)   DEFAULT "",
    at_rs      C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    at_arttyp,
    at_de,
    at_descr,
    at_en,
    at_nl,
    at_rs
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    at_arttyp  arttyp.at_arttyp,
    at_de      arttyp.at_de,
    at_descr   arttyp.at_descr,
    at_en      arttyp.at_en,
    at_nl      arttyp.at_nl,
    at_rs      arttyp.at_rs
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caasgempl AS caBase OF common\libs\cit_ca.vcx
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
    ae_aeid    I       DEFAULT 0,
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
DEFINE CLASS caazepick AS caBase OF common\libs\cit_ca.vcx
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
DEFINE CLASS cabanken AS caBase OF common\libs\cit_ca.vcx
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
    ba_baid    I       DEFAULT 0,
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
DEFINE CLASS cabccard AS caBase OF common\libs\cit_ca.vcx
Alias = [cabccard]
Tables = [bccard]
KeyFieldList = [bc_bcid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bc_agid,
       bc_bcid,
       bc_caid,
       bc_deleted,
       bc_discnr,
       bc_ean,
       bc_type
    FROM bccard
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bc_agid    I       DEFAULT 0,
    bc_bcid    I       DEFAULT 0,
    bc_caid    I       DEFAULT 0,
    bc_deleted L       DEFAULT .F.,
    bc_discnr  N(2,0)  DEFAULT 0,
    bc_ean     C(13)   DEFAULT "",
    bc_type    N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bc_agid,
    bc_bcid,
    bc_caid,
    bc_deleted,
    bc_discnr,
    bc_ean,
    bc_type
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bc_agid    bccard.bc_agid,
    bc_bcid    bccard.bc_bcid,
    bc_caid    bccard.bc_caid,
    bc_deleted bccard.bc_deleted,
    bc_discnr  bccard.bc_discnr,
    bc_ean     bccard.bc_ean,
    bc_type    bccard.bc_type
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabcrdarti AS caBase OF common\libs\cit_ca.vcx
Alias = [cabcrdarti]
Tables = [bcrdarti]
KeyFieldList = [ba_baid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ba_agid,
       ba_artid,
       ba_baid,
       ba_qty
    FROM bcrdarti
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ba_agid    I       DEFAULT 0,
    ba_artid   I       DEFAULT 0,
    ba_baid    I       DEFAULT 0,
    ba_qty     N(8,3)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ba_agid,
    ba_artid,
    ba_baid,
    ba_qty
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ba_agid    bcrdarti.ba_agid,
    ba_artid   bcrdarti.ba_artid,
    ba_baid    bcrdarti.ba_baid,
    ba_qty     bcrdarti.ba_qty
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabcrdtran AS caBase OF common\libs\cit_ca.vcx
Alias = [cabcrdtran]
Tables = [bcrdtran]
KeyFieldList = [bt_btid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bt_aaddrid,
       bt_addrid,
       bt_artid,
       bt_bcid,
       bt_btid,
       bt_caid,
       bt_chkid,
       bt_compnum,
       bt_discnr,
       bt_discpct,
       bt_ldescr,
       bt_orderid,
       bt_plevnr,
       bt_posted,
       bt_qty,
       bt_sysdate
    FROM bcrdtran
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_aaddrid N(8,0)  DEFAULT 0,
    bt_addrid  N(8,0)  DEFAULT 0,
    bt_artid   I       DEFAULT 0,
    bt_bcid    I       DEFAULT 0,
    bt_btid    I       DEFAULT 0,
    bt_caid    I       DEFAULT 0,
    bt_chkid   I       DEFAULT 0,
    bt_compnum N(10,0) DEFAULT 0,
    bt_discnr  N(2,0)  DEFAULT 0,
    bt_discpct N(3,0)  DEFAULT 0,
    bt_ldescr  C(40)   DEFAULT "",
    bt_orderid I       DEFAULT 0,
    bt_plevnr  N(1,0)  DEFAULT 0,
    bt_posted  T       DEFAULT {},
    bt_qty     N(8,3)  DEFAULT 0,
    bt_sysdate D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_aaddrid,
    bt_addrid,
    bt_artid,
    bt_bcid,
    bt_btid,
    bt_caid,
    bt_chkid,
    bt_compnum,
    bt_discnr,
    bt_discpct,
    bt_ldescr,
    bt_orderid,
    bt_plevnr,
    bt_posted,
    bt_qty,
    bt_sysdate
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_aaddrid bcrdtran.bt_aaddrid,
    bt_addrid  bcrdtran.bt_addrid,
    bt_artid   bcrdtran.bt_artid,
    bt_bcid    bcrdtran.bt_bcid,
    bt_btid    bcrdtran.bt_btid,
    bt_caid    bcrdtran.bt_caid,
    bt_chkid   bcrdtran.bt_chkid,
    bt_compnum bcrdtran.bt_compnum,
    bt_discnr  bcrdtran.bt_discnr,
    bt_discpct bcrdtran.bt_discpct,
    bt_ldescr  bcrdtran.bt_ldescr,
    bt_orderid bcrdtran.bt_orderid,
    bt_plevnr  bcrdtran.bt_plevnr,
    bt_posted  bcrdtran.bt_posted,
    bt_qty     bcrdtran.bt_qty,
    bt_sysdate bcrdtran.bt_sysdate
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabillnum AS caBase OF common\libs\cit_ca.vcx
Alias = [cabillnum]
Tables = [billnum]
KeyFieldList = [bn_billnum]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bn_billnum,
       bn_cancel,
       bn_chkid,
       bn_created,
       bn_cxldate,
       bn_date,
       bn_deptnr,
       bn_fpid,
       bn_fpnr,
       bn_invoice,
       bn_note,
       bn_qrcode,
       bn_status,
       bn_waitnr
    FROM billnum
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bn_billnum I       DEFAULT 0,
    bn_cancel  T       DEFAULT {},
    bn_chkid   I       DEFAULT 0,
    bn_created T       DEFAULT {},
    bn_cxldate D       DEFAULT {},
    bn_date    D       DEFAULT {},
    bn_deptnr  N(2,0)  DEFAULT 0,
    bn_fpid    I       DEFAULT 0,
    bn_fpnr    N(2,0)  DEFAULT 0,
    bn_invoice I       DEFAULT 0,
    bn_note    C(100)  DEFAULT "",
    bn_qrcode  C(254)  DEFAULT "",
    bn_status  N(1,0)  DEFAULT 0,
    bn_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bn_billnum,
    bn_cancel,
    bn_chkid,
    bn_created,
    bn_cxldate,
    bn_date,
    bn_deptnr,
    bn_fpid,
    bn_fpnr,
    bn_invoice,
    bn_note,
    bn_qrcode,
    bn_status,
    bn_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bn_billnum billnum.bn_billnum,
    bn_cancel  billnum.bn_cancel,
    bn_chkid   billnum.bn_chkid,
    bn_created billnum.bn_created,
    bn_cxldate billnum.bn_cxldate,
    bn_date    billnum.bn_date,
    bn_deptnr  billnum.bn_deptnr,
    bn_fpid    billnum.bn_fpid,
    bn_fpnr    billnum.bn_fpnr,
    bn_invoice billnum.bn_invoice,
    bn_note    billnum.bn_note,
    bn_qrcode  billnum.bn_qrcode,
    bn_status  billnum.bn_status,
    bn_waitnr  billnum.bn_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cabspendin AS caBase OF common\libs\cit_ca.vcx
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
DEFINE CLASS cacashin AS caBase OF common\libs\cit_ca.vcx
Alias = [cacashin]
Tables = [cashin]
KeyFieldList = [ci_ciid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ci_amount,
       ci_changes,
       ci_ciid,
       ci_debit,
       ci_flag,
       ci_oldway,
       ci_paynr,
       ci_readid,
       ci_userid,
       ci_waitnr,
       ci_xreadid
    FROM cashin
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ci_amount  Y       DEFAULT 0,
    ci_changes M       DEFAULT "",
    ci_ciid    I       DEFAULT 0,
    ci_debit   Y       DEFAULT 0,
    ci_flag    N(1,0)  DEFAULT 0,
    ci_oldway  L       DEFAULT .F.,
    ci_paynr   N(2,0)  DEFAULT 0,
    ci_readid  I       DEFAULT 0,
    ci_userid  C(25)   DEFAULT "",
    ci_waitnr  N(3,0)  DEFAULT 0,
    ci_xreadid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ci_amount,
    ci_changes,
    ci_ciid,
    ci_debit,
    ci_flag,
    ci_oldway,
    ci_paynr,
    ci_readid,
    ci_userid,
    ci_waitnr,
    ci_xreadid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ci_amount  cashin.ci_amount,
    ci_changes cashin.ci_changes,
    ci_ciid    cashin.ci_ciid,
    ci_debit   cashin.ci_debit,
    ci_flag    cashin.ci_flag,
    ci_oldway  cashin.ci_oldway,
    ci_paynr   cashin.ci_paynr,
    ci_readid  cashin.ci_readid,
    ci_userid  cashin.ci_userid,
    ci_waitnr  cashin.ci_waitnr,
    ci_xreadid cashin.ci_xreadid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacheck AS caBase OF common\libs\cit_ca.vcx
Alias = [cacheck]
Tables = [check]
KeyFieldList = [ck_chkid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ck_billnum,
       ck_bmsdisc,
       ck_cfile,
       ck_chkid,
       ck_closed,
       ck_covers,
       ck_custnr,
       ck_fopost,
       ck_gstname,
       ck_gsttyp,
       ck_invcid,
       ck_lastclo,
       ck_lastopn,
       ck_lost,
       ck_opened,
       ck_printed,
       ck_room,
       ck_seatnr,
       ck_sysdate,
       ck_tableid,
       ck_touched,
       ck_waitnr
    FROM check
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ck_billnum I       DEFAULT 0,
    ck_bmsdisc C(3)    DEFAULT "",
    ck_cfile   L       DEFAULT .F.,
    ck_chkid   I       DEFAULT 0,
    ck_closed  T       DEFAULT {},
    ck_covers  N(3,0)  DEFAULT 0,
    ck_custnr  I       DEFAULT 0,
    ck_fopost  I       DEFAULT 0,
    ck_gstname C(30)   DEFAULT "",
    ck_gsttyp  N(2,0)  DEFAULT 0,
    ck_invcid  I       DEFAULT 0,
    ck_lastclo T       DEFAULT {},
    ck_lastopn T       DEFAULT {},
    ck_lost    L       DEFAULT .F.,
    ck_opened  T       DEFAULT {},
    ck_printed C(1)    DEFAULT "",
    ck_room    C(10)   DEFAULT "",
    ck_seatnr  I       DEFAULT 0,
    ck_sysdate D       DEFAULT {},
    ck_tableid I       DEFAULT 0,
    ck_touched L       DEFAULT .F.,
    ck_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ck_billnum,
    ck_bmsdisc,
    ck_cfile,
    ck_chkid,
    ck_closed,
    ck_covers,
    ck_custnr,
    ck_fopost,
    ck_gstname,
    ck_gsttyp,
    ck_invcid,
    ck_lastclo,
    ck_lastopn,
    ck_lost,
    ck_opened,
    ck_printed,
    ck_room,
    ck_seatnr,
    ck_sysdate,
    ck_tableid,
    ck_touched,
    ck_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ck_billnum check.ck_billnum,
    ck_bmsdisc check.ck_bmsdisc,
    ck_cfile   check.ck_cfile,
    ck_chkid   check.ck_chkid,
    ck_closed  check.ck_closed,
    ck_covers  check.ck_covers,
    ck_custnr  check.ck_custnr,
    ck_fopost  check.ck_fopost,
    ck_gstname check.ck_gstname,
    ck_gsttyp  check.ck_gsttyp,
    ck_invcid  check.ck_invcid,
    ck_lastclo check.ck_lastclo,
    ck_lastopn check.ck_lastopn,
    ck_lost    check.ck_lost,
    ck_opened  check.ck_opened,
    ck_printed check.ck_printed,
    ck_room    check.ck_room,
    ck_seatnr  check.ck_seatnr,
    ck_sysdate check.ck_sysdate,
    ck_tableid check.ck_tableid,
    ck_touched check.ck_touched,
    ck_waitnr  check.ck_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacreceipt AS caBase OF common\libs\cit_ca.vcx
Alias = [cacreceipt]
Tables = [creceipt]
KeyFieldList = [cr_crecipt]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       cr_addrid,
       cr_chkid,
       cr_crecipt,
       cr_invoice,
       cr_paid,
       cr_paynr
    FROM creceipt
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_addrid  N(8,0)  DEFAULT 0,
    cr_chkid   I       DEFAULT 0,
    cr_crecipt N(8,0)  DEFAULT 0,
    cr_invoice I       DEFAULT 0,
    cr_paid    L       DEFAULT .F.,
    cr_paynr   N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_addrid,
    cr_chkid,
    cr_crecipt,
    cr_invoice,
    cr_paid,
    cr_paynr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    cr_addrid  creceipt.cr_addrid,
    cr_chkid   creceipt.cr_chkid,
    cr_crecipt creceipt.cr_crecipt,
    cr_invoice creceipt.cr_invoice,
    cr_paid    creceipt.cr_paid,
    cr_paynr   creceipt.cr_paynr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cacrlog AS caBase OF common\libs\cit_ca.vcx
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
DEFINE CLASS cacustact AS caBase OF common\libs\cit_ca.vcx
Alias = [cacustact]
Tables = [custact]
KeyFieldList = [ca_caid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ca_aaddrid,
       ca_addrid,
       ca_caid,
       ca_city,
       ca_company,
       ca_compnum,
       ca_deleted,
       ca_fname,
       ca_limit,
       ca_lname,
       ca_phone,
       ca_plevnr,
       ca_street,
       ca_title,
       ca_zip
    FROM custact
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ca_aaddrid N(8,0)  DEFAULT 0,
    ca_addrid  N(8,0)  DEFAULT 0,
    ca_caid    I       DEFAULT 0,
    ca_city    C(30)   DEFAULT "",
    ca_company C(50)   DEFAULT "",
    ca_compnum N(10,0) DEFAULT 0,
    ca_deleted L       DEFAULT .F.,
    ca_fname   C(20)   DEFAULT "",
    ca_limit   Y       DEFAULT 0,
    ca_lname   C(30)   DEFAULT "",
    ca_phone   C(20)   DEFAULT "",
    ca_plevnr  N(1,0)  DEFAULT 0,
    ca_street  C(30)   DEFAULT "",
    ca_title   C(25)   DEFAULT "",
    ca_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ca_aaddrid,
    ca_addrid,
    ca_caid,
    ca_city,
    ca_company,
    ca_compnum,
    ca_deleted,
    ca_fname,
    ca_limit,
    ca_lname,
    ca_phone,
    ca_plevnr,
    ca_street,
    ca_title,
    ca_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ca_aaddrid custact.ca_aaddrid,
    ca_addrid  custact.ca_addrid,
    ca_caid    custact.ca_caid,
    ca_city    custact.ca_city,
    ca_company custact.ca_company,
    ca_compnum custact.ca_compnum,
    ca_deleted custact.ca_deleted,
    ca_fname   custact.ca_fname,
    ca_limit   custact.ca_limit,
    ca_lname   custact.ca_lname,
    ca_phone   custact.ca_phone,
    ca_plevnr  custact.ca_plevnr,
    ca_street  custact.ca_street,
    ca_title   custact.ca_title,
    ca_zip     custact.ca_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cadepartm AS caBase OF common\libs\cit_ca.vcx
Alias = [cadepartm]
Tables = [departm]
KeyFieldList = [dp_deptnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       dp_deleted,
       dp_deptnr,
       dp_descr,
       dp_foart
    FROM departm
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_deleted L       DEFAULT .F.,
    dp_deptnr  N(2,0)  DEFAULT 0,
    dp_descr   C(20)   DEFAULT "",
    dp_foart   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_deleted,
    dp_deptnr,
    dp_descr,
    dp_foart
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dp_deleted departm.dp_deleted,
    dp_deptnr  departm.dp_deptnr,
    dp_descr   departm.dp_descr,
    dp_foart   departm.dp_foart
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cadesktblr AS caBase OF common\libs\cit_ca.vcx
Alias = [cadesktblr]
Tables = [desktblr]
KeyFieldList = [dr_drid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       dr_drid,
       dr_rlid,
       dr_trid
    FROM desktblr
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    dr_drid    I       DEFAULT 0,
    dr_rlid    I       DEFAULT 0,
    dr_trid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dr_drid,
    dr_rlid,
    dr_trid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    dr_drid    desktblr.dr_drid,
    dr_rlid    desktblr.dr_rlid,
    dr_trid    desktblr.dr_trid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cadiscount AS caBase OF common\libs\cit_ca.vcx
Alias = [cadiscount]
Tables = [discount]
KeyFieldList = [ds_discnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ds_cusmsg,
       ds_deleted,
       ds_descr,
       ds_discnr,
       ds_discpct
    FROM discount
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ds_cusmsg  L       DEFAULT .F.,
    ds_deleted L       DEFAULT .F.,
    ds_descr   C(20)   DEFAULT "",
    ds_discnr  N(2,0)  DEFAULT 0,
    ds_discpct N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ds_cusmsg,
    ds_deleted,
    ds_descr,
    ds_discnr,
    ds_discpct
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ds_cusmsg  discount.ds_cusmsg,
    ds_deleted discount.ds_deleted,
    ds_descr   discount.ds_descr,
    ds_discnr  discount.ds_discnr,
    ds_discpct discount.ds_discpct
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caedevent AS caBase OF common\libs\cit_ca.vcx
Alias = [caedevent]
Tables = [edevent]
KeyFieldList = [ed_edid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ed_action,
       ed_bgtime,
       ed_devtype,
       ed_edid,
       ed_edtime,
       ed_orderid,
       ed_plu,
       ed_status,
       ed_waitnr
    FROM edevent
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ed_action  N(1,0)  DEFAULT 0,
    ed_bgtime  T       DEFAULT {},
    ed_devtype N(1,0)  DEFAULT 0,
    ed_edid    I       DEFAULT 0,
    ed_edtime  T       DEFAULT {},
    ed_orderid I       DEFAULT 0,
    ed_plu     N(4,0)  DEFAULT 0,
    ed_status  N(1,0)  DEFAULT 0,
    ed_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ed_action,
    ed_bgtime,
    ed_devtype,
    ed_edid,
    ed_edtime,
    ed_orderid,
    ed_plu,
    ed_status,
    ed_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ed_action  edevent.ed_action,
    ed_bgtime  edevent.ed_bgtime,
    ed_devtype edevent.ed_devtype,
    ed_edid    edevent.ed_edid,
    ed_edtime  edevent.ed_edtime,
    ed_orderid edevent.ed_orderid,
    ed_plu     edevent.ed_plu,
    ed_status  edevent.ed_status,
    ed_waitnr  edevent.ed_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caelpay AS caBase OF common\libs\cit_ca.vcx
Alias = [caelpay]
Tables = [elpay]
KeyFieldList = [el_elid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       el_elid,
       el_paymid,
       el_paynr,
       el_print,
       el_reciv,
       el_sent
    FROM elpay
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    el_elid    I       DEFAULT 0,
    el_paymid  I       DEFAULT 0,
    el_paynr   N(2,0)  DEFAULT 0,
    el_print   M       DEFAULT "",
    el_reciv   M       DEFAULT "",
    el_sent    M       DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    el_elid,
    el_paymid,
    el_paynr,
    el_print,
    el_reciv,
    el_sent
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    el_elid    elpay.el_elid,
    el_paymid  elpay.el_paymid,
    el_paynr   elpay.el_paynr,
    el_print   elpay.el_print,
    el_reciv   elpay.el_reciv,
    el_sent    elpay.el_sent
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caemployee AS caBase OF common\libs\cit_ca.vcx
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
       em_waitnr,
       em_whweek,
       em_zcid,
       em_zip
    FROM employee
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    em_accnr   N(12,0) DEFAULT 0,
    em_baid    I       DEFAULT 0,
    em_birth   D       DEFAULT {},
    em_bkcity  C(50)   DEFAULT "",
    em_bkname  C(50)   DEFAULT "",
    em_bknr    N(8,0)  DEFAULT 0,
    em_city    C(30)   DEFAULT "",
    em_dayweek N(1,0)  DEFAULT 0,
    em_emid    I       DEFAULT 0,
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
    em_waitnr  N(3,0)  DEFAULT 0,
    em_whweek  N(4,1)  DEFAULT 0,
    em_zcid    I       DEFAULT 0,
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
    em_waitnr,
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
    em_waitnr  employee.em_waitnr,
    em_whweek  employee.em_whweek,
    em_zcid    employee.em_zcid,
    em_zip     employee.em_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caemployeh AS caBase OF common\libs\cit_ca.vcx
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
    eh_ehid    I       DEFAULT 0,
    eh_emid    I       DEFAULT 0,
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
DEFINE CLASS cafopostid AS caBase OF common\libs\cit_ca.vcx
Alias = [cafopostid]
Tables = [fopostid]
KeyFieldList = [fp_fopid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       fp_ciid,
       fp_fopid,
       fp_orderid,
       fp_paymid,
       fp_readid,
       fp_setid
    FROM fopostid
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    fp_ciid    I       DEFAULT 0,
    fp_fopid   N(8,0)  DEFAULT 0,
    fp_orderid I       DEFAULT 0,
    fp_paymid  I       DEFAULT 0,
    fp_readid  I       DEFAULT 0,
    fp_setid   N(8,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fp_ciid,
    fp_fopid,
    fp_orderid,
    fp_paymid,
    fp_readid,
    fp_setid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    fp_ciid    fopostid.fp_ciid,
    fp_fopid   fopostid.fp_fopid,
    fp_orderid fopostid.fp_orderid,
    fp_paymid  fopostid.fp_paymid,
    fp_readid  fopostid.fp_readid,
    fp_setid   fopostid.fp_setid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cafprinter AS caBase OF common\libs\cit_ca.vcx
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
DEFINE CLASS caguestgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [caguestgrp]
Tables = [guestgrp]
KeyFieldList = [gg_gsgrpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       gg_deleted,
       gg_gsgrpid,
       gg_name,
       gg_plevnr,
       gg_quitpay
    FROM guestgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    gg_deleted L       DEFAULT .F.,
    gg_gsgrpid I       DEFAULT 0,
    gg_name    C(20)   DEFAULT "",
    gg_plevnr  N(1,0)  DEFAULT 0,
    gg_quitpay L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gg_deleted,
    gg_gsgrpid,
    gg_name,
    gg_plevnr,
    gg_quitpay
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gg_deleted guestgrp.gg_deleted,
    gg_gsgrpid guestgrp.gg_gsgrpid,
    gg_name    guestgrp.gg_name,
    gg_plevnr  guestgrp.gg_plevnr,
    gg_quitpay guestgrp.gg_quitpay
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caguestinf AS caBase OF common\libs\cit_ca.vcx
Alias = [caguestinf]
Tables = [guestinf]
KeyFieldList = [gi_aaddrid, gi_addrid, gi_apid, gi_giid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       gi_aaddrid,
       gi_addrid,
       gi_apid,
       gi_chkid,
       gi_city,
       gi_company,
       gi_compnum,
       gi_departm,
       gi_fname,
       gi_giid,
       gi_lname,
       gi_note,
       gi_street,
       gi_title,
       gi_zip
    FROM guestinf
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    gi_aaddrid N(8,0)  DEFAULT 0,
    gi_addrid  N(8,0)  DEFAULT 0,
    gi_apid    N(8,0)  DEFAULT 0,
    gi_chkid   I       DEFAULT 0,
    gi_city    C(30)   DEFAULT "",
    gi_company C(50)   DEFAULT "",
    gi_compnum N(10,0) DEFAULT 0,
    gi_departm C(50)   DEFAULT "",
    gi_fname   C(20)   DEFAULT "",
    gi_giid    I       DEFAULT 0,
    gi_lname   C(30)   DEFAULT "",
    gi_note    M       DEFAULT "",
    gi_street  C(30)   DEFAULT "",
    gi_title   C(25)   DEFAULT "",
    gi_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gi_aaddrid,
    gi_addrid,
    gi_apid,
    gi_chkid,
    gi_city,
    gi_company,
    gi_compnum,
    gi_departm,
    gi_fname,
    gi_giid,
    gi_lname,
    gi_note,
    gi_street,
    gi_title,
    gi_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gi_aaddrid guestinf.gi_aaddrid,
    gi_addrid  guestinf.gi_addrid,
    gi_apid    guestinf.gi_apid,
    gi_chkid   guestinf.gi_chkid,
    gi_city    guestinf.gi_city,
    gi_company guestinf.gi_company,
    gi_compnum guestinf.gi_compnum,
    gi_departm guestinf.gi_departm,
    gi_fname   guestinf.gi_fname,
    gi_giid    guestinf.gi_giid,
    gi_lname   guestinf.gi_lname,
    gi_note    guestinf.gi_note,
    gi_street  guestinf.gi_street,
    gi_title   guestinf.gi_title,
    gi_zip     guestinf.gi_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caguesttyp AS caBase OF common\libs\cit_ca.vcx
Alias = [caguesttyp]
Tables = [guesttyp]
KeyFieldList = [gt_gsttyp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       gt_deleted,
       gt_descr,
       gt_gsttyp
    FROM guesttyp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    gt_deleted L       DEFAULT .F.,
    gt_descr   C(20)   DEFAULT "",
    gt_gsttyp  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gt_deleted,
    gt_descr,
    gt_gsttyp
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    gt_deleted guesttyp.gt_deleted,
    gt_descr   guesttyp.gt_descr,
    gt_gsttyp  guesttyp.gt_gsttyp
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahbctran AS caBase OF common\libs\cit_ca.vcx
Alias = [cahbctran]
Tables = [hbctran]
KeyFieldList = [bt_btid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       bt_aaddrid,
       bt_addrid,
       bt_artid,
       bt_bcid,
       bt_btid,
       bt_caid,
       bt_chkid,
       bt_compnum,
       bt_discnr,
       bt_discpct,
       bt_ldescr,
       bt_orderid,
       bt_plevnr,
       bt_posted,
       bt_qty,
       bt_sysdate
    FROM hbctran
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_aaddrid N(8,0)  DEFAULT 0,
    bt_addrid  N(8,0)  DEFAULT 0,
    bt_artid   I       DEFAULT 0,
    bt_bcid    I       DEFAULT 0,
    bt_btid    I       DEFAULT 0,
    bt_caid    I       DEFAULT 0,
    bt_chkid   I       DEFAULT 0,
    bt_compnum N(10,0) DEFAULT 0,
    bt_discnr  N(2,0)  DEFAULT 0,
    bt_discpct N(3,0)  DEFAULT 0,
    bt_ldescr  C(40)   DEFAULT "",
    bt_orderid I       DEFAULT 0,
    bt_plevnr  N(1,0)  DEFAULT 0,
    bt_posted  T       DEFAULT {},
    bt_qty     N(8,3)  DEFAULT 0,
    bt_sysdate D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_aaddrid,
    bt_addrid,
    bt_artid,
    bt_bcid,
    bt_btid,
    bt_caid,
    bt_chkid,
    bt_compnum,
    bt_discnr,
    bt_discpct,
    bt_ldescr,
    bt_orderid,
    bt_plevnr,
    bt_posted,
    bt_qty,
    bt_sysdate
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    bt_aaddrid hbctran.bt_aaddrid,
    bt_addrid  hbctran.bt_addrid,
    bt_artid   hbctran.bt_artid,
    bt_bcid    hbctran.bt_bcid,
    bt_btid    hbctran.bt_btid,
    bt_caid    hbctran.bt_caid,
    bt_chkid   hbctran.bt_chkid,
    bt_compnum hbctran.bt_compnum,
    bt_discnr  hbctran.bt_discnr,
    bt_discpct hbctran.bt_discpct,
    bt_ldescr  hbctran.bt_ldescr,
    bt_orderid hbctran.bt_orderid,
    bt_plevnr  hbctran.bt_plevnr,
    bt_posted  hbctran.bt_posted,
    bt_qty     hbctran.bt_qty,
    bt_sysdate hbctran.bt_sysdate
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahcheck AS caBase OF common\libs\cit_ca.vcx
Alias = [cahcheck]
Tables = [hcheck]
KeyFieldList = [ck_chkid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ck_billnum,
       ck_cfile,
       ck_chkid,
       ck_covers,
       ck_gsttyp,
       ck_invcid,
       ck_lost,
       ck_seatnr,
       ck_sysdate,
       ck_tableid
    FROM hcheck
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ck_billnum I       DEFAULT 0,
    ck_cfile   L       DEFAULT .F.,
    ck_chkid   I       DEFAULT 0,
    ck_covers  N(3,0)  DEFAULT 0,
    ck_gsttyp  N(2,0)  DEFAULT 0,
    ck_invcid  I       DEFAULT 0,
    ck_lost    L       DEFAULT .F.,
    ck_seatnr  I       DEFAULT 0,
    ck_sysdate D       DEFAULT {},
    ck_tableid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ck_billnum,
    ck_cfile,
    ck_chkid,
    ck_covers,
    ck_gsttyp,
    ck_invcid,
    ck_lost,
    ck_seatnr,
    ck_sysdate,
    ck_tableid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ck_billnum hcheck.ck_billnum,
    ck_cfile   hcheck.ck_cfile,
    ck_chkid   hcheck.ck_chkid,
    ck_covers  hcheck.ck_covers,
    ck_gsttyp  hcheck.ck_gsttyp,
    ck_invcid  hcheck.ck_invcid,
    ck_lost    hcheck.ck_lost,
    ck_seatnr  hcheck.ck_seatnr,
    ck_sysdate hcheck.ck_sysdate,
    ck_tableid hcheck.ck_tableid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahedevent AS caBase OF common\libs\cit_ca.vcx
Alias = [cahedevent]
Tables = [hedevent]
KeyFieldList = [ed_edid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ed_action,
       ed_bgtime,
       ed_devtype,
       ed_edid,
       ed_edtime,
       ed_orderid,
       ed_plu,
       ed_status,
       ed_waitnr
    FROM hedevent
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ed_action  N(1,0)  DEFAULT 0,
    ed_bgtime  T       DEFAULT {},
    ed_devtype N(1,0)  DEFAULT 0,
    ed_edid    I       DEFAULT 0,
    ed_edtime  T       DEFAULT {},
    ed_orderid I       DEFAULT 0,
    ed_plu     N(4,0)  DEFAULT 0,
    ed_status  N(1,0)  DEFAULT 0,
    ed_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ed_action,
    ed_bgtime,
    ed_devtype,
    ed_edid,
    ed_edtime,
    ed_orderid,
    ed_plu,
    ed_status,
    ed_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ed_action  hedevent.ed_action,
    ed_bgtime  hedevent.ed_bgtime,
    ed_devtype hedevent.ed_devtype,
    ed_edid    hedevent.ed_edid,
    ed_edtime  hedevent.ed_edtime,
    ed_orderid hedevent.ed_orderid,
    ed_plu     hedevent.ed_plu,
    ed_status  hedevent.ed_status,
    ed_waitnr  hedevent.ed_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahordcomp AS caBase OF common\libs\cit_ca.vcx
Alias = [cahordcomp]
Tables = [hordcomp]
KeyFieldList = [oc_orcmpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       oc_amt,
       oc_artid,
       oc_compid,
       oc_mainnr,
       oc_orcmpid,
       oc_subnr,
       oc_vatnr,
       oc_vatpct
    FROM hordcomp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    oc_amt     Y       DEFAULT 0,
    oc_artid   I       DEFAULT 0,
    oc_compid  I       DEFAULT 0,
    oc_mainnr  N(2,0)  DEFAULT 0,
    oc_orcmpid I       DEFAULT 0,
    oc_subnr   N(4,0)  DEFAULT 0,
    oc_vatnr   N(1,0)  DEFAULT 0,
    oc_vatpct  N(4,1)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oc_amt,
    oc_artid,
    oc_compid,
    oc_mainnr,
    oc_orcmpid,
    oc_subnr,
    oc_vatnr,
    oc_vatpct
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oc_amt     hordcomp.oc_amt,
    oc_artid   hordcomp.oc_artid,
    oc_compid  hordcomp.oc_compid,
    oc_mainnr  hordcomp.oc_mainnr,
    oc_orcmpid hordcomp.oc_orcmpid,
    oc_subnr   hordcomp.oc_subnr,
    oc_vatnr   hordcomp.oc_vatnr,
    oc_vatpct  hordcomp.oc_vatpct
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahorder AS caBase OF common\libs\cit_ca.vcx
Alias = [cahorder]
Tables = [horder]
KeyFieldList = [or_orderid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       or_artid,
       or_arttyp,
       or_chkid,
       or_compid,
       or_crwatnr,
       or_deptnr,
       or_discnr,
       or_discpct,
       or_locnr,
       or_modid,
       or_oaid,
       or_orderid,
       or_ordlsid,
       or_plevnr,
       or_posted,
       or_prc,
       or_qty,
       or_readid,
       or_rreason,
       or_seatnr,
       or_spilnr,
       or_supplem,
       or_sysdate,
       or_tablenr,
       or_termnr,
       or_timznnr,
       or_waitnr
    FROM horder
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_artid   I       DEFAULT 0,
    or_arttyp  N(1,0)  DEFAULT 0,
    or_chkid   I       DEFAULT 0,
    or_compid  I       DEFAULT 0,
    or_crwatnr N(3,0)  DEFAULT 0,
    or_deptnr  N(2,0)  DEFAULT 0,
    or_discnr  N(2,0)  DEFAULT 0,
    or_discpct N(3,0)  DEFAULT 0,
    or_locnr   N(2,0)  DEFAULT 0,
    or_modid   I       DEFAULT 0,
    or_oaid    I       DEFAULT 0,
    or_orderid I       DEFAULT 0,
    or_ordlsid I       DEFAULT 0,
    or_plevnr  N(1,0)  DEFAULT 0,
    or_posted  T       DEFAULT {},
    or_prc     Y       DEFAULT 0,
    or_qty     N(8,3)  DEFAULT 0,
    or_readid  I       DEFAULT 0,
    or_rreason C(50)   DEFAULT "",
    or_seatnr  I       DEFAULT 0,
    or_spilnr  N(2,0)  DEFAULT 0,
    or_supplem C(30)   DEFAULT "",
    or_sysdate D       DEFAULT {},
    or_tablenr N(4,0)  DEFAULT 0,
    or_termnr  N(2,0)  DEFAULT 0,
    or_timznnr N(2,0)  DEFAULT 0,
    or_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_artid,
    or_arttyp,
    or_chkid,
    or_compid,
    or_crwatnr,
    or_deptnr,
    or_discnr,
    or_discpct,
    or_locnr,
    or_modid,
    or_oaid,
    or_orderid,
    or_ordlsid,
    or_plevnr,
    or_posted,
    or_prc,
    or_qty,
    or_readid,
    or_rreason,
    or_seatnr,
    or_spilnr,
    or_supplem,
    or_sysdate,
    or_tablenr,
    or_termnr,
    or_timznnr,
    or_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_artid   horder.or_artid,
    or_arttyp  horder.or_arttyp,
    or_chkid   horder.or_chkid,
    or_compid  horder.or_compid,
    or_crwatnr horder.or_crwatnr,
    or_deptnr  horder.or_deptnr,
    or_discnr  horder.or_discnr,
    or_discpct horder.or_discpct,
    or_locnr   horder.or_locnr,
    or_modid   horder.or_modid,
    or_oaid    horder.or_oaid,
    or_orderid horder.or_orderid,
    or_ordlsid horder.or_ordlsid,
    or_plevnr  horder.or_plevnr,
    or_posted  horder.or_posted,
    or_prc     horder.or_prc,
    or_qty     horder.or_qty,
    or_readid  horder.or_readid,
    or_rreason horder.or_rreason,
    or_seatnr  horder.or_seatnr,
    or_spilnr  horder.or_spilnr,
    or_supplem horder.or_supplem,
    or_sysdate horder.or_sysdate,
    or_tablenr horder.or_tablenr,
    or_termnr  horder.or_termnr,
    or_timznnr horder.or_timznnr,
    or_waitnr  horder.or_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahpayment AS caBase OF common\libs\cit_ca.vcx
Alias = [cahpayment]
Tables = [hpayment]
KeyFieldList = [py_paymid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       py_amt,
       py_chkid,
       py_crwatnr,
       py_curramt,
       py_deptnr,
       py_f2chkid,
       py_flag,
       py_paygnr,
       py_paymid,
       py_paynr,
       py_paytyp,
       py_posted,
       py_rate,
       py_readid,
       py_sysdate,
       py_termnr,
       py_text,
       py_void,
       py_waitnr
    FROM hpayment
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    py_amt     Y       DEFAULT 0,
    py_chkid   I       DEFAULT 0,
    py_crwatnr N(3,0)  DEFAULT 0,
    py_curramt Y       DEFAULT 0,
    py_deptnr  N(2,0)  DEFAULT 0,
    py_f2chkid I       DEFAULT 0,
    py_flag    N(1,0)  DEFAULT 0,
    py_paygnr  N(1,0)  DEFAULT 0,
    py_paymid  I       DEFAULT 0,
    py_paynr   N(2,0)  DEFAULT 0,
    py_paytyp  N(1,0)  DEFAULT 0,
    py_posted  T       DEFAULT {},
    py_rate    N(13,6) DEFAULT 0,
    py_readid  I       DEFAULT 0,
    py_sysdate D       DEFAULT {},
    py_termnr  N(2,0)  DEFAULT 0,
    py_text    C(25)   DEFAULT "",
    py_void    L       DEFAULT .F.,
    py_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    py_amt,
    py_chkid,
    py_crwatnr,
    py_curramt,
    py_deptnr,
    py_f2chkid,
    py_flag,
    py_paygnr,
    py_paymid,
    py_paynr,
    py_paytyp,
    py_posted,
    py_rate,
    py_readid,
    py_sysdate,
    py_termnr,
    py_text,
    py_void,
    py_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    py_amt     hpayment.py_amt,
    py_chkid   hpayment.py_chkid,
    py_crwatnr hpayment.py_crwatnr,
    py_curramt hpayment.py_curramt,
    py_deptnr  hpayment.py_deptnr,
    py_f2chkid hpayment.py_f2chkid,
    py_flag    hpayment.py_flag,
    py_paygnr  hpayment.py_paygnr,
    py_paymid  hpayment.py_paymid,
    py_paynr   hpayment.py_paynr,
    py_paytyp  hpayment.py_paytyp,
    py_posted  hpayment.py_posted,
    py_rate    hpayment.py_rate,
    py_readid  hpayment.py_readid,
    py_sysdate hpayment.py_sysdate,
    py_termnr  hpayment.py_termnr,
    py_text    hpayment.py_text,
    py_void    hpayment.py_void,
    py_waitnr  hpayment.py_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahtable AS caBase OF common\libs\cit_ca.vcx
Alias = [cahtable]
Tables = [htable]
KeyFieldList = [tb_tableid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tb_closed,
       tb_covers,
       tb_lost,
       tb_opened,
       tb_sysdate,
       tb_tableid,
       tb_tablenr
    FROM htable
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tb_closed  T       DEFAULT {},
    tb_covers  N(3,0)  DEFAULT 0,
    tb_lost    L       DEFAULT .F.,
    tb_opened  T       DEFAULT {},
    tb_sysdate D       DEFAULT {},
    tb_tableid I       DEFAULT 0,
    tb_tablenr N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tb_closed,
    tb_covers,
    tb_lost,
    tb_opened,
    tb_sysdate,
    tb_tableid,
    tb_tablenr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tb_closed  htable.tb_closed,
    tb_covers  htable.tb_covers,
    tb_lost    htable.tb_lost,
    tb_opened  htable.tb_opened,
    tb_sysdate htable.tb_sysdate,
    tb_tableid htable.tb_tableid,
    tb_tablenr htable.tb_tablenr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cahtablers AS caBase OF common\libs\cit_ca.vcx
Alias = [cahtablers]
Tables = [htablers]
KeyFieldList = [tr_trid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tr_aaddrid,
       tr_addrid,
       tr_changes,
       tr_created,
       tr_fname,
       tr_from,
       tr_gsgrpid,
       tr_lname,
       tr_note,
       tr_persons,
       tr_phone,
       tr_rsid,
       tr_status,
       tr_sysdate,
       tr_tableid,
       tr_tablenr,
       tr_title,
       tr_to,
       tr_trid,
       tr_updated,
       tr_user,
       tr_userid,
       tr_usrname,
       tr_waitnr
    FROM htablers
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tr_aaddrid N(8,0)  DEFAULT 0,
    tr_addrid  N(8,0)  DEFAULT 0,
    tr_changes M       DEFAULT "",
    tr_created T       DEFAULT {},
    tr_fname   C(20)   DEFAULT "",
    tr_from    T       DEFAULT {},
    tr_gsgrpid I       DEFAULT 0,
    tr_lname   C(30)   DEFAULT "",
    tr_note    M       DEFAULT "",
    tr_persons N(2,0)  DEFAULT 0,
    tr_phone   C(20)   DEFAULT "",
    tr_rsid    I       DEFAULT 0,
    tr_status  I       DEFAULT 0,
    tr_sysdate D       DEFAULT {},
    tr_tableid I       DEFAULT 0,
    tr_tablenr N(4,0)  DEFAULT 0,
    tr_title   C(25)   DEFAULT "",
    tr_to      T       DEFAULT {},
    tr_trid    I       DEFAULT 0,
    tr_updated T       DEFAULT {},
    tr_user    C(3)    DEFAULT "",
    tr_userid  C(10)   DEFAULT "",
    tr_usrname C(10)   DEFAULT "",
    tr_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tr_aaddrid,
    tr_addrid,
    tr_changes,
    tr_created,
    tr_fname,
    tr_from,
    tr_gsgrpid,
    tr_lname,
    tr_note,
    tr_persons,
    tr_phone,
    tr_rsid,
    tr_status,
    tr_sysdate,
    tr_tableid,
    tr_tablenr,
    tr_title,
    tr_to,
    tr_trid,
    tr_updated,
    tr_user,
    tr_userid,
    tr_usrname,
    tr_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tr_aaddrid htablers.tr_aaddrid,
    tr_addrid  htablers.tr_addrid,
    tr_changes htablers.tr_changes,
    tr_created htablers.tr_created,
    tr_fname   htablers.tr_fname,
    tr_from    htablers.tr_from,
    tr_gsgrpid htablers.tr_gsgrpid,
    tr_lname   htablers.tr_lname,
    tr_note    htablers.tr_note,
    tr_persons htablers.tr_persons,
    tr_phone   htablers.tr_phone,
    tr_rsid    htablers.tr_rsid,
    tr_status  htablers.tr_status,
    tr_sysdate htablers.tr_sysdate,
    tr_tableid htablers.tr_tableid,
    tr_tablenr htablers.tr_tablenr,
    tr_title   htablers.tr_title,
    tr_to      htablers.tr_to,
    tr_trid    htablers.tr_trid,
    tr_updated htablers.tr_updated,
    tr_user    htablers.tr_user,
    tr_userid  htablers.tr_userid,
    tr_usrname htablers.tr_usrname,
    tr_waitnr  htablers.tr_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caid AS caBase OF common\libs\cit_ca.vcx
Alias = [caid]
Tables = [id]
KeyFieldList = [id_name]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       id_last,
       id_name
    FROM id
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_last    I       DEFAULT 0,
    id_name    C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_last,
    id_name
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    id_last    id.id_last,
    id_name    id.id_name
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainoritem AS caBase OF common\libs\cit_ca.vcx
Alias = [cainoritem]
Tables = [inoritem]
KeyFieldList = [it_itid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       it_invtid,
       it_itid,
       it_ordered,
       it_ordnum,
       it_reason,
       it_receive,
       it_status
    FROM inoritem
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    it_invtid  I       DEFAULT 0,
    it_itid    I       DEFAULT 0,
    it_ordered N(10,6) DEFAULT 0,
    it_ordnum  N(8,0)  DEFAULT 0,
    it_reason  C(200)  DEFAULT "",
    it_receive N(10,6) DEFAULT 0,
    it_status  N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    it_invtid,
    it_itid,
    it_ordered,
    it_ordnum,
    it_reason,
    it_receive,
    it_status
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    it_invtid  inoritem.it_invtid,
    it_itid    inoritem.it_itid,
    it_ordered inoritem.it_ordered,
    it_ordnum  inoritem.it_ordnum,
    it_reason  inoritem.it_reason,
    it_receive inoritem.it_receive,
    it_status  inoritem.it_status
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvorder AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvorder]
Tables = [invorder]
KeyFieldList = [io_ioid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       io_date,
       io_ioid,
       io_ordnum,
       io_ordtry,
       io_status,
       io_suppid,
       io_user,
       io_winname
    FROM invorder
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    io_date    D       DEFAULT {},
    io_ioid    I       DEFAULT 0,
    io_ordnum  N(8,0)  DEFAULT 0,
    io_ordtry  I       DEFAULT 0,
    io_status  N(1,0)  DEFAULT 0,
    io_suppid  N(8,0)  DEFAULT 0,
    io_user    C(3)    DEFAULT "",
    io_winname C(15)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    io_date,
    io_ioid,
    io_ordnum,
    io_ordtry,
    io_status,
    io_suppid,
    io_user,
    io_winname
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    io_date    invorder.io_date,
    io_ioid    invorder.io_ioid,
    io_ordnum  invorder.io_ordnum,
    io_ordtry  invorder.io_ordtry,
    io_status  invorder.io_status,
    io_suppid  invorder.io_suppid,
    io_user    invorder.io_user,
    io_winname invorder.io_winname
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvtgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvtgrp]
Tables = [invtgrp]
KeyFieldList = [ig_invtgnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ig_deleted,
       ig_descr,
       ig_invtgnr
    FROM invtgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ig_deleted L       DEFAULT .F.,
    ig_descr   C(20)   DEFAULT "",
    ig_invtgnr N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ig_deleted,
    ig_descr,
    ig_invtgnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ig_deleted invtgrp.ig_deleted,
    ig_descr   invtgrp.ig_descr,
    ig_invtgnr invtgrp.ig_invtgnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvthist AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvthist]
Tables = [invthist]
KeyFieldList = [ih_ihid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ih_currqty,
       ih_ihid,
       ih_invtid,
       ih_puprice,
       ih_sysdate
    FROM invthist
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ih_currqty N(17,6) DEFAULT 0,
    ih_ihid    I       DEFAULT 0,
    ih_invtid  I       DEFAULT 0,
    ih_puprice Y       DEFAULT 0,
    ih_sysdate D       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ih_currqty,
    ih_ihid,
    ih_invtid,
    ih_puprice,
    ih_sysdate
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ih_currqty invthist.ih_currqty,
    ih_ihid    invthist.ih_ihid,
    ih_invtid  invthist.ih_invtid,
    ih_puprice invthist.ih_puprice,
    ih_sysdate invthist.ih_sysdate
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvtitem AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvtitem]
Tables = [invtitem]
KeyFieldList = [ii_invtid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ii_currqty,
       ii_curstck,
       ii_curstdt,
       ii_deleted,
       ii_descr,
       ii_ean,
       ii_invsgnr,
       ii_invtgnr,
       ii_invtid,
       ii_lastord,
       ii_maxinvt,
       ii_mininvt,
       ii_netqty,
       ii_netunit,
       ii_note,
       ii_puprice,
       ii_retneg,
       ii_sellprc,
       ii_selltru,
       ii_suppmsg,
       ii_unit
    FROM invtitem
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ii_currqty N(17,6) DEFAULT 0,
    ii_curstck N(10,6) DEFAULT 0,
    ii_curstdt T       DEFAULT {},
    ii_deleted L       DEFAULT .F.,
    ii_descr   C(30)   DEFAULT "",
    ii_ean     C(13)   DEFAULT "",
    ii_invsgnr N(2,0)  DEFAULT 0,
    ii_invtgnr N(2,0)  DEFAULT 0,
    ii_invtid  I       DEFAULT 0,
    ii_lastord N(8,0)  DEFAULT 0,
    ii_maxinvt N(8,0)  DEFAULT 0,
    ii_mininvt N(8,0)  DEFAULT 0,
    ii_netqty  N(7,3)  DEFAULT 0,
    ii_netunit C(2)    DEFAULT "",
    ii_note    M       DEFAULT "",
    ii_puprice Y       DEFAULT 0,
    ii_retneg  L       DEFAULT .F.,
    ii_sellprc Y       DEFAULT 0,
    ii_selltru L       DEFAULT .F.,
    ii_suppmsg L       DEFAULT .F.,
    ii_unit    C(2)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ii_currqty,
    ii_curstck,
    ii_curstdt,
    ii_deleted,
    ii_descr,
    ii_ean,
    ii_invsgnr,
    ii_invtgnr,
    ii_invtid,
    ii_lastord,
    ii_maxinvt,
    ii_mininvt,
    ii_netqty,
    ii_netunit,
    ii_note,
    ii_puprice,
    ii_retneg,
    ii_sellprc,
    ii_selltru,
    ii_suppmsg,
    ii_unit
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ii_currqty invtitem.ii_currqty,
    ii_curstck invtitem.ii_curstck,
    ii_curstdt invtitem.ii_curstdt,
    ii_deleted invtitem.ii_deleted,
    ii_descr   invtitem.ii_descr,
    ii_ean     invtitem.ii_ean,
    ii_invsgnr invtitem.ii_invsgnr,
    ii_invtgnr invtitem.ii_invtgnr,
    ii_invtid  invtitem.ii_invtid,
    ii_lastord invtitem.ii_lastord,
    ii_maxinvt invtitem.ii_maxinvt,
    ii_mininvt invtitem.ii_mininvt,
    ii_netqty  invtitem.ii_netqty,
    ii_netunit invtitem.ii_netunit,
    ii_note    invtitem.ii_note,
    ii_puprice invtitem.ii_puprice,
    ii_retneg  invtitem.ii_retneg,
    ii_sellprc invtitem.ii_sellprc,
    ii_selltru invtitem.ii_selltru,
    ii_suppmsg invtitem.ii_suppmsg,
    ii_unit    invtitem.ii_unit
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvtlog AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvtlog]
Tables = [invtlog]
KeyFieldList = [il_ilid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       il_datetim,
       il_descr,
       il_ilid,
       il_inputid,
       il_invtid,
       il_ordnum,
       il_puprice,
       il_qty,
       il_userid
    FROM invtlog
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    il_datetim T       DEFAULT {},
    il_descr   C(100)  DEFAULT "",
    il_ilid    I       DEFAULT 0,
    il_inputid I       DEFAULT 0,
    il_invtid  I       DEFAULT 0,
    il_ordnum  N(8,0)  DEFAULT 0,
    il_puprice Y       DEFAULT 0,
    il_qty     N(17,6) DEFAULT 0,
    il_userid  C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    il_datetim,
    il_descr,
    il_ilid,
    il_inputid,
    il_invtid,
    il_ordnum,
    il_puprice,
    il_qty,
    il_userid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    il_datetim invtlog.il_datetim,
    il_descr   invtlog.il_descr,
    il_ilid    invtlog.il_ilid,
    il_inputid invtlog.il_inputid,
    il_invtid  invtlog.il_invtid,
    il_ordnum  invtlog.il_ordnum,
    il_puprice invtlog.il_puprice,
    il_qty     invtlog.il_qty,
    il_userid  invtlog.il_userid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvtsgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvtsgrp]
Tables = [invtsgrp]
KeyFieldList = [ir_invsgnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ir_deleted,
       ir_descr,
       ir_invsgnr
    FROM invtsgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ir_deleted L       DEFAULT .F.,
    ir_descr   C(20)   DEFAULT "",
    ir_invsgnr N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ir_deleted,
    ir_descr,
    ir_invsgnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ir_deleted invtsgrp.ir_deleted,
    ir_descr   invtsgrp.ir_descr,
    ir_invsgnr invtsgrp.ir_invsgnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvtsupp AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvtsupp]
Tables = [invtsupp]
KeyFieldList = [is_insupid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       is_insupid,
       is_invtid,
       is_selgain,
       is_sellprc,
       is_spartnr,
       is_spblock,
       is_spforar,
       is_suppid,
       is_unitprc
    FROM invtsupp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    is_insupid N(8,0)  DEFAULT 0,
    is_invtid  I       DEFAULT 0,
    is_selgain N(7,2)  DEFAULT 0,
    is_sellprc Y       DEFAULT 0,
    is_spartnr C(50)   DEFAULT "",
    is_spblock L       DEFAULT .F.,
    is_spforar L       DEFAULT .F.,
    is_suppid  N(8,0)  DEFAULT 0,
    is_unitprc Y       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    is_insupid,
    is_invtid,
    is_selgain,
    is_sellprc,
    is_spartnr,
    is_spblock,
    is_spforar,
    is_suppid,
    is_unitprc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    is_insupid invtsupp.is_insupid,
    is_invtid  invtsupp.is_invtid,
    is_selgain invtsupp.is_selgain,
    is_sellprc invtsupp.is_sellprc,
    is_spartnr invtsupp.is_spartnr,
    is_spblock invtsupp.is_spblock,
    is_spforar invtsupp.is_spforar,
    is_suppid  invtsupp.is_suppid,
    is_unitprc invtsupp.is_unitprc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cainvtunit AS caBase OF common\libs\cit_ca.vcx
Alias = [cainvtunit]
Tables = [invtunit]
KeyFieldList = [iu_unit]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       iu_de,
       iu_descr,
       iu_en,
       iu_nl,
       iu_quant,
       iu_ratio,
       iu_rs,
       iu_unit
    FROM invtunit
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    iu_de      C(20)   DEFAULT "",
    iu_descr   C(20)   DEFAULT "",
    iu_en      C(20)   DEFAULT "",
    iu_nl      C(20)   DEFAULT "",
    iu_quant   C(1)    DEFAULT "",
    iu_ratio   B(6)    DEFAULT 0,
    iu_rs      C(20)   DEFAULT "",
    iu_unit    C(2)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    iu_de,
    iu_descr,
    iu_en,
    iu_nl,
    iu_quant,
    iu_ratio,
    iu_rs,
    iu_unit
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    iu_de      invtunit.iu_de,
    iu_descr   invtunit.iu_descr,
    iu_en      invtunit.iu_en,
    iu_nl      invtunit.iu_nl,
    iu_quant   invtunit.iu_quant,
    iu_ratio   invtunit.iu_ratio,
    iu_rs      invtunit.iu_rs,
    iu_unit    invtunit.iu_unit
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cajob AS caBase OF common\libs\cit_ca.vcx
Alias = [cajob]
Tables = [job]
KeyFieldList = [jb_jbnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       jb_deleted,
       jb_descr,
       jb_jbnr
    FROM job
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    jb_deleted L       DEFAULT .F.,
    jb_descr   C(20)   DEFAULT "",
    jb_jbnr    N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    jb_deleted,
    jb_descr,
    jb_jbnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    jb_deleted job.jb_deleted,
    jb_descr   job.jb_descr,
    jb_jbnr    job.jb_jbnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cakeydriv AS caBase OF common\libs\cit_ca.vcx
Alias = [cakeydriv]
Tables = [keydriv]
KeyFieldList = [kd_drivid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       kd_drivid,
       kd_name,
       kd_type,
       kd_wkbegin,
       kd_wkend,
       kd_wkout
    FROM keydriv
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    kd_drivid  I       DEFAULT 0,
    kd_name    C(20)   DEFAULT "",
    kd_type    N(2,0)  DEFAULT 0,
    kd_wkbegin C(20)   DEFAULT "",
    kd_wkend   C(20)   DEFAULT "",
    kd_wkout   C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    kd_drivid,
    kd_name,
    kd_type,
    kd_wkbegin,
    kd_wkend,
    kd_wkout
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    kd_drivid  keydriv.kd_drivid,
    kd_name    keydriv.kd_name,
    kd_type    keydriv.kd_type,
    kd_wkbegin keydriv.kd_wkbegin,
    kd_wkend   keydriv.kd_wkend,
    kd_wkout   keydriv.kd_wkout
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS calocation AS caBase OF common\libs\cit_ca.vcx
Alias = [calocation]
Tables = [location]
KeyFieldList = [lc_locnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       lc_begin,
       lc_deleted,
       lc_deptnr,
       lc_descr,
       lc_dscform,
       lc_dscoff,
       lc_dscport,
       lc_end,
       lc_feat1,
       lc_feat2,
       lc_feat3,
       lc_feat4,
       lc_feat5,
       lc_locnr,
       lc_or1form,
       lc_or1off,
       lc_or1port,
       lc_or2form,
       lc_or2off,
       lc_or2port,
       lc_or3form,
       lc_or3off,
       lc_or3port,
       lc_or4form,
       lc_or4off,
       lc_or4port,
       lc_or5form,
       lc_or5off,
       lc_or5port,
       lc_or6form,
       lc_or6off,
       lc_or6port,
       lc_or7form,
       lc_or7off,
       lc_or7port,
       lc_plevnr,
       lc_plforce,
       lc_rcpform,
       lc_rcpoff,
       lc_rcpport,
       lc_slpform,
       lc_slpoff,
       lc_slpport
    FROM location
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    lc_begin   N(4,0)  DEFAULT 0,
    lc_deleted L       DEFAULT .F.,
    lc_deptnr  N(2,0)  DEFAULT 0,
    lc_descr   C(20)   DEFAULT "",
    lc_dscform C(10)   DEFAULT "",
    lc_dscoff  L       DEFAULT .F.,
    lc_dscport C(30)   DEFAULT "",
    lc_end     N(4,0)  DEFAULT 0,
    lc_feat1   C(3)    DEFAULT "",
    lc_feat2   C(3)    DEFAULT "",
    lc_feat3   C(3)    DEFAULT "",
    lc_feat4   C(3)    DEFAULT "",
    lc_feat5   C(3)    DEFAULT "",
    lc_locnr   N(2,0)  DEFAULT 0,
    lc_or1form C(10)   DEFAULT "",
    lc_or1off  L       DEFAULT .F.,
    lc_or1port C(30)   DEFAULT "",
    lc_or2form C(10)   DEFAULT "",
    lc_or2off  L       DEFAULT .F.,
    lc_or2port C(30)   DEFAULT "",
    lc_or3form C(10)   DEFAULT "",
    lc_or3off  L       DEFAULT .F.,
    lc_or3port C(30)   DEFAULT "",
    lc_or4form C(10)   DEFAULT "",
    lc_or4off  L       DEFAULT .F.,
    lc_or4port C(30)   DEFAULT "",
    lc_or5form C(10)   DEFAULT "",
    lc_or5off  L       DEFAULT .F.,
    lc_or5port C(30)   DEFAULT "",
    lc_or6form C(10)   DEFAULT "",
    lc_or6off  L       DEFAULT .F.,
    lc_or6port C(30)   DEFAULT "",
    lc_or7form C(10)   DEFAULT "",
    lc_or7off  L       DEFAULT .F.,
    lc_or7port C(30)   DEFAULT "",
    lc_plevnr  N(1,0)  DEFAULT 0,
    lc_plforce L       DEFAULT .F.,
    lc_rcpform C(10)   DEFAULT "",
    lc_rcpoff  L       DEFAULT .F.,
    lc_rcpport C(30)   DEFAULT "",
    lc_slpform C(10)   DEFAULT "",
    lc_slpoff  L       DEFAULT .F.,
    lc_slpport C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lc_begin,
    lc_deleted,
    lc_deptnr,
    lc_descr,
    lc_dscform,
    lc_dscoff,
    lc_dscport,
    lc_end,
    lc_feat1,
    lc_feat2,
    lc_feat3,
    lc_feat4,
    lc_feat5,
    lc_locnr,
    lc_or1form,
    lc_or1off,
    lc_or1port,
    lc_or2form,
    lc_or2off,
    lc_or2port,
    lc_or3form,
    lc_or3off,
    lc_or3port,
    lc_or4form,
    lc_or4off,
    lc_or4port,
    lc_or5form,
    lc_or5off,
    lc_or5port,
    lc_or6form,
    lc_or6off,
    lc_or6port,
    lc_or7form,
    lc_or7off,
    lc_or7port,
    lc_plevnr,
    lc_plforce,
    lc_rcpform,
    lc_rcpoff,
    lc_rcpport,
    lc_slpform,
    lc_slpoff,
    lc_slpport
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lc_begin   location.lc_begin,
    lc_deleted location.lc_deleted,
    lc_deptnr  location.lc_deptnr,
    lc_descr   location.lc_descr,
    lc_dscform location.lc_dscform,
    lc_dscoff  location.lc_dscoff,
    lc_dscport location.lc_dscport,
    lc_end     location.lc_end,
    lc_feat1   location.lc_feat1,
    lc_feat2   location.lc_feat2,
    lc_feat3   location.lc_feat3,
    lc_feat4   location.lc_feat4,
    lc_feat5   location.lc_feat5,
    lc_locnr   location.lc_locnr,
    lc_or1form location.lc_or1form,
    lc_or1off  location.lc_or1off,
    lc_or1port location.lc_or1port,
    lc_or2form location.lc_or2form,
    lc_or2off  location.lc_or2off,
    lc_or2port location.lc_or2port,
    lc_or3form location.lc_or3form,
    lc_or3off  location.lc_or3off,
    lc_or3port location.lc_or3port,
    lc_or4form location.lc_or4form,
    lc_or4off  location.lc_or4off,
    lc_or4port location.lc_or4port,
    lc_or5form location.lc_or5form,
    lc_or5off  location.lc_or5off,
    lc_or5port location.lc_or5port,
    lc_or6form location.lc_or6form,
    lc_or6off  location.lc_or6off,
    lc_or6port location.lc_or6port,
    lc_or7form location.lc_or7form,
    lc_or7off  location.lc_or7off,
    lc_or7port location.lc_or7port,
    lc_plevnr  location.lc_plevnr,
    lc_plforce location.lc_plforce,
    lc_rcpform location.lc_rcpform,
    lc_rcpoff  location.lc_rcpoff,
    lc_rcpport location.lc_rcpport,
    lc_slpform location.lc_slpform,
    lc_slpoff  location.lc_slpoff,
    lc_slpport location.lc_slpport
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS calogger AS caBase OF common\libs\cit_ca.vcx
Alias = [calogger]
Tables = [logger]
KeyFieldList = [lg_lgid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       lg_action,
       lg_changes,
       lg_lgid,
       lg_newkey,
       lg_oldkey,
       lg_table,
       lg_user,
       lg_when
    FROM logger
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    lg_action  C(1)    DEFAULT "",
    lg_changes M       DEFAULT "",
    lg_lgid    I       DEFAULT 0,
    lg_newkey  C(25)   DEFAULT "",
    lg_oldkey  C(25)   DEFAULT "",
    lg_table   C(10)   DEFAULT "",
    lg_user    C(3)    DEFAULT "",
    lg_when    T       DEFAULT {}
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lg_action,
    lg_changes,
    lg_lgid,
    lg_newkey,
    lg_oldkey,
    lg_table,
    lg_user,
    lg_when
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lg_action  logger.lg_action,
    lg_changes logger.lg_changes,
    lg_lgid    logger.lg_lgid,
    lg_newkey  logger.lg_newkey,
    lg_oldkey  logger.lg_oldkey,
    lg_table   logger.lg_table,
    lg_user    logger.lg_user,
    lg_when    logger.lg_when
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camaingrp AS caBase OF common\libs\cit_ca.vcx
Alias = [camaingrp]
Tables = [maingrp]
KeyFieldList = [mn_mainnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       mn_deleted,
       mn_descr,
       mn_mainnr
    FROM maingrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    mn_deleted L       DEFAULT .F.,
    mn_descr   C(20)   DEFAULT "",
    mn_mainnr  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mn_deleted,
    mn_descr,
    mn_mainnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mn_deleted maingrp.mn_deleted,
    mn_descr   maingrp.mn_descr,
    mn_mainnr  maingrp.mn_mainnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camenudata AS caBase OF common\libs\cit_ca.vcx
Alias = [camenudata]
Tables = [menudata]
KeyFieldList = [md_menuid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       md_command,
       md_menuid,
       md_order,
       md_parent,
       md_picture,
       md_text
    FROM menudata
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    md_command C(254)  DEFAULT "",
    md_menuid  N(5,0)  DEFAULT 0,
    md_order   N(4,0)  DEFAULT 0,
    md_parent  N(5,0)  DEFAULT 0,
    md_picture C(254)  DEFAULT "",
    md_text    C(32)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    md_command,
    md_menuid,
    md_order,
    md_parent,
    md_picture,
    md_text
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    md_command menudata.md_command,
    md_menuid  menudata.md_menuid,
    md_order   menudata.md_order,
    md_parent  menudata.md_parent,
    md_picture menudata.md_picture,
    md_text    menudata.md_text
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camessage AS caBase OF common\libs\cit_ca.vcx
Alias = [camessage]
Tables = [message]
KeyFieldList = [ms_msgid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ms_cut,
       ms_deleted,
       ms_descr,
       ms_msgid,
       ms_red,
       ms_sequenc
    FROM message
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ms_cut     L       DEFAULT .F.,
    ms_deleted L       DEFAULT .F.,
    ms_descr   C(20)   DEFAULT "",
    ms_msgid   I       DEFAULT 0,
    ms_red     L       DEFAULT .F.,
    ms_sequenc N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ms_cut,
    ms_deleted,
    ms_descr,
    ms_msgid,
    ms_red,
    ms_sequenc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ms_cut     message.ms_cut,
    ms_deleted message.ms_deleted,
    ms_descr   message.ms_descr,
    ms_msgid   message.ms_msgid,
    ms_red     message.ms_red,
    ms_sequenc message.ms_sequenc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camodifgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [camodifgrp]
Tables = [modifgrp]
KeyFieldList = [mg_modgid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       mg_askqty,
       mg_deleted,
       mg_descr,
       mg_modgid,
       mg_multsel
    FROM modifgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_askqty  L       DEFAULT .F.,
    mg_deleted L       DEFAULT .F.,
    mg_descr   C(20)   DEFAULT "",
    mg_modgid  I       DEFAULT 0,
    mg_multsel L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_askqty,
    mg_deleted,
    mg_descr,
    mg_modgid,
    mg_multsel
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mg_askqty  modifgrp.mg_askqty,
    mg_deleted modifgrp.mg_deleted,
    mg_descr   modifgrp.mg_descr,
    mg_modgid  modifgrp.mg_modgid,
    mg_multsel modifgrp.mg_multsel
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS camodifier AS caBase OF common\libs\cit_ca.vcx
Alias = [camodifier]
Tables = [modifier]
KeyFieldList = [mf_modid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       mf_artid,
       mf_deleted,
       mf_descr,
       mf_modgid,
       mf_modid,
       mf_qtylmt,
       mf_red,
       mf_sequenc
    FROM modifier
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    mf_artid   I       DEFAULT 0,
    mf_deleted L       DEFAULT .F.,
    mf_descr   C(20)   DEFAULT "",
    mf_modgid  I       DEFAULT 0,
    mf_modid   I       DEFAULT 0,
    mf_qtylmt  L       DEFAULT .F.,
    mf_red     L       DEFAULT .F.,
    mf_sequenc N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mf_artid,
    mf_deleted,
    mf_descr,
    mf_modgid,
    mf_modid,
    mf_qtylmt,
    mf_red,
    mf_sequenc
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    mf_artid   modifier.mf_artid,
    mf_deleted modifier.mf_deleted,
    mf_descr   modifier.mf_descr,
    mf_modgid  modifier.mf_modgid,
    mf_modid   modifier.mf_modid,
    mf_qtylmt  modifier.mf_qtylmt,
    mf_red     modifier.mf_red,
    mf_sequenc modifier.mf_sequenc
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caordcard AS caBase OF common\libs\cit_ca.vcx
Alias = [caordcard]
Tables = [ordcard]
KeyFieldList = [oa_oaid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       oa_active,
       oa_cardno,
       oa_created,
       oa_oaid,
       oa_waitnr
    FROM ordcard
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    oa_active  L       DEFAULT .F.,
    oa_cardno  C(12)   DEFAULT "",
    oa_created T       DEFAULT {},
    oa_oaid    I       DEFAULT 0,
    oa_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oa_active,
    oa_cardno,
    oa_created,
    oa_oaid,
    oa_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oa_active  ordcard.oa_active,
    oa_cardno  ordcard.oa_cardno,
    oa_created ordcard.oa_created,
    oa_oaid    ordcard.oa_oaid,
    oa_waitnr  ordcard.oa_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caordcomp AS caBase OF common\libs\cit_ca.vcx
Alias = [caordcomp]
Tables = [ordcomp]
KeyFieldList = [oc_orcmpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       oc_amt,
       oc_artid,
       oc_compid,
       oc_mainnr,
       oc_orcmpid,
       oc_subnr,
       oc_vatnr,
       oc_vatpct
    FROM ordcomp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    oc_amt     Y       DEFAULT 0,
    oc_artid   I       DEFAULT 0,
    oc_compid  I       DEFAULT 0,
    oc_mainnr  N(2,0)  DEFAULT 0,
    oc_orcmpid I       DEFAULT 0,
    oc_subnr   N(4,0)  DEFAULT 0,
    oc_vatnr   N(1,0)  DEFAULT 0,
    oc_vatpct  N(4,1)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oc_amt,
    oc_artid,
    oc_compid,
    oc_mainnr,
    oc_orcmpid,
    oc_subnr,
    oc_vatnr,
    oc_vatpct
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    oc_amt     ordcomp.oc_amt,
    oc_artid   ordcomp.oc_artid,
    oc_compid  ordcomp.oc_compid,
    oc_mainnr  ordcomp.oc_mainnr,
    oc_orcmpid ordcomp.oc_orcmpid,
    oc_subnr   ordcomp.oc_subnr,
    oc_vatnr   ordcomp.oc_vatnr,
    oc_vatpct  ordcomp.oc_vatpct
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caorder AS caBase OF common\libs\cit_ca.vcx
Alias = [caorder]
Tables = [order]
KeyFieldList = [or_orderid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       or_artid,
       or_arttyp,
       or_chkid,
       or_compid,
       or_crwatnr,
       or_deptnr,
       or_discnr,
       or_discpct,
       or_ldescr,
       or_locnr,
       or_modid,
       or_oaid,
       or_orderid,
       or_ordlsid,
       or_plevnr,
       or_posted,
       or_prc,
       or_qty,
       or_readid,
       or_rreason,
       or_sdescr,
       or_seatnr,
       or_sortnr,
       or_spilnr,
       or_supplem,
       or_sysdate,
       or_tablenr,
       or_termnr,
       or_timznnr,
       or_touched,
       or_voucnum,
       or_waitnr
    FROM order
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_artid   I       DEFAULT 0,
    or_arttyp  N(1,0)  DEFAULT 0,
    or_chkid   I       DEFAULT 0,
    or_compid  I       DEFAULT 0,
    or_crwatnr N(3,0)  DEFAULT 0,
    or_deptnr  N(2,0)  DEFAULT 0,
    or_discnr  N(2,0)  DEFAULT 0,
    or_discpct N(3,0)  DEFAULT 0,
    or_ldescr  C(40)   DEFAULT "",
    or_locnr   N(2,0)  DEFAULT 0,
    or_modid   I       DEFAULT 0,
    or_oaid    I       DEFAULT 0,
    or_orderid I       DEFAULT 0,
    or_ordlsid I       DEFAULT 0,
    or_plevnr  N(1,0)  DEFAULT 0,
    or_posted  T       DEFAULT {},
    or_prc     Y       DEFAULT 0,
    or_qty     N(8,3)  DEFAULT 0,
    or_readid  I       DEFAULT 0,
    or_rreason C(50)   DEFAULT "",
    or_sdescr  C(20)   DEFAULT "",
    or_seatnr  I       DEFAULT 0,
    or_sortnr  N(2,0)  DEFAULT 0,
    or_spilnr  N(2,0)  DEFAULT 0,
    or_supplem C(30)   DEFAULT "",
    or_sysdate D       DEFAULT {},
    or_tablenr N(4,0)  DEFAULT 0,
    or_termnr  N(2,0)  DEFAULT 0,
    or_timznnr N(2,0)  DEFAULT 0,
    or_touched L       DEFAULT .F.,
    or_voucnum N(10,0) DEFAULT 0,
    or_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_artid,
    or_arttyp,
    or_chkid,
    or_compid,
    or_crwatnr,
    or_deptnr,
    or_discnr,
    or_discpct,
    or_ldescr,
    or_locnr,
    or_modid,
    or_oaid,
    or_orderid,
    or_ordlsid,
    or_plevnr,
    or_posted,
    or_prc,
    or_qty,
    or_readid,
    or_rreason,
    or_sdescr,
    or_seatnr,
    or_sortnr,
    or_spilnr,
    or_supplem,
    or_sysdate,
    or_tablenr,
    or_termnr,
    or_timznnr,
    or_touched,
    or_voucnum,
    or_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    or_artid   order.or_artid,
    or_arttyp  order.or_arttyp,
    or_chkid   order.or_chkid,
    or_compid  order.or_compid,
    or_crwatnr order.or_crwatnr,
    or_deptnr  order.or_deptnr,
    or_discnr  order.or_discnr,
    or_discpct order.or_discpct,
    or_ldescr  order.or_ldescr,
    or_locnr   order.or_locnr,
    or_modid   order.or_modid,
    or_oaid    order.or_oaid,
    or_orderid order.or_orderid,
    or_ordlsid order.or_ordlsid,
    or_plevnr  order.or_plevnr,
    or_posted  order.or_posted,
    or_prc     order.or_prc,
    or_qty     order.or_qty,
    or_readid  order.or_readid,
    or_rreason order.or_rreason,
    or_sdescr  order.or_sdescr,
    or_seatnr  order.or_seatnr,
    or_sortnr  order.or_sortnr,
    or_spilnr  order.or_spilnr,
    or_supplem order.or_supplem,
    or_sysdate order.or_sysdate,
    or_tablenr order.or_tablenr,
    or_termnr  order.or_termnr,
    or_timznnr order.or_timznnr,
    or_touched order.or_touched,
    or_voucnum order.or_voucnum,
    or_waitnr  order.or_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caparam AS caBase OF common\libs\cit_ca.vcx
Alias = [caparam]
Tables = [param]
KeyFieldList = [pa_paid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pa_arefres,
       pa_bmspay,
       pa_cash,
       pa_cashctr,
       pa_cdsclos,
       pa_cdslin1,
       pa_cdslin2,
       pa_chkcol0,
       pa_chkcol1,
       pa_chkcol2,
       pa_chklim1,
       pa_chklim2,
       pa_compdet,
       pa_covrea,
       pa_custinc,
       pa_custvat,
       pa_cwhour0,
       pa_cwhour1,
       pa_cwhour2,
       pa_cwhour3,
       pa_cxlobil,
       pa_dbver,
       pa_dpart11,
       pa_dpart12,
       pa_dpart21,
       pa_dpart22,
       pa_dpart31,
       pa_dpart32,
       pa_dpend,
       pa_dpstart,
       pa_ean2sca,
       pa_ean2sum,
       pa_extinve,
       pa_fiscprt,
       pa_foadr,
       pa_foart,
       pa_foaze,
       pa_focashi,
       pa_fodir,
       pa_folang,
       pa_folink,
       pa_fonovat,
       pa_fopay,
       pa_fopayde,
       pa_foqroom,
       pa_foz,
       pa_holddat,
       pa_idxlast,
       pa_infcurr,
       pa_inputid,
       pa_isocurr,
       pa_kclen,
       pa_kcstart,
       pa_lastpm,
       pa_licaddr,
       pa_liccity,
       pa_licexp2,
       pa_licexpy,
       pa_licname,
       pa_licnr,
       pa_licopt,
       pa_locale,
       pa_loggers,
       pa_logsize,
       pa_manprnt,
       pa_maxterm,
       pa_maxuser,
       pa_noprcia,
       pa_orwrite,
       pa_paid,
       pa_perplev,
       pa_plevvat,
       pa_point,
       pa_prtloc,
       pa_sendart,
       pa_shortx,
       pa_sortord,
       pa_sysdate,
       pa_tblwait,
       pa_tkround,
       pa_trandet,
       pa_updwait,
       pa_wbautoc,
       pa_wbmin,
       pa_wbmin1,
       pa_wbmin2,
       pa_wbmin3,
       pa_wimax,
       pa_wrndmin,
       pa_wtrevn,
       pa_xpay,
       pa_xrev,
       pa_yearchk,
       pa_z1bank,
       pa_z1opntb,
       pa_z1rev,
       pa_z2bank,
       pa_z2crcpt,
       pa_z2int,
       pa_z2last,
       pa_z2opntb,
       pa_z2pay,
       pa_z2rev,
       pa_zpdisc,
       pa_zpopntb,
       pa_zprefnd,
       pa_zpspil
    FROM param
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_arefres L       DEFAULT .F.,
    pa_bmspay  N(2,0)  DEFAULT 0,
    pa_cash    N(2,0)  DEFAULT 0,
    pa_cashctr L       DEFAULT .F.,
    pa_cdsclos C(20)   DEFAULT "",
    pa_cdslin1 C(20)   DEFAULT "",
    pa_cdslin2 C(20)   DEFAULT "",
    pa_chkcol0 I       DEFAULT 0,
    pa_chkcol1 I       DEFAULT 0,
    pa_chkcol2 I       DEFAULT 0,
    pa_chklim1 N(4,0)  DEFAULT 0,
    pa_chklim2 N(4,0)  DEFAULT 0,
    pa_compdet L       DEFAULT .F.,
    pa_covrea  L       DEFAULT .F.,
    pa_custinc N(3,0)  DEFAULT 0,
    pa_custvat L       DEFAULT .F.,
    pa_cwhour0 N(2,0)  DEFAULT 0,
    pa_cwhour1 N(2,0)  DEFAULT 0,
    pa_cwhour2 N(2,0)  DEFAULT 0,
    pa_cwhour3 N(2,0)  DEFAULT 0,
    pa_cxlobil L       DEFAULT .F.,
    pa_dbver   C(10)   DEFAULT "",
    pa_dpart11 C(5)    DEFAULT "",
    pa_dpart12 C(5)    DEFAULT "",
    pa_dpart21 C(5)    DEFAULT "",
    pa_dpart22 C(5)    DEFAULT "",
    pa_dpart31 C(5)    DEFAULT "",
    pa_dpart32 C(5)    DEFAULT "",
    pa_dpend   N(2,0)  DEFAULT 0,
    pa_dpstart N(2,0)  DEFAULT 0,
    pa_ean2sca C(30)   DEFAULT "",
    pa_ean2sum C(30)   DEFAULT "",
    pa_extinve L       DEFAULT .F.,
    pa_fiscprt C(6)    DEFAULT "",
    pa_foadr   L       DEFAULT .F.,
    pa_foart   N(4,0)  DEFAULT 0,
    pa_foaze   L       DEFAULT .F.,
    pa_focashi N(2,0)  DEFAULT 0,
    pa_fodir   C(60)   DEFAULT "",
    pa_folang  N(1,0)  DEFAULT 0,
    pa_folink  L       DEFAULT .F.,
    pa_fonovat L       DEFAULT .F.,
    pa_fopay   N(2,0)  DEFAULT 0,
    pa_fopayde L       DEFAULT .F.,
    pa_foqroom L       DEFAULT .F.,
    pa_foz     L       DEFAULT .F.,
    pa_holddat N(2,0)  DEFAULT 0,
    pa_idxlast D       DEFAULT {},
    pa_infcurr C(3)    DEFAULT "",
    pa_inputid I       DEFAULT 0,
    pa_isocurr C(3)    DEFAULT "",
    pa_kclen   N(2,0)  DEFAULT 0,
    pa_kcstart N(2,0)  DEFAULT 0,
    pa_lastpm  L       DEFAULT .F.,
    pa_licaddr C(40)   DEFAULT "",
    pa_liccity C(40)   DEFAULT "",
    pa_licexp2 L       DEFAULT .F.,
    pa_licexpy D       DEFAULT {},
    pa_licname C(50)   DEFAULT "",
    pa_licnr   B(0)    DEFAULT 0,
    pa_licopt  C(40)   DEFAULT "",
    pa_locale  C(2)    DEFAULT "",
    pa_loggers N(5,0)  DEFAULT 0,
    pa_logsize N(6,0)  DEFAULT 0,
    pa_manprnt N(1,0)  DEFAULT 0,
    pa_maxterm N(2,0)  DEFAULT 0,
    pa_maxuser N(1,0)  DEFAULT 0,
    pa_noprcia L       DEFAULT .F.,
    pa_orwrite L       DEFAULT .F.,
    pa_paid    N(1,0)  DEFAULT 0,
    pa_perplev L       DEFAULT .F.,
    pa_plevvat L       DEFAULT .F.,
    pa_point   C(1)    DEFAULT "",
    pa_prtloc  L       DEFAULT .F.,
    pa_sendart D       DEFAULT {},
    pa_shortx  L       DEFAULT .F.,
    pa_sortord L       DEFAULT .F.,
    pa_sysdate D       DEFAULT {},
    pa_tblwait L       DEFAULT .F.,
    pa_tkround N(2,0)  DEFAULT 0,
    pa_trandet L       DEFAULT .F.,
    pa_updwait L       DEFAULT .F.,
    pa_wbautoc L       DEFAULT .F.,
    pa_wbmin   N(3,0)  DEFAULT 0,
    pa_wbmin1  N(3,0)  DEFAULT 0,
    pa_wbmin2  N(3,0)  DEFAULT 0,
    pa_wbmin3  N(3,0)  DEFAULT 0,
    pa_wimax   N(2,0)  DEFAULT 0,
    pa_wrndmin N(2,0)  DEFAULT 0,
    pa_wtrevn  L       DEFAULT .F.,
    pa_xpay    N(1,0)  DEFAULT 0,
    pa_xrev    N(1,0)  DEFAULT 0,
    pa_yearchk L       DEFAULT .F.,
    pa_z1bank  L       DEFAULT .F.,
    pa_z1opntb L       DEFAULT .F.,
    pa_z1rev   N(1,0)  DEFAULT 0,
    pa_z2bank  L       DEFAULT .F.,
    pa_z2crcpt L       DEFAULT .F.,
    pa_z2int   N(2,0)  DEFAULT 0,
    pa_z2last  T       DEFAULT {},
    pa_z2opntb L       DEFAULT .F.,
    pa_z2pay   N(1,0)  DEFAULT 0,
    pa_z2rev   N(1,0)  DEFAULT 0,
    pa_zpdisc  L       DEFAULT .F.,
    pa_zpopntb L       DEFAULT .F.,
    pa_zprefnd L       DEFAULT .F.,
    pa_zpspil  L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_arefres,
    pa_bmspay,
    pa_cash,
    pa_cashctr,
    pa_cdsclos,
    pa_cdslin1,
    pa_cdslin2,
    pa_chkcol0,
    pa_chkcol1,
    pa_chkcol2,
    pa_chklim1,
    pa_chklim2,
    pa_compdet,
    pa_covrea,
    pa_custinc,
    pa_custvat,
    pa_cwhour0,
    pa_cwhour1,
    pa_cwhour2,
    pa_cwhour3,
    pa_cxlobil,
    pa_dbver,
    pa_dpart11,
    pa_dpart12,
    pa_dpart21,
    pa_dpart22,
    pa_dpart31,
    pa_dpart32,
    pa_dpend,
    pa_dpstart,
    pa_ean2sca,
    pa_ean2sum,
    pa_extinve,
    pa_fiscprt,
    pa_foadr,
    pa_foart,
    pa_foaze,
    pa_focashi,
    pa_fodir,
    pa_folang,
    pa_folink,
    pa_fonovat,
    pa_fopay,
    pa_fopayde,
    pa_foqroom,
    pa_foz,
    pa_holddat,
    pa_idxlast,
    pa_infcurr,
    pa_inputid,
    pa_isocurr,
    pa_kclen,
    pa_kcstart,
    pa_lastpm,
    pa_licaddr,
    pa_liccity,
    pa_licexp2,
    pa_licexpy,
    pa_licname,
    pa_licnr,
    pa_licopt,
    pa_locale,
    pa_loggers,
    pa_logsize,
    pa_manprnt,
    pa_maxterm,
    pa_maxuser,
    pa_noprcia,
    pa_orwrite,
    pa_paid,
    pa_perplev,
    pa_plevvat,
    pa_point,
    pa_prtloc,
    pa_sendart,
    pa_shortx,
    pa_sortord,
    pa_sysdate,
    pa_tblwait,
    pa_tkround,
    pa_trandet,
    pa_updwait,
    pa_wbautoc,
    pa_wbmin,
    pa_wbmin1,
    pa_wbmin2,
    pa_wbmin3,
    pa_wimax,
    pa_wrndmin,
    pa_wtrevn,
    pa_xpay,
    pa_xrev,
    pa_yearchk,
    pa_z1bank,
    pa_z1opntb,
    pa_z1rev,
    pa_z2bank,
    pa_z2crcpt,
    pa_z2int,
    pa_z2last,
    pa_z2opntb,
    pa_z2pay,
    pa_z2rev,
    pa_zpdisc,
    pa_zpopntb,
    pa_zprefnd,
    pa_zpspil
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pa_arefres param.pa_arefres,
    pa_bmspay  param.pa_bmspay,
    pa_cash    param.pa_cash,
    pa_cashctr param.pa_cashctr,
    pa_cdsclos param.pa_cdsclos,
    pa_cdslin1 param.pa_cdslin1,
    pa_cdslin2 param.pa_cdslin2,
    pa_chkcol0 param.pa_chkcol0,
    pa_chkcol1 param.pa_chkcol1,
    pa_chkcol2 param.pa_chkcol2,
    pa_chklim1 param.pa_chklim1,
    pa_chklim2 param.pa_chklim2,
    pa_compdet param.pa_compdet,
    pa_covrea  param.pa_covrea,
    pa_custinc param.pa_custinc,
    pa_custvat param.pa_custvat,
    pa_cwhour0 param.pa_cwhour0,
    pa_cwhour1 param.pa_cwhour1,
    pa_cwhour2 param.pa_cwhour2,
    pa_cwhour3 param.pa_cwhour3,
    pa_cxlobil param.pa_cxlobil,
    pa_dbver   param.pa_dbver,
    pa_dpart11 param.pa_dpart11,
    pa_dpart12 param.pa_dpart12,
    pa_dpart21 param.pa_dpart21,
    pa_dpart22 param.pa_dpart22,
    pa_dpart31 param.pa_dpart31,
    pa_dpart32 param.pa_dpart32,
    pa_dpend   param.pa_dpend,
    pa_dpstart param.pa_dpstart,
    pa_ean2sca param.pa_ean2sca,
    pa_ean2sum param.pa_ean2sum,
    pa_extinve param.pa_extinve,
    pa_fiscprt param.pa_fiscprt,
    pa_foadr   param.pa_foadr,
    pa_foart   param.pa_foart,
    pa_foaze   param.pa_foaze,
    pa_focashi param.pa_focashi,
    pa_fodir   param.pa_fodir,
    pa_folang  param.pa_folang,
    pa_folink  param.pa_folink,
    pa_fonovat param.pa_fonovat,
    pa_fopay   param.pa_fopay,
    pa_fopayde param.pa_fopayde,
    pa_foqroom param.pa_foqroom,
    pa_foz     param.pa_foz,
    pa_holddat param.pa_holddat,
    pa_idxlast param.pa_idxlast,
    pa_infcurr param.pa_infcurr,
    pa_inputid param.pa_inputid,
    pa_isocurr param.pa_isocurr,
    pa_kclen   param.pa_kclen,
    pa_kcstart param.pa_kcstart,
    pa_lastpm  param.pa_lastpm,
    pa_licaddr param.pa_licaddr,
    pa_liccity param.pa_liccity,
    pa_licexp2 param.pa_licexp2,
    pa_licexpy param.pa_licexpy,
    pa_licname param.pa_licname,
    pa_licnr   param.pa_licnr,
    pa_licopt  param.pa_licopt,
    pa_locale  param.pa_locale,
    pa_loggers param.pa_loggers,
    pa_logsize param.pa_logsize,
    pa_manprnt param.pa_manprnt,
    pa_maxterm param.pa_maxterm,
    pa_maxuser param.pa_maxuser,
    pa_noprcia param.pa_noprcia,
    pa_orwrite param.pa_orwrite,
    pa_paid    param.pa_paid,
    pa_perplev param.pa_perplev,
    pa_plevvat param.pa_plevvat,
    pa_point   param.pa_point,
    pa_prtloc  param.pa_prtloc,
    pa_sendart param.pa_sendart,
    pa_shortx  param.pa_shortx,
    pa_sortord param.pa_sortord,
    pa_sysdate param.pa_sysdate,
    pa_tblwait param.pa_tblwait,
    pa_tkround param.pa_tkround,
    pa_trandet param.pa_trandet,
    pa_updwait param.pa_updwait,
    pa_wbautoc param.pa_wbautoc,
    pa_wbmin   param.pa_wbmin,
    pa_wbmin1  param.pa_wbmin1,
    pa_wbmin2  param.pa_wbmin2,
    pa_wbmin3  param.pa_wbmin3,
    pa_wimax   param.pa_wimax,
    pa_wrndmin param.pa_wrndmin,
    pa_wtrevn  param.pa_wtrevn,
    pa_xpay    param.pa_xpay,
    pa_xrev    param.pa_xrev,
    pa_yearchk param.pa_yearchk,
    pa_z1bank  param.pa_z1bank,
    pa_z1opntb param.pa_z1opntb,
    pa_z1rev   param.pa_z1rev,
    pa_z2bank  param.pa_z2bank,
    pa_z2crcpt param.pa_z2crcpt,
    pa_z2int   param.pa_z2int,
    pa_z2last  param.pa_z2last,
    pa_z2opntb param.pa_z2opntb,
    pa_z2pay   param.pa_z2pay,
    pa_z2rev   param.pa_z2rev,
    pa_zpdisc  param.pa_zpdisc,
    pa_zpopntb param.pa_zpopntb,
    pa_zprefnd param.pa_zprefnd,
    pa_zpspil  param.pa_zpspil
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capaygrp AS caBase OF common\libs\cit_ca.vcx
Alias = [capaygrp]
Tables = [paygrp]
KeyFieldList = [pg_paygnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pg_deleted,
       pg_descr,
       pg_paygnr
    FROM paygrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pg_deleted L       DEFAULT .F.,
    pg_descr   C(20)   DEFAULT "",
    pg_paygnr  N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pg_deleted,
    pg_descr,
    pg_paygnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pg_deleted paygrp.pg_deleted,
    pg_descr   paygrp.pg_descr,
    pg_paygnr  paygrp.pg_paygnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capayment AS caBase OF common\libs\cit_ca.vcx
Alias = [capayment]
Tables = [payment]
KeyFieldList = [py_paymid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       py_amt,
       py_chkid,
       py_crwatnr,
       py_curramt,
       py_deptnr,
       py_f2chkid,
       py_flag,
       py_paygnr,
       py_paymid,
       py_paynr,
       py_paytyp,
       py_posted,
       py_rate,
       py_readid,
       py_rreason,
       py_sysdate,
       py_termnr,
       py_text,
       py_void,
       py_waitnr,
       py_xreadid
    FROM payment
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    py_amt     Y       DEFAULT 0,
    py_chkid   I       DEFAULT 0,
    py_crwatnr N(3,0)  DEFAULT 0,
    py_curramt Y       DEFAULT 0,
    py_deptnr  N(2,0)  DEFAULT 0,
    py_f2chkid I       DEFAULT 0,
    py_flag    N(1,0)  DEFAULT 0,
    py_paygnr  N(1,0)  DEFAULT 0,
    py_paymid  I       DEFAULT 0,
    py_paynr   N(2,0)  DEFAULT 0,
    py_paytyp  N(1,0)  DEFAULT 0,
    py_posted  T       DEFAULT {},
    py_rate    N(13,6) DEFAULT 0,
    py_readid  I       DEFAULT 0,
    py_rreason C(50)   DEFAULT "",
    py_sysdate D       DEFAULT {},
    py_termnr  N(2,0)  DEFAULT 0,
    py_text    C(25)   DEFAULT "",
    py_void    L       DEFAULT .F.,
    py_waitnr  N(3,0)  DEFAULT 0,
    py_xreadid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    py_amt,
    py_chkid,
    py_crwatnr,
    py_curramt,
    py_deptnr,
    py_f2chkid,
    py_flag,
    py_paygnr,
    py_paymid,
    py_paynr,
    py_paytyp,
    py_posted,
    py_rate,
    py_readid,
    py_rreason,
    py_sysdate,
    py_termnr,
    py_text,
    py_void,
    py_waitnr,
    py_xreadid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    py_amt     payment.py_amt,
    py_chkid   payment.py_chkid,
    py_crwatnr payment.py_crwatnr,
    py_curramt payment.py_curramt,
    py_deptnr  payment.py_deptnr,
    py_f2chkid payment.py_f2chkid,
    py_flag    payment.py_flag,
    py_paygnr  payment.py_paygnr,
    py_paymid  payment.py_paymid,
    py_paynr   payment.py_paynr,
    py_paytyp  payment.py_paytyp,
    py_posted  payment.py_posted,
    py_rate    payment.py_rate,
    py_readid  payment.py_readid,
    py_rreason payment.py_rreason,
    py_sysdate payment.py_sysdate,
    py_termnr  payment.py_termnr,
    py_text    payment.py_text,
    py_void    payment.py_void,
    py_waitnr  payment.py_waitnr,
    py_xreadid payment.py_xreadid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capaymeth AS caBase OF common\libs\cit_ca.vcx
Alias = [capaymeth]
Tables = [paymeth]
KeyFieldList = [pm_paynr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pm_active,
       pm_askdesc,
       pm_deleted,
       pm_descr,
       pm_dshowom,
       pm_elpay,
       pm_elpyman,
       pm_elpynum,
       pm_elpypad,
       pm_elpyza,
       pm_focashi,
       pm_fopay,
       pm_fppay,
       pm_ftpay,
       pm_isocurr,
       pm_minamt,
       pm_opendrw,
       pm_paygnr,
       pm_paynr,
       pm_paytyp,
       pm_prtcopy,
       pm_rate,
       pm_spilnr
    FROM paymeth
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pm_active  L       DEFAULT .F.,
    pm_askdesc L       DEFAULT .F.,
    pm_deleted L       DEFAULT .F.,
    pm_descr   C(20)   DEFAULT "",
    pm_dshowom L       DEFAULT .F.,
    pm_elpay   L       DEFAULT .F.,
    pm_elpyman L       DEFAULT .F.,
    pm_elpynum N(2,0)  DEFAULT 0,
    pm_elpypad L       DEFAULT .F.,
    pm_elpyza  C(2)    DEFAULT "",
    pm_focashi N(2,0)  DEFAULT 0,
    pm_fopay   N(2,0)  DEFAULT 0,
    pm_fppay   C(1)    DEFAULT "",
    pm_ftpay   C(2)    DEFAULT "",
    pm_isocurr C(3)    DEFAULT "",
    pm_minamt  Y       DEFAULT 0,
    pm_opendrw N(1,0)  DEFAULT 0,
    pm_paygnr  N(1,0)  DEFAULT 0,
    pm_paynr   N(2,0)  DEFAULT 0,
    pm_paytyp  N(1,0)  DEFAULT 0,
    pm_prtcopy N(1,0)  DEFAULT 0,
    pm_rate    N(13,6) DEFAULT 0,
    pm_spilnr  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pm_active,
    pm_askdesc,
    pm_deleted,
    pm_descr,
    pm_dshowom,
    pm_elpay,
    pm_elpyman,
    pm_elpynum,
    pm_elpypad,
    pm_elpyza,
    pm_focashi,
    pm_fopay,
    pm_fppay,
    pm_ftpay,
    pm_isocurr,
    pm_minamt,
    pm_opendrw,
    pm_paygnr,
    pm_paynr,
    pm_paytyp,
    pm_prtcopy,
    pm_rate,
    pm_spilnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pm_active  paymeth.pm_active,
    pm_askdesc paymeth.pm_askdesc,
    pm_deleted paymeth.pm_deleted,
    pm_descr   paymeth.pm_descr,
    pm_dshowom paymeth.pm_dshowom,
    pm_elpay   paymeth.pm_elpay,
    pm_elpyman paymeth.pm_elpyman,
    pm_elpynum paymeth.pm_elpynum,
    pm_elpypad paymeth.pm_elpypad,
    pm_elpyza  paymeth.pm_elpyza,
    pm_focashi paymeth.pm_focashi,
    pm_fopay   paymeth.pm_fopay,
    pm_fppay   paymeth.pm_fppay,
    pm_ftpay   paymeth.pm_ftpay,
    pm_isocurr paymeth.pm_isocurr,
    pm_minamt  paymeth.pm_minamt,
    pm_opendrw paymeth.pm_opendrw,
    pm_paygnr  paymeth.pm_paygnr,
    pm_paynr   paymeth.pm_paynr,
    pm_paytyp  paymeth.pm_paytyp,
    pm_prtcopy paymeth.pm_prtcopy,
    pm_rate    paymeth.pm_rate,
    pm_spilnr  paymeth.pm_spilnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capaytyp AS caBase OF common\libs\cit_ca.vcx
Alias = [capaytyp]
Tables = [paytyp]
KeyFieldList = [pt_paytyp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pt_de,
       pt_descr,
       pt_en,
       pt_nl,
       pt_paytyp,
       pt_rs
    FROM paytyp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pt_de      C(20)   DEFAULT "",
    pt_descr   C(20)   DEFAULT "",
    pt_en      C(20)   DEFAULT "",
    pt_nl      C(20)   DEFAULT "",
    pt_paytyp  N(1,0)  DEFAULT 0,
    pt_rs      C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pt_de,
    pt_descr,
    pt_en,
    pt_nl,
    pt_paytyp,
    pt_rs
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pt_de      paytyp.pt_de,
    pt_descr   paytyp.pt_descr,
    pt_en      paytyp.pt_en,
    pt_nl      paytyp.pt_nl,
    pt_paytyp  paytyp.pt_paytyp,
    pt_rs      paytyp.pt_rs
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caplanobjs AS caBase OF common\libs\cit_ca.vcx
Alias = [caplanobjs]
Tables = [planobjs]
KeyFieldList = [po_pobjid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       po_deleted,
       po_exit,
       po_goplid,
       po_otypid,
       po_planid,
       po_pobjid,
       po_size,
       po_tablenr,
       po_tabres,
       po_tblplan,
       po_xpos,
       po_ypos
    FROM planobjs
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    po_deleted L       DEFAULT .F.,
    po_exit    L       DEFAULT .F.,
    po_goplid  I       DEFAULT 0,
    po_otypid  I       DEFAULT 0,
    po_planid  I       DEFAULT 0,
    po_pobjid  I       DEFAULT 0,
    po_size    N(4,0)  DEFAULT 0,
    po_tablenr N(4,0)  DEFAULT 0,
    po_tabres  L       DEFAULT .F.,
    po_tblplan L       DEFAULT .F.,
    po_xpos    N(4,0)  DEFAULT 0,
    po_ypos    N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    po_deleted,
    po_exit,
    po_goplid,
    po_otypid,
    po_planid,
    po_pobjid,
    po_size,
    po_tablenr,
    po_tabres,
    po_tblplan,
    po_xpos,
    po_ypos
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    po_deleted planobjs.po_deleted,
    po_exit    planobjs.po_exit,
    po_goplid  planobjs.po_goplid,
    po_otypid  planobjs.po_otypid,
    po_planid  planobjs.po_planid,
    po_pobjid  planobjs.po_pobjid,
    po_size    planobjs.po_size,
    po_tablenr planobjs.po_tablenr,
    po_tabres  planobjs.po_tabres,
    po_tblplan planobjs.po_tblplan,
    po_xpos    planobjs.po_xpos,
    po_ypos    planobjs.po_ypos
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caplans AS caBase OF common\libs\cit_ca.vcx
Alias = [caplans]
Tables = [plans]
KeyFieldList = [pl_planid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pl_backcol,
       pl_deleted,
       pl_descr,
       pl_height,
       pl_left,
       pl_picture,
       pl_planid,
       pl_top,
       pl_width
    FROM plans
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pl_backcol I       DEFAULT 0,
    pl_deleted L       DEFAULT .F.,
    pl_descr   C(20)   DEFAULT "",
    pl_height  N(4,0)  DEFAULT 0,
    pl_left    N(4,0)  DEFAULT 0,
    pl_picture C(254)  DEFAULT "",
    pl_planid  I       DEFAULT 0,
    pl_top     N(4,0)  DEFAULT 0,
    pl_width   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pl_backcol,
    pl_deleted,
    pl_descr,
    pl_height,
    pl_left,
    pl_picture,
    pl_planid,
    pl_top,
    pl_width
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pl_backcol plans.pl_backcol,
    pl_deleted plans.pl_deleted,
    pl_descr   plans.pl_descr,
    pl_height  plans.pl_height,
    pl_left    plans.pl_left,
    pl_picture plans.pl_picture,
    pl_planid  plans.pl_planid,
    pl_top     plans.pl_top,
    pl_width   plans.pl_width
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caplobjtyp AS caBase OF common\libs\cit_ca.vcx
Alias = [caplobjtyp]
Tables = [plobjtyp]
KeyFieldList = [ot_otypid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ot_control,
       ot_descr,
       ot_otypid,
       ot_params
    FROM plobjtyp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ot_control C(20)   DEFAULT "",
    ot_descr   C(20)   DEFAULT "",
    ot_otypid  I       DEFAULT 0,
    ot_params  C(254)  DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ot_control,
    ot_descr,
    ot_otypid,
    ot_params
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ot_control plobjtyp.ot_control,
    ot_descr   plobjtyp.ot_descr,
    ot_otypid  plobjtyp.ot_otypid,
    ot_params  plobjtyp.ot_params
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capricelev AS caBase OF common\libs\cit_ca.vcx
Alias = [capricelev]
Tables = [pricelev]
KeyFieldList = [lv_plevnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       lv_deleted,
       lv_descr,
       lv_fpstd,
       lv_noopprc,
       lv_order,
       lv_plevnr,
       lv_plevvat
    FROM pricelev
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    lv_deleted L       DEFAULT .F.,
    lv_descr   C(20)   DEFAULT "",
    lv_fpstd   L       DEFAULT .F.,
    lv_noopprc L       DEFAULT .F.,
    lv_order   N(1,0)  DEFAULT 0,
    lv_plevnr  N(1,0)  DEFAULT 0,
    lv_plevvat N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lv_deleted,
    lv_descr,
    lv_fpstd,
    lv_noopprc,
    lv_order,
    lv_plevnr,
    lv_plevvat
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    lv_deleted pricelev.lv_deleted,
    lv_descr   pricelev.lv_descr,
    lv_fpstd   pricelev.lv_fpstd,
    lv_noopprc pricelev.lv_noopprc,
    lv_order   pricelev.lv_order,
    lv_plevnr  pricelev.lv_plevnr,
    lv_plevvat pricelev.lv_plevvat
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS capricescd AS caBase OF common\libs\cit_ca.vcx
Alias = [capricescd]
Tables = [pricescd]
KeyFieldList = [sd_pscdid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sd_begin,
       sd_dow,
       sd_end,
       sd_locnr,
       sd_plevnr,
       sd_pscdid
    FROM pricescd
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sd_begin   C(4)    DEFAULT "",
    sd_dow     N(1,0)  DEFAULT 0,
    sd_end     C(4)    DEFAULT "",
    sd_locnr   N(2,0)  DEFAULT 0,
    sd_plevnr  N(1,0)  DEFAULT 0,
    sd_pscdid  I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sd_begin,
    sd_dow,
    sd_end,
    sd_locnr,
    sd_plevnr,
    sd_pscdid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sd_begin   pricescd.sd_begin,
    sd_dow     pricescd.sd_dow,
    sd_end     pricescd.sd_end,
    sd_locnr   pricescd.sd_locnr,
    sd_plevnr  pricescd.sd_plevnr,
    sd_pscdid  pricescd.sd_pscdid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caprntdriv AS caBase OF common\libs\cit_ca.vcx
Alias = [caprntdriv]
Tables = [prntdriv]
KeyFieldList = [pd_prtdriv]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pd_blksize,
       pd_delay,
       pd_descr,
       pd_devdsc,
       pd_devrcp,
       pd_devslp,
       pd_ff,
       pd_font,
       pd_fullcut,
       pd_init,
       pd_lmargin,
       pd_partcut,
       pd_prtdriv,
       pd_reset,
       pd_stamp
    FROM prntdriv
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pd_blksize N(2,0)  DEFAULT 0,
    pd_delay   N(2,0)  DEFAULT 0,
    pd_descr   C(30)   DEFAULT "",
    pd_devdsc  M       DEFAULT "",
    pd_devrcp  M       DEFAULT "",
    pd_devslp  M       DEFAULT "",
    pd_ff      M       DEFAULT "",
    pd_font    M       DEFAULT "",
    pd_fullcut M       DEFAULT "",
    pd_init    M       DEFAULT "",
    pd_lmargin M       DEFAULT "",
    pd_partcut M       DEFAULT "",
    pd_prtdriv C(10)   DEFAULT "",
    pd_reset   M       DEFAULT "",
    pd_stamp   M       DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pd_blksize,
    pd_delay,
    pd_descr,
    pd_devdsc,
    pd_devrcp,
    pd_devslp,
    pd_ff,
    pd_font,
    pd_fullcut,
    pd_init,
    pd_lmargin,
    pd_partcut,
    pd_prtdriv,
    pd_reset,
    pd_stamp
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pd_blksize prntdriv.pd_blksize,
    pd_delay   prntdriv.pd_delay,
    pd_descr   prntdriv.pd_descr,
    pd_devdsc  prntdriv.pd_devdsc,
    pd_devrcp  prntdriv.pd_devrcp,
    pd_devslp  prntdriv.pd_devslp,
    pd_ff      prntdriv.pd_ff,
    pd_font    prntdriv.pd_font,
    pd_fullcut prntdriv.pd_fullcut,
    pd_init    prntdriv.pd_init,
    pd_lmargin prntdriv.pd_lmargin,
    pd_partcut prntdriv.pd_partcut,
    pd_prtdriv prntdriv.pd_prtdriv,
    pd_reset   prntdriv.pd_reset,
    pd_stamp   prntdriv.pd_stamp
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caprntform AS caBase OF common\libs\cit_ca.vcx
Alias = [caprntform]
Tables = [prntform]
KeyFieldList = [pf_prtform]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pf_art,
       pf_artcnd,
       pf_artdbh,
       pf_artdbw,
       pf_artemp,
       pf_art_x,
       pf_aticsep,
       pf_cols,
       pf_copyno,
       pf_cust,
       pf_custcnd,
       pf_custdbh,
       pf_custdbw,
       pf_custemp,
       pf_cust_x,
       pf_deleted,
       pf_descr,
       pf_disc,
       pf_disccnd,
       pf_discdbh,
       pf_discdbw,
       pf_discemp,
       pf_disc_x,
       pf_grposts,
       pf_head,
       pf_headcnd,
       pf_headdbh,
       pf_headdbw,
       pf_heademp,
       pf_head_x,
       pf_hval,
       pf_hvalcnd,
       pf_hvaldbh,
       pf_hvaldbw,
       pf_hvalemp,
       pf_hval_x,
       pf_lmargin,
       pf_margin,
       pf_margin1,
       pf_mod,
       pf_modcnd,
       pf_moddbh,
       pf_moddbw,
       pf_modemp,
       pf_mod_x,
       pf_net,
       pf_netcnd,
       pf_netdbh,
       pf_netdbw,
       pf_netemp,
       pf_netto,
       pf_netto_x,
       pf_net_x,
       pf_pay,
       pf_paycnd,
       pf_paydbh,
       pf_paydbw,
       pf_payemp,
       pf_pay_x,
       pf_prtform,
       pf_rows,
       pf_sort,
       pf_stamp,
       pf_summ,
       pf_summcnd,
       pf_summdbh,
       pf_summdbw,
       pf_summemp,
       pf_summ_x,
       pf_tart,
       pf_tartcnd,
       pf_tartdbh,
       pf_tartdbw,
       pf_tartemp,
       pf_tart_x,
       pf_tickets,
       pf_titl,
       pf_titlcnd,
       pf_titldbh,
       pf_titldbw,
       pf_titlemp,
       pf_titl_x,
       pf_trn,
       pf_trncnd,
       pf_trndbh,
       pf_trndbw,
       pf_trnemp,
       pf_trn_x,
       pf_val,
       pf_valcnd,
       pf_valdbh,
       pf_valdbw,
       pf_valemp,
       pf_validat,
       pf_val_x,
       pf_vat,
       pf_vatcnd,
       pf_vatdbh,
       pf_vatdbw,
       pf_vatemp,
       pf_vat_x
    FROM prntform
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pf_art     M       DEFAULT "",
    pf_artcnd  L       DEFAULT .F.,
    pf_artdbh  L       DEFAULT .F.,
    pf_artdbw  L       DEFAULT .F.,
    pf_artemp  L       DEFAULT .F.,
    pf_art_x   M       DEFAULT "",
    pf_aticsep L       DEFAULT .F.,
    pf_cols    N(2,0)  DEFAULT 0,
    pf_copyno  N(2,0)  DEFAULT 0,
    pf_cust    M       DEFAULT "",
    pf_custcnd L       DEFAULT .F.,
    pf_custdbh L       DEFAULT .F.,
    pf_custdbw L       DEFAULT .F.,
    pf_custemp L       DEFAULT .F.,
    pf_cust_x  M       DEFAULT "",
    pf_deleted L       DEFAULT .F.,
    pf_descr   C(20)   DEFAULT "",
    pf_disc    M       DEFAULT "",
    pf_disccnd L       DEFAULT .F.,
    pf_discdbh L       DEFAULT .F.,
    pf_discdbw L       DEFAULT .F.,
    pf_discemp L       DEFAULT .F.,
    pf_disc_x  M       DEFAULT "",
    pf_grposts L       DEFAULT .F.,
    pf_head    M       DEFAULT "",
    pf_headcnd L       DEFAULT .F.,
    pf_headdbh L       DEFAULT .F.,
    pf_headdbw L       DEFAULT .F.,
    pf_heademp L       DEFAULT .F.,
    pf_head_x  M       DEFAULT "",
    pf_hval    M       DEFAULT "",
    pf_hvalcnd L       DEFAULT .F.,
    pf_hvaldbh L       DEFAULT .F.,
    pf_hvaldbw L       DEFAULT .F.,
    pf_hvalemp L       DEFAULT .F.,
    pf_hval_x  M       DEFAULT "",
    pf_lmargin N(3,0)  DEFAULT 0,
    pf_margin  N(2,0)  DEFAULT 0,
    pf_margin1 N(2,0)  DEFAULT 0,
    pf_mod     M       DEFAULT "",
    pf_modcnd  L       DEFAULT .F.,
    pf_moddbh  L       DEFAULT .F.,
    pf_moddbw  L       DEFAULT .F.,
    pf_modemp  L       DEFAULT .F.,
    pf_mod_x   M       DEFAULT "",
    pf_net     M       DEFAULT "",
    pf_netcnd  L       DEFAULT .F.,
    pf_netdbh  L       DEFAULT .F.,
    pf_netdbw  L       DEFAULT .F.,
    pf_netemp  L       DEFAULT .F.,
    pf_netto   M       DEFAULT "",
    pf_netto_x M       DEFAULT "",
    pf_net_x   M       DEFAULT "",
    pf_pay     M       DEFAULT "",
    pf_paycnd  L       DEFAULT .F.,
    pf_paydbh  L       DEFAULT .F.,
    pf_paydbw  L       DEFAULT .F.,
    pf_payemp  L       DEFAULT .F.,
    pf_pay_x   M       DEFAULT "",
    pf_prtform C(10)   DEFAULT "",
    pf_rows    N(3,0)  DEFAULT 0,
    pf_sort    L       DEFAULT .F.,
    pf_stamp   L       DEFAULT .F.,
    pf_summ    M       DEFAULT "",
    pf_summcnd L       DEFAULT .F.,
    pf_summdbh L       DEFAULT .F.,
    pf_summdbw L       DEFAULT .F.,
    pf_summemp L       DEFAULT .F.,
    pf_summ_x  M       DEFAULT "",
    pf_tart    M       DEFAULT "",
    pf_tartcnd L       DEFAULT .F.,
    pf_tartdbh L       DEFAULT .F.,
    pf_tartdbw L       DEFAULT .F.,
    pf_tartemp L       DEFAULT .F.,
    pf_tart_x  M       DEFAULT "",
    pf_tickets N(1,0)  DEFAULT 0,
    pf_titl    M       DEFAULT "",
    pf_titlcnd L       DEFAULT .F.,
    pf_titldbh L       DEFAULT .F.,
    pf_titldbw L       DEFAULT .F.,
    pf_titlemp L       DEFAULT .F.,
    pf_titl_x  M       DEFAULT "",
    pf_trn     M       DEFAULT "",
    pf_trncnd  L       DEFAULT .F.,
    pf_trndbh  L       DEFAULT .F.,
    pf_trndbw  L       DEFAULT .F.,
    pf_trnemp  L       DEFAULT .F.,
    pf_trn_x   M       DEFAULT "",
    pf_val     M       DEFAULT "",
    pf_valcnd  L       DEFAULT .F.,
    pf_valdbh  L       DEFAULT .F.,
    pf_valdbw  L       DEFAULT .F.,
    pf_valemp  L       DEFAULT .F.,
    pf_validat L       DEFAULT .F.,
    pf_val_x   M       DEFAULT "",
    pf_vat     M       DEFAULT "",
    pf_vatcnd  L       DEFAULT .F.,
    pf_vatdbh  L       DEFAULT .F.,
    pf_vatdbw  L       DEFAULT .F.,
    pf_vatemp  L       DEFAULT .F.,
    pf_vat_x   M       DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pf_art,
    pf_artcnd,
    pf_artdbh,
    pf_artdbw,
    pf_artemp,
    pf_art_x,
    pf_aticsep,
    pf_cols,
    pf_copyno,
    pf_cust,
    pf_custcnd,
    pf_custdbh,
    pf_custdbw,
    pf_custemp,
    pf_cust_x,
    pf_deleted,
    pf_descr,
    pf_disc,
    pf_disccnd,
    pf_discdbh,
    pf_discdbw,
    pf_discemp,
    pf_disc_x,
    pf_grposts,
    pf_head,
    pf_headcnd,
    pf_headdbh,
    pf_headdbw,
    pf_heademp,
    pf_head_x,
    pf_hval,
    pf_hvalcnd,
    pf_hvaldbh,
    pf_hvaldbw,
    pf_hvalemp,
    pf_hval_x,
    pf_lmargin,
    pf_margin,
    pf_margin1,
    pf_mod,
    pf_modcnd,
    pf_moddbh,
    pf_moddbw,
    pf_modemp,
    pf_mod_x,
    pf_net,
    pf_netcnd,
    pf_netdbh,
    pf_netdbw,
    pf_netemp,
    pf_netto,
    pf_netto_x,
    pf_net_x,
    pf_pay,
    pf_paycnd,
    pf_paydbh,
    pf_paydbw,
    pf_payemp,
    pf_pay_x,
    pf_prtform,
    pf_rows,
    pf_sort,
    pf_stamp,
    pf_summ,
    pf_summcnd,
    pf_summdbh,
    pf_summdbw,
    pf_summemp,
    pf_summ_x,
    pf_tart,
    pf_tartcnd,
    pf_tartdbh,
    pf_tartdbw,
    pf_tartemp,
    pf_tart_x,
    pf_tickets,
    pf_titl,
    pf_titlcnd,
    pf_titldbh,
    pf_titldbw,
    pf_titlemp,
    pf_titl_x,
    pf_trn,
    pf_trncnd,
    pf_trndbh,
    pf_trndbw,
    pf_trnemp,
    pf_trn_x,
    pf_val,
    pf_valcnd,
    pf_valdbh,
    pf_valdbw,
    pf_valemp,
    pf_validat,
    pf_val_x,
    pf_vat,
    pf_vatcnd,
    pf_vatdbh,
    pf_vatdbw,
    pf_vatemp,
    pf_vat_x
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pf_art     prntform.pf_art,
    pf_artcnd  prntform.pf_artcnd,
    pf_artdbh  prntform.pf_artdbh,
    pf_artdbw  prntform.pf_artdbw,
    pf_artemp  prntform.pf_artemp,
    pf_art_x   prntform.pf_art_x,
    pf_aticsep prntform.pf_aticsep,
    pf_cols    prntform.pf_cols,
    pf_copyno  prntform.pf_copyno,
    pf_cust    prntform.pf_cust,
    pf_custcnd prntform.pf_custcnd,
    pf_custdbh prntform.pf_custdbh,
    pf_custdbw prntform.pf_custdbw,
    pf_custemp prntform.pf_custemp,
    pf_cust_x  prntform.pf_cust_x,
    pf_deleted prntform.pf_deleted,
    pf_descr   prntform.pf_descr,
    pf_disc    prntform.pf_disc,
    pf_disccnd prntform.pf_disccnd,
    pf_discdbh prntform.pf_discdbh,
    pf_discdbw prntform.pf_discdbw,
    pf_discemp prntform.pf_discemp,
    pf_disc_x  prntform.pf_disc_x,
    pf_grposts prntform.pf_grposts,
    pf_head    prntform.pf_head,
    pf_headcnd prntform.pf_headcnd,
    pf_headdbh prntform.pf_headdbh,
    pf_headdbw prntform.pf_headdbw,
    pf_heademp prntform.pf_heademp,
    pf_head_x  prntform.pf_head_x,
    pf_hval    prntform.pf_hval,
    pf_hvalcnd prntform.pf_hvalcnd,
    pf_hvaldbh prntform.pf_hvaldbh,
    pf_hvaldbw prntform.pf_hvaldbw,
    pf_hvalemp prntform.pf_hvalemp,
    pf_hval_x  prntform.pf_hval_x,
    pf_lmargin prntform.pf_lmargin,
    pf_margin  prntform.pf_margin,
    pf_margin1 prntform.pf_margin1,
    pf_mod     prntform.pf_mod,
    pf_modcnd  prntform.pf_modcnd,
    pf_moddbh  prntform.pf_moddbh,
    pf_moddbw  prntform.pf_moddbw,
    pf_modemp  prntform.pf_modemp,
    pf_mod_x   prntform.pf_mod_x,
    pf_net     prntform.pf_net,
    pf_netcnd  prntform.pf_netcnd,
    pf_netdbh  prntform.pf_netdbh,
    pf_netdbw  prntform.pf_netdbw,
    pf_netemp  prntform.pf_netemp,
    pf_netto   prntform.pf_netto,
    pf_netto_x prntform.pf_netto_x,
    pf_net_x   prntform.pf_net_x,
    pf_pay     prntform.pf_pay,
    pf_paycnd  prntform.pf_paycnd,
    pf_paydbh  prntform.pf_paydbh,
    pf_paydbw  prntform.pf_paydbw,
    pf_payemp  prntform.pf_payemp,
    pf_pay_x   prntform.pf_pay_x,
    pf_prtform prntform.pf_prtform,
    pf_rows    prntform.pf_rows,
    pf_sort    prntform.pf_sort,
    pf_stamp   prntform.pf_stamp,
    pf_summ    prntform.pf_summ,
    pf_summcnd prntform.pf_summcnd,
    pf_summdbh prntform.pf_summdbh,
    pf_summdbw prntform.pf_summdbw,
    pf_summemp prntform.pf_summemp,
    pf_summ_x  prntform.pf_summ_x,
    pf_tart    prntform.pf_tart,
    pf_tartcnd prntform.pf_tartcnd,
    pf_tartdbh prntform.pf_tartdbh,
    pf_tartdbw prntform.pf_tartdbw,
    pf_tartemp prntform.pf_tartemp,
    pf_tart_x  prntform.pf_tart_x,
    pf_tickets prntform.pf_tickets,
    pf_titl    prntform.pf_titl,
    pf_titlcnd prntform.pf_titlcnd,
    pf_titldbh prntform.pf_titldbh,
    pf_titldbw prntform.pf_titldbw,
    pf_titlemp prntform.pf_titlemp,
    pf_titl_x  prntform.pf_titl_x,
    pf_trn     prntform.pf_trn,
    pf_trncnd  prntform.pf_trncnd,
    pf_trndbh  prntform.pf_trndbh,
    pf_trndbw  prntform.pf_trndbw,
    pf_trnemp  prntform.pf_trnemp,
    pf_trn_x   prntform.pf_trn_x,
    pf_val     prntform.pf_val,
    pf_valcnd  prntform.pf_valcnd,
    pf_valdbh  prntform.pf_valdbh,
    pf_valdbw  prntform.pf_valdbw,
    pf_valemp  prntform.pf_valemp,
    pf_validat prntform.pf_validat,
    pf_val_x   prntform.pf_val_x,
    pf_vat     prntform.pf_vat,
    pf_vatcnd  prntform.pf_vatcnd,
    pf_vatdbh  prntform.pf_vatdbh,
    pf_vatdbw  prntform.pf_vatdbw,
    pf_vatemp  prntform.pf_vatemp,
    pf_vat_x   prntform.pf_vat_x
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caprntname AS caBase OF common\libs\cit_ca.vcx
Alias = [caprntname]
Tables = [prntname]
KeyFieldList = [pn_printnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pn_descr,
       pn_printnr
    FROM prntname
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pn_descr   C(20)   DEFAULT "",
    pn_printnr N(1,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pn_descr,
    pn_printnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pn_descr   prntname.pn_descr,
    pn_printnr prntname.pn_printnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caprntrepr AS caBase OF common\libs\cit_ca.vcx
Alias = [caprntrepr]
Tables = [prntrepr]
KeyFieldList = [pr_prtrpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pr_artlabe,
       pr_basedon,
       pr_billuse,
       pr_code,
       pr_custom,
       pr_deleted,
       pr_descrip,
       pr_dialog,
       pr_dlguse,
       pr_hide,
       pr_preproc,
       pr_prtrpid,
       pr_repname,
       pr_saveres
    FROM prntrepr
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pr_artlabe L       DEFAULT .F.,
    pr_basedon C(10)   DEFAULT "",
    pr_billuse L       DEFAULT .F.,
    pr_code    C(10)   DEFAULT "",
    pr_custom  L       DEFAULT .F.,
    pr_deleted L       DEFAULT .F.,
    pr_descrip C(50)   DEFAULT "",
    pr_dialog  M       DEFAULT "",
    pr_dlguse  L       DEFAULT .F.,
    pr_hide    L       DEFAULT .F.,
    pr_preproc M       DEFAULT "",
    pr_prtrpid I       DEFAULT 0,
    pr_repname C(20)   DEFAULT "",
    pr_saveres L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pr_artlabe,
    pr_basedon,
    pr_billuse,
    pr_code,
    pr_custom,
    pr_deleted,
    pr_descrip,
    pr_dialog,
    pr_dlguse,
    pr_hide,
    pr_preproc,
    pr_prtrpid,
    pr_repname,
    pr_saveres
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pr_artlabe prntrepr.pr_artlabe,
    pr_basedon prntrepr.pr_basedon,
    pr_billuse prntrepr.pr_billuse,
    pr_code    prntrepr.pr_code,
    pr_custom  prntrepr.pr_custom,
    pr_deleted prntrepr.pr_deleted,
    pr_descrip prntrepr.pr_descrip,
    pr_dialog  prntrepr.pr_dialog,
    pr_dlguse  prntrepr.pr_dlguse,
    pr_hide    prntrepr.pr_hide,
    pr_preproc prntrepr.pr_preproc,
    pr_prtrpid prntrepr.pr_prtrpid,
    pr_repname prntrepr.pr_repname,
    pr_saveres prntrepr.pr_saveres
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caprntvar AS caBase OF common\libs\cit_ca.vcx
Alias = [caprntvar]
Tables = [prntvar]
KeyFieldList = [pv_var]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       pv_bands,
       pv_custom,
       pv_de,
       pv_descr,
       pv_en,
       pv_expr,
       pv_len,
       pv_nl,
       pv_rs,
       pv_var
    FROM prntvar
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    pv_bands   C(10)   DEFAULT "",
    pv_custom  L       DEFAULT .F.,
    pv_de      C(30)   DEFAULT "",
    pv_descr   C(30)   DEFAULT "",
    pv_en      C(30)   DEFAULT "",
    pv_expr    M       DEFAULT "",
    pv_len     N(2,0)  DEFAULT 0,
    pv_nl      C(30)   DEFAULT "",
    pv_rs      C(30)   DEFAULT "",
    pv_var     C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pv_bands,
    pv_custom,
    pv_de,
    pv_descr,
    pv_en,
    pv_expr,
    pv_len,
    pv_nl,
    pv_rs,
    pv_var
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    pv_bands   prntvar.pv_bands,
    pv_custom  prntvar.pv_custom,
    pv_de      prntvar.pv_de,
    pv_descr   prntvar.pv_descr,
    pv_en      prntvar.pv_en,
    pv_expr    prntvar.pv_expr,
    pv_len     prntvar.pv_len,
    pv_nl      prntvar.pv_nl,
    pv_rs      prntvar.pv_rs,
    pv_var     prntvar.pv_var
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carartcomp AS caBase OF common\libs\cit_ca.vcx
Alias = [carartcomp]
Tables = [rartcomp]
KeyFieldList = [ac_arcmpid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ac_amtlev1,
       ac_amtlev2,
       ac_amtlev3,
       ac_amtlev4,
       ac_amtlev5,
       ac_amtlev6,
       ac_amtlev7,
       ac_amtlev8,
       ac_amtlev9,
       ac_arcmpid,
       ac_artid,
       ac_ptartid
    FROM rartcomp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_amtlev1 Y       DEFAULT 0,
    ac_amtlev2 Y       DEFAULT 0,
    ac_amtlev3 Y       DEFAULT 0,
    ac_amtlev4 Y       DEFAULT 0,
    ac_amtlev5 Y       DEFAULT 0,
    ac_amtlev6 Y       DEFAULT 0,
    ac_amtlev7 Y       DEFAULT 0,
    ac_amtlev8 Y       DEFAULT 0,
    ac_amtlev9 Y       DEFAULT 0,
    ac_arcmpid I       DEFAULT 0,
    ac_artid   I       DEFAULT 0,
    ac_ptartid I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_amtlev1,
    ac_amtlev2,
    ac_amtlev3,
    ac_amtlev4,
    ac_amtlev5,
    ac_amtlev6,
    ac_amtlev7,
    ac_amtlev8,
    ac_amtlev9,
    ac_arcmpid,
    ac_artid,
    ac_ptartid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ac_amtlev1 rartcomp.ac_amtlev1,
    ac_amtlev2 rartcomp.ac_amtlev2,
    ac_amtlev3 rartcomp.ac_amtlev3,
    ac_amtlev4 rartcomp.ac_amtlev4,
    ac_amtlev5 rartcomp.ac_amtlev5,
    ac_amtlev6 rartcomp.ac_amtlev6,
    ac_amtlev7 rartcomp.ac_amtlev7,
    ac_amtlev8 rartcomp.ac_amtlev8,
    ac_amtlev9 rartcomp.ac_amtlev9,
    ac_arcmpid rartcomp.ac_arcmpid,
    ac_artid   rartcomp.ac_artid,
    ac_ptartid rartcomp.ac_ptartid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carartfo AS caBase OF common\libs\cit_ca.vcx
Alias = [carartfo]
Tables = [rartfo]
KeyFieldList = [af_artfoid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       af_artfoid,
       af_artid,
       af_deptnr,
       af_foart
    FROM rartfo
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_artfoid I       DEFAULT 0,
    af_artid   I       DEFAULT 0,
    af_deptnr  N(2,0)  DEFAULT 0,
    af_foart   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_artfoid,
    af_artid,
    af_deptnr,
    af_foart
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    af_artfoid rartfo.af_artfoid,
    af_artid   rartfo.af_artid,
    af_deptnr  rartfo.af_deptnr,
    af_foart   rartfo.af_foart
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cararticle AS caBase OF common\libs\cit_ca.vcx
Alias = [cararticle]
Tables = [rarticle]
KeyFieldList = [ar_artid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ar_active,
       ar_adescr,
       ar_artid,
       ar_arttyp,
       ar_bscramt,
       ar_bscruse,
       ar_bsdays,
       ar_bsdbamt,
       ar_bsdbuse,
       ar_compdet,
       ar_decqty,
       ar_deleted,
       ar_devart,
       ar_devtype,
       ar_discnt,
       ar_ean,
       ar_eanplu,
       ar_fatindr,
       ar_foart,
       ar_ldescr,
       ar_mainnr,
       ar_manufac,
       ar_modgid1,
       ar_modgid2,
       ar_modgid3,
       ar_modgid4,
       ar_modgid5,
       ar_modgid6,
       ar_netqty,
       ar_plu,
       ar_plvatnr,
       ar_plvtnr2,
       ar_prclev1,
       ar_prclev2,
       ar_prclev3,
       ar_prclev4,
       ar_prclev5,
       ar_prclev6,
       ar_prclev7,
       ar_prclev8,
       ar_prclev9,
       ar_prcopen,
       ar_prcpur,
       ar_prtord1,
       ar_prtord2,
       ar_prtord3,
       ar_prtord4,
       ar_prtord5,
       ar_prtord6,
       ar_prtord7,
       ar_qdescr,
       ar_qtymes,
       ar_red,
       ar_sdescr,
       ar_slip,
       ar_sortnr,
       ar_subnr,
       ar_supplem,
       ar_ticket,
       ar_unit,
       ar_vatnr,
       ar_weighqt,
       ar_weitara
    FROM rarticle
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_active  L       DEFAULT .F.,
    ar_adescr  C(40)   DEFAULT "",
    ar_artid   I       DEFAULT 0,
    ar_arttyp  N(1,0)  DEFAULT 0,
    ar_bscramt N(12,3) DEFAULT 0,
    ar_bscruse L       DEFAULT .F.,
    ar_bsdays  N(4,0)  DEFAULT 0,
    ar_bsdbamt N(12,3) DEFAULT 0,
    ar_bsdbuse L       DEFAULT .F.,
    ar_compdet L       DEFAULT .F.,
    ar_decqty  L       DEFAULT .F.,
    ar_deleted L       DEFAULT .F.,
    ar_devart  N(4,0)  DEFAULT 0,
    ar_devtype N(1,0)  DEFAULT 0,
    ar_discnt  L       DEFAULT .F.,
    ar_ean     C(13)   DEFAULT "",
    ar_eanplu  N(5,0)  DEFAULT 0,
    ar_fatindr C(40)   DEFAULT "",
    ar_foart   N(4,0)  DEFAULT 0,
    ar_ldescr  C(40)   DEFAULT "",
    ar_mainnr  N(2,0)  DEFAULT 0,
    ar_manufac C(40)   DEFAULT "",
    ar_modgid1 I       DEFAULT 0,
    ar_modgid2 I       DEFAULT 0,
    ar_modgid3 I       DEFAULT 0,
    ar_modgid4 I       DEFAULT 0,
    ar_modgid5 I       DEFAULT 0,
    ar_modgid6 I       DEFAULT 0,
    ar_netqty  N(7,3)  DEFAULT 0,
    ar_plu     N(8,0)  DEFAULT 0,
    ar_plvatnr N(1,0)  DEFAULT 0,
    ar_plvtnr2 N(1,0)  DEFAULT 0,
    ar_prclev1 Y       DEFAULT 0,
    ar_prclev2 Y       DEFAULT 0,
    ar_prclev3 Y       DEFAULT 0,
    ar_prclev4 Y       DEFAULT 0,
    ar_prclev5 Y       DEFAULT 0,
    ar_prclev6 Y       DEFAULT 0,
    ar_prclev7 Y       DEFAULT 0,
    ar_prclev8 Y       DEFAULT 0,
    ar_prclev9 Y       DEFAULT 0,
    ar_prcopen L       DEFAULT .F.,
    ar_prcpur  Y       DEFAULT 0,
    ar_prtord1 L       DEFAULT .F.,
    ar_prtord2 L       DEFAULT .F.,
    ar_prtord3 L       DEFAULT .F.,
    ar_prtord4 L       DEFAULT .F.,
    ar_prtord5 L       DEFAULT .F.,
    ar_prtord6 L       DEFAULT .F.,
    ar_prtord7 L       DEFAULT .F.,
    ar_qdescr  C(40)   DEFAULT "",
    ar_qtymes  C(3)    DEFAULT "",
    ar_red     L       DEFAULT .F.,
    ar_sdescr  C(20)   DEFAULT "",
    ar_slip    L       DEFAULT .F.,
    ar_sortnr  N(2,0)  DEFAULT 0,
    ar_subnr   N(4,0)  DEFAULT 0,
    ar_supplem L       DEFAULT .F.,
    ar_ticket  L       DEFAULT .F.,
    ar_unit    C(2)    DEFAULT "",
    ar_vatnr   N(1,0)  DEFAULT 0,
    ar_weighqt L       DEFAULT .F.,
    ar_weitara N(5,3)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_active,
    ar_adescr,
    ar_artid,
    ar_arttyp,
    ar_bscramt,
    ar_bscruse,
    ar_bsdays,
    ar_bsdbamt,
    ar_bsdbuse,
    ar_compdet,
    ar_decqty,
    ar_deleted,
    ar_devart,
    ar_devtype,
    ar_discnt,
    ar_ean,
    ar_eanplu,
    ar_fatindr,
    ar_foart,
    ar_ldescr,
    ar_mainnr,
    ar_manufac,
    ar_modgid1,
    ar_modgid2,
    ar_modgid3,
    ar_modgid4,
    ar_modgid5,
    ar_modgid6,
    ar_netqty,
    ar_plu,
    ar_plvatnr,
    ar_plvtnr2,
    ar_prclev1,
    ar_prclev2,
    ar_prclev3,
    ar_prclev4,
    ar_prclev5,
    ar_prclev6,
    ar_prclev7,
    ar_prclev8,
    ar_prclev9,
    ar_prcopen,
    ar_prcpur,
    ar_prtord1,
    ar_prtord2,
    ar_prtord3,
    ar_prtord4,
    ar_prtord5,
    ar_prtord6,
    ar_prtord7,
    ar_qdescr,
    ar_qtymes,
    ar_red,
    ar_sdescr,
    ar_slip,
    ar_sortnr,
    ar_subnr,
    ar_supplem,
    ar_ticket,
    ar_unit,
    ar_vatnr,
    ar_weighqt,
    ar_weitara
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ar_active  rarticle.ar_active,
    ar_adescr  rarticle.ar_adescr,
    ar_artid   rarticle.ar_artid,
    ar_arttyp  rarticle.ar_arttyp,
    ar_bscramt rarticle.ar_bscramt,
    ar_bscruse rarticle.ar_bscruse,
    ar_bsdays  rarticle.ar_bsdays,
    ar_bsdbamt rarticle.ar_bsdbamt,
    ar_bsdbuse rarticle.ar_bsdbuse,
    ar_compdet rarticle.ar_compdet,
    ar_decqty  rarticle.ar_decqty,
    ar_deleted rarticle.ar_deleted,
    ar_devart  rarticle.ar_devart,
    ar_devtype rarticle.ar_devtype,
    ar_discnt  rarticle.ar_discnt,
    ar_ean     rarticle.ar_ean,
    ar_eanplu  rarticle.ar_eanplu,
    ar_fatindr rarticle.ar_fatindr,
    ar_foart   rarticle.ar_foart,
    ar_ldescr  rarticle.ar_ldescr,
    ar_mainnr  rarticle.ar_mainnr,
    ar_manufac rarticle.ar_manufac,
    ar_modgid1 rarticle.ar_modgid1,
    ar_modgid2 rarticle.ar_modgid2,
    ar_modgid3 rarticle.ar_modgid3,
    ar_modgid4 rarticle.ar_modgid4,
    ar_modgid5 rarticle.ar_modgid5,
    ar_modgid6 rarticle.ar_modgid6,
    ar_netqty  rarticle.ar_netqty,
    ar_plu     rarticle.ar_plu,
    ar_plvatnr rarticle.ar_plvatnr,
    ar_plvtnr2 rarticle.ar_plvtnr2,
    ar_prclev1 rarticle.ar_prclev1,
    ar_prclev2 rarticle.ar_prclev2,
    ar_prclev3 rarticle.ar_prclev3,
    ar_prclev4 rarticle.ar_prclev4,
    ar_prclev5 rarticle.ar_prclev5,
    ar_prclev6 rarticle.ar_prclev6,
    ar_prclev7 rarticle.ar_prclev7,
    ar_prclev8 rarticle.ar_prclev8,
    ar_prclev9 rarticle.ar_prclev9,
    ar_prcopen rarticle.ar_prcopen,
    ar_prcpur  rarticle.ar_prcpur,
    ar_prtord1 rarticle.ar_prtord1,
    ar_prtord2 rarticle.ar_prtord2,
    ar_prtord3 rarticle.ar_prtord3,
    ar_prtord4 rarticle.ar_prtord4,
    ar_prtord5 rarticle.ar_prtord5,
    ar_prtord6 rarticle.ar_prtord6,
    ar_prtord7 rarticle.ar_prtord7,
    ar_qdescr  rarticle.ar_qdescr,
    ar_qtymes  rarticle.ar_qtymes,
    ar_red     rarticle.ar_red,
    ar_sdescr  rarticle.ar_sdescr,
    ar_slip    rarticle.ar_slip,
    ar_sortnr  rarticle.ar_sortnr,
    ar_subnr   rarticle.ar_subnr,
    ar_supplem rarticle.ar_supplem,
    ar_ticket  rarticle.ar_ticket,
    ar_unit    rarticle.ar_unit,
    ar_vatnr   rarticle.ar_vatnr,
    ar_weighqt rarticle.ar_weighqt,
    ar_weitara rarticle.ar_weitara
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carartinvt AS caBase OF common\libs\cit_ca.vcx
Alias = [carartinvt]
Tables = [rartinvt]
KeyFieldList = [ai_ainvtid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ai_ainvtid,
       ai_artid,
       ai_invtamt,
       ai_invtid,
       ai_main,
       ai_sellqty,
       ai_unit
    FROM rartinvt
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_ainvtid I       DEFAULT 0,
    ai_artid   I       DEFAULT 0,
    ai_invtamt Y       DEFAULT 0,
    ai_invtid  I       DEFAULT 0,
    ai_main    L       DEFAULT .F.,
    ai_sellqty B(3)    DEFAULT 0,
    ai_unit    C(2)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_ainvtid,
    ai_artid,
    ai_invtamt,
    ai_invtid,
    ai_main,
    ai_sellqty,
    ai_unit
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ai_ainvtid rartinvt.ai_ainvtid,
    ai_artid   rartinvt.ai_artid,
    ai_invtamt rartinvt.ai_invtamt,
    ai_invtid  rartinvt.ai_invtid,
    ai_main    rartinvt.ai_main,
    ai_sellqty rartinvt.ai_sellqty,
    ai_unit    rartinvt.ai_unit
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS careader AS caBase OF common\libs\cit_ca.vcx
Alias = [careader]
Tables = [reader]
KeyFieldList = [rd_readid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       rd_begin,
       rd_cfile,
       rd_crwatnr,
       rd_departm,
       rd_end,
       rd_readcnt,
       rd_readid,
       rd_sysdate,
       rd_termnr,
       rd_type,
       rd_waitnr
    FROM reader
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_begin   T       DEFAULT {},
    rd_cfile   L       DEFAULT .F.,
    rd_crwatnr N(3,0)  DEFAULT 0,
    rd_departm N(2,0)  DEFAULT 0,
    rd_end     T       DEFAULT {},
    rd_readcnt I       DEFAULT 0,
    rd_readid  I       DEFAULT 0,
    rd_sysdate D       DEFAULT {},
    rd_termnr  N(2,0)  DEFAULT 0,
    rd_type    C(2)    DEFAULT "",
    rd_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_begin,
    rd_cfile,
    rd_crwatnr,
    rd_departm,
    rd_end,
    rd_readcnt,
    rd_readid,
    rd_sysdate,
    rd_termnr,
    rd_type,
    rd_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    rd_begin   reader.rd_begin,
    rd_cfile   reader.rd_cfile,
    rd_crwatnr reader.rd_crwatnr,
    rd_departm reader.rd_departm,
    rd_end     reader.rd_end,
    rd_readcnt reader.rd_readcnt,
    rd_readid  reader.rd_readid,
    rd_sysdate reader.rd_sysdate,
    rd_termnr  reader.rd_termnr,
    rd_type    reader.rd_type,
    rd_waitnr  reader.rd_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carscrn AS caBase OF common\libs\cit_ca.vcx
Alias = [carscrn]
Tables = [rscrn]
KeyFieldList = [sc_screen,sc_scrsize]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sc_appfile,
       sc_descr,
       sc_height,
       sc_left,
       sc_scid,
       sc_screen,
       sc_scrsize,
       sc_startup,
       sc_top,
       sc_width
    FROM rscrn
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_appfile C(8)    DEFAULT "",
    sc_descr   C(20)   DEFAULT "",
    sc_height  N(3,0)  DEFAULT 0,
    sc_left    N(3,0)  DEFAULT 0,
    sc_scid    I       DEFAULT 0,
    sc_screen  C(10)   DEFAULT "",
    sc_scrsize N(1,0)  DEFAULT 0,
    sc_startup L       DEFAULT .F.,
    sc_top     N(3,0)  DEFAULT 0,
    sc_width   N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_appfile,
    sc_descr,
    sc_height,
    sc_left,
    sc_scid,
    sc_screen,
    sc_scrsize,
    sc_startup,
    sc_top,
    sc_width
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_appfile rscrn.sc_appfile,
    sc_descr   rscrn.sc_descr,
    sc_height  rscrn.sc_height,
    sc_left    rscrn.sc_left,
    sc_scid    rscrn.sc_scid,
    sc_screen  rscrn.sc_screen,
    sc_scrsize rscrn.sc_scrsize,
    sc_startup rscrn.sc_startup,
    sc_top     rscrn.sc_top,
    sc_width   rscrn.sc_width
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS carscrnkey AS caBase OF common\libs\cit_ca.vcx
Alias = [carscrnkey]
Tables = [rscrnkey]
KeyFieldList = [sk_keyid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sk_backcol,
       sk_caption,
       sk_font,
       sk_forecol,
       sk_func,
       sk_func2,
       sk_func3,
       sk_height,
       sk_keyid,
       sk_left,
       sk_param,
       sk_param2,
       sk_param3,
       sk_screen,
       sk_state,
       sk_top,
       sk_width
    FROM rscrnkey
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sk_backcol I       DEFAULT 0,
    sk_caption C(40)   DEFAULT "",
    sk_font    C(30)   DEFAULT "",
    sk_forecol I       DEFAULT 0,
    sk_func    C(40)   DEFAULT "",
    sk_func2   C(40)   DEFAULT "",
    sk_func3   C(40)   DEFAULT "",
    sk_height  N(3,0)  DEFAULT 0,
    sk_keyid   I       DEFAULT 0,
    sk_left    N(3,0)  DEFAULT 0,
    sk_param   C(20)   DEFAULT "",
    sk_param2  C(20)   DEFAULT "",
    sk_param3  C(20)   DEFAULT "",
    sk_screen  C(10)   DEFAULT "",
    sk_state   N(1,0)  DEFAULT 0,
    sk_top     N(3,0)  DEFAULT 0,
    sk_width   N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sk_backcol,
    sk_caption,
    sk_font,
    sk_forecol,
    sk_func,
    sk_func2,
    sk_func3,
    sk_height,
    sk_keyid,
    sk_left,
    sk_param,
    sk_param2,
    sk_param3,
    sk_screen,
    sk_state,
    sk_top,
    sk_width
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sk_backcol rscrnkey.sk_backcol,
    sk_caption rscrnkey.sk_caption,
    sk_font    rscrnkey.sk_font,
    sk_forecol rscrnkey.sk_forecol,
    sk_func    rscrnkey.sk_func,
    sk_func2   rscrnkey.sk_func2,
    sk_func3   rscrnkey.sk_func3,
    sk_height  rscrnkey.sk_height,
    sk_keyid   rscrnkey.sk_keyid,
    sk_left    rscrnkey.sk_left,
    sk_param   rscrnkey.sk_param,
    sk_param2  rscrnkey.sk_param2,
    sk_param3  rscrnkey.sk_param3,
    sk_screen  rscrnkey.sk_screen,
    sk_state   rscrnkey.sk_state,
    sk_top     rscrnkey.sk_top,
    sk_width   rscrnkey.sk_width
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cascrn AS caBase OF common\libs\cit_ca.vcx
Alias = [cascrn]
Tables = [scrn]
KeyFieldList = [sc_screen,sc_scrsize]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sc_appfile,
       sc_descr,
       sc_height,
       sc_left,
       sc_scid,
       sc_screen,
       sc_scrsize,
       sc_startup,
       sc_top,
       sc_width
    FROM scrn
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_appfile C(8)    DEFAULT "",
    sc_descr   C(20)   DEFAULT "",
    sc_height  N(3,0)  DEFAULT 0,
    sc_left    N(3,0)  DEFAULT 0,
    sc_scid    I       DEFAULT 0,
    sc_screen  C(10)   DEFAULT "",
    sc_scrsize N(1,0)  DEFAULT 0,
    sc_startup L       DEFAULT .F.,
    sc_top     N(3,0)  DEFAULT 0,
    sc_width   N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_appfile,
    sc_descr,
    sc_height,
    sc_left,
    sc_scid,
    sc_screen,
    sc_scrsize,
    sc_startup,
    sc_top,
    sc_width
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sc_appfile scrn.sc_appfile,
    sc_descr   scrn.sc_descr,
    sc_height  scrn.sc_height,
    sc_left    scrn.sc_left,
    sc_scid    scrn.sc_scid,
    sc_screen  scrn.sc_screen,
    sc_scrsize scrn.sc_scrsize,
    sc_startup scrn.sc_startup,
    sc_top     scrn.sc_top,
    sc_width   scrn.sc_width
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cascrnfunc AS caBase OF common\libs\cit_ca.vcx
Alias = [cascrnfunc]
Tables = [scrnfunc]
KeyFieldList = [sf_func]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sf_appfile,
       sf_common,
       sf_de,
       sf_descr,
       sf_en,
       sf_func,
       sf_nl,
       sf_rs
    FROM scrnfunc
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sf_appfile C(8)    DEFAULT "",
    sf_common  L       DEFAULT .F.,
    sf_de      C(40)   DEFAULT "",
    sf_descr   C(40)   DEFAULT "",
    sf_en      C(40)   DEFAULT "",
    sf_func    C(40)   DEFAULT "",
    sf_nl      C(40)   DEFAULT "",
    sf_rs      C(40)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sf_appfile,
    sf_common,
    sf_de,
    sf_descr,
    sf_en,
    sf_func,
    sf_nl,
    sf_rs
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sf_appfile scrnfunc.sf_appfile,
    sf_common  scrnfunc.sf_common,
    sf_de      scrnfunc.sf_de,
    sf_descr   scrnfunc.sf_descr,
    sf_en      scrnfunc.sf_en,
    sf_func    scrnfunc.sf_func,
    sf_nl      scrnfunc.sf_nl,
    sf_rs      scrnfunc.sf_rs
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cascrnkey AS caBase OF common\libs\cit_ca.vcx
Alias = [cascrnkey]
Tables = [scrnkey]
KeyFieldList = [sk_keyid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sk_backcol,
       sk_caption,
       sk_font,
       sk_forecol,
       sk_func,
       sk_func2,
       sk_func3,
       sk_height,
       sk_keyid,
       sk_left,
       sk_param,
       sk_param2,
       sk_param3,
       sk_screen,
       sk_state,
       sk_top,
       sk_width
    FROM scrnkey
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sk_backcol I       DEFAULT 0,
    sk_caption C(40)   DEFAULT "",
    sk_font    C(30)   DEFAULT "",
    sk_forecol I       DEFAULT 0,
    sk_func    C(40)   DEFAULT "",
    sk_func2   C(40)   DEFAULT "",
    sk_func3   C(40)   DEFAULT "",
    sk_height  N(3,0)  DEFAULT 0,
    sk_keyid   I       DEFAULT 0,
    sk_left    N(3,0)  DEFAULT 0,
    sk_param   C(20)   DEFAULT "",
    sk_param2  C(20)   DEFAULT "",
    sk_param3  C(20)   DEFAULT "",
    sk_screen  C(10)   DEFAULT "",
    sk_state   N(1,0)  DEFAULT 0,
    sk_top     N(3,0)  DEFAULT 0,
    sk_width   N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sk_backcol,
    sk_caption,
    sk_font,
    sk_forecol,
    sk_func,
    sk_func2,
    sk_func3,
    sk_height,
    sk_keyid,
    sk_left,
    sk_param,
    sk_param2,
    sk_param3,
    sk_screen,
    sk_state,
    sk_top,
    sk_width
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sk_backcol scrnkey.sk_backcol,
    sk_caption scrnkey.sk_caption,
    sk_font    scrnkey.sk_font,
    sk_forecol scrnkey.sk_forecol,
    sk_func    scrnkey.sk_func,
    sk_func2   scrnkey.sk_func2,
    sk_func3   scrnkey.sk_func3,
    sk_height  scrnkey.sk_height,
    sk_keyid   scrnkey.sk_keyid,
    sk_left    scrnkey.sk_left,
    sk_param   scrnkey.sk_param,
    sk_param2  scrnkey.sk_param2,
    sk_param3  scrnkey.sk_param3,
    sk_screen  scrnkey.sk_screen,
    sk_state   scrnkey.sk_state,
    sk_top     scrnkey.sk_top,
    sk_width   scrnkey.sk_width
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS casortgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [casortgrp]
Tables = [sortgrp]
KeyFieldList = [sr_sortnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sr_deleted,
       sr_descr,
       sr_sortnr
    FROM sortgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sr_deleted L       DEFAULT .F.,
    sr_descr   C(20)   DEFAULT "",
    sr_sortnr  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sr_deleted,
    sr_descr,
    sr_sortnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sr_deleted sortgrp.sr_deleted,
    sr_descr   sortgrp.sr_descr,
    sr_sortnr  sortgrp.sr_sortnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caspilreas AS caBase OF common\libs\cit_ca.vcx
Alias = [caspilreas]
Tables = [spilreas]
KeyFieldList = [sp_spilnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sp_deleted,
       sp_descr,
       sp_spilnr
    FROM spilreas
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sp_deleted L       DEFAULT .F.,
    sp_descr   C(20)   DEFAULT "",
    sp_spilnr  N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sp_deleted,
    sp_descr,
    sp_spilnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sp_deleted spilreas.sp_deleted,
    sp_descr   spilreas.sp_descr,
    sp_spilnr  spilreas.sp_spilnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS casubgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [casubgrp]
Tables = [subgrp]
KeyFieldList = [sb_subnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       sb_deleted,
       sb_descr,
       sb_soman,
       sb_subnr
    FROM subgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    sb_deleted L       DEFAULT .F.,
    sb_descr   C(20)   DEFAULT "",
    sb_soman   L       DEFAULT .F.,
    sb_subnr   N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sb_deleted,
    sb_descr,
    sb_soman,
    sb_subnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    sb_deleted subgrp.sb_deleted,
    sb_descr   subgrp.sb_descr,
    sb_soman   subgrp.sb_soman,
    sb_subnr   subgrp.sb_subnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS casuppliers AS caBase OF common\libs\cit_ca.vcx
Alias = [casuppliers]
Tables = [suppliers]
KeyFieldList = [su_suppid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       su_apname,
       su_city,
       su_email,
       su_fax,
       su_name,
       su_name2,
       su_note,
       su_phone,
       su_phone2,
       su_street,
       su_street2,
       su_suppid,
       su_suppnr,
       su_website,
       su_zcid,
       su_zip
    FROM suppliers
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    su_apname  C(50)   DEFAULT "",
    su_city    C(30)   DEFAULT "",
    su_email   C(60)   DEFAULT "",
    su_fax     C(30)   DEFAULT "",
    su_name    C(50)   DEFAULT "",
    su_name2   C(50)   DEFAULT "",
    su_note    M       DEFAULT "",
    su_phone   C(30)   DEFAULT "",
    su_phone2  C(30)   DEFAULT "",
    su_street  C(50)   DEFAULT "",
    su_street2 C(50)   DEFAULT "",
    su_suppid  N(8,0)  DEFAULT 0,
    su_suppnr  N(8,0)  DEFAULT 0,
    su_website C(100)  DEFAULT "",
    su_zcid    I       DEFAULT 0,
    su_zip     C(10)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    su_apname,
    su_city,
    su_email,
    su_fax,
    su_name,
    su_name2,
    su_note,
    su_phone,
    su_phone2,
    su_street,
    su_street2,
    su_suppid,
    su_suppnr,
    su_website,
    su_zcid,
    su_zip
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    su_apname  suppliers.su_apname,
    su_city    suppliers.su_city,
    su_email   suppliers.su_email,
    su_fax     suppliers.su_fax,
    su_name    suppliers.su_name,
    su_name2   suppliers.su_name2,
    su_note    suppliers.su_note,
    su_phone   suppliers.su_phone,
    su_phone2  suppliers.su_phone2,
    su_street  suppliers.su_street,
    su_street2 suppliers.su_street2,
    su_suppid  suppliers.su_suppid,
    su_suppnr  suppliers.su_suppnr,
    su_website suppliers.su_website,
    su_zcid    suppliers.su_zcid,
    su_zip     suppliers.su_zip
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catable AS caBase OF common\libs\cit_ca.vcx
Alias = [catable]
Tables = [table]
KeyFieldList = [tb_tableid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tb_closed,
       tb_covers,
       tb_lost,
       tb_opened,
       tb_sysdate,
       tb_tableid,
       tb_tablenr,
       tb_touched,
       tb_waitnr
    FROM table
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tb_closed  T       DEFAULT {},
    tb_covers  N(3,0)  DEFAULT 0,
    tb_lost    L       DEFAULT .F.,
    tb_opened  T       DEFAULT {},
    tb_sysdate D       DEFAULT {},
    tb_tableid I       DEFAULT 0,
    tb_tablenr N(4,0)  DEFAULT 0,
    tb_touched L       DEFAULT .F.,
    tb_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tb_closed,
    tb_covers,
    tb_lost,
    tb_opened,
    tb_sysdate,
    tb_tableid,
    tb_tablenr,
    tb_touched,
    tb_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tb_closed  table.tb_closed,
    tb_covers  table.tb_covers,
    tb_lost    table.tb_lost,
    tb_opened  table.tb_opened,
    tb_sysdate table.tb_sysdate,
    tb_tableid table.tb_tableid,
    tb_tablenr table.tb_tablenr,
    tb_touched table.tb_touched,
    tb_waitnr  table.tb_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catableres AS caBase OF common\libs\cit_ca.vcx
Alias = [catableres]
Tables = [tableres]
KeyFieldList = [tr_trid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tr_aaddrid,
       tr_addrid,
       tr_changes,
       tr_childs,
       tr_created,
       tr_fname,
       tr_from,
       tr_gsgrpid,
       tr_lname,
       tr_note,
       tr_persons,
       tr_phone,
       tr_rsid,
       tr_status,
       tr_sysdate,
       tr_tableid,
       tr_tablenr,
       tr_tgid,
       tr_title,
       tr_to,
       tr_touched,
       tr_trid,
       tr_updated,
       tr_user,
       tr_userid,
       tr_usrname,
       tr_waitnr
    FROM tableres
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tr_aaddrid N(8,0)  DEFAULT 0,
    tr_addrid  N(8,0)  DEFAULT 0,
    tr_changes M       DEFAULT "",
    tr_childs  I       DEFAULT 0,
    tr_created T       DEFAULT {},
    tr_fname   C(20)   DEFAULT "",
    tr_from    T       DEFAULT {},
    tr_gsgrpid I       DEFAULT 0,
    tr_lname   C(30)   DEFAULT "",
    tr_note    M       DEFAULT "",
    tr_persons I       DEFAULT 0,
    tr_phone   C(20)   DEFAULT "",
    tr_rsid    I       DEFAULT 0,
    tr_status  I       DEFAULT 0,
    tr_sysdate D       DEFAULT {},
    tr_tableid I       DEFAULT 0,
    tr_tablenr N(4,0)  DEFAULT 0,
    tr_tgid    I       DEFAULT 0,
    tr_title   C(25)   DEFAULT "",
    tr_to      T       DEFAULT {},
    tr_touched L       DEFAULT .F.,
    tr_trid    I       DEFAULT 0,
    tr_updated T       DEFAULT {},
    tr_user    C(3)    DEFAULT "",
    tr_userid  C(10)   DEFAULT "",
    tr_usrname C(10)   DEFAULT "",
    tr_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tr_aaddrid,
    tr_addrid,
    tr_changes,
    tr_childs,
    tr_created,
    tr_fname,
    tr_from,
    tr_gsgrpid,
    tr_lname,
    tr_note,
    tr_persons,
    tr_phone,
    tr_rsid,
    tr_status,
    tr_sysdate,
    tr_tableid,
    tr_tablenr,
    tr_tgid,
    tr_title,
    tr_to,
    tr_touched,
    tr_trid,
    tr_updated,
    tr_user,
    tr_userid,
    tr_usrname,
    tr_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tr_aaddrid tableres.tr_aaddrid,
    tr_addrid  tableres.tr_addrid,
    tr_changes tableres.tr_changes,
    tr_childs  tableres.tr_childs,
    tr_created tableres.tr_created,
    tr_fname   tableres.tr_fname,
    tr_from    tableres.tr_from,
    tr_gsgrpid tableres.tr_gsgrpid,
    tr_lname   tableres.tr_lname,
    tr_note    tableres.tr_note,
    tr_persons tableres.tr_persons,
    tr_phone   tableres.tr_phone,
    tr_rsid    tableres.tr_rsid,
    tr_status  tableres.tr_status,
    tr_sysdate tableres.tr_sysdate,
    tr_tableid tableres.tr_tableid,
    tr_tablenr tableres.tr_tablenr,
    tr_tgid    tableres.tr_tgid,
    tr_title   tableres.tr_title,
    tr_to      tableres.tr_to,
    tr_touched tableres.tr_touched,
    tr_trid    tableres.tr_trid,
    tr_updated tableres.tr_updated,
    tr_user    tableres.tr_user,
    tr_userid  tableres.tr_userid,
    tr_usrname tableres.tr_usrname,
    tr_waitnr  tableres.tr_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catblfeat AS caBase OF common\libs\cit_ca.vcx
Alias = [catblfeat]
Tables = [tblfeat]
KeyFieldList = [tf_code]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tf_code,
       tf_deleted,
       tf_descr
    FROM tblfeat
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tf_code    C(3)    DEFAULT "",
    tf_deleted L       DEFAULT .F.,
    tf_descr   C(20)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tf_code,
    tf_deleted,
    tf_descr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tf_code    tblfeat.tf_code,
    tf_deleted tblfeat.tf_deleted,
    tf_descr   tblfeat.tf_descr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catblprops AS caBase OF common\libs\cit_ca.vcx
Alias = [catblprops]
Tables = [tblprops]
KeyFieldList = [tp_tablenr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tp_deleted,
       tp_feat1,
       tp_feat2,
       tp_feat3,
       tp_feat4,
       tp_feat5,
       tp_seats,
       tp_tablenr
    FROM tblprops
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tp_deleted L       DEFAULT .F.,
    tp_feat1   C(3)    DEFAULT "",
    tp_feat2   C(3)    DEFAULT "",
    tp_feat3   C(3)    DEFAULT "",
    tp_feat4   C(3)    DEFAULT "",
    tp_feat5   C(3)    DEFAULT "",
    tp_seats   N(3,0)  DEFAULT 0,
    tp_tablenr N(4,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tp_deleted,
    tp_feat1,
    tp_feat2,
    tp_feat3,
    tp_feat4,
    tp_feat5,
    tp_seats,
    tp_tablenr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tp_deleted tblprops.tp_deleted,
    tp_feat1   tblprops.tp_feat1,
    tp_feat2   tblprops.tp_feat2,
    tp_feat3   tblprops.tp_feat3,
    tp_feat4   tblprops.tp_feat4,
    tp_feat5   tblprops.tp_feat5,
    tp_seats   tblprops.tp_seats,
    tp_tablenr tblprops.tp_tablenr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catblrsgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [catblrsgrp]
Tables = [tblrsgrp]
KeyFieldList = [tg_tgid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tg_adults,
       tg_childs,
       tg_locnr,
       tg_note,
       tg_tables,
       tg_tgid
    FROM tblrsgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tg_adults  I       DEFAULT 0,
    tg_childs  I       DEFAULT 0,
    tg_locnr   I       DEFAULT 0,
    tg_note    M       DEFAULT "",
    tg_tables  C(50)   DEFAULT "",
    tg_tgid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tg_adults,
    tg_childs,
    tg_locnr,
    tg_note,
    tg_tables,
    tg_tgid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tg_adults  tblrsgrp.tg_adults,
    tg_childs  tblrsgrp.tg_childs,
    tg_locnr   tblrsgrp.tg_locnr,
    tg_note    tblrsgrp.tg_note,
    tg_tables  tblrsgrp.tg_tables,
    tg_tgid    tblrsgrp.tg_tgid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caterminal AS caBase OF common\libs\cit_ca.vcx
Alias = [caterminal]
Tables = [terminal]
KeyFieldList = [tm_termnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tm_bcport,
       tm_bcset,
       tm_cdsdriv,
       tm_cdsport,
       tm_covers,
       tm_crwbaud,
       tm_crwdriv,
       tm_crwifc,
       tm_crwport,
       tm_de2port,
       tm_de2type,
       tm_de3port,
       tm_de3type,
       tm_deleted,
       tm_deptnr,
       tm_descr,
       tm_devaof1,
       tm_devaof2,
       tm_devhs1,
       tm_devhs2,
       tm_devhs3,
       tm_devport,
       tm_devset1,
       tm_devset2,
       tm_devset3,
       tm_devtype,
       tm_dirsale,
       tm_drwdriv,
       tm_drwoff,
       tm_drwport,
       tm_dscform,
       tm_dscoff,
       tm_dscport,
       tm_edbmp,
       tm_elcltid,
       tm_elksz2,
       tm_elpcph,
       tm_elpcpn,
       tm_elpcps,
       tm_elpcrt,
       tm_elpcrw,
       tm_elpdir,
       tm_elpport,
       tm_elte1,
       tm_elte2,
       tm_elte3,
       tm_eltimeo,
       tm_elts1,
       tm_elts2,
       tm_elts3,
       tm_elwidth,
       tm_extdisp,
       tm_fpdriv,
       tm_fpnr,
       tm_fpoff,
       tm_grpplu,
       tm_gstname,
       tm_gsttyp,
       tm_keeptbp,
       tm_keydriv,
       tm_keyport,
       tm_keyset,
       tm_locnr,
       tm_or1form,
       tm_or1off,
       tm_or1port,
       tm_or2form,
       tm_or2off,
       tm_or2port,
       tm_or3form,
       tm_or3off,
       tm_or3port,
       tm_or4form,
       tm_or4off,
       tm_or4port,
       tm_or5form,
       tm_or5off,
       tm_or5port,
       tm_or6form,
       tm_or6off,
       tm_or6port,
       tm_or7form,
       tm_or7off,
       tm_or7port,
       tm_planid,
       tm_plevnr,
       tm_prdriv1,
       tm_prdriv2,
       tm_prdriv3,
       tm_prdriv4,
       tm_prdriv5,
       tm_prdriv6,
       tm_prhs1,
       tm_prhs2,
       tm_prhs3,
       tm_prhs4,
       tm_prhs5,
       tm_prhs6,
       tm_prport1,
       tm_prport2,
       tm_prport3,
       tm_prport4,
       tm_prport5,
       tm_prport6,
       tm_prset1,
       tm_prset2,
       tm_prset3,
       tm_prset4,
       tm_prset5,
       tm_prset6,
       tm_prshar1,
       tm_prshar2,
       tm_prshar3,
       tm_prshar4,
       tm_prshar5,
       tm_prshar6,
       tm_prstmp1,
       tm_prstmp2,
       tm_prstmp3,
       tm_prstmp4,
       tm_prstmp5,
       tm_prstmp6,
       tm_prtdsal,
       tm_prtloc,
       tm_prtmode,
       tm_rcpform,
       tm_rcpoff,
       tm_rcpport,
       tm_room,
       tm_screen,
       tm_scrsize,
       tm_slpform,
       tm_slpoff,
       tm_slpport,
       tm_spoolon,
       tm_taskbar,
       tm_termnr,
       tm_voport,
       tm_winexit,
       tm_winname,
       tm_wstaydn,
       tm_xport,
       tm_z1port,
       tm_z2port
    FROM terminal
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tm_bcport  C(5)    DEFAULT "",
    tm_bcset   C(20)   DEFAULT "",
    tm_cdsdriv C(10)   DEFAULT "",
    tm_cdsport C(4)    DEFAULT "",
    tm_covers  L       DEFAULT .F.,
    tm_crwbaud N(6,0)  DEFAULT 0,
    tm_crwdriv C(25)   DEFAULT "",
    tm_crwifc  L       DEFAULT .F.,
    tm_crwport C(6)    DEFAULT "",
    tm_de2port C(5)    DEFAULT "",
    tm_de2type N(1,0)  DEFAULT 0,
    tm_de3port C(5)    DEFAULT "",
    tm_de3type N(1,0)  DEFAULT 0,
    tm_deleted L       DEFAULT .F.,
    tm_deptnr  N(2,0)  DEFAULT 0,
    tm_descr   C(20)   DEFAULT "",
    tm_devaof1 L       DEFAULT .F.,
    tm_devaof2 L       DEFAULT .F.,
    tm_devhs1  N(1,0)  DEFAULT 0,
    tm_devhs2  N(1,0)  DEFAULT 0,
    tm_devhs3  N(1,0)  DEFAULT 0,
    tm_devport C(5)    DEFAULT "",
    tm_devset1 C(20)   DEFAULT "",
    tm_devset2 C(20)   DEFAULT "",
    tm_devset3 C(20)   DEFAULT "",
    tm_devtype N(1,0)  DEFAULT 0,
    tm_dirsale L       DEFAULT .F.,
    tm_drwdriv C(10)   DEFAULT "",
    tm_drwoff  L       DEFAULT .F.,
    tm_drwport C(4)    DEFAULT "",
    tm_dscform C(10)   DEFAULT "",
    tm_dscoff  L       DEFAULT .F.,
    tm_dscport C(30)   DEFAULT "",
    tm_edbmp   C(20)   DEFAULT "",
    tm_elcltid N(3,0)  DEFAULT 0,
    tm_elksz2  L       DEFAULT .F.,
    tm_elpcph  C(1)    DEFAULT "",
    tm_elpcpn  C(5)    DEFAULT "",
    tm_elpcps  C(12)   DEFAULT "",
    tm_elpcrt  C(1)    DEFAULT "",
    tm_elpcrw  N(4,0)  DEFAULT 0,
    tm_elpdir  C(100)  DEFAULT "",
    tm_elpport C(30)   DEFAULT "",
    tm_elte1   C(10)   DEFAULT "",
    tm_elte2   C(10)   DEFAULT "",
    tm_elte3   C(10)   DEFAULT "",
    tm_eltimeo N(3,0)  DEFAULT 0,
    tm_elts1   C(10)   DEFAULT "",
    tm_elts2   C(10)   DEFAULT "",
    tm_elts3   C(10)   DEFAULT "",
    tm_elwidth N(3,0)  DEFAULT 0,
    tm_extdisp L       DEFAULT .F.,
    tm_fpdriv  C(50)   DEFAULT "",
    tm_fpnr    N(2,0)  DEFAULT 0,
    tm_fpoff   L       DEFAULT .F.,
    tm_grpplu  L       DEFAULT .F.,
    tm_gstname L       DEFAULT .F.,
    tm_gsttyp  L       DEFAULT .F.,
    tm_keeptbp L       DEFAULT .F.,
    tm_keydriv C(20)   DEFAULT "",
    tm_keyport C(5)    DEFAULT "",
    tm_keyset  C(20)   DEFAULT "",
    tm_locnr   N(2,0)  DEFAULT 0,
    tm_or1form C(10)   DEFAULT "",
    tm_or1off  L       DEFAULT .F.,
    tm_or1port C(30)   DEFAULT "",
    tm_or2form C(10)   DEFAULT "",
    tm_or2off  L       DEFAULT .F.,
    tm_or2port C(30)   DEFAULT "",
    tm_or3form C(10)   DEFAULT "",
    tm_or3off  L       DEFAULT .F.,
    tm_or3port C(30)   DEFAULT "",
    tm_or4form C(10)   DEFAULT "",
    tm_or4off  L       DEFAULT .F.,
    tm_or4port C(30)   DEFAULT "",
    tm_or5form C(10)   DEFAULT "",
    tm_or5off  L       DEFAULT .F.,
    tm_or5port C(30)   DEFAULT "",
    tm_or6form C(10)   DEFAULT "",
    tm_or6off  L       DEFAULT .F.,
    tm_or6port C(30)   DEFAULT "",
    tm_or7form C(10)   DEFAULT "",
    tm_or7off  L       DEFAULT .F.,
    tm_or7port C(30)   DEFAULT "",
    tm_planid  I       DEFAULT 0,
    tm_plevnr  N(1,0)  DEFAULT 0,
    tm_prdriv1 C(10)   DEFAULT "",
    tm_prdriv2 C(10)   DEFAULT "",
    tm_prdriv3 C(10)   DEFAULT "",
    tm_prdriv4 C(10)   DEFAULT "",
    tm_prdriv5 C(10)   DEFAULT "",
    tm_prdriv6 C(10)   DEFAULT "",
    tm_prhs1   N(1,0)  DEFAULT 0,
    tm_prhs2   N(1,0)  DEFAULT 0,
    tm_prhs3   N(1,0)  DEFAULT 0,
    tm_prhs4   N(1,0)  DEFAULT 0,
    tm_prhs5   N(1,0)  DEFAULT 0,
    tm_prhs6   N(1,0)  DEFAULT 0,
    tm_prport1 C(4)    DEFAULT "",
    tm_prport2 C(4)    DEFAULT "",
    tm_prport3 C(4)    DEFAULT "",
    tm_prport4 C(4)    DEFAULT "",
    tm_prport5 C(4)    DEFAULT "",
    tm_prport6 C(4)    DEFAULT "",
    tm_prset1  C(20)   DEFAULT "",
    tm_prset2  C(20)   DEFAULT "",
    tm_prset3  C(20)   DEFAULT "",
    tm_prset4  C(20)   DEFAULT "",
    tm_prset5  C(20)   DEFAULT "",
    tm_prset6  C(20)   DEFAULT "",
    tm_prshar1 C(10)   DEFAULT "",
    tm_prshar2 C(10)   DEFAULT "",
    tm_prshar3 C(10)   DEFAULT "",
    tm_prshar4 C(10)   DEFAULT "",
    tm_prshar5 C(10)   DEFAULT "",
    tm_prshar6 C(10)   DEFAULT "",
    tm_prstmp1 L       DEFAULT .F.,
    tm_prstmp2 L       DEFAULT .F.,
    tm_prstmp3 L       DEFAULT .F.,
    tm_prstmp4 L       DEFAULT .F.,
    tm_prstmp5 L       DEFAULT .F.,
    tm_prstmp6 L       DEFAULT .F.,
    tm_prtdsal N(1,0)  DEFAULT 0,
    tm_prtloc  L       DEFAULT .F.,
    tm_prtmode N(1,0)  DEFAULT 0,
    tm_rcpform C(10)   DEFAULT "",
    tm_rcpoff  L       DEFAULT .F.,
    tm_rcpport C(30)   DEFAULT "",
    tm_room    L       DEFAULT .F.,
    tm_screen  C(10)   DEFAULT "",
    tm_scrsize N(1,0)  DEFAULT 0,
    tm_slpform C(10)   DEFAULT "",
    tm_slpoff  L       DEFAULT .F.,
    tm_slpport C(30)   DEFAULT "",
    tm_spoolon L       DEFAULT .F.,
    tm_taskbar L       DEFAULT .F.,
    tm_termnr  N(2,0)  DEFAULT 0,
    tm_voport  C(30)   DEFAULT "",
    tm_winexit L       DEFAULT .F.,
    tm_winname C(15)   DEFAULT "",
    tm_wstaydn L       DEFAULT .F.,
    tm_xport   C(30)   DEFAULT "",
    tm_z1port  C(30)   DEFAULT "",
    tm_z2port  C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tm_bcport,
    tm_bcset,
    tm_cdsdriv,
    tm_cdsport,
    tm_covers,
    tm_crwbaud,
    tm_crwdriv,
    tm_crwifc,
    tm_crwport,
    tm_de2port,
    tm_de2type,
    tm_de3port,
    tm_de3type,
    tm_deleted,
    tm_deptnr,
    tm_descr,
    tm_devaof1,
    tm_devaof2,
    tm_devhs1,
    tm_devhs2,
    tm_devhs3,
    tm_devport,
    tm_devset1,
    tm_devset2,
    tm_devset3,
    tm_devtype,
    tm_dirsale,
    tm_drwdriv,
    tm_drwoff,
    tm_drwport,
    tm_dscform,
    tm_dscoff,
    tm_dscport,
    tm_edbmp,
    tm_elcltid,
    tm_elksz2,
    tm_elpcph,
    tm_elpcpn,
    tm_elpcps,
    tm_elpcrt,
    tm_elpcrw,
    tm_elpdir,
    tm_elpport,
    tm_elte1,
    tm_elte2,
    tm_elte3,
    tm_eltimeo,
    tm_elts1,
    tm_elts2,
    tm_elts3,
    tm_elwidth,
    tm_extdisp,
    tm_fpdriv,
    tm_fpnr,
    tm_fpoff,
    tm_grpplu,
    tm_gstname,
    tm_gsttyp,
    tm_keeptbp,
    tm_keydriv,
    tm_keyport,
    tm_keyset,
    tm_locnr,
    tm_or1form,
    tm_or1off,
    tm_or1port,
    tm_or2form,
    tm_or2off,
    tm_or2port,
    tm_or3form,
    tm_or3off,
    tm_or3port,
    tm_or4form,
    tm_or4off,
    tm_or4port,
    tm_or5form,
    tm_or5off,
    tm_or5port,
    tm_or6form,
    tm_or6off,
    tm_or6port,
    tm_or7form,
    tm_or7off,
    tm_or7port,
    tm_planid,
    tm_plevnr,
    tm_prdriv1,
    tm_prdriv2,
    tm_prdriv3,
    tm_prdriv4,
    tm_prdriv5,
    tm_prdriv6,
    tm_prhs1,
    tm_prhs2,
    tm_prhs3,
    tm_prhs4,
    tm_prhs5,
    tm_prhs6,
    tm_prport1,
    tm_prport2,
    tm_prport3,
    tm_prport4,
    tm_prport5,
    tm_prport6,
    tm_prset1,
    tm_prset2,
    tm_prset3,
    tm_prset4,
    tm_prset5,
    tm_prset6,
    tm_prshar1,
    tm_prshar2,
    tm_prshar3,
    tm_prshar4,
    tm_prshar5,
    tm_prshar6,
    tm_prstmp1,
    tm_prstmp2,
    tm_prstmp3,
    tm_prstmp4,
    tm_prstmp5,
    tm_prstmp6,
    tm_prtdsal,
    tm_prtloc,
    tm_prtmode,
    tm_rcpform,
    tm_rcpoff,
    tm_rcpport,
    tm_room,
    tm_screen,
    tm_scrsize,
    tm_slpform,
    tm_slpoff,
    tm_slpport,
    tm_spoolon,
    tm_taskbar,
    tm_termnr,
    tm_voport,
    tm_winexit,
    tm_winname,
    tm_wstaydn,
    tm_xport,
    tm_z1port,
    tm_z2port
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tm_bcport  terminal.tm_bcport,
    tm_bcset   terminal.tm_bcset,
    tm_cdsdriv terminal.tm_cdsdriv,
    tm_cdsport terminal.tm_cdsport,
    tm_covers  terminal.tm_covers,
    tm_crwbaud terminal.tm_crwbaud,
    tm_crwdriv terminal.tm_crwdriv,
    tm_crwifc  terminal.tm_crwifc,
    tm_crwport terminal.tm_crwport,
    tm_de2port terminal.tm_de2port,
    tm_de2type terminal.tm_de2type,
    tm_de3port terminal.tm_de3port,
    tm_de3type terminal.tm_de3type,
    tm_deleted terminal.tm_deleted,
    tm_deptnr  terminal.tm_deptnr,
    tm_descr   terminal.tm_descr,
    tm_devaof1 terminal.tm_devaof1,
    tm_devaof2 terminal.tm_devaof2,
    tm_devhs1  terminal.tm_devhs1,
    tm_devhs2  terminal.tm_devhs2,
    tm_devhs3  terminal.tm_devhs3,
    tm_devport terminal.tm_devport,
    tm_devset1 terminal.tm_devset1,
    tm_devset2 terminal.tm_devset2,
    tm_devset3 terminal.tm_devset3,
    tm_devtype terminal.tm_devtype,
    tm_dirsale terminal.tm_dirsale,
    tm_drwdriv terminal.tm_drwdriv,
    tm_drwoff  terminal.tm_drwoff,
    tm_drwport terminal.tm_drwport,
    tm_dscform terminal.tm_dscform,
    tm_dscoff  terminal.tm_dscoff,
    tm_dscport terminal.tm_dscport,
    tm_edbmp   terminal.tm_edbmp,
    tm_elcltid terminal.tm_elcltid,
    tm_elksz2  terminal.tm_elksz2,
    tm_elpcph  terminal.tm_elpcph,
    tm_elpcpn  terminal.tm_elpcpn,
    tm_elpcps  terminal.tm_elpcps,
    tm_elpcrt  terminal.tm_elpcrt,
    tm_elpcrw  terminal.tm_elpcrw,
    tm_elpdir  terminal.tm_elpdir,
    tm_elpport terminal.tm_elpport,
    tm_elte1   terminal.tm_elte1,
    tm_elte2   terminal.tm_elte2,
    tm_elte3   terminal.tm_elte3,
    tm_eltimeo terminal.tm_eltimeo,
    tm_elts1   terminal.tm_elts1,
    tm_elts2   terminal.tm_elts2,
    tm_elts3   terminal.tm_elts3,
    tm_elwidth terminal.tm_elwidth,
    tm_extdisp terminal.tm_extdisp,
    tm_fpdriv  terminal.tm_fpdriv,
    tm_fpnr    terminal.tm_fpnr,
    tm_fpoff   terminal.tm_fpoff,
    tm_grpplu  terminal.tm_grpplu,
    tm_gstname terminal.tm_gstname,
    tm_gsttyp  terminal.tm_gsttyp,
    tm_keeptbp terminal.tm_keeptbp,
    tm_keydriv terminal.tm_keydriv,
    tm_keyport terminal.tm_keyport,
    tm_keyset  terminal.tm_keyset,
    tm_locnr   terminal.tm_locnr,
    tm_or1form terminal.tm_or1form,
    tm_or1off  terminal.tm_or1off,
    tm_or1port terminal.tm_or1port,
    tm_or2form terminal.tm_or2form,
    tm_or2off  terminal.tm_or2off,
    tm_or2port terminal.tm_or2port,
    tm_or3form terminal.tm_or3form,
    tm_or3off  terminal.tm_or3off,
    tm_or3port terminal.tm_or3port,
    tm_or4form terminal.tm_or4form,
    tm_or4off  terminal.tm_or4off,
    tm_or4port terminal.tm_or4port,
    tm_or5form terminal.tm_or5form,
    tm_or5off  terminal.tm_or5off,
    tm_or5port terminal.tm_or5port,
    tm_or6form terminal.tm_or6form,
    tm_or6off  terminal.tm_or6off,
    tm_or6port terminal.tm_or6port,
    tm_or7form terminal.tm_or7form,
    tm_or7off  terminal.tm_or7off,
    tm_or7port terminal.tm_or7port,
    tm_planid  terminal.tm_planid,
    tm_plevnr  terminal.tm_plevnr,
    tm_prdriv1 terminal.tm_prdriv1,
    tm_prdriv2 terminal.tm_prdriv2,
    tm_prdriv3 terminal.tm_prdriv3,
    tm_prdriv4 terminal.tm_prdriv4,
    tm_prdriv5 terminal.tm_prdriv5,
    tm_prdriv6 terminal.tm_prdriv6,
    tm_prhs1   terminal.tm_prhs1,
    tm_prhs2   terminal.tm_prhs2,
    tm_prhs3   terminal.tm_prhs3,
    tm_prhs4   terminal.tm_prhs4,
    tm_prhs5   terminal.tm_prhs5,
    tm_prhs6   terminal.tm_prhs6,
    tm_prport1 terminal.tm_prport1,
    tm_prport2 terminal.tm_prport2,
    tm_prport3 terminal.tm_prport3,
    tm_prport4 terminal.tm_prport4,
    tm_prport5 terminal.tm_prport5,
    tm_prport6 terminal.tm_prport6,
    tm_prset1  terminal.tm_prset1,
    tm_prset2  terminal.tm_prset2,
    tm_prset3  terminal.tm_prset3,
    tm_prset4  terminal.tm_prset4,
    tm_prset5  terminal.tm_prset5,
    tm_prset6  terminal.tm_prset6,
    tm_prshar1 terminal.tm_prshar1,
    tm_prshar2 terminal.tm_prshar2,
    tm_prshar3 terminal.tm_prshar3,
    tm_prshar4 terminal.tm_prshar4,
    tm_prshar5 terminal.tm_prshar5,
    tm_prshar6 terminal.tm_prshar6,
    tm_prstmp1 terminal.tm_prstmp1,
    tm_prstmp2 terminal.tm_prstmp2,
    tm_prstmp3 terminal.tm_prstmp3,
    tm_prstmp4 terminal.tm_prstmp4,
    tm_prstmp5 terminal.tm_prstmp5,
    tm_prstmp6 terminal.tm_prstmp6,
    tm_prtdsal terminal.tm_prtdsal,
    tm_prtloc  terminal.tm_prtloc,
    tm_prtmode terminal.tm_prtmode,
    tm_rcpform terminal.tm_rcpform,
    tm_rcpoff  terminal.tm_rcpoff,
    tm_rcpport terminal.tm_rcpport,
    tm_room    terminal.tm_room,
    tm_screen  terminal.tm_screen,
    tm_scrsize terminal.tm_scrsize,
    tm_slpform terminal.tm_slpform,
    tm_slpoff  terminal.tm_slpoff,
    tm_slpport terminal.tm_slpport,
    tm_spoolon terminal.tm_spoolon,
    tm_taskbar terminal.tm_taskbar,
    tm_termnr  terminal.tm_termnr,
    tm_voport  terminal.tm_voport,
    tm_winexit terminal.tm_winexit,
    tm_winname terminal.tm_winname,
    tm_wstaydn terminal.tm_wstaydn,
    tm_xport   terminal.tm_xport,
    tm_z1port  terminal.tm_z1port,
    tm_z2port  terminal.tm_z2port
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catext AS caBase OF common\libs\cit_ca.vcx
Alias = [catext]
Tables = [text]
KeyFieldList = [tx_id,tx_context,tx_locale]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tx_context,
       tx_id,
       tx_locale,
       tx_text
    FROM text
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tx_context C(1)    DEFAULT "",
    tx_id      C(32)   DEFAULT "",
    tx_locale  C(2)    DEFAULT "",
    tx_text    C(200)  DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tx_context,
    tx_id,
    tx_locale,
    tx_text
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tx_context text.tx_context,
    tx_id      text.tx_id,
    tx_locale  text.tx_locale,
    tx_text    text.tx_text
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catimetype AS caBase OF common\libs\cit_ca.vcx
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
DEFINE CLASS catimezone AS caBase OF common\libs\cit_ca.vcx
Alias = [catimezone]
Tables = [timezone]
KeyFieldList = [tz_timznnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tz_begin,
       tz_deleted,
       tz_descr,
       tz_end,
       tz_timznnr
    FROM timezone
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tz_begin   C(4)    DEFAULT "",
    tz_deleted L       DEFAULT .F.,
    tz_descr   C(20)   DEFAULT "",
    tz_end     C(4)    DEFAULT "",
    tz_timznnr N(2,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tz_begin,
    tz_deleted,
    tz_descr,
    tz_end,
    tz_timznnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tz_begin   timezone.tz_begin,
    tz_deleted timezone.tz_deleted,
    tz_descr   timezone.tz_descr,
    tz_end     timezone.tz_end,
    tz_timznnr timezone.tz_timznnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catitlcode AS caBase OF common\libs\cit_ca.vcx
Alias = [catitlcode]
Tables = [titlcode]
KeyFieldList = [tc_titlcod]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       tc_deleted,
       tc_salute,
       tc_titlcod,
       tc_title
    FROM titlcode
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    tc_deleted L       DEFAULT .F.,
    tc_salute  C(50)   DEFAULT "",
    tc_titlcod N(2,0)  DEFAULT 0,
    tc_title   C(25)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tc_deleted,
    tc_salute,
    tc_titlcod,
    tc_title
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    tc_deleted titlcode.tc_deleted,
    tc_salute  titlcode.tc_salute,
    tc_titlcod titlcode.tc_titlcod,
    tc_title   titlcode.tc_title
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS catmoman AS caBase OF common\libs\cit_ca.vcx
Alias = [catmoman]
Tables = [tmoman]
KeyFieldList = [to_omannr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       to_appfile,
       to_barcode,
       to_cardrea,
       to_dcheksu,
       to_deleted,
       to_descr,
       to_dscform,
       to_dscoff,
       to_dscport,
       to_elcltid,
       to_elksz2,
       to_elpcph,
       to_elpcpn,
       to_elpcps,
       to_elpcrt,
       to_elpcrw,
       to_elpdir,
       to_elpport,
       to_elte1,
       to_elte2,
       to_elte3,
       to_eltimeo,
       to_elts1,
       to_elts2,
       to_elts3,
       to_elwidth,
       to_login,
       to_omannr,
       to_or1form,
       to_or1off,
       to_or1port,
       to_or2form,
       to_or2off,
       to_or2port,
       to_or3form,
       to_or3off,
       to_or3port,
       to_or4form,
       to_or4off,
       to_or4port,
       to_or5form,
       to_or5off,
       to_or5port,
       to_or6form,
       to_or6off,
       to_or6port,
       to_or7form,
       to_or7off,
       to_or7port,
       to_plevnr,
       to_prdriv1,
       to_prdriv2,
       to_prdriv3,
       to_prdriv4,
       to_prdriv5,
       to_prdriv6,
       to_prhs1,
       to_prhs2,
       to_prhs3,
       to_prhs4,
       to_prhs5,
       to_prhs6,
       to_prport1,
       to_prport2,
       to_prport3,
       to_prport4,
       to_prport5,
       to_prport6,
       to_prset1,
       to_prset2,
       to_prset3,
       to_prset4,
       to_prset5,
       to_prset6,
       to_prshar1,
       to_prshar2,
       to_prshar3,
       to_prshar4,
       to_prshar5,
       to_prshar6,
       to_prstmp1,
       to_prstmp2,
       to_prstmp3,
       to_prstmp4,
       to_prstmp5,
       to_prstmp6,
       to_prtloc,
       to_prtmode,
       to_rcheksu,
       to_rcpform,
       to_rcpoff,
       to_rcpport,
       to_request,
       to_screen,
       to_slpform,
       to_slpoff,
       to_slpport,
       to_solnoua,
       to_useoms,
       to_winname,
       to_xport,
       to_z1port,
       to_z2port
    FROM tmoman
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    to_appfile C(8)    DEFAULT "",
    to_barcode L       DEFAULT .F.,
    to_cardrea L       DEFAULT .F.,
    to_dcheksu N(16,0) DEFAULT 0,
    to_deleted L       DEFAULT .F.,
    to_descr   C(30)   DEFAULT "",
    to_dscform C(10)   DEFAULT "",
    to_dscoff  L       DEFAULT .F.,
    to_dscport C(30)   DEFAULT "",
    to_elcltid N(3,0)  DEFAULT 0,
    to_elksz2  L       DEFAULT .F.,
    to_elpcph  C(1)    DEFAULT "",
    to_elpcpn  C(5)    DEFAULT "",
    to_elpcps  C(12)   DEFAULT "",
    to_elpcrt  C(1)    DEFAULT "",
    to_elpcrw  N(4,0)  DEFAULT 0,
    to_elpdir  C(100)  DEFAULT "",
    to_elpport C(30)   DEFAULT "",
    to_elte1   C(10)   DEFAULT "",
    to_elte2   C(10)   DEFAULT "",
    to_elte3   C(10)   DEFAULT "",
    to_eltimeo N(3,0)  DEFAULT 0,
    to_elts1   C(10)   DEFAULT "",
    to_elts2   C(10)   DEFAULT "",
    to_elts3   C(10)   DEFAULT "",
    to_elwidth N(3,0)  DEFAULT 0,
    to_login   T       DEFAULT {},
    to_omannr  I       DEFAULT 0,
    to_or1form C(10)   DEFAULT "",
    to_or1off  L       DEFAULT .F.,
    to_or1port C(30)   DEFAULT "",
    to_or2form C(10)   DEFAULT "",
    to_or2off  L       DEFAULT .F.,
    to_or2port C(30)   DEFAULT "",
    to_or3form C(10)   DEFAULT "",
    to_or3off  L       DEFAULT .F.,
    to_or3port C(30)   DEFAULT "",
    to_or4form C(10)   DEFAULT "",
    to_or4off  L       DEFAULT .F.,
    to_or4port C(30)   DEFAULT "",
    to_or5form C(10)   DEFAULT "",
    to_or5off  L       DEFAULT .F.,
    to_or5port C(30)   DEFAULT "",
    to_or6form C(10)   DEFAULT "",
    to_or6off  L       DEFAULT .F.,
    to_or6port C(30)   DEFAULT "",
    to_or7form C(10)   DEFAULT "",
    to_or7off  L       DEFAULT .F.,
    to_or7port C(30)   DEFAULT "",
    to_plevnr  N(1,0)  DEFAULT 0,
    to_prdriv1 C(10)   DEFAULT "",
    to_prdriv2 C(10)   DEFAULT "",
    to_prdriv3 C(10)   DEFAULT "",
    to_prdriv4 C(10)   DEFAULT "",
    to_prdriv5 C(10)   DEFAULT "",
    to_prdriv6 C(10)   DEFAULT "",
    to_prhs1   N(1,0)  DEFAULT 0,
    to_prhs2   N(1,0)  DEFAULT 0,
    to_prhs3   N(1,0)  DEFAULT 0,
    to_prhs4   N(1,0)  DEFAULT 0,
    to_prhs5   N(1,0)  DEFAULT 0,
    to_prhs6   N(1,0)  DEFAULT 0,
    to_prport1 C(4)    DEFAULT "",
    to_prport2 C(4)    DEFAULT "",
    to_prport3 C(4)    DEFAULT "",
    to_prport4 C(4)    DEFAULT "",
    to_prport5 C(4)    DEFAULT "",
    to_prport6 C(4)    DEFAULT "",
    to_prset1  C(20)   DEFAULT "",
    to_prset2  C(20)   DEFAULT "",
    to_prset3  C(20)   DEFAULT "",
    to_prset4  C(20)   DEFAULT "",
    to_prset5  C(20)   DEFAULT "",
    to_prset6  C(20)   DEFAULT "",
    to_prshar1 C(10)   DEFAULT "",
    to_prshar2 C(10)   DEFAULT "",
    to_prshar3 C(10)   DEFAULT "",
    to_prshar4 C(10)   DEFAULT "",
    to_prshar5 C(10)   DEFAULT "",
    to_prshar6 C(10)   DEFAULT "",
    to_prstmp1 L       DEFAULT .F.,
    to_prstmp2 L       DEFAULT .F.,
    to_prstmp3 L       DEFAULT .F.,
    to_prstmp4 L       DEFAULT .F.,
    to_prstmp5 L       DEFAULT .F.,
    to_prstmp6 L       DEFAULT .F.,
    to_prtloc  L       DEFAULT .F.,
    to_prtmode N(1,0)  DEFAULT 0,
    to_rcheksu N(16,0) DEFAULT 0,
    to_rcpform C(10)   DEFAULT "",
    to_rcpoff  L       DEFAULT .F.,
    to_rcpport C(30)   DEFAULT "",
    to_request N(2,0)  DEFAULT 0,
    to_screen  C(10)   DEFAULT "",
    to_slpform C(10)   DEFAULT "",
    to_slpoff  L       DEFAULT .F.,
    to_slpport C(30)   DEFAULT "",
    to_solnoua L       DEFAULT .F.,
    to_useoms  L       DEFAULT .F.,
    to_winname C(15)   DEFAULT "",
    to_xport   C(30)   DEFAULT "",
    to_z1port  C(30)   DEFAULT "",
    to_z2port  C(30)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    to_appfile,
    to_barcode,
    to_cardrea,
    to_dcheksu,
    to_deleted,
    to_descr,
    to_dscform,
    to_dscoff,
    to_dscport,
    to_elcltid,
    to_elksz2,
    to_elpcph,
    to_elpcpn,
    to_elpcps,
    to_elpcrt,
    to_elpcrw,
    to_elpdir,
    to_elpport,
    to_elte1,
    to_elte2,
    to_elte3,
    to_eltimeo,
    to_elts1,
    to_elts2,
    to_elts3,
    to_elwidth,
    to_login,
    to_omannr,
    to_or1form,
    to_or1off,
    to_or1port,
    to_or2form,
    to_or2off,
    to_or2port,
    to_or3form,
    to_or3off,
    to_or3port,
    to_or4form,
    to_or4off,
    to_or4port,
    to_or5form,
    to_or5off,
    to_or5port,
    to_or6form,
    to_or6off,
    to_or6port,
    to_or7form,
    to_or7off,
    to_or7port,
    to_plevnr,
    to_prdriv1,
    to_prdriv2,
    to_prdriv3,
    to_prdriv4,
    to_prdriv5,
    to_prdriv6,
    to_prhs1,
    to_prhs2,
    to_prhs3,
    to_prhs4,
    to_prhs5,
    to_prhs6,
    to_prport1,
    to_prport2,
    to_prport3,
    to_prport4,
    to_prport5,
    to_prport6,
    to_prset1,
    to_prset2,
    to_prset3,
    to_prset4,
    to_prset5,
    to_prset6,
    to_prshar1,
    to_prshar2,
    to_prshar3,
    to_prshar4,
    to_prshar5,
    to_prshar6,
    to_prstmp1,
    to_prstmp2,
    to_prstmp3,
    to_prstmp4,
    to_prstmp5,
    to_prstmp6,
    to_prtloc,
    to_prtmode,
    to_rcheksu,
    to_rcpform,
    to_rcpoff,
    to_rcpport,
    to_request,
    to_screen,
    to_slpform,
    to_slpoff,
    to_slpport,
    to_solnoua,
    to_useoms,
    to_winname,
    to_xport,
    to_z1port,
    to_z2port
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    to_appfile tmoman.to_appfile,
    to_barcode tmoman.to_barcode,
    to_cardrea tmoman.to_cardrea,
    to_dcheksu tmoman.to_dcheksu,
    to_deleted tmoman.to_deleted,
    to_descr   tmoman.to_descr,
    to_dscform tmoman.to_dscform,
    to_dscoff  tmoman.to_dscoff,
    to_dscport tmoman.to_dscport,
    to_elcltid tmoman.to_elcltid,
    to_elksz2  tmoman.to_elksz2,
    to_elpcph  tmoman.to_elpcph,
    to_elpcpn  tmoman.to_elpcpn,
    to_elpcps  tmoman.to_elpcps,
    to_elpcrt  tmoman.to_elpcrt,
    to_elpcrw  tmoman.to_elpcrw,
    to_elpdir  tmoman.to_elpdir,
    to_elpport tmoman.to_elpport,
    to_elte1   tmoman.to_elte1,
    to_elte2   tmoman.to_elte2,
    to_elte3   tmoman.to_elte3,
    to_eltimeo tmoman.to_eltimeo,
    to_elts1   tmoman.to_elts1,
    to_elts2   tmoman.to_elts2,
    to_elts3   tmoman.to_elts3,
    to_elwidth tmoman.to_elwidth,
    to_login   tmoman.to_login,
    to_omannr  tmoman.to_omannr,
    to_or1form tmoman.to_or1form,
    to_or1off  tmoman.to_or1off,
    to_or1port tmoman.to_or1port,
    to_or2form tmoman.to_or2form,
    to_or2off  tmoman.to_or2off,
    to_or2port tmoman.to_or2port,
    to_or3form tmoman.to_or3form,
    to_or3off  tmoman.to_or3off,
    to_or3port tmoman.to_or3port,
    to_or4form tmoman.to_or4form,
    to_or4off  tmoman.to_or4off,
    to_or4port tmoman.to_or4port,
    to_or5form tmoman.to_or5form,
    to_or5off  tmoman.to_or5off,
    to_or5port tmoman.to_or5port,
    to_or6form tmoman.to_or6form,
    to_or6off  tmoman.to_or6off,
    to_or6port tmoman.to_or6port,
    to_or7form tmoman.to_or7form,
    to_or7off  tmoman.to_or7off,
    to_or7port tmoman.to_or7port,
    to_plevnr  tmoman.to_plevnr,
    to_prdriv1 tmoman.to_prdriv1,
    to_prdriv2 tmoman.to_prdriv2,
    to_prdriv3 tmoman.to_prdriv3,
    to_prdriv4 tmoman.to_prdriv4,
    to_prdriv5 tmoman.to_prdriv5,
    to_prdriv6 tmoman.to_prdriv6,
    to_prhs1   tmoman.to_prhs1,
    to_prhs2   tmoman.to_prhs2,
    to_prhs3   tmoman.to_prhs3,
    to_prhs4   tmoman.to_prhs4,
    to_prhs5   tmoman.to_prhs5,
    to_prhs6   tmoman.to_prhs6,
    to_prport1 tmoman.to_prport1,
    to_prport2 tmoman.to_prport2,
    to_prport3 tmoman.to_prport3,
    to_prport4 tmoman.to_prport4,
    to_prport5 tmoman.to_prport5,
    to_prport6 tmoman.to_prport6,
    to_prset1  tmoman.to_prset1,
    to_prset2  tmoman.to_prset2,
    to_prset3  tmoman.to_prset3,
    to_prset4  tmoman.to_prset4,
    to_prset5  tmoman.to_prset5,
    to_prset6  tmoman.to_prset6,
    to_prshar1 tmoman.to_prshar1,
    to_prshar2 tmoman.to_prshar2,
    to_prshar3 tmoman.to_prshar3,
    to_prshar4 tmoman.to_prshar4,
    to_prshar5 tmoman.to_prshar5,
    to_prshar6 tmoman.to_prshar6,
    to_prstmp1 tmoman.to_prstmp1,
    to_prstmp2 tmoman.to_prstmp2,
    to_prstmp3 tmoman.to_prstmp3,
    to_prstmp4 tmoman.to_prstmp4,
    to_prstmp5 tmoman.to_prstmp5,
    to_prstmp6 tmoman.to_prstmp6,
    to_prtloc  tmoman.to_prtloc,
    to_prtmode tmoman.to_prtmode,
    to_rcheksu tmoman.to_rcheksu,
    to_rcpform tmoman.to_rcpform,
    to_rcpoff  tmoman.to_rcpoff,
    to_rcpport tmoman.to_rcpport,
    to_request tmoman.to_request,
    to_screen  tmoman.to_screen,
    to_slpform tmoman.to_slpform,
    to_slpoff  tmoman.to_slpoff,
    to_slpport tmoman.to_slpport,
    to_solnoua tmoman.to_solnoua,
    to_useoms  tmoman.to_useoms,
    to_winname tmoman.to_winname,
    to_xport   tmoman.to_xport,
    to_z1port  tmoman.to_z1port,
    to_z2port  tmoman.to_z2port
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS causer AS caBase OF common\libs\cit_ca.vcx
Alias = [causer]
Tables = [user]
KeyFieldList = [us_user]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       us_active,
       us_deleted,
       us_name,
       us_passwrd,
       us_user,
       us_usergrp,
       us_winuser
    FROM user
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    us_active  L       DEFAULT .F.,
    us_deleted L       DEFAULT .F.,
    us_name    C(30)   DEFAULT "",
    us_passwrd C(5)    DEFAULT "",
    us_user    C(3)    DEFAULT "",
    us_usergrp C(3)    DEFAULT "",
    us_winuser C(15)   DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    us_active,
    us_deleted,
    us_name,
    us_passwrd,
    us_user,
    us_usergrp,
    us_winuser
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    us_active  user.us_active,
    us_deleted user.us_deleted,
    us_name    user.us_name,
    us_passwrd user.us_passwrd,
    us_user    user.us_user,
    us_usergrp user.us_usergrp,
    us_winuser user.us_winuser
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS causergrp AS caBase OF common\libs\cit_ca.vcx
Alias = [causergrp]
Tables = [usergrp]
KeyFieldList = [ug_usergrp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       ug_archive,
       ug_calimit,
       ug_custact,
       ug_deleted,
       ug_descr,
       ug_financ,
       ug_guests,
       ug_invent,
       ug_inveset,
       ug_invt,
       ug_maint,
       ug_param,
       ug_person,
       ug_prtform,
       ug_report,
       ug_reset,
       ug_scrnkey,
       ug_sdata,
       ug_term,
       ug_tools,
       ug_user,
       ug_usergrp
    FROM usergrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    ug_archive L       DEFAULT .F.,
    ug_calimit L       DEFAULT .F.,
    ug_custact L       DEFAULT .F.,
    ug_deleted L       DEFAULT .F.,
    ug_descr   C(20)   DEFAULT "",
    ug_financ  L       DEFAULT .F.,
    ug_guests  L       DEFAULT .F.,
    ug_invent  L       DEFAULT .F.,
    ug_inveset L       DEFAULT .F.,
    ug_invt    L       DEFAULT .F.,
    ug_maint   L       DEFAULT .F.,
    ug_param   L       DEFAULT .F.,
    ug_person  L       DEFAULT .F.,
    ug_prtform L       DEFAULT .F.,
    ug_report  L       DEFAULT .F.,
    ug_reset   L       DEFAULT .F.,
    ug_scrnkey L       DEFAULT .F.,
    ug_sdata   L       DEFAULT .F.,
    ug_term    L       DEFAULT .F.,
    ug_tools   L       DEFAULT .F.,
    ug_user    L       DEFAULT .F.,
    ug_usergrp C(3)    DEFAULT ""
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ug_archive,
    ug_calimit,
    ug_custact,
    ug_deleted,
    ug_descr,
    ug_financ,
    ug_guests,
    ug_invent,
    ug_inveset,
    ug_invt,
    ug_maint,
    ug_param,
    ug_person,
    ug_prtform,
    ug_report,
    ug_reset,
    ug_scrnkey,
    ug_sdata,
    ug_term,
    ug_tools,
    ug_user,
    ug_usergrp
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    ug_archive usergrp.ug_archive,
    ug_calimit usergrp.ug_calimit,
    ug_custact usergrp.ug_custact,
    ug_deleted usergrp.ug_deleted,
    ug_descr   usergrp.ug_descr,
    ug_financ  usergrp.ug_financ,
    ug_guests  usergrp.ug_guests,
    ug_invent  usergrp.ug_invent,
    ug_inveset usergrp.ug_inveset,
    ug_invt    usergrp.ug_invt,
    ug_maint   usergrp.ug_maint,
    ug_param   usergrp.ug_param,
    ug_person  usergrp.ug_person,
    ug_prtform usergrp.ug_prtform,
    ug_report  usergrp.ug_report,
    ug_reset   usergrp.ug_reset,
    ug_scrnkey usergrp.ug_scrnkey,
    ug_sdata   usergrp.ug_sdata,
    ug_term    usergrp.ug_term,
    ug_tools   usergrp.ug_tools,
    ug_user    usergrp.ug_user,
    ug_usergrp usergrp.ug_usergrp
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cavatgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [cavatgrp]
Tables = [vatgrp]
KeyFieldList = [vt_vatnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       vt_deleted,
       vt_descr,
       vt_fovat,
       vt_fpvat,
       vt_ftvat,
       vt_vatnr,
       vt_vatpct
    FROM vatgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    vt_deleted L       DEFAULT .F.,
    vt_descr   C(20)   DEFAULT "",
    vt_fovat   N(1,0)  DEFAULT 0,
    vt_fpvat   C(2)    DEFAULT "",
    vt_ftvat   C(2)    DEFAULT "",
    vt_vatnr   N(1,0)  DEFAULT 0,
    vt_vatpct  N(4,1)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    vt_deleted,
    vt_descr,
    vt_fovat,
    vt_fpvat,
    vt_ftvat,
    vt_vatnr,
    vt_vatpct
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    vt_deleted vatgrp.vt_deleted,
    vt_descr   vatgrp.vt_descr,
    vt_fovat   vatgrp.vt_fovat,
    vt_fpvat   vatgrp.vt_fpvat,
    vt_ftvat   vatgrp.vt_ftvat,
    vt_vatnr   vatgrp.vt_vatnr,
    vt_vatpct  vatgrp.vt_vatpct
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cawaiter AS caBase OF common\libs\cit_ca.vcx
Alias = [cawaiter]
Tables = [waiter]
KeyFieldList = [wt_waitnr]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       wt_active,
       wt_deleted,
       wt_fplogin,
       wt_fprint,
       wt_key,
       wt_name,
       wt_nokey,
       wt_omankey,
       wt_pass,
       wt_waitgrp,
       wt_waitnr
    FROM waiter
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    wt_active  L       DEFAULT .F.,
    wt_deleted L       DEFAULT .F.,
    wt_fplogin L       DEFAULT .F.,
    wt_fprint  M       DEFAULT "",
    wt_key     C(50)   DEFAULT "",
    wt_name    C(30)   DEFAULT "",
    wt_nokey   L       DEFAULT .F.,
    wt_omankey C(10)   DEFAULT "",
    wt_pass    N(4,0)  DEFAULT 0,
    wt_waitgrp C(3)    DEFAULT "",
    wt_waitnr  N(3,0)  DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wt_active,
    wt_deleted,
    wt_fplogin,
    wt_fprint,
    wt_key,
    wt_name,
    wt_nokey,
    wt_omankey,
    wt_pass,
    wt_waitgrp,
    wt_waitnr
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wt_active  waiter.wt_active,
    wt_deleted waiter.wt_deleted,
    wt_fplogin waiter.wt_fplogin,
    wt_fprint  waiter.wt_fprint,
    wt_key     waiter.wt_key,
    wt_name    waiter.wt_name,
    wt_nokey   waiter.wt_nokey,
    wt_omankey waiter.wt_omankey,
    wt_pass    waiter.wt_pass,
    wt_waitgrp waiter.wt_waitgrp,
    wt_waitnr  waiter.wt_waitnr
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cawaitgrp AS caBase OF common\libs\cit_ca.vcx
Alias = [cawaitgrp]
Tables = [waitgrp]
KeyFieldList = [wg_waitgrp]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       wg_alltbls,
       wg_cashchg,
       wg_cashin,
       wg_cashout,
       wg_deleted,
       wg_descr,
       wg_dirsale,
       wg_discnt,
       wg_exit,
       wg_extart,
       wg_ftshtdw,
       wg_ftstart,
       wg_ledger,
       wg_multlog,
       wg_negpric,
       wg_opendrw,
       wg_openprc,
       wg_owner,
       wg_paymnt,
       wg_payvoid,
       wg_peronly,
       wg_prclev,
       wg_refnd,
       wg_reopen,
       wg_rmchrg,
       wg_spil,
       wg_split,
       wg_tblres,
       wg_ulrefnd,
       wg_void,
       wg_voucher,
       wg_waitgrp,
       wg_x,
       wg_xterm,
       wg_xwait,
       wg_z1,
       wg_z1term,
       wg_z2
    FROM waitgrp
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    wg_alltbls L       DEFAULT .F.,
    wg_cashchg L       DEFAULT .F.,
    wg_cashin  L       DEFAULT .F.,
    wg_cashout L       DEFAULT .F.,
    wg_deleted L       DEFAULT .F.,
    wg_descr   C(20)   DEFAULT "",
    wg_dirsale L       DEFAULT .F.,
    wg_discnt  L       DEFAULT .F.,
    wg_exit    L       DEFAULT .F.,
    wg_extart  L       DEFAULT .F.,
    wg_ftshtdw L       DEFAULT .F.,
    wg_ftstart L       DEFAULT .F.,
    wg_ledger  L       DEFAULT .F.,
    wg_multlog L       DEFAULT .F.,
    wg_negpric L       DEFAULT .F.,
    wg_opendrw L       DEFAULT .F.,
    wg_openprc L       DEFAULT .F.,
    wg_owner   L       DEFAULT .F.,
    wg_paymnt  L       DEFAULT .F.,
    wg_payvoid L       DEFAULT .F.,
    wg_peronly L       DEFAULT .F.,
    wg_prclev  L       DEFAULT .F.,
    wg_refnd   L       DEFAULT .F.,
    wg_reopen  L       DEFAULT .F.,
    wg_rmchrg  L       DEFAULT .F.,
    wg_spil    L       DEFAULT .F.,
    wg_split   L       DEFAULT .F.,
    wg_tblres  L       DEFAULT .F.,
    wg_ulrefnd L       DEFAULT .F.,
    wg_void    L       DEFAULT .F.,
    wg_voucher L       DEFAULT .F.,
    wg_waitgrp C(3)    DEFAULT "",
    wg_x       L       DEFAULT .F.,
    wg_xterm   L       DEFAULT .F.,
    wg_xwait   L       DEFAULT .F.,
    wg_z1      L       DEFAULT .F.,
    wg_z1term  L       DEFAULT .F.,
    wg_z2      L       DEFAULT .F.
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wg_alltbls,
    wg_cashchg,
    wg_cashin,
    wg_cashout,
    wg_deleted,
    wg_descr,
    wg_dirsale,
    wg_discnt,
    wg_exit,
    wg_extart,
    wg_ftshtdw,
    wg_ftstart,
    wg_ledger,
    wg_multlog,
    wg_negpric,
    wg_opendrw,
    wg_openprc,
    wg_owner,
    wg_paymnt,
    wg_payvoid,
    wg_peronly,
    wg_prclev,
    wg_refnd,
    wg_reopen,
    wg_rmchrg,
    wg_spil,
    wg_split,
    wg_tblres,
    wg_ulrefnd,
    wg_void,
    wg_voucher,
    wg_waitgrp,
    wg_x,
    wg_xterm,
    wg_xwait,
    wg_z1,
    wg_z1term,
    wg_z2
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wg_alltbls waitgrp.wg_alltbls,
    wg_cashchg waitgrp.wg_cashchg,
    wg_cashin  waitgrp.wg_cashin,
    wg_cashout waitgrp.wg_cashout,
    wg_deleted waitgrp.wg_deleted,
    wg_descr   waitgrp.wg_descr,
    wg_dirsale waitgrp.wg_dirsale,
    wg_discnt  waitgrp.wg_discnt,
    wg_exit    waitgrp.wg_exit,
    wg_extart  waitgrp.wg_extart,
    wg_ftshtdw waitgrp.wg_ftshtdw,
    wg_ftstart waitgrp.wg_ftstart,
    wg_ledger  waitgrp.wg_ledger,
    wg_multlog waitgrp.wg_multlog,
    wg_negpric waitgrp.wg_negpric,
    wg_opendrw waitgrp.wg_opendrw,
    wg_openprc waitgrp.wg_openprc,
    wg_owner   waitgrp.wg_owner,
    wg_paymnt  waitgrp.wg_paymnt,
    wg_payvoid waitgrp.wg_payvoid,
    wg_peronly waitgrp.wg_peronly,
    wg_prclev  waitgrp.wg_prclev,
    wg_refnd   waitgrp.wg_refnd,
    wg_reopen  waitgrp.wg_reopen,
    wg_rmchrg  waitgrp.wg_rmchrg,
    wg_spil    waitgrp.wg_spil,
    wg_split   waitgrp.wg_split,
    wg_tblres  waitgrp.wg_tblres,
    wg_ulrefnd waitgrp.wg_ulrefnd,
    wg_void    waitgrp.wg_void,
    wg_voucher waitgrp.wg_voucher,
    wg_waitgrp waitgrp.wg_waitgrp,
    wg_x       waitgrp.wg_x,
    wg_xterm   waitgrp.wg_xterm,
    wg_xwait   waitgrp.wg_xwait,
    wg_z1      waitgrp.wg_z1,
    wg_z1term  waitgrp.wg_z1term,
    wg_z2      waitgrp.wg_z2
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS cawaitlog AS caBase OF common\libs\cit_ca.vcx
Alias = [cawaitlog]
Tables = [waitlog]
KeyFieldList = [wl_wlid]
PROCEDURE SetCommandProps
TEXT TO this.SelectCmd TEXTMERGE NOSHOW PRETEXT 1+2+8
SELECT
       wl_action,
       wl_author,
       wl_chkid,
       wl_logged,
       wl_newval,
       wl_oldval,
       wl_orderid,
       wl_paymid,
       wl_paynr,
       wl_sysdate,
       wl_tableid,
       wl_tablenr,
       wl_termnr,
       wl_waitnr,
       wl_wlid
    FROM waitlog
ENDTEXT
TEXT TO this.CursorSchema TEXTMERGE NOSHOW PRETEXT 1+2+8
    wl_action  C(10)   DEFAULT "",
    wl_author  N(3,0)  DEFAULT 0,
    wl_chkid   I       DEFAULT 0,
    wl_logged  T       DEFAULT {},
    wl_newval  C(50)   DEFAULT "",
    wl_oldval  C(50)   DEFAULT "",
    wl_orderid I       DEFAULT 0,
    wl_paymid  I       DEFAULT 0,
    wl_paynr   N(2,0)  DEFAULT 0,
    wl_sysdate D       DEFAULT {},
    wl_tableid I       DEFAULT 0,
    wl_tablenr N(4,0)  DEFAULT 0,
    wl_termnr  N(2,0)  DEFAULT 0,
    wl_waitnr  N(3,0)  DEFAULT 0,
    wl_wlid    I       DEFAULT 0
ENDTEXT
TEXT TO this.UpdatableFieldList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wl_action,
    wl_author,
    wl_chkid,
    wl_logged,
    wl_newval,
    wl_oldval,
    wl_orderid,
    wl_paymid,
    wl_paynr,
    wl_sysdate,
    wl_tableid,
    wl_tablenr,
    wl_termnr,
    wl_waitnr,
    wl_wlid
ENDTEXT
TEXT TO this.UpdateNameList TEXTMERGE NOSHOW PRETEXT 1+2+8
    wl_action  waitlog.wl_action,
    wl_author  waitlog.wl_author,
    wl_chkid   waitlog.wl_chkid,
    wl_logged  waitlog.wl_logged,
    wl_newval  waitlog.wl_newval,
    wl_oldval  waitlog.wl_oldval,
    wl_orderid waitlog.wl_orderid,
    wl_paymid  waitlog.wl_paymid,
    wl_paynr   waitlog.wl_paynr,
    wl_sysdate waitlog.wl_sysdate,
    wl_tableid waitlog.wl_tableid,
    wl_tablenr waitlog.wl_tablenr,
    wl_termnr  waitlog.wl_termnr,
    wl_waitnr  waitlog.wl_waitnr,
    wl_wlid    waitlog.wl_wlid
ENDTEXT

DODEFAULT()
ENDPROC
ENDDEFINE
*
DEFINE CLASS caworkbrk AS caBase OF common\libs\cit_ca.vcx
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
    wb_wbid    I       DEFAULT 0,
    wb_whid    I       DEFAULT 0
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
DEFINE CLASS caworkbrkd AS caBase OF common\libs\cit_ca.vcx
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
DEFINE CLASS caworkint AS caBase OF common\libs\cit_ca.vcx
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
    wi_emid    I       DEFAULT 0,
    wi_end     T       DEFAULT {},
    wi_sysdate D       DEFAULT {},
    wi_whid    I       DEFAULT 0
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
DEFINE CLASS cazipcode AS caBase OF common\libs\cit_ca.vcx
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
    zc_zcid    I       DEFAULT 0,
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
