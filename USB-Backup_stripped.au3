#NoTrayIcon
Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 1 + 2 + 4)
Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Opt("WinTitleMatchMode", 2)
Opt("WinDetectHiddenText", 1)
Global Enum $ARRAYFILL_FORCE_DEFAULT, $ARRAYFILL_FORCE_SINGLEITEM, $ARRAYFILL_FORCE_INT, $ARRAYFILL_FORCE_NUMBER, $ARRAYFILL_FORCE_PTR, $ARRAYFILL_FORCE_HWND, $ARRAYFILL_FORCE_STRING
Global Enum $ARRAYUNIQUE_NOCOUNT, $ARRAYUNIQUE_COUNT
Global Enum $ARRAYUNIQUE_AUTO, $ARRAYUNIQUE_FORCE32, $ARRAYUNIQUE_FORCE64, $ARRAYUNIQUE_MATCH, $ARRAYUNIQUE_DISTINCT
Func _ArrayAdd(ByRef $aArray, $vValue, $iStart = 0, $sDelim_Item = "|", $sDelim_Row = @CRLF, $iForce = $ARRAYFILL_FORCE_DEFAULT)
If $iStart = Default Then $iStart = 0
If $sDelim_Item = Default Then $sDelim_Item = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iForce = Default Then $iForce = $ARRAYFILL_FORCE_DEFAULT
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, 1)
Local $hDataType = 0
Switch $iForce
Case $ARRAYFILL_FORCE_INT
$hDataType = Int
Case $ARRAYFILL_FORCE_NUMBER
$hDataType = Number
Case $ARRAYFILL_FORCE_PTR
$hDataType = Ptr
Case $ARRAYFILL_FORCE_HWND
$hDataType = Hwnd
Case $ARRAYFILL_FORCE_STRING
$hDataType = String
EndSwitch
Switch UBound($aArray, 0)
Case 1
If $iForce = $ARRAYFILL_FORCE_SINGLEITEM Then
ReDim $aArray[$iDim_1 + 1]
$aArray[$iDim_1] = $vValue
Return $iDim_1
EndIf
If IsArray($vValue) Then
If UBound($vValue, 0) <> 1 Then Return SetError(5, 0, -1)
$hDataType = 0
Else
Local $aTmp = StringSplit($vValue, $sDelim_Item, 2 + 1)
If UBound($aTmp, 1) = 1 Then
$aTmp[0] = $vValue
EndIf
$vValue = $aTmp
EndIf
Local $iAdd = UBound($vValue, 1)
ReDim $aArray[$iDim_1 + $iAdd]
For $i = 0 To $iAdd - 1
If IsFunc($hDataType) Then
$aArray[$iDim_1 + $i] = $hDataType($vValue[$i])
Else
$aArray[$iDim_1 + $i] = $vValue[$i]
EndIf
Next
Return $iDim_1 + $iAdd - 1
Case 2
Local $iDim_2 = UBound($aArray, 2)
If $iStart < 0 Or $iStart > $iDim_2 - 1 Then Return SetError(4, 0, -1)
Local $iValDim_1, $iValDim_2 = 0, $iColCount
If IsArray($vValue) Then
If UBound($vValue, 0) <> 2 Then Return SetError(5, 0, -1)
$iValDim_1 = UBound($vValue, 1)
$iValDim_2 = UBound($vValue, 2)
$hDataType = 0
Else
Local $aSplit_1 = StringSplit($vValue, $sDelim_Row, 2 + 1)
$iValDim_1 = UBound($aSplit_1, 1)
Local $aTmp[$iValDim_1][0], $aSplit_2
For $i = 0 To $iValDim_1 - 1
$aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, 2 + 1)
$iColCount = UBound($aSplit_2)
If $iColCount > $iValDim_2 Then
$iValDim_2 = $iColCount
ReDim $aTmp[$iValDim_1][$iValDim_2]
EndIf
For $j = 0 To $iColCount - 1
$aTmp[$i][$j] = $aSplit_2[$j]
Next
Next
$vValue = $aTmp
EndIf
If UBound($vValue, 2) + $iStart > UBound($aArray, 2) Then Return SetError(3, 0, -1)
ReDim $aArray[$iDim_1 + $iValDim_1][$iDim_2]
For $iWriteTo_Index = 0 To $iValDim_1 - 1
For $j = 0 To $iDim_2 - 1
If $j < $iStart Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
ElseIf $j - $iStart > $iValDim_2 - 1 Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
Else
If IsFunc($hDataType) Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = $hDataType($vValue[$iWriteTo_Index][$j - $iStart])
Else
$aArray[$iWriteTo_Index + $iDim_1][$j] = $vValue[$iWriteTo_Index][$j - $iStart]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($aArray, 1) - 1
EndFunc
Func _ArrayColInsert(ByRef $aArray, $iColumn)
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, 1)
Switch UBound($aArray, 0)
Case 1
Local $aTempArray[$iDim_1][2]
Switch $iColumn
Case 0, 1
For $i = 0 To $iDim_1 - 1
$aTempArray[$i][(Not $iColumn)] = $aArray[$i]
Next
Case Else
Return SetError(3, 0, -1)
EndSwitch
$aArray = $aTempArray
Case 2
Local $iDim_2 = UBound($aArray, 2)
If $iColumn < 0 Or $iColumn > $iDim_2 Then Return SetError(3, 0, -1)
ReDim $aArray[$iDim_1][$iDim_2 + 1]
For $i = 0 To $iDim_1 - 1
For $j = $iDim_2 To $iColumn + 1 Step -1
$aArray[$i][$j] = $aArray[$i][$j - 1]
Next
$aArray[$i][$iColumn] = ""
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($aArray, 2)
EndFunc
Func _ArrayDelete(ByRef $aArray, $vRange)
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, 1) - 1
If IsArray($vRange) Then
If UBound($vRange, 0) <> 1 Or UBound($vRange, 1) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($aArray, 0)
Case 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$aArray[$iCopyTo_Index] = $aArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($aArray, 2) - 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$aArray[$iCopyTo_Index][$j] = $aArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($aArray, 1)
EndFunc
Func _ArrayInsert(ByRef $aArray, $vRange, $vValue = "", $iStart = 0, $sDelim_Item = "|", $sDelim_Row = @CRLF, $iForce = $ARRAYFILL_FORCE_DEFAULT)
If $vValue = Default Then $vValue = ""
If $iStart = Default Then $iStart = 0
If $sDelim_Item = Default Then $sDelim_Item = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iForce = Default Then $iForce = $ARRAYFILL_FORCE_DEFAULT
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, 1) - 1
Local $hDataType = 0
Switch $iForce
Case $ARRAYFILL_FORCE_INT
$hDataType = Int
Case $ARRAYFILL_FORCE_NUMBER
$hDataType = Number
Case $ARRAYFILL_FORCE_PTR
$hDataType = Ptr
Case $ARRAYFILL_FORCE_HWND
$hDataType = Hwnd
Case $ARRAYFILL_FORCE_STRING
$hDataType = String
EndSwitch
Local $aSplit_1, $aSplit_2
If IsArray($vRange) Then
If UBound($vRange, 0) <> 1 Or UBound($vRange, 1) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
For $i = 2 To $vRange[0]
If $vRange[$i] < $vRange[$i - 1] Then Return SetError(3, 0, -1)
Next
Local $iCopyTo_Index = $iDim_1 + $vRange[0]
Local $iInsertPoint_Index = $vRange[0]
Local $iInsert_Index = $vRange[$iInsertPoint_Index]
Switch UBound($aArray, 0)
Case 1
If $iForce = $ARRAYFILL_FORCE_SINGLEITEM Then
ReDim $aArray[$iDim_1 + $vRange[0] + 1]
For $iReadFromIndex = $iDim_1 To 0 Step -1
$aArray[$iCopyTo_Index] = $aArray[$iReadFromIndex]
$iCopyTo_Index -= 1
$iInsert_Index = $vRange[$iInsertPoint_Index]
While $iReadFromIndex = $iInsert_Index
$aArray[$iCopyTo_Index] = $vValue
$iCopyTo_Index -= 1
$iInsertPoint_Index -= 1
If $iInsertPoint_Index < 1 Then ExitLoop 2
$iInsert_Index = $vRange[$iInsertPoint_Index]
WEnd
Next
Return $iDim_1 + $vRange[0] + 1
EndIf
ReDim $aArray[$iDim_1 + $vRange[0] + 1]
If IsArray($vValue) Then
If UBound($vValue, 0) <> 1 Then Return SetError(5, 0, -1)
$hDataType = 0
Else
Local $aTmp = StringSplit($vValue, $sDelim_Item, 2 + 1)
If UBound($aTmp, 1) = 1 Then
$aTmp[0] = $vValue
$hDataType = 0
EndIf
$vValue = $aTmp
EndIf
For $iReadFromIndex = $iDim_1 To 0 Step -1
$aArray[$iCopyTo_Index] = $aArray[$iReadFromIndex]
$iCopyTo_Index -= 1
$iInsert_Index = $vRange[$iInsertPoint_Index]
While $iReadFromIndex = $iInsert_Index
If $iInsertPoint_Index <= UBound($vValue, 1) Then
If IsFunc($hDataType) Then
$aArray[$iCopyTo_Index] = $hDataType($vValue[$iInsertPoint_Index - 1])
Else
$aArray[$iCopyTo_Index] = $vValue[$iInsertPoint_Index - 1]
EndIf
Else
$aArray[$iCopyTo_Index] = ""
EndIf
$iCopyTo_Index -= 1
$iInsertPoint_Index -= 1
If $iInsertPoint_Index = 0 Then ExitLoop 2
$iInsert_Index = $vRange[$iInsertPoint_Index]
WEnd
Next
Case 2
Local $iDim_2 = UBound($aArray, 2)
If $iStart < 0 Or $iStart > $iDim_2 - 1 Then Return SetError(6, 0, -1)
Local $iValDim_1, $iValDim_2
If IsArray($vValue) Then
If UBound($vValue, 0) <> 2 Then Return SetError(7, 0, -1)
$iValDim_1 = UBound($vValue, 1)
$iValDim_2 = UBound($vValue, 2)
$hDataType = 0
Else
$aSplit_1 = StringSplit($vValue, $sDelim_Row, 2 + 1)
$iValDim_1 = UBound($aSplit_1, 1)
StringReplace($aSplit_1[0], $sDelim_Item, "")
$iValDim_2 = @extended + 1
Local $aTmp[$iValDim_1][$iValDim_2]
For $i = 0 To $iValDim_1 - 1
$aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, 2 + 1)
For $j = 0 To $iValDim_2 - 1
$aTmp[$i][$j] = $aSplit_2[$j]
Next
Next
$vValue = $aTmp
EndIf
If UBound($vValue, 2) + $iStart > UBound($aArray, 2) Then Return SetError(8, 0, -1)
ReDim $aArray[$iDim_1 + $vRange[0] + 1][$iDim_2]
For $iReadFromIndex = $iDim_1 To 0 Step -1
For $j = 0 To $iDim_2 - 1
$aArray[$iCopyTo_Index][$j] = $aArray[$iReadFromIndex][$j]
Next
$iCopyTo_Index -= 1
$iInsert_Index = $vRange[$iInsertPoint_Index]
While $iReadFromIndex = $iInsert_Index
For $j = 0 To $iDim_2 - 1
If $j < $iStart Then
$aArray[$iCopyTo_Index][$j] = ""
ElseIf $j - $iStart > $iValDim_2 - 1 Then
$aArray[$iCopyTo_Index][$j] = ""
Else
If $iInsertPoint_Index - 1 < $iValDim_1 Then
If IsFunc($hDataType) Then
$aArray[$iCopyTo_Index][$j] = $hDataType($vValue[$iInsertPoint_Index - 1][$j - $iStart])
Else
$aArray[$iCopyTo_Index][$j] = $vValue[$iInsertPoint_Index - 1][$j - $iStart]
EndIf
Else
$aArray[$iCopyTo_Index][$j] = ""
EndIf
EndIf
Next
$iCopyTo_Index -= 1
$iInsertPoint_Index -= 1
If $iInsertPoint_Index = 0 Then ExitLoop 2
$iInsert_Index = $vRange[$iInsertPoint_Index]
WEnd
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($aArray, 1)
EndFunc
Func _ArrayPop(ByRef $aArray)
If(Not IsArray($aArray)) Then Return SetError(1, 0, "")
If UBound($aArray, 0) <> 1 Then Return SetError(2, 0, "")
Local $iUBound = UBound($aArray) - 1
If $iUBound = -1 Then Return SetError(3, 0, "")
Local $sLastVal = $aArray[$iUBound]
If $iUBound > -1 Then
ReDim $aArray[$iUBound]
EndIf
Return $sLastVal
EndFunc
Func _ArrayReverse(ByRef $aArray, $iStart = 0, $iEnd = 0)
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
If UBound($aArray, 0) <> 1 Then Return SetError(3, 0, 0)
If Not UBound($aArray) Then Return SetError(4, 0, 0)
Local $vTmp, $iUBound = UBound($aArray) - 1
If $iEnd < 1 Or $iEnd > $iUBound Then $iEnd = $iUBound
If $iStart < 0 Then $iStart = 0
If $iStart > $iEnd Then Return SetError(2, 0, 0)
For $i = $iStart To Int(($iStart + $iEnd - 1) / 2)
$vTmp = $aArray[$i]
$aArray[$i] = $aArray[$iEnd]
$aArray[$iEnd] = $vTmp
$iEnd -= 1
Next
Return 1
EndFunc
Func _ArraySort(ByRef $aArray, $iDescending = 0, $iStart = 0, $iEnd = 0, $iSubItem = 0, $iPivot = 0)
If $iDescending = Default Then $iDescending = 0
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If $iSubItem = Default Then $iSubItem = 0
If $iPivot = Default Then $iPivot = 0
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
Local $iUBound = UBound($aArray) - 1
If $iUBound = -1 Then Return SetError(5, 0, 0)
If $iEnd = Default Then $iEnd = 0
If $iEnd < 1 Or $iEnd > $iUBound Or $iEnd = Default Then $iEnd = $iUBound
If $iStart < 0 Or $iStart = Default Then $iStart = 0
If $iStart > $iEnd Then Return SetError(2, 0, 0)
If $iDescending = Default Then $iDescending = 0
If $iPivot = Default Then $iPivot = 0
If $iSubItem = Default Then $iSubItem = 0
Switch UBound($aArray, 0)
Case 1
If $iPivot Then
__ArrayDualPivotSort($aArray, $iStart, $iEnd)
Else
__ArrayQuickSort1D($aArray, $iStart, $iEnd)
EndIf
If $iDescending Then _ArrayReverse($aArray, $iStart, $iEnd)
Case 2
If $iPivot Then Return SetError(6, 0, 0)
Local $iSubMax = UBound($aArray, 2) - 1
If $iSubItem > $iSubMax Then Return SetError(3, 0, 0)
If $iDescending Then
$iDescending = -1
Else
$iDescending = 1
EndIf
__ArrayQuickSort2D($aArray, $iDescending, $iStart, $iEnd, $iSubItem, $iSubMax)
Case Else
Return SetError(4, 0, 0)
EndSwitch
Return 1
EndFunc
Func __ArrayQuickSort1D(ByRef $aArray, Const ByRef $iStart, Const ByRef $iEnd)
If $iEnd <= $iStart Then Return
Local $vTmp
If($iEnd - $iStart) < 15 Then
Local $vCur
For $i = $iStart + 1 To $iEnd
$vTmp = $aArray[$i]
If IsNumber($vTmp) Then
For $j = $i - 1 To $iStart Step -1
$vCur = $aArray[$j]
If($vTmp >= $vCur And IsNumber($vCur)) Or(Not IsNumber($vCur) And StringCompare($vTmp, $vCur) >= 0) Then ExitLoop
$aArray[$j + 1] = $vCur
Next
Else
For $j = $i - 1 To $iStart Step -1
If(StringCompare($vTmp, $aArray[$j]) >= 0) Then ExitLoop
$aArray[$j + 1] = $aArray[$j]
Next
EndIf
$aArray[$j + 1] = $vTmp
Next
Return
EndIf
Local $L = $iStart, $R = $iEnd, $vPivot = $aArray[Int(($iStart + $iEnd) / 2)], $bNum = IsNumber($vPivot)
Do
If $bNum Then
While($aArray[$L] < $vPivot And IsNumber($aArray[$L])) Or(Not IsNumber($aArray[$L]) And StringCompare($aArray[$L], $vPivot) < 0)
$L += 1
WEnd
While($aArray[$R] > $vPivot And IsNumber($aArray[$R])) Or(Not IsNumber($aArray[$R]) And StringCompare($aArray[$R], $vPivot) > 0)
$R -= 1
WEnd
Else
While(StringCompare($aArray[$L], $vPivot) < 0)
$L += 1
WEnd
While(StringCompare($aArray[$R], $vPivot) > 0)
$R -= 1
WEnd
EndIf
If $L <= $R Then
$vTmp = $aArray[$L]
$aArray[$L] = $aArray[$R]
$aArray[$R] = $vTmp
$L += 1
$R -= 1
EndIf
Until $L > $R
__ArrayQuickSort1D($aArray, $iStart, $R)
__ArrayQuickSort1D($aArray, $L, $iEnd)
EndFunc
Func __ArrayQuickSort2D(ByRef $aArray, Const ByRef $iStep, Const ByRef $iStart, Const ByRef $iEnd, Const ByRef $iSubItem, Const ByRef $iSubMax)
If $iEnd <= $iStart Then Return
Local $vTmp, $L = $iStart, $R = $iEnd, $vPivot = $aArray[Int(($iStart + $iEnd) / 2)][$iSubItem], $bNum = IsNumber($vPivot)
Do
If $bNum Then
While($iStep *($aArray[$L][$iSubItem] - $vPivot) < 0 And IsNumber($aArray[$L][$iSubItem])) Or(Not IsNumber($aArray[$L][$iSubItem]) And $iStep * StringCompare($aArray[$L][$iSubItem], $vPivot) < 0)
$L += 1
WEnd
While($iStep *($aArray[$R][$iSubItem] - $vPivot) > 0 And IsNumber($aArray[$R][$iSubItem])) Or(Not IsNumber($aArray[$R][$iSubItem]) And $iStep * StringCompare($aArray[$R][$iSubItem], $vPivot) > 0)
$R -= 1
WEnd
Else
While($iStep * StringCompare($aArray[$L][$iSubItem], $vPivot) < 0)
$L += 1
WEnd
While($iStep * StringCompare($aArray[$R][$iSubItem], $vPivot) > 0)
$R -= 1
WEnd
EndIf
If $L <= $R Then
For $i = 0 To $iSubMax
$vTmp = $aArray[$L][$i]
$aArray[$L][$i] = $aArray[$R][$i]
$aArray[$R][$i] = $vTmp
Next
$L += 1
$R -= 1
EndIf
Until $L > $R
__ArrayQuickSort2D($aArray, $iStep, $iStart, $R, $iSubItem, $iSubMax)
__ArrayQuickSort2D($aArray, $iStep, $L, $iEnd, $iSubItem, $iSubMax)
EndFunc
Func __ArrayDualPivotSort(ByRef $aArray, $iPivot_Left, $iPivot_Right, $bLeftMost = True)
If $iPivot_Left > $iPivot_Right Then Return
Local $iLength = $iPivot_Right - $iPivot_Left + 1
Local $i, $j, $k, $iAi, $iAk, $iA1, $iA2, $iLast
If $iLength < 45 Then
If $bLeftMost Then
$i = $iPivot_Left
While $i < $iPivot_Right
$j = $i
$iAi = $aArray[$i + 1]
While $iAi < $aArray[$j]
$aArray[$j + 1] = $aArray[$j]
$j -= 1
If $j + 1 = $iPivot_Left Then ExitLoop
WEnd
$aArray[$j + 1] = $iAi
$i += 1
WEnd
Else
While 1
If $iPivot_Left >= $iPivot_Right Then Return 1
$iPivot_Left += 1
If $aArray[$iPivot_Left] < $aArray[$iPivot_Left - 1] Then ExitLoop
WEnd
While 1
$k = $iPivot_Left
$iPivot_Left += 1
If $iPivot_Left > $iPivot_Right Then ExitLoop
$iA1 = $aArray[$k]
$iA2 = $aArray[$iPivot_Left]
If $iA1 < $iA2 Then
$iA2 = $iA1
$iA1 = $aArray[$iPivot_Left]
EndIf
$k -= 1
While $iA1 < $aArray[$k]
$aArray[$k + 2] = $aArray[$k]
$k -= 1
WEnd
$aArray[$k + 2] = $iA1
While $iA2 < $aArray[$k]
$aArray[$k + 1] = $aArray[$k]
$k -= 1
WEnd
$aArray[$k + 1] = $iA2
$iPivot_Left += 1
WEnd
$iLast = $aArray[$iPivot_Right]
$iPivot_Right -= 1
While $iLast < $aArray[$iPivot_Right]
$aArray[$iPivot_Right + 1] = $aArray[$iPivot_Right]
$iPivot_Right -= 1
WEnd
$aArray[$iPivot_Right + 1] = $iLast
EndIf
Return 1
EndIf
Local $iSeventh = BitShift($iLength, 3) + BitShift($iLength, 6) + 1
Local $iE1, $iE2, $iE3, $iE4, $iE5, $t
$iE3 = Ceiling(($iPivot_Left + $iPivot_Right) / 2)
$iE2 = $iE3 - $iSeventh
$iE1 = $iE2 - $iSeventh
$iE4 = $iE3 + $iSeventh
$iE5 = $iE4 + $iSeventh
If $aArray[$iE2] < $aArray[$iE1] Then
$t = $aArray[$iE2]
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
If $aArray[$iE3] < $aArray[$iE2] Then
$t = $aArray[$iE3]
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
If $aArray[$iE4] < $aArray[$iE3] Then
$t = $aArray[$iE4]
$aArray[$iE4] = $aArray[$iE3]
$aArray[$iE3] = $t
If $t < $aArray[$iE2] Then
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
EndIf
If $aArray[$iE5] < $aArray[$iE4] Then
$t = $aArray[$iE5]
$aArray[$iE5] = $aArray[$iE4]
$aArray[$iE4] = $t
If $t < $aArray[$iE3] Then
$aArray[$iE4] = $aArray[$iE3]
$aArray[$iE3] = $t
If $t < $aArray[$iE2] Then
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
EndIf
EndIf
Local $iLess = $iPivot_Left
Local $iGreater = $iPivot_Right
If(($aArray[$iE1] <> $aArray[$iE2]) And($aArray[$iE2] <> $aArray[$iE3]) And($aArray[$iE3] <> $aArray[$iE4]) And($aArray[$iE4] <> $aArray[$iE5])) Then
Local $iPivot_1 = $aArray[$iE2]
Local $iPivot_2 = $aArray[$iE4]
$aArray[$iE2] = $aArray[$iPivot_Left]
$aArray[$iE4] = $aArray[$iPivot_Right]
Do
$iLess += 1
Until $aArray[$iLess] >= $iPivot_1
Do
$iGreater -= 1
Until $aArray[$iGreater] <= $iPivot_2
$k = $iLess
While $k <= $iGreater
$iAk = $aArray[$k]
If $iAk < $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
ElseIf $iAk > $iPivot_2 Then
While $aArray[$iGreater] > $iPivot_2
$iGreater -= 1
If $iGreater + 1 = $k Then ExitLoop 2
WEnd
If $aArray[$iGreater] < $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $aArray[$iGreater]
$iLess += 1
Else
$aArray[$k] = $aArray[$iGreater]
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
$aArray[$iPivot_Left] = $aArray[$iLess - 1]
$aArray[$iLess - 1] = $iPivot_1
$aArray[$iPivot_Right] = $aArray[$iGreater + 1]
$aArray[$iGreater + 1] = $iPivot_2
__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 2, True)
__ArrayDualPivotSort($aArray, $iGreater + 2, $iPivot_Right, False)
If($iLess < $iE1) And($iE5 < $iGreater) Then
While $aArray[$iLess] = $iPivot_1
$iLess += 1
WEnd
While $aArray[$iGreater] = $iPivot_2
$iGreater -= 1
WEnd
$k = $iLess
While $k <= $iGreater
$iAk = $aArray[$k]
If $iAk = $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
ElseIf $iAk = $iPivot_2 Then
While $aArray[$iGreater] = $iPivot_2
$iGreater -= 1
If $iGreater + 1 = $k Then ExitLoop 2
WEnd
If $aArray[$iGreater] = $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iPivot_1
$iLess += 1
Else
$aArray[$k] = $aArray[$iGreater]
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
EndIf
__ArrayDualPivotSort($aArray, $iLess, $iGreater, False)
Else
Local $iPivot = $aArray[$iE3]
$k = $iLess
While $k <= $iGreater
If $aArray[$k] = $iPivot Then
$k += 1
ContinueLoop
EndIf
$iAk = $aArray[$k]
If $iAk < $iPivot Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
Else
While $aArray[$iGreater] > $iPivot
$iGreater -= 1
WEnd
If $aArray[$iGreater] < $iPivot Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $aArray[$iGreater]
$iLess += 1
Else
$aArray[$k] = $iPivot
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 1, True)
__ArrayDualPivotSort($aArray, $iGreater + 1, $iPivot_Right, False)
EndIf
EndFunc
Func _ArrayUnique(Const ByRef $aArray, $iColumn = 0, $iBase = 0, $iCase = 0, $iCount = $ARRAYUNIQUE_COUNT, $iIntType = $ARRAYUNIQUE_AUTO)
If $iColumn = Default Then $iColumn = 0
If $iBase = Default Then $iBase = 0
If $iCase = Default Then $iCase = 0
If $iCount = Default Then $iCount = $ARRAYUNIQUE_COUNT
If UBound($aArray, 1) = 0 Then Return SetError(1, 0, 0)
Local $iDims = UBound($aArray, 0), $iNumColumns = UBound($aArray, 2)
If $iDims > 2 Then Return SetError(2, 0, 0)
If $iBase < 0 Or $iBase > 1 Or(Not IsInt($iBase)) Then Return SetError(3, 0, 0)
If $iCase < 0 Or $iCase > 1 Or(Not IsInt($iCase)) Then Return SetError(3, 0, 0)
If $iCount < 0 Or $iCount > 1 Or(Not IsInt($iCount)) Then Return SetError(4, 0, 0)
If $iIntType < 0 Or $iIntType > 4 Or(Not IsInt($iIntType)) Then Return SetError(5, 0, 0)
If $iColumn < 0 Or($iNumColumns = 0 And $iColumn > 0) Or($iNumColumns > 0 And $iColumn >= $iNumColumns) Then Return SetError(6, 0, 0)
If $iIntType = $ARRAYUNIQUE_AUTO Then
Local $vFirstElem =(($iDims = 1) ?($aArray[$iBase]) :($aArray[$iColumn][$iBase]) )
If IsInt($vFirstElem) Then
Switch VarGetType($vFirstElem)
Case "Int32"
$iIntType = $ARRAYUNIQUE_FORCE32
Case "Int64"
$iIntType = $ARRAYUNIQUE_FORCE64
EndSwitch
Else
$iIntType = $ARRAYUNIQUE_FORCE32
EndIf
EndIf
ObjEvent("AutoIt.Error", "__ArrayUnique_AutoErrFunc")
Local $oDictionary = ObjCreate("Scripting.Dictionary")
$oDictionary.CompareMode = Number(Not $iCase)
Local $vElem, $sType, $vKey, $bCOMError = False
For $i = $iBase To UBound($aArray) - 1
If $iDims = 1 Then
$vElem = $aArray[$i]
Else
$vElem = $aArray[$i][$iColumn]
EndIf
Switch $iIntType
Case $ARRAYUNIQUE_FORCE32
$oDictionary.Item($vElem)
If @error Then
$bCOMError = True
ExitLoop
EndIf
Case $ARRAYUNIQUE_FORCE64
$sType = VarGetType($vElem)
If $sType = "Int32" Then
$bCOMError = True
ExitLoop
EndIf
$vKey = "#" & $sType & "#" & String($vElem)
If Not $oDictionary.Item($vKey) Then
$oDictionary($vKey) = $vElem
EndIf
Case $ARRAYUNIQUE_MATCH
$sType = VarGetType($vElem)
If StringLeft($sType, 3) = "Int" Then
$vKey = "#Int#" & String($vElem)
Else
$vKey = "#" & $sType & "#" & String($vElem)
EndIf
If Not $oDictionary.Item($vKey) Then
$oDictionary($vKey) = $vElem
EndIf
Case $ARRAYUNIQUE_DISTINCT
$vKey = "#" & VarGetType($vElem) & "#" & String($vElem)
If Not $oDictionary.Item($vKey) Then
$oDictionary($vKey) = $vElem
EndIf
EndSwitch
Next
Local $aValues, $j = 0
If $bCOMError Then
Return SetError(7, 0, 0)
ElseIf $iIntType <> $ARRAYUNIQUE_FORCE32 Then
Local $aValues[$oDictionary.Count]
For $vKey In $oDictionary.Keys()
$aValues[$j] = $oDictionary($vKey)
If StringLeft($vKey, 5) = "#Ptr#" Then
$aValues[$j] = Ptr($aValues[$j])
EndIf
$j += 1
Next
Else
$aValues = $oDictionary.Keys()
EndIf
If $iCount Then
_ArrayInsert($aValues, 0, $oDictionary.Count)
EndIf
Return $aValues
EndFunc
Func __ArrayUnique_AutoErrFunc()
EndFunc
Global Const $BM_CLICK = 0xF5
Global Const $COLOR_BLUE = 0x0000FF
Global Const $TRAY_EVENT_PRIMARYDOUBLE = -13
Global Const $CRYPT_VERIFYCONTEXT = 0xF0000000
Global $__g_aCryptInternalData[3]
Func _Crypt_Startup()
If __Crypt_RefCount() = 0 Then
Local $hAdvapi32 = DllOpen("Advapi32.dll")
If $hAdvapi32 = -1 Then Return SetError(1, 0, False)
__Crypt_DllHandleSet($hAdvapi32)
Local $iProviderID = 24
Local $aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptAcquireContext", "handle*", 0, "ptr", 0, "ptr", 0, "dword", $iProviderID, "dword", $CRYPT_VERIFYCONTEXT)
If @error Or Not $aRet[0] Then
Local $iError = @error + 10, $iExtended = @extended
DllClose(__Crypt_DllHandle())
Return SetError($iError, $iExtended, False)
Else
__Crypt_ContextSet($aRet[1])
EndIf
EndIf
__Crypt_RefCountInc()
Return True
EndFunc
Func _Crypt_Shutdown()
__Crypt_RefCountDec()
If __Crypt_RefCount() = 0 Then
DllCall(__Crypt_DllHandle(), "bool", "CryptReleaseContext", "handle", __Crypt_Context(), "dword", 0)
DllClose(__Crypt_DllHandle())
EndIf
EndFunc
Func _Crypt_DeriveKey($vPassword, $iAlgID, $iHashAlgID = 0x00008003)
Local $aRet = 0, $hBuff = 0, $hCryptHash = 0, $iError = 0, $iExtended = 0, $vReturn = 0
_Crypt_Startup()
Do
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptCreateHash", "handle", __Crypt_Context(), "uint", $iHashAlgID, "ptr", 0, "dword", 0, "handle*", 0)
If @error Or Not $aRet[0] Then
$iError = @error + 10
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
$hCryptHash = $aRet[5]
$hBuff = DllStructCreate("byte[" & BinaryLen($vPassword) & "]")
DllStructSetData($hBuff, 1, $vPassword)
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptHashData", "handle", $hCryptHash, "struct*", $hBuff, "dword", DllStructGetSize($hBuff), "dword", 1)
If @error Or Not $aRet[0] Then
$iError = @error + 20
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptDeriveKey", "handle", __Crypt_Context(), "uint", $iAlgID, "handle", $hCryptHash, "dword", 0x00000001, "handle*", 0)
If @error Or Not $aRet[0] Then
$iError = @error + 30
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
$vReturn = $aRet[5]
Until True
If $hCryptHash <> 0 Then DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyHash", "handle", $hCryptHash)
Return SetError($iError, $iExtended, $vReturn)
EndFunc
Func _Crypt_DestroyKey($hCryptKey)
Local $aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyKey", "handle", $hCryptKey)
Local $iError = @error, $iExtended = @extended
_Crypt_Shutdown()
If $iError Or Not $aRet[0] Then
Return SetError($iError + 10, $iExtended, False)
Else
Return True
EndIf
EndFunc
Func _Crypt_EncryptData($vData, $vCryptKey, $iAlgID, $bFinal = True)
Switch $iAlgID
Case 0
Local $iCalgUsed = __Crypt_GetCalgFromCryptKey($vCryptKey)
If @error Then Return SetError(@error, -1, @extended)
If $iCalgUsed = 0x00006801 Then ContinueCase
Case 0x00006801
If BinaryLen($vData) = 0 Then Return SetError(0, 0, Binary(''))
EndSwitch
Local $iReqBuffSize = 0, $aRet = 0, $hBuff = 0, $iError = 0, $iExtended = 0, $vReturn = 0
_Crypt_Startup()
Do
If $iAlgID <> 0 Then
$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
If @error Then
$iError = @error + 100
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
EndIf
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptEncrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "ptr", 0, "dword*", BinaryLen($vData), "dword", 0)
If @error Or Not $aRet[0] Then
$iError = @error + 20
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
$iReqBuffSize = $aRet[6]
$hBuff = DllStructCreate("byte[" & $iReqBuffSize + 1 & "]")
DllStructSetData($hBuff, 1, $vData)
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptEncrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "struct*", $hBuff, "dword*", BinaryLen($vData), "dword", DllStructGetSize($hBuff) - 1)
If @error Or Not $aRet[0] Then
$iError = @error + 30
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
$vReturn = BinaryMid(DllStructGetData($hBuff, 1), 1, $iReqBuffSize)
Until True
If $iAlgID <> 0 Then _Crypt_DestroyKey($vCryptKey)
_Crypt_Shutdown()
Return SetError($iError, $iExtended, $vReturn)
EndFunc
Func _Crypt_DecryptData($vData, $vCryptKey, $iAlgID, $bFinal = True)
Switch $iAlgID
Case 0
Local $iCalgUsed = __Crypt_GetCalgFromCryptKey($vCryptKey)
If @error Then Return SetError(@error, -1, @extended)
If $iCalgUsed = 0x00006801 Then ContinueCase
Case 0x00006801
If BinaryLen($vData) = 0 Then Return SetError(0, 0, Binary(''))
EndSwitch
Local $aRet = 0, $hBuff = 0, $hTempStruct = 0, $iError = 0, $iExtended = 0, $iPlainTextSize = 0, $vReturn = 0
_Crypt_Startup()
Do
If $iAlgID <> 0 Then
$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
If @error Then
$iError = @error + 100
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
EndIf
$hBuff = DllStructCreate("byte[" & BinaryLen($vData) + 1000 & "]")
If BinaryLen($vData) > 0 Then DllStructSetData($hBuff, 1, $vData)
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptDecrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "struct*", $hBuff, "dword*", BinaryLen($vData))
If @error Or Not $aRet[0] Then
$iError = @error + 20
$iExtended = @extended
$vReturn = -1
ExitLoop
EndIf
$iPlainTextSize = $aRet[6]
$hTempStruct = DllStructCreate("byte[" & $iPlainTextSize + 1 & "]", DllStructGetPtr($hBuff))
$vReturn = BinaryMid(DllStructGetData($hTempStruct, 1), 1, $iPlainTextSize)
Until True
If $iAlgID <> 0 Then _Crypt_DestroyKey($vCryptKey)
_Crypt_Shutdown()
Return SetError($iError, $iExtended, $vReturn)
EndFunc
Func __Crypt_RefCount()
Return $__g_aCryptInternalData[0]
EndFunc
Func __Crypt_RefCountInc()
$__g_aCryptInternalData[0] += 1
EndFunc
Func __Crypt_RefCountDec()
If $__g_aCryptInternalData[0] > 0 Then $__g_aCryptInternalData[0] -= 1
EndFunc
Func __Crypt_DllHandle()
Return $__g_aCryptInternalData[1]
EndFunc
Func __Crypt_DllHandleSet($hAdvapi32)
$__g_aCryptInternalData[1] = $hAdvapi32
EndFunc
Func __Crypt_Context()
Return $__g_aCryptInternalData[2]
EndFunc
Func __Crypt_ContextSet($hCryptContext)
$__g_aCryptInternalData[2] = $hCryptContext
EndFunc
Func __Crypt_GetCalgFromCryptKey($vCryptKey)
Local $tAlgId = DllStructCreate("uint;dword")
DllStructSetData($tAlgId, 2, 4)
Local $aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptGetKeyParam", "handle", $vCryptKey, "dword", 0x00000007, "ptr", DllStructGetPtr($tAlgId, 1), "dword*", DllStructGetPtr($tAlgId, 2), "dword", 0)
If @error Or Not $aRet[0] Then
Return SetError(@error, @extended, 1)
Else
Return DllStructGetData($tAlgId, 1)
EndIf
EndFunc
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagNMHDR = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"
Global Const $tagGDIPRECTF = "struct;float X;float Y;float Width;float Height;endstruct"
Global Const $tagGDIPSTARTUPINPUT = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
Return $aResult
EndFunc
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $LLKHF_EXTENDED = BitShift(0x0100, 8)
Global Const $LLKHF_ALTDOWN = BitShift(0x2000, 8)
Global Const $LLKHF_UP = BitShift(0x8000, 8)
Func _WinAPI_BitBlt($hDestDC, $iXDest, $iYDest, $iWidth, $iHeight, $hSrcDC, $iXSrc, $iYSrc, $iROP)
Local $aResult = DllCall("gdi32.dll", "bool", "BitBlt", "handle", $hDestDC, "int", $iXDest, "int", $iYDest, "int", $iWidth, "int", $iHeight, "handle", $hSrcDC, "int", $iXSrc, "int", $iYSrc, "dword", $iROP)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_CreateCompatibleDC($hDC)
Local $aResult = DllCall("gdi32.dll", "handle", "CreateCompatibleDC", "handle", $hDC)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_DeleteDC($hDC)
Local $aResult = DllCall("gdi32.dll", "bool", "DeleteDC", "handle", $hDC)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_DeleteObject($hObject)
Local $aResult = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hObject)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_GetDC($hWnd)
Local $aResult = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetDlgCtrlID($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetParent($hWnd)
Local $aResult = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_PostMessage($hWnd, $iMsg, $wParam, $lParam)
Local $aResult = DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_ReleaseDC($hWnd, $hDC)
Local $aResult = DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hDC)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_SelectObject($hDC, $hGDIObj)
Local $aResult = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hGDIObj)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__WINVER = __WINVER()
Func __Iif($bTest, $vTrue, $vFalse)
Return $bTest ? $vTrue : $vFalse
EndFunc
Func __WINVER()
Local $tOSVI = DllStructCreate($tagOSVERSIONINFO)
DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
Local $aRet = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $tOSVI)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc
Func _DateAdd($sType, $iNumber, $sDate)
Local $asTimePart[4]
Local $asDatePart[4]
Local $iJulianDate
$sType = StringLeft($sType, 1)
If StringInStr("D,M,Y,w,h,n,s", $sType) = 0 Or $sType = "" Then
Return SetError(1, 0, 0)
EndIf
If Not StringIsInt($iNumber) Then
Return SetError(2, 0, 0)
EndIf
If Not _DateIsValid($sDate) Then
Return SetError(3, 0, 0)
EndIf
_DateTimeSplit($sDate, $asDatePart, $asTimePart)
If $sType = "d" Or $sType = "w" Then
If $sType = "w" Then $iNumber = $iNumber * 7
$iJulianDate = _DateToDayValue($asDatePart[1], $asDatePart[2], $asDatePart[3]) + $iNumber
_DayValueToDate($iJulianDate, $asDatePart[1], $asDatePart[2], $asDatePart[3])
EndIf
If $sType = "m" Then
$asDatePart[2] = $asDatePart[2] + $iNumber
While $asDatePart[2] > 12
$asDatePart[2] = $asDatePart[2] - 12
$asDatePart[1] = $asDatePart[1] + 1
WEnd
While $asDatePart[2] < 1
$asDatePart[2] = $asDatePart[2] + 12
$asDatePart[1] = $asDatePart[1] - 1
WEnd
EndIf
If $sType = "y" Then
$asDatePart[1] = $asDatePart[1] + $iNumber
EndIf
If $sType = "h" Or $sType = "n" Or $sType = "s" Then
Local $iTimeVal = _TimeToTicks($asTimePart[1], $asTimePart[2], $asTimePart[3]) / 1000
If $sType = "h" Then $iTimeVal = $iTimeVal + $iNumber * 3600
If $sType = "n" Then $iTimeVal = $iTimeVal + $iNumber * 60
If $sType = "s" Then $iTimeVal = $iTimeVal + $iNumber
Local $iDay2Add = Int($iTimeVal /(24 * 60 * 60))
$iTimeVal = $iTimeVal - $iDay2Add * 24 * 60 * 60
If $iTimeVal < 0 Then
$iDay2Add = $iDay2Add - 1
$iTimeVal = $iTimeVal + 24 * 60 * 60
EndIf
$iJulianDate = _DateToDayValue($asDatePart[1], $asDatePart[2], $asDatePart[3]) + $iDay2Add
_DayValueToDate($iJulianDate, $asDatePart[1], $asDatePart[2], $asDatePart[3])
_TicksToTime($iTimeVal * 1000, $asTimePart[1], $asTimePart[2], $asTimePart[3])
EndIf
Local $iNumDays = _DaysInMonth($asDatePart[1])
If $iNumDays[$asDatePart[2]] < $asDatePart[3] Then $asDatePart[3] = $iNumDays[$asDatePart[2]]
$sDate = $asDatePart[1] & '/' & StringRight("0" & $asDatePart[2], 2) & '/' & StringRight("0" & $asDatePart[3], 2)
If $asTimePart[0] > 0 Then
If $asTimePart[0] > 2 Then
$sDate = $sDate & " " & StringRight("0" & $asTimePart[1], 2) & ':' & StringRight("0" & $asTimePart[2], 2) & ':' & StringRight("0" & $asTimePart[3], 2)
Else
$sDate = $sDate & " " & StringRight("0" & $asTimePart[1], 2) & ':' & StringRight("0" & $asTimePart[2], 2)
EndIf
EndIf
Return $sDate
EndFunc
Func _DateDiff($sType, $sStartDate, $sEndDate)
$sType = StringLeft($sType, 1)
If StringInStr("d,m,y,w,h,n,s", $sType) = 0 Or $sType = "" Then
Return SetError(1, 0, 0)
EndIf
If Not _DateIsValid($sStartDate) Then
Return SetError(2, 0, 0)
EndIf
If Not _DateIsValid($sEndDate) Then
Return SetError(3, 0, 0)
EndIf
Local $asStartDatePart[4], $asStartTimePart[4], $asEndDatePart[4], $asEndTimePart[4]
_DateTimeSplit($sStartDate, $asStartDatePart, $asStartTimePart)
_DateTimeSplit($sEndDate, $asEndDatePart, $asEndTimePart)
Local $aDaysDiff = _DateToDayValue($asEndDatePart[1], $asEndDatePart[2], $asEndDatePart[3]) - _DateToDayValue($asStartDatePart[1], $asStartDatePart[2], $asStartDatePart[3])
Local $iTimeDiff, $iYearDiff, $iStartTimeInSecs, $iEndTimeInSecs
If $asStartTimePart[0] > 1 And $asEndTimePart[0] > 1 Then
$iStartTimeInSecs = $asStartTimePart[1] * 3600 + $asStartTimePart[2] * 60 + $asStartTimePart[3]
$iEndTimeInSecs = $asEndTimePart[1] * 3600 + $asEndTimePart[2] * 60 + $asEndTimePart[3]
$iTimeDiff = $iEndTimeInSecs - $iStartTimeInSecs
If $iTimeDiff < 0 Then
$aDaysDiff = $aDaysDiff - 1
$iTimeDiff = $iTimeDiff + 24 * 60 * 60
EndIf
Else
$iTimeDiff = 0
EndIf
Select
Case $sType = "d"
Return $aDaysDiff
Case $sType = "m"
$iYearDiff = $asEndDatePart[1] - $asStartDatePart[1]
Local $iMonthDiff = $asEndDatePart[2] - $asStartDatePart[2] + $iYearDiff * 12
If $asEndDatePart[3] < $asStartDatePart[3] Then $iMonthDiff = $iMonthDiff - 1
$iStartTimeInSecs = $asStartTimePart[1] * 3600 + $asStartTimePart[2] * 60 + $asStartTimePart[3]
$iEndTimeInSecs = $asEndTimePart[1] * 3600 + $asEndTimePart[2] * 60 + $asEndTimePart[3]
$iTimeDiff = $iEndTimeInSecs - $iStartTimeInSecs
If $asEndDatePart[3] = $asStartDatePart[3] And $iTimeDiff < 0 Then $iMonthDiff = $iMonthDiff - 1
Return $iMonthDiff
Case $sType = "y"
$iYearDiff = $asEndDatePart[1] - $asStartDatePart[1]
If $asEndDatePart[2] < $asStartDatePart[2] Then $iYearDiff = $iYearDiff - 1
If $asEndDatePart[2] = $asStartDatePart[2] And $asEndDatePart[3] < $asStartDatePart[3] Then $iYearDiff = $iYearDiff - 1
$iStartTimeInSecs = $asStartTimePart[1] * 3600 + $asStartTimePart[2] * 60 + $asStartTimePart[3]
$iEndTimeInSecs = $asEndTimePart[1] * 3600 + $asEndTimePart[2] * 60 + $asEndTimePart[3]
$iTimeDiff = $iEndTimeInSecs - $iStartTimeInSecs
If $asEndDatePart[2] = $asStartDatePart[2] And $asEndDatePart[3] = $asStartDatePart[3] And $iTimeDiff < 0 Then $iYearDiff = $iYearDiff - 1
Return $iYearDiff
Case $sType = "w"
Return Int($aDaysDiff / 7)
Case $sType = "h"
Return $aDaysDiff * 24 + Int($iTimeDiff / 3600)
Case $sType = "n"
Return $aDaysDiff * 24 * 60 + Int($iTimeDiff / 60)
Case $sType = "s"
Return $aDaysDiff * 24 * 60 * 60 + $iTimeDiff
EndSelect
EndFunc
Func _DateIsLeapYear($iYear)
If StringIsInt($iYear) Then
Select
Case Mod($iYear, 4) = 0 And Mod($iYear, 100) <> 0
Return 1
Case Mod($iYear, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _DateIsValid($sDate)
Local $asDatePart[4], $asTimePart[4]
_DateTimeSplit($sDate, $asDatePart, $asTimePart)
If Not StringIsInt($asDatePart[1]) Then Return 0
If Not StringIsInt($asDatePart[2]) Then Return 0
If Not StringIsInt($asDatePart[3]) Then Return 0
$asDatePart[1] = Int($asDatePart[1])
$asDatePart[2] = Int($asDatePart[2])
$asDatePart[3] = Int($asDatePart[3])
Local $iNumDays = _DaysInMonth($asDatePart[1])
If $asDatePart[1] < 1000 Or $asDatePart[1] > 2999 Then Return 0
If $asDatePart[2] < 1 Or $asDatePart[2] > 12 Then Return 0
If $asDatePart[3] < 1 Or $asDatePart[3] > $iNumDays[$asDatePart[2]] Then Return 0
If $asTimePart[0] < 1 Then Return 1
If $asTimePart[0] < 2 Then Return 0
If $asTimePart[0] = 2 Then $asTimePart[3] = "00"
If Not StringIsInt($asTimePart[1]) Then Return 0
If Not StringIsInt($asTimePart[2]) Then Return 0
If Not StringIsInt($asTimePart[3]) Then Return 0
$asTimePart[1] = Int($asTimePart[1])
$asTimePart[2] = Int($asTimePart[2])
$asTimePart[3] = Int($asTimePart[3])
If $asTimePart[1] < 0 Or $asTimePart[1] > 23 Then Return 0
If $asTimePart[2] < 0 Or $asTimePart[2] > 59 Then Return 0
If $asTimePart[3] < 0 Or $asTimePart[3] > 59 Then Return 0
Return 1
EndFunc
Func _DateTimeSplit($sDate, ByRef $aDatePart, ByRef $iTimePart)
Local $sDateTime = StringSplit($sDate, " T")
If $sDateTime[0] > 0 Then $aDatePart = StringSplit($sDateTime[1], "/-.")
If $sDateTime[0] > 1 Then
$iTimePart = StringSplit($sDateTime[2], ":")
If UBound($iTimePart) < 4 Then ReDim $iTimePart[4]
Else
Dim $iTimePart[4]
EndIf
If UBound($aDatePart) < 4 Then ReDim $aDatePart[4]
For $x = 1 To 3
If StringIsInt($aDatePart[$x]) Then
$aDatePart[$x] = Int($aDatePart[$x])
Else
$aDatePart[$x] = -1
EndIf
If StringIsInt($iTimePart[$x]) Then
$iTimePart[$x] = Int($iTimePart[$x])
Else
$iTimePart[$x] = 0
EndIf
Next
Return 1
EndFunc
Func _DateToDayValue($iYear, $iMonth, $iDay)
If Not _DateIsValid(StringFormat("%04d/%02d/%02d", $iYear, $iMonth, $iDay)) Then
Return SetError(1, 0, "")
EndIf
If $iMonth < 3 Then
$iMonth = $iMonth + 12
$iYear = $iYear - 1
EndIf
Local $i_FactorA = Int($iYear / 100)
Local $i_FactorB = Int($i_FactorA / 4)
Local $i_FactorC = 2 - $i_FactorA + $i_FactorB
Local $i_FactorE = Int(1461 *($iYear + 4716) / 4)
Local $i_FactorF = Int(153 *($iMonth + 1) / 5)
Local $iJulianDate = $i_FactorC + $iDay + $i_FactorE + $i_FactorF - 1524.5
Return $iJulianDate
EndFunc
Func _DayValueToDate($iJulianDate, ByRef $iYear, ByRef $iMonth, ByRef $iDay)
If $iJulianDate < 0 Or Not IsNumber($iJulianDate) Then
Return SetError(1, 0, 0)
EndIf
Local $i_FactorZ = Int($iJulianDate + 0.5)
Local $i_FactorW = Int(($i_FactorZ - 1867216.25) / 36524.25)
Local $i_FactorX = Int($i_FactorW / 4)
Local $i_FactorA = $i_FactorZ + 1 + $i_FactorW - $i_FactorX
Local $i_FactorB = $i_FactorA + 1524
Local $i_FactorC = Int(($i_FactorB - 122.1) / 365.25)
Local $i_FactorD = Int(365.25 * $i_FactorC)
Local $i_FactorE = Int(($i_FactorB - $i_FactorD) / 30.6001)
Local $i_FactorF = Int(30.6001 * $i_FactorE)
$iDay = $i_FactorB - $i_FactorD - $i_FactorF
If $i_FactorE - 1 < 13 Then
$iMonth = $i_FactorE - 1
Else
$iMonth = $i_FactorE - 13
EndIf
If $iMonth < 3 Then
$iYear = $i_FactorC - 4715
Else
$iYear = $i_FactorC - 4716
EndIf
$iYear = StringFormat("%04d", $iYear)
$iMonth = StringFormat("%02d", $iMonth)
$iDay = StringFormat("%02d", $iDay)
Return $iYear & "/" & $iMonth & "/" & $iDay
EndFunc
Func _NowCalc()
Return @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
EndFunc
Func _TicksToTime($iTicks, ByRef $iHours, ByRef $iMins, ByRef $iSecs)
If Number($iTicks) > 0 Then
$iTicks = Int($iTicks / 1000)
$iHours = Int($iTicks / 3600)
$iTicks = Mod($iTicks, 3600)
$iMins = Int($iTicks / 60)
$iSecs = Mod($iTicks, 60)
Return 1
ElseIf Number($iTicks) = 0 Then
$iHours = 0
$iTicks = 0
$iMins = 0
$iSecs = 0
Return 1
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _TimeToTicks($iHours = @HOUR, $iMins = @MIN, $iSecs = @SEC)
If StringIsInt($iHours) And StringIsInt($iMins) And StringIsInt($iSecs) Then
Local $iTicks = 1000 *((3600 * $iHours) +(60 * $iMins) + $iSecs)
Return $iTicks
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _DaysInMonth($iYear)
Local $aDays = [12, 31,(_DateIsLeapYear($iYear) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $aDays
EndFunc
Func _FileCountLines($sFilePath)
Local $hFileOpen = FileOpen($sFilePath, 0)
If $hFileOpen = -1 Then Return SetError(1, 0, 0)
Local $sFileRead = StringStripWS(FileRead($hFileOpen), 2)
FileClose($hFileOpen)
Return UBound(StringRegExp($sFileRead, "\R", 3)) + 1 - Int($sFileRead = "")
EndFunc
Func _FileListToArray($sFilePath, $sFilter = "*", $iFlag = 0, $bReturnPath = False)
Local $sDelimiter = "|", $sFileList = "", $sFileName = "", $sFullPath = ""
$sFilePath = StringRegExpReplace($sFilePath, "[\\/]+$", "") & "\"
If $iFlag = Default Then $iFlag = 0
If $bReturnPath Then $sFullPath = $sFilePath
If $sFilter = Default Then $sFilter = "*"
If Not FileExists($sFilePath) Then Return SetError(1, 0, 0)
If StringRegExp($sFilter, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 0, 0)
Local $hSearch = FileFindFirstFile($sFilePath & $sFilter)
If @error Then Return SetError(4, 0, 0)
While 1
$sFileName = FileFindNextFile($hSearch)
If @error Then ExitLoop
If($iFlag + @extended = 2) Then ContinueLoop
$sFileList &= $sDelimiter & $sFullPath & $sFileName
WEnd
FileClose($hSearch)
If $sFileList = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($sFileList, 1), $sDelimiter)
EndFunc
Func _PathSplit($sFilePath, ByRef $sDrive, ByRef $sDir, ByRef $sFileName, ByRef $sExtension)
Local $aArray = StringRegExp($sFilePath, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", 1)
If @error Then
ReDim $aArray[5]
$aArray[0] = $sFilePath
EndIf
$sDrive = $aArray[1]
If StringLeft($aArray[2], 1) == "/" Then
$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\/")
Else
$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\\")
EndIf
$aArray[2] = $sDir
$sFileName = $aArray[3]
$sExtension = $aArray[4]
Return $aArray
EndFunc
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_EVENT_PRIMARYDOWN = -7
Global Const $GUI_EVENT_PRIMARYUP = -8
Global Const $GUI_EVENT_SECONDARYDOWN = -9
Global Const $GUI_EVENT_SECONDARYUP = -10
Global Const $GUI_EVENT_MOUSEMOVE = -11
Func _GUICtrlListBox_GetCurSel($hWnd)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, 0x0188)
Else
Return GUICtrlSendMsg($hWnd, 0x0188, 0, 0)
EndIf
EndFunc
Func _GUICtrlListBox_ResetContent($hWnd)
If IsHWnd($hWnd) Then
_SendMessage($hWnd, 0x0184)
Else
GUICtrlSendMsg($hWnd, 0x0184, 0, 0)
EndIf
EndFunc
Global Const $TCM_SETCURSEL =(0x1300 + 12)
Global Const $TCN_FIRST = -550
Global Const $TCN_SELCHANGE =($TCN_FIRST - 1)
Global Const $TCN_SELCHANGING =($TCN_FIRST - 2)
Global Const $__TABCONSTANT_WM_NOTIFY = 0x004E
Func _GUICtrlTab_ActivateTab($hWnd, $iIndex)
Local $nIndX
If $hWnd = -1 Then $hWnd = GUICtrlGetHandle(-1)
If IsHWnd($hWnd) Then
$nIndX = _WinAPI_GetDlgCtrlID($hWnd)
Else
$nIndX = $hWnd
$hWnd = GUICtrlGetHandle($hWnd)
EndIf
Local $hParent = _WinAPI_GetParent($hWnd)
If @error Then Return SetError(1, 0, -1)
Local $tNmhdr = DllStructCreate($tagNMHDR)
DllStructSetData($tNmhdr, 1, $hWnd)
DllStructSetData($tNmhdr, 2, $nIndX)
DllStructSetData($tNmhdr, 3, $TCN_SELCHANGING)
_SendMessage($hParent, $__TABCONSTANT_WM_NOTIFY, $nIndX, $tNmhdr, 0, "wparam", "struct*")
Local $iRet = _GUICtrlTab_SetCurSel($hWnd, $iIndex)
DllStructSetData($tNmhdr, 3, $TCN_SELCHANGE)
_SendMessage($hParent, $__TABCONSTANT_WM_NOTIFY, $nIndX, $tNmhdr, 0, "wparam", "struct*")
Return $iRet
EndFunc
Func _GUICtrlTab_SetCurSel($hWnd, $iIndex)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $TCM_SETCURSEL, $iIndex)
Else
Return GUICtrlSendMsg($hWnd, $TCM_SETCURSEL, $iIndex, 0)
EndIf
EndFunc
Global Const $TVI_ROOT = 0xFFFF0000
Global Const $TVM_DELETEITEM = 0x1100 + 1
Global Const $TVM_GETCOUNT = 0x1100 + 5
Func _GUICtrlTreeView_DeleteAll($hWnd)
Local $iCount = 0
If IsHWnd($hWnd) Then
_SendMessage($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT)
$iCount = _GUICtrlTreeView_GetCount($hWnd)
If $iCount Then Return GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT) <> 0
Return True
Else
GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT)
$iCount = _GUICtrlTreeView_GetCount($hWnd)
If $iCount Then Return _SendMessage($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT) <> 0
Return True
EndIf
Return False
EndFunc
Func _GUICtrlTreeView_GetCount($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $TVM_GETCOUNT)
EndFunc
Func _Max($iNum1, $iNum2)
If Not IsNumber($iNum1) Then Return SetError(1, 0, 0)
If Not IsNumber($iNum2) Then Return SetError(2, 0, 0)
Return($iNum1 > $iNum2) ? $iNum1 : $iNum2
EndFunc
Func _Singleton($sOccurrenceName, $iFlag = 0)
Local Const $ERROR_ALREADY_EXISTS = 183
Local Const $SECURITY_DESCRIPTOR_REVISION = 1
Local $tSecurityAttributes = 0
If BitAND($iFlag, 2) Then
Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", "struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", "struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
DllStructSetData($tSecurityAttributes, 3, 0)
EndIf
EndIf
EndIf
Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurrenceName)
If @error Then Return SetError(@error, @extended, 0)
Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
If @error Then Return SetError(@error, @extended, 0)
If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
If BitAND($iFlag, 1) Then
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
If @error Then Return SetError(@error, @extended, 0)
Return SetError($aLastError[0], $aLastError[0], 0)
Else
Exit -1
EndIf
EndIf
Return $aHandle[0]
EndFunc
Global Const $__tagWinAPICom_GUID = "struct;ulong Data1;ushort Data2;ushort Data3;byte Data4[8];endstruct"
Func _WinAPI_CoTaskMemFree($pMemory)
DllCall('ole32.dll', 'none', 'CoTaskMemFree', 'ptr', $pMemory)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Func _WinAPI_CreateGUID()
Local $tGUID = DllStructCreate($__tagWinAPICom_GUID)
Local $aReturn = DllCall('ole32.dll', 'long', 'CoCreateGuid', 'struct*', $tGUID)
If @error Then Return SetError(@error, @extended, '')
If $aReturn[0] Then Return SetError(10, $aReturn[0], '')
$aReturn = DllCall('ole32.dll', 'int', 'StringFromGUID2', 'struct*', $tGUID, 'wstr', '', 'int', 65536)
If @error Or Not $aReturn[0] Then Return SetError(@error + 20, @extended, '')
Return $aReturn[2]
EndFunc
Func _WinAPI_PathSearchAndQualify($sFilePath, $bExists = False)
Local $aRet = DllCall('shlwapi.dll', 'bool', 'PathSearchAndQualifyW', 'wstr', $sFilePath, 'wstr', '', 'int', 4096)
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, '')
If $bExists And Not FileExists($aRet[2]) Then Return SetError(20, 0, '')
Return $aRet[2]
EndFunc
Func _WinAPI_ShellGetPathFromIDList($pPIDL)
Local $aRet = DllCall('shell32.dll', 'bool', 'SHGetPathFromIDListW', 'struct*', $pPIDL, 'wstr', '')
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, '')
Return $aRet[2]
EndFunc
Func _WinAPI_ShellILCreateFromPath($sFilePath)
Local $aRet = DllCall('shell32.dll', 'long', 'SHILCreateFromPath', 'wstr', $sFilePath, 'ptr*', 0, 'dword*', 0)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then Return SetError(10, $aRet[0], 0)
Return $aRet[2]
EndFunc
Global Const $tagPRINTDLG = __Iif(@AutoItX64, '', 'align 2;') & 'dword Size;hwnd hOwner;handle hDevMode;handle hDevNames;handle hDC;dword Flags;word FromPage;word ToPage;word MinPage;word MaxPage;word Copies;handle hInstance;lparam lParam;ptr PrintHook;ptr SetupHook;ptr PrintTemplateName;ptr SetupTemplateName;handle hPrintTemplate;handle hSetupTemplate'
Func _WinAPI_BrowseForFolderDlg($sRoot = '', $sText = '', $iFlags = 0, $pBrowseProc = 0, $lParam = 0, $hParent = 0)
Local Const $tagBROWSEINFO = 'hwnd hwndOwner;ptr pidlRoot;ptr pszDisplayName; ptr lpszTitle;uint ulFlags;ptr lpfn;lparam lParam;int iImage'
Local $tBROWSEINFO = DllStructCreate($tagBROWSEINFO & ';wchar[' &(StringLen($sText) + 1) & '];wchar[260]')
Local $pPIDL = 0, $sResult = ''
If StringStripWS($sRoot, 1 + 2) Then
Local $sPath = _WinAPI_PathSearchAndQualify($sRoot, 1)
If @error Then
$sPath = $sRoot
EndIf
$pPIDL = _WinAPI_ShellILCreateFromPath($sPath)
If @error Then
EndIf
EndIf
DllStructSetData($tBROWSEINFO, 1, $hParent)
DllStructSetData($tBROWSEINFO, 2, $pPIDL)
DllStructSetData($tBROWSEINFO, 3, DllStructGetPtr($tBROWSEINFO, 10))
DllStructSetData($tBROWSEINFO, 4, DllStructGetPtr($tBROWSEINFO, 9))
DllStructSetData($tBROWSEINFO, 5, $iFlags)
DllStructSetData($tBROWSEINFO, 6, $pBrowseProc)
DllStructSetData($tBROWSEINFO, 7, $lParam)
DllStructSetData($tBROWSEINFO, 8, 0)
DllStructSetData($tBROWSEINFO, 9, $sText)
Local $aRet = DllCall('shell32.dll', 'ptr', 'SHBrowseForFolderW', 'struct*', $tBROWSEINFO)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, '')
$sResult = _WinAPI_ShellGetPathFromIDList($aRet[0])
_WinAPI_CoTaskMemFree($aRet[0])
If $pPIDL Then
_WinAPI_CoTaskMemFree($pPIDL)
EndIf
If Not $sResult Then Return SetError(10, 0, '')
Return $sResult
EndFunc
Func _WinAPI_StrFormatByteSize($iSize)
Local $aRet = DllCall('shlwapi.dll', 'ptr', 'StrFormatByteSizeW', 'int64', $iSize, 'wstr', '', 'uint', 1024)
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, '')
Return $aRet[2]
EndFunc
Func _WinAPI_DefineDosDevice($sDevice, $iFlags, $sFilePath = '')
Local $sTypeOfPath = 'wstr'
If Not StringStripWS($sFilePath, 1 + 2) Then
$sTypeOfPath = 'ptr'
$sFilePath = 0
EndIf
Local $aRet = DllCall('kernel32.dll', 'bool', 'DefineDosDeviceW', 'dword', $iFlags, 'wstr', $sDevice, $sTypeOfPath, $sFilePath)
If @error Then Return SetError(@error, @extended, False)
Return $aRet[0]
EndFunc
Func _WinAPI_GetFileAttributes($sFilePath)
Local $aRet = DllCall('kernel32.dll', 'dword', 'GetFileAttributesW', 'wstr', $sFilePath)
If @error Or($aRet[0] = 4294967295) Then Return SetError(@error, @extended, 0)
Return $aRet[0]
EndFunc
Func _WinAPI_GetLogicalDrives()
Local $aRet = DllCall('kernel32.dll', 'dword', 'GetLogicalDrives')
If @error Then Return SetError(@error, @extended, 0)
Return $aRet[0]
EndFunc
Global Const $WS_CAPTION = 0x00C00000
Global $__g_hGDIPBrush = 0
Global $__g_hGDIPDll = 0
Global $__g_hGDIPPen = 0
Global $__g_iGDIPRef = 0
Global $__g_iGDIPToken = 0
Global $__g_bGDIP_V1_0 = True
Func _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $hGraphics)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateBitmapFromGraphics", "int", $iWidth, "int", $iHeight, "handle", $hGraphics, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[4]
EndFunc
Func _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap, $iARGB = 0xFF000000)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateHBITMAPFromBitmap", "handle", $hBitmap, "handle*", 0, "dword", $iARGB)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_BitmapDispose($hBitmap)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDisposeImage", "handle", $hBitmap)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_BrushCreateSolid($iARGB = 0xFF000000)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateSolidFill", "int", $iARGB, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_BrushDispose($hBrush)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeleteBrush", "handle", $hBrush)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_FontCreate($hFamily, $fSize, $iStyle = 0, $iUnit = 3)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateFont", "handle", $hFamily, "float", $fSize, "int", $iStyle, "int", $iUnit, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[5]
EndFunc
Func _GDIPlus_FontDispose($hFont)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeleteFont", "handle", $hFont)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_FontFamilyCreate($sFamily, $pCollection = 0)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateFontFamilyFromName", "wstr", $sFamily, "ptr", $pCollection, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[3]
EndFunc
Func _GDIPlus_FontFamilyDispose($hFamily)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeleteFontFamily", "handle", $hFamily)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsClear($hGraphics, $iARGB = 0xFF000000)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGraphicsClear", "handle", $hGraphics, "dword", $iARGB)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsCreateFromHDC($hDC)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateFromHDC", "handle", $hDC, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_GraphicsCreateFromHWND($hWnd)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateFromHWND", "hwnd", $hWnd, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_GraphicsDispose($hGraphics)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeleteGraphics", "handle", $hGraphics)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsDrawImage($hGraphics, $hImage, $nX, $nY)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDrawImage", "handle", $hGraphics, "handle", $hImage, "float", $nX, "float", $nY)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsDrawPath($hGraphics, $hPath, $hPen = 0)
__GDIPlus_PenDefCreate($hPen)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDrawPath", "handle", $hGraphics, "handle", $hPen, "handle", $hPath)
__GDIPlus_PenDefDispose()
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsDrawPie($hGraphics, $nX, $nY, $nWidth, $nHeight, $fStartAngle, $fSweepAngle, $hPen = 0)
__GDIPlus_PenDefCreate($hPen)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDrawPie", "handle", $hGraphics, "handle", $hPen, "float", $nX, "float", $nY, "float", $nWidth, "float", $nHeight, "float", $fStartAngle, "float", $fSweepAngle)
__GDIPlus_PenDefDispose()
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsDrawRect($hGraphics, $nX, $nY, $nWidth, $nHeight, $hPen = 0)
__GDIPlus_PenDefCreate($hPen)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDrawRectangle", "handle", $hGraphics, "handle", $hPen, "float", $nX, "float", $nY, "float", $nWidth, "float", $nHeight)
__GDIPlus_PenDefDispose()
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsDrawStringEx($hGraphics, $sString, $hFont, $tLayout, $hFormat, $hBrush)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDrawString", "handle", $hGraphics, "wstr", $sString, "int", -1, "handle", $hFont, "struct*", $tLayout, "handle", $hFormat, "handle", $hBrush)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsFillPath($hGraphics, $hPath, $hBrush = 0)
__GDIPlus_BrushDefCreate($hBrush)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipFillPath", "handle", $hGraphics, "handle", $hBrush, "handle", $hPath)
__GDIPlus_BrushDefDispose()
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsFillPie($hGraphics, $nX, $nY, $nWidth, $nHeight, $fStartAngle, $fSweepAngle, $hBrush = 0)
__GDIPlus_BrushDefCreate($hBrush)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipFillPie", "handle", $hGraphics, "handle", $hBrush, "float", $nX, "float", $nY, "float", $nWidth, "float", $nHeight, "float", $fStartAngle, "float", $fSweepAngle)
__GDIPlus_BrushDefDispose()
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsFillRect($hGraphics, $nX, $nY, $nWidth, $nHeight, $hBrush = 0)
__GDIPlus_BrushDefCreate($hBrush)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipFillRectangle", "handle", $hGraphics, "handle", $hBrush, "float", $nX, "float", $nY, "float", $nWidth, "float", $nHeight)
__GDIPlus_BrushDefDispose()
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsSetClipRect($hGraphics, $nX, $nY, $nWidth, $nHeight, $iCombineMode = 0)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetClipRect", "handle", $hGraphics, "float", $nX, "float", $nY, "float", $nWidth, "float", $nHeight, "int", $iCombineMode)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_GraphicsSetSmoothingMode($hGraphics, $iSmooth)
If $iSmooth < 0 Or $iSmooth > 5 Then $iSmooth = 0
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetSmoothingMode", "handle", $hGraphics, "int", $iSmooth)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_ImageDispose($hImage)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDisposeImage", "handle", $hImage)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_ImageGetGraphicsContext($hImage)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetImageGraphicsContext", "handle", $hImage, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_PathAddArc($hPath, $nX, $nY, $nWidth, $nHeight, $fStartAngle, $fSweepAngle)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipAddPathArc", "handle", $hPath, "float", $nX, "float", $nY, "float", $nWidth, "float", $nHeight, "float", $fStartAngle, "float", $fSweepAngle)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_PathCloseFigure($hPath)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipClosePathFigure", "handle", $hPath)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_PathCreate($iFillMode = 0)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreatePath", "int", $iFillMode, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_PathDispose($hPath)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeletePath", "handle", $hPath)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_PenCreate($iARGB = 0xFF000000, $nWidth = 1, $iUnit = 2)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreatePen1", "dword", $iARGB, "float", $nWidth, "int", $iUnit, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[4]
EndFunc
Func _GDIPlus_PenDispose($hPen)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeletePen", "handle", $hPen)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_RectFCreate($nX = 0, $nY = 0, $nWidth = 0, $nHeight = 0)
Local $tRECTF = DllStructCreate($tagGDIPRECTF)
DllStructSetData($tRECTF, "X", $nX)
DllStructSetData($tRECTF, "Y", $nY)
DllStructSetData($tRECTF, "Width", $nWidth)
DllStructSetData($tRECTF, "Height", $nHeight)
Return $tRECTF
EndFunc
Func _GDIPlus_Shutdown()
If $__g_hGDIPDll = 0 Then Return SetError(-1, -1, False)
$__g_iGDIPRef -= 1
If $__g_iGDIPRef = 0 Then
DllCall($__g_hGDIPDll, "none", "GdiplusShutdown", "ulong_ptr", $__g_iGDIPToken)
DllClose($__g_hGDIPDll)
$__g_hGDIPDll = 0
EndIf
Return True
EndFunc
Func _GDIPlus_Startup($sGDIPDLL = Default, $bRetDllHandle = False)
$__g_iGDIPRef += 1
If $__g_iGDIPRef > 1 Then Return True
If $sGDIPDLL = Default Then $sGDIPDLL = "gdiplus.dll"
$__g_hGDIPDll = DllOpen($sGDIPDLL)
If $__g_hGDIPDll = -1 Then
$__g_iGDIPRef = 0
Return SetError(1, 2, False)
EndIf
Local $sVer = FileGetVersion($sGDIPDLL)
$sVer = StringSplit($sVer, ".")
If $sVer[1] > 5 Then $__g_bGDIP_V1_0 = False
Local $tInput = DllStructCreate($tagGDIPSTARTUPINPUT)
Local $tToken = DllStructCreate("ulong_ptr Data")
DllStructSetData($tInput, "Version", 1)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdiplusStartup", "struct*", $tToken, "struct*", $tInput, "ptr", 0)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
$__g_iGDIPToken = DllStructGetData($tToken, "Data")
If $bRetDllHandle Then Return $__g_hGDIPDll
Return SetExtended($sVer[1], True)
EndFunc
Func _GDIPlus_StringFormatCreate($iFormat = 0, $iLangID = 0)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateStringFormat", "int", $iFormat, "word", $iLangID, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[3]
EndFunc
Func _GDIPlus_StringFormatDispose($hFormat)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDeleteStringFormat", "handle", $hFormat)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_StringFormatSetAlign($hStringFormat, $iFlag)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipSetStringFormatAlign", "handle", $hStringFormat, "int", $iFlag)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func __GDIPlus_BrushDefCreate(ByRef $hBrush)
If $hBrush = 0 Then
$__g_hGDIPBrush = _GDIPlus_BrushCreateSolid()
$hBrush = $__g_hGDIPBrush
EndIf
EndFunc
Func __GDIPlus_BrushDefDispose($iCurError = @error, $iCurExtended = @extended)
If $__g_hGDIPBrush <> 0 Then
_GDIPlus_BrushDispose($__g_hGDIPBrush)
$__g_hGDIPBrush = 0
EndIf
Return SetError($iCurError, $iCurExtended)
EndFunc
Func __GDIPlus_PenDefCreate(ByRef $hPen)
If $hPen = 0 Then
$__g_hGDIPPen = _GDIPlus_PenCreate()
$hPen = $__g_hGDIPPen
EndIf
EndFunc
Func __GDIPlus_PenDefDispose($iCurError = @error, $iCurExtended = @extended)
If $__g_hGDIPPen <> 0 Then
_GDIPlus_PenDispose($__g_hGDIPPen)
$__g_hGDIPPen = 0
EndIf
Return SetError($iCurError, $iCurExtended)
EndFunc
Global $g_hMovingGUI = 0
Global $g_iAutoit_Def_BK_Color = __GUICtrlFFLabel_GetWindowBkColor()
Global $g_hRefreshCB
Global $g_ahGraphics[1] = [0]
Global $g_ahDCs[1] = [0]
Global $g_aRefreshTimer = 0
Global Enum $g_FF_hGUI, $g_FF_iGraphicsIndex, $g_iFF_DCIndex, $g_FF_bIsMinimized, $g_FF_hBitmap, $g_FF_hBuffer, $g_FF_hBrush, $g_FF_FontFamily, $g_FF_hStringformat, $g_FF_Layout, $g_FF_hFont, $g_FF_iLeft, $g_FF_iTop, $g_FF_iWidth, $g_FF_iHeight, $g_FF_sRestore, $g_FF_bRemoved, $g_FF_iDef_BG_Color, $g_FF_Max
Global $g_aGDILbs[1][$g_FF_Max]
$g_aGDILbs[0][0] = 0
Func _GUICtrlFFLabel_Create($hWnd, $sText, $iLeft, $iTop, $iWidth, $iHeight, $iFontSize = 8.5, $sFontFamily = 'Microsoft Sans Serif', $iFontStyle = 0, $iAlign = 0, $iColor = 0xFF000000)
If $sFontFamily = -1 Or $sFontFamily = Default Then $sFontFamily = 'Microsoft Sans Serif'
If $iFontSize = -1 Or $iFontSize = Default Then $iFontSize = 8.5
If $iFontStyle = -1 Or $iFontStyle = Default Then $iFontStyle = 0
If $iAlign = -1 Or $iAlign = Default Then $iAlign = 0
If $iColor = -1 Or $iColor = Default Then $iColor = 0xFF000000
ReDim $g_aGDILbs[UBound($g_aGDILbs) + 1][$g_FF_Max]
$g_aGDILbs[0][0] += 1
If $g_aGDILbs[0][0] = 1 Then
_GDIPlus_Startup()
$g_hRefreshCB = DllCallbackRegister('_GUICtrlFFLabel_Refresh', 'none', '')
OnAutoItExitRegister('__GUICtrlFFLabel_Dispose')
GUIRegisterMsg(0x0214, '__GUICtrlFFLabel_WM_SIZING')
GUIRegisterMsg(0x0005, '__GUICtrlFFLabel_WM_SIZE')
GUIRegisterMsg(0x0232, '__GUICtrlFFLabel_WM_EXITSIZEMOVE')
GUIRegisterMsg(0x0231, '__GUICtrlFFLabel_WM_ENTERSIZEMOVE')
EndIf
__GUICtrlFFLabel_Graphics_N_DC($g_aGDILbs[0][0], $hWnd)
__GUICtrlFFLabel_VerifyARGB($iColor)
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hGUI] = $hWnd
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iLeft] = $iLeft
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iTop] = $iTop
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iWidth] = $iWidth
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iHeight] = $iHeight
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_bIsMinimized] = False
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iDef_BG_Color] = $g_iAutoit_Def_BK_Color
Local $iGraphicsIndex = $g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iGraphicsIndex]
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBitmap] = _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $g_ahGraphics[$iGraphicsIndex])
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBuffer] = _GDIPlus_ImageGetGraphicsContext($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBitmap])
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBrush] = _GDIPlus_BrushCreateSolid($iColor)
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_FontFamily] = _GDIPlus_FontFamilyCreate($sFontFamily)
If $iAlign < 3 Then
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hStringformat] = _GDIPlus_StringFormatCreate()
_GDIPlus_StringFormatSetAlign($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hStringformat], $iAlign)
If @error Then ConsoleWrite('error setting alignment' & @CRLF)
EndIf
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hFont] = _GDIPlus_FontCreate($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_FontFamily], $iFontSize, $iFontStyle)
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_Layout] = _GDIPlus_RectFCreate(0, 0, $iWidth, $iHeight)
$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_bRemoved] = False
_GUICtrlFFLabel_SetData($g_aGDILbs[0][0], $sText)
Return $g_aGDILbs[0][0]
EndFunc
Func _GUICtrlFFLabel_SetData($iIndex, $sText, $iBackGround = Default)
If $iIndex > $g_aGDILbs[0][0] Or $g_aGDILbs[$iIndex][$g_FF_bRemoved] Then Return SetError(-1)
$g_aGDILbs[$iIndex][$g_FF_sRestore] = $sText
If $g_aGDILbs[$iIndex][$g_FF_bIsMinimized] Then Return
If $iBackGround = Default Then $iBackGround = $g_aGDILbs[$iIndex][$g_FF_iDef_BG_Color]
_GDIPlus_GraphicsClear($g_aGDILbs[$iIndex][$g_FF_hBuffer], $iBackGround)
_GDIPlus_GraphicsSetSmoothingMode($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBuffer], 0)
_GDIPlus_GraphicsDrawStringEx($g_aGDILbs[$iIndex][$g_FF_hBuffer], $sText, $g_aGDILbs[$iIndex][$g_FF_hFont], $g_aGDILbs[$iIndex][$g_FF_Layout], $g_aGDILbs[$iIndex][$g_FF_hStringformat], $g_aGDILbs[$iIndex][$g_FF_hBrush])
$g_aGDILbs[$iIndex][$g_FF_sRestore] = $sText
__GUICtrlFFLabel_WriteBuffer($iIndex)
EndFunc
Func _GUICtrlFFLabel_Delete($iIndex)
If $iIndex > $g_aGDILbs[0][0] Or $g_aGDILbs[$iIndex][$g_FF_bRemoved] Then Return SetError(-1)
_GUICtrlFFLabel_SetData($iIndex, '')
_GDIPlus_FontDispose($g_aGDILbs[$iIndex][$g_FF_hFont])
_GDIPlus_StringFormatDispose($g_aGDILbs[$iIndex][$g_FF_hStringformat])
_GDIPlus_FontFamilyDispose($g_aGDILbs[$iIndex][$g_FF_FontFamily])
_GDIPlus_BrushDispose($g_aGDILbs[$iIndex][$g_FF_hBrush])
_GDIPlus_GraphicsDispose($g_aGDILbs[$iIndex][$g_FF_hBuffer])
_GDIPlus_ImageDispose($g_aGDILbs[$iIndex][$g_FF_hBitmap])
$g_aGDILbs[$iIndex][$g_FF_bRemoved] = True
EndFunc
Func _GUICtrlFFLabel_Refresh()
If $g_hMovingGUI Then
For $i = 1 To $g_aGDILbs[0][0]
If Not $g_aGDILbs[$i][$g_FF_bRemoved] And $g_aGDILbs[$i][$g_FF_hGUI] = $g_hMovingGUI Then _GUICtrlFFLabel_SetData($i, $g_aGDILbs[$i][$g_FF_sRestore])
Next
Else
For $i = 1 To $g_aGDILbs[0][0]
If Not $g_aGDILbs[$i][$g_FF_bRemoved] Then _GUICtrlFFLabel_SetData($i, $g_aGDILbs[$i][$g_FF_sRestore])
Next
EndIf
EndFunc
Func __GUICtrlFFLabel_GetWindowBkColor($hWnd = 0)
Local $hDC, $iOpt, $hBkGUI, $nColor
If $hWnd Then
$hDC = _WinAPI_GetDC($hWnd)
$nColor = DllCall('gdi32.dll', 'int', 'GetBkColor', 'hwnd', $hDC)
$nColor = $nColor[0]
$nColor = Hex(BitOR(BitAND($nColor, 0x00FF00), BitShift(BitAND($nColor, 0x0000FF), -16), BitShift(BitAND($nColor, 0xFF0000), 16)), 6)
_WinAPI_ReleaseDC($hWnd, $hDC)
Return "0xFF" & $nColor
EndIf
$iOpt = Opt("WinWaitDelay", 10)
$hBkGUI = GUICreate("", 2, 2, 1, 1, 0x80000000, 0x00000080)
GUISetState()
WinWait($hBkGUI)
$nColor = Hex(PixelGetColor(1, 1, $hBkGUI), 6)
GUIDelete($hBkGUI)
Opt("WinWaitDelay", $iOpt)
Return '0xFF' & $nColor
EndFunc
Func __GUICtrlFFLabel_WriteBuffer($iIndex)
Local $hGDI_HBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($g_aGDILbs[$iIndex][$g_FF_hBitmap])
Local $hDC = _WinAPI_CreateCompatibleDC($g_ahDCs[$g_aGDILbs[$iIndex][$g_iFF_DCIndex]])
_WinAPI_SelectObject($hDC, $hGDI_HBitmap)
_WinAPI_BitBlt($g_ahDCs[$g_aGDILbs[$iIndex][$g_iFF_DCIndex]], $g_aGDILbs[$iIndex][$g_FF_iLeft], $g_aGDILbs[$iIndex][$g_FF_iTop], $g_aGDILbs[$iIndex][$g_FF_iWidth], $g_aGDILbs[$iIndex][$g_FF_iHeight], $hDC, 0, 0, 0x00CC0020)
_WinAPI_DeleteObject($hGDI_HBitmap)
_WinAPI_DeleteDC($hDC)
EndFunc
Func __GUICtrlFFLabel_Graphics_N_DC($iIndex, $hWnd)
For $i = 1 To $g_aGDILbs[0][0]
If $g_aGDILbs[$i][$g_FF_hGUI] = $hWnd Then
$g_aGDILbs[$iIndex][$g_FF_iGraphicsIndex] = $g_aGDILbs[$i][$g_FF_iGraphicsIndex]
$g_aGDILbs[$iIndex][$g_iFF_DCIndex] = $g_aGDILbs[$i][$g_iFF_DCIndex]
Return
EndIf
Next
ReDim $g_ahGraphics[UBound($g_ahGraphics) + 1]
$g_ahGraphics[0] += 1
ReDim $g_ahDCs[UBound($g_ahDCs) + 1]
$g_ahDCs[0] += 1
$g_ahGraphics[$g_ahGraphics[0]] = _GDIPlus_GraphicsCreateFromHWND($hWnd)
$g_ahDCs[$g_ahDCs[0]] = _WinAPI_GetDC($hWnd)
$g_aGDILbs[$iIndex][$g_FF_iGraphicsIndex] = $g_ahGraphics[0]
$g_aGDILbs[$iIndex][$g_iFF_DCIndex] = $g_ahDCs[0]
EndFunc
Func __GUICtrlFFLabel_Dispose()
DllCallbackFree($g_hRefreshCB)
For $i = 1 To $g_aGDILbs[0][0]
If Not $g_aGDILbs[$i][$g_FF_bRemoved] Then
_GDIPlus_FontDispose($g_aGDILbs[$i][$g_FF_hFont])
_GDIPlus_StringFormatDispose($g_aGDILbs[$i][$g_FF_hStringformat])
_GDIPlus_FontFamilyDispose($g_aGDILbs[$i][$g_FF_FontFamily])
_GDIPlus_BrushDispose($g_aGDILbs[$i][$g_FF_hBrush])
_GDIPlus_GraphicsDispose($g_aGDILbs[$i][$g_FF_hBuffer])
_GDIPlus_ImageDispose($g_aGDILbs[$i][$g_FF_hBitmap])
EndIf
Next
For $i = 1 To $g_ahGraphics[0]
_GDIPlus_GraphicsDispose($g_ahGraphics[$i])
For $j = 1 To $g_aGDILbs[0][0]
If $g_aGDILbs[$j][$g_iFF_DCIndex] = $i Then
_WinAPI_ReleaseDC($g_aGDILbs[$j][$g_FF_hGUI], $g_ahDCs[$i])
ExitLoop
EndIf
Next
Next
_GDIPlus_Shutdown()
EndFunc
Func __GUICtrlFFLabel_VerifyARGB(ByRef $iHex)
If IsString($iHex) Then
If StringLeft($iHex, 2) = '0x' Then $iHex = StringTrimLeft($iHex, 2)
If StringLen($iHex) = 6 Then
$iHex = '0xFF' & $iHex
Else
$iHex = '0x' & $iHex
EndIf
Else
If $iHex <= 0xFFFFFF Then $iHex = '0xFF' & Hex($iHex, 6)
EndIf
EndFunc
Func __GUICtrlFFLabel_WM_ENTERSIZEMOVE($hWndGUI)
$g_hMovingGUI = $hWndGUI
$g_aRefreshTimer = DllCall('user32.dll', 'UINT', 'SetTimer', 'hwnd', 0, 'UINT', 0, 'UINT', 50, 'ptr', DllCallbackGetPtr($g_hRefreshCB))
EndFunc
Func __GUICtrlFFLabel_WM_EXITSIZEMOVE()
DllCall('user32.dll', 'bool', 'KillTimer', 'hwnd', 0, 'UINT', $g_aRefreshTimer[0])
$g_hMovingGUI = 0
EndFunc
Func __GUICtrlFFLabel_WM_SIZE($hWndGUI, $MsgID, $wParam)
#forceref $hWndGUI, $MsgID
Switch $wParam
Case 0
For $i = 1 To $g_aGDILbs[0][0]
If $g_aGDILbs[$i][$g_FF_hGUI] = $hWndGUI Then
If $g_aGDILbs[$i][$g_FF_bIsMinimized] Then $g_aGDILbs[$i][$g_FF_bIsMinimized] = False
EndIf
Next
AdlibRegister('__GUICtrlFFLabel_DelayedRefresh', 100)
Case 1
For $i = 1 To $g_aGDILbs[0][0]
If $g_aGDILbs[$i][$g_FF_hGUI] = $hWndGUI Then $g_aGDILbs[$i][$g_FF_bIsMinimized] = True
Next
Case 2
AdlibRegister('__GUICtrlFFLabel_DelayedRefresh', 100)
EndSwitch
Return 'GUI_RUNDEFMSG'
EndFunc
Func __GUICtrlFFLabel_WM_SIZING()
_GUICtrlFFLabel_Refresh()
Return 'GUI_RUNDEFMSG'
EndFunc
Func __GUICtrlFFLabel_DelayedRefresh()
_GUICtrlFFLabel_Refresh()
AdlibUnRegister('__GUICtrlFFLabel_DelayedRefresh')
EndFunc
Global $__BinaryCall_Kernel32dll = DllOpen('kernel32.dll')
Global $__BinaryCall_Msvcrtdll = DllOpen('msvcrt.dll')
Global $__BinaryCall_LastError = ""
Func _BinaryCall_GetProcAddress($Module, $Proc)
Local $Ret = DllCall($__BinaryCall_Kernel32dll, 'ptr', 'GetProcAddress', 'ptr', $Module, 'str', $Proc)
If @Error Or Not $Ret[0] Then Return SetError(1, @Error, 0)
Return $Ret[0]
EndFunc
Func _BinaryCall_LoadLibrary($Filename)
Local $Ret = DllCall($__BinaryCall_Kernel32dll, "handle", "LoadLibraryW", "wstr", $Filename)
If @Error Then Return SetError(1, @Error, 0)
Return $Ret[0]
EndFunc
Func _BinaryCall_lstrlenA($Ptr)
Local $Ret = DllCall($__BinaryCall_Kernel32dll, "int", "lstrlenA", "ptr", $Ptr)
If @Error Then Return SetError(1, @Error, 0)
Return $Ret[0]
EndFunc
Func _BinaryCall_Alloc($Code, $Padding = 0)
Local $Length = BinaryLen($Code) + $Padding
Local $Ret = DllCall($__BinaryCall_Kernel32dll, "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", $Length, "dword", 0x1000, "dword", 0x40)
If @Error Or Not $Ret[0] Then Return SetError(1, @Error, 0)
If BinaryLen($Code) Then
Local $Buffer = DllStructCreate("byte[" & $Length & "]", $Ret[0])
DllStructSetData($Buffer, 1, $Code)
EndIf
Return $Ret[0]
EndFunc
Func _BinaryCall_RegionSize($Ptr)
Local $Buffer = DllStructCreate("ptr;ptr;dword;uint_ptr;dword;dword;dword")
Local $Ret = DllCall($__BinaryCall_Kernel32dll, "int", "VirtualQuery", "ptr", $Ptr, "ptr", DllStructGetPtr($Buffer), "uint_ptr", DllStructGetSize($Buffer))
If @Error Or $Ret[0] = 0 Then Return SetError(1, @Error, 0)
Return DllStructGetData($Buffer, 4)
EndFunc
Func _BinaryCall_Free($Ptr)
Local $Ret = DllCall($__BinaryCall_Kernel32dll, "bool", "VirtualFree", "ptr", $Ptr, "ulong_ptr", 0, "dword", 0x8000)
If @Error Or $Ret[0] = 0 Then Return SetError(1, @Error, 0)
Return $Ret[0]
EndFunc
Func _BinaryCall_MemorySearch($Ptr, $Length, $Binary)
Static $CodeBase
If Not $CodeBase Then
If @AutoItX64 Then
$CodeBase = _BinaryCall_Create('0x4883EC084D85C94889C8742C4C39CA72254C29CA488D141131C9EB0848FFC14C39C97414448A1408453A140874EE48FFC04839D076E231C05AC3', '', 0, True, False)
Else
$CodeBase = _BinaryCall_Create('0x5589E58B4D14578B4508568B550C538B7D1085C9742139CA721B29CA8D341031D2EB054239CA740F8A1C17381C1074F34039F076EA31C05B5E5F5DC3', '', 0, True, False)
EndIf
If Not $CodeBase Then Return SetError(1, 0, 0)
EndIf
$Binary = Binary($Binary)
Local $Buffer = DllStructCreate("byte[" & BinaryLen($Binary) & "]")
DllStructSetData($Buffer, 1, $Binary)
Local $Ret = DllCallAddress("ptr:cdecl", $CodeBase, "ptr", $Ptr, "uint", $Length, "ptr", DllStructGetPtr($Buffer), "uint", DllStructGetSize($Buffer))
Return $Ret[0]
EndFunc
Func _BinaryCall_Base64Decode($Src)
Static $CodeBase
If Not $CodeBase Then
If @AutoItX64 Then
$CodeBase = _BinaryCall_Create('0x41544989CAB9FF000000555756E8BE000000534881EC000100004889E7F3A44C89D6E98A0000004439C87E0731C0E98D0000000FB66E01440FB626FFC00FB65E020FB62C2C460FB62424408A3C1C0FB65E034189EB41C1E4024183E3308A1C1C41C1FB044509E34080FF634189CC45881C08744C440FB6DFC1E5044489DF4088E883E73CC1FF0209C7418D44240241887C08014883C10380FB63742488D841C1E3064883C60483E03F4409D841884408FF89F389C84429D339D30F8C67FFFFFF4881C4000100005B5E5F5D415CC35EC3E8F9FFFFFF000000000000000000000000000000000000000000000000000000000000000000000000000000000000003E0000003F3435363738393A3B3C3D00000063000000000102030405060708090A0B0C0D0E0F101112131415161718190000000000001A1B1C1D1E1F202122232425262728292A2B2C2D2E2F30313233', '', 132, True, False)
Else
$CodeBase = _BinaryCall_Create('0x55B9FF00000089E531C05756E8F10000005381EC0C0100008B55088DBDF5FEFFFFF3A4E9C00000003B45140F8FC20000000FB65C0A028A9C1DF5FEFFFF889DF3FEFFFF0FB65C0A038A9C1DF5FEFFFF889DF2FEFFFF0FB65C0A018985E8FEFFFF0FB69C1DF5FEFFFF899DECFEFFFF0FB63C0A89DE83E630C1FE040FB6BC3DF5FEFFFFC1E70209FE8B7D1089F3881C074080BDF3FEFFFF63745C0FB6B5F3FEFFFF8BBDECFEFFFF8B9DE8FEFFFF89F083E03CC1E704C1F80209F88B7D1088441F0189D883C00280BDF2FEFFFF6374278A85F2FEFFFFC1E60683C10483E03F09F088441F0289D883C0033B4D0C0F8C37FFFFFFEB0231C081C40C0100005B5E5F5DC35EC3E8F9FFFFFF000000000000000000000000000000000000000000000000000000000000000000000000000000000000003E0000003F3435363738393A3B3C3D00000063000000000102030405060708090A0B0C0D0E0F101112131415161718190000000000001A1B1C1D1E1F202122232425262728292A2B2C2D2E2F30313233', '', 132, True, False)
EndIf
If Not $CodeBase Then Return SetError(1, 0, Binary(""))
EndIf
$Src = String($Src)
Local $SrcLen = StringLen($Src)
Local $SrcBuf = DllStructCreate("char[" & $SrcLen & "]")
DllStructSetData($SrcBuf, 1, $Src)
Local $DstLen = Int(($SrcLen + 2) / 4) * 3 + 1
Local $DstBuf = DllStructCreate("byte[" & $DstLen & "]")
Local $Ret = DllCallAddress("uint:cdecl", $CodeBase, "ptr", DllStructGetPtr($SrcBuf), "uint", $SrcLen, "ptr", DllStructGetPtr($DstBuf), "uint", $DstLen)
If $Ret[0] = 0 Then Return SetError(2, 0, Binary(""))
Return BinaryMid(DllStructGetData($DstBuf, 1), 1, $Ret[0])
EndFunc
Func _BinaryCall_LzmaDecompress($Src)
Static $CodeBase
If Not $CodeBase Then
If @AutoItX64 Then
$CodeBase = _BinaryCall_Create(_BinaryCall_Base64Decode('QVcxwEFWQVVBVFVXSInXVkiJzlMx20iB7OgAAABEiiFBgPzgdgnpyQAAAEGD7C1BiMf/wEGA/Cx38THA6wRBg+wJQYjG/8BBgPwId/GLRglEi24FQQ+2zkyJRCQoRQ+2/0HB5xBBiQFBD7bEAcG4AAMAANPgjYQAcA4AAEhjyOjIBAAATInpSInF6L0EAABIicMxwEyJ8kSI4EyLRCQoiNQl//8A/0QJ+EiF24lFAHQoTYXtdCNIjVfzSI1MJDhIg8YNTIkEJE2J6UmJ2EiJ7+g2AAAAicbrBb4BAAAASInp6IQEAACF9nQKSInZMdvodgQAAEiJ2EiBxOgAAABbXl9dQVxBXUFeQV/DVVNBV0FWQVVBVEFQTQHBQVFNicVRVkgB8lJIieX8SYn0iwdMjX8Eik8Cg8r/0+L30olV6Ijhg8r/0+L30olV5ADBiUXsuAEAAACJReCJRdyJRdhIiUXQRSnJKfaDy/8A0bgAAwAA0+BIjYg2BwAAuAAEAARMif/R6fOrvwUAAADoUAMAAP/PdfdEie9EicgrfSDB4ARBifpEI1XoRAHQTY0cR+hAAwAAD4WTAAAAik3sI33k0+eA6Qj22dPuAfe4AQAAAEiNPH++AAEAAMHnCEGD+QdNjbR/bA4AAHI0TInvSCt90A+2P9HnQYnzIf5BAfNPjRxe6O8CAACJwcHuCIPhATnOvgABAAB1DjnGd9jrDE2J8+jQAgAAOfBy9EyJ76pEiclBg/kEcg65AwAAAEGD+QpyA4PBA0EpyelDAgAAT42cT4ABAADomgIAAHUsi0XcQYP5B4lF4BnAi1XY99CLTdCD4AOJVdxBicGJTdhNjbdkBgAA6akAAABPjZxPmAEAAOhfAgAAdUZEicjB4AREAdBNjZxH4AEAAOhHAgAAdWpBg/kHuQkAAAByA4PBAkGJyUyJ70grfdBIO30gD4L9AQAAigdIA33QqumzAQAAT42cT7ABAADoCgIAAIt12HQhT42cT8gBAADo+AEAAIt13HQJi03ci3XgiU3gi03YiU3ci03QiU3YiXXQQYP5B7kIAAAAcgODwQNBiclNjbdoCgAATYnz6LsBAAB1FESJ0CnJweADvggAAABJjXxGBOs2TY1eAuicAQAAdRpEidC5CAAAAMHgA74IAAAASY28RgQBAADrEUmNvgQCAAC5EAAAAL4AAQAAiU3MuAEAAABJifvoYQEAAInCKfJy8gNVzEGD+QSJVcwPg7kAAABBg8EHuQMAAAA50XICidHB4Qa4AQAAAEmNvE9gAwAAvkAAAABJifvoHwEAAEGJwkEp8nLwQYP6BHJ4RInWRIlV0NHug2XQAf/Og03QAkGD+g5zFYnx0mXQi0XQRCnQTY20R14FAADrLIPuBOi6AAAA0evRZdBBOdhyBv9F0EEp2P/OdedNjbdEBgAAwWXQBL4EAAAAvwEAAACJ+E2J8+ioAAAAqAF0Awl90NHn/8516+sERIlV0P9F0EyJ74tNzEiJ+IPBAkgrRSBIOUXQd1RIif5IK3XQSItVGKyqSDnXcwT/yXX1SYn9D7bwTDttGA+C9fz//+gwAAAAKcBIi1UQTCtlCESJIkiLVWBMK20gRIkqSIPEKEFcQV1BXUFfW13DXli4AQAAAOvSgfsAAAABcgHDweMITDtlAHPmQcHgCEWKBCRJg8QBwynATY0cQ4H7AAAAAXMVweMITDtlAHPBQcHgCEWKBCRJg8QBidlBD7cTwekLD6/KQTnIcxOJy7kACAAAKdHB6QVmQQELAcDDKcvB6gVBKchmQSkTAcCDwAHDSLj////////////gbXN2Y3J0LmRsbHxtYWxsb2MASLj////////////gZnJlZQA='))
Else
$CodeBase = _BinaryCall_Create(_BinaryCall_Base64Decode('VYnlVzH/VlOD7EyLXQiKC4D54A+HxQAAADHA6wWD6S2I0ID5LI1QAXfziEXmMcDrBYPpCYjQgPkIjVABd/OIReWLRRSITeSLUwkPtsmLcwWJEA+2ReUBwbgAAwAA0+CNhABwDgAAiQQk6EcEAACJNCSJRdToPAQAAItV1InHi0Xkhf+JArgBAAAAdDaF9nQyi0UQg8MNiRQkiXQkFIl8JBCJRCQYjUXgiUQkDItFDIlcJASD6A2JRCQI6CkAAACLVdSJRdSJFCToAQQAAItF1IXAdAqJPCQx/+jwAwAAg8RMifhbXl9dw1dWU1WJ5YtFJAFFKFD8i3UYAXUcVot1FK2SUopO/oPI/9Pg99BQiPGDyP/T4PfQUADRifeD7AwpwEBQUFBQUFcp9laDy/+4AAMAANPgjYg2BwAAuAAEAATR6fOragVZ6MoCAADi+Yt9/ItF8Ct9JCH4iUXosADoywIAAA+FhQAAAIpN9CN97NPngOkI9tnT7lgB916NPH/B5wg8B1qNjH5sDgAAUVa+AAEAAFCwAXI0i338K33cD7Y/i23M0eeJ8SH+AfGNbE0A6JgCAACJwcHuCIPhATnOvgABAAB1DjnwctfrDIttzOh5AgAAOfBy9FqD+gSJ0XIJg/oKsQNyArEGKcpS60mwwOhJAgAAdRRYX1pZWln/NCRRUrpkBgAAsQDrb7DM6CwCAAB1LLDw6BMCAAB1U1g8B7AJcgKwC1CLdfwrddw7dSQPgs8BAACsi338qumOAQAAsNjo9wEAAIt12HQbsOTo6wEAAIt11HQJi3XQi03UiU3Qi03YiU3Ui03ciU3YiXXcWF9ZumgKAACxCAH6Ulc8B4jIcgIEA1CLbczovAEAAHUUi0Xoi33MweADKclqCF6NfEcE6zWLbcyDxQLomwEAAHUYi0Xoi33MweADaghZaghejbxHBAEAAOsQvwQCAAADfcxqEFm+AAEAAIlN5CnAQIn96GYBAACJwSnxcvMBTeSDfcQED4OwAAAAg0XEB4tN5IP5BHIDagNZi33IweEGKcBAakBejbxPYAMAAIn96CoBAACJwSnxcvOJTeiJTdyD+QRyc4nOg2XcAdHug03cAk6D+Q5zGbivAgAAKciJ8dJl3ANF3NHgA0XIiUXM6y2D7gToowAAANHr0WXcOV3gcgb/RdwpXeBOdei4RAYAAANFyIlFzMFl3ARqBF4p/0eJ+IttzOi0AAAAqAF0Awl93NHnTnXs6wD/RdyLTeSDwQKLffyJ+CtFJDlF3HdIif4rddyLVSisqjnXcwNJdfeJffwPtvA7fSgPgnH9///oKAAAACnAjWwkPItVIIt1+Ct1GIkyi1Usi338K30kiTrJW15fw15YKcBA69qB+wAAAAFyAcPB4whWi3X4O3Ucc+SLReDB4AisiUXgiXX4XsOLTcQPtsDB4QQDRegByOsGD7bAA0XEi23IjWxFACnAjWxFAIH7AAAAAXMci0wkOMFkJCAIO0wkXHOcihH/RCQ4weMIiFQkIInZD7dVAMHpCw+vyjlMJCBzF4nLuQAIAAAp0cHpBWYBTQABwI1sJEDDweoFKUwkICnLZilVAAHAg8ABjWwkQMO4///////gbXN2Y3J0LmRsbHxtYWxsb2MAuP//////4GZyZWUA'))
EndIf
If Not $CodeBase Then Return SetError(1, 0, Binary(""))
EndIf
$Src = Binary($Src)
Local $SrcLen = BinaryLen($Src)
Local $SrcBuf = DllStructCreate("byte[" & $SrcLen & "]")
DllStructSetData($SrcBuf, 1, $Src)
Local $Ret = DllCallAddress("ptr:cdecl", $CodeBase, "ptr", DllStructGetPtr($SrcBuf), "uint_ptr", $SrcLen, "uint_ptr*", 0, "uint*", 0)
If $Ret[0] Then
Local $DstBuf = DllStructCreate("byte[" & $Ret[3] & "]", $Ret[0])
Local $Output = DllStructGetData($DstBuf, 1)
DllCall($__BinaryCall_Msvcrtdll, "none:cdecl", "free", "ptr", $Ret[0])
Return $Output
EndIf
Return SetError(2, 0, Binary(""))
EndFunc
Func _BinaryCall_Relocation($Base, $Reloc)
Local $Size = Int(BinaryMid($Reloc, 1, 2))
For $i = 3 To BinaryLen($Reloc) Step $Size
Local $Offset = Int(BinaryMid($Reloc, $i, $Size))
Local $Ptr = $Base + $Offset
DllStructSetData(DllStructCreate("ptr", $Ptr), 1, DllStructGetData(DllStructCreate("ptr", $Ptr), 1) + $Base)
Next
EndFunc
Func _BinaryCall_ImportLibrary($Base, $Length)
Local $JmpBin, $JmpOff, $JmpLen, $DllName, $ProcName
If @AutoItX64 Then
$JmpBin = Binary("0x48B8FFFFFFFFFFFFFFFFFFE0")
$JmpOff = 2
Else
$JmpBin = Binary("0xB8FFFFFFFFFFE0")
$JmpOff = 1
EndIf
$JmpLen = BinaryLen($JmpBin)
Do
Local $Ptr = _BinaryCall_MemorySearch($Base, $Length, $JmpBin)
If $Ptr = 0 Then ExitLoop
Local $StringPtr = $Ptr + $JmpLen
Local $StringLen = _BinaryCall_lstrlenA($StringPtr)
Local $String = DllStructGetData(DllStructCreate("char[" & $StringLen & "]", $StringPtr), 1)
Local $Split = StringSplit($String, "|")
If $Split[0] = 1 Then
$ProcName = $Split[1]
ElseIf $Split[0] = 2 Then
If $Split[1] Then $DllName = $Split[1]
$ProcName = $Split[2]
EndIf
If $DllName And $ProcName Then
Local $Handle = _BinaryCall_LoadLibrary($DllName)
If Not $Handle Then
$__BinaryCall_LastError = "LoadLibrary fail on " & $DllName
Return SetError(1, 0, False)
EndIf
Local $Proc = _BinaryCall_GetProcAddress($Handle, $ProcName)
If Not $Proc Then
$__BinaryCall_LastError = "GetProcAddress failed on " & $ProcName
Return SetError(2, 0, False)
EndIf
DllStructSetData(DllStructCreate("ptr", $Ptr + $JmpOff), 1, $Proc)
EndIf
Local $Diff = Int($Ptr - $Base + $JmpLen + $StringLen + 1)
$Base += $Diff
$Length -= $Diff
Until $Length <= $JmpLen
Return True
EndFunc
Func _BinaryCall_CodePrepare($Code)
If Not $Code Then Return ""
If IsBinary($Code) Then Return $Code
$Code = String($Code)
If StringLeft($Code, 2) = "0x" Then Return Binary($Code)
If StringIsXDigit($Code) Then Return Binary("0x" & $Code)
Return _BinaryCall_LzmaDecompress(_BinaryCall_Base64Decode($Code))
EndFunc
Func _BinaryCall_SymbolFind($CodeBase, $Identify, $Length = Default)
$Identify = Binary($Identify)
If IsKeyword($Length) Then
$Length = _BinaryCall_RegionSize($CodeBase)
EndIf
Local $Ptr = _BinaryCall_MemorySearch($CodeBase, $Length, $Identify)
If $Ptr = 0 Then Return SetError(1, 0, 0)
Return $Ptr + BinaryLen($Identify)
EndFunc
Func _BinaryCall_SymbolList($CodeBase, $Symbol)
If Not IsArray($Symbol) Or $CodeBase = 0 Then Return SetError(1, 0, 0)
Local $Tag = ""
For $i = 0 To UBound($Symbol) - 1
$Tag &= "ptr " & $Symbol[$i] & ";"
Next
Local $SymbolList = DllStructCreate($Tag)
If @Error Then Return SetError(1, 0, 0)
For $i = 0 To UBound($Symbol) - 1
$CodeBase = _BinaryCall_SymbolFind($CodeBase, $Symbol[$i])
DllStructSetData($SymbolList, $Symbol[$i], $CodeBase)
Next
Return $SymbolList
EndFunc
Func _BinaryCall_Create($Code, $Reloc = '', $Padding = 0, $ReleaseOnExit = True, $LibraryImport = True)
Local $BinaryCode = _BinaryCall_CodePrepare($Code)
If Not $BinaryCode Then Return SetError(1, 0, 0)
Local $BinaryCodeLen = BinaryLen($BinaryCode)
Local $TotalCodeLen = $BinaryCodeLen + $Padding
Local $CodeBase = _BinaryCall_Alloc($BinaryCode, $Padding)
If Not $CodeBase Then Return SetError(2, 0, 0)
If $Reloc Then
$Reloc = _BinaryCall_CodePrepare($Reloc)
If Not $Reloc Then Return SetError(3, 0, 0)
_BinaryCall_Relocation($CodeBase, $Reloc)
EndIf
If $LibraryImport Then
If Not _BinaryCall_ImportLibrary($CodeBase, $BinaryCodeLen) Then
_BinaryCall_Free($CodeBase)
Return SetError(4, 0, 0)
EndIf
EndIf
If $ReleaseOnExit Then
_BinaryCall_ReleaseOnExit($CodeBase)
EndIf
Return SetError(0, $TotalCodeLen, $CodeBase)
EndFunc
Func _BinaryCall_ReleaseOnExit($Ptr)
OnAutoItExitRegister('__BinaryCall_DoRelease')
__BinaryCall_ReleaseOnExit_Handle($Ptr)
EndFunc
Func __BinaryCall_DoRelease()
__BinaryCall_ReleaseOnExit_Handle()
EndFunc
Func __BinaryCall_ReleaseOnExit_Handle($Ptr = Default)
Static $PtrList
If @NumParams = 0 Then
If IsArray($PtrList) Then
For $i = 1 To $PtrList[0]
_BinaryCall_Free($PtrList[$i])
Next
EndIf
Else
If Not IsArray($PtrList) Then
Local $InitArray[1] = [0]
$PtrList = $InitArray
EndIf
If IsPtr($Ptr) Then
Local $Array = $PtrList
Local $Size = UBound($Array)
ReDim $Array[$Size + 1]
$Array[$Size] = $Ptr
$Array[0] += 1
$PtrList = $Array
EndIf
EndIf
EndFunc
Func SHA3_Startup()
Static $SymbolList
If Not IsDllStruct($SymbolList) Then
Local $Code, $Reloc = ''
If @AutoItX64 Then
$Code = 'AwAAAASABwAAAAAAAAAkL48ClECNsbXAnsP7Sx9oG4hgMYQouRFrQAJycRNa9bTFL/2KiJtCwuh/Gp8tAxsZMjUHkixT1HFwo+2Ejp83qGOHEe6xfB7bq1mWi3deg/zXfHyhX98dIz6vGZVRkmbUTc2rL7xnBOEHPPmiWitEmrkUOmfLCAJaU5AVnJsbthzwX5Y+LwCDevx1Pog0+gmQmJq/Tta3Orn6qGBiPc/8lRy50ymWr8g9KwgcddbiCh+L8eGplHfbxb29KOUagWQPUC1u8Coo/ILV60dr7CfSSr7RapWHVFUi51EXgTYqcMGokbEVoCO0c+nGfXHakJDCqcO0tuPtHhfQyiAluF8rk0BapmUvemUrQYteZTkoze/z5wCD4ylmYE0yTZdN5NN1EAHCyJwy++/AdNBUUjYyy9YUQBjuZnEXRwAzJObtnECeJNUThq4Pur4VLsaveQCQcceK/dhrpllqBwoN/nW/jVs8RnRx1BfLlNeBCahI9fCThgas3SQouZDYiO1QSWKp6sqFHW9TP/kf5w1X6KBLvlfzaIAyaH4UfF89YxFQ5Samo/q6qq8aT4bBmW7kQSX9w2LrrBRayiJmZro2Nd6gtWqQ2K02JaXM2PYn1rHb/p6BWYFVp+Yk8P1tZYiLyq/jdNmplNtdD9QIF/nj13F9ab9SU6LJdaX3GQwPeemUPxikPcBDj1f0xQmrtSe7CpHjRcZWPWbk/hTxSGDonWHiq3Y6FLDe83MmpPDBz7YqUS48JANOx5tw5k1qZfADrGWxzYR6H7La9V6nVIVbdSI6Nl3l5Xwhxe1wCGgE5vPfFiu81vRLqIjjnOu3X0fNqd9VJxZElf7YB7rqqFw6kuQBDz7SM4scQgR55nIpBYdGQbUCut4pt9ahu9vODFnzpViA/TV/3e02tINl999ne1r7ed+snTivk0Ep0YWYVk6ni4uKooWGVdxdqxUNAldmGKimkFTfrjiuDPBk4NPzcA/tWbvzPNq5zojFDn796LTBddydB2Q5PaitHEi7tujBc1DcYBzku4Jjex4pf/3OihefyM2tLeV4PrH0/7KbF4vE7WowDfDJlJeNPSrJTUuetDNzRXzDJRlxJdtvljxzTbj2ettBQbms7uUl4ht/idVy/JIN4nZuB/AoNuLy7UWZkqruDcVr2ktNabv9DUp/Jl/xwtf/zVuHpCgqz9gO87VxfJmmHBWHg4e770xshegg8FqsPM8nF2U4+gVjByBxxGXzxM+nQ6ZxYGvd6g4Xg5sDVbG3jt7fc0pReyiihetd6m8tHFb8siG8u5sOWMEiQAuX2OLk5ISyvrqdnTeHAxgCmr/lawLmZnu4KjJ3gv4k1E83zCpLD5HapodtE6mFCGbtQnhU9HlkGAmr16pG/CybcfxuyK/rRq13wYd8XT7TH5tH8KSR9vzvA499gjSGovoCD9UUbn+a9IbpcbWs1LEaPLSE5oPNq9N/WX7BMlFC9b1BiA56M+Mr587TI104vU/I9qAeHypv6iuB0Vk5wwVStGc6JrWhMrQrKOgXYYL0AUWlkTqIEy8xKDUk4lT4ROOJ0ZlKO1KIeSuIv/jWFzfsnan8/SHLWWtInkgSfcB2Dw=='
Else
$Code = 'AwAAAARACgAAAAAAAABcQfD555tIPPb/a31LbK6Gqf8ftQGc5ULs2ULA02Mfa3o7G3jxGAFkH0s6r9f2VFE+XCQl7eTYask3HxPuOpH9okqrHYlyge0sTZ+wKo1m+QxcTTVd9l4Q20n/e9nJwER9wh0W/wAXCyYjqH1yiz6vTJhASza679uIqdbhhJrf4iCyIySjVw2LSzfiP7wQnt5LKlFDLhu/1O4uMft8CnrgsJN0hu7z3smX5stXMUL39bdHiPCueRSSkg+oHwltx5kniX4juWIYq0Yv/loSKGvv5EHmrqvNm5iTuTykiUpm4AItvVaocLmipHcwa2l06nUSE5SI8j98Xk3Nnsa8kOXCBp1ZOplJpfMPSPvefHKdZuYptz1DC3/LIZFZdhbdJwG5yxnPWy3IpMxdi+LnrWmT+moTTsebxZquhJfUt33hZ4OSVM6yk1w5YjiERMOUBJm93Bfb95Hky1cVCJUDHrIWOe9M7/Pu9bf/i2d6AL5ADcw1jFtUgthVWfFmdYV+LdAWqe8UPWO6+v1i3fwccqQGceB8Sji76fZuL03E4ibKieMOqjmsMaB6YzhqNaNoExGCwDZ3SLII4kg88dRsdClGKHb+7jD1581Z1zCoQkRmP9tijEtTUDsX3NKhNw946+YDAGw8tZDr2nE2wgSBAsOlcVpzeJGm9bGsbegMsSOoHYTSLYvuHuxRwI5IvIoGH9ppGAxuSScC2W695riXEBFkz6bTULrd6o0twrzh1ij3dP34NKjLQzPC5siNhvHCzhc8Rtw/vSiib+0re2LGwvx4W6ohOeu7fvioHKyE4Jj06YV7Kfbm3txxF1Ct3JS8WGeXDApPCkWYkorPygL4BThWDQZpHC1fL0eziWVWhRvneI6owhIpEs4j+Wcwx7kNPtv43OHG1eTSFmVSaKfTLF5WXqyAtx2aRzfR+/cR+QmSFKllqgFfucY6mpKv9tspI8q1W97BYJ2qtgr3LC2deIDYMoHCvAm1lr5eOQWrMBl0s3Vz4g7FOhoaqKR/bGJPh+75K9ObumqAOApAgQkdOaMjN2IGu8N4/8nXKo+52coQNBjVxWg164kVNWpPOVtjITVdv230tcJX+0OTgNCsNPvFAEm3X+C3oWdkjHWSrg+UyqjH+F1cfFB2YtxKeMvbD5B43vd5o2wmlETsp+xLL47UHXvlU+7/RaxT8IGIl88Wtw40F33sNWHch+kkuWvzqwS3RjFTIMlOF426rMyq+gz1iLW+s/xQW2IvZqlsI9znrUJ84QYa4C/cVs6KAmSzxhkNvN8+XDsEK3/bcQw8i3B5QmS6vmHufCnbOymTeZmWP63SJWFl0pBVMQQbc6/5fUWXAP1YO8BlXE7f43rmc6FmRV0NxYaQvddJg+Q0lIbKlNW0hdDGmDg7wfBJrZI1omowW9+AEeqQ+1/pJ2pIjjlZSXRZH109EBYiVWQOoPPdc18VQk/FOjVYszm2nzzkMk1IHhqs2A/S1zmayGF8sC51n3abfGSDKspGfSFyL6pAZktMwObhdluWIl8J08Feo8klHxMfKxFjMf8JI+u5zE9sFGht841QNQLkVbKp9GiSo2qXRxQdykaHCZETrpxy7UAnJa6pFt0ynXFMx89615rUqRzb22ifkZKSkqKSOkB1RK9/g+Yzub6rzW075r1Dy/SDqWrokqMDH4etuOg7PxvA12nUDGtGg2Q4cizLhnasrLnn0ZrvtodXBXalTUlY+/6tyatbtkKIeqduJbIVkiUTfM+JJUqO5HS6NCiM0/vu8P34abJYubA0JPlNXiXK/o2c8UViR/VRdnWzIGGDAyK9Q9udyERpN5PycOx150Trs5isyrLQYcE2FvadvZ905ntvPVK7RuDXuVksdKs8D+Av/Ul9FqHi0eM24jECpYtnmKOEcyJyELKqc70yFF+IDLLIetG/uQvIPYS4lVX5hhpgmo3U/S3qXgB='
$Reloc = 'AwAAAAQOAAAAAAAAAAAA//4aaS5g/M2DkyM6bdee78AA'
EndIf
Local $Symbol[] = ["rhash_sha3_224_init","rhash_sha3_256_init","rhash_sha3_384_init","rhash_sha3_512_init","rhash_sha3_update","rhash_sha3_final"]
Local $CodeBase = _BinaryCall_Create($Code, $Reloc)
If @Error Then Return SetError(1, 0, 0)
$SymbolList = _BinaryCall_SymbolList($CodeBase, $Symbol)
If @Error Then Return SetError(1, 0, 0)
EndIf
Return $SymbolList
EndFunc
Func SHA3_Init($Bits = 256)
Local $SymbolList = SHA3_Startup()
If @Error Then Return SetError(1, 0, 0)
Local $InitFunc = "rhash_sha3_" &(($Bits = 224 Or $Bits = 384 Or $Bits = 512) ? $Bits : 256) & "_init"
Local $Ctx = DllStructCreate("byte[400]")
DllCallAddress("none:cdecl", DllStructGetData($SymbolList, $InitFunc), "ptr", DllStructGetPtr($Ctx))
Return $Ctx
EndFunc
Func SHA3_Input($Ctx, $Data)
Local $SymbolList = SHA3_Startup()
If @Error Or Not IsDllStruct($Ctx) Then Return SetError(1, 0, 0)
$Data = Binary($Data)
Local $InputLen = BinaryLen($Data)
Local $Input = DllStructCreate("byte[" & $InputLen & "]")
DllStructSetData($Input, 1, $Data)
DllCallAddress("none:cdecl", DllStructGetData($SymbolList, "rhash_sha3_update"), "ptr", DllStructGetPtr($Ctx), "ptr", DllStructGetPtr($Input), "uint_ptr", $InputLen)
EndFunc
Func SHA3_Result($Ctx)
Local $SymbolList = SHA3_Startup()
If @Error Or Not IsDllStruct($Ctx) Then Return SetError(1, 0, Binary(""))
Local $BlockSize = DllStructGetData(DllStructCreate("byte[396];uint;", DllStructGetPtr($Ctx)), 2)
Local $DigestLen = 100 - $BlockSize / 2
Local $Digest = DllStructCreate("byte[" & $DigestLen & "]")
DllCallAddress("none:cdecl", DllStructGetData($SymbolList, "rhash_sha3_final"), "ptr", DllStructGetPtr($Ctx), "ptr", DllStructGetPtr($Digest))
Return DllStructGetData($Digest, 1)
EndFunc
Func SHA3($Data, $Bits = 256)
Local $Ctx = SHA3_Init($Bits)
SHA3_Input($Ctx, $Data)
Return SHA3_Result($Ctx)
EndFunc
Func _DrawLegend($hWnd, $sValues, $sColors, $sHeadline, $iLeft, $iTop, $iHeight = 18, $iFontSize = 8.5, $iX_Headline = 60, $iX_Value = 50, $iX_Percent = 40)
Local $aChartColour = StringSplit($sColors, ",", 2)
Local $aChartValue = StringSplit($sValues, ",", 2)
Local $aChartPercent = StringSplit($sValues, ",", 2)
Local $aChartHeadline = StringSplit($sHeadline, ",", 2)
Local $nCount, $nTotal = 0, $nValues
If UBound($aChartColour) <> UBound($aChartValue) Then
MsgBox(0, "ERROR", "UBound($aChartColour) <> UBound($aChartValue)")
EndIf
If UBound($aChartColour) <> UBound($aChartHeadline) Then
MsgBox(0, "ERROR", "UBound($aChartColour) <> UBound($aChartHeadline)")
EndIf
$nValues = UBound($aChartValue)
Global $ahBrush[$nValues], $ahPen[$nValues]
For $i = 0 To $nValues - 1
$ahBrush[$i] = _GDIPlus_BrushCreateSolid(BitOR(0xff000000, $aChartColour[$i]))
$ahPen[$i] = _GDIPlus_PenCreate(0xff000000)
Next
Local $hDC = _WinAPI_GetDC($hWnd)
Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)
Local $a = WinGetPos($hWnd)
Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($a[2], $a[3], $hGraphics)
Local $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
_GDIPlus_GraphicsSetSmoothingMode($hBuffer, 2)
_GDIPlus_GraphicsSetClipRect($hGraphics, $iLeft, $iTop, $iX_Headline + $iHeight / 2 + 2 + $iX_Value + $iX_Percent, $iHeight * $nValues, 1)
If 0 = 1 Then
_GDIPlus_GraphicsClear($hBuffer, 0xffaaaaaa)
Else
_GDIPlus_GraphicsClear($hBuffer, _GetWindowBkColor($hWnd))
EndIf
_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0, 0)
For $nCount = 0 To UBound($aChartValue) - 1
$nTotal += $aChartValue[$nCount]
Next
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
EndFunc
Func _DrawPie($hWnd, $sValues, $sColors, $pieLeft, $pieTop, $pieWidth, $Aspect = 30, $pieDepth = 10, $rotation = 180)
$Aspect /= 100
Local Const $PIE_DIAMETER = $pieWidth - 2
Local Const $PIE_HEIGHT = $PIE_DIAMETER * $Aspect - 2
Local Const $PI = ATan(1) * 4
Local $pieHeight = $PIE_DIAMETER * $Aspect
Local $nCount, $nTotal = 0, $angleStart, $angleSweep, $x, $y, $hPath
Local $aChartColour = StringSplit($sColors, ",", 2)
Local $aChartValue = StringSplit($sValues, ",", 2)
If UBound($aChartColour) <> UBound($aChartValue) Then
MsgBox(0, "ERROR", "UBound($aChartColour) <> UBound($aChartValue)")
EndIf
Local $NUM_VALUES = UBound($aChartValue)
Global $ahBrush[$NUM_VALUES][2], $ahPen[$NUM_VALUES]
For $i = 0 To $NUM_VALUES - 1
$ahBrush[$i][0] = _GDIPlus_BrushCreateSolid(BitOR(0xff000000, $aChartColour[$i]))
$ahBrush[$i][1] = _GDIPlus_BrushCreateSolid(BitOR(0xff000000, _GetDarkerColour($aChartColour[$i])))
$ahPen[$i] = _GDIPlus_PenCreate(BitOR(0xff000000, _GetDarkerColour(_GetDarkerColour($aChartColour[$i]))))
Next
Local $hDC = _WinAPI_GetDC($hWnd)
Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)
Local $a = WinGetPos($hWnd)
Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($a[2], $a[3], $hGraphics)
Local $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
_GDIPlus_GraphicsSetSmoothingMode($hBuffer, 2)
For $nCount = 0 To UBound($aChartValue) - 1
$nTotal += $aChartValue[$nCount]
Next
For $nCount = 0 To UBound($aChartValue) - 1
$aChartValue[$nCount] /= $nTotal
Next
$rotation = Mod($rotation, 360)
_GDIPlus_GraphicsSetClipRect($hGraphics, $pieLeft, $pieTop, $pieWidth, $pieHeight + $pieDepth *(1 - $Aspect), 1)
If 0 = 1 Then
_GDIPlus_GraphicsClear($hBuffer, 0xffaaaaaa)
Else
_GDIPlus_GraphicsClear($hBuffer, _GetWindowBkColor($hWnd))
EndIf
Local $Angles[UBound($aChartValue) + 1]
For $nCount = 0 To UBound($aChartValue)
If $nCount = 0 Then
$Angles[$nCount] = $rotation
Else
$Angles[$nCount] = $Angles[$nCount - 1] +($aChartValue[$nCount - 1] * 360)
EndIf
Next
For $nCount = 0 To UBound($aChartValue)
$x = $PIE_DIAMETER * Cos($Angles[$nCount] * $PI / 180)
$y = $PIE_DIAMETER * Sin($Angles[$nCount] * $PI / 180)
$y -=($PIE_DIAMETER - $PIE_HEIGHT) * Sin($Angles[$nCount] * $PI / 180)
If $x = 0 Then
$Angles[$nCount] = 90 +($y < 0) * 180
Else
$Angles[$nCount] = ATan($y / $x) * 180 / $PI
EndIf
If $x < 0 Then $Angles[$nCount] += 180
If $x >= 0 And $y < 0 Then $Angles[$nCount] += 360
$x = $PIE_DIAMETER * Cos($Angles[$nCount] * $PI / 180)
$y = $PIE_HEIGHT * Sin($Angles[$nCount] * $PI / 180)
Next
Local $nStart = -1, $nEnd = -1
For $nCount = 0 To UBound($aChartValue) - 1
$angleStart = Mod($Angles[$nCount], 360)
$angleSweep = Mod($Angles[$nCount + 1] - $Angles[$nCount] + 360, 360)
If $angleStart <= 270 And($angleStart + $angleSweep) >= 270 Then
$nStart = $nCount
EndIf
If($angleStart <= 90 And($angleStart + $angleSweep) >= 90) Or($angleStart <= 450 And($angleStart + $angleSweep) >= 450) Then
$nEnd = $nCount
EndIf
If $nEnd >= 0 And $nStart >= 0 Then ExitLoop
Next
_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth *(1 - $Aspect), $nStart, $Angles)
$nCount = Mod($nStart + 1, UBound($aChartValue))
While $nCount <> $nEnd
_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth *(1 - $Aspect), $nCount, $Angles)
$nCount = Mod($nCount + 1, UBound($aChartValue))
WEnd
$nCount = Mod($nStart + UBound($aChartValue) - 1, UBound($aChartValue))
While $nCount <> $nEnd
_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth *(1 - $Aspect), $nCount, $Angles)
$nCount = Mod($nCount + UBound($aChartValue) - 1, UBound($aChartValue))
WEnd
_DrawPiePiece($hBuffer, $pieLeft, $pieTop, $PIE_DIAMETER, $PIE_HEIGHT, $pieDepth *(1 - $Aspect), $nEnd, $Angles)
_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0, 0)
For $i = 0 To UBound($aChartColour) - 1
_GDIPlus_PenDispose($ahPen[$i])
_GDIPlus_BrushDispose($ahBrush[$i][0])
_GDIPlus_BrushDispose($ahBrush[$i][1])
Next
_GDIPlus_GraphicsDispose($hBuffer)
_GDIPlus_BitmapDispose($hBitmap)
_GDIPlus_GraphicsDispose($hGraphics)
_WinAPI_ReleaseDC($hWnd, $hDC)
EndFunc
Func _DrawPiePiece($hGraphics, $iX, $iY, $iWidth, $iHeight, $iDepth, $nCount, $Angles)
Local $hPath, $cX = $iX +($iWidth / 2), $cY = $iY +($iHeight / 2), $fDrawn = False
Local $iStart = Mod($Angles[$nCount], 360), $iSweep = Mod($Angles[$nCount + 1] - $Angles[$nCount] + 360, 360)
$hPath = _GDIPlus_PathCreate()
If $iStart < 180 And($iStart + $iSweep > 180) Then
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
If $iStart < 180 And(Not $fDrawn) Then
_GDIPlus_PathAddArc($hPath, $iX, $iY, $iWidth, $iHeight, $iStart, $iSweep)
_GDIPlus_PathAddArc($hPath, $iX, $iY + $iDepth, $iWidth, $iHeight, $iStart + $iSweep, -$iSweep)
_GDIPlus_PathCloseFigure($hPath)
_GDIPlus_GraphicsFillPath($hGraphics, $hPath, $ahBrush[$nCount][1])
_GDIPlus_GraphicsDrawPath($hGraphics, $hPath, $ahPen[$nCount])
EndIf
_GDIPlus_PathDispose($hPath)
_GDIPlus_GraphicsFillPie($hGraphics, $iX, $iY, $iWidth, $iHeight, $iStart, $iSweep, $ahBrush[$nCount][0])
_GDIPlus_GraphicsDrawPie($hGraphics, $iX, $iY, $iWidth, $iHeight, $iStart, $iSweep, $ahPen[$nCount])
EndFunc
Func _GetDarkerColour($Colour)
Local $Red, $Green, $Blue
$Red =(BitAND($Colour, 0xff0000) / 0x10000) - 40
$Green =(BitAND($Colour, 0x00ff00) / 0x100) - 40
$Blue =(BitAND($Colour, 0x0000ff)) - 40
If $Red < 0 Then $Red = 0
If $Green < 0 Then $Green = 0
If $Blue < 0 Then $Blue = 0
Return($Red * 0x10000) +($Green * 0x100) + $Blue
EndFunc
Func _GetWindowBkColor($hWnd = 0)
Local $hDC, $iOpt, $hBkGUI, $nColor
If $hWnd Then
$hDC = _WinAPI_GetDC($hWnd)
$nColor = DllCall('gdi32.dll', 'int', 'GetBkColor', 'hwnd', $hDC)
$nColor = $nColor[0]
$nColor = Hex(BitOR(BitAND($nColor, 0x00FF00), BitShift(BitAND($nColor, 0x0000FF), -16), BitShift(BitAND($nColor, 0xFF0000), 16)), 6)
_WinAPI_ReleaseDC($hWnd, $hDC)
Return "0xFF" & $nColor
EndIf
$iOpt = Opt("WinWaitDelay", 10)
$hBkGUI = GUICreate("", 2, 2, 1, 1, 0x80000000, 0x00000080)
GUISetState()
WinWait($hBkGUI)
$nColor = Hex(PixelGetColor(1, 1, $hBkGUI), 6)
GUIDelete($hBkGUI)
Opt("WinWaitDelay", $iOpt)
Return '0xFF' & $nColor
EndFunc
Func _syncexe($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $syncexe
$syncexe &= 'AAgAAE0AWpAAAwAAAASDBvD/DwCA6wAAgQbkQACvAGgADh+6AA4AtAnNIbgBAEzNIVRoaXMgAHByb2dyYW0gAGNhbm5vdCBiAGUgcnVuIGluACBET1MgbW9kAmUuDQ0KJIYEBVAEAMAUEABQBlFGVuZa4AAPAwILAQIYAAbWB7FHgRAatQNgEQJvMAAR6VAAIC4T/g7w'
$syncexe &= 'CqIPJW7iUIwIAECuAAV/DR8B8B/IcBiv4EJXhvdE5wDKBSFA1xBvAADJAAIAA1YDLwSQUBUVAAAsBiD/EOBvAFUOFqBhAEAGQGYAbXIGABDQNgAQnB4AJWsAki7kBkAHQEEGwCYALg4EABBgFpbGVkamMyEBAEAkl2ZXBvIGAFfmBgJgxFaHM4emAgRgMWluZ4QWMVU3'
$syncexe &= 'NvYvQeYCoQCg4BFZTkM6AiBEaXNrIExSBiAHYvYmB3KVBuBG9nY3B+JEBaAw9AaXJ5d2BoBGB4IylAISA5CTkwMS5EYmR1CWBzKFBglsICAoYRwyB0QXJgegF+bmMibnMgaQN/bmMvbWlgKgUDUXdlamAwIwl+c2BsIDFwZAh/blFtZW5gNIHwBRV41EJAQAi9FqAFCL'
$syncexe &= '+oMAyf8zwPKu99EASVFSavX/FQwBEEAAUP8VCAyA8JU1DAkQUYXJBVZ0Q2oAaoBgBgRqAFFoQDzwXyFEoABQaAAbrQUVSBQWkEuFAOid/wD//4t0JASF9gJ0DovO6I4cYEXxXwFBA16gM8gugYP78wCgy4UAZgiJRCQWCIGBy6DIAYPBQRhhgBAEgOBAYWWWSEWCEYgQ'
$syncexe &= 'HmaJTCQgLgDB0MgUAQDSSEVCQaE2YAQsLkAjRQSlAhRoA9EDUWYCx0QkOjoACsCzh2EKDtBE4gBIEOEAYkwe1FLyX0GTA7BIBB8GgJELRgHo2kT+hQDO6AOTEMZeBIPEOMOLHRBUJCgQUjcBMFoVkcuGqhWsWlPNEEwkBA5R/xU4QgE33yAQAlNWV/8VAG6Cy6RDDrl4'
$syncexe &= 'FtAEQRGEPBBkARhcJKIBAEBgTETyEIAAEEEIiEQkERAgAYCOZMQbPRhuMLO9CGA8CB7AE1B3RHgQ0bgUJFUTgfEPcD0IPsAzUBdDojh8EQBBgBcQ6EoObpBL9wRBIBjLIOh9DKDIRPJAGJBMd1AI/EBpDQDR7kOD+yB8qECKFvDltUUITCehkEtIFtH9eAApKhHHEjBI'
$syncexe &= 'DPEJERUwmC/Ql4BeshMAMAOcNbyoRGAGsBhg1qMHcGcAYNYTBjAHYdZDoAXwcDi4K9EThAAg16dbDmGWEwUgUCdnNphHAABQt2aWGwYwZQawg4xIRVKwkawsCfMC4SDRAAYDEytCwT8hi9iKw4kgBDHoSfpwCkCADgQBtJswNhKwCfDKAIXAK1t1YUAgYWAWEtAD8ZJL'
$syncexe &= 'qREIGvRJcjZwTIEFUk2DwgBvAgCL0DfoIqUAIsAhAlABQGq4L0cAYW4BKJcIkLUmSPh0YQLAJghsAnAwCZoA+IHvIgAw9AbS1rZvwJTmVkYl8BYkd2Z3NXqABFDExDQj40LGBsAG4DBwJZdGB1JmdIQAgBZwVGZAN0VHhgQGHAAAkB7A9DYWxmYEIFdWBuALYPQWINcW'
$syncexe &= 'RtdUNvd1gRAEALCjFU1vZBt1bGVgIwsYJpGMQkGVBwcCNB7B9AZzlsYILDIHAMAIAFCEl0YHJfdmNEYJANsAQpAEeDUAsFQk5VTUA7W2MOBEN8T2NrcDIAGAASlCdWZmZXJzlmUgAIQq8PSZoDFuf3RoADcAPwI='
$syncexe = _WinAPI_Base64Decode($syncexe)
Local $bString = ASM_DecompressLZMAT($syncexe)
If $bSaveBinary Then
Local $hFile = FileOpen($sSavePath & "\sync.exe", 18)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func _7z_x64dll($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $7z_x64dll
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '3Hu/94QEeubyanHVP0f+UTa73uenZLP/Rbi9Lxs2MUGFyLA/S0QVJ+cfv2a7m7dER8FZ4xLi6FIekbTW9eZnRndIIKiiYTbNgxLEVeu7x+CeT/DYSBHgG+fQoIzgSazoZysuIUyMbjppJmNlR/GHuCo7HZowY9iFZ+ZdV8hd5MpAhZrdFOnMTp1hLcuNqMVY8wxe3Nt7e0VOK1SJOoXXIfxpXJIEfRDTwroyVZkGNt/AScOSG7myIcFJwOI+toBqZo0oDjtaa9Gja4xGbHN39P5D7iKeGb+XGq0o5OQh3nmO18/xvNewbY5c9msF1/E1U4iVdNvzfPE4DJZFdDYqz9UWnuYm4cWpZHmLw2IckCv6zwTz2HU54c+WljwlSHoEMjM7uvJAnzcRBm22TFgmNMv/PYSEQz9u3vTiIPwIB23V+4As1JH1/yTO37k/VXhvvY2nYUzytlzdUFCPOLd4GWruzPSNtz4FZF8/ut/pkNKF6+BeFnRaaAGMn56hTY70jY2JHbpliAM1Kt9XHE1DctFSUUOSndBNSPmSYZAMRXpQ/t+hnJNZz2Lf1cK1TKiPiVVXws5d1HU661Uy93rs61OslfIHjXzXJiyyfWVP8QVSraZm7ic5jW1skVM3UmViKXHjpvfKpiWQrnGXzTP9Fi++UwGRTAo24QRJQZ78DZUjfyUei4REfEPYuwV111hlV5rcgpVZbs7LIf0aa6BDTMpkujk7jPaHavQj7Tu1RxNurj8UK7xkvMXVxqd5g139M7VbzfNe7LtNQQEq6rAKpz93a/00yp9W08vvM3FU92e+FaxIpoS/SvLomfwZ4PabP1InQH4UB1MPosaPjNZHDDiGtk5UYDxvIImxDt5ZwRLvlnrc6Uz88usgPDc5uqiVXWV/FuxImymORah+pyqcG/5NbKKts9MInjHuQ2YvcdlZ+ULStKBWE33KjLL6ECcJqUoDkUVflFEA/92p+/Q0zFfEIPRd5klgKdpmwlaeJRYffxDJ6ZOflvIFkEIcc63u/siiYr9hasYDCnAVxyzu1S+K5iEm62FvQXGAgYlaCK89SaUHQ0Rrl6X/ZymxpUbpmyw0v6FRRw9fMFgZAV0a3TOaO85ShmaDKomCcXBIxC+JiEtBYWuccBCMQIs3kDPAgwHHHMeGXRqb7B0r+tO0oysDrkmnHmTu+ObYuM1D9/chijVYhqA7Trc/F4eunoaoXS7qb2OxmRCi1WB6mq3WYOSMdmL2v85N0eIH8SsLOP0pcgQq6OWA922vlXeBFnjVCalM8hqvvh16dA9Rko1Crscovo9narIEFPJ+l/AeqAUBltv8lBd3gCy1kgQYRQy320DY0eBGRc30ELrk0HIv0VtQushghrwFTfJttFufTToZSZpC0KMcuFjxAdtAsDKsgIpRUuO2NqltpLYLEqR0UiHOZYy/k3AzghnJB2rhsAwzJGPMhuZb2LEQ4rAK/9RtTI2CyFkrxAWWg46Y3ugqQrzh5j9Poqgj0x4GxuAeo/YnGzO3/3vcmyMcq8S98opZyCTCFs0hNODCcXhXwT2z/xvMpiv6rRNXmevFrlJN/C3qcM+T3YMVG7TB0X3kPSY688xqKcGAhgz5XAScSrjln0gXyfMNGMarrvDKSwqbSGaZGyk/rkPO3LnM/OGjdImQzKMT8HfRjc5lN6LSGD3F5TJmp/H1Kf5ihLON7GZkHK0nmGOeDpnRnZcMWp782m385MTFbJijLbxJHfWT5eCCKtyMkwFkFYAOvouBkQiSiz5XMIWSk/mOnMycok1Ip47F8Kf/YM3HkadWZC5stLhK9lNlM4dtgxFOWa+eYGmLe+9RPcX0o2MGpKyZCEMNe8AGocszmTVK9tTACP////82FhrY0u2H8h0DkUVNN2jzHLYoLJCaf6N4QP7wW/Dc86NzXKaHUqIVLpJthpk2cUB1NXUu9Gs4bNP60DgHAXoOZvQEkFN9MvB2wlayv9Jw/2pR8beAjo/iI+jR6uZP'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'KuJDEs7BtUYmYPGXL0tV//o/Hqg9giK+5yqW9bM1SnJuszFlao7tXJv/FL6fKqBpUHsNGaZhYHZ3lvi3FESpzZZmdid9ggEDsVV3zG7pTOQjntKBJ3twUTtcRkp9fipwN0OXPVQIqwQwfjKa6QTHLH2oMmuBY4imOEZ/MLj41CZtXn5tUFWI0Rz5eQpSdWM7U4QBHiDf5ZhdOHnDIOJ/FkSQcv3PW9vCeW4f3LxvReUbsW7/0y2K9EAjTk2RObJ4NLoGUUusLVM1+Qkb2lUofP+JhM94/LD+eQSNXvjpoDXbApsmrjPwSjY7HzP4d31Hj778an/aGnxNb0aVnX5QUWAi+RvOhxE4UHWHzEcN2aKuOKRhAdcGXtqsuLuBL7hs6cFdOfFsdTmXxfYcjeO250kAdnSfowGKAh/Oq0EigCX5vyV/5T+Asa25rWi6SKaCEmMZNp5EufQixsrX3+alJUF6do+HGREiioZ2PJoB/+cjhTehxsKs6qn5KXQz8RSjKiMcfXWy/KGh8StlY2Py+wXZEUhmfpmg9u9YE0wr808aYRtmGSqzLDK30T6NOI23dg6tKNjke2nQCtlRdRmyHhsLifj2B37KjIJBL2qcIBkO3K2W6EitoPatqHF46gXtC+GH1AXjq5l/LANxrHwcFe/MpbDS8eQTj527HbGZ+ipY7DqIDgmc6TnMw9pvsd9HC2rbkg4LRSZTze4DeSt8VLp6wZla1jXVTY65jeT4LJTPKnvPJjaZsOIka7EtZ88hPtHjRPzB8546qChzZ7xSrmOIyq5AlQJeijaHtWp7mlPN82sCu6dljPI0WFcPQFdp0h0PjCyjIyAS6IAXI0tdjHMlm43PnSl5JI9KwTDKtr6AqkOOu3kq9WA3zYe9v6+y0VNtcpBF58WGaPmslBFhg6bFnY4UYRanMdh9FoWH8qfoifHscKjeRYn1RNYj7gQjQ3zwXoUMEu6R6VpZMtZfrqzC6O0SUfZMUI7o7s+KD7H3uN7nUau2vm+LOemuiTzpFaV2t/CtHDzByTdxe9YKeKcHRuC011ZyRZq5i93djKedfqODroVSqXpops5CjVMHp2/5TbRjkfTDHZsuyr2T6NxX2u54skT41WEYEC/dPs2bqkauin2X3XlpEejPVaXNekQZqrxzZgbVqGY5w3DhZVDv/XkGR5QNuGtz/BaT0aPvXNHRlX+WxyL3SS3cnQcHK9FDCSjbX1rzLTBu6KoiJznFNsOBLUuCdaMEtw1HNdSD1b0zUe/lkJgBPxydIYfsXlGIOPTjESPt7R27RaJg+HNOejHtmipEJsgTxAozd0P1Z+1wCQd7ciVJOzVYTmIrjdAkNu3+MzMFvZDM68VuWIy849QRPW8JZq8IqmAb47DEMWU6+VdPd333I1My/HkQ09YdMeUhgTXy9JuxtjWR+QZjunb2GmG8YSDwGyA2RKk1ibxZuT+qxqk5j/xYlzS9jRVTv8GBN4gMPbqWhEj2NPUHIB9Lhkm085hMFTozxpW3Hno1R1FvzEvQGAfjefbBni8/MyoztWnVIubG4og0ALpAIkh+fir7hIlO/Ts8I5Ho2y/hx7uHnyIgSz9PouRlDDClflZX3phGMerITuhvIvyJptUlkb5om+bzIoW7BccO1F44xU9GeN2Lqh/sQe9B9AhLsBOCfS3AsgYsAsxxdqSF9tLwogMbO+R0/nbqpkHEfHmwpkwlSJhSRi9BaXN7O129rc9aUrgfqkiqLAVmxqIerXqc+MwAHnU9vsc5hBF4SH0reAkSvy80Bc2m6PexuzFxRW2BG0/hrhJBaPJA9bXw768ZwVmOGZA2aJearGV01xSyfrJryYmyXsTEVKGcVs3fZkHHjPijiqHcoyKa3ImPvN2IV2KKFwd2m/aCwDmSXKz2zfl5MwUE/QhkkUMpCTp1cnqrMtj/jrTo+f8UmQySCzDYZYPRtIgyEVzyF/zmhQC/RGJMfYQ4hv6WhmmuJecH6yqZBxXOYtOQ'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'zbrsVdAbli9CGWPFabO5vQdHm9H/Qa0CDea6jnECW76UfRZ9idRtAdDfxnQWFrLkDLB6VDDQwDN8+hPF8kGTTsFIpk92TjGnxpVvEnmrpYHMk3KqYPPBK38OS12EoALX8IlcMKGGrwjDUZyAyBSFUIMAL/wdZNf3RyVjRY4ekbsakIqH5uPkj9fpBB8MsQbc+o7apfAzul3Rz6OkvHhvZStEiH8Am3my2G62URQvx4+OlxAtGHCy7oXrgjBYJeCGMg6ESaM3j8VIWoiLyZPcVWxAx+b6qqoDgb1YTwK2XuhmHWQOD+GKZ+x2XdXiXa1yozXOrzjxtZZUmp0Prj8kPhxJzU/WRjcu/mIMonBz8+Ap8L1SuijPbp3F1bSWeXl66hAAYq/wBDhlhBsmuCPzFQ3v5GKOhZZTU66sN8s6YLt4vjkcRkgTDSv8R/fnHn+Cyu5udMSeipODXwrLUauXY9Md4ypS+3zbBp23JE+UqdLd4b4PdF8KVKzEAVuZW5t+5rHl1f0CnPqeH8ONDGFAqd1P2HMaYrXPoVButayT0s13wpzVLKWFcmkStu+ehTfS6goU9TZSJYvcHJOHKNv3CHwI8F3AIlh6jaygeXYKYtPyTtz/COOiHQdUmFRiYsV8qfctQGSOmgx40LPmZ+sBMSTF6o/1c1Zrki0ccyQW59gj16uK/7DgbU1vjaVYTnkTT8Msc0P0iNcKXauI4DbXu2Qfkw4FdiBbOraPDnmm6DnLFxaA9fU1wA7xrA46FWLqoiodeTrJMXEk3aj4V9PiCUxlfHEnm/9TbFTctxa5wCIdPxiq4EF/z7F2iOakQB0DKratB6ZbgfghJ3P1D2WJ8xu5qdnlt0xApepLvITAxe6bQ9QTR9ep9qOnwubhMX5h6iGTuxRMx4g3IpQVumn2IcGyF8qoYDCBdGfe7feQmlQ995cC3aDwg82N969CFHohvFJAtul85I673+qReuvOrFrLDLVdKYuL52dPGzp4zT69jXDCQYp9mPzF1Ji2dXkHAiwqaNX9dDuJGKuMMqKKPfbyNzmbyR5gVVSNrwOCBwgbOVTOZhwyII1uGzf7qKYfiM0vCXIR1apKXZj0OWJFxr2Bf2IEYV/H7+IHHvIE/5bOXbjsTzVp7uimcU24/YG1lBoGJMpSv5jTj7pf3RAYwBj94GLYpwoa5z+NzxehlMaPBp2tpUj1TUOr5NHSZ49Yje07VTRqLLtIJ+3ugBhI4kJbF0ZagSWPRZ/NFBvLIjDPcBMFwN/ibvvkRmNhFXs3oJ/I02zwtfqdUqh3HEdTTHewm81dk0IEGU3ysBqNIKlYucEP5Y7Gno5NeNLqeddSfJWfA4/pihG7u29v09uWhJ7oTNSAyK3C1HZxBU+W1ndABPZuFJKtaSEeXtMJYZyB/iV5LNUmBT7d3pmBDwovAnGXsa784W7tm1RVTENabzmr3kxoobdaQbcNFuAbq8aObrHAGcPO6mhU3UBUhgmseG1/Ia4bXSIqbOa97dvjqG7Yz3sxAmE+N6Xg/Vmd49efJKftV6TrYSA7YKTrA51CwnHjBVr/8vU7RLqfjWawyLlzQJ/PZsDrU/cxW+CpJynYcB2bERYb4zUxHpLRdr9Sxv4bxFuxOOhC72wOJffjy0wqPQh65JfQNlKwfhDx3MFhzVl+BEMFDypdYuQCQUkNU02vGXmYh1N8zp+OJeDYdX+63saAkcR/1LOPFgFK6chevTTThvfoCchzITY4mO2lqNqEb9/QdNAkw5Z4noehjRY9oEzmI6yTXuGp3Gf507KPvUMxkVCQNe7b0uVvbK2z1ABmIMkvBAeyEI8VlaUlXtodJAfN0BOqaJ+bFECjXcycjBbo1MhGb6RtXBvy735amQYzKcFxjs20S14dd+bsF778hkScZi0R+I4Hvqhkbz2DKj6eLfFNvpW4897Kgga6Er5xuKl2qSy9LcgdrdtAiRqm4egwUA1mw5SjUnBrRvBswTx3BVzlJJTCGJWh'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'UpOoql2wr7NqUzEHMSySMtZIQRXTAepmzQGmgbIUZN7sqhklDK8l81Ufed3oOOt1nOXbeE7RDOc1YNBmsaRTKlMIIg/YfasKmZHaFCXBg02G2xx0NbgRilP8n2sjAkqBihVZ6/OVivMWMoESAPGpDNXbNVn+77i+sXWRGiiLjb2FPrknHeOUZXDEvJ+I3mQC2dVlBX4h4pFkAATCaZVczxpKAKpsDnLfolh9dVSfZ5BugCS/AreP9WmU8Grio0lyJ6dsW37r/AttiqOgIYbkbnv4KejaNHqq9ptSdHfLwcz9l4NK7xHh03nNfKg0o2OEOHXu75bZwAcbX7ASn+AiGwGLfOb1J7tk4VU3IG93tdlCxfq8f6DmiZm9WRwSUqOlbWxdjpWSt5EkXKyL9mEoqtCrVOLuO7hREhiUiIR2Lio6L6I8ZKh+4Ra4GAtPIkbnQLVyya6AK0qXgB8IcCkg1zn2YoLcnxe6deLuOj91flCc3sOhk75s00PasHVi8Xmz8FC0rcbiYpytn+nKxCIa5J9UEqXmGbZIMjL0nRkmcZJkDOPhyfCVi35LQMW3ih7VHetITfazwBu/soJKy9cW12yRilQPDZdIyf8mv/UlbQGg/D6o3UFCGJ7pQqW4i6DTT876IjqWASQWp/lRBveZ/L7E/HJLWPy3gO2cU/vEtBqOM2bcutkJYMwIMVPZzGWXM8gFy3uGwPpf6skZmmIxYc9NFUuDgJRKmjw/bm+bxemzJA2yP3mS8Anv2s4biIJhfKDy8M3CxXdTrFUxAgOsLwtfVgDUYqN5/FCcqc6Lmy75ceHcGi8rFAiFO5a2Idk6S1plvWRe+bcC79APIXlwdYUQ+u/wXY6K/GhA9XOI8On0e0ZI6dT+12MIsLKp6FR6xue1Q2Y8cSodAFnLMZ5oWLsxMsrYvgf7xIFmbOBQwmWM9NrXeRjcKr592deI5xEw2Sgp2HFk3nrjo8UDdm6VeDRDkffaYNIZ5jwlPZ3/d8ScZ80y1avNWKduZbUiUm2w58zSdR29jNq6nfAavQScAVGXqANoTafn/hD0nQcafbVgzlrT8Q37TO/t7IBCDPDLzstt70AWYPXufnmQjWPSRewxU2u3wpjrXCwtJBZdOgxXx5wr/qmfpWWtL4HPthJUrut2FA027Y6Dd1kCU2h3HTmbNcvJUvXcwQlb27YeIknvPufpJ7jULBLfAmrQXIv8WiCfkdMuK3OfktaQAdnaK6pm6Gdida1dpmgleTR62IjnWYKj5hHp7s6OJa9oTe4cuPT5IPYCHWHOkxMZRgwOhWYlyMctejGSmxC4Qtv3GcMG6LQI/////5reGKEiFpLRdgiebielldyGazfOshRcqlG8Ir7CWRB1t1I5ab5jjR9MG7MWWyDgvAc3O443k9cRcb4AtX/1DLuWNiK8U88NUwPARMzW3yt2lJFUOAgzdfgtueiYzDkz4llgPfbcjYIwLNsNdUvKcy8oV0foBpGySOBmzy5dCqA19zzybzmpltHENIPKH11jXv+O6PDVCm6OYtW0RS9St4c8N8XiljJ0kLvVXOCM7USoTaeXD6blNwXwASa6ra/hzoSG7m5QwNmCt14ZfmPVnbRoWr3Bv5qUChFpyxorgiPSLfzJhED/PsKFkd+T/FyGjnmPL2WHrUHcHjx4Bobs04c4tedCoao+DY2PAmjYjotVKDd5gyIYntyTVpjfklDCyavEbpsThOgALUfe10bHs7FFjExqnOipZYAuhZjrCUFkFYatugZSSGtTqryYnehxCmdybuLry9/dX+98b4Tb0icycMFSRLbpvJ8TsKqdOT8xrcYnZVs5Fe8o/OHh53uCIDc4aGYcRuCRUXtVs+URqWvvAQuXZsdf44a/IvyOWM8UY+xsXO+aPDTEzmZ7dYrZg28xyCuHdZH5zbzCS+k+UGLfwnQUMpv1s4MMQXc5sGsmbIQUy7gFj2vyIDNty6lKejXNehturml5cqvhC9cW44fZPYKv'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'iFJcbU4Zo+FbdyHesbxrgkpu3ILtZJLvUN/o1FIPoyGrxLRHRCMad8qxZW6fjZkc/////+QHeyHkUnBN/63sWcjVvBn2UUIsK1gVAciZwptfOubommIVr8SkO2bhaKIR3sykx5/mkYRyqUJaUdUaZM0wrxlOtRhOa0aeDKyugVFkOyPRnB25NeVlBHfbIQYlPH77pYjLRkErb28MBFpEB/hhSNYrTYVeybrLpdOuEcpA/3xiZGtY3TrDCmskiIfwrERYa/JLfdkHGu9oeKliRHtAzNSSoRuu8ni1pzoiaVt+OBmDh5Y1RtBMNpVgKXIbFuJl4l5bCzr+iBWouDjv8jkgCvj9lYxh2msmJA5mf7GXd9ay1sTnOzkQK4rLA2cIF/P6kbkhsaYwAH/l+uURc7YloMf7GhTl9musZ7IK3SJmwVp6YiukdIlMkSVA0t5BQSdISe+Twp5IHBFpaMRhLOnIEUT2r65Vy1AVjGkR+KBY7T1+0/aAg3inNUaGasQvfhHDHE+Qims6aQL8tzSRuiddMFSyHQ7iSGAv6hQxQ48/aqrIvgKWkEOoOMtGvpIRIGeI03w3fElR8XRASsXb+kSA4A5+A26u+0U9a7L6kAOz8dtxc5DzQe0X/bSRRYikpND+UJ7LKCG5G706jIT6k1R3LfQZDSgQuqjkFD4x2dEas4S/hcyxFzJbZtPFDTXjnpF6/bkkmJ8VbYCqnZdHz1KXnLumCwOKMkkTVA18zZ+opRfpG1WRPRSyPaoW2oGHfLPDNFcuqwUVXj3Qr1DX2V8wka4Fed0hPDIR0GSImNWxwCXZSyHGqtJh2h8iZNd3ge9uHp1wt7XDMvBD9QnMm+G9IA3L4qME8Y/RyCxwld5oBWch4N4xWOjUfmlu8xqH2HFc+yH1YlUEoEesKaVVvaoMcvw+SxCEnDYgpmMLIDj0o2yoQ6GlZfcwrTWJzLDsAEkryUD7EUxO2Gb8GKoJORjZlnTH1Z+/46gVpfxMA3P5SeScwhfqZam+f/nFo6CjVzig2IJxhDq+SvvPtxT1UGG1x2EhnHQB1ELHbDc5w1lgyRIb1Jn3FtcL8684ejurruYR4bZ6pFiZEenpppVHn9AbDg0v5y44kHaL11Bn+WZEH9olF8PSat//9hgycbv4XEe1ABrWn0Vuv4Jl2m7L1lHhfKwa4Z0PH6fke2/5lZkB5/+EBJ5HYVDtHR1cz8K/GC/mNYVt6328yJv5SVJEk1KTtVFCX8MbM5aXE6arl8eqH+QWLgN9Zy36x+PVAy9R2m34ECXuc3zxFZJt7Pjvfm9kjscD8MapP0KSnDSvCf+T3yOLD0kGmHvvgd+QchFoguN4iEYO0wwNTerciEcopSQFKJttCb0YfZmNBvcc7Q8MZccdmE1dfXZRwSWeoEkdTnyqt0S4L5JLGDd4yjl3BaZJy1d4StCVjLwmOhyLbHEjwY3kioimQFX8NHNRmEJQKn4c+720ZUJ0oYXw4atI+2isQtRNrNHqfTM9q7fpASyuUyE0RG2djnJKowTtCpVt00ILskde3dP3fDMH8e/HFajCkrKnTDezeUcH3JuDl/cHBvW/qTYKGOx1wCXEkyjOP4n5pba6xlUNaQT4tUFUZWDYnRHGQGgmskvM+dkC24C846GLCJaxi0qZhXLBT7WhYGTJfF8thcMKiNaDPS1b4v/Je8HXW/uIkZJmjALTLruduNNhBsjGITZZQ4Ux97t7g0wAtZziDo9AXrOALJ2Dhgo8cFpwqigk812WqzB+g3HQnXYX9Pi3PBFOmPFpsosdh9lM7k0A5gMrLjxuoqA5DlkUqKivMoiI0DVLpfWcxvc1snfawGKqllODU3cuuYUiEVjMH0gcKbY/Kfn6s55qGaA1JNECRXJwSxw0vIHQyHzKV4wuFdxVfnVmOiKcAHc6RhVQQP38Suiwb9Gl9OfvbAp0oLRmiImC9XlPZLAKZss4PB+IJDO50ddTYrwFq6oydTj8fMEhTIEfaXXT'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '7OJ0ftMi6kK/g8bpItPA3wR2xODLX0jFgYAkoU909rlbQhmeB87E/NbXrVzAl6TfsSKd5XadpI808ILDUW9OG6sr3/z2D12Wo7WB+cO2RyJmOnJA6BPs6b/mQKL+GwEwJs3pZxH7rWenDJF0tPCP7l9KANBI/5KFW7VLyR+LQoVjZNuQlNfXqM/wR7xZO/yOypp8LTnBo4mL68gOeD0dfm0f8Er6nVCYfFIu3dK5ZgAjMplP0mLVXsSQ3yxDQRatMtnWIlkMAwGfd2+tEbAbYx2Fdu0FVEDSsVdtXTimyqyfk4+KoyoIYEvUVMkLwP4ZGDh9QeLNo/DZo85NHudvKLY3o2MqWcFX6QeC46psK2iQDPjoSaCKt4KYUNa1ymKtHNhWJBgV6Tli+ACfXwXhLoyeLyWk0VQYcRsMURgVORYPn4vN8eqUuUbjU6khCKPgXxAKaeH5+ahBu2jpzyyBjAIjT4jWeih7jtuFypPR+sAx72Uewg6jTmgWe39AWye+o1clQWeyd5fRG+9hbCwryZAUYKPd9cBfBWG28AWXU0uyzq084RYVOdtuKIXCXAsTdR8osboCfFMT9OVPSjX6OGSqtyP8B5K1IH+RQIwdIoM2PDlOz2YYetCylWvKvPNTMkLDb39fnxbx81Azb3iUYC6JPFfdqRbfKZXdTurg9dv1NdUQBzroGhGbIKpe/yK0o/6KmdVI1WjHWP/eMbHzg1ovNQWN0xC6HEFnkoseHD72RjeOmXY1Ahy0v5cmvnRu4DGsSN9Ojxj8nJVXzmbGMKohx4SXuZVkWzCBv6mht1rnP07sHwtFIYO77Wb+LlL9rB5gE/njKb4gv0MM+RsxjHat8Rlf5DejGOmSpuedwI/nnAAMWR7e8Mq8zq93qax82nZsMDJPV1X4XxJ1hOnS59yTJEfdV1legOhKtgSMZ3y4P7WKZy0CCjwiSX0ysgivpqi/8vJsa+VpiCxZxgBhBZGxynCQXSAvEDJ5xOQjglmV5tlN2UwLqicxRojWeZw7e4BW9uCznQyyvSDj6qbKXabrchKRTQcTdI/VrfIqNovrsaKPpptpaPqYIqV1UEvIS0x0A9y5T22XVtI6uRin/3QOO/AU8UCbBfRdOn3HfM8ElgWnAyjWzBUj5rSY9/JoUMLhvMSjxK+/vOR82XQ1qAYrGY6265gHbBaV/rbJl7ijLVEKXzdU4eUbg+H4vbOLYLrPtn70ouKBEeA7vHMPtFDpftA1OqCfGUTJjvU/E19UdNGRBq6/TnxMoyMKqVpWb3+1hPkVeTkjv0lx4X4iz+06eBS3dc/u+2MQ2n5EsbssAXbwZNGPiL8v/4tCQx083Shk5PpZMqxc24zz+RB12qgGVbT/hwhZld17MeBPDWcnN8yZpjCvqw3A5+DKU8cud4hL9IMW1sufGySi+zzXEAgRSoP/AsXyjAZB1XIFK0CLtBTFO4pk4b5i0bwgTFkP4NZfK4NclWlNDetHvrAnNFJLD6Mp6fLZtOUyabNhhB9q1sMDHH6aTQkGlJN2bN9o+5ZyM+L6zVIMGR5b1Y2Q57Enb1kl2QRLFtAVzOJNBERDNmXz33GZuoa0j7DBfGcjVZJDyDblDMOQJmOr+cq/d2AF8jIprDhVgomg9zG09Zes/hwuEhtMOvhgy8BkRSEBHPWUDPQjD/O/5Jox1RH9S+fdk7pVoAchBvOeY0FsXVis/vuMLdN5v7fgzDpsZ21yvKjH2GxoBEDqqwTy1B+ExJ3QNNmyHQniII4VhT+VkrL2u+jUciVPZPxN8icXvYCdLEYkfLansphHVNgVcbRweBVlh3GGw5EDjPFxZPnru9jBzEUm/XAFlph6yalT44EpQ78CqeZ1JG8JEOsRVcQ749KCN7kH6Mm4oT+5wfYZcjdA7c3PbgkwF4FpUpKPC61bdO7fTTj4N3B5XQa3SPIHvp8GSoc970moeCnzlYtfR5KqHHf21UEPHf+8fRKUzJNuXbsMpDAzTC4Dud8i'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'NRD0KyOCGwfo/6qzhxReAZU4expRbR2DdaXliPebRr8epBhCmIEdKHF83B83KV+gp8lqVNbX6ZNptri3FRVb9Q6qxVYMmBUA2Ve+IJJQym0NrHbuEWThuw4Je60P3LOLfcEIo9kHoN9bk6Tw32YG1iNFiBqzgW0vR8tF3gy+bgEF4yjnOccVCmmDl1d5uYe6zjwwnn+dcTfTuFpTO/tTjtByXnE7032kVz4+LykoHmi4d0fYH24/oULfBQty662YWa0WvzXD9TP5qlBOIZYD2jCBn50fOToEuseSsMEx0IK0A21o6oUHbsl5lxRht/jq0lDc7PypCkqRQYPiPZVbOCC4mS3ClVmN0edFK/MupLbHZh3S2KEk7N7hrX+uUr4yvYpifzflLY0iIjYD7QQvrm8ZSW/njeRr9eAsRrxER3Q/sBollmSX2ZY2Ca+nwNk4vPvtXXWPx1SNNqLG9w3YS/6uI2JE7Jbb4hAT0NHmNXEn9w4BLiQef9dLk4jmrJHu30zLkFdKXUY7bC1PSXbGkXVjMZ9ti3IulWX4sJJTjKTuWo9igPKyhOQ+Zh278DY5O0gwuBfz596GKhEDxtAOp8l9SBrfYXwFru3RPY5Uu4iPp2D1pd0Qety3BKmSxplWjtpRmSTGhZyjtCUEnR/p7IUnBmXUPcQ4OX1IqJq6FQn+Hjws5aJe9WwTRNaL0MII/////3GHeS5iROz2RDtedjhoSNvUtzENBNS5LcHwo4oquDUW25xY6SeWWL7ZYyGwYuu0KxhaS/yeXGQJ3nYL7dFOFvZ1yDRgTrnNz4GUXW/H8rRFdhqrzv5zLQyZLJJGVX0RfVppKEqmev4vMdxDZ/GR0hw+QXZKD2upBQVpltVw5awchAZdPyxf2JXzJ1EBhByKGhG2Fjjk3w700/6A3dKTktixMnIrA/J2/vF+hM0h7dYi2TpQybXuZw7NHwE+vQdwkO0qoDU/CnfRJx7Uts8NDZcSJ19a1+4k4BFerkclS9jFNCqLKYhkA3M9848V2pKH8Q3rZIKXvSCamHtYhg7Z/Hz+9c26KFE+EsKm7VPwOrro0eSB6J4Rm5d7zMla1XXvrcIle2k+NgDJXLzHHOrSrmjFZsfG1oFi0joASDDXGiPibwuXZCrUkCUhRKsOZuOyth0+FSOUalAF/s6BMG/4v8WI5TAPxqs54rAYyt25c5/cP/LLRKSzB6qWBgd81hvxwlDKnZzzXEUO2gh+ZRWEJuPOWSkzLITwlqDPm/syxKABDXtDrSgQKNqo2pGJpfuAfsFYp30HtELNqQcbppAraE77xDVpL1+eITVaGL0hm5Z0n1eGko6gEuQodgDGgPzoxYByB2ceM18EDKlqqaBBR5a7Jm4dFILtLtL5NwjOfyp32slELIXg6G2c3Z+9Sd4dP6wfa/J9H2vQ6YYPoFlbm8PZKgBjnW7QPV/YVft7t3M3H922lB8eIWP3qAWrbTPI2qd0O+zAx5RqzL3BazeLwtDHruHHKGNH7d32nv2Mjzpk6Mc+wuIujCi9mKwbkTZUXED52Ny4hIbsCGuUghe/XSuZOXCtfjCB/nQ/2jWuMMGrJIi8nGX8rf7qHb7B5+dwsNaECeUzpkLQVwJhqr077fApDqlu7dQgfyclPARmRnWqaqo1NbIQInGxG7rFSoYlJWLe/Rsj1WaFG1qD5hPahvAJYMw7D681bFziaQDhgh2SOlQP9Ce1GM4yWq21bq2sefVQ/uJFu9uQu7H3rp4bxPI8/kfvQ1Qs5j7j56bynpgFhEC5mJSceXuJCcTnEnYNhDEl61EkYF8ZCQ20eIJVaUWtBYRVRN3qYfiD67yWYnkAnQvFxTHfUL+1voKqNe7Zu0N0X4yMz+56ElYXAn8KrSmZoJxtDX5fCaucT9Et6PlAGON+IcF6DRq9vT0dGOu8Kt4rlVrnOVsGxQn69wXdKB8QYT1deLBY3g7Ht3Evbd/pLGApokwoibUgx7veZlnS/IyBScMtlCTM'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'ng4fsAH4q3k4Ygs4uqGKorZxzfV9azOxr02P/nisFVDl7OWqNC8i0B0e1QPVulB4uTHOHgEjbSzFG8dxwLagKga4PQA5KI7VT0BWBwrevhbm4+AZlh8z0js8Naaoo2BilZ/2JRMluRqQXfHeF4OUV3YMZ2PEk69VZ45n5tPE/TbPTtgqnkt1Vr9WilJ/QFlTq4wTg/lGrdPFrO7o6mvc6LHR6bIgGz+GT4rNEWYCzBeW1LRM8JGFvGrDClLtLtS8sffNzJUmmGlbE4JCz1cbqFxAy0GTTt1HBi6kTWMZZSoHNcXNL6erSrlCK78g+3wK4PK3ePgrYeU3ot1ViW+A6wJi4GX5CQAIxXV1Bad6hYZE8kGHDKYYdh8u59EmwDSKlp80d1PGfHeSmTyp1WmdFnHUOsLjxEf5mSTF/9B/S1TxG5x7SFkEwJujAU4uR6I4I1z1ClG/R6DZr+ZfxIsxsptf/BBEeFn88Mj0uvVRRtu9LC+1hhzlw7s0+xm5RPzyIlt7QOf2OUO8Et+UETLu/aTPAJKkCM+1hXUCNlw1Rb1WQRPe0G8P3w1NJKLic02fDDNpnKfr/P0s+LFwPejQ5UO7vlr5ZY0p2zA5hCK1OEv6DN8Nnu3cHt7Mag0OmbJsEGOM+viZ7v0D3f9TcQKoi+Zi/xTqIFNn2GKQ+FJ5wD51lgH4IZ1bVUuAIwW6q9vXVFHLvE5wJ2W5izAgBH68WL4V2rJgVke7AHiHEognSjsZqUs10W85+cNAGc33yl8mK1ykNYC0oP2YxhWAu3b+1sogSCPSX0Co8jkhjQmvivIubyQhv+7o86OPy5EYXl3Kg2H3vv8Z3did/YtBvjORvazOkGUhKrTUOq4SCkxAfrLM55N/8LqC1vPseJ9EzUZeyBkVK4gqWMFhokATx2eR6fO7ymFssHT6nqobd7KoI/dWetiSSRBEM0r5cSat88SVXnpUdUiBb+XE0D74bE/mCwc1LEzdgUUQwz0uePS9Yasr2mqIJoSWoSyUPz2hB9bKOg6KMcJQrUV9BzJwfEHsY0rx8TGsEw+9qCiTLslKQRUTVSpcGUArlb/krjhav35f812VNemhtPcncO6TV2ZitrNkf6QD8VaFJquVhlKYiC+rkpExnmhZqXmWRG1rd70xjBLo2NHLtlvTC4UF5WLrYN7QeJSpmypcXzhbDj68LP0Yr5tU1BoD+iETEmdTP36LedaJY+aR+r1PB64Z7sTakl0XAaxCcuMxPEWtJOKAD26dJgm0x8l5w3MYrkaEuJbqNaWRSORCS0tPS2nuSN9KlZ+OtHSlax9k6A+57+lkGmq/X6ZrKHRlmRrC+pApumidvgaY/8Xcgd99N3n+v6HS4UnDjYIssKF7M5jo85iWfYZCd37AbUMJx3VgxAIv6BwDidoOJ83lT1SLBSfH3jyFuFZfHWaHGIPABkLKbnAnJvEfeVimOw1xvqrCpvR9MG8pt0oUsuomZwVpQU2Q3ludXdRhfYbO4ctG0rQC6CaFqdAi66T1f8lMwFRTU9rz/iRVyYGTn/jjQZiFGJy7JCp3ZLdnM3dXp5SIM3rESusQTdgfBNhBk47PwM8B5kZRxuobLBkuqi8Ny5heDIGJjzwDvEtifnnLF2TrmhVBkTuPc7k2Jh/lgy2+mVTz/gk91c38ik4QjVibq35EPwunjImvnYBYWenw+3Qd0aU0rSctMQAi+QBj0PWlp+1J9RmVXb7UlhEJ0aq2ikjCtnedJ7gUAmu7VHrAhr8oU9wFNBcImuHNyxjSW0ZRXfQxaIH74OKZ9sQefi3yApfkB5EQqGjAN8FUM1EBPkxwLr8762JFdZuaELOLuzDh6w7FtmJK7eEw3nXJhqf5J+oKE/F6m/CHBFghf7oCwv2er3Rt5+w80VZJDu56HV2EQKrGnnkTpUUUjj1SdbQXMjCv5eEio3xB6Uux/coXXZXh4AfTP7IACXDsenBs5Ahc7tE0yoxoKQi1tEoDQ8SMS016NIUw'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'K/YKTSTEtfzIX1oJkAQD7AGneyTXLV2zCP4jMSVIR2T4z3z7KIySx0KG77PMtl3ZOugeop0qW5P3s98AEznp1OuJURmziC5e6Vrk0W6wdqE+QA0IGz6cyzi0QVpV4PbhlrGQ9uSQf6V64b3YbVYf7ViBUBXJ9lw5s481UcqgdMf/9Ip+INp/U5Vfyu7tmj54CXP1z3JCCHUY/pnasRwQRIWOXsgzwzNx1xCKwtrGoRABycrm2F5x+sQWeqZreUE4vnFa+QrZ92jq+mKxMYAkrl5DipKtbaacJv2sxoisidNRp6DaQCw9rezwaFsdw0yNSLm7N0V3kPG9uMq3Y4vycb/9nqm4ZSgl6xMu07sClz+XBSPSg6kExJLqQRpOx3rqLc8PfHjMMwoEUrh8ZdLo4sS8haS3Id/CA9ceS9dEuZyfgDUeVO/fPnC4VqVGUJpd8eDIgR+cHj883QjQ/AjEIAHaIvq9u0Q/cWbjzfz6xSL99PkyK2WjlO7nHeyEgr3UKhCdmDqQ+FGgbwSeDmSArU1E2YCmiUHuWLyEkgRr7nqEjx4cnr0SGOw30r4uwhvm5Cv4Xiffx7EygKwTinImFbtm/Zs107QD34T0M8lCG2e5bx/J1H7efRQgSl49CE5Z0CJFQvKW4p+pUHvCPv3FtbBmrZgO+h/TtTc8KIjKgXqff1aXR8K6OqUvwzeOKfg1II+MpPjI4+qmIcK4YFYB65/ilcdepX92Bis3SXKHnrsW032Ny2upd3deUmLOOTcoPZsK/YuItmFi4NDWZLXApCEUXxhbUzh3Lvko3wXpDRZso56tzjUvQi2U8IOlrXX7m9wEeIWRy5t+OWF5qfWcLCR82WSrEdW3Nj8+6a54ZtyGxrUt7WqimzfkyWbPj/HRjFWwTioqcl99QnmXJ0noBpmehEjT2+ls7ocSeyMwguKdRBA92+dzeuUfxg1Uev9VGCmtcGDbJJ6yiRzE3iyD1tT3IHwuFdLmGJ+ssc+VcnMRlM0F7Aa4s0HqVpq3UoQchVbZ8slNE+/xwO72WDOZYB/JOLV5AhfGSH5AS60IbEA7zldOa2DP+0OHYKF3zunnVdHjT5NXoO5YC76Y58F0r5pibnBiP+Iz0IksF+ZlHQysBUem88ZrOduqsnf35z9Vl0+MhJKPL2uPgvahd20FdaPb8FV0s2fElwKciZ0hZsDId0uoh+kxwWQbCz3YLtQKiIn5eF8xkL1nwe/rZLIfqZcdz8ampRb3urBNBIOYo9E8Qjlh63MXCO01jf8cNbwBhMxCZo8jZ0I/rHliHyZktVf6W5GP5I9rxX8q7ovMEpRC8MyV6e6XN56JsALB1/gYvO/3UvA1tCTDlJuYMljRTx8U6jow6TM2yPYyxbpX+syQPdwGNOUXqO919vqaxJPfzIogPLEI/////6RUSSwA+h1aN1I+kw8En02VejusXNbHWtaPm4sha3iM7i1l3iVKqyRIjNxw4JkX+/CJLtYX1joNos2AZ0H9o68B57pGmHbeGgbdw0GoylLkdcOtamnwfeKRHXQDHQFj0augQ/kRx02ciAeudxvCTPeVlgyVbYclxrTuKajZbIFZ2tgCp1VMkOxcVk6QIy35jPsKLk1Ce+HS0vh2IXAde31g4d+w8AAfiBFnhz+rRnuI+PI/MZBMQ6U94tFzfRI9EnLzykbUoIb2f1mt/oKyztNDw+lvB3w31NDqGV5/5C2IvrbYYBJMG3oaezQh67tmmKzEcucrXw/53cyhDEeH2snLGNbgPfEWjYe8Fixz4DLdXMdwQFNI2Fg46bIjxtYEltScaxWw1NfwbDuyWckovjxEGJ7F70HnvetHu2CFpWg3YrHnhGs1n8R6N3l/22ZC33PJhlzbSEcS32I9PxL696HvEbR1a0GKUieeXT22xtAM9sMlpFL75Lhh8ThNf5IC5FsllbsYx4nRSB7palE42hYt+v5EMdLg2fnV577pa7cnKS1HB0BJVSnX9uCOLj2CAyAV'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'fC/VP2TsCqjhXVS28P1gGDoDxRXk3Dj9QIK39LG3hUDrF5JEeLtUW1AmWwDeAKcEgwyqDCHfAz+auBPLw+Hl7WraEWLnl/Xk+n8O383OsrV4SyQ3EUOfyzRnsLaS/L9bILMyOnEAe8xKYTPlA2trwF1kttMvc4m3Rhj7XZJBxJEoUDBuXan5HpWUTorAHYvhRV4DUUMKNrQw1kdcwGUNDgbZ1Lw8z6o2NdtiVG1JgT+FDNDwQjcwjG7efvZQRz+z/c8aK/xcUVuxhkRT2shG6KQDlprADf3toND8FAULqlD8lmXz/1oRU3JeZnkY8TIzNTUcB5F+UpA1+35s+NPV0PSyIpYMXXeq1Kyqy+FV1jM1OIfFPucIzv7N2d6khxcigHOjUPNlXjv7dKa/8X4yCHHyQta5KUIw7uZ9r7uO0YxUpTTwxIr/ENPCQXqp+O20c3QEEPIROfiD8ejUZPOoEb2TSV3o9EZwZen/Enllb8ey8sTJGoj3I7ee3JoFGhtV1de9lZYT5GaF2VD9l9c8UhrfG0/mfQdaw8WcVAhlpSFg1FKdGpNu0NuHn7OV2juRicRRhNWn0zItu4YipIY9v9n2Kp3LJMvTKfSX9Ulf0CVqJNLr847CHWa4y0qiY4RkewyIXUM2lZk08xMax09H9XaxqhtTVK+Nbu9k04ryLaNZZwFO97gdRF76J7fjv5ViRk9j3N74yVqTb/4o3j8/mXtm5tpoejiyTuB6UScqqyppc3GTiTWp1ZUFPpIhpDC4xxx2f3hW2EHucM33GJKuDaWZZD2pfqwEhFH4lgOfzoVuu3IJiePdkXmvNFRtjCPE3NRwjwA6b0e/enQCwOlBJajP6hDdVsIsoQ5cx/WtDMmRhIzYv+FuB+K5ovc4sp3LEm1mAnvJIw4u1OgukjXIrDr7N8n06hyBLA49GABQnqeB9v9WSxI1ueS8BTO6BtUACDqS51RY1tP2N2bcsiwmechjY7bVgiVViBO9Kg0q1y26yHIIxqyCS19Zb4MfGoZ2jVxDtor9lPV/SfmPyCXxqWqqNKKa6uytN4G906m2oxUPT8gYh9KjLNUnw/0rmZOCX/ukpmFE3+ssZCIhfoVB2XihtoaRsc2x46uEdXlS6SIAUN9JPL+O4q74yvDy/B9k1HoBu92sLk0TkH7zSPyJEO/CdkmV15w6RSoTm4uMCBqmq2aWdcEZZBwuwHRO5gj8XxUHo3/qu9ca0wSHuG2iErC3hLwOb/Ud6Z26UQSWXUWrdPtuzl5nYgjxWVjZhNX7bELIfse0Gcylb2y1Jb+1CXsihAFb2LoMfO0DUaNEVMGqbrUfJuWhcIZYS9jQHfWx0GtWH+V3KsvvnH6L06KR+hIoDFZRQ4ZtPQYxqEAUGAGvBqXqQ3rMrWjKsl/B25fbfc43fBSqFRKrXLVKpM5j44T6N5rYOJPxmkldJm8vGcxQCZFjJmhce6EBJ/ca+ghu2HmaLo9E4leiZ4XLaX2ZH1Z8s0JFlzf8BeO0gFo1oK7BAThozqOmzu1gyBKCwDjVOo+Gxs8UTl87jirj+E05NszOCGXoT2vP5vasgLbOKJENO+j6VeDkjngcOdBcJxJM1h7XYwXvGabpCVodtWzh+AAbifDqA30CXzBR7hisE7gjk/8qTMng6RHfCm2PlPpW73e08tjSEo+Vzz2E4hFIOWX/WMtYwKWSD9eSyhPZI6MZvKWO5Mt6J82aKRLqsU/olYNTNF/YRKWTdczFtXwrTdwHKYA2KhxyI6OjNmQVkVZaaAt9u2gVDKCHhMzThOCoBEDZdPT/5NSvJLhE6XFNnwo3oFWp7j27kOolYyIavYT3onZ+cTqWaucmk+qyyK4JCkaihI3+M0JbuZ6kKVbWM1cf4WPs2W6yXb1w7Kg5rRYTs6TkEHsW1faMTA6Tt0Xhagq3rymXQqGoiC/2cd96FJIgoiPMkvVN/xPgstniOIqDorh5Pz3UCmYlnjHFJAlO39pa82BRoykUisQN'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'p2CWDpMBoyCD9yURicWoCTgzgyOnOnt7aKAGN+8AMnYrtajO+M8JcANsjL6hH67Q4ui6GrI+eBKCdfRQdzu11LjXvNQbAJojQXbpvXwRKfAbFmoypEfF/KTjBfbgbbQUSZhDDtodyyWKjw7cHwxZ4ebMNtJIPWbWekqkvFcTW0YigJSUp7O6z7fDPkUmEcq/TBHEaFrkFN7WOdVcwJsrFeiO/sCq6JAkPY1OFefHeC7p5AYAisdjU8pIE3Cl710SVwz1h+bT3kcZl4ZzH60gjktuoRobsGeo8Unyi+2CfO9EA7U6YX9o/p4ub9/+j8aFDXivisDYh+oMpkC38N7Uo2HAG8dS0oYkXyy4XdpBe38qcmQPBxE6cL7YyD3FdtjIWksmsHhTjIq+yhPUS3YdpcxZ3ikQYWPZykLIdNDFBRfLaDe7EhXkpRFADBfRt/RMdUvpfleDN+V0VRFdXMTaDv8hTNUKVzP4vkPenHUl3r/lmxe7dyXWRKw/ztgfXZ5WUyUehRvyooaOVbCnlQx7UT7kerh2pZkYs8x2oTUziGv0AduKo3dmjrpMjjm3aUr6FAu/LLGouVcPhnBztQ80z86G+IguX4PEZKItoWTTRerwA6ofUro4h+oNGAjaFhy/13Wd6XCkTpZn+ldaMjKC68UEShNfdWLhMxNt8KxDqOXhjVcHqPbhhzuynix3NXwpts/iYBJ4vH743NYSaznfjQetu+0qM6b7ztoyZ00f9iBhRhGh3ED1tsy8bf7mmu9SoEW9NgOsK13mk2dNp/ZkbpymkoM+leN+8TA171j7+J8ZTZiUPJ75v9CJk8+jJ/Y48eGl2l7jDFo0Dh5gHoR7Vd1QdmK9DSXG/WKAEmj3y0quwAwhxRsToEbletrlWh1h0F6Kg9qmFe6hOKPSQ6/VUDIGRjN8yfcHwmpXe7q5CILqvbBeNT82RAui5HlgxSChYPR7mYdyG+0SdNYTJzY78gWKzQapMni5dwRMw6C7+EwoxhmVPvDv3iziE3R926NTye50OBsuFj7COCFjzaM8zr+trP12ZOILFCwQRpTzTVRc9i0C7yxJAgF9GzrSLYmL1KA79lP8wOdRYVn1OIFJ9oSAc7kNcCImrZ0idNR1sa36DiPd6pvmLYGi4dSDN0cqAcH0PCOWAu37lQXfWUsUlKXIqAYN2Z6orPolioWCgfAYHpGNpbW8Fp2ZRb9Km1ViDCZpxcHa1I0FGo2cXht6VyqgxNTHFSKA1uGEoUCSpJ2aUTOMH7l6FVVpwnH/NenbOmtnhGI5enWriFqFppYYAraSrtDEVc6Hr03H2sNNbZRyYz75O3c58kBOdQhmoGCaJPokPoZ38JXMYjp0L3m8xbrZbyr4uqE1WJzOT9H/CEN0EHaJBwwmUvlYWecY51eJBUOxDOsLN5Zk4wn9zHvVfci21rioHm5GtkyLaJolnfshPa1nu3uR/8lQnw2x/AMOipIYmWlEAakUlzzkdLyin/9CUPxn95M6AUh3Qx/MfEHMyqmNN3GKemMDihBMYscI/////8cTOdaNLdbW0k+NH4XLODCmY7pgnBu6W1b00Z5UaUgOFxzCpwg6GXZ8Yp2V12x8YosP5axwXWHTfD2entQkUIE5iGLBl++Lgy9D/IiGY28SrRTvBHtuqz15MUeSXYC7IAaoX+sRDLv2KLM1qsDIP9ulELEq+9+2O0K7iWgDVr3kX5tL0VZkUVSHnh6uhE6OrTb/lLuqx0rUHMDQAbeuAP8GicRNPPeTjkYFgl4GpyFym/L42Ma1eYkByweVOz5eKmyJbofh6eTOWmqBAvkxC7v/ExpYf5ZpmniIFgpHV2d9cC87YK6y60TFZANlL/5la+Z/SAdgPOf242xtPbUThuNya8N177eROZjsRFwN+FplFbQTrt9wc77LkKh9xVcM/Em/s7G0eFg+QRaEVF8b4hoRyI4QHoGD/JOxjVr3BZ/wbagH1vCwj8iCu8j86//tpnUp1BMeDIyj'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= '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'
$7z_x64dll &= 'MoJMM4dWJjeHEkkIc0FyYyDRVEYHgfZGRp5OdW1iAGVyT2ZGb3JtOGF0tIJUsDMHMAVQRjcUNlc2VRbgNpdGl2ZXBiSgZQFjaMIUJndWdgAVdlbWhARSFtMy8IsB+OJTAPBm'
$7z_x64dll = _WinAPI_Base64Decode($7z_x64dll)
Local Const $bString = ASM_DecompressLZMAT($7z_x64dll)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\7z.dll", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func _7zGminiexe2($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $7zGminiexe
$7zGminiexe &= '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'
$7zGminiexe &= 'Y6n3JtvatTxgHEkKZrOWg3PULt8POORw5l54RIinKp/+tU2iSuYPHmVNF2XePBaSliChg2E5PAjw2qZmAFoX/iZSrn08P7fEnHOlH6U4uPKf/ju1RqGXIRIR4e1YKZhjFNzPevFavb0E8czXOUDr5Vli+dbdrsylAh4cncjGrx5wnygNkjscbxkvzBrrhylULKTGLf9OefbKavDi7GB4hL76hwpclO1KOMBCllPgSQibdOXe7o6XZd7dB5od/zkxYddEzjbZsMtwMmY04JT5UCJUM2s5jEBNu59oei184GEwIC9B+zutwvdTLjO1Eqyh0BylC+uC+/NiQznQqucgF3xZM6QAPLnRUXuqica7i3Ot4ni3D6dyjXTYt4bHPza8UmlxX9QnKjZhKiySRu8iAa1lGinj0zdczgju1Q8Gv4a0LG5DwWvgm2RMe0UnPYRa5ZRCtah4+DsmftJ0c0HCjiEV3hc1hLgY2U8MJyEAB8sz/FT2/r6PCpUhgpiMNz0pN4r/8wtihTQ6NrEXtJVZL3fLCb7DxH2JQZsUjs96LQzZNyFnu3v+uInphx1+sopwg+Wlbp8m47L9UE9d8bwt93VKfk+yARWkVl6xGhCG2lmI1wnpNAfIZAnGEjILKL+Of1XyI/VeH4gdZBDu7EKVrNfs9nQbPEMQZnxujtn871e1iATKCJ+GCMSfVqIMiaNcMNVHjvP/3yffsF+UGyW40ZMC/YsqHmTm2xhau6a5qdxARpjRFqVKU1L22kSMlrl61N9Slzgx3zBGoSNsK8K2mVLixBYm5zwy/E4NBCirQVmYJmL2mAkZupSMlIJS3LsYRbsCZ6jLKHARlwA78x4V75jRiz/PWROBA5lIdAye0u3pJnTbTqzywpShZARqDQgm4wrLJlW+Hj+vxXUZkOrrb1VIoJXXoXbf4YeHhaXcv5hxRWwXpFVu+JJY4gmQqyWPNEAuLNpWZb453vOtiHsm6jSvI+fOKI+br0avf1/sPZKvaCj9ndy8+fvtmEsAaBiFjybS9eps1OIeghz1xjyZzfWmCOvXbmPCaZmYJO6+bcAoru0VLoeIUIhoquG2CtCf9Qrs/6VcP1l3pE1/glHJlbcXbrzcfg1lc1Db8g7qzuUonfmTmKIZxB6UJ7X3LL8TRiKr9rcGRCSjOdA0taMbsNvoJTDHgtX09eojRPDlzkuCBKQrPkz2LY+pt7j153rgOCs/cePcb0NgxPJHfDWgpH1ns3lxbi7F7HpVmy/jl6L6VXGW0n+PO/c/R3keqpXBDSGz+FTUiimSfdZfFgiWGBxSj6yx2r7HjAuMmOpDZMCsZX/XlasnAJ9kjuEdAxXfRbBAGFUiKqT1xihWIuXibTrmGYbM6r0qVIudxllYYK7cNrcY5G9rFDiq1u0BSEDtKiNDOtQ4/l2qStSox+SzVpL79O/zPM3sHjFe0RVTU1U+lhnr0Lmk460s5KWzE6xciqPT51PK9Su0mTweuYpfLCjk9Nf8NeuM2WW6sIzA76/ENj/MuVCBwWAhGDS7hse2JlvyJ2dzgVvHwCNcOgXmANScmypUqPhSIKiR9Ef5AStZrAggOg4pYyiVZDbWAMYryLPZGwEMPbeXbWHx8/N8Z2Ke89jp0vaWUdstIWv1EH3oVQgdOUzmEUvKOCMnq4d/s8yx2Qr0EzTgOiMAxGtTmLG1aDQvbI14L3/AsHQQ5moLaDa2p+GtXc0Zp7nS+qDmXEcUsHX2+IFAPJnyKVE27hhFKEQS2k2MzkDff25Y0jT0GJRMtEmYRbfJd8rbVV7Yqu+8uhJ04AEmGuJ21M5dJZkIPyBhw/gyF/Fmd+Cx0aYDGAKIKlO2ffYRXbLsd96ftxx0UOhvXGzk89sLrPoIR0zcLaKdWgWj7WxLbWO5TitQoMbBD7LyufWs712ZLtX9hmNrxkGGtGXEvxp+Z9n0COxwoA18ea14estvUs6BSmjrx3nsPa59WnVSy792AS3jy1uDHUOIIfRUcS3i'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'M7kggwfWmt1MBH1o+u3fGXvVG6OzGzNETQ5tgTwyLz2xBhqbu/rdCdbn/KixRIue01qM60AsvAiC9A6wQ1LSSy6YHd7x3bf1ivHNxi4mlClzU3h9r7EvS8imGz4cbvk4/Ti4817jISkJPOt30I/6+6n2omBmo0jTZd7Z3uIK3Uom+JPHP3wPEVVkq8iRGW5L4RSRhgLaA43sIdThMysOPjhOCHVZXfI4tItHCci4YB5OFqbjgY6ZpYfl7yER/gG0X3pW1rAqGppL5M/UWJ1uW2eBEjgq5KDQU6rhRCTSTgbJRnbDpwyuKiuOPwCoynaGLLh1nLFquUoC2DS3izfkU0x+WByNuzCRCY3TrDUJWL+ImMMmZn9MmGrvs07Y+AC5CMjp/8C3r8T4kBwPsiFPc2vpAEluXa+9bebw2uEmYP2zI7Ni1iiXeZ//RAHwu8O2moEyLc42YSMtd1KbGfOtWf641wpne9XMrLV/488dDIPsEnWJfTXUopPwud8QtVymaLxiXClc9vfFRnF1PKOnHI+AFVGoQMAmtHZA7icIveeyKoA13q69URBtRgcuNzl3BShNLScEAuQzW33NZr40b2bFIgNBTV/X/dQQGL8IJeKUzK0UmhpGLOYWuJvDh/7Ii1wgIhy42p8OBGlFfJUERPJNnh3lQ0jC7hVhhOcl6Lc3+fj51o1JnQz/////MJe6YT5bRtxvQ9Hx5yx0ilpYfCClGbP/zcKqjPg0mOl6Y1dxckH6jinF69Y2LIylMlRiR+JhP4/gd0y5ZRNLoxaB8W2uwMYk3d67xo6RHYgmdTxrpCQ8W5QGfiuohFuXeBcZ83h8Wo2mI5Vfuaqg6lhTk0oD+4E76gfNuw5cUS7pjlK4jsQ/g6kIIomEkY+k3nKGP7n/v1LGY1a+duQXEDVEcy2obNUTeeOWu9xW+fMuKRJy9KfrErvmJAK2Fiby56MfPOXjbzmki8wUjDf89gM8OMOShWSNrpKLuxCk2Cxij5o9XwVuHCfHzougB+mMVS21R4y7+QDnilM1X1Sfm7+mRvnXbSZDJxZSXVfPVNggNM89hvpDjH8VSyBcTyNhwsBdDaQmShIfRHWZcsaDGQ+T6fMcJ0VYZtuYq7gw9T5ySVXT4X1dbqPkJLRu1EgtdZOyppASr+/rSBiL56Xi2k9ys2zHAhziMP63fmkyzLMOhiBpFnuHkgMLzMEGwf6aQgPDiMgxe+xeNeEenSXuvIkzKqIjKLBYWRSVZ3hwf+tn10N7TjFKovueRsOkgONEk/hioW1fE3Wvf60yjbzL3bC5thRB4zghbvVJtMGGA2/bhnikcgDAVfbHlFdZbpxCi4omSGBtyTRnNEqh9FFJ1EaaYEBMFU7TE1pgAVWnpV6GyNMndVEncHAOsEunalrYB6qdSKxZgvlzvMqsiQJRKcI8AsxFu5lVj1q8KHFBSxVMAW+QHARuS0cvnbxJNqlJqjSQJxQkaW7EAhKqHmO1kOYcAnJNW2dS40CevKNEnk/E7IrcS5gkMhxN2kR4LBQ5LEn+s23G0NDurElZxHvz62bQcK39V0VBeYLNEwEBnjgbpdHGoMs1wjl9z5gRPioYPu11OapKWszGUMKYkAd/YQ+SpNe68GD5odfry/uCCvgF5G0qL6SLxkaoPM70SYeeqFGzaswvH+dTuQbXeKMx7fzVWYvS83huxfhP+uAGtr9qGJP20axtLFXfns72y1+SMKAb/OJK7PUQlM+ia5/LjaGoGM2HdFumA9BcKOQRouu9McXlZk5nOyYM2YacnzSNnHWOgzx6Th0y5zCHrvQ7zDqVC9sGCxkmDDX0JMTp8euTWiNoQGKZsUF8Ac9hPMV/fsiXXuK25pyyp5MLYdvqwG3P78ZN/1FRn40gzntvy8zXbLFiN0lW29h+A0BeakWtGS4dM198b3sK4FM82ZkOgf0HK4dvc9vqO8/2M/LHk36y53cb6nLYQSpZJ8oD/l2JBiRSqW9d1o8Zb20h9iUB'
$7zGminiexe &= 'G6HAYDqmu+Hf/N+rnc5AZ+8UKVEr5Hgdkvr3WiiGOMLETxs3fJ/fG4ExoIbCZfnuR0OxXJYHgO8csMF8J/VGyFeEroARoI5PJCwMstPmh1h2obPI6UG3igM7g5710a1+22rPlnymawT26BZk39BSRikvCO0Sb/JT1G100cF6mSleLE370A/YnGMNeec/ZqGq0a/1dCg/rTEkNSxgVO76PjN5LeCmCug5VmHfRGJb+V3ZqE/U0InpwyEQcYVqL0UVQuHmZ7jzubeJOdHpbxLb2ygcVXVznMWafM8yDMIVw7AJEU/79twuuurZt332xe28K7z1eOJhOQx0PA5tnkiNBKzbm0vxszxo+rq9TLCfR3XRCH7iyyXiBOcbvJBhXnODeOELlObvjzknA59YABF23mppu8Uxdsxy5qAfPbDL2CDTSpEXGxdNtXqkH2IP+nN2fU79zgpcaHm2T1mrvbQbGeSQWZ8DV0pMXaUGuBZlnAVJ5kY7I5j+ZtMOD7HN8BlkR7csKMfi8GuSL1CZQmojk42dcgOaqnSf3qVbYSNCHIQLMWlRedXHNGAjqYgBnyikbQvFijxFz8FHOkd02/p0v5T/C4jaQLFMCIBqYogDWdjVLTdG/p5Fz1aA8d1FbIbKQTvEIy3aI843nMUAHhq5dwpShGb5s2qUhPKPOjc1wJGYISGnSjiBDj8GZ/ycY/TH7hEeluWwd9dbCGRBbg2CQtwOVCZ73J0EsfKo6Cu6q/g5RXhBteRQRxxdCR0QMK74mpQX3Y4nPHUxtsiMEdYvsdT5B/GCHstYL3Gs42CMC6RzfCoRQWn7alvCIfbukGgNrlrRgc7VmQaleGd++sLO/T0lGcd/HfGtmcMyDsIjRhCIKNrJxLBeu6Y8Qg7zlYW3YvlQ0iRkSTKa5HLxKTfE6tBxi0o7g7kbAB7Xa9Efqm/BtXRhs1Yv7PuOY5v1Uz47C+kPr98giYmDAJ5Hr2HmEYtpa2atQjOZjC/ziIQoOASn9AWbHBOb5r199wdmfB0nb2vB64+LwaZ40pUfO/7OK1p1odncXtowH+u0EHsZd1VgXLyG/+TG1sa+DY2iM2XaPs9UaL4OB/nlq9wruvHm14p7BlCwm9P4CHX7LI+HqpqZXpwQxdxUMfl20TI15KQCkD7p6DDO2yeCxD5styxu5iX9MII57TiR241nRIDBeyrpZ369ABAc4MqlRbSdhiO95X3WEAx+KRW/6EWmUZxQYyTjKjsNRmNQCW3AZb8smvaAfbLMJIAsQIIs5u0uxncbn+FJauuUXLI+u+e0VJKFba/Qnnu9J2MUb/HIsPVOppd7x2nsY+PPVxJ6Zo3bZzaYI/0hbJ/FDhCua27gYPa2im6i11V7oeGWZw6MZk/yWdy/YZlE8FdjNkAM8gZQkTWbbFOLBtVZHO1b8S18EiH8DlCnd1ykxn7Wr+efJjG0PlKw8LTGvZz6xvaai5u1q10V2n8FqbUe1WcAvt8LAw/35ZyWtbo1jQr8TS3PcFgLEvpi4mh8nox+/05Uj/r47KUKYG8u+6J4EmFRcz7phgPIGdVJexbPnuPByBm9KtY1MuuB95Q74r1B+3w/YKgeINaXKGJ5aQApBLDzoOHBsh3EiElng2Z7D30C1KAa0inSrLUCDs8VF6/d40MsIHs3vuWTr8wnJ8IXc+r1n9V80tYa+nhRMOzLjUop42EFItCGp/g4dfjf6kPMhJ2JGyU9oSJI/85G4QgVglDO5AIrPIyrIbNi2CI/K8xPrbE5R2z4u/ynL7UDn/NMhVGUgxS2VMF5tOTh0FEsbIaOhZwzRyrZMtjMVGHNPyqGP1nZE+hKbgE0n2388GVc+H2dqQ8h7VEfENZM4hxhHsK0MPeSTfm+yocchgoSJ6iAtRSIVKyM14VWHfL6qTLYyjoQxXw8iUU1fhuqhO5tK6/wmO+VqWXGpS2buMvk0C88W7k4EmHn8U/lRsOPDW8f8FfwWG6sxlM+lVH00yvRG8VwGxFg'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'hsgUyKL2c76cUdURlUhYZBRZ6C67Isc8P2DRYl0BW7et1JE4ko6ktVljhMO+Wh6FJrpbc0wOLlrLh8SJBn+wPqE2rYPvrUoScraQapd2mnZSm48kD4DHcQjeq2ERY80l75VWBSUYuce4xmcTvf76NPHVYEpuxuAj2m+Aby0JVIaMJQ551xKedv0jOKgey/gtKWqk1blvamGqNc3Osp+aXg4sfuZMJIkVE7lKW65qkcPLU0ZIvlspgonnqcwzHFgddavNTxXmBKLHFoFpPPgvHZv/6CPO8iki1Osgo/hHjT5e7KOPr4bhTh9Nc224zkuLaqNzdBZikMVUzp+QMF6YPgNrgytuEVjaT4GyvgKtjQaqICokwzKKJ0GOsmlbjflbLZRLSJOJrjXKu03AIDFxhnMa0EA+vaP21ejJFhMngt4mQ60mOlhma3WJ9HOLYjzImn8/EXp+1OwKW6KbnhdB7dJmiC0/j18aaAL16QzSWwDVbtCXrxeFYWwxaefMOl0y4voO+769131vwWuB9WSdpal80IC/4/55pHk3eGexM42Zo+vhB/AC9p0/G5t3d1OaganOLNg/pEK9tz5QiekDlPvOAj8GIyshVPO20AxlTckpEmhAu5Hn3GzkrUnWxkCPuIfsa+zvCbUr6VzXyMkD/cY4+cVWBfsyUq4X9fnLs96/zYmpXxHEOM44nq1lXgeppLC4sNUetIebHaIvXvUCDX7K7NyN9/v2JSaIeCAHd6bB0JjLnW0wRr2IH5DpwOxMA0JAx/cHHA0jST5AMrEoahi4i9G1433FZgsPDY+LQpAX2FzP6gB2CFCDZdgRxMlFKs8PcZbYZZJ5vGjrklB/+6Z0RjGz+in5Jdh4CTpTD88GW+i5f0lIsRyavhN16OjNGdCaL+MJEQr9Wg6e31rZcyxUUgluSyWgJb94/KG5rCrsqWsRVMAkoDH/0J6NDd7UpZ1FUBelrNumjVJE49ZUlKD+ZTTaDboQPSgqluYlsJdGfjl/3XSVeEZhIe1dqwHm3sfzW+TrxfZSHO7uyllxEvbeMm7kidEU63QM+gE/8ATb4QfhprqDVFrrJ/+cDr+6RY+Dpv3MRBK7bzB/cV53akCIzoi8kSJHb4T2kRQ0UkQjaSifwy1PKhg6dE6wEJuQUXTY0o5l9x9c+Rd1ju/sRkA1W0sHDT0UPwSIYrpP3b0q+SDAETLBuTNfYy06U524XiNeh7j98D8flQm10paBaSFKSvFVSnn7Btp4bAHZC60h9wsN4lmgd+2e/cMFPZwUseGpk46ml2+0MQXPZdWvfxecBVQFDA9iNezndD63LAkZh4+ZEvdkfJNoaZtFfl2X1A+k7ZutKgetgZzz904DHdKm+xnl99fLdTT9wY/UNdPtQ57e7gLnwjkmjMZ+haXuo+M19aJGZs95JVbnMZbxnQo+hTeZdNSeMPdgZ9LDoeRt0IvpKnnQ2cNSnvp9Fk0f2aLJmFNCBvpUudvzqW3uZGpRlNaqUZ3+xsa+/jnFtkzuoL9tUDfEFm305BKlXeQFfV9umTsEBV16H/OJ10thG403r8BSQNNIcn3SWSK3a7RUBO4LQ4r38wHL8GjWL2lscsMLoEgzaO/V1lfecfA4mSxR8E/SgyEvo2BdKYf5raBk3FlC+dFaMh2EeFZwWpxyb5I59AzfyvCxef2bMaOCBPeCbOmgOV3WbKo2L0CeaOSzsSfXHerRZ0tRp4KgcvaJIKqteYDO6fTQjMGQdOexoTL7yQsAwXPzu3YA7ow9KE98JXeTOlFETZU2B9+TayqW1y6ThRVCK2nSWNNK3rqxD04t8uqkGlGvBp7gNXkNeUG33d8eYP5iMw4ItuXwiprisLWfDDLomaDVEDUjyo5MM9rRX4eboWqp0PZc9WTNI+wyZEbPlNiGua0XSpkIdoj+81PysPqUVVUIkwSEnfqmidVYajb50kqwtvcAV5TI8JXARJyA1OBRkDLNot+dlaRYPniD6ViC5cb5GH8m'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'zgBqJEK0PcyrzkvVMD2R9EM92HQ4Vf+OUClAuVnvBt1X8mIcDjQY/n2FZ0rTYuANxjD4SANy6Pt8CYQVprFNQPczhkx18/urQkkc0UTIJ+vQv6wpNsmWJ92iNheVX0QdgENkWaTDVFev2+Y0OvCk6I1KZ84bvASMxPEwX1avbpA55op93gd9YJGU+sCswqME7tD/TmV/t8+ibQRpIvCeqHAR3zCHrh8DO+mpjEZKWQSl5CkZFkFhztpVU/GXydKxBlsk4+E9dGbIvNhfvVn5H2tHgvaEsDMXu8QJhPV/hG/3LME2nGGzcjVcuyTtVd9MNBPhr0iQNvluUnH6CkN2V2TmLdJ3w1Tvbax/ShlDlQkzbW2Ey4uO2ArnDSsORpSRJ+cq8ShoUMTU4ubFtviBdpQF+r+4SLgHsy02wiZuxSH4n2vRGuZ34RYK6J1B2PP9fUcVYY1n+A+TUN6ordsLJsQroUby60toxIdF8zCP8Cu68Qrmqe7peibDsPvai/3gH1tGNGyG4coR72blClxt8UxRHPzNWaDjCUxOCQvlvsQuYHVO8xpNGWaJAR/0ImAUijUnAMSXvamaJvLzNmQ6iPmwMkY8YNxnyqOmI4GHvsuQ5BeM9Dyscxjt0+8ztu1ZvTVmvw5r1Vrv3KF8b307/Dfnc10hYwWfXumX88zGoy1UwXgu4yWmWgOUfJVf1CXykA19QnymUaUK9S+bMhFzMXPvfyfA909ZNGYrZlh5oNQC0yMeWLHJfUuLVuGKqccXeZPloU/L2oHMT1QJenCT2fEzqbF69cBC5bBiRQEKisqJjrqPk3qfXCTC95ZsfbT9Km5awu31v+pAL/UCkkUtpHdJ6nktYx4cYs/vj7yHw5mkv9u7Ojds5s74Znxu2iHLnhUAo1KP12WpiEnheKQAPLmlAj37rB4yRq1aSuq/IeR1HWalEllbH1mvehQPoS+WVD2rN9mwMtRfo4eX7dE+TjuHlEfedH0aHhrjehiW9x0MlTG9uLFe4xcVgvqQtvh3jQN8r8rkTN8LXOT5EauX0GEm0D+TAR1EKN9OIM1zVO7i8WeMS1dK+hGyLb6Y5PEZQYrPpbegAafAVLAu2SbyFVI0PcjzmG/TAjyy4PBIBFKwQwib8SJJZXAD6nHkF0G6+mc37o23HTTmLGvTDNhCQy/re0EbWHt6+F6PKa2jSJELaGF4QSvyak6dmkjFRJpkeJK651g9qp4yj+EdJf0FOAsy9PjzBeU80XERdCL0iQ2zS4I2CxtXEEoMw9xNKYIWPOeIHH52plDsW5WW7H1yVC5h8ZCwql5VESrEsWM2pNKeevmh5zAG4n9kD8JOHUvVv0Qj1a5Tdm1zpcw4flMonTSDllIDBVofsNDClZzMpsDOI+D0K0fYG2U9odJuZLMowwEGeRrJbBBcwS69YiHtyuOz5ufU/u+K+QFzg33D07H5dxaf6wC6iJmV1jCuX+YigSnSTgtaALCa418zcbDt0yhYgNoHMBSKpAVSc+Ks+3RFb8gMnEhsrzEcTM/FFwML93Nh0go8uJWAtXe/Sn7Z3psx1MC/kV63uoxASr67DAKxhBOzueFfzTwCKwkT2bcO9nXLJDt5eiUJeoNzDx3H0DEDfdJV/2ipAnZyEQtRyN1k9VGMXwDoGpNajoVM0/LZVb4sEd+Aw6obA0+Ti2QbrY72CBcA4k8v/CJ3z0XM0nJ+u5jr9YwRwVwDge7MYmsx1Ff2A+Czow7FvEubjx0J4AB8BdXRoHvzEmDysBk/HEnNR7sSi/lpyHuE3NB6BxQvKMLFRS7BTdb59khNCsDYxkxz49f6WMs1anocz3o6VWWExuLON6fc15Njdi7WhS4JGVC2yvo3soIv2fcfSGTumHAt+M8S/BEH5SPCII9NOi1kJtVaLqkhr593NNE3FOG+I5fenIqeKg5+PBgLKcjUq+r3MT6xzpIsw/BipztoQ9L1VchzPrqXVeuICLVrAILPtL4a+Oibd4E8I0IZ'
$7zGminiexe &= 'NoB/5GuSNHGTIiFezY43AyxeZOULx1ij4oVnL06FLxp9ieKm7vxWcgopptPAHJYxJCBk8E+CruDNhsPk/VSg9NzogSVI1BF0+8f97ZNRgWYhGlwo228Lpt/gAwZ1rZv3m2hm+GYSDRtwuDjgpU3pt0mErT2vFcRTJLKl3If6zVFD7NdltDIAbA5hT8bJz71eGLUtkWaA+Ncd2Bb/5MD8c/s0pDx6xZjE8KIMRg877mmZcKB8PJwtxCUBvWFfOdb8juVtCG1qYtRMOIpSoy0RszoSYPvCylkzicEzpwUrGXDBS6WQIHsKVNpekBgQkFtdu4HqTCvMoSUU67pSb2RwCvqXuUoyIEC8GC7oIwE4QAGtFnWgJXBnDJhUZ/bVX3AZFwGNPHzZ67PTMV2yOG6FRPwEhaWkR3/9jQGngFvZzZOTTEINuv66iDVNrKmlIQ5W8IPieq2J4GphVkiu7t1PDnPewyEi+VdgvUvU5rYJToE9RWevvaUxD92La3hAuI0quQpuj9RL8mwlOt3a5Hc1BhQVrgH4yO6kauXQR+BFXRGZTK5V/ibj7CBJfeBnGn0sLLkfUOV9cF4giN+B+0xX7JAkmeOCYEukNcx+gyKehMH8q7hs++h6IVdjS7CZR5BLXHX1vvfutSCtQPx4gP6mHkmNjPE3LSXBgciH8T+0kk0Tp03x8QumYOV1JO+OrTkLkD1rtQLkrwbZrBs5GdAwrtudGC7z7k5aUJYZ9Ih9IvX8KhiQKUUqbimn11T85UlVw/hbghDtzwnaTMXI7/CTldZf3JuqXsmRIj2cwyn5EVYkjeqyfy9LCZjubxgEA+P/FwDvByh9KXpxkpW2PZA4r2Q1ms3lnIx4ncKsHzZ1U8cbSIyw7UaiUifSs8dmxN0WOai0rY5f7PB8g783zynQEFhIxW8GxJGYgzK135EbQU+aT75LkWXbp8YnQCV0XYfRIecdKwk6eo2FkouucvrGEm1ueybPrulyxcoIMdRQYWGIl+rQTGOr7rsJraqGRYKuvVoAIAknwMbdVH4Lloz+NaUSauk1hCMRyJ889Li+UvnlT5cCj89co27TnXCF5aAyDw25U+xKu3lJ+DWVyFIjrg493itoaOzHRc564DRXTX3cC5lsyYGMaxqyKw56bxlUXyxoIJuWOEBLTt/tlQ+qi4Os4nZUsx/ApheO15wMmQmQkNfN0Ks68luHGdPFkbUtqBoDUF2VWmzJplLXKcTOnMi1AzKOnlFEU96Mr7uw6BWSH9NFlRqUgffoeEAsHi9fY+9opoP72f1XIR9pHGTPJBocG13nTlBNiLyep1j2FbSQF0nOW4xoS+PdfYkHl82lUwCpGFK30IUBzemVuZv2nfpvQSkGYJnY9oKgAaz5p0ReNzOFa+p5OgZywUoCqBz121Dnc8BNf2GXq+z2ciaYy6l1TSH2TAkDtyf7PXxTIGMLm75E/lVG+dD+ug+Uk3T1NZusvCSopFM0jeIn95EpHT/f4L+SiCpBEHJ47NzRgSW7Sq+EungTB5qulyQTdQWdof4aU8MRiAnQP6WrJEfFYjD0ZSVdYdJQZB6asDmFo5WtkBQz17pswceCk3cio5S4vK9qZOGf8pdwPAhZakD7WNYD06lK1vcxvQmccTGIBz9jQHlMghfqdz5h+vvInJ8et3tCzHhCmaAEeMqX0uFWiVNrcpGTuK3QIC0IxtCPn2yEHpbaldLBwhbwi16ERvR/BzYIgwj/////8lTKV2qQcRDDpjhR+Q4MF8PyUGysbixVNTCthn3AKxJKb9j6uSa8qLlA5f+K6Fdu7vBO7UkIljbjruduxW4n5Ite+qgERX1aKV1TBsKW6l5CtN3HO4Ka/32xkULtbju92AvzevU1dinZPL8e3wDi8lA0jbamwXymAChqoUBWji81Dm/NMpF9u5rSAjAg3bBuvn4CYaOlNDp/TndpLiKGq0tFb7Y3W+zGXv5hYdGcenQ1EtQ1AngNkeEDCYdhtxAZPn3W'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'y/bR151W/dJmSqhxrMBFuWof0G8kEJjqkJjHW7N5XDTBrLOuNe3n8iatSYfBJfDxoxGCIPruPSzY/+Oob5plri5cJZByw0YZEj/V3QDAONh+/gOh8XgVP1CFHnARgg9hfydbT26UcB9tROCftalFsbhiRtCJK2lAvcRXVsidB3RWJMUcJRTnyVCeRH6wNDeBZNhJcZ2piSp8M1LVCKJ7g57UacRy8RSXsejkQcNDZO2FAMX2g9dwBjEfuIf7+X3MmjmkMIs/oDItc2ni3h2HvID1eGfGHC4upGJvfLb+u0fe4JC+wCukJKjkgBnFS0KgStqht5eVt9sinCmyiH/zrY4+ZQs8rhSa+GX3IyQ4bCY65SfGJjcoPmcBijn8WeMv/T0bHL7TECLfmsjEZ9U8rOocATK9HjcSFsMDMHZ1q/dFEql1hKwiXGHEKD7BQQhBLFQwUMKdnA6azoU783xzuZSOCP////+gidQ/CdcQfa6Hj+OP2T2DxHsWxAySYdf1x+M1KEEi4pqjPZAGs/A2GH5Kzwou719SJ/GDqm//TOhYJ8znLaNc9xHGlT4xCnTwF7tVSqotAXGlwSJZKVFrqT+xUnvRDthXZ5S7CEvSm9poJIlOYHoapJL1p7xQUDy6zif1K0kwq/agCQqIjFZT2kx1Qf04Zy3z4poM/XKrssqqzlhK0G15sh83dQ7Hrbq+z2UUHClIwIzAZ9a48O+OpN5Ri5IzhZ8yLXYvnLkv1USoBYYAVFwfqcsIf68TPzXs+uUaXjN/ekuftkoOR7r+JD1aFub811pll8itROAAxsVyNHNYeWS1c6UXb+lRbRLhjiU7T55MXhKdMZFuuG1OhZt0R7WH2Z9iLJ+lPHNgZ7dyUafib42d9xvXqu+T/YvYRJryymFTdGOimztMrwyTHxmsycy+3+NgnMUdbX9LR+YzNOSEY1TusebDJb1ejMd5eRVgKE5cqoNwUlOZ8MZu0stRoubwPMM9P/xmARtTjAf6kkrsIeXEHeUFTUWrexjraBNY9XscH7yTbJeTh025513CTJploxvaUW8T2KMfVhStuUvLGbllHNse0JjaDRSGODM2iFepSXN6J/Jsi6sM2NE+xmVRg9yd9G7WuOhAS74id/Twpa5zkih6NSKtcKdj6FCUzaXGT6KJQFGM4+Vv/ZJYni0kcuvtcSlPLBrjiBOesehTU+z74KzXt0X3Ycn2LpD2WIGzgoKonhmOS4yKsQ24qnyAA7RprJ3Hsh6IpUm+FJRdir9n1PkdZi7gcYi1/hoRwr3qujEOUEgrA8xPe/vn01zLtM85tqd4hk+WZTN/6qrhKGOD4qna7zVEHptFjmEP7U52jOBQj0CdCwzGAFjrGJv9Ub0Tf3Kj/DoGoxgDy17HAqV80TQDT/NyjBDhXrt2SWnA4GFgWrgneK3shml8x0vyetfQM7zmuoeJVyL8TDH17BCO05txOq288CyxMOQyjx9WYa8i9gdsldrq/Ja/lHJ5+gUWR4FTATPIA4leDFU4+hwUwxe4vdvZMfUzbW5BUbCMtosJspjwZTQl6LEQ7ojwVGwEhqW6yLmaLodOhcd/LSyPyHEsiaA5EubpUD7TAGkI2Omu1xocN/EnovV76yLFltGYr8mx1rtgD2JegKdkoULRr5PXyuXN5BxHNC/HA56FOxvhBaF8Q+pjieLBb2ibZ6gaPLeqifYUi3NL6+/LowgdTsZ5betIDHus0fasmhL792jBrxe5wAneksgOHTwmXp9PFRRbjYhvG9KlH2DDEU0E8hmn+F2MfyP5j8SlOm9IeQ8ImUabmozaljtea5tLQm7ra/bq+W2cI+R9ZJOzXRh4uA2C6jQUkrUwW5uGyiDMDJAgkDfXzLDGbUmykg1hZljalht5krYOfmEBct3sPHlZpbMGzeluP+563MPd+fbMf6zSq35O5StLgvudqnZjWl6oQleXSv3a6r7bZaELKq/mOubBe/k2eZNZZpH1ESHoD50cf4G+'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'KzXGZGh25CaFPLtKajYhY3GokLkTUkjOC87l7roAHQ0F/aCaAEsfmg02wvXC1DUQYxxZUfqZMGH4eemVrKyejSLSEooMm9DM65WzaqFsXarhFGqkZLHzfP/YRKHARM5gd/03/XCdHK0vIcmLXGdBFE7+goUnKwnN1dXyDmZ3tchKRf6fXmQiKpscnQq83mMmvNGEmSxBeTx7I2+VjLRocJEe78Tae0E4X36qPLGJxmi4DtSFUHGQUIgerOsvLfXLdpXQe1iFJ3oQdWHHs1zEC7wKuhyFkMPnn2Bgx2nbz6I5Lml+0Gbn6Znlim3jbMTYLpeNGGzogONT+Kc6sAS3qEMPrNojcrkFLc+Ek6rOPO/5olz60BcHmTbOWphJ7UV4cvUSk54htuzGyPJu4BGcYbnMZCjTwTCVGIuD8ki6oWXOo/2AxilKUfsXSocM12oWfC2YvoURuIWTLY9anhcGpiKh6vmvJ8Sd2idDSN57vlkjVUdSu6oDUgSsfP1DWOG9jNXCOtBDvC55tRHbU3O85KX77S580gfP3cnfFnbBlgULb6VIgEKUwa7R4xriJPjIfqcZiZTov7TrE9MaSNWuzvYxZbmvm7ummqLj2E4jWIXPTM9n77RLQE4o3GGZqwJIAcAgz7WMWGtggpC6Tr0bO3vWBYuqHoxrQyQ8r2TKX0Cweh3uhQaI+i39viBhmLL8lI1+B7izN1SMy0RUJrk8At4TQNj99vvbqEXQ7+pGVBeXqbUo1+cX4YY3uBANjXQouOz2jvslpbvktGkr0ZNUEaDq4xwKdxhsLfj60JKskRxtRZZKSHKx+JbEeiHcokx6pBMEuZ7W6KDVWRBnIcQzu2CUmfxHzseQk0QQ9nO7YonodYuKptJ8qs1wM8QytpB67Kn5e6uGXN8UYRlPQJLg87ROS5LuzD8+uqsnxJ+FxXaVxb9Fdt6w/rJsk8VgE54WXtV1Ym1xO/6tIMUrdDbS9meGl0I5zONkyWIrXxc1SzjaZkfjLAuE/Pk4L2S3Zf7D4nk+bNhXriadZgcBNyM01LY9RILAIHeILFN/fAS979GBZ8E3YH8l7B5DmHmTxTAbSUeGKlygRtA/IAaRns9qwj7rCUXr9mHPmUl1WrU/pQqqDSBjgrLbSF7ChCiyPFDVrWVVWucOPB54l5N9vuMjlB4NaCjfVbtzPuVzg7Bq7N/QotJ/XOpiI6h/LNN4kcHufaQzaJwOPre4tQIVC+Z/vXsQwn+CpVB8leAH+QHjoo+mwWhI+ReiaM2sWF8bwkPrc2EOTudencu91J23b3d52pND8Y9NFUAszh0nHyiKV9v2SVcgRoMfgY/aAuvNgHrgtZ/sESD8f6qNfdqUGRCxhQYOdWISAtlD1JZNep4eP1LoGlt5NWkMXCEyOMwI/////y1uMa3/JWmrr0mu2uEOolz6PNsTE0PU3r8ZqTlQYSL1V2XIE9NXjXmvAV/Rxbh4R28HBwCUVHyJg5g9ZebSXMmkdX6ldG8D9sFvqUoHGGxI489EdMHJ+694r57XIK4Q1fTbuGCFKanFeJF9ywq5JWnqkILdOULT16X2yoKZJfpWPIkHEo4mMfNE+eAMf07IjTwP0FR/OaAnaHaKsnkqan6Pop36xY0C8AWYFFz7jdYMrg4zozRipyzGA6McRSsaBxy+vxWu0pEj2gxELSbgPInAlKntsFKkivCkl9BkOQM7o/4iHYq7iUVFU+mogO49pDktg+m8O1OFtbN9aiw+7xQUa3rFuBoRJVqP/Z3Ua+M9pZLzAv+97I9POWwlI7PAM3bMlkovrZVE+EQnT2WdaM3Att/DGuIIUu+hJB4G1904ISscO/V3qsbZI2fifQiiNQlvb36fo4cGV7LoCoskhftw1gF86PFIdgXjUBEIy0mgODDqSnEhQTRa3FXZRf1RMCfFqDGX41kd1U4h9Y/hYzOnh3kIj3WhCR5L2J5Yurs7/nNtw7XYrqAOpy4KluyeEQDm+QT9L7DSK8Ie'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '5n21n66PGJJYKbgdsemCADJ+sGEK+egwLBmr+hs0n16X8LvODYvkDwTHLFAI93x95PSeWvDoDtq5yWlnB0+NyxDm2u1gIOAC0AKodVHiUPK+y1Mhs6Z8nhWBKpygr1Ns32s+kAv6RBI75OJgePPQTBMHxdDXNWwKh65Ncuzn6BQyD2zaRC8pHQFSKfNGOxxiQ5TCiZSzuQw4m5WBj8SCrsm+hO7aO4YBJ2msIorQCMxmGHKvvQy1mJySUKS5sTUt+eTcGx5uDGSFssB02ryODqMFcwnJyycodG9GC45MEidjXQ+lXb2HF077k4N55wI1GsjFQaGf1R4SRTn3xH3eZgoZ4xFFNB7LZZGwbs/Ri7rQd8Jydbv5R/KU4X3j8nJ6h6DdFI56McrVF0MGSv+nHefd4nbFd8LXo7g+A38sB4JccfA5bfFeY4K0jKvFHNRKXv+rxdfcq5ouCDtoKUlsyY0H9UZBIQ851DpO5f7DbosIR/D7ceqoF1sWvqxtnGeq3dkoxbKsJUWvFJ5u/QIDIa0pc6JST86FQ3jOwbW4ncWY/lqKkmJAqhT6MhStXef8hJTKdxAwgWoDOWdnxRy5xBoQq7XI2yoSTrCf1dMvDbH/4ar8VajaWs1anG+cV+Z9zV9mG4SMT0ZZlzeNXG33pJ5DXwk55vVYWTye2FRoLy0CMm3zyYS7FpU2p6yoi8FFCIqjAUl1ytCJ4zIkQtGx5E2RFxdKa/7VLNWOh+r6uH8XEZKTTCG3ASuZgo4Y14loGVCt5AUOhxYmgHGo8ocAxPBSOlIc4RliygJXLQYzcNZA3ck1xhyCmt43D9XclojZe4WUbP3JKlDXVW9JFNjUuWB17spGuhliL6+urA3ZLHUmGsoaPSNatTtEWFfW7Cs9o+11z+XtAnt3mKuPmpgIS/0yY6gk9nEQ93+FZdhhoTKeP1S4UjCzJBVDIMmbhjVrA7BQ3/rjp7R1Qc7iytu+Wgd1RjOdoIr2phEA3TRvzI1fY0gAA32b8wWvTCYrnXRy2Z2RTQ5U8DuAKCJn7VjBsGrGU7xkPERzIDr6NKYNIZN1g5tisN0HYIikPpRiORpvAbBooh/14zkF5HXogrIMyG6sk5qIYEAoZ+8nv+moeYOKDDt71aMdIc6H/JqG449J8oUcV5guyZe+oH7e/Hy13IboW/el4/cBPeuTB6twlT3FDiD/P4Y2xJJhFIF0eBrh0/osk4P9J8XnxbdpEu1DFvtxLuULd3yF94XAAHNbXiunxX3iMhp15+bayoLj/xEeHFd3ycUzQ4RAHPhMtFf4qb6P3tN9XvtY8mpAWHTEjLGEFB/OJ+9p27+rW/DdjIMkKE7hQ1K+Qmc8qbAceNrJLc5Qrio5awedmClycXew+LOnGmNXGWy0AH4tVsAW/MrROCrhWBfWNclleDPMGHFmfjbOT1WPN5oIq2Oyc2BaGVgfkGkbL4qaoF3crTeKwginDWyAZR9Fe2g28ZphHSVgbVXIUxfabMtknFKvxy9MZWPvbBYMg8JypcViXmSl9+d6yFFTjUPcuGkUb6D+pidOc0q3aqXE7M34xwgGJLPtDCzcnZjAgXcL1DQmY1UoOUyY4REoDh351UvtN8iwXy1Z7N40jfWnlTY7ip37bDL98/fgHGXWeYp6f1VNrKpIcoHlw/Mv1qzS0HyyS+7nX7JwPNoi6FQR5Wt54F2Nxn16fM30WDTgRgzImXeReELw2KWXbZTa17oHorkBQgCMpIV5/f3xbQboS08gSrmk6sGD+ljzk5DTDU9iOYDWh1JY3CEomgybg25YkThBihLKGrKdMxV+9XWCUTxTfzl/+w4JIk3N9ijYgnVksLWfZ4wlPb9XxZmxBT9HRj3Nzc2UGyFdYTlElLQk7IwV5zH/dLujqlHv295KmcjahXUtL8bABQMxrJzIvRegFVAinYXXPwwjhZaC96w8VmRiobkFCi3OqW31qQANgvrzCzq5hw1SQK/hDtd6mF0MNAC7PRlQ'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'ye5WGvoBBCzg3THLzRpE2zwuyTax/oanpTkA8Xqh62a3GJSmDWJ3j9vRa+O0uLUHYtS1rYMqxFqwrMg44xfe/sI1bF6NH1akgGajMNT/1y5XTtkmuqTFiwvLIPErhJi7gBGj4DPazSH0u8AlrYBcEanF+HvWnFnS/jChZEg+Fd+nS+1pyawRIJfDITdASP6Xmb2w0QuSqDT94c7gaFHTaptOUHHmKl7pWv1Z4rfsGLBYhIPhWjfGm8D8U32xOMLIN3CJu3/JZOCwv9SQlvo6UKYc4cO5Q9wRTRP0W7KDqBni+wblzCI8TUZfVyyawZ6XljBP332ChxKoXsq6tHFFRYCA+172SkreG08dP9qHf7QhUaixaVL5rcdjgWx8iZQbu9Hs3mjTVFD/Ny48lXpmzkNwjwXan8SH/undrGTag5+FzM2Rgy4JIeWPnlfTHr4GFBIEabiVONwnPrRh8ifRWxu7vQAHTYFAKxGrHp7+U813BmHx7HGvpTsuw1wbOxerIVwH4utcHjPzLYQTRy1RNYEOlwqvB5n1sAVUTWGAnSNhoTC8jjfCCcK3QwhIKptUm3NLZ55URN48F0HQNt8WXJpu1AkqLOUxsIgSTSLQitb0AswNBi60aoCaZEiUrQgdOhQiTY1BsJp52x9mrm6gdwEQVw7Dqu/44N+WJzspgsZKiGNSdA1gPT2LsHlW+h/mvz3/flYNc7+bI7ixv+nhmQcceCOFvu4/KI2mwBiReB8uwxk5Rhli898lafbvrJivSizTPvyo3tKm2MqEysK4ecdLidlin7GbhA4h+vFZDCcvPtvx5R9ckqUHf+0ysQz/////na81OwshozRjCoHvWT3lMWCRx2slmpUk+Fwep4g8NItELAOHb9sSNdjDeXSmzrIK+s2ckUyeaEQdXgNNFy35C85KzAnlNki7sYYD8lVOir+wHI5xkEwT2vxgUohYqp7AoqGpIvIvSXtYgoS5mUVGfXX29ViFZUtmZDmQ+xXKIUL/cUhi3r311JLpEHSs3bCEpNvqbpic0CJb/dd2Bf/+HZEqftL1FK4/XjxczzYg/J6/FbyD8eU/oYaq8V0irvkGBKro+SyfFOxk4/6aZRaoFlTno4fe1haEIXwnFF7iG66a986wARhvQ7EyWC6AuQj6VHBEhtK8zAxu9zkkkxxPGyH54vFDQaPb3NAFr9uY19OzqqSiejxFbuKxvW1TRjoYqKM2j573a8IpF3n3EQECEC1xKWg3d+5Z811vcEhlM7n0ihN02XRaO0JYj1nl4NtKIhIt8Q3er54r1Z33h+/FmwNR18lcOc9F1pkDU9Fi7mMBPghztMSv+cMbQNeUeGupBukRjKY5vuMZii5WGyz13IpGh2fFoxvXWxiaVLbwxm4LQ0CRTZVu1LZz1raTkuhcSpk2br67KZUyJqwcIkbD2nwTd59Q0nd+URxHDIK6obui6sygLiCsx9P8x3T56tchb/xWJeKUuw0xUbkI3ptGmaWorwmirU+W8PSb2WBUB/HFmKXNUoyWcWETBsNKvLlof0hSRSjN0/N8363+/hOV0O91RhjarRI8NihELME9MC7wqr/17uclVijwSNFH2cf8g5fmG49z4a0TgQncnegQGp6tvQDnfX0tyaTWbDniDzER4cahtjLg202/vXGvN8BquUmfHHWJySg9pZTd7euYQGPMOTJjbVGj6n7ASSZY4MSTdzH9vhhsZ6LCc8drUNF7f+9cmAjKfNLRpxklFj1+niHzcU6jkGE9jfZiTjv+uiElo82opZTPN6pTsoXbI8um+XBW5XZGZdPXiRlCJWFaIBnAQzokUR6EulReokezr4JzzS06CcO533hCswvq143e0sLI4F9uIOjdLYsDxKn+GpRReBOYeUUJe3WhLOAd23rZjBB4ipWHO7zcTj0SUQhQRf5uCp+NmdSyO461JUvERywCFvwU2HEJozf0NvI+RASagIV/eYRKn2a1w9P0hijg88oNxtRumnCw'
$7zGminiexe &= 'OPLE77u10CAoR0L95/50hV2rnCVor3BtIoy7TwngXCbNOPAr6S8af1UH8kcQTD6h4hBOmlrrbLtMHz19dL/XF10FSfR2+7LmlT9jke5FSjeGQdULgEmCgkX7mWiGSag174LNq7LmZR0d0HyKeuXZUPDJiGpO8EUZ+93WTDKg7ZXCSD0Prb+yNvRAy1Cv7SmvPDKu8F6np5Hvj3TGWkv1PYQWZ+b1hoSzeuOFD8wmoIPgMgZF6vW5IkhRs/fYvC8wIy2U0owbaXXlhj9ei6lvm6eVOOcOqh32v8WKoJwPjXXv1Fkd2HkDWxblXaEgwdmycqse+cvP/Otz0LnPMIy8w80ncgqUx9xSCCmLUvJyNqT8RILwKCod4iofhrGamXypWrknmjxVyF1TcDLxoicwLmbxNXF9ruH4nToz9kwBALY6L4md9+YOey9ag2Vs/AlYdt4D8hNO+w/J9SSB/SpAk5DDk6YTlHk1OOoes+RwRrebwE5quQ7FQuc6ngA/g1j9FQwi+ps0q5D/ruQI8FoCmJ54kiuY920zFrnkgCBj3sW+if+SBBOl31HKUHSqoTv9MwqrIsL9HDRbJR5IKy4k10moHvR2xZlqMjGgf1iofDawG7GzawwedUVh0bv85GjFu1qdVEXqU8sDesp/RR5//8hBQHQLO68zaHoNfdM89piLoqasLSYRwu4N/jZWIyrKD6HuED4DxAmLr7jZZQg4fdhY/JHeyLdLx8X7PPGbMKwOgWUVBi977pEOcZVwrqWCiJYxvN2QbdDCtLu79dD6qQ7t7ygfyESqRn2a07ZYar3jmdCPOdyq10r5AsSceOybzMgjQnQ18LC9NP9XhDbquzSjeXANp7LRE4FRn2DiI3AwP6Xi47pkdO3kXchw6J+tkrSPonEbRLyrqyUbNhCIbMWI2bijhx5tnwccOj5iLkixZk44Ui7mu7lwW7S2wfEfQEXgOZ1VStkbPetA5ONPcXDDcx68vlmwPGklYwizN783oyH1+CFuXswvJJRcCshuIMHfCeTS2NSSWCGw3v1wyHWTpkHZrnmzhWD83LaAiivyguqF7d7uYPs6czlJBY7qvgr7HRhKmcgG5K5Dkp12Lzkc5E2l3GBlSlhBknSUBDJ0nmvYwGMwpnScvQn2Du33qPClvTqZF92WRGBqCYlHQjVBvQtvPe7iZVurKaJR113ZJG/z3I0sSB3J4wDDkoJQTjOhnUqiA2emgQ6kl0lxxktS3bjlROmr7/KykPIr8nGO8tviNkpE8OKlqVPCHDwLMgdmCumpsvsiQF5ma09oWIyelqfYHM4xlyQbmEBVGpKjZ9srtW3bx2oag2NvPUZ/lI+LYkwNpDiKBpD+fZff3Dt+XYQyPSRs9QCnHQDFksnFSeShvWkyDYhZc8aUDnpU3wD34guvjAlVYbXT8D9CnvKa2JJjPILjTUqyUWYNcJMiwc/KXdEqLeT/JtEpbLJjkZajgZ+ehWwhE/zpsvJs/V4QvA3vxBX4kqF1YqEHw03JAqwZhy6xwH4La/Yj+PwlE6ggWdIzPPT3EdvXWKBGL4ycVLmnC3BvpXtB9hoI8m6N7yX3I5GkWNZZ0sEUoX8sLvbJ7WXMlFxBC8mvETecIzjlBfD4CC876eingvsQrri4pN6yEBXik4Kt1JNoQ8WDbeW+om77raZpO5SdbZKnOEM6AS7TF2FZW18w6wvcCoS7Y7XK0sxVjhRyal8BW/tuOAeRauggx6M3wZgxtenZYIqsbv4F0sSfazSegB0AtHC4qB3yA/ryfREUSWSwMP7AngZo9PJs9ZuO3sl3PaoGSoaAt+2zBP37vky2VuF4nPhxSTL0MW7aKdx6A2qUBOOhTIOU+GHvQQx5HxnRN/N9tSMLYN9PKUpq6NcqfaVd07w3tj7vEoPsMQDr9z8Py17QHUysdH6VQkL+rb01Wj+Wl1Pjp0aN9YMnWhEv7T19qNafGx2bioh+MbqAbiMoxdexGpflzn46o/9ljfqA'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'cx9P3Eg761XhL43cD3sSTUO2YAXYaT0EN5gwGAEHB4dJSyTVQz8JrQbqH2Oi9rBwuZP1I2CRtAIHALKakaxciHvsLgI9lKDazelpQv4oJvg9/YZq0BxefYP9tcfUxVDoZrfalWDhSpSWwpmJOGaqcORsHx3YSkcWCse6K7W0QjIl0ClvLpnKTXjifvm1spANalcZOBSvXuk2k+XATEtH/UEebYRNVpXtTNhI21lt4XRMlUeut3gBwRpljljxHH2gZwHOFHY4r/bi1bvdvmyPcaueM7nRikXQuKnT5jKP58yW0Nn85puOzIRnXgw8ld3NSmfquR1Wetx65b2itEXKNm0rQPLCurvXa3DYlZ5lU88LhKq4be17yZbbqfroHIx2sWFN4SWH2glGsCgZZpvdaQJKdBIGWAN9V9Hb2zt5RFt1/zEQhAE4Xm5axQAH0ibUBx2IoKE9dRq76g6Fc8p2zVahP768Erone1iV8vfNz0Ri9E6BFTSG58fp1/ysPn0X7Nid7n+/+u0nbP3dcxltPiOlOdn04a13mz46K/Y6DW1gIannrPrALfJIDk/iNjU7M6v4WAQxSJ7JInKAwoMesEvU18LGLlzIUnzintJMPR1OmyW5vBqa0/iOh9oPZSp4PIsl4zROVk0nsuvq+6FmH8msN7cnlpEN/H9xDjmoC0CX7LcR6UXpkgiyCxpu4UFTiIGeG2jOmQAVDinE2nz0Z7y3q9Oov2h5Nr/DHV8bY8hruj2IkhPccdXmhZEM/////+jN1PXYToslG4gdrKn4VdORxyptu4h3H1+a+oE4oMtXTEVpoCkwlbVbt8C1lhKHy1slMGTboanmZFjxFYZXhxgTlxAIbhlf0sAg4U2qJ/96SNUmAMxD0rW/3yZ8Wsb0kegOP2dQ+3bCd37OB7xS6H2hVhCFQSrfhk8H/0Y4PrIXuriCprZUZojfL9Tzi3x6jGkSYHCB44lIke2OvwawTD39Zl8xUo++dZGvz8zGbrlE9CRPPZ0Hc9GljJTNoi/vUU5PrcZN8FZAx4WKVaPiItTzbuJ1bD+4+ekMnYa/WtE2Gp1iT4USoMPbmNyMbPc6n2bN7fe2Op6Jlavr1xOdjYPibImW2RLRo0vanOA/fTfS592pkODYVeaeA85haw7jha0CT36Z3pWB0ZU9TBjSvpNRFA49ufD1VFVMx7nADkjQ6u5aewPDsE8mwiQabMAwAtLXr6NJjpuEFs8amSZnFzrmQjFBiN7/Y7qqNq2YM4DZiFMcBZtTi64IXFA3KEHIY9l/9YlbEEfIC5I+UL27fFPmV3tdbrYaLgm++RopReLKowBsi6FGpR+4Srg++16PGAKgM9AniUGq/eJGLgfOqNUqiengkwnFRQP+XluovNi7+NuYM/Aw+rxsDw5eQvef8ObSuoBQ4uxctrh9GnDAPR7CzXDmjnQkRlI+TU5aTZBLpSkHjPBPJ7bvIuMljHghQVBJQXaeCxGyMEZ7XhZEDQb8HPVV7j+MqecSV5EyjxKKEWU1FDkc59sWWiin0rgXJWXwcUgPgKPwMCsjXluy1H7m1mdFyNo3vs0xRmL38PxDSJpMeZ143fgvV0zShevTlVdRKkKRvzrJnRWr7nWmkdMwAjJwSGf4noVRsObg+W9KTQCU+ykvnnYw6keDKmqZjm5L2D19x4yQnB8gNKEJC4rQGg8neThl41zMvu+vX2xTf2JVDHaM6ujssJ6G/8Xcp/SBvyevCgKp5QbfKB/HiyO1F1BA07c/3h2Ace1laEQoZeLHVRWKjszHW2ePpnINxRdDVziDmSZxdqG6dx1LUlaC4IkLzFICNX4cijo6bpdNaNm8TtRpLz1pjaeHKPgepPVREhFY5AQ7Zadp5gF+BN3n2NXh4NmhoxGeCyunbLF63Ao3GrM/cEBDwahBlIOu+U80EnzjHAjEsBKOIXk7N4tMJzd8LFUILPidJQVKwoH7FbL1wxu1rEzwexyY5dmXT9oGqSu6+lo4M1fy'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'LX4/TZTWS1FJUoU68/XxahOtNF4Y0aOzQcdiFSGGZvlnzJb8XI571Tqqv6AUXPGcDRSzI++N3k+ahvlFUn7hiMXRtLF0ct0dDvkdNLNPe7Ityj1mxREWmsQNVaQCcld2i167saRNOPpx21pZNT2RLag59NTTyltnDzrkA1TaCtgDj1V7/wKGpjieaW5KBU9LGkp7losndqazKRPC9yKnn9MSiXdz9Tpl3Dy7ljA4HWl6p2RkMyY2fai02SZAUt/NWiUsmAVe1GtEEHwS+nc5nbdxyf5f9pehBoc2u8RqOZ1cIBoHO9K0MM3Ir45SDHSW1KsYH7EzJMck+ChXCFWA2RuuNlTXjlSEOy+4R/+nCv/6HKUuKXdOIY1BQXHTJnmw7Wm9laN4cmbiIcJP2feAQGW1ZJy83ODV60c1DQXGtu0Ch0P4WJ4GIXP1UagKThSO9ZDgnFPhqKr3pxgxqU8FcZ+KEHJxLWfRWEvefzk2Ifqicl7MqAGkRfOxCzv8KqKVkWrMpG5CJoQ8prGz8FkUB9GZk9VltLrj9QvoyFWwpsvVFjAAVXmNIeOWc3F9BqIQRTo85BY6cgfq6FfUAnU2vNs15G6p0lhZI5eyJVcHiMQo/XmB6sGZkdWcuiCFy5RwHyUZLlKVa1z/QoJNElZECqgvbyexnR55ObJRD6OMpupHiSubR6x1+s9BGJg9LK60PWBrU2sLgVVDh8EE3pDmD5037vomKl6qfLIYwGNpgEVD9o1bOLOeLO3GN+xjk9V2hobItXg65SGekM0psh+XOC8r4b+CsO9QDqHEZOgXxazbnbHxhZfKX/th9VpB6Jh19jQK08zDgU5qqe2KyuaqiZPwJF6JUxV+Xdu7bC/rPYvpziGsvN8CuiWsf6s/p/Cud9F1SBE0R+U1L74xfxrtfx+sm2K204peHeth32+rcGAK3aO7dYFVT0T+WTEvJ4JWhq/mxPe5qOK5/mMX5f512opaAir28lRrMSzgZl4vl6KVFQTHl6c0g7i5jyQIj4IctuZAknjho+L+ycB8xuiAPMiTGKhdSY7ux1yzA8JKDE49EvPWkyBYKawaWw+3eEIh2vNpwpgJdjcg0PICeKTcmOCqJfURMpSUEsrN4H3FCcoJSznw5/BooDOf55m/7XEMKg7YApzdnsz89bNjFk5X2boon0I8wvfqk3A1K2+p41APufJwNy/vl46SuPlbOquX9qrN4GYBsMqLS4CWb/S7l3wddNMfDdTb4dm8MillUiEgtpvsIZfVuR9wELTyL9ko+AysJFsYDDiwaviWAacisxNeWNKo611UX1mtx8S+KKA7a4u/vWg28m5++0dXDNkV1GR9Fx0S+WZTuGHExO4YGDdLMwuTCwOHtDymdusyGCQ0tyXnzR76OHYIiEqzIonCqYVF0wR9tDY6Egb6kBLYRoSBVYk0O7o5YStii6dTtxtxbF7fXrgtAT2eWNfbRLJnPK8gqMW5EFPT2b7EIDjZ1G8JHtCPq1skbM2Gj3vJVP/H1y7XRlgAbQWHA+6HkS7OLcxymiRLN3mVEYWRCjkzfzv9KPYMUE0nH5yrFdMEwWnT784g3hbRovrsBa6u/X7KyN3etZ3ytRs8o6cNrmPG43AwklqKfErahvyRo/M+FwCkTv1kfBtXXcRDjHD2PmRcbyOCiL1hPHL1zsBuR3sByw37H+JTMuw9qM3sr/lrLeai7tI8vU8cnLN0nUROW40N6uNd/JwEWQj3fM9Y7WBbEZS+acW9I4NFWeAaHHqdQ3xT+MNPzO7905PcEP////8jSniqomzTo+bIoDfxrgFQt7FzwN+mGaNGVbBSy/kMKCdIAADS7ldvuJUBpmJxIfge5YI9VA6QFUZLi5H/qSUYsdVaqQYMmhnLPybxfaLJFqHmdub0MClH228eqt9oKXLWmHC6VnXX3dLHEIh3c+N6gOxfayDv12H6orhmkXfAk04hsWELcYWGZo4vcwP/zw1qR7WSNHSpqq2Bm9/O'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '/de7gqBich/rKQrx1Ph0UiqBVwx11UkLAJunYyGwyqmLGTJYgLnSEbjTj1d3n9KTwynbJWb6pZGeko5sPBuZ2z8GuWYWCH03HTabFa/WW2sk88baKD7dhK1+yDSHeJGzT2wrKeyBtWmtCZZe1Zsbbz2IS894OKEXyvJazF/rjorjSnWTRN99SXkcWw9YrPxLCPkmmMcMgfR/K7Llmir5OiSbgPMLSkYsFC25kBpDnc4A/G7HEHrBtvtX8vqEm0/ze8n5fVLOOHO0DKuvYZNmVvyHVhbQJUuThPzpFN3WleyU8uTKPTtrWHf87cNhAq+GQTcB/oQzgctaP6h7Uv3mgKh2xIneePa/KmDl23amRLZ7h1X0dLPlIj/LTLIIZkyQtyCwouiVGZ5v0vyN1jAujApPlE1kUiygYaDzNA09t+l5H3qF5zn/LdLAuPlbdLbzgvUIXchhOaE6FQOI98Ojp/mYlv1HTbmzHsR0BOzzNb2pgpLGCBBnhmhrIJmejF5N4zvyAsF1ChOJOUmXxd/r9e/6dCOkLb7K6Nj9+c/fk5Iz1Ue04AMAol27WsJtXG31DieFRRvrt24UdIhanXzjWqRExqRTYlPZQbgqWv7bO4jOIvhxo8h8/t/Ppl/aL3ruET6nMguSWr1x5NTmFlxCHSFCooyEN8IQ9Lity+nQ3Cr2NvLYy93exssnZegbZrtc7voElZcYQqaRBNauAHpa4vT23jgWOCJEml/5hcswU1xSM5SG5banm9HA2vePGWffRqHmWUC9InkAWGCyxcan+Qn3vaJBq512YFoJxBdQNpy38ZXO5IYpj8YhlpVyZWUStyv/TzLHYSUzzUBZp/YhgjtomqS9qYdgk1DhvSvcvYWVVwNKWdyioV+SJJIF6vmo5ZWA8y0SQ7sixhiPWmazsbJuifa3n4ZcRDNt8iEuHJOdsDquW6WbJ1+MlqsYe7Dmch1eKTqwAkMgxsB2mbiqww8xyPJHxNksMUq2ktkxATibY8nYKTIT3YFkssNfOzXL7D5H5KbJllVZUX6R/rrhAujJPR4cih2jZyoZLugdM2zXTZKX3o/FzYdhS2E40vcjgHUukNw0X9zKq/isBF7g9xP5tBv66QjRUjFUm3eE9glpu3DWZYNLvmUVS24k+Z1E9HdGUVg2W8htdi1r8HQE77hpI8vRDriJfQKVCyCScuoPFEtnOW82TI1CoNUYjCXBIplXcDf4HHilYM5B3nfpGPaUM2fZ4o2+jlp6IL8FTdbmRp0jWNzfkHThZobZbZAUt5gtKo1yAfc4TmMmiYjI/sIyoUjQ8qz3XEHQ5d6l8m7P/f+aXk3A0szMPVVElhHKz3WG1UnlN468KEdV23I3tL8BLFP4tJ6aLOypVdlAJiwRaCwy+EB+zgLtt4b9OnEvwxaSKy+Zhgzgo8fOrHDX/j3P2qkSRp2QAJ3a0r7IZktKMKlSSc8TNMJtFSJCRLrtgMZjH3We8NPH37WOakR7gFH8mh1MaTRIWJy796ZLRmIGxrmANkmCwuxZZm2AXvbwUulBTQMgfLrPribiBN6KoCrUon3dFBb6FvTaT3BQ/kOI7lO86cvmqnXQm0jyQrrmrE5Hl4OhJfRK3mlk1codioP2LGtLqWWt3xhtmzj+iD2WUw6Xl4qtLH8RVbbuc1ZGGcxBWhhsHuGCWNwp3KyIWRRyUtulOrXMHoEt/c6B6xdjKpsUVaHYSewPx7QSgOB23cTDd3Buiq59CVvP6iqoln7wCkb4yVSs8ACJ3Qmr/LcsvO33YRw4sBw0Qnnx1SczJ/HQV06Ozk9BM3ryVMldSIvx6cSFda8UkRbpqIfOvudbjNN6m2Mawwj/////YCl3Nn3WGVppCp+VgONTBUuFA4c37tUa8irMUdoqoVfwK6XSznN4oxYk176z5Agyhr8MocQUTLUvItlsTNqRKbdSq7kEl9+t/esW7ghGac/FRwQEJRdC8DsoynlLoYorY4kgJQLycbgArj4lJn0P'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= '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'
$7zGminiexe &= 'Af8NAf+qDQH/AQH//QDMMQD/quDwDwlmDQBmPGAG7hQQbSCMYQYQAlAKAPD19QVwd3cHAGBoaAhgaWkJALC8vAwgKysLAHB9fQ3Q3d0NADA+Pg6grq4OABAfHw+Aj48/AgDvmwOkoKBeDg8G8P+DAP8yDA3wBCIICfASvM+lq/ACSXB98AD/vF+FjiTUK1+A8gi8rwGcvD/0D4y8TwF8vD8DjF2TvfUJMPbfZ2/RBNhzT4FDvA8Rq9uvz8D7Uv8A2wcPAbC8zwPwEP4Ajwjw/8oAOiyrz/EY3ijiUgMcb99BfzIiSBUBjEkDICAQVi5ivBUBADEQEDTjtRUCADAqKhBsoRL2WjEAgOGQ4MEDRDTcYAUwZa0FVgAQRQBSJJAE8ARg5cQDSRRgxAIA0ftC8K7SBAE6U2DPElpTwTHaTlQBEAQEoAjUTgUhUwIAdAByAGmGSHAmWAOQBsAGUFYG4Ibq9gFvjKDCKDAANKgMkMMhYr4swgRgAcoFQ4zQBgAHEKbKC3k1AWE0UNYGwqTIJGQAa20AZVUAc602MlDUBiBGAyQz1w0wVEYHAAA8AIpr0A5WRMQAcwBjTSFwjDCW1ghgrzQ3AC0+REAVBCAARwBVlQEAABU2AAvsaFUEMseMBTEANQAuxQE1zHDVVimSxiUoPSOdEhUxUW69AWwFgjcAej0DFQAAjMUCATUCZTSwTRjFEnCtAnURZ5ZjoKIZokwPANIHMAaQwgEx1dUDBNFihgQwNSEg1QBVZ8QgRwJQTQB2VQBVbxTAwgNUhSFvJFAlVT0yVgMQRgpknSBfOGUHAb0GnTCkURTRLlVNE+2RLiyAxyMstpYQFdAKIFcGQAZQVwUwRtda2kUHAKDTQ8K67lXUTfQGXl0RQAvFESX4AAAtACQuOkJFB20Xc3wQFNZnmkAASwDfuQDA84PXxgZiVwYgN5f25tYjEgPgAiMCUuY29gZAluZ21iNSRQVg1IIjAjJHFwbgRhbG9uZW1gMgklc2J/Lj0wCgwBM2N1fWJgbBlgcSAOA21yMCUCfnpjM3hlYG0BY219KWNiYH8Db3ZkbXMvYG0KYTNtfmYhcDIALSFuaWZlbGMUdnVQuKL4xhNyMZAf8wI1IOAALSDpYUQFbmRpdGlxcgCkgQIiBwcm9jZQBzc29yQXJjaAFpdGVjdHVy+QECKiIgbmFtIHBD0KKVBudCQXpHBCIgdHlwWHCXRuA2IyPykglDViYwNyaXBkdXBuADSCogR1VJLjwvxFwJSnBlbi0BY3nLPEKEdEGpQT7R8QDFkKBVQU3NUi5XaW5kAG93cy5Db21tAG9uLUNvbnRyCm9scyKpcjap8hBwAHVibGljS2V5CFRva2XIUZNTAyBmQxNDQzM2BmAWQ2YmAsIWRuB2Vhd2hisvPv5pEt3RgSJcVigUI9BboHMRBgfXBxAWMgZmUQKF9RFTZXR0IQhzjVcBaHR0cDovL4VGUC6FZi6FBi9TTUkDLzIwMDUv6ULwBdxsAxA8ZHBpQXcAYXJlPnRydWXvUQE41Q70Eg8/UCBUHC9AFcGZYsIFO6QAQCrEtFUNTADMxBpMgMzEVSdMAM3ENEyAzcRVPkwAzsRITIDOxFVVTADPxGFMgM/EqgDFxgZ6DKDIAJqtDIDKALYMABDEHFQV4YhH0jxEzkHyHISui0eiAMAzDBy0VCQF4FTENCPjQsQEwAQQRGQVBJUECQNkbLYF8NQ0REVMFjBExHQEQ0dEiIz1xlZGQk9MRRBBVVQwNIVUxGRIXlVTRVIoZKYAbwBhZExpYnJhckJ5gnFwVEYHlaoQhEFGJperYNoAaXJ0HHVhbEzQrMFjQWwRbG9jNGYkV2ZOEBhFeGnwAi4AUmUDZ0Nsb3NlZQs0ANoF8FSnYJTGVuYEWtFwFS1QxlZGVwbxJKbWBTL0luQWkEaXFsaWppcCAEAkF3ZmlOaWxjSn3QdJc605ZRMKAEoMFCDGAwEQLMM4gQOJ4+bx/78AYBOe'
$7zGminiexe &= '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'
$7zGminiexe &= 'eDECQLAEkxQqRAokmoLvItgSAALj0ATxoNoQQRCgYBD834GmClABAQEEXDBaMCg8lQATYMgh+VF1YrRg8DY2B9fCT5IfAIPkQmoChjogJVcGF/A2l0b3JpdXCoxQJgej0xUBQjAjABMD82JAgAIAYTDNGRFAAgEWGREQcXMVACZjgI9DUFMJzYDWAcIZvtFKs6YBcHOQJWTWCjwIIGD0ki5jR6YK0PKnmuHbbV0OcNY849xAHb4FYMR1SiEBf6UJcLaYa8pZBewB4L1QLbYsdXkDMM3bFJRo9OQPsO2p0gIlTxULQO8CWR4LoakJMHvrUkErCrwCQAGEUYcH4toBcNIRWv8QxnUEMC9C53vf/XcLgKEk9oDhksoAsN8dy+RU7eQGAGrSUqWA14cKMD5GIAAE9ewDoHqYqb8eSY0EcJdG6GtdQTMGQKegQOwTPXYBYCtSOXasnuwIIAiGI+JyuQYIELIgKnRK0EsOkDsmvg7rbeoH4GMSzHC8M9ID4CdNr+CZbEUI4AQS+0h1YPkG4F9SgfgcnK0AAGBUKOLQfjcKwMSvPqhebUNfUA8jWHBtHgC/1gEE0KcUjxRG6hMDIKMpvmY7NyVAbh3QRgCPJhoBMTVqAhATk3AzU0MjGhExNjiABINDMHdlgURFMRAXMBVlIQwOVGkAbm8gUmVpY2gMYXJkdDowUKZBMADCUKL4ESBTb3VyCGNlIETyAfEGV2Yjx+IQAbz6EdOQMJUAEWABUYQD1DbWJpDGtuZCVqYq8A/UAE9WgwZxTl4kANgn4XhL/KmYAM2LA6GhhJiBABVcBeso7gP3ABv7eG1jnXAsAICupISBe8FHACUpKH0/DjJsAGORDFCoV8fHAItJ89FDOa4cALegU3ZwqVOnAJ17I4thK0PUAMRFMAmKZDMXAH/gG4vfbvOdAAwVI1V/rzzSAGucwvwg07PNAICWf8WwbfHeAMa3rzDDj5XZAI5r4pLcmmDNAPAb5beDdUC7ADqEurHuT/gDAHP2Iuck/99HAIDhx1/jRt/PAOwk7ODxedfJAL6yHsWx0h4aAOuIWJ/Sqye8AHzeMg21suK2ACTxwkeoeVQ8AGldeFUxbRfOALq1tHshMl60ABPSCbT5OS7GAMxaqWiGXEW2ARw/obODduOqAiQiwCWiAVgwDKoCJlACAyAJ8BZsM5IAEiYJgAVVMFMwIZIAWAFO/XoA4RmBdgB/kQhhBwDiEjIiLhFggOoET2BWcMFYIO9jAObf0uUVV4lFAWmLSTypT5kWBItyABhx0OMbMIIBNKAwAMMALAYKKoQGaAGG9ndGHsADHJD2AW8RKM9pAjCB5RQwIBbV/AgwOQ4HGgiBwFVzKjcA8mY2AEKHljYH0gPh0TEgZSA4MEcnlzYWRyfsA2YFILYSZWQgLQAAdGhlIENFUlQgVU3uDgwlFzZGJ5YWuyDYAXRlbUo4AEKE0hWQApKmBwRycCBvclRABiKWB0IgV2ZWJmeGA2UgR2gckOYGIgsEkFAGYhhPBxJGBxIrTxBYCAM1kT9RIqOhAzARBgAJYIZIAYb4QsglB6EEBBBqBi9QsYMKUFALV13mFLoM8GKP5+2n/WQBgL63R3h9y7EFYMHrcaD4E6IAsFlmHBRm958OwFakZ4KpK9sC4FhdD12MEbYK8N9MN2wLJ7YMkM4MiwhTDx8EgENjrbg12f8JkGw3azQ3wLMBACsz+p5O4ekOYCm5CuygYbsOYHOKGy7v6y4IMFZQ6qablKQHIB8tZaOCkSkHcJJPCjftGYUPAJEnUoy3fh0AoEaIPkiEFxQE0GNO+0H7+4YFwNMX0ZLU/N0GUMMPzESTQo0JoCjJgB4U7s0GMCi8vLYiyogI4Dv/eUARt8UHsGRmthxCL4oPQMMPjJ5146UKEP8lUfb35bQKwB33OPVUCE8LAIIZ6plhFv8PkItfecU4AYYCgH1aeMoSI0gQFahmAH0KKgATyKhe8GjMVggf4K5yoHBCEeC/'
$7zGminiexe &= 'cgwxolkfGcYENxDDgIcEIzAcNLgQ4+ADADwnUQEzAn4EMY0NywDRoBpVsuikkABjlW0nnlfmNBguMv6yBVzWAGD4BUBeIY0xFD/yAdB0lIEx5dxlAnCqMCCIWIj6AdCoDeFVqYlUDOB/X4mb7ZkzAaCdwmDCJP0RDRDUIzRhnPPoCsAvA7zVFZkWC3AU8Dm33YR+BvBHkQ4Zn2wNDHBnSy1a/XcBBfBcjXWrGcMVD4AoE2mBNZ+rBQBUfoQggfcSAwB7+RBsf1kfCuCab7RiFL3qDQB8IhtusLU4BACmK6W0nn9YAlCQG0XcQmtgCIDHr7AL6od+ATDvuciU+3tnAvC1UDVbaI7bAWDXyOszojoQCdC6nGmUZY7GAcDsIEsv8QzHDFDUF0YWUQYpDLBe0Oc96iK6CAC5Knu/JsjsAqA5VPJKfdrlBxCm2tXolaTSDABOmySYJwdGBJDPjSJVRxAqCCNwZVcA/jKXYBAjOCXgLwMC/jIBU2SI8S7mMVMYbRhYDYPRaLkAYzEHAYkGZFYQ86DtIAA3MjUxMDUyM8CeDpBo/aYghqzGCID84sFzTaWBAHAFcQSLqwNjB2KwAFkQAgwxZwAwZTBjMGEEFAANLPli+00ELwAvFAHeZurLqAENp2ESMEkwEhwfAyxX42lIqR1OwrIVAOWBbFPQwGFwAEqmnuL2NmyyABc8YgVj8uIOAHcE+Ul7V6cRAHMiio8gFGapAJxE3nyERo4kAJJVqw9X4Ja/AOVPHIsmhD5mAAgIDrlDlEBhAJxmBhY8N8xAAKF/4y89JggrAIizpdnZbpC7AJhuu1r9he+CAMQLSANxv0/TAGyrGKgU2ds5AGKpOEU35x7lAOgT7lM+A0rbAOAjpUaKAUyiAFHwNyuZLqFUAJMZwm2dQ41gAHFhtYcbOsloAB9GfggKIJBiAF87FxUrOV6eAFg1BlQFpE7uAB/nh1HjLRKuAIoFICau51T+AMx73lvxQ5ZvAJbtGuL6YjJEAJ/Dd50o25SXAF7j8yNdPPFbAL2SDAs74161H07sAA=='
$7zGminiexe = _WinAPI_Base64Decode($7zGminiexe)
Local Const $bString = ASM_DecompressLZMAT($7zGminiexe)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\7zG-mini.exe", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func _vscscx64exe($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $vscscx64exe
$vscscx64exe &= 'AAIBAE0AWpAAAwAAAASDBvD/DwCA6wAAgQbkQACvgG4ADh+6AA4AtAnNIbgBAEzNIVRoaXMgAHByb2dyYW0gAGNhbm5vdCBiAGUgcnVuIGluACBET1MgbW9kAmUuDQ0KJIbkHoC956uaW9FuUAQX9oPtqw4wGkwE6ECR7a4OYtlOlOsghu27VkLRXqTmIZ/tpg4S6EVD'
$vscscx64exe &= 'hA4ilTaG5hlXUABQRQAAZIYDAAgLM31NJgUPMIIAsCCQIAEBAABrECIxEYBvABAGUBAwrAIuIwAAUIAQANDpUAAgYwFmoiaAGAbOQB4PQKEAoBYEAEGclAFBAABq4AAGkAMADC3p8REA31L1AYUFswYWApUvAYCZAF3gThCjMTcRVkDv9ACBRwPgLnJzcmO5UJWXAAAK'
$vscscx64exe &= 'DoDv5MCz8FCCAP8PADDjkhMD8CgQYszw////DSQOCsrO6a9NKAFTE9gDAPjnAAAAoAMASQUAKBoDACQjPK6ct7o+D1T1a7SbXHo6ZZ7xAwn+3YDWfMz/RclGn5Ru6X9UcZzDLw3Vmm0DEdScpfJFJnOefY5JjTE8UxVRwz+7b59udIpn8hwGlKNsQWxeDEwPN2/FMPhG'
$vscscx64exe &= 'B4ufdtVlVbiJufgZRhdpMxFEDs4y6lSRhxJGwDZi2REkA7JmMzilqrwHdH9+I2qVt3X6SDF+8xtK6msPVbaXG1heOxRKL8QHUf+aXeCQC2WxiacZZ2tR2nHPqqMDJbNCSZ/IqR6aCe2L1fRDhQ1npCBfNgjUNYs9/zQ9Gzu7O3uGgGWKN9r+2E4nEhS3bkbtYP0INL3Z'
$vscscx64exe &= 'AUWQrajqU580ih0rfqi1V/5vSgtBaYcMBT/hOJlU8oKi0D+Q/KIzO4Vcjr1xJw+YLG9cLm6ow5fQXZ72WoKUXCLWFxLonrejHmkJa0fDZDY1R44ZI71TqFTTiJrzTlRb7mzo2SOC6jDuMBRibITBp3MAnJUdBDiFUPg5biwsEIE00uXiSiMBIHO/fAmZ2mr2bVnkFm9d'
$vscscx64exe &= '48uslvEHq1+disKLFN6fRXlR/cFAcf2wRTZYsbEkcWR+6vhD7HLAWhswXz1fD2X//efPntLaNt/M++LgcaEJDaC9nn0MJ9WgQ/2S89m/4sieZUwTNnk/RYbRgSU+9o95A38p7ZTuIvHdVZVI8xdPER5Alhzi+jmqyZ77pgHaK8NnuEPYI5/Smxg7L9mxNVk0JtynTLlg'
$vscscx64exe &= '6gObWNwKUciJlrm/DwhdP9JxDRmVxq7VkwfWmtahartGPRh5tGmjGcnqMOeGZcJG9JjKxf+jrDtUklWCtUaOnt+LVopxQUA6ZOfYQgKray3SgSBa/iRZC9j3SX66qI3AfjENO3xfElgBKWMvHRsV3pi7VIs02GDop5XM0SusPu+VQNfD02fI2xDoXvq8UOiLg4AvUOuV'
$vscscx64exe &= 'KXO65bCaMCvQdZGOiTR64LZgIEQuF+F5qVwgcT+ULk+1OQOpmRg5O8kIxtraTSdiF5+ceSaYLGEpImNRLWdPFEY6Fd1QHNObR9AOhT96n7JotRBD7dG65bzHJERdWB7kr+sTguGMZ57sm0Yi7DDq/WUipQiQs2wUU1P028oBINJ9h+4i5H52CaI1ast0YBZBz12eUzkD'
$vscscx64exe &= 'ceQdzd1WAehL7l4Ug81ZuHpa81ZwVnFfyDyYKEL0VO5BUqqXSGubFII8ZrFiMsOUMvmDlAlXA9Z2QB6pDvWHbWz2xUuDXxpQWCCglGQEB10vL5CBbG5w7bxczpiX3Hd5iYWXLKTPZEH94Kv04oGuzOyivwWZXdH0mmwLRiLnj9P3Mafgdn1rO4ji6/ew2roEv59ljNu5'
$vscscx64exe &= 'ZH/a/AXz6vRE4g+FTAvmlMVvxhz1mDreoMqDdVZVPSmaZ6+ZUJCepaqiMUGXbM6nELqU6CgCHfXP2Ntm5/A+81ij19lEteDSm8DfjG9XhmQSkRxK7CTAWxAAVj2Lppis0c47vEcBjE8ftT1mKMxt4gJKuENgDpiFJ4WY+95/aMnJe98Foz4uWlE66lHD6QbOa/KPUVnx'
$vscscx64exe &= '0WSivt7IkXDpYXinVlf+Vkm6g9lVp3mNrwVfK3z6UiimR6xeIAeDQ3zHpmF24VGRkZSEQxhyFL9HMmaaC49svLK85Rk1L9kSMacVJzz0pt0Z4/hSnV1iqeUR5ltO0FrO+hzjvTkXDT9cGXJpr1Ziz9VOMAUlZpSJjlahzIXFcDbWZvYawhrpC16wjrqhMVv6XYyz1bcR'
$vscscx64exe &= 'H0BWh0nkDuEOkalkDZ5SuYq/NZeGjzO2TqPEuvmFpLiYHwPJfZaUaZELj+8p3cAhOhCLNltitCVMaBFtpgWS8WXR2uZNJJl6OKe3i7T/yTeGTbugxONlfyC7DInE665TjWQ90t5iEspKl41+dPCOCD042FpBihZQ73zRX6pEDfZSTbQ83+G4QCbLuP36uRAhANE4fR9A'
$vscscx64exe &= 'cukiZqlAkY0tm+UbwX4wou16QqUMsv1UZ68IiNdRhf+WAzZ/3djAy9b8hh4rS17w8ZF2cMlEqesTEB+/uy4dfwnDlhXycgqDV3y2ZUh3JpM3Wmy4psLtqgIh12C/VWE5Tsp08bu5ndtIcdBBk24NYkmEVuU+pHjiCB0jJMIZvtF/xUs/gvjslDR/yO82rOvSB+8unSC7'
$vscscx64exe &= 'izNi5oEia3HEuNmhewcAT5Ok2p7Jx0OI8Qnpc9pbqLt61ADyFlPeUy768x/RpfUb1YvHEAt7qBrZ6nmY79nzUiS0429ioNdwBxzJTDzVV0FVwfMRiLZqNJyC06a2E0b9qzX3f6Z7OuV1Vh3I3VC8XvPbZATxDYaMLqsJ29BC/MmZ7/skOOU+y7cSAh5gr2JIKPWhQ/DJ'
$vscscx64exe &= '7hnn5+i1OcALdhugMG5CkVbU5c5W8E7imMdaCVq10zkHkrkjuMpLFtWuOgbLB/mtSgXhJkRFKS7rGloe4BNHtzKNP3g1QTXGIRWMU6CcfNVcC0AOP8cBZ4Jc/n0fCoO69PaF3oJZBRReXx5f4ENQHNb11eBUUkI5L6UHES30qY9iw/bP3332PCDAKtOGRgpQb0rqVkzf'
$vscscx64exe &= 'Gg+uxx4sE2Inya903vIJGWzQXpqe44Hh7xK7pFq+8Wz8WaYVEhFj3bP2kWSHfetlxbHIH32VWWUllQFpL15YxXKs2JGVPyPYTWG2WXBzi2OR1qosWEbLZhvm0ipfJKYFajSQsQFU5C6y4wC+nM2OvsNaRAkeB0C1Mhex6jusWdabu/P/eE1he30HxD7sA0yCVo3UubOk'
$vscscx64exe &= 'Jnfr8M7oDZO3c9UHUjff86G5UonBiP4V2kR0W9rMbdpI/QPT5cuj//8Wdxh1rJ8DeaWNvaG6wGZLOklJHyRSLDsmZTfS4Ee/B7SBN/e6nv2GjY1hwpKbLeHEws+oSZLSPTFJHaHPoXcwfHsnRqqqPyV9hBCVcSTOw17FsGmDUutqFJjQtavp7OyYF9atYqHkGITFwklV'
$vscscx64exe &= 'KO2XkpOt+k2+EmSqqKxBd0u1pLJmO8Lsuh82AuhVt8QhEMPoTSyCj707L3QIyVGoQGClrDMWbda+WiusIv93hR6EJbEFWisGRZpBn7spBBJJe0mVFoN4e6iblNtR0fkpP1xc9MQZ6t/8xIcs1ys7ChCOrttBiO/yLljtTS7QuqC+uwcLnIwCUAyZU5C6j9Pkw80P5Iib'
$vscscx64exe &= 'YCkeRyoojlL5WD3S3erOGLzsKACo1Et4nDQkC+5u+cxjZ3xFHawdYD8eaz+dEyzpJOFLJ6z9s2B+2td+JtZYRv1tWWgJfliKyPtj4zIpg7ZqDGCI5qROiLChnfqidU2jbQab/UKnHM4QGjwYVY2F3n0Bt7LFqEHKs0RNNhBM8ouvVcZKgqnirkUcXemDb0+Xr3UjAGSe'
$vscscx64exe &= 'hSGZZHVyVIZiwvG/ANpTpiJwle/tRiLixx5zqtcXuKxeG6EiPUpLB155sVlTAOTMWmmS+lFItEBnSDy3CyslIKhuvlFZVM4Hk8UEsI9BbXAR6ynAG2ctJV7AOq7r3TnSSpqT5GqgOR/F/2Tqx7COogrRO7ScrFaJw/sfQ0eFEP1GSPqKVo9UbqCQpjDUjJAEl5er7YIp'
$vscscx64exe &= 'r1AbBS6rNcZynUScrn/2jgm5Zor6M09OFFxJgeHqgT/2hxex+sRDTKF9Nqh6+K8/yH3rLrm9MiY5txanlZbrUu1im4s68E5zypvMYSyyVp8nbCB/Cttht0Vzb+CwsuNJ8H75cTxSNS8uyXvsJhbB3k2dguxNnwNu8Lgoij/uVhbQPFtHJIAsHSEhB2Y9bNVG6ZK1z2wZ'
$vscscx64exe &= 'hqfXAFKChMXoD6Dbtyi2fQxWgHZZJw2DD4k6YLwfOv81RAP7EOpJxymSXBBd3BQtzdla6Ownb6JbnO0vC7PbkRPTUpjWTo3ykrO7I7TvC3f8nEBonONv2ds3WXWN45alRnRSrR2M5sb5eWdq32XHkw66Ts6/kPaAF4bYEo5EOAQeSlwMsg8DZ4gJh5gr7vIVpUK4Avno'
$vscscx64exe &= 'KbcxV1KIcEjFFs5lFVc2HCIo1+ui/BcUFbRelLadw6fIvvKTqoGCDV4zDrXa/rKoggPud1GV/K0Coc0iZ7zLz2Ctae2dCDf9HFCDVlj1vszypVAn6rMlf0gQwtvi7xFTBuqEpBKgkYGBsiA/wq3Kfm7L/Pqgbvl/N6K4nQOZbyNAz/M0uWBeY+mujb3wrVrjXYOeebk+'
$vscscx64exe &= 'qL19iN+OfkRWpvpOeVGSFKcZHhvFEdj0K2TakZkusJfmYb/c9MrkXJN4KHmglDTCjh3RwDKUDFE0/OReKd/ztqeREt1KN5r4xv12aQv4yOMjEgCJyK8NHaUaIseJ0choYm2XBukalRnmcinynoyCx7FIBmrSKMPiSF91M/Sfu94lXghqGGFYLqBKAYbMqBlPzRhDW6SV'
$vscscx64exe &= 'IXOjD+8ksOZyzFux/2ryQGfvYq0jEMmR+wk3TPrdFX6AR9rUTaqc3wA2ANE7lBzwUjn9B3PeWXmlRErksyXzmd5yfxIggv8DPo0GXGjXrabm2XlL6rR69EQnroQiOZHLFpCD/X0YK4bT9EaqeF0ewcLgDomnO2adFU96A/Vg7v2X5R2kzQq/mdcMU94ZuFOSpM7lm5Nr'
$vscscx64exe &= 'R9j0Xxe1Ja4+GzFlkwPxXlDiM6bcp9fbohZ9pJog3GXxOr7Pe2pqzEJbBP9Oa+Cm6U5ZHml8krd6rMFX45RsDoSV70Fsvo02Bxi5/RFSyChbArffNDc6x3XBviQdOLcH6rGusSONwAAr1L/yyaa5n7bvRXPK2TpPmlq/sz4UPfWqapSz5h9JqeVa/QErb8gjE29kuTFq'
$vscscx64exe &= 'afJGy/oF6iHSHs1n3ZQtTvJvQHCIeoDhElzLHwfxZ3AH810X2Tx9GqiXUKQ60sbvPcovGyzh9ersfyisfFPh4GLrLFSLuBdcWfCIbc0HWO6R/6Vyo7jfJflm8rQI/////1V59+LCRZEr7tLG74hQXsEAOBVuiifMFDPBtLQqk0IfJJ1sFvTbXqlNpvx6qCE+kVP0lk+6'
$vscscx64exe &= 'jAoWIoys8DPPFFif9kWKXfiB/l4pj5GBv+JPnkEJ7wiu3bpkRgHpv/iCmy17u89ZyIWvafVp0iQQuwsmu9gho8J0Za6JKsU2mo28Us4Q9uCCvUcHtViZaJ5wmkmsaqi4x5MeivZDbeLm+/bOLDeEkrpGBHRp85d5MFSo9WlKfNNt2MlSlEbmryzaptwA/WuFHRAtufrw'
$vscscx64exe &= 'ys2FNLF74zUG9tHFTPBQLDe0fFPPjBS4Ksbc1z0uBNkIv8+vGHwOZIgouzeiLnrOQIVJsZ8bJPXH6hmsPjsu8b4E4AG+VCkALzJ/bilNgQ/vHvPaftTp4Wv1+u0e6Cqo4XHKkdTgpZpAoJ07cIBafZWSwAaytW9abyacOR4kY8qaFfvS85PdMsMw/I3tB1RL4zE/9vc+'
$vscscx64exe &= 'XoDJIZgaseZ0rs1W9jBAL2/dqLOMQ7+PMUGZq5/ULl9nk96cdVsDnW2Qj1/60f+uGF5wjeWvBXyAr7Si64Oj9kfBUxe7wg97Koyzyagneb/oXKq/QvOmzeUJUyCXAf6HRcbZvbtE9J8dK5Lhk5Cb+dZOxbtrnEKhMxvuvu2zmcW+b1MjO8/0eSz7cSgg01CblzTqrrD+'
$vscscx64exe &= 'GPns6QRfFWu8NWho30Egydsb35g+BRYN9uwXLdLw2E2FQkK4ByDHap5UIud1DdLDhG1nmUJ+8U/RQdIbFH65jekwkiq2awFZSDf9BReOWhbr6wtZugmKE48HwtMCA4H/NY8U3GsCehjl4zJm869qRzGdqOS2MGvscwoCGToQwM4/uZSS67li7Dbu02sB2F17l0e1PcZY'
$vscscx64exe &= '3dXK15/VUomclpcWHwf9nlAF7SBzui9UeqC155GzQVn4/QSNEmgxQBYo0BcOBxlnSoVNb71IBUc6/9zS2we6tHkM83MtqkuK6bJvsaWyPWGlXAGhTP5dpdUh3PaAPX5gZnURP3MNflwtKjV9nGLk92m+GlJYwoXnYke/4QQ0dtRyBQ2Ha4ykbY5HC+KYyfGbJyBz4Nzj'
$vscscx64exe &= 'eS879WesYAD32hYp3WNvWDwumijEkAv2QUecqiI2YVg3pppyFqLiLwhv4a4aC9uWkuBA0tRWE5O4cuGgGB3yDsUYYwDnNuCOK7W638mIPuOffJAdTpa+KIpauYRGSipjT8/RncQT1OV8lQReDxyJ5/+9emO96E0hsUyfKfvZFistf4gef+Jctj+JDYcwDqcIa1i6ff3s'
$vscscx64exe &= 'FKn6DcPeCrums6xixghiJ7/gqoL/g7KpnXYsWdEtY1bM74RNqch2nZnmz7PKUy3bhqqq6zqwqJOkWTHQo28vFFI2Iquz8d6FiCVXD+SOAiIucc5fMjq83zdhTYffwwxYhLc6YRVkFH9SUjX33SXEJM3dXnRipUeyF21WwhrqaVfwctp7U7KPeiQwIq2CYJKU9oxbhtfa'
$vscscx64exe &= 'EKdwaADlzfmeT2dRaD/ACa4LooEpi0I7d1MhAvZmH7sPuqJ2mBJpVkLa/5VUmY0SBbNnBzpLb6DHBo+is9miLeDFMYjB6VOI35LjGB98QpsTIWBtUYGi2NpCJedSOvgu+nWzY0QL++4G1OiSwcYPJvgBhP9GRPTruIbIwkzmU9bsUAR5nzRE53NjN94mFGq39AYMBtO2'
$vscscx64exe &= 'j3rVC5aUXGtzakp7hl8VwLsYxVyZnKlx15OV1Yx+o12uBUd93u3M4E9lsgJ278tZ6eA2/SjYG+445BmKxbvxBbTKvNoUl6Tb+xMerpaGZjm9HePQrqH1hQwkpsLd8SN4KPNs2WzwZjMFTwsYLV1HkYp/gjEjKdgv2YarQnyPIeikhUpwuMQhxK6+6gN7Vv5HjR0BRfdV'
$vscscx64exe &= 'H8lettdhm84B9nbuIXMnPixbyT5eG4OdxrhFkSXWg6ZvQga2utCWe/5xwEbgCxupCgHqFEoIKKnX6qkdgapx7gYyyzgDEkLYULZMIEjJ8hlKJypTdfcnsFE7pNwzfAWRvzN3CI5CC5QmoV1y8E9egUZw0znQo0Aq8JMlS0r2LYNyDJU+TbM5JUHnx/NtjabyA9M4YetR'
$vscscx64exe &= 'AwWZZ0CcYwU2og+GNUUqxp0HK2cvEeCOyGIBXVly2gqHoN7NPXD3Pbfje5963WcudFgXpuFAL3gXS603lnI/8up7fxEWRRE7J0XN9kQUmL/jqlx+IXDaOPRBlNKuTWJee6eEVjIwG+Cp3Hgh07U4ehDT0fWVJKEMXv87TRGFI0QhMBg2PPRM45LbLM0AJ0Jejc89X52r'
$vscscx64exe &= '2jVTFA62zr4QglLIgvQrtoTLT5y7zY02WTmqt4uMx1S/b7Srz5uTkvT0jRmiG9ltPbjZOMbjn9wUYuwvFoWYWxiklh93RkSavwaWG/RkcgIcq3F7moBKVGizAOixKvgSLHa+5CZBrvmUhMO+Y5o6rkMPj1Vwij+tGE9ieZOSAyOSvy3iOpYaTHL1M8RL6gi1jzPZGfUF'
$vscscx64exe &= 'e81uhrgYsg+ygKKE+xa6LCQeicBwSwWcvAenxnPHU+2+HSZd8KSkTzosYDLCt/3C956aosGPf0G3JdoII4p7SOag8aqSBsrpquDJwcKxl0/NwfuuLTOC4x3GBaFl7N/Po3UI1Ip+nADpn7MrQKrAAzFuUFvNxydsfpn/3QfxavsIRoTxO9h5khO0DQEKCFvAQ+3eZdW5'
$vscscx64exe &= 'QlrbQ1mvEplOUTfp+GM+miX/L4nNBcY1JUr9K4ovR0lnWlNoQ6xhCVxq5ZHGd0+vEEUvbRQS3n8RWs90DRJ1sYrGS4xbS/HxNXMbwAVb8qNwUKPeQlGIeeC0OTK3ZI7+juAgCeicTg1A1aY1JnHhL+LAjvsZ2eVflF40BhLNPwVKz2at5CgVDr0cI4dWR/4Kt2xTreSM'
$vscscx64exe &= 'PY2chT44siEcHlqWO1w5QzSgx6p6YqANLftKluDUy8ivh3gHvQVh72UwMPGyQmUWYkEpl7kOwvbzuhHR+bInv58s0wu6dwv7TDjB3sZ3lj3Df9DJ+g+BuSmkDluooHI5cNZfX0echda0VHOVAqS673U/Y4dKPVEeAIgf0HYneqESDEPDR8ADxy9JK/kisJUOw88DmxuR'
$vscscx64exe &= 'ZXa+IJ9rGbGrkpMpv1mPATIxT8ZtDTgD3ll4VPNHs2j3H0gjvkQXklhR2dmIqDf/AAFanSphEIVgfEHzrqm6heRXNNKSUeH9Sd9UQw2TsRUIL4KsGw25uvD1k2OFQ+GTve/drnqg7XvgVUjyg+MaOBEQLZkfN5jPlUDazjOaGkhBwCUTf4ba6I0xtXqeS2XPw9PJSBpW'
$vscscx64exe &= 'YoX7qa2+mXoGwZhqOBqd+cgOqAgMOGUQXw9YZlZBO1fqg76wAn11nqc7XKkM/////zir8wY6028V/RdVlUjCH5onQSaUXLr+d3C1PtpZpFP2k84XJytDY3XAssP2iOSjTchk+7KQIIn7LvOLczd8ifqzWlcOg3vSgle4GoyC8qgcK8aFcaQEjy/QieZxQboYQ/q1TXwr'
$vscscx64exe &= 'eIYRTV4fFfpjwQ6QQQJA2g2TIueWdw/B9aWzY0TByr674pDbQ9TtZVPORI/odBNu10irGy1iZJYj9a+Mih9ts5k/LrPx2OkJ7lYNZoIG0mUAwqFaWDyWxowBnZO2yzbTQ0jrFx+LUPSQWFuQKEwmqcR+EAttOCkyh6AJ2cSxfeKmudfQkdclFcEivTNcPMBATBDNjFRX'
$vscscx64exe &= 'iKVNGekTzJf3EbPZqThmbXFNcf2nEQ8fTC1nBSk3x7n5TCjEdUu+faZsA6sRr0EHaCMCSmx6Z+juD0AG4Dn2hHqgNt6aOI5JWnqo5ERyF9LJZz9ouAYeML+q86QrQ7wDrI/a3RKbT9nwWzwhcVHBfCSJj3Xq4NieMUVMCBC2NHidt82nX73qnD9mfsf/ZmiGfusAjT6+'
$vscscx64exe &= 'zp0JOEL06DW7No421z5XJrK5gpZk46LR2n5UKvwW2f2xjzS8zr570SZjumxuNBkgxwHVSL9TUzKftgQkASLxUuA+qjONgYDxqDMdp3efjAykXaKZhBqNljCqY3tJe/AoBVUimXhB3q6lxPCBsclsG4FBBwxfvj16NFoyppVPyTbGz38GEzQQxxwUffRJITOANN6PDFV+'
$vscscx64exe &= '7FumCyDCpRwLyOBJVy6knnJK6/s4mUbc9GjSW6y0QEzjggqCxr2HNoYgHSoB1fAnygdU+yZL7GyyIqOaj4CP8Spwp1Fbt4b2ZZIHimAP9AZqnOjmY9SUYR0mJcWX/fvAF1Dcr9dFcRhRBnY/S5B66qSIf8i4q/+fJ3KmtqPDuypv591393UWdCpGqKFKUBGjSHAuYW0X'
$vscscx64exe &= 'VmjWnzweLn5jOEP2j0te1O/zQkMS9VjncAc1BDewjWo+BHXNnlsdTxprQOfQs3CtWZkJ+WtSWqFwLpYsvFYsRUUl6wbqUAcmpXiOcUi/FY2JU8g/BX6Q8g3CZneMealhiSW1XDFFHD26MfOlHMZfKJR6hXrTpHb7kbx5vzIIdzND1hyo6cbcn3HgxTULpoJGhhJe+xP+'
$vscscx64exe &= 'URr7xMbW0fH2Ap2ENI7svK8xgUXYKPufRbqnRpNLD7/UcsRVOwr6ClZlwatawQ5+5epGhdl4WX8WsNDDLbd2S9jg4PE6kh/yI8wdOVFyEXVjUo0bXjv7HJY79NGNh68s5P1hDjbcTEwaynAypbA4qEAlxPBDvBSmFD8TqlG2g38OQrEIPKthZ2SNeIMuOe/9rfrGCtwu'
$vscscx64exe &= 'yeSPbmGlsuhA6GDnGnvy6EV8cJOWw6pXWaVt70gWSlHRpexKp6ve5SVo+8Fa2c9Jc5GcbFZ8Qnr27BMB3oRRY6YSOpOdAeL5h6mY9M9/LH44MH3h4lFiCg/n9S94/BPw3RdI9kbyfL7XZHpZ97Eta09c28nfiO295+JVG0bD/ToGbwb+iWkgPQp7S5Uqs+cN/35IOQ+C'
$vscscx64exe &= '6zcFoWjTuHJciwZs7U/TR7NJlUA8OAp/1tvBrhe/zAPm282B1DydjG68k5MD7DcO5sIa09nZD++nXRNvvjZ7l1aYk5Fzbw0m9gyMe5dx9IZcbAk6WIWy2vb9jutyfIvftRZn7LRqIeJEzAeLv2rc5/As/ajIP8A2mkJJQ1C9wMf6i2MixaqMonshEUrazQ5hhhx0aX6E'
$vscscx64exe &= 'XhJXtm8ponG2U6vX/ncycZ6IJJvXZSysLyemyM2yDDeaYhMYq2+qoMPvq+Hn4H7HVKxzdhCyWiiPQZm2zl9wfJFidYFc50/E2qMB6oOLKBO3kj0bSHyDCmjzBgbJLA7egsPk0xef12Jkv9jXPiEXagt4n0AjaOix0xeQ6laMjp6Uu6IcgStEq2JLuCYu+5an85XiW7rY'
$vscscx64exe &= 'fxB1tDbVtXVGXOjewhq853zel6uYE5EI/qb1EwAQtBOxZ67sXIZklsX+H5M869c2FEGRH8LbrrzvpGZno3dG3/+dgxBta2pzw+YhJpne9RcXvsXE98nofy8KzXrfiZ7KSC0mBQ/MBViORLHBIwQPxeiT5eByvbihL346o7ZEkE3CBwW58G7In78kYdXXKgfN9AAqRjjb'
$vscscx64exe &= 'O3Wo6BxkllbMXp/D4IeuCuCs/BMyIojMZqOfOT8hQGWJzci08i59IlVxyE1/c+mMfnbpkGvdW67NeSYHrXE0ptUqKoVURjeCPKbhp4RNK1exhbHXqTtGoMG2WGEJm39W9rhbPEAvGVWrp01yfa/uRfYpafVqp2E1sgzdSMtqpSYOZRUjAtK6hRDNCOdl6QSW7qtPV1EQ'
$vscscx64exe &= 'WL5ND11sMCxP6zeUQeyUqCBFzXcEInG3SoT4XJKnf2XMro8I47JXDVL1WuWZZU9N07twujjL3h027WYW+vRahTagJmfXMyngNG5qcvWbOYTtlIOvgxt6Lptfve8IZSeGD8Hua7n/lwbNRqCzOwlRBBz9Cc2LC7cBXW10UQAnBgcezKlOzzyodNKW1SLMGxf1gf4+B7pA'
$vscscx64exe &= 'EYpptcAOjrF9uio7VmTVUi50TajXf8NuLLh8Mu+5hkHPiZbWanKUIsVVNBPj0ICu1dus9zM9lrd4PT+SkK8FJgPUyKrTHqVb9D94lJ+x+oVjMCEx+PsW/42bDSXTOAoJflG5wei1/1qcrktvnYUHMLYdNAR29dpZiLZAieCHdWKVwyR98EGFsCjC69Dn97aZke4lZnKB'
$vscscx64exe &= 'aSfGM56Hn3mbj3yxoegvM1AFbn1U9yIEib3NDBx7uOoAhnM6fUwiI4aPknHTI0KMEa1mZPwM5CP6ypBT1cyxE0nC3nSZgCFRkf1/5A+2QQlaUN+lqI/1BSInnlgIzW9D7rpd9rNJTsWS3cOGQOV84RsdqqXQGepJJmKhrLEFkkDWI1sLPMxMNWhhD66n5wDCIFZTWjwf'
$vscscx64exe &= 'lVae4EcCMw5tr3pfnGn/au0zsTWm8X3QHPVf9pUsd10Fto9xpnnc5JsBsyClAqP517/Vuz8eHNWld+reYA8Pghl3BthM3HD4JdWm/UlgMP6ZOSSAZAf8O7GjkO6ZVz4mqxnm+ICbdw8dKbVNumlb+F5jrNk8hQ+neKU013eCYjFc6y1dY4jAkMWpDBfF63bPiTF4zD7X'
$vscscx64exe &= '3MCp25/KvRTyRSwOmJMEo46WhC35hUplxA1KnIYNNNfkkvgIctGocF6Lrndry6tTWYcxM8oGPRCQU+hhdGjQuCJTUzk9BHKW6tHd3ovLGSwWEbu/jTZLJOyMIj0ZtXlu35avY+R9u49A4s27O2EidkMbjMTKgkwhiH5wprI4hC0Xs5OMab49JTTDXK/m7IzzIUeklPgw'
$vscscx64exe &= 'hudEkgeqb+WBSnmX7Jsx8bmLVUZoFB5hpnrzk14L/gCe5dxeaF5MLcEINeipbcsyBXLsk5gzmsp/w0llgMYuGxeo8N1vXEhliXkQB7ZoIKt5eQ7B4hRIlKEbPLe/MD3H+Xm9p3VVo1vTG0sMXagvakZWG1f/5Qbr4xSQNzFjaYdV+DM47ZWuUZpu5kaMjeSRBNsx75DQ'
$vscscx64exe &= 'U0xEi3Pena7hSroRjfW43CUcMtYfdHDvQkgsjUV1lX4aYMcNLeEDmfgbclCGnI8b9EUlqZhLLADmz0zfMVDJquNPfR30Z3fpj1GqRDAUX27nWVUafblmvylFMVe6xRX+F38MqbOFzvZ4grvkhs5g/h71fiDsdN8hZCOrlU+9q+R6hxVHETzN3MAEA+mBHhgQWRwOyGpU'
$vscscx64exe &= 'xFZ3vce3H96RrEyeuoV92qKjuGLSimdnvczNllj+X4/WONJ9s12gjH8iWZ7ymmRNOUmU+2bdC+QJF2jLujyZK5rB/vlZT7KXL3kro7u24wVmbo/a2LtgtO9K+LBc+IurXB5bVABiTr+pCEgBgaa+SnhDVg8rNTVZXDoeGSVae1giwSO2IBEMs5TPlqIIYMLF4ly1ZAHX'
$vscscx64exe &= '3/G+JBdKtWxapnRGYA6GJbEByk6bJX6R0KibDxYAcPPK6ZRHbgaF7Nb7j7MG+Ljn9eypkyPQEM0jf3UMtOByOLP2DB59BOxuEJTB0vjEjna9bCQtjC1qIEDWIi5pyCmW1rH2+WuI3pxhwcBZHKXa9Q4zBwIrMk3OfJ1FkmsHgboEtEh/UPoSh4QmRzqZt7lXMQ42jSLF'
$vscscx64exe &= '/SebXEG+BZPFUCWk3VgXrmQzZzNNyrNqVv7/k9fiTp23dC5KzjEooUs6oUy0jHg1oDL59kDRdi/u/VQOBH7C6g7/kMpt377LsMdn3t4Cza/8SLcR0pbHYujZgxOuJXwPrVeGpJv+ALX1/N+6zPii+kIyVwuD9ervSJNC3mktY0INtgMSftosBNTUlbiTIBNIwv4t7iLH'
$vscscx64exe &= 'XcodQrHbh26OadD1BHnmnpik77Iau24gIg7xoUxF+5eNiE/L2U5t1vFnHKBpyeFs80vpCiQkq8fbgS9VRPOs5QgykIGaGo4TnJeqaFlLZS1whxlhqPC0BKtX7PJYbfnDCoA6Wxf2QCsGw6U927kA75DOu44MT47q4GOEUpeLNXko7OytM6NMPCfXN92aumUXaBRD5L8O'
$vscscx64exe &= 't0y1/siG7/Kjuydm+pYDamMDdYxyVGVIk0TWb7SVmIUI/////+F3Fmfsb8650nPiwh0NTUOhBNoQxE/W7CCh5KxZjKPGBpXfxCzhWlTs90ebdb586SRLSA9LKQ4jxTCk9unuGUzNwooDOdtus5kwH8+ieBXi3p1kjWC+QrTqyV4Zwogb3S7U2kPRedUETysMR2bcuycv'
$vscscx64exe &= 'RlMk8+GhBqr8xgKxHaCU00GLNDJqfcDPXxbRjJkJh8vJ1h1UvnkeJenNiCJquO114KdiOKOleOa0nWkKHHEJP/ug+qssgfxI9CNb+hfE/JR7rKRQOHxsl/PaxHujKZxGP6IYeaCtcCRysTZ78y2JAcn8nL3QcPslKmhAERXiyT8tihx7u+ZE1CKnNhjoNdTnmmwVDUga'
$vscscx64exe &= 'OguBjHczhFUb8Wy8cVOkJYtP873P6QtVxKMwN3Buzkwr8u1QM/9+QPrGDhBq6xwumgpb5Kxw09OSnyUfxh7itrAyqbMowUcIqccLi1Zz1BZrC1Xl9TzSVHc3rX70VjrnpkU4ERFLzICHYikUdAHXsDWVJL+75rQ3Cqi4EKFEePZYMQrZHrJJu1zbDzPtmgnlsgdjH2lT'
$vscscx64exe &= 'IA//PfGRq3a7kLwsKWDKYxZKkGO19j/rYso0tYD3InkW5pBsfYtcnVxPXF2gv1sVBbvbaZ4mqWVJstnueCCtZpOYh/QY2HvW1gFZDsBv9o6LxPrlc7awIb3vQklLyLbaMQi8q1WVTwAd6qLana/i19H3ooHEBDT3DTDuPnOeLkHFHxFzGbQicp+93vlkjl5Fo+kWnsG4'
$vscscx64exe &= 'C3GCvlE3KesDfJrAHJJfV61m0vTAXCCD40aKTFyIHBPYeCJ9aifDQBZBXncwljc+982ns85M2+IVgq6Dxv4n/DnefYyDvmxkcQ0aw+CpxKd5paUDc2LeBHwvCsqJAHU8SVKEnOwrZSV5HRCCxaUdRJX8eYxItmWvMm0Tu1ExJkS5eX8Ev6MTQBUNRScDyzyx9C1RW/YA'
$vscscx64exe &= 'SwBaKPLPxAkHzUOMLf33Jz7xIVMEd4d+MvAxHTFECwdhv6kY7pdYVuBf5+tlbwD+VtUQ23vySZzH4hPXDMc93TKZ0qaUNmwDR2YMM4PHR4srvxh0+afjUFfxfzE7Yrau/6DOoCFTPz2Q9NhiUPikLb00m6sTylOgOMiW6T9iyQGYP4xAYq4FScwHS80KL+kAvhbuOaXM'
$vscscx64exe &= '0T5DSNNUTplMNMraCWJLOdjnPJZzQK8Pf96lMnypkZheS6fI8e2sl5ZVOtOiZvFZj66EmqAD9/cfwFwQwdBLJ18ppXmIH/FVrCPhJw0F/8hVRFxW7GgRb6L/d0b7e/ip/qav8XU3Cpu5D6ixSDb6+prtVFrL2yEfDdJ/zP7vEX3MFpkQTaocdmOnc60sx0HC6tDOubIX'
$vscscx64exe &= 'ge9NmJhSiYG9Lq1b0/IeknA+sx4EoNssm4WyzVWnIgpFGD7MmeBYntRnMREv0+MBqwYaSdhkAdFvXddokls362Iq/y9lucPJS4vqci9ZOmgGazpfvp6sWt82LtSeU3vpMARrXUqhtCMxV1P7euvPsZVE4DrSqeXhdUdIG2loMNz+vWKz3G83JH9BfsFoNXvWtf4HQibo'
$vscscx64exe &= 'MT7wEdD1xPe0fDWJvdMns5Jxpmw0btDRntjteMAl0LwHr9KmZmOBhrLZL13Mk6wvw2rjHbA7tMeTn/PSjIhTCN6AVa4KK9ttai9Yd0kb6Ui/SBV4pqepYk7wmgp+Lic4P3kFZeb2I4eoZ2GMqfmWY4zbGLFj6Nngf8zqQzDAUqRyjPtUlktztVBgBR+1t/eLUnAlWL/x'
$vscscx64exe &= 'BNeLb2iZ5e6RPe5JMMifL7b8eZIjUK8j1b9I5GnAcuDryiXXAL5tK4HRP4MLoiZ9ZmW5QmSAWR6NRM4GYsNQvm7Ucl73nUN7LJXjBsvC/DI2/ZbC9UF947ZbuXwZeWzo0PBe9JrpxUAJjT6oeKZ5Zx9gBL840nXdQbNVNZzUIjwOPeT4hg5QLhHA6z0+DFKeUT5thzZM'
$vscscx64exe &= 'MwwLOXsI4kTQhlmyPebx0gQxkKPUqbNJSZ8iEWA02Ja1060M07K582jHHIssDoCHK27y3qL1GzbmMtaYJOB2o1fNyU0IphYQKa+a/ocQbC5koQNTNo5nFjXCDwg8uoitoRkV21qyK8a0Ez9RCpoxtnq+yOV15Gq+YfrNXnWHnxYux62foBtn1opsHu3FG17eZgra30OA'
$vscscx64exe &= '0C7iQzWifBKiBYsno3hD7Usf0D/a17LrIkjA35sw8aaALWmMOi4sVLLXVQZVS0D6viTeAajtNJhluFXXffFyyYIcdrxQzN5CbnQh1qscL2nevKbDdYqB80MfvUVSaTyrGHSTGur7P9QA1CD1diLso6Q1/8s/ce5Ap1NfiFKk+2kY+He8h7OTu11HtWX3eOz9V/0fZoib'
$vscscx64exe &= 'kJTKrTlgoNkkKAS3XZdj05+PMmHKFpj8oG0cEfLfbDgH3K7HxNkcM3PX2HINFVP4SIE1oue3tvFCa930RCVHjp9nMKLR//bjwtuWSjXWTUp7Ae+mbSZhV0Mat/QUnh4SfGBgX11v6VgvgQoqN31yHKHXi5kgDqw2bR314BtfObMzoeODsauOxq+ksfaDZ12KylGEbUpu'
$vscscx64exe &= 'catiFIQzVYwIiYwRWAxXZrvS9DfwZrT51hvGOI9V1B45hebAcZNH7Dh3VRO3EVRY/aIQzRoDmXqadt8yt4TTIGjxcgzvJVcJxUh6oYTHJkpoM/IuVqdLom0X1Kxf6YEcszsuj8KM2VdO/1enrc2MpTl1ShnVBi5eQ//gqerek1+or1vgpxLWa6tAMUiyXtmhp/6Uzj8N'
$vscscx64exe &= 'c/MPiL2hhcZz0fXLdVAEDcT9Lt07LJRK3ecNC726MzaamX/c+QhVv/iXTMVApKPzxuyeEtcZ8hOwggj/////qxSC7Q8wHxBPWGeu4MnBxMqNvc3FdBADfcO1jB5/kuZsJ/WiCLjRl9QNMURkmjIS+yoBs6S+h5FCXGEy+uW1Xz8OXS5RT+31cmDHYibwDL4r6YQZq6FL'
$vscscx64exe &= 'fwPrXmOCMzGcj2gfoZVawUZ+TEgRpnN2VpR4+2Yi7F7DsRiKoXcmt9IXUOojOh9M+dogGMPgfI14kDEHgRmEXB2fmo6r408xvxSZKO6QnSRG/oyTruBWnsiKyd5JfKez4zedb5pSXl4UWJjv1L5Hkva307kgLrbE57eE9dH9he8KrDaCXKCRjqts298O+YLlY8pmNe0l'
$vscscx64exe &= 'Ol5Fnww3Yvqh5nf0XdzZzpC98ltj+X45CyeeyvVf/kAigaLV0S3y7eN4jXj+tBjEl0qquG+PHCsSrXblAnMkPo0z5QcV3w+i1n2oELX3BtrIlgqrsX5yQc2SBu4/PYZTTNtWgMxfYR4XUVGIL4rvkRcJwfuMSaUy0YxXM0lkHEEKTpBq5kOGvgKqAVm4236oYZZvFapI'
$vscscx64exe &= 'InHtos/Zr03hjiUlK1kbB8rj4TyyE3HIrLDjMkzn5cilJntPFB9k20TawhPJy/8PS5IDyS+gt7GTYQE/S+TVG8A4xHw9sXKtBgdWpBgRvTknAUWwyioIXPZGNYuOx+33mdw1i8pn4q/zE1FxHr2WidpOzYeirAikoXAKY5DV0z+x0WSWp2XwUKi/mNx170Bwb2TE6itM'
$vscscx64exe &= 'AOhrt3X37B+nvxoD2uoj9TgQbXghwHNw+/d9TaJpH800p4bWN+O8e13po/yMBLB1g2AKWbnLz/8zdXw/Br1MQISYzFFulOVilEKrAwK5m13c4z9wcNroZ4/p0GbsxeN9imbciv6wZ3d2w14YFfzkvOU+zPbjUhtUVT2vBAV67QHfEyfRFZDPqGt/sxHv08oSuzLeJXow'
$vscscx64exe &= 'EUQsxHPSVwBCEpNyRqWkypI+14eed5I9Bp5GTn4YCxv6fnay9UYE1sAXaAeFfLGTPZPaBTvW1e7zhHni6Xk9KrOTfPnUUHvV8gn5aNbKsVW7YYdBErjdRL1OVWBmMD57cTNxk21TtaTe2gTsyeq3Bip9Fv6IzmzLjkYcWX8UV+iAEaaQGPR/lDRBK0JXM6e07OfVGt5/'
$vscscx64exe &= '0KrfSIPechn4gGJLjXMjbEajIzcMIfSSwMgInWRUe0Y/JfaKS4BQbxduRGtx1U9MRpmrTvAHYzwwu+JVE7lRjCUNH1A2eV1TKLQGhc0qHHFNpGQpcBjjfr4bSIdKERtgP5OqEDOBAKuRazYZn6bC6I9Xp6jH3xQ4+bR2XhaGWu8+eAj27Q0eBgFIzgsuf40PnBM+/j7z'
$vscscx64exe &= 'utiVMR7q7AXLxmsbCWat+ossSecufh1WqFkP95JSEsnu11Tel/avQd4hK8YTYhffeBERd489qWFu/tuF8C3vjKD+CmkjywHZCmDe+mvHQV3G176qW13qkcQXTFUeBRGUPtb5AIx8h+F5Qhyj/u/mRqfNAxqb+nTpXwdhA5pQsufi6tPF3Gr86y2VsAfRiow7ysrRiUFY'
$vscscx64exe &= 'ulzxajbDtuSm9jhnoX+8LQz5YY6nT6zlRKEvNtkpG2KJQcoSKYpD8HqWMDCyTlf3g7DNHnzsQCDq2KzWVH4YJJK1MCbBkP5WszEDhcveTFWCMg7Mm0qrrNv9oGd3/Dyaa2HF48ZwdjcVZtEJZGk1LS13pvxoxboltpune7CsuMvCW/xtocPvgf6wS3DZjdAQeyZ5Zkhz'
$vscscx64exe &= 'xaxzvXijZzbij9uimZuBg+fNyLbi0g41qJedUbjrLJlfu/ZUnzXGnDUI2WM7T3Qm1CBhFHypEBdLtO5BWFp9cL35Jx6Yzd7lTqv+JQ53RPhmDpS3TY7Ccip7UdKqF+iyHRIY664bflki4newiwiLdv72GOhxBaUefhvyDcA/sBUeOPAlSYydPD2rT+yevpX1zlDUh7id'
$vscscx64exe &= 'JVwy2gqcjhMgwZUm4zoK38C8XubHGXfD/lM+hiFauddnVqWz8Wq/ybW8El+NeqiP6ePGn9yZFMkh6GlpqXJBKQp3csXbk/WozuN7ykMaksQYzc4XbQEcR7PiftGvUd8rVrbS2ML/jPhV8FRSueehobkLSFsmDyiM9vYJubNj7npDeouYhcKeAWyyR1Y9VHUi1ozdYRr8'
$vscscx64exe &= 'MRDDf3lhLjj2WfbdyArIHT4svp8EHUUrgVCpiaQ7dJ0RogpVb95IToD+q/qH4iKVvHAbnIfL1NfUfWEdVoJa8dGUHuYaa+/HofAxpWzy8M8E0cRVNI3de3ggiZAC/FrPqOldbfgaQgLQpNgQjGE7scjNnc+yQq8zsyrIPaGqpop7BmgHjDlHYxnPk/tt5VinISEgbaAH'
$vscscx64exe &= '0lWddCsfNtCU7WkXCU/JbgYutu5nUYODItxZ33ShVa6Qg479gXLLAfJyAnXNfPXCUfstZJk7pXnHND+VyVzGgCmaEo98PB+YWr6Lw/BzwMQtbDRJrClfMS8mlfceQHckF9Izg9yX57yBKGTba7I4lAFbS+hkZNzmoHrWLbCTTBmPWgj6KZzQO7wM198wVKJiZfq6F6Bh'
$vscscx64exe &= '65sCnq/boGY5uuwN8tqwMGZGHz96+nuLHMHxPssNnOQhGlBXtMnZ6zRsEVMmw4asNHnYCsmkPiqrzSAjlXEBousYjB3ADQH77FxPRFssTcVBHt5wNrwyZwf8oQo0B7FrNtiSz31qyRfez4mUQlgn7gi5zMaDDEm5cmKXEuKUCDl1uB6yswW6IAD+OPNhj4VWV8ooSxrq'
$vscscx64exe &= 'n22bxOcJGpMmX0pgaY8bZdul0IJTb5ePHGUa31FoSky4tnpazMapvLp7hWXzsyPT2d5ZL4+npIV/13ycCP/////aIBmtQU1VimdQl3tF1CBh+FGGmhc5+DWw/3cbAwR6RvPjt3FET07Mi7aK7iJp+XxYawZNSfGVz93GhmRK2XrT0uR69VuM6Nw5H1cqUg26/4p/cLco'
$vscscx64exe &= 'CC6djbDgMbGJLIb+YcAxamWPLZMamK0JtYt9QgzOdZdYChe7XsopkxPRsZpz3Y/8ixpqTeA7/opTwqv/SgYQu8iO5AAOibvIgF3+Dnr4wgghKhC5P9sZWrz0OqIj8yz9QGGpR+dUIojuwqEnGXUg6Vw1TJxXjdD5WNTcIZXtrsMH8s02jcDMBHgqilaVdo6xAY0DsMn/'
$vscscx64exe &= 'fUUhbaLXU3Y6le0HhfR/kYj170azX7Sjr5brSdelPWlKmBJvrNniePfIdyKym7B9x5AmbR2QaYdJPbr8qMhnx/s/idnvr16O6y2VO1zhw2gWZGFjBuBjWE/PNj3YPLYaq3rvTFrnCwthZahF+GHzr46TrrO0DE8wuiGkDjN3Cap4qh2Lx6o1ojeMBs33FL5/+PJjdPhi'
$vscscx64exe &= 'Hl2PIyS+99hYbs3+D+Mh9QTkmLUmgrOp2tGZZ6CZMHEGqDEy7eIky/4hnij06XC7Ln8Pzc+Bby5Q32l2BkZU8RUxVuSpRjAnQIjmrFRAgUMHZcw847meE4vpol0TuivzDrdw9LGfSafqYOc+ubVhYBuOcN8lBPg3hbQdaD7GxKhVyDfKGZmOXSuDBrUESACmIKT/aNKM'
$vscscx64exe &= 'rotMOVhGL5AHJF+Qye/F7dtxLzxb0z/CtRrx/lfyDeROy1ri7GSpRFiBzs1Yme/gYdLAC7FydHHqQ/zutHo/ds5Cq6X38WM0zECtZWoYHuJGFF4baY8CBQ4kYB+QNTzU62ncJyCTQrKRRSsHZ6bnPFAQyvrrj9GgGV/oIracAxB214fZmKcHFhfmrA6QPLmgnvB/m67b'
$vscscx64exe &= '4+03Qprjk6bPsTrKeQg0JSR+gBuXnlN+zOTnblLMufU6EIjEfKRn03Z49NNCK8YBYuBYw+n0OOWQ9T9Nb8nnKxIUPSUXZkpB0MJkHMT9ZxbQUUrXy8y07CpABBgKF92pYPJnF8fd/yb8XvEr3xdC/E6uNXPjUjMWYZtfB1zrEGQRBULiXHC+WBDfMQ0XUT9iyOg9G0/Y'
$vscscx64exe &= 'BdT26tTAzabT37uV7bOm/DiK6V6v+tibpLq+fhhwOULvZYstFSiNLmfEfRdaZidM3fKZ2jC2VgMYaguY7A6W/nUYIZk9CUzqtS1azwuGnOiXqVPSl2zqE1KqZt4WpeFPnQBIkbRHkSwp8iZ3+gz/XbKWYtddKYFjiDxg8zTATH6K2kzVBjCaaeNWwAZaMlpo9yDpXwMo'
$vscscx64exe &= 'IUrYM/BW3w7GfWO8+urUMkDR57KCi1Q6qmiypWaPWzFJltRmFvtpqkY6+GafYuJO+ZjzrXlAJVG5CL4VdyhYynrTIyVDQGbWK3/eVtLU/oQ1wTZr8Pxdm3yCbxJ9d9nk0FWvESFs92iA0neAjRvN1sKYdHnD/w1Z+79OzWUTfLLfU9vUHA0lRsXb5qkQGvIPclmkg9zZ'
$vscscx64exe &= 'QjxWDvsRPd5Am2fykOAHeO8wiYM6xA7sCWOv+OfGU+vHZmkVLBuRimIeGVDv6h7UdN77zGyXImDIaY7wu/Y7JsZI3EwF2XTUkISAaXJURs37Vz0a82HnLk1+cE/jp+Ruda8KPALhHnr2UWGz8jIfAYVR17yKfk2hS155doGd3Bvdq6wtxocBr9L1FSQ1Vf60Nq6cqyad'
$vscscx64exe &= 'tcgk3yNuGXzDH2ghi38fZTr1R/4McGideuMsfwaoBDLuBZurr6RFHekCtw5Sr2Gmm4RZTi0AofqlZGGLefGprxco49Dv1zEeM7RQd93cgb1k6YdLnPR+9Iv9PKnZsoIOkflObTJQnk3g38xk27nNlF/fLSHg67KSYGMnh1oBjM+HR2toApbxcJWbuoOEjZZrWjZ9rSwv'
$vscscx64exe &= 'zAkFIo/M3T+5SILEpVP0uJ9hWQNH8RFPWiT5n+a3jPY07GqVPA5RZHadhlwLdh/T9wMAEeA5TtnNjdvoqFiXdXY24bmcNxqqTxi5ulUwNcYWbMTRKezThtUqPFc96zRE6kBH+AzPYW5DjDwJfhVmJxAP2Xij/8S+GbJzkrYC+0rvMNmONx1DNR0qrfJYEpPQjkfgTOka'
$vscscx64exe &= 'EYrtUgWUUNvLDCuwwNeQYSd9YD9n3It6qQSIW6yKBwnQA1Tj6goWnNz9vnOLd5l82klgfP2T/Em/x8tuCo3Xy0Sq8VuhdGcNjXMLGGavqfbRmSWdmquTIJejPtuzsRQkAPsl1nDrDfIOd3hHy+GeFwRjvdf23JaXY75Eq5NC+SE521Bi0ULpztl3LWTrw8AQL0yxCqhF'
$vscscx64exe &= 'VeExrRQomfXwoZxqsN5tAoosjItG/6n4Od35xfGOSvVG3WYzQxMmLyXt/+RlSwc4iFrdwqeXYUmnfXktR9mVQ4KMlFGed9n6ybrlG3buzBjIqVh9+J/bBYzGV8UwwztZQoUqw6VrbYzd9uAhc4Vad1VE1l7wy1EKjgXJxgvm/OzwLYJ1xo5NI33sr/IZDqldpdKaN3Jp'
$vscscx64exe &= 'zeznwYadFZVdnhHqLN8aCqV7BtMFF/8E2qIPoBJCPFc6jRq6DB2G+G2dPjsfW4XOOvgWcjcOOCVkiVsZcP/GXIiNuZYVsAAbSuz4qbTAy4jcSrdmIqgJGRLJDTQ3Zkm8t4eXzudCcf1eK4+L80viUjb9IxXgCSK+cg1uXLYleDm6NS5QmOhaNQTH6YtTLnS0D3fGBnTk'
$vscscx64exe &= '3qhVWErVbqUyN8MuqC8BJW06OriSQiWnBrMEFd3I7o4O7QCc9okq7PFvejjK9jNW5uO+suqI4cHHgUXhPHH5WinL5pBBZYfDjO7JFrfb7yG20YGKpFyJHB8qEzdzaIK3BDzv3ngXm52HAUgsWEISw3S2+kw87szuUbLcqCEhPogZbliEszwISI6AMELKD0jtVDVM0/mH'
$vscscx64exe &= '2HIVaO6Ald0ArD/9k9zpdPAb8Fy0nwM3tlUQvqYd05mkquic+v4n9IHrC4BBUnmz6YH4vAIZg8woI1IfCh+Z4vDlCKWsGMgybmNUu6t1xMNFcOlxuV8ziXgf1BRtlI4mOytcj7vDaJP4XvsS0A+vtr8Ae2XwwYqgCP////8Il4+kdRM6SUmDhUkS1NdBhJrdMHSgamO4'
$vscscx64exe &= 'kFjsIwgLHPSlk1QXZld7SvMNdkYTJE6fQOps6FFLQlNY28vF2/arh/aiEqQ/K1pcjj4p0q0FOeZyfUOjMt0VK/ObHQVUiANpeMcUOrjL0qRxWvhhLM1ycabmh/S0acHEHPjXY88dYODfJLC6UL8hR8lQJvX2u6SrmDAp1gUVH4cX9a2gv3ydK3dulX6JItsiWfxd1Fxx'
$vscscx64exe &= '530D45iBLP41iX64W9JbwYh1TLDz9Zw7DoekCKWWudlO2EZXqkDCjDkJCi4IrGZNSxze9kgunYt6eKyOO9ZEhsuqB4m8HwcbK67DO9QDtk9PlWSICVD3e7hMd7a3fIAJO6N+rLEkeChGbHDQ9gALb0Fof/m4YwtMT6FheSmfSzMU3ev5EXjGSUHZjLuqe+Id3JTqkc1t'
$vscscx64exe &= 'TQW2QqoVqoNr1hBFndLmujXsIJvTvCOMhzgmJw4zkKr8RRqWkY8Nn/tDqJsW7cwM30weThiodfOX4+9kRSfOxZx2gSTyATC6lxVjsTSRkuzPs9h5/8imXHRp+nm3MTONZF0delcTX8BzUzBZqXjYD2qcBnt0e5lc+aWaNsCgLIGImEZfSkwPd7bp+266g0LtV4fdXc0X'
$vscscx64exe &= 'Ob/GEMImaJSyfge1NG++rcdQiYv0MPZ6FVU/Msgt9XlKxyni97nRV8508t6xMojgcaJilzM0yxaIOFYaPyLZ7712kdOGod88MBrgtmYyUfsDzlNRa20qwUYgrMketgHyLhVfY1omCOgFqnLh7L9LfhOlIbMBiRMqCXj7o9RqpQISxwFOol4d9VqvgG+Z0Hriqu3lIttT'
$vscscx64exe &= 'dzYriljsC0htpzX0LVHzXHG0CPJuf+e0SEAgV5WmII0fki6ZbHwZG5QN7JfUAwquNf7jL0ByWhZg+KFezigqkB8fN2y9xM/2XugOt8u8reie4pd34QYwWHc+Dzi0OXTzLi0wltESHY5yWyr2X1KrkMdE/MBgq6+q8QVGy99sBBqHz+AeFPFKKQj01uhyyS6WS9uJNQbx'
$vscscx64exe &= 'agJMTqqGyp9EL6d/9sQpJYEToYaSt6mIcJgQVJpHPwwkCq8vDHQdqThTMV9WQWfhkp3bpj9TNI4Prb3efwVHDYM8HsrEC3DGrmT7OEpC6L+0W67AiG5Ibcc6ZZucYC3WYGijXTHLnQ4KoGKxwD3EH/hUVYb5iE2iwmRL78HSs84P/udKUp6gpGDYtp+wEDwr1hI/xiyq'
$vscscx64exe &= 'j1REB6GVAYwuGV24As31US5JppBVDjhsbkmYt6wcQ74QJNvmTWTMRf6trbGkL+ArCLj2HK5cDd0WazbX8AuV30sC9GWL+A3U5vCsPwOkE/HixeJ1mNN6Mo9n2jqQC/ZeHB04/v9bygO25Ro8RDu5/lLBna/AosJco6Z+nPC1MUXncdFNNonVfTLlmZS46VLsUZsyfCXQ'
$vscscx64exe &= 'fxokre7FFFfWJxgr2qc8qG4wfigQO+REG9G252EZMl7aLzNsXorJ3YVLZNAO1VPtskTuDVjN85aHiZRz20+2KAJR3HojNiy316KozKfKLriVXlpgZdx3Og2hGo1TFJ0bGFVlZNAWhWMzd7bJFpROyXcCysiAzDcwoATgaaljvzC77JlRZGPvNgFJERzcfVMymZxbDt3S'
$vscscx64exe &= 'M4thr0HowK3rvDtowH6SYsANKJRLAqInz9iyrE4/3jDU+ulwPJMx0/B0gn5jSujTVg+ZL9J+qSdYwRpM6h/lWSYlAfhmm95IjFyxbsKgs3MYk+lpgeAdeef/dV8r2YQlus5nvODTvH/ENjlQreiROWANUJainppumpPTLadHYWD1NUq8ySdKuVosqg+sWjvqXOYE5Dmq'
$vscscx64exe &= '5hZyG7rKZw2GIv2eA7vCP+o+qznK1vBmtq1I5lwXLDrNmMr/hdY2lGyNkZ/anEcKCzDqEYrwRyEQDaQtg/QtHlewj/O0ipbAqxc7tBcZXhus60QOKlo6CIy0gW+AIjrvBq0LOCtAkrPuTPb2r1/pzMjQ+r7yhR96Kfvrr+6b2ZDaaV8Ir9dEiU79yoaNNyvH+rq61bSC'
$vscscx64exe &= 'XZAdZ6g0+1RZyFZ7l4pHWQc43ANi/hn0sCraFtIvX8b4pm18QwwbFM1qGJSGetDHZgP9vEb02uid9WGouGQF2W3tLVJm4O0I3A/h6Uhy1e3uqYC7zPc2mNXHpqkLPx7i1+E/5zpZ8hS3E6Rmcglf6rhR1hR6W7oyYAlxjbF+YuuX4zfU3f74ALKG/PEqRjfdD1XDZYWM'
$vscscx64exe &= 'hN7qU9ZdEVvFtDaLdJCjxYTkvhbp6aStpP3sML9HMFthzLSZuSZRqQN6GWRpNRQCeEEyerHh7XF6nTCMj0vh1mhepyReySSqanM4UngJwk3yRdmXJt2ynj4eZBgCa26oD2rw79Dbqvzd/bQbDUobhte2tK6peVGZrl7fXAj+pIdRtgAbkFCFJDpDw8/Butec9X5xCyQR'
$vscscx64exe &= '25RnCjFjoBE/UDDR7xZ5FQUFV1Mg5kD4SSapSgB+QaKadLZxGE7llAvUDPbB68HVXriw9uCSdYAQBRnc44yYBLjHIBlgcIx1ZmSOsuHQI54caV58zxlJqSFiBS349JAf2pru4IW3kw/PK0D7D5Upx4TtQyxAG/zQcBAmYwsRdxi/ejPvZ6u15rOPsmQ47nFqbuTMiCZe'
$vscscx64exe &= 'kiAg0+ccO7G0VnFw2n32j9wiSjUtwqjr6qlgl/Fo7L3XXAfqUMEBGY/+W8Wfx0Z2AyRL8hUvBwT9ZWb8D3rbPVTqMCX7xam8EirfAEYrA1BBU/yJLARX2cRWYK8wS5KJNYhesNPq9U5AGfWpiModulAmgzVkfvFQHBLkD2qjZ6k0X/FnVPV9RT+4lTZcB1QPVGbxLCk3'
$vscscx64exe &= '7bflkeeEDfHlMZbGOByrlPt0sKQQVKpBekjd/ij7ypdlOBaC+pAqgfRCGx42L6eXxfWIwMlvGyanRrDENmLa7295n5H2RVrmmUMA9keb4xkAtSAtiwWenWM/CuYXtxs4abz8fpXQOTxBG2t689+o6J7OSy/y7yfNFlj+7aWJv51yXUI6TBu1Fcm0g54zIL/sKgS0gLfg'
$vscscx64exe &= 'ex9AjCOj8tCmclJK4DwvnTktKUoeTOFrQj5I+SFcZ0bOTbroMhV0vnyo/17b7dEOyfd5imJ7KsvRdkMWgo4U/////2cbAzXjLSXgMbF4Ns1NsgZMXWa9FF2AlUn6x4sHHYqrbM6GTETxeBTtgEeyZ6fzMYDCQPMsNolKIi93y7u60vU8dGxCNGp0JZoS7na9bxvapg2H'
$vscscx64exe &= 'yokhZAaKd8RoWTO8LOM9PjZ7uZUDRu00htIWtw76y/UZodxG2HTZq4081iUj1Gzx2uayFL2grOYvH7LUw/wsDg0yP0tm5dwttfnK5syeidJzHrWnoKVtkLkghWhSd0H/qMO1pxm3MT+I2VmNSZPT5B28wAFMkdtzFkBPz/ZkfeSVLDY6McgA3RAjjwlq2I7J28rDil7p'
$vscscx64exe &= 'SNd6vQlpIT+CGufqPZDGLdhqyCQKpD8gzfCi8AzSXx25KFG5SLORDQIebhQfdEBt+pCnkExs3imvN8AifRNsXzM16paBVyJW1g434JKaBk1t5bID8tNKucevpiFrKfAe2n/12pxUSfDTt3Z6ZQEOuC/moM2hhybSDc+wtmBBxyNPh4OhdzE+nujXl9SlOliFCpPsedIU'
$vscscx64exe &= '/YfanFUip7APeQ7yTZlnoPdU3f8ccGOlIRo/z74xyeG5dLJglBEWUqLEd8ylCx80oibE4Tc6ixnuRhWBSSCr60C/YPzKZjZOM9z61ibuHpeTjZv/0F9pWpvi7wskk9qyN54sRLCLwBr346QGaeDz1MqKCrEEpPS4adP4nMxJ+50buMnYmWIzG5nzwSRrz4ENnl3hwR0p'
$vscscx64exe &= 'TMv8P4ogpApYeWOsFRoqPIcBpW0nr66A9I8hsMj6NzTxellGVpLSegDgEHSAlfPUfUAvmsmMlqnuXyqGwGeLwrkS+YXfGMCB1gk42jczFP/EByyTmc7fwPDUn5+wfjdvdqmCxxcElNZxgQxfjbro0DMn14CaHFjJLD0Vl9bW6y00tgfEMc9W1EPw4/oWJXTZoBgokXJY'
$vscscx64exe &= 'pO+8MI5W5iWaDeX7tIT9P6VE/3voXreRpt6JBROYM1qqf+gzyO7q54XCmg7JAcUZ+OUtoEPmhhpLJc+F/LbTrhM80EfNexdajrV5AFcinQ3+7XEdOKCffGKipzx/19cKuH+icYBvk/kce9zpPUltiAgY1KD/ituFp7qe3/xKK6nehZB7IK9kVc/88Em9Ix+M1nrUk4jf'
$vscscx64exe &= 'svRGuhzcb4ecluHcP/Op85N7eUrvHoOyx2Tw0slvgWBc6lz+9aIf0jYXXvsc0gYA8+LvnX7Bm3Z5x9svOEuv6LOpEa9YzH8qUV6ji/BoYbf1SAaqxpt9H18dVmaT/gzhEO7rFNq51lGrTjKH89KPid7K+uz7190Cqu9rzV5PthDFBRE5E77pOfowN/N3hCh7uVWg9iYE'
$vscscx64exe &= 'y+k0LRsz5zAp/WqIsd926KGNoTL/gymZxKSViheVvLib7r6j2dg47Af9ETj74cqWlxku7dccGZlxDw2PTobpGwNympu1+Rw9YZCjeHGAwdyQJ60x5/hvbXe2QGAFE+8VJpdhmHFPuBKCjapaiKfXq7zkSL6DGoy7HkwSZa1irivxqzxhTafI+eEkyqjg5HXgUIpwwLTa'
$vscscx64exe &= 'K57dfKkP/+wBKSdRnh2FSBpZeyx7mQP456QrHeHY963fJebsUMPrjygr7fkD0nZwGdT5DOWRB5wEahEmGXcV7mEMCtB/YJp7vpjbwosQzdvJungv9nyPO0Lk9C9XKB7h3unw28iY85ZqHJocL4F0OBRkd9pb5vI9I9gZKq5l8iwfepKOljfrF9uz9N4IJDH4icj09cly'
$vscscx64exe &= '5+gfrrb5vY9LbLc7FYsbDr2mDHeEZQbyqWCIo3wXuWqKvKw7p3fxOBSLTTssBZUQNHZ2RFOTF5T3itZKNq5sQQNetv6BjFPwsGb84voFBuXjpP3AhgWQivreFVCY7uL0+NjzVh0ar7WYnDxklx9YV2owo5S+xJX6Rn/a/sCf3QciEB2/vwxtjRFY8o23OoGC2jGsM5Od'
$vscscx64exe &= 'GYP+ONy69mrp+BbPZB3xm2zFrFQLaBojfG5ZN3jfKL63hVFkvTsZbFqPTWbvIqtZgmQ+xzLlx4hEcIMC3VNN7B/UyC+I5w5jfn4BjJwlDXnk4EGQzXyLA+MaS3YU/whJuG9/8nZblPMsrg5IWvVf2z8rKWDUTjrj3SenM+Ib41FLwnFpjtpbKHj6nbDQuEm/duIveGK/'
$vscscx64exe &= 'J4DEP+BJMwvXcKrOb/Et0f+yVntssRNNwHXC/ehHaDrpEpXHxhl0NOxKbwed9N08xLFq3onDrfs8T+MarAcCiBy6zyf1b/uHpEYyx5upkAI6LJxMyNX6BDdJrogiPQkcBO41W2qc3zZN4TgZk/AxTQt4fp0kCeFZceJRp+VdyLyAF7ABrmFliE7A1TdqT9XG7zOxOjO9'
$vscscx64exe &= 'mJ2WuUI06A8asKVweqFTbjhO7j+HYveUprOyrQikxtH1HgJqxnrEYq8ie7HeKt4k3N6ia91mdPuyq1dfsXdi6HH6zC/S0y81XEBokltsxt29VSSYYMkGMm0s7Lt5lZL8Fabqk0qo1ghCX+ESdgjK9HWKOqZ+bnQ9TJgXEL8DRAhccZz7cqMeB6Qvf6061idB3ufKNEp5'
$vscscx64exe &= 'eVHn0u7VJ5GMeJmxrX6+PtaAB+j3SawfY8KVQzZv5HTD3sMt3NXUGzuQX1f0bDYRsruczuHMmoSVA9wKwxHijKYlWiZiAwjT4fe8/uRHCqNHCRV6ng6z9Tv5mSucnveub8C19dNCkCJfSsp25gYN5i0NSNZuLCRO5t+1bPwPK1QRJmiXD8sqwdMImn8Rnw3oZvo1e7KC'
$vscscx64exe &= 'eF5y0GqnwzJtpjqGSmq/aaNjUEng3mksDnZuP0JQzp31YBo/p0JSy6ELVD2PISqMzvEiz+SlgfQnaGGxSmG9mLTkwme7cITwZRipBwV/xpm38jpk02cOCSDorTEf1oHGldpqiXAdL2UWAtgYEzNwFvffNP6u42EglGMZLNvAD5awAg8/BHGZaKDlYFBUWx7As4WxuB/D'
$vscscx64exe &= 'idxcoSv45wzlM2xsUstbsSEh5Q4cdKYFIJuB3RUU6g7lNpusMXiwiD61yA8R1r7KoNLSIZwffSmccssdq9JJMzL8IQSCXiMGKbt0STCldUK9iMNXkwFOB1nSmn3dmhgHn3vNS8A1+HM76qKCToUFrW+qXafq48sjgcjmCzHwASc2TdqAFjP9q5uhu/Na1WoImWzGc32Q'
$vscscx64exe &= 'nnUXDjur9jYWUhph23TY3e/V8TPA2wq8rufWd9reG6PEOa55ypveK54F1G4jRAeqWjiY7ZXMT5gTWyxHN4E6FIWZFrW9sszY5Z9xmJ4ruTR3unojAnVJWTKYDw8TkC5EF2wBl46jZqHjY3LEQ7o3uNgnuMXD6Sb5nylvbK8xOQcqYsy1KSXK+IsCWFn2ctTcPHhAGU4y'
$vscscx64exe &= 'BJK/121EoY8li0PAaXVSvTCCyvIILBJXmeV992yqJKMV8u3TFuMDP7MZ1GB1/iPEAl7yQo1WKbrk0k5i4i1n1s0o18pEufWAbktcolE1h1C3n4egOLhRg0iu+pe8iDHNqNJDDlQvilaFCusFs/BJaWwbYJoCdk6NzFn6TXbLcDPjKjK/l4qtYY0+icSGovB0G2tE0D7Q'
$vscscx64exe &= 'EgoOvQG61qPz2oc7gfSx16M0r2/qBzEyAu/JSapHKGo1Ix6orzFhQYtkE4V06Z2mzOUTF0GjJulpVQ6mHmKOKETejNUDaT4Z4bo6FkUgTbOSFzrZ2ztfBcb+lfiYPg4O0KvyegbfalkEIzuq3tUErQIxO32FcNaAgaYKmkScKwmz7Xqmyia0ZEMH1FSuPYwiJE7oZhEg'
$vscscx64exe &= 'y/jMPyjbZbg58e1j22fvG0f/mte5G6RCjbgsB75912Dmi5f3MF/spafGR9sRusqjk+kCmbl6ULFg0f86fmaIBYzlJduxQ6bCrRtPTWE1RT3kN0m+BZ6PgFh33+fh/cvTRnKdYMGwwxzE4Q2FAUFSXufW2cuKpMb9V44Lu9DbwVOE1HHQldOeoNXnD4illjexMYQTshRe'
$vscscx64exe &= 'mz2S2kY4ZaUGOz1x8xv6Bb4GdYfCM4fO2Hyua+DEwgiMWtea32SJAiqzfYjEVXZZF9TSHIk/wvlhw3rgOhz9FUPLEQJrr/RV5B1gWYGL69MV38q739Xh15ijwengKrv3UP+FScfwLMbBP/L0wMulDWUGpRWfvF+hD9o7zG7hFH8DERlHictn1Q9qY9onX2dQGocXoE++'
$vscscx64exe &= 'A1YsBajTyGRdoib3OBNKkDvtvcHtQg9nps3QazkDzbsCrIXHDJm3w+xR050KkWoAVZzBdKCz+XviPkQ/QvbpRj1ezqgueqYRXUeFuzboRxQ+xjjz3zHuJeCrECZ3Jjw3dxoHZitQkl+pQuUP3dgVuPNGIe7dTCk07E6BkyEiT9bikC3YdT4SZUNP24P8sfzravp8RHhf'
$vscscx64exe &= 'QrWOOjsUPoUmPH3+yas+qmVbYj15RNV3Ej7bmmZhWjzukY+8h2esiYjmuAUF3eKm3StiRjbuCAyTmBvbTqASWRdBufuAQkh51/bHzwLrJGvJ60beRdmcvQNPLM11v4N4bP/BsUIBSJaugQ0E7pJRG6o8ifXKhHprrFcPI71xHxeRjr52rsZ+TdWiRAfJaMSh9/z4/iyG'
$vscscx64exe &= 'wbwysjnLNxwtrhDDZF1RIyJvea8ds+XPrJMeTPcJ2Sch33LBOnW4YOogq7cvreAFBl+E/MnF3oDLMZJ6rDkzw/6sEZnDVnTtziLXLSuUkPWOwKHtM+qpN79Xvcwo1i31/x8TYNAofKgs7SXZ8YYK/DQVzZaV+aLuQbNHjOWqcN1wa/n08AdKbLrh3KvM22L4MG/c4nb5'
$vscscx64exe &= '0CvgydUKoHin72XpIMBAnyQF9WNcoPUfPe1h1/cxJJi0BXjbKuz0pjiEzLRuzwjGqZ/RCTK3a64J5movSyMvc2pjyVs20ILvCAycAQcnIJ3sbFho2bThWlf8LGH+4HMLTYuCCwRbxiscn2Wu7emzWb2GPzAEmlBu4RfPRlc93dXb0ttiSv0X8V1aivcUH7WVo6pM0X87'
$vscscx64exe &= 'w7gaukFx5VjTGhqEn/5Eo4sL+sI1FVp0MraooEIon7JbjOvtf+2KYppNcGMPieQn/uDiR7DnLVhJgKEfPD050LUnKvn7IHMCfzTHtH03qpAQvZ1NiVgqZODQDzhUjr3ZWJHFUeQKonASc0WWqyJF+BHN8rme8+gBLlauCjpe+rJexBKLjpiyez3ep610kJ04jeYsXg7L'
$vscscx64exe &= 'VtK8Y2cZ6+sWbHEOeGDAPNiuT75FRO8yHa1+bAL+vUBv6ZihmiFNbmz9NQM+27/nlG+PjBpYpyKczAjd6ggCxU19zpGZdbiw1tiwoJXVf7YognArdBiEEGdRbKmLiWAfLHuXzgmgDbNKTtNKqmcJa+PPDE9bMffhE+PY3fgYPioLQnP8anK5DBYwtVt3QF1uu6zKeGRn'
$vscscx64exe &= 'iy12ANy1cX8u3Xh5bG0gN9/F1fUan72MbmNbYq2RfUay3NBKItaH/vrJLdCbVtSAXXJu/2BZjgSw61FoP2Rqqjnros8QdZsuFZVS1GfTNIpK065uH3SpFczhAirHVGS1+Bavyqzuqxbom3y1v58EmkguWJY06Xx70GxZkjxP1lyjGdLQU1+1n0m+jyaYb8GXVdCTHdza'
$vscscx64exe &= 'G75aYpK5OeGFTAOY9oTiFnLbhRVBA2dED2yZ+F+PCf2K1CYgQsPWHnVQMPO0viyqdpzJNjKXnxoT8XYsuLY+UU1hnp8EB6xkgQkTpWJCzHaspJiWaNgT8J0IyxBcMZiiIJwwbWffZomoZUHi7OejhKYUItdpMcVAv1j2UP2tdHqlF9abrBsGCurcOqftaUS+cdKm49vj'
$vscscx64exe &= 'RKeve+Zfu+RmyyGBRwgXhMHIimPtVGymC874vKlrthCnhZ2Iei7m1YFJtB81D16vl/cW7QSCD3p9AWnMuv0SSTuYVBiUDhm0D7iFa2bHrcfcDbQHIkC3l9oBzsoE915+toj8k8ktav5QjRKOWLNc2HEgquKLSpy33hWeoienKo8mRfcgG8A+lVi4atU5TEeOKoNELNVB'
$vscscx64exe &= 'mpNvq/IZ+Ds9X/Z7U9iekq9CY7ZB1mJ1Z5XjASe0Y+aL1gN0pasRL7YR6fcR/1zVX1v7ENdjQZ7dipOROvDqB8fOD1Kj3qYlVm2m20GeoDVEbrKP3GWtAADsLQc7F9ioIRPo88HwOTJudx6Fn9+GNXeQwseZWxIqRVbN+axoxmDij1THVzarFOuV40GA4QWBWdmuYOp5'
$vscscx64exe &= 'yMhAwNdAqWy8RNIRCTnanY2bxhoHOKQjrfPb/IBgQwhwLdDvOLGgLJOD9kLfnRNbR6Ht3m5R9G58XQGceQMwV6dd35XqiCvNZ380DPNtmG/vmOQwIhXFeoVY31+tJLNaxMcDcXQu1dpFs4UiQfrXT2wWCYSol3EKYASoR3aw08WuCrf/uaKSJ1FScKmEdJ/CgIgZBFOE'
$vscscx64exe &= 'e99TEnlA33TIqmiCZ7Ia7vpvlUMQbpCPmRg1cyo+ZfsDODIafmGBuOdjkgBJa9mwR/TUtHRnN1ERxepIdt8StgSyfuJYdT/+m5O9K/SH3TCXLhwtgMU16hVyxA54faiZ8+VxWgqiLKh6uhPkL0duQ9OpsacWhlPF3vlsphkWyH80mlH043lwt8eQVMzoJtVXFdPcQ+aO'
$vscscx64exe &= 'wasjU/MZ+4VNGKNnMOLAYasE3FD86DoovolMN/Ld7wb16bm+dwgvx/ku/KItIuK4PO43c9Bj6V9XBJAr7YOHoXdbQaXNwtxYnyqcqusNx5vM568pAzLJtnKUTwSvO8eK6zW3aNxMyJcLSlN/B/+Kcp2gcOq9WicL2/VF2H4XoAo8jzFbNrhrxmw8jWNqOKvAf+nlbg6H'
$vscscx64exe &= 'C9pR9Cue2lrsKOQULIe6LcdKObCDbkLSb5gmejx+0evRJ2eNfc2cxPWGCfRhARUTtMkmTH/Pxzq6RecW1Ti0NdIi1egNJC3W46Mqiqxq6wpjBZwCGOjMHMcgBGOe7E2vxl5icHCJjbNFW58SJFhpku2PQfeTt5jnOwAV1lRr5T1osYxuDcRpRiz+1fSR1V8lCE12Ti92'
$vscscx64exe &= 'tZY1PpDy1dt/UNvhajxwW240II5k50SYaND58hPSeX0qcCeliKdy4lK5Dv5Hl/7z1yXQh7Ixogsj9BWe7rUjiVUWkSf6CvhdFYlx1UD8CmLYvhD/////3mzbXfQSzmZciHG2WjirwGpJdE0OZlrwc8ayTzMo4m9KcfNUoP/ntNMHtoy5LBHGCY49Y09nyTCVEbLtoikm'
$vscscx64exe &= 'D6rrXZgEfEuYuQBqdPIPMuqtGWFcHE7BiWnF8Pivb9izNWc074XF66gYJ+NWBE7k7QOA1zUA7Lj2EJZiqjzEyDdSzg4w1OKB2nLdsmH1fH0/Pb/2SEm+/aJad/9Me7DCWDMT5f2Z5aH+pszTInxKMYL+RZmJac+bpSs8rY/eaERqA9QSM9VPnycevR8j2eU3gOw3Gp+z'
$vscscx64exe &= 'RlsFj1EfBe/eqntRrNNxGUflqUgBqzn6x0qnwPIpo6ZJF0n/UtM/Cbq/lBoxgEqUGhdErG+GKFmwg6mRbrMLEcvz7ObXTHUIx9ppjruGQlR6xaUC1u72kWMrfXVF+DIGrlNMdKrkRqp7PwZ0j4vMKkd6mNasQ8IhYiGQm5g219L9S9Il2mdmt/SYwoNsSkpUQB0YG2CU'
$vscscx64exe &= 'k5UkewT6WopZ8K2eG+A9MOkW6sTfzbBlNsrjcVfdVGEMjceJYNIFa4hxagVUS0KFPvHF8jeoZMiF+iMLxv1jJIdI9HMLnQSXlJIZVYbY4t1T6vpbhfKxF5mrOuhNvz+U2TGohoZ3rj/wJ0B28/8HcPMNx7qr8c7oCiyOh2NBLJWWlNfvKnTQTnFFkCjmHEPqwQRS6nJr'
$vscscx64exe &= 'DwtT8iVi5gTj3iPcW9cW5yxzmTsr1ogy/MApSCTK0ey+AM+usjtqWcAOWIKk2pQ8Sut5pQW3dF4bcSNsRyfiMd8a2nL/AnTDPfBk1cNc9i2I34Gd9ZfVgn/OE89auduthk+Bu8L+ylajCLYBD3wZgL9/cke7MdvgCYM5IHnqIuyhyFuHnpVSCAneLlbibLOoVuLA/uRl'
$vscscx64exe &= 'yF9+Ar7E8HQxoFzX8GOb6unMw5tOzt0vxyh1YJMCGLrnUWva+zUvx2bNTSOC250OKPoH05+4wRBhMHsdaRVIA5bW4VvkonCZwqpG+m9zBa35zD0Mc6M5zj9KMdbm1UOYsKGVt9xMBS50rZdxNrIBKytuiSKXBINcioa3KsZ9haBWBU8gPELMyZZ35ZvYB6Nu6pk+MEkb'
$vscscx64exe &= '6IlW9ju4uc88UufQt8YDQ1a/skQYHSeuZY9daceH6Ij9mX7h4i+UAvmtuQnPkLdcjpZ3HcgNFGL98XBY8ljuP1AK5lo98sG7LRm63bLB5t2e2eCSPjbwQJ78uAluqIO6Wuq46SyYtju0dYJbjgOo9j1EkDxca9QlMsxb1K0jzV8zWugPZfCQx4Fg3ZuBtvrcJl8DRair'
$vscscx64exe &= 'dtj0ItU7N00Vegy8UszAYoneNuMA26V1dhoGsCamghXzFFCIZqQ4q98GR4wkahgGsNK/v83PwFnUhCsObG2KGy7Vw6Gtw9uTk4wjlnDTF47Dh8h0sK3OK5hamBt9g9SnxRK3UfWwS8PM4oXGLH71chwXyhSlK5bCxTCFXT4Zulx9WOEx+6ce/PN6KtLuRNmu4RbaMSEq'
$vscscx64exe &= 'grAPoycy8cAQkH0hE4TZQ+kEf4P6Xs8cvylN3AIEpCOVNatVLvs2AopmexIEhZfgOXzCHjYhOfqcNX3NbjqYodGkMnrioYzU3RvB6w0nBo1eztSKd6Mu78KupfSTvOHX2x6pCHvYjFyoLVMPg62piAhJUcAEKgTBScn/jYZn/6zgf4QlQx+QPQyCFpjJOdC7nZZ5OEaS'
$vscscx64exe &= 'Sjo3YBDUnV1bckAxhWFjrrdwW5sndx9NguAdqQKErT5Em6Cn581NVkqwED7NZu4x5eaE922jmE5cL/djVoDozmwliGfi+gx6E/oyW/ApCU3IteOSFMyobZEFLydSpeFnNuU329KH7nP97gEakECSQTBjOrHqh2JjExILDj8ieIgizzm25b22vPMsAwwr3ZeLZhruv9Qi'
$vscscx64exe &= 'HvOuoq4yjRTCTFsFzrx045zqjAT/t09DlSsG0+aCS2joHio6rfWX/wqS7hAvuOMurV1qbAFoOF+pgpSIsazqL7VNZ7JG8gNsM21pMszArIHtHpcamhhZXYi7iJOLsxbVjMAvoYwZVvtOaOhJFsAx2HeYYoq15LtrmKzhPa0YcrbiebI+Y3UDGGTubMghQJnGk+TGfOAn'
$vscscx64exe &= 'FzL+DQOkIJWXXcKiH48rVmKWhlP8V8EmZPKkcR7kD/UK9gMMiA+tQpInVoNMsjiAu6GimoIvex5LrZBDfXDxa9HkWeTIxU+co0263UY7aSgc26jmGBuaFMMNL12YTreBIZG+Zv703fqMJxGChf6ZmbndlO8i+2hJfeLL8vhE45zPouwnj9vEQZMSDsDitaK5OX5zboiA'
$vscscx64exe &= '4YqCo7Ybm1ZtpvJ+46hDE5Tg4UH5eoBI1wtWMM7+2hdBAsEyW2lzGno5tzeFz3eGt6tLO5klnqQ+egE1b2HCRejjqHDCcX7qJMVIibDxP7EWGW+Hgb6em5EOOFH8DfpGRKOj8aO0cDA4keJyakr57728y8rgAdXfOYc26KwJM8DJc+l0gDxlqktTq1L/GP+n5Dn2wDmp'
$vscscx64exe &= '/DzEQi5HeCA4PG6SvmoXsE5wOEvloZ5lCFoVHbq07B3vMjIj6pVAJVbeI4DhMs9wru0De2rr1kjbHJMf7A9dgOw1kVITLyQfoke9e57z83WSsCUE5fTci1ZmHxOSxGQrEYpEG0JYjRoELNBDfRyASVoBKQaDyy55cFRu/H/n0hwZ7KIKJyAqQ+GPNne3f4Kp9I9q5kZ/'
$vscscx64exe &= 'Pu1vJFa87LuLABFMvd6ztjoD7DYZpmpLVKHCYXM7Hks9N2lUzy7t8rry6SG7WvI6FoTUAjMUTOHy45AlG+6Lh683qt1NUFBjbW0XKY1h/e1nQ8/yFqraXNUBhX7cucAU+VTa7naM2KTLBen8I1rIquUjNt/ePRv9/OVqYyX6wt25tthj9vIHZcAG9xuvE3GFa5u6XoJd'
$vscscx64exe &= 'VAU8dy3nSE3EljDJna6LiD7YGxobdvfQ/Is/OfytqY2RLCfj0WoHKIUbxJ9nI8Qw10Z1r4nHpShUDe3Ay0N+lnz64sKg8gzlm8aoGsBo4k9Ehlu7qfTxno9TL/qbvGKhfWbJa3uxNcUEDqkwQ9UpeIRY0a+vx2OsOax/dh4kCSwUoofRuqkA3f5R2Y5AQUzZaXP09Q8s'
$vscscx64exe &= 'Fd1aXflSb8++tS1XTmYWR0YQYLG//0lc+FTbJ3YnUA+kZ5VbRNtEEhFoQbi/+BVUpl1fSCQYz+gzvCXc2j/zvxef5TGQwKVahxXi+N5TQpAP2n2PCltd2WSVPCuN5suXJlJqr9WMnWTYWB+XjVU9E2suvdV1AAyqeqsAarPyeWn87zVjTYxB/Xr396pJT4SCapZKMzVx'
$vscscx64exe &= 'H093h4/FsSIb0zKzJHHtmVgsRIgbobW/dD5Hq36xeQUUkwBhCWea04Wefb/JRbkDO3nKrR1l1LsTe30Q4M6jbokLZBZOpaHUrUI0LdQzlU9FBQoLQSDgnDAWOmdQ3ZxaiDx9UxzlKaSjzLWfjowQDyVY7CWdE+7uabLIs7WO4WGLFs5O1Qj43jDaxXUk0XugtaLmmKBD'
$vscscx64exe &= 'nIfIzL7pb6P3KhLgqF/StHDhR1+GFR208E0pIFRKK2xS4ye7SeefgRgSLZCuHB5fNBN6JTwrYzCANGWpKR2NfYlRH7yLsvzFRwPnuX4/nXdp4uWU82vIpf/o/GMIVJmqLRwEKFebadvkTXGfGv4PYNVlX+cGbh185rGdEPnI3r2LFIl6Ym/2/lg2i5KpPA17kJxsqo3P'
$vscscx64exe &= 'F8UAGK7hARR2uBe505nPkclM0+Fq+0xKkRO4IzRjL6pQNUQtlRtBwTbTi/AI4cr7MucRBZb7/nSiFLCbznpn0+Kg0QulZjvFvltNYSTdsQD9CgxnLILOqh22QZtzwV8Ck0BsDmTl+fONRlnFVDw6rk0xM5dcgUGhItTKEch0yui/MpvwZ3J9FUUjEWO/iNNuTOjcXZyX'
$vscscx64exe &= '+T8mAM1F2exEzFSJbW1EGEMN/FDJrK18FLX6LTzl2MP88LJ64NWnjJPBc96t+atmQPjXhOEju8fDtIr/D2WfG3O0xJFnQxgMqMFBf4R6dbRbiVMo2yFR1b0EanMa01gA7I3y+8tSRWlcGbvm4Y4Nr9fJGMIBmS99hHSIQkE6q5mF0P4fWfsGCH8lM6apHjMF6FRQXKVt'
$vscscx64exe &= 'yBVMMN5fPMf7W6ChfOhwU1BOKFvbOVskLJV5dLW3wYqBiRF8SNJBSFITwXHm+R+p8yTiyeHazYPXxhD6KBi6h4dsIhnwVfsKRlUSWAVXZR6xVyP1TK0I9NNpjmH+n8JUOGQXBrF4mwtWjkInL69bY2JmzQd/a3lVOAUEOZJD+oO1vKoE9qjs9WLUpF8dRm0UQW+1KMu+'
$vscscx64exe &= 'qETRi1JBH2pGLncjNl5QlKDKixXT2LQxU0aoySCacs1EHUKn6t3F+RgiEKmh4k9a1Iw9UQy1MDFGqX/BkeWsf8doaoqVvAjqwnDrgwmhfq8510REU1YFPhE6XlOYhknrzqWqCRdtciLMHEZB+PG061dJpJIyiQKNALLLL1/9JCk/D5QZEl91Ev0HdoSlYdAoyEokrWvp'
$vscscx64exe &= 'yQdyscP/Yv0LvN5m3phIHgVLpD17bEC3Y4dwLDU/6uo3hwyWEiEJ7jqktfOUfdG+iV5DsA/AexW1BNmNuRHi+oVx1pDmU2uj48mDtfgPrXDbd/dn8DisCa3ak8mR+KHGdxMrJx+KD6+w4EKbJpA7nFWktDsmx+4EfyFUKWuMBD61jwuYahJv33R0sN//t/GZb4/Z+jqy'
$vscscx64exe &= '/HjrvFslzmXTJC1zR5BzSB3awyTGlrmtbEqCysBN9LWphNeujDLoM3TLUWDP0wQ2R/bZ9YTj+mQCOoTKQgSUIZRHhzrkgG3OYWzjiWwlamSdhkpDcUTysBbpDbJtiCN59mkqJLHvsnox2CFuwYR/aIRVwGfQ9+d4I6/p5+Jz/a0TveWzqd76jJqAbM0VMEUlA8Zj9fZk'
$vscscx64exe &= '+f91l2DJPhjbaMnCf5kyuJdvfnpuhMgz5lDiHGDpLTH7nglrVIkG0bffgY5B1hvSKmWkCyreloQCyNDx/5VtuGDAxuMSn86UOVPejXij8erIepJo0UK7X1MSzhUBRbwZQZ9yQ0FSFwQYZfVjEnKtuU8DrfsY4otc1jsa7SMjkfp5EXtoPDk0qSBW2/5n3/o/DKzSngN1'
$vscscx64exe &= 'g81JEtPQ/4+YJdo0lyOSrvhEqBOmd7hiy/9LD24zl0qGtBizxC3NlI3UCvwM7KS6KZpt0JZj0EjbsUcL/myTjz+o84gUoQ6vB3LC/ZP93hxnvshSzVvHuympdDxSY4Gt4a3yRTvxXgQ1x11F6oQquxWtOGo30fxaCEA7wxN316wSd+ngQAdKs2WYOi9kQ4A0di1XBZCD'
$vscscx64exe &= 'ssXjmys3lJ0okrQtszUT9Raojg9QcZQkSs+X4lMJEaW/orLLgO8oZT1k5y4zVMu4EQ0WcFxz6xgfxHa1tpXjI+ir6eoGNjDIIbLK9x+RSWwgQCgIT2YFO9tbMHwCr3VnxejYLQtxr2Xc1J//Wh2vLX0NPymTO4WS6fU7XzpXSuQJe+vcPOuU/DGmuTAAcbHGno6f2EUo'
$vscscx64exe &= '+7IVvOjWAIJmVF08CC9hm02HKQcwiWTn2CX3u9a+0LCS4N3j08H+KtwIGYd9pbwd53OCPzB3xtIuGRuV5txwGA5SrG2u/cOV1zNX90g3rhY1/V1OFJyQXlWoGQhQVAhjnelBGyf1pdKtgTG7phg6gMkET4RJEIxjauCPk6eHhlUJzp34jxDwfBKzTHbUNj09ohZAnMC+'
$vscscx64exe &= 'm7Qr49VpV7Mjx7Fq4bOGWyy7XMVnji/JCCsnuZGN5DEQabP9knoBk6g4cKhrUTnzhVSdzqWHx1T5yAeNQdYL2utladqR5MLnWP1hGtI3TLepQ/1Qz/i+d3nhqJ9JVCTFjsbk1mZWAm26v3Ak+YFHJ7MRaGN9DciU1bdXgvLqS8lY8FWZBRn9ftCAiZqFrh4o2U3Hulxc'
$vscscx64exe &= '5ckns2/rt+sc8qisR68MLqkqCjosUdwPbq14zsDor5NnuuitzxXdALFf7ZwhWLXnM88utWNRJBsGrGTgHTV0AjjPGH1hITb+AF+Xj2EXXADp1wJevxij4F4UdJbkoLz9x21TrrrInxVwYb57oC2ajFUrfogV8r0ke68dT5OmC9dhuI282VdScSB7rW1tVYZagyoDUBsp'
$vscscx64exe &= 'n8SorcudcCGOJq2KdpqKSblaWSfSDvRRiWMgwB+K89fGODegscRnymoIQo28cmce+gu955ZansjbzHFA/Z8I/////6TrPvrJBjSvb4oLFL5814NK7MzcvLp5LoKXfeMji2d30RIi35RqiGlw9HJ7aFYX80R+V72NNAcRviTyokgLBEXoQYoZBbx6V524Xr80To4PoLaG'
$vscscx64exe &= 'ImAcA8yEoLRN7cKSvHDlrMQXavkGbPqya6f/dRHi6q5dmIwHekWkyQQu/npIp6vhwLYLzUIFNIIRs4AQ/4EroJuqouvcvX4l3q5q01Ioq6w7VCmj51+9uUt+ZE7+XgDO/isGXqY1g1nJyuouPUuZfvqeECVtxzuig3kjOZheZk6d+gUwJEap8XpJdwnyCbvuF+sqfIP6'
$vscscx64exe &= 'rGTj2l83Erzt7C9WKd7Sb+sZLz55VB8GjcuczYaNDVblSNAfumSSbfFHLlHcMZV4lDnfEHe5jFicC72Tslu0TJYC3MdnQ6AxNlYNzzhj3eT+mScVKLAFxM5OES79aWrXAJexupAULnDEECr27G0wjgK10hQ3PCcDf1gfAf4JeVfUBmeqtS2iWHW5L2JaITQqdpJDL31c'
$vscscx64exe &= 'd2g8Mz45xN8sIGpt/zXaHksY3Am34Mtvr/HLVYj3LfQFEXhfN8E5lwnyvKoJ8oyFXl7pa7zk0PRnwchommcoCLea3/43yIcsCCSTnziAaut7Phn+Ay4UXgpzDXw74vGsqSgql9nuWlNsXf3wCbROVntBlxqfJaH/aKsYsonagT82HJlZVzh63injKgXleU3ywaRYTIJI'
$vscscx64exe &= 'LQKnl8yn5R5ET3v3hZSlhkP2cE9v2rRTSk3cjVEoxDzXb0k/8zqN0aLsdbft+qZHh3Easfg8ZRrbgf+esjA9XpVjItGIXiDhhTQB3Mn6kUqYt7XxxtSVNFpkPE75Govkj7tCwPnq7jbrzs8I0ynUeks0yH4bZcblhEZ0d62GkFSIkEnjicnSFLDwrjN+xgztI1TeBDRr'
$vscscx64exe &= 'kJ2/5DWebyWaa595R8B+TodiXMcInYw7hPwz2neA8LgtcNz3sCvUhC+c/FopPKAFoWNciOLWqjYZYN+YLqdDOMF3Ih5epYAQlb3H25VRWP8ssvWHHheE1lnyWBOwbeN0voHlsSxoDSndt4DpR5OFbxeNhTww/0xID/wU1tNf6Ll2Au/1CZ7v5C6rSSXRgvgMMVsYBx1Q'
$vscscx64exe &= 'UvXxEQrVIkP+t3JPXZsHyaotK/bNkTdqh9fQNgTmvxxVRQmQYjs3K5hv/GKQtN1tbO6TyCwFuxTzMcSNea5J9ACOl8GGqYXN9llWfZp2A+SLOTj+0jNX8R/S8Prunmw8GzLVBfoKep7vS3+9Zi7wv76UiMGsY8RPlTtCBP/Lhzn/UzKOSUD4iUqP1aN1CIpk2dQRdXhV'
$vscscx64exe &= 'hTsLFjECcQjC3O7fTY4QsdPQwfVl00L6llvCeWRtMGMrb7cb/svqPAZW1WCPaD5wWAyM57VxwFQTAEalK6s5iwkU64n+samEszsi20nAPMejOOpOjY3fjcdPRXD8Yg2NcgdjOkCrw2oGQKfYcbwmLki2tnePJv2PKas53CV6ndNR+9ki6ehjZBfa3IHayLR9CD04ACz1'
$vscscx64exe &= 'uJ+NED3oddfAej+c+AbZZti7/tv40xBpO4gxwfQl3pFCZWyQQZT5CCGMCQjYLqMOU6EJ1Q0wKAw0O/iV/PHf2y59qWOVeyEwwSpRvf3F5lnxFv6JHMRhadwKG4Keym72KJyc/dPGLd4d2QqBzEbDPUH0g/pnzyX6srNDZ2fypI1sx/GLS7qki3TneEU9V893r5K+QOj1'
$vscscx64exe &= '+uIiwQ7ndMYleEEnSA3fMGJU0fwBcAoZjw3spX6gd1xDlXfGkca8cFEP4dbZ+Q7E7CC+31W9YkXMno0CsrcOkD94gApaOwLaoXSDmmQIDF4ikL/v/3u6SCNhXw1x9NOpYdQXrIV1+Cz7vJ5aXoln93Jzl3B/9Nd1g3F3x+im/9BJeQ/zma2x2F5pu7Gv3yzz/3UO9/kY'
$vscscx64exe &= '3t2GVa2rxRlqrpQspzyKXcwzmBZfYwo0ppSX/64tuafCzRFk5tf/iP3HvleCXpSx7r9PJYKxPZIs8giXFWjbmfBCYfH+nAwGTAdsawFz3sCP9U6KBApHHr/hbW5QYHMjD0kaPFpgwq2AAce048GY7WAzJ9B7ml8CIx8w+qZjVubqSa2Z0080LVAj3s6jL9aLxnQaLDj6'
$vscscx64exe &= 'gNlI5MN7Dczx22j66+DhYYzMDdkRcDMOYEFnLaDSItRdoVLP1mQ3NKJLXKTi6FDW9IkOPnHIHQeNUZw9iyd+M5nl+QjIikMU3rscfbfgLEEz/Rh89JlXGitbAonkN7Drebv6OKUGH58eKDJN2f03xglm62FltRtmM4VDV4eQIpohe65KxVaulUX0D/GY0liRZpI801kT'
$vscscx64exe &= 'o5FOwE11gtEV1TwNJqSce2jWWhPvNz5lPbaXMCUiSVvTPaMwKDDDTqC1glnTPNDMUinYwHeeYXBfw79bWIVEACaHbj+sFK3odS3bpSHM2EDMSeD41D0Va77NgcKBXuVFnTrOJpKNWVP3YSQJey2Jc5jJEXyNAUfXjUebK4oDl5Lek/CSyHVB/nZCsLqrB6/5k6wTgpH8'
$vscscx64exe &= 'rz0PH15GaybX/xxG3cnDfrj05AgptooVNhSyqMjDYWZ091n3ZHqybe5n0C8ggtLL2/XkYnwbL/z74VXIpC4avPdI96gnWc5HbiLgLW6KGis1S63vzWP1S6GugUWa4hu9ZfWtGmmaRopCGBihL2axPlv/jW5JCIs6M2PZaTcoQFG0xltnyuaEhXVcTMnauvJNdtCHs8+l'
$vscscx64exe &= '6ua6NqnovpY8X6Pj0JS9Ec+VenyqkXW2r4BuYsjSYIVgjvMo46VpjOShlHpqpLB2GeTBknqIYVcZhKycCcc5ZuVi2J0boCpKKtXyPmLbVfQC9IJj5HE+s3NxRGkNzt76GvqN7DLvXgZmgnziTaaX9f6IInUk7dO2VXs//fOHhoPiorDURX07heZGVYjr5rTa3yZKxTkX'
$vscscx64exe &= 'EYIKXpgcIkXTV+dZzokp4/Ua+COCQAB0AygePeden+fOSmI+5xPtrEIPlrbVcVC+7co0e1L2YLL3BnGSsZ9jTiS9XWnPe4Why2j0tZy5sqOBltLA5yedaD0sKtpgF0+mZfn+X3LPhtHm98ouH+a7r40PIxV8GBO9Vo72H3yhFplo7tWXqi7aK6pXCBsI2jYAePEI////'
$vscscx64exe &= '/73OlIxYJVBHOUO0ZITR/4Er0cvq1yYEeBh1Wm0/5mbwXHnaZMi+AR75PIDbJOPwKNJXUsWIt9kVsPFifk9UYkef6IAkC20r1EHTshKVDk+LDsNZ4ai1I2oo+pGGfzN2uWjVDt9d/+r+ERDIFONnznKgwf8bpFTtaQrcp0f915vT/gFCF6d8inwiX6Q0e5vvwWyttSl5'
$vscscx64exe &= '5vzN7sKQLb2D5OaCrTtVZ/fAP4pj06Xp1Z7cei2E5zLfVQADOFviKjxodPTKkdMOeX2awSjWPBD0iAqvms7/ANJrilKRDJRIRV3fxOeo4aXepy/zq+SFMkHNkw++9X5orRnWKJwysbGS1hw620pPDtoPiQkrNeFONkurDIbG0xGqiF+IMdkEDX8Fqn57D2F1C5LA/pY5'
$vscscx64exe &= 'lvMR8F6JSBjFtOlEosnAgqpGG2CSs04Hq1ILbomqFLSecCUvtoYv5Mf5f1j5mu06WV/ZFeltWYCCIohhrASmAPGsB1811IpzFdmr1ZG4mfu2bjY+EVfrhRTgbhJU9s79ILCzgAMZTM0mchs/skDAoxRMuZVLbvWRxTVrA7Wl+caHJwPnMT7hoU3hbNKz4dv1WoeRTHqC'
$vscscx64exe &= 'lq14Qr1O1mjIJLVvr8beN32OH3XgEsciyUijm7Dla0hvbEERtSl5wy+vSBvIXG64708LUQNK1/wYP70l9giEucnSTrBgpI1is9HOAv7diVqczcmpp3KSzw/beq3GazchYOTyrnz//sjKgezVjzvN7gjkgJsYueof1Gtda6HwEDGw+PeT4LU0Ar5HuG9HdqEs2rRdalsw'
$vscscx64exe &= 'EUOg+/zZ2uASj0f1MP9zBHRC0I6FgjcFZ9Yc68Mz6/KoUwRmKoRovBhIcGYI4wQMByCfajMBMc/O/w7TL7tRkzygkoh+i32M6m+MQ2peiwuypilt7evOm+w+6cMYw9UjmMNlPe2Bodta91MNr5yF12cvTVraOwIv2kcOQSjLuCecCspPQ+IYsR2YdWmkL7SDN9DYFntV'
$vscscx64exe &= 'ZGmQRpqnubMRS2R3I+ejv+636o8tDDZSSUtw1lxwy8XcBTUnfcm1NzXDIwe4S13dUTA5Nivv5YlQL5K/0pyfRQORQfSxuWusJYAGM/pyllapMDbdpe1Tc875h2KB7k0W4uODsSE2gh3Ux8OccYLQKWUtNtYccaT8ZB8Jom9Wa0O6k7nuFMrsnwogZIyAaw5md/k4r4YV'
$vscscx64exe &= 'RiFY7rvVbn2WggfQAzzfO45qBgFjtuA4Ck3imFumtSG8k1/GN1KkKlkHZBgpytdwgUddP/431Zv8qZyx7NRgd1O1BcNyKa3PXo4n2n/WAUxkJrKi5njUj8x0/oCkYT8Rau5H0rmiLgAVCSDvJALrbPByOtuWdL8+dWmBz9NPMxulgMjR4kRkFB6XGqozrSEafD1jiNRf'
$vscscx64exe &= 'Zj78PGhtQIgNFAz7Mc64juX6VF46ycS+OhDIHM3VKCsTlul5jGc9tB/ockVZ5XhWizTTL02+9hR5jeQ/WsdZaEUWvLXfFsApadxrcy0AnZWmZ59FkNUhK94co9ytQNxwPaKJeE06bZq5FvtGyT66Ew5yp08KOjKrNuMeiCeBtA22o+3EN9x8kgRxZW3Wht7MuIQX8q9G'
$vscscx64exe &= '6nr8xWyhK+x/BTsqzXxz4/TTKL+IgIOETypCCn07ryPwgwHxWZYj3kFdkIfZzZqebOmkPj0QoTanyOP/L/484B1Nht2lmm7LAo5ZtoS+M2cVJGOcIkM75pe8JI3gid89Q/nWgvQ2SICHGoFkQGFqGkBW8KASBF1XizbIVVPGhoPvoPnjpaII+Q+RbHfXqGxJLyv9FV06'
$vscscx64exe &= 'FJ26pYeahKD0sMYANQk3JAveJCwFTSQ/bwG9AXa8PZHcz62Y2yDtIkAybNiR/F023UjEw7SPY2xJDll1qZdVRro8UN1PqkvgPgkywK8wi9+OgKb0MtM/U1gwXnf5sv9Y/uaj2LKoAzaKmhqXQ/SM/w0gJ8sxaCGR23co1ujjb8ObmrSWMFNTf1ymjA/PUAO8LQTpT2dY'
$vscscx64exe &= 'W06e6nYWDS56w9GhUP5gWa5ZwXUi7c2jsFIlv6aCzPKaNWxtLp+qVpKHVS+t2Q42T/02eKqCXhDKhmEL/ukdCkVlmxpN2aZsisA+wLJZR1yD+AWxvfTKBhS5qbXvD7iAyBfliw8JicN6Ujx8MR+b/1PEk13INZN+sL6w1NnRMfbpe5zDUCof4+n0pK+vgG3F35fT+8DN'
$vscscx64exe &= 'sGn+o5/fT3Eb7ITy4PMPIFN0o361FeX9ZtFry2jawptrdH7IwJ7FEbDZqnsp/cnH4xWSZF3L3ssne04hetP3D7FPU8jwCCrtPJX/zq890woRVtuYtnGyV3oialITkND9raVUfuUFQJpzvCi4fTxNRISAzTlDMZsO/MdVl+Zr5NUVkVu/h2Mrd44hY6M/9v7HsB4+zQRM'
$vscscx64exe &= 'SENHcsS7pPmh55ObwDCAwiijSKOWgGT9QHPxHxKPjOsn22qFhsKWOb1F7HXCgd51OUN+DxfD3CDPqzzePH9KB5093V8zSPe/oxBDDGuFMl5Z+FU03D0XjtsFpfCdq1/D8iQm+leWJ6B3Xdpw5ihFB6LKF+FW/0y4eBAk9kfmvhH68/k8pY96VFEgZ4IElD2kbMfNN1gN'
$vscscx64exe &= 'ZOzV+1mWltNqMQlR2xkHsVg8SdDDIJpkuTxn7RkvzvVcaICBGfDX9LL8seRQorv+yjwvI4WQAJ5jHyftPjf+V3eg6ZIyew+Z1BxPeuPeDOGnXCq5VsDsSoRDmdyvUk4oF1UOO/dv5FjjqHt3DghfRsnshFfupBSfuCvWm7oYQ1bBwD4znEBNiUlAKDHPkb8X99RzTUwL'
$vscscx64exe &= 'ttuYh3urTU+tLreuq0dOEdB8wo5zCvIw29laf8UmzeSI4qIbCpsCVmVzOsNp14g9EPVOGWC1K5FE6d2f2uhFv0jmoOEPsHaVBA0wVELkESTCg5RBpDYixq/V8pw7M/cwtFk2GS7WrhGm06k1HKSCN0S9kX0Z7YzjdH+vpO0LWlDibgHRxFOD5Lu3x85wXpJ2d5RrHYI2'
$vscscx64exe &= '4LQ9BvMhQdfgkiAFe/ILPXOhtM6/sqIceU3TpaE5JaBGB8BshaORddCEWKHfAedLvNUMlFjoi3psIY9CJdSD8ZW9mFQ7NH17dIOn3qbAubRKAl8E40snBYw0CtjUTxN8Esc2IVPSfokOyk1bSdBBBLzU8B+UZGuzFYqzRViXigvb5BxjghW6Yo+eythaMSZYiS+A8m2Y'
$vscscx64exe &= 'aiqpw979LgJEV4m4VOTW738W+G6IW8tQMRTJl6WA4lpACr9oECfxcDU+qtxUDWltDU4oZ1TWcxzyHOljqU8HOFn8WBFz3W41IUGg8sEKdtTxfHHbtuyk8+iVAeOHa115rpp0T8aOzXGw6QTn+KeI0MVR/yM5JgqAeAIgRRzuLGhXEHCxOrDbp0rxf4eFGGq2HqIJpgkw'
$vscscx64exe &= 'uClQ7ys2AHmH8J8nEGKwTisacx5kDQuNAS094YEMIS1OfFj/A+11TfM51AR4IcJ/VX4uhogCUHGaW7eAiR8/nobbxuGrI1HHpyCCGDRcw/wQP7AABMyFPchK5nAVqDeJzD8H7AltyE+3lP36fxZUdhbIAeGp9cRFC2gXRoKGBWMDPNIQsVqZ+yRLUBoqo+TwHsyuMO8n'
$vscscx64exe &= 'cuOFbiTjWAA3SEVanMEFIUFCu0B2jWHcxqpkRT7r42kD3P/Y3AEImZiuJlxeQKQ3NLEJyzkHX5LUts2dNMcssHsAIidw0Zb3KGovAD3PV7h4V9UogB9awMTj/rnaJpc7eokUOkJ5INbRdRjHwr4aiiRrNhuu2vCGJ9zAtjANoFuPPkINhxwqKDPR6DR3pldLquPuI4qI'
$vscscx64exe &= '8W+HVHUspzDMR/nHbnQtKwhaMJ0Za3/99SztC0wFrkz+6iMGMAYsvXqiwJKJ4pvswwwkaLOwIDtJZ7zhGmHGarHZ7W/wiuUO8dZ857RJBfjNAjQ60CVs+PulO1vklsLGXD7EqPfBoSl8/22vIjeaxK8tVrGbKohBkFyssAipIxXPyGgsZdYWkgj/////k/TP3nV3hp8F'
$vscscx64exe &= 'jDS8u4a5/WzggTRnQiA4SrfYiZTA3TkIBX4mMN5CXcypS05ARKiJ0MvRVKlxHT5PG8l6iIjzERpQ3twTsf7Bbabl1icl98RKnlRSv8BDYS0Rk0CVcFXY/pzDkaz+Z3Rnq0XnlnrKomYJeYBfAta3Ha4W9RyH/qxJQKEu27h/nxbPmIIJdrqPD0qxuky3UILMNtIp4Sja'
$vscscx64exe &= 'w+bC2tzq36OYq2keAVpZArrjm50O0rGfLMrcXGlHR0HSXmr2LfHzJ3KBNQsor4vZ4mXN2522FBaqsGfvgymJ38+AYF10gjCwkCdyywUAwNJfn0yCLxKKro6poOafq+Cn2Q8t1biEqAqOBoKcv1OTYOi3AtWeT1BSyS98DPwf72kjisLLC/7sXNtDMSCE4VWdW2DEwDWw'
$vscscx64exe &= 'fJHeKjKSeNr2ifTuHVXLo+XCScPoaw2HPO9Wp7ajwdfBZGNwuKWNTOOplknAPSHxgF1cTkKq5ixZNACPHw6c73Le9K1oe5LwLh8nQ1CTN5/nQ+uT8ickk4rtB43aJ67OiSA4Bm2rFirnotMaNnXbABQ7zFunQiiM8gFKqfOIk1gqzND/Sy2cXJurirbGT8809cA7sylS'
$vscscx64exe &= 'CJhnSdRjcNvPvwYkpsqSkY2TGMok/zjdCwsvamTPUBrq7VYs85dDWRBuOma74ESux76O0dwYqsphkH3/3pdbGhOoiSakhZd1OBtoPWDSfMbO/7z3r3HLABSti8nbC+XVD3akOetvMTbTtb5x1RpQKuT39P+Z8L3jHVwgi4S7PNN1ck+bRmW9l+Shl2O+bnMDPf18SJx8'
$vscscx64exe &= 'qb0dONzHfpZRhxl9dRvkvxigMpPNdAqyApey5pk3vIFg3uAjqxv2gN6rmvQ8Et7g6oiSJk4K7sq+1c+r+Awr/IRl3M4TC2k9UvbYTGbWJVxGts04HO+M+ra7p4BZEwCj+6cIj9DP8dEnXKRvIU7DepuXP7iPLRi8P6JgBfqhbwHEkehfCqPWx/qt43MyyWsa2XhXP7Bi'
$vscscx64exe &= 'IdSr4v9pX85XBYK361hMX86jvqndTrccP+bo0Dd5Jivh1fkFxDb+aG97KWXmGYV4Du4CAU/HLV5rlEWcC5h05tOOp8CTSrvL195sPpsqMMYzGH+lJikQDRxBbO7Cua5Nc2XYm50glmBGhQNzU9dAgPT/0suFBfmdJaX3EKJRGGMtofHBonTUNC7O3ZOskqFhU96S/QqC'
$vscscx64exe &= '3CjVgSUkwerq2lho0FlziEteRcmjwhNuSbBhvvhl1KiNOSNNgJ+hvv2Hl0XEKkPpPA4AY47d9nrNTLcpVtUJiod4qfGYpBI28u2sYAY0s1I6HgjShbWsrOtEDilugNS10CIYrTWs4llG4mPlbQIjJMoxWLUcR+gy6UuTcy/ABTL/6stgcHQOtxecu1E4q6nWB1smCRPv'
$vscscx64exe &= 'UNGa9BTRZvm97oERdwZ1ldI+CNgm9bt4gP7oQ0KnICHpl8WIzjj7XdY2u5fSYwllTtbZwx2JK2Wb5RmQk8RIssD/k9Kl7bB85DMk1bLSzA6NFQSXL3cARea/vK9WAnLVQ6PdTI3yWSzNIsVF5/nW96y/ckAA7gtc73pZzmHkdZ3G4lzw0jevliaQw32v4jl7rXTs1rx8'
$vscscx64exe &= 'r6Z6rdEhIuj7lyVk3MaoL+0FOLgpQxrwCKGTXSj5KOwppCIKIGrWbUBrL5wyqBQsjtv7OUswyW+YMSXjUOCboAEbcv4jUVsvntsLyfUjbAHCYNLja7K1ySTzhi4brwzDnfW2YVw1tbkpXKXNxCHmTUD+rWH5n6nv4ae/xBqV5gptuRZYEgfBO9LK0svGAhJ/APFU3gms'
$vscscx64exe &= 'cEowUBj1aqRPgxP84Ylr08+TK5hTENf8xg29Cxvxg8M7qvRvVUmKsxVvxW5A5zTN3rWoFjGW7Pe/fsDmPMAUT673KHHUQTkYVBPk7una477s6Syrk7Qq7YcKgNNLohQnVnqfa+J61juPmevm8wKf6pU39NzKb6FqD3C/TGJHNUseXEOS6VFQ8Yfczp52tHvokpBf0K4k'
$vscscx64exe &= 'zDhkFDYy0YRyUkTS/plwcZI4Lk6rs7xvsv0zEfUjUXKYhOXJhCmBqd+uEs9Oaif4dqLmaneu5zxi5J8UHZAui0Czc46zP5nn2l2DSQIgrlXd2ud0rcVka4CCb36gzI4X4J51DQWVdWWiuEjCkyDPb8K4kO8K6uKop5sYeCN8h4mVxsgziE21Kb/WmS+5DWOJsUaRDbzF'
$vscscx64exe &= '4RkB/hc3aZc6CFw6mlxrIzAGfnrFvRNbzCtMvo8/AQTqPqpWr0p7IBJrCiq63yeNiBObXEoWUITFTf3m2hAPjZK3XccGYhyaPJ4g4Om14PI649IROMmR26PZ8ocXN4tZkYDqPfAs177xlY41dC0kg0gwTdtS7AbNfS3ZCL9EI4jgmLuwmvYmT8f40jGtRoAzE+LUynt8'
$vscscx64exe &= 'jwk4muCXNgKkeUC38mXsdpAR2bjc5uAft/jJzXj5TWGZetbMgN1khcrcPmw4SME6xoV5wlhxat5A3ti8HXrDDDhtFiylIWDeYdbw+4Ksvqf3oWOOU9KpIOVbGqRMEGZLMCgheSZ+GU6FbRVPyCUW67ZZo4GIjzKA1Vo/Ug3xqU6vIMy5d7RsCNOMkjqP0GOLqizFTuYX'
$vscscx64exe &= 'FS/KJGkbIz4aU60O72liivBDlfVxyWdGbNK0Psz6S8ISx0qRf5p7miGUNKrCiotgW/sYh0SLm6pddopCjSrRjwjBJl67FrtsoGxEkq2QBvLU1XdLYk3LBzS8x/l3H8+yDwqixlXfxhXDsCS/Tqce6NoKK5VzcZIVMbQ7KyqtvCKAl+Pcp5MNAaxU+brAzPAad2Id4noL'
$vscscx64exe &= 'L75HkVvZACwJXzF9Qva6OBqks86IQkjvsL2EPMPAfeKn9Bi0L0/PKvTv6SPqcSyNniKXaRzW21k7aaKYIUaACYypsP5t14chMtKChD39xMYNOGYHyqF1NhyM/jYiOticTd9bwqVz2rmlu+zhG5aRAdKMeesI/////5KOM3pTEj5l+9fiVSNJfsbCEcKFhf8iPJYc/hHJ'
$vscscx64exe &= 'lqOSOwdx1fglHu7GgWhAUzO9QZOiWSKHcnbcG+OTbPW2Dsv0K5G8TvGXBCQxTska6WcZcfHQ0n2/9pa1PlOMl4C56iW4t5V6RWpg6a1D26TlBa01tSmYx2c41l+VKE4NunGxEPHnZAYxLdQDlzhkyex3GMXkBO/GvB476F1VTAqaUoSUAJm55HiaV8czG9X4dlD6/W+y'
$vscscx64exe &= 'kcCqkUljVUa9tS91Ms1jC3jVBu6bMoxST6c7I+JeIPLfKVvSISgjMPNUkufTfGliOXQo/mn/SSa1A9rS4d6gJt4fXJ/LddoJbhhAOPQeAF1jGlNNQuX+jYSqtPLfvlJpfln3WvAu/tltvrFUbEWAm8kVmJLCISbYOE8SpgIh/aRZjzVtIQQaomJ3Jbx166IC60PXFniR'
$vscscx64exe &= 'KmVwU4BKgayQQOS+1qWKsTJubYY6CPfzOZLKMcExY5Y2zyTil+c5tdGyrZDME5kmX+YtMfPGg2d/vAexeb11icLdG/fnpV2xf4Jg4N7X7OpT5A+HqC7Qxadr7IWBZcVA68rIoySWNPpKAaRY08ICIH5q0bRmJDv+2f6XcbECPHga89buK3q3PQ9RwmAgf89Ccb228fzI'
$vscscx64exe &= 'RKjZEnPR+n4JHu97hN3+12GWmwH5jhg4EI6Yma38SNBdJl3PlY0o3ZA7NVNZYJs62lCemPOUqNhmuuui4YSx/A8HSmDx7UQmFKPb6c67YHL1YhKWWsp4yQd9q6KmY9PODhFJVaj2nL7DHfZQbNp5XFKr0WG8QXEsVE7y6vqFRPV4KOeJPbhFCGb/hHgliKJXrLpHRo/D'
$vscscx64exe &= 'HCgw4IJtDY0cZ4YC/h4KEelvW81cbqvWWc4DqGKiLHnvs8axW3smPy/Bf8PdQgPsjug4FsWlwKfXVx6XBlRl9+96bAf7Lw5TLbUu3feyWOFCeSOthrFCcB7mRjcRt5KNatAJXJYq4Qjm4+SpgVEbpggJ9OMyEyPJrDMxWOqrin6JFGTCFOJEceTNcdAyk3fH502fTrCa'
$vscscx64exe &= '5830HMjTdxOdLMdmdU+sKzk/8Hou7xUuJfxCJiCAKjVd5hWUWhhnKQ+tlilAept+3onbtSNndFpqxiG2RsvZj2uJJFyQgXZuLZAKyX7kGCESgTghnxRj1/aMSEPj7El5FI8szH+IW0fQhVRbHQN0pYtLOepUWTzulLJ0Q2auQC9L6BiAuM7B/YS8QYdFJXOk22G9RFXu'
$vscscx64exe &= 'aYFxva01uPxdajOF+LpBTkQN/zDcWjBnXXHP8tard2gWbCi2blmm9jeqS6dc5j8UD22j9xCxwCBUYDrknmRL0j4jCtKASHLB8yrDtxsqlrDVAWdP3ayO9XmBemwf7sbJp6dO4D3p8aXPgF/V9483IDXK3hhzcYeplZs7yRrMkPr5ebCnN5eC2c/sYIy+pqODUVkcOpaL'
$vscscx64exe &= 'oo9r0jhQTeynACfBPWmsMFgwltKB/iPQZHqQEiVzAvXCsD0++KrWcH0SXYEWwC9ou9afU56xNhNeO0a1NpQgW0mOaQ6K/x2mKUeZxXHqy28GrZNFzjv6ZCHB6KmSXy2ajgtqGgkC35K1Iksxk3Yh8CBq23IRbVWnci3gwW67Y2Rqnoux7JEM8i+XFkhELmyNi4hwWhhm'
$vscscx64exe &= 'b4bFoWxrmNWv6KbqnVF2dupB71wph2jy8PZQSH8ZDAJde3Cl5tNST57jiEeWDA+VnPP5T9R+nDihyRSqErRyUBBNbRQmte6wvrnYyZfW4pLDKRoiEZ0v31VcQYuzalrSZxdVVOcm6xkml2BQV1h54khTS5637GvE8oCgi675TQSw8tFtjD1TCStHf0raUbpdsjDoQqxH'
$vscscx64exe &= 'O5ozBbismt5Yl+jY9PIcakM2sa2qwXd2IzECzriqUqVw0NlZSGT6EzijkY13XkNYD07zuMm/tHfqEgTCsxYEUr8Y9IJp3fgNUYqG0hLxrUDmKYKtXqt90Zwzx7tYSHG8MD7FPJuoqjw5+/2clh1tKbU52L7ey+xAwNNRi9j50TUkKAbXuX7pWDbASyIGiLJs0bC9w86Q'
$vscscx64exe &= 'vvYJBw698mxGKZk4Q5t6EYWJ4Rc4CJglwC5MkAPb2lbOhXKIxYWS7AzA+9TDpWhF2Agxc0fKmD8mIR4pQmzuTFHYI0TyOBvTZ1tv+M3Y7AJ6ClcKP+rHYMpZZOOANbTxms6pbGUdsTzuzMhdTcQL/IuYxKFoK2X+4vHB2khvha1eJUsFQ7md8goRK/hwz2cQzjJnxbyV'
$vscscx64exe &= 't7G0iCJX1W/HqF86yi/aHr1okX2ibaJ2nVrmJaMqTnj8cbB4t4UVFvZDIa69XI1HHSAVfKnWq2sGzDFeme89PeuNeQJphDhYgtmUu1oA+W0pYmT8/NW+56jxPiTiJFr3u6Rzx4M/U+yVdP1bIuG4IRn3vq2EUy0vMLINymvhqfO2OYaiNs7Dn1E7vwI5xVpT59mryuRs'
$vscscx64exe &= '5JakwzsopxGFkL4y1qNd4mBRFK1nQ17CMvy2jJVknER7Jc8O0q7v4iqL6QioLmXms7iPlWZbLyjKt3cXbbGytnTnMYhnvvY8UWEfltqFn4rH6xzsrHhrCBetyRM/mW0EhRm820rn+Zj5rnPcGCTKCnjpBf4tcnIZVHjtX+oXWEs55MLXQ2sfL300tS5jTZ3FH/0WlTw4'
$vscscx64exe &= 'DEhnXGwCkEwM2Ld4CTPotqrct1u2hE0Bm5Q78qZk7h/orZFj8FsBPqmMzQ4U7H8J5z3vpdbj4mpTtsWbN20ngWN7y+7cKOqcGCv3XXKWmKLuWwBkiToLlyb4OjYuEtXOPJnLSdRvhMk91otkS6XGaad4P57zks0rp1qx9cL7mONWCuJ2/Qco7T2hyE+xX96pjIEP7DI4'
$vscscx64exe &= 'OzhOOFj8IX5PdFmU5Jet104kyGLtgab2K3JHKqHhk153iA47sm7ACbgFe8p9ZG34+j65NXbxP2yi+v/pvkxPrhEVr0OYVzWKJ+FelzUFKCq5VyLd1rT8ideNSByB6BSwQlJ+PUeoXNVt0uYsoofqhmNRdJy8ral5PE5hblFa517DIrHfFlF+14QRyV6id55WQhL1Jd+K'
$vscscx64exe &= 'ngKN5kvZ/MDqIZlmg0fkIYHC4EcU6oL5DE9m9bd5vakUVDB7PJoMWAOqnNXt7z/768bn4Q/gdh9/iA2ftJiPGbpiMyPNaz+hpx/R0DQ6I+c6ydtUHC2GmelO33DcbqrgNWi/HiMCMmmsWkIVNsuoMBsCufkgnkA9wEyFb+f//lX8QfgFRncz3I0PutuyXFIH38JgG+bw'
$vscscx64exe &= 'YwZi+PxHbBnJCFfMB+n9guj0yM2g3yyJn2TJGCxXVoKm3TY7Du8KeP/ZV6g2o4WmKLzIXhlMQfpchxytx2U3WF/+bhwnv4totlomPMeIlzXtypaKphJIW+YT2aqBvR+NrdNy43G9TvCIbWRiXWByUtpmxQ2qazD5JO/PfRG8OwcSa6gyxu5af8hndYXOUQemHSXIhxng'
$vscscx64exe &= 's64DWjXuJ616Xpsa3LRxxnlnaRYuFR7rRuaG9uiAaEWbX8X0LFzYGwKm8BxpyYTvnzn7QcuRPcCeQnGdOYx94xu/PURIA19oVBLSFDll7Y1ZmAG/4gMQWF6/7Jm5yWNkhijFd9JX6E/ikPnc0SgZyIvXty/Y8cdY+q4PPST8vayAZp1VYX7ejhOuVYgkUT6e+fJjZEki'
$vscscx64exe &= 'SEv8EU5/iPBZBHSZoN0YnlxK+aXb3KjIaGF0LcNIyVwgJCoIiM0xuqaZnBWGRITa/pnof28H8tKI7HUEy0bekPEnifLBDy40RxEx5zF4uVzm5EmZGAh3TtgG43Nt60usGe/+Ekl0RyyRNniV4cXY5CWjP/FaMq5Ee4fKGIEMAgmnuKwQ9fVxVkHUFid4uqC6kSpup/yt'
$vscscx64exe &= 'dlBP/bw2gu1zaCe4Sbrsj2XSoTzSdOHzposI2Cf9baNoiTlf4Z4BLyplelrgAiWFUAqMecG5ze7ctgj/////HhHo2PTiHS+ZG2xspgr+ZNjjAQwuqKWQuw1eFKgEXcULucyO2uHHqwyMVXy6UGIKeS7v6gTkRazfkbh/uVV4o1B/Wa4Y7G1muijPMgMNtf7doqbYg3Vp'
$vscscx64exe &= 'XhsZe8w27u8bP1QtCBpgjnnS13Zdi9T1ZR+Ibw61jk54u2hwNZTWqzRhnaKk+6dGuAcxQrmaruwlxEuWo4fiBbO2R03vkkm8gAmFwVSCJSK37FieqbQ9Z0+6ceCFbVPyL4rjrLEVT0Ufx9pNwwlvGQxZ+C3hWGMhSANabBTCw5IEOJ4MBCaw5XWuFENcUtXm5ZyBdMre'
$vscscx64exe &= 'EKQOLP2vEsVdel2d0dYQhqI3ped4ASlwMT2WJZj+szjJPyOTe6ouhOoC+qMSFH4Cxu9Kons0WR4mPRnyKDxbj3G9OBgjp1KlXCsDL/NjLfA0p/Qi8BwZqg5UMgyDfUhSkgSBeEiVVSeJwlVKzDwfukXyTqDKl7rqoKuXza+Ss4VO/LGB5GSjIOfWP5BdqSxnN9RJmm0r'
$vscscx64exe &= 'Ks8/ItkaBhx0G6BI7AxA6KzP7+PPv9tIsP7JYsoDkk2a7KILduW6CbwJ9/y1UFlY2twPzg1BiW2HNIfpJTcRfCy5TRox1sC7wjyP7sMJkxf/jmhxdUZjrIiSwNJ0IiQZxOBiT/isfw87SWodQGIRP8/+hByyRNf5l+znLuEmBiwLZ8lZVz5EySg5Bp5J2j53aXuQzbLA'
$vscscx64exe &= '57hNGwkdbgWxZuy3vn57Liz7JfBnGf0LyjLnQCvsIg9zNufZliIlkmpOYP167Ew+8h/SZZbXilyETQ2HC1nxCL3zfG8mRN7g76NHXj6sfKlmPlPumCRtH8vljtOltfyN4UvZPHLUadyt5TlIUADfLTlZBJdmC+4acM4zyr38emhf7j+SLgq3k0Cdaf9X6k6v13EAvtRL'
$vscscx64exe &= '4iLg2BaSLMKQynjOdAnmbkI2F/fftTZUPruQq5mmuzFfV0WjWHtypz3RjdDsr3JkZOhA5VyJ9ztAS3l39CBfQoVTuzyP0ZgbBnZJeH/aZ4cDzUbpRkQNWWhMQtKr0hEPRrjuZe1St/0jWJ/jZfywr46ryZ6VCGIVYIUT4GGjOlcpLre2AxioBpz6QJYgDr8+jsS0vmcP'
$vscscx64exe &= '1w0Rr2Md+0CG3iw8PXNEo+bCXwN+osxUz2q4sN0rgDt3wTgT2aZPBJ8ZFB0kUROCSmVVvfMcd5HDPdERy7q4kTiJNYVfYPpyXNfZj57Hs/3Oz3pGMqlPxxYRO7PuBsuWDBCprpd2zqiWZAj2D+NGWxxu1ViOSWdPV27bReMbKkx47FdennK3185x66+XR33UN2738HOz'
$vscscx64exe &= 's5+v1qSO5H9AY1uOsmLqWugxa92c0aV5HvJFXGTtjLiYFksUOpD2bsbNf79DE3SZIzV8WFUldIrqLgS5CFnJxvIFI2qa/tSoj2AUfHjsBjIi+7zeoxRT10GAE28wIpY1dM2gFEYNq5ks8YPoWo0+HkPKaShUJ8/VQqh6vDLSNRxO7Na3OIk/5NHQn1sscIX6RQjuFPka'
$vscscx64exe &= 'gFWlDqQtVNysT+E8HuIAidHwTnDA5mFLop9Ni3dpyv2Tl48uFJF8exKJsk//LQBolgvr6m/jAi20DCsTr9rjY9JAKz4jrLEKvmiQUy+foIqIzrMj1JcxaD/L9/qPnz6DsbOq0tRIFswElvcd/k9ZePzGOulADHQOkoq0LwlE31nKqTFtN9ElVTIZHjcVl1dn+k/alGoH'
$vscscx64exe &= 'M1RIhB8pwmaPhv0r7tIButsjNY6j9WItTeyf/6Rif/df7OrH4xU3Xv+TioAIKBS/YZuvMU64MUUCuOELJZUzL9F+5jyftJmBIc9h7EtUHj0exm3wwUdOu3O7+oAWOywuirKRXXYGg1jY0BwEvlec9AHGaZ8yrmu3zB5Qynowhzl/yhT6emyQquvdqoKf8KTzGqDdkx0a'
$vscscx64exe &= 'tbcLdTL5R2wFVxp1owpiWVyKrEdgQFiKdYr3cFqGT7LPxkWz4mNIkWz4mXptozk377yCz9860eX7PXelZZ55LBNgFSkO0Tgb6yyz7nqHkzawHZtj5536HjYssBe2/QR3kwNO912zHqATWzrJuexsRNNddVqAB1myFr2PGZyZysb2XtvCXptlqhRwaz+NjVFLHYCYMUFY'
$vscscx64exe &= 'OdEaRh6K0Oa3iH6RTg+hsppuyeaDo59QqsPFTqlWvRae9XMrd4ewXLAh9ZRwErXl4wnqW52IyGX336WnRW/HIY9PrQ36cigR1MtVKqu7FuStByICyUTElrfxuLij15hMZX0m5OhzIN29upnEh/APPX0f4QYkqsMmXt/kfMDhNLDjwqHO7JWdHObAmsURbMjwNu/RIrex'
$vscscx64exe &= 'L9BIonK2SseUneLfEbVq2BYoJ9mbhDI0Ba5bW0RJbWcxAt7p4hAjY7za6p5JCQDJWCl9mCBrvmZmdBHLqDGdFR6kRxTuL/69dnrTEnKq9v+BRqWkuDtAcUevklZZsxYSVmNDcE7Kd9xrgtxB0XYjVGPYgJI3sDRvny+OuVE3g+wgAiH/iwjeHp0I2zd6zDlHrRdUYU7D'
$vscscx64exe &= 'wvyFQSZMDTJXcEZfSTBuQhploWxgjvSX/DKhuUMkty++hJGSRxZR2MudDJMA/bVngYtkEe5dV5ggH3sh+0DKzWJTh6qrzNPfasYO1WBQDsffhS/DFhXL7K1XPaESROyqjCIc51o+g4Io3kNOsc7dGqnuNjNGr/FbWIjsaxSFZ5aIiDOrJK77Icy8ALcokjzIHFcjhByV'
$vscscx64exe &= '5tpVJ31yuUAG1hYmU++ydk8YCRx5J3MMrLVroqPg7YgpHO84uTx3+sx9tkQpv/bLvGz/jRUpjtxBkTgwqLDZGSWqV2Tc7Rr6KLn0yhnkIuJShBzrXxDMrVTHFeneT9E5lDLIICokJlH0aI7dbHiRBMXrBTtJkT1HZ/FhposcE9qJutlzECKzX3NgNaSpcOauLrId47tE'
$vscscx64exe &= 'EQ26i9FFXAFf0C8L5f+zSj2F7AGF/AbA387XB9kDHv2XAlnY7yWWw06IyZZQxSDFpHKrZUckeKtumrPHgjMZJExRfKd0PqEksYkNxsqmcniDKd9JlbxEXAzuuczQx6aZRz3hxby8unPeW456mPKzap6eUZ0bTW8VQtE5hOQxiuTkdCpbFrJiwyB4b/pAs+SovPd/vuDM'
$vscscx64exe &= 'aP1nRhMSKuJ4x3lWnPZJrc5SqH9M5U7miZgQRlX+HnJHCWabZQYQR135iaFMFPItAJYqRYEv4PqGo3tZOzI7SqSh8qDHyXKECEAEnoFekc2iY7R02Ma9ELLqDlMgzx8ajIMVCDUBq2zkFWX1Dngr9QgWAi+8DF4j+4xT6JBdHEias2/aX+2xWQAFOwy1rRQ4PLyNVCRL'
$vscscx64exe &= 'knXVt8KM5G2uPm+mVmfJMPU9pmDbcKE3orgI/////2BTzG7bp0o/dfyEH1yVV1wW3sRB2Za3PCuUd3BxjbcyZWGoTdqlFScBykBoFKiVdRkQVwbqYPHnnSYQhCXO5Bs+qIXOWvcD8pDjJqmnw3qZaynzugNWkW7zvGF4WU6BXHgP6OHjbZsWbMEIfIiFTMmc/Ub4C24u'
$vscscx64exe &= 'fglWjehiFobmpfmVz9S75S3c/urKHLr+ScgsUzij4fGCoB7xnlRN9VV3gGWH4c6Wh5LUVnhfVYHNAa7Lc3L7lqAbyo1LuJ3Q9AOJDmQNxgMKaWD9M8T3OmQv+3XIruXu3J6Ox/AQEbu7qy/+aE01worCOci+DikTSH43DR4vas71etlPJAIUBNaC+zdBT2QY8lb2wKak'
$vscscx64exe &= '/xdzkI1XH8i+OOW9qmOk7SkdP1rVSg2KNPBXZm3cL2TBde+atHhoXzO6xxckSaO84PJxWueSDvkE6+xv3mI17JRfesZXqbgAjtxKNzLzirfIRDVgA/qXhrhpgW2m4dQVxLhlx8UwLwSFCcuEUYr5dKWDs/y/dD2sZaMqtgQNHgUtYMEIMGk0oQVc9SRZfiTYdQ8QXody'
$vscscx64exe &= 'Ye7a9A5tkrzEBFAd0U/rZejZp7aXHkvsz2dBq6cWxPnUjS0PQ86uzeKrrJ0KblYMk4/7UBhGE+tElVMDwp7Mblb/EYMWIu8qROGJcb2VkvwGRPZYNDVYunb+IgLpSLy+vXkEqjrllSMNFNXYjbwYBK6kZpHw3juyeqwc0+PWEFbZfzsGtfkbr2mn258PAI8ycpk+A27b'
$vscscx64exe &= 'kGks8HyZcZvnfiO/Q4L9X2dwFjg7oQEAczhk0c7UYE4NKWxitfFooYBPkpe7L0ovvQJ0GCk4KYpc+KF8nKMBn5XrQVxy7+Nb6iC80wk+vroVVeS49ses5pOvfisU1eCiuTpXzabBSbCPsfEpvNh4y8Dq8Jx+e/RV7PsQwBllLZxcwo1YFTDq2JsRcCO4TRpESVrybxbH'
$vscscx64exe &= '1ClrDG4E5Rw6Y93glChSqGFdip5C76CS80Zif7wS5pBXKgXpblJxheZITf8byh695GfR5WVE+GIzHCQKxP6LEcwQUPa+YFV74ZrWApD3SaEc3rHL/YbrajARCCdF/+cxf23dh2M5xe0IueLUcqOezxE81wyKwT7/sGn3t+vZZBKf1+u51aKRZaQIX0A5DpNy4LEE1sdE'
$vscscx64exe &= 'DPHytBmWXxw6mLKO4KkMwfKvkt8SUwCpJN9u2cPAVvlVxZ4gHBKx8qZxmpTuD8DwExGdJHr+aYUN2SJooUoibvOC8V/rhKo5JzcQgE1SbWN9PR7fOi+wJlZfnsmyvZz/cUmvoYyH5YVUZ6TDUuy8cUCXlt21OCtzC4i2bEnb5fXW93ay4ihY5WulGj5JhVvubGk2qLb/'
$vscscx64exe &= 'reV+Wvq0lGFD9MSiVYgr3k0gRVAvPPC8TejgzyYDAirQpAOInPM6SDPFUI9a2S8hFEeMH1yLcd6k1X6MjnnG48VybrKZ/XEOVr2muZ11ulwwpgTagFPqIiRAZWPaDBdJ3+HL2+3dPLB1LmbSKijFYL41FduS38An7YR7KkWziWDC2tcwckhnWO5nBhZfkB8fsLrjRmky'
$vscscx64exe &= 'zjHz31dm8S9pWeYBTBQJ6Qhm8JmeohMM9Ej8YfCHmbKaIHZ/lXQ/Bb9hWt9RsM1gELMgURH1ml4VnT8HDw0bSAm5JCHCEUoyYBNeNObtzwroizlEVAVfGrh+FdiJYObqOSBLwrSL9FmNvPv+kG8CDYL2c9oK9FpS0aKQrPa6SAe78NHSGJk677DMpE71M8/3bWuUTTl2'
$vscscx64exe &= '5tzvZTgNGUj9p73P1Frvvztp0Y8JIa0pOgQPK/O9eXlgpqXV72dEQCJhqLbW4N7gApfSMjsr7j9zOxC3DyiSRzAV8kB8k20wBYqJg5l1SQYs78v4mpwokTtEdinTWrrOCN6FGDOEZ2YbP0vt8gGJOtss5CB0NTxf7ezDjmxdtc7Y3qDSgMrPixrqzZfACGof4LF+JnSA'
$vscscx64exe &= 'BlqVvY6s3mlpmt3yifdMiHN/Ie1IiaZNOp91RXIQ86jeJha4LpDajTw2DyK11IDVqgrYDykNVZQAqnEuzhXmIZbZSMcS7F+l4E4RpCwJsHlHZHZMeJpiBCLJhUi7+kEpRFCOU1KMf2KnuR1zNkARQ4ExTkQs5L5+ZD6pq52a2/hA7Qwd7D45edUcm2GFk2dWR6O3FonU'
$vscscx64exe &= 'WG68cCM2tAv0yhALc3QSYqOKgKXKrGP1rO2iipHyRHCjaUDsMvgkoDJuidaQgElQ2iaBEqbU6ICYnMySXjkgXPSuZRG10NvB2S4q8fnpCYeN79OUM2F/DXT7DpiGcGDJtwAQq5NFBxxJ9WxYBC3dbgVtl14inMaMGPhAfad4Nv8eeWcLdoVu5ppuJsCOyId6gaADcEsx'
$vscscx64exe &= 'k2qfiXoj0VMkKqy+xM+mEzc6EYDxu6GAZFW0R7zyX9Nnro+OwVmQlTbS9F6v+5Z1Pn6ySkpPVE3GuIvZsq+xPNbREfDLNENR6J3+PMg2gEDyCkjObaJUh9hGLiX4TqoEX33/hEEjmwvzozJSPf0W7JXS7F02zCrF+ToxPgIZwSKPWGWvtxiP/33yv3cTYFTez/gzQV94'
$vscscx64exe &= 'iQB0SEuFueKw2Tmp7JY1HppFO8c7eZ4sm9DihlYzp1kryc/PlMaVzztuScVun0IvyEaZcHISGaefhD/Xpq1j78T7yQwbTX0cvU6Nn+VHLMxxwYZ1ml3M5coi5DPLzm8fLnpSth/AmlN8TDAjIiknw1dyMAITwtEIFKXYIo2mKKtvJRYEs2gpZL3wWEhItdnWR86t8dSu'
$vscscx64exe &= 'DX1PSzXtNoO1CH0NXq4BPZAGhk3V+RzQssWKBnDwe+qirt976G9kJrON5cPWbt5D9WvumZZh/i68OxflGo0nZPw4CltkbO/qfoOrQyIPmkYcfNMDBs05fFBCewet9FpEFidi3ty8oN526vC3bxra5D4XZgfg3oYkGY2C/ueZuHWLs9pWaJ+8AFOC5fKDKtwK7JuaTtkM'
$vscscx64exe &= 'voatiL9V1eEp1jqWXBusXiSDUEs8Vp/9eIRIhXh9DWuEIKoqOs3m4avHrgx5tDdYzJn6qd5GL+JOlPG4sAvcyC8dpFiyfz26WiUcd1uhNz5SIF3pcyxtYmrwlO/+i/tcSr1AmOcnCpHtcMHWGtk2EDVCQWyQDUseEBUiXuOz0jGraBqm7PeVRkdsXQ0dWH4rxnHRMjKp'
$vscscx64exe &= 'p5QCEebU+oVTwYob1BYpjTCPc+zT3urCjALFyPBQ+F3ACdBDcVaX+X/QiZh3uTWDBf1bNNxTAMaXn5qBAnlzToVRDitBmttpd2rBem8K9OttkeoDiZSJsmmYYlHHF1CzHc+vJ5eV6E3/SCelVHAGZnIhAFCZ2dBTzbytE6wqTx6T6Dp4iSCHc8wtXZs3uB0izmoscuon'
$vscscx64exe &= 'bc7C1OT96UJuswz/////IRSF7ryzAc2TYoeL2eKN6rKa5mP/ygXYHww19OYiN2kVtuhGUlVJ4R84/p+ZRuNV2N8zswtlsWjC2KQFK8cvj2gceWKUTwekLOGTXj8YRkqkuxkK3+5BIIO5Jj69sRJIX1kyE145w4k+dRZLDoEpcIDrBn1dG897n+qbqYPek+Xz5Bj0Lrn9'
$vscscx64exe &= 'kHORjuTcvNM1gfE5NGAZ+BA5//A1g7xuw9kGMBVL5KjbviqoxjWS9yTgRSHOzX//rxVOKZcOehnD5MRTXNu64+/Otujno/yrDfIHhmR9mHQDGH09ak7xNbA2v81NOJIGOO9G1a9CT5MJbxbrfw8UcI4NaN9m3vyN7Z1WbwIQfmqa3yABAS29cwkJPyfalQHC9fxKTWQk'
$vscscx64exe &= 'xV38IIAacPdXE8nBO+xFjgAaDUpn5bbDqGrmVXSj6QTccBe0a4L7PrLBQ6VXeSQjAbeSkgXOwe0PCN+jrS+9YROI/eNKTmrEacwLqLios80T3FOUHHWagmxRJpAp9giGeqtmbHZWMan52H+Fc8jUx+gAXqdcHrvY74MPsE7Ernu/oYpWJZcqAvTkLmg+0xiPPQMFIzBQ'
$vscscx64exe &= 'H6D2FDMlB3FLdK4/DmFpt5dgk4qxKCCfv8NguiU25m3d4PNblu1ViWwOZGz5zEadFttpyXJ/5cTyEQdnj2eh0R4COnOWzhrujJbbbuGVRBFn5tOvTNQUJ32UwXe+ZbeWEcQgNtt67f/bzNwvNj758DSR/ovwdcCSTQyhuji5dH43ZbRvH6qyrPr58GIYmGzUlcc4og+F'
$vscscx64exe &= 'nbTEU7Hgv9uymlWx+YKib5O2UKbFSYbXNzldTZSpDzu4iXN4BsT8+HuKIW1EZ3TYgm+Qd80FpIztS1TXBi4oxvFY/9p34jt/B0bA3Oq1Q7Vn4MwVzQ0PMy00rHyeVbOUpf+7IXBVNEZpKmFNJVpRF9XNGY+q7b2L7NEk/jdy4LlskUYXwo8jntSs+fvvxBCH3WMuXpTA'
$vscscx64exe &= '1TpsK6JzXiEfrw1FuwFRhTWIcH/wKCZrAJbjfLQm6PNRSlD3vCCxwh8W981qnCwNoTY3qfwbwp16I/R1qPnDH2GcQgZkxfF8EYOTvGZuuFupKKGkhVgOhGGPlb+ktrW6cc7hJkqZxl7JZ33y8js90vtG0cjb9QSQ92WcZPahOlWuifoIXH4EoY4kVmOLCQQqEguaV5+h'
$vscscx64exe &= 'nr56dAhrxmNkgUo7pvVejxdBemLIaBeNrY/J6NB02pd6Vx0Or+iTF5VByEdczIyHQOLCpQinyYEoe2tD/0p0e5SmCpP9pZRv4z7DFNzaelayjK8N3YK8bSqVviVI2AnIJ3nb8XScqJWmdab6mAbmraIfBmyPeghOdgGvqSJ58pn6LMd4P95fWWwzVRyUGasvauaybDy9'
$vscscx64exe &= 'ErmnVCkG16wAOFu33yQVMoXGrB9CgQq47IuFeiQPVpzfurbuxf2O1J4UYVhpFcaesaVlX05VJHyX7S12m0Fpb+OVncnwvcnA4nkVTA8kYS1jLmN5XZnUSOa0iwT6CZ+W1lqq7j0wFu5PJgB8BzN+YdDI2/aFxxwSaAZmT+odJ/IheS2BpYGHw8i8B6ZlW7ImRtVzTZ8o'
$vscscx64exe &= 'AGRgQaTXfOtDCk2u9i3pb55RnsAguDmlKzPwXSvxfxkLb4Pk5k7vDwDqMBQLzsqWMrPb5TBYK0+RhrWMvNPvZmQinzkNA5GQ7hCNHSqPSHv8DZe4bOJ4Mb1cKQJF6lpWPP+kEMDbAYBEMZIcgJKNPFl+G4hid0w0n2VbDR4+CTrwK4oZMPxpNpnVcF/8R5n1qekAUhqc'
$vscscx64exe &= 'Pr2Tg1eg1vGwfaxagUhSaOZztgv9YC2d+uyHqyBm6WaLbx2jqgVRv3HgkntDRQ7GHZLL7VOypa26JecPEzH3VyNfXYSk1X6H848YlH5QP2THcfDfbu0ruUGktFUngf3tWGpNb6JduH27tiIqrZypFtVOGFVM28Jq9DUCE+3Wk/edP6D97SvSTK/crHw940kLGBMpzWss'
$vscscx64exe &= 'mLDeQ2AGFWAR4h3+YZ6lCNn27heYFs66fU4kV0o9gj8/C6IFB4qSD1rkc4UN/GZjgkUh2Loh4cBuCdQBQDa5FJTgurMJB1kneymc5RxpmkxfasoPVRoO74YZw7VKzBOaAoPRBGQoBbPcLysM6UK8eG307DIfz8yk1ngHy44es47jkpHojtTRJJO+TdTs6EonZKbR4+Sy'
$vscscx64exe &= '3jWoVDHEsjt6r9IomVpH6DF7W+5KBiO+LjC5ve9Lmc4dK042DJNJPb75d1XfiK1Vbu5hLsjBZjxnMfHJ1uk/eTwoR2S34M6nWqx5XjYYgAbfKszQbcy8yQ+VzgvS3WJBzTca2EvqN0on8zHgWtjBfTTJ+puAtYM8fVlw6eGFDUUlnQrbucsj2WzvbwDzbJAeJHl04lyL'
$vscscx64exe &= 'i6APoxv8TeNhFvCQzExyXJM+fNzYBdr/Fs2moZ290icoXsFataR/bhlJx3kueTlNUK3o5sbyVWhw2zVmvTwfPHNJF3APg80r4+xW4saCGYbxYXIpXGW+yaAMzXwyZRcnfN1+XmFg9EYqYyAneSfgMa1jKVkoI9UISZLY7bN4KDBw7crARRtZyQI3yE7jjP4H8MrqHepz'
$vscscx64exe &= '3/rM2QqLYiDrUpJMXMJpzmZ/KPUh2/+AwG9zGC8lpfvJb32HHb49ftfuLU8jX3dGisA3mguv03S0TkdUpqXrC2KegTS/AnQn0rMXHCgzoXEp3AYkXaTlFq08wmqI4jU1V2DsP1ospytGGoIjI0oFLneFeFQ8+hJFQsVEui4rUxwLDqkHgliJIjz3EcuXWmk4SGYmI7uX'
$vscscx64exe &= 'R4QHEIlRCd+F2lRz4tTUGdmBvNN2/kBwvZQwVTaEoYvPSzE5fy7VN9KbUxRMtrz2oTnlt2iGQ8wwxb+IVay5o8pXwuWz6n/xGOfq7ueAjNknqVa5cZjmmJRipFqEJZVAb0TyWy2ELIULB3C86HYQy00QSh+rxlnKl/1YecCgJYl8B6GddrFkBynieQJdlo4w0yUhhU4Y'
$vscscx64exe &= 'm0XCX7LRVQ7ZhHaCkbDL6fx+ar4GYrbiBn6VjDBJN3JAIOyveShNLBIC7svmoSa0OEyvXS53C+4CzuuIbJ5ZiG0EK4sFVN+v1EwmFtzp4h91i37OG6NAHeAfRKhqmBv/bikHcI5zcbnVd5cJZKw9DFqWT6i597in8ZhoUdWSEdQLhi0pwPC6Irhl5UANoLMvirwUqQxM'
$vscscx64exe &= 'IDPpeqGs7ToIMEECBvi7SKl7ETb1TzYKrI2pHLs3+NRM4rVjqGWABESo9prg1V4CMZ0PrvpDQ4b8CySWmtFGA+SV/EyP5L1+7yqi/UxLQUp+6XQnnYn9oaJdBYUGWqPbnOJdJ0BQrbMt+UPQwpbvUetTl8razCTTbajwngKWR2edu0MUZrNvbY3OqzLYPt1AenK68O0Q'
$vscscx64exe &= 'xchicuwKhl4/N+kxiyChjyN5CY1lau1hbbD0gM5h2lzWFOq2oemaZxrSy02uARYDiFiU4U4Vz6Q7/PFHFg9gJoedEL/iD1cYhGLCpcKgt3EtnvBVRtZopvFj12J2oxerwxXmvb5gh0NdpKuFwBXSG0A7K8KvhOg3N7OOpIVdYQLp4BkJocWBh53RA6YeA6d5TXaTGnOp'
$vscscx64exe &= 'oBQZWfTdj9EEqhNej6X26vjMngQ9cYNBTJyRWJyjuzoyeSabsFhGNneC5sayykB3GtNPME/VvKzjQw8gv1GlKxuySSA3TKPMxFc5kO+y9Kf4+rYbx7DA0xZ4lTdlYHdCKP1Pm/UaQ2AbdkFprFPOigPHBJpeAIL+MEB81qlbLTMXRPcNZjzIab1jiuYBgGrQSd84UWmb'
$vscscx64exe &= 'tzhJSmk2rZelFRLLJpI9MKjGevmkOH3/Of2YPFZpwabO8gqXyXaGIhxrHZIuZS+3vs0tjjMcZGXvEGMUbi6jLGr8Dd2p5pZF7MWckmDjWnzhiv0oZaEO413+y1RVswackBgoaViuFvv9GLj9lEwLouokS8EHqEv05iXvjZi1l5EKXQmQ+PztiejPMZCJ2aYU2Gp6b7iq'
$vscscx64exe &= 'wN3R9bN3XcsnlrpE7VLRQRjbtwVN93XpUGVfgRPU0DteWwVzDedA1yPvD9bgXgtTQGJOnY/fyu0JlamThY63M6s/071ozAvCk0C9AtJslmU7cHEQAdUHhFl0smuWAwA8Srf21bKMk6zzQZAIoubIH1rP9w3PlwwcOcWRN3X1ge+3CA+oht9uMEhhIEhcvP9j9y43Y41q'
$vscscx64exe &= '7tAuWidwZcoqI6RuWp8xZ4D4fJrTRTiT9W5xz5R4J1KewiEocXlyAU1caW/VbFueTCyqWTFsqVrJ7rPJSbV9j8C/5vt9+BTGwmyAw5ncmbMIPfR3eVfpNxiBG+9/1rkXytlBXf9K/ssiz25MM3T65eZQT463P9jZFR9jZjydgXS/9NkcTAqDLjYQcuSRpNprbMAylbea'
$vscscx64exe &= 'DIGYK/LgD8zmdDOBfk4eji3JHqHy43lbeA/sWr3IcoiGSmM0g4+4yJeY5+oUdpUoEe6ef3SfdzwWFldwFVzFT6t6xY5OPtzxluldqJHxf9XiY5TxDWUnHsykTVq6z+XoZWME4awTAb05He7/D4oU/AdC+M2v3uGvhivEUrGUeEQxLSD8tC0tHx5haJXpEP4jWVCeJsQn'
$vscscx64exe &= '/JcEIxHQGFhobDCPXAlBz+3KEfNF1GkAQWPKPLxobcFTPN0uyxD7afe1xCgVDy1CobNjKqrs7vtaK15LEkRWaDjlzJ5f8JtP7Aoz7y7QCP////8jT4R9SYVb9NKgBu+Cy68ChI3laqy3c4D4ouyph2QrgInE6oO0b1LOHZhWF0/TKCVvEfmSjADVP9ZpHOqtnILRmQue'
$vscscx64exe &= 'f2GeRlayCpE1UkEL7aO4VY/GNC7iaijimV7V+p0OVhRrTEoywXb2nAXmH3we06M7B2eyPKw/jg3YNmcgct8/RvNK0qj/Yby6zExhYR6uUiYNex8w8JkOjq9Xo/iadxQ5bgFXBqouuHCCo+y8mE8SwSJqte9KI/6X1zG/INIhtz/0mCAwh02KDN74FD8UrUrliM8yUBL/'
$vscscx64exe &= 'kevh/cAtToJqTjQY0KbOLwt4eQ0PiPPwQxAMNvQ8jbxZ849DhhuZg/JdeGdutgA6p3YDF6aZ3T/fv7lr8Gw+SOhn1UMkKc8t9pB1iP9uSl2yzZBGrnrAdM9m0PIG5qeIvK/W/SYTAYLCn4yfAIpYK2nHlmRJe6XKELm8OOWVfKWtKm1YZBwbWJbONk7jIrqosU5rGpbh'
$vscscx64exe &= 'iZlEx1rZgc+nDK0pLAp0wqE0EiLu2SmG+DH9dGNllNMahQ8IrQpVDypmZC4GrKwcP5jCZu3kH+VW9wwT1nH5gEYbGriGz3IfOVBp2IILCeGmRE/0o2oSQZjAMKcp7PD/IT7jxJWou8szIinH8rZvQ+OZ9jEAvhlrfsFZCv09buJoeLf9sQJBVqHn8h4HEGNTmAD3Oacv'
$vscscx64exe &= 'LQ01b8++DBYaTrF66jdvuLnhyjcFYIUz6/Z4DupJqSGuqk+kehQWsLF3r1AZ089epIhuZ0FORm6BY4YyFf3cZTx9exQ4jOlBpbBVzSY960Yd0ituEF5TX6h4DQWzdtC0xmmv9GToou/bmCqftNYnQyGQtM9uy4NuTI1ygbuoc+XdO+HP/vR3squSTSaG+oW99M3BQh2L'
$vscscx64exe &= 'qCOfKK3wnRvnWOmmSKMntapgDTprvBUKHbG/UclglW/slR439rFSnTDcGDCofrZcj4dfBMMVZCs7rBR/66Yg9MWvkzOxbarqwb2iQ24apCsYeNWdDb1MdsTtmxR2UbH5IHkFL+3JdeZWw7QP0x2YVFfREIDPbU+9MaxAyisevoT5ToQZ8P1TwavnZJzMvwmjFZ9ryf07'
$vscscx64exe &= 'ompN2p4sJpsGNwW65jz3rDJjN5ZSclozj7vmgnD1S0Il1KWXULnnCFANLAeKuxj9hhOGznOOu1tuINxoTc381qMRi+S6eGYlaFWJZnWZfcnH5CdKflyTCWv+oXv5k53CsqCixtZ2F01GLLRWoKVq5IOwAYS+np+PlZmFg3EDSnm7/88qJBHp9nUlpSLEg/+zLmZnWwON'
$vscscx64exe &= 'LIA4hs03zRaZcyrm8jZOxMH92jaRfn9r5KNsQGuMHY1jUabpE/Qh+wg0qJ7xU8gcZfDDcj5AIk/D65bWTdSINVtsCRPevEsjz3CdH6A22WMzC3qDBoEtxLv38svAqH1vvHWjryU3JiF/izgmk93Q0jsARYZ9PAqYFQiJVIw/DWSZn3VzVQx16LxNMkPCZevm/tFisZ34'
$vscscx64exe &= 'KzAmzYBfaPko5t8KdE5sLB0oi7hlx09+16gglo0Yz+cGcfAvPXoMwP0RFGPsdscb5fTnE/kK22eTsmy2JiWwfJgXxgoKi7G7J6qIfp/E63gC31+/mD7nPK2ec745w2yPH56Fecmlvfn5vx+Fr0YxrGJC/dxElbSw6mfJPMaZrzuKmNnSFT6UFlj8h3VSW1ZYkQ9KlkxD'
$vscscx64exe &= '324dthdM734zkL+Kg19rLJq5+Hvmk9pSo5w88yamSpXuQUMg/WeK1sb653fQCpFU/4esryyVVql/cg0DejkynrO9VHU2euvGgVEpvJRPRJpUgMLXmQfln9PN7YVsP7ZxwtiGMdWKFQoZ+J3+XWpwHjOwsLtR5oqJmL3MsOcx7iGhhnoIqS7tAJUyE9RIDs6iIUcZHc2o'
$vscscx64exe &= 'D3gQI6RNJ9yb3y6FVkk6u1SPuC4qKVVQRVUfKSo4QUIJBIC3Ii33wuuoF7CJgqS4PaEfHbuel/PKpKNglTAns8vnit2T0RzqFrHesMLC0AgyJ4u9BomyRbwS0BWLV+WJAKuTiyZAyf/4KHmjeiKvbJOn1WnzAsxrj+O4ZcdCPAkVoctGBLCMQaNcH6eqQ0wpnlndPkh9'
$vscscx64exe &= 'nfNNh2WFetmF8OD/dgld1NUYYQsgsv1MTv1dgW12nMa/9yd2Mi/IJhbCMBR4I0PvXAAUlL3FJR/WsJlK/yNBgiTkeCmGkdBr4usNKCfLoAE+o42fU99H6DENav9FWnE7YNHbt1URYshMa38DWSvMkvZnVr7iFB5VGU8lFxvww3uhw52kA3ilGVITv9TYcac3upt76nS1'
$vscscx64exe &= '758HQQRf8eKS4ww93HxHvFHvW1eYD7lyOah9LuHChdoO7il0hhkQTPEu/RAkgNyce7WmqfxaxnzU1zs3YrWAT2cxpEqXKztKmUt/d01CaupmB9ur6D5//6rH1ZGIWjx/2WY05tQYFBUBg7WhJKDHjAr2VgcUFcaXmj735wwtF1WaDNTESr8hKnmpjuxWWOc2zPXdSGSe'
$vscscx64exe &= 'd09WAxLqDrxGXM3ZCDbrthNuu8tAc1QkilK7wSnf6eaHxTwr/7jD9enW5eicSjZYob0WhS8rDoyaBHleWQaEEYZkP0YWwqUS1bmhqiLrhom82ONT7gIbrU1/HeGb0sbzSGfDxHqGr09a0qNGDkH1PGUP+8zoPzp4C/wbnmxQD7Oqf4ZqQyFfqEVmuPQb8wn+i40QlJ8R'
$vscscx64exe &= '6QA96VV6MCvKhpSRxZPDbCB1e00EfC6ndfUMdq3GVj6w463LtvV3KrSXROBoKEHgRD0mgEa/8pQ+yEcXh9phGBcRhn1TLDY/ueOACA0VYAIpQerk1zGrFS7wZGa5tXjH1cqAnZAaNX74NVNHOjYEB5hdBbgQtYnCc5eSvm27uug9zs2w4XgNmD+rbdNuwU/GAOZj1gHY'
$vscscx64exe &= 'lX6eujlsfjxdBfJyYOfgU/0suzpmaswx9voUFlbEGLDNn/ileE6UjkWRk6DjJBX6683EN3pa7kmu8qAHk0o3LfRcMbgjCZj98OsNWNPp5YOErU11cuai4PKeIPmdih/JNnDvoAvDgH1iUpp24DpR2lppuQvS52f1jdH2so/SmZTnjGu43NKM+AJjeffAxA3I+QazmKIu'
$vscscx64exe &= 'ze0gDBEPIHJWwe+TErCfZWZyKVWtGfE+XrKNA74BwWoPfITgsajeSR3I5noytOgprn++Zdyzu4ko8hpG+eRIgX6N7xOPx45wS+ON1q71UjQef1XydeqJrzPO/XPz8K/ZVT20Yw79pXjOEQFdJm9J7lpzcuBU0LkjIr1ecln1x54c7ZUh10iz6gFw0Ko7aVAb8KoWO2Tx'
$vscscx64exe &= 'RGro5KVu6o8bwoBHdQ7D4gE+8Nqp7Dr62hmYITJNHtUmkGjm1rl+q6YMghGa3ym5LTILN8c8LsquH+ZrV5+iiFuhkw5sdh0BiUYY5F374BpCErYWrUy+gRa1zx10YgSFR9wZPbVaIwpgr0H1wUxRz2PkXQ6A44i4oBnZ2hg86bWU/03XvS+JVPXbSsh7m1FeyRrm5cv7'
$vscscx64exe &= '9Tgreb6oT03ZG1t4s6te0tqulUN3zQv16xFxPHzGNkkPxPkwmVulow1bRZs1duPEF1UwB0UTGewoWzs/Tm9oN4ATRMW/H5VvRXp13XL2NBiKtak1aXjKPDSJqoOMu2E0Uyq2m0S5JdcM/////4D4pbTpT195JyJ/0bUr1pucvfcXKjTKtraKVdDnZ0nWrKYJhRCoAN/P'
$vscscx64exe &= 'Zm5wVdEJ22E1G7ihWA/7nnDOu0KC/4804s/a7qftcJIs28WDMq6us4VMg7pBWtviSzOYwyCH/slM0JTYi2JRHkGxqgSLPQ/Qm2rtBEjOP2e7w2tzvmqCsiVRl4iVuR//9HEgFQvbIbgdZyuzkl4RSixyMMB/2A9bGkMP0sNnWy7Zg9/QxTqLNsv/vRBYpaCWQ5aLE4jg'
$vscscx64exe &= 'LKkIkmjOak8YePimSm+/DX1X6r2v7RRzWFUj17JwCqQ8CGGdLfVecp8lv6u7FLpoH+6J2j9aE44GDzeaRTwHdQaRR7RfNo5n5zfxOia/Cu4w+pzBPPJ2lVlc1mo49UaXyDqc00HHrOPAv3xvVl7c8sUtDxna/3S6lpSA3V9y/O8oLX3ztQI4x7IL+doLBqh8XbmMVOAR'
$vscscx64exe &= 'x8nhGnp0D+AJ4NmRk0/oAkiBdCCUDGEEaBdMhra8vk1SmmZodyQwQG54DnMNvFSf+Q/FN/SaHr9VDkGvWjpioT322LNq2xRY2ddDX6aE2IxkCzMEwgKod25ioOhpgeWfg1hNGHb1m+g5ym6UPvzI8wYd7oD8Ba9znmSza4wOS5hALmXUmnhUupHkqbXkm8rskUM1HcKT'
$vscscx64exe &= 'upGpOV48UocbdgpL70pMFM9CD5S67z7K5tOx48yVdzqr9J+q3fQ4DZQ9Nmtb6uI3dNV0eWfxY4l6vY/m4YuNV9Nq4CgROm9UK3NR3nuU1AEy/PE/Q2onTcG66ZoT0RKWTOYksthU/NlufNphd9kUySfbN/osW1GGIBOnxzMDrHsZkQ+uOoGAhmXPpVda4O6DNe8u7nnv'
$vscscx64exe &= '3FO+Q5jXSbOdlXwcB5moWvGGdptIrt0+5PZcIACTtDgkmaoP4XupuQDDYiTvNgk6epiHOuvvlPcaIyFaAsEqTxMczbQJiZJj2WVk/GJIJU2kI9fROv6DODierkmiT7Jd3MlNsjlSPWAwmUkWDEEDjHrEwD9DVMkm7I850sWtNy43fMIEXgbJXSIhkzhevHfPncF7je4R'
$vscscx64exe &= 'Z7Xl2sONBtkhRBn62zRxfmzBXexTZBSMKirqPgcdjHwD6Y6Df6UU0Uj8J5oLLnvUybibyo11kjR5caOWE7HtlCMS/wbkn6aGUD2nZ3E0RsnFmQX/Z/m1tOKRelrZknkDsq6lwl6Zz0nzPQBw4SRKa6jJ7q4saY+5SPUeP1XMOV8RaFGG0JZnLp8sBBbWIC5/KlrVrn8H'
$vscscx64exe &= 'JaPw4+dSLw1Z7FrK2dtWZEufp/WMO2tW+JZXpn6rj09NbROBmjgeDvROd+3EeWIBMpHWWkZ21fTBDdUZBWGU63B4llN604yXTHayDOUePeJzd3rkFx8ghjn32FFr3WM41AUrS6+1QpBW3Lh3p5WByFdteiO0kXoZK8oGOG4UgFNEFA/kAWVV4EJ/sUWOXrcPYL3Tl72K'
$vscscx64exe &= 'DGeRZwjdcFZJ28EDAmCk3WKR6kYaRjp4hRuat9lejoYB8j2bDOTNPvTDLFqB2u0VVM31Rsb7AET7cz1zbVEFfhWqp7D1yFNQAdwUFyw/uPfAVDoXb1f543A2J0B4Qf3dP9EiqMElIDjKeDtO8VWdeMvKwZS6A8fD+6F6xL1tVE/JKXztQbLHkELfL29l6HHb1IaIKK/9'
$vscscx64exe &= '/Bl32BAh9CWnRklaDf7ct/QpdAIF/nfWHpjghP8VJ+jOgyLaqtNiugzTWnHMoleD1xIj7zH4MjvBqKuUl0dJVeY0NzImJMhuUlE6wP2ljHZjSs/NyvAq7c0Orkur5vjhI8T7gHuTnwIg5RPE4net7dUnl9ySXYSjuZkEvBNFdoNqQGZ8hdy54zdB33xROLB3WSkEgaC3'
$vscscx64exe &= 'wWoCBbWjXUoBLWEgZ00HtXXJUcMF6OuSECAgqI23WD/aXNBd5pitMcIXzlJNynd3F9YZiqFmA+Bx8noHsaVp+zqc2u11rykXYUtLI5tuNtRkIN9ddpcLGzYdhUgLhpDaQOgOZcfGGf3uJ1qyxil5WKS+bfLWPqZazHg71541aVTzKf5DMQybb3VBttBi/hjDyC5g+lpJ'
$vscscx64exe &= 'Vc0+MZhQNF0Mu6w1taB/OD7VJNcg6Zz2cDzUMdgnNUrgNTCFz1Fhg57mF2+9ovnG+xO/lo+y64SC0OEz7BKxEydmzF7lSZ0Iv3Xjb+z/+jdpgXb5eTQSU9mCDgPHlbkL2jfbFvs9LVteB1XAIE7tD6o6j/QWThDdu+xF732d5fEr+ojqnHwFLH6CkGyJtSQj+7lfSpyY'
$vscscx64exe &= 'DCR15fBoA6AO5OMuXxUQkbT9JrNsxVYSqq95P3WfzinDmGiWLxTPlwQ4wBJfaSdtMdwX+x8N9PRLXO6shcue9+nQRPn2DRN96fnHXxsOQgVnp+njvXq2rQSgNDCQ/qWGNWo9XMxw3PL7X6jv+lyYOIffITm9PtuY9kCNI1HCt8h3YFNtbHKfghmmr2lWeqJKOgENPBzm'
$vscscx64exe &= 'Ee8xj6Ba4i62zLdy92doO2IYOQM6/xEPAUka6H/D9FpJNxJcmjlKOO7Vy6FQTGC5uq7UFYp1Rwc4VYjhd4p1qcrCr4JD/fM/vieWKEYy4KbbV/kYyZZPpjId0QbTDv25ABKyKm6Y7FOJ4KlBIjcGOnYZEqlhb9l6K5tJQe0H4PQ5eGD6mUkHPpQmI/fLe/YCPlLEdVIe'
$vscscx64exe &= 'yKCCHgqsKCKeZGEmj82YA+T6oKl6f2bf0kbPIb3l3h2cgJQyqNRrshErR+H54u9RoWiv6G7tpbJHCy5fBYxiKm3/vnEIdWdDncPwJUVyn/9PeFFaALKXfgwmpl4VrxB04bJQFrSaYjy76+Tk0IMKpSM1QQdAPzi1+QJ4EqGx+8atCQOWtr+WisaKlpPhUcSA713UAFgl'
$vscscx64exe &= 'hkciIqNeIpM796WqDpu7CiBSmcf2Ak0M/qQUlf2MfEx6dMezwFWBxgSR5wDjzoCUt8i9UV0MJ2foX45T4kvS7QBuZy74Lb4VlDXg8FnL6lrWM78r2xBgkLDrMqOn0yn9pCUsdfJYNiD32rq5Y/te/GfeDSvT8D2ahavPaHahRwHAHpUgVZDAsm1vA9hO0M5k+Ruu9+yh'
$vscscx64exe &= 'ip5Fj7uLQRw7us/JyYkegBmF/rlwDJPJNqfamWcnb8ldE3g0SA2nthLhJUMqXlOZHMnP+dfDWdMnLAZSaTj2mspQ6J5Y4N92YBJdwJQhuAH4Wb5TaHaDFLqStLU/f4kND8Bk12vuQqm66+SHq7rWOZXDtVagxu8nOfNLs3vgteHc/BQilzVwLWVd8Ebi0W3vD6JHgOJi'
$vscscx64exe &= '9hG6WkX0MLY88B+/J8PHzST/0IwuqZbUY+D/VlOFUrwfgWHIJ/OGHLdkbOAFNjU2PfYcIJDf+jgxUrrXHeUuXsAUyov74bBBKNLgjEmqlPPw3KHxnXteo1XdeOmCKvVPdg7b9Zkq84qqgxXTrODDRdbkY6CX3TX72Wm3iWgDjN+OSIs39os1VcUmdg+Z9BvWyyugqsjP'
$vscscx64exe &= 'UfnZPAsDiQOhqasaUXDj+QSyZCDlKPeqE0U1tMaB6zI/jRlyFdZvKRd/w1/ZU7K7J3s7CfTGEPVwEGIdU9a47zzZAJF7YPsmh4sAoRTZ0ldOVT6B6yvamhTdUeMRs24lvGT2HFgcuXKdFPA9cXJwMEfV+a2RJiipWgrm0XclQJiE9rUBDCIDeQC1/wEmMd7xlgS4/S9l'
$vscscx64exe &= 'MWy1Rj0FiVI2l6LB07WQz0qqZRqeRgBigmQwpWCOi7wGoQds7XERmUU1m468BDb8zHl3CBr5FeMvoLNt/9Q2NJO6TQAzCBUFFuzRjYKsJOqP4/G/Ils+k/lQg81HbXhsauYS+huW8mfkj551e0+wWp+oOdsR6pBCeIVuqOQRWHtz8yHLjpdBL5k2BvDIbToD1OiXQGO3'
$vscscx64exe &= 'HYSQHQ5+OtTUJE2k951V66XgYw3GF/2RorCNscHfHmOJ5FQ2tz3AFlmjP6t70hVejuABiSOQahsDdiRphZiRtGzxPOpwhQUYHmdGVpaSsr9tZDIIW24uJfd2wY+dzzdqhyBA0DGj9qIPUXu1dQlfQaC5xGWt4mZ2PycqUL8JBWuRCEMwxwkrXU7KaH0aW9s+fGe3AyzO'
$vscscx64exe &= '47Qhbl/vs2FPqTdStUYq502QC2EL6HzLjrq3UmSGJD//srJVPjvtmWv8uKtCmTjplqgXvOZVpHCUaKW9NdM0ww8b/fPH2KCSHCZ4KbfzLhM4GMoM0hPm/ORetsp06yHuJRc+bBsHjhrwQlLeDpm1QaGc7slFD2nHrwtP/vorAYgg7vTx9oVS1MuXbgZhuz4P9LR7SWqw'
$vscscx64exe &= 'BAR0dzQpc1syv4xsNGL7jjvrmXEohoZqWGw5DKjwhTgEnJHKhbQC48YSo6O6/6lMptE2wpNsfX1ahxx3srmDB1W4YwLhLLhLqT763J/UxdLfJG6FlUklWXeWJudSRBaTsoZ/RXRnuZzelYa6ZgW3bZbwjKrjF3vMR+Ai7baREBy9vNQtM7kEZ9VQpk6Vd0eP6E35NBJI'
$vscscx64exe &= 'TkM6SpLVNw3bE6ysSLpnFcWS4za0YzPSOJWcj+eIuJ/H7/7yDzHmTdY83iHABPwnnJIhdIYbxsqTczvGn3paHmQQpi/iJetRrwtSStrfHJSBKdSR8gFqtt+QRK4n+3TNFYEF2lsTHFz5TFIHEn0TcbEPZsNP0MMtALo0yOrCQ5WQcnDUU7uh3aYJg/Jv8rrakdUPUYgD'
$vscscx64exe &= 'XCFZBMr2zQA2jxjKYq7D7Rw7Lw7XuD3uk1hiwSG5YJEty7Ld0gwPJ18YNmfbpt9P/7FDy7sFuOUXgdaOwqISNNe6AwX5eRUCR3J0HH7AbPgYAWLhbjxZIRKZOTmrfTdTdxRxvgd24kJvQ/0QnDjWmxITGeeojkPmPaFajKm7lsX0byG7q4JKq9Dsh00dBpyP1nxB/wyV'
$vscscx64exe &= 'SjGjaD0MLpVtIj/5CenCcVbJqAS9VF3WiQr/JQIzwODL2cDSklHKkd56xuKxEyg0I5/mRHmIrf7S/wSgDpqIZumISSm39vZJMgvfj86DOhD5axE5+yM5mEd4HrbBrUa7V6NuCatbcDS+U174XRYN3jeC//WST4TjouWjg0iZpM/H5WBz1EHddI8EJCpg+/dJt7xDEztR'
$vscscx64exe &= 'UonpP8fftjARuwj/////linoDg2o/x+XSVryvd7IGoqTtEfRaLpixaD+D7SdazBV7vABLT2UwkaXuv8n/qrARfroFe0U9MqINcQfYxSe6UonKb5xrwq5kFe2eo3lPSL1cX2n8neBLuw3A0d603bs+SgKAJo4rDXhtAF1U3L/xLRk3gCudDbUMz0BDNq6Rr126ERApxsw'
$vscscx64exe &= '8cMacEmB01jHGP4iMQ2W30+cvUyg7uWTVfmc+B8gYgJHWVQ3OGWb16R8/0Rov0pBToVVZlBs+1BRA/HgiLW6/JiMi/PWU4h71BcPpYPUP/GFy4IopMTAt9k7AwA8iS6Epoav0ZMY88tXeKcEseUfqYq5qb3uN9pARdSbJLxGbWN1Hf7JZNZRQWAzXFZplqvirn8pl/Dv'
$vscscx64exe &= '48S20mIWDmEVkOP/KU9wm1Z2lmjUbf8RpmjaKgnwe1dguVMroD5psf6DRMObe8J0WO3SMBUrNYw1aC/CatanI/yW6oK3YzyAPKKT9HmOAzS3yjhl+ycQVSP7Qmbq0QrGiZ4n2DEMcBO57xyR3QxGoAPtT7Y5b2cQzEVbeFrfhHtLjDGvlYcytA7QsgMxquB3aBKltCn3'
$vscscx64exe &= 'DCAl3W8bAwgxxf8pDxMV0wtE+65/30sq0m+h1wNwx3qkKIl3ddpICwX80k28Ddgo7F68ZjB+42jBdj3aIvHD932K6/lQ6wcKJ2wvnJ38yVMu3H26UlBSJmQFf5wdsuK2tFHM/Zk7F5rVLG89WBk/EHJUXAiupupDvAHmTvEWIj9/L0PQvq9zb6I9zC/tkBqB2qhmLyVD'
$vscscx64exe &= 'ub1rwz3KyPjKdY5Pc8P8gyM87PQ7E1Mut/1s+3+HOAcSyAADQIemyBP3Yqbk7JiaNmlGapJ7lapnwyGkHZ5jqbRjT6eGJWtJv29UyvMn7ndzh3RTDQEWgFa2VhaSz96pFHEz/U2ou/c9MhB/fiBx7KOItn0+I4TwnBm+xOJAzRqIhbiOA2NC+k2WhfNgEfGa6wGwOn0L'
$vscscx64exe &= '+zmFJXirR8+MXtJFDWafZVams4jkchKjMBYViPf4INcmdNwd/FHD+lnzUbw4gUaejBc7BiwhWZtr1EET1hKia2G9dHQdTHHBx2e5o1YbQ7V6rfHSVH18czG3wX2gSQtk/cHqDfXp54tVmHFfgEcfnikWuC+RBlBJO4/9/4fvS/TTJFY6kUmIlODGblvZVbNKI2TuGrvb'
$vscscx64exe &= 'gDEBRdIf5d39T6LWwENzJxQ8AGSX2Fh3W5r/gwC56DfHgUZRDA2uxl3GM7dpLw0+ZBVrajwvUlWuX3yM1bCaEbvRn0IjJUdE7M+fGyYq2B3ru4bJJtYXzaKV8whssXFtB+l7EszwLaiHdNQFTcGl8nq5tHZQBDdFLFEKj4Ih/g8wOqtmD2A/z6ndnCOOaAARPDaVCbcg'
$vscscx64exe &= '0liokxL9Rvu7YfWzTnYCLSlaXGjMmlNECNpurRvVH1zacX/MAVh51PdqZq3mFz1F9hRRHjR3ZhJLkxf+w+OtZPHmJVicMvDPxGodY0MGilGoRUrDk6GGy/V1nKS78UjxkMgJiXEwHPT6R6qmjf9oaSxoNliKNWT+RBukrHLCNsmynptA0i6egILNWBMYjV0AdXrPPTe0'
$vscscx64exe &= 'MJ6Q0vREQUhuK82IeEEwAZahx0YNvuYKh2YOuqHOQTd2IBQMiJi/T8VQE8WXaYHs+1E4p+ABxSZCvN+CqachFsfP91M4myNa/FE3CoE/1x+7hJCNkH5MX/6wVoUevtNxOF7sE4gkAQFHaBSO90LZcOBD0CPwsZT/Sx52gyOlW6PW0CMIAQ2YO95RyArXsY+XibnbpVeN'
$vscscx64exe &= '4sZTgpX7hkjJS52/7wxg23U+srELDhoQMnDAF7trRqvxgQn8rK60+yDRdRuP2gcOtMIElZdL8dmk7tZjSvHOmkLI2bPhhHQWq9r7Wr97Z8x6JzR5yI3mFFUU7qfQ5VdtfnRlq5l29LRYgqmCR8SJdLsalv3+1uVbnrX543Vp99YnPobZZfMmPHM8UbdO+e4tvV7GptPr'
$vscscx64exe &= 'IVcd+pU68ACmN7SRVQ7sYli4RmQeOl1mUMToC7G26X6Nj34d8PW2xklxoDokJcDGjBB6k497e+/fHip/JAwFdBG2DIV7F6kU9/qvzVT7pQAFMntTepSiesoOwwGne59ncQaUI9RwRLfpgAxrGzq/+dUel1vfeCCWd1lxOQAaPz2Yf6ENyqEAc/Yjo0oIK9GcOFr7luls'
$vscscx64exe &= 'NHLZHoKL8w9f4MpvjHUcra5Ysroabsrl1kWrcduNFS3rCKhlIpyODuc9FTgXJLSS2rvGCOy80uW9bBX4w2yVS3TzyBMfAk+o53dgOyvSe75KadgznfF0snupvtBiG1DuHBdKZ1rj/YISjMmuBc6NZRGhIDczmuhzH/qxlpFo8dJtY7WU2mhaHdUt+/hsETa2AGJkJEn2'
$vscscx64exe &= 'FI3D92SQPJoZKzZYC1Kfb2P6lYX9BvwJCZlNFZC1Ym6N6TCw+92UbdplMJ/LSKTNsmQ0qGOFRXuVS2nCFpFiOW/cjWjRv60E2DgtB+Qy9fFuFHWRjWDIH+iYjZm6pUXYkq1qn/6i6DDCXmFRZdZq63xXWEJTn3dV7Pq0H4ILb/nqu3r2Ni5mK1pMCI0FttM9kwR2sdzI'
$vscscx64exe &= '1UBlly0Lkejt60GI6F9ny1oLG/9c6b8Av1twC/glXsxqYCYM1FehHz11JncmBtg6hSiKDlfkpFEdGLCzmi3AxdzpSwx6hPvG7fU1dMAd7CjpLbGJL5WpBAAFElLG+IHfHwv/dzdDflTww1xXIXWV2DTeBM5CIjXrXrGDv7nVFcYH6ggJ2YJ4rduyrz3tyeSSpwD0wFOV'
$vscscx64exe &= 'Pgh1nvSTRkjt5c9S3ofhPhY3+XzuMeu/kO1LoorCUR/ESl9XgWicpKRpcXlAFRR4QCQUAP/1oJfkh78rJ54ZNymsAU/W0jD5snHZFXopE2+kA2J3iKI0qLcoZIllN2wqBJFHshVxgGtMkiqNxLVA6YLbvIk9lrhfbFA6bnUh2wpbmROEYyU6THfBE1hHFA6D4pL/Gs3s'
$vscscx64exe &= 'E7IPj83+rxrATXAgxpcVel8QSIKqk6BVVODANkFzm6bIEl48E+2StawK2iWQvDbbjNykFaJoLJ8BeZREFiMYIPue3ZKaF52BLfDjoo8KmbTmHXSdAKnhpFxF9Q6duNTd8qnwdi4xa6QUaNgSRdCFxO4Khyf2CU2I6UXjvDu0IRe1swxpWwXJm8p0MOnBa5+C3st5U4uP'
$vscscx64exe &= '6ZQ6BIilWutoIAXK3ujC/OxY67RJoA/E5yMXHHgMIWYm/cxqkRGYsO8d9Mj6RtNEqGtLpPXzM2lHyXFzK3+i88p+JhDwfLLtLQAmyxV8V3B9DNnuZuAfBYIbIG9Q71UKmhLPK0KCpSwep5OfQB09vBwS1S33iDIqF3RsQIwzXWpKAAZzaeXc1J5jk3etabPtcQSKme/h'
$vscscx64exe &= 'MkW94/odW/eS8mfFJLGtZpWFCP/////f7QHgs59DOiQl2zIn5pTqBwUA0IirUOwy3MvM3nQwEE7yfw1LWigWBdGlOJ/OtTBImQ12H/d7TzOo5TW0JiwSpM/FmxYMAv08NCtLP/yhreXe//AJi/s8kSvXCJqEPr72ALx4tGgH85OkRR5QvJ0VWXONPI0fldg9iPlyWrTg'
$vscscx64exe &= '6KMyFamqQ73F3v7P5sD7+y/Qg64KhFo3gzqsXZMBloIDk+0jXceOW7hujubzc1f0JFdbYUxyYqlA499ynmb59lkagh+em7fzKBF0doTuXjL0TPo8WQ1rhZ0prwX/J1svjMMkgjOb7kg4qdWa8koUt9Ut9DK9yLUONuGNRYGgMU+Fa8tXS+CyNAqIxIHe+QGiQQob0gnx'
$vscscx64exe &= 'QdyvgSto6TnqFudt372wKKSe7mFFSHDJgDaern2JwsWlVxWp3jBrHpSmV/d3TVFdny++Zfw8WvlcX2JF7rcHsPyji+1iobCcDymRk4guY6GBD7WC1K4zpVS6tFDxMDUuUuSsojLySZN/G1A6U6GsdvlvSjoVcRe/hNIHKcT6mMp7SmCmzTpUQIuGAnfK119XivVNR1z2'
$vscscx64exe &= 'wWfxgJdm5H1OZle5cvn38f/hS/xo9HIUVpUvLG5Vh5FRDJZOMNRnn52c6jO4rYHDT0mf4FxBt8nu5eCR9ySixKHgdhst6ok1vAEB1eo2kmZo+b4V1XWmW25ZKI+Dd49YobIAGH9AVQ6ZsmAHpw7CNT5ULAadL5o+zwzeUjgeFbJ2h3NeoJNgren+gvggoW/T0Ir43LbX'
$vscscx64exe &= 'MxTSF1FTYaUvmrEB3ZGDIIy36VuzSKHogP6lrZ351vFaIfpmGYXzmq/yUxWis+nc91P56p4FO4itm+IkULRCmHKKNsnRqwrc6+EiwBOUx2ZOO7MgjJVnF4GMm2LLo21S2hAUCnKT/wIcnffBErBEm7qYLc8ul3uqiSMfMh0olWeuQTHzbBSAVmJlbPQIA575NyM1V3mB'
$vscscx64exe &= '9E1tKJ8mWM53rQ7rSwRIzoluz/Wtjux+7p+LI/IJk46G/dVWpNqsDeaO6YnZI8dNV6B2qusPa2f4mRkHZhzcV3qhP3k4718kcsKNkqywY59hqVwQaueQFCR/zX/h4VmaZM2qdLm0JoK4a5z8U1OzMy9o3Ozt3JpSSR5mGN0O+87ssDI9IzJ27nDY3E7pt6vDkxBzfSl4'
$vscscx64exe &= 'fp4RYvNShI5ZxwsqH7f/2WzksWyUWT/uvd4aqCaDeF7cIcbQ4SzrYwG8/fOWfSUc2whatjmwClPeZcZkQGldku7TNZrgQnR4CoBj53m0y89mFh0+RmiswTuKt4MzlSdJYGVDcMKuwOahNKXRx6CzI296lgfalIwSjF795OQzpdicq3HZw3H6O580XbhwU1zSrr03L4zI'
$vscscx64exe &= '0lAM6jCsZPB7sP8UclywV7lOdH8T3cgGvMHvoaxNbWDaxxDamh7eTUI9Ue0iCaveKtym+9M9mrc340gfDsnAyxuNnS868fAPRAJDH947pBdfGqi7GmHI8/oUjLHFJFqJawk/NWMEDCWb9NarRroqobPNy8SaFQltkuUiB6tV9lLc8fUmVlyQxn26a3DiIhRHuM1MJQWG'
$vscscx64exe &= 'KMPzZqz7InObAybr0ZKPnaBtrUm3cSYWywq3rIZ1zT0lha24+57MibfkNlQQSfLpbzi/c8jjBe91p7eM08vSV0PThvEWm89QylUucgvnOE37tOxkGasKkENXArkjTFL4u2aJd2zGikyD3OA0F6f5bX5qkWWblUt/rC2fWMJP3EGbkvVeKFFZRLMMWsYezX+tmxePNsEV'
$vscscx64exe &= 'mFnnmlBpLe4qLchnN3w32XR9W5W9LEsbrsSr6FLwmkxiWPar8gTwlx952Cn6m5aMxMeq+6ZbUcp1GotMNmH+wBv0bUsTiC1zyoPV3HJX4gL839R0tKwmKltVcEgI2dUYfhEd6K5ZRoZbFBZfBgfJ+IK54d0+htTW7ak4Bkqs49KiVPX8iS9FmcryoOiLvyfevRqIOttg'
$vscscx64exe &= 'zMQqg8rSJ7dD8qJUI3nhjp8qH6B0iIV2qf70uQIf951uv+uF7ZfeFAvh/C5amVeX0cVq7BtLTQhO7MOaa8TOYqaKsxQpi7Uz6tdxxYeobuonDsSMi/PfvARXHHEzTSGP33nQPdAp8QEsES37TUAExeuNaV7CqeCcf5JRxmzp36EAQtyf/uQQ9GncBVcK4YJOvnEnaCcl'
$vscscx64exe &= 'uUDVNY7U6GZTiWtI9Zp8oBe2PF08hwAiY/Qn57ax3H8Ii1g8mcQMffa8S+GoznHYa9+unIKyhwBRdSI53T2dvVE5q0QPnVTAOhU9VJNDVJjmQInJiNEsXav4ojkqOmn1PDs/jXVdTomMU10xBi0A3AnwH5PGBqVKBeCOHrcOxpf9r5XEz/ILrLC44tSjk1jbY44/Bsyj'
$vscscx64exe &= 'hMnoH1/XR9d4c26ob/UTUf4/xpn95UeRnMuZiEMX1LXEr4sFMmCOfkupqturttYaXdcBdtPRK47rmrUTzYNl6AB7PvgyYUQG1JbC3FH+jfYKCG5zTOs0noxffKiiu7b3cjyseUeHJH2jTknokofxs83S+ZA9moWjMxrYBx0NQ9jrcK6H2WL1h1L9aP0JujtsqHA+QDQh'
$vscscx64exe &= 'TrZ11zuQ9BJ7sEyM6/7upjoSCPGw9HYecymoWB7wjCe70dznHQc/kqHUXU2wGxnnel1PrMoUveBI/DipmTDLSnXEmGYWtGM6G6aCoDqObWA7RqkxK/drkmR0QysPYqTTvMdFhIw18JK4Hz/1O3Tbh8rgzW8J50JvJkEk/VV5h50gj//1TRPWwa44/dYC5Ymx9dBPgEuE'
$vscscx64exe &= 'l77X8lZQ9kxDnYY2b2DtK1OwpB5yStFtIUE6Z8roQLLfCJVJAIvec14xGMIE/////6v0Ha4BGWzGG3Mo8SUHcYWB0/prAfZHhrbmHIIWmHLlfQWL7x0RCjOhdIzvxaiVUO9nuZVXmdYT4wwHxGZ8edwpUfo7kBVkajclIQktTc7ywR1y+mYfiNm3MBKnle6hHudN+WNK'
$vscscx64exe &= 'MBfgHwf/jRVUEVyBd9b1r+qv27lnTS5dCu6rLdjtSgvwgiw1g4UMOVgPAoFUAhWQEyJ2e4405T65Y01GoCUgs8e3zkk6UgPvNIfHQNkkIqCuoH8rzSWb+y9tx4RHZNgkZ2qEeKRf/5QqjOgHwSvBYQKy1NUYxZROb96K+DaqEG3/96pOn7dLxoY/zoG3eKMXQuTHmq3g'
$vscscx64exe &= '3OJZUIElmrOUbr4ER5SqwwsghJNlHrSC+zgSwPlR2C8eHvWWHuT6chxdbgi62JdCMjr53IQ50ENnKVLfYLF6LIF3rcSftUED95TW2SJy3x2BbfJCT0A8iNaY/z1ut01TnC/JBzknLzM81k4eZad41jbUobZZPOt71Od5OtoBy6VuZ8IFJ5cvVVkayLuNS4RiBcP0nOD8'
$vscscx64exe &= 'VEp7oGy1oYHt8qcI/zSAD6O5EzKjZpb3enbwlBXIpV8ddi7RYbE2pOtQZyigLlT8+pyTmEDcGg6kZPUbhSXSz0JW1yo2fcRIFnAHViowOIs5DMFa2OuATjdYX5cmw0YBKghCvUO2MRHVdw+KmQ8YinWJlbj2eOqU0WbXiOusOVushQFj2kpLFi5L433K+q5zZwhaYVlQ'
$vscscx64exe &= '0Gld87Ika2NEybM3rwRayf3oEevxB8LNzx3Q2Y3r0FvN+RyR6/k6JmYvNcIyxVgvfUEl2oFGKtmROoi1tbF7eF0Lg1+5fQ1aI4VuZmm3Rb7tJCrsm2vkKu80e5JHfc3sI4QQeKpQn6pZZoNygZE22k4vFGmUxOIRgFqpgnro8OP01WL0eoS9ScJ2GjhzLFKjOek1Ibt0'
$vscscx64exe &= 'eBoUmPrBBuxPdoUjhWJwHEhDKl0ez5Olp/ZghoT3stZ/lgh2GYARmDLWsYeAAvJBiGq808xznvKMYYMVw6zuXWRh9RedfvcpuTz6U5LyniIJupUboDY29Bd2HE87lHT9rFtQuS4Fma6e7DUlfMUgfkKrGkK3uX46uytebao+mIfON+3cA5+c4dt28EIDhEYkPMjtd/MX'
$vscscx64exe &= 'k+APWsek4DIAAAAAAAAAAABTVldVSI019Rf//0iNvgAA/f9XuBPYAwBQSInhSIn6SIn3vvbnAABVSInlRIsJSYnQSInySI13AlaKB//KiMEkB8DpA0jHwwD9//9I0+OIwUiNnFyI8f//SIPjwGoASDncdflTSI17CIpO///KiEcCiMjA6QSITwEkD4gHSI1P/FBBV0iN'
$vscscx64exe &= 'RwRFMf9BVkG+AQAAAEFVRTHtQVRVU0iJTCTwSIlEJNi4AQAAAEiJdCT4TIlEJOiJw0SJTCTkD7ZPAtPjidlIi1wkOP/JiUwk1A+2TwHT4EiLTCTw/8iJRCTQD7YHxwEAAAAAx0QkyAAAAADHRCTEAQAAAMdEJMABAAAAx0QkvAEAAADHAwAAAACJRCTMD7ZPAQHBuAAD'
$vscscx64exe &= 'AADT4DHJjbg2BwAAQTn/cxNIi1wk2InI/8E5+WbHBEMABOvrSIt8JPiJ0EUx0kGDy/8x0kmJ/EkBxEw55w+E7wgAAA+2B0HB4gj/wkj/x0EJwoP6BH7jRDt8JOQPg9oIAACLRCTUSGNcJMhIi1Qk2EQh+IlEJLhIY2wkuEiJ2EjB4ARIAehBgfv///8ATI0MQncaTDnn'
$vscscx64exe &= 'D4SWCAAAD7YHQcHiCEHB4whI/8dBCcJBD7cRRInYwegLD7fKD6/BQTnCD4PFAQAAQYnDuAAIAABIi1wk2CnID7ZMJMy+AQAAAMH4BY0EAkEPttVmQYkBi0Qk0EQh+NPguQgAAAArTCTM0/oB0GnAAAMAAIN8JMgGicBMjYxDbA4AAA+OuAAAAEiLVCToRIn4RCnwD7Ys'
$vscscx64exe &= 'AgHtSGPWieuB4wABAABBgfv///8ASGPDSY0EQUyNBFB3Gkw55w+E2wcAAA+2B0HB4ghBweMISP/HQQnCQQ+3kAACAABEidjB6AsPt8oPr8FBOcJzIEGJw7gACAAAAfYpyMH4BYXbjQQCZkGJgAACAAB0IestQSnDQSnCidBmwegFjXQ2AQBmKcKF22ZBiQCQAAIAAHQO'
$vscscx64exe &= 'gQD+/wAAAA+OYQT////reDTzByeANGYcFLiPBAAATY0EQXcaTDkE5w+EQwegYHsAEBQsjhAUPI4AgPR/HJQgHPQAcAtBlIgdjL4A8HCr/PAaHJQDIDyHEZQ4jAsAgAAAEGCfghw8gl9QFAOwHtoSHwAGGhDriDEZnRNBTQCJBPVAiDQBORQDf0QNRVnppgYlB1QkQMgJ'
$vscscx64exe &= 'BciD6gOD6EEGhJHw8ASdSAU66Yd4UAdZBoCECtjBFUKVABFIjTRYJUJhebRQIv5wawmYVeAaI+0UI8XUGNB2QAHEWkSVDMRhMk0BwFEMwBJmiYb0EQPccUMFQML78AmcFBhMRJYK0EgA1JyAnG5HVUwQGdwXldgOkhekHVWQF0+AmRcP8DAIXTcAFhQYEhqAFDxeQGSS'
$vscscx64exe &= 'CFxNlmjIHCUjSGoBMVMhA2ilQHCl8AXghSHzAU9BKciJAEFpAAxFhf9CeTCg8UBIl5IBUC5UwIGeLtBIVAOQEC0Rr0NUrzDQZxNAhMgykI5NUDL+nDAQA5EeAQGR8wc1EulBb7UJAOnxArDp8QGRa2GDnPHYNUCcjhlAEQxvQBnBQFdEwfAFyMHwAR3B8AGcEQywAbwu'
$vscscx64exe &= 'UgsMBbypAHyCX4PRfhCJUYURihKUaEweR5SQ0oWDptCFQAR0h9BIkRvUGcQpEwCZ/QLmAo0zdxIZpYIAnY0BSGPAggQhRgBNjUQBBOt0eHHzBUkMxUAqxfAFUQKmydA0yVBBvRBQNxcUkRgkkA1IGEBQcYGUq4sQ6yf9kE2NgVgEFRy9J7QS+T9RAkGEOgVClLjcq7Ag'
$vscscx64exe &= 'Y8WNiUFJjTSK1pAYcggNofH1AQ6BUdEPr8KBEUQX6gHWngIdFxJgppBosG7REIRsHiBsQC3mARBslujwvwxSF6nNIESJydPgBCnFRAHt3gHy8CglTAWDaQUHuA0SgwX9BA9MxXIIEqTZMFKYoQIHrgcwAMYHu4aNDwBJY8DZccoEBS2dx5EdD2BhTPAHRQHxjgYs6xft'
$vscscx64exe &= 'k0dNDcoEkmgBGB7wGDSIDhQ0CIA/UJRo/ODYgNhLMWgeEP8QjR8EMegsQAYNjXD/DH8jifHdIXkR0+YwSAFJCWoSQDGFlEIgzNSo6BXusB5F0Qi3n5CbkR0vEBQNsF4UYF+Uoy2HcFCUot0IEPDvDFJ3nKQSFGxO4NuaxwAQpkBkYhAhJrs1NlrDJgkPkKucECYJz7Ft'
$vscscx64exe &= 'kqAagSYJyrURUJTgLpNAEEUB7V0BiEH/xgB0QIPFAkU5/jx3TRoOaCIQWQomAvHfHOgiAAIPlcIxwLoRIyAJXChcN80yggtF9///VVMW1QHdJgl0I+sHILKuER0wkIi/QkSCL1IhehUClJhPsBMDvNUVBMAV1BXkFfSVDILl5YYBuQAgAgAAsgVIifvrLIoAB0iDxwE8'
$vscscx64exe &= 'gHIACjyPdwaAf/4AD3QGLOg8AXcAIzgXdR+LByVAAMEAD8gp+AHYBKtIg+kEvIP0T5Bcl71egBG+SBCD7CgSGgE8ALAIcJAATGe1+EUAgNTICANqQAAAgRQwjwsI/5ZUUAcwUAkP/8cIwAB013kKSA+3F4FoILCugJSYr6wBAP/I8q5Iien/MJZcpJEBkICUOACANDiM'
$vscscx64exe &= 'sK78bwrExxSDxChIi65gZChRCwD//78LENjcAJWUGB6Em2oBgZSonQIxyA7yT1CN1Hh4EdgACALwBwiG8sfUyHRAAtK0GEA4dJACAND15bWF1EhEggSouxHEddwBmB60s9uvGxEAj9UdAeA9AfIAcQXSG4DBAWAckALFN0UBBAAAgMP1AQkgQARFAqQQBGvAEgDk6mAD'
$vscscx64exe &= 'YPyJx/8FkO0TFBoEAFjBA/wFGmMACjJAQwJWAFMAX4gUUAQgRQJJAE8rAE48kEQBRiwAEAm9BO/+LRAAAKEMFkBwFxz1QwQaBEGgTgAyHwKA/q0AAT0AdAAAcgBpAG4AZ4I1AGkAbABlZQBuCgBmAG+MoM0oMCoANAyQwyFCFACgAGAHsMIFQ4zQpgAABxDGC3k1AWGq'
$vscscx64exe &= 'NFDWBnJVBELGB3crAHNVBCjlASkcQBxRZIzgxkogAExEgNoOgcYBciQAAkCkSgBLHADHA2+lAGmjxCLXBeIJsNMN0BlVRMQAcwBj/SFwHQJ2aS0gAFE8gdYIUBDDMloDYEUCbAB11UB02VsVA1cgwBWlEM0QY5xShVICMtUeMtUcAlcOYgTSI1AGENcDUBBBV9weAhA+'
$vscscx64exe &= 'AA99gVY1IEVzXYE2AC79Ay4cUARDIC4AMSww04Ww3WnRh8HAD/0UdOzSOaHFVkZoVwNQHufCBHirXALIAgEtBGUlBMShXiRVNtFGQccIqdUBTdZlIl0UcwxgxgX1MnLVtEARYRVkLmQQVAJgx8YBFXAtFnLNIp0zZaslAS5tAEDdIU+k1G5RXxHRMVVr1R+PAFOZEFDB'
$vscscx64exe &= '4FoWQVZFMNYK0IPZYwugX5HQScG7tdSt9A5E9SxWolUAcuX6AQAAJIUtVKxVI25dAGx1gwCRQIAASwBELDIIYXNzAGVtYmx5IHhtAGxucz0idXJuADpzY2hlbWFzAC1taWNyb3NvAGZ0LWNvbTphAHNtLnYxIiBtAGFuaWZlc3RWAGVyc2lvbj0iADEuMCI+DQogACA8'
$vscscx64exe &= 'dHJ1c3RJFm5mbzXwFTPcQw5zAWVjdXJpdHk8REgEcmVxdZUAZWQAUHJpdmlsZWcyZXNwhpdFeOhABxgSwFRmV8YGwgZIET0iYXNJbnYAb2tlciIgdWkEQWNjZXM1AWZhAWxzZSI+PC/wX0AeD0d49eA8L62hPC/A0WI8Q1YGV+ZGllHmNtYiRWR0Qa1E2J1w9VRJeJEE'
$vscscx64exe &= 'AEKXBwBX1iNyl+Y2IyAjAuIW1gYDTYDdUy5WQzkwLkMEUlQiIHbtVDkuADAuMjEwMjIuAjgiIHByb6ESbwByQXJjaGl0ZQhjdHVyAQBhbWQgNjR0UCfGljbGsFSWR9U1kF1hNgaAIzYjlhMWU3YQg1M2IxY20RPdLEbfIE/AdbUi/OfjWpD8FxgEAFQMAJAJGAQqAIxM'
$vscscx64exe &= 'XMEEnEwcosoErEy8wgS8TIyjygTMTFzEBNxMHGXLBOxMDFBcbAAQaqocpMdBihyEyUGm1RwEULQ8bM3D3Dyc7sYR2gICQOp8TJDBs0AWPLxUJOVUxAQwI+NCxMQE0IQwZTUElXVAxsY2yiJSLPTGVkYIJCHwxFQUVEUFQ1IBRVNVVElMUzASMIXEdBUElcQiHFZTUyiR'
$vscscx64exe &= 'BCEGA29hAGRMaWJyYXJ5AUEAAEdldFBlCAxBZGRydQg+ApAm50BXF8bGBIkYPBaEwMb2NkZjRnJljPYCUYSXBi/gAvADUOc2FlZ3hkYn8FWGN1YGF84BBDBHRwYElBX0ReGEpUUIZbwAAAAw9JbklkaXFibBlqYXATDEFshQBiSXEWD1xlbXVnYAFUaH5pS2YB4BJBBm'
$vscscx64exe &= 'VNdQCTBHN3fFDwBDcmVhdGVWcwBzQmFja3VwQwdvbXBvbtkJOQ8JAB9uYWx2Fb8F8Eg='
$vscscx64exe = _WinAPI_Base64Decode($vscscx64exe)
Local $bString = ASM_DecompressLZMAT($vscscx64exe)
If $bSaveBinary Then
Local $hFile = FileOpen($sSavePath & "\vscsc.exe", 18)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func DoBackup_PrepareExefiles($sTempPath)
If Not FileExists($sTempPath & "vscsc.exe") Then _vscscx64exe(True, $sTempPath)
If Not FileExists($sTempPath & "sync.exe") Then _syncexe(True, $sTempPath)
If Not FileExists($sTempPath & "7z.dll") Then _7z_x64dll(True, $sTempPath)
If Not FileExists($sTempPath & "7zg-mini.exe") Then _7zgminiexe2(True, $sTempPath)
EndFunc
Func _WinAPI_Base64Decode($sB64String)
Local $aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
If @error Or Not $aCrypt[0] Then Return SetError(1, 0, "")
Local $bBuffer = DllStructCreate("byte[" & $aCrypt[5] & "]")
$aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $bBuffer, "dword*", $aCrypt[5], "ptr", 0, "ptr", 0)
If @error Or Not $aCrypt[0] Then Return SetError(2, 0, "")
Return DllStructGetData($bBuffer, 1)
EndFunc
Func ASM_DecompressLZMAT($Data)
Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768
If @AutoItX64 Then
Local $Code = "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"
$Code &= "5/o1kEQsAf7ChQJKEWf+KPU06QsjULCtlHGUMyrwiJMbCggKTje0+TgXdGmQGXisYu9BxgKaIwr4HApKAQw/fMgSArJnA8oeSdHJqVNxagiueGUCImaKKhdshPB5iEkCHQnGQAMYF+nk0TdpgoAK8OuH/JE5agKytTp0np6Md2oBNUARWlgo5ukqCBEPM8DqFFEU4sX7H0lHQRVGyjMdg+gB5l6gi9M1J/HokAOWAfx2ZkGJJMMQiQIWuiDb/YIUHMFqySVhq4Q/EoD5Ib0MLCkZJjioUnA8/SgzlwEgZ+l9+kmBIKC0SwEvhHYkd/kuc1LVL4gDxlvdTLhpnpUVrlgn0tgHBqF6VvdwlLTPoJJ25AaLKogBuFfhaNsouwhkkD30gC3PKfdMOUUXg6RCPEWE5GmqAgGJ34M5dDgBRS4MLEkU5osYwO0ICfUwg8MkMfbrGC6J3jNUMPudSzS61JpAOsDuDkQJ1uWIN6HSnU1B2MYJ/ggfdJxF1O1noN92jOjoIHOIFu14FBrh3UCvPDk0dbGeRUnrwDOA0IQkEmvC5TiHZDxswO9VBGiYGv/Q1z2Uv0e3v8aGuFuA7/qDMecDPuoC3f/PO4A1wZASAyFgkAEpOdKgg1TWthyYWinmP54MgPQ1rpzBR+OdCEYCHEO1BcMDOcaC9fR5oBo8GGDxgnnegRnF2iZt6RmJwkbrjn4p8qoMCSAYRQ6cvNeaxiJiGCSvOZAFRYXbkA70MXZ1sTmh0KG2oM9Bt5W+SEs/+hTR6rtEiKKLuvOtooQEl+AwB6Sx8Mb1KK6aJBq4YaVSQDXA6wSRHIq227VjhUtlKx3UBa18GgWXOfkOr+nyMcp0ZSdGEbZc1CMS4wQlSgtC30Omp/KB+1oPKnRQ9EQShmkMl24oN7gEjZ+pwxjrLDDTqDNh1hKn5n9lRwVE6bcp2xQSMVB1sGCmVDoaAtoCuIKBAW5VeSOErdLKzbsNjZ8RTZmcApMQdecB3HP+FAg/JJ+NmvzUTHOjIt7TkJgYBb9/EUQhUO/8PnQEJDQ/sBD4jRJdaLEkJ5wDdiOD7unrB7ILGRdBcdoxdoGIBEeLFBAsbWhG0TzMfyziHYvp8ajvXg6NsmoEqsjRi+nXKl+X0QMJB/nqHkS5Qo10HoCvOfFyf6I9r6rpHxgxHDB1vqaa+0OlDh2qtDIng0TpiGhjPsVSGmVkO6kF9olT69UaI5FKwyILSDvNuBQ4vvLDsAuJAjMxwB+4vj8769/2oQfYYkoFt3Qw+wqswICLAfaIoUIRAx3rvNQQBxe1VwyMzwbQlQD+/POqX2DDAA=="
Else
Local $Code = "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"
$Code &= "/id8kUgoGcQx6d+KOQN0d42I71gbLXDqiaQjkCShGg8y0SwBdmp/IAxNAuyIAxEMjZ1rWqFq5KNJslERd1oWbQJAg8rwiFZAKkYDpA6gQ+m+0DV3jICU8LqooVCJssR4BJCC6UOvryGF5gG/funUP/0JA3VnuSrYwlk7kUyTCc7NZTuRQY/pjfmmZn0gdJowKggWDjLA6hRWhKlwjUclqiIz1Yh3mr816TY1iU36JAPdLd+EZAqzN5cUEPdH9UCZavcmEkP+bTBBCK9U0y2OyBEwBArp7/grkhiJkXCOQLEbRwGbJIJYoJJfEukL+jQ/zCX1IYgGYvT4RXnKmbLed054IOL8uUuTuCXnyU5ilktxoulxgIVVMe1XVr6hUVNskdyszpdIJyPGOOVSiG1pIYbi6yAG0ynROc7MVRS9jx6E21zTO1DWMd0xPhQyLB9UTYjeJPIdMURi0Bf3o+sqwFwnRTMl598XV8HjArXaiBHrRp5N62KZAwh0kNBkGWyJ6UbRRnnpe/EnhnmJS+Acg3HxM7I4FBd4GTXJgIvBhNIpdaZaY+uwS3YcS9KPjYaQLwySxhsUU9mpCbcMMSMxCctzEks9Mly+xH37cTEg2OuYNHP595luKIJo7gwaA8gSnmQBCnPv44nZLFY/nKHzHIjkTgfqgPLOrNVAr5mElhwKIeOpH/vyILUvgcMDOcFwo/TEF40UD9dmgsiNtD4LhgrIgcKDCusBKcrLagESEE+YKO3Rx/uywkNwazfLYRk7QfEQdmjNFjGJEEOga1EAFtt14YvSEyAa6cH+wpPL0euIlaSbvNO61pOm+vWAldmB4f9BB9nBbGdwr6+KhVGBoa+qHkTr26S1KYVLlz/gHY1UMwFKORTcDsSCL1p0gGx0dotUhCQcMsZtpKV3JnvTZSWB+6KvdGeE9BJGhgyVvLgJuASef6p+mI/pgqq1sZ8cCIjBFhTp0v2U99kWQMt/kWCyOIiDoOmbQll20GeGdZlTVCilAoSAobMBjPXP/Ir6OrfRwiViCcEiIZJYdA7SZioLVNR4txuNmhFZIKYCWxBUzhNp1TE/TQsKTDP8dR3hopA4XAUzgRSD4n+O9BEEhxwSf4nQEdU8qF+VJHQw2Ql2LBl9621xUcdEaoNTDVAbxgSj0Z49Fw6LKlL8xkZcC4kpdeUBgOme/FneaKTJKBJUgrBBBAqshOmg/ZknRdMQzx/UFFTVA4MkoEEdRn5FgYwyJwY4j0TpxJeA8aADdEgrY6fF2h6zJKgaDmVUcEoTTBGNFowTQYEw6Tmmi8XkMWVaJl8MLH8xxG/ry4yDt4CBw5E2CenFJCy4jUBF5CjfRDSJAx32vBi4Ajvr4e/ahQfamHtUBzH7geLAiyANDBLpsaFCAxHrvN0QQQe1V71NEoXJF0hFiQxpxhcDsuYJCPfHA5BaCqpSSQoAdfaJysHpAh7886sW0V23xqpfwwA="
EndIf
Local $Opcode = String(_LZMAT_CodeDecompress($Code))
Local $_LZMAT_Decompress =(StringInStr($Opcode, "89DB") + 1) / 2
$Opcode = Binary($Opcode)
Local $_LZMAT_CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)
$_LZMAT_CodeBufferMemory = $_LZMAT_CodeBufferMemory[0]
Local $_LZMAT_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_LZMAT_CodeBufferMemory)
DllStructSetData($_LZMAT_CodeBuffer, 1, $Opcode)
Local $OutputLen = Int(BinaryMid($Data, 1, 4))
$Data = BinaryMid($Data, 5)
Local $InputLen = BinaryLen($Data)
Local $Input = DllStructCreate("byte[" & $InputLen & "]")
DllStructSetData($Input, 1, $Data)
Local $Output = DllStructCreate("byte[" & $OutputLen & "]")
Local $Ret = DllCallAddress("uint", DllStructGetPtr($_LZMAT_CodeBuffer) + $_LZMAT_Decompress, "struct*", $Input, "uint", $InputLen, "struct*", $Output, "uint*", $OutputLen)
DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $_LZMAT_CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)
Return BinaryMid(DllStructGetData($Output, 1), 1, $Ret[4])
EndFunc
Func _LZMAT_CodeDecompress($Code)
Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768
If @AutoItX64 Then
Local $Opcode = "0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"
Else
Local $Opcode = "0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"
EndIf
Local $AP_Decompress =(StringInStr($Opcode, "89C0") - 3) / 2
Local $B64D_Init =(StringInStr($Opcode, "89D2") - 3) / 2
Local $B64D_DecodeData =(StringInStr($Opcode, "89F6") - 3) / 2
$Opcode = Binary($Opcode)
Local $CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)
$CodeBufferMemory = $CodeBufferMemory[0]
Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
DllStructSetData($CodeBuffer, 1, $Opcode)
Local $B64D_State = DllStructCreate("byte[16]")
Local $Length = StringLen($Code)
Local $Output = DllStructCreate("byte[" & $Length & "]")
DllCallAddress("none", DllStructGetPtr($CodeBuffer) + $B64D_Init, "struct*", $B64D_State, "int", 0, "int", 0, "int", 0)
DllCallAddress("int", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, "str", $Code, "uint", $Length, "struct*", $Output, "struct*", $B64D_State)
Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
Local $Result = DllStructCreate("byte[" &($ResultLen + 16) & "]"), $Ret
If @AutoItX64 Then
$Ret = DllCallAddress("uint", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "struct*", $Result, "int", 0, "int", 0)
Else
$Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "ptr", DllStructGetPtr($Result), "int", 0, "int", 0)
EndIf
DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)
Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc
Global $sUpdateAppVersion = FileGetVersion(@ScriptFullPath)
Global Const $sUpdateURL = "http://www.mcmilk.de/projects/USB-Backup/"
Global $iHasNewUpdate = 0
Global $aInetVersion = 0
Global $aFilePaths[1] = [0]
Global $aFilePathsTS[1] = [0]
Global $aUSBSticks[1] = [0]
Global Enum $eDeviceName = 0, $eDeviceID, $eFullDrive, $eDriveLetter, $ePassword, $eBackupPath
Global $aCurrentSticks[1][6] = [[0, 0, 0, 0, 0, 0]]
Global $iTrayTipTime = 15
Global $aCurrentSticksOkay[1] = [0]
Global $sAppPath = @AppDataDir & "\" & "USB-Backup" & "\"
Global $sAppHelp = @AppDataDir & "\" & "USB-Backup" & "\" & "USB-Backup" & ".chm"
Global $sTempPath = @TempDir & "\" & "USB-Backup" & "-" & _WinAPI_CreateGUID() & "\"
Global $sSaltValue = "0"
Global $sHelpTopic = "usage.html"
Global $hHelpHandle
Global $s7ZipCreateCmd = '7zg-mini a "%A" %o -m0=ZStd -mx2 -ms=off -mhe -slp -ssc -ssw -scsWIN -p"%P" "%p"'
Global $s7ZipUpdateCmd = '7zg-mini u "%A" %o -m0=ZStd -mx2 -ms=off -mhe -slp -ssc -ssw -scsWIN -p"%P" -u- -up0q3r2x2y2z0w2!"%U" "%p"'
Global $sDebug7ZipCmd = "0"
Global $s7ZipPriority = "idle"
Global $sMaxFullBackups = "0"
Global $sFullBackupIn = "365"
Global $sShowUpdateHint = "7"
Global $sShowEditConfig = "1"
Global $sShowEditIndex = "0"
Global $sShowWriteIndex = "0"
Global $sShowStatusMessage = "1"
Global $sEnableVSS = "1"
Global $sDebugVSCSCCmd = "0"
Global $sUsePowerPlan = "1"
Global $sDebugPowerPlan = "0"
Global $sCheckForUpdate = "1"
Global $sNewVersionHint = "300"
Global $sFileNameLen = "16"
Global $sEditor = "notepad.exe"
Global $sRunBeforeCmd = ""
Global $sRunAfterCmd = ""
Global $sChmVersion = "0"
Global $sIniVersion = "6"
Global $aTrayItems[1] = [0]
Global $aBackupTray[1] = [0]
Global $aIndexEditTray[1] = [0]
Global $aIndexSaveTray[1] = [0]
Global $iRegisterStick, $iRegisterPath, $iEditSettings, $iStatus, $iUpdate, $iAbout, $iExit
Global $iRunningBackup = 0
Global $iPowerPlanPid = 0
Global $hGUI = 0
Global $gGuiStyle = BitOR($WS_CAPTION, 0x80000000)
Global $gGuiExStyle = -1
If Not FileExists($sAppPath & "Logfiles") Then DirCreate($sAppPath & "Logfiles")
Func _deDEini($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $deDEini
$deDEini &= 'wRQAAA0ACltIZWFkbGkAbmVzXQ0KMT0AJTEgLSBTY2gAd2Vyd2llZ2UAbmVyIEZlaGwEZXINCjI6RJcGMLY2ByJXdpYGMEcnl1YmV+YG0aAwYzNWZXJ6AGVpY2huaXNzAWUgZmVzdGyIgdGgQGNHNlAmVwfkZgIgYXVmIEzACEANayAlMg0KQDVGDHKXJkcGAlAmN0dX'
$deDEini &= 'xsZGR+Di4tKg8AVAFSYwt0YlF5bXBTJFQBdGVzdXA1EFl0AWRlcWAcEtlgURQNMjVFbmRmYfTDVMBEKWCaBrDQogNj0YBhImJibHVoYBXHDDkkcAJTEBDQo4PUVpbg8ggncgDQo5PUTc4MZAJ0d+hgoXsTEwQD0P8QcxMT1Lb24AZmlndXJhdGkAb24gYmVhcmIxZWmW'
$deDEini &= 'gAMyPUllAB14IHYwcBFgozM2GzA3hiZXliZGIwI0PVdhcm4zACwAIGRpZSBsZXQSenRlj5Fhcmwgh8kWVGENAJExTWVzfHMa8C5TLuAKGkAXRiBHV0bH4hthdQJlIG1hbCDzACCE4xEgOy0p1RFEYQBzIFByb2dyYT1tbUcy9pAF0B1BZwsGMz1CaXQBAAmBIBhm/HI3'
$deDEini &= 'ILWRc3fkwLEDGxA0PVNvbGyGPyJrb21wgQB8IAQQNrZWBwcCZTYSRlYAsMbm8ic7OKBQ50YG8i4zVwfAxmR/BkAH0jmwLgDy4/wuoippZQcC8Gc5YXtspwR6r7AzoGdzUOT0Appdk3d1KnA58kYCbmchcROdpGtsGpA95xdSOc4o9yMwtwaVZ3xlliSOvwMdQLBCV/Yh'
$deDEini &= 'xxZGEx0RSxS1ABMk4FZSKxAAViZn9sbmd9Y2QAtdQkUA6wNERzdQlsZ2V5YWFmCPuEgxY14JEpEDbOR1dmbZEvkDuzU6KpFDIgP/AtYVMAPBFDU9TmXcnwNvU3atBv0UDmDGj3AmFiZnFDY9QQFrdHVhbGlzfwCC1ICUxmZWhh5pnE5708PY9RBaOJc26gFuqQB0IGGi'
$deDEini &= '0GbQyxY4hZBa2BLIFDlMuRHkdvcUkBfscpDQVFH4TgLiVlYXFCCTIoY+cUAX9QR0B0Bt9mfAnRLtNUJ1dHRvbpLrNU9LcNATdH83EzwQ+ZaDlOamV3cPADiJU+RGZ1Ym58aIETY9TBcUZThBdVxzFsCmAHaQAIDScoV3ZYDj8gJyMJA+UC7GXm7zhnOXMXcGMTfSlMbh'
$deDEini &= 'ltYWAbQ0AQlpZUDfG0g3LVppcCA4YW7PADcgEQNGb3IxdHP5BxxS0wNVbPCpVzY9syTNiYsChHMo8UBXNraGEj8BmzM5SMxLIddnenX/hjcqVVMxQiARisMBMj1SGWrT3wA4qNMboVWXMyAY6PkEW7w8QLMfkWZXVvypSOg1PUy9KXM/WIC5GWFtICVkLiUCbS4lWSB1'
$deDEini &= 'FoAEoVPSlAlSJCf3VicXnZrZ01+Qxh9iUQSglxBtVwNXTUkgUwNlcnZpY2WfE80ptz99Ma8jjRllWQ4NgcUz/G8C3wP5KW5Rn0kHa2E/bm5QVGIQfdB5BQ0zLhttdd+u4aZzIOADHTU9S3qRv3MRkSYa7phDKUZgY/QJdwEDFPywxQFsVpFnEDY3d+dZNQDyNlxhdRDg'
$deDEini &= 'EtNjttg3ghZmphYQOF3wCl4Pw9oPkmOMQGRmCVEHNVfH7z0gkSDpHb4CEQEkYSBlbto5Bs0KQkUpYbhnIEBm7rwQSJCnIAciyEDaESGmG/kRg/0UtUbMIyMBESAKQmVudYkLcs0mQTtkbY0MqQgyDzKXBBGLAC7FMMoLD0AcVm9sdW0wZW56DVEs4Lb2BieICChWU1Mp'
$deDEini &= 'EgMgRlBGluZ2VnPhZn9ClwYCLSC9PAUBEgbjXw+WNdI6JzwQ6XReBpOa1/YDUlRLJdEw9aChEaGZ0QC/NSVhwQQaCdEMVuoRVdISMBi3wBQmVsZWtdONsK5nMLncOf4NRNYL4aaUMRYVumt7ITR8K5cQ9RFMJgPSAXBtQjCoUlP2z2ATiNS4ET3W3i2taWHAcFOULwDc'
$deDEini &= 'YsDwRt5ZQCw4xC/RD2DVALyClyOJkSU61c5uBRjTE8QODnEBQgvQBhsuHpDVclDS1lJCJhyAfQd6FEiOGXEfyhjBxlYa4EZ2lGaIAWNhLrYdImgAbOHvxxDGDQWHRQ+eAaFpIO0nIH9LYhYUSWPEME1Ibg2i9yCQzwCXEwVD+QwiDRAkN4b2k2ZXf9EtwCI5E/Ubxghj'
$deDEini &= 'YW9mZsAgMu4MgCdnF3L235kWMhoi0uoGBAI0PSJMb2dqAVNSEOPC9nZGTyJwcFaj7ED5FDI2BSKmF1YU6XfTHUL2AkoRFQDhDWGt8QMz034Q1Ro1Y2aRdm8RBkHWRywdb2UgWnYHYFgR3NAn49kANgMUQg9goDGqB2WmIwCtISczTh61Zo+wGibyHf3hwybWxuD1cSgg'
$deDEini &= 'SUCtDjNjNO4hVAez9iZnNwDBF5zpLDM1QWH1YxnxBjY9QEjRDyBQbGF0evvNAIoYkLQT/xADdFNB5dQQ3kXzFekMZeE7SQKZEHYmkwYzl1dakLtBA9NzdFA2F9ZGxxLqBlDCsqHDYuTMAEQhQ2QJB7tYN1OuYz0g2RNyqhdhExC6CilHY78BSitcFEGjHgJwjkERZXJw'
$deDEini &= 'qRJgAmpz8H0S6iiFK+IbUDd3VhbvQxJlAsYjoSMhNz1WKgnArlEQzbVsgcOWGXo0OfelAs0A9h1AzDUNE2TEe1817gXwJpkC9hAhd1DYJUYw49YKkC6QazAHF1YjUSlw4wbnJwDiBDWjHRDaBRF7MZlVWUNDFmJslioCpnM1YKG2QkkVNTZpEToVYJsWcJS3wjk3GTb5'
$deDEini &= 'MTjmCRZiMmCqAGlnGQrgkvNsvlKMYgNjEDOeCZAN7SQAPzYxPeYeC+uHELIFSAx+ALAv6HACLaBjEMwaDTEjNHF84Wm7YCUxdCHwEaYhhQM1/yIGYBRCNjNmvDEeDIITrg1gGmLdAgzBJEE2Jue9EGoOBCQJMN+eJ9CRMKZKATYL5jUwKgyXCqBjFGaGAkIa0grjVNfk'
$deDEini &= 'plB3BmJWC1AWLzYnJ2bpAFogEEAAsqP8IkYAaWxlUGF0aFt4XVFOShCQ9FL30UMStmBUx8bG9gI0bBCLw0r3AjVSAeTm9QGmE3GjN3LWkkvhUoZXU2CgA88CN+KXMW9u4Rk+FBJd6oNhyzo5bC4DcHDwciMyoU4i8GPGr04D6imQa5A/EjiimkG70gVjJFgBbgFRBmOW'
$deDEini &= 'jKCZQfAaA2PiIZ4aafoReGNsdQlkZUNv7gPgRhdIAjMCYl/SfRclMVxuNyNc8gcBCC0KBgEc5hMRJ+YvAQkW9gdyMnKSRhGIGEluZm9ybYYY4gsHejIDYGOB2jCjNDEWF8L/GeMAYqTiAkoVVVGRASGVIc/5DdYllBbWPkEbRhFSU7FPGXUAgGNyABEMbQo4UBNgqBcT'
$deDEini &= 'SnVuY5YaUj5yNdgK8HY3B3ITFAANLGdlZQksnh2XzcBWlt8v4XMDfRIlKSIVMrIVAvZfOQA='
$deDEini = _WinAPI_Base64Decode($deDEini)
Local $bString = ASM_DecompressLZMAT($deDEini)
If $bSaveBinary Then
Local $hFile = FileOpen($sSavePath & "\de-DE.ini", 18)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func _enGBini($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $enGBini
$enGBini &= 'oBEAAA0ACltIZWFkbGkAbmVzXQ0KMT0AJTEgLSBGYXQAYWwgRXJyb3IQDQoyJiNVdpYGMEdXJgcyRZcmMLY216Aw4zJDAGhvb3NlIGJhAGNrdXAgUGF0VGg2QGMzQigyBwLw5gZCJJdmVyYAUiLToFDjRnICZWF0aW5ncuSC4OLSoLABQBU2R7BGJReWlwEyRQcRRlfH'
$enGBini &= 'CTI9VXAIZGF0ZegRJPYmUkcnHFF1aQ5Qg4hEIG9m3NSgYBPQMxTmNlbGBmIwNz0SEwFREtOgAIDT8wRHl/bm5kkLOT2xYEY0BaIPMHE9tUAuVAuBMpciAwExPUVkaXQghgYSIwMySW5kZXjAERDGETPTcyWXBkJXpsI0PVdhckBu7wAsIGxhc3SQb1FpczwAQhaWhxgJ'
$enGBini &= 'wEYWUhHSVDYnMRd29iIUxPYVQAaQBzJHFyZHVwZAxwJCF7ZWBgIQBsL29rYGAkQEUhYBstOyAyDTAwAl93YmF9bWBgByl8bGBiJWBgEyxtYIQAbi9gZ0dxww0wPFVhYG2gowtgsTBkKWJgdQNkb3JpcHYgbzJtchNRxBhVYGMmNWZxgmAgI3EIAKoQgQhgJpdCdzMgQw'
$enGBini &= 'BzKH9lbHRgaIHWRlbGV0ZWRxPzUSgGFHYW5kardWtymi9gB0amCjJkITzPoDmWJ3YXMgY9EiW2VjETiTAsKQZ0LwVA4GxRIwSYe2HUD3PABsA8sCRG93bmxvZ2E9AEUAaW7BAU0A/hMKFDHcNfbWBncAYgAyVzc2diNQE5G3Dg/9AkQEdyOQRo0vIPERA3s0BzPVEnJ1'
$enGBini &= 'bgUT7MkBHwN/NDo0ARQyIEhkIUBlZEBR0+OEUHYHAncqA2JXBiI3lz4AEmYXllbAFibGVkYUNsAEQAaCVsYGB2J2k8bWKgCUNydTfncNAImFcmU7A3QgY3UFcnJlbnRkgZMG6A5184BIkYOEQ1BOzeIBIleWRnJtUUAwEiDDB+NWFwHmdBYwAAH3hjE3l7YGM1AgVEd3'
$enGBini &= 'RjdcEFDytAQHsUaLFBRSZWawgPZEEUQmRLY9IVXW9jZnYQPTQ5Q1UjVRhDfGRlBHVgbCVGwAgqLSghdUgIPiciqQo/kgIUdXdhYz8JQVYAeRVnaXMNKU5pa20ZamhwrdAkOhFbMiAFNob3cgNy1aQWlkQdMz9Ob2DBBUZxM1PVBhdUpy3oF2i7EhgpSmD2rUDKA/MNNt'
$enGBini &= 'lA3SJRViMRaVO8dbEyCThnYuwDJtOHM6qTURRKFGacUFdG9AtC0DPyBuNKAGcoAnZxw1PUwliL0VXxlkLgAlbS4lWSBhdAMgJUg6JU1lIDcru0GoRt8DmOANY8hDEQRXTUkgU4sRY2W/7xI9C0sJJd0Spzjtp31wf3lQEVkgJQUHWKEItyt6aDkAtRB/qDhQcx1x4g87'
$enGBini &= '80khFLsVOjAhogNkA2VjcnlwdNsGQAwYVRA2N3f3JkcGBnIC4Hcgc2VlbQFzIGZhdWx0zKGHA0k3IsVajpiTnDUXUBYmN4YGknfG8CfXc2B7nzgXCMUJbjE+AiTECWsgZnJvbZQJUmR1RvCWW1Bm95L2tsxwl7eTMDGD4fUPYWVPEloi0xME8kGAJBeoRNYWSjBHJwcU'
$enGBini &= 'FhcAIpd2hkYHNJciESY298ZWp0JX1mFRVmgR1iDQMgIiBi1vZmafSI4R7gahYIEXaW5jb5UGXGN9JzQfk0kx1RBzaGphuwhDA3DrMmQfUy1tIG4EEDxB1wuQbPBGC2ByvSEuC8MUJlbGBmyyQGYCBdJWRpYW1l8+kLMKVYUfYg4kbCBz2hHhawkhNKVPXJMQ00BSGMHW'
$enGBini &= 'jQyUUpPBmpiXBmBTZ3YAVzaWZhYcUDJXJRncgyLLQG9uZmlyiTC9rF+Aw1o2AxAdQvoHOYl7j903T3BlhhSQvVh3YkghmEUDb26UoWEBWS0lH20tJbUFJW4tBo4VhBivZRx4ngrGEnOQneBcITYCAI0WVgtDRqY2PU5vW26aAnETDNSjIGcBABlQ7dlDSggCSG5CCoD3'
$enGBini &= 'ADkhANxYD+B6AEEFDOkCoRYxPXFvqRJNHOFHdmlhJgT1JpOoAEZzpgXAG44ZIkwRBHVuZ2VuQEDTQyQSO8L2dtblUhJj5YICImRQ45RAJRMy56EPqXHuGCVzUxhBY4YLtcsbOQk11hGUFTtjq2BVQXUzShBWjZJVzlINUGbvAA0gdGltQgCCDDIyFXPwxsb2dudyEFoV'
$enGBini &= '6UJABmZvdW5keRCGFkY29gYmqgAU5panW2H1BXxzDgnh3QCdKLoIk8owQ+PVIyMwd3YUEuQjEgFFGzP4QhYTEZcrRBoBoTY9SGphEQUuFFDmmgFkaQ5hEmNlaF4aUCYXAnOzXTQVMFvHAgHzBjhuCZDwkJgHkdNjlF4wl9fmMNRmpRAwPVRv0hWAEkAxagFBpsNiJFfW'
$enGBini &= 'W0pBI/4BPKJAAVA3E2czWyARFmjSikVDU7Ml+lFfNHogABcfwBO1RH4AAjceNj1TaQQ6DKK2EeUXNP/KEKEAAL4NSBXOEEFF7hpEFYPOEDCGVkZW5zkQsFdTA4OFtFdj9RBlhhgAn29ivHCuAaIUAWhhbmeCaAH1dlcmV0zgFkg2Mz1FbGFw+h7xGkNXYzAgYQIHwAtY'
$enGBini &= 'qBwBOXJv0gaRPIADNj3pAnZrvhrRnYE4N+00eIHDnjaQWYASOVIiBRY2MLaCJiOXCF37YGMVQFQxpetyMEMuB9GRoCdwNh0OY39jMQhJGL4owHl1EHUKVgMZqZIgJTFkQdODJJoBwFkeMFDTEwQHx/aSNtYK8BbuYIZCphSjgSD/OOGZgRYIgSTmHdNOoIAQmhLyr0cC'
$enGBini &= 'KS42H2DbAXzg3iGOByMMMPo8VQmgviLYkgnjFLZQVuD2VneGFqtQ1tTgnikS1OBoEDu+JVJEIYcSW0xdGSxpbj4QU9PRQ3ITZlTqQPYANGTQwMP2AL4ZBmzeEBDw4L8A5QkuDnAToXfWIuwQLmV4IhWBYdOz5FgB/QxkaWVQILEIYTUBbmtvcMA0kF7gljaGRgdiEFZn'
$enGBini &= 'BsIEATUIa45WIdEWBqcoAI4TUjVDdlaXklIEMFYXSRFhoSxAu3oTZSZIAUxjDQFuFQZqE4IvCDDWAaBDYUIY4dQxQ29tZ23+CpA+MgICRU4NEWsyUBLD5TbC5WEQcKDXInsQsGGRAqYO4CYmMSczIyfdE3jR9mYVIeDg11ZxIlgAPhyq7yBtILYFYbRe5MEt2it1Vlrg'
$enGBini &= 'JiARBTL6kNGwAiklEBEJaxYAIndoLhAgc29tKgSiFgGuFyBcM5UVo1TnNmb7Iiz0ohIFBPkxHVFucgFh0/MzssVqFQM='
$enGBini = _WinAPI_Base64Decode($enGBini)
Local $bString = ASM_DecompressLZMAT($enGBini)
If $bSaveBinary Then
Local $hFile = FileOpen($sSavePath & "\en-GB.ini", 18)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Global $mHeadlines, $mTaskTray, $mMessages, $mStatusMessage, $mErrorMessages, $mFatalErrors, $mLabels, $mButtons, $mExcludeComment, $mTaskStatus
Local $iLanguageCount = 226
Local $aAllLanguages[$iLanguageCount][4] = [ ["0004", "zh-CHS", "Chinese - Simplified"], ["0401", "ar-SA", "Arabic - Saudi Arabia"], ["0402", "bg-BG", "Bulgarian - Bulgaria"], ["0403", "ca-ES", "Catalan - Spain"], ["0404", "zh-TW", "Chinese (Traditional) - Taiwan"], ["0405", "cs-CZ", "Czech - Czech Republic"], ["0406", "da-DK", "Danish - Denmark"], ["0407", "de-DE", "Deutsch - Deutsch", _deDEini], ["0408", "el-GR", "Greek - Greece"], ["0409", "en-US", "English - United States", _enGBini], ["040A", "es-ES", "tradnl Spanish - Spain"], ["040B", "fi-FI", "Finnish - Finland"], ["040C", "fr-FR", "French - France"], ["040D", "he-IL", "Hebrew - Israel"], ["040E", "hu-HU", "Hungarian - Hungary"], ["040F", "is-IS", "Icelandic - Iceland"], ["0410", "it-IT", "Italian - Italy"], ["0411", "ja-JP", "Japanese - Japan"], ["0412", "ko-KR", "Korean - Korea"], ["0413", "nl-NL", "Dutch - Netherlands"], ["0414", "nb-NO", "Norwegian (Bokm�l) - Norway"], ["0415", "pl-PL", "Polish - Poland"], ["0416", "pt-BR", "Portuguese - Brazil"], ["0417", "rm-CH", "Romansh - Switzerland"], ["0418", "ro-RO", "Romanian - Romania"], ["0419", "ru-RU", "Russian - Russia"], ["041A", "hr-HR", "Croatian - Croatia"], ["041B", "sk-SK", "Slovak - Slovakia"], ["041C", "sq-AL", "Albanian - Albania"], ["041D", "sv-SE", "Swedish - Sweden"], ["041E", "th-TH", "Thai - Thailand"], ["041F", "tr-TR", "Turkish - Turkey"], ["0420", "ur-PK", "Urdu - Pakistan"], ["0421", "id-ID", "Indonesian - Indonesia"], ["0422", "uk-UA", "Ukrainian - Ukraine"], ["0423", "be-BY", "Belarusian - Belarus"], ["0424", "sl-SI", "Slovenian - Slovenia"], ["0425", "et-EE", "Estonian - Estonia"], ["0426", "lv-LV", "Latvian - Latvia"], ["0427", "lt-LT", "Lithuanian - Lithuanian"], ["0428", "tg-Cyrl-TJ", "Tajik (Cyrillic) - Tajikistan"], ["0429", "fa-IR", "Persian - Iran"], ["042A", "vi-VN", "Vietnamese - Vietnam"], ["042B", "hy-AM", "Armenian - Armenia"], ["042C", "az-Latn-A", "Azeri (Latin) - Azerbaijan"], ["042D", "eu-ES", "Basque - Basque"], ["042E", "hsb-DE", "Upper Sorbian - Germany"], ["042F", "mk-MK", "Macedonian - Macedonia"], ["0432", "tn-ZA", "Setswana / Tswana - South Africa"], ["0434", "xh-ZA", "isiXhosa - South Africa"], ["0435", "zu-ZA", "isiZulu - South Africa"], ["0436", "af-ZA", "Afrikaans - South Africa"], ["0437", "ka-GE", "Georgian - Georgia"], ["0438", "fo-FO", "Faroese - Faroe Islands"], ["0439", "hi-IN", "Hindi - India"], ["043A", "mt-MT", "Maltese - Malta"], ["043B", "se-NO", "Sami (Northern) - Norway"], ["043e", "ms-MY", "Malay - Malaysia"], ["043F", "kk-KZ", "Kazakh - Kazakhstan"], ["0440", "ky-KG", "Kyrgyz - Kyrgyzstan"], ["0441", "sw-KE", "Swahili - Kenya"], ["0442", "tk-TM", "Turkmen - Turkmenistan"], ["0443", "uz-Latn-UZ", "Uzbek (Latin) - Uzbekistan"], ["0444", "tt-RU", "Tatar - Russia"], ["0445", "bn-IN", "Bangla - Bangladesh"], ["0446", "pa-IN", "Punjabi - India"], ["0447", "gu-IN", "Gujarati - India"], ["0448", "or-IN", "Oriya - India"], ["0449", "ta-IN", "Tamil - India"], ["044A", "te-IN", "Telugu - India"], ["044B", "kn-IN", "Kannada - India"], ["044C", "ml-IN", "Malayalam - India"], ["044D", "as-IN", "Assamese - India"], ["044E", "mr-IN", "Marathi - India"], ["044F", "sa-IN", "Sanskrit - India"], ["0450", "mn-MN", "Mongolian (Cyrillic) - Mongolia"], ["0451", "bo-CN", "Tibetan - China"], ["0452", "cy-GB", "Welsh - United Kingdom"], ["0453", "km-KH", "Khmer - Cambodia"], ["0454", "lo-LA", "Lao - Lao PDR"], ["0456", "gl-ES", "Galician - Spain"], ["0457", "kok-IN", "Konkani - India"], ["045A", "syr-SY", "Syriac - Syria"], ["045B", "si-LK", "Sinhala - Sri Lanka"], ["045C", "chr-Cher-US", "Cherokee - Cherokee"], ["045D", "iu-Cans-CA", "Inuktitut (Canadian_Syllabics) - Canada"], ["045E", "am-ET", "Amharic - Ethiopia"], ["0461", "ne-NP", "Nepali - Nepal"], ["0462", "fy-NL", "Frisian - Netherlands"], ["0463", "ps-AF", "Pashto - Afghanistan"], ["0464", "fil-PH", "Filipino - Philippines"], ["0465", "dv-MV", "Divehi - Maldives"], ["0468", "ha-Latn-NG", "Hausa - Nigeria"], _
["046A", "yo-NG", "Yoruba - Nigeria"], ["046B", "quz-BO", "Quechua - Bolivia"], ["046C", "nso-ZA", "Sesotho sa Leboa - South Africa"], ["046D", "ba-RU", "Bashkir - Russia"], ["046E", "lb-LU", "Luxembourgish - Luxembourg"], ["046F", "kl-GL", "Greenlandic - Greenland"], ["0470", "ig-NG", "Igbo - Nigeria"], ["0473", "ti-ET", "Tigrinya - Ethiopia"], ["0475", "haw-US", "Hawiian - United States"], ["0478", "ii-CN", "Yi - China"], ["047A", "arn-CL", "Mapudungun - Chile"], ["047C", "moh-CA", "Mohawk - Canada"], ["047E", "br-FR", "Breton - France"], ["0480", "ug-CN", "Uyghur - China"], ["0481", "mi-NZ", "Maori - New Zealand"], ["0482", "oc-FR", "Occitan - France"], ["0483", "co-FR", "Corsican - France"], ["0484", "gsw-FR", "Alsatian - France"], ["0485", "sah-RU", "Sakha - Russia"], ["0486", "qut-GT", "K'iche - Guatemala"], ["0487", "rw-RW", "Kinyarwanda - Rwanda"], ["0488", "wo-SN", "Wolof - Senegal"], ["048C", "prs-AF", "Dari - Afghanistan"], ["0491", "gd-GB", "Scottish Gaelic - United Kingdom"], ["0492", "ku-Arab-IQ", "Central Kurdish - Iraq"], ["0801", "ar-IQ", "Arabic - Iraq"], ["0803", "ca-ES-valencia", "Valencian - Valencia"], ["0804", "zh-CN", "Chinese (Simplified) - China"], ["0807", "de-CH", "German - Switzerland"], ["0809", "en-GB", "English - United Kingdom", _enGBini], ["080A", "es-MX", "Spanish - Mexico"], ["080C", "fr-BE", "French - Belgium"], ["0810", "it-CH", "Italian - Switzerland"], ["0813", "nl-BE", "Dutch - Belgium"], ["0814", "nn-NO", "Norwegian (Nynorsk) - Norway"], ["0816", "pt-PT", "Portuguese - Portugal"], ["081A", "sr-Latn-CS", "Serbian (Latin) - Serbia and Montenegro"], ["081D", "sv-FI", "Swedish - Finland"], ["0820", "ur-IN", "Urdu - (reserved)"], ["082C", "az-Cyrl-AZ", "Azeri (Cyrillic) - Azerbaijan"], ["082E", "dsb-DE", "Lower Sorbian - Germany"], ["0832", "tn-BW", "Setswana / Tswana - Botswana"], ["083B", "se-SE", "Sami (Northern) - Sweden"], ["083C", "ga-IE", "Irish - Ireland"], ["083E", "ms-BN", "Malay - Brunei Darassalam"], ["0843", "uz-Cyrl-UZ", "Uzbek (Cyrillic) - Uzbekistan"], ["0845", "bn-BD", "Bangla - Bangladesh"], ["0846", "pa-Arab-PK", "Punjabi - Pakistan"], ["0849", "ta-LK", "Tamil - Sri Lanka"], ["0850", "mn-Mong-CN", "Mongolian (Mong) - Mongolia"], ["0859", "sd-Arab-PK", "Sindhi - Pakistan"], ["085D", "iu-Latn-CA", "Inuktitut (Latin) - Canada"], ["085F", "tzm-Latn-DZ", "Tamazight (Latin) - Algeria"], ["0867", "ff-Latn-SN", "Pular - Senegal"], ["086B", "quz-EC", "Quechua - Ecuador"], ["0873", "ti-ER", "Tigrinya - Eritrea"], ["0C01", "ar-EG", "Arabic - Egypt"], ["0C04", "zh-HK", "Chinese - Hong Kong SAR"], ["0C07", "de-AT", "German - Austria"], ["0C09", "en-AU", "English - Australia"], ["0C0A", "es-ES", "Spanish - Spain"], ["0C0C", "fr-CA", "French - Canada"], ["0C1A", "sr-Cyrl-CS", "Serbian (Cyrillic) - Serbia and Montenegro"], ["0C3B", "se-FI", "Sami (Northern) - Finland"], ["0C6B", "quz-PE", "Quechua - Peru"], ["1001", "ar-LY", "Arabic - Libya"], ["1004", "zh-SG", "Chinese - Singapore"], ["1007", "de-LU", "German - Luxembourg"], ["1009", "en-CA", "English - Canada"], ["100A", "es-GT", "Spanish - Guatemala"], ["100C", "fr-CH", "French - Switzerland"], ["101A", "hr-BA", "Croatian (Latin) - Bosnia and Herzegovina"], ["103B", "smj-NO", "Sami (Lule) - Norway"], ["105F", "tzm-Tfng-MA", "Central Atlas Tamazight (Tifinagh) - Morocco"], ["1401", "ar-DZ", "Arabic - Algeria"], ["1404", "zh-MO", "Chinese - Macao SAR"], ["1407", "de-LI", "German - Liechtenstein"], ["1409", "en-NZ", "English - New Zealand"], ["140A", "es-CR", "Spanish - Costa Rica"], ["140C", "fr-LU", "French - Luxembourg"], ["141A", "bs-Latn-BA", "Bosnian (Latin) - Bosnia and Herzegovina"], ["143B", "smj-SE", "Sami (Lule) - Sweden"], ["1801", "ar-MA", "Arabic - Morocco"], ["1809", "en-IE", "English - Ireland"], ["180A", "es-PA", "Spanish - Panama"], ["180C", "fr-MC", "French - Monaco"], ["181A", "sr-Latn-BA", "Serbian (Latin) - Bosnia and Herzegovina"], ["183B", "sma-NO", "Sami (Southern) - Norway"], ["1C01", "ar-TN", "Arabic - Tunisia"], _
["1c09", "en-ZA", "English - South Africa"], ["1C0A", "es-DO", "Spanish - Dominican Republic"], ["1C1A", "sr-Cyrl-BA", "Serbian (Cyrillic) - Bosnia and Herzegovina"], ["1C3B", "sma-SE", "Sami (Southern) - Sweden"], ["2001", "ar-OM", "Arabic - Oman"], ["2009", "en-JM", "English - Jamaica"], ["200A", "es-VE", "Spanish - Venezuela"], ["201A", "bs-Cyrl-BA", "Bosnian (Cyrillic) - Bosnia and Herzegovina"], ["203B", "sms-FI", "Sami (Skolt) - Finland"], ["2401", "ar-YE", "Arabic - Yemen"], ["2409", "en-029", "English - Caribbean"], ["240A", "es-CO", "Spanish - Colombia"], ["241A", "sr-Latn-RS", "Serbian (Latin) - Serbia"], ["243B", "smn-FI", "Sami (Inari) - Finland"], ["2801", "ar-SY", "Arabic - Syria"], ["2809", "en-BZ", "English - Belize"], ["280A", "es-PE", "Spanish - Peru"], ["281A", "sr-Cyrl-RS", "Serbian (Cyrillic) - Serbia"], ["2C01", "ar-JO", "Arabic - Jordan"], ["2C09", "en-TT", "English - Trinidad and Tobago"], ["2C0A", "es-AR", "Spanish - Argentina"], ["2C1A", "sr-Latn-ME", "Serbian (Latin) - Montenegro"], ["3001", "ar-LB", "Arabic - Lebanon"], ["3009", "en-ZW", "English - Zimbabwe"], ["300A", "es-EC", "Spanish - Ecuador"], ["301A", "sr-Cyrl-ME", "Serbian (Cyrillic) - Montenegro"], ["3401", "ar-KW", "Arabic - Kuwait"], ["3409", "en-PH", "English - Philippines"], ["340A", "es-CL", "Spanish - Chile"], ["3801", "ar-AE", "Arabic - U.A.E."], ["380A", "es-UY", "Spanish - Uruguay"], ["3C01", "ar-BH", "Arabic - Bahrain"], ["3C0A", "es-PY", "Spanish - Paraguay"], ["4001", "ar-QA", "Arabic - Qatar"], ["4009", "en-IN", "English - India"], ["400A", "es-BO", "Spanish - Bolivia"], ["4409", "en-MY", "English - Malaysia"], ["440A", "es-SV", "Spanish - El Salvador"], ["4809", "en-SG", "English - Singapore"], ["480A", "es-HN", "Spanish - Honduras"], ["4C0A", "es-NI", "Spanish - Nicaragua"], ["500A", "es-PR", "Spanish - Puerto Rico"], ["540A", "es-US", "Spanish - United States"], ["7C04", "zh-CHT", "Chinese - Traditional"]]
Func GetCurrentLanguageIniFile($OSLang = @OSLang)
Local $sCombo = ""
Local $sLangFile
Local $iLangID = 0
For $i = 0 To $iLanguageCount - 1
If IsFunc($aAllLanguages[$i][3]) Then $sCombo &= "|" & $aAllLanguages[$i][2]
Next
$sCombo = StringTrimLeft($sCombo, 1)
For $i = 0 To $iLanguageCount - 1
If $aAllLanguages[$i][0] <> $OSLang Then ContinueLoop
$sLangFile = $sAppPath & $aAllLanguages[$i][1] & ".ini"
If FileExists($sLangFile) Then
If Not IsFunc($aAllLanguages[$i][3]) Then
Local $sText = "Your language (id=" & $OSLang & ") is not part of USB-Backup currently." & @CRLF & @CRLF
$sText &= "Please mail me your translation ;)"
MsgBox(0, "USB-Backup", $sText)
EndIf
Return $sLangFile
Else
If IsFunc($aAllLanguages[$i][3]) Then
Local $sIniContent = $aAllLanguages[$i][3](True, $sLangFile)
FileWrite($sLangFile, $sIniContent)
Return $sLangFile
Else
$iLangID = $i
ExitLoop
EndIf
EndIf
Next
If StringLen($sLangFile) = 0 Then
Local $sText = "Your System Language is completly unknown to me?!" & @CRLF
$sText &= "Please tell me more about it?! -> @OSLang=" & @OSLang
MsgBox(0, "USB-Backup", $sText)
Exit
EndIf
Local $width = 400
Local $height = 170
Local $left = @DesktopWidth / 2 - $width / 2
Local $top = @DesktopHeight / 2 - $height / 2
Local $hWnd = GUICreate("USB-Backup", $width, $height, $left, $top, BitOR(0x00080000, $WS_CAPTION))
Local $sText = ""
Local $id_OK = GUICtrlCreateButton('OK', $width - 70, $height - 30, 60, 23)
Local $aCombo = StringSplit($sCombo, "|", 2)
Local $id_Combo = GUICtrlCreateCombo("", 10, $height - 30, $width - 100, 23, BitOR(0x3, 0x40, 0x00200000))
GUICtrlSetData($id_Combo, $sCombo, $aCombo[0])
$sText &= "Sorry, but your language (id=" & $OSLang & ") is not part of USB-Backup." & @CRLF & @CRLF
$sText &= "Which language best suits you?" & @CRLF & @CRLF
$sText &= "Maybe you can send me a translation ;)"
GUICtrlCreateLabel($sText, 10, 10, $width - 20, $height - 60)
GUISetState(@SW_SHOW)
While 1
Switch GUIGetMsg()
Case $id_OK, $GUI_EVENT_CLOSE
$sCombo = GUICtrlRead($id_Combo)
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
Exit
EndFunc
Func InitMsg($sIniName, $sSection, ByRef $mArray, $iCount)
Local $a = IniReadSection($sIniName, $sSection)
If $a[0][0] <> $iCount Then
FileMove($sIniName, $sIniName & ".old", 1)
GetCurrentLanguageIniFile()
$a = IniReadSection($sIniName, $sSection)
EndIf
Dim $mArray[$a[0][0] + 1]
For $i = 1 To $a[0][0]
$mArray[$i] = $a[$i][1]
Next
Return 0
EndFunc
Func InitLanguage()
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
EndFunc
Func Msg($sMsg, $p1 = "", $p2 = "", $p3 = "", $p4 = "", $p5 = "", $p6 = "")
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
EndFunc
InitLanguage()
If _Singleton("USB-Backup", 1) = 0 Then
MsgBox(0, "USB-Backup", Msg($mMessages[1]))
Exit
EndIf
InitBackup()
Func InitBackup()
Local $hSearch = FileFindFirstFile(@TempDir & "\" & "USB-Backup" & "-{*}")
If $hSearch <> -1 Then
While 1
Local $sFileName = FileFindNextFile($hSearch)
If @error Then ExitLoop
DirRemove(@TempDir & "\" & $sFileName, 1)
WEnd
EndIf
$hHelpHandle = DllOpen("HHCtrl.ocx")
_Crypt_Startup()
_GDIPlus_Startup()
ReadConfiguration()
GetCurrentSticks()
CheckForUpdate()
AdlibRegister("GetCurrentSticks", 500)
AdlibRegister("CheckForUpdate", 1000 * 60 * 60)
AdlibRegister("NewVersionHint", 1000 * $sNewVersionHint)
OnAutoItExitRegister("QuitBackup")
TrayInitMenu()
EndFunc
Func QuitBackup()
FileChangeDir(@ScriptDir)
If FileExists($sTempPath) Then DirRemove($sTempPath, 1)
_Crypt_Shutdown()
_GDIPlus_Shutdown()
EndFunc
Func FatalError($sMsg)
MsgBox(16, Msg($mHeadlines[1], "USB-Backup"), $sMsg & @CRLF & @CRLF & Msg($mMessages[2]))
Return
EndFunc
Func DisableTrayMenu()
For $i = 1 To $aTrayItems[0]
TrayItemDelete($aTrayItems[$i])
Next
ReDim $aTrayItems[1]
$aTrayItems[0] = 0
If Not FileExists($sTempPath) Then
DirCreate($sTempPath)
EndIf
AdlibUnRegister("CheckNeedNewBackup")
EndFunc
Func EnableTrayMenu()
DisableTrayMenu()
HotKeySet("{F1}")
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
$c = TrayCreateItem("")
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
$iUpdate = -1000
EndIf
$iAbout = TrayCreateItem(Msg($mTaskTray[3]))
_ArrayAdd($aTrayItems, $iAbout)
$c = TrayCreateItem("")
_ArrayAdd($aTrayItems, $c)
$iExit = TrayCreateItem(Msg($mTaskTray[4]))
_ArrayAdd($aTrayItems, $iExit)
$aTrayItems[0] = UBound($aTrayItems) - 1
AdlibRegister("CheckNeedNewBackup", 1000 * 300)
TraySetState(1)
EndFunc
Func TrayIcon_NoStick()
Local $iUpdateNeeded = CheckNeedNewBackup()
If $iUpdateNeeded == 0 Then
TraySetIcon(@ScriptFullPath, -4)
Else
TraySetIcon(@ScriptFullPath, -6)
EndIf
EndFunc
Func TrayIcon_SomeStick()
Local $iUpdateNeeded = CheckNeedNewBackup()
If $iUpdateNeeded == 0 Then
TraySetIcon(@ScriptFullPath, -3)
Else
TraySetIcon(@ScriptFullPath, -5)
EndIf
EndFunc
Func TrayIcon_BackupStick()
TraySetIcon(@ScriptFullPath, -1)
EndFunc
Func TrayInitMenu()
UpdateCurrentSticks()
TraySetToolTip("USB-Backup")
While 1
Local $msg = TrayGetMsg()
Switch $msg
Case 0, $GUI_EVENT_MOUSEMOVE, $GUI_EVENT_PRIMARYDOWN, $GUI_EVENT_PRIMARYUP, $GUI_EVENT_SECONDARYDOWN, $GUI_EVENT_SECONDARYUP
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
SetupHelp("usage-Settings.html")
RunWait($sEditor & " " & $sAppPath & "USB-Backup" & '.ini')
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
TrayTip("USB-Backup" & " " & "0.5", $sText, $iTrayTipTime, 1)
Case $iExit
Exit
Case $TRAY_EVENT_PRIMARYDOUBLE
Case Else
For $i = 1 To $aBackupTray[0]
Local $id = $aCurrentSticksOkay[$i]
If $aBackupTray[$i] = $msg Then
DisableTrayMenu()
ChooseBackup($id)
EnableTrayMenu()
EndIf
If $aIndexEditTray[$i] = $msg Then
DisableTrayMenu()
If Not GetPasswordForID($id) Then
EnableTrayMenu()
ExitLoop
EndIf
SetupHelp("usage-IndexSettings.html")
RunWait($sEditor & " " & GetTempIndex($id))
UpdateIndexFile($id)
EnableTrayMenu()
EndIf
If $aIndexSaveTray[$i] = $msg Then
If Not GetPasswordForID($id) Then ExitLoop
UpdateIndexFile($id)
EndIf
Next
EndSwitch
WEnd
WriteConfiguration()
EndFunc
Func ReadConfiguration()
Local $sInifile = $sAppPath & "USB-Backup" & '.ini'
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
$aFilePathsTS[$i] = 0
EndIf
Next
EndIf
$sOldVersion = IniRead($sInifile, "Options", "IniVersion", "0")
If $sIniVersion = 0 Then
WriteConfiguration()
ElseIf $sIniVersion > $sOldVersion Then
IniDelete($sInifile, "Options")
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
$sChmVersion = IniRead($sInifile, "Options", "ChmVersion", $sChmVersion)
$sRunBeforeCmd = IniRead($sInifile, "Options", "RunBeforeCmd", $sRunBeforeCmd)
$sRunAfterCmd = IniRead($sInifile, "Options", "RunAfterCmd", $sRunAfterCmd)
$sUsePowerPlan = IniRead($sInifile, "Options", "UsePowerPlan", $sUsePowerPlan)
$sDebugPowerPlan = IniRead($sInifile, "Options", "DebugPowerPlan", $sDebugPowerPlan)
$sShowStatusMessage = IniRead($sInifile, "Options", "ShowStatusMessage", $sShowStatusMessage)
$sChmVersion = Int($sChmVersion)
$sFileNameLen = Int($sFileNameLen)
$sMaxFullBackups = Int($sMaxFullBackups)
WriteConfiguration()
EndFunc
Func WriteConfiguration()
Local $sInifile = $sAppPath & "USB-Backup" & '.ini'
Local $sTemp
$sTemp = ""
_ArraySort($aUSBSticks, 0, 1)
For $i = 1 To $aUSBSticks[0]
$sTemp &= $i & "=" & $aUSBSticks[$i] & @LF
Next
IniWriteSection($sInifile, 'USB Devices', $sTemp)
Dim $aTemp[$aFilePaths[0] + 1][2]
$aTemp[0][0] = $aFilePaths[0]
For $i = 1 To $aFilePaths[0]
$aTemp[$i][1] = $aFilePaths[$i] & "|" & $aFilePathsTS[$i]
Next
_ArraySort($aTemp, 0, 0, 0, 1)
For $i = 1 To $aFilePaths[0]
$aTemp[$i][0] = $i
Next
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
IniWrite($sInifile, "Options", "ChmVersion", $sChmVersion)
IniWrite($sInifile, "Options", "RunBeforeCmd", $sRunBeforeCmd)
IniWrite($sInifile, "Options", "RunAfterCmd", $sRunAfterCmd)
IniWrite($sInifile, "Options", "UsePowerPlan", $sUsePowerPlan)
IniWrite($sInifile, "Options", "ShowStatusMessage", $sShowStatusMessage)
IniDelete($sInifile, "Options", "WaitForStickTime")
EndFunc
Func GetWMIServiceObject()
Local $objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!\\.\root\CIMV2")
If Not IsObj($objWMIService) Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[1]))
Return 0
EndIf
Return $objWMIService
EndFunc
Func GetDriveInfos()
Local $objWMIService = GetWMIServiceObject()
If $objWMIService = 0 Then Return
Local $i = 1
Local $aDrives[30][6]
$aDrives[0][0] = 0
$aDrives[0][1] = 0
Local $oq_drives = $objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive WHERE PNPDeviceID LIKE 'USBSTOR%'")
For $drive In $oq_drives
If $drive.Status <> "OK" Then ContinueLoop
$aDrives[0][1] += 1
Local $oq_parts = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $drive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition")
For $part In $oq_parts
Local $oq_disks = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & $part.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition")
For $disk In $oq_disks
$aDrives[$i][0] = $drive.Caption
$aDrives[$i][1] = $drive.PNPDeviceID
$aDrives[$i][2] = $disk.Caption
$aDrives[$i][3] = StringLeft($disk.Caption, 1)
$aDrives[$i][4] = ""
$aDrives[$i][5] = $aDrives[$i][2] & "\" & "USB-Backup" & "\" & @UserName & "@" & @ComputerName & "\"
$aDrives[0][0] = $i
$i += 1
Next
Next
Next
_ArrayDelete($aDrives, $i & "-29")
Return $aDrives
EndFunc
Func GetCurrentSticks()
Static $iDriveMaskOld = 0
Local $iDriveMask = _WinAPI_GetLogicalDrives()
If $iDriveMaskOld = $iDriveMask Then Return
$iDriveMaskOld = $iDriveMask
$aCurrentSticks = GetDriveInfos()
UpdateCurrentSticks()
EndFunc
Func CheckNeedNewBackup()
Local $diff = $sShowUpdateHint * 24 * 60 * 60
Local $ts = GetTimeStamp()
Local $i, $iMaxDiff = 0
For $i = 1 To $aFilePathsTS[0]
If $aFilePathsTS[$i] = 0 Then ContinueLoop
If $ts - $aFilePathsTS[$i] > $diff Then
If $ts - $aFilePathsTS[$i] > $iMaxDiff Then $iMaxDiff = $ts - $aFilePathsTS[$i]
EndIf
Next
If $iMaxDiff > 0 Then
Local $days = Int($iMaxDiff /(24 * 60 * 60))
If $sShowUpdateHint <> 0 Then
Local $sText = Msg($mTaskTray[14], $days)
TrayTip("USB-Backup" & " " & "0.5", $sText, $iTrayTipTime, 2)
EndIf
Return $days
EndIf
Return 0
EndFunc
Func GetOldestBackup()
Local $i, $ts = 0
For $i = 1 To $aFilePathsTS[0]
If $aFilePathsTS[$i] = 0 Then Return 0
If $ts = 0 Then $ts = $aFilePathsTS[$i]
If $aFilePathsTS[$i] < $ts Then $ts = $aFilePathsTS[$i]
Next
Return $ts
EndFunc
Func UpdateCurrentSticks()
Local $iIsBackupStick = 0
ReDim $aCurrentSticksOkay[1]
$aCurrentSticksOkay[0] = 0
For $i = 1 To $aUSBSticks[0]
Local $aTemp = StringSplit($aUSBSticks[$i], "|", 2)
For $j = 1 To $aCurrentSticks[0][0]
If $aCurrentSticks[$j][$eDeviceID] = $aTemp[$eDeviceID] Then
$iIsBackupStick = 1
ReDim $aCurrentSticksOkay[$aCurrentSticksOkay[0] + 1 + 1]
$aCurrentSticksOkay[0] += 1
$aCurrentSticksOkay[$aCurrentSticksOkay[0]] = $j
EndIf
Next
Next
EnableTrayMenu()
If $aCurrentSticks[0][0] = 0 Then
TrayIcon_NoStick()
Return
EndIf
If $iIsBackupStick = 0 Then
TrayIcon_SomeStick()
Else
TrayIcon_BackupStick()
EndIf
EndFunc
Func RegisterStickUpdateLists($lstCurrent, $lstRegistered, $aCurrentRegistered)
_GUICtrlListBox_ResetContent($lstCurrent)
If IsArray($aCurrentSticks) Then
For $i = 1 To $aCurrentSticks[0][0]
Local $s = ""
$s &= " (" & $aCurrentSticks[$i][$eFullDrive] & ")  - "
$s &= $aCurrentSticks[$i][$eDeviceName]
GUICtrlSetData($lstCurrent, $s)
Next
EndIf
_GUICtrlListBox_ResetContent($lstRegistered)
If IsArray($aCurrentRegistered) Then
For $i = 1 To $aCurrentRegistered[0][0]
Local $s = ""
$s &= " (" & $aCurrentRegistered[$i][$eFullDrive] & ")  - "
$s &= $aCurrentRegistered[$i][$eDeviceName]
GUICtrlSetData($lstRegistered, $s)
Next
EndIf
EndFunc
Func RegisterStickAdd(ByRef $aCurrentRegistered, $i)
For $j = 1 To $aCurrentRegistered[0][0]
If $aCurrentRegistered[$j][$eDeviceID] = $aCurrentSticks[$i + 1][$eDeviceID] Then
Return
EndIf
Next
Local $sNew = ""
$sNew &= $aCurrentSticks[$i + 1][0] & "|"
$sNew &= $aCurrentSticks[$i + 1][1] & "|"
$sNew &= $aCurrentSticks[$i + 1][2]
$aCurrentRegistered[0][0] += 1
_ArrayAdd($aCurrentRegistered, $sNew)
EndFunc
Func RegisterStickDelete(ByRef $aCurrentRegistered, $i)
$aCurrentRegistered[0][0] -= 1
_ArrayDelete($aCurrentRegistered, $i + 1)
EndFunc
Func RegisterStick()
$hGUI = GUICreate(Msg($mHeadlines[2], "USB-Backup"), 800, 400, -1, -1, $gGuiStyle, $gGuiExStyle)
SetupHelp("usage-RegisterStick.html")
Local $aCurrentRegistered[$aUSBSticks[0] + 1][3]
For $i = 1 To $aUSBSticks[0]
Local $aTemp = StringSplit($aUSBSticks[$i], "|", 2)
$aCurrentRegistered[$i][0] = $aTemp[0]
$aCurrentRegistered[$i][1] = $aTemp[1]
$aCurrentRegistered[$i][2] = $aTemp[2]
Next
$aCurrentRegistered[0][0] = $aUSBSticks[0]
GUICtrlCreateLabel(Msg($mLabels[1]), 8, 8, 361, 24)
GUICtrlSetFont(-1, 10)
GUICtrlCreateLabel(Msg($mLabels[2]), 432, 8, 361, 24)
GUICtrlSetFont(-1, 10)
Local $lstCurrent = GUICtrlCreateList("", 8, 32, 361, 329, BitOR(0x00000001, 0x00200000))
Local $btnRegisterStick = GUICtrlCreateButton("-->", 376, 128, 51, 25)
GUICtrlSetTip(-1, Msg($mLabels[3]))
Local $btnDeleteStick = GUICtrlCreateButton("<--", 376, 160, 51, 25)
GUICtrlSetTip(-1, Msg($mLabels[4]))
Local $lstRegistered = GUICtrlCreateList("", 432, 32, 361, 329, BitOR(0x00000001, 0x00200000))
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
GUIDelete($hGUI)
EndFunc
Func GetNewPath(ByRef $aCurrentPaths, ByRef $aCurrentPathsTS)
Local $sPath = _WinAPI_BrowseForFolderDlg("", Msg($mMessages[3]), BitOR(0x00000001, 0x00000020, 0x00000040, 0x00000200))
If @error Or $sPath = "" Then
Return
EndIf
For $i = 1 To $aCurrentPaths[0]
If $sPath = $aCurrentPaths[$i] Then Return
Next
_ArrayAdd($aCurrentPaths, $sPath)
_ArrayAdd($aCurrentPathsTS, 0)
$aCurrentPaths[0] += 1
$aCurrentPathsTS[0] += 1
EndFunc
Func IsJunction($sDirectory)
Local Const $FILE_ATTRIBUTE_JUNCTION = 0x400
If BitAND(_WinAPI_GetFileAttributes($sDirectory), $FILE_ATTRIBUTE_JUNCTION) = $FILE_ATTRIBUTE_JUNCTION Then
Return 1
EndIf
Return 0
EndFunc
Func FindJunctions($sPath, ByRef $sJunctions)
Local $aFileList = _FileListToArray($sPath, "*", 2, True)
If @error <> 0 Then Return
For $i = 1 To $aFileList[0]
If IsJunction($aFileList[$i]) Then
$sJunctions = $sJunctions & $aFileList[$i] & "|"
Else
FindJunctions($aFileList[$i], $sJunctions)
EndIf
Next
EndFunc
Func RegisterPath()
$hGUI = GUICreate(Msg($mHeadlines[3], "USB-Backup"), 800, 400, -1, -1, $gGuiStyle, $gGuiExStyle)
SetupHelp("usage-RegisterPath.html")
Local $aCurrentPaths = $aFilePaths
Local $aCurrentPathsTS = $aFilePathsTS
GUICtrlCreateLabel(Msg($mLabels[5]), 8, 8, 786, 24)
GUICtrlSetFont(-1, 10)
Local $lstPath = GUICtrlCreateList("", 8, 32, 785, 329, BitOR(0x00000001, 0x00200000))
Local $btnAdd = GUICtrlCreateButton(Msg($mButtons[4]), 8, 368, 110, 25)
Local $btnDel = GUICtrlCreateButton(Msg($mButtons[5]), 122, 368, 110, 25)
Local $btnExclude = GUICtrlCreateButton(Msg($mButtons[7]), 236, 368, 140, 25)
Local $btnExcludeR = GUICtrlCreateButton(Msg($mButtons[8]), 380, 368, 140, 25)
Local $btnOkay = GUICtrlCreateButton(Msg($mButtons[1]), 640, 368, 65, 25)
Local $btnCancel = GUICtrlCreateButton(Msg($mButtons[2]), 710, 368, 85, 25)
For $i = 1 To $aCurrentPaths[0]
GUICtrlSetData($lstPath, $aCurrentPaths[$i])
Next
GUISetState(@SW_SHOW, $hGUI)
While 1
Local $msg = GUIGetMsg()
Switch $msg
Case 0, $GUI_EVENT_MOUSEMOVE
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
DisableTrayMenu()
SetupHelp("usage-Exclude.html")
Local $sCurrentPath = $aCurrentPaths[$i + 1]
Local $sExcludeFile
If $msg = $btnExclude Then
$sExcludeFile = GetExcludeFile_X($sAppPath, $sCurrentPath)
Else
$sExcludeFile = GetExcludeFile_XR($sAppPath, $sCurrentPath)
EndIf
If Not FileExists($sExcludeFile) Then
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
SetupHelp("usage-RegisterPath.html")
Case $btnDel
Local $i = _GUICtrlListBox_GetCurSel($lstPath)
If $i = -1 Then ContinueLoop
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
GUIDelete($hGUI)
ReadConfiguration()
EndFunc
Func FindFreeDrives($iMinDrives)
Local $iDrives = _WinAPI_GetLogicalDrives()
Local $iCount = 0
Local $iCurrentBit = 1
If $iMinDrives = 0 Then
Return 0
EndIf
For $i = 1 To 26
If Not BitAND($iDrives, $iCurrentBit) Then
$iCount += 1
EndIf
$iCurrentBit *= 2
Next
If $iCount < $iMinDrives Then
MsgBox(0, "USB-Backup", Msg($mFatalErrors[1]))
Exit
EndIf
Local $aFreeDrives[$iMinDrives + 1]
$aFreeDrives[0] = $iMinDrives
$iCount = 0
$iCurrentBit = 1
For $i = 1 To 26
If Not BitAND($iDrives, $iCurrentBit) Then
Local $sDriveLetter = Chr($i + 64)
$iCount += 1
$aFreeDrives[$iCount] = $sDriveLetter & ":"
EndIf
If $iCount = $iMinDrives Then
Return $aFreeDrives
EndIf
$iCurrentBit *= 2
Next
Return $aFreeDrives
EndFunc
Func FindVSSDrivesForBackup($aBackupTodo)
Dim $aDrivesWithVSS[30][2]
$aDrivesWithVSS[0][0] = 0
Dim $aTemp[$aBackupTodo[0]]
For $i = 1 To $aBackupTodo[0]
Local $sDriveLetter = StringUpper(StringLeft($aBackupTodo[$i], 2))
If $sDriveLetter = "\\" Then
ContinueLoop
EndIf
Local $iText = DriveStatus($sDriveLetter & "\")
If $iText <> "READY" Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[2], $sDriveLetter))
Return 0
EndIf
$aTemp[$i - 1] = $sDriveLetter
Next
Local $aDrivesInBackup = _ArrayUnique($aTemp)
Local $aDrivesFixed = DriveGetDrive("FIXED")
If Not IsArray($aDrivesInBackup) Then
ReDim $aDrivesWithVSS[1][2]
Return $aDrivesWithVSS
EndIf
For $i = 1 To $aDrivesInBackup[0]
For $j = 1 To $aDrivesFixed[0]
Local $sDrive = StringUpper($aDrivesFixed[$j])
If $aDrivesInBackup[$i] = $sDrive Then
$aDrivesWithVSS[0][0] += 1
$aDrivesWithVSS[$aDrivesWithVSS[0][0]][0] = $sDrive
EndIf
Next
Next
$aDrivesInBackup = 0
Local $aFreeDrives = FindFreeDrives($aDrivesWithVSS[0][0])
For $i = 1 To $aDrivesWithVSS[0][0]
$aDrivesWithVSS[$i][1] = $aFreeDrives[$i]
Next
_ArrayDelete($aDrivesWithVSS, $aDrivesWithVSS[0][0] + 1 & "-29")
Return $aDrivesWithVSS
EndFunc
Func CheckBackupPaths()
Local $aToCheck = $aFilePaths
Local $iError = 0
For $i = 1 To $aToCheck[0]
If Not FileExists($aToCheck[$i]) Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[3], $aToCheck[$i]))
$iError += 1
ContinueLoop
EndIf
If Not StringInStr(FileGetAttrib($aToCheck[$i]), "D") Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[4], $aToCheck[$i]))
$iError += 1
EndIf
Next
Return $iError
EndFunc
Func GetCurrentDate()
Return @YEAR & "-" & @MON & "-" & @MDAY
EndFunc
Func GetCurrentTime()
Return @HOUR & ":" & @MIN & ":" & @SEC
EndFunc
Func GetTimeStamp()
Return _DateDiff('s', "1970/01/01 00:00:00", _NowCalc())
EndFunc
Func StringFormatTime($sFormat, $iTimestamp = 0)
Local $DateTS = _DateAdd("s", $iTimestamp, "1970/01/01 00:00:00")
Local $aMyDate, $aMyTime
_DateTimeSplit($DateTS, $aMyDate, $aMyTime)
Local $sDate = $sFormat
$sDate = StringReplace($sDate, "%Y", StringFormat("%04d", $aMyDate[1]), 0, 1)
$sDate = StringReplace($sDate, "%m", StringFormat("%02d", $aMyDate[2]), 0, 1)
$sDate = StringReplace($sDate, "%d", StringFormat("%02d", $aMyDate[3]), 0, 1)
$sDate = StringReplace($sDate, "%H", StringFormat("%02d", $aMyTime[1]), 0, 1)
$sDate = StringReplace($sDate, "%M", StringFormat("%02d", $aMyTime[2]), 0, 1)
$sDate = StringReplace($sDate, "%S", StringFormat("%02d", $aMyTime[3]), 0, 1)
Return $sDate
EndFunc
Func GetTimeElapsed($ts)
Local $sTime = ""
Local $x
$x = Int($ts /(60 * 60))
$ts -= $x * 60 * 60
$sTime = StringFormat("%02d", $x) & ":"
$x = Int($ts / 60)
$ts -= $x * 60
$sTime &= StringFormat("%02d:%02d", $x, $ts)
Return $sTime
EndFunc
Func GetSeconds($sTime)
Local $iSeconds = 0
Local $aTime = StringSplit($sTime, ":")
If $aTime[0] <> 3 Then FatalError("@ GetSeconds($sTime=" & $sTime & ") -> keine 2x : dabei ?!")
$iSeconds += Int($aTime[1]) * 60 * 60
$iSeconds += Int($aTime[2]) * 60
$iSeconds += Int($aTime[3])
Return $iSeconds
EndFunc
Func GetBackupTime($ts)
Local $sTime = ""
Local $x
$x = Int($ts /(60 * 60 * 24))
If $x > 0 Then
$ts -= $x * 60 * 60 * 24
$sTime &= $x & "d"
EndIf
$x = Int($ts /(60 * 60))
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
EndFunc
Func MyInputBox($title, $helpIndex, $text, $default = "", $style = "")
Local $width = 370
Local $height = 130
Local $left = @DesktopWidth / 2 - $width / 2
Local $top = @DesktopHeight / 2 - $height / 2
Local $hWnd = GUICreate($title, $width, $height, $left, $top, BitOR(0x00080000, $WS_CAPTION))
SetupHelp("$helpIndex")
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
EndFunc
Func AboutBox()
Local $width = 500
Local $height = 260
Local $left = @DesktopWidth / 2 - $width / 2
Local $top = @DesktopHeight / 2 - $height / 2
Local $mail = "E-Mail: milky-usb-backup" & "@" & "mcmilk.de"
Local $hWnd = GUICreate("USB-Backup", $width, $height, $left, $top, BitOR(0x00080000, $WS_CAPTION))
$sHelpTopic = "usage-About.html"
Local $x = 50, $y = 40, $h = 21, $c, $a
GUISetFont(9)
$c = GUICtrlCreateLabel("© 2014 - 2016 Tino Reichardt / LKEE,", $x, $y + $h)
GUICtrlSetTip($c, $mail)
$a = ControlGetPos($hWnd, "", $c)
Local $web1 = GUICtrlCreateLabel("Homepage", $a[0] + $a[2] - 5, $y + $h)
GUICtrlSetTip($web1, $mail)
GUICtrlSetColor(-1, $COLOR_BLUE)
GUICtrlSetFont(-1, -1, -1, 4)
GUICtrlSetCursor(-1, 0)
$c = GUICtrlCreateLabel("© 1999 - 2016 Igor Pavlov (7-Zip),", $x, $y + $h * 3)
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
$c = GUICtrlCreateLabel("USB-Backup" & " - Version " & "0.5", 10, 10, 480, -1, 0x1)
GUISetFont(8.5)
$c = GUICtrlCreateLabel($sUpdateAppVersion, $width - 60, $height - 35, 60, -1, 0x1)
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
Case 4
ExitLoop
Case $GUI_EVENT_CLOSE
ExitLoop
EndSwitch
WEnd
GUIDelete($hWnd)
Return
EndFunc
Func MyPKDF($sKey, $rounds = 1000)
Local $sPW = $sKey
For $i = 1 To $rounds
$sKey = SHA3($sKey & $sPW & $i, 512)
Next
Return $sKey
EndFunc
Func MyEncrypt($scData, $sPassword)
Local $cData = _Crypt_EncryptData($scData, MyPKDF($sPassword), 0x00006610)
Return $cData
EndFunc
Func MyMiniHash($sPath)
Return StringLower(StringMid(SHA3($sPath & $sSaltValue, 224), 3, $sFileNameLen))
EndFunc
Func GetExcludeFile_X($sPrefix, $sFilePath)
Return $sPrefix & "X_" & StringLower(StringMid(SHA3($sFilePath, 224), 5, $sFileNameLen)) & '.txt'
EndFunc
Func GetExcludeFile_XR($sPrefix, $sFilePath)
Return $sPrefix & "XR_" & StringLower(StringMid(SHA3($sFilePath, 224), 5, $sFileNameLen)) & '.txt'
EndFunc
Func GetTempIndex($id, $iMode = 0)
Static $sFsType = ""
If $sFsType = "" Then $sFsType = DriveGetFileSystem(StringLeft($sTempPath, 2))
If $sFsType = "NTFS" Then
If $iMode <> 0 Then Return $sTempPath & "Index"
Return $sTempPath & "Index:" & $id & $aCurrentSticks[$id][$eDriveLetter] & ".ini"
EndIf
Return $sTempPath & "Index-" & $id & $aCurrentSticks[$id][$eDriveLetter] & ".ini"
EndFunc
Func FileDeleteSave($id)
Static $sFsType = ""
Local $sFileName = GetTempIndex($id)
Local $hFile = FileOpen($sFileName, 0 + 2)
If $hFile = -1 Then Return
FileSetPos($hFile, 0, 0)
Local $sPlain = FileRead($hFile)
Local $sKey = SHA3($sPlain & $sSaltValue, 512)
Local $sData = BinaryToString(_Crypt_EncryptData($sPlain, $sKey, 0x00006610))
FileSetPos($hFile, 0, 0)
FileWrite($hFile, $sData)
FileFlush($hFile)
FileClose($hFile)
FileDelete(GetTempIndex($id, 1))
EndFunc
Func MyDecrypt($cData, $sPassword)
Local $sData = String(BinaryToString(_Crypt_DecryptData($cData, MyPKDF($sPassword), 0x00006610), 4))
Return $sData
EndFunc
Func ReadIndexFile($sIndexFile, $sPassword)
Local $cData = FileRead($sIndexFile)
If @error <> 0 Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[5], $sIndexFile))
Return ""
EndIf
Local $sData = MyDecrypt($cData, $sPassword)
If @error <> 0 Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[6], $sIndexFile))
Return ""
EndIf
If StringCompare(StringLeft($sData, 12), "[" & "USB-Backup" & "]") <> 0 Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[7]))
Return ""
EndIf
Return $sData
EndFunc
Func UpdateIndexFile($id)
Local $sBackupPath = $aCurrentSticks[$id][$eBackupPath]
Local $sPassword = $aCurrentSticks[$id][$ePassword]
Local $sIndexFile = $sBackupPath & "Index"
Local $sIndexTemp = GetTempIndex($id)
Local $sSection = "USB-Backup"
Local $x
$x = IniRead($sIndexTemp, $sSection, "cdate", GetCurrentDate())
IniWrite($sIndexTemp, $sSection, "cdate", $x)
$x = IniRead($sIndexTemp, $sSection, "ctime", GetCurrentTime())
IniWrite($sIndexTemp, $sSection, "ctime", $x)
$x = IniRead($sIndexTemp, $sSection, "cts", GetTimeStamp())
IniWrite($sIndexTemp, $sSection, "cts", $x)
$sSaltValue = IniRead($sIndexTemp, $sSection, "SaltValue", "0")
If $sSaltValue = "0" Then
$sSaltValue = StringMid(MyPKDF(_WinAPI_CreateGUID(), 20), 3)
IniWrite($sIndexTemp, $sSection, "SaltValue", $sSaltValue)
EndIf
For $i = 1 To $aFilePaths[0]
$x = IniRead($sIndexTemp, $aFilePaths[$i], "cts", GetTimeStamp())
IniWrite($sIndexTemp, $aFilePaths[$i], "cts", $x)
$x = IniRead($sIndexTemp, $aFilePaths[$i], "fts", "0")
IniWrite($sIndexTemp, $aFilePaths[$i], "fts", $x)
Next
IniWrite($sIndexTemp, $sSection, "mdate", GetCurrentDate())
IniWrite($sIndexTemp, $sSection, "mtime", GetCurrentTime())
IniWrite($sIndexTemp, $sSection, "mts", GetTimeStamp())
Local $sData = FileRead($sIndexTemp)
If @error <> 0 Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[5], $sIndexTemp))
Return ""
EndIf
Local $cData = MyEncrypt($sData, $sPassword)
DirCreate($sBackupPath)
Local $hFile = FileOpen($sIndexFile, 2)
If FileWrite($hFile, $cData) <> 1 Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[8], $sIndexFile))
EndIf
FileFlush($hFile)
FileClose($hFile)
Return
EndFunc
Func GetPasswordForID($id)
Local $sBackupPath = $aCurrentSticks[$id][$eBackupPath]
Local $sIndexFile = $sBackupPath & "Index"
Local $sIndexTemp = GetTempIndex($id)
Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
Local $sData = ""
Local $sPassword = ""
If Not FileExists($sIndexFile) Then
Do
Local $sPass1 = MyInputBox("USB-Backup", "usage-BackupPassword.html", Msg($mLabels[6], $sDrive), "", 32)
If $sPass1 = "" Then Return
$sPassword = MyInputBox("USB-Backup", "usage-BackupPassword.html", Msg($mLabels[7], $sDrive), "", 32)
If $sPassword = "" Then Return
Until $sPass1 = $sPassword
$aCurrentSticks[$id][$ePassword] = $sPassword
_Crypt_DestroyKey($sPass1)
_Crypt_DestroyKey($sPassword)
UpdateIndexFile($id)
$sData = ReadIndexFile($sIndexFile, $sPassword)
Else
Do
If $aCurrentSticks[$id][$ePassword] <> "" Then
$sPassword = $aCurrentSticks[$id][$ePassword]
Else
$sPassword = MyInputBox("USB-Backup", "usage-BackupPassword.html", Msg($mLabels[8], $sDrive), "", 32)
EndIf
_Crypt_DestroyKey($aCurrentSticks[$id][$ePassword])
$aCurrentSticks[$id][$ePassword] = ""
If $sPassword = "" Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[9]) & @CRLF & @CRLF & $sIndexFile)
Return 0
EndIf
$sData = ReadIndexFile($sIndexFile, $sPassword)
Until $sData <> ""
EndIf
FileDeleteSave($id)
Local $hFile = FileOpen($sIndexTemp, 2)
FileWrite($hFile, $sData)
FileFlush($hFile)
FileClose($hFile)
$aCurrentSticks[$id][$ePassword] = $sPassword
UpdateIndexFile($id)
Return 1
EndFunc
Func ChooseBackup($id)
If $sCheckForUpdate Then CheckForUpdate()
If CheckBackupPaths() Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[10]))
Return
EndIf
If Not GetPasswordForID($id) Then Return
Local $aBackupTodo = ManageBackups($id)
If Not IsArray($aBackupTodo) Then
FileDeleteSave($id)
Return
EndIf
CreateNewBackup($id, $aBackupTodo)
Return
EndFunc
Func ManageBackups_Info($id, $msg, $tvid, $tv, ByRef $aBackups, ByRef $aBackupTodo, ByRef $aGuiIDs)
Local $sIndexTemp = GetTempIndex($id)
Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
Local $iReturn = 0
Static $iOldIndex = -1
Local $iIndex
Static $radioAddTodo, $radioDelTodo
Static $btnDelete, $ClickDirectory, $ClickFullZIP, $ClickUpdateZIP, $ClickFullWarn, $ClickUpdateWarn
For $iIndex = 1 To $aBackups[0][0]
If $aBackups[$iIndex][1] = $tvid Then ExitLoop
Next
If $iIndex > $aBackups[0][0] Then
$iOldIndex = -1
Return 0
EndIf
Local $aCurrentQuery[9]
For $i = 0 To 8
$aCurrentQuery[$i] = $aBackups[$iIndex][$i]
Next
If $iOldIndex > $aBackups[0][0] Then $iOldIndex = -1
Local $aLastQuery[9]
If $iOldIndex <> -1 Then
For $i = 0 To 8
$aLastQuery[$i] = $aBackups[$iOldIndex][$i]
Next
EndIf
If Int($msg) = Int($tvid) Then
$btnDelete = ""
$ClickDirectory = ""
$ClickFullZIP = ""
$ClickUpdateZIP = ""
$ClickFullWarn = ""
$ClickUpdateWarn = ""
EndIf
For $iTodoIndex = 1 To $aBackupTodo[0][0]
If $aBackupTodo[$iTodoIndex][1] = $tvid Then ExitLoop
Next
If($iOldIndex <> -1) And($msg = $btnDelete) Then
Switch $aLastQuery[0]
Case "p"
If $aLastQuery[2] <> 1 Then
If MsgBox(4, "USB-Backup", Msg($mMessages[4])) = 6 Then
DirRemove($aLastQuery[3], 1)
IniDelete($sIndexTemp, $aLastQuery[5])
UpdateIndexFile($id)
_GUICtrlTreeView_DeleteAll($tv)
$iReturn = 1
EndIf
EndIf
Case "f"
If MsgBox(4, "USB-Backup", Msg($mMessages[5])) = 6 Then
DirRemove($aLastQuery[3], 1)
IniDelete($sIndexTemp, $aLastQuery[5], "f" & $aLastQuery[4])
UpdateIndexFile($id)
Local $sDir = $sAppPath & "Logfiles\" & MyMiniHash($aLastQuery[5] & $aLastQuery[4])
If FileExists($sDir) Then DirRemove($sDir, 1)
_GUICtrlTreeView_DeleteAll($tv)
$iReturn = 1
EndIf
Case "u"
If MsgBox(4, "USB-Backup", Msg($mMessages[6])) = 6 Then
FileDelete($aLastQuery[8])
Local $aTS = StringSplit($aLastQuery[4], "+")
Local $sOld = IniRead($sIndexTemp, $aLastQuery[5], "f" & $aTS[1], "")
Local $aU = StringSplit($sOld, ";")
Local $sNew = $aU[1]
For $i = 2 To $aU[0]
Local $aU2 = StringSplit($aU[$i], ":")
If $aU2[1] <> $aTS[2] Then
$sNew &= ";" & $aU[$i]
EndIf
Next
IniWrite($sIndexTemp, $aLastQuery[5], "f" & $aTS[1], $sNew)
UpdateIndexFile($id)
_GUICtrlTreeView_DeleteAll($tv)
$iReturn = 1
EndIf
EndSwitch
ElseIf $msg <> $tvid Then
If $msg = $ClickDirectory Then
ShellExecute($aLastQuery[3])
ElseIf $msg = $ClickFullZIP Then
ShellExecute($aLastQuery[7])
ElseIf $msg = $ClickUpdateZIP Then
ShellExecute($aLastQuery[8])
ElseIf $msg = $ClickFullWarn Then
Local $s = StringTrimRight($aLastQuery[7], 3)
Local $sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
Run($sEditor & " " & $sErrorLog)
ElseIf $msg = $ClickUpdateWarn Then
Local $s = StringTrimRight($aLastQuery[8], 3)
Local $sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
Run($sEditor & " " & $sErrorLog)
ElseIf $msg = $radioAddTodo Then
Switch $aBackupTodo[$iTodoIndex][0]
Case "na"
$aBackupTodo[$iTodoIndex][0] = "a"
$aBackupTodo[0][1] += 1
Case "nu"
$aBackupTodo[$iTodoIndex][0] = "u"
$aBackupTodo[0][2] += 1
EndSwitch
ElseIf $msg = $radioDelTodo Then
Switch $aBackupTodo[$iTodoIndex][0]
Case "a"
$aBackupTodo[$iTodoIndex][0] = "na"
$aBackupTodo[0][1] -= 1
Case "u"
$aBackupTodo[$iTodoIndex][0] = "nu"
$aBackupTodo[0][2] -= 1
EndSwitch
EndIf
Return $iReturn
EndIf
For $i = 1 To $aGuiIDs[0]
GUICtrlDelete($aGuiIDs[$i])
Next
Dim $aGuiIDs[1]
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
If $aCurrentQuery[2] = "1" Then
If $aCurrentQuery[7] = 0 Then
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
GUICtrlSetState($radioAddTodo, 1)
Else
GUICtrlSetState($radioDelTodo, 1)
EndIf
$btnDelete = -1
Else
$c = GUICtrlCreateButton(Msg($mButtons[6]), 710, 327, 75, 25)
$btnDelete = $c
_ArrayAdd($aGuiIDs, $c)
EndIf
Case "f"
Local $sArchiv = StringRight($aCurrentQuery[7], $sFileNameLen + 3)
Local $s = StringTrimRight($aCurrentQuery[7], 3)
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
If $aCurrentQuery[2] = "1" Then
$c = GUICtrlCreateRadio(Msg($mLabels[26]), 504, 318, 200, 17)
$radioAddTodo = $c
_ArrayAdd($aGuiIDs, $c)
$c = GUICtrlCreateRadio(Msg($mLabels[27]), 504, 336, 200, 17)
$radioDelTodo = $c
_ArrayAdd($aGuiIDs, $c)
If $aBackupTodo[$iTodoIndex][0] <> "nu" Then
GUICtrlSetState($radioAddTodo, 1)
Else
GUICtrlSetState($radioDelTodo, 1)
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
$iOldIndex = $iIndex
$aGuiIDs[0] = UBound($aGuiIDs) - 1
Return $iReturn
EndFunc
Func ManageBackups_TV($id, $tv, $aPaths, ByRef $aBackups, ByRef $aBackupTodo, $sColor = "")
Local $tsCurrent = GetTimeStamp()
Local $sIndexTemp = GetTempIndex($id)
Local $sBackupBase = $aCurrentSticks[$id][$eBackupPath]
Local $sText
For $iPath = 1 To $aPaths[0]
Local $sPath = $aPaths[$iPath]
Local $tvPath = GUICtrlCreateTreeViewItem("[" & $sPath & "]", $tv)
Local $iPathBytesBackups = 0
Local $iPathBytesUpdates = 0
Local $sIsBackup = "|1|"
If $sColor <> "" Then
GUICtrlSetColor($tvPath, $sColor)
$sIsBackup = "|0|"
EndIf
Local $sMaxFTS = 0
Local $sCTS = IniRead($sIndexTemp, $sPath, "cts", "0")
Local $sFTS = IniRead($sIndexTemp, $sPath, "fts", "0")
Local $sBackupPath = $sBackupBase & MyMiniHash($sPath)
_ArrayAdd($aBackups, "p|" & $tvPath & $sIsBackup & $sBackupPath & "|" & $sCTS & "|" & $sPath & "|0|0|0")
$aBackups[0][0] += 1
$aBackups[0][1] += 1
Local $iLastPath = $aBackups[0][0]
If $sColor = "" Then
Local $sBackupFull = $sBackupPath & "\" & MyMiniHash($sPath & $tsCurrent)
Local $sBackupFullZip = $sBackupFull & "\" & MyMiniHash($sPath & $tsCurrent) & ".7z"
If $sFTS = "0" Then
_ArrayAdd($aBackupTodo, "a|" & $tvPath & "|f" & $tsCurrent & "|" & $tsCurrent & "|" & $sPath & "|" & $sBackupFullZip)
$aBackupTodo[0][0] += 1
$aBackupTodo[0][1] += 1
DirCreate($sBackupPath)
ContinueLoop
Else
_ArrayAdd($aBackupTodo, "na|" & $tvPath & "|f" & $tsCurrent & "|" & $tsCurrent & "|" & $sPath & "|" & $sBackupFullZip)
$aBackupTodo[0][0] += 1
EndIf
EndIf
Local $aSection = IniReadSection($sIndexTemp, $sPath)
If @error <> 0 Then FatalError(Msg($mFatalErrors[2]))
For $iSection = 1 To $aSection[0][0]
Local $sKey = $aSection[$iSection][0]
If Not(StringLeft($sKey, 1) = "f") Then ContinueLoop
If Not StringIsDigit(StringTrimLeft($sKey, 1)) Then ContinueLoop
Local $sFull = $aSection[$iSection][1]
Local $aFull = StringSplit($sFull, ";")
If Not IsArray($aFull) Then FatalError(Msg($mFatalErrors[3]))
Local $aUpdate = StringSplit($aFull[1], ":")
If Not IsArray($aUpdate) Then FatalError(Msg($mFatalErrors[4]))
Local $sFTimeStamp = $aUpdate[1]
Local $sLength = GetBackupTime($aUpdate[2])
Local $sText = Msg($mLabels[31], $sLength)
Local $tvFull = GUICtrlCreateTreeViewItem(StringFormatTime($sText, $sFTimeStamp), $tvPath)
If $sColor <> "" Then GUICtrlSetColor($tvFull, $sColor)
Local $sBackupFull = $sBackupPath & "\" & MyMiniHash($sPath & $sFTimeStamp)
Local $sBackupFullZip = $sBackupFull & "\" & MyMiniHash($sPath & $sFTimeStamp) & ".7z"
Local $sBackupUpdate = $sBackupFull & "\" & MyMiniHash($sPath & $sFTimeStamp & $tsCurrent) & ".7z"
If Not FileExists($sBackupFullZip) Then
$sText = Msg($mLabels[32]) & @CRLF
$sText &= StringLeft($sBackupFullZip, 23) & "..." & StringRight($sBackupFullZip, 23) & @CRLF & @CRLF
$sText &= Msg($mLabels[33]) & @CRLF & @CRLF
$sText &= Msg($mLabels[34]) & @CRLF
MsgBox(48, "USB-Backup", $sText)
IniDelete($sIndexTemp, $sPath, "f" & $sFTimeStamp)
UpdateIndexFile($id)
ContinueLoop
EndIf
DirCreate($sBackupFull)
Local $s = "f|" & $tvFull & $sIsBackup & $sBackupFull & "|" & $sFTimeStamp
$s &= "|" & $sPath & "|" & $aUpdate[3] & "|" & $sBackupFullZip & "|0"
_ArrayAdd($aBackups, $s)
$aBackups[0][0] += 1
$aBackups[0][2] += 1
$aBackups[0][5] += $aUpdate[3]
$iPathBytesBackups += $aUpdate[3]
$aBackups[$iLastPath][7] += 1
Local $iLastFull = $aBackups[0][0]
_ArrayAdd($aBackupTodo, "nu|" & $tvFull & "|f" & $sFTimeStamp & "|" & $tsCurrent & "|" & $sPath & "|" & $sBackupFullZip & "|" & $sBackupUpdate)
$aBackupTodo[0][0] += 1
For $iArchivUpdate = 2 To $aFull[0]
Local $aUpdate = StringSplit($aFull[$iArchivUpdate], ":")
If Not IsArray($aUpdate) Then FatalError(Msg($mFatalErrors[4]))
Local $sUTimeStamp = $aUpdate[1]
Local $sLength = GetBackupTime($aUpdate[2])
Local $sText = Msg($mLabels[37], $sLength)
Local $tvUpdate = GUICtrlCreateTreeViewItem(StringFormatTime($sText, $sUTimeStamp), $tvFull)
Local $sBackupUpdate = $sBackupFull & "\" & MyMiniHash($sPath & $sFTimeStamp & $sUTimeStamp) & ".7z"
If $sColor <> "" Then GUICtrlSetColor($tvUpdate, $sColor)
If Not FileExists($sBackupUpdate) Then
$sText = Msg($mLabels[35]) & @CRLF
$sText &= StringLeft($sBackupFullZip, 23) & "..." & StringRight($sBackupFullZip, 23) & @CRLF & @CRLF
$sText &= Msg($mLabels[33]) & @CRLF & @CRLF
$sText &= Msg($mLabels[36]) & @CRLF
MsgBox(48, "USB-Backup", $sText)
FileWrite($sBackupUpdate, "Jemand hatte diese Datei einfach gelöscht... :/")
EndIf
Local $s = "u|" & $tvUpdate & $sIsBackup & $sBackupFull & "|" & $sFTimeStamp & "+" & $sUTimeStamp
$s &= "|" & $sPath & "|" & $aUpdate[3] & "|" & $sBackupFullZip & "|" & $sBackupUpdate
_ArrayAdd($aBackups, $s)
$aBackups[0][0] += 1
$aBackups[0][3] += 1
$aBackups[0][4] += $aUpdate[3]
$aBackups[$iLastPath][8] += 1
$aBackups[$iLastFull][8] += $aUpdate[3]
$iPathBytesUpdates += $aUpdate[3]
Next
If $sMaxFTS < $sFTimeStamp Then $sMaxFTS = $sFTimeStamp
Next
If $sMaxFTS <> $sFTS Then
IniWrite($sIndexTemp, $sPath, "fts", $sMaxFTS)
UpdateIndexFile($id)
$sFTS = $sMaxFTS
EndIf
Local $i = 0
If($sColor = "") Then
If $sFTS +($sFullBackupIn * 60 * 60 * 24) > $tsCurrent Then
Do
If($aBackupTodo[$i][0] = "nu") And($aBackupTodo[$i][4] = $sPath) And($aBackupTodo[$i][2] = "f" & $sFTS) Then
$aBackupTodo[$i][0] = "u"
$aBackupTodo[0][2] += 1
ExitLoop
EndIf
$i += 1
Until UBound($aBackupTodo) - 1 < $i
Else
Do
If($aBackupTodo[$i][0] = "na") And($aBackupTodo[$i][4] = $sPath) Then
$aBackupTodo[0][1] += 1
$aBackupTodo[$i][0] = "a"
ExitLoop
EndIf
$i += 1
Until UBound($aBackupTodo) - 1 < $i
EndIf
EndIf
$aBackups[$iLastPath][6] = $iPathBytesBackups & "+" & $iPathBytesUpdates
Next
EndFunc
Func GetOLDFilePaths($sIndexTemp, ByRef $aOldPaths)
Local $aOldBackups = IniReadSectionNames($sIndexTemp)
_ArrayDelete($aOldBackups, 0)
While UBound($aOldBackups)
Local $s = _ArrayPop($aOldBackups)
Local $sFound = "no"
If $s = "USB-Backup" Then ContinueLoop
For $i = 1 To $aFilePaths[0]
If $s = $aFilePaths[$i] Then $sFound = "yes"
Next
If $sFound = "yes" Then ContinueLoop
_ArrayAdd($aOldPaths, $s)
WEnd
$aOldPaths[0] = UBound($aOldPaths) - 1
EndFunc
Func DrawSpaceUsage($sDrive)
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
Local $sColors = "0x0000ff,0xff00ff"
Local $sValues = Int($iUsed) & "," & Int($iFree)
_DrawPie($hGUI, $sValues, $sColors, 650, $y1 + 22, 128, 40, 15)
_DrawLegend($hGUI, $sValues, $sColors, Msg($mLabels[41]), 504 - 2, $y1 + 86, 17, 8.5, 82, 70)
EndFunc
Func DrawSpaceUsageStatus($sDrive, $iNew)
Static $ts = 0
If $iNew = 0 Then
$ts = 0
EndIf
If $ts + 3 > GetTimeStamp() Then Return
Local $iTotal = DriveSpaceTotal($sDrive) * 1024 * 1024
Local $iFree = DriveSpaceFree($sDrive) * 1024 * 1024
Local $iUsed = $iTotal - $iFree
Local $x1 = 18, $y1 = 264, $h = 18
If $ts = 0 Then
GUICtrlCreateLabel(Msg($mLabels[38]), $x1, $y1, 82, 17)
GUICtrlCreateLabel(Msg($mLabels[39]), $x1, $y1 + $h, 82, 17)
GUICtrlCreateLabel(DriveGetLabel($sDrive), $x1 + 87, $y1, 190, 17)
GUICtrlCreateLabel(DriveGetFileSystem($sDrive), $x1 + 87, $y1 + $h, 82, 17)
GUICtrlCreateLabel(Msg($mLabels[40]), $x1, $y1 + 51, 56, 17)
GUICtrlCreateLabel(_WinAPI_StrFormatByteSize($iTotal), $x1 + 57, $y1 + 51, 65, 17)
EndIf
$ts = GetTimeStamp()
Local $sColors = "0x0000ff,0x00ccff,0xff00ff"
Local $sValues = Int($iUsed - $iNew) & "," & Int($iNew) & "," & Int($iFree)
_DrawPie($hGUI, $sValues, $sColors, $x1 + 148, $y1 + 18, 134, 31, 13)
_DrawLegend($hGUI, $sValues, $sColors, Msg($mLabels[42]), $x1 - 2, $y1 + 70, 18, 8.5, 56, 75)
Return
EndFunc
Func GetWindowBkColor()
Local $iOpt = Opt("WinWaitDelay", 10)
Local $hWnd = GUICreate("", 2, 2, 1, 1, 0x80000000, 0x00000080)
GUISetState()
WinWait($hWnd)
Local $iColor = PixelGetColor(1, 1, $hWnd)
GUIDelete($hWnd)
Opt("WinWaitDelay", $iOpt)
Return $iColor
EndFunc
Func ManageBackups($id)
Local $sIndexTemp = GetTempIndex($id)
Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
$hGUI = GUICreate(Msg($mHeadlines[4], "USB-Backup", $aCurrentSticks[$id][$eFullDrive]), 800, 400, -1, -1, $gGuiStyle, $gGuiExStyle)
SetupHelp("usage-ManageBackups.html")
Local $lHeadline = GUICtrlCreateLabel(Msg($mLabels[43]), 8, 8, 458, 24)
GUICtrlSetFont(-1, 10)
GUICtrlCreateGroup(Msg($mLabels[44], $sDrive), 8, 32, 481, 361)
Local $iStyle = BitOR(0x00000001, 0x00000002, 0x00000004, 0x00000010, 0x00000020)
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
Dim $aBackups[1][9] = [[0, 0, 0, 0, 0, 0, 0, 0, 0]]
Dim $aBackupTodo[1][7] = [[0, 0, 0, 0, 0, 0, 0]]
Dim $aOldPaths[1]
GetOLDFilePaths($sIndexTemp, $aOldPaths)
ManageBackups_TV($id, $tv, $aFilePaths, $aBackups, $aBackupTodo)
ManageBackups_TV($id, $tv, $aOldPaths, $aBackups, $aBackupTodo, 0x888888)
GUICtrlSendMsg($btnOverview, $BM_CLICK, 0, 0)
GUICtrlSetState($btnStart, 256)
Dim $aGuiIDs[1]
While 1
Local $msg = GUIGetMsg()
Switch $msg
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
Case $GUI_EVENT_CLOSE, $btnCancel
ExitLoop
Case Else
Local $tvid = GUICtrlRead($tv)
Switch ManageBackups_Info($id, $msg, $tvid, $tv, $aBackups, $aBackupTodo, $aGuiIDs)
Case 1
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
EndFunc
Func _GUICtrlCreateLabel($sText, $iLeft, $iTop, $iWidth = 50, $iHeight = 17)
Return _GUICtrlFFLabel_Create($hGUI, $sText, $iLeft, $iTop, $iWidth, $iHeight, 8.5, 'Microsoft Sans Serif')
EndFunc
Func _GUICtrlSetData($iIndex, $sText, $iColor = -1)
If $iColor = -1 Then
Return _GUICtrlFFLabel_SetData($iIndex, $sText)
Else
Return _GUICtrlFFLabel_SetData($iIndex, $sText, $iColor)
EndIf
EndFunc
Func DirName($sPath)
Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
_PathSplit($sPath, $sDrive, $sDir, $sFileName, $sExtension)
Return $sDrive & $sDir
EndFunc
Func BaseName($sPath)
Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
_PathSplit($sPath, $sDrive, $sDir, $sFileName, $sExtension)
Return $sFileName
EndFunc
Func CreateNewBackup_SetStatus($id, $v)
Switch $v
Case "7z:end"
GUICtrlSetColor($id, 0x005500)
GUICtrlSetData($id, Msg($mTaskStatus[1]))
Case "7z:cancel"
GUICtrlSetColor($id, 0xaa0000)
GUICtrlSetData($id, Msg($mTaskStatus[2]))
Case "7z:error"
GUICtrlSetColor($id, 0xaa0000)
GUICtrlSetData($id, Msg($mTaskStatus[3]))
Case "7z:scan"
GUICtrlSetColor($id, 0x0000aa)
GUICtrlSetData($id, Msg($mTaskStatus[4]))
Case "7z:zip"
GUICtrlSetColor($id, 0x0000aa)
GUICtrlSetData($id, Msg($mTaskStatus[5]))
EndSwitch
EndFunc
Func _GetTabColor($Tab)
Local $aPosWin = WinGetPos($hGUI)
Local $aPosCtrl = ControlGetPos($hGUI, "", $Tab)
Local $iColor = Hex(PixelGetColor($aPosWin[0] + $aPosCtrl[0] + $aPosCtrl[2] - 2, $aPosWin[1] + $aPosCtrl[1] + $aPosCtrl[3] - 2, ControlGetHandle($hGUI, "", $Tab)), 6)
Return $iColor
EndFunc
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
Local $sFile = $sTempPath & "PowerOnWayne.cmd"
FileDelete($sFile)
FileWrite($sFile, $sText)
$iPowerPlanPid = ShellExecute($sFile, "", "", "", $sDebugPowerPlan = "0" ? @SW_HIDE : @SW_SHOW)
EndFunc
Func ResetPowerPlan()
Local $sFile = $sTempPath & "PowerOnWayne.cmd.finished"
While ProcessExists($iPowerPlanPid)
FileWrite($sFile, $iPowerPlanPid)
Sleep(500)
WEnd
FileDelete($sFile)
EndFunc
Func CreateNewBackup($id, $aBackupTodo)
Local $sDrive = $aCurrentSticks[$id][$eFullDrive]
Local $tsBegin = GetTimeStamp()
Local $aDrivesWithVSS
Local $iStatusLabel
Local $sStatusText
$hGUI = GUICreate(Msg($mHeadlines[5], "USB-Backup"), 800, 400, -1, -1, $gGuiStyle)
SetupHelp("usage-BackupStatus.html")
If $sRunBeforeCmd <> "" Then RunWait($sRunBeforeCmd)
If $sEnableVSS = "1" Or $sUsePowerPlan = "1" Then
GUISetState(@SW_SHOW, $hGUI)
$sStatusText = Msg($mLabels[51])
$iStatusLabel = _GUICtrlFFLabel_Create($hGUI, $sStatusText, 8, 8, 800 - 16, 400 - 16, 9, "Lucida Console")
EndIf
If $sUsePowerPlan = "1" Then
CreatePowerPlan()
$sStatusText &= @CRLF & Msg($mLabels[52])
_GUICtrlSetData($iStatusLabel, $sStatusText)
EndIf
If $sEnableVSS = "1" Then
$aDrivesWithVSS = CreateVSSDevices($id, $aBackupTodo, $iStatusLabel, $sStatusText)
If Not IsArray($aDrivesWithVSS) Then
GUIDelete($hGUI)
TrayTip("USB-Backup", Msg($mMessages[7]), $iTrayTipTime, 1)
If $sUsePowerPlan = "1" Then ResetPowerPlan()
$iRunningBackup = 0
EnableTrayMenu()
Return
EndIf
Else
FileChangeDir($sTempPath)
DoBackup_PrepareExefiles($sTempPath)
$aDrivesWithVSS = 0
EndIf
If $sEnableVSS = "1" Or $sUsePowerPlan = "1" Then
_GUICtrlFFLabel_Delete($iStatusLabel)
EndIf
$iRunningBackup = $hGUI
EnableTrayMenu()
SetupHelp("usage-BackupStatus.html")
Dim $aGid[$aBackupTodo[0][0] + 1][14]
Dim $aHwnd[$aBackupTodo[0][0] + 1][14]
Dim $aLast[$aBackupTodo[0][0] + 1][14]
Dim $aReal[18]
Dim $aButtons[$aBackupTodo[0][0] + 1][4]
Local $iTaskGroup = GUICtrlCreateGroup("", 8, 4, 785, 230, -1, 0x00000020)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup(Msg($mLabels[45], $sDrive), 8, 240, 297, 153)
DrawSpaceUsageStatus($sDrive, 0)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $xw = 188
$aReal[1] = _GUICtrlCreateLabel("", 28 + $xw * 0, 46, 180, 17)
$aReal[2] = _GUICtrlCreateLabel("", 28 + $xw * 1, 46, 180, 17)
$aReal[3] = GUICtrlCreateLabel("", 585, 192, 190, 26)
GUICtrlSetFont($aReal[3], 11)
$aReal[4] = _GUICtrlCreateLabel("", 28, 56 + 15, 744, 17)
$aReal[5] = GUICtrlCreateProgress(28, 74 + 15, 700, 19)
$aReal[6] = _GUICtrlCreateLabel("", 701 + 28, 76 + 15, 43, 17)
$aReal[7] = _GUICtrlCreateLabel("", 28, 115, 744, 17)
$aReal[8] = GUICtrlCreateProgress(28, 133, 700, 19)
$aReal[9] = _GUICtrlCreateLabel("", 701 + 28, 135, 43, 17)
$aReal[10] = _GUICtrlCreateLabel("", 28 + $xw * 2, 46, 155, 17)
$aReal[11] = _GUICtrlCreateLabel("", 8 + $xw * 3, 46, 199, 17)
$aReal[12] = _GUICtrlCreateLabel("", 28, 154, 740, 33)
Local $Tab = GUICtrlCreateTab(16, 16, 770, 209, 0x00000008)
For $i = 1 To $aBackupTodo[0][0]
$aGid[$i][0] = GUICtrlCreateTabItem($aBackupTodo[$i][4])
Local $iStyle = BitOR(0, 0)
Local $iStyle2 = BitOR(0, 0)
$aButtons[$i][0] = GUICtrlCreateButton(Msg($mButtons[13]), 28, 190, 131, 25, $iStyle, $iStyle2)
$aButtons[$i][1] = GUICtrlCreateButton(Msg($mButtons[15]), 164, 190, 131, 25, $iStyle, $iStyle2)
$aButtons[$i][2] = GUICtrlCreateButton(Msg($mButtons[16]), 300, 190, 131, 25, $iStyle, $iStyle2)
For $j = 1 To 13
$aGid[$i][$j] = GUICtrlCreateLabel("", -10, -10, 1, 1)
$aHwnd[$i][$j] = GUICtrlGetHandle($aGid[$i][$j])
GUICtrlSetState($aGid[$i][$j], 32)
$aLast[$i][$j] = ""
Next
GUICtrlSetData($aGid[$i][2], "00:00:00")
Next
GUICtrlCreateTabItem("")
GUICtrlCreateGroup("", -99, -99, 1, 1)
_GUICtrlTab_ActivateTab($Tab, 0)
GUICtrlCreateGroup(Msg($mLabels[40]), 312, 240, 481, 153, -1, 0x00000020)
Local $btnCancel = GUICtrlCreateButton(Msg($mButtons[2]), 688, 360, 99, 25)
Local $btnToTray = GUICtrlCreateButton(Msg($mButtons[11]), 584, 360, 99, 25)
$aReal[13] = _GUICtrlCreateLabel("", 321, 264, 180, 17)
$aReal[17] = _GUICtrlCreateLabel("", 321, 360 + 4, 180, 17)
$aReal[14] = _GUICtrlCreateLabel("", 8 + $xw * 3, 264, 199, 17)
$aReal[15] = GUICtrlCreateProgress(321, 321, 464, 27)
$aReal[16] = _GUICtrlCreateLabel("", 321, 300, 464, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW, $hGUI)
Local $iColor = _GetTabColor($Tab)
GUICtrlSetBkColor($aReal[3], Dec($iColor))
$iColor = "0xff" & $iColor
Local $aSevenZip = StartSevenZip($id, $aBackupTodo, $aDrivesWithVSS, $aHwnd)
Local $iActiveTab = 1
Local $iNeedRedraw = 0
Local $tsLastOne = 0
_GUICtrlTab_ActivateTab($Tab, 0)
While 1
Local $iFound = 0
For $i = 1 To $aSevenZip[0][0]
If $aSevenZip[$i][0] = 0 Then ContinueLoop
If Not ProcessExists($aSevenZip[$i][0]) Then
StopSevenZipProcess($aBackupTodo, $aSevenZip, $i)
GUICtrlSetData($aGid[$i][3], "7z:cancel")
$iNeedRedraw = 1
ContinueLoop
EndIf
$iFound += 1
Next
If $iFound = 0 Then ExitLoop
For $i = 1 To $aBackupTodo[0][0]
Local $v
$v = GUICtrlRead($aGid[$i][3])
If $v = "7z:end" And ProcessExists($aSevenZip[$i][0]) Then
$aLast[$i][2] = "00:00:00"
GUICtrlSetData($aGid[$i][2], $aLast[$i][2])
$aLast[$i][5] = GUICtrlRead($aGid[$i][4])
GUICtrlSetData($aGid[$i][5], $aLast[$i][5])
$aLast[$i][8] = GUICtrlRead($aGid[$i][7])
GUICtrlSetData($aGid[$i][8], $aLast[$i][8])
$aLast[$i][10] = 0
GUICtrlSetData($aGid[$i][10], $aLast[$i][10])
$aLast[$i][11] = ""
GUICtrlSetData($aGid[$i][11], $aLast[$i][11])
If $v = "7z:end" And ProcessExists($aSevenZip[$i][0]) Then
While 1
ClickSevenZip($aSevenZip[$i][1], "Button3")
Sleep(200)
If Not ProcessExists($aSevenZip[$i][0]) Then ExitLoop
WEnd
FinishSevenZip($id, $aBackupTodo, $aSevenZip, $i)
EndIf
GUICtrlSetState($aButtons[$i][0], 128)
GUICtrlSetState($aButtons[$i][1], 128)
GUICtrlSetState($aButtons[$i][2], 128)
$aLast[$i][3] = $v
$iNeedRedraw = 1
CreateNewBackup_SetStatus($aReal[3], $aLast[$iActiveTab][3])
EndIf
If $aLast[$i][3] <> $v Then
CreateNewBackup_SetStatus($aReal[3], $aLast[$iActiveTab][3])
$iNeedRedraw = 1
EndIf
For $j = 1 To 12
$v = GUICtrlRead($aGid[$i][$j])
If Not($v = $aLast[$i][$j]) Then
$aLast[$i][$j] = $v
If $iActiveTab = $i Then $iNeedRedraw = 1
EndIf
Next
$v = GUICtrlRead($aGid[$i][13])
If Not($v = $aLast[$i][13]) Then
$aLast[$i][$j] = $v
Local $sErrorLog
If $aBackupTodo[$i][0] = "a" Then
Local $s = StringTrimRight($aBackupTodo[$i][5], 3)
$sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
Else
Local $s = StringTrimRight($aBackupTodo[$i][6], 3)
$sErrorLog = $sAppPath & "Logfiles" & StringRight($s, 2 * $sFileNameLen + 2) & ".log"
EndIf
DirCreate(DirName($sErrorLog))
FileDelete($sErrorLog)
FileWrite($sErrorLog, GUICtrlRead($aGid[$i][13]))
EndIf
Next
If $iNeedRedraw = 1 Then
Local $i = $iActiveTab
Local $v
Local $iTotal, $iProcessed, $iPacked, $iPercent, $iRatio, $iSpeed
_GUICtrlSetData($aReal[1], Msg($mLabels[53], $aLast[$i][1]), $iColor)
If $aLast[$i][2] = "00:00:00" Then
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
$iTotal = $aLast[$i][7]
$iProcessed = $aLast[$i][8]
$iPercent = $iTotal <> 0 ? Int(($iProcessed * 100) / $iTotal) : 0
_GUICtrlSetData($aReal[7], Msg($mLabels[57]) & " " & $iProcessed & " / " & $iTotal, $iColor)
GUICtrlSetData($aReal[8], $iPercent)
_GUICtrlSetData($aReal[9], $iPercent & "%", $iColor)
If $aLast[$i][10] = 0 Then
_GUICtrlSetData($aReal[11], "", $iColor)
Else
_GUICtrlSetData($aReal[11], Msg($mLabels[58]) & " " & _WinAPI_StrFormatByteSize($aLast[$i][10]) & "/s", $iColor)
EndIf
_GUICtrlSetData($aReal[12], $aLast[$i][11], $iColor)
If $aLast[$i][12] = 0 Then
_GUICtrlSetData($aReal[10], "", $iColor)
Else
_GUICtrlSetData($aReal[10], Msg($mLabels[59]) & " " & $aLast[$i][12], $iColor)
EndIf
$iNeedRedraw = 0
EndIf
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
TraySetToolTip(Msg($mLabels[60], "USB-Backup", GetBackupTime($iCurrentRemainingTime)))
EndIf
Local $msg = GUIGetMsg()
Switch $msg
Case 0, $GUI_EVENT_MOUSEMOVE
Case $Tab
$iActiveTab = GUICtrlRead($Tab) + 1
CreateNewBackup_SetStatus($aReal[3], $aLast[$iActiveTab][3])
$iNeedRedraw = 1
Case $btnCancel
If MsgBox(4, "USB-Backup", Msg($mMessages[8])) = 6 Then
StopSevenZip($aBackupTodo, $aSevenZip, $aDrivesWithVSS)
ExitLoop
EndIf
Case $btnToTray, $GUI_EVENT_CLOSE
$iRunningBackup = $hGUI
EnableTrayMenu()
GUISetState(@SW_HIDE, $hGUI)
Case $aButtons[$iActiveTab][0]
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
$aLast[$i][10] = 0
GUICtrlSetData($aGid[$i][10], $aLast[$i][10])
Case $aButtons[$iActiveTab][2]
Local $i = $iActiveTab
If $aSevenZip[$i][0] = 0 Then ContinueLoop
If MsgBox(4, "USB-Backup", Msg($mMessages[9])) = 6 Then
GUICtrlSetState($aButtons[$i][0], 128)
GUICtrlSetState($aButtons[$i][1], 128)
GUICtrlSetState($aButtons[$i][2], 128)
While ProcessExists($aSevenZip[$i][0])
ProcessClose($aSevenZip[$i][0])
Sleep(300)
WEnd
ContinueLoop
EndIf
EndSwitch
Switch TrayGetMsg()
Case $iExit
If MsgBox(4, "USB-Backup", Msg($mMessages[8])) = 6 Then
StopSevenZip($aBackupTodo, $aSevenZip, $aDrivesWithVSS)
ExitLoop
EndIf
Case $iStatus
GUISetState(@SW_SHOW, $iRunningBackup)
SetupHelp("usage-BackupStatus.html")
$iNeedRedraw = 1
ContinueLoop
EndSwitch
WEnd
StopVSSDevices($aDrivesWithVSS)
$iRunningBackup = 0
EnableTrayMenu()
GUIDelete($hGUI)
If $sUsePowerPlan = "1" Then ResetPowerPlan()
Local $iOkay = 0, $iCancel = 0
For $i = 1 To $aSevenZip[0][0]
If $aSevenZip[$i][3] = "okay" Then $iOkay += 1
If $aSevenZip[$i][3] = "cancel" Then $iCancel += 1
Next
If $sShowStatusMessage = "1" Then
If $iCancel = 0 Then
MsgBox(BitOR(0, 64), "USB-Backup", Msg($mMessages[11]))
ElseIf $iOkay > 0 Then
MsgBox(BitOR(0, 48), "USB-Backup", Msg($mMessages[12]))
Else
MsgBox(BitOR(0, 48), "USB-Backup", Msg($mMessages[7]))
EndIf
Else
If $iCancel = 0 Then
TrayTip("USB-Backup", Msg($mMessages[11]), $iTrayTipTime, 1)
ElseIf $iOkay > 0 Then
TrayTip("USB-Backup", Msg($mMessages[12]), $iTrayTipTime, 1)
Else
TrayTip("USB-Backup", Msg($mMessages[7]), $iTrayTipTime, 1)
EndIf
EndIf
TraySetToolTip("USB-Backup")
FileDeleteSave($id)
RunWait(@ComSpec & " /c sync.exe", "", @SW_HIDE)
If $sRunAfterCmd <> "" Then RunWait($sRunAfterCmd)
Return
EndFunc
Func CreateVSSDevices($id, $aBackupTodo, $iStatusLabel, $sStatusText)
Local $sIndexTemp = GetTempIndex($id)
FileChangeDir($sTempPath)
RunWait(@ComSpec & " /c sync.exe", "", @SW_HIDE)
_GUICtrlSetData($iStatusLabel, $sStatusText)
DoBackup_PrepareExefiles($sTempPath)
Dim $aTheDrives[1]
For $i = 1 To $aBackupTodo[0][0]
If StringLeft($aBackupTodo[$i][4], 2) = "\\" Then ContinueLoop
If StringMid($aBackupTodo[$i][4], 2, 2) <> ":\" Then ContinueLoop
_ArrayAdd($aTheDrives, StringLeft($aBackupTodo[$i][4], 2))
Next
$aTheDrives[0] = UBound($aTheDrives) - 1
Local $aDrivesWithVSS = FindVSSDrivesForBackup($aTheDrives)
If Not IsArray($aDrivesWithVSS) Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[11]))
Return 0
EndIf
If $aDrivesWithVSS[0][0] = 0 Then Return $aDrivesWithVSS
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
Local $sAdminUser = IniRead($sIndexTemp, "USB-Backup", "AdminUser", "")
Local $sAdminPass = IniRead($sIndexTemp, "USB-Backup", "AdminPass", "")
Local $sShadow = ""
While 1
If $sAdminUser = "" Then
$sAdminUser = MyInputBox("USB-Backup", "usage-VSSAdmin.html", Msg($mLabels[62]), "Administrator")
If $sAdminUser = "" Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[12]))
Return 0
EndIf
$sAdminPass = MyInputBox("USB-Backup", "usage-VSSAdmin.html", Msg($mLabels[63], $sAdminUser), "", 32)
EndIf
$aDrivesWithVSS[$i][2] = RunAs($sAdminUser, @ComputerName, $sAdminPass, 0, $sFile, $sTempPath, $iShowFlag)
If $aDrivesWithVSS[$i][2] = 0 Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[13]))
$sAdminUser = ""
ContinueLoop
EndIf
Local $iStatusChar = 1
While ProcessExists($aDrivesWithVSS[$i][2])
Local $sFullTitle1 = WinGetTitle("[REGEXPTITLE:" & $sTitleOK & "\\]")
Local $iStart1 = StringInStr($sFullTitle1, $sTitleOK)
Local $sFullTitle2 = WinGetTitle("[REGEXPTITLE:" & $sTitleERR & "]")
Local $iStart2 = StringInStr($sFullTitle2, $sTitleERR)
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
If $iStart2 <> 0 Then
FileWrite($sFile & ".finished", "...")
$sShadow = ""
ExitLoop
EndIf
$sShadow = StringMid($sFullTitle1, $iStart1 + StringLen($sTitleOK))
$aDrivesWithVSS[$i][3] = WinGetHandle("[REGEXPTITLE:" & $sTitleOK & "\\]")
ExitLoop
WEnd
If $sShadow = "" Then
MsgBox(0, "USB-Backup", Msg($mErrorMessages[14], $sDrive))
$sAdminUser = ""
ContinueLoop
EndIf
ExitLoop
WEnd
IniWrite($sIndexTemp, "USB-Backup", "AdminUser", $sAdminUser)
IniWrite($sIndexTemp, "USB-Backup", "AdminPass", $sAdminPass)
UpdateIndexFile($id)
If _WinAPI_DefineDosDevice($aDrivesWithVSS[$i][1], 0, $sShadow) <> True Then
FatalError(Msg($mFatalErrors[6], $sShadow, $aDrivesWithVSS[$i][1]))
EndIf
Sleep(1000)
Next
Return $aDrivesWithVSS
EndFunc
Func StopVSSDevices($aDrivesWithVSS)
If Not IsArray($aDrivesWithVSS) Then Return
For $i = 1 To $aDrivesWithVSS[0][0]
_WinAPI_DefineDosDevice($aDrivesWithVSS[$i][1], 0x02)
Local $sEndFile = $sTempPath & "vscsc-" & StringLeft($aDrivesWithVSS[$i][0], 1) & ".cmd.finished"
While ProcessExists($aDrivesWithVSS[$i][2])
FileWrite($sEndFile, "nö")
Sleep(500)
WEnd
FileDelete($sEndFile)
Next
EndFunc
Func ClickSevenZip($hWindow, $btn)
Local $lParam
Switch $btn
Case "Button1"
$lParam = 444
Case "Button2"
$lParam = 446
Case "Button3"
$lParam = 2
EndSwitch
_WinAPI_PostMessage($hWindow, 0x111, $lParam, 0)
EndFunc
Func StartSevenZip($id, $aBackupTodo, $aDrivesWithVSS, $aHwnd)
Local $sPassword = $aCurrentSticks[$id][$ePassword]
Dim $aSevenZip[$aBackupTodo[0][0] + 1][4]
$aSevenZip[0][0] = $aBackupTodo[0][0]
For $i = 1 To $aBackupTodo[0][0]
Local $sZipTitle = "SevenZIP-" & _WinAPI_CreateGUID()
Local $sSevenZipCmd = ""
Local $sPath = $aBackupTodo[$i][4]
Local $sArchiv = $aBackupTodo[$i][5]
Local $sPathReal = $sPath
Local $sOptions = ' -title"' & $sZipTitle & '"'
$sOptions &= ' -xr!"*\USB-Backup-*" '
Local $sPathPrefix = DirName($sPath)
Local $sExcludeFile = GetExcludeFile_X($sAppPath, $sPath)
If FileExists($sExcludeFile) Then
Local $sText = FileReadToArray($sExcludeFile)
Local $aExcludeFile[0]
For $j = 0 To UBound($sText) - 1
If StringLen($sText[$j]) = 0 Then ContinueLoop
If StringLeft($sText[$j], 1) = "#" Then ContinueLoop
If(StringLen($sText[$j]) = 11) And($sText[$j] = "[Junctions]") Then
Local $sJunctions = ""
FindJunctions($sPath, $sJunctions)
If StringLen($sJunctions) = 0 Then ContinueLoop
$sJunctions = StringTrimRight($sJunctions, 1)
_ArrayAdd($aExcludeFile, $sJunctions)
ContinueLoop
EndIf
_ArrayAdd($aExcludeFile, $sText[$j])
Next
$sExcludeFile = GetExcludeFile_X($sTempPath, $sPath)
FileDelete($sExcludeFile)
For $j = 0 To UBound($aExcludeFile) - 1
FileWriteLine($sExcludeFile, StringReplace($aExcludeFile[$j], $sPathPrefix, "", 1))
Next
If FileExists($sExcludeFile) Then
$sOptions &= ' -x@"' & $sExcludeFile & '"'
EndIf
EndIf
$sExcludeFile = GetExcludeFile_XR($sAppPath, $sPath)
If FileExists($sExcludeFile) Then
Local $sText = FileReadToArray($sExcludeFile)
Local $aExcludeFile[0]
For $j = 0 To UBound($sText) - 1
If StringLen($sText[$j]) = 0 Then ContinueLoop
If StringLeft($sText[$j], 1) = "#" Then ContinueLoop
If(StringLen($sText[$j]) = 11) And($sText[$j] = "[Junctions]") Then
Local $sJunctions = ""
FindJunctions($sPath, $sJunctions)
If StringLen($sJunctions) = 0 Then ContinueLoop
$sJunctions = StringTrimRight($sJunctions, 1)
_ArrayAdd($aExcludeFile, $sJunctions)
ContinueLoop
EndIf
_ArrayAdd($aExcludeFile, $sText[$j])
Next
$sExcludeFile = GetExcludeFile_XR($sTempPath, $sPath)
FileDelete($sExcludeFile)
For $j = 0 To UBound($aExcludeFile) - 1
FileWriteLine($sExcludeFile, StringReplace($aExcludeFile[$j], $sPathPrefix, "", 1))
Next
If FileExists($sExcludeFile) Then
$sOptions &= ' -xr@"' & $sExcludeFile & '"'
EndIf
EndIf
For $j = 1 To 13
$sOptions &= " -ctl" & $j & "=" & Int($aHwnd[$i][$j])
Next
If $sEnableVSS = "1" Then
For $j = 1 To $aDrivesWithVSS[0][0]
If StringLeft($sPath, 1) = StringLeft($aDrivesWithVSS[$j][0], 1) Then
$sPathReal = StringLeft($aDrivesWithVSS[$j][1], 1)
$sPathReal &= StringMid($sPath, 2)
EndIf
Next
EndIf
Local $sSevenZipExe
If $aBackupTodo[$i][0] = "a" Then
DirCreate(StringMid($sArchiv, 1, StringLen($sArchiv) - $sFileNameLen - 4))
Local $a = StringSplit($s7ZipCreateCmd, " ")
$sSevenZipExe = $a[1]
$sSevenZipCmd = StringReplace($s7ZipCreateCmd, "%A", $sArchiv, 1, 1)
$sSevenZipCmd = StringReplace($sSevenZipCmd, "%o", $sOptions, 1, 1)
$sSevenZipCmd = StringReplace($sSevenZipCmd, "%P", $sPassword, 1, 1)
$sSevenZipCmd = StringReplace($sSevenZipCmd, "%p", $sPathReal, 1, 1)
ElseIf $aBackupTodo[$i][0] = "u" Then
Local $sUpdate = $aBackupTodo[$i][6]
Local $a = StringSplit($s7ZipUpdateCmd, " ")
$sSevenZipExe = $a[1]
$sSevenZipCmd = StringReplace($s7ZipUpdateCmd, "%A", $sArchiv, 1, 1)
$sSevenZipCmd = StringReplace($sSevenZipCmd, "%o", $sOptions, 1, 1)
$sSevenZipCmd = StringReplace($sSevenZipCmd, "%U", $sUpdate, 1, 1)
$sSevenZipCmd = StringReplace($sSevenZipCmd, "%P", $sPassword, 1, 1)
$sSevenZipCmd = StringReplace($sSevenZipCmd, "%p", $sPathReal, 1, 1)
EndIf
Local $sParameter = StringMid($sSevenZipCmd, StringLen($sSevenZipExe) + 1)
Local $iShowFlag = $sDebug7ZipCmd <> 0 ? @SW_SHOW : @SW_HIDE
$aSevenZip[$i][0] = ShellExecute($sTempPath & $sSevenZipExe, $sParameter, $sTempPath, "", $iShowFlag)
If $aSevenZip[$i][0] = -1 Then FatalError(Msg($mFatalErrors[7]))
While 1
$aSevenZip[$i][1] = WinWait($sZipTitle, "", 99)
WinActivate($hGUI)
If $aSevenZip[$i][1] <> 0 Then ExitLoop
FatalError(Msg($mFatalErrors[8]))
WEnd
$aSevenZip[$i][2] = $sZipTitle
If $s7ZipPriority = "idle" Then
ClickSevenZip($aSevenZip[$i][1], "Button1")
EndIf
WinMove($aSevenZip[$i][1], "", -1, -1, 800)
Next
Return $aSevenZip
EndFunc
Func FinishSevenZip($id, $aBackupTodo, ByRef $aSevenZip, $i)
Local $sIndexTemp = GetTempIndex($id)
Local $sKey = $aBackupTodo[$i][2]
Local $sTimeStamp = $aBackupTodo[$i][3]
Local $sPath = $aBackupTodo[$i][4]
Local $sArchiv = $aBackupTodo[$i][5]
Local $sRuntime = GetTimeStamp() - $sTimeStamp
If $aBackupTodo[$i][0] = "a" Then
Local $sBytes = FileGetSize($sArchiv)
IniWrite($sIndexTemp, $sPath, $sKey, $sTimeStamp & ":" & $sRuntime & ":" & $sBytes)
IniWrite($sIndexTemp, $sPath, "fts", $sTimeStamp)
ElseIf $aBackupTodo[$i][0] = "u" Then
Local $sUpdate = $aBackupTodo[$i][6]
Local $sBytes = FileGetSize($sUpdate)
Local $sOldEntry = IniRead($sIndexTemp, $sPath, $sKey, "")
IniWrite($sIndexTemp, $sPath, $sKey, $sOldEntry & ";" & $sTimeStamp & ":" & $sRuntime & ":" & $sBytes)
EndIf
$aSevenZip[$i][0] = 0
$aSevenZip[$i][3] = "okay"
For $i = 1 To $aFilePaths[0]
If $sPath = $aFilePaths[$i] Then
$aFilePathsTS[$i] = $sTimeStamp
WriteConfiguration()
ExitLoop
EndIf
Next
If $aBackupTodo[$i][0] = "a" And $sMaxFullBackups <> 0 Then
Local $aTemp = IniReadSection($sIndexTemp, $sPath)
Local $iFullBackups = $aTemp[0][0] - 2
If $iFullBackups > $sMaxFullBackups Then
Local $aTodo[0]
For $i = 1 To $aTemp[0][0]
If $aTemp[$i][0] = "cts" Then ContinueLoop
If $aTemp[$i][0] = "fts" Then ContinueLoop
If StringLeft($aTemp[$i][0], 1) <> "f" Then FatalError(Msg($mFatalErrors[9]))
_ArrayAdd($aTodo, StringTrimLeft($aTemp[$i][0], 1))
Next
_ArraySort($aTodo, 1)
_ArrayDelete($aTodo, "0-" & $sMaxFullBackups - 1)
For $i = 0 To UBound($aTodo) - 1
Local $sDir = $aCurrentSticks[$id][$eBackupPath] & MyMiniHash($sPath) & "\" & MyMiniHash($sPath & $aTodo[$i])
DirRemove($sDir, 1)
IniDelete($sIndexTemp, $sPath, "f" & $aTodo[$i])
$sDir = $sAppPath & "Logfiles\" & MyMiniHash($sPath & $aTodo[$i])
If FileExists($sDir) Then DirRemove($sDir, 1)
Next
EndIf
EndIf
UpdateIndexFile($id)
EndFunc
Func StopSevenZipProcess($aBackupTodo, ByRef $aSevenZip, $i)
While ProcessExists($aSevenZip[$i][0])
ProcessClose($aSevenZip[$i][0])
Sleep(400)
WEnd
$aSevenZip[$i][0] = 0
$aSevenZip[$i][3] = "cancel"
If $aBackupTodo[$i][0] = "a" Then
FileDelete($aBackupTodo[$i][5])
DirRemove(DirName($aBackupTodo[$i][5]))
ElseIf $aBackupTodo[$i][0] = "u" Then
FileDelete($aBackupTodo[$i][6])
EndIf
EndFunc
Func StopSevenZip($aBackupTodo, ByRef $aSevenZip, $aDrivesWithVSS)
For $i = 1 To $aSevenZip[0][0]
If $aSevenZip[$i][0] = 0 Then ContinueLoop
StopSevenZipProcess($aBackupTodo, $aSevenZip, $i)
Next
StopVSSDevices($aDrivesWithVSS)
EndFunc
Func GetProcessorInfo()
Local $sDefault = "Unknown CPU, 1"
Local $objWMIService = GetWMIServiceObject()
If $objWMIService = 0 Then Return $sDefault
Local $colItems = $objWMIService.ExecQuery("SELECT Name,NumberOfLogicalProcessors FROM Win32_Processor")
If Not IsObj($colItems) Then Return $sDefault
Local $objItem
For $objItem In $colItems
Local $s = StringStripWS($objItem.Name, 1)
$s = StringReplace($s, ";", "")
Return $s & "; " & $objItem.NumberOfLogicalProcessors
Next
EndFunc
Func CheckVersions($iCurrent, $iInternet)
Local $aCurrent = StringSplit($iCurrent, ".")
Local $aInternet = StringSplit($iInternet, ".")
If String($iCurrent) = "0.0.0.0" Then Return 0
If $iCurrent = $iInternet Then Return 0
If $aCurrent[0] <> 4 Or $aInternet[0] <> 4 Then Return 0
For $i = 1 To 4
If Int($aInternet[$i]) = Int($aCurrent[$i]) Then ContinueLoop
If Int($aInternet[$i]) > Int($aCurrent[$i]) Then
Return 1
EndIf
If Int($aInternet[$i]) < Int($aCurrent[$i]) Then
Return 0
EndIf
Next
Return 0
EndFunc
Func CheckForUpdate()
If $sCheckForUpdate = "0" Then Return
If Ping("mcmilk.de", 300) = 0 Then Return
HttpSetUserAgent("USB-Backup" & "/" & $sUpdateAppVersion & " (" & @UserName & "; " & @ComputerName & "; " & @OSLang & "; " & @OSVersion & "; " & @OSArch & "; " & GetProcessorInfo() & ")")
Local $sInetVersion = BinaryToString(InetRead($sUpdateURL & "version.txt", 1 + 16))
If @error <> 0 Then Return
$aInetVersion = StringSplit($sInetVersion, ",")
If $aInetVersion[0] <> 2 Then Return
$aInetVersion[2] = Int($aInetVersion[2])
$iHasNewUpdate = 0
$iHasNewUpdate += CheckVersions($sUpdateAppVersion, $aInetVersion[1])
If $sChmVersion < $aInetVersion[2] Then
$iHasNewUpdate += 2
EndIf
Local $sText
Switch $iHasNewUpdate
Case 1
$sText = Msg($mMessages[15]) & @CRLF & @CRLF & Msg($mMessages[10])
If MsgBox(4, "USB-Backup", $sText) = 6 Then DownloadUpdates()
Case 2
$sText = Msg($mMessages[16]) & @CRLF & @CRLF & Msg($mMessages[10])
If MsgBox(4, "USB-Backup", $sText) = 6 Then DownloadUpdates()
Case 3
$sText = Msg($mMessages[17]) & @CRLF & @CRLF & Msg($mMessages[10])
If MsgBox(4, "USB-Backup", $sText) = 6 Then DownloadUpdates()
EndSwitch
EndFunc
Func NewVersionHint()
Local $sText = ""
Switch $iHasNewUpdate
Case 1
$sText = Msg($mMessages[15])
TrayTip("USB-Backup" & " " & "0.5", $sText, $iTrayTipTime, 2)
Case 2
$sText = Msg($mMessages[16])
TrayTip("USB-Backup" & " " & "0.5", $sText, $iTrayTipTime, 1)
Case 3
$sText = Msg($mMessages[17])
TrayTip("USB-Backup" & " " & "0.5", $sText, $iTrayTipTime, 2)
EndSwitch
EndFunc
Func DownloadUpdates()
Local $sFilePath, $iStatus = 0
If BitAND($iHasNewUpdate, 2) Then
$sFilePath = $sTempPath & "USB-Backup" & ".chm"
FileDelete($sFilePath)
$iStatus = DownloadFile($sUpdateURL & "USB-Backup" & ".chm", $sFilePath, Msg($mLabels[64]))
If $iStatus = 0 Then
FileDelete($sAppHelp)
FileMove($sFilePath, $sAppHelp)
TrayTip("USB-Backup" & " " & "0.5", Msg($mMessages[18]), $iTrayTipTime, 1)
EndIf
EndIf
If BitAND($iHasNewUpdate, 1) Then
If @AutoItX64 Then
$sFilePath = $sTempPath & "USB-Backup" & "_x64.exe"
FileDelete($sFilePath)
$iStatus = DownloadFile($sUpdateURL & "USB-Backup" & "_x64.exe", $sFilePath, Msg($mLabels[65]))
Else
$sFilePath = $sTempPath & "USB-Backup" & ".exe"
FileDelete($sFilePath)
$iStatus = DownloadFile($sUpdateURL & "USB-Backup" & ".exe", $sFilePath, Msg($mLabels[65]))
EndIf
If $iStatus = 0 Then
FileMove(@ScriptFullPath, $sFilePath & ".old", 1)
While 1
Local $i = FileMove($sFilePath, @ScriptFullPath, 1)
If $i = 1 Then ExitLoop
Sleep(100)
WEnd
TrayTip("USB-Backup" & " " & "0.5", Msg($mMessages[19]), $iTrayTipTime, 1)
Sleep(1000)
FileDelete($sTempPath & "USB-Backup" & ".cmd")
Local $sBatch = "ping -n 5 127.0.0.1 > NUL" & @CRLF
$sBatch &= 'start /D "' & DirName(@ScriptFullPath) & '" ' & BaseName(@ScriptFullPath)
FileWrite($sTempPath & "USB-Backup" & ".cmd", $sBatch)
Run($sTempPath & "USB-Backup" & ".cmd", "", @SW_HIDE)
Exit
EndIf
EndIf
If $iStatus <> 0 Then
TrayTip("USB-Backup" & " " & "0.5", Msg($mMessages[20]), $iTrayTipTime, 2)
Return
EndIf
$iHasNewUpdate = 0
$sChmVersion = $aInetVersion[2]
WriteConfiguration()
EndFunc
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
TrayTip("USB-Backup" & " " & "0.5", $sText, $iTrayTipTime, 1)
Until $aState[2]
If @error Then
FileDelete($sFile)
Return 1
EndIf
InetClose($hDownload)
Return 0
EndFunc
Func SetupHelp($sTopic)
If Not FileExists($sAppHelp) Then Return
$sHelpTopic = $sTopic
HotKeySet("{F1}", "ShowHelp")
EndFunc
Func ShowHelp()
If $hHelpHandle = -1 Then Return
DllCall($hHelpHandle, "hwnd", "HtmlHelp", "hwnd", 0, "str", $sAppHelp & "::" & $sHelpTopic, "int", 0, "dword", 0)
EndFunc
