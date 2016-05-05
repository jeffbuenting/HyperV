
$clusterName = 'vbcl0012'

Import-Module failoverclusters


# ----- Move Owner of Cluster and quorum if needed
#    Write-Host "-- Moving the quorum to another host if needed..."
#    $Quorum = Get-ClusterGroup -Cluster $clusterName | where { $_.name -eq 'Cluster Group' }
      
	  
    Move-ClusterGroup -Cluster $ClusterName -Name 'Cluster Group'
      
