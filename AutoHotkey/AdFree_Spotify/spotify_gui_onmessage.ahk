OnMessage(WM_MOUSEACTIVATE, 	"ACTIVATE") 		; LButton, MButton, RButton activation
OnMessage(WM_MOUSELEAVE, 		"WM_MOUSELEAVE") 	; For about dialog controls to change the mouse cursor
OnMessage(WM_NCACTIVATE,		"NCACTIVATE") 		; Mouse event like Autoscroll (tested with Logitech Setpoint)
;WM_SETCURSOR has been moved to About subroutine in spotify_gui_func.ahk
;OnMessage(WM_SETCURSOR, 		"WM_SETCURSOR") 	; Keep changing the cursor while its over the control
;-------------------------------------------
OnMessage(WM_LBUTTONDOWN, 		"BUTTONDOWN")
OnMessage(WM_LBUTTONDBLCLK, 	"BUTTONDOWN")
OnMessage(WM_NCLBUTTONDOWN, 	"BUTTONDOWN")
OnMessage(WM_NCLBUTTONDBLCLK, 	"BUTTONDOWN")

OnMessage(WM_RBUTTONDOWN, 		"BUTTONDOWN")
OnMessage(WM_RBUTTONDBLCLK, 	"BUTTONDOWN")
OnMessage(WM_NCRBUTTONDOWN, 	"BUTTONDOWN")
OnMessage(WM_NCRBUTTONDBLCLK, 	"BUTTONDOWN")

OnMessage(WM_MBUTTONDOWN, 		"BUTTONDOWN")
OnMessage(WM_MBUTTONDBLCLK, 	"BUTTONDOWN")
OnMessage(WM_NCMBUTTONDOWN, 	"BUTTONDOWN")
OnMessage(WM_NCMBUTTONDBLCLK, 	"BUTTONDOWN")
;-------------------------------------------
OnMessage(WM_LBUTTONUP, 		"BUTTONUP")
OnMessage(WM_NCLBUTTONUP, 		"BUTTONUP")

OnMessage(WM_RBUTTONUP, 		"BUTTONUP")
OnMessage(WM_NCRBUTTONUP, 		"BUTTONUP")

OnMessage(WM_MBUTTONUP, 		"BUTTONUP")
OnMessage(WM_NCMBUTTONUP, 		"BUTTONUP")
;-------------------------------------------