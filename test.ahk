Gui, Add, Tab2,, Tab1|Tab2|Tab3|Tab4

Gui Show

SetTimer, GetTab, 100

Return



GetTab:
ControlGet, TabNumber, Tab,, SysTabControl321,A

ToolTip, You are on Tab %TabNumber%.`nClick another one.

Return



ESC::ExitApp	; <-- Press escape to exit.