sMENUNAME := VarSetCapacity(MENUNAME, 10, 0)
VarSetCapacity(SIZE, 8, 0)
sCHOOSEFONT := VarSetCapacity(CHOOSEFONT, 60, 0)
VarSetCapacity(LOGFONT, 28 + 32, 0)
VarSetCapacity(RECT, 16)
VarSetCapacity(POINT, 8)
VarSetCapacity(TRACKMOUSEEVENT, 16, 0)

; CHOOSEFONT
	NumPut(sCHOOSEFONT, CHOOSEFONT) ; lStructSize
	NumPut(gid1, CHOOSEFONT, 4) ; hwndOwner
	;NumPut(0, CHOOSEFONT, 8) ; hDC
	NumPut(&LOGFONT, CHOOSEFONT, 12) ; lpLogFont
	NumPut(FontHeight * 10, CHOOSEFONT, 16) ; iPointSize
	NumPut(CF_INITTOLOGFONTSTRUCT | CF_EFFECTS | CF_FORCEFONTEXIST | CF_SCREENFONTS | CF_SCALABLEONLY, CHOOSEFONT, 20) ; Flags
	NumPut(ColorConvert(FontColor), CHOOSEFONT, 24) ; rgbColors
	;NumPut(0, CHOOSEFONT, 28) ; lCustData
	;NumPut(0, CHOOSEFONT, 32) ; lpfnHook
	;NumPut(0, CHOOSEFONT, 36) ; lpTemplateName
	;NumPut(0, CHOOSEFONT, 40) ; hInstance
	;NumPut(0, CHOOSEFONT, 44) ; lpszStyle
	;NumPut(0, CHOOSEFONT, 48) ; nFontType
	;NumPut(0, CHOOSEFONT, 50) ; Missing alignment, see CommDlg.h
	;NumPut(0, CHOOSEFONT, 52) ; nSizeMin
	;NumPut(0, CHOOSEFONT, 56) ; nSizeMax

; LOGFONT
	hDC := DllCall("GetDC", int, gid1)
	NumPut(-1 * DllCall("MulDiv", int, FontHeight, int, DllCall("GetDeviceCaps", int, hDC, int, LOGPIXELSY), int, 72), LOGFONT, 0) ; lfHeight
	;NumPut(-1 * DllCall("MulDiv", int, FontWidth, int, DllCall("GetDeviceCaps", int, hDC, int, LOGPIXELSX), int, 72), LOGFONT, 4)  ; lfWidth
	;NumPut(0, LOGFONT, 8) 			; lfEscapement
	;NumPut(0, LOGFONT, 12) 			; lfOrientation
	NumPut(FontStyle & 0x4 ? FW_BOLD : FontStyle & 0x2 ? FW_BOLD : FW_REGULAR, LOGFONT, 16) ; lfWeight
	NumPut(FontStyle & 0x4 ? 1 : FontStyle & 0x1 ? 1 : 0, LOGFONT, 20, "UChar") ; lfItalic
	NumPut(FontEffect & 0x4 ? 1 : FontEffect & 0x2 ? 1 : 0, LOGFONT, 21, "UChar") ; lfUnderline
	NumPut(FontEffect & 0x4 ? 1 : FontEffect & 0x1 ? 1 : 0, LOGFONT, 22, "UChar") ; lfStrikeOut
	NumPut(1, LOGFONT, 23, "UChar") ; lfCharSet
	;NumPut(7, LOGFONT, 24, "UChar") ; lfOutputPrecision
	;NumPut(0, LOGFONT, 25, "UChar") ; lfClipPrecision
	NumPut(0x4, LOGFONT, 26, "UChar") ; lfQuality
	straddr := NumPut(0, LOGFONT, 27, "UChar") ; lfPitchAndFamily
	DllCall("lstrcpy", int, straddr, str, FontName) ; lfFaceName
	DllCall("ReleaseDC", int, gid1, int, hDC)

; TRACKMOUSEEVENT
	NumPut(16, TRACKMOUSEEVENT) ; cbSize
	NumPut(TME_LEAVE, TRACKMOUSEEVENT, 4) ; dwFlags
	;NumPut(, TRACKMOUSEEVENT, 8) ; hwndTrack
	;NumPut(, TRACKMOUSEEVENT, 12) ; dwHoverTime