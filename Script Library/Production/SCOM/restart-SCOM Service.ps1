$VMHosts = Get-VMHost -VMMServer vbas0080 | where { $_.OperatingSystem -like "Microsoft Windows Server 2008 R2 Enterprise*" } |sort name

foreach ($Server in $VMHosts ) {
    
	 	write-host $Server.name	
		Invoke-Command -ComputerName $Server.name -ScriptBlock { Net stop healthservice }
		Invoke-Command -ComputerName $Server.name -ScriptBlock { net start healthservice }
		
	
}