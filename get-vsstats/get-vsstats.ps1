# VMM Library


"Library Servers"
Get-libraryserver -vmmserver vbas0053 | sort -Property computername | where { $_.Computername -ne "VBAS0053" } | foreach {
    $LibServer = $_.computername
	
	$LibShare = get-wmiobject -class "Win32_Share" -namespace "root\CIMV2" -computername $LibServer | where { $_.name -eq "VMM Library" }
	$Drive = $LibShare.Path[0] + $LibShare.Path[1]

	$VMMLibDrive = get-wmiobject -computername $LibServer -query "select deviceid,size,freespace from win32_logicaldisk where drivetype=3" | where { $_.DeviceID -eq $Drive } 

	[int64]$DriveSize = $VMMLibDrive.Size; $DriveSize = $DriveSize / 1024 / 1024 / 1024
	[int64]$Freespace = $VMMLibDrive.FreeSpace; $FreeSpace = $FreeSpace / 1024 / 1024 / 1024
	"    $LibServer has $FreeSpace GB free on a $DriveSize GB drive"
}

"VM Hosts"
get-vmhost -vmmserver vbas0053 | sort -Property computername | foreach {
    $HostServer = $_.Computername
	$HostServer
	foreach ( $P in $_.vmpaths ) {
	    $Drive = $P[0] + $P[1]
		$VMDrive = get-wmiobject -computername $HostServer -query "select deviceid,size,freespace from win32_logicaldisk where drivetype=3" | where { $_.DeviceID -eq $Drive } 

		[int64]$DriveSize = $VMDrive.Size; $DriveSize = $DriveSize / 1024 / 1024 / 1024
		[int64]$Freespace = $VMDrive.FreeSpace; $FreeSpace = $FreeSpace / 1024 / 1024 / 1024
		"    $P has $FreeSpace GB free on a $DriveSize GB drive"
	}
}

