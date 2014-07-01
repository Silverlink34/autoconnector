;GUI for auto Putty SSH connections.Created by Brandon Galiher.
;Parameters for the script listed here
#SingleInstance, Force ;if the script is ran and it was already running, this will cause it to reload itself.
#NoTrayIcon ;Kinda self explanatory.
#NoEnv ;supposed to make compatibility better
;Set icon for program
menu,tray,icon,%A_ScriptDir%\autoconnector.ico,
;Create working dir under My Documents
filecreatedir, %a_mydocuments%\AutoConnector
;Set working directory to created dir ^^
SetWorkingDir %a_mydocuments%\AutoConnector


;Version Settings here, these will call on updater to update if necessary. The program's current version is set here.
version = v1.1-alpha
progress,10,Checking the currentversion file on GitHub..,Checking for updates..
sleep, 500
urldownloadtofile,https://raw.githubusercontent.com/Silverlink34/autoconnector/master/currentversion, %a_workingdir%\currentversion
if errorlevel
{
	progress, off
	msgbox, Could not check for updates. Your interwebs connection isn't working..Press OK to continue.
	gosub configcheck
}
progress,25
fileread,currentversion,%a_workingdir%\currentversion
progress,50,Reading currentversion file..
sleep, 500
filedelete,%a_workingdir%\currentversion
progress,75,Deleting currentversion file..
sleep, 500
if version = %currentversion%
{
	progress,100,,AutoConnector is up-to-date.
	sleep, 500
	progress,off
	fileremovedir, %a_workingdir%\updater,1
	gosub configcheck
}
else 
{
	progress,100,,Update found. Running updater application.
	sleep, 500
	progress,off
	fileremovedir, %a_workingdir%\updater,1
	gosub runupdater
}
exit
runupdater:
ifexist %a_workingdir%\updater\updatefailed
{
	filedelete, %a_workingdir%\updater\updatefailed
	gosub configcheck
}
else
{
	ifnotexist, %a_workingdir%\updater\autoconnector-updater.exe
	{
		filecreatedir, %a_workingdir%\updater
		fileappend,%a_scriptdir%,%a_workingdir%\updater\autoconnectordir
		fileinstall, unzip.exe,%a_workingdir%\programbin\unzip.exe,1
		urldownloadtofile,https://raw.githubusercontent.com/Silverlink34/autoconnector-updater/master/autoconnector-updater.exe, %a_workingdir%\updater\autoconnector-updater.exe
		sleep,5000
		ifexist, %a_workingdir%\updater\autoconnector-updater.exe
		{
			sleep,2000
			progress,off
			fileappend,%a_scriptdir%,%a_workingdir%\updater\autoconnectordir
			run, %a_workingdir%\updater\autoconnector-updater.exe
		}
		else
		{
				if updatefail = 1
				{
					msgbox, Unable to update at this time. Running AutoConnector out of date.
					gosub configcheck
				}
			msgbox,There was a problem connecting to GitHub.com. Re-trying 1 more time.
			updatefail = 1
			gosub runupdater
		}	
	}
	else
	{
		fileappend,%a_scriptdir%,%a_workingdir%\updater\autoconnectordir
		run, %a_workingdir%\updater\autoconnector-updater.exe
	}
}
exit

;Check for config.txt options
configcheck:
fileread, config, config.txt
ifnotinstring, config, passisset
	gosub masterpasswordset
else
	gosub masterpasswordprompt
exit
passwordverified:
ifinstring, config, skipenabled
	gosub MainMenu
else
	gosub guistart
return
;set master password for application
masterpasswordset:
gui, 5:show, w587 h250, Set Master Password
gui, 5:font, s14
guicontrol, 5:focus,masterpass
gui, 5:add, text,,Master password has not been set.
gui, 5:add, text,,Please set a master password to secure this application's data.
gui, 5:add, edit,password vmasterpass
gui, 5:add,text,,Enter password again to verify.
gui, 5:add,edit,password v2ndpass
gui, 5:add,button,vbutok1 g2ndpassverify,Submit
exit
2ndpassverify:
gui, 5:submit
if masterpass = %2ndpass%
	gosub setsecurityquestions
