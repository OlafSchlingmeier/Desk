FUNCTION UpdTbl
LPARAMETERS DoLogin
IF PCOUNT()=0
	DoLogin = .T.
ENDIF
Close Tables All
LOCAL l_cPath
l_cPath = SET("Path")
IF NOT UPPER("data") $ l_cPath
	SET PATH TO (IIF(EMPTY(l_cPath),"data",l_cPath + ";data"))
ENDIF
ProcCryptor()
IF !USED('files')
	USE data\files ALIAS files IN 0
ENDIF
SELECT files
SET ORDER TO tag1
IF !USED('fields')
	USE data\fields ALIAS fields IN 0
ENDIF
SELECT fields
SET ORDER TO 1
CREATE CURSOR tblUpdTblFailed (uf_action C(100), uf_table C(8))

***********************
* GROUP
AddField('group','gr_multipr','C (16)','Array with rights in the Multiproper Menu')

* BQBESTHL
addfield('bqbesthl','bq_order','n (3)','Konferenzraum -Bestuhlung Sortierung in sheet.scx')
addindex('bqbesthl','tag2','bq_order')

* piart
addfield('piart','pi_maingbn','c (50)')
addfield('piart','pi_amnotax','n (10,2)')
addindex('piart','tag1','pi_piid',,.T.)
UpdateFilesTbl('piart','.F.',3,'','','','Import von externe Kasse - Buchungen')

* pipay
addfield('pipay','pp_amount','n (10,2)')
addindex('pipay','tag1','pp_ppid',,.T.)
UpdateFilesTbl('pipay','.F.',3,'','','','Import von externe Kasse - Zahlungen')

* pichk
addfield('pichk','pz_sysdate','d (8)')
addindex('pichk','tag1','pz_pzid',,.T.)
UpdateFilesTbl('pichk','.F.',3,'','','','Import von externe Kasse - Rechnungen')

* bproener
addfield('bproener','be_tempera','n (4,1)')

* elpay
addfield('elpay','el_print','m (4)')
addindex('elpay','tag2','el_postid')
UpdateFilesTbl('elpay','.F.',4,'','','','elPay Tabelle, verkn�pfung zu post/histpost �ber el_postid','el_elid')

*HISTRES
addfield('histres','hr_usrres0','c (100)')
addfield('histres','hr_bmsto1w','C (6)','Flags for BMS points from 2-6 windows to 1 window address')
addfield('histres','hr_emailst','n (1)','Flags for sending auto. E-Mail. 0 - not send, 1 - sent arr., 2 - sent dep.')
addfield('histres','hr_rglayou','c (7)','Store g_billstyle for Bills in History; 7th char. (0-5 bits) - use UD booking date')
addfield('histres','hr_ccauth','c (32)')
addfield('histres','hr_ccexpy','c (32)')
addfield('histres','hr_ccnum','c (32)')
addfield('histres','hr_lstart','c (3)','Start location (building)')
addfield('histres','hr_lfinish','c (3)','Finish location (building)')
addfield('histres','hr_apname','c (50)','Contact Name')
addindex('histres','tag16','hr_created')
addindex('histres','tag17','hr_roomnum+DTOS(hr_depdate)')

*PICKLIST
addfield('picklist','pl_inactiv','l (1)','Dont use anymore')

*roomtype
addfield('roomtype','rt_wborder','n (2)','Webbooking RT - Roomtype assigning order')
addfield('roomtype','rt_wbcusrt','c (4)','Webbooking RT - Custom roomtype')
addfield('roomtype','rt_wbmain','l (1)','Webbooking RT - Main roomtype')
addindex('roomtype','tag2','IIF(rt_sequenc=0,"ZZ",STR(rt_sequenc,2))+rt_roomtyp')

*cmrtavl
addfield('cmrtavl','cm_date','d (8)','Date')
addfield('cmrtavl','cm_roomtyp','c (4)','ID from rt_roomtyp')
addfield('cmrtavl','cm_perc','n (3)','Percent (Max. 100%)')
addindex('cmrtavl','tag1','cm_date')
UpdateFilesTbl('cmrtavl','.F.',3,'P','X','','Citadel Mobile roomtypes availability','CM_DATE, CM_ROOMTYP')

* RTYPEDEF
addfield('rtypedef','rd_maxpers','n (4)','Maximum persons per room of specified type')
addfield('rtypedef','rd_verent','l (1)','Vehicle rent')
addindex('rtypedef','tag2','rd_roomtyp')
UpdateFilesTbl('rtypedef','.T.',2,'L','P','','def. Zimmertypen')

* ROOM
addfield('room','rm_link','c (100)')
addfield('room','rm_geo','c (25)', 'Latitude, longitude address on Google Maps in DD (decimal degrees)')
addfield('room','rm_addrid','n (8)', 'Address ID of Web booking credentials')
addfield('room','rm_user4','c (50)', 'User field 4')
addfield('room','rm_user5','c (50)', 'User field 5')
addfield('room','rm_user6','c (50)', 'User field 6')
addfield('room','rm_user7','c (50)', 'User field 7')
addfield('room','rm_user8','c (50)', 'User field 8')
addfield('room','rm_user9','c (50)', 'User field 9')
addfield('room','rm_user10','c (50)', 'User field 10')
addfield('room','rm_ratecod','c (10)', 'Default ratecode for room')
addfield('room','rm_inactiv','l (10)', 'Set room as inactive and not bookable.')
addfield('room','rm_bedchld','n (2)', 'Number of beds only for children')
addfield('room','rm_bedchag','n (1)', 'Children beds from age - 1,2 or 3 from param.pa_childs')
addfield('room','rm_bedchfr','n (1)', 'Children beds are free from age - 1,2 or 3 from param.pa_childs')
addfield('room','rm_linkifc','l (1)', 'Create ACT, IN, OUT files in ifc directory also for linked rooms')
addindex('room','tag7','rm_roomtyp')

* ROOMFEAT
addfield('roomfeat','rf_resfix','l (1)','Use artinum for fixed charges')
addfield('roomfeat','rf_artinum','n (4)','Artinum for fixed charges')
addfield('roomfeat','rf_units','n (4)','Units for fixed charges')
addfield('roomfeat','rf_price','b (2)','Price for fixed charge')
addfield('roomfeat','rf_package','l (1)','wenn TRUE - Fixleistung wird als Package gebucht')
addfield('roomfeat','rf_alldays','l (1)','Fixed charges for all days')

*param
addfield('param','pa_payonld','n (3)','Payment On Ledger (number in PayMethod)')
addfield('param','pa_rndpay','n (3)','Paymethod to post roundings on')

*param2
addfield('param2','pa_agnbwin','i (4)','Default bill window for agent.')
addfield('param2','pa_connew','l (1)','Show conference reservations from resrate times')
addfield('param2','pa_cwcompr','l (1)',"Compare standard rates with Citweb rates in Rate code's form.")
addfield('param2','pa_wrndmin','n (2)',"Working hours rounding in minutes")
addfield('param2','pa_resnotf','n (2)',"Font size for note editbox (rs_note) in reservation mask")
addfield('param2','pa_ppuser1','c (20)',"Description for Privacy policy user field 1")
addfield('param2','pa_ppuser2','c (20)',"Description for Privacy policy user field 2")
addfield('param2','pa_ppuser3','c (20)',"Description for Privacy policy user field 3")
addfield('param2','pa_ppuser4','c (20)',"Description for Privacy policy user field 4")
addfield('param2','pa_ppuser5','c (20)',"Description for Privacy policy user field 5")
addfield('param2','pa_ppuset1','c (1)',"Field type for Privacy policy user field 1")
addfield('param2','pa_ppuset2','c (1)',"Field type for Privacy policy user field 2")
addfield('param2','pa_ppuset3','c (1)',"Field type for Privacy policy user field 3")
addfield('param2','pa_ppuset4','c (1)',"Field type for Privacy policy user field 4")
addfield('param2','pa_ppuset5','c (1)',"Field type for Privacy policy user field 5")
addfield('param2','pa_delrstr','l (1)',"Delete log reservat table transactions in audit")
addfield('param2','pa_posssch','l (1)',"True when Schultes POS is used, with head and details in DAT file")
addfield('param2','pa_connold','l (1)','Show conference reservations from resrate times')
addfield('param2','pa_rminfo1','c (30)','Description for room maid additional info 1 (rs_rminfo1)')
addfield('param2','pa_rminfo2','c (30)','Description for room maid additional info 1 (rs_rminfo2)')
addfield('param2','pa_arhdate','d (8)','Last date in archive')
addfield('param2','pa_shbsprc','l (1)','Show fixed price in rate code combo')
addfield('param2','pa_globlid','c (13)',"Hotel's Global ID")
addfield('param2','pa_street','c (100)','Street')
addfield('param2','pa_manager','c (100)','Managing Director')
addfield('param2','pa_phone','c (20)','Phone number')
addfield('param2','pa_faxno','c (100)','Faxnumber')
addfield('param2','pa_email','c (100)','E-mail address')
addfield('param2','pa_website','c (60)','WebSite')
addfield('param2','pa_acctnr','c (30)','Description for room maid additional info 1 (rs_rminfo1)')
addfield('param2','pa_blz','c (20)','Bank code')
addfield('param2','pa_swift','c (15)','Bank SWIFT code')
addfield('param2','pa_iban','c (25)',"Company's IBAN code")
addfield('param2','pa_ustidnr','c (20)','Vat Nr. for forign company')
addfield('param2','pa_vatnr','c (20)','Vat Nr.')
addfield('param2','pa_bmspay','n (3)','Payment on BMS (number in PayMethod)')
UpdateFilesTbl('param2','.T.',3,'','','','More parameters')

*address
addfield('address','ad_memdat','d (8)','Member date')
addfield('address','ad_market','c (3)','Default market code to use with this address')
addfield('address','ad_source','c (3)','Default source code to use with this address')
addfield('address','ad_discnt','c (3)','Default discount code to use with this address')
addfield('address','ad_webpass','c (6)','Password for web booking')
addfield('address','ad_fax','c (100)','Faxnumber')
addfield('address','ad_usr9','c (100)','User definable field 9')
addindex('address','TAG29','IIF(EMPTY(ad_departm),REPLICATE(CHR(255),50),UPPER(ad_departm))')

*adrmain
addfield('adrmain','ad_mail5','C (3)','5. mailing code')
addfield('adrmain','ad_vipstat','n (2)','VIP Status from picklist pl_label="VIPSTATUS", from main server')
addfield('adrmain','ad_webpass','c (6)','Password for web booking')
addfield('adrmain','ad_fax','c (100)','Faxnumber')
addfield('adrmain','ad_note','m (4)','Note')
addindex('adrmain','TAG10','ad_phone')
UpdateFilesTbl('adrmain','.F.',11,'B','R','','Haupt Adressdatenbank')

*apartner
addfield('apartner','ap_fax','c (100)','Contact Fax')

*adrhot
addfield('adrhot','an_adid','i (4)','Foregin key ad_adid from adrmain')
addfield('adrhot','an_hotcode','c (10)','Foregin key ho_hotcode from hotcode')
addindex('adrhot','TAG1','an_adid')
UpdateFilesTbl('adrhot','.F.',11,'P','R','','In welchen Hotels ist Adresse vorhanden')

