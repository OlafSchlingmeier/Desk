  6   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
                         Arial Narrow                                                  
rs_arrdate                                                    ad_lname, ad_fname                                            Arial Narrow                                                  alltrim(company)                                                                                                            Arial Narrow                                                  4rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3)                                                                        Arial Narrow                                                  Trim(get_rm_rmname(RS_ROOMNUM))                                                                                             Arial Narrow                                                  
RS_RATECOD                                                    Arial Narrow                                                  RS_RATE                                                       "999,999,999.99"                                              CURRENCY                                                      Arial Narrow                                                  
rs_arrdate                                                    Arial Narrow                                                  
rs_depdate                                                    Arial Narrow                                                  	RS_STATUS                                                     Arial Narrow                                                  RepoText("LIST", "ARRDATE")                                   Arial Narrow                                                  RepoText("LIST", "DEPDATE")                                   Arial Narrow                                                  RepoText("LIST", "RATECODE")                                  Arial Narrow                                                  RepoText("LIST", "RATE")                                      Arial Narrow                                                  RepoText("LIST", "STATUS")                                    Arial Narrow                                                  RepoText("LIST", "TOTALS")                                    Arial Narrow                                                  RepoText("LIST", "GUEST")                                     Arial Narrow                                                  RepoText("LIST", "COMPANY")                                   Arial Narrow                                                  RepoText("LIST", "ROOM")                                      Arial Narrow                                                  RepoText("LIST", "PAX")                                       Arial Narrow                                                  4rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3)                                                                        Arial Narrow                                                  Proper(rs_group)                                              Arial Narrow                                                  RepoText("LIST", "GROUP")                                     Arial Narrow                                                  
rs_arrdate                                                    Arial Narrow                                                  MyCDoW(rs_arrdate)                                            Arial Narrow                                                  RepoText("LIST", "SUBTOTALS")                                 Arial Narrow                                                  4rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3)                                                                        Arial Narrow                                                  RepoText("LIST", "ARRDATE")                                   Arial Narrow                                                  DTOC(DATE()) + " " + TIME()                                   Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  max3                                                          Arial Narrow                                                  max4                                                          Arial Narrow                                                  max1                                                          Arial Narrow                                                  min4                                                          Arial Narrow                                                  min3                                                          Arial Narrow                                                  min1                                                          Arial Narrow                                                  prompt4                                                       Arial Narrow                                                  prompt3                                                       Arial Narrow                                                  prompt2                                                       Arial Narrow                                                  prompt1                                                       Arial Narrow                                                  title                                                         Arial Narrow                                                  "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         RepoText("LIST", "USERID")                                    Arial Narrow                                                  RepoText("LIST", "PRINTED")                                   Arial Narrow                                                  max2                                                          Arial Narrow                                                  min2                                                          Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  RepoText("LIST", "PAGE")                                      Arial Narrow                                                  Walltrim(str(Param.Pa_Version,7,2)+"-"+str(param.pa_build,3,0)+"/"+trim(lists.li_extra))                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  1alltrim(rs_arrtime) + " - " + alltrim(rs_deptime)                                                                           Arial Narrow                                                  RepoText("LIST", "TIME")                                                                                                    Arial Narrow                                                  
RS_CNFSTAT                                                                                                                  Arial Narrow                                                  RepoText("LIST", "CNFSTAT")                                                                                                 Arial Narrow                                                  'MLine(RS_CHANGES, MemLines(RS_CHANGES))                                                                                     Arial                                                         rs_status='CXL'                                               )MLine(RS_CHANGES, MemLines(RS_CHANGES)-1)                     "@B"                                                          Arial                                                         rs_status='CXL'                                               $"CXL-Nr.: " + alltrim(str(rs_cxlnr))                                                                                        Arial                                                         rs_status='CXL'                                               Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         Arial                                                         dataenvironment                                               wTop = 0
Left = 0
Width = 0
Height = 0
Visible = .F.
TabStop = .F.
DataSource = .NULL.
Name = "Dataenvironment"
       %ORIENTATION=0
