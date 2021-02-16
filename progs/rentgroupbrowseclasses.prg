*rentgroupbrowseclasses
*
DEFINE CLASS grdinputcolumn AS Column
Sparse = .t.
ReadOnly = .F.
HeaderClass = "IHeader"
HeaderClassLibrary = "grdinputclasses.prg"
lonlyonce = .F.
ccontrolsourcecopy = ""
ADD OBJECT Header1 AS IHeader
ADD OBJECT tbinput1 AS itbgrid
ADD OBJECT cboinput1 AS icbogrid
ADD OBJECT tbgridro1 AS itbgridro
ADD OBJECT tbgridinforo1 AS itbgridinforo
ADD OBJECT cboinputtitle1 AS icbogridtitle
*
PROCEDURE ControlSource_ASSIGN
LPARAMETERS vNewVal
IF NOT this.lonlyonce AND NOT EMPTY(vNewVal)
     this.lonlyonce = .T.
     this.ccontrolsourcecopy = vNewVal
ENDIF
this.ControlSource = vNewVal
ENDPROC
ENDDEFINE
*
DEFINE CLASS IHeader AS Header
alignment = 2
ENDDEFINE
*
DEFINE CLASS itbgrid AS textbox
*
PROCEDURE InteractiveChange
*!*	DEBUGOUT "IC " + TRANSFORM(this.Value)
IF TYPE("thisform.oResData.clname")="C" AND TYPE("thisform.txtLastName.Name")="C"
	thisform.oResData.clname = ALLTRIM(TRANSFORM(this.Value))
	thisform.txtLastName.Refresh()
ENDIF
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS icbogrid AS cbodb OF libs\jbase.vcx
BorderStyle = 0
ldontsetcontrolsource = .T.
lsqlcursorfromalias = .T.
*
PROCEDURE GetRowSourceBefore
WITH this
     TEXT TO .jsql TEXTMERGE NOSHOW PRETEXT 15
          SELECT pl_charcod, <<"pl_lang"+g_langnum>> 
          FROM curcountry ORDER BY 1
     ENDTEXT
     .jboundcolumn = 1
     .jcolumncount = 2
     .jcolumnwidths = "40,150"
ENDWITH

RETURN .T.
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS icbogridtitle AS cbodb OF libs\jbase.vcx
BorderStyle = 0
ldontsetcontrolsource = .T.
lsqlcursorfromalias = .T.
*
PROCEDURE GetRowSourceBefore
LOCAL l_cSql

WITH this
     TEXT TO .jsql TEXTMERGE NOSHOW PRETEXT 15
          SELECT ti_title, ti_titlcod, ti_salute 
               FROM curtitle 
               ORDER BY ti_titlcod
     ENDTEXT
     .jboundcolumn = 1
     .jcolumncount = 2
     .jcolumnwidths = "150,40,250"
ENDWITH

RETURN .T.
ENDPROC
*
ENDDEFINE
*
DEFINE CLASS itbgridro AS textbox
*ReadOnly = .T.
Enabled = .T.
BackColor = RGB(192,192,192)
DisabledBackColor = RGB(192,192,192)
*
ENDDEFINE
*
DEFINE CLASS itbgridinforo AS textbox
*ReadOnly = .T.
Enabled = .T.
*
ENDDEFINE