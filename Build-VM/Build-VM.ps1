#------------------------------------------------------------------------------
# Build-VM
#
# Automates the provisioning of a VM
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function ConvertTo-DecimalIP 
#
# Allows conversion of an IP address to an unsigned 32-bit integer.
#http://www.indented.co.uk/index.php/2010/01/23/powershell-subnet-math/
#------------------------------------------------------------------------------

Function ConvertTo-DecimalIP( [String]$IP )

{
	$IPAddress = [Net.IPAddress]::Parse($IP)
	$I = 3
	$IPAddress.GetAddressBytes() | %{$DecimalIP += $_*[Math]::Pow(256,$I); $I--}
	
	Return [UInt32]$DecimalIP
}

#------------------------------------------------------------------------------
# Function ConvertTo-DottedDecimalIP 
#
# Used to switch a decimal or binary IP back to the more common dotted decimal format. The function uses a simple pair of regular expressions to determine which format is presented.
#http://www.indented.co.uk/index.php/2010/01/23/powershell-subnet-math/
#------------------------------------------------------------------------------

Function ConvertTo-DottedDecimalIP( [String]$IP )

{
	switch -regex ( $IP ) {
		"([01]{8}\.){3}[01]{8}" {
				Return [String]::Join('.', $( $IP.Split('.') | %{[Convert]::ToInt32($_, 2) } ))
			}
		"\d" {
				$IP = [UInt32]$IP
				$DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
					$Remainder = $IP % [Math]::Pow(256, $i) 
					($IP - $Remainder) / [Math]::Pow(256, $i)
					$IP = $Remainder
				})
				Return [String]::Join('.', $DottedIP)
			}
		Default {
				Write-Error "Cannot Convert this format"
			}
	}
}

#------------------------------------------------------------------------------
# Function ConvertTo-DottedDecimalIP 
#
# The functions above can be used with along with a bitwise AND operation against an IP address and subnet mask to calculate the network address.
#http://www.indented.co.uk/index.php/2010/01/23/powershell-subnet-math/
#------------------------------------------------------------------------------

Function Get-NetworkAddress( [String]$IP, [String]$Mask )

{
	Return [string](ConvertTo-DottedDecimalIP $((ConvertTo-DecimalIP $IP) -BAnd (ConvertTo-DecimalIP $Mask)))
}

#------------------------------------------------------------------------------
# Function Get-SPWebService
#
## Usage: 
#   $proxy = .\get-webservice2.ps1 [-Url] http://site/service.asmx?wsdl [-Anonymous] [[-SoapProtocol] <Soap | Soap12>]
#------------------------------------------------------------------------------

Function Get-SPWebService

