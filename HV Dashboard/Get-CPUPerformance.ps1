Import-Module 'c:\Scripts\Hyper-v\hyperv_custom.psm1' -force

# ----- Input and Output files are located here
$FilePath = 'c:\scripts\data'
# ( Split-Path -parent $MyInvocation.MyCommand.Definition)
$HostCPUFile = "$($FilePath)\CloudHostCPU.csv"
$VMCPUFile = "$($FilePath)\CloudVMCPU.csv"

$ServerList = Get-Content "$($FilePath)\Servers.txt"

Foreach ( $C in $ServerList ) {
 #   Write-EventLog -LogName Application -Source PowershellScript -entrytype Information -EventId 9999 -Message "Getting Info for: $C"
    Get-HVCPUPerformance -ComputerName $C | where instanceName -eq _Total | Out-CountertoCSV -FileName $HostCPUFile -SecondstoKeep 86400

    get-vm -ComputerName $C | Select-Object -ExpandProperty Name | Get-CPUPerformance | where instanceName -eq _Total | Out-CountertoCSV -FileName $VMCPUFile -SecondstoKeep 86400
    
}




