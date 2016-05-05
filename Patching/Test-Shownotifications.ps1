#------------------------------------------------------------------------------
# Test-shownotifications.ps1
#------------------------------------------------------------------------------

# ----- Script requires elevation.  Check to see if running as admin.  if not restart eleveted
Import-Module "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\UACPSModule\UASPSModule.psm1"
Restart-ScriptAsAdmin

Import-Module "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Patching\SCCMPSModule\SCCMPSModule.psm1"

#show-SCCMNotifications -ComputerName 'VBNS0022' -Notify

Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")