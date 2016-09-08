get-vmmserver vbas0080 | Out-Null

$VM = Get-VM vbas0120

$NICs = $VM.VirtualNetworkAdapters
$NIC.EthernetAddress
	foreach ( $Nic in $Nics ) {
		$VMMAC = $NIC.EthernetAddress
	}

$VMCount = 0

$VMs = Get-VM
foreach( $VM in $VMs ) {
	$VM.Name
	$VMCount++
	$Nics = $VM.VirtualNetworkAdapters
	foreach ( $Nic in $Nics ) {
		if ( $NIC.EthernetAddress -ne $VMMAC ) {
				Write-Host "No match" 
			}
			Else {
				Write-Host "Match" -ForegroundColor Red 
		}
	}
}
$VMCount