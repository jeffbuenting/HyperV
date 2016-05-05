
#------------------------------------------------------------------------

Function Remote-CMD ( $Computer, $CMD, $Cred )
# Function to run a command on a remote computer.  Remote computer is $Computer.  Command is $CMD.  
# You must run this with ADMIN Permissions on the remote computer.


{
     Write-host "Remote-CMD"
     write-host "Running $CMD on $Computer"

     $NewProcess = Get-WmiObject -class "Win32_Process" -Namespace "Root/CIMV2" -Computername $Computer -credential $Cred
   
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

#Process script arguments
$Direction = $args[0]
$VMName = $args[1]

$cred = get-credential | Out-Null

if ( $args[1] -eq $Null ) { # Blank VM argument passed
		Write-host "ERROR: VM cannot be blank" -foregroundcolor "yellow"
		Write-Host "Syntax: move-hyperv direction VM" -ForegroundColor "yellow"
		Write-Host "    Direction => to - moving to Hyper-V server; from - moving from Hyper-V server" -ForegroundColor "yellow"
		Write-Host "    VM        => name of the VM to move" -ForegroundColor "yellow"
	}
	else {
	
	$VM = get-vm -vmmserver "vbas0053" -name $VMName
	#Convert VM.name into real computer name.
	$length = 0
    $length = ( $vm.name ).indexof( " " ) 
    if ( $length -le 0 ) { $length = ($vm.name).length }
    $VMComputer = ( $vm.name ).substring(0,$length)
	
	switch ( $Direction ) {
		'to'  { # Copy VM to Hyper-V
		
			#Remove-VMAdditions
			switch ( $VM.vmaddition ) {
		        13.206 {
    	            $VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
        	    }  
	            13.552 {
   	            	$VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
   	            }                    
	            13.803 {
    	            $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'        	    
            	}
	            13.809 {
    	            $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
            	}
				13.813 {
					$VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
            	}
	            default {}
    		}

			Remote-CMD $VMComputer $VMUnInstallCmd $Cred
#            Wait-ForReboot $VMComputer
#			
#			#shutdown the VM
#			(gwmi win32_operatingsystem -ComputerName $VMComputer).Win32Shutdown(1)
#			
#			#Copy the VHD to the Hyper-V location
#			get-virtualharddisk -VM $VM.name | foreach { Copy-Item $VHD.location "\\vbvs0005\c$\virtual machines\vhd" }
#			
#			#Remove-VM from SCVMM
			
		
		}
		'from' { # Copy VM from Hyper-V
	
		}
		Default { # Unrecognized Direction
			Write-host "ERROR: $Direction is not a valid Direction" -foregroundcolor "yellow"
			Write-Host "Syntax: move-hyperv direction VM" -ForegroundColor "yellow"
			Write-Host "    Direction => to - moving to Hyper-V server; from - moving from Hyper-V server" -ForegroundColor "yellow"
			Write-Host "    VM        => name of the VM to move" -ForegroundColor "yellow"
		}
	}
}