<#
    .Synopsis
        Creates a new VM 

    .Description
        Using the OS ISO and an AutoUnattend.xml file a new VM is created from scratch.
#>

[CmdletBinding()]
Param(
    [String]$HVHost = 'SL-JeffB',

    [String]$Name = 'JB-CRM03',

    [String]$Path = 'h:\virtualmachines',

    [Int64]$MemoryStartUpBytes = 2GB,

    [Int64]$MinimumRAM = .5GB,

    [Int64]$ProcessorCount = 4,

    [String]$Switch = 'External',

    [String]$OSTemplate = 'G:\Template\WIN2016',

    [String]$UnattendFile = 'G:\Template\Win2016\autounattend.xml',

    [String]$UnattendISO = "WIN2016STD_Unattended.iso",

    [String]$Key = '89YHN-XPT6M-2THWJ-9FB79-T84BC'
)

$VerbosePreference = 'Continue'





# ------------------------------------------------------------

# ----- Delete VM  probably don't want to do this automatically

#$OldVM = Get-VM -ComputerName $HVHost -name $Name -ErrorAction SilentlyContinue

if ( $OldVM ) {
    if ( (Read-Host "$Name VM already exists.  Do you want to delete it? (y/N)").ToLower() -eq 'y' ) {

        write-verbose "Deleting existing VM"

        Clear-DnsClientCache

        Stop-VM -VM $OldVM -Force

        Remove-VM -VM $OldVM -Force

        IF ( $HVHost -ne $env:COMPUTERNAME ) {
            Remove-Item "\\$HVHost\$($OldVM.Path.Replace(':','$'))" -Recurse -Force
        }
        Else {
            Remove-Item $OldVM.Path -Recurse -Force
        }
    }
    else {
        Write-Warning "You do not want to delet the existing VM: $Name"
        Break
    }
}


#-------------------------------------------------------------




Copy-item $UnattendFile -Destination $OSTemplate\iso\AutoUnattend.xml  -Force

# ----- Edit the Unattend file for the correct ComputerName
Write-verbose "Edit Computer Name in Unattend.xml"
$XML = [xml](Get-Content "$OSTemplate\iso\AutoUnattend.xml" )
(($xml.unattend.settings | where pass -eq specialize).component | where name -eq "Microsoft-Windows-Shell-Setup").ComputerName = $Name
(($xml.unattend.settings | where pass -eq specialize).component | where name -eq "Microsoft-Windows-Shell-Setup").ProductKey = $Key
$XML.Save( "$OSTemplate\iso\AutoUnattend.xml" )

# ----- Create new ISO
write-Verbose "Create new ISO with Unattended.xml"
#Set-Location ($Path -split '\\')[0]

Try {
    if ( Test-Path -Path "$OSTemplate\$UnattendISO" ) { Remove-Item -Path "$OSTemplate\$UnattendISO" -ErrorAction Stop  }

    # ----- had to use start-Process due to how powershell treats parameters : http://microsoft.public.windows.powershell.narkive.com/jjog5ts5/oscdimg-with-powershell
    Start-Process -FilePath 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe' -ArgumentList "-b$OSTemplate\ISO\boot\etfsboot.com -u2 -h -m -lWIN_Server_2016 $OSTemplate\iso $OSTemplate\$UnattendISO"  -wait -ErrorAction Stop
}
Catch {
    $EXceptionMessage = $_.Exception.Message
    $ExceptionType = $_.exception.GetType().fullname
    Throw "ERROR : Problem creating Unattend ISO.`n`n     $ExceptionMessage`n`n     Exception : $ExceptionType" 
}

# ----- copy to remote server if needed

IF ( $HVHost -ne $env:COMPUTERNAME ) {
    Copy-item -Path "$OSTemplate\$UnattendISO" -Destination "\\$HVHost\C$\temp\" -force
    $OSTemplate = "c:\temp"   
}

 invoke-command -ComputerName $HVHost -scriptblock {
    $VerbosePreference = 'Continue'

    # ----- Create New VM 
    Try {
        Write-Verbose "Creating VM"
        $VM =New-VM -ComputerName $Using:HVHost -Name $Using:Name  -MemoryStartupBytes $Using:MemoryStartUpBytes -Path $Using:Path -NewVHDPath "$($Using:Name).vhdx" -NewVHDSizeBytes 128849018880  -SwitchName $Using:Switch -ErrorAction Stop
    } 
    Catch {
        $EXceptionMessage = $_.Exception.Message
        $ExceptionType = $_.exception.GetType().fullname
        Throw "ERROR : There was a problem creating the new VM.`n`n     $ExceptionMessage`n`n     Exception : $ExceptionType"   
    }


    # ----- Configure VM
    Set-VM -VM $VM -DynamicMemory -ProcessorCount $Using:ProcessorCount -MemoryMinimumBytes $Using:MinimumRam
 
    # ----- Mount ISO

    

    Set-VMDvdDrive -ComputerName $Using:HVHost -VMName $VM.Name -Path "$Using:OSTemplate\$Using:UnattendISO"


    Write-Verbose "Starting VM $Using:Name"
    Start-VM -VM $VM 




}

# ----- Because our DNS is configured wonky, we have to use the FQDN for DNS resolution.
$FQDNName = $Name + '

# ----- wait for OS to be installed and configured via unattend.xml
$Timeout = 120
$T = 0
while ( -Not (Test-Connection -ComputerName $FQDNName -Count 1 -Quiet) ) {
    Write-Output "Configuring ...($T)"
    $T ++
    if ( $T -ge $Timeout ) { Throw "Error : Timeout Reached waiting for Server to Retart.`n`nTo verify the server is back up relies on pinging the system.  If the firewall does not allow ping then this process will fail and timeout." }
    Start-sleep -seconds 10
}

# ----- Reboot Server to Complete AutoUnattend
Write-Verbose "Rebooting Computer"
Restart-Computer -ComputerName $FQDNName -Wait -For PowerShell -Force

# ----- Having problems creating temp dir on remote machine.  Pausing to make sure everything is online
$Pause = 180
For ( $I = 1; $I -le 100; $I++ ) {

    Write-Progress -Activity 'Waiting for VM' -PercentComplete $I -CurrentOperation "$I Complete" -status 'Please wait'
    Start-Sleep -Seconds ([int]($Pause/100))
}



# ----- add the DSC Cert 
# ----- https://msdn.microsoft.com/en-us/powershell/dsc/securemof
#Write-Verbose "Importing DSC Certificate"


#if ( -Not (Test-Path "\\$Name\c$\Temp") ) { New-item -Path "\\$Name\c$\Temp" -ItemType Directory }

#Copy-Item -Path "xxx\c$\DSCScripts\DscPrivateKey.pfx" -Destination "\\$Name\c$\Temp" -Force

#Invoke-Command -ComputerName $Name -ScriptBlock {
#    $mypwd = ConvertTo-SecureString -String "xxx" -Force -AsPlainText
#    Import-PfxCertificate -FilePath "C:\temp\DscPrivateKey.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd
#}

# ----- For my lab I shut off the windows firewall
#Write-Verbose "Making sure firewall is off for LAB."
#$Session = New-CimSession -ComputerName $Name 
#Get-NetFirewallprofile -CimSession $Session | Set-NetFirewallProfile -Enabled False

# ----- Cleanup
Write-verbose "Removing ISO from VM drive"
invoke-Command -ComputerName $HVHost -ScriptBlock {
    
    Set-VMDvdDrive -ComputerName $Using:HVHost -VMName $Using:Name -Path $Null
}
