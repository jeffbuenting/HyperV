$computer = "VMAS9063"
Get-WmiObject -Class MSFT_SIPESGlobalRegistrarSetting -Namespace root\cimv2 -ComputerName $computer