{	
	param ( $url = $(throw "need `$url"), 
			[switch]$Anonymous, 
			[string]$protocol = "Soap" )
			
	[void][system.Reflection.Assembly]::LoadWithPartialName("system.web.services")
 
	trap {
	        "Error:`n`n $error";
	        break; 
	}
	
	$dcp = new-object system.web.services.discovery.discoveryclientprotocol
 
 	# ----- Get Username/Password if not using Anonymouse access
	if (! $Anonymous) {
	    Write-Progress "Network Credentials" "Awaiting input..."
	    $dcp.Credentials = (Get-Credential).GetNetworkCredential()
	}

	Write-Progress "Discovery" "Searching..."
	$dcp.AllowAutoRedirect = $true
	[void]$dcp.DiscoverAny($url)
	$dcp.ResolveAll()

	# ----- get service name
	foreach ($entry in $dcp.Documents.GetEnumerator()) { # needed for Dictionary
	    if ($entry.Value -is [System.Web.Services.Description.ServiceDescription]) {
	        $script:serviceName = $entry.Value.Services[0].Name
	        Write-Verbose "Service: $serviceName"
	    }
	}

	Write-Progress "WS-I Basic Profile 1.1" "Validating..."
	$ns = new-Object System.CodeDom.CodeNamespace # "WebServices"

	$wref = new-object System.Web.Services.Description.WebReference $dcp.Documents, $ns
	$wrefs = new-object system.web.services.description.webreferencecollection
	[void]$wrefs.Add($wref)

	$ccUnit = new-object System.CodeDom.CodeCompileUnit
	[void]$ccUnit.Namespaces.Add($ns)

	$violations = new-object system.web.Services.Description.BasicProfileViolationCollection
	$wsi11 = [system.web.services.WsiProfiles]::BasicProfile1_1

	if ([system.web.Services.Description.WebServicesInteroperability]::CheckConformance($wsi11, $wref, $violations)) {
	    Write-Progress "Proxy Generation" "Compiling..."
	    
	    $webRefOpts = new-object System.Web.Services.Description.WebReferenceOptions
		$webRefOpts.CodeGenerationOptions = "GenerateNewAsync","GenerateProperties" #,"GenerateOldAsync"

		#StringCollection strings = ServiceDescriptionImporter.GenerateWebReferences(
		#	webReferences, codeProvider, codeCompileUnit, parameters.GetWebReferenceOptions());

	    $csprovider = new-object Microsoft.CSharp.CSharpCodeProvider
		$warnings = [System.Web.Services.Description.ServiceDescriptionImporter]::GenerateWebReferences(
			$wrefs, $csprovider, $ccunit, $webRefOpts)
	        
	    if ($warnings.Count -eq 0) {
	        $param = new-object system.CodeDom.Compiler.CompilerParameters
	        [void]$param.ReferencedAssemblies.Add("System.Xml.dll")
	        [void]$param.ReferencedAssemblies.Add("System.Web.Services.dll")        
	        $param.GenerateInMemory = $true;
	        #$param.TempFiles = (new-object System.CodeDom.Compiler.TempFileCollection "c:\temp", $true)
	        $param.GenerateExecutable = $false;
	        #$param.OutputAssembly = "$($ns.Name)_$($sdname).dll"
	        $param.TreatWarningsAsErrors = $false;
	        $param.WarningLevel = 4;
	        
	        # do it
	        $compileResults = $csprovider.CompileAssemblyFromDom($param, $ccUnit);
	 
	        if ($compileResults.Errors.Count -gt 0) {
	            Write-Progress "Proxy Generation" "Failed."
	            foreach ($output in $compileResults.Output) { write-host $output }
	            foreach ($err in $compileResults.Errors) { write-warning $err }            
	        } else {            
	            $assembly = $compileResults.CompiledAssembly

	            if ($assembly) {
	                $serviceType = $assembly.GetType($serviceName)                
	                $assembly.GetTypes() | % { Write-Verbose $_.FullName }
	            } else {
	                Write-Warning "Failed: `$assembly is null"
					return
	            }
	            
	            # return proxy instance
	            $proxy = new-object $serviceType.FullName
	            if (! $Anonymous) {
	                $proxy.Credentials = $dcp.Credentials
	            }
	            $proxy # dump instance to pipeline
	        }
	    } else {
	        Write-Progress "Proxy Generation" "Failed."        
	        Write-Warning $warnings
	    }
	    #Write-Progress -Completed
	}
}

#----------------------------------------------------------------------------
# Function Get-SPListInfo
#
# Get the info from a SharePoint List
#http://msdn.microsoft.com/en-us/library/lists.lists.getlistcollection(v=office.12).aspx
#----------------------------------------------------------------------------

Function Get-SPListInfo

{
	Param ( $SPService,
			$ListName = $Null )
	
	$Lists = $SPService.GetListcollection()

	if ( $ListName -eq $null ) { # ----- Get all lists
			return $lists.Childnodes
		}
		else {	# ----- Get specific list
			foreach ( $List in $Lists.childnodes ) {
				if ( $list.Title -eq $ListName ) { return $List }
			}
	}
}

#----------------------------------------------------------------------------
# Function Get-SPList
#
# Returns the Items in a list
# http://www.u2u.info/Blogs/karine/Lists/Posts/Post.aspx?ID=26
#
# Query if Null returns the entire list.  to retrieve a subset of the list you will need to pass a CAML Query
#----------------------------------------------------------------------------

Function Get-SPList

{
	Param ( $SPService,
			$List,
			[XML]$Query = $Null )
		
	$XMLList = $SPService.GetListItems( $List.ID, $null, $Query, $null, $null, $null, $null)
	Return $XMLList.data.row 
	
}

