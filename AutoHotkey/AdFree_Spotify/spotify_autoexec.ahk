	#NoEnv
	#NoTrayIcon
	#SingleInstance, ignore
	SendMode, Input
	DetectHiddenWindows, On
	SetWinDelay, -1
	setbatchlines, -1
	CoordMode, Mouse, Screen
	
	;  reload_script()
	
	  FileTitle := "LioneZZ AdFree Spotify"
	, FileVersion := " v1.6"
	, FileName := ".\LioneZZ AdFree Spotify.ini"
	
	, FadeStep := 18
	
	, LoadSettings()
	
	, Sclass := "SpotifyMainWindow"
	, Bclass := "SpotifyShadow"

	, Playkey := "{space}"
	, volupkey := "^{up 2}"
	
	#Include spotify_gui_autoexec.ahk

	Initialize = 1 ; Use this to help decide whether or not do Hide at Startup
		GoSub, Open ; Open main GUI
		Gosub, Infinite ; Update song text position
	Initialize = 0 ; No matter the state of Hide at Startup, no more keeping GUI hidden when going through subroutine Open
	if vStartHidden ; Destroy GUIs to release variables
		Loop % MonitorC + 2
			Gui, %A_Index%: Destroy
	
;---------------------------------
;---------------------------------
	
	Gui, 98: +lastfound +AlwaysOnTop +0x2000000 -Sysmenu +E0x20000 +ToolWindow -Caption
	Gui, 98: Color, % GuiColor%vListShadowColor%
	gid98 := WinExist()
	
	Gui, 99: +lastfound +AlwaysOnTop +0x2000000 -Sysmenu +E0x20000 +ToolWindow -Caption
	Gui, 99: Color, % FontColor
	gid99 := WinExist()
	
	
	WinWait, ahk_class %sclass%
	WinGet, sid, ID
	WinGet, spid, PID
	
	  getpixel := dllcall("GetProcAddress", int, hgdi32 := dllcall("LoadLibrary", str, "Gdi32.dll"), str, "GetPixel")
	, printwindow := dllcall("GetProcAddress", int, huser32 := dllcall("LoadLibrary", str, "User32.dll"), str, "PrintWindow")
	, redrawwindow := dllcall("GetProcAddress", int, huser32, str, "RedrawWindow")
	, setwineventhook(sid, hhook)
	;, spotify(sid, hhook) ; Run once on startup to catch a possible advert
	
	settimer, updatesid, -10, -1
	settimer, runstartup, -10 ; Must make this a separate thread because of "critical" in spotify() function
Return


runstartup:
	spotify(sid, hhook)
return

updatesid:
	loop
	{
		winwaitclose, ahk_id %sid%
		unhookwinevent(hhook) ; Remove Winevent hook
		
		winwait, ahk_class %sclass% ; Wait for Spotify to reappear
		setwineventhook(sid := winexist(), hhook) ; Set the Winevent hook up again
	}
return


setwineventhook(hwnd, byref hhook)
{
	hhook := dllcall("SetWinEventHook"
				, int, 0x800C ; EVENT_OBJECT_NAMECHANGE
				, int, 0x800C ; EVENT_OBJECT_NAMECHANGE
				, int, 0
				, int, registercallback("wineventproc", "fast", 7, hwnd)
				, int, getprocessid(hwnd)
				, int, 0
				, int, 0x2) ; WINEVENT_SKIPOWNPROCESS | WINEVENT_OUTOFCONTEXT
}

unhookwinevent(byref hhook)
{
	if hhook
		if dllcall("UnhookWinEvent", int, hhook)
			hhook := 0
}

wineventproc(hhook, event, hwnd, idobject, idchild, eventthread, eventtime)
{
	if (hwnd = a_eventinfo)
		spotify(hwnd, hhook)
}

getprocessid(hwnd)
{
	dllcall("GetWindowThreadProcessId"
			, int, hwnd
			, intp, pid)
	return % pid
}

printwindow(hwnd, hdccomp)
{
	global printwindow, redrawwindow
	  dllcall(printwindow, int, hwnd, int, hdccomp, int, 0)
	; Must redraw or some Spotify client gui elements will not draw properly
	, dllcall("RedrawWindow", int, hwnd, int, 0, int, 0, int, 0x1 | 0x8 | 0x100) ; RDW_INVALIDATE | RDW_VALIDATE | RDW_UPDATENOW
}

winget_title(hwnd = "")
{
	wingettitle, title, % hwnd ? "ahk_id " hwnd : ""
	return % title
}

post_lbuttondown(x, y, wintitle = "", vkeys = "")
{
	postmessage, 0x201, % vkeys <> "" ? 1 | vkeys : 1, x | (y << 16), , % wintitle 
}

post_lbuttonup(x, y, wintitle = "", vkeys = "")
{
	postmessage, 0x202, % vkeys,  x | (y << 16), , % wintitle
}

#Include .\spotify_func.ahk
#Include .\spotify_gui_func.ahk

