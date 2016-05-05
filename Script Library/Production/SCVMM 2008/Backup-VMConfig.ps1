#---------------------------------------------------------------------------
# Backup-VMConfig.ps1
#
# Backs up the VM config from VMM.  Stores it in an excel spreadsheet.
#---------------------------------------------------------------------------

add-pssnapin Microsoft.systemcenter.virtualmachinemanager

Get-VMMServer VBAS0080

$Date = "{0:yyyy-MM-dd}" -f (Get-Date)


Get-VM | export-csv c:\Temp\VMConfigBU_$Date.csv

$ToLocation = "\\vbgov.com\deploy\Disaster_Recovery\scvmm\Data\BU desc and owners of vms"

Move-Item c:\Temp\VMConfigBU_$Date.csv $ToLocation

#Remove backups over 2 weeks old ----------------------------------------------get

$Date = (Get-Date).adddays(-14)

set-location $ToLocation
 
dir | where { $_.Lastwritetime -lt $Date } | foreach {
    remove-item $_.name
}


#dir $ToLocation | where { $_.Lastwritetime -lt $Date } | foreach {
 #   $Filename = $ToLocation+$_.name
 #   remove-item -path $Filename
#}