#pragma compile(FileVersion, 1.2.0.0)
#pragma compile(ProductVersion, 3.3.12.0)
#pragma compile(ProductName, File to Base64 String Code Generator)
#pragma compile(LegalCopyright, UEZ 2011-2015)
#pragma compile(Icon, EyeBlink.ico)
#pragma compile(CompanyName, UEZ Software Development)
#pragma compile(inputboxres, false)
#pragma compile(UPX, False)

;~ #AutoIt3Wrapper_Version=b
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rm
#AutoIt3Wrapper_Run_After=del /f /q "%scriptdir%\%scriptfile%_stripped.au3"

#include <ButtonConstants.au3>
#include <Constants.au3>
#include <FontConstants.au3>
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <GUIListView.au3>
#include <GUIMenu.au3>
#include <GUIRichEdit.au3>
#include <Misc.au3>
#include <WindowsConstants.au3>
#include <WinAPISys.au3>

Break(0)
Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 0)

Global Const $title = "'File to Base64 String' Code Generator "
_GDIPlus_Startup()

Global Const $hDll_shell32 = DllOpen("shell32.dll")
Local $hDll_user32 = DllOpen("user32.dll")

#Region GUI
Global $aDPI = _GDIPlus_GraphicsGetDPIRatio()
Global Const $ver = "v1.20 Build 2015-01-20"
Global Const $width = 642
Global Const $height = 600
Global Const $hGUI = GUICreate($title & $ver & " by UEZ", $width, $height, -1, -1, Default, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOPMOST))
GUISetFont(8 * $aDPI[0], 400, 0, "Arial")

Global $aBGColors[12] = [0xBFCDDB, 0xEAE3F3, 0xC0DCC0, 0xA6CAF0, 0xD7E4F2, 0xFFE0C4, 0xFFE4B5, 0xE6E6FA, 0xEEE8AA, 0xFFD948, 0xEEBB88, 0xABCDEF]
Global $sBGColors, $k
For $k = 0 To UBound($aBGColors) - 1
	$sBGColors &= Hex($aBGColors[$k], 6) & ", "
Next
$sBGColors = StringTrimRight($sBGColors, 2)

Global $GUI_Color, $GUI_Color_def = "FFD948", $LZNT_CompStrength_def = 1, $DeCompFct_def = 1, $iCompAlg_def = 1
Global $ini_file = @ScriptDir & "\File to Base64 String Code Generator.ini"
Global $hFile_Ini
If Not FileExists($ini_file) Then
	$hFile_Ini = FileOpen($ini_file, 1)
	FileWriteLine($hFile_Ini, ";Some color values: " & $sBGColors)
	FileClose($hFile_Ini)
	IniWrite($ini_file, "GUI_Color", "Random", 0)
	IniWrite($ini_file, "GUI_Color", "Color", $GUI_Color_def)
	IniWrite($ini_file, "Compression", "Strength", $LZNT_CompStrength_def)
	IniWrite($ini_file, "Compression", "DeComp", $DeCompFct_def)
	IniWrite($ini_file, "Compression", "CompAlg", $iCompAlg_def)
EndIf
Global $random_color = IniRead($ini_file, "GUI_Color", "Random", 0)
Global $LZNT_compression_strength = Int(IniRead($ini_file, "Compression", "Strength", $LZNT_CompStrength_def))
If $LZNT_compression_strength < 0 Or $LZNT_compression_strength > 2 Then $LZNT_compression_strength = $LZNT_CompStrength_def

Global $iCompAlg = Int(IniRead($ini_file, "Compression", "CompAlg", $iCompAlg_def))
If $iCompAlg < 1 Or $iCompAlg > 2 Then $iCompAlg = $iCompAlg_def

Global $DeCompFct = Int(IniRead($ini_file, "Compression", "DeComp", $DeCompFct_def))
If $DeCompFct < 0 Or $DeCompFct > 1 Then $DeCompFct = $DeCompFct_def

If $random_color = "1" Then
	$GUI_Color = $aBGColors[Random(0, UBound($aBGColors) - 1, 1)]
	GUISetBkColor($GUI_Color)
	$GUI_Color = Hex($GUI_Color, 6)
Else
	$GUI_Color = IniRead($ini_file, "GUI_Color", "Color", $GUI_Color_def)
	If StringLen($GUI_Color) <> 6 Or Not Dec($GUI_Color) Then $GUI_Color = $GUI_Color_def
	GUISetBkColor("0x" & $GUI_Color)
EndIf

Global Const $idLabel_File = GUICtrlCreateLabel("Select File:", 8, 16, 70, 20)
GUICtrlSetFont(-1, 10 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, "Select file which you want to convert to a base64 string", "", 0, 1)
Global Const $idButton_File = GUICtrlCreateButton("&Browse", 80, 12, 75, 25)
GUICtrlSetFont(-1, 9 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, "Select file which you want to convert to a base64 string", "", 0, 1)
Global Const $idInput_File = GUICtrlCreateInput("", 160, 14, 473, 22, $ES_READONLY)
GUICtrlSetFont(-1, 10 * $aDPI[0], 400, 0, "Arial")
;~ GUICtrlSetState(-1, $GUI_DROPACCEPTED)
Global Const $idLabel_VarName = GUICtrlCreateLabel("Variable / Function Name:", 8, 49, 155, 20)
GUICtrlSetFont(-1, 10 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, "Enter the variable / function name without leading $" & @LF & "In multi selection mode file names will be used!", "", 0, 1)
Global Const $idInput_Var = GUICtrlCreateInput("Base64String", 164, 46, 221, 22)
GUICtrlSetFont(-1, 10 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, "Enter the name of the function / variable to be used without leading $" & @LF & "In multi selection mode file names will be used!", "", 0, 1)
;~ GUICtrlSetState(-1, $GUI_DROPACCEPTED)
Global Const $idCheckbox_ContFuncName = GUICtrlCreateCheckbox(" Create continuous function names", 165, 76, 220, 16, Default, $WS_EX_LAYOUTRTL)
GUICtrlSetFont(-1, 8 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, ".Creates continuous function names when multi files are selected to handle functions easily within your script", "", 0, 1)
Global Const $idButton_Convert = GUICtrlCreateButton("Convert", 8, 102, 83, 43, $BS_BITMAP)
GUICtrlSetFont(-1, 21 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, "Convert any file to a base64 string incl. function code", "", 0, 1)
Global Const $hButton_Convert = GUICtrlGetHandle($idButton_Convert)

Global $u, $aBitmapAnim[8]
;~ For $u = 0 To 7
;~ 	$aBitmapAnim[$u] = _GDIPlus_BitmapCreateFromMemory(Execute("_EyeBlink_" & $u & "png()")) ;AutoIt3Wrapper_Run_Au3Stripper will ignore _EyeBlink_*png functions and remove it :-(
;~ Next
$aBitmapAnim[0] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_0png())
$aBitmapAnim[1] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_1png())
$aBitmapAnim[2] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_2png())
$aBitmapAnim[3] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_3png())
$aBitmapAnim[4] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_4png())
$aBitmapAnim[5] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_5png())
$aBitmapAnim[6] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_6png())
$aBitmapAnim[7] = _GDIPlus_BitmapCreateFromMemory(_EyeBlink_7png())

Global Const $STM_SETIMAGE = 0x0172
Global Const $hBmp_Button = _GDIPlus_BitmapCreateFromMemory(Image_Btn(), True)
_WinAPI_DeleteObject(_SendMessage($hButton_Convert, $BM_SETIMAGE, $IMAGE_BITMAP, $hBmp_Button))
_WinAPI_UpdateWindow($hButton_Convert)
Global Const $hBmp_Button2 = _GDIPlus_BitmapCreateFromMemory(Image_Btn2(), True)

Global $RE_BgColor = 0xFBFDFB
Global $hRichEdit = _GUICtrlRichEdit_Create($hGUI, "", 8, 152, 625, $height - 157, BitOR($ES_MULTILINE, $WS_VSCROLL, $WS_HSCROLL, $ES_AUTOVSCROLL))
_GUICtrlRichEdit_SetLimitOnText($hRichEdit, 0xFFFFFF)
_GUICtrlRichEdit_SetFont($hRichEdit, 9 * $aDPI[0], "Arial")
_GUICtrlRichEdit_SetCharColor($hRichEdit, 0x200000) ;BGR
_GUICtrlRichEdit_SetCharBkColor($hRichEdit, 0xFBFDFB) ;BGR
;~ _GUICtrlRichEdit_SetBkColor($hRichEdit, 0xFFFFFF)
_GUICtrlRichEdit_SetBkColor($hRichEdit, $RE_BgColor)
_GUICtrlRichEdit_SetReadOnly($hRichEdit, True)

Global Const $idButton_Save = GUICtrlCreateButton("&Save", 104, 102, 75, 43)
GUICtrlSetFont(-1, 9 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, "Save script to a file (AU3 format)", "", 0, 1)
Global Const $idButton_Clipboard = GUICtrlCreateButton("&Clipboard", 192, 102, 75, 43)
GUICtrlSetFont(-1, 9 * $aDPI[0], 400, 0, "Arial")
GUICtrlSetTip(-1, "LMB: Put script to clipboard" & @LF & "RMB: Put script to clipboard and paste it to SciTE directly", "", 0, 1)


Global Const $idCheckbox_Compression = GUICtrlCreateCheckbox(" Com&pression", 304, 102, 81, 17, Default, $WS_EX_LAYOUTRTL)
GUICtrlSetFont(-1, 8 * $aDPI[0], 400, 0, "Arial")
If $LZNT_compression_strength < 2 Then GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, ".Enable build-in (LZNT) or LZMAT compression" & @LF & ".Press RMB to set LZNT compression strength" & @LF & ".Default: high (slow)", "", 0, 1)

Global Const $idCheckbox_DecompFunction = GUICtrlCreateCheckbox(".&Add decomp. func", 275, 129, 110, 17, Default, $WS_EX_LAYOUTRTL)
GUICtrlSetFont(-1, 8 * $aDPI[0], 400, 0, "Arial")
If $DeCompFct Then GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, ".Add also decompression function to the code", "", 0, 1)

Global Const $idGroup_Statistics = GUICtrlCreateGroup("Statistics", 392, 40, 241, 105)
Global Const $idLabel_Length = GUICtrlCreateLabel("Old Length:", 400, 60, 59, 18)
GUICtrlSetTip(-1, "Size of the file", "", 0, 1)
Global Const $idLabel_Lenght_n = GUICtrlCreateLabel(StringFormat("%.2f %s", 0, "kb"), 466, 60, 96, 18)
Global Const $idLabel_Length_C = GUICtrlCreateLabel("New Length:", 400, 90, 66, 18)
GUICtrlSetTip(-1, "Size of the compressed file", "", 0, 1)
Global Const $idLabel_Length_C_n = GUICtrlCreateLabel(StringFormat("%.2f %s", 0, "kb"), 466, 90, 88, 18)
Global Const $idLabel_ScriptLength = GUICtrlCreateLabel("Script length:", 400, 120, 66, 18)
GUICtrlSetTip(-1, "Size of the script file", "", 0, 1)
Global Const $idLabel_ScriptLength_n = GUICtrlCreateLabel(StringFormat("%.2f %s", 0, "kb"), 466, 120, 88, 18)
GUICtrlSetTip(-1, "Size of generated AutoIt script", "", 0, 1)
Global Const $idLabel_Saved = GUICtrlCreateLabel("Saved:", 539, 90, 38, 18)
GUICtrlSetTip(-1, "Compression benefit", "", 0, 1)
Global Const $idLabel_SavedPerc = GUICtrlCreateLabel(StringFormat("%05.2f %s", 0, "%"), 579, 90, 46, 18)
GUICtrlSetFont(-1, 8 * $aDPI[0], 800, 0, "Arial")
GUICtrlSetTip(-1, "The higher the value the better the compression!", "", 0, 1)
Global Const $idLabel_MS = GUICtrlCreateLabel("Multiselect:", 539, 60, 57, 14)
GUICtrlSetTip(-1, "Press lmb to display statistics if Multiselect is set to true", "", 0, 1)
Global Const $idLabel_MS_state = GUICtrlCreateLabel("False", 595, 60, 30, 14)
GUICtrlCreateGroup("", -99, -99, 1, 1)

Global Enum $id_LZNT_Standard = 0x400, $id_LZNT_High, $id_LZNT, $id_LZMAT, $id_About, $id_Copy
Global Const $hQMenu_Sub1 = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($hQMenu_Sub1, 0, "Standard", $id_LZNT_Standard)
_GUICtrlMenu_InsertMenuItem($hQMenu_Sub1, 1, "High", $id_LZNT_High)

Global Const $hQMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($hQMenu, 0, "LZNT Compression Strength", $id_LZNT, $hQMenu_Sub1)
_GUICtrlMenu_InsertMenuItem($hQMenu, 1, "LZMAT Compression", $id_LZMAT)
_GUICtrlMenu_CheckMenuItem($hQMenu, $iCompAlg - 1)

If $LZNT_compression_strength = 2 Then
	_GUICtrlMenu_CheckRadioItem($hQMenu_Sub1, 0, 1, $LZNT_CompStrength_def)
Else
	_GUICtrlMenu_CheckRadioItem($hQMenu_Sub1, 0, 1, $LZNT_compression_strength)
EndIf

Global Const $hMenu = _GUICtrlMenu_GetSystemMenu($hGUI)
_GUICtrlMenu_AppendMenu($hMenu, $MF_SEPARATOR, 0, 0)
_GUICtrlMenu_AppendMenu($hMenu, $MF_STRING, $id_About, "About")
Global $hTmp = _GDIPlus_BitmapCreateFromMemory(Info_Icon())
Global Const $hBMP_About = _GDIPlus_Convert2HBitmap($hTmp, $COLOR_MENU)
_GDIPlus_BitmapDispose($hTmp)
_GUICtrlMenu_SetItemBmp($hMenu, 8, $hBMP_About)

Global Const $hPopupMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($hPopupMenu, 0, "Copy", $id_Copy)
Global Const $hBMP_Copy = WinAPI_GUICtrlMenu_CreateBitmap(@SystemDir & "\Shell32.dll", 134)
_GUICtrlMenu_SetItemBmp($hPopupMenu, 0, $hBMP_Copy)

_GUICtrlRichEdit_SetEventMask($hRichEdit, $ENM_MOUSEEVENTS)

;~ GUISetIcon(@ScriptDir & "\EyeBlink.ico", $hGUI)
Global $hIcon = _GDIPlus_HICONCreateFromBitmap($aBitmapAnim[0])
_WinAPI_SetClassLongEx($hGUI, $GCL_HICONSM, $hIcon)
GUISetState(@SW_SHOW, $hGUI)
#EndRegion GUI

Global Const $tagEN_MSGFILTER = $tagNMHDR & ";uint msg;int wParam;int lParam"

Global Const $SND_ASYNC = 0x00000001
Global Const $SND_MEMORY = 0x00000004
Global Const $SND_NOSTOP = 0x00000010
Global Const $binWave = _Typewriter()
Global $tWave = DllStructCreate("byte[" & BinaryLen($binWave) & "]")
DllStructSetData($tWave, 1, $binWave)

Global $_B64E_CodeBuffer, $_B64E_CodeBufferMemory, $_B64E_Init, $_B64E_EncodeData, $_B64E_EncodeEnd
Global $err = False, $compressed = True, $compressed2, $multiselect = False, $ToolTip = False
Global $nMsg, $text, $Script, $Decompress_LZNT_Func, $BinaryString, $BinaryStringComp, $Script_Base64Decode, $BinStringLen, $bSize, $hListView, $iLabel_Length_C_n, $iLabel_Lenght_n
Global $hWndListView, $hWndFrom, $iIDFrom, $iCode, $aStatistic[1][4]
Global Const $LineLen = 2000, $limit = 50 * 1024 ^ 2
;~ Global Const $WM_MOVING = 0x0216
Global $aCoord, $tPoint, $Prev_Coord[2], $aFiles[2], $sFiles, $converted = False
Global $_LZMAT_CodeBuffer, $_LZMAT_CodeBufferMemory, $_LZMAT_Compress, $_LZMAT_Decompress, $iCompressionUsed = Null
_LZMAT_Startup()

#Region function codes
Global $Script_Base64Decode = @CRLF & @CRLF & _
		'Func _WinAPI_Base64Decode($sB64String)' & @CRLF
$Script_Base64Decode &= @TAB & 'Local $aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)' & @CRLF
$Script_Base64Decode &= @TAB & 'If @error Or Not $aCrypt[0] Then Return SetError(1, 0, "")' & @CRLF
$Script_Base64Decode &= @TAB & 'Local $bBuffer = DllStructCreate("byte[" & $aCrypt[5] & "]")' & @CRLF
$Script_Base64Decode &= @TAB & '$aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $bBuffer, "dword*", $aCrypt[5], "ptr", 0, "ptr", 0)' & @CRLF
$Script_Base64Decode &= @TAB & 'If @error Or Not $aCrypt[0] Then Return SetError(2, 0, "")' & @CRLF
$Script_Base64Decode &= @TAB & 'Return DllStructGetData($bBuffer, 1)' & @CRLF
$Script_Base64Decode &= 'EndFunc   ;==>_WinAPI_Base64Decode'

Global $Decompress_LZNT_Func = @CRLF & @CRLF & _
		'Func _WinAPI_LZNTDecompress(ByRef $tInput, ByRef $tOutput, $iBufferSize)' & @CRLF
$Decompress_LZNT_Func &= @TAB & '$tOutput = DllStructCreate("byte[" & $iBufferSize & "]")' & @CRLF
$Decompress_LZNT_Func &= @TAB & 'If @error Then Return SetError(1, 0, 0)' & @CRLF
$Decompress_LZNT_Func &= @TAB & 'Local $aRet = DllCall("ntdll.dll", "uint", "RtlDecompressBuffer", "ushort", 0x0002, "struct*", $tOutput, "ulong", $iBufferSize, "struct*", $tInput, "ulong", DllStructGetSize($tInput), "ulong*", 0)' & @CRLF
$Decompress_LZNT_Func &= @TAB & 'If @error Then Return SetError(2, 0, 0)' & @CRLF
$Decompress_LZNT_Func &= @TAB & 'If $aRet[0] Then Return SetError(3, $aRet[0], 0)' & @CRLF
$Decompress_LZNT_Func &= @TAB & 'Return $aRet[6]' & @CRLF
$Decompress_LZNT_Func &= 'EndFunc   ;==>_WinAPI_LZNTDecompress'

