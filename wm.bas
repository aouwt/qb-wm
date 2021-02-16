'$INCLUDE: './global.bh'

$Let DEBUG = TRUE

Dim temp As winType
Dim win_Log As Integer
Dim win_Img As Integer
Dim win_Cat As Integer, win_Cat_Text As String
Dim otherWin As Integer

temp = __template_Win
temp.X = 50
temp.IH = NewImage(320, 240, 32)
temp.T = "Log"
temp.FH = __font_Mono
win_Log = newWin(temp)

temp = __template_Win
temp.X = 200
temp.IH = NewImage(320, 240, 32)
temp.T = "Text editor"
temp.FH = __font_Sans
win_Cat = newWin(temp)

temp = __template_Win
temp.X = 100
temp.IH = LoadImage("images/image.jpg", 32)
temp.T = "Test"
win_Img = newWin(temp)

logp "INFO> main routine: Ready"
Dim win As Integer
Do
    Do While MouseInput: updateMouse: Loop

    For win = LBound(w) To UBound(w)
        If w(win).IH = 0 Then Continue
        Select Case win


            Case win_Log 'Log window
                If w(win).NeedsRefresh Then logp ""

                If (w(win_Log).Z = 0) And (__inKey = "+") And (otherWin = 0) Then
                    temp = __template_Win
                    temp.IH = NewImage(640, 480, 32)
                    temp.FH = __font_Mono
                    otherWin = newWin(temp)
                End If



            Case win_Img 'The image window doesn't change, so we dont need to do anything.



            Case win_Cat 'Text editor window
                If w(win_Cat).Z = 0 Then

                    Do Until __inKey = ""
                        Select Case __inKey '__inKey is updated when upd is called.
                            Case Chr$(8): win_Cat_Text = Left$(win_Cat_Text, Len(win_Cat_Text) - 1) 'backspace
                            Case Else: win_Cat_Text = win_Cat_Text + __inKey 'Append keypress to window
                        End Select
                        __inKey = InKey$
                    Loop

                    If w(win).NeedsRefresh Then
                        FreeImage w(win).IH 'Resize the window. Not required every frame, but it should be fine.
                        w(win).IH = NewImage(w(win).W, w(win).H, 32)
                        Font w(win).FH, w(win).IH
                    End If

                    Dest w(win_Cat).IH
                    Cls , RGBA32(0, 0, 0, 0)
                    Print win_Cat_Text;
                End If



            Case otherWin 'Other window
                If (w(win).W > 8) And (w(win).H > 8) Then 'Resize it. Again, not needed every frame, but it should be fine.
                    FreeImage w(win).IH
                    w(win).IH = NewImage(w(win).W, w(win).H, 32)
                    Font w(win).FH, w(win).IH
                End If

                'Window contents
                Dest w(win).IH
                Print "X:"; w(win).X, "Y:"; w(win).Y
                Print "Z:"; w(win).Z
                Print "W:"; w(win).W, "H:"; w(win).H
                Print "T:"; w(win).T, "WH:"; win
                Print "IH:"; w(win).IH, "FH:"; w(win).FH

                'Window title
                w(win).T = "Window " + LTrim$(Str$(win)) + " (" + LTrim$(Str$(w(win).X)) + "," + LTrim$(Str$(w(win).Y)) + ")-(" + LTrim$(Str$(w(win).W + w(win).X)) + "," + LTrim$(Str$(w(win).H + w(win).Y)) + ")"
        End Select
    Next
    upd
    Display
    Limit 60
Loop











