# backup Virtual Machines

#-----------------------------------------------------------------------------------

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

#-----------------------------------------------------------------------------------

#$BackupLocation = "e:\bu"
#$VSServer = "VBVS0001"
#$Cmd = "C:\Program Files\Microsoft\VSSSDK72\Tools\VSSReports\vshadow.exe -p -nw e:"
#
#Get-VMMServer "VBAS0053" | Out-Null
#Get-VM | where { $_.name -eq "CVB-VISTA-VM" } | foreach {
#    if ( $_.status -eq "Running" ) { 
#	        SaveState-VM $_ | Out-Null
#			$Comp = $_.Hostname
#            remote-cmd $Comp $Cmd
#			Start-VM $_ | Out-Null
#		}
#		else {
#	    	
#	}
#}
    
$Computer = "vbvs0001"
$I=1
Get-WmiObject  -Class Win32_shadowcopy -Namespace root\CIMV2 -ComputerName $Computer | select-object DeviceObject | foreach {
    $Link = 'c:\shadowcopy'+$I
	$Link
	$I++
		cmd /k mklink /d $Link $_
		exit
}




	
	
	

	
	
