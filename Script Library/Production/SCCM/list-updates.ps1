#-------------------------------------------------------------------------------
# Function Test-Admin
#
# Returns True if running as admin
#-------------------------------------------------------------------------------

function Test-Admin 
{ 
   $currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() ) 
   if ($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) 
   { 
      return $true 
   } 
   else 
   { 
      return $false 
   } 
}  

#-------------------------------------------------------------------------------
# Function Restart-ScriptAsAdmin
#
#
#-------------------------------------------------------------------------------

Function Restart-ScriptAsAdmin

{
	$Invocation=((Get-Variable MyInvocation).value).ScriptName 
	
	if ($Invocation -ne $null) 
	{ 
	   $arg="-command `"& '"+$Invocation+"'`"" 
	   if (!(Test-Admin)) { # ----- F
			      Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg 
			      break 
		   		} 
			Else {
				Write-Host "Already running as Admin no need to restart..."
		}
	} 
	else 
	{ 
	   return "Error - Script is not saved" 
	   break 
	} 
}

#----------------------------------------------------------------------------
# Function List-SCCMUpdates
#
# Lists the updates that SCCM has advertised for this computer
#----------------------------------------------------------------------------

Function List-SCCMUpdates

{
	param ( $Computer )
	
	Enable-WSManCredSSP -Role client -DelegateComputer *
	$Session = New-Pssession -ComputerName $Server -authentication Credssp -Credential (Get-Credential) -ConfigurationName "http://schemas.microsoft.com/powershell/microsoft.powershell32"
	Invoke-Command -Session $Session -ScriptBlock {

		$SWUpdates = New-Object -ComObject "UDA.CCMUpdatesDeployment"
		$SWUpdatesList = $SWUpdates.EnumerateUpdates(2,0,[Ref]0)

		if ( $SWUpdatesList.getcount() -eq 0 ) {
				"No Updates Found..."
			}
			else {
				"updates that need to be installed..."
				for ( $I = 0; $I -le $SWUpdatesList.getcount(); $I++ ) {
					$Update = $SWUpdatesList.GetUpdate($I)
					$Update.getname(1033)
				}
		}
	} 
	Remove-PSSession $Session

	Disable-WSManCredSSP -role client
}

#----------------------------------------------------------------------------
# Function Install-SCCMUpdates
#
# Installs updates presented by SCCM
# http://msdn.microsoft.com/en-us/library/cc144922.aspx
#----------------------------------------------------------------------------

Function Install-SCCMUpdates 

{
	Param ( $Computer )
	
	Enable-WSManCredSSP -Role client -DelegateComputer *
	$Session = New-Pssession -ComputerName $Server -authentication Credssp -Credential (Get-Credential) -ConfigurationName "http://schemas.microsoft.com/powershell/microsoft.powershell32"
	Invoke-Command -Session $Session -ScriptBlock {
		$Progress = 0
		$UpdatesDeployment = New-Object -ComObject "UDA.CCMUpdatesDeployment"
		$UpdatesColl = $UpdatesDeployment.EnumerateUpdates(2,0,[ref]$Progress)
		
		$UpdateCount = $UpdatesColl.getcount()
		
		if ( $Progress -eq 0 ) {  	# ----- No other Installation in progress
				if (  $UpdateCount -gt 0 ) { 	# ----- Updates still to install
						$UpdatesList = @()
						for ( $I = 0; $I -le $UpdateCount - 1; $I++ ) {
							$I
							$Update = $UpdatesColl.GetUpdate($I)
							$UpdatesList += $Update.GetID()
						}						
						
						# ----- Download and Install the updates
						$UpdatesDeployment.InstallUpdates( $UpdatesList,0,1)
						
						Write-Host "Updates being installed...."
					}
					Else {						# ----- No more updates to install
						Write-Host "No updates need to be installed"
				}
			}
			else {					# ------ Another Installation is in progress
				Write-Host "Another Update Installation is in Progress"
		}
	} 
	Remove-PSSession $Session

	Disable-WSManCredSSP -role client
}
 
#----------------------------------------------------------------------------
# Main
#----------------------------------------------------------------------------

Restart-ScriptAsAdmin

$Server = 'VBVS0014'
	
Install-SCCMUpdates $server