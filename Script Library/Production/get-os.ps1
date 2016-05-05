$VB = Get-QADComputer -Name vbdb* -OSName '*2008*'
$VM = Get-QADComputer -Name vmdb* -OSName '*2008*'

$Servers = $VB + $VM

$servers | ft name 

