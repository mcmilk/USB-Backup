
#cs
	Copyright © 2009 WideBoyDixon and UEZ [3D Pie Chart: post #1]
	http://www.autoitscript.com/forum/index.php?showtopic=97241

	Copyright © 2014 - 2015 Tino Reichardt

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License Version 2, as
	published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
#ce

#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <GUISlider.au3>
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIMisc.au3>
#include <FFLabels.au3>

Global Const $iDebug = 0

Func _DrawLegend($hWnd, $sValues, $sColors, $sHeadline, $iLeft, $iTop, $iHeight = 18, $iFontSize = 8.5, $iX_Headline = 60, $iX_Value = 50, $iX_Percent = 40)
	Local $aChartColour = StringSplit($sColors, ",", $STR_NOCOUNT)
	Local $aChartValue = StringSplit($sValues, ",", $STR_NOCOUNT)
	Local $aChartPercent = StringSplit($sValues, ",", $STR_NOCOUNT)
	Local $aChartHeadline = StringSplit($sHeadline, ",", $STR_NOCOUNT)
	Local $nCount, $nTotal = 0, $nValues

	If UBound($aChartColour) <> UBound($aChartValue) Then
		MsgBox(0, "ERROR", "UBound($aChartColour) <> UBound($aChartValue)")
	EndIf
	If UBound($aChartColour) <> UBound($aChartHeadline) Then
		MsgBox(0, "ERROR", "UBound($aChartColour) <> UBound($aChartHeadline)")
	EndIf
	$nValues = UBound($aChartValue)

	; Start GDI+
	;_GDIPlus_Startup()

	; Create the brushes and pens
	Global $ahBrush[$nValues], $ahPen[$nValues]
	For $i = 0 To $nValues - 1
		$ahBrush[$i] = _GDIPlus_BrushCreateSolid(BitOR(0xff000000, $aChartColour[$i]))
		$ahPen[$i] = _GDIPlus_PenCreate(0xff000000)
	Next

	; Set up GDI+
	Local $hDC = _WinAPI_GetDC($hWnd)
	Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)
	Local $a = WinGetPos($hWnd)
	Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($a[2], $a[3], $hGraphics)
	Local $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($hBuffer, 2)

	_GDIPlus_GraphicsSetClipRect($hGraphics, $iLeft, $iTop, $iX_Headline + $iHeight / 2 + 2 + $iX_Value + $iX_Percent, $iHeight * $nValues, 1)
	If $iDebug = 1 Then
		_GDIPlus_GraphicsClear($hBuffer, 0xffaaaaaa)
	Else
		_GDIPlus_GraphicsClear($hBuffer, _GetWindowBkColor($hWnd))
	EndIf
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0, 0)

	; Total up the values
	For $nCount = 0 To UBound($aChartValue) - 1
		$nTotal += $aChartValue[$nCount]
	Next

	; Set the fractional values
	For $nCount = 0 To UBound($aChartPercent) - 1
		$aChartPercent[$nCount] /= $nTotal
	Next

	Local $hFormat = _GDIPlus_StringFormatCreate()
	Local $hFamily = _GDIPlus_FontFamilyCreate("Microsoft Sans Serif")
	Local $hFont = _GDIPlus_FontCreate($hFamily, $iFontSize)
	Local $hBrush = _GDIPlus_BrushCreateSolid()
	For $i = 0 To $nValues - 1
		Local $y = $iTop + $i * $iHeight
		Local $x = $iLeft
		Local $tLayout

		$tLayout = _GDIPlus_RectFCreate($x, $y, $iX_Headline, $iHeight)
		_GDIPlus_GraphicsDrawStringEx($hGraphics, $aChartHeadline[$i], $hFont, $tLayout, $hFormat, $hBrush)
		$x += $iX_Headline

		$tLayout = _GDIPlus_RectFCreate($x, $y, $iX_Value, $iHeight)
		_GDIPlus_GraphicsDrawStringEx($hGraphics, _WinAPI_StrFormatByteSize($aChartValue[$i]), $hFont, $tLayout, $hFormat, $hBrush)
		$x += $iX_Value

		Local $h = Int($iHeight / 2)
		Local $hx = Int($h / 4)
		_GDIPlus_GraphicsDrawRect($hGraphics, $x, $y + $hx, $h, $h, $ahPen[$i])
		_GDIPlus_GraphicsFillRect($hGraphics, $x + 1, $y + $hx + 1, $h - 1, $h - 1, $ahBrush[$i])
		$x += $h + 2

		$tLayout = _GDIPlus_RectFCreate($x, $y, $iX_Percent, $iHeight)
		_GDIPlus_GraphicsDrawStringEx($hGraphics, Int($aChartPercent[$i] * 100) & "%", $hFont, $tLayout, $hFormat, $hBrush)
	Next

	For $i = 0 To UBound($aChartColour) - 1
		_GDIPlus_PenDispose($ahPen[$i])
		_GDIPlus_BrushDispose($ahBrush[$i])
	Next
	_GDIPlus_GraphicsDispose($hBuffer)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphics)
	_WinAPI_ReleaseDC($hWnd, $hDC)
