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
     
}#----------------------------------------------------------------

$Computer = "VBVS0002"
$SCopies = Get-WmiObject -Class Win32_ShadowCopy -Namespace root/cimv2 -ComputerName $Computer
$MostCurrentDate = $SCopies[0].installdate

foreach ( $Copy in $SCopies ) {
   if ( $MostCurrentDate -lt $Copy.installdate ) { 
       $MostCurrentDate = $Copy.InstallDate 
	   $SnapID = $Copy.ID
	}

#   $Date = [System.Management.ManagementDateTimeConverter]::ToDateTime($Copy.installdate)
#   $Date, $Copy.ID
#   $Copy.VolumeName
#   " "
}
#[System.Management.ManagementDateTimeConverter]::ToDateTime($MostCurrentDate),$SnapID

$Cmd = "C:\Program Files\Microsoft\VSSSDK72\Tools\VSSReports\vshadow.exe -er=$SnapID,VSSShare"

remote-cmd $Computer $Cmd

Get-WmiObject -class WIN32_Share -namespace root\cimv2 -ComputerName $Computer 

New-PSDrive -Name k -psprovider filesystem -Root "\\vbvs0002\vssshare" 
Set-Location k: | Out-Null
dir
Set-Location c:
remove-psdrive -Name k |Out-Null

## Clean up
$Share = Get-WmiObject -class WIN32_Share -namespace root\cimv2 -ComputerName $Computer | where { $_.name -eq "VSSShare" }
$Share.delete()

