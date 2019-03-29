#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=USB-Backup.ico
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Homepage: https://www.mcmilk.de/projects/USB-Backup/
#AutoIt3Wrapper_Res_Description=Encrypted Backup on external Storage
#AutoIt3Wrapper_Res_Fileversion=0.5.0.8
#AutoIt3Wrapper_Res_ProductVersion=0.5.0.8
#AutoIt3Wrapper_Res_LegalCopyright=© 2014 - 2019 Tino Reichardt
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Res_Field=Productname|USB-Backup
#AutoIt3Wrapper_Res_Field=CompanyName|Tino Reichardt / LKEE
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Res_Icon_Add=icos\03.ico
#AutoIt3Wrapper_Res_Icon_Add=icos\04.ico
#AutoIt3Wrapper_Res_Icon_Add=icos\05.ico
#AutoIt3Wrapper_Res_Icon_Add=icos\06.ico
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /sv /rm /mi 6
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs
	Copyright © 2014 - 2019 Tino Reichardt

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License Version 2, as
	published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
#ce

; ctime: /TR 2014-04-16
; mtime: /TR 2019-03-29

Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 1 + 2 + 4)
Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Opt("WinTitleMatchMode", 2)
Opt("WinDetectHiddenText", 1)

#include <APIDlgConstants.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <Constants.au3>
#include <Crypt.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiListBox.au3>
#include <GuiTab.au3>
#include <GuiTreeView.au3>
#include <Math.au3>
#include <Misc.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <TreeViewConstants.au3>
#include <WinAPIDlg.au3>
#include <WinAPIFiles.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>

; own include files:
#include "FFLabels.au3"
#include "Sha3.au3"
#include "DrawPie.au3"
;#include "PrintFromArray.au3"

#include "USB-Backup_Tools.au3"

; Titel, Name und so weiter definieren...
Global Const $sAppName = "USB-Backup"
Global Const $sTitle = $sAppName
Global Const $sVersion = "0.5"

; USB-Backup.exe Version -> ist in der exe hardcoded!
Global $sUpdateAppVersion = FileGetVersion(@ScriptFullPath)

; Update Funktion
; "version.txt" -> "$AppVer,$ChmVer\n"
; "USB-Backup.exe" -> @autostart
; "de-DE.ini" -> @ %APPDATA%\Language.ini (wenn @OSLANG=0407)
Global Const $sUpdateURL = "http://www.mcmilk.de/projects/USB-Backup/" ; with / @ end!!!
Global $iHasNewUpdate = 0 ; 0=no update 1=new-exe
Global $aInetVersion = 0

; Standardmaße der App
Global Const $myWidth = 800
Global Const $myHeight = 400

; Array mit Verzeichnissen, welche gesichert werden sollen
Global $aFilePaths[1] = [0]
Global $aFilePathsTS[1] = [0]

; Array mit Sticks, auf denen gesichert werden darf, Format:
Global $aUSBSticks[1] = [0]

; derzeit aktive USB Sticks am System
; [0][0]-> Laufwerke
; [0][1]-> Sticks bzw. Geräte
; [1][0] -> Name
; [1][1] -> ID
; [1][2] -> E:
; [1][3] -> E
; [1][4] -> some-password
; [1][5] -> E:\USB-Backup\User@Host\
Global Enum $eDeviceName = 0, $eDeviceID, $eFullDrive, $eDriveLetter, $ePassword, $eBackupPath
Global $aCurrentSticks[1][6] = [[0, 0, 0, 0, 0, 0]]
Global $iTrayTipTime = 15 ; Zeit, für die TrayTip() Anweisungen

; aktuelle und registrierte Sticks, auf denen quasi gesichert werden kann
; - enthält Index zum $aCurrentSticks[] array
; - [0] anzahl der sticks
; - wird benutzt, um das Tray zu aktualisieren
Global $aCurrentSticksOkay[1] = [0]

; diverse globale Variablen, für schnellen Zugriff
Global $sAppPath = @AppDataDir & "\" & $sAppName & "\"
Global $sTempPath = @TempDir & "\" & $sAppName & "-" & _WinAPI_CreateGUID() & "\"
Global $sSaltValue = "0"

; diese globals sind auch als Option in der INI anpassbar
Global $s7ZipCreateCmd = '7zg-mini a "%A" %o -m0=zstd -mx2 -ms=on -mhe -slp -ssc -ssw -scsWIN -p"%P" "%p"'
Global $s7ZipUpdateCmd = '7zg-mini u "%A" %o -m0=zstd -mx2 -ms=on -mhe -slp -ssc -ssw -scsWIN -p"%P" -u- -up0q3r2x2y2z0w2!"%U" "%p"'
Global $sDebug7ZipCmd = "0"

; Priority for the 7-Zip Commands: IDLE_PRIORITY_CLASS / NORMAL_PRIORITY_CLASS
Global $s7ZipPriority = "idle" ; "idle" / "normal"

Global $sMaxFullBackups = "0" ; 0=egal, ansonsten 1 -> maximal ein full backup, danach nur noch updates...
Global $sFullBackupIn = "365" ; in Tage (about one year)
Global $sShowUpdateHint = "7" ; in Tage, oder 0=aus
Global $sShowEditConfig = "1"
Global $sShowEditIndex = "0"
Global $sShowWriteIndex = "0"
Global $sShowStatusMessage = "1"
Global $sEnableVSS = "0"
Global $sDebugVSCSCCmd = "0"
Global $sUsePowerPlan = "1"
Global $sDebugPowerPlan = "0"
Global $sCheckForUpdate = "1"
Global $sNewVersionHint = "300" ; in Sekunden / alle 5 Minuten
Global $sFileNameLen = "16"
Global $sEditor = "notepad.exe"
Global $sRunBeforeCmd = ""
Global $sRunAfterCmd = ""

; +1 ,wenn sich Konfigurationsvariablen ändern und INI deshalb lieber komplett neu erstellt wird
Global $sIniVersion = "6"

; TrayMenu Variablen, welche global sein müssen
Global $aTrayItems[1] = [0] ; alle ID's der Controls
Global $aBackupTray[1] = [0] ; ID's der "Sicherung auf X:" Controls
Global $aIndexEditTray[1] = [0] ; ID's der "Index von X: bearbeiten" Controls
Global $aIndexSaveTray[1] = [0] ; ID's der "Index von X: speichern" Controls
Global $iRegisterStick, $iRegisterPath, $iEditSettings, $iStatus, $iUpdate, $iAbout, $iExit
Global $iRunningBackup = 0 ; contains $hGUI of Backup Window
Global $iPowerPlanPid = 0

Global $hGUI = 0
Global $gGuiStyle = BitOR($WS_CAPTION, $WS_POPUP)
Global $gGuiExStyle = -1

; AppPath und Logfile Path erstellen
If Not FileExists($sAppPath & "Logfiles") Then DirCreate($sAppPath & "Logfiles")

; reading language stuff first...
#include "USB-Backup_Lang.au3"
InitLanguage()

; wenn es schon läuft, nix weiter machen...
If _Singleton($sTitle, 1) = 0 Then
	MsgBox($MB_OK, $sTitle, Msg($mMessages[1]))
	Exit
EndIf

; entry point für das programm
InitBackup()

; erstmaliger aufruf...
Func InitBackup()

	; löschen von alten USB-Backup-{*} Verzeichnissen... falls nötig:
	Local $hSearch = FileFindFirstFile(@TempDir & "\" & $sAppName & "-{*}")
	If $hSearch <> -1 Then
		While 1
			Local $sFileName = FileFindNextFile($hSearch)
			If @error Then ExitLoop
			DirRemove(@TempDir & "\" & $sFileName, 1)
			;ConsoleWrite("delete: " & @TempDir & "\" & $sFileName & @CRLF)
		WEnd
	EndIf

	; Start Crypto / GDI+
	_Crypt_Startup()
	_GDIPlus_Startup()

	ReadConfiguration()
	GetCurrentSticks()
	CheckForUpdate()

	; 1x die sekunde checken wir, ob da änderungen bei den sticks zu sehen sind
	AdlibRegister("GetCurrentSticks", 500)

	; auf Updates Checken, jede Stunde mal... sofern der Check nicht aus ist
	AdlibRegister("CheckForUpdate", 1000 * 60 * 60)
	AdlibRegister("NewVersionHint", 1000 * $sNewVersionHint)

	OnAutoItExitRegister("QuitBackup")
	TrayInitMenu()
EndFunc   ;==>InitBackup

; wird beim beenden ausgeführt, hier sollte endgültig aufgräumt werden!
Func QuitBackup()
	FileChangeDir(@ScriptDir)
	; das tempdir löschen, inkl. aller Dateien da drinnen
	If FileExists($sTempPath) Then DirRemove($sTempPath, 1)

	; Shutdown Crypto / GDI+
	_Crypt_Shutdown()
	_GDIPlus_Shutdown()
EndFunc   ;==>QuitBackup

Func FatalError($sMsg)
	MsgBox($MB_ICONERROR, Msg($mHeadlines[1], $sTitle), _
			$sMsg & @CRLF & @CRLF & Msg($mMessages[2]))
	; we are returning now... may cause bigger probs... but people should mail me if that happens!
	Return
EndFunc   ;==>FatalError

Func DisableTrayMenu()
	For $i = 1 To $aTrayItems[0]
		TrayItemDelete($aTrayItems[$i])
	Next
	ReDim $aTrayItems[1]
	$aTrayItems[0] = 0

	; Temp Dir erstellen
	If Not FileExists($sTempPath) Then
		DirCreate($sTempPath)
	EndIf

	; irgendein GUI ist offen, also nicht nerven...
	AdlibUnRegister("CheckNeedNewBackup")
EndFunc   ;==>DisableTrayMenu

Func EnableTrayMenu()
	DisableTrayMenu()

	If $iRunningBackup <> "0" Then
		$iStatus = TrayCreateItem(Msg($mTaskTray[5]))
		_ArrayAdd($aTrayItems, $iStatus)
		$iExit = TrayCreateItem(Msg($mTaskTray[6]))
		_ArrayAdd($aTrayItems, $iExit)
		$aTrayItems[0] = UBound($aTrayItems) - 1
		Return
	EndIf

	Local $aDrives = $aCurrentSticksOkay
	Local $c

	ReDim $aBackupTray[$aDrives[0] + 1]
	ReDim $aIndexSaveTray[$aDrives[0] + 1]
	ReDim $aIndexEditTray[$aDrives[0] + 1]
	$aBackupTray[0] = $aDrives[0]
	$aIndexEditTray[0] = $aDrives[0]
	$aIndexSaveTray[0] = $aDrives[0]

	If $aFilePaths[0] <> 0 Then
		For $i = 1 To $aDrives[0]
			Local $sDrive = $aCurrentSticks[$aDrives[$i]][$eFullDrive]
			$aBackupTray[$i] = TrayCreateItem(Msg($mTaskTray[7], $sDrive))
			_ArrayAdd($aTrayItems, $aBackupTray[$i])
		Next

		If $aDrives[0] > 0 Then
			$c = TrayCreateItem("") ; separator line
			_ArrayAdd($aTrayItems, $c)
		EndIf
	EndIf

	$c = TrayCreateMenu(Msg($mTaskTray[8]))
	_ArrayAdd($aTrayItems, $c)
	$iRegisterStick = TrayCreateItem(Msg($mTaskTray[9]), $c)
	_ArrayAdd($aTrayItems, $iRegisterStick)
	$iRegisterPath = TrayCreateItem(Msg($mTaskTray[10]), $c)
	_ArrayAdd($aTrayItems, $iRegisterPath)

	If $sShowEditConfig = "1" Then
		$iEditSettings = TrayCreateItem(Msg($mTaskTray[11]), $c)
		_ArrayAdd($aTrayItems, $iEditSettings)
	EndIf

	For $i = 1 To $aDrives[0]
		If $sShowEditIndex = "1" Then
			$aIndexEditTray[$i] = TrayCreateItem(Msg($mTaskTray[12], $aCurrentSticks[$aDrives[$i]][$eFullDrive]), $c)
			_ArrayAdd($aTrayItems, $aIndexEditTray[$i])
		EndIf
		If $sShowWriteIndex = "1" Then
			$aIndexSaveTray[$i] = TrayCreateItem(Msg($mTaskTray[13], $aCurrentSticks[$aDrives[$i]][$eFullDrive]), $c)
			_ArrayAdd($aTrayItems, $aIndexSaveTray[$i])
		EndIf
	Next

	$iStatus = TrayCreateItem(Msg($mTaskTray[1]))
	_ArrayAdd($aTrayItems, $iStatus)
	If $iHasNewUpdate <> 0 Then
		$iUpdate = TrayCreateItem(Msg($mTaskTray[2]))
		_ArrayAdd($aTrayItems, $iUpdate)
	Else
		; be sure, it will be ignored...
		$iUpdate = -1000
	EndIf
	$iAbout = TrayCreateItem(Msg($mTaskTray[3]))
	_ArrayAdd($aTrayItems, $iAbout)
	$c = TrayCreateItem("") ; separator line
	_ArrayAdd($aTrayItems, $c)
	$iExit = TrayCreateItem(Msg($mTaskTray[4]))
	_ArrayAdd($aTrayItems, $iExit)
	$aTrayItems[0] = UBound($aTrayItems) - 1

	; Benutzer alle 5min nerven, wenn das Backup zu alt ist ;) - nicht änderbar!
	AdlibRegister("CheckNeedNewBackup", 1000 * 300)

	; ab nun haben wir nen tray
	TraySetState($TRAY_ICONSTATE_SHOW)
EndFunc   ;==>EnableTrayMenu

; KEIN Stick ist drinnen
Func TrayIcon_NoStick()
	Local $iUpdateNeeded = CheckNeedNewBackup()

	If $iUpdateNeeded == 0 Then
		TraySetIcon(@ScriptFullPath, -4)
	Else
		; mit ausrufezeichen
		TraySetIcon(@ScriptFullPath, -6)
	EndIf
EndFunc   ;==>TrayIcon_NoStick

; irgendein Stick ist drinnen
Func TrayIcon_SomeStick()
	Local $iUpdateNeeded = CheckNeedNewBackup()

	If $iUpdateNeeded == 0 Then
		TraySetIcon(@ScriptFullPath, -3)
	Else
		; mit ausrufezeichen
		TraySetIcon(@ScriptFullPath, -5)
	EndIf
EndFunc   ;==>TrayIcon_SomeStick

; Backup Stick ist drinnen
Func TrayIcon_BackupStick()
	; tasche -> passender stick, icon ist in der exe
	TraySetIcon(@ScriptFullPath, -1)
EndFunc   ;==>TrayIcon_BackupStick

; baut uns ein kleines schickes Tray zusammen
Func TrayInitMenu()
	UpdateCurrentSticks()
	TraySetToolTip($sTitle)

	While 1
		Local $msg = TrayGetMsg()
		Switch $msg
			Case 0, $GUI_EVENT_MOUSEMOVE, $GUI_EVENT_PRIMARYDOWN, $GUI_EVENT_PRIMARYUP, $GUI_EVENT_SECONDARYDOWN, $GUI_EVENT_SECONDARYUP
				; ignore these

			Case $iRegisterStick
				DisableTrayMenu()
				RegisterStick()
				UpdateCurrentSticks()

			Case $iRegisterPath
				DisableTrayMenu()
				RegisterPath()
				UpdateCurrentSticks()

			Case $iEditSettings
				DisableTrayMenu()
				RunWait($sEditor & " " & $sAppPath & $sAppName & '.ini')
				ReadConfiguration()
				UpdateCurrentSticks()

			Case $iUpdate
				DisableTrayMenu()
				DownloadUpdates()
				UpdateCurrentSticks()

			Case $iAbout
				DisableTrayMenu()
				AboutBox()
				UpdateCurrentSticks()

			Case $iStatus
				DisableTrayMenu()
				GetCurrentSticks()
				UpdateCurrentSticks()

				Local $sText = Msg($mStatusMessage[1]) & @CRLF & @CRLF
				$sText &= Msg($mStatusMessage[2]) & " " & $aUSBSticks[0] & @CRLF
				$sText &= Msg($mStatusMessage[3]) & " " & $aFilePaths[0]
				If $aCurrentSticksOkay[0] <> 0 Then
					$sText &= @CRLF & Msg($mStatusMessage[4]) & " " & $aCurrentSticksOkay[0]
				EndIf
				Local $iTS = GetOldestBackup()
				If $iTS <> 0 Then
					$sText &= @CRLF & Msg(StringFormatTime($mStatusMessage[5], $iTS))
				EndIf
				TrayTip($sAppName & " " & $sVersion, $sText, $iTrayTipTime, $TIP_ICONASTERISK)

			Case $iExit
				; der einzige ausgang ;)
				Exit

			Case $TRAY_EVENT_PRIMARYDOUBLE
				; hm... vlt. machen wir mal was mit dem doppelklick ...

			Case Else
				For $i = 1 To $aBackupTray[0]
					Local $id = $aCurrentSticksOkay[$i]

					; backup erstellen?
					If $aBackupTray[$i] = $msg Then
						DisableTrayMenu()
						ChooseBackup($id)
						EnableTrayMenu()
					EndIf

					; index bearbeiten?
					If $aIndexEditTray[$i] = $msg Then
						DisableTrayMenu()
						If Not GetPasswordForID($id) Then
							EnableTrayMenu()
							ExitLoop
						EndIf
						RunWait($sEditor & " " & GetTempIndex($id))
						UpdateIndexFile($id)
						EnableTrayMenu()
					EndIf

					; index speichern?
					If $aIndexSaveTray[$i] = $msg Then
						If Not GetPasswordForID($id) Then ExitLoop
						UpdateIndexFile($id)
					EndIf
				Next
		EndSwitch
	WEnd

	; sobald das Programm richtig beendet wird, schreiben wir nochmal die Konfiguration...
	WriteConfiguration()
EndFunc   ;==>TrayInitMenu

; #FUNCTION# ====================================================================================================================
; Name ..........: ReadConfiguration
; Description ...: Lesen der aktuellen Konfiguration von Appdata/Appname/Appname.ini
; Syntax ........: ReadConfiguration()
; Parameters ....: None
; Return values .: IniDatei lesen und @ $aFilePaths und $aUSBSticks speichern
; Author ........: Tino Reichardt
; Modified ......: 15.04.2014
; ===============================================================================================================================
Func ReadConfiguration()
	Local $sInifile = $sAppPath & $sAppName & '.ini'
	Local $sOldVersion
	Local $aTemp

	$aTemp = IniReadSection($sInifile, 'USB Devices')
	If @error <> 1 Then
		$aUSBSticks[0] = $aTemp[0][0]
		ReDim $aUSBSticks[$aUSBSticks[0] + 1]
		For $i = 1 To $aUSBSticks[0]
			$aUSBSticks[$i] = $aTemp[$i][1]
		Next
	EndIf

	$aTemp = IniReadSection($sInifile, 'Backup Paths')
	If @error <> 1 Then
		Local $n = $aTemp[0][0]
		$aFilePaths[0] = $n
		$aFilePathsTS[0] = $n
		ReDim $aFilePaths[$n + 1]
		ReDim $aFilePathsTS[$n + 1]
		For $i = 1 To $n
			Local $a = StringSplit($aTemp[$i][1], "|")
			If $a[0] = 2 Then
				$aFilePaths[$i] = $a[1]
				$aFilePathsTS[$i] = $a[2]
			Else
				$aFilePaths[$i] = $a[1]
				$aFilePathsTS[$i] = 0 ; unset TimeStamp
			EndIf
		Next
	EndIf

	$sOldVersion = IniRead($sInifile, "Options", "IniVersion", "0")
	If $sIniVersion = 0 Then
		WriteConfiguration()
	ElseIf $sIniVersion > $sOldVersion Then
		; alte Optionen komplett löschen...
		IniDelete($sInifile, "Options")
		; defaultwerte neu setzen...
		WriteConfiguration()
	EndIf

	$s7ZipCreateCmd = IniRead($sInifile, "Options", "7ZipCreateCmd", $s7ZipCreateCmd)
	$s7ZipUpdateCmd = IniRead($sInifile, "Options", "7ZipUpdateCmd", $s7ZipUpdateCmd)
	$s7ZipPriority = IniRead($sInifile, "Options", "7ZipPriority", $s7ZipPriority)
	$sMaxFullBackups = IniRead($sInifile, "Options", "MaxFullBackups", $sMaxFullBackups)
	$sFullBackupIn = IniRead($sInifile, "Options", "FullBackupIn", $sFullBackupIn)
	$sCheckForUpdate = IniRead($sInifile, "Options", "CheckForUpdate", $sCheckForUpdate)
	$sShowUpdateHint = IniRead($sInifile, "Options", "ShowUpdateHint", $sShowUpdateHint)
	$sNewVersionHint = IniRead($sInifile, "Options", "NewVersionHint", $sNewVersionHint)
	$sShowEditIndex = IniRead($sInifile, "Options", "ShowEditIndex", $sShowEditIndex)
	$sShowEditConfig = IniRead($sInifile, "Options", "ShowEditConfig", $sShowEditConfig)
	$sShowWriteIndex = IniRead($sInifile, "Options", "ShowWriteIndex", $sShowWriteIndex)
	$sDebugVSCSCCmd = IniRead($sInifile, "Options", "DebugVSCSCCmd", $sDebugVSCSCCmd)
	$sEnableVSS = IniRead($sInifile, "Options", "EnableVSS", $sEnableVSS)
	$sDebug7ZipCmd = IniRead($sInifile, "Options", "Debug7ZipCmd", $sDebug7ZipCmd)
	$sFileNameLen = IniRead($sInifile, "Options", "FileNameLen", $sFileNameLen)
	$sEditor = IniRead($sInifile, "Options", "Editor", $sEditor)
	$sRunBeforeCmd = IniRead($sInifile, "Options", "RunBeforeCmd", $sRunBeforeCmd)
	$sRunAfterCmd = IniRead($sInifile, "Options", "RunAfterCmd", $sRunAfterCmd)
	$sUsePowerPlan = IniRead($sInifile, "Options", "UsePowerPlan", $sUsePowerPlan)
	$sDebugPowerPlan = IniRead($sInifile, "Options", "DebugPowerPlan", $sDebugPowerPlan)
	$sShowStatusMessage = IniRead($sInifile, "Options", "ShowStatusMessage", $sShowStatusMessage)

	; war nie fertig, werde ich wohl auch nie machen ;)
	IniDelete($sInifile, "Options", "ChmVersion")

	; hier wollen wir direkt mit integer arbeiten...
	$sFileNameLen = Int($sFileNameLen)
	$sMaxFullBackups = Int($sMaxFullBackups)

	; just write an cleanup version after parsing...
	WriteConfiguration()
EndFunc   ;==>ReadConfiguration

; #FUNCTION# ====================================================================================================================
; Name ..........: WriteConfiguration
; Description ...: Schreiben der aktuellen Konfiguration nach Appdata/Appname/Appname.ini
; Syntax ........: WriteConfiguration(), es werden ganze Sektionen geschrieben, damit alte Werte weg sind!
; Parameters ....: None
; Return values .: None
; Author ........: Tino Reichardt
; Modified ......: 16.04.2014
; ===============================================================================================================================
Func WriteConfiguration()
	Local $sInifile = $sAppPath & $sAppName & '.ini'
	Local $sTemp

	; key=value pair delimited by @LF, wir speichern immer sortiert...
	$sTemp = ""
	_ArraySort($aUSBSticks, 0, 1)
	For $i = 1 To $aUSBSticks[0]
		$sTemp &= $i & "=" & $aUSBSticks[$i] & @LF
	Next
	IniWriteSection($sInifile, 'USB Devices', $sTemp)

	; das hier ist nun etwas komplexer, da wir den TS nachträglich mit dazu geholt haben :(
	Dim $aTemp[$aFilePaths[0] + 1][2]
	$aTemp[0][0] = $aFilePaths[0]
	For $i = 1 To $aFilePaths[0]
		$aTemp[$i][1] = $aFilePaths[$i] & "|" & $aFilePathsTS[$i]
	Next
	_ArraySort($aTemp, 0, 0, 0, 1)
	For $i = 1 To $aFilePaths[0]
		$aTemp[$i][0] = $i
	Next
	;ConsoleWrite("danach:" & @CRLF)
	;_PrintFromArray($aTemp)
	IniWriteSection($sInifile, 'Backup Paths', $aTemp)

	IniWrite($sInifile, "Options", "FullBackupIn", $sFullBackupIn)
	IniWrite($sInifile, "Options", "MaxFullBackups", $sMaxFullBackups)
	IniWrite($sInifile, "Options", "ShowUpdateHint", $sShowUpdateHint)
	IniWrite($sInifile, "Options", "NewVersionHint", $sNewVersionHint)
	IniWrite($sInifile, "Options", "CheckForUpdate", $sCheckForUpdate)
	IniWrite($sInifile, "Options", "ShowEditIndex", $sShowEditIndex)
	IniWrite($sInifile, "Options", "ShowEditConfig", $sShowEditConfig)
	IniWrite($sInifile, "Options", "ShowWriteIndex", $sShowWriteIndex)
	IniWrite($sInifile, "Options", "EnableVSS", $sEnableVSS)
	IniWrite($sInifile, "Options", "DebugVSCSCCmd", $sDebugVSCSCCmd)
	IniWrite($sInifile, "Options", "Debug7ZipCmd", $sDebug7ZipCmd)
	IniWrite($sInifile, "Options", "DebugPowerPlan", $sDebugPowerPlan)
	IniWrite($sInifile, "Options", "7ZipCreateCmd", $s7ZipCreateCmd)
	IniWrite($sInifile, "Options", "7ZipUpdateCmd", $s7ZipUpdateCmd)
	IniWrite($sInifile, "Options", "7ZipPriority", $s7ZipPriority)
	IniWrite($sInifile, "Options", "FileNameLen", $sFileNameLen)
	IniWrite($sInifile, "Options", "Editor", $sEditor)
	IniWrite($sInifile, "Options", "IniVersion", $sIniVersion)
	IniWrite($sInifile, "Options", "RunBeforeCmd", $sRunBeforeCmd)
	IniWrite($sInifile, "Options", "RunAfterCmd", $sRunAfterCmd)
	IniWrite($sInifile, "Options", "UsePowerPlan", $sUsePowerPlan)
	IniWrite($sInifile, "Options", "ShowStatusMessage", $sShowStatusMessage)

	; not needed anymore...
	IniDelete($sInifile, "Options", "WaitForStickTime")
EndFunc   ;==>WriteConfiguration

; #FUNCTION# ====================================================================================================================
; Name ..........: GetWMIServiceObject
; Description ...: Holt sich Infos zu den aktuell gesteckten USB Sticks ... das dauert eine Weile... schnell ist anders!!
; Syntax ........: GetWMIServiceObject()
; Author ........: Tino Reichardt
; Modified ......: 24.02.2015
; ===============================================================================================================================
Func GetWMIServiceObject()
	Local $objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!\\.\root\CIMV2")
	If Not IsObj($objWMIService) Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[1]))
		Return 0
	EndIf
	Return $objWMIService
