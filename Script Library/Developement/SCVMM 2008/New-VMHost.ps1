#-----------------------------------------------------------------------------------------------------------

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


#----------------------------------------------------

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
Function Reboot-VM( $Server )

{
     $s = get-wmiobject win32_operatingsystem -computername $Server 
     $s.win32shutdown(6)
     
     #Wait for Host to complete reboot.
     #wait until the computer is off

     do {
          ping $server | Out-Null
		  '.'
     } while ( $lastexitcode -eq 0 )

     #wait until the computer is back on

    Wait-forService $server "netlogon" "Running"
}
#-----------------------------------------------------------------------------------------------------------
# Main
#-----------------------------------------------------------------------------------------------------------

Get-VMMServer -ComputerName VMAS9072 | Out-Null
$Credentials = Get-Credential
$HostName = Get-Input "Which Host are you working with?"

# Create Local storage for VMs C:\virtual machines ---------------------------------------------------------

$VMPath = "Virtual Machines"
new-item -path "\\$HostName\C$" -Name $VMPath -type Directory

$VMPath = "C:\$VMPath"

# Add new Host to SCVMM and install Hyper-V Roll -----------------------------------------------------------

$VMHostGroup = Get-VMHostGroup | where {$_.Path -eq "All Hosts\Hyper-V"}
Add-VMHost -ComputerName "$HostName.vbgov.com" -Description "" -credential $Credentials -RemoteConnectEnabled $true -RemoteConnectPort 5900 -VmPaths $VMPath -Reassociate $false -VMHostGroup $VMHostGroup 

Reboot-VM "$HostName.vbgov.com"

# Config Hyper-V -------------------------------------------------------------------------------------------
#     Setup Hyper-V Networks -------------------------------------------------------------------------------

$HostServer = Get-VMHost -ComputerName $HostName

$hostnic = Get-VMHostnetworkadapter -VMHost $HostServer | where { $_.connectionname -eq "Services LAN" }
new-VirtualNetwork -vmhost $HostServer -Name "Services LAN" -VMHostNetworkAdapters $HostNic 

#     Turn on VSS for volume with the VM's stored on it. ---------------------------------------------------

Get-MsgBox "Please Enable Shadow Copy on $HostName.  I'll wait" 64

#Create Shadow Storage
#$Class = Get-WmiObject -List -Computer $HostName | where{$_.Name -eq 'Win32_ShadowStorage' }
#$class.create( "c:\", "c:\" )

#Creates a shadow copy
#$Class = Get-WmiObject -List -Computer $HostName | where{$_.Name -eq 'Win32_ShadowCopy' }
#$class.create("C:\", "ClientAccessible")


#     Set Control Panel option in start menu to display as a menu ------------------------------------------

