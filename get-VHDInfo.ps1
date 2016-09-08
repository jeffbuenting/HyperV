#------------------------------------------------------------------------------
# Get-VHDInfo.ps1
#
# Returns Info about the VHD
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Function Get-VMSize
#
# returns the amount of space a VM will need if vhd is full
#------------------------------------------------------------------------------

Function Get-VMSize

{
	Param( $VM )
	
	$VMSize = 0
	if ( $VM.DynamicMemoryEnabled -eq $true ) { # --- Using Dynamic Memory
			$RAM = $VM.DynamicMemoryMaximumMB / 1GB
		}
		Else { 								# --- Not using Dynamic Memory
			$RAM = $VM.Memory / 1GB
	}
	$VMSize += $RAM
	$VMSize += ($VM.TotalSize) / 1GB
	$VMSize += $VMSize*.20
	Return $VMSize
}

#-----------------------------------------------------------------------------
# Get-VMCSV
#
# Gets the name of the CSV that the VM is stored on
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

#-----------------------------------------------------------------------------
# Main
#-----------------------------------------------------------------------------

import-module \\vbgov.com\deploy\Disaster_Recovery\Powershell\Modules\Server-PSModule\server-psmodule.psm1

Get-VMMServer vbas0080 | Out-Null

$VMs = Get-VM | where { $_.status -ne "Stored" }

$VMInfo = @()

foreach ( $VM in $VMs ) {

	$VM.name

	$VMI = New-Object system.Object
	
	$VMI | Add-Member -type NoteProperty -Name Name -Value $VM.Name
	$VMI | Add-Member -type NoteProperty -Name VMSize -Value (Get-VMSize $VM)
	
	# ----- Get the used space Windows sees on its HDD
	
	$WindowsSize = get-HDDUsedSpace -ServerName $VM.ComputerName
	$VMI | Add-Member -type NoteProperty -Name SizeSeenByWindows -Value $WindowsSize.TotalDiskSpaceUsedbyWIndows
	
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
	$VMI | Add-Member -type NoteProperty -Name Location -Value $VM.Location
	$VMI | Add-Member -type NoteProperty -Name CSV -Value (get-VMCSV $VM)
	
	$VMInfo += $VMI
}

#$VMInfo

$VMInfo | Export-Csv c:\temp\VMInfo.csv