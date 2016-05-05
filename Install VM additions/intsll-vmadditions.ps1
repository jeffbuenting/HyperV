# Installs VM Additions on machines that do not have them or are outdated.
#------------------------------------------------------------------------
Function Remote-CMD ( $Computer, $CMD, $Cred )
# Function to run a command on a remote computer.  Remote computer is $Computer.  Command is $CMD.  
# You must run this with ADMIN Permissions on the remote computer.

{
     Write-host "Remote-CMD"
     write-host "Running $CMD on $Computer"
     $NewProcess = Get-WmiObject -List -Computer $Computer -credential $Cred | where{$_.Name -eq 'Win32_Process' }
   
     $ReturnCode = $NewProcess.create( $CMD )
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
#------------------------------------------------------------------------
Function Wait-forService( $computer, $Service, $Action )
#  Function to wait until the $Server on computer $computer $Action
{
     #required to load DLL if not already loaded.
     if (-not ([appdomain]::CurrentDomain.getassemblies() |? {$_.ManifestModule -like "system.serviceprocess"})) {[void][System.Reflection.Assembly]::LoadWithPartialName('system.serviceprocess')}
     
     [System.ServiceProcess.ServiceController]$sc2 = new-object System.ServiceProcess.ServiceController( $Service, $computer )
     $I = 0    # I is used as a timeout.
     do {
          $I = $I + 1
          $SC2.status
     } While ( $SC2.status -ne $Action -and $I -le 1000 )
}
#------------------------------------------------------------------------
Function Wait-ForReboot( $computer )
{
     #wait for Reboot
     do {
          ping $Computer
     } while ( $lastexitcode -eq 0 )
     #wait until the computer is back on
     Wait-forService $Computer "netlogon" "Running"
}
#------------------------------------------------------------------------
Function Reboot-VM( $Server, $Cred )
{
     $s = get-wmiobject win32_operatingsystem -computername $Server -credential $cred
     $s.win32shutdown(6)
     
     #Wait for Host to complete reboot.
     #wait until the computer is off
     do {
          ping $server
     } while ( $lastexitcode -eq 0 )
     #wait until the computer is back on
    Wait-forService $server "netlogon" "Running"
}

#------------------------------------------------------------------------
Function Mount-VMAdditions( $VM )
{
     $vmadditions = get-iso | where { $_.Name –eq ‘VMAdditions’ }
     $dvddrive = get-virtualdvddrive -vm $vm
     if ( $dvddrive.iso.name -eq "VMAdditions" ) {
   write-host "Already Mounted: "
  }
  else {
   write-host "Mounting: ", $vm.name
   Set-VirtualDVDDrive -VirtualDVDDrive $vm.VirtualDVDDrives[0] -Link -ISO $vmadditions | out-null
     }
}
#------------------------------------------------------------------------
#------------------------------------------------------------------------
#  Main
#------------------------------------------------------------------------
clear-host
get-vmmserver "vbas0053" | out-null
# Get list of VM's that need the VM Additions
$TotalVM = 0
$VMNeedtobeStarted = 0
$VMNeedPermissions = 0
$VMErrors = 0
$UName = '1comit$admin!'
$cred = get-credential $UName
$PWD = $Cred.password
foreach ( $vm in ( get-vm | where {    $_.vmaddition -lt "13.813" -or $_.hasvmadditions -eq 0  -and $_.vmhost -eq "vbvs0003" -and $_.state -eq "Running"  } ) ) { 
#foreach ( $vm in ( get-vm | where { $_.hasvmadditions -eq 0  -and $_.vmhost -eq "vbvs0003" -and $_.state -eq "Running"  } ) ) { 
  $length = 0
     $length = ( $vm.name ).indexof( " " ) 
     if ( $length -le 0 ) { $length = ($vm.name).length }
     $strComputer = ( $vm.name ).substring(0,$length)
     $uName = $strComputer+'\1comit$admin!'
     
     
     $cred=new-object  -typename System.Management.Automation.PSCredential -argumentlist $UName,$pwd
 #    $Cred.getnetworkcredential()

     #Get Drive letter of VM DVD Drive
 
     $oldErrCount = $error.count
    
     
     $D = get-wmiobject win32_logicaldisk -filter "DriveType = 5" -computer $strComputer -credential $cred 
  
     if ( $error.count -eq $oldErrCount ) {
               # Means the Cred was correct and there was no error and the $D has the DVD Drive letter of the VM               
     
     
               $VMInstallCmd = $D.deviceid+'\windows\setup.exe /s /v"Reboot=ReallySupress /qn"'
     
               switch ( $VM.vmaddition ) {
                    13.206 {
                         $VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
                         Remote-CMD $strComputer $VMUnInstallCmd $Cred
                         Wait-ForReboot $strComputer
                    }  
                    13.552 {
                         $VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
                         Remote-CMD $strComputer $VMUnInstallCmd $Cred
                         Wait-ForReboot $strComputer
                    }                    
                    13.803 {
                         $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
                         Remote-CMD $strComputer $VMUnInstallCmd $Cred
                         Wait-ForReboot $strCompute
                    }
                    13.809 {
                         $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
                         Remote-CMD $strComputer $VMUnInstallCmd $Cred
                         Wait-ForReboot $strCompute
                    }
                    default {}
               }
     
     
              
              
               #Mount VM additions ISO
               Mount-VMAdditions $VM
         
               #install VM additions
     
              $ReturnCode = Remote-CMD $StrComputer $VMInstallCmd $Cred 
               $ReturnCode
    
               switch ( $ReturnCode ) {
                    0 { 
                         "Installed VM Additions successfully on $VMName" 
                         Reboot-VM $strComputer $Cred
                    }
                 2 { "The user does not have access to the requested information." }
                 3 { "The user does not have sufficient privilge." }
                 8 { "Unknown failure.  But check that the VM Additions ISO is mounted to the DVD." }
                 9 { "The path specified does not exist.  More than likely this means the DVD drive is not D:" }
                 21 { "The specified parameter is invalid." }
                 default { "refer to Win32 error code documentation." }
               }
          }
          else {               
               "$VM  - Credentials are incorrect."
     }
     
}

#-------------------------------------------------------------------------------------
