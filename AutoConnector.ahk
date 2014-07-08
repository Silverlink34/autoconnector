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

versioncheck:
;Version Settings here, these will call on updater to update if necessary. The program's current version is set here.
version = 1.1-alpha
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
gui, 5:add, text,,Please set a master encryption password to secure this application's data.`n`nLeaving it blank is also an option, but not recommended.
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
GUI, 1:Add, Text,,Thank you for using Brandon's AutoConnector, Version %version%.
GUI, 1:Add, Text,,This application will quickly allow access to remote devices.
GUI, 1:Add, Text,,Protocols supported are: SSH, SFTP, RDP, Telnet and VNC.
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
gui, 2:add,tab, w725 h450 vconnectionselect gcurrenttabnumber,SSH|RDP|Telnet|VNC|Master Settings
gui, 2:add,listbox,vSSHConnections R13 gsshselected
gui, 2:add,updown,section
gui, 2:add, Button,w224 border vbutcreatessh gCreatesshconnection, Create Connection
gui, 2:add,button,ys w165 border vbutsshconn gconnecttossh section,Connect
gui, 2:add,button,w165 vbutsshedit geditsshconnection,Edit Connection
gui, 2:add,button,w165 vbutsshdel gdeletesshconnection,Delete Connection
gui, 2:add,button,w165 vbutsftp gusesftp,Use SFTP
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
gui, 2:add,text,vnotavailabletelnet,This protocol has not been created yet, it is in progress.
gui, 2:tab,VNC
gui, 2:add,text,vnotavailablevnc,This protocol has not been created yet, it is in progress.
gui, 2:tab,Master Settings
gui, 2:add, groupbox,x239 y235
gui, 2:add,button,x256 y275 border vbutresetmasterpass gresetmasterpassword,Reset Master Password
gui, 2:tab
currenttabnumber:
ControlGet, TabNumber, Tab,, SysTabControl321,A
if tabnumber = 1
	gosub detectssh
if tabnumber = 2
	gosub detectrdp
gui, 2:tab,SSH
sshselected:
controlget,sshisselected,choice,,listbox1,A
if sftpmenu = 1
{
	guicontrol,text,txtsftpconnectionto,SFTP To: %sshisselected%
}
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
if gui2wasdestroyed = 1
	createsshwasclicked =
