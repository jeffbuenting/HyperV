#------------------------------------------------------------------------------
# Virtual PC module
#
# Powershell cmdlets to manipulate Virtual PC VMs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function Start-VPCVM
#
#------------------------------------------------------------------------------

Function Start-VPCVM

{
	param ( [String]$VMName = $null,
			$VPCApp = $VPC )
	
	if ( $VMName -eq $Null ) { 	# ----- Start all VMs 
			$VM = $VPC.FindVirtualMachine()
			$VM.Startup()
		}
		else {
			$VM = $VPC.FindVirtualMachine($VMName)
			$VM.Startup()
	}
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

$Global:VPC = New-Object -ComObject virtualpc.application 