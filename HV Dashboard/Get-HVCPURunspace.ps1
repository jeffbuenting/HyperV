Function Get-HVCPU {

    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline=$True )]
        [String[]]$ComputerName
    )

    Process {
        ForEach ( $C in $ComputerName ) {
            Write-Verbose "Retrieving Perfromance data for $C"

            $CPURunTime = get-counter  -ComputerName $C -Counter "Hyper-V Hypervisor Logical Processor(*)\% Total Run Time" 
            $TimeStamp = $CPURunTime.TimeStamp
            $CPURunTime.CounterSamples | Foreach {
                
                if ( $_.CookedValue -ge 90 ) { $H = 2 }
                    Elseif ( $_.CookedValue -ge 80 -and $_.CookedValue -Lt 90 ) { $H = 1 }
                        Else { $H = 0 }
                
                $CPU = New-Object psobject -Property @{
                    ComputerName = $C
                    Path = $_.Path
                    InstanceName = $_.InstanceName
                    PercentRunTime = $_.CookedValue
                    Health = $H
                }
                Write-Output $CPU
            }
        }
    }
}

$StopWatch = [system.diagnostics.stopwatch]::StartNew()


 'SL-Hyperv1.stratuslivedemo.com','SL-Jeffb' | Get-HVCPu -Verbose

 $StopWatch.Elapsed