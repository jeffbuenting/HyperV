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

        $Command = {
            param (
                [String]$Computer
            )
            
            $CPURunTime = get-counter -ComputerName $Computer -Counter "Hyper-V Hypervisor Logical Processor(*)\% Total Run Time" 

            $TimeStamp = $CPURunTime.TimeStamp
            $CPURunTime.CounterSamples | Foreach {
                
                # ----- Determine the health of the value
                if ( $_.CookedValue -ge 90 ) { $H = 2 }
                    Elseif ( $_.CookedValue -ge 80 -and $_.CookedValue -Lt 90 ) { $H = 1 }
                        Else { $H = 0 }
                
                $CPU = New-Object psobject -Property @{
                    ComputerName = $Computer
                    Path = $_.Path
                    InstanceName = $_.InstanceName
                    PercentRunTime = $_.CookedValue
                    Health = $H
                }

                Write-Output $CPU
            }
        }
    }

    Process {
        ForEach ( $C in $ComputerName ) {
            Write-Verbose "Retrieving Perfromance data for $C"

            $RunSpaceObject = New-Object -TypeName PSObject -Property @{
                Runspace = [Powershell]::Create()
                Invoker = $Null
            }

            $RunSpaceObject.RunSpace.RunspacePool = $RunSpacePool
            $RunSpaceObject.Runspace.AddScript( $Command ) | Out-Null
            $runSpaceObject.RunSpace.AddArgument( $C ) | Out-Null
            $RunSpaceObject.Invoker = $RunspaceObject.RunSpace.BeginInvoke()

            # ----- Wait for Runspace to complete
            Write-Verbose "Waiting for Runspace to complete for $C"
            While ( $RunSpaceObject.Invoker.IsCompleted -eq $False ) {}

            $HVCPU = $RunSpaceObject.Runspace.EndInvoke( $RunSpaceObject.Invoker )
            $RunspaceObject.Runspace.Dispose()

            Write-Output $HVCPU
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


 'SL-Hyperv1.stratuslivedemo.com','SL-Jeffb' | Get-HVCPUPerformance -Verbose

 $StopWatch.Elapsed
