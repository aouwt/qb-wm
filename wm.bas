$NOPREFIX
$RESIZE:ON
TYPE winType
     ih AS LONG
     t AS STRING
     x AS INTEGER
     y AS INTEGER
     w AS UNSIGNED INTEGER
     h AS UNSIGNED INTEGER
     s AS UNSIGNED BYTE
END TYPE

__backgnd& = _LOADIMAGE("back.png", 32)
'__backgnd& = LOADIMAGE("image2.jpg", 32)
'__backgnd& = NEWIMAGE(1920, 1080, 32)
'PUTIMAGE , i&, __backgnd&
'FREEIMAGE i&
'_FULLSCREEN _STRETCH , _SMOOTH
__screeni& = NEWIMAGE(640, 480, 32)
'__screeni& = NEWIMAGE(120, 60, 32)
SCREEN __screeni&
DEST DISPLAY

'$DYNAMIC

DIM w(0 TO 0) AS winType, temp AS winType, i AS INTEGER
temp.ih = NEWIMAGE(1024, 512, 32)
temp.h = 256
temp.w = 256
temp.s = &B00000001
temp.t = "Log"
i = newWin(temp)
temp.t = "Test"
temp.ih = LOADIMAGE("image2.jpg", 32)
i = newWin(temp)
temp.ih = NEWIMAGE(256, 256, 32)
'temp.ih = NEWIMAGE(256, 256, 32)
'i = newWin(temp)
logp "Started"
DO
     'LIMIT 10
     IF (WIDTH(w(0).ih) <> w(0).w) OR (HEIGHT(w(0).ih) <> w(0).h) THEN logp ""
     upd
     DO WHILE MOUSEINPUT
          IF MOUSEBUTTON(1) THEN
               w(i%).x = w(i%).x + (MOUSEX - mx)
               w(i%).y = w(i%).y + (MOUSEY - my)
          ELSEIF MOUSEBUTTON(2) THEN
               w(i%).w = w(i%).w + (MOUSEX - mx)
               w(i%).h = w(i%).h + (MOUSEY - my)
          END IF
          mx = MOUSEX
          my = MOUSEY
     LOOP

     'PRINTSTRING (0, 0), "win: " + STR$(i)
     'PRINTSTRING (0, 16), "bounds: " + STR$(LBOUND(w)) + " to " + STR$(UBOUND(w))
     'PRINT "hi"
     DISPLAY


     i$ = INKEY$
     'i$ = ""
     IF i$ <> "" THEN
          IF i$ = " " THEN
               temp.ih = NEWIMAGE(640, 480, 32)
               n = newWin(temp)
          END IF
          IF i$ = CHR$(27) THEN
               FREEIMAGE w(i).ih
               w(i).ih = 0
          END IF
          DO: LOOP UNTIL INKEY$ = ""
     END IF

     i = __focusWindow%

     IF (i = 0) OR (i = 1) THEN CONTINUE
     IF w(i).ih = 0 THEN CONTINUE

     IF ((w(i).w <> WIDTH(w(i).ih)) OR (w(i).h <> HEIGHT(w(i).ih))) THEN
          IF (w(i).w > 8) AND (w(i).h > 8) THEN
               FREEIMAGE w(i).ih
               w(i).ih = NEWIMAGE(w(i).w, w(i).h, 32)
          END IF
     END IF

     w(i).t = "Window " + LTRIM$(STR$(i)) + " (" + LTRIM$(STR$(w(i).x)) + "," + LTRIM$(STR$(w(i).y)) + ")-(" + LTRIM$(STR$(w(i).w + w(i).x)) + "," + LTRIM$(STR$(w(i).h + w(i).y)) + ")"

     DEST w(i).ih
     COLOR RGBA32(255, 255, 255, 255), RGBA32(0, 0, 0, 0)
     CLS
     PRINT "x:", w(i).x
     PRINT "y:", w(i).y
     PRINT
     PRINT "w:", w(i).w
     PRINT "h:", w(i).h
     PRINT
     PRINT "t:", w(i).t
     PRINT "ih:", w(i).ih
LOOP