Global $Decompress_LZMAT_Func = @CRLF & @CRLF & _
        'Func ASM_DecompressLZMAT($Data)' & @CRLF & _
        @TAB & 'Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768' & @CRLF & _
        @TAB & 'If @AutoItX64 Then' & @CRLF & _
        @TAB & @TAB & 'Local $Code = "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"' & @CRLF & _
        @TAB & @TAB & '$Code &= "5/o1kEQsAf7ChQJKEWf+KPU06QsjULCtlHGUMyrwiJMbCggKTje0+TgXdGmQGXisYu9BxgKaIwr4HApKAQw/fMgSArJnA8oeSdHJqVNxagiueGUCImaKKhdshPB5iEkCHQnGQAMYF+nk0TdpgoAK8OuH/JE5agKytTp0np6Md2oBNUARWlgo5ukqCBEPM8DqFFEU4sX7H0lHQRVGyjMdg+gB5l6gi9M1J/HokAOWAfx2ZkGJJMMQiQIWuiDb/YIUHMFqySVhq4Q/EoD5Ib0MLCkZJjioUnA8/SgzlwEgZ+l9+kmBIKC0SwEvhHYkd/kuc1LVL4gDxlvdTLhpnpUVrlgn0tgHBqF6VvdwlLTPoJJ25AaLKogBuFfhaNsouwhkkD30gC3PKfdMOUUXg6RCPEWE5GmqAgGJ34M5dDgBRS4MLEkU5osYwO0ICfUwg8MkMfbrGC6J3jNUMPudSzS61JpAOsDuDkQJ1uWIN6HSnU1B2MYJ/ggfdJxF1O1noN92jOjoIHOIFu14FBrh3UCvPDk0dbGeRUnrwDOA0IQkEmvC5TiHZDxswO9VBGiYGv/Q1z2Uv0e3v8aGuFuA7/qDMecDPuoC3f/PO4A1wZASAyFgkAEpOdKgg1TWthyYWinmP54MgPQ1rpzBR+OdCEYCHEO1BcMDOcaC9fR5oBo8GGDxgnnegRnF2iZt6RmJwkbrjn4p8qoMCSAYRQ6cvNeaxiJiGCSvOZAFRYXbkA70MXZ1sTmh0KG2oM9Bt5W+SEs/+hTR6rtEiKKLuvOtooQEl+AwB6Sx8Mb1KK6aJBq4YaVSQDXA6wSRHIq227VjhUtlKx3UBa18GgWXOfkOr+nyMcp0ZSdGEbZc1CMS4wQlSgtC30Omp/KB+1oPKnRQ9EQShmkMl24oN7gEjZ+pwxjrLDDTqDNh1hKn5n9lRwVE6bcp2xQSMVB1sGCmVDoaAtoCuIKBAW5VeSOErdLKzbsNjZ8RTZmcApMQdecB3HP+FAg/JJ+NmvzUTHOjIt7TkJgYBb9/EUQhUO/8PnQEJDQ/sBD4jRJdaLEkJ5wDdiOD7unrB7ILGRdBcdoxdoGIBEeLFBAsbWhG0TzMfyziHYvp8ajvXg6NsmoEqsjRi+nXKl+X0QMJB/nqHkS5Qo10HoCvOfFyf6I9r6rpHxgxHDB1vqaa+0OlDh2qtDIng0TpiGhjPsVSGmVkO6kF9olT69UaI5FKwyILSDvNuBQ4vvLDsAuJAjMxwB+4vj8769/2oQfYYkoFt3Qw+wqswICLAfaIoUIRAx3rvNQQBxe1VwyMzwbQlQD+/POqX2DDAA=="' & @CRLF & _
        @TAB & 'Else' & @CRLF & _
        @TAB & @TAB & 'Local $Code = "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"' & @CRLF & _
        @TAB & @TAB & '$Code &= "/id8kUgoGcQx6d+KOQN0d42I71gbLXDqiaQjkCShGg8y0SwBdmp/IAxNAuyIAxEMjZ1rWqFq5KNJslERd1oWbQJAg8rwiFZAKkYDpA6gQ+m+0DV3jICU8LqooVCJssR4BJCC6UOvryGF5gG/funUP/0JA3VnuSrYwlk7kUyTCc7NZTuRQY/pjfmmZn0gdJowKggWDjLA6hRWhKlwjUclqiIz1Yh3mr816TY1iU36JAPdLd+EZAqzN5cUEPdH9UCZavcmEkP+bTBBCK9U0y2OyBEwBArp7/grkhiJkXCOQLEbRwGbJIJYoJJfEukL+jQ/zCX1IYgGYvT4RXnKmbLed054IOL8uUuTuCXnyU5ilktxoulxgIVVMe1XVr6hUVNskdyszpdIJyPGOOVSiG1pIYbi6yAG0ynROc7MVRS9jx6E21zTO1DWMd0xPhQyLB9UTYjeJPIdMURi0Bf3o+sqwFwnRTMl598XV8HjArXaiBHrRp5N62KZAwh0kNBkGWyJ6UbRRnnpe/EnhnmJS+Acg3HxM7I4FBd4GTXJgIvBhNIpdaZaY+uwS3YcS9KPjYaQLwySxhsUU9mpCbcMMSMxCctzEks9Mly+xH37cTEg2OuYNHP595luKIJo7gwaA8gSnmQBCnPv44nZLFY/nKHzHIjkTgfqgPLOrNVAr5mElhwKIeOpH/vyILUvgcMDOcFwo/TEF40UD9dmgsiNtD4LhgrIgcKDCusBKcrLagESEE+YKO3Rx/uywkNwazfLYRk7QfEQdmjNFjGJEEOga1EAFtt14YvSEyAa6cH+wpPL0euIlaSbvNO61pOm+vWAldmB4f9BB9nBbGdwr6+KhVGBoa+qHkTr26S1KYVLlz/gHY1UMwFKORTcDsSCL1p0gGx0dotUhCQcMsZtpKV3JnvTZSWB+6KvdGeE9BJGhgyVvLgJuASef6p+mI/pgqq1sZ8cCIjBFhTp0v2U99kWQMt/kWCyOIiDoOmbQll20GeGdZlTVCilAoSAobMBjPXP/Ir6OrfRwiViCcEiIZJYdA7SZioLVNR4txuNmhFZIKYCWxBUzhNp1TE/TQsKTDP8dR3hopA4XAUzgRSD4n+O9BEEhxwSf4nQEdU8qF+VJHQw2Ql2LBl9621xUcdEaoNTDVAbxgSj0Z49Fw6LKlL8xkZcC4kpdeUBgOme/FneaKTJKBJUgrBBBAqshOmg/ZknRdMQzx/UFFTVA4MkoEEdRn5FgYwyJwY4j0TpxJeA8aADdEgrY6fF2h6zJKgaDmVUcEoTTBGNFowTQYEw6Tmmi8XkMWVaJl8MLH8xxG/ry4yDt4CBw5E2CenFJCy4jUBF5CjfRDSJAx32vBi4Ajvr4e/ahQfamHtUBzH7geLAiyANDBLpsaFCAxHrvN0QQQe1V71NEoXJF0hFiQxpxhcDsuYJCPfHA5BaCqpSSQoAdfaJysHpAh7886sW0V23xqpfwwA="' & @CRLF & _
        @TAB & 'EndIf' & @CRLF & _
        @TAB & 'Local $Opcode = String(_LZMAT_CodeDecompress($Code))' & @CRLF & _
        @TAB & 'Local Const $_LZMAT_Compress = (StringInStr($Opcode, "89C0") + 1) / 2' & @CRLF & _
        @TAB & 'Local Const $_LZMAT_Decompress = (StringInStr($Opcode, "89DB") + 1) / 2' & @CRLF & _
        @TAB & '$Opcode = Binary($Opcode)' & @CRLF & _
        @TAB & 'Local $_LZMAT_CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)' & @CRLF & _
        @TAB & '$_LZMAT_CodeBufferMemory = $_LZMAT_CodeBufferMemory[0]' & @CRLF & _
        @TAB & 'Local Const $_LZMAT_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_LZMAT_CodeBufferMemory)' & @CRLF & _
        @TAB & 'DllStructSetData($_LZMAT_CodeBuffer, 1, $Opcode)' & @CRLF & _
        @TAB & 'Local Const $OutputLen = Int(BinaryMid($Data, 1, 4))' & @CRLF & _
        @TAB & '$Data = BinaryMid($Data, 5)' & @CRLF & _
        @TAB & 'Local Const $InputLen = BinaryLen($Data)' & @CRLF & _
        @TAB & 'Local Const $Input = DllStructCreate("byte[" & $InputLen & "]")' & @CRLF & _
        @TAB & 'DllStructSetData($Input, 1, $Data)' & @CRLF & _
        @TAB & 'Local Const $Output = DllStructCreate("byte[" & $OutputLen & "]")' & @CRLF & _
        @TAB & 'Local Const $Ret = DllCallAddress("uint", DllStructGetPtr($_LZMAT_CodeBuffer) + $_LZMAT_Decompress, "struct*", $Input, "uint", $InputLen, "struct*", $Output, "uint*", $OutputLen)' & @CRLF & _
        @TAB & 'DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $_LZMAT_CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)' & @CRLF & _
        @TAB & 'Return BinaryMid(DllStructGetData($Output, 1), 1, $Ret[4])' & @CRLF & _
        'EndFunc   ;==>ASM_DecompressLZMAT' & @CRLF & _
        @CRLF & _
        'Func _LZMAT_CodeDecompress($Code)' & @CRLF & _
        @TAB & 'Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768' & @CRLF & _
        @TAB & 'If @AutoItX64 Then' & @CRLF & _
        @TAB & @TAB & 'Local $Opcode = "0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"' & @CRLF & _
        @TAB & 'Else' & @CRLF & _
        @TAB & @TAB & 'Local $Opcode = "0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"' & @CRLF & _
        @TAB & 'EndIf' & @CRLF & _
        @TAB & 'Local Const $AP_Decompress = (StringInStr($Opcode, "89C0") - 3) / 2' & @CRLF & _
        @TAB & 'Local Const $B64D_Init = (StringInStr($Opcode, "89D2") - 3) / 2' & @CRLF & _
        @TAB & 'Local Const $B64D_DecodeData = (StringInStr($Opcode, "89F6") - 3) / 2' & @CRLF & _
        @TAB & '$Opcode = Binary($Opcode)' & @CRLF & _
        @TAB & 'Local $CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)' & @CRLF & _
        @TAB & '$CodeBufferMemory = $CodeBufferMemory[0]' & @CRLF & _
        @TAB & 'Local Const $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)' & @CRLF & _
        @TAB & 'DllStructSetData($CodeBuffer, 1, $Opcode)' & @CRLF & _
        @TAB & 'Local Const $B64D_State = DllStructCreate("byte[16]")' & @CRLF & _
        @TAB & 'Local Const $Length = StringLen($Code)' & @CRLF & _
        @TAB & 'Local Const $Output = DllStructCreate("byte[" & $Length & "]")' & @CRLF & _
        @TAB & 'DllCallAddress("none", DllStructGetPtr($CodeBuffer) + $B64D_Init, "struct*", $B64D_State, "int", 0, "int", 0, "int", 0)' & @CRLF & _
        @TAB & 'DllCallAddress("int", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, "str", $Code, "uint", $Length, "struct*", $Output, "struct*", $B64D_State)' & @CRLF & _
        @TAB & 'Local Const $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)' & @CRLF & _
        @TAB & 'Local $Result = DllStructCreate("byte[" & ($ResultLen + 16) & "]"), $Ret' & @CRLF & _
        @TAB & 'If @AutoItX64 Then' & @CRLF & _
        @TAB & @TAB & '$Ret = DllCallAddress("uint", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "struct*", $Result, "int", 0, "int", 0)' & @CRLF & _
        @TAB & 'Else' & @CRLF & _
        @TAB & @TAB & '$Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "ptr", DllStructGetPtr($Result), "int", 0, "int", 0)' & @CRLF & _
        @TAB & 'EndIf' & @CRLF & _
        @TAB & 'DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)' & @CRLF & _
        @TAB & 'Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])' & @CRLF & _
        'EndFunc   ;==>_LZMAT_CodeDecompress'
#EndRegion function codes

;~ Global Const $WM_MOVING = 0x0216
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_CONTEXTMENU, "WM_CONTEXTMENU")
GUIRegisterMsg($WM_MOVING, "WM_MOVING")
GUIRegisterMsg($WM_SYSCOMMAND, "WM_SYSCOMMAND")
GUIRegisterMsg($WM_ACTIVATEAPP, "WM_ACTIVATEAPP")
GUIRegisterMsg($WM_CONTEXTMENU, "WM_CONTEXTMENU")
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES")

Global $aPos, $mhover = False, $mhover_stat1 = False, $mhover_stat2 = True, $bCredits = False
Global $hSciTE, $dummy

_GUICtrlRichEdit_SetText($hRichEdit, "Ready.")

$dummy = GUICtrlCreateDummy()
GUICtrlSendToDummy($dummy)

Global $tChkAero = DllStructCreate("int;")
DllCall("dwmapi.dll", "int", "DwmIsCompositionEnabled", "struct*", $tChkAero)
Global $bAero = DllStructGetData($tChkAero, 1)
If $bAero Then
	GUIRegisterMsg($WM_TIMER, "PlayAnim")
	DllCall($hDll_user32, "int", "SetTimer", "hwnd", $hGUI, "int", 0, "int", Random(15000, 45000, 1), "int", 0)
EndIf

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			GUIRegisterMsg($WM_TIMER, "")
			IniWrite($ini_file, "GUI_Color", "Color", $GUI_Color)
			If GUICtrlRead($idCheckbox_Compression) = $GUI_UNCHECKED Then
				$LZNT_compression_strength = 2
			Else
				If _GUICtrlMenu_GetItemChecked($hQMenu_Sub1, 0) Then
					$LZNT_compression_strength = 0
				Else
					$LZNT_compression_strength = 1
				EndIf
			EndIf
			If GUICtrlRead($idCheckbox_DecompFunction) = $GUI_CHECKED Then
				$DeCompFct = 1
			Else
				$DeCompFct = 0
			EndIf
			IniWrite($ini_file, "Compression", "Strength", $LZNT_compression_strength)
			IniWrite($ini_file, "Compression", "DeComp", $DeCompFct)
			IniWrite($ini_file, "Compression", "CompAlg", $iCompAlg)
			$tWave = 0
			GUIRegisterMsg($WM_CONTEXTMENU, "")
			GUIRegisterMsg($WM_NOTIFY, "")
			GUIRegisterMsg($WM_COMMAND, "")
			GUIRegisterMsg($WM_SYSCOMMAND, "")
			GUIRegisterMsg($WM_CONTEXTMENU, "")
			GUIRegisterMsg($WM_MOVING, "")
			GUIRegisterMsg($WM_ACTIVATEAPP, "")
			_GUICtrlRichEdit_Destroy($hRichEdit)
			_WinAPI_DeleteObject($hBMP_Copy)
			_WinAPI_DeleteObject($hBMP_About)
			_WinAPI_DeleteObject($hBmp_Button)
			_WinAPI_DeleteObject($hBmp_Button2)
			For $u = 0 To 7
				_GDIPlus_BitmapDispose($aBitmapAnim[$u])
			Next
			_WinAPI_DestroyIcon($hIcon)
			_GDIPlus_Shutdown()
			GUIDelete($hGUI)
			DllClose($hDll_shell32)
			DllClose($hDll_user32)
			Exit
		Case $idButton_File
			Load_File()
		Case $idButton_Save
			If _GUICtrlRichEdit_GetText($hRichEdit) = "" Or _GUICtrlRichEdit_GetText($hRichEdit) = "Ready." Then
				MsgBox(16 + 262144, "Error", "Noting to save!" & @LF & @LF & "Convert any file before pressing the Save button!", 30, $hGUI)
			Else
				Save_File()
			EndIf
		Case $idButton_Clipboard
			$text = _GUICtrlRichEdit_GetText($hRichEdit)
			If $text = "" Or $text = "Ready." Then
				MsgBox(16 + 262144, "Error", "Noting to put to clipboard!" & @LF & @LF & "Convert any file before pressing the Clipboard button!", 30, $hGUI)
			Else
				If Not ClipPut($text) Then $err = True
				If $err Then
					MsgBox(16 + 262144, "Error", "Unable to put script to clipboad!", 30, $hGUI)
				Else
					MsgBox(64 + 262144, "Information", "Script was properly put to clipboard!", 30, $hGUI)
				EndIf
			EndIf
		Case $idButton_Convert
			Convert()
		Case $idCheckbox_Compression, $dummy
			Switch BitAND(GUICtrlRead($idCheckbox_Compression), $GUI_CHECKED)
				Case 0
					_GUICtrlMenu_EnableMenuItem($hQMenu, 0, 2)
					_GUICtrlMenu_EnableMenuItem($hQMenu, 1, 2)
				Case Else
					_GUICtrlMenu_EnableMenuItem($hQMenu, 0, 0)
					_GUICtrlMenu_EnableMenuItem($hQMenu, 1, 0)
					If $iCompAlg = 2 Then
						_GUICtrlMenu_CheckMenuItem($hQMenu_Sub1, 0, False)
						_GUICtrlMenu_CheckMenuItem($hQMenu_Sub1, 1, False)
					Else
						If $LZNT_compression_strength = 2 Then
							_GUICtrlMenu_CheckRadioItem($hQMenu_Sub1, 0, 1, $LZNT_CompStrength_def)
						Else
							_GUICtrlMenu_CheckRadioItem($hQMenu_Sub1, 0, 1, $LZNT_compression_strength)
						EndIf
					EndIf
			EndSwitch
		Case $idCheckbox_ContFuncName
			If BitAND(GUICtrlRead($idCheckbox_ContFuncName), $GUI_UNCHECKED) And $multiselect Then
				GUICtrlSetState($idInput_Var, $GUI_DISABLE)
			Else
				GUICtrlSetState($idInput_Var, $GUI_ENABLE)
			EndIf
		Case $GUI_EVENT_DROPPED
			ConsoleWrite("Case $GUI_EVENT_DROPPED")
	EndSwitch
	$aPos = GUIGetCursorInfo($hGUI)
	Switch $aPos[4]
		Case $idLabel_MS
			If $aPos[2] And $multiselect And UBound($aStatistic) > 1 Then Display_Statistic($aStatistic)
		Case $idButton_Clipboard
			If $aPos[3] Then
				$hSciTE = WinGetHandle("[CLASS:SciTEWindow]", "")
				$text = _GUICtrlRichEdit_GetText($hRichEdit)
				If $hSciTE And $text <> "Ready." And $text <> "" Then
					ClipPut($text)
					WinActivate($hSciTE)
					Sleep(500)
					Send("^v")
					Sleep(250)
				Else
					If Not IsHWnd($hSciTE) Then
						MsgBox(16 + 262144, "Error", "SciTE window not detected!", 30, $hGUI)
					Else
						MsgBox(16 + 262144, "Error", "Noting to put to clipboard!" & @LF & @LF & "Convert any file before pressing the Clipboard button!", 30, $hGUI)
					EndIf
				EndIf
			EndIf
		Case $idButton_Convert
			If $mhover_stat2 Then
				_SendMessage($hButton_Convert, $BM_SETIMAGE, $IMAGE_BITMAP, $hBmp_Button2)
				_WinAPI_UpdateWindow($hButton_Convert)
				$mhover_stat2 = False
				$mhover_stat1 = True
			EndIf
		Case Else
			If $mhover_stat1 Then
				_SendMessage($hButton_Convert, $BM_SETIMAGE, $IMAGE_BITMAP, $hBmp_Button)
				_WinAPI_UpdateWindow($hButton_Convert)
				$mhover_stat1 = False
				$mhover_stat2 = True
			EndIf
	EndSwitch
WEnd

Func PlayAnim()
	Local $u, $hIcon
	For $u = 0 To 7
		$hIcon = _GDIPlus_HICONCreateFromBitmap($aBitmapAnim[$u])
		_WinAPI_SetClassLongEx($hGUI, -34, $hIcon)
		Sleep(60)
		_WinAPI_DestroyIcon($hIcon)
	Next
	For $u = 6 To 0 Step -1
		$hIcon = _GDIPlus_HICONCreateFromBitmap($aBitmapAnim[$u])
		_WinAPI_SetClassLongEx($hGUI, -34, $hIcon)
		Sleep(80)
		_WinAPI_DestroyIcon($hIcon)
	Next
	Local $iRnd = Random(15000, 45000, 1)
	DllCall($hDll_user32, "int", "SetTimer", "hwnd", $hGUI, "int", 0, "int", $iRnd, "int", 0)
EndFunc   ;==>PlayAnim

