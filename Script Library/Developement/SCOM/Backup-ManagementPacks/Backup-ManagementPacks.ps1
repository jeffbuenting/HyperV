#----------------------------------------------------------------------------------------------------------------
# Backup-ManagementPacks
#
# Backu
#-----------------------------------------------------------------------------------------------------------------


# ----- Configure powershell for SCOM

Set-Location "C:\Program Files\System Center Operations Manager 2007"
& ".\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Startup.ps1"

# Get the Root Management Server.
$managementServer = Get-rootManagementServer

# ----- Export all MP to xml

get-managementpack | export-managementpack -path D:\SCOMMPBackup

# ----- Copy MPs to backup location

$Date = "{0:yyyy-MM-dd}" -f (Get-Date)

$ToLocation = "\\vbgov.com\deploy\Disaster_Recovery\SCOM\MPBackups\$Date"
New-Item $ToLocation -itemtype directory
Move-item d:\SCOMMPBackups\*.* $ToLocation

# ----- Remove Backups over 2 weeks old




#
#
#
##Copy the files to \\vbfp0012\Disaster_Recovery\Office Communications Server\Backups\VMAS0073\OCS and files ---------
#
#
#
##Remove backups over 2 weeks old ------------------------------------------------------------------------------------
#
#$Date = (Get-Date).adddays(-14)
# 
#dir $ToLocation | where { $_.Lastwritetime -lt $Date } | foreach {
#    $Filename = $ToLocation+$_.name
#    remove-item -path $Filename
}




