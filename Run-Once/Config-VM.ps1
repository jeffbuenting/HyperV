#-----------------------------------------------------------------------------------
# Config-VM
#
# Runs automatically when first Admin logs onto VM to configure system.
#-----------------------------------------------------------------------------------

param ( [String]$ComputerName = 'Empty',		# ----- Contains a name if running remotely
		[Bool]$Debug = $False )			# ----- Debug Var Set to true if debuggins script

#-------------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------------

if ( $Debug -eq $true ) {
	Write-Host "Beginning Script Config-VM.ps1"
	Write-Host "  ComputerName = $ComputerName"
	Write-Host "  Debug = $Debug"
}
	
if ( $ComputerName -eq 'Empty' ) {
	# ----- Get name of computer the Script is running on
	$ComputerName = GC env:computername
}

Clear-host

 
 
 
# ----- Set IP
Write-Host "Set the IPs on the Server.  Go ahead, I'll Wait ...." -ForegroundColor green
Write-Host "Press any key when the IPs are set" 
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "Add AD groups to local groups..." -ForegroundColor Green
import-module '\\vbgov.com\deploy\Disaster_Recovery\ActiveDirectory\Scripts\LocalUsersAndComputersModule\LocalUsersAndComputersModule'

# ----- Add Server Local Admin-U group to the Local Administrators Group
$LocalAdmins = Get-LocalGroupMember 'Administrators'
if ( $LocalAdmins  -cnotcontains "Server Local Admins-U" ) {   	# ----- Add the group 
	Add-LocalGroupMember -ADGroup 'Server Local Admins-U' -localgroup 'Administrators'
}

# ----- Add COMIT Operations DataCenter Group to the Local Remote Desktop Group
$LocalRemoteDesktop = Get-LocalGroupMember 'Remote Desktop Users'
if ( $LocalRemoteDesktop  -cnotcontains "COMIT Operations Support data Center-U" ) {   	# ----- Add the group 
	Add-LocalGroupMember -ADGroup 'COMIT Operations Support data Center-U' -localgroup 'Remote Desktop Users'
}

# ----- Add COMIT Operations Server Shutdown-U Group to the Local Power Users Group
$LocalPowerUsers = Get-LocalGroupMember 'Power Users'
if ( $LocalRemoteDesktop  -cnotcontains "COMIT Operations Support data Center-U" ) {   	# ----- Add the group 
	Add-LocalGroupMember -ADGroup 'Comit Operations Server Shutdown-U' -localgroup 'Power Users'
}

# ----- Create Temp Directory
Write-Host "Creating Temp Directory..." -ForegroundColor Green
if ( (Test-Path "C:\Temp") -eq $False ) {
	Set-Location c:\ 
	New-Item -name temp -ItemType directory -ErrorAction SilentlyContinue
	Write-Host "Rebooting the computer so changes take affect.  Rerun this command after reboot" -foreground cyan
#	Restart-Computer -Confirm
#	break
}

# ----- Install SCCM Client Agent ---------------------------------------------------
Write-Host "Installing SCCM Client Agent....." -ForegroundColor Green
$job = Start-Job {  & "\\vbas0076\SMS_CVB\Client\ccmsetup.exe" } 
Wait-Job $job

# ----- Add required windows Roles / Features --------------------------------------

Write-Host "Adding standard Roles / Features..." -ForegroundColor Green

set-wsmanquickconfig -force

# ----- Installing McCrappy EPO Agent
Write-Host "Installing McCrappy EPO Agent....."
& "\\vbgov.com\deploy\Disaster_Recovery\McAfee_AntiVirus\EPOAgent\FramePkg.exe"
Write-Host "Email Shawn so he can config EPO correctly on server.  Go ahead, I'll Wait ...." -ForegroundColor green
Write-Host "Press any key when the Email has been sent" 
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ----- Configure Time Sync Integrated Components
set-service -Name VMICTIMESYNC -StartupType Disabled -Status Stopped
Set-Service -Name W32Time -Status Stopped
Set-Service -Name W32Time -Status Running

# ----- Get OS Version
Write-Host "Loading OS Specific hotfixes and featurs ..." -ForegroundColor Green
$OS = Gwmi Win32_OperatingSystem 
$OS
$OS.Caption

