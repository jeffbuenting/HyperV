$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut" | out-Null

$TestCases = @(
    @{
        TestName = 'One Server'
        ComputerName = $env:COMPUTERNAME
    }
    
    @{
        TestName = 'Multiple Servers'
        ComputerName = $env:COMPUTERNAME,$env:COMPUTERNAME,$env:COMPUTERNAME
    }

    @{
        TestName = 'No Server Name passed'  
    }
)

Describe "Get-HVCPUPerformance" {
    It "Returns a custom object.  Test: <TestName>" -TestCases $TestCases {
        param 
        (
            $ComputerName
        )

        if ( $Computername ) 
        {
            $output = Get-HVCPUPerformance -ComputerName $ComputerName -Verbose
        }
        Else 
        {
            $output = Get-HVCPUPerformance -Verbose
        }

        $Output | Should BeofType PSCustomObject
    }

    It "Should be for counter Hyper-V HyperVisor Locical Processor % Total Run Time. Test: <TestName>" -TestCases $TestCases {
        param 
        (
            $ComputerName
        )

        if ( $Computername ) 
        {
            $output = Get-HVCPUPerformance -ComputerName $ComputerName -Verbose
        }
        Else 
        {
            $output = Get-HVCPUPerformance -Verbose
        }

        $Output.Path | Should Match "hyper-v hypervisor logical processor\(.*\)\\% total run time"
    }
}
