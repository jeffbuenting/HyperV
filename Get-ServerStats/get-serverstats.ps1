#$List.name = "vbvs0001"

$Cred = Get-credential "vbgov.com\jbuentinda"

$ServerCount
$HDDCount
$NoInfo
$HDDSize

$List = get-QADComputer -SearchRoot 'vbgov.com/Servers Test'
Foreach ( $Computer in $List ) {
 	"----",$computer.name
    #Check if server is virtual
	$HW = Get-WmiObject "Win32_BaseBoard" -Namespace "Root/CIMV2" -ComputerName $Computer.name -Credential $Cred 
	if ( $HW.Manufacturer -ne "Microsoft Corporation" ) {  #if true then machine is VM and we do not want to process.
       
	    $ServerCount++
	    $oldErrCount = $Error.count
	    $Disks = Get-WMIObject Win32_LogicalDisk -filter "DriveType = 3" -ComputerName $computer.name -cred $Cred -ErrorAction SilentlyContinue
	    $RAM = Get-WmiObject -class "Win32_Computersystem" -Namespace "Root\CIMV2" -ComputerName $Computer.name -Credential $Cred -ErrorAction SilentlyContinue
	    if ($error.count -eq $oldErrCount ) {
		     	#No Error
			}
			else {
				#Error
		 		$NoInfo++
		}
		foreach ( $Disk in $Disks ) {
#	    $Disk.deviceid
#		([int64]$Disk.Size-[int64]$Disk.freespace)/1024/1024/1024
			$HDDSize = $HDDSize + ([int64]$Disk.Size-[int64]$Disk.freespace)/1024/1024/1024
			$HDDCount++		
		}
		$Mem = $Mem + $RAM.TotalPhysicalMemory/1024/1024/1024
	}
}
	
$NoInfo
	
$AVGHDD = $HDDSize/$ServerCount
$AVGMem = $Mem/$ServerCount
"-----------------------"
"$serverCount Servers"
"$AVGHDD MB is the average HDD size."
"$AVGMem GB is the Averange RAM."




