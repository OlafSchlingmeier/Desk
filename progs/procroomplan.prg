* PROCEDURE procroomplan
PROCEDURE OpenData
LPARAMETERS tcTablePath, tlConf

OpenFileDirect(,"resrooms",,tcTablePath)
OpenFileDirect(,"reschg",,tcTablePath)
OpenFileDirect(,"reservat",,tcTablePath)
OpenFileDirect(,"ratecode",,tcTablePath)
OpenFileDirect(,"groupres",,tcTablePath)
OpenFileDirect(,"availab",,tcTablePath)
OpenFileDirect(,"althead",,tcTablePath)
*OpenFileDirect(,"room",,tcTablePath)
OpenFileDirect(,"roomtype",,tcTablePath)
OpenFileDirect(,"rtypedef",,tcTablePath)
OpenFileDirect(,"building",,tcTablePath)
OpenFileDirect(,"roomfeat",,tcTablePath)
OpenFileDirect(,"address",,tcTablePath)
OpenFileDirect(,"apartner",,tcTablePath)
OpenFileDirect(,"outofser",,tcTablePath)
OpenFileDirect(,"outoford",,tcTablePath)
OpenFileDirect(,"citcolor",,tcTablePath)
OpenFileDirect(,"resrate",,tcTablePath)
OpenFileDirect(,"resfix",,tcTablePath)
OpenFileDirect(,"resfeat",,tcTablePath)
OpenFileDirect(,"document",,tcTablePath)
OpenFileDirect(,"article",,tcTablePath)
*OpenFileDirect(,"post",,tcTablePath)
*OpenFileDirect(,"menu",,tcTablePath)
*OpenFileDirect(,"laststay",,tcTablePath)
*OpenFileDirect(,"deposit",,tcTablePath)
*OpenFileDirect(,"cashier",,tcTablePath)
*OpenFileDirect(,"user",,tcTablePath)
*OpenFileDirect(,"group",,tcTablePath)
OpenFileDirect(,"season",,tcTablePath)
OpenFileDirect(,"evint",,tcTablePath)
OpenFileDirect(,"events",,tcTablePath)
OpenFileDirect(,"hresrate",,tcTablePath)
IF tlConf
	OpenFileDirect(,"pictures",,tcTablePath)
	OpenFileDirect(,"roompict",,tcTablePath)
	OpenFileDirect(,"bqbesthl",,tcTablePath)
	OpenFileDirect(,"respict",,tcTablePath)
