LoadSettings()
{
	Local FontColorHTML, SM_CMONITORS = 80
	
	; Get monitor count and dimensions to calculate replacement values for invalid / missing X and Y
	SysGet, MonitorC, %SM_CMONITORS%
	If MonitorC > 96 ; Yeah, sure, but let's be prepared anyway
			MonitorC = 96

	IfExist, %FileName%
	{
		; Font
		IniRead, vEnableAll,		%FileName%, UseTextDspl,UseTextDspl,1
		
		IniRead, FontName,			%FileName%, Font, 		Name, 		Times New Roman
		IniRead, FontStyle,			%FileName%, Font, 		Style, 		4
		IniRead, FontHeight,		%FileName%, Font, 		Size, 		24
		IniRead, FontEffect,		%FileName%, Font, 		Effect, 	0
		IniRead, FontColor,			%FileName%, Font, 		Color, 		0x000000
		
		IniRead, vUseShadowColor,	%FileName%, Outline, 	Use, 		1
		IniRead, vListShadowColor,	%FileName%, Outline, 	Color, 		1
		
		IniRead, vTextUpDown,		%FileName%, Duration, 	Seconds,	5
		IniRead, vInfinite, 		%FileName%, Duration, 	Infinite, 	0
		
		IniRead, vRadio,			%FileName%, Position,	Justify,	4
		IniRead, Monitor,			%FileName%, Position,	Monitor,	1
		IniRead, vStartHidden,		%FileName%, Position,	HideAtStartup, 0
	}
	Else
	{
		AddXY = 1 ; X and Y & Monitor will be tested and added later
		FileAppend,
(
[UseTextDspl]
UseTextDspl=1

[Font]
Name=Times New Roman
Style=4
Size=26
Effect=0
Color=0x000000

[Outline]
Use=1
Color=1

[Duration]
Seconds=5
Infinite=0

[Position]
Justify=4
Monitor=1
Hidden=0
), %FileName%
	}
	
	If vEnableAll not in 0,1
		vEnableAll = 1
		
	If !FontName
		FontName = Times New Roman
	
	If FontStyle not in 0,1,2,4
		FontStyle = 4 ; 0 = no style, 1 = italic, 2 = bold, 4 = italic & bold)
		
	If FontHeight is not integer
		FontHeight = 26
	Else If FontHeight <= 0
		FontHeight = 26
	
	If FontEffect not in 0,1,2,4
		FontEffect = 0 ; 0 = no effect, 1 = strikeout, 2 = underline, 4 = strikeout & underline
	
	FontColorHTML := SubStr(FontColor, 3)
	If (SubStr(FontColor, 1, 2) != "0x") or (StrLen(FontColor) != 8)
		FontColor = 0x000000
	Else If FontColorHTML is not alnum
		FontColor = 0x000000
	Else If FontColorHTML contains G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
		FontColor = 0x000000
		
	If vUseShadowColor not in 0,1
		vUseShadowColor = 1
	
	If vListShadowColor not between 1 and 16
		vListShadowColor = 1
	
	If vTextUpDown is not integer
		vTextUpDown = 5
	Else If vTextUpDown not between 1 and 30
		vTextUpDown = 5
	
	If vInfinite not in 0,1
		vInfinite = 0
		
	If vRadio not in 1,2,3,4
		vRadio4 = 1
	Else
		Loop, 4
			If (A_Index != vRadio)
				vRadio%A_Index% = 0
			Else
				vRadio%A_Index% = 1
	
	If Monitor is not Integer
		Monitor = 1
	Else If (Monitor > MonitorC)
		Monitor = 1
	
	If vStartHidden not in 0,1
		vStartHidden = 0
	
	; X and Y will be tested later in spotify_gui_func.ahk
	Return
}

