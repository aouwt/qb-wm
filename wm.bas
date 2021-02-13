'$INCLUDE: './global.bh'

Dim temp As winType
Dim win_Log As Integer
Dim win_Img As Integer
Dim win_Cat As Integer, win_Cat_Text As String

temp = __template_Win
temp.IH = NewImage(320, 240, 32)
temp.T = "Log"
win_Log = newWin(temp)

temp = __template_Win
temp.X = 200
temp.IH = NewImage(320, 240, 32)
temp.T = "Text editor"
win_Cat = newWin(temp)

temp = __template_Win
temp.X = 100
temp.IH = LoadImage("images/image.jpg", 32)
temp.T = "Test"
win_Img = newWin(temp)

__focusedWindow = win_Log


Dim win As Integer
Do
    For win = LBound(w) To UBound(w)
        If w(win).IH = 0 Then Continue
        Select Case win
            Case win_Log 'Log window
                logp "" 'Empty input just refreshes the window




            Case win_Img 'The image window doesn't change, so we dont need to do anything.



            Case win_Cat 'Text editor window
                Select Case __InKey '__INKEY is updated when upd is called.
                    Case Chr$(8) 'backspace
                    Case Else: win_Cat_Text = win_Cat_Text + __InKey 'Append keypress to window
                End Select

                If (w(win).W > 8) And (w(win).H > 8) Then
                    FreeImage w(win).IH 'Resize the window. Not required every frame, but it should be fine.
                    w(win).IH = NewImage(w(win).W, w(win).H, 32)
                End If

                Dest w(win_Cat).IH
                Print win_Cat_Text;



                'Case Else 'Other window
                '    If (w(win).W > 8) And (w(win).H > 8) Then 'Resize it. Again, not needed every frame, but it should be fine.
                '        FreeImage w(win).IH
                '        w(win).IH = NewImage(w(win).W, w(win).H, 32)
                '    End If

                '    Window contents
                '    Dest w(win).IH
                '    Print "X:"; w(win).X, "Y:"; w(win).Y
                '    Print "W:"; w(win).W, "H:"; w(win).H
                '    Print "T:"; w(win).T
                '    Print "IH:"; w(win).IH
                '    Print "F:"; w(win).Z, "win:"; win

                '    Window title
                '    w(win).T = "Window " + LTrim$(Str$(win)) + " (" + LTrim$(Str$(w(win).X)) + "," + LTrim$(Str$(w(win).Y)) + ")-(" + LTrim$(Str$(w(win).W + w(win).X)) + "," + LTrim$(Str$(w(win).H + w(win).Y)) + ")"
        End Select
    Next
    upd
    Limit 30
Loop











