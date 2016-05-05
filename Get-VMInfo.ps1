#------------------------------------------------------------------------------
# Get-VMInfo.ps1
#
# Gets information about the VM
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function Get-VMSize
#
# returns the amount of space a VM will need if vhd is full
#------------------------------------------------------------------------------

Function Get-VMSize

{
	Param( $VM,
			[Switch]$Debug )
	
	$VMSize = 0
	if ( $VM.DynamicMemoryEnabled -eq $true ) { # --- Using Dynamic Memory
			$RAM = $VM.DynamicMemoryMaximumMB / 1GB
		}
		Else { 								# --- Not using Dynamic Memory
			$RAM = $VM.Memory / 1GB
	}
	$VMSize += $RAM

	$VMSize += ($VM.TotalSize) / 1GB
	if ( $Debug ) { Write-Host "VMSize = " $VMSize -ForegroundColor Cyan }
	$VMSize += $VMSize*.20
	
	if ( $Debug ) { Write-Host "Adjusted VMSize = " $VMSize -ForegroundColor Cyan }
	
	Return $VMSize
}

#-----------------------------------------------------------------------------
# Funtion Get-VMCSV
# 
# Gets the CSV that the VM is stored on
#-----------------------------------------------------------------------------

Function Get-VMCSV

{
	param ( $VM )
	
	$CSV = ([regex]::matches([string]($VM.Location), "C:\\ClusterStorage\\[A-Za-z\d_]*")) | %{$_.value}

	if ( $CSV -ne $null ) {
			return $CSV.substring(18)
		}
		Else {
			Return "Local Storage"
	}
}

#------------------------------------------------------------------------------
# Function Get-HDDUsedSpaceHardDrive
#
#	Returns what Windows sees as used space on all of its hard drives as one number.
#-----------------------------------------------------------------------------

Function Get-HDDUsedSpace

{
	param ( [String]$ServerName,
			[Switch]$Debug )
	
#	if ( $Debug ) { Write-Host "ServerName = $ServerName" -ForegroundColor Cyan }
	try {
			$Disks = gwmi -class Win32_DiskDrive -ComputerName $ServerName | where { ($_.Model -eq 'Virtual HD ATA Device') -or ($_.Model -eq 'Msft Virtual Disk SCSI Disk Device') }  -ErrorAction SilentlyContinue
			
		}
		catch {
#			if ( $Debug ) { Write-Host "Cannot connect to WMI on VM " $VM.name -ForegroundColor Red }
#				throw $error[0].Exception

	}
	if ( -not $? ) { 	# ----- Write Error and do not continue looking for Disk info
			if ( $Debug ) {
				Write-Host "ERROR - Check the Server as this name is not valid $ServerName`n`n" -ForegroundColor Red
				write-host $_ -ForegroundColor red
			}
		}
		else {			# ----- If no error Continue
			# ----- Convert Win32_DiskDrive to WIN32_LogicalDiskDrive
			$LogicalDisks = @()
			foreach ($Disk in $Disks ) {
				$PhysicalDrive = $Disk.DeviceID
				$signature = $Disk.Signature
				$Partitions = gwmi -Query "Associators of {Win32_DiskDrive='$($Disk.DeviceID)'} Where AssocClass=Win32_DiskDriveToDiskPartition" -ComputerName $Servername
				foreach ( $Part in $Partitions ) {
					$Partition = $Part.DeviceID
					$LogicalDisks += gwmi -Query "Associators of {Win32_DiskPartition='$($Part.DeviceID)'} Where AssocClass=Win32_LogicalDiskToPartition" -ComputerName $ServerName | Add-Member ScriptProperty Letter {$this.DeviceID} -PassThru | Add-Member NoteProperty Drive $PhysicalDrive -PassThru | Add-Member NoteProperty Signature $Signature -PassThru | Add-Member NoteProperty Partition $Partition -PassThru
				}
			} 
	}

	$WindowsTotalSize = 0
	foreach ( $LogicalDisk in $LogicalDisks ) {
		if ( $Debug ) { Write-Host $LogicalDisk.DeviceID ($LogicalDisk.Size/1GB) ($LogicalDisk.FreeSpace/1GB) -ForegroundColor Cyan }
		$WindowsTotalSize += $LogicalDisk.size - $LogicalDisk.Freespace
		
	}
	$HDDInfo = New-Object system.Object
	$HDDInfo | Add-Member -type NoteProperty -Name ServerName -Value $Servername
	$HDDInfo | Add-Member -type NoteProperty -Name Disks -Value $Disks
	$HDDInfo | Add-Member -type NoteProperty -Name TotalDiskSpaceUsedbyWIndows -Value ($WindowsTotalSize/1GB)
	
	if ( $Debug ) { $T = $WindowsTotalSize/1GB; Write-Host "Windows Total Size = $T"  -ForegroundColor Cyan }
	
	write-host $HDInfo
	
	Return $HDDInfo
}



