#include "USB-Backup_Tools_Binaries.au3"

; #FUNCTION# ====================================================================================================================
; Name ..........: DoBackup_PrepareExefiles
; Description ...: Stellt die passende vscsc.exe usw. zur Verfügung und lädt auch die benutzten Dll Files
; Syntax ........: DoBackup_PrepareExefiles($sTempPath)
; Author ........: Tino Reichardt
; Modified ......: 17.04.2014
; ===============================================================================================================================
Func DoBackup_PrepareExefiles($sTempPath)
	Local $bVSCSC = ""
	Switch @OSVersion
		Case "WIN_XP" ; Windows XP hat eigene Version
			If Not FileExists($sTempPath & "vscsc.exe") Then $bVSCSC = _vscscxpexe(False)
		Case "WIN_2003" ; Windows Server 2003 auch
			If Not FileExists($sTempPath & "vscsc.exe") Then $bVSCSC = _vscscw2003exe(False)
		Case Else
			; alle anderen haben einheitlich neuen standard
			If @OSArch = "X86" Then
				If Not FileExists($sTempPath & "vscsc.exe") Then $bVSCSC = _vscscx32exe(False)
			Else
				If Not FileExists($sTempPath & "vscsc.exe") Then $bVSCSC = _vscscx64exe(False)
			EndIf
	EndSwitch
	If $bVSCSC <> "" Then FileWrite($sTempPath & "vscsc.exe", $bVSCSC)
	$bVSCSC = ""

	Local $b7zDll = ""
	Local $b7zExe = ""
	If @OSArch = "X86" Then
		If Not FileExists($sTempPath & "7z.dll") Then $b7zDll  =_7zx32dll(False)
		If Not FileExists($sTempPath & "7zg-mini.exe") Then $b7zExe = _7zgx32exe(False)
	Else
		If Not FileExists($sTempPath & "7z.dll") Then $b7zDll  = _7zx64dll(False)
		If Not FileExists($sTempPath & "7zg-mini.exe") Then $b7zExe = _7zgx64exe(False)
	EndIf

	If $b7zDll <> "" Then FileWrite($sTempPath & "7z.dll", $b7zDll)
	$b7zDll = ""

	If $b7zExe <> "" Then FileWrite($sTempPath & "7zg-mini.exe", $b7zExe)
	$b7zExe = ""

	Local $bSyncExe = ""
	If Not FileExists($sTempPath & "sync.exe") Then $bSyncExe = _syncexe(False)
	$bSyncExe = ""
EndFunc   ;==>DoBackup_PrepareExefiles
