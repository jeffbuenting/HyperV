#get-ipAddress.ps1
$hostCur = “”
$outfilename = “c:/temp/out.csv”
“hostname,IP” | Out-File $outfilename -encoding ASCII




$Servers = get-qadcomputer -SearchRoot 'vbgov.com/Servers' | sort name


foreach ($S in $Servers ){
	$Computer = $S.name

	$IPList = GWMI -class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $Computer -filter "IpEnabled = TRUE" -erroraction SilentlyContinue


	$ComputerIPs=''

	if ( $IPList -ne $null ) {
		$IPs = (0..3)
		$Filled = $False
		ForEach ($IP in $IPList) {
			foreach ( $I in $IP.IPAddress ){
				$Matched = $False
				if ( $I.startswith( "10.100.20" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.21" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.22" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.51" ) ) {
					$IPs[2]=$I
					$Matched = $True
				}
				if ( $Matched -eq $false ) {
					if ( $I.startswith( "10" ) ) {
						if ( $Filled -ne $true ) {
								$IPs[0]=$I
								$Filled=$true
							}
							else {
								$IPs[3]=$I
						}
					}
				}
			}
		
			$ComputerIPs=''
			for ( $I=0; $I -le 3; $I++ ) {
				if ( $IPs[$I] -ne $I ) {
						$ComputerIPs = $ComputerIPs+','+$IPs[$I]
					}
					else {
						$ComputerIPs = $ComputerIPs+',-'
				}
			}
		}
	}
	
	Write-Output “$Computer, $ComputerIPs”
	“$Computer $ComputerIPs” | Out-File $outfilename -encoding ASCII -append
	
			
}


$Servers = get-qadcomputer -SearchRoot 'vbgov.com/Servers Terminal' | sort name


foreach ($S in $Servers ){
	$Computer = $S.name
	
	$IPList = GWMI -class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $Computer -filter "IpEnabled = TRUE" -erroraction SilentlyContinue


	$ComputerIPs=''

	if ( $IPList -ne $null ) {
		$IPs = (0..3)
		$Filled = $False
		ForEach ($IP in $IPList) {
			foreach ( $I in $IP.IPAddress ){
				$Matched = $False
				if ( $I.startswith( "10.100.20" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.21" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.22" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.51" ) ) {
					$IPs[2]=$I
					$Matched = $True
				}
				if ( $Matched -eq $false ) {
					if ( $I.startswith( "10" ) ) {
						if ( $Filled -ne $true ) {
								$IPs[0]=$I
								$Filled=$true
							}
							else {
								$IPs[3]=$I
						}
					}
				}
			}
		
			$ComputerIPs=''
			for ( $I=0; $I -le 3; $I++ ) {
				if ( $IPs[$I] -ne $I ) {
						$ComputerIPs = $ComputerIPs+','+$IPs[$I]
					}
					else {
						$ComputerIPs = $ComputerIPs+',-'
				}
			}
		}
	}
	
	Write-Output “$Computer, $ComputerIPs”
	“$Computer $ComputerIPs” | Out-File $outfilename -encoding ASCII -append
	
			
}



$Servers = get-qadcomputer -SearchRoot 'vbgov.com/Servers Virtual Host' | sort name


foreach ($S in $Servers ){
	$Computer = $S.name
	
	$IPList = GWMI -class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $Computer -filter "IpEnabled = TRUE" -erroraction SilentlyContinue


	$ComputerIPs=''

	if ( $IPList -ne $null ) {
		$IPs = (0..3)
		$Filled = $False
		ForEach ($IP in $IPList) {
			foreach ( $I in $IP.IPAddress ){
				$Matched=$False
				if ( $I.startswith( "10.100.20" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.21" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.22" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.51" ) ) {
					$IPs[2]=$I
					$Matched = $True
				}
				if ( $Matched -eq $false ) {
					if ( $I.startswith( "10" ) ) {
						if ( $Filled -ne $true ) {
								$IPs[0]=$I
								$Filled=$true
							}
							else {
								$IPs[3]=$I
						}
					}
				}
			}
		
			$ComputerIPs=''
			for ( $I=0; $I -le 3; $I++ ) {
				if ( $IPs[$I] -ne $I ) {
						$ComputerIPs = $ComputerIPs+','+$IPs[$I]
					}
					else {
						$ComputerIPs = $ComputerIPs+',-'
				}
			}
		}
	}
	
	Write-Output “$Computer, $ComputerIPs”
	“$Computer $ComputerIPs” | Out-File $outfilename -encoding ASCII -append
	
			
}




$Servers = get-qadcomputer -SearchRoot 'vbgov.com/Servers Developement' | sort name


foreach ($S in $Servers ){
	$Computer = $S.name
	
	$IPList = GWMI -class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $Computer -filter "IpEnabled = TRUE" -erroraction SilentlyContinue


	$ComputerIPs=''

	if ( $IPList -ne $null ) {
		$IPs = (0..3)
		$Filled = $False
		ForEach ($IP in $IPList) {
			foreach ( $I in $IP.IPAddress ){
				$Matched = $False
				if ( $I.startswith( "10.100.20" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.21" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.22" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.51" ) ) {
					$IPs[2]=$I
					$Matched = $True
				}
				if ( $Matched -eq $false ) {
					if ( $I.startswith( "10" ) ) {
						if ( $Filled -ne $true ) {
								$IPs[0]=$I
								$Filled=$true
							}
							else {
								$IPs[3]=$I
						}
					}
				}
			}
		
			$ComputerIPs=''
			for ( $I=0; $I -le 3; $I++ ) {
				if ( $IPs[$I] -ne $I ) {
						$ComputerIPs = $ComputerIPs+','+$IPs[$I]
					}
					else {
						$ComputerIPs = $ComputerIPs+',-'
				}
			}
		}
	}
	
	Write-Output “$Computer, $ComputerIPs”
	“$Computer $ComputerIPs” | Out-File $outfilename -encoding ASCII -append
	
			
}


$Servers = get-qadcomputer -SearchRoot 'vbgov.com/Servers File and Print' | sort name


foreach ($S in $Servers ){
	$Computer = $S.name
	
	$IPList = GWMI -class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $Computer -filter "IpEnabled = TRUE" -erroraction SilentlyContinue


	$ComputerIPs=''

	if ( $IPList -ne $null ) {
		$IPs = (0..3)
		$Filled = $False
		ForEach ($IP in $IPList) {
			foreach ( $I in $IP.IPAddress ){
				$Matched = $False
				if ( $I.startswith( "10.100.20" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.21" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.22" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.51" ) ) {
					$IPs[2]=$I
					$Matched = $True
				}
				if ( $Matched -eq $false ) {
					if ( $I.startswith( "10" ) ) {
						if ( $Filled -ne $true ) {
								$IPs[0]=$I
								$Filled=$true
							}
							else {
								$IPs[3]=$I
						}
					}
				}
			}
		
		
			$ComputerIPs=''
			for ( $I=0; $I -le 3; $I++ ) {
				if ( $IPs[$I] -ne $I ) {
						$ComputerIPs = $ComputerIPs+','+$IPs[$I]
					}
					else {
						$ComputerIPs = $ComputerIPs+',-'
				}
			}
		}
	}
	
	Write-Output “$Computer, $ComputerIPs”
	“$Computer $ComputerIPs” | Out-File $outfilename -encoding ASCII -append
	
			
}



$Servers = get-qadcomputer -SearchRoot 'vbgov.com/Servers Test' | sort name


foreach ($S in $Servers ){
	$Computer = $S.name
	
	$IPList = GWMI -class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $Computer -filter "IpEnabled = TRUE" -erroraction SilentlyContinue


	$ComputerIPs=''

	if ( $IPList -ne $null ) {
		$IPs = (0..3)
		$Filled = $False
		ForEach ($IP in $IPList) {
			foreach ( $I in $IP.IPAddress ){
				$Matched = $False
				if ( $I.startswith( "10.100.20" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.21" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.22" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.51" ) ) {
					$IPs[2]=$I
					$Matched = $True
				}
				if ( $Matched -eq $false ) {
					if ( $I.startswith( "10" ) ) {
						if ( $Filled -ne $true ) {
								$IPs[0]=$I
								$Filled=$true
							}
							else {
								$IPs[3]=$I
						}
					}
				}
			}
		
			$ComputerIPs=''
			for ( $I=0; $I -le 3; $I++ ) {
				if ( $IPs[$I] -ne $I ) {
						$ComputerIPs = $ComputerIPs+','+$IPs[$I]
					}
					else {
						$ComputerIPs = $ComputerIPs+',-'
				}
			}
		}
	}
	
	Write-Output “$Computer, $ComputerIPs”
	“$Computer $ComputerIPs” | Out-File $outfilename -encoding ASCII -append
	
			
}

$Servers = get-qadcomputer -SearchRoot 'vbgov.com/Servers Network Services' | sort name


foreach ($S in $Servers ){
	$Computer = $S.name

	$IPList = GWMI -class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $Computer -filter "IpEnabled = TRUE" -erroraction SilentlyContinue


	$ComputerIPs=''

	if ( $IPList -ne $null ) {
		$IPs = (0..3)
		$Filled = $False
		ForEach ($IP in $IPList) {
			foreach ( $I in $IP.IPAddress ){
				$Matched = $False
				if ( $I.startswith( "10.100.20" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.21" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.22" ) ) {
					$IPS[1]=$I
					$Matched = $True
				}
				if ( $I.startswith( "10.100.51" ) ) {
					$IPs[2]=$I
					$Matched = $True
				}
				if ( $Matched -eq $false ) {
					if ( $I.startswith( "10" ) ) {
						if ( $Filled -ne $true ) {
								$IPs[0]=$I
								$Filled=$true
							}
							else {
								$IPs[3]=$I
						}
					}
				}
			}
		
			$ComputerIPs=''
			for ( $I=0; $I -le 3; $I++ ) {
				if ( $IPs[$I] -ne $I ) {
						$ComputerIPs = $ComputerIPs+','+$IPs[$I]
					}
					else {
						$ComputerIPs = $ComputerIPs+',-'
				}
			}
		}
	}
	
	Write-Output “$Computer, $ComputerIPs”
	“$Computer $ComputerIPs” | Out-File $outfilename -encoding ASCII -append
	
			
}
