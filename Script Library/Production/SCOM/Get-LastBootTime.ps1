#-------------------------------------------------------------------------
# Get-LastBootTime
#
# Gets the time the system last started.
#-------------------------------------------------------------------------

$Computer = $args[0]

$OS = get-wmiobject Win32_OperatingSystem -computername $Computer

$OS.ConverttoDateTime($OS.lastBootupTime)