Display(string,ShowInDisplay = 1, trim = 1)
{
	Local a, TextW, TextH
	Gui, Submit, Nohide
	If vEnableAll
	{
		If trim ; Only if auto-called by song change in Spotify (vs. preview button)
			StringMid, string, string, 11, Strlen(string) ; Remove "Spotify - " from the string
		
		  hDC := DllCall("GetDC", int, gid98) ; Get GUI DC for text drawing
		, DllCall("SetBkMode", int, hDC, int, TRANSPARENT) ; Transparent text background
		
		, hFont := DllCall("CreateFontIndirect", int, &LOGFONT) ; Create font for song info display
		
		, hfontorig := DllCall("SelectObject", int, hDC, int, hfont) ; Select the new font into DC
		, DllCall("GetTextExtentPoint32", int, hDC, str, string, int, StrLen(string), int, &SIZE) ; Get font dimensions
		
		; GUIs to transparency
		WinSet, Transparent, 0, ahk_id %gid98%
		WinSet, Transparent, 0, ahk_id %gid99%

		; Position GUI in the work area corner and set dimensions according to text
		SysGet, mon%ShowInDisplay%, Monitor, %ShowInDisplay%
		
		TextW := NumGet(SIZE) + 8, TextH := NumGet(SIZE, 4)
		
		If vRadio1		; Top-Left
			MonPos := "x" SongTextX + mon%ShowInDisplay%Left " y" SongTextY + mon%ShowInDisplay%Top " w" TextW + 10 " h" TextH " NA"
		Else If vRadio2	; Bottom-Left
			MonPos := "x" SongTextX + mon%ShowInDisplay%Left " y" SongTextY - TextH + mon%ShowInDisplay%Top " w" TextW + 10 " h" TextH " NA"
		Else If vRadio3	; Top-Right
			MonPos := "x" SongTextX - TextW + mon%ShowInDisplay%Left " y" SongTextY + mon%ShowInDisplay%Top " w" TextW + 10 " h" TextH " NA"
		Else   ; vRadio4, Bottom-Right
			MonPos := "x" SongTextX - TextW + mon%ShowInDisplay%Left " y" SongTextY - TextH + mon%ShowInDisplay%Top " w" TextW + 10 " h" TextH " NA"
		
		;Msgbox % SongTextX ", " TextW ", " mon%ShowInDisplay%Left ", " SongTextY ", " TextH ", " mon%ShowInDisplay%Top
		If vUseShadowColor
			Gui, 98: Show, % MonPos
		Gui, 99: Show, % MonPos
		
		; Draw path for SetWindowRgn
		  DllCall("BeginPath", uint, hDC) 
		, DllCall("TextOut", int, hDC, int, 4, int, -2, str, string, int, StrLen(string))
		, DllCall("EndPath", uint, hDC)
		
		, hRgn := DllCall("PathToRegion", int, hDC) ; CENTER text border region
		, hRgn1 := DllCall("CreateRectRgn", int, 1, int, 1, int, 1, int, 1) ; Create inside text region
		, hRgn2 := DllCall("CreateRectRgn", int, 1, int, 1, int, 1, int, 1) ; Create border region
		, hRgn3 := DllCall("CreateRectRgn", int, 1, int, 1, int, 1, int, 1) ; Create another container region for combining
		
		, DllCall("CombineRgn", int, hRgn1, int, hRgn, int, 0, int, RGN_COPY) ; Duplicate region
		, DllCall("CombineRgn", int, hRgn2, int, hRgn, int, 0, int, RGN_COPY) ; 
		, DllCall("CombineRgn", int, hRgn3, int, hRgn, int, 0, int, RGN_COPY) ; 
		
		, DllCall("OffsetRgn", int, hRgn1, int, -1, int, 0) ; Offset to LEFT border
		, DllCall("OffsetRgn", int, hRgn2, int, 1, int, 0) ; Offset to RIGHT border
		, DllCall("CombineRgn", int, hRgn3, int, hRgn1, int, hRgn2, int, RGN_OR) ; Combine LEFT and RIGHT regions together
		
		, DllCall("OffsetRgn", int, hRgn1, int, 1, int, 1) ; Offset TOP text border region
		, DllCall("CombineRgn", int, hRgn2, int, hRgn1, int, hRgn3, int, RGN_OR) ; Combine LEFT&RIGHT and TOP regions together
		
		, DllCall("OffsetRgn", int, hRgn1, int, 0, int, -2) ; Offset BOTTOM text border region
		, DllCall("CombineRgn", int, hRgn3, int, hRgn1, int, hRgn2, int, RGN_OR) ; Combine LEFT&RIGHT&TOP and BOTTOM regions together

		, DllCall("SetWindowRgn", int, gid98, int, hRgn3, int, 1) ; Set region for border
		, DllCall("SetWindowRgn", int, gid99, int, hRgn, int, 1) ; Set region for center
		
		, DllCall("SelectObject", int, hDC, int, hfontorig) ; Retrieve the original font
		, DllCall("DeleteObject", int, hfont) ; Delete text object
		, DllCall("DeleteObject", int, hRgn1) ; Delete regions
		, DllCall("DeleteObject", int, hRgn2)
		
		; After a successful call to SetWindowRgn, the system owns the region specified by the region handle hRgn. The system does not make a copy of the region. Thus, you should not make any further function calls with this region handle. In particular, do not delete this region handle. The system deletes the region handle when it no longer needed.

		, DllCall("ReleaseDC", int, gid98, int, hDC) ; Release DC
		Settimer, Fadein, -1 ;, 1
	}
	Return	
}

