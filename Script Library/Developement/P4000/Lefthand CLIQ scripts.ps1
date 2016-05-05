#------------------------------------------------------------------
# Funct Setup-PSEnvironment
#
#
#-------------------------------------------------------------------

Function Setup-PSEnvironment

{
	param ( $Debug )
	
	if ($Debug -eq $True ) { "Setup-PSEnvironment Function"
	}
	if ( (Get-PSSnapin -Name Microsoft.SystemCenter.VirtualMachineManager -ErrorAction SilentlyContinue) -eq $null ){		#----- Check if VMM Snapin installed 
	    Add-PSSnapin Microsoft.SystemCenter.VirtualMachineManager
	}
}




#-------------------------------------------------------------------
# Funct Discover-P4000Nodes
#
# gets a list of HP P4000 Nodes
#
# Input:
# Output: 
#	Object with the list of nodes
#-------------------------------------------------------------------

Function Discover-p4000Nodes()

{
	$NodeInfo = @()
	
	Get-Content "\\vbgov.com\deploy\Disaster_Recovery\HP_LeftHand_SAN\Software\NodeIPs.txt" | foreach {
		
		$NInfo = New-Object System.Object
		
		$V = cliq discovertcp node=$_ | Out-String
				
		# ----- Get VirtManager
		$V = $V.substring($V.indexof('virtManager')+13) #strip off everything before 
		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after 
		$NInfo | Add-Member -type NoteProperty -Name VirtualManager -Value $S
		# ----- Get ManagementGroup
		$V = $V.substring($V.indexof('systemId')+13) #strip off everything before 
		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after 
		$NInfo | Add-Member -type NoteProperty -Name ManagementGroup -Value $S
		
		# ----- Get Version
		$V = $V.substring($V.indexof('softwareVer')+13) #strip off everything before 
		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after 
		$NInfo | Add-Member -type NoteProperty -Name Version -Value $S
		# ----- Get Serial Number
		$V = $V.substring($V.indexof('serialNumber')+13) #strip off everything before 
		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after 
		$NInfo | Add-Member -type NoteProperty -Name SerialNumber -Value $S
		
		# ----- Get Name
		$V = $V.substring($V.indexof('name')+13) #strip off everything before 
		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after 
		$NInfo | Add-Member -type NoteProperty -Name Name -Value $S
		# ----- Get IPAddress
		$V = $V.substring($V.indexof('ipAddress')+13) #strip off everything before 
		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after 
		$NInfo | Add-Member -type NoteProperty -Name IPAddress -Value $S
#		
		$NodeInfo += $NInfo
	}
	
	
#	Return $NodeInfo		# ----- Uncomment when not in MP

	# --------------------MP Code.  Comment out when not in an MP -----------------------------
	
	
	# ----- Start by setting up API object and creating a discovery data object. 
	# ----- Discovery data object requires the MPElement and Target/ID variables.  The first argument in the method is always 0. 
	$API = New-Object -comObject ‘MOM.ScriptAPI’ 
	$discoveryData = $API.CreateDiscoveryData(0, $sourceId, $managedEntityId)

	# ----- Now we loop thru our Info and put it in property bags
	foreach ( $Node in $NodeInfo ) {
		$Instance = $discoveryData.CreateClassInstance( "$MPElement[Name='HPP4000.Discover.Nodes']$" )
		$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/VirtualManager$",$Node.virtualmanager )
		$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/ManagementGroup$",$Node.ManagementGroup )
		$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/Version$",$Node.Version )
		$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/SerialNumber$",$Node.SerialNumber )
		$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/Name$",$Node.name )
		$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/IPAddress$",$Node.IPAddress )
		
		$discoveryData.AddInstance( $Instance )
		
		Remove-Variable Instance
	}
		

}

