;GUI for auto Putty SSH connections.Created by Brandon Galiher.
;Parameters for the script listed here
#SingleInstance, Force ;if the script is ran and it was already running, this will cause it to reload itself.
#NoEnv ;supposed to make compatibility better
;Set icon for program
;menu,tray,icon,%A_ScriptDir%\autoconnector.ico,
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
		fileinstall,7za.exe,%a_workingdir%\programbin\7za.exe
		urldownloadtofile,https://raw.githubusercontent.com/Silverlink34/autoconnector-updater/master/autoconnector-updater.exe, %a_workingdir%\updater\autoconnector-updater.exe
		sleep,5000
		ifexist, %a_workingdir%\updater\autoconnector-updater.exe
		{
			sleep,2000
			progress,off
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
msgbox, I do not own AutoHotkey, Putty, or any other programs this script calls upon. `nI am simply the author of the script. `n`nI am also not responsible for any damage to your computer, you are the user that decided to trust my program.
return


Help:
msgbox, Some things to note:`n`n-All used files are stored under My Documents/AutoConnector.`n`n-You can transport your saved connections simply by copying the Saved Connections folder around. Please note that all of your connections are encrypted with your master password, so if you set a master password that is different they will not load.`n`n-Deleting config files out of the My Documents\AutoConnector WILL REMOVE your ability to recover your password. 
return

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
if possaved = 1
{
	xandypos = x%x% y%y%
	possaved =
}
else
	xandypos = center
gui, 2:show, w768 h520 %xandypos%
gui, 2:font, s16,
GUI, 2:Add, Text,,Please create a new connection or choose a saved connection.
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
gui, 2:add,listbox,vRDPConnections R13 grdpselected
gui, 2:add,updown,section
gui, 2:add, Button,w224 border vbutcreaterdp gCreaterdpconnection, Create Connection
gui, 2:add,button,ys w165 border vbutrdpconn gconnecttordp section,Connect
gui, 2:add,button,w165 vbutrdpedit geditrdpconnection,Edit Connection
gui, 2:add,button,w165 vbutrdpdel gdeleterdpconnection,Delete Connection
gui, 2:add,button,w165 vbutrdpadv gshowrdpadv,Show/Hide Advanced Options
guicontrol, 2:disable,butrdpconn
guicontrol, 2:disable,butrdpedit
guicontrol, 2:disable,butrdpdel
guicontrol, 2:disable,butrdpadv
;gui, 2:add, Button,w225 border gCreaterdpconnection, Create Connection
gui, 2:tab,Telnet
gui, 2:add,listbox,vTelnetConnections gtelnetselected R13
gui, 2:add,updown,section
gui, 2:add, Button,w224 border vbutcreatetelnet gcreatetelnetconnection, Create Connection
gui, 2:add,button,ys w165 border vbuttelnetconn gconnecttotelnet section,Connect
gui, 2:add,button,w165 vbuttelnetedit gedittelnetconnection,Edit Connection
gui, 2:add,button,w165 vbuttelnetdel gdeletetelnetconnection,Delete Connection
gui, 2:font,s14
;gui, 2:add,checkbox,vcustciscoauto gshowciscoautotype,Customize Cisco AutoType
gui, 2:tab,VNC
gui, 2:add,text,vnotavailablevnc,This protocol has not been created yet, it is in progress.
gui, 2:tab,Master Settings
gui, 2:add, groupbox,x239 y235
gui, 2:add,button,x256 y275 border vbutresetmasterpass gresetmasterpassword,Reset Master Password
gui, 2:tab
if selectrdptab = 1
{
	guicontrol, choosestring, SysTabControl321,|RDP
	selectrdptab =
}
if selecttelnettab = 1
{
	guicontrol, choosestring, SysTabControl321,|Telnet
	selecttelnettab =
}
currenttabnumber:
ControlGet, TabNumber, Tab,, SysTabControl321,A
if tabnumber = 1
	gosub detectssh
if tabnumber = 2
	gosub detectrdp
if tabnumber = 3
	gosub detecttelnet
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
	gosub guidestroykeeppos
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
	guicontrol, 2:,editsshname,%sshisselected%
	guicontrol, 2:,editsshserver,%sshcredfilter2%
	guicontrol, 2:,editsshport,%sshcredfilter1%
	guicontrol, 2:,editsshpass,%sshcredfilter3%
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
	gui, 2:add, edit,w100 veditsshport,%sshcredfilter1%
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
		gosub guidestroykeeppos
	}
	else
	return
}
return
canceleditssh:
editsshname =
editsshserver =
editsshport =
editsshpass =
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
guicontrol, 2:show,butcreatessh
guicontrol, 2:enable,butcreatessh
guicontrol, 2:show,butsshconn
guicontrol, 2:show,butsshedit
guicontrol, 2:show,butsshdel
guicontrol, 2:show,butsftp
guicontrol, 2:show,butsshadv
exit

deletesshconnection:
msgbox,4,,Are you sure you wish to delete connection: %sshisselected%?
ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\SSH\%sshisselected%
		gosub guidestroykeeppos
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
gui, 2:add,button,x310 y150 section vbutlaunchfz glaunchfz,Launch SFTP GUI`nWith FileZilla
gui, 2:add,button,ys x+65 vbutlaunchpsftp glaunchpsftp,Launch SFTP CLI`nWith PSFTP
gui, 2:add,button,w167 vbutsftpclihelp gsftpclihelp,SFTP CLI`nHelp
return
returntossh:
gosub guidestroykeeppos
return
launchfz:
ifexist C:\Program Files (x86)\FileZilla FTP Client
{
	fzdir = C:\Program Files (x86)\FileZilla FTP Client
}
ifexist C:\Program Files\FileZilla FTP Client
{
	fzdir = C:\Program Files\FileZilla FTP Client
}
ifnotinstring, fzdir, Program
{
	ifnotexist, %a_workingdir%\programbin\filezilla
	{
		ifexist %a_workingdir%\programbin\autoconnector-master.zip
		{
			msgbox, acmasterzip found, skipping to extract.
			gosub extractfz
		}
		progress,10,,Installing FileZilla to AutoConnector\programbin..
		filecreatedir, %a_workingdir%\programbin
		progress,50,`n`nDownloading FileZilla files..
		urldownloadtofile,https://github.com/Silverlink34/autoconnector/archive/master.zip, %a_workingdir%\programbin\autoconnector-master.zip
		extractfz:
		progress,70,`n`nExtracting FileZilla Files..
		fileinstall,7za.exe,%a_workingdir%\programbin\7za.exe
		runwait, %comspec% /c %a_workingdir%\programbin\7za x programbin\autoconnector-master.zip -oprogrambin\filezilla filezilla -r -aoa,hide
		sleep,1000
		ifnotexist, %a_workingdir%\programbin\filezilla
		{
			progress,off
			msgbox, filezilla did not install correctly.
		}
		else
		{
			progress,100,`n`n,Done.
			sleep,800
			progress,off
			fzdir = %A_WorkingDir%\programbin\filezilla\autoconnector-master\filezilla
			gosub runfzconnect
		}
	}
	else
	{
		fzdir = %A_WorkingDir%\programbin\filezilla\autoconnector-master\filezilla
		gosub runfzconnect
	}
}
runfzconnect:
gui, 2:SUBMIT,nohide
ifexist %a_workingdir%\programbin\autoconnector-master.zip
	filedelete, %a_workingdir%\programbin\autoconnector-master.zip
fileread, data, %a_workingdir%\SavedConnections\SSH\%sshisselected%
sshconn := Decrypt(data,pass)
stringreplace,sshconn,sshconn,%puttydir%,,1
stringreplace,sshconn,sshconn,\putty,,1
stringreplace,sshconn,sshconn,-P,,1
stringreplace,sshconn,sshconn,%a_space%w%a_space%,%a_space%,1
stringreplace,sshconn,sshconn,%a_space%%a_space%,,
stringreplace,sshconn,sshconn,@,%a_space%,
stringsplit,sftpcreds,sshconn,%a_space%,,
;msgbox,port: %sftpcreds1%`nusername: %sftpcreds2%`nServer: %sftpcreds3%`nPassword: %sftpcreds4%
if localdir
	fzconnect = %fzdir%\filezilla.exe "--local="%localdir%" sftp://%sftpcreds2%:%sftpcreds4%@%sftpcreds3%:%sftpcreds1%"
else
	fzconnect = %fzdir%\filezilla.exe "sftp://%sftpcreds2%:%sftpcreds4%@%sftpcreds3%:%sftpcreds1%"
run, %fzconnect%
exit
launchpsftp:
fileinstall,psftp.exe,%a_workingdir%\programbin\psftp.exe
fileread, data, %a_workingdir%\SavedConnections\SSH\%sshisselected%
sshconn := Decrypt(data,pass)
stringreplace,sshconn,sshconn,%puttydir%,,1
stringreplace,sshconn,sshconn,\putty,,1
stringreplace,sshconn,sshconn,-P,,1
stringreplace,sshconn,sshconn,%a_space%w%a_space%,%a_space%,1
stringreplace,sshconn,sshconn,%a_space%%a_space%,,
stringsplit,sftpcreds,sshconn,%a_space%,,
;msgbox,Username@server:%sshcredfilter2% Password:%sshcredfilter3% Port:%sshcredfilter1%
psftpconnect =  %a_workingdir%\programbin\psftp -P %sftpcreds1% %sftpcreds2% -pw %sftpcreds3%
run, %psftpconnect%
return
sftpclihelp:
msgbox,The SFTP command line uses Linux (bash) sftp commands. Here are the basic commands:`n`nput - transfers file from local to remote. assumes file is in current local directory unless full path specified.`nget - downloads remote file to current local directory.`nls - Lists remote directory`nlls - lists local directory`ncd - changes remote directory, type directory after "cd" to change to it.`nUsing "cd .." will go up a directory, and "cd ../dir" will go up a directory and change to a folder in that directory.`nlcd - same as cd, but changes your local directory.`nbye - exits connection.`nget and put commands accept "*" as a wildcard.
return

showsshadv:
sshmenu = 1
if gui2wasdestroyed = 1
{
	sshadvfirstclick =
	sshadvsecondshow =
	gui2wasdestroyed =
}
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


gui, 2:tab,rdp
rdpselected:
controlget,rdpisselected,choice,,listbox2,A
if rdpisselected
{
	guicontrol, 2:enable,butrdpconn
	guicontrol, 2:enable,butrdpedit
	guicontrol, 2:enable,butrdpdel
	guicontrol, 2:enable,butrdpadv
}
else
{
	guicontrol, 2:disable,butrdpconn
	guicontrol, 2:disable,butrdpedit
	guicontrol, 2:disable,butrdpdel
	guicontrol, 2:disable,butrdpadv
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

Createrdpconnection:
guicontrol, 2:disable,butcreaterdp
guicontrol, 2:disable,butrdpconn
guicontrol, 2:disable,butrdpedit
guicontrol, 2:disable,butrdpdel
guicontrol, 2:disable,butrdpadv
guicontrol, 2:hide,butcreaterdp
guicontrol, 2:hide,butrdpconn
guicontrol, 2:hide,butrdpedit
guicontrol, 2:hide,butrdpdel
guicontrol, 2:hide,butrdpadv
if gui2wasdestroyed = 1
	createrdpwasclicked =
if rdpadvfirstclick = 1
{
	guicontrol, 2:disable,txtrdpsettings,
	guicontrol, 2:hide,txtrdpsettings,
	guicontrol, 2:disable,txtenabledrives,
	guicontrol, 2:hide,txtenabledrives,
	guicontrol, 2:disable,enabledrives,
	guicontrol, 2:hide,enabledrives,
	guicontrol, 2:disable,enablefullscreen,
	guicontrol, 2:hide,enablefullscreen,
	guicontrol, 2:disable,enablewindowedscreen
	guicontrol, 2:hide,enablewindowedscreen
	guicontrol, 2:disable,txtrdpahk
	guicontrol, 2:hide,txtrdpahk
	guicontrol, 2:disable,enablerdpahk
	guicontrol, 2:hide,enablerdpahk
	guicontrol, 2:hide,rdpahkpassonly
	guicontrol, 2:disable,rdpahkpassonly
	guicontrol, 2:hide,rdpahkhelp
	guicontrol, 2:disable,rdpahkhelp
	rdpadvfirstclick =
	rdpadvsecondshow = 1
}
if createrdpwasclicked = 1
{
	guicontrol, 2:show,txtnewrdpconn
	guicontrol, 2:show,txtrdpname
	guicontrol, 2:show,rdpname
	guicontrol, 2:show,txtrdpserver
	guicontrol, 2:show,rdpserver
	guicontrol, 2:show,txtrdpuser
	guicontrol, 2:show,rdpuser
	guicontrol, 2:show,txtrdppass
	guicontrol, 2:show,rdppass
	guicontrol, 2:show,butsaverdp
	guicontrol, 2:show,butcancelcreaterdp
	guicontrol, 2:enable,txtnewrdpconn
	guicontrol, 2:enable,txtrdpname
	guicontrol, 2:enable,rdpname
	guicontrol, 2:enable,txtrdpserver
	guicontrol, 2:enable,rdpserver
	guicontrol, 2:enable,txtrdpuser
	guicontrol, 2:enable,rdpuser
	guicontrol, 2:enable,txtrdppass
	guicontrol, 2:enable,rdppass
	guicontrol, 2:enable,butsaverdp
	guicontrol, 2:enable,butcancelcreaterdp
}
else
{
	gui, 2:tab,rdp
	gui, 2:font,underline
	gui, 2:add,text,vtxtnewrdpconn ys x420 section,New Connection
	guicontrol, 2:hide,txtnewrdpconn
	guicontrol, 2:show,txtnewrdpconn
	gui, 2:font,norm s14
	gui, 2:font,underline
	GUI, 2:Add,Text,vtxtrdpname xs x300,Connection Name
	gui, 2:font,norm
	guicontrol, 2:hide,txtrdpname
	guicontrol, 2:show,txtrdpname
	gui, 2:add, edit,w300 vrdpname,My RDP Connection
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxtrdpserver,Server domain/public ip and port
	gui, 2:font,norm
	guicontrol, 2:hide,txtrdpserver
	guicontrol, 2:show,txtrdpserver
	gui, 2:add, edit,w300 vrdpserver, server:port
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxtrdpuser,Username
	gui, 2:font,norm
	guicontrol, 2:hide,txtrdpuser
	guicontrol, 2:show,txtrdpuser
	gui, 2:add, edit,w240 vrdpuser,
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxtrdppass,Password
	gui, 2:font,norm
	guicontrol, 2:hide,txtrdppass
	guicontrol, 2:show,txtrdppass
	gui, 2:add, edit,password w240 vrdppass,
	gui, 2:add, button,border vbutsaverdp x42 y436 w112 gsaverdp, Save
	gui, 2:add, button,border vbutcancelcreaterdp x154 y436 w112 gcancelcreaterdp,Cancel
	createrdpwasclicked = 1
	if gui2wasdestroyed = 1
		gui2wasdestroyed =
}
exit

Saverdp:
{
	gui, 2:submit
	FileCreateDir, SavedConnections
	FileCreateDir, SavedConnections\RDP
	data = %a_workingdir%\programbin\rdp /v:%rdpserver% /u:%rdpuser% /p:%rdppass%
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\rdp\%rdpname%
	selectrdptab = 1
	gosub guidestroykeeppos
}
return

cancelcreaterdp:
guicontrol, 2:hide,txtnewrdpconn
guicontrol, 2:hide,txtrdpname
guicontrol, 2:hide,rdpname
guicontrol, 2:hide,txtrdpserver
guicontrol, 2:hide,rdpserver
guicontrol, 2:hide,txtrdpuser
guicontrol, 2:hide,rdpuser
guicontrol, 2:hide,txtrdppass
guicontrol, 2:hide,rdppass
guicontrol, 2:hide,butsaverdp
guicontrol, 2:hide,butcancelcreaterdp
guicontrol, 2:disable,txtnewrdpconn
guicontrol, 2:disable,txtrdpname
guicontrol, 2:disable,rdpname
guicontrol, 2:disable,txtrdpserver
guicontrol, 2:disable,rdpserver
guicontrol, 2:disable,txtrdpuser
guicontrol, 2:disable,rdpuser
guicontrol, 2:disable,txtrdppass
guicontrol, 2:disable,rdppass
guicontrol, 2:disable,butsaverdp
guicontrol, 2:disable,butcancelcreaterdp
rdpname =
rdpserver =
rdpuser =
rdppass =
guicontrol, 2:show,butcreaterdp
guicontrol, 2:enable,butcreaterdp
guicontrol, 2:show,butrdpconn
guicontrol, 2:show,butrdpedit
guicontrol, 2:show,butrdpdel
guicontrol, 2:show,butrdpadv
exit

connecttordp:
filecreatedir, %a_workingdir%\programbin
fileinstall, rdp.exe,%a_workingdir%\programbin\rdp.exe,1
fileread, data, %a_workingdir%\SavedConnections\rdp\%rdpisselected%
rdpconnect := Decrypt(data,pass)
gui, 2:submit,nohide
if rdpadvclicked
{
	stringreplace,rdpcreds,rdpconnect,%a_workingdir%\programbin\rdp,,1
	stringreplace,rdpcreds,rdpcreds,/v:,,
	stringreplace,rdpcreds,rdpcreds,/u:,,
	stringreplace,rdpcreds,rdpcreds,/p:,,
	stringreplace,rdpcreds,rdpcreds,%a_space%,%a_tab%,1
	stringsplit,rdpcredfilter,rdpcreds,%a_tab%,%a_tab%,
	if enabledrives = 1
		drives =  /drives
	if enablefullscreen = 1
		fullscrn = /f
	if enablewindowedscreen
		windowedscrn = /w:900 /h:670
	if enabledrives = 0
		drives =
	if enablefullscreen = 0
		fullscrn =
	rdpconnect = %a_workingdir%\programbin\rdp /v:%rdpcredfilter2% /u:%rdpcredfilter3% /p:%rdpcredfilter4% %drives% %fullscrn% %windowedscrn%
}
if enablerdpahk = 1
	{	
		rdpahkcreated = 1
		if rdpahkoff = 1
		{
			hotkey,^!a,,on
			rdpahkoff =
		}
		hotkey,ifwinactive,%rdpcredfilter2%
		hotkey,^!a,rdpahk
	}
if enablerdpahk = 0
	if rdpahkcreated = 1
	{
		hotkey,^!a,off
		rdpahkoff = 1
	}
run, %rdpconnect%
return
rdpahk:
if rdpahkpassonly = 1
{
	sendraw %rdpcredfilter4%
	send {enter}
}
else
{
	Sendraw %rdpcredfilter3%
	send {tab}
	sendraw %rdpcredfilter4%
	send {enter}
}
return

Editrdpconnection:
fileread,data,%a_workingdir%\SavedConnections\rdp\%rdpisselected%
rdp2edit := decrypt(data,pass)
stringreplace,rdpcreds,rdp2edit,%a_workingdir%\programbin\rdp,,1
stringreplace,rdpcreds,rdpcreds,/v:,,
stringreplace,rdpcreds,rdpcreds,/u:,,
stringreplace,rdpcreds,rdpcreds,/p:,,
stringreplace,rdpcreds,rdpcreds,%a_space%,%a_tab%,1
stringsplit,rdpcredfilter,rdpcreds,%a_tab%,%a_tab%,
;msgbox,server:port: %rdpcredfilter2% username: %rdpcredfilter3% password: %rdpcredfilter4%
guicontrol, 2:disable,butcreaterdp
guicontrol, 2:disable,butrdpconn
guicontrol, 2:disable,butrdpedit
guicontrol, 2:disable,butrdpdel
guicontrol, 2:disable,butrdpadv
guicontrol, 2:hide,butcreaterdp
guicontrol, 2:hide,butrdpconn
guicontrol, 2:hide,butrdpedit
guicontrol, 2:hide,butrdpdel
guicontrol, 2:hide,butrdpadv
if rdpadvfirstclick = 1
{
	guicontrol, 2:disable,txtrdpsettings,
	guicontrol, 2:hide,txtrdpsettings,
	guicontrol, 2:disable,txtenabledrives,
	guicontrol, 2:hide,txtenabledrives,
	guicontrol, 2:disable,enabledrives,
	guicontrol, 2:hide,enabledrives,
	guicontrol, 2:disable,enablefullscreen,
	guicontrol, 2:hide,enablefullscreen,
	guicontrol, 2:disable,enablewindowedscreen
	guicontrol, 2:hide,enablewindowedscreen
	guicontrol, 2:disable,txtrdpahk
	guicontrol, 2:hide,txtrdpahk
	guicontrol, 2:disable,enablerdpahk
	guicontrol, 2:hide,enablerdpahk
	guicontrol, 2:hide,rdpahkpassonly
	guicontrol, 2:disable,rdpahkpassonly
	guicontrol, 2:hide,rdpahkhelp
	guicontrol, 2:disable,rdpahkhelp
	rdpadvfirstclick =
	rdpadvsecondshow = 1
}
if gui2wasdestroyed = 1
	editrdpwasclicked =
if editrdpwasclicked = 1
{
	guicontrol, 2:show,txteditrdptitle
	guicontrol, 2:show,txteditrdpname
	guicontrol, 2:show,editrdpname
	guicontrol, 2:show,txteditrdpserver
	guicontrol, 2:show,editrdpserver
	guicontrol, 2:show,txteditrdpuser
	guicontrol, 2:show,editrdpuser
	guicontrol, 2:show,txteditrdppass
	guicontrol, 2:show,editrdppass
	guicontrol, 2:show,butsaveeditedrdp
	guicontrol, 2:show,butcanceleditedrdp
	guicontrol, 2:enable,txteditrdptitle
	guicontrol, 2:enable,txteditrdpname
	guicontrol, 2:enable,editrdpname
	guicontrol, 2:enable,txteditrdpserver
	guicontrol, 2:enable,editrdpserver
	guicontrol, 2:enable,txteditrdpuser
	guicontrol, 2:enable,editrdpuser
	guicontrol, 2:enable,txteditrdppass
	guicontrol, 2:enable,editrdppass
	guicontrol, 2:enable,butsaveeditedrdp
	guicontrol, 2:enable,butcanceleditedrdp
	guicontrol, 2:,editrdpname,%rdpisselected%
	guicontrol, 2:,editrdpserver,%rdpcredfilter2%
	guicontrol, 2:,editrdpuser,%rdpcredfilter3%
	guicontrol, 2:,editrdppass,%rdpcredfilter4%
	
}
else
{	
	gui, 2:tab,rdp
	gui, 2:font,underline
	gui, 2:add,text,vtxteditrdptitle ys x420 section,Edit Connection
	guicontrol, 2:hide,txteditrdptitle
	guicontrol, 2:show,txteditrdptitle
	gui, 2:font,norm s14
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditrdpname xs  x300,Connection Name
	gui, 2:font,norm	
	guicontrol, 2:hide,txteditrdpname
	guicontrol, 2:show,txteditrdpname
	gui, 2:add, edit,w300 veditrdpname,%rdpisselected%
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditrdpserver,Server domain/public ip 
	gui, 2:font,norm
	guicontrol, 2:hide,txteditrdpserver
	guicontrol, 2:show,txteditrdpserver
	gui, 2:add, edit,w300 veditrdpserver,%rdpcredfilter2%
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditrdpuser,Username
	gui, 2:font,norm
	guicontrol, 2:hide,vtxteditrdpuser
	guicontrol, 2:show,vtxteditrdpuser
	gui, 2:add, edit,w300 veditrdpuser,%rdpcredfilter3%
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxteditrdppass,Password
	gui, 2:font,norm
	guicontrol, 2:hide,txteditrdppass
	guicontrol, 2:show,txteditrdppass
	gui, 2:add, edit,password w240 veditrdppass,%rdpcredfilter4%
	gui, 2:add, button,border vbutsaveeditedrdp x42 y436 w112 gsaveeditedrdp, Save
	gui, 2:add, button,border vbutcanceleditedrdp x154 y436 w112 gcanceleditrdp,Cancel
	editrdpwasclicked = 1
	if gui2wasdestroyed = 1
		gui2wasdestroyed =
}
return
saveeditedrdp:
{
	gui, 2:submit,nohide
	msgbox,4,,Are you sure you wish to edit connection: %rdpisselected%?`nIf you select yes, your provided settings will overwrite your previous settings for the connection.`n`nNOTE:`nIf you removed the password out of the password field, it will now be blank and the connection will probably fail.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\rdp\%rdpisselected%
		data = %a_workingdir%\programbin\rdp /v:%editrdpserver% /u:%editrdpuser% /p:%editrdppass%
		editedrdp := Encrypt(data,pass)
		FileAppend,%editedrdp%,%A_workingdir%\SavedConnections\rdp\%editrdpname%
		selectrdptab = 1
		gosub guidestroykeeppos
	}
	else
	return
}
return
canceleditrdp:
guicontrol, 2:hide,txteditrdptitle
guicontrol, 2:hide,txteditrdpname
guicontrol, 2:hide,editrdpname
guicontrol, 2:hide,txteditrdpserver
guicontrol, 2:hide,editrdpserver
guicontrol, 2:hide,txteditrdpuser
guicontrol, 2:hide,editrdpuser
guicontrol, 2:hide,txteditrdppass
guicontrol, 2:hide,editrdppass
guicontrol, 2:hide,butsaveeditedrdp
guicontrol, 2:hide,butcanceleditedrdp
guicontrol, 2:disable,txteditrdptitle
guicontrol, 2:disable,txteditrdpname
guicontrol, 2:disable,editrdpname
guicontrol, 2:disable,txteditrdpserver
guicontrol, 2:disable,editrdpserver
guicontrol, 2:disable,txteditrdpuser
guicontrol, 2:disable,editrdpuser
guicontrol, 2:disable,txteditrdppass
guicontrol, 2:disable,editrdppass
guicontrol, 2:disable,butsaveeditedrdp
guicontrol, 2:disable,butcanceleditedrdp
editrdpname =
editrdpserver =
editrdpuser =
editrdppass =
guicontrol, 2:show,butcreaterdp
guicontrol, 2:enable,butcreaterdp
guicontrol, 2:show,butrdpconn
guicontrol, 2:show,butrdpedit
guicontrol, 2:show,butrdpdel
guicontrol, 2:show,butrdpadv
exit

deleterdpconnection:
msgbox,4,,Are you sure you wish to delete connection: %rdpisselected%?
ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\rdp\%rdpisselected%
		selectrdptab = 1
		gosub guidestroykeeppos
	}
return

showrdpadv:
rdpadvclicked = 1
if gui2wasdestroyed = 1
{
	rdpadvfirstclick =
	rdpadvsecondshow =
	gui2wasdestroyed =
}
if rdpadvfirstclick = 1
{
	guicontrol, 2:disable,txtrdpsettings,
	guicontrol, 2:hide,txtrdpsettings,
	guicontrol, 2:disable,txtenabledrives,
	guicontrol, 2:hide,txtenabledrives,
	guicontrol, 2:disable,enabledrives,
	guicontrol, 2:hide,enabledrives,
	guicontrol, 2:disable,enablefullscreen,
	guicontrol, 2:hide,enablefullscreen,
	guicontrol, 2:disable,enablewindowedscreen
	guicontrol, 2:hide,enablewindowedscreen
	guicontrol, 2:disable,txtrdpahk
	guicontrol, 2:hide,txtrdpahk
	guicontrol, 2:disable,enablerdpahk
	guicontrol, 2:hide,enablerdpahk
	guicontrol, 2:hide,rdpahkpassonly
	guicontrol, 2:disable,rdpahkpassonly
	guicontrol, 2:hide,rdpahkhelp
	guicontrol, 2:disable,rdpahkhelp
	rdpadvfirstclick =
	rdpadvsecondshow = 1
}
else
{
	if rdpadvsecondshow = 1
	{
		rdpadvfirstclick = 1
		guicontrol, 2:enable,txtrdpsettings
		guicontrol, 2:show,txtrdpsettings,
		guicontrol, 2:enable,txtenabledrives,
		guicontrol, 2:show,txtenabledrives,
		guicontrol, 2:enable,enabledrives,
		guicontrol, 2:show,enabledrives,
		guicontrol, 2:enable,enablefullscreen,
		guicontrol, 2:show,enablefullscreen,
		guicontrol, 2:enable,enablewindowedscreen
		guicontrol, 2:show,enablewindowedscreen
		guicontrol, 2:enable,txtrdpahk
		guicontrol, 2:show,txtrdpahk
		guicontrol, 2:enable,enablerdpahk
		guicontrol, 2:show,enablerdpahk
	}
	else
	{	
		gui, 2:tab,rdp
		gui, 2:font,underline
		gui, 2:add,text,vtxtrdpsettings ys x490,RDP Settings
		gui, 2:font, norm
		guicontrol, 2:hide,txtrdpsettings,
		guicontrol, 2:show,txtrdpsettings,
		gui, 2:font,s14
		gui, 2:add,checkbox,venabledrives,Redirect local drives
		gui, 2:add,checkbox,venablefullscreen guncheckwindowedscreen,Force full screen
		gui, 2:add,checkbox,venablewindowedscreen guncheckfullscreen,Force Windowed Screen
		gui, 2:font,s16 underline
		gui, 2:add,text,vtxtrdpahk,AutoHotkey Settings
		guicontrol, 2:hide,txtrdpahk,
		guicontrol, 2:show,txtrdpahk,
		gui, 2:font,norm s14
		gui, 2:add,checkbox,venablerdpahk gshowrdpahk,Enable AutoHotkey`n(Ctrl+Alt+A)
		rdpadvfirstclick = 1
	}
}
exit
uncheckwindowedscreen:
if windoweddisabled = 1
{
	guicontrol, 2:enable,enablewindowedscreen
	windoweddisabled =
}
else
{
guicontrol, 2:,enablewindowedscreen,0
guicontrol, 2:disable,enablewindowedscreen
windoweddisabled = 1
}
return
uncheckfullscreen:
if fullscreendisabled = 1
{
	guicontrol, 2:enable,enablefullscreen
	fullscreendisabled =
}
else
{
guicontrol, 2:,enablefullscreen,0
guicontrol, 2:disable,enablefullscreen
fullscreendisabled = 1
}
return
showrdpahk:
if gui2wasdestroyed = 1
	rdpahkclicked =