EndFunc   ;==>GetWMIServiceObject

; #FUNCTION# ====================================================================================================================
; Name ..........: GetDriveInfos
; Description ...: Holt sich Infos zu den aktuell gesteckten USB Sticks ... das dauert eine Weile... schnell ist anders!!
; Syntax ........: GetDriveInfos()
; Parameters ....: None
; Return values .: None
; Author ........: Tino Reichardt
; Modified ......: 16.04.2014
; ===============================================================================================================================
Func GetDriveInfos()
	Local $objWMIService = GetWMIServiceObject()
	If $objWMIService = 0 Then Return

	Local $i = 1
	Local $aDrives[30][6]

	$aDrives[0][0] = 0
	$aDrives[0][1] = 0

	; für alle USB Festplatten / Sticks
	; Local $oq_drives = $objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive WHERE PNPDeviceID LIKE 'USBSTOR%'")
	Local $oq_drives = $objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive WHERE MediaType = 'External hard disk media' Or MediaType = 'Removable media'")
	For $drive In $oq_drives
		If $drive.Status <> "OK" Then ContinueLoop

		; Anzahl USB Geräte += 1
		$aDrives[0][1] += 1

		; für alle Laufwerke die Partitionen finden
		; WMI Tasks http://msdn.microsoft.com/en-us/library/aa394602%28v=vs.85%29.aspx
		Local $oq_parts = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $drive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition")
		For $part In $oq_parts
			; für Partitionen die entsprechende logische Disk finden
			Local $oq_disks = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & $part.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition")
			For $disk In $oq_disks
				; fill this array
				; Global Enum $eDeviceName = 0, $eDeviceID, $eDriveLetter, $eFullDrive, $ePassword, $eBackupPath
				$aDrives[$i][0] = $drive.Caption ; Linux File-CD Gadget USB Device
				$aDrives[$i][1] = $drive.PNPDeviceID ; USBSTOR\DISK&VEN_CRUCIAL_&PROD_CT480M500SSD1&REV_MU03\0000000000000033&0
				$aDrives[$i][2] = $disk.Caption ; "G:"
				$aDrives[$i][3] = StringLeft($disk.Caption, 1) ; "G"
				$aDrives[$i][4] = "" ; Passwort
				$aDrives[$i][5] = $aDrives[$i][2] & "\" & $sAppName & "\" & @UserName & "@" & @ComputerName & "\" ; BackupPfad
				$aDrives[0][0] = $i ; Anzahl USB Laufwerke += 1
				$i += 1
			Next
		Next
	Next

	; delete unused array elements
	; _ArrayDisplay($aDrives, "vor dem delete ist i=" & $i)
	_ArrayDelete($aDrives, $i & "-29")

	Return $aDrives
EndFunc   ;==>GetDriveInfos

; #FUNCTION# ====================================================================================================================
; Name ..........: GetCurrentSticks
; Description ...: Herausfinden aller am PC gesteckten USB Massenspeicher
; Syntax ........: GetCurrentSticks()
; Author ........: Tino Reichardt
; Modified ......: 04.06.2015
; ===============================================================================================================================
Func GetCurrentSticks()
	Static $iDriveMaskOld = 0
	Local $iDriveMask = _WinAPI_GetLogicalDrives()

	If $iDriveMaskOld = $iDriveMask Then Return
	$iDriveMaskOld = $iDriveMask

	; this will take a while...
	$aCurrentSticks = GetDriveInfos()
	;ConsoleWrite("UPDATE() $iDriveMaskOld=" & $iDriveMaskOld & "  $iDriveMask=" & $iDriveMask & @CRLF)
	UpdateCurrentSticks()
EndFunc   ;==>GetCurrentSticks

; #FUNCTION# ====================================================================================================================
; Name ..........: CheckNeedNewBackup
; Description ...: Prüfen, ob Backups aktuell genug sind
; Syntax ........: CheckNeedNewBackup()
; Author ........: Tino Reichardt
; Modified ......: 09.04.2016
; ===============================================================================================================================
Func CheckNeedNewBackup()

	; $sShowUpdateHint = X -> X Tage -> X * 24 * 60 * 60 Sekunden
	Local $diff = $sShowUpdateHint * 24 * 60 * 60
	Local $ts = GetTimeStamp()
	Local $i, $iMaxDiff = 0

	; _PrintFromArray($aFilePathsTS[0])

	For $i = 1 To $aFilePathsTS[0]
		; neuer Eintrag... wir meckern da noch nicht...
		If $aFilePathsTS[$i] = 0 Then ContinueLoop
		; wir merken uns die älteste Sicherung...
		If $ts - $aFilePathsTS[$i] > $diff Then
			If $ts - $aFilePathsTS[$i] > $iMaxDiff Then $iMaxDiff = $ts - $aFilePathsTS[$i]
		EndIf
	Next

	If $iMaxDiff > 0 Then
		Local $days = Int($iMaxDiff / (24 * 60 * 60))
		If $sShowUpdateHint <> 0 Then
			Local $sText = Msg($mTaskTray[14], $days)
			TrayTip($sAppName & " " & $sVersion, $sText, $iTrayTipTime, $TIP_ICONEXCLAMATION)
		EndIf
		Return $days
	EndIf

	Return 0
EndFunc   ;==>CheckNeedNewBackup

; #FUNCTION# ====================================================================================================================
; Name ..........: GetOldestBackup
; Description ...: Für den StatusTrayTip die Backupzeit errechnen
; Syntax ........: GetOldestBackup()
; Author ........: Tino Reichardt
; Modified ......: 14.06.2015
; ===============================================================================================================================
Func GetOldestBackup()
	Local $i, $ts = 0

	;_PrintFromArray($aFilePathsTS)
	For $i = 1 To $aFilePathsTS[0]
		; we have a new directory here, so the last backup time is not relevant
		If $aFilePathsTS[$i] = 0 Then Return 0

		; first time...
		If $ts = 0 Then $ts = $aFilePathsTS[$i]

		; we want the oldest (smallest) time
		If $aFilePathsTS[$i] < $ts Then $ts = $aFilePathsTS[$i]
	Next

	Return $ts
EndFunc   ;==>GetOldestBackup

; #FUNCTION# ====================================================================================================================
; Name ..........: UpdateCurrentSticks
; Description ...: Prüfen, ob derzeit gesteckte USB Massenspeicher registriert wurden und Tray aktualisieren
; Author ........: Tino Reichardt
; Modified ......: 07.08.2014
; ===============================================================================================================================
Func UpdateCurrentSticks()
	Local $iIsBackupStick = 0
	Local $aOldSticksOkay = $aCurrentSticksOkay

	; erstmal reset
	ReDim $aCurrentSticksOkay[1]
	$aCurrentSticksOkay[0] = 0

	; $aUSBSticks[] hat viele infos, wir speichern aber nicht alle ab...
	For $i = 1 To $aUSBSticks[0]
		Local $aTemp = StringSplit($aUSBSticks[$i], "|", $STR_NOCOUNT)
		For $j = 1 To $aCurrentSticks[0][0]
			; device id hat genug infos
			If $aCurrentSticks[$j][$eDeviceID] = $aTemp[$eDeviceID] Then
				$iIsBackupStick = 1
				ReDim $aCurrentSticksOkay[$aCurrentSticksOkay[0] + 1 + 1]
				$aCurrentSticksOkay[0] += 1
				$aCurrentSticksOkay[$aCurrentSticksOkay[0]] = $j
			EndIf
		Next
	Next


	; TrayMenu aktualisieren
	EnableTrayMenu()

	; icon ändern... sofern nötig
	If $aCurrentSticks[0][0] = 0 Then
		TrayIcon_NoStick()
		Return
	EndIf

	If $iIsBackupStick = 0 Then
		TrayIcon_SomeStick()
	Else
		TrayIcon_BackupStick()
	EndIf
EndFunc   ;==>UpdateCurrentSticks

Func RegisterStickUpdateLists($lstCurrent, $lstRegistered, $aCurrentRegistered)

	; linke seite
	_GUICtrlListBox_ResetContent($lstCurrent)
	If IsArray($aCurrentSticks) Then
		For $i = 1 To $aCurrentSticks[0][0] ; für alle USB Laufwerke
			Local $s = ""
			$s &= " (" & $aCurrentSticks[$i][$eFullDrive] & ")  - "
			$s &= $aCurrentSticks[$i][$eDeviceName]
			GUICtrlSetData($lstCurrent, $s)
		Next
	EndIf

	; rechte seite
	_GUICtrlListBox_ResetContent($lstRegistered)
	If IsArray($aCurrentRegistered) Then
		For $i = 1 To $aCurrentRegistered[0][0]
			Local $s = ""
			$s &= " (" & $aCurrentRegistered[$i][$eFullDrive] & ")  - "
			$s &= $aCurrentRegistered[$i][$eDeviceName]
			GUICtrlSetData($lstRegistered, $s)
		Next
	EndIf
EndFunc   ;==>RegisterStickUpdateLists

; #FUNCTION# ====================================================================================================================
; Name ..........: RegisterStickAdd
; Description ...: hinzufügen eines Sticks zum temporären Array: $aCurrentRegistered
; Syntax ........: RegisterStickAdd()
; Author ........: Tino Reichardt
; Modified ......: 06.08.2014
; ===============================================================================================================================
Func RegisterStickAdd(ByRef $aCurrentRegistered, $i)
	; erstmal prüfen, ob das ding schon in der liste ist...
	For $j = 1 To $aCurrentRegistered[0][0]
		If $aCurrentRegistered[$j][$eDeviceID] = $aCurrentSticks[$i + 1][$eDeviceID] Then
			; ist schon registriert...
			Return
		EndIf
	Next

	; wenn noch nicht in liste, mache es dazu...
	Local $sNew = ""
	$sNew &= $aCurrentSticks[$i + 1][0] & "|"
	$sNew &= $aCurrentSticks[$i + 1][1] & "|"
	$sNew &= $aCurrentSticks[$i + 1][2]
	$aCurrentRegistered[0][0] += 1
	_ArrayAdd($aCurrentRegistered, $sNew)
	; _ArrayDisplay($aCurrentRegistered, "neu drinn1")
EndFunc   ;==>RegisterStickAdd

; #FUNCTION# ====================================================================================================================
; Name ..........: RegisterStickDelete
; Description ...: entfernt einen Stick vom temporären Array: $aCurrentRegistered
; Syntax ........: RegisterStickDelete()
; Author ........: Tino Reichardt
; Modified ......: 06.08.2014
; ===============================================================================================================================
Func RegisterStickDelete(ByRef $aCurrentRegistered, $i)
	$aCurrentRegistered[0][0] -= 1
	_ArrayDelete($aCurrentRegistered, $i + 1)
EndFunc   ;==>RegisterStickDelete

; #FUNCTION# ====================================================================================================================
; Name ..........: RegisterStick
; Description ...: Zum registrieren von neuen Sticks für das Backup das aktuellen Benutzers / Computers
; Syntax ........: RegisterStick()
; Author ........: Tino Reichardt
; Modified ......: 15.04.2014
; ===============================================================================================================================
Func RegisterStick()
	$hGUI = GUICreate(Msg($mHeadlines[2], $sTitle), $myWidth, $myHeight, -1, -1, $gGuiStyle, $gGuiExStyle)

	; wir machen daraus ein 2D array:
	Local $aCurrentRegistered[$aUSBSticks[0] + 1][3]
	For $i = 1 To $aUSBSticks[0]
		Local $aTemp = StringSplit($aUSBSticks[$i], "|", $STR_NOCOUNT)
		$aCurrentRegistered[$i][0] = $aTemp[0]
		$aCurrentRegistered[$i][1] = $aTemp[1]
		$aCurrentRegistered[$i][2] = $aTemp[2]
	Next
	$aCurrentRegistered[0][0] = $aUSBSticks[0] ; counter

	;_ArrayDisplay($aUSBSticks)
	; $aCurrentRegistered -> aktuell registrierte Sticks
	; $aCurrentSticks     -> aktuell gesteckte Sticks

	; GUI aufbauen
	GUICtrlCreateLabel(Msg($mLabels[1]), 8, 8, 361, 24)
	GUICtrlSetFont(-1, 10)
	GUICtrlCreateLabel(Msg($mLabels[2]), 432, 8, 361, 24)
	GUICtrlSetFont(-1, 10)

	Local $lstCurrent = GUICtrlCreateList("", 8, 32, 361, 329, BitOR($LBS_NOTIFY, $WS_VSCROLL))
	Local $btnRegisterStick = GUICtrlCreateButton("-->", 376, 128, 51, 25)
	GUICtrlSetTip(-1, Msg($mLabels[3]))
	Local $btnDeleteStick = GUICtrlCreateButton("<--", 376, 160, 51, 25)
	GUICtrlSetTip(-1, Msg($mLabels[4]))
	Local $lstRegistered = GUICtrlCreateList("", 432, 32, 361, 329, BitOR($LBS_NOTIFY, $WS_VSCROLL))
	Local $btnRefresh = GUICtrlCreateButton(Msg($mButtons[3]), 8, 368, 99, 25)
	Local $btnOkay = GUICtrlCreateButton(Msg($mButtons[1]), 640, 368, 65, 25)
	Local $btnCancel = GUICtrlCreateButton(Msg($mButtons[2]), 710, 368, 85, 25)

	RegisterStickUpdateLists($lstCurrent, $lstRegistered, $aCurrentRegistered)
	GUISetState(@SW_SHOW, $hGUI)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $btnCancel
				ExitLoop

			Case $btnOkay
				; wieder ein 1D Array aUSBSticks[] aus $aCurrentRegistered erzeugen...
				ReDim $aUSBSticks[$aCurrentRegistered[0][0] + 1]
				For $i = 1 To $aCurrentRegistered[0][0]
					$aUSBSticks[$i] = $aCurrentRegistered[$i][0] & "|"
					$aUSBSticks[$i] &= $aCurrentRegistered[$i][1] & "|"
					$aUSBSticks[$i] &= $aCurrentRegistered[$i][2]
				Next
				$aUSBSticks[0] = $aCurrentRegistered[0][0]
				WriteConfiguration()
				ExitLoop

			Case $btnDeleteStick
				Local $i = _GUICtrlListBox_GetCurSel($lstRegistered)
				If $i = -1 Then ContinueLoop
				RegisterStickDelete($aCurrentRegistered, $i)
				RegisterStickUpdateLists($lstCurrent, $lstRegistered, $aCurrentRegistered)

			Case $btnRegisterStick
				Local $i = _GUICtrlListBox_GetCurSel($lstCurrent)
				If $i = -1 Then ContinueLoop
				RegisterStickAdd($aCurrentRegistered, $i)
				RegisterStickUpdateLists($lstCurrent, $lstRegistered, $aCurrentRegistered)

			Case $btnRefresh
				RegisterStickUpdateLists($lstCurrent, $lstRegistered, $aCurrentRegistered)
				DisableTrayMenu()
		EndSwitch
	WEnd

	; Fenster zu und TrayMenu wieder an....
	GUIDelete($hGUI)
EndFunc   ;==>RegisterStick

; #FUNCTION# ====================================================================================================================
; Name ..........: GetNewPath
; Description ...: Auswahlbox für neue Verzeichnisse anzeigen und wählen lassen...
; Syntax ........: GetNewPath($aCurrentPaths, $aCurrentPathsTS)
; Parameters ....: Array, welches mit Infos über die derzeitige Auswahl gefüllt ist
; Return values .: None
; Author ........: Tino Reichardt
; Modified ......: 17.04.2014
; ===============================================================================================================================
Func GetNewPath(ByRef $aCurrentPaths, ByRef $aCurrentPathsTS)
	Local $sPath = _WinAPI_BrowseForFolderDlg("", Msg($mMessages[3]), _
			BitOR($BIF_RETURNONLYFSDIRS, $BIF_VALIDATE, $BIF_NEWDIALOGSTYLE, $BIF_NONEWFOLDERBUTTON))

	; irgendwas ging bei der Pfadwahl schief, nix weiter machen...
	If @error Or $sPath = "" Then
		Return
	EndIf

	; wenn der pfad schon da ist, das hinzufügen einfach ignorieren
	For $i = 1 To $aCurrentPaths[0]
		If $sPath = $aCurrentPaths[$i] Then Return
	Next

	; neuen pfad dazu und counter hoch
	_ArrayAdd($aCurrentPaths, $sPath)
	_ArrayAdd($aCurrentPathsTS, 0)
	$aCurrentPaths[0] += 1
	$aCurrentPathsTS[0] += 1
EndFunc   ;==>GetNewPath

; #FUNCTION# ====================================================================================================================
; Name ..........: IsJunction
; Description ...: testet, ob $sDirectory ein Link ist...
; Syntax ........: IsJunction($sDirectory)
; Author ........: Tino Reichardt
; Modified ......: 30.04.2014
; ===============================================================================================================================
Func IsJunction($sDirectory)
	Local Const $FILE_ATTRIBUTE_JUNCTION = 0x400
	If BitAND(_WinAPI_GetFileAttributes($sDirectory), $FILE_ATTRIBUTE_JUNCTION) = $FILE_ATTRIBUTE_JUNCTION Then
		Return 1
	EndIf
	Return 0
EndFunc   ;==>IsJunction

; #FUNCTION# ====================================================================================================================
; Name ..........: FindJunctions
; Description ...: durchsucht $sPath rekursiv nach Junctions und schreibt diese in den String $sJunctions
;                  ->  daraus kann man dann ein Array machen...
; Syntax ........: FindJunctions($sPath, $sJunctions)
; Author ........: Tino Reichardt
; Modified ......: 30.04.2014
; ===============================================================================================================================
Func FindJunctions($sPath, ByRef $sJunctions)
	; alle Verzeichnisse unterhalb von $sPath
	Local $aFileList = _FileListToArray($sPath, "*", $FLTA_FOLDERS, True)
	If @error <> 0 Then Return
	For $i = 1 To $aFileList[0]
		If IsJunction($aFileList[$i]) Then
			$sJunctions = $sJunctions & $aFileList[$i] & "|"
		Else
			FindJunctions($aFileList[$i], $sJunctions)
		EndIf
	Next
EndFunc   ;==>FindJunctions

; #FUNCTION# ====================================================================================================================
; Name ..........: RegisterPath
; Description ...: Erstellung von Verzeichnislisten, welche gesichert werden sollen
; Syntax ........: RegisterPath()
; Author ........: Tino Reichardt
; Modified ......: 15.04.2014
; ===============================================================================================================================
Func RegisterPath()
	$hGUI = GUICreate(Msg($mHeadlines[3], $sTitle), $myWidth, $myHeight, -1, -1, $gGuiStyle, $gGuiExStyle)

	; alle alten Standardpfade sind erstmal auch die aktuellen...
	Local $aCurrentPaths = $aFilePaths
	Local $aCurrentPathsTS = $aFilePathsTS

	GUICtrlCreateLabel(Msg($mLabels[5]), 8, 8, 786, 24)
	GUICtrlSetFont(-1, 10)
	Local $lstPath = GUICtrlCreateList("", 8, 32, 785, 329, BitOR($LBS_NOTIFY, $WS_VSCROLL))
	Local $btnAdd = GUICtrlCreateButton(Msg($mButtons[4]), 8, 368, 110, 25)
	Local $btnDel = GUICtrlCreateButton(Msg($mButtons[5]), 122, 368, 110, 25)
	Local $btnExclude = GUICtrlCreateButton(Msg($mButtons[7]), 236, 368, 140, 25)
	Local $btnExcludeR = GUICtrlCreateButton(Msg($mButtons[8]), 380, 368, 140, 25)
	Local $btnOkay = GUICtrlCreateButton(Msg($mButtons[1]), 640, 368, 65, 25)
	Local $btnCancel = GUICtrlCreateButton(Msg($mButtons[2]), 710, 368, 85, 25)

	; $aFilePaths -> wirklich übernommende Verzeichnisse
	; $aCurrentPaths -> derzeit angezeigte Pfade...
	For $i = 1 To $aCurrentPaths[0]
		GUICtrlSetData($lstPath, $aCurrentPaths[$i])
	Next
	GUISetState(@SW_SHOW, $hGUI)

	While 1
		Local $msg = GUIGetMsg()
		Switch $msg
			Case 0, $GUI_EVENT_MOUSEMOVE
				; ignore

			Case $GUI_EVENT_CLOSE, $btnCancel
				ExitLoop

			Case $btnOkay
				$aFilePaths = $aCurrentPaths
				$aFilePathsTS = $aCurrentPathsTS
				WriteConfiguration()
				ExitLoop

			Case $btnAdd
				GetNewPath($aCurrentPaths, $aCurrentPathsTS)
				_GUICtrlListBox_ResetContent($lstPath)
				For $i = 1 To $aCurrentPaths[0]
					GUICtrlSetData($lstPath, $aCurrentPaths[$i])
				Next

			Case $btnExclude, $btnExcludeR
				Local $i = _GUICtrlListBox_GetCurSel($lstPath)
				If $i = -1 Then ContinueLoop
				; Tray aus und Hilfe Thema setzen
				DisableTrayMenu()
				; Sektion lesen/erstellen, Editor starten und dann INI updaten
				Local $sCurrentPath = $aCurrentPaths[$i + 1]
				Local $sExcludeFile
				If $msg = $btnExclude Then
					$sExcludeFile = GetExcludeFile_X($sAppPath, $sCurrentPath)
				Else
					$sExcludeFile = GetExcludeFile_XR($sAppPath, $sCurrentPath)
				EndIf
				If Not FileExists($sExcludeFile) Then
					; File mit ein wenig Mini Doku erstellen:
					Local $sText = Msg($mExcludeComment[1], $sCurrentPath) & @CRLF
					$sText &= Msg($mExcludeComment[2]) & @CRLF
					$sText &= Msg($mExcludeComment[3]) & @CRLF
					If $msg = $btnExclude Then
						$sText &= Msg($mExcludeComment[4], "-x@Filename.txt") & @CRLF
					Else
						$sText &= Msg($mExcludeComment[4], "-xr@Filename.txt") & @CRLF
					EndIf
					$sText &= Msg($mExcludeComment[5]) & @CRLF
					$sText &= Msg($mExcludeComment[6]) & @CRLF
					FileWrite($sExcludeFile, $sText)
				EndIf
				WinSetState($hGUI, "", @SW_DISABLE)
				RunWait($sEditor & " " & $sExcludeFile)
				WinSetState($hGUI, "", @SW_ENABLE)
				WinActivate($hGUI)
				UpdateCurrentSticks()

			Case $btnDel
				Local $i = _GUICtrlListBox_GetCurSel($lstPath)
				If $i = -1 Then ContinueLoop
				; wenn ausschlussliste dabei ist, löschen...
				Local $sExcludeFile = GetExcludeFile_X($sAppPath, $aCurrentPaths[$i + 1])
				FileDelete($sExcludeFile)
				$sExcludeFile = GetExcludeFile_XR($sAppPath, $aCurrentPaths[$i + 1])
				FileDelete($sExcludeFile)
				$aCurrentPaths[0] -= 1
				_ArrayDelete($aCurrentPaths, $i + 1)
				_ArrayDelete($aCurrentPathsTS, $i + 1)
				_GUICtrlListBox_ResetContent($lstPath)
				For $i = 1 To $aCurrentPaths[0]
					GUICtrlSetData($lstPath, $aCurrentPaths[$i])
				Next
		EndSwitch
	WEnd

	; Fenster zu und TrayMenu wieder an....
	GUIDelete($hGUI)
	ReadConfiguration()
EndFunc   ;==>RegisterPath

; #FUNCTION# ====================================================================================================================
; Name ..........: FindFreeDrives
; Description ...: find at least $iMinDrives free drives and return them as array, exit on failure
; Syntax ........: FindFreeDrives($iMinDrives)
; Return values .: array representing all free DOS Drives
; Author ........: Tino Reichardt
; Modified ......: 23.04.2014
; ===============================================================================================================================
Func FindFreeDrives($iMinDrives)
	Local $iDrives = _WinAPI_GetLogicalDrives()
	Local $iCount = 0
	Local $iCurrentBit = 1

	If $iMinDrives = 0 Then
		; 0 haben wir immer frei ;)
		Return 0
	EndIf

	; erstmal durchzählen
	For $i = 1 To 26
		If Not BitAND($iDrives, $iCurrentBit) Then
			$iCount += 1
		EndIf
		$iCurrentBit *= 2
	Next

	; wir beenden hier, wenn nicht genug frei ist
	If $iCount < $iMinDrives Then
		MsgBox($MB_OK, $sTitle, Msg($mFatalErrors[1]))
		Exit
	EndIf

	; erstellen des arrays, jedes freie drive bekommt seinen platz
	Local $aFreeDrives[$iMinDrives + 1]
	$aFreeDrives[0] = $iMinDrives
	$iCount = 0
	$iCurrentBit = 1
	For $i = 1 To 26
		; zuweisen der buchstaben...
		If Not BitAND($iDrives, $iCurrentBit) Then
			Local $sDriveLetter = Chr($i + 64) ; A=65
			$iCount += 1
			$aFreeDrives[$iCount] = $sDriveLetter & ":"
		EndIf
		If $iCount = $iMinDrives Then
			Return $aFreeDrives ; wir haben nun genug laufwerke gefunden...
		EndIf
		$iCurrentBit *= 2
	Next

	Return $aFreeDrives
EndFunc   ;==>FindFreeDrives

