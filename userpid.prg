*
FUNCTION UserPID
 LOCAL lcAncel
 IF paRam.pa_relogin
      lcAncel = _screen.oGlobal.Reconfirm()
      RETURN  .NOT. lcAncel
 ELSE
      RETURN .T.
 ENDIF
ENDFUNC
*
