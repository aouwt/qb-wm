'$INCLUDE: './global.bh'
$Checking:Off

$Let HW = FALSE
$Let LIGHT = TRUE

Dim temp As winType
Dim win_Log As Integer
Dim win_Img As Integer
Dim win_Cat As Integer, win_Cat_Text As String, win_Img_Image As Long
Dim win_Launcher

win_Img_Image = LoadImage("images/image.jpg", 32)

temp = __template_Win
temp.IH = NewImage(temp.W, temp.H, 32)
temp.T = "Launcher"
win_Launcher = newWin(temp)


logp "INFO> main routine: Ready"
Dim win As Integer
Do
    Do While MouseInput: updateMouse: Loop

    For win = LBound(w) To UBound(w)
        If w(win).IH = 0 Then Continue
        Select Case win


            Case win_Log 'Log window
                If w(win).NeedsRefresh Then resizeWin win_Log: logp ""


            Case win_Img
                If w(win).NeedsRefresh Then
                    resizeWin win_Img
                    PutImage , win_Img_Image, w(win).IH
                End If



            Case win_Cat 'Text editor window
                If w(win_Cat).Z = 0 Then

                    Do Until __inKey = ""
                        Select Case __inKey '__inKey is updated when upd is called.
                            Case Chr$(8): win_Cat_Text = Left$(win_Cat_Text, Len(win_Cat_Text) - 1) 'backspace
                            Case Else: win_Cat_Text = win_Cat_Text + __inKey 'Append keypress to window
                        End Select
                        __inKey = InKey$
                    Loop

                    If w(win).NeedsRefresh Then resizeWin win

                    Dest w(win_Cat).IH
                    Cls , 0
                    Print win_Cat_Text;
                End If



            Case win_Launcher
                If w(win).NeedsRefresh Then resizeWin win
                Dest w(win).IH
                Cls
                If win_Log Then PrintString (0, 0), "Close log" Else PrintString (0, 0), "Open log"
                If win_Cat Then PrintString (0, 16), "Close text editor" Else PrintString (0, 16), "Open text editor"
                If win_Img Then PrintString (0, 32), "Close image" Else PrintString (0, 32), "Open image"
                If w(win_Launcher).Z = 0 Then
                    If MouseButton(1) Then
                        Select Case w(win).MY
                            Case 0 TO 16
                                If win_Log Then
                                    freeWin win_Log
                                    win_Log = 0
                                Else
                                    temp = __template_Win
                                    temp.X = 50
                                    temp.IH = NewImage(320, 240, 32)
                                    temp.T = "Log"
                                    temp.FH = __font_Mono
                                    win_Log = newWin(temp)
                                End If

                            Case 16 TO 24
                                If win_Cat Then
                                    freeWin win_Cat
                                    win_Cat = 0
                                Else
                                    temp = __template_Win
                                    temp.X = 200
                                    temp.IH = NewImage(320, 240, 32)
                                    temp.T = "Text editor"
                                    temp.FH = __font_Sans
                                    win_Cat = newWin(temp)
                                End If

                            Case 32 TO 48
                                If win_Img Then
                                    freeWin win_Img
                                    win_Img = 0
                                Else
                                    temp = __template_Win
                                    temp.IH = NewImage(temp.W, temp.H, 32)
                                    temp.T = "Image"
                                    win_Img = newWin(temp)
                                End If
                        End Select
                    End If
                End If


                'Case otherWin 'Other window
                '    If (w(win).W > 8) And (w(win).H > 8) Then 'Resize it. Again, not needed every frame, but it should be fine.
                '        FreeImage w(win).IH
                '        w(win).IH = NewImage(w(win).W, w(win).H, 32)
                '        Font w(win).FH, w(win).IH
                '    End If

                '    'Window contents
                '    Dest w(win).IH
                '    Print "X:"; w(win).X, "Y:"; w(win).Y
                '    Print "Z:"; w(win).Z
                '    Print "W:"; w(win).W, "H:"; w(win).H
                '    Print "T:"; w(win).T, "WH:"; win
                '    Print "IH:"; w(win).IH, "FH:"; w(win).FH

                '    'Window title
                '    w(win).T = "Window " + LTrim$(Str$(win)) + " (" + LTrim$(Str$(w(win).X)) + "," + LTrim$(Str$(w(win).Y)) + ")-(" + LTrim$(Str$(w(win).W + w(win).X)) + "," + LTrim$(Str$(w(win).H + w(win).Y)) + ")"
        End Select
    Next
    upd
    Display
    Limit 60
