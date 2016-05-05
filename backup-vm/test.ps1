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

     #$returncode

     Return $Returncode.returnValue
     
}

#-----------------------------------------------------------------------------------------

#Set objShell = CreateObject ("WScript.Shell")

$Computer = "VBVS0002"
#map to the C: drive of $computer
#$Net = $(New-Object -Com WScript.Network)
#$net.MapNetworkDrive("J:", "\\$Computer\c$")


#Load current date (formatted as mm-dd-yyyy) into variable strToday
$DateTime = Get-Date -UFormat "%m-%d-%Y_%I-%m"

# Backup target folder or UNC path
$BackupDir = "c:\Backup\VS\$DateTime\"

#Drive containing Virtual Machines
$VMdrive = "d:" 

#VM folder path
$VMfolder = "Virtual Machines"

#'available drive letter used to mount shadow copy
$TempDrive = "V:"

#create backup folder
#new-item $backupDir -type directory

#New-Item $sExCmd -type file

# Create Shadow copy of VM drive
remote-cmd $Computer "c:\VSS\vshadow.exe -script=c:\vss\setvar1.cmd $VMdrive"  # ( removed -p so maybe drive will not remain when done.)
remote-cmd $Computer "c:\vss\call setvar1.cmd"
remote-cmd $Computer "c:\VSS\vshadow.exe -el=%SHADOW_ID_1%, $TempDrive"

remote-cmd $Computer "dir v:"


#Copy the virtual machine files from the shadow copy
$Source = "$TempDrive\$VMfolder"
remote-cmd $Computer "copy $Source $BackupDir"

#Copy-Item $Source $BackupDir -Recurse

#' Delete created shadow copy instance
#oExCmd.WriteLine "Echo y | vshadow.exe -da"
#
#'Backup complete!
#wscript.echo("Backup complete!")
#