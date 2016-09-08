get-vmmserver VBAS0080
$CheckPoints=get-vmcheckpoint

$CheckPoints | select-object VM,AddedTime

$Today = Get-Date

foreach ( $CP in $CheckPoints ) {
	$Age = ($Today-$CP.AddedTime).Days
	$VM = $CP.VM
	if ((( $Today-$CP.AddedTime).Days ) -gt 40 ) {
		"----$VM, $Age "
	}
	else {
		"$VM, $Age"
	}
}

Send-MailMessage -To "jbuentin@vbgov.com" -From "COMITAPP95@vbgov.com" -Subject "$VM has an old Checkpoint" -SmtpServer mailrelay.vbgov.com