Loop









'$Checking:Off
$If LIGHT = TRUE Then
    Sub putWin (w As winType)
        Shared __param_TBHeight As Unsigned Integer

        If w.IH = 0 Then Exit Sub 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!
        _DontBlend

    If w.Z = 0 Then  _
    Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HFF000000, BF _
    Else Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HFF999999, BF

        PrintString ((w.W - PrintWidth(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

        PutImage (w.X + 1, w.Y + __param_TBHeight), w.IH, , (0, 0)-Step(w.W, w.H) ' Put the contents of the window down
    End Sub
$Else
    Sub putWin (w As winType)
    Shared __param_TBHeight As Unsigned Integer

    'For speed
    Rem RGBA32(0, 0, 0, 10)  = &H0A000000
    Rem RGBA32(0, 0, 0, 200) = &HC8000000
    Rem RGBA32(0, 0, 0, 64)  = &H40000000

    Line (w.X - 2, w.Y - 2)-Step(w.W + 6, w.H + __param_TBHeight + 6), &H0A000000, BF 'Shadow

    If w.IH = 0 Then Exit Sub 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!

    If w.Z = 0 Then
    Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HC8000000, BF 'Window backing
    End If

    PrintString ((w.W - PrintWidth(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

    PutImage (w.X + 1, w.Y + __param_TBHeight), w.IH, , (0, 0)-Step(w.W, w.H), Smooth ' Put the contents of the window down

    If w.Z Then Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &H40000000, BF 'Dark overlay if not focused
    End Sub
$End If
'$Checking:On


'$Checking:Off
Sub upd Static
    Shared w() As winType
    Shared winZOrder() As Byte
    Shared __image_Background As Long
    Shared __image_Screen As Long
    Shared __image_ScreenBuffer As Long
    Shared __image_Cursor As Long
    Shared __param_ScreenFont As Long

    __inKey$ = InKey$

    $If HW = TRUE Then
        Dest __image_ScreenBuffer
    $Else
        If (Resize) Then 'If the program window is resizing
            Screen 0
            FreeImage __image_Screen
            __image_Screen = NewImage(ResizeWidth, ResizeHeight, 32)
            Screen __image_Screen
            Font __param_ScreenFont, __image_Screen
        End If

        Dest Display
    $End If

    PutImage , __image_Background 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)
    PrintString (0, 0), "FPS:" + Str$(fps) 'the fps function is fps the amount of times it's called in a second.

    fixFocusArray

    Dim i As Integer
    For i = UBound(winZOrder) To LBound(winZOrder) Step -1
        If winZOrder(i) <> 0 Then
            putWin w(winZOrder(i))
        End If
    Next

    PutImage (MouseX, MouseY), __image_Cursor

    $If HW Then
        PutImage , __image_ScreenBuffer, __image_Screen
    $End If
End Sub
'$Checking:On





'$Checking:Off
Function newWin% (template As winType)
    Shared w() As winType

    Font template.FH, template.IH
    Dim i As Integer
    For i = LBound(w) To UBound(w)

        If (w(i).IH = 0) Then
            logp "INFO> newWin: Empty slot " + Str$(i) + " now holds window with image handle of " + Str$(w(i).IH)
            GoTo e
        End If

    Next
    ReDim Preserve w(LBound(w) To UBound(w) + 1) As winType
    i = UBound(w)
    logp "INFO> newWin: Extending w() to " + Str$(i) + " for window with image handle of " + Str$(w(i).IH)

    e:
    If template.T <> "" Then template.T = template.T + " (" + LTrim$(Str$(i)) + ")"
    w(i) = template
    If w(i).Z = 0 Then grabFocus i
    newWin% = i
End Function
'$Checking:On




'$Checking:Off
Sub logp (s As String) Static
    Shared w() As winType
    Shared win_Log As Integer

    Dim i As Long, l As String
    i = Dest

    If s <> "" Then l = l + s + Chr$(13)

    If win_Log Then
        If w(win_Log).IH Then
            Dest w(win_Log).IH

            Print l;

            Dest i 'Restore the DEST IMAGE
        End If
    End If
End Sub
'$Checking:On




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




'$Checking:Off
Sub updateMouse Static
    Shared w() As winType
    Shared winZOrder() As Byte
    Shared __param_TBHeight As Unsigned Integer


    Dim optMenu As Integer, optWin As Integer
    Dim mLockX As Single, mLockY As Single 'Or as I like to call it, mmmlocks and mmmlockie
    Dim mouseLatch As Bit

    Dim win As Integer, i As Integer
    For win = LBound(winZOrder) To UBound(winZOrder)
        i = winZOrder(win)

        If i = 0 Then Continue

        w(i).MX = MouseX - (w(i).X + 1)
        w(i).MY = MouseY - (w(i).Y + __param_TBHeight + 1)

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

        ElseIf (w(__focusedWindow).W <> _Width(w(__focusedWindow).IH)) Or (w(__focusedWindow).H <> _Height(w(__focusedWindow).IH)) Then
            w(__focusedWindow).NeedsRefresh = True
        Else
            w(__focusedWindow).NeedsRefresh = False

    End If: End If

    mLockX = MouseX
    mLockY = MouseY
End Sub
'$Checking:On





Sub fixFocusArray
    Shared winZOrder() As Byte
    Shared w() As winType

    Erase winZOrder

    Dim i As Integer
    'For i = LBound(w) To UBound(w)
    '    If w(i).T = "" Then winZOrder(UBound(winZOrder)) = i
    'Next

    For i = UBound(w) To LBound(w) Step -1 'Prioritize newer windows by going backwards
        If w(i).IH = 0 Then Continue
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



Sub resizeWin (win As Integer)
    Shared w() As winType
    FreeImage w(win).IH
    w(win).IH = NewImage(w(win).W, w(win).H, 32)
    Font w(win).FH, w(win).IH
End Sub




Function mouseIsOver` (win As Integer)
    Shared w() As winType
    mouseIsOver` = ((MouseX >= w(win).X) And (MouseX <= (w(win).X + w(win).W)) And (MouseY >= w(win).Y) And (MouseY <= (w(win).Y + w(win).H)))
End Function






Sub grabFocus (win As Integer)
    Shared w() As winType
    Dim i As Integer
    For i = LBound(w) To UBound(w)
        If i = win Then w(i).Z = 0 Else w(i).Z = w(i).Z + 1
    Next
    __focusedWindow = win
End Sub




Sub sendWin (w As winType, c As Long)
    Dim i As _Unsigned _Byte
    i = 0
    Put #c, , i
    Put #c, , w.X
    Put #c, , w.Y
    Put #c, , w.Z
    Put #c, , w.W
    Put #c, , w.H
    Put #c, , w.NeedsRefresh
    _Source w.IH

    Dim x As Integer, y As Integer, clr As Long

    x = _Width(w.IH)
    Put #c, , x

    y = _Height(w.IH)
    Put #c, , y

    For x = 0 To _Width(w.IH)
        For y = 0 To _Height(w.IH)
            clr = Point(x, y)
            Put #c, , clr
    Next y, x
End Sub



Sub getWin (c As Long)
    Shared temp As winType
    Dim i As _Unsigned _Byte
    Do
        i = 1
        If LOF(c) Then Get #c, , i
    Loop Until i = 0
    Do: Loop Until LOF(c)
    Get #c, , temp.X
    Do: Loop Until LOF(c)
    Get #c, , temp.Y
    Do: Loop Until LOF(c)
    Get #c, , temp.Z
    Do: Loop Until LOF(c)
    Get #c, , temp.W
    Do: Loop Until LOF(c)
    Get #c, , temp.H
    Do: Loop Until LOF(c)
    Get #c, , temp.NeedsRefresh

    Dim x As Integer, y As Integer
    Do: Loop Until LOF(c)
    Get #c, , x

    Do: Loop Until LOF(c)
    Get #c, , y

    If temp.IH = 0 Or temp.IH = -1 Then _FreeImage temp.IH
    temp.IH = _NewImage(x, y, 32)
    _Dest temp.IH

    Dim clr As Long
    For x = 0 To _Width(temp.IH)
        For y = 0 To _Height(temp.IH)
            Do: Loop Until LOF(c)
            Get #c, , clr
            PSet (x, y), clr
    Next y, x
End Sub