else
	msgbox, The passwords you entered do not match. Enter them again.
	gui, 5:destroy
	gosub masterpasswordset
exit
setsecurityquestions:
gui, 7:show, w587 h500, Set Security Questions
gui, 7:font, s14
gui, 7:add,text,,Submit answers to the following questions for recovery of forgotten password.
gui, 7:add,text,,Your answers are not case sensitive.`n
gui, 7:add,text,,What is your favorite internet browser?
gui, 7:add,edit,w300 vanswer1,
gui, 7:add,text,,Who is your favorite computer manufacturer?
gui, 7:add,edit, w300 vanswer2,
gui, 7:add,text,,What is your favorite operating system?
gui, 7:add,edit,w300 vanswer3,
gui, 7:add,text,,If all else fails, what is your email address to send password to?
gui, 7:add,edit,w300 vemailaddr,
gui, 7:add,button,vbutsub2 gsubmitmpass,Submit
exit

submitmpass:
gui, 5:submit
gui, 7:submit
fileappend,%masterpass%%a_tab%,%a_workingdir%\config2
data = %masterpass%
pass = %masterpass%
gui, 5:destroy
fileappend, % Encrypt(Data,Pass), %a_workingdir%\config
run, %comspec% /c attrib +h %a_workingdir%\config,,hide
data =
pass =
fileappend,%answer1%%a_tab%%answer2%%a_tab%%answer3%%a_tab%%emailaddr%, %a_workingdir%\config2
run, %comspec% /c attrib +h %a_workingdir%\config2,,hide
fileread,data,%a_workingdir%\config2
filedelete, %a_workingdir%\config2
fileappend, % encrypt(data,pass),%a_workingdir%\config2
run, %comspec% /c attrib +h %a_workingdir%\config2,hide
gui, 7:destroy
fileappend, passisset,%a_workingdir%\config.txt
pass =
data =
gosub configcheck
exit
masterpasswordprompt:
gui, 6:show, w567 h170, Enter Master Password
gui, 6:font, s16
gui, 6:add,text,,Enter your master password.
gui, 6:add,edit,password ventermpass
guicontrol, 6:focus,entermpass
gui, 6:add,button,vbutsub2 default gverifympass,Submit
gui, 6:add,button,x+20 vbutforgot gforgotpass,I forgot my password..D'OH!!
exit
verifympass:
gui, 6:submit
fileread, data, %a_workingdir%\config
pass = %entermpass%
mpass := Decrypt(data,pass)
;msgbox, %mpass%
if mpass = %entermpass%
{
	gui, 6:destroy
	pass =
	gosub passwordverified
}
else
{
	msgbox, You entered the wrong password.`nTry again.
	gui, 6:destroy
	mpass =
	pass =
	gosub configcheck
}
exit

