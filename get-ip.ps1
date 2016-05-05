

$Servers = Get-VMHost -VMMServer vbas0080

foreach ( $Server in $Servers) {
	Write-Host $Server -ForegroundColor cyan
	$ServerName = $Server
	
		Get-WmiObject -class Win32_NetworkAdapterConfiguration -ComputerName $serverName | foreach {
#			Get-WmiObject -class Win32_NetworkAdapterConfiguration -ComputerName $serverName
		
	 	foreach ( $IP in $_.IPAddress ) {
			if ( $IP -ne $null ) {
					if ( $IP.contains( "10.100.39") ) {
							$IP
							$_.IPSubnet
					
				}
			}
		}
	}
}
	