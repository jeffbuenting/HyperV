$COMITOpsSrvShutdownGroup = [ADSI]("WinNT://vbgov/Comit Operations Server Shutdown-U")
$COMITOpsSupDataCenterGroup = [ADSI]("WinNT://vbgov/COMIT Operations Support data Center-U")

$ComputerName = GC env:computername

$LocalPowerUsersGroup = [ADSI]("WinNT://$ComputerName/Power Users")

$LocalRemoteDesktopUsersGroup = [ADSI]("WinNT://$ComputerName/Remote Desktop Users")

$LocalPowerUsersGroup.PSBase.Invoke("Add",$COMITOpsSrvShutdownGroup.PSBase.Path)
$LocalRemoteDesktopUsersGroup.PSBase.Invoke("Add",$COMITOpsSupDataCenterGroup.PSBase.Path)


