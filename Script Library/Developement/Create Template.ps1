# ------------------------------------------------------------------------------
# New Template Wizard Script
# ------------------------------------------------------------------------------
# Script generated on Friday, June 20, 2008 12:09:29 PM by Virtual Machine Manager
# 
# For additional help on cmdlet usage, type get-help <cmdlet name>
# ------------------------------------------------------------------------------


Set-VirtualFloppyDrive -RunAsynchronously -VMMServer vmas9072 -NoMedia -JobGroup 079b175b-b16a-462c-8d3a-7d4e11e7023a 


New-VirtualNetworkAdapter -VMMServer vmas9072 -JobGroup 079b175b-b16a-462c-8d3a-7d4e11e7023a -PhysicalAddressType Dynamic -VLanEnabled $false -Synthetic 


New-VirtualDVDDrive -VMMServer vmas9072 -JobGroup 079b175b-b16a-462c-8d3a-7d4e11e7023a -Bus 1 -LUN 0 

$CPUType = Get-ProcessorType -VMMServer vmas9072 | where {$_.Name -eq "1-processor 3.33 GHz Xeon MP"}


New-HardwareProfile -VMMServer vmas9072 -Owner "VBGOV\jbuentin" -CPUType $CPUType -Name "Profile45625beb-a470-46f4-b8a9-371d717fd2f7" -Description "Profile used to create a VM/Template" -CPUCount 2 -MemoryMB 2048 -ExpectedCPUUtilization 20 -DiskIO 0 -NetworkUtilization 10 -RelativeWeight 100 -HighlyAvailable $false -NumLock $false -BootOrder "CD", "IdeHardDrive", "PxeBoot", "Floppy" -LimitCPUFunctionality $false -JobGroup 079b175b-b16a-462c-8d3a-7d4e11e7023a 


$VM = Get-VM -VMMServer vmas9072 -Name "VMAS9299" | where {$_.VMHost.Name -eq "VBVS0007.vbgov.com"}
$LibraryServer = Get-LibraryServer -VMMServer vmas9072 | where {$_.Name -eq "vbvs0001.vbgov.com"}
$HardwareProfile = Get-HardwareProfile -VMMServer vmas9072 | where {$_.Name -eq "Profile45625beb-a470-46f4-b8a9-371d717fd2f7"}
$AdminPasswordCredential = get-credential
$JoinDomainCredential = get-credential
$OperatingSystem = Get-OperatingSystem -VMMServer vmas9072 | where {$_.Name -eq "Windows Server 2003 Standard x64 Edition"}

New-Template -Name "WIN 2008 Standard R2 wSP2 x64" -RunAsynchronously -Owner "VBGOV\jbuentin" -VM $VM -LibraryServer $LibraryServer -SharePath "\\vbvs0001.vbgov.com\VMM Library\VHD Templates" -HardwareProfile $HardwareProfile -JobGroup 079b175b-b16a-462c-8d3a-7d4e11e7023a -ComputerName "*" -FullName "" -OrgName "" -ProductKey "CPCDM-HJJWH-HBPTY-PDBGX-KMYRT" -TimeZone 35 -AdminPasswordCredential $AdminPasswordCredential -JoinDomain "vbgov.com" -JoinDomainCredential $JoinDomainCredential -AnswerFile -OperatingSystem $OperatingSystem 

