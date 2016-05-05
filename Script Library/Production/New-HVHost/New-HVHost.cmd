Rem ----------------- Configure WinRM
rem call winrm quickconfig < y.txt

Rem ----------------- Load HP Lefthand MPIO DSM
rem echo Installing HP Lefthand MPIO DSM please wait until it is finished...

rem call "\\vbgov.com\deploy\Disaster_Recovery\HP LeftHand SAN\Software\Windows Solution Pack 8.1\mpiodsm\setup.exe" /s


Rem ------------------ Load Windows features / roles
powershell -command "& {set-executionpolicy unrestricted}"
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -NoExit -executionpolicy Bypass -ImportSystemModules -command "& '\\vbas0080\VMMLibrary\Script Library\Production\New-HVHost\New-HVHost.ps1'"
