*
FUNCTION RsColor
 PARAMETER csTatus
 PRIVATE ccOlor
 ccOlor = "RGB(0, 0, 0, 255, 255, 255)"
 DO CASE
      CASE csTatus='OUT'
           ccOlor = "RGB(255, 255, 255, 0, 0, 0)"
      CASE csTatus='IN'
           ccOlor = "RGB(0,0,0,192,192,0)"
      CASE csTatus='DEF'
           ccOlor = "RGB(255, 255, 255, 192, 0, 0)"
      CASE csTatus='OPT'
           ccOlor = "RGB(0, 0, 0, 0, 192, 192)"
      CASE csTatus='LST'
           ccOlor = "RGB(0, 0, 0, 192, 0, 192)"
      CASE csTatus='ASG'
           ccOlor = "RGB(255, 255, 255, 0, 0, 255)"
      CASE csTatus='6PM'
           ccOlor = "RGB(255, 255, 255, 160, 80, 16)"
      CASE csTatus='TEN'
           ccOlor = "RGB(0, 0, 255, 192, 192, 192)"
      CASE INLIST(csTatus, 'CXL', 'NS')
           ccOlor = "RGB(0,0,0,0, 192, 0)"
 ENDCASE
 RETURN ccOlor
ENDFUNC
*
