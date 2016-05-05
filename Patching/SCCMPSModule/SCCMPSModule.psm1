#------------------------------------------------------------------------------
# SCCM Powershell Module
#------------------------------------------------------------------------------

param ( [Bool]$Debug = $False )

#------------------------------------------------------------------------------
# Show-SCCMNotifications.ps1
#
# Toggles sofware update notifications from the toast area
#------------------------------------------------------------------------------

Function Show-SCCMNotifications

{
	Param ( [String]$ComputerName = '',
			[switch]$Notify )
	Write-Host "Setting SCCM Notification on $ComputerName..." 		
	if ( $ServerName -eq '' ) {		# ----- Run on local machine
		}
		else {						# ----- Run on remote Server
			try {
					Enable-WSManCredSSP -Role client -DelegateComputer * -force -ErrorAction SilentlyContinue | out-null
				}
				catch [System.InvalidOperationException] {
					write-host "$_.exception"
					Write-Host "`nPlease run the following powershell commands on the remote system and rerun."
					Write-Host "Enable-WSManCredSSP"
					Write-Host "Enable-PSRemoting"
					break
			}

			try {
				try {
						Write-Host "Connecting to remote Server..."
						$Session = New-Pssession -ComputerName $ComputerName -authentication Credssp -Credential $Cred -ConfigurationName "http://schemas.microsoft.com/powershell/microsoft.powershell32" -ErrorAction Stop
					}
					catch [System.Management.Automation.ActionPreferenceStopException] {
						throw $_.Exception
				}
				}
				catch [System.Management.Automation.Remoting.PSRemotingTransportException] { 
					Write-Host "You need to enter a valid username and password INCLUDING the domain name." -foregroundcolor Red
					Write-Host "Please run the script again with the correct info." -ForegroundColor red
					Write-Host "-- Or --"
					Write-Host "Please run the following powershell commands on the remote system and rerun." -ForegroundColor Green
					Write-Host "Enable-WSManCredSSP -role Server -force" -ForegroundColor Green
					Write-Host "Enable-PSRemoting -force" -ForegroundColor Green
					
					Write-Host "Press any key to continue ..."
					$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					Break
			}
			
			switch ( $Notify ) {
				$true  { $Flag = 1 }
				$false { $Flag = 0 }
			}
	
			Invoke-Command -ArgumentList $Flag -Session $Session -ErrorAction SilentlyContinue -ScriptBlock  {
				
				param ( [int]$Flag )
								
				$SWUpdates = New-Object -ComObject "UDA.CCMUpdatesDeployment"
			
				$SWUpdates.setuserexperienceflag( $Flag )
				
			}
			
			Write-Host "Press any key to continue ..."

			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			
	}
	
	
#	dim updatesDeployment
#    
#set updatesDeployment = CreateObject ("UDA.CCMUpdatesDeployment")
#updatesDeployment.SetUserExperienceFlag 1
	
	
	
}

#----------------------------------------------------------------------------
# Function Get-SCCMUpdates
#
# Lists the updates that SCCM has advertised for this computer
#----------------------------------------------------------------------------

<#
	.SYNOPSIS
		Gets a list of updates available via SCCM.
		
	.DESCRIPTION
		Gets a list of updates available via SCCM.
		
	.PARAMETER ComputerName
		Specifies the Computers FQDN
		
	.PARAMETER Cred
		Specifies the Credentials to use on the Computer.
	
	.INPUTS
		None
	
	.OUTPUTS
		List of Objects containing information of the updates available in SCCM for this computer.
		
	.EXAMPLE
		get-SCCMUpdates -ComputerName 'VBVS0018.vbgov.com' -Cred $Cred
#>


Function Get-SCCMUpdates

