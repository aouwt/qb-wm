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
               CASE win.log% 'Log window
                    logp "" 'Empty input just refreshes the window


               CASE win.img% 'The image window doesn't change, so we dont need to do anything.


               CASE win.cat% 'Text editor window

                    SELECT CASE __INKEY$ '__INKEY$ is updated when upd is called.
                         CASE CHR$(8) 'backspace
                         CASE ELSE: win.cat.c$ = win.cat.c$ + __INKEY$ 'Append keypress to window
                    END SELECT

                    IF (w(win%).w > 8) AND (w(win%).h > 8) THEN
                         FREEIMAGE w(win%).ih 'Resize the window. Not required every frame, but it should be fine.
                         w(win%).ih = NEWIMAGE(w(win%).w, w(win%).h, 32)
                    END IF

                    DEST w(win.cat%).ih
                    PRINT win.cat.c$;


               CASE ELSE 'Other window
                    IF (w(win%).w > 8) AND (w(win%).h > 8) THEN 'Resize it. Again, not needed every frame, but it should be fine.
                         FREEIMAGE w(win%).ih
                         w(win%).ih = NEWIMAGE(w(win%).w, w(win%).h, 32)
                    END IF

                    'Window contents
                    DEST w(win%).ih
                    PRINT "X:"; w(win%).x, "Y:"; w(win%).y
                    PRINT "W:"; w(win%).w, "H:"; w(win%).h
                    PRINT "T:"; w(win%).t
                    PRINT "IH:"; w(win%).ih
                    PRINT "F:"; w(win%).f, "hdl:"; win%
                    PRINT "wByFocus:"; wByFocus(w(win%).f)

                    'Window title
                    w(win%).t = "Window " + LTRIM$(STR$(win%)) + " (" + LTRIM$(STR$(w(win%).x)) + "," + LTRIM$(STR$(w(win%).y)) + ")-(" + LTRIM$(STR$(w(win%).w + w(win%).x)) + "," + LTRIM$(STR$(w(i).h + w(i).y)) + ")"
          END SELECT
     NEXT
     upd
LOOP

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

     FOR i% = LBOUND(w) TO UBOUND(w)
          IF (MOUSEX >= w(i%).x) AND (MOUSEX <= (w(i%).x + w(i%).w)) AND (MOUSEY >= w(i%).y) AND (MOUSEY <= (w(i%).y + 18)) THEN 'if mouse is over titlebar
               IF MOUSEBUTTON(1) THEN 'Left click
                    w(i%).x = w(i%).x + mx
                    w(i%).y = w(i%).y + my
               ELSEIF MOUSEBUTTON(2) THEN 'Middle click

               ELSEIF MOUSEBUTTON(3) THEN 'Right click
                    w(i%).w = w(i%).w + mx
                    w(i%).h = w(i%).h + my
               END IF
               my = (MOUSEY - my)
               mx = (MOUSEX - mx)
          END IF
          putWin w(i%)
     NEXT
     DISPLAY
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

