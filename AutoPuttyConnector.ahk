;GUI for auto Putty SSH connections.Created by Brandon Galiher.

;encryption functions are at bottom of script.

;Parameters for the script listed here
#SingleInstance, Force ;if the script is ran and it was already running, this will cause it to reload itself.
#NoTrayIcon ;Kinda self explanatory.
#NoEnv ;supposed to make compatibility better

;Create working dir under My Documents
filecreatedir, %a_mydocuments%/AutoConnector

;Set working directory to created dir ^^
SetWorkingDir %a_mydocuments%/AutoConnector

;Check for config.txt options
fileread, config, config.txt
ifinstring, config, skipenabled
	gosub MainMenu
else
	gosub guistart
return

;Start of GUI below here
guistart:
Gui, 1:Show, w768 h485, Auto Putty Connector
gui, 1:font, s16,
GUI, 1:Add, Text,,Thank you for using Brandon's Auto Putty Connector.
GUI, 1:Add, Text,,This GUI will store SSH information and auto-connect you to specified servers.
GUI, 1:Add, Text,,Saved passwords are encrypted with 128bit encryption method.
GUI, 1:Add, Text,,All used files are stored under My Documents/AutoConnector.
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
if rdpenabled = 1
{
	sshenabled = 0
	gosub mainmenustart
}
else
	sshenabled = 1
mainmenustart:
;msgbox, ssh=%sshenabled% rdp=%rdpenabled%
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
	puttydir = C:\Program Files (x86)\PuTTY
}
ifexist C:\Program Files\PuTTY
{
	puttydir = C:\Program Files\PuTTY
}
ifnotinstring, puttydir, Program
{
	filecreatedir, %a_workingdir%\programbin
	puttydir = %A_WorkingDir%\programbin
	fileinstall, putty.exe,%a_workingdir%\programbin\putty.exe,1
}
gui, 2:add, Button,section border vButcreateconn gCreateconnection, Create Connection
gui, 2:add, button,x+60 border vButdeleteconn gDeleteconnection, Delete Connection
gui, 2:add, text,xs,_________________________________________________________________________________
if sshenabled = 1
	gui, 2:add, radio,section checked1 vsshconn gcheckssh,SSH
else
	gui, 2:add, radio,section vsshconn gcheckssh,SSH
if rdpenabled = 1
	gui, 2:add, radio,ys checked1 vrdpconn gcheckrdp,RDP
else
	gui, 2:add, radio,ys vrdpconn gcheckrdp,RDP
ifequal, checkedbutton,telnet
	gui, 2:add, radio,ys checked1 vtelnetconn,Telnet
else
	gui, 2:add, radio,ys vtelnetconn,Telnet
ifequal, checkedbutton,vnc
	gui, 2:add, radio, ys checked1 vvncconn,VNC
else
	gui, 2:add, radio,ys vvncconn,VNC
gui, 2:add, text,xs section,_________________________________________________________________________________
gui, 2:submit, nohide
if sshenabled = 1 ;this is here because SSH is the default radio button checked and I want it to default show ssh connections
	gosub detectssh
if rdpenabled = 1
	gosub detectrdp
exit
;Detect existing/saved SSH connections and create buttons for them
Checkssh:
{
gui, 2:destroy
sshenabled = 1
rdpenabled = 0
gosub mainmenu
}
return
Checkrdp:
{
gui, 2:destroy
rdpenabled = 1
gosub mainmenu
}
return
Detectssh:
ifexist %a_workingdir%\SavedConnections\SSH
{	
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\SSH > %a_workingdir%\tmp\sshlist,, hide
	sleep, 200
	Loop, read, %A_workingdir%\tmp\sshlist
	{
		if a_index = 1
		{
			SSH1 = %a_loopreadline%
			gui, 2:add, button,vbutssh1 section gSSH1, %a_loopreadline%
			continue
		}
		if a_index = 6
		{
			SSH6 = %a_loopreadline%
			gui, 2:add, button,vbutssh6 ys gSSH6, %a_loopreadline%
			continue
		}
		SSH%a_index% = %a_loopreadline%
		gui, 2:add, button,vbutssh%a_index% gSSH%a_index%, %a_loopreadline%
		if a_index = 10
			break
	}
	Fileremovedir, tmp, 1	
}
Return