#--------------------------------------------------------------------
# Funct Get-P4000VolumeInfo
#
# Utilizes the CLIQ API to retrieve information about the specified Volume.  If no VolumeName is supplied the Function will return info about all volumes
#
# Input:
#	VolumeName = ( Case Sensitive ) Name of the volume whos info you want
#	SANName	= Name of the P4000 Node ( cluster name is preferable )
#	UserName = User name on the P4000 with read access
#	Password = of said user
# Returns an object with the volumes info
#--------------------------------------------------------------------

Function Get-p4000VolumeInfo 

{
	Param ( $SANName,$KeyFile,$VolumeName,$Debug )

	if ( $Debug -eq $true ) {
		"Get-P4000VolumeInfo Function"
		"     SANName = $SANName"
		"     KeyFile = $KeyFile"
		"     VolumeName = $VolumeName"
		"     Debug = $Debug"
	}

#	$VInfo = @() 				# -------------- http://powershell.com/cs/blogs/tobias/archive/2010/09/22/creating-objects-yourself-and-a-bunch-of-cool-things-you-can-do-with-them.aspx
#								# -------------- http://technet.microsoft.com/en-us/library/ff730946.aspx
#			
	if ( $VolumeName -eq $null ) {
			"Getting information on all Volumes.  This may take awhile..."
			$Value = cliq getvolumeinfo login=$SANName keyfile=$Keyfile
		}
		else {
			"Cliq"
			cliq getvolumeinfo volumename=$VolumeName login=$SANName keyfile=$KeyFile
#			$Value = cliq getvolumeinfo volumename=$VolumeName login=$SANName keyfile=$KeyFile
	}
	$value
#	
#	$V = $Value | out-string		#--------Convert to string
#	
#	
#
#	$I=0
#	do {
#		$ErrorCount = $Error.count
#	
#		# ----- Split into Object
#		
#		$V = $V.substring($V.IndexOf( 'VOLUME' ))
#				
#		$VolumeInfo = New-Object System.Object
#					
#		# ----- Pull out the size
#		$V = $V.substring($V.indexof('size')+15) #strip off everything before the size
#		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after the size
#		$VolumeInfo | Add-Member -type NoteProperty -Name Size -Value ([long]$S/1GB)
#		
#		# ----- Get Name
#		$V = $V.substring($V.indexof('name')+15)
#		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after the Name
#		$VolumeInfo | Add-Member -type NoteProperty -Name Name -Value ([regex]::Matches($S,"^[a-zA-Z]*\d*_?[a-zA-Z]?") | %{$_.value})
#		# ----- Get Provisioned Size of Volume
#		$V = $V.substring($V.indexof('bytesWritten')+15) #strip off everything before 
#		$S = $V.substring(0,$V.indexof(' '))	# -------- Strip off everything after 
#		$VolumeInfo | Add-Member -type NoteProperty -Name ProvisionedSpace -Value ([long]$S/1GB)
#
#		$VInfo += $VolumeInfo
#		
#	} while( ($V.IndexOf('VOLUME' )) -ne -1)
#	
#	Return $VInfo
}

#---------------------------------------------------------------------
# Funct Get-VMExtendedInfo	
#
# Get additional info about a VM that GET-VM does not return.
#		VMSize
#		LUN VM is stored on
#		Reclaimable Space
# Input
#	VM to get info
# Output
#	Object with the info
#---------------------------------------------------------------------

Function Get-VMExtendedInfo

