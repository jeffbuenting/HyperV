# Repair Incomplete VM Config

 
write-host "testing"
get-vmmserver "vbas0053"


$vm = get-vm | where { $_.state -eq 'IncompleteVMConfig' } 

foreach ( $V in $vm ) {
     $V.name
     $v.virtuadvddrives[0]
     $V
 #    Set-VirtualDVDDrive –VirtualDVDDrive $V.VirtualDVDDrives[0] -nomedia
 #    Set-VirtualDVDDrive -VirtualDVDDrive $v.VirtualDVDDrives[0] -nomedia
}
