     @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
UT=CPW2:
ORIENTATION=0
PAPERSIZE=9
SCALE=100
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                                                                2    winspool  CUTEPDF  CPW2:                              Arial Narrow                                                  
p_cDebitor                                                    Arial Narrow                                                  p_cDebValue                                                                                                                 Arial Narrow                                                  p_cDebit                                                                                                                    Arial Narrow                                                  	p_cCredit                                                                                                                   Arial Narrow                                                  
p_cBalance                                                                                                                  Arial Narrow                                                  p_nDebit                                                                                                                    Arial Narrow                                                  	p_nCredit                                                                                                                   Arial Narrow                                                  
p_nBalance                                                                                                                  Arial Narrow                                                  	p_cBillno                                                                                                                   Arial Narrow                                                  p_cDate                                                                                                                     Arial Narrow                                                  
p_cBelgdat                                                                                                                  Arial Narrow                                                  	p_cPaynum                                                                                                                   Arial Narrow                                                  p_cDebit                                                                                                                    Arial Narrow                                                  	p_cCredit                                                                                                                   Arial Narrow                                                  
p_cBalance                                                                                                                  Arial Narrow                                                  p_cReference                                                                                                                Arial Narrow                                                  
p_cDispute                                                                                                                  Arial Narrow                                                  	ap_billnr                                                                                                                   Arial Narrow                                                  ap_date                                                       "@D"                                                                                                                        Arial Narrow                                                  
ap_belgdat                                                    "@D"                                                                                                                        Arial Narrow                                                  ap_paynum+ap_artinum                                                                                                        Arial Narrow                                                  ap_debit                                                                                                                    Arial Narrow                                                  	ap_credit                                                                                                                   Arial Narrow                                                  qIIF(ap_headid=ap_lineid .OR. ap_headid=0,TRANSFORM(arPstbal(ap_headid,ap_lineid,.F.),RIGHT(gcCurrcydisp, 12)),"")                                                                           Arial Narrow                                                  ap_ref                                                                                                                      Arial Narrow                                                  IIF(ap_dispute, p_cYes, p_cNo)                                                                                              Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  "Seite"                                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  DATE()                                                        Arial Narrow                                                  TIME()                                                        Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  p_cTitle                                                                                                                    Arial Narrow                                                  �LTrim(iif(empty(curaracaddr80012.ad_company),"",Trim(curaracaddr80012.ad_title) + " ") + Trim(curaracaddr80012.ad_fname) + " " + Trim(Flip(curaracaddr80012.ad_lname)))                       Arial                                                         kiif(Empty(curaracaddr80012.ad_company), Trim(curaracaddr80012.ad_title), Flip(curaracaddr80012.ad_company))                   Arial                                                         curaracaddr80012.ad_departm                                   Arial                                                         curaracaddr80012.ad_street                                    Arial                                                         ETrim(curaracaddr80012.ad_zip) + "  " + Trim(curaracaddr80012.ad_city)                                                         Arial                                                         curaracaddr80012.ad_street2                                   Arial                                                         �Iif(curaracaddr80012.ad_country  <>   param.pa_country, dbLookUp("PickList" , "TAG4","COUNTRY   "+ curaracaddr80012.ad_country , "PickList.Pl_Lang1")," ")                                    ""                                                            Arial                                                         Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         dataenvironment                                               YTop = 0
Left = 0
Width = 0
Height = 0
DataSource = .NULL.
Name = "Dataenvironment"
                                     �DRIVER=winspool
DEVICE=CUTEPDF
OUTPUT=CPW2:
ORIENTATION=0
PAPERSIZE=9
SCALE=100
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                                                                2    winspool  CUTEPDF  CPW2:                              Arial Narrow                                                  
p_cDebitor                                                    Arial Narrow                                                  p_cDebValue                                                                                                                 Arial Narrow                                                  p_cDebit                                                                                                                    Arial Narrow                                                  	p_cCredit                                                                                                                   Arial Narrow                                                  
p_cBalance                                                                                                                  Arial Narrow                                                  p_nDebit                                                                                                                    Arial Narrow                                                  	p_nCredit                                                                                                                   Arial Narrow                                                  
p_nBalance                                                                                                                  Arial Narrow                                                  	p_cBillno                                                                                                                   Arial Narrow                                                  p_cDate                                                                                                                     Arial Narrow                                                  
p_cBelgdat                                                                                                                  Arial Narrow                                                  	p_cPaynum                                                                                                                   Arial Narrow                                                  p_cDebit                                                                                                                    Arial Narrow                                                  	p_cCredit                                                                                                                   Arial Narrow                                                  
p_cBalance                                                                                                                  Arial Narrow                                                  p_cReference                                                                                                                Arial Narrow                                                  
p_cDispute                                                                                                                  Arial Narrow                                                  	ap_billnr                                                                                                                   Arial Narrow                                                  ap_date                                                       "@D"                                                                                                                        Arial Narrow                                                  
ap_belgdat                                                    "@D"                                                                                                                        Arial Narrow                                                  ap_paynum+ap_artinum                                                                                                        Arial Narrow                                                  ap_debit                                                                                                                    Arial Narrow                                                  	ap_credit                                                                                                                   Arial Narrow                                                  qIIF(ap_headid=ap_lineid .OR. ap_headid=0,TRANSFORM(arPstbal(ap_headid,ap_lineid,.F.),RIGHT(gcCurrcydisp, 12)),"")                                                                           Arial Narrow                                                  ap_ref                                                                                                                      Arial Narrow                                                  IIF(ap_dispute, p_cYes, p_cNo)                                                                                              Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  "Seite"                                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  DATE()                                                        Arial Narrow                                                  TIME()                                                        Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  p_cTitle                                                                                                                    Arial Narrow                                                  �LTrim(iif(empty(curaracaddr80012.ad_company),"",Trim(curaracaddr80012.ad_title) + " ") + Trim(curaracaddr80012.ad_fname) + " " + Trim(Flip(curaracaddr80012.ad_lname)))                       Arial                                                         kiif(Empty(curaracaddr80012.ad_company), Trim(curaracaddr80012.ad_title), Flip(curaracaddr80012.ad_company))                   Arial                                                         curaracaddr80012.ad_departm                                   Arial                                                         curaracaddr80012.ad_street                                    Arial                                                         ETrim(curaracaddr80012.ad_zip) + "  " + Trim(curaracaddr80012.ad_city)                                                         Arial                                                         curaracaddr80012.ad_street2                                   Arial                                                         �Iif(curaracaddr80012.ad_country  <>   param.pa_country, dbLookUp("PickList" , "TAG4","COUNTRY   "+ curaracaddr80012.ad_country , "PickList.Pl_Lang1")," ")                                    ""                                                            Arial                                                         Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         dataenvironment                                               YTop = 0
Left = 0
Width = 0
Height = 0
DataSource = .NULL.
Name = "Dataenvironment"
                               