forgotpass:
gui, 6:destroy
gui, 8:show, w700 h240, I forgot my password :(
gui, 8:font, s14
gui, 8:add,text,,So you thought you would use this utility to save your passworded connections...
gui, 8:add,text,,Yet you forgot your master password! You silly goose.
gui, 8:add,text,,Try entering your answered security questions, or just have it emailed.`nHopefully you entered your email correctly..
gui, 8:add,button,vbutemailme gemailmpass,Email it to me!
gui, 8:add,button,x+20 vbutenteranswers gsubmitqanswers,Answer Security Questions
gui, 8:add,button,x+20 vbutreturn2mpprompt greturn2mpprompt, Go Back
exit

return2mpprompt:
gui, 8:destroy
gosub masterpasswordprompt

Emailmpass:
gui, 8:submit
gui, 8:destroy
fileread,data,%a_workingdir%\config2
questions := Decrypt(data,pass)
stringsplit,answernum,questions,%a_tab%,,
emailtoaddress = %answernum5%
emailpass = agrias123
emailfromaddress = autoconnector.by.brandon@gmail.com
emailsubject = Your AutoConnector Password
mypass = %answernum1%
emailmessage = You asked to have your password emailed to you so here it is. Your password is %mypass%
emailfromnodomain = autoconnector.by.brandon
sendMail(emailToAddress,emailPass,emailFromAddress,emailSubject,emailMessage,EmailFromNoDomain)
msgbox, Email was sent if your internets is working. Closing application now.
exit

submitqanswers:
gui, 8:submit
gui, 8:destroy
gui, 9:show, w587 h500, Answer The Questions
gui, 9:font, s14
gui, 9:add,text,,Answer the following questions to recover forgotten password.
gui, 9:add,text,,Your answers are not case sensitive.`n
gui, 9:add,text,,What is your favorite internet browser?
gui, 9:add,edit,w300 vsanswer1,
gui, 9:add,text,,Who is your favorite computer manufacturer?
gui, 9:add,edit, w300 vsanswer2,
gui, 9:add,text,,What is your favorite operating system?
gui, 9:add,edit,w300 vsanswer3,
gui, 9:add,button,vbutsub2 gsubmittedanswers,Submit
exit

submittedanswers:
gui, 9:submit
fileread,data,%a_workingdir%\config2
questions := Decrypt(data,pass)
stringsplit,answernum,questions,%a_tab%,,
if sanswer1 = %answernum2%
{
	if sanswer2 = %answernum3%
	{
		if sanswer3 = %answernum4%
		{
			gui, 9:destroy
			gosub correctanswers
		}
		else
		{	msgbox, One of the security questions is incorrect. Try again. 
			gui, 9:destroy
			gosub submitqanswers
		}
	}
	else
	{	msgbox, One of the security questions is incorrect. Try again. 
		gui, 9:destroy
		gosub submitqanswers
	}
	
}
else
{	msgbox, One of the security questions is incorrect. Try again. 
	gui, 9:destroy
	gosub submitqanswers
}	
exit
correctanswers:
fileappend,%answernum1%,%a_mydocuments%\AutoConnector pass.txt
msgbox, Good job, you can remember 3 answers but not your password.`nI'll go ahead and export it to My Documents\AutoConnector pass.txt.`nMake sure you delete the file and note it.`nClosing application.
exit


;Start of GUI below here
guistart:
Gui, 1:Show, w768 h485, AutoConnector
gui, 1:font, s14,
GUI, 1:Add, Text,,Thank you for using Brandon's AutoConnector.
GUI, 1:Add, Text,,This application will quickly allow access to remote devices.
GUI, 1:Add, Text,,Protocols supported are: SSH, RDP, Telnet and VNC.
GUI, 1:Add, Text,,Saved usernames and passwords are encrypted with 128bit encryption method.
gui, 1:add, button, vButok1 gMainMenu default, OK
gui, 1:add, button, vButrddisc gDisclaimer, Read Disclaimer
gui, 1:add, button, gHelp, Help/things to note
gui, 1:add,button,gviewsource,View Source on Github
;Option to skip intro/disclaimer
gui, 1:add, checkbox, vskipintro, Skip this screen on next run?
exit

Disclaimer:
{
msgbox, I do not own AutoHotkey, Putty, or any other programs this script calls upon. `nI am simply the author of the script. `n`nI am also not responsible for any damage to your computer, you are the user that decided to trust my program.
gui, 1:destroy
gosub guistart
}

Help:
msgbox, Some things to note:`n`n-All used files are stored under My Documents/AutoConnector.`n`n-You can transport your saved connections simply by copying the Saved Connections folder around. Please note that all of your connections are encrypted with your master password, so if you set a master password that is different they will not load.`n`n-Deleting config files out of the My Documents\AutoConnector WILL REMOVE your ability to recover your password. 
gui, 1:destroy
gosub guistart

viewsource:
run, https://github.com/silverlink34/autoconnector
winactivate, silverlink34/autoconnector
gui, 1:destroy
gosub guistart

