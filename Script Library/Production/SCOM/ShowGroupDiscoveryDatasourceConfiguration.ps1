# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2007
# 
# NAME: ShowGroupDiscoveryDataSourceConfiguration.ps1
# 
# AUTHOR: Michiel Wouters
# DATE  : 6/30/2010
# 
# COMMENT: Lists all instance and computer groups matching user's wildcard input. With every group
# the membershiprule configuration is shown.
# Adjust the threshold variables for your specific situation
# 
# ==============================================================================================

Set-Location "C:\Program Files\System Center Operations Manager 2007"
& ".\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Startup.ps1"

# Get the Root Management Server.
$managementServer = Get-rootManagementServer




#User-input only works from within a script!
$strGroup = Read-Host "Enter a group discovery name (wildcard) string";

$intMembershipRuleThreshold = 3;
$intMembershipRuleExpressionThreshold = 5;
$intMembershipRuleCount = 0;
$intMembershipRuleExpressionCount = 0;

#These Id's are the base Id's which are usually used when creating groups
$strInstanceGroupBaseClassId = "4ce499f1-0298-83fe-7740-7a0fbc8e2449" #Instance group
$strComputerGroupBaseClassId = "0c363342-717b-5471-3aa5-9de3df073f2a" #Computer group

Write-Host "Retrieving class that match:" $strGroup;
$colGroups = Get-MonitoringClass | where {$_.DisplayName -match "$strGroup" -and $_.Base -ne $null} | Sort-Object -Property DisplayName

if ($colGroups -ne $null) {
	$colGroups | foreach {
		If (($_.Base.Id.ToString() -eq $strInstanceGroupBaseClassId) -Or ($_.Base.Id.ToString() -eq $strComputerGroupBaseClassId)){
			Write-Host "Class:" $_.DisplayName;
			$colDiscoveries = $_.GetMonitoringDiscoveries();
			#check if discoveries exist
			If ($colDiscoveries.Count -ne 0) {
				$colDiscoveries | foreach {
					Write-Host "  Discovery:";
					$config = [xml] ("<config>" + $_.DataSource.Configuration + "</config>");
					#check wether Discovery uses membership rules
					$intMembershipRuleCount = $config.GetElementsByTagName("MembershipRule").Count;
					If($intMembershipRuleCount -gt 0){
						If ($intMembershipRuleCount -ge $intMembershipRuleThreshold){
							Write-Host "    MembershipRules:" $intMembershipRuleCount -ForeGroundColor red;
						} else {
							Write-Host "    MembershipRules:" $intMembershipRuleCount -ForeGroundColor green;
						}
						$intIndex = 0;
						$config.config.MembershipRules.MembershipRule | %{
							$intIndex++;
							$intMembershipRuleExpressionCount = $_.GetElementsByTagName("Expression").Count;
							If ($intMembershipRuleExpressionCount -gt 0) { 
								Write-Host "      Membership Rule #$intIndex";
								If ($intMembershipRuleExpressionCount -ge $intMembershipRuleExpressionThreshold){
									Write-Host "        Expression count:" $intMembershipRuleExpressionCount -ForeGroundColor red;
								} else {
									Write-Host "        Expression count:" $intMembershipRuleExpressionCount -ForeGroundColor green;
								}
							}
							$intMembershipRuleExpressionCount = 0;
						}
					}
					$config = $null;
				  $intMembershipRuleCount = 0;
				}
			}
		}
	}
}