*adrphone
addfield('adrphone','aj_ajid','i (4)','ID')
addfield('adrphone','aj_phone','c (20)','Phone (digits are reversed)')
addfield('adrphone','aj_addrid','i (4)','ID from address')
addfield('adrphone','aj_apid','i (4)','ID from apartner')
addfield('adrphone','aj_field','c (10)','Field in address or apartner table')
addindex('adrphone','TAG1','aj_ajid')
addindex('adrphone','TAG2','aj_phone')
addindex('adrphone','TAG3','aj_addrid')
addindex('adrphone','TAG4','aj_apid')
UpdateFilesTbl('adrphone','.F.',1,'P','X','','Telefonnummern aus dem Adressbuch')

*id
addfield('id','id_clast','C (10)','Id last char')

*idmain
addfield('idmain','id_clast','C (10)','Id last char')
UpdateFilesTbl('idmain','.F.',11,'R','','','Ids on mainserver')

*reservat
addfield('reservat','rs_yoid','i','Reservation offer ID')
addfield('reservat','rs_rcsync','l (1)','Must sync prices in resrate and ressplit with ratearti')
addfield('reservat','rs_bmsto1w','C (5)','Flags for BMS points from 2-6 windows to 1 window address')
addfield('reservat','rs_emailst','n (1)','Flags for sending auto. E-Mail. 0 - not send, 1 - sent arr., 2 - sent dep.')
addfield('reservat','rs_odepdat','d','Reservation original departure date')
addfield('reservat','rs_rglayou','c (7)','Store g_billstyle for Bills; 7th char. (0-5 bits) - use UD booking date')
addfield('reservat','rs_mshwcco','c (2)','0->.F., 1->.T., 1. pos. -> show msg. on checkout, 2. pos. show msg. on modify.')
addfield('reservat','rs_ccauth','c (32)')
addfield('reservat','rs_ccexpy','c (32)')
addfield('reservat','rs_ccnum','c (32)')
addfield('reservat','rs_extflag','c (4)','Argus and Wellness flags')
addfield('reservat','rs_lstart','c (3)','Start location (building)')
addfield('reservat','rs_lfinish','c (3)','Finish location (building)')
addfield('reservat','rs_custom1','m (4)','Custom field 1 - For hotel installation specific data')
addfield('reservat','rs_bqkz','c (4)','Konferenzraum -Bestuhlung Kennzeichen')
addfield('reservat','rs_apname','c (50)','Contact lastname')
addfield('reservat','rs_rminfo1','m (4)','Room maid additional info 1')
addfield('reservat','rs_rminfo2','m (4)','Room maid additional info 2')
addfield('reservat','rs_doarch','l (1)',"Indicator that reservation must be archived")
addindex('reservat','tag35','rs_created')
addindex('reservat','tag36','rs_rmname+DTOS(rs_arrdate)+DTOS(rs_depdate)')
addindex('reservat','tag37','rs_lstart')
addindex('reservat','tag38','rs_lfinish')
UpdateFilesTbl('reservat','.T.',2,'P','','','Aktuelle (zuk�nftige) Reservierungen')

*resifcin
addfield('resifcin','rn_rsid','i (4)','Primary key from reservat.rs_rsid')
addfield('resifcin','rn_pin','c (12)','Password/PIN')
addfield('resifcin','rn_pttcls','c (10)','manual control of PTT Class of service')
addfield('resifcin','rn_ptvcls','c (10)','manual control of PTV Class of service')
addfield('resifcin','rn_intcls','c (10)','manual control of INT Class of service')
addfield('resifcin','rn_sync','n (1)','Sync signal. 0 - none, 1 - GI, 2 - GC, 3 - GI+GC')
addindex('resifcin','tag1','rn_rsid')
UpdateFilesTbl('resifcin','.T.',2,'P','','','Reservat interface for internet access','rn_rsid')

*rpostifc
addfield('rpostifc','rk_dsetid','i (4)','Primary key from post.ps_setid which canceled this access')
addindex('rpostifc','tag5','rk_to')
UpdateFilesTbl('rpostifc','.T.',2,'P','','','Link to post table for interface access','rk_rkid')

* H I S T P O S T 
* Don't forget to update audit.prg - FUNCTION HistPost !!!
addfield('histpost','hp_raid','n (10)','Ratearti ID for ratecode')
addfield('histpost','hp_rdate','d (8)','Logis date for which is ratecode posted')
addfield('histpost','hp_bdate','d (8)','User defined UD booking date')
AddField('histpost','hp_window','i','Bill window')
AddField('histpost','hp_supplem','c (150)','Supplement text, added by the user')
AddField('histpost','hp_buildng','c (3)','Building code from building.bu_buildng')
addfield('histpost','hp_paynum','n (3)','Payment number (zero when it is an article posting)')
addindex('histpost','tag8','hp_voucnum')
addindex('histpost','tag9','hp_rdate')

* POST
addfield('post','ps_raid','n (10)','Ratearti ID for ratecode')
addfield('post','ps_rdate','d (8)','Logis date for which is ratecode posted')
addfield('post','ps_bdate','d (8)','User defined UD booking date')
AddField('post','ps_window','i','Bill window the posting is on')
AddField('post','ps_supplem','c (150)','Supplementary text')
addfield('post','ps_paynum','n (3)','Paymethod number')
AddField('post','ps_buildng','c (3)','Building code from building.bu_buildng')
addindex('post','tag5','ps_setid')
addindex('post','tag6','ps_origid')

* POSTCXL
AddField('postcxl','ps_window','i')
addfield('postcxl','ps_paynum','n (3)')
AddField('postcxl','ps_raid','n(10)')

* POSTDISC
AddField('postdisc','pd_postid','n(8)','Posting ID')
AddField('postdisc','pd_origamt','b(2)','Original amount posted')
AddField('postdisc','pd_discnt','c(3)','Discount code')
AddField('postdisc','pd_discpct','n(3)','Discount percent [%]')
AddField('postdisc','pd_tmstamp','t','Time stamp')
AddField('postdisc','pd_userid','c(10)','User ID')
AddIndex('postdisc','tag1','pd_postid')
UpdateFilesTbl('postdisc','.T.',3,,,,'Post discounts','pd_postid')

* IFCLOST
AddField('ifclost','ps_window','i')
addfield('ifclost','ps_paynum','n (3)')
AddIndex('ifclost','tag2','ps_postid')

* ARACCT
AddField('aracct','ac_aracct','n(10)','A/R Account number')

* ARPOST
AddField('arpost','ap_aracct','n(10)','A/R Account')
addfield('arpost','ap_vblock','l (1)','Blocked deleting becouse of voucher not yet used')
addfield('arpost','ap_ref','c (150)','Reference')
addfield('arpost','ap_pagenr','n (3)','Page number')
addfield('arpost','ap_paynum','n (3)','FO Paymethod')
addindex('arpost','tag7','ap_billnr')
addindex('arpost','tag8','DTOS(ap_belgdat)+STR(ap_pagenr,3)')
UpdateFilesTbl('arpost','.T.',3,'P','','','erw. offene Debitoren')

* ARGENREM
AddField('argenrem','ag_acfrom','n(10)','From debitor no.')
AddField('argenrem','ag_acto','n(10)','To debitor no.')

* BILLNUM
AddField('billnum','bn_adrchgd','d (8)','SysDate when window/address was changed')
AddField('billnum','bn_userid','c (10)','Benutzer ID welcher die Rechnung erstellt hat')
AddField('billnum','bn_address','m (4)','Address on bill, when bill was issued')
AddField('billnum','bn_oldwin','i','Old bn_window')
AddField('billnum','bn_window','i','Rechnungsfenster bei Reservierung')
AddField('billnum','bn_rsid','i','Reservation ID')
addfield('billnum','bn_paynum','n (3)','Finanzweg f�r Rechnungsabschluss')
AddField('billnum','bn_qrcode','c (254)','Fiskaltrust QR code to be printed on bill')
AddField('billnum','bn_qrcodec','c (254)','Fiskaltrust QR code fo CXL bill')
AddField('billnum','bn_negnum','c (10)','Bill number with oposite/negativ items (Gutschrift)')
AddField('billnum','bn_pdf','l (1)','PDF/A-3 e-invoice file name created')
AddIndex('billnum','tag5','bn_adrchgd')

* BANQUET
AddField('banquet','bq_bqid','i','Reservation banquet ID')
AddIndex('banquet','tag4','bq_bqid')
UpdateFilesTbl('banquet','.T.',2,'Z','P','T','gebuchte Bankettartikel','bq_bqid')

* HBANQUET
AddField('hbanquet','bq_bqid','i','Reservation banquet ID')
AddIndex('hbanquet','tag2','bq_bqid')
UpdateFilesTbl('hbanquet','.T.',4,'','','','Bankettartikel historisch','bq_bqid')

* RESFIX
AddField('resfix','rf_rfid','i','Reservation fixed charges ID')
AddField('resfix','rf_forcurr','l (1)','Price in foreign currency, when ratecode is in foreign currency NOT EMPTY(rc_paynum)')
AddField('resfix','rf_showhk','l (1)','Show in house keeping list')
AddField('resfix','rf_feature','c (7)','Room Feature (rf_roomnum+rf_feature)')
AddIndex('resfix','tag2','rf_rfid')
UpdateFilesTbl('resfix','.T.',2,'P','T','','Fixleistungen','rf_rfid')

* HRESFIX
addfield('hresfix','rf_childs3','n (3)','No. of children of 3. cat. for ratecode in fixed charges')
addfield('hresfix','rf_forcurr','l (1)','Price in foreign currency, when ratecode is in foreign currency NOT EMPTY(rc_paynum)')
addfield('hresfix','rf_showhk','l (1)','Show in house keeping list')
addindex('hresfix','tag2','rf_rfid')
UpdateFilesTbl('hresfix','.T.',4,'','','','Fixleistungen historisch','rf_rfid')

* DEPOSIT
addfield('deposit','dp_remlast','d','Last reminder sent')
addfield('deposit','dp_receipt','i','Receipt number')
addfield('deposit','dp_recidet','m','Receipt details as json')
addfield('deposit','dp_percent','b (8)','Deposit percent [%] of reservation price')
addfield('deposit','dp_descrip','c (25)','Custom description of posting')
addfield('deposit','dp_supplem','c (25)','Supplementary text')
addfield('deposit','dp_paynum','n (3)','Paymethod Number')
addindex('deposit','tag7','dp_postid')

* HDEPOSIT
addfield('hdeposit','dp_remlast','d','Last reminder sent')
addfield('hdeposit','dp_receipt','i','Receipt number')
addfield('hdeposit','dp_recidet','m','Receipt details as json')
addfield('hdeposit','dp_percent','b (8)','Deposit percent [%] of reservation price')
addfield('hdeposit','dp_descrip','c (25)','Custom description of posting')
addfield('hdeposit','dp_supplem','c (25)','Supplementary text')
addfield('hdeposit','dp_paynum','n (3)','Paymethod Number')
addindex('hdeposit','tag2','dp_postid')
UpdateFilesTbl('hdeposit','.T.',4,'','','','Deposits historisch')

