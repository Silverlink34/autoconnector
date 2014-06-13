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
ifexist %a_workingdir%\savedcons
	{
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\savedcons > %a_workingdir%\tmp\connlist
	sleep, 200
	fileread, svdconnlist, %a_workingdir%/tmp/connlist
	stringsplit, connection, svdconnlist, `r,`n
	ifinstring, connection1, %connection1%
		{
		gui, 2:add, button, vButcon1 gConnection1, %Connection1%
		}
	ifinstring, connection2, %connection2%
		{
		gui, 2:add, button, vButcon2 gConnection2, %Connection2%
		}
	ifinstring, connection3, %connection3%
		{
		gui, 2:add, button, vButcon3 gConnection3, %Connection3%
		}
	ifinstring, connection4, %connection4%
		{
		gui, 2:add, button, vButcon4 gConnection4, %Connection4%
		}
	ifinstring, connection5, %connection5%
		{
		gui, 2:add, button, vButcon5 gConnection5, %Connection5%
		}
	ifinstring, connection6, %connection6%
		{
		gui, 2:add, button, vButcon6 gConnection6, %Connection6%
		}
	ifinstring, connection7, %connection7%
		{
		gui, 2:add, button, vButcon7 gConnection7, %Connection7%
		}
	}
return
goto guiclose
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
FileCreateDir, savedcons
FileAppend, %puttydir%\putty %Host1% -pw %Pass1%, %A_workingdir%\savedcons\%Name1%
gui, 2:destroy
goto MainMenu
}
Connection1:
{
msgbox, it worked
}
Connection2:
{
msgbox, it worked
}
Connection3:
{
msgbox, it worked
}
Connection4:
{
msgbox, it worked
}
Connection5:
{
msgbox, it worked
}
Connection6:
{
msgbox, it worked
}
Connection7:
{
msgbox, it worked
}
guiclose: 
exitapp