Detectrdp:
ifexist %a_workingdir%\SavedConnections\RDP
{	
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\RDP > %a_workingdir%\tmp\rdplist,, hide
	sleep, 200
	Loop, read, %A_workingdir%\tmp\rdplist
	{
		if a_index = 1
		{	
			RDP1 = %a_loopreadline%
			gui, 2:add, button,vbutrdp1 section grdp1, %a_loopreadline%
			continue
		}
		if a_index = 6
		{
			RDP6 = %a_loopreadline%
			gui, 2:add, button,vbutrdp6 ys grdp6, %a_loopreadline%
			continue
		}
		RDP%a_index% = %a_loopreadline%
		gui, 2:add, button,vbutrdp%a_index% grdp%a_index%, %a_loopreadline%
		if a_index = 10
			break
	}
	Fileremovedir, tmp, 1	
}
return
Createconnection:

if crdpenabled = 1
{
	csshenabled = 0
	gosub createconnectionstart
}
else
	csshenabled = 1
	
createconnectionstart:
gui, 2:submit
gui, 3:show, w768 h485
gui, 3:font, s16,
GUI, 3:Add, Text,,Choose a protocol type and enter connection details.`nCredentials are saved and encrypted immediately.
gui, 3:add,button,border x230 vreturnmainmenu gcrereturnmainmenu,Cancel
gui, 3:add, text,xs y103,_________________________________________________________________________________
if csshenabled = 1
	gui, 3:add, radio,section checked1 vcsshconn gccheckssh,SSH
else
	gui, 3:add, radio,section vcsshconn gccheckssh,SSH
if crdpenabled = 1
	gui, 3:add, radio,ys checked1 vcrdpconn gccheckrdp,RDP
else
	gui, 3:add, radio,ys vcrdpconn gccheckrdp,RDP
if ctelnetenabled = 1
	gui, 3:add, radio,ys checked1 vctelnetconn,Telnet
else
	gui, 3:add, radio,ys vctelnetconn,Telnet
if cvncenabled = 1
	gui, 3:add, radio, ys checked1 vcvncconn,VNC
else
	gui, 3:add, radio,ys vcvncconn,VNC
gui, 3:add, text,xs section,_________________________________________________________________________________
gui, 3:submit, nohide
if csshenabled = 1 ;this is here because SSH is the default radio button checked and I want it to default show ssh connections
	gosub createssh
if crdpenabled = 1
	gosub createrdp
exit

CCheckssh:
{
gui, 3:destroy
csshenabled = 1
crdpenabled = 0
gosub createconnection
}
return
CCheckrdp:
{
gui, 3:destroy
crdpenabled = 1
gosub createconnection
}
return

Createssh:
GUI, 3:Add, Text,xs section,Connection Name
gui, 3:add, edit,w300 vsshname,My SSH Connection
GUI, 3:Add, Text,,Username, host and port
gui, 3:add, edit,w300 vsshserver, user@server:port
GUI, 3:Add, Text,,SSH password
gui, 3:add, edit,password w240 vsshpass,
gui, 3:add, button,border x20 y74 vButsave1 gsavessh, Save Connection
exit

Createrdp:
gui, 3:add, text,xs section,Connection Name
gui, 3:add, edit,w300 vrdpname,My RDP Connection
gui, 3:add, text,,Server domain or public ip and port
gui, 3:add, edit,w300 vrdpserver,server:port
gui, 3:add, text,,Username and Password
gui, 3:add, edit,w300 vrdpuser,username
gui, 3:add, edit,w300 x+30 password vrdppass,password
gui, 3:add, button,border x20 y74 vButsave2 gsaverdp, Save Connection
exit

crereturnmainmenu:
gui, 2:destroy
gui, 3:destroy
gosub mainmenu
exit


Savessh:
{
	gui, 3:submit
	FileCreateDir, SavedConnections
	FileCreateDir, SavedConnections\SSH
	FileAppend, %puttydir%\putty %sshserver% -pw %sshpass%, %A_workingdir%\SavedConnections\SSH\%sshname%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%sshname%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%sshname%
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%sshname%
	gui, 2:destroy
	gui, 3:destroy
	gosub MainMenu
}
return

Saverdp:
{
	gui, 3:submit
	filecreatedir, %a_workingdir%\programbin
	fileinstall, rdp.exe,%a_workingdir%\programbin\rdp.exe,1
	FileCreateDir, SavedConnections
	FileCreateDir, SavedConnections\RDP
	FileAppend, %a_workingdir%\programbin\rdp /v:%rdpserver% /u:%rdpuser% /p:%rdppass%, %A_workingdir%\SavedConnections\RDP\%rdpname%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%rdpname%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%rdpname%
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%rdpname%
	gui, 2:destroy
	gui, 3:destroy
	gosub MainMenu
}
return
Deleteconnection:
if drdpenabled = 1
{
	dsshenabled = 0
	gosub delmenustart
}
else
	dsshenabled = 1
	
delmenustart:
;msgbox, ssh=%sshenabled% rdp=%rdpenabled%
gui, 2:submit
gui, 2:destroy
gui, 4:show, w768 h485
gui, 4:font, s16,
gui, 4:add, text,cRed,You are in delete connection mode. Click a connection to remove it.
gui, 4:add, button, border vbutreturn gdelreturnmainmenu,Return to Main Menu
gui, 4:add, text,xs,_________________________________________________________________________________
if dsshenabled = 1
	gui, 4:add, radio,section checked1 vdsshconn gdcheckssh,SSH
else
	gui, 4:add, radio,section vdsshconn gdcheckssh,SSH
if drdpenabled = 1
	gui, 4:add, radio,ys checked1 vdrdpconn gdcheckrdp,RDP
else
	gui, 4:add, radio,ys vdrdpconn gdcheckrdp,RDP
ifequal, checkedbutton,telnet
	gui, 4:add, radio,ys checked1 vdtelnetconn,Telnet
else
	gui, 4:add, radio,ys vdtelnetconn,Telnet
ifequal, checkedbutton,vnc
	gui, 4:add, radio, ys checked1 vdvncconn,VNC
else
	gui, 4:add, radio,ys vdvncconn,VNC
gui, 4:add, text,xs section,_________________________________________________________________________________
gui, 4:submit, nohide
if dsshenabled = 1 ;this is here because SSH is the default radio button checked and I want it to default show ssh connections
	gosub ddetectssh
if drdpenabled = 1
	gosub ddetectrdp
exit
dCheckssh:
{
gui, 4:destroy
dsshenabled = 1
drdpenabled = 0
gosub deleteconnection
}
return
dCheckrdp:
{
gui, 4:destroy
drdpenabled = 1
gosub deleteconnection
}
return
ddetectssh:
if ssh1
{
	gui, 4:add, button, vdelssh1 grmvssh1,%SSH1%
}
if ssh2
{
	gui, 4:add, button, vdelssh2 grmvssh2,%ssh2%
}
if ssh3
{
	gui, 4:add, button, vdelssh3 grmvssh3,%ssh3%
}
if ssh4
{
	gui, 4:add, button, vdelssh4 grmvssh4,%ssh4%
}
if ssh5
{
	gui, 4:add, button, vdelssh5 grmvssh5,%ssh5%
}
if ssh6
{
	gui, 4:add, button, vdelssh6 grmvssh6,%ssh6%
}
if ssh7
{
	gui, 4:add, button, vdelssh7 grmvssh7,%ssh7%
}
if ssh8
{
	gui, 4:add, button, vdelssh8 grmvssh8,%ssh8%
}
if ssh9
{
	gui, 4:add, button, vdelssh9 grmvssh9,%ssh9%
}
if ssh10
{
	gui, 4:add, button, vdelssh10 grmvssh10,%ssh10%
}
return

ddetectrdp:
if rdp1
{
	gui, 4:add, button,vdelrdp1 grmvrdp1,%RDP1%
}
if rdp2
{
	gui, 4:add, button,vdelrdp2 grmvrdp2,%rdp2%
}
if rdp3
{
	gui, 4:add, button,vdelrdp3 grmvrdp3,%rdp3%
}
if rdp4
{
	gui, 4:add, button,vdelrdp4 grmvrdp4,%rdp4%
}
if rdp5
{
	gui, 4:add, button,vdelrdp5 grmvrdp5,%rdp5%
}
if rdp6
{
	gui, 4:add, button,vdelrdp6 grmvrdp6,%rdp6%
}
if rdp7
{
	gui, 4:add, button,vdelrdp7 grmvrdp7,%rdp7%
}
if rdp8
{
	gui, 4:add, button,vdelrdp8 grmvrdp8,%rdp8%
}
if rdp9
{
	gui, 4:add, button,vdelrdp9 grmvrdp9,%rdp9%
}
if rdp10
{
	gui, 4:add, button,vdelrdp10 grmvrdp10,%rdp10%
}
return

delreturnmainmenu:
gui, 2:destroy
gui, 4:destroy
gosub mainmenu
exit


return ;keeps the script from running Connection1 when it gets to it
SSH1:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH1%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH1%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH1%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH1%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH1%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH1%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH1%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH2:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH2%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH2%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH2%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH2%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH2%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH2%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH2%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH3:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH3%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH3%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH3%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH3%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH3%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH3%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH3%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH4:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH4%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH4%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH4%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH4%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH4%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH4%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH4%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH5:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH5%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH5%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH5%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH5%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH5%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH5%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH5%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH6:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH6%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH6%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH6%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH6%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH6%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH6%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH6%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH7:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH7%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH7%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH7%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH7%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH7%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH7%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH7%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH8:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH8%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH8%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH8%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH8%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH8%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH8%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH8%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH9:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH9%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH9%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH9%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH9%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH9%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH9%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH9%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

SSH10:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH10%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%SSH10%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH10%
	Fileread, sshconnect, %A_workingdir%\SavedConnections\SSH\%SSH10%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%SSH10%
	filedelete, %A_workingdir%\SavedConnections\SSH\%SSH10%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%SSH10%
	run, %sshconnect%
	gui, 2:destroy
	sshconnect =
}
exit

RmvSSH1:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH1%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH1%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH2:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH2%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH2%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH3:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH3%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH3%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH4:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH4%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH4%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH5:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH5%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH5%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH6:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH6%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH6%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH7:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH7%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH7%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH8:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH8%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH8%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH9:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH9%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH9%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvSSH10:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %SSH10%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%SSH10%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return

RDP1:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP1%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP1%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP1%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP1%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP1%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP1%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP1%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP2:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP2%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP2%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP2%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP2%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP2%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP2%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP2%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP3:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP3%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP3%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP3%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP3%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP3%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP3%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP3%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP4:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP4%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP4%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP4%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP4%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP4%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP4%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP4%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP5:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP5%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP5%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP5%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP5%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP5%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP5%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP5%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP6:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP6%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP6%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP6%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP6%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP6%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP6%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP6%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP7:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP7%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP7%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP7%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP7%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP7%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP7%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP7%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP8:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP8%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP8%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP8%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP8%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP8%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP8%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP8%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP9:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP9%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP9%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP9%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP9%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP9%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP9%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP9%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RDP10:
{
	Gui, 2:submit
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP10%
	Filedelete, %A_workingdir%\SavedConnections\RDP\%RDP10%
	Fileappend, % Decrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP10%
	Fileread, rdpconnect, %A_workingdir%\SavedConnections\RDP\%RDP10%
	Fileread, data, %A_workingdir%\SavedConnections\RDP\%RDP10%
	filedelete, %A_workingdir%\SavedConnections\RDP\%RDP10%
	fileappend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\RDP\%RDP10%
	run, %rdpconnect%
	gui, 2:destroy
	rdpconnect =
}
exit

RmvRDP1:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP1%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP1%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP2:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP2%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP2%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP3:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP3%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP3%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP4:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP4%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP4%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP5:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP5%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP5%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP6:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP6%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP6%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP7:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP7%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP7%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP8:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP8%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP8%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP9:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP9%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP9%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
}
return
RmvRDP10:
{
	gui, 4:submit
	msgbox, 4,Really Delete?,Are you sure you wish to delete %RDP10%? `nPress Yes to delete or No to go back to Delete Connections Menu.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\RDP\%RDP10%
		gui, 4:destroy
		gosub MainMenu
	}
	else
	{
		gui, 4:destroy
		gosub Deleteconnection
	}
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
4guiclose:
ExitApp