{
	param ( [String]$ComputerName = '.', 
			$Cred )
	
	try {
			Enable-WSManCredSSP -Role client -DelegateComputer * -force -ErrorAction SilentlyContinue | out-null
		}
		catch [System.InvalidOperationException] {
			write-host "$_.exception"
			Write-Host "Please run the following powershell commands on the remote system and rerun."
			Write-Host "Enable-WSManCredSSP -role server -force"
			Write-Host "Enable-PSRemoting -force"
	}

	try {
		try {
				Write-Host "Connecting to remote Server..."
				$Session = New-Pssession -ComputerName $ComputerName -authentication Credssp -Credential $Cred -ConfigurationName "http://schemas.microsoft.com/powershell/microsoft.powershell32" -ErrorAction Stop
			}
			catch [System.Management.Automation.ActionPreferenceStopException] {
				throw $_.Exception
		}
		}
		catch [System.Management.Automation.Remoting.PSRemotingTransportException] { 
			Write-Host "You need to enter a valid username and password INCLUDING the domain name." -foregroundcolor Red
			Write-Host "Please run the script again with the correct info." -ForegroundColor red
	}
	
	try {
			Invoke-Command -Session $Session -ErrorAction SilentlyContinue -ScriptBlock  {

				
				$SWUpdatesList = $SWUpdates.EnumerateUpdates(2,0,[Ref]0)

				$Updates = @()
				
				if ( $SWUpdatesList.getcount() -eq 0 ) {
						write-host "No Updates Found..."
					}
					else {
						write-host "Getting updates that need to be installed..."
						for ( $I = 0; $I -lt $SWUpdatesList.getcount(); $I++ ) {
							$UpdateInfo = New-Object System.object
							$Update = $SWUpdatesList.GetUpdate($I)
							$updateInfo | Add-Member -type NoteProperty -Name Name -Value $Update.getname(1033)
							$updateInfo | Add-Member -type NoteProperty -Name ID -Value $Update.getID()
							$updateInfo | Add-Member -type NoteProperty -Name EnforcementDeadline -Value $Update.getEnforcementDeadline()
							$updateInfo | Add-Member -type NoteProperty -Name BulletinID -Value $Update.getBulletinID
							$updateInfo | Add-Member -type NoteProperty -Name ArticleID -Value $Update.getArticleID()
							$updateInfo | Add-Member -type NoteProperty -Name Summary -Value $Update.getSummary(1033)
							$updateInfo | Add-Member -type NoteProperty -Name InfoLink -Value $Update.getInfoLink(1033) 
							$updateInfo | Add-Member -type NoteProperty -Name Manufacturer -Value $Update.getManufacturer(1033)
							$updateInfo | Add-Member -type NoteProperty -Name State -Value $Update.getState()
							$updateInfo | Add-Member -type NoteProperty -Name NotificationOption -Value $Update.GetNotificationOption()
							$UpdateInfo | Add-Member -type NoteProperty -Name RebootDeadline -Value $Update.GetRebootDeadline()
							
							$ProgressStage = $null
							$PercentComplete = $Null
							$ErrorCode = $Null
							$Update.GetProgress( ([ref]$ProgressStage),([ref]$PercentComplete),([ref]$ErrorCode) )
							$updateInfo | Add-Member -type NoteProperty -Name ProgressStage -Value $ProgressStage
							$updateInfo | Add-Member -type NoteProperty -Name PercentComplete -Value $PercentComplete
							$updateInfo | Add-Member -type NoteProperty -Name ErrorCode -Value $ErrorCode
											
							$Updates += $UpdateInfo
						}
				}
				Return $Updates
			}
		}
		catch [System.Management.Automation.ParameterBindingException] {
				write-host "There is an error: " -ForegroundColor Red 
				$_ | FL * -force
	}
	
	Remove-PSSession -Session $Session

	Disable-WSManCredSSP -role client
	
	Return $Updates
}

#----------------------------------------------------------------------------
# Function Install-SCCMUpdates
#
# Installs updates presented by SCCM
# http://msdn.microsoft.com/en-us/library/cc144922.aspx
#----------------------------------------------------------------------------

<#
	.SYNOPSIS
		Installs Updates presented by SCCM
		
	.DESCRIPTION
		Installs Updates presented by SCCM
		
	.PARAMETER ComputerName
		Specifies the FQDN of the computer to install updates
		
	.PARAMETER Cred
		Specifies the Credentials to use on the Computer.
		
	.PARAMETER TimeOut
		Specifies the number of minutes to wait before breaking out of the install loop.
	
	.INPUTS
		None
	
	.OUTPUTS
		None
		
	.EXAMPLE
		get-SCCMUpdates -ComputerName 'VBVS0018.vbgov.com' -Cred $Cred -TimeOut 45
		
	.LINK
		http://msdn.microsoft.com/en-us/library/cc144922.aspx
		