Func Convert()
	If GUICtrlRead($idInput_File) = "" Then Return MsgBox(16 + 262144, "Error", "No file(s) selected!", 30, $hGUI)
	GUICtrlSetState($idButton_Convert, $GUI_DISABLE)
	GUISetState(@SW_DISABLE, $hGUI)
	GUICtrlSetColor($idLabel_SavedPerc, 0x000000)
	_GUICtrlRichEdit_SetText($hRichEdit, "Please wait while converting to base64 string...")
	Local $old_cursor = MouseGetCursor()
	GUISetCursor(15, 1, $hGUI)
	Local $compression = BitAND(GUICtrlRead($idCheckbox_Compression), $GUI_CHECKED)
	Local $decomp_function = BitAND(GUICtrlRead($idCheckbox_DecompFunction), $GUI_CHECKED)
	Local $path = $aFiles[0], $j, $fHandle, $BinaryString, $bSize, $BinarySuffix, $VarName, $comp, $iNumberLength, $bChkContFuncName
	$Script = ";Code below was generated by: 'File to Base64 String' Code Generator " & $ver
	If $multiselect Then
		GUICtrlSetData($idLabel_SavedPerc, StringFormat("%05.2f %s", 0, "%"))
		ReDim $aStatistic[UBound($aFiles) - 1][4] ;filename, files size, compressed file size, saved %
		$iNumberLength = UBound($aFiles) - 1
		$VarName = StringRegExpReplace(GUICtrlRead($idInput_Var), "[^\w]", "")
		$bChkContFuncName = BitAND(GUICtrlRead($idCheckbox_ContFuncName), $GUI_CHECKED)
		If $VarName = "" And $bChkContFuncName Then
			_Enable_Ctrls($old_cursor)
			Return MsgBox(16 + 262144, "Error", "Function name is empty!", 30, $hGUI)
		EndIf
		For $j = 1 To UBound($aFiles) - 1
			ToolTip("Progress: " & StringFormat("%05.2f %s", 100 * $j / (UBound($aFiles) - 1), "%"), 10 + MouseGetPos(0), 20 + MouseGetPos(1))
			If FileGetSize($path & $aFiles[$j]) = 0 Then
				$aStatistic[$j - 1][0] = $aFiles[$j]
				$aStatistic[$j - 1][1] = 0
				ContinueLoop
			EndIf
			$fHandle = FileOpen($path & $aFiles[$j], 16)
			If @error Then ContinueLoop
			$BinaryString = FileRead($fHandle)
			FileClose($fHandle)
			$bSize = BinaryLen($BinaryString)
			$aStatistic[$j - 1][1] = $bSize
			$comp = $compression
			If $compression Then
				$BinaryStringComp = Compress($BinaryString)
				If BinaryLen($BinaryStringComp) > $bSize Then
					$comp = False
					$aStatistic[$j - 1][2] = $bSize
					$aStatistic[$j - 1][3] = StringFormat("%05.2f", 100 - (100 * BinaryLen($BinaryStringComp) / $bSize))
				Else
					$compressed2 = True
					$comp = True
					$aStatistic[$j - 1][2] = BinaryLen($BinaryStringComp)
					$aStatistic[$j - 1][3] = StringFormat("%05.2f", 100 - (100 * $aStatistic[$j - 1][2] / $bSize))
					$BinaryString = $BinaryStringComp
				EndIf
			Else
				$aStatistic[$j - 1][2] = $bSize
				$aStatistic[$j - 1][3] = StringFormat("%05.2f", 0)
			EndIf
			$aStatistic[$j - 1][0] = $aFiles[$j]
			$BinaryString = _Base64Encode($BinaryString)
			$BinStringLen = StringLen($BinaryString)
			$BinarySuffix = StringRight($BinaryString, Mod($BinStringLen, $LineLen))
			If $bChkContFuncName Then
				Create_Function($Script, $VarName & $j, $BinaryString, $BinStringLen, $LineLen, $comp, $BinarySuffix, $aFiles[$j], $bSize)
			Else
				$VarName = StringRegExpReplace($aFiles[$j], "[^\w]", "")
				Create_Function($Script, $VarName, $BinaryString, $BinStringLen, $LineLen, $comp, $BinarySuffix, $aFiles[$j], $bSize)
			EndIf
		Next
		$BinaryStringComp = 0
		ToolTip("")
		_GUICtrlRichEdit_SetText($hRichEdit, "")
		If Not $compressed2 Then GUICtrlSetState($idCheckbox_Compression, $GUI_UNCHECKED)
		If $decomp_function Then
			If Not $compressed2 Then
				_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode)
			Else
				Switch $iCompAlg
					Case 1
						_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode & $Decompress_LZNT_Func)
					Case 2
						_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode & $Decompress_LZMAT_Func)
				EndSwitch
			EndIf
		Else
			_GUICtrlRichEdit_InsertText($hRichEdit, $Script)
		EndIf
		Display_Statistic($aStatistic)
		If Not $compressed2 And $compression Then
			$aCoord = ControlGetPos($hGUI, "", $idCheckbox_Compression)
			$tPoint = DllStructCreate("int X;int Y")
			DllStructSetData($tPoint, "X", $aCoord[0] + 20)
			DllStructSetData($tPoint, "Y", $aCoord[1] + 12)
			_WinAPI_ClientToScreen($hGUI, $tPoint)
			ToolTip("All compressed files size exceeded original file size!" & @LF & "Compression was disabled for all files!", DllStructGetData($tPoint, "X"), DllStructGetData($tPoint, "Y"), "Warning", 2, 1)
			GUICtrlSendToDummy($dummy)
			AdlibRegister("ToolTip_Off", 7500)
		EndIf
	Else
		Local $file = $path & $aFiles[1]
		If Not FileExists($file) Then
			_Enable_Ctrls($old_cursor)
			_GUICtrlRichEdit_SetText($hRichEdit, "Ready.")
			Return MsgBox(16 + 262144, "Error", '"' & $file & '" not found!', 30, $hGUI)
		EndIf
		If FileGetSize($file) = 0 Then
			_Enable_Ctrls($old_cursor)
			_GUICtrlRichEdit_SetText($hRichEdit, "Ready.")
			Return MsgBox(16 + 262144, "Error", '"' & $file & '" is empty (0 kb)', 30, $hGUI)
		EndIf
		$VarName = StringRegExpReplace(GUICtrlRead($idInput_Var), "[^\w]", "")
		If $VarName = "" Then
			_Enable_Ctrls($old_cursor)
			Return MsgBox(16 + 262144, "Error", "Variable / function name is empty!", 30, $hGUI)
		EndIf
		$fHandle = FileOpen($file, 16)
		$BinaryString = FileRead($fHandle)
		FileClose($fHandle)
		$bSize = BinaryLen($BinaryString)
		If $compression Then
			$BinaryStringComp = Compress($BinaryString)
			$BinStringLen = BinaryLen($BinaryStringComp)
			Local $SavedPerc = 100 - (100 * $BinStringLen / $bSize)
			GUICtrlSetData($idLabel_SavedPerc, StringFormat("%05.2f %s", $SavedPerc, "%"))
			If $SavedPerc >= 0 Then
				$iLabel_Length_C_n = $BinStringLen / 1024
				GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", $iLabel_Length_C_n, "kb"))
				GUICtrlSetColor($idLabel_SavedPerc, 0x008000)
				$BinaryString = $BinaryStringComp
			Else
				$iLabel_Length_C_n = $bSize / 1024
				GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", $iLabel_Length_C_n, "kb"))
				$ToolTip = True
				$compression = False
				GUICtrlSetState($idCheckbox_Compression, $GUI_UNCHECKED)
				GUICtrlSetColor($idLabel_SavedPerc, 0x800000)
				$aCoord = ControlGetPos($hGUI, "", $idLabel_SavedPerc)
				$tPoint = DllStructCreate("int X;int Y")
				DllStructSetData($tPoint, "X", $aCoord[0] + 20)
				DllStructSetData($tPoint, "Y", $aCoord[1] + 12)
				_WinAPI_ClientToScreen($hGUI, $tPoint)
				ToolTip("Size is larger than original size!" & @LF & "Compression disabled!", DllStructGetData($tPoint, "X"), DllStructGetData($tPoint, "Y"), "Warning", 2, 1)
				GUICtrlSendToDummy($dummy)
				AdlibRegister("ToolTip_Off", 5000)
				$iCompressionUsed = -1
			EndIf
			$BinaryStringComp = 0
		Else
			GUICtrlSetData($idLabel_SavedPerc, StringFormat("%05.2f %s", 0, "%"))
			GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", 0, "kb"))
			$iCompressionUsed = -1
		EndIf
		$BinaryString = _Base64Encode($BinaryString)
		$BinStringLen = StringLen($BinaryString)
		$BinarySuffix = StringRight($BinaryString, Mod($BinStringLen, $LineLen))
		Create_Function($Script, $VarName, $BinaryString, $BinStringLen, $LineLen, $compression, $BinarySuffix, StringRegExpReplace($file, "(.+\\)(.+)", "$2"), $bSize)
		_GUICtrlRichEdit_SetText($hRichEdit, "")
		If $decomp_function Then
			If Not $compressed Then
				_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode)
			Else
				Switch $iCompAlg
					Case 1
						_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode & $Decompress_LZNT_Func)
					Case 2
						_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode & $Decompress_LZMAT_Func)
				EndSwitch
			EndIf
		Else
			_GUICtrlRichEdit_InsertText($hRichEdit, $Script)
		EndIf
	EndIf
	GUICtrlSetData($idLabel_ScriptLength_n, StringFormat("%.2f kb", BinaryLen(Binary(_GUICtrlRichEdit_GetText($hRichEdit))) / 1024))
	_Enable_Ctrls($old_cursor)
	$converted = True
EndFunc   ;==>Convert

Func Create_Function(ByRef $Script, $VarName, $BinaryString, $BinStringLen, $LineLen, $compression, $BinarySuffix, $sFile, $bSize)
	$Script &= @CRLF & @CRLF & "Func _" & $VarName & "($bSaveBinary = False, $sSavePath = @ScriptDir)" & @CRLF & @TAB & "Local $" & $VarName & @CRLF
	If $BinStringLen > $LineLen Then
		Local $aBinString = StringRegExp($BinaryString, ".{" & $LineLen & "}", 3)
		For $i = 0 To UBound($aBinString) - 1
			$Script &= @TAB & "$" & $VarName & " &= '" & $aBinString[$i] & "'" & @CRLF
		Next
		$Script &= @TAB & "$" & $VarName & " &= '" & $BinarySuffix & "'" & @CRLF
	Else
		$Script &= @TAB & "$" & $VarName & " &= '" & $BinaryString & "'" & @CRLF
	EndIf
	If Not $compression Then
		$Script &= @TAB & "Local Const $bString = Binary(_WinAPI_Base64Decode($" & $VarName & "))" & @CRLF
		$compressed = False
	Else
		$Script &= @TAB & "$" & $VarName & " = _WinAPI_Base64Decode($" & $VarName & ")" & @CRLF
		Switch $iCompAlg
			Case 1
				$Script &= @TAB & "Local $tSource = DllStructCreate('byte[' & BinaryLen($" & $VarName & ") & ']')" & @CRLF
				$Script &= @TAB & "DllStructSetData($tSource, 1, $" & $VarName & ")" & @CRLF
				$Script &= @TAB & "Local $tDecompress" & @CRLF
				$Script &= @TAB & "_WinAPI_LZNTDecompress($tSource, $tDecompress, " & $bSize & ")" & @CRLF
				$Script &= @TAB & "$tSource = 0" & @CRLF
				$Script &= @TAB & "Local Const $bString = Binary(DllStructGetData($tDecompress, 1))" & @CRLF
			Case 2
				$Script &= @TAB & "Local Const $bString = ASM_DecompressLZMAT($" & $VarName & ")" & @CRLF
		EndSwitch
		$compressed = True
	EndIf
	$Script &= @TAB & "If $bSaveBinary Then" & @CRLF
	$Script &= @TAB & @TAB & 'Local Const $hFile = FileOpen($sSavePath & "\' & $sFile & '", 18)' & @CRLF
	$Script &= @TAB & @TAB & "If @error Then Return SetError(1, 0, 0)" & @CRLF
	$Script &= @TAB & @TAB & "FileWrite($hFile, $bString)" & @CRLF
	$Script &= @TAB & @TAB & "FileClose($hFile)" & @CRLF
	$Script &= @TAB & "EndIf" & @CRLF
	$Script &= @TAB & "Return $bString" & @CRLF
	$Script &= "EndFunc   ;==>_" & $VarName
EndFunc   ;==>Create_Function

Func _Enable_Ctrls($old_cursor)
	GUICtrlSetState($idButton_Convert, $GUI_ENABLE)
	GUISetCursor($old_cursor, 1, $hGUI)
	GUISetState(@SW_ENABLE, $hGUI)
EndFunc   ;==>_Enable_Ctrls

Func Compress($binString)
	Switch $iCompAlg
		Case 1
			Local $tCompressed
			Local $tSource = DllStructCreate("byte[" & BinaryLen($binString) & "]")
			DllStructSetData($tSource, 1, $binString)
			_WinAPI_LZNTCompress($tSource, $tCompressed, $LZNT_compression_strength)
			$tSource = 0
			$iCompressionUsed = $LZNT_compression_strength
			Return DllStructGetData($tCompressed, 1)
		Case 2
			$iCompressionUsed = 2
			Return _LZMAT_Compress($binString)
	EndSwitch
EndFunc   ;==>Compress

Func ToolTip_Off()
	$ToolTip = False
	ToolTip("")
	AdlibUnRegister("ToolTip_Off")
EndFunc   ;==>ToolTip_Off

Func Load_File($file = "")
	$iLabel_Lenght_n = 0
	ToolTip("")
	If $file = "" Then
		$file = FileOpenDialog("Select any file to convert to base64 string", "", "Files (*.*)", 3 + 4, "", $hGUI)
		If @error Then Return MsgBox(64 + 262144, "Warning", "Selection has been aborted!", 20, $hGUI)
	EndIf
	_GUICtrlRichEdit_SetText($hRichEdit, "")
	Local $fSize, $c, $s
	$aFiles = StringSplit($file, "|", 2)
	If Not @error Then
		$aFiles[0] &= "\"
		For $c = 1 To UBound($aFiles) - 1
			$s += FileGetSize($aFiles[0] & $aFiles[$c])
		Next
		If $s > $limit Then Return MsgBoxEx(" No, I'm not ;-) ", 48 + 262144, "Limit of " & Round($limit / 1024 ^ 2, 2) & " MB exceeded. Crazy?", "Sum of all files: " & Round($s / 1024 ^ 2, 2) & "MB. Are you nuts to convert this size of files?", 60, $hGUI)
		$multiselect = True
		$compressed2 = False
		GUICtrlSetData($idLabel_MS_state, "True")
		If BitAND(GUICtrlRead($idCheckbox_ContFuncName), $GUI_UNCHECKED) Then
			GUICtrlSetState($idInput_Var, $GUI_DISABLE)
		Else
			GUICtrlSetState($idInput_Var, $GUI_ENABLE)
		EndIf
		$sFiles = UBound($aFiles) - 1 & " files selected!" & @LF & "Ready!"
		_GUICtrlRichEdit_SetText($hRichEdit, $sFiles)
	Else
		$fSize = FileGetSize($file)
		If $fSize > $limit Then Return MsgBoxEx(" No, I'm not ;-) ", 48 + 262144, "Limit of" & Round($limit / 1024 ^ 2, 2) & " MB exceeded. Crazy?", "Sum of all files: " & Round($fSize / 1024 ^ 2, 2) & " MB. Are you nuts to convert this size of file?", 60, $hGUI)
		ReDim $aFiles[2]
		Local $aSplit = StringRegExp($file, "(.*\\)(.*)", 3)
		$aFiles[0] = $aSplit[0]
		$aFiles[1] = $aSplit[1]
		$multiselect = False
		GUICtrlSetData($idLabel_MS_state, "False")
		GUICtrlSetState($idInput_Var, $GUI_ENABLE)
		_GUICtrlRichEdit_SetText($hRichEdit, "Ready.")
	EndIf
	If Not $multiselect Then
		$iLabel_Lenght_n = FileGetSize($file) / 1024
		GUICtrlSetData($idLabel_Lenght_n, StringFormat("%.2f %s", $iLabel_Lenght_n, "kb"))
		GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", 0, "kb"))
		GUICtrlSetData($idLabel_SavedPerc, StringFormat("%05.2f %s", 0, "%"))
	EndIf
	$Script = ""
	GUICtrlSetColor($idLabel_SavedPerc, 0x00000)

	GUICtrlSetData($idInput_File, _ArrayToString($aFiles, ",", 1))
	GUICtrlSetState($idButton_Convert, $GUI_ENABLE)
	$converted = False
	GUICtrlSetData($idLabel_ScriptLength_n, StringFormat("%.2f kb", 0))
EndFunc   ;==>Load_File

Func Save_File()
	Local $filename = FileSaveDialog("Save", "", "AutoIt Format (*.au3)", 18, "", $hGUI)
	If @error Then Return MsgBox(48 + 262144, "Warning", "Save was aborted!", 30, $hGUI)
	If StringRight($filename, 4) <> ".au3" Then $filename &= ".au3"
	Local $hFile = FileOpen($filename, 2)
	If $hFile = -1 Then Return MsgBox(16 + 262144, "Error", "Unable to create '" & $filename & "'!", 30, $hGUI)
	FileWrite($hFile, _GUICtrlRichEdit_GetText($hRichEdit))
	FileClose($hFile)
	Return MsgBox(64 + 262144, "Information", "Text was properly saved to '" & $filename & "'!", 30, $hGUI)
EndFunc   ;==>Save_File

Func Display_Statistic($array)
	GUISetState(@SW_DISABLE, $hGUI)
	Local $w = 500, $h = 600
	Local $hGUI_stat = GUICreate("Statistic", $w, $h, -1, -1, Default, Default, $hGUI)
	$hListView = _GUICtrlListView_Create($hGUI_stat, "", 0, 0, $w, $h)
	_GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_DOUBLEBUFFER, $LVS_EX_FULLROWSELECT))
	_GUICtrlListView_InsertColumn($hListView, 0, "File Name", 170)
	_GUICtrlListView_InsertColumn($hListView, 1, "File Size (bytes)", 100)
	_GUICtrlListView_InsertColumn($hListView, 2, "Compressed Size (bytes)", 130)
	_GUICtrlListView_InsertColumn($hListView, 3, "Saved (%)", 80)
	_GUICtrlListView_BeginUpdate($hListView)
	_GUICtrlListView_AddArray($hListView, $array)
	_GUICtrlListView_EndUpdate($hListView)
	GUISetState(@SW_SHOW, $hGUI_stat)
	Local $t = TimerInit()
	Local $dt = 120 * 1000
	Do
		If TimerDiff($t) > $dt Then ExitLoop
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUISetState(@SW_ENABLE, $hGUI)
	GUIDelete($hGUI_stat)
EndFunc   ;==>Display_Statistic

