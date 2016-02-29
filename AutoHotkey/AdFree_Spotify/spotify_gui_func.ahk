; ------------------------------------------------------------------------------------------------
; 	FUNCTIONS & SUBROUTINES
; ------------------------------------------------------------------------------------------------

	; Change Hide at Startup state
	HideAtStartup:
		Menu, Tray, ToggleCheck, Hide at Startup
		vStartHidden := !vStartHidden
	Return
	
	; Main GUI summoned from the tray menu
	Open:
	DetectHiddenWindows, Off
	IfWinExist, ahk_id %gid1% ; If already exist, do not let execute the code another time
	{
		WinActivate
		Return
	}
	DetectHiddenWindows, On
	
	; ------------------------------------------------------------------------------------------------
	; 	GUI CONSTRUCTION
	; ------------------------------------------------------------------------------------------------
		Gui, +LastFound -MinimizeBox
		Gui, Color, Black
		Gui, Font, cWhite
		Gui, Font, underline
		Gui, Add, Text, % "w" Tw1W  " center", Instructions
		Gui, Font, Norm
		Gui, Add, Text, % "w" Tw1W  " Section", 
	(
   %A_Space%%A_Space%%A_Space%%A_Space%%A_Space%Use your mouse to set
     'Artist - Song - Album' text
     position in your monitor(s).

     The black square represents
     the text object and the numbered
     quadrilaterals are the physical 
     monitors installed in your system.

     Click on the monitor you want to
     use to display the song info and
     drag the square while holding
     down the mouse button.
	)
		Gui, Add, GroupBox, % "w" Tw1W " h279 yp+180 center", % "                                          "
		Gui, Add, Checkbox, x43 yp Checked%vEnableAll% vvEnableAll gEnableAll, USE TEXT DISPLAY
		Gui, Add, Button, w120 x43 yp+28 vvButtonFont gButtonFont, Choose Font
		
		Gui, Add, GroupBox, % "xs+7 yp+32 w" Tw1W - 14 " h50 Center", % "                                      "
		Gui, Add, Checkbox, x48 yp vvUseShadowColor gUseShadowColor Checked%vUseShadowColor%, % "Use colored outline"
		Gui, Add, Text, x34 yp+22 vvTextShadowColor, Outline color:
		Gui, Font, cBlack
		Gui, Add, DropDownList, x100 yp-3 w70 AltSubmit vvListShadowColor Choose%vListShadowColor% gListShadowColor
							  , White|Black|Maroon|Green|Olive|Navy|Purple|Teal|Gray|Silver|Red|Lime|Yellow|Blue|Fuchsia|Aqua
		Gui, Font, cWhite
		
		Gui, Add, GroupBox, % "xs+7 yp+39 w" Tw1W - 14 " h50 Center", Text display duration (seconds)
		Gui, Font, Norm
		Gui, Font, cBlack
		Gui, Add, Edit, x49 yp+20 w37 vvTextEdit hwndhEdit Number 
		Gui, Add, UpDown, vvTextUpDown Range1-30, %vTextUpDown%
		Gui, Font, Norm
		Gui, Font, cWhite
		Gui, Add, Checkbox, xp+60 yp+4 Checked%vInfinite% vvInfinite gInfinite, Infinite
		
		Gui, Add, GroupBox, % "xs+7 yp+33 w" Tw1W - 14 " h64 Center", Text justification
		Gui, Add, Radio, vvRadio1 Checked%vRadio1% xp+5 yp+20	, Top-Left
		Gui, Add, Radio, vvRadio2 Checked%vRadio2%				, Bottom-Left
		Gui, Add, Radio, vvRadio3 Checked%vRadio3% xp+80 yp-18	, Top-Right
		Gui, Add, Radio, vvRadio4 Checked%vRadio4%	 			, Bottom-Right
		
		Gui, Add, Button, xs+38 yp+33 w110 vvButtonPreview gButtonPreview, Preview
		
		Gui, Add, TreeView, % "ym w" Tw2WInit " h" Tw2HInit " vvTw2 hwndhTw2 +" WS_CLIPCHILDREN " Background" TwColor2 ;/ 100 * (GuiW - 3 * Margins)
		gid1 := WinExist()

		ControlGetPos, Tw2X, Tw2Y, Tw2WInit, Tw2HInit, , ahk_id %hTw2% ; Update TreeView position and dimensions, easier this way

		; Correct TreeView dimensions which are too large :(
		Tw2W := Tw2WInit - Tw2Wtrim 
		Tw2H := Tw2HInit - Tw2Htrim

	; ------------------------------------------------------------------------------------------------
	; 	CREATE AND POSITION CHILD GUIS, THAT REPRESENT PHYSICAL DISPLAY LAYOUT, IN THE TREEVIEW CONTROL
	; ------------------------------------------------------------------------------------------------
		; Virtual desktop position and dimensions
		SysGet, VX, 76
		SysGet, VY, 77
		SysGet, VW, 78
		SysGet, VH, 79
		
		; Scaling ratio
		RelX := VW / Tw2W
		RelY := VH / Tw2H

		; Adjust RelX and RelY not to fill the whole TreeView control unless appropriate
		; If virtual desktop width > height, Y pixel ratio needs to be adjusted
		; Same processing for X pixel if height > width
		; Otherwise measures won't be right because TreeView square shape doesn't likely reflect desktop shape
		If (VW > VH)
			RelY *= VW / VH
		Else If (VW < VH)
			RelX *= VH / VW
			
		SysGet, MonitorC, %SM_CMONITORS%
		If MonitorC > 96 ; Yeah, sure, but let's be prepared anyway
			MonitorC = 96
		Loop % MonitorC
		{
			a := A_Index + 1
			; Get monitor dimensions
			SysGet, gid%a%, Monitor, %A_Index%
			
			; Get monitor position relative to TreeView size, scaled accordingly
			gid%a%X := Floor((gid%a%Left - VX) / RelX)
			gid%a%Y := Floor((gid%a%Top - VY) / RelY)
			gid%a%W := Floor((gid%a%Right - gid%a%Left) / RelX)
			gid%a%H := Floor((gid%a%Bottom - gid%a%Top) / RelY)
			
			If (gid%a%W >= gid%a%H / 2) ; Display height is font size deciding factor
				sFont%a% := Floor(((gid%a%H / 2) - 1) * 2 / 3) ; Approximate values
			Else ; Extremely unlikely (maybe true in virtual displays?). If true, display width becomes the deciding factor
				sFont%a% := Floor(((gid%a%W / 2) - 1) * 4 / 3) ; Approximate values
			
			; FORMULAS, DO NOT DESTROY ,,,, H := r + 2 * r // 4 + 1 ,,,, W := H // 2 - ((Mod(H, 2) ? 0 : 1)) ,,,, r = (W - 1) * 4 / 3 ,,,, r = (H - 1) * 2 / 3
			
			; Add new GUIs to represent monitors constituting the desktop
			Gui, %a%: +LastFound -Sysmenu -Caption +Border +%WS_CHILD% 
			Gui, %a%: Color, %GuiInActiveColor%
			Gui, %a%: Font, % "s" sFont%a% " c" FontInActiveColor
			Gui, %a%: Add, Text, % "x0 y0 center vvText" a " hwndhText" a, % A_Index
			gid%a% := WinExist()
			
			GuiControlGet, Text%a%, %a%: Pos, vText%a% ; Get display number text dimensions
			
			GuiControl, %a%: Move, vText%a%, % "x" gid%a%W / 2 - Text%a%W / 2 " y" gid%a%H / 2 - Text%a%H / 2
			DllCall("SetParent", int, gid%a%, int, hTw2) ; Set new GUI to be TreeView's child
			;Gui, %a%: -%WS_POPUP%
			
		}

		If (Tw2W - VW / RelX > Tw2H - VH / RelY)	 ; GUIs representing displays need to be horizontally centered in the TreeView control
			HorAlign = 1
		Else If (Tw2W - VW / RelX < Tw2H - VH / RelY) ; GUIs representing displays need to be vertically centered in the TreeView control
			HorAlign = 0
	
	; Set enabled/disabled states
	InitializeGUI()
	
	; Main GUI
	Gui, Show, % "w" GuiW " h" GuiH (vStartHidden and Initialize ? " Hide" : ""), % FileTitle FileVersion
		Loop % MonitorC
		{
			a := A_Index + 1
			If HorAlign
				gid%a%X += Round((Tw2W - VW / RelX) / 2)
			Else
				gid%a%Y += Round((Tw2H - VH / RelY) / 2)
			
	; Monitor GUIs
	Gui, %a%: Show, % "x" gid%a%X " y" gid%a%Y " w" gid%a%W " h" gid%a%H " NA" (vStartHidden and Initialize ? " Hide" : ""), % "Monitor #" A_Index
		}

		; Songbox creation
		a++
		Gui, %a%: +LastFound
		gid%a% := WinExist()
		DllCall("SetParent", int, gid%a%, int, hTw2)
		Gui, %a%: Color, Black
		Gui %a%: Font, s8 c000000
		Gui %a%: Add, Text, x0 y0 w12 h12 hwndhSongBox, % "    "
		
	; Create the songbox
	Gui %a%: Show, Autosize Hide NA
		WinGetPos, gid%a%X, gid%a%Y, gid%a%W, gid%a%H, % "ahk_id " gid%a%
		;ControlGetPos, SongBoxX, SongBoxY, SongBoxW, SongBoxH, , ahk_id %hSongBox%
		WinGetPos, , , SongBoxW, SongBoxH, ahk_id %hSongBox%
		;WinSet, Region, % SongBoxX "-" SongBoxY " w" SongBoxW " h" SongBoxH, % "ahk_id " gid%a%
		WinSet, Region, % SM_CXEDGE + 1 "-" SM_CYEDGE + SM_CYCAPTION + 1 " w" SongBoxW " h" SongBoxH, % "ahk_id " gid%a%
	
	; Get songbox position from the settings file, update file if necessary, test position validity and show the songbox GUI
	c := MonitorC + 2
	
	If (SongBoxX = "") ; True only during the first execution
	{
		If !AddXY ; Settings file was found
		{
			IniRead, SongBoxX, %FileName%, Position, X
			IniRead, SongBoxY, %FileName%, Position, Y
			;SongBoxX //= RelX, SongBoxY //= RelY
		}
		Else ; File not found, add the last missing lines
		{
			;SongBoxX := gid2W - SongBoxW, SongBoxY := gid2H - SongBoxH
			IniWrite, % SongBoxX := (gid2W - SongBoxW) * RelX, %FileName%, Position, X ; Assign X a valid value and add to the settings file
			IniWrite, % SongBoxY := (gid2H - SongBoxH) * RelY, %FileName%, Position, Y ; Assign Y a valid value and add to the settings file
		}
		
		; X and/or Y was not found in the settings file
		If (SongBoxX = "ERROR") or (SongBoxY = "ERROR")
			; Overwrite both even if both were not missing
			SongBoxX := (gid2W - SongBoxW) * RelX, SongBoxY := (gid2H - SongBoxH) * RelY
		b := Monitor + 1
	} ; The user may have tampered with the settings file during program execution, that's why if ends already here
	
	; X and/or Y may still be invalid, just test both of them
	ValidPos = 0
	Loop, % MonitorC
	{
		a := b ? b : A_Index + 1
		; If the songbox is completely located within any single monitor GUI rectangle
		If  (SongBoxX >= 0) and Floor((SongBoxX + (SongBoxW * RelX)) <= gid%a%Right - gid%a%Left) 
		and (SongBoxY >= 0) and Floor((SongBoxY + (SongBoxH * RelY)) <= gid%a%Bottom - gid%a%Top)
		{
			ValidPos := a
			Break
		}
	}
	
	If !ValidPos ; If settings were invalid
	{
		ValidPos = 2
		SongBoxX := (gid2W - SongBoxW) * RelX
		SongBoxY := (gid2H - SongBoxH) * RelY
	}
	
	; Songbox
	Gui, %c%: Show, % "x" gid%ValidPos%X + SongBoxX // RelX - SM_CXEDGE " y" gid%ValidPos%Y + SongBoxY // RelY - SM_CYEDGE - SM_CYCAPTION (vStartHidden and Initialize ? " Hide" : ""), Artist - Song - Album
	
	; ------------------------------------------------------------------------------------------------
	; 	STRUCTURES
	; ------------------------------------------------------------------------------------------------
		#Include spotify_gui_structures.ahk
		
	; ------------------------------------------------------------------------------------------------
	;	ONMESSAGE
	; ------------------------------------------------------------------------------------------------
		#Include spotify_gui_onmessage.ahk
		
		PrevWindowProcEdit := DllCall("SetWindowLong", uint, hEdit, int, GWP_WNDPROC, int, RegisterCallback("WindowProcEdit", "", 4), uint)
		SendMessage, WM_MOUSEACTIVATE, 0, 0, , % "ahk_id " gid%ValidPos%
	Return
	
				
				; USE TEXT DISPLAY checkbox
				EnableAll:
					Gui, Submit, Nohide
					InitializeGUI()
				Return
				
				; Choose font button
				ButtonFont:
					If DllCall("comdlg32\ChooseFontA", int, &CHOOSEFONT) ; The user clicked OK
						Gui, 99: Color, % ColorConvert(NumGet(CHOOSEFONT, 24))
					NumPut(FONT_QUALITY, LOGFONT, 26, "UChar") ; lfQuality
				Return
				
				; Infinite checkbox
				Infinite:
					Gui, Submit, Nohide
					SongTextAdjust()
					GuiControl, Disable%vInfinite%, vTextEdit
					GuiControl, Disable%vInfinite%, vTextUpDown
					;If vInfinite
						;vTextEdit = 0
				Return
				
				; Use colored outline checkbox
				UseShadowColor:
					Gui, Submit, Nohide
					SongTextAdjust()
					GuiControl, Enable%vUseShadowColor%, vListShadowColor
				Return
				
				; Outline color dropdownlist
				ListShadowColor:
					Gui, Submit, NoHide
					SongTextAdjust()
					Gui, 98: Color, % GuiColor%vListShadowColor%
				Return
				
				; Preview button
				ButtonPreview:
					Gui, Submit, Nohide
					SongTextAdjust()
					Display((string = "Spotify" ? "Artist - Song - Album" : (string = "" ? "Artist - Song - Album" : SubStr(string, 11))), b - 1, 0)
					;Display("Artist - Song - Album", b - 1, 0)
					
				Return
				
				; Tray menu about
				About:
					Menu, Tray, Disable, Open
					If gid97
					{
						WinActivate, ahk_id %gid97%
						Return
					}
					Gui, 97: Default
					IfWinExist, ahk_id %gid1%
					{
						Gui, 1: +Disabled
						Gui, +Owner1
					}
					Gui, +lastfound -MinimizeBox -Sysmenu
					gid97 := WinExist()
					
					Gui, Color, Black
					Gui, Add, Text, w185 h85 +%SS_SUNKEN%
					Gui, Font, Bold cWhite underline
					Gui, Add, Text, xp+1 yp+15 w183 Section center, % FileTitle FileVersion 
					Gui, Font, Norm cWhite
					Gui, Add, Text, xp+13 yp+20, © 2010-%a_year%
					;Gui, Font, Bold cWhite
					Gui, Add, Text, xp+70 yp, LioneZZ Software
					 
					;Gui, Font, Norm cWhite
					;Gui, Add, Text, xs+9 yp+20 Section, % "EMail: "
					Gui, Font, Norm
					Gui, Font, c8888FF Underline
					Gui, Add, Text, x26 yp+20 hwndhWeb gWeb, http://www.lionezzsoftware.com ;LioneZZ Software website
					;Gui, Add, Text, xs+7 hwndhYoutube gYoutube, LioneZZ Software Youtube channel
					Gui, Font, Norm cWhite
					Gui, Add, Button, x67 y+23 w70 Default gAboutOK, &OK
					
					; Make sure About dialog stays completely visible by counting which monitors the GUI spreads 
					; into (if any) when shown at initial mid-main GUI coordinates. If the About dialog crosses 
					; display edges, calculate the square pixel area the dialog accommodates for each physical 
					; monitor. Move the About dialog entirely within edges of the window containing the largest 
					; portion of the dialog.
					IfWinExist, ahk_id %gid1%
					{
						
						WinGetPos, gid1X, gid1Y, gid1W, gid1H, ahk_id %gid1%
						
						Gui, Show, % "x" (gid1X + gid1W / 2 - 205 / 2 - SM_CXEDGE) // 1 
								  . " y" (gid1Y + gid1H / 2 - (130 + SM_CYEDGE * 2 + SM_CYCAPTION) / 2) // 1  " w205 h125 Hide", About
						
						SysGet, MonitorC, %SM_CMONITORS%
						If MonitorC > 96
							MonitorC = 96
						If !SetAboutPos(gid97) ; Dialog GUI completely outside of desktop space
							If !SetAboutPos(gid1) ; Main GUI completely outside of desktop space (highly unlikely)
							{
								;Position to the center of the primary monitor
								WinGetPos, , , AboutW, , ahk_id %gid97%
								WinMove, % (mon1Right - mon1Left - AboutW) // 2, % (mon1Bottom - mon1Top - AboutH) // 2
								Gui, Show
							}
					}
					Else
						Gui, Show, , About
					WinActivate, ahk_id %gid97%
					PrevControlProc := DllCall("SetWindowLong", int, hWeb, int, GWP_WNDPROC, uint, RegisterCallback("ControlProc", "", 4), uint)
					; The same orig process as above
					DllCall("SetWindowLong", int, hEmail, int, GWP_WNDPROC, uint, RegisterCallback("ControlProc", "", 4), uint)
					DllCall("SetWindowLong", int, hYoutube, int, GWP_WNDPROC, int, RegisterCallback("ControlProc", "", 4), uint)
					hHand := DllCall("LoadCursor", int, 0, int, IDC_HAND)
					OnMessage(WM_SETCURSOR, "WM_SETCURSOR") ; Keep changing the cursor while its over the control
				Return
				
				ControlProc(hWnd, uMsg, wParam, lParam)
				{
					Local WndProc
					If !Trackinghwnd and (uMsg = WM_MOUSEMOVE)
					{
						NumPut(hWnd, TRACKMOUSEEVENT, 8) ; hwndTrack
						DllCall("TrackMouseEvent", int, &TRACKMOUSEEVENT)
						Trackinghwnd := hWnd
						/* MSDN:
						Your application can change the design of the cursor by using the SetCursor function and specifying a different cursor handle.
						However, when the cursor moves, the system redraws the class cursor at the new location. To prevent the class cursor from 
						being redrawn, you must process the WM_SETCURSOR message.
						*/
						DllCall("SetCursor", int, hHand)
					}
					Return DllCall("CallWindowProc", uint, PrevControlProc, uint, hWnd, uint, uMsg, uint, wParam, uint, lParam)
				}
				
				WM_SETCURSOR(wParam, lParam, msg, hwnd)
				{
					Global
					If Trackinghwnd and (wParam = Trackinghwnd)
					{
						DllCall("SetCursor", int, hHand)
						Return 1
					}
				}
				
				WM_MOUSELEAVE(wParam, lParam, msg, hwnd)
				{
					Global
					; The cursor automatically changes back to the window class cursor
					Trackinghwnd := 0
				}
				
				Web:
					Run, http://www.lionezzsoftware.com
				Return
				
				Email:
					Run, mailto:sales@lionezzsoftware.com
				Return
				
				Youtube:
					Run, http://www.youtube.com/LioneZZSoftware
				Return
				
				AboutOK:
					onmessage(WM_SETCURSOR, "") ; Disable WM_SETCURSOR monitoring until About dialog is popped up again
					Gui, Destroy
					
					gid97 = 0
					Menu, Tray, Enable, Open
					IfWinExist, ahk_id %gid1%
					{
						Gui, 1: -Disabled
						WinActivate
					}
				Return
				
				; Tray menu exit
				OnExit:
					;IfWinExist, % "ahk_id " gid%b%
					Gosub, GuiClose
					ExitApp
				Return
				
				; Close button / !{F4}
				GuiClose:
					If clipped
						DllCall("ClipCursor", int, 0)
					IfExist, %FileName%
					{
						FileDelete, %FileName%
						If !ErrorLevel
							SaveSettings()
					}
					Else
						SaveSettings()
					Loop % MonitorC + 2
						Gui, %A_Index%: Destroy
					
					  unhookwinevent(hhook)
					, dllcall("FreeLibrary", int, hgdi32)
					, dllcall("FreeLibrary", int, huser32)
				Return
	
	; Save settings to ini file
	SaveSettings()
	{
		Local FontColorSwap
		
		; To make sure X and Y are not empty in case GUIS were closed (= Songbox destroyed) and the user exits through tray menu
		; Also do not parse the font structure a second time as it's unnecessary
		IfWinExist, % "ahk_id " gid%b%
		{
			Gui, Submit, Nohide
			
			; Needed to keep respective settings saved during execution
			FontName := DllCall("MulDiv", int, &LOGFONT + 28, int, 1, int, 1, str)
			FontStyle := NumGet(LOGFONT, 16) = FW_BOLD ? NumGet(LOGFONT, 20, "UChar") != 0 ? 4 : 2 : NumGet(LOGFONT, 20, "UChar") = 1 ? 1 : 0
			FontHeight := NumGet(CHOOSEFONT, 16) // 10
			FontEffect := NumGet(LOGFONT, 21, "UChar") = 1 ? NumGet(LOGFONT, 22, "UChar") != 0 ? 4 : 2 : NumGet(LOGFONT, 22, "UChar") = 1 ? 1 : 0
			SetFormat, Integer, H
			FontColor := NumGet(CHOOSEFONT, 24) + 0 ; Do NOT swap bytes here...
			SetFormat, Integer, D
			FontColorSwap := ColorConvert(FontColor) ; ... but here
			
			WinGetPos, gid%b%X, gid%b%Y, , , % "ahk_id " gid%b%
			WinGetPos, SongBoxX, SongBoxY, , , ahk_id %hSongBox%
			SongBoxX := (SongBoxX - (gid%b%X + 1)) * RelX, SongBoxY := (SongBoxY - (gid%b%Y + 1)) * RelY ; 1 stands for ... something :s
		}
	
		IniWrite, % vEnableAll		, %FileName%, UseTextDspl,	UseTextDspl
		
		FileAppend, `n, %Filename%
		IniWrite, % FontName		, %FileName%, Font, 		Name
		IniWrite, % FontStyle		, %FileName%, Font, 		Style
		IniWrite, % FontHeight		, %FileName%, Font, 		Size
		IniWrite, % FontEffect		, %FileName%, Font, 		Effect
		IniWrite, % FontColorSwap	, %FileName%, Font, 		Color
		
		FileAppend, `n, %Filename%
		IniWrite, % vUseShadowColor	, %FileName%, Outline, 		Use
		IniWrite, % vListShadowColor, %FileName%, Outline, 		Color
		
		FileAppend, `n, %Filename%
		IniWrite, % vTextUpDown		, %FileName%, Duration, 	Seconds
		IniWrite, % vInfinite		, %FileName%, Duration, 	Infinite
		
		FileAppend, `n, %Filename%
		IniWrite, % vRadio1 = 1 ? 1 : vRadio2 = 1 ? 2 : vRadio3 = 1 ? 3 : 4
									, %FileName%, Position,		Justify
		IniWrite, % b - 1			, %FileName%, Position,		Monitor
		IniWrite, % vStartHidden	, %FileName%, Position,		HideAtStartup
		IniWrite, % SongBoxX 		, %FileName%, Position,		X
		IniWrite, % SongBoxY 		, %FileName%, Position,		Y

		Return
	}
	
	SetAboutPos(hWnd)
	{
		Local RefX, RefY, RefW, RefH, Ref1, Ref2, Ref3, Ref4
			, AboutX, AboutY, AboutW, AboutH, DispArea1, DispArea2, DispArea3, DispArea4
			, Iter, LargestArea, LargestAreaIndex

		WinGetPos, RefX, RefY, RefW, RefH, ahk_id %hWnd%
		
		IfWinExist, ahk_id %gid97% ; Surely exists, just update the last found window to save some typing
			WinGetPos, AboutX, AboutY, AboutW, AboutH
		Loop % MonitorC
		{
			SysGet, mon%A_Index%, MonitorWorkArea, % A_Index
			
			; Within the monitor # A_Index
			If  (RefX 			>= mon%A_Index%Left) 	and (RefX 			<= mon%A_Index%Right)
			and (RefY 			>= mon%A_Index%Top)  	and (RefY 			<= mon%A_Index%Bottom) ; Upper-left corner
				Ref1 := A_Index
			If  (RefX 			>= mon%A_Index%Left)	and (RefX  			<= mon%A_Index%Right)
			and (RefY + RefH 	>= mon%A_Index%Top)  	and (RefY + RefH 	<= mon%A_Index%Bottom) ; Lower-left corner
				Ref2 := A_Index
			If  (RefX + RefW 	>= mon%A_Index%Left) 	and (RefX + RefW 	<= mon%A_Index%Right)
			and (RefY 			>= mon%A_Index%Top) 	and (RefY 			<= mon%A_Index%Bottom) ; Upper-right corner
				Ref3 := A_Index
			If  (RefX + RefW 	>= mon%A_Index%Left) 	and (RefX + RefW 	<= mon%A_Index%Right)
			and (RefY + RefH 	>= mon%A_Index%Top)  	and (RefY + RefH 	<= mon%A_Index%Bottom) ; Lower-right corner
				Ref4 := A_Index
			If Ref1 and Ref2 and Ref3 and Ref4 ; If all found already, no need to carry on
				Break
		}
		If Ref1 and (Ref1 = Ref4) ; Entire Ref GUI in a single monitor
		{
			Gui, Show
			Return 1 ; Non-zero / non-blank value equals to success
		}
		Else
		{
			If Ref1 					; Total area for the display having the Ref GUI upper-left corner
			{
				DispArea%Ref1% := Ref1 = Ref3 ? RefW : (mon%Ref1%Right 	- RefX)		; W
				DispArea%Ref1% *= Ref1 = Ref2 ? RefH : (mon%Ref1%Bottom	- RefY)		; H
			}
			If Ref2 and (Ref2 != Ref1) 	; Total area for the display having the Ref GUI lower-left corner
				DispArea%Ref2% := (Ref2 = Ref4 ? RefW : (mon%Ref2%Right	- RefX))	; W
								  * (RefY + RefH - mon%Ref2%Top) 					; H
			
			If Ref3 and (Ref3 != Ref1) 	; Total area for the display having the Ref GUI upper-right corner
			{
				DispArea%Ref3% := (RefX + RefW - mon%Ref3%Left)						; W
				DispArea%Ref3% *= Ref3 = Ref4 ? RefH : (mon%Ref3%Bottom	- RefY)		; H
			}
			If Ref4 and (Ref4 != Ref2) 	; Total area for the display having the Ref GUI lower-right corner
					and (Ref4 != Ref3) 
				DispArea%Ref4% := (RefX + RefW - mon%Ref4%Left) 					; W
								  * (RefY + RefH - mon%Ref4%Top) 					; H
			
			Loop, 4
			{
				Iter := Ref%A_Index%
				If (DispArea%Iter% > (LargestArea ? LargestArea : 0))
				{
					LargestArea := DispArea%Iter%
					LargestAreaIndex := A_Index
				}
			}
			
			If LargestArea ; The dialog at least partially visible
			{
				; Find out which dialog corners are outside of the area of the monitor to display the dialog and move the dialog GUI accordingly
				Iter := Ref%LargestAreaIndex%
				If (RefX < mon%Iter%Left)
				{
					If (RefY < mon%Iter%Top) 					; Upper-left, lower-left and upper-right
						WinMove, % mon%Iter%Left - 1			, % mon%Iter%Top					; Move southeast
					Else If (RefY + RefH > mon%Iter%Bottom) ; Upper-left, lower-left and lower-right
						WinMove, % mon%Iter%Left - 1			, % mon%Iter%Bottom - AboutH		; Move northeast
					Else										; Upper-left and lower-left
						WinMove, % mon%Iter%Left - 1												; Move east
				}
				Else If (RefX + RefW > mon%Iter%Right)
				{
					If (RefY < mon%Iter%Top) 					; Upper-right, lower-right and upper-left
						WinMove, % mon%Iter%Right - AboutW + 1	, % mon%Iter%Top					; Move southwest
					Else If (RefY + RefH > mon%Iter%Bottom) ; Upper-right, lower-right and lower-left
						WinMove, % mon%Iter%Right - AboutW + 1	, % mon%Iter%Bottom - AboutH		; Move northwest
					Else										; Upper-right and lower-right
						WinMove, % mon%Iter%Right - AboutW + 1										; Move west
				}
				Else If (RefY < mon%Iter%Top)					; Upper-left and upper-right
					WinMove, 									, % mon%Iter%Top - 1				; Move south
				Else If (RefY + RefH > mon%Iter%Bottom) 	; Lower-left and lower-right
					WinMove, 									, % mon%Iter%Bottom - AboutH + 1	; Move north
				Gui, Show
			}
		}
		Return LargestArea
	}
	
	; Enable / disable controls
	InitializeGUI()
	{
		Global
		GuiControl, Enable%vEnableAll%, vButtonFont
		GuiControl, Enable%vEnableAll%, vUseShadowColor
		GuiControl, Enable%vEnableAll%, vTextShadowColor
		GuiControl, Enable%vEnableAll%, vListShadowColor
		GuiControl, Enable%vEnableAll%, vTextEdit
		GuiControl, Enable%vEnableAll%, vTextUpDown
		GuiControl, Enable%vEnableAll%, vInfinite
		Loop, 4
			GuiControl, Enable%vEnableAll%, vRadio%A_Index%
		GuiControl, Enable%vEnableAll%, vButtonPreview
		
		GuiControl, Enable%vEnableAll%, vTw2
		
		; These only matter if master switch is enabled
		If vEnableAll
		{
			GuiControl, Enable%vUseShadowColor%, vListShadowColor
			
			GuiControl, Disable%vInfinite%, vTextEdit
			GuiControl, Disable%vInfinite%, vTextUpDown
		}
		Return
	}

	; Convert RGB to BGR and vice versa
	ColorConvert(FontColor)
	{
		SetFormat, Integer, H
		FontColor := ((FontColor & 0xFF) << 16 | FontColor & 0xFF00 | (FontColor & 0xFF0000) >> 16) + 0
		SetFormat, Integer, D
		; Pad missing zeros
		Loop % 8 - StrLen(FontColor)
			FontColor := SubStr(FontColor, 1, 2) . "0" . SubStr(FontColor, 3)
		Return FontColor
	}
	
	
	
	; Set song text position in the physical GUI
	SongTextAdjust()
	{
		Local SongBoxX, SongBoxY, SongBoxW, SongBoxH
		If (!b)
			b = 2
		
		WinGetPos, gid%b%X, gid%b%Y, gid%b%W, gid%b%H, % "ahk_id " gid%b%
		WinGetPos, SongBoxX, SongBoxY, SongBoxW, SongBoxH, ahk_id %hSongBox%
		
		If vRadio1		; Top-Left
			SongBoxW := SongBoxH := 0
		Else If vRadio2	; Bottom-Left
			SongBoxW := 0
		Else If vRadio3	; Top-Right
			SongBoxH := 0
						; Bottom-Right needs no adjustment
		
		SongTextX := Round(Round((SongBoxX + SongBoxW - gid%b%X) * RelX))
		SongTextY := Round((SongBoxY + SongBoxH - gid%b%Y) * RelY)
		
		; Needs extra adjustment, don't even ask
		SongTextX -= Floor(((gid%b%X + gid%b%W) - SongBoxX) / ((gid%b%W - 1)/ Round(RelX)))
		
		; If rounding errors have caused text to get outside of monitor bounding rectangle, limit song name position accordingly
		If (SongTextX > gid%b%Right - gid%b%Left)
			SongTextX := gid%b%Right - gid%b%Left
		If (SongTextY > gid%b%Bottom - gid%b%Top)
			SongTextY := gid%b%Bottom - gid%b%Top
		Return
	}

	; Songbox dragging code
	MoveSong(a, MouseX, MouseY)
	{
			Local Tw2X, Tw2Y, SongBoxW, SongBoxH, gid1X, gid1Y
			
			WinGetPos, Tw2X, Tw2Y, , , ahk_id %hTw2% ; Treeview position
			WinGetPos, , , SongboxW, SongboxH, ahk_id %hSongBox% ; Songbox position and dimension
			
			; Get the monitor GUI number under the cursor
			Loop % MonitorC
			{
				a := A_Index + 1
				WinGetPos, gid%a%X, gid%a%Y, gid%a%W, gid%a%H, % "ahk_id " gid%a%
				
				; If cursor is within GUI borders, get the last matching GUI in case there are many (more recent one always overlaps the one before it by like 1px)
				If (gid%a%X <= MouseX) and (gid%a%X + gid%a%W >= MouseX) and (gid%a%Y <= MouseY) and (gid%a%Y + gid%a%H >= MouseY)
					b := a
			}
			a := b
			
			; Set up cursor clipping for the GUI the user clicked at
			NumPut(gid%a%X + SongBoxW / 2 - 2, RECT)
			NumPut(gid%a%Y + SongBoxH / 2 - 2, RECT, 4)
			NumPut(gid%a%X + gid%a%W - SongBoxW / 2 - 3, RECT, 8)
			NumPut(gid%a%Y + gid%a%H - SongBoxH / 2 - 3, RECT, 12)
			DllCall("ClipCursor", int, &RECT)
			clipped = 1
			
			; Position the songbox hor & vert center to (clipped) mouse click coordinates
			MouseGetPos, MouseX, MouseY
			a := MonitorC + 2
			WinMove, % "ahk_id " gid%a%, , MouseX - Tw2X - SM_CXEDGE - SongBoxW / 2, MouseY - Tw2Y - SM_CYEDGE - SM_CYCAPTION - SongBoxH / 2
			
			Loop
			{
				MouseGetPos, MouseX, MouseY
				
				; First time iteration 
				If (A_Index = 1) ;(MouseXPrev = "") and (MouseMoveActive)
					MouseXPrev := MouseX, MouseYPrev := MouseY
				
				; Move song name GUI after the cursor
				WinGetPos, gid%a%X, gid%a%Y, , , % "ahk_id " gid%a% ; Relative to display space point 0, 0
				WinGetPos, Tw2X, Tw2Y, , , ahk_id %hTw2% ; Relative to display space point 0, 0
				WinMove, % "ahk_id " gid%a%, , gid%a%X - Tw2X + MouseX - MouseXPrev - SM_CXEDGE, gid%a%Y - Tw2Y + MouseY - MouseYPrev - SM_CYEDGE ; Relative to Tw2X, Tw2Y

				MouseXPrev := MouseX, MouseYPrev := MouseY
				Sleep, 30
				
				; Break out if button up event has taken place
				If (!MouseMoveActive)
					break
			}
			Return
	}
	
	; Activate Songbox dragging
	BUTTONDOWN(wParam, lParam, msg, hwnd)
	{
			Local MouseX, MouseY, MouseWin, a
			MouseGetPos, MouseX, MouseY, MouseWin
			Loop % MonitorC + 1
			{
				a := A_Index + 1
				If (MouseWin = gid%a%)
				{
					MouseMoveActive = 1
					MoveSong(a, MouseX, MouseY)
					Break
				}
			}
			Return
	}

	; Stop Songbox dragging & remove cursor clipping
	BUTTONUP(wParam, lParam, msg, hwnd)
	{
			global
			If MouseMoveActive
			{
				MouseMoveActive = 0
				MouseXPrev := MouseYPrev := ""
			}
			If clipped
			{
				DllCall("ClipCursor", int, 0)
				clipped := !clipped
			}
			Return
	}

	; Rare mouse events can cause main GUI to lose its active state to one of child GUIs
	NC_ACTIVATE(wParam, lParam, msg, hwnd)
	{
			Local a
			Loop % MonitorC + 1
			{
				a := A_Index + 1
				If (hwnd = gid%a%) and (msg = WM_NCACTIVATE) and (wParam = True) ; Mouse event like Autoscroll (tested with Logitech Setpoint)
					Return DllCall("SetForegroundWindow", int, gid1)
			}
			Return
	}

	; Monitor GUI behavior when clicked
	ACTIVATE(wParam, lParam, msg, hwnd)
	{
			Local a, b, MouseX, MouseY, GuiActive, match = 0 ; For dynamic array gid
			Critical
			Loop % MonitorC + 1 ; Include songbox GUI
			{
				a := A_Index + 1
				If (hwnd = gid%a%) ; If WM_MOUSEACTIVATE was received by GUIs representing monitors or the songbox
				{
					match := a ; Match was found
					Break
				}
			}
			If match
			{
				; Because adjacent GUIs overlap, the latter one being on the top like by 1px
				; Thus, need to run the loop all the way to see which is the last window to contain the click point
				; Consider that window clicked and change colors accordingly
				; This helps in situations where GUI colors are not updated when user clicks at the songbox just at the intersection of two GUIs
				If (a > MonitorC + 1) ; Only if clicked at song box
				{
					MouseGetPos, MouseX, MouseY
					Loop % MonitorC
					{
						a := A_Index + 1
						WinGetPos, gid%a%X, gid%a%Y, gid%a%W, gid%a%H, % "ahk_id " gid%a%
						If  (MouseX >= gid%a%X) and (MouseX <= gid%a%X + gid%a%W) 
						and (MouseY >= gid%a%Y) and (MouseY <= gid%a%Y + gid%a%H)
							GuiActive := a
					}					
					a := GuiActive
				}
				
				Gui, %a%: Color, %GuiActiveColor% ; Swap background color to active
				Gui, %a%: Font, c%FontActiveColor% ; Swap text color to active
				GuiControl, %a%: Font, vText%a% ; Apply text color change
				Loop % MonitorC
				{
					b := A_Index + 1
					If (b != a) ; Change the previous active GUI back to inactive colors
					{
						Gui, %b%: Color, %GuiInActiveColor%
						Gui, %b%: Font, c%FontInActiveColor%
						GuiControl, %b%: Font, vText%b%
					}
				}
				Return MA_NOACTIVATE, DllCall("SetForegroundWindow", int, gid1) ; MUST be this way to work
			}
			Return 1 ; Proceed with default processing
	}

	; Prevent the user from pasting invalid values to Text display duration edit control
	WindowProcEdit(hWnd, uMsg, wParam, lParam)
	{
		Global 
		If (uMsg = WM_PASTE)
		{
			If Clipboard is not integer
			{
				ControlSend, , q, ahk_id %hWnd% ; Send invalid character to invoke warning
				Return
			}
			Else If (Clipboard < 1) or (Clipboard > 30)
			{
				ControlSend, , q, ahk_id %hWnd% ; Send invalid character to invoke warning
				Return
			}
		}
		Return DllCall("CallWindowProc", uint, PrevWindowProcEdit, uint, hWnd, uint, uMsg, uint, wParam, uint, lParam)
	}