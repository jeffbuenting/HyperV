#-------------------------------------------------------------------------------
# UACPSModule.psm1
#
# Provides cmdlets for UAC
#-------------------------------------------------------------------------------

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

<#
	.SYNOPSIS
		If script is not running as admin, forces it to restart with elevated privledges
		
	.DESCRIPTION
		If script is not running as admin, forces it to restart with elevated privledges
		
	.INPUTS
		None
	
	.OUTPUTS
		None
		
	.EXAMPLE
		Restart-ScriptAsAdmin

#>

Function Restart-ScriptAsAdmin

{
	$Invocation=((Get-Variable MyInvocation).value).ScriptName 
	
	if ($Invocation -ne $null) 
	{ 
	   $arg="-command `"& '"+$Invocation+"'`"" 
	   if (!(Test-Admin)) { # ----- F
			    try {
						Write-Host "Script requires elevated privledges to run.  Restarting as admin..." -ForegroundColor Yellow
			  			Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg 
					}
					catch {
						[System.Exception] | Out-Null
						Write-Host "You need to enter a valid username and password." -foregroundcolor Red
						Write-Host "Please run the script again with the correct info." -ForegroundColor red
				}
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

#-----------------------------------------------------------------------------
# Main
#-----------------------------------------------------------------------------

Export-ModuleMember -Function Restart-ScriptAsAdmin