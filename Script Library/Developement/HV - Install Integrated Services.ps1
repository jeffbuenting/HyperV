# ------------------------------------------------------------------------------
# Migrate Virtual Machine from Virtual Server Host to Hyper-V host
# ------------------------------------------------------------------------------
# Command Line arguments
#    $VMName = Name of the VM to migrate
# ------------------------------------------------------------------------------



Function Get-MSGBox( $MSG, $Bttns, $HDRMsg )

{
    $a = new-object -comobject MSScriptControl.ScriptControl
    $a.language = "vbscript"
    $a.addcode("function getConfirm() getconfirm = msgbox(`"$MSG`",$Bttns,`"$HDRMsg`") end function" )
    $b = $a.eval("getconfirm")

    Return $b

}


#----------------------------------------------------

Function Get-Input( $Question )

{
    $a = new-object -comobject MSScriptControl.ScriptControl
    $a.language = "vbscript"
    $a.addcode("function getInput() getInput = inputbox(`"$Question`",`"$Question`") end function" )
    $b = $a.eval("getInput")

    Return $b

}

#------------------------------------------------------------------------

Function Remote-CMD ( $Computer, $CMD, $Cred )
# Function to run a command on a remote computer.  Remote computer is $Computer.  Command is $CMD.  
# You must run this with ADMIN Permissions on the remote computer.


{
#     Write-host "Remote-CMD"
     write-host "Running $CMD on $Computer"
     
     if ( $Cred -ne $NULL ) {          # Credentials passed to Funct
             $NewProcess = Get-WmiObject -List -Computer $Computer -credential $Cred | where{$_.Name -eq 'Win32_Process' }
         }                            #  Use default Creds.
         else {
             $NewProcess = Get-WmiObject -List -Computer $Computer | where{$_.Name -eq 'Win32_Process' }
     }
   
     $ReturnCode = $NewProcess.create( $CMD )
     #Waiting for process to end
     $a = 0
     $timespan = New-Object System.TimeSpan(0, 0, 1)  
     $scope = New-Object System.Management.ManagementScope("\\$Computer\root\cimV2")
     $query = New-Object System.Management.WQLEventQuery ("__InstanceDeletionEvent",$timespan, "TargetInstance ISA 'Win32_Process'" )
     $watcher = New-Object System.Management.ManagementEventWatcher($scope,$query)

     do {
          $b = $watcher.WaitForNextEvent()
	  "."
          if ( $b.TargetInstance.processid -eq $returncode.processid ) {
	       $a = 1
          }
     } while ($a -ne 1)

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
     "waiting for $computer to reboot"
     do {
          ping $Computer | out-null
          '.'
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

#------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------

get-vmmserver "VMAS9072" | Out-Null

$Machine = Get-Input "Name of the VM to install the Integrated Services on"
$vm = Get-VM -name $Machine

if ( $VM.Status -ne "Running" ) { Start-VM -VM $VM }

copy "\\vbfp0012\Disaster_Recovery\Hyper-V Windows 2008\Integrated Components\*.*" "\\$VM.computername\c$\temp\integrated components" 







