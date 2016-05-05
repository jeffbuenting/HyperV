#----------------------------------------------------------------------------------------------------------------------------------------------------
# New-HVHost.ps1
#
# 	Configures a Windows 2008 R2 server as a Hyper-V host ready to be clustered.
#----------------------------------------------------------------------------------------------------------------------------------------------------

#----- Install Hotfixes --------------------------------------
Write-Host "Installing Hotfixes...."

if ( (Get-WmiObject -query 'select * from win32_quickfixengineering' | where {$_.hotfixid -eq "KB977158"} | foreach {$_.hotfixid}) -eq 0 ) {
		# ----- Not installed
		Write-Host "     Installing KB977158..."
		$job = Start-Job {  & "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Patches\Hyper-V R2 patches\Windows6.1-KB977158-x64.msu" } 
		Wait-Job $job
	}
	else {
		# ----- Already installed
		Write-Host "     KB977158 Already installed."
}
if ( (Get-WmiObject -query 'select * from win32_quickfixengineering' | where {$_.hotfixid -eq "KB675354"} | foreach {$_.hotfixid}) -eq 0 ) {
		# ----- Not installed
		Write-Host "     Installing KB975354"
		$job = Start-Job {  & "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Patches\Hyper-V R2 patches\Windows6.1-KB975354-v2-x64.msu"} 
		Wait-Job $job
	}
	else {
		# ----- Already installed
		Write-Host "     KB975354 Already installed."
}
if ( (Get-WmiObject -query 'select * from win32_quickfixengineering' | where {$_.hotfixid -eq "KB977357"} | foreach {$_.hotfixid}) -eq 0 ) {
		# ----- Not installed
		Write-Host "     Installing KB977357"
		$Job = Start-Job { & "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Patches\Hyper-V R2 patches\KB977357 - WMI Memory Leak\Windows6.1-KB977357-x64.msu"}
		Wait-Job $job
	}
	else {
		# ----- Already installed
		Write-Host "     KB977357 Already installed."
}
if ( (Get-WmiObject -query 'select * from win32_quickfixengineering' | where {$_.hotfixid -eq "KB976443"} | foreach {$_.hotfixid}) -eq 0 ) {
		# ----- Not installed
		Write-Host "     Installing KB976443"
		$Job = Start-Job { & "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Patches\Hyper-V R2 patches\KB976443 - ISCSI issue\Windows6.1-KB976443-x64.msu" }
		Wait-Job $job
	}
	else {
		# ----- Already installed
		Write-Host "     KB976443 Already installed."
}
if ( (Get-WmiObject -query 'select * from win32_quickfixengineering' | where {$_.hotfixid -eq "KB975530"} | foreach {$_.hotfixid}) -eq 0 ) {
		# ----- Not installed
		Write-Host "     Installing KB975530"
		$Job = Start-Job { & "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Patches\Hyper-V R2 patches\KB 975530 - Intel Hyper-V CPU issue\Windows6.1-KB975530-v3-x64.msu"}
		Wait-Job $job
	}
	else {
		# ----- Already installed
		Write-Host "     KB975530 Already installed."
}

#----- Load HP Lefthand MPIO DSM ------------------------------------------
Write-Host ""
Write-Host "Installing HP Lefthand MPIO DSM please wait until it is finished...."
$job = Start-job { & "\\vbgov.com\deploy\Disaster_Recovery\HP LeftHand SAN\Software\Windows Solution Pack 8.1\mpiodsm\setup.exe" /s }
Wait-Job $job

#----- Configure disk disable short name generation ----------------------
& fsutil 8dot3name set 2

#----- Check for and Install SCCM updates --------------------------------
Write-Host ""
Write-Host "Installing SCCM Windows Patches...."
$SCCMClient = [wmiclass] "\\.\root\ccm:sms_client"
$SCCMClient.RequestMachinePolicy()
$SCCMClient.EvaluateMachinePolicy()

# ----- Configure Windows Roles and Features ------------------------------
add-windowsfeature failover-clustering

add-windowsfeature hyper-v

# ----- Reboot ------------------------------------------------------------
Restart-Computer