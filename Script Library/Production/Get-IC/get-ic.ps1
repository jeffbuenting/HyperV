#---------------------------------------------------------------------------
# Get-IC
#
# Gets info about the Hyper-V integrated components
#---------------------------------------------------------------------------

Get-VMMServer "vbas0080"
$VMs = Get-VM

foreach ( $VM in $VMs ) {
#	$computer = $VM.computername
#	$Computer
#	Test-Path "\\$Computer\windows\system32\drivers\vmbus.sys"
    $Computer = $VM.ComputerName
	if ($VM.status -eq "Running" ) { 
		if ( Test-Path "\\$Computer\c$\windows\system32\drivers\vmbus.sys" ) {
				$fileinfo = ((get-item "\\$Computer\c$\windows\system32\drivers\vmbus.sys").VersionInfo ).FileVersion
				Write-Host "$Computer  -- $fileinfo"
			}
			else {
				Write-Host "$Computer -- Path does not exist"
		}
	}
}
