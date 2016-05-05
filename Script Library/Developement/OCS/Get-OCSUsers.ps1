
$SysSupport = Get-QADGroupMember -Identity "Comit Systems Support-U"

get-wmiobject -class msft_sipesusersetting | Foreach {
    foreach ( $user in $sysSupport ) {
	    $SysSupportMember = "False"
	    if ( $User.name -eq $_.displayname ){    # OCS enabled user is a member of COMIT Systems Support-U
		    $SysSupportMember = "True"
			"Member"
		}
	}
	$syssupportmember
	If ( ( $sysSupportMember -eq "False") -and ( $_.EnabledForInternetAccess  -eq  $true ) ) {
		$_.displayname
		$I++	
	}
}
	
