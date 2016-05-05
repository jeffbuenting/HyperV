#------------------------------------------------------------------------------
# Patch-HyperVHosts.sp1
#
# Patches the Hyper-V hosts in a cluster 
#------------------------------------------------------------------------------


#----------------------------------------------------------------------------
# Main
#----------------------------------------------------------------------------

# ----- Script requires elevation.  Check to see if running as admin.  if not restart eleveted
Import-Module "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\UACPSModule\UASPSModule.psm1"
Restart-ScriptAsAdmin

$ClusterName = 'VBCL0008'

# ----- Get cluster Nodes
if ( (Get-PSSnapin -Name Microsoft.SystemCenter.VirtualMachineManager -ErrorAction SilentlyContinue) -eq $null ){
	Add-PSSnapin -Name Microsoft.SystemCenter.VirtualMachineManager
}
Get-VMMServer VBAS0080 | out-null
$Cluster = Get-VMHostCluster -Name $ClusterName
$ClusterNodes = Get-VMHost -VMHostCluster $Cluster | where { $_.name -eq 'VBVS0050.vbgov.com' }

Import-Module "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Patching\SCCMPSModule\SCCMPSModule.psm1"
Import-Module FailOverClusters

$ClusterCSVs = Get-ClusterSharedVolume -Cluster $ClusterName 

# ----- Process each node one at a time
foreach ( $Node in $ClusterNodes ) {
	Write-Host "Processing Node $Node.ComputerName in cluster $ClusterName"
	
	# ----- Put Node in Maint Mode via VMM to live migrate all VMs to another node
	# ----- Check to see if Host is already in Maint Mode
	$VMHost = Get-VMHost -ComputerName $Node
	if ( $VMHost.MaintenanceHost -ne $true ) {
		Write-Host "-- Placing Node in Maintenance Mode and Live migrating VMs to other hosts..."
		try {
				Try {
						Disable-VMHost -VMHost $Node -MoveWithinCluster -ErrorAction Stop | out-null
					}
					catch [System.Management.Automation.ActionPreferenceStopException] {
						throw $_.Exception
				}
			}
			catch [Microsoft.VirtualManager.Utils.CarmineException] {
				Write-Host "Error:" -ForegroundColor Red
				Write-Host "$_.Exception" -ForegroundColor Red
				Write-Host "$_.FullyQualifiedErrorID" -ForegroundColor Red
				Write-Host ""
				Write-Host "Resolutions:" -ForegroundColor Red
				Write-Host "-- Check the cluster to see if there is enough room to migrate VMs." -ForegroundColor Red
				Write-Host "-- Verify all VMs have checked the Allow migration to a virtual machine host with a different processor checked." -ForegroundColor Red
			}
			catch { 			# ----- Catch all other errors
				Write-Host "Error:" -ForegroundColor Red
				"$_.Exception"
				$_.FullyQualifiedErrorID
				$_.Exception.gettype().Fullname
				"----"
				$_ | FL *
				
		}
	}
		
	
	# ----- Move all CSVs from Node if needed
	Write-Host "-- Moving CSVs from this Node if needed..."
	$CSVs = $ClusterCSVs | where { ($_.ownernode).name -eq $Node.ComputerName }
	if ( $CSVs -ne $null ) {
		foreach ($C in $CSVs) {
			Move-ClusterSharedVolume $C.name -Cluster $ClusterName
		}
	}
	
	# ----- Move Owner of Cluster and quorum if needed
	Write-Host "-- Moving the quorum to another host if needed..."
	$Quorum = Get-ClusterGroup -Cluster $clusterName | where { $_.name -eq 'Cluster Group' }
	if ( ($Quorum.ownernode).name -eq $Node.ComputerName ) {
		Move-ClusterGroup -Cluster $ClusterName -Name 'Cluster Group'
	}
	
	# ----- Patch Node
	$RebootNeeded = Install-SCCMUpdates $Node.Name $Cred
	
	write-host $RebootNeeded
	
	if ( $RebootNeeded ) {
		Write-Host "rebooting..." -NoNewline
#		Restart-Computer $Node.Name -force
		
		# ----- Wait until Node has Rebooted
		# ----- Wait for Service ( to stop )
		$Continue = $False
		do {
			try {
					$Service = Get-Service -ComputerName $Node.Name | where { $_.name -eq 'vmms' } -ErrorAction SilentlyContinue
					Write-Host "." -NoNewline
				}
				Catch {
					$Continue = $true
			}
		} while ( -not $Continue )
		# ----- Wait for Service ( to start )
		do {
			try {
					$Service = Get-Service -ComputerName $Node.Name | where { $_.name -eq 'vmms' } -ErrorAction SilentlyContinue
					Write-Host "." -NoNewline
				}
				Catch {
			}
			
		} while ( $Service.Status  -ne 'Running')
	}

	# ----- Stop Maint Mode via VMM on host
	# ----- Check if Host is in Maintenance Mode
	$VMHost = Get-VMHost -ComputerName $Node
	if ( $VMHost.MaintenanceHost -eq $true ) {
		Write-Host "`n-- Stopping Maintenance mode..."
		try { 
				Enable-VMHost -VMHost $Node | Out-Null
			}
			catch {
				Write-Host "Error:" -ForegroundColor Red
				"$_.Exception"
				$_.FullyQualifiedErrorID
				$_.Exception.gettype().Fullname
				"----"
				$_ | FL *
		}
	}

}

Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


  
  