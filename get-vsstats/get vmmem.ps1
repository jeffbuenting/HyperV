function Get-RAM ( $Computer )

{
    $ram=WmiObject Win32_ComputerSystem
    return ( $ram.TotalPhysicalMemory )
}


$computer = "."

$Mem = Get-RAM $Computer

$Mem
