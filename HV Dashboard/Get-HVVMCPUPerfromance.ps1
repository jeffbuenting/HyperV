Function Get-CPUPerformance {

    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline=$True )]
        [String[]]$ComputerName = '.',

         [String]$FileName,

        [Switch]$History
    )

     Begin {
        if ( $History ) {
            Write-Verbose "Retrieving the saved data"
            $CPUPerformanceCounter = @()
            $CPUPerformanceCounter = Import-CSV $FileName -ErrorAction SilentlyContinue 

            Write-Debug "Saved data: $($CPUPerformanceCounter | Out-String)"
        }
    }

    Process {
        ForEach ( $C in $ComputerName ) {
            Write-Verbose "Retrieving Perfromance data on Host: $C"
            
            #$CRT = get-counter  -ComputerName $C -Counter "Hyper-V Hypervisor Virtual Processor(*)\% Total Run Time"
            $CPURunTime = Get-Counter -ComputerName $C -Counter "Processor Information(*)\% Processor Time"

            $TimeStamp = $CPURunTime.TimeStamp

            $CPURunTime.CounterSamples | Foreach {
                
                $CPU = New-Object psobject -Property @{
                    ComputerName = $C
                    TimeStamp = $TimeStamp
                    InstanceName = $_.InstanceName
                    PercentRunTime = $_.CookedValue
                }
                
                Write-Debug "Data: $($CPU | Out-String)"

                If ( $History ) {
                        Write-Verbose "Adding new data to the saved data"
                        $CPUPerformanceCounter += $CPU | where instanceName -eq _Total 
                    }
                    else {
                        Write-Verbose "Outputting Info for $($CPU.InstanceName)"
                        Write-Verbose "CPU Counter TimeStamp: $($CPU.Timestamp)"
                        Write-Output $CPU
                }


            }
        }
    }

    End {
        If ( $History ) {
            Write-Verbose "Writing Counters to file"
            $CPUPerformanceCounter | Sort-Object -Descending TimeStamp | Select-Object -Last $NumValuestoKeep | Export-CSV $FileName -NoTypeInformation -Force
           
            Write-Output $CPUPerformanceCounter
        }      
    }
}

'jeffb-crm03','jeffb-sql03' | Get-CPUPerformance -FileName f:\temp\cpuhistory.csv -History