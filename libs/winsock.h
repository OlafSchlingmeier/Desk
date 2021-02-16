#DEFINE crlf CHR(13)+CHR(10)
#DEFINE oneblock 1024
#DEFINE nSleepMilliSeconds 500	&& 1/2 second

#DEFINE sckClosed 0
#DEFINE sckOpen 1
#DEFINE sckListening 2
#DEFINE sckConnectionPending 3
#DEFINE sckResolvingHost 4
#DEFINE sckResolved 5
#DEFINE sckConnecting 6
#DEFINE sckConnected 7
#DEFINE sckClosing 8
#DEFINE sckError 9
#DEFINE strtype 8

#DEFINE Winsock_Connection_Request "ConnectionRequest"
#DEFINE Winsock_Close "Close"

#DEFINE clientmode 1
#DEFINE servermode 2