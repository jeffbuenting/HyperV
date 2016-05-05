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

#--------------------------------------------------------------------


Setup-PSEnvironment

$VMs = get-vm -vmmserver "VBAS0080" | where {($_.host -ne "VBVS9001" -or $_.host -ne "VBPUBVS0015") -and $_.status -eq "Running" }
 
 foreach ($V in $VMs ) {
 	if ( ($V.hostgrouppath).contains("All Hosts\VBGOV\Production") ) {
		$Name = $V.name
		$Desc = $V.Description
		"$Name; $Desc" | out-file c:\temp\prod_vms.txt -append
	}
	if ( ($V.hostgrouppath).contains("All Hosts\VBGOV\Test Dev") ) {
		$Name = $V.name
		$Desc = $V.Description
		"$Name; $Desc" | out-file c:\temp\Testdev_vms.txt -append
	}
}