if sshadvfirstclick = 1 ;if user accidentally left advanced ssh options open, this closes it before createssh options are shown.
{
	guicontrol, 2:disable,txtsshportforwarding,
	guicontrol, 2:hide,txtsshportforwarding,
	guicontrol, 2:disable,txtlocalsshport,
	guicontrol, 2:hide,txtlocalsshport,
	guicontrol, 2:disable,localsshport,
	guicontrol, 2:hide,localsshport,
	guicontrol, 2:disable,txtremotedestnport,
	guicontrol, 2:hide,txtremotedestnport,
	guicontrol, 2:disable,remotedestnport,
	guicontrol, 2:hide,remotedestnport,
	sshadvfirstclick =
	sshadvsecondshow = 1
}
if createsshwasclicked = 1
{
	guicontrol, 2:show,txtnewsshconn
	guicontrol, 2:show,txtsshname
	guicontrol, 2:show,sshname
	guicontrol, 2:show,txtsshserver
	guicontrol, 2:show,sshserver
	guicontrol, 2:show,txtsshport
	guicontrol, 2:show,sshport
	
	guicontrol, 2:show,txtsshpass
	guicontrol, 2:show,sshpass
	guicontrol, 2:show,butsavessh
	guicontrol, 2:show,butcancelcreatessh
	guicontrol, 2:enable,txtnewsshconn
	guicontrol, 2:enable,txtsshname
	guicontrol, 2:enable,sshname
	guicontrol, 2:enable,txtsshserver
	guicontrol, 2:enable,sshserver
	guicontrol, 2:enable,txtsshport
	guicontrol, 2:enable,sshport
	guicontrol, 2:enable,txtsshpass
	guicontrol, 2:enable,sshpass
	guicontrol, 2:enable,butsavessh
	guicontrol, 2:enable,butcancelcreatessh
}
else
{
	gui, 2:font,underline
	gui, 2:add,text,vtxtnewsshconn ys x420 section,New Connection
	guicontrol, 2:hide,txtnewsshconn
	guicontrol, 2:show,txtnewsshconn
	gui, 2:font,norm s14
	gui, 2:font,underline
	GUI, 2:Add,Text,vtxtsshname xs x300,Connection Name
	gui, 2:font,norm
	guicontrol, 2:hide,txtsshname
	guicontrol, 2:show,txtsshname
	gui, 2:add, edit,w300 vsshname,My SSH Connection
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxtsshserver,Username and host
	gui, 2:font,norm
	guicontrol, 2:hide,txtsshserver
	guicontrol, 2:show,txtsshserver
	gui, 2:add, edit,w300 vsshserver, user@server
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxtsshport,Specify a port if not default port 22
	gui, 2:font,norm
	guicontrol, 2:hide,txtsshport
	guicontrol, 2:show,txtsshport
	gui, 2:add, edit,w50 vsshport,22
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxtsshpass,SSH password
	gui, 2:font,norm
	guicontrol, 2:hide,txtsshpass
	guicontrol, 2:show,txtsshpass
	gui, 2:add, edit,password w240 vsshpass,
	gui, 2:add, button,border vbutsavessh x42 y436 w112 gsavessh, Save
	gui, 2:add, button,border vbutcancelcreatessh x154 y436 w112 gcancelcreatessh,Cancel
	createsshwasclicked = 1
	if gui2wasdestroyed = 1
		gui2wasdestroyed =
}
exit
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
	gui2wasdestroyed = 1
	gosub MainMenu
}
return
cancelcreatessh:
guicontrol, 2:hide,txtnewsshconn
guicontrol, 2:hide,txtsshname
guicontrol, 2:hide,sshname
guicontrol, 2:hide,txtsshserver
guicontrol, 2:hide,sshserver
guicontrol, 2:hide,txtsshport
guicontrol, 2:hide,sshport
guicontrol, 2:hide,txtsshpass
guicontrol, 2:hide,sshpass
guicontrol, 2:hide,butsavessh
guicontrol, 2:hide,butcancelcreatessh
guicontrol, 2:disable,txtnewsshconn
guicontrol, 2:disable,txtsshname
guicontrol, 2:disable,sshname
guicontrol, 2:disable,txtsshserver
guicontrol, 2:disable,sshserver
guicontrol, 2:disable,txtsshport
guicontrol, 2:disable,sshport
guicontrol, 2:disable,txtsshpass
guicontrol, 2:disable,sshpass
guicontrol, 2:disable,butsavessh
guicontrol, 2:disable,butcancelcreatessh
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

connecttossh:
fileread, data, %a_workingdir%\SavedConnections\SSH\%sshisselected%
sshconnect := Decrypt(data,pass)
gui, 2:submit,nohide
if localsshport
{
	stringreplace,sshcreds,sshconnect,%puttydir%,,1
	stringreplace,sshcreds,sshcreds,\putty,,1
	stringreplace,sshcreds,sshcreds,-P,,1
	stringreplace,sshcreds,sshcreds,%a_space%w%a_space%,%a_space%,1
	stringreplace,sshcreds,sshcreds,%a_space%%a_space%,,
	stringsplit,sshcredfilter,sshcreds,%a_space%,,
	sshconnect = %puttydir%\putty -P %sshcredfilter1% %sshcredfilter2% -pw %sshcredfilter3% -R %localsshport%:%remotedestnport%
}
run, %sshconnect%
return

Editsshconnection:
fileread, data, %a_workingdir%\SavedConnections\SSH\%sshisselected%
ssh2edit := Decrypt(data,pass)
stringreplace,sshcreds,ssh2edit,%puttydir%,,1
stringreplace,sshcreds,sshcreds,\putty,,1
stringreplace,sshcreds,sshcreds,-P,,1
stringreplace,sshcreds,sshcreds,%a_space%w%a_space%,%a_space%,1
stringreplace,sshcreds,sshcreds,%a_space%%a_space%,,
stringsplit,sshcredfilter,sshcreds,%a_space%,,
;msgbox,Username@server:%sshcredfilter2% Password:%sshcredfilter3% Port:%sshcredfilter1%
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
if sshadvfirstclick = 1 ;if user accidentally left advanced ssh options open, this closes it before editssh options are shown.
{
	guicontrol, 2:disable,txtsshportforwarding,
	guicontrol, 2:hide,txtsshportforwarding,
	guicontrol, 2:disable,txtlocalsshport,
	guicontrol, 2:hide,txtlocalsshport,
	guicontrol, 2:disable,localsshport,
	guicontrol, 2:hide,localsshport,
	guicontrol, 2:disable,txtremotedestnport,
	guicontrol, 2:hide,txtremotedestnport,
	guicontrol, 2:disable,remotedestnport,
	guicontrol, 2:hide,remotedestnport,
	sshadvfirstclick =
	sshadvsecondshow = 1
}
if gui2wasdestroyed = 1
	editsshwasclicked =
