     !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Courier New                    @  *  winspool \\FRONT2\Kyocera FS-1700 Ne00:                                                 \\FRONT2\Kyocera FS-1700        � p s  	        X  X   A4                                                                                      ����      ��������            ��    ��  ������������������������������         '''  '                                   �DRIVER=winspool
DEVICE=\\FRONT2\Kyocera FS-1700
OUTPUT=Ne00:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=273
DUPLEX=1
YRESOLUTION=600
TTOPTION=1
                                    
ps_reserid                     reservat.rs_roomnum            Arial                          reservat.rs_arrdate            Arial                          "@D"                           reservat.rs_depdate            Arial                          "@D"                           	ps_amount                      Arial                          "9999999.99"                   balance                        Arial                          "999999999.99"                 ps_ifc                         Arial                          g_hotel                        Arial                          ps_date                        Arial                          Date()                                                        Arial                          "@D"                           ps_units                       Arial                          	"9999999"                      vat2                           Arial                          vat2<>0                        "99999999.99"                  vat9                                                          Arial                          vat9<>0                        "99999999.99"                  �LTrim(iif(empty(address.ad_company),"",Trim(address.ad_title) + " ") + Trim(address.ad_fname) + " " + Trim(Flip(address.ad_lname)))                                Arial                          Piif(Empty(address.ad_company), Trim(address.ad_title), Flip(address.ad_company))                 Arial                          address.ad_departm             Arial                          address.ad_street              Arial                          3Trim(address.ad_zip) + "  " + Trim(address.ad_city)             Arial                          address.ad_street2             Arial                          �Iif(address.ad_country  <>   param.pa_country, dbLookUp("PickList" , "TAG4","COUNTRY   "+ address.ad_country , "PickList.Pl_Lang1")," ")                           Arial                          RepoText("LIST", "ROOM")       Arial Narrow                   
"~ARRDATE"                     Arial Narrow                   
"~DEPDATE"                     Arial Narrow                   RepoText("LIST", "DATE")                                      Arial Narrow                   "~DESCRIPT"                                                   Arial Narrow                   RepoText("LIST", "QTY")                                       Arial Narrow                   RepoText("LIST", "DATE")                                      Arial Narrow                   RDLookup('PickList', 'pl_label=[VATGROUP] and pl_numcod=2', 'pl_lang' + g_RptLngNr)                                              Arial Narrow                   vat2<>0                        RDLookup('PickList', 'pl_label=[VATGROUP] and pl_numcod=9', 'pl_lang' + g_RptLngNr)                                              Arial Narrow                   vat9<>0                        RepoText("LIST", "TOTAL")                                     Arial Narrow                   	"~AMOUNT"                                                     Arial Narrow                   "~BILLDESCR"                                                  Arial                          vat1                           ps_vat1                        0                              vat9                           ps_vat9                        0                              vat2                           ps_vat2                        0                              vat3                           ps_vat3                        0                              balance                        	ps_amount                      0                              Courier New                    Arial                          Arial                          Arial Narrow                   Arial                          dataenvironment                Name = "Dataenvironment"
                                      
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   �DRIVER=winspool
DEVICE=\\FRONT2\Kyocera FS-1700
OUTPUT=Ne00:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=273
DUPLEX=1
YRESOLUTION=600
TTOPTION=1
                                    �DRIVER=winspool
DEVICE=\\FRONT2\Kyocera FS-1700
OUTPUT=Ne00:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=7
DUPLEX=1
YRESOLUTION=600
TTOPTION=1=1
                                    
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   
"~ARRDATE"LIST", "ARRDATE")                                     
"~DEPDATE"LIST", "DEPDATE")                                     "~DESCRIPT"IST", "DESCRIPT")                                    	"~AMOUNT""LIST", "AMOUNT")                                      "~BILLDESCR"ST", "BILLDESCR")                                   RepoText("LIST", "ARRDATE")                                     RepoText("LIST", "DEPDATE")                                     RepoText("LIST", "DESCRIPT")                                    RepoText("LIST", "AMOUNT")                                      RepoText("LIST", "BILLDESCR")                             