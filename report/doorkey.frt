   Z   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              %ORIENTATION=0
PAPERSIZE=9
COLOR=2
nt to PDF (redirected 1)
OUTPUT=TS001
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
             P  9  winspool  Microsoft Print to PDF (redirected 1)  TS001                                                                Courier New                                                   TTOC(DATETIME())                                              Arial Narrow                                                  g_hotel                                                       Arial                                                         ""Ihr QR Code f�r Zimmert�rschloss"                            Arial Narrow                                                  p_oQRData.cFile                                               NOT EMPTY(p_oQRData.cFile)                                    dALLTRIM(p_oQRData.cTitle) + " " + ALLTRIM(p_oQRData.cFirstName) + " " + ALLTRIM(p_oQRData.cLastName)                          Arial                                                         ;DTOC(p_oQRData.dArrDate) + " - " + DTOC(p_oQRData.dDepDate)                                                                   Arial                                                         i"Reservierungsnummer: " + IIF(EMPTY(p_oQRData.nReserId),p_oQRData.cReserId,TRANSFORM(p_oQRData.nReserId))                     ""                                                            Arial                                                         "Gast:"                                                       Arial                                                         "Anreise / Abreise:"                                          Arial                                                         ALLTRIM(p_oQRData.cRoom)                                      Arial                                                         	"Zimmer:"                                                     Arial                                                         "URL: " + p_oQRData.cURL                                      Arial                                                         Courier New                                                   Arial Narrow                                                  Arial                                                         Arial Narrow                                                  dataenvironment                                               YTop = 0
Left = 0
Width = 0
Height = 0
DataSource = .NULL.
Name = "Dataenvironment"
                                     �DRIVER=winspool
DEVICE=Microsoft Print to PDF (redirected 1)
OUTPUT=TS001
ORIENTATION=0
PAPERSIZE=9
COPIES=1
DEFAULTSOURCE=15
PRINTQUALITY=600
COLOR=2
YRESOLUTION=600
             P  9  winspool  Microsoft Print to PDF (redirected 1)  TS001                                                                Courier New                                                   TTOC(DATETIME())                                              Arial Narrow                                                  g_hotel                                                       Arial                                                         ""Ihr QR Code f�r Zimmert�rschloss"                            Arial Narrow                                                  p_oQRData.cFile                                               NOT EMPTY(p_oQRData.cFile)                                    dALLTRIM(p_oQRData.cTitle) + " " + ALLTRIM(p_oQRData.cFirstName) + " " + ALLTRIM(p_oQRData.cLastName)                          Arial                                                         ;DTOC(p_oQRData.dArrDate) + " - " + DTOC(p_oQRData.dDepDate)                                                                   Arial                                                         i"Reservierungsnummer: " + IIF(EMPTY(p_oQRData.nReserId),p_oQRData.cReserId,TRANSFORM(p_oQRData.nReserId))                     ""                                                            Arial                                                         "Gast:"                                                       Arial                                                         "Anreise / Abreise:"                                          Arial                                                         ALLTRIM(p_oQRData.cRoom)                                      Arial                                                         	"Zimmer:"                                                     Arial                                                         "URL: " + p_oQRData.cURL                                      Arial                                                         Courier New                                                   Arial Narrow                                                  Arial                                                         Arial Narrow                                                  dataenvironment                                               YTop = 0
Left = 0
Width = 0
Height = 0
DataSource = .NULL.
Name = "Dataenvironment"
                               