; #FUNCTION# ====================================================================================================================
; Name ..........: FindVSSDrivesForBackup
; Description ...: generate a small mapping array for VSS drives
; Syntax ........: FindVSSDrivesForBackup($aBackupTodo)
; Return values .: array, which are set with information about VSS
; Author ........: Tino Reichardt
; Modified ......: 02.02.2015
; ===============================================================================================================================
Func FindVSSDrivesForBackup($aBackupTodo)
	Dim $aDrivesWithVSS[30][2]

	; reset the counter
	$aDrivesWithVSS[0][0] = 0

	; erstmal nur zählen und error check
	Dim $aTemp[$aBackupTodo[0]]
	For $i = 1 To $aBackupTodo[0]
		Local $sDriveLetter = StringUpper(StringLeft($aBackupTodo[$i], 2))
		If $sDriveLetter = "\\" Then
			ContinueLoop ; ist wohl ein netzlaufwerk, das ist okay...
		EndIf

		;  bei folgendem check fallen leere floppy und cdrom lw. raus
		Local $iText = DriveStatus($sDriveLetter & "\")
		If $iText <> "READY" Then
			MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[2], $sDriveLetter))
			Return 0 ; error
		EndIf
		$aTemp[$i - 1] = $sDriveLetter
	Next

	; nun wollen wir jede Platte nur ein mal ;)
	Local $aDrivesInBackup = _ArrayUnique($aTemp) ; sind groß geschrieben...
	Local $aDrivesFixed = DriveGetDrive("FIXED") ; wir nehmen an, das diese VSS können...

	If Not IsArray($aDrivesInBackup) Then
		; return empty array
		ReDim $aDrivesWithVSS[1][2]
		Return $aDrivesWithVSS
	EndIf

	For $i = 1 To $aDrivesInBackup[0]
		; jetzt prüfen wir, ob $aDrivesInBackup auch echte platten sind...
		For $j = 1 To $aDrivesFixed[0]
			Local $sDrive = StringUpper($aDrivesFixed[$j])
			; wenn das laufwerk bei fixed mit dabei ist, dann VSS ok
			If $aDrivesInBackup[$i] = $sDrive Then
				$aDrivesWithVSS[0][0] += 1
				$aDrivesWithVSS[$aDrivesWithVSS[0][0]][0] = $sDrive
			EndIf
		Next
	Next
	$aDrivesInBackup = 0

	; hier suchen wir nun freie Laufwerke für die VSS Mappings
	Local $aFreeDrives = FindFreeDrives($aDrivesWithVSS[0][0])
	For $i = 1 To $aDrivesWithVSS[0][0]
		$aDrivesWithVSS[$i][1] = $aFreeDrives[$i]
	Next

	_ArrayDelete($aDrivesWithVSS, $aDrivesWithVSS[0][0] + 1 & "-29")
	;_ArrayDisplay($aDrivesWithVSS)
	Return $aDrivesWithVSS ; success
EndFunc   ;==>FindVSSDrivesForBackup

; #FUNCTION# ====================================================================================================================
; Name ..........: CheckBackupPaths
; Description ...: überprüft, ob alle Quellverzeichnisse von $aFilePaths lesbar sind...
; Syntax ........: CheckBackupPaths()
; Author ........: Tino Reichardt
; Modified ......: 25.07.2014
; ===============================================================================================================================
Func CheckBackupPaths()
	Local $aToCheck = $aFilePaths
	Local $iError = 0
	For $i = 1 To $aToCheck[0]
		; muß da sein...
		If Not FileExists($aToCheck[$i]) Then
			MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[3], $aToCheck[$i]))
			$iError += 1
			; die nicht vorhandene Datei ist sicher auch kein Verzeichnis ;)
			; also nächste quelle testen...
			ContinueLoop
		EndIf

		; muß ein verzeichnis sein...
		If Not StringInStr(FileGetAttrib($aToCheck[$i]), "D") Then
			MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[4], $aToCheck[$i]))
			$iError += 1
		EndIf
	Next

	; 0 is okay
	Return $iError
EndFunc   ;==>CheckBackupPaths

; #FUNCTION# ====================================================================================================================
; Name ..........: GetCurrentDate / GetCurrentTime / GetCurrentDateTime
; Description ...: aktuelle Datum / Zeit / Datum+Zeit
; Syntax ........: GetCurrentDate()
; Author ........: Tino Reichardt
; Modified ......: 15.08.2014
; ===============================================================================================================================
Func GetCurrentDate()
	; 2014-12-24
	Return @YEAR & "-" & @MON & "-" & @MDAY
EndFunc   ;==>GetCurrentDate

Func GetCurrentTime()
	; 18:22:11
	Return @HOUR & ":" & @MIN & ":" & @SEC
EndFunc   ;==>GetCurrentTime

Func GetCurrentDateTime()
	; [2014-12-24 18:22:11]
	Return "[" & GetCurrentDate() & " " & GetCurrentTime() & "]"
EndFunc   ;==>GetCurrentDateTime

; #FUNCTION# ====================================================================================================================
; Name ..........: GetTimeStamp
; Description ...: liefert aktuellen Unix Timestamp (Sek seit 1.1.1970)
; Syntax ........: GetTimeStamp()
; Author ........: Tino Reichardt
; Modified ......: 08.03.2015
; ===============================================================================================================================
Func GetTimeStamp()
	Return _DateDiff('s', "1970/01/01 00:00:00", _NowCalc())
EndFunc   ;==>GetTimeStamp

; #FUNCTION# ====================================================================================================================
; Name ..........: StringFormatTime
; Description ...: Liefert formatiertes Datum, kann nur: %d.%m.%Y + %H:%M:%S
; Syntax ........: StringFormatTime()
; Author ........: Tino Reichardt
; Modified ......: 02.04.2015
; ===============================================================================================================================
Func StringFormatTime($sFormat, $iTimestamp = 0)
	Local $DateTS = _DateAdd("s", $iTimestamp, "1970/01/01 00:00:00")
	Local $aMyDate, $aMyTime
	_DateTimeSplit($DateTS, $aMyDate, $aMyTime)
	Local $sDate = $sFormat
	$sDate = StringReplace($sDate, "%Y", StringFormat("%04d", $aMyDate[1]), 0, 1) ; %Y - Das vierstellige Jahr
	$sDate = StringReplace($sDate, "%m", StringFormat("%02d", $aMyDate[2]), 0, 1) ; %m - Monat als Zahl (Bereich 01 bis 12)
	$sDate = StringReplace($sDate, "%d", StringFormat("%02d", $aMyDate[3]), 0, 1) ; %d - Tag des Monats als Zahl (Bereich 01 bis 31)
	$sDate = StringReplace($sDate, "%H", StringFormat("%02d", $aMyTime[1]), 0, 1) ; %H - Stunde als Zahl im 24-Stunden-Format (Bereich 00 bis 23)
	$sDate = StringReplace($sDate, "%M", StringFormat("%02d", $aMyTime[2]), 0, 1) ; %M - Minute als Dezimal-Wert
	$sDate = StringReplace($sDate, "%S", StringFormat("%02d", $aMyTime[3]), 0, 1) ; %S - Sekunden als Dezimal-Wert
	Return $sDate
EndFunc   ;==>StringFormatTime


; #FUNCTION# ====================================================================================================================
; Name ..........: GetTimeElapsed
; Description ...: formatiert uns die Zeit in der Form HH:MM:SS
; Syntax ........: GetTimeElapsed($seconds)
; Author ........: Tino Reichardt
; Modified ......: 17.02.2015
; ===============================================================================================================================
Func GetTimeElapsed($ts)
	Local $sTime = ""
	Local $x

	$x = Int($ts / (60 * 60))
	$ts -= $x * 60 * 60
	$sTime = StringFormat("%02d", $x) & ":"

	$x = Int($ts / 60)
	$ts -= $x * 60
	$sTime &= StringFormat("%02d:%02d", $x, $ts)

	Return $sTime
EndFunc   ;==>GetTimeElapsed

; #FUNCTION# ====================================================================================================================
; Name ..........: GetSeconds
; Description ...: gibt die Anzahl der Sekunden zurück
; Syntax ........: GetSeconds("HH:MM:SS")
; Author ........: Tino Reichardt
; Modified ......: 23.02.2015
; ===============================================================================================================================
Func GetSeconds($sTime)
	Local $iSeconds = 0
	Local $aTime = StringSplit($sTime, ":")
	If $aTime[0] <> 3 Then FatalError("@ GetSeconds($sTime=" & $sTime & ") -> keine 2x : dabei ?!")

	$iSeconds += Int($aTime[1]) * 60 * 60
	$iSeconds += Int($aTime[2]) * 60
	$iSeconds += Int($aTime[3])

	Return $iSeconds
EndFunc   ;==>GetSeconds

; #FUNCTION# ====================================================================================================================
; Name ..........: GetBackupTime
; Description ...: formatiert uns die Zeit, die eine Sicherung benötigt hatte
; Syntax ........: GetBackupTime()
; Author ........: Tino Reichardt
; Modified ......: 22.01.2014
; ===============================================================================================================================
Func GetBackupTime($ts)
	Local $sTime = ""
	Local $x

	; "1d 22h 12m 60s"
	; 60 + (12*60) + (22*60*60) + (1*24*60*60)
	$x = Int($ts / (60 * 60 * 24))
	If $x > 0 Then
		$ts -= $x * 60 * 60 * 24
		$sTime &= $x & "d"
	EndIf

	$x = Int($ts / (60 * 60))
	If $x > 0 Then
		$ts -= $x * 60 * 60
		If StringLen($sTime) Then $sTime &= " "
		$sTime &= $x & "h"
	EndIf

	$x = Int($ts / 60)
	If $x > 0 Then
		$ts -= $x * 60
		If StringLen($sTime) Then $sTime &= " "
		$sTime &= $x & "m"
	EndIf

	If $ts > 0 Then
		If StringLen($sTime) Then $sTime &= " "
		$sTime &= $ts & "s"
	EndIf

	Return $sTime
EndFunc   ;==>GetBackupTime

; #FUNCTION# ====================================================================================================================
; Name ..........: MyInputBox
; Description ...: Passwort/Eingabe vom Benutzer erfragen...
; Syntax ........: MyInputBox("some text", "standardwert", $ES_PASSWORD)
; Author ........: Tino Reichardt
; Modified ......: 19.02.2015
; ===============================================================================================================================
Func MyInputBox($title, $helpIndex, $text, $default = "", $style = "")
	Local $width = 370
	Local $height = 130
	Local $left = @DesktopWidth / 2 - $width / 2
	Local $top = @DesktopHeight / 2 - $height / 2

	Local $hWnd = GUICreate($title, $width, $height, $left, $top, BitOR($WS_SYSMENU, $WS_CAPTION))

	GUICtrlCreateLabel($text, 40, 20, $width - 80, 20)
	Local $id_INPUT
	If $style <> "" Then
		$id_INPUT = GUICtrlCreateInput($default, 40, 50, $width - 80, 20, $style)
	Else
		$id_INPUT = GUICtrlCreateInput($default, 40, 50, $width - 80, 20)
	EndIf
	Local $id_OK = GUICtrlCreateButton('OK', $width / 2 - 75 / 2, $height - 35, 75, 23)
	Local $id_ENTER = GUICtrlCreateDummy()
	Dim $aAccelKeys[1][2] = [["{ENTER}", $id_ENTER]]
	GUISetAccelerators($aAccelKeys)
	GUISetState(@SW_SHOW)
	Local $sInput = ''

	While 1
		Local $msg = GUIGetMsg()
		;If $msg <> 0 Then ConsoleWrite(" msg=" & $msg & @CRLF)
		Switch $msg
			Case $id_OK, $id_ENTER
				$sInput = GUICtrlRead($id_INPUT)
				ExitLoop
			Case $GUI_EVENT_CLOSE
				$sInput = ""
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hWnd)
	Return $sInput
EndFunc   ;==>MyInputBox

; #FUNCTION# ====================================================================================================================
; Name ..........: AboutBox
; Description ...: ein kleines About anzeigen...
; Syntax ........: AboutBox()
; Author ........: Tino Reichardt
; Modified ......: 21.01.2015
; ===============================================================================================================================
Func AboutBox()
	Local $width = 500
	Local $height = 260
	Local $left = @DesktopWidth / 2 - $width / 2
	Local $top = @DesktopHeight / 2 - $height / 2
	Local $mail = "E-Mail: milky-usb-backup" & "@" & "mcmilk.de"

	Local $hWnd = GUICreate($sTitle, $width, $height, $left, $top, BitOR($WS_SYSMENU, $WS_CAPTION))
	Local $x = 50, $y = 40, $h = 21, $c, $a

	GUISetFont(9)
	$c = GUICtrlCreateLabel("© 2014 - 2019 Tino Reichardt,", $x, $y + $h)
	GUICtrlSetTip($c, $mail)
	$a = ControlGetPos($hWnd, "", $c)
	Local $web1 = GUICtrlCreateLabel("Homepage", $a[0] + $a[2] - 5, $y + $h)
	GUICtrlSetTip($web1, $mail)
	GUICtrlSetColor(-1, $COLOR_BLUE)
	GUICtrlSetFont(-1, -1, -1, 4)
	GUICtrlSetCursor(-1, 0)

	$c = GUICtrlCreateLabel("© 1999 - 2019 Igor Pavlov (7-Zip),", $x, $y + $h * 3)
	$a = ControlGetPos($hWnd, "", $c)
	Local $web2 = GUICtrlCreateLabel("www.7-zip.org", $a[0] + $a[2] - 5, $a[1])
	GUICtrlSetColor(-1, $COLOR_BLUE)
	GUICtrlSetFont(-1, -1, -1, 4)
	GUICtrlSetCursor(-1, 0)

	$c = GUICtrlCreateLabel("© 2006 Microsoft (vscsc.exe),", $x, $y + $h * 4)
	$a = ControlGetPos($hWnd, "", $c)
	Local $web3 = GUICtrlCreateLabel("vscsc.sf.net", $a[0] + $a[2] - 5, $a[1])
	GUICtrlSetColor(-1, $COLOR_BLUE)
	GUICtrlSetFont(-1, -1, -1, 4)
	GUICtrlSetCursor(-1, 0)

	GUICtrlCreateLabel("© 1999 Andrey Shedel (sync.c)", $x, $y + $h * 5)

	$c = GUICtrlCreateLabel("© Ward, UEZ and others from ", $x, $y + $h * 6)
	$a = ControlGetPos($hWnd, "", $c)
	Local $web4 = GUICtrlCreateLabel("AutoIt Forum", $a[0] + $a[2] - 5, $a[1])
	GUICtrlSetColor(-1, $COLOR_BLUE)
	GUICtrlSetFont(-1, -1, -1, 4)
	GUICtrlSetCursor(-1, 0)

	Local $id_OK = GUICtrlCreateButton('OK', $width / 2 - 75 / 2, $height - 35, 75, 23)
	GUISetFont(14)
	$c = GUICtrlCreateLabel($sAppName & " - Version " & $sVersion, 10, 10, 480, -1, $SS_CENTER)

	GUISetFont(8.5)
	$c = GUICtrlCreateLabel($sUpdateAppVersion, $width - 60, $height - 35, 60, -1, $SS_CENTER)
	; GUICtrlSetBkColor(-1, 0x00aaaa)

	GUISetState(@SW_SHOW)
	While 1
		Local $msg = GUIGetMsg()
		Switch $msg
			Case $web1
				ShellExecute($sUpdateURL)
			Case $web2
				ShellExecute("http://www.7-zip.org/")
			Case $web3
				ShellExecute("http://vscsc.sf.net/")
			Case $web4
				ShellExecute("http://www.autoitscript.com/forum/")
			Case $id_OK
				ExitLoop
			Case 4 ; ENTER
				ExitLoop
			Case $GUI_EVENT_CLOSE ;  ESC oder zu klickern
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hWnd)
	Return

EndFunc   ;==>AboutBox

; #FUNCTION# ====================================================================================================================
; Name ..........: MyPKDF()
; Description ...: Benutzerpasswort ein wenig besser machen, TODO=scrypt?
; Syntax ........: MyPKDF(UserPW, Rundenanzahl)
; Author ........: Tino Reichardt
; Modified ......: 21.01.2015
; ===============================================================================================================================
Func MyPKDF($sKey, $rounds = 1000)
	Local $sPW = $sKey
	For $i = 1 To $rounds
		$sKey = SHA3($sKey & $sPW & $i, 512)
	Next
	Return $sKey
EndFunc   ;==>MyPKDF

; #FUNCTION# ====================================================================================================================
; Name ..........: MyMiniHash()
; Description ...: gibt einen "kryptischen" Pfad zurück
; Syntax ........: MyMiniHash(pfad)
; Author ........: Tino Reichardt
; Modified ......: 27.01.2015
; ===============================================================================================================================
Func MyMiniHash($sPath)
	; BackupPath  = E:\usb-backup\user@host\@BackupDir\@FullBackup\@FullBackup.7z
	; BackupPath  = E:\usb-backup\user@host\@BackupDir\@FullBackup\@Update.7z
	; @BackupDir  = sha(filepath & salt)   -> filepath = section from index.ini
	; @FullBackup = sha(fTimestamp & salt) -> timestamp of full backup
	; Update      = sha(uTimestamp & salt) -> timestamp of update
	Return StringLower(StringMid(SHA3($sPath & $sSaltValue, 224), 3, $sFileNameLen))
EndFunc   ;==>MyMiniHash

; #FUNCTION# ====================================================================================================================
; Name ..........: GetExcludeFile_X()
; Description ...: gibt einen kurzen / eindeutigen Pfad zurück
; Syntax ........: GetExcludeFile_X(pfad)
; Author ........: Tino Reichardt
; Modified ......: 05.03.2015
; ===============================================================================================================================
Func GetExcludeFile_X($sPrefix, $sFilePath)
	Return $sPrefix & "X_" & StringLower(StringMid(SHA3($sFilePath, 224), 5, $sFileNameLen)) & '.txt'
EndFunc   ;==>GetExcludeFile_X

; #FUNCTION# ====================================================================================================================
; Name ..........: GetExcludeFile_XR()
; Description ...: gibt einen kurzen / eindeutigen Pfad zurück
; Syntax ........: GetExcludeFile_XR(pfad)
; Author ........: Tino Reichardt
; Modified ......: 05.03.2015
; ===============================================================================================================================
Func GetExcludeFile_XR($sPrefix, $sFilePath)
	Return $sPrefix & "XR_" & StringLower(StringMid(SHA3($sFilePath, 224), 5, $sFileNameLen)) & '.txt'
EndFunc   ;==>GetExcludeFile_XR

; #FUNCTION# ====================================================================================================================
; Name ..........: GetTempIndex(id)
; Description ...: Gibt Pfad zum temp. Index @ Temp zurück
; Syntax ........: GetTempIndex(id)
; Author ........: Tino Reichardt
; Modified ......: 01.04.2015
; ===============================================================================================================================
Func GetTempIndex($id, $iMode = 0)
	Static $sFsType = ""
	If $sFsType = "" Then $sFsType = DriveGetFileSystem(StringLeft($sTempPath, 2))

	If $sFsType = "NTFS" Then
		; in einem stream verstecken...
		If $iMode <> 0 Then Return $sTempPath & "Index"
		Return $sTempPath & "Index:" & $id & $aCurrentSticks[$id][$eDriveLetter] & ".ini"
	EndIf
	; standard
	Return $sTempPath & "Index-" & $id & $aCurrentSticks[$id][$eDriveLetter] & ".ini"
EndFunc   ;==>GetTempIndex

; #FUNCTION# ====================================================================================================================
; Name ..........: FileSaveDelete
; Description ...: Löschen des temp. INdex wegen der sensitiven Daten
; Syntax ........: FileSaveDelete()
; Author ........: Tino Reichardt
; Modified ......: 02.04.2015
; ===============================================================================================================================
Func FileDeleteSave($id)
	Static $sFsType = ""
	Local $sFileName = GetTempIndex($id)

	; Datei öffnen, verschlüsseln, schreiben, flushen, schließen, löschen
	Local $hFile = FileOpen($sFileName, $FO_OVERWRITE)
	If $hFile = -1 Then Return
	FileSetPos($hFile, 0, $FILE_BEGIN)
	Local $sPlain = FileRead($hFile)
	Local $sKey = SHA3($sPlain & $sSaltValue, 512)
	Local $sData = BinaryToString(_Crypt_EncryptData($sPlain, $sKey, $CALG_AES_256))
	FileSetPos($hFile, 0, $FILE_BEGIN)
	FileWrite($hFile, $sData)
	FileFlush($hFile)
	FileClose($hFile)
	FileDelete(GetTempIndex($id, 1))
EndFunc   ;==>FileDeleteSave

; #FUNCTION# ====================================================================================================================
; Name ..........: MyEncrypt()
; Description ...: Daten verschlüsseln und zurück geben
; Syntax ........: MyEncrypt(cleartext data, password)
; Author ........: Tino Reichardt
; Modified ......: 21.01.2015
; ===============================================================================================================================
Func MyEncrypt($scData, $sPassword)
	Local $cData = _Crypt_EncryptData($scData, MyPKDF($sPassword), $CALG_AES_256)
	Return $cData
EndFunc   ;==>MyEncrypt

; #FUNCTION# ====================================================================================================================
; Name ..........: MyDecrypt()
; Description ...: Daten entschlüsseln und zurück geben
; Syntax ........: MyDecrypt(encoded datam password)
; Author ........: Tino Reichardt
; Modified ......: 21.01.2015
; ===============================================================================================================================
Func MyDecrypt($seData, $sPassword)
	Local $scData = _Crypt_DecryptData($seData, MyPKDF($sPassword), $CALG_AES_256)
	If Not IsBinary($scData) Then Return ""
	Return BinaryToString($scData)
EndFunc   ;==>MyDecrypt

; #FUNCTION# ====================================================================================================================
; Name ..........: ReadIndexFile
; Description ...: liest verschlüsselte Index Datei
; Syntax ........: ReadIndexFile(ecryptedIndex, Passwort)
; Author ........: Tino Reichardt
; Modified ......: 21.01.2015
; ===============================================================================================================================
Func ReadIndexFile($sIndexFile, $sPassword)
	Local $hFile = FileOpen($sIndexFile, $FO_ANSI)
	Local $cData = FileRead($hFile)
	If @error <> 0 Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[5], $sIndexFile))
		FileClose($hFile)
		Return ""
	EndIf
	FileClose($hFile)

	Local $sData = MyDecrypt($cData, $sPassword)
	If $sData = "" Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[6], $sIndexFile))
	EndIf

	; wenn wir bis hier hin durch sind, scheint alles okay zu sein ;)
	Return $sData ; success
EndFunc   ;==>ReadIndexFile

; #FUNCTION# ====================================================================================================================
; Name ..........: BackupIndexFile
; Description ...: Erstellt Backup der verschlüsselten Index Datei
; Syntax ........: BackupIndexFile(IndexFile, OldFilename)
; Author ........: Tino Reichardt
; Modified ......: 25.04.2017
; ===============================================================================================================================
Func BackupIndexFile($sFileName, $sOldFilename)

	; lösche zu altes backup
	If FileExists($sOldFilename) Then FileDelete($sOldFilename)
	If Not FileExists($sFileName) Then Return

	If FileMove($sFileName, $sOldFilename) <> 1 Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[8], $sFileName))
	EndIf
EndFunc   ;==>BackupIndexFile

; #FUNCTION# ====================================================================================================================
; Name ..........: UpdateIndexFile
; Description ...: Erstellt verschlüsselte Index Datei und wenn nötig auch diverse Standardwerte
; Syntax ........: UpdateIndexFile(id of stick)
; Author ........: Tino Reichardt
; Modified ......: 23.01.2015
; ===============================================================================================================================
Func UpdateIndexFile($id)
	Local $sBackupPath = $aCurrentSticks[$id][$eBackupPath]
	Local $sPassword = $aCurrentSticks[$id][$ePassword]
	Local $sIndexFile = $sBackupPath & "Index"
	Local $sIndexTemp = GetTempIndex($id)
	Local $x

	DirCreate($sBackupPath)

	; fix not existing entries, if needed
	$x = IniRead($sIndexTemp, $sAppName, "cdate", GetCurrentDate())
	IniWrite($sIndexTemp, $sAppName, "cdate", $x)
	$x = IniRead($sIndexTemp, $sAppName, "ctime", GetCurrentTime())
	IniWrite($sIndexTemp, $sAppName, "ctime", $x)
	$x = IniRead($sIndexTemp, $sAppName, "cts", GetTimeStamp())
	IniWrite($sIndexTemp, $sAppName, "cts", $x)

	; this must be handled with a bit of care...
	$sSaltValue = IniRead($sIndexTemp, $sAppName, "SaltValue", "0")
	If $sSaltValue = "0" Then
		; generate some nice random salt, will be used in all MyMiniHash() operations later
		$sSaltValue = StringMid(MyPKDF(_WinAPI_CreateGUID(), 20), 3)
		IniWrite($sIndexTemp, $sAppName, "SaltValue", $sSaltValue)
	EndIf

	For $i = 1 To $aFilePaths[0]
		Local $sSection = $aFilePaths[$i]

		; jedes backup verzeichnishat einen cts (creation timestamp)
		$x = IniRead($sIndexTemp, $sSection, "cts", GetTimeStamp())
		IniWrite($sIndexTemp, $sSection, "cts", $x)

		; jedes backup verzeichnis hat einen fts (timestamp letztes full backup)
		$x = IniRead($sIndexTemp, $sSection, "fts", "0")
		IniWrite($sIndexTemp, $sSection, "fts", $x)

		; ConsoleWrite("UpdateIndexFile() IniWrite S=" & $sSection & @CRLF)
	Next
	; ConsoleWrite("UpdateIndexFile() FileGetEncoding()=" & FileGetEncoding($sIndexTemp) & @CRLF)

	; save latest mofification time
	IniWrite($sIndexTemp, $sAppName, "mdate", GetCurrentDate())
	IniWrite($sIndexTemp, $sAppName, "mtime", GetCurrentTime())
	IniWrite($sIndexTemp, $sAppName, "mts", GetTimeStamp())

	; read it, encrypt it, store it on external drive
	Local $hFile = FileOpen($sIndexTemp)
	Local $sData = FileRead($hFile)
	If @error <> 0 Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[5], $sIndexTemp))
		Return ""
	EndIf
	FileClose($hFile)

	Local $cData = MyEncrypt($sData, $sPassword)
	Local $sIndexFileTemp = $sIndexFile & ".new"
	; neue temp index file
	$hFile = FileOpen($sIndexFileTemp, $FO_OVERWRITE)
	If $hFile = -1 Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[8], $sIndexFileTemp))
		Return ""
	EndIf

	If FileWrite($hFile, $cData) <> 1 Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[8], $sIndexFileTemp))
		Return ""
	EndIf

	If FileFlush($hFile) <> True Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[8], $sIndexFileTemp))
		Return ""
	EndIf

	If FileClose($hFile) <> 1 Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[8], $sIndexFileTemp))
		Return ""
	EndIf

	; delete old index backups (one is okay)
	For $i = 20 To 1 Step -1
		FileDelete($sIndexFile & ".old" & $i)
	Next
	BackupIndexFile($sIndexFile, $sIndexFile & ".old")
	BackupIndexFile($sIndexFileTemp, $sIndexFile)

	Return
EndFunc   ;==>UpdateIndexFile

