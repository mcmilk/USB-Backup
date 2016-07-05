
USB-Backup
==========


[USB-Backup] is a free backup solution for creating encrypted backups to
external USB media.

For the compression and the backup format itself the proven and very stable
software 7-Zip is used.


## Features

- local disks, such as the system disk C: can be backed up by using shadow
  copies (warning, this requires administrator privileges)
- the use of the program is user-friendly and has been developed in
  cooperation with users
- Network drives and UNC paths can also be backed up
- Installation: no setup, just one AutoIT script (put together into one
  executable)
- Security:
  - during the initial backup, a password is set - without a password, you can
    not back up!
  - when the external disk will be lost, a stranger can not really see what
    was backed up
  - only username@pc are stored plaintext, but this is used to distinguish the
    backups in case of emergency
  - an encrypted index is stored on the external disk, so that a restore at
    any time and on any computer is possible
- to each directory, you can create exception lists
- after a setable time, USB-Backup reminds the user to update the existing
  backup
- the degree of compression and other 7-Zip parameters can be completely
  adapted in the USB Backup.ini
- Automatic updates of program and help file are possible, but you can disable
  this also
- the help file is currently not finished, sorry about that :(
  - you can help me with that :)


## Screenshots

- no stick: ![no stick](http://mcmilk.de/projects/USB-Backup/t_stick_no.png)
- with stick: ![with stick](http://mcmilk.de/projects/USB-Backup/t_stick_yes.png)
- registred stick: ![reg. stick](http://mcmilk.de/projects/USB-Backup/t_stick_reg.png)


## Requirements

- Hardware
  - Intel Pentium III, 500MHz, 512MB RAM, 2MB Harddisk
- Operation System:
  - Windows XP, Windows Vista, Windows 7, Windows 8, Windows 10
  - Windows Server 2003, Windows Server 2008, Windows Server 2012
- Software:
  - for restoring the backups, 7-Zip Zstd is needed


## Installation

- the program does not require installation and is run under default user
  privileges
- [USB-Backup] should be put into the Startup folder, so that it starts with
  windows - it is seen then in the system tray
- the per user configuration can be found in this folder: %APPDATA%\USB-Backup


## Download

- https://mcmilk.de/projects/USB-Backup/dl/latest/

    7-Zip ZStd Homepage
    7-Zip Homepage
    AutoIt Homepage
    other Backup Software
    Google Search: Windows USB Backup 

## See Also

- [7-Zip] Homepage
- [7-Zip Zstd] Homepage
- [USB-Backup] Homepage


[7-Zip]: http://www.7-zip.org/
[7-Zip Zstd]: https://github.com/mcmilk/7-Zip-Zstd
[USB-Backup]: https://github.com/mcmilk/USB-Backup
