


get-vmmserver "vmas9072"

get-vmhost | foreach{

$strComputer = $_.name

$colItems = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" `
-computername $strComputer
$_.name |Out-File c:\temp\drives.txt -Append
foreach ($objItem in $colItems) {
      
     $objItem.DeviceID |Out-File c:\temp\drives.txt -Append
      
}
}