if rdpahkclicked = 1
{
	guicontrol, 2:hide,rdpahkpassonly
	guicontrol, 2:disable,rdpahkpassonly
	guicontrol, 2:hide,rdpahkhelp
	guicontrol, 2:disable,rdpahkhelp
	rdpahk2ndclick = 1
	rdpahkclicked =
}
else
{
	if rdpahk2ndclick = 1
	{
		guicontrol, 2:show,rdpahkpassonly
		guicontrol, 2:enable,rdpahkpassonly
		guicontrol, 2:show,rdpahkhelp
		guicontrol, 2:enable,rdpahkhelp
		rdpahkclicked = 1
		
	}
	else
	{
		gui, 2:add,checkbox,vrdpahkpassonly,Auto Password Only`n(Type Password+(enter)
		gui, 2:add,button,vrdpahkhelp grdpahkhelp,AutoHotkey Help
		rdpahkclicked = 1
	}
}
return
RdpAHKHelp:
msgbox,Enabling AutoHotkey will allow the key combination of Ctrl+Alt+A to automatically type username (tab) password (enter).`nThis is useful if an older OS doesn't let you auto login normally.`nYou may additonally enable the option to only type password (enter) for connections that already have the username field entered.
return

gui, 2:tab,telnet
telnetselected:
controlget,telnetisselected,choice,,listbox3,A
if telnetisselected
{
	guicontrol, 2:enable,buttelnetconn
	guicontrol, 2:enable,buttelnetedit
	guicontrol, 2:enable,buttelnetdel
	guicontrol, 2:enable,custciscoauto
	ifnotexist, %a_workingdir%\SavedConnections\cisco\%telnetisselected%
	{
		guicontrol, 2:disable,custciscoauto
		
	}
}
else
{
	guicontrol, 2:disable,buttelnetconn
	guicontrol, 2:disable,buttelnetedit
	guicontrol, 2:disable,buttelnetdel
	guicontrol, 2:disable,custciscoauto
}
exit

Detecttelnet:
ifexist %a_workingdir%\SavedConnections\telnet
controlget,listedtelnet,list,,Listbox3,A
{	
	FileCreateDir, tmp
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\telnet > %a_workingdir%\tmp\telnetlist,, hide
	sleep, 200
	Loop, read, %A_workingdir%\tmp\telnetlist
	{
		ifnotinstring,listedtelnet,%a_loopreadline%
			guicontrol, 2:,telnetconnections,%a_loopreadline%|
	}
	Fileremovedir, tmp, 1	
}
return
Createtelnetconnection:
guicontrol, 2:disable,butcreatetelnet
guicontrol, 2:disable,buttelnetconn
guicontrol, 2:disable,buttelnetedit
guicontrol, 2:disable,buttelnetdel
guicontrol, 2:disable,custciscoauto
guicontrol, 2:hide,butcreatetelnet
guicontrol, 2:hide,buttelnetconn
guicontrol, 2:hide,buttelnetedit
guicontrol, 2:hide,buttelnetdel
guicontrol, 2:hide,custciscoauto
if gui2wasdestroyed = 1
	createtelnetwasclicked =
if createtelnetwasclicked = 1
{
	guicontrol, 2:show,txtnewtelnetconn
	guicontrol, 2:show,txttelnetname
	guicontrol, 2:show,telnetname
	guicontrol, 2:show,txttelnetserver
	guicontrol, 2:show,telnetserver
	guicontrol, 2:show,saveciscocreds
	guicontrol, 2:show,butsavetelnet
	guicontrol, 2:show,butcancelcreatetelnet
	guicontrol, 2:enable,txtnewtelnetconn
	guicontrol, 2:enable,txttelnetname
	guicontrol, 2:enable,telnetname
	guicontrol, 2:enable,txttelnetserver
	guicontrol, 2:enable,telnetserver
	guicontrol, 2:show,saveciscocreds
	guicontrol, 2:enable,butsavetelnet
	guicontrol, 2:enable,butcancelcreatetelnet
}
else
{
	gui, 2:tab,telnet
	gui, 2:font,underline
	gui, 2:add,text,vtxtnewtelnetconn ys x420 section,New Connection
	guicontrol, 2:hide,txtnewtelnetconn
	guicontrol, 2:show,txtnewtelnetconn
	gui, 2:font,norm s14
	gui, 2:font,underline
	GUI, 2:Add,Text,vtxttelnetname xs x300,Connection Name
	gui, 2:font,norm
	guicontrol, 2:hide,txttelnetname
	guicontrol, 2:show,txttelnetname
	gui, 2:add, edit,w300 vtelnetname,My telnet Connection
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxttelnetserver,Server domain/public ip and Port
	gui, 2:font,norm
	guicontrol, 2:hide,txttelnetserver
	guicontrol, 2:show,txttelnetserver
	gui, 2:add, edit,w300 vtelnetserver, serverip:port
	gui, 2:add,checkbox,vsaveciscocreds,Use Cisco Router Credentials
	gui, 2:add, button,border vbutsavetelnet gsavetelnet x42 y436 w112,Save
	gui, 2:add, button,border vbutcancelcreatetelnet gcancelcreatetelnet x154 y436 w112,Cancel
	createtelnetwasclicked = 1
	if gui2wasdestroyed = 1
		gui2wasdestroyed =
}
exit
Savetelnet:
{
	if ciscosaved
		ciscosaved =
	else
		gui, 2:submit,nohide
	if saveciscocreds = 1
		gosub saveciscocredentials
	FileCreateDir, SavedConnections
	FileCreateDir, SavedConnections\telnet
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
	data =  %puttydir%\putty telnet://%telnetserver%
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\telnet\%telnetname%

	selecttelnettab = 1
	gosub guidestroykeeppos
}
return
createciscocredentials:
aftertelsaved = 1
gosub saveciscocredentials
saveciscocredentials:
guicontrol, 2:hide,txtnewtelnetconn
guicontrol, 2:hide,txttelnetname
guicontrol, 2:hide,telnetname
guicontrol, 2:hide,txttelnetserver
guicontrol, 2:hide,telnetserver
guicontrol, 2:hide,saveciscocreds
guicontrol, 2:hide,butsavetelnet
guicontrol, 2:hide,butcancelcreatetelnet
guicontrol, 2:disable,txtnewtelnetconn
guicontrol, 2:disable,txttelnetname
guicontrol, 2:disable,telnetname
guicontrol, 2:disable,txttelnetserver
guicontrol, 2:disable,telnetserver
guicontrol, 2:disable,saveciscocreds
guicontrol, 2:disable,butsavetelnet
guicontrol, 2:disable,butcancelcreatetelnet
if aftertelsaved = 1
{
	guicontrol, 2:hide,txtedittelnetconn
	guicontrol, 2:hide,txtedittelnetname
	guicontrol, 2:hide,edittelnetname
	guicontrol, 2:hide,txtedittelnetserver
	guicontrol, 2:hide,edittelnetserver
	guicontrol, 2:hide,butsaveeditedtelnet
	guicontrol, 2:hide,butcanceledittelnet
	guicontrol, 2:hide,buteditcisco
	guicontrol, 2:hide,butaddcisco
	guicontrol, 2:hide,butdelcisco
	guicontrol, 2:disable,txtedittelnettitle
	guicontrol, 2:disable,txtedittelnetname
	guicontrol, 2:disable,edittelnetname
	guicontrol, 2:disable,txtedittelnetserver
	guicontrol, 2:disable,edittelnetserver
	guicontrol, 2:disable,buteditcisco
	guicontrol, 2:disable,butaddcisco
	guicontrol, 2:disable,butdelcisco
	guicontrol, 2:disable,butsaveeditedtelnet
	guicontrol, 2:disable,butcanceledittelnet
}
gui, 2:font,underline
gui, 2:add,text,vtxtciscocreds ys x420 section,Cisco Credentials
guicontrol, 2:hide,txtciscocreds
guicontrol, 2:show,txtciscocreds
gui, 2:font,s14
GUI, 2:Add,Text,vtxtinituser xs x300,Username
guicontrol, 2:hide,txtinituser
guicontrol, 2:show,txtinituser
gui, 2:font,norm s14
gui, 2:add,edit,vinituser w260
gui, 2:font,underline
GUI, 2:Add,Text,vtxtinitpass,Password
guicontrol, 2:hide,txtinitpass
guicontrol, 2:show,txtinitpass
gui, 2:font,norm
gui, 2:add,edit,vinitpass password w260
gui, 2:font,underline
GUI, 2:Add,Text,vtxtenablecreds xs,Enable Password
guicontrol, 2:hide,txtenablepass
guicontrol, 2:show,txtenablepass
gui, 2:font,norm
gui, 2:add,edit,venablepass password w260 xs x300
gui, 2:add, button,border vbutsavecisco gsavecisco x42 y436 w112,Save
gui, 2:add, button,border vbutcancelcisco gcancelcisco x154 y436 w112,Cancel
exit
savecisco:
gui, 2:submit
FileCreateDir, SavedConnections
FileCreateDir, SavedConnections\cisco
data = %inituser%%a_tab%%initpass%%a_tab%%enablepass%
if aftertelsaved = 1
{
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\cisco\%telnetisselected%
	aftertelsaved = 0
	edittelnetwasclicked = 1
}
else
{
	FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\cisco\%telnetname%
}
saveciscocreds =
ciscosaved = 1
gosub savetelnet
exit

cancelcisco:
selecttelnettab = 1
gosub guidestroykeeppos

cancelcreatetelnet:
guicontrol, 2:hide,txtnewtelnetconn
guicontrol, 2:hide,txttelnetname
guicontrol, 2:hide,telnetname
guicontrol, 2:hide,txttelnetserver
guicontrol, 2:hide,telnetserver
guicontrol, 2:hide,saveciscocreds
guicontrol, 2:hide,butsavetelnet
guicontrol, 2:hide,butcancelcreatetelnet
guicontrol, 2:disable,txtnewtelnetconn
guicontrol, 2:disable,txttelnetname
guicontrol, 2:disable,telnetname
guicontrol, 2:disable,txttelnetserver
guicontrol, 2:disable,telnetserver
guicontrol, 2:disable,saveciscocreds
guicontrol, 2:disable,butsavetelnet
guicontrol, 2:disable,butcancelcreatetelnet
telnetname =
telnetserver =
guicontrol, 2:show,butcreatetelnet
guicontrol, 2:enable,butcreatetelnet
guicontrol, 2:show,buttelnetconn
guicontrol, 2:show,buttelnetedit
guicontrol, 2:show,buttelnetdel
guicontrol, 2:show,custciscoauto
exit

connecttotelnet:
fileread, data, %a_workingdir%\SavedConnections\telnet\%telnetisselected%
telnetconnect := Decrypt(data,pass)
run, %telnetconnect%
ifexist %a_workingdir%\SavedConnections\cisco\%telnetisselected%
custciscoauto:
{
	fileread,data,%a_workingdir%\SavedConnections\cisco\%telnetisselected%
	ciscocreds := Decrypt(data,pass)
	stringsplit,ciscocredfilter,ciscocreds,%a_tab%
	winwaitactive,%telnetserver%
	sleep,800
	sendraw,%ciscocredfilter1%
	send,{enter}
	sleep,200
	sendraw,%ciscocredfilter2%
	send,{enter}
	sleep,200
	sendraw,en
	send,{enter}
	sleep,200
	sendraw,%ciscocredfilter3%
	send,{enter}
}
return
Edittelnetconnection:
fileread,data,%a_workingdir%\SavedConnections\telnet\%telnetisselected%
telnet2edit := decrypt(data,pass)
ifexist C:\Program Files (x86)\PuTTY
{
	puttydir = C:\Program Files (x86)\PuTTY
}
ifexist C:\Program Files\PuTTY
{
	puttydir = C:\Program Files\PuTTY
}
ifexist %a_workingdir%\programbin\putty.exe
{
	puttydir = %a_workingdir%\programbin\
}
stringreplace,telnetserver,telnet2edit,%puttydir%,,
stringreplace,telnetserver,telnetserver,\putty,,
stringreplace,telnetserver,telnetserver,%a_space%,,
stringreplace,telnetserver,telnetserver,telnet://,,
guicontrol, 2:disable,butcreatetelnet
guicontrol, 2:disable,buttelnetconn
guicontrol, 2:disable,buttelnetedit
guicontrol, 2:disable,buttelnetdel
guicontrol, 2:disable,custciscoauto
guicontrol, 2:hide,custciscoauto
guicontrol, 2:hide,butcreatetelnet
guicontrol, 2:hide,buttelnetconn
guicontrol, 2:hide,buttelnetedit
guicontrol, 2:hide,buttelnetdel
if gui2wasdestroyed = 1
	edittelnetwasclicked =
if edittelnetwasclicked = 1
{
	guicontrol, 2:show,txtedittelnetconn
	guicontrol, 2:show,txtedittelnetname
	guicontrol, 2:show,edittelnetname
	guicontrol, 2:show,txtedittelnetserver
	guicontrol, 2:show,edittelnetserver
	guicontrol, 2:show,buteditcisco
	guicontrol, 2:show,butaddcisco
	guicontrol, 2:show,butdelcisco
	guicontrol, 2:show,butsaveeditedtelnet
	guicontrol, 2:show,butcanceledittelnet
	guicontrol, 2:enable,txtedittelnettitle
	guicontrol, 2:enable,txtedittelnetname
	guicontrol, 2:enable,edittelnetname
	guicontrol, 2:enable,txtedittelnetserver
	guicontrol, 2:enable,edittelnetserver
	guicontrol, 2:enable,buteditcisco
	guicontrol, 2:enable,butaddcisco
	guicontrol, 2:enable,butdelcisco
	guicontrol, 2:enable,butsaveeditedtelnet
	guicontrol, 2:enable,butcanceledittelnet
	guicontrol, 2:,edittelnetname,%telnetisselected%
	guicontrol, 2:,edittelnetserver,%telnetserver%
	ifnotexist, %a_workingdir%\SavedConnections\cisco\%telnetisselected%
	{
		guicontrol, 2:disable,buteditcisco
		guicontrol, 2:disable,butdelcisco
	}
	else
		guicontrol, 2:disable,butaddcisco
}
else
{	
	gui, 2:tab,telnet
	gui, 2:font,underline
	gui, 2:add,text,vtxtedittelnetconn ys x420 section,Edit Connection
	guicontrol, 2:hide,txtedittelnetconn
	guicontrol, 2:show,txtedittelnetconn
	gui, 2:font,norm s14
	gui, 2:font,underline
	GUI, 2:Add,Text,vtxtedittelnetname xs x300,Connection Name
	gui, 2:font,norm
	guicontrol, 2:hide,txtedittelnetname
	guicontrol, 2:show,txtedittelnetname
	gui, 2:add, edit,w300 vedittelnetname,%telnetisselected%
	gui, 2:font,underline
	GUI, 2:Add, Text,vtxtedittelnetserver,Server domain/public ip and Port
	gui, 2:font,norm
	guicontrol, 2:hide,txtedittelnetserver
	guicontrol, 2:show,txtedittelnetserver
	gui, 2:add, edit,w300 vedittelnetserver,%telnetserver%
	gui, 2:add,button,vbutaddcisco gcreateciscocredentials,Create Cisco Credentials
	gui, 2:add,button,vbuteditcisco geditciscocreds,Edit Cisco Credentials
	gui, 2:add,button,vbutdelcisco gdeleteciscocreds,Delete Cisco Credentials
	ifnotexist, %a_workingdir%\SavedConnections\cisco\%telnetisselected%
	{
		guicontrol, 2:disable,buteditcisco
		guicontrol, 2:disable,butdelcisco
	}
	else
		guicontrol, 2:disable,butaddcisco
	gui, 2:add, button,border vbutsaveeditedtelnet x42 y436 w112 gsaveeditedtelnet, Save
	gui, 2:add, button,border vbutcanceledittelnet x154 y436 w112 gcanceledittelnet,Cancel
	edittelnetwasclicked = 1
	if gui2wasdestroyed = 1
		gui2wasdestroyed =
}
return
editciscocreds:
fileread,data,%a_workingdir%\SavedConnections\cisco\%telnetisselected%
ciscocreds := Decrypt(data,pass)
stringsplit,ciscocredfilter,ciscocreds,%a_tab%
guicontrol, 2:hide,txtedittelnetconn
guicontrol, 2:hide,txtedittelnetname
guicontrol, 2:hide,edittelnetname
guicontrol, 2:hide,txtedittelnetserver
guicontrol, 2:hide,edittelnetserver
guicontrol, 2:hide,butaddcisco
guicontrol, 2:hide,buteditcisco
guicontrol, 2:hide,butdelcisco
guicontrol, 2:hide,butsaveeditedtelnet
guicontrol, 2:hide,butcanceledittelnet
guicontrol, 2:disable,txtedittelnetconn
guicontrol, 2:disable,txtedittelnetname
guicontrol, 2:disable,edittelnetname
guicontrol, 2:disable,txtedittelnetserver
guicontrol, 2:disable,edittelnetserver
guicontrol, 2:disable,butaddcisco
guicontrol, 2:disable,buteditcisco
guicontrol, 2:disable,butdelcisco
guicontrol, 2:disable,butsaveeditedtelnet
guicontrol, 2:disable,butcanceledittelnet
gui, 2:font,underline
gui, 2:add,text,vtxteditciscocreds ys x420 section,Edit Cisco Credentials
guicontrol, 2:hide,txteditciscocreds
guicontrol, 2:show,txteditciscocreds
gui, 2:font,s14
GUI, 2:Add,Text,vtxteditinituser xs x300,Username
guicontrol, 2:hide,txteditinituser
guicontrol, 2:show,txteditinituser
gui, 2:font,norm s14
gui, 2:add,edit,veditinituser w260,%ciscocredfilter1%
gui, 2:font,underline
GUI, 2:Add,Text,vtxteditinitpass,Password
guicontrol, 2:hide,txteditinitpass
guicontrol, 2:show,txteditinitpass
gui, 2:font,norm
gui, 2:add,edit,veditinitpass password w260,%ciscocredfilter2%
gui, 2:font,underline
GUI, 2:Add,Text,vtxteditenablecreds xs,Enable Password
guicontrol, 2:hide,txteditenablepass
guicontrol, 2:show,txteditenablepass
gui, 2:font,norm
gui, 2:add,edit,veditenablepass password w260 xs x300,%ciscocredfilter3%
gui, 2:add, button,border vbutsaveeditcisco gsaveeditcisco x42 y436 w112,Save
gui, 2:add, button,border vbutcanceleditcisco gcanceleditcisco x154 y436 w112,Cancel
guicontrol, 2:,editinituser,%ciscocredfilter1%
guicontrol, 2:,editinitpass,%ciscocredfilter2%
guicontrol, 2:,editenanblepass,%ciscocredfilter3%
return

saveeditcisco:
gui, 2:submit,nohide
data = %editinituser%%a_tab%%editinitpass%%a_tab%%editenablepass%
filedelete,%A_workingdir%\SavedConnections\cisco\%telnetisselected%
FileAppend, % Encrypt(Data,Pass), %A_workingdir%\SavedConnections\cisco\%edittelnetname%
ciscocredfilter1 =
ciscocredfilter2 =
ciscocredfilter3 =
selecttelnettab = 1
gosub guidestroykeeppos
return

canceleditcisco:

selecttelnettab = 1
gosub guidestroykeeppos
return

deleteciscocreds:
msgbox,4,,Are you sure you wish to delete Cisco credentials for: %telnetisselected%?
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\cisco\%telnetisselected%
		selecttelnettab = 1
		gosub guidestroykeeppos
	}
	else
	return

deletetelnetconnection:
msgbox,4,,Are you sure you wish to delete connection: %telnetisselected%?
ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\telnet\%telnetisselected%
		gui, 2:destroy
		selecttelnettab = 1
		gui2wasdestroyed = 1
		gosub mainmenu
	}
