#---------------------------------------------------------------------------------
# Hyper-V custom module
#---------------------------------------------------------------------------------

#---------------------------------------------------------------------------------
# Hyper-V Perfromance Cmdlets
#---------------------------------------------------------------------------------

Function Get-HVCPUPerformance {

<#
    .Description
        Retrieves the CPU Performance information on a Hyper-V server

    .Parameter ComputerName
        Name of the Computer to retrieve the information from.  Defaults to the local host

    .Link
        http://www.fastvue.co/tmgreporter/blog/understanding-hyper-v-cpu-usage-physical-and-virtual


#>

    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline=$True )]
        [String[]]$ComputerName = '.'


    )

    Process {
    
        ForEach ( $C in $ComputerName ) {
            Write-Verbose "Retrieving Perfromance data on Host: $C"

            if ( Test-Connection -ComputerName $C -Quiet ) {
                    Write-Verbose "Computer Exists and is Online"
            
                    #$CRT = get-counter  -ComputerName $C -Counter "Hyper-V Hypervisor Virtual Processor(*)\% Total Run Time"
                    $CPURunTime = get-counter  -ComputerName $C -Counter "Hyper-V Hypervisor Logical Processor(*)\% Total Run Time" 

                    $TimeStamp = $CPURunTime.TimeStamp

                    $CPURunTime.CounterSamples | Foreach {
                
                        $CPU = New-Object psobject -Property @{
                            ComputerName = $C
                            TimeStamp = $TimeStamp
                            InstanceName = $_.InstanceName
                            PercentRunTime = $_.CookedValue
                        }
                
                        Write-Debug "Data: $($CPU | Out-String)"

                        Write-Output $CPU
                    }
                }
                Else {
                    Write-Verbose "$C is either not online or is unreachable"
            }
        }
    }
}

#---------------------------------------------------------------------------------

Function Get-CPUPerformance {

<#
    .Description
        Retrieves the CPU % Time counter and either returns it (PassThru switch) or saves it to a specified file (History Switch)

    .Parameter
        
#>

        [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline=$True )]
        [String[]]$ComputerName = '.'
    )

    Process {
        ForEach ( $C in $ComputerName ) {
            Write-Verbose "Retrieving Perfromance data on Host: $C"

            if ( Test-Connection -ComputerName $C -Quiet ) {
                    Write-Verbose "Computer Exists and is Online"
            
                    #$CRT = get-counter  -ComputerName $C -Counter "Hyper-V Hypervisor Virtual Processor(*)\% Total Run Time"
                    $CPURunTime = Get-Counter -ComputerName $C -Counter "Processor Information(*)\% Processor Time" -ErrorAction SilentlyContinue

                    $TimeStamp = $CPURunTime.TimeStamp

                    $CPURunTime.CounterSamples | Foreach {
                
                        $CPU = New-Object psobject -Property @{
                            ComputerName = $C
                            TimeStamp = $TimeStamp
                            InstanceName = $_.InstanceName
                            PercentRunTime = $_.CookedValue
                        }
                
                        Write-Debug "Data: $($CPU | Out-String)"

                        Write-Output $CPU
                    }
                }
                Else {
                    Write-Verbose "$C is either not online or is unreachable"
            }
        }
    }
}

#---------------------------------------------------------------------------------
# Custom output functions
#---------------------------------------------------------------------------------

Function out-CountertoCSV {

    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline=$True )]
        [PSObject[]]$Object,

        [String]$FileName,

        [Int]$SecondstoKeep = 0
    )

    Process {
        Foreach ( $O in $Object ) {
            Write-Verbose "Writing to CSV File $($O | Out-String)"

            $O |  Export-CSV -Path $FileName -NoTypeInformation -Append
        }
    }

    End {
        if ( $SecondstoKeep -gt 0 ) {
            Write-Verbose "Removing items older than $SecondsToKeep Seconds from the CSV"

            # ----- Had to move Export-CSV to second line (saving data in variable) as there was no data in the saved file.  I believe this was becasue the file was still opened by Import-CSV
            $SavedData = Import-CSV $FileName -ErrorAction SilentlyContinue | where timestamp -ge (get-date).AddSeconds(-$SecondstoKeep) 
            $SavedData | Export-CSV $FileName -NoTypeInformation -Force
         
        }
    }
}

#---------------------------------------------------------------------------------
#---------------------------------------------------------------------------------