switch -regex ( $OS.Caption ) {
	'Microsoft Windows Server 2008 R2 Enterprise' { 
		Write-Host "$OS.Caption" -foregroundcolor yellow

		
		# ----- Install Required Hotfixes
		Write-Host "Installing HotFixes..." -ForegroundColor green
		$Command = '\\vbgov.com\deploy\OS Servers\Patches\W2k8R2 Hotfixes\KB2470949 - Avg Disk sec per transfer very high and incorrect\Windows6.1-KB2470949-v2-x64.msu'
		Copy-Item $Command c:\temp
		$HFCMD = "c:\temp\Windows6.1-KB2470949-v2-x64 /quiet /norestart"
		$CMD = Start-Process -FilePath 'c:\Windows\System32\wusa.exe' -ArgumentList $HFCMD -passthru
		do{}until ($CMD.HasExited -eq $true)
		$ExitCode = $CMD.GetType().GetField("exitCode", "NonPublic,Instance").GetValue($CMD)
		
		Switch ( $ExitCode ) {
			0			{ 
					Write-Host "Done"
					$Reboot = $True
				}
			2			{ $CMD }
			3			{ Write-Host "This update applies to a ROLE or Feature that is not installed on this computer" -ForegroundColor Yellow }
			3010		{ Write-Host "Hotfix for Windows is already installed on this computer." -ForegroundColor Yellow }
			-2145124329 { Write-Host "The Update is not applicable to your computer" -ForegroundColor Yellow }
			-2145124330 { Write-Host "Another Install is underway.  Please wait for that one to complete and restart this one." -ForegroundColor Yellow } 
			default 	{ Write-Host "Unknown Exit Code --> $ExitCode" -ForegroundColor Magenta }
		}

	}
	'Microsoft Windows Server 2008 R2 Standard' { 
		Write-Host "$OS.Caption"
		
		# ----- Install Required Hotfixes
		Write-Host "Installing HotFixes..." -ForegroundColor green
		$Command = '\\vbgov.com\deploy\OS Servers\Patches\W2k8R2 Hotfixes\KB2470949 - Avg Disk sec per transfer very high and incorrect\Windows6.1-KB2470949-v2-x64.msu'
		Copy-Item $Command c:\temp
		$HFCMD = "c:\temp\Windows6.1-KB2470949-v2-x64 /quiet /norestart"
		$CMD = Start-Process -FilePath 'c:\Windows\System32\wusa.exe' -ArgumentList $HFCMD -passthru
		do{}until ($CMD.HasExited -eq $true)
		$ExitCode = $CMD.GetType().GetField("exitCode", "NonPublic,Instance").GetValue($CMD)
		
		Switch ( $ExitCode ) {
			0			{ 
					Write-Host "Done"
					$Reboot = $True
				}
			3			{ Write-Host "This update applies to a ROLE or Feature that is not installed on this computer" -ForegroundColor Yellow }
			3010		{ Write-Host "Hotfix for Windows is already installed on this computer." -ForegroundColor Yellow }
			-2145124329 { Write-Host "The Update is not applicable to your computer" -ForegroundColor Yellow }
			-2145124330 { Write-Host "Another Install is underway.  Please wait for that one to complete and restart this one." -ForegroundColor Yellow } 
			default 	{ Write-Host "Unknown Exit Code --> $ExitCode" -ForegroundColor Magenta }
		}

	}
	'Microsoftr Windows Serverr 2008 Enterprise' {
		Write-Host "$OS.Caption"
	}
	Default { Write-Host "OS unknown:" $OS.Version  $OS.caption $OS.name-ForegroundColor Magenta }
}

#-------------------------------------------------------------------------------
# Configure the server depending on its purpose
#-------------------------------------------------------------------------------

Write-Host 'Configuring Server Depending on type...' -ForegroundColor Green
$ComputerName
switch -regex ( $ComputerName ) {
	'vbdb/d{4}' {
			Write-Host "Configuring Server as Database Server" -ForegroundColor DarkCyan
			
			Import-Module activedirectory
			
			# ----- Creating group in ad for DB local Admin
			$Servers = Get-ADComputer -Filter { dnshostname -eq $ComputerName }
			
			
		}
	'cvb' {
			Write-Host "$ComputerName -- Server is a workstation.  Double Check name..." -ForegroundColor Red
			# ----- Creating group in ad for DB local Admin
			$Servers = Get-ADComputer -Filter { Name -eq $ComputerName }
			$ObjectPath = ($Servers.DistinguishedName).Substring($ComputerName.length+4)
			$GroupName = "$ComputerName Local Admins-U"
			Try {
					$Group = New-ADGroup -Path $ObjectPath -Name $GroupName -GroupScope Universal -Credential $Cred
				}
				Catch {
					Write-Host "Username or Password is incorrect...." -ForegroundColor Red
					Break
			}
#			$DBAGroup = $group = Get-ADGroup "CN=COMIT Database Admins-U,OU=User Groups,OU=Unmanaged,DC=VBGOV,DC=COM"
#			Add-ADGroupMember -Identity $Group -member $DBAGroup -Credential $Cred
#			
#			
						break
		}
	default {
			Write-Host "Unknown Server Name... $ComputerName"	-ForegroundColor Red
			break
		}
}