ENDIF
ENDPROC
*
PROCEDURE CloseData
DClose("resrooms")
DClose("reschg")
DClose("reservat")
DClose("ratecode")
DClose("groupres")
DClose("availab")
DClose("althead")
*DClose("room")
DClose("roomtype")
DClose("rtypedef")
DClose("building")
DClose("roomfeat")
DClose("address")
DClose("apartner")
DClose("outofser")
DClose("outoford")
DClose("citcolor")
DClose("resrate")
DClose("resfix")
DClose("resfeat")
DClose("document")
DClose("article")
*DClose("post")
*DClose("menu")
*DClose("laststay")
*DClose("deposit")
*DClose("cashier")
*DClose("user")
*DClose("group")
DClose("season")
DClose("evint")
DClose("events")
DClose("hresrate")
DClose("pictures")
DClose("roompict")
DClose("bqbesthl")
DClose("respict")
ENDPROC
*
DEFINE CLASS RoomPlanDE AS dataenvironment
     Name = "dataenvironment"
     AutoOpenTables = .F.
     DataSource = .NULL.

     ADD OBJECT curreschg AS cursor WITH ;
          Alias = "reschg", ;
          CursorSource = "..\data\reschg.dbf", ;
          Name = "curreschg"

     ADD OBJECT curroomplan AS cursor WITH ;
          Alias = "roomplan", ;
          CursorSource = "..\data\roomplan.dbf", ;
          Name = "curroomplan"

     ADD OBJECT curreservat AS cursor WITH ;
          Alias = "reservat", ;
          CursorSource = "..\data\reservat.dbf", ;
          Name = "curreservat"

     ADD OBJECT curratecode AS cursor WITH ;
          Alias = "ratecode", ;
          CursorSource = "..\data\ratecode.dbf", ;
          Order = "TAG1", ;
          Name = "curratecode"

     ADD OBJECT curroom AS cursor WITH ;
          Alias = "room", ;
          CursorSource = "..\data\room.dbf", ;
          Name = "curroom"

     ADD OBJECT curroomtype AS cursor WITH ;
          Alias = "roomtype", ;
          CursorSource = "..\data\roomtype.dbf", ;
          Name = "curroomtype"

     ADD OBJECT curseason AS cursor WITH ;
          Alias = "season", ;
          CursorSource = "..\data\season.dbf", ;
          Order = "TAG1", ;
          Name = "curseason"

     ADD OBJECT curpost AS cursor WITH ;
          Alias = "post", ;
          CursorSource = "..\data\post.dbf", ;
          Name = "curpost"

     ADD OBJECT curroomfeat AS cursor WITH ;
          Alias = "roomfeat", ;
          CursorSource = "..\data\roomfeat.dbf", ;
          Name = "roomfeat"

     ADD OBJECT curaddress AS cursor WITH ;
          Alias = "address", ;
          CursorSource = "..\data\address.dbf", ;
          Name = "curaddress"

     ADD OBJECT curoutoford AS cursor WITH ;
          Alias = "outoford", ;
          CursorSource = "..\data\outoford.dbf", ;
          Order = "TAG1", ;
          Filter = "NOT oo_cancel", ;
          Name = "curoutoford"

     ADD OBJECT curmenu AS cursor WITH ;
          Alias = "menu", ;
          CursorSource = "..\data\menu.dbf", ;
          Name = "curmenu"

     ADD OBJECT curlaststay AS cursor WITH ;
          Alias = "laststay", ;
          CursorSource = "..\data\laststay.dbf", ;
          Name = "curlaststay"

     ADD OBJECT curdeposit AS cursor WITH ;
          Alias = "deposit", ;
          CursorSource = "..\data\deposit.dbf", ;
          Name = "curdeposit"

     ADD OBJECT curapartner AS cursor WITH ;
          Alias = "apartner", ;
          CursorSource = "..\data\apartner.dbf", ;
          Name = "curapartner"

     ADD OBJECT curcashier AS cursor WITH ;
          Alias = "cashier", ;
          CursorSource = "..\data\cashier.dbf", ;
          Name = "curcashier"

     ADD OBJECT curuser AS cursor WITH ;
          Alias = "user", ;
          CursorSource = "..\data\user.dbf", ;
          Name = "curuser"

     ADD OBJECT curgroup AS cursor WITH ;
          Alias = "group", ;
          CursorSource = "..\data\group.dbf", ;
          Name = "curgroup"

     ADD OBJECT curoutofser AS cursor WITH ;
          Alias = "outofser", ;
          CursorSource = "..\data\outofser.dbf", ;
          Name = "curoutofser"

     ADD OBJECT curcitcolor AS cursor WITH ;
          Alias = "citcolor", ;
          CursorSource = "..\data\citcolor.dbf", ;
          Name = "curcitcolor"

     ADD OBJECT curresrate AS cursor WITH ;
          Alias = "resrate", ;
          CursorSource = "..\data\resrate.dbf", ;
          Order = "TAG2", ;
          Name = "curresrate"

     ADD OBJECT curresrooms AS cursor WITH ;
          Alias = "resrooms", ;
          CursorSource = "..\data\resrooms.dbf", ;
          BufferModeOverride = 5, ;
          Name = "curresrooms"

     ADD OBJECT curdocument AS cursor WITH ;
          Alias = "document", ;
          CursorSource = "..\data\document.dbf", ;
          Name = "curdocument"

ENDDEFINE
*
DEFINE CLASS ConfRoomPlanDE AS RoomPlanDE
     Name = "dataenvironment"
     AutoOpenTables = .F.
     DataSource = .NULL.

     ADD OBJECT curpictures AS cursor WITH ;
          Alias = "pictures", ;
          CursorSource = "..\data\pictures.dbf", ;
          Order = "TAG1", ;
          Name = "curpictures"

     ADD OBJECT curroompict AS cursor WITH ;
          Alias = "roompict", ;
          CursorSource = "..\data\roompict.dbf", ;
          Order = "TAG1", ;
          Name = "curroompict"

     ADD OBJECT curbqbesthl AS cursor WITH ;
          Alias = "bqbesthl", ;
          CursorSource = "..\data\bqbesthl.dbf", ;
          Order = "TAG1", ;
          Name = "curbqbesthl"

     ADD OBJECT currespict AS cursor WITH ;
          Alias = "respict", ;
          CursorSource = "..\data\respict.dbf", ;
          Order = "TAG1", ;
          Name = "currespict"

ENDDEFINE
*