# ------------------------------------------------------------------------------
# Creates a New VM
# ------------------------------------------------------------------------------
# 
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
# Main
#------------------------------------------------------------------------

get-vmmserver "VMAS9072" | Out-Null

$VMName = get-input "Name of the new VM"
$VM_Host = get-input "Name of host to place VM on"

$CPUType = Get-CPUType | where {$_.Name -eq "1-processor 3.33 GHz Xeon MP"}

$VMHost = Get-VMHost -ComputerName $VM_Host
if ( $VMHost.VirtualizationPlatformString -eq "Microsoft Hyper-V" ) {  # Hyper-V server
        New-HardwareProfile -Owner "VBGOV\jbuentin" -CPUType $CPUType -Name "Profiled644af61-1f67-48bf-96fc-2dc6f8c4c9b2" -Description "Profile used to create a VM/Template" -CPUCount 2 -MemoryMB 2048 -ExpectedCPUUtilization 20 -DiskIO 0 -NetworkUtilization 10 -RelativeWeight 100 -HighlyAvailable $false -NumLock $false -BootOrder "CD", "IdeHardDrive", "PxeBoot", "Floppy" -LimitCPUFunctionality $false -JobGroup 5d4a776b-4765-4f0c-8b98-24e4de2c204a 
	$Template = Get-Template | where {$_.Name -eq "HV - WIN 2003 Enterprise R2 SP2 x86"}
	}
	else {  #Virtual Server
	Get-MSGBox "Not a Hyper-V server" 20 "Error"
	Break
}

$NewPath = Get-Input "Where do you want to save the files associated with this virtual machine on the host? Default => c:\virtual machines\"
if ( $NewPath -eq $NULL ) { $NewPath = "c:\virtual machines\" }

#getSet-VirtualFloppyDrive -RunAsynchronously -NoMedia -JobGroup 5d4a776b-4765-4f0c-8b98-24e4de2c204a 
New-VirtualNetworkAdapter -jobGroup 5d4a776b-4765-4f0c-8b98-24e4de2c204a -PhysicalAddressType Dynamic -VirtualNetwork "Services LAN" -VLanEnabled $false 
New-VirtualDVDDrive -JobGroup 5d4a776b-4765-4f0c-8b98-24e4de2c204a -Bus 1 -LUN 0 

$HardwareProfile = Get-HardwareProfile | where {$_.Name -eq "Profiled644af61-1f67-48bf-96fc-2dc6f8c4c9b2"}
$OperatingSystem = Get-OperatingSystem | where {$_.Name -eq "Windows Server 2003 Enterprise Edition (32-bit x86)"}

New-VM -Template $Template -Name $VMName -Description "" -VMHost $VMHost -Path $NewPath -JobGroup 5d4a776b-4765-4f0c-8b98-24e4de2c204a -RunAsynchronously -Owner "VBGOV\jbuentin" -HardwareProfile $HardwareProfile -ComputerName $VMName -FullName "COMIT" -OrgName "City of Virginia Beach" -ProductKey "CPCDM-HJJWH-HBPTY-PDBGX-KMYRT" -TimeZone 35 -GuiRunOnceCommands "\\vbfp0012\vmm library\script library\win 2003 install.bat" -OperatingSystem $OperatingSystem -RunAsSystem -StartAction AlwaysAutoTurnOnVM -DelayStart 0 -UseHardwareAssistedVirtualization $false -StopAction SaveVM 






