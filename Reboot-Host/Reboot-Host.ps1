clear-host

get-vmmserver "vbas0053" | out-null

$Server = read-host "Enter the name of the Host you want to reboot"
$Server = $Server + ".vbgov.com"

# Get a list of VM's running

$VM = get-vm | where { $_.state -eq "Running" -and $_.hostname -eq $Server } 

#Save state of VM's

foreach ( $I in $VM ) {
    savestate-vm -vm $I
    Write-host "Saving state on ",$I
}

#Reboot VMHost

$S = gwmi win32_operatingsystem -computer $Server 
$S.reboot() 

#Wait for Host to complete reboot.
#wait until the computer is off

do {
    ping $server
} while ( $lastexitcode -ne 0 )

#while ( $lastexitcode -eq 0 )

#wait until the computer is back on

do {
    ping $server
} while ( $lastexitcode -ne 0 )

#restore State

foreach ( $I in $VM ) {
    start-vm -vm $I
    write-host "Starting VM ",$I
}