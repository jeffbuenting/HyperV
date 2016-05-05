
Get-vmmserver "vmas9072"

get-vm | where { $_.virtualizationplatform -eq "HyperV" } | foreach {



	$strComputer = $_.name
	
	
	GWMI -cl "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $strComputer -filter "IpEnabled = TRUE" | format-table macaddress | Export-Csv c:\temp\mac1.csv
}	
	
#	$colItems = GWMI -cl "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $strComputer -filter "IpEnabled = TRUE"
#	
#	
#	
#	ForEach ($objItem in $colItems) {
##		$strComputer, $objItem.MacAddress
#
#		
#	}
#}