Func _Credits()
	GUIRegisterMsg($WM_TIMER, "")
	$bCredits = True
	GUIRegisterMsg($WM_NOTIFY, "")
	GUIRegisterMsg($WM_DROPFILES, "")
	GUIRegisterMsg($WM_SYSCOMMAND, "")
	GUICtrlSetState($idButton_Convert, $GUI_DISABLE)
	GUICtrlSetState($idButton_Clipboard, $GUI_DISABLE)
	GUICtrlSetState($idButton_File, $GUI_DISABLE)
	GUICtrlSetState($idButton_Save, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_Compression, $GUI_DISABLE)
	GUICtrlSetState($idCheckbox_DecompFunction, $GUI_DISABLE)
	GUICtrlSetState($idInput_Var, $GUI_DISABLE)

	ToolTip("")
	Opt("GUIOnEventMode", 1)
	Local $sleep = 200
	Local $save = _GUICtrlRichEdit_GetText($hRichEdit)
	_GUICtrlRichEdit_SetText($hRichEdit, "")
	_GUICtrlRichEdit_SetParaAlignment($hRichEdit, "c")
	_GUICtrlRichEdit_AppendText($hRichEdit, "{\rtf1\utf8{\colortbl;\red16\green16\blue16;}\cf1 {\fs24 {\b " & $title & $ver & "}}\cf0 \line \line }")
	Sleep($sleep)
	Local $Image_UEZ = StringMid(_Image_UEZ(), 31)
	Local $binRtf = "{\rtf1{\pict\dibitmap\picw6218\pich3149\picwgoal3525\pichgoal1785 " & $Image_UEZ & "}}"
	_GUICtrlRichEdit_AppendText($hRichEdit, @LF)
	_GUICtrlRichEdit_AppendText($hRichEdit, "{\rtf1\utf8{\colortbl;\red128\green128\blue255;}\cf1 {\fs32 {\b   Coded by}}\cf0 \line \line }")
	Sleep(1000)
	_GUICtrlRichEdit_AppendText($hRichEdit, $binRtf)
	_GUICtrlRichEdit_AppendText($hRichEdit, @LF)
	Sleep($sleep)
	_GUICtrlRichEdit_AppendText($hRichEdit, "{\rtf1\utf8{\colortbl;\red0\green128\blue0;}\cf1 {\fs28 {\i  Credits to:}}\cf0 \line \line }")
	Sleep(600)
	_GUICtrlRichEdit_SetFont($hRichEdit, 10 * $aDPI[0], "Times Roman")
	Local $text = "Ward for the _Base64Encode() / LZMAT() / MsgBoxEx() functions." & @LF & @LF & _
			"trancexx for the LZNTCompress / LZNTDecompress and _WinAPI_Base64Decode() functions!" & @LF & @LF & _
			"wraithdu for fixing bugs and advancing the code." & @LF & @LF & @LF & _
			"Press ESC to go back to code screen!"
	Local $aText = StringSplit($text, "", 2), $i
	DllCall("winmm.dll", "int", "PlaySoundW", "struct*", $tWave, "ptr", 0, "dword", BitOR($SND_ASYNC, $SND_MEMORY, $SND_NOSTOP))
	Local $fFPS = (UBound($aText) - 1) / 8.45
	Local $fSleep = 1000 / $fFPS
	Local $fTimer, $fTD, $i = 0
	Do
		$fTimer = TimerInit()

		If $i < UBound($aText) Then
			_GUICtrlRichEdit_AppendText($hRichEdit, $aText[$i])
			$i += 1
		Else
			ExitLoop
		EndIf

		$fTD = $fSleep - TimerDiff($fTimer)
		If $fTD > 0 Then
			DllCall("kernel32.dll", "none", "Sleep", "dword", $fTD)
		EndIf
	Until False

	While Not _IsPressed("1B", $hDll_user32) * Sleep(20)
	WEnd
	_GUICtrlRichEdit_SetText($hRichEdit, "")
	_GUICtrlRichEdit_SetParaAlignment($hRichEdit, "l")
	_GUICtrlRichEdit_PauseRedraw($hRichEdit)
	_GUICtrlRichEdit_SetCharColor($hRichEdit, 0x000000)
	_GUICtrlRichEdit_AppendText($hRichEdit, $save)
	_GUICtrlRichEdit_ResumeRedraw($hRichEdit)
	Opt("GUIOnEventMode", 0)

	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	GUIRegisterMsg($WM_SYSCOMMAND, "WM_SYSCOMMAND")
	GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES")
	GUIRegisterMsg($WM_TIMER, "PlayAnim")
	GUICtrlSetState($idButton_Convert, $GUI_ENABLE)
	GUICtrlSetState($idButton_Clipboard, $GUI_ENABLE)
	GUICtrlSetState($idButton_File, $GUI_ENABLE)
	GUICtrlSetState($idButton_Save, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_Compression, $GUI_ENABLE)
	GUICtrlSetState($idCheckbox_DecompFunction, $GUI_ENABLE)
	GUICtrlSetState($idInput_Var, $GUI_ENABLE)
	If $converted Then GUICtrlSetData($idLabel_ScriptLength_n, StringFormat("%.2f kb", BinaryLen(Binary(_GUICtrlRichEdit_GetText($hRichEdit))) / 1024))
	$bCredits = False
EndFunc   ;==>_Credits

Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)
	Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)
	If @error Then Return SetError(1, @extended, 0)
	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)
	If @error Then Return SetError(2, @extended, 0)
	Local $iDPI = $aResult[2]
	_GDIPlus_GraphicsDispose($hGfx)
	Local $aResults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]
	Return $aResults
EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio

Func _GDIPlus_Convert2HBitmap($hBitmap, $iColor); removes alpha backround using system color and converts to gdi bitmap
	Local $iBgColor = _WinAPI_GetSysColor($iColor)
	$iBgColor = 0x10000 * BitAND($iBgColor, 0xFF) + BitAND($iBgColor, 0x00FF00) + BitShift($iBgColor, 16)
	Local $iWidth = _GDIPlus_ImageGetWidth($hBitmap), $iHeight = _GDIPlus_ImageGetHeight($hBitmap)
	Local $aResult = DllCall($__g_hGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", 0, "int", 0x0026200A, "ptr", 0, "handle*", 0)
	Local $hBitmap_new = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight) ;$aResult[6]
	Local $hCtx_new = _GDIPlus_ImageGetGraphicsContext($hBitmap_new)
	_GDIPlus_GraphicsSetPixelOffsetMode($hCtx_new, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)
	Local $hBrush = _GDIPlus_BrushCreateSolid(0xFF000000 + $iBgColor)
	_GDIPlus_GraphicsFillRect($hCtx_new, 0, 0, $iWidth, $iHeight, $hBrush)
	_GDIPlus_GraphicsDrawImageRect($hCtx_new, $hBitmap, 0, 0, $iWidth, $iHeight)
	Local $hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap_new)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_BitmapDispose($hBitmap_new)
	_GDIPlus_GraphicsDispose($hCtx_new)
	Return $hHBITMAP
EndFunc   ;==>_GDIPlus_Convert2HBitmap

#Region WM functions
Func WM_DROPFILES($hwnd, $msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $lParam
	Local $aRet = DllCall($hDll_shell32, "int", "DragQueryFileW", "handle", $wParam, "uint", -1, "ptr", 0, "int", 0)
	If @error Or Not $aRet[0] Then Return SetError(1, 0, MsgBox(16 + 65536 + 262144, "Error", "An unexpected error has occured in Func WM_DROPFILES!", 10) * 0)

	Local $sDroppedFiles, $sPrefix, $i, $j = 0, $multipath = False, $tBuffer = DllStructCreate("wchar[260]"), $iSize = DllStructGetSize($tBuffer)
	If $aRet[0] = 1 Then
		DllCall($hDll_shell32, "int", "DragQueryFileW", "handle", $wParam, "uint", 0, "struct*", $tBuffer, "int", $iSize)
		$sDroppedFiles = DllStructGetData($tBuffer, 1)

		If StringInStr(FileGetAttrib($sDroppedFiles), "D") Then
			DllCall($hDll_shell32, "none", "DragFinish", "handle", $wParam)
			Return MsgBox(16 + 262144, "Error", "No support for folders yet!", 20, $hGUI)
		EndIf
	Else
		For $i = 0 To $aRet[0] - 1
			DllCall($hDll_shell32, "int", "DragQueryFileW", "handle", $wParam, "uint", $i, "struct*", $tBuffer, "int", $iSize)
			If Not StringInStr(FileGetAttrib(DllStructGetData($tBuffer, 1)), "D") Then
				If Not $j Then
					$sPrefix = StringRegExpReplace(DllStructGetData($tBuffer, 1), "(.+)\\.*", "$1") & "|"
				EndIf
				If StringRegExpReplace(DllStructGetData($tBuffer, 1), "(.+)\\.*", "$1") & "|" = $sPrefix Then
					$sDroppedFiles &= StringRegExpReplace(DllStructGetData($tBuffer, 1), ".+\\(.*)", "$1") & "|"
					$j += 1
				Else
					$multipath = True
				EndIf
			EndIf
		Next
		If Not $j Then
			DllCall($hDll_shell32, "none", "DragFinish", "handle", $wParam)
			Return MsgBox(64 + 262144, "Warning", "No files were added!", 20, $hGUI)
		EndIf

		$sDroppedFiles = $sPrefix & $sDroppedFiles

		If $multipath Then MsgBox(64 + 262144, "Warning", "No support for files from different pathes currently." & @CRLF & _
				"Added files from first path only!", 20, $hGUI)
		$sDroppedFiles = StringTrimRight($sDroppedFiles, 1)
	EndIf
	DllCall($hDll_shell32, "none", "DragFinish", "handle", $wParam)
	$tBuffer = 0
	If $sDroppedFiles <> "" Then Load_File($sDroppedFiles)
	WinActivate($hGUI)
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>WM_DROPFILES

Func WM_ACTIVATEAPP($hwnd, $msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $lParam
	If Not $wParam Then ;GUI lost focus
		$ToolTip = False
		ToolTip("")
	EndIf
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>WM_ACTIVATEAPP

Func WM_NOTIFY($hwnd, $msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $wParam
	If IsHWnd($hListView) Then
		$hWndListView = $hListView
	Else
		$hWndListView = GUICtrlGetHandle($hListView)
	EndIf
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $NM_CUSTOMDRAW
					Local $tCustDraw = DllStructCreate($tagNMLVCUSTOMDRAW, $lParam)
					Local $iDrawStage = DllStructGetData($tCustDraw, "dwDrawStage")
					If $iDrawStage = $CDDS_PREPAINT Then Return $CDRF_NOTIFYITEMDRAW
					If $iDrawStage = $CDDS_ITEMPREPAINT Then Return $CDRF_NOTIFYSUBITEMDRAW
					Local $iItem = DllStructGetData($tCustDraw, "dwItemSpec")
					Local $iSubItem = DllStructGetData($tCustDraw, "iSubItem")
					Local $iColor = 0x000000
					If $iSubItem = 3 Then
						If $aStatistic[$iItem][$iSubItem] < 0 Then
							$iColor = 0x0000C0
							Local $hDC = DllStructGetData($tCustDraw, "hdc")
							Local $FORMATLV_hFONT = _WinAPI_CreateFont(14, 0, 0, 0, $FW_BOLD, False, False, False, _
								  $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $DEFAULT_QUALITY, 0)
							_WinAPI_SelectObject($hDC, $FORMATLV_hFONT)
							_WinAPI_DeleteObject($FORMATLV_hFONT)
						Else
							$iColor = 0x00C000
						EndIf
					EndIf
					DllStructSetData($tCustDraw, "clrText", $iColor)

			EndSwitch
		Case $hRichEdit
			Switch $iCode
				Case $EN_MSGFILTER
					Local $tMsgFilter = DllStructCreate($tagEN_MSGFILTER, $lParam)
					If DllStructGetData($tMsgFilter, "msg") = $WM_RBUTTONUP Then
						_GUICtrlMenu_TrackPopupMenu($hPopupMenu, $hwnd)
						Return 1
					EndIf
			EndSwitch
	EndSwitch
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>WM_NOTIFY

Func WM_COMMAND($hwnd, $msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $lParam
	If $wParam = 0x04002710 Or $bCredits Then Return "GUI_RUNDEFMSG" ;no update when vertical scrollbar is used or credits function is running
	If $converted Then
		If $multiselect Then
			SetRichText($compressed2, $wParam)
		Else
			SetRichText($compressed, $wParam)
		EndIf
	EndIf
	Switch $wParam
		Case $id_LZNT_Standard
			_GUICtrlMenu_CheckRadioItem($hQMenu_Sub1, 0, 1, 0)
			$LZNT_compression_strength = 0
			_GUICtrlMenu_CheckMenuItem($hQMenu, 0, 1)
			_GUICtrlMenu_CheckMenuItem($hQMenu, 1, 0)
			$iCompAlg = 1
			_GUICtrlRichEdit_SetText($hRichEdit, "")
			GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", 0, "kb"))
		Case $id_LZNT_High
			_GUICtrlMenu_CheckRadioItem($hQMenu_Sub1, 0, 1, 1)
			$LZNT_compression_strength = 1
			_GUICtrlMenu_CheckMenuItem($hQMenu, 0, 1)
			_GUICtrlMenu_CheckMenuItem($hQMenu, 1, 0)
			$iCompAlg = 1
			_GUICtrlRichEdit_SetText($hRichEdit, "")
			GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", 0, "kb"))
		Case $id_LZMAT
			_GUICtrlMenu_CheckMenuItem($hQMenu, 0, 0)
			_GUICtrlMenu_CheckMenuItem($hQMenu, 1, 1)
			_GUICtrlMenu_CheckMenuItem($hQMenu_Sub1, 0, False)
			_GUICtrlMenu_CheckMenuItem($hQMenu_Sub1, 1, False)
			$iCompAlg = 2
			_GUICtrlRichEdit_SetText($hRichEdit, "")
			GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", 0, "kb"))
		Case $id_Copy
			Local $e = False
			Local $marked_txt = _GUICtrlRichEdit_GetSelText($hRichEdit)
			If $marked_txt = -1 Then
				$marked_txt = _GUICtrlRichEdit_GetText($hRichEdit)
				If $marked_txt = "" Or $marked_txt = "Ready." Then
					$e = True
				Else
					ClipPut($marked_txt)
				EndIf
			Else
				ClipPut($marked_txt)
			EndIf
			If Not $e Then
				_GUICtrlRichEdit_SetBkColor($hRichEdit, 0x00FF00)
				Sleep(100)
				_GUICtrlRichEdit_SetBkColor($hRichEdit, $RE_BgColor)
			EndIf
	EndSwitch
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>WM_COMMAND

Func SetRichText($mode, $wParam)
	Switch $mode
		Case False ;no compression encoded
			Switch $wParam
				Case $idCheckbox_Compression
					If BitAND(GUICtrlRead($idCheckbox_Compression), $GUI_CHECKED) Then
						_GUICtrlRichEdit_SetText($hRichEdit, "")
						GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", 0, "kb"))
					Else
						If BitAND(GUICtrlRead($idCheckbox_DecompFunction), $GUI_UNCHECKED) Then
							_GUICtrlRichEdit_InsertText($hRichEdit, $Script)
						Else
							_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode)
						EndIf
						GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", $iLabel_Length_C_n, "kb"))
					EndIf
				Case $idCheckbox_DecompFunction
					_GUICtrlRichEdit_SetText($hRichEdit, "")
					If BitAND(GUICtrlRead($idCheckbox_Compression), $GUI_UNCHECKED) Then
						If BitAND(GUICtrlRead($idCheckbox_DecompFunction), $GUI_CHECKED) Then
							_GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode)
						Else
							_GUICtrlRichEdit_InsertText($hRichEdit, $Script)
						EndIf
					EndIf
					GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", $iLabel_Length_C_n, "kb"))
			EndSwitch
		Case True ;with compression encoded
			Switch $wParam
				Case $idCheckbox_Compression
					If BitAND(GUICtrlRead($idCheckbox_Compression), $GUI_UNCHECKED) Then
						_GUICtrlRichEdit_SetText($hRichEdit, "")
						GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", 0, "kb"))
					Else
						If BitAND(GUICtrlRead($idCheckbox_DecompFunction), $GUI_UNCHECKED) Then
							If $iCompAlg = $iCompressionUsed Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script)
						Else
							Switch $iCompAlg
								Case 0
									If $iCompressionUsed = 0 Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Decompress_LZNT_Func)
								Case 1
									If $iCompressionUsed = 1 Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Decompress_LZNT_Func)
								Case 2
									If $iCompressionUsed = 2 Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Decompress_LZMAT_Func)
							EndSwitch
						EndIf
						GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", $iLabel_Length_C_n, "kb"))
					EndIf
				Case $idCheckbox_DecompFunction
					If BitAND(GUICtrlRead($idCheckbox_Compression), $GUI_CHECKED) Then
						_GUICtrlRichEdit_SetText($hRichEdit, "")
						If BitAND(GUICtrlRead($idCheckbox_DecompFunction), $GUI_UNCHECKED) Then
							If $iCompAlg = $iCompressionUsed Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script)
						Else
							Switch $iCompAlg
								Case 0
									If $iCompressionUsed = 0 Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode & $Decompress_LZNT_Func)
								Case 1
									If $iCompressionUsed = 1 Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode & $Decompress_LZNT_Func)
								Case 2
									If $iCompressionUsed = 2 Then _GUICtrlRichEdit_InsertText($hRichEdit, $Script & $Script_Base64Decode & $Decompress_LZMAT_Func)
							EndSwitch
						EndIf
						GUICtrlSetData($idLabel_Length_C_n, StringFormat("%.2f %s", $iLabel_Length_C_n, "kb"))
					EndIf
			EndSwitch
	EndSwitch
	If $converted Then GUICtrlSetData($idLabel_ScriptLength_n, StringFormat("%.2f kb", BinaryLen(Binary(_GUICtrlRichEdit_GetText($hRichEdit))) / 1024))
EndFunc   ;==>SetRichText

