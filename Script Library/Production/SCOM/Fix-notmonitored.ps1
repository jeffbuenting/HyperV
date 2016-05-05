#---------------------------------------------------------------------------
# Fix-NotMonitored.ps1
#
# If SCOM agent shows not monitored ( Uninitialized ), then uninstall agent and reinstall
#---------------------------------------------------------------------------

Set-Location "C:\Program Files\System Center Operations Manager 2007"
& ".\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Startup.ps1"

# Get the Root Management Server.
$managementServer = Get-rootManagementServer 

$agents = Get-Agent | where { $_.healthstate -eq 'Uninitialized' }
foreach ( $Agent in $Agents ) {	

	$Agent.principalname

	Uninstall-Agent -AgentManagedComputer $agent
	
	# Create the discovery configuration for computer2 and computer3.
	$discoConfig = New-WindowsDiscoveryConfiguration -ComputerName: $Agent.principalname
		
	# Discover the computers.
	$discoResult = Start-Discovery -ManagementServer: $managementServer -WindowsDiscoveryConfiguration: $discoConfig
 		
	# Install an agent on each computer.
	Install-Agent -ManagementServer: $managementServer -AgentManagedComputer: $discoResult.CustomMonitoringObjects
}
	

