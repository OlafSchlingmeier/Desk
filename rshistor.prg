*
FUNCTION RSHistor
 PRIVATE ncHoice
 PRIVATE noLdarea
 ncHoice = 1
 noLdarea = SELECT()
 SELECT reServat
 DEFINE WINDOW whIstory AT 0, 0 SIZE 15, 120 FONT "Arial", 10 NOCLOSE  ;
        NOZOOM TITLE chIldtitle(GetLangText("RESERV2","TW_HISTORY")) + ": " + IIF(EMPTY(Reservat.rs_lname),Reservat.rs_company,Reservat.rs_lname) NOMDI DOUBLE
 MOVE WINDOW whIstory CENTER
 ACTIVATE WINDOW whIstory
 = paNelborder()
 SCATTER MEMO MEMVAR FIELDS rs_changes
 @ 1, 2 EDIT M.rs_changes SIZE WROWS()-2, WCOLS()-20 SCROLL NOMODIFY
 @ 1, WCOLS()-16.5 GET ncHoice STYLE "B" SIZE nbUttonheight, 15 FUNCTION  ;
   "*" PICTURE GetLangText("COMMON","TXT_CLOSE")
 READ MODAL
 RELEASE WINDOW whIstory
 = chIldtitle("")
 SELECT (noLdarea)
 RETURN .F.
ENDFUNC
*
