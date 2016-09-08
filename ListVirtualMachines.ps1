#List Virtual Machines in a .csv file
add-pssnapin Microsoft.SystemCenter.VirtualMachineManager
get-vm -vmmserver vbas0080.vbgov.com| Select Name,OperatingSystem,@{label='Total Size(GB)';expression={($_.TotalSize / 1gb).tostring("F02")}},CreationTime,LimitCPUFunctionality,VMCheckPoints| Export-Csv C:\Temp\VirtualMachineData.csv
c:\Temp\virtualmachinedata.csv

remove-pssnapin Microsoft.SystemCenter.VirtualMachineManager