Func WM_CONTEXTMENU($hwnd, $msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $wParam, $lParam
	Local $mi = GUIGetCursorInfo()
	If (Not @error) Then
		Switch $mi[4]
			Case $idCheckbox_Compression
				_GUICtrlMenu_TrackPopupMenu($hQMenu, $hwnd)
				Return True
		EndSwitch
	EndIf
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>WM_CONTEXTMENU

Func WM_MOVING($hwnd, $msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $wParam, $lParam
	Local $iX, $iY
	If $ToolTip Then
		$aCoord = ControlGetPos($hGUI, "", $idLabel_SavedPerc)
		$tPoint = DllStructCreate("int X;int Y")
		DllStructSetData($tPoint, "X", $aCoord[0] + 20)
		DllStructSetData($tPoint, "Y", $aCoord[1] + 12)
		_WinAPI_ClientToScreen($hGUI, $tPoint)
		$iX = DllStructGetData($tPoint, "X")
		$iY = DllStructGetData($tPoint, "Y")
		If $iX <> $Prev_Coord[0] Or $iY <> $Prev_Coord[1] Then
			ToolTip("Size is larger than original size!" & @LF & "Compression disabled!", $iX, $iY, "Warning", 2, 1)
			GUICtrlSendToDummy($dummy)
			$Prev_Coord[0] = $iX
			$Prev_Coord[1] = $iY
		EndIf
		$tPoint = 0
	EndIf
EndFunc   ;==>WM_MOVING

Func WM_SYSCOMMAND($hwnd, $msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $lParam
	Local $idFrom
	$idFrom = BitAND($wParam, 0x0000FFFF)
	Switch $idFrom
		Case $id_About
			_Credits()
	EndSwitch
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>WM_SYSCOMMAND
#EndRegion WM functions

#Region additional functions
Func MsgBoxEx($CustomButton, $Flag, $title, $text, $Timeout = 0, $hwnd = 0) ;thanks to Ward
	Assign("MsgBoxEx:CustomButton", $CustomButton, 2)
	Local $CBT_ProcCB = DllCallbackRegister("MsgBoxEx_CBT_Proc", "long", "int;hwnd;lparam")
	Local $CBT_Hook = _WinAPI_SetWindowsHookEx($WH_CBT, DllCallbackGetPtr($CBT_ProcCB), 0, _WinAPI_GetCurrentThreadId())
	Local $Ret = MsgBox($Flag, $title, $text, $Timeout, $hwnd)
	Local $Error = @error
	_WinAPI_UnhookWindowsHookEx($CBT_Hook)
	DllCallbackFree($CBT_ProcCB)
	Assign("MsgBoxEx:CustomButton", 0, 2)
	Return SetError($Error, 0, $Ret)
EndFunc   ;==>MsgBoxEx

Func MsgBoxEx_CBT_Proc($nCode, $wParam, $lParam) ;thanks to Ward
	If $nCode = 5 Then ; HCBT_ACTIVATE
		Local $CustomButton = StringSplit(Eval("MsgBoxEx:CustomButton"), "|")
		For $i = 1 To $CustomButton[0]
			ControlSetText($wParam, "", $i, $CustomButton[$i])
		Next
	EndIf
	Return _WinAPI_CallNextHookEx(0, $nCode, $wParam, $lParam)
EndFunc   ;==>MsgBoxEx_CBT_Proc

Func _WinAPI_Base64Decode($sB64String) ;code by trancexx
	Local $a_Call = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
	If @error Or Not $a_Call[0] Then Return SetError(1, 0, "")
	Local $a = DllStructCreate("byte[" & $a_Call[5] & "]")
	$a_Call = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $a, "dword*", $a_Call[5], "ptr", 0, "ptr", 0)
	If @error Or Not $a_Call[0] Then Return SetError(2, 0, "")
	Return DllStructGetData($a, 1)
EndFunc   ;==>_WinAPI_Base64Decode

; #FUNCTION# ====================================================================================================================
; Name...........: 	_WinAPI_LZNTCompress
; Description....: 	Compresses an input data.
; Syntax.........: 	_WinAPI_LZNTCompress ( $tInput, ByRef $tOutput [, $fMaximum] )
; Parameters.....: 	$tInput   - "byte[n]" or any other structure that contains the data to be compressed.
;                  			$tOutput  - "byte[n]" structure that is created by this function, and contain the compressed data.
;                  			$fMaximum - Specifies whether use a maximum data compression, valid values:
;                  			|TRUE     - Uses an algorithm which provides maximum data compression but with relatively slower performance.
;                  			|FALSE    - Uses an algorithm which provides a balance between data compression and performance. (Default)
; Return values..:	Success   - The size of the compressed data, in bytes.
;                  			Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the NTSTATUS code.
; Author.........: 	trancexx
; Modified.......: 	Yashied, UEZ
; Remarks........: 	The input and output buffers must be different, otherwise, the function fails.
; Related........:
; Link...........: 		@@MsdnLink@@ RtlCompressBuffer
; Example........: 	Yes
; ===============================================================================================================================
Func _WinAPI_LZNTCompress(ByRef $tInput, ByRef $tOutput, $fMaximum = True)
	Local $tBuffer, $tWorkSpace, $Ret
	Local $COMPRESSION_FORMAT_LZNT1 = 0x0002, $COMPRESSION_ENGINE_MAXIMUM = 0x0100
	If $fMaximum Then $COMPRESSION_FORMAT_LZNT1 = BitOR($COMPRESSION_FORMAT_LZNT1, $COMPRESSION_ENGINE_MAXIMUM)
	$tOutput = 0
	$Ret = DllCall("ntdll.dll", "uint", "RtlGetCompressionWorkSpaceSize", "ushort", $COMPRESSION_FORMAT_LZNT1, "ulong*", 0, "ulong*", 0)
	If @error Then Return SetError(1, 0, 0)
	If $Ret[0] Then Return SetError(2, $Ret[0], 0)
	$tWorkSpace = DllStructCreate("byte[" & $Ret[2] & "]")
	$tBuffer = DllStructCreate("byte[" & (2 * DllStructGetSize($tInput)) & "]")
	$Ret = DllCall("ntdll.dll", "uint", "RtlCompressBuffer", "ushort", $COMPRESSION_FORMAT_LZNT1, "struct*", $tInput, "ulong", DllStructGetSize($tInput), "struct*", $tBuffer, "ulong", DllStructGetSize($tBuffer), "ulong", 4096, "ulong*", 0, "struct*", $tWorkSpace)
	If @error Then Return SetError(3, 0, 0)
	If $Ret[0] Then Return SetError(4, $Ret[0], 0)
	$tOutput = DllStructCreate("byte[" & $Ret[7] & "]")
	If Not _WinAPI_MoveMemory(DllStructGetPtr($tOutput), DllStructGetPtr($tBuffer), $Ret[7]) Then
		$tOutput = 0
		Return SetError(5, 0, 0)
	EndIf
	Return $Ret[7]
EndFunc   ;==>_WinAPI_LZNTCompress

;~ Func _WinAPI_MoveMemory($pDestination, $pSource, $iLength)
;~ 	DllCall("ntdll.dll", "none", "RtlMoveMemory", "ptr", $pDestination, "ptr", $pSource, "ulong_ptr", $iLength)
;~ 	If @error Then Return SetError(1, 0, 0)
;~ 	Return 1
;~ EndFunc   ;==>_WinAPI_MoveMemory

Func _Base64EncodeInit($LineBreak = 76) ;code by Ward
	If Not IsDllStruct($_B64E_CodeBuffer) Then
		Local $Opcode
		If @AutoItX64 Then
			$Opcode = "0x89C08D42034883EC0885D2C70100000000C64104000F49C2C7410800000000C1F80283E20389410C740683C00189410C4883C408C389C94883EC3848895C242848897424304889CB8B0A83F901742083F9024889D87444C6000A4883C001488B74243029D8488B5C24284883C438C30FB67204E803020000BA3D0000004080FE3F7F08480FBEF60FB614308813C643013D488D4303C643023DEBBC0FB67204E8D7010000BA3D0000004080FE3F7F08480FBEF60FB614308813C643013D488D4302EB9489DB4883EC68418B014863D248895C242848897424304C89C348897C24384C896424484C89CE83F80148896C24404C896C24504C897424584C897C24604C8D2411410FB6790474434D89C64989CD0F82F700000083F8024C89C5747B31C0488B5C2428488B742430488B7C2438488B6C24404C8B6424484C8B6C24504C8B7424584C8B7C24604883C468C34C89C54989CF4D39E70F840B010000450FBE374D8D6F014489F025F0000000C1F80409C7E8040100004080FF3FBA3D0000007F08480FBEFF0FB614384489F78855004883C50183E70FC1E7024D39E50F84B2000000450FB675004983C5014489F025C0000000C1F80609C7E8BD0000004080FF3FBA3D0000007F08480FBEFF0FB61438BF3F0000008855004421F74C8D7502E896000000480FBED70FB604108845018B460883C0013B460C89460875104C8D7503C645020AC7460800000000904D39E5742E410FBE7D004D8D7D01498D6E01E8560000004889FA83E70348C1EA02C1E70483E23F0FB60410418806E913FFFFFF4489F040887E04C7060000000029D8E9CCFEFFFF89E840887E04C7060200000029D8E9B9FEFFFF89E840887E04C7060100000029D8E9A6FEFFFFE8400000004142434445464748494A4B4C4D4E4F505152535455565758595A6162636465666768696A6B6C6D6E6F707172737475767778797A303132333435363738392B2F58C3"
		Else
			$Opcode = "0x89C08B4C24088B44240489CAC1FA1FC1EA1E01CAC1FA0283E103C70000000000C6400400C740080000000089500C740683C20189500CC2100089C983EC0C8B4C2414895C24048B5C2410897424088B1183FA01741D83FA0289D87443C6000A83C0018B74240829D88B5C240483C40CC210000FB67104E80C020000BA3D00000089F180F93F7F0989F20FBEF20FB6143088138D4303C643013DC643023DEBBD0FB67104E8DF010000BA3D00000089F180F93F7F0989F20FBEF20FB6143088138D4302C643013DEB9489DB83EC3C895C242C8B5C244C896C24388B542440897424308B6C2444897C24348B030FB6730401D583F801742D8B4C24488954241C0F820101000083F80289CF747D31C08B5C242C8B7424308B7C24348B6C243883C43CC210008B4C244889D739EF0F84400100008D57010FBE3F89542418894C241489F825F0000000C1F80409C6897C241CE8330100008B542418C644240C3D8B4C241489C789F03C3F7F0B0FBEF00FB604378844240C0FB644240C8D790188018B74241C83E60FC1E60239EA0F84CB0000000FB60A83C2018954241C89C825C0000000C1F80609C6884C2414E8D8000000BA3D0000000FB64C24148944240C89F03C3F7F0B0FBEF08B44240C0FB6143083E13F881789CEE8AD00000089F10FBED18D4F020FB604108847018B430883C0013B430C894308750EC647020A8D4F03C7430800000000396C241C743A8B44241C8B7C241C0FBE30894C241483C701E8650000008B4C241489F283E60381E2FC000000C1EA02C1E6040FB60410880183C101E9E4FEFFFF89F088430489C8C703000000002B442448E9B2FEFFFF89F189F8884B04C703020000002B442448E99CFEFFFF89F088430489C8C703010000002B442448E986FEFFFFE8400000004142434445464748494A4B4C4D4E4F505152535455565758595A6162636465666768696A6B6C6D6E6F707172737475767778797A303132333435363738392B2F58C3"
		EndIf
		$_B64E_Init = (StringInStr($Opcode, "89C0") + 1) / 2
		$_B64E_EncodeData = (StringInStr($Opcode, "89DB") + 1) / 2
		$_B64E_EncodeEnd = (StringInStr($Opcode, "89C9") + 1) / 2
		$Opcode = Binary($Opcode)

		$_B64E_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_B64E_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_B64E_CodeBufferMemory)
		DllStructSetData($_B64E_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_B64E_Exit")
	EndIf

	Local $State = DllStructCreate("byte[16]")
	DllCallAddress("none", DllStructGetPtr($_B64E_CodeBuffer) + $_B64E_Init, "struct*", $State, "uint", $LineBreak, "int", 0, "int", 0)
	Return $State
EndFunc   ;==>_Base64EncodeInit

Func _Base64EncodeData(ByRef $State, $Data) ;code by Ward
	If Not IsDllStruct($_B64E_CodeBuffer) Or Not IsDllStruct($State) Then Return SetError(1, 0, "")
	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	Local $OutputLen = Ceiling(BinaryLen($Data) * 1.4) + 3
	Local $Output = DllStructCreate("char[" & $OutputLen & "]")
	DllCallAddress("int", DllStructGetPtr($_B64E_CodeBuffer) + $_B64E_EncodeData, "struct*", $Input, "uint", $InputLen, "struct*", $Output, "struct*", $State)
	Return DllStructGetData($Output, 1)
EndFunc   ;==>_Base64EncodeData

Func _Base64EncodeEnd(ByRef $State) ;code by Ward
	If Not IsDllStruct($_B64E_CodeBuffer) Or Not IsDllStruct($State) Then Return SetError(1, 0, "")
	Local $Output = DllStructCreate("char[5]")
	DllCallAddress("int", DllStructGetPtr($_B64E_CodeBuffer) + $_B64E_EncodeEnd, "struct*", $Output, "struct*", $State, "int", 0, "int", 0)
	Return DllStructGetData($Output, 1)
EndFunc   ;==>_Base64EncodeEnd

Func _Base64Encode($Data, $LineBreak = 0) ;code by Ward - modified by UEZ
	Local $State = _Base64EncodeInit($LineBreak)
	Return StringReplace(StringStripCR(_Base64EncodeData($State, $Data) & _Base64EncodeEnd($State)), @LF, "")
EndFunc   ;==>_Base64Encode

Func _B64E_Exit() ;code by Ward
	$_B64E_CodeBuffer = 0
	_MemVirtualFree($_B64E_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc   ;==>_B64E_Exit

Func _WinAPI_LZNTDecompress(ByRef $tInput, ByRef $tOutput, $iBufferSize = 0x40000)
	Local $tBuffer, $Ret
	$tOutput = 0
	$tBuffer = DllStructCreate("byte[" & $iBufferSize & "]")
	If @error Then Return SetError(1, 0, 0)
	$Ret = DllCall("ntdll.dll", "uint", "RtlDecompressBuffer", "ushort", 0x0002, "struct*", $tBuffer, "ulong", $iBufferSize, "struct*", $tInput, "ulong", DllStructGetSize($tInput), "ulong*", 0)
	If @error Then Return SetError(2, 0, 0)
	If $Ret[0] Then Return SetError(3, $Ret[0], 0)
	$tOutput = DllStructCreate("byte[" & $Ret[6] & "]")
	If Not _WinAPI_MoveMemory(DllStructGetPtr($tOutput), DllStructGetPtr($tBuffer), $Ret[6]) Then
		$tOutput = 0
		Return SetError(4, 0, 0)
	EndIf
	Return $Ret[6]
EndFunc   ;==>_WinAPI_LZNTDecompress

Func WinAPI_GUICtrlMenu_CreateBitmap($file, $iIndex = 0, $iW = 16, $iH = 16) ;thanks to Yashied
	If FileExists($file) Then
		Local $aRet, $hIcon, $hHBITMAP
		Local $hDC, $hBackDC, $hBackSv

;~ 		$aRet = DllCall("shell32", "long", "ExtractAssociatedIcon", "int", 0, "str", $file, "word*", $iIndex)
;~ 		If @error Then Return SetError(@error, @extended, 0)
;~ 		$hIcon = $aRet[0]
		$aRet = DllCall($hDll_shell32, "int", "SHExtractIconsW", "wstr", $file, "int", $iIndex, "int", $iW, "int", $iH, "ptr*", 0, "ptr*", 0, "int", 1, "int", 0)
		If @error Then Return SetError(@error, @extended, 0)
		$hIcon = $aRet[5]

		$hDC = _WinAPI_GetDC(0) ;thanks to Yashied
		$hBackDC = _WinAPI_CreateCompatibleDC($hDC)
		$hHBITMAP = _WinAPI_CreateSolidBitmap(0, _WinAPI_GetSysColor($COLOR_MENU), $iW, $iW)
		$hBackSv = _WinAPI_SelectObject($hBackDC, $hHBITMAP)
		_WinAPI_DrawIconEx($hBackDC, 0, 0, $hIcon, $iW, $iW, 0, 0, 3)
		_WinAPI_DestroyIcon($hIcon)

		_WinAPI_SelectObject($hBackDC, $hBackSv)
		_WinAPI_ReleaseDC(0, $hDC)
		_WinAPI_DeleteDC($hBackDC)
		Return $hHBITMAP
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>WinAPI_GUICtrlMenu_CreateBitmap

Func _LZMAT_Compress($Data)
	If Not IsDllStruct($_LZMAT_CodeBuffer) Then _LZMAT_Startup()

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Return BinaryMid(Binary($InputLen), 1, 4) & _LZMAT_Compress_Core($Data)
EndFunc   ;==>_LZMAT_Compress

Func _LZMAT_Compress_Core($Data)
	If Not IsDllStruct($_LZMAT_CodeBuffer) Then _LZMAT_Startup()

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)

	Local $OutputLen = $InputLen + 1024
	Local $Output = DllStructCreate("byte[" & $OutputLen & "]")
	Local $Buffer = DllStructCreate("byte[262144]")

	Local $Ptr = DllStructCreate("ptr src; ptr dst; ptr buf")
	DllStructSetData($Ptr, 'src', DllStructGetPtr($Input))
	DllStructSetData($Ptr, 'dst', DllStructGetPtr($Output))
	DllStructSetData($Ptr, 'buf', DllStructGetPtr($Buffer))

    Local $Ret = DllCallAddress("uint", DllStructGetPtr($_LZMAT_CodeBuffer) + $_LZMAT_Compress, "struct*", $Ptr, "uint", $InputLen, _
            "uint*", $OutputLen, "int", 0)

	Return BinaryMid(DllStructGetData($Output, 1), 1, $Ret[3])
EndFunc   ;==>_LZMAT_Compress_Core

Func _LZMAT_Startup()
	If Not IsDllStruct($_LZMAT_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Code = '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'
			$Code &= '5/o1kEQsAf7ChQJKEWf+KPU06QsjULCtlHGUMyrwiJMbCggKTje0+TgXdGmQGXisYu9BxgKaIwr4HApKAQw/fMgSArJnA8oeSdHJqVNxagiueGUCImaKKhdshPB5iEkCHQnGQAMYF+nk0TdpgoAK8OuH/JE5agKytTp0np6Md2oBNUARWlgo5ukqCBEPM8DqFFEU4sX7H0lHQRVGyjMdg+gB5l6gi9M1J/HokAOWAfx2ZkGJJMMQiQIWuiDb/YIUHMFqySVhq4Q/EoD5Ib0MLCkZJjioUnA8/SgzlwEgZ+l9+kmBIKC0SwEvhHYkd/kuc1LVL4gDxlvdTLhpnpUVrlgn0tgHBqF6VvdwlLTPoJJ25AaLKogBuFfhaNsouwhkkD30gC3PKfdMOUUXg6RCPEWE5GmqAgGJ34M5dDgBRS4MLEkU5osYwO0ICfUwg8MkMfbrGC6J3jNUMPudSzS61JpAOsDuDkQJ1uWIN6HSnU1B2MYJ/ggfdJxF1O1noN92jOjoIHOIFu14FBrh3UCvPDk0dbGeRUnrwDOA0IQkEmvC5TiHZDxswO9VBGiYGv/Q1z2Uv0e3v8aGuFuA7/qDMecDPuoC3f/PO4A1wZASAyFgkAEpOdKgg1TWthyYWinmP54MgPQ1rpzBR+OdCEYCHEO1BcMDOcaC9fR5oBo8GGDxgnnegRnF2iZt6RmJwkbrjn4p8qoMCSAYRQ6cvNeaxiJiGCSvOZAFRYXbkA70MXZ1sTmh0KG2oM9Bt5W+SEs/+hTR6rtEiKKLuvOtooQEl+AwB6Sx8Mb1KK6aJBq4YaVSQDXA6wSRHIq227VjhUtlKx3UBa18GgWXOfkOr+nyMcp0ZSdGEbZc1CMS4wQlSgtC30Omp/KB+1oPKnRQ9EQShmkMl24oN7gEjZ+pwxjrLDDTqDNh1hKn5n9lRwVE6bcp2xQSMVB1sGCmVDoaAtoCuIKBAW5VeSOErdLKzbsNjZ8RTZmcApMQdecB3HP+FAg/JJ+NmvzUTHOjIt7TkJgYBb9/EUQhUO/8PnQEJDQ/sBD4jRJdaLEkJ5wDdiOD7unrB7ILGRdBcdoxdoGIBEeLFBAsbWhG0TzMfyziHYvp8ajvXg6NsmoEqsjRi+nXKl+X0QMJB/nqHkS5Qo10HoCvOfFyf6I9r6rpHxgxHDB1vqaa+0OlDh2qtDIng0TpiGhjPsVSGmVkO6kF9olT69UaI5FKwyILSDvNuBQ4vvLDsAuJAjMxwB+4vj8769/2oQfYYkoFt3Qw+wqswICLAfaIoUIRAx3rvNQQBxe1VwyMzwbQlQD+/POqX2DDAA=='
		Else
			Local $Code = 'Uw8AAIkAwIPsLItEJDDoUHwId1R7EMwINBEM/+syDQgdOCcE50A//X+c6DUwAoPELDjCEH5k224cXHz02VkIIJERCCIsRAQooy+qChEcEFVXVgxTgeyMf4sZnCSwD8eyXwwEjgis/wOJbhxejA4/hPCgi7uU+qSFB4wjDrTyqCGDwAHpvFYRy3tMOwKNBwHfg8F8G3zp/wHkD7YGiAeL07i3FsbAJEv/wegJHQHQJdh/2QSD3GkUMepkfKxAAQ+GAwSpZKgJopmGNlgBGXNnX87CvKdAyhlgERQ/BSFLDS+AUe+FZ776CGRUchiKQCuUeLREZSuhkhhMYgPeLM6D+dWkMSD0dgEQCo1yHP87Sv8MhFcGHXTBPoHuP0RHk2Z8FIAIGcAK99AhxskBAsHpCYmCPByNBAGYyYs8A4M5/g+POvUythhOFzE5x1RMBkHVjSJIGHiiUSSSMDJcS88wGDgxIIPuZwGdcHXoJ+CT6yroy4tMyj34XEOEgTYKApo0YxzEyAMzr/ikwBwRidmZx6U4gMocPmY5y3VVyaYDyAEYurkOC3cM3znOhfattJnr4qyYkgH9kIxwRQk6AnWfBXRmQ4JS6xB3Ig4FAYPpbzrOAup11QHwhcmNcIwS6Tt6MNqyRY8Z80QGi2zSiEygo8UBKfkfOfVysdkYgDQpdm8LN8DB5Qc56SlyDwsQA3oxgztrgf5JiROfAqCHpQeSb1OEhVVv46a/hP4o6RNddwo1kf4OKRoi9CQ7Fol2BBkc+J19GSBmgOQ/miqE7vqBtAJQ3SjB4AYECAaJ9R2Il8Do+oh2RlC4QdChhy+kUtRsTETUglZmIijlbyAq3yKKuwfk/6bHNJhDwBgcdgW+N99ZisYB4pIYGxlVt6Q0wL7PgeeRgAHB7glmA6Qe5ImB5hiQLLM5iQzM339AORj0rEi7nYV1z0KrHDmEZmGhMh5CZlTGe9tEELDpgf2r5nu6kF0SD5XBRztE+PgBic52CISKIoUi3aB6kplpWOoQjSnH8OnKHUDzkks2L0pv2KdK8S8IJQQWgwY6OXwvPocY1uVI8KQi5vbKIEB1hA3UNxtlektd8InB4Q8rtQ4YwOkUTwGRTY+NfRJAACh0BMZF80mC8TlirQqD6gU5RD+ZOubHZhmIKmBCgbxJrIsigSwYyqgb9VfqqbCqDIM5iTTJSBqB4h4ajMSJ6eCMk5nBqx6Nh+KBE4AvFBaFsKTNVK3VRIPh4gGF0iMqfZVLk3I7iBEutHJiK4QZA3LCBQaBxIzMOFsJXl9dw5SLoHhBApHzpIQS5hWvHzU/JCI3gYgLVD8ULgIOyESEh+EDTu4JESJPzgJuXiZmBCBsxvGRMrUPHy8T/RAD2gnFAogNNyCyClZ0CYMy+BExoKu9PRDyhk3ZtxmNSO5tgyGkFU0xuIRdisuITZZpLKWSCNmHHunbLmuLAqYqJBqIgXwkEKazERsJRDnPmKuGNZInicZUE/tNi1wqRJofQMHtbFI6C41V/IZ81WmBwuJDOyWC/MkiysgJwppwwe62B4Pg1YjWpYhfRNViAZlRQRjiBIlCiBdrHt2RL0cBSAoMgkHuwlLXX2s3tNiOQJieSMZPQYHVBZ0OA/IIBC9qD4GkowDwjTzvAe2xOgJ0IIu8zNNI6ow0AzmDAgffNQaFKwsF6oVE8gmirmoQUh7d+vMXKCXhHBa/iatAki1YmsclIB6/E+ml/ElsfGpDBaL9FNFDTeKG6RkxrrMhNQFi7gROttRZrWpbq1iHVVP+MVCl/ZOaGBRxg+HwiExN7cUvCJAc6cL71d+rEwH2IEB/dpyaIPkJ1hPUCjRtWAiI29SYzs/F2+uZSdxACppmh4nGZjQQgzkEsMdAAtmeDAYlyPvUssIL6bv+mAkguEoKCRqDgVyB+QuLE3cPpxmEBQLN/GDy6JBpB7ZKBDpOPC7sSAENzzDRKLkFDIne6w08HGsKSo6ywv91B+iJhcDu7KnUMNHzOQfD6bj6VOtFAbsNCoXz2awNxHQBiA7p/KMhyCorVQ/DSZHU6dFS'
			$Code &= '/id8kUgoGcQx6d+KOQN0d42I71gbLXDqiaQjkCShGg8y0SwBdmp/IAxNAuyIAxEMjZ1rWqFq5KNJslERd1oWbQJAg8rwiFZAKkYDpA6gQ+m+0DV3jICU8LqooVCJssR4BJCC6UOvryGF5gG/funUP/0JA3VnuSrYwlk7kUyTCc7NZTuRQY/pjfmmZn0gdJowKggWDjLA6hRWhKlwjUclqiIz1Yh3mr816TY1iU36JAPdLd+EZAqzN5cUEPdH9UCZavcmEkP+bTBBCK9U0y2OyBEwBArp7/grkhiJkXCOQLEbRwGbJIJYoJJfEukL+jQ/zCX1IYgGYvT4RXnKmbLed054IOL8uUuTuCXnyU5ilktxoulxgIVVMe1XVr6hUVNskdyszpdIJyPGOOVSiG1pIYbi6yAG0ynROc7MVRS9jx6E21zTO1DWMd0xPhQyLB9UTYjeJPIdMURi0Bf3o+sqwFwnRTMl598XV8HjArXaiBHrRp5N62KZAwh0kNBkGWyJ6UbRRnnpe/EnhnmJS+Acg3HxM7I4FBd4GTXJgIvBhNIpdaZaY+uwS3YcS9KPjYaQLwySxhsUU9mpCbcMMSMxCctzEks9Mly+xH37cTEg2OuYNHP595luKIJo7gwaA8gSnmQBCnPv44nZLFY/nKHzHIjkTgfqgPLOrNVAr5mElhwKIeOpH/vyILUvgcMDOcFwo/TEF40UD9dmgsiNtD4LhgrIgcKDCusBKcrLagESEE+YKO3Rx/uywkNwazfLYRk7QfEQdmjNFjGJEEOga1EAFtt14YvSEyAa6cH+wpPL0euIlaSbvNO61pOm+vWAldmB4f9BB9nBbGdwr6+KhVGBoa+qHkTr26S1KYVLlz/gHY1UMwFKORTcDsSCL1p0gGx0dotUhCQcMsZtpKV3JnvTZSWB+6KvdGeE9BJGhgyVvLgJuASef6p+mI/pgqq1sZ8cCIjBFhTp0v2U99kWQMt/kWCyOIiDoOmbQll20GeGdZlTVCilAoSAobMBjPXP/Ir6OrfRwiViCcEiIZJYdA7SZioLVNR4txuNmhFZIKYCWxBUzhNp1TE/TQsKTDP8dR3hopA4XAUzgRSD4n+O9BEEhxwSf4nQEdU8qF+VJHQw2Ql2LBl9621xUcdEaoNTDVAbxgSj0Z49Fw6LKlL8xkZcC4kpdeUBgOme/FneaKTJKBJUgrBBBAqshOmg/ZknRdMQzx/UFFTVA4MkoEEdRn5FgYwyJwY4j0TpxJeA8aADdEgrY6fF2h6zJKgaDmVUcEoTTBGNFowTQYEw6Tmmi8XkMWVaJl8MLH8xxG/ry4yDt4CBw5E2CenFJCy4jUBF5CjfRDSJAx32vBi4Ajvr4e/ahQfamHtUBzH7geLAiyANDBLpsaFCAxHrvN0QQQe1V71NEoXJF0hFiQxpxhcDsuYJCPfHA5BaCqpSSQoAdfaJysHpAh7886sW0V23xqpfwwA='
		EndIf
		Local $Opcode = String(_LZMAT_CodeDecompress($Code))
		$_LZMAT_Compress = (StringInStr($Opcode, "89C0") + 1) / 2
		$_LZMAT_Decompress = (StringInStr($Opcode, "89DB") + 1) / 2
		$Opcode = Binary($Opcode)

		$_LZMAT_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_LZMAT_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_LZMAT_CodeBufferMemory)
		DllStructSetData($_LZMAT_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_LZMAT_Exit")
	EndIf
EndFunc   ;==>_LZMAT_Startup

Func _LZMAT_CodeDecompress($Code)
	If @AutoItX64 Then
		Local $Opcode = '0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	Else
		Local $Opcode = '0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	EndIf
	Local $AP_Decompress = (StringInStr($Opcode, "89C0") + 1) / 2
	Local $B64D_Init = (StringInStr($Opcode, "89D2") + 1) / 2
	Local $B64D_DecodeData = (StringInStr($Opcode, "89F6") + 1) / 2
	$Opcode = Binary($Opcode)

	Local $CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
	DllStructSetData($CodeBuffer, 1, $Opcode)

	Local $B64D_State = DllStructCreate("byte[16]")
	Local $Length = StringLen($Code)
	Local $Output = DllStructCreate("byte[" & $Length & "]")

    DllCallAddress("none", DllStructGetPtr($CodeBuffer) + $B64D_Init, "struct*", $B64D_State, "int", 0, "int", 0, "int", 0)

    DllCallAddress("int", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, "str", $Code, "uint", $Length, _
            "struct*", $Output, "struct*", $B64D_State)

	Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
	Local $Result = DllStructCreate("byte[" & ($ResultLen + 16) & "]")

    If @AutoItX64 Then
        Local $Ret = DllCallAddress("uint", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, _
                "struct*", $Result, "int", 0, "int", 0)
    Else
        Local $Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, _
                "ptr", DllStructGetPtr($Output) + 4, "ptr", DllStructGetPtr($Result), "int", 0, "int", 0)
    EndIf

	_MemVirtualFree($CodeBufferMemory, 0, $MEM_RELEASE)
	Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc   ;==>_LZMAT_CodeDecompress

Func _LZMAT_Exit()
	$_LZMAT_CodeBuffer = 0
	_MemVirtualFree($_LZMAT_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc   ;==>_LZMAT_Exit
#EndRegion additional functions

#Region Base64 strings
Func Compress_Icon()
	Local $Compress_Icon
	$Compress_Icon &= "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAACEFBMVEUAAADCwsK0mlpGRkbQ0NConHyLka0aGhqSpb21xd8eHh83Nzm70elzibk3ODpgYGDh5++70+zGztnx+P3D1OiQkK3Kxrutp5diYmMCAgI9OjLIv6bEokuzpoS0xuDm8frL5PiNkay1m1iKmrq9qG/GxsbZ4evQuHDOsGGpnXuwutPY6/e93vW2ucPe3uDX19c+Oi9lZWXz4beumVysj0DPt3LOsGKonXyrtc7I4vWt1vJ5irrz4bismFsFBgbf4OHOsWS4zOWkrsy63POg0/O1nFv15sCsmFzNu37OtG6TmL+etdqPsNqMj6y0nF306sysmV/IrWHPtXKtn3i+vsV9clGxsbinnIG9nUfp0pmpl2Xg4OGDbzeCbjinn4pERENFQz+4n1vGo0fMqVTBrXnh39jVzK/GoELRrFCpkVG6uLO3t7bFqVnjzZStjjqAdVuCeWCekGnBrGzTsV3hwniykTjKq1zny4W3mUu1tLQSEhLDnD3dumfDplmMgF5xZER7aTeylEXaxIr36cu5mDrUvn737M65omKMka0lJSW6kCfKojqjhzyGd0+DdU6HeEx/aCnQsmTky5G4ki/Jp1HcwoW0lkrOuHarj0Cljk63tbDX1tTLysjGxcO5sZuskEGrj0aliTiojDypjkKkjUzU1NXLy8zb29rMzMwuLi7Yvnt1dXXPz8+zsrnZ2dkBAQF94J3+AAAAAXRSTlMAQObYZgAAAAlwSFlzAAAbrwAAG68BXhqRHAAAAOlJREFUeF5NyFOzwwAUAOGT1LZtX9u2bdu2bds2/mI7babTfdsPsKhkiiMQfGJyjAwuywdodHa0DvFuXKkwkccXyERiifulIXKFUqXWaIv0BjcEmMwWq82+gQYFx3sgNCw8IjKKiMbE+nngPIGQlJxCTE1LxyAjk5CVnZObl1+AQeFXcclvWXlFZVU11NTW1Tc0NjW3tLa1d3R2dUNPb1//wODQ8Mjo2PjEJDIF0zOzc/MLi0vLK6tr6/hNgK3tnd29/YPDo+OT0zM8CeDi8ur65vbu/uHx6fnl1QVv7x+fONz3j7+rP+QfnFHKPe9xFNwIAAAAAElFTkSuQmCC"
	Return Binary(_WinAPI_Base64Decode($Compress_Icon))
EndFunc   ;==>Compress_Icon

Func Info_Icon()
	Local $Info_Icon
	$Info_Icon &= "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABvFBMVEUAAADv8fUFBQWDtfFUjOQTL5ICBBQICAhelegUO8cpXNUTOMVjm+kFCBZWjOYwNDtNhuQwZ9lLYYwfHyI/eN5pousrY9dJguIOKaJ0qu9wo+twoukIFl4eSbBnoOgNFCt7su9noOkgTbW61fMwZNdEfuJLg+RPiOSMtOsSK5VknelsousJCg53q+/t8fUFD1Y0bNk7dNweSbpRiOS0yu/A0++5z+/A1/MAAgsAAAJhl+iCtPEwZModQKMOJpEKHYZwpe1ckuY2bdqCqObx8/d/sO9jl+ZYkeYcQ7IgIicIG4MkWNMHFFtLf97v8/VbjOSPte1RjORYj+YZP61+su8FDlYdS8wgUc8kVtNAd9pPg+A8d95Ae+BGf+IZO6B/tO8UO8UbRsodTc4gT885bNdGeNw0adk4cNw7d94pXs8yTZF4q+8NJp17sO8YQMonWM+6zOvz9ff19ffB0e87cNktY9kvZNkRMKNUW2kOKrAjO3gcRspnj95zmuB3m+J0muIqXtUjVtEQMLBkm+gOFC0PKqMOLboXP8gZQ8oTO8EOKqISExMJCw4jOXsUMJ3x8/UTL5owTZFUXGwfIieN7tAOAAAAAXRSTlMAQObYZgAAAN9JREFUeF5ty0NzBGEABuH3G65t24pt27Zt23byh1NTm9pTnlsfGv8rbGVZG5fJojBj7qVph13+19kit8VbMEGXlDohKFcpqqwJUrfiWvPEhN/nDwQVoc5ItDLOHANIprJ0Obl5+TfFMr2+jAcqDOpqXU3tRz3TIJI1NgHNLRKDuo20dxhVXd09SqCvf2BQMkTI8MjomHFcC3CTU9Mzs4TMzS8sLi1TAFbF6xubW9s7u3v7B4cAID+SnpyenV9cXl1rKAhu7+6l4ofHp2fNC9Je395Nps+vbwoZ/I9Sm85fvUwsK6pN0U8AAAAASUVORK5CYII="
	Return Binary(_WinAPI_Base64Decode($Info_Icon))
EndFunc   ;==>Info_Icon

Func Image_Btn()
	Local $Image_Btn
	$Image_Btn &= "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"
	$Image_Btn &= "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"
	$Image_Btn &= "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"
	$Image_Btn &= "PM91Xc+2bbtYLOZyuVy6UCjM53K5c47jTHLOZwzDWNA0LdvY2Fju7u7m4XBYVUYt1yXRXBGsbDYL/rXTlUxSMMZONBp1gsHgMud8LJ/PH8lms1omkzGUUkEACEspIxjjCMa4HiEUQgiZCCG9Ao0KIRgAcKWUq5QqSymLUso8ABQQQkUAKCGEygghLxKJcEqpCgQCyldgoVCAQqFwRRu+0rP9H8KgwQhpvkDgAAAAAElFTkSuQmCC"
	Return Binary(_WinAPI_Base64Decode($Image_Btn))
EndFunc   ;==>Image_Btn

Func Image_Btn2()
	Local $Image_Btn2
	$Image_Btn2 &= "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"
	$Image_Btn2 &= "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"
	$Image_Btn2 &= "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"
	$Image_Btn2 &= "kkzDstXRltawdhradPS01sKZ41uYeNvh6/E+qGpe1RdHqhU/HackDjadPwkh4ad8+L7vKpVKpWd314GhjYf+NxopPuvVpXY2Xbqk0J40GQ8exvjY2XvXYab0aC/UO8ytT7o7JvuLR8afCAfzz+38+QtLeMa7onZ5y5Wtq5Z8oKWtZa5M+YFOFEuiGEqpaTh2uvi1s2nHzPjteFjHMyPCGwYNjFVzsGoWQLOwiDMIISE8gSAIQES6mC8We3Z3dY3u6n09PDL1AgTb7tWkBpsvbY9WuFZLIMA7dm9n/cWQmU2X5Osc1dZrm7OTvfWFqULf2K5K/+TD+3YPtO0DzvVbsmtql85dPWfJ3GV1zQ1zUqlUmgkujNJklIZSahqaOQ7SOygLAGPHlCOlhBACxJlVcZKUCsXC6KHBo2NdA/tKPRPbVD7czjPeQb8xM9awZmG0zLYYKSUIBIczcwVn/H6Wcw5EhMVTtY5q65SrcZNa68nDmam94Wj+qYm9/dmRDV1zkNg2ysilXkNmWaalZmGqMTc311g7J12TqfGCIJC+9KSUgog4Y4w556ojLWNBRM4YY51zJkmSJIniJCzHlXK+OFkeLoxUJgoDlaF8tynGXS42vTzjDVJKTKTn1Yap8xfq9kq9m261vONDOWuwJiYmEIbhKW0YADZFfuQ8L0pqkrHJVNwZDxdeiI9MyfDIpA+LNIAstK2BYDWMUS0YMmAsAINHRByCCVdtUWhYxLA2tNYVoW0eQAGMFQGUwBAyUOI1ZzX5wjXrrAMAVmBw+RADOLUzn+q9/T/84ZZhzPdgSAAAAABJRU5ErkJggg=="
	Return Binary(_WinAPI_Base64Decode($Image_Btn2))
EndFunc   ;==>Image_Btn2

Func _Image_UEZ($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $Image_UEZ
	$Image_UEZ &= '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'
	$Image_UEZ &= 'AA8ADwADDwANAAgDFhYKA/4B/w4PAA8ADwAPAA8ADwA/DwAPAA8ADwAPAKoODFgAMjMXMigOCgP+CN8BDwAPAA8ADwAPAA8APw8ADwAPAA8ADwCmDhMXAGONiESuYSQo/AsM3x0xLi8BDwAPAA8Afw8ADwAPAA8ADwAPAA8AAAAEAxP6ll8UJwA6H451Y2FAGeQJA50NBAMfEA8ADwB/DwAPAA8ADwAPAA8AtgoIDAMM3zhmHQtA/JgA9PLLDQUNJx+ALYaLMzULDKoswAQMEzVYA48DDwD/DwB/Tw8ADwAPAA8ADwCgDAABCgsZbSw1CwYBvwEDAli+ZvS3AFJr6JScBQUNgDoGiMi1bQ7YDoAEDCgRSTNY7wODDwAPAAAEAQoKbxY/DwAPAA8AghM/AQdWWG2AF0nIasi1Ga4pAYEIAwwKC22uRQDdVkiYPz987wDd1gUNNh8iYhhhbQ7lAqAOSWqzOGozWP8DDwAfBgNYeIwoCx9PDwAPAM8ECA4M4GLPBJIMFlgsEQBvRF8GFAazvhITWSgECFEOCVgoAG1AEXBiLTb+AFZRfD9Va1G3AFb+ywUFGxQiDJZUgCDCDQETtRAAX0WHcREZCgiP3w4PACsIMCEaVBk/IQMPAAIAx7oCABgABAEWGUAzICQ1CQEEDmQMDgBtEW91jhQ2u0CXhWX3QBYDQgQAAQEDDBYLEzUALCQRN4uWRIgAjiM6HftXUmsAmVVrkrdWV1IAVam/DQUbH2YgYzMZCggAYAxAAGKiaDo6H3VJADJYCgMBAQgEBgQNaxYACAqMi4YwiGNtAyUwGOkDCwA1EciNIrOuJAQTDApACAMLKBcAGkSOHSfxTdBAWkxGX2EOgFsEAAgDFg4ZjEAXAFRJrmp1Zo5FABQ6Nhs69flSEFdsklUAdVJsVwBWa0zX15HRBQAFNgaNGjIOAwAEABYRs1Ci0QAbGzqOakkXLEAoEw4OCwkkAAsAEyTI7eIfRDICDL10CAxYMjdxAQBnGydFRAI1FgIBh3QKEzICYiIAHyfFsMCfn0cgP6kjrhlABwQDAUB6GshxjSKeIwIdQDk2u88e2O8AUUhSbJpWUZgCvYA6mldRP15egF7X16ihBQ0ANwARKAoIFhEicgBQomgbBRsdhwCIcchvGkk3NwICIgA3SWOzH6sQoSeNQPs6CAMJABkki41FOtFpAMy7BQ0dIm9AAwFhAQABFigzro1ARSfL8O9rgC6fIF7B1oYsQJEEAyBYF66IS8BGDRQAy/f7d+mJlZVElX2COle3mMABVyCaqreZRwIAPsEEzM4AsoiLMg4JACSzxaIxZVucAA0FDTY6HRQfBCMGJAAjHx020eCXnDZ1MvCwRcqAogBYLLViIhTOaAA0MWSoexwNBQw2hwJhgTpYM2JfAB0f9vNSkmu9AFFRWp+fT4dhBAkEgjrIIsv19gD6/QPNk82qiUCfsU5OYJtBHa8IbFFRQHWq7laYAj4BHT4+TEzAUwDRBQ0nnmIzGQAsliMpqEZ7dgBlT6HWzjYNBQMfAAQADSe7q6eXcJwncYxGTh8ABAABAAwWFgoMDAwJBFgsgI6HOtYVOQhdXTGAHUaFtAUAGxSzGiwLAQQAARM3Zh3P9FIAVldXVrdRUUhAvaXhOnE1gA0BAA4z5n6PgICCAK90ByrDPcRegF5OYE6PSEpAHYSaUkIdKldrTOAcAQAdWlpH1Orr3gFAOyOGN0A3IpwARrpGe7JlOTQANDRnZyUlJjwALi4uDw8wODgIMA9/AABCGBhyQHLbbk8hFQIAHBQVHAQAlwAAnB2uDhNhMB8ASR0WGTIzgDMkQCS1roagdBicEFBAHWEdZJFTBEar4GstyBdYCgATN+144T6ZSABWbJqabLeSSEC3fW4jcAvBOhMAEWrs70pKk80Aowc9qnSTXokAfWB9XEqTmq8EKleCOz2aklqlBKWlAB0/WkfX4SDr6+vcnKJjtZYARauoqLJlKTnAUFBQ'
	$Image_UEZ &= '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'
	$Image_UEZ &= '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'
	$Image_UEZ &= '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'
	$Image_UEZ &= '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'
	$Image_UEZ &= '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'
	$Image_UEZ &= 'lwFgPW6XyaQcbr8A2b9PHL+/aG40TyFhJISgHQEA2y8BQDs4MC44Ep3xYAUnLRooGTvhJzMAaoec77dImV4AXqWVYL1gsWAA8xQFOkUGnhMAB7l5ec2A1XkIgo9gATpOlY9cAE6xc05VfZg/AIlMa2xXUlGYAFo+Xunp10c+hN/f4JJTEC21RGYCCIIdL02/iIuMA2IXCwABC0BjXxQAzx7Jz45EGkAAjDIXEb5Ji8hglshvtSxDHUBDKCBhcV/Fq6AdHKQApMmnv2gcpE8YFSEhwLcBAEMYcgDb4C87L3J4OxB/MNg4wFgS0ToYIkkZeh3gDg5ArgAiH/CVXl5HsQCVfVWxsZtX8wAbDR2ehyNUxICqqnmAm8SCQB0AlU5gTnNOveYgDQ06FCPNbyMfADqn37jQKZ5JBliFSOAySYiHcm4MriRlo4sOCW1JjQAG4pccdYskWAnByAkOoKyMNRkLASUjCAltN3EtHxCh0WinoR0cHMlYpMmkIJrAHUMAAB4CGGDXQn9ycjswANiwMA8PLi4uMKuWQAl5WOIOFowAAkSHoTFeiVoATlVziU5SbIIA+hs2H19fI+0A88SqXI+TgmAQTk5zc2AAsWDmAAUNFGZii0k3Ajfqb4uIOsC4vAiOGhPnGgQKKAI4akTdJI0OAAD+M8hAs2bs8jMTAwIECcFzAwHHCggKE0AASXFfI7Scq5eAHMkcHBwVHJA6BhWAL9MOQkIYhDsgfy/bL9igbC4PPBin4C9vFX4sIE+LjQBFoTjffHOJiQB9VlZWzRE6BgBmamoiH+zzm4BgSoJglZVzwCsAc6VzVZwNJ0VAdYsXNVgL+Tc1QK5LU2UiGiokBDHgi7UkGa8OxTMLjGARGnAkKA8CZmMKABMyVK6GX0UfwOLFz6dPbhAAUCwDAgDRDhhCf39/LwDg2xAwbtGc4hxmYx8kDwBRBRYoFwCLho4fxRUx3wCSUlJsKj36XwBqAhdhlmYjywBC74J9c3OxpQCxc3OliT9Vz0AnH19xSSwaTwjAWHDsJYa1WB3TDBwOE4aBDwCwgg4oKAMPAhkECAwLGTIRABqWdSKeIyPWAKGcxc+rq6dPDBwhwEmwiG6nq9EAxaGhS54ihsg4SRc1mYMPANoOGUAAYa5EZp4j4u0A8vv//fP9YTUADg6MEW+GLSMA4vLTfqWJibEAc6VHpZU/acsgZmK1NQq6DgsXbmMAj70GMJ4InwzaDgMHF6EPAIMJDBZYNUAAM2EaY2JEs2YAXy2eh0tLRQYARUuHh54tX2YAjURirkkRJCw4GQsKnwQPAEcFCygAMhdhGshxjWYgIrNitYyQqQMLABlAVItqsy1LAiOAbUM4Kaip6GDB12X5MoemszkZ/IwZ2g8PAA8ADwAPACMTAAMMCgtYGYwyAEAXMxFUtbW+ASBCYbVUVBEzJMBAbTUTCxYQko8OSw8A6w4DMAUoLCAFMxhAGRYifRAQE20kABE3i5ZxdYgiAF8tLSJ1lmFt/6sO4E0PGg8ADwAPAA8ANyIhcL8KCgoWBwAKCv4M0UyPBw8ADwA0BSEFx6QDYRWQxShtQCQXEfoRwBQyYxAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPABIO79sSIhAwEOEUDC8cDwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwB/DwAPAA8ADwAPAA8ADwAAAAADsAIA/A8DsAIA5gE='
	$Image_UEZ = _WinAPI_Base64Decode($Image_UEZ)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($Image_UEZ) & ']')
	DllStructSetData($tSource, 1, $Image_UEZ)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 29162)
	$tSource = 0
	Local $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\UEZ4.1.bmp", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return  $bString
EndFunc   ;==>_Image_UEZ

Func _Typewriter()
	Local $Typewriter
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "34MTp36GA6AGAj59ATHBMP+BCKABwgjmYaV84wKsVEoC/wEEwwZFCIcBqo3HaIUBKAL/CAFnZmxpKIsDG2eAgxqshv8fAFiDCgr8kpSaDK+EikiL/+8cHwAThisJhQHvlJ8Kpwn/hRioyWy8HwAfAH+2XMRsnP/pL8UUPS39CwsMyyFFJGmq/9lQRyzpRC8LXlANJHQylioDgEjhSIB/gn99euFgPYCBg4GwF/BbkVjHgAAgULABgX96UD/hRAPAQVEDhYB1eoKBVHqA4GCBEAF7wQJ9JoFxZ8BKgHkgAYF94wBJYF5+fnmBBpABkEUdIQmB0UMRARBLeXqCA+ABkk6CeYB7gX8udHBN8FlgBIAwBH1+QHt+en+Ce1BdgmGxYoGBeoNAWdEFeQPQAXAGgHl+f3uDWH19giJaEF16gFp9xH+GQGp9gn0wCxEMA5KAgAh6f4CBdnMAen6Ih4WIhngAdXV0dnuIhoYChaADeH6DgH96BH15oGmBgYOGfgh6eXogEIWFgoWR4Ah1e3uQA3+BsBISgPERgH3gCniAiAB7dXZ+gYaBgAKGAQR1fn6Bi4oAgIN+cHZ7foYAhXuFh3V9f3WBoBWPhnuDf3iQDACCh356gXp4ewCCg4OHgIaAdUsAbQAWg9AMgHrgCoL+gpE5QGgwdmAY1GJgDHJ9+eNcgIFQAkJvAmahHeEgf+ABUVvzLBADEVq0I3EDe+8THtFXoQHhYn3Ab/NmUWP/kgGhAwMhk4PEMbIHsRbjBP+ABtNtg2XGoNEXBIf6R8NG/9VfU4rnYww49JIcOKZ1gnb/eTvqPXqtfy+/N0YwcQChLd+HNfc7eQqSCNZTfQCQdAL7F1WQAHx7cHIS3bQFDD+j/z0BrXYoo9USxQn5Wf+e+57/i0VHnudX8x6XubVMTxUPAP8PAA8AL16vGVm2r1pPAR9d/w8ADwAPAA8ADwAtB5m0GCj/+SiIdM8WnxUPAP8TdQANBP8RP/UBjwUCL/UBwweGHsch/38OqxdPAg8ACzkPAO8/qBJ/JmzIqg93J0gmc60/sWh/AIV4fYZ/eX+FfzK/MMDQYbFkAFEwXjO7f/PxyTEEgYFwt9DG0FgQto+QXZABkGHwy35+guAEB9FrcDmwuXl7j350QH+NfW6GeuDKi5Ugw4UgaIBA0H+CMGUCa3DRfod6fpF9AHaHhWxrgYWARIOFIAV/dX1wX4BNcAl9kG3wbX56MGaCEIF9goGxVX18ew9xzYBuYWnAcIJ9dX5+e9BvQrmBYGEFAFewyHzegZDY8NOhbuBif5EAIdEYe3yCsABxIH18grWAf358fX5+fwAgAIB9f359gIB9gQBgfX1+e36AAbCIfX9/AHh8fn4BTIEAJH5/f3+AfwFgRQFEfwAkf31/AFKAPwFSAAYBQgGCAnoCOn1//H17AWIDaAASAYQCHgJC/wAqAgoEAAQKAhgBeQKNAA1/A0EDRQEMAoMAswYMAkl+/ICABAgDKAZSBVYEEgHI/wcNAjCFOwF4AQ8CYoMVgAf/hHgDHQUNggIBFoMPBQECD/8FF4ENAwEIcok9hDqFWQEB/wORg5OECQUagxKFdoWlg6H3haoDGywAgEAAwwGIAQoD/8cBQyVAA4MASgVGAcJkiDH/CghDMI1BCAAET1ZMRxCVB/8qAAIPw1GDXgRgyinGYcU0/0ZfhgyGs8UHCXJSXQ4DkAT/5AcbAAkrigRnHigX6wMEHP9GI0wwTi8jJeUlyQMlBssK/xE58jmXPC8DhAuYBUc3B47z4ZXBlH17ogFEkKCC5Yh2fYKdoFt9QpBBA8KggAJ/YKd/fXp/gnsBIAF+gIF6fX+BKWIggHsgAXpABnp7boHAq+CsAkOAoKKFRIAdoIiCAAKiC4AGgH98t4ILAAiBk4CBqeAAfEAA/oFFUYWwqo6kVgVW4aPLiWtBpAIQfaASggF4wL97D6APgnmFYOK0f3+DfSB5f395fqAQg4MJgBGAeaAbgX6B"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "QoGwA/1wcIIhfZMMAGFBbSF0sC8/sgDUFkI0pUiBArQCe34AgoF7dIWDdnsAhn92g4Z9eYIsgHrwgsBiemAJeoK4gX2BsAKReME0fcFD//AJwXdlBAEBk3THXjM7MAAgg35+g4DgCHp5HXAAfRF8cIXlXICBgyR+exIBgoJTBHt771EQYJ3QfIAOe8ECEQEwAPx7eWAEkzRAAeMClJbxCf/CJKEFs5RINHmGRmoFnLma/xOBB2Q3n6tsow7HVlIdZQL/pqEVoi9Qw3lnKz9Kv0LXWT9zFZtcn3OHpzICwzaAfQR2epALg4aAe3lAdnl5e4CDoCN9xnoAg/CDe3p5ISNQC32gAHvwHgAY0YBipkOYgP8wAYACURmBKE1zAqjoL0pM/+WxjECaGKKkPVTjoe4c3QX/zleSBPMET1kPAO9h1oMdbv/PU55UNCg4af+gDwC6BvGb5nvBNZIEfHyCAVJAQHD/KAkRF4kfYm+VwWYLdhlWCf+ICscADwDPXA1YawPPFr8D/ysuCnvvh2Of9hOoMZYPr3L/33APADgC00QPAA8ADwAbe//PPi0KlhAoF8tyclr/BA4uH6LZDwAPANYI0F5/g3gAeod+dYKFeYBAg3p+gnp7sGeGAHh+hX92hoF1QIKAeIGDdiACfQCFe3uGe3qGfoB5gn96gYF6AFzFUMd9sAKBfnoRa2Jaf1Hiol/BytBIs23CFMEJfgB6c4uIdHmHioBsf4Bzhn2CQEYCfQADe4WGfXSDAIZzfoWGc3WHAHV4iIt5f414AHl7c32DfX2IAIF0e4d/dnqPAIfNtQBueYh4dIp+eACHhHWBgHaAggB1gYh6e4V9gACCen6Hfn2DeQB6hXp4g4OAfgB/f36AfXuCfgh+hX8AFHt/f3sAgYF5f4J7foEYfX2CARgABH2AgAh9fX8BVH5/fX/TAWYAAIB9AA6AAhIEDsMBPAAUgH5+gAEUAgLPAgYDLwIJAAOAgAELAk47AXwAAoAAVAEMAUJ/f5x9fQEqAAACE359ABHDAyoAAH1+fnsAAwACPwEMAmIDDgCMASkCF359/wEfhT+BXAMAhQOCQ4UVhwz9gSJ9AiQDJ4QjBgAEOoQJbwgNgTwFIoU6f4IgAmd+/oCCTIWPhIKEQYFfAwkCDf+EBYMMAhKEiwgAg7UEAwCm/4YChxAAsgfHhgVABQVjhwT/RAGFIMcERQpIDEoGCQNFAf/FUoQvBgUJW0gbxWGDC4xjfxcAmgfKdQUEByMHngIwgIR+e0CUfn6DgsGdAH16gIOAgoB7RH56gAR/gIFAvXqgeX9/gYJAkXrAo/6BAFNAiAFSAhNBwMEEA6v/xT9BXEGJR2MJXQdMwX5BEP+OMwQqRjpEiAhYyAIJaIhcL0heRQBCAoB5eUAWe39CgyB9f4F9e8B1fcB/gn59e3sgfeB9+Ht9hYAZwgWgVkACAH0/oCQAhCEcIAYABiACgH/igWFrgH97oX/CDYJc/2R/xkdhFyWGakkhKIN+a1f/qlArJw1h5BzPB4Mx5BDGPf8FC6tE4njqfI9NI4IfAOczB99VzwMQQYB7eH2BQcBPg4F5eXngpIM5IDd6fkEwoi9gAIF/+IKAeiBXAn0gTaQcZCr/hAuEAUKBpbGjVqICrCgEBq+CAEMG5IiCZ3zju3wCt/9iCiNUKCxmLGYQpjVGr0dx/yePhmLHWYelYklmBYyzoU//JW5CA2W+j4sFsB8AaDKuTP/om0gVMKOLqlJZ8FqIKMgI/3JEHwAPAA8AYnIRTVIUcgfmfOIW0EF9fGJKh3XGbv+jFlsf6i90eA8AA0pvFQ8A389vjhIPAE8DagOBgVBgTH9wh9OLgQTxLbEAMl5ST4L/EZCgiZERYgGRXzERQF/hAp+gD0IxYAHCE8EAfXtIXU/AAHIB8QWhE317dTd7tnqQliEtfeCMVTZ78pX78WiBVYBwPUMyQoJwVkA/tHt7kWmB0geQAH4Qmv5/IAGxWvCYwQQh"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "CIJ2g4gKLYsDBjcICf+JDQYfGwANMYoMSI8DAAJk/5EEAVpAW0YBRAYCA8AQgGL/0ZwSBUIN26oWsEagPwAFpv+nCoFuA64/ANFxRqKGqp5E/zF/TGB/LR8A7AvHMSSAil3/Z4osh/NdkQJEiR8AHwAqC//tK0kucBzFK8oEbB0pMAM5/z8oXywNdC8mhQHOUSUUtyD/Ty+fLR8AKo7pK5IByiYaIW+CqUszQsHIiIDFv4LCfvchkkUEx2GA4QIkBuQJiAEHwQygx+dqgH59gH/YfX+AotiCF31CAAW//+EFJdEmMYMBR0WC3KRCKOn/n7Z8M1thzCIFRUgWMxPwCgcECsELdA97f4KDfQB/gXh0e4GDgwCCgX99fXt6egCCh316gX97f0CAgYF9fYAxAoAygnEFensQEeEWgH7AgYGAg4F9IA4BBniBgX+QA8ISZXmSenv/8QCRCDEBk0ghFActeHnREvfBFsVzgw97QgHEf4YWRVj/IxbMLmcQYgLXAikCNHifYP8vAf92mgGkLemRe3c2GdVB/2VT54hyDLQMUZGUAqc05yd/MSrTAAQsVJS4FLpLBSCBHH988BmpY8Eyfn2CA2As8R+DfXmFeX0EhHfRHHqId3x/AHWAfHuDd4F/AHmFe36Be4F5AH6CdYF9foZ6AIN/eoB7fXp90IF9gIVABHngA2ALAHx6eX6DgIOCLH588CPCDntAEnx+iSEhenygB3yCguAAwH98fH58gZAAAAA/wADGLAKfsQFREAENe33+e8Ej8g51H6QUxaI5FNqa/z8BlwGSGy9GjwLBFWQApEX/x0IxCVtiRnYlGMlh9TcqY/+3tF88jF/vqC9hDwC/RJYE/695DwDKR2lFegBWrf+B/4z/lSn/XoZXDwBfev4C/Ab6QP/3Wj8RDwAPAHu0lhAMGFY8/2e++wHJFikL+kpvEc8QnwH/xwBGBU917wIPAG6l3xWqCv9an08nDwAPAHnmDwC/urjk/58GT6QpF6xhHyp6Wt+4PxJ/Txtf0y8BDwAPAA8AaApvtWB+f39/fgFABFB/PwQoAgADMAQUCDAFeH9/WIB/fQAABmZ9AAqA3oACQAMEBU4AFH0FFAWe/wMABR4ALQgMCHIEXgA/AEH/BjMGjwdGARIIwAUZBhIFBv8GgwU1BjgGLwRHDyEQAIk3/4qhCKWJMQiiCAqEEAB2g2z/AQQNAAEJBnsGLgg7hQ6MNP+MBATFiz4MfMlByjRKPgQ970lUyQ6UYRUAgBFc2AwMW/8KYB4DyEHTSw8FhwFNyM3KCUdVgHvAJ3qGdnsAgWqDinmHh3kAg3N5f2+Hg3YAjIF4fnV+en4AinZ+hnN7gH0AgXuIg3WDeXQAgnuAgn6Ben4ggXh/hXqBE32AAIB7goF+g357BHp7QBOCfX+AfkCAeoGCeYLABX0AgH95g35+g30AfoF7f3p+g3oQgoF6gMDkeoKAAHaCf3iGeX6BAH6GeHaNdnmLAHZ7goZ7c5J/AGyIgniDg4B+AIOGdH2HdH2FAQAKg3h6in55hgKAoAl+en+DfX8ghX19gH1gDX5+gIWBfYCBfX1AAAR/fwACe3SAgYIAgnGIg3mHcXgAjHqBhn+BdYgAemuIgHh+e4ZgeniMeX2gB6APfyCCgIKKf4AYenQAcX16eIKDgYEDwBogInt+fXp7fgB/fX+Bfnl9faB4f4GBggA/feAUyUACfXpgA4B/AIhAfktgieAFfeABgYFAQ3vmeyFiwBB+ewSBgBXgCcJ7AUCBf3p9QAEAH5yAgCEVwABDaH17JTH3gEtAGoKJgEAAAQxACwAD/6EEAB/AD6IBQA6gB4ILAQD/QwFBAAEIwgAhAQRPYQJhFf9CV2JyYBFgASEDowTkBuJOBoAAAEEDfn+Cg3oDwDdgHnmHgHmGgQh0f4YAOH2DgXhCgSA4fnaCggAjfRB+hX57oAuCeoAwhn17g2AaICKCfrh9gYCBrMIjwRyBo63/AAvB"
	$Typewriter &= "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"
	$Typewriter &= "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"
	$Typewriter &= "XwSDAiNFTYSkgOBbgAB+g+ABewHhYoGCgH17fnsgen95foKganh+8IN6foIgAwBfIHHBUoFiYIF/fH99fOBQ++FrYCN7RFYgVUUvonGhYysBZOACeyIIfMALgH6+eYBTAEfBAiAIYAN8gVU3IjchAQEze6Fegmd9fOh9f3zADX0gFCFfoAD+faEPwAvACEOOZAUCYOED/wVMp5BFNaF/Ig2gHqJXoR6TgBBBEX58QYeCfcCCESFbgX2B4QWBf3s0gYAhiH6ggEJegYDUfoGgAYXgIIIgEgAKsIWBfoLABSAqfkAFMntjsICAwJHgjoGBUICBgn8gF33ALH/me4ALYAKAgUEDoQnBjfdhBWEzIol9AAaACiACYBSL4RchQXpAEn2AgcEVDyEogMVBGAABg4h1eQCDdnaGe3iLhgEAAnqGfnV+g4cUhoCAEIKADHqCfQB7eniFfnB/fQB4gXuCf3+KhoCDhoJ9f4GCgAAAfnl4eXp4f4ACeWAmfnl+f4KF0IODhoagDHugDeA8DUEse0GO4ap/hoWDIIWDgoOBIBB5eg56wTGgEKAdenl6e/54AAghKmAvwBahQsJLYAAIfXt7gAWAgX+A/IOC4CjhTyEuICDhdAXo/H174B+G4uAW4QJD48SBBwKuBHun6AA="
	$Typewriter = _WinAPI_Base64Decode($Typewriter)
	Local $tSource = DllStructCreate("byte[" & BinaryLen($Typewriter) & "]")
	DllStructSetData($tSource, 1, $Typewriter)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress)
	$tSource = 0
	Return Binary(DllStructGetData($tDecompress, 1))
EndFunc   ;==>_Typewriter

Func _EyeBlink_0png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_0png
	$EyeBlink_0png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIsSURBVChTHVK9S7JRFH8qF6VQEAWHhqAhQkKaDMGPesGlECKVKESKEJMERUFriOhm1JDZYJkUJhhBulhE0SCCSEFDiza46SD4Fzj9znufO1zO5d5zzu/jHOn8/PxfNptlt7e37PHxUcSrqyvWbDZZu91mPz8/rF6vs0qlwm5ubsS/fK/Vaqzf7zPp+Pg4zQsolUrR6empiFtbW7S/v08PDw/0+vpK+XyeCoUClUolcX9+fiYOQL1ej6R4PM4CgQCsVivm5+dhMBgwNjaG8fFxqNVqTExMQKlUQqvVYm5uDk6nE8lkEpwN3t7eIG1ubjJ+MDMzg9HRUWg0GphMJrhcLpjNZthsNjgcDkxOToocnU4nctbW1nB5eQnJ4/GwxcVFgaBSqWA0GhEKhbC7uwuZ2crKinjj9BGNRsGlQK/XY2RkBKurq5C4Xra8vIzp6WlMTU0JlEQigYODA+zs7GBvb080kovL5TIGgwHW19ehUCgwOzsLKRwOM7/fj6WlJVgsFsjNZHRuFviEEIlEEAwGkU6nMRwO8ff3B5/PJ6TIYNLh4SGTTXG73UKr1+vFyckJcrkcPj4+0Gg08P39jW63i9/fX9zd3QlGCwsLsNvtkM7OzpiMFIvFsL29jY2NDeGBTJmPFcViEe/v7/j8/ES1WsXT0xMymQy4dJEvXVxcpOV5c0fp+vqa7u/viS8Uvby80NfXF7VaLep0OsSXijgD4oyIN6GjoyPKZrP0H8yFbrIMH96xAAAAAElFTkSuQmCC'
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_0png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_0.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_0png

Func _EyeBlink_1png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_1png
	$EyeBlink_1png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIsSURBVChTHVK9S7JRFH8qF6VQEAWHhqAhQkKaDMGPesGlECKVKESKEJMERUFriOhm1JDZYJkUJhhBulhE0SCCSEFDiza46SD4Fzj9znufO1zO5d5zzu/jHOn8/PxfNptlt7e37PHxUcSrqyvWbDZZu91mPz8/rF6vs0qlwm5ubsS/fK/Vaqzf7zPp+Pg4zQsolUrR6empiFtbW7S/v08PDw/0+vpK+XyeCoUClUolcX9+fiYOQL1ej6R4PM4CgQCsVivm5+dhMBgwNjaG8fFxqNVqTExMQKlUQqvVYm5uDk6nE8lkEpwN3t7eIG1ubjJ+MDMzg9HRUWg0GphMJrhcLpjNZthsNjgcDkxOToocnU4nctbW1nB5eQnJ4/GwxcVFgaBSqWA0GhEKhbC7uwuZ2crKinjj9BGNRsGlQK/XY2RkBKurq5C4Xra8vIzp6WlMTU0JlEQigYODA+zs7GBvb080kovL5TIGgwHW19ehUCgwOzsLKRwOM7/fj6WlJVgsFsjNZHRuFviEEIlEEAwGkU6nMRwO8ff3B5/PJ6TIYNLh4SGTTXG73UKr1+vFyckJcrkcPj4+0Gg08P39jW63i9/fX9zd3QlGCwsLsNvtkM7OzpiMFIvFsL29jY2NDeGBTJmPFcViEe/v7/j8/ES1WsXT0xMymQy4dJEvXVxcpOV5c0fp+vqa7u/viS8Uvby80NfXF7VaLep0OsSXijgD4oyIN6GjoyPKZrP0H8yFbrIMH96xAAAAAElFTkSuQmCC'
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_1png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_1.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_1png

Func _EyeBlink_2png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_2png
	$EyeBlink_2png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIqSURBVChTNVK9S/JRGP3REBQmFQgSBGYYWIuTghAovLiITgmChvZFaiqaONSgQlcjw49ALTLIBqPPLapBC4LCQZzEQRwcBPEvaDv3vb8LDQ/34d5zzznPh5BOp/+VSiVyeXlJbm9vydXVFc8bjQbpdDqk2WySz89P8vz8TP5wYi7eDYdDIiSTyVyxWKSZTIbH6ekp9fv99Pj4mD49PdGPjw96d3dHHx4e6P39PWUE/Pz5+aGDwYAK0WiUeDwemEwm6PV6KBQKjI+PQyKRYHZ2lsf09DTm5+f5u81mQywWw/n5Od7e3iC43W7idDqhVqv5x8nJSSwuLsJgMECj0UCr1UKn00Emk0Eul2Nqagpzc3NwOBzI5XIQ7HY7EcGiysTEBJaXl7G9vY3d3V3s7OzAarViZWUF1WoVe3t7yOfzkEqlXEx0I2xubhKz2QylUomFhQUsLS1hf38fh4eH2NraQiAQ4GShUAiPj48YjUZYW1vD2NgYFxOCwSBxuVwwGo28RovFAp/Ph3K5DNZQhMNheL1eZLNZ/P7+ot1uY319HTMzM1CpVBDi8Tg5ODjgdkQSkf3o6AgXFxd4eXlBvV7H19cXer0eWq0Wrq+vOaHYm9XVVQgnJyeEBSKRCK9dbI7oQFROpVK4ubnB+/s7arUaXl9fwUaIs7MzXt7GxgYEZi3HQJQ1h7LR0EqlwufMwJQtEWXKtN/v0263S5l9+v39zfcikUjQQqFA/wOOK28JpUd8GgAAAABJRU5ErkJggg=='
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_2png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_2.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_2png

Func _EyeBlink_3png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_3png
	$EyeBlink_3png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAInSURBVChTHVK9S7pRGL2DhmiE2JqWiB+kUGsi2PBDgiDQQYQQRVIQrcEocamIK1SKSUSkCH4slQ6Cgx+QtAhKWLQUDSIENfQPNJ77u+8dLvfyvuc5z3POecjFxcW/29tbWiqV6P39Pa3VavTh4YE+Pz/Tj48POhqNaL/fp41Gg97c3NBisUibzSZ9enqiv7+/lKTT6UtOwK6vrxkHsHw+z05OTlihUGCPj49sPB6zdrvNWq0W4yTiO2/AhsMh+/n5YeTg4IDGYjG43W64XC5YrVao1WrMz89jYWEBi4uL0Ol0WF1dxdbWFiKRCE5PT8GbotvtggSDQer3+0WhSqWCTCaDRqOBzWaDwWCA2WwWR6lUQqFQiGOxWBAKhcCnBfH5fNThcGBubg4zMzMwGo3Y3t4GJxagzc1NLC8vo1wuIxAI4PDwEHK5XOB5LQgH0Y2NDWi1WiwtLcFkMmF3dxfJZFIQSPLC4TD29vZQr9fx/f0tSAkhYkoSj8eFBKfTCbvdLn5Go1Fwt3F2diYKJd3ZbBZ/f394e3sTnWdnZ6HX60GOj49pKpWC1+vF+vo6PB4PeArgboM7j16vBx4jPj8/8fr6KqRIhCsrK1hbWwM5Pz+nfBewv7+PnZ0doV+aIJFIgEeMSqWCTqcDHqm4+a4gk8kIjyRPSC6Xu6xWqyJ/aR+kN9fKOJi9vLyw6XTKvr6+2GQyYe/v72wwGLC7uzt2dHTErq6u2H94+28ear7zpgAAAABJRU5ErkJggg=='
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_3png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_3.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_3png

Func _EyeBlink_4png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_4png
	$EyeBlink_4png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIdSURBVChTHVK/S/pRFP2ouJhgKong4BKGhIMILkERfQdRAgN1EIooEBEdxAoq0IYHWqJJijqoEInQD4doCbRB0UFBEEEnh3AUGvoDOu/7Pm94cO+755573j1PuLu7+1epVEitViPNZpN8fX2R4XBIxuMxmUwmPP/4+CD1ep08PDxwnJh3Oh3y8/NDhGQyeV+tVql4Xl9fKStQ1kgXiwX9/f2ly+WSTqdT2m63KSOhhUKB4waDAa8Jl5eX5Pz8HIFAANFoFGdnZxDzWCyGeDyOTCYDphCPj48oFou4ublBIpFAuVxGq9WCwBrJ8fExHA4HLBYLVldXoVAoIJVKIQgCJBIJ1tbWsLGxAbvdjt3dXXg8Hj4wl8tBODo6Int7ezAajZDL5bxJJpNBrVZjfX0der0eSqUS29vbWFlZgUql4rnJZILf74cQCoWI2+2GVqvlkzUaDWw2G8Q7l8sFn8+H/f19HovyCSGcXBy0ubkJIRwOE6/XC6vVymVubW3xpmw2i9vbW0QiEZyenqJUKuHv7w+j0YhjRAKdTgfh+vqaiMsTSXZ2duB0OhEMBvnCPj8/0ev1wGzFfD5Hv9/n7z44OIDBYIDZbIZoI0mn03z7JycnnOjw8JA7cXV1hXw+j0ajgbe3Nzw/P/PtX1xccJyoVGBS75+enij7JJQVKbOLvry80Pf3d/4nZrMZ/f7+pkwBj7vdLhXxzH6aSqXofxq8b1cNshylAAAAAElFTkSuQmCC'
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_4png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_4.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_4png

Func _EyeBlink_5png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_5png
	$EyeBlink_5png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIbSURBVChTPVLLS+pBGP0FtgpB6KGIGxMShMi/wEDvLgl7rCIfi4gINDBBRd3IqBU9oAdIpQsVcSMUgiASESIImkqYCIJLQfwfznfHuXAXH/P65pwz54x0dXX15/n5maXTaVYsFtnHxwdrtVrs5+eH9ft9sX5/f2e5XI7d39+z19dXsf76+mLT6ZRJiUTijm9SKpUiDkD8gHq9Ho1GIxqPx2L8/v6mSqVC2WyWOAgVCgVqNBo0mUxICoVCLBAI4PT0FHyOYDAIv9+PeDyOTCaDUqmEt7c3cAW4ublBOBwWfY+Pj+CgkPhFdnx8jJ2dHZjNZlH7+/vweDwCoF6vo9vtotPpgCuAy+XC3t6eGC8uLiAdHR2xra0t6PV6rKysQKvVYn19XZTVasXZ2Rmenp7AvUC1WkUsFsPm5iY2NjYEkMSZmN1uh0qlgiRJ/2t+fh5zc3OQy+VYXFyEWq2GTqfD6uoqNBoNZDIZ1tbWIJ2fn7OTkxNYLBYolUosLCxAoVDAYDCIZx0eHoqKRqN4eHiAzWYTPTOSpaUlSJFIhLndbiFrJn/GYjQacXBwgGQyCZ6K8KDZbCKfzwtvTCYTlpeX/ym4vLxk/C+AK4HT6RSs29vbcDgc4v0+nw+3t7fC9ZkC3g+v1yuM3t3dhXR9fX03y5cbRS8vL8RZiMdG5XKZPj8/qd1u03A4pMFgQL+/v1Sr1YhHSjxqisVi9BeX93PysZ0QRgAAAABJRU5ErkJggg=='
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_5png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_5.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_5png

Func _EyeBlink_6png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_6png
	$EyeBlink_6png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIdSURBVChTPVI7SLJRGP4IonDJQQUHCVqjQWrTMQVBly5os3QZKvBG5GUwDxZC5o2GwjDRCKopUlFBdNCQQPEC4qKDELS01OLwnP875+f/h5dz3st53ud93iOEw+H1m5sbcnd3R15eXkipVCLv7+/k4+ODdDodUqlUeDyTyZDr62tuT09PPP75+UmE8/Pzq2QySW9vb+nz8zMtFou02WzSfr9PR6MRHQ6H3C8UCjSbzdJoNMrPer1OJ5MJFTweD/H5fDg4OIDT6YTb7UYwGMT9/T1yuRyq1SpEULy+vvIYy52enuLy8pLnhePjY3J0dISdnR0YDAbodDpsbGwgEAjg7e0NrVYLIgt0u12Io+Di4gIOhwNWqxV+vx/C4eEhsVgsWF1dxdraGvR6PQdjyXw+j8FggK+vL/z8/GA8HiOVSmF3dxcmkwlbW1sQbDYbEUGwsrKCubk5LC8vw2g04uTkBI+Pj+j1evj+/sZ0OsXv7y/a7TYfU6VS8Vqugd1ux/b2NpRKJQRBwPz8PBYXF6HRaMDGEwVGLBbD3t4eZymTyXidXC4H2wJhdPf39/n87DFL/jPmM2CJRPI/NjMzg4WFhb8MRDVJJBIBY8E6KhQKzM7O8kKpVMq7LS0tQa1WQ6vVwmw2cwE3Nzf5nX2kK7bXRCJBQ6EQPTs7o+JmqAhIvV4vjcfj9OHhgZbLZdpoNGitVqPpdJq6XC6xPkT/ADKMdokVe9FaAAAAAElFTkSuQmCC'
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_6png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_6.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_6png

Func _EyeBlink_7png($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $EyeBlink_7png
	$EyeBlink_7png &= 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAKCAYAAAC9vt6cAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIdSURBVChTVVI/SPJRFP0NggTWUg1KhK5KYODmWmQQJkiKDk06aCKKgZAEVs+CFCsHSSgFIUGtQSzIPxgOijiGRUIUBI3RFrSc+73f+/iGb7g83r333HPePU9Kp9NL5+fnLJ/Ps2q1ylqtFuv3+2w4HLLRaMS63S67ublhxWKRZbNZEeVymT08PLDPz08mHR0dnVxcXFAul6NKpUKNRoMGgwFxML2/v9N4PCY+TOSvrq7o7OyMSqUS9Xo9+vj4ICkWizEe8Hq9CIVCiEajYIyBM4KDwBvR6XRwe3uLQqGAw8ND7OzsIJlM4u7uDlIgEGBbW1twOp1YXV3F8vIy7HY7EokE7u/v8fj4iLe3N7y8vKBer+P4+BiRSAQejwfxePzvABm8uLgIk8kEi8UCt9uN/f19NJtNvL6+4uvrCz8/P+CSweXD7/fDarViY2MDUjgcZsFgEEajEUqlEgsLC7DZbJCfxZeH5+dnfH9/4/f3Vwx5enrC3t4e5ufnYTAYIHYgS3I4HNBoNJAkCZOTk9Dr9VhbW8PBwQFqtRq4Q0LyysoK5ubmRN/s7CxkF5gs1+fzieLExIQo/gv5rtPpMD09/V9eJhEK+D9gmUwG29vbMJvNmJmZgUKhEE0qlQpTU1NQq9XQarUCIJO4XC6sr6+LUzo9PT2RfeUfhLhFxC2izc1NEXzBtLu7S5yArq+vidtJ7XabLi8viRNSKpWiPwxQdsXLIea6AAAAAElFTkSuQmCC'
	Local $bString = Binary(_WinAPI_Base64Decode($EyeBlink_7png))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\EyeBlink_7.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_EyeBlink_7png
#EndRegion Base64 strings