; #FUNCTION# ====================================================================================================================
; Name ..........: GetPasswordForID
; Description ...: Fragt den Benutzer nach einem Passwort für Stick Numer $id
; Syntax ........: GetPasswordForID(id)
; Author ........: Tino Reichardt
; Modified ......: 21.01.2015
; Returns .......: 1=sucess 0=wrong
; ===============================================================================================================================
Func GetPasswordForID($id)
	Local $sBackupPath = $aCurrentSticks[$id][$eBackupPath]
	Local $sIndexFile = $sBackupPath & "Index"
	Local $sIndexTemp = GetTempIndex($id)
	Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
	Local $sData = ""
	Local $sPassword = ""

	If Not FileExists($sIndexFile) Then
		Do
			Local $sPass1 = MyInputBox($sTitle, "usage-BackupPassword.html", Msg($mLabels[6], $sDrive), "", $ES_PASSWORD)
			If $sPass1 = "" Then Return
			$sPassword = MyInputBox($sTitle, "usage-BackupPassword.html", Msg($mLabels[7], $sDrive), "", $ES_PASSWORD)
			If $sPassword = "" Then Return
		Until $sPass1 = $sPassword
		$aCurrentSticks[$id][$ePassword] = $sPassword
		_Crypt_DestroyKey($sPass1)
		_Crypt_DestroyKey($sPassword)
		UpdateIndexFile($id)
		$sData = ReadIndexFile($sIndexFile, $sPassword)
	Else
		; E:\Usb-Backup\user@host\Index einlesen...
		Do
			; falls der nutzer schonmal sein passwort eingegeben hat, wissen wir das auch noch...
			If $aCurrentSticks[$id][$ePassword] <> "" Then
				$sPassword = $aCurrentSticks[$id][$ePassword]
			Else
				$sPassword = MyInputBox($sTitle, "usage-BackupPassword.html", Msg($mLabels[8], $sDrive), "", $ES_PASSWORD)
			EndIf

			; nun aber reset
			_Crypt_DestroyKey($aCurrentSticks[$id][$ePassword])
			$aCurrentSticks[$id][$ePassword] = ""

			; wenn nix eingegeben, dem nutzer hinweis zum löschen geben
			If $sPassword = "" Then
				MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[9]) & @CRLF & @CRLF & $sIndexFile)
				Return 0
			EndIf

			; indexfile muß entschlüsselt werden können
			$sData = ReadIndexFile($sIndexFile, $sPassword)
		Until $sData <> ""
	EndIf

	; temporären Klartext Index überschreiben und dann löschen
	; -> sicheres löschen quasi... wegen admin passwort
	FileDeleteSave($id)

	; temporären Klartext Index erzeugen
	Local $hFile = FileOpen($sIndexTemp, $FO_OVERWRITE + $FO_ANSI)
	FileWrite($hFile, $sData)
	FileFlush($hFile)
	FileClose($hFile)

	; this will add new FilePaths, if needed
	$aCurrentSticks[$id][$ePassword] = $sPassword
	UpdateIndexFile($id)

	Return 1
EndFunc   ;==>GetPasswordForID

; #FUNCTION# ====================================================================================================================
; Name ..........: ChooseBackup
; Description ...: Backuptyp und Passwort vom Benutzer erfragen...
; Syntax ........: ChooseBackup(USB Disk ID)
; Author ........: Tino Reichardt
; Modified ......: 20.01.2015
; ===============================================================================================================================
Func ChooseBackup($id)

	If $sCheckForUpdate Then CheckForUpdate()

	; 1) zu sichernde Verzeichnisse checken ($aFilePaths)
	If CheckBackupPaths() Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[10]))
		Return
	EndIf

	; 2) Passwort fordern, ohne machen wir keine Backups!
	If Not GetPasswordForID($id) Then Return

	; 3) Löschen und abändern des aktuellen Backup Auftrages...
	Local $aBackupTodo = ManageBackups($id)
	If Not IsArray($aBackupTodo) Then
		FileDeleteSave($id)
		Return
	EndIf

	; 4) starten des backups...
	CreateNewBackup($id, $aBackupTodo)
	Return
EndFunc   ;==>ChooseBackup

