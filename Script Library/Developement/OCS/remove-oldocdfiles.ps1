#------------------------------------------------------------------------------
# remove-OldOCSfiles.ps1
#
# nightly maintenance to remove metadata and presentation files older than 14 days
#------------------------------------------------------------------------------

$Date = "{0:mm/dd/yyyy}" -f (Get-Date)
$date
$date=$Date.adddays(-14)
$date
# run dmdel.exe ----------------------------------------------------------------

#&'c:\program files\microsoft office communications server 2007\reskit\dmdel.exe' a=[delete] m=[d:\ocsdata\metadata] c=[d:\ocsdata\presentations] e=[









