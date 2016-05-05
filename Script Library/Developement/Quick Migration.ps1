# ------------------------------------------------------------------------------
# Quick migration 
#
#
#Migrate Virtual Machine Wizard Script
# ------------------------------------------------------------------------------
# Script generated on Thursday, June 19, 2008 2:04:32 PM by Virtual Machine Manager
# 
# For additional help on cmdlet usage, type get-help <cmdlet name>
# ------------------------------------------------------------------------------

$VM = Get-VM -VMMServer vmas9072 -Name "VMAS9073" | where {$_.VMHost.Name -eq "VBVS0008.vbgov.com"}
$VMHost = Get-VMHost -VMMServer vmas9072 | where {$_.Name -eq "VBVS0007.vbgov.com"}

Move-VM -VM $VM -VMHost $VMHost -RunAsynchronously -JobGroup fd3bdce0-7a21-46be-982a-606daf86a0e2 