PAPERSIZE=9
COLOR=1
                         Arial Narrow                                                  
rs_arrdate                                                    ad_lname, ad_fname                                            Arial Narrow                                                  alltrim(company)                                                                                                            Arial Narrow                                                  4rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3)                                                                        Arial Narrow                                                  Trim(get_rm_rmname(RS_ROOMNUM))                                                                                             Arial Narrow                                                  
RS_RATECOD                                                    Arial Narrow                                                  RS_RATE                                                       "999,999,999.99"                                              CURRENCY                                                      Arial Narrow                                                  
rs_arrdate                                                    Arial Narrow                                                  
rs_depdate                                                    Arial Narrow                                                  	RS_STATUS                                                     Arial Narrow                                                  RepoText("LIST", "ARRDATE")                                   Arial Narrow                                                  RepoText("LIST", "DEPDATE")                                   Arial Narrow                                                  RepoText("LIST", "RATECODE")                                  Arial Narrow                                                  RepoText("LIST", "RATE")                                      Arial Narrow                                                  RepoText("LIST", "STATUS")                                    Arial Narrow                                                  RepoText("LIST", "TOTALS")                                    Arial Narrow                                                  RepoText("LIST", "GUEST")                                     Arial Narrow                                                  RepoText("LIST", "COMPANY")                                   Arial Narrow                                                  RepoText("LIST", "ROOM")                                      Arial Narrow                                                  RepoText("LIST", "PAX")                                       Arial Narrow                                                  4rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3)                                                                        Arial Narrow                                                  Proper(rs_group)                                              Arial Narrow                                                  RepoText("LIST", "GROUP")                                     Arial Narrow                                                  
rs_arrdate                                                    Arial Narrow                                                  MyCDoW(rs_arrdate)                                            Arial Narrow                                                  RepoText("LIST", "SUBTOTALS")                                 Arial Narrow                                                  4rs_rooms*(rs_adults+rs_childs+rs_childs2+rs_childs3)                                                                        Arial Narrow                                                  RepoText("LIST", "ARRDATE")                                   Arial Narrow                                                  DTOC(DATE()) + " " + TIME()                                   Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  max3                                                          Arial Narrow                                                  max4                                                          Arial Narrow                                                  max1                                                          Arial Narrow                                                  min4                                                          Arial Narrow                                                  min3                                                          Arial Narrow                                                  min1                                                          Arial Narrow                                                  prompt4                                                       Arial Narrow                                                  prompt3                                                       Arial Narrow                                                  prompt2                                                       Arial Narrow                                                  prompt1                                                       Arial Narrow                                                  title                                                         Arial Narrow                                                  "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         RepoText("LIST", "USERID")                                    Arial Narrow                                                  RepoText("LIST", "PRINTED")                                   Arial Narrow                                                  max2                                                          Arial Narrow                                                  min2                                                          Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  RepoText("LIST", "PAGE")                                      Arial Narrow                                                  Walltrim(str(Param.Pa_Version,7,2)+"-"+str(param.pa_build,3,0)+"/"+trim(lists.li_extra))                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  1alltrim(rs_arrtime) + " - " + alltrim(rs_deptime)                                                                           Arial Narrow                                                  RepoText("LIST", "TIME")                                                                                                    Arial Narrow                                                  
RS_CNFSTAT                                                                                                                  Arial Narrow                                                  RepoText("LIST", "CNFSTAT")                                                                                                 Arial Narrow                                                  'MLine(RS_CHANGES, MemLines(RS_CHANGES))                                                                                     Arial                                                         rs_status='CXL'                                               )MLine(RS_CHANGES, MemLines(RS_CHANGES)-1)                     "@B"                                                          Arial                                                         rs_status='CXL'                                               $"CXL-Nr.: " + alltrim(str(rs_cxlnr))                                                                                        Arial                                                         rs_status='CXL'                                               Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         Arial                                                         dataenvironment                                               wTop = 0
Left = 0
Width = 0
Height = 0
Visible = .F.
TabStop = .F.
DataSource = .NULL.
Name = "Dataenvironment"
 