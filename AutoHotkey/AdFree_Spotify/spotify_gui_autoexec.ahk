
GuiW = 700 			; in pxs
GuiH = 497 			;
Margins = 10 		; in pxs, for both Treeview sides
Tw1W = 27			; Treeview width relative to GUI, in percents
Tw1W := Round(Tw1W / 100 * (GuiW - 2 * Margins))
Tw2WInit := Tw2HInit := GuiW - Tw1W - 3 * Margins

Tw2Wtrim = 6		; Trim constant for Treeview
Tw2Htrim = 5		;

TwColor2 = Gray		; Treeview 2 backgnd color

GuiActiveColor = Silver
GuiInActiveColor = White

FontActiveColor = White
FontInActiveColor = 898989

If !A_IsCompiled
	Menu, Tray, Icon, Lionezz spotify.ico, 1, 1

; ------------------------------------------------------------------------------------------------
;	CONSTANTS
; ------------------------------------------------------------------------------------------------
	#Include spotify_gui_constants.ahk

	; Tray menu creation
;if a_iscompiled
	Menu, Tray, NoStandard
	
Menu, Tray, Add, Open
Menu, Tray, Default, Open
Menu, Tray, Add, Hide at Startup, HideAtStartup
Menu, Tray, Add, About
Menu, Tray, Add
Menu, Tray, Add, Exit, OnExit, 1
Menu, Tray, Tip, % FileTitle FileVersion
if vStartHidden
	Menu, Tray, Check, Hide at Startup	
Menu, Tray, Icon
