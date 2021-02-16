LPARAMETERS lp_cRateCode, lp_cSeason, lp_cCitexid, lp_cLang, lp_cBookingNumber, lp_dFromdat, lp_dTodat
PRIVATE p_cPROCHRS_Result
LOCAL l_oHTTP, l_oXML, l_oNodes, l_oNode, l_oRoomRates, l_oSeasons, l_oSeason, l_nSeasonId, l_oAddonPrices, ;
      l_nPriceId, l_nPrice, l_nSelect, l_cTitle, l_cSeasonName, l_cSelectedSeasonName, l_nCitexid, l_nSeasonIDFound, l_lFound, ;
      l_cType, l_oAdjustments, l_oAdjustment

l_nSelect = SELECT()

WAIT GetLangText("COMMON","T_PLEASEWAIT") WINDOW NOWAIT

p_cPROCHRS_Result = ""

l_cServer = ReadINI(FULLPATH(_screen.oGlobal.cHotelDir+"citadel.ini"),[agency],[server])
l_cProxy = ReadINI(FULLPATH(_screen.oGlobal.cHotelDir+"citadel.ini"),[agency],[proxy])
l_lExternalClient = IIF(LOWER(ReadINI(FULLPATH(_screen.oGlobal.cHotelDir+"citadel.ini"),[agency],[externalclient]))=="yes",.T.,.F.)

IF EMPTY(lp_cBookingNumber)

     l_cCategoryId = ALLTRIM(dlookup("room","rm_rmname == '" + lp_cRateCode + "'","rm_user8"))

     IF EMPTY(l_cCategoryId)
          alert("Dieser Preiskode ist mit keine HRS Kategorie verbunden!")
          RETURN .T.
     ENDIF

     l_nCitexid = 0
     IF NOT EMPTY(lp_cCitexid)
          l_nCitexid = lp_cCitexid
     ENDIF

ENDIF

IF NOT "foxcrypto.fll" $ LOWER(SET("Library"))
     SET LIBRARY TO "common\dll\foxcrypto.fll" ADDITIVE
ENDIF

l_cURL = "http://" + l_cServer

IF EMPTY(lp_cBookingNumber)
     l_cURL = l_cURL + "/getprices"
ELSE
     l_cURL = l_cURL + "/destinationsolutions"
ENDIF

* http://localhost:29613/getprices?token=f97b4d11-3784-4057-902d-3da683693ce4&categoryid=5387

l_oParams = CREATEOBJECT("Empty")
ADDPROPERTY(l_oParams, "cServer", l_cURL)
ADDPROPERTY(l_oParams, "cProxy", l_cProxy)
ADDPROPERTY(l_oParams, "lUseExternalHTTPClient", l_lExternalClient)
ADDPROPERTY(l_oParams, "cLogFile", "")
ADDPROPERTY(l_oParams, "cContentType", "text/html")
ADDPROPERTY(l_oParams, "lGET", .T.)

l_oHTTP = NEWOBJECT("cHTTPDataSend", "common\progs\vfpajax.prg", "", l_oParams)
IF EMPTY(lp_cBookingNumber)
     l_oXML = l_oHTTP.Send("token=f97b4d11-3784-4057-902d-3da683693ce4&categoryid=" + l_cCategoryId)
     IF ISNULL(l_oXML)
          DO FORM forms\rshistor WITH l_oHTTP.GetError(), GetLangText("RECURRES","TXT_INFORMATION"), .NULL., .T.
          RETURN .F.
     ENDIF
ELSE
     l_oXML = l_oHTTP.Send("reservation=" + lp_cBookingNumber)
ENDIF

