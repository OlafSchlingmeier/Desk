  �   !                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Arial                          ?  )  winspool Brother MFL Pro Printer LPT1:                                                  �Brother MFL Pro Printer         � 8f  	 �4d    X  X   A4                                                                                    �  PRIV�                                                                                        '''  '        eF �                                                                                     �              S p l C t r l . e x e                                            X  (         ��                             �DRIVER=winspool
DEVICE=Brother MFL Pro Printer
OUTPUT=LPT1:
ORIENTATION=0
PAPERSIZE=9
SCALE=100
DEFAULTSOURCE=7
PRINTQUALITY=600
YRESOLUTION=600
TTOPTION=1
                              ..\DBF\FILES.DBF               Files                          Tag1                           ..\DBF\ADDRESS.DBF             Address                        Tag1                           ..\DBF\LICENSE.DBF             License                        ..\DBF\ADDRESS.DBF             Agent                          Tag1                           ..\DBF\ADDRESS.DBF             Company                        Tag1                           ..\DBF\ADDRESS.DBF             Saddress                       ..\DBF\ALLOTT.DBF              Allott                         Tag1                           ..\DBF\ARTICLE.DBF             Article                        Tag1                           ..\DBF\AVAILAB.DBF             Availab                        Tag1                           ..\DBF\CASHIER.DBF             Cashier                        ..\DBF\EVENT.DBF               Event                          Tag1                           ..\DBF\GROUP.DBF               Group                          ..\DBF\HISTPOST.DBF            Histpost                       Tag1                           ..\DBF\HISTRES.DBF             Histres                        Tag1                           ..\DBF\LANGUAGE.DBF            Language                       Tag1                           ..\DBF\LISTS.DBF               Lists                          Tag1                           ..\DBF\PARAM.DBF               Param                          ..\DBF\PAYMETHO.DBF            Paymetho                       Tag1                           ..\DBF\PICKLIST.DBF            Picklist                       Tag1                           ..\DBF\POST.DBF                Post                           Tag1                           ..\DBF\RATEARTI.DBF            Ratearti                       Tag1                           ..\DBF\RATECODE.DBF            Ratecode                       Tag1                           ..\DBF\RESERVAT.DBF            Reservat                       Tag1                           ..\DBF\ROOM.DBF                Room                           Tag1                           ..\DBF\ROOMFEAT.DBF            Roomfeat                       Tag1                           ..\DBF\ROOMPLAN.DBF            Roomplan                       Tag1                           ..\DBF\ROOMTYPE.DBF            Roomtype                       Tag1                           ..\DBF\TITLE.DBF               Title                          Tag1                           ..\DBF\USER.DBF                User                           Tag1                           ..\DBF\LOGACT.DBF              Logact                         
rs_agentid                     Agent                          Reservat                       	rs_compid                      Company                        Reservat                       	rs_addrid                      Address                        Reservat                       Query.arrdate                  Arial                          Query.depdate                  Arial                          blname                                                        Arial                          bfname                                                        Arial                          bzip                                                          Arial                          bcity                                                         Arial                          bstrasse                                                      Arial                          bland                                                         Arial                          bbirth                                                        Arial                          Arial                          "ANMELDUNG"                    Arial                          "REGISTRATION / INSCRIPTION"                                    Arial                          	"Ankunft"                      Arial                          	"Abreise"                      Arial                          "Name"                         Arial                          	"arrival"                      Arial                          "departure"                    Arial                          "name"                         Arial                          "residence,no,street"          Arial                          "state"                        Arial                          "date of birth"                Arial                          "PLZ, Wohnort, Stra�e"         Arial                          "Staat bzw. Bundesland"        Arial                          "Geburtsdatum"                 Arial                          "Privatanschrift"              Arial                          "Staatsangeh�rigkeit"          bland                                                         Arial                          Arial                          "Zimmer Nr."                   Arial                          "room number"                  Arial                          "Rechnungsanschrift"           azip                                                          Arial                          rs_compid<>0                   acity                                                         Arial                          rs_compid<>0                   astrasse                                                      Arial                          rs_compid<>0                   aland                                                         Arial                          rs_compid<>0                   Arial                          "residence,no,street"          Arial                          "PLZ, Wohnort, Stra�e"         Arial                          "Staat bzw. Bundesland"        Arial                          "Telefonnr."                   Arial                          "Fax"                          Arial                          "telefon number"               Arial                          "fax"                          Arial                          "Telefonnr."                   Arial                          "Fax"                          Arial                          "telefon number"               Arial                          "fax"                          aphone                                                        Arial                          rs_compid<>0                   afax                                                          Arial                          rs_compid<>0                   Query.rs_roomnum               Arial                          bphone                                                        Arial                          bfax                                                          Arial                          empty(Query.ad_phone_a)        empty(Query.ad_fax_a)          Jempty(query.ad_zip_a) or empty(query.ad_city_a) or empty(Query.ad_stree_a)                       acompany                                                      Arial                          rs_compid<>0                   adepartm                                                      Arial                          rs_compid<>0                   empty(Query.bname)             Arial                          	"Vorname"                      Arial                          "first name"                   empty(Query.ad_fname_b)        empty(Query.ad_compa_a)        Arial                          !empty(query.ad_compa_b)       "Firma"                        Arial                          !empty(query.ad_compa_b)       	"company"                      bcompany                                                      Arial                          !empty(bcompany)               Arial                          %"signature(chr. name and first name)"                           Arial                          "Unterschrift"                 Arial                          Arial                          Arial                          Arial                          Arial                          Arial                          dataenvironment                gAutoOpenTables = .T.
AutoCloseTables = .T.
InitialSelectedAlias = "Lists"
Name = "dataenvironment"
                           sPROCEDURE Destroy
*- [CONVERTER] Tabellen zwecks Kompatibilit�t zur�cksetzenTHIS.OpenTablesTHIS.Init
ENDPROC
               ����    �   �                         d�   %   _       x      p           �  U   
 ��  � �
 ��  � � U  THIS
 OPENTABLES INIT Destroy,     ��1 � � 2                       h       )   �                              cursor                         �Alias = "Files"
Order = "Tag1"
CursorSource = ..\dbf\files.dbf
Name = "cursor1"
                                                                                                                                                 cursor                         XAlias = "Address"
Order = "Tag1"
CursorSource = ..\dbf\address.dbf
Name = "cursor2"
         cursor                         HAlias = "License"
CursorSource = ..\dbf\license.dbf
Name = "cursor3"
                         cursor                         VAlias = "Agent"
Order = "Tag1"
CursorSource = ..\dbf\address.dbf
Name = "cursor4"
           cursor                         XAlias = "Company"
Order = "Tag1"
CursorSource = ..\dbf\address.dbf
Name = "cursor5"
         cursor                         IAlias = "Saddress"
CursorSource = ..\dbf\address.dbf
Name = "cursor6"
                        cursor                         VAlias = "Allott"
Order = "Tag1"
CursorSource = ..\dbf\allott.dbf
Name = "cursor7"
           cursor                         XAlias = "Article"
Order = "Tag1"
CursorSource = ..\dbf\article.dbf
Name = "cursor8"
         cursor                         XAlias = "Availab"
Order = "Tag1"
CursorSource = ..\dbf\availab.dbf
Name = "cursor9"
         cursor                         IAlias = "Cashier"
CursorSource = ..\dbf\cashier.dbf
Name = "cursor10"
                        cursor                         UAlias = "Event"
Order = "Tag1"
CursorSource = ..\dbf\event.dbf
Name = "cursor11"
            cursor                         EAlias = "Group"
CursorSource = ..\dbf\group.dbf
Name = "cursor12"
                            cursor                         [Alias = "Histpost"
Order = "Tag1"
CursorSource = ..\dbf\histpost.dbf
Name = "cursor13"
      cursor                         YAlias = "Histres"
Order = "Tag1"
CursorSource = ..\dbf\histres.dbf
Name = "cursor14"
        cursor                         [Alias = "Language"
Order = "Tag1"
CursorSource = ..\dbf\language.dbf
Name = "cursor15"
      cursor                         UAlias = "Lists"
Order = "Tag1"
CursorSource = ..\dbf\lists.dbf
Name = "cursor16"
            cursor                         EAlias = "Param"
CursorSource = ..\dbf\param.dbf
Name = "cursor17"
                            cursor                         [Alias = "Paymetho"
Order = "Tag1"
CursorSource = ..\dbf\paymetho.dbf
Name = "cursor18"
      cursor                         [Alias = "Picklist"
Order = "Tag1"
CursorSource = ..\dbf\picklist.dbf
Name = "cursor19"
      cursor                         SAlias = "Post"
Order = "Tag1"
CursorSource = ..\dbf\post.dbf
Name = "cursor20"
              cursor                         [Alias = "Ratearti"
Order = "Tag1"
CursorSource = ..\dbf\ratearti.dbf
Name = "cursor21"
      cursor                         [Alias = "Ratecode"
Order = "Tag1"
CursorSource = ..\dbf\ratecode.dbf
Name = "cursor22"
      cursor                         [Alias = "Reservat"
Order = "Tag1"
CursorSource = ..\dbf\reservat.dbf
Name = "cursor23"
      cursor                         SAlias = "Room"
Order = "Tag1"
CursorSource = ..\dbf\room.dbf
Name = "cursor24"
              cursor                         [Alias = "Roomfeat"
Order = "Tag1"
CursorSource = ..\dbf\roomfeat.dbf
Name = "cursor25"
      cursor                         [Alias = "Roomplan"
Order = "Tag1"
CursorSource = ..\dbf\roomplan.dbf
Name = "cursor26"
      cursor                         [Alias = "Roomtype"
Order = "Tag1"
CursorSource = ..\dbf\roomtype.dbf
Name = "cursor27"
      cursor                         UAlias = "Title"
Order = "Tag1"
CursorSource = ..\dbf\title.dbf
Name = "cursor28"
            cursor                         SAlias = "User"
Order = "Tag1"
CursorSource = ..\dbf\user.dbf
Name = "cursor29"
              cursor                         GAlias = "Logact"
CursorSource = ..\dbf\logact.dbf
Name = "cursor30"
                          relation                       yParentAlias = "Reservat"
RelationalExpr = "rs_agentid"
ChildAlias = "Agent"
ChildOrder = "Tag1"
Name = "relation31"
         relation                       zParentAlias = "Reservat"
RelationalExpr = "rs_compid"
ChildAlias = "Company"
ChildOrder = "Tag1"
Name = "relation32"
        relation                       zParentAlias = "Reservat"
RelationalExpr = "rs_addrid"
ChildAlias = "Address"
ChildOrder = "Tag1"
Name = "relation33"
         