  (   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=1
ORTPROMPT:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
                                         4    winspool  PDF  PORTPROMPT:                            Arial Narrow                                                  
rm_roomnum                                                    Evaluate("rm_lang" + g_LangNum)                               Arial Narrow                                                  EMPTY(pl_charcod)                                             get_rt_roomtyp(RM_ROOMTYP)                                                                                                  Arial Narrow                                                  EMPTY(pl_charcod)                                             RM_FLOOR                                                      Arial Narrow                                                  EMPTY(pl_charcod)                                             
RM_MAXPERS                                                    Arial Narrow                                                  EMPTY(pl_charcod)                                             RM_BEDS                                                                                                                     Arial Narrow                                                  EMPTY(pl_charcod)                                             	rm_rmname                                                     Arial Narrow                                                  EMPTY(pl_charcod)                                             RM_PHONE                                                      Arial Narrow                                                  EMPTY(pl_charcod)                                             RepoText("LIST", "MAXPERS")                                   Arial Narrow                                                  RepoText("LIST", "FLOOR")                                     Arial Narrow                                                  RepoText("LIST", "DESCRIPT")                                  Arial Narrow                                                  RepoText("LIST", "ROOMTYPE")                                  Arial Narrow                                                  RepoText("LIST", "ROOM")                                      Arial Narrow                                                  RepoText("LIST", "PHONES")                                    Arial Narrow                                                  RepoText("LIST", "BEDS")                                                                                                    Arial Narrow                                                  rt_group<>2                                                   sumrooms                                                      Arial Narrow                                                  RepoText("LIST", "TOTALS")                                                                                                  Arial Narrow                                                  RepoText("LIST", "SEQUENCE")                                  Arial Narrow                                                  RM_RPSEQ                                                      Arial Narrow                                                  EMPTY(pl_charcod)                                             sumbeds                                                       Arial Narrow                                                  rt_group<>2                                                                                                                 rt_group<>2                                                   get_rm_rmname_linked(RM_LINK)                                 ""                                                            Arial Narrow                                                  EMPTY(pl_charcod)                                             RepoText("LIST", "LINKS")                                                                                                   Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  RepoText("LIST", "PAGE")                                      Arial Narrow                                                  Walltrim(str(Param.Pa_Version,7,2)+"-"+str(param.pa_build,3,0)+"/"+trim(lists.li_extra))                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  DATE()                                                        Arial Narrow                                                  TIME()                                                        Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  max3                                                          Arial Narrow                                                  max4                                                          Arial Narrow                                                  max1                                                          Arial Narrow                                                  min4                                                          Arial Narrow                                                  min3                                                          Arial Narrow                                                  min1                                                          Arial Narrow                                                  prompt4                                                       Arial Narrow                                                  prompt3                                                       Arial Narrow                                                  prompt2                                                       Arial Narrow                                                  prompt1                                                       Arial Narrow                                                  title                                                         Arial Narrow                                                  "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         RepoText("LIST", "USERID")                                    Arial Narrow                                                  RepoText("LIST", "PRINTED")                                   Arial Narrow                                                  max2                                                          Arial Narrow                                                  min2                                                          Arial Narrow                                                  pl_lang3                                                      Arial Narrow                                                  min1 AND NOT EMPTY(pl_charcod)                                
pl_charcod                                                    Arial Narrow                                                  min1 AND NOT EMPTY(pl_charcod)                                sumbeds                                                        IIF(EMPTY(pl_charcod),rm_beds,0)                              0                                                             sumrooms                                                      IIF(EMPTY(pl_charcod),1,0)                                    0                                                             Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         Arial Narrow                                                  dataenvironment                                               wTop = 0
Left = 0
Width = 0
Height = 0
Visible = .F.
TabStop = .F.
DataSource = .NULL.
Name = "Dataenvironment"
       �DRIVER=winspool
DEVICE=PDF
OUTPUT=PORTPROMPT:
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=1
YRESOLUTION=600
                                         4    winspool  PDF  PORTPROMPT:                            Arial Narrow                                                  
rm_roomnum                                                    Evaluate("rm_lang" + g_LangNum)                               Arial Narrow                                                  EMPTY(pl_charcod)                                             get_rt_roomtyp(RM_ROOMTYP)                                                                                                  Arial Narrow                                                  EMPTY(pl_charcod)                                             RM_FLOOR                                                      Arial Narrow                                                  EMPTY(pl_charcod)                                             
RM_MAXPERS                                                    Arial Narrow                                                  EMPTY(pl_charcod)                                             RM_BEDS                                                                                                                     Arial Narrow                                                  EMPTY(pl_charcod)                                             	rm_rmname                                                     Arial Narrow                                                  EMPTY(pl_charcod)                                             RM_PHONE                                                      Arial Narrow                                                  EMPTY(pl_charcod)                                             RepoText("LIST", "MAXPERS")                                   Arial Narrow                                                  RepoText("LIST", "FLOOR")                                     Arial Narrow                                                  RepoText("LIST", "DESCRIPT")                                  Arial Narrow                                                  RepoText("LIST", "ROOMTYPE")                                  Arial Narrow                                                  RepoText("LIST", "ROOM")                                      Arial Narrow                                                  RepoText("LIST", "PHONES")                                    Arial Narrow                                                  RepoText("LIST", "BEDS")                                                                                                    Arial Narrow                                                  rt_group<>2                                                   sumrooms                                                      Arial Narrow                                                  RepoText("LIST", "TOTALS")                                                                                                  Arial Narrow                                                  RepoText("LIST", "SEQUENCE")                                  Arial Narrow                                                  RM_RPSEQ                                                      Arial Narrow                                                  EMPTY(pl_charcod)                                             sumbeds                                                       Arial Narrow                                                  rt_group<>2                                                                                                                 rt_group<>2                                                   get_rm_rmname_linked(RM_LINK)                                 ""                                                            Arial Narrow                                                  EMPTY(pl_charcod)                                             RepoText("LIST", "LINKS")                                                                                                   Arial Narrow                                                  _pageno                                                       Arial Narrow                                                  RepoText("LIST", "PAGE")                                      Arial Narrow                                                  Walltrim(str(Param.Pa_Version,7,2)+"-"+str(param.pa_build,3,0)+"/"+trim(lists.li_extra))                                                                                                     Arial Narrow                                                  6"� by Citadel Hotelsoftware Schlingmeier + Partner KG"                                                                      Arial Narrow                                                  DATE()                                                        Arial Narrow                                                  TIME()                                                        Arial Narrow                                                  g_userid                                                      Arial Narrow                                                  Param.pa_hotel, Param.pa_city                                 Arial Narrow                                                  max3                                                          Arial Narrow                                                  max4                                                          Arial Narrow                                                  max1                                                          Arial Narrow                                                  min4                                                          Arial Narrow                                                  min3                                                          Arial Narrow                                                  min1                                                          Arial Narrow                                                  prompt4                                                       Arial Narrow                                                  prompt3                                                       Arial Narrow                                                  prompt2                                                       Arial Narrow                                                  prompt1                                                       Arial Narrow                                                  title                                                         Arial Narrow                                                  "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         "-"                                                           Arial                                                         RepoText("LIST", "USERID")                                    Arial Narrow                                                  RepoText("LIST", "PRINTED")                                   Arial Narrow                                                  max2                                                          Arial Narrow                                                  min2                                                          Arial Narrow                                                  pl_lang3                                                      Arial Narrow                                                  min1 AND NOT EMPTY(pl_charcod)                                
pl_charcod                                                    Arial Narrow                                                  min1 AND NOT EMPTY(pl_charcod)                                sumbeds                                                        IIF(EMPTY(pl_charcod),rm_beds,0)                              0                                                             sumrooms                                                      IIF(EMPTY(pl_charcod),1,0)                                    0                                                             Arial Narrow                                                  Arial Narrow                                                  Arial Narrow                                                  Arial                                                         Arial Narrow                                                  dataenvironment                                               wTop = 0
Left = 0
Width = 0
Height = 0
Visible = .F.
TabStop = .F.
DataSource = .NULL.
Name = "Dataenvironment"
 