; #FUNCTION# ====================================================================================================================
; Name ..........: ManageBackups_Info
; Description ...: auf TreeView Aktionen reagieren
; Syntax ........: ManageBackups_Info($id, $msg, $tvid, $aBackups, $aBackupTodo, $aGuiIDs)
;					$id -> stick id
; 					$msg -> GetMsg() vom TreeView
; 					$tvid -> Item
; 					$aBackups[][] -> das große array
;					$aGuiIDs -> das dynamische grafik id zeugs
; Author ........: Tino Reichardt
; Modified ......: 24.01.2015
; ===============================================================================================================================
Func ManageBackups_Info($id, $msg, $tvid, $tv, ByRef $aBackups, ByRef $aBackupTodo, ByRef $aGuiIDs)
	Local $sIndexTemp = GetTempIndex($id)
	Local $sBackupPath = $aCurrentSticks[$id][$eBackupPath]
	Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
	Local $iReturn = 0

	; diese beiden ermöglichen uns den Zugriff auf die jeweiligen index im array
	Static $iOldIndex = -1 ; oldIndex wird für den löschen button benötigt
	Local $iIndex

	; diese sind für aktionen nutzbar...
	Static $radioAddTodo, $radioDelTodo
	Static $btnDelete, $ClickDirectory, $ClickFullZIP, $ClickUpdateZIP, $ClickFullWarn, $ClickUpdateWarn

	; aktuelles element raus suchen...
	For $iIndex = 1 To $aBackups[0][0]
		If $aBackups[$iIndex][1] = $tvid Then ExitLoop
	Next

	If $iIndex > $aBackups[0][0] Then
		$iOldIndex = -1
		Return 0
	EndIf

	; ConsoleWrite("$aBackups: $iIndex=" & $iIndex)
	; _PrintFromArray($aBackups)

	; _ArrayTranspose($aXY) ; -> kaputt! gibt kein 1D array zurück, sondern 2D!
	Local $aCurrentQuery[9]
	For $i = 0 To 8
		$aCurrentQuery[$i] = $aBackups[$iIndex][$i]
	Next

	;ConsoleWrite("$aCurrentQuery: ")
	;_PrintFromArray($aCurrentQuery)

	; check, if OldIndex is valid
	If $iOldIndex > $aBackups[0][0] Then $iOldIndex = -1
	Local $aLastQuery[9]
	If $iOldIndex <> -1 Then
		For $i = 0 To 8
			$aLastQuery[$i] = $aBackups[$iOldIndex][$i]
		Next

		#cs
			[0] u
			[1] 31
			[2] 1
			[3] H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\ed512c5fe15eafde
			[4] 1428016471+1428016869
			[5] Z:\autoit\7z938_milky
			[6] 774
			[7] H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\ed512c5fe15eafde\ed512c5fe15eafde.7z
			[8] H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\ed512c5fe15eafde\8bc67fb5bccd35f3.7z

			[0] f
			[1] 29
			[2] 1
			[3] H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\8777808d2e4ab7af
			[4] 1428014662
			[5] Z:\autoit\7z938_milky
			[6] 6475484
			[7] H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\8777808d2e4ab7af\8777808d2e4ab7af.7z
			[8] 0
		#ce
	EndIf

	; reset these now
	If Int($msg) = Int($tvid) Then
		$btnDelete = ""
		$ClickDirectory = ""
		$ClickFullZIP = ""
		$ClickUpdateZIP = ""
		$ClickFullWarn = ""
		$ClickUpdateWarn = ""
	EndIf
	#cs
		ConsoleWrite("$msg=" & $msg & @CRLF)
		ConsoleWrite("$tvid=" & $tvid & @CRLF)
		ConsoleWrite("$ClickFullZIP=" & $ClickFullZIP & @CRLF)
		ConsoleWrite("$ClickUpdateZIP=" & $ClickUpdateZIP & @CRLF)
		ConsoleWrite("$ClickFullWarn=" & $ClickFullWarn & @CRLF)
		ConsoleWrite("$ClickUpdateWarn=" & $ClickUpdateWarn & @CRLF)
	#ce

	; aktuelles todo element raus suchen...
	For $iTodoIndex = 1 To $aBackupTodo[0][0]
		If $aBackupTodo[$iTodoIndex][1] = $tvid Then ExitLoop
	Next

	; löschen button abfangen
	If ($iOldIndex <> -1) And ($msg = $btnDelete) Then
		Switch $aLastQuery[0]
			Case "p"
				; Pfad darf man auch löschen, aber nur wenn nicht mehr in der aktuelen FilePath[] Liste!
				If $aLastQuery[2] <> 1 Then
					If MsgBox($MB_YESNO, $sTitle, Msg($mMessages[4])) = $IDYES Then
						; 1) ganzes verzeichnis löschen
						DirRemove($aLastQuery[3], 1)
						; 2) die ganze section löschen:
						IniDelete($sIndexTemp, $aLastQuery[5])
						UpdateIndexFile($id)
						_GUICtrlTreeView_DeleteAll($tv)
						$iReturn = 1 ; Tree neu aufbauen ist nötig!
					EndIf
				EndIf
			Case "f"
				If MsgBox($MB_YESNO, $sTitle, Msg($mMessages[5])) = $IDYES Then
					; 1) ganzes verzeichnis löschen (inkl. updates) -> einfach
					DirRemove($aLastQuery[3], 1)
					;ConsoleWrite("lösche dir=" & $aLastQuery[3])

					; 2) den registry eintrag löschen -> einfach
					IniDelete($sIndexTemp, $aLastQuery[5], "f" & $aLastQuery[4])
					UpdateIndexFile($id)
					;ConsoleWrite(" inidelete path=" & $aLastQuery[5] & ", key=f" & $aLastQuery[4])

					; 3) logfiles der sicherung löschen
					Local $sDir = $sAppPath & "Logfiles\" & MyMiniHash($aLastQuery[5] & $aLastQuery[4])
					If FileExists($sDir) Then DirRemove($sDir, 1)

					; 4) aus der $aBackupTodo und Tree löschen -> uiuiui
					; hatte es erst versucht, mache nun aber doch einen reset ;)
					_GUICtrlTreeView_DeleteAll($tv)
					$iReturn = 1 ; Tree neu aufbauen ist nötig!
				EndIf
			Case "u"
				If MsgBox($MB_YESNO, $sTitle, Msg($mMessages[6])) = $IDYES Then
					; beim update löschen muß folgendes getan werden:
					; 1) die update file selber löschen (ist einfach, da in $aLastQuery[8] gespeichert)
					FileDelete($aLastQuery[8])

					; 2) den index anpassen und abspeichern, das ist schwieriger:
					;    -> $aLastQuery[4] hat den Timestamp von FullBackup+Update: 1422538964+1422538997
					;    -> im index muß also der key "f1422538964" geholt werden, dann das update da raus, dann abspeichern
					;    -> $aTS[1]=full $aTS[2]=update timestamp
					Local $aTS = StringSplit($aLastQuery[4], "+")
					Local $sOld = IniRead($sIndexTemp, $aLastQuery[5], "f" & $aTS[1], "")
					Local $aU = StringSplit($sOld, ";") ; updates als array
					Local $sNew = $aU[1] ; am anfang ist immer der ts vom full backup
					For $i = 2 To $aU[0]
						; nun timestamp:runtime:bytes paare
						Local $aU2 = StringSplit($aU[$i], ":")
						If $aU2[1] <> $aTS[2] Then
							$sNew &= ";" & $aU[$i]
						EndIf
					Next
					;ConsoleWrite("$sIndexTemp=" & $sIndexTemp & " section=" & $aLastQuery[5] & " key=f" & $aTS[1] & " v=" & $sNew)
					IniWrite($sIndexTemp, $aLastQuery[5], "f" & $aTS[1], $sNew)
					UpdateIndexFile($id)

					; 3) tree element löschen
					_GUICtrlTreeView_DeleteAll($tv)
					$iReturn = 1 ; Tree neu aufbauen ist nötig!
				EndIf
		EndSwitch
	ElseIf $msg <> $tvid Then
		; hier landen wir, wenn in der gruppe rechts unten auf etwas geklickt wurde...
		; Verzeichnis, Full Backup oder Update angeklickt
		If $msg = $ClickDirectory Then
			ShellExecute($aLastQuery[3])
		ElseIf $msg = $ClickFullZIP Then
			ShellExecute($aLastQuery[7])
		ElseIf $msg = $ClickUpdateZIP Then
			ShellExecute($aLastQuery[8])
		ElseIf $msg = $ClickFullWarn Then
			Local $s = StringTrimRight($aLastQuery[7], 3) ; .7z beim archiv.7z weg machen
			Local $sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
			Run($sEditor & " " & $sErrorLog)
		ElseIf $msg = $ClickUpdateWarn Then
			Local $s = StringTrimRight($aLastQuery[8], 3) ; .7z beim archiv.7z weg machen
			Local $sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
			Run($sEditor & " " & $sErrorLog)
		ElseIf $msg = $radioAddTodo Then
			; wenn add/del radio gedrückt, dann checken ob änderungen am BackupTodo[] nötig sind
			; [0][0]=rows, [0][1]=full backups, [0][2]=updates
			Switch $aBackupTodo[$iTodoIndex][0]
				Case "na"
					$aBackupTodo[$iTodoIndex][0] = "a"
					$aBackupTodo[0][1] += 1 ; full backup counter
				Case "nu"
					$aBackupTodo[$iTodoIndex][0] = "u"
					$aBackupTodo[0][2] += 1 ; update counter
			EndSwitch
		ElseIf $msg = $radioDelTodo Then
			Switch $aBackupTodo[$iTodoIndex][0]
				Case "a"
					$aBackupTodo[$iTodoIndex][0] = "na"
					$aBackupTodo[0][1] -= 1 ; full backup counter
				Case "u"
					$aBackupTodo[$iTodoIndex][0] = "nu"
					$aBackupTodo[0][2] -= 1 ; update counter
			EndSwitch
		EndIf
		;_PrintFromArray($aGuiIDs)
		;ConsoleWrite("UND NU: $iTodoIndex=" & $iTodoIndex & " $aBackupTodo[$iTodoIndex][0]=" & $aBackupTodo[$iTodoIndex][0] & " $radioDelTodo=" & $radioDelTodo & " $radioAddTodo=" & $radioAddTodo & @CRLF)

		; und wieder zurück zum gui...
		Return $iReturn
	EndIf

	; alte ID's löschen, wenn $msg==$tvid, weil treeview eben...
	For $i = 1 To $aGuiIDs[0]
		GUICtrlDelete($aGuiIDs[$i])
	Next
	Dim $aGuiIDs[1]

	; gruppe rechts unten neu aufbauen:
	Local $x1 = 504, $y1 = 212, $h = 19, $l1 = 88, $c, $l2 = 188

	$c = GUICtrlCreateLabel(Msg($mLabels[9]), $x1, $y1, $l1, 17)
	_ArrayAdd($aGuiIDs, $c)
	$c = GUICtrlCreateLabel($sDrive & "\..\" & StringRight($aCurrentQuery[3], $sFileNameLen), $x1 + $l1, $y1, $l2, 17)
	_ArrayAdd($aGuiIDs, $c)
	$ClickDirectory = $c
	GUICtrlSetColor(-1, $COLOR_BLUE)
	GUICtrlSetTip(-1, Msg($mLabels[10], $aCurrentQuery[3]))
	GUICtrlSetFont(-1, -1, -1, 4)
	GUICtrlSetCursor(-1, 0)

	Switch $aCurrentQuery[0]
		Case "p"
			$c = GUICtrlCreateLabel(Msg($mLabels[11]), $x1, $y1 + $h * 1, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel(StringFormatTime(Msg($mLabels[12]), $aCurrentQuery[4]), $x1 + $l1, $y1 + $h * 1, $l2, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel(Msg($mLabels[13]), $x1, $y1 + $h * 2, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)

			If $aCurrentQuery[6] <> 0 Then
				Local $aBytes = StringSplit($aCurrentQuery[6], "+")
				$c = GUICtrlCreateLabel(Msg($mLabels[14], $aCurrentQuery[7], _WinAPI_StrFormatByteSize($aBytes[1])), $x1 + $l1, $y1 + $h * 2, $l2, 17)
				_ArrayAdd($aGuiIDs, $c)
				If $aCurrentQuery[8] <> 0 Then
					$c = GUICtrlCreateLabel(Msg($mLabels[15], $aCurrentQuery[8], _WinAPI_StrFormatByteSize($aBytes[2])), $x1 + $l1, $y1 + $h * 3, $l2, 17)
					_ArrayAdd($aGuiIDs, $c)
				EndIf
				$aBytes = 0
			Else
				$c = GUICtrlCreateLabel(Msg($mLabels[16]), $x1 + $l1, $y1 + $h * 2, $l2, 17)
				_ArrayAdd($aGuiIDs, $c)
			EndIf

			; [2]=1 -> ist ein aktueller pfad
			If $aCurrentQuery[2] = "1" Then
				If $aCurrentQuery[7] = 0 Then ; $aCurrentQuery[7] -> anzahl der sicherungen ist "0" ?
					$c = GUICtrlCreateRadio(Msg($mLabels[17]), 504, 336, 200, 17)
					$radioAddTodo = $c
					_ArrayAdd($aGuiIDs, $c)
					$btnDelete = -1
				Else
					$c = GUICtrlCreateRadio(Msg($mLabels[18]), 504, 318, 240, 17)
					$radioAddTodo = $c
					_ArrayAdd($aGuiIDs, $c)
					$c = GUICtrlCreateRadio(Msg($mLabels[19]), 504, 336, 240, 17)
					$radioDelTodo = $c
					_ArrayAdd($aGuiIDs, $c)
				EndIf
				If $aBackupTodo[$iTodoIndex][0] <> "na" Then
					GUICtrlSetState($radioAddTodo, $GUI_CHECKED)
				Else
					GUICtrlSetState($radioDelTodo, $GUI_CHECKED)
				EndIf
				$btnDelete = -1
			Else
				$c = GUICtrlCreateButton(Msg($mButtons[6]), 710, 327, 75, 25)
				$btnDelete = $c
				_ArrayAdd($aGuiIDs, $c)
			EndIf

		Case "f"
			Local $sArchiv = StringRight($aCurrentQuery[7], $sFileNameLen + 3)
			Local $s = StringTrimRight($aCurrentQuery[7], 3) ; .7z beim archiv.7z weg machen
			Local $sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
			Local $iLine = 1

			$c = GUICtrlCreateLabel(Msg($mLabels[20]), $x1, $y1 + $h * $iLine, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel($sDrive & "\..\" & $sArchiv, $x1 + $l1, $y1 + $h * $iLine, $l2, 17)
			_ArrayAdd($aGuiIDs, $c)
			$ClickFullZIP = $c
			GUICtrlSetColor(-1, $COLOR_BLUE)
			GUICtrlSetTip(-1, Msg($mLabels[21], $sArchiv))
			GUICtrlSetFont(-1, -1, -1, 4)
			GUICtrlSetCursor(-1, 0)

			$iLine += 1
			$c = GUICtrlCreateLabel(Msg($mLabels[22]), $x1, $y1 + $h * $iLine, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel(_WinAPI_StrFormatByteSize($aCurrentQuery[6]), $x1 + $l1, $y1 + $h * $iLine)
			_ArrayAdd($aGuiIDs, $c)

			If FileExists($sErrorLog) Then
				Local $a = ControlGetPos($hGUI, "", $c)
				Local $iWarnings = _FileCountLines($sErrorLog)
				$c = GUICtrlCreateLabel(Msg($mLabels[23], $iWarnings), $a[0] + $a[2], $y1 + $h * $iLine, $l2 - $a[2], 17)
				_ArrayAdd($aGuiIDs, $c)
				$ClickFullWarn = $c
				GUICtrlSetColor(-1, $COLOR_BLUE)
				GUICtrlSetTip(-1, Msg($mLabels[24], BaseName($sErrorLog)))
				GUICtrlSetCursor(-1, 0)
			EndIf

			$iLine += 1
			$c = GUICtrlCreateLabel(Msg($mLabels[25]), $x1, $y1 + $h * $iLine, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel(_WinAPI_StrFormatByteSize($aCurrentQuery[8]), $x1 + $l1, $y1 + $h * $iLine, $l2, 17)
			_ArrayAdd($aGuiIDs, $c)

			$c = GUICtrlCreateButton(Msg($mButtons[6]), 710, 327, 75, 25)
			$btnDelete = $c
			_ArrayAdd($aGuiIDs, $c)

			; [2]=1 -> ist ein aktueller pfad
			If $aCurrentQuery[2] = "1" Then
				$c = GUICtrlCreateRadio(Msg($mLabels[26]), 504, 318, 200, 17)
				$radioAddTodo = $c
				_ArrayAdd($aGuiIDs, $c)
				$c = GUICtrlCreateRadio(Msg($mLabels[27]), 504, 336, 200, 17)
				$radioDelTodo = $c
				_ArrayAdd($aGuiIDs, $c)
				If $aBackupTodo[$iTodoIndex][0] <> "nu" Then
					GUICtrlSetState($radioAddTodo, $GUI_CHECKED)
				Else
					GUICtrlSetState($radioDelTodo, $GUI_CHECKED)
				EndIf
			EndIf

		Case "u"
			Local $sArchiv = StringRight($aCurrentQuery[7], $sFileNameLen + 3)
			Local $sUpdate = StringRight($aCurrentQuery[8], $sFileNameLen + 3)
			Local $s1 = StringTrimRight($aCurrentQuery[7], 3)
			Local $s2 = StringTrimRight($aCurrentQuery[8], 3)
			Local $sErrorLog = $sAppPath & "Logfiles" & StringRight($s1, 2 * $sFileNameLen + 2) & ".log"
			Local $sErrorLog2 = $sAppPath & "Logfiles" & StringRight($s2, 2 * $sFileNameLen + 2) & ".log"
			Local $iLine = 1

			$c = GUICtrlCreateLabel(Msg($mLabels[20]), $x1, $y1 + $h * $iLine, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel($sDrive & "\..\" & $sArchiv, $x1 + $l1, $y1 + $h * $iLine, $l2, 17)
			_ArrayAdd($aGuiIDs, $c)
			$ClickFullZIP = $c
			GUICtrlSetColor(-1, $COLOR_BLUE)
			GUICtrlSetTip(-1, Msg($mLabels[21], $sArchiv))
			GUICtrlSetFont(-1, -1, -1, 4)
			GUICtrlSetCursor(-1, 0)

			$iLine += 1
			$c = GUICtrlCreateLabel(Msg($mLabels[22]), $x1, $y1 + $h * $iLine, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			;$c = GUICtrlCreateLabel(_WinAPI_StrFormatByteSize($aCurrentQuery[6]), $x1 + $l1, $y1 + $h * $iLine, $l2, 17)
			$c = GUICtrlCreateLabel(_WinAPI_StrFormatByteSize(FileGetSize($aCurrentQuery[7])), $x1 + $l1, $y1 + $h * $iLine)
			_ArrayAdd($aGuiIDs, $c)

			If FileExists($sErrorLog) Then
				Local $a = ControlGetPos($hGUI, "", $c)
				Local $iWarnings = _FileCountLines($sErrorLog)
				$c = GUICtrlCreateLabel(Msg($mLabels[23], $iWarnings), $a[0] + $a[2], $y1 + $h * $iLine, $l2 - $a[2], 17)
				_ArrayAdd($aGuiIDs, $c)
				$ClickFullWarn = $c
				GUICtrlSetColor($c, $COLOR_BLUE)
				GUICtrlSetTip($c, Msg($mLabels[24], BaseName($sErrorLog)))
				GUICtrlSetCursor($c, 0)
			EndIf

			$iLine += 1
			$c = GUICtrlCreateLabel(Msg($mLabels[28]), $x1, $y1 + $h * $iLine, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel($sDrive & "\..\" & $sUpdate, $x1 + $l1, $y1 + $h * $iLine, $l2, 17)
			_ArrayAdd($aGuiIDs, $c)
			$ClickUpdateZIP = $c
			GUICtrlSetColor(-1, $COLOR_BLUE)
			GUICtrlSetTip(-1, Msg($mLabels[29], $sUpdate))
			GUICtrlSetFont(-1, -1, -1, 4)
			GUICtrlSetCursor(-1, 0)

			$iLine += 1
			$c = GUICtrlCreateLabel(Msg($mLabels[30]), $x1, $y1 + $h * $iLine, $l1, 17)
			_ArrayAdd($aGuiIDs, $c)
			$c = GUICtrlCreateLabel(_WinAPI_StrFormatByteSize($aCurrentQuery[6]), $x1 + $l1, $y1 + $h * $iLine)
			_ArrayAdd($aGuiIDs, $c)

			If FileExists($sErrorLog2) Then
				Local $a = ControlGetPos($hGUI, "", $c)
				Local $iWarnings = _FileCountLines($sErrorLog2)
				$c = GUICtrlCreateLabel(Msg($mLabels[23], $iWarnings), $a[0] + $a[2] - 5, $y1 + $h * $iLine, $l2 - $a[2], 17)
				_ArrayAdd($aGuiIDs, $c)
				$ClickUpdateWarn = $c
				GUICtrlSetColor(-1, $COLOR_BLUE)
				GUICtrlSetTip(-1, Msg($mLabels[24], BaseName($sErrorLog2)))
				GUICtrlSetCursor(-1, 0)
			EndIf

			$c = GUICtrlCreateButton(Msg($mButtons[6]), 710, 327, 75, 25)
			$btnDelete = $c
			_ArrayAdd($aGuiIDs, $c)
	EndSwitch

	; remember last id
	$iOldIndex = $iIndex
	$aGuiIDs[0] = UBound($aGuiIDs) - 1
	Return $iReturn
EndFunc   ;==>ManageBackups_Info

; #FUNCTION# ====================================================================================================================
; Name ..........: ManageBackups_TV
; Description ...: TreeView erstellen
; Syntax ........: ManageBackups_TV()
;	id = id vom stick
;	$tv = treeview id
;	$aPaths = arrays der pfade, welche aus ini gelesen werden sollen
;	$aBackups = zu füllendes allwissendes array
;	$aBackupTodo = liste der zu sichernden pfade
;	$sColor = wenn leer, dann handelt es sich um aktuelles backup, ansonsten farbe der inaktiven
; Author ........: Tino Reichardt
; Modified ......: 20.01.2015
; ===============================================================================================================================
Func ManageBackups_TV($id, $tv, $aPaths, ByRef $aBackups, ByRef $aBackupTodo, $sColor = "")
	Local $tsCurrent = GetTimeStamp() ; aktueller timestamp
	Local $sIndexTemp = GetTempIndex($id) ; temp. ini file
	Local $sBackupBase = $aCurrentSticks[$id][$eBackupPath]
	Local $sText

	; erstmal alle aktuellen Backuppfade durchgehen
	For $iPath = 1 To $aPaths[0]
		; cts=timestamp -> creation timestamp of filepath (pfad angelegt am...)
		; fts=timestamp -> ts letzte sicherung - ist 0 wenn noch keine angelegt
		; fNUMBER=ts:runtime:bytes    -> ein full backup, NUMBER ist auch ein TS, aber ohne spez. Bedeutung!
		; fNUMBER=ts:runtime:bytes;ts2:runtime2:bytes2 -> one fullbackup with one update

		Local $sPath = $aPaths[$iPath] ; aktuelle filepath
		Local $tvPath = GUICtrlCreateTreeViewItem("[" & $sPath & "]", $tv)
		Local $iPathBytesBackups = 0 ; summary for path
		Local $iPathBytesUpdates = 0 ; summary for path

		; alte sicherung / oder aktuelle filepath?
		Local $sIsBackup = "|1|"
		If $sColor <> "" Then
			; alte sicherungen werden grau :)
			GUICtrlSetColor($tvPath, $sColor)
			$sIsBackup = "|0|"
		EndIf

		; neue sicherung, da wir noch nie gesichert haben...
		Local $sMaxFTS = 0
		Local $sCTS = IniRead($sIndexTemp, $sPath, "cts", "0")
		Local $sFTS = IniRead($sIndexTemp, $sPath, "fts", "0")
		Local $sBackupPath = $sBackupBase & MyMiniHash($sPath)

		; add to big array
		; 0=path | 1=tvid | 2=is current | 3=dir (sha(path+salt) | 4=cts
		; -> später: | 5=filepath | 6=bytes alle | 7=anzahl sicherungen | 8=anzahl updates
		_ArrayAdd($aBackups, "p|" & $tvPath & $sIsBackup & $sBackupPath & "|" & $sCTS & "|" & $sPath & "|0|0|0")
		$aBackups[0][0] += 1 ; array rows += 1
		$aBackups[0][1] += 1 ; filepaths += 1
		Local $iLastPath = $aBackups[0][0]

		; wenn fts=0 ist, ist noch nie ein update gelaufen, quasi ersteinrichtung...
		If $sColor = "" Then
			Local $sBackupFull = $sBackupPath & "\" & MyMiniHash($sPath & $tsCurrent)
			Local $sBackupFullZip = $sBackupFull & "\" & MyMiniHash($sPath & $tsCurrent) & ".7z"
			If $sFTS = "0" Then
				; [a][tvid][inikey][path][archiv][-] -> full backup
				_ArrayAdd($aBackupTodo, "a|" & $tvPath & "|f" & $tsCurrent & "|" & $tsCurrent & "|" & $sPath & "|" & $sBackupFullZip)
				$aBackupTodo[0][0] += 1 ; rows
				$aBackupTodo[0][1] += 1 ; full backups

				; hier erstellen wir auch schonmal das Grundverzeichnis für diesen Pfad
				DirCreate($sBackupPath)

				; mehr brauchen wir nun erstmal nicht machen, sofern fts=0
				ContinueLoop
			Else
				; dickes full backup erstmal aus, später wird darüber entschieden, ob es laufen sollte
				_ArrayAdd($aBackupTodo, "na|" & $tvPath & "|f" & $tsCurrent & "|" & $tsCurrent & "|" & $sPath & "|" & $sBackupFullZip)
				$aBackupTodo[0][0] += 1 ; rows
			EndIf
		EndIf

		; [0][0]=count  [1][0]=Key1  [1][1]=Value1 ..
		Local $aSection = IniReadSection($sIndexTemp, $sPath)
		; section nicht da? dies dürfte nie auftreten, da wir den index beim start aktualisieren!
		If @error <> 0 Then FatalError(Msg($mFatalErrors[2]))

		;_ArrayDisplay($aSection)
		For $iSection = 1 To $aSection[0][0]
			Local $sKey = $aSection[$iSection][0] ; ini key
			If Not (StringLeft($sKey, 1) = "f") Then ContinueLoop ; am anfang ein kleines "f" ?
			If Not StringIsDigit(StringTrimLeft($sKey, 1)) Then ContinueLoop ; dann dürfen es nur zahlen sein!

			; wenn bis hier, dann haben wir ein neues FullBackup gefunden...
			Local $sFull = $aSection[$iSection][1] ; ini value

			; zwei Möglichkeiten:
			; 1) f1234=TS1:runtime:bytes -> nur full backup
			; 2) f1234=TS1:runtime:bytes;TS2:runtime2:bytes2 -> mit einem update

			; $aUpdates[0]=1 -> nur full backkup, wenn größer dann entsprechend updates dazu...
			Local $aFull = StringSplit($sFull, ";")
			If Not IsArray($aFull) Then FatalError(Msg($mFatalErrors[3]))

			Local $aUpdate = StringSplit($aFull[1], ":")
			If Not IsArray($aUpdate) Then FatalError(Msg($mFatalErrors[4]))

			; Full Backup Daten
			Local $sFTimeStamp = $aUpdate[1]
			Local $sLength = GetBackupTime($aUpdate[2])
			Local $sBytes = $aUpdate[3]
			Local $sText = Msg($mLabels[31], $sLength)
			Local $tvFull = GUICtrlCreateTreeViewItem(StringFormatTime($sText, $sFTimeStamp), $tvPath)
			If $sColor <> "" Then GUICtrlSetColor($tvFull, $sColor)

			; BackupPath    = E:\usb-backup\user@host\@BackupDir
			; BackupFull    = E:\usb-backup\user@host\@BackupDir\@FullBackup
			; BackupFullZip = E:\usb-backup\user@host\@BackupDir\@FullBackup\@FullBackup.7z
			; BackupUpdate  = E:\usb-backup\user@host\@BackupDir\@FullBackup\@Update.7z
			; @BackupDir    = sha(filepath & salt)   -> filepath = section from index.ini
			; @FullBackup   = sha(filepath & fTimestamp & salt) -> timestamp of full backup
			; @Update       = sha(filepath & uTimestamp & salt) -> timestamp of update
			Local $sBackupFull = $sBackupPath & "\" & MyMiniHash($sPath & $sFTimeStamp)
			Local $sBackupFullZip = $sBackupFull & "\" & MyMiniHash($sPath & $sFTimeStamp) & ".7z"
			Local $sBackupUpdate = $sBackupFull & "\" & MyMiniHash($sPath & $sFTimeStamp & $tsCurrent) & ".7z"

			; wenn datei nicht gefunden, index reparieren oder ignorieren?
			If Not FileExists($sBackupFullZip) Then
				$sText = Msg($mLabels[32]) & @CRLF
				$sText &= StringLeft($sBackupFullZip, 23) & "..." & StringRight($sBackupFullZip, 23) & @CRLF & @CRLF
				$sText &= Msg($mLabels[33]) & @CRLF & @CRLF
				$sText &= Msg($mLabels[34]) & @CRLF
				MsgBox($MB_ICONWARNING, $sTitle, $sText)
				IniDelete($sIndexTemp, $sPath, "f" & $sFTimeStamp)
				UpdateIndexFile($id) ; save it!
				ContinueLoop
			EndIf
			DirCreate($sBackupFull)

			; 0=full | 1=tvid | 2=is current | 3=pkdf(f-timestamp) | 4=cts
			Local $s = "f|" & $tvFull & $sIsBackup & $sBackupFull & "|" & $sFTimeStamp
			; | 5=filepath | 6=bytes | 7=base archiv  | 8=bytes all updates in this backup
			$s &= "|" & $sPath & "|" & $aUpdate[3] & "|" & $sBackupFullZip & "|0" ; & $aFull[0] - 1
			_ArrayAdd($aBackups, $s)
			$aBackups[0][0] += 1 ; array rows += 1
			$aBackups[0][2] += 1 ; full backups += 1
			$aBackups[0][5] += $aUpdate[3] ; bytes alle full backups
			$iPathBytesBackups += $aUpdate[3]
			$aBackups[$iLastPath][7] += 1 ; full in path += 1
			Local $iLastFull = $aBackups[0][0]

			; u|28|f1422445625|C:\2\1|M:\USB-Backup\nutzer@NUTZER-PC\33D1D7323EBF6E2DBB04\33D1D7323EBF6E2DBB04.7z|update.7z
			; wir setzen erstmal keine updates automatisch, erst am ende wird bei der neuesten sicherung das update aktiviert...
			_ArrayAdd($aBackupTodo, "nu|" & $tvFull & "|f" & $sFTimeStamp & "|" & $tsCurrent & "|" & $sPath & "|" & $sBackupFullZip & "|" & $sBackupUpdate)
			$aBackupTodo[0][0] += 1 ; rows

			; wenn updates da sind, auch diese darstellen...
			For $iArchivUpdate = 2 To $aFull[0]

				Local $aUpdate = StringSplit($aFull[$iArchivUpdate], ":")
				If Not IsArray($aUpdate) Then FatalError(Msg($mFatalErrors[4]))

				Local $sUTimeStamp = $aUpdate[1]
				Local $sLength = GetBackupTime($aUpdate[2])
				Local $sText = Msg($mLabels[37], $sLength)
				Local $tvUpdate = GUICtrlCreateTreeViewItem(StringFormatTime($sText, $sUTimeStamp), $tvFull)
				Local $sBackupUpdate = $sBackupFull & "\" & MyMiniHash($sPath & $sFTimeStamp & $sUTimeStamp) & ".7z"
				If $sColor <> "" Then GUICtrlSetColor($tvUpdate, $sColor)

				; update.7z nicht da, was tun?
				If Not FileExists($sBackupUpdate) Then
					$sText = Msg($mLabels[35]) & @CRLF
					$sText &= StringLeft($sBackupFullZip, 23) & "..." & StringRight($sBackupFullZip, 23) & @CRLF & @CRLF
					$sText &= Msg($mLabels[33]) & @CRLF & @CRLF
					; das geht schneller als index korrigieren ;)
					$sText &= Msg($mLabels[36]) & @CRLF
					MsgBox($MB_ICONWARNING, $sTitle, $sText)
					FileWrite($sBackupUpdate, "Jemand hatte diese Datei einfach gelöscht... :/")
				EndIf

				; 0=update | 1=tvid | 2=is current | 3=path-to-full backup | 4=full timestamp + update timestamp
				Local $s = "u|" & $tvUpdate & $sIsBackup & $sBackupFull & "|" & $sFTimeStamp & "+" & $sUTimeStamp
				; | 5=filepath | 6=bytes update | 7=base archive | 8=update archive
				$s &= "|" & $sPath & "|" & $aUpdate[3] & "|" & $sBackupFullZip & "|" & $sBackupUpdate
				_ArrayAdd($aBackups, $s)
				$aBackups[0][0] += 1 ; array rows += 1
				$aBackups[0][3] += 1 ; updates += 1
				$aBackups[0][4] += $aUpdate[3] ; bytes alle updates
				$aBackups[$iLastPath][8] += 1 ; updates in path += 1
				$aBackups[$iLastFull][8] += $aUpdate[3] ; bytes of updates in full += bytes
				$iPathBytesUpdates += $aUpdate[3]

			Next
			; ende für alle Updates

			; der fts eintrag von der ini kann veraltet sein, wenn eine neuere komplettsicherung gelöscht wurde!
			If $sMaxFTS < $sFTimeStamp Then $sMaxFTS = $sFTimeStamp ; wir suchen hier deshalb immer nochmal das neueste :)

		Next

		; ende alle Sicherungen eines Pfades
		If $sMaxFTS <> $sFTS Then
			; ui, wir haben einen unterschied mit dem fts=ts key der sektion... fix it!
			IniWrite($sIndexTemp, $sPath, "fts", $sMaxFTS)
			UpdateIndexFile($id) ; save it!
			$sFTS = $sMaxFTS
		EndIf

		; hier entscheidet sich, ob update oder komplette sicherung
		Local $i = 0
		If ($sColor = "") Then
			If $sFTS + ($sFullBackupIn * 60 * 60 * 24) > $tsCurrent Then
				Do
					;[13] nu|47|f1422552533|1422569083|C:\Users\nutzer\Documents|M:\USB-Backup\nutzer@NUTZER-PC\4384533657DD6CD7\DE77889EC5B116B9\DE77889EC5B116B9.7z|M:\USB-Backup\nutzer@NUTZER-PC\4384533657DD6CD7\DE77889EC5B116B9\A9B39B7A1B6B9AA6.7z
					If ($aBackupTodo[$i][0] = "nu") And ($aBackupTodo[$i][4] = $sPath) And ($aBackupTodo[$i][2] = "f" & $sFTS) Then
						$aBackupTodo[$i][0] = "u"
						$aBackupTodo[0][2] += 1 ; update counter
						ExitLoop
					EndIf
					$i += 1
				Until UBound($aBackupTodo) - 1 < $i
			Else
				Do
					; [12] na|46|f1422569083|1422569083|C:\Users\nutzer\Documents|M:\USB-Backup\nutzer@NUTZER-PC\4384533657DD6CD7\7238CAD81B1EE708\7238CAD81B1EE708.7z|
					If ($aBackupTodo[$i][0] = "na") And ($aBackupTodo[$i][4] = $sPath) Then
						$aBackupTodo[0][1] += 1 ; full backup counter
						$aBackupTodo[$i][0] = "a"
						ExitLoop
					EndIf
					$i += 1
				Until UBound($aBackupTodo) - 1 < $i
			EndIf
		EndIf

		; counter per path
		$aBackups[$iLastPath][6] = $iPathBytesBackups & "+" & $iPathBytesUpdates

	Next
	; ende alle Pfade
EndFunc   ;==>ManageBackups_TV

; #FUNCTION# ====================================================================================================================
; Name ..........: GetOLDFilePaths
; Description ...: Suchen von alten Backups, welche aktuell gar nicht mehr gesichert werden...
; Syntax ........: GetOLDFilePaths()
; Author ........: Tino Reichardt
; Modified ......: 29.01.2015
; ===============================================================================================================================
Func GetOLDFilePaths($sIndexTemp, ByRef $aOldPaths)
	Local $aOldBackups = IniReadSectionNames($sIndexTemp)

	; delete counter
	_ArrayDelete($aOldBackups, 0)
	While UBound($aOldBackups)
		Local $s = _ArrayPop($aOldBackups)
		Local $sFound = "no"
		If $s = $sAppName Then ContinueLoop
		For $i = 1 To $aFilePaths[0]
			If $s = $aFilePaths[$i] Then $sFound = "yes"
		Next
		If $sFound = "yes" Then ContinueLoop
		_ArrayAdd($aOldPaths, $s) ; ist alt
	WEnd

	; setup counter
	$aOldPaths[0] = UBound($aOldPaths) - 1
EndFunc   ;==>GetOLDFilePaths

; #FUNCTION# ====================================================================================================================
; Name ..........: DrawSpaceUsage
; Description ...: Info zum Platz auf dem Sicherungsdatenträger...
; Syntax ........: DrawSpaceUsage()
; Author ........: Tino Reichardt
; Modified ......: 29.01.2015
; ===============================================================================================================================
Func DrawSpaceUsage($sDrive)

	; wir rechnen hier mit Bytes... Autoit macht erstmal nur MB
	Local $iTotal = DriveSpaceTotal($sDrive) * 1024 * 1024
	Local $iFree = DriveSpaceFree($sDrive) * 1024 * 1024
	Local $iUsed = $iTotal - $iFree

	Local $y1 = 56, $h = 18
	GUICtrlCreateLabel(Msg($mLabels[38]), 504, $y1, 82, 17)
	GUICtrlCreateLabel(Msg($mLabels[39]), 504, $y1 + $h, 82, 17)
	GUICtrlCreateLabel(Msg($mLabels[40]), 504, $y1 + 69, 82, 17)

	GUICtrlCreateLabel(DriveGetLabel($sDrive), 586, $y1, 198, 17)
	GUICtrlCreateLabel(DriveGetFileSystem($sDrive), 586, $y1 + $h, 82, 17)
	GUICtrlCreateLabel(_WinAPI_StrFormatByteSize($iTotal), 586, $y1 + 69, 65, 17)

	; sind die Standard Windows Farben bei "Eigenschaften von C:"
	Local $sColors = "0x0000ff,0xff00ff"
	Local $sValues = Int($iUsed) & "," & Int($iFree)

	;_DrawPie($hWnd, $sValues, $sColors, $pieLeft, $pieTop, $pieWidth, $Aspect = 30, $pieDepth = 10, $rotation = 0)
	_DrawPie($hGUI, $sValues, $sColors, 650, $y1 + 22, 128, 40, 15)
	; _DrawLegend($hWnd, $sValues, $sColors, $sHeadline, $iLeft, $iTop, $iHeight = 18, $iFontSize = 8.5, $iX_Headline = 60, $iX_Value = 50, $iX_Percent = 40)
	_DrawLegend($hGUI, $sValues, $sColors, Msg($mLabels[41]), 504 - 2, $y1 + 86, 17, 8.5, 82, 70)
EndFunc   ;==>DrawSpaceUsage

; #FUNCTION# ====================================================================================================================
; Name ..........: DrawSpaceUsageStatus
; Description ...: Info zum Platz auf dem Sicherungsdatenträger...
; Syntax ........: DrawSpaceUsageStatus()
; Author ........: Tino Reichardt
; Modified ......: 17.02.2015
; ===============================================================================================================================
Func DrawSpaceUsageStatus($sDrive, $iNew)
	Static $ts = 0

	If $iNew = 0 Then
		$ts = 0
	EndIf

	; update not to often...
	If $ts + 3 > GetTimeStamp() Then Return

	; wir rechnen hier mit Bytes... Autoit macht erstmal nur MB
	Local $iTotal = DriveSpaceTotal($sDrive) * 1024 * 1024
	Local $iFree = DriveSpaceFree($sDrive) * 1024 * 1024
	Local $iUsed = $iTotal - $iFree

	Local $x1 = 18, $y1 = 264, $h = 18
	If $ts = 0 Then
		; muß nur ein mal erstellt werden:
		GUICtrlCreateLabel(Msg($mLabels[38]), $x1, $y1, 82, 17)
		GUICtrlCreateLabel(Msg($mLabels[39]), $x1, $y1 + $h, 82, 17)
		GUICtrlCreateLabel(DriveGetLabel($sDrive), $x1 + 87, $y1, 190, 17)
		GUICtrlCreateLabel(DriveGetFileSystem($sDrive), $x1 + 87, $y1 + $h, 82, 17)

		GUICtrlCreateLabel(Msg($mLabels[40]), $x1, $y1 + 51, 56, 17)
		GUICtrlCreateLabel(_WinAPI_StrFormatByteSize($iTotal), $x1 + 57, $y1 + 51, 65, 17)
		;GUICtrlSetBkColor(-1, 0xdd00aa)
	EndIf
	$ts = GetTimeStamp()

	Local $sColors = "0x0000ff,0x00ccff,0xff00ff"
	Local $sValues = Int($iUsed - $iNew) & "," & Int($iNew) & "," & Int($iFree)

	;_DrawPie($hWnd, $sValues, $sColors, $pieLeft, $pieTop, $pieWidth, $Aspect = 30, $pieDepth = 10, $rotation = 0)
	_DrawPie($hGUI, $sValues, $sColors, $x1 + 148, $y1 + 18, 134, 31, 13)
	; _DrawLegend($hWnd, $sValues, $sColors, $sHeadline, $iLeft, $iTop, $iHeight = 18, $iFontSize = 8.5, $iX_Headline = 60, $iX_Value = 50, $iX_Percent = 40)
	_DrawLegend($hGUI, $sValues, $sColors, Msg($mLabels[42]), $x1 - 2, $y1 + 70, 18, 8.5, 56, 75)
	Return
EndFunc   ;==>DrawSpaceUsageStatus

; #FUNCTION# ====================================================================================================================
; Name ..........: GetWindowBkColor
; Description ...: gibt Standard Hintergrund Farbe zurück
; Syntax ........: GetWindowBkColor()
; Author ........: Tino Reichardt
; Modified ......: 09.03.2015
; ===============================================================================================================================
Func GetWindowBkColor()
	Local $iOpt = Opt("WinWaitDelay", 10)
	Local $hWnd = GUICreate("", 11, 11, 1, 1, $WS_POPUP, $WS_EX_TOOLWINDOW)
	GUISetState()
	WinWait($hWnd)
	Local $iColor = PixelGetColor(5, 5, $hWnd)
	GUIDelete($hWnd)
	Opt("WinWaitDelay", $iOpt)
	Return $iColor
EndFunc   ;==>GetWindowBkColor

; #FUNCTION# ====================================================================================================================
; Name ..........: ManageBackups
; Description ...: löschen alter Sicherungen usw.
; Syntax ........: ManageBackups(USB Disk ID)
; Author ........: Tino Reichardt
; Modified ......: 20.01.2015
; ===============================================================================================================================
Func ManageBackups($id)
	Local $sIndexTemp = GetTempIndex($id)
	Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
	Local $sPassword = $aCurrentSticks[$id][$ePassword]
	Local $sBackupPath = $aCurrentSticks[$id][$eBackupPath]

	$hGUI = GUICreate(Msg($mHeadlines[4], $sTitle, $aCurrentSticks[$id][$eFullDrive]), $myWidth, $myHeight, -1, -1, $gGuiStyle, $gGuiExStyle)

	Local $lHeadline = GUICtrlCreateLabel(Msg($mLabels[43]), 8, 8, 458, 24)
	GUICtrlSetFont(-1, 10)

	GUICtrlCreateGroup(Msg($mLabels[44], $sDrive), 8, 32, 481, 361)
	Local $iStyle = BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS)
	Local $tv = GUICtrlCreateTreeView(15, 50, 467, 337, $iStyle)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlSetBkColor($tv, GetWindowBkColor())

	GUICtrlCreateGroup(Msg($mLabels[45], $sDrive), 496, 32, 297, 153)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUICtrlCreateGroup("", 496, 192, 297, 169)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	Local $btnStart = GUICtrlCreateButton(Msg($mButtons[9]), 496, 368, 142, 25)
	Local $btnOverview = GUICtrlCreateButton(Msg($mButtons[10]), 642, 368, 75, 25)
	Local $btnCancel = GUICtrlCreateButton(Msg($mButtons[12]), 720, 368, 75, 25)
	GUISetState(@SW_SHOW)

	DrawSpaceUsage($sDrive)

	; vorhandene Backup Infos kommen hier rein...
	Dim $aBackups[1][9] = [[0, 0, 0, 0, 0, 0, 0, 0, 0]]

	; zu erstellende Backups werden hier gespeichert
	; [0][0] -> rows
	; [0][1] -> full backups
	; [0][2] -> updates
	; a|29|f1422443019|f-timestamp|C:\2\1|M:\USB-Backup\nutzer@NUTZER-PC\33D1D7323EBF6E2DBB04\DA30BC2637B86E096F89\DA30BC2637B86E096F89.7z
	; u|29|f1422443019|u-timestamp|C:\2\1|M:\USB-Backup\nutzer@NUTZER-PC\33D1D7323EBF6E2DBB04\DA30BC2637B86E096F89\DA30BC2637B86E096F89.7z|update.7z
	Dim $aBackupTodo[1][7] = [[0, 0, 0, 0, 0, 0, 0]]

	; TreeView erzeugen...
	Dim $aOldPaths[1]
	GetOLDFilePaths($sIndexTemp, $aOldPaths)
	; _PrintFromArray($aOldPaths)

	ManageBackups_TV($id, $tv, $aFilePaths, $aBackups, $aBackupTodo)
	ManageBackups_TV($id, $tv, $aOldPaths, $aBackups, $aBackupTodo, 0x888888)
	;GUISetState(@SW_SHOW)

	; we want to see the overview as default
	GUICtrlSendMsg($btnOverview, $BM_CLICK, 0, 0)
	GUICtrlSetState($btnStart, $GUI_FOCUS)

	Dim $aGuiIDs[1]
	While 1
		Local $msg = GUIGetMsg()
		Switch $msg
			; ignore these things:
			Case 0, $GUI_EVENT_MOUSEMOVE, $GUI_EVENT_PRIMARYDOWN, $GUI_EVENT_PRIMARYUP, $GUI_EVENT_SECONDARYDOWN, $GUI_EVENT_SECONDARYUP
			Case $btnStart
				GUIDelete($hGUI)
				Local $i = 1
				Do
					If $aBackupTodo[$i][0] = "na" Or $aBackupTodo[$i][0] = "nu" Then
						_ArrayDelete($aBackupTodo, $i)
						ContinueLoop
					EndIf
					$i += 1
				Until UBound($aBackupTodo) - 1 < $i
				$aBackupTodo[0][0] = UBound($aBackupTodo) - 1
				Return $aBackupTodo
			Case $btnOverview
				For $i = 1 To $aGuiIDs[0]
					GUICtrlDelete($aGuiIDs[$i])
				Next
				ReDim $aGuiIDs[1]
				Local $x1 = 504, $y1 = 212, $h = 21, $c
				$c = GUICtrlCreateLabel(Msg($mLabels[46]), $x1, $y1 + $h * 0, 140, 17)
				_ArrayAdd($aGuiIDs, $c)
				$c = GUICtrlCreateLabel($aBackups[0][1], $x1 + 144, $y1 + $h * 0, 100, 17)
				_ArrayAdd($aGuiIDs, $c)

				$c = GUICtrlCreateLabel(Msg($mLabels[47]), $x1, $y1 + $h * 1, 140, 17)
				_ArrayAdd($aGuiIDs, $c)
				$c = GUICtrlCreateLabel($aBackups[0][2] & "  (" & _WinAPI_StrFormatByteSize($aBackups[0][5]) & ")", $x1 + 144, $y1 + $h * 1, 100, 17)
				_ArrayAdd($aGuiIDs, $c)

				$c = GUICtrlCreateLabel(Msg($mLabels[48]), $x1, $y1 + $h * 2, 140, 17)
				_ArrayAdd($aGuiIDs, $c)
				$c = GUICtrlCreateLabel($aBackups[0][3] & "  (" & _WinAPI_StrFormatByteSize($aBackups[0][4]) & ")", $x1 + 144, $y1 + $h * 2, 100, 17)
				_ArrayAdd($aGuiIDs, $c)

				$y1 = 316
				$c = GUICtrlCreateLabel(Msg($mLabels[49]), $x1, $y1, 140, 17)
				_ArrayAdd($aGuiIDs, $c)
				$c = GUICtrlCreateLabel($aBackupTodo[0][1], $x1 + 144, $y1, 100, 17)
				_ArrayAdd($aGuiIDs, $c)
				$c = GUICtrlCreateLabel(Msg($mLabels[50]), $x1, $y1 + $h, 140, 17)
				_ArrayAdd($aGuiIDs, $c)
				$c = GUICtrlCreateLabel($aBackupTodo[0][2], $x1 + 144, $y1 + $h, 100, 17)
				_ArrayAdd($aGuiIDs, $c)
				$aGuiIDs[0] = UBound($aGuiIDs) - 1

				;ConsoleWrite("$aBackupTodo:" & @CRLF)
				;_PrintFromArray($aBackupTodo)
				;ConsoleWrite("$aBackups:" & @CRLF)
				;_PrintFromArray($aBackups)
			Case $GUI_EVENT_CLOSE, $btnCancel
				ExitLoop
			Case Else
				; get ctrlid of treeview item
				Local $tvid = GUICtrlRead($tv)
				;ConsoleWrite("gid=" & $tvid & " msg=" & $msg & @CRLF)
				Switch ManageBackups_Info($id, $msg, $tvid, $tv, $aBackups, $aBackupTodo, $aGuiIDs)
					Case 1
						; 1) tree new einlesen
						Dim $aBackups[1][9] = [[0, 0, 0, 0, 0, 0, 0, 0, 0]]
						Dim $aBackupTodo[1][7] = [[0, 0, 0, 0, 0, 0, 0]]
						Dim $aOldPaths[1]
						GetOLDFilePaths($sIndexTemp, $aOldPaths)
						ManageBackups_TV($id, $tv, $aFilePaths, $aBackups, $aBackupTodo)
						ManageBackups_TV($id, $tv, $aOldPaths, $aBackups, $aBackupTodo, 0x888888)
						DrawSpaceUsage($sDrive)
				EndSwitch
		EndSwitch
	WEnd

	GUIDelete($hGUI)
	Return ""
EndFunc   ;==>ManageBackups

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlCreateLabel
; Description ...: Wrapper für _GUICtrlFFLabel_Create
; Syntax ........: _GUICtrlCreateLabel(params)
; Author ........: Tino Reichardt
; Modified ......: 20.02.2015
; ===============================================================================================================================
Func _GUICtrlCreateLabel($sText, $iLeft, $iTop, $iWidth = 50, $iHeight = 17)
	Return _GUICtrlFFLabel_Create($hGUI, $sText, $iLeft, $iTop, $iWidth, $iHeight, 8.5, 'Microsoft Sans Serif')
EndFunc   ;==>_GUICtrlCreateLabel

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlSetData
; Description ...: Wrapper für _GUICtrlFFLabel_SetData
; Syntax ........: _GUICtrlSetData($iIndex, $sText, $iColor = 0xff & RGB)
; Author ........: Tino Reichardt
; Modified ......: 20.02.2015
; ===============================================================================================================================
Func _GUICtrlSetData($iIndex, $sText, $iColor = -1)
	;Return _GUICtrlFFLabel_SetData($iIndex, $sText)
	If $iColor = -1 Then
		Return _GUICtrlFFLabel_SetData($iIndex, $sText)
	Else
		Return _GUICtrlFFLabel_SetData($iIndex, $sText, $iColor)
	EndIf
EndFunc   ;==>_GUICtrlSetData

; #FUNCTION# ====================================================================================================================
; Name ..........: DirName
; Description ...: gibt Verzeichnis eines Pfades zurück
; Syntax ........: DirName()
; Author ........: Tino Reichardt
; Modified ......: 06.03.2015
; ===============================================================================================================================
Func DirName($sPath)
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	_PathSplit($sPath, $sDrive, $sDir, $sFileName, $sExtension)
	Return $sDrive & $sDir
EndFunc   ;==>DirName

; #FUNCTION# ====================================================================================================================
; Name ..........: BaseName
; Description ...: gibt Dateinamen eines Pfades zurück
; Syntax ........: BaseName()
; Author ........: Tino Reichardt
; Modified ......: 06.03.2015
; ===============================================================================================================================
Func BaseName($sPath)
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	_PathSplit($sPath, $sDrive, $sDir, $sFileName, $sExtension)
	Return $sFileName
EndFunc   ;==>BaseName

Func CreateNewBackup_SetStatus($id, $v)
	;ConsoleWrite("neuer status id=" & $id & " v=" & $v & @CRLF)
	Switch $v
		Case "7z:end"
			GUICtrlSetColor($id, 0x005500) ; RGB: grün
			GUICtrlSetData($id, Msg($mTaskStatus[1]))
		Case "7z:cancel"
			; Task abgebrochen
			GUICtrlSetColor($id, 0xaa0000) ; RGB: rot
			GUICtrlSetData($id, Msg($mTaskStatus[2]))
		Case "7z:error"
			; 7z:error -> speicherplatz oder sowas...
			GUICtrlSetColor($id, 0xaa0000) ; RGB: rot
			GUICtrlSetData($id, Msg($mTaskStatus[3]))
		Case "7z:scan"
			GUICtrlSetColor($id, 0x0000aa) ; RGB: blau
			GUICtrlSetData($id, Msg($mTaskStatus[4]))
		Case "7z:zip"
			GUICtrlSetColor($id, 0x0000aa) ; RGB: blau
			GUICtrlSetData($id, Msg($mTaskStatus[5]))
	EndSwitch
EndFunc   ;==>CreateNewBackup_SetStatus

; #FUNCTION# ====================================================================================================================
; Name...........: _GetTabColor
; Description ...: Farbe vom Tab Control bekommen
; Syntax.........: _GetTabColor($Tab)
; Author ........: Tino Reichardt
; Modified ......: 10.03.2015
; ===============================================================================================================================
Func _GetTabColor($Tab)
	Local $aPosWin = WinGetPos($hGUI)
	Local $aPosCtrl = ControlGetPos($hGUI, "", $Tab)
	Local $iColor = Hex(PixelGetColor($aPosWin[0] + $aPosCtrl[0] + $aPosCtrl[2] - 2, _
			$aPosWin[1] + $aPosCtrl[1] + $aPosCtrl[3] - 2, ControlGetHandle($hGUI, "", $Tab)), 6)
	Return $iColor
EndFunc   ;==>_GetTabColor

; #FUNCTION# ====================================================================================================================
; Name...........: CreatePowerPlan
; Description ...: Das ganze PowerManagement zeugs deaktivieren... damit das Backup nicht abgebrochen wird
; Syntax.........: CreatePowerPlan()
; Author ........: Tino Reichardt
; Modified ......: 27.05.2015
; ===============================================================================================================================
Func CreatePowerPlan()
	Local $sText = ''
	$sText &= '@echo on' & @CRLF
	$sText &= '' & @CRLF
	$sText &= 'rem Windows Standard wiederherstellen geht so:' & @CRLF
	$sText &= 'rem @winxp: powercfg /RestoreDefaultPolicies' & @CRLF
	$sText &= 'rem @win7:  powercfg -RestoreDefaultSchemes' & @CRLF
	$sText &= '' & @CRLF
	$sText &= 'ver | find "[Version 5"' & @CRLF
	$sText &= 'if %errorlevel% == 0 goto winxp' & @CRLF
	$sText &= 'goto win7' & @CRLF
	$sText &= '' & @CRLF
	$sText &= 'rem Windows XP / Server 2003' & @CRLF
	$sText &= ':winxp' & @CRLF
	$sText &= 'echo WinXP' & @CRLF
	$sText &= 'rem 1) zeile suchen 2) "Name" weg machen 3) führende Leerzeichen weg machen' & @CRLF
	$sText &= 'for /f "delims=*" %%i in (' & "'" & 'powercfg /query ^| find "Name"' & "'" & ') do (set x=%%i)' & @CRLF
	$sText &= 'set x=%x:~4,200%' & @CRLF
	$sText &= 'for /f "tokens=* delims= " %%a In ("%x%") Do set x=%%a' & @CRLF
	$sText &= 'set GUID_OLD=%x%' & @CRLF
	$sText &= 'powercfg /create USB-Backup' & @CRLF
	$sText &= 'powercfg /change USB-Backup /disk-timeout-ac 0' & @CRLF
	$sText &= 'powercfg /change USB-Backup /disk-timeout-dc 0' & @CRLF
	$sText &= 'powercfg /change USB-Backup /monitor-timeout-ac 5' & @CRLF
	$sText &= 'powercfg /change USB-Backup /monitor-timeout-dc 5' & @CRLF
	$sText &= 'powercfg /change USB-Backup /standby-timeout-ac 0' & @CRLF
	$sText &= 'powercfg /change USB-Backup /standby-timeout-dc 0' & @CRLF
	$sText &= 'powercfg /change USB-Backup /hibernate-timeout-ac 0' & @CRLF
	$sText &= 'powercfg /change USB-Backup /hibernate-timeout-dc 0' & @CRLF
	$sText &= 'powercfg /change USB-Backup /processor-throttle-ac adaptive' & @CRLF
	$sText &= 'powercfg /change USB-Backup /processor-throttle-dc adaptive' & @CRLF
	$sText &= 'powercfg /setactive USB-Backup' & @CRLF
	$sText &= 'title POWERCFG-IS-READY' & @CRLF
	$sText &= ':winxp_wait' & @CRLF
	$sText &= 'ping -n 2 127.0.0.1 > NUL' & @CRLF
	$sText &= 'if not exist %0.finished goto winxp_wait' & @CRLF
	$sText &= 'powercfg /setactive "%GUID_OLD%"' & @CRLF
	$sText &= 'powercfg /delete USB-Backup' & @CRLF
	$sText &= 'goto end' & @CRLF
	$sText &= '' & @CRLF
	$sText &= 'rem Windows Vista / 7 / 8 ...' & @CRLF
	$sText &= ':win7' & @CRLF
	$sText &= 'echo Win7' & @CRLF
	$sText &= 'for /f "skip=2 tokens=2,3,4 delims=:()" %%G in (' & "'powercfg -list') do (" & @CRLF
	$sText &= ' if "%%I" == " *" set GUID_OLD=%%G' & @CRLF
	$sText &= ')' & @CRLF
	$sText &= 'set GUID_MAX=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' & @CRLF
	$sText &= 'set GUID_USB=8379f509-36a0-4184-a6a6-f2836a1329d5' & @CRLF
	$sText &= 'powercfg -duplicatescheme %GUID_MAX% %GUID_USB%' & @CRLF
	$sText &= 'powercfg -changename %GUID_USB% USB-Backup' & @CRLF
	$sText &= 'powercfg -setactive %GUID_USB%' & @CRLF
	$sText &= 'powercfg -change -disk-timeout-ac 0' & @CRLF
	$sText &= 'powercfg -change -disk-timeout-dc 0' & @CRLF
	$sText &= 'powercfg -change -monitor-timeout-ac 5' & @CRLF
	$sText &= 'powercfg -change -monitor-timeout-dc 5' & @CRLF
	$sText &= 'powercfg -change -standby-timeout-ac 0' & @CRLF
	$sText &= 'powercfg -change -standby-timeout-dc 0' & @CRLF
	$sText &= 'powercfg -change -hibernate-timeout-ac 0' & @CRLF
	$sText &= 'powercfg -change -hibernate-timeout-dc 0' & @CRLF
	$sText &= 'powercfg -change -processor-throttle-ac adaptive' & @CRLF
	$sText &= 'powercfg -change -processor-throttle-dc adaptive' & @CRLF
	$sText &= 'rem Untergruppe Festplatte / Festplatte ausschalten nach' & @CRLF
	$sText &= 'set GUID_SUB=0012ee47-9041-4b5d-9b77-535fba8b1442' & @CRLF
	$sText &= 'set GUID_IDX=6738e2c4-e8a5-4a42-b16a-e040e769756e' & @CRLF
	$sText &= 'powercfg -SetAcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'powercfg -SetDcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'rem Untergruppe USB-Einstellungen / Einstellungen für selektives USB-Energiesparen' & @CRLF
	$sText &= 'set GUID_SUB=2a737441-1930-4402-8d77-b2bebba308a3' & @CRLF
	$sText &= 'set GUID_IDX=48e6b7a6-50f5-4782-a5d4-53bb8f07e226' & @CRLF
	$sText &= 'powercfg -SetAcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'powercfg -SetDcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'rem Untergruppe Energie sparen / Hybriden Standbymodus zulassen' & @CRLF
	$sText &= 'set GUID_SUB=238c9fa8-0aad-41ed-83f4-97be242c8f20' & @CRLF
	$sText &= 'set GUID_IDX=94ac6d29-73ce-41a6-809f-6363ba21b47e' & @CRLF
	$sText &= 'powercfg -SetAcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'powercfg -SetDcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'rem Untergruppe Energie sparen / Ruhezustand nach' & @CRLF
	$sText &= 'set GUID_IDX=9d7815a6-7ee4-497e-8888-515a05f02364' & @CRLF
	$sText &= 'powercfg -SetAcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'powercfg -SetDcValueIndex %GUID_USB% %GUID_SUB% %GUID_IDX% 0' & @CRLF
	$sText &= 'title POWERCFG-IS-READY' & @CRLF
	$sText &= ':win7_wait' & @CRLF
	$sText &= 'ping -n 2 127.0.0.1 > NUL' & @CRLF
	$sText &= 'if not exist %0.finished goto win7_wait' & @CRLF
	$sText &= 'powercfg -setactive %GUID_OLD%' & @CRLF
	$sText &= 'powercfg -delete %GUID_USB%' & @CRLF
	$sText &= 'goto end' & @CRLF
	$sText &= '' & @CRLF
	$sText &= ':end' & @CRLF
	$sText &= 'del %0.finished' & @CRLF
	$sText &= '' & @CRLF
	; file erstellen + runwait()

	Local $sFile = $sTempPath & "PowerOnWayne.cmd"
	FileDelete($sFile)
	FileWrite($sFile, $sText)
	$iPowerPlanPid = ShellExecute($sFile, "", "", "", $sDebugPowerPlan = "0" ? @SW_HIDE : @SW_SHOW)
EndFunc   ;==>CreatePowerPlan

; #FUNCTION# ====================================================================================================================
; Name...........: ResetPowerPlan
; Description ...: PowerManagement wieder zurücksetzen... (wir legen nur die datei .finished an ...!)
; Syntax.........: ResetPowerPlan()
; Author ........: Tino Reichardt
; Modified ......: 02.06.2015
; ===============================================================================================================================
Func ResetPowerPlan()
	Local $sFile = $sTempPath & "PowerOnWayne.cmd.finished"
	While ProcessExists($iPowerPlanPid)
		FileWrite($sFile, $iPowerPlanPid)
		Sleep(500)
	WEnd
	FileDelete($sFile)
EndFunc   ;==>ResetPowerPlan

; #FUNCTION# ====================================================================================================================
; Name ..........: CreateNewBackup
; Description ...: Backup erstellen, inkl. Status usw.
; Syntax ........: CreateNewBackup()
; Author ........: Tino Reichardt
; Modified ......: 20.01.2015
; ===============================================================================================================================
Func CreateNewBackup($id, $aBackupTodo)
	Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
	Local $tsBegin = GetTimeStamp()
	Local $aDrivesWithVSS
	Local $iStatusLabel
	Local $sStatusText

	$hGUI = GUICreate(Msg($mHeadlines[5], $sTitle), $myWidth, $myHeight, -1, -1, $gGuiStyle)

	; Run Some Command before Backup... if the user wants multiple commands, he must use some batchfile...
	If $sRunBeforeCmd <> "" Then RunWait($sRunBeforeCmd)

	; Fenster für nachrichten erstellen, sofern benötigt
	If $sEnableVSS = "1" Or $sUsePowerPlan = "1" Then
		GUISetState(@SW_SHOW, $hGUI)
		$sStatusText = Msg($mLabels[51])
		$iStatusLabel = _GUICtrlFFLabel_Create($hGUI, $sStatusText, 8, 8, $myWidth - 16, $myHeight - 16, 9, "Lucida Console")
	EndIf

	; wir erstellen einen temp. powerplan...
	; -> damit der rechner nicht einfach in den stand by geht...
	If $sUsePowerPlan = "1" Then
		CreatePowerPlan()
		$sStatusText &= @CRLF & Msg($mLabels[52])
		_GUICtrlSetData($iStatusLabel, $sStatusText)
	EndIf

	If $sEnableVSS = "1" Then
		$aDrivesWithVSS = CreateVSSDevices($id, $aBackupTodo, $iStatusLabel, $sStatusText)

		If Not IsArray($aDrivesWithVSS) Then
			GUIDelete($hGUI)
			TrayTip($sTitle, Msg($mMessages[7]), $iTrayTipTime, $TIP_ICONASTERISK)
			If $sUsePowerPlan = "1" Then ResetPowerPlan()
			$iRunningBackup = 0
			EnableTrayMenu()
			Return
		EndIf
	Else
		; no VSS
		FileChangeDir($sTempPath)
		DoBackup_PrepareExefiles($sTempPath)
		$aDrivesWithVSS = 0
	EndIf

	If $sEnableVSS = "1" Or $sUsePowerPlan = "1" Then
		_GUICtrlFFLabel_Delete($iStatusLabel)
	EndIf

	; Status TrayMenu
	$iRunningBackup = $hGUI
	EnableTrayMenu()

	#cs
		von 7zip:
		01) elapsed time 00:00:33
		02) remaining time 00:00:33
		03) status: scanning/compressing/finished
		04) total size in bytes
		05) processed size in bytes
		06) packet size in bytes
		07) files, total
		08) files, processed
		09) compression ratio : 15 %
		10) speed in bytes/s
		11) current dir\n\r current file->wichtig!
		12) anzahl fehler
		13) fehler meldungen
		-> Gid[$i]
	#ce

	; interaction with 7zip... one dummy, one old value (used: 1..13)
	Dim $aGid[$aBackupTodo[0][0] + 1][14] ; 1..13 -> current value (set via 7zip)
	Dim $aHwnd[$aBackupTodo[0][0] + 1][14] ; 1..13 -> hwnd of gid (for cmdline)
	Dim $aLast[$aBackupTodo[0][0] + 1][14] ; 1..13 -> last values of 7zip

	; real labels, to be shown / calculated
	Dim $aReal[18] ;  used: 1..17
	Dim $aButtons[$aBackupTodo[0][0] + 1][4] ; die vier buttons je task

	Local $iTaskGroup = GUICtrlCreateGroup("", 8, 4, 785, 230, -1, $WS_EX_TRANSPARENT)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ; group end

	; space on stick / hdd
	GUICtrlCreateGroup(Msg($mLabels[45], $sDrive), 8, 240, 297, 153)
	DrawSpaceUsageStatus($sDrive, 0)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; 01) elapsed time 00:00:33
	Local $xw = 188
	$aReal[1] = _GUICtrlCreateLabel("", 28 + $xw * 0, 46, 180, 17)

	; 02) remaining time 00:00:33
	$aReal[2] = _GUICtrlCreateLabel("", 28 + $xw * 1, 46, 180, 17)

	; 03) status: scanning/compressing/finished
	$aReal[3] = GUICtrlCreateLabel("", 585, 192, 190, 26)
	GUICtrlSetFont($aReal[3], 11)

	; 04) total size in bytes
	; 05) processed size in bytes
	; 06) packet size in bytes
	; 09) compression ratio : 15 % (kommt direkt hinter gepackte größe)
	$aReal[4] = _GUICtrlCreateLabel("", 28, 56 + 15, 744, 17)
	$aReal[5] = GUICtrlCreateProgress(28, 74 + 15, 700, 19)
	$aReal[6] = _GUICtrlCreateLabel("", 701 + 28, 76 + 15, 43, 17)

	; 07) files, total
	; 08) files, processed
	$aReal[7] = _GUICtrlCreateLabel("", 28, 115, 744, 17)
	$aReal[8] = GUICtrlCreateProgress(28, 133, 700, 19)
	$aReal[9] = _GUICtrlCreateLabel("", 701 + 28, 135, 43, 17)

	; 12) anzahl fehler
	$aReal[10] = _GUICtrlCreateLabel("", 28 + $xw * 2, 46, 155, 17)

	; 10) speed in bytes/s
	$aReal[11] = _GUICtrlCreateLabel("", 8 + $xw * 3, 46, 199, 17)

	; 11) current dir\n\r current file->wichtig!
	$aReal[12] = _GUICtrlCreateLabel("", 28, 154, 740, 33)

	Local $iX = 16, $iY = 12
	Local $Tab = GUICtrlCreateTab(16, 16, 770, 209, $TCS_FLATBUTTONS)

	; init arrays, tabs und buttons
	For $i = 1 To $aBackupTodo[0][0]

		; noch ein Tab...
		$aGid[$i][0] = GUICtrlCreateTabItem($aBackupTodo[$i][4])

		; Buttons für Tab
		Local $iStyle = BitOR(0, 0)
		Local $iStyle2 = BitOR(0, 0)
		$aButtons[$i][0] = GUICtrlCreateButton(Msg($mButtons[13]), 28, 190, 131, 25, $iStyle, $iStyle2)
		$aButtons[$i][1] = GUICtrlCreateButton(Msg($mButtons[15]), 164, 190, 131, 25, $iStyle, $iStyle2)
		$aButtons[$i][2] = GUICtrlCreateButton(Msg($mButtons[16]), 300, 190, 131, 25, $iStyle, $iStyle2)

		For $j = 1 To 13
			; außerhalb und verstecken, hier kommen die werte von 7zip an:
			$aGid[$i][$j] = GUICtrlCreateLabel("", -10, -10, 1, 1)
			$aHwnd[$i][$j] = GUICtrlGetHandle($aGid[$i][$j])
			GUICtrlSetState($aGid[$i][$j], $GUI_HIDE)

			; damit prüfen wir, ob sich werte geändert haben...
			$aLast[$i][$j] = "" ; Last value
		Next

		; muß HH:MM:SS Format haben!
		GUICtrlSetData($aGid[$i][2], "00:00:00")
	Next

	GUICtrlCreateTabItem("") ; tab end
	GUICtrlCreateGroup("", -99, -99, 1, 1) ; group end
	_GUICtrlTab_ActivateTab($Tab, 0)

	; overview progress
	GUICtrlCreateGroup(Msg($mLabels[40]), 312, 240, 481, 153, -1, $WS_EX_TRANSPARENT)
	Local $btnCancel = GUICtrlCreateButton(Msg($mButtons[2]), 688, 360, 99, 25)
	Local $btnToTray = GUICtrlCreateButton(Msg($mButtons[11]), 584, 360, 99, 25)

	; Gesamt, Verstrichene Zeit 00:00:33
	$aReal[13] = _GUICtrlCreateLabel("", 321, 264, 180, 17)

	; Gesamt, Verbleibene Zeit 00:00:33
	$aReal[17] = _GUICtrlCreateLabel("", 321, 360 + 4, 180, 17)

	; Gesamt, speed in bytes/s
	$aReal[14] = _GUICtrlCreateLabel("", 8 + $xw * 3, 264, 199, 17)

	; Gesamt, Verarbeitet: 10 MB / 100 MB  Gepackte Größe: 1 MB (10%)
	$aReal[15] = GUICtrlCreateProgress(321, 321, 464, 27)
	$aReal[16] = _GUICtrlCreateLabel("", 321, 300, 464, 17)

	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW, $hGUI)
	Local $iColor = _GetTabColor($Tab)
	GUICtrlSetBkColor($aReal[3], Dec($iColor))
	; ARGB for FFLabels
	$iColor = "0xff" & $iColor

	; gui created, now start 7zip...
	Local $aSevenZip = StartSevenZip($id, $aBackupTodo, $aDrivesWithVSS, $aHwnd)
	Local $iActiveTab = 1
	Local $iNeedRedraw = 0
	Local $tsLastOne = 0

	; Default Tab is First one...
	_GUICtrlTab_ActivateTab($Tab, 0)

	; große status loop
	While 1
		; check, if some pid has finished...
		Local $iFound = 0
		For $i = 1 To $aSevenZip[0][0]
			If $aSevenZip[$i][0] = 0 Then ContinueLoop
			If Not ProcessExists($aSevenZip[$i][0]) Then
				; ist zwar schon weg, aber da sind sicher noch angefangene archive und sowas...
				StopSevenZipProcess($aBackupTodo, $aSevenZip, $i)
				GUICtrlSetData($aGid[$i][3], "7z:cancel")
				$iNeedRedraw = 1
				ContinueLoop
			EndIf
			$iFound += 1
		Next

		; wenn alle pid's weg sind, ist das backup fertig...
		If $iFound = 0 Then ExitLoop

		; check the values and set $aLast[$i][xx] to the current value
		; - when $iNeedRedraw is set to 1, we will redraw the current tab values
		For $i = 1 To $aBackupTodo[0][0]
			Local $v

			; 3) status: scanning/compressing/finished
			; $aSevenZip[$i][0] -> pid
			; $aSevenZip[$i][1] -> hwnd
			; $aSevenZip[$i][2] -> title
			; $aSevenZip[$i][3] -> status -> cancel/okay
			$v = GUICtrlRead($aGid[$i][3])

			; check for finished 7zip
			If $v = "7z:end" And ProcessExists($aSevenZip[$i][0]) Then
				; remaining time is zero now
				$aLast[$i][2] = "00:00:00"
				GUICtrlSetData($aGid[$i][2], $aLast[$i][2])

				; processed size = total size
				$aLast[$i][5] = GUICtrlRead($aGid[$i][4])
				GUICtrlSetData($aGid[$i][5], $aLast[$i][5])

				; processed files = total files
				$aLast[$i][8] = GUICtrlRead($aGid[$i][7])
				GUICtrlSetData($aGid[$i][8], $aLast[$i][8])

				; reset speed
				$aLast[$i][10] = 0
				GUICtrlSetData($aGid[$i][10], $aLast[$i][10])

				; reset current file
				$aLast[$i][11] = ""
				GUICtrlSetData($aGid[$i][11], $aLast[$i][11])

				If $v = "7z:end" And ProcessExists($aSevenZip[$i][0]) Then
					; click the "7z:close" button, until the 7zip pid is away...
					While 1
						ClickSevenZip($aSevenZip[$i][1], "Button3")
						Sleep(200)
						If Not ProcessExists($aSevenZip[$i][0]) Then ExitLoop
					WEnd
					FinishSevenZip($id, $aBackupTodo, $aSevenZip, $i)
				EndIf

				GUICtrlSetState($aButtons[$i][0], $GUI_DISABLE)
				GUICtrlSetState($aButtons[$i][1], $GUI_DISABLE)
				GUICtrlSetState($aButtons[$i][2], $GUI_DISABLE)

				$aLast[$i][3] = $v
				$iNeedRedraw = 1
				CreateNewBackup_SetStatus($aReal[3], $aLast[$iActiveTab][3])
			EndIf

			; update status
			If $aLast[$i][3] <> $v Then
				CreateNewBackup_SetStatus($aReal[3], $aLast[$iActiveTab][3])
				$iNeedRedraw = 1
			EndIf

			For $j = 1 To 12
				$v = GUICtrlRead($aGid[$i][$j])
				If Not ($v = $aLast[$i][$j]) Then
					$aLast[$i][$j] = $v
					If $iActiveTab = $i Then $iNeedRedraw = 1
				EndIf
			Next

			; 13 -> warnungen abspeichern... sofern gesetzt
			$v = GUICtrlRead($aGid[$i][13])
			If Not ($v = $aLast[$i][13]) Then
				$aLast[$i][$j] = $v
				Local $sErrorLog
				;_PrintFromArray($aBackupTodo)
				If $aBackupTodo[$i][0] = "a" Then
					Local $s = StringTrimRight($aBackupTodo[$i][5], 3) ; .7z beim archiv.7z weg machen
					$sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
				Else
					Local $s = StringTrimRight($aBackupTodo[$i][6], 3) ; .7z bei update.7z weg machen
					$sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
				EndIf
				DirCreate(DirName($sErrorLog))
				FileDelete($sErrorLog)
				FileWrite($sErrorLog, GUICtrlRead($aGid[$i][13]))
			EndIf
		Next

		; check, if we need to repaint sth.
		If $iNeedRedraw = 1 Then
			Local $i = $iActiveTab
			Local $v
			Local $iTotal, $iProcessed, $iPacked, $iPercent, $iRatio, $iSpeed

			; 1) elapsed time 00:00:33
			_GUICtrlSetData($aReal[1], Msg($mLabels[53], $aLast[$i][1]), $iColor)

			; 2) remaining time 00:00:33
			If $aLast[$i][2] = "00:00:00" Then
				; keine Restzeit mehr da... also nix anzeigen
				_GUICtrlSetData($aReal[2], "", $iColor)
			Else
				_GUICtrlSetData($aReal[2], Msg($mLabels[54], $aLast[$i][2]), $iColor)
			EndIf

			$iTotal = $aLast[$i][4]
			$iProcessed = $aLast[$i][5]
			$iPacked = $aLast[$i][6]
			$iPercent = $iTotal <> 0 ? Int(($iProcessed * 100) / $iTotal) : 0
			$iRatio = $iPacked <> 0 ? Int(($iPacked * 100) / $iProcessed) : 0
			If $iPacked = 0 Then
				_GUICtrlSetData($aReal[4], Msg($mLabels[55]) & " " & _WinAPI_StrFormatByteSize($iProcessed) & " / " & _WinAPI_StrFormatByteSize($iTotal), $iColor)
			Else
				_GUICtrlSetData($aReal[4], Msg($mLabels[55]) & " " & _WinAPI_StrFormatByteSize($iProcessed) & " / " & _WinAPI_StrFormatByteSize($iTotal) & "   " & Msg($mLabels[56], _WinAPI_StrFormatByteSize($iPacked)) & " (" & $iRatio & "%)", $iColor)
			EndIf
			GUICtrlSetData($aReal[5], $iPercent)
			_GUICtrlSetData($aReal[6], $iPercent & "%", $iColor)

			; 8) files, processed
			$iTotal = $aLast[$i][7]
			$iProcessed = $aLast[$i][8]
			$iPercent = $iTotal <> 0 ? Int(($iProcessed * 100) / $iTotal) : 0
			_GUICtrlSetData($aReal[7], Msg($mLabels[57]) & " " & $iProcessed & " / " & $iTotal, $iColor)
			GUICtrlSetData($aReal[8], $iPercent)
			_GUICtrlSetData($aReal[9], $iPercent & "%", $iColor)

			; 10) speed in bytes/s
			If $aLast[$i][10] = 0 Then
				_GUICtrlSetData($aReal[11], "", $iColor)
			Else
				_GUICtrlSetData($aReal[11], Msg($mLabels[58]) & " " & _WinAPI_StrFormatByteSize($aLast[$i][10]) & "/s", $iColor)
			EndIf

			; 11) current dir\n\r current file
			_GUICtrlSetData($aReal[12], $aLast[$i][11], $iColor)

			; 12) anzahl fehler
			If $aLast[$i][12] = 0 Then
				_GUICtrlSetData($aReal[10], "", $iColor)
			Else
				_GUICtrlSetData($aReal[10], Msg($mLabels[59]) & " " & $aLast[$i][12], $iColor)
			EndIf

			$iNeedRedraw = 0
		EndIf

		; Gesamtwerte, 1x je Sekunde:
		Local $tsCurrent = GetTimeStamp()
		If $tsCurrent <> $tsLastOne Then
			$tsLastOne = $tsCurrent
			Local $iTotal = 0
			Local $iProcessed = 0
			Local $iPacked = 0
			Local $iSpeed = 0
			Local $iCurrentRemainingTime = 0
			For $j = 1 To $aBackupTodo[0][0]
				$iTotal += $aLast[$j][4]
				$iProcessed += $aLast[$j][5]
				$iPacked += $aLast[$j][6]
				$iSpeed += $aLast[$j][10]
				; ConsoleWrite(" $aLast[" & $j & "][2] = " & $aLast[$j][2] & @CRLF)
				$iCurrentRemainingTime = _Max($iCurrentRemainingTime, GetSeconds($aLast[$j][2]))
			Next
			$iPercent = $iTotal <> 0 ? Int(($iProcessed * 100) / $iTotal) : 0
			$iRatio = $iPacked <> 0 ? Int(($iPacked * 100) / $iProcessed) : 0

			_GUICtrlSetData($aReal[13], Msg($mLabels[53], GetTimeElapsed($tsCurrent - $tsBegin)))
			_GUICtrlSetData($aReal[17], Msg($mLabels[54], GetTimeElapsed($iCurrentRemainingTime)))
			_GUICtrlSetData($aReal[14], Msg($mLabels[58]) & " " & _WinAPI_StrFormatByteSize($iSpeed) & "/s")
			GUICtrlSetData($aReal[15], $iPercent)
			If $iPacked = 0 Then
				_GUICtrlSetData($aReal[16], Msg($mLabels[55]) & " " & _WinAPI_StrFormatByteSize($iProcessed) & " / " & _WinAPI_StrFormatByteSize($iTotal))
			Else
				_GUICtrlSetData($aReal[16], Msg($mLabels[55]) & " " & _WinAPI_StrFormatByteSize($iProcessed) & " / " & _WinAPI_StrFormatByteSize($iTotal) & "   " & Msg($mLabels[56], _WinAPI_StrFormatByteSize($iPacked)) & " (" & $iRatio & "%)")
			EndIf

			DrawSpaceUsageStatus($sDrive, $iPacked)
			TraySetToolTip(Msg($mLabels[60], $sTitle, GetBackupTime($iCurrentRemainingTime)))
		EndIf

		; GUI Nachrichten
		Local $msg = GUIGetMsg()
		Switch $msg
			Case 0, $GUI_EVENT_MOUSEMOVE
				; ignore

			Case $Tab
				$iActiveTab = GUICtrlRead($Tab) + 1
				CreateNewBackup_SetStatus($aReal[3], $aLast[$iActiveTab][3])
				$iNeedRedraw = 1

			Case $btnCancel
				If MsgBox($MB_YESNO, $sTitle, Msg($mMessages[8])) = $IDYES Then
					StopSevenZip($aBackupTodo, $aSevenZip, $aDrivesWithVSS)
					ExitLoop ; abbruch vom backup
				EndIf

			Case $btnToTray, $GUI_EVENT_CLOSE
				$iRunningBackup = $hGUI
				EnableTrayMenu()
				GUISetState(@SW_HIDE, $hGUI)

			Case $aButtons[$iActiveTab][0]
				; 7-zip anzeigen / verstecken
				Local $i = $iActiveTab
				If $aSevenZip[$i][0] = 0 Then ContinueLoop
				Local $iState = WinGetState($aSevenZip[$i][1])
				If BitAND($iState, 2) Then
					WinSetState($aSevenZip[$i][1], "", @SW_HIDE)
					GUICtrlSetData($aButtons[$i][0], Msg($mButtons[13]))
				Else
					WinSetState($aSevenZip[$i][1], "", @SW_SHOW)
					GUICtrlSetData($aButtons[$i][0], Msg($mButtons[17]))
				EndIf

			Case $aButtons[$iActiveTab][1]
				; Pausieren / Fortsetzen
				Local $i = $iActiveTab
				If $aSevenZip[$i][0] = 0 Then ContinueLoop
				ClickSevenZip($aSevenZip[$i][1], "Button2")
				Local $sButton = ControlGetText($aSevenZip[$i][1], "", "Button2")
				Switch $sButton
					Case "7z:pause"
						$sButton = Msg($mButtons[15])
					Case "7z:continue"
						$sButton = Msg($mButtons[14])
				EndSwitch
				GUICtrlSetData($aButtons[$i][1], $sButton)

				; set speed to zero, will get new speed via 7-Zip ...
				$aLast[$i][10] = 0
				GUICtrlSetData($aGid[$i][10], $aLast[$i][10])

			Case $aButtons[$iActiveTab][2]
				; Task abbrechen
				Local $i = $iActiveTab
				If $aSevenZip[$i][0] = 0 Then ContinueLoop
				If MsgBox($MB_YESNO, $sTitle, Msg($mMessages[9])) = $IDYES Then
					GUICtrlSetState($aButtons[$i][0], $GUI_DISABLE)
					GUICtrlSetState($aButtons[$i][1], $GUI_DISABLE)
					GUICtrlSetState($aButtons[$i][2], $GUI_DISABLE)
					While ProcessExists($aSevenZip[$i][0])
						ProcessClose($aSevenZip[$i][0])
						Sleep(300)
					WEnd
					ContinueLoop
				EndIf
				;Case Else
				;	ConsoleWrite(" msg=" & $msg & @CRLF)
		EndSwitch

		; Tray Nachrichten
		Switch TrayGetMsg()
			Case $iExit
				If MsgBox($MB_YESNO, $sTitle, Msg($mMessages[8])) = $IDYES Then
					StopSevenZip($aBackupTodo, $aSevenZip, $aDrivesWithVSS)
					ExitLoop ; abbruch vom backup
				EndIf
			Case $iStatus
				GUISetState(@SW_SHOW, $iRunningBackup)
				$iNeedRedraw = 1
				ContinueLoop
		EndSwitch

		; next while loop...
	WEnd

	; zusätzliche VSS Laufwerke wieder weg... sofern da
	StopVSSDevices($aDrivesWithVSS)

	; standard menü wieder an...
	$iRunningBackup = 0
	EnableTrayMenu()

	GUIDelete($hGUI)

	; Standard PowerPlan wieder herstellen
	If $sUsePowerPlan = "1" Then ResetPowerPlan()

	Local $iOkay = 0, $iCancel = 0
	For $i = 1 To $aSevenZip[0][0]
		If $aSevenZip[$i][3] = "okay" Then $iOkay += 1
		If $aSevenZip[$i][3] = "cancel" Then $iCancel += 1
	Next

	If $sShowStatusMessage = "1" Then
		If $iCancel = 0 Then
			MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), $sTitle, Msg($mMessages[11]))
		ElseIf $iOkay > 0 Then
			MsgBox(BitOR($MB_OK, $MB_ICONWARNING), $sTitle, Msg($mMessages[12]))
		Else
			MsgBox(BitOR($MB_OK, $MB_ICONWARNING), $sTitle, Msg($mMessages[7]))
		EndIf
	Else
		If $iCancel = 0 Then
			TrayTip($sTitle, Msg($mMessages[11]), $iTrayTipTime, $TIP_ICONASTERISK)
		ElseIf $iOkay > 0 Then
			TrayTip($sTitle, Msg($mMessages[12]), $iTrayTipTime, $TIP_ICONASTERISK)
		Else
			TrayTip($sTitle, Msg($mMessages[7]), $iTrayTipTime, $TIP_ICONASTERISK)
		EndIf
	EndIf
	TraySetToolTip($sTitle)

	; delete tmp index
	FileDeleteSave($id)

	; am ende noch ein sync... manche ziehen den stick einfach raus ... ;)
	RunWait(@ComSpec & " /c sync.exe", "", @SW_HIDE)
	If $sRunAfterCmd <> "" Then RunWait($sRunAfterCmd)

	; die vscsc.exe, 7zg-mini.exe, 7z.dll und sync.exe usw... bleiben erstmal liegen, QuitBackup() räumt die weg...
	Return
