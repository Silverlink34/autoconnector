; <COMPILER: v1.1.07.03>

MsgBox, 64, Encryption Utility, Created by Cephei1`n`nCephei1@hotmail.co.uk`nhttp://www.autohotkey.com/community/viewtopic.php?f=2&t=89137

#Persistent

#SingleInstance, Force

#NoEnv

#NoTrayIcon

ListLines, Off

SetWinDelay,-1

SetBatchLines,-1

FilePath = %1%

Loop, %FilePath% {

FilePath := A_LoopFileLongPath

Break

}

If !! FilePath

{

IfExist, % FilePath

{

FileRead, Data, % FilePath

SplitPath, FilePath, FileName, Dir, Ext, FileNameNoExt

}

}

Else

Dir := "None", FileName := "None"

Gui, Font, S10, Verdana

Gui, +Resize MinSize500x100

Gui, Add, Button, gSelectFile, Select a file

Gui, Add, Text, , Path:`t`n`nName:

Gui, Add, Text, x+ yp w480 vDir, %Dir%`n

Gui, Add, Text, xp y+ w480 vFileName, %FileName%

Gui, Add, Button, x10 y+10 gEncrypt, Encrypt

Gui, Add, Button, x+10 yp gDecrypt, Decrypt

Gui, Show, , Encryption Utility

Return

GuiEscape:

GuiClose:

ExitApp

SelectFile:

FileSelectFile, FilePath, , % A_MyDocuments, Select a file, Text Documents (*.txt)

If ErrorLevel

Return

If (!FilePath || FilePath = "None")

Return

IfExist, % FilePath

{

SplitPath, FilePath, FileName, Dir, Ext, FileNameNoExt

GuiControl, , Dir, %Dir%

GuiControl, , FileName, %FileName%

FileRead, Data, % FilePath

}

Return

Encrypt:

If FilePath = None

{

Msgbox, 64, Encryption Utility, You did not select a file!

Return

}

InputBox, Pass, Encrypt, Enter a password to use for encryption.`n(You can encrypt without a password too)

If Errorlevel

{

Msgbox, 64, Encryption Utility, You cancelled. Try again...

Return

}

SplitPath, FilePath, FileName, Dir, Ext, FileNameNoExt

FileRead, Data, % FilePath

SavePath := Dir "\" FileNameNoExt "_Encrypted." Ext

FileDelete, % SavePath

FileAppend, % Encrypt(Data,Pass), % SavePath

Msgbox, 64, Encryption Utility, '%FileName%.%Ext%' Encrypted!`nNew encrypted version is saved in the same folder as the original.

Run % "explorer.exe /select," SavePath

Return

Decrypt:

If FilePath = None

{

Msgbox, 64, Encryption Utility, You did not select a file!

Return

}

InputBox, Pass, Decrypt, Enter a password to use for decryption (if you set one).

If Errorlevel

{

Msgbox, 64, Encryption Utility, You cancelled. Try again...

Return

}

SplitPath, FilePath, FileName, Dir, Ext, FileNameNoExt

FileRead, Data, % FilePath

SavePath := Dir "\" FileNameNoExt "_Decrypted." Ext

FileDelete, % SavePath

FileAppend, % Decrypt(Data,Pass), % SavePath

Msgbox, 64, Encryption Utility, '%FileName%.%Ext%' Decrypted!`nNew Decrypted version is saved in the same folder as the original.

Run % "explorer.exe /select," SavePath

Return

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

,sBox%a% := (sBox%b%+0, sBox%b% := sBox%a%)

Loop % StrLen(Data)//2

i := A_Index  & 255

,j := sBox%i% + j  & 255

,k := sBox%i% + sBox%j%  & 255

,sBox%i% := (sBox%j%+0, sBox%j% := sBox%i%)

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

,sBox%a% := (sBox%b%+0, sBox%b% := sBox%a%)

Loop Parse, Data

i := A_Index & 255

,j := sBox%i% + j  & 255

,k := sBox%i% + sBox%j%  & 255

,sBox%i% := (sBox%j%+0, sBox%j% := sBox%i%)

,Result .= SubStr(Asc(A_LoopField)^sBox%k%, -1, 2)

StringReplace Result, Result, x, 0, All

SetFormat Integer, %Format%

Return Result

}