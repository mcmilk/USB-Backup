#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GuiComboBox.au3>

#include "BinaryCall.au3"
#include "Array.au3"
#include "Lang\USB-Backup_LangFiles.au3"

#cs
	Copyright © 2015 Tino Reichardt

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License Version 2, as
	published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
#ce

Global $mHeadlines, $mTaskTray, $mMessages, $mStatusMessage, _
		$mErrorMessages, $mFatalErrors, $mLabels, $mButtons, _
		$mExcludeComment, $mTaskStatus

; Description of that table, with de-DE as example:
; [0] 0407             -> @OSLANG, Locale identifier
; [1] de-DE            -> "Primary language - Sublanguage"
; [2] German - Deutsch -> "Description -> English Name - Name in that Language" -> Name in that Language contains the Country currently!
; [3] _deDEini         -> Function, which defines IniFile
Local $iLanguageCount = 226
Local $aAllLanguages[$iLanguageCount][4] = [ _
		["0004", "zh-CHS", "Chinese - Simplified"], _
		["0401", "ar-SA", "Arabic - Saudi Arabia"], _
		["0402", "bg-BG", "Bulgarian - Bulgaria"], _
		["0403", "ca-ES", "Catalan - Spain"], _
		["0404", "zh-TW", "Chinese (Traditional) - Taiwan"], _
		["0405", "cs-CZ", "Czech - Czech Republic"], _
		["0406", "da-DK", "Danish - Denmark"], _
		["0407", "de-DE", "Deutsch - Deutsch", _deDEini], _
		["0408", "el-GR", "Greek - Greece"], _
		["0409", "en-US", "English - United States", _enGBini], _
		["040A", "es-ES", "tradnl Spanish - Spain"], _
		["040B", "fi-FI", "Finnish - Finland"], _
		["040C", "fr-FR", "French - France"], _
		["040D", "he-IL", "Hebrew - Israel"], _
		["040E", "hu-HU", "Hungarian - Hungary"], _
		["040F", "is-IS", "Icelandic - Iceland"], _
		["0410", "it-IT", "Italian - Italy"], _
		["0411", "ja-JP", "Japanese - Japan"], _
		["0412", "ko-KR", "Korean - Korea"], _
		["0413", "nl-NL", "Dutch - Netherlands"], _
		["0414", "nb-NO", "Norwegian (Bokmål) - Norway"], _
		["0415", "pl-PL", "Polish - Poland"], _
		["0416", "pt-BR", "Portuguese - Brazil"], _
		["0417", "rm-CH", "Romansh - Switzerland"], _
		["0418", "ro-RO", "Romanian - Romania"], _
		["0419", "ru-RU", "Russian - Russia"], _
		["041A", "hr-HR", "Croatian - Croatia"], _
		["041B", "sk-SK", "Slovak - Slovakia"], _
		["041C", "sq-AL", "Albanian - Albania"], _
		["041D", "sv-SE", "Swedish - Sweden"], _
		["041E", "th-TH", "Thai - Thailand"], _
		["041F", "tr-TR", "Turkish - Turkey"], _
		["0420", "ur-PK", "Urdu - Pakistan"], _
		["0421", "id-ID", "Indonesian - Indonesia"], _
		["0422", "uk-UA", "Ukrainian - Ukraine"], _
		["0423", "be-BY", "Belarusian - Belarus"], _
		["0424", "sl-SI", "Slovenian - Slovenia"], _
		["0425", "et-EE", "Estonian - Estonia"], _
		["0426", "lv-LV", "Latvian - Latvia"], _
		["0427", "lt-LT", "Lithuanian - Lithuanian"], _
		["0428", "tg-Cyrl-TJ", "Tajik (Cyrillic) - Tajikistan"], _
		["0429", "fa-IR", "Persian - Iran"], _
		["042A", "vi-VN", "Vietnamese - Vietnam"], _
		["042B", "hy-AM", "Armenian - Armenia"], _
		["042C", "az-Latn-A", "Azeri (Latin) - Azerbaijan"], _
		["042D", "eu-ES", "Basque - Basque"], _
		["042E", "hsb-DE", "Upper Sorbian - Germany"], _
		["042F", "mk-MK", "Macedonian - Macedonia"], _
		["0432", "tn-ZA", "Setswana / Tswana - South Africa"], _
		["0434", "xh-ZA", "isiXhosa - South Africa"], _
		["0435", "zu-ZA", "isiZulu - South Africa"], _
		["0436", "af-ZA", "Afrikaans - South Africa"], _
		["0437", "ka-GE", "Georgian - Georgia"], _
		["0438", "fo-FO", "Faroese - Faroe Islands"], _
		["0439", "hi-IN", "Hindi - India"], _
		["043A", "mt-MT", "Maltese - Malta"], _
		["043B", "se-NO", "Sami (Northern) - Norway"], _
		["043e", "ms-MY", "Malay - Malaysia"], _
		["043F", "kk-KZ", "Kazakh - Kazakhstan"], _
		["0440", "ky-KG", "Kyrgyz - Kyrgyzstan"], _
		["0441", "sw-KE", "Swahili - Kenya"], _
		["0442", "tk-TM", "Turkmen - Turkmenistan"], _
		["0443", "uz-Latn-UZ", "Uzbek (Latin) - Uzbekistan"], _
		["0444", "tt-RU", "Tatar - Russia"], _
		["0445", "bn-IN", "Bangla - Bangladesh"], _
		["0446", "pa-IN", "Punjabi - India"], _
		["0447", "gu-IN", "Gujarati - India"], _
		["0448", "or-IN", "Oriya - India"], _
		["0449", "ta-IN", "Tamil - India"], _
		["044A", "te-IN", "Telugu - India"], _
		["044B", "kn-IN", "Kannada - India"], _
		["044C", "ml-IN", "Malayalam - India"], _
		["044D", "as-IN", "Assamese - India"], _
		["044E", "mr-IN", "Marathi - India"], _
		["044F", "sa-IN", "Sanskrit - India"], _
		["0450", "mn-MN", "Mongolian (Cyrillic) - Mongolia"], _
		["0451", "bo-CN", "Tibetan - China"], _
		["0452", "cy-GB", "Welsh - United Kingdom"], _
		["0453", "km-KH", "Khmer - Cambodia"], _
		["0454", "lo-LA", "Lao - Lao PDR"], _
		["0456", "gl-ES", "Galician - Spain"], _
		["0457", "kok-IN", "Konkani - India"], _
		["045A", "syr-SY", "Syriac - Syria"], _
		["045B", "si-LK", "Sinhala - Sri Lanka"], _
		["045C", "chr-Cher-US", "Cherokee - Cherokee"], _
		["045D", "iu-Cans-CA", "Inuktitut (Canadian_Syllabics) - Canada"], _
		["045E", "am-ET", "Amharic - Ethiopia"], _
		["0461", "ne-NP", "Nepali - Nepal"], _
		["0462", "fy-NL", "Frisian - Netherlands"], _
		["0463", "ps-AF", "Pashto - Afghanistan"], _
		["0464", "fil-PH", "Filipino - Philippines"], _
		["0465", "dv-MV", "Divehi - Maldives"], _
		["0468", "ha-Latn-NG", "Hausa - Nigeria"], _
		["046A", "yo-NG", "Yoruba - Nigeria"], _
		["046B", "quz-BO", "Quechua - Bolivia"], _
		["046C", "nso-ZA", "Sesotho sa Leboa - South Africa"], _
		["046D", "ba-RU", "Bashkir - Russia"], _
		["046E", "lb-LU", "Luxembourgish - Luxembourg"], _
		["046F", "kl-GL", "Greenlandic - Greenland"], _
		["0470", "ig-NG", "Igbo - Nigeria"], _
		["0473", "ti-ET", "Tigrinya - Ethiopia"], _
		["0475", "haw-US", "Hawiian - United States"], _
		["0478", "ii-CN", "Yi - China"], _
		["047A", "arn-CL", "Mapudungun - Chile"], _
		["047C", "moh-CA", "Mohawk - Canada"], _
		["047E", "br-FR", "Breton - France"], _
		["0480", "ug-CN", "Uyghur - China"], _
		["0481", "mi-NZ", "Maori - New Zealand"], _
		["0482", "oc-FR", "Occitan - France"], _
		["0483", "co-FR", "Corsican - France"], _
		["0484", "gsw-FR", "Alsatian - France"], _
		["0485", "sah-RU", "Sakha - Russia"], _
		["0486", "qut-GT", "K'iche - Guatemala"], _
		["0487", "rw-RW", "Kinyarwanda - Rwanda"], _
		["0488", "wo-SN", "Wolof - Senegal"], _
		["048C", "prs-AF", "Dari - Afghanistan"], _
		["0491", "gd-GB", "Scottish Gaelic - United Kingdom"], _
		["0492", "ku-Arab-IQ", "Central Kurdish - Iraq"], _
		["0801", "ar-IQ", "Arabic - Iraq"], _
		["0803", "ca-ES-valencia", "Valencian - Valencia"], _
		["0804", "zh-CN", "Chinese (Simplified) - China"], _
		["0807", "de-CH", "German - Switzerland"], _
		["0809", "en-GB", "English - United Kingdom", _enGBini], _
		["080A", "es-MX", "Spanish - Mexico"], _
		["080C", "fr-BE", "French - Belgium"], _
		["0810", "it-CH", "Italian - Switzerland"], _
		["0813", "nl-BE", "Dutch - Belgium"], _
		["0814", "nn-NO", "Norwegian (Nynorsk) - Norway"], _
		["0816", "pt-PT", "Portuguese - Portugal"], _
		["081A", "sr-Latn-CS", "Serbian (Latin) - Serbia and Montenegro"], _
		["081D", "sv-FI", "Swedish - Finland"], _
		["0820", "ur-IN", "Urdu - (reserved)"], _
		["082C", "az-Cyrl-AZ", "Azeri (Cyrillic) - Azerbaijan"], _
		["082E", "dsb-DE", "Lower Sorbian - Germany"], _
		["0832", "tn-BW", "Setswana / Tswana - Botswana"], _
		["083B", "se-SE", "Sami (Northern) - Sweden"], _
		["083C", "ga-IE", "Irish - Ireland"], _
		["083E", "ms-BN", "Malay - Brunei Darassalam"], _
		["0843", "uz-Cyrl-UZ", "Uzbek (Cyrillic) - Uzbekistan"], _
		["0845", "bn-BD", "Bangla - Bangladesh"], _
		["0846", "pa-Arab-PK", "Punjabi - Pakistan"], _
		["0849", "ta-LK", "Tamil - Sri Lanka"], _
		["0850", "mn-Mong-CN", "Mongolian (Mong) - Mongolia"], _
		["0859", "sd-Arab-PK", "Sindhi - Pakistan"], _
		["085D", "iu-Latn-CA", "Inuktitut (Latin) - Canada"], _
		["085F", "tzm-Latn-DZ", "Tamazight (Latin) - Algeria"], _
		["0867", "ff-Latn-SN", "Pular - Senegal"], _
		["086B", "quz-EC", "Quechua - Ecuador"], _
		["0873", "ti-ER", "Tigrinya - Eritrea"], _
		["0C01", "ar-EG", "Arabic - Egypt"], _
		["0C04", "zh-HK", "Chinese - Hong Kong SAR"], _
		["0C07", "de-AT", "German - Austria"], _
		["0C09", "en-AU", "English - Australia"], _
		["0C0A", "es-ES", "Spanish - Spain"], _
		["0C0C", "fr-CA", "French - Canada"], _
		["0C1A", "sr-Cyrl-CS", "Serbian (Cyrillic) - Serbia and Montenegro"], _
		["0C3B", "se-FI", "Sami (Northern) - Finland"], _
		["0C6B", "quz-PE", "Quechua - Peru"], _
		["1001", "ar-LY", "Arabic - Libya"], _
		["1004", "zh-SG", "Chinese - Singapore"], _
		["1007", "de-LU", "German - Luxembourg"], _
		["1009", "en-CA", "English - Canada"], _
		["100A", "es-GT", "Spanish - Guatemala"], _
		["100C", "fr-CH", "French - Switzerland"], _
		["101A", "hr-BA", "Croatian (Latin) - Bosnia and Herzegovina"], _
		["103B", "smj-NO", "Sami (Lule) - Norway"], _
		["105F", "tzm-Tfng-MA", "Central Atlas Tamazight (Tifinagh) - Morocco"], _
		["1401", "ar-DZ", "Arabic - Algeria"], _
		["1404", "zh-MO", "Chinese - Macao SAR"], _
		["1407", "de-LI", "German - Liechtenstein"], _
		["1409", "en-NZ", "English - New Zealand"], _
		["140A", "es-CR", "Spanish - Costa Rica"], _
		["140C", "fr-LU", "French - Luxembourg"], _
		["141A", "bs-Latn-BA", "Bosnian (Latin) - Bosnia and Herzegovina"], _
		["143B", "smj-SE", "Sami (Lule) - Sweden"], _
		["1801", "ar-MA", "Arabic - Morocco"], _
		["1809", "en-IE", "English - Ireland"], _
		["180A", "es-PA", "Spanish - Panama"], _
		["180C", "fr-MC", "French - Monaco"], _
		["181A", "sr-Latn-BA", "Serbian (Latin) - Bosnia and Herzegovina"], _
		["183B", "sma-NO", "Sami (Southern) - Norway"], _
		["1C01", "ar-TN", "Arabic - Tunisia"], _
		["1c09", "en-ZA", "English - South Africa"], _
		["1C0A", "es-DO", "Spanish - Dominican Republic"], _
		["1C1A", "sr-Cyrl-BA", "Serbian (Cyrillic) - Bosnia and Herzegovina"], _
		["1C3B", "sma-SE", "Sami (Southern) - Sweden"], _
		["2001", "ar-OM", "Arabic - Oman"], _
		["2009", "en-JM", "English - Jamaica"], _
		["200A", "es-VE", "Spanish - Venezuela"], _
		["201A", "bs-Cyrl-BA", "Bosnian (Cyrillic) - Bosnia and Herzegovina"], _
		["203B", "sms-FI", "Sami (Skolt) - Finland"], _
		["2401", "ar-YE", "Arabic - Yemen"], _
		["2409", "en-029", "English - Caribbean"], _
		["240A", "es-CO", "Spanish - Colombia"], _
		["241A", "sr-Latn-RS", "Serbian (Latin) - Serbia"], _
		["243B", "smn-FI", "Sami (Inari) - Finland"], _
		["2801", "ar-SY", "Arabic - Syria"], _
		["2809", "en-BZ", "English - Belize"], _
		["280A", "es-PE", "Spanish - Peru"], _
		["281A", "sr-Cyrl-RS", "Serbian (Cyrillic) - Serbia"], _
		["2C01", "ar-JO", "Arabic - Jordan"], _
		["2C09", "en-TT", "English - Trinidad and Tobago"], _
		["2C0A", "es-AR", "Spanish - Argentina"], _
		["2C1A", "sr-Latn-ME", "Serbian (Latin) - Montenegro"], _
		["3001", "ar-LB", "Arabic - Lebanon"], _
		["3009", "en-ZW", "English - Zimbabwe"], _
		["300A", "es-EC", "Spanish - Ecuador"], _
		["301A", "sr-Cyrl-ME", "Serbian (Cyrillic) - Montenegro"], _
		["3401", "ar-KW", "Arabic - Kuwait"], _
		["3409", "en-PH", "English - Philippines"], _
		["340A", "es-CL", "Spanish - Chile"], _
		["3801", "ar-AE", "Arabic - U.A.E."], _
		["380A", "es-UY", "Spanish - Uruguay"], _
		["3C01", "ar-BH", "Arabic - Bahrain"], _
		["3C0A", "es-PY", "Spanish - Paraguay"], _
		["4001", "ar-QA", "Arabic - Qatar"], _
		["4009", "en-IN", "English - India"], _
		["400A", "es-BO", "Spanish - Bolivia"], _
		["4409", "en-MY", "English - Malaysia"], _
		["440A", "es-SV", "Spanish - El Salvador"], _
		["4809", "en-SG", "English - Singapore"], _
		["480A", "es-HN", "Spanish - Honduras"], _
		["4C0A", "es-NI", "Spanish - Nicaragua"], _
		["500A", "es-PR", "Spanish - Puerto Rico"], _
		["540A", "es-US", "Spanish - United States"], _
		["7C04", "zh-CHT", "Chinese - Traditional"]]

