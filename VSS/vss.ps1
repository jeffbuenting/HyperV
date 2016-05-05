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

$Comp = "VBVS0002.vbgov.com"

$colItems = get-wmiobject -class "Win32_ShadowCopy" -namespace "root\cimv2" -computername $Comp






#$SnapID = $ColItems[0].ID
#$SnapID
#$Cmd = "C:\Program Files\Microsoft\VSSSDK72\Tools\VSSReports\vshadow.exe -er=$SnapID,VSSShare,Virtual Machine"
#$Cmd
#remote-cmd $Comp $Cmd
#
#New-PSDrive -Name k -psprovider filesystem -Root "\\vbvs0002\vssshare"
#Set-Location k:

#$net = $(New-Object -Com WScript.Network)
#$net.MapNetworkDrive("i:", "\\vbvs0002\vssshare")


ForEach ( $objItem in $colItems ) {
    $ObjItem.ID
 $objItem.ClientAccessible
$objItem.Count
$objItem.DeviceObject
$objItem.Differential
$objItem.ExposedLocally
$objItem.ExposedName
$objItem.ExposedRemotely
$objItem.HardwareAssisted
$objItem.Imported
$objItem.NoAutoRelease
$objItem.NotSurfaced
$objItem.NoWriters
$objItem.OriginatingMachine
$objItem.Persistent
$objItem.Plex
$objItem.ProviderID
$objItem.ServiceMachine
$objItem.SetID
$objItem.State
 $objItem.Transportable
 $objItem.VolumeName
 ""   
	}
