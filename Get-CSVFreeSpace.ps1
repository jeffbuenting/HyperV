#---------#------------------------------------------------------------------------------
# Function Get-VMSize
#
# returns the amount of space a VM will need if vhd is full
# $Full = true if you want the fully provisions size.  False if you want the dynamic size
#------------------------------------------------------------------------------

Function Get-VMSize

{
	Param ( $VM,
			$Full = $True )
	
	$VMSize = 0
	if ( $VM.DynamicMemoryEnabled -eq $true ) { # --- Using Dynamic Memory
			$RAM = $VM.DynamicMemoryMaximumMB / 1GB
		}
		Else { 								# --- Not using Dynamic Memory
			$RAM = $VM.Memory / 1GB
	}
	$VMSize += $RAM
	if ( $Full ) {
			$Disks = Get-VirtualDiskDrive -VM $VM
			Foreach ($Disk in $Disks ) {
				$VMSize += ($Disk.virtualharddisk).Maximumsize / 1GB
			}
		}
		else {
			$VMSize += ($VM.TotalSize) / 1GB
	}
	$VMSize += $VMSize*.20
	Return $VMSize
}

#------------------------------------------------------------------------------
# Function: Get-CSVInfo
#
# Name, Path( FriendlyVolumeName ), VolSize, NumVMs, ThinSpaceUsed, FullSpaceUsed
#------------------------------------------------------------------------------

Function Get-CSVInfo

{
	param ( $ClusterName )
	
	# ----- Setup
	Import-module failoverclusters
	
	$CSVInfo = @()
	
	$Nodes = Get-ClusterNode -Cluster $ClusterName
	
	$CSVs = Get-ClusterSharedVolume -Cluster $ClusterName
	
	$VMCount = 0
	$VMSize = 0
	
	foreach ( $CSV in $CSVs ) {
		$CSVVolInfo = $CSV | select -ExpandProperty SharedVolumeInfo
		$CSVI = New-Object System.Object
		
		$CSVI | Add-Member -type NoteProperty -Name Name -Value $CSV.Name
		$CSVI | Add-Member -type NoteProperty -Name Path -Value $CSVVolInfo.FriendlyVolumeName
		$CSVI | Add-Member -type NoteProperty -Name VolSize -Value ($CSVVolInfo.Partition.Size/1GB)
		$CSVI | Add-Member -type NoteProperty -Name ThinSpaceUsed -Value ($CSVVolInfo.Partition.UsedSpace/1GB)
		$CSVI | Add-Member -type NoteProperty -Name Cluster -Value $ClusterName
		
		foreach ($Node in $Nodes) {	
			$CLusterVMs = Get-VM -VMHost (Get-VMHost -ComputerName $Node.name) 
			$CLusterVMs | FT Name, Location
			if ($CLusterVMs -ne $Null) {
				foreach( $VM in $CLusterVMs ) {
					if ( ([string]$VM.Location).contains($CSVVolInfo.FriendlyVolumeName)   ) {
						$VMCount += 1
						$VMSize += Get-VMSize $VM
					}	
				}
			}
		}
		
		$CSVI | Add-Member -type NoteProperty -Name NumVMs -Value $VMCount
		$CSVI | Add-Member -type NoteProperty -Name FullSpaceUsed -Value $VMSize
		
		$CSVInfo += $CSVI
		$VMCount = 0
	$VMSize = 0
	}
	
	Return $CSVInfo
}


#----------------------------------------------------------------------------------------
#Main
#----------------------------------------------------------------------------------------



Get-VMMServer vbas0080 | Out-Null


#$Clusters = Get-VMHostCluster
$Clusters = get-VMHostCluster | where { $_.ClusterName -eq "VBCL0005" }

$CSVs = @()
foreach ( $Cluster in $Clusters ) { $CSVs += Get-CSVInfo $Cluster.ClusterName }

$CSVs | FT path, Thinspaceused,FullSpaceUsed -AutoSize

