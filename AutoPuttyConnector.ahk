;GUI for auto Putty SSH connections.Created by Brandon Galiher.

;gui, add, edit, vtxt1, input text here
; empty window sample

Gui, 1:Show, w768 h485, Auto Putty Connector
gui, 1:font, s16,
GUI, 1:Add, Text,,Thank you for using Brandon's Auto Putty Connector.
GUI, 1:Add, Text,,This GUI will store SSH information and auto-connect you to specified servers.
gui, 1:add, button, vButok1 gMainMenu, OK
gui, 1:add, button, vButrddisc gDisclaimer, Read Disclaimer
return

Disclaimer:
{
msgbox, I do not own AutoHotkey, Putty, or any other programs this script calls upon. `nI am simply the author of the script. `n`nI am also not responsible for any damage to your computer, you are the user that decided to trust my program.
goto MainMenu
}

MainMenu:
gui, 1:submit
gui, 2:show, w768 h485
gui, 2:font, s16,
GUI, 2:Add, Text,,Choose an appropriate option.


;Detectsettings:
;{
;gui, 1:submit
;gui, 2:show, w768 h485
;gui, 2:font, s16,
;GUI, 2:Add, Text,,Checking to see if Putty is installed.
;sleep, 2000
;ifexist C:\Program Files (x86)\PuTTY
;	GUI, 2:Add, Text,, Found Putty in 32bit folder! && goto Use32bitdir
;ifexist C:\Program Files\PuTTY
;	GUI, 2:Add, Text,, Found Putty in 32bit OS folder! && goto Use 32bitosdir
;msgbox, Could not find Putty in default location. Using included version of Putty for connections.
;goto guiclose
;}

;Use32bitdir:
;{
;gui, 2:cancel
;gui, 3:show, w768 h485
;gui, 3:font, s16,
;GUI, 3:Add, Text,,Will you be using special ssh functions such as x11 forwarding or ssh tunnels?
;gui, 3:add, button, vButyes1 gSetupprofiles, Yes && gui, 3:add, button, vButno1 gContinue1, No
;Continue1:
;gui, 3:destroy
;gui, 3:show, w768 h485
;gui, 3:font, s16,
;GUI, 3:Add, Text,,
guiclose: 
exitapp