#>

Function Install-SCCMUpdates 

{
	Param ( [String]$ComputerName,
			$Cred,
			[Switch]$Reboot,
			$TimeOut = 30 )		# ----- Timeout in minutes
			
	write-host $TimeOut
	
	try {
			Write-Host "Installing Updates on $ComputerName..." 
			Enable-WSManCredSSP -Role client -DelegateComputer * -force -ErrorAction SilentlyContinue | out-null
		}
		catch [System.InvalidOperationException] {
			write-host "$_.exception"
			Write-Host "Please run the following powershell commands on the remote system and rerun."
			Write-Host "Enable-WSManCredSSP"
			Write-Host "Enable-PSRemoting"
	}

	try {
		try {
				Write-Host "Connecting to remote Server..."
				$Session = New-Pssession -ComputerName $ComputerName -authentication Credssp -Credential $Cred -ConfigurationName "http://schemas.microsoft.com/powershell/microsoft.powershell32" -ErrorAction Stop
			}
			catch [System.Management.Automation.ActionPreferenceStopException] {
				throw $_.Exception
		}
		}
		catch [System.Management.Automation.Remoting.PSRemotingTransportException] { 
			Write-Host "You need to enter a valid username and password INCLUDING the domain name." -foregroundcolor Red
			Write-Host "Please run the script again with the correct info." -ForegroundColor red
			Write-Host "-- Or --"
			Write-Host "Please run the following powershell commands on the remote system and rerun." -ForegroundColor Green
			Write-Host "Enable-WSManCredSSP -role Server -force" -ForegroundColor Green
			Write-Host "Enable-PSRemoting -force" -ForegroundColor Green
			Break
	}
	
	try {
			$RebootNeeded = Invoke-Command -ArgumentList $TimeOut -Session $Session -ErrorAction SilentlyContinue -ScriptBlock  {
				
				param ( $TimeOut )
				
				$Progress = $Null
				$RebootNeeded = $False
				$UpdatesDeployment = New-Object -ComObject "UDA.CCMUpdatesDeployment"
				# ----- Get the current updates
				$UpdatesColl = $UpdatesDeployment.EnumerateUpdates(2,0,[ref]$Progress)
				# ----- Get a count of the available updates
				$UpdateCount = $UpdatesColl.getcount()
				
				Write-Host "Progress: $Progress"
				if (( $Progress -eq 0 ) -or ($Progress -eq $Null)) {  
						if (  $UpdateCount -gt 0 ) { 	# ----- Updates still to install
								$UpdatesList = @()		# ----- Array to hold the update IDs
								$list = @()
								$AllInstalled = @()
								
								# ----- Get list of update IDs
								for ( $I = 0; $I -le $UpdateCount - 1; $I++ ) {
									$Update = $UpdatesColl.GetUpdate($I)
									# ----- Check the install status of the update
									$ProgressStage = $PercentComplete = $ErrorCode = $Null
									$Update.GetProgress( [ref]$ProgressStage,[ref]$PercentComplete,[ref]$ErrorCode )
#									Write-Host  $ProgressStage $Update.getname(1033)
									$AllInstalled += $False

									switch ( $ProgressStage ) {
										0 		{ $UpdatesList += $Update.GetID() }		# ----- State None
										1		{ $UpdatesList += $Update.GetID() }     # ----- State Available
										10		{ $RebootNeeded = $true }				# ----- Reboot Needed
										default { Write-Host "Progess Stage Unknown --> $ProgressStage" -ForegroundColor Cyan }
									}
								}
								
								if ( -not $RebootNeeded ) { 
								
									# ----- Download and Install the updates
									Write-Host "Installing Updates if needed...."
									$UpdatesDeployment.InstallUpdates( $UpdatesList,0,1)
									
									# ----- Check progress of installs and if done reboot
									# ----- http://msdn.microsoft.com/en-us/library/cc143125.aspx
									Write-Host "Waiting for updates to complete..." -NoNewline
									$NumUpdatesDone = 0
									
									$TimeOutCount = 0
									
#									for ( $I = 0; $I -le $Updateslist.count - 1; $I++ ) {
#										Write-Host $AllInstalled[$I]
#									}
									
									do {
										for ( $I = 0; $I -le $Updateslist.count - 1; $I++ ) {
											
											$Update = $UpdatesColl.GetUpdate($I)
											# ----- Check the install status of the update
											$ProgressStage = $PercentComplete = $ErrorCode = $Null
											$Update.GetProgress( [ref]$ProgressStage,[ref]$PercentComplete,[ref]$ErrorCode )
											
#											Write-Host  $ProgressStage $AllInstalled[$I] $Update.getname(1033)
											
											
											if ( $ProgressStage -gt 8 ) { # ----- Update install is not complete if 8 or less
												$AllInstalled[$I] = $True
											}
											
										}
										# ----- wait 60 seconds
										Start-Sleep -Seconds 60
										Write-Host "." -NoNewline
										$TimeOutCount += 1
#										Write-Host "----- TimeOut = $TimeOutCount" 
										# ----- Check to see if all Updates are installed
										$InstallCompleted = $True
#										$I = 0
										$AllInstalled | foreach {
											
#											Write-Host "$I -- $_"
											if ( $_ -eq $false ) {
												$InstallCompleted = $false
											}
#											++$I
										}
#										Write-Host "Install Completed?: $InstallCompleted"
										
									} while ( (-not $InstallCompleted ) -and ($TimeOutCount -le $TimeOut ) )
									Write-Host "`nAll installed -- waiting on reboot"
									$RebootNeeded = $True
								}
							}
							Else {						# ----- No more updates to install
								Write-Host "No updates need to be installed"
						}
					}
					else {					# ------ Another Installation is in progress
						Write-Host "Another Update Installation is in Progress"
				}
				
				if ( -not $Reboot ) {Return $RebootNeeded} 		# ----- Check Reboot Switch,  If false return to calling function.  If True continue with reboot script
			} 
		}
		catch [System.Management.Automation.ParameterBindingException] {
				write-host "There is an error: " -ForegroundColor Red 
				$_ | FL * -force
	}
		
	# ----- Reboot Server 
	Remove-PSSession $Session
	
	Disable-WSManCredSSP -role client
	
	if ( $RebootNeeded ) {								
		Write-Host "Restarting Computer..." -ForegroundColor Red
		# ----- Set computer in maint mode in SCOM
		set-SCOMMaintenanceMode -ComputerPrincipalName $ComputerName -NumberOfHoursInMaintenanceMode 20 -Comment "Patching and Hotfixes"
		
		try {
				try {
						Restart-Computer $ComputerName -ErrorAction Stop
					}
					catch [System.Management.Automation.ActionPreferenceStopException] {
						throw $_.Exception
				}	
			}
			catch [System.InvalidOperationException] {
				Write-Host "The system shutdown cannot be initiated on $ComputerName because there are other users logged on to the computer." -ForegroundColor Red
				Write-Host "Forcing $Computername to restart.  You will have to Confirm."
				try {
						Try {
								Restart-Computer -ComputerName $ComputerName -Force -Confirm -ErrorAction Stop
							}
							catch {
								throw $_.Exception
						}
					}
					Catch {
						Write-Host "Error:" -ForegroundColor Red
						"$_.Exception"
						$_.FullyQualifiedErrorID
						$_.Exception.gettype().Fullname
						"----"
						$_ | FL *
				}
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

#-------------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------------

# ----- Requires the SCOMPSModule.psm1 be loaded.
# ----- Check to see if SCOMPSModule is loaded
if (-not(Get-Module SCOMPSModule)) {
	Write-Host "Importing SCOMPSModule..."
	Import-Module -Name "\\vbgov.com\deploy\Disaster_Recovery\SCOM\Scripts\SCOMPSModule\SCOMPSModule.psm1" -argumentlist 'vbas022', $Debug
}

# ----- Requires Admin Credentials
Write-Host "These are the credentials needed on the remote system..." -ForegroundColor Yellow
$global:Cred = get-credential

Export-ModuleMember -Function get-SCCMUpdates, Install-SCCMUpdates, Show-SCCMNotifications