Sub putWin (w As winType)
    If w.IH = 0 Then Exit Sub 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!

    If w.Z = 0 Then

        Line (w.X, w.Y)-Step(w.W + 2, w.H + 18), RGBA32(0, 0, 0, 200), BF 'If the window is focused, we make a darker backing
    Else Line (w.X, w.Y)-Step(w.W + 2, w.H + 18), RGBA32(0, 0, 0, 64), BF 'If it doesn't, we use a lighter backing

    End If


    Color RGBA32(255, 255, 255, 255), RGBA32(0, 0, 0, 16) ' Make the title transparent
    PrintString ((w.W - PrintWidth(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

    PutImage (w.X + 1, w.Y + 17)-Step(w.W, w.H), w.IH, , , Smooth ' Put the contents of the window down

    Rem If w.Z = 0 Then Line (w.X + 1, w.Y + 17)-Step(w.W, w.H), RGBA32(0, 0, 0, 127), BF 'Overlay. Disabled for now due to speed.
End Sub





Sub upd Static
    Shared w() As winType
    Shared __image_Background As Long
    Shared __image_Screen As Long
    Shared winZOrder() As Byte

    __InKey$ = InKey$
    Dest Display 'Make sure we're writing to the screen!

    If (Resize) Then 'If the program window is resizing.
        Screen 0 ' It is highy reccomended to free the screen's image handle from the screen before freeing the image itself.
        FreeImage __image_Screen
        __image_Screen = NewImage(ResizeWidth, ResizeHeight, 32) 'Create the new image...
        Screen __image_Screen '...and slap it down on the screen!
    End If


    PutImage , __image_Background 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)
    PrintString (0, 0), "FPS:" + Str$(fps) 'the fps function is fps the amount of times it's called in a second.

    Do While MouseInput: updateMouse: Loop
    fixFocusArray

    Dim i As Integer
    For i = LBound(winzorder) To UBound(winzorder)
        If winZOrder(i) <> 0 Then
            putWin w(winZOrder(i))
        End If
    Next

    Display
End Sub







Function newWin% (template As winType)
    Shared w() As winType

    Dim i As Integer
    For i = LBound(w) To UBound(w)

        If (w(i).IH = 0) Then
            newWin% = i
            w(i) = template
            Exit Function
        End If

    Next

    ReDim Preserve w(UBound(w) + 1) As winType
    w(UBound(w)) = template
    newWin% = UBound(w)
End Function






Sub logp (s As String) Static
    Shared w() As winType
    Shared win_Log As Integer

    Dim i As Long, l As String
    i = Dest

    If s <> "" Then l = l + s + Chr$(13)

    FreeImage w(win_Log).IH
    w(win_Log).IH = NewImage(w(win_Log).W, w(win_Log).H, 32)
    Dest w(win_Log).IH

    Print l;

    Dest i 'Restore the DEST IMAGE
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

    If w(hdl).IH = 0 Then logp "ERR> freeWin: Window " + LTrim$(Str$(hdl)) + " doesn't exist": Exit Sub
    FreeImage w(hdl).IH
    w(hdl).IH = 0
End Sub




Sub updateMouse Static
    Shared w() As winType


    Dim optMenu As Integer, optWin As Integer
    Dim mLockX As Single, mLockY As Single 'Or as I like to call it, mmmlocks and mmmlockie

    Dim i As Integer
    For i = LBound(w) To UBound(w)
        If w(i).T = "" Then Continue
        If (MouseX >= w(i).X) And (MouseY <= (w(i).X + w(i).W)) _
       And (MouseY >= w(i).Y) And (MouseY <= (w(i).Y + 18)) Then ' If mouse is over titlebar


            If MouseButton(1) And (__InKey$ = " ") Then 'Open options (Middle click)
                If optMenu = 0 Then
                    __template_WinOptions.IH = CopyImage(__template_WinOptions.IH, 32) 'So that when we inevitably freeWin the option menu, we dont erase the template's image
                    __template_WinOptions.X = w(i).X
                    __template_WinOptions.Y = w(i).Y
                    optMenu = newWin(__template_WinOptions)
                    __focusedWindow = optMenu
                    optWin = i
                End If

            ElseIf MouseButton(1) Or MouseButton(2) Then __focusedWindow = i
            End If

        End If
    Next

    If (optMenu <> 0) And (__InKey$ <> " ") Then
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

    If MouseButton(1) Then 'Move (Left click)
        w(__focusedWindow).X = w(__focusedWindow).X + (MouseX - mLockX)
        w(__focusedWindow).Y = w(__focusedWindow).Y + (MouseY - mLockY)

    ElseIf MouseButton(2) Then 'Resize (Right click)
        w(__focusedWindow).W = w(__focusedWindow).W + (MouseX - mLockX)
        w(__focusedWindow).H = w(__focusedWindow).H + (MouseY - mLockY)

    End If

    mLockX = MouseX
    mLockY = MouseY
End Sub





Sub fixFocusArray
    Shared winZOrder() As Byte
    Shared w() As winType


    ReDim winZOrder(0 To 255) As Byte 'Since we're not using PRESERVE, it erases the contents of winZOrder as well

    Dim i As Integer
    For i = LBound(w) To UBound(w)
        If w(i).T = "" Then winZOrder(0) = i
    Next

    For i = LBound(w) To UBound(w)
        Do While ((w(i).Z = __focusedWindow) And (i <> __focusedWindow)) Or (winZOrder(w(i).Z) <> 0)
            w(i).Z = w(i).Z + 1
        Loop
        winZOrder(w(i).Z) = i
    Next
End Sub


Function mouseIsOver` (win As Integer)
    Shared w() As winType
    mouseIsOver` = ((MouseX >= w(win).X) And (MouseX <= (w(win).X + w(win).W)) And (MouseY >= w(win).Y) And (MouseY <= (w(win).Y + w(win).H)))
End Function
