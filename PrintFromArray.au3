#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _PrintFromArray
; Description ...: Print an array to the console.
; Syntax ........: _PrintFromArray(Const Byref $aArray[, $iBase = Default[, $iUBound = Default[, $sDelimeter = "|"]]])
; Parameters ....: $aArray              - [in/out and const] The array to be written to the file.
;                  $iBase               - [optional] Start array index to read, normally set to 0 or 1. Default is 0.
;                  $iUBound             - [optional] Set to the last record you want to write to the File. Default is whole array.
;                  $sDelimeter          - [optional] Delimiter character(s) for 2-dimension arrays. Default is "|".
; Return values .: Success - 1
;                  Failure - 0 and sets @error to non-zero
;                   |@error:
;                   |1 - Input is not an array.
;                   |2 - Array dimension is greater than 2.
;                   |3 - Start index is greater than the size of the array.
; Author ........: guinness
; Modified ......:
; Remarks .......:
; Related .......: _FileWriteFromArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _PrintFromArray(ByRef Const $aArray, $iBase = Default, $iUBound = Default, $sDelimeter = "|")
    ; Check if we have a valid array as input
    If Not IsArray($aArray) Then Return SetError(1, 0, 0)

    ; Check the number of dimensions
    Local $iDims = UBound($aArray, 0)
    If $iDims > 2 Then Return SetError(2, 0, 0)

    ; Determine last entry of the array
    Local $iLast = UBound($aArray) - 1
    If $iUBound = Default Or $iUBound > $iLast Then $iUBound = $iLast
    If $iBase < 0 Or $iBase = Default Then $iBase = 0
    If $iBase > $iUBound Then Return SetError(3, 0, 0)

    If $sDelimeter = Default Then $sDelimeter = "|"

    ; Write array data to the console
    Switch $iDims
        Case 1
            For $i = $iBase To $iUBound
                ConsoleWrite("[" & $i - $iBase & "] " & $aArray[$i] & @CRLF)
            Next
        Case 2
            Local $sTemp = ""
            Local $iCols = UBound($aArray, 2)
            For $i = $iBase To $iUBound
                $sTemp = $aArray[$i][0]
                For $j = 1 To $iCols - 1
                    $sTemp &= $sDelimeter & $aArray[$i][$j]
                Next
                ConsoleWrite("[" & $i - $iBase & "] " & $sTemp & @CRLF)
            Next
    EndSwitch
    Return 1
EndFunc   ;==>_PrintFromArray
