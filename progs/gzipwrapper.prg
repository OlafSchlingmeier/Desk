*****************************************************************
* Quick & Dirty Wrapper Class für FoxCrypto Library
* (C) 08.2002 by wOOdy, ProLib Software GmbH
*****************************************************************

DEFINE CLASS GZipper AS CUSTOM

	PROCEDURE Compress (cString)
		LOCAL lnHandle, lnSize, lcZipped

		lnHandle = GzipCREATE(1)
		IF lnHandle > 0
			GzipPUT(lnHandle, cString)
			GzipCLOSE(lnHandle)
			lnSize   = GzipMaxRetrievable(lnHandle)
			lcZipped = GzipGET(lnHandle, lnSize)
			GzipDestroy(lnHandle)
		ELSE 
			error "Compress instantiation failed"	
		ENDIF

		RETURN lcZipped
	ENDPROC


	PROCEDURE DeCompress (cString)
		LOCAL lnHandle, lnSize, lcZipped

		lnHandle = GUnzipCreate()
		IF lnHandle > 0
			GUnzipPUT(lnHandle,cString)
			GUnzipCLOSE(lnHandle)
			lnSize = GUnzipMaxRetrievable(lnHandle)
			lcZipped = GUnzipGET(lnHandle, lnSize)
			GUnzipDestroy(lnHandle)
		ELSE
			error "Decompress instantiation failed"	
		ENDIF

		RETURN lcZipped
	ENDPROC

	Procedure IsCompressed 
		*====================================================================
		* Author.....: Nina Schwanzer 
		* Date.......: 08/03/04
		*
		* About......: Checks the string if compressed.
		* Parameters.: tcString - string to check
		* Return.....: Logical
		*====================================================================
		LParameters tcString
		Local llCompressed
		
		If Vartype( m.tcString ) == "C" AND NOT Empty( m.tcString ) 
			llCompressed = Left( m.tcString, 3 ) == CHR(31)+CHR(139)+CHR(8)
		EndIf
		
		Return m.llCompressed 
	EndProc
ENDDEFINE
