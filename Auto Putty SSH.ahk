; Generated using SmartGUI Creator 4.0
Gui, Show, x375 y191 h420 w523, Auto Putty Connector
gui, 1:font, s16,
GUI, 1:Add, Text,,Thank you for using Brandon's Auto Putty Connector.
GUI, 1:Add, Text,,This GUI will store SSH information and auto-connect you to specified servers.
gui, 1:add, button, vButok1 gMainMenu, OK
gui, 1:add, button, vButrddisc gDisclaimer, Read Disclaimer
Return

Disclaimer:
{
msgbox, I do not own AutoHotkey, Putty, or any other programs this script calls upon. `nI am simply the author of the script. `n`nI am also not responsible for any damage to your computer, you are the user that decided to trust my program.
goto MainMenu
}
GuiClose:
ExitApp