EndFunc   ;==>CreateNewBackup

; #FUNCTION# ====================================================================================================================
; Name ..........: CreateVSSDevices
; Description ...: erstellt VSS Drives
; Syntax ........: CreateVSSDevices($id, $aBackupTodo)
;	returns array with vss devices
; Author ........: Tino Reichardt
; Modified ......: 24.01.2015
; ===============================================================================================================================
Func CreateVSSDevices($id, $aBackupTodo, $iStatusLabel, $sStatusText)
	Local $sIndexTemp = GetTempIndex($id)

	; 1) wechseln zum TempDir von USB-Backup
	FileChangeDir($sTempPath)

	; 2) erstmal ein sync, dann erstellen der schattenkopien
	RunWait(@ComSpec & " /c sync.exe", "", @SW_HIDE)
	_GUICtrlSetData($iStatusLabel, $sStatusText)

	; erstellt uns sync.exe, das passende vss tool usw...
	DoBackup_PrepareExefiles($sTempPath)

	; 3a) erstellen der VSS Laufwerke
	Dim $aTheDrives[1]
	For $i = 1 To $aBackupTodo[0][0]
		; skip networking paths
		If StringLeft($aBackupTodo[$i][4], 2) = "\\" Then ContinueLoop
		If StringMid($aBackupTodo[$i][4], 2, 2) <> ":\" Then ContinueLoop
		_ArrayAdd($aTheDrives, StringLeft($aBackupTodo[$i][4], 2))
	Next
	$aTheDrives[0] = UBound($aTheDrives) - 1

	; 3b) freie Laufwerke für VSS finden
	Local $aDrivesWithVSS = FindVSSDrivesForBackup($aTheDrives)
	If Not IsArray($aDrivesWithVSS) Then
		MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[11]))
		Return 0
	EndIf

	; nix vss da, return the dummy
	If $aDrivesWithVSS[0][0] = 0 Then Return $aDrivesWithVSS

	; 3c) wenn doch, brauchen wir nun noch eine spalte mehr für das hwnd
	; $aDrivesWithVSS[$i] [0][0]=counter
	; [i][0] = C: (quelle)
	; [i][1] = A: (VSS lw)
	; [i][2] = pid für die cmd.exe
	; [i][3] = hwnd für das fenster...
	_ArrayColInsert($aDrivesWithVSS, 2)
	_ArrayColInsert($aDrivesWithVSS, 2)

	For $i = 1 To $aDrivesWithVSS[0][0]
		Local $sDrive = StringLeft($aDrivesWithVSS[$i][0], 1)
		Local $sTitleOK = "VSS-IS-READY-FOR-" & $sDrive & "-"
		Local $sTitleERR = "VSS-HAS-ERROR-FOR-" & $sDrive
		Local $sRandom = _WinAPI_CreateGUID()
		Local $sText = ""
		Local $sTempDrive, $sTempDir
		_PathSplit($sTempPath, $sTempDrive, $sTempDir, $sText, $sText)
		;ConsoleWrite(" $sDir=" & $sDir & " $sFileName=" & $sFileName & @CRLF)
		$sText = "@echo off" & @CRLF & @CRLF
		$sText &= 'rem 1) wenn ohne paramater aufgerufen, dann vscsc starten' & @CRLF
		$sText &= 'rem 2) wenn mit parameter gestartet, dann okay title setzen' & @CRLF
		$sText &= $sTempDrive & @CRLF
		$sText &= 'cd "' & $sTempDir & '"' & @CRLF
		$sText &= 'if "%1" == "" goto vscsc' & @CRLF
		$sText &= 'goto okay' & @CRLF & @CRLF
		$sText &= ':vscsc' & @CRLF
		$sText &= 'vscsc.exe -exec=%0 ' & $sDrive & ':' & @CRLF
		$sText &= 'if not %errorlevel% == 0 goto error' & @CRLF
		$sText &= 'goto end' & @CRLF & @CRLF
		$sText &= ':okay' & @CRLF
		$sText &= 'title ' & $sTitleOK & "%1" & @CRLF
		$sText &= ':wait' & @CRLF
		$sText &= 'ping -n 2 127.0.0.1 > NUL' & @CRLF
		$sText &= 'if not exist %0.finished goto wait' & @CRLF
		$sText &= 'goto end' & @CRLF & @CRLF
		$sText &= ':error' & @CRLF
		$sText &= 'title ' & $sTitleERR & @CRLF
		$sText &= ':wait2' & @CRLF
		$sText &= 'ping -n 2 127.0.0.1 > NUL' & @CRLF
		$sText &= 'if not exist %0.finished goto wait2' & @CRLF
		$sText &= ':end' & @CRLF

		$sStatusText &= @CRLF & Msg($mLabels[61], $aDrivesWithVSS[$i][0]) & " "
		_GUICtrlSetData($iStatusLabel, $sStatusText)

		Local $sFile = $sTempPath & "vscsc-" & $sDrive & ".cmd"
		FileDelete($sFile)
		FileWrite($sFile, $sText)

		Local $iShowFlag = $sDebugVSCSCCmd <> 0 ? @SW_SHOW : @SW_HIDE
		Local $sAdminUser = IniRead($sIndexTemp, $sAppName, "AdminUser", "")
		Local $sAdminPass = IniRead($sIndexTemp, $sAppName, "AdminPass", "")
		Local $sShadow = "" ; sieht dann so aus: "\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy2"

		While 1
			If $sAdminUser = "" Then
				$sAdminUser = MyInputBox($sTitle, "usage-VSSAdmin.html", Msg($mLabels[62]), "Administrator")
				If $sAdminUser = "" Then
					MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[12]))
					Return 0
				EndIf
				$sAdminPass = MyInputBox($sTitle, "usage-VSSAdmin.html", Msg($mLabels[63], $sAdminUser), "", $ES_PASSWORD)
			EndIf

			;$aDrivesWithVSS[$i][2] = RunAs($sAdminUser, @ComputerName, $sAdminPass, 0, @ComSpec & " /c " & $sFile, $sTempPath, $iShowFlag)
			$aDrivesWithVSS[$i][2] = RunAs($sAdminUser, @ComputerName, $sAdminPass, 0, $sFile, $sTempPath, $iShowFlag)
			If $aDrivesWithVSS[$i][2] = 0 Then
				MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[13]))
				$sAdminUser = ""
				ContinueLoop ; nochmal neu eingeben...
			EndIf

			; wenn bis hier gekommen, nutzer+pass okay, aber vscsc?
			Local $iStatusChar = 1
			While ProcessExists($aDrivesWithVSS[$i][2])
				; Some more text from cmd.exe VSS-IS-READY-FOR-C-\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy2
				Local $sFullTitle1 = WinGetTitle("[REGEXPTITLE:" & $sTitleOK & "\\]")
				Local $iStart1 = StringInStr($sFullTitle1, $sTitleOK)
				Local $sFullTitle2 = WinGetTitle("[REGEXPTITLE:" & $sTitleERR & "]")
				Local $iStart2 = StringInStr($sFullTitle2, $sTitleERR)

				; wenn noch nicht entschieden...
				If $iStart1 = 0 And $iStart2 = 0 Then
					Local $iStatusTextChar
					Sleep(Random(50, 150))
					Switch $iStatusChar
						Case 1
							$iStatusTextChar = "|"
							$iStatusChar += 1
						Case 2
							$iStatusTextChar = "/"
							$iStatusChar += 1
						Case 3
							$iStatusTextChar = "-"
							$iStatusChar += 1
						Case 4
							$iStatusTextChar = "\"
							$iStatusChar = 1
					EndSwitch

					_GUICtrlSetData($iStatusLabel, $sStatusText & $iStatusTextChar)
					ContinueLoop
				EndIf

				; wenn error
				If $iStart2 <> 0 Then
					FileWrite($sFile & ".finished", "...")
					$sShadow = ""
					ExitLoop
				EndIf

				;ConsoleWrite("full=" & $sFullTitle1 & " shadow=" & $sShadow & " istart1=" & $iStart1 & @CRLF)
				$sShadow = StringMid($sFullTitle1, $iStart1 + StringLen($sTitleOK))
				$aDrivesWithVSS[$i][3] = WinGetHandle("[REGEXPTITLE:" & $sTitleOK & "\\]")
				ExitLoop
			WEnd

			If $sShadow = "" Then
				MsgBox($MB_OK, $sTitle, Msg($mErrorMessages[14], $sDrive))
				$sAdminUser = ""
				ContinueLoop ; user erneut auffordern
			EndIf

			; alles gut, raus aus der loop
			ExitLoop
		WEnd

		; wenn bis hier gekommen, nutzer+pass und vscsc sind okay
		; -> speichern von user+pass, somit geht das hier nächstes mal ohne eingabe...
		IniWrite($sIndexTemp, $sAppName, "AdminUser", $sAdminUser)
		IniWrite($sIndexTemp, $sAppName, "AdminPass", $sAdminPass)
		UpdateIndexFile($id)

		; mapping shadow path to dos drive ... should not fail!
		If _WinAPI_DefineDosDevice($aDrivesWithVSS[$i][1], 0, $sShadow) <> True Then
			FatalError(Msg($mFatalErrors[6], $sShadow, $aDrivesWithVSS[$i][1]))
		EndIf

		; wait for device to be ready...
		Sleep(1000)
	Next

	Return $aDrivesWithVSS
