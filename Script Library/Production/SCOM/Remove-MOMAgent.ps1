#---------------------------------------------------------------------------
#Remove-MOMAgent.ps1
#
# If the SCOM agents, from a list of computers in an OU, status is monitored ( Not uninitialized ) then remove the MOM 2005 agent
#---------------------------------------------------------------------------


#Set-Location "C:\Program Files\System Center Operations Manager 2007"
#& ".\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Startup.ps1"
#
## Get the Root Management Server.
#$managementServer = Get-rootManagementServer 
#
#$Servers = get-QADComputer -SearchRoot 'vbgov.com/servers file and print'
#
#foreach ( $S in $Servers ) {
#		
#	# ----- Check if agent is installed
#	if ($agent = Get-Agent | where { $_.healthstate -nq 'Uninitialized' } ) {
#			# ----- If agent is not installed, Install it
#			Write-Host "Uninstalling from MOM 2005 " $S.DNSName
#			
#			
#		}
#		else {
#			Write-Host $S.DNSName " SCOM Agent issues"
#	}
	
	
	
	
[System.Reflection.Assembly]::LoadFile("C:\Program Files\MOM\Microsoft.Mom.Sdk.dll") 
[System.Reflection.Assembly]::LoadFile("C:\Program Files\MOM\mom.context.dll") 

$mom = [Microsoft.EnterpriseManagement.Mom.Administration]::GetAdministrationObject() 

# And we are Ready to Go :  

# Ask the Object what we can do With it : 

$mom | gm 
