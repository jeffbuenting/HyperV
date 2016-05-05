#------------------------------------------------------------------
# Fuction Discover-Checkpoints
#------------------------------------------------------------------

Function Discover-Checkpoints

{
	if ( (Get-PSSnapin -Name Microsoft.SystemCenter.VirtualMachineManager -ErrorAction SilentlyContinue) -eq $null ){		#----- Check if VMM Snapin installed 
	    Add-PSSnapin Microsoft.SystemCenter.VirtualMachineManager
	}

	Get-VMMServer "VBAS0080.vbgov.com" | out-null

	$CheckPoints = get-vmcheckpoint 

	$Today = Get-date
	
	$CheckPoint =@()

	# ----- Now we loop thru our Info and put it in property bags
	foreach ( $CP in $CheckPoints ) {
		$CPInfo = New-Object System.Object
		
		$CPVHDs = ""
		# ----- Get .AVHD files associated with the CheckPoint
		$Drives = $CP.virtualdiskdrives

		foreach( $D in $Drives) {
			$CPVHDs += ($D.virtualharddisk).name + ".avhd, "
			
		}
		
		# ----- Get .VHD files associated with the checkPoint
		$VM = Get-VM -name $CP.VM
				
		$Drives=$VM.virtualharddisks
		foreach($D in $Drives) {
			$CPVHDs +=$D.name + '.vhd, '
		}
		
		$VDrives = Get-VirtualHardDisk -VM $VM
		
		$reclaimSpace = 0
		foreach ( $VD in $VDrives ) {
			$VD
			if ( ($VD.location).contains( "avhd" ) ) { 
				$reclaimSpace += ($VD.size)/1GB
				$ReclaimSpace
			}
		}
		
		# ----- Remove the last comma
		$CPVHDs = $CPVHDs.substring(0,$CPVHDs.length-2)
		
		$CPInfo | Add-Member -type NoteProperty -Name CheckPointName -Value $CP.Name
		$CPInfo | Add-Member -type NoteProperty -Name CheckPointCreationDate -Value $CP.AddedTime
		$CPInfo | Add-Member -type NoteProperty -Name VMName -Value $CP.VM.Name
		$CPInfo | Add-Member -type NoteProperty -Name Age -Value (($Today-$CP.AddedTime).Days )
		$CPInfo | Add-Member -type NoteProperty -Name VHDs -Value $CPVHDs
		$CPInfo | Add-Member -type NoteProperty -Name ReclaimableSpace -Value $ReclaimSpace
		
		$CheckPoint += $CPInfo
		
	}
	Return $CheckPoint
}



#--------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------

$CheckPoints = Discover-Checkpoints 

$ProdReclaimableSpace = 0
$TestReclaimableSpace = 0



foreach ( $CP in $CheckPoints) { 
($CP.VMName).substring(4,1)

	Switch (($CP.VMName).substring(4,1) ) {
		0 {$ProdReclaimableSpace += $CP.ReclaimableSpace }
		8 { $TestReclaimableSpace += $CP.ReclaimableSpace }
		9 { $TestReclaimableSpace += $CP.ReclaimableSpace }
	}
}

$TestReclaimableSpace
$ProdReclaimableSpace

	