* HRESEXT
addfield('hresext','rs_yoid','i','Reservation offer ID')
addfield('hresext','rs_odepdat','d','Reservation original departure date')
addfield('hresext','rs_mshwcco','c (2)','0->.F., 1->.T., 1. pos. -> show msg. on checkout, 2. pos. show msg. on modify.')
addfield('hresext','rs_custom1','m (4)','Custom field 1 - For hotel installation specific data')
addfield('hresext','rs_rminfo1','m (4)','Room maid additional info 1')
addfield('hresext','rs_rminfo2','m (4)','Room maid additional info 2')
addfield('hresext','rs_bqkz','c (4)','Konferenzraum -Bestuhlung Kennzeichen')
addindex('hresext','tag3','rs_rsid')
UpdateFilesTbl('hresext','.T.',4,'','','','Reservierung historisch')

* PRICEAVG
addfield('priceavg','pv_high','b (8)','high boundary of the range')
addindex('priceavg','tag1','pv_pvid')
UpdateFilesTbl('priceavg','.T.',3,'','','','Durchschnittspreis Wertebereiche','pv_pvid')

* ADRSTINT
addfield('adrstint','ai_evid','n (8)','Event id')
addindex('adrstint','tag2','ai_evid')
UpdateFilesTbl('adrstint','.T.',1,'P','','','Bevorzugtes Buchungszeitraum f�r Adresse')

* ADRTOSI
addfield('adrtosi','ao_aiid','n (8)','Bevorzugtes Buchungszeitraum ID')
addindex('adrtosi','tag2','ao_aiid')
UpdateFilesTbl('adrtosi','.T.',1,'P','','','Verkn�pfung f�r Bevorzugtes Buchungszeitraum')

* ADINTRST
addfield('adintrst','ab_descrip','c (30)','Beschreibung')
addindex('adintrst','tag1','ab_abid')
UpdateFilesTbl('adintrst','.T.',1,'P','','','Interessen f�r Adresse')

* ADRTOIN
addfield('adrtoin','ae_abid','n (8)','Interessen ID')
addindex('adrtoin','tag2','ae_abid')
UpdateFilesTbl('adrtoin','.T.',1,'P','','','Verkn�pfung f�r Interessen')

* ADRRATES
addfield('adrrates','af_camnt3','b (8)','Vereinbartes Preis f�r 3. Kinder Kategorie')
addfield('adrrates','af_urcprc','l (1)','Use prices from selected ratecode')
addindex('adrrates','tag1','af_addrid')
UpdateFilesTbl('adrrates','.T.',1,'P','','','Vereinbarte Preise f�r Adresse')

* HOUTOFOR
addfield('houtofor','rs_msgshow','l (1)','Flag to be used in the Message screen, NOT standard')
addindex('houtofor','tag1','oo_id')
UpdateFilesTbl('houtofor','.T.',4,'','','','Out Of Order historisch')

* HOUTOFSR
addfield('houtofsr','os_todat','d (8)','Zimmer OOS Endedatum')
addindex('houtofsr','tag1','os_id')
UpdateFilesTbl('houtofsr','.T.',4,'','','','Out Of Service historisch')

* ACTION
addfield('action','at_reccur','t (8)','When created with reccurring, date of creation')
addfield('action','at_roomnum','c (4)','ID from room.roomnum')

* RATEPROP
addfield('rateprop','rd_valdate','d (8)','Ratecode property date value')
addindex('rateprop','tag4','rd_ratecod+DTOS(rd_valdate)')
UpdateFilesTbl('rateprop','.T.',3,'','','','Preiskode Eigenschaften')

* BILLINST
addfield('billinst','bi_day','n (3)','Day of booking for bill instructions restriction')
addindex('billinst','tag2','STR(bi_reserid,12,3)+STR(bi_day,3)')
UpdateFilesTbl('billinst','.T.',4,'','','','Restrictions for bill instructions')

* HBILLINS
addfield('hbillins','bi_day','n (3)','Day of booking for bill instructions restriction')
addindex('hbillins','tag2','STR(bi_reserid,12,3)+STR(bi_day,3)')
UpdateFilesTbl('hbillins','.T.',4,'','','','Restrictions for bill instructions')

* POSTCHNG
addfield('postchng','ph_newval','c (30)','New value of field')
addindex('postchng','tag1','ph_postid')
UpdateFilesTbl('postchng','.T.',3,'P','','','')

* HPOSTCNG
addfield('hpostcng','ph_newval','c (30)','New value of field')
addindex('hpostcng','tag2','ph_time')
UpdateFilesTbl('hpostcng','.T.',3,'','','','')

* ESENT
addfield('esent','es_attachm','n (2)','Number of attachments in the message')
addfield('esent','es_sysdate','d (8)','System date when message was created')
addfield('esent','es_rsid','i (4)','System date when message was created')
addindex('esent','tag1','es_esid')
addindex('esent','tag2','es_sysdate')
UpdateFilesTbl('esent','.T.',1,'','','','E-Mails - Sent')

* ESENTRCP
addfield('esentrcp','ec_apid','n (8)','')
addindex('esentrcp','tag2','STR(ec_addrid,8)+STR(ec_apid,8)')
UpdateFilesTbl('esentrcp','.T.',1,'','','','E-Mails - Sent - Recipts')

* EINBOX
addfield('einbox','ei_attachm','n (2)','Number of attachments in the message')
addindex('einbox','tag2','ei_msysid')
UpdateFilesTbl('einbox','.T.',1,'','','','E-Mails - Inbox')

* EINBOXSN
addfield('einboxsn','eb_apid','n (8)','')
addindex('einboxsn','tag2','STR(eb_addrid,8)+STR(eb_apid,8)')
UpdateFilesTbl('einboxsn','.T.',1,'','','','E-Mails - Inbox - Senders')