Sub putWin (w As winType)
    Shared __screenFont As Long

    If w.IH = 0 Then Exit Sub 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!

    If w.Z = 0 Then _
             Line (w.X, w.Y)-Step(w.W + 2, w.H + FontHeight(__screenFont) + 2), RGBA32(0, 0, 0, 200), BF _
        Else Line (w.X, w.Y)-Step(w.W + 2, w.H + FontHeight(__screenFont) + 2), RGBA32(0, 0, 0, 64 ), BF

    Color RGBA32(255, 255, 255, 255), RGBA32(0, 0, 0, 16) ' Make the title transparent
    PrintString ((w.W - PrintWidth(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

    PutImage (w.X + 1, w.Y + FontHeight(__screenFont) + 1)-Step(w.W, w.H), w.IH ' Put the contents of the window down

    Rem If w.Z = 0 Then Line (w.X + 1, w.Y + 17)-Step(w.W, w.H), RGBA32(0, 0, 0, 127), BF 'Overlay. Disabled for now due to speed.
End Sub





Sub upd Static
    Shared w() As winType
    Shared __image_Background As Long
    Shared __image_Screen As Long
    Shared __screenFont As Long
    Shared winZOrder() As Byte

    __inKey$ = InKey$
    Dest Display 'Make sure we're writing to the screen!

    If (Resize) Then 'If the program window is resizing.
        Screen 0 ' It is highy reccomended to free the screen's image handle from the screen before freeing the image itself.
        FreeImage __image_Screen
        __image_Screen = NewImage(ResizeWidth, ResizeHeight, 32) 'Create the new image...
        Screen __image_Screen '...and slap it down on the screen!
        Font __screenFont, Display
    End If


    PutImage , __image_Background 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)
    PrintString (0, 0), "FPS:" + Str$(fps) 'the fps function is fps the amount of times it's called in a second.

    fixFocusArray

    Dim i As Integer
    For i = UBound(winZOrder) To LBound(winZOrder) Step -1
        If winZOrder(i) <> 0 Then
            putWin w(winZOrder(i))
        End If
    Next

End Sub







Function newWin% (template As winType)
    Shared w() As winType

    Dim i As Integer
    For i = LBound(w) To UBound(w)

        If (w(i).IH = 0) Then
            newWin% = i

            $If DEBUG Then
                template.T = template.T + " (" + LTrim$(Str$(i)) + ")"
            $End If

            w(i) = template
            logp "INFO> newWin: Empty slot " + Str$(i) + " now holds window with image handle of " + Str$(w(i).IH)
            Exit Function
        End If

    Next

    ReDim Preserve w(LBound(w) To UBound(w) + 1) As winType

    $If DEBUG Then
        template.T = template.T + " (" + LTrim$(Str$(UBound(w))) + ")"
    $End If

    w(UBound(w)) = template
    newWin% = UBound(w)
    logp "INFO> newWin: Extending w() to " + Str$(i) + " for window with image handle of " + Str$(w(i).IH)
End Function






Sub logp (s As String) Static
    Shared w() As winType
    Shared win_Log As Integer

    Dim i As Long, l As String
    i = Dest

    If s <> "" Then l = l + s + Chr$(13)

    If win_Log Then
        If w(win_Log).IH Then
            FreeImage w(win_Log).IH
            w(win_Log).IH = NewImage(w(win_Log).W, w(win_Log).H, 32)
            Dest w(win_Log).IH
            Font w(win_Log).FH

            Print l;

            Dest i 'Restore the DEST IMAGE
        End If
    End If
End Sub





Function fps% Static
    Dim t As Double
    Dim t2 As Double

    t2 = Timer(0.0001)
    fps = 1 / (t2 - t)
    t = t2
End Function





Sub freeWin (hdl As Integer)
    Shared w() As winType

    If w(hdl).IH = 0 Then logp "ERROR> freeWin: Window " + LTrim$(Str$(hdl)) + " doesn't exist": Exit Sub
    FreeImage w(hdl).IH
    w(hdl).IH = 0
End Sub






Sub updateMouse Static
    Shared w() As winType
    Shared winZOrder() As Byte
    Shared __screenFont As Long


    Dim optMenu As Integer, optWin As Integer
    Dim mLockX As Single, mLockY As Single 'Or as I like to call it, mmmlocks and mmmlockie
    Dim mouseLatch As Bit

    Dim win As Integer, i As Integer
    For win = LBound(winZOrder) To UBound(winZOrder)
        i = winZOrder(win)
        If i = 0 Then Continue
        If w(i).T = "" Then Continue

        If mouseIsOver(i) Then

            If MouseButton(1) And (__inKey$ = " ") Then 'Open options (Middle click)
                If optMenu = 0 Then
                    __template_WinOptions.IH = CopyImage(__template_WinOptions.IH, 32) 'So that when we inevitably freeWin the option menu, we dont erase the template's image
                    __template_WinOptions.X = w(i).X
                    __template_WinOptions.Y = w(i).Y

                    optMenu = newWin(__template_WinOptions)
                    grabFocus optMenu

                    optWin = i
                    mouseLatch = True
                End If

            ElseIf (MouseButton(1) Or MouseButton(2)) And (mouseLatch = False) Then
                grabFocus i
                mouseLatch = True

            ElseIf (__focusedWindow = i) And (Not MouseButton(1)) And (Not MouseButton(2)) Then mouseLatch = False
            End If

            Rem ElseIf (mouseIsOver(i) = false) And (MouseButton(1)) Then __focusedWindow = 0
            Rem ElseIf (mouseIsOver(i)) And (MouseButton(1)) Then grabFocus i
        End If


    Next

    If (optMenu <> 0) And (__inKey$ <> " ") Then
        If MouseButton(1) Then
            If mouseIsOver(optMenu) Then
                freeWin optWin
                freeWin optMenu
                optMenu = 0
            Else
                freeWin optMenu
                optMenu = 0
            End If
        End If
    End If

    If __focusedWindow Then
        If MouseButton(1) Then 'Move (Left click)
            w(__focusedWindow).X = w(__focusedWindow).X + (MouseX - mLockX)
            w(__focusedWindow).Y = w(__focusedWindow).Y + (MouseY - mLockY)

        ElseIf MouseButton(2) Then 'Resize (Right click)
            w(__focusedWindow).W = w(__focusedWindow).W + (MouseX - mLockX)
            w(__focusedWindow).H = w(__focusedWindow).H + (MouseY - mLockY)

        ElseIf (w(__focusedWindow).W <> _Width(w(__focusedWindow).IH)) Or (w(__focusedWindow).H <> _Height(w(__focusedWindow).IH)) Then _
                 w(__focusedWindow).NeedsRefresh = True  _
            Else w(__focusedWindow).NeedsRefresh = False

    End If: End If

    mLockX = MouseX
    mLockY = MouseY
End Sub







Sub fixFocusArray
    Shared winZOrder() As Byte
    Shared w() As winType


    ReDim winZOrder(0 To 255) As Byte 'Since we're not using PRESERVE, it erases the contents of winZOrder as well

    Dim i As Integer
    'For i = LBound(w) To UBound(w)
    '    If w(i).T = "" Then winZOrder(UBound(winZOrder)) = i
    'Next

    For i = UBound(w) To LBound(w) Step -1 'Prioritize newer windows by going backwards
        If i = __focusedWindow Then
            w(i).Z = 0
            winZOrder(0) = i
            Continue
        End If

        Do Until winZOrder(w(i).Z) = 0
            w(i).Z = w(i).Z + 1
        Loop
        winZOrder(w(i).Z) = i
    Next
End Sub





Function mouseIsOver` (win As Integer)
    Shared w() As winType
    mouseIsOver` = ((MouseX >= w(win).X) And (MouseX <= (w(win).X + w(win).W)) And (MouseY >= w(win).Y) And (MouseY <= (w(win).Y + w(win).H)))
End Function






Sub grabFocus (win As Integer)
    Shared w() As winType
    Dim i As Integer
    For i = LBound(w) To UBound(w)

    If i = win Then w(i).Z = 0 _
    Else w(i).Z = w(i).Z + 1

    Next
    __focusedWindow = win
End Sub
