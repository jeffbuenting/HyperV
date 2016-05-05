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

$Machine = Get-Input "VM name to be moved"
$vm = Get-VM -name $Machine

#check if the VM has Checkpoints ------------------------------
$Checkpts = Get-VMCheckpoint -VM $VM

#if yes then stop -----------------------------------------
if ( $Checkpts -ne $NULL ) {
    Get-MSGBox "VM Contains Checkpts.  It cannot be migrated to Hyper-V." 16 "Error" | out-null
    break
}

$NewHost = Get-Input "New Host Name"

$NewPath = Get-Input "Where do you want to save the files associated with this virtual machine on the host? Default => c:\virtual machines\"
if ( $NewPath -eq $NULL ) { $NewPath = "c:\virtual machines\" }

$Confirm = Get-MSGBox "Moving $machine to $NewPath on host $NewHost.  Please Confirm." 68 "Confirm"
if ( $Confirm -eq 6 ) { # Yes was clicked

        
        # Check to see if the VM has a SCSI boot Drive ---------

        if ( $VM.StatusString -ne "Stopped" ) { $Running = $TRUE; Shutdown-VM -VM $VM; do{ $VM.StatusString }while( $VM.StatusString -ne "Stopped") }


        foreach ($d in (get-virtualdiskdrive -VM $VM)) { 


            if ( ( $d.bustype -eq 'IDE' ) -and ( $d.bus -eq 0 ) -and ( $d.lun -eq 0 ) ) { $IDEBoot = $TRUE }   # IDE is the boot disk no changes needed

            if ( ( $d.bustype -eq 'SCSI' ) -and ( $d.bus -eq 0 ) -and ( $d.lun -eq 0 ) ) { 
                $SCSIBootDisk = $D
            }

        }


        # if so convert SCSI to IDE ----------------------------

        if ( $IDEBoot ) {} # Not action required
            else {   # Change the SCSI Boot drive to an IDE boot drive
                 set-virtualdiskdrive -virtualdiskdrive $SCSIBootDisk -IDE -BUS 0 -LUN 0
        }


        if ( $Running ) { Start-VM -VM $VM }
        
        #Remove the VM Additions from the VM ------------------

        switch ( $VM.vmaddition ) {
                '13.206' {
                     $VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
                }  
                '13.552' {
                     $VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
                }                    
                '13.803' {
                     $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
                }
                '13.809' {
                     $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
                }
		'13.813' {
		    $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
                 }
		'13.820' {
		    $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
		}
                default { 
                    Get-MSGBox "Unknown VM Additions" 20 "Error" | out-null
                    Break
                }
           }

        $ReturnCode = Remote-CMD $VM.ComputerName $VMUninstallCmd
        Wait-ForReboot $VM.ComputerName

        switch ( $ReturnCode ) {
            '0'  {"Uninstalled VM Additions successfully on $VMName" }
            '2'  { "The user does not have access to the requested information." }
            '3'  { "The user does not have sufficient privilge." }
            '8'  { "Unknown failure.  But check that the VM Additions ISO is mounted to the DVD." }
            '9'  { "The path specified does not exist.  More than likely this means the DVD drive is not D:" }
            '21' { "The specified parameter is invalid." }
            #default { "refer to Win32 error code documentation." }
        }


        #Move the VM -------------------------------------------

        $VirtualNetworkAdapter = Get-VirtualNetworkAdapter -vm $VM
        Set-VirtualNetworkAdapter -VirtualNetworkAdapter $VirtualNetworkAdapter -RunAsynchronously -VirtualNetwork "Services LAN" -NetworkTag "' -        #Location '" -JobGroup 92423d16-a8eb-4cf5-be46-843e7e5fa788 -VLanEnabled $false 
        $VMHost = Get-VMHost -computername $NewHost
        Move-VM -VM $VM -VMHost $VMHost -Path $NewPath -RunAsynchronously -UseLAN -JobGroup 92423d16-a8eb-4cf5-be46-843e7e5fa788 

        #Wait until the move has been completed ----------------
        
        do {} until ( $VM.Status -eq "UnderMigration" )
        do {} while ( $VM.Status -eq "UnderMigration" )

        #install Hyper-V integrated Services -------------------

        #Let everyone know the move is complete ----------------

        Get-MSGBox "$VM has been moved.  Don't forget to install the Hyper-V Integrated Services" 68 "Complete" | out-null
    
    }
    else {  # Confirmation was not given
        Get-MSGBox "Input was not correct." 20 "Error" | out-null
}

exit    #exit out of powershell

