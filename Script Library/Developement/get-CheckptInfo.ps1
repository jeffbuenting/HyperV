#---------------------------------------------------------------------------------
# Get-CheckptInfo
#
# Checks to see if a checkpoint exists and lists the checkpoints
#---------------------------------------------------------------------------------

#---------------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------------

Get-VMMServer vmas9072 

$VM = Get-VM -Name test

$Checkpts = Get-VMCheckpoint -VM $VM

if ( $Checkpts -eq $NULL ) {
        "There are no checkpts"
    }
    Else {
        "Here is a list of the checkpoints:"
        $Checkpts
}