if editsshwasclicked = 1
{
	guicontrol, 2:show,txteditsshtitle
	guicontrol, 2:show,txteditsshname
	guicontrol, 2:show,editsshname
	guicontrol, 2:show,txteditsshserver
	guicontrol, 2:show,editsshserver
	guicontrol, 2:show,txteditsshport
	guicontrol, 2:show,editsshport
	guicontrol, 2:show,txteditsshpass
	guicontrol, 2:show,editsshpass
	guicontrol, 2:show,butsaveeditedssh
	guicontrol, 2:show,butcanceleditedssh
	guicontrol, 2:enable,txteditsshtitle
	guicontrol, 2:enable,txteditsshname
	guicontrol, 2:enable,editsshname
	guicontrol, 2:enable,txteditsshserver
	guicontrol, 2:enable,editsshserver
	guicontrol, 2:enable,txteditsshport
	guicontrol, 2:enable,editsshport
	guicontrol, 2:enable,txteditsshpass
	guicontrol, 2:enable,editsshpass
	guicontrol, 2:enable,butsaveeditedssh
	guicontrol, 2:enable,butcanceleditedssh
}
else
{	
	gui, 2:font,underline
	gui, 2:add,text,vtxteditsshtitle ys x420 section,Edit Connection
	guicontrol, 2:hide,txteditsshtitle
	guicontrol, 2:show,txteditsshtitle
	gui, 2:font,norm s14
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditsshname xs  x300,Connection Name
	gui, 2:font,norm	
	guicontrol, 2:hide,txteditsshname
	guicontrol, 2:show,txteditsshname
	gui, 2:add, edit,w300 veditsshname,%sshisselected%
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditsshserver,Username and host
	gui, 2:font,norm
	guicontrol, 2:hide,txteditsshserver
	guicontrol, 2:show,txteditsshserver
	gui, 2:add, edit,w300 veditsshserver,%sshcredfilter2%
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditsshport,Specify a port if not default port 22
	gui, 2:font,norm
	guicontrol, 2:hide,txteditsshport
	guicontrol, 2:show,txteditsshport
	gui, 2:add, edit,w50 veditsshport,%sshcredfilter1%
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditsshpass,SSH password
	gui, 2:font,norm
	guicontrol, 2:hide,txteditsshpass
	guicontrol, 2:show,txteditsshpass
	gui, 2:add, edit,password w240 veditsshpass,%sshcredfilter3%
	gui, 2:add, button,border vbutsaveeditedssh x42 y436 w112 gsaveeditedssh, Save
	gui, 2:add, button,border vbutcanceleditedssh x154 y436 w112 gcanceleditssh,Cancel
	editsshwasclicked = 1
	if gui2wasdestroyed = 1
		gui2wasdestroyed =
}
return
saveeditedssh:
{
	gui, 2:submit,nohide
	msgbox,4,,Are you sure you wish to edit connection: %sshisselected%?`nIf you select yes, your provided settings will overwrite your previous settings for the connection.`n`nNOTE:`nIf you removed the password out of the password field, it will now be blank and the connection will probably fail.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%sshisselected%
		FileAppend, %puttydir%\putty -P %editsshport% %editsshserver% -pw %editsshpass%, %A_workingdir%\SavedConnections\SSH\%editsshname%
		Fileread, data, %A_workingdir%\SavedConnections\SSH\%editsshname%
		Filedelete, %A_workingdir%\SavedConnections\SSH\%editsshname%
		FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\SSH\%editsshname%
		gui, 2:destroy
		gui2wasdestroyed = 1
		gosub mainmenu
	}
	else
	return
}
return
canceleditssh:
guicontrol, 2:hide,txteditsshtitle
guicontrol, 2:hide,txteditsshname
guicontrol, 2:hide,editsshname
guicontrol, 2:hide,txteditsshserver
guicontrol, 2:hide,editsshserver
guicontrol, 2:hide,txteditsshport
guicontrol, 2:hide,editsshport
guicontrol, 2:hide,txteditsshpass
guicontrol, 2:hide,editsshpass
guicontrol, 2:hide,butsaveeditedssh
guicontrol, 2:hide,butcanceleditedssh
guicontrol, 2:disable,txteditsshtitle
guicontrol, 2:disable,txteditsshname
guicontrol, 2:disable,editsshname
guicontrol, 2:disable,txteditsshserver
guicontrol, 2:disable,editsshserver
guicontrol, 2:disable,txteditsshport
guicontrol, 2:disable,editsshport
guicontrol, 2:disable,txteditsshpass
guicontrol, 2:disable,editsshport
guicontrol, 2:disable,butsaveeditedssh
guicontrol, 2:disable,butcanceleditedssh
editsshname =
editsshserver =
editsshport =
editsshpass =
guicontrol, 2:show,butcreatessh
guicontrol, 2:enable,butcreatessh
guicontrol, 2:show,butsshconn
guicontrol, 2:show,butsshedit
guicontrol, 2:show,butsshdel
guicontrol, 2:show,butsftp
guicontrol, 2:show,butsshadv
exit
return