EndFunc   ;==>_DrawLegend

; Draw the pie chart
;
; $hWnd = $hWnd of window
; $sValues = "12,22,33,44,55" -> should be 100
; $sColors = "0x123456,0x123456,..."
; left, top, width
; $Aspect = 50 (10..100)
; $pieDepth = 10 (0..xx)
; $rotation = 0 (0..360)
Func _DrawPie($hWnd, $sValues, $sColors, $pieLeft, $pieTop, $pieWidth, $Aspect = 30, $pieDepth = 10, $rotation = 180)
	$Aspect /= 100

	; Controls the size of the pie and also the depth
	Local Const $PIE_DIAMETER = $pieWidth - 2
	Local Const $PIE_HEIGHT = $PIE_DIAMETER * $Aspect - 2
	Local Const $PI = ATan(1) * 4 ; The value of PI
	Local $pieHeight = $PIE_DIAMETER * $Aspect
	Local $nCount, $nTotal = 0, $angleStart, $angleSweep, $x, $y, $hPath
	Local $aChartColour = StringSplit($sColors, ",", $STR_NOCOUNT)
	Local $aChartValue = StringSplit($sValues, ",", $STR_NOCOUNT)
	If UBound($aChartColour) <> UBound($aChartValue) Then
		MsgBox(0, "ERROR", "UBound($aChartColour) <> UBound($aChartValue)")
	EndIf
	Local $NUM_VALUES = UBound($aChartValue)

	; Start GDI+
	;_GDIPlus_Startup()

	; Create the brushes and pens
	Global $ahBrush[$NUM_VALUES][2], $ahPen[$NUM_VALUES]
	For $i = 0 To $NUM_VALUES - 1
		$ahBrush[$i][0] = _GDIPlus_BrushCreateSolid(BitOR(0xff000000, $aChartColour[$i]))
		$ahBrush[$i][1] = _GDIPlus_BrushCreateSolid(BitOR(0xff000000, _GetDarkerColour($aChartColour[$i])))
		$ahPen[$i] = _GDIPlus_PenCreate(BitOR(0xff000000, _GetDarkerColour(_GetDarkerColour($aChartColour[$i]))))
	Next

	; Set up GDI+
	Local $hDC = _WinAPI_GetDC($hWnd)
	Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)
	Local $a = WinGetPos($hWnd)
	Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($a[2], $a[3], $hGraphics)
	Local $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($hBuffer, 2)

	; Total up the values
	For $nCount = 0 To UBound($aChartValue) - 1
		$nTotal += $aChartValue[$nCount]
	Next

	; Set the fractional values
	For $nCount = 0 To UBound($aChartValue) - 1
		$aChartValue[$nCount] /= $nTotal
	Next

	; Make sure we don't over-rotate
	$rotation = Mod($rotation, 360)

	; Clear the graphics buffer
	_GDIPlus_GraphicsSetClipRect($hGraphics, $pieLeft, $pieTop, $pieWidth, $pieHeight + $pieDepth * (1 - $Aspect), 1)

	If $iDebug = 1 Then
		_GDIPlus_GraphicsClear($hBuffer, 0xffaaaaaa)
	Else
		_GDIPlus_GraphicsClear($hBuffer, _GetWindowBkColor($hWnd))
	EndIf

	; Set the initial angles based on the fractional values
	Local $Angles[UBound($aChartValue) + 1]
	For $nCount = 0 To UBound($aChartValue)
		If $nCount = 0 Then
			$Angles[$nCount] = $rotation
		Else
			$Angles[$nCount] = $Angles[$nCount - 1] + ($aChartValue[$nCount - 1] * 360)
		EndIf
	Next

	; Adjust the angles based on the aspect
	For $nCount = 0 To UBound($aChartValue)
		$x = $PIE_DIAMETER * Cos($Angles[$nCount] * $PI / 180)
		$y = $PIE_DIAMETER * Sin($Angles[$nCount] * $PI / 180)
		$y -= ($PIE_DIAMETER - $PIE_HEIGHT) * Sin($Angles[$nCount] * $PI / 180)
		If $x = 0 Then
			$Angles[$nCount] = 90 + ($y < 0) * 180
		Else
			$Angles[$nCount] = ATan($y / $x) * 180 / $PI
		EndIf
		If $x < 0 Then $Angles[$nCount] += 180
		If $x >= 0 And $y < 0 Then $Angles[$nCount] += 360
		$x = $PIE_DIAMETER * Cos($Angles[$nCount] * $PI / 180)
		$y = $PIE_HEIGHT * Sin($Angles[$nCount] * $PI / 180)
	Next

	; Decide which pieces to draw first and last
	Local $nStart = -1, $nEnd = -1
	For $nCount = 0 To UBound($aChartValue) - 1
		$angleStart = Mod($Angles[$nCount], 360)
		$angleSweep = Mod($Angles[$nCount + 1] - $Angles[$nCount] + 360, 360)
		If $angleStart <= 270 And ($angleStart + $angleSweep) >= 270 Then
			$nStart = $nCount
		EndIf
		If ($angleStart <= 90 And ($angleStart + $angleSweep) >= 90) _
				Or ($angleStart <= 450 And ($angleStart + $angleSweep) >= 450) Then
			$nEnd = $nCount
		EndIf
		If $nEnd >= 0 And $nStart >= 0 Then ExitLoop
	Next

	; Draw the first piece
	_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth * (1 - $Aspect), $nStart, $Angles)

	; Draw pieces "to the right"
	$nCount = Mod($nStart + 1, UBound($aChartValue))
	While $nCount <> $nEnd
		_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth * (1 - $Aspect), $nCount, $Angles)
		$nCount = Mod($nCount + 1, UBound($aChartValue))
	WEnd

	; Draw pieces "to the left"
	$nCount = Mod($nStart + UBound($aChartValue) - 1, UBound($aChartValue))
	While $nCount <> $nEnd
		_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth * (1 - $Aspect), $nCount, $Angles)
		$nCount = Mod($nCount + UBound($aChartValue) - 1, UBound($aChartValue))
	WEnd

	; Draw the last piece
	_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth * (1 - $Aspect), $nEnd, $Angles)

	; Now draw the bitmap on to the device context of the window
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0, 0)

	; Release the resources
	For $i = 0 To UBound($aChartColour) - 1
		_GDIPlus_PenDispose($ahPen[$i])
		_GDIPlus_BrushDispose($ahBrush[$i][0])
		_GDIPlus_BrushDispose($ahBrush[$i][1])
	Next
	_GDIPlus_GraphicsDispose($hBuffer)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphics)
	_WinAPI_ReleaseDC($hWnd, $hDC)

	; Shut down GDI+
	; _GDIPlus_Shutdown()