EndFunc   ;==>CreateVSSDevices

; #FUNCTION# ====================================================================================================================
; Name ..........: StopVSSDevices
; Description ...: entfernt VSS Drives
; Syntax ........: StopVSSDevices($aDrivesWithVSS)
; Author ........: Tino Reichardt
; Modified ......: 01.02.2015
; ===============================================================================================================================
Func StopVSSDevices($aDrivesWithVSS)
	If Not IsArray($aDrivesWithVSS) Then Return
	; $aDrivesWithVSS[0][0] -> Counter
	; $aDrivesWithVSS[$i][0] -> RealDrive
	; $aDrivesWithVSS[$i][1] -> ShadowDrive
	; $aDrivesWithVSS[$i][2] -> Pid
	; $aDrivesWithVSS[$i][3] -> Handle
	For $i = 1 To $aDrivesWithVSS[0][0]
		; delete mapped dos device
		_WinAPI_DefineDosDevice($aDrivesWithVSS[$i][1], $DDD_REMOVE_DEFINITION)
		; C:\Users\nutzer\AppData\Local\Temp\USB-Backup-{DC4C0BAD-0F8A-4F59-A442-C16A881F34E4}\vscsc-C.cmd.finish
		Local $sEndFile = $sTempPath & "vscsc-" & StringLeft($aDrivesWithVSS[$i][0], 1) & ".cmd.finished"
		While ProcessExists($aDrivesWithVSS[$i][2])
			FileWrite($sEndFile, "nö")
			Sleep(500)
		WEnd
		FileDelete($sEndFile)
	Next
EndFunc   ;==>StopVSSDevices

; #FUNCTION# ====================================================================================================================
; Name ..........: ClickSevenZip
; Description ...: bei einem SevenZipFenster was anklickern
; Syntax ........: ClickSevenZip($aSevenZip, Button)
; Author ........: Tino Reichardt
; Modified ......: 09.08.2015
; ===============================================================================================================================
Func ClickSevenZip($hWindow, $btn)
	; $aZip[$i][0] -> pid
	; $aZip[$i][1] -> hwnd
	Local $lParam
	Switch $btn
		Case "Button1"
			$lParam = 444
		Case "Button2"
			$lParam = 446
		Case "Button3"
			$lParam = 2
	EndSwitch
	; _WinAPI_PostMessage ( $hWnd, $iMsg, $wParam, $lParam )
	; _WinAPI_SendMessageTimeout ( $hWnd, $iMsg [, $wParam = 0 [, $lParam = 0 [, $iTimeout = 1000 [, $iFlags = 0]]]] )
	; ConsoleWrite("_WinAPI_SendMessageTimeout(" & $hWindow & ", " & 0x111 & ", " & $lParam & ", " & "0) = @error=" & @error & @CRLF)
	_WinAPI_PostMessage($hWindow, 0x111, $lParam, 0)
	; ConsoleWrite("_WinAPI_PostMessage(" & $hWindow & ", " & 0x111 & ", " & $lParam & ", " & "0)" & @CRLF)
EndFunc   ;==>ClickSevenZip

