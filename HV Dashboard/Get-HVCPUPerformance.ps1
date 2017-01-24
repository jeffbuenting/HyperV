Function Get-HVCPUPerformance {

    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline=$True )]
        [String[]]$ComputerName = $Env:COMPUTERNAME,

        [int]$MaxRunSpaces = $Env:NUMBER_OF_PROCESSORS + 1
    )

    Begin
    {
        Write-verbose "Create Runspace Pool"
        $RunSpacePool = [RunspaceFactory]::CreateRunspacePool( 1,$MaxRunSpaces)
        $RunSpacePool.ApartmentState = 'MTA'
        $RunSpacePool.Open()
    }

    Process {
        ForEach ( $C in $ComputerName ) {
            Write-Verbose "Retrieving Perfromance data for $C"

            $CPURunTime = get-counter  -ComputerName $C -Counter "Hyper-V Hypervisor Logical Processor(*)\% Total Run Time" 

            $TimeStamp = $CPURunTime.TimeStamp
            $CPURunTime.CounterSamples | Foreach {
                
                # ----- Determine the health of the value
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

    End
    {
        Write-Verbose "Runspace cleanup"
        $RunSpacePool.Close()
        $RunSpacePool.Dispose()
    }
}

$StopWatch = [system.diagnostics.stopwatch]::StartNew()


 'SL-Jeffb' | Get-HVCPUPerformance -Verbose

 $StopWatch.Elapsed
