;GUI for auto Putty SSH connections.Created by Brandon Galiher.

;encryption functions are at bottom of script.

;Parameters for the script listed here
#SingleInstance, Force ;if the script is ran and it was already running, this will cause it to reload itself.
#NoTrayIcon ;Kinda self explanatory.
#NoEnv ;supposed to make compatibility better

;Check for config.txt options
fileread, config, config.txt
ifinstring, config, skipenabled
	gosub MainMenu
else
	gosub guistart
return

goto guistart ;keeps script from auto-running the hotkey label
;hotkey label for when box is checked
enablehotkey:
fileappend,	`nhotkeyenabled, %a_workingdir%\config.txt
gui, 2:destroy
goto, mainmenu
return


;Start of GUI below here
guistart:
Gui, 1:Show, w768 h485, Auto Putty Connector
gui, 1:font, s16,
GUI, 1:Add, Text,,Thank you for using Brandon's Auto Putty Connector.
GUI, 1:Add, Text,,This GUI will store SSH information and auto-connect you to specified servers.
GUI, 1:Add, Text,,Saved passwords are encrypted with 128bit encryption method.
GUI, 1:Add, Text,,Connections are saved to savedconns folder.
gui, 1:add, button, vButok1 gMainMenu, OK
gui, 1:add, button, vButrddisc gDisclaimer, Read Disclaimer
;Option to skip intro/disclaimer
gui, 1:add, checkbox, vskipintro, Skip this screen on next run?
exit

Disclaimer:
{
msgbox, I do not own AutoHotkey, Putty, or any other programs this script calls upon. `nI am simply the author of the script. `n`nI am also not responsible for any damage to your computer, you are the user that decided to trust my program.
gui, 1:destroy
gosub guistart
}

MainMenu:
gui, 1:submit
ifequal, skipintro, 1
{
	fileappend, skipenabled, %a_workingdir%\config.txt
}
gui, 2:show, w768 h485
gui, 2:font, s16,
GUI, 2:Add, Text,,Please create a new connection or choose a saved connection.
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
gui, 2:add, Button, border vButcreateconn gCreateconnection, Create Connection
gui, 2:add, text,,_________________________________________________________________________________
;Detect existing/saved connections and create buttons for them	
ifexist %a_workingdir%\savedcons
{
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\savedcons > %a_workingdir%\tmp\connectionlist,, hide
	sleep, 200
	fileread, vconnlist, %a_workingdir%/tmp/connectionlist
	stringreplace, vconnlist, vconnlist,`r`n,],all
	stringsplit, connection, vconnlist,]
	ifgreater, connection0, 1
	{
		gui, 2:add, button, section Y+20 vButcon1 gConnection1, %Connection1%
	}
	ifgreater, connection0, 2
	{
		gui, 2:add, button, vButcon2 gConnection2, %Connection2%
	}
	ifgreater, connection0, 3
	{
		gui, 2:add, button, vButcon3 gConnection3, %Connection3%
	}
	ifgreater, connection0, 4
	{
		gui, 2:add, button, vButcon4 gConnection4, %Connection4%
	}
	ifgreater, connection0, 5
	{
		gui, 2:add, button, vButcon5 gConnection5, %Connection5%
	}
	ifgreater, connection0, 6
	{
		gui, 2:add, button, ys vButcon6 gConnection6, %Connection6%
	}
	ifgreater, connection0, 7
	{
		gui, 2:add, button, vButcon7 gConnection7, %Connection7%
	}
	ifgreater, connection0, 8
	{
		gui, 2:add, button, vButcon8 gConnection8, %Connection8%
	}
	ifgreater, connection0, 9
	{
		gui, 2:add, button, vButcon9 gConnection9, %Connection9%
	}
	ifgreater, connection0, 10
	{
		gui, 2:add, button, vButcon10 gConnection10, %Connection10%
	}
	Fileremovedir, tmp, 1	
}
Return


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
	exit
}


Saveconnection:
{
	gui, 3:submit
	FileCreateDir, savedcons
	FileAppend, %puttydir%\putty %Host1% -pw %Pass1%, %A_workingdir%\savedcons\%Name1%
	Fileread, data, %A_workingdir%\savedcons\%Name1%
	Filedelete, %A_workingdir%\savedcons\%Name1%
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%Name1%
	gui, 2:destroy
	gui, 3:destroy
	gosub MainMenu
}


return ;keeps the script from running Connection1 when it gets to it
Connection1:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection1%
	Filedelete, %A_workingdir%\savedcons\%connection1%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection1%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection1%
	Fileread, data, %A_workingdir%\savedcons\%connection1%
	filedelete, %A_workingdir%\savedcons\%connection1%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection1%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