MainMenu:
pass = %mpass%
gui, 1:submit
gui, 1:destroy
ifequal, skipintro, 1
{
	fileappend, skipenabled, %a_workingdir%\config.txt
}
gui, 2:show, w768 h520
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
gui, 2:add,tab, w725 h450 vconnectionselect gcurrenttabnumber,SSH|RDP|Telnet|VNC
gui, 2:add,listbox,vSSHConnections R13 gsshselected
gui, 2:add,updown,section
gui, 2:add, Button,w224 border vbutcreatessh gCreatesshconnection, Create Connection
gui, 2:add,button,ys w165 border vbutsshconn gconnecttossh section,Connect
gui, 2:add,button,w165 vbutsshedit,Edit Connection
gui, 2:add,button,w165 vbutsshdel,Delete Connection
gui, 2:add,button,w165 vbutsftp,Launch SFTP FileZilla
gui, 2:add,button,w165 vbutsshadv gshowsshadv,Show/Hide Advanced Options
guicontrol, 2:disable,butsshconn
guicontrol, 2:disable,butsshedit
guicontrol, 2:disable,butsshdel
guicontrol, 2:disable,butsftp
guicontrol, 2:disable,butsshadv
gui, 2:tab,RDP
gui, 2:add,listbox,vRDPConnections R13
gui, 2:add,updown
;gui, 2:add, Button,w225 border gCreaterdpconnection, Create Connection
gui, 2:tab,Telnet
gui, 2:add,text,,This protocol has not been created yet, it is in progress.
gui, 2:tab,VNC
gui, 2:add,text,,This protocol has not been created yet, it is in progress.
gui, 2:tab
currenttabnumber:
ControlGet, TabNumber, Tab,, SysTabControl321,A
if tabnumber = 1
	gosub detectssh
if tabnumber = 2
	gosub detectrdp
sshselected:
controlget,sshisselected,choice,,listbox1,A
	if sshisselected
	{
		guicontrol, 2:enable,butsshconn
		guicontrol, 2:enable,butsshedit
		guicontrol, 2:enable,butsshdel
		guicontrol, 2:enable,butsftp
		guicontrol, 2:enable,butsshadv
	}
	else
	{
		guicontrol, 2:disable,butsshconn
		guicontrol, 2:disable,butsshedit
		guicontrol, 2:disable,butsshdel
		guicontrol, 2:disable,butsftp
		guicontrol, 2:disable,butsshadv
	}
;gui, 2:add, Button,section border vButcreateconn gCreateconnection, Create Connection
;gui, 2:add, button,x+60 border vButdeleteconn gDeleteconnection, Delete Connection
;gui, 2:add, radio,section checked1 vsshconn gcheckssh,SSH
;gui, 2:add, radio,section vsshconn gcheckssh,SSH
;gui, 2:add, radio,ys checked1 vrdpconn gcheckrdp,RDP
;gui, 2:add, radio,ys vrdpconn gcheckrdp,RDP
;gui, 2:add, radio,ys checked1 vtelnetconn,Telnet
;gui, 2:add, radio,ys vtelnetconn,Telnet
;gui, 2:add, radio, ys checked1 vvncconn,VNC
;gui, 2:add, radio,ys vvncconn,VNC
exit

Detectssh:
ifexist %a_workingdir%\SavedConnections\SSH
controlget,listedssh,list,,Listbox1,A
{	
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\SSH > %a_workingdir%\tmp\sshlist,, hide
	sleep, 200
	Loop, read, %A_workingdir%\tmp\sshlist
	{
		ifnotinstring, listedssh,%a_loopreadline% ;keeps listbox from duplicating entries
		{	
			SSH%a_index% = %a_loopreadline%
			guicontrol, 2:,sshconnections,%a_loopreadline%|
		}
	}
	Fileremovedir, tmp, 1	
}
Return

