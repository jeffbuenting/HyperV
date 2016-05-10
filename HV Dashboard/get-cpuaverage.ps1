Import-Module 'F:\OneDrive for Business\Scripts\Hyper-v\hyperv_custom.psm1'

$ServerList = 'SL-Hyperv1','SL-Hyperv2'

$NumValuestoKeep = 20

$HostCPUFile = 'f:\temp\HostCPU.csv'

$CPUPerformanceCounter = @()
$CPUPerformanceCounter += Import-CSV $HostCPUFile

ForEach ( $S in $ServerList ) {
    # ----- Add current value to the array
    $CPUPerformanceCounter += Get-HVCPUPerformance -ComputerName $S | where instanceName -eq _Total | Select-Object TimeStamp,ComputerName,InstanceName,PercentRunTime
}

# ----- Write newest 10
$CPUPerformanceCounter | Sort-Object -Descending TimeStamp | Select-Object -Last 10 | Export-CSV $HostCPUFile -NoTypeInformation -Force

ForEach ( $S in $serverList ) {
    ($CPUPerformanceCounter | where ComputerName -eq $S ).PercentRunTime | Measure-Object -Average -Maximum #| Select-Object -ExpandProperty Average
}



# ----- Get older values
#Import-CSV f:\temp\HostCPU.csv | Foreach { $CPUPerformanceCounter += $_ }

# ----- Add current value to the array
#$CPUPerformanceCounter += Get-HVCPUPerformance -ComputerName sl-jeffb | where instanceName -eq _Total | Select-Object TimeStamp,ComputerName,InstanceName,PercentRunTime 

# ----- Write newest 10
#$CPUPerformanceCounter | Sort-Object -Descending TimeStamp | Select-Object -Last 10 | Export-CSV F:\temp\HostCPU.csv -NoTypeInformation -Force

# ----- Average
#($CPUPerformanceCounter.PercentRunTime) | Measure-object -Average | Select-Object -ExpandProperty Average