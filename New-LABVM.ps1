[CmdletBinding()]
Param(
    [String]$Name = 'JB-sql01',

    [String]$Path = 'G:\VirtualMachines',

    [Int64]$MemoryStartUpBytes = 2GB,

    [String]$Switch = 'External',

    [String]$VHD = 'g:\Template\WIN2012Sysprep.vhdx',

    [String]$UnattendFile = 'G:\Template\WIN2012R2Unattend.xml'
)

$VerbosePreference = 'Continue'

# ----- Create New VM with no VHD
Write-Verbose "Creating VM"
$VM = New-VM -Name $Name  -MemoryStartupBytes $MemoryStartUpBytes -Path $Path -NoVHD -SwitchName $Switch 

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
$XML = [xml](Get-Content "$($Drive):\Windows\Panther\unattend.xml" )
(($xml.unattend.settings | where pass -eq specialize).component | where name -eq "Microsoft-Windows-Shell-Setup").ComputerName = $Name
$XML.Save( "$($Drive):\Windows\Panther\unattend.xml" )

Dismount-VHD "$Path\$Name\Virtual Hard Disks\$Name.vhdx"

Add-VMHardDiskDrive -VM $VM -Path "$Path\$Name\Virtual Hard Disks\$Name.vhdx" 

# ----- Configure VM
Set-VM -VM $VM -DynamicMemory -ProcessorCount 6 

Start-VM -VM $VM