; #FUNCTION# ====================================================================================================================
; Name ..........: StartSevenZip
; Description ...: Sicherung mit SevenZip starten
; Syntax ........: StartSevenZip($aDrivesWithVSS)
; Author ........: Tino Reichardt
; Modified ......: 01.02.2015
; ===============================================================================================================================
Func StartSevenZip($id, $aBackupTodo, $aDrivesWithVSS, $aHwnd)
	Local $sPassword = $aCurrentSticks[$id][$ePassword]

	#cs
		incoming:
		$aBackupTodo
		[0] 3|3|0|0|0|0|0
		[1] a|20|f1427934699|1427934699|C:\1|H:\USB-Backup\nutzer@VBOX\b6274132c1bf965a\380534efa3092667\380534efa3092667.7z|
		[2] a|26|f1427934699|1427934699|C:\Dokumente und Einstellungen\nutzer\Desktop\totalcmd|H:\USB-Backup\nutzer@VBOX\51b08fa54405b59b\c4f166850c452ebd\c4f166850c452ebd.7z|
		[3] a|32|f1427934699|1427934699|Z:\autoit\7z938_milky|H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\ea8163f91f44785e\ea8163f91f44785e.7z|

		$aBackupTodo
		[0] 3|0|3|0|0|0|0
		[1] u|25|f1427933305|1427934772|C:\1|H:\USB-Backup\nutzer@VBOX\b6274132c1bf965a\e68b813c5998001e\e68b813c5998001e.7z|H:\USB-Backup\nutzer@VBOX\b6274132c1bf965a\e68b813c5998001e\0a1720e91d8f3b07.7z
		[2] u|32|f1427934699|1427934772|C:\Dokumente und Einstellungen\nutzer\Desktop\totalcmd|H:\USB-Backup\nutzer@VBOX\51b08fa54405b59b\c4f166850c452ebd\c4f166850c452ebd.7z|H:\USB-Backup\nutzer@VBOX\51b08fa54405b59b\c4f166850c452ebd\63971aa6c301dcc1.7z
		[3] u|39|f1427934699|1427934772|Z:\autoit\7z938_milky|H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\ea8163f91f44785e\ea8163f91f44785e.7z|H:\USB-Backup\nutzer@VBOX\17600f8e8537beba\ea8163f91f44785e\8d333a5c84e4cc49.7z

		ConsoleWrite("$aBackupTodo" & @CRLF)
		_PrintFromArray($aBackupTodo)
		ConsoleWrite("$aDrivesWithVSS" & @CRLF)
		_PrintFromArray($aDrivesWithVSS)
		ConsoleWrite("$aHwnd" & @CRLF)
		_PrintFromArray($aHwnd)
	#ce

	; [pid][hwnd][title][status]
	Dim $aSevenZip[$aBackupTodo[0][0] + 1][4]
	$aSevenZip[0][0] = $aBackupTodo[0][0]

	For $i = 1 To $aBackupTodo[0][0]
		Local $sZipTitle = "SevenZIP-" & _WinAPI_CreateGUID()
		Local $sSevenZipCmd = ""
		Local $sKey = $aBackupTodo[$i][2] ; new fTS key for ini file
		Local $sPath = $aBackupTodo[$i][4]
		Local $sArchiv = $aBackupTodo[$i][5] ; archiv
		Local $sPathReal = $sPath
		Local $sOptions = ' -title"' & $sZipTitle & '"'

		; no backup of our own tmoporary data!
		$sOptions &= ' -xr!"*\USB-Backup-*" '

		; -x@file Option, wenn gewünscht
		Local $sPathPrefix = DirName($sPath)
		Local $sExcludeFile = GetExcludeFile_X($sAppPath, $sPath)
		If FileExists($sExcludeFile) Then
			Local $sText = FileReadToArray($sExcludeFile)
			Local $aExcludeFile[0] ; Array für die neue Datei
			For $j = 0 To UBound($sText) - 1
				; leere zeile
				If StringLen($sText[$j]) = 0 Then ContinueLoop
				; Kommentar
				If StringLeft($sText[$j], 1) = "#" Then ContinueLoop
				; [Junctions] -> alle Junctions im Pfad raus filtern ... 7-Zip mag die nicht! ;)
				If (StringLen($sText[$j]) = 11) And ($sText[$j] = "[Junctions]") Then
					Local $sJunctions = ""
					FindJunctions($sPath, $sJunctions)
					If StringLen($sJunctions) = 0 Then ContinueLoop
					$sJunctions = StringTrimRight($sJunctions, 1) ; am ende ist immer ein "|"
					_ArrayAdd($aExcludeFile, $sJunctions)
					ContinueLoop
				EndIf
				_ArrayAdd($aExcludeFile, $sText[$j])
			Next
			$sExcludeFile = GetExcludeFile_X($sTempPath, $sPath)
			FileDelete($sExcludeFile)
			For $j = 0 To UBound($aExcludeFile) - 1
				; 7-Zip will alle Pfade relativ!
				FileWriteLine($sExcludeFile, StringReplace($aExcludeFile[$j], $sPathPrefix, "", 1))
			Next
			; kann ja sein, das nur kommentare drin sind und die tempfile deshalb nicht erstellt wurde
			If FileExists($sExcludeFile) Then
				$sOptions &= ' -x@"' & $sExcludeFile & '"'
			EndIf
		EndIf

		; -xr@file Option, wenn gewünscht
		$sExcludeFile = GetExcludeFile_XR($sAppPath, $sPath)
		If FileExists($sExcludeFile) Then
			Local $sText = FileReadToArray($sExcludeFile)
			Local $aExcludeFile[0] ; Array für die neue Datei
			For $j = 0 To UBound($sText) - 1
				; leere zeile
				If StringLen($sText[$j]) = 0 Then ContinueLoop
				; Kommentar
				If StringLeft($sText[$j], 1) = "#" Then ContinueLoop
				; [Junctions] -> alle Junctions im Pfad raus filtern ... 7-Zip mag die nicht! ;)
				If (StringLen($sText[$j]) = 11) And ($sText[$j] = "[Junctions]") Then
					Local $sJunctions = ""
					FindJunctions($sPath, $sJunctions)
					If StringLen($sJunctions) = 0 Then ContinueLoop
					$sJunctions = StringTrimRight($sJunctions, 1) ; am ende ist immer ein "|"
					_ArrayAdd($aExcludeFile, $sJunctions)
					ContinueLoop
				EndIf
				_ArrayAdd($aExcludeFile, $sText[$j])
			Next
			$sExcludeFile = GetExcludeFile_XR($sTempPath, $sPath)
			FileDelete($sExcludeFile)
			For $j = 0 To UBound($aExcludeFile) - 1
				; 7-Zip will alle Pfade relativ!
				FileWriteLine($sExcludeFile, StringReplace($aExcludeFile[$j], $sPathPrefix, "", 1))
			Next
			; kann ja sein, das nur kommentare drin sind und die tempfile deshalb nicht erstellt wurde
			If FileExists($sExcludeFile) Then
				$sOptions &= ' -xr@"' & $sExcludeFile & '"'
			EndIf
		EndIf

		; append our hwnd's
		For $j = 1 To 13
			$sOptions &= " -ctl" & $j & "=" & Int($aHwnd[$i][$j])
		Next

		If $sEnableVSS = "1" Then
			For $j = 1 To $aDrivesWithVSS[0][0]
				If StringLeft($sPath, 1) = StringLeft($aDrivesWithVSS[$j][0], 1) Then
					#cs
						$aDrivesWithVSS
						[0] 1|||
						[1] C:|A:|2632|0x001103E6
					#ce
					$sPathReal = StringLeft($aDrivesWithVSS[$j][1], 1)
					$sPathReal &= StringMid($sPath, 2)
				EndIf
			Next
		EndIf

		Local $sSevenZipExe
		If $aBackupTodo[$i][0] = "a" Then
			; a|31|f1422469676|f-timestamp|C:\2|M:\USB-Backup\nutzer@NUTZER-PC\B5712627A269E93C\58D2A66D9FCA2DA6\58D2A66D9FCA2DA6.7z|
			DirCreate(StringMid($sArchiv, 1, StringLen($sArchiv) - $sFileNameLen - 4))
			Local $a = StringSplit($s7ZipCreateCmd, " ")
			$sSevenZipExe = $a[1]

			;%A -> Archiv / %P -> Password / %p = Path / %o = Options
			$sSevenZipCmd = StringReplace($s7ZipCreateCmd, "%A", $sArchiv, 1, $STR_CASESENSE)
			$sSevenZipCmd = StringReplace($sSevenZipCmd, "%o", $sOptions, 1, $STR_CASESENSE)
			$sSevenZipCmd = StringReplace($sSevenZipCmd, "%P", $sPassword, 1, $STR_CASESENSE)
			$sSevenZipCmd = StringReplace($sSevenZipCmd, "%p", $sPathReal, 1, $STR_CASESENSE)
		ElseIf $aBackupTodo[$i][0] = "u" Then
			; u|38|f1422469676|u-timestamp|C:\Users\nutzer\Documents|M:\USB-Backup\nutzer@NUTZER-PC\4384533657DD6CD7\B891BFA1AC055C45\B891BFA1AC055C45.7z|M:\USB-Backup\nutzer@NUTZER-PC\4384533657DD6CD7\B891BFA1AC055C45\58D2A66D9FCA2DA6.7z
			Local $sUpdate = $aBackupTodo[$i][6] ; update archiv
			Local $a = StringSplit($s7ZipUpdateCmd, " ")
			$sSevenZipExe = $a[1]

			;%A -> Archiv / %U -> UpdateFile / %P -> Password / %p = Path / %o = Options
			$sSevenZipCmd = StringReplace($s7ZipUpdateCmd, "%A", $sArchiv, 1, $STR_CASESENSE)
			$sSevenZipCmd = StringReplace($sSevenZipCmd, "%o", $sOptions, 1, $STR_CASESENSE)
			$sSevenZipCmd = StringReplace($sSevenZipCmd, "%U", $sUpdate, 1, $STR_CASESENSE)
			$sSevenZipCmd = StringReplace($sSevenZipCmd, "%P", $sPassword, 1, $STR_CASESENSE)
			$sSevenZipCmd = StringReplace($sSevenZipCmd, "%p", $sPathReal, 1, $STR_CASESENSE)
		EndIf

		; exe und parameter trennen
		Local $sParameter = StringMid($sSevenZipCmd, StringLen($sSevenZipExe) + 1)

		; gleich im hintergrund starten
		Local $iShowFlag = $sDebug7ZipCmd <> 0 ? @SW_SHOW : @SW_HIDE

		; temp:
		; $sSevenZipExe = "z:\autoit\7z938_milky\CPP\7zip\UI\7zg-mini\Release\7zg-mini.exe"
		; $aSevenZip[$i][0] = ShellExecute($sSevenZipExe, $sParameter, $sTempPath, "", $iShowFlag)

		$aSevenZip[$i][0] = ShellExecute($sTempPath & $sSevenZipExe, $sParameter, $sTempPath, "", $iShowFlag)
		If $aSevenZip[$i][0] = -1 Then FatalError(Msg($mFatalErrors[7]))
		While 1
			$aSevenZip[$i][1] = WinWait($sZipTitle, "", 99)
			WinActivate($hGUI)
			If $aSevenZip[$i][1] <> 0 Then ExitLoop
			FatalError(Msg($mFatalErrors[8]))
		WEnd

		; der title kann zum zeigen/verstecken genutzt werden
		$aSevenZip[$i][2] = $sZipTitle

		; default for 7zip is "normal mode" - we want idle mode (mostly)
		If $s7ZipPriority = "idle" Then
			ClickSevenZip($aSevenZip[$i][1], "Button1")
		EndIf

		; größe anpassen, damit der statusbalken auch die pfade korrekt bekommt...
		WinMove($aSevenZip[$i][1], "", -1, -1, $myWidth)
	Next

	;_PrintFromArray($aSevenZip)
	Return $aSevenZip
EndFunc   ;==>StartSevenZip

; #FUNCTION# ====================================================================================================================
; Name ..........: FinishSevenZip
; Description ...: SicherungsTask erfolgreich abschließen und Index+Ini abspeichern...
; Syntax ........: FinishSevenZip($id, $aBackupTodo, $aSevenZip, $iIndex)
; Author ........: Tino Reichardt
; Modified ......: 01.02.2015
; ===============================================================================================================================
Func FinishSevenZip($id, $aBackupTodo, ByRef $aSevenZip, $i)
	Local $sIndexTemp = GetTempIndex($id)
	Local $sKey = $aBackupTodo[$i][2] ; new fTS key for ini file
	Local $sTimeStamp = $aBackupTodo[$i][3] ; new timestamp
	Local $sPath = $aBackupTodo[$i][4] ; path to backup
	Local $sArchiv = $aBackupTodo[$i][5] ; basis archiv
	Local $sRuntime = GetTimeStamp() - $sTimeStamp

	Local $iEncoding = FileGetEncoding($sIndexTemp)
	; XXX
	; ConsoleWrite("FinishSevenZip() $sIndexTemp=" & $sIndexTemp & " $iEncoding=" & $iEncoding & @CRLF)

	If $aBackupTodo[$i][0] = "a" Then
		Local $sBytes = FileGetSize($sArchiv)
		; f1=timestamp:runtime:bytes
		IniWrite($sIndexTemp, $sPath, $sKey, $sTimeStamp & ":" & $sRuntime & ":" & $sBytes)
		; fts=timestamp  -> new full backup timestamp
		IniWrite($sIndexTemp, $sPath, "fts", $sTimeStamp)
	ElseIf $aBackupTodo[$i][0] = "u" Then
		Local $sUpdate = $aBackupTodo[$i][6] ; update archiv
		Local $sBytes = FileGetSize($sUpdate)
		; kompletter alter eintrag ... da hängen wir nun noch was ran
		Local $sOldEntry = IniRead($sIndexTemp, $sPath, $sKey, "")
		IniWrite($sIndexTemp, $sPath, $sKey, $sOldEntry & ";" & $sTimeStamp & ":" & $sRuntime & ":" & $sBytes)
	EndIf
	$aSevenZip[$i][0] = 0
	$aSevenZip[$i][3] = "okay"

	; update TS @ Ini File ... das brauchen wir, damit nach X Tagen dann gemeckert werden kann
	For $i = 1 To $aFilePaths[0]
		If $sPath = $aFilePaths[$i] Then
			$aFilePathsTS[$i] = $sTimeStamp
			WriteConfiguration()
			ExitLoop
		EndIf
	Next

	; ältere Sicherungen inkl. Updates löschen, sofern via MaxFullBackups=X gewünscht...
	If $aBackupTodo[$i][0] = "a" And $sMaxFullBackups <> 0 Then
		Local $aTemp = IniReadSection($sIndexTemp, $sPath)
		Local $iFullBackups = $aTemp[0][0] - 2 ; virtually remove fts=x and cts=x

		;_PrintFromArray($aBackupTodo)
		If $iFullBackups > $sMaxFullBackups Then
			Local $aTodo[0]
			; wir müssen nun checken, was weg kann...
			For $i = 1 To $aTemp[0][0]
				If $aTemp[$i][0] = "cts" Then ContinueLoop
				If $aTemp[$i][0] = "fts" Then ContinueLoop
				If StringLeft($aTemp[$i][0], 1) <> "f" Then FatalError(Msg($mFatalErrors[9]))
				_ArrayAdd($aTodo, StringTrimLeft($aTemp[$i][0], 1))
			Next
			; sortieren, oben sind die neusesten
			_ArraySort($aTodo, 1)
			_ArrayDelete($aTodo, "0-" & $sMaxFullBackups - 1)
			; nun die "alten" durchgehen und entsprechend löschen...
			For $i = 0 To UBound($aTodo) - 1
				; 1) sicherung inkl. updates löschen
				Local $sDir = $aCurrentSticks[$id][$eBackupPath] & MyMiniHash($sPath) & "\" & MyMiniHash($sPath & $aTodo[$i])
				DirRemove($sDir, 1)
				; 2) den registry eintrag löschen
				IniDelete($sIndexTemp, $sPath, "f" & $aTodo[$i])
				; 3) logfiles der sicherung löschen
				$sDir = $sAppPath & "Logfiles\" & MyMiniHash($sPath & $aTodo[$i])
				If FileExists($sDir) Then DirRemove($sDir, 1)
			Next
		EndIf
	EndIf

	; encrypt new temporary index to real one
	UpdateIndexFile($id)
EndFunc   ;==>FinishSevenZip

; #FUNCTION# ====================================================================================================================
; Name ..........: StopSevenZipProcess
; Description ...: Einen 7-Zip Prozess stoppen
; Syntax ........: StopSevenZipProcess($aBackupTodo, $aSevenZip)
; Author ........: Tino Reichardt
; Modified ......: 01.02.2015
; ===============================================================================================================================
Func StopSevenZipProcess($aBackupTodo, ByRef $aSevenZip, $i)
	; pid killen + angefangene datei löschen...
	While ProcessExists($aSevenZip[$i][0])
		; ConsoleWrite("killing " & $aSevenZip[$i][0] & @CRLF)
		ProcessClose($aSevenZip[$i][0])
		Sleep(400)
	WEnd
	$aSevenZip[$i][0] = 0
	$aSevenZip[$i][3] = "cancel"
	If $aBackupTodo[$i][0] = "a" Then
		FileDelete($aBackupTodo[$i][5]) ; archiv
		; falls verzeichnis leer, löschen...
		DirRemove(DirName($aBackupTodo[$i][5]))
	ElseIf $aBackupTodo[$i][0] = "u" Then
		FileDelete($aBackupTodo[$i][6]) ; update
	EndIf
EndFunc   ;==>StopSevenZipProcess

; #FUNCTION# ====================================================================================================================
; Name ..........: StopSevenZip
; Description ...: Sicherung abbrechen bzw. beenden
; Syntax ........: StopSevenZip($aBackupTodo, $aSevenZip, $aDrivesWithVSS)
; Author ........: Tino Reichardt
; Modified ......: 01.02.2015
; ===============================================================================================================================
Func StopSevenZip($aBackupTodo, ByRef $aSevenZip, $aDrivesWithVSS)
	For $i = 1 To $aSevenZip[0][0]
		If $aSevenZip[$i][0] = 0 Then ContinueLoop
		StopSevenZipProcess($aBackupTodo, $aSevenZip, $i)
	Next
	StopVSSDevices($aDrivesWithVSS)
EndFunc   ;==>StopSevenZip

; #FUNCTION# ====================================================================================================================
; Name ..........: GetProcessorInfo
; Description ...: CPU Namen und Anzahl Kerne (logische, inkl. HT) als String ermitteln
; Syntax ........: GetProcessorInfo()
; Author ........: Tino Reichardt
; Modified ......: 01.04.2015
; ===============================================================================================================================
Func GetProcessorInfo()
	Local $sDefault = "Unknown CPU, 1"

	Local $objWMIService = GetWMIServiceObject()
	If $objWMIService = 0 Then Return $sDefault

	Local $colItems = $objWMIService.ExecQuery("SELECT Name,NumberOfLogicalProcessors FROM Win32_Processor")
	If Not IsObj($colItems) Then Return $sDefault

	Local $objItem
	For $objItem In $colItems
		Local $s = StringStripWS($objItem.Name, 1)
		$s = StringReplace($s, ";", "") ; nehmen wir selber als seperator...
		Return $s & "; " & $objItem.NumberOfLogicalProcessors
	Next
EndFunc   ;==>GetProcessorInfo

; #FUNCTION# ====================================================================================================================
; Name ..........: CheckVersions
; Description ...: Zwei Versionen der Form 1.2.3.4 vergleichen
; Syntax ........: CheckVersions(current, internet)
;                  -> return 1: wenn internet version neuer ist
;                  -> return 0: keine neuere version im netz
; Author ........: Tino Reichardt
; Modified ......: 10.03.2015
; ===============================================================================================================================
Func CheckVersions($iCurrent, $iInternet)
	Local $aCurrent = StringSplit($iCurrent, ".")
	Local $aInternet = StringSplit($iInternet, ".")

	; not compiled
	If String($iCurrent) = "0.0.0.0" Then Return 0

	; if equal
	If $iCurrent = $iInternet Then Return 0

	; wenn was nicht passt, dann erstmal kein Update und gut...
	;MsgBox($MB_OK, "versionen", " $iCurrent=" & $iCurrent & "  $iInternet=" & $iInternet)
	If $aCurrent[0] <> 4 Or $aInternet[0] <> 4 Then Return 0
	For $i = 1 To 4
		; 0.0.0.1 > 0.0.0.0
		; 0.0.1.0 > 0.0.0.99
		If Int($aInternet[$i]) = Int($aCurrent[$i]) Then ContinueLoop
		If Int($aInternet[$i]) > Int($aCurrent[$i]) Then
			;MsgBox($MB_OK, "internetversion ist neuer", " $iCurrent=" & $iCurrent & "  $iInternet=" & $iInternet)
			Return 1
		EndIf
		If Int($aInternet[$i]) < Int($aCurrent[$i]) Then
			;MsgBox($MB_OK, "internetversion ist älter", " $iCurrent=" & $iCurrent & "  $iInternet=" & $iInternet)
			Return 0
		EndIf
	Next

	; nix neue version
	Return 0
EndFunc   ;==>CheckVersions

; #FUNCTION# ====================================================================================================================
; Name ..........: CheckForUpdate
; Description ...: auf neue Version im Internet prüfen
; Syntax ........: CheckForUpdate()
; Author ........: Tino Reichardt
; Modified ......: 04.03.2015
; ===============================================================================================================================
Func CheckForUpdate()
	If $sCheckForUpdate = "0" Then Return

	If Ping("mcmilk.de", 300) = 0 Then Return
	; USB-Backup/0.2d (nutzer; NUTZER-PC; 0407; WIN_7; X64; Intel(R) Core(TM) i7-3632QM CPU @ 2.20GHz; 2)
	HttpSetUserAgent($sAppName & "/" & $sUpdateAppVersion & " (" & @UserName & "; " & @ComputerName & "; " & @OSLang & "; " & @OSVersion & "; " & @OSArch & "; " & GetProcessorInfo() & ")")
	Local $sInetVersion = BinaryToString(InetRead($sUpdateURL & "version.txt", 1 + 16))
	If @error <> 0 Then Return

	; ConsoleWrite(" $sInetVersion=" & $sInetVersion & "  @error =" & @error & @CRLF)
	; a[0]=2 a[1]=prog-version a[2]=help-version
	$aInetVersion = StringSplit($sInetVersion, ",")
	If $aInetVersion[0] <> 2 Then Return

	; bei der Hilfe setzen wir nur auf einen Integer, den wir per Hand hochzählen
	$aInetVersion[2] = Int($aInetVersion[2])
	$iHasNewUpdate = 0

	; new USB-Backup.exe Version?
	$iHasNewUpdate += CheckVersions($sUpdateAppVersion, $aInetVersion[1])

	; Es ist ein Update verfügbar, soll es installiert werden ?
	Local $sText
	Switch $iHasNewUpdate
		Case 1
			; application
			$sText = Msg($mMessages[15]) & @CRLF & @CRLF & Msg($mMessages[10])
			If MsgBox($MB_YESNO, $sTitle, $sText) = $IDYES Then DownloadUpdates()
		Case 2
			; help
			$sText = Msg($mMessages[16]) & @CRLF & @CRLF & Msg($mMessages[10])
			If MsgBox($MB_YESNO, $sTitle, $sText) = $IDYES Then DownloadUpdates()
		Case 3
			; application + help
			$sText = Msg($mMessages[17]) & @CRLF & @CRLF & Msg($mMessages[10])
			If MsgBox($MB_YESNO, $sTitle, $sText) = $IDYES Then DownloadUpdates()
	EndSwitch
EndFunc   ;==>CheckForUpdate

; #FUNCTION# ====================================================================================================================
; Name ..........: NewVersionHint
; Description ...: auf neue Version im Internet hinweisen
; Syntax ........: NewVersionHint()
; Author ........: Tino Reichardt
; Modified ......: 19.04.2015
; ===============================================================================================================================
Func NewVersionHint()
	Local $sText = ""
	Switch $iHasNewUpdate
		Case 1
			; application
			$sText = Msg($mMessages[15])
			TrayTip($sAppName & " " & $sVersion, $sText, $iTrayTipTime, $TIP_ICONEXCLAMATION)
		Case 2
			; help
			$sText = Msg($mMessages[16])
			TrayTip($sAppName & " " & $sVersion, $sText, $iTrayTipTime, $TIP_ICONASTERISK)
		Case 3
			; application + help
			$sText = Msg($mMessages[17])
			TrayTip($sAppName & " " & $sVersion, $sText, $iTrayTipTime, $TIP_ICONEXCLAMATION)
	EndSwitch
EndFunc   ;==>NewVersionHint

; #FUNCTION# ====================================================================================================================
; Name ..........: DownloadUpdates
; Description ...: Updates installieren
; Syntax ........: DownloadUpdates()
; Author ........: Tino Reichardt
; Modified ......: 04.03.2015
; ===============================================================================================================================
Func DownloadUpdates()
	Local $sFilePath, $iStatus = 0

	; 1) Programm aktualisieren...
	If BitAND($iHasNewUpdate, 1) Then

		; update herunter laden
		; - früher zwischen 64bit und 32bit unterschieden (_x64 suffix bei 64bit)
		; - seit version 0.5.0.4 gibts nur noch eine exe file!
		$sFilePath = $sTempPath & $sAppName & ".exe"
		FileDelete($sFilePath)
		$iStatus = DownloadFile($sUpdateURL & $sAppName & ".exe", $sFilePath, Msg($mLabels[65]))

		If $iStatus = 0 Then
			; umbenennen der ausgeführten exe (löschen geht ja nicht)
			FileMove(@ScriptFullPath, $sFilePath & ".old", $FC_OVERWRITE)
			; neue exe plazieren
			While 1
				Local $i = FileMove($sFilePath, @ScriptFullPath, $FC_OVERWRITE)
				If $i = 1 Then ExitLoop
				Sleep(100)
			WEnd
			TrayTip($sAppName & " " & $sVersion, Msg($mMessages[19]), $iTrayTipTime, $TIP_ICONASTERISK)
			Sleep(1000)
			; wir gehen da mal sicher:
			; 1) erstellen einer batch
			; 2) diese ausführen, und eigenen prozess beenden
			; 3) batch startet nach 5 sekunden erneut die neue usb-backup.exe
			FileDelete($sTempPath & $sAppName & ".cmd")
			Local $sBatch = "ping -n 5 127.0.0.1 > NUL" & @CRLF
			$sBatch &= 'start /D "' & DirName(@ScriptFullPath) & '" ' & BaseName(@ScriptFullPath)
			FileWrite($sTempPath & $sAppName & ".cmd", $sBatch)
			Run($sTempPath & $sAppName & ".cmd", "", @SW_HIDE)
			; das temp. verzeichnis kann hier mal nicht gelöscht werden, weil die exe noch ausgeführt wird...
			; das wird aber beim erneuten start automatisch bereinigt ;)
			Exit
		EndIf
	EndIf

	If $iStatus <> 0 Then
		TrayTip($sAppName & " " & $sVersion, Msg($mMessages[20]), $iTrayTipTime, $TIP_ICONEXCLAMATION)
		Return
	EndIf

	$iHasNewUpdate = 0
	WriteConfiguration()
EndFunc   ;==>DownloadUpdates

; #FUNCTION# ====================================================================================================================
; Name ..........: DownloadFile
; Description ...: Update herunterladen
; Syntax ........: DownloadFile()
; Author ........: Tino Reichardt
; Modified ......: 04.03.2015
; ===============================================================================================================================
Func DownloadFile($sURL, $sFile, $sInfo)
	Local $aState
	Local $iTotal = InetGetSize($sURL, 1)

	If $iTotal = 0 Then Return 1
	Local $hDownload = InetGet($sURL, $sFile, 1, 1)
	Do
		Sleep(350)
		$aState = InetGetInfo($hDownload)
		Local $iRead = $aState[0]
		Local $sText = Msg($mMessages[13], $sInfo)
		$sText &= @CRLF & @CRLF & Msg($mMessages[14], _WinAPI_StrFormatByteSize($iRead), _WinAPI_StrFormatByteSize($iTotal))
		TrayTip($sAppName & " " & $sVersion, $sText, $iTrayTipTime, $TIP_ICONASTERISK)
	Until $aState[2]

	If @error Then
		FileDelete($sFile)
		Return 1
	EndIf
	InetClose($hDownload)

	Return 0
EndFunc   ;==>DownloadFile
