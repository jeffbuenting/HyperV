#--------------------------------------------------------------------------------------

Function Backup-VM {

<#
    .Synopsis
        Backs up Hyper-v VM
        
    .Description
        Backs up VM to specified location.  Optionally will clean up older files if required.    
        
    .Parameter VM
        VM object to be backed up.
        
    .Parameter Destination
        File location where the VMs will be backed up. 
        
    .Parameter Cleanup
        if True then the folders older than the DaystoKeep will be deleted.
        
    .Parameter DaystoKeep
        number of days to save backups.  Anything older (In days) and the files will be deleted.
        
    .Example
         Backs up the VM 'Test' to the specified location.  No clean up is performed

         get-vm -Name 'Test' | backup-vm -Destination 'F:\VM Backups'

    .Example
        Backs up the VM 'Test' to the specified location .  Files for Test older than 14 days will be deleted.

        get-vm -Name 'Test' | backup-vm -Destination 'F:\VM Backups' -Cleanup -DaystoKeep 14
#>

    # ----- TODO: Create Excluded list

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeLine=$True)]  
        [Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,

        [Parameter(Mandatory=$true)]  
        [String]$Destination,

        [Switch]$CleanUp = $False
    )

    # ----- Dynamic Parameter help: http://www.powershellmagazine.com/2014/05/29/dynamic-parameters-in-powershell/
    #                               https://technet.microsoft.com/en-us/library/hh847743.aspx
    DynamicParam {
        if ( $CleanUp ) {
            $attributes = new-object System.Management.Automation.ParameterAttribute
            $attributes.ParameterSetName = "__AllParameterSets"
            $attributes.Mandatory = $false
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $dynParam1 = new-object -Type System.Management.Automation.RuntimeDefinedParameter("DaystoKeep", [int], $attributeCollection)
            $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add("DaystoKeep", $dynParam1)
            return $paramDictionary
        }
    }

    Begin {
        Write-Verbose "Creating Backup location"
        $Date = Get-Date -UFormat "%Y-%B-%d"
        Write-Verbose "Date: $Date"
        if ( Test-Path "$Destination\$Date" -eq $False ) { MD "$Destination\$Date" | Out-Null }
    }

    Process {
        ForEach ($V in $VM) {
            Write-Verbose "Backing up VM -- $VM"
            Write-Verbose "     Saving VM"
            if ( $V.State -eq 'Running' ) { Save-VM -VM $V }
            Write-Verbose "Copying Files"
            copy-item -Path $V.Path -Destination "$Destination\$Date" -recurse
            if ( $V.State -eq 'Running' ) { Start-VM -VM $V }
        }
    }

    End {
        if ( $CleanUp ) {
            Write-Verbose "Checking for old VM Backups"
            # ----- TODO:  Get the cleanup proceedure I have at home.
            # ------ Note:  Only check for the Specified VM and only delete those older files.

        }
    }
            
}

get-vm -Name 'Test' | backup-vm -Destination 'F:\VM Backups' -verbose