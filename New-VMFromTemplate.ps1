Function New-VMFromTemplate {

<#
    .Synopsis
        Creates a new Hyper-V Vm using a syspreped VHDx

    .Description
        Creates a new Hyper-V VM in the location specified.  Or in the default location if the path is not specified.  Also uses the template VHD at the Template Path specified.

    .Parameter Name
        Name of the new VM

    .Parameter ComputerName
        Name of the VMHost to create the new VM.  Default is the local host.

    .Parameter Path
        Path location to create the VM.  If left black the VM will be create at the default location for the VMHost.

    .Parameter TemplatePath
        Full path to the VHD.  Default is f:\Virtual Machines\@TemplateVHDx\WIN2012R2_STD_Template.vhdx

    .Example
        Creates a new VM called TestVM in the path specified ustilizing the default VHD template.
        
        New-VMFromTemplate -Name 'TestVM' -Path 'f:\Virtual Machines' -verbose
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeLine=$True)]  
        [String[]]$Name,

        [String]$ComputerName = '.',

        [String]$Path,

        [Int]$CPUCount = 4,

        [String]$TemplatePath = 'f:\Virtual Machines\@TemplateVHDx',

        [Validateset( 'WIN2012R2_STD','WIN2008R2_ENT','ignorecase=$True')]
        [String]$OS

    )

    Begin {
        if ( $Path -eq $Null ) {
            Write-Verbose '$Path is Null.  Setting to VMHost default path'

            $Path = (get-vmhost).VirtualHardDiskPath

            Write-Verbose "Will be creating VM VMHost Default location: $Path"
        }

        Write-Verbose "Getting template VHDx and setting GEN version"
        $SrcPath = Get-ChildItem -path $TemplatePath | where Name -like "$OS*" | Select-Object -ExpandProperty FullName 
        write-verbose "SrcPath: $SrcPath"
        if ( $OS -eq "WIN2012R2_STD" ) {
                $GEN = 2
            }
            else {
                $GEN = 1
        }
               
    }
    
    Process {
        Foreach ( $N in $Name ) {
            Write-Verbose "Creating New VM ($N)..."
            new-vm -Name $N -MemoryStartupBytes 4GB -NoVHD -path $Path -Generation $GEN -SwitchName External -BootDevice VHD 

            Write-Verbose "Moving Template VHDx and renaming it to the VMs file location"
            MD -Path "$Path\$N\Virtual Hard Disks"
            Copy-item -Path $SrcPath -Destination "$Path\$N\Virtual Hard Disks\$($N)_C.vhdx"

            Write-Verbose "Adding VHDx to VM"
            $VM = Get-vm -Name $N 
            Add-VMHardDiskDrive -VM $VM -Path "$Path\$N\Virtual Hard Disks\$($N)_C.vhdx"

            Write-Verbose "Setting CPU Count"
            Set-VM -VM $VM -ProcessorCount $CPUCount

            Write-Verbose "Setting boot order to start from VHD"
            if ( $Gen -eq 2 ) {
                    Set-VMFirmware -VM $VM -BootOrder (get-VMHarddiskDrive -VM $VM)
                }
                else {
                    Set-VMBios -VM $VM -StartupOrder IDE
            }
            
            Write-OutPut (Get-VM -Name $N)
        }
    }
}

New-VMFromTemplate -Name 'JEFFB-CRM01','JEFFB-SQL01' -Path 'f:\Virtual Machines' -OS WIN2012R2_STD -verbose 
