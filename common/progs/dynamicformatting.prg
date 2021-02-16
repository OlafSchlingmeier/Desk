*
DEFINE CLASS EffectsListener AS _ReportListener OF common\ffc\_ReportListener.vcx
* Define a class that knows how to apply effects to objects in a report.
	oEffectHandlers = .NULL.	&& a collection of effect handlers
	DIMENSION aRecords[1]	&& an array of information for each record in the FRX

	FUNCTION Init
	* Create a collection of effect handler objects and fill it with the handlers
	* we know about. A subclass or instance could be filled with additional ones.
		DODEFAULT()
		this.oEffectHandlers = CREATEOBJECT('Collection')
		this.oEffectHandlers.Add(CREATEOBJECT('DynamicForeColorEffect'))
		this.oEffectHandlers.Add(CREATEOBJECT('DynamicBackColorEffect'))
		this.oEffectHandlers.Add(CREATEOBJECT('DynamicFontEffect'))
		this.oEffectHandlers.Add(CREATEOBJECT('DynamicStyleEffect'))
	ENDFUNC

	FUNCTION BeforeReport
	* Dimension aRecords to as many records as there are in the FRX so we don't
	* have to redimension it as the report runs. The first column indicates if
	* we've processed that record in the FRX yet and the second column contains
	* a collection of effect handlers used to process the record.
		DODEFAULT()
		this.SetFRXDataSession()
		DIMENSION this.aRecords[RECCOUNT(), 2]
		this.ResetDataSession()
	ENDFUNC

*		PROCEDURE AdjustObjectSize(tnFRXRecno, toObjProperties)
*			LOCAL loObject

*			* If we haven't already checked if this object is a column chart,
*			* find its record in the FRX and see if its USER memo contains
*			* "COLUMNCHART". Then flag that we have checked it so we don't do
*			* it again.
*			IF NOT this.aRecords[tnFRXRecno, 1]
*				loObject = this.GetReportObject(tnFRXRecno)
*				this.aRecords[tnFRXRecno, 1] = .T.
*				this.aRecords[tnFRXRecno, 2] = ATC('COLUMNCHART',loObject.User) > 0
*			ENDIF

