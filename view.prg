*
PROCEDURE VewCashier
 doform("frmViewCashier","forms\viewCashier")
 RETURN
ENDPROC
*
FUNCTION VewRatecode
 LPARAMETERS lp_cOption
 LOCAL ARRAY l_aParams(14)

 l_aparams(14) = (EVL(lp_cOption,"") <> "RATEFIND")
 Doform(IIF(l_aparams(14),"ratecodeview","ratecodeym"),"forms\ratecodeym",,, @l_aParams)

 RETURN .T.
ENDFUNC
*
PROCEDURE VewAvail
 LOCAL llFound
 LOCAL ARRAY laParams(2)
 DO ShowVisibleForm IN DoForm WITH "availability", llFound
 DO CASE
      CASE llFound
      CASE _screen.oGlobal.lNewAvailability
           laParams(2) = MakeStructure("oAvailData, dSelectedDate, lOK")
           laParams(2).oAvailData = MakeStructure("dDate, lOptiDef, lAlloDef, lTentDef, lOosDef")
           laParams(2).oAvailData.dDate = SysDate()
           laParams(2).oAvailData.lOptiDef = _screen.oGlobal.oParam.pa_optidef
           laParams(2).oAvailData.lAlloDef = _screen.oGlobal.oParam.pa_allodef
           laParams(2).oAvailData.lTentDef = _screen.oGlobal.oParam.pa_tentdef
           laParams(2).oAvailData.lOosDef = _screen.oGlobal.oParam2.pa_oosdef
           DO FORM "forms\AvlSearchForm" WITH laParams(2) TO laParams(2).lOK
           IF laParams(2).lOK
                laParams(2).dSelectedDate = EVL(laParams(2).dSelectedDate, SysDate())
                Doform("availability","forms\availability",,,@laParams)
           ENDIF
      OTHERWISE
           BrwAvailab()
 ENDCASE

 RETURN .T.
ENDPROC
*
PROCEDURE VewMaxAvail
 doform('maxavail', 'forms\availabilitymaximum')
 RETURN .T.
ENDPROC
*
PROCEDURE VewMultiPropAvail
 LOCAL llFound
 LOCAL ARRAY laParams(2)
ASSERT .f.
 DO ShowVisibleForm IN DoForm WITH "mpavailability", llFound
 DO CASE
      CASE llFound
      CASE _screen.oGlobal.lNewAvailability
           laParams(1) = "frmMultipropAvail"
           laParams(2) = MakeStructure("oAvailData, dSelectedDate, lOK")
           laParams(2).oAvailData = MakeStructure("dDate, lOptiDef, lAlloDef, lTentDef, lOosDef")
           laParams(2).oAvailData.dDate = SysDate()
           laParams(2).oAvailData.lOptiDef = _screen.oGlobal.oParam.pa_optidef
           laParams(2).oAvailData.lAlloDef = _screen.oGlobal.oParam.pa_allodef
           laParams(2).oAvailData.lTentDef = _screen.oGlobal.oParam.pa_tentdef
           laParams(2).oAvailData.lOosDef = _screen.oGlobal.oParam2.pa_oosdef
           DO FORM "forms\AvlSearchForm" WITH laParams(2) TO laParams(2).lOK
           IF laParams(2).lOK
                laParams(2).dSelectedDate = EVL(laParams(2).dSelectedDate, SysDate())
                Doform("mpavailability","forms\availability",,,@laParams)
           ENDIF
      OTHERWISE
           BrwAvailab("brwmultipropavail")
 ENDCASE

 RETURN .T.
ENDPROC
*