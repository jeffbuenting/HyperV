Function Get-IP

{
	Param ( $ServerName,			# ----- ServerName to get the IP addresses from
			$Version = 'All' )		# ----- Which IPs to get ALL = All, IPv4, IPv6
	
	# Get Networking Adapter Configuration  
	$IPconfigset = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $ServerName
	    
	# Iterate and get IP address  
  
	$IPs = @()
	foreach ($IPConfig in $IPConfigSet) {  
	   if ($Ipconfig.IPaddress) {  
	      $I=0
		  foreach ( $Addr in $IPConfig.IPaddress ) {
			
		  	$IPAddy = New-Object system.object
	      	$IPAddy | Add-Member -type NoteProperty -Name Address -Value $Addr
			$IPAddy | Add-Member -type NoteProperty -Name Subnet -Value $IPConfig.IPSubnet[$I]
			
			$IPs += $IPAddy
			$I++
	      }  
	   }  
	}  
	
	$IP = @()
	Switch ( $Version.toupper() ) {
		'IPV4' {
				foreach ( $IPAddy in $IPs ) {
					if ( $IPAddy.Address -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" ) { $IP += $IPAddy }
				}
			}
		'IPV6' {
				foreach ( $IPAddy in $IPs ) {
					if ( $IPAddy.Address -match "[A-F0-9:]*" ) { $IP += $IPAddy }
				}
			}
		'ALL' { $IP = $IPs }
		default { $IP = $IPs }
	}
		
	Return $IP
}
#---------------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------------

import-module activedirectory

#$Cred = Get-Credential

$Servers = @()
Get-ADComputer -LDAPFilter "(name=VBVS*)" | foreach {
	$Servers += $_.Name
}


$ServerInfo = @()

foreach ( $S in $Servers ) {

	$SInfo = New-Object system.Object
	$SInfo | Add-Member -type NoteProperty -Name Server -Value $S
	$SInfo | Add-Member -type NoteProperty -Name Status -Value "In Service"
	($S).substring(4,1)
	Switch (($S).substring(4,1) ) {
		0 { $SInfo | Add-Member -type NoteProperty -Name Tier -Value "Prod" }
		1 { $SInfo | Add-Member -type NoteProperty -Name Tier -Value "Prod" }
		8 { $SInfo | Add-Member -type NoteProperty -Name Tier -Value "Dev" }
		9 { $SInfo | Add-Member -type NoteProperty -Name Tier -Value "Test" }
	}
	$SInfo | Add-Member -type NoteProperty -Name Network -Value "Public"
	$SInfo | Add-Member -type NoteProperty -Name WindowsDomain -Value "Extranet"
	
	$OS = gwmi Win32_OperatingSystem -computer $S
	$OS.caption
	switch ( $OS.caption ) {
		'Microsoft(R) Windows(R) Server 2003 Standard x64 Edition' { 
				$SInfo | Add-Member -type NoteProperty -Name OS -Value "2003 x64" 
				$SInfo | Add-Member -type NoteProperty -Name WindowsVersion -Value "Server Standard"
			}
		'Microsoft(R) Windows(R) Server 2003, Standard Edition' {
				$SInfo | Add-Member -type NoteProperty -Name OS -Value "2003" 
				$SInfo | Add-Member -type NoteProperty -Name WindowsVersion -Value "Server Standard"
			}
		'Microsoft(R) Windows(R) Server 2003, Enterprise Edition' {
				$SInfo | Add-Member -type NoteProperty -Name OS -Value "2003" 
				$SInfo | Add-Member -type NoteProperty -Name WindowsVersion -Value "Server Advanced/Enterprise"
			}
		'Microsoft Windows Server 2008 R2 Enterprise' {
				$SInfo | Add-Member -type NoteProperty -Name OS -Value "2008 R2 x64" 
				$SInfo | Add-Member -type NoteProperty -Name WindowsVersion -Value "Server Advanced/Enterprise"
			}
		'Microsoft Windows Server 2008 R2 Standard' {
				$SInfo | Add-Member -type NoteProperty -Name OS -Value "2008 R2 x64" 
				$SInfo | Add-Member -type NoteProperty -Name WindowsVersion -Value "Server Standard"
			}			
	
	switch ( $OS.ServicePackMajorVersion ) {
		1 { $SInfo | Add-Member -type NoteProperty -Name OSServicePack -Value "SP1" }
		2 { $SInfo | Add-Member -type NoteProperty -Name OSServicePack -Value "SP2" }
	}
	
	$IP = @()
	$IP = $Null
	get-IP $S 'IPv4' | foreach { 
		if ( $IP -eq $Null ) { 
				$IP += $_.Address + '/' + $_.Subnet
			}
			else {
				$IP += ', '+ $_.Address + '/' + $_.Subnet
		}
	}
	
	$SInfo | Add-Member -type NoteProperty -Name IPPrimary -Value $IP
	$RAM = [Math]::round(((Get-WmiObject -Class Win32_ComputerSystem).totalPhysicalMemory)/1GB)
	$SInfo | Add-Member -type NoteProperty -Name RAM -Value $RAM 
	
	$SInfo | Add-Member -type NoteProperty -Name Virtual -Value '1'
			
	$ServerInfo += $SInfo
}
$ServerInfo

$ServerInfo | Export-Csv c:\temp\ServerInfo.csv


