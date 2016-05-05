#---------------------------------------------------------------------------
# Set-Timeout
#
# Modifys the Timeout of a rule
#---------------------------------------------------------------------------

Set-Location "C:\Program Files\System Center Operations Manager 2007"
& ".\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Startup.ps1"

# Get the Root Management Server.
$managementServer = Get-rootManagementServer 

$WorkFlowName = "Microsoft.SystemCenter.HealthService.SCOMpercentageCPUTimeMonitor
"
"Discovery"

$RuleInfo = Get-Discovery -Criteria "Name='$WorkFlowName'"

$RuleInfo

"Rule"
Get-Rule -Criteria "Name='$WorkFlowName'"

"Monitor"
Get-Monitor -Criteria "Name='$WorkFlowName'"

#Get-Rule | where { $_.Id -eq $RuleID }



 

#            discoveryOverride.Discovery     = discovery;
#
#            discoveryOverride.Property      = ManagementPackWorkflowProperty.Enabled;
#
#            discoveryOverride.Value         = "false";
#
#            discoveryOverride.Context       = monitoringClass;
#
#            discoveryOverride.DisplayName   = "SampleDiscoveryOverride";
			
			
#$MP = get-managementpack | where { $_.DisplayName -eq "Custom - Timeouts" }

#$OverRide =  New-Object Microsoft.EnterpriseManagement.Configuration.ManagementPackRulePropertyOverride $mp,"Overide.Timeout.$WorkFlowName"
#
#$OverRide
#$OverRide.Rule = $RuleInfo
#$OverRide.Value = 'e'
#>$override.Context = $rule.Target
#>$override.DisplayName = 'Test Override'
#>$mp.Verify()
#>$mp.AcceptChanges()
