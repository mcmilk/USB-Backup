@echo off
rem vim:set tw=200

set A=C:\Program Files (x86)\AutoIt3
set A=C:\Programme\AutoIt3
set B=Z:\autoit\USB-Backup
cd %B%

echo usb-backup 32+64bit...
copy /Y USB-Backup_Tools_xany.au3 USB-Backup_Tools.au3
"%A%\SciTE\au3Stripper\au3Stripper.exe" "%B%\USB-Backup.au3" /pe /sv /sf /rm
"%A%\Aut2exe\Aut2Exe.exe" /in "%B%\USB-Backup_stripped.au3" /out "%B%\USB-Backup_c4.exe" /nopack /icon "%B%\USB-Backup.ico" /comp 4

echo usb-backup 64bit...
copy /Y USB-Backup_Tools_x64.au3 USB-Backup_Tools.au3
"%A%\SciTE\au3Stripper\au3Stripper.exe" "%B%\USB-Backup.au3" /pe /sv /sf /rm
"%A%\Aut2exe\Aut2Exe.exe" /in "%B%\USB-Backup_stripped.au3" /out "%B%\USB-Backup_x64_c4.exe" /nopack /icon "%B%\USB-Backup.ico" /comp 4

:: remove these, not needed anymore
del "%B%\USB-Backup_stripped.au3"
del "%B%\USB-Backup_Tools.au3"

echo stripping exe files...
mpress -s -r -q USB-Backup.exe
mpress -s -r -q USB-Backup_x64.exe

echo signing exe files...
rem signtool sign /v /tr http://time.certum.pl/ /f USB-Backup.p12 /p pass USB-Backup.exe
rem signtool sign /v /tr http://time.certum.pl/ /f USB-Backup.p12 /p pass USB-Backup_x64.exe

pause