deletesshconnection:
msgbox,4,,Are you sure you wish to delete connection: %sshisselected%?
ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%sshisselected%
		gui, 2:destroy
		gui2wasdestroyed = 1
		gosub mainmenu
	}
return

usesftp:
sftpmenu = 1
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
if sshadvfirstclick = 1 ;if user accidentally left advanced ssh options open, this closes it before sftp options are shown.
{
	guicontrol, 2:disable,txtsshportforwarding,
	guicontrol, 2:hide,txtsshportforwarding,
	guicontrol, 2:disable,txtlocalsshport,
	guicontrol, 2:hide,txtlocalsshport,
	guicontrol, 2:disable,localsshport,
	guicontrol, 2:hide,localsshport,
	guicontrol, 2:disable,txtremotedestnport,
	guicontrol, 2:hide,txtremotedestnport,
	guicontrol, 2:disable,remotedestnport,
	guicontrol, 2:hide,remotedestnport,
	sshadvfirstclick =
	sshadvsecondshow = 1
}
gui, 2:add, Button,w224 x42 y436 border vbutreturntossh greturntossh,Return to SSH
gui, 2:font,underline
gui, 2:add,text,vtxtsftpconnectionto ys x365 section,SFTP To: %sshisselected%
guicontrol, 2:hide,sftpconnectionto
guicontrol, 2:show,sftpconnectionto
gui, 2:font,norm s14
gui, 2:add,button,x310 y150 section vbutlaunchfilezilla,Launch SFTP GUI`nWith FileZilla
gui, 2:add,button,ys x+65 vbutlaunchpsftp,Launch SFTP CLI`nWith PSFTP
gui, 2:font,underline
gui, 2:add,text,xs y+40 vtxtsftpoptions,SFTP Options (applied to both GUI and CLI)
gui, 2:font,s13
gui, 2:add,text,vtxtspecifylocaldir section,Specify Local Directory
gui, 2:font,norm
gui, 2:add,edit,vlocaldir,
gui, 2:font,underline s14
gui, 2:add,text,xs y+8 vtxtclioptions,CLI Options
gui, 2:font,s13
gui, 2:add,text,vtxtbatchfile,Load SFTP Command File
gui, 2:font,norm
gui, 2:add,button,vbutloadsftpbatch,Browse for file
gui, 2:font,s14
gui, 2:add,button,vbutsftpclihelp ys x+175,SFTP CLI`nHelp
return
returntossh:
gui, 2:destroy
gosub mainmenu
return

showsshadv:
sshmenu = 1
if gui2wasdestroyed = 1
	sshadvfirstclick =
if sshadvfirstclick = 1
{
	guicontrol, 2:disable,txtsshportforwarding,
	guicontrol, 2:hide,txtsshportforwarding,
	guicontrol, 2:disable,txtlocalsshport,
	guicontrol, 2:hide,txtlocalsshport,
	guicontrol, 2:disable,localsshport,
	guicontrol, 2:hide,localsshport,
	guicontrol, 2:disable,txtremotedestnport,
	guicontrol, 2:hide,txtremotedestnport,
	guicontrol, 2:disable,remotedestnport,
	guicontrol, 2:hide,remotedestnport,
	sshadvfirstclick =
	sshadvsecondshow = 1
}
else
{
	if sshadvsecondshow = 1
	{
		sshadvfirstclick = 1
		guicontrol, 2:enable,txtsshportforwarding
		guicontrol, 2:show,txtsshportforwarding,
		guicontrol, 2:enable,txtlocalsshport,
		guicontrol, 2:show,txtlocalsshport,
		guicontrol, 2:enable,localsshport,
		guicontrol, 2:show,localsshport,
		guicontrol, 2:enable,txtremotedestnport,
		guicontrol, 2:show,txtremotedestnport,
		guicontrol, 2:enable,remotedestnport,
		guicontrol, 2:show,remotedestnport,
	}
	else
	{	
		gui, 2:font,underline
		gui, 2:add,text,vtxtsshportforwarding ys x490,SSH Port Forwarding
		gui, 2:font, norm
		guicontrol, 2:hide,txtsshportforwarding,
		guicontrol, 2:show,txtsshportforwarding,
		gui, 2:add,text,vtxtlocalsshport,Local forwarded port`nExample:2022
		guicontrol, 2:hide,txtlocalsshport,
		guicontrol, 2:show,txtlocalsshport,
		gui, 2:add,edit,vlocalsshport,
		gui, 2:add,text,vtxtremotedestnport,Remote server and port`nExample:localhost:22
		guicontrol, 2:hide,txtremotedestnport,
		guicontrol, 2:show,txtremotedestnport,
		gui, 2:add,edit,vremotedestnport,
		sshadvfirstclick = 1
	}
}
exit

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
/*
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
*/


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


/*
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
*/
resetmasterpassword:
msgbox,4,,Are you sure you wish to reset your master password and re-encrypt all connections?`n`nResetting the password can help to migrate connections to another computer.
ifmsgbox yes
{
	gui, 2:destroy
	gui, 3:show, w587 h250, Reset Master Password
	gui, 3:font, s14
	guicontrol, 3:focus,resetmasterpass
	gui, 3:add, text,,Enter new password.
	gui, 3:add, edit,password vresetmasterpass
	gui, 3:add,text,,Enter password again to verify.
	gui, 3:add,edit,password vreset2ndpass
	gui, 3:add,button,vbutresetok1 greset2ndpassverify,Submit
	exit
	reset2ndpassverify:
	gui, 3:submit
	if resetmasterpass = %reset2ndpass%
		gosub reencryptconnections
	else
	{
		msgbox, The passwords you entered do not match. Enter them again.
		gui, 3:destroy
		gosub resetmasterpassword
	}
	exit
	reencryptconnections:
	gui, 3:submit
	Progress,10,Reading All SSH connections...,Resetting Master Password Encryption
	sleep,2000
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\SSH > %a_workingdir%\tmp\sshlist,, hide
	sleep, 200
	progress,50,Decrypting and Re-Encrypting SSH...
	Loop, read, %A_workingdir%\tmp\sshlist
	{
	sleep,100
	progress,5%a_index%
	fileread,data,%a_workingdir%\SavedConnections\SSH\%a_loopreadline%
	filedelete, %a_workingdir%\SavedConnections\SSH\%a_loopreadline%
	ssh2reset := Decrypt(data,pass)
	pass = %resetmasterpass%
	data = %ssh2reset%
	fileappend,% Encrypt(data,pass),%a_workingdir%\SavedConnections\SSH\%a_loopreadline%
	pass = %mpass%
	}	
	progress,70,SSH Connections Re-Encrypted.
	sleep,2000
	progress,80,Setting New Master Password...
	sleep,2000
	data = %resetmasterpass%
	pass = %resetmasterpass%
	filedelete,%a_workingdir%\config
	fileappend, % Encrypt(Data,Pass), %a_workingdir%\config
	run, %comspec% /c attrib +h %a_workingdir%\config,,hide
	progress,100,,Master Password Successfully Reset. Restarting application..
	sleep,2000
	progress,off
	gui, 3:destroy
	gosub versioncheck
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

