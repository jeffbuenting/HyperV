# http://msdn.microsoft.com/en-us/library/cc144922.aspx#Y497


Write-Host "hello"
$UpdateList = @()

$SWUpdates = New-Object -ComObject "UDA.CCMUpdatesDeployment"

$SWUpdatesList = $SWUpdates.EnumerateUpdates(2,0,[Ref]0)


$UpdateCount = $SWUpdatesList.GetCount()

# ----- Before installing, determine wheather another job is already in progress

		for ( $I = 0; $I -le $UpdateCount; $I++ ) {
			$Patch = $SWUpdatesList.getupdate($I)
			$UpdateList += @($Patch.getid())
		}
#		$UpdateList
#		
#		
#		# ----- Download and install the update
#		$SWUpdates.InstallUpdates( $UpdatesList,0,1 )