#----------------------------------------------------------------------------
# Function Update-SPList
#
# Updates a Sharepoint List
#
#http://www.u2u.info/Blogs/Karine/Lists/Posts/Post.aspx?ID=23
#----------------------------------------------------------------------------

Function Update-SPList 

{
	Param ( $SPService,
			$list,
			[XML]$UpdateQuery )

	$SPService.UpdateListItems( $list.ID, $UpdateQuery )
}

#------------------------------------------------------------------------------
# Function Get-VMSize
#
# returns the amount of space a VM will need if vhd is full
#------------------------------------------------------------------------------

Function Get-VMSize

{
	Param( $VM )
	
	$VMSize = 0
	if ( $VM.DynamicMemoryEnabled -eq $true ) { # --- Using Dynamic Memory
			$RAM = $VM.DynamicMemoryMaximumMB / 1GB
		}
		Else { 								# --- Not using Dynamic Memory
			$RAM = $VM.Memory / 1GB
	}
	$VMSize += $RAM
	$Disks = Get-VirtualDiskDrive -VM $VM
	Foreach ($Disk in $Disks ) {
		$VMSize += ($Disk.virtualharddisk).Maximumsize / 1GB
	}
	$VMSize += $VMSize*.20
	Return $VMSize
}

#------------------------------------------------------------------------------
# Function: Get-CSVInfo
#
# Name, Path( FriendlyVolumeName ), VolSize, NumVMs, ThinSpaceUsed, FullSpaceUsed
#------------------------------------------------------------------------------

Function Get-CSVInfo

{
	param ( $ClusterName )
	
	# ----- Setup
	Import-module failoverclusters
	
	$CSVInfo = @()
	
	$Nodes = Get-ClusterNode -Cluster $ClusterName
	
	$CSVs = Get-ClusterSharedVolume -Cluster $ClusterName
	
	foreach ( $CSV in $CSVs ) {
		$CSVVolInfo = $CSV | select -ExpandProperty SharedVolumeInfo
		$CSVI = New-Object System.Object
		
		$CSVI | Add-Member -type NoteProperty -Name Name -Value $CSV.Name
		$CSVI | Add-Member -type NoteProperty -Name Path -Value $CSVVolInfo.FriendlyVolumeName
		$CSVI | Add-Member -type NoteProperty -Name VolSize -Value $CSVVolInfo.Partition.Size
		$CSVI | Add-Member -type NoteProperty -Name ThinSpaceUsed -Value $CSVVolInfo.Partition.UsedSpace
		
		$VMSize = 0
		$CLusterVMs=''
		foreach ($Node in $Nodes) {	
			$CLusterVMs = Get-VM -VMHost (Get-VMHost -ComputerName $Node.name) 
			if ($CLusterVMs -ne $Null) {
				foreach( $VM in $CLusterVMs ) {
					if ( ($VM.Location).contains($CSVVolInfo.FriendlyVolumeName)   ) {
						$VMCount += 1
						$VMSize += Get-VMSize $VM
					}	
				}
			}
		}
		
		$CSVI | Add-Member -type NoteProperty -Name NumVMs -Value $VMCount
		$CSVI | Add-Member -type NoteProperty -Name FullSpaceUsed -Value $VMSize
		
		$CSVInfo += $CSVI
	}
	
	Return $CSVInfo
}

#------------------------------------------------------------------------------
# Function Set-VMHostToDeploy
#
# Name, Cluster, CSV, path
#------------------------------------------------------------------------------

Function Set-VMHostToDeploy

