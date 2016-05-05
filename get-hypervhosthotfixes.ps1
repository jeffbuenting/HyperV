Get-VMMServer vbas0080 | Out-Null

$Computers = Get-VMHost

$Hotfixes = Get-Content "\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\HotfixList.txt"

$CsvFilePath = "C:\temp\hotfix.csv" 
 
#Variable for writing progress information 
$TotalComputers = ($computers | Measure-Object).Count 
$CurrentComputer = 1 
  
#Create array to hold hotfix information 
$Export = @() 
 
#Splits the array if more than one hotfix are provided 
$Hotfixes = $HotFix.Split(",") 
 
#Loop through every computers   
foreach ($computer in $computers) { 
 
#Loop through every hotfix 
foreach ($hotfix in $hotfixes) { 
#Write progress information 
Write-Progress -Activity "Checking for hotfix $hotfix..." -Status "Current computer: $($computer.name)" -Id 1 -PercentComplete (($CurrentComputer/$TotalComputers) * 100) 
 
#Create a custom object for each hotfix 
$obj = New-Object -TypeName psobject 
$obj | Add-Member -Name Hotfix -Value $hotfix -MemberType NoteProperty 
$obj | Add-Member -Name Computer -Value $computer.Name -MemberType NoteProperty 
$obj | Add-Member -Name OS -Value $computer.OperatingSystem -MemberType NoteProperty
 
#Check if hotfix are installed  
 try { 
 if (Test-Connection -Count 1 -ComputerName $computer.name -Quiet) { 
 Get-HotFix -Id $hotfix -ComputerName $computer.Name -ea stop | Out-Null 
 $obj | Add-Member -Name HotfixInstalled -Value $true -MemberType NoteProperty 
 $obj | Add-Member -Name ErrorEncountered -Value "None" -MemberType NoteProperty 
 } 
 else { 
   $obj | Add-Member -Name HotfixInstalled -Value $false -MemberType NoteProperty 
   $obj | Add-Member -Name ErrorEncountered -Value $error[0].Exception.Message -MemberType NoteProperty 
 } 
 } 
  
 catch { 
   $obj | Add-Member -Name HotfixInstalled -Value $false -MemberType NoteProperty 
   $obj | Add-Member -Name ErrorEncountered -Value $error[0].Exception.Message -MemberType NoteProperty    
 } 
  
#Add the custom object to the array to be exported 
$Export += $obj 
 
} 
 
#Increase counter variable 
$CurrentComputer ++ 
 
 } 
  
#Export the array with hotfix-information to the user-specified path 
$Export | Export-Csv -Path $CsvFilePath -NoTypeInformation
$csvfilepath