#-----------------------------------------------------------------------------------
# Config-WIN2008
#
# Runs automatically when first Admin logs onto VM to configure system.
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
# function to spefify settings for a NIC based on the name of the NIC
#-----------------------------------------------------------------------------------

function Set-IPAddress { 
 	param(  [string]$networkinterface,[string]$ip,[string]$mask, [string]$gateway, [string]$registerDns = "TRUE" )  
 
	$index = (gwmi Win32_NetworkAdapter | where {$_.netconnectionid -eq $networkinterface}).DeviceID 	
	
	$DNS = "10.100.8.18","10.100.12.18","10.100.30.2","10.100.8.76","10.205.110.5"
	
	$NetInterface = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter “Index=$index"
	
	$NetInterface.EnableStatic($ip, $mask)
	$NetInterface.SetGateways($gateway)
	$NetInterface.SetDNSServerSearchOrder($DNS)
	$NetInterface.SetDynamicDNSRegistration($registerDns)
	$NetInterface.SetWINSServer( "10.100.4.11","10.100.8.11" )
	
}

#-------------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------------

# ----- Set IP -----------------------------------------------------------------------
Write-Host "Setting IP Address...."

# -- Enumerate NICs installed on Server
$NICS = gwmi Win32_NetworkAdapter
Write-Host "Device ID  Device Name"
Write-Host
foreach ($N in $NICS ) {
	if ( $N.netconnectionID -ne $null ){
		write-host $N.DeviceID "         " $N.netconnectionID
	}
}

Write-host " "

$DevID = Read-Host "Enter the Device ID for the Network connection to configure: "

$Networkinterface = $NICS[ $DevID ].netconnectionID
$StaticIP = read-host "Static IP for this server: "
$Subnet = Read-Host "Subnet for this Server: "
$Dgateway = Read-Host "Default Gateway for this server: "
Set-IPAddress $Networkinterface $StaticIP $Subnet $DGateway

# ----- Create Temp Directory -------------------------------------------------------

mkdir c:\temp

# ----- Install Netbackup 7.0 -----------------------------------------------
Write-Host "Installing Netbackup 7.0....."
& "\\vbas0080\VMMLibrary\Script Library\Production\NetBackup\Client 7.0 x32\silentclient.cmd"


# ----- Install SCCM Client Agent ---------------------------------------------------
Write-Host "Installing SCCM Client Agent....."
& "\\vbas0076\SMS_CVB\Client\ccmsetup.exe"


# ----- Push SCOM agent to this Server ----------------------------------------------

## ----- Add required windows Roles / Features --------------------------------------
#
#Write-Host "Adding standard Roles / Features..."
#


# ----- Setup WinRM ----------------------------------------------------------------

winrm qc

