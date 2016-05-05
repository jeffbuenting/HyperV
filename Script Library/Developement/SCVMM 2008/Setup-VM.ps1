#-------------------------------------------------------------------------------
# Setup-VM.ps1
#
# Configures a new VM Server with the City standards
#-------------------------------------------------------------------------------

Function Get-Input( $Question )

{
    $a = new-object -comobject MSScriptControl.ScriptControl
    $a.language = "vbscript"
    $a.addcode("function getInput() getInput = inputbox(`"$Question`",`"$Question`") end function" )
    $b = $a.eval("getInput")

    Return $b

}

#------------------------------------------------------------------------

Function Get-MSGBox( $MSG, $Bttns, $HDRMsg )

{
    $a = new-object -comobject MSScriptControl.ScriptControl
    $a.language = "vbscript"
    $a.addcode("function getConfirm() getconfirm = msgbox(`"$MSG`",$Bttns,`"$HDRMsg`") end function" )
    $b = $a.eval("getconfirm")

    Return $b

}

#------------------------------------------------------------------------

Function Remote-CMD ( $Computer, $CMD )
# Function to run a command on a remote computer.  Remote computer is $Computer.  Command is $CMD.  
# You must run this with ADMIN Permissions on the remote computer.


{
     Write-host "Remote-CMD"
     write-host "Running $CMD on $Computer"

     $NewProcess = Get-WmiObject -List -Computer $Computer | where{$_.Name -eq 'Win32_Process' }
   
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

Function Reboot-VM( $Server )

{
     $s = get-wmiobject win32_operatingsystem -computername $Server 
     $s.win32shutdown(6)
     
     #Wait for Host to complete reboot.
     #wait until the computer is off

     do {
          ping $server
     } while ( $lastexitcode -eq 0 )

     #wait until the computer is back on

    Wait-forService $server "netlogon" "Running"
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

# Get Servers Name -------------------------------------------------------------

$VMName = Get-input "Name of VM to configure"

# Get Server's OS --------------------------------------------------------------

$VMOS = get-wmiobject Win32_OperatingSystem -comp $VMName
$VMOS



switch ( $VMOS.Version ) {
    'Microsoft(R) Windows(R) Server 2003, Enterprise Edition' { $VM_OS = '2003' }
	'6.0.6001' { $VM_OS = '2008'; "what" }
}	

$VM_OS
switch ( $VM_OS ) {
    '2008' { 
	    # Set up display to 1024x768 ------------------------------------------
		"display"
		&'\\vbgov.com\deploy\disaster_recovery\scvmm\software\qres\qres.exe' /1024
			
		# Install Hyper-V Integrated Services ---------------------------------
		"IC"
		&'\\vbgov.com\deploy\disaster_recovery\hyper-v windows 2008\integrated Components\support\x86\setup.exe /quiet'
			
	    
		#         Setup Backup ------------------------------------------------
		#              Install Netbackup 6.5 ----------------------------------
		#c:\windows\system32\msiexec.exe.exe "/l*v c:\temp\netbackup install.log" /i "VERITAS NetBackup.msi" /qn INSTALLDIR="C:\Program Files\VERITAS\" NBINITIALKEY="%LICENSEKEY%" MASTERSERVERNAME="VBBS002" ADDITIONALSERVERS="VBBS0003" ADMINCLIENT=0 MASTERSERVERINSTALL=0 MEDIASERVERINSTALL=0 ADMINCONSOLEINSTALL=1 INSTALLLEVEL=150	SERVERS="VBBS002,$VM.Name,VBBS0003" CLIENTNAME=$VM.Name NBOTMINSTALL="1" NBINSTALLDOCS="1" STARTUP="Automatic" NBSTARTSERVICES="1" BPCD_PORT="13782" BPRD_PORT="13720" BPDBM_PORT="%13721" VMD_PORT="13701" ACSD_PORT="13702" TL8CD_PORT="13705" ODLD_PORT="13706" TS8D_PORT="13709" TLDCD_PORT="13711" TL4D_PORT="13713" TSDD_PORT="13714" TSHD_PORT="13715" TLMD_PORT="13716" TLHCD_PORT="13717"	LMFCD_PORT="13718" VOPIED_PORT="13783" RSMD_PORT="13719" CLIENTSLAVENAME=$VM.Name SILENTINSTALL="1"  NBDBD_PORT="13784" VNETD_PORT="13724" NUMERICINSTALLTYPE="2" INSTALLDEBUG="0" VISD_PORT="9284" BPJOBD_PORT="13723" STOP_NBU_PROCESSES="0" STOP_WINDOWS_PROCESSES="0" ABORT_REBOOT_INSTALL="0" INSTALL_LIVEUPDATE=0 REBOOT="ReallySuppress"
		
		#              Install Netbackup 6.5.2 --------------------------------
		#              Email Storage Team that These servers are ready for them.
		
		#         Setup MOM --------------------------------------------------- 
	
		
	}
	'2003' {
	   "Working with 2003 server  "
	}
}