{
	param ( $NewVMInfo )

	$Clusters = Get-VMHostCluster -VMHostGroup  $NewVMInfo.VMHostGroup

	$HighestRating = 0
	$ClusterResourceRatings = @()
	foreach ( $Cluster in $Clusters ) {
		$ClusterResourceRating = New-Object system.object
		$CLusterResourceRating | Add-Member -type NoteProperty -Name Cluster -Value $Cluster.Name
		$Nodes = @()
		foreach( $N in $Cluster.Nodes) { $Nodes += get-vmhost -ComputerName $N.Name }    
		$HostRatings = Get-VMHostRating  -VMHost $Nodes -DiskSpaceGB ($NewVMInfo.C+$NewVMInfo.D) -Template $NewVMInfo.VMTemplate -VMName $NewVMInfo.Name | where { $_.Rating -gt 0 } | Sort-Object -property Rating -descending
		$ClusterRating = 0
		foreach ( $H in $HostRatings ) { $ClusterRating += $H.Rating }
		$CLusterResourceRating | Add-Member -type NoteProperty -Name ClusterRating -Value $ClusterRating
		$ClusterResourceRatings += $ClusterResourceRating
	}

	$ClusterResourceRatings = $ClusterResourceRatings | sort -Descending ClusterRating

	# ---------- Determine which CSV the VM will live on

	$CSVs = @()
	$DeploymentHost = @()
	$ClusterChoosen = $False
	foreach ( $ClusterRating in $ClusterResourceRatings ) {
		if ( $ClusterChoosen -eq $False ) {
			$CSVs = Get-CSVInfo $ClusterRating.Cluster
			foreach ( $CSV in $CSVs ) {
				if ( $ClusterChoosen -eq $false ) {
					$PercentFreeSpace = (100*($CSV.FullSpaceUsed+(($NewVMInfo.C+$NewVMInfo.D+$NewVMInfo.RAMGB)*.20)))/$CSV.VolSize
					if ( $PercentFreeSpace -le .20 ) { 
						$DH = New-Object System.Object
						$DH | Add-Member -type NoteProperty -Name Cluster -Value $ClusterRating.Cluster
						$DH | Add-Member -type NoteProperty -Name CSV -Value $CSV.Name
						$DH | Add-Member -type NoteProperty -Name Path -Value $CSV.Path
						$Nodes = @()
						$HostRatings = @()
						foreach($N in (Get-ClusterNode -Cluster $ClusterRating.Cluster)) { $Nodes += get-vmhost -ComputerName $N.Name }
						$HostRatings = Get-VMHostRating  -VMHost $Nodes -DiskSpaceGB ($NewVMInfo.C+$NewVMInfo.D) -Template $NewVMInfo.VMTemplate -VMName $NewVMInfo.Name | where { $_.Rating -gt 0 } | Sort-Object -property Rating -descending
						# ----- Select the highest Rated Host
						$HighestRating = 0
						foreach ( $HR in $HostRatings ) {
							if ( $HR.Rating -gt $HighestRating ) {
								$HighestRating = $HR.Rating
								$UseHost = $HR.Name
							}
						}
						$DH | Add-Member -type NoteProperty -Name Host -Value $UseHost
						$ClusterChoosen = $true
						$DeploymentHost += $DH
					}
				}
			}
		}
	}
	
	Return $DeploymentHost
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

Get-VMMServer VBAS0080 | out-null

# ----- Get list of Approved VMs from the SHarepoint list Virtual Machine Requests.
$SPProxy = get-SPWebService -Url 'http://vbnet/_vti_bin/lists.asmx'
$SPProxy.url = 'http://vbnet/comit/ss/SITeam/_vti_bin/lists.asmx'

$NewVMList = Get-SPListInfo $SPProxy 'Virtual machine requests'

$Query = "<Query><Where><Eq><FieldRef Name='Status' /><Value Type='Text'>Approved</Value></Eq></Where></Query>" 
$NewVMRequests = Get-SPList $SPProxy $NewVMList $Query

# ----- Repeat for each Approve Request...
foreach ( $NewVMRequest in $NewVMRequests ) {

	$NewVMInfo = New-Object System.Object
	# ----- Get inputs from the list

	# ---------- Get new VM name
	
	$VMName = $NewVMRequest.ows_Title
	$NewVMInfo | Add-Member -type NoteProperty -Name Name -Value $VMName

	Write-Host "Gathering information on $VMName...."

#	# --------- Get VM Description
#	$NewVMRequest.ows_Description | Get-Member
	
	$Desc = " "
	$NewVMInfo | Add-Member -type NoteProperty -Name Desc -Value $Desc

#
#	# ---------- Get VM Owner
#	$Owner = "vbgov\$NewVMRequest.ows_Requester"
	$Owner = "jbuentin"
	$NewVMInfo | Add-Member -type NoteProperty -Name Owner -Value $Owner

	# ---------- Get IP Address
	

	$NewVMInfo | Add-Member -type NoteProperty -Name IP -Value (Read-Host -Prompt "$VMName IP Address: ")
	$NewVMInfo | Add-Member -type NoteProperty -Name Mask -Value (Read-Host -prompt "$VMName Subnet Mask: ")

	switch ( get-networkaddress $NewVMInfo.IP $NewVMInfo.Mask  ) {
		'10.100.4.0' {$NewVMInfo | Add-Member -type NoteProperty -Name VLANID -Value 900}
		'10.100.8.0' {$NewVMInfo | Add-Member -type NoteProperty -Name VLANID -Value 901}
		'10.100.12.0' {$NewVMInfo | Add-Member -type NoteProperty -Name VLANID -Value 902}
	}

	# ---------- Get OS ( and thus the template to use )

	Switch ( $NewVMRequest.ows_OS ) {
		"WIN 2008 R2 Enterprise x64" {
			$NewVMInfo | Add-Member -type NoteProperty -Name VMTemplate -Value ( Get-Template | where { $_.Name -eq "WIN 2008 R2 ENT SP1" } )
			$NewVMInfo | Add-Member -type NoteProperty -Name C -Value $NewVMRequest.ows_C_x003a__x0020_drive
			$NewVMInfo | Add-Member -type NoteProperty -Name D -Value $NewVMRequest.ows_D_x003a__x0020_drive
			$GuestOSProfile = Get-GuestOSProfile | where {$_.Name -eq "WIN 2008 R2 ENT"}
			$OperatingSystem = Get-OperatingSystem | where {$_.Name -eq "64-bit edition of Windows Server 2008 Enterprise"}
		}
		"WIN 2008 R2 Standard x64" {
			$NewVMInfo | Add-Member -type NoteProperty -Name VMTemplate -Value ( Get-Template | where { $_.Name -eq "WIN 2008 R2 STD SP1" } )
			$NewVMInfo | Add-Member -type NoteProperty -Name C -Value $NewVMRequest.ows_C_x003a__x0020_drive
			$NewVMInfo | Add-Member -type NoteProperty -Name D -Value $NewVMRequest.ows_D_x003a__x0020_drive
			$GuestOSProfile = Get-GuestOSProfile | where {$_.Name -eq "WIN 2008 R2 STD"}
			$OperatingSystem = Get-OperatingSystem | where {$_.Name -eq "64-bit edition of Windows Server 2008 Standard"}
		}
		"WIN 2008 Enterprise x64" {
			$NewVMInfo | Add-Member -type NoteProperty -Name VMTemplate -Value ( Get-Template | where { $_.Name -eq "WIN 2008    ENT SP2 x64" } )
			$NewVMInfo | Add-Member -type NoteProperty -Name C -Value $NewVMRequest.ows_C_x003a__x0020_drive
			$NewVMInfo | Add-Member -type NoteProperty -Name D -Value $NewVMRequest.ows_D_x003a__x0020_drive
			$GuestOSProfile = Get-GuestOSProfile | where {$_.Name -eq "WIN 2008 ENT"}
			$OperatingSystem = Get-OperatingSystem | where {$_.Name -eq "64-bit edition of Windows Server 2008 Enterprise"}
		}
		"WIN 2008 Standard x64" {
			$NewVMInfo | Add-Member -type NoteProperty -Name VMTemplate -Value ( Get-Template | where { $_.Name -eq "WIN 2008    STD SP2 x64" } )
			$NewVMInfo | Add-Member -type NoteProperty -Name C -Value $NewVMRequest.ows_C_x003a__x0020_drive
			$NewVMInfo | Add-Member -type NoteProperty -Name D -Value $NewVMRequest.ows_D_x003a__x0020_drive
			$GuestOSProfile = Get-GuestOSProfile | where {$_.Name -eq "WIN 2008 STD"}
			$OperatingSystem = Get-OperatingSystem | where {$_.Name -eq "64-bit edition of Windows Server 2008 Standard"}
		}
		"WIN 2008 Enterprise x32" {
			$NewVMInfo | Add-Member -type NoteProperty -Name VMTemplate -Value ( Get-Template | where { $_.Name -eq "WIN 2008    ENT SP2 x32" } )
			$NewVMInfo | Add-Member -type NoteProperty -Name C -Value $NewVMRequest.ows_C_x003a__x0020_drive
			$NewVMInfo | Add-Member -type NoteProperty -Name D -Value $NewVMRequest.ows_D_x003a__x0020_drive
			$GuestOSProfile = Get-GuestOSProfile | where {$_.Name -eq "WIN 2008 ENT"}
			$OperatingSystem = Get-OperatingSystem | where {$_.Name -eq "Windows Server 2008 Enterprise 32-Bit"}
		}
		"WIN 2008 Standard x32" {
			$NewVMInfo | Add-Member -type NoteProperty -Name VMTemplate -Value ( Get-Template | where { $_.Name -eq "WIN 2008    STD SP2 x32" } )
			$NewVMInfo | Add-Member -type NoteProperty -Name C -Value $NewVMRequest.ows_C_x003a__x0020_drive
			$NewVMInfo | Add-Member -type NoteProperty -Name D -Value $NewVMRequest.ows_D_x003a__x0020_drive
			$GuestOSProfile = Get-GuestOSProfile | where {$_.Name -eq "WIN 2008 STD"}
			$OperatingSystem = Get-OperatingSystem | where {$_.Name -eq "Windows Server 2008 Standard 32-Bit"}
		}
	}

	# ---------- Get MAX RAM

	$NewVMInfo | Add-Member -type NoteProperty -Name RAMGB -Value ( "{0:N0}" -f [int]$NewVMRequest.ows_RAM )
 
	# ---------- Get # CPU

	$NewVMInfo | Add-Member -type NoteProperty -Name CPU -Value $NewVMRequest.ows_CPU

	# ----- Get and sort the host ratings for all hosts in cluster

	# ---------- Get Test/Dev or Prod Hostgroup
	Switch (($NewVMInfo.Name).substring(4,1) ) {
		0 { $NewVMInfo | Add-Member -type NoteProperty -Name VMHostGroup -Value "Production" }
		1 { $NewVMInfo | Add-Member -type NoteProperty -Name VMHostGroup -Value "Remote Servers" }
		8 { $NewVMInfo | Add-Member -type NoteProperty -Name VMHostGroup -Value "Test Dev" }
		9 { $NewVMInfo | Add-Member -type NoteProperty -Name VMHostGroup -Value "Test Dev" }
	}
	
	# ---------- Determine the cluster to place the VM in.

	$DeploytoHost = Set-VMHostToDeploy $NewVMInfo

	# ----- Build the VM

	$HardwareProfile = Get-HardwareProfile | where {$_.name -eq 'Standard HW' }

	Write-Host "Creating New VM $VMName...."

	
	$NewVM = New-VM -Template $NewVMInfo.VMTemplate -Name $NewVMInfo.Name -Description $NewVMInfo.Desc -VMHost $DeployToHost.Host -Path $DeployToHost.Path -Owner $NewVMInfo.Owner -HardwareProfile $HardwareProfile -GuestOSProfile $GuestOSProfile -ComputerName $NewVMInfo.Name -TimeZone 35 -GuiRunOnceCommands "runas/user:1comit$admin! ""\\vbgov.com\deploy\Disaster_Recovery\Hyper-V Windows 2008\Scripts\Run-Once\win2008R2_run-once.cmd""" -AnswerFile $null -OperatingSystem $OperatingSystem -StartAction AlwaysAutoTurnOnVM -DelayStart 180 -StopAction SaveVM -DynamicMemoryEnabled $true -DynamicMemoryMaximumMB (([int]$NewVMInfo.RAMGB)*1024) -MemoryMB 512

	# ---------- Set the NIC
	
	Write-Host "Configuring NIC ..."
	
	$NIC = Get-VirtualNetworkAdapter -VM $NewVM
	Set-VirtualNetworkAdapter -VirtualNetworkAdapter $NIC -VirtualNetwork "Virtual Switch 01" -VLanEnabled $True -VLanId $NewVMInfo.VLANID 

	Write-Host "Starting $VMName..."
	Start-VM $VM

	# ----- Configure the VM

	# ---------- Add Operations group to Poweruser / Remote desktop User 

	# ---------- Install Scom

}