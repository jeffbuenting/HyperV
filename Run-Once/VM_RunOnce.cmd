@Echo off

REM -- Pause for IE to configure itself ( 3 minutes ) (1 min = 60000 miliseconds )
REM ping 1.1.1.1 -n 1 -w 30000 > nul

Rem -- add powershell feature ( needed for windows 2008 servers ) 
rem start /wait ocsetup MicrosoftWindowsPowerShell /passive
"\\vbgov.com\deploy\Disaster_Recovery\Powershell\Powershell 2.0 Win 2008x64\windows6.0-kb968930-x64.msu /passive /norestart"

Rem -- Copy powershell config file ( can't do it via powershell as there are permissoion issues )
copy "\\vbgov.com\deploy\disaster_recovery\Hyper-V Windows 2008\patches\host\powershell.exe.config" "c:\windows\system32\windowspowershell\v1.0\"
	
REM -- Configure Powershell
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell -command "& {set-executionpolicy unrestricted}"

%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell -ExecutionPolicy Bypass -command "& '\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Run-Once\Config-VM.ps1'"

pause

	