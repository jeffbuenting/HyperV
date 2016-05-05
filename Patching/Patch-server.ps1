#------------------------------------------------------------------------------
# Patch-Server.sp1
#
# Patches a Server
#------------------------------------------------------------------------------


#----------------------------------------------------------------------------
# Main
#----------------------------------------------------------------------------

$Server = 'VBVS0012.vbgov.com'

# ----- Script requires elevation.  Check to see if running as admin.  if not restart eleveted
Import-Module "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\UACPSModule\UASPSModule.psm1"
Restart-ScriptAsAdmin

Import-Module "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Patching\SCCMPSModule\SCCMPSModule.psm1"

# ----- Patch Node
Install-SCCMUpdates -ComputerName $Server -Cred $Cred -Reboot

Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")