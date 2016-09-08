#List Virtual Machines snapshotdata in a .csv file
add-pssnapin Microsoft.SystemCenter.VirtualMachineManager
Get-VMCheckpoint -vmmserver vbas0080.vbgov.com |Select vm,addedtime | Export-Csv C:\Temp\VirtualMachineCheckPointData.csv
c:\Temp\virtualmachinecheckpointdata.csv

remove-pssnapin Microsoft.SystemCenter.VirtualMachineManager
