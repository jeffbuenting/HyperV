Function Write-HVCPUPerformance {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String]$FileName,

        [PSObject[]]$CPUPerformance
    )

    Begin {
        Write-Verbose "Write CPU Performance Header"
        Add-Content $FileName  "<table width='100%'>"
 	    Add-Content $FileName "<tr bgcolor=#BE81F7>"
        Add-Content $FileName "<td width='33.3%' align=center>Time Stamp</td>"
        Add-Content $FileName "<td width='33.3%' align=center>CPU Instance</td>"
        Add-Content $FileName "<td width='33.3%' align=center>% Total Run Time</td>"
        Add-Content $FileName "</tr>"

        Write-Verbose "Setting Waringing Colors"
        [Array]$WarningLevel = "#77FF5B","#FFF632","#FF6B6B","#FF0040"

    }
     
    Process {
        Foreach ( $CPU in $CPUPerformance ) {
            Write-Verbose "Writing $($CPU.TotalRunTimPercent.CounterSamples.InstanceName)"
	        Add-Content $FileName "<tr bgcolor=#77FF5B>" 
	        Add-Content $FileName "<td width='33.3%' BGCOLOR='#77FF5B' align=center>$($CPU.TimeStamp)</td>"
	        Add-Content $FileName "<td width='33.3%' BGCOLOR='#77FF5B' align=center>$($CPU.InstanceName)</td>" 
	        Add-Content $FileName "<td width='33.3%' BGCOLOR='$($WarningLevel[$CPU.Health])' align=center>$($CPU.PercentRunTime) GB</td>" 
	        Add-Content $FileName "</tr>"
        }
    }
}