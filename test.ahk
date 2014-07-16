SetWorkingDir %a_mydocuments%\AutoConnector
fileread,data,%a_workingdir%\config2
questions := Decrypt(data,pass)
stringsplit,answernum,questions,%a_tab%,,
pass = %answernum1%
^!c::
fileread,data,%a_workingdir%\SavedConnections\cisco\Windstream Modem
ciscocreds := Decrypt(data,pass)
stringsplit,ciscocredfilter,ciscocreds,%a_tab%
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
return
!^q::
exitapp

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