return

saveeditedtelnet:
{
	gui, 2:submit,nohide
	msgbox,4,,Are you sure you wish to edit connection: %telnetisselected%?`nIf you select yes, your provided settings will overwrite your previous settings for the connection.`n`nNOTE:`nIf you removed the password out of the password field, it will now be blank and the connection will probably fail.
	ifmsgbox yes
	{
		filedelete, %A_workingdir%\SavedConnections\telnet\%telnetisselected%
		data = %puttydir%\putty telnet://%edittelnetserver%
		editedtelnet := Encrypt(data,pass)
		FileAppend,%editedtelnet%,%A_workingdir%\SavedConnections\telnet\%edittelnetname%		
		selecttelnettab = 1
		gosub guidestroykeeppos
	}
	else
	return
}
return
canceledittelnet:
guicontrol, 2:hide,txtedittelnetconn
guicontrol, 2:hide,txtedittelnetname
guicontrol, 2:hide,edittelnetname
guicontrol, 2:hide,txtedittelnetserver
guicontrol, 2:hide,edittelnetserver
guicontrol, 2:hide,butsaveeditedtelnet
guicontrol, 2:hide,butcanceledittelnet
guicontrol, 2:hide,buteditcisco
guicontrol, 2:hide,butaddcisco
guicontrol, 2:hide,butdelcisco
guicontrol, 2:disable,txtedittelnettitle
guicontrol, 2:disable,txtedittelnetname
guicontrol, 2:disable,edittelnetname
guicontrol, 2:disable,txtedittelnetserver
guicontrol, 2:disable,edittelnetserver
guicontrol, 2:disable,buteditcisco
guicontrol, 2:disable,butaddcisco
guicontrol, 2:disable,butdelcisco
guicontrol, 2:disable,butsaveeditedtelnet
guicontrol, 2:disable,butcanceledittelnet
edittelnetname =
edittelnetserver =
guicontrol, 2:show,butcreatetelnet
guicontrol, 2:enable,butcreatetelnet
guicontrol, 2:show,buttelnetconn
guicontrol, 2:show,buttelnetedit
guicontrol, 2:show,buttelnetdel
guicontrol, 2:show,buttelnetadv
guicontrol, 2:show,custciscoauto
exit

