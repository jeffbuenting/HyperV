


get-vmmserver vmas0080 | out-null

$Hosts = get-vmhost | where {$_.virtualizationPlatformString -eq "Microsoft Hyper-V" } | sort name
foreach( $H in $Hosts ) {
    $H.name 
	get-vm -vmhost $H | Select-Object name, description | sort name
	"----------------"
}