# Uninstalls the VM Additions from a machine on a Virtual Server

#----------------------------------------------------

Function Get-Input( $Question ) 
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    $objForm = New-Object System.Windows.Forms.Form 
	$objForm.Text = $Question
	$objForm.Size = New-Object System.Drawing.Size(300,200) 
	$objForm.StartPosition = "CenterScreen"

	$objForm.KeyPreview = $True
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    	{$x=$objTextBox.Text;$objForm.Close()}})
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
		{$objForm.Close()}})

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Size(75,120)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = "OK"
	$OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
	$objForm.Controls.Add($OKButton)
	
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Size(150,120)
	$CancelButton.Size = New-Object System.Drawing.Size(75,23)
	$CancelButton.Text = "Cancel"
	$CancelButton.Add_Click({$objForm.Close()})
	$objForm.Controls.Add($CancelButton)
	
	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,20) 
	$objLabel.Size = New-Object System.Drawing.Size(280,20) 
	$objLabel.Text = $Question
	$objForm.Controls.Add($objLabel) 
	
	$objTextBox = New-Object System.Windows.Forms.TextBox 
	$objTextBox.Location = New-Object System.Drawing.Size(10,40) 
	$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
	$objForm.Controls.Add($objTextBox) 
	
	$objForm.Topmost = $True
	
	$objForm.Add_Shown({$objForm.Activate()})
	[void] $objForm.ShowDialog()

 	Return $x
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
#  Main
#------------------------------------------------------------------------

clear-host
Get-VMMServer -ComputerName "VMAS9072" | out-null


$VMName = get-input "Enter the name of the VM to remove VM Additions from:"
$VM = Get-VM -Name $VMName

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
                default {"Unknown VM Additions"}
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

 











#$UName = '1comit$admin!'

#$cred = get-credential $UName
#$PWD = $Cred.password

#$VMName = get-input "Enter the name of the VM to remove VM Additions from:"
#$VM = Get-VM -Name $VMName

##$length = 0
##$length = ( $vm.name ).indexof( " " ) 
##if ( $length -le 0 ) { $length = ($vm.name).length }
##$strComputer = ( $vm.name ).substring(0,$length)


#$strComputer = $VM.computername

#$uName = $strComputer+'\1comit$admin!'

#	 $StrComputer
	 
     
# $cred=new-object  -typename System.Management.Automation.PSCredential -argumentlist $UName,$pwd

#Get Drive letter of VM DVD Drive
 
#$oldErrCount = $error.count
    
#$D = get-wmiobject win32_logicaldisk -filter "DriveType = 5" -computer $strComputer -credential $cred 
  
#if ( $error.count -eq $oldErrCount ) {
	# Means the Cred was correct and there was no error and the $D has the DVD Drive letter of the VM               
     
#           switch ( $VM.vmaddition ) {
#                '13.206' {
#                     $VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
#                     $ReturnCode = Remote-CMD $strComputer $VMUnInstallCmd $Cred
#                     Wait-ForReboot $strComputer
#                }  
#                '13.552' {
#                     $VMUninstallCmd = 'msiexec.exe /qn /x{543595B5-51FE-4E1D-9281-51F01E05D10F}'
#                     $ReturnCode = Remote-CMD $strComputer $VMUnInstallCmd $Cred
#                     Wait-ForReboot $strComputer
#                }                    
#                '13.803' {
#                     $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
#                     $ReturnCode = Remote-CMD $strComputer $VMUnInstallCmd $Cred
#                     Wait-ForReboot $strComputer
#                }
#                '13.809' {
#                     $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
#                     $ReturnCode = Remote-CMD $strComputer $VMUnInstallCmd $Cred
#                     Wait-ForReboot $strComputer
#                }
#		'13.813' {
#		    $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
#		    $ReturnCode = Remote-CMD $strComputer $VMUnInstallCmd $Cred
#                    Wait-ForReboot $strComputer
#		}
#		'13.820' {
#		    "Removing 13.820"
#		    $VMUninstallCmd = 'msiexec.exe /qn /x{E799CA03-7E46-4AE7-A7B6-E904CCFD1529}'
 #                   $ReturnCode = Remote-CMD $strComputer $VMUnInstallCmd $Cred
 #                   Wait-ForReboot $strComputer
#		}
#                default {"Unknown VM Additions"}
#           }
     
               
#"one"     
 
 #          $ReturnCode
#"two"
    
 #          switch ( $ReturnCode ) {
  #                  '0' {"Uninstalled VM Additions successfully on $VMName" }
#	            2 { "The user does not have access to the requested information." }
#	            3 { "The user does not have sufficient privilge." }
#	            8 { "Unknown failure.  But check that the VM Additions ISO is mounted to the DVD." }
#	            9 { "The path specified does not exist.  More than likely this means the DVD drive is not D:" }
#	            21 { "The specified parameter is invalid." }
#	            default { "refer to Win32 error code documentation." }
 #         }
#      }
#      else {               
#           "$VM  - Credentials are incorrect."
#}
     



#-------------------------------------------------------------------------------------