Detectrdp:
ifexist %a_workingdir%\SavedConnections\RDP
controlget,listedrdp,list,,Listbox2,A
{	
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\RDP > %a_workingdir%\tmp\rdplist,, hide
	sleep, 200
	Loop, read, %A_workingdir%\tmp\rdplist
	{
		ifnotinstring,listedrdp,%a_loopreadline%
			guicontrol, 2:,rdpconnections,%a_loopreadline%|
	}
	Fileremovedir, tmp, 1	
}
return
Createsshconnection:
guicontrol, 2:disable,butcreatessh
guicontrol, 2:disable,butsshconn
guicontrol, 2:disable,butsshedit
guicontrol, 2:disable,butsshdel
guicontrol, 2:disable,butsftp
guicontrol, 2:disable,butsshadv
guicontrol, 2:hide,butcreatessh
guicontrol, 2:hide,butsshconn
guicontrol, 2:hide,butsshedit
guicontrol, 2:hide,butsshdel
guicontrol, 2:hide,butsftp
guicontrol, 2:hide,butsshadv
if createsshwasclicked = 1
{
	guicontrol, 2:show,static4
	guicontrol, 2:show,static5
	guicontrol, 2:show,edit1
	guicontrol, 2:show,static6
	guicontrol, 2:show,edit2
	guicontrol, 2:show,static7
	guicontrol, 2:show,edit3
	guicontrol, 2:show,static8
	guicontrol, 2:show,edit4
	guicontrol, 2:show,button7
	guicontrol, 2:show,button8
	guicontrol, 2:enable,static4
	guicontrol, 2:enable,static5
	guicontrol, 2:enable,edit1
	guicontrol, 2:enable,static6
	guicontrol, 2:enable,edit2
	guicontrol, 2:enable,static7
	guicontrol, 2:enable,edit3
	guicontrol, 2:enable,static8
	guicontrol, 2:enable,edit4
	guicontrol, 2:enable,button7
	guicontrol, 2:enable,button8
}
else
{
	gui, 2:font,underline
	gui, 2:add,text, ys x420 section,New Connection
	guicontrol, 2:hide,static4
	guicontrol, 2:show,static4
	gui, 2:font,norm s14
	gui, 2:font,underline
	GUI, 2:Add, Text,xs x300,Connection Name
	gui, 2:font,norm
	guicontrol, 2:hide,static5
	guicontrol, 2:show,static5
	gui, 2:add, edit,w300  vsshname,My SSH Connection
	gui, 2:font,underline
	GUI, 2:Add, Text,,Username and host
	gui, 2:font,norm
	guicontrol, 2:hide,static6
	guicontrol, 2:show,static6
	gui, 2:add, edit,w300 vsshserver, user@server
	gui, 2:font,underline
	GUI, 2:Add, Text,,Specify a port if not default port 22
	gui, 2:font,norm
	guicontrol, 2:hide,static7
	guicontrol, 2:show,static7
	gui, 2:add, edit,w50 vsshport,22
	gui, 2:font,underline
	GUI, 2:Add, Text,,SSH password
	gui, 2:font,norm
	guicontrol, 2:hide,static8
	guicontrol, 2:show,static8
	gui, 2:add, edit,password w240 vsshpass,
	gui, 2:add, button,border x42 y430 w112 vButsave1 gsavessh, Save
	gui, 2:add, button,border x154 y430 w112 vreturnssh gcancelcreatessh,Cancel
	createsshwasclicked = 1
}
exit

cancelcreatessh:
guicontrol, 2:hide,static4
guicontrol, 2:hide,static5
guicontrol, 2:hide,edit1
guicontrol, 2:hide,static6
guicontrol, 2:hide,edit2
guicontrol, 2:hide,static7
guicontrol, 2:hide,edit3
guicontrol, 2:hide,static8
guicontrol, 2:hide,edit4
guicontrol, 2:hide,button7
guicontrol, 2:hide,button8
guicontrol, 2:disable,static4
guicontrol, 2:disable,static5
guicontrol, 2:disable,edit1
guicontrol, 2:disable,static6
guicontrol, 2:disable,edit2
guicontrol, 2:disable,static7
guicontrol, 2:disable,edit3
guicontrol, 2:disable,static8
guicontrol, 2:disable,edit4
guicontrol, 2:disable,button7
guicontrol, 2:disable,button8
sshname =
sshserver =
sshport =
sshpass =
guicontrol, 2:show,butcreatessh
guicontrol, 2:enable,butcreatessh
guicontrol, 2:show,butsshconn
guicontrol, 2:show,butsshedit
guicontrol, 2:show,butsshdel
guicontrol, 2:show,butsftp
guicontrol, 2:show,butsshadv
exit

Createrdp:
gui, 3:add, text,xs section,Connection Name
gui, 3:add,checkbox,x+210 section vchkrdpadv gshowrdpadv,Show advanced options?
gui, 3:add, edit,x20 w300 vrdpname,My RDP Connection
gui, 3:add, text,,Server domain or public ip and port
gui, 3:add, edit,w300 vrdpserver,server:port
gui, 3:add, text,,Username and Password
gui, 3:add, edit,w300 vrdpuser,username
gui, 3:add, edit,w300 x+30 password vrdppass,password
gui, 3:add, button,border x20 y71 vButsave2 gsaverdp, Save Connection
exit