*			* If this is supposed to be a column chart, make its width the same
*			* as its height.
*			IF this.aRecords[tnFRXRecno, 2]
*				toObjProperties.Height = toObjProperties.Width
*				toObjProperties.Reload = .T.
*			ENDIF
*		ENDPROC

	FUNCTION EvaluateContents(tnFRXRecno, toObjProperties)
	* Apply any effects that were requested to the field about to be rendered.
		LOCAL loEffectObject, loEffectHandler, lcExpression

		* If we haven't already checked if this field needs any effects, do so and
		* flag that we have checked it so we don't do it again.
		IF NOT this.aRecords[tnFRXRecno, 1]
			this.aRecords[tnFRXRecno, 1] = .T.
			this.aRecords[tnFRXRecno, 2] = this.SetupEffectsForObject(tnFRXRecno)
		ENDIF

		* Go through the collection of effect handlers for the field (the collection
		* may be empty if the field doesn't need any effects), letting each one do its
		* thing.
		FOR EACH loEffectObject IN this.aRecords[tnFRXRecno, 2]
			loEffectHandler = loEffectObject.oEffectHandler
			lcExpression    = loEffectObject.cExpression
			loEffectHandler.Execute(toObjProperties, lcExpression)
		NEXT

		DODEFAULT(tnFRXRecno, toObjProperties)	&&Do the normal behavior.
	ENDFUNC

	FUNCTION SetupEffectsForObject(tnFRXRecno)
	* Go through each effect handler to see if it'll handle the current report
	* object. If so, add it to a collection of handlers for the object, and return
	* that collection.
		LOCAL loFRX, loHandlers, loObject

		loFRX      = this.GetReportObject(tnFRXRecno)
		loHandlers = CREATEOBJECT('Collection')
		FOR EACH loEffectHandler IN this.oEffectHandlers
			loObject = loEffectHandler.GetEffect(loFRX)
			IF VARTYPE(loObject) = 'O'
				loHandlers.Add(loObject)
			ENDIF
		NEXT

		RETURN loHandlers
	ENDFUNC

	PROCEDURE GetReportObject(tnFRXRecno)
	* Return a SCATTER NAME object for the specified record in the FRX.
		LOCAL loObject

		this.SetFRXDataSession()
		GO tnFRXRecno
		SCATTER MEMO NAME loObject
		this.ResetDataSession()

		RETURN loObject
	ENDPROC
ENDDEFINE
*
DEFINE CLASS EffectObject AS Custom
	* Create a class that holds a reference to an effect handler and the expression
	* the effect handler is supposed to act on for a particular record in the FRX.
	oEffectHandler = .NULL.
	cExpression    = ''
ENDDEFINE
*
DEFINE CLASS EffectHandler AS Custom
	* Define an abstract class for effect handler objects.

	FUNCTION Execute(toObjProperties, tcExpression)
	* Execute is called by the EvaluateContents method of EffectsListener to
	* perform an effect.
	ENDFUNC

	FUNCTION GetEffect(toFRX)
	* GetEffects is called to return an object containing a reference to the
	* handler and the expression it's supposed to work on if the specified report
	* object needs this effect, or return null if not.
		RETURN .NULL.
	ENDFUNC

	FUNCTION EvaluateExpression(tcExpression)
	* EvaluateExpression may be called by Execute to evaluate the specified
	* expression.
		RETURN EVALUATE(tcExpression)
	ENDFUNC
ENDDEFINE
*
DEFINE CLASS UserEffectHandler AS EffectHandler
	* Define an abstract class for effect handlers that look for
	* "*:EFFECTS <effectname> = <effectexpression>" in the USER memo.
	cEffectsDirective = '*:EFFECTS'		&& the directive that indicates an effect is needed
	cEffectName       = ''				&& the effect name to look for (filled in in a subclass)

	FUNCTION GetEffect(toFRX)
		LOCAL lcEffect, loObject

		lcEffect = this.cEffectsDirective + ' ' + this.cEffectName
		IF ATC(lcEffect, toFRX.User) > 0
			loObject = CREATEOBJECT('EffectObject')
			loObject.oEffectHandler = this
			loObject.cExpression = STREXTRACT(toFRX.User, lcEffect + ' = ', CHR(13), 1, 3)
		ELSE
			loObject = .NULL.
		ENDIF

		RETURN loObject
	ENDFUNC
ENDDEFINE
*
DEFINE CLASS DynamicForeColorEffect AS UserEffectHandler
	* Define a class to provide dynamic forecolor effects.
	cEffectName = 'FORECOLOR'

	FUNCTION Execute(toObjProperties, tcExpression)
	* Evaluate the expression. If the result is a numeric value and doesn't match
	* the existing color of the object, change the object's color and set the
	* Reload flag to .T.
		LOCAL lnColor, lnPenRed, lnPenGreen, lnPenBlue

		lnColor = this.EvaluateExpression(tcExpression)
		IF VARTYPE(lnColor) = 'N'
			lnPenRed   = BITAND(lnColor, 0x0000FF)
			lnPenGreen = BITRSHIFT(BITAND(lnColor, 0x00FF00),  8)
			lnPenBlue  = BITRSHIFT(BITAND(lnColor, 0xFF0000), 16)
			IF toObjProperties.PenRed <> lnPenRed OR toObjProperties.PenGreen <> lnPenGreen OR toObjProperties.PenBlue <> lnPenBlue
				toObjProperties.PenRed   = lnPenRed
				toObjProperties.PenGreen = lnPenGreen
				toObjProperties.PenBlue  = lnPenBlue
				toObjProperties.Reload   = .T.
			ENDIF
		ENDIF
	ENDFUNC
ENDDEFINE
*
DEFINE CLASS DynamicBackColorEffect AS UserEffectHandler
* Define a class to provide dynamic backcolor effects.
	cEffectName = 'BACKCOLOR'

	FUNCTION Execute(toObjProperties, tcExpression)
	* Evaluate the expression. If the result is a numeric value and doesn't match
	* the existing color of the object, change the object's color and set the
	* Reload flag to .T.
		LOCAL lnColor, lnFillRed, lnFillGreen, lnFillBlue

		lnColor = this.EvaluateExpression(tcExpression)
		IF VARTYPE(lnColor) = 'N'
			lnFillRed   = BITAND(lnColor, 0x0000FF)
			lnFillGreen = BITRSHIFT(BITAND(lnColor, 0x00FF00),  8)
			lnFillBlue  = BITRSHIFT(BITAND(lnColor, 0xFF0000), 16)
			IF toObjProperties.FillRed <> lnFillRed OR toObjProperties.FillGreen <> lnFillGreen OR toObjProperties.FillBlue <> lnFillBlue
				toObjProperties.FillRed   = lnFillRed
				toObjProperties.FillGreen = lnFillGreen
				toObjProperties.FillBlue  = lnFillBlue
				toObjProperties.Reload    = .T.
			ENDIF
		ENDIF
	ENDFUNC
ENDDEFINE
*
DEFINE CLASS DynamicFontEffect AS UserEffectHandler
* Define a class to provide dynamic font effects.
	cEffectName = 'FONT'

	FUNCTION Execute(toObjProperties, tcExpression)
	* Evaluate the expression. If the result is a character value and doesn't match
	* the existing font of the object, change the object's font and set the
	* Reload flag to .T.
		LOCAL lcFont, lcFontStyle, lcFontName, lnFontStyle, lnFontSize

		lcFont = this.EvaluateExpression(tcExpression)
		IF VARTYPE(lcFont) = 'C'
			lcFontName  = ALLTRIM(GETWORDNUM(lcFont,1,','))
			lnFontSize  = INT(VAL(GETWORDNUM(lcFont,2,',')))
			lcFontStyle = ALLTRIM(GETWORDNUM(lcFont,3,','))
			lnFontStyle = IIF(lcFontStyle=='BI',3,IIF(lcFontStyle=='I',2,IIF(lcFontStyle=='B',1,0)))
			IF toObjProperties.FontName <> lcFontName OR toObjProperties.FontSize <> lnFontSize OR toObjProperties.FontStyle <> lnFontStyle
				toObjProperties.FontName  = lcFontName
				toObjProperties.FontSize  = lnFontSize
				toObjProperties.FontStyle = lnFontStyle
				toObjProperties.Reload    = .T.
			ENDIF
		ENDIF
	ENDFUNC
ENDDEFINE
*
DEFINE CLASS DynamicStyleEffect AS UserEffectHandler
* Define a class to provide dynamic style effects.
	cEffectName = 'STYLE'

	FUNCTION Execute(toObjProperties, tcExpression)
	* Evaluate the expression. If the result is a numeric value and doesn't match
	* the existing style of the object, change the object's style and set the
	* Reload flag to .T.
		LOCAL lnStyle

		lnStyle = this.EvaluateExpression(tcExpression)
		IF VARTYPE(lnStyle) = 'N' AND toObjProperties.FontStyle <> lnStyle
			toObjProperties.FontStyle = lnStyle
			toObjProperties.Reload    = .T.
		ENDIF
	ENDFUNC
ENDDEFINE