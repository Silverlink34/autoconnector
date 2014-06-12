;GUI for auto Putty SSH connections.Created by Brandon Galiher.

;Implemented functions listed here


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
}

MainMenu:
{
gui, 1:submit
gui, 2:show, w768 h485
gui, 2:font, s16,
GUI, 2:Add, Text,,Create a new connection or choose a saved connection.
ifexist C:\Program Files (x86)\PuTTY
	{
	GUI, 2:Add, Text,,Using locally installed version of Putty. 
	puttydir = C:\Program Files (x86)\PuTTY
	}
ifexist C:\Program Files\PuTTY
	{
	GUI, 2:Add, Text,,Using locally installed version of Putty.
	puttydir = C:\Program Files\PuTTY
	}
ifnotinstring, puttydir, Program
	{
	GUI, 2:Add, Text,,Could not find default installation of PuTTY. Using included PuTTY.
	puttydir = %A_WorkingDir%\PuTTY
	}
gui, 2:add, Button, vButcreateconn gCreateconnection, Create Connection
ifexist %a_workingdir%\saveddata
	{
	}
return
}

Createconnection:
{
gui, 2:submit
gui, 3:show, w768 h485
gui, 3:font, s16,
GUI, 3:Add, Text,,Enter connection details. Credentials are encrypted and saved.
GUI, 3:Add, Text,,Connection Name
gui, 3:add, edit,w300 vName1,My SSH Connection
GUI, 3:Add, Text,,Username, host and port
gui, 3:add, edit,w300 vHost1, user@server:port
GUI, 3:Add, Text,,SSH password
gui, 3:add, edit,password w240 vPass1,
gui, 3:add, button, vButsave1 gSaveconnection, Save Connection
return
 }

Saveconnection:
{
gui, 3:submit
FileCreateDir, saveddata
FileAppend, %puttydir%\putty %Host1% -pw %Pass1%, %A_workingdir%\saveddata\%Name1%
gui, 2:destroy
goto MainMenu
}

guiclose: 
exitapp

