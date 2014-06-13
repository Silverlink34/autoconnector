fileread, svdconnlist, %a_workingdir%/tmp/connlist
stringsplit, connection, svdconnlist, `r,`n
msgbox, %connection1% %connection2%