get-vmmserver "vbas0053"

$vm = get-vm | where { $_.hostname -eq "vbvs0001.vbgov.com" -and $_.state -eq "Running" }

foreach( $V in $VM ){

    ping $V
}


