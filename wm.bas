'$INCLUDE:'./global.bh'

DIM temp AS winType


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

    IF (RESIZE) THEN 'If the program window is resizing.
        SCREEN 0 ' It is highy reccomended to free the screen's image handle from the screen before freeing the image itself.
        FREEIMAGE __screeni&
        __screeni& = NEWIMAGE(RESIZEWIDTH, RESIZEHEIGHT, 32) 'Create the new image...
        SCREEN __screeni& '...and slap it down on the screen!
    END IF

    PUTIMAGE , __backgnd& 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)
    PRINTSTRING (0, 0), "FPS:" + STR$(fps) 'the fps function is fps the amount of times it's called in a second.


    FOR i% = LBOUND(w) TO UBOUND(w)
        IF (MOUSEX >= w(i%).x) AND (MOUSEX <= (w(i%).x + w(i%).w)) AND (MOUSEY >= w(i%).y) AND (MOUSEY <= (w(i%).y + 18)) THEN 'if mouse is over titlebar

            IF MOUSEBUTTON(1) THEN 'Left click
                w(i%).x = w(i%).x + mx
                w(i%).y = w(i%).y + my

            ELSEIF MOUSEBUTTON(2) THEN 'Right click
                w(i%).w = w(i%).w + mx
                w(i%).h = w(i%).h + my

            ELSEIF MOUSEBUTTON(3) THEN 'middle
                IF winOptMenu% = 0 THEN
                    winOptMenu% = newWin(__template_WinOptions)
                END IF

            ELSE

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