/*showciscoautotype:
if ciscoautotypeclicked = 1
{
	guicontrol, 2:hide,autotypeuser
	guicontrol, 2:hide,autotypepass
	guicontrol, 2:hide,autotypeenpass
	guicontrol, 2:hide,butsaveciscoauto
	guicontrol, 2:disable,autotypeuser
	guicontrol, 2:disable,autotypepass
	guicontrol, 2:disable,autotypeenpass
	guicontrol, 2:disable,butsaveciscoauto
	ciscoautotypeclicked =
	ciscoautotype2ndclick = 1
}
else
{
	if ciscoautotype2ndclick = 1
	{
		guicontrol, 2:show,autotypeuser
		guicontrol, 2:show,autotypepass
		guicontrol, 2:show,autotypeenpass
		guicontrol, 2:show,butsaveciscoauto
		guicontrol, 2:enable,autotypeuser
		guicontrol, 2:enable,autotypepass
		guicontrol, 2:enable,autotypeenpass
		guicontrol, 2:enable,butsaveciscoauto
		ciscoautotypeclicked = 1
	}
	else
	{
		gui, 2:tab,telnet
		gui, 2:add,checkbox, xs x302 y315 vautotypeuser,Type Username
		gui, 2:add,checkbox,vautotypepass,Type Password
		gui, 2:add,checkbox,vautotypeenpass,Type Enable Password
		gui, 2:add,button,vbutsaveciscoauto,Save Customized AutoType`nSettings
		ciscoautotypeclicked = 1
	}
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
	FileCreateDir, %a_workingdir%\tmp
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\SSH > %a_workingdir%\tmp\sshlist,, hide
	sleep, 200
	progress,20,Decrypting and Re-Encrypting SSH...
	Loop, read, %A_workingdir%\tmp\sshlist
	{
	sleep,100
	fileread,data,%a_workingdir%\SavedConnections\SSH\%a_loopreadline%
	filedelete, %a_workingdir%\SavedConnections\SSH\%a_loopreadline%
	ssh2reset := Decrypt(data,pass)
	pass = %resetmasterpass%
	data = %ssh2reset%
	fileappend,% Encrypt(data,pass),%a_workingdir%\SavedConnections\SSH\%a_loopreadline%
	pass = %mpass%
	}	
	progress,30,SSH Connections Re-Encrypted.
	sleep,2000
	Progress,40,Reading All RDP connections...
	sleep,2000
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\rdp > %a_workingdir%\tmp\rdplist,, hide
	sleep,200
	progress,50,Decrypting and Re-Encrypting RDP...
	Loop, read, %A_workingdir%\tmp\rdplist
	{
	sleep,100
	fileread,data,%a_workingdir%\SavedConnections\rdp\%a_loopreadline%
	filedelete, %a_workingdir%\SavedConnections\rdp\%a_loopreadline%
	rdp2reset := Decrypt(data,pass)
	pass = %resetmasterpass%
	data = %rdp2reset%
	fileappend,% Encrypt(data,pass),%a_workingdir%\SavedConnections\rdp\%a_loopreadline%
	pass = %mpass%
	}	
	progress,60,RDP Connections Re-Encrypted.
	sleep,2000
	Progress,70,Reading All Telnet/Cisco connections...
	sleep,2000
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\Telnet > %a_workingdir%\tmp\Telnetlist,, hide
	run, %comspec% /c dir /b %a_workingdir%\SavedConnections\cisco > %a_workingdir%\tmp\ciscolist,, hide
	sleep,200
	progress,75,Decrypting and Re-Encrypting Telnet&Cisco
	Loop, read, %A_workingdir%\tmp\Telnetlist
	{
	sleep,100
	fileread,data,%a_workingdir%\SavedConnections\Telnet\%a_loopreadline%
	filedelete, %a_workingdir%\SavedConnections\Telnet\%a_loopreadline%
	Telnet2reset := Decrypt(data,pass)
	pass = %resetmasterpass%
	data = %Telnet2reset%
	fileappend,% Encrypt(data,pass),%a_workingdir%\SavedConnections\Telnet\%a_loopreadline%
	pass = %mpass%
	}
	Loop, read, %A_workingdir%\tmp\ciscolist
	{
	sleep,100
	fileread,data,%a_workingdir%\SavedConnections\cisco\%a_loopreadline%
	filedelete, %a_workingdir%\SavedConnections\cisco\%a_loopreadline%
	cisco2reset := Decrypt(data,pass)
	pass = %resetmasterpass%
	data = %cisco2reset%
	fileappend,% Encrypt(data,pass),%a_workingdir%\SavedConnections\cisco\%a_loopreadline%
	pass = %mpass%
	}	
	progress,80,Telnet/Cisco Re-Encrypted.
	sleep,2000
	progress,85,Resetting Initial Password..
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

;Use this label to have window keep its position after being destroyed
guidestroykeeppos:
WinGetPos,x,y
;MsgBox %x% %y%
gui2wasdestroyed = 1
possaved = 1
gui, 2:destroy
gosub mainmenu

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