Connection2:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection2%
	Filedelete, %A_workingdir%\savedcons\%connection2%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection2%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection2%
	Fileread, data, %A_workingdir%\savedcons\%connection2%
	filedelete, %A_workingdir%\savedcons\%connection2%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection2%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

Connection3:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection3%
	Filedelete, %A_workingdir%\savedcons\%connection3%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection3%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection3%
	Fileread, data, %A_workingdir%\savedcons\%connection3%
	filedelete, %A_workingdir%\savedcons\%connection3%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection3%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

Connection4:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection4%
	Filedelete, %A_workingdir%\savedcons\%connection4%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection4%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection4%
	Fileread, data, %A_workingdir%\savedcons\%connection4%
	filedelete, %A_workingdir%\savedcons\%connection4%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection4%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

Connection5:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection5%
	Filedelete, %A_workingdir%\savedcons\%connection5%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection5%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection5%
	Fileread, data, %A_workingdir%\savedcons\%connection5%
	filedelete, %A_workingdir%\savedcons\%connection5%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection5%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

Connection6:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection6%
	Filedelete, %A_workingdir%\savedcons\%connection6%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection6%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection6%
	Fileread, data, %A_workingdir%\savedcons\%connection6%
	filedelete, %A_workingdir%\savedcons\%connection6%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection6%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

Connection7:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection7%
	Filedelete, %A_workingdir%\savedcons\%connection7%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection7%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection7%
	Fileread, data, %A_workingdir%\savedcons\%connection7%
	filedelete, %A_workingdir%\savedcons\%connection7%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection7%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

Connection8:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection8%
	Filedelete, %A_workingdir%\savedcons\%connection8%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection8%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection8%
	Fileread, data, %A_workingdir%\savedcons\%connection8%
	filedelete, %A_workingdir%\savedcons\%connection8%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection8%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

connection9:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection9%
	Filedelete, %A_workingdir%\savedcons\%connection9%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection9%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection9%
	Fileread, data, %A_workingdir%\savedcons\%connection9%
	filedelete, %A_workingdir%\savedcons\%connection9%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection9%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return

connection10:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\savedcons\%connection10%
	Filedelete, %A_workingdir%\savedcons\%connection10%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\savedcons\%connection10%
	Fileread, sshconnect, %A_workingdir%\savedcons\%connection10%
	Fileread, data, %A_workingdir%\savedcons\%connection10%
	filedelete, %A_workingdir%\savedcons\%connection10%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\savedcons\%connection10%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
return


;Encrypt and Decrypt Functions listed here

Decrypt(Data,Pass) {
	b := 0, j := 0, x := "0x"
	VarSetCapacity(Result,StrLen(Data)//2)
	Loop 256
		a := A_Index - 1
		,Key%a% := Asc(SubStr(Pass, Mod(a,StrLen(Pass))+1, 1)) 
		,sBox%a% := a
	Loop 256
		a := A_Index - 1
		,b := b + sBox%a% + Key%a%  & 255
		,sBox%a% := (sBox%b%+0, sBox%b% := sBox%a%) ; SWAP(a,b)
	Loop % StrLen(Data)//2
		i := A_Index  & 255
		,j := sBox%i% + j  & 255
		,k := sBox%i% + sBox%j%  & 255
		,sBox%i% := (sBox%j%+0, sBox%j% := sBox%i%) ; SWAP(i,j)
		,Result .= Chr((x . SubStr(Data,2*A_Index-1,2)) ^ sBox%k%)
   	Return Result
}
Return

Encrypt(Data,Pass) { 
	Format := A_FormatInteger 
	SetFormat Integer, Hex 
	b := 0, j := 0 
	VarSetCapacity(Result,StrLen(Data)*2) 
	Loop 256 
		a := A_Index - 1 
		,Key%a% := Asc(SubStr(Pass, Mod(a,StrLen(Pass))+1, 1)) 
		,sBox%a% := a 
	Loop 256 
		a := A_Index - 1 
		,b := b + sBox%a% + Key%a%  & 255 
		,sBox%a% := (sBox%b%+0, sBox%b% := sBox%a%) ; SWAP(a,b) 
	Loop Parse, Data 
		i := A_Index & 255 
		,j := sBox%i% + j  & 255 
		,k := sBox%i% + sBox%j%  & 255 
		,sBox%i% := (sBox%j%+0, sBox%j% := sBox%i%) ; SWAP(i,j) 
		,Result .= SubStr(Asc(A_LoopField)^sBox%k%, -1, 2) 
	StringReplace Result, Result, x, 0, All 
	SetFormat Integer, %Format% 
	Return Result 
}

GuiEscape:
GuiClose:
2guiclose:
3guiclose:
ExitApp

