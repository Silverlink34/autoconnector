SetWorkingDir %a_mydocuments%\AutoConnector
Loop, read, %A_workingdir%\tmp\sshlist
{
	msgbox, %a_loopreadline%
	ifequal, %a_index%, 1
		gui, 2:add, button, section xs Y+20 gSSH1, %a_loopreadline%
	ifequal, %a_index%, 6
		gui, 2:add, button, ys gSSH6, %a_loopreadline%
	gui, 2:add, button, gSSH%a_index%, %a_loopreadline%
}
return

old detect script
fileread, vsshlist, %a_workingdir%\tmp\sshlist
stringreplace, vsshlist, vsshlist,`r`n,],all
stringsplit, SSH, vsshlist,]
	ifgreater, SSH0, 1
	{
		gui, 2:add, button, section xs Y+20 gSSH1, %SSH1%
	}
	ifgreater, SSH0, 2
	{
		gui, 2:add, button, gSSH2, %SSH2%
	}
	ifgreater, SSH0, 3
	{
		gui, 2:add, button, gSSH3, %SSH3%
	}
	ifgreater, SSH0, 4
	{
		gui, 2:add, button, gSSH4, %SSH4%
	}
	ifgreater, SSH0, 5
	{
		gui, 2:add, button, gSSH5, %SSH5%
	}
	ifgreater, SSH0, 6
	{
		gui, 2:add, button, ys gSSH6, %SSH6%
	}
	ifgreater, SSH0, 7
	{
		gui, 2:add, button, gSSH7, %SSH7%
	}
	ifgreater, SSH0, 8
	{
		gui, 2:add, button, gSSH8, %SSH8%
	}
	ifgreater, SSH0, 9
	{
		gui, 2:add, button, gSSH9, %SSH9%
	}
	ifgreater, SSH0, 10
	{
		gui, 2:add, button, gSSH10, %SSH10%
	}