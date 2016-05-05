


#------------------------------------------------------------------------




Get-VMMServer vmas9072
$vm = Get-VM -Name test
$Running = $IDEBOOT = $FALSE

$VM.StatusString

if ( $VM.StatusString -ne "Stopped" ) { $Running = $TRUE; Shutdown-VM -VM $VM; do{ $VM.StatusString }while( $VM.StatusString -ne "Stopped") }

"----"
foreach ($d in (get-virtualdiskdrive -VM $VM)) { 


    if ( ( $d.bustype -eq 'IDE' ) -and ( $d.bus -eq 0 ) -and ( $d.lun -eq 0 ) ) { $IDEBoot = $TRUE }   # IDE is the boot disk no changes needed

    if ( ( $d.bustype -eq 'SCSI' ) -and ( $d.bus -eq 0 ) -and ( $d.lun -eq 0 ) ) { 
        $SCSIBootDisk = $D
    }
"--------"
}
$Running
$IDEBoot    
$SCSIBootDisk

    if ( $IDEBoot ) {} # Not action required
         else {   # Change the SCSI Boot drive to an IDE boot drive
              set-virtualdiskdrive -virtualdiskdrive $SCSIBootDisk -IDE -BUS 0 -LUN 0
    }


if ( $Running ) { Start-VM -VM $VM }



