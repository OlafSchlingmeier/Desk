*
FUNCTION LangEdit
 PARAMETER cpRefix, ctItle, pnEditsize
 PRIVATE acLang
 PRIVATE noLdarea
 PRIVATE noLdorder
 PRIVATE noLdrecord
 PRIVATE cfIeld
 PRIVATE ncOunt
 PRIVATE nsIze
 PRIVATE nrOw
 PRIVATE ncOl
 PRIVATE nlOopcount
 PRIVATE cvAriable
 IF EMPTY(pnEditsize)
      pnEditsize = 25
 ENDIF
 IF (LASTKEY()==24)
      noLdarea = SELECT()
      noLdorder = ORDER("picklist")
      noLdrecord = RECNO("picklist")
      cfIeld = "PickList.Pl_Lang"+g_Langnum
      SELECT piCklist
      SET ORDER TO 3
      = SEEK("LANGUAGE", "PickList")
      Copy To Array acLang 					 Fields &cField					 While PickList.Pl_Label = "LANGUAGE"
      ncOunt = _TALLY
      nsIze = ncOunt*1.25+1.75
      SET ORDER IN "PickList" TO nOldOrder
      GOTO noLdrecord IN "PickList"
      SELECT (noLdarea)
      DEFINE WINDOW wlAnguages AT 0.000, 0.000 SIZE nsIze, 60.000 FONT  ;
             "Arial", 10 NOGROW NOFLOAT NOCLOSE TITLE ctItle NOMDI SYSTEM
      MOVE WINDOW wlAnguages CENTER
      ACTIVATE WINDOW wlAnguages
      nrOw = 1.00
      ncOl = 25.00
      DO paNel WITH 1/4, 2/3, WROWS()-(0.25), WCOLS()-(0.666666666666667)
      FOR nlOopcount = 1 TO ncOunt
           cvAriable = "m."+cpRefix+"Lang"+LTRIM(STR(nlOopcount))
           DO paNel WITH nrOw-(0.0625), 8/3, nrOw+1+(0.0625), 70/3, 2
           @ nrOw, 4.000 SAY acLang(nlOopcount) SIZE 1, 19
           @ nRow, 25.00 Get &cVariable Picture "@K " + Replicate("X", pnEditSize) Size 1, 30 
           nrOw = nrOw+1.25
      ENDFOR
      READ MODAL
      RELEASE WINDOW wlAnguages
 ENDIF
 RETURN .T.
ENDFUNC
*