showsshadv:
if sshadvshowing = 1
{
	guicontrol, 2:disable,static4,
	guicontrol, 2:hide,static4,
	guicontrol, 2:disable,edit1,
	guicontrol, 2:hide,edit1,
	guicontrol, 2:disable,edit2,
	guicontrol, 2:hide,edit2,
	sshadvshowing =
	sshadvshowagain = 1
}
else
{
	if sshadvshowagain = 1
	{
		sshadvshowing = 1
		guicontrol, 2:enable,static4,
		guicontrol, 2:show,static4,
		guicontrol, 2:enable,edit1,
		guicontrol, 2:show,edit1,
		guicontrol, 2:enable,edit2,
		guicontrol, 2:show,edit2,
	}
	else
	{	
		gui, 2:font,underline
		gui, 2:add,text,ys x490,SSH Port Forwarding
		gui, 2:font, norm
		guicontrol, 2:hide,static4,
		guicontrol, 2:show,static4,
		gui, 2:add,edit,vlocalsshport,localport
		gui, 2:add,edit,vremotedestnport,remotelocal:port
		sshadvshowing = 1
	}
}
exit


;showrdpadv:
;gui, 3:submit,nohide
;if chkrdpadv = 1
;{
;	gui, 3:font,underline
;	gui, 3:add,text,xs y240,RDP Advanced Options
;	gui, 3:font,norm
;	gui, 3:add,checkbox,venabledrives,Redirect all drives/media to remote?
;	gui, 3:add,checkbox,venablesound,Redirect sound from remote?
;	gui, 3:add,checkbox,venablefullscreen,Force full screen?
;	gui, 3:add,checkbox,vdisablewall,Force disable remote wallpaper?
;	exit
;}
;else
;{
;	gui, 3:destroy
;	gosub, createconnection
;}	

Savessh:
{
	gui, 2:submit
	FileCreateDir, SavedConnections
	FileCreateDir, SavedConnections\SSH
	if localsshport
		FileAppend, %puttydir%\putty -P %sshport% %sshserver% -pw %sshpass% -R %localsshport%:%remotedestnport%, %A_workingdir%\SavedConnections\SSH\%sshname%
	else
		FileAppend, %puttydir%\putty -P %sshport% %sshserver% -pw %sshpass%, %A_workingdir%\SavedConnections\SSH\%sshname%
	Fileread, data, %A_workingdir%\SavedConnections\SSH\%sshname%
	Filedelete, %A_workingdir%\SavedConnections\SSH\%sshname%
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%sshname%
	gui, 2:destroy
	gosub MainMenu
}
return

Saverdp:
{
	gui, 3:submit
	if enabledrives
		drives =  /drives
	if enablesound
		sound = /sound
	if enablefullscreen
		fullscrn = /f
	if disablewall
		dwall = /nowallpaper
	filecreatedir, %a_workingdir%\programbin
	fileinstall, rdp.exe,%a_workingdir%\programbin\rdp.exe,1
	FileCreateDir, SavedConnections
	FileCreateDir, SavedConnections\RDP
	FileAppend, %a_workingdir%\programbin\rdp /v:%rdpserver% /u:%rdpuser% /p:%rdppass% %drives% %sound% %fullscrn% %dwall%, %A_workingdir%\SavedConnections\RDP\%rdpname%
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

Connecttossh:


return

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
;Email send functions below here
sendMail(emailToAddress,emailPass,emailFromAddress,emailSubject,emailMessage,EmailFromNoDomain)
	{
		filecreatedir, %a_workingdir%\programbin
		fileinstall, mailsend.exe,%a_workingdir%\programbin\mailsend.exe,1
        mailsendlocation = %a_workingdir%\programbin
		Run, %mailsendlocation%\mailsend.exe -to %emailToAddress% -from %emailFromAddress% -ssl -smtp smtp.gmail.com -port 465 -sub "%emailSubject%" -M "%emailMessage%" +cc +bc -q -auth-plain -user "%emailFromNoDomain%" -pass "%emailPass%",, Hide
	}


GuiEscape:
GuiClose:
2guiclose:
3guiclose:
4guiclose:
ExitApp

