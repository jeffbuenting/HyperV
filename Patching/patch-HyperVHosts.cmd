c:\windows\syswow64\windowspowershell\v1.0\powershell.exe -command "& {set-executionpolicy unrestricted}"

c:\windows\syswow64\windowspowershell\v1.0\powershell.exe -executionpolicy bypass "& '\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Patching\Get-windowsupdates.ps1'"

pause