IF EMPTY(lp_cBookingNumber)

     CREATE CURSOR caddonty (addon_id i, name c(200))

     l_oAddonTypes = l_oXML.selectNodes("/root/category/roomrate_get_addon_types_rs/addon_type")
     IF NOT ISNULL(l_oAddonTypes)
          FOR EACH l_oAddonType IN l_oAddonTypes
               l_nAddonId = l_oHTTP.GetAttribute("addon_id","I",l_oAddonType)
               l_cAddonName = l_oHTTP.GetNodeText("name","C",l_oAddonType)
               INSERT INTO caddonty (addon_id, name) VALUES (l_nAddonId, l_cAddonName)
               *PHRS_Log("addontype|addon_id: "+TRANSFORM(l_nAddonId)+"|name: "+TRANSFORM(l_cAddonName))
          ENDFOR
     ENDIF

     CREATE CURSOR cseasons (season_id i, name c(200), start d, end d)

     l_oAllSeasons = l_oXML.selectSingleNode("/root/category/season_get_all_rs")
     IF NOT ISNULL(l_oAllSeasons)
          l_oSeasons = l_oAllSeasons.selectNodes("season")
          FOR EACH l_oSeason IN l_oSeasons
               l_nSeasonId = l_oHTTP.GetAttribute("season_id","I",l_oSeason)
               l_cSeasonName = UPPER(l_oHTTP.GetNodeText("name","C",l_oSeason))
               l_cSeasonStart = l_oHTTP.GetNodeText("start","C",l_oSeason)
               l_cSeasonEnd = l_oHTTP.GetNodeText("end","C",l_oSeason)
               INSERT INTO cseasons (season_id, name, start, end) VALUES (l_nSeasonId, l_cSeasonName, l_oHTTP.ConvertXMLDateToVFPDate(l_cSeasonStart), l_oHTTP.ConvertXMLDateToVFPDate(l_cSeasonEnd))
               *PHRS_Log("season|season_id: "+TRANSFORM(l_nSeasonId)+"|name: "+TRANSFORM(l_cSeasonName)+"|start: "+TRANSFORM(l_cSeasonStart)+"|end: "+TRANSFORM(l_cSeasonEnd))
          ENDFOR
     ENDIF

     * Find season for selected ratecode

     l_nSeasonIDFound = 0

     IF NOT EMPTY(lp_cSeason)
          l_lFound = .F.
          IF EMPTY(l_nCitexid)
               * Show HRS IDs for newly created ratecode
               SELECT cseasons
               LOCATE FOR start = lp_dFromdat AND end = lp_dTodat - 1
               IF FOUND()
                    l_lFound = .T.
                    l_nSeasonIDFound = season_id
               ENDIF
          ELSE
               l_oRoomRates = l_oXML.selectSingleNode("/root/category/roomrates_get_rs")
               IF NOT ISNULL(l_oRoomRates)
                    l_oSeasons = l_oRoomRates.selectNodes("season")
                    FOR EACH l_oSeason IN l_oSeasons
                         l_nSeasonId = l_oHTTP.GetAttribute("season_id","I",l_oSeason)
                         l_oAccommodationPrices = l_oSeason.selectNodes("accommodations/price")
                         FOR EACH l_oAccommodationPrice IN l_oAccommodationPrices
                              l_nPriceId = l_oHTTP.GetAttribute("price_id","I",l_oAccommodationPrice)
                              IF l_nPriceId = l_nCitexid
                                   l_lFound = .T.
                                   l_nSeasonIDFound = l_nSeasonId
                                   EXIT
                              ENDIF
                         ENDFOR
                         IF l_lFound
                              EXIT
                         ENDIF
                    ENDFOR
               ENDIF
          ENDIF
          IF NOT l_lFound
               alert("Keine Saison in HRS für diesen Preiskode gefudnen!")
               RETURN .T.
          ENDIF
     ENDIF

     l_oRoomRates = l_oXML.selectSingleNode("/root/category/roomrates_get_rs")
     IF NOT ISNULL(l_oRoomRates)
          l_oSeasons = l_oRoomRates.selectNodes("season")
          FOR EACH l_oSeason IN l_oSeasons
               l_nSeasonId = l_oHTTP.GetAttribute("season_id","I",l_oSeason)
               IF l_nSeasonId <> l_nSeasonIDFound
                    LOOP
               ENDIF

               dlocate("cseasons", "season_id = " + TRANSFORM(l_nSeasonId))

               PHRS_Log("seasons")
               PHRS_Log(REPLICATE("-",51))
               PHRS_Log(PADR("season_id",9)+"|"+PADR("name",20) +        "|"+PADR("start",12)+             "|"+PADR("end",12))
               PHRS_Log(PADR(l_nSeasonId,9)+"|"+PADR(ALLTRIM(cseasons.name),20)+"|"+PADR(DTOC(cseasons.start),12)+"|"+PADR(DTOC(cseasons.end),12))
               PHRS_Log("")
               PHRS_Log("accommodation prices")
               PHRS_Log(REPLICATE("-",51))
               PHRS_Log(PADR("price_id",9)+"|"+PADR("price",20))
               l_oAccommodationPrices = l_oSeason.selectNodes("accommodations/price")
               FOR EACH l_oAccommodationPrice IN l_oAccommodationPrices
                    l_nPriceId = l_oHTTP.GetAttribute("price_id","I",l_oAccommodationPrice)
                    l_nPrice = l_oHTTP.GetNodeText("value","B",l_oAccommodationPrice)
                    PHRS_Log(PADR(TRANSFORM(l_nPriceId),9)+"|"+PADR(STR(l_nPrice,15,2),20))
               ENDFOR

               PHRS_Log("")
               PHRS_Log("addon prices")
               PHRS_Log(REPLICATE("-",51))
               PHRS_Log(PADR("price_id",9)+"|"+PADR("price",20)+"|"+PADR("addon_id",12)+"|"+PADR("name",50))
               l_oAddonPrices = l_oSeason.selectNodes("addons/price")
               FOR EACH l_oAddonPrice IN l_oAddonPrices
                    l_nPriceId = l_oHTTP.GetAttribute("price_id","I",l_oAddonPrice)
                    l_nAddonId = l_oHTTP.GetNodeText("addon_id","B",l_oAddonPrice)
                    l_nPrice = l_oHTTP.GetNodeText("value","B",l_oAddonPrice)

                    dlocate("caddonty", "addon_id = " + TRANSFORM(l_nAddonId))
                    PHRS_Log(PADR(TRANSFORM(l_nPriceId),9)+"|"+PADR(STR(l_nPrice,15,2),20)+"|"+PADR(TRANSFORM(l_nAddonId),12)+"|"+PADR(ALLTRIM(caddonty.name),50))
               ENDFOR

               PHRS_Log("")
               PHRS_Log("adjustments")
               PHRS_Log(REPLICATE("-",51))
               PHRS_Log(PADR("price_id",9)+"|"+PADR("price",20)+"|"+PADR("type",50))
               l_oAdjustments = l_oSeason.selectNodes("adjustments/price")
               FOR EACH l_oAdjustment IN l_oAdjustments
                    l_nPriceId = l_oHTTP.GetAttribute("price_id","I",l_oAdjustment)
                    l_cType = l_oHTTP.GetNodeText("type","C",l_oAdjustment)
                    l_nPrice = l_oHTTP.GetNodeText("value","B",l_oAdjustment)

                    PHRS_Log(PADR(TRANSFORM(l_nPriceId),9)+"|"+PADR(STR(l_nPrice,15,2),20)+"|"+PADR(ALLTRIM(l_cType),50))
               ENDFOR

               PHRS_Log("")

          ENDFOR
     ENDIF

     IF EMPTY(p_cPROCHRS_Result)
          p_cPROCHRS_Result = "Season nicht gefunden in HRS!"
     ENDIF

     WAIT CLEAR

     l_cTitle = GetLangText("MGRFINAN","TXT_RCCODE") + ": " + ALLTRIM(lp_cRateCode) + IIF(EMPTY(lp_cSeason), "", " | " + lp_cSeason )+ ;
               " | " + ALLTRIM(lp_cLang) + ;
               " | HRS CategoryId: " + l_cCategoryId

     PHRS_DoForm(l_cTitle)

ELSE
     
ENDIF

SELECT (l_nSelect)

RETURN .T.
ENDPROC
*
PROCEDURE PHRS_Log
LPARAMETERS lp_cEntry
p_cPROCHRS_Result = p_cPROCHRS_Result + lp_cEntry + CHR(13)
ENDPROC
*
PROCEDURE PHRS_DoForm
LPARAMETERS lp_cTitle
LOCAL l_lFound As Form

FOR EACH l_oForm IN _screen.Forms
     IF LOWER(l_oForm.Name) == "rshistor" AND l_oForm.Caption == lp_cTitle
          l_oForm.SetNewData(p_cPROCHRS_Result)
          l_lFound = .T.
          EXIT
     ENDIF
ENDFOR

IF NOT l_lFound
     DO FORM forms\rshistor WITH p_cPROCHRS_Result, ,.NULL. , ,lp_cTitle, "Courier", "bitmap\icons\roomlist.ico", .T., .T.
ENDIF

ENDPROC
*