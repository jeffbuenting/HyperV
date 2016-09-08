#------------------------------------------------------------------------------
# Configure-HVHost
#
# After installing OS run this script to configure the OS with necessary apps configurations
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Get-InstalledAppliations
#
# Reads the installed applications via the registry
#------------------------------------------------------------------------------

function Get-InstalledApplications

{
	$computername = '.'
	
	$array = @()
     
	
    # ----- Define the variable to hold the location of Currently Installed Programs
    $UninstallKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 
 
    # ----- Create an instance of the Registry Object and open the HKLM base key
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername) 
 
    # ----- Drill down into the Uninstall key using the OpenSubKey Method
     $regkey=$reg.OpenSubKey($UninstallKey) 
 
    # ----- Retrieve an array of string that contain all the subkey names
    $subkeys=$regkey.GetSubKeyNames() 
 
    # ----- Open each Subkey and use GetValue Method to return the required values for each
    foreach($key in $subkeys){
        $thisKey=$UninstallKey+"\\"+$key 
        $thisSubKey=$reg.OpenSubKey($thisKey) 
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $computername
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
        $obj | Add-Member -MemberType NoteProperty -Name "InstallLocation" -Value $($thisSubKey.GetValue("InstallLocation"))
        $obj | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))
		
		$array += $obj
    } 
	 

	return $array 
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

Clear-host

Write-Host "Configuring Windows Features... " -ForegroundColor Green

# ----- Enable SNMP
Import-Module servermanager
add-windowsfeature SNMP-Service

# ----- Enable Fail Over clustering Feature
add-windowsfeature Failover-clustering

# ----- Configure WINRM
set-wsmanquickconfig -force

Write-Host "Configuring Local Group membership..." -ForegroundColor Green

# ----- Create Temp Directory

if ( (Test-Path "C:\Temp") -eq $False ) {
	Write-Host "Creating Temp Directory..." -ForegroundColor Green
	Set-Location c:\ 
	New-Item -name temp -ItemType directory -ErrorAction SilentlyContinue
}

$PSP = Get-InstalledApplications


$PSPInstalled = $False
foreach ( $App in $PSP ) {
	if ( $App.DisplayName -eq 'HP Insight Management Agents' ) { $PSPInstalled = $true } 
}



if ( $PSPInstalled ) {
		Write-Host "PSP already installed..." -ForegroundColor green
	}
	else {
		Write-Host "Installing PSP..." -ForegroundColor green
		
		Copy-Item '\\vbgov.com\deploy\OS Servers\apps\HP\PSP\8.7-x64' 'c:\temp' -recurse -force
		'c:\Temp\8.7-x64\hpsum.exe /express_install'
		Write-Host "Press any key to continue after PSP installation has completed..."

		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ----- Configure NICs

Import-Module '\\vbgov.com\deploy\Disaster_Recovery\Powershell\Modules\Input\input.psm1'
Import-Module '\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\HyperV\HyperV.psd1'

$NICS = gwmi win32_networkadapter -Filter "PhysicalAdapter='true'" 

switch ( $NICs.Count ) {
	2	{		# ----- Cisco Switch enclosure
			Write-Host "Configuring second NIC in a two NIC setup..." -ForegroundColor green
			foreach ( $NIC in $NICS ) {
				$NICConfig = gwmi win32_networkadapterconfiguration | where { $_.InterfaceIndex -eq $NIC.InterfaceIndex }
				
				if ( $NICConfig.DNSDomain -eq 'VBGOV.COM' ) { 
						$NIC.NetConnectionID = "H-V Mgmt-922" 
					}
					else {
						
						$IPAddress = Get-InputWindow ( "Input IP Address for ISCSI NIC: " )	
						$NIC.NetConnectionID = "Virtual Switch Trunk 01"
						$NICConfig.enablestatic( $IPAddress, '255.255.255.0' )
						if ( $NICConfig.TCPIPNetbiosOptions -ne 2 ) {
							$NICConfig.SetTCPIPNetBios(2) |out-null
							$NICConfig.SetDynamicDNSRegistration($false) | out-null
						}
						# ----- Configure Hyper-V switch
						New-VMExternalSwitch -virtualSwitchName 'Virtual Switch 01' -ExterrnalEthernet $NICConfig.Description -force
				}
			}
		}
	8	{		# ----- Virtual Connect Switch Enclosure
			Write-Host "Configuring other NICs in an eight NIC setup..." -ForegroundColor green
		}
	Default {
			Write-Host "ERROR - Unknown number of NICs.  Does not match standard Hardware Configuration for Hyper-V" -ForegroundColor Red
			Break
		}
}

# ----- Install SCCM Client Agent ---------------------------------------------------
Write-Host "Installing SCCM Client Agent....." -ForegroundColor Green
$job = Start-Job {  & "\\vbas0076\SMS_CVB\Client\ccmsetup.exe" } 
Wait-Job $job

## ----- Installing McCrappy EPO Agent
#Write-Host "Installing McCrappy EPO Agent....."
#& "\\vbgov.com\deploy\Disaster_Recovery\McAfee_AntiVirus\EPOAgent\FramePkg.exe"
#Write-Host "Email Shawn so he can config EPO correctly on server.  Go ahead, I'll Wait ...." -ForegroundColor green
#Write-Host "Press any key when the Email has been sent" 
#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ----- Install HP Application Aware Snapshot
Copy-Item '\\vbgov.com\deploy\Disaster_Recovery\HP LeftHand SAN\Software\SANiQ9.5\HP_Application_Aware_Snapshot_Installer_9.5.0.1004_P25020.exe' 'c:\temp'
'c:\Temp\HP_Application_Aware_Snapshot_Installer_9.5.0.1004_P25020.exe'
Write-Host "Press any key to continue after HP Application Aware Snapshot installation has completed..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ----- Install HP DSM
Copy-Item '\\vbgov.com\deploy\Disaster_Recovery\HP LeftHand SAN\Software\SANiQ9.5\HP_DSM_Installer_9.5.0.981.exe' 'c:\temp'
'c:\Temp\HP_DSM_Installer_9.5.0.981.exe'
Write-Host "Press any key to continue after HP DSM installation has completed..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ----- Install Hotfixes
'\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Patches\Host\install-hotfixes.ps1'

# ----- Reboot

Restart-Computer 

#---------------------------------------------------------------------------------------

# ----- Configure NIC Teaming

#An excerpt from the HP Networking Utilities User Guide: (h20331.www2.hp.com/.../c00752571.pdf)
#
#Step 1. Generate a script file on the source server by clicking Save in the HP Network
#Configuration Utility user interface, or by selecting CQNICCMD /S in the Command Line
#utility.
#
#Step 2. Modify the script file as necessary.
#NOTE If you modify the script file, HP recommends that you run CQNICCMD /P to check the
#syntax of the modified file and check the log file for errors and warnings. The default
#location of the log file is \cpqsystem\log\cpqteam.log on the system drive. The
#syntax of the /P option is: cqniccmd /pfilename.
#
#Step 3. Install the HP Network Configuration utility on the target system.
#
#Step 4. Run the Command Line utility with the following syntax:
#cqniccmd /C <pathname>
#
#Step 5. Check the log file for errors and warnings. The default location of the log file is
#\cpqsystem\log\cpqteam.log on the system drive. 



