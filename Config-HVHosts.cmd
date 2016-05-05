@CLS

@Echo off



Rem -- Copy powershell config file ( can't do it via powershell as there are permissoion issues )
rem copy "\\vbgov.com\deploy\disaster_recovery\Hyper-V Windows 2008\patches\host\powershell.exe.config" "c:\windows\system32\windowspowershell\v1.0\"
	
REM -- Configure Powershell
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell -command "& {set-executionpolicy unrestricted}"

%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell -ExecutionPolicy Bypass -command "& '\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Config-HVHosts.ps1'"

pause

	