* EMPROP
addfield('emprop','ep_wbchmpe','l (1)','Webbooking - Calculate child also in max. persons')
addfield('emprop','ep_wbadman','l (1)','Webbooking - Street, ZIP, city and country are mandatory')
addfield('emprop','ep_wbrfpar','c (20)','Webbooking - First part of string in http query parameters for room features')
addfield('emprop','ep_wbrpalw','l (1)','Webbooking - Allow room plan for members')
addfield('emprop','ep_wbvoalw','l (1)','Webbooking - Allow enter voucher number on web site')
addfield('emprop','ep_wbnospl','l (1)',[Webbooking - Don't show split articles from ratecodes on web site])
addfield('emprop','ep_wbnogun','l (1)',[Webbooking - Don't show textboxes to enter guest names on web site])
addfield('emprop','ep_wbnocc','l (1)',[Webbooking - Don't show credit card fields on web site])
addfield('emprop','ep_wbnocus','l (1)',[Webbooking - Don't show textboxes to enter customer data on web site])
addfield('emprop','ep_wbbkpid','c (2)','Webbooking - 2 first letters for Bookind Id in extreser.er_uniquid field')
addfield('emprop','ep_wbnohna','l (1)',[Webbooking - Don't show message 'You are in HOTEL' on web site])
addfield('emprop','ep_wbexpir','i (4)',[Webbooking - In how many minutes expires offer for guest])
addfield('emprop','ep_wbratca','l (1)',[Webbooking - Show rates in calendar])
addfield('emprop','ep_wbnoirt','l (1)',[Webbooking - Don't show invalid room types])
addfield('emprop','ep_romcapt','m (4)',[Webbooking - Caption expression for room plan])
addfield('emprop','ep_wbonagp','l (1)',[Webbooking - Show only prices from sales module for logged in user])
addfield('emprop','ep_wbconf','l (1)',[Webbooking - Allow conference room types (rt_group=2)])
addfield('emprop','ep_wbccafc','l (1)',[Webbooking - Allow paying reservation with afc])
UpdateFilesTbl('emprop','.T.',1,'','','','E-Mail system settings')

* FINACCNT
addfield('finaccnt','fa_descr','c (50)','Description')
addindex('finaccnt','tag2','fa_descr')

* PAYMETHO
addfield('paymetho','pm_elpyman','l (1)','Enter creditcard number for elPay manualy')
addfield('paymetho','pm_elpyza','c (2)','elPay Zahlart -> gc, kk, sm')
addfield('paymetho','pm_usrgrp','c (100)','Usergroups that have access to the pay method')
addfield('paymetho','pm_aracct','n (10)','Link to A/R accounts')
AddField('paymetho','pm_buildng','c (3)','Building code')
addfield('paymetho','pm_aronly','l (1)','Use only in ledger payment')
addfield('paymetho','pm_kiosk','l (1)','Allow to use on kiosk')
addfield('paymetho','pm_paynum','n (3)','Paymethod number')
addfield('paymetho','pm_wbccafc','c (20)','Brand (credit card type) from afc. Link to extoffer.eo_wbccafc')

* SEASON
addfield('season','se_event','c (100)',"Season's event")
addfield('season','se_hotclos','l (1)','Statistik im Manager nicht berechnen')

*RESRATE
addfield('resrate','rr_curcoef','b (8)','Currency rate X')
addfield('resrate','rr_arrtime','c (5)','Arrival time for conference reservations')
addfield('resrate','rr_deptime','c (5)','Departure time for conference reservations')
addfield('resrate','rr_package','b (8)','Part of rate increased by split articles')
addindex('resrate','tag5','STR(rr_reserid,12,3)+LEFT(rr_status,2)+DTOS(rr_date)')
UpdateFilesTbl('resrate','.T.',2,'P','','','Daily reservation price')

*HRESRATE
addfield('hresrate','rr_curcoef','b (8)','Currency rate X')
addfield('hresrate','rr_arrtime','c (5)','Arrival time for conference reservations')
addfield('hresrate','rr_deptime','c (5)','Departure time for conference reservations')
addfield('hresrate','rr_package','b (8)','Part of rate increased by split articles')
addindex('hresrate','tag5','STR(rr_reserid,12,3)+LEFT(rr_status,2)+DTOS(rr_date)')
UpdateFilesTbl('hresrate','.T.',4,'','','','Daily reservation price historical')

*RESROOMS
addfield('resrooms','ri_shareid', 'n (8)','Sharer-ID')
addindex('resrooms','tag4','ri_roomnum')
addindex('resrooms','tag5','ri_date')
addindex('resrooms','tag6','ri_todate')
UpdateFilesTbl('resrooms','.T.',2,'P','','','Zimmerbuchungen')

*HRESROOM
addfield('hresroom','ri_shareid', 'n (8)','Sharer-ID')
addindex('hresroom','tag4','ri_roomnum')
addindex('hresroom','tag5','ri_date')
addindex('hresroom','tag6','ri_todate')
UpdateFilesTbl('hresroom','.T.',2,'','','','Zimmerbuchungen historisch')

* RESRMSHR
addfield('resrmshr','sr_rroomid','n (8)','Reservation room entry ID')
addindex('resrmshr','tag2','sr_rroomid')
UpdateFilesTbl('resrmshr','.T.',2,'B','N','P','Verbindung zw. Sharern u. Zimmerbuchung')

* EXTRESER
addfield('extreser','er_depamt1', 'b(2)', 'Deposit amount needed')
addfield('extreser','er_depdat1', 'd(8)', 'Deposit is due until')
addfield('extreser','er_cmid', 'c(32)', 'Channelmanager internal ID')
addfield('extreser','er_pin', 'c(8)', 'PIN code to access Webbooking reservation data')
addfield('extreser','er_offerid', 'c(32)', 'Offer id from extoffer table, when created from Webbooking.')
addindex('extreser','tag12','er_pmscxls')
UpdateFilesTbl('extreser','.T.',3,'','','','External reservations')

* EXTOFFER
addfield('extoffer','eo_eoid','i (4)', 'Unique ID')
addfield('extoffer','eo_offerid','c (32)', 'Offer id from extreser.er_offerid')
addfield('extoffer','eo_debit', 'b(2)', 'Debit amount to pay')
addfield('extoffer','eo_credit', 'b(2)', 'Paid amount')
addfield('extoffer','eo_chkoid','c (90)', 'Checkout id from afc')
addfield('extoffer','eo_currenc','c (10)', 'Currency from afc')
addfield('extoffer','eo_wbccafc','c (20)', 'Brand (credit card type) from afc. Link to paymetho.pm_wbccafc')
addfield('extoffer','eo_type','c (20)', 'Type from afc')
addfield('extoffer','eo_offer','m (4)', 'Offers from Webbooking for reservation created (json)')
addfield('extoffer','eo_booking','m (4)', 'Booking from Webbooking from which is reservation created (json)')
addfield('extoffer','eo_booked','t (8)', 'Timestamp when booking is created')
addfield('extoffer','eo_paylog','m (4)', 'Response from afc when payment is processed (json)')
addfield('extoffer','eo_paid','l (1)', 'True when debit is paid with afc')
addfield('extoffer','eo_import','l (1)', 'True when payment is imported in post table')
addindex('extoffer','tag1','eo_eoid')
addindex('extoffer','tag2','eo_offerid')
UpdateFilesTbl('extoffer','.F.',3,'P','','','Offers from Webbooking in extreser table','eo_eoid')

* EXTERROR
addfield('exterror','er_uniquid','c(50)')
addfield('exterror','er_company', 'c(50)')
addindex('exterror','tag10','er_status')
UpdateFilesTbl('exterror','.T.',3,'','','','External reservations')

* EXTVOUCH
addfield('extvouch','ve_deleted', 'l(1)', 'Deleted voucher')
addindex('extvouch','tag1','ve_veid',,.T.)
addindex('extvouch','tag2','ve_uniquid')
addindex('extvouch','tag3','ve_vouchno')
UpdateFilesTbl('extvouch','.T.',9,'X','','','External vouchers')

* RATEARTI
addfield('ratearti','ra_pctexma','l (1)','Calculate percent for extra article from main split article price')
addfield('ratearti','ra_pmlocal','l (1)','Local currency, when ratecode is in forign currency NOT EMPTY(rc_paynum)')
addfield('ratearti','ra_wservid','i (4)','Wellness service ID')
addfield('ratearti','ra_atblres','l (1)','If true then this split article generate table reservation in Argus')
addfield('ratearti','ra_user1','c (50)','User field 1')
addfield('ratearti','ra_user2','c (50)','User field 2')
addfield('ratearti','ra_user3','c (50)','User field 3')
addfield('ratearti','ra_user4','c (50)','User field 4')
addfield('ratearti','ra_note','m (4)','Note')
addfield('ratearti','ra_notef','m (4)','Note with format codes')
AddField('ratearti','ra_notep','m (4)','Note with format codes for printing')
addfield('ratearti','ra_package','l (1)','Increase price of reservation')
addindex('ratearti','tag2','ra_ratecod+STR(ra_raid,10)')
UpdateFilesTbl('ratearti','.T.',3,'P','','','Preiskode Artikelsplit')

* RESRART
addfield('resrart','ra_raid','n(10)','ratearti ID for articles')
addfield('resrart','ra_rsid','i(4)','Reservation ID')
addfield('resrart','ra_ratecod','c(23)','Ratecode the splitting article belongs to')
addfield('resrart','ra_rcsetid','n(8)','Ratecode set id')
addfield('resrart','ra_artinum','n(4)','Article to post charge on')
addfield('resrart','ra_artityp','n(1)','Splitting article type')
addfield('resrart','ra_amnt','b(2)','Amount to charge')
addfield('resrart','ra_exinfo','c(20)','Extra info for this split article')
addfield('resrart','ra_multipl','n(1)','Multiplier for the splitting amount')
addfield('resrart','ra_onlyon','n(3)','Charge only on certain day of the stay')
addfield('resrart','ra_pctexma','l(1)','Calculate percent for extra article from main split article price')
addfield('resrart','ra_pmlocal','l(1)','Local currency, when ratecode is in forign currency NOT EMPTY(rc_paynum)')
addfield('resrart','ra_ratepct','n(7,2)','Percentage of rate in reservation')
addfield('resrart','ra_sagroup','l(1)','Group this split article, as text in rc_salangX, on bill')
addfield('resrart','ra_wservid','i(4)','Wellness service ID')
addfield('resrart','ra_atblres','l(1)','If true then this split article generate table reservation in Argus')
addfield('resrart','ra_user1','c(50)','User field 1')
addfield('resrart','ra_user2','c(50)','User field 2')
addfield('resrart','ra_user3','c(50)','User field 3')
addfield('resrart','ra_user4','c(50)','User field 4')
addfield('resrart','ra_note','m (4)','Note')
addfield('resrart','ra_notef','m (4)','Note with format codes')
AddField('resrart','ra_notep','m (4)','Note with format codes for printing')
addfield('resrart','ra_package','l (1)','Increase price of reservation')
addindex('resrart','tag1','STR(ra_rsid,10)+ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4)')
addindex('resrart','tag2','STR(ra_rsid,10)+ra_ratecod+STR(ra_raid,10)')
addindex('resrart','tag3','ra_rsid')
UpdateFilesTbl('resrart','.T.',2,'P','T','','Custom split articles per reservation','ra_raid')

* HRESRART
addfield('hresrart','ra_raid','n(10)','ratearti ID for articles')
addfield('hresrart','ra_rsid','i(4)','Reservation ID')
addfield('hresrart','ra_ratecod','c(23)','Ratecode the splitting article belongs to')
addfield('hresrart','ra_rcsetid','n(8)','Ratecode set id')
addfield('hresrart','ra_artinum','n(4)','Article to post charge on')
addfield('hresrart','ra_artityp','n(1)','Splitting article type')
addfield('hresrart','ra_amnt','b(2)','Amount to charge')
addfield('hresrart','ra_exinfo','c(20)','Extra info for this split article')
addfield('hresrart','ra_multipl','n(1)','Multiplier for the splitting amount')
addfield('hresrart','ra_onlyon','n(3)','Charge only on certain day of the stay')
addfield('hresrart','ra_pctexma','l(1)','Calculate percent for extra article from main split article price')
addfield('hresrart','ra_pmlocal','l(1)','Local currency, when ratecode is in forign currency NOT EMPTY(rc_paynum)')
addfield('hresrart','ra_ratepct','n(7,2)','Percentage of rate in reservation')
addfield('hresrart','ra_sagroup','l(1)','Group this split article, as text in rc_salangX, on bill')
addfield('hresrart','ra_wservid','i(4)','Wellness service ID')
addfield('hresrart','ra_atblres','l(1)','If true then this split article generate table reservation in Argus')
addfield('hresrart','ra_user1','c(50)','User field 1')
addfield('hresrart','ra_user2','c(50)','User field 2')
addfield('hresrart','ra_user3','c(50)','User field 3')
addfield('hresrart','ra_user4','c(50)','User field 4')
addfield('hresrart','ra_note','m (4)','Note')
addfield('hresrart','ra_notef','m (4)','Note with format codes')
AddField('hresrart','ra_notep','m (4)','Note with format codes for printing')
addfield('hresrart','ra_package','l (1)','Increase price of reservation')
addindex('hresrart','tag1','STR(ra_rsid,10)+ra_ratecod+STR(ra_artityp,1)+STR(ra_artinum,4)')
addindex('hresrart','tag2','STR(ra_rsid,10)+ra_ratecod+STR(ra_raid,10)')
UpdateFilesTbl('hresrart','.T.',4,'','','','Custom split articles per reservation hist.','ra_raid')

* PRTYPES
addfield('prtypes','pt_alwgrp','l (1)','always group or not')
UpdateFilesTbl('prtypes','.T.',3,'P','','','Druckgruppierungskode')

* EVENTS
addfield('events','ev_picture','C (30)','Picture or icon of the event')
addfield('events','ev_color','C (11)','Color of the event')
addindex('events','tag2','ev_name')
UpdateFilesTbl('events','.T.',3,'P','','','Events')

* EVINT
addfield('evint','ei_to','D (8)','Date to')
addindex('evint','tag2','ei_eiid')
UpdateFilesTbl('evint','.T.',3,'P','','','Event intervals')

* VOUCHER
addfield('voucher','vo_postid','n (8)','Posting ID')
addfield('voucher','vo_note','m (4)','Gutschein Notiz')
addfield('voucher','vo_vat','n (1)','Vat group')
addfield('voucher','vo_vatdesc','c (25)','VAT description')
addfield('voucher','vo_vatval','n (5,2)','VAT percent value')
addfield('voucher','vo_veid','i (4)','External voucher id from extvouch.ve_veid')
addindex('voucher','tag11','vo_number')
addindex('voucher','tag12','vo_veid')

* ZIPCODE
addfield('zipcode','zc_zcid','n (8)','Zip code ID')
addindex('zipcode','tag3','zc_zcid')
UpdateFilesTbl('zipcode','.T.',1,'','','','Postleitzahlen')

* LISTS
addfield('lists','li_mainsrv','l (1)','Main server report')
addfield('lists','li_buildng','l (1)','Use also for buildings')
addfield('lists','li_etsavdc','l (1)','Save exported file in document table')
addfield('lists','li_lettype','n (1)','Letter based on: 0 - ADR list, 2 - RES list, 2 - BMS list')
addfield('lists','li_alang','c (3)','Language from address.ad_lang, for which is report created')
addfield('lists','li_attcahm','m (4)','Attachments when sending with E-Mail')
addfield('lists','li_consent','l (1)','Check consent')
addfield('lists','li_showubd','l (1)',[In dialog show 'Use book-keeping date' check box])
addindex('lists','tag24','li_menu')

* USER
addfield('user','us_fax','c (20)','FAX number of user')
addfield('user','us_phone','c (20)','Telephone number of user')
addfield('user','us_websrv','l (1)','User is allowed to login from Citadel WebServer')
addfield('user','us_inactiv','l (1)','User is inactive (deleted)')

* USERFAV
addfield('userfav','uf_userid','c (10)','User ID.')
addfield('userfav','uf_menu','c (20)','Menu code')
addfield('userfav','uf_menukey','c (20)','Menu key.')
addindex('userfav','tag1','UPPER(PADR(uf_userid,10)+uf_menu+uf_menukey)')
addindex('userfav','tag2','uf_userid')
UpdateFilesTbl('userfav','.T.',5,'','','','Favourite functions for user.')

* RATECODE
addfield('ratecode','rc_maxstay','n (3)','Max stay for this ratecode')
addfield('ratecode','rc_notecp','l (1)','Copy rc_note into rs_note, when new reservation is created')
addfield('ratecode','rc_key','c (23)','Ratecode uniqueid')
addfield('ratecode','rc_paymeth','c (4)','Default paymethod code used in reseravtion')
addfield('ratecode','rc_moposon','n (2)','Post monthly rate code on this day in month')
addfield('ratecode','rc_rcid','i (4)','Ratecode record id')
addfield('ratecode','rc_citmobi','l (1)','Show this ratecode on Citadelmobile Web page')
addfield('ratecode','rc_citmob1','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob2','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob3','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob4','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob5','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob6','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob7','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob8','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmob9','m (4)','Description for Citadelmobile Web page')
addfield('ratecode','rc_citmoss','l (1)','Show split articles on Citadelmobile Web page')
addfield('ratecode','rc_citexid','c (10)','External ratecode id on Citadelmobile Web page')
addfield('ratecode','rc_wbase','b (2)','Base rate independent from adults+children weekend price')
addfield('ratecode','rc_citmsre','l (1)','Show ratecode description in conformation E-Mail in Webbooking Citadelmobile Web page')
addfield('ratecode','rc_adperra','b (2)','Additional price per person from rc_adperra rate after number od persons in rm_beds')
addfield('ratecode','rc_adperid','i (4)','Additional price per person HRS ID')
addfield('ratecode','rc_paynum','n (3)','Paymethod number to recalculate rate in reservation screen to local currency')
addfield('ratecode','rc_citucwr','l (1)','Use Citweb rates in Webbooking Citadelmobile Web page')
addfield('ratecode','rc_citvwrl','c (3)','Citweb virtual room type from cwrates.ew_vroom field')
addfield('ratecode','rc_citcwcr','n (6,2)','Adjust Citweb rate for given amount. Negative values are also posible')
addfield('ratecode','rc_citcwcp','n (6,2)','Adjust Citweb rate for given percent. Negative values are also posible')
addindex('ratecode','tag5','rc_ratecod')
addindex('ratecode','tag6','rc_key')
addindex('ratecode','tag7','rc_ratecod+rc_roomtyp+rc_season+DTOS(rc_fromdat)')

* BUILDING
addfield('building','bu_dontswb','l (1)','Dont show in Webbooking')
addfield('building','bu_numcode','N (2)','Buidling Numcode')
addfield('building','bu_cashnr','N (3)','Building CashNo.')
addindex('building','tag1','bu_buid')
UpdateFilesTbl('building','.T.',2,'','','','Buildings')

* TERMINAL
addfield('terminal','tm_hiactiv','l (1)','Health insurance Smart Cart active')
UpdateFilesTbl('terminal','.T.',5,'','','','Defined terminals in Brilliant')

* HOTEL
addfield('hotel','ho_hotcode','c (10)','Hotel code')
addfield('hotel','ho_path','c (254)','Path to hotel root folder')
addfield('hotel','ho_descrip','c (100)','Hotel description')
addfield('hotel','ho_mainsrv','l','Is Multiproper exe')
addfield('hotel','ho_hosecid','i','HOSEC hotel Id')
UpdateFilesTbl('hotel','.F.',11,'R','','','Hotels in system')

* FPRINTER
addfield('fprinter','fp_drvfile','c (100)','Path and name to driver exe')
UpdateFilesTbl('fprinter','.T.',5,'','','','List of available fiscal printers')

* SCREENS
addfield('screens','sc_usset3','l (1)','User settings 3')
addfield('screens','sc_ussets','c (30)','User settings upto 30. 0/1')
addindex('screens','tag2','sc_label')
addindex('screens','tag3','sc_userid')

* logger
addfield('logger','lg_keyexp','C(50)','Table key field(s)')
addfield('logger','lg_keyid','C(35)','Record ID in table')
addfield('logger','lg_changes','M(4)','Changes')
addfield('logger','lg_sysdate','D(8)','System date')
addindex('logger','tag4','lg_keyid')
addindex('logger','tag5','lg_sysdate')
UpdateFilesTbl('logger','.T.',5,'','','',[Log of changes in tables])

* DOCUMENT
addfield('document','dc_file','c(50)','Document file')
addfield('document','dc_bbid','i','Bonus account ID')
addindex('document','tag4','dc_file')
addindex('document','tag5','dc_bbid')

* MANAGER
addfield('manager','mg_optcxl','n(10)','Cancelled OPT,TEN,LST reservations')
addfield('manager','mg_optcxlm','n(10)','Number of OPT,TEN,LST cancelations this month')
addfield('manager','mg_optcxly','n(10)','Number of OPT,TEN,LST cancelations this year')
addfield('manager','mg_ten30da','n(10)','Tentative for the next 30 days')
addfield('manager','mg_ten365d','n(10)','Tentative for the next 365 days')
addfield('manager','mg_tencxl','n(10)','Cancelled TEN reservations')
addfield('manager','mg_tencxlm','n(10)','Number of TEN cancelations this month')
addfield('manager','mg_tencxly','n(10)','Number of TEN cancelations this year')
addfield('manager','mg_tenendm','n(10)','Tentative until the end of the month')
addfield('manager','mg_tenendy','n(10)','Tentative until the end of the year')
addfield('manager','mg_tennext','n(10)','Tentative next week')
addfield('manager','mg_tentomo','n(10)','Tentative tomorrow')

* MNGBUILD
addfield('mngbuild','mg_optcxl','n(10)','Cancelled OPT,TEN,LST reservations')
addfield('mngbuild','mg_optcxlm','n(10)','Number of OPT,TEN,LST cancelations this month')
addfield('mngbuild','mg_optcxly','n(10)','Number of OPT,TEN,LST cancelations this year')
addfield('mngbuild','mg_ten30da','n(10)','Tentative for the next 30 days')
addfield('mngbuild','mg_ten365d','n(10)','Tentative for the next 365 days')
addfield('mngbuild','mg_tencxl','n(10)','Cancelled TEN reservations')
addfield('mngbuild','mg_tencxlm','n(10)','Number of TEN cancelations this month')
addfield('mngbuild','mg_tencxly','n(10)','Number of TEN cancelations this year')
addfield('mngbuild','mg_tenendm','n(10)','Tentative until the end of the month')
addfield('mngbuild','mg_tenendy','n(10)','Tentative until the end of the year')
addfield('mngbuild','mg_tennext','n(10)','Tentative next week')
addfield('mngbuild','mg_tentomo','n(10)','Tentative tomorrow')

* YIELDMNG
AddField('yieldmng','ym_active','l','Freischalten')
AddField('yieldmng','ym_avlhot','l','Availability for entire hotel.')
AddField('yieldmng','ym_prcpct2','n(6,2)','How much percent of price for 2 adults goes below or above.')
AddField('yieldmng','ym_prcpct3','n(6,2)','How much percent of price for 3 adults goes below or above.')
AddField('yieldmng','ym_prcunit','n(1)','Price correction unit. 0 -for percent; 1 -for amount.')
AddIndex('yieldmng','tag1','ym_ymid')
UpdateFilesTbl('yieldmng','.T.',3,'','','','Yield managment definition.')

* RCYIELD
AddField('rcyield','yr_ratecod','c (23)','Ratecode ID')
AddIndex('rcyield','tag2','yr_ymid')
UpdateFilesTbl('rcyield','.T.',3,'','','','Ratecode condition.')

* YMNGPROP
AddField('ymngprop','yp_ypid','i','Record ID')
AddField('ymngprop','yp_ymid','i','Yield managment definition ID')
AddField('ymngprop','yp_date','d','Date')
AddField('ymngprop','yp_flags','c(5)','Property flags')
AddIndex('ymngprop','tag1','yp_ypid')
AddIndex('ymngprop','tag2','yp_ymid')
AddIndex('ymngprop','tag3','yp_date')
UpdateFilesTbl('ymngprop','.T.',3,'P','','','Yield managment definition properties.','yp_ypid')

* YIOFFER
AddField('yioffer','yo_userid','c (10)','User ID')
AddIndex('yioffer','tag2','yo_rsid')
UpdateFilesTbl('yioffer','.T.',2,'','','','Reservation offer.')

* YICOND
AddField('yicond','yc_ycid','i','Reservation offer condition ID')
AddField('yicond','yc_yoid','i','Reservation offer ID')
AddField('yicond','yc_yrid','i','Ratecode condition ID')
AddField('yicond','yc_daytype','n (1)','Typ fon Tagenoperation 0 -<=, 1 - >=')
AddField('yicond','yc_days','n (3)','Tagen')
AddField('yicond','yc_avltype','n (1)','Typ von Belegungoperation 0 -<=, 1 - >=')
AddField('yicond','yc_avail','n (5,1)','Perzent von Belegung')
AddField('yicond','yc_avlhot','l','Availability for entire hotel.')
AddField('yicond','yc_prcpct','n (6,2)','Perzent wieviel Perzent Preis geht unter oder oben')
AddField('yicond','yc_round','n (1)','Rundung 0-5')
AddField('yicond','yc_prcset','n (1)','Preiseinstellung 0-3')
AddField('yicond','yc_prcunit','n (1)','Price correction unit. 0 -for percent; 1 -for amount.')
AddIndex('yicond','tag1','yc_ycid')
AddIndex('yicond','tag2','yc_yoid')
AddIndex('yicond','tag3','yc_yrid')
UpdateFilesTbl('yicond','.T.',2,'','','','Reservation offer condition.')

* RESYIELD
AddField('resyield','ry_occup','n (3)','Occupation limit [%]')
AddIndex('resyield','tag4','ry_date')
UpdateFilesTbl('resyield','.T.',2,'P','','','Offered prices for reservation.')

* HYIOFFER
AddField('hyioffer','yo_userid','c (10)','User ID')
AddIndex('hyioffer','tag1','yo_yoid')
AddIndex('hyioffer','tag2','yo_rsid')
UpdateFilesTbl('hyioffer','.T.',4,'','','','Reservation offer historical.')

* HYICOND
AddField('hyicond','yc_prcunit','n (1)','Price correction unit. 0 -for percent; 1 -for amount.')
AddIndex('hyicond','tag1','yc_ycid')
AddIndex('hyicond','tag2','yc_yoid')
AddIndex('hyicond','tag3','yc_yrid')
UpdateFilesTbl('hyicond','.T.',4,'','','','Reservation offer condition historical.')

* HRESYILD
AddField('hresyild','ry_ryid','i','Reservation yield ID')
AddField('hresyild','ry_yoid','i','Reservation offer ID')
AddField('hresyild','ry_ycid','i','Yield condition ID')
AddField('hresyild','ry_date','d (8)','Date')
AddField('hresyild','ry_ratecod','c (23)','Ratecode ID')
AddField('hresyild','ry_rate','b (8)','Reservation price')
AddField('hresyild','ry_occup','n (3)','Occupation limit [%]')
AddIndex('hresyild','tag1','ry_ryid')
AddIndex('hresyild','tag2','ry_yoid')
AddIndex('hresyild','tag3','ry_ycid')
AddIndex('hresyild','tag4','ry_date')
UpdateFilesTbl('hresyild','.T.',4,'','','','Offered prices for reservation historical.')

* RESSPLIT
AddField('ressplit','rl_rlid','i','Reservation split article ID')
AddField('ressplit','rl_rsid','i','Reservation ID')
AddField('ressplit','rl_rdrsid','i','Redirected reservation ID')
AddField('ressplit','rl_date','d','Date op posting')
AddField('ressplit','rl_raid','n (10)','Ratearti ID for ratecode')
AddField('ressplit','rl_rfid','i','Reservation fixed charges ID')
AddField('ressplit','rl_bqid','i','Reservation banquet ID')
AddField('ressplit','rl_ratecod','c (23)','Ratecode ID')
AddField('ressplit','rl_artinum','n (4)','Articlenumber posted')
AddField('ressplit','rl_artityp','n (1)','Splitting article type')
AddField('ressplit','rl_price','b (6)','Unitprice / Currency rate')
AddField('ressplit','rl_units','b (2)','Units posted by room')
AddField('ressplit','rl_rdate','d','Date of article usage')
AddIndex('ressplit','tag1','rl_rsid')
AddIndex('ressplit','tag2','rl_date')
AddIndex('ressplit','tag3','rl_raid')
AddIndex('ressplit','tag4','rl_rfid')
AddIndex('ressplit','tag5','rl_bqid')
AddIndex('ressplit','tag6','PADL(rl_rsid,10)+DTOS(rl_date)')
AddIndex('ressplit','tag7','rl_artinum')
AddIndex('ressplit','tag8','rl_rlid')
AddIndex('ressplit','tag9','rl_rdate')
UpdateFilesTbl('ressplit','.T.',2,'P','T','','Splits for reservation.','rl_rlid')

* HRESPLIT
AddField('hresplit','rl_rlid','i','Reservation split article ID')
AddField('hresplit','rl_rsid','i','Reservation ID')
AddField('hresplit','rl_date','d','Date op posting')
AddField('hresplit','rl_rdate','d','Date of article usage')
AddField('hresplit','rl_ratecod','c (23)','Ratecode ID')
AddField('hresplit','rl_artinum','n (4)','Articlenumber posted')
AddField('hresplit','rl_artityp','n (1)','Splitting article type')
AddField('hresplit','rl_price','b (6)','Unitprice / Currency rate')
AddField('hresplit','rl_units','b (2)','Units posted by room')
AddIndex('hresplit','tag1','rl_rlid')
AddIndex('hresplit','tag2','rl_rsid')
AddIndex('hresplit','tag3','rl_date')
AddIndex('hresplit','tag4','rl_rdate')
UpdateFilesTbl('hresplit','.T.',4,'','','','Splits for reservation historical.','rl_rlid')

* CWVRRT
AddField('cwvrrt','eq_vroom','c(3)','Virtual roomtype from citweb (virtrooms.vr_vroom)')
AddField('cwvrrt','eq_ratecod','c(10)','Ratecode selected for virtual roomtype from citweb')
AddField('cwvrrt','eq_adults','n(1)','No. of adults (1-5) for which is price generated.')
AddField('cwvrrt','eq_updated','t(8)','Datetime when rates last time updated')
AddField('cwvrrt','eq_sent','t(8)','Datetime when rates last time sent to web')
AddField('cwvrrt','eq_userid','c(10)','User which last changed prices')
AddField('cwvrrt','eq_inactiv','l(1)','Aktiv/Nicht aktiv')
AddField('cwvrrt','eq_channel','i(4)','Channel id for rate (Dirs21, Channelmanager, Cultuzz ...)')
AddField('cwvrrt','eq_rateid','c(16)','Additional rate id (empty means standard - default rate)')
AddField('cwvrrt','eq_chvroom','c(3)','Virtual roomtype from citweb (virtrooms.vr_vroom) for additional rates')
AddField('cwvrrt','eq_descrip','c(40)','Description')
AddField('cwvrrt','eq_ymactiv','l(1)','Yield manager (APS) automatic price changes active')
AddField('cwvrrt','eq_adusta','n(1)','Standard number of adults (1-5) expected in room')
AddField('cwvrrt','eq_citucwr','l(1)','Adjust rates before sending to channels')
AddField('cwvrrt','eq_citcwcr','n(6,2)','Adjust rate for given amount before sending to channels. Negative values allowed')
AddField('cwvrrt','eq_citcwcp','n(6,2)','Adjust rate for given percent before sending to channels. Negative values allowed')
AddIndex('cwvrrt','tag1','eq_vroom')
UpdateFilesTbl('cwvrrt','.T.',3,'P','','','Virtual roomtypes in Citweb','eq_vroom')

* CWRATES
AddField('cwrates','ew_date','d(8)','Date for wich is price defined')
AddField('cwrates','ew_vroom','c(3)','Virtual roomtype from citweb (virtrooms.vr_vroom)')
AddField('cwrates','ew_rate','n(12,2)','Rate on date for virtual room type')
AddField('cwrates','ew_minstay','n(3)','')
AddField('cwrates','ew_maxstay','n(3)','')
AddField('cwrates','ew_mealcod','c(2)','RO-Room only, BB-Breakfast, HB-Half Board, FB-Full Board, AI-All inclusive')
AddField('cwrates','ew_rate2','n(12,2)','Rate for 2 persons on date for virtual room type')
AddField('cwrates','ew_rate3','n(12,2)','Rate for 3 persons on date for virtual room type')
AddField('cwrates','ew_rate4','n(12,2)','Rate for 4 persons on date for virtual room type')
AddField('cwrates','ew_rate5','n(12,2)','Rate for 5 persons on date for virtual room type')
AddField('cwrates','ew_crate1','n(12,2)','Rate for 1 child on date for virtual room type')
AddField('cwrates','ew_crate2','n(12,2)','Rate for 2 child on date for virtual room type')
AddField('cwrates','ew_crate3','n(12,2)','Rate for 3 child on date for virtual room type')
AddField('cwrates','ew_closed','n(1)',"When 2, this rate is closed - it can't be used")
AddIndex('cwrates','tag1','ew_date')
AddIndex('cwrates','tag2','ew_vroom')
UpdateFilesTbl('cwrates','.T.',3,'P','','','Rates for virtual roomtypes in Citweb','ew_date,ew_vroom')

* UGIMP
AddField('ugimp','ug_ugid','i(4)','Record ID')
AddField('ugimp','ug_sysdate','d(8)','System date of import')
AddField('ugimp','ug_time','t(8)','Date and time of import')
AddField('ugimp','ug_file','c(254)','Filename of imported file')
AddField('ugimp','ug_text','m(4)','Content of imported file')
UpdateFilesTbl('ugimp','.F.',5,'','','','Ugos import log files','ug_ugid')

* RESCFGUE
AddField('rescfgue','rj_rjid','i','Record ID')
AddField('rescfgue','rj_cgid','i','Conference group ID')
AddField('rescfgue','rj_rsid','i','Reservation ID')
AddField('rescfgue','rj_crsid','i','Conference reservation ID')
AddField('rescfgue','rj_addrid','n (8)',[Guest's address id])
AddField('rescfgue','rj_lname','c (30)',[Guest's last name])
AddField('rescfgue','rj_fname','c (20)',[Guest's first name])
AddField('rescfgue','rj_title','c (20)',[Guest's title])
AddField('rescfgue','rj_priorit','i',[Guest's priority in group])
AddField('rescfgue','rj_deleted','l(1)','Deleted')
AddIndex('rescfgue','tag1','rj_rjid')
AddIndex('rescfgue','tag2','rj_cgid')
AddIndex('rescfgue','tag3','rj_crsid')
AddIndex('rescfgue','tag4','rj_rsid')
AddIndex('rescfgue','tag5','rj_priorit')
AddIndex('rescfgue','tag6','PADL(rj_crsid,10)+PADL(rj_priorit,10)')
UpdateFilesTbl('rescfgue','.T.',2,'P','','','Conference group guests.','rj_rjid')

* BSACCT
AddField('bsacct','bb_bbid','i','Bonus account ID')
AddField('bsacct','bb_adid','i','Link to adrmain ID')
AddField('bsacct','bb_addrid','n(8)','Link to address ID')
AddField('bsacct','bb_inactiv','l','Bonus account inactive')
AddField('bsacct','bb_history','m(4)','History of changes for this account')
AddField('bsacct','bb_email','l','When .T., must send E-Mail')
AddIndex('bsacct','tag1','bb_bbid',,.T.)
AddIndex('bsacct','tag2','bb_addrid')
AddIndex('bsacct','tag3','bb_adid')
UpdateFilesTbl('bsacct','.F.',1,'P','R','','Bonus accounts','bb_bbid')

* BSPOST
AddField('bspost','bs_bcid','i','Bonus card ID')
AddIndex('bspost','tag5','bs_billnum')
UpdateFilesTbl('bspost','.F.',1,'P','R','','Bonus posts','bs_bsid')

* BSCARD
AddField('bscard','bc_deleted','l','When .T., card is deleted/inactive')
AddIndex('bscard','tag3','bc_cardid')
UpdateFilesTbl('bscard','.F.',1,'P','R','','Bonus cards','bc_bcid')

* ARTICLE
AddField('article','ar_mangrp','n(2)','Additional grouping codes for manager')
AddField('article','ar_resourc','c(3)',[Resource selected from picklist where pl_label='RESOURCE'])

* USERMSG
AddField('usermsg','um_umid','i','Message ID')
AddField('usermsg','um_userid','c(10)','User ID')
AddField('usermsg','um_text','m','Message')
AddField('usermsg','um_left','n(4)','Message left position')
AddField('usermsg','um_top','n(4)','Message top position')
AddField('usermsg','um_width','n(4)','Message width')
AddField('usermsg','um_height','n(4)','Message height')
AddIndex('usermsg','tag1','um_umid')
AddIndex('usermsg','tag2','um_userid')
UpdateFilesTbl('usermsg','.T.',5,'P','','','Users HTML messages','um_umid,um_userid')

* ROOMTPIC
AddField('roomtpic','ro_picid','n(8)','Picture ID')
AddField('roomtpic','ro_roomtyp','c(4)','Roomtype ID')
AddIndex('roomtpic','tag1','ro_roomtyp+STR(ro_picid,8)')
UpdateFilesTbl('roomtpic','.T.',2,'P','X','','Zuordnung Bilder an Zimmertypen','ro_roomtyp,ro_picid')

* BUILDPIC
AddField('buildpic','bt_picid','n(8)','Picture ID')
AddField('buildpic','bt_buid','i(4)','Building ID')
AddIndex('buildpic','tag1','bt_picid')
AddIndex('buildpic','tag2','bt_buid')
UpdateFilesTbl('buildpic','.T.',2,'P','X','','Zuordnung Bilder an Geb�uden','bt_picid,bt_buid')

* MESSAGES
AddField('messages','ms_hotcode','c(10)','Hotel for which this record is generated')

* LEDGPOST
AddField('ledgpost','ld_qrcode','c (254)','Fiskaltrust QR code to be printed on bill')
addfield('ledgpost','ld_paynum','n (3)','Payment number')
AddIndex('ledgpost','tag1','STR(ld_paynum,3)+ld_company')
AddIndex('ledgpost','tag2','STR(ld_paynum,3)+ld_lname ')
AddIndex('ledgpost','tag3','STR(ld_paynum,3)+ld_billnum ')
AddIndex('ledgpost','tag4','STR(ld_paynum,3)+DTOS(ld_billdat) ')
AddIndex('ledgpost','tag7','ld_postid')

* LEDGPAYM
AddField('ledgpaym','lp_ldid','i','Reference to ledgpost ID')
addfield('ledgpaym','lp_paynum','n (3)','Payment number')
AddIndex('ledgpaym','tag5','lp_ldid')

* AZEPICK
AddField('azepick','aq_dval2','D(8)','Picklist date value 2')
AddIndex('azepick','tag1','aq_label')
AddIndex('azepick','tag2','aq_label+STR(aq_numcod,3)')
AddIndex('azepick','tag3','aq_label+aq_charcod')
UpdateFilesTbl('azepick','.T.',8,'L','P','','Various AZE Pick Lists','aq_label,aq_charcod,aq_numcod')

* WORKBRKD
AddField('workbrkd','wd_wdid','i','Default work break ID')
AddField('workbrkd','wd_date','d','Date of default work break')
AddField('workbrkd','wd_min','n(3)','Default work break in munutes')
addfield('workbrkd','wd_cwhour0','n(2)','Continuous number of working hours for no break')
addfield('workbrkd','wd_cwhour1','n(2)','Continuous number of working hours for work break 1')
addfield('workbrkd','wd_wbmin1','n(3)','Work break in minutes 1')
addfield('workbrkd','wd_cwhour2','n(2)','Continuous number of working hours for work break 2')
addfield('workbrkd','wd_wbmin2','n(3)','Work break in minutes 2')
addfield('workbrkd','wd_cwhour3','n(2)','Continuous number of working hours for work break 3')
addfield('workbrkd','wd_wbmin3','n(3)','Work break in minutes 3')
AddIndex('workbrkd','tag1','wd_wdid')
AddIndex('workbrkd','tag2','wd_date')
UpdateFilesTbl('workbrkd','.T.',8,'P','','','Default work break','wd_wdid')

* TIMETYPE
AddField('timetype','tt_vacatio','l','Working time for vacation')
AddField('timetype','tt_setpl0','l','Sets planned working time to 0')
AddField('timetype','tt_timepct','n(3)','How much percent/(duration in minutes) time would be reduced.')
AddField('timetype','tt_timunit','n(1)','Time reduction unit. 0 -for percent; 1 -for duration in minutes.')

* PICTURES
AddField('pictures','pc_lang11','c (250)','')
AddField('pictures','pc_hash','c (32)','MD5 hashed value of file. Can be used to detect if picture is changed.')
AddField('pictures','pc_flength','i (4)','File size. Can be used to detect if picture is changed.')

* MENU
AddField('menu','mn_sequ','n(2)',"Sequence (0-16);If 0 then hasn't shown")
AddField('menu','mn_files','c(100)','List of required files')
AddIndex('menu','tag1','mn_sequ')

* EMPLOYEE
AddField('employee','em_webcode','c(4)','PIN Code for accessing Web Version of AZE')
AddField('employee','em_dayweek','n(1)','Weekly working days')
AddField('employee','em_whweek','n(4,1)','Weekly working hours')
AddField('employee','em_inactiv','l(1)','When .T., employee is inactive')
AddField('employee','em_uid','c(16)','Card UID, for log in')

* EMPLOYEH
AddField('employeh','eh_ehid','n(8)','Employee properties for year ID')
AddField('employeh','eh_emid','n(8)','Employee ID')
AddField('employeh','eh_year','n(4)','Employee properties for year')
AddField('employeh','eh_vacatio','n(3)','Vacation demanding')
AddIndex('employeh','tag1','eh_ehid')
UpdateFilesTbl('employeh','.T.',8,'P','X','','Employee properties for year','eh_ehid')

* EXTSTAT
addfield('extstat','ex_exid','i (4)', 'Unique ID')
addfield('extstat','ex_date','d (8)', 'For which date are inserted data. Only one date per one source.')
addfield('extstat','ex_source','c (3)', 'Source code from picklist.pl_label = "SOURCE"')
addfield('extstat','ex_website','i (4)', 'Number of calls to hotel website')
addfield('extstat','ex_webbook','i (4)', 'Number of calls to webbooking website')
addindex('extstat','tag1','ex_exid')
addindex('extstat','tag2','ex_date')
UpdateFilesTbl('extstat','.F.',3,'P','','','How many times is called hotel website','ex_exid')

* PSWINDOW
AddField('pswindow','pw_pwid','i','Post window ID')
AddField('pswindow','pw_rsid','i','Reservation ID')
AddField('pswindow','pw_window','i','Bill window')
AddField('pswindow','pw_winpos','n(1)','Bill window position 1..6')
AddField('pswindow','pw_addrid','n(8)','Bill window address')
AddField('pswindow','pw_billsty','c(1)','Bill style')
AddField('pswindow','pw_udbdate','l','Use UD booking date')
AddField('pswindow','pw_blamid','n(8)','')
AddField('pswindow','pw_copy','n(2)','Number of copies printed of Bill Window')
AddField('pswindow','pw_note','m','Note on Bill')
AddField('pswindow','pw_bmsto1w','l','Move BMS points from window >1 to 1 window address')
AddIndex('pswindow','tag1','pw_pwid')
AddIndex('pswindow','tag2','pw_rsid')
AddIndex('pswindow','tag3','pw_window')
AddIndex('pswindow','tag4','PADL(pw_rsid,10)+PADL(pw_window,10)')
UpdateFilesTbl('pswindow','.T.',2,'P','T','','Post window details.','pw_pwid')

* HPWINDOW
AddField('hpwindow','pw_pwid','i','Post window ID')
AddField('hpwindow','pw_rsid','i','Reservation ID')
AddField('hpwindow','pw_window','i','Bill window')
AddField('hpwindow','pw_winpos','n(1)','Bill window position 1..6')
AddField('hpwindow','pw_addrid','n(8)','Bill window address')
AddField('hpwindow','pw_billsty','c(1)','Bill style')
AddField('hpwindow','pw_udbdate','l','Use UD booking date')
AddField('hpwindow','pw_blamid','n(8)','')
AddField('hpwindow','pw_copy','n(2)','')
AddField('hpwindow','pw_note','m','Note on Bill')
AddField('hpwindow','pw_bmsto1w','l','Move BMS points from window >1 to 1 window address')
AddIndex('hpwindow','tag1','pw_pwid')
AddIndex('hpwindow','tag2','pw_rsid')
AddIndex('hpwindow','tag3','pw_window')
AddIndex('hpwindow','tag4','PADL(pw_rsid,10)+PADL(pw_window,10)')
UpdateFilesTbl('hpwindow','.T.',4,'','','','Historical post window details.','pw_pwid')

* ADRPRVCY
addfield('adrprvcy','ap_user5','c(50)','User field 5')
AddIndex('adrprvcy','tag1','ap_apid')
AddIndex('adrprvcy','tag2','ap_addrid')
UpdateFilesTbl('adrprvcy','.T.',1,'','','','Address privacy','ap_apid')

* ADRFEAT
AddField('adrfeat','fa_faid','i','Record ID')
AddField('adrfeat','fa_addrid','n(8)','Address ID')
AddField('adrfeat','fa_feature','c(3)','Feature')
AddIndex('adrfeat','tag1','fa_faid')
AddIndex('adrfeat','tag2','fa_addrid')
UpdateFilesTbl('adrfeat','.T.',1,'','','','Address features','fa_faid')

* RESFEAT
AddField('resfeat','fr_frid','i','Record ID')
AddField('resfeat','fr_rsid','i','Reservation ID')
AddField('resfeat','fr_feature','c(3)','Feature')
AddIndex('resfeat','tag1','fr_frid')
AddIndex('resfeat','tag2','fr_rsid')
UpdateFilesTbl('resfeat','.T.',2,'P','T','','Reservation features','fr_frid')

* HRESFEAT
AddField('hresfeat','fr_frid','i','Record ID')
AddField('hresfeat','fr_rsid','i','Reservation ID')
AddField('hresfeat','fr_feature','c(3)','Feature')
AddIndex('hresfeat','tag1','fr_frid')
AddIndex('hresfeat','tag2','fr_rsid')
UpdateFilesTbl('hresfeat','.T.',2,'','','','History reservation features','fr_frid')

* RSIFSYNC
AddField('rsifsync','rq_resroom','m','')
AddField('rsifsync','rq_notroom','l','When .T., this is rt_group=3 room type (DUM)')
AddField('rsifsync','rq_timisec','n(3)','Milliseconds part of timestamp in rq_timesta field')
UpdateFilesTbl('rsifsync','.T.',2,'P','T','C','Reservations transactions')

* JETWEB
AddField('jetweb','jw_guid','c(36)','GUID from Feratel, should be used when sending Meldeschein')

*************
SELECT tblUpdTblFailed
IF .NOT. EMPTY(RECCOUNT())
	LOCAL l_str
	l_str = "Failed to open exclusively following tables:" + CHR(13)
	GOTO TOP
	SCAN
		IF EMPTY(AT(uf_table, l_str))
			l_str = l_str + uf_table + ", "
		ENDIF
	ENDSCAN
	l_str = SUBSTR(l_str, 1, LEN(l_str)-2)
	MESSAGEBOX(l_str,0,"Error!")
ELSE
	MESSAGEBOX('Database is updated to new EXE version!',48,'Completed')
ENDIF
USE
WAIT CLEAR
CLOSE DATABASES ALL
ProcCryptor()
IF TYPE("goTbrQuick") <> "U" AND DoLogin
	 = opEnfile()
	 = chEcklite()
	 = reLations()
	 = checkwin("LOGIN WITH .T.",.T.)
ENDIF

ENDFUNC
*
FUNCTION AddField
	LPARAMETERS cTable,cField,cType,cDescription
	LOCAL gnCount,lexist
	LOCAL LTableName, LFildType, n, LFieldChanged
	LOCAL l_area, l_closed, l_order, l_recno, l_return
	LOCAL ARRAY laTableStruc(1)
	IF EMPTY(cDescription)
		cDescription = ""
	ENDIF
	l_area = SELECT()
	LFieldChanged = .f.
	l_closed = .F.
	IF USED(cTable)
		SELECT &cTable
		l_order = ORDER()
		l_recno = RECNO()
		l_closed = .T.
		USE
	ENDIF
	IF !FILE("data\"+cTable+".dbf")
		WAIT WINDOW "Creating table: "+ctable NOWAIT
		LTableName = "data\"+cTable
		CREATE TABLE &LTableName (&cField &cType)
		IF SEEK(UPPER(PADR(ctable,8)),'files')
			REPLACE fi_alias WITH ALLTRIM(ctable) IN files
			REPLACE fi_path WITH "DATA\" IN files
		ELSE
			SELECT files
			SCATTER MEMO MEMVAR BLANK
			m.fi_name =  UPPER(ALLTRIM(ctable))
			m.fi_alias =  ALLTRIM(ctable)
			m.fi_path = "DATA\"
			INSERT INTO files FROM MEMVAR
		ENDIF
	ELSE
		TRY
			USE ("data\"+cTable) IN 0 EXCLUSIVE
		CATCH
		ENDTRY
	ENDIF
	WAIT WINDOW "Working on table: "+ctable+", checking Field: "+cfield NOWAIT
	l_return = USED(cTable)
	IF l_return
		SELECT &cTable
		AFIELDS(laTableStruc)
		lexist=.F.
		FOR gnCount = 1 TO ALEN(laTableStruc,1)
			DO CASE
			 CASE UPPER(ALLTRIM(laTableStruc(gnCount,1)))==UPPER(ALLTRIM(cField))
				lexist=.T.
				EXIT
			ENDCASE
		ENDFOR
		LOCAL l_type, l_len, l_dec, l_str
		cType = ALLTRIM(cType)
		l_type = UPPER(SUBSTR(cType, 1, 1))
		n = AT("(", cType)
		IF n > 0
			l_str = SUBSTR(cType, n+1, LEN(cType)-n)
			n = AT(")", l_str)
			l_str = SUBSTR(l_str, 1, n-1)
			n = AT(",", l_str)
			IF n > 0
				l_len = VAL(SUBSTR(l_str, 1, n-1))
				l_dec = VAL(SUBSTR(l_str, n+1, LEN(l_str)-n))
			ELSE
				l_len = VAL(l_str)
				l_dec = 0
			ENDIF
		ELSE
			l_len = 0
			l_dec = 0
		ENDIF
		IF UPPER(l_type) = "B"
			IF EMPTY(l_str)
				l_dec = 2
			ELSE
				l_dec = l_len
			ENDIF
			l_len = 8
		ENDIF
		IF UPPER(l_type) = "T"
			l_dec = 0
			l_len = 8
		ENDIF
          IF UPPER(l_type) = "I"
               l_dec = 0
               l_len = 4
          ENDIF
          IF UPPER(l_type) = "M"
               l_dec = 0
               l_len = 4
          ENDIF
          IF UPPER(l_type) = "L"
               l_dec = 0
               l_len = 1
          ENDIF
          IF UPPER(l_type) = "D"
               l_dec = 0
               l_len = 8
          ENDIF
		IF !lexist
			WAIT WINDOW "Working on table: "+ctable+", adding new Field: "+cfield NOWAIT
			ALTER TABLE &cTable ADD &cField &cType
		ELSE
			IF (laTableStruc(gnCount,2)<>UPPER(l_type)) OR (laTableStruc(gnCount,3)<>l_len) OR ;
			   (laTableStruc(gnCount,4)<>l_dec)
				WAIT WINDOW "Working on table: "+ctable+", change Field: "+cfield NOWAIT
				ALTER TABLE &cTable ALTER &cField &cType
				LFieldChanged = .T.
			ENDIF
		ENDIF
		IF SEEK(UPPER(PADR(cTable,8)+PADR(cField,10)),'fields')
			REPLACE fd_type WITH l_type, fd_len WITH l_len, ;
					fd_dec WITH l_dec IN fields
		    IF NOT EMPTY(cDescription) AND NOT (fields.fd_descr == cDescription)
		    	REPLACE fd_descr WITH cDescription IN fields
		    ENDIF
		ELSE
			SELECT fields
			SCATTER MEMO MEMVAR BLANK
			m.fd_name = UPPER(ALLTRIM(cField))
			m.fd_table = UPPER(ALLTRIM(cTable))
			m.fd_type = l_type
			m.fd_len = l_len
			m.fd_dec = l_dec
		    IF EMPTY(m.fd_descr) AND NOT EMPTY(cDescription)
		    	m.fd_descr = cDescription
		    ENDIF
			INSERT INTO fields FROM MEMVAR
		ENDIF
		SELECT &cTable
		USE
	ENDIF
	IF l_closed
		USE &cTable IN 0 SHARED
		IF !EMPTY(l_order)
			SET ORDER TO l_order
		ENDIF
		GOTO l_recno
	ENDIF
	SELECT(l_area)
	IF .NOT. l_return
		IF USED("tblUpdTblFailed")
			cType = "Table:"+cTable+" Field:"+cField+" Type:"+cType
			INSERT INTO tblUpdTblFailed (uf_action, uf_table) VALUES (cType, cTable)
		ENDIF
	ENDIF
	
	RETURN l_return
ENDFUNC
*
FUNCTION AddIndex
	LPARAMETERS cTable, cTag, CExp, cOrder, lcandidate
	LOCAL lexist
	LOCAL l_area, l_closed, l_order, l_recno, l_return, lcmacro
	l_area = SELECT()
	IF EMPTY(cOrder)
		cOrder = "ASCENDING"
	ELSE
		cOrder = "DESCENDING"
	ENDIF
	WAIT WINDOW "Working on table: "+ctable+",checking Index: "+ctag NOWAIT
	l_closed = .F.
	IF USED(cTable)
		SELECT &cTable
		l_order = ORDER()
		l_recno = RECNO()
		l_closed = .T.
		USE
	ENDIF
	TRY
		USE ("data\"+cTable) IN 0 EXCLUSIVE
	CATCH
	ENDTRY
	l_return = USED(cTable)
	IF l_return
		SELECT &cTable
		lexist=.F.
		lsame=.F.
		FOR nCount = 1 TO 254
			IF !EMPTY(TAG(nCount))  && Checks for tags in the index
				IF TAG(nCount) == UPPER(ALLTRIM(cTag))
					lexist = .T.
					IF KEY(nCount) == UPPER(ALLTRIM(CExp))
						lsame = .T.
					ENDIF
					EXIT
				ENDIF
			ELSE
				EXIT
			ENDIF
		ENDFOR
		IF !lsame
			IF lexist
				WAIT WINDOW "Working on table: "+ctable+",changid Index: "+ctag+" to:"+CExp NOWAIT
				DELETE TAG &cTag
			ELSE
				WAIT WINDOW "Working on table: "+ctable+",adding New Index: "+ctag NOWAIT
			ENDIF
			INDEX ON &CExp TAG &cTag
		ENDIF
		LOCAL l_key
		l_key = ALLTRIM(STR(VAL(SUBSTR(cTag,4,LEN(cTag)-3))))
		IF SEEK(UPPER(ctable),'files')
			REPLACE fi_path WITH "DATA\" IN files
			l_key = "fi_key" + ALLTRIM(STR(VAL(SUBSTR(cTag,4,LEN(cTag)-3))))
			REPLACE &l_key WITH CExp IN files
		ELSE
			SELECT files
			SCATTER MEMO MEMVAR BLANK
			m.fi_name =  UPPER(ALLTRIM(ctable))
			m.fi_alias =  ALLTRIM(ctable)
			m.fi_path = "DATA\"
			l_key = "m.fi_key" + ALLTRIM(STR(VAL(SUBSTR(cTag,4,LEN(cTag)-3))))
			&l_key = CExp
			INSERT INTO files FROM MEMVAR
		ENDIF
		IF lcandidate
			lcmacro = "fi_uni" + ALLTRIM(STR(VAL(SUBSTR(cTag,4,LEN(cTag)-3))))
			REPLACE &lcmacro WITH .T. IN files
		ENDIF
		SELECT &cTable
		USE
	ENDIF
	IF l_closed
		USE &cTable IN 0 SHARED
		IF !EMPTY(l_order)
			SET ORDER TO l_order
		ENDIF
		GOTO l_recno
	ENDIF
	SELECT(l_area)
	IF .NOT. l_return
		IF USED("tblUpdTblFailed")
			CExp = "Table:"+cTable+" Tag:"+cTag+" Expression:"+CExp
			INSERT INTO tblUpdTblFailed (uf_action, uf_table) VALUES (CExp, cTable)
		ENDIF
	ENDIF
	
	RETURN l_return
*Close Tables All
ENDFUNC
*UpdateFilesTbl('cmrtavl','.F.',3,'','P','','Import von externe Kasse - Buchungen')
FUNCTION updatefilestbl
LPARAMETERS lp_cName, lp_cAutoOpen, lp_nGroup, lp_cFlag1, lp_cFlag2, lp_cFlag3, lp_cDescription, lp_cUnikey
LOCAL l_nSelected, l_oFields, l_lChangesDetected
IF SEEK(UPPER(lp_cName),"files","tag1")
	l_nSelected = SELECT()
	SELECT files
	SCATTER MEMO NAME l_oFields
	IF NOT EMPTY(lp_cAutoOpen) AND (l_oFields.fi_autopen <> EVALUATE(lp_cAutoOpen))
		l_oFields.fi_autopen = EVALUATE(lp_cAutoOpen)
		l_lChangesDetected = .T.
	ENDIF
	IF NOT EMPTY(lp_nGroup) AND (l_oFields.fi_group <> lp_nGroup)
		l_oFields.fi_group = lp_nGroup
		l_lChangesDetected = .T.
	ENDIF
	IF NOT EMPTY(lp_cFlag1) AND NOT lp_cFlag1 $ l_oFields.fi_flag
		l_oFields.fi_flag = TRIM(l_oFields.fi_flag) + lp_cFlag1
		l_lChangesDetected = .T.
	ENDIF
	IF NOT EMPTY(lp_cFlag2) AND NOT lp_cFlag2 $ l_oFields.fi_flag
		l_oFields.fi_flag = TRIM(l_oFields.fi_flag) + lp_cFlag2
		l_lChangesDetected = .T.
	ENDIF
	IF NOT EMPTY(lp_cFlag3) AND NOT lp_cFlag3 $ l_oFields.fi_flag
		l_oFields.fi_flag = TRIM(l_oFields.fi_flag) + lp_cFlag3
		l_lChangesDetected = .T.
	ENDIF
	IF NOT EMPTY(lp_cDescription) AND (l_oFields.fi_descrip <> PADR(lp_cDescription,40))
		l_oFields.fi_descrip = lp_cDescription
		l_lChangesDetected = .T.
	ENDIF
	IF NOT EMPTY(lp_cUnikey) AND (l_oFields.fi_unikey <> PADR(UPPER(lp_cUnikey),254))
		l_oFields.fi_unikey = UPPER(lp_cUnikey)
		l_lChangesDetected = .T.
	ENDIF
	IF l_lChangesDetected
		GATHER NAME l_oFields MEMO
	ENDIF
	SELECT(l_nSelected)
ENDIF
RETURN .T.
ENDFUNC
*
PROCEDURE updatefieldvalue
LPARAMETERS lp_cTableName, lp_cSourceField, lp_cDestinationField
LOCAL l_cMacro, l_cOrder, l_nRecno, l_lCloseTable, l_nOldArea

l_nOldArea = SELECT()
IF USED(lp_cTableName)
	l_cOrder = ORDER(lp_cTableName)
	l_nRecno = RECNO(lp_cTableName)
ELSE
	USE (lp_cTableName) IN 0 SHARED
	l_lCloseTable = .T.
ENDIF

SELECT &lp_cTableName
IF EMPTY(FIELD(lp_cSourceField)) OR EMPTY(FIELD(lp_cDestinationField))
	RETURN .F.
ENDIF

IF USED(lp_cTableName)
	l_cMacro = "REPLACE "+lp_cDestinationField+" WITH "+lp_cSourceField+" ALL IN "+lp_cTableName
	&l_cMacro
ENDIF

IF l_lCloseTable
	USE IN (lp_cTableName)
ELSE
	IF NOT EMPTY(l_cOrder)
		SET ORDER TO l_cOrder
	ENDIF
	GO l_nRecno IN &lp_cTableName
ENDIF
SELECT (l_nOldArea)
ENDPROC