EndFunc   ;==>_DrawPie

Func _DrawPiePiece($hGraphics, $iX, $iY, $iWidth, $iHeight, $iDepth, $nCount, $Angles)
	Local $hPath, $cX = $iX + ($iWidth / 2), $cY = $iY + ($iHeight / 2), $fDrawn = False
	Local $iStart = Mod($Angles[$nCount], 360), $iSweep = Mod($Angles[$nCount + 1] - $Angles[$nCount] + 360, 360)

	; Draw side
	$hPath = _GDIPlus_PathCreate()
	If $iStart < 180 And ($iStart + $iSweep > 180) Then
		_GDIPlus_PathAddArc($hPath, $iX, $iY, $iWidth, $iHeight, $iStart, 180 - $iStart)
		_GDIPlus_PathAddArc($hPath, $iX, $iY + $iDepth, $iWidth, $iHeight, 180, $iStart - 180)
		_GDIPlus_PathCloseFigure($hPath)
		_GDIPlus_GraphicsFillPath($hGraphics, $hPath, $ahBrush[$nCount][1])
		_GDIPlus_GraphicsDrawPath($hGraphics, $hPath, $ahPen[$nCount])
		$fDrawn = True
	EndIf
	If $iStart + $iSweep > 360 Then
		_GDIPlus_PathAddArc($hPath, $iX, $iY, $iWidth, $iHeight, 0, $iStart + $iSweep - 360)
		_GDIPlus_PathAddArc($hPath, $iX, $iY + $iDepth, $iWidth, $iHeight, $iStart + $iSweep - 360, 360 - $iStart - $iSweep)
		_GDIPlus_PathCloseFigure($hPath)
		_GDIPlus_GraphicsFillPath($hGraphics, $hPath, $ahBrush[$nCount][1])
		_GDIPlus_GraphicsDrawPath($hGraphics, $hPath, $ahPen[$nCount])
		$fDrawn = True
	EndIf
	If $iStart < 180 And (Not $fDrawn) Then
		_GDIPlus_PathAddArc($hPath, $iX, $iY, $iWidth, $iHeight, $iStart, $iSweep)
		_GDIPlus_PathAddArc($hPath, $iX, $iY + $iDepth, $iWidth, $iHeight, $iStart + $iSweep, -$iSweep)
		_GDIPlus_PathCloseFigure($hPath)
		_GDIPlus_GraphicsFillPath($hGraphics, $hPath, $ahBrush[$nCount][1])
		_GDIPlus_GraphicsDrawPath($hGraphics, $hPath, $ahPen[$nCount])
	EndIf
	_GDIPlus_PathDispose($hPath)

	; Draw top
	_GDIPlus_GraphicsFillPie($hGraphics, $iX, $iY, $iWidth, $iHeight, $iStart, $iSweep, $ahBrush[$nCount][0])
	_GDIPlus_GraphicsDrawPie($hGraphics, $iX, $iY, $iWidth, $iHeight, $iStart, $iSweep, $ahPen[$nCount])
EndFunc   ;==>_DrawPiePiece

; Get a darker version of a colour by extracting the RGB components
Func _GetDarkerColour($Colour)
	Local $Red, $Green, $Blue
	$Red = (BitAND($Colour, 0xff0000) / 0x10000) - 40
	$Green = (BitAND($Colour, 0x00ff00) / 0x100) - 40
	$Blue = (BitAND($Colour, 0x0000ff)) - 40
	If $Red < 0 Then $Red = 0
	If $Green < 0 Then $Green = 0
	If $Blue < 0 Then $Blue = 0
	Return ($Red * 0x10000) + ($Green * 0x100) + $Blue
EndFunc   ;==>_GetDarkerColour

Func _GetWindowBkColor($hWnd = 0)
	Local $hDC, $iOpt, $hBkGUI, $nColor

	If $hWnd Then
		$hDC = _WinAPI_GetDC($hWnd)
		$nColor = DllCall('gdi32.dll', 'int', 'GetBkColor', 'hwnd', $hDC)
		$nColor = $nColor[0] ;BGR
		$nColor = Hex(BitOR(BitAND($nColor, 0x00FF00), BitShift(BitAND($nColor, 0x0000FF), -16), BitShift(BitAND($nColor, 0xFF0000), 16)), 6) ;convert to RGB
		_WinAPI_ReleaseDC($hWnd, $hDC)
		Return "0xFF" & $nColor
	EndIf

	$iOpt = Opt("WinWaitDelay", 10)
	$hBkGUI = GUICreate("", 2, 2, 1, 1, $WS_POPUP, $WS_EX_TOOLWINDOW)
	GUISetState()
	WinWait($hBkGUI)
	$nColor = Hex(PixelGetColor(1, 1, $hBkGUI), 6)
	GUIDelete($hBkGUI)
	Opt("WinWaitDelay", $iOpt)

	Return '0xFF' & $nColor

EndFunc   ;==>_GetWindowBkColor