SUB putWin (w AS winType)
     IF (w.ih = 0) OR (w.ih = -1) THEN EXIT SUB

     IF (w.s AND &B00000001) THEN
          'BLEND
          LINE (w.x, w.y)-STEP(w.w + 2, w.h + 18), RGBA32(0, 0, 0, 200), BF
     ELSE
          'DONTBLEND
          LINE (w.x, w.y)-STEP(w.w + 2, w.h + 18), RGBA32(0, 0, 0, 64), BF
     END IF
     LINE (w.x, w.y)-STEP(w.w + 2, w.h + 18), RGBA32(0, 0, 0, 255), B

     COLOR RGBA32(255, 255, 255, 255), RGBA32(0, 0, 0, 16)
     PRINTSTRING ((w.w - PRINTWIDTH(w.t, 0)) / 2 + w.x, w.y + 1), w.t
     PUTIMAGE (w.x + 1, w.y + 17)-STEP(w.w, w.h), w.ih, , , SMOOTH
     'IF (w.s AND &B00000001) = 0 THEN LINE (w.x + 1, w.y + 17)-STEP(w.w, w.h), RGBA32(0, 0, 0, 127), BF
END SUB




SUB upd STATIC
     SHARED w() AS winType, __backgnd&, __screeni&, __focusWindow%
     DEST DISPLAY
     PUTIMAGE , __backgnd&
     IF (RESIZE) THEN
          SCREEN 0
          FREEIMAGE __screeni&
          __screeni& = NEWIMAGE(RESIZEWIDTH, RESIZEHEIGHT, 32)
          SCREEN __screeni&
     END IF
     PRINTSTRING (0, 0), "FPS:" + STR$(fps)

     IF MOUSEBUTTON(1) THEN
          FOR i% = UBOUND(w) TO LBOUND(w) STEP -1
               IF (MOUSEX < (w(i%).w + w(i%).x)) AND (MOUSEX > w(i%).x) AND (MOUSEY < (w(i%).h + w(i%).y)) AND (MOUSEY > w(i%).y) THEN
                    w(i%).s = (w(i%).s OR &B00000001)
                    __focusWindow% = i%

                    FOR i% = i% - 1 TO LBOUND(w) STEP -1
                         w(i%).s = (w(i%).s AND &B11111110)
                    NEXT
                    EXIT FOR
               ELSE w(i%).s = (w(i%).s AND &B11111110)
               END IF
          NEXT
     ELSE
          FOR i% = UBOUND(w) TO LBOUND(w) STEP -1
               IF (w(i%).s AND &B00000001) THEN
                    __focusWindow% = i%
                    FOR i% = i% - 1 TO LBOUND(w) STEP -1
                         w(i%).s = (w(i%).s AND &B11111110)
                    NEXT
                    EXIT FOR
               END IF
          NEXT
     END IF

     FOR i% = LBOUND(w) TO UBOUND(w)
          'IF w(i%).ih = -1 THEN w(i%).ih = NEWIMAGE(256, 256, 32)
          IF w(i%).ih = 0 THEN CONTINUE
          IF w(i%).s AND &B00000001 THEN f% = i% ELSE putWin w(i%) 'if focus bit is set
     NEXT
     IF (w(f%).ih <> 0) AND (w(f%).ih <> -1) THEN putWin w(f%)

END SUB





FUNCTION newWin% (template AS winType) STATIC
     SHARED w() AS winType
     FOR i% = LBOUND(w) TO UBOUND(w)
          IF w(i%).ih = -1 THEN logp "ERROR: Window " + STR$(i%) + " has handle of -1": w(i%).ih = 0
          IF (w(i%).ih = 0) THEN
               newWin% = i%
               w(i%) = template
               EXIT FUNCTION
          END IF
     NEXT
     logp "INFO: Extending window memory for window " + STR$(i%)
     REDIM PRESERVE w(UBOUND(w) + 1) AS winType
     w(UBOUND(w)) = template
     newWin% = UBOUND(w)
END FUNCTION


'SUB logp (s$): PRINT s$: END SUB
SUB logp (s$) STATIC
     SHARED w() AS winType
     i& = DEST
     IF s$ <> "" THEN l$ = l$ + s$ + CHR$(13)
     FREEIMAGE w(0).ih
     w(0).ih = NEWIMAGE(w(0).w, w(0).h, 32)
     DEST w(0).ih
     PRINT l$;
     DEST i&
END SUB

FUNCTION fps% STATIC
     t2# = TIMER(0.0001)
     fps = 1 / (t2# - t#)
     t# = t2#
END FUNCTION
