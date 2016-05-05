param($sourceId, $managedEntityId) 


#------------------------------------------------------------------- 
   
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
		
		$NodeInfo += $NInfo
	}
	
	Return $NodeInfo		# ----- Uncomment when not in MP
}

#-------------------------------------------------------------------
# Main
#-------------------------------------------------------------------


if ($debug -ne "true"){$debug = [bool]$false}else{$debug = [bool]$true}

$Debug=[bool]$True

#Write-Debuginfo $Debug '$SourceID, $ManagedIntityID'

$NodeInfo=Discover-p4000Nodes 

# ----- Start by setting up API object and creating a discovery data object. 
# ----- Discovery data object requires the MPElement and Target/ID variables.  The first argument in the method is always 0. 
$API = New-Object -comObject ‘MOM.ScriptAPI’ 
$discoveryData = $API.CreateDiscoveryData(0, $sourceId, $managedEntityId)

# ----- Now we loop thru our Info and put it in property bags

ForEach ( $Node in $NodeInfo ) {
	
	
		
	$Node.virtualmanager
	$Node.ManagementGroup
	$Node.Version
	$Node.SerialNumber
	$Node.name
	$Node.IPAddress 
	$Instance = $discoveryData.CreateClassInstance( "$MPElement[Name='HPP4000.Class.Nodes']$" )
	$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/VirtualManager$",$Node.virtualmanager )
	$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/ManagementGroup$",$Node.ManagementGroup )
	$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/Version$",$Node.Version )
	$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/SerialNumber$",$Node.SerialNumber )
	$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/Name$",$Node.name )
	$Instance.addproperty( "$MPElement[Name='HPP4000.Discover.Nodes']/IPAddress$",$Node.IPAddress )
	
	$discoveryData.AddInstance( $Instance )
	
	Remove-Variable Instance
}
