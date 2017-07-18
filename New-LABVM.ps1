[CmdletBinding()]
Param(
    [String]$Name = 'JB-LAPS01',

    [String]$Path = 'G:\VirtualMachines',

    [Int64]$MemoryStartUpBytes = 2GB,

    [Int64]$MinimumRAM = 2GB,

    [String]$Switch = 'External',

    [String]$VHD = 'g:\Template\WIN2012R2Sysprep.vhdx',

    [String]$UnattendFile = 'G:\Template\WIN2012R2Unattend.xml'
)

$VerbosePreference = 'Continue'

# ----- Create New VM with no VHD
Try {
    Write-Verbose "Creating VM"
    $VM = New-VM -Name $Name  -MemoryStartupBytes $MemoryStartUpBytes -Path $Path -NoVHD -SwitchName $Switch 
} 
Catch {
    $EXceptionMessage = $_.Exception.Message
    $ExceptionType = $_.exception.GetType().fullname
    Throw "ERROR : There was a problem creating the new VM.`n`n     $ExceptionMessage`n`n     Exception : $ExceptionType"   
}

# ----- Copy VHD and Rename
Write-Verbose "Copy VHD"
if ( -Not (Test-Path -Path "$Path\$Name\Virtual Hard Disks" ) ) { New-Item -Path "$Path\$Name\Virtual Hard Disks" -ItemType Directory }
Copy-Item -Path $VHD -Destination "$Path\$Name\Virtual Hard Disks\$Name.vhdx"

# ----- Mount VHD and add unattend.xml file
# ----- http://www.thomasmaurer.ch/2016/06/add-unattend-xml-to-vhdx-file-for-vm-automation/
Write-verbose "Add Unattend.xml"
Mount-VHD -Path "$Path\$Name\Virtual Hard Disks\$Name.vhdx"

# ----- Find the Mounted drive letter.  since windows uses multiple partitions for the OS, we are grabbing the larger or second partition (1)
# ----- https://blogs.technet.microsoft.com/heyscriptingguy/2014/02/10/powertip-identify-letter-of-mounted-iso-or-vhd-file-with-powershell/
$Drive = (Get-DiskImage "$Path\$Name\Virtual Hard Disks\$Name.vhdx" | Get-Disk | Get-Partition)[1] | Select-Object -ExpandProperty DriveLetter

Copy-item $UnattendFile -Destination "$($Drive):\Windows\Panther\unattend.xml" -Force

# ----- Edit the Unattend file for the correct ComputerName
Write-verbose "Edit Computer Name in Unattend.xml"
$XML = [xml](Get-Content "$($Drive):\Windows\Panther\unattend.xml" )
(($xml.unattend.settings | where pass -eq specialize).component | where name -eq "Microsoft-Windows-Shell-Setup").ComputerName = $Name
$XML.Save( "$($Drive):\Windows\Panther\unattend.xml" )

Dismount-VHD "$Path\$Name\Virtual Hard Disks\$Name.vhdx"

Add-VMHardDiskDrive -VM $VM -Path "$Path\$Name\Virtual Hard Disks\$Name.vhdx" 

# ----- Configure VM
Set-VM -VM $VM -DynamicMemory -ProcessorCount 6 -MemoryMinimumBytes $MinimumRam

# ----- Starting immediately after building seems to cause issues.  As in need to reboot for the unattend to work correctly.  Adding some time.
Write-verbose "Pausing to wait for vm to complete configuration"
Start-Sleep -Seconds 300

Write-Verbose "Starting VM $Name"
Start-VM -VM $VM 

# ----- Because our DNS is configured wonky, we have to use the FQDN for DNS resolution.
$Name = $Name + '.stratuslivedemo.com'

# ----- Wait for VM to boot and then pause 5 minutes to complete booting
$Timeout = 60
$T = 0
while ( -Not (Test-Connection -ComputerName $Name -Quiet ) ) {
    Write-Output "Restarting ...($T)"
    $T ++
    if ( $T -ge $Timeout ) { Throw "Error : Timeout Reached waiting for Server to Retart.`n`nTo verify the server is back up relies on pinging the system.  If the firewall does not allow ping then this process will fail and timeout." }
    Start-sleep -seconds 10
}

# ----- once ping is true then wait an additional time for all services to come online.
$Seconds = 300
For ( $I = 1; $I -le 100; $I++ ) {
    Start-sleep -Seconds (0.01 * $Seconds)
    Write-Progress -Activity "Pausing to Let the Server Come back online" -Status "Percent Complete: " -PercentComplete $I
}

# ----- For my lab I shut off the windows firewall
$Session = New-CimSession -ComputerName $Name 
Get-NetFirewallprofile -CimSession $Session | Set-NetFirewallProfile -Enabled False

# ----- add the DSC Cert 
# ----- https://msdn.microsoft.com/en-us/powershell/dsc/securemof
Copy-Item -Path "\\sl-dsc.stratuslivedemo.com\c$\DSCScripts\DscPrivateKey.pfx" -Destination "\\$Name\c$\Temp" -Force
Invoke-Command -ComputerName $Name -ScriptBlock {
    $mypwd = ConvertTo-SecureString -String "Stratus!!2017" -Force -AsPlainText
    Import-PfxCertificate -FilePath "C:\temp\DscPrivateKey.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd
}


