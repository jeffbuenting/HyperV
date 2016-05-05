$Catalog = Get-QADComputer -SearchRoot 'vbgov.com/managed/computers/comit/systems support' 

ForEach($Machine in $Catalog) {
    $QueryString = Gwmi Win32_OperatingSystem -Comp $Machine.name 
    $QueryString = $QueryString.Caption 
    Write-Host $Machine.name ":" $QueryString
}