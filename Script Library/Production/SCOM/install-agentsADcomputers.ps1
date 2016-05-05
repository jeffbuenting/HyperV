#---------------------------------------------------------------------------
#Install-AgentADComputers.ps1
#
# Gets a list of Servers from and OU in AD and if the SCOM agent is not installed.  Installs it.
#---------------------------------------------------------------------------


Set-Location "C:\Program Files\System Center Operations Manager 2007"
& ".\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Startup.ps1"

# Get the Root Management Server.
$managementServer = Get-rootManagementServer 


$Servers = get-QADComputer -SearchRoot 'vbgov.com/servers'

foreach ( $S in $Servers ) {
		
	# ----- Check if agent is installed
	if ( ($agent = Get-Agent | where { $_.Principalname -eq $S.DNSName }) -eq $null ) {
			# ----- If agent is not installed, Install it
			Write-Host "Installing SCOM agent on" $S.DNSName
			
			# ----- Create the discovery configuration for computer2 and computer3.
			$discoConfig = New-WindowsDiscoveryConfiguration -ComputerName: $S.DNSName
			
			# ----- Discover the computers.
			$discoResult = Start-Discovery -ManagementServer: $managementServer -WindowsDiscoveryConfiguration: $discoConfig
			
			# ----- Install an agent on each computer.
			Install-Agent -ManagementServer: $managementServer -AgentManagedComputer: $discoResult.CustomMonitoringObjects
		}
		else {
			Write-Host $S.DNSName " Already Installed"
	}
}











