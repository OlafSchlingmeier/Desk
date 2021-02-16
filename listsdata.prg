Function addresshistory
Lparameters naddrid,nindex
LOCAL lcSql, l_cColSourceMacro
Wait Window 'Please wait...' Nowait

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
SELECT hr_reserid, hr_addrid, hr_compid, hr_agentid, hr_lname, hr_arrdate, hr_depdate, ;
	hr_arrtime, hr_deptime, hr_rooms, hr_roomtyp, hr_roomnum, hr_adults, hr_childs, ;
	hr_childs2, hr_childs3, hr_rate, hr_ratecod, hr_status, hr_company, hr_group, ;
	NVL(al_allott, <<sqlcnv(SPACE(30),.T.)>>) AS al_allott ;
	FROM histres ;
	LEFT JOIN althead ON hr_altid = al_altid ;
	WHERE hr_addrid = <<sqlcnv(naddrid,.T.)>> OR ;
	hr_compid = <<sqlcnv(naddrid,.T.)>> OR ;
	hr_agentid = <<sqlcnv(naddrid,.T.)>>
ENDTEXT
sqlcursor(lcSql,"cTmpHistres",,,,.T.,,.T.)

TEXT TO lcSql TEXTMERGE NOSHOW PRETEXT 15
SELECT * FROM grid
	WHERE gr_user = <<sqlcnv(g_userid,.T.)>> AND gr_label = <<sqlcnv(PADR("REVNUEGRID",30),.T.)>> AND gr_activ
	ORDER BY gr_order
ENDTEXT
lcurGrid = sqlcursor(lcSql)

SELECT cTmpHistres
Index On Dtos(hr_arrdate) Tag tag1
Index On Dtos(hr_arrdate) Tag tag2 Descending
Index On Dtos(hr_depdate) Tag tag3
Index On Dtos(hr_depdate) Tag tag4 Descending

* header data
=Seek(naddrid,'address','tag1')

Create Cursor Query (c1 c(100),;
	c2 c(100),;
	c3 c(100),;
	c4 c(100),;
	c5 c(100),;
	c6 c(100),;
	c7 c(100),;
	c8 c(100),;
	c9 c(100),;
	c10 c(100),;
	c11 c(100),;
	c12 c(100),;
	c13 c(100),;
	c14 c(100),;
	h1 c(100),;
	h2 c(100),;
	h3 c(100),;
	h4 c(100),;
	h5 c(100),;
	h6 c(100),;
	h7 c(100),;
	h8 c(100),;
	h9 c(100),;
	h10 c(100),;
	h11 c(100),;
	h12 c(100),;
	h13 c(100),;
	h14 c(100),;
	title c(100))
Select cTmpHistres
Scan
	lnCount=1
	m.title='Address history'
	Select &lcurGrid
	Scan
		cSource = ""
		l_cColSourceMacro = "_screen.ActiveForm.MainPage.PageAddress.SlavePage.PageRevnue.RevnueGrid."+ALLTRIM(gr_column)+".ControlSource"
		
		TRY
			cSource = &l_cColSourceMacro
		CATCH
		ENDTRY
		IF NOT EMPTY(cSource)
			cMacro='m.c'+Alltrim(Str(lnCount))
			&cMacro=Alltrim(Padr(&cSource,100))
			cMacro='m.h'+Alltrim(Str(lnCount))
			&cMacro=Alltrim(Padr(gr_caption,100))
			lnCount=lnCount+1
		ENDIF
	Endscan
	Insert Into Query From Memvar
	Select cTmpHistres
Endscan
dclose(lcurGrid)
dclose("cTmpHistres")
Select Query
Wait Clear
Endfunc