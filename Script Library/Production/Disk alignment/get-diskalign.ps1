
  
#param ($computer)


get-vmmserver vbas0080 | Out-Null
$VM = get-vm |where{ ($_.status -eq "Running") -and ($_.host -ne "vbvs9001" ) }

foreach ( $Computer in $VM ) {

	$partitions = Get-WmiObject -computerName $computer Win32_DiskPartition

	$partitions | foreach { Get-WmiObject -computerName $computer -query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($_.DeviceID)'} WHERE AssocClass = Win32_LogicalDiskToPartition"  | 
        	        add-member -membertype noteproperty PartitionName $_.Name -passthru |
                	add-member  -membertype noteproperty Block $_.BlockSize -passthru |
    		        add-member  -membertype noteproperty StartingOffset $_.StartingOffset -passthru |
                	add-member  -membertype noteproperty StartSector $($_.StartingOffset/$_.BlockSize) -passthru } |
	format-table SystemName, Name, PartitionName, Block, StartingOffset, StartSector 
	
}

  

#Select SystemName, Name, PartitionName, Block, StartingOffset, StartSecto