Function Remote-CMD ( $Computer, $CMD )
# Function to run a command on a remote computer.  Remote computer is $Computer.  Command is $CMD.  
# You must run this with ADMIN Permissions on the remote computer.


{
     Write-host "Remote-CMD"
     write-host "Running $CMD on $Computer"

     $ReturnCode = ([wmiClass]"\\$Computer\ROOT\CIMV2:win32_process").Create($CMD) 

     #Waiting for process to end
     $a = 0

     $timespan = New-Object System.TimeSpan(0, 0, 1)  
     $scope = New-Object System.Management.ManagementScope("\\$Computer\root\cimV2")
     $query = New-Object System.Management.WQLEventQuery ("__InstanceDeletionEvent",$timespan, "TargetInstance ISA 'Win32_Process'" )
     $watcher = New-Object System.Management.ManagementEventWatcher($scope,$query)

     "Waiting for $CMD to complete"
     do {
          $b = $watcher.WaitForNextEvent()
          if ( $b.TargetInstance.processid -eq $returncode.processid ) {
	       $a = 1
          }
     } while ($a -ne 1)

     $returncode

     Return $Returncode.returnValue
     
}

#-----------------------------------------------------------------------------------------

get-vmmserver "vbas0053" | out-null


$cmdline = 'd:\windows\setup.exe /s /v"Reboot=ReallySupress /qn"'
$cmdline


     $vmadditions = get-iso | where { $_.Name –eq ‘VMAdditions’ }
   
     $VMName = "vmas9049 - ohm"

     $VM = get-vm | where { $_.name -eq $VMName }
     


#     $dvddrive = get-virtualdvddrive -vm $vm
 #    if ( $dvddrive.iso.name -eq "VMAdditions" ) {
#			write-host "Already Mounted: "
#		}
#		else {
#			write-host "Mounting: ", $vm.name
#			Set-VirtualDVDDrive -VirtualDVDDrive $vm.VirtualDVDDrives[0] -Link -ISO $vmadditions | out-null
 #    }
     

     start-vm -vm $VM
     do {
          $VM = get-vm | where { $_.name -eq $VMName }
     } until ( $VM.state -eq "Running" )

     $ReturnCode = Remote-CMD $VMName $CMDLine	

     $ReturnCode
     

     switch ( $ReturnCode ) {
          0 { "Installed VM Additions successfully on $VMName" }
	  2 { "The user does not have access to the requested information." }
	  3 { "The user does not have sufficient privilge." }
	  8 { "Unknown failure.  But check that the VM Additions ISO is mounted to the DVD." }
	  9 { "The path specified does not exist.  More than likely this means the DVD drive is not D:" }
	  21 { "The specified parameter is invalid." }
	  default { "refer to Win32 error code documentation." }
     }

    shutdown-vm -vm $vm













