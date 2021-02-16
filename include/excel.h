*** Excel.h ***

* xlBordersIndex
#DEFINE xlDiagonalDown		 5
#DEFINE xlDiagonalUp		 6
#DEFINE xlEdgeBottom		 9
#DEFINE xlEdgeLeft			 7
#DEFINE xlEdgeRight			10
#DEFINE xlEdgeTop			 8
#DEFINE xlInsideHorizontal	12
#DEFINE xlInsideVertical		11

* xlLineStyle
#DEFINE xlContinuous		 1
#DEFINE xlDash			  -4115
#DEFINE xlDashDot			 4
#DEFINE xlDashDotDot		 5 
#DEFINE xlDot			  -4118 
#DEFINE xlDouble		  -4119 
#DEFINE xlLineStyleNone	  -4142 
#DEFINE xlSlantDashDot		13 

* xlHAlign
#DEFINE xlHAlignCenter			 -4108 
#DEFINE xlHAlignCenterAcrossSelection	7 
#DEFINE xlHAlignDistributed		 -4117 
#DEFINE xlHAlignFill				5 
#DEFINE xlHAlignGeneral				1 
#DEFINE xlHAlignJustify			 -4130 
#DEFINE xlHAlignLeft			 -4131 
#DEFINE xlHAlignRight			 -4152 

* xlVAlign
#DEFINE xlVAlignBottom		-4107 
#DEFINE xlVAlignCenter		-4108 
#DEFINE xlVAlignDistributed	-4117 
#DEFINE xlVAlignJustify		-4130 
#DEFINE xlVAlignTop			-4160 

* xlPapersize
#DEFINE xlPaper10x14			16 
#DEFINE xlPaper11x17			17 
#DEFINE xlPaperA3				 8 
#DEFINE xlPaperA4				 9 
#DEFINE xlPaperA4Small			10 
#DEFINE xlPaperA5				11 
#DEFINE xlPaperB4				12 
#DEFINE xlPaperB5				13 
#DEFINE xlPaperCsheet			24 
#DEFINE xlPaperDsheet			25 
#DEFINE xlPaperEnvelope10		20 
#DEFINE xlPaperEnvelope11		21 
#DEFINE xlPaperEnvelope12		22 
#DEFINE xlPaperEnvelope14		23 
#DEFINE xlPaperEnvelope9			19 
#DEFINE xlPaperEnvelopeB4		33 
#DEFINE xlPaperEnvelopeB5		34 
#DEFINE xlPaperEnvelopeB6		35 
#DEFINE xlPaperEnvelopeC3		29 
#DEFINE xlPaperEnvelopeC4		30 
#DEFINE xlPaperEnvelopeC5		28 
#DEFINE xlPaperEnvelopeC6		31 
#DEFINE xlPaperEnvelopeC65		32 
#DEFINE xlPaperEnvelopeDL		27 
#DEFINE xlPaperEnvelopeItaly		36 
#DEFINE xlPaperEnvelopeMonarch	37 
#DEFINE xlPaperEnvelopePersonal	38 
#DEFINE xlPaperEsheet			26 
#DEFINE xlPaperExecutive			 7 
#DEFINE xlPaperFanfoldLegalGerman	41 
#DEFINE xlPaperFanfoldStdGerman	40 
#DEFINE xlPaperFanfoldUS			39 
#DEFINE xlPaperFolio			14 
#DEFINE xlPaperLedger			 4 
#DEFINE xlPaperLegal			 5 
#DEFINE xlPaperLetter			 1 
#DEFINE xlPaperLetterSmall		 2 
#DEFINE xlPaperNote				18 
#DEFINE xlPaperQuarto			15 
#DEFINE xlPaperStatement			 6 
#DEFINE xlPaperTabloid			 3 
#DEFINE xlPaperUser			    256 

* XlFileFormat
#DEFINE xlAddIn					18	&& Microsoft Excel 97-2003 Add-In
#DEFINE xlAddIn8					18	&& Microsoft Excel 97-2003 Add-In
#DEFINE xlCSV						 6	&& CSV
#DEFINE xlCSVMac					22	&& Macintosh CSV
#DEFINE xlCSVMSDOS					24	&& MSDOS CSV
#DEFINE xlCSVWindows				23	&& Windows CSV
#DEFINE xlCurrentPlatformText		  -4158	&& Current Platform Text
#DEFINE xlDBF2						 7	&& DBF2
#DEFINE xlDBF3						 8	&& DBF3
#DEFINE xlDBF4						11	&& DBF4
#DEFINE xlDIF						 9	&& DIF
#DEFINE xlExcel12					50	&& Excel12
#DEFINE xlExcel2					16	&& Excel2
#DEFINE xlExcel2FarEast				27	&& Excel2 FarEast
#DEFINE xlExcel3					29	&& Excel3
#DEFINE xlExcel4					33	&& Excel4
#DEFINE xlExcel4Workbook				35	&& Excel4 Workbook
#DEFINE xlExcel5					39	&& Excel5
#DEFINE xlExcel7					39	&& Excel7
#DEFINE xlExcel8					56	&& Excel8
#DEFINE xlExcel9795					43	&& Excel9795
#DEFINE xlHtml						44	&& HTML format
#DEFINE xlIntlAddIn					26	&& International Add-In
#DEFINE xlIntlMacro					25	&& International Macro
#DEFINE xlOpenDocumentSpreadsheet		60	&& OpenDocument Spreadsheet
#DEFINE xlOpenXMLAddIn				55	&& Open XML Add-In
#DEFINE xlOpenXMLTemplate			54	&& Open XML Template
#DEFINE xlOpenXMLTemplateMacroEnabled	53	&& Open XML Template Macro Enabled
#DEFINE xlOpenXMLWorkbook			51	&& Open XML Workbook
#DEFINE xlOpenXMLWorkbookMacroEnabled	52	&& Open XML Workbook Macro Enabled
#DEFINE xlSYLK						 2	&& SYLK
#DEFINE xlTemplate					17	&& Template
#DEFINE xlTemplate8					17	&& Template 8
#DEFINE xlTextMac					19	&& Macintosh Text
#DEFINE xlTextMSDOS					21	&& MSDOS Text
#DEFINE xlTextPrinter				36	&& Printer Text
#DEFINE xlTextWindows				20	&& Windows Text
#DEFINE xlUnicodeText				42	&& Unicode Text
#DEFINE xlWebArchive				45	&& Web Archive
#DEFINE xlWJ2WD1					14	&& WJ2WD1
#DEFINE xlWJ3						40	&& WJ3
#DEFINE xlWJ3FJ3					41	&& WJ3FJ3
#DEFINE xlWK1						 5	&& WK1
#DEFINE xlWK1ALL					31	&& WK1ALL
#DEFINE xlWK1FMT					30	&& WK1FMT
#DEFINE xlWK3						15	&& WK3
#DEFINE xlWK3FM3					32	&& WK3FM3
#DEFINE xlWK4						38	&& WK4
#DEFINE xlWKS						 4	&& Worksheet
#DEFINE xlWorkbookDefault			51	&& Workbook default
#DEFINE xlWorkbookNormal			  -4143	&& Workbook normal
#DEFINE xlWorks2FarEast				28	&& Works2 FarEast
#DEFINE xlWQ1						34	&& WQ1
#DEFINE xlXMLSpreadsheet				46	&& XML Spreadsheet