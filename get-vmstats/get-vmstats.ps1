# Get-VMStats.ps1
# Gets the statistics about VMs.  HDD max size and actual size, etc.
#------------------------------------------------------------------------------

function Get-VMCount( $Server )
# Returns the number of VM's on the specified server.  If $Server is Null then return 
#     number of all VM's 

{
    if ( $Server -eq $null ) {
	        get-vm -vmmserver "vmas9072" | foreach { $Count = $Count +1 }
		}
		else {
		    get-vm -vmmserver "vmas9072" | where { $_.hostname -eq $Server } | foreach { $Count = $Count +1 }
	}
	Return $Count
}

#------------------------------------------------------------------------------


$NumVHD = 0
$TotalMaxSize = 0
$TotalCurrentSize = 0

$NumVM = Get-VMCount 


get-vm -vmmserver "vmas9072" | get-virtualharddisk | foreach {
    $_.parent.name
	$_.maximumsize
	$_.Size
	
	$NumVHD = $NumVHD + 1
	$TotalMaxSize = $TotalMaxSize + $_.maximumsize
	$TotalCurrentSize = $TotalCurrentSize + $_.Size
}

$TotalMaxSize = $TotalMaxSize / 1024 / 1024 /1024
$TotalCurrentSize = $TotalCurrentSize / 1024 / 1024 / 1024
$AVGMax = $TotalMaxSize / $NumVM
$AVGCurrntSize = $TotalCurrentSize / $NumVM

"There are $NumVM Virtual Hard Disks"
"They potentially could use $TotalMaxSize GB"
"They currently are using $TotalCurrentSize GB"
""
"Avg Max = $AVGMax              Avg Current size = $AVGCurrntSize"


