Import-Module '\\vbgov.com\deploy\Disaster_Recovery\Powershell\Modules\Input\input.psm1'

$NICS = gwmi win32_networkadapter -Filter "PhysicalAdapter='true'" 


switch ( $NICs.Count ) {
	2	{		# ----- Cisco Switch enclosure
			foreach ( $NIC in $NICS ) {
				$NICConfig = gwmi win32_networkadapterconfiguration | where { $_.InterfaceIndex -eq $NIC.InterfaceIndex }
				
				if ( $NICConfig.DNSDomain -eq 'VBGOV.COM' ) { 
						$NICConfig.NetConnectionID = "H-V Mgmt-922" 
					}
					else {
						
						$IPAddress = Get-InputWindow ( "Input IP Address for ISCSI NIC: " )	
						$NICConfig.NetConnectionID = "ISCSI - 911"
						$NICConfig.enablestatic( $IPAddress, '255.255.255.0' )
						if ( $NICConfig.TCPIPNetbiosOptions -ne 2 ) {
							$NICConfig.SetTCPIPNetBios(2) |out-null
							$NICConfig.SetDynamicDNSRegistration($false) | out-null
						}
				}
			}
		}
	8	{		# ----- Virtual Connect Switch Enclosure
		}
	Default {
			Write-Host "ERROR - Unknown number of NICs.  Does not match standard Hardware Configuration for Hyper-V" -ForegroundColor Red
			Break
		}
}
	
			
