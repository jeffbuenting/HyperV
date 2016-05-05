function GET-RemoteEventLog( $Computer, $Days )

{
    $d=Get-Date
	$recent=[System.Management.ManagementDateTimeConverter]::ToDMTFDateTime($d.AddDays(-$Days)) 
	$query="Select LogFile,TimeGenerated,Type,EventCode,Message from Win32_NTLogevent where TimeGenerated >='$recent'"
	$EventLog = Get-WmiObject -computername $computer -query $query 
	Return $EventLog
}

#-------------------------------------------------------------------------------
#- Main
#-------------------------------------------------------------------------------
$Days = 20
$DatetoCheck = (Get-Date).adddays(-$Days)

$RemoteComputer = "vbvs0002.vbgov.com"

#gets the entire Event Log for the computer from the last $N days
#	Get just the events in the Virtual Server Log
# 	Pull out just the possible start and stop events

$Elog = Get-RemoteEventLog $RemoteComputer $Days | where-object { $_.logfile –eq “Virtual Server” } | where-object { ($_.eventcode –eq "1024") -or ($_.eventcode -eq "1032")  } | Where-Object { ($_.message -like "*started*") -or ($_.message -like "*turned off*" ) }

$StartStop = $Elog

$VMList = get-vm -vmmserver "vbas0053" | where { ( $_.status -eq "PowerOff" ) -and ( $_.hostname -eq $RemoteComputer )}

$VMList | foreach {
	$StartDate = (Get-Date).adddays(-700)					#Seed dates to begin the comparison.  Itially 2 yr ago.
	$StopDate = (Get-Date).adddays(-700)
	foreach ( $e in $StartStop ) {							#Find out when the last time the VM was started
		$TempSTR = $e.message.trimstart('"')                #remove the first quote
		if ($_ -eq $TempStr.substring(0,($tempStr.indexof('"')) ) ) {
			if ( $e.message -like "*started*" ) {
			   	$Date = [System.Management.ManagementDateTimeConverter]::ToDateTime($e.timegenerated)
				if ( $Date -gt $StartDate ) { $StartDate = $Date }
			}
			if ( $e.message -like "*turned off*" ) {
			   	$Date = [System.Management.ManagementDateTimeConverter]::ToDateTime($e.timegenerated)
				if ( $Date -gt $StopDate ) { $StopDate = $Date }
			}
		}
	}

	#Still off
	if ( $StopDate -lt $DatetoCheck ) {			
		"$_ has not been started in the last $Days days."
	}
}



