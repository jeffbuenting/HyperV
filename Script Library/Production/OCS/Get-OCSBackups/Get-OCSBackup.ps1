#----------------------------------------------------------------------------------------------------------------
# Get-OCSBackup.ps1
#
# Backsup the OCS 2007 R2 Enterprise Consolodated Topology Server configuration
#-----------------------------------------------------------------------------------------------------------------

$Date = "{0:yyyy-MM-dd}" -f (Get-Date)


#backsup the OCS Global, Pool and Machine settings ----------------------------------------------------------------

& 'c:\Program Files\common files\microsoft office communications server 2007 R2\lcscmd.exe' /config /action:export /level:global /configfile:c:\OCSBackups\Global_$Date.xml /poolname:OCSPool001
& 'c:\Program Files\common files\microsoft office communications server 2007 R2\lcscmd.exe' /config /action:export /level:pool /configfile:c:\OCSBackups\Pool_$Date.xml /poolname:OCSPool001
& 'c:\Program Files\common files\microsoft office communications server 2007 R2\lcscmd.exe' /config /action:export /level:machine /configfile:c:\OCSBackups\Machine_$Date.xml /poolname:OCSPool001

# Backup the IIS configuration -------------------------------------------------------------------------------------

Copy-Item c:\Windows\System32\inetsrv\config\*.* c:\ocsbackups\IIS

#Backup the OCS address book Normalization .txt file ----------------------------------------------------------------

copy-item c:\ocsdata\abs\company_phone_number_normalization_rules.txt c:\ocsbackups\company_phone_number_normalization_rules_$Date.txt

#Copy the files to \\vbfp0012\Disaster_Recovery\Office Communications Server\Backups\VMAS0073\OCS and files ---------

$ToLocation = "\\vbfp0012\Disaster_Recovery\Office Communications Server\Backups\VBAS0081\OCS and files\"
Move-item c:\ocsbackups\*.* $ToLocation

#Remove backups over 2 weeks old ------------------------------------------------------------------------------------

$Date = (Get-Date).adddays(-14)
 
dir $ToLocation | where { $_.Lastwritetime -lt $Date } | foreach {
    $Filename = $ToLocation+$_.name
    remove-item -path $Filename
}