; #FUNCTION# ====================================================================================================================
; Name ..........: GetCurrentLanguageIniFile
; Description ...: IniDatei, welche zur aktuellen Systemsprache passt suchen...
; Syntax ........: GetCurrentLanguageIniFile($OSLang)
; Author ........: Tino Reichardt
; Modified ......: 12.04.2015
; ===============================================================================================================================
Func GetCurrentLanguageIniFile($OSLang = @OSLang)
	Local $sCombo = ""
	Local $sLangFile
	Local $iLangID = 0

	; was haben wir denn im moment für sprachen definiert...
	For $i = 0 To $iLanguageCount - 1
		If IsFunc($aAllLanguages[$i][3]) Then $sCombo &= "|" & $aAllLanguages[$i][2]
	Next
	; remove first | -> no empty cell in table
	$sCombo = StringTrimLeft($sCombo, 1)
	; ConsoleWrite("$sCombo=" & $sCombo & @CRLF)

	For $i = 0 To $iLanguageCount - 1
		; wenn id der Sprache nicht passt, nächste probieren...
		If $aAllLanguages[$i][0] <> $OSLang Then ContinueLoop

		; zum Beispiel: %APPDATA%\de-DE.ini
		$sLangFile = $sAppPath & $aAllLanguages[$i][1] & ".ini"

		If FileExists($sLangFile) Then
			; Sprachdatei ist schon vorhanden
			If Not IsFunc($aAllLanguages[$i][3]) Then
				; show some messsage, that we would like to have this translation ;)
				Local $sText = "Your language (id=" & $OSLang & ") is not part of USB-Backup currently." & @CRLF & @CRLF
				$sText &= "Please mail me your translation ;)"
				MsgBox(0, $sTitle, $sText)
			EndIf
			Return $sLangFile
		Else
			; Sprachdatei muss erstellt werden
			If IsFunc($aAllLanguages[$i][3]) Then
				; Sprache ist in USB-Backup vorhanden... das ist schick...
				Local $sIniContent = $aAllLanguages[$i][3](True, $sLangFile)
				FileWrite($sLangFile, $sIniContent)
				Return $sLangFile
			Else
				; Abbruch der Schleife, $sLangFile ist noch definiert
				$iLangID = $i
				ExitLoop
			EndIf
		EndIf
	Next

	If StringLen($sLangFile) = 0 Then
		Local $sText = "Your System Language is completly unknown to me?!" & @CRLF
		$sText &= "Please tell me more about it?! -> @OSLang=" & @OSLang
		MsgBox(0, $sTitle, $sText)
		Exit
	EndIf

	; wenn wir hier landen, haben wir eine bisher undefinierte Sprache und noch keine "ähnliche" Ini Datei
	#cs
		current language is unknown to USB-Backup
		- ask user, which language he want to use for now...
		- save it to a new language.ini + ask user for translation ;)
	#ce

	Local $width = 400
	Local $height = 170
	Local $left = @DesktopWidth / 2 - $width / 2
	Local $top = @DesktopHeight / 2 - $height / 2
	Local $hWnd = GUICreate($sTitle, $width, $height, $left, $top, BitOR($WS_SYSMENU, $WS_CAPTION))

	Local $sText = ""
	Local $id_OK = GUICtrlCreateButton('OK', $width - 70, $height - 30, 60, 23)
	Local $aCombo = StringSplit($sCombo, "|", $STR_NOCOUNT)
	Local $id_Combo = GUICtrlCreateCombo("", 10, $height - 30, $width - 100, 23, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
	GUICtrlSetData($id_Combo, $sCombo, $aCombo[0])
	$sText &= "Sorry, but your language (id=" & $OSLang & ") is not part of USB-Backup." & @CRLF & @CRLF
	$sText &= "Which language best suits you?" & @CRLF & @CRLF
	$sText &= "Maybe you can send me a translation ;)"
	GUICtrlCreateLabel($sText, 10, 10, $width - 20, $height - 60)
	;GUICtrlSetBkColor(-1, 0xdddddd)
	GUISetState(@SW_SHOW)

	While 1
		Switch GUIGetMsg()
			Case $id_OK, $GUI_EVENT_CLOSE
				$sCombo = GUICtrlRead($id_Combo)
				;ConsoleWrite("$sCombo=" & $sCombo & @CRLF)
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete($hWnd)

	For $i = 0 To $iLanguageCount - 1
		If $sCombo = $aAllLanguages[$i][2] Then
			Local $sIniContent = $aAllLanguages[$i][3](True, $sLangFile)
			FileWrite($sLangFile, $sIniContent)
			Return $sLangFile
		EndIf
	Next

	; Wenn der Nutzer ESC drückt, wählt er quasi keine Sprache aus!
	Exit
EndFunc   ;==>GetCurrentLanguageIniFile

; #FUNCTION# ====================================================================================================================
; Name ..........: InitLanguage
; Description ...: initialize the content of a section of a transalation IniFile
; Syntax ........: InitLanguage()
; Author ........: Tino Reichardt
; Modified ......: 03.06.2015
; ===============================================================================================================================
Func InitMsg($sIniName, $sSection, ByRef $mArray, $iCount)
	; kann nicht fehlschlagen, da wir die INI Dateien selber "per hand" ausgesucht haben
	Local $a = IniReadSection($sIniName, $sSection)
	If $a[0][0] <> $iCount Then
		#cs
			Local $sText = "Translation File " & $sIniName & " seems wrong." & @CRLF & @CRLF
			$sText &= "Section: " & $sSection & @CRLF
			$sText &= "Lines found: " & $a[0][0] & @CRLF
			$sText &= "Lines wanted: " & $iCount & @CRLF & @CRLF
			$sText &= "Creating backup of it!"
			MsgBox(0, $sTitle, $sText)
		#ce

		; overwrite old one, if there...
		FileMove($sIniName, $sIniName & ".old", 1)

		; will generate a new one...
		GetCurrentLanguageIniFile()
		; read new one...
		$a = IniReadSection($sIniName, $sSection)
	EndIf
	Dim $mArray[$a[0][0] + 1]
	For $i = 1 To $a[0][0]
		$mArray[$i] = $a[$i][1]
	Next
	Return 0
	; ConsoleWrite("$sSection=" & $sSection & " count= "&$a[0][0]+1&@CRLF)
EndFunc   ;==>InitMsg

; #FUNCTION# ====================================================================================================================
; Name ..........: InitLanguage
; Description ...: initialisiert die Spracheinstellungen
; Syntax ........: InitLanguage()
; Author ........: Tino Reichardt
; Modified ......: 12.04.2015
; ===============================================================================================================================
Func InitLanguage()
	;Local $sIniName = GetCurrentLanguageIniFile("4009") ; indien
	Local $sIniName = GetCurrentLanguageIniFile()

	InitMsg($sIniName, "Headlines", $mHeadlines, 5)
	InitMsg($sIniName, "TaskTray", $mTaskTray, 14)
	InitMsg($sIniName, "Messages", $mMessages, 20)
	InitMsg($sIniName, "Buttons", $mButtons, 17)
	InitMsg($sIniName, "StatusMessage", $mStatusMessage, 5)
	InitMsg($sIniName, "ErrorMessages", $mErrorMessages, 14)
	InitMsg($sIniName, "Labels", $mLabels, 65)
	InitMsg($sIniName, "TaskStatus", $mTaskStatus, 5)
	InitMsg($sIniName, "FatalErrors", $mFatalErrors, 9)
	InitMsg($sIniName, "ExcludeComment", $mExcludeComment, 6)
EndFunc   ;==>InitLanguage

; #FUNCTION# ====================================================================================================================
; Name ..........: Msg
; Description ...: Gibt gewählten Text für die aktuelle Sprache zurück
; Syntax ........: Msg()
; Author ........: Tino Reichardt
; Modified ......: 12.04.2015
; ===============================================================================================================================
Func Msg($sMsg, $p1 = "", $p2 = "", $p3 = "", $p4 = "", $p5 = "", $p6 = "")
	; \n -> @crlf
	$sMsg = StringReplace($sMsg, "\n", @CRLF, 0, 1)

	If StringLen($p1) > 0 Then
		$sMsg = StringReplace($sMsg, "%1", $p1, 0, 1)
	Else
		Return $sMsg
	EndIf

	If StringLen($p2) > 0 Then
		$sMsg = StringReplace($sMsg, "%2", $p2, 0, 1)
	Else
		Return $sMsg
	EndIf

	If StringLen($p3) > 0 Then
		$sMsg = StringReplace($sMsg, "%3", $p3, 0, 1)
	Else
		Return $sMsg
	EndIf

	If StringLen($p4) > 0 Then
		$sMsg = StringReplace($sMsg, "%4", $p4, 0, 1)
	Else
		Return $sMsg
	EndIf

	If StringLen($p5) > 0 Then
		$sMsg = StringReplace($sMsg, "%5", $p5, 0, 1)
	Else
		Return $sMsg
	EndIf

	If StringLen($p6) > 0 Then
		$sMsg = StringReplace($sMsg, "%6", $p6, 0, 1)
	Else
		Return $sMsg
	EndIf
EndFunc   ;==>Msg
