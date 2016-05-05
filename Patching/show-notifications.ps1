

#Import-Module "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Patching\SCCMPSModule\SCCMPSModule.psm1"
#
#show-sccmnotifications


$SWUpdates = New-Object -ComObject "UDA.CCMUpdatesDeployment"
	
	$SWUpdates