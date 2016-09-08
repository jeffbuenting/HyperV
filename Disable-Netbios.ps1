#------------------------------------------------------------------------------
# Disable-NetBios.ps1
#
#	Disables the NetBIOS and Unchecks the DNS registration of all ISCSI NICs on Hyper-V servers
#------------------------------------------------------------------------------

$Servers = Get-QADComputer -searchroot 'ou=servers virtual host,dc=vbgov,dc=com'

foreach ( $Server in $Servers) {
	$ServerName = $Server.Name
	
	# ----- Determine which NIC has an IP in the range 10.100.20.x
	Get-WmiObject -class Win32_NetworkAdapterConfiguration -ComputerName $serverName | foreach {
	 	foreach ( $IP in $_.IPAddress ) {
			if ( $IP -ne $null ) {
					if ( $IP.contains( "10.100.20") ) {
					$NIC = $_
				}
			}
		}
	}
	# ----- Check if Netbios is Disabled
	# ----- 0 (0x0) Enable Netbios via DHCP
	# ----- 1 (0x1) Enable Netbios
	# ----- 2 (0x2) Disable Netbios

	if ( $NIC.TCPIPNetbiosOptions -ne 2 ) {
			Write-Host "Disabling Netbios on $ServerName" -ForegroundColor red
			$NIC.SetTCPIPNetBios(2) |out-null
			$NIC.SetDynamicDNSRegistration($false) | out-null
	 	}
		Else {
			Write-Host "Netbios already disabled on $ServerName" -ForegroundColor green
	}
}
