'$INCLUDE: './global.bh'

DIM temp AS winType
DIM win_Log AS INTEGER
DIM win_Img AS INTEGER
DIM win_Cat AS INTEGER, win_Cat_Text AS STRING

temp = __template_Win
temp.IH = NEWIMAGE(320, 240, 32)
temp.T = "Log"
win_Log = newWin(temp)

temp = __template_Win
temp.IH = NEWIMAGE(320, 240, 32)
temp.T = "Text editor"
win_Cat = newWin(temp)

temp = __template_Win
temp.IH = LOADIMAGE("images/image.jpg", 32)
temp.T = "Test"
win_Img = newWin(temp)


DIM win AS INTEGER
DO
    FOR win = LBOUND(w) TO UBOUND(w)
        SELECT CASE win
            CASE win_Log 'Log window
                logp "" 'Empty input just refreshes the window




            CASE win_Img 'The image window doesn't change, so we dont need to do anything.



            CASE win_Cat 'Text editor window
                SELECT CASE __INKEY '__INKEY is updated when upd is called.
                    CASE CHR$(8) 'backspace
                    CASE ELSE: win_Cat_Text = win_Cat_Text + __INKEY 'Append keypress to window
                END SELECT

                IF (w(win).W > 8) AND (w(win).H > 8) THEN
                    FREEIMAGE w(win).IH 'Resize the window. Not required every frame, but it should be fine.
                    w(win).IH = NEWIMAGE(w(win).W, w(win).H, 32)
                END IF

                DEST w(win_Cat).IH
                PRINT win_Cat_Text;



            CASE ELSE 'Other window
                IF (w(win).W > 8) AND (w(win).H > 8) THEN 'Resize it. Again, not needed every frame, but it should be fine.
                    FREEIMAGE w(win).IH
                    w(win).IH = NEWIMAGE(w(win).W, w(win).H, 32)
                END IF

                'Window contents
                DEST w(win).IH
                PRINT "X:"; w(win).X, "Y:"; w(win).Y
                PRINT "W:"; w(win).W, "H:"; w(win).H
                PRINT "T:"; w(win).T
                PRINT "IH:"; w(win).IH
                PRINT "F:"; w(win).F, "win:"; win

                'Window title
                w(win).T = "Window " + LTRIM$(STR$(win)) + " (" + LTRIM$(STR$(w(win).X)) + "," + LTRIM$(STR$(w(win).Y)) + ")-(" + LTRIM$(STR$(w(win).W + w(win).X)) + "," + LTRIM$(STR$(w(win).H + w(win).Y)) + ")"
        END SELECT
    NEXT
    win = MOUSEINPUT
    upd
LOOP











SUB putWin (w AS winType)
    IF w.IH = 0 THEN EXIT SUB 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!

    IF w.F = 0 THEN

        LINE (w.X, w.Y)-STEP(w.W + 2, w.H + 18), RGBA32(0, 0, 0, 200), BF 'If the window is focused, we make a darker backing
    ELSE LINE (w.X, w.Y)-STEP(w.W + 2, w.H + 18), RGBA32(0, 0, 0, 64), BF 'If it doesn't, we use a lighter backing

    END IF


    COLOR RGBA32(255, 255, 255, 255), RGBA32(0, 0, 0, 16) ' Make the title transparent
    PRINTSTRING ((w.W - PRINTWIDTH(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

    PUTIMAGE (w.X + 1, w.Y + 17)-STEP(w.W, w.H), w.IH, , , SMOOTH ' Put the contents of the window down

    REM IF (w.s AND &B00000001) = 0 THEN LINE (w.x + 1, w.y + 17)-STEP(w.w, w.h), RGBA32(0, 0, 0, 127), BF   'Overlay. Disabled for now due to speed.
END SUB





SUB upd STATIC
    SHARED w() AS winType, __image_Background AS LONG, __image_Screen AS LONG

    DEST DISPLAY 'Make sure we're writing to the screen!

    IF (RESIZE) THEN 'If the program window is resizing.
        SCREEN 0 ' It is highy reccomended to free the screen's image handle from the screen before freeing the image itself.
        FREEIMAGE __image_Screen
        __image_Screen = NEWIMAGE(RESIZEWIDTH, RESIZEHEIGHT, 32) 'Create the new image...
        SCREEN __image_Screen '...and slap it down on the screen!
    END IF


    PUTIMAGE , __image_Background 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)
    PRINTSTRING (0, 0), "FPS:" + STR$(fps) 'the fps function is fps the amount of times it's called in a second.





    DISPLAY
END SUB







FUNCTION newWin% (template AS winType) STATIC
    SHARED w() AS winType

    DIM i AS INTEGER
    FOR i = LBOUND(w) TO UBOUND(w)

        IF (w(i).IH = 0) THEN
            newWin% = i
            w(i) = template
            EXIT FUNCTION
        END IF

    NEXT

    REDIM PRESERVE w(UBOUND(w) + 1) AS winType
    w(UBOUND(w)) = template
    newWin% = UBOUND(w)
END FUNCTION






SUB logp (s AS STRING) STATIC
    SHARED w() AS winType, win_Log AS INTEGER

    DIM i AS LONG, l AS STRING
    i = DEST

    IF s <> "" THEN l = l + s + CHR$(13)

    FREEIMAGE w(win_Log).IH
    w(win_Log).IH = NEWIMAGE(w(win_Log).W, w(win_Log).H, 32)
    DEST w(win_Log).IH

    PRINT l;

    DEST i 'Restore the DEST IMAGE
END SUB






FUNCTION fps% STATIC
    DIM t AS DOUBLE, t2 AS DOUBLE
    t2 = TIMER(0.0001)
    fps = 1 / (t2 - t)
    t = t2
END FUNCTION





SUB freeWin (hdl AS INTEGER)
    SHARED w() AS winType
    IF w(hdl).IH = 0 THEN logp "ERR> freeWin: Window " + LTRIM$(STR$(hdl)) + " doesn't exist": EXIT SUB
    FREEIMAGE w(hdl).IH
    w(hdl).IH = 0
END SUB




SUB updateMouse STATIC
    SHARED w() AS winType


    DIM optMenu AS INTEGER, optWin AS INTEGER
    DIM mLockX AS SINGLE, mLockY AS SINGLE 'Or as I like to call it, mmmlocks and mmmlockie

    DIM i AS INTEGER
    FOR i = LBOUND(w) TO UBOUND(w)

        IF (MOUSEX >= w(i).X) AND (MOUSEX <= (w(i).X + w(i).W)) AND _
           (MOUSEY >= w(i).Y) AND (MOUSEY <= (w(i).Y + 18)) THEN ' If mouse is over titlebar


            IF MOUSEBUTTON(3) THEN 'Open options (Middle click)
                IF optMenu = 0 THEN
                    __template_WinOptions.IH = COPYIMAGE(__template_WinOptions.IH, 32) 'So that when we inevitably freeWin the option menu, we dont erase the template's image
                    optMenu = newWin(__template_WinOptions)
                    optWin = i
                END IF

            ELSEIF MOUSEBUTTON(1) THEN 'Move (Left click)
                w(i).X = w(i).X + (MOUSEX - mLockX)
                w(i).Y = w(i).Y + (MOUSEY - mLockY)

            ELSEIF MOUSEBUTTON(2) THEN 'Resize (Right click)
                w(i).W = w(i).W + (MOUSEX - mLockX)
                w(i).H = w(i).H + (MOUSEY - mLockY)

            END IF


        END IF
    NEXT


END SUB