{
	Param ( $KeyFile, $VM, $Debug )

	if ( $Debug = $true ) { 
		"Get-VMExtendedInfo Function" 
		"     KeyFile = $KeyFile"
		"     VM = $VM"
		"     Debug = $Debug"
	}

	$VEInfo = @()
	
	if ( $VM -eq $null ) { "Warning, Getting info for all LUNs / VMs.  This may take awhile..." }
			
	$VMVolume = Get-p4000VolumeInfo -SANName "VBSAN001" -Keyfile $KeyFile -VolumeName $VM -Debug $True
	
	if ( $Debug -eq $true ) { 
		"-----Volume Info -----"
		$VMVolume 
		$I = 0
	}
#	
#	foreach ( $VMV in $VMVolume ) {
#		if ( $Debug -eq $true ) { 
#			"------Volume $I------"
#			$VMV 
#			$I++
#		}
#	
#		# ----- Get VM Info 
#		$S = ([regex]::Matches($VMV.Name,"^[a-zA-Z]*\d*") | %{$_.value})
#		if ( $Debug -eq $true ) { "VM Name = $S" }
#		
#		$VMInfo = Get-VM -VMMServer vbas0080 -Name $S | where{ ( $_.status -ne 'IncompleteVMConfig') -and ( $_.status -ne 'Missing' ) -and ( $_.Status -ne 'Stored' ) }
#		$VMExInfo = New-Object System.Object
#		if ( $VMInfo -eq $null ) {
#				# ----- LUN does not contain a VM
#				$VMExInfo | Add-Member -type NoteProperty -Name VMName -Value $S	# ----- Gets the VM's Name
#				$VMExInfo | Add-Member -Type NoteProperty -Name VolumeName -Value "Error finding VM with this name" 	# ----- Error
#				
#			}
#			else {		# ----- Process info for VM
#				
#				$VMExInfo | Add-Member -type NoteProperty -Name VMName -Value $VMInfo.Name	# ----- Gets the VM's Name
#				$VMExInfo | Add-Member -Type NoteProperty -Name VolumeName -Value $VMV.Name	# ----- Gets the VM's Volume's Name
#				
#				if ( $VMInfo.VMHost -eq "vbvs0002.vbgov.com" -or  $VMInfo.VMHost -eq "vbvs0004.vbgov.com" ) { 	# ----- Non Clustered hosts
#						$Location = $VMInfo.Location -replace ":", "$"
#						$VMFolder = "\\"+$VMInfo.VMHost+"\"+$Location
#					}
#					else {
#						$Location = $VMInfo.Location -replace "c:", "\c$"
#						$Location = ( [Regex]::Matches( $Location, "^\\c\$\\ClusterStorage\\[a-zA-Z0-9]*\\") | %{$_.value} )      
#						$VMFolder = "\\"+$VMInfo.VMHost+$Location
#				}
#				$VMFolderSize = (Get-ChildItem $VMFolder -recurse | Measure-Object -property length -sum).sum/1GB 
#				$VMEXInfo | Add-Member -type NoteProperty -Name VMSize -Value $VMFolderSize	# ---- Gets the VM's Size Includeing VHDs and Config files
#				if ( ($VMV.ProvisionedSpace - $VMFolderSize) -lt 0 ) { $RecSpace = 0 }
#					else { $RecSpace = $VMV.ProvisionedSpace - $VMFolderSize }
#				$VMEXInfo | Add-Member -type NoteProperty -Name ReclaimableSpace -Value $RecSpace	# ---- Gets the potentially reclaimable space on the Volume
#				$VEInfo += $VMExInfo
#		}
#	}	
#	
#	Return $VEInfo
}

#---------------------------------------------------------------------
#---------------------------------------------------------------------
#  Main
#---------------------------------------------------------------------

$Debug = $True

Setup-PSEnvironment -Debug $Debug


$KeyFile = "\\vbgov.com\deploy\Disaster_Recovery\HP_LeftHand_SAN\Software\P4000keyfile.dat"
#$KeyFile = "C:\temp\P4000keyfile.dat"
$VM = 'VBFP0006'

#get-VMExtendedInfo -KeyFile $KeyFile -VM $VM -Debug $Debug

#cliq getvolumeinfo volumename=$VM login=VBSAN001 keyfile=$Keyfile > c:\temp\volinfo.txt 
#$V = Get-Content c:\temp\volinfo.txt
#$V


$v = cliq getvolumeinfo volumename=VBFP0006 login=VBSAN001 username=jbuentin password=Branman1! output=xml
$v







#Discover-p4000Nodes