#-----------------------------------------------------------------------------
# Main
#-----------------------------------------------------------------------------

Get-VMMServer vbas0080 | Out-Null

#$VMs = Get-VM | where { $_.status -ne "Stored" }



$VMs = Get-VM | where { $_.name -eq 'VBDB0027 - new' }

$VMInfo = @()

foreach ( $VM in $VMs ) {

	$VM.name

	$VMI = New-Object system.Object
	
	$VMSize = Get-VMSize $VM -Debug
	$VMI | Add-Member -type NoteProperty -Name Name -Value $VM.Name
	$VMI | Add-Member -type NoteProperty -Name VMSize -Value $VMSize
	
	# ----- Get the used space Windows sees on its HDD
	$WindowsSize = get-HDDUsedSpace -ServerName $VM.ComputerName -Debug
	if ( $WindowsSize.TotalDiskSpaceUsedbyWIndows -ne 0 ) {
			$VMI | Add-Member -type NoteProperty -Name TotalDiskSpaceSeenByWindows -Value ($WindowsSize.TotalDiskSpaceUsedbyWIndows)
		}
		else {
			$VMI | Add-Member -type NoteProperty -Name TotalDiskSpaceSeenByWindows -Value "ERROR - Value Not Available" 
	}
	
	# ---------- Get Test/Dev or Prod Hostgroup
	
	if ( ($VM.Name).Length -lt 5 ) { 
			$VMI | Add-Member -type NoteProperty -Name Tier -Value "Test"
		}
		else {
			Switch (($VM.Name).substring(4,1) ) {
				0 { $VMI | Add-Member -type NoteProperty -Name Tier -Value 'Prod' }
				1 { $VMI | Add-Member -type NoteProperty -Name Tier -Value 'Remote Prod' }
				8 { $VMI | Add-Member -type NoteProperty -Name Tier -Value "Dev" }
				9 { $VMI | Add-Member -type NoteProperty -Name Tier -Value "Test" }
			}
	}
	Write-Host $VMSize $WindowsSize.TotalDiskSpaceUsedbyWIndows -ForegroundColor cyan
	if (( $VMSize -ne 0 ) -and ( $WindowsSize.TotalDiskSpaceUsedbyWIndows -ne 0 ) -and ($VMSize -ge $WindowsSize.TotalDiskSpaceUsedbyWIndows))  {
		         # ----- calculate gain from compacting
		         $VMI | Add-Member -type NoteProperty -Name SpaceGainFromCompacting -Value ($VMSize-$WindowsSize.TotalDiskSpaceUsedbyWIndows)
		
		         # ----- Calculate percent gain from compacting
		         $VMI | Add-Member -type NoteProperty -Name PercentGainFromCompacting -Value (($VMSize-$WindowsSize.TotalDiskSpaceUsedbyWIndows)/$VMSize)
            }
            Else {
	            # ----- calculate gain from compacting
		         $VMI | Add-Member -type NoteProperty -Name SpaceGainFromCompacting -Value 0 
		
		         # ----- Calculate percent gain from compacting
		         $VMI | Add-Member -type NoteProperty -Name PercentGainFromCompacting -Value 0
	}
	
	$VMI | Add-Member -type NoteProperty -Name Location -Value $VM.Location
	$VMI | Add-Member -type NoteProperty -Name CSV -Value (get-VMCSV $VM)
	
	$VMInfo += $VMI
}

$VMInfo | select *

#$VMInfo | Export-Csv c:\temp\VMInfo.csv