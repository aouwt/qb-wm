'$NOPREFIX allows us to use QB64 keywords without the beginning underscore
'eg. We can use UNSIGNED instead of _UNSIGNED
$NOPREFIX
'Allow resizing the window
$RESIZE:ON


TYPE winType 'Window type definition. QB64 is not object-oriented, so we have to use user types instead.

     ih AS LONG ' Image handle. A value of 0 indicates that this is an open window handle.
     t AS STRING ' Title
     x AS INTEGER ' X position. Should be SINGLE but for some reason QB64 doesn't like virginity :(
     y AS INTEGER ' Y position
     w AS UNSIGNED INTEGER ' Width
     h AS UNSIGNED INTEGER ' Height
     f AS UNSIGNED INTEGER ' Focus order. wByFocus(window.f) MUST equal this window's handle.

END TYPE

__backgnd& = _LOADIMAGE("images/back.png", 32) 'Background image.
__screeni& = NEWIMAGE(640, 480, 32) 'SCREEN image on startup. This changes any time the window is resized, but MUST be a valid _NEWIMAGE handle to prevent Illegal Function Call errors
SCREEN __screeni&
DEST DISPLAY

'NOTE TO CONTRIBUTORS: QuickBasic is weird. $DYNAMIC here is technically commented out, but because it's a metacommand, it only works when commented out.
'Luckily, QB64 metacommands don't have this principle.
REM $DYNAMIC  'We need w() and wByFocus() to be resizable so we can hold more windows.

DIM w(0 TO 0) AS winType ' w() stores all window information (see TYPE winType)
DIM wByFocus(0 TO 0) AS INTEGER ' wByFocus() stores each window's handle in the order of their focus.


DIM temp AS winType 'Stores all window data before feeding it into newWin()
temp.ih = NEWIMAGE(1024, 512, 32) 'Log window
temp.h = 256 'Height
temp.w = 256 'Width
temp.f = 1 'No focus
temp.t = "Log"
win.log% = newWin(temp) 'Create the window. Handle is put into win.log%.

temp.t = "Test" 'Image window
temp.ih = LOADIMAGE("images/image.jpg", 32)
win.img% = newWin(temp)

temp.t = "Text editor" 'Text editor window
temp.ih = NEWIMAGE(255, 255, 32)
win.cat% = newWin(temp)



DO
     FOR win% = LBOUND(w) TO UBOUND(w)
          SELECT CASE win%
               CASE win.log%
                    logp ""
               CASE win.img%
               CASE win.cat%
                    DEST w(win.cat%).ih
                    CLS

                    SELECT CASE __INKEY$
                         CASE CHR$(8) 'backspace
                         CASE ELSE
                              win.cat.c$ = win.cat.c$ + __INKEY$
                    END SELECT


          END SELECT
     NEXT

LOOP


'DO
'IF (WIDTH(w(0).ih) <> w(0).w) OR (HEIGHT(w(0).ih) <> w(0).h) THEN logp ""
'upd
'DO WHILE MOUSEINPUT
'     IF MOUSEBUTTON(1) THEN
'          w(i%).x = w(i%).x + (MOUSEX - mx)
'          w(i%).y = w(i%).y + (MOUSEY - my)
'     ELSEIF MOUSEBUTTON(2) THEN
'          w(i%).w = w(i%).w + (MOUSEX - mx)
'          w(i%).h = w(i%).h + (MOUSEY - my)
'     END IF
'     mx = MOUSEX
'     my = MOUSEY
'LOOP

''PRINTSTRING (0, 0), "win: " + STR$(i)
''PRINTSTRING (0, 16), "bounds: " + STR$(LBOUND(w)) + " to " + STR$(UBOUND(w))
''PRINT "hi"
'DISPLAY


'i$ = INKEY$
''i$ = ""
'IF i$ <> "" THEN
'     IF i$ = " " THEN
'          temp.ih = NEWIMAGE(640, 480, 32)
'          n = newWin(temp)
'     END IF
'     IF i$ = CHR$(27) THEN
'          FREEIMAGE w(i).ih
'          w(i).ih = 0
'     END IF
'     DO: LOOP UNTIL INKEY$ = ""
'END IF

'i = __focusWindow%

'IF (i = 0) OR (i = 1) THEN CONTINUE
'IF w(i).ih = 0 THEN CONTINUE

'IF ((w(i).w <> WIDTH(w(i).ih)) OR (w(i).h <> HEIGHT(w(i).ih))) THEN
'     IF (w(i).w > 8) AND (w(i).h > 8) THEN
'          FREEIMAGE w(i).ih
'          w(i).ih = NEWIMAGE(w(i).w, w(i).h, 32)
'     END IF
'END IF

'w(i).t = "Window " + LTRIM$(STR$(i)) + " (" + LTRIM$(STR$(w(i).x)) + "," + LTRIM$(STR$(w(i).y)) + ")-(" + LTRIM$(STR$(w(i).w + w(i).x)) + "," + LTRIM$(STR$(w(i).h + w(i).y)) + ")"

'DEST w(i).ih
'COLOR RGBA32(255, 255, 255, 255), RGBA32(0, 0, 0, 0)
'CLS
'PRINT "x:", w(i).x
'PRINT "y:", w(i).y
'PRINT
'PRINT "w:", w(i).w
'PRINT "h:", w(i).h
'PRINT
'PRINT "t:", w(i).t
'PRINT "ih:", w(i).ih
'LOOP



SUB putWin (w AS winType)
     IF w.ih = 0 THEN EXIT SUB 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!

     IF w.f = 0 THEN

          LINE (w.x, w.y)-STEP(w.w + 2, w.h + 18), RGBA32(0, 0, 0, 200), BF 'If the window is focused, we make a darker backing
     ELSE LINE (w.x, w.y)-STEP(w.w + 2, w.h + 18), RGBA32(0, 0, 0, 64), BF 'If it doesn't, we use a lighter backing

     END IF


     COLOR RGBA32(255, 255, 255, 255), RGBA32(0, 0, 0, 16) ' Make the title transparent
     PRINTSTRING ((w.w - PRINTWIDTH(w.t, 0)) / 2 + w.x, w.y + 1), w.t ' Title

     PUTIMAGE (w.x + 1, w.y + 17)-STEP(w.w, w.h), w.ih, , , SMOOTH ' Put the contents of the window down

     'IF (w.s AND &B00000001) = 0 THEN LINE (w.x + 1, w.y + 17)-STEP(w.w, w.h), RGBA32(0, 0, 0, 127), BF   'Overlay. Disabled for now due to speed.
END SUB




SUB upd STATIC
     SHARED w() AS winType, __backgnd&, __screeni&, __focusWindow%

     DEST DISPLAY 'Make sure we're writing to the screen!

     PUTIMAGE , __backgnd& 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)


     IF (RESIZE) THEN 'If the program window is resizing.
          SCREEN 0 ' It is highy reccomended to free the screen's image handle from the screen before freeing the image itself.
          FREEIMAGE __screeni&
          __screeni& = NEWIMAGE(RESIZEWIDTH, RESIZEHEIGHT, 32) 'Create the new image...
          SCREEN __screeni& '...and slap it down on the screen!
     END IF

     PRINTSTRING (0, 0), "FPS:" + STR$(fps) 'the fps function is fps the amount of times it's called in a second.
     'Or, more accurately, the multiplicative inverse of the amount of time since it was last called


     IF MOUSEBUTTON(1) THEN 'vvvv This REALLY needs rewritten.
          FOR i% = UBOUND(w) TO LBOUND(w) STEP -1
               IF (MOUSEX < (w(i%).w + w(i%).x)) AND (MOUSEX > w(i%).x) AND (MOUSEY < (w(i%).h + w(i%).y)) AND (MOUSEY > w(i%).y) THEN
                    w(i%).f = 0
                    __focusWindow% = i%

                    FOR i% = i% - 1 TO LBOUND(w) STEP -1
                         w(i%).f = 1 'Note to self: add focus layers.
                    NEXT
                    EXIT FOR
               ELSE w(i%).f = 1
               END IF
          NEXT
     ELSE
          FOR i% = UBOUND(w) TO LBOUND(w) STEP -1
               IF w(i%).f = 0 THEN
                    __focusWindow% = i%
                    FOR i% = i% - 1 TO LBOUND(w) STEP -1
                         w(i%).f = 1
                    NEXT
                    EXIT FOR
               END IF
          NEXT
     END IF

     FOR i% = LBOUND(w) TO UBOUND(w) 'Needs rewritten to allow for focus layers.
          'wByFocus() is specifically made for this.

          IF w(i%).ih = 0 THEN CONTINUE 'Skip "free" slots
          IF w(i%).f = 0 THEN f% = i% ELSE putWin w(i%) 'If focus, draw last. Otherwise, draw now.
     NEXT
     IF (w(f%).ih <> 0) AND (w(f%).ih <> -1) THEN putWin w(f%) 'Draw focus last

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

SUB mouse
     SHARED w() AS winType

     FOR i% = UBOUND(w) TO LBOUND(w) STEP -1
          'if w(i%).s
     NEXT
END SUB