Fadein:
	NewFade = 1
	SetTimer, FadeOut, Off
	Tp = 0
	
	Loop % 255 / FadeStep
	{
		Tp += FadeStep
		WinSet, Transparent, %Tp%, ahk_id %gid98%
		WinSet, Transparent, %Tp%, ahk_id %gid99%
		Sleep, 60
	}
	WinSet, Transparent, 255, ahk_id %gid98%
	WinSet, Transparent, 255, ahk_id %gid99%
	If !vInfinite
		SetTimer, Fadeout, % -1000 * vTextUpDown ;, 1
Return

Fadeout:
	NewFade = 0
	Tp = 255

	Loop % 255 / FadeStep
	{
		Tp -= FadeStep
		If NewFade
			Return
		WinSet, Transparent, %Tp%, ahk_id %gid98%
		WinSet, Transparent, %Tp%, ahk_id %gid99%
		Sleep, 60
	}
	Gui, 98: Hide
	Gui, 99: Hide
Return

spotify(sid, byref hhook)
{
	global sclass
		 , getpixel
		 , volupkey
		  
	static spotifyvolx ; The var that contains the current volume prior to muting
	/*
	Forward button:
		0xC6C7C6 equals Enabled forward button background gray pixel (right left to the leftmost small arrow topmost grayish pixel), 32-bit color. 16-bit color: 0xC6C7C6.
		0x7B797B equals Disabled forward button background gray pixel (right left to the leftmost small arrow topmost grayish pixel), 32-bit color. 16-bit color: 0x7B7973.
		0xA0A0A0 is a good value approximately in between these two.
	*/
		 , spotifycolor1 := 0xA0
	/*
	Volume slider:
		Background horizontal center line 32-bit color, left to the position marker: 0x3D3D3D. 16-bit color: 0x393C39
		Background horizontal center line 32-bit color, right to the position marker: 0x323232. 16-bit color: 0x313031
		Darkest pixel of the volume slider position marker horizontal center line 32-bit color: 0xB0B0B0. 16-bit color: 0xB5B2B5
		0x7F7F7F is a good value approximately in between these two
	*/
		 , spotifycolor2 := 0x7F
		 
		 , prevtitle := ""
		 , muted := 0
	
	; Update the Last Found Window here
	if ((title := winget_title(winexist("ahk_id " sid))) <> "Spotify") ; True, if not paused / playback not finished
	{	
		; Check if minimized and restore if so
		; This must be done first in order that wingetpos would retrieve proper dimensions
		winget, state, minmax
		If (state = -1) ; Minimized
		{
			loop
			{
				winhide ; Hiding somehow helps keeping the client inactive
				sleep, 20
				if !dllcall("IsWindowVisible", int, sid)
				{
					; Restore without activating it
					dllcall("ShowWindow", int, sid, int, 4) ; SW_SHOWNOACTIVATE
					sleep, 20
					winget, minmax, minmax
					if (minmax <> -1)
						break
				}
			}
		}
		
		wingetpos, , , w, h
		
		  spotify1x := 81 	; Forward button X
		, spotify1y := h - 24 ; Forward button Y
		, spotify2x := 50 	; Pause button X
		, spotify2y := h - 28 ; Pause button Y
		
		, volumepositions := 9
		, spotifyvol0x := 120 ; The first pixel, counting from left, that can become occupied by the volume position marker
		, spotifyvol1x := 196 ; The last pixel, counting from left, that needs to be checked for position marker when finding out the volume level prior to muting
		, spotifyvoly := h - 21 ; Volume slider y position
		
		, spotifytime0x := 287 ; The spot that, when sent a WM_LBUTTONDOWN, will move song time position marker to 0:00
		
		, hdc := dllcall("GetDC", int, sid)
		
		; Create compatible DC
		, hdccomp := DllCall("CreateCompatibleDC", int, hdc)
		; Create compatible bitmap
		, hbmcomp := DllCall("CreateCompatibleBitmap", int, hdc, int, w, int, h)
		; Select compatible bitmap to compatible DC
		, hbmorig := DllCall("SelectObject", int, hdccomp, int, hbmcomp)
		
		;hidden := 0
		loop ; Check if hidden and show if so
			if !dllcall("IsWindowVisible", int, sid) ; Hidden
			{
				wingetpos, x, y ; Get original position
				winmove, , , -32000, -32000 ; Move way out of the desktop area
				
				; Unhide without activating
				dllcall("ShowWindow", int, sid, int, 8) ; SW_SHOWNA
				;, hidden := 1
				
				winset, bottom ; Move to the bottom of the window stack
				winmove, , , x, y ; Restore original position
				sleep, 20
			}
			else
				break
		
		; Get a memory screen capture now that the client is visible and non-minimized
		printwindow(sid, hdccomp)
		
		; Get forward button state and proceed accordingly
		if (dllcall(getpixel
					, int, hdccomp
					, int, spotify1x
					, int, spotify1y) & 0xff > spotifycolor1) ; If true, forward button is active -> not an ad
		{
			if muted ; Mute needs to be removed
			{
				loop
				{
					if (spotifyvolx <= 128) and (a_index = 1) ; Original volume too close to zero -> must over-increase volume a bit to be able to adjust volume back to original low level
						loop
						{	
							controlsend, , % volupkey ; Send position marker two notches up
							sleep, 20
							  printwindow(sid, hdccomp)
							, a := 1
							loop 2 ; Check two first 9-pixel "volume positions" for the position marker
								if (dllcall(getpixel
									, int, hdccomp
									, int, spotifyvol0x + (a_index - 1) * 9
									, int, spotifyvoly) & 0xFF > spotifycolor2) ; The position marker is still too close to the left edge of volume slider background.
								{
									a := 0
									break
								}
							if a
								break
						}
					; Wait to let the client some time to become responsive to volume adjustment
					if (a_index = 1)
						sleep, 2000
					
					; Move the song position marker back to 0:00
					  post_lbuttondown(spotifytime0x, spotifyvoly)
					, post_lbuttonup(spotifytime0x, spotifyvoly)
					
					loop 2 ; Do twice to hopefully improve reliability
					; Set volume back to original
					  post_lbuttondown(spotifyvolx + 1, spotifyvoly) ; + 1 accounts for the fact that the position marker is not placed right to the click spot but one pixel left to it.
					, post_lbuttonup(spotifyvolx + 1, spotifyvoly)
					
					printwindow(sid, hdccomp)
					
					if (dllcall(getpixel
							, int, hdccomp
							, int, spotifyvol0x
							, int, spotifyvoly) & 0xFF < spotifycolor2) ; The position marker is no more at zero volume position
					or (spotifyvolx <= 124) ; Position marker was originally at zero volume position
						break
				}
				muted := 0
			}
			if (title <> prevtitle)
				  Display(title, b - 1)
				, prevtitle := title
		}
		else if !muted ; An ad!
		{
			; Get original volume
			loop % volumepositions
			{
				if (dllcall(getpixel
					, int, hdccomp
					, int, spotifyvol1x - (a_index - 1) * 9
					, int, spotifyvoly) & 0xff > spotifycolor2) ; If true, a part of the position marker has been discovered
				{
					a := spotifyvol1x - (a_index - 1) * 9
					; Find out the exact location of the position marker at a pixel precision
					loop 5
					{
						if (dllcall(getpixel
							, int, hdccomp
							, int, a -= 2
							, int, spotifyvoly) & 0xff < spotifycolor2) ; If true, we've reached a pixel that's to the left of the position marker left border
						{
							; Must check the next pixel to the right because checks were made in 2-pixel steps
							if (dllcall(getpixel
								, int, hdccomp
								, int, ++a
								, int, spotifyvoly) & 0xff < spotifycolor2) ; If true, this is the background pixel just to the left of the position marker left border
								++a ; Go forward one pixel to get to the first pixel of the position marker left side
							spotifyvolx := a + 4 ; Go four pixels forward to get to the horizontal center of the position marker, which is the current volume level (NOTE: WM_LBUTTONDOWN needs to hit one more pixel right to this spot)
							break
						}
					}
					break
				}
			}
			
			; Remove the WinEvent hook temporarily. Otherwise muting action will cause client title bar text change and the hook function will be called, which is unwanted here.
			unhookwinevent(hhook)
			
			; Mute
			loop
			{
				  post_lbuttondown(spotifyvol0x, spotifyvoly)
				, post_lbuttonup(spotifyvol0x, spotifyvoly)
				sleep, 20
				if (winget_title(sid) = "Spotify") or (a_index = 100) ; Mute action succeeded or too many attempts
				{
					muted := 1
					break
				}
			}
			
			; Press Play
			loop
			{
				controlsend, , {space}
				sleep, 50 ; 100
				if (winget_title() <> "Spotify") ; Play action succeeded
					break
			}
			; Set the WinEvent hook up again
			setwineventhook(sid, hhook)
		}
		
		; Clean-up
		  dllcall("SelectObject", int, hdccomp, int, hbmorig)
		, dllcall("DeleteObject", int, hbmcomp)
		, dllcall("DeleteDC", int, hdccomp)
		, dllCall("ReleaseDC", int, sid, int, hdc)
		
		/*
		if (minmax = -1)
			winminimize
		if hidden
			winhide
		*/
	}	
}