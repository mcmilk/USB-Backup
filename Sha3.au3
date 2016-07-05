; =============================================================================
;  AutoIt BinaryCall UDF Demo
;  Author: Ward
; =============================================================================

#Include "BinaryCall.au3"

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

	Local $InitFunc = "rhash_sha3_" & (($Bits = 224 Or $Bits = 384 Or $Bits = 512) ? $Bits : 256) & "_init"
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
