     @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=2
UTPUT=pdfcmon
ORIENTATION=0
PAPERSIZE=9
SCALE=100
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                                                           7    winspool  PDFCreator  pdfcmon                         Arial Narrow                                                  day                                                           KDLookup('Room', 'rm_roomnum =' + SqlCnv(pp_roomnum), 'rm_lang' + g_LangNum)                                                                                                                 Arial Narrow                                                  Proper(pp_name)                                                                                                             Arial Narrow                                                  )pp_adults+pp_childs+pp_childs2+pp_childs3                                                                                   Arial Narrow                                                  get_rm_rmname(pp_ROOMNUM)                                                                                                   Arial Narrow                                                  
pp_arrtime                                                                                                                  Arial Narrow                                                  
pp_deptime                                                                                                                  Arial Narrow                                                  RepoText("LIST", "BEGIN")                                                                                                   Arial Narrow                                                  RepoText("LIST", "NAME")                                                                                                    Arial Narrow                                                  RepoText("LIST", "ROOM")                                                                                                    Arial Narrow                                                  RepoText("LIST", "PERS")                                                                                                    Arial Narrow                                                  
pp_reserid                                                                                                                  Arial Narrow                                                  RepoText("LIST", "RESID")                                     Arial Narrow                                                  RepoText("LIST", "END")                                                                                                     Arial Narrow                                                  RepoText("LIST", "SETUP")                                                                                                   Arial Narrow                                                  DToC(Day) + ' ' + MyCDoW(Day)                                                                                               Arial Narrow                                                  
pp_cnfstat                                                                                                                  Arial Narrow                                                  ">"                                                                                                                         Arial Narrow                                                  pp_depdate>day                                                ">"                                                                                                                         Arial Narrow                                                  pp_arrdate<day                                                RepoText("LIST", "STATUS")                                                                                                  Arial Narrow                                                  	pp_status                                                                                                                   Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  RepoText("LIST", "PAGE")                                      Arial Narrow                                                  Walltrim(str(Param.Pa_Version,7,2)+"-"+str(param.pa_build,3,0)+"/"+trim(lists.li_extra))                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  DTOC(DATE()) + " " + TIME()                                   ""                                                            Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  max3                                                          Arial Narrow                                                  max4                                                          Arial Narrow                                                  max1                                                          Arial Narrow                                                  min4                                                          Arial Narrow                                                  min3                                                          Arial Narrow                                                  min1                                                          Arial Narrow                                                  prompt4                                                       Arial Narrow                                                  prompt3                                                       Arial Narrow                                                  prompt2                                                       Arial Narrow                                                  prompt1                                                       Arial Narrow                                                  title                                                         Arial Narrow                                                  "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         RepoText("LIST", "USERID")                                    Arial Narrow                                                  RepoText("LIST", "PRINTED")                                   Arial Narrow                                                  max2                                                          Arial Narrow                                                  'IIF(EMPTY(min2),'',get_rm_rmname(min2))                       Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         dataenvironment                                               wTop = 0
Left = 0
Width = 0
Height = 0
Visible = .F.
TabStop = .F.
DataSource = .NULL.
Name = "Dataenvironment"
       �DRIVER=winspool
DEVICE=PDFCreator
OUTPUT=pdfcmon
ORIENTATION=0
PAPERSIZE=9
SCALE=100
ASCII=0
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
TTOPTION=3
COLLATE=1
                                                           7    winspool  PDFCreator  pdfcmon                         Arial Narrow                                                  day                                                           KDLookup('Room', 'rm_roomnum =' + SqlCnv(pp_roomnum), 'rm_lang' + g_LangNum)                                                                                                                 Arial Narrow                                                  Proper(pp_name)                                                                                                             Arial Narrow                                                  )pp_adults+pp_childs+pp_childs2+pp_childs3                                                                                   Arial Narrow                                                  get_rm_rmname(pp_ROOMNUM)                                                                                                   Arial Narrow                                                  
pp_arrtime                                                                                                                  Arial Narrow                                                  
pp_deptime                                                                                                                  Arial Narrow                                                  RepoText("LIST", "BEGIN")                                                                                                   Arial Narrow                                                  RepoText("LIST", "NAME")                                                                                                    Arial Narrow                                                  RepoText("LIST", "ROOM")                                                                                                    Arial Narrow                                                  RepoText("LIST", "PERS")                                                                                                    Arial Narrow                                                  
pp_reserid                                                                                                                  Arial Narrow                                                  RepoText("LIST", "RESID")                                     Arial Narrow                                                  RepoText("LIST", "END")                                                                                                     Arial Narrow                                                  RepoText("LIST", "SETUP")                                                                                                   Arial Narrow                                                  DToC(Day) + ' ' + MyCDoW(Day)                                                                                               Arial Narrow                                                  
pp_cnfstat                                                                                                                  Arial Narrow                                                  ">"                                                                                                                         Arial Narrow                                                  pp_depdate>day                                                ">"                                                                                                                         Arial Narrow                                                  pp_arrdate<day                                                RepoText("LIST", "STATUS")                                                                                                  Arial Narrow                                                  	pp_status                                                                                                                   Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  RepoText("LIST", "PAGE")                                      Arial Narrow                                                  Walltrim(str(Param.Pa_Version,7,2)+"-"+str(param.pa_build,3,0)+"/"+trim(lists.li_extra))                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  DTOC(DATE()) + " " + TIME()                                   ""                                                            Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  max3                                                          Arial Narrow                                                  max4                                                          Arial Narrow                                                  max1                                                          Arial Narrow                                                  min4                                                          Arial Narrow                                                  min3                                                          Arial Narrow                                                  min1                                                          Arial Narrow                                                  prompt4                                                       Arial Narrow                                                  prompt3                                                       Arial Narrow                                                  prompt2                                                       Arial Narrow                                                  prompt1                                                       Arial Narrow                                                  title                                                         Arial Narrow                                                  "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         RepoText("LIST", "USERID")                                    Arial Narrow                                                  RepoText("LIST", "PRINTED")                                   Arial Narrow                                                  max2                                                          Arial Narrow                                                  'IIF(EMPTY(min2),'',get_rm_rmname(min2))                       Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         dataenvironment                                               wTop = 0
Left = 0
Width = 0
Height = 0
Visible = .F.
TabStop = .F.
DataSource = .NULL.
